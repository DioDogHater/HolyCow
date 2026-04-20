section .text
BITS 64
CPU ALL
default REL
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
	mov rbx, [rsp+72]
	mov rcx, [rsp+56]
	mov rsi, [rbx+rcx*8]
	mov [rsp+8], rsi
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
	.L4:
	.L5:
	inc QWORD [rsp+24]
	mov rcx, [rsp+24]
	.L2:
	dec rbx
	jmp .L1
	.L3:
	add rsp, 16
	mov rbx, [rsp+16]
	add rbx, 0x4
	mov [rsp+16], rbx
	mov rbx, [rbp+16]
	movzx rcx, BYTE [rbx]
	xor rbx, rbx
	cmp rcx, rbx
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
	mov rbx, STR2
	mov [rsp+0], rbx
	mov rbx, [rsp+56]
	mov rcx, [rbx]
	mov [rsp+8], rcx
	mov rbx, [rsp+48]
	mov [rsp+16], rbx
	call println
	mov rbx, [rsp+24]
	add rsp, 32
	mov rcx, [rsp+24]
	add rcx, 0x8
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

global msg.set_text:function
msg.set_text:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	mov rcx, [rbp+24]
	mov [rbx], rcx
	mov rcx, 0x1
	mov [rbx+8], rcx
	.L0:
	leave
	ret

global msg.set_integer:function
msg.set_integer:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	mov rcx, [rbp+24]
	mov [rbx], rcx
	mov rcx, 0x2
	mov [rbx+8], rcx
	.L0:
	leave
	ret

global msg.set_number:function
msg.set_number:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	movss xmm0, [rbp+24]
	movss [rbx], xmm0
	mov rcx, 0x3
	mov [rbx+8], rcx
	.L0:
	leave
	ret

global msg.set_confirm:function
msg.set_confirm:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	mov cl, [rbp+24]
	mov [rbx], cl
	mov rcx, 0x4
	mov [rbx+8], rcx
	.L0:
	leave
	ret

global msg.print:function
msg.print:
	push rbp
	mov rbp, rsp
	mov rcx, [rbp+16]
	lea rcx, [rcx+0]
	mov rbx, [rcx+8]
	mov rcx, 0x1
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L1
	sub rsp, 16
	mov rbx, STR3
	mov [rsp+0], rbx
	mov rcx, [rbp+16]
	lea rcx, [rcx+0]
	mov rbx, [rcx]
	mov [rsp+8], rbx
	call println
	add rsp, 16
	jmp .L2
	.L1:
	mov rcx, [rbp+16]
	lea rcx, [rcx+0]
	mov rbx, [rcx+8]
	mov rcx, 0x2
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L3
	sub rsp, 16
	mov rbx, STR4
	mov [rsp+0], rbx
	mov rcx, [rbp+16]
	lea rcx, [rcx+0]
	mov rbx, [rcx]
	mov [rsp+8], rbx
	call println
	add rsp, 16
	jmp .L2
	.L3:
	mov rcx, [rbp+16]
	lea rcx, [rcx+0]
	mov rbx, [rcx+8]
	mov rcx, 0x3
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L4
	sub rsp, 16
	mov rbx, STR5
	mov [rsp+0], rbx
	mov rbx, [rbp+16]
	lea rbx, [rbx+0]
	cvtss2sd xmm0, [rbx]
	movsd [rsp+8], xmm0
	call println
	add rsp, 16
	jmp .L2
	.L4:
	mov rcx, [rbp+16]
	lea rcx, [rcx+0]
	mov rbx, [rcx+8]
	mov rcx, 0x4
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L5
	sub rsp, 16
	mov rbx, STR6
	mov [rsp+0], rbx
	mov rcx, [rbp+16]
	lea rcx, [rcx+0]
	movzx rbx, BYTE [rcx]
	mov [rsp+8], rbx
	call println
	add rsp, 16
	jmp .L2
	.L5:
	sub rsp, 16
	mov rbx, STR7
	mov [rsp+0], rbx
	call println
	add rsp, 16
	.L2:
	.L0:
	leave
	ret

global test.greet:function
test.greet:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, STR8
	mov [rsp+0], rbx
	call println
	add rsp, 16
	.L0:
	leave
	ret

