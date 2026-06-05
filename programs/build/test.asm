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
	mov rcx, [rsp+24]
	inc QWORD [rsp+24]
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
	lea rdi, [rbx]
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

global string.print_debug:function
string.print_debug:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov rbx, STR14
	mov [rsp+0], rbx
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	sub rsp, 16
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	call string.is_heap
	movzx rbx, BYTE [rsp+0]
	add rsp, 16
	mov [rsp+16], rbx
	sub rsp, 16
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	call string.is_shared
	movzx rbx, BYTE [rsp+0]
	add rsp, 16
	mov [rsp+24], rbx
	call println
	add rsp, 32
	.L0:
	leave
	ret

global print_int_vector:function
print_int_vector:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, STR15
	mov [rsp+0], rbx
	call print
	add rsp, 16
	sub rsp, 16
	xor rbx, rbx
	mov [rsp+8], rbx
	.L1:
	mov rbx, [rsp+8]
	mov rsi, [rbp+16]
	mov rcx, [rsi+8]
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L3
	mov rbx, [rsp+8]
	test rbx, rbx
	je .L4
	sub rsp, 16
	mov rbx, STR16
	mov [rsp+0], rbx
	call print
	add rsp, 16
	.L4:
	.L5:
	sub rsp, 32
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	mov rbx, [rsp+40]
	mov [rsp+16], rbx
	call vector.at
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+0], rbx
	sub rsp, 16
	mov rbx, STR17
	mov [rsp+0], rbx
	mov rbx, [rsp+16]
	mov rcx, [rbx]
	mov [rsp+8], rcx
	call print
	add rsp, 16
	.L2:
	mov rbx, [rsp+8]
	inc QWORD [rsp+8]
	jmp .L1
	.L3:
	add rsp, 16
	sub rsp, 16
	mov rbx, STR18
	mov [rsp+0], rbx
	call println
	add rsp, 16
	.L0:
	leave
	ret

global Parent.print:function
Parent.print:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov rbx, STR19
	mov [rsp+0], rbx
	mov rcx, [rbp+16]
	mov rbx, [rcx+0]
	mov [rsp+8], rbx
	mov rcx, [rbp+16]
	mov rbx, [rcx+8]
	mov [rsp+16], rbx
	mov rcx, [rbp+16]
	mov rbx, [rcx+16]
	mov [rsp+24], rbx
	call println
	add rsp, 32
	.L0:
	leave
	ret

global Child.print:function
Child.print:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, [rbp+16]
	add rbx, 0x8
	mov [rsp+0], rbx
	call Parent.print
	add rsp, 16
	sub rsp, 16
	mov rbx, STR20
	mov [rsp+0], rbx
	call println
	add rsp, 16
	.L0:
	leave
	ret

global Child.test:function
Child.test:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, STR21
	mov [rsp+0], rbx
	call println
	add rsp, 16
	.L0:
	leave
	ret

global Child2.test:function
Child2.test:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, STR22
	mov [rsp+0], rbx
	call println
	add rsp, 16
	.L0:
	leave
	ret

global OperatorTest.__add_int:function
OperatorTest.__add_int:
	push rbp
	mov rbp, rsp
	mov rcx, [rbp+24]
	mov rbx, [rcx+0]
	mov rcx, [rbp+32]
	add rbx, rcx
	mov [rbp+16], rbx
	jmp .L0
	.L0:
	leave
	ret

global OperatorTest.__mul_float:function
OperatorTest.__mul_float:
	push rbp
	mov rbp, rsp
	mov rsi, [rbp+24]
	mov rcx, [rsi+0]
	cvtsi2ss xmm0, rcx
	cvtsd2ss xmm1, [rbp+32]
	mulss xmm0, xmm1
	cvtss2sd xmm0, xmm0
	cvttsd2si rbx, xmm0
	mov [rbp+16], rbx
	jmp .L0
	.L0:
	leave
	ret

