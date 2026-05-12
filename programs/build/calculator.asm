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

global Expr.eval:function
Expr.eval:
	push rbp
	mov rbp, rsp
	leave
	ret

global Expr.free:function
Expr.free:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, [rbp+16]
	mov [rsp+0], rbx
	call free
	add rsp, 16
	.L0:
	leave
	ret

global Value.eval:function
Value.eval:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+24]
	movsd xmm0, [rbx+8]
	movsd [rbp+16], xmm0
	.L0:
	leave
	ret

global Neg.eval:function
Neg.eval:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rcx, [rbp+24]
	mov rbx, [rcx+8]
	mov [rsp+8], rbx
	mov rbx, [rsp+8]
	mov rbx, [rbx]
	call [rbx+0*8]
	movsd xmm0, [rsp+0]
	add rsp, 16
	xorpd xmm0, [__FNEG_MASKd]
	movsd [rbp+16], xmm0
	.L0:
	leave
	ret

global Neg.free:function
Neg.free:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rcx, [rbp+16]
	mov rbx, [rcx+8]
	mov [rsp+0], rbx
	call free
	add rsp, 16
	sub rsp, 16
	mov rbx, [rbp+16]
	mov [rsp+0], rbx
	call free
	add rsp, 16
	.L0:
	leave
	ret

global BinOp.compute:function
BinOp.compute:
	push rbp
	mov rbp, rsp
	leave
	ret

global BinOp.eval:function
BinOp.eval:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	sub rsp, 16
	mov rcx, [rbp+24]
	mov rbx, [rcx+8]
	mov [rsp+8], rbx
	mov rbx, [rsp+8]
	mov rbx, [rbx]
	call [rbx+0*8]
	movsd xmm0, [rsp+0]
	add rsp, 16
	movsd [rsp+16], xmm0
	sub rsp, 16
	mov rcx, [rbp+24]
	mov rbx, [rcx+16]
	mov [rsp+8], rbx
	mov rbx, [rsp+8]
	mov rbx, [rbx]
	call [rbx+0*8]
	movsd xmm0, [rsp+0]
	add rsp, 16
	movsd [rsp+24], xmm0
	mov rbx, [rsp+8]
	mov rbx, [rbx]
	call [rbx+2*8]
	movsd xmm0, [rsp+0]
	add rsp, 32
	movsd [rbp+16], xmm0
	.L0:
	leave
	ret

global BinOp.free:function
BinOp.free:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rcx, [rbp+16]
	mov rbx, [rcx+8]
	mov [rsp+0], rbx
	call free
	add rsp, 16
	sub rsp, 16
	mov rcx, [rbp+16]
	mov rbx, [rcx+16]
	mov [rsp+0], rbx
	call free
	add rsp, 16
	sub rsp, 16
	mov rbx, [rbp+16]
	mov [rsp+0], rbx
	call free
	add rsp, 16
	.L0:
	leave
	ret

global Add.compute:function
Add.compute:
	push rbp
	mov rbp, rsp
	movsd xmm0, [rbp+32]
	movsd xmm1, [rbp+40]
	addsd xmm0, xmm1
	movsd [rbp+16], xmm0
	.L0:
	leave
	ret

global Sub.compute:function
Sub.compute:
	push rbp
	mov rbp, rsp
	movsd xmm0, [rbp+32]
	movsd xmm1, [rbp+40]
	subsd xmm0, xmm1
	movsd [rbp+16], xmm0
	.L0:
	leave
	ret

global Mul.compute:function
Mul.compute:
	push rbp
	mov rbp, rsp
	movsd xmm0, [rbp+32]
	movsd xmm1, [rbp+40]
	mulsd xmm0, xmm1
	movsd [rbp+16], xmm0
	.L0:
	leave
	ret

global Div.compute:function
Div.compute:
	push rbp
	mov rbp, rsp
	movsd xmm0, [rbp+32]
	movsd xmm1, [rbp+40]
	divsd xmm0, xmm1
	movsd [rbp+16], xmm0
	.L0:
	leave
	ret

