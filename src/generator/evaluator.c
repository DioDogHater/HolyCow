#include "evaluator.h"
#include "generator.h"

uint64_t eval_special_char(char c){
    switch(c){
        case 't':
            return '\t';
        case 'n':
            return '\n';
        case 'r':
            return '\r';
        case 'b':
            return '\b';
        case 'a':
            return '\a';
        case 'f':
            return '\f';
        case 'v':
            return '\v';
        case '\\':
            return '\\';
        case '\'':
            return '\'';
        case '"':
            return '"';
        case '0':
            return '\0';
        case 'e':
            return '\e';
        default:
            HC_WARN("Unknown special character \\%c", c);
            HC_WARN("Value of character defaulting to 0.");
            return 0;
    }
}

uint64_t eval_char_lit(node_term* char_lit){
    const char* str = char_lit->str;
    size_t strlen = char_lit->strlen;
    if(strlen >= 4 && str[1] != '\\'){
        print_context_ex("Character literal cannot be more than 1 character", str, strlen);
        HC_WARN("Value of character defaulting to 0.");
        return 0;
    }
    if(str[1] == '\\')
        return eval_special_char(str[2]);
    return str[1];
}

uint64_t eval_int_lit(node_term* int_lit){
    const char* str = int_lit->str;
    size_t strlen = int_lit->strlen;
    int64_t val = 0;
    if(str[1] == 'x'){
        str += 2, strlen -= 2;
        for(; strlen; strlen--, str++){
            int64_t digit = (*str > '9') ? (*str - 'A' + 10) : (*str - '0');
            val = (val << 4) + digit;
        }
    }else if(str[1] == 'b'){
        str += 2;
        strlen -= 2;
        for(; strlen; strlen--, str++)
            val = (val << 1) + (*str - '0');
    }else if(str[1] == 'o'){
        str += 2, strlen -= 2;
        for(; strlen; strlen--, str++)
            val = (val << 3) + (*str - '0');
    }else{
        for(; strlen; strlen--, str++)
            val = val*10 + (*str - '0');
    }

    return val;
}

double eval_float_lit(node_term* float_lit){
    const char* str = float_lit->str;
    size_t strlen = float_lit->strlen;
    bool decimals = false;
    double val = 0.f, val_frac = 0.f, mult = 1.f;
    for(; strlen; strlen--, str++){
        if(*str == '.'){
            decimals = true;
            continue;
        }
        if(decimals){
            val_frac = val_frac*10.f + (double)(*str - '0');
            mult *= 10.f;
        }else
            val = val*10.f + (double)(*str - '0');
    }
    return val + val_frac / mult;
}