global test.get:function
test.get:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	mov rcx, 0x3039
	mov [rbx+0], rcx
	mov rbx, [rbp+16]
	mov rcx, 0x100
	mov [rbx+8], rcx
	mov rbx, [rbp+16]
	lea rbx, [rbx+16]
	mov rcx, STR9
	mov [rbx+0], rcx
	mov rcx, STR10
	mov [rbx+8], rcx
	.L0:
	leave
	ret

global test.print_test2:function
test.print_test2:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov rbx, STR11
	mov [rsp+0], rbx
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	call print
	add rsp, 32
	.L0:
	leave
	ret

global test.print:function
test.print:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov rbx, STR12
	mov [rsp+0], rbx
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	call print
	add rsp, 32
	sub rsp, 16
	lea rbx, [rsp+0]
	lea r8, [rbp+16]
	lea r8, [r8+16]
	cld
	mov rdi, rbx
	lea rsi, [r8]
	mov rcx, 2
	rep movsq
	call test.print_test2
	add rsp, 16
	sub rsp, 16
	mov rbx, STR13
	mov [rsp+0], rbx
	call println
	add rsp, 16
	.L0:
	leave
	ret

global main:function
main:
	push rbp
	mov rbp, rsp
	sub rsp, 96
	movsd xmm0, [FP0]
	movsd [rsp+88], xmm0
	movsd xmm0, [FP1]
	movsd [rsp+80], xmm0
	movsd xmm0, [rsp+80]
	movsd xmm1, [rsp+88]
	movsd xmm2, xmm0
	subsd xmm2, xmm1
	andpd xmm2, [__FABS_MASKd]
	comisd xmm2, [FP_PRECISION]
	setbe bl
	test bl, bl
	je .L1
	sub rsp, 48
	mov rbx, STR14
	mov [rsp+0], rbx
	mov rbx, 0xa
	mov [rsp+8], rbx
	movsd xmm0, [rsp+136]
	movsd [rsp+16], xmm0
	mov rbx, 0xa
	mov [rsp+24], rbx
	movsd xmm0, [rsp+128]
	movsd [rsp+32], xmm0
	movsd xmm0, [FP_PRECISION]
	movsd [rsp+40], xmm0
	call println
	add rsp, 48
	.L1:
	.L2:
	sub rsp, 48
	mov rbx, STR15
	mov [rsp+0], rbx
	mov rbx, 0x3
	mov [rsp+8], rbx
	mov rbx, STR16
	mov [rsp+16], rbx
	mov rbx, STR17
	mov [rsp+24], rbx
	mov rbx, STR18
	mov [rsp+32], rbx
	call frame
	add rsp, 48
	lea rbx, [rsp+48]
	mov rcx, 0x6
	mov [rbx+0], rcx
	xor rcx, rcx
	mov [rbx+8], rcx
	lea r8, [rbx+16]
	mov rcx, STR8
	mov [r8+0], rcx
	mov rcx, STR19
	mov [r8+8], rcx
	sub rsp, 32
	lea rbx, [rsp+0]
	cld
	mov rdi, rbx
	lea rsi, [rsp+80]
	mov rcx, 4
	rep movsq
	call test.print
	add rsp, 32
	sub rsp, 32
	lea rbx, [rsp+0]
	sub rsp, 16
	mov [rsp+0], rbx
	call test.get
	add rsp, 16
	call test.print
	add rsp, 32
	lea rbx, [rsp+16]
	sub rsp, 32
	mov [rsp+0], rbx
	mov rbx, STR8
	mov [rsp+8], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+16], rbx
	call string.from_str
	add rsp, 32
	sub rsp, 16
	mov rbx, STR20
	mov [rsp+0], rbx
	lea rbx, [rsp+32]
	mov [rsp+8], rbx
	call println
	add rsp, 16
	lea rbx, [rsp+0]
	lea r8, [rbx+0]
	xor rcx, rcx
	mov [r8], rcx
	mov rcx, 0x2
	mov [r8+8], rcx
	sub rsp, 16
	lea rbx, [rsp+16]
	mov [rsp+0], rbx
	call msg.print
	add rsp, 16
	sub rsp, 16
	lea rbx, [rsp+16]
	mov [rsp+0], rbx
	mov rbx, STR8
	mov [rsp+8], rbx
	call msg.set_text
	add rsp, 16
	sub rsp, 16
	lea rbx, [rsp+16]
	mov [rsp+0], rbx
	call msg.print
	add rsp, 16
	sub rsp, 16
	lea rbx, [rsp+16]
	mov [rsp+0], rbx
	cvtsd2ss xmm0, [FP2]
	movss [rsp+8], xmm0
	call msg.set_number
	add rsp, 16
	sub rsp, 16
	lea rbx, [rsp+16]
	mov [rsp+0], rbx
	call msg.print
	add rsp, 16
	sub rsp, 16
	lea rbx, [rsp+16]
	mov [rsp+0], rbx
	xor bl, bl
	mov [rsp+8], bl
	call msg.set_confirm
	add rsp, 16
	sub rsp, 16
	lea rbx, [rsp+16]
	mov [rsp+0], rbx
	call msg.print
	add rsp, 16
	.L0:
	leave
	ret


