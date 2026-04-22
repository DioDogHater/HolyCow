#ifndef HCC_TARGET_REQU_H
#define HCC_TARGET_REQU_H

#include "../dev/libs.h"
#include "../lexer/lexer.h"

// Information about the target
extern const char* target_architecture;  // e.g. "x86 Linux"
extern const unsigned int target_cpu;    // Either 32 or 64 bit
extern const size_t target_address_size; // For 32 bit, should be 4 bytes and for 64 bit, should be 8 bytes
extern const char* target_assembler;
extern const char* target_linker;

// Information about the program's essential sections (for assembly)
extern const char* target_entry_point;
extern const char* target_text_section;
extern const char* target_data_section;
extern const char* target_rodata_section;

// Setup the entry point and other stuff
void gen_setup(HC_FILE fptr, bool library);

// Assemble and link via external assembler and linker
int assemble(const char* output_file, bool debug);
int link(const char* output_file, char* link_files);

typedef enum { OCCUP_NONE = 0, OCCUP_UNSIGNED, OCCUP_SIGNED, OCCUP_IGNORE } reg_occup_t;

typedef struct reg_t{
    const char* name;
    struct reg_t* children;
    size_t size;
    reg_occup_t occupied;
    unsigned int mask;
} reg_t;
#define REGISTER(name, size, m, children) (reg_t){(name), (children), (size), OCCUP_NONE, (m)}
#define NULL_REG (reg_t){NULL}

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
void gen_alloc_stack(HC_FILE, size_t);
void gen_dealloc_stack(HC_FILE, size_t);
void gen_start_func(HC_FILE, const char*, size_t, bool);
void gen_start_method(HC_FILE, const char*, size_t, const char*, size_t);
void gen_inherit_method(HC_FILE, const char*, size_t, const char*, size_t, const char*, size_t);
void gen_return_func(HC_FILE);
void gen_push_stack(HC_FILE, reg_t*);
void gen_pop_stack(HC_FILE, reg_t*);

// Unary operations / simple instructions
void gen_set_reg(HC_FILE, reg_t*, const char*, size_t);
void gen_set_reg_raw(HC_FILE, reg_t*, uint64_t);
void gen_clear_reg(HC_FILE, reg_t*);
void gen_add_reg(HC_FILE, reg_t*, uint64_t);
void gen_sub_reg(HC_FILE, reg_t*, uint64_t);
void gen_and_reg(HC_FILE, reg_t*, uint64_t);
void gen_or_reg(HC_FILE, reg_t*, uint64_t);
void gen_xor_reg(HC_FILE, reg_t*, uint64_t);
void gen_shl_reg(HC_FILE, reg_t*, uint64_t);
void gen_shr_reg(HC_FILE, reg_t*, uint64_t);
void gen_sshr_reg(HC_FILE, reg_t*, uint64_t);
void gen_rol_reg(HC_FILE, reg_t*, uint64_t);
void gen_ror_reg(HC_FILE, reg_t*, uint64_t);
void gen_flip_reg(HC_FILE, reg_t*);
void gen_neg_reg(HC_FILE, reg_t*);
void gen_inc_reg(HC_FILE, reg_t*);
void gen_dec_reg(HC_FILE, reg_t*);

// String literal IO
void gen_load_str_lit(HC_FILE, reg_t*, size_t);

// Global IO
void gen_load_global(HC_FILE, reg_t*, const char*, size_t);
void gen_loadx_global(HC_FILE, reg_t*, const char*, size_t, size_t, bool sign);
void gen_load_global_ptr(HC_FILE, reg_t*, const char*, size_t);
void gen_save_global(HC_FILE, reg_t*, const char*, size_t);
void gen_inc_global(HC_FILE, const char*, size_t, size_t size, bool inc); // inc = true -> ++, inc = false -> --

void gen_load_global_offset_ptr(HC_FILE, reg_t*, const char*, size_t, size_t);
void gen_load_global_offset(HC_FILE, reg_t*, const char*, size_t, size_t);
void gen_loadx_global_offset(HC_FILE, reg_t*, const char*, size_t, size_t, size_t, bool sign);
void gen_save_global_offset(HC_FILE, reg_t*, const char*, size_t, size_t);
void gen_inc_global_offset(HC_FILE, const char*, size_t, size_t, size_t size, bool inc); // inc = true -> ++, inc = false -> --

