#ifndef TARGET_x86_Linux
#define TARGET_x86_Linux

#include "../dev/libs.h"
#include "target_requirements.h"

const char* target_architecture = "x64 Linux";
const size_t target_address_size = 8; // bytes
const unsigned int target_cpu = 64;
const char* target_entry_point = "_start";
const char* target_text_section = "section .text\nglobal _start\n";
const char* target_data_section = "section .data\n";
const char* target_rodata_section = "section .rodata\n";

void gen_setup(HC_FILE fptr){
    HC_FPRINTF(fptr, "%s_start:\n\tsub rsp, 16\n\tcall main\n\tmov rax, 60\n\tmov rdi, [rsp+8]\n\tsyscall\n", target_text_section);
}

int assemble(const char* output_file, bool debug){
    char buffer[1024];
    snprintf(buffer, 1023, "nasm %s -felf64 %s.nasm -o %s.o", debug ? "-g -F dwarf" : "", output_file, output_file);
    return system(buffer);
}

int link(const char* output_file){
    char buffer[512];
    sprintf(buffer,"ld %s.o -o %s", output_file, output_file);
    return system(buffer);
}

#undef REGISTER_COUNT
#define REGISTER_COUNT 6

#define BASIC_REG(a, m) \
REGISTER("r" a "x", 8, (m), REGISTER_ARRAY(\
    REGISTER("e" a "x", 4, (m), REGISTER_ARRAY(\
        REGISTER(a "x", 2, (m), REGISTER_ARRAY(\
            REGISTER(a "l", 1, (m), NULL),\
            REGISTER(a "h", 1, (m), NULL)\
        ))\
    ))\
))

#define EXTENDED_REG(n, m) \
REGISTER("r" n, 8, (m), REGISTER_ARRAY(\
    REGISTER("r" n "d", 4, (m), REGISTER_ARRAY(\
        REGISTER("r" n "w", 2, (m), REGISTER_ARRAY(\
            REGISTER("r" n "b", 1, (m), NULL)\
        ))\
    ))\
))

reg_t registers[] = {
    BASIC_REG("b",1),
    BASIC_REG("c",2),
    REGISTER("rsi", 8, 4, REGISTER_ARRAY(
        REGISTER("esi", 4, 4, REGISTER_ARRAY(
            REGISTER("si", 2, 4, REGISTER_ARRAY(
                REGISTER("sil", 4, 1, NULL)
            ))
        ))
    )),
    REGISTER("rdi", 8, 5, REGISTER_ARRAY(
        REGISTER("edi", 4, 5, REGISTER_ARRAY(
            REGISTER("di", 2, 5, REGISTER_ARRAY(
                REGISTER("dil", 1, 5, NULL)
            ))
        ))
    )),
    EXTENDED_REG("8", 6),
    EXTENDED_REG("9", 7),
    EXTENDED_REG("10", 8),
    EXTENDED_REG("11", 9),
    EXTENDED_REG("12", 10),
    EXTENDED_REG("13", 11),
    EXTENDED_REG("14", 12),
    EXTENDED_REG("15", 13),
    BASIC_REG("a",0),
    BASIC_REG("d",3),
    (reg_t){NULL}
};

void gen_alloc_stack(HC_FILE fptr, size_t size){ HC_FPRINTF(fptr, "\tsub rsp, %lu\n", size); }
void gen_dealloc_stack(HC_FILE fptr, size_t size){ HC_FPRINTF(fptr, "\tadd rsp, %lu\n", size); }
void gen_start_func(HC_FILE fptr, const char* func_name, size_t strlen){ HC_FPRINTF(fptr, "\n%.*s:\n\tpush rbp\n\tmov rbp, rsp\n", (int)strlen, func_name); }
void gen_return_func(HC_FILE fptr){ HC_FPRINTF(fptr, "\tleave\n\tret\n"); }
void gen_push_stack(HC_FILE fptr, reg_t* op){
    //if(op->size == 2 || op->size == 8)
    //    HC_FPRINTF(fptr, "\tpush %s\n", op->name);
    //else
    HC_FPRINTF(fptr, "\tsub rsp, %lu\n\tmov [rsp+%lu], %s\n", op->size, op->size, op->name);
}
void gen_pop_stack(HC_FILE fptr, reg_t* op){
    //if(op->size == 8)
    //    HC_FPRINTF(fptr, "\tpop %s\n", op->name);
    //else
    HC_FPRINTF(fptr, "\tmov [rsp+%lu], %s\n\tadd rsp, %lu\n", op->size, op->name, op->size);
}

