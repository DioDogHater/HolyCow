#include "hc_types.h"
#include "generator.h"

token_t dummy_types[] = {
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

void print_type(const char* before, type_t type, const char* after){
    HC_PRINT("%s", before);
    if(type.data && type.repr){
        HC_PRINT(BOLD "%.*s", (int)type.repr->strlen, type.repr->str);
        if(type.repr->type == tk_const)
            HC_PRINT(" %.*s", (int)type.repr->next->strlen, type.repr->next->str);
        if(type.ptr_depth < 0) type.ptr_depth = 0;
        for(size_t i = 0; i < type.ptr_depth; i++)
            HC_PRINT("*");
    }else{
        HC_PRINT(BOLD "(%s %lu bytes%.*s)", type.sign ? "signed" : "unsigned", type.size, (int)type.ptr_depth, "*****..");
    }
    HC_PRINT(RESET_ATTR "%s\n", after);
}

// Returns the sign of a value of type tk
bool signof_type(token_t* tk){
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
size_t sizeof_type(token_t* tk){
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

type_t type_from_tk(token_t* tk){
    size_t sz = sizeof_type(tk);
    bool sign = signof_type(tk);
    int ptr_depth = 0;
    for(token_t* ptr = (tk->type == tk_const) ? tk->next->next : tk->next; ptr && ptr->type == tk_mult; ptr = ptr->next)
        ptr_depth++;
    type_t t = (type_t){sz, tk, sign, DATA_INT, ptr_depth};
    if(tk->type == tk_float)
        t.data = DATA_FLOAT;
    return t;
}

type_t typeof_expr(node_expr* expr){
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
        case tk_str_lit:
            max = (type_t){1,GET_DUMMY_TYPE(uint8),false,DATA_INT,1};
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
        }case tk_float_lit:{
            max = (type_t){8,GET_DUMMY_TYPE(float),true,DATA_FLOAT,0};
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
        case tk_open_bracket:
            max = typeof_expr(expr->bin_op.lhs);
            max.ptr_depth--;
            if(max.ptr_depth < 0){
                print_context_expr("Trying to dereference a direct value", expr);
                return INVALID_TYPE;
            }
            break;
        case tk_deref:
            max = typeof_expr(expr->unary_op.lhs);
            max.ptr_depth--;
            if(max.ptr_depth < 0){
                print_context_expr("Trying to dereference a direct value", expr);
                return INVALID_TYPE;
            }
            break;
        case tk_getaddr:
            max = typeof_expr(expr->unary_op.lhs);
            max.ptr_depth++;
            break;
        case tk_type_cast:
            max = type_from_tk(expr->type_cast.lhs->start);
            break;
        case tk_shl:
        case tk_shr:
            max = typeof_expr(expr->bin_op.lhs);
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
            short dt1 = (t1.ptr_depth) ? DATA_INT : DATA_FLOAT, dt2 = (t2.ptr_depth) ? DATA_INT : DATA_FLOAT;
            if(t1.data && t2.data && t1.data == DATA_INT && t2.data == DATA_INT){
                size_t sz1 = (t1.ptr_depth) ? target_address_size : t1.size, sz2 = (t2.ptr_depth) ? target_address_size : t2.size;
                if(sz1 > sz2 || t1.ptr_depth > t2.ptr_depth || (sz1 == sz2 && t1.sign > t2.sign))
                    max = t1;
                else
                    max = t2;
            }else if(t1.data == DATA_FLOAT && t2.data == DATA_INT)
                max = t1;
            else if(t2.data == DATA_FLOAT && t1.data == DATA_INT)
                max = t2;
            else if(t1.data == DATA_FLOAT && t2.data == DATA_FLOAT)
                max = t1;
            break;
        }case tk_func_call:{
            func_t* func = get_func(expr->func.identifier->str, expr->func.identifier->strlen);
            if(!func){
                print_context_expr("Unknown function", expr);
                return INVALID_TYPE;
            }
            max = func->type;
            break;
        }case tk_stack_alloc:{
            type_t elem_type = type_from_tk(expr->salloc.elem_type);
            elem_type.ptr_depth++;
            max = elem_type;
            break;
        }
    }
    return max;
}
