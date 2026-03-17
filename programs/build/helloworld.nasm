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

global add:function
add:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+24]
	mov rcx, [rbp+32]
	add rbx, rcx
	mov [rbp+16], rbx
	jmp .L0
	.L0:
	leave
	ret

global test:function
test:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+24]
	mov rax, [rbp+32]
	mov rcx, [rbp+40]
	imul rcx
	add rbx, rax
	mov [rbp+16], rbx
	jmp .L0
	.L0:
	leave
	ret

global print_numbers:function
print_numbers:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	lea rbx, [rbp+24]
	mov [rsp+8], rbx
	mov bl, 62
	mov [rsp+7], bl
	mov rbx, [rbp+16]
	.L1:
	test rbx, rbx
	je .L3
	sub rsp, 32
	mov [rsp+24], rbx
	mov rcx, STR0
	mov [rsp+0], rcx
	movzx rcx, BYTE [rsp+39]
	mov [rsp+8], rcx
	mov rcx, [rsp+40]
	mov rsi, [rcx]
	mov [rsp+16], rsi
	call print
	mov rbx, [rsp+24]
	add rsp, 32
	mov rcx, [rsp+8]
	mov rsi, 8
	add rcx, rsi
	mov [rsp+8], rcx
	mov cl, 44
	mov [rsp+7], cl
	.L2:
	dec rbx
	jmp .L1
	.L3:
	sub rsp, 16
	mov bl, 10
	mov [rsp+0], bl
	call print_char
	add rsp, 16
	.L0:
	leave
	ret

global main:function
main:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	sub rsp, 16
	mov rbx, STR1
	mov [rsp+0], rbx
	call println
	add rsp, 16
	sub rsp, 32
	mov rbx, STR2
	mov [rsp+0], rbx
	mov rbx, 5
	mov [rsp+8], rbx
	mov rbx, 30
	mov [rsp+16], rbx
	call println
	add rsp, 32
	sub rsp, 16
	mov rbx, STR3
	mov [rsp+0], rbx
	mov rbx, 20
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 16
	mov rbx, STR4
	mov [rsp+0], rbx
	mov rbx, 20
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 16
	mov rbx, STR5
	mov [rsp+0], rbx
	mov rbx, 20
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 16
	mov rbx, STR6
	mov [rsp+0], rbx
	mov rbx, 20
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 16
	mov rbx, STR7
	mov [rsp+0], rbx
	mov rbx, 20
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 16
	mov rbx, STR8
	mov [rsp+0], rbx
	mov rbx, STR9
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 32
	mov rbx, STR10
	mov [rsp+0], rbx
	mov rbx, 5
	mov [rsp+8], rbx
	mov rbx, STR11
	mov [rsp+16], rbx
	call println
	add rsp, 32
	sub rsp, 16
	mov rbx, STR12
	mov [rsp+0], rbx
	mov rbx, 64
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 32
	mov rbx, STR13
	mov [rsp+0], rbx
	mov rbx, 5
	mov [rsp+8], rbx
	mov rbx, 42
	mov [rsp+16], rbx
	call println
	add rsp, 32
	sub rsp, 16
	mov rbx, STR14
	mov [rsp+0], rbx
	mov rbx, -647
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 16
	mov rbx, STR15
	mov [rsp+0], rbx
	mov rbx, 102532
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 16
	mov rbx, STR16
	mov [rsp+0], rbx
	mov rbx, 25
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 16
	mov rbx, STR17
	mov [rsp+0], rbx
	mov rbx, 48879
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 16
	mov rbx, STR18
	mov [rsp+0], rbx
	mov rbx, 1
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 32
	mov rbx, STR19
	mov [rsp+8], rbx
	mov rbx, 18446744073709551615
	mov [rsp+16], rbx
	call string_to_fixed
	mov ebx, [rsp+0]
	add rsp, 32
	mov [rsp+12], ebx
	sub rsp, 16
	mov rbx, STR20
	mov [rsp+0], rbx
	movsxd rbx, DWORD [rsp+28]
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 16
	mov rbx, STR21
	mov [rsp+0], rbx
	fld QWORD [FP0]
	fchs
	fstp QWORD [rsp+8]
	call println
	add rsp, 16
	sub rsp, 32
	mov rbx, STR22
	mov [rsp+0], rbx
	mov rbx, 6
	mov [rsp+8], rbx
	fld QWORD [FP1]
	fchs
	fstp QWORD [rsp+16]
	call println
	add rsp, 32
	.L0:
	leave
	ret
extern absi:function
extern absf:function
extern random:function
extern randint:function
extern is_alpha:function
extern is_num:function
extern is_alnum:function
extern to_lower:function
extern to_upper:function
extern set_rounding:function
extern sqrt:function
extern pow:function
extern log:function
extern sin:function
extern cos:function
extern tan:function
extern atan2:function
extern round:function
extern floor:function
extern ceil:function
extern trunc:function
extern int_to_fixed:function
extern fraction_to_fixed:function
extern string_to_fixed:function
extern fixed_to_int:function
extern mul_fixed:function
extern div_fixed:function
extern mod_fixed:function
extern memset:function
extern memcpy:function
extern memmove:function
extern strlen:function
extern strfind:function
extern strdfind:function
extern strcpy:function
extern strcmp:function
extern strequal:function
extern flush_stdout:function
extern print_str:function
extern print_char:function
extern print_decimal:function
extern print_udecimal:function
extern print_hex:function
extern print_fixed:function
extern print_float:function
extern print_format:function
extern print:function
extern println:function
extern error:function
extern input:function
extern input_char:function
extern int_to_string:function
extern uint_to_string:function
extern string_to_int:function
extern read:function
extern write:function
extern exit:function


section .data


section .rodata
STR0:
db "%c %i",0
STR1:
db "Hello world!",0
STR2:
db "%A5 chars from start%A30 chars",0
STR3:
db "[%[Aligned left%L]",0
STR4:
db "[%[Aligned right%R]",0
STR5:
db "[%[Centered%C]",0
STR6:
db "%[This is way too long and I want it short%T",0
STR7:
db "%[This is way too long and I want it short%*T",0
STR8:
db "string:            ",34,"%s",34,"",0
STR9:
db "HolyCow!",0
STR10:
db "length string:     ",34,"%*s",34,"",0
STR11:
db "1234567890",0
STR12:
db "character:         '%c'",0
STR13:
db "repeated character: %*c",0
STR14:
db "signed int:         %i",0
STR15:
db "unsigned int:       %u",0
STR16:
db "n length uint:      %04",0
STR17:
db "uint (hex):         %x",0
STR18:
db "bool:               %b",0
STR19:
db "-16.2126",0
STR20:
db "fixed point:        %F",0
STR21:
db "float:              %f",0
STR22:
db "float (n digits):   %*f",0
FP0:
dq 16.2126
FP1:
dq 16.212635
