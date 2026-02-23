section .text
BITS 64
CPU X64
default ABS
global _start
_start:
	fninit
	mov rax, [rsp+0]
	lea rbx, [rsp+8]
	sub rsp, 32
	mov [rsp+8], rax
	mov [rsp+16], rbx
	call main
	mov rax, 60
	mov rdi, [rsp]
	syscall

global main:function
main:
	push rbp
	mov rbp, rsp
	leave
	ret
extern absi
extern absf
extern random
extern randint
extern is_alpha
extern is_num
extern is_alnum
extern to_lower
extern to_upper
extern set_rounding
extern modf
extern sqrt
extern pow
extern log
extern sin
extern cos
extern tan
extern atan2
extern round
extern int_to_fixed
extern fraction_to_fixed
extern string_to_fixed
extern fixed_to_int
extern mul_fixed
extern div_fixed
extern mod_fixed
extern memset
extern memcpy
extern memmove
extern strlen
extern strfind
extern strdfind
extern strcpy
extern strcmp
extern strequal
extern flush_stdout
extern print_str
extern print_char
extern print_decimal
extern print_udecimal
extern print_hex
extern print_fixed
extern print_float
extern print_format
extern print
extern println
extern error
extern input
extern input_char
extern int_to_string
extern uint_to_string
extern string_to_int
extern read
extern write
extern exit


section .data


section .rodata
