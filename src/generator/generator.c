#include "generator.h"
#include "regs.h"
#include "target_requirements.h"
#include "target_x64_Linux.h"
#include <stdalign.h>

// Global variables
size_t stack_ptr = 0;
size_t stack_sz = 0;
size_t label_count = 1;

vector_t vars[1] = { NEW_VECTOR(var_t) };
vector_t funcs[1] = { NEW_VECTOR(func_t) };

node_term* str_literals = NULL;
size_t str_literal_count = 0;

static node_term* global_var_values = NULL;

// Find a variable with its name
var_t* get_var(const char* str, size_t strlen){
    for(size_t i = 0; i < vector_size(vars); i++){
        var_t* var = vector_at(vars, i);
        if(var->strlen == strlen && strncmp(var->str, str, strlen) == 0)
            return var;
    }
    return NULL;
}

// Find a function with its name
func_t* get_func(const char* str, size_t strlen){
    for(size_t i = 0; i < vector_size(funcs); i++){
        func_t* func = vector_at(funcs, i);
        if(func->strlen == strlen && strncmp(func->str, str, strlen) == 0)
            return func;
    }
    return NULL;
}

// Get the size of a scope (the size of all variables inside)
size_t get_scope_size(node_stmt* scope){
    size_t total = 0;
    for(; scope; scope = scope->next){
        if(scope->type == tk_var_decl){
            size_t sz = sizeof_type(scope->var_decl.var_type);
            total = (total + sz - 1) / sz * sz;
            total += sz;
        }else if(scope->type == tk_arr_decl){
            size_t elem_count = 0, strlen = scope->arr_decl.elem_count->strlen;
            for(const char* str = scope->arr_decl.elem_count->str; strlen; str++, strlen--){
                if(*str < '0' || *str > '9')
                    return 0;
                elem_count = elem_count * 10 + (int)(*str - '0');
            }
            size_t sz = sizeof_type(scope->var_decl.var_type);
            total = (total + sz - 1) / sz * sz;
            total += sz * elem_count;
        }
    }
    return (total + 15) / 16 * 16;
}

// Initialise the scope and save the state before it starts
scope_t gen_init_scope(HC_FILE fptr, node_stmt* scope){
    scope_t snapshot = (scope_t){stack_sz, stack_ptr, vector_size(vars), 0};
    if(!scope)
        return snapshot;
    size_t sz = get_scope_size(scope);
    snapshot.size = sz;
    if(sz)
        gen_alloc_stack(fptr, sz);
    stack_ptr = stack_sz;
    stack_sz += sz;
    return snapshot;
}

// Quit the scope and return to the state before it started
void gen_quit_scope(HC_FILE fptr, scope_t snapshot){
    if(snapshot.stack_sz - stack_sz)
        gen_dealloc_stack(fptr, stack_sz - snapshot.stack_sz);
    stack_ptr = snapshot.stack_ptr;
    stack_sz = snapshot.stack_sz;
    for(size_t i = vector_size(vars); i > snapshot.var_sz; i--)
        vector_popback(vars);
}

// Append a string literal to the linked list of string literals
// Returns the id (index) of the string
size_t append_string_literal(node_term* str_lit){
    node_term* ptr = str_literals;
    if(str_literal_count == 0){
        str_lit->next = NULL;
        str_literals = str_lit;
    }else{
        str_lit->next = NULL;
        node_term* ptr = str_literals;
        for(; ptr->next; ptr = &ptr->next->term);
        ptr->next = (node_expr*) str_lit;
    }
    return str_literal_count++;
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
    }else if(expr->type == tk_deref){
        type_t ptr_type = typeof_expr(expr->unary_op.lhs);
        if(ptr_type.ptr_depth == 0){
            print_context_expr("Expected a pointer to dereference", expr->unary_op.lhs);
            print_type("Type ", ptr_type, " is not a pointer.");
            return false;
        }
        reg_t* tmp = generate_expr(fptr, expr->unary_op.lhs, ptr_type, NULL);
        gen_save_ptr(fptr, data, tmp);
        (void) free_reg(tmp);
        return true;
    }else if(expr->type == tk_open_bracket){
        type_t ptr_type = typeof_expr(expr->bin_op.lhs);
        if(ptr_type.ptr_depth == 0){
            print_context_expr("Expected a pointer to dereference", expr->bin_op.lhs);
            print_type("Type ", ptr_type, " is not a pointer.");
            return false;
        }
        reg_t* ptr = generate_expr(fptr, expr->bin_op.lhs, ptr_type, NULL);
        reg_t* idx = generate_expr(fptr, expr->bin_op.rhs, (type_t){8, GET_DUMMY_TYPE(uint64), false, DATA_INT, 0}, NULL);
        gen_save_idx(fptr, data, ptr, idx, ptr_type.size);
        (void) free_reg(ptr);
        (void) free_reg(idx);
        return true;
    }
    print_context_expr("Unable to save to expr", expr);
    return false;
}

extern void compiler_quit(void);
static void fail_gen_expr(HC_FILE fptr){
    HC_ERR("\nGENERATION FAILED!");
    vector_destroy(vars);
    vector_destroy(funcs);
    HC_FCLOSE(fptr);
    compiler_quit();
    HC_FAIL();
}

#define EXPR_ONCE(expr, type, reg) free_reg(generate_expr(fptr, (expr), (type), (reg)))

