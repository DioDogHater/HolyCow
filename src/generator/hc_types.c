#include "hc_types.h"
#include "generator.h"
#include "regs.h"

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
    DUMMY_TYPE(double),
    DUMMY_TYPE(bool),
    DUMMY_TYPE(void)
};

void print_type(const char* before, type_t type, const char* after){
    HC_PRINT("%s", before);
    if(type.data && type.repr){
        token_t* repr = type.repr;
        while(repr->next && repr->type >= tk_public && repr->type <= tk_peek)
            repr = repr->next;
        HC_PRINT(BOLD "%.*s", (int)type.repr->strlen, type.repr->str);
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

    switch(tk->type){
        case tk_void:
        case tk_bool:
        case tk_identifier:
            return false;
        case tk_int8:
        case tk_int16:
        case tk_int32:
        case tk_int64:
        case tk_float:
        case tk_double:
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

    switch(tk->type){
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
        case tk_float:
            return 4;
        case tk_int64:
        case tk_uint64:
        case tk_double:
            return 8;
    }

    print_context("Type of unknown size", tk);
    return ~0;
}

type_t type_from_tk(token_t* tk){
    type_t t;
    while(tk->next && tk->type >= tk_public && tk->type <= tk_cfunc)
        tk = tk->next;
    t.repr = tk, t.ptr_depth = 0;
    if(tk->type != tk_identifier){
        size_t sz = sizeof_type(tk);
        if(sz == ~0)
            return INVALID_TYPE;
        bool sign = signof_type(tk);
        t.size = sz, t.align = sz, t.sign = sign;
        t.data = (tk->type == tk_float || tk->type == tk_double) ? DATA_FLOAT : DATA_INT;
    }else{
        t.sign = false;
        struct_t* struc = get_struct_tk(tk);
        if(struc){
            t.size = struc->size, t.align = struc->align;
            t.data = DATA_STRUCT;
        }
        union_t* unio = get_union_tk(tk);
        if(unio){
            t.size = unio->size, t.align = unio->align;
            t.data = DATA_UNION;
        }

        if(!struc && !unio){
            print_context("Type does not exist!", tk);
            return INVALID_TYPE;
        }
    }
    for(token_t* ptr = tk->next; ptr && ptr->type == tk_mult; ptr = ptr->next)
        t.ptr_depth++;
    return t;
}

size_t flags_from_tk(token_t* tk){
    size_t a = FLAG_NONE;
    while(tk->next && tk->type >= tk_public && tk->type <= tk_cfunc){
        if(tk->type != tk_public){
            if(a & (1 << (tk->type - tk_private)))
                print_context("Modifier is repeated, only needed once", tk);
            a |= 1 << (tk->type - tk_private);
        }
        tk = tk->next;
    }

    if((a & FLAG_PRIVATE) && (a & FLAG_PROTECT)){
        a -= FLAG_PROTECT;
        print_context("Cannot be private and protected, defaults to private", tk);
    }

    if((a & FLAG_PEEK) && !(a & FLAG_PRIVATE) && !(a & FLAG_PROTECT)){
        a -= FLAG_PEEK;
        print_context("Cannot be peakable if it isn't private or protected", tk);
    }

    if((a & FLAG_EXTERN) && (a != FLAG_EXTERN && a != (FLAG_EXTERN | FLAG_CFUNC))){
        a &= FLAG_EXTERN;
        print_context("extern can only be used by itself", tk);
    }

    return a;
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
            max = (type_t){1, GET_DUMMY_TYPE(bool), false, DATA_INT, 1, 0};
            break;
        case tk_str_lit:
        case tk_char_lit:
            max = (type_t){1, GET_DUMMY_TYPE(uint8), false, DATA_INT, 1, expr->type == tk_str_lit};
            break;
        case tk_int_lit:{
            max = (type_t){8, GET_DUMMY_TYPE(int64), true, DATA_INT, 8, 0};
            break;
        }case tk_float_lit:{
            max = (type_t){8, GET_DUMMY_TYPE(double), true, DATA_FLOAT, 8, 0};
            break;
        }case tk_identifier:{
            var_t* var = get_var(expr->term.str, expr->term.strlen);
            constexpr_t* cons = get_constexpr(expr->term.str, expr->term.strlen);
            if(!var && !cons){
                print_context_ex("Unknown identifier", expr->term.str, expr->term.strlen);
                return INVALID_TYPE;
            }
            if(var)
                max = var->type;
            else if(cons && cons->type == CONST_INT)
                max = (type_t){8, GET_DUMMY_TYPE(int64), true, DATA_INT, 8, 0};
            else if(cons && cons->type == CONST_FLOAT)
                max = (type_t){8, GET_DUMMY_TYPE(double), true, DATA_FLOAT, 8, 0};
            break;
        }case tk_reg_expr:{
            reg_t* reg = (reg_t*) expr->reg.reg;
            max = (type_t){reg->size, GET_DUMMY_TYPE(uint64), reg->occupied == OCCUP_SIGNED, DATA_INT, reg->size, 0};
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
        case tk_struct:{
            struct_t* stru = get_struct_tk(expr->construct.struc);
            if(!stru){
                print_context("Structure type does not exist!", expr->construct.struc);
                return INVALID_TYPE;
            }
            max = (type_t){stru->size, expr->construct.struc, false, DATA_STRUCT, stru->align, 0};
            break;
        }case tk_union:{
            union_t* unio = get_union(expr->uconstruct.unio->str, expr->uconstruct.unio->strlen);
            if(!unio){
                print_context("Union type does not exist!", expr->uconstruct.unio);
                return INVALID_TYPE;
            }
            max = (type_t){unio->size, expr->uconstruct.unio, false, DATA_UNION, unio->align, 0};
            break;
        }case tk_dot:{
            if(expr->access.obj->type == tk_identifier){
                enum_t* enu = get_enum(expr->access.obj->term.str, expr->access.obj->term.strlen);
                if(enu && get_enum_val(enu, expr->access.member->str, expr->access.member->strlen, NULL))
                    return (type_t){8, GET_DUMMY_TYPE(int64), true, DATA_INT, 8, 0};
                module_t* mod = get_module(expr->access.obj->term.str, expr->access.obj->term.strlen);
                if(mod){
                    var_t* var = get_module_var(mod, expr->access.member->str, expr->access.member->strlen);
                    constexpr_t* cons = get_module_const(mod, expr->access.member->str, expr->access.member->strlen);
                    if(!var && !cons){
                        print_context("Unknown variable in module", expr->access.member);
                        return INVALID_TYPE;
                    }
                    if(var)
                        return var->type;
                    else if(cons->type == CONST_INT)
                        return (type_t){8, GET_DUMMY_TYPE(int64), true, DATA_INT, 8, 0};
                    else
                        return (type_t){8, GET_DUMMY_TYPE(double), true, DATA_FLOAT, 8, 0};
                }
            }

            type_t obj_type = typeof_expr(expr->access.obj);
            if(!obj_type.data || obj_type.ptr_depth > 1 || (obj_type.data != DATA_STRUCT && obj_type.data != DATA_UNION)){
                print_context_expr("Expected structure / class / union", expr->access.obj);
                return INVALID_TYPE;
            }
            if(obj_type.data == DATA_STRUCT){
                struct_t* stru = get_struct_tk(obj_type.repr);
                var_t* member = get_member(stru, expr->access.member->str, expr->access.member->strlen);
                if(!member){
                    print_context("Is not a member of structure / class", expr->access.member);
                    return INVALID_TYPE;
                }
                max = member->type;
            }else{
                union_t* unio = get_union(obj_type.repr->str, obj_type.repr->strlen);
                if(unio->is_variant && expr->access.member->strlen == 4 && strncmp(expr->access.member->str, "type", 4) == 0)
                    return (type_t){unio->align, GET_DUMMY_TYPE(uint64), false, DATA_INT, unio->align, 0};
                node_stmt* member = get_union_member(unio, expr->access.member->str, expr->access.member->strlen);
                if(!member){
                    print_context("Is not a member of union", expr->access.member);
                    return INVALID_TYPE;
                }
                if(member->type == tk_var_decl)
                    max = type_from_tk(member->var_decl.var_type);
                else{
                    max = type_from_tk(member->arr_decl.elem_type);
                    max.ptr_depth++;
                }
            }
            break;
        }case tk_deref:
            max = typeof_expr(expr->unary_op.lhs);
            if(max.ptr_depth == 0){
                print_context_expr("Trying to dereference a direct value", expr);
                return INVALID_TYPE;
            }
            max.ptr_depth--;
            break;
        case tk_sizeof:
            max = (type_t){8, GET_DUMMY_TYPE(uint64), false, DATA_INT, 8, 0};
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
            short dt1 = DATAOF_T(t1), dt2 = DATAOF_T(t2);
            if(t1.data && t2.data && dt1 == DATA_INT && dt2 == DATA_INT){
                size_t sz1 = SIZEOF_T(t1), sz2 = SIZEOF_T(t2);
                if(sz1 > sz2 || t1.ptr_depth > t2.ptr_depth || (sz1 == sz2 && t1.sign > t2.sign))
                    max = t1;
                else
                    max = t2;
            }else if(dt1 == DATA_FLOAT && dt2 == DATA_INT)
                max = t1;
            else if(dt1 == DATA_FLOAT && dt2 == DATA_INT)
                max = t2;
            else if(dt1 == DATA_FLOAT && dt2 == DATA_FLOAT)
                max = t1;
            break;
        }
        case tk_func_call:{
            func_t* func = NULL;
            if(expr->func.func->type == tk_identifier)
                func = get_func(expr->func.func->term.str, expr->func.func->term.strlen);
            else if(expr->func.func->type == tk_dot){
                if(expr->func.func->access.obj->type == tk_identifier){
                    module_t* mod = get_module(expr->func.func->access.obj->term.str,
                                               expr->func.func->access.obj->term.strlen);
                    if(mod)
                        func = get_module_func(mod, expr->func.func->access.member->str,
                                               expr->func.func->access.member->strlen);
                }

                if(!func){
                    type_t t = typeof_expr(expr->func.func->access.obj);
                    if(t.data != DATA_STRUCT || t.ptr_depth > 1){
                        print_context("Expected class to call method", expr->func.func->access.member);
                        return INVALID_TYPE;
                    }
                    struct_t* stru = get_struct_tk(t.repr);
                    func = get_method(stru, expr->func.func->access.member->str, expr->func.func->access.member->strlen);
                }
            }
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

bool types_compatible(type_t a, type_t b){
    uint8_t d1 = DATAOF_T(a), d2 = DATAOF_T(b);
    if(!d1 || !d2)
        return false;
    if(a.ptr_depth != b.ptr_depth)
        return false;
    else if(a.ptr_depth && (a.size != b.size || a.data != b.data) && (!a.repr || a.repr->type != tk_void) && (!b.repr || b.repr->type != tk_void))
        return false;
    if((d1 == DATA_STRUCT && d2 == DATA_STRUCT) || (d1 == DATA_UNION && d2 == DATA_UNION))
        return (a.repr->strlen == b.repr->strlen) && strncmp(a.repr->str, b.repr->str, a.repr->strlen) == 0;
    else if((d1 == DATA_INT && d2 == DATA_FLOAT) || (d1 == DATA_FLOAT && d2 == DATA_INT))
        return true;
    else if(d1 == d2)
        return true;
    return false;
}
