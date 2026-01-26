#include "std/stdlib.hhc"

int absi(int x){
    if(x < 0){ return -x; }
    return x;
}
float absf(float x){
    @asm("fld QWORD [rbp+24]
    fabs
    fstp QWORD [rbp+16]");
}

void random(uint8* data, uint size){
    @asm(rax, rdi, rsi, rdx,
    "mov rax, 318
    mov rdi, %0
    mov rsi, %1
    xor rdx, rdx
    syscall", data, size);
}
int randint(int min, int max){
    int rnd;
    random(&rnd, 8);
    return rnd % (max - min) + min;
}

bool is_alpha(char c){
    return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z');
}
bool is_num(char c){
    return c >= '0' && c <= '9';
}
bool is_alnum(char c){
    return is_alpha(c) || is_num(c);
}

char to_lower(char c){
    if(is_alpha(c)){
        return c | 0b00100000;
    }
    return c;
}
char to_upper(char c){
    if(is_alpha(c)){
        return c | 0b11011111;
    }
    return c;
}

void set_rounding(uint8 mode){
    uint16 fcw;
    @asm("fstcw [%0]", &fcw);
    fcw = fcw & 0xF3FF;
    fcw = fcw | (mode << 8);
    @asm("fldcw [%0]", &fcw);
}

float modf(float x, float d){
    @asm("fld QWORD [rbp+24]
    fld QWORD [rbp+32]
    fprem
    fstp QWORD [rbp+16]
    fstp st0");
}
float sqrt(float x){
    @asm("fld QWORD [rbp+24]
    fsqrt
    fstp QWORD [rbp+16]");
}

float sin(float x){
    x = modf(x, 6.28318530718);
    @asm("fld QWORD [rbp+24]
    fsin
    fstp QWORD [rbp+16]");
}
float cos(float x){
    x = modf(x, 6.28318530718);
    @asm("fld QWORD [rbp+24]
    fcos
    fstp QWORD [rbp+16]");
}
float tan(float x){
    x = modf(x, 6.28318530718);
    @asm("fld QWORD [rbp+24]
    fptan
    fstp st0
    fstp QWORD [rbp+16]");
}
float atan2(float y, float x){
    @asm("fld QWORD [rbp+24]
    fld QWORD [rbp+32]
    fpatan
    fstp QWORD [rbp+16]");
}

float round(float x, uint8 mode){
    set_rounding(mode);
    @asm(
    "fld QWORD [rbp+24]
    frndint
    fstp QWORD [rbp+16]");
    set_rounding();
}

// Fixed point arithmetic
fixed int_to_fixed(int x){
    return x << FIXED_PRECISION;
}
fixed fraction_to_fixed(int a, int b){
    return (int)((a << (FIXED_PRECISION2)) / b);
}
fixed string_to_fixed(char* str, uint len){
    if(len == -1){ len = strlen(str); }
    fixed int_x = 0;
    fixed frac_x = 0;
    int32 d = 1;
    bool sign = false;
    bool frac = false;
    for(; len; ++str, --len){
        if(*str == '-'){ sign = !sign; }
        else if(*str >= '0' && *str <= '9'){
            if(frac){
                frac_x = frac_x * 10 + ((*str - '0') << FIXED_PRECISION);
                d *= 10;
            }else{
                int_x = int_x * 10 + ((*str - '0') << FIXED_PRECISION);
            }
        }else if(*str == '.'){
            frac = true;
        }
    }
    int_x += (frac_x / d) & FIXED_FRAC_MASK;
    if(sign){ int_x = -int_x; }
    return int_x;
}
int fixed_to_int(fixed x){
    return x >> FIXED_PRECISION;
}
fixed mul_fixed(fixed a, fixed b){
    return (int)((a * b) >> FIXED_PRECISION);
}
fixed div_fixed(fixed a, fixed b){
    return (int)((a << FIXED_PRECISION) / b);
}
fixed mod_fixed(fixed a, fixed b){
    return (int)((a << FIXED_PRECISION) % b);
}

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

uint strfind(char* str, char c, uint len){
    if(len != -1){
        @asm(rdi, al, rcx,
    "mov al, %0
    mov rdi, %1
    mov rcx, %2
    cld
    repne scasb
    sub %2, rcx
    dec %2
    mov [%3], %2",
        c, str, len + 1, &@return);
    }else{
        @asm(rdi, al, rcx,
    "mov al, %0
    mov rdi, %1
    mov rcx, ~0
    cld
    repne scasb
    not rcx
    dec rcx
    mov [%2], rcx",
        c, str, &@return);
    }
}

// Terminal IO
#define STDOUT_BUFF_SZ 1024
char stdout_buff[STDOUT_BUFF_SZ];
uint stdout_cursor = 0;

void flush_stdout(){
    write(STDOUT, stdout_buff, stdout_cursor);
    stdout_cursor = 0;
}

// Prints a string with a specified length
// If len = -1 (so no length provided), len = strlen(str)
void print_str(char* str, uint len){
    if(len == -1){ len = strlen(str); }
    repeat(len){
        stdout_buff[stdout_cursor++] = *str;
        if(*str == '\n'){ flush_stdout(); }
        ++str;
    }
}

// Prints a single character
void print_char(char c){
    stdout_buff[stdout_cursor++] = c;
    if(c == '\n'){ flush_stdout(); }
}

// Prints a signed 64 bit int in decimal form
void print_decimal(int x){
    char buffer[32];
    print_str(int_to_string(x, buffer, 32));
}

// Prints an unsigned 64 bit int in decimal form
void print_udecimal(uint x){
    char buffer[32];
    print_str(uint_to_string(x, buffer, 32));
}

// Prints an unsigned 64 bit int in hexadecimal form
void print_hex(uint x){
    char buffer[32];
    buffer[31] = 0;
    char* lookup = "0123456789ABCDEF";
    char* ptr = buffer + 30;
    if(x == 0){ *(ptr--) = '0'; }
    for(; x; x = x >> 4, --ptr){ *ptr = lookup[x & 0xF]; }
    *(ptr--) = 'x';
    *(ptr) = '0';
    print_str(ptr);
}

// Prints a fixed point number
void print_fixed(fixed x){
    if(x < 0){
        print_char('-');
        x = -x;
    }
    uint integer = x >> FIXED_PRECISION;
    uint fractional = (x & FIXED_FRAC_MASK) * 10000 / (1 << FIXED_PRECISION);
    print_udecimal(integer);
    print_char('.');
    char buffer[32];
    print_str(uint_to_string(fractional, buffer, 5, '0'));
}

void print_float(float x){
    char buffer[32];
    bool sign = (x < 0.0);
    if(sign){
        print_char('-');
        x = -x;
    }
    uint integer = x;
    uint fractional = (x - (float)integer) * 10000.0;
    set_rounding(FP_ZERO);
    print_udecimal(integer);
    print_char('.');
    print_str(uint_to_string(fractional, buffer, 5, '0'));
}

void print_format(char* fmt, uint* argv){
    // Go through each part of the format string
    uint argc = 0;
    uint len = strlen(fmt);
    while(len){
        uint n = strfind(fmt, '%', len);
        if(n){
            print_str(fmt, n);
        }else if(*(fmt+1) == 'i'){
            print_decimal(argv[argc++]);
        }else if(*(fmt+1) == 'u'){
            print_udecimal(argv[argc++]);
        }else if(*(fmt+1) == 'x'){
            print_hex(argv[argc++]);
        }else if(*(fmt+1) == 's'){
            print_str((char*)argv[argc++]);
        }else if(*(fmt+1) == 'c'){
            print_char(argv[argc++]);
        }else if(*(fmt+1) == 'b'){
            if(argv[argc++]){ print_str("true "); }
            else{ print_str("false"); }
        }else if(*(fmt+1) == 'F'){
            print_fixed((fixed)argv[argc++]);
        }else if(*(fmt+1) == 'f'){
            print_float(((float*)argv)[argc++]);
        }else if(*(fmt+1) == '%'){
            print_char('%');
        }else if(*(fmt+1) == '*'){
            ++fmt;
            uint mod = argv[argc++];
            if(*(fmt+1) == 's'){
                print_str((char*)argv[argc++], mod);
            }else if(*(fmt+1) == 'c'){
                char c = argv[argc++];
                repeat(mod){ print_char(c); }
            }else{
                print_str("\nUnexpected format specifier %");
                print_str(fmt-1, 2);
                print_char('\n');
                exit(1);
            }
        }else{
            print_str("\nUnexpected format specifier %");
            print_char(*(fmt+1));
            print_char('\n');
            exit(1);
        }
        if(n){
            fmt += n;
            len -= n;
        }else{
            fmt += 2;
            len -= 2;
        }
    }
}

void print(char* fmt, ...){
    print_format(fmt, VARGS);
}

void println(char* fmt, ...){
    print_format(fmt, VARGS);
    print_char('\n');
}

void error(char* fmt, ...){
    print_format(fmt, VARGS);
    print_char('\n');
    exit(EXIT_FAILURE);
}

// Takes in a buffer, its size
// Returns number of characters read
uint input(char* buff, uint len){
    // Use read(stdin, buff, len)
    int result = read(STDIN, buff, len);
    if(result < 0){ error("input() error: %i", result); }
    buff[--result] = 0;
    return result;
}

char input_char(){
    uint16 c = 0;
    int result = read(STDIN, &c, 2);
    if(result < 0){ error("input_char() error: %i", result); }
    return c;
}

// INT - STR conversion
char* int_to_string(int x, char* str, uint len, char filler){
    char* ptr = &str[--len];
    bool sign = x < 0;
    if(sign){ x = -x; }
    *ptr = 0;
    --ptr;
    if(x == 0){ *(ptr--) = '0'; }
    for(; x && len; x /= 10, --len, --ptr){ *ptr = (int)(x % 10) + '0'; }
    if(filler){
        repeat(len){ *(ptr--) = filler; }
    }
    if(sign){ *(ptr--) = '-'; }
    return ptr+1;
}

char* uint_to_string(uint x, char* str, uint len, char filler){
    char* ptr = &str[--len];
    *ptr = 0;
    --ptr;
    if(x == 0){ *(ptr--) = '0'; }
    for(; x && len; x /= 10, --len, --ptr){ *ptr = (uint)(x % 10) + '0'; }
    if(filler){
        repeat(len){ *(ptr--) = filler; }
    }
    return ptr+1;
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

// Reads len bytes from file descriptor -> buff
int read(uint fd, char* buff, uint len){
    @asm(rax, rdi, rsi, rdx,
    "mov rax, 0
    mov rdi, %0
    mov rsi, %1
    mov rdx, %2
    syscall
    mov [rbp+16], rax", fd, buff, len);
}

// Writes len bytes from buff -> file descriptor
int write(uint fd, char* buff, uint len){
    @asm(rax, rdi, rsi, rdx,
    "mov rax, 1
    mov rdi, %0
    mov rsi, %1
    mov rdx, %2
    syscall
    mov [rbp+16], rax", fd, buff, len);
}

// Exits the program instantly with a code
void exit(int code){
    @asm(rax, rdi,
    "mov rax, 60
    mov rdi, %0
    syscall", code);
}
