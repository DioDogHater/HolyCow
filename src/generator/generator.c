#include "generator.h"
#include "../dev/style.h"

#include "target_requirements.h"
#include "target_x64_Linux.h"

size_t stack_ptr = 0;
size_t stack_sz = 0;
size_t label_count = 1;

vector_t vars[1] = { NEW_VECTOR(var_t) };

node_term* str_literals = NULL;
size_t str_literal_count = 0;

#define DUMMY_TYPE(t) {tk_##t, NULL, 0, NULL}
#define GET_DUMMY_TYPE(t) (&dummy_types[(tk_##t - tk_int8)])
static token_t dummy_types[] = {
    DUMMY_TYPE(int8),
    DUMMY_TYPE(uint8),
    DUMMY_TYPE(int16),
    DUMMY_TYPE(uint16),
    DUMMY_TYPE(int32),
    DUMMY_TYPE(uint32),
    DUMMY_TYPE(int64),
    DUMMY_TYPE(uint64),
    DUMMY_TYPE(float),
    DUMMY_TYPE(string),
    DUMMY_TYPE(bool),
    DUMMY_TYPE(flag),
    DUMMY_TYPE(void)
};

// Find if a register is free or not depending on its children
static bool is_reg_free(reg_t* reg){
    if(!reg || reg->occupied)
        return false;
    for(reg_t* child = reg->children; child && child->name; child++)
        if(child->occupied) return false;
    return true;
}

// Get a free register with a certain size or NULL if there are none
static reg_t* get_free_reg(size_t size, reg_t* reg_arr){
    for(; reg_arr && reg_arr->name; reg_arr++){
        if(reg_arr->size == size && is_reg_free(reg_arr))
            return reg_arr;
        else if(reg_arr->size != size && reg_arr->children){
            reg_t* reg = get_free_reg(size, reg_arr->children);
            if(reg) return reg;
        }
    }
    return NULL;
}
#define GET_FREE_REG(sz) get_free_reg((sz), registers)

// Get a occupied / free register masked with a reg_mask or NULL if there are none
static reg_t* get_occup_mask_reg(size_t size, bool occup, reg_mask mask, reg_t* reg_arr){
    for(; reg_arr && reg_arr->name; reg_arr++){
        if(!REG_IN_MASK(reg_arr, mask))
            continue;
        if(reg_arr->size == size && is_reg_free(reg_arr) != occup)
            return reg_arr;
        else if(reg_arr->size != size && reg_arr->children){
            reg_t* reg = get_occup_mask_reg(size, occup, mask, reg_arr->children);
            if(reg) return reg;
        }
    }
    return NULL;
}
#define GET_MASK_REG(sz, m) get_occup_mask_reg((sz), false, (m), registers)
#define GET_OCC_MASK_REG(sz, m) get_occup_mask_reg((sz), true, (m), registers)
#define GET_OP_REG1(sz, op) get_occup_mask_reg((sz), false, allowed_##op##_regs1, registers)
#define GET_OCC_OP_REG1(sz, op) get_occup_mask_reg((sz), true, allowed_##op##_regs1, registers)
#define GET_OP_REG2(sz, op) get_occup_mask_reg((sz), false, allowed_##op##_regs2, registers)
#define GET_OCC_OP_REG2(sz, op) get_occup_mask_reg((sz), true, allowed_##op##_regs2, registers)

// Get all registers in mask
// Returns number of masked registers
static int get_mask_regs(reg_mask mask, reg_t* reg_arr, reg_t* masked_regs[MAX_REGS]){
    int n = 0;
    for(; reg_arr && reg_arr->name; reg_arr++){
        if(!REG_IN_MASK(reg_arr, mask))
            continue;
        masked_regs[n++] = reg_arr;
        if(reg_arr->children)
            n += get_mask_regs(mask, reg_arr->children, &masked_regs[n]);
    }
    return n;
}
#define FIND_MASK_REGS(m, buff) get_mask_regs((m), registers, (buff))

