#include "regs.h"
#include "target_requirements.h"

// Find if a register is free or not depending on its children
bool is_reg_free(reg_t* reg){
    if(!reg || reg->occupied)
        return false;
    for(reg_t* child = reg->children; child && child->name; child++){
        if(!is_reg_free(child))
            return false;
    }
    return true;
}

// Get a free register with a certain size or NULL if there are none
reg_t* get_free_reg(size_t size, reg_t* reg_arr){
    for(; reg_arr && reg_arr->name; reg_arr++){
        if(reg_arr->size == size && is_reg_free(reg_arr)){
            return reg_arr;
        }else if(reg_arr->size != size && reg_arr->children){
            reg_t* reg = get_free_reg(size, reg_arr->children);
            if(reg)
                return reg;
        }
    }
    return NULL;
}

// Get a occupied / free register masked with a reg_mask or NULL if there are none
reg_t* get_occup_mask_reg(size_t size, bool occup, reg_mask mask, reg_t* reg_arr){
    for(; reg_arr && reg_arr->name; reg_arr++){
        if(reg_arr->occupied == OCCUP_IGNORE)
            continue;
        if(REG_IN_MASK(reg_arr, mask) && reg_arr->size == size && ((!occup && is_reg_free(reg_arr)) || (occup && reg_arr->occupied)))
            return reg_arr;
        else if(reg_arr->size != size && reg_arr->children){
            reg_t* reg = get_occup_mask_reg(size, occup, mask, reg_arr->children);
            if(reg) return reg;
        }
    }
    return NULL;
}

// Get all registers in mask
// Returns number of masked registers
int get_mask_regs(reg_mask mask, reg_t* reg_arr, reg_t* masked_regs[MAX_REGS]){
    int n = 0;
    for(; reg_arr && reg_arr->name; reg_arr++){
        if(REG_IN_MASK(reg_arr, mask))
            masked_regs[n++] = reg_arr;
        if(reg_arr->children)
            n += get_mask_regs(mask, reg_arr->children, &masked_regs[n]);
    }
    return n;
}

// Get all occupied / free registers in mask
// Returns number of masked registers
int get_mask_occup_regs(reg_mask mask, bool occup, reg_t* reg_arr, reg_t* masked_regs[MAX_REGS]){
    int n = 0;
    for(; reg_arr && reg_arr->name; reg_arr++){
        if(reg_arr->occupied == OCCUP_IGNORE)
            continue;
        if(REG_IN_MASK(reg_arr, mask) && occup && reg_arr->occupied){
            masked_regs[n++] = reg_arr;
            continue;
        }else if(REG_IN_MASK(reg_arr, mask) && !occup && is_reg_free(reg_arr))
            masked_regs[n++] = reg_arr;
        if(reg_arr->children)
            n += get_mask_occup_regs(mask, occup, reg_arr->children, &masked_regs[n]);
    }
    return n;
}

// Get reg with name
reg_t* get_named_reg(const char* str, size_t strlen, reg_t* reg_arr){
    for(; reg_arr && reg_arr->name; reg_arr++){
        size_t reg_strlen = 0;
        for(const char* ptr = reg_arr->name; *ptr; ptr++, reg_strlen++);
        if(reg_strlen == strlen && strncmp(str, reg_arr->name, strlen) == 0)
            return reg_arr;
        if(reg_arr->children){
            reg_t* reg = get_named_reg(str, strlen, reg_arr->children);
            if(reg) return reg;
        }
    }
    return NULL;
}

reg_t* alloc_reg(reg_t* reg, bool sign){
    if(!reg)
        return NULL;
    reg->occupied = ((sign) ? OCCUP_SIGNED : OCCUP_UNSIGNED);
    for(reg_t* child = reg->children; child && child->name; child++)
        (void) alloc_reg(child, sign);
    return reg;
}

 reg_t* free_reg(reg_t* reg){
    if(!reg)
        return NULL;
    reg->occupied = OCCUP_NONE;
    for(reg_t* child = reg->children; child && child->name; child++)
        (void) free_reg(child);
    return reg;
}

// Move value from a -> b
// Frees a and occupies b instead
reg_t* transfer_reg(HC_FILE fptr, reg_t* a, reg_t* b){
    if(!a || !b)
        return NULL;
    bool sign = a->occupied == OCCUP_SIGNED;
    if(a->size < b->size)
        gen_movex_reg(fptr, b, a, sign);
    else if(a->size > b->size){
        a = get_lower_nbytes(fptr, a, b->size);
        return transfer_reg(fptr, a, b);
    }else
        gen_move_reg(fptr, b, a);
    free_reg(a);
    alloc_reg(b, sign);
    return b;
}

// Get lower n bytes of a value
// EX: Get the 2 lower bytes of an 8 byte value
reg_t* get_lower_nbytes(HC_FILE fptr, reg_t* op, size_t n){
    reg_t* child = op->children;
    for(; child && child->size != n; child = child->children);
    bool sign = op->occupied == OCCUP_SIGNED;
    if(child){
        (void) free_reg(op);
        return alloc_reg(child, sign);
    }
    gen_push_stack(fptr, op);
    (void) free_reg(op);
    reg_t* tmp = alloc_reg(GET_FREE_REG(n), sign);
    gen_load_stack(fptr, tmp, 0);
    gen_dealloc_stack(fptr, op->size);
    return tmp;
}