extern log:function
extern sin:function
extern print_char:function
extern trunc:function
extern print:function
extern set_rounding:function
extern pow:function
extern memmove:function
extern random:function
extern is_num:function
extern memset:function
extern malloc:function
extern exit:function
extern read:function
extern tan:function
extern int_to_string:function
extern string_to_int:function
extern write:function
extern print_format:function
extern close:function
extern strcmp:function
extern strfind:function
extern absf:function
extern print_fixed:function
extern absi:function
extern floor:function
extern open:function
extern uint_to_string:function
extern strdfind:function
extern free:function
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
extern realloc:function
extern cos:function
extern strcpy:function
extern print_double:function
extern println:function
extern round:function
extern sqrt:function
extern error:function
extern randint:function
extern print_hex:function
extern atan2:function
extern is_alnum:function
extern File.write:function
extern File.read:function
extern File.print:function
extern File.println:function
extern File.set_buffering:function
extern File.set_buffer:function
extern File.flush:function
extern string.share:function
extern string.print:function
extern string.compare:function
extern string.is_equal:function
extern string.str_equals:function
extern string.is_heap:function
extern string.is_shared:function
extern string.free:function
extern File.open:function
extern File.close:function
extern fixed.from_int:function
extern fixed.from_float:function
extern fixed.from_string:function
extern fixed.to_int:function
extern fixed.to_float:function
extern fixed.mul:function
extern fixed.div:function
extern fixed.mod:function
extern string.from_str:function
extern string.from_shared:function
extern string.new:function
extern string.format:function


section .data align=16
__FP_TMP: times 4 dq 0
__GP_TMP: times 4 dq 0
extern stdout:data
extern stdin:data
global FP_PRECISION:data
FP_PRECISION:
dq 0.0001000000
extern File:data
extern fixed:data
extern string:data
extern test:data


section .rodata align=16
__FABS_MASKd: dq 0x7FFFFFFFFFFFFFFF, 0
__FABS_MASKs: dd 0x7FFFFFFF, 0, 0, 0
__FNEG_MASKd: dq 0x8000000000000000, 0
__FNEG_MASKs: dd 0x80000000, 0, 0, 0
STR0:
db "+%*c+",0
STR1:
db "+%[ %s %*C+",0
dw 0
STR2:
db "|%[ %s%L|",0
dd 0
STR3:
db "msg{",34,"%s",34,"}",0
dd 0
STR4:
db "msg{%i}",0
times 6 db 0
STR5:
db "msg{%f}",0
times 6 db 0
STR6:
db "msg{%b}",0
times 6 db 0
STR7:
db "msg{INVALID}",0
db 0
STR8:
db "Hello world!",0
db 0
STR9:
db "Foo",0
dw 0
STR10:
db "Bar",0
dw 0
STR11:
db "test2{",34,"%s",34,", ",34,"%s",34,"}",0
dd 0
STR12:
db "test{%u, %u, ",0
STR13:
db "}",0
dd 0
STR14:
db "%*f ~= %*f ± %f",0
times 5 db 0
STR15:
db "Foo tierlist",0
db 0
STR16:
db "1. Foo",0
times 7 db 0
STR17:
db "2. Bar",0
times 7 db 0
STR18:
db "3. Foo-bar",0
times 3 db 0
STR19:
db "Foo bar",0
times 6 db 0
STR20:
db "%S",0
times 3 db 0
FP0:
dq 3.1415926536
FP1:
dq 3.1415300000
FP2:
dq 6.6700000000
