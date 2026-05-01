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

global JSON.skip_whitespace:function
JSON.skip_whitespace:
	push rbp
	mov rbp, rsp
	.L1:
	sub rsp, 16
	mov rbx, QWORD [JSON+8]
	mov cl, [rbx]
	mov [rsp+1], cl
	call is_whitespace
	mov bl, [rsp+0]
	add rsp, 16
	test bl, bl
	je .L3
	.L2:
	lea rcx, [JSON+8]
	mov rbx, [rcx]
	inc QWORD [rcx]
	jmp .L1
	.L3:
	.L0:
	leave
	ret

global JSON.get_line:function
JSON.get_line:
	push rbp
	mov rbp, rsp
	xor rbx, rbx
	mov [rbp+16], rbx
	sub rsp, 16
	mov rbx, QWORD [JSON+8]
	mov [rsp+8], rbx
	.L1:
	mov rbx, [rsp+8]
	mov rcx, QWORD [JSON+0]
	cmp rbx, rcx
	setae bl
	test bl, bl
	je .L3
	mov rbx, [rsp+8]
	mov cl, [rbx]
	mov bl, 0xa
	cmp cl, bl
	sete bl
	test bl, bl
	je .L4
	mov rbx, [rbp+16]
	inc QWORD [rbp+16]
	.L4:
	.L5:
	.L2:
	mov rbx, [rsp+8]
	dec QWORD [rsp+8]
	jmp .L1
	.L3:
	add rsp, 16
	.L0:
	leave
	ret

global JSON.print_debug:function
JSON.print_debug:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov rbx, STR0
	mov [rsp+0], rbx
	sub rsp, 48
	mov rbx, QWORD [JSON+8]
	mov [rsp+8], rbx
	mov bl, 0xa
	mov [rsp+16], bl
	sub rsp, 16
	mov rbx, QWORD [JSON+8]
	mov [rsp+8], rbx
	call strlen
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rsp+24], rbx
	xor bl, bl
	mov [rsp+32], bl
	call strfind
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rsp+8], rbx
	mov rbx, QWORD [JSON+8]
	mov [rsp+16], rbx
	call println
	add rsp, 32
	.L0:
	leave
	ret