global Mod.compute:function
Mod.compute:
	push rbp
	mov rbp, rsp
	movsd xmm0, [rbp+32]
	movsd xmm1, [rbp+40]
	movsd xmm2, xmm0
	divsd xmm2, xmm1
	roundsd xmm2, xmm2, 3
	mulsd xmm2, xmm1
	subsd xmm0, xmm2
	movsd [rbp+16], xmm0
	.L0:
	leave
	ret

global Pow.compute:function
Pow.compute:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	movsd xmm0, [rbp+32]
	movsd [rsp+8], xmm0
	movsd xmm0, [rbp+40]
	movsd [rsp+16], xmm0
	call pow
	movsd xmm0, [rsp+0]
	add rsp, 32
	movsd [rbp+16], xmm0
	.L0:
	leave
	ret

global tokenize:function
tokenize:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	lea rbx, [rsp+0]
	sub rsp, 32
	mov [rsp+0], rbx
	mov rbx, 0x10
	mov [rsp+8], rbx
	mov rbx, 0x40
	mov [rsp+16], rbx
	call vector.new
	add rsp, 32
	sub rsp, 16
	.L1:
	mov rbx, [rbp+24]
	mov cl, [rbx]
	test cl, cl
	je .L3
	sub rsp, 16
	mov rbx, [rbp+24]
	mov cl, [rbx]
	mov [rsp+1], cl
	call is_whitespace
	mov bl, [rsp+0]
	add rsp, 16
	test bl, bl
	je .L4
	jmp .L2
	jmp .L5
	.L4:
	sub rsp, 16
	mov rbx, [rbp+24]
	mov cl, [rbx]
	mov [rsp+1], cl
	call is_num
	mov bl, [rsp+0]
	add rsp, 16
	test bl, bl
	je .L6
	sub rsp, 16
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	.L7:
	sub rsp, 16
	mov rbx, [rbp+24]
	mov cl, [rbx]
	mov [rsp+1], cl
	call is_num
	mov bl, [rsp+0]
	add rsp, 16
	test bl, bl
	je .L9
	.L8:
	mov rbx, [rbp+24]
	inc QWORD [rbp+24]
	jmp .L7
	.L9:
	mov rbx, [rbp+24]
	mov cl, [rbx]
	mov bl, 0x2e
	cmp cl, bl
	sete bl
	test bl, bl
	je .L10
	mov rbx, [rbp+24]
	inc QWORD [rbp+24]
	.L12:
	sub rsp, 16
	mov rbx, [rbp+24]
	mov cl, [rbx]
	mov [rsp+1], cl
	call is_num
	mov bl, [rsp+0]
	add rsp, 16
	test bl, bl
	je .L14
	.L13:
	mov rbx, [rbp+24]
	inc QWORD [rbp+24]
	jmp .L12
	.L14:
	.L10:
	.L11:
	lea rbx, [rsp+16]
	mov rcx, [rsp+8]
	mov [rbx], rcx
	mov rcx, 0x1
	mov [rbx+8], rcx
	mov rbx, [rbp+24]
	dec QWORD [rbp+24]
	add rsp, 16
	jmp .L5
	.L6:
	lea rbx, [rsp+0]
	mov rcx, [rbp+24]
	mov sil, [rcx]
	mov [rbx], sil
	mov rcx, 0x2
	mov [rbx+8], rcx
	.L5:
	sub rsp, 32
	lea rbx, [rsp+48]
	mov [rsp+8], rbx
	lea rbx, [rsp+32]
	mov [rsp+16], rbx
	call vector.pushback
	add rsp, 32
	.L2:
	mov rbx, [rbp+24]
	inc QWORD [rbp+24]
	jmp .L1
	.L3:
	add rsp, 16
	mov rbx, [rbp+16]
	cld
	lea rdi, [rbx]
	lea rsi, [rsp+0]
	mov rcx, 4
	rep movsq
	.L0:
	leave
	ret