// Get all occupied / free registers in mask
// Returns number of masked registers
static int get_mask_occup_regs(reg_mask mask, bool occup, reg_t* reg_arr, reg_t* masked_regs[MAX_REGS]){
    int n = 0;
    for(; reg_arr && reg_arr->name; reg_arr++){
        if(!REG_IN_MASK(reg_arr, mask) || is_reg_free(reg_arr) == occup)
            continue;
        masked_regs[n++] = reg_arr;
        if(reg_arr)
            n += get_mask_occup_regs(mask, occup, reg_arr, &masked_regs[n]);
    }
    return n;
}
#define FIND_AFFECTED_REGS(op, buff) get_mask_occup_regs(GET_AFFECTED_REGS(op), true, registers, (buff))

static reg_t* alloc_reg(reg_t* reg, bool sign){
    if(!reg)
        return NULL;
    reg->occupied = ((sign) ? OCCUP_SIGNED : OCCUP_UNSIGNED);
    for(reg_t* child = reg->children; child && child->name; child++)
        alloc_reg(child, sign);
    return reg;
}

static reg_t* free_reg(reg_t* reg){
    if(!reg)
        return NULL;
    reg->occupied = OCCUP_NONE;
    for(reg_t* child = reg->children; child && child->name; child++)
        free_reg(child);
    return reg;
}

// Move value from a -> b
// Frees a and occupies b instead
static reg_t* transfer_reg(HC_FILE fptr, reg_t* a, reg_t* b){
    if(!a || !b)
        return NULL;
    bool sign = a->occupied == OCCUP_SIGNED;
    if(a->size < b->size)
        gen_movex_reg(fptr, b, a, sign);
    else
        gen_move_reg(fptr, b, a);
    free_reg(a);
    alloc_reg(b, sign);
    return b;
}

static void print_type(const char* before, type_t type, const char* after){
    HC_PRINT("%s", before);
    if(type.repr){
        HC_PRINT(BOLD "%.*s", (int)type.repr->strlen, type.repr->str);
        if(type.repr->type == tk_const)
            HC_PRINT(" %.*s", (int)type.repr->next->strlen, type.repr->next->str);
        for(size_t i = 0; i < type.ptr_depth; i++)
            HC_PRINT("*");
    }else{
        HC_PRINT(BOLD "(%lu, %s, %d)", type.size, type.sign ? "signed" : "unsigned", type.ptr_depth);
    }
    HC_PRINT(RESET_ATTR "%s\n", after);
}

// Returns the sign of a value of type tk
static bool signof_type(token_t* tk){
    if(!tk)
        return 0;

    // Ignore const
    if(tk->type == tk_const)
        tk = tk->next;

    switch(tk->type){
        case tk_flag:
        case tk_void:
        case tk_bool:
        case tk_float:
            return false;
        case tk_int8:
        case tk_int16:
        case tk_int32:
        case tk_int64:
            return true;
        case tk_uint8:
        case tk_uint16:
        case tk_uint32:
        case tk_uint64:
            return false;
    }

    print_context("Type has unknown sign", tk);
    return false;
}

// Returns the size of a value of type tk in bytes
static size_t sizeof_type(token_t* tk){
    if(!tk)
        return 0;

    // Ignore const
    if(tk->type == tk_const)
        tk = tk->next;

    switch(tk->type){
    case tk_flag:
    case tk_void:
        return 0;
    case tk_int8:
    case tk_uint8:
    case tk_bool:
        return 1;
    case tk_int16:
    case tk_uint16:
        return 2;
    case tk_int32:
    case tk_uint32:
        return 4;
    case tk_int64:
    case tk_uint64:
    case tk_float:
        return 8;
    }

    print_context("Type of unknown size", tk);
    return 0;
}