global JSON.parse_term:function
JSON.parse_term:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	call JSON.skip_whitespace
	mov rbx, QWORD [JSON+8]
	mov cl, [rbx]
	mov [rsp+15], cl
	mov bl, [rsp+15]
	xor cl, cl
	cmp bl, cl
	sete bl
	test bl, bl
	je .L1
	mov rbx, [rbp+16]
	xor cl, cl
	mov [rbx], cl
	mov rcx, 0x7
	mov [rbx+24], rcx
	jmp .L0
	.L1:
	.L2:
	mov bl, [rsp+15]
	mov cl, 0x2d
	cmp bl, cl
	sete bl
	test bl, bl
	jne .L6
	mov cl, [rsp+15]
	mov sil, 0x2b
	cmp cl, sil
	sete bl
	.L6:
	test bl, bl
	jne .L5
	sub rsp, 16
	mov bl, [rsp+31]
	mov [rsp+1], bl
	call is_num
	mov bl, [rsp+0]
	add rsp, 16
	.L5:
	test bl, bl
	je .L3
	sub rsp, 16
	mov bl, [rsp+31]
	mov cl, 0x2d
	cmp bl, cl
	sete bl
	mov [rsp+15], bl
	mov bl, [rsp+31]
	mov cl, 0x2d
	cmp bl, cl
	sete bl
	test bl, bl
	jne .L9
	mov cl, [rsp+31]
	mov sil, 0x2b
	cmp cl, sil
	sete bl
	.L9:
	test bl, bl
	je .L7
	lea rcx, [JSON+8]
	mov rbx, [rcx]
	inc QWORD [rcx]
	.L7:
	.L8:
	xor rbx, rbx
	mov [rsp+0], rbx
	.L10:
	sub rsp, 16
	mov rbx, QWORD [JSON+8]
	mov cl, [rbx]
	mov [rsp+1], cl
	call is_num
	mov bl, [rsp+0]
	add rsp, 16
	test bl, bl
	je .L12
	mov rbx, [rsp+0]
	shl rbx, 1
	lea rbx, [rbx+rbx*4]
	mov rsi, QWORD [JSON+8]
	movzx rcx, BYTE [rsi]
	sub rcx, 0x30
	add rbx, rcx
	mov [rsp+0], rbx
	.L11:
	lea rcx, [JSON+8]
	mov rbx, [rcx]
	inc QWORD [rcx]
	jmp .L10
	.L12:
	mov rbx, QWORD [JSON+8]
	mov cl, [rbx]
	mov bl, 0x2e
	cmp cl, bl
	sete bl
	test bl, bl
	je .L13
	sub rsp, 32
	movsd xmm0, [FP0]
	movsd [rsp+24], xmm0
	movsd xmm0, [FP1]
	movsd [rsp+16], xmm0
	lea rcx, [JSON+8]
	mov rbx, [rcx]
	inc QWORD [rcx]
	.L15:
	sub rsp, 16
	mov rbx, QWORD [JSON+8]
	mov cl, [rbx]
	mov [rsp+1], cl
	call is_num
	mov bl, [rsp+0]
	add rsp, 16
	test bl, bl
	je .L17
	movsd xmm0, [rsp+24]
	mov rbx, QWORD [JSON+8]
	movzx rcx, BYTE [rbx]
	sub rcx, 0x30
	cvtsi2sd xmm1, rcx
	movsd xmm2, [rsp+16]
	mulsd xmm1, xmm2
	addsd xmm0, xmm1
	movsd [rsp+24], xmm0
	movsd xmm0, [rsp+16]
	movsd xmm1, [FP1]
	mulsd xmm0, xmm1
	movsd [rsp+16], xmm0
	.L16:
	lea rcx, [JSON+8]
	mov rbx, [rcx]
	inc QWORD [rcx]
	jmp .L15
	.L17:
	mov rbx, [rsp+32]
	cvtsi2sd xmm0, rbx
	movsd xmm1, [rsp+24]
	addsd xmm0, xmm1
	movsd [rsp+8], xmm0
	mov rbx, [rbp+16]
	mov cl, [rsp+47]
	test cl, cl
	je .L18
	movsd xmm0, [rsp+8]
	xorpd xmm0, [__FNEG_MASKd]
	jmp .L19
	.L18:
	movsd xmm0, [rsp+8]
	.L19:
	movsd [rbx], xmm0
	mov rcx, 0x2
	mov [rbx+24], rcx
	jmp .L0
	add rsp, 32
	.L13:
	.L14:
	mov rbx, [rbp+16]
	mov sil, [rsp+15]
	test sil, sil
	je .L20
	mov rcx, [rsp+0]
	neg rcx
	jmp .L21
	.L20:
	mov rcx, [rsp+0]
	.L21:
	mov [rbx], rcx
	mov rcx, 0x1
	mov [rbx+24], rcx
	jmp .L0
	add rsp, 16
	jmp .L4
	.L3:
	mov bl, [rsp+15]
	mov cl, 0x22
	cmp bl, cl
	sete bl
	test bl, bl
	je .L22
	sub rsp, 16
	lea rcx, [JSON+8]
	inc QWORD [rcx]
	mov rbx, [rcx]
	mov [rsp+8], rbx
	.L23:
	mov rbx, QWORD [JSON+8]
	mov cl, [rbx]
	test cl, cl
	setne bl
	je .L26
	mov rcx, QWORD [JSON+8]
	mov sil, [rcx]
	mov cl, 0x22
	cmp sil, cl
	setne bl
	.L26:
	test bl, bl
	je .L25
	.L24:
	lea rcx, [JSON+8]
	mov rbx, [rcx]
	inc QWORD [rcx]
	jmp .L23
	.L25:
	lea rcx, [JSON+8]
	mov rbx, [rcx]
	inc QWORD [rcx]
	mov rbx, [rbp+16]
	mov rcx, [rsp+8]
	mov [rbx], rcx
	mov rcx, 0x4
	mov [rbx+24], rcx
	jmp .L0
	add rsp, 16
	jmp .L4
	.L22:
	mov bl, [rsp+15]
	mov cl, 0x5b
	cmp bl, cl
	sete bl
	test bl, bl
	je .L27
	sub rsp, 16
	lea rbx, [rsp+0]
	xor rcx, rcx
	mov [rbx+0], rcx
	xor rcx, rcx
	mov [rbx+8], rcx
	sub rsp, 32
	.L28:
	lea rcx, [JSON+8]
	mov rbx, [rcx]
	inc QWORD [rcx]
	call JSON.skip_whitespace
	mov rbx, QWORD [JSON+8]
	mov cl, [rbx]
	mov bl, 0x5d
	cmp cl, bl
	sete bl
	test bl, bl
	je .L30
	jmp .L29
	.L30:
	.L31:
	lea rbx, [rsp+0]
	sub rsp, 16
	mov [rsp+0], rbx
	call JSON.parse_term
	add rsp, 16
	sub rsp, 48
	lea rbx, [rsp+80]
	mov [rsp+0], rbx
	lea rbx, [rsp+8]
	cld
	lea rdi, [rbx]
	lea rsi, [rsp+48]
	mov rcx, 4
	rep movsq
	call JSON_Array.append
	add rsp, 48
	call JSON.skip_whitespace
	mov rbx, QWORD [JSON+8]
	mov cl, [rbx]
	mov bl, 0x2c
	cmp cl, bl
	setne bl
	test bl, bl
	je .L32
	jmp .L29
	.L32:
	.L33:
	jmp .L28
	.L29:
	add rsp, 32
	call JSON.skip_whitespace
	lea rcx, [JSON+8]
	mov rbx, [rcx]
	inc QWORD [rcx]
	mov cl, [rbx]
	mov bl, 0x5d
	cmp cl, bl
	setne bl
	test bl, bl
	je .L34
	sub rsp, 16
	lea rbx, [rsp+16]
	mov [rsp+0], rbx
	call JSON_Array.free
	add rsp, 16
	sub rsp, 32
	mov rbx, STR1
	mov [rsp+0], rbx
	sub rsp, 16
	call JSON.get_line
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rsp+8], rbx
	mov rbx, QWORD [JSON+8]
	movzx rcx, BYTE [rbx]
	mov [rsp+16], rcx
	call println
	add rsp, 32
	xor bl, bl
	mov [JSON+16], bl
	mov rbx, [rbp+16]
	xor cl, cl
	mov [rbx], cl
	mov rcx, 0x7
	mov [rbx+24], rcx
	jmp .L0
	.L34:
	.L35:
	mov rbx, [rbp+16]
	cld
	lea rdi, [rbx]
	lea rsi, [rsp+0]
	mov rcx, 2
	rep movsq
	mov rcx, 0x5
	mov [rbx+24], rcx
	jmp .L0
	add rsp, 16
	jmp .L4
	.L27:
	mov bl, [rsp+15]
	mov cl, 0x7b
	cmp bl, cl
	sete bl
	test bl, bl
	je .L36
	sub rsp, 32
	lea rbx, [rsp+8]
	xor rcx, rcx
	mov [rbx+0], rcx
	xor rcx, rcx
	mov [rbx+8], rcx
	xor rcx, rcx
	mov [rbx+16], rcx
	sub rsp, 64
	.L37:
	lea rcx, [JSON+8]
	mov rbx, [rcx]
	inc QWORD [rcx]
	call JSON.skip_whitespace
	mov rbx, QWORD [JSON+8]
	mov cl, [rbx]
	mov bl, 0x7d
	cmp cl, bl
	sete bl
	test bl, bl
	je .L39
	jmp .L38
	.L39:
	.L40:
	lea rbx, [rsp+32]
	sub rsp, 16
	mov [rsp+0], rbx
	call JSON.parse_term
	add rsp, 16
	lea rcx, [rsp+32]
	mov rbx, [rcx+24]
	mov rcx, 0x4
	cmp rbx, rcx
	setne bl
	test bl, bl
	je .L41
	sub rsp, 16
	lea rbx, [rsp+88]
	mov [rsp+0], rbx
	call JSON_Object.free
	add rsp, 16
	sub rsp, 16
	mov rbx, STR2
	mov [rsp+0], rbx
	sub rsp, 16
	call JSON.get_line
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rsp+8], rbx
	call println
	add rsp, 16
	xor bl, bl
	mov [JSON+16], bl
	mov rbx, [rbp+16]
	xor cl, cl
	mov [rbx], cl
	mov rcx, 0x7
	mov [rbx+24], rcx
	jmp .L0
	.L41:
	.L42:
	call JSON.skip_whitespace
	lea rcx, [JSON+8]
	mov rbx, [rcx]
	inc QWORD [rcx]
	mov cl, [rbx]
	mov bl, 0x3a
	cmp cl, bl
	setne bl
	test bl, bl
	je .L43
	sub rsp, 16
	lea rbx, [rsp+88]
	mov [rsp+0], rbx
	call JSON_Object.free
	add rsp, 16
	sub rsp, 32
	mov rbx, STR3
	mov [rsp+0], rbx
	sub rsp, 16
	call JSON.get_line
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rsp+8], rbx
	mov rbx, QWORD [JSON+8]
	movzx rcx, BYTE [rbx]
	mov [rsp+16], rcx
	call println
	add rsp, 32
	xor bl, bl
	mov [JSON+16], bl
	mov rbx, [rbp+16]
	xor cl, cl
	mov [rbx], cl
	mov rcx, 0x7
	mov [rbx+24], rcx
	jmp .L0
	.L43:
	.L44:
	lea rbx, [rsp+0]
	sub rsp, 16
	mov [rsp+0], rbx
	call JSON.parse_term
	add rsp, 16
	sub rsp, 48
	lea rbx, [rsp+120]
	mov [rsp+0], rbx
	mov rbx, [rsp+80]
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	cld
	lea rdi, [rbx]
	lea rsi, [rsp+48]
	mov rcx, 4
	rep movsq
	call JSON_Object.append
	add rsp, 48
	mov rbx, QWORD [JSON+8]
	mov cl, [rbx]
	mov bl, 0x2c
	cmp cl, bl
	setne bl
	test bl, bl
	je .L45
	jmp .L38
	.L45:
	.L46:
	jmp .L37
	.L38:
	add rsp, 64
	call JSON.skip_whitespace
	lea rcx, [JSON+8]
	mov rbx, [rcx]
	inc QWORD [rcx]
	mov cl, [rbx]
	mov bl, 0x7d
	cmp cl, bl
	setne bl
	test bl, bl
	je .L47
	sub rsp, 16
	lea rbx, [rsp+24]
	mov [rsp+0], rbx
	call JSON_Object.free
	add rsp, 16
	sub rsp, 32
	mov rbx, STR4
	mov [rsp+0], rbx
	sub rsp, 16
	call JSON.get_line
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rsp+8], rbx
	mov rbx, QWORD [JSON+8]
	movzx rcx, BYTE [rbx]
	mov [rsp+16], rcx
	call println
	add rsp, 32
	xor bl, bl
	mov [JSON+16], bl
	mov rbx, [rbp+16]
	xor cl, cl
	mov [rbx], cl
	mov rcx, 0x7
	mov [rbx+24], rcx
	jmp .L0
	.L47:
	.L48:
	mov rbx, [rbp+16]
	cld
	lea rdi, [rbx]
	lea rsi, [rsp+8]
	mov rcx, 3
	rep movsq
	mov rcx, 0x6
	mov [rbx+24], rcx
	jmp .L0
	add rsp, 32
	jmp .L4
	.L36:
	sub rsp, 32
	mov rbx, QWORD [JSON+8]
	mov [rsp+8], rbx
	mov rbx, STR5
	mov [rsp+16], rbx
	mov rbx, 0x4
	mov [rsp+24], rbx
	call strcmp
	movsx rbx, BYTE [rsp+0]
	add rsp, 32
	xor rcx, rcx
	cmp rbx, rcx
	sete bl
	test bl, bl
	jne .L50
	sub rsp, 32
	mov [rsp+31], bl
	mov rbx, QWORD [JSON+8]
	mov [rsp+8], rbx
	mov rbx, STR6
	mov [rsp+16], rbx
	mov rbx, 0x5
	mov [rsp+24], rbx
	call strcmp
	mov bl, [rsp+31]
	movsx rcx, BYTE [rsp+0]
	add rsp, 32
	xor rsi, rsi
	cmp rcx, rsi
	sete bl
	.L50:
	test bl, bl
	je .L49
	sub rsp, 16
	mov bl, [rsp+31]
	mov cl, 0x74
	cmp bl, cl
	sete bl
	mov [rsp+15], bl
	mov bl, [rsp+15]
	test bl, bl
	je .L51
	mov rbx, QWORD [JSON+8]
	add rbx, 0x4
	mov [JSON+8], rbx
	jmp .L52
	.L51:
	mov rbx, QWORD [JSON+8]
	add rbx, 0x5
	mov [JSON+8], rbx
	.L52:
	mov rbx, [rbp+16]
	mov cl, [rsp+15]
	mov [rbx], cl
	mov rcx, 0x3
	mov [rbx+24], rcx
	jmp .L0
	add rsp, 16
	jmp .L4
	.L49:
	sub rsp, 32
	mov rbx, QWORD [JSON+8]
	mov [rsp+8], rbx
	mov rbx, STR7
	mov [rsp+16], rbx
	mov rbx, 0x4
	mov [rsp+24], rbx
	call strcmp
	movsx rbx, BYTE [rsp+0]
	add rsp, 32
	xor rcx, rcx
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L53
	mov rbx, QWORD [JSON+8]
	add rbx, 0x4
	mov [JSON+8], rbx
	mov rbx, [rbp+16]
	xor cl, cl
	mov [rbx], cl
	mov rcx, 0x7
	mov [rbx+24], rcx
	jmp .L0
	jmp .L4
	.L53:
	sub rsp, 32
	mov rbx, STR8
	mov [rsp+0], rbx
	sub rsp, 16
	call JSON.get_line
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rsp+8], rbx
	sub rsp, 48
	mov rbx, QWORD [JSON+8]
	mov [rsp+8], rbx
	mov bl, 0xa
	mov [rsp+16], bl
	sub rsp, 16
	mov rbx, QWORD [JSON+8]
	mov [rsp+8], rbx
	call strlen
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rsp+24], rbx
	xor bl, bl
	mov [rsp+32], bl
	call strfind
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rsp+16], rbx
	mov rbx, QWORD [JSON+8]
	mov [rsp+24], rbx
	call println
	add rsp, 32
	xor bl, bl
	mov [JSON+16], bl
	mov rbx, [rbp+16]
	xor cl, cl
	mov [rbx], cl
	mov rcx, 0x7
	mov [rbx+24], rcx
	jmp .L0
	.L4:
	.L0:
	leave
	ret