static const char* x86_sz_names[9] = {"Unkown", "BYTE", "WORD", "Unknown", "DWORD", "Unknown", "Unknown", "Unknown", "QWORD"};

// Unary ops
void gen_set_reg(HC_FILE fptr, reg_t* reg, const char* val, size_t strlen){ HC_FPRINTF(fptr, "\tmov %s, %.*s\n", reg->name, (int)strlen, val); }
void gen_clear_reg(HC_FILE fptr, reg_t* op){ HC_FPRINTF(fptr, "\txor %s, %s\n", op->name, op->name); }
void gen_neg_reg(HC_FILE fptr, reg_t* op){ HC_FPRINTF(fptr, "\tneg %s\n", op->name); }
void gen_flip_reg(HC_FILE fptr, reg_t* op){ HC_FPRINTF(fptr, "\tnot %s\n", op->name); }
void gen_inc_reg(HC_FILE fptr, reg_t* op){ HC_FPRINTF(fptr, "\tinc %s\n", op->name); }
void gen_dec_reg(HC_FILE fptr, reg_t* op){ HC_FPRINTF(fptr, "\tdec %s\n", op->name); }

// Str
void gen_load_str(HC_FILE fptr, reg_t* op, size_t id){ HC_FPRINTF(fptr, "\tmov %s, STR%lu\n", op->name, id); }

// Global
void gen_load_global(HC_FILE fptr, reg_t* op, const char* str, size_t strlen){ HC_FPRINTF(fptr, "\tmov %s, [%.*s]\n", op->name, (int)strlen, str); }
void gen_loadx_global(HC_FILE fptr, reg_t* op, const char* str, size_t strlen, size_t sz, bool sign){ HC_FPRINTF(fptr, (sign) ? ("\tmovsx %s, %s [%.*s]\n") : ("\tmovzx %s, %s [%.*s]\n"), op->name, x86_sz_names[sz], (int)strlen, str); }
void gen_load_global_ptr(HC_FILE fptr, reg_t* op, const char* str, size_t strlen){ HC_FPRINTF(fptr, "\tmov %s, %.*s\n", op->name, (int)strlen, str); }
void gen_save_global(HC_FILE fptr, reg_t* op, const char* str, size_t strlen){ HC_FPRINTF(fptr, "\tmov %.*s, %s\n", (int)strlen, str, op->name); }

// Stack
void gen_load_stack(HC_FILE fptr, reg_t* op, size_t ptr){ HC_FPRINTF(fptr, "\tmov %s, [rsp+%lu]\n", op->name, ptr); }
void gen_loadx_stack(HC_FILE fptr, reg_t* op, size_t ptr, size_t sz, bool sign){ HC_FPRINTF(fptr, (sign) ? ("\tmovsx %s, %s [rsp+%lu]\n") : ("\tmovzx %s, %s [rsp+%lu]\n"), op->name, x86_sz_names[sz], ptr); }
void gen_load_stack_ptr(HC_FILE fptr, reg_t* op, size_t ptr){ HC_FPRINTF(fptr, "\tlea %s, [rsp+%lu]\n", op->name, ptr); }
void gen_save_stack(HC_FILE fptr, reg_t* op, size_t ptr){ HC_FPRINTF(fptr, "\tmov [rsp+%lu], %s\n", ptr, op->name); }

// Arg
void gen_load_arg(HC_FILE fptr, reg_t* op, size_t ptr){ HC_FPRINTF(fptr, "\tmov %s, [rbp+%lu]\n", op->name, ptr + 16); }
void gen_loadx_arg(HC_FILE fptr, reg_t* op, size_t ptr, size_t sz, bool sign){ HC_FPRINTF(fptr, (sign) ? ("\tmovsx %s, %s [rbp+%lu]\n") : ("\tmovzx %s, %s [rsp+%lu]\n"), op->name, x86_sz_names[sz], ptr); }
void gen_load_arg_ptr(HC_FILE fptr, reg_t* op, size_t ptr){ HC_FPRINTF(fptr, "\tlea %s, [rsp+%lu]\n", op->name, ptr); }
void gen_save_arg(HC_FILE fptr, reg_t* op, size_t ptr){ HC_FPRINTF(fptr, "\tmov [rsp+%lu], %s\n", ptr + 16, op->name); }