var_t* get_var(const char* str, size_t strlen){
    for(size_t i = 0; i < vector_size(vars); i++){
        var_t* var = vector_at(vars, i);
        if(var->strlen == strlen && strncmp(var->str, str, strlen) == 0)
            return var;
    }
    return NULL;
}

static type_t type_from_tk(token_t* tk){
    size_t sz = sizeof_type(tk);
    bool sign = signof_type(tk);
    int ptr_depth = 0;
    for(token_t* ptr = (tk->type == tk_const) ? tk->next->next : tk->next; ptr && ptr->type == tk_mult; ptr = ptr->next)
        ptr_depth++;
    return (type_t){sz, tk, sign, DATA_INT, ptr_depth};
}

#define TYPE_MAX(a, b) ((a).size > (b).size || ((a).size == (b).size && (a).sign > (b).sign)) ? (a) : (b)
static type_t typeof_expr(node_expr* expr){
    type_t max = INVALID_TYPE;
    switch(expr->type){
    case tk_cmp_eq:
    case tk_cmp_neq:
    case tk_cmp_g:
    case tk_cmp_ge:
    case tk_cmp_l:
    case tk_cmp_le:
    case tk_cmp_approx:
    case tk_and:
    case tk_or:
    case tk_not:
    case tk_bool_lit:
        max = (type_t){1,GET_DUMMY_TYPE(bool),false,DATA_INT,0};
        break;
    case tk_char_lit:
        max = (type_t){1,GET_DUMMY_TYPE(uint8),false,DATA_INT,0};
        break;
    case tk_int_lit:{
        const char* str = expr->term.str;
        size_t strlen = expr->term.strlen;
        uint64_t r = 0;
        for(; strlen; str++, strlen--)
            r = r * 10 + (uint64_t)(*str - '0');
        if(r < (1 << 7))
            max = (type_t){1,GET_DUMMY_TYPE(int8),true,DATA_INT,0};
        else if(r < (1 << 15))
            max = (type_t){2,GET_DUMMY_TYPE(int16),true,DATA_INT,0};
        else if(r < (1 << 31))
            max = (type_t){4,GET_DUMMY_TYPE(int32),true,DATA_INT,0};
        else
            max = (type_t){8,GET_DUMMY_TYPE(int64),true,DATA_INT,0};
        break;
    }case tk_identifier:{
        var_t* var = get_var(expr->term.str, expr->term.strlen);
        if(!var){
            print_context_ex("Unknown identifier", expr->term.str, expr->term.strlen);
            return INVALID_TYPE;
        }
        max = var->type;
        break;
    }case tk_neg:
    case tk_bin_flip:
    case tk_inc:
    case tk_dec:
    case tk_post_inc:
    case tk_post_dec:
        max = typeof_expr(expr->unary_op.lhs);
        break;
    case tk_deref:
        max = typeof_expr(expr->unary_op.lhs);
        max.ptr_depth--;
        if(max.ptr_depth < 0){
            print_context_expr("Trying to dereference a direct value", expr);
            return max;
        }
        break;
    case tk_getaddr:
        max = typeof_expr(expr->unary_op.lhs);
        max.ptr_depth++;
        break;
    case tk_type_cast:
        max = type_from_tk(expr->type_cast.lhs->start);
        break;
    case tk_add:
    case tk_sub:
    case tk_mult:
    case tk_div:
    case tk_mod:
    case tk_bin_and:
    case tk_bin_or:
    case tk_bin_xor:{
        type_t t1 = typeof_expr(expr->bin_op.lhs), t2 = typeof_expr(expr->bin_op.rhs);
        if(t1.size && t2.size)
            max = TYPE_MAX(t1, t2);
        break;
    }
    }
    return max;
}

