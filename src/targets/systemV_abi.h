#ifndef SYSTEM_V_ABI_H
#define SYSTEM_V_ABI_H

#include "../generator/target_requirements.h"
#include "../generator/regs.h"
#include "../generator/hc_types.h"
#include "../generator/generator.h"

// Load a QWORD / DWORD from a global (offset optionally) in a XMM register
static void x64_load_global_XMM(HC_FILE fptr, size_t which, const char* str, size_t strlen, size_t offset, bool dp){
    HC_FPRINTF(fptr, "\tmovs%c xmm%lu, %s [%.*s+%lu]\n", dp?'d':'s', which, dp?"QWORD":"DWORD", (int)strlen, str, offset);
}

// Save a XMM register in a QWORD / DWORD on the stack
static void x64_save_stack_XMM(HC_FILE fptr, size_t which, size_t offset, bool dp){
    HC_FPRINTF(fptr, "\tmovs%c %s [rsp+%lu], xmm%lu\n", dp?'d':'s', dp?"QWORD":"DWORD", offset, which);
}

// Save a XMM register in a QWORD / DWORD pointed to by register, with offset
static void x64_save_ptr_XMM(HC_FILE fptr, size_t which, reg_t* ptr, size_t offset, bool dp){
    HC_FPRINTF(fptr, "\tmovs%c %s [%s+%lu], xmm%lu\n", dp?'d':'s', dp?"QWORD":"DWORD", ptr->name, offset, which);
}

// Number of integer arguments that can be passed in registers
#define SYSV_REG_ARGS 6

// Registers used for passing arguments, in order
static reg_t* sysV_reg_order[SYSV_REG_ARGS] = {0};
static reg_t* sysV_return_regs[2] = {0};
static reg_t* sysV_xmm_count;

// Load an integer argument, either on a register or on the stack
static void sysV_load_int_arg(HC_FILE fptr, size_t arg_index, size_t* stack_ptr, node_expr* expr, type_t target){
    if(!target.ptr_depth && target.size < 8)
        target = (type_t){8, target.sign ? GET_DUMMY_TYPE(int64) : GET_DUMMY_TYPE(uint64), target.sign, DATA_INT, 8, 0};
    reg_t* target_reg = (arg_index < SYSV_REG_ARGS) ? free_reg(sysV_reg_order[arg_index]) : GET_FREE_REG(8);
    reg_t* reg = generate_expr(fptr, expr, target, target_reg);
    if(reg != target_reg && arg_index < SYSV_REG_ARGS)
        reg = transfer_reg(fptr, reg, target_reg);
    if(arg_index >= SYSV_REG_ARGS){
        *stack_ptr -= 8;
        gen_save_stack(fptr, free_reg(reg), *stack_ptr);
    }
}

// Number of float arguments that can be passed in XMM registers
#define SYSV_XMM_ARGS 8

// Load a float argument, either in a XMM register or on the stack
static void sysV_load_float_arg(HC_FILE fptr, size_t arg_index, size_t* stack_ptr, node_expr* expr, bool dp){
    if(!generate_float_expr(fptr, expr))
        fail_gen_expr(fptr);
    if(arg_index < SYSV_XMM_ARGS){
        gen_save_global_float(fptr, "__FP_TMP", 8, dp);
        x64_load_global_XMM(fptr, arg_index, "__FP_TMP", 8, 0, dp);
    }else{
        *stack_ptr -= 8;
        gen_save_stack_float(fptr, *stack_ptr, 0);
    }
}