global JSON.parse:function
JSON.parse:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+24]
	mov [JSON+0], rbx
	mov rbx, [rbp+24]
	mov [JSON+8], rbx
	mov bl, 0x1
	mov [JSON+16], bl
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+0], rbx
	call JSON.parse_term
	add rsp, 16
	jmp .L0
	.L0:
	leave
	ret

global JSON.print_data:function
JSON.print_data:
	push rbp
	mov rbp, rsp
	mov rcx, [rbp+16]
	mov rbx, [rcx+24]
	mov rcx, 0x1
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L1
	sub rsp, 32
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, STR9
	mov [rsp+8], rbx
	mov rcx, [rbp+16]
	mov rbx, [rcx]
	mov [rsp+16], rbx
	call File.print
	add rsp, 32
	jmp .L2
	.L1:
	mov rcx, [rbp+16]
	mov rbx, [rcx+24]
	mov rcx, 0x2
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L3
	sub rsp, 32
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, STR10
	mov [rsp+8], rbx
	mov rbx, [rbp+16]
	movsd xmm0, [rbx]
	movsd [rsp+16], xmm0
	call File.print
	add rsp, 32
	jmp .L2
	.L3:
	mov rcx, [rbp+16]
	mov rbx, [rcx+24]
	mov rcx, 0x3
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L4
	sub rsp, 32
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, STR11
	mov [rsp+8], rbx
	mov rcx, [rbp+16]
	movzx rbx, BYTE [rcx]
	mov [rsp+16], rbx
	call File.print
	add rsp, 32
	jmp .L2
	.L4:
	mov rcx, [rbp+16]
	mov rbx, [rcx+24]
	mov rcx, 0x4
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L5
	sub rsp, 32
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, STR12
	mov [rsp+8], rbx
	sub rsp, 48
	mov rcx, [rbp+16]
	mov rbx, [rcx]
	mov [rsp+8], rbx
	mov bl, 0x22
	mov [rsp+16], bl
	mov rbx, 0xffffffffffffffff
	mov [rsp+24], rbx
	xor bl, bl
	mov [rsp+32], bl
	call strfind
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rsp+16], rbx
	mov rcx, [rbp+16]
	mov rbx, [rcx]
	mov [rsp+24], rbx
	call File.print
	add rsp, 32
	jmp .L2
	.L5:
	mov rcx, [rbp+16]
	mov rbx, [rcx+24]
	mov rcx, 0x5
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L6
	sub rsp, 32
	mov rbx, [rbp+16]
	mov [rsp+0], rbx
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	call JSON_Array.print
	add rsp, 32
	jmp .L2
	.L6:
	mov rcx, [rbp+16]
	mov rbx, [rcx+24]
	mov rcx, 0x6
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L7
	sub rsp, 32
	mov rbx, [rbp+16]
	mov [rsp+0], rbx
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	call JSON_Object.print
	add rsp, 32
	jmp .L2
	.L7:
	mov rcx, [rbp+16]
	mov rbx, [rcx+24]
	mov rcx, 0x7
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L8
	sub rsp, 16
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, STR7
	mov [rsp+8], rbx
	call File.print
	add rsp, 16
	jmp .L2
	.L8:
	sub rsp, 32
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, STR13
	mov [rsp+8], rbx
	mov rcx, [rbp+16]
	mov rbx, [rcx+24]
	mov [rsp+16], rbx
	call File.print
	add rsp, 32
	.L2:
	.L0:
	leave
	ret