// Save a value in an expression
static bool save_expr(HC_FILE fptr, node_expr* expr, reg_t* data){
    if(expr->type == tk_identifier){
        var_t* var = get_var(expr->term.str, expr->term.strlen);
        if(!var){
            print_context_ex("Unknown identifier", expr->term.str, expr->term.strlen);
            return false;
        }
        if(var->location == VAR_STACK)
            gen_save_stack(fptr, data, stack_sz - var->stack_ptr);
        else if(var->location == VAR_GLOBAL)
            gen_save_global(fptr, data, var->str, var->strlen);
        else if(var->location == VAR_ARG)
            gen_save_arg(fptr, data, var->stack_ptr);
        else{
            print_context_expr("Not implemented yet", expr);
            return false;
        }
        return true;
    }
    print_context_expr("Unable to save to expr", expr);
    return false;
}

#define FAIL_EXPR() \
do{\
    HC_ERR("\nGENERATION FAILED!");\
    vector_destroy(vars);\
    HC_FCLOSE(fptr);\
    HC_FAIL();\
}while(0)

#define SIGNED_OP1(sign, n) ((sign) ? GET_ALLOWED_REGS1(n) : GET_ALLOWED_REGS1(s##n))
#define SIGNED_OP2(sign, n) ((sign) ? GET_ALLOWED_REGS2(n) : GET_ALLOWED_REGS2(s##n))
#define SIGNED_AFFECTED(sign, n) ((sign) ? GET_AFFECTED_REGS(n) : GET_AFFECTED_REGS(s##n))
reg_t* generate_expr(HC_FILE fptr, node_expr* expr, type_t target_type, reg_t* prefered){
    if(!target_type.size){
        print_context_expr("Invalid target type", expr);
        print_type("Type ", target_type, " has a size of 0 bytes!");
        FAIL_EXPR();
    }

    size_t sz = target_type.ptr_depth ? target_address_size : target_type.size;
    bool sign = target_type.ptr_depth ? false : target_type.sign;

    // Buffer
    static reg_t* masked_regs[MAX_REGS];

    switch(expr->type){
    case tk_bool_lit:{
        reg_t* tmp = alloc_reg(prefered ? prefered : GET_FREE_REG(sz), sign);
        gen_set_reg(fptr, tmp, (*expr->term.str == 't') ? "1" : "0", 1);
        return tmp;
    }case tk_char_lit:
    case tk_int_lit:{
        reg_t* tmp = alloc_reg(prefered ? prefered : GET_FREE_REG(sz), sign);
        gen_set_reg(fptr, tmp, expr->term.str, expr->term.strlen);
        return tmp;
    }case tk_str_lit:{
        if(sz != target_address_size){
            print_context_ex("Cannot fit address into smaller type", expr->term.str, expr->term.strlen);
            FAIL_EXPR();
        }
        reg_t* tmp = alloc_reg(prefered ? prefered : GET_FREE_REG(sz), sign);
        gen_load_str(fptr, tmp, str_literal_count++);
        if(str_literal_count == 1){
            expr->next = NULL;
            str_literals = &expr->term;
        }else{
            expr->next = NULL;
            node_term* ptr = str_literals;
            for(; ptr->next; ptr = &ptr->next->term)
                ptr->next = expr;
        }
        return tmp;
    }case tk_identifier:{
        var_t* var = get_var(expr->term.str, expr->term.strlen);
        if(!var){
            print_context_ex("Unknown identifier", expr->term.str, expr->term.strlen);
            FAIL_EXPR();
        }
        type_t var_type = var->type;
        if(var_type.ptr_depth) var_type.size = target_address_size;
        reg_t* tmp = alloc_reg(prefered ? prefered : GET_FREE_REG(sz), sign);
        if(var_type.size < sz){
            if(var->location == VAR_STACK)
                gen_loadx_stack(fptr, tmp, stack_sz - var->stack_ptr, var_type.size, sign);
            else if(var->location == VAR_GLOBAL)
                gen_loadx_global(fptr, tmp, var->str, var->strlen, var_type.size, sign);
            else if(var->location == VAR_ARG)
                gen_loadx_arg(fptr, tmp, var->stack_ptr, var_type.size, sign);
            else{
                print_context_expr("Not implemented yet", expr);
                FAIL_EXPR();
            }
        }else{
            if(var->location == VAR_STACK)
                gen_load_stack(fptr, tmp, stack_sz - var->stack_ptr);
            else if(var->location == VAR_GLOBAL)
                gen_load_global(fptr, tmp, var->str, var->strlen);
            else if(var->location == VAR_ARG)
                gen_load_arg(fptr, tmp, var->stack_ptr);
            else{
                print_context_expr("Not implemented yet", expr);
                FAIL_EXPR();
            }
        }
        return tmp;
    }
#define NEG_LIKE_EXPR(n, m) \
    case n:{\
        reg_t* tmp = generate_expr(fptr, expr->unary_op.lhs, target_type, prefered ? prefered : GET_FREE_REG(sz));\
        gen_##m##_reg(fptr, tmp);\
        return tmp;\
    }
    NEG_LIKE_EXPR(tk_neg, neg)
    NEG_LIKE_EXPR(tk_bin_flip, flip)
#define INC_LIKE_EXPR(n, m) \
    case n:{\
        reg_t* tmp = generate_expr(fptr, expr->unary_op.lhs, target_type, prefered ? prefered : GET_FREE_REG(sz));\
        gen_##m##_reg(fptr, tmp);\
        if(!save_expr(fptr, expr->unary_op.lhs, tmp))\
            FAIL_EXPR();\
        return tmp;\
    }
    INC_LIKE_EXPR(tk_inc, inc)
    INC_LIKE_EXPR(tk_dec, dec)
#define POST_INC_LIKE_EXPR(n, m, l) \
    case n:{\
        reg_t* tmp = generate_expr(fptr, expr->unary_op.lhs, target_type, prefered ? prefered : GET_FREE_REG(sz));\
        gen_##m##_reg(fptr, tmp);\
        if(!save_expr(fptr, expr->unary_op.lhs, tmp))\
            FAIL_EXPR();\
        gen_##l##_reg(fptr, tmp);\
        return tmp;\
    }
    POST_INC_LIKE_EXPR(tk_post_inc, inc, dec)
    POST_INC_LIKE_EXPR(tk_post_dec, dec, inc)
#define ADD_LIKE_EXPR(n, m) \
    case n:{\
        reg_t* tmp1 = generate_expr(fptr, expr->bin_op.lhs, target_type,\
                                    (prefered && REG_IN_MASK(prefered, GET_ALLOWED_REGS1(m))) ? prefered : GET_OP_REG1(sz, m));\
        reg_t* tmp2 = generate_expr(fptr, expr->bin_op.rhs, target_type, GET_OP_REG2(sz, m));\
        gen_##m##_regs(fptr, tmp1, tmp2);\
        free_reg(tmp2);\
        return tmp1;\
    }
    ADD_LIKE_EXPR(tk_add, add)
    ADD_LIKE_EXPR(tk_sub, sub)
    ADD_LIKE_EXPR(tk_bin_or, or)
    ADD_LIKE_EXPR(tk_bin_and, and)
    ADD_LIKE_EXPR(tk_bin_xor, xor)
#define MULT_LIKE_EXPR(n, m) \
    case n:{\
        reg_mask op1 = SIGNED_OP1(sign, m), op2 = SIGNED_OP2(sign, m);\
        reg_t* tmp1 = generate_expr(fptr, expr->bin_op.lhs, target_type, (prefered && REG_IN_MASK(prefered, op1)) ? prefered : GET_MASK_REG(sz, op1));\
        reg_t* tmp2 = generate_expr(fptr, expr->bin_op.rhs, target_type, GET_MASK_REG(sz, op2));\
        if(!REG_IN_MASK(tmp1, op1)){\
            reg_t* tmp3 = GET_OCC_MASK_REG(sz, op1);\
            reg_t* tmp4 = GET_MASK_REG(sz, ALL_REGS_EXCEPT(SIGNED_AFFECTED(sign, m)));\
            transfer_reg(fptr, tmp3, tmp4);\
            transfer_reg(fptr, tmp1, tmp3);\
            (sign) ? gen_s##m##_regs(fptr, tmp3, tmp2) : gen_##m##_regs(fptr, tmp3, tmp2);\
            transfer_reg(fptr, tmp3, tmp1);\
            transfer_reg(fptr, tmp4, tmp3);\
            return tmp1;\
        }else if(!REG_IN_MASK(tmp2, op2)){\
            reg_t* tmp3 = GET_OCC_MASK_REG(sz, op2);\
            reg_t* tmp4 = GET_MASK_REG(sz, ALL_REGS_EXCEPT(SIGNED_AFFECTED(sign, m)));\
            transfer_reg(fptr, tmp3, tmp4);\
            transfer_reg(fptr, tmp2, tmp3);\
            (sign) ? gen_s##m##_regs(fptr, tmp1, tmp3) : gen_##m##_regs(fptr, tmp1, tmp3);\
            transfer_reg(fptr, tmp4, tmp3);\
            return tmp1;\
        }\
        (sign) ? gen_s##m##_regs(fptr, tmp1, tmp2) : gen_##m##_regs(fptr, tmp1, tmp2);\
        free_reg(tmp2);\
        return tmp1;\
    }
    MULT_LIKE_EXPR(tk_mult, mul)
    MULT_LIKE_EXPR(tk_div, div)
    MULT_LIKE_EXPR(tk_mod, mod)
    case tk_getaddr:{
        if(sz != target_address_size){
            print_context_expr("Cannot store address in smaller type", expr);
            print_type("Type ", target_type, " is not big enough for an address.");
            FAIL_EXPR();
        }
        reg_t* tmp = alloc_reg((prefered && prefered->size == target_address_size) ? prefered : GET_FREE_REG(target_address_size), sign);
        if(expr->unary_op.lhs->type == tk_identifier){
            var_t* var = get_var(expr->unary_op.lhs->term.str, expr->unary_op.lhs->term.strlen);
            if(!var){
                print_context_expr("Unknown identifier", expr->unary_op.lhs);
                FAIL_EXPR();
            }
            if(var->location == VAR_STACK)
                gen_load_stack_ptr(fptr, tmp, stack_sz - var->stack_ptr);
            else if(var->location == VAR_GLOBAL)
                gen_load_global_ptr(fptr, tmp, var->str, var->strlen);
            else if(var->location == VAR_ARG)
                gen_load_arg_ptr(fptr, tmp, var->stack_ptr);
            else{
                print_context_expr("Not implemented yet", expr);
                FAIL_EXPR();
            }
            return tmp;
        }else{
            print_context_expr("Unable to get address of expression", expr->unary_op.lhs);
            FAIL_EXPR();
        }
    }
    case tk_deref:{
        type_t ptr_type = typeof_expr(expr->unary_op.lhs);
        if(ptr_type.ptr_depth == 0){
            print_context_expr("Expected a pointer to dereference", expr->unary_op.lhs);
            print_type("Type ", ptr_type, " is not a pointer.");
            FAIL_EXPR();
        }
        reg_t* tmp1 = generate_expr(fptr, expr->unary_op.lhs, ptr_type, NULL);
        ptr_type.ptr_depth--;
        if(ptr_type.ptr_depth) ptr_type.size = target_address_size;
        reg_t* tmp2 = alloc_reg(prefered ? prefered : GET_FREE_REG(sz), sign);
        if(sz <= ptr_type.size)
            gen_load_ptr(fptr, tmp2, tmp1);
        else
            gen_loadx_ptr(fptr, tmp2, tmp1, ptr_type.size, sign);
        (void) free_reg(tmp1);
        return tmp2;
    }case tk_type_cast:{
        type_t cast_type = type_from_tk(expr->type_cast.lhs->start);
        if(sz == ((cast_type.ptr_depth) ? target_address_size : cast_type.size)){
            reg_t* tmp = generate_expr(fptr, expr->type_cast.rhs, cast_type, prefered);
            if(sign == ((cast_type.ptr_depth) ? false : cast_type.sign))
                tmp->occupied = (sign) ? OCCUP_SIGNED : OCCUP_UNSIGNED;
            return tmp;
        }else if(sz > ((cast_type.ptr_depth) ? target_address_size : cast_type.size)){
            reg_t* tmp1 = generate_expr(fptr, expr->type_cast.rhs, cast_type, NULL);
            reg_t* tmp2 = alloc_reg(prefered ? prefered : GET_FREE_REG(sz), sign);
            return transfer_reg(fptr, tmp1, tmp2);
        }else{
            print_context_expr("Trying to convert bigger type into smaller type", expr);
            FAIL_EXPR();
        }
    }
    }
    print_context_expr("Expression type not implemented", expr);
    FAIL_EXPR();
}
#define EXPR_ONCE(expr, type, reg) free_reg(generate_expr(fptr, (expr), (type), (reg)))

