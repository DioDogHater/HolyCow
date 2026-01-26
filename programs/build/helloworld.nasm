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
	mov bl, '>'
	mov [rsp+7], bl
	mov rbx, [rbp+16]
	.L1:
	test rbx, rbx
	je .L3
	sub rsp, 32
	mov [rsp+24], rbx
	mov rcx, STR0
	mov [rsp+0], rcx
	movsx rcx, BYTE [rsp+39]
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
	mov cl, ','
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
	sub rsp, 16
	mov rbx, STR2
	mov [rsp+0], rbx
	mov rbx, STR3
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 32
	mov rbx, STR4
	mov [rsp+0], rbx
	mov rbx, 5
	mov [rsp+8], rbx
	mov rbx, STR5
	mov [rsp+16], rbx
	call println
	add rsp, 32
	sub rsp, 16
	mov rbx, STR6
	mov [rsp+0], rbx
	mov rbx, '@'
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 32
	mov rbx, STR7
	mov [rsp+0], rbx
	mov rbx, 5
	mov [rsp+8], rbx
	mov rbx, '*'
	mov [rsp+16], rbx
	call println
	add rsp, 32
	sub rsp, 16
	mov rbx, STR8
	mov [rsp+0], rbx
	mov rbx, 647
	neg rbx
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 16
	mov rbx, STR9
	mov [rsp+0], rbx
	mov rbx, 102532
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 16
	mov rbx, STR10
	mov [rsp+0], rbx
	mov rbx, 0xBEEF
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 16
	mov rbx, STR11
	mov [rsp+0], rbx
	mov rbx, 1
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 32
	mov rbx, STR12
	mov [rsp+8], rbx
	mov rbx, 1
	neg rbx
	mov [rsp+16], rbx
	call string_to_fixed
	mov ebx, [rsp+0]
	add rsp, 32
	mov [rsp+12], ebx
	sub rsp, 16
	mov rbx, STR13
	mov [rsp+0], rbx
	movsx rbx, DWORD [rsp+28]
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 16
	mov rbx, STR14
	mov [rsp+0], rbx
	fld QWORD [FP0]
	fchs
	fstp QWORD [rsp+8]
	call println
	add rsp, 16
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
extern strlen
extern strfind
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
db "%c %i",0
STR1:
db "Hello world!",0
STR2:
db "string:            ",34,"%s",34,"",0
STR3:
db "HolyCow!",0
STR4:
db "length string:     ",34,"%*s",34,"",0
STR5:
db "1234567890",0
STR6:
db "character:         '%c'",0
STR7:
db "repeated character: %*c",0
STR8:
db "signed int:         %i",0
STR9:
db "unsigned int:       %u",0
STR10:
db "uint (hex):         %x",0
STR11:
db "bool                %b",0
STR12:
db "-16.2126",0
STR13:
db "fixed point number: %F",0
STR14:
db "float number:       %f",0
FP0:
dq 16.2126
