#include "std/stdlib.hhc"

// STR operations

// Sets bytes to a certain 8 bit value
void memset(uint8* mem, uint8 data, uint mem_size){
    @asm(al,rcx,rdi,
         "mov rdi, %0
         mov al, %1
         mov rcx, %2
         cld
         rep stosb", mem, data, mem_size);
}

// Copies bytes from src to dest
void memcpy(uint8* dest, uint8* src, uint mem_size){
    @asm(rcx, rsi, rdi,
    "mov rdi, %0
    mov rsi, %1
    mov rcx, %2
    cld
    rep movsb", dest, src, mem_size);
}

// Returns the length of a string
uint strlen(char* str){
    @asm(rdi, al, rcx,
    "xor al, al
    mov rdi, %0
    mov rcx, ~0
    cld
    repne scasb
    not rcx
    dec rcx
    mov [%1], rcx", str, &@return);
}

// Terminal IO

// Prints a string with a specified length
// If len = -1 (so no length provided), len = strlen(str)
void print_str(char* str, uint len){
    if(len == -1){ len = strlen(str); }
    // Use sys_write(stdout, str, len)
    @asm(rax, rdi, rsi, rdx,
    "mov rax, 1
    mov rdi, 1
    mov rsi, %0
    mov rdx, %1
    syscall", str, len);
}

// Prints a signed 64 bit int in decimal form
void print_decimal(int x){
    char buffer[32];
    print_str(int_to_string(x, buffer, 32));
}

// Prints an unsigned 64 bit int in hexadecimal form
void print_hex(uint x){
    char buffer[32];
    buffer[31] = 0;
    char* lookup = "0123456789ABCDEF";
    char* ptr = buffer + 30;
    for(; x; x /= 16, --ptr){ *ptr = lookup[x & 0xF]; }
    *(ptr--) = 'x';
    *(ptr) = '0';
    print_str(ptr);
}

// Takes in a buffer, its size
// Returns number of characters read
uint input(char* buff, uint len){
    // Use sys_read(stdin, buff, buff_len)
    @asm(rax, rdi, rsi, rdx,
    "mov rax, 0
    mov rdi, 0
    mov rsi, %0
    mov rdx, %1
    syscall
    mov [rbp+16], rax", buff, len);
}

// INT - STR conversion
char* int_to_string(int x, char* str, uint len){
    char* ptr = &str[len - 1];
    bool sign = x < 0;
    if(sign){ x = -x; }
    *ptr = 0;
    --ptr;
    for(; x && ptr - str < len; x /= 10, ptr--){ *ptr = (x % 10) + '0'; }
    if(sign){ *(ptr--) = '-'; }
    return (char*)(ptr + 1);
}

int string_to_int(char* str, uint len){
    if(len == -1){ len = strlen(str); }
    int result = 0;
    bool sign = false;
    for(; len; ++str, --len){
        if(*str == '-'){ sign = !sign; }
        else if(*str >= '0' && *str <= '9'){
            result = result * 10 + (*str - '0');
        }
    }
    if(sign){ result = -result; }
    return result;
}

// OS stuff

// Exits the program instantly with a code
void exit(int code){
    @asm(rax, rdi,
    "mov rax, 60
    mov rdi, %0
    syscall", code);
}
