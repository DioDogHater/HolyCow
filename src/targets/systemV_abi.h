#ifndef SYSTEM_V_ABI_H
#define SYSTEM_V_ABI_H

#include "../generator/generator.h"

size_t generate_cfunc_call(HC_FILE fptr, node_expr* expr, func_t* func, reg_t* struct_ptr){
    reg_t* masked_regs[MAX_REGS];

    // The amount of bytes allocated on the stack
    size_t func_call_sz = (func->type.ptr_depth || func->type.data == DATA_STRUCT || func->type.data == DATA_UNION) ? target_address_size : func->type.size;

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

    if(!func->type.ptr_depth && (func->type.data == DATA_STRUCT || func->type.data == DATA_UNION)){
        if(struct_ptr) gen_save_stack(fptr, free_reg(struct_ptr), 0);
        else{
            reg_t* tmp = GET_FREE_REG(target_address_size);
            gen_set_reg(fptr, tmp, "0", 1);
            gen_save_stack(fptr, tmp, 0);
        }
    }

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
    arg_expr = expr->func.args;
    for(node_var_decl* arg = &func->args->var_decl; arg; arg = &arg->next->var_decl){
        node_expr* next_arg = NULL;

        // Variable arguments
        if(arg->type == tk_var_args){
            arg_ptr = ALIGN(arg_ptr, 8);
            if(((node_expr_stmt*)arg)->expr){
                char buff[256];
                reg_t* tmp = alloc_reg(GET_FREE_REG(8), false);
                gen_set_reg(fptr, tmp, buff, snprintf(buff, 255, "%lu", varg_count));
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
                }
                // Float value
                else if(expr_type.data == DATA_FLOAT){
                    if(!generate_float_expr(fptr, arg_expr))
                        fail_gen_expr(fptr);
                    gen_save_stack_float(fptr, arg_ptr);
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
        if(DATAOF_T(expr_type) != DATAOF_T(arg_type) ||
            expr_type.ptr_depth != arg_type.ptr_depth){
            print_context_expr("Incompatible argument type", arg_expr);
        print_context("Expected argument type", arg->var_type);
        print_type("Type ", expr_type, " is not compatible!");
        fail_gen_expr(fptr);
            }

            arg_ptr = ALIGN(arg_ptr, arg_align);
            if(expr_type.ptr_depth || expr_type.data == DATA_INT){
                reg_t* tmp = EXPR_ONCE(arg_expr, arg_type, NULL);
                gen_save_stack(fptr, tmp, arg_ptr);
            }else if(expr_type.data == DATA_FLOAT){
                if(!generate_float_expr(fptr, arg_expr))
                    fail_gen_expr(fptr);
                gen_save_stack_float(fptr, arg_ptr);
            }else if(expr_type.data == DATA_STRUCT || expr_type.data == DATA_UNION){
                reg_t* tmp = alloc_reg(GET_MASK_REG(target_address_size, allowed_copy_regs), false);
                gen_load_stack_ptr(fptr, tmp, arg_ptr);
                if(expr_type.data == DATA_STRUCT){
                    struct_t* stru = get_struct_tk(expr_type.repr);
                    if(!save_struct(fptr, stru, tmp, arg_expr))
                        return false;
                }else{
                    union_t* unio = get_union_tk(expr_type.repr);
                    if(!save_union(fptr, unio, tmp, arg_expr))
                        return false;
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
    gen_call_func(fptr, func->str, func->strlen);

    // Retrieve every register off the stack
    arg_ptr = 0;
    n = get_mask_occup_regs(ALL_REGS, true, registers, masked_regs);
    for(int i = 0; i < n; i++){
        if(struct_ptr && masked_regs[i]->name == struct_ptr->name) continue;
        arg_ptr = ALIGN(arg_ptr, masked_regs[i]->size);
        arg_ptr += masked_regs[i]->size;
        gen_load_stack(fptr, masked_regs[i], func_call_sz - arg_ptr);
    }
    return func_call_sz;
}

#endif
