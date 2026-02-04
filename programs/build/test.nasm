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

global table:function
table:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	lea rbx, [rbp+32]
	mov [rsp+24], rbx
	sub rsp, 16
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	call strlen
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rsp+16], rbx
	mov rbx, 0
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	sub rsp, 16
	.L1:
	test rbx, rbx
	je .L3
	sub rsp, 32
	mov [rsp+24], rbx
	mov rcx, [rsp+72]
	mov rsi, [rsp+56]
	mov rdi, [rcx+rsi*8]
	mov [rsp+8], rdi
	call strlen
	mov rbx, [rsp+24]
	mov rcx, [rsp+0]
	add rsp, 32
	mov [rsp+8], rcx
	mov rcx, [rsp+8]
	mov rsi, [rsp+32]
	cmp rcx, rsi
	seta cl
	test cl, cl
	je .L4
	mov rcx, [rsp+8]
	mov [rsp+32], rcx
	jmp .L5
	.L4:
	.L5:
	mov rcx, [rsp+24]
	inc rcx
	mov [rsp+24], rcx
	.L2:
	dec rbx
	jmp .L1
	.L3:
	add rsp, 16
	mov rbx, [rsp+16]
	mov rcx, 4
	add rbx, rcx
	mov [rsp+16], rbx
	sub rsp, 32
	mov rbx, STR0
	mov [rsp+0], rbx
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	mov rbx, [rsp+48]
	mov [rsp+16], rbx
	mov rbx, '-'
	mov [rsp+24], rbx
	call println
	add rsp, 32
	mov rbx, [rbp+24]
	.L6:
	test rbx, rbx
	je .L8
	sub rsp, 32
	mov [rsp+24], rbx
	mov rcx, STR1
	mov [rsp+0], rcx
	mov rcx, [rsp+56]
	mov rsi, [rcx]
	mov [rsp+8], rsi
	mov rcx, [rsp+48]
	mov [rsp+16], rcx
	call println
	mov rbx, [rsp+24]
	add rsp, 32
	mov rcx, [rsp+24]
	mov rsi, 8
	add rcx, rsi
	mov [rsp+24], rcx
	.L7:
	dec rbx
	jmp .L6
	.L8:
	sub rsp, 32
	mov rbx, STR2
	mov [rsp+0], rbx
	mov rbx, [rsp+48]
	mov [rsp+8], rbx
	mov rbx, '-'
	mov [rsp+16], rbx
	call println
	add rsp, 32
	.L0:
	leave
	ret

global main:function
main:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	fld QWORD [FP0]
	fstp QWORD [rsp+8]
	fld QWORD [FP1]
	fstp QWORD [rsp+0]
	fld QWORD [rsp+0]
	fld QWORD [rsp+8]
	fsubp
	fabs
	fld QWORD [FP_PRECISION]
	fcomip
	fstp st0
	setae bl
	test bl, bl
	je .L1
	sub rsp, 48
	mov rbx, STR3
	mov [rsp+0], rbx
	mov rbx, 5
	mov [rsp+8], rbx
	fld QWORD [rsp+56]
	fstp QWORD [rsp+16]
	mov rbx, 5
	mov [rsp+24], rbx
	fld QWORD [rsp+48]
	fstp QWORD [rsp+32]
	call println
	add rsp, 48
	jmp .L2
	.L1:
	.L2:
	sub rsp, 48
	mov rbx, STR4
	mov [rsp+0], rbx
	mov rbx, 3
	mov [rsp+8], rbx
	mov rbx, STR5
	mov [rsp+16], rbx
	mov rbx, STR6
	mov [rsp+24], rbx
	mov rbx, STR7
	mov [rsp+32], rbx
	call table
	add rsp, 48
	sub rsp, 32
	mov rbx, STR8
	mov [rsp+0], rbx
	fld QWORD [rsp+40]
	fstp QWORD [rsp+8]
	sub rsp, 32
	fld QWORD [rsp+72]
	fstp QWORD [rsp+8]
	mov bl, 0x00
	mov [rsp+16], bl
	call round
	fld QWORD [rsp+0]
	add rsp, 32
	fstp QWORD [rsp+16]
	call println
	add rsp, 32
	sub rsp, 32
	mov rbx, STR9
	mov [rsp+0], rbx
	fld QWORD [rsp+40]
	fstp QWORD [rsp+8]
	sub rsp, 32
	fld QWORD [rsp+72]
	fstp QWORD [rsp+8]
	mov bl, 0x04
	mov [rsp+16], bl
	call round
	fld QWORD [rsp+0]
	add rsp, 32
	fstp QWORD [rsp+16]
	call println
	add rsp, 32
	sub rsp, 32
	mov rbx, STR10
	mov [rsp+0], rbx
	fld QWORD [rsp+40]
	fstp QWORD [rsp+8]
	sub rsp, 32
	fld QWORD [rsp+72]
	fstp QWORD [rsp+8]
	mov bl, 0x08
	mov [rsp+16], bl
	call round
	fld QWORD [rsp+0]
	add rsp, 32
	fstp QWORD [rsp+16]
	call println
	add rsp, 32
	sub rsp, 32
	mov rbx, STR11
	mov [rsp+0], rbx
	fld QWORD [rsp+40]
	fstp QWORD [rsp+8]
	sub rsp, 32
	fld QWORD [rsp+72]
	fstp QWORD [rsp+8]
	mov bl, 0x0C
	mov [rsp+16], bl
	call round
	fld QWORD [rsp+0]
	add rsp, 32
	fstp QWORD [rsp+16]
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
FP_PRECISION:
dq 0.001


section .rodata
STR0:
db "+%[ %s %*C+",0
STR1:
db "|%[ %s%L|",0
STR2:
db "+%*c+",0
STR3:
db "%*f ~= %*f",0
STR4:
db "Foo tierlist",0
STR5:
db "1. Foo",0
STR6:
db "2. Bar",0
STR7:
db "3. Foo-bar",0
STR8:
db "round(%f, FP_ROUND) = %f",0
STR9:
db "round(%f, FP_FLOOR) = %f",0
STR10:
db "round(%f, FP_CEIL)  = %f",0
STR11:
db "round(%f, FP_TRUNC) = %f",0
FP0:
dq 3.14150
FP1:
dq 3.14155