// Ptr
void gen_load_ptr(HC_FILE fptr, reg_t* op, reg_t* ptr){ HC_FPRINTF(fptr, "\tmov %s, [%s]\n", op->name, ptr->name); }
void gen_loadx_ptr(HC_FILE fptr, reg_t* op, reg_t* ptr, size_t sz, bool sign){ HC_FPRINTF(fptr, (sign) ? ("\tmovsx %s, %s [%s]\n") : ("\tmovzx %s, %s [%s]\n"), op->name, x86_sz_names[sz], ptr->name); }
void gen_save_ptr(HC_FILE fptr, reg_t* op, reg_t* ptr){ HC_FPRINTF(fptr, "\tmov [%s], %s\n", ptr->name, op->name); }

// Return
void gen_save_return(HC_FILE fptr, reg_t* op){ HC_FPRINTF(fptr, "\tmov [rbp+%lu], %s\n", op->size + 16, op->name); }

// Reg transfer
void gen_move_reg(HC_FILE fptr, reg_t* dest, reg_t* src){ HC_FPRINTF(fptr, "\tmov %s, %s\n", dest->name, src->name); }
void gen_movex_reg(HC_FILE fptr, reg_t* dest, reg_t* src, bool sign){ HC_FPRINTF(fptr, (sign) ? ("\tmovsx %s, %s\n") : ("\tmovsx %s, %s\n"), dest->name, src->name); }

// Binary ops
SET_ALLOWED_REGS1(add, ALL_REGS);
SET_ALLOWED_REGS2(add, ALL_REGS);
CREATE_OPERATION(add, "\tadd %s, %s\n", op1->name, op2->name);

SET_ALLOWED_REGS1(sub, ALL_REGS);
SET_ALLOWED_REGS2(sub, ALL_REGS);
CREATE_OPERATION(sub, "\tsub %s, %s\n", op1->name, op2->name);

SET_ALLOWED_REGS1(and, ALL_REGS);
SET_ALLOWED_REGS2(and, ALL_REGS);
CREATE_OPERATION(and, "\tand %s, %s\n", op1->name, op2->name);

SET_ALLOWED_REGS1(or, ALL_REGS);
SET_ALLOWED_REGS2(or, ALL_REGS);
CREATE_OPERATION(or, "\tor %s, %s\n", op1->name, op2->name);

SET_ALLOWED_REGS1(xor, ALL_REGS);
SET_ALLOWED_REGS2(xor, ALL_REGS);
CREATE_OPERATION(xor, "\txor %s, %s\n", op1->name, op2->name);

SET_ALLOWED_REGS1(smul, REG(0));
SET_ALLOWED_REGS2(smul, ALL_REGS_EXCEPT(REG(0) | REG(3)));
SET_AFFECTED_REGS(smul, REG(3));
CREATE_OPERATION(smul, "\timul %s\n", op2->name);

SET_ALLOWED_REGS1(mul, REG(0));
SET_ALLOWED_REGS2(mul, ALL_REGS_EXCEPT(REG(0) | REG(3)));
SET_AFFECTED_REGS(mul, REG(3));
CREATE_OPERATION(mul, "\tmul %s\n", op2->name);

SET_ALLOWED_REGS1(sdiv, REG(0));
SET_ALLOWED_REGS2(sdiv, ALL_REGS_EXCEPT(REG(0) | REG(3)));
SET_AFFECTED_REGS(sdiv, REG(3));
CREATE_OPERATION(sdiv, "\tidiv %s\n", op2->name);

SET_ALLOWED_REGS1(div, REG(0));
SET_ALLOWED_REGS2(div, ALL_REGS_EXCEPT(REG(0) | REG(3)));
SET_AFFECTED_REGS(div, REG(3));
CREATE_OPERATION(div, "\tdiv %s\n", op2->name);

SET_ALLOWED_REGS1(smod, REG(3));
SET_ALLOWED_REGS2(smod, ALL_REGS_EXCEPT(REG(0) | REG(3)));
SET_AFFECTED_REGS(smod, REG(0));
CREATE_OPERATION(smod, "\tidiv %s\n", op2->name);