global JSON.print:function
JSON.print:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov rbx, [rbp+16]
	mov [rsp+0], rbx
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	call JSON.print_data
	add rsp, 32
	sub rsp, 16
	mov rbx, STR14
	mov [rsp+0], rbx
	call println
	add rsp, 16
	.L0:
	leave
	ret

global JSON.free:function
JSON.free:
	push rbp
	mov rbp, rsp
	mov rcx, [rbp+16]
	mov rbx, [rcx+24]
	mov rcx, 0x5
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L1
	sub rsp, 16
	mov rbx, [rbp+16]
	mov [rsp+0], rbx
	call JSON_Array.free
	add rsp, 16
	jmp .L2
	.L1:
	mov rcx, [rbp+16]
	mov rbx, [rcx+24]
	mov rcx, 0x6
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L3
	sub rsp, 16
	mov rbx, [rbp+16]
	mov [rsp+0], rbx
	call JSON_Object.free
	add rsp, 16
	jmp .L2
	.L3:
	.L2:
	.L0:
	leave
	ret

global JSON_Array.append:function
JSON_Array.append:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 32
	mov [rsp+24], rbx
	mov rcx, [rbp+16]
	mov rbx, [rcx+0]
	mov [rsp+8], rbx
	mov rcx, [rbp+16]
	lea rcx, [rcx+8]
	inc QWORD [rcx]
	mov rbx, [rcx]
	shl rbx, 5
	mov [rsp+16], rbx
	call realloc
	mov rbx, [rsp+24]
	mov rcx, [rsp+0]
	add rsp, 32
	mov [rbx+0], rcx
	mov rsi, [rbp+16]
	mov rcx, [rsi+0]
	test rcx, rcx
	sete bl
	test bl, bl
	je .L1
	sub rsp, 16
	mov rbx, STR15
	mov [rsp+0], rbx
	lea rcx, [rbp+24]
	mov rbx, [rcx+24]
	mov [rsp+8], rbx
	call error
	add rsp, 16
	.L1:
	.L2:
	mov rcx, [rbp+16]
	mov rbx, [rcx+0]
	mov rsi, [rbp+16]
	mov rcx, [rsi+8]
	dec rcx
	shl rcx, 2
	lea rbx, [rbx+rcx*8]
	cld
	lea rdi, [rbx]
	lea rsi, [rbp+24]
	mov rcx, 4
	rep movsq
	.L0:
	leave
	ret