/*
Operates checks on a structure and modifies the count of integer / float arguments to pass.
Also, if provided, should_be_float (array of two booleans) will be modified:
 - If struct size <= 8, will set should_be_float[0] to wether struct will be stored in XMM register
 - If struct size <= 16, will set should_be_float[0] and should_be_float[1] to wether
    the first eightbyte will be stored in XMM and wether the second eightbyte will be stored in XMM

Returns...
 - If struct is an argument:
     wether struct should be passed as eightbytes (false) or be passed on the stack (true).
 - If struct is return value:
     wether struct will be returned as eightbytes (false) or should have its address passed
     as the first argument of the function (true).
*/
static bool sysV_check_struct(struct_t* stru, size_t* int_count, size_t* float_count, bool* should_be_float){
    if(stru->size <= 8){
        *should_be_float = true;
        for(size_t i = 0; *should_be_float && i < vector_size(stru->members); i++){
            var_t* member = (var_t*) vector_at(stru->members, i);
            if(member->location == VAR_ARRAY && member->type.ptr_depth == 1 && member->type.data == DATA_FLOAT)
                continue;
            if(member->type.ptr_depth || member->type.data != DATA_FLOAT)
                *should_be_float = false;
        }
        if(*should_be_float){
            if(*float_count >= SYSV_XMM_ARGS)
                return true;
            (*float_count)++;
        }else{
            if(*int_count >= SYSV_REG_ARGS)
                return true;
            (*int_count)++;
        }
    }else if(stru->size <= 16){
        // first eightbyte
        should_be_float[0] = true;
        size_t i = 0;
        for(; i < vector_size(stru->members); i++){
            var_t* member = (var_t*) vector_at(stru->members, i);
            if(member->stack_ptr >= 8)
                break;
            if(member->location == VAR_ARRAY && member->type.ptr_depth == 1 && member->type.data == DATA_FLOAT)
                continue;
            if(member->type.ptr_depth  || member->type.data != DATA_FLOAT)
                should_be_float[0] = false;
        }

        // Check compatibility with eightbyte separation
        if(i >= vector_size(stru->members) || ((var_t*)vector_at(stru->members, i))->stack_ptr != 8)
            return true;

        // second eightbyte
        should_be_float[1] = true;
        for(; should_be_float && i < vector_size(stru->members); i++){
            var_t* member = (var_t*) vector_at(stru->members, i);
            if(member->location == VAR_ARRAY && member->type.ptr_depth == 1 && member->type.data == DATA_FLOAT)
                continue;
            if(member->type.ptr_depth || member->type.data != DATA_FLOAT)
                should_be_float[1] = false;
        }
        // Check if value can be passed in registers
        // or has to be passed on the stack
        size_t fcount = should_be_float[0] ? 1 : 0;
        size_t icount = 1 - fcount;
        if(should_be_float[1])
            fcount++;
        else
            icount++;
        if(*float_count + fcount > SYSV_XMM_ARGS || *int_count + icount > SYSV_REG_ARGS)
            return true;
        *float_count += fcount;
        *int_count += icount;
    }else
        return true;
    return false;
}

// Same as sysV_check_struct, except we check unions
// should_be_float should point to a single boolean
static bool sysV_check_union(union_t* unio, size_t* int_count, size_t* float_count, bool* should_be_float){
    if(unio->size <= 8){
        *should_be_float = true;
        for(node_stmt* ptr = unio->members; ptr; ptr = ptr->next){
            type_t member_type;
            if(ptr->type == tk_var_decl)
                member_type = type_from_tk(ptr->var_decl.var_type);
            else
                member_type = type_from_tk(ptr->arr_decl.elem_type);
            if(member_type.ptr_depth || member_type.data != DATA_FLOAT)
                *should_be_float = false;
        }
        if(*should_be_float){
            if(*float_count >= SYSV_XMM_ARGS)
                return true;
            (*float_count)++;
        }else{
            if(*int_count >= SYSV_REG_ARGS)
                return true;
            (*int_count)++;
        }
    }else if(unio->size <= 16){
        *should_be_float = true;
        for(node_stmt* ptr = unio->members; ptr; ptr = ptr->next){
            type_t member_type;
            if(ptr->type == tk_var_decl)
                member_type = type_from_tk(ptr->var_decl.var_type);
            else
                member_type = type_from_tk(ptr->arr_decl.elem_type);
            if(member_type.ptr_depth || member_type.data != DATA_FLOAT)
                *should_be_float = false;
        }
        if(*should_be_float){
            if(*float_count + 2 > SYSV_XMM_ARGS)
                return true;
            (*float_count) += 2;
        }else{
            if(*int_count + 2 > SYSV_REG_ARGS)
                return true;
            (*int_count) += 2;
        }
    }else
        return true;
    return false;
}