global OperatorTest.__div_OperatorTest:function
OperatorTest.__div_OperatorTest:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+24]
	mov rax, [rbx+0]
	mov rbx, [rbp+32]
	xor rdx, rdx
	idiv rbx
	mov [rbp+16], rax
	jmp .L0
	.L0:
	leave
	ret

global OperatorTest.__neg:function
OperatorTest.__neg:
	push rbp
	mov rbp, rsp
	mov rcx, [rbp+24]
	mov rbx, [rcx+0]
	neg rbx
	mov [rbp+16], rbx
	jmp .L0
	.L0:
	leave
	ret

global OperatorTest.__and_bool:function
OperatorTest.__and_bool:
	push rbp
	mov rbp, rsp
	mov rcx, [rbp+24]
	mov rbx, [rcx+0]
	xor rcx, rcx
	cmp rbx, rcx
	setne bl
	test bl, bl
	je .L1
	mov bl, [rbp+32]
	.L1:
	mov [rbp+16], bl
	jmp .L0
	.L0:
	leave
	ret

global iostream.__shl_str:function
iostream.__shl_str:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, STR23
	mov [rsp+0], rbx
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call print
	add rsp, 16
	.L0:
	leave
	ret

global iostream.__shl_int:function
iostream.__shl_int:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, STR17
	mov [rsp+0], rbx
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call print
	add rsp, 16
	.L0:
	leave
	ret

global iostream.__shl_bool:function
iostream.__shl_bool:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, STR24
	mov [rsp+0], rbx
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call print
	add rsp, 16
	.L0:
	leave
	ret

global iostream.__shl_char:function
iostream.__shl_char:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, STR25
	mov [rsp+0], rbx
	movzx rbx, BYTE [rbp+32]
	mov [rsp+8], rbx
	call print
	add rsp, 16
	.L0:
	leave
	ret

global iostream.__shl_float:function
iostream.__shl_float:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, STR26
	mov [rsp+0], rbx
	movsd xmm0, [rbp+32]
	movsd [rsp+8], xmm0
	call print
	add rsp, 16
	.L0:
	leave
	ret

global iostream.__shl_string:function
iostream.__shl_string:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	lea rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, QWORD [stdout]
	mov [rsp+8], rbx
	call string.print
	add rsp, 16
	.L0:
	leave
	ret