global JSON_Array.print:function
JSON_Array.print:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+24]
	test rbx, rbx
	setne cl
	je .L3
	sub rsp, 32
	mov [rsp+31], cl
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call File.get_buffering
	mov cl, [rsp+31]
	mov rbx, [rsp+0]
	add rsp, 32
	mov rsi, 0x2
	cmp rbx, rsi
	setne cl
	.L3:
	test cl, cl
	je .L1
	sub rsp, 16
	mov rbx, STR16
	mov [rsp+0], rbx
	call error
	add rsp, 16
	.L1:
	.L2:
	mov rbx, [rbp+24]
	xor rcx, rcx
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L4
	mov rbx, 0x3
	mov [rbp+24], rbx
	jmp .L5
	.L4:
	mov rbx, [rbp+24]
	test rbx, rbx
	je .L6
	sub rsp, 32
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, STR17
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	call File.print
	add rsp, 32
	mov rbx, [rbp+24]
	add rbx, 0x3
	mov [rbp+24], rbx
	jmp .L5
	.L6:
	.L5:
	sub rsp, 16
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, STR18
	mov [rsp+8], rbx
	call File.print
	add rsp, 16
	sub rsp, 16
	xor rbx, rbx
	mov [rsp+8], rbx
	.L7:
	mov rbx, [rsp+8]
	mov rsi, [rbp+16]
	mov rcx, [rsi+8]
	cmp rbx, rcx
	setb bl
	test bl, bl
	je .L9
	mov rbx, [rbp+24]
	test rbx, rbx
	je .L10
	sub rsp, 32
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, STR19
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	call File.print
	add rsp, 32
	.L10:
	.L11:
	sub rsp, 32
	mov rsi, [rbp+16]
	mov rcx, [rsi+0]
	mov rsi, [rsp+40]
	shl rsi, 2
	lea rbx, [rcx+rsi*8]
	mov [rsp+0], rbx
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	call JSON.print_data
	add rsp, 32
	mov rbx, [rsp+8]
	mov rsi, [rbp+16]
	mov rcx, [rsi+8]
	dec rcx
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L12
	sub rsp, 32
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, STR20
	mov [rsp+8], rbx
	mov cl, [rbp+24]
	test cl, cl
	je .L14
	mov rbx, 0x2
	jmp .L15
	.L14:
	mov rbx, 0x1
	.L15:
	mov [rsp+16], rbx
	mov rbx, STR21
	mov [rsp+24], rbx
	call File.print
	add rsp, 32
	.L12:
	.L13:
	.L8:
	mov rbx, [rsp+8]
	inc QWORD [rsp+8]
	jmp .L7
	.L9:
	add rsp, 16
	mov rbx, [rbp+24]
	test rbx, rbx
	je .L16
	sub rsp, 32
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, STR19
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	sub rbx, 0x3
	mov [rsp+16], rbx
	call File.print
	add rsp, 32
	.L16:
	.L17:
	sub rsp, 16
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, STR22
	mov [rsp+8], rbx
	call File.print
	add rsp, 16
	.L0:
	leave
	ret

global JSON_Array.free:function
JSON_Array.free:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	xor rbx, rbx
	mov [rsp+8], rbx
	.L1:
	mov rbx, [rsp+8]
	mov rsi, [rbp+16]
	mov rcx, [rsi+8]
	cmp rbx, rcx
	setb bl
	test bl, bl
	je .L3
	sub rsp, 16
	mov rsi, [rbp+16]
	mov rcx, [rsi+0]
	mov rsi, [rsp+24]
	shl rsi, 2
	lea rbx, [rcx+rsi*8]
	mov [rsp+0], rbx
	call JSON.free
	add rsp, 16
	.L2:
	mov rbx, [rsp+8]
	inc QWORD [rsp+8]
	jmp .L1
	.L3:
	add rsp, 16
	mov rcx, [rbp+16]
	mov rbx, [rcx+0]
	test rbx, rbx
	je .L4
	sub rsp, 16
	mov rcx, [rbp+16]
	mov rbx, [rcx+0]
	mov [rsp+0], rbx
	call free
	add rsp, 16
	.L4:
	.L5:
	mov rbx, [rbp+16]
	xor rcx, rcx
	mov [rbx+0], rcx
	xor rcx, rcx
	mov [rbx+8], rcx
	.L0:
	leave
	ret

global JSON_Object.append:function
JSON_Object.append:
	push rbp
	mov rbp, rsp
	mov rcx, [rbp+16]
	lea rcx, [rcx+16]
	mov rbx, [rcx]
	inc QWORD [rcx]
	mov rbx, [rbp+16]
	sub rsp, 32
	mov [rsp+24], rbx
	mov rcx, [rbp+16]
	mov rbx, [rcx+0]
	mov [rsp+8], rbx
	mov rcx, [rbp+16]
	mov rbx, [rcx+16]
	shl rbx, 3
	mov [rsp+16], rbx
	call realloc
	mov rbx, [rsp+24]
	mov rcx, [rsp+0]
	add rsp, 32
	mov [rbx+0], rcx
	mov rbx, [rbp+16]
	sub rsp, 32
	mov [rsp+24], rbx
	mov rcx, [rbp+16]
	mov rbx, [rcx+8]
	mov [rsp+8], rbx
	mov rcx, [rbp+16]
	mov rbx, [rcx+16]
	shl rbx, 5
	mov [rsp+16], rbx
	call realloc
	mov rbx, [rsp+24]
	mov rcx, [rsp+0]
	add rsp, 32
	mov [rbx+8], rcx
	mov rsi, [rbp+16]
	mov rcx, [rsi+0]
	test rcx, rcx
	sete bl
	test bl, bl
	jne .L3
	mov rsi, [rbp+16]
	mov rcx, [rsi+8]
	test rcx, rcx
	sete bl
	.L3:
	test bl, bl
	je .L1
	sub rsp, 32
	mov rbx, STR23
	mov [rsp+0], rbx
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	lea rcx, [rbp+32]
	mov rbx, [rcx+24]
	mov [rsp+16], rbx
	call error
	add rsp, 32
	.L1:
	.L2:
	mov rcx, [rbp+16]
	mov rbx, [rcx+0]
	mov rsi, [rbp+16]
	mov rcx, [rsi+16]
	dec rcx
	mov rsi, [rbp+24]
	mov [rbx+rcx*8], rsi
	mov rcx, [rbp+16]
	mov rbx, [rcx+8]
	mov rsi, [rbp+16]
	mov rcx, [rsi+16]
	dec rcx
	shl rcx, 2
	lea rbx, [rbx+rcx*8]
	cld
	lea rdi, [rbx]
	lea rsi, [rbp+32]
	mov rcx, 4
	rep movsq
	.L0:
	leave
	ret