/*
Since I'm fucking dumb and I decided singly linked lists were a good idea,
I'm gonna have to use recursion to go through a linked list in reverse order.

Will first go through each argument and calculate the total amount of integer and float arguments
and will also calculate the amount of stack space needed for extra / struct / union arguments.
Then, it will load in reverse order the arguments needed for the function and store them where they're
supposed to be stored.

Everything the function needs to keep track is pointed to by an argument.
int_idx     : Number of integer arguments / current integer argument loaded.
float_idx   : Number of float arguments / current float argument loaded.
stack_ptr   : The space needed on the stack / pointer to current argument on the stack.
arg         : The current argument.
arg_expr    : The expression provided for the current argument.

The function stops when no more arguments and no more expressions are provided.
Normally, the recursion chain will first increment int_idx, float_idx and stack_ptr,
then will decrement them until they reach their original value.
*/
static void sysV_load_arg(HC_FILE fptr, size_t* int_idx, size_t* float_idx, size_t* stack_ptr, node_var_decl* arg, node_expr* arg_expr){
    if(!arg && arg_expr){
        print_context_expr("Excess argument", arg_expr);
        fail_gen_expr(fptr);
    }else if(!arg){
        // Base case : no more arguments and no more values provided -> end of function call
        // We need to include the size of every argument we need to pass on the stack.
        // (So every excess arg after we used all registers)
        if(*int_idx > SYSV_REG_ARGS)
            *stack_ptr += (*int_idx - SYSV_REG_ARGS) * 8;
        else if(*float_idx > SYSV_XMM_ARGS)
            *stack_ptr += (*float_idx - SYSV_XMM_ARGS) * 8;

        // We want to allocate the space needed on the stack first.
        if(*stack_ptr){
            *stack_ptr = ALIGN(*stack_ptr, 16);
            gen_alloc_stack(fptr, *stack_ptr);
            stack_sz += *stack_ptr;
        }
        return;
    }

    // Check if no argument is provided
    bool var_arg = arg->type == tk_var_args;
    if((!arg_expr || arg_expr->type == tk_nothing) && !var_arg && !arg->expr){
        print_context("Expected argument to be provided", arg->var_type);
        fail_gen_expr(fptr);
    }else if(var_arg && !arg_expr){
        // End the recursive algorithm
        gen_clear_reg(fptr, sysV_return_regs[0]);
        sysV_load_arg(fptr, int_idx, float_idx, stack_ptr, NULL, NULL);
        return;
    }else if(var_arg && arg_expr->type == tk_nothing){
        HC_WARN("Cannot give no argument in variable arguments!");
        fail_gen_expr(fptr);
    }

    // Utility variables for structures / unions
    struct_t* stru;
    union_t* unio;
    bool xmm_stored[2];
    bool stack_passed = false;

    // Get the argument's type as well as the expression's type
    type_t expr_type = typeof_expr(arg_expr);
    type_t arg_type = var_arg ? expr_type : type_from_tk(arg->var_type);

    if(var_arg && !expr_type.ptr_depth && expr_type.data != DATA_INT && expr_type.data != DATA_FLOAT){
        print_context_expr("Can only pass integer or float types in variable arguments", arg_expr);
        fail_gen_expr(fptr);
    }

    // Verify if expression is compatible with argument
    if(DATAOF_T(arg_type) != DATAOF_T(expr_type) || arg_type.ptr_depth != expr_type.ptr_depth){
        print_context_expr("Incompatible argument type", arg_expr);
        print_context("Expected argument type", arg->var_type);
        print_type("Type ", expr_type, " is not compatible!");
        fail_gen_expr(fptr);
    }

    // This is a crucial step, we must know in advance the number of
    // int / float args we are gonna pass in registers and the stack
    // size of the function call.
    if(arg_type.ptr_depth || arg_type.data == DATA_INT)
        (*int_idx)++;
    else if(arg_type.data == DATA_FLOAT)
        (*float_idx)++;
    else if(arg_type.data == DATA_STRUCT){
        stru = get_struct_tk(arg_type.repr);
        stack_passed = sysV_check_struct(stru, int_idx, float_idx, xmm_stored);
        if(stack_passed)
            *stack_ptr += ALIGN(stru->size, 8);
    }else if(arg_type.data == DATA_UNION){
        unio = get_union_tk(arg_type.repr);
        stack_passed = sysV_check_union(unio, int_idx, float_idx, xmm_stored);
        if(stack_passed)
            *stack_ptr += ALIGN(unio->size, 8);
    }

    // Recursive call to do next argument before doing this one
    sysV_load_arg(fptr, int_idx, float_idx, stack_ptr,
            (var_arg) ? arg : &arg->next->var_decl,
            (arg_expr) ? arg_expr->next : NULL);

    // Generate the loading of the argument
    if(arg_type.ptr_depth || arg_type.data == DATA_INT)
        sysV_load_int_arg(fptr, --(*int_idx), stack_ptr, arg_expr, arg_type);
    else if(arg_type.data == DATA_FLOAT){
        sysV_load_float_arg(fptr, --(*float_idx), stack_ptr, arg_expr, var_arg || arg_type.size == 8);
        if(var_arg && *float_idx < SYSV_XMM_ARGS)
            gen_inc_reg(fptr, sysV_xmm_count);
    }else if(arg_type.data == DATA_STRUCT){
        reg_t* ptr = alloc_reg(GET_MASK_REG(target_address_size, allowed_copy_regs), false);
        if(stack_passed){
            *stack_ptr -= ALIGN(stru->size, 8);
            gen_load_stack_ptr(fptr, ptr, *stack_ptr);
            save_struct(fptr, stru, ptr, arg_expr);
        }else{
            gen_load_global_ptr(fptr, ptr, "__GP_TMP", 8);
            save_struct(fptr, stru, ptr, arg_expr);
            if(stru->size > 8){
                if(xmm_stored[1])
                    x64_load_global_XMM(fptr, --(*float_idx), "__GP_TMP", 8, 8, (stru->size - 8) == 8);
                else
                    gen_load_global_offset(fptr, alloc_reg(sysV_reg_order[--(*int_idx)], false), "__GP_TMP", 8, 8);
            }
            if(xmm_stored[0])
                x64_load_global_XMM(fptr, --(*float_idx), "__GP_TMP", 8, 0, true);
            else
                gen_load_global_offset(fptr, alloc_reg(sysV_reg_order[--(*int_idx)], false), "__GP_TMP", 8, 0);
        }
        (void) free_reg(ptr);
    }else if(arg_type.data == DATA_UNION){
        reg_t* ptr = alloc_reg(GET_MASK_REG(target_address_size, allowed_copy_regs), false);
        if(stack_passed){
            *stack_ptr -= ALIGN(unio->size, 8);
            gen_load_stack_ptr(fptr, ptr, *stack_ptr);
            save_union(fptr, unio, ptr, arg_expr);
        }else{
            gen_load_global_ptr(fptr, ptr, "__GP_TMP", 8);
            save_union(fptr, unio, ptr, arg_expr);
            if(unio->size > 8){
                if(xmm_stored[0])
                    x64_load_global_XMM(fptr, --(*float_idx), "__GP_TMP", 8, 8, true);
                else
                    gen_load_global_offset(fptr, alloc_reg(sysV_reg_order[--(*int_idx)], false), "__GP_TMP", 8, 8);
            }
            if(xmm_stored[0])
                x64_load_global_XMM(fptr, --(*float_idx), "__GP_TMP", 8, 0, true);
            else
                gen_load_global_offset(fptr, alloc_reg(sysV_reg_order[--(*int_idx)], false), "__GP_TMP", 8, 0);
        }
        (void) free_reg(ptr);
    }
}

