#ifdef TARGET_x64_Linux

#include "../dev/libs.h"
#include "../generator/target_requirements.h"
#include "x64_regs.h"
#include "x64_ops.h"

const char* target_architecture = "x64 Linux";
const size_t target_address_size = 8; // bytes
const unsigned int target_cpu = 64;
const char* target_assembler = "nasm (Netwide Assembler)";
const char* target_linker = "ld (GNU Linker)";

const char* target_entry_point = "_start";
const char* target_text_section = "section .text\n";
const char* target_data_section = "section .data\n";
const char* target_rodata_section = "section .rodata\n";

void gen_setup(HC_FILE fptr, bool library){
    HC_FPRINTF(fptr,
        "BITS 64\n"
        "CPU X64\n"
        "default ABS\n");
    if(library) return;
    HC_FPRINTF(fptr,
        "global _start\n"
        "_start:\n"
        "\tfninit\n"
        "\tmov rax, [rsp+0]\n"
        "\tlea rbx, [rsp+8]\n"
        "\tsub rsp, 32\n"
        "\tmov [rsp+8], rax\n"
        "\tmov [rsp+16], rbx\n"
        "\tcall main\n"
        "\tmov rax, 60\n"
        "\tmov rdi, [rsp]\n"
        "\tsyscall\n");
}

int assemble(const char* output_file, bool debug){
    char buffer[1024];
    snprintf(buffer, 1023, "nasm %s -felf64 %s.nasm -o %s.o", debug ? "-g -F dwarf" : "", output_file, output_file);
    return system(buffer);
}

int link(const char* output_file, char* link_files){
    char buffer[4096];
    for(char* ptr = link_files; *ptr; ptr++)
        if(*ptr == ',') *ptr = ' ';
    snprintf(buffer, 4095, "ld %s %s.o -o %s", link_files, output_file, output_file);
    return system(buffer);
}

#endif
