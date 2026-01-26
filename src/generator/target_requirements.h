#ifndef HCC_TARGET_REQU_H
#define HCC_TARGET_REQU_H

#include "../dev/libs.h"
#include "../lexer/lexer.h"

// Information about the target
extern const char* target_architecture;  // e.g. "x86 Linux"
extern const unsigned int target_cpu;    // Either 32 or 64 bit
extern const size_t target_address_size; // For 32 bit, should be 4 bytes and for 64 bit, should be 8 bytes

// Information about the program's essential sections (for assembly)
extern const char* target_entry_point;
extern const char* target_text_section;
extern const char* target_data_section;
extern const char* target_rodata_section;

// Setup the entry point and other stuff
extern void gen_setup(HC_FILE fptr, bool library);

// Assemble and link via external assembler and linker
extern int assemble(const char* output_file, bool debug);
extern int link(const char* output_file, char* link_files);

typedef enum { OCCUP_NONE = 0, OCCUP_UNSIGNED, OCCUP_SIGNED, OCCUP_IGNORE } reg_occup_t;

typedef struct reg_t{
    const char* name;
    struct reg_t* children;
    size_t size;
    reg_occup_t occupied;
    unsigned int mask;
} reg_t;
#define REGISTER(name, size, m, children) (reg_t){(name), (children), (size), OCCUP_NONE, (m)}
#define REGISTER_ARRAY(...) ((reg_t[]){__VA_ARGS__, (reg_t){NULL}})

#define MAX_REGS 128
typedef uint64_t reg_mask;
#define REQ_ALLOWED_REGS(op) extern const reg_mask allowed_##op##_regs1; extern const reg_mask allowed_##op##_regs2
#define REQ_AFFECTED_REGS(op) extern const reg_mask affected_##op##_regs
#define ALL_REGS ~0
#define ALL_REGS_EXCEPT(rs) ~(rs)
#define REG(r) (1<<(r))
#define REG_IN_MASK(r, m) ((m) & (1 << (r)->mask))
#define SET_ALLOWED_REGS1(op, _mask) const reg_mask allowed_##op##_regs1 = (_mask)
#define SET_ALLOWED_REGS2(op, _mask) const reg_mask allowed_##op##_regs2 = (_mask)
#define SET_AFFECTED_REGS(op, _mask) const reg_mask affected_##op##_regs = (_mask)
#define GET_ALLOWED_REGS1(op) (allowed_##op##_regs1)
#define GET_ALLOWED_REGS2(op) (allowed_##op##_regs2)
#define GET_AFFECTED_REGS(op) (affected_##op##_regs)

#define REGISTER_COUNT 0
extern reg_t registers[];

// Setup
extern void gen_alloc_stack(HC_FILE, size_t);
extern void gen_dealloc_stack(HC_FILE, size_t);
extern void gen_start_func(HC_FILE, const char*, size_t, bool);
extern void gen_return_func(HC_FILE);
extern void gen_push_stack(HC_FILE, reg_t*);
extern void gen_pop_stack(HC_FILE, reg_t*);

// Unary operations / simple instructions
extern void gen_set_reg(HC_FILE, reg_t*, const char*, size_t);
extern void gen_clear_reg(HC_FILE, reg_t*);
extern void gen_flip_reg(HC_FILE, reg_t*);
extern void gen_neg_reg(HC_FILE, reg_t*);
extern void gen_inc_reg(HC_FILE, reg_t*);
extern void gen_dec_reg(HC_FILE, reg_t*);

// String literal IO
extern void gen_load_str(HC_FILE, reg_t*, size_t);

// Global IO
extern void gen_load_global(HC_FILE, reg_t*, const char*, size_t);
extern void gen_loadx_global(HC_FILE, reg_t*, const char*, size_t, size_t, bool);
extern void gen_load_global_ptr(HC_FILE, reg_t*, const char*, size_t);
extern void gen_save_global(HC_FILE, reg_t*, const char*, size_t);

// Stack IO
extern void gen_load_stack(HC_FILE, reg_t*, size_t);
extern void gen_loadx_stack(HC_FILE, reg_t*, size_t, size_t, bool); // Extended (small -> big)
extern void gen_load_stack_ptr(HC_FILE, reg_t*, size_t);
extern void gen_save_stack(HC_FILE, reg_t*, size_t);

// Argument IO
extern void gen_load_arg(HC_FILE, reg_t*, size_t);
extern void gen_loadx_arg(HC_FILE, reg_t*, size_t, size_t, bool);   // Extended (small -> big)
extern void gen_load_arg_ptr(HC_FILE, reg_t*, size_t);
extern void gen_save_arg(HC_FILE, reg_t*, size_t);

