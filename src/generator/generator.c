#include "generator.h"
#include "evaluator.h"
#include "hc_types.h"
#include "regs.h"
#include "target_requirements.h"
#include "../targets/target_x64_Linux.h"
#include "user_defined.h"

// Global variables
size_t stack_ptr = 0;
size_t stack_sz = 0;
size_t label_count = 1;

node_term* str_literals = NULL;
size_t str_literal_count = 0;

node_term* float_literals = NULL;
size_t float_literal_count = 0;

static vector_t global_var_values[1] = { NEW_VECTOR(node_expr) };

// Get the size of a scope (the size of all variables inside)
size_t get_scope_size(node_stmt* scope){
    if(!scope || scope == (node_stmt*)(~0))
        return 0;
    size_t total = 0;
    for(; scope; scope = scope->next){
        if(scope->type == tk_var_decl){
            type_t var_type = type_from_tk(scope->var_decl.var_type);
            size_t var_sz = SIZEOF_T(var_type), var_align = ALIGNOF_T(var_type);
            if(!var_type.data || !var_sz)
                return 0;
            total = ALIGN(total, var_align);
            total += SIZEOF_T(var_type);
        }else if(scope->type == tk_arr_decl){
            uint64_t elem_count;
            if(!eval_uint_expr(scope->arr_decl.elem_count, &elem_count)){
                print_context_expr("Expected constant expression", scope->arr_decl.elem_count);
                return false;
            }
            type_t elem_type = type_from_tk(scope->arr_decl.elem_type);
            size_t elem_sz = SIZEOF_T(elem_type), elem_align = ALIGNOF_T(elem_type);
            if(!elem_type.data || !elem_sz)
                return 0;
            total = ALIGN(total, elem_align);
            total += elem_sz * elem_count;
        }
    }
    return ALIGN(total, 16);
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
    str_lit->next = NULL;
    if(str_literal_count == 0){
        str_literals = str_lit;
    }else{
        if(ptr->strlen == str_lit->strlen && strncmp(ptr->str, str_lit->str, ptr->strlen) == 0)
            return 0;
        for(size_t i = 1; ptr->next; ptr = &ptr->next->term, i++)
            if(ptr->next->term.strlen == str_lit->strlen && strncmp(ptr->next->term.str, str_lit->str, str_lit->strlen) == 0)
                return i;
        ptr->next = (node_expr*) str_lit;
    }
    return str_literal_count++;
}

static void gen_free(HC_FILE fptr){
    vector_destroy(vars);
    hashtable_destroy(funcs);
    for(size_t i = 0; i < vector_size(structs); i++){
        struct_t* stru = vector_at(structs, i);
        vector_destroy(stru->members);
        vector_destroy(stru->funcs);
    }
    vector_destroy(structs);
    vector_destroy(unions);
    vector_destroy(enums);
    HC_FCLOSE(fptr);
}

void fail_gen_expr(HC_FILE fptr){
    HC_ERR("\nGENERATION FAILED!");
    gen_free(fptr);
    compiler_quit();
    HC_FAIL();
}

// Append a float literal to the linked list of float literals
// Returns the id (index) of the float
size_t append_float_literal(node_term* float_lit){
    node_term* ptr = float_literals;
    float_lit->next = NULL;
    if(float_literal_count == 0){
        float_literals = float_lit;
    }else{
        if(ptr->strlen == float_lit->strlen && strncmp(ptr->str, float_lit->str, ptr->strlen) == 0)
            return 0;
        for(size_t i = 1; ptr->next; ptr = &ptr->next->term, i++)
            if(ptr->next->term.strlen == float_lit->strlen && strncmp(ptr->next->term.str, float_lit->str, float_lit->strlen) == 0)
                return i;
        ptr->next = (node_expr*) float_lit;
    }
    return float_literal_count++;
}

// Save a "memory chunk" (struct / class / union / variant / arrays?)
static bool save_memory(HC_FILE fptr, size_t sz, reg_t* ptr, node_expr* value){
    if(value->type == tk_identifier){
        var_t* var = get_var(value->term.str, value->term.strlen);
        if(!var){
            print_context_ex("Unknown identifier", value->term.str, value->term.strlen);
            return false;
        }
        if(var->location == VAR_STACK)
            gen_copy_stack(fptr, ptr, stack_sz - var->stack_ptr, sz);
        else if(var->location == VAR_GLOBAL)
            gen_copy_global(fptr, ptr, var->str, var->strlen, sz);
        else if(var->location == VAR_ARG)
            gen_copy_arg(fptr, ptr, var->stack_ptr, sz);
    }else if(value->type == tk_deref){
        reg_t* src = generate_expr(fptr, value->unary_op.lhs, typeof_expr(value->unary_op.lhs), GET_MASK_REG(target_address_size, allowed_copy_regs));
        gen_copy_ptr(fptr, ptr, src, sz);
        (void) free_reg(src);
    }else if(value->type == tk_dot){
        reg_t* src = alloc_reg(GET_MASK_REG(target_address_size, allowed_copy_regs), false);
        if(!get_expr_address(fptr, src, value))
            return false;
        gen_copy_ptr(fptr, ptr, src, sz);
        (void) free_reg(src);
    }else if(value->type == tk_open_bracket){
        reg_t* src = generate_expr(fptr, value->bin_op.lhs, typeof_expr(value->bin_op.lhs), NULL);
        reg_t* idx = generate_expr(fptr, value->bin_op.rhs, (type_t){8, GET_DUMMY_TYPE(uint64), false, DATA_INT, 8, 0}, NULL);
        gen_copy_idx(fptr, ptr, src, idx, sz);
        (void) free_reg(src);
        (void) free_reg(idx);
    }else if(value->type == tk_func_call){
        func_t* func = NULL;
        size_t func_call_sz = generate_func_call(fptr, value, &func, ptr);
        gen_dealloc_stack(fptr, func_call_sz);
        stack_sz -= func_call_sz;
    }else
        return false;
    return true;
}

bool save_struct(HC_FILE fptr, struct_t* stru, reg_t* ptr, node_expr* value){
    type_t value_type = typeof_expr(value);
    if(value_type.ptr_depth || value_type.data != DATA_STRUCT){
        print_context_expr("Expected structure / class", value);
        return false;
    }
    if(get_struct_tk(value_type.repr) != stru){
        print_context_expr("Incompatible structure type", value);
        HC_PRINT("Expected structure / class type " BOLD GREEN_FG "%.*s" RESET_ATTR " instead.\n", (int)stru->strlen, stru->str);
        return false;
    }

    if(value->type == tk_struct){
        node_expr* args = value->construct.elems;
        node_expr* default_args = stru->default_values;
        size_t i = 0;
        for(; default_args; i++){
            var_t* member = vector_at(stru->members, i);
            node_expr* arg_expr = args;

            if(member->location == VAR_ARRAY)
                continue;

            if(!args || args->type == tk_nothing){
                if(default_args->type == tk_nothing){
                    default_args = default_args->next;
                    continue;
                }
                arg_expr = default_args;
            }

            if(args)
                args = args->next;

            if(member->type.ptr_depth || member->type.data == DATA_INT){
                reg_t* tmp = EXPR_ONCE(arg_expr, member->type, NULL);
                gen_save_offset(fptr, tmp, ptr, member->stack_ptr);
            }else if(member->type.data == DATA_FLOAT){
                if(!generate_float_expr(fptr, arg_expr))
                    return false;
                gen_save_offset_float(fptr, ptr, member->stack_ptr, member->type.size == 8);
            }else if(member->type.data == DATA_STRUCT || member->type.data == DATA_UNION){
                reg_t* member_ptr = alloc_reg(GET_MASK_REG(target_address_size, allowed_copy_regs), false);
                gen_load_offset_ptr(fptr, member_ptr, ptr, member->stack_ptr);
                if(member->type.data == DATA_STRUCT){
                    struct_t* member_stru = get_struct_tk(member->type.repr);
                    if(!save_struct(fptr, member_stru, member_ptr, arg_expr))
                        return false;
                }else{
                    union_t* member_unio = get_union_tk(member->type.repr);
                    if(!save_union(fptr, member_unio, member_ptr, arg_expr))
                        return false;
                }
                (void) free_reg(member_ptr);
            }

            default_args = default_args->next;
            if(args && !default_args){
                print_context_expr("Too many initialisation values provided", args);
                return false;
            }
        }
        return true;
    }

    // If it's not a construction, we just copy memory
    return save_memory(fptr, stru->size, ptr, value);
}

bool save_union(HC_FILE fptr, union_t* unio, reg_t* ptr, node_expr* value){
    type_t value_type = typeof_expr(value);
    if(value_type.ptr_depth || value_type.data != DATA_UNION){
        print_context_expr("Expected union", value);
        return false;
    }
    if(get_union_tk(value_type.repr) != unio){
        print_context_expr("Incompatible union type", value);
        HC_PRINT("Expected structure / class type " BOLD GREEN_FG "%.*s" RESET_ATTR " instead.\n", (int)unio->strlen, unio->str);
        return false;
    }
    if(value->type == tk_union){
        node_stmt* member = get_union_member(unio, value->uconstruct.member->str, value->uconstruct.member->strlen);
        if(!member){
            print_context("Unknown member", value->uconstruct.member);
            return false;
        }
        if(member->type == tk_arr_decl){
            print_context("Cannot give value to array member", value->uconstruct.member);
            return false;
        }
        if(!value->uconstruct.elem && member->var_decl.expr)
            value->uconstruct.elem = member->var_decl.expr;
        type_t member_type = type_from_tk(member->var_decl.var_type);
        if(member_type.ptr_depth || member_type.data == DATA_INT)
            gen_save_ptr(fptr, EXPR_ONCE(value->uconstruct.elem, member_type, NULL), ptr);
        else if(member_type.data == DATA_FLOAT){
            if(!generate_float_expr(fptr, value->uconstruct.elem))
                return false;
            gen_save_ptr_float(fptr, ptr, member_type.size == 8);
        }else if(member_type.data == DATA_STRUCT){
            struct_t* stru = get_struct_tk(member_type.repr);
            if(!save_struct(fptr, stru, ptr, value->uconstruct.elem))
                return false;
        }else if(member_type.data == DATA_UNION){
            union_t* unio = get_union_tk(member_type.repr);
            if(!save_union(fptr, unio, ptr, value->uconstruct.elem))
                return false;
        }
        if(unio->is_variant){
            enum_t* enu = get_enum(unio->str, unio->strlen);
            int64_t val;
            get_enum_val(enu, value->uconstruct.member->str, value->uconstruct.member->strlen, &val);
            reg_t* tmp = GET_FREE_REG(unio->align);
            gen_set_reg_raw(fptr, tmp, val);
            gen_save_offset(fptr, tmp, ptr, unio->size - unio->align);
        }
        return true;
    }
    return save_memory(fptr, unio->size, ptr, value);
}

// If we're inside a class, this will be set to the current class
static struct_t* current_class = NULL;

// If we're inside a module, this will be set to current module
static module_t* current_module = NULL;

// Check if a variable / function is private
static bool check_module_private(size_t flags, module_t* mod, token_t* var, bool write){
    if((!(flags & FLAG_PEEK) || write) && ((flags & FLAG_PRIVATE) || (flags & FLAG_PROTECT))){
        if(((flags & FLAG_INHERITED) && (flags & FLAG_PRIVATE)) || current_module != mod){
            print_context("Cannot access private / protected member", var);
            return false;
        }
    }
    return true;
}

// Check if a member / method is private and cannot be accessed
static bool check_private(size_t flags, struct_t* stru, node_expr* expr, bool write){
    bool is_accessible = true;
    if(expr->access.obj->type == tk_dot){
        node_access* dot = &expr->access.obj->access;
        module_t* mod = get_module(dot->obj->term.str, dot->obj->term.strlen);
        if(mod){
            var_t* var = get_module_var(mod, dot->member->str, dot->member->strlen);
            is_accessible = check_module_private(var->flags, mod, dot->member, write);
        }else{
            type_t obj_type = typeof_expr(dot->obj);
            struct_t* stru2 = get_struct_tk(obj_type.repr);
            var_t* member = get_member(stru2, dot->member->str, dot->member->strlen);
            is_accessible = check_private(member->flags, stru2, (node_expr*) dot, write);
        }
    }else if(expr->access.obj->type == tk_func_call && expr->access.obj->func.func->type == tk_dot){
        node_access* dot = &expr->access.obj->func.func->access;
        module_t* mod = get_module(dot->obj->term.str, dot->obj->term.strlen);
        if(mod){
            func_t* func = get_module_func(mod, dot->member->str, dot->member->strlen);
            is_accessible = check_module_private(func->flags, mod, dot->member, write);
        }else{
            type_t obj_type = typeof_expr(dot->obj);
            struct_t* stru2 = get_struct_tk(obj_type.repr);
            func_t* method = get_method(stru2, dot->member->str, dot->member->strlen);
            is_accessible = check_private(method->flags, stru2, (node_expr*) dot, write);
        }
    }
    if(!is_accessible)
        return false;
    if((!(flags & FLAG_PEEK) || write) && ((flags & FLAG_PRIVATE) || (flags & FLAG_PROTECT))){
        if(((flags & FLAG_INHERITED) && (flags & FLAG_PRIVATE)) || current_class != stru){
            print_context("Cannot access private / protected member", expr->access.member);
            return false;
        }
    }
    return true;
}



// Get the address of a value
bool get_expr_address(HC_FILE fptr, reg_t* tmp,  node_expr* expr){
    if(expr->type == tk_identifier){
        var_t* var = get_var(expr->term.str, expr->term.strlen);
        if(!var){
            print_context_expr("Unknown identifier", expr);
            return false;
        }
        if(var->location == VAR_STACK)
            gen_load_stack_ptr(fptr, tmp, stack_sz - var->stack_ptr);
        else if(var->location == VAR_GLOBAL)
            gen_load_global_ptr(fptr, tmp, var->str, var->strlen);
        else if(var->location == VAR_ARG)
            gen_load_arg_ptr(fptr, tmp, var->stack_ptr);
        else if(var->location == VAR_ARRAY || var->location == VAR_GLOBAL_ARR){
            print_context_expr("Cannot get address to an array, use intermediate pointer variable instead", expr);
            return false;
        }else{
            print_context_expr("Not implemented yet", expr);
            return false;
        }
        return true;
    }else if(expr->type == tk_open_bracket){
        type_t ptr_type = typeof_expr(expr);
        ptr_type.ptr_depth++;
        reg_t* ptr = generate_expr(fptr, expr->bin_op.lhs, ptr_type, NULL);
        reg_t* idx = generate_expr(fptr, expr->bin_op.rhs, (type_t){8, GET_DUMMY_TYPE(uint64), false, DATA_INT, 8, 0}, NULL);
        gen_load_idx_ptr(fptr, tmp, ptr, idx, ptr_type.size);
        (void) free_reg(ptr);
        (void) free_reg(idx);
        return true;
    }else if(expr->type == tk_dot){
        if(expr->access.obj->type == tk_identifier){
            module_t* mod = get_module(expr->access.obj->term.str, expr->access.obj->term.strlen);
            if(mod){
                var_t* var = get_module_var(mod, expr->access.member->str, expr->access.member->strlen);
                if(!var){
                    print_context("Unknown variable in module", expr->access.member);
                    return false;
                }
                if(var->location != VAR_STACK){
                    print_context("Cannot get address to array, array is the address itself", expr->access.member);
                    return false;
                }
                if(!check_module_private(var->flags, mod, expr->access.member, false))
                    return false;
                gen_load_global_offset_ptr(fptr, tmp, mod->str, mod->strlen, var->stack_ptr);
                return true;
            }
        }

        type_t obj_type = typeof_expr(expr->access.obj);
        if(obj_type.ptr_depth > 1 || (obj_type.data != DATA_STRUCT && obj_type.data != DATA_UNION)){
            print_context_expr("Expected structure / class / union", expr->access.obj);
            return false;
        }
        if(obj_type.data == DATA_STRUCT){
            struct_t* stru = get_struct_tk(obj_type.repr);
            var_t* member = get_member(stru, expr->access.member->str, expr->access.member->strlen);
            if(member->location == VAR_ARRAY){
                print_context("Cannot get address to array, array is the address itself", expr->access.member);
                return false;
            }
            if(!check_private(member->flags, stru, expr, false))
                return false;
            if(obj_type.ptr_depth){
                generate_expr(fptr, expr->access.obj, obj_type, free_reg(tmp));
                gen_load_offset_ptr(fptr, tmp, tmp, member->stack_ptr);
            }else{
                if(!get_expr_address(fptr, tmp, expr->access.obj))
                    return false;
                gen_load_offset_ptr(fptr, tmp, tmp, member->stack_ptr);
            }
            return true;
        }else if(obj_type.data == DATA_UNION)
            return get_expr_address(fptr, tmp, expr->access.obj);
    }

    print_context_expr("Unable to get address of expression", expr);
    return false;
}