global get_precedence:function
get_precedence:
	push rbp
	mov rbp, rsp
	mov rbx, 0xffffffffffffffff
	mov [rbp+16], rbx
	mov bl, [rbp+24]
	mov cl, 0x2d
	cmp bl, cl
	sete bl
	test bl, bl
	jne .L3
	mov cl, [rbp+24]
	mov sil, 0x2b
	cmp cl, sil
	sete bl
	.L3:
	test bl, bl
	je .L1
	mov rbx, 0x1
	mov [rbp+16], rbx
	jmp .L2
	.L1:
	mov bl, [rbp+24]
	mov cl, 0x2a
	cmp bl, cl
	sete bl
	test bl, bl
	jne .L6
	mov cl, [rbp+24]
	mov sil, 0x2f
	cmp cl, sil
	sete bl
	.L6:
	test bl, bl
	jne .L5
	mov cl, [rbp+24]
	mov sil, 0x25
	cmp cl, sil
	sete bl
	.L5:
	test bl, bl
	je .L4
	mov rbx, 0x2
	mov [rbp+16], rbx
	jmp .L2
	.L4:
	mov bl, [rbp+24]
	mov cl, 0x5e
	cmp bl, cl
	sete bl
	test bl, bl
	je .L7
	mov rbx, 0x3
	mov [rbp+16], rbx
	jmp .L2
	.L7:
	.L2:
	.L0:
	leave
	ret

global parse_term:function
parse_term:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, [rbp+32]
	mov rcx, [rbx]
	mov rsi, [rbp+24]
	mov rbx, [rsi+8]
	cmp rcx, rbx
	setge bl
	test bl, bl
	je .L1
	sub rsp, 16
	mov rbx, STR0
	mov [rsp+0], rbx
	call error
	add rsp, 16
	.L1:
	.L2:
	sub rsp, 32
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rcx, [rbp+32]
	mov rbx, [rcx]
	inc QWORD [rcx]
	mov [rsp+16], rbx
	call vector.at
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+8], rbx
	mov rcx, [rsp+8]
	mov rbx, [rcx+8]
	mov rcx, 0x1
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L3
	sub rsp, 16
	sub rsp, 32
	mov rcx, [rsp+56]
	mov rbx, [rcx]
	mov [rsp+8], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+16], rbx
	call string_to_double
	movsd xmm0, [rsp+0]
	add rsp, 32
	movsd [rsp+8], xmm0
	sub rsp, 16
	mov rbx, 0x10
	mov [rsp+8], rbx
	call malloc
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rsp+0], rbx
	mov rbx, [rsp+0]
	movsd xmm0, [rsp+8]
	movsd [rbx+8], xmm0
	mov QWORD [rbx], Value__VTABLE
	mov rbx, [rsp+0]
	mov [rbp+16], rbx
	add rsp, 16
	jmp .L4
	.L3:
	mov rcx, [rsp+8]
	mov bl, [rcx]
	mov cl, 0x2d
	cmp bl, cl
	sete bl
	test bl, bl
	je .L5
	sub rsp, 16
	sub rsp, 16
	mov rbx, 0x10
	mov [rsp+8], rbx
	call malloc
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rsp+8], rbx
	mov rbx, [rsp+8]
	sub rsp, 48
	mov [rsp+40], rbx
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	mov rbx, 0x3
	mov [rsp+24], rbx
	call parse_expression
	mov rbx, [rsp+40]
	mov rcx, [rsp+0]
	add rsp, 48
	mov [rbx+8], rcx
	mov QWORD [rbx], Neg__VTABLE
	mov rbx, [rsp+8]
	mov [rbp+16], rbx
	add rsp, 16
	jmp .L4
	.L5:
	mov rcx, [rsp+8]
	mov bl, [rcx]
	mov cl, 0x28
	cmp bl, cl
	sete bl
	test bl, bl
	je .L6
	sub rsp, 16
	sub rsp, 32
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	xor rbx, rbx
	mov [rsp+24], rbx
	call parse_expression
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rbp+16], rbx
	mov rbx, [rbp+32]
	mov rcx, [rbx]
	mov rsi, [rbp+24]
	mov rbx, [rsi+8]
	cmp rcx, rbx
	setge bl
	test bl, bl
	je .L7
	sub rsp, 16
	mov rbx, STR1
	mov [rsp+0], rbx
	call error
	add rsp, 16
	.L7:
	.L8:
	sub rsp, 32
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rcx, [rbp+32]
	mov rbx, [rcx]
	inc QWORD [rcx]
	mov [rsp+16], rbx
	call vector.at
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+8], rbx
	mov rcx, [rsp+8]
	mov rbx, [rcx+8]
	mov rcx, 0x2
	cmp rbx, rcx
	setne bl
	test bl, bl
	jne .L11
	mov rsi, [rsp+8]
	mov cl, [rsi]
	mov sil, 0x29
	cmp cl, sil
	setne bl
	.L11:
	test bl, bl
	je .L9
	sub rsp, 16
	mov rbx, STR2
	mov [rsp+0], rbx
	call error
	add rsp, 16
	.L9:
	.L10:
	add rsp, 16
	jmp .L4
	.L6:
	sub rsp, 16
	mov rbx, STR3
	mov [rsp+0], rbx
	call error
	add rsp, 16
	.L4:
	.L0:
	leave
	ret

