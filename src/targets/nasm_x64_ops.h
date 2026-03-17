#ifndef NASM_x64_OPS_H
#define NASM_x64_OPS_H

#include "../generator/target_requirements.h"
#include "../generator/regs.h"

// Names of different sizes
static const char* x64_sz_names[9] = {"Unkown", "BYTE", "WORD", "Unknown", "DWORD", "Unknown", "Unknown", "Unknown", "QWORD"};

void gen_alloc_stack(HC_FILE fptr, size_t size){ HC_FPRINTF(fptr, "\tsub rsp, %lu\n", size); }
void gen_dealloc_stack(HC_FILE fptr, size_t size){ HC_FPRINTF(fptr, "\tadd rsp, %lu\n", size); }
void gen_start_func(HC_FILE fptr, const char* func_name, size_t strlen, bool priv){
    HC_FPRINTF(fptr, "\n%s %.*s:function\n%.*s:\n\tpush rbp\n\tmov rbp, rsp\n", priv?"static":"global", (int)strlen, func_name, (int)strlen, func_name);
}
void gen_return_func(HC_FILE fptr){ HC_FPRINTF(fptr, "\tleave\n\tret\n"); }
void gen_push_stack(HC_FILE fptr, reg_t* op){
    if(op->size == 2 || op->size == 8)
        HC_FPRINTF(fptr, "\tpush %s\n", op->name);
    else
        HC_FPRINTF(fptr, "\tsub rsp, %lu\n\tmov [rsp], %s\n", op->size, op->name);
}
void gen_pop_stack(HC_FILE fptr, reg_t* op){
    if(op->size == 2 || op->size == 8)
        HC_FPRINTF(fptr, "\tpop %s\n", op->name);
    else
        HC_FPRINTF(fptr, "\tmov [rsp], %s\n\tadd rsp, %lu\n", op->name, op->size);
}

// Unary ops
void gen_set_reg(HC_FILE fptr, reg_t* reg, const char* val, size_t strlen){ HC_FPRINTF(fptr, "\tmov %s, %.*s\n", reg->name, (int)strlen, val); }
void gen_clear_reg(HC_FILE fptr, reg_t* op){ HC_FPRINTF(fptr, "\txor %s, %s\n", op->name, op->name); }
void gen_neg_reg(HC_FILE fptr, reg_t* op){ HC_FPRINTF(fptr, "\tneg %s\n", op->name); }
void gen_flip_reg(HC_FILE fptr, reg_t* op){ HC_FPRINTF(fptr, "\tnot %s\n", op->name); }
void gen_inc_reg(HC_FILE fptr, reg_t* op){ HC_FPRINTF(fptr, "\tinc %s\n", op->name); }
void gen_dec_reg(HC_FILE fptr, reg_t* op){ HC_FPRINTF(fptr, "\tdec %s\n", op->name); }