#define SIGNED_OP1(sign, n) ((sign) ? GET_ALLOWED_REGS1(s##n) : GET_ALLOWED_REGS1(n))
#define SIGNED_OP2(sign, n) ((sign) ? GET_ALLOWED_REGS2(s##n) : GET_ALLOWED_REGS2(n))
#define SIGNED_AFFECTED(sign, n) ((sign) ? GET_AFFECTED_REGS(s##n) : GET_AFFECTED_REGS(n))
reg_t* generate_expr(HC_FILE fptr, node_expr* expr, type_t target_type, reg_t* prefered){
    if(!target_type.data || !target_type.size){
        print_context_expr("Invalid target type", expr);
        print_type("Type ", target_type, (!target_type.data) ? " is invalid!" : " has a size of 0 bytes!");
        fail_gen_expr(fptr);
    }

    size_t sz = target_type.ptr_depth ? target_address_size : target_type.size;
    bool sign = target_type.ptr_depth ? false : target_type.sign;
    if(prefered && !is_reg_free(prefered)) prefered = NULL;

    // Buffer
    static reg_t* masked_regs[MAX_REGS];

    switch(expr->type){
    case tk_bool_lit:{
        reg_t* tmp = alloc_reg(prefered ? prefered : GET_FREE_REG(sz), sign);
        gen_set_reg(fptr, tmp, (*expr->term.str == 't') ? "1" : "0", 1);
        return tmp;
    }case tk_char_lit:{
        reg_t* tmp = alloc_reg(prefered ? prefered : GET_FREE_REG(sz), sign);
        if(expr->term.strlen == 4){
            if(strncmp(expr->term.str, "'\n'", 4))
                gen_set_reg(fptr, tmp, "10", 2);
            else if(strncmp(expr->term.str, "'\t'", 4))
                gen_set_reg(fptr, tmp, "9", 1);
            else if(strncmp(expr->term.str, "'\0", 4))
                gen_set_reg(fptr, tmp, "0", 1);
            else
                gen_set_reg(fptr, tmp, expr->term.str, 4);
        }else
            gen_set_reg(fptr, tmp, expr->term.str, expr->term.strlen);
        return tmp;
    }case tk_int_lit:{
        reg_t* tmp = alloc_reg(prefered ? prefered : GET_FREE_REG(sz), sign);
        gen_set_reg(fptr, tmp, expr->term.str, expr->term.strlen);
        return tmp;
    }case tk_str_lit:{
        if(sz != target_address_size){
            print_context_ex("Cannot fit address into type with different size", expr->term.str, expr->term.strlen);
            print_type("Type ", target_type, " is not the right size");
            fail_gen_expr(fptr);
        }
        reg_t* tmp = alloc_reg(prefered ? prefered : GET_FREE_REG(sz), sign);
        gen_load_str(fptr, tmp, append_string_literal(&expr->term));
        return tmp;
    }case tk_identifier:{
        var_t* var = get_var(expr->term.str, expr->term.strlen);
        if(!var){
            print_context_ex("Unknown identifier", expr->term.str, expr->term.strlen);
            fail_gen_expr(fptr);
        }
        type_t var_type = var->type;
        if(var_type.ptr_depth || var->location == VAR_ARRAY || var->location == VAR_GLOBAL_ARR)
            var_type.size = target_address_size;
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
                fail_gen_expr(fptr);
            }
        }else{
            if(var->location == VAR_STACK)
                gen_load_stack(fptr, tmp, stack_sz - var->stack_ptr);
            else if(var->location == VAR_GLOBAL)
                gen_load_global(fptr, tmp, var->str, var->strlen);
            else if(var->location == VAR_ARG)
                gen_load_arg(fptr, tmp, var->stack_ptr);
            else if((var->location == VAR_ARRAY || var->location == VAR_GLOBAL_ARR) && sz != target_address_size){
                print_context_expr("Cannot fit address into type of different size", expr);
                print_type("Type ", target_type, " is not the right size");
                fail_gen_expr(fptr);
            }else if(var->location == VAR_ARRAY)
                gen_load_stack_ptr(fptr, tmp, stack_sz - var->stack_ptr);
            else if(var->location == VAR_GLOBAL_ARR)
                gen_load_global_ptr(fptr, tmp, var->str, var->strlen);
            else{
                print_context_expr("Not implemented yet", expr);
                fail_gen_expr(fptr);
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
            fail_gen_expr(fptr);\
        return tmp;\
    }
    INC_LIKE_EXPR(tk_inc, inc)
    INC_LIKE_EXPR(tk_dec, dec)
#define POST_INC_LIKE_EXPR(n, m, l) \
    case n:{\
        reg_t* tmp = generate_expr(fptr, expr->unary_op.lhs, target_type, prefered ? prefered : GET_FREE_REG(sz));\
        gen_##m##_reg(fptr, tmp);\
        if(!save_expr(fptr, expr->unary_op.lhs, tmp))\
            fail_gen_expr(fptr);\
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
        reg_mask op1 = SIGNED_OP1(sign, m), op2 = SIGNED_OP2(sign, m), affected = SIGNED_AFFECTED(sign, m);\
        reg_t* tmp1 = generate_expr(fptr, expr->bin_op.lhs, target_type, (prefered && REG_IN_MASK(prefered, op1)) ? prefered : GET_MASK_REG(sz, op1));\
        reg_t* tmp2 = generate_expr(fptr, expr->bin_op.rhs, target_type, GET_MASK_REG(sz, op2));\
        reg_t* replacements[MAX_REGS];/*v*/\
        int n = get_mask_occup_regs(affected, true, registers, masked_regs);\
        for(int i = 0; i < n; i++)\
            replacements[i] = transfer_reg(fptr, masked_regs[i], GET_MASK_REG(masked_regs[i]->size, ALL_REGS_EXCEPT(affected))); /*^*/\
        if(!REG_IN_MASK(tmp1, op1)){\
            reg_t* tmp3 = GET_OCC_MASK_REG(sz, op1);\
            reg_t* tmp4 = GET_MASK_REG(sz, ALL_REGS_EXCEPT(affected));\
            transfer_reg(fptr, tmp3, tmp4);\
            transfer_reg(fptr, tmp1, tmp3);\
            (sign) ? gen_s##m##_regs(fptr, tmp3, tmp2) : gen_##m##_regs(fptr, tmp3, tmp2);\
            transfer_reg(fptr, tmp3, tmp1);\
            transfer_reg(fptr, tmp4, tmp3);\
            for(int i = 0; i < n; i++)/**/\
                (void) transfer_reg(fptr, replacements[i], masked_regs[i]);\
            return tmp1;\
        }else if(!REG_IN_MASK(tmp2, op2)){\
            reg_t* tmp3 = GET_OCC_MASK_REG(sz, op2);\
            reg_t* tmp4 = GET_MASK_REG(sz, ALL_REGS_EXCEPT(SIGNED_AFFECTED(sign, m)));\
            transfer_reg(fptr, tmp3, tmp4);\
            transfer_reg(fptr, tmp2, tmp3);\
            (sign) ? gen_s##m##_regs(fptr, tmp1, tmp3) : gen_##m##_regs(fptr, tmp1, tmp3);\
            transfer_reg(fptr, tmp4, tmp3);\
            for(int i = 0; i < n; i++)/**/\
                (void) transfer_reg(fptr, replacements[i], masked_regs[i]);\
            return tmp1;\
        }\
        (sign) ? gen_s##m##_regs(fptr, tmp1, tmp2) : gen_##m##_regs(fptr, tmp1, tmp2);\
        free_reg(tmp2);\
        for(int i = 0; i < n; i++)/**/\
            (void) transfer_reg(fptr, replacements[i], masked_regs[i]);\
        return tmp1;\
    }
    MULT_LIKE_EXPR(tk_mult, mul)
    MULT_LIKE_EXPR(tk_div, div)
    MULT_LIKE_EXPR(tk_mod, mod)
    case tk_not:{
        reg_t* tmp1 = generate_expr(fptr, expr->unary_op.lhs, typeof_expr(expr->unary_op.lhs), NULL);
        gen_cmpz_reg(fptr, tmp1);
        reg_t* tmp2 = alloc_reg(GET_FREE_REG(1), sign);
        gen_cond_set(fptr, tk_cmp_eq, tmp2, false);
        (void) free_reg(tmp1);
        if(sz != 1)
            tmp2 = transfer_reg(fptr, tmp2, prefered ? prefered : GET_FREE_REG(sz));
        return tmp2;
    }
    case tk_and:
    case tk_or:{
        size_t skip_label = label_count++;
        type_t t = typeof_expr(expr->bin_op.lhs);
        reg_t* tmp1 = generate_expr(fptr, expr->bin_op.lhs, t, NULL);
        if(!t.repr || t.repr->type != tk_bool){
            reg_t* tmp2 = alloc_reg(GET_FREE_REG(1), sign);
            gen_cmpz_reg(fptr, tmp1);
            gen_cond_set(fptr, tk_cmp_neq, tmp2, false);
            if(expr->type == tk_and)
                gen_cond_jump(fptr, tk_cmp_eq, skip_label, false);
            else
                gen_cond_jump(fptr, tk_cmp_neq, skip_label, false);
            free_reg(tmp1);
            tmp1 = tmp2;
        }else{
            gen_cmpz_reg(fptr, tmp1);
            if(expr->type == tk_and)
                gen_cond_jump(fptr, tk_cmp_eq, skip_label, false);
            else
                gen_cond_jump(fptr, tk_cmp_neq, skip_label, false);
        }
        t = typeof_expr(expr->bin_op.rhs);
        reg_t* tmp2 = generate_expr(fptr, expr->bin_op.rhs, t, NULL);
        if(!t.repr || t.repr->type != tk_bool){
            reg_t* tmp3 = alloc_reg(GET_FREE_REG(1), sign);
            gen_cmpz_reg(fptr, tmp2);
            gen_cond_set(fptr, tk_cmp_neq, tmp3, false);
            free_reg(tmp2);
            tmp2 = tmp3;
        }
        if(expr->type == tk_and)
            gen_and_regs(fptr, tmp1, tmp2);
        else
            gen_or_regs(fptr, tmp1, tmp2);
        gen_label(fptr, skip_label);
        (void) free_reg(tmp2);
        if(sz != 1)
            tmp1 = transfer_reg(fptr, tmp1, (prefered && is_reg_free(prefered)) ? prefered : GET_FREE_REG(sz));
        return tmp1;
    }
    case tk_cmp_eq:
    case tk_cmp_neq:
    case tk_cmp_g:
    case tk_cmp_ge:
    case tk_cmp_l:
    case tk_cmp_le:{
        type_t t1 = typeof_expr(expr->bin_op.lhs), t2 = typeof_expr(expr->bin_op.rhs);
        if(!t1.data || !t2.data || t1.data != t2.data){
            print_context_expr("Cannot compare two values of incompatible types", expr);
            fail_gen_expr(fptr);
        }
        type_t biggest_t = (t1.size > t2.size) ? t1 : t2;
        reg_t *lhs = generate_expr(fptr, expr->bin_op.lhs, biggest_t, NULL), *rhs = generate_expr(fptr, expr->bin_op.rhs, biggest_t, NULL);
        gen_compare(fptr, lhs, rhs);
        (void) free_reg(lhs);
        (void) free_reg(rhs);
        reg_t* tmp = alloc_reg(GET_FREE_REG(1), sign);
        gen_cond_set(fptr, expr->type, tmp, t1.sign | t2.sign);
        if(sz != 1)
            tmp = transfer_reg(fptr, tmp, (prefered && is_reg_free(prefered)) ? prefered : GET_FREE_REG(sz));
        return tmp;
    }
    case tk_getaddr:{
        if(sz != target_address_size){
            print_context_expr("Cannot store address in smaller type", expr);
            print_type("Type ", target_type, " is not big enough for an address.");
            fail_gen_expr(fptr);
        }
        reg_t* tmp = alloc_reg(prefered ? prefered : GET_FREE_REG(target_address_size), sign);
        if(expr->unary_op.lhs->type == tk_identifier){
            var_t* var = get_var(expr->unary_op.lhs->term.str, expr->unary_op.lhs->term.strlen);
            if(!var){
                print_context_expr("Unknown identifier", expr->unary_op.lhs);
                fail_gen_expr(fptr);
            }
            if(var->location == VAR_STACK)
                gen_load_stack_ptr(fptr, tmp, stack_sz - var->stack_ptr);
            else if(var->location == VAR_GLOBAL)
                gen_load_global_ptr(fptr, tmp, var->str, var->strlen);
            else if(var->location == VAR_ARG)
                gen_load_arg_ptr(fptr, tmp, var->stack_ptr);
            else if(var->location == VAR_ARRAY || var->location == VAR_GLOBAL_ARR){
                print_context_expr("Cannot get address to an array, use intermediate pointer variable instead", expr);
                fail_gen_expr(fptr);
            }else{
                print_context_expr("Not implemented yet", expr);
                fail_gen_expr(fptr);
            }
            return tmp;
        }else if(expr->unary_op.lhs->type == tk_open_bracket){
            type_t ptr_type = typeof_expr(expr->unary_op.lhs);
            ptr_type.ptr_depth++;
            reg_t* ptr = generate_expr(fptr, expr->unary_op.lhs->bin_op.lhs, ptr_type, NULL);
            reg_t* idx = generate_expr(fptr, expr->unary_op.lhs->bin_op.rhs, (type_t){8, GET_DUMMY_TYPE(uint64), false, DATA_INT, 0}, NULL);
            gen_load_idx_ptr(fptr, tmp, ptr, idx, ptr_type.size);
            (void) free_reg(ptr);
            (void) free_reg(idx);
            return tmp;
        }else{
            print_context_expr("Unable to get address of expression", expr->unary_op.lhs);
            fail_gen_expr(fptr);
        }
    }
    case tk_deref:{
        type_t ptr_type = typeof_expr(expr->unary_op.lhs);
        if(ptr_type.ptr_depth == 0){
            print_context_expr("Expected a pointer to dereference", expr->unary_op.lhs);
            print_type("Type ", ptr_type, " is not a pointer.");
            fail_gen_expr(fptr);
        }
        reg_t* val = alloc_reg(prefered, sign);
        reg_t* ptr = generate_expr(fptr, expr->unary_op.lhs, ptr_type, NULL);
        if(!val) val = alloc_reg(GET_FREE_REG(sz), sign);
        ptr_type.ptr_depth--;
        if(ptr_type.ptr_depth) ptr_type.size = target_address_size;
        if(sz <= ptr_type.size)
            gen_load_ptr(fptr, val, ptr);
        else
            gen_loadx_ptr(fptr, val, ptr, ptr_type.size, sign);
        (void) free_reg(ptr);
        return val;
    }
    case tk_open_bracket:{
        type_t ptr_type = typeof_expr(expr->bin_op.lhs);
        if(ptr_type.ptr_depth == 0){
            print_context_expr("Expected a pointer to index", expr->bin_op.lhs);
            print_type("Type ", ptr_type, " is not a pointer.");
            fail_gen_expr(fptr);
        }
        reg_t* elem = alloc_reg(prefered, sign);
        reg_t* ptr = generate_expr(fptr, expr->bin_op.lhs, ptr_type, NULL);
        reg_t* idx = generate_expr(fptr, expr->bin_op.rhs, (type_t){8, GET_DUMMY_TYPE(uint64), false, DATA_INT, 0}, NULL);
        ptr_type.ptr_depth--;
        if(ptr_type.ptr_depth) ptr_type.size = target_address_size;
        if(!elem) elem = alloc_reg(GET_FREE_REG(sz), sign);
        if(sz <= ptr_type.size)
            gen_load_idx(fptr, elem, ptr, idx, ptr_type.size);
        else
            gen_loadx_idx(fptr, elem, ptr, idx, ptr_type.size, sign);
        (void) free_reg(ptr);
        (void) free_reg(idx);
        return elem;
    }
    case tk_type_cast:{
        type_t cast_type = type_from_tk(expr->type_cast.lhs->start);
        if(sz == ((cast_type.ptr_depth) ? target_address_size : cast_type.size)){
            reg_t* tmp = generate_expr(fptr, expr->type_cast.rhs, cast_type, prefered);
            if(sign == ((cast_type.ptr_depth) ? false : cast_type.sign))
                tmp->occupied = (sign) ? OCCUP_SIGNED : OCCUP_UNSIGNED;
            return tmp;
        }else if(sz > ((cast_type.ptr_depth) ? target_address_size : cast_type.size)){
            reg_t* tmp2 = alloc_reg(prefered, sign);
            reg_t* tmp1 = generate_expr(fptr, expr->type_cast.rhs, cast_type, NULL);
            if(!tmp2) tmp2 = alloc_reg(GET_FREE_REG(sz), sign);
            return transfer_reg(fptr, tmp1, tmp2);
        }else{
            print_context_expr("Trying to convert bigger type into smaller type", expr);
            fail_gen_expr(fptr);
        }
    }
    case tk_func_call:{
        // Get the function
        func_t* func = get_func(expr->func.identifier->str, expr->func.identifier->strlen);
        if(!func){
            print_context_expr("Unknown function", expr);
            fail_gen_expr(fptr);
        }

        // The amount of bytes allocated on the stack
        size_t func_call_sz = (func->type.ptr_depth) ? target_address_size : func->type.size;

        // Get the occupied registers to save on the stack
        // (because a function can affect registers)
        int n = get_mask_occup_regs(ALL_REGS, true, registers, masked_regs);
        for(int i = 0; i < n; i++){
            func_call_sz = (func_call_sz + masked_regs[i]->size - 1) / masked_regs[i]->size * masked_regs[i]->size;
            func_call_sz += masked_regs[i]->size;
        }

        // Get the size of all arguments + return value
        for(node_var_decl* arg = &func->args->var_decl; arg; arg = &arg->next->var_decl){
            type_t arg_type = type_from_tk(arg->var_type);
            size_t arg_size = (arg_type.ptr_depth) ? target_address_size : arg_type.size;
            func_call_sz = (func_call_sz + arg_size - 1) / arg_size * arg_size;
            func_call_sz += arg_size;
        }

        // Allocate the stack space for everything
        func_call_sz = (func_call_sz + 15) / 16 * 16;
        if(func_call_sz)
            gen_alloc_stack(fptr, func_call_sz);
        stack_sz += func_call_sz;

        // Save each occupied register on the stack
        size_t arg_ptr = 0;
        for(int i = 0; i < n; i++){
            arg_ptr = (arg_ptr + masked_regs[i]->size - 1) / masked_regs[i]->size * masked_regs[i]->size;
            arg_ptr += masked_regs[i]->size;
            gen_save_stack(fptr, masked_regs[i], func_call_sz - arg_ptr);
        }

        // Generate each argument
        arg_ptr = (func->type.ptr_depth) ? target_address_size : func->type.size;
        node_expr* arg_expr = expr->func.args;
        for(node_var_decl* arg = &func->args->var_decl; arg; arg = &arg->next->var_decl){
            node_expr* next_arg = NULL;
            if(!arg_expr || arg_expr->type == tk_nothing){
                if(!arg->expr){
                    print_context("In function call here", expr->func.identifier);
                    print_context("Missing argument and no default value", arg->identifier);
                    fail_gen_expr(fptr);
                }
                arg_expr = arg->expr;
            }
            if(arg_expr)
                next_arg = arg_expr->next;

            type_t expr_type = typeof_expr(arg_expr), arg_type = type_from_tk(arg->var_type);
            size_t arg_size = (arg_type.ptr_depth) ? target_address_size : arg_type.size;

            // If the argument isn't compatible
            if(expr_type.data != arg_type.data || expr_type.ptr_depth != arg_type.ptr_depth){
                print_context_expr("Incompatible argument type", arg_expr);
                print_context("Expected argument type", arg->var_type);
                print_type("Type ", expr_type, " is not compatible!");
                fail_gen_expr(fptr);
            }

            reg_t* tmp = EXPR_ONCE(arg_expr, arg_type, NULL);
            arg_ptr = (arg_ptr + arg_size - 1) / arg_size * arg_size;
            gen_save_stack(fptr, tmp, arg_ptr);
            arg_ptr += arg_size;

            arg_expr = next_arg;
        }

        if(arg_expr){
            print_context_expr("Too many arguments provided", arg_expr);
            fail_gen_expr(fptr);
        }

        // Call the function
        gen_call_func(fptr, func->str, func->strlen);

        // Retrieve every register off the stack
        arg_ptr = 0;
        n = get_mask_occup_regs(ALL_REGS, true, registers, masked_regs);
        for(int i = 0; i < n; i++){
            arg_ptr = (arg_ptr + masked_regs[i]->size - 1) / masked_regs[i]->size * masked_regs[i]->size;
            arg_ptr += masked_regs[i]->size;
            gen_load_stack(fptr, masked_regs[i], func_call_sz - arg_ptr);
        }

        // Get the return value or 0 if it doesnt return anything
        reg_t* tmp = alloc_reg(prefered ? prefered : GET_FREE_REG(sz), sign);
        if((func->type.ptr_depth) ? true : func->type.size)
            gen_load_stack(fptr, tmp, 0);
        else
            gen_set_reg(fptr, tmp, "0", 1);

        // Deallocate the stack space of the function
        if(func_call_sz)
            gen_dealloc_stack(fptr, func_call_sz);
        stack_sz -= func_call_sz;
        return tmp;
    }
    case tk_stack_alloc:{
        if(sz != target_address_size){
            print_context_expr("Cannot store address in smaller type", expr);
            print_type("Type ", target_type, " is not big enough for an address.");
            fail_gen_expr(fptr);
        }
        type_t elem_type = type_from_tk(expr->salloc.elem_type);
        size_t elem_count = 0, strlen = expr->salloc.elem_count->strlen;
        for(const char* str = expr->salloc.elem_count->str; strlen; str++, strlen--){
            if(*str < '0' || *str > '9'){
                print_context_ex("Expected base 10 integer literal", str, strlen);
                fail_gen_expr(fptr);
            }
            elem_count = elem_count * 10 + (int)(*str - '0');
        }
        size_t alloc_sz = ((elem_type.ptr_depth) ? target_address_size : elem_type.size) * elem_count;
        alloc_sz = (alloc_sz + 15) / 16 * 16;
        gen_alloc_stack(fptr, alloc_sz);
        stack_sz += alloc_sz;
        reg_t* tmp = alloc_reg(prefered ? prefered : GET_FREE_REG(sz), sign);
        gen_load_stack_ptr(fptr, tmp, 0);
        return tmp;
    }
    }
    print_context_expr("Expression type not implemented", expr);
    fail_gen_expr(fptr);
    return NULL;
}