global JSON_Object.get:function
JSON_Object.get:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	sub rsp, 16
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call strlen
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rsp+8], rbx
	sub rsp, 16
	xor rbx, rbx
	mov [rsp+8], rbx
	.L1:
	mov rbx, [rsp+8]
	mov rsi, [rbp+24]
	mov rcx, [rsi+16]
	cmp rbx, rcx
	setb bl
	test bl, bl
	je .L3
	sub rsp, 16
	mov rcx, [rbp+24]
	mov rbx, [rcx+0]
	mov rcx, [rsp+24]
	mov rsi, [rbx+rcx*8]
	mov [rsp+8], rsi
	sub rsp, 16
	mov rbx, [rsp+24]
	mov [rsp+8], rbx
	call strlen
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rsp+0], rbx
	sub rsp, 48
	mov rbx, [rsp+56]
	mov [rsp+8], rbx
	mov bl, 0x22
	mov [rsp+16], bl
	mov rbx, [rsp+48]
	mov [rsp+24], rbx
	xor bl, bl
	mov [rsp+32], bl
	call strfind
	mov rbx, [rsp+0]
	add rsp, 48
	xor rcx, rcx
	cmp rbx, rcx
	setge bl
	test bl, bl
	je .L4
	sub rsp, 48
	mov rbx, [rsp+56]
	mov [rsp+8], rbx
	mov bl, 0x22
	mov [rsp+16], bl
	mov rbx, [rsp+48]
	mov [rsp+24], rbx
	xor bl, bl
	mov [rsp+32], bl
	call strfind
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rsp+0], rbx
	.L4:
	.L5:
	mov rbx, [rsp+40]
	mov rcx, [rsp+0]
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L8
	sub rsp, 32
	mov [rsp+31], bl
	mov rbx, [rsp+40]
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	mov rbx, [rsp+32]
	mov [rsp+24], rbx
	call strcmp
	mov bl, [rsp+31]
	movsx rcx, BYTE [rsp+0]
	add rsp, 32
	xor rsi, rsi
	cmp rcx, rsi
	sete bl
	.L8:
	test bl, bl
	je .L6
	mov rsi, [rbp+24]
	mov rcx, [rsi+8]
	mov rsi, [rsp+24]
	shl rsi, 2
	lea rbx, [rcx+rsi*8]
	mov [rbp+16], rbx
	jmp .L0
	.L6:
	.L7:
	add rsp, 16
	.L2:
	mov rbx, [rsp+8]
	inc QWORD [rsp+8]
	jmp .L1
	.L3:
	add rsp, 16
	xor rbx, rbx
	mov [rbp+16], rbx
	.L0:
	leave
	ret

global JSON_Object.print:function
JSON_Object.print:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+24]
	test rbx, rbx
	setne cl
	je .L3
	sub rsp, 32
	mov [rsp+31], cl
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call File.get_buffering
	mov cl, [rsp+31]
	mov rbx, [rsp+0]
	add rsp, 32
	mov rsi, 0x2
	cmp rbx, rsi
	setne cl
	.L3:
	test cl, cl
	je .L1
	sub rsp, 16
	mov rbx, STR16
	mov [rsp+0], rbx
	call error
	add rsp, 16
	.L1:
	.L2:
	mov rbx, [rbp+24]
	xor rcx, rcx
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L4
	mov rbx, 0x3
	mov [rbp+24], rbx
	jmp .L5
	.L4:
	mov rbx, [rbp+24]
	test rbx, rbx
	je .L6
	sub rsp, 32
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, STR17
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	call File.print
	add rsp, 32
	mov rbx, [rbp+24]
	add rbx, 0x3
	mov [rbp+24], rbx
	jmp .L5
	.L6:
	.L5:
	sub rsp, 16
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, STR24
	mov [rsp+8], rbx
	call File.print
	add rsp, 16
	sub rsp, 16
	xor rbx, rbx
	mov [rsp+8], rbx
	.L7:
	mov rbx, [rsp+8]
	mov rsi, [rbp+16]
	mov rcx, [rsi+16]
	cmp rbx, rcx
	setb bl
	test bl, bl
	je .L9
	sub rsp, 16
	mov rbx, [rbp+24]
	test rbx, rbx
	je .L10
	sub rsp, 32
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, STR19
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	call File.print
	add rsp, 32
	.L10:
	.L11:
	mov rcx, [rbp+16]
	mov rbx, [rcx+0]
	mov rcx, [rsp+24]
	mov rsi, [rbx+rcx*8]
	mov [rsp+8], rsi
	sub rsp, 48
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, STR25
	mov [rsp+8], rbx
	sub rsp, 48
	mov rbx, [rsp+104]
	mov [rsp+8], rbx
	mov bl, 0x22
	mov [rsp+16], bl
	mov rbx, 0xffffffffffffffff
	mov [rsp+24], rbx
	xor bl, bl
	mov [rsp+32], bl
	call strfind
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rsp+16], rbx
	mov rbx, [rsp+56]
	mov [rsp+24], rbx
	mov cl, [rbp+24]
	test cl, cl
	je .L12
	mov rbx, 0x2
	jmp .L13
	.L12:
	mov rbx, 0x1
	.L13:
	mov [rsp+32], rbx
	mov rbx, STR26
	mov [rsp+40], rbx
	call File.print
	add rsp, 48
	sub rsp, 32
	mov rsi, [rbp+16]
	mov rcx, [rsi+8]
	mov rsi, [rsp+56]
	shl rsi, 2
	lea rbx, [rcx+rsi*8]
	mov [rsp+0], rbx
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	call JSON.print_data
	add rsp, 32
	mov rbx, [rsp+24]
	mov rsi, [rbp+16]
	mov rcx, [rsi+16]
	dec rcx
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L14
	sub rsp, 32
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, STR20
	mov [rsp+8], rbx
	mov cl, [rbp+24]
	test cl, cl
	je .L16
	mov rbx, 0x2
	jmp .L17
	.L16:
	mov rbx, 0x1
	.L17:
	mov [rsp+16], rbx
	mov rbx, STR21
	mov [rsp+24], rbx
	call File.print
	add rsp, 32
	.L14:
	.L15:
	add rsp, 16
	.L8:
	mov rbx, [rsp+8]
	inc QWORD [rsp+8]
	jmp .L7
	.L9:
	add rsp, 16
	mov rbx, [rbp+24]
	test rbx, rbx
	je .L18
	sub rsp, 32
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, STR19
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	sub rbx, 0x3
	mov [rsp+16], rbx
	call File.print
	add rsp, 32
	.L18:
	.L19:
	sub rsp, 16
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, STR27
	mov [rsp+8], rbx
	call File.print
	add rsp, 16
	.L0:
	leave
	ret

global JSON_Object.free:function
JSON_Object.free:
	push rbp
	mov rbp, rsp
	mov rcx, [rbp+16]
	mov rbx, [rcx+0]
	test rbx, rbx
	je .L1
	sub rsp, 16
	mov rcx, [rbp+16]
	mov rbx, [rcx+0]
	mov [rsp+0], rbx
	call free
	add rsp, 16
	.L1:
	.L2:
	sub rsp, 16
	xor rbx, rbx
	mov [rsp+8], rbx
	.L3:
	mov rbx, [rsp+8]
	mov rsi, [rbp+16]
	mov rcx, [rsi+16]
	cmp rbx, rcx
	setb bl
	test bl, bl
	je .L5
	sub rsp, 16
	mov rsi, [rbp+16]
	mov rcx, [rsi+8]
	mov rsi, [rsp+24]
	shl rsi, 2
	lea rbx, [rcx+rsi*8]
	mov [rsp+0], rbx
	call JSON.free
	add rsp, 16
	.L4:
	mov rbx, [rsp+8]
	inc QWORD [rsp+8]
	jmp .L3
	.L5:
	add rsp, 16
	mov rcx, [rbp+16]
	mov rbx, [rcx+8]
	test rbx, rbx
	je .L6
	sub rsp, 16
	mov rcx, [rbp+16]
	mov rbx, [rcx+8]
	mov [rsp+0], rbx
	call free
	add rsp, 16
	.L6:
	.L7:
	mov rbx, [rbp+16]
	xor rcx, rcx
	mov [rbx+0], rcx
	xor rcx, rcx
	mov [rbx+8], rcx
	xor rcx, rcx
	mov [rbx+16], rcx
	.L0:
	leave
	ret