// Save a value in an expression
bool save_expr(HC_FILE fptr, node_expr* expr, node_expr* value){
    {
        type_t expr_type = typeof_expr(expr), val_type = typeof_expr(value);
        if(!types_compatible(expr_type, val_type)){
            print_context_expr("Types are incompatible", value);
            print_type("Type ", val_type, " is not compatible with");
            print_type("the expected type ", expr_type, "!");
            return false;
        }
    }

    if(expr->type == tk_identifier){
        // Variable assignment
        var_t* var = get_var(expr->term.str, expr->term.strlen);
        if(!var){
            print_context_ex("Unknown identifier", expr->term.str, expr->term.strlen);
            return false;
        }

        if(var->location == VAR_ARRAY || var->location == VAR_GLOBAL_ARR){
            print_context_ex("Cannot give value to an array", expr->term.str, expr->term.strlen);
            return false;
        }

        if(var->type.ptr_depth || var->type.data == DATA_INT){
            reg_t* data = EXPR_ONCE(value, var->type, NULL);
            if(var->location == VAR_STACK)
                gen_save_stack(fptr, data, stack_sz - var->stack_ptr);
            else if(var->location == VAR_GLOBAL)
                gen_save_global(fptr, data, var->str, var->strlen);
            else if(var->location == VAR_ARG)
                gen_save_arg(fptr, data, var->stack_ptr);
        }else if(var->type.data == DATA_FLOAT){
            if(!generate_float_expr(fptr, value))
                return false;
            if(var->location == VAR_STACK)
                gen_save_stack_float(fptr, stack_sz - var->stack_ptr, var->type.size == 8);
            else if(var->location == VAR_GLOBAL)
                gen_save_global_float(fptr, var->str, var->strlen, var->type.size == 8);
            else if(var->location == VAR_ARG)
                gen_save_arg_float(fptr, var->stack_ptr, var->type.size == 8);
        }else if(var->type.data == DATA_STRUCT || var->type.data == DATA_UNION){
            reg_t* var_ptr = alloc_reg(GET_MASK_REG(target_address_size, allowed_copy_regs), false);
            if(var->location == VAR_STACK)
                gen_load_stack_ptr(fptr, var_ptr, stack_sz - var->stack_ptr);
            else if(var->location == VAR_GLOBAL)
                gen_load_global_ptr(fptr, var_ptr, var->str, var->strlen);
            else if(var->location == VAR_ARG)
                gen_load_arg_ptr(fptr, var_ptr, var->stack_ptr);
            if(var->type.data == DATA_STRUCT){
                struct_t* stru = get_struct_tk(var->type.repr);
                if(!save_struct(fptr, stru, var_ptr, value))
                    return false;
            }else{
                union_t* unio = get_union_tk(var->type.repr);
                if(!save_union(fptr, unio, var_ptr, value))
                    return false;
            }
            (void) free_reg(var_ptr);
            return true;
        }
        return true;
    }else if(expr->type == tk_deref){
        // * operator (dereference)
        type_t ptr_type = typeof_expr(expr->unary_op.lhs);
        if(ptr_type.ptr_depth == 0){
            print_context_expr("Expected a pointer to dereference", expr->unary_op.lhs);
            print_type("Type ", ptr_type, " is not a pointer.");
            return false;
        }
        reg_t* ptr = generate_expr(fptr, expr->unary_op.lhs, ptr_type, GET_MASK_REG(target_address_size, allowed_copy_regs));
        if(--ptr_type.ptr_depth || ptr_type.data == DATA_INT){
            reg_t* data = EXPR_ONCE(value, ptr_type, NULL);
            gen_save_ptr(fptr, data, ptr);
        }else if(ptr_type.data == DATA_FLOAT){
            if(!generate_float_expr(fptr, value))
                return false;
            gen_save_ptr_float(fptr, ptr, ptr_type.size == 8);
        }else if(ptr_type.data == DATA_STRUCT){
            struct_t* stru = get_struct_tk(ptr_type.repr);
            if(!save_struct(fptr, stru, ptr, value))
                return false;
        }else if(ptr_type.data == DATA_UNION){
            union_t* unio = get_union_tk(ptr_type.repr);
            if(!save_union(fptr, unio, ptr, value))
                return false;
        }
        (void) free_reg(ptr);
        return true;
    }else if(expr->type == tk_open_bracket){
        // Array element
        type_t ptr_type = typeof_expr(expr->bin_op.lhs);
        if(ptr_type.ptr_depth == 0){
            print_context_expr("Expected a pointer to dereference", expr->bin_op.lhs);
            print_type("Type ", ptr_type, " is not a pointer.");
            return false;
        }
        // Generate the pointer and index expressions
        reg_t* ptr = generate_expr(fptr, expr->bin_op.lhs, ptr_type, NULL);
        reg_t* idx = generate_expr(fptr, expr->bin_op.rhs, (type_t){target_address_size, GET_DUMMY_TYPE(uint64), false, DATA_INT, target_address_size, 0}, NULL);
        if(--ptr_type.ptr_depth) ptr_type.size = target_address_size;
        if(ptr_type.ptr_depth || ptr_type.data == DATA_INT){
            // Save the int expression into the array element
            reg_t* data = EXPR_ONCE(value, ptr_type, NULL);
            gen_save_idx(fptr, data, ptr, idx, ptr_type.size);
        }else if(ptr_type.data == DATA_FLOAT){
            // Save the float expression into the array element
            if(!generate_float_expr(fptr, value))
                return false;
            gen_save_idx_float(fptr, ptr, idx, ptr_type.size, ptr_type.size == 8);
        }else if(ptr_type.data == DATA_STRUCT || ptr_type.data == DATA_UNION){
            (void) free_reg(ptr);
            reg_t* tmp = alloc_reg(GET_MASK_REG(target_address_size, allowed_copy_regs), false);
            gen_load_idx_ptr(fptr, tmp, ptr, idx, ptr_type.size);
            (void) free_reg(idx);
            if(ptr_type.data == DATA_STRUCT){
                struct_t* stru = get_struct_tk(ptr_type.repr);
                if(!save_struct(fptr, stru, tmp, value))
                    return false;
            }else{
                union_t* unio = get_union_tk(ptr_type.repr);
                if(!save_union(fptr, unio, tmp, value))
                    return false;
            }
            (void) free_reg(tmp);
            return true;
        }
        (void) free_reg(ptr);
        (void) free_reg(idx);
        return true;
    }else if(expr->type == tk_dot){
        // Module variable assignment
        if(expr->access.obj->type == tk_identifier){
            module_t* mod = get_module(expr->access.obj->term.str, expr->access.obj->term.strlen);
            if(mod){
                var_t* var = get_module_var(mod, expr->access.member->str, expr->access.member->strlen);
                if(!var){
                    print_context("Unknown variable in module", expr->access.member);
                    return false;
                }
                if(var->location != VAR_STACK){
                    print_context("Cannot give value to array, array is the address itself", expr->access.member);
                    return false;
                }
                if(!check_module_private(var->flags, mod, expr->access.member, true))
                    return false;
                if(var->type.ptr_depth || var->type.data == DATA_INT)
                    gen_save_global_offset(fptr, EXPR_ONCE(value, var->type, NULL), mod->str, mod->strlen, var->stack_ptr);
                else if(var->type.data == DATA_FLOAT){
                    if(!generate_float_expr(fptr, value))
                        return false;
                    gen_save_global_offset_float(fptr, mod->str, mod->strlen, var->stack_ptr, var->type.size == 8);
                }else if(var->type.data == DATA_STRUCT || var->type.data == DATA_UNION){
                    reg_t* tmp = alloc_reg(GET_MASK_REG(target_address_size, allowed_copy_regs), false);
                    gen_load_global_offset_ptr(fptr, tmp, mod->str, mod->strlen, var->stack_ptr);
                    if(var->type.data == DATA_STRUCT){
                        struct_t* stru = get_struct_tk(var->type.repr);
                        if(!save_struct(fptr, stru, tmp, value))
                            return false;
                    }else if(var->type.data == DATA_UNION){
                        union_t* unio = get_union_tk(var->type.repr);
                        if(!save_union(fptr, unio, tmp, value))
                            return false;
                    }
                    (void) free_reg(tmp);
                }
                return true;
            }
        }

        // Member / attribute / union assignment
        type_t obj_type = typeof_expr(expr->access.obj);
        if(obj_type.ptr_depth > 1 || (obj_type.data != DATA_STRUCT && obj_type.data != DATA_UNION)){
            print_context_expr("Expected structure / class / union", expr->access.obj);
            return false;
        }
        if(obj_type.data == DATA_STRUCT){
            struct_t* stru = get_struct_tk(obj_type.repr);
            var_t* member = get_member(stru, expr->access.member->str, expr->access.member->strlen);
            if(!member){
                print_context("Unknown member", expr->access.member);
                return false;
            }
            if(member->location == VAR_ARRAY){
                print_context_expr("Cannot give value to an array member", expr);
                return false;
            }
            if(!check_private(member->flags, stru, expr, true))
                return false;
            if(obj_type.ptr_depth || expr->access.obj->type == tk_deref || expr->access.obj->type == tk_open_bracket || expr->access.obj->type == tk_dot){
                reg_t* ptr;
                if(obj_type.ptr_depth)
                    ptr = generate_expr(fptr, expr->access.obj, obj_type, NULL);
                else if(expr->access.obj->type == tk_deref){
                    obj_type.ptr_depth++;
                    ptr = generate_expr(fptr, expr->access.obj->unary_op.lhs, obj_type, NULL);
                }else if(expr->access.obj->type == tk_open_bracket){
                    ptr = alloc_reg(GET_MASK_REG(target_address_size, allowed_copy_regs), false);
                    obj_type.ptr_depth++;
                    reg_t* arr = generate_expr(fptr, expr->access.obj->bin_op.lhs, obj_type, NULL);
                    reg_t* idx = generate_expr(fptr, expr->access.obj->bin_op.rhs, (type_t){8, GET_DUMMY_TYPE(uint64), false, DATA_INT, 8, 0}, NULL);
                    gen_load_idx_ptr(fptr, ptr, arr, idx, obj_type.size);
                    (void) free_reg(arr);
                    (void) free_reg(idx);
                }else if(expr->access.obj->type == tk_dot){
                    ptr = alloc_reg(GET_MASK_REG(target_address_size, allowed_copy_regs), false);
                    if(!get_expr_address(fptr, ptr, expr->access.obj))
                        return false;
                }
                if(member->type.ptr_depth || member->type.data == DATA_INT){
                    reg_t* tmp = EXPR_ONCE(value, member->type, NULL);
                    gen_save_offset(fptr, tmp, ptr, member->stack_ptr);
                }else if(member->type.data == DATA_FLOAT){
                    if(!generate_float_expr(fptr, value))
                        return false;
                    gen_save_offset_float(fptr, ptr, member->stack_ptr, member->type.size == 8);
                }else if(member->type.data == DATA_STRUCT){
                    struct_t* stru = get_struct_tk(member->type.repr);
                    gen_load_offset_ptr(fptr, ptr, ptr, member->stack_ptr);
                    if(!save_struct(fptr, stru, ptr, value))
                        return false;
                }else if(member->type.data == DATA_UNION){
                    union_t* unio = get_union_tk(member->type.repr);
                    gen_load_offset_ptr(fptr, ptr, ptr, member->stack_ptr);
                    if(!save_union(fptr, unio, ptr, value))
                        return false;
                }
                (void) free_reg(ptr);
                return true;
            }else if(expr->access.obj->type == tk_identifier){
                var_t* var = get_var(expr->access.obj->term.str, expr->access.obj->term.strlen);
                if(member->type.ptr_depth || member->type.data == DATA_INT){
                    reg_t* tmp = EXPR_ONCE(value, member->type, NULL);
                    if(var->location == VAR_STACK || var->location == VAR_ARRAY)
                        gen_save_stack(fptr, tmp, stack_sz - var->stack_ptr + member->stack_ptr);
                    else if(var->location == VAR_GLOBAL || var->location == VAR_GLOBAL_ARR)
                        gen_save_global_offset(fptr, tmp, var->str, var->strlen, member->stack_ptr);
                    else if(var->location == VAR_ARG)
                        gen_save_arg(fptr, tmp, var->stack_ptr + member->stack_ptr);
                }else if(member->type.data == DATA_FLOAT){
                    if(!generate_float_expr(fptr, value))
                        return false;
                    if(var->location == VAR_STACK || var->location == VAR_ARRAY)
                        gen_save_stack_float(fptr, stack_sz - var->stack_ptr + member->stack_ptr, var->type.size == 8);
                    else if(var->location == VAR_GLOBAL || var->location == VAR_GLOBAL_ARR)
                        gen_save_global_offset_float(fptr, var->str, var->strlen, member->stack_ptr, var->type.size == 8);
                    else if(var->location == VAR_ARG)
                        gen_save_arg_float(fptr, var->stack_ptr + member->stack_ptr, var->type.size == 8);
                }else if(member->type.data == DATA_STRUCT || member->type.data == DATA_UNION){
                    reg_t* tmp = alloc_reg(GET_MASK_REG(target_address_size, allowed_copy_regs), false);
                    if(var->location == VAR_STACK || var->location == VAR_ARRAY)
                        gen_load_stack_ptr(fptr, tmp, stack_sz - var->stack_ptr + member->stack_ptr);
                    else if(var->location == VAR_GLOBAL || var->location == VAR_GLOBAL_ARR)
                        gen_load_global_offset_ptr(fptr, tmp, var->str, var->strlen, member->stack_ptr);
                    else if(var->location == VAR_ARG)
                        gen_load_arg_ptr(fptr, tmp, var->stack_ptr + member->stack_ptr);
                    if(member->type.data == DATA_STRUCT){
                        struct_t* stru = get_struct_tk(member->type.repr);
                        if(!save_struct(fptr, stru, tmp, value))
                            return false;
                    }else{
                        union_t* unio = get_union_tk(member->type.repr);
                        if(!save_union(fptr, unio, tmp, value))
                            return false;
                    }
                    (void) free_reg(tmp);
                }
                return true;
            }
            return false;
        }else if(obj_type.data == DATA_UNION){
            union_t* unio = get_union_tk(obj_type.repr);
            node_stmt* member = get_union_member(unio, expr->access.member->str, expr->access.member->strlen);
            if(!member){
                print_context("Unknown member", expr->access.member);
                return false;
            }
            if(member->type == tk_arr_decl){
                print_context("Cannot give value to array member", expr->access.member);
                return false;
            }
            type_t member_type = type_from_tk(member->var_decl.var_type);
            if(obj_type.ptr_depth || expr->access.obj->type == tk_deref || expr->access.obj->type == tk_open_bracket || expr->access.obj->type == tk_dot){
                reg_t* ptr;
                if(obj_type.ptr_depth)
                    ptr = generate_expr(fptr, expr->access.obj, obj_type, NULL);
                else if(expr->access.obj->type == tk_deref){
                    obj_type.ptr_depth++;
                    ptr = generate_expr(fptr, expr->access.obj->unary_op.lhs, obj_type, NULL);
                }else if(expr->access.obj->type == tk_open_bracket){
                    ptr = alloc_reg(GET_MASK_REG(target_address_size, allowed_copy_regs), false);
                    obj_type.ptr_depth++;
                    reg_t* arr = generate_expr(fptr, expr->access.obj->bin_op.lhs, obj_type, NULL);
                    reg_t* idx = generate_expr(fptr, expr->access.obj->bin_op.rhs, (type_t){8, GET_DUMMY_TYPE(uint64), false, DATA_INT, 8, 0}, NULL);
                    gen_load_idx_ptr(fptr, ptr, arr, idx, obj_type.size);
                    (void) free_reg(arr);
                    (void) free_reg(idx);
                }else if(expr->access.obj->type == tk_dot){
                    ptr = alloc_reg(GET_MASK_REG(target_address_size, allowed_copy_regs), false);
                    if(!get_expr_address(fptr, ptr, expr->access.obj))
                        return false;
                }
                if(member_type.ptr_depth || member_type.data == DATA_INT){
                    reg_t* tmp = EXPR_ONCE(value, member_type, NULL);
                    gen_save_ptr(fptr, tmp, ptr);
                }else if(member_type.data == DATA_FLOAT){
                    if(!generate_float_expr(fptr, value))
                        return false;
                    gen_save_ptr_float(fptr, ptr, member_type.size == 8);
                }else if(member_type.data == DATA_STRUCT){
                    struct_t* stru = get_struct_tk(member_type.repr);
                    if(!save_struct(fptr, stru, ptr, value))
                        return false;
                }else if(member_type.data == DATA_UNION){
                    union_t* unio = get_union_tk(member_type.repr);
                    if(!save_union(fptr, unio, ptr, value))
                        return false;
                }
                (void) free_reg(ptr);
                return true;
            }else if(expr->access.obj->type == tk_identifier){
                var_t* var = get_var(expr->access.obj->term.str, expr->access.obj->term.strlen);
                if(member_type.ptr_depth || member_type.data == DATA_INT){
                    reg_t* tmp = EXPR_ONCE(value, member_type, NULL);
                    if(var->location == VAR_STACK || var->location == VAR_ARRAY)
                        gen_save_stack(fptr, tmp, stack_sz - var->stack_ptr);
                    else if(var->location == VAR_GLOBAL || var->location == VAR_GLOBAL_ARR)
                        gen_save_global(fptr, tmp, var->str, var->strlen);
                    else if(var->location == VAR_ARG)
                        gen_save_arg(fptr, tmp, var->stack_ptr);
                }else if(member_type.data == DATA_FLOAT){
                    if(!generate_float_expr(fptr, value))
                        return false;
                    if(var->location == VAR_STACK || var->location == VAR_ARRAY)
                        gen_save_stack_float(fptr, stack_sz - var->stack_ptr, var->type.size == 8);
                    else if(var->location == VAR_GLOBAL || var->location == VAR_GLOBAL_ARR)
                        gen_save_global_float(fptr, var->str, var->strlen, var->type.size == 8);
                    else if(var->location == VAR_ARG)
                        gen_save_arg_float(fptr, var->stack_ptr, var->type.size == 8);
                }else if(member_type.data == DATA_STRUCT || member_type.data == DATA_UNION){
                    reg_t* tmp = alloc_reg(GET_MASK_REG(target_address_size, allowed_copy_regs), false);
                    if(var->location == VAR_STACK || var->location == VAR_ARRAY)
                        gen_load_stack_ptr(fptr, tmp, stack_sz - var->stack_ptr);
                    else if(var->location == VAR_GLOBAL || var->location == VAR_GLOBAL_ARR)
                        gen_load_global_ptr(fptr, tmp, var->str, var->strlen);
                    else if(var->location == VAR_ARG)
                        gen_load_arg_ptr(fptr, tmp, var->stack_ptr);
                    if(member_type.data == DATA_STRUCT){
                        struct_t* stru = get_struct_tk(member_type.repr);
                        if(!save_struct(fptr, stru, tmp, value))
                            return false;
                    }else{
                        union_t* unio = get_union_tk(member_type.repr);
                        if(!save_union(fptr, unio, tmp, value))
                            return false;
                    }
                    (void) free_reg(tmp);
                }
                return true;
            }
            return false;
        }
    }
    print_context_expr("Unable to save to expr", expr);
    return false;
}

bool inc_expr(HC_FILE fptr, node_expr* expr, reg_t* dest, bool before, bool inc){
    type_t expr_type = typeof_expr(expr);
    if(!expr_type.data){
        print_context_expr("Cannot increment / decrement", expr);
        return NULL;
    }
    size_t sz = SIZEOF_T(expr_type), dsz = dest->size;
    bool sign = (dest->occupied == OCCUP_SIGNED);
    if(expr->type == tk_identifier){
        var_t* var = get_var(expr->term.str, expr->term.strlen);
        if(!var){
            print_context_expr("Unknown identifier", expr);
            return false;
        }
        if(var->location == VAR_STACK){
            if(!before)
                (dsz > sz) ? gen_loadx_stack(fptr, dest, stack_sz - var->stack_ptr, sz, sign) : gen_load_stack(fptr, dest, stack_sz - var->stack_ptr);
            gen_inc_stack(fptr, stack_sz - var->stack_ptr, sz, inc);
            if(before)
                (dsz > sz) ? gen_loadx_stack(fptr, dest, stack_sz - var->stack_ptr, sz, sign) : gen_load_stack(fptr, dest, stack_sz - var->stack_ptr);
        }else if(var->location == VAR_ARG){
            if(!before)
                (dsz > sz) ? gen_loadx_arg(fptr, dest, var->stack_ptr, sz, sign) : gen_load_arg(fptr, dest, var->stack_ptr);
            gen_inc_arg(fptr, var->stack_ptr, SIZEOF_T(var->type), inc);
            if(before)
                (dsz > sz) ? gen_loadx_arg(fptr, dest, var->stack_ptr, sz, sign) : gen_load_arg(fptr, dest, var->stack_ptr);
        }else if(var->location == VAR_GLOBAL){
            if(!before)
                (dsz > sz) ? gen_loadx_global(fptr, dest, var->str, var->strlen, sz, sign) :
                             gen_load_global(fptr, dest, var->str, var->strlen);
            gen_inc_global(fptr, var->str, var->strlen, SIZEOF_T(var->type), inc);
            if(before)
                (dsz > sz) ? gen_loadx_global(fptr, dest, var->str, var->strlen, sz, sign) :
                             gen_load_global(fptr, dest, var->str, var->strlen);
        }else{
            print_context_expr("Cannot increment / decrement an array", expr);
            return false;
        }
    }else if(expr->type == tk_deref){
        expr_type.ptr_depth++;
        reg_t* ptr = generate_expr(fptr, expr->unary_op.lhs, expr_type, NULL);
        if(!before)
            (dsz > sz) ? gen_loadx_ptr(fptr, dest, ptr, sz, sign) : gen_load_ptr(fptr, dest, ptr);
        gen_inc_ptr(fptr, ptr, SIZEOF_T(expr_type), inc);
        if(before)
            (dsz > sz) ? gen_loadx_ptr(fptr, dest, ptr, sz, sign) : gen_load_ptr(fptr, dest, ptr);
        (void) free_reg(ptr);
    }else if(expr->type == tk_open_bracket){
        expr_type.ptr_depth++;
        reg_t* ptr = generate_expr(fptr, expr->bin_op.lhs, expr_type, NULL);
        reg_t* idx = generate_expr(fptr, expr->bin_op.rhs,
                        (type_t){target_address_size, GET_DUMMY_TYPE(uint64), false, DATA_INT, target_address_size, 0}, NULL);
        expr_type.ptr_depth--;
        if(!before)
            (dsz > sz) ? gen_loadx_idx(fptr, dest, ptr, idx, sz, sign) : gen_load_idx(fptr, dest, ptr, idx, sz);
        gen_inc_idx(fptr, ptr, idx, sz, inc);
        if(before)
            (dsz > sz) ? gen_loadx_idx(fptr, dest, ptr, idx, sz, sign) : gen_load_idx(fptr, dest, ptr, idx, sz);
        (void) free_reg(ptr);
        (void) free_reg(idx);
    }else if(expr->type == tk_dot){
        reg_t* ptr = alloc_reg(GET_FREE_REG(target_address_size), false);
        if(!get_expr_address(fptr, ptr, expr))
            return false;
        if(!before)
            (dsz > sz) ? gen_loadx_ptr(fptr, dest, ptr, sz, sign) : gen_load_ptr(fptr, dest, ptr);
        gen_inc_ptr(fptr, ptr, sz, inc);
        if(before)
            (dsz > sz) ? gen_loadx_ptr(fptr, dest, ptr, sz, sign) : gen_load_ptr(fptr, dest, ptr);
        (void) free_reg(ptr);
    }else{
        print_context_expr("Cannot increment / decrement value", expr);
        return false;
    }
    return true;
}