bool generate_stmt(HC_FILE fptr, node_stmt* stmt, type_t fn_type){
    if(!fn_type.data && stmt->type != tk_func_decl && stmt->type != tk_var_decl && stmt->type != tk_arr_decl){
        HC_PRINT(BOLD "Sadly I can't tell you where the error is, but here is the invalid statement's type: %lu :(" RESET_ATTR "\n", stmt->type);
        HC_ERR("Cannot do more than declaring functions, variables or arrays outside a function!");
        return false;
    }

    switch(stmt->type){
    case tk_func_decl:{
        if(fn_type.data){
            print_context("Cannot declare function in another", stmt->func_decl.func_type);
            return false;
        }

        // Check for last definition
        func_t* last_def = get_func(stmt->func_decl.identifier->str, stmt->func_decl.identifier->strlen);

        // Registrate the function
        func_t func = (func_t){
            stmt->func_decl.identifier->str,
            stmt->func_decl.identifier->strlen,
            stmt->func_decl.args,
            stmt->func_decl.stmts,
            type_from_tk(stmt->func_decl.func_type)
        };

        if(last_def){
            if(func.stmts && last_def->stmts){
                print_context_ex("Redefining function here", func.str, func.strlen);
                print_context_ex("First defined here", last_def->str, last_def->strlen);
                return false;
            }
            bool same = (func.type.size == last_def->type.size && func.type.sign == last_def->type.sign &&
                        func.type.ptr_depth == last_def->type.ptr_depth && func.type.data == last_def->type.data);
            node_var_decl* last_arg = &last_def->args->var_decl;
            for(node_var_decl* arg = &func.args->var_decl; same && arg; arg = &arg->next->var_decl, last_arg = &last_arg->next->var_decl){
                type_t t1 = type_from_tk(arg->var_type), t2 = type_from_tk(last_arg->var_type);
                if(!last_arg || t1.size != t2.size || t1.sign != t2.sign || t1.ptr_depth != t2.ptr_depth || t1.data != t2.data)
                    same = false;
                if(last_arg->expr && !arg->expr)
                    arg->expr = last_arg->expr;
            }
            if(last_arg || !same){
                print_context_ex("Function does not match previous definition", func.str, func.strlen);
                print_context_ex("Previously defined here", last_def->str, last_def->strlen);
                return false;
            }
            if(func.stmts && !last_def->stmts)
                *last_def = func;
        }else
            vector_append(funcs, &func);

        if(!stmt->func_decl.stmts)
            return true;
        else if(stmt->func_decl.stmts == (node_stmt*)(~0)){
            gen_start_func(fptr, stmt->func_decl.identifier->str, stmt->func_decl.identifier->strlen, false);
            gen_return_func(fptr);
            return true;
        }

        print_context("Func def here", stmt->func_decl.identifier);

        // Setup the function
        stack_sz = stack_ptr = 0;
        label_count = 1;
        gen_start_func(fptr, stmt->func_decl.identifier->str, stmt->func_decl.identifier->strlen, false);

        // Setup the function scope
        size_t arg_ptr = 0;
        scope_t func_scope = gen_init_scope(fptr, stmt->func_decl.stmts);

        // @return variable in the function scope
        arg_ptr += (func.type.ptr_depth) ? target_address_size : func.type.size;
        var_t return_var = {"@return", 7, 0,
                            VAR_ARG, func.type};
        vector_append(vars, &return_var);

        // Add arguments as variables
        for(node_var_decl* arg = &func.args->var_decl; arg; arg = &arg->next->var_decl){
            type_t arg_type = type_from_tk(arg->var_type);
            if(arg->expr){
                type_t default_type = typeof_expr(arg->expr);
                if(!default_type.data || default_type.data != arg_type.data || default_type.ptr_depth != arg_type.ptr_depth){
                    if(default_type.data)
                        print_context_expr("Default value has incompatible type", arg->expr);
                    return false;
                }
            }
            size_t arg_size = (arg_type.ptr_depth) ? target_address_size : arg_type.size;
            arg_ptr = (arg_ptr + arg_size - 1) / arg_size * arg_size;
            var_t arg_var = {arg->identifier->str, arg->identifier->strlen, arg_ptr, VAR_ARG, arg_type};
            arg_ptr += arg_size;
            vector_append(vars, &arg_var);
        }

        // Go through each statement
        for(node_stmt* ptr = stmt->func_decl.stmts; ptr; ptr = ptr->next){
            if(!generate_stmt(fptr, ptr, func.type))
                return false;
        }

        // Remove the variables in the scope
        for(size_t i = vector_size(vars); i > func_scope.var_sz; i--)
            vector_popback(vars);

        // First label is dedicated to returns
        gen_label(fptr, 0);
        //gen_quit_scope(fptr, func_sz);
        gen_return_func(fptr);



        return true;
    }
    case tk_if:{
        // Allocate labels
        size_t other_label = label_count++, end_label = label_count++;

        // Generate condition
        reg_t* cond = EXPR_ONCE(stmt->if_stmt.cond, typeof_expr(stmt->if_stmt.cond), NULL);
        gen_cmpz_reg(fptr, cond);
        gen_cond_jump(fptr, tk_cmp_eq, other_label, false);

        // Go through the if's scope if its condition is true
        scope_t scope = gen_init_scope(fptr, stmt->if_stmt.stmts);
        for(node_stmt* ptr = stmt->if_stmt.stmts; ptr; ptr = ptr->next){
            if(!generate_stmt(fptr, ptr, fn_type))
                return false;
        }

        // Quit the scope and jump to the end
        gen_quit_scope(fptr, scope);
        gen_jump(fptr, end_label);

        // The "other" label is a label that precedes the next statement
        // in a if -> else if ... -> else chain
        gen_label(fptr, other_label);

        // Go through each next else if / else statement
        node_stmt* if_stmt = stmt;
        while(stmt->next && (stmt->next->type == tk_else_if || stmt->next->type == tk_else)){
            // Skip over the statement
            stmt = stmt->next;
            if_stmt->next = stmt->next;

            // Generate it
            if(stmt->type == tk_else_if){
                other_label = label_count++;

                // Generate the alternate condition
                cond = EXPR_ONCE(stmt->if_stmt.cond, typeof_expr(stmt->if_stmt.cond), NULL);
                gen_cmpz_reg(fptr, cond);
                gen_cond_jump(fptr, tk_cmp_eq, other_label, false);

                // Go through the else if's scopes
                scope_t else_if_scope = gen_init_scope(fptr, stmt->if_stmt.stmts);
                for(node_stmt* ptr = stmt->if_stmt.stmts; ptr; ptr = ptr->next){
                    if(!generate_stmt(fptr, ptr, fn_type))
                        return false;
                }

                // Quit the scope
                gen_quit_scope(fptr, else_if_scope);
                gen_jump(fptr, end_label);

                gen_label(fptr, other_label);
            }else{
                // Just go through the else's scope
                scope_t else_scope = gen_init_scope(fptr, stmt->scope.stmts);
                for(node_stmt* ptr = stmt->scope.stmts; ptr; ptr = ptr->next){
                    if(!generate_stmt(fptr, ptr, fn_type))
                        return false;
                }
                gen_quit_scope(fptr, else_scope);
                // The else ends the chain
                break;
            }
        }

        // The end of the if statement chain
        gen_label(fptr, end_label);

        return true;
    }
    // If we stumble upon else if / else without an if behind it
    case tk_else_if:
    case tk_else:{
        if(stmt->type == tk_else_if)
            print_context_expr("Missing if statement before else if", stmt->if_stmt.cond);
        else
            print_context("Missing if statement before else in function", fn_type.repr);
        return false;
    }
    // Basic scope: { ... }
    case tk_open_braces:{
        scope_t scope = gen_init_scope(fptr, stmt->scope.stmts);

        for(node_stmt* ptr = stmt->scope.stmts; ptr; ptr = ptr->next){
            if(!generate_stmt(fptr, ptr, fn_type))
                return false;
        }

        gen_quit_scope(fptr, scope);
        return true;
    }
    case tk_while:{
        size_t start_label = label_count++, end_label= label_count++;

        // Start the loop
        scope_t while_scope = gen_init_scope(fptr, stmt->while_stmt.stmts);
        gen_label(fptr, start_label);

        // Check the condition
        reg_t* cond = EXPR_ONCE(stmt->while_stmt.cond, typeof_expr(stmt->while_stmt.cond), NULL);
        gen_cmpz_reg(fptr, cond);
        gen_cond_jump(fptr, tk_cmp_eq, end_label, false);

        // Generate the scope
        for(node_stmt* ptr = stmt->while_stmt.stmts; ptr; ptr = ptr->next){
            if(!generate_stmt(fptr, ptr, fn_type))
                return false;
        }

        // When the loop continues
        if(stack_sz > while_scope.stack_sz + while_scope.size)
            gen_dealloc_stack(fptr, stack_sz - (while_scope.stack_sz + while_scope.size));
        gen_jump(fptr, start_label);

        // When the loop ends
        gen_label(fptr, end_label);
        gen_quit_scope(fptr, while_scope);
        return true;
    }
    case tk_repeat:{
        size_t start_label = label_count++, end_label = label_count++;

        // Start the loop
        reg_t* cond = generate_expr(fptr, stmt->repeat_stmt.cond, typeof_expr(stmt->repeat_stmt.cond), NULL);
        scope_t repeat_scope = gen_init_scope(fptr, stmt->repeat_stmt.stmts);
        gen_label(fptr, start_label);

        // Check the condition
        gen_cmpz_reg(fptr, cond);
        gen_cond_jump(fptr, tk_cmp_eq, end_label, false);

        // Generate the scope
        for(node_stmt* ptr = stmt->repeat_stmt.stmts; ptr; ptr = ptr->next){
            if(!generate_stmt(fptr, ptr, fn_type))
                return false;
        }

        // When the loop continues
        if(stack_sz > repeat_scope.stack_sz + repeat_scope.size)
            gen_dealloc_stack(fptr, stack_sz - (repeat_scope.stack_sz + repeat_scope.size));
        gen_dec_reg(fptr, cond);
        gen_jump(fptr, start_label);

        // When the loop ends
        gen_label(fptr, end_label);
        gen_quit_scope(fptr, repeat_scope);
        return true;
    }
    case tk_for:{
        size_t start_label = label_count++, end_label= label_count++;

        // Start the loop
        scope_t for_scope;
        if(stmt->for_stmt.init){
            node_stmt* last_init = (node_stmt*) stmt->for_stmt.init;
            for(; last_init->next; last_init = last_init->next);
            last_init->next = stmt->for_stmt.stmts;
            for_scope = gen_init_scope(fptr, (node_stmt*) stmt->for_stmt.init);
            for(; (node_stmt*) stmt->for_stmt.init != stmt->for_stmt.stmts; stmt->for_stmt.init = &stmt->for_stmt.init->next->var_decl)
                generate_stmt(fptr, (node_stmt*) stmt->for_stmt.init, fn_type);
        }else
            for_scope = gen_init_scope(fptr, stmt->for_stmt.stmts);
        gen_label(fptr, start_label);

        // Check the condition
        reg_t* cond = EXPR_ONCE(stmt->for_stmt.cond, typeof_expr(stmt->for_stmt.cond), NULL);
        gen_cmpz_reg(fptr, cond);
        gen_cond_jump(fptr, tk_cmp_eq, end_label, false);

        // Generate the scope
        for(node_stmt* ptr = stmt->for_stmt.stmts; ptr; ptr = ptr->next){
            if(!generate_stmt(fptr, ptr, fn_type))
                return false;
        }

        // Step
        for(node_stmt* ptr = stmt->for_stmt.step; ptr; ptr = ptr->next){
            if(!generate_stmt(fptr, ptr, fn_type))
                return false;
        }

        // When the loop continues
        if(stack_sz > for_scope.stack_sz + for_scope.size)
            gen_dealloc_stack(fptr, stack_sz - (for_scope.stack_sz + for_scope.size));
        gen_jump(fptr, start_label);

        // When the loop ends
        gen_label(fptr, end_label);
        gen_quit_scope(fptr, for_scope);
        return true;
    }
    case tk_var_decl:{
        // If the variable already got declared
        if(get_var(stmt->var_decl.identifier->str, stmt->var_decl.identifier->strlen)){
            print_context("Variable was already declared before", stmt->var_decl.identifier);
            var_t* var = get_var(stmt->var_decl.identifier->str, stmt->var_decl.identifier->strlen);
            print_context_ex("First declared here:", var->str, var->strlen);
            return false;
        }

        type_t var_type = type_from_tk(stmt->var_decl.var_type);
        size_t var_sz = (var_type.ptr_depth) ? target_address_size : var_type.size;

        if(fn_type.data){
            // Stack variables
            stack_ptr = (stack_ptr + var_sz - 1) / var_sz * var_sz;
            stack_ptr += (var_type.ptr_depth) ? target_address_size : var_type.size;
            size_t var_ptr = stack_ptr;

            // Save the default value
            if(stmt->var_decl.expr){
                reg_t* tmp = EXPR_ONCE(stmt->var_decl.expr, var_type, NULL);

                gen_save_stack(fptr, tmp, stack_sz - var_ptr);
            }

            // Register the variable in the variable vector
            var_t new_var = {stmt->var_decl.identifier->str, stmt->var_decl.identifier->strlen, var_ptr, VAR_STACK, var_type};
            vector_append(vars, &new_var);
        }else{
            // Global variables
            if(stmt->var_decl.expr && (stmt->var_decl.expr->type == tk_int_lit ||
               stmt->var_decl.expr->type == tk_char_lit || stmt->var_decl.expr->type == tk_str_lit ||
               stmt->var_decl.expr->type == tk_bool_lit)){
                node_term* last_lit = global_var_values;
                stmt->var_decl.expr->term.next = NULL;
                if(!last_lit)
                    global_var_values = &stmt->var_decl.expr->term;
                else{
                    for(; last_lit->next; last_lit = &last_lit->next->term);
                    last_lit->next = stmt->var_decl.expr;
                }
            }else if(stmt->var_decl.expr){
                print_context_expr("Non constant value assigned to global variable (initialise it in a function)", stmt->var_decl.expr);
                return false;
            }

            // Register the variable in the variable vector
            var_t new_var = {stmt->var_decl.identifier->str, stmt->var_decl.identifier->strlen, (stmt->var_decl.expr != 0), VAR_GLOBAL, var_type};
            vector_append(vars, &new_var);
        }
        return true;
    }
    case tk_arr_decl:{
        // If the variable already got declared
        if(get_var(stmt->arr_decl.identifier->str, stmt->arr_decl.identifier->strlen)){
            print_context("Variable was already declared before", stmt->arr_decl.identifier);
            var_t* var = get_var(stmt->arr_decl.identifier->str, stmt->arr_decl.identifier->strlen);
            print_context_ex("First declared here:", var->str, var->strlen);
            return false;
        }

        type_t var_type = type_from_tk(stmt->arr_decl.elem_type);

        // Get the number of elements in the array
        size_t elem_count = 0, strlen = stmt->arr_decl.elem_count->strlen;
        for(const char* str = stmt->arr_decl.elem_count->str; strlen; str++, strlen--){
            if(*str < '0' || *str > '9'){
                print_context_ex("Expected base 10 integer literal", str, strlen);
                return false;
            }
            elem_count = elem_count * 10 + (int)(*str - '0');
        }

        // Get the size of the array and adjust the pointer depth of the var's type
        size_t elem_size = (var_type.ptr_depth) ? target_address_size : var_type.size;
        size_t arr_size = elem_size * elem_count;
        var_type.ptr_depth++;

        if(fn_type.data){
            // Stack array
            stack_ptr = (stack_ptr + elem_size - 1) / elem_size * elem_size;
            stack_ptr += arr_size;
            size_t var_ptr = stack_ptr;

            // Register the variable in the variable vector
            var_t new_var = {stmt->arr_decl.identifier->str, stmt->arr_decl.identifier->strlen, var_ptr, VAR_ARRAY, var_type};
            vector_append(vars, &new_var);
        }else{
            // Global array
            var_t new_var = {stmt->arr_decl.identifier->str, stmt->arr_decl.identifier->strlen, arr_size, VAR_GLOBAL_ARR, var_type};
            vector_append(vars, &new_var);
        }
        return true;
    }
    case tk_assign:{
        type_t type = typeof_expr(stmt->var_assign.var);
        reg_t* val = generate_expr(fptr, stmt->var_assign.expr, type, NULL);
        bool ok = save_expr(fptr, stmt->var_assign.var, val);
        (void) free_reg(val);
        return ok;
    }
    case tk_add_assign:
    case tk_sub_assign:
    case tk_mult_assign:
    case tk_div_assign:
    case tk_mod_assign:{
        type_t type = typeof_expr(stmt->var_assign.var);
        node_bin_op op = (node_bin_op){stmt->type - tk_add_assign + tk_add, NULL, stmt->var_assign.var, stmt->var_assign.expr};
        reg_t* val = generate_expr(fptr, (node_expr*) &op, type, NULL);
        bool ok = save_expr(fptr, stmt->var_assign.var, val);
        (void) free_reg(val);
        return ok;
    }
    case tk_expr_stmt:{
        // Just generate the expression with the target of a 64 bit int or a type we know
        type_t type = typeof_expr(stmt->expr.expr);
        if(!type.data || !((type.ptr_depth) ? true : type.size))
            type = (type_t){8, GET_DUMMY_TYPE(int64), true, DATA_INT, 0};
        EXPR_ONCE(stmt->expr.expr, type, NULL);
        return true;
    }
    case tk_asm:{
        // Variables
        const char* str;
        size_t strlen, tmp_count = 0;
        reg_t* tmps[10];

        // Go through each used register and allocate it
        for(node_term* t = stmt->asm_stmt.used_regs; t; t = &t->next->term){
            reg_t* reg = get_named_reg(t->str, t->strlen, registers);
            if(!reg){
                print_context_ex("Unknown used register (try using the --reg-info option)", t->str, t->strlen);
                return false;
            }
            reg->occupied = OCCUP_IGNORE;
        }

        // Go through each expression in the extra args
        for(node_expr* expr = stmt->asm_stmt.args; expr && tmp_count < 10; expr = expr->next, tmp_count++){
            tmps[tmp_count] = generate_expr(fptr, expr, typeof_expr(expr), NULL);
            if(!tmps[tmp_count]){
                print_context_expr("Not enough registers for all values (try separating inline assembly in two parts?)", expr);
                return false;
            }
        }

        // Transfer the inlined assembly code to the generated assembly
        str = stmt->asm_stmt.code->str + 1, strlen = stmt->asm_stmt.code->strlen - 2;
        HC_FPRINTF(fptr, "\t");
        for(; strlen; str++, strlen--){
            if(*str == '\\' && *(str+1) == 'n'){
                HC_FPRINTF(fptr, "\n");
                str++, strlen--;
            }else if(*str == '\\' && *(str+1) == 't'){
                HC_FPRINTF(fptr, "\t");
                str++, strlen--;
            }else if(*str == '%' && *(str+1) >= '0' && *(str+1) <= '9'){
                int i = *(++str) - '0';
                strlen--;
                if(i >= tmp_count){
                    print_context_ex("Not enough temporaries for index", str-1, 2);
                    return false;
                }
                HC_FPRINTF(fptr, "%s", tmps[i]->name);
            }else
                HC_FPRINTF(fptr,"%c",*str);
        }
        HC_FPRINTF(fptr, "\n");

        // Free all registers
        for(reg_t* reg_ptr = registers; reg_ptr->name; reg_ptr++)
            (void) free_reg(reg_ptr);

        return true;
    }
    case tk_return:
        // Return value if possible
        if((fn_type.ptr_depth) ? true : fn_type.size && stmt->ret.expr){
            gen_save_return(fptr, EXPR_ONCE(stmt->ret.expr, fn_type, NULL));
        }else if(stmt->ret.expr){
            print_context_expr("Unexpected return value, function returns nothing", stmt->ret.expr);
            print_context("Function's type has a size of 0 bytes", fn_type.repr);
            return false;
        }
        // Jump to the end of the function
        gen_jump(fptr, 0);
        return true;
    }
    HC_ERR("Unkown statement type %lu", stmt->type);
    return false;
}

