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
	mov QWORD [rsp], 0
	mov [rsp+8], rax
	mov [rsp+16], rbx
	call main
	mov rax, 60
	mov rdi, [rsp]
	syscall

global frame:function
frame:
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
	xor rbx, rbx
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
	mov rcx, 0x4
	add rbx, rcx
	mov [rsp+16], rbx
	mov rcx, [rbp+16]
	mov sil, [rcx]
	test sil, sil
	sete bl
	test bl, bl
	je .L6
	sub rsp, 32
	mov rbx, STR0
	mov [rsp+0], rbx
	mov rbx, [rsp+48]
	mov [rsp+8], rbx
	mov rbx, 0x2d
	mov [rsp+16], rbx
	call println
	add rsp, 32
	jmp .L7
	.L6:
	sub rsp, 32
	mov rbx, STR1
	mov [rsp+0], rbx
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	mov rbx, [rsp+48]
	mov [rsp+16], rbx
	mov rbx, 0x2d
	mov [rsp+24], rbx
	call println
	add rsp, 32
	.L7:
	mov rbx, [rbp+24]
	.L8:
	test rbx, rbx
	je .L10
	sub rsp, 32
	mov [rsp+24], rbx
	mov rcx, STR2
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
	mov rsi, 0x8
	add rcx, rsi
	mov [rsp+24], rcx
	.L9:
	dec rbx
	jmp .L8
	.L10:
	sub rsp, 32
	mov rbx, STR0
	mov [rsp+0], rbx
	mov rbx, [rsp+48]
	mov [rsp+8], rbx
	mov rbx, 0x2d
	mov [rsp+16], rbx
	call println
	add rsp, 32
	.L0:
	leave
	ret

global get_test:function
get_test:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	mov rcx, 0xa
	mov [rbx+0], rcx
	mov rbx, [rbp+16]
	mov rcx, 0x5
	mov [rbx+8], rcx
	mov rbx, [rbp+16]
	lea rbx, [rbx+16]
	mov rcx, STR3
	mov [rbx+0], rcx
	mov rcx, STR4
	mov [rbx+8], rcx
	.L0:
	leave
	ret

global print_test:function
print_test:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	mov rbx, STR5
	mov [rsp+0], rbx
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	lea rcx, [rbp+16]
	lea rcx, [rcx+16]
	mov rbx, [rcx+0]
	mov [rsp+24], rbx
	lea rcx, [rbp+16]
	lea rcx, [rcx+16]
	mov rbx, [rcx+8]
	mov [rsp+32], rbx
	call println
	add rsp, 48
	.L0:
	leave
	ret

global print_msg:function
print_msg:
	push rbp
	mov rbp, rsp
	mov rcx, [rbp+16]
	mov rbx, [rcx+0]
	mov rcx, 0x1
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L1
	sub rsp, 16
	mov rbx, STR6
	mov [rsp+0], rbx
	mov rcx, [rbp+16]
	lea rcx, [rcx+8]
	mov rbx, [rcx]
	mov [rsp+8], rbx
	call println
	add rsp, 16
	jmp .L2
	.L1:
	mov rcx, [rbp+16]
	mov rbx, [rcx+0]
	mov rcx, 0x2
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L3
	sub rsp, 16
	mov rbx, STR7
	mov [rsp+0], rbx
	mov rcx, [rbp+16]
	lea rcx, [rcx+8]
	mov rbx, [rcx]
	mov [rsp+8], rbx
	call println
	add rsp, 16
	jmp .L2
	.L3:
	mov rcx, [rbp+16]
	mov rbx, [rcx+0]
	mov rcx, 0x3
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L4
	sub rsp, 16
	mov rbx, STR8
	mov [rsp+0], rbx
	mov rbx, [rbp+16]
	lea rbx, [rbx+8]
	fld DWORD [rbx]
	fstp QWORD [rsp+8]
	call println
	add rsp, 16
	jmp .L2
	.L4:
	sub rsp, 16
	mov rbx, STR9
	mov [rsp+0], rbx
	mov rcx, [rbp+16]
	lea rcx, [rcx+8]
	movzx rbx, BYTE [rcx]
	mov [rsp+8], rbx
	call println
	add rsp, 16
	.L2:
	.L0:
	leave
	ret