// Stack IO
void gen_load_stack(HC_FILE, reg_t*, size_t);
void gen_loadx_stack(HC_FILE, reg_t*, size_t, size_t, bool sign); // Extended (small -> big)
void gen_load_stack_ptr(HC_FILE, reg_t*, size_t);
void gen_save_stack(HC_FILE, reg_t*, size_t);
void gen_inc_stack(HC_FILE, size_t, size_t size, bool inc); // inc = true -> ++, inc = false -> --

// Argument IO
void gen_load_arg(HC_FILE, reg_t*, size_t);
void gen_loadx_arg(HC_FILE, reg_t*, size_t, size_t, bool sign);   // Extended (small -> big)
void gen_load_arg_ptr(HC_FILE, reg_t*, size_t);
void gen_save_arg(HC_FILE, reg_t*, size_t);
void gen_inc_arg(HC_FILE, size_t, size_t size, bool inc); // inc = true -> ++, inc = false -> --

// Pointer IO
void gen_load_ptr(HC_FILE, reg_t*, reg_t*);
void gen_loadx_ptr(HC_FILE, reg_t*, reg_t*, size_t, bool sign);   // Extended (small -> big)
void gen_save_ptr(HC_FILE, reg_t*, reg_t*);
void gen_inc_ptr(HC_FILE, reg_t*, size_t size, bool inc); // inc = true -> ++, inc = false -> --

// Indexing IO
void gen_load_idx(HC_FILE, reg_t*, reg_t*, reg_t*, size_t);
void gen_loadx_idx(HC_FILE, reg_t*, reg_t*, reg_t*, size_t, bool sign); // Extended (small -> big)
void gen_load_idx_ptr(HC_FILE, reg_t*, reg_t*, reg_t*, size_t);
void gen_save_idx(HC_FILE, reg_t*, reg_t*, reg_t*, size_t);
void gen_inc_idx(HC_FILE, reg_t*, reg_t*, size_t size, bool inc); // inc = true -> ++, inc = false -> --

// Pointer + offset IO
void gen_load_offset(HC_FILE, reg_t*, reg_t*, size_t);
void gen_loadx_offset(HC_FILE, reg_t*, reg_t*, size_t, size_t, bool sign); // Extended (small -> big)
void gen_load_offset_ptr(HC_FILE, reg_t*, reg_t*, size_t);
void gen_save_offset(HC_FILE, reg_t*, reg_t*, size_t);
void gen_inc_offset(HC_FILE, reg_t*, size_t, size_t size, bool inc); // inc = true -> ++, inc = false -> --

// Copy memory
extern const reg_mask allowed_copy_regs;    // Alls regs except those used to copy data
extern const reg_mask affected_copy_regs;
void gen_copy_global(HC_FILE, reg_t* dest, const char* str, size_t strlen, size_t sz);
void gen_copy_stack(HC_FILE, reg_t* dest, size_t ptr, size_t sz);
void gen_copy_arg(HC_FILE, reg_t* dest, size_t ptr, size_t sz);
void gen_copy_ptr(HC_FILE, reg_t* dest, reg_t* src, size_t sz);
void gen_copy_idx(HC_FILE, reg_t* dest, reg_t* src, reg_t* idx, size_t sz);

// Compare memory
extern const reg_mask allowed_memcmp_regs;
extern const reg_mask affected_memcmp_regs;
void gen_memcmp(HC_FILE, reg_t* ptr1, reg_t* ptr2, size_t sz);

// Register transfer
void gen_move_reg(HC_FILE, reg_t*, reg_t*);
void gen_movex_reg(HC_FILE, reg_t*, reg_t*, bool);   // Extended (small -> big)