// Generates a function call.
// expr = the function call expression.
// ret_func = pointer to function we just called, where this function will modify it.
// struct_ptr = an optional parameter, used when the function returns a structure.
// Returns the stack size allocated to call the function and provide arguments.
size_t generate_func_call(HC_FILE fptr, node_expr* expr, func_t** ret_func, reg_t* struct_ptr){
    reg_t* masked_regs[MAX_REGS];

    // Get the function
    type_t method = INVALID_TYPE;
    module_t* module = NULL;
    func_t* func = NULL;
    if(expr->func.func->type == tk_identifier)
        func = get_func(expr->func.func->term.str, expr->func.func->term.strlen);
    else if(expr->func.func->type == tk_dot){
        if(expr->func.func->access.obj->type == tk_identifier){
            module_t* mod = get_module(expr->func.func->access.obj->term.str,
                                       expr->func.func->access.obj->term.strlen);
            if(mod){
                func = get_module_func(mod, expr->func.func->access.member->str,
                                       expr->func.func->access.member->strlen);
                if(!func){
                    print_context("Function does not exist in module", expr->func.func->access.member);
                    fail_gen_expr(fptr);
                }
                if(!check_module_private(func->flags, mod, expr->func.func->access.member, false))
                    fail_gen_expr(fptr);
                module = mod;
            }
        }

        if(!func){
            type_t t = typeof_expr(expr->func.func->access.obj);
            if(t.data != DATA_STRUCT || t.ptr_depth > 1){
                print_context("Expected class to call method", expr->func.func->access.member);
                fail_gen_expr(fptr);
            }
            method = t;
            struct_t* stru = get_struct_tk(t.repr);
            func = get_method(stru, expr->func.func->access.member->str, expr->func.func->access.member->strlen);
            if(!check_private(func->flags, stru, expr->func.func, false))
                fail_gen_expr(fptr);
        }
    }
    if(!func){
        print_context_expr("Unknown function", expr->func.func);
        fail_gen_expr(fptr);
    }
    *ret_func = func;

    if(func->flags & FLAG_CFUNC)
        return generate_cfunc_call(fptr, expr, *ret_func, struct_ptr);

    // The amount of bytes allocated on the stack
    size_t func_call_sz = (func->type.ptr_depth || func->type.data == DATA_STRUCT || func->type.data == DATA_UNION) ? target_address_size : func->type.size;

    // If we have to pass the "this" pointer
    if(method.data)
        func_call_sz = ALIGN(func_call_sz, target_address_size) + target_address_size;

    // Get the occupied registers to save on the stack
    // (because a function can affect registers)
    int n = get_mask_occup_regs(ALL_REGS, true, registers, masked_regs);
    for(int i = 0; i < n; i++){
        if(struct_ptr && masked_regs[i]->name == struct_ptr->name)
            continue;
        func_call_sz = ALIGN(func_call_sz, masked_regs[i]->size);
        func_call_sz += masked_regs[i]->size;
    }

    // Get the size of all arguments + return value
    node_expr* arg_expr = expr->func.args;
    size_t varg_count = 0;
    for(node_var_decl* arg = &func->args->var_decl; arg; arg = &arg->next->var_decl){
        if(arg->type == tk_var_args){
            func_call_sz = ALIGN(func_call_sz, 8);
            if(((node_expr_stmt*)arg)->expr)
                func_call_sz += 8;
            for(; arg_expr; arg_expr = arg_expr->next, varg_count++)
                func_call_sz += 8;
            break;
        }
        type_t arg_type = type_from_tk(arg->var_type);
        size_t arg_align = ALIGNOF_T(arg_type);
        func_call_sz = ALIGN(func_call_sz, arg_align);
        func_call_sz += SIZEOF_T(arg_type);
        if(arg_expr) arg_expr = arg_expr->next;
    }

    // Allocate the stack space for everything
    func_call_sz = ALIGN(func_call_sz, 16);
    if(func_call_sz)
        gen_alloc_stack(fptr, func_call_sz);
    stack_sz += func_call_sz;

    if(!func->type.ptr_depth && (func->type.data == DATA_STRUCT || func->type.data == DATA_UNION))
        gen_save_stack(fptr, free_reg(struct_ptr), 0);


    // Save each occupied register on the stack
    size_t arg_ptr = 0;
    for(int i = 0; i < n; i++){
        if(struct_ptr && masked_regs[i]->name == struct_ptr->name)
            continue;
        arg_ptr = ALIGN(arg_ptr, masked_regs[i]->size);
        arg_ptr += masked_regs[i]->size;
        gen_save_stack(fptr, masked_regs[i], func_call_sz - arg_ptr);
    }

    // Generate each argument
    arg_ptr = (func->type.ptr_depth || func->type.data == DATA_STRUCT || func->type.data == DATA_UNION) ? target_address_size : func->type.size;

    // We need to generate the "this" pointer if necessary
    if(method.data){
        arg_ptr = ALIGN(arg_ptr, target_address_size);
        reg_t* tmp = GET_FREE_REG(target_address_size);
        if(method.ptr_depth)
            tmp = generate_expr(fptr, expr->func.func->access.obj, method, NULL);
        else if(!get_expr_address(fptr, alloc_reg(tmp, false), expr->func.func->access.obj))
            return false;
        gen_save_stack(fptr, tmp, arg_ptr);
        (void) free_reg(tmp);
        arg_ptr += target_address_size;
    }

    arg_expr = expr->func.args;
    for(node_var_decl* arg = &func->args->var_decl; arg; arg = &arg->next->var_decl){
        node_expr* next_arg = NULL;

        // Variable arguments
        if(arg->type == tk_var_args){
            arg_ptr = ALIGN(arg_ptr, 8);
            if(((node_expr_stmt*)arg)->expr){
                reg_t* tmp = alloc_reg(GET_FREE_REG(8), false);
                gen_set_reg_raw(fptr, tmp, varg_count);
                gen_save_stack(fptr, tmp, arg_ptr);
                (void) free_reg(tmp);
                arg_ptr += 8;
            }

            // Go through each additional argument
            for(; arg_expr; arg_expr = next_arg){
                next_arg = arg_expr->next;
                type_t expr_type = typeof_expr(arg_expr);

                // Int value
                if(expr_type.ptr_depth || expr_type.data == DATA_INT){
                    reg_t* tmp = EXPR_ONCE(arg_expr, ((type_t){8, GET_DUMMY_TYPE(int64), true, DATA_INT, 8, 0}), NULL);
                    gen_save_stack(fptr, tmp, arg_ptr);
                }// Float value
                else if(expr_type.data == DATA_FLOAT){
                    if(!generate_float_expr(fptr, arg_expr))
                        fail_gen_expr(fptr);
                    gen_save_stack_float(fptr, arg_ptr, true);
                }// Other data types
                else{
                    print_context_expr("Unsupported variable argument type", arg_expr);
                    fail_gen_expr(fptr);
                }
                arg_ptr += 8;
            }
            break;
        }else if(!arg_expr || arg_expr->type == tk_nothing){
            if(arg_expr)
                next_arg = arg_expr->next;
            if(!arg->expr){
                print_context_expr("In function call here", expr);
                print_context("Missing argument and no default value", arg->identifier);
                fail_gen_expr(fptr);
            }
            arg_expr = arg->expr;
        }else if(arg_expr)
            next_arg = arg_expr->next;

        type_t expr_type = typeof_expr(arg_expr), arg_type = type_from_tk(arg->var_type);
        size_t arg_size = SIZEOF_T(arg_type), arg_align = ALIGNOF_T(arg_type);

        // If the argument isn't compatible
        if(!types_compatible(arg_type, expr_type)){
            print_context_expr("Incompatible argument type", arg_expr);
            print_context("Expected argument type", arg->var_type);
            print_type("Type ", expr_type, " is not compatible!");
            fail_gen_expr(fptr);
        }

        arg_ptr = ALIGN(arg_ptr, arg_align);
        if(arg_type.ptr_depth || arg_type.data == DATA_INT){
            reg_t* tmp = EXPR_ONCE(arg_expr, arg_type, NULL);
            gen_save_stack(fptr, tmp, arg_ptr);
        }else if(arg_type.data == DATA_FLOAT){
            if(!generate_float_expr(fptr, arg_expr))
                fail_gen_expr(fptr);
            gen_save_stack_float(fptr, arg_ptr, arg_type.size == 8);
        }else if(arg_type.data == DATA_STRUCT || arg_type.data == DATA_UNION){
            reg_t* tmp = alloc_reg(GET_MASK_REG(target_address_size, allowed_copy_regs), false);
            gen_load_stack_ptr(fptr, tmp, arg_ptr);
            if(arg_type.data == DATA_STRUCT){
                struct_t* stru = get_struct_tk(arg_type.repr);
                if(!save_struct(fptr, stru, tmp, arg_expr))
                    fail_gen_expr(fptr);
            }else{
                union_t* unio = get_union_tk(arg_type.repr);
                if(!save_union(fptr, unio, tmp, arg_expr))
                    fail_gen_expr(fptr);
            }
            (void) free_reg(tmp);
        }else{
            print_context_expr("Argument data type not implemented", arg_expr);
            fail_gen_expr(fptr);
        }
        arg_ptr += arg_size;

        arg_expr = next_arg;
    }

    if(arg_expr){
        print_context_expr("Too many arguments provided", arg_expr);
        fail_gen_expr(fptr);
    }

    // Call the function
    if(func->flags & FLAG_EXTERN)
        gen_call_extern_func(fptr, func->str, func->strlen);
    else if(method.data)
        gen_call_method(fptr, method.repr->str, method.repr->strlen, func->str, func->strlen);
    else if(module)
        gen_call_method(fptr, module->str, module->strlen, func->str, func->strlen);
    else
        gen_call_func(fptr, func->str, func->strlen);

    // Retrieve every register off the stack
    arg_ptr = 0;
    for(int i = 0; i < n; i++){
        if(struct_ptr && masked_regs[i]->name == struct_ptr->name) continue;
        arg_ptr = ALIGN(arg_ptr, masked_regs[i]->size);
        arg_ptr += masked_regs[i]->size;
        gen_load_stack(fptr, masked_regs[i], func_call_sz - arg_ptr);
    }
    return func_call_sz;
}