global main:function
main:
	push rbp
	mov rbp, rsp
	sub rsp, 320
	movsd xmm0, [FP0]
	movsd [rsp+312], xmm0
	movsd xmm0, [FP1]
	movsd [rsp+304], xmm0
	mov rbx, 0x5
	mov [rsp+224], rbx
	mov rbx, 0x2
	mov [rsp+232], rbx
	mov rbx, 0x1
	mov [rsp+240], rbx
	mov rbx, 0x6
	mov [rsp+248], rbx
	mov rbx, 0x8
	mov [rsp+256], rbx
	movsd xmm0, [rsp+304]
	movsd xmm1, [rsp+312]
	movsd xmm2, xmm0
	subsd xmm2, xmm1
	andpd xmm2, [__FABS_MASKd]
	comisd xmm2, [FP_PRECISION]
	setbe bl
	test bl, bl
	je .L1
	sub rsp, 48
	mov rbx, STR27
	mov [rsp+0], rbx
	mov rbx, 0xa
	mov [rsp+8], rbx
	movsd xmm0, [rsp+360]
	movsd [rsp+16], xmm0
	mov rbx, 0xa
	mov [rsp+24], rbx
	movsd xmm0, [rsp+352]
	movsd [rsp+32], xmm0
	movsd xmm0, [FP_PRECISION]
	movsd [rsp+40], xmm0
	call println
	add rsp, 48
	.L1:
	.L2:
	sub rsp, 48
	mov rbx, STR28
	mov [rsp+0], rbx
	mov rbx, 0x3
	mov [rsp+8], rbx
	mov rbx, STR29
	mov [rsp+16], rbx
	mov rbx, STR30
	mov [rsp+24], rbx
	mov rbx, STR31
	mov [rsp+32], rbx
	call frame
	add rsp, 48
	lea rbx, [rsp+192]
	mov rcx, 0x6
	mov [rbx+0], rcx
	xor rcx, rcx
	mov [rbx+8], rcx
	lea r8, [rbx+16]
	mov rcx, STR8
	mov [r8+0], rcx
	mov rcx, STR32
	mov [r8+8], rcx
	sub rsp, 32
	lea rbx, [rsp+0]
	cld
	lea rdi, [rbx]
	lea rsi, [rsp+224]
	mov rcx, 4
	rep movsq
	call test.print
	add rsp, 32
	sub rsp, 32
	lea rbx, [rsp+0]
	sub rsp, 16
	mov [rsp+0], rbx
	mov [rsp+8], rbx
	call test.get
	mov rbx, [rsp+8]
	add rsp, 16
	call test.print
	add rsp, 32
	lea rbx, [rsp+160]
	sub rsp, 32
	mov [rsp+0], rbx
	mov [rsp+24], rbx
	mov rbx, STR8
	mov [rsp+8], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+16], rbx
	call string.from_str
	mov rbx, [rsp+24]
	add rsp, 32
	sub rsp, 16
	lea rbx, [rsp+176]
	mov [rsp+0], rbx
	call string.print_debug
	add rsp, 16
	sub rsp, 16
	lea rbx, [rsp+176]
	mov [rsp+0], rbx
	call string.free
	add rsp, 16
	lea rbx, [rsp+160]
	sub rsp, 32
	mov [rsp+0], rbx
	mov [rsp+24], rbx
	mov rbx, STR33
	mov [rsp+8], rbx
	mov rbx, STR34
	mov [rsp+16], rbx
	call string.format
	mov rbx, [rsp+24]
	add rsp, 32
	sub rsp, 16
	lea rbx, [rsp+176]
	mov [rsp+0], rbx
	call string.print_debug
	add rsp, 16
	lea rbx, [rsp+128]
	sub rsp, 32
	mov [rsp+0], rbx
	mov [rsp+24], rbx
	lea rbx, [rsp+192]
	mov [rsp+8], rbx
	call string.from_shared
	mov rbx, [rsp+24]
	add rsp, 32
	sub rsp, 32
	lea rbx, [rsp+160]
	mov [rsp+0], rbx
	mov rbx, 0x6
	mov [rsp+8], rbx
	xor rbx, rbx
	mov [rsp+16], rbx
	call string.slice
	add rsp, 32
	sub rsp, 16
	lea rbx, [rsp+144]
	mov [rsp+0], rbx
	call string.print_debug
	add rsp, 16
	sub rsp, 16
	lea rbx, [rsp+144]
	mov [rsp+0], rbx
	mov bl, 0x21
	mov [rsp+8], bl
	mov bl, 0x3f
	mov [rsp+9], bl
	call string.replace
	add rsp, 16
	sub rsp, 16
	lea rbx, [rsp+144]
	mov [rsp+0], rbx
	call string.print_debug
	add rsp, 16
	sub rsp, 16
	lea rbx, [rsp+144]
	mov [rsp+0], rbx
	call string.free
	add rsp, 16
	sub rsp, 16
	lea rbx, [rsp+176]
	mov [rsp+0], rbx
	call string.free
	add rsp, 16
	lea rbx, [rsp+88]
	sub rsp, 32
	mov [rsp+0], rbx
	mov [rsp+24], rbx
	mov rbx, 0x8
	mov [rsp+8], rbx
	mov rbx, 0x40
	mov [rsp+16], rbx
	call vector.new
	mov rbx, [rsp+24]
	add rsp, 32
	mov rbx, 0x5
	mov [rsp+120], rbx
	sub rsp, 32
	lea rbx, [rsp+120]
	mov [rsp+8], rbx
	lea rbx, [rsp+152]
	mov [rsp+16], rbx
	call vector.pushback
	add rsp, 32
	mov rbx, 0xa
	mov [rsp+120], rbx
	sub rsp, 32
	lea rbx, [rsp+120]
	mov [rsp+8], rbx
	lea rbx, [rsp+152]
	mov [rsp+16], rbx
	call vector.pushback
	add rsp, 32
	sub rsp, 16
	lea rbx, [rsp+104]
	mov [rsp+0], rbx
	call print_int_vector
	add rsp, 16
	mov rbx, 0xfffffffffffffffb
	mov [rsp+120], rbx
	sub rsp, 32
	lea rbx, [rsp+120]
	mov [rsp+8], rbx
	mov rbx, 0x1
	mov [rsp+16], rbx
	lea rbx, [rsp+152]
	mov [rsp+24], rbx
	call vector.insert
	add rsp, 32
	sub rsp, 16
	lea rbx, [rsp+104]
	mov [rsp+0], rbx
	call print_int_vector
	add rsp, 16
	sub rsp, 16
	lea rbx, [rsp+104]
	mov [rsp+0], rbx
	xor rbx, rbx
	mov [rsp+8], rbx
	call vector.remove
	add rsp, 16
	sub rsp, 16
	lea rbx, [rsp+104]
	mov [rsp+0], rbx
	call print_int_vector
	add rsp, 16
	sub rsp, 16
	lea rbx, [rsp+104]
	mov [rsp+0], rbx
	call vector.free
	add rsp, 16
	lea rbx, [rsp+72]
	lea r8, [rbx+0]
	xor rcx, rcx
	mov [r8], rcx
	mov rcx, 0x2
	mov [r8+8], rcx
	sub rsp, 16
	lea rbx, [rsp+88]
	mov [rsp+0], rbx
	call msg.print
	add rsp, 16
	sub rsp, 16
	lea rbx, [rsp+88]
	mov [rsp+0], rbx
	mov rbx, STR8
	mov [rsp+8], rbx
	call msg.set_text
	add rsp, 16
	sub rsp, 16
	lea rbx, [rsp+88]
	mov [rsp+0], rbx
	call msg.print
	add rsp, 16
	sub rsp, 16
	lea rbx, [rsp+88]
	mov [rsp+0], rbx
	cvtsd2ss xmm0, [FP2]
	movss [rsp+8], xmm0
	call msg.set_number
	add rsp, 16
	sub rsp, 16
	lea rbx, [rsp+88]
	mov [rsp+0], rbx
	call msg.print
	add rsp, 16
	sub rsp, 16
	lea rbx, [rsp+88]
	mov [rsp+0], rbx
	xor bl, bl
	mov [rsp+8], bl
	call msg.set_confirm
	add rsp, 16
	sub rsp, 16
	lea rbx, [rsp+88]
	mov [rsp+0], rbx
	call msg.print
	add rsp, 16
	lea rbx, [rsp+40]
	mov rcx, 0x5
	mov [rbx+8], rcx
	mov rcx, 0x7
	mov [rbx+16], rcx
	mov rcx, 0x1
	mov [rbx+24], rcx
	mov QWORD [rbx], Child__VTABLE
	sub rsp, 16
	lea rbx, [rsp+56]
	mov [rsp+0], rbx
	call Child.print
	add rsp, 16
	sub rsp, 16
	lea rbx, [rsp+56]
	mov [rsp+0], rbx
	mov rbx, [rsp+0]
	mov rbx, [rbx]
	call [rbx+0*8]
	add rsp, 16
	lea rbx, [rsp+8]
	xor rcx, rcx
	mov [rbx+8], rcx
	xor rcx, rcx
	mov [rbx+16], rcx
	xor rcx, rcx
	mov [rbx+24], rcx
	mov QWORD [rbx], Child2__VTABLE
	sub rsp, 16
	lea rbx, [rsp+24]
	mov [rsp+0], rbx
	mov rbx, [rsp+0]
	mov rbx, [rbx]
	call [rbx+0*8]
	add rsp, 16
	lea rbx, [rsp+8]
	mov [rsp+0], rbx
	sub rsp, 16
	mov rbx, [rsp+16]
	mov [rsp+0], rbx
	mov rbx, [rsp+0]
	mov rbx, [rbx]
	call [rbx+0*8]
	add rsp, 16
	sub rsp, 48
	mov rbx, STR35
	mov [rsp+0], rbx
	sub rsp, 16
	lea rbx, [rsp+0]
	mov rcx, 0x2
	mov [rbx+0], rcx
	sub rsp, 32
	lea rbx, [rsp+32]
	mov [rsp+8], rbx
	mov rbx, 0x5
	mov [rsp+16], rbx
	call OperatorTest.__add_int
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rsp+8], rbx
	sub rsp, 16
	lea rbx, [rsp+0]
	mov rcx, 0xa
	mov [rbx+0], rcx
	sub rsp, 32
	lea rbx, [rsp+32]
	mov [rsp+8], rbx
	movsd xmm0, [FP3]
	movsd [rsp+16], xmm0
	call OperatorTest.__mul_float
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rsp+16], rbx
	sub rsp, 16
	lea rbx, [rsp+0]
	mov rcx, 0x10
	mov [rbx+0], rcx
	sub rsp, 32
	lea rbx, [rsp+32]
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	mov rcx, 0x2
	mov [rbx+0], rcx
	call OperatorTest.__div_OperatorTest
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rsp+24], rbx
	sub rsp, 16
	lea rbx, [rsp+0]
	mov rcx, 0x19
	mov [rbx+0], rcx
	sub rsp, 16
	lea rbx, [rsp+16]
	mov [rsp+8], rbx
	call OperatorTest.__neg
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+32], rbx
	sub rsp, 16
	lea rbx, [rsp+0]
	xor rcx, rcx
	mov [rbx+0], rcx
	sub rsp, 32
	lea rbx, [rsp+32]
	mov [rsp+8], rbx
	mov bl, 0x1
	mov [rsp+16], bl
	call OperatorTest.__and_bool
	movzx rbx, BYTE [rsp+0]
	add rsp, 48
	mov [rsp+40], rbx
	call println
	add rsp, 48
	sub rsp, 16
	lea rbx, [rsp+0]
	sub rsp, 16
	lea rcx, [rsp+0]
	sub rsp, 16
	lea rsi, [rsp+0]
	sub rsp, 16
	lea rdi, [rsp+0]
	sub rsp, 16
	lea r8, [rsp+0]
	sub rsp, 16
	lea r9, [rsp+0]
	sub rsp, 16
	lea r10, [rsp+0]
	sub rsp, 80
	mov [rsp+0], r10
	mov [rsp+72], rbx
	mov [rsp+64], rcx
	mov [rsp+56], rsi
	mov [rsp+48], rdi
	mov [rsp+40], r8
	mov [rsp+32], r9
	mov [rsp+24], r10
	lea rbx, [cout]
	mov [rsp+8], rbx
	mov rbx, STR36
	mov [rsp+16], rbx
	call iostream.__shl_str
	mov rbx, [rsp+72]
	mov rcx, [rsp+64]
	mov rsi, [rsp+56]
	mov rdi, [rsp+48]
	mov r8, [rsp+40]
	mov r9, [rsp+32]
	mov r10, [rsp+24]
	add rsp, 80
	sub rsp, 80
	mov [rsp+0], r9
	mov [rsp+72], rbx
	mov [rsp+64], rcx
	mov [rsp+56], rsi
	mov [rsp+48], rdi
	mov [rsp+40], r8
	mov [rsp+32], r9
	lea rbx, [rsp+80]
	mov [rsp+8], rbx
	mov rbx, 0x2a
	mov [rsp+16], rbx
	call iostream.__shl_int
	mov rbx, [rsp+72]
	mov rcx, [rsp+64]
	mov rsi, [rsp+56]
	mov rdi, [rsp+48]
	mov r8, [rsp+40]
	mov r9, [rsp+32]
	add rsp, 96
	sub rsp, 64
	mov [rsp+0], r8
	mov [rsp+56], rbx
	mov [rsp+48], rcx
	mov [rsp+40], rsi
	mov [rsp+32], rdi
	mov [rsp+24], r8
	lea rbx, [rsp+64]
	mov [rsp+8], rbx
	mov rbx, STR37
	mov [rsp+16], rbx
	call iostream.__shl_str
	mov rbx, [rsp+56]
	mov rcx, [rsp+48]
	mov rsi, [rsp+40]
	mov rdi, [rsp+32]
	mov r8, [rsp+24]
	add rsp, 80
	sub rsp, 64
	mov [rsp+0], rdi
	mov [rsp+56], rbx
	mov [rsp+48], rcx
	mov [rsp+40], rsi
	mov [rsp+32], rdi
	lea rbx, [rsp+64]
	mov [rsp+8], rbx
	mov rbx, 0x1
	mov [rsp+16], rbx
	call iostream.__shl_bool
	mov rbx, [rsp+56]
	mov rcx, [rsp+48]
	mov rsi, [rsp+40]
	mov rdi, [rsp+32]
	add rsp, 80
	sub rsp, 48
	mov [rsp+0], rsi
	mov [rsp+40], rbx
	mov [rsp+32], rcx
	mov [rsp+24], rsi
	lea rbx, [rsp+48]
	mov [rsp+8], rbx
	mov rbx, STR37
	mov [rsp+16], rbx
	call iostream.__shl_str
	mov rbx, [rsp+40]
	mov rcx, [rsp+32]
	mov rsi, [rsp+24]
	add rsp, 64
	sub rsp, 48
	mov [rsp+0], rcx
	mov [rsp+40], rbx
	mov [rsp+32], rcx
	lea rbx, [rsp+48]
	mov [rsp+8], rbx
	movsd xmm0, [FP4]
	movsd [rsp+16], xmm0
	call iostream.__shl_float
	mov rbx, [rsp+40]
	mov rcx, [rsp+32]
	add rsp, 64
	sub rsp, 32
	mov [rsp+0], rbx
	mov [rsp+24], rbx
	lea rbx, [rsp+32]
	mov [rsp+8], rbx
	mov bl, 0xa
	mov [rsp+16], bl
	call iostream.__shl_char
	mov rbx, [rsp+24]
	add rsp, 48
	add rsp, 16
	mov rax, .L3
	mov rdx, rbp
	call __exception_push
	mov rax, .L5
	mov rdx, rbp
	call __exception_push
	sub rsp, 16
	xor rcx, rcx
	mov [rsp+8], rcx
	.L7:
	mov rcx, [rsp+8]
	mov rsi, 0x64
	cmp rcx, rsi
	setl cl
	test cl, cl
	je .L9
	mov rcx, [rsp+8]
	mov rsi, 0x43
	cmp rcx, rsi
	sete cl
	test cl, cl
	je .L10
	mov rcx, [rsp+8]
	mov rax, rcx
	xor rdx, rdx
	call __exception_throw
	.L10:
	.L11:
	.L8:
	mov rcx, [rsp+8]
	inc QWORD [rsp+8]
	jmp .L7
	.L9:
	add rsp, 16
	call __exception_pop
	jmp .L6
	.L5:
	sub rsp, 16
	mov [rsp+8], rax
	mov [rsp+0], rdx
	sub rsp, 32
	mov [rsp+24], rbx
	mov rbx, STR38
	mov [rsp+0], rbx
	mov rbx, [rsp+40]
	mov [rsp+8], rbx
	call println
	mov rbx, [rsp+24]
	add rsp, 32
	mov rcx, 0xffffffffffffffff
	mov rsi, STR39
	mov rax, rcx
	mov rdx, rsi
	call __exception_throw
	add rsp, 16
	.L6:
	call __exception_pop
	jmp .L4
	.L3:
	sub rsp, 16
	mov [rsp+8], rax
	mov [rsp+0], rdx
	sub rsp, 32
	mov [rsp+24], rbx
	mov rbx, STR40
	mov [rsp+0], rbx
	mov rbx, [rsp+40]
	mov [rsp+8], rbx
	mov rbx, [rsp+32]
	mov [rsp+16], rbx
	call println
	mov rbx, [rsp+24]
	add rsp, 32
	add rsp, 16
	.L4:
	.L0:
	leave
	ret