// BINARY OPERATIONS -> file, op1, op2, result
// follows this format: op1 OPERATION op2 -> op1
#define REQ_OPERATION(op) REQ_ALLOWED_REGS(op); void gen_##op##_regs(HC_FILE, reg_t*, reg_t*)
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
void gen_label(HC_FILE, size_t);
void gen_jump(HC_FILE, size_t);
void gen_call_func(HC_FILE, const char*, size_t);
void gen_call_method(HC_FILE, const char*, size_t, const char*, size_t);
void gen_call_extern_func(HC_FILE, const char*, size_t);
void gen_cmpz_reg(HC_FILE, reg_t*);
void gen_compare(HC_FILE, reg_t*, reg_t*);
void gen_cond_jump(HC_FILE, tk_type, size_t, bool);
void gen_cond_set(HC_FILE, tk_type, reg_t*, bool);

// Float registers
typedef struct freg_t {
    const char* name;
    struct freg_t* children;
    bool dp;
    bool occupied;
} freg_t;
#define FREG(name, ds, children) (freg_t){(name), (children), (ds), false}
#define NULL_FREG (freg_t){NULL}

#define MAX_FREGS 128
#define FREG_COUNT 0
extern freg_t fregs[];

// Declaration tools
void gen_declare_extern(HC_FILE, const char*, size_t, const char* category);
void gen_declare_extern_method(HC_FILE, const char*, size_t, const char*, size_t);
void gen_start_global_decl(HC_FILE, const char*, size_t, bool);
void gen_declare_int(HC_FILE, int64_t, size_t);
size_t gen_declare_str(HC_FILE, const char*, size_t);
void gen_declare_str_lit_ptr(HC_FILE, size_t);
void gen_declare_global_ptr(HC_FILE, const char*, size_t);
void gen_declare_float(HC_FILE, double, bool);
void gen_declare_mem(HC_FILE, size_t);
void gen_declare_align(HC_FILE, const char*, size_t, size_t);

void gen_declare_str_lit(HC_FILE, size_t, const char*, size_t);
void gen_declare_float_lit(HC_FILE, size_t, double);

// Floating point operations
void gen_loadf(HC_FILE, freg_t*, size_t);
void gen_move_freg(HC_FILE, freg_t*, freg_t*);
void gen_loadf_stack(HC_FILE, freg_t*, size_t, bool);
void gen_loadf_arg(HC_FILE, freg_t*, size_t, bool);
void gen_loadf_ptr(HC_FILE, freg_t*, reg_t*, bool);
void gen_loadf_idx(HC_FILE, freg_t*, reg_t*, reg_t*, bool);
void gen_loadf_global(HC_FILE, freg_t*, const char*, size_t, bool);
void gen_loadf_global_offset(HC_FILE, freg_t*, const char*, size_t, size_t, bool);
void gen_loadf_offset(HC_FILE, freg_t*, reg_t*, size_t, bool);
void gen_savef_stack(HC_FILE, freg_t*, size_t, bool);
void gen_savef_arg(HC_FILE, freg_t*, size_t, bool);
void gen_savef_ptr(HC_FILE, freg_t*, reg_t*, bool);
void gen_savef_idx(HC_FILE, freg_t*, reg_t*, reg_t*, bool);
void gen_savef_global(HC_FILE, freg_t*, const char*, size_t, bool);
void gen_savef_global_offset(HC_FILE, freg_t*, const char*, size_t, size_t, bool);
void gen_savef_offset(HC_FILE, freg_t*, reg_t*, size_t, bool);
void gen_int_to_float(HC_FILE, freg_t*, reg_t*);
void gen_float_to_int(HC_FILE, freg_t*, reg_t*);
void gen_negf(HC_FILE, freg_t*);
void gen_addf(HC_FILE, freg_t*, freg_t*);
void gen_subf(HC_FILE, freg_t*, freg_t*);
void gen_mulf(HC_FILE, freg_t*, freg_t*);
void gen_divf(HC_FILE, freg_t*, freg_t*);
void gen_modf(HC_FILE, freg_t*, freg_t*);
void gen_cmpzf(HC_FILE, freg_t*);
void gen_cmpf(HC_FILE, freg_t*, freg_t*);
void gen_cmp_approx(HC_FILE, freg_t*, freg_t*);

#endif