#define SIGNED_OP1(sign, n) ((sign) ? GET_ALLOWED_REGS1(s##n) : GET_ALLOWED_REGS1(n))
#define SIGNED_OP2(sign, n) ((sign) ? GET_ALLOWED_REGS2(s##n) : GET_ALLOWED_REGS2(n))
#define SIGNED_AFFECTED(sign, n) ((sign) ? GET_AFFECTED_REGS(s##n) : GET_AFFECTED_REGS(n))
reg_t* generate_expr(HC_FILE fptr, node_expr* expr, type_t target_type, reg_t* prefered){
    if(!target_type.data || !SIZEOF_T(target_type)){
        print_context_expr("Invalid target type", expr);
        print_type("Type ", target_type, (!target_type.data) ? " is invalid!" : " has a size of 0 bytes!");
        fail_gen_expr(fptr);
    }

    size_t sz = target_type.ptr_depth ? target_address_size : target_type.size;
    type_t expr_type = typeof_expr(expr);
    bool sign = target_type.ptr_depth ? false : target_type.sign;
    if(sign && !SIGNOF_T(expr_type))
        sign = false;
    if(prefered && !is_reg_free(prefered)) prefered = NULL;

    if(!expr_type.ptr_depth && expr_type.data == DATA_FLOAT){
        if(target_type.repr && target_type.repr->type == tk_bool){
            reg_t* tmp = alloc_reg(prefered ? prefered : GET_FREE_REG(1), sign);
            if(!generate_float_expr(fptr, expr))
                fail_gen_expr(fptr);
            gen_cmpz_float(fptr);
            gen_cond_set(fptr, tk_cmp_neq, tmp, false);
            return tmp;
        }else{
            reg_t* tmp = alloc_reg(prefered ? prefered : GET_FREE_REG(sz), sign);
            if(!generate_float_expr(fptr, expr))
                fail_gen_expr(fptr);
            gen_float_to_int(fptr, tmp);
            return tmp;
        }
    }else if(!expr_type.ptr_depth && (expr_type.data == DATA_STRUCT || expr_type.data == DATA_UNION)){
        print_context_expr("Expression cannot be evaluated as an integer", expr);
        fail_gen_expr(fptr);
    }

    // Buffer
    static reg_t* masked_regs[MAX_REGS];

    // Check if we can substitute the expression with
    // a compile-time evaluated integer value
    if(sign){
        int64_t result;
        if(eval_int_expr(expr, &result)){
            reg_t* tmp = alloc_reg(prefered ? prefered : GET_FREE_REG(sz), true);
            if(!result)
                gen_clear_reg(fptr, tmp);
            else
                gen_set_reg_raw(fptr, tmp, result);
            return tmp;
        }
    }else{
        uint64_t result;
        if(eval_uint_expr(expr, &result)){
            char buff[256];
            reg_t* tmp = alloc_reg(prefered ? prefered : GET_FREE_REG(sz), false);
            if(!result)
                gen_clear_reg(fptr, tmp);
            else
                gen_set_reg_raw(fptr, tmp, result);
            return tmp;
        }
    }

    switch(expr->type){
    case tk_reg_expr:
        return (reg_t*) expr->reg.reg;
    case tk_str_lit:{
        if(sz != target_address_size){
            print_context_ex("Cannot fit address into type with different size", expr->term.str, expr->term.strlen);
            print_type("Type ", target_type, " is not the right size");
            fail_gen_expr(fptr);
        }
        reg_t* tmp = alloc_reg(prefered ? prefered : GET_FREE_REG(sz), sign);
        gen_load_str_lit(fptr, tmp, append_string_literal(&expr->term));
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
    case tk_inc:
    case tk_dec:{
        reg_t* tmp = alloc_reg(prefered ? prefered : GET_FREE_REG(sz), sign);
        if(!inc_expr(fptr, expr->unary_op.lhs, tmp, true, expr->type == tk_inc))
            return false;
        return tmp;
    }
    case tk_post_inc:
    case tk_post_dec:{
        reg_t* tmp = alloc_reg(prefered ? prefered : GET_FREE_REG(sz), sign);
        if(!inc_expr(fptr, expr->unary_op.lhs, tmp, false, expr->type == tk_post_inc))
            return false;
        return tmp;
    }
#define ADD_LIKE_EXPR(n, m) \
    case n:{\
        int64_t cexpr = 0;\
        bool lc = false, rc = false;\
        if((lc = eval_int_expr(expr->bin_op.lhs, &cexpr)) || (rc = eval_int_expr(expr->bin_op.rhs, &cexpr))){\
            node_expr* c = lc ? expr->bin_op.rhs : expr->bin_op.lhs;\
            reg_t* tmp = generate_expr(fptr, c, target_type, prefered);\
            if(cexpr == 1 && (n == tk_add || n == tk_sub)) (n == tk_sub) ? gen_dec_reg(fptr, tmp) : gen_inc_reg(fptr, tmp);\
            else if(cexpr == -1 && (n == tk_add || n == tk_sub)) (n == tk_add) ? gen_dec_reg(fptr, tmp) : gen_inc_reg(fptr, tmp);\
            else gen_##m##_reg(fptr, tmp, cexpr);\
            return tmp;\
        }\
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
        int64_t cexpr;\
        bool lc = false, rc = false, _sign;\
        if(n == tk_mult && ((lc = eval_int_expr(expr->bin_op.lhs, &cexpr)) || (rc = eval_int_expr(expr->bin_op.rhs, &cexpr)))){\
            cexpr = (_sign = cexpr < 0) ? -cexpr : cexpr;\
            node_expr* c = lc ? expr->bin_op.rhs : expr->bin_op.lhs;\
            if(cexpr == 0){ reg_t* tmp = alloc_reg(prefered ? prefered : GET_FREE_REG(sz), sign); gen_clear_reg(fptr, tmp); return tmp; }\
            if(cexpr == 1){ reg_t* tmp = generate_expr(fptr, c, target_type, prefered); if(_sign) gen_neg_reg(fptr, tmp); return tmp; }\
            size_t i = 0; for(; (cexpr % 2 == 0) && cexpr > 1; cexpr /= 2, i++);\
            if(cexpr == 1){\
                reg_t* tmp = generate_expr(fptr, c, target_type, prefered); gen_shl_reg(fptr, tmp, i);\
                if(_sign) gen_neg_reg(fptr, tmp); return tmp;\
            }else if(cexpr == 3){\
                reg_t* tmp = generate_expr(fptr, c, target_type, prefered); if(i) gen_shl_reg(fptr, tmp, i);\
                gen_load_idx_ptr(fptr, tmp, tmp, tmp, 2);\
                if(_sign) gen_neg_reg(fptr, tmp); return tmp;\
            }else if(cexpr == 5){\
                reg_t* tmp = generate_expr(fptr, c, target_type, prefered); if(i) gen_shl_reg(fptr, tmp, i);\
                gen_load_idx_ptr(fptr, tmp, tmp, tmp, 4);\
                if(_sign) gen_neg_reg(fptr, tmp); return tmp;\
            }\
        }else if(n != tk_mult && eval_int_expr(expr->bin_op.rhs, &cexpr) && IS_POW2(ABS(cexpr))){\
            cexpr = (_sign = cexpr < 0) ? -cexpr : cexpr;\
            if(cexpr == 0){ print_context_expr("Division by zero", expr->bin_op.rhs); fail_gen_expr(fptr); }\
            if(cexpr == 1) return generate_expr(fptr, expr->bin_op.lhs, target_type, prefered);\
            reg_t* tmp = generate_expr(fptr, expr->bin_op.lhs, target_type, prefered);\
            if(n == tk_div){\
                size_t i = 0; for(; cexpr > 1; cexpr /= 2, i++);\
                (sign) ? gen_sshr_reg(fptr, tmp, i) : gen_shr_reg(fptr, tmp, i);\
            }else\
                gen_and_reg(fptr, tmp, cexpr - 1);\
            if(_sign) gen_neg_reg(fptr, tmp);\
            return tmp;\
        }\
        reg_mask op1 = SIGNED_OP1(sign, m), op2 = SIGNED_OP2(sign, m), affected = SIGNED_AFFECTED(sign, m);\
        reg_t* tmp1 = generate_expr(fptr, expr->bin_op.lhs, target_type, (prefered && REG_IN_MASK(prefered, op1)) ? prefered : GET_MASK_REG(sz, op1));\
        reg_t* tmp2 = generate_expr(fptr, expr->bin_op.rhs, target_type, GET_MASK_REG(sz, op2));\
        reg_t* replacements[MAX_REGS];\
        int n = get_mask_occup_regs(affected, true, registers, masked_regs);\
        for(int i = 0; i < n; i++)\
            replacements[i] = transfer_reg(fptr, masked_regs[i], GET_MASK_REG(masked_regs[i]->size, ALL_REGS_EXCEPT(affected)));\
        if(!REG_IN_MASK(tmp1, op1)){\
            reg_t* tmp3 = GET_OCC_MASK_REG(sz, op1);\
            reg_t* tmp4 = GET_MASK_REG(sz, ALL_REGS_EXCEPT(affected));\
            if(!tmp3) tmp3 = GET_MASK_REG(sz, op1), tmp4 = NULL;\
            (void) transfer_reg(fptr, tmp3, tmp4);\
            (void) transfer_reg(fptr, tmp1, tmp3);\
            (sign) ? gen_s##m##_regs(fptr, tmp3, tmp2) : gen_##m##_regs(fptr, tmp3, tmp2);\
            (void) transfer_reg(fptr, tmp3, tmp1);\
            (void) transfer_reg(fptr, tmp4, tmp3);\
            (void) free_reg(tmp2);\
            for(int i = 0; i < n; i++)\
                (void) transfer_reg(fptr, replacements[i], masked_regs[i]);\
            return tmp1;\
        }else if(!REG_IN_MASK(tmp2, op2)){\
            reg_t* tmp3 = GET_OCC_MASK_REG(sz, op2);\
            reg_t* tmp4 = GET_MASK_REG(sz, ALL_REGS_EXCEPT(affected));\
            if(!tmp3) tmp3 = GET_MASK_REG(sz, op2), tmp4 = NULL;\
            (void) transfer_reg(fptr, tmp3, tmp4);\
            (void) transfer_reg(fptr, tmp2, tmp3);\
            (sign) ? gen_s##m##_regs(fptr, tmp1, tmp3) : gen_##m##_regs(fptr, tmp1, tmp3);\
            (void) transfer_reg(fptr, tmp4, tmp3);\
            (void) free_reg(tmp2);\
            for(int i = 0; i < n; i++)\
                (void) transfer_reg(fptr, replacements[i], masked_regs[i]);\
            return tmp1;\
        }\
        (sign) ? gen_s##m##_regs(fptr, tmp1, tmp2) : gen_##m##_regs(fptr, tmp1, tmp2);\
        (void) free_reg(tmp2);\
        for(int i = 0; i < n; i++)\
            (void) transfer_reg(fptr, replacements[i], masked_regs[i]);\
        return tmp1;\
    }
    MULT_LIKE_EXPR(tk_mult, mul)
    MULT_LIKE_EXPR(tk_div, div)
    MULT_LIKE_EXPR(tk_mod, mod)
    case tk_shl:
    case tk_shr:{
        int64_t i = 0;
        if(eval_int_expr(expr->bin_op.rhs, &i)){
            if(i < 0){ print_context_expr("Cannot shift negative bits left / right", expr->bin_op.rhs); fail_gen_expr(fptr); }
            if(i == 0){ reg_t* tmp = alloc_reg(prefered ? prefered : GET_FREE_REG(sz), sign); gen_clear_reg(fptr, tmp); return tmp; }
            reg_t* tmp = generate_expr(fptr, expr->bin_op.lhs, target_type, prefered);
            if(expr->type == tk_shl) gen_shl_reg(fptr, tmp, i);
            else if(sign) gen_sshr_reg(fptr, tmp, i);
            else gen_shr_reg(fptr, tmp, i);
            return tmp;
        }

        reg_mask lhs, rhs;
        if(expr->type == tk_shl) lhs = GET_ALLOWED_REGS1(shl), rhs = GET_ALLOWED_REGS2(shl);
        else lhs = SIGNED_OP1(sign, shr), rhs = SIGNED_OP2(sign, shr);
        reg_t* tmp1 = generate_expr(fptr, expr->bin_op.lhs, target_type, (prefered && REG_IN_MASK(prefered, lhs)) ? prefered : GET_MASK_REG(sz, lhs));
        reg_t* tmp2 = generate_expr(fptr, expr->bin_op.rhs, (type_t){1, GET_DUMMY_TYPE(uint8), false, DATA_INT, 1, 0}, GET_MASK_REG(1, rhs));
        if(!REG_IN_MASK(tmp2, rhs)){
            reg_t* tmp3 = GET_OCC_MASK_REG(1, rhs);
            reg_t* tmp4 = GET_FREE_REG(1);
            (void) transfer_reg(fptr, tmp3, tmp4);
            (void) transfer_reg(fptr, tmp2, tmp3);
            if(expr->type == tk_shl) gen_shl_regs(fptr, tmp1, tmp3);
            else if(sign) gen_sshr_regs(fptr, tmp1, tmp3);
            else gen_shr_regs(fptr, tmp1, tmp3);
            (void) transfer_reg(fptr, tmp4, tmp3);
            return tmp1;
        }
        if(expr->type == tk_shl) gen_shl_regs(fptr, tmp1, tmp2);
        else if(sign) gen_sshr_regs(fptr, tmp1, tmp2);
        else gen_shr_regs(fptr, tmp1, tmp2);
        (void) free_reg(tmp2);
        return tmp1;
    }
    case tk_not:{
        reg_t* tmp2 = alloc_reg((prefered && prefered->size == 1) ? prefered : GET_FREE_REG(1), sign);
        reg_t* tmp1 = generate_expr(fptr, expr->unary_op.lhs, typeof_expr(expr->unary_op.lhs), NULL);
        gen_cmpz_reg(fptr, tmp1);
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
        reg_t* tmp1 = NULL;
        if(!t.repr || t.repr->type != tk_bool){
            if(t.ptr_depth || t.data == DATA_INT){
                tmp1 = generate_expr(fptr, expr->bin_op.lhs, t, NULL);
                reg_t* tmp2 = alloc_reg(GET_FREE_REG(1), sign);
                gen_cmpz_reg(fptr, tmp1);
                gen_cond_set(fptr, tk_cmp_neq, tmp2, false);
                (void) free_reg(tmp1);
                tmp1 = tmp2;
            }else if(t.data == DATA_FLOAT){
                tmp1 = alloc_reg(prefered ? prefered : GET_FREE_REG(1), sign);
                if(!generate_float_expr(fptr, expr->bin_op.lhs))
                    fail_gen_expr(fptr);
                gen_cmpz_float(fptr);
                gen_cond_set(fptr, tk_cmp_neq, tmp1, false);
            }
        }else{
            tmp1 = generate_expr(fptr, expr->bin_op.lhs, t, (prefered && prefered->size == 1) ? prefered : NULL);
            gen_cmpz_reg(fptr, tmp1);
        }
        if(expr->type == tk_and)
            gen_cond_jump(fptr, tk_cmp_eq, skip_label, false);
        else
            gen_cond_jump(fptr, tk_cmp_neq, skip_label, false);
        t = typeof_expr(expr->bin_op.rhs);
        if(!t.repr || t.repr->type != tk_bool){
            if(t.ptr_depth || t.data == DATA_INT){
                reg_t* tmp2 = generate_expr(fptr, expr->bin_op.rhs, t, NULL);
                gen_cmpz_reg(fptr, tmp2);
                gen_cond_set(fptr, tk_cmp_neq, tmp1, false);
                (void) free_reg(tmp2);
                tmp2 = tmp1;
            }else if(t.data == DATA_FLOAT){
                if(!generate_float_expr(fptr, expr->bin_op.rhs))
                    fail_gen_expr(fptr);
                gen_cmpz_float(fptr);
                gen_cond_set(fptr, tk_cmp_neq, tmp1, false);
            }
        }else{
            (void) free_reg(tmp1);
            generate_expr(fptr, expr->bin_op.rhs, t, tmp1);
        }
        gen_label(fptr, skip_label);
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
        if(!types_compatible(t1, t2)){
            print_context_expr("Cannot compare two values of incompatible types", expr);
            fail_gen_expr(fptr);
        }
        type_t biggest_t = (DATAOF_T(t1) > DATAOF_T(t2) || SIZEOF_T(t1) > SIZEOF_T(t2)) ? t1 : t2;
        reg_t* tmp = alloc_reg((prefered && prefered->size == 1) ? prefered : NULL, sign);
        if(biggest_t.ptr_depth || biggest_t.data == DATA_INT){
            reg_t *lhs = generate_expr(fptr, expr->bin_op.lhs, biggest_t, NULL), *rhs = generate_expr(fptr, expr->bin_op.rhs, biggest_t, NULL);
            gen_compare(fptr, lhs, rhs);
            (void) free_reg(lhs);
            (void) free_reg(rhs);
        }else if(biggest_t.data == DATA_FLOAT){
            t1.sign = t2.sign = false;
            if(!generate_float_expr(fptr, expr->bin_op.rhs) || !generate_float_expr(fptr, expr->bin_op.lhs))
                fail_gen_expr(fptr);
            gen_cmp_floats(fptr);
        }else{
            print_context_expr("Cannot compare things other than ints / floats", expr);
            fail_gen_expr(fptr);
        }
        if(!tmp) tmp = alloc_reg(GET_FREE_REG(1), sign);
        gen_cond_set(fptr, expr->type, tmp, t1.sign || t2.sign);
        if(sz != 1)
            tmp = transfer_reg(fptr, tmp, (prefered && is_reg_free(prefered)) ? prefered : GET_FREE_REG(sz));
        return tmp;
    }
    case tk_cmp_approx:{
        var_t* FP_PRECISION = get_var("FP_PRECISION", 12);
        if(!FP_PRECISION){
            print_context_expr("Missing FP_PRECISION global variable.", expr);
            HC_WARN("FP_PRECISION must be a declared global variable containing the max difference between two numbers approximately equal.");
            fail_gen_expr(fptr);
        }
        if(DATAOF_T(FP_PRECISION->type) != DATA_FLOAT || FP_PRECISION->type.size != 8){
            print_context_ex("FP_PRECISION must be of type double.", FP_PRECISION->str, FP_PRECISION->strlen);
            fail_gen_expr(fptr);
        }
        type_t t1 = typeof_expr(expr->bin_op.lhs), t2 = typeof_expr(expr->bin_op.rhs);
        if(!t1.data || !t2.data || t1.ptr_depth || t1.data != DATA_FLOAT || t2.ptr_depth || t2.data != DATA_FLOAT){
            print_context_expr("Cannot compare approximately values that are not floats", expr);
            fail_gen_expr(fptr);
        }
        if(!generate_float_expr(fptr, expr->bin_op.rhs) || !generate_float_expr(fptr, expr->bin_op.lhs))
            return false;
        gen_cmp_approx_floats(fptr);
        reg_t* tmp = alloc_reg((prefered && prefered->size == 1) ? prefered : GET_FREE_REG(1), sign);
        gen_cond_set(fptr, tk_cmp_ge, tmp, false);
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
        if(!get_expr_address(fptr, tmp, expr->unary_op.lhs))
            fail_gen_expr(fptr);
        return tmp;
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
        reg_t* idx = generate_expr(fptr, expr->bin_op.rhs, (type_t){8, GET_DUMMY_TYPE(uint64), false, DATA_INT, 8, 0}, NULL);
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
    case tk_dot:{
        if(expr->access.obj->type == tk_identifier){
            module_t* mod = get_module(expr->access.obj->term.str, expr->access.obj->term.strlen);
            if(mod){
                var_t* var = get_module_var(mod, expr->access.member->str, expr->access.member->strlen);
                if(!var){
                    print_context("Unknown variable in module", expr->access.member);
                    fail_gen_expr(fptr);
                }
                if(!check_module_private(var->flags, mod, expr->access.member, true))
                    fail_gen_expr(fptr);
                reg_t* tmp = alloc_reg(prefered ? prefered : GET_FREE_REG(sz), sign);
                if(SIZEOF_T(var->type) < sz)
                    gen_loadx_global_offset(fptr, tmp, mod->str, mod->strlen, var->stack_ptr, var->type.size, sign);
                else if(var->location == VAR_ARRAY)
                    gen_load_global_offset_ptr(fptr, tmp, mod->str, mod->strlen, var->stack_ptr);
                else
                    gen_load_global_offset(fptr, tmp, mod->str, mod->strlen, var->stack_ptr);
                return tmp;
            }
        }

        type_t obj_type = typeof_expr(expr->access.obj);
        if(obj_type.ptr_depth > 1 || (obj_type.data != DATA_STRUCT && obj_type.data != DATA_UNION)){
            print_context_expr("Expected structure / class / union", expr->access.obj);
            fail_gen_expr(fptr);
        }
        if(obj_type.data == DATA_STRUCT){
            struct_t* stru = get_struct_tk(obj_type.repr);
            var_t* member = get_member(stru, expr->access.member->str, expr->access.member->strlen);
            if(!member)
                fail_gen_expr(fptr);

            if(!check_private(member->flags, stru, expr, false))
                fail_gen_expr(fptr);

            if(member->location == VAR_ARRAY && sz != target_address_size){
                print_context_expr("Cannot store address (array pointer) in smaller type", expr);
                fail_gen_expr(fptr);
            }
            reg_t* tmp = alloc_reg(prefered ? prefered : GET_FREE_REG(sz), sign);
            if(obj_type.ptr_depth || expr->access.obj->type == tk_deref || expr->access.obj->type == tk_open_bracket || expr->access.obj->type == tk_dot){
                reg_t* ptr;
                if(obj_type.ptr_depth)
                    ptr = generate_expr(fptr, expr->access.obj, obj_type, NULL);
                else if(expr->access.obj->type == tk_deref){
                    obj_type.ptr_depth++;
                    ptr = generate_expr(fptr, expr->access.obj->unary_op.lhs, obj_type, NULL);
                }else if(expr->access.obj->type == tk_open_bracket){
                    ptr = alloc_reg(GET_FREE_REG(target_address_size), false);
                    obj_type.ptr_depth++;
                    reg_t* arr = generate_expr(fptr, expr->access.obj->bin_op.lhs, obj_type, NULL);
                    reg_t* idx = generate_expr(fptr, expr->access.obj->bin_op.rhs, (type_t){8, GET_DUMMY_TYPE(uint64), false, DATA_INT, 8, 0}, NULL);
                    gen_load_idx_ptr(fptr, ptr, arr, idx, obj_type.size);
                    (void) free_reg(arr);
                    (void) free_reg(idx);
                }else if(expr->access.obj->type == tk_dot){
                    ptr = alloc_reg(GET_FREE_REG(target_address_size), false);
                    if(!get_expr_address(fptr, ptr, expr->access.obj))
                        fail_gen_expr(fptr);
                }
                if(SIZEOF_T(member->type) < sz)
                    gen_loadx_offset(fptr, tmp, ptr, member->stack_ptr, SIZEOF_T(member->type), sign);
                else if(member->location == VAR_ARRAY)
                    gen_load_offset_ptr(fptr, tmp, ptr, member->stack_ptr);
                else
                    gen_load_offset(fptr, tmp, ptr, member->stack_ptr);
                (void) free_reg(ptr);
                return tmp;
            }else if(expr->access.obj->type == tk_identifier){
                var_t* var = get_var(expr->access.obj->term.str, expr->access.obj->term.strlen);
                if(SIZEOF_T(member->type) < sz){
                    if(var->location == VAR_STACK || var->location == VAR_ARRAY)
                        gen_loadx_stack(fptr, tmp, stack_sz - var->stack_ptr + member->stack_ptr, SIZEOF_T(member->type), sign);
                    else if(var->location == VAR_GLOBAL || var->location == VAR_GLOBAL_ARR)
                        gen_loadx_global_offset(fptr, tmp, var->str, var->strlen, member->stack_ptr, SIZEOF_T(member->type), sign);
                    else if(var->location == VAR_ARG)
                        gen_loadx_arg(fptr, tmp, var->stack_ptr + member->stack_ptr, SIZEOF_T(member->type), sign);
                }else if(member->location == VAR_ARRAY){
                    if(var->location == VAR_STACK || var->location == VAR_ARRAY)
                        gen_load_stack_ptr(fptr, tmp, stack_sz - var->stack_ptr + member->stack_ptr);
                    else if(var->location == VAR_GLOBAL || var->location == VAR_GLOBAL_ARR)
                        gen_load_global_offset_ptr(fptr, tmp, var->str, var->strlen, member->stack_ptr);
                    else if(var->location == VAR_ARG)
                        gen_load_arg_ptr(fptr, tmp, var->stack_ptr + member->stack_ptr);
                }else{
                    if(var->location == VAR_STACK || var->location == VAR_ARRAY)
                        gen_load_stack(fptr, tmp, stack_sz - var->stack_ptr + member->stack_ptr);
                    else if(var->location == VAR_GLOBAL || var->location == VAR_GLOBAL_ARR)
                        gen_load_global_offset(fptr, tmp, var->str, var->strlen, member->stack_ptr);
                    else if(var->location == VAR_ARG)
                        gen_load_arg(fptr, tmp, var->stack_ptr + member->stack_ptr);
                }
                return tmp;
            }else{
                print_context_expr("Not implemented yet", expr);
                fail_gen_expr(fptr);
            }
        }else if(obj_type.data == DATA_UNION){
            union_t* unio = get_union_tk(obj_type.repr);
            reg_t* tmp = alloc_reg(prefered ? prefered : GET_FREE_REG(sz), sign);

            if(unio->is_variant && expr->access.member->strlen == 4 && strncmp(expr->access.member->str, "type", 4) == 0){
                reg_t* ptr;
                if(obj_type.ptr_depth)
                    ptr = generate_expr(fptr, expr->access.obj, obj_type, NULL);
                else{
                    ptr = alloc_reg(GET_FREE_REG(target_address_size), false);
                    if(!get_expr_address(fptr, ptr, expr->access.obj))
                        fail_gen_expr(fptr);
                }
                if(sz <= unio->align)
                    gen_load_offset(fptr, tmp, ptr, unio->size - unio->align);
                else
                    gen_loadx_offset(fptr, tmp, ptr, unio->size - unio->align, unio->align, false);
                (void) free_reg(ptr);
                return tmp;
            }

            node_stmt* member = get_union_member(unio, expr->access.member->str, expr->access.member->strlen);
            if(!member)
                fail_gen_expr(fptr);

            type_t member_type;
            if(member->type == tk_var_decl) member_type = type_from_tk(member->var_decl.var_type);
            else if(sz != target_address_size){
                print_context_expr("Cannot store address (array pointer) in smaller type", expr);
                fail_gen_expr(fptr);
            }else{
                member_type = type_from_tk(member->arr_decl.elem_type);
                member_type.repr++;
            }

            if(obj_type.ptr_depth || expr->access.obj->type == tk_deref || expr->access.obj->type == tk_open_bracket || expr->access.obj->type == tk_dot){
                reg_t* ptr;
                if(obj_type.ptr_depth)
                    ptr = generate_expr(fptr, expr->access.obj, obj_type, NULL);
                else if(expr->access.obj->type == tk_deref){
                    obj_type.ptr_depth++;
                    ptr = generate_expr(fptr, expr->access.obj->unary_op.lhs, obj_type, NULL);
                }else if(expr->access.obj->type == tk_open_bracket){
                    ptr = alloc_reg(GET_FREE_REG(target_address_size), false);
                    obj_type.ptr_depth++;
                    reg_t* arr = generate_expr(fptr, expr->access.obj->bin_op.lhs, obj_type, NULL);
                    reg_t* idx = generate_expr(fptr, expr->access.obj->bin_op.rhs, (type_t){8, GET_DUMMY_TYPE(uint64), false, DATA_INT, 8, 0}, NULL);
                    gen_load_idx_ptr(fptr, ptr, arr, idx, obj_type.size);
                    (void) free_reg(arr);
                    (void) free_reg(idx);
                }else if(expr->access.obj->type == tk_dot){
                    ptr = alloc_reg(GET_FREE_REG(target_address_size), false);
                    if(!get_expr_address(fptr, ptr, expr->access.obj))
                        fail_gen_expr(fptr);
                }
                if(SIZEOF_T(member_type) < sz)
                    gen_loadx_ptr(fptr, tmp, ptr, SIZEOF_T(member_type), sign);
                else if(member->type == tk_arr_decl)
                    gen_move_reg(fptr, ptr, tmp);
                else
                    gen_load_ptr(fptr, tmp, ptr);
                (void) free_reg(ptr);
                return tmp;
            }else if(expr->access.obj->type == tk_identifier){
                var_t* var = get_var(expr->access.obj->term.str, expr->access.obj->term.strlen);
                if(SIZEOF_T(member_type) < sz){
                    if(var->location == VAR_STACK || var->location == VAR_ARRAY)
                        gen_loadx_stack(fptr, tmp, stack_sz - var->stack_ptr, SIZEOF_T(member_type), sign);
                    else if(var->location == VAR_GLOBAL || var->location == VAR_GLOBAL_ARR)
                        gen_loadx_global(fptr, tmp, var->str, var->strlen, SIZEOF_T(member_type), sign);
                    else if(var->location == VAR_ARG)
                        gen_loadx_arg(fptr, tmp, var->stack_ptr, SIZEOF_T(member_type), sign);
                }else if(member->type == tk_arr_decl){
                    if(var->location == VAR_STACK || var->location == VAR_ARRAY)
                        gen_load_stack_ptr(fptr, tmp, stack_sz - var->stack_ptr);
                    else if(var->location == VAR_GLOBAL || var->location == VAR_GLOBAL_ARR)
                        gen_load_global_ptr(fptr, tmp, var->str, var->strlen);
                    else if(var->location == VAR_ARG)
                        gen_load_arg_ptr(fptr, tmp, var->stack_ptr);
                }else{
                    if(var->location == VAR_STACK || var->location == VAR_ARRAY)
                        gen_load_stack(fptr, tmp, stack_sz - var->stack_ptr);
                    else if(var->location == VAR_GLOBAL || var->location == VAR_GLOBAL_ARR)
                        gen_load_global(fptr, tmp, var->str, var->strlen);
                    else if(var->location == VAR_ARG)
                        gen_load_arg(fptr, tmp, var->stack_ptr);
                }
                return tmp;
            }else{
                print_context_expr("Not implemented yet", expr);
                fail_gen_expr(fptr);
            }
        }
    }
    case tk_type_cast:{
        type_t cast_type = type_from_tk(expr->type_cast.lhs->start);
        size_t cast_size = SIZEOF_T(cast_type);
        short cast_data = DATAOF_T(cast_type);
        if(cast_data == DATA_FLOAT){
            if(!generate_float_expr(fptr, expr->type_cast.rhs))
                fail_gen_expr(fptr);
            reg_t* tmp = alloc_reg(prefered ? prefered : GET_FREE_REG(sz), sign);
            gen_float_to_int(fptr, tmp);
            return tmp;
        }
        if(sz == cast_size){
            reg_t* tmp = generate_expr(fptr, expr->type_cast.rhs, cast_type, prefered);
            if(sign == SIGNOF_T(cast_type))
                tmp->occupied = (sign) ? OCCUP_SIGNED : OCCUP_UNSIGNED;
            return tmp;
        }else if(sz > cast_size){
            reg_t* tmp2 = alloc_reg(prefered, sign);
            reg_t* tmp1 = generate_expr(fptr, expr->type_cast.rhs, cast_type, NULL);
            if(!tmp2) tmp2 = alloc_reg(GET_FREE_REG(sz), sign);
            return transfer_reg(fptr, tmp1, tmp2);
        }else{
            reg_t* tmp = generate_expr(fptr, expr->type_cast.rhs, cast_type, NULL);
            return get_lower_nbytes(fptr, tmp, sz);
        }
    }
    case tk_func_call:{
        func_t* func = NULL;
        size_t func_call_sz = generate_func_call(fptr, expr, &func, NULL);

        // Get the return value
        size_t return_sz = SIZEOF_T(func->type);
        reg_t* tmp = alloc_reg(prefered ? prefered : GET_FREE_REG(sz), sign);
        if(return_sz && sz <= return_sz)
            gen_load_stack(fptr, tmp, 0);
        else if(return_sz)
            gen_loadx_stack(fptr, tmp, 0, return_sz, sign);

        // Deallocate the stack space of the function
        if(func_call_sz)
            gen_dealloc_stack(fptr, func_call_sz);
        stack_sz -= func_call_sz;
        return tmp;
    }
    case tk_sizeof:
        print_context_expr("Size cannot be determined", expr);
        fail_gen_expr(fptr);
    case tk_ternary:{
        size_t other_label = label_count++, end_label = label_count++;
        reg_t* tmp = alloc_reg(prefered ? prefered : GET_FREE_REG(sz), sign);
        reg_t* cond = generate_expr(fptr, expr->ternary.cond, (type_t){1, GET_DUMMY_TYPE(bool), false, DATA_INT, 1, 0}, NULL);
        (void) free_reg(tmp);
        gen_cmpz_reg(fptr, cond);
        gen_cond_jump(fptr, tk_cmp_eq, other_label, false);
        (void) free_reg(cond);
        tmp = generate_expr(fptr, expr->ternary.lhs, target_type, tmp);
        (void) free_reg(tmp);
        gen_jump(fptr, end_label);
        gen_label(fptr, other_label);
        tmp = generate_expr(fptr, expr->ternary.rhs, target_type, tmp);
        gen_label(fptr, end_label);
        return tmp;
    }
    // NOT WORTH IT AT THE MOMENT
    /*case tk_stack_alloc:{
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
    }*/
    }
    print_context_expr("Expression type not implemented", expr);
    fail_gen_expr(fptr);
    return NULL;
}

// Floating point expressions
bool generate_float_expr(HC_FILE fptr, node_expr* expr){
    type_t expr_type = typeof_expr(expr);
    if(!expr_type.data){
        print_context_expr("Expression of invalid type", expr);
        return false;
    }else if(!expr_type.ptr_depth && expr_type.data == DATA_INT){
        reg_t* tmp = EXPR_ONCE(expr, ((type_t){8, GET_DUMMY_TYPE(int64), true, DATA_INT, 8, 0}), NULL);
        gen_int_to_float(fptr, tmp);
        return true;
    }else if(expr_type.data != DATA_FLOAT){
        print_type("Cannot convert type ",expr_type," to float");
        print_context_expr("Cannot convert expression to float", expr);
        return false;
    }

    // Compile-time evaluation
    if(expr->type != tk_float_lit){
        double result;
        if(eval_float_expr(expr, &result)){
            gen_load_float_raw(fptr, result);
            return true;
        }
    }

    switch(expr->type){
    case tk_float_lit:
        gen_load_float(fptr, append_float_literal(&expr->term));
        break;
    case tk_identifier:{
        var_t* var = get_var(expr->term.str, expr->term.strlen);
        if(var->location == VAR_STACK)
            gen_load_stack_float(fptr, stack_sz - var->stack_ptr, var->type.size == 8);
        else if(var->location == VAR_ARG)
            gen_load_arg_float(fptr, var->stack_ptr, var->type.size == 8);
        else if(var->location == VAR_GLOBAL)
            gen_load_global_float(fptr, var->str, var->strlen, var->type.size == 8);
        else{
            print_context_ex("Not implemented", expr->term.str, expr->term.strlen);
            return false;
        }
        break;
    }case tk_neg:
        if(!generate_float_expr(fptr, expr->unary_op.lhs))
            return false;
        gen_neg_float(fptr);
        break;
    case tk_add:
    case tk_sub:
    case tk_mult:
    case tk_div:
    case tk_mod:
        if(!generate_float_expr(fptr, expr->bin_op.lhs) || !generate_float_expr(fptr, expr->bin_op.rhs))
            return false;
        if(expr->type == tk_add)
            gen_add_floats(fptr);
        else if(expr->type == tk_sub)
            gen_sub_floats(fptr);
        else if(expr->type == tk_mult)
            gen_mul_floats(fptr);
        else if(expr->type == tk_mod)
            gen_mod_floats(fptr);
        else
            gen_div_floats(fptr);
        break;
    case tk_deref:{
        expr_type.ptr_depth++;
        reg_t* ptr = EXPR_ONCE(expr->unary_op.lhs, expr_type, NULL);
        gen_load_ptr_float(fptr, ptr, expr_type.size == 8);
        break;
    }
    case tk_open_bracket:{
        expr_type.ptr_depth++;
        reg_t* ptr = generate_expr(fptr, expr->bin_op.lhs, expr_type, NULL);
        reg_t* idx = generate_expr(fptr, expr->bin_op.rhs, (type_t){8, GET_DUMMY_TYPE(uint64), false, DATA_INT, 8, 0}, NULL);
        gen_load_idx_float(fptr, ptr, idx, expr_type.size, expr_type.size == 8);
        (void) free_reg(ptr);
        (void) free_reg(idx);
        break;
    }
    case tk_type_cast:
        return generate_float_expr(fptr, expr->type_cast.rhs);
    case tk_func_call:{
        func_t* func = NULL;
        size_t func_call_sz = generate_func_call(fptr, expr, &func, NULL);

        gen_load_stack_float(fptr, 0, expr_type.size == 8);

        if(func_call_sz)
            gen_dealloc_stack(fptr, func_call_sz);
        stack_sz -= func_call_sz;
        break;
    }case tk_dot:{
        if(expr->access.obj->type == tk_identifier){
            module_t* mod = get_module(expr->access.obj->term.str, expr->access.obj->term.strlen);
            if(mod){
                var_t* var = get_module_var(mod, expr->access.member->str, expr->access.member->strlen);
                if(!var){
                    print_context("Unknown variable in module", expr->access.member);
                    return false;
                }
                if(var->location != VAR_STACK){
                    print_context("Cannot give value to array, array is the address itself", expr->access.member);
                    return false;
                }
                if(!check_module_private(var->flags, mod, expr->access.member, true))
                    return false;
                gen_load_global_offset_float(fptr, mod->str, mod->strlen, var->stack_ptr, var->type.size == 8);
            }
        }

        type_t obj_type = typeof_expr(expr->access.obj);
        if(obj_type.ptr_depth > 1 || (obj_type.data != DATA_STRUCT && obj_type.data != DATA_UNION)){
            print_context_expr("Expected structure / class / union", expr->access.obj);
            fail_gen_expr(fptr);
        }
        if(obj_type.data == DATA_STRUCT){
            struct_t* stru = get_struct_tk(obj_type.repr);
            var_t* member = get_member(stru, expr->access.member->str, expr->access.member->strlen);
            if(!check_private(member->flags, stru, expr, false))
                return false;
            if(obj_type.ptr_depth || expr->access.obj->type == tk_deref || expr->access.obj->type == tk_open_bracket || expr->access.obj->type == tk_dot){
                reg_t* ptr;
                if(obj_type.ptr_depth)
                    ptr = generate_expr(fptr, expr->access.obj, obj_type, NULL);
                else if(expr->access.obj->type == tk_deref){
                    obj_type.ptr_depth++;
                    ptr = generate_expr(fptr, expr->access.obj->unary_op.lhs, obj_type, NULL);
                }else if(expr->access.obj->type == tk_open_bracket){
                    ptr = alloc_reg(GET_FREE_REG(target_address_size), false);
                    obj_type.ptr_depth++;
                    reg_t* arr = generate_expr(fptr, expr->access.obj->bin_op.lhs, obj_type, NULL);
                    reg_t* idx = generate_expr(fptr, expr->access.obj->bin_op.rhs, (type_t){8, GET_DUMMY_TYPE(uint64), false, DATA_INT, 8, 0}, NULL);
                    gen_load_idx_ptr(fptr, ptr, arr, idx, obj_type.size);
                    (void) free_reg(arr);
                    (void) free_reg(idx);
                }else if(expr->access.obj->type == tk_dot){
                    ptr = alloc_reg(GET_FREE_REG(target_address_size), false);
                    if(!get_expr_address(fptr, ptr, expr->access.obj))
                        return false;
                }
                gen_load_offset_float(fptr, ptr, member->stack_ptr, member->type.size == 8);
                (void) free_reg(ptr);
            }else if(expr->access.obj->type == tk_identifier){
                var_t* var = get_var(expr->access.obj->term.str, expr->access.obj->term.strlen);
                if(var->location == VAR_STACK)
                    gen_load_stack_float(fptr, stack_sz - var->stack_ptr + member->stack_ptr, member->type.size == 8);
                else if(var->location == VAR_GLOBAL)
                    gen_load_global_offset_float(fptr, var->str, var->strlen, member->stack_ptr, member->type.size == 8);
                else if(var->location == VAR_ARG)
                    gen_load_arg_float(fptr, var->stack_ptr + member->stack_ptr, member->type.size == 8);
            }else{
                print_context_expr("Not implemented yet", expr);
                return false;
            }
            return true;
        }else if(obj_type.data == DATA_UNION){
            union_t* unio = get_union_tk(obj_type.repr);
            node_stmt* member = get_union_member(unio, expr->access.member->str, expr->access.member->strlen);
            type_t member_type;
            member_type = type_from_tk(member->var_decl.var_type);
            if(obj_type.ptr_depth || expr->access.obj->type == tk_deref || expr->access.obj->type == tk_open_bracket || expr->access.obj->type == tk_dot){
                reg_t* ptr;
                if(obj_type.ptr_depth)
                    ptr = generate_expr(fptr, expr->access.obj, obj_type, NULL);
                else if(expr->access.obj->type == tk_deref){
                    obj_type.ptr_depth++;
                    ptr = generate_expr(fptr, expr->access.obj->unary_op.lhs, obj_type, NULL);
                }else if(expr->access.obj->type == tk_open_bracket){
                    ptr = alloc_reg(GET_FREE_REG(target_address_size), false);
                    obj_type.ptr_depth++;
                    reg_t* arr = generate_expr(fptr, expr->access.obj->bin_op.lhs, obj_type, NULL);
                    reg_t* idx = generate_expr(fptr, expr->access.obj->bin_op.rhs, (type_t){8, GET_DUMMY_TYPE(uint64), false, DATA_INT, 8, 0}, NULL);
                    gen_load_idx_ptr(fptr, ptr, arr, idx, obj_type.size);
                    (void) free_reg(arr);
                    (void) free_reg(idx);
                }else if(expr->access.obj->type == tk_dot){
                    ptr = alloc_reg(GET_FREE_REG(target_address_size), false);
                    if(!get_expr_address(fptr, ptr, expr->access.obj))
                        return false;
                }
                gen_load_ptr_float(fptr, ptr, member_type.size == 8);
                (void) free_reg(ptr);
                return true;
            }else if(expr->access.obj->type == tk_identifier){
                var_t* var = get_var(expr->access.obj->term.str, expr->access.obj->term.strlen);
                if(var->location == VAR_STACK || var->location == VAR_ARRAY)
                    gen_load_stack_float(fptr, stack_sz - var->stack_ptr, member_type.size == 8);
                else if(var->location == VAR_GLOBAL || var->location == VAR_GLOBAL_ARR)
                    gen_load_global_float(fptr, var->str, var->strlen, member_type.size == 8);
                else if(var->location == VAR_ARG)
                    gen_load_arg_float(fptr, var->stack_ptr, member_type.size == 8);
                return true;
            }else{
                print_context_expr("Not implemented yet", expr);
                return false;
            }
        }
    }default:
        print_context_expr("Unknown / float operation", expr);
        return false;
    }
    return true;
}

bool generate_func(HC_FILE fptr, func_t* target, node_stmt* stmt, token_t* parent, token_t* this){
    // Registrate the function
    func_t func = (func_t){
        stmt->func_decl.identifier->str,
        stmt->func_decl.identifier->strlen,
        stmt->func_decl.args,
        flags_from_tk(stmt->func_decl.func_type),
        type_from_tk(stmt->func_decl.func_type)
    };

    // Good way to know where something happens
    // print_context_ex("Test", func.str, func.strlen);

    if(!func.type.data || (!func.type.ptr_depth && func.type.data != DATA_INT && !func.type.size)){
        print_context("Type returned by function is invalid", stmt->func_decl.identifier);
        return false;
    }

    if(stmt->func_decl.stmts)
        func.flags |= FLAG_FDEF;

    if(target->type.data != DATA_INVALID){
        if(stmt->func_decl.stmts && (target->flags & FLAG_FDEF)){
            print_context_ex("Redefining function here", func.str, func.strlen);
            print_context_ex("First defined here", target->str, target->strlen);
            return false;
        }
        bool same = ((func.flags & ~FLAG_FDEF) == (target->flags & ~FLAG_FDEF) &&
        func.type.size == target->type.size &&
        func.type.sign == target->type.sign &&
        func.type.ptr_depth == target->type.ptr_depth &&
        func.type.data == target->type.data);
        node_var_decl* last_arg = &target->args->var_decl;
        if((last_arg == NULL) != (func.args == NULL))
            same = false;
        for(node_var_decl* arg = &func.args->var_decl; same && arg; arg = &arg->next->var_decl, last_arg = &last_arg->next->var_decl){
            if((arg->type == tk_var_args) != (last_arg->type == tk_var_args)){
                if(arg->type != tk_var_args)
                    print_context("Var args not matching", arg->identifier);
                else
                    print_context("Var args not matching", last_arg->identifier);
                same = false;
                break;
            }else if(arg->type == tk_var_args){
                last_arg = NULL;
                break;
            }
            type_t t1 = type_from_tk(arg->var_type), t2 = type_from_tk(last_arg->var_type);
            if(!last_arg || t1.size != t2.size || t1.sign != t2.sign || t1.ptr_depth != t2.ptr_depth || t1.data != t2.data)
                same = false;
            if(last_arg->expr && !arg->expr)
                arg->expr = last_arg->expr;
        }
        if(last_arg || !same){
            print_context_ex("Function does not match previous definition", func.str, func.strlen);
            print_context_ex("Previously defined here", target->str, target->strlen);
            return false;
        }
        if(stmt->func_decl.stmts && !(target->flags & FLAG_FDEF))
            *target = func;
    }else
        *target = func;

    if(stmt->func_decl.stmts && (func.flags & FLAG_EXTERN || func.flags & FLAG_CFUNC)){
        print_context("Cannot define an external function", stmt->func_decl.func_type);
        return false;
    }

    // Check if all arguments are valid
    for(node_var_decl* arg = &func.args->var_decl; arg; arg = &arg->next->var_decl){
        if(arg->type == tk_var_args)
            break;
        type_t arg_type = type_from_tk(arg->var_type);
        if(!SIZEOF_T(arg_type)){
            print_context("Argument is 0 bytes big!", arg->identifier);
            return false;
        }
    }

    if(!stmt->func_decl.stmts)
        return true;

    // Setup the function
    stack_sz = stack_ptr = 0;
    label_count = 1;
    if(parent)
        gen_start_method(fptr, parent->str, parent->strlen, func.str, func.strlen);
    else
        gen_start_func(fptr, func.str, func.strlen, func.flags & FLAG_PRIVATE);

    if(stmt->func_decl.stmts == (node_stmt*)(~0)){
        gen_return_func(fptr);
        return true;
    }

    // Setup the function scope
    size_t arg_ptr = 0;
    scope_t func_scope = gen_init_scope(fptr, stmt->func_decl.stmts);

    // @return variable in the function scope
    arg_ptr += (func.type.ptr_depth || func.type.data == DATA_STRUCT || func.type.data == DATA_UNION) ? target_address_size : func.type.size;
    var_t return_var;
    if(!func.type.ptr_depth && (func.type.data == DATA_STRUCT || func.type.data == DATA_UNION)){
        func.type.ptr_depth++;
        return_var = (var_t){"@return", 7, 0, VAR_ARG, FLAG_NONE, func.type};
        func.type.ptr_depth--;
    }else
        return_var = (var_t){"@return", 7, 0, VAR_ARG, FLAG_NONE, func.type};
    vector_append(vars, &return_var);

    if(this){
        type_t this_type = type_from_tk(this);
        this_type.ptr_depth = 1;
        arg_ptr = ALIGN(arg_ptr, target_address_size);
        var_t this_var = (var_t){"this", 4, arg_ptr, VAR_ARG, FLAG_INHERITED, this_type};
        arg_ptr += target_address_size;
        vector_append(vars, &this_var);
    }

    // Add arguments as variables
    for(node_var_decl* arg = &func.args->var_decl; arg; arg = &arg->next->var_decl){
        // Variable arguments start (@varg_start)
        if(arg->type == tk_var_args){
            arg_ptr = ALIGN(arg_ptr, 8);
            if(((node_expr_stmt*)arg)->expr){
                node_term vargc = ((node_expr_stmt*)arg)->expr->term;
                var_t argc = (var_t){vargc.str, vargc.strlen, arg_ptr, VAR_ARG, 0, (type_t){8, GET_DUMMY_TYPE(uint64), false, DATA_INT, 8, 0}};
                if(get_var(vargc.str, vargc.strlen)){
                    print_context_ex("Another argument has the same name", vargc.str, vargc.strlen);
                    return false;
                }
                vector_append(vars, &argc);
                arg_ptr += 8;
            }
            var_t arg_var = (var_t){"@varg_start", 11, arg_ptr, VAR_ARG, FLAG_NONE, (type_t){8, GET_DUMMY_TYPE(int64), true, DATA_INT, 8, 0}};
            vector_append(vars, &arg_var);
            break;
        }

        type_t arg_type = type_from_tk(arg->var_type);

        // Register argument as variable in function scope
        size_t arg_align = ALIGNOF_T(arg_type);
        arg_ptr = ALIGN(arg_ptr, arg_align);
        if(flags_from_tk(arg->var_type)){
            print_context("Cannot give modifiers to function arguments", arg->var_type);
            return false;
        }
        var_t arg_var = (var_t){arg->identifier->str, arg->identifier->strlen, arg_ptr, VAR_ARG, FLAG_NONE, arg_type};
        arg_ptr += SIZEOF_T(arg_type);
        if(get_var(arg->identifier->str, arg->identifier->strlen)){
            print_context("Another argument has the same name", arg->identifier);
            return false;
        }
        vector_append(vars, &arg_var);
    }

    // Go through each statement
    for(node_stmt* ptr = stmt->func_decl.stmts; ptr; ptr = ptr->next){
        if(!generate_stmt(fptr, ptr, func.type, (scope_info){0,0,0,0,0}))
            return false;
    }

    // Remove the variables in the scope
    for(size_t i = vector_size(vars); i > func_scope.var_sz; i--)
        vector_popback(vars);

    // First label is dedicated to returns
    gen_label(fptr, 0);
    gen_return_func(fptr);

    return true;
}

static bool append_module_var(module_t* mod, var_t* var, node_expr* expr){
    if(get_module_var(mod, var->str, var->strlen)){
        print_context_ex("Variable with the same name already declared in the module", var->str, var->strlen);
        return false;
    }

    if(get_module_const(mod, var->str, var->strlen)){
        print_context_ex("Constant with the same name already declared in the module", var->str, var->strlen);
        return false;
    }

    // Append the member
    vector_append(mod->vars, var);

    // Add default value to linked list
    // If there is none, we add a nothing expression
    if(var->location == VAR_STACK){
        if(mod->vals){
            node_expr* val = mod->vals;
            for(; val->next; val = val->next);
            if(expr)
                val->next = expr;
            else{
                val->next = (node_expr*) ARENA_ALLOC(arena, node_nothing_expr);
                val->next->none = (node_nothing_expr){tk_nothing, NULL};
            }
        }else if(expr)
            mod->vals = expr;
        else{
            mod->vals = (node_expr*) ARENA_ALLOC(arena, node_nothing_expr);
            mod->vals->none = (node_nothing_expr){tk_nothing, NULL};
        }
    }

    return true;
}

bool generate_stmt(HC_FILE fptr, node_stmt* stmt, type_t fn_type, scope_info parent){
    if(!fn_type.data &&
        stmt->type != tk_func_decl &&
        stmt->type != tk_var_decl &&
        stmt->type != tk_arr_decl &&
        stmt->type != tk_constexpr &&
        stmt->type != tk_struct &&
        stmt->type != tk_union &&
        stmt->type != tk_variant &&
        stmt->type != tk_class &&
        stmt->type != tk_enum &&
        stmt->type != tk_module &&
        stmt->type != tk_asm){
        HC_PRINT(BOLD "Sadly I can't tell you where the error is, but here is the invalid statement's type: %lu :(" RESET_ATTR "\n", stmt->type);
        HC_ERR("Cannot do more than declaring functions, variables, arrays or data structures outside a function!");
        return false;
    }

    if(!stmt || stmt == (node_stmt*)(~0))
        return true;

    switch(stmt->type){
    case tk_func_decl:{
        if(fn_type.data){
            print_context("Cannot declare function in another", stmt->func_decl.func_type);
            return false;
        }
        func_t* target = get_func(stmt->func_decl.identifier->str, stmt->func_decl.identifier->strlen);
        if(!target){
            func_t func = (func_t){stmt->func_decl.identifier->str, stmt->func_decl.identifier->strlen};
            func.type.data = DATA_INVALID;
            target = hashtable_set(funcs, &func);
        }
        if(!generate_func(fptr, target, stmt, NULL, NULL))
            return false;
        if((target->flags & FLAG_PROTECT) || (target->flags & FLAG_PEEK)){
            print_context_ex("Only public, private, extern and @cfunc modifiers are allowed on functions", target->str, target->strlen);
            return false;
        }
        return true;
    }
    case tk_if:{
        // Allocate labels
        size_t other_label = label_count++, end_label = label_count++;
        parent.stack_sz = stack_sz;
        parent.next_label = other_label;
        if(!parent.end_label)
            parent.end_label = end_label;

        // Generate condition
        type_t cond_type = typeof_expr(stmt->if_stmt.cond);
        if(cond_type.ptr_depth || cond_type.data == DATA_INT){
            reg_t* cond = EXPR_ONCE(stmt->if_stmt.cond, cond_type, NULL);
            gen_cmpz_reg(fptr, cond);
        }else if(cond_type.data == DATA_FLOAT){
            if(!generate_float_expr(fptr, stmt->if_stmt.cond))
                return false;
            gen_cmpz_float(fptr);
        }else{
            print_context_expr("Cannot use as a condition", stmt->if_stmt.cond);
            return false;
        }
        gen_cond_jump(fptr, tk_cmp_eq, other_label, false);

        // Go through the if's scope if its condition is true
        if(!generate_stmt(fptr, stmt->if_stmt.stmts, fn_type, parent))
            return false;

        if(stmt->next && (stmt->next->type == tk_else_if || stmt->next->type == tk_else))
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
                parent.next_label = other_label;

                // Generate the alternate condition
                cond_type = typeof_expr(stmt->if_stmt.cond);
                if(cond_type.ptr_depth || cond_type.data == DATA_INT){
                    reg_t* cond = EXPR_ONCE(stmt->if_stmt.cond, cond_type, NULL);
                    gen_cmpz_reg(fptr, cond);
                }else if(cond_type.data == DATA_FLOAT){
                    if(!generate_float_expr(fptr, stmt->if_stmt.cond))
                        return false;
                    gen_cmpz_float(fptr);
                }else{
                    print_context_expr("Cannot use as a condition", stmt->if_stmt.cond);
                    return false;
                }
                gen_cond_jump(fptr, tk_cmp_eq, other_label, false);

                // Go through the else if's scopes
                if(!generate_stmt(fptr, stmt->if_stmt.stmts, fn_type, parent))
                    return false;
                gen_jump(fptr, end_label);

                gen_label(fptr, other_label);
            }else{
                // Just go through the else's scope
                parent.next_label = 0;
                generate_stmt(fptr, stmt->scope.stmts, fn_type, parent);
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
        parent.end_label = 0;
        scope_t scope = gen_init_scope(fptr, stmt->scope.stmts);
        for(node_stmt* ptr = stmt->scope.stmts; ptr; ptr = ptr->next){
            if(!generate_stmt(fptr, ptr, fn_type, parent))
                return false;
        }

        gen_quit_scope(fptr, scope);
        return true;
    }
    case tk_while:{
        size_t start_label = label_count++, end_label = label_count++;
        parent.end_label = 0;
        parent.stack_sz = stack_sz;
        parent.continue_label = start_label;
        parent.break_label = end_label;

        // Start the loop
        scope_t while_scope = gen_init_scope(fptr, stmt->while_stmt.stmts);
        gen_label(fptr, start_label);

        // Check the condition
        type_t cond_type = typeof_expr(stmt->while_stmt.cond);
        if(cond_type.ptr_depth || cond_type.data == DATA_INT){
            reg_t* cond = EXPR_ONCE(stmt->while_stmt.cond, cond_type, NULL);
            gen_cmpz_reg(fptr, cond);
        }else if(cond_type.data == DATA_FLOAT){
            if(!generate_float_expr(fptr, stmt->while_stmt.cond))
                return false;
            gen_cmpz_float(fptr);
        }else{
            print_context_expr("Cannot use as a condition", stmt->while_stmt.cond);
            return false;
        }
        gen_cond_jump(fptr, tk_cmp_eq, end_label, false);

        // Generate the scope
        for(node_stmt* ptr = stmt->while_stmt.stmts; ptr; ptr = ptr->next){
            if(!generate_stmt(fptr, ptr, fn_type, parent))
                return false;
        }

        // When the loop continues
        //if(stack_sz > parent.stack_sz)
        //    gen_dealloc_stack(fptr, stack_sz - parent.stack_sz);
        gen_jump(fptr, start_label);

        // When the loop ends
        gen_label(fptr, end_label);
        gen_quit_scope(fptr, while_scope);
        return true;
    }
    case tk_repeat:{
        size_t start_label = label_count++, step_label = label_count++, end_label = label_count++;
        parent.end_label = 0;
        parent.stack_sz = stack_sz;
        parent.continue_label = step_label;
        parent.break_label = end_label;

        // Start the loop
        reg_t* cond = generate_expr(fptr, stmt->repeat_stmt.cond, (type_t){8, GET_DUMMY_TYPE(uint64), false, DATA_INT, 8, 0}, NULL);
        scope_t repeat_scope = gen_init_scope(fptr, stmt->repeat_stmt.stmts);
        gen_label(fptr, start_label);

        // Check the condition
        gen_cmpz_reg(fptr, cond);
        gen_cond_jump(fptr, tk_cmp_eq, end_label, false);

        // Generate the scope
        for(node_stmt* ptr = stmt->repeat_stmt.stmts; ptr; ptr = ptr->next){
            if(!generate_stmt(fptr, ptr, fn_type, parent))
                return false;
        }

        // When the loop continues
        gen_label(fptr, step_label);
        //if(stack_sz > parent.stack_sz)
        //    gen_dealloc_stack(fptr, stack_sz - parent.stack_sz);
        gen_dec_reg(fptr, cond);
        gen_jump(fptr, start_label);

        // When the loop ends
        gen_label(fptr, end_label);
        (void) free_reg(cond);
        gen_quit_scope(fptr, repeat_scope);
        return true;
    }
    case tk_forever:{
        parent.end_label = 0;
        parent.stack_sz = stack_sz;

        size_t start_label = label_count++, end_label = label_count++;
        scope_t loop_scope = gen_init_scope(fptr, stmt->scope.stmts);
        parent.continue_label = start_label;
        parent.break_label = end_label;

        gen_label(fptr, start_label);

        // Generate the scope
        for(node_stmt* ptr = stmt->scope.stmts; ptr; ptr = ptr->next){
            if(!generate_stmt(fptr, ptr, fn_type, parent))
                return false;
        }

        // When the loop continues
        //if(stack_sz > parent.stack_sz)
        //    gen_dealloc_stack(fptr, stack_sz - parent.stack_sz);
        gen_jump(fptr, start_label);

        gen_label(fptr, end_label);
        gen_quit_scope(fptr, loop_scope);
        return true;
    }
    case tk_for:{
        size_t start_label = label_count++, step_label = label_count++, end_label = label_count++;

        parent.end_label = 0;
        parent.stack_sz = stack_sz;

        // Start the loop
        scope_t for_scope;
        if(stmt->for_stmt.init){
            node_stmt* last_init = (node_stmt*) stmt->for_stmt.init;
            for(; last_init->next; last_init = last_init->next);
            last_init->next = stmt->for_stmt.stmts;
            for_scope = gen_init_scope(fptr, (node_stmt*) stmt->for_stmt.init);
            for(; (node_stmt*) stmt->for_stmt.init != stmt->for_stmt.stmts; stmt->for_stmt.init = &stmt->for_stmt.init->next->var_decl)
                generate_stmt(fptr, (node_stmt*) stmt->for_stmt.init, fn_type, parent);
        }else
            for_scope = gen_init_scope(fptr, stmt->for_stmt.stmts);
        gen_label(fptr, start_label);

        parent.continue_label = step_label;
        parent.break_label = end_label;

        // Check the condition
        type_t cond_type = typeof_expr(stmt->for_stmt.cond);
        if(cond_type.ptr_depth || cond_type.data == DATA_INT){
            reg_t* cond = EXPR_ONCE(stmt->for_stmt.cond, cond_type, NULL);
            gen_cmpz_reg(fptr, cond);
        }else if(cond_type.data == DATA_FLOAT){
            if(!generate_float_expr(fptr, stmt->for_stmt.cond))
                return false;
            gen_cmpz_float(fptr);
        }else{
            print_context_expr("Cannot use as a condition", stmt->for_stmt.cond);
            return false;
        }
        gen_cond_jump(fptr, tk_cmp_eq, end_label, false);

        // Generate the scope
        for(node_stmt* ptr = stmt->for_stmt.stmts; ptr; ptr = ptr->next){
            if(!generate_stmt(fptr, ptr, fn_type, parent))
                return false;
        }

        // Step
        gen_label(fptr, step_label);
        for(node_stmt* ptr = stmt->for_stmt.step; ptr; ptr = ptr->next){
            if(!generate_stmt(fptr, ptr, fn_type, parent))
                return false;
        }

        // When the loop continues
        //if(stack_sz > parent.stack_sz)
        //    gen_dealloc_stack(fptr, stack_sz - parent.stack_sz);
        gen_jump(fptr, start_label);

        // When the loop ends
        gen_label(fptr, end_label);
        gen_quit_scope(fptr, for_scope);
        return true;
    }
    case tk_var_decl:{
        // If the variable already got declared
        var_t* last_def = get_var(stmt->var_decl.identifier->str, stmt->var_decl.identifier->strlen);
        if(last_def && !(last_def->location == VAR_GLOBAL && last_def->flags & FLAG_EXTERN)){
            print_context("Variable was already declared before", stmt->var_decl.identifier);
            print_context_ex("First declared here:", last_def->str, last_def->strlen);
            return false;
        }

        // If a constexpr already has the same name
        constexpr_t* cons = get_constexpr(stmt->arr_decl.identifier->str, stmt->arr_decl.identifier->strlen);
        if(cons){
            print_context("Constexpr already declared with the same name", stmt->arr_decl.identifier);
            print_context_ex("Constexpr defined here", cons->str, cons->strlen);
            return false;
        }

        // If an enum already has the same name
        enum_t* enu = get_enum(stmt->var_decl.identifier->str, stmt->var_decl.identifier->strlen);
        if(enu){
            print_context("Enum has the same name", stmt->var_decl.identifier);
            print_context_ex("Enum defined here", enu->str, enu->strlen);
            return false;
        }

        // If a module already has the same name
        module_t* mod = get_module(stmt->var_decl.identifier->str, stmt->var_decl.identifier->strlen);
        if(mod){
            print_context("Module has the same name", stmt->var_decl.identifier);
            print_context_ex("Module defined here", mod->str, mod->strlen);
            return false;
        }

        type_t var_type = type_from_tk(stmt->var_decl.var_type);
        if(!var_type.data){
            print_context("Invalid type!", stmt->var_decl.var_type);
            return false;
        }

        size_t var_flags = flags_from_tk(stmt->var_decl.var_type);
        size_t var_sz = SIZEOF_T(var_type), var_align = ALIGNOF_T(var_type);
        if(!var_sz){
            print_context("Variable type is 0 bytes big!", stmt->var_decl.var_type);
            return false;
        }

        if(fn_type.data){
            // Stack variables
            stack_ptr = ALIGN(stack_ptr, var_align);
            stack_ptr += var_sz;
            size_t var_ptr = stack_ptr;

            // Save the default value
            if(stmt->var_decl.expr){
                if(var_type.ptr_depth || var_type.data == DATA_INT){
                    reg_t* tmp = EXPR_ONCE(stmt->var_decl.expr, var_type, NULL);
                    gen_save_stack(fptr, tmp, stack_sz - var_ptr);
                }else if(var_type.data == DATA_FLOAT){
                    if(!generate_float_expr(fptr, stmt->var_decl.expr))
                        return false;
                    gen_save_stack_float(fptr, stack_sz - var_ptr, var_type.size == 8);
                }else if(var_type.data == DATA_STRUCT || var_type.data == DATA_UNION){
                    reg_t* ptr = alloc_reg(GET_MASK_REG(target_address_size, allowed_copy_regs), false);
                    gen_load_stack_ptr(fptr, ptr, stack_sz - var_ptr);
                    if(var_type.data == DATA_STRUCT){
                        struct_t* stru = get_struct_tk(var_type.repr);
                        if(!save_struct(fptr, stru, ptr, stmt->var_decl.expr))
                            return false;
                    }else{
                        union_t* unio = get_union_tk(var_type.repr);
                        if(!save_union(fptr, unio, ptr, stmt->var_decl.expr))
                            return false;
                    }
                    (void) free_reg(ptr);
                }
            }

            if(var_flags != FLAG_NONE){
                print_context("Incompatible modifier(s)", stmt->var_decl.var_type);
                return false;
            }

            // Register the variable in the variable vector
            var_t new_var = (var_t){stmt->var_decl.identifier->str, stmt->var_decl.identifier->strlen, var_ptr, VAR_STACK, var_flags, var_type};
            if(last_def)
                *last_def = new_var;
            else
                vector_append(vars, &new_var);
        }else{
            // Global variables
            size_t i = ~0;
            if(stmt->var_decl.expr){
                i = vector_size(global_var_values);
                node_expr* expr = vector_append(global_var_values, stmt->var_decl.expr);
            }

            if(var_flags != FLAG_NONE && var_flags != FLAG_EXTERN && var_flags != FLAG_PRIVATE){
                print_context("Incompatible modifier(s)", stmt->var_decl.var_type);
                return false;
            }

            if(var_flags == FLAG_EXTERN && stmt->var_decl.expr){
                print_context_expr("Cannot give a value to external variable", stmt->var_decl.expr);
                return false;
            }

            // Register the variable in the variable vector
            var_t new_var = (var_t){
                stmt->var_decl.identifier->str,
                stmt->var_decl.identifier->strlen,
                i,
                VAR_GLOBAL, var_flags, var_type
            };

            if(last_def)
                *last_def = new_var;
            else
                last_def = vector_append(vars, &new_var);
        }
        return true;
    }
    case tk_arr_decl:{
        // If the variable already got declared
        var_t* last_def = get_var(stmt->var_decl.identifier->str, stmt->var_decl.identifier->strlen);
        if(last_def && !(last_def->flags & FLAG_EXTERN)){
            print_context("Variable was already declared before", stmt->var_decl.identifier);
            print_context_ex("First declared here:", last_def->str, last_def->strlen);
            return false;
        }

        // If a constexpr already has the same name
        constexpr_t* cons = get_constexpr(stmt->arr_decl.identifier->str, stmt->arr_decl.identifier->strlen);
        if(cons){
            print_context("Constexpr already declared with the same name", stmt->arr_decl.identifier);
            print_context_ex("Constexpr defined here", cons->str, cons->strlen);
            return false;
        }

        // If an enum already has the same name
        enum_t* enu = get_enum(stmt->arr_decl.identifier->str, stmt->arr_decl.identifier->strlen);
        if(enu){
            print_context("Enum has the same name", stmt->arr_decl.identifier);
            print_context_ex("Enum defined here", enu->str, enu->strlen);
            return false;
        }

        // If a module already has the same name
        module_t* mod = get_module(stmt->arr_decl.identifier->str, stmt->arr_decl.identifier->strlen);
        if(mod){
            print_context("Module has the same name", stmt->arr_decl.identifier);
            print_context_ex("Module defined here", mod->str, mod->strlen);
            return false;
        }

        type_t elem_type = type_from_tk(stmt->arr_decl.elem_type);
        if(!elem_type.data){
            print_context("Invalid type!", stmt->arr_decl.elem_type);
            return false;
        }

        size_t arr_flags = flags_from_tk(stmt->arr_decl.elem_type);

        // Get the number of elements in the array
        int64_t elem_count;
        if(!eval_int_expr(stmt->arr_decl.elem_count, &elem_count)){
            print_context_expr("Expected constant expression", stmt->arr_decl.elem_count);
            return false;
        }

        if(elem_count <= 0){
            print_context_expr("Element count of array must be positive (it is <= 0)", stmt->arr_decl.elem_count);
            return false;
        }

        // Get the size of the array and adjust the pointer depth of the var's type
        size_t elem_size = SIZEOF_T(elem_type), elem_align = ALIGNOF_T(elem_type);
        if(!elem_size){
            print_context("Array element type is 0 bytes big!", stmt->arr_decl.elem_type);
            return false;
        }

        size_t arr_size = elem_size * elem_count;
        elem_type.ptr_depth++;

        if(fn_type.data){
            // Stack array
            stack_ptr = ALIGN(stack_ptr, elem_align);
            stack_ptr += arr_size;
            size_t var_ptr = stack_ptr;

            if(arr_flags != FLAG_NONE){
                print_context("Incompatible modifier(s)", stmt->arr_decl.elem_type);
                return false;
            }

            // Register the array in the variable vector
            var_t new_var = (var_t){stmt->arr_decl.identifier->str, stmt->arr_decl.identifier->strlen, var_ptr, VAR_ARRAY, arr_flags, elem_type};
            vector_append(vars, &new_var);
        }else{
            if(arr_flags != FLAG_NONE && arr_flags != FLAG_EXTERN && arr_flags != FLAG_PRIVATE){
                print_context("Incompatible modifier(s)", stmt->arr_decl.elem_type);
                return false;
            }
            // Global array
            var_t new_var = (var_t){stmt->arr_decl.identifier->str, stmt->arr_decl.identifier->strlen, arr_size, VAR_GLOBAL_ARR, arr_flags, elem_type};
            vector_append(vars, &new_var);
        }
        return true;
    }case tk_constexpr:{
        if(fn_type.data)
            print_context(YELLOW_FG "WARNING" RESET_ATTR " : Constant expression will be exposed in global namespace", stmt->const_decl.identifier);

        // If variable already has the same name
        var_t* var = get_var(stmt->const_decl.identifier->str, stmt->const_decl.identifier->strlen);
        if(var){
            print_context("Variable already declared with the same name", stmt->const_decl.identifier);
            print_context_ex("Variable declared here", var->str, var->strlen);
        }

        // If an enum already has the same name
        enum_t* enu = get_enum(stmt->const_decl.identifier->str, stmt->const_decl.identifier->strlen);
        if(enu){
            print_context("Enum has the same name", stmt->const_decl.identifier);
            print_context_ex("Enum defined here", enu->str, enu->strlen);
            return false;
        }

        // If a module already has the same name
        module_t* mod = get_module(stmt->const_decl.identifier->str, stmt->const_decl.identifier->strlen);
        if(mod){
            print_context("Module has the same name", stmt->const_decl.identifier);
            print_context_ex("Module defined here", mod->str, mod->strlen);
            return false;
        }

        constexpr_t cons = (constexpr_t){stmt->const_decl.identifier->str, stmt->const_decl.identifier->strlen,
                                        stmt->const_decl.is_integer ? CONST_INT : CONST_FLOAT};

        if((cons.type == CONST_INT && !eval_int_expr(stmt->const_decl.expr, &cons.i)) ||
            (cons.type == CONST_FLOAT && !eval_float_expr(stmt->const_decl.expr, &cons.f))){
            print_context_expr("Expression is not constant", stmt->const_decl.expr);
            return false;
        }

        vector_append(consts, &cons);
        return true;
    }case tk_struct:
    case tk_class:{
        if(fn_type.data){
            print_context("Cannot declare struct / class type in function", stmt->struct_decl.identifier);
            return false;
        }

        const char* str = stmt->struct_decl.identifier->str;
        size_t strlen = stmt->struct_decl.identifier->strlen;

        if(get_union(str, strlen)){
            print_context_ex("Union type already declared with the same name", str, strlen);
            union_t* unio = get_union(str, strlen);
            print_context_ex("Last declaration here", unio->str, unio->strlen);
            return false;
        }

        struct_t* new_struct = get_struct(str, strlen);
        if(stmt->type == tk_struct && new_struct && new_struct->size){
            print_context_ex("Already defined", str, strlen);
            print_context_ex("Last definition here", new_struct->str, new_struct->strlen);
            return false;
        }else if(!new_struct){
            struct_t stru = {str, strlen, 0, 0, {NEW_VECTOR(var_t)}, {NEW_VECTOR(func_t)}, NULL};
            new_struct = vector_append(structs, &stru);
        }

        bool first_member_def = new_struct->members->size == 0;
        for(size_t i = 0; i < vector_size(new_struct->funcs); i++){
            func_t* func = vector_at(new_struct->funcs, i);
            if(func->flags & FLAG_CFUNC)
                first_member_def = false;
        }

        if(stmt->type == tk_class){
            current_class = new_struct;
            current_module = get_module(str, strlen);
        }

        for(node_stmt* ptr = stmt->struct_decl.members; ptr; ptr = ptr->next){
            // Scalar members
            if(ptr->type == tk_var_decl){
                if(!first_member_def){
                    print_context("Members must be defined entirely (together) before methods are defined", ptr->var_decl.identifier);
                    print_context("In class declaration", stmt->struct_decl.identifier);
                    return false;
                }

                if(get_member(new_struct, ptr->var_decl.identifier->str, ptr->var_decl.identifier->strlen)){
                    print_context("Another member has the same name in struct / class", ptr->var_decl.identifier);
                    return false;
                }

                type_t var_type = type_from_tk(ptr->var_decl.var_type);
                size_t var_flags = flags_from_tk(ptr->var_decl.var_type);
                size_t var_sz = SIZEOF_T(var_type), var_align = ALIGNOF_T(var_type);

                if(!var_type.data){
                    print_context("Invalid structure member type!", ptr->var_decl.identifier);
                    return false;
                }

                if(var_type.data == DATA_STRUCT && get_struct_tk(var_type.repr) == new_struct && !var_type.ptr_depth){
                    print_context("Cannot have itself as a member", ptr->var_decl.identifier);
                    return false;
                }

                // We don't want an empty type (0 byte big type)
                if(!var_sz){
                    print_context("Structure member type is 0 bytes big!", ptr->var_decl.var_type);
                    return false;
                }

                if(stmt->type == tk_struct && var_flags){
                    print_context("Cannot give modifiers to structure members", ptr->var_decl.var_type);
                    return false;
                }else if((var_flags & FLAG_EXTERN) || (var_flags & FLAG_CFUNC)){
                    print_context("Invalid modifiers", ptr->var_decl.var_type);
                    return false;
                }

                // Calculate the struct's size with alignment
                new_struct->size = ALIGN(new_struct->size, var_align);
                new_struct->align = MAX(new_struct->align, var_align);
                var_t member_var = (var_t){ptr->var_decl.identifier->str, ptr->var_decl.identifier->strlen, new_struct->size, VAR_STACK, var_flags, var_type};
                new_struct->size += var_sz;

                // Append the member
                vector_append(new_struct->members, &member_var);

                // Add default value to linked list
                // If there is none, we add a nothing expression
                if(new_struct->default_values){
                    node_expr* val = new_struct->default_values;
                    for(; val->next; val = val->next);
                    if(ptr->var_decl.expr)
                        val->next = ptr->var_decl.expr;
                    else{
                        val->next = (node_expr*) ARENA_ALLOC(arena, node_nothing_expr);
                        val->next->none = (node_nothing_expr){tk_nothing, NULL};
                    }
                }else if(ptr->var_decl.expr)
                    new_struct->default_values = ptr->var_decl.expr;
                else{
                    new_struct->default_values = (node_expr*) ARENA_ALLOC(arena, node_nothing_expr);
                    new_struct->default_values->none = (node_nothing_expr){tk_nothing, NULL};
                }
            }// Array members
            else if(ptr->type == tk_arr_decl){
                if(!first_member_def){
                    print_context("Members must be defined entirely (together) before methods are defined", ptr->arr_decl.identifier);
                    print_context("In class declaration", stmt->struct_decl.identifier);
                    return false;
                }

                if(get_member(new_struct, ptr->arr_decl.identifier->str, ptr->arr_decl.identifier->strlen)){
                    print_context("Another member has the same name in struct / class", ptr->arr_decl.identifier);
                    return false;
                }

                type_t elem_type = type_from_tk(ptr->arr_decl.elem_type);
                size_t arr_flags = flags_from_tk(ptr->arr_decl.elem_type);
                size_t elem_sz = SIZEOF_T(elem_type), elem_align = ALIGNOF_T(elem_type);
                int64_t elem_count;
                if(!eval_int_expr(ptr->arr_decl.elem_count, &elem_count)){
                    print_context_expr("Expected constant expression", ptr->arr_decl.elem_count);
                    return false;
                }

                if(!elem_type.data){
                    print_context("Invalid array member type!", ptr->arr_decl.identifier);
                    return false;
                }

                if(elem_type.data == DATA_STRUCT && get_struct_tk(elem_type.repr) == new_struct && !elem_type.ptr_depth){
                    print_context("Cannot have itself as a member", ptr->var_decl.identifier);
                    return false;
                }

                if(!elem_sz){
                    print_context("Array member elements are 0 bytes big!", ptr->arr_decl.identifier);
                    return false;
                }

                if(elem_count < 0){
                    print_context_expr("Array member's element count is negative!", ptr->arr_decl.elem_count);
                    return false;
                }

                if(stmt->type == tk_struct && arr_flags){
                    print_context("Cannot give modifiers to structure members", ptr->arr_decl.elem_type);
                    return false;
                }else if((arr_flags & FLAG_EXTERN) || (arr_flags & FLAG_CFUNC)){
                    print_context("Invalid modifiers", ptr->arr_decl.elem_type);
                    return false;
                }

                // Calculate struct's size and alignment
                new_struct->size = ALIGN(new_struct->size, elem_align);
                new_struct->align = MAX(new_struct->align, elem_align);
                elem_type.ptr_depth++;
                var_t member_arr = (var_t){ptr->arr_decl.identifier->str, ptr->arr_decl.identifier->strlen, new_struct->size, VAR_ARRAY, arr_flags, elem_type};
                new_struct->size += elem_sz * elem_count;

                // Append array to members
                vector_append(new_struct->members, &member_arr);
            }else if(stmt->type == tk_class && ptr->type == tk_func_decl){
                func_t* method = get_method(new_struct, ptr->func_decl.identifier->str, ptr->func_decl.identifier->strlen);
                if(!method){
                    func_t func = (func_t){stmt->func_decl.identifier->str, stmt->func_decl.identifier->strlen};
                    func.type.data = DATA_INVALID;
                    method = vector_append(new_struct->funcs, &func);
                }
                if(!generate_func(fptr, method, ptr, stmt->struct_decl.identifier, stmt->struct_decl.identifier))
                    return false;
                if((method->flags & FLAG_CFUNC) || (method->flags & FLAG_PEEK) || (method->flags & FLAG_EXTERN)){
                    print_context_ex("Modifiers extern, @cfunc and @peek are prohibited on methods", method->str, method->strlen);
                    return false;
                }
                if(method->flags & FLAG_FDEF)
                    first_member_def = false;
            }else{
                print_context_ex("Expected only member declarations, got another statement instead here", str, strlen);
                return false;
            }
        }

        if(new_struct->align)
            new_struct->size = ALIGN(new_struct->size, new_struct->align);

        if(stmt->type == tk_class){
            current_class = NULL;
            current_module = NULL;
        }

        return true;
    }case tk_union:
    case tk_variant:{
        if(fn_type.data){
            print_context("Cannot declare union type in function", stmt->struct_decl.identifier);
            return false;
        }

        const char* str = stmt->struct_decl.identifier->str;
        size_t strlen = stmt->struct_decl.identifier->strlen;

        if(get_struct(str, strlen)){
            print_context_ex("Structure / class type already declared with the same name", str, strlen);
            struct_t* stru = get_struct(str, strlen);
            print_context_ex("Last declaration here", stru->str, stru->strlen);
            return false;
        }

        union_t* last_def = get_union(str, strlen);
        if(last_def && last_def->size){
            print_context_ex("Already defined", str, strlen);
            print_context_ex("Last definition here", last_def->str, last_def->strlen);
            return false;
        }

        enum_t variant_enum = (enum_t){str, strlen, NULL};
        union_t unio = {str, strlen, 0, 0, (stmt->type == tk_variant), stmt->struct_decl.members};
        for(node_stmt* ptr = stmt->struct_decl.members; ptr; ptr = ptr->next){
            if(ptr->type == tk_var_decl){
                if(get_union_member(&unio, ptr->var_decl.identifier->str, ptr->var_decl.identifier->strlen) != ptr){
                    print_context("Another member has the same name in union", ptr->var_decl.identifier);
                    return false;
                }

                type_t var_type = type_from_tk(ptr->var_decl.var_type);
                size_t size = SIZEOF_T(var_type), align = ALIGNOF_T(var_type);

                if(!var_type.data){
                    print_context("Invalid union member type!", ptr->arr_decl.identifier);
                    return false;
                }

                if(!size){
                    print_context("Union member holds empty (0 bytes big) type!", ptr->arr_decl.identifier);
                    return false;
                }

                if(flags_from_tk(ptr->var_decl.var_type)){
                    print_context("Cannot give modifiers to union members", ptr->var_decl.var_type);
                    return false;
                }

                if(stmt->type == tk_variant){
                    if(ptr->var_decl.identifier->strlen == 4 && strncmp(ptr->var_decl.identifier->str, "type", 4) == 0){
                        print_context("Cannot define a member with the name \"type\" in a variant", ptr->var_decl.identifier);
                        return false;
                    }
                    node_expr* val = (node_expr*) ARENA_ALLOC(arena, node_term);
                    val->term = (node_term){tk_identifier, NULL,  ptr->var_decl.identifier->str, ptr->var_decl.identifier->strlen};
                    if(!variant_enum.vals)
                        variant_enum.vals = val;
                    else
                        APPEND_LIST(variant_enum.vals, val);
                }

                unio.size = MAX(unio.size, size);
                unio.align = MAX(unio.align, align);
            }else if(ptr->type == tk_arr_decl){
                if(get_union_member(&unio, ptr->arr_decl.identifier->str, ptr->arr_decl.identifier->strlen) != ptr){
                    print_context("Another member has the same name in union", ptr->arr_decl.identifier);
                    return false;
                }

                type_t elem_type = type_from_tk(ptr->arr_decl.elem_type);
                size_t size = SIZEOF_T(elem_type), align = ALIGNOF_T(elem_type);
                int64_t elem_count;
                if(!eval_int_expr(ptr->arr_decl.elem_count, &elem_count)){
                    print_context_expr("Expected constant expression", ptr->arr_decl.elem_count);
                    return false;
                }

                if(!elem_type.data){
                    print_context("Invalid array member type!", ptr->arr_decl.identifier);
                    return false;
                }

                if(!size){
                    print_context("Array member elements are 0 bytes big!", ptr->arr_decl.identifier);
                    return false;
                }

                if(elem_count < 0){
                    print_context_expr("Array member's element count is negative!", ptr->arr_decl.elem_count);
                    return false;
                }

                if(flags_from_tk(ptr->arr_decl.elem_type)){
                    print_context("Cannot give modifiers to union members", ptr->arr_decl.elem_type);
                    return false;
                }

                if(stmt->type == tk_variant){
                    if(ptr->arr_decl.identifier->strlen == 4 && strncmp(ptr->arr_decl.identifier->str, "type", 4) == 0){
                        print_context("Cannot define a member with the name \"type\" in a variant", ptr->var_decl.identifier);
                        return false;
                    }
                    node_expr* val = (node_expr*) ARENA_ALLOC(arena, node_term);
                    val->term = (node_term){tk_identifier, NULL,  ptr->arr_decl.identifier->str, ptr->arr_decl.identifier->strlen};
                    if(!variant_enum.vals)
                        variant_enum.vals = val;
                    else
                        APPEND_LIST(variant_enum.vals, val);
                }

                unio.size = MAX(unio.size, size * elem_count);
                unio.align = MAX(unio.align, align);
            }else{
                print_context_ex("Can only have member declarations in a union declaration", str, strlen);
                return false;
            }
        }

        if(unio.align)
            unio.size = ALIGN(unio.size, unio.align);

        if(stmt->type == tk_variant){
            enum_t* enu = get_enum(unio.str, unio.strlen);
            if(enu){
                print_context_ex("Enum type is already defined with the same name", unio.str, unio.strlen);
                print_context_ex("Last defined here", enu->str, enu->strlen);
                return false;
            }
            if(!variant_enum.vals){
                print_context_ex("Variants must provide at least one possible value", unio.str, unio.strlen);
                return false;
            }
            vector_append(enums, &variant_enum);
            unio.align = MAX(unio.align, 1);
            unio.size += unio.align;
        }

        if(!last_def)
            vector_append(unions, &unio);
        else
            *last_def = unio;
        return true;
    }case tk_module:{
        if(fn_type.data){
            print_context("Modules cannot be defined in functions", stmt->struct_decl.identifier);
            return false;
        }

        // If variable already has the same name
        var_t* var = get_var(stmt->struct_decl.identifier->str, stmt->struct_decl.identifier->strlen);
        if(var){
            print_context("Variable already declared with the same name", stmt->struct_decl.identifier);
            print_context_ex("Variable declared here", var->str, var->strlen);
        }

        module_t* mod = get_module(stmt->struct_decl.identifier->str, stmt->struct_decl.identifier->strlen);
        if(!mod){
            module_t module = (module_t){stmt->struct_decl.identifier->str, stmt->struct_decl.identifier->strlen,
                0, {NEW_VECTOR(constexpr_t)}, {NEW_VECTOR(var_t)}, {NEW_VECTOR(func_t)}, NULL};
            mod = vector_append(modules, &module);
        }

        if(stmt->struct_decl.identifier->next->type == tk_extern)
            mod->external = true;
        else if(stmt->struct_decl.identifier->next->type == tk_assign)
            mod->external = false;

        current_module = mod;

        for(node_stmt* ptr = stmt->struct_decl.members; ptr; ptr = ptr->next){
            if(ptr->type == tk_var_decl){
                type_t var_type = type_from_tk(ptr->var_decl.var_type);
                size_t var_flags = flags_from_tk(ptr->var_decl.var_type);
                size_t var_sz = SIZEOF_T(var_type), var_align = ALIGNOF_T(var_type);

                if((var_flags & FLAG_EXTERN) || (var_flags & FLAG_CFUNC)){
                    print_context("Invalid modifiers", ptr->var_decl.var_type);
                    return false;
                }

                if(!var_type.data){
                    print_context("Invalid structure member type!", ptr->var_decl.identifier);
                    return false;
                }

                // We don't want an empty type (0 byte big type)
                if(!var_sz){
                    print_context("Structure member type is 0 bytes big!", ptr->var_decl.var_type);
                    return false;
                }

                // Calculate the struct's size with alignment
                mod->size = ALIGN(mod->size, var_align);
                var_t member_var = (var_t){ptr->var_decl.identifier->str, ptr->var_decl.identifier->strlen, mod->size, VAR_STACK, var_flags, var_type};
                mod->size += var_sz;

                append_module_var(mod, &member_var, ptr->var_decl.expr);
            }else if(ptr->type == tk_arr_decl){
                type_t elem_type = type_from_tk(ptr->arr_decl.elem_type);
                size_t arr_flags = flags_from_tk(ptr->arr_decl.elem_type);
                size_t elem_sz = SIZEOF_T(elem_type), elem_align = ALIGNOF_T(elem_type);
                int64_t elem_count;
                if(!eval_int_expr(ptr->arr_decl.elem_count, &elem_count)){
                    print_context_expr("Expected constant expression", ptr->arr_decl.elem_count);
                    return false;
                }

                if((arr_flags & FLAG_EXTERN) || (arr_flags & FLAG_CFUNC)){
                    print_context("Invalid modifiers", ptr->arr_decl.elem_type);
                    return false;
                }

                if(!elem_type.data){
                    print_context("Invalid array member type!", ptr->arr_decl.identifier);
                    return false;
                }

                if(!elem_sz){
                    print_context("Array member elements are 0 bytes big!", ptr->arr_decl.identifier);
                    return false;
                }

                if(elem_count < 0){
                    print_context_expr("Array member's element count is negative!", ptr->arr_decl.elem_count);
                    return false;
                }

                // Calculate struct's size and alignment
                mod->size = ALIGN(mod->size, elem_align);
                elem_type.ptr_depth++;
                var_t member_arr = (var_t){ptr->arr_decl.identifier->str, ptr->arr_decl.identifier->strlen, mod->size, VAR_ARRAY, arr_flags, elem_type};
                mod->size += elem_sz * elem_count;

                append_module_var(mod, &member_arr, NULL);
            }else if(ptr->type == tk_constexpr){
                if(get_module_var(mod, ptr->const_decl.identifier->str, ptr->const_decl.identifier->strlen)){
                    print_context("Variable with the same name already declared in the module", ptr->const_decl.identifier);
                    return false;
                }

                if(get_module_const(mod, ptr->const_decl.identifier->str, ptr->const_decl.identifier->strlen)){
                    print_context("Constant with the same name already declared in the module", ptr->const_decl.identifier);
                    return false;
                }

                constexpr_t cons = (constexpr_t){ptr->const_decl.identifier->str, ptr->const_decl.identifier->strlen,
                    ptr->const_decl.is_integer ? CONST_INT : CONST_FLOAT};
                if((cons.type == CONST_INT && !eval_int_expr(ptr->const_decl.expr, &cons.i)) ||
                    (cons.type == CONST_FLOAT && !eval_float_expr(ptr->const_decl.expr, &cons.f))){
                    print_context_expr("Expression is not constant", ptr->const_decl.expr);
                    return false;
                }
                vector_append(mod->consts, &cons);
            }else if(ptr->type == tk_func_decl){
                func_t* func = get_module_func(mod, ptr->func_decl.identifier->str, ptr->func_decl.identifier->strlen);
                if(!func){
                    func_t new_func = (func_t){ptr->func_decl.identifier->str, ptr->func_decl.identifier->strlen, NULL, 0, INVALID_TYPE};
                    func = vector_append(mod->funcs, &new_func);
                }
                if(!generate_func(fptr, func, ptr, stmt->struct_decl.identifier, NULL))
                    return false;
                if((func->flags & FLAG_CFUNC) || (func->flags & FLAG_PEEK) || (func->flags & FLAG_EXTERN)){
                    print_context_ex("Modifiers extern, static, @cfunc and @peek are prohibited on functions inside modules", func->str, func->strlen);
                    return false;
                }
                if(mod->external && func->flags & FLAG_FDEF){
                    print_context_ex("Cannot define functions in module if it is external", func->str, func->strlen);
                    if(stmt->struct_decl.identifier->next->type != tk_extern)
                        print_context_ex("Consider adding = after module name to start its definition", mod->str, mod->strlen);
                    else
                        print_context("Consider replacing extern with = to start its definition", stmt->struct_decl.identifier->next);
                    return false;
                }
            }else{
                print_context("Can only declare constants, variables and functions in a module", stmt->struct_decl.identifier);
                return false;
            }
        }

        current_module = NULL;

        return true;
    }case tk_enum:{
        if(fn_type.data){
            print_context("Enum type cannot be declared in a function", stmt->enum_decl.identifier);
            return false;
        }
        enum_t enu = (enum_t){stmt->enum_decl.identifier->str, stmt->enum_decl.identifier->strlen, stmt->enum_decl.members};
        enum_t* last_def = get_enum(enu.str, enu.strlen);
        if(last_def){
            print_context_ex("Enum already defined", enu.str, enu.strlen);
            print_context_ex("Last definition", last_def->str, last_def->strlen);
            return false;
        }

        var_t* var = get_var(enu.str, enu.strlen);
        if(var){
            print_context_ex("Variable has the same name", enu.str, enu.strlen);
            print_context_ex("Variable defined here", var->str, var->strlen);
            return false;
        }

        vector_append(enums, &enu);
        return true;
    }case tk_assign:
        return save_expr(fptr, stmt->var_assign.var, stmt->var_assign.expr);
    case tk_add_assign:
    case tk_sub_assign:
    case tk_mult_assign:
    case tk_div_assign:
    case tk_mod_assign:{
        node_bin_op op = (node_bin_op){stmt->type - tk_add_assign + tk_add, NULL, stmt->var_assign.var, stmt->var_assign.expr};
        return save_expr(fptr, stmt->var_assign.var, (node_expr*) &op);
    }
    case tk_expr_stmt:{
        // Just generate the expression with the target of a 64 bit int or a type we know
        type_t type = typeof_expr(stmt->expr.expr);
        if(!type.data)
            type = (type_t){8, GET_DUMMY_TYPE(int64), true, DATA_INT, 8, 0};
        if(stmt->expr.expr->type == tk_func_call){
            func_t* func = NULL;
            size_t func_call_sz = 0;
            reg_t* struct_ptr = NULL;
            if(!type.ptr_depth && (type.data == DATA_STRUCT || type.data == DATA_UNION)){
                struct_ptr = alloc_reg(GET_MASK_REG(target_address_size, allowed_copy_regs), false);
                func_call_sz = type.size;
                gen_alloc_stack(fptr, type.size);
                gen_load_stack_ptr(fptr, struct_ptr, 0);
            }
            func_call_sz += generate_func_call(fptr, stmt->expr.expr, &func, struct_ptr);
            if(struct_ptr)
                (void) free_reg(struct_ptr);
            if(func_call_sz)
                gen_dealloc_stack(fptr, func_call_sz);
            stack_sz -= func_call_sz;
        }else if(type.ptr_depth || type.data == DATA_INT)
            EXPR_ONCE(stmt->expr.expr, type, NULL);
        else if(type.data == DATA_FLOAT){
            if(!generate_float_expr(fptr, stmt->expr.expr))
                return false;
            gen_pop_float(fptr);
        }
        return true;
    }
    case tk_continue:
        if(!parent.continue_label){
            print_context("Not in a loop", stmt->control.token);
            return false;
        }
        gen_jump(fptr, parent.continue_label);
        return true;
    case tk_break:
        if(!parent.break_label){
            print_context("Not in a loop", stmt->control.token);
            return false;
        }
        gen_jump(fptr, parent.break_label);
        return true;
    case tk_end:
        if(!parent.end_label){
            print_context("Not in an if / switch statement", stmt->control.token);
            return false;
        }
        if(stack_sz - parent.stack_sz)
            gen_dealloc_stack(fptr, stack_sz - parent.stack_sz);
        gen_jump(fptr, parent.end_label);
        return true;
    case tk_next:
        if(!parent.next_label){
            print_context("Not in an if / switch statement", stmt->control.token);
            return false;
        }
        if(stack_sz - parent.stack_sz)
            gen_dealloc_stack(fptr, stack_sz - parent.stack_sz);
        gen_jump(fptr, parent.next_label);
        return true;
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
            type_t expr_type = typeof_expr(expr);
            if(expr_type.ptr_depth || expr_type.data == DATA_INT){
                tmps[tmp_count] = generate_expr(fptr, expr, expr_type, NULL);
                if(!tmps[tmp_count]){
                    print_context_expr("Not enough registers for all values (try separating inline assembly in two parts?)", expr);
                    return false;
                }
            }else{
                print_context_expr("If value is not an int, use pointer to value", expr);
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
            }else if(*str == '@' && *(str+1) >= '0' && *(str+1) <= '9'){
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
        if(SIZEOF_T(fn_type) && stmt->ret.expr){
            if(fn_type.ptr_depth || fn_type.data == DATA_INT)
                gen_save_arg(fptr, EXPR_ONCE(stmt->ret.expr, fn_type, NULL), 0);
            else if(fn_type.data == DATA_FLOAT){
                if(!generate_float_expr(fptr, stmt->ret.expr))
                    return false;
                gen_save_arg_float(fptr, 0, fn_type.size == 8);
            }else if(fn_type.data == DATA_STRUCT || fn_type.data == DATA_UNION){
                reg_t* ptr = alloc_reg(GET_MASK_REG(target_address_size, allowed_copy_regs), false);
                gen_load_arg(fptr, ptr, 0);
                if(fn_type.data == DATA_STRUCT){
                    struct_t* stru = get_struct_tk(fn_type.repr);
                    if(!save_struct(fptr, stru, ptr, stmt->ret.expr))
                        return false;
                }else if(fn_type.data == DATA_UNION){
                    union_t* unio = get_union_tk(fn_type.repr);
                    if(!save_union(fptr, unio, ptr, stmt->ret.expr))
                        return false;
                }
                (void) free_reg(ptr);
            }
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

static bool generate_constant(HC_FILE fptr, type_t target_type, node_expr* expr){
    if((expr->type == tk_str_lit || expr->type == tk_getaddr) && !target_type.ptr_depth){
        print_context_expr("Cannot assign pointer value to non-pointer type", expr);
        print_type("Type ", target_type, " is not a pointer type!");
        return false;
    }
    if(expr->type == tk_str_lit)
        gen_declare_str_lit_ptr(fptr, append_string_literal(&expr->term));
    else if(expr->type == tk_getaddr){
        if(expr->unary_op.lhs->type != tk_identifier){
            print_context_expr("Expression is not constant", expr);
            return false;
        }
        var_t* var = get_var(expr->unary_op.lhs->term.str, expr->unary_op.lhs->term.strlen);
        if(!var){
            print_context_ex("Unknown identifier", expr->unary_op.lhs->term.str, expr->unary_op.lhs->term.strlen);
            return false;
        }
        if(var->location != VAR_GLOBAL){
            print_context_ex("Expected global variable known at compile time", var->str, var->strlen);
            return false;
        }
        gen_declare_global_ptr(fptr, var->str, var->strlen);
    }else if(expr->type == tk_identifier){
        var_t* var = get_var(expr->term.str, expr->term.strlen);
        if(!var){
            print_context_ex("Unknown identifier", expr->term.str, expr->term.strlen);
            return false;
        }
        if(var->location == VAR_GLOBAL_ARR)
            gen_declare_global_ptr(fptr, var->str, var->strlen);
        else if(var->location == VAR_GLOBAL && var->stack_ptr != ~0){
            if(!types_compatible(var->type, target_type)){
                print_context_ex("Types are incompatible!", expr->term.str, expr->term.strlen);
                return false;
            }
            node_expr* var_expr = vector_at(global_var_values, var->stack_ptr);
            return generate_constant(fptr, target_type, var_expr);
        }else{
            print_context_ex("Expected global variable with known initialisation value or global array", expr->term.str, expr->term.strlen);
            return false;
        }
    }else if(target_type.ptr_depth || target_type.data == DATA_INT){
        size_t sz = SIZEOF_T(target_type);
        bool sign = SIGNOF_T(target_type);
        if(sign){
            int64_t val;
            if(!eval_int_expr(expr, &val)){
                print_context_expr("Expression is not constant", expr);
                return false;
            }
            gen_declare_int(fptr, val, sz);
        }else{
            uint64_t val;
            if(!eval_uint_expr(expr, &val)){
                print_context_expr("Expression is not constant", expr);
                return false;
            }
            gen_declare_int(fptr, val, sz);
        }
    }else if(target_type.data == DATA_FLOAT){
        double val;
        if(!eval_float_expr(expr, &val)){
            print_context_expr("Expression is not constant", expr);
            return false;
        }
        gen_declare_float(fptr, val, target_type.size == 8);
    }else if(target_type.data == DATA_STRUCT){
        if(expr->type != tk_struct){
            print_context_expr("Expected structure construction", expr);
            return false;
        }
        struct_t* stru = get_struct_tk(target_type.repr);
        if(get_struct_tk(expr->construct.struc) != stru){
            print_context("Incompatible structure type", expr->construct.struc);
            return false;
        }
        node_expr* args = expr->construct.elems;
        node_expr* default_args = stru->default_values;
        size_t i = 0, last = 0;
        for(; default_args; i++){
            var_t* member = vector_at(stru->members, i);
            node_expr* arg_expr = args;

            if(last < member->stack_ptr)
                gen_declare_mem(fptr, member->stack_ptr - last);
            last = member->stack_ptr;

            if(member->location == VAR_ARRAY){
                if(i + 1 < vector_size(stru->members)){
                    var_t* next_member = vector_at(stru->members, i+1);
                    gen_declare_mem(fptr, next_member->stack_ptr - member->stack_ptr);
                    last = next_member->stack_ptr;
                }else
                    gen_declare_mem(fptr, stru->size - member->stack_ptr);
                continue;
            }

            if(!args || args->type == tk_nothing){
                if(default_args->type == tk_nothing){
                    gen_declare_mem(fptr, SIZEOF_T(member->type));
                    last += SIZEOF_T(member->type);
                    default_args = default_args->next;
                    continue;
                }
                arg_expr = default_args;
            }

            if(args)
                args = args->next;

            if(!generate_constant(fptr, member->type, arg_expr))
                return false;

            last += SIZEOF_T(member->type);

            default_args = default_args->next;
            if(args && !default_args){
                print_context_expr("Too many initialisation values provided", args);
                return false;
            }
        }
    }else if(target_type.data == DATA_UNION){
        if(expr->type != tk_union){
            print_context_expr("Expected union construction", expr);
            return false;
        }
        union_t* unio = get_union_tk(target_type.repr);
        if(get_union_tk(expr->uconstruct.unio) != unio){
            print_context("Incompatible union type", expr->uconstruct.unio);
            return false;
        }
        node_stmt* member = get_union_member(unio, expr->uconstruct.member->str, expr->uconstruct.member->strlen);
        if(!member || member->type != tk_var_decl){
            print_context("Expected valid scalar member", expr->uconstruct.member);
            return false;
        }
        type_t member_type = type_from_tk(member->var_decl.var_type);
        if(!generate_constant(fptr, member_type, expr->uconstruct.elem))
            return false;
        size_t pad = unio->size - SIZEOF_T(member_type) - ((unio->is_variant) ? unio->align : 0);
        if(pad)
            gen_declare_mem(fptr, pad);
        if(unio->is_variant){
            enum_t* enu = get_enum(unio->str, unio->strlen);
            int64_t val;
            get_enum_val(enu, member->var_decl.identifier->str, member->var_decl.identifier->strlen, &val);
            gen_declare_int(fptr, val, unio->align);
        }
    }
    return true;
}

bool generate(const char* output_file, node_stmt* AST, bool library){
    HC_FILE fptr = HC_FOPEN_WRITE(output_file);

    // Start the code section (aka text section)
    HC_FPRINTF(fptr, "%s", target_text_section);
    gen_setup(fptr, library);

    // Init the function hashtable
    // Starting size of 256 tables, 16 functions each max.
    hashtable_init(funcs, 256);

    // Go through each statement and generate it
    for(; AST; AST = AST->next){
        if(!generate_stmt(fptr, AST, INVALID_TYPE, (scope_info){0,0,0,0,0})){
            gen_free(fptr);
            return false;
        }
    }

    //HC_WARN("Generating statements ended");

    // Go through all declared but not defined functions
    // to set them as extern for the linking stage
    HC_FPRINTF(fptr, "\n\n");
    for(size_t i = 0; i < funcs->size; i++){
        hashset_t set = funcs->sets[i];
        for(size_t j = 0; j < set.size; j++){
            func_t* func = &((func_t*)set.pairs)[j];
            if(func->flags & FLAG_FDEF) continue;
            gen_declare_extern(fptr, func->str, func->strlen, "function");
        }
    }

    // Go through all declared but not defined functions
    // in classes and modules
    for(size_t i = 0; i < vector_size(structs); i++){
        struct_t* stru = vector_at(structs, i);
        for(size_t j = 0; j < vector_size(stru->funcs); j++){
            func_t* method = vector_at(stru->funcs, j);
            if(!(method->flags & FLAG_FDEF))
                gen_declare_extern_method(fptr, stru->str, stru->strlen, method->str, method->strlen);
        }
    }
    for(size_t i = 0; i < vector_size(modules); i++){
        module_t* mod = vector_at(modules, i);
        for(size_t j = 0; j < vector_size(mod->funcs); j++){
            func_t* method = vector_at(mod->funcs, j);
            if(!(method->flags & FLAG_FDEF))
                gen_declare_extern_method(fptr, mod->str, mod->strlen, method->str, method->strlen);
        }
    }

    // Data section
    HC_FPRINTF(fptr, "\n\n%s", target_data_section);

    // Create a static temporary space for floating point operations
    gen_start_global_decl(fptr, "__FP_TMP", 8, true);
    gen_declare_int(fptr, 0, 8);

    // Create a static general purpose temporary space
    gen_start_global_decl(fptr, "__GP_TMP", 8, true);
    gen_declare_mem(fptr, 64);

    // Go through all global variables and add them in the .data section
    for(size_t i = 0; i < vector_size(vars); i++){
        var_t* var = vector_at(vars, i);
        if(var->location != VAR_GLOBAL && var->location != VAR_GLOBAL_ARR){
            print_context_ex("BUG : Non-global variable is left at the end of program", var->str, var->strlen);
            gen_free(fptr);
            return false;
        }
        if(var->flags & FLAG_EXTERN){
            if(var->location == VAR_GLOBAL && var->stack_ptr != ~0){
                print_context_ex("Cannot give value to external global variable", var->str, var->strlen);
                gen_free(fptr);
                return false;
            }
            gen_declare_extern(fptr, var->str, var->strlen, "data");
            continue;
        }
        gen_start_global_decl(fptr, var->str, var->strlen, var->flags & FLAG_PRIVATE);
        if(var->location == VAR_GLOBAL_ARR)
            gen_declare_mem(fptr, ALIGN(var->stack_ptr, 8));
        else if(var->stack_ptr != ~0){
            size_t var_sz = SIZEOF_T(var->type);
            node_expr* expr = vector_at(global_var_values, var->stack_ptr);
            if(!generate_constant(fptr, var->type, expr)){
                gen_free(fptr);
                return false;
            }
            gen_declare_mem(fptr, ALIGN(var_sz, 8) - var_sz);
        }else{
            size_t var_sz = SIZEOF_T(var->type);
            gen_declare_mem(fptr, ALIGN(var_sz, 8));
        }
    }

    // Go through all modules and add them in .data section
    for(size_t i = 0; i < vector_size(modules); i++){
        module_t* mod = vector_at(modules, i);
        if(mod->external){
            gen_declare_extern(fptr, mod->str, mod->strlen, "data");
            continue;
        }
        gen_start_global_decl(fptr, mod->str, mod->strlen, false);
        size_t last = 0;
        node_expr* vals = mod->vals;
        for(size_t j = 0; j < vector_size(mod->vars); j++){
            var_t* var = vector_at(mod->vars, j);
            if(last < var->stack_ptr)
                gen_declare_mem(fptr, var->stack_ptr - last);
            last = var->stack_ptr;
            if(var->location == VAR_STACK){
                if(vals->type != tk_nothing){
                    if(!generate_constant(fptr, var->type, vals)){
                        gen_free(fptr);
                        return false;
                    }
                }else
                    gen_declare_mem(fptr, SIZEOF_T(var->type));
                vals = vals->next;
                last += SIZEOF_T(var->type);
            }else if(var->location == VAR_ARRAY){
                size_t arr_size;
                if(j + 1 < vector_size(mod->vars)){
                    var_t* next_var = (var_t*) vector_at(mod->vars, j + 1);
                    arr_size = next_var->stack_ptr - var->stack_ptr;
                    last = next_var->stack_ptr;
                }else
                    arr_size = mod->size - var->stack_ptr;
                gen_declare_mem(fptr, arr_size);
            }
        }
        if(last % 8)
            gen_declare_mem(fptr, ALIGN(last, 8) - last);
    }

    // Generate the read only data section for string literals
    HC_FPRINTF(fptr, "\n\n%s", target_rodata_section);
    size_t i = 0;
    for(node_term* str_lit = str_literals; str_lit; str_lit = &str_lit->next->term, i++)
        gen_declare_str_lit(fptr, i, str_lit->str, str_lit->strlen);
    i = 0;
    for(node_term* float_lit = float_literals; float_lit; float_lit = &float_lit->next->term, i++)
        gen_declare_float_lit(fptr, i, float_lit->str, float_lit->strlen);

    gen_free(fptr);
    return true;
}