static void generate_quit(HC_FILE fptr){
    HC_FCLOSE(fptr);
    vector_destroy(vars);
    vector_destroy(funcs);
}

bool generate(const char* output_file, node_stmt* AST, bool library){
    HC_FILE fptr = HC_FOPEN_WRITE(output_file);

    gen_setup(fptr, library);

    // Go through each statement and generate it
    for(; AST; AST = AST->next){
        if(!generate_stmt(fptr, AST, INVALID_TYPE)){
            generate_quit(fptr);
            return false;
        }
    }

    // Go through all declared but not defined functions
    // to set them as extern for the linking stage
    for(size_t i = 0; i < vector_size(funcs); i++){
        func_t* func = vector_at(funcs, i);
        if(func->stmts) continue;
        gen_declare_extern(fptr, func->str, func->strlen);
    }

    // Go through all global variables and add them in the .data section
    // Absolutely disgusting code, will clean up later
    // TODO clean up this mess
    HC_FPRINTF(fptr, "\n\n%s", target_data_section);
    node_term* global_val = global_var_values;
    for(size_t i = 0; i < vector_size(vars); i++){
        var_t* var = vector_at(vars, i);
        if(var->location == VAR_GLOBAL){
            if(var->stack_ptr){
                if(global_val->type != tk_str_lit)
                  gen_declare_global(fptr, var->str, var->strlen, var->type.ptr_depth ? target_address_size : var->type.size, global_val->str, global_val->strlen);
                else{
                    if(var->type.ptr_depth == 0 && var->type.size != target_address_size){
                        print_context_expr("Cannot assign non-pointer variable to a string literal", (node_expr*) global_val);
                        generate_quit(fptr);
                        return false;
                    }
                    char buffer[128];
                    gen_declare_global(
                        fptr, var->str, var->strlen,
                        target_address_size, buffer,
                        // Returns the length of buffer   Returns the string literals id
                        snprintf(buffer, 127, "STR%lu", append_string_literal(global_val))
                    );
                }
                global_val = &global_val->next->term;
            }else
                gen_declare_global(fptr, var->str, var->strlen, var->type.ptr_depth ? target_address_size : var->type.size, "0", 1);
        }else if(var->location == VAR_GLOBAL_ARR)
            gen_declare_global_arr(fptr, var->str, var->strlen, var->stack_ptr);
        else{
            print_context_ex("Not supposed to be left out at the end of program (bug)", var->str, var->strlen);
            generate_quit(fptr);
            return false;
        }
    }

    // Generate the read only data section for string literals
    HC_FPRINTF(fptr, "\n\n%s", target_rodata_section);
    size_t i = 0;
    for(node_term* str_lit = str_literals; str_lit; str_lit = &str_lit->next->term, i++)
        gen_declare_str(fptr, i, str_lit->str, str_lit->strlen);

    generate_quit(fptr);
    return true;
}