static void x64_loadx_reg(HC_FILE fptr, reg_t* op, size_t sz, bool sign){
    if(sz == 4 && sign)
        HC_FPRINTF(fptr, "\tmovsxd %s, DWORD ", op->name);
    else if(sz == 4)
        HC_FPRINTF(fptr, "\tmov %s, DWORD ", op->children->name);
    else
        HC_FPRINTF(fptr, "\tmov%cx %s, %s ", (sign) ? 's' : 'z', op->name, x64_sz_names[sz]);
}
#define x64_LOAD(fmt, ...) HC_FPRINTF(fptr, "\tmov %s, " fmt "\n", op->name,##__VA_ARGS__)
#define x64_LOADX(fmt, ...) do{ x64_loadx_reg(fptr, op, sz, sign); HC_FPRINTF(fptr, fmt "\n",##__VA_ARGS__); }while(0)
#define x64_PTR(fmt, ...) HC_FPRINTF(fptr, "\tlea %s, " fmt "\n", op->name,##__VA_ARGS__)
#define x64_SAVE(fmt, ...) HC_FPRINTF(fptr, "\tmov " fmt ", %s\n",##__VA_ARGS__, op->name)
#define x64_ARGS(...) __VA_ARGS__
#define x64_LOCATION_L(name, args, fmt, ...) \
void gen_load_##name(HC_FILE fptr, reg_t* op, args){ x64_LOAD(fmt,##__VA_ARGS__); }
#define x64_LOCATION_LX(name, args, fmt, ...) \
void gen_loadx_##name(HC_FILE fptr, reg_t* op, args, size_t sz, bool sign){ x64_LOADX(fmt,##__VA_ARGS__); }
#define x64_LOCATION_PTR(name, args, fmt, ...) \
void gen_load_##name##_ptr(HC_FILE fptr, reg_t* op, args){ x64_PTR(fmt,##__VA_ARGS__); }
#define x64_LOCATION_SV(name, args, fmt, ...) \
void gen_save_##name(HC_FILE fptr, reg_t* op, args){ x64_SAVE(fmt,##__VA_ARGS__); }
#define x64_LOCATION(name, args, fmt, ...) \
x64_LOCATION_L(name, args, fmt,##__VA_ARGS__) \
x64_LOCATION_LX(name, args, fmt,##__VA_ARGS__) \
x64_LOCATION_PTR(name, args, fmt,##__VA_ARGS__) \
x64_LOCATION_SV(name, args, fmt,##__VA_ARGS__)

// Str
void gen_load_str_lit(HC_FILE fptr, reg_t* op, size_t id){ x64_LOAD("STR%lu", id); }

// Global)
#define x64_GLOBAL_ARGS x64_ARGS(const char* str, size_t strlen)
#define x64_GLOBAL_OFFSET_ARGS x64_ARGS(const char* str, size_t strlen, size_t offset)
x64_LOCATION_L(global, x64_GLOBAL_ARGS, "%s [%.*s]", x64_sz_names[op->size], (int)strlen, str);
x64_LOCATION_L(global_offset, x64_GLOBAL_OFFSET_ARGS, "%s [%.*s+%lu]", x64_sz_names[op->size], (int)strlen, str, offset);
x64_LOCATION_LX(global, x64_GLOBAL_ARGS, "[%.*s]", (int)strlen, str);
x64_LOCATION_LX(global_offset, x64_GLOBAL_OFFSET_ARGS, "[%.*s+%lu]", (int)strlen, str, offset);
x64_LOCATION_PTR(global, x64_GLOBAL_ARGS, "[%.*s]", (int)strlen, str);
x64_LOCATION_PTR(global_offset, x64_GLOBAL_OFFSET_ARGS, "[%.*s+%lu]", (int)strlen, str, offset);
x64_LOCATION_SV(global, x64_GLOBAL_ARGS, "[%.*s]", (int)strlen, str);
x64_LOCATION_SV(global_offset, x64_GLOBAL_OFFSET_ARGS, "[%.*s+%lu]", (int)strlen, str, offset);

// Stack
x64_LOCATION(stack, size_t ptr, "[rsp+%lu]", ptr);

// Arg
x64_LOCATION(arg, size_t ptr, "[rbp+%lu]", ptr + 16);

// Ptr
x64_LOCATION_L(ptr, reg_t* ptr, "[%s]", ptr->name);
x64_LOCATION_LX(ptr, reg_t* ptr, "[%s]", ptr->name);
x64_LOCATION_SV(ptr, reg_t* ptr, "[%s]", ptr->name);

// Index
#define x64_INDEX_ARGS x64_ARGS(reg_t* ptr, reg_t* idx, size_t elem_sz)
static size_t x64_index_scale(HC_FILE fptr, reg_t* idx, size_t elem_sz){
    if(elem_sz == 1 || elem_sz == 2 || elem_sz == 4 || elem_sz == 8)
        return elem_sz;
    size_t n = elem_sz;
    if(elem_sz % 8 == 0)
        n /= 8, elem_sz = 8;
    else if(elem_sz % 4 == 0)
        n /= 4, elem_sz = 4;
    else if(elem_sz % 2 == 0)
        n /= 2, elem_sz = 2;
    else
        elem_sz = 1;
    if(n == 2)
        HC_FPRINTF(fptr, "\tadd %s, %s\n", idx->name, idx->name);
    else if(IS_POW2(n)){
        int x = 0;
        for(; n > 1; n /= 2, x++);
        HC_FPRINTF(fptr, "\tshl %s, %d\n", idx->name, x);
    }else if(n-1 == 1 || n-1 == 2 || n-1 == 4 || n-1 == 8){
        n--;
        HC_FPRINTF(fptr, "\tlea %s, [%s+%s*%lu]\n", idx->name, idx->name, idx->name, n);
    }else if(n == 7)
        HC_FPRINTF(fptr, "\tlea %s, [%s*8-%s]\n", idx->name, idx->name, idx->name);
    else{
        /* ALGORITHM:
            1. Find the closest power of 2
                - For x = 1, x++, calculate i = 2^x
                - If abs(n - i) < 2^(x-1), we break and use x and i
            2. We move idx to a new free register (tmp)
            3. We shift idx left x-1 times
            4. We then subtract / add the difference using immediate
               addressing (lea idx, [idx ± tmp * x]) and addition (add idx, tmp)
        */
        int x = 1;
        ssize_t i = 2;
        for(; ABS(i - (ssize_t)n) > i / 2; x++, i *= 2);
        reg_t* tmp = GET_FREE_REG(target_address_size);
        HC_FPRINTF(fptr, "\tmov %s, %s\n\tshl %s, %d\n", tmp->name, idx->name, idx->name, x);
        size_t diff = ABS(i - (ssize_t)n);
        bool diff_sign = (i - n) < 0;
        if(diff > 24){
            size_t diff8 = diff % 8;
            if(diff8 == 0);
            else if(diff8 == 1)
                HC_FPRINTF(fptr, "\tadd %s, %s\n", idx->name, tmp->name);
            else if(IS_POW2(diff8))
                HC_FPRINTF(fptr, "\tlea %s, [%s+%s*%lu]\n", idx->name, idx->name, tmp->name, diff8);
            else if(IS_POW2(diff8 - 1))
                HC_FPRINTF(fptr, "\tlea %s, [%s+%s*%lu]\n\tadd %s, %s\n", idx->name, idx->name, tmp->name, diff8-1, idx->name, tmp->name);
            else if(diff8 == 6)
                HC_FPRINTF(fptr, "\tlea %s, [%s+%s*4]\n\tlea %s, [%s+%s*2]\n", idx->name, idx->name, tmp->name, idx->name, idx->name, tmp->name);
            else if(diff8 == 7)
                HC_FPRINTF(fptr, "\tlea %s, [%s+%s*8]\n\tsub %s, %s\n", idx->name, idx->name, tmp->name, idx->name, tmp->name);
            HC_FPRINTF(fptr, "\tshl %s, 3\n", tmp->name);
            diff /= 8;
        }
        while(diff){
            if(diff >= 8){
                HC_FPRINTF(fptr, "\tlea %s, [%s %c %s*8]\n", idx->name, idx->name, diff_sign?'-':'+', tmp->name);
                diff -= 8;
            }else if(diff >= 4){
                HC_FPRINTF(fptr, "\tlea %s, [%s %c %s*4]\n", idx->name, idx->name, diff_sign?'-':'+', tmp->name);
                diff -= 4;
            }else if(diff >= 2){
                HC_FPRINTF(fptr, "\tlea %s, [%s %c %s*2]\n", idx->name, idx->name, diff_sign?'-':'+', tmp->name);
                diff -= 2;
            }else{
                HC_FPRINTF(fptr, "\t%s %s, %s\n", diff_sign?"sub":"add", idx->name, tmp->name);
                diff--;
            }
        }
    }
    return elem_sz;
}
x64_LOCATION_L(idx, x64_INDEX_ARGS, "[%s+%s*%lu]", ptr->name, idx->name, x64_index_scale(fptr, idx, elem_sz));
x64_LOCATION_LX(idx, x64_ARGS(reg_t* ptr, reg_t* idx), "[%s+%s*%lu]", ptr->name, idx->name, x64_index_scale(fptr, idx, sz));
x64_LOCATION_PTR(idx, x64_INDEX_ARGS, "[%s+%s*%lu]", ptr->name, idx->name, x64_index_scale(fptr, idx, elem_sz));
x64_LOCATION_SV(idx, x64_INDEX_ARGS, "[%s+%s*%lu]", ptr->name, idx->name, x64_index_scale(fptr, idx, elem_sz));

// Pointer + offset IO
#define x64_OFFSET_ARGS x64_ARGS(reg_t* ptr, size_t offset)
x64_LOCATION_L(offset, x64_OFFSET_ARGS, "[%s+%lu]", ptr->name, offset);
x64_LOCATION_LX(offset, x64_OFFSET_ARGS, "[%s+%lu]", ptr->name, offset);
x64_LOCATION_PTR(offset, x64_OFFSET_ARGS, "[%s+%lu]", ptr->name, offset);
x64_LOCATION_SV(offset, x64_OFFSET_ARGS, "[%s+%lu]", ptr->name, offset);

// Copy memory
const reg_mask allowed_copy_regs = ALL_REGS_EXCEPT(REG(2) | REG(4) | REG(5));
#define GEN_COPY_MEMORY(addr, ...) \
    if(sz == 8){ HC_FPRINTF(fptr, "\tmov rdi, [" addr "]\n\tmov [%s], rdi\n",##__VA_ARGS__, dest->name); return; }\
    else if(sz == 4){ HC_FPRINTF(fptr, "\tmov edi, [" addr "]\n\tmov [%s], edi\n",##__VA_ARGS__, dest->name); return; }\
    else if(sz == 2){ HC_FPRINTF(fptr, "\tmov di, [" addr "]\n\tmov [%s], di\n",##__VA_ARGS__, dest->name); return; }\
    else if(sz == 1){ HC_FPRINTF(fptr, "\tmov dil, [" addr "]\n\tmov [%s], dil\n",##__VA_ARGS__, dest->name); return; }\
    char op_size = 'b';\
    if(sz % 8 == 0) op_size = 'q', sz /= 8;\
    else if(sz % 4 == 0) op_size = 'd', sz /= 4;\
    else if(sz % 2 == 0) op_size = 'w', sz /= 2;\
    HC_FPRINTF(fptr,"\tcld\n\tmov rdi, %s\n\tlea rsi, [" addr "]\n\tmov rcx, %lu\n\trep movs%c\n", dest->name,##__VA_ARGS__, sz, op_size)
void gen_copy_global(HC_FILE fptr, reg_t* dest, const char* str, size_t strlen, size_t sz){ GEN_COPY_MEMORY("%.*s", (int)strlen, str); }
void gen_copy_stack(HC_FILE fptr, reg_t* dest, size_t ptr, size_t sz){ GEN_COPY_MEMORY("rsp+%lu", ptr); }
void gen_copy_arg(HC_FILE fptr, reg_t* dest, size_t ptr, size_t sz){ GEN_COPY_MEMORY("rbp+%lu", ptr); }
void gen_copy_ptr(HC_FILE fptr, reg_t* dest, reg_t* src, size_t sz){ GEN_COPY_MEMORY("%s", src->name); }
void gen_copy_idx(HC_FILE fptr, reg_t* dest, reg_t* src, reg_t* idx, size_t sz){ GEN_COPY_MEMORY("%s+%s*%lu", src->name, idx->name, sz); }

// Reg transfer
void gen_move_reg(HC_FILE fptr, reg_t* op, reg_t* src){ x64_LOAD("%s", src->name); }
void gen_movex_reg(HC_FILE fptr, reg_t* op, reg_t* src, bool sign){ size_t sz = src->size; x64_LOADX("%s", src->name); }

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

SET_ALLOWED_REGS1(shl, ALL_REGS_EXCEPT(REG(2)));
SET_ALLOWED_REGS2(shl, REG(2));
CREATE_OPERATION(shl, "\tshl %s, %s\n", op1->name, op2->name);

SET_ALLOWED_REGS1(shr, ALL_REGS_EXCEPT(REG(2)));
SET_ALLOWED_REGS2(shr, REG(2));
CREATE_OPERATION(shr, "\tshr %s, %s\n", op1->name, op2->name);

SET_ALLOWED_REGS1(sshr, ALL_REGS_EXCEPT(REG(2)));
SET_ALLOWED_REGS2(sshr, REG(2));
CREATE_OPERATION(sshr, "\tsar %s, %s\n", op1->name, op2->name);

SET_ALLOWED_REGS1(smul, REG(0));
SET_ALLOWED_REGS2(smul, ALL_REGS_EXCEPT(REG(0) | REG(3)));
SET_AFFECTED_REGS(smul, REG(3));
CREATE_OPERATION(smul, "\timul %s\n", op2->name);

SET_ALLOWED_REGS1(mul, REG(0));
SET_ALLOWED_REGS2(mul, ALL_REGS_EXCEPT(REG(0) | REG(3)));
SET_AFFECTED_REGS(mul, REG(3));
CREATE_OPERATION(mul, "\tmul %s\n", op2->name);

static void gen_division(HC_FILE fptr, reg_t* op, bool sign){
    if(op->size == 1) HC_FPRINTF(fptr, "\txor ah, ah\n");
    else HC_FPRINTF(fptr, "\txor rdx, rdx\n");
    HC_FPRINTF(fptr, "\t%s %s\n", (sign)?"idiv":"div", op->name);
}

SET_ALLOWED_REGS1(sdiv, REG(0));
SET_ALLOWED_REGS2(sdiv, ALL_REGS_EXCEPT(REG(0) | REG(3)));
SET_AFFECTED_REGS(sdiv, REG(3));
void gen_sdiv_regs(HC_FILE fptr, reg_t* op1, reg_t* op2){ gen_division(fptr, op2, true); }

SET_ALLOWED_REGS1(div, REG(0));
SET_ALLOWED_REGS2(div, ALL_REGS_EXCEPT(REG(0) | REG(3)));
SET_AFFECTED_REGS(div, REG(3));
void gen_div_regs(HC_FILE fptr, reg_t* op1, reg_t* op2){ gen_division(fptr, op2, false); }

static void gen_modulo(HC_FILE fptr, reg_t* op1, reg_t* op2, bool sign){
    gen_division(fptr, op2, sign);
    const char* remainder_reg[8] = {"ah","dx","","eax","","","","rdx"};
    HC_FPRINTF(fptr,"\tmov %s, %s\n", op1->name, remainder_reg[op1->size - 1]);
}

SET_ALLOWED_REGS1(smod, REG(0));
SET_ALLOWED_REGS2(smod, ALL_REGS_EXCEPT(REG(0) | REG(3)));
SET_AFFECTED_REGS(smod, REG(3));
void gen_smod_regs(HC_FILE fptr, reg_t* op1, reg_t* op2){ gen_modulo(fptr, op1, op2, true); }

SET_ALLOWED_REGS1(mod, REG(0));
SET_ALLOWED_REGS2(mod, ALL_REGS_EXCEPT(REG(0) | REG(3)));
SET_AFFECTED_REGS(mod, REG(3));
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

void gen_declare_extern(HC_FILE fptr, const char* str, size_t strlen, const char* category){ HC_FPRINTF(fptr, "extern %.*s:%s\n", (int)strlen, str, category); }

static const char* x64_decl[9] = {"Unknown","db","dw","Unknown","dd","Unknown","Unknown","Unknown","dq"};
void gen_start_global_decl(HC_FILE fptr, const char* str, size_t strlen, bool priv){
    HC_FPRINTF(fptr, "%s %.*s:data\n%.*s:\n", priv?"static":"global", (int)strlen, str, (int)strlen, str);
}
void gen_declare_int(HC_FILE fptr, int64_t val, size_t sz){
    HC_FPRINTF(fptr, "%s %lu\n", x64_decl[sz], val);
}
size_t gen_declare_str(HC_FILE fptr, const char* str, size_t strlen){
    size_t len = 1;
    HC_FPRINTF(fptr, "db ");
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
        }else if(*str == '\\' && *(str+1) == 'x'){
            str++, strlen--;
            HC_FPRINTF(fptr, "\",0x%.*s,\"",2,str+1);
            str += 2, strlen -= 2;
        }else if(*str == '\\' && *(str+1) == '\n'){
            str++, strlen--;
            continue;
        }else if(*str == '\\'){
            HC_FPRINTF(fptr, "\",%d,\"", (int)*(str+1));
            str++, strlen--;
        }else
            HC_FPRINTF(fptr,"%c",*str);
        len++;
    }
    HC_FPRINTF(fptr, ",0\n");
    return len;
}
void gen_declare_str_lit_ptr(HC_FILE fptr, size_t id){
    HC_FPRINTF(fptr, "dq STR%lu\n", id);
}
void gen_declare_global_ptr(HC_FILE fptr, const char* str, size_t strlen){
    HC_FPRINTF(fptr, "dq %.*s\n", (int)strlen, str);
}
void gen_declare_float(HC_FILE fptr, double val){
    HC_FPRINTF(fptr, "dq %.10F\n", val);
}
void gen_declare_mem(HC_FILE fptr, size_t size){
    HC_FPRINTF(fptr, "times %lu db 0\n", size);
}
void gen_declare_align(HC_FILE fptr, const char* str, size_t strlen, size_t sz){
    HC_FPRINTF(fptr, "times %lu - ($-%.*s) db 0\n", sz, (int)strlen, str);
}

void gen_declare_str_lit(HC_FILE fptr, size_t id, const char* str, size_t strlen){
    HC_FPRINTF(fptr, "STR%lu:\n", id);
    gen_declare_str(fptr, str, strlen);
}
void gen_declare_float_lit(HC_FILE fptr, size_t id, const char* str, size_t strlen){
    HC_FPRINTF(fptr, "FP%lu:\ndq %.*s\n", id, (int)strlen, str);
}

// float operations
void gen_pop_float(HC_FILE fptr){ HC_FPRINTF(fptr, "\tfstp st0\n"); }
void gen_load_float(HC_FILE fptr, size_t id){ HC_FPRINTF(fptr, "\tfld QWORD [FP%lu]\n", id); }
void gen_load_stack_float(HC_FILE fptr, size_t ptr){ HC_FPRINTF(fptr, "\tfld QWORD [rsp+%lu]\n", ptr); }
void gen_load_arg_float(HC_FILE fptr, size_t ptr){ HC_FPRINTF(fptr, "\tfld QWORD [rbp+%lu]\n", ptr+16); }
void gen_load_ptr_float(HC_FILE fptr, reg_t* ptr){ HC_FPRINTF(fptr, "\tfld QWORD [%s]\n", ptr->name); }
void gen_load_idx_float(HC_FILE fptr, reg_t* ptr, reg_t* idx, size_t sz){ HC_FPRINTF(fptr, "\tfld QWORD [%s+%s*%lu]\n", ptr->name, idx->name, sz); }
void gen_load_global_float(HC_FILE fptr, const char* str, size_t strlen){ HC_FPRINTF(fptr, "\tfld QWORD [%.*s]\n", (int)strlen, str); }
void gen_load_global_offset_float(HC_FILE fptr, const char* str, size_t strlen, size_t offset){ HC_FPRINTF(fptr, "\tfld QWORD [%.*s+%lu]\n", (int)strlen, str, offset); }
void gen_load_offset_float(HC_FILE fptr, reg_t* ptr, size_t offset){ HC_FPRINTF(fptr, "\tfld QWORD [%s+%lu]\n", ptr->name, offset); }
void gen_save_stack_float(HC_FILE fptr, size_t ptr){ HC_FPRINTF(fptr, "\tfstp QWORD [rsp+%lu]\n", ptr); }
void gen_save_arg_float(HC_FILE fptr, size_t ptr){ HC_FPRINTF(fptr, "\tfstp QWORD [rbp+%lu]\n", ptr+16); }
void gen_save_ptr_float(HC_FILE fptr, reg_t* ptr){ HC_FPRINTF(fptr, "\tfstp QWORD [%s]\n", ptr->name); }
void gen_save_idx_float(HC_FILE fptr, reg_t* ptr, reg_t* idx, size_t sz){ HC_FPRINTF(fptr, "\tfstp QWORD [%s+%s*%lu]\n", ptr->name, idx->name, sz); }
void gen_save_global_float(HC_FILE fptr, const char* str, size_t strlen){ HC_FPRINTF(fptr, "\tfstp QWORD [%.*s]\n", (int)strlen, str); }
void gen_save_global_offset_float(HC_FILE fptr, const char* str, size_t strlen, size_t offset){ HC_FPRINTF(fptr, "\tfstp QWORD [%.*s+%lu]\n", (int)strlen, str, offset); }
void gen_save_offset_float(HC_FILE fptr, reg_t* ptr, size_t offset){ HC_FPRINTF(fptr, "\tfstp QWORD [%s+%lu]\n", ptr->name, offset); }
void gen_load_float_reg(HC_FILE fptr, reg_t* op){
    gen_alloc_stack(fptr, 8);
    HC_FPRINTF(fptr, "\tfstp QWORD [rsp]\n");
    gen_pop_stack(fptr, op);
}
void gen_int_to_float(HC_FILE fptr, reg_t* reg){
    gen_push_stack(fptr, reg);
    HC_FPRINTF(fptr, "\tfild %s [rsp]\n", x64_sz_names[reg->size]);
    gen_dealloc_stack(fptr, reg->size);
}
void gen_float_to_int(HC_FILE fptr, reg_t* reg){
    gen_alloc_stack(fptr, reg->size);
    HC_FPRINTF(fptr, "\tfistp %s [rsp]\n", x64_sz_names[reg->size]);
    gen_pop_stack(fptr, reg);
}
void gen_neg_float(HC_FILE fptr){ HC_FPRINTF(fptr, "\tfchs\n"); }
void gen_add_floats(HC_FILE fptr){ HC_FPRINTF(fptr, "\tfaddp\n"); }
void gen_sub_floats(HC_FILE fptr){ HC_FPRINTF(fptr, "\tfsubp\n"); }
void gen_mul_floats(HC_FILE fptr){ HC_FPRINTF(fptr, "\tfmulp\n"); }
void gen_div_floats(HC_FILE fptr){ HC_FPRINTF(fptr, "\tfdivp\n"); }
void gen_mod_floats(HC_FILE fptr){ HC_FPRINTF(fptr, "\tfprem\n\tfstp st0\n"); }
void gen_cmpz_float(HC_FILE fptr){ HC_FPRINTF(fptr, "\tfldz\n\tfcomip\n\tfstp st0\n"); }
void gen_cmp_floats(HC_FILE fptr){ HC_FPRINTF(fptr, "\tfcomip\n\tfstp st0\n"); }
void gen_cmp_approx_floats(HC_FILE fptr){
    HC_FPRINTF(fptr,
        "\tfsubp\n"
        "\tfabs\n"
        "\tfld QWORD [FP_PRECISION]\n"
        "\tfcomip\n"
        "\tfstp st0\n"
    );
}

#endif
