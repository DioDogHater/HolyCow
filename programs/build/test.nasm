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
	sub rsp, 16
	fld QWORD [FP0]
	fstp QWORD [rsp+8]
	sub rsp, 32
	mov rbx, STR0
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
	mov rbx, STR1
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
	mov rbx, STR2
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
	mov rbx, STR3
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
FP_PRECISION:
dq 0.001


section .rodata
STR0:
db "round(%f, FP_NEAREST)  = %f",0
STR1:
db "round(%f, FP_DOWN)     = %f",0
STR2:
db "round(%f, FP_UP)       = %f",0
STR3:
db "round(%f, FP_ZERO)     = %f",0
FP0:
dq 3.1415