// Pointer IO
extern void gen_load_ptr(HC_FILE, reg_t*, reg_t*);
extern void gen_loadx_ptr(HC_FILE, reg_t*, reg_t*, size_t, bool);   // Extended (small -> big)
extern void gen_save_ptr(HC_FILE, reg_t*, reg_t*);

// Indexing IO
extern void gen_load_idx(HC_FILE, reg_t*, reg_t*, reg_t*, size_t);
extern void gen_loadx_idx(HC_FILE, reg_t*, reg_t*, reg_t*, size_t, bool); // Extended (small -> big)
extern void gen_load_idx_ptr(HC_FILE, reg_t*, reg_t*, reg_t*, size_t);
extern void gen_save_idx(HC_FILE, reg_t*, reg_t*, reg_t*, size_t);

// Return value
extern void gen_save_return(HC_FILE, reg_t*);

// Register transfer
extern void gen_move_reg(HC_FILE, reg_t*, reg_t*);
extern void gen_movex_reg(HC_FILE, reg_t*, reg_t*, bool);   // Extended (small -> big)

// BINARY OPERATIONS -> file, op1, op2, result
// follows this format: op1 OPERATION op2 -> op1
#define REQ_OPERATION(op) REQ_ALLOWED_REGS(op); extern void gen_##op##_regs(HC_FILE, reg_t*, reg_t*)
#define CREATE_OPERATION(op,fmt,...) void gen_##op##_regs(HC_FILE fptr, reg_t* op1, reg_t* op2) { HC_FPRINTF(fptr, (fmt),##__VA_ARGS__); }
REQ_OPERATION(add);
REQ_OPERATION(sub);
REQ_OPERATION(and);
REQ_OPERATION(or);
REQ_OPERATION(xor);
REQ_OPERATION(shl);
REQ_OPERATION(shr);
REQ_OPERATION(sshr); // Shift right, signed
REQ_AFFECTED_REGS(smul);
REQ_OPERATION(smul);
REQ_AFFECTED_REGS(mul);
REQ_OPERATION(mul);
REQ_AFFECTED_REGS(sdiv);
REQ_OPERATION(sdiv);
REQ_AFFECTED_REGS(div);
REQ_OPERATION(div);
REQ_AFFECTED_REGS(smod);
REQ_OPERATION(smod);
REQ_AFFECTED_REGS(mod);
REQ_OPERATION(mod);

// Labels, jumps and conditional jumps / sets
extern void gen_label(HC_FILE, size_t);
extern void gen_jump(HC_FILE, size_t);
extern void gen_call_func(HC_FILE, const char*, size_t);
extern void gen_cmpz_reg(HC_FILE, reg_t*);
extern void gen_compare(HC_FILE, reg_t*, reg_t*);
extern void gen_cond_jump(HC_FILE, tk_type, size_t, bool);
extern void gen_cond_set(HC_FILE, tk_type, reg_t*, bool);

// Declaration tools
extern void gen_declare_extern(HC_FILE, const char*, size_t);
extern void gen_declare_global(HC_FILE, const char*, size_t, size_t, const char*, size_t);
extern void gen_declare_global_arr(HC_FILE, const char*, size_t, size_t);
extern void gen_declare_str(HC_FILE, size_t, const char*, size_t);
extern void gen_declare_float(HC_FILE, size_t, const char*, size_t);

// Floating point operations
extern void gen_pop_float(HC_FILE);
extern void gen_load_float(HC_FILE, size_t);
extern void gen_load_stack_float(HC_FILE, size_t);
extern void gen_load_arg_float(HC_FILE, size_t);
extern void gen_load_ptr_float(HC_FILE, reg_t*);
extern void gen_load_idx_float(HC_FILE, reg_t*, reg_t*, size_t);
extern void gen_load_global_float(HC_FILE, const char*, size_t);
extern void gen_save_stack_float(HC_FILE, size_t);
extern void gen_save_arg_float(HC_FILE, size_t);
extern void gen_save_ptr_float(HC_FILE, reg_t*);
extern void gen_save_idx_float(HC_FILE, reg_t*, reg_t*, size_t);
extern void gen_save_global_float(HC_FILE, const char*, size_t);
extern void gen_load_float_reg(HC_FILE, reg_t*);
extern void gen_int_to_float(HC_FILE, reg_t*);
extern void gen_float_to_int(HC_FILE, reg_t*);
extern void gen_neg_float(HC_FILE);
extern void gen_add_floats(HC_FILE);
extern void gen_sub_floats(HC_FILE);
extern void gen_mul_floats(HC_FILE);
extern void gen_div_floats(HC_FILE);
extern void gen_cmpz_float(HC_FILE);
extern void gen_cmp_floats(HC_FILE);
extern void gen_cmp_approx_floats(HC_FILE);

#endif
