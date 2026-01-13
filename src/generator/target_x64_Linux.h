// #define TARGET_x64_Linux
#ifdef TARGET_x64_Linux

#include "../dev/libs.h"
#include "target_requirements.h"

const char* target_architecture = "x64 Linux";
const size_t target_address_size = 8; // bytes
const unsigned int target_cpu = 64;
const char* target_entry_point = "_start";
const char* target_text_section = "section .text\n";
const char* target_data_section = "section .data\n";
const char* target_rodata_section = "section .rodata\n";

static const char* x86_sz_names[9] = {"Unkown", "BYTE", "WORD", "Unknown", "DWORD", "Unknown", "Unknown", "Unknown", "QWORD"};
void gen_setup(HC_FILE fptr, bool library){
    if(!library)
        HC_FPRINTF(fptr,
        "%sglobal _start\n"
        "default ABS\n"
        "_start:\n"
        "\tmov rax, [rsp+0]\n"
        "\tlea rbx, [rsp+8]\n"
        "\tsub rsp, 32\n"
        "\tmov [rsp+8], rax\n"
        "\tmov [rsp+16], rbx\n"
        "\tcall main\n"
        "\tmov rax, 60\n"
        "\tmov rdi, [rsp]\n"
        "\tsyscall\n", target_text_section);
}

int assemble(const char* output_file, bool debug){
    char buffer[1024];
    snprintf(buffer, 1023, "nasm %s -felf64 %s.nasm -o %s.o", debug ? "-g -F dwarf" : "", output_file, output_file);
    return system(buffer);
}

int link(const char* output_file, char* link_files){
    char buffer[4096];
    for(char* ptr = link_files; *ptr; ptr++)
        if(*ptr == ';') *ptr = ' ';
    snprintf(buffer, 4095, "ld %s %s.o -o %s", link_files, output_file, output_file);
    return system(buffer);
}

#undef REGISTER_COUNT
#define REGISTER_COUNT 6