bool generate_stmt(HC_FILE fptr, node_stmt* stmt, type_t fn_type){
    // Buffer
    static reg_t* masked_regs[MAX_REGS];

    switch(stmt->type){
    case tk_var_decl:{
        // If the variable already got declared
        if(get_var(stmt->var_decl.identifier->str, stmt->var_decl.identifier->strlen)){
            print_context("Variable was already declared before", stmt->var_decl.identifier);
            var_t* var = get_var(stmt->var_decl.identifier->str, stmt->var_decl.identifier->strlen);
            print_context_ex("First declared here:", var->str, var->strlen);
            return false;
        }

        type_t var_type = type_from_tk(stmt->var_decl.var_type);

        // Save the default value
        if(stmt->var_decl.expr)
            gen_save_stack(fptr, EXPR_ONCE(stmt->var_decl.expr, var_type, NULL), stack_sz - stack_ptr);

        // Register the variable in the variable vector
        var_t new_var = {stmt->var_decl.identifier->str, stmt->var_decl.identifier->strlen, stack_ptr, VAR_STACK, var_type};
        vector_append(vars, &new_var);
        stack_ptr += var_type.ptr_depth ? target_address_size : var_type.size;
        return true;
    }case tk_assign:{
        type_t type = typeof_expr(stmt->var_assign.var);
        reg_t* val = EXPR_ONCE(stmt->var_assign.expr, type, NULL);
        return save_expr(fptr, stmt->var_assign.var, val);
    }case tk_expr_stmt:{
        // Just generate the expression with the target of a 64 bit int or a type we know
        type_t type = typeof_expr(stmt->expr.expr);
        if(!type.size)
            type = (type_t){8, GET_DUMMY_TYPE(int64), true, 0};
        EXPR_ONCE(stmt->expr.expr, type, NULL);
        return true;
    }case tk_asm:{
        // Variables
        reg_mask used_regs = 0;
        const char* str;
        size_t strlen, tmp_count = 0;
        reg_t* tmps[10];

        // Go through each masked register and add it to the used_regs mask
        for(node_term* t = stmt->asm_stmt.used_regs; t; t = &t->next->term){
            int m = 0;
            str = t->str, strlen = t->strlen;
            for(; strlen; str++, strlen--)
                m = m * 10 + (int)(*str - '0');
            used_regs |= 1 << m;
        }

        // Get all used registers and make them occupied
        int n = get_mask_regs(used_regs, registers, masked_regs);
        for(int i = 0; i < n; i++)
            (void) alloc_reg(masked_regs[i], false);

        // Go through each expression in the extra args
        for(node_expr* expr = stmt->asm_stmt.args; expr; expr = expr->next)
            tmps[tmp_count++] = generate_expr(fptr, expr, typeof_expr(expr), NULL);

        // Move the injected assembly code in the generated assembly
        str = stmt->asm_stmt.code->str + 1, strlen = stmt->asm_stmt.code->strlen - 2;
        HC_FPRINTF(fptr, "\t");
        for(; strlen; str++, strlen--){
            if(*str == '\\' && *(str+1) == 'n'){
                HC_FPRINTF(fptr, "\t\n");
                str++, strlen--;
            }else if(*str == '%'){
                int i = *(++str) - '0';
                strlen--;
                HC_FPRINTF(fptr, "%s", tmps[i]->name);
            }else
                HC_FPRINTF(fptr,"%c",*str);
        }
        HC_FPRINTF(fptr, "\n");

        // Free all the registers previously marked as occupied
        n = get_mask_regs(used_regs, registers, masked_regs);
        for(; n; n--)
            (void) free_reg(masked_regs[n-1]);

        // Free all temporaries used for the extra args
        for(; tmp_count; tmp_count--)
            (void) free_reg(tmps[tmp_count-1]);
        return true;
    }case tk_return:
        gen_save_return(fptr, EXPR_ONCE(stmt->ret.expr, fn_type, NULL));
        gen_jump(fptr, 0);
        return true;
    }
    HC_ERR("Unkown statement type %lu", stmt->type);
    return false;
}