#define EVAL_UNARY_OP(name, op, F, T) \
case name:{\
    T lhs;\
    if(!eval_##F##_expr(expr->bin_op.lhs, &lhs))\
        return false;\
    *result = op lhs;\
    break;\
}
#define EVAL_BIN_OP(name, op, F, T) \
case name:{\
    T lhs, rhs;\
    if(!eval_##F##_expr(expr->bin_op.lhs, &lhs) || !eval_##F##_expr(expr->bin_op.rhs, &rhs))\
        return false;\
    *result = lhs op rhs;\
    break;\
}

#define EVAL_INT_EXPR(name, T) \
bool eval_##name##_expr(node_expr* expr, T* result){\
    type_t expr_type = typeof_expr(expr);\
    if(!expr_type.data)\
        return false;\
    if(DATAOF_T(expr_type) == DATA_FLOAT){\
        double val = 0.f;\
        if(!eval_float_expr(expr, &val))\
            return false;\
        *result = (T) val;\
        return true;\
    }else if(DATAOF_T(expr_type) != DATA_INT)\
        return false;\
    \
    switch(expr->type){\
    case tk_int_lit:\
        *result = eval_int_lit(&expr->term);\
        break;\
    case tk_char_lit:\
        *result = eval_char_lit(&expr->term);\
        break;\
    case tk_bool_lit:\
        *result = *expr->term.str == 't';\
        break;\
    case tk_identifier:{\
        constexpr_t* cons = get_constexpr(expr->term.str, expr->term.strlen);\
        if(cons){\
            *result = (cons->type == CONST_INT) ? (T) cons->i : (T) cons->f;\
            break;\
        }\
        return false;\
    }case tk_dot:{\
        if(expr->access.obj->type != tk_identifier)\
            return false;\
        enum_t* enu = get_enum(expr->access.obj->term.str, expr->access.obj->term.strlen);\
        module_t* mod = get_module(expr->access.obj->term.str, expr->access.obj->term.strlen);\
        if(!enu && !mod) return false;\
        if(enu)\
            return get_enum_val(enu, expr->access.member->str, expr->access.member->strlen, (int64_t*)result);\
        else if(mod){\
            constexpr_t* cons = get_module_const(mod, expr->access.member->str, expr->access.member->strlen);\
            if(cons){\
                *result = (cons->type == CONST_INT) ? (T) cons->i : (T) cons->f;\
                break;\
            }\
            return false;\
        }\
    }case tk_type_cast:\
        return eval_##name##_expr(expr->type_cast.rhs, result);\
    case tk_sizeof:{\
        type_t value_type = INVALID_TYPE;\
        if(expr->unary_op.lhs->type == tk_int8)\
            value_type = type_from_tk(expr->unary_op.lhs->type_expr.start);\
        else if(expr->unary_op.lhs->type == tk_identifier){\
            struct_t* stru = get_struct(expr->unary_op.lhs->term.str, expr->unary_op.lhs->term.strlen);\
            if(stru)\
                value_type = (type_t){stru->size, .data = DATA_STRUCT, .ptr_depth = 0};\
            union_t* unio = get_union(expr->unary_op.lhs->term.str, expr->unary_op.lhs->term.strlen);\
            if(unio)\
                value_type = (type_t){unio->size, .data = DATA_UNION, .ptr_depth = 0};\
        }\
        if(!value_type.data)\
            value_type = typeof_expr(expr->unary_op.lhs);\
        if(!value_type.data)\
            return false;\
        *result = (T) SIZEOF_T(value_type);\
        return true;\
    }\
    EVAL_UNARY_OP(tk_neg, -, name, T)\
    EVAL_UNARY_OP(tk_bin_flip, ~, name, T)\
    EVAL_UNARY_OP(tk_not, !, name, T)\
    EVAL_BIN_OP(tk_add,  +, name, T)\
    EVAL_BIN_OP(tk_sub,  -, name, T)\
    EVAL_BIN_OP(tk_mult, *, name, T)\
    EVAL_BIN_OP(tk_div,  /, name, T)\
    EVAL_BIN_OP(tk_mod,  %, name, T)\
    EVAL_BIN_OP(tk_bin_and,  &, name, T)\
    EVAL_BIN_OP(tk_bin_or,   |, name, T)\
    EVAL_BIN_OP(tk_bin_xor,  ^, name, T)\
    EVAL_BIN_OP(tk_and, &&, name, T)\
    EVAL_BIN_OP(tk_or,  ||, name, T)\
    EVAL_BIN_OP(tk_shl, <<, name, T)\
    EVAL_BIN_OP(tk_shr, >>, name, T)\
    default:\
        return false;\
    }\
    return true;\
}

EVAL_INT_EXPR(int, int64_t)
EVAL_INT_EXPR(uint, uint64_t)

#define EVAL_FBIN_OP(name, op) \
case name:{\
    double lhs, rhs;\
    if(!eval_float_expr(expr->bin_op.lhs, &lhs) || !eval_float_expr(expr->bin_op.rhs, &rhs))\
        return false;\
    *result = lhs op rhs;\
    break;\
}

bool eval_float_expr(node_expr* expr, double* result){
    type_t expr_type = typeof_expr(expr);
    if(DATAOF_T(expr_type) == DATA_INT){
        int64_t integer;
        if(!eval_int_expr(expr, &integer))
            return false;
        *result = (double) integer;
        return true;
    }else if(DATAOF_T(expr_type) != DATA_FLOAT)
        return false;

    switch(expr->type){
    case tk_float_lit:
        *result = eval_float_lit(&expr->term);
        break;
    case tk_neg:{
        if(!eval_float_expr(expr->unary_op.lhs, result))
            return false;
        *result = -*result;
        break;
    }case tk_identifier:{
        constexpr_t* cons = get_constexpr(expr->term.str, expr->term.strlen);
        if(cons){
            *result = (cons->type == CONST_INT) ? (double) cons->i : cons->f;
            break;
        }
        return false;
    }case tk_dot:{
        module_t* mod = get_module(expr->access.obj->term.str, expr->access.obj->term.strlen);
        if(mod){
            constexpr_t* cons = get_module_const(mod, expr->access.member->str, expr->access.member->strlen);
            if(cons){
                *result = (cons->type == CONST_INT) ? (double) cons->i : cons->f;
                break;
            }
        }
        return false;
    }case tk_type_cast:
        return eval_float_expr(expr->type_cast.rhs, result);
    EVAL_FBIN_OP(tk_add, +)
    EVAL_FBIN_OP(tk_sub, -)
    EVAL_FBIN_OP(tk_mult, *)
    EVAL_FBIN_OP(tk_div, /)
    default:
        return false;
    }
    return true;
}