#define BASIC_REG(a, m) \
REGISTER("r" a "x", 8, (m), REGISTER_ARRAY(\
    REGISTER("e" a "x", 4, (m), REGISTER_ARRAY(\
        REGISTER(a "x", 2, (m), REGISTER_ARRAY(\
            REGISTER(a "l", 1, (m), NULL)\
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
                REGISTER("sil", 1, 4, NULL)
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
void gen_start_func(HC_FILE fptr, const char* func_name, size_t strlen, bool priv){
    if(!priv)
        HC_FPRINTF(fptr, "\nglobal %.*s", (int)strlen, func_name);
    HC_FPRINTF(fptr, "\n%.*s:\n\tpush rbp\n\tmov rbp, rsp\n", (int)strlen, func_name);
}
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
void gen_load_global(HC_FILE fptr, reg_t* op, const char* str, size_t strlen){ HC_FPRINTF(fptr, "\tmov %s, %s [%.*s]\n", op->name, x86_sz_names[op->size], (int)strlen, str); }
void gen_loadx_global(HC_FILE fptr, reg_t* op, const char* str, size_t strlen, size_t sz, bool sign){ HC_FPRINTF(fptr, (sign) ? ("\tmovsx %s, %s [DS:%.*s]\n") : ("\tmovzx %s, %s [%.*s]\n"), op->name, x86_sz_names[sz], (int)strlen, str); }
void gen_load_global_ptr(HC_FILE fptr, reg_t* op, const char* str, size_t strlen){ HC_FPRINTF(fptr, "\tmov %s, %.*s\n", op->name, (int)strlen, str); }
void gen_save_global(HC_FILE fptr, reg_t* op, const char* str, size_t strlen){ HC_FPRINTF(fptr, "\tmov [%.*s], %s\n", (int)strlen, str, op->name); }

// Stack
void gen_load_stack(HC_FILE fptr, reg_t* op, size_t ptr){ HC_FPRINTF(fptr, "\tmov %s, [rsp+%lu]\n", op->name, ptr); }
void gen_loadx_stack(HC_FILE fptr, reg_t* op, size_t ptr, size_t sz, bool sign){ HC_FPRINTF(fptr, (sign) ? ("\tmovsx %s, %s [rsp+%lu]\n") : ("\tmovzx %s, %s [rsp+%lu]\n"), op->name, x86_sz_names[sz], ptr); }
void gen_load_stack_ptr(HC_FILE fptr, reg_t* op, size_t ptr){ HC_FPRINTF(fptr, "\tlea %s, [rsp+%lu]\n", op->name, ptr); }
void gen_save_stack(HC_FILE fptr, reg_t* op, size_t ptr){ HC_FPRINTF(fptr, "\tmov [rsp+%lu], %s\n", ptr, op->name); }

// Arg
void gen_load_arg(HC_FILE fptr, reg_t* op, size_t ptr){ HC_FPRINTF(fptr, "\tmov %s, [rbp+%lu]\n", op->name, ptr + 16); }
void gen_loadx_arg(HC_FILE fptr, reg_t* op, size_t ptr, size_t sz, bool sign){ HC_FPRINTF(fptr, (sign) ? ("\tmovsx %s, %s [rbp+%lu]\n") : ("\tmovzx %s, %s [rbp+%lu]\n"), op->name, x86_sz_names[sz], ptr); }
void gen_load_arg_ptr(HC_FILE fptr, reg_t* op, size_t ptr){ HC_FPRINTF(fptr, "\tlea %s, [rbp+%lu]\n", op->name, ptr + 16); }
void gen_save_arg(HC_FILE fptr, reg_t* op, size_t ptr){ HC_FPRINTF(fptr, "\tmov [rbp+%lu], %s\n", ptr + 16, op->name); }

// Ptr
void gen_load_ptr(HC_FILE fptr, reg_t* op, reg_t* ptr){ HC_FPRINTF(fptr, "\tmov %s, [%s]\n", op->name, ptr->name); }
void gen_loadx_ptr(HC_FILE fptr, reg_t* op, reg_t* ptr, size_t sz, bool sign){ HC_FPRINTF(fptr, (sign) ? ("\tmovsx %s, %s [%s]\n") : ("\tmovzx %s, %s [%s]\n"), op->name, x86_sz_names[sz], ptr->name); }
void gen_save_ptr(HC_FILE fptr, reg_t* op, reg_t* ptr){ HC_FPRINTF(fptr, "\tmov [%s], %s\n", ptr->name, op->name); }

// Index
void gen_load_idx(HC_FILE fptr, reg_t* op, reg_t* ptr, reg_t* idx, size_t elem_sz){
    HC_FPRINTF(fptr, "\tmov %s, [%s+%s*%lu]\n", op->name, ptr->name, idx->name, elem_sz);
}
void gen_loadx_idx(HC_FILE fptr, reg_t* op, reg_t* ptr, reg_t* idx, size_t elem_sz, bool sign){
    HC_FPRINTF(fptr, "\t%s %s, %s [%s+%s*%lu]\n", (sign)?"movsx":"movzx", op->name, x86_sz_names[elem_sz], ptr->name, idx->name, elem_sz);
}
void gen_load_idx_ptr(HC_FILE fptr, reg_t* op, reg_t* ptr, reg_t* idx, size_t elem_sz){
    HC_FPRINTF(fptr, "\tlea %s, [%s+%s*%lu]\n", op->name, ptr->name, idx->name, elem_sz);
}
void gen_save_idx(HC_FILE fptr, reg_t* op, reg_t* ptr, reg_t* idx, size_t elem_sz){
    HC_FPRINTF(fptr, "\tmov [%s+%s*%lu], %s\n", ptr->name, idx->name, elem_sz, op->name);
}

// Return
void gen_save_return(HC_FILE fptr, reg_t* op){ HC_FPRINTF(fptr, "\tmov [rbp+16], %s\n", op->name); }

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

SET_ALLOWED_REGS1(shl, ALL_REGS);
SET_ALLOWED_REGS2(shl, REG(2));
CREATE_OPERATION(shl, "\tshl %s, %s\n", op1->name, op2->name);

SET_ALLOWED_REGS1(shr, ALL_REGS);
SET_ALLOWED_REGS2(shr, REG(2));
CREATE_OPERATION(shr, "\tshr %s, %s\n", op1->name, op2->name);

SET_ALLOWED_REGS1(sar, ALL_REGS);
SET_ALLOWED_REGS2(sar, REG(2));
CREATE_OPERATION(sar, "\tsar %s, %s\n", op1->name, op2->name);

SET_ALLOWED_REGS1(smul, REG(0));
SET_ALLOWED_REGS2(smul, ALL_REGS_EXCEPT(REG(0) | REG(3) | REG(14)));
SET_AFFECTED_REGS(smul, REG(3));
CREATE_OPERATION(smul, "\timul %s\n", op2->name);

SET_ALLOWED_REGS1(mul, REG(0));
SET_ALLOWED_REGS2(mul, ALL_REGS_EXCEPT(REG(0) | REG(3) | REG(14)));
SET_AFFECTED_REGS(mul, REG(3));
CREATE_OPERATION(mul, "\tmul %s\n", op2->name);

static void gen_division(HC_FILE fptr, reg_t* op, bool sign){
    if(op->size == 1) HC_FPRINTF(fptr, "\txor ah, ah\n");
    else HC_FPRINTF(fptr, "\txor rdx, rdx\n");
    HC_FPRINTF(fptr, "\t%s %s\n", (sign)?"idiv":"div", op->name);
}

SET_ALLOWED_REGS1(sdiv, REG(0));
SET_ALLOWED_REGS2(sdiv, ALL_REGS_EXCEPT(REG(0) | REG(3) | REG(14)));
SET_AFFECTED_REGS(sdiv, REG(3) | REG(14));
void gen_sdiv_regs(HC_FILE fptr, reg_t* op1, reg_t* op2){ gen_division(fptr, op2, true); }

SET_ALLOWED_REGS1(div, REG(0));
SET_ALLOWED_REGS2(div, ALL_REGS_EXCEPT(REG(0) | REG(3) | REG(14)));
SET_AFFECTED_REGS(div, REG(3) | REG(14));
void gen_div_regs(HC_FILE fptr, reg_t* op1, reg_t* op2){ gen_division(fptr, op2, false); }

static void gen_modulo(HC_FILE fptr, reg_t* op1, reg_t* op2, bool sign){
    gen_division(fptr, op2, sign);
    const char* remainder_reg[8] = {"ah","dx","","eax","","","","rdx"};
    HC_FPRINTF(fptr,"\tmov %s, %s\n", op1->name, remainder_reg[op1->size - 1]);
}

SET_ALLOWED_REGS1(smod, REG(0));
SET_ALLOWED_REGS2(smod, ALL_REGS_EXCEPT(REG(0) | REG(3) | REG(14)));
SET_AFFECTED_REGS(smod, REG(3) | REG(14));
void gen_smod_regs(HC_FILE fptr, reg_t* op1, reg_t* op2){ gen_modulo(fptr, op1, op2, true); }

SET_ALLOWED_REGS1(mod, REG(0));
SET_ALLOWED_REGS2(mod, ALL_REGS_EXCEPT(REG(0) | REG(3) | REG(14)));
SET_AFFECTED_REGS(mod, REG(3) | REG(14));
void gen_mod_regs(HC_FILE fptr, reg_t* op1, reg_t* op2){ gen_modulo(fptr, op1, op2, false); }

void gen_label(HC_FILE fptr, size_t label){ HC_FPRINTF(fptr, "\t.L%lu:\n", label); }
void gen_jump(HC_FILE fptr, size_t label){ HC_FPRINTF(fptr, "\tjmp .L%lu\n", label); }
void gen_call_func(HC_FILE fptr, const char* str, size_t strlen){ HC_FPRINTF(fptr, "\tcall %.*s\n", (int)strlen, str); }
void gen_cmpz_reg(HC_FILE fptr, reg_t* reg){ HC_FPRINTF(fptr, "\ttest %s, %s\n", reg->name, reg->name); }
void gen_compare(HC_FILE fptr, reg_t* lhs, reg_t* rhs){ HC_FPRINTF(fptr, "\tcmp %s, %s\n", lhs->name, rhs->name); }

void gen_cond_jump(HC_FILE fptr, tk_type cmp, size_t label, bool sign){
    switch(cmp){
    case tk_cmp_eq:
        HC_FPRINTF(fptr, "\tje .L%lu\n", label);
        break;
    case tk_cmp_neq:
        HC_FPRINTF(fptr, "\tjne .L%lu\n", label);
        break;
    case tk_cmp_g:
        if(sign) HC_FPRINTF(fptr, "\tjg .L%lu\n", label);
        else HC_FPRINTF(fptr, "\tja .L%lu\n", label);
        break;
    case tk_cmp_l:
        if(sign) HC_FPRINTF(fptr, "\tjl .L%lu\n", label);
        else HC_FPRINTF(fptr, "\tjb .L%lu\n", label);
        break;
    case tk_cmp_le:
        if(sign) HC_FPRINTF(fptr, "\tjle .L%lu\n", label);
        else HC_FPRINTF(fptr, "\tjbe .L%lu\n", label);
        break;
    case tk_cmp_ge:
        if(sign) HC_FPRINTF(fptr, "\tjge .L%lu\n", label);
        else HC_FPRINTF(fptr, "\tjae .L%lu\n", label);
        break;
    default:
        HC_FPRINTF(fptr, "\tUNKNOWN CONDITIONAL JUMP \"%lu\"\n", cmp);
        break;
    }
}

void gen_cond_set(HC_FILE fptr, tk_type cmp, reg_t* reg, bool sign){
    switch(cmp){
    case tk_cmp_eq:
        HC_FPRINTF(fptr, "\tsete %s\n", reg->name);
        break;
    case tk_cmp_neq:
        HC_FPRINTF(fptr, "\tsetne %s\n", reg->name);
        break;
    case tk_cmp_g:
        if(sign) HC_FPRINTF(fptr, "\tsetg %s\n", reg->name);
        else HC_FPRINTF(fptr, "\tseta %s\n", reg->name);
        break;
    case tk_cmp_l:
        if(sign) HC_FPRINTF(fptr, "\tsetl %s\n", reg->name);
        else HC_FPRINTF(fptr, "\tsetb %s\n", reg->name);
        break;
    case tk_cmp_le:
        if(sign) HC_FPRINTF(fptr, "\tsetle %s\n", reg->name);
        else HC_FPRINTF(fptr, "\tsetbe %s\n", reg->name);
        break;
    case tk_cmp_ge:
        if(sign) HC_FPRINTF(fptr, "\tsetge %s\n", reg->name);
        else HC_FPRINTF(fptr, "\tsetae %s\n", reg->name);
        break;
    default:
        HC_FPRINTF(fptr, "\tUNKNOWN CONDITIONAL JUMP \"%lu\"\n", cmp);
        break;
    }
}

void gen_declare_extern(HC_FILE fptr, const char* str, size_t strlen){ HC_FPRINTF(fptr, "extern %.*s\n", (int)strlen, str); }
void gen_declare_global(HC_FILE fptr, const char* str, size_t strlen, size_t size, const char* value, size_t value_len){
    const char* declaration_sizes[9] = {"Unknown","db","dw","Unknown","dd","Unknown","Unknown","Unknown","dq"};
    HC_FPRINTF(fptr, "%.*s:\n%s %.*s", (int)strlen, str, declaration_sizes[size], (int)value_len, value);
}
void gen_declare_global_arr(HC_FILE fptr, const char* str, size_t strlen, size_t size){ HC_FPRINTF(fptr, "%.*s:\ntimes %lu db 0", (int)strlen, str, size); }
void gen_declare_str(HC_FILE fptr, size_t id, const char* str, size_t strlen){
    HC_FPRINTF(fptr, "STR%lu:\n\tdb ", id);
    for(; strlen; str++, strlen--){
        if((*str == '\\' && *(str+1) == 'n') || *str == '\n'){
            HC_FPRINTF(fptr, "\",10,\"");
            if(*str == '\\') str++, strlen--;
        }else if(*str == '\\' && *(str+1) == 't'){
            HC_FPRINTF(fptr, "\t");
            str++, strlen--;
        }else if(*str == '\\' && *(str+1) == '0'){
            HC_FPRINTF(fptr, "\",0,\"");
            str++, strlen--;
        }else
            HC_FPRINTF(fptr,"%c",*str);
    }
    HC_FPRINTF(fptr, ",0\n");
}

#endif