static size_t get_scope_size(node_stmt* scope){
    size_t total = 0;
    for(; scope; scope = scope->next)
        if(scope->type == tk_var_decl)
            total += sizeof_type(scope->var_decl.var_type);
    return (total + 15) / 16 * 16;
}

static size_t gen_init_scope(HC_FILE fptr, node_stmt* scope){
    size_t sz = get_scope_size(scope);
    if(sz)
        gen_alloc_stack(fptr, sz);
    stack_sz += sz;
    return sz;
}

static void gen_quit_scope(HC_FILE fptr, size_t sz){
    if(sz)
        gen_dealloc_stack(fptr, sz);
    stack_sz -= sz;
}

bool generate(const char* output_file, node_stmt* AST){
    HC_FILE fptr = HC_FOPEN_WRITE(output_file);

    gen_setup(fptr);

    // Setup the main function
    stack_sz = stack_ptr = 0;
    label_count = 1;
    gen_start_func(fptr, "main", 4);

    // Setup the function scope
    size_t var_sz = vector_size(vars);
    size_t main_sz = gen_init_scope(fptr, AST);

    var_t return_var = {"@return", 7, 8, VAR_ARG, (type_t){8, GET_DUMMY_TYPE(int64), true, DATA_INT, 0}},
          argc = {"argc", 4, 16, VAR_ARG, (type_t){8, GET_DUMMY_TYPE(uint64), false, DATA_INT, 0}},
          argv = {"argv", 4, 32, VAR_ARG, (type_t){1, GET_DUMMY_TYPE(uint8), false, DATA_INT, 2}};
    vector_append(vars, &return_var);
    vector_append(vars, &argc);
    vector_append(vars, &argv);

    // Go through each statement
    while(AST){
        if(!generate_stmt(fptr, AST, return_var.type)){
            HC_FCLOSE(fptr);
            vector_destroy(vars);
            return false;
        }
        AST = AST->next;
    }

    // Remove the variables in the scope
    // gen_quit_scope(fptr, main_sz);
    for(size_t i = vector_size(vars); i > var_sz; i--)
        vector_popback(vars);

    // First label is dedicated to returns
    gen_label(fptr, 0);
    gen_return_func(fptr);

    // Generate the read only data section for string literals
    HC_FPRINTF(fptr, "\n\n%s", target_rodata_section);
    size_t i = 0;
    for(node_term* str_lit = str_literals; str_lit; str_lit = &str_lit->next->term, i++)
        gen_declare_str(fptr, i, str_lit->str, str_lit->strlen);

    HC_FCLOSE(fptr);
    vector_destroy(vars);
    return true;
}
