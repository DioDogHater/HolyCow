#include "evaluator.h"

uint64_t eval_char_lit(node_term* char_lit){
    const char* str = char_lit->str;
    size_t strlen = char_lit->strlen;
    if(strlen >= 4 && str[1] != '\\'){
        print_context_ex("Character literal cannot be more than 1 character", str, strlen);
        HC_WARN("Value of character defaulting to 0.");
        return 0;
    }
    if(str[1] == '\\') switch(str[2]){
        case 't':
            return '\t';
        case 'n':
            return '\n';
        case '0':
            return '\0';
        case 'e':
            return '\e';
        default:
            print_context_ex("Unknown special character", str, strlen);
            HC_WARN("Value of character defaulting to 0.");
            return 0;
    }
    return str[1];
}

uint64_t eval_int_lit(node_term* int_lit){
    const char* str = int_lit->str;
    size_t strlen = int_lit->strlen;
    int64_t val = 0;
    if(str[1] == 'x'){
        str += 2;
        strlen -= 2;
        for(; strlen; strlen--, str++){
            int64_t digit = (*str > '9') ? (*str - 'A' + 10) : (*str - '0');
            val = (val << 4) + digit;
        }
    }else if(str[1] == 'b'){
        str += 2;
        strlen -= 2;
        for(; strlen; strlen--, str++)
            val = (val << 1) + (*str - '0');
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
    return true;\
}
#define EVAL_BIN_OP(name, op, F, T) \
case name:{\
    T lhs, rhs;\
    if(!eval_##F##_expr(expr->bin_op.lhs, &lhs) || !eval_##F##_expr(expr->bin_op.rhs, &rhs))\
        return false;\
    *result = lhs op rhs;\
    return true;\
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
        return true;\
    case tk_char_lit:\
        *result = eval_char_lit(&expr->term);\
        return true;\
    case tk_bool_lit:\
        *result = *expr->term.str == 't';\
        return true;\
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
    }\
    return false;\
}

EVAL_INT_EXPR(int, int64_t)
EVAL_INT_EXPR(uint, uint64_t)

#define EVAL_FBIN_OP(name, op) \
case name:{\
    double lhs, rhs;\
    if(!eval_float_expr(expr->bin_op.lhs, &lhs) || !eval_float_expr(expr->bin_op.rhs, &rhs))\
        return false;\
    *result = lhs op rhs;\
    return true;\
}

bool eval_float_expr(node_expr* expr, double* result){
    switch(expr->type){
    case tk_float_lit:
        *result = eval_float_lit(&expr->term);
        return true;
    case tk_neg:{
        if(!eval_float_expr(expr->unary_op.lhs, result))
            return false;
        *result = -*result;
        return true;
    }
    EVAL_FBIN_OP(tk_add, +)
    EVAL_FBIN_OP(tk_sub, -)
    EVAL_FBIN_OP(tk_mult, *)
    EVAL_FBIN_OP(tk_div, /)
    }
    return false;
}