global parse_expression:function
parse_expression:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	call parse_term
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rbp+16], rbx
	sub rsp, 32
	.L1:
	mov rbx, [rbp+32]
	mov rcx, [rbx]
	mov rsi, [rbp+24]
	mov rbx, [rsi+8]
	cmp rcx, rbx
	setb bl
	test bl, bl
	je .L2
	sub rsp, 32
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov rcx, [rbx]
	mov [rsp+16], rcx
	call vector.at
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+24], rbx
	mov rcx, [rsp+24]
	mov rbx, [rcx+8]
	mov rcx, 0x1
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L3
	sub rsp, 16
	mov rbx, STR4
	mov [rsp+0], rbx
	call error
	add rsp, 16
	.L3:
	.L4:
	mov rcx, [rsp+24]
	mov rbx, [rcx+8]
	mov rcx, 0x2
	cmp rbx, rcx
	setne bl
	test bl, bl
	je .L5
	jmp .L2
	.L5:
	.L6:
	sub rsp, 16
	mov rcx, [rsp+40]
	mov bl, [rcx]
	mov [rsp+8], bl
	call get_precedence
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rsp+16], rbx
	mov rbx, [rsp+16]
	mov rcx, 0xffffffffffffffff
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L9
	mov rsi, [rsp+24]
	mov cl, [rsi]
	mov sil, 0x29
	cmp cl, sil
	setne bl
	.L9:
	test bl, bl
	je .L7
	sub rsp, 16
	mov rbx, STR5
	mov [rsp+0], rbx
	mov rcx, [rsp+40]
	movzx rbx, BYTE [rcx]
	mov [rsp+8], rbx
	call error
	add rsp, 16
	.L7:
	.L8:
	mov rbx, [rsp+16]
	mov rcx, [rbp+40]
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L10
	jmp .L2
	.L10:
	.L11:
	mov rcx, [rbp+32]
	mov rbx, [rcx]
	inc QWORD [rcx]
	sub rsp, 32
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	mov rbx, [rsp+48]
	inc rbx
	mov [rsp+24], rbx
	call parse_expression
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+8], rbx
	mov rcx, [rsp+24]
	mov bl, [rcx]
	mov cl, 0x2b
	cmp bl, cl
	sete bl
	test bl, bl
	je .L12
	sub rsp, 16
	sub rsp, 16
	mov rbx, 0x18
	mov [rsp+8], rbx
	call malloc
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rsp+8], rbx
	mov rbx, [rsp+8]
	mov rcx, [rbp+16]
	mov [rbx+8], rcx
	mov rcx, [rsp+24]
	mov [rbx+16], rcx
	mov QWORD [rbx], Add__VTABLE
	mov rbx, [rsp+8]
	mov [rbp+16], rbx
	add rsp, 16
	jmp .L13
	.L12:
	mov rcx, [rsp+24]
	mov bl, [rcx]
	mov cl, 0x2d
	cmp bl, cl
	sete bl
	test bl, bl
	je .L14
	sub rsp, 16
	sub rsp, 16
	mov rbx, 0x18
	mov [rsp+8], rbx
	call malloc
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rsp+8], rbx
	mov rbx, [rsp+8]
	mov rcx, [rbp+16]
	mov [rbx+8], rcx
	mov rcx, [rsp+24]
	mov [rbx+16], rcx
	mov QWORD [rbx], Sub__VTABLE
	mov rbx, [rsp+8]
	mov [rbp+16], rbx
	add rsp, 16
	jmp .L13
	.L14:
	mov rcx, [rsp+24]
	mov bl, [rcx]
	mov cl, 0x2a
	cmp bl, cl
	sete bl
	test bl, bl
	jne .L16
	mov rsi, [rsp+24]
	mov cl, [rsi]
	mov sil, 0x28
	cmp cl, sil
	sete bl
	.L16:
	test bl, bl
	je .L15
	sub rsp, 16
	sub rsp, 16
	mov rbx, 0x18
	mov [rsp+8], rbx
	call malloc
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rsp+8], rbx
	mov rbx, [rsp+8]
	mov rcx, [rbp+16]
	mov [rbx+8], rcx
	mov rcx, [rsp+24]
	mov [rbx+16], rcx
	mov QWORD [rbx], Mul__VTABLE
	mov rbx, [rsp+8]
	mov [rbp+16], rbx
	add rsp, 16
	jmp .L13
	.L15:
	mov rcx, [rsp+24]
	mov bl, [rcx]
	mov cl, 0x2f
	cmp bl, cl
	sete bl
	test bl, bl
	je .L17
	sub rsp, 16
	sub rsp, 16
	mov rbx, 0x18
	mov [rsp+8], rbx
	call malloc
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rsp+8], rbx
	mov rbx, [rsp+8]
	mov rcx, [rbp+16]
	mov [rbx+8], rcx
	mov rcx, [rsp+24]
	mov [rbx+16], rcx
	mov QWORD [rbx], Div__VTABLE
	mov rbx, [rsp+8]
	mov [rbp+16], rbx
	add rsp, 16
	jmp .L13
	.L17:
	mov rcx, [rsp+24]
	mov bl, [rcx]
	mov cl, 0x25
	cmp bl, cl
	sete bl
	test bl, bl
	je .L18
	sub rsp, 16
	sub rsp, 16
	mov rbx, 0x18
	mov [rsp+8], rbx
	call malloc
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rsp+8], rbx
	mov rbx, [rsp+8]
	mov rcx, [rbp+16]
	mov [rbx+8], rcx
	mov rcx, [rsp+24]
	mov [rbx+16], rcx
	mov QWORD [rbx], Mod__VTABLE
	mov rbx, [rsp+8]
	mov [rbp+16], rbx
	add rsp, 16
	jmp .L13
	.L18:
	mov rcx, [rsp+24]
	mov bl, [rcx]
	mov cl, 0x5e
	cmp bl, cl
	sete bl
	test bl, bl
	je .L19
	sub rsp, 16
	sub rsp, 16
	mov rbx, 0x18
	mov [rsp+8], rbx
	call malloc
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rsp+8], rbx
	mov rbx, [rsp+8]
	mov rcx, [rbp+16]
	mov [rbx+8], rcx
	mov rcx, [rsp+24]
	mov [rbx+16], rcx
	mov QWORD [rbx], Pow__VTABLE
	mov rbx, [rsp+8]
	mov [rbp+16], rbx
	add rsp, 16
	jmp .L13
	.L19:
	.L13:
	jmp .L1
	.L2:
	add rsp, 32
	.L0:
	leave
	ret