void sysV_init(){
    reg_t* reg_order[SYSV_REG_ARGS] = {
        get_named_reg("rdi", 3, registers),
        get_named_reg("rsi", 3, registers),
        get_named_reg("rdx", 3, registers),
        get_named_reg("rcx", 3, registers),
        get_named_reg("r8", 2, registers),
        get_named_reg("r9", 2, registers)
    };
    for(size_t i = 0; i < SYSV_REG_ARGS; i++)
        sysV_reg_order[i] = reg_order[i];
    sysV_return_regs[0] = get_named_reg("rax", 3, registers);
    sysV_return_regs[1] = get_named_reg("rdx", 3, registers);
    sysV_xmm_count = get_named_reg("al", 2, registers);
}

// Moves n bytes from register op to memory [ptr]
static void x64_move_ptr_bytes(HC_FILE fptr, reg_t* op, reg_t* ptr, size_t bytes){
    if(bytes == 8)
        gen_save_ptr(fptr, op, ptr);
    else if(bytes == 4)
        gen_save_ptr(fptr, op->children, ptr);
    else if(bytes == 2)
        gen_save_ptr(fptr, op->children->children, ptr);
    else if(bytes == 1)
        gen_save_ptr(fptr, op->children->children->children, ptr);
    else if(bytes == 3){
        x64_move_ptr_bytes(fptr, op, ptr, 2);
        gen_shl_reg(fptr, op, 2 * 8);
        gen_add_reg(fptr, ptr, 2);
        x64_move_ptr_bytes(fptr, op, ptr, 1);
    }else{  // bytes = 5, 6 or 7
        x64_move_ptr_bytes(fptr, op, ptr, 4);
        gen_shl_reg(fptr, op, 4 * 8);
        gen_add_reg(fptr, ptr, 4);
        x64_move_ptr_bytes(fptr, op, ptr, bytes - 4);
    }
}