global main:function
main:
	push rbp
	mov rbp, rsp
	sub rsp, 8288
	lea rbx, [rsp+8272]
	xor rcx, rcx
	mov [rbx+0], rcx
	xor rcx, rcx
	mov [rbx+8], rcx
	sub rsp, 48
	lea rbx, [rsp+8320]
	mov [rsp+0], rbx
	lea rbx, [rsp+8]
	mov rcx, 0x32
	mov [rbx], rcx
	mov rcx, 0x1
	mov [rbx+24], rcx
	call JSON_Array.append
	add rsp, 48
	sub rsp, 48
	lea rbx, [rsp+8320]
	mov [rsp+0], rbx
	lea rbx, [rsp+8]
	movsd xmm0, [FP2]
	movsd [rbx], xmm0
	mov rcx, 0x2
	mov [rbx+24], rcx
	call JSON_Array.append
	add rsp, 48
	sub rsp, 48
	lea rbx, [rsp+8320]
	mov [rsp+0], rbx
	lea rbx, [rsp+8]
	mov cl, 0x1
	mov [rbx], cl
	mov rcx, 0x3
	mov [rbx+24], rcx
	call JSON_Array.append
	add rsp, 48
	sub rsp, 32
	lea rbx, [rsp+8304]
	mov [rsp+0], rbx
	xor rbx, rbx
	mov [rsp+8], rbx
	mov rbx, QWORD [stdout]
	mov [rsp+16], rbx
	call JSON_Array.print
	add rsp, 32
	sub rsp, 16
	mov rbx, STR14
	mov [rsp+0], rbx
	call println
	add rsp, 16
	lea rbx, [rsp+8248]
	xor rcx, rcx
	mov [rbx+0], rcx
	xor rcx, rcx
	mov [rbx+8], rcx
	xor rcx, rcx
	mov [rbx+16], rcx
	sub rsp, 48
	lea rbx, [rsp+8296]
	mov [rsp+0], rbx
	mov rbx, STR28
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	cld
	lea rdi, [rbx]
	lea rsi, [rsp+8320]
	mov rcx, 2
	rep movsq
	mov rcx, 0x5
	mov [rbx+24], rcx
	call JSON_Object.append
	add rsp, 48
	sub rsp, 48
	lea rbx, [rsp+8296]
	mov [rsp+0], rbx
	mov rbx, STR29
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	mov rcx, STR30
	mov [rbx], rcx
	mov rcx, 0x4
	mov [rbx+24], rcx
	call JSON_Object.append
	add rsp, 48
	sub rsp, 32
	lea rbx, [rsp+8280]
	mov [rsp+0], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+8], rbx
	mov rbx, QWORD [stdout]
	mov [rsp+16], rbx
	call JSON_Object.print
	add rsp, 32
	sub rsp, 16
	mov rbx, STR14
	mov [rsp+0], rbx
	call println
	add rsp, 16
	sub rsp, 272
	sub rsp, 32
	mov rbx, STR31
	mov [rsp+8], rbx
	mov rbx, 0x4
	mov [rsp+16], rbx
	call File.open
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+8], rbx
	sub rsp, 32
	mov rbx, [rsp+40]
	mov [rsp+0], rbx
	lea rbx, [rsp+48]
	mov [rsp+8], rbx
	mov rbx, 0x100
	mov [rsp+16], rbx
	call File.set_buffer
	add rsp, 32
	sub rsp, 16
	mov rbx, [rsp+24]
	mov [rsp+0], rbx
	mov rbx, 0x2
	mov [rsp+8], rbx
	call File.set_buffering
	add rsp, 16
	sub rsp, 32
	lea rbx, [rsp+8552]
	mov [rsp+0], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+8], rbx
	mov rbx, [rsp+40]
	mov [rsp+16], rbx
	call JSON_Object.print
	add rsp, 32
	sub rsp, 16
	mov rbx, [rsp+24]
	mov [rsp+8], rbx
	call File.close
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rsp+8], rbx
	add rsp, 272
	sub rsp, 16
	lea rbx, [rsp+8264]
	mov [rsp+0], rbx
	call JSON_Object.free
	add rsp, 16
	sub rsp, 32
	mov rbx, STR32
	mov [rsp+8], rbx
	mov rbx, 0x2
	mov [rsp+16], rbx
	call File.open
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+8240], rbx
	mov rcx, [rsp+8240]
	test rcx, rcx
	sete bl
	test bl, bl
	je .L1
	mov rbx, 0xffffffffffffffff
	mov [rbp+16], rbx
	jmp .L0
	.L1:
	.L2:
	sub rsp, 32
	mov rbx, [rsp+8272]
	mov [rsp+8], rbx
	lea rbx, [rsp+80]
	mov [rsp+16], rbx
	mov rbx, 0x1fff
	mov [rsp+24], rbx
	call File.read
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+40], rbx
	lea rbx, [rsp+48]
	mov rcx, [rsp+40]
	xor sil, sil
	mov [rbx+rcx*1], sil
	lea rbx, [rsp+8]
	sub rsp, 16
	mov [rsp+0], rbx
	lea rbx, [rsp+64]
	mov [rsp+8], rbx
	call JSON.parse
	add rsp, 16
	mov cl, BYTE [JSON+16]
	test cl, cl
	sete bl
	test bl, bl
	je .L3
	sub rsp, 16
	mov rbx, STR33
	mov [rsp+0], rbx
	call error
	add rsp, 16
	.L3:
	.L4:
	lea rcx, [rsp+8]
	mov rbx, [rcx+24]
	mov rcx, 0x5
	cmp rbx, rcx
	setne bl
	test bl, bl
	je .L5
	sub rsp, 16
	mov rbx, STR34
	mov [rsp+0], rbx
	call error
	add rsp, 16
	.L5:
	.L6:
	sub rsp, 16
	mov rbx, STR35
	mov [rsp+0], rbx
	call println
	add rsp, 16
	sub rsp, 16
	xor rbx, rbx
	mov [rsp+8], rbx
	.L7:
	mov rbx, [rsp+8]
	lea rsi, [rsp+24]
	mov rcx, [rsi+8]
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L9
	sub rsp, 16
	lea rsi, [rsp+40]
	mov rcx, [rsi+0]
	mov rsi, [rsp+24]
	shl rsi, 2
	lea rbx, [rcx+rsi*8]
	mov [rsp+8], rbx
	mov rcx, [rsp+8]
	mov rbx, [rcx+24]
	mov rcx, 0x6
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L10
	sub rsp, 16
	sub rsp, 32
	mov rbx, [rsp+56]
	mov [rsp+8], rbx
	mov rbx, STR36
	mov [rsp+16], rbx
	call JSON_Object.get
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+8], rbx
	sub rsp, 32
	mov rbx, [rsp+56]
	mov [rsp+8], rbx
	mov rbx, STR37
	mov [rsp+16], rbx
	call JSON_Object.get
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+0], rbx
	mov rcx, [rsp+8]
	test rcx, rcx
	sete bl
	test bl, bl
	jne .L16
	mov rsi, [rsp+8]
	mov rcx, [rsi+24]
	mov rsi, 0x4
	cmp rcx, rsi
	setne bl
	.L16:
	test bl, bl
	jne .L15
	mov rcx, [rsp+0]
	test rcx, rcx
	sete bl
	.L15:
	test bl, bl
	jne .L14
	mov rsi, [rsp+0]
	mov rcx, [rsi+24]
	mov rsi, 0x4
	cmp rcx, rsi
	setne bl
	.L14:
	test bl, bl
	je .L12
	sub rsp, 16
	mov rbx, STR38
	mov [rsp+0], rbx
	call error
	add rsp, 16
	.L12:
	.L13:
	sub rsp, 48
	mov rbx, STR39
	mov [rsp+0], rbx
	sub rsp, 48
	mov rcx, [rsp+104]
	mov rbx, [rcx]
	mov [rsp+8], rbx
	mov bl, 0x22
	mov [rsp+16], bl
	mov rbx, 0xffffffffffffffff
	mov [rsp+24], rbx
	xor bl, bl
	mov [rsp+32], bl
	call strfind
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rsp+8], rbx
	mov rcx, [rsp+56]
	mov rbx, [rcx]
	mov [rsp+16], rbx
	sub rsp, 48
	mov rcx, [rsp+96]
	mov rbx, [rcx]
	mov [rsp+8], rbx
	mov bl, 0x22
	mov [rsp+16], bl
	mov rbx, 0xffffffffffffffff
	mov [rsp+24], rbx
	xor bl, bl
	mov [rsp+32], bl
	call strfind
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rsp+24], rbx
	mov rcx, [rsp+48]
	mov rbx, [rcx]
	mov [rsp+32], rbx
	call println
	add rsp, 48
	add rsp, 16
	.L10:
	.L11:
	add rsp, 16
	.L8:
	mov rbx, [rsp+8]
	inc QWORD [rsp+8]
	jmp .L7
	.L9:
	add rsp, 16
	sub rsp, 16
	mov rbx, [rsp+8256]
	mov [rsp+8], rbx
	call File.close
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rsp+8240], rbx
	sub rsp, 16
	lea rbx, [rsp+24]
	mov [rsp+0], rbx
	call JSON.free
	add rsp, 16
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


