#ifndef HCC_REGS_H
#define HCC_REGS_H

// Register related operations
#include "../dev/libs.h"
#include "target_requirements.h"

// Find if a register is free or not depending on its children
bool is_reg_free(reg_t* reg);

// Get a free register with a certain size or NULL if there are none
reg_t* get_free_reg(size_t size, reg_t* reg_arr);
#define GET_FREE_REG(sz) get_free_reg((sz), registers)


// Get a occupied / free register masked with a reg_mask or NULL if there are none
reg_t* get_occup_mask_reg(size_t size, bool occup, reg_mask mask, reg_t* reg_arr);
#define GET_MASK_REG(sz, m) get_occup_mask_reg((sz), false, (m), registers)
#define GET_OCC_MASK_REG(sz, m) get_occup_mask_reg((sz), true, (m), registers)
#define GET_OP_REG1(sz, op) get_occup_mask_reg((sz), false, allowed_##op##_regs1, registers)
#define GET_OCC_OP_REG1(sz, op) get_occup_mask_reg((sz), true, allowed_##op##_regs1, registers)
#define GET_OP_REG2(sz, op) get_occup_mask_reg((sz), false, allowed_##op##_regs2, registers)
#define GET_OCC_OP_REG2(sz, op) get_occup_mask_reg((sz), true, allowed_##op##_regs2, registers)

// Get all registers in mask
// Returns number of masked registers
int get_mask_regs(reg_mask mask, reg_t* reg_arr, reg_t* masked_regs[MAX_REGS]);
#define FIND_MASK_REGS(m, buff) get_mask_regs((m), registers, (buff))

// Get all occupied / free registers in mask
// Returns number of masked registers
int get_mask_occup_regs(reg_mask mask, bool occup, reg_t* reg_arr, reg_t* masked_regs[MAX_REGS]);

// Get reg with name
reg_t* get_named_reg(const char* str, size_t strlen, reg_t* reg_arr);

reg_t* alloc_reg(reg_t* reg, bool sign);
reg_t* free_reg(reg_t* reg);

reg_t* transfer_reg(HC_FILE fptr, reg_t* a, reg_t* b);
reg_t* get_lower_nbytes(HC_FILE fptr, reg_t* op, size_t n);

#endif
