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

global fibo_recursive:function
fibo_recursive:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+24]
	mov [rbp+16], rbx
	mov rbx, [rbp+24]
	mov rcx, 0x1
	cmp rbx, rcx
	setg bl
	test bl, bl
	je .L1
	sub rsp, 16
	mov rbx, [rbp+24]
	mov rcx, 0x1
	sub rbx, rcx
	mov [rsp+8], rbx
	call fibo_recursive
	mov rbx, [rsp+0]
	add rsp, 16
	sub rsp, 32
	mov [rsp+24], rbx
	mov rcx, [rbp+24]
	mov rsi, 0x2
	sub rcx, rsi
	mov [rsp+8], rcx
	call fibo_recursive
	mov rbx, [rsp+24]
	mov rcx, [rsp+0]
	add rsp, 32
	add rbx, rcx
	mov [rbp+16], rbx
	jmp .L2
	.L1:
	.L2:
	.L0:
	leave
	ret

global fibo_recursive_cached:function
fibo_recursive_cached:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+24]
	mov rcx, 0x1
	cmp rbx, rcx
	setle bl
	test bl, bl
	je .L1
	mov rbx, [rbp+24]
	mov [rbp+16], rbx
	jmp .L2
	.L1:
	mov rbx, [rbp+24]
	mov rcx, 0x2
	sub rbx, rcx
	mov rcx, QWORD [fibo+0]
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L3
	lea rbx, [fibo+8]
	mov rcx, [rbp+24]
	mov rsi, 0x2
	sub rcx, rsi
	mov rsi, [rbx+rcx*8]
	mov [rbp+16], rsi
	jmp .L2
	.L3:
	sub rsp, 16
	mov rbx, [rbp+24]
	mov rcx, 0x1
	sub rbx, rcx
	mov [rsp+8], rbx
	call fibo_recursive_cached
	mov rbx, [rsp+0]
	add rsp, 16
	sub rsp, 32
	mov [rsp+24], rbx
	mov rcx, [rbp+24]
	mov rsi, 0x2
	sub rcx, rsi
	mov [rsp+8], rcx
	call fibo_recursive_cached
	mov rbx, [rsp+24]
	mov rcx, [rsp+0]
	add rsp, 32
	add rbx, rcx
	mov [rbp+16], rbx
	mov rbx, QWORD [fibo+0]
	mov rcx, 0x100
	cmp rbx, rcx
	setne bl
	test bl, bl
	je .L4
	lea rbx, [fibo+8]
	mov rcx, QWORD [fibo+0]
	inc rcx
	mov [fibo+0], rcx
	dec rcx
	mov rsi, [rbp+16]
	mov [rbx+rcx*8], rsi
	jmp .L5
	.L4:
	.L5:
	.L2:
	.L0:
	leave
	ret

global fibo_iterative:function
fibo_iterative:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, [rbp+24]
	mov rcx, 0x1
	cmp rbx, rcx
	setle bl
	test bl, bl
	je .L1
	mov rbx, [rbp+24]
	mov [rbp+16], rbx
	jmp .L0
	jmp .L2
	.L1:
	.L2:
	xor rbx, rbx
	mov [rsp+8], rbx
	mov rbx, 0x1
	mov [rsp+0], rbx
	mov rbx, [rbp+24]
	mov rcx, 0x1
	sub rbx, rcx
	.L3:
	test rbx, rbx
	je .L5
	mov rcx, [rsp+8]
	mov rsi, [rsp+0]
	add rcx, rsi
	mov [rbp+16], rcx
	mov rcx, [rsp+0]
	mov [rsp+8], rcx
	mov rcx, [rbp+16]
	mov [rsp+0], rcx
	.L4:
	dec rbx
	jmp .L3
	.L5:
	.L0:
	leave
	ret

global main:function
main:
	push rbp
	mov rbp, rsp
	sub rsp, 64
	sub rsp, 16
	mov rbx, STR0
	mov [rsp+0], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+8], rbx
	call print_str
	add rsp, 16
	sub rsp, 32
	lea rbx, [rsp+64]
	mov [rsp+8], rbx
	mov rbx, 0x20
	mov [rsp+16], rbx
	call input
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+24], rbx
	sub rsp, 32
	lea rbx, [rsp+64]
	mov [rsp+8], rbx
	mov rbx, [rsp+56]
	mov [rsp+16], rbx
	call string_to_int
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+16], rbx
	mov rbx, [rsp+16]
	xor rcx, rcx
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L1
	sub rsp, 16
	mov rbx, STR1
	mov [rsp+0], rbx
	call error
	add rsp, 16
	jmp .L2
	.L1:
	.L2:
	sub rsp, 16
	mov rbx, [rsp+32]
	mov [rsp+8], rbx
	call fibo_recursive_cached
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rsp+8], rbx
	sub rsp, 32
	mov rbx, STR2
	mov [rsp+0], rbx
	mov rbx, [rsp+48]
	mov [rsp+8], rbx
	mov rbx, [rsp+40]
	mov [rsp+16], rbx
	call println
	add rsp, 32
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
extern tan:function
extern int_to_string:function
extern string_to_int:function
extern print_format:function
extern strcmp:function
extern strfind:function
extern absf:function
extern print_fixed:function
extern absi:function
extern floor:function
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
extern File.set_buffering:function
extern File.set_buffer:function
extern File.flush:function
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
extern string.new:function


section .data
static __FP_TMP:data
__FP_TMP:
dq 0
static __GP_TMP:data
__GP_TMP:
times 64 db 0
extern stdout:data
extern stdin:data
extern File:data
extern fixed:data
extern string:data
global fibo:data
fibo:
dq 0
times 2048 db 0


section .rodata
STR0:
db "This program calculates the nth fibonacci number.",10,"Please enter n: ",0
STR1:
db "n must be a positive number or 0.",0
STR2:
db "The %ith fibonacci number is %u",0