size_t generate_cfunc_call(HC_FILE fptr, node_expr* expr, func_t* func, reg_t* struct_ptr){
    reg_t* masked_regs[MAX_REGS];

    // The amount of bytes allocated on the stack
    size_t func_call_sz = SIZEOF_T(func->type) ? 8 : 0, args_sz = 0;
    size_t int_count = 0, float_count = 0;
    size_t float_vargs = 0;

    // Get the occupied registers to save on the stack
    // (because a function can affect registers)
    int n = get_mask_occup_regs(ALL_REGS, true, registers, masked_regs);
    for(int i = 0; i < n; i++){
        if(masked_regs[i] == struct_ptr)
            continue;
        func_call_sz = ALIGN(func_call_sz, masked_regs[i]->size);
        func_call_sz += masked_regs[i]->size;
    }
    func_call_sz = ALIGN(func_call_sz, 16);
    if(func_call_sz){
        gen_alloc_stack(fptr, func_call_sz);
        stack_sz += func_call_sz;
    }

    // Save each occupied register on the stack
    size_t arg_ptr = struct_ptr ? 8 : 0;
    if(struct_ptr)
        gen_save_stack(fptr, struct_ptr, func_call_sz - 8);
    for(int i = 0; i < n; i++){
        if(masked_regs[i] == struct_ptr)
            continue;
        arg_ptr = ALIGN(arg_ptr, masked_regs[i]->size);
        arg_ptr += masked_regs[i]->size;
        gen_save_stack(fptr, masked_regs[i], func_call_sz - arg_ptr);
    }

    // Free every register to be able to use them for evaluating expressions
    for(size_t i = 0; i < REGISTER_COUNT; i++)
        free_reg(&registers[i]);

    // Tracks if return value (if its a struct / union) is given in registers
    bool ret_in_regs = true;
    bool xmm_stored[2];

    // If return value is a structure / union
    if(DATAOF_T(func->type) == DATA_STRUCT){
        struct_t* stru = get_struct_tk(func->type.repr);
        size_t _tmp1 = 0, _tmp2 = 0;
        if(sysV_check_struct(stru, &_tmp1, &_tmp2, xmm_stored))
            int_count++, ret_in_regs = false;
    }else if(DATAOF_T(func->type) == DATA_UNION){
        union_t* unio = get_union_tk(func->type.repr);
        size_t _tmp1 = 0, _tmp2 = 0;
        if(sysV_check_union(unio, &_tmp1, &_tmp2, xmm_stored))
            int_count++, ret_in_regs = false;
    }

    if(int_count)
        gen_move_reg(fptr, alloc_reg(sysV_reg_order[0], false), struct_ptr);
    (void) alloc_reg(sysV_return_regs[0], false);

    // Load arguments
    size_t stack_sz_before = stack_sz;
    sysV_load_arg(fptr, &int_count, &float_count, &args_sz, &func->args->var_decl, expr->func.args);
    func_call_sz += stack_sz - stack_sz_before;

    // Call the function
    if(func->flags & FLAG_EXTERN)
        gen_call_extern_func(fptr, func->str, func->strlen);
    else
        gen_call_func(fptr, func->str, func->strlen);

    // Free every register that wasnt used before
    for(size_t i = 0; i < REGISTER_COUNT; i++)
        free_reg(&registers[i]);

    arg_ptr = struct_ptr ? 8 : 0;

    // Move the struct from the registers to memory
    if(struct_ptr && ret_in_regs){
        struct_ptr = GET_MASK_REG(8, ALL_REGS_EXCEPT(REG(0) | REG(3)));
        gen_load_stack(fptr, struct_ptr, func_call_sz - arg_ptr);
        if(func->type.size <= 8){
            if(xmm_stored[0])
                x64_save_ptr_XMM(fptr, 0, struct_ptr, 0, func->type.size == 8);
            else
                x64_move_ptr_bytes(fptr, sysV_return_regs[0], struct_ptr, func->type.size);
        }else{
            size_t xmm = 0, reg = 0;
            if(xmm_stored[0])
                x64_save_ptr_XMM(fptr, xmm++, struct_ptr, 0, true);
            else
                gen_save_ptr(fptr, sysV_return_regs[reg++], struct_ptr);
            if(xmm_stored[1])
                x64_save_ptr_XMM(fptr, xmm, struct_ptr, 8, (func->type.size - 8) == 8);
            else{
                if(reg)
                    gen_add_reg(fptr, struct_ptr, 8);
                x64_move_ptr_bytes(fptr, sysV_return_regs[reg], struct_ptr, func->type.size - 8);
            }
        }
    }
    else if(!SIZEOF_T(func->type));
    else if(func->type.ptr_depth || func->type.data == DATA_INT)
        gen_save_stack(fptr, sysV_return_regs[0], 0);
    else if(func->type.data == DATA_FLOAT)
        x64_save_stack_XMM(fptr, 0, 0, func->type.size == 8);

    // Retrieve every register's old value off the stack
    for(int i = 0; i < n; i++){
        if(masked_regs[i] == struct_ptr)
            continue;
        arg_ptr = ALIGN(arg_ptr, masked_regs[i]->size);
        arg_ptr += masked_regs[i]->size;
        gen_load_stack(fptr, alloc_reg(masked_regs[i], false), func_call_sz - arg_ptr);
    }

    HC_DEBUG_PRINT(func_call_sz, "%lu");
    return func_call_sz;
}

#endif