SET_ALLOWED_REGS1(mod, REG(3));
SET_ALLOWED_REGS2(mod, ALL_REGS_EXCEPT(REG(0) | REG(3)));
SET_AFFECTED_REGS(mod, REG(0));
CREATE_OPERATION(mod, "\tdiv %s\n", op2->name);

void gen_label(HC_FILE fptr, size_t label){ HC_FPRINTF(fptr, "\t.L%lu:\n", label); }
void gen_jump(HC_FILE fptr, size_t label){ HC_FPRINTF(fptr, "\tjmp .L%lu\n", label); }
void gen_cmpz_reg(HC_FILE fptr, reg_t* reg){ HC_FPRINTF(fptr, "\ttest %s, %s\n", reg->name, reg->name); }
void gen_compare(HC_FILE fptr, reg_t* reg, const char* value, size_t strlen){ HC_FPRINTF(fptr, "\tcmp %s, %.*s\n", reg->name, (int)strlen, value); }

void gen_cond_jump(HC_FILE fptr, tk_type cmp, size_t label){
    switch(cmp){
    case tk_cmp_eq:
        HC_FPRINTF(fptr, "\tje .L%lu\n", label);
        break;
    case tk_cmp_neq:
        HC_FPRINTF(fptr, "\tjne .L%lu\n", label);
        break;
    case tk_cmp_g:
        HC_FPRINTF(fptr, "\tjg .L%lu\n", label);
        break;
    case tk_cmp_a:
        HC_FPRINTF(fptr, "\tja .L%lu\n", label);
        break;
    case tk_cmp_l:
        HC_FPRINTF(fptr, "\tjl .L%lu\n", label);
        break;
    case tk_cmp_b:
        HC_FPRINTF(fptr, "\tjb .L%lu\n", label);
        break;
    case tk_cmp_le:
        HC_FPRINTF(fptr, "\tjle .L%lu\n", label);
        break;
    case tk_cmp_be:
        HC_FPRINTF(fptr, "\tjbe .L%lu\n", label);
        break;
    case tk_cmp_ge:
        HC_FPRINTF(fptr, "\tjge .L%lu\n", label);
        break;
    case tk_cmp_ae:
        HC_FPRINTF(fptr, "\tjae .L%lu\n", label);
        break;
    default:
        HC_FPRINTF(fptr, "\tUNKNOWN CONDITIONAL JUMP \"%lu\"\n", cmp);
        break;
    }
}

void gen_cond_set(HC_FILE fptr, tk_type cmp, reg_t* reg){
    switch(cmp){
    case tk_cmp_eq:
        HC_FPRINTF(fptr, "\tse %s\n", reg->name);
        break;
    case tk_cmp_neq:
        HC_FPRINTF(fptr, "\tsne %s\n", reg->name);
        break;
    case tk_cmp_g:
        HC_FPRINTF(fptr, "\tsg %s\n", reg->name);
        break;
    case tk_cmp_a:
        HC_FPRINTF(fptr, "\tsa %s\n", reg->name);
        break;
    case tk_cmp_l:
        HC_FPRINTF(fptr, "\tsl %s\n", reg->name);
        break;
    case tk_cmp_b:
        HC_FPRINTF(fptr, "\tsb %s\n", reg->name);
        break;
    case tk_cmp_le:
        HC_FPRINTF(fptr, "\tsle %s\n", reg->name);
        break;
    case tk_cmp_be:
        HC_FPRINTF(fptr, "\tsbe %s\n", reg->name);
        break;
    case tk_cmp_ge:
        HC_FPRINTF(fptr, "\tsge %s\n", reg->name);
        break;
    case tk_cmp_ae:
        HC_FPRINTF(fptr, "\tsae %s\n", reg->name);
        break;
    default:
        HC_FPRINTF(fptr, "\tUNKNOWN CONDITIONAL JUMP \"%lu\"\n", cmp);
        break;
    }
}

void gen_declare_str(HC_FILE fptr, size_t id, const char* str, size_t strlen){
    HC_FPRINTF(fptr, "STR%lu:\n\tdb ", id);
    for(; strlen; str++, strlen--){
        if((*str == '\\' && *(str+1) == 'n') || *str == '\n'){
            HC_FPRINTF(fptr, "\",10,\"");
            if(*str == '\\') str++, strlen--;
        }else
            HC_FPRINTF(fptr,"%c",*str);
    }
    HC_FPRINTF(fptr, ",0\n");
}

#endif