global parse:function
parse:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	lea rbx, [rsp+16]
	sub rsp, 16
	mov [rsp+0], rbx
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	call tokenize
	add rsp, 16
	xor rbx, rbx
	mov [rsp+8], rbx
	sub rsp, 32
	lea rbx, [rsp+48]
	mov [rsp+8], rbx
	lea rbx, [rsp+40]
	mov [rsp+16], rbx
	xor rbx, rbx
	mov [rsp+24], rbx
	call parse_expression
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rbp+16], rbx
	sub rsp, 16
	lea rbx, [rsp+32]
	mov [rsp+0], rbx
	call vector.free
	add rsp, 16
	.L0:
	leave
	ret

global main:function
main:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, STR6
	mov [rsp+0], rbx
	call println
	add rsp, 16
	sub rsp, 1040
	.L1:
	sub rsp, 16
	mov rbx, STR7
	mov [rsp+0], rbx
	call println
	add rsp, 16
	sub rsp, 32
	lea rbx, [rsp+48]
	mov [rsp+8], rbx
	mov rbx, 0x400
	mov [rsp+16], rbx
	call input
	add rsp, 32
	lea rbx, [rsp+16]
	xor rcx, rcx
	mov sil, [rbx+rcx*1]
	mov bl, 0x71
	cmp sil, bl
	sete bl
	test bl, bl
	je .L3
	jmp .L2
	.L3:
	.L4:
	sub rsp, 16
	lea rbx, [rsp+32]
	mov [rsp+8], rbx
	call parse
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rsp+8], rbx
	sub rsp, 16
	mov rbx, STR8
	mov [rsp+0], rbx
	sub rsp, 16
	mov rbx, [rsp+40]
	mov [rsp+8], rbx
	mov rbx, [rsp+8]
	mov rbx, [rbx]
	call [rbx+0*8]
	movsd xmm0, [rsp+0]
	add rsp, 16
	movsd [rsp+8], xmm0
	call println
	add rsp, 16
	sub rsp, 16
	mov rbx, [rsp+24]
	mov [rsp+0], rbx
	mov rbx, [rsp+0]
	mov rbx, [rbx]
	call [rbx+1*8]
	add rsp, 16
	jmp .L1
	.L2:
	add rsp, 1040
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
Value.free equ Expr.free
Add.eval equ BinOp.eval
Add.free equ BinOp.free
Sub.eval equ BinOp.eval
Sub.free equ BinOp.free
Mul.eval equ BinOp.eval
Mul.free equ BinOp.free
Div.eval equ BinOp.eval
Div.free equ BinOp.free
Mod.eval equ BinOp.eval
Mod.free equ BinOp.free
Pow.eval equ BinOp.eval
Pow.free equ BinOp.free