extern log:function
extern get_allocated_heap:function
extern sin:function
extern print_char:function
extern trunc:function
extern print:function
extern set_rounding:function
extern pow:function
extern memmove:function
extern is_printable:function
extern get_free_heap:function
extern random:function
extern is_num:function
extern memset:function
extern string_to_double:function
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
extern _align:function
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
extern is_whitespace:function
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
extern File.get_buffering:function
extern File.set_buffer:function
extern File.flush:function
extern string.print:function
extern string.copy:function
extern string.slice:function
extern string.replace:function
extern string.find:function
extern string.dfind:function
extern string.compare:function
extern string.is_equal:function
extern string.str_equal:function
extern string.is_heap:function
extern string.is_shared:function
extern string.free:function
extern vector.reserve:function
extern vector.copy:function
extern vector.in_range:function
extern vector.at:function
extern vector.pushback:function
extern vector.popback:function
extern vector.append_arr:function
extern vector.append:function
extern vector.insert:function
extern vector.remove:function
extern vector.free:function
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
extern vector.empty:function
extern vector.new:function
extern vector.from_arr:function
Child2.print equ Child.print
extern __exception_push:function
extern __exception_pop:function
extern __exception_throw:function


section .data align=16
__FP_TMP: times 4 dq 0
__GP_TMP: times 4 dq 0
extern stdout:data
extern stdin:data
global FP_PRECISION:data
FP_PRECISION:
dq 0.0001000000
global cout:data
cout:
dq 0
static Child__VTABLE:data
Child__VTABLE:
dq Child.test
static Child2__VTABLE:data
Child2__VTABLE:
dq Child2.test
extern File:data
extern fixed:data
extern string:data
extern vector:data
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
db "(",34,"%S",34,", is_heap=%b, is_shared=%b)",0
times 5 db 0
STR15:
db "[",0
dd 0
STR16:
db ", ",0
times 3 db 0
STR17:
db "%i",0
times 3 db 0
STR18:
db "]",0
dd 0
STR19:
db "%i, %i, %i",0
times 3 db 0
STR20:
db "Hello from Child!",0
dd 0
STR21:
db "Test from Child",0
times 6 db 0
STR22:
db "Test from Child2",0
times 5 db 0
STR23:
db "%s",0
times 3 db 0
STR24:
db "%b",0
times 3 db 0
STR25:
db "%c",0
times 3 db 0
STR26:
db "%g",0
times 3 db 0
STR27:
db "%*f ~= %*f ± %f",0
times 5 db 0
STR28:
db "Foo tierlist",0
db 0
STR29:
db "1. Foo",0
times 7 db 0
STR30:
db "2. Bar",0
times 7 db 0
STR31:
db "3. Foo-bar",0
times 3 db 0
STR32:
db "Foo bar",0
times 6 db 0
STR33:
db "Hello %s!",0
dd 0
STR34:
db "friend",0
times 7 db 0
STR35:
db "%i, %i, %i, %i, %b",0
times 3 db 0
STR36:
db "Hello world ",0
db 0
STR37:
db " ",0
dd 0
STR38:
db "Caught exception %i inside try ... catch",0
times 5 db 0
STR39:
db "Shut up kid",0
dw 0
STR40:
db "Exception %i caught : %s",0
times 5 db 0
FP0:
dq 3.1415926536
FP1:
dq 3.1415300000
FP2:
dq 6.6700000000
FP3:
dq 6.7000000000
FP4:
dq 105.9120000000
