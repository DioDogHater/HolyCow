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

global fibo_recursive:function
fibo_recursive:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+24]
	mov rcx, 0
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L1
	mov rbx, 0
	mov [rbp+16], rbx
	jmp .L0
	jmp .L2
	.L1:
	mov rbx, [rbp+24]
	mov rcx, 1
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L3
	mov rbx, 1
	mov [rbp+16], rbx
	jmp .L0
	jmp .L2
	.L3:
	.L2:
	sub rsp, 16
	mov rbx, [rbp+24]
	mov rcx, 1
	sub rbx, rcx
	mov [rsp+8], rbx
	call fibo_recursive
	mov rbx, [rsp+0]
	add rsp, 16
	sub rsp, 32
	mov [rsp+24], rbx
	mov rcx, [rbp+24]
	mov rsi, 2
	sub rcx, rsi
	mov [rsp+8], rcx
	call fibo_recursive
	mov rbx, [rsp+24]
	mov rcx, [rsp+0]
	add rsp, 32
	add rbx, rcx
	mov [rbp+16], rbx
	jmp .L0
	.L0:
	leave
	ret

global fibo_iterative:function
fibo_iterative:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov rbx, [rbp+24]
	mov rcx, 0
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L1
	mov rbx, 0
	mov [rbp+16], rbx
	jmp .L0
	jmp .L2
	.L1:
	.L2:
	mov rbx, 0
	mov [rsp+24], rbx
	mov rbx, 1
	mov [rsp+16], rbx
	mov rbx, 0
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov rcx, 1
	sub rbx, rcx
	.L3:
	test rbx, rbx
	je .L5
	mov rcx, [rsp+24]
	mov rsi, [rsp+16]
	add rcx, rsi
	mov [rsp+8], rcx
	mov rcx, [rsp+16]
	mov [rsp+24], rcx
	mov rcx, [rsp+8]
	mov [rsp+16], rcx
	.L4:
	dec rbx
	jmp .L3
	.L5:
	mov rbx, [rsp+16]
	mov [rbp+16], rbx
	jmp .L0
	.L0:
	leave
	ret

global main:function
main:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	sub rsp, 16
	mov rbx, STR0
	mov [rsp+0], rbx
	mov rbx, 1
	neg rbx
	mov [rsp+8], rbx
	call print_str
	add rsp, 16
	sub rsp, 32
	lea rbx, [rsp+48]
	mov [rsp+8], rbx
	mov rbx, 32
	mov [rsp+16], rbx
	call input
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+8], rbx
	sub rsp, 32
	lea rbx, [rsp+48]
	mov [rsp+8], rbx
	mov rbx, [rsp+40]
	mov [rsp+16], rbx
	call string_to_int
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+0], rbx
	mov rbx, [rsp+0]
	mov rcx, 0
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L1
	sub rsp, 16
	mov rbx, STR1
	mov [rsp+0], rbx
	mov rbx, 1
	neg rbx
	mov [rsp+8], rbx
	call print_str
	add rsp, 16
	jmp .L0
	jmp .L2
	.L1:
	.L2:
	sub rsp, 32
	mov rbx, STR2
	mov [rsp+0], rbx
	mov rbx, [rsp+32]
	mov [rsp+8], rbx
	sub rsp, 16
	mov rbx, [rsp+48]
	mov [rsp+8], rbx
	call fibo_iterative
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rsp+16], rbx
	call println
	add rsp, 32
	.L0:
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
STR0:
db "This program calculates the nth fibonacci number.",10,"Please enter n: ",0
STR1:
db "n must be >= 0",10,"",0
STR2:
db "The %ith fibonacci number is %u",0