section .data align=16
__FP_TMP: times 4 dq 0
__GP_TMP: times 4 dq 0
extern stdout:data
extern stdin:data
static Expr__VTABLE:data
Expr__VTABLE:
dq Expr.eval
dq Expr.free
static Value__VTABLE:data
Value__VTABLE:
dq Value.eval
dq Value.free
static Neg__VTABLE:data
Neg__VTABLE:
dq Neg.eval
dq Neg.free
static BinOp__VTABLE:data
BinOp__VTABLE:
dq BinOp.eval
dq BinOp.free
dq BinOp.compute
static Add__VTABLE:data
Add__VTABLE:
dq Add.eval
dq Add.free
dq Add.compute
static Sub__VTABLE:data
Sub__VTABLE:
dq Sub.eval
dq Sub.free
dq Sub.compute
static Mul__VTABLE:data
Mul__VTABLE:
dq Mul.eval
dq Mul.free
dq Mul.compute
static Div__VTABLE:data
Div__VTABLE:
dq Div.eval
dq Div.free
dq Div.compute
static Mod__VTABLE:data
Mod__VTABLE:
dq Mod.eval
dq Mod.free
dq Mod.compute
static Pow__VTABLE:data
Pow__VTABLE:
dq Pow.eval
dq Pow.free
dq Pow.compute
extern File:data
extern fixed:data
extern string:data
extern vector:data


section .rodata align=16
__FABS_MASKd: dq 0x7FFFFFFFFFFFFFFF, 0
__FABS_MASKs: dd 0x7FFFFFFF, 0, 0, 0
__FNEG_MASKd: dq 0x8000000000000000, 0
__FNEG_MASKs: dd 0x80000000, 0, 0, 0
STR0:
db "Expression missing",0
times 3 db 0
STR1:
db "Missing closing ')'",0
dw 0
STR2:
db "Expected closing ')'",0
db 0
STR3:
db "Invalid term expression",0
times 6 db 0
STR4:
db "No implicit multiplication",0
times 3 db 0
STR5:
db "Invalid operator %c",0
dw 0
STR6:
db "[==== Press 'q' to quit calculator. ====]",0
dd 0
STR7:
db "",0
times 5 db 0
STR8:
db "= %g",0
db 0