global main:function
main:
	push rbp
	mov rbp, rsp
	sub rsp, 64
	fld QWORD [FP0]
	fstp QWORD [rsp+56]
	fld QWORD [FP1]
	fstp QWORD [rsp+48]
	fld QWORD [rsp+48]
	fld QWORD [rsp+56]
	fsubp
	fabs
	fld QWORD [FP_PRECISION]
	fcomip
	fstp st0
	setae bl
	test bl, bl
	je .L1
	sub rsp, 48
	mov rbx, STR10
	mov [rsp+0], rbx
	mov rbx, 0xa
	mov [rsp+8], rbx
	fld QWORD [rsp+104]
	fstp QWORD [rsp+16]
	mov rbx, 0xa
	mov [rsp+24], rbx
	fld QWORD [rsp+96]
	fstp QWORD [rsp+32]
	fld QWORD [FP_PRECISION]
	fstp QWORD [rsp+40]
	call println
	add rsp, 48
	jmp .L2
	.L1:
	.L2:
	sub rsp, 48
	mov rbx, STR11
	mov [rsp+0], rbx
	mov rbx, 0x3
	mov [rsp+8], rbx
	mov rbx, STR12
	mov [rsp+16], rbx
	mov rbx, STR13
	mov [rsp+24], rbx
	mov rbx, STR14
	mov [rsp+32], rbx
	call frame
	add rsp, 48
	lea rbx, [rsp+16]
	xor rcx, rcx
	mov [rbx+0], rcx
	mov rcx, 0x6
	mov [rbx+8], rcx
	lea r8, [rbx+16]
	mov rcx, STR15
	mov [r8+0], rcx
	mov rcx, STR16
	mov [r8+8], rcx
	sub rsp, 32
	lea rbx, [rsp+0]
	cld
	mov rdi, rbx
	lea rsi, [rsp+48]
	mov rcx, 4
	rep movsq
	call print_test
	add rsp, 32
	sub rsp, 32
	lea rbx, [rsp+0]
	sub rsp, 16
	mov [rsp+0], rbx
	call get_test
	add rsp, 16
	call print_test
	add rsp, 32
	lea rbx, [rsp+0]
	mov rcx, 0x1
	mov [rbx+0], rcx
	lea r8, [rbx+8]
	mov rcx, STR15
	mov [r8], rcx
	sub rsp, 16
	lea rbx, [rsp+16]
	mov [rsp+0], rbx
	call print_msg
	add rsp, 16
	.L0:
	leave
	ret


extern int_to_fixed:function
extern log:function
extern fraction_to_fixed:function
extern sin:function
extern print_char:function
extern trunc:function
extern print:function
extern set_rounding:function
extern div_fixed:function
extern pow:function
extern memmove:function
extern mul_fixed:function
extern random:function
extern is_num:function
extern memset:function
extern exit:function
extern read:function
extern tan:function
extern int_to_string:function
extern string_to_int:function
extern string_to_fixed:function
extern write:function
extern print_format:function
extern strcmp:function
extern strfind:function
extern absf:function
extern fixed_to_int:function
extern print_fixed:function
extern absi:function
extern floor:function
extern uint_to_string:function
extern strdfind:function
extern flush_stdout:function
extern to_lower:function
extern memcpy:function
extern input_char:function
extern strequal:function
extern strlen:function
extern ceil:function
extern print_str:function
extern to_upper:function
extern print_udecimal:function
extern input:function
extern print_decimal:function
extern is_alpha:function
extern cos:function
extern strcpy:function
extern print_double:function
extern mod_fixed:function
extern println:function
extern round:function
extern sqrt:function
extern error:function
extern randint:function
extern print_hex:function
extern atan2:function
extern is_alnum:function


section .data
static __FP_TMP:data
__FP_TMP:
dq 0
static __GP_TMP:data
__GP_TMP:
times 64 db 0
global FP_PRECISION:data
FP_PRECISION:
dq 0.0001000000


section .rodata
STR0:
db "+%*c+",0
STR1:
db "+%[ %s %*C+",0
STR2:
db "|%[ %s%L|",0
STR3:
db "Diddy",0
STR4:
db "Blud",0
STR5:
db "test{%i, %i, test2{",34,"%s",34,", ",34,"%s",34,"}}",0
STR6:
db "msg{msg.text, ",34,"%s",34,"}",0
STR7:
db "msg{msg.integer, %i}",0
STR8:
db "msg{msg.number, %f}",0
STR9:
db "msg{msg.confirm, %b}",0
STR10:
db "%*f ~= %*f ± %f",0
STR11:
db "Foo tierlist",0
STR12:
db "1. Foo",0
STR13:
db "2. Bar",0
STR14:
db "3. Foo-bar",0
STR15:
db "Hello world!",0
STR16:
db "Foo bar",0
FP0:
dq 3.14159265359
FP1:
dq 3.14153