section .data align=16
__FP_TMP: times 4 dq 0
__GP_TMP: times 4 dq 0
extern stdout:data
extern stdin:data
extern File:data
extern fixed:data
extern string:data
extern vector:data
global JSON:data
JSON:
dq 0
dq 0
db 1
times 7 db 0


section .rodata align=16
__FABS_MASKd: dq 0x7FFFFFFFFFFFFFFF, 0
__FABS_MASKs: dd 0x7FFFFFFF, 0, 0, 0
__FNEG_MASKd: dq 0x8000000000000000, 0
__FNEG_MASKs: dd 0x80000000, 0, 0, 0
STR0:
db "%*s",10,"",0
db 0
STR1:
db "Expected ] at the end of array term at line %u, got %c instead",0
times 7 db 0
STR2:
db "Expected string for key at line %u",0
times 3 db 0
STR3:
db "Expected : after key at line %u, got %c instead",0
times 6 db 0
STR4:
db "Expected } at the end of object term at line %u, got %c instead",0
times 6 db 0
STR5:
db "true",0
db 0
STR6:
db "false",0
STR7:
db "null",0
db 0
STR8:
db "Unsupported JSON term at line %u: %*s",0
STR9:
db "%i",0
times 3 db 0
STR10:
db "%f",0
times 3 db 0
STR11:
db "%b",0
times 3 db 0
STR12:
db "",34,"%*s",34,"",0
STR13:
db "<INVALID %u>",0
db 0
STR14:
db "",0
times 5 db 0
STR15:
db "JSON_Array.append(%u) : no more memory",0
times 7 db 0
STR16:
db "JSON_Array.print(JSON.spaced, f) : f is not a line buffered file!",10,"If spacing is used, line buffering is necessary!",0
times 3 db 0
STR17:
db "%A",0
times 3 db 0
STR18:
db "[",0
dd 0
STR19:
db "",10,"%A",0
dw 0
STR20:
db "%*s",0
dw 0
STR21:
db ", ",0
times 3 db 0
STR22:
db "]",0
dd 0
STR23:
db "JSON_Object.append(%s, %u) : no more memory",0
dw 0
STR24:
db "{",0
dd 0
STR25:
db "",34,"%*s",34,"%*s",0
times 5 db 0
STR26:
db ": ",0
times 3 db 0
STR27:
db "}",0
dd 0
STR28:
db "test",0
db 0
STR29:
db "bro",0
dw 0
STR30:
db "Lebron james",0
db 0
STR31:
db "programs/assets/output.json",0
dw 0
STR32:
db "programs/assets/test.json",0
dd 0
STR33:
db "Failed to parse JSON!",0
STR34:
db "Expected array of items",0
times 6 db 0
STR35:
db "Analysing test.json ...",0
times 6 db 0
STR36:
db "id",0
times 3 db 0
STR37:
db "name",0
db 0
STR38:
db "Expected id and name in item",0
db 0
STR39:
db "Found %*s : %*s",0
times 6 db 0
FP0:
dq 0.0000000000
FP1:
dq 0.1000000000
FP2:
dq 67.6767000000
