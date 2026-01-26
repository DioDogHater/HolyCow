section .text
BITS 64
CPU X64
default ABS

global absi:function
absi:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+24]
	mov rcx, 0
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L1
	mov rbx, [rbp+24]
	neg rbx
	mov [rbp+16], rbx
	jmp .L0
	jmp .L2
	.L1:
	.L2:
	mov rbx, [rbp+24]
	mov [rbp+16], rbx
	jmp .L0
	.L0:
	leave
	ret

global absf:function
absf:
	push rbp
	mov rbp, rsp
	fld QWORD [rbp+24]
    fabs
    fstp QWORD [rbp+16]
	.L0:
	leave
	ret

global random:function
random:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	mov rcx, [rbp+24]
	mov rax, 318
    mov rdi, rbx
    mov rsi, rcx
    xor rdx, rdx
    syscall
	.L0:
	leave
	ret

global randint:function
randint:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	sub rsp, 16
	lea rbx, [rsp+24]
	mov [rsp+0], rbx
	mov rbx, 8
	mov [rsp+8], rbx
	call random
	add rsp, 16
	mov rax, [rsp+8]
	mov rbx, [rbp+32]
	mov rcx, [rbp+24]
	sub rbx, rcx
	xor rdx, rdx
	idiv rbx
	mov rax, rdx
	mov rbx, [rbp+24]
	add rax, rbx
	mov [rbp+16], rax
	jmp .L0
	.L0:
	leave
	ret

global is_alpha:function
is_alpha:
	push rbp
	mov rbp, rsp
	mov bl, [rbp+17]
	mov cl, 'a'
	cmp bl, cl
	setae bl
	test bl, bl
	je .L2
	mov cl, [rbp+17]
	mov sil, 'z'
	cmp cl, sil
	setbe bl
	.L2:
	test bl, bl
	jne .L1
	mov cl, [rbp+17]
	mov sil, 'A'
	cmp cl, sil
	setae bl
	test bl, bl
	je .L3
	mov cl, [rbp+17]
	mov sil, 'Z'
	cmp cl, sil
	setbe bl
	.L3:
	.L1:
	mov [rbp+16], bl
	jmp .L0
	.L0:
	leave
	ret

global is_num:function
is_num:
	push rbp
	mov rbp, rsp
	mov bl, [rbp+17]
	mov cl, '0'
	cmp bl, cl
	setae bl
	test bl, bl
	je .L1
	mov cl, [rbp+17]
	mov sil, '9'
	cmp cl, sil
	setbe bl
	.L1:
	mov [rbp+16], bl
	jmp .L0
	.L0:
	leave
	ret

global is_alnum:function
is_alnum:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov bl, [rbp+17]
	mov [rsp+1], bl
	call is_alpha
	mov bl, [rsp+0]
	add rsp, 16
	test bl, bl
	jne .L1
	sub rsp, 16
	mov bl, [rbp+17]
	mov [rsp+1], bl
	call is_num
	mov bl, [rsp+0]
	add rsp, 16
	.L1:
	mov [rbp+16], bl
	jmp .L0
	.L0:
	leave
	ret

global to_lower:function
to_lower:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov bl, [rbp+17]
	mov [rsp+1], bl
	call is_alpha
	mov bl, [rsp+0]
	add rsp, 16
	test bl, bl
	je .L1
	mov bl, [rbp+17]
	mov cl, 0b00100000
	or bl, cl
	mov [rbp+16], bl
	jmp .L0
	jmp .L2
	.L1:
	.L2:
	mov bl, [rbp+17]
	mov [rbp+16], bl
	jmp .L0
	.L0:
	leave
	ret

global to_upper:function
to_upper:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov bl, [rbp+17]
	mov [rsp+1], bl
	call is_alpha
	mov bl, [rsp+0]
	add rsp, 16
	test bl, bl
	je .L1
	mov bl, [rbp+17]
	mov cl, 0b11011111
	or bl, cl
	mov [rbp+16], bl
	jmp .L0
	jmp .L2
	.L1:
	.L2:
	mov bl, [rbp+17]
	mov [rbp+16], bl
	jmp .L0
	.L0:
	leave
	ret

global set_rounding:function
set_rounding:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	lea rbx, [rsp+14]
	fstcw [rbx]
	mov bx, [rsp+14]
	mov cx, 0xF3FF
	and bx, cx
	mov [rsp+14], bx
	mov bx, [rsp+14]
	movzx si, BYTE [rbp+16]
	mov cl, 8
	shl si, cl
	or bx, si
	mov [rsp+14], bx
	lea rbx, [rsp+14]
	fldcw [rbx]
	.L0:
	leave
	ret

global modf:function
modf:
	push rbp
	mov rbp, rsp
	fld QWORD [rbp+24]
    fld QWORD [rbp+32]
    fprem
    fstp QWORD [rbp+16]
    fstp st0
	.L0:
	leave
	ret

global sqrt:function
sqrt:
	push rbp
	mov rbp, rsp
	fld QWORD [rbp+24]
    fsqrt
    fstp QWORD [rbp+16]
	.L0:
	leave
	ret

global sin:function
sin:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	fld QWORD [rbp+24]
	fstp QWORD [rsp+8]
	fld QWORD [FP0]
	fstp QWORD [rsp+16]
	call modf
	fld QWORD [rsp+0]
	add rsp, 32
	fstp QWORD [rbp+24]
	fld QWORD [rbp+24]
    fsin
    fstp QWORD [rbp+16]
	.L0:
	leave
	ret

global cos:function
cos:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	fld QWORD [rbp+24]
	fstp QWORD [rsp+8]
	fld QWORD [FP1]
	fstp QWORD [rsp+16]
	call modf
	fld QWORD [rsp+0]
	add rsp, 32
	fstp QWORD [rbp+24]
	fld QWORD [rbp+24]
    fcos
    fstp QWORD [rbp+16]
	.L0:
	leave
	ret

global tan:function
tan:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	fld QWORD [rbp+24]
	fstp QWORD [rsp+8]
	fld QWORD [FP2]
	fstp QWORD [rsp+16]
	call modf
	fld QWORD [rsp+0]
	add rsp, 32
	fstp QWORD [rbp+24]
	fld QWORD [rbp+24]
    fptan
    fstp st0
    fstp QWORD [rbp+16]
	.L0:
	leave
	ret

global atan2:function
atan2:
	push rbp
	mov rbp, rsp
	fld QWORD [rbp+24]
    fld QWORD [rbp+32]
    fpatan
    fstp QWORD [rbp+16]
	.L0:
	leave
	ret

global round:function
round:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov bl, [rbp+32]
	mov [rsp+0], bl
	call set_rounding
	add rsp, 16
	fld QWORD [rbp+24]
    frndint
    fstp QWORD [rbp+16]
	sub rsp, 16
	mov bl, 0x0C
	mov [rsp+0], bl
	call set_rounding
	add rsp, 16
	.L0:
	leave
	ret

global int_to_fixed:function
int_to_fixed:
	push rbp
	mov rbp, rsp
	mov ebx, [rbp+24]
	mov cl, 15
	shl ebx, cl
	mov [rbp+16], ebx
	jmp .L0
	.L0:
	leave
	ret

global fraction_to_fixed:function
fraction_to_fixed:
	push rbp
	mov rbp, rsp
	mov rax, [rbp+24]
	mov cl, 30
	shl rax, cl
	mov rbx, [rbp+32]
	xor rdx, rdx
	idiv rbx
	mov [rbp+16], eax
	jmp .L0
	.L0:
	leave
	ret

global string_to_fixed:function
string_to_fixed:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, [rbp+32]
	mov rcx, 1
	neg rcx
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L1
	sub rsp, 16
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	call strlen
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rbp+32], rbx
	jmp .L2
	.L1:
	.L2:
	mov ebx, 0
	mov [rsp+12], ebx
	mov ebx, 0
	mov [rsp+8], ebx
	mov ebx, 1
	mov [rsp+4], ebx
	mov bl, 0
	mov [rsp+3], bl
	mov bl, 0
	mov [rsp+2], bl
	.L3:
	mov rbx, [rbp+32]
	test rbx, rbx
	je .L5
	mov rbx, [rbp+24]
	mov cl, [rbx]
	mov bl, '-'
	cmp cl, bl
	sete bl
	test bl, bl
	je .L6
	mov cl, [rsp+3]
	test cl, cl
	sete bl
	mov [rsp+3], bl
	jmp .L7
	.L6:
	mov rbx, [rbp+24]
	mov cl, [rbx]
	mov bl, '0'
	cmp cl, bl
	setae bl
	test bl, bl
	je .L9
	mov rcx, [rbp+24]
	mov sil, [rcx]
	mov cl, '9'
	cmp sil, cl
	setbe bl
	.L9:
	test bl, bl
	je .L8
	mov bl, [rsp+2]
	test bl, bl
	je .L10
	mov eax, [rsp+8]
	mov ebx, 10
	imul ebx
	mov rcx, [rbp+24]
	movsx ebx, BYTE [rcx]
	mov ecx, '0'
	sub ebx, ecx
	mov cl, 15
	shl ebx, cl
	add eax, ebx
	mov [rsp+8], eax
	mov eax, [rsp+4]
	mov ebx, 10
	imul ebx
	mov [rsp+4], eax
	jmp .L11
	.L10:
	mov eax, [rsp+12]
	mov ebx, 10
	imul ebx
	mov rcx, [rbp+24]
	movsx ebx, BYTE [rcx]
	mov ecx, '0'
	sub ebx, ecx
	mov cl, 15
	shl ebx, cl
	add eax, ebx
	mov [rsp+12], eax
	.L11:
	jmp .L7
	.L8:
	mov rbx, [rbp+24]
	mov cl, [rbx]
	mov bl, '.'
	cmp cl, bl
	sete bl
	test bl, bl
	je .L12
	mov bl, 1
	mov [rsp+2], bl
	jmp .L7
	.L12:
	.L7:
	.L4:
	mov rbx, [rbp+24]
	inc rbx
	mov [rbp+24], rbx
	mov rbx, [rbp+32]
	dec rbx
	mov [rbp+32], rbx
	jmp .L3
	.L5:
	mov ebx, [rsp+12]
	mov eax, [rsp+8]
	mov ecx, [rsp+4]
	xor rdx, rdx
	idiv ecx
	mov ecx, 0x00007FFF
	and eax, ecx
	add ebx, eax
	mov [rsp+12], ebx
	mov bl, [rsp+3]
	test bl, bl
	je .L13
	mov ebx, [rsp+12]
	neg ebx
	mov [rsp+12], ebx
	jmp .L14
	.L13:
	.L14:
	mov ebx, [rsp+12]
	mov [rbp+16], ebx
	jmp .L0
	.L0:
	leave
	ret

global fixed_to_int:function
fixed_to_int:
	push rbp
	mov rbp, rsp
	movsx rbx, DWORD [rbp+24]
	mov cl, 15
	sar rbx, cl
	mov [rbp+16], rbx
	jmp .L0
	.L0:
	leave
	ret

global mul_fixed:function
mul_fixed:
	push rbp
	mov rbp, rsp
	movsx rax, DWORD [rbp+20]
	movsx rbx, DWORD [rbp+24]
	imul rbx
	mov cl, 15
	sar rax, cl
	mov [rbp+16], eax
	jmp .L0
	.L0:
	leave
	ret

global div_fixed:function
div_fixed:
	push rbp
	mov rbp, rsp
	movsx rax, DWORD [rbp+20]
	mov cl, 15
	shl rax, cl
	movsx rbx, DWORD [rbp+24]
	xor rdx, rdx
	idiv rbx
	mov [rbp+16], eax
	jmp .L0
	.L0:
	leave
	ret

global mod_fixed:function
mod_fixed:
	push rbp
	mov rbp, rsp
	movsx rax, DWORD [rbp+20]
	mov cl, 15
	shl rax, cl
	movsx rbx, DWORD [rbp+24]
	xor rdx, rdx
	idiv rbx
	mov rax, rdx
	mov [rbp+16], eax
	jmp .L0
	.L0:
	leave
	ret

global memset:function
memset:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	mov cl, [rbp+24]
	mov rsi, [rbp+32]
	mov rdi, rbx
    mov al, cl
    mov rcx, rsi
    cld
    rep stosb
	.L0:
	leave
	ret

global memcpy:function
memcpy:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	mov r8, [rbp+24]
	mov r9, [rbp+32]
	mov rdi, rbx
    mov rsi, r8
    mov rcx, r9
    cld
    rep movsb
	.L0:
	leave
	ret

global strlen:function
strlen:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+24]
	lea rsi, [rbp+16]
	xor al, al
    mov rdi, rbx
    mov rcx, ~0
    cld
    repne scasb
    not rcx
    dec rcx
    mov [rsi], rcx
	.L0:
	leave
	ret

global strfind:function
strfind:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+40]
	mov rcx, 1
	neg rcx
	cmp rbx, rcx
	setne bl
	test bl, bl
	je .L1
	mov bl, [rbp+32]
	mov rsi, [rbp+24]
	mov r8, [rbp+40]
	mov r9, 1
	add r8, r9
	lea r9, [rbp+16]
	mov al, bl
    mov rdi, rsi
    mov rcx, r8
    cld
    repne scasb
    sub r8, rcx
    dec r8
    mov [r9], r8
	jmp .L2
	.L1:
	mov bl, [rbp+32]
	mov rsi, [rbp+24]
	lea r8, [rbp+16]
	mov al, bl
    mov rdi, rsi
    mov rcx, ~0
    cld
    repne scasb
    not rcx
    dec rcx
    mov [r8], rcx
	.L2:
	.L0:
	leave
	ret

global flush_stdout:function
flush_stdout:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov rbx, 1
	mov [rsp+8], rbx
	mov rbx, stdout_buff
	mov [rsp+16], rbx
	mov rbx, QWORD [stdout_cursor]
	mov [rsp+24], rbx
	call write
	mov rbx, [rsp+0]
	add rsp, 32
	mov rbx, 0
	mov [stdout_cursor], rbx
	.L0:
	leave
	ret

global print_str:function
print_str:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+24]
	mov rcx, 1
	neg rcx
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L1
	sub rsp, 16
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	call strlen
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rbp+24], rbx
	jmp .L2
	.L1:
	.L2:
	mov rbx, [rbp+24]
	.L3:
	test rbx, rbx
	je .L5
	mov rcx, stdout_buff
	mov rsi, QWORD [stdout_cursor]
	inc rsi
	mov [stdout_cursor], rsi
	dec rsi
	mov rdi, [rbp+16]
	mov r8b, [rdi]
	mov [rcx+rsi*1], r8b
	mov rcx, [rbp+16]
	mov sil, [rcx]
	mov cl, 10
	cmp sil, cl
	sete cl
	test cl, cl
	je .L6
	sub rsp, 16
	mov [rsp+8], rbx
	call flush_stdout
	mov rbx, [rsp+8]
	add rsp, 16
	jmp .L7
	.L6:
	.L7:
	mov rcx, [rbp+16]
	inc rcx
	mov [rbp+16], rcx
	.L4:
	dec rbx
	jmp .L3
	.L5:
	.L0:
	leave
	ret

global print_char:function
print_char:
	push rbp
	mov rbp, rsp
	mov rbx, stdout_buff
	mov rcx, QWORD [stdout_cursor]
	inc rcx
	mov [stdout_cursor], rcx
	dec rcx
	mov sil, [rbp+16]
	mov [rbx+rcx*1], sil
	mov bl, [rbp+16]
	mov cl, 10
	cmp bl, cl
	sete bl
	test bl, bl
	je .L1
	call flush_stdout
	jmp .L2
	.L1:
	.L2:
	.L0:
	leave
	ret

global print_decimal:function
print_decimal:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	sub rsp, 16
	sub rsp, 48
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	lea rbx, [rsp+64]
	mov [rsp+16], rbx
	mov rbx, 32
	mov [rsp+24], rbx
	mov bl, 0
	mov [rsp+32], bl
	call int_to_string
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rsp+0], rbx
	mov rbx, 1
	neg rbx
	mov [rsp+8], rbx
	call print_str
	add rsp, 16
	.L0:
	leave
	ret

global print_udecimal:function
print_udecimal:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	sub rsp, 16
	sub rsp, 48
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	lea rbx, [rsp+64]
	mov [rsp+16], rbx
	mov rbx, 32
	mov [rsp+24], rbx
	mov bl, 0
	mov [rsp+32], bl
	call uint_to_string
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rsp+0], rbx
	mov rbx, 1
	neg rbx
	mov [rsp+8], rbx
	call print_str
	add rsp, 16
	.L0:
	leave
	ret

global print_hex:function
print_hex:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	lea rbx, [rsp+16]
	mov rcx, 31
	mov sil, 0
	mov [rbx+rcx*1], sil
	mov rbx, STR0
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	mov rcx, 30
	add rbx, rcx
	mov [rsp+0], rbx
	mov rbx, [rbp+16]
	mov rcx, 0
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L1
	mov rbx, [rsp+0]
	dec rbx
	mov [rsp+0], rbx
	inc rbx
	mov cl, '0'
	mov [rbx], cl
	jmp .L2
	.L1:
	.L2:
	.L3:
	mov rbx, [rbp+16]
	test rbx, rbx
	je .L5
	mov rbx, [rsp+0]
	mov rcx, [rsp+8]
	mov rsi, [rbp+16]
	mov rdi, 0xF
	and rsi, rdi
	mov dil, [rcx+rsi*1]
	mov [rbx], dil
	.L4:
	mov rbx, [rbp+16]
	mov cl, 4
	shr rbx, cl
	mov [rbp+16], rbx
	mov rbx, [rsp+0]
	dec rbx
	mov [rsp+0], rbx
	jmp .L3
	.L5:
	mov rbx, [rsp+0]
	dec rbx
	mov [rsp+0], rbx
	inc rbx
	mov cl, 'x'
	mov [rbx], cl
	mov rbx, [rsp+0]
	mov cl, '0'
	mov [rbx], cl
	sub rsp, 16
	mov rbx, [rsp+16]
	mov [rsp+0], rbx
	mov rbx, 1
	neg rbx
	mov [rsp+8], rbx
	call print_str
	add rsp, 16
	.L0:
	leave
	ret

global print_fixed:function
print_fixed:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	mov ebx, [rbp+16]
	mov ecx, 0
	cmp ebx, ecx
	setl bl
	test bl, bl
	je .L1
	sub rsp, 16
	mov bl, '-'
	mov [rsp+0], bl
	call print_char
	add rsp, 16
	mov ebx, [rbp+16]
	neg ebx
	mov [rbp+16], ebx
	jmp .L2
	.L1:
	.L2:
	movzx rbx, DWORD [rbp+16]
	mov cl, 15
	shr rbx, cl
	mov [rsp+40], rbx
	movzx rax, DWORD [rbp+16]
	mov rbx, 0x00007FFF
	and rax, rbx
	mov rbx, 10000
	mul rbx
	mov rbx, 1
	mov cl, 15
	shl rbx, cl
	xor rdx, rdx
	div rbx
	mov [rsp+32], rax
	sub rsp, 16
	mov rbx, [rsp+56]
	mov [rsp+0], rbx
	call print_udecimal
	add rsp, 16
	sub rsp, 16
	mov bl, '.'
	mov [rsp+0], bl
	call print_char
	add rsp, 16
	sub rsp, 16
	sub rsp, 48
	mov rbx, [rsp+96]
	mov [rsp+8], rbx
	lea rbx, [rsp+64]
	mov [rsp+16], rbx
	mov rbx, 5
	mov [rsp+24], rbx
	mov bl, '0'
	mov [rsp+32], bl
	call uint_to_string
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rsp+0], rbx
	mov rbx, 1
	neg rbx
	mov [rsp+8], rbx
	call print_str
	add rsp, 16
	.L0:
	leave
	ret

global print_float:function
print_float:
	push rbp
	mov rbp, rsp
	sub rsp, 64
	fld QWORD [FP3]
	fld QWORD [rbp+16]
	fcomip
	fstp st0
	setb bl
	mov [rsp+31], bl
	mov bl, [rsp+31]
	test bl, bl
	je .L1
	sub rsp, 16
	mov bl, '-'
	mov [rsp+0], bl
	call print_char
	add rsp, 16
	fld QWORD [rbp+16]
	fchs
	fstp QWORD [rbp+16]
	jmp .L2
	.L1:
	.L2:
	fld QWORD [rbp+16]
	sub rsp, 8
	fistp QWORD [rsp]
	pop rbx
	mov [rsp+16], rbx
	fld QWORD [rbp+16]
	mov rcx, [rsp+16]
	push rcx
	fild QWORD [rsp]
	add rsp, 8
	fsubp
	fld QWORD [FP4]
	fmulp
	sub rsp, 8
	fistp QWORD [rsp]
	pop rbx
	mov [rsp+8], rbx
	sub rsp, 16
	mov bl, 0x0C
	mov [rsp+0], bl
	call set_rounding
	add rsp, 16
	sub rsp, 16
	mov rbx, [rsp+32]
	mov [rsp+0], rbx
	call print_udecimal
	add rsp, 16
	sub rsp, 16
	mov bl, '.'
	mov [rsp+0], bl
	call print_char
	add rsp, 16
	sub rsp, 16
	sub rsp, 48
	mov rbx, [rsp+72]
	mov [rsp+8], rbx
	lea rbx, [rsp+96]
	mov [rsp+16], rbx
	mov rbx, 5
	mov [rsp+24], rbx
	mov bl, '0'
	mov [rsp+32], bl
	call uint_to_string
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rsp+0], rbx
	mov rbx, 1
	neg rbx
	mov [rsp+8], rbx
	call print_str
	add rsp, 16
	.L0:
	leave
	ret

global print_format:function
print_format:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, 0
	mov [rsp+8], rbx
	sub rsp, 16
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	call strlen
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rsp+0], rbx
	sub rsp, 16
	.L1:
	mov rbx, [rsp+16]
	test rbx, rbx
	je .L2
	sub rsp, 32
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	mov bl, '%'
	mov [rsp+16], bl
	mov rbx, [rsp+48]
	mov [rsp+24], rbx
	call strfind
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+8], rbx
	mov rbx, [rsp+8]
	test rbx, rbx
	je .L3
	sub rsp, 16
	mov rbx, [rbp+16]
	mov [rsp+0], rbx
	mov rbx, [rsp+24]
	mov [rsp+8], rbx
	call print_str
	add rsp, 16
	jmp .L4
	.L3:
	mov rbx, [rbp+16]
	mov rcx, 1
	add rbx, rcx
	mov cl, [rbx]
	mov bl, 'i'
	cmp cl, bl
	sete bl
	test bl, bl
	je .L5
	sub rsp, 16
	mov rbx, [rbp+24]
	mov rcx, [rsp+40]
	inc rcx
	mov [rsp+40], rcx
	dec rcx
	mov rsi, [rbx+rcx*8]
	mov [rsp+0], rsi
	call print_decimal
	add rsp, 16
	jmp .L4
	.L5:
	mov rbx, [rbp+16]
	mov rcx, 1
	add rbx, rcx
	mov cl, [rbx]
	mov bl, 'u'
	cmp cl, bl
	sete bl
	test bl, bl
	je .L6
	sub rsp, 16
	mov rbx, [rbp+24]
	mov rcx, [rsp+40]
	inc rcx
	mov [rsp+40], rcx
	dec rcx
	mov rsi, [rbx+rcx*8]
	mov [rsp+0], rsi
	call print_udecimal
	add rsp, 16
	jmp .L4
	.L6:
	mov rbx, [rbp+16]
	mov rcx, 1
	add rbx, rcx
	mov cl, [rbx]
	mov bl, 'x'
	cmp cl, bl
	sete bl
	test bl, bl
	je .L7
	sub rsp, 16
	mov rbx, [rbp+24]
	mov rcx, [rsp+40]
	inc rcx
	mov [rsp+40], rcx
	dec rcx
	mov rsi, [rbx+rcx*8]
	mov [rsp+0], rsi
	call print_hex
	add rsp, 16
	jmp .L4
	.L7:
	mov rbx, [rbp+16]
	mov rcx, 1
	add rbx, rcx
	mov cl, [rbx]
	mov bl, 's'
	cmp cl, bl
	sete bl
	test bl, bl
	je .L8
	sub rsp, 16
	mov rbx, [rbp+24]
	mov rcx, [rsp+40]
	inc rcx
	mov [rsp+40], rcx
	dec rcx
	mov rsi, [rbx+rcx*8]
	mov [rsp+0], rsi
	mov rbx, 1
	neg rbx
	mov [rsp+8], rbx
	call print_str
	add rsp, 16
	jmp .L4
	.L8:
	mov rbx, [rbp+16]
	mov rcx, 1
	add rbx, rcx
	mov cl, [rbx]
	mov bl, 'c'
	cmp cl, bl
	sete bl
	test bl, bl
	je .L9
	sub rsp, 16
	mov rbx, [rbp+24]
	mov rcx, [rsp+40]
	inc rcx
	mov [rsp+40], rcx
	dec rcx
	mov sil, [rbx+rcx*8]
	mov [rsp+0], sil
	call print_char
	add rsp, 16
	jmp .L4
	.L9:
	mov rbx, [rbp+16]
	mov rcx, 1
	add rbx, rcx
	mov cl, [rbx]
	mov bl, 'b'
	cmp cl, bl
	sete bl
	test bl, bl
	je .L10
	mov rbx, [rbp+24]
	mov rcx, [rsp+24]
	inc rcx
	mov [rsp+24], rcx
	dec rcx
	mov rsi, [rbx+rcx*8]
	test rsi, rsi
	je .L11
	sub rsp, 16
	mov rbx, STR1
	mov [rsp+0], rbx
	mov rbx, 1
	neg rbx
	mov [rsp+8], rbx
	call print_str
	add rsp, 16
	jmp .L12
	.L11:
	sub rsp, 16
	mov rbx, STR2
	mov [rsp+0], rbx
	mov rbx, 1
	neg rbx
	mov [rsp+8], rbx
	call print_str
	add rsp, 16
	.L12:
	jmp .L4
	.L10:
	mov rbx, [rbp+16]
	mov rcx, 1
	add rbx, rcx
	mov cl, [rbx]
	mov bl, 'F'
	cmp cl, bl
	sete bl
	test bl, bl
	je .L13
	sub rsp, 16
	mov rbx, [rbp+24]
	mov rcx, [rsp+40]
	inc rcx
	mov [rsp+40], rcx
	dec rcx
	mov esi, [rbx+rcx*8]
	mov [rsp+0], esi
	call print_fixed
	add rsp, 16
	jmp .L4
	.L13:
	mov rbx, [rbp+16]
	mov rcx, 1
	add rbx, rcx
	mov cl, [rbx]
	mov bl, 'f'
	cmp cl, bl
	sete bl
	test bl, bl
	je .L14
	sub rsp, 16
	mov rbx, [rbp+24]
	mov rcx, [rsp+40]
	inc rcx
	mov [rsp+40], rcx
	dec rcx
	fld QWORD [rbx+rcx*8]
	fstp QWORD [rsp+0]
	call print_float
	add rsp, 16
	jmp .L4
	.L14:
	mov rbx, [rbp+16]
	mov rcx, 1
	add rbx, rcx
	mov cl, [rbx]
	mov bl, '%'
	cmp cl, bl
	sete bl
	test bl, bl
	je .L15
	sub rsp, 16
	mov bl, '%'
	mov [rsp+0], bl
	call print_char
	add rsp, 16
	jmp .L4
	.L15:
	mov rbx, [rbp+16]
	mov rcx, 1
	add rbx, rcx
	mov cl, [rbx]
	mov bl, '*'
	cmp cl, bl
	sete bl
	test bl, bl
	je .L16
	sub rsp, 16
	mov rbx, [rbp+16]
	inc rbx
	mov [rbp+16], rbx
	mov rbx, [rbp+24]
	mov rcx, [rsp+40]
	inc rcx
	mov [rsp+40], rcx
	dec rcx
	mov rsi, [rbx+rcx*8]
	mov [rsp+8], rsi
	mov rbx, [rbp+16]
	mov rcx, 1
	add rbx, rcx
	mov cl, [rbx]
	mov bl, 's'
	cmp cl, bl
	sete bl
	test bl, bl
	je .L17
	sub rsp, 16
	mov rbx, [rbp+24]
	mov rcx, [rsp+56]
	inc rcx
	mov [rsp+56], rcx
	dec rcx
	mov rsi, [rbx+rcx*8]
	mov [rsp+0], rsi
	mov rbx, [rsp+24]
	mov [rsp+8], rbx
	call print_str
	add rsp, 16
	jmp .L18
	.L17:
	mov rbx, [rbp+16]
	mov rcx, 1
	add rbx, rcx
	mov cl, [rbx]
	mov bl, 'c'
	cmp cl, bl
	sete bl
	test bl, bl
	je .L19
	sub rsp, 16
	mov rbx, [rbp+24]
	mov rcx, [rsp+56]
	inc rcx
	mov [rsp+56], rcx
	dec rcx
	mov sil, [rbx+rcx*8]
	mov [rsp+15], sil
	mov rbx, [rsp+24]
	.L20:
	test rbx, rbx
	je .L22
	sub rsp, 16
	mov [rsp+8], rbx
	mov cl, [rsp+31]
	mov [rsp+0], cl
	call print_char
	mov rbx, [rsp+8]
	add rsp, 16
	.L21:
	dec rbx
	jmp .L20
	.L22:
	add rsp, 16
	jmp .L18
	.L19:
	sub rsp, 16
	mov rbx, STR3
	mov [rsp+0], rbx
	mov rbx, 1
	neg rbx
	mov [rsp+8], rbx
	call print_str
	add rsp, 16
	sub rsp, 16
	mov rbx, [rbp+16]
	mov rcx, 1
	sub rbx, rcx
	mov [rsp+0], rbx
	mov rbx, 2
	mov [rsp+8], rbx
	call print_str
	add rsp, 16
	sub rsp, 16
	mov bl, 10
	mov [rsp+0], bl
	call print_char
	add rsp, 16
	sub rsp, 16
	mov rbx, 1
	mov [rsp+0], rbx
	call exit
	add rsp, 16
	.L18:
	add rsp, 16
	jmp .L4
	.L16:
	sub rsp, 16
	mov rbx, STR4
	mov [rsp+0], rbx
	mov rbx, 1
	neg rbx
	mov [rsp+8], rbx
	call print_str
	add rsp, 16
	sub rsp, 16
	mov rbx, [rbp+16]
	mov rcx, 1
	add rbx, rcx
	mov cl, [rbx]
	mov [rsp+0], cl
	call print_char
	add rsp, 16
	sub rsp, 16
	mov bl, 10
	mov [rsp+0], bl
	call print_char
	add rsp, 16
	sub rsp, 16
	mov rbx, 1
	mov [rsp+0], rbx
	call exit
	add rsp, 16
	.L4:
	mov rbx, [rsp+8]
	test rbx, rbx
	je .L23
	mov rbx, [rbp+16]
	mov rcx, [rsp+8]
	add rbx, rcx
	mov [rbp+16], rbx
	mov rbx, [rsp+16]
	mov rcx, [rsp+8]
	sub rbx, rcx
	mov [rsp+16], rbx
	jmp .L24
	.L23:
	mov rbx, [rbp+16]
	mov rcx, 2
	add rbx, rcx
	mov [rbp+16], rbx
	mov rbx, [rsp+16]
	mov rcx, 2
	sub rbx, rcx
	mov [rsp+16], rbx
	.L24:
	jmp .L1
	.L2:
	add rsp, 16
	.L0:
	leave
	ret

global print:function
print:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, [rbp+16]
	mov [rsp+0], rbx
	lea rbx, [rbp+24]
	mov [rsp+8], rbx
	call print_format
	add rsp, 16
	.L0:
	leave
	ret

global println:function
println:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, [rbp+16]
	mov [rsp+0], rbx
	lea rbx, [rbp+24]
	mov [rsp+8], rbx
	call print_format
	add rsp, 16
	sub rsp, 16
	mov bl, 10
	mov [rsp+0], bl
	call print_char
	add rsp, 16
	.L0:
	leave
	ret

global error:function
error:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, [rbp+16]
	mov [rsp+0], rbx
	lea rbx, [rbp+24]
	mov [rsp+8], rbx
	call print_format
	add rsp, 16
	sub rsp, 16
	mov bl, 10
	mov [rsp+0], bl
	call print_char
	add rsp, 16
	sub rsp, 16
	mov rbx, 1
	neg rbx
	mov [rsp+0], rbx
	call exit
	add rsp, 16
	.L0:
	leave
	ret

global input:function
input:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	sub rsp, 32
	mov rbx, 0
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	mov rbx, [rbp+32]
	mov [rsp+24], rbx
	call read
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+8], rbx
	mov rbx, [rsp+8]
	mov rcx, 0
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L1
	sub rsp, 16
	mov rbx, STR5
	mov [rsp+0], rbx
	mov rbx, [rsp+24]
	mov [rsp+8], rbx
	call error
	add rsp, 16
	jmp .L2
	.L1:
	.L2:
	mov rbx, [rbp+24]
	mov rcx, [rsp+8]
	dec rcx
	mov [rsp+8], rcx
	mov sil, 0
	mov [rbx+rcx*1], sil
	mov rbx, [rsp+8]
	mov [rbp+16], rbx
	jmp .L0
	.L0:
	leave
	ret

global input_char:function
input_char:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov bx, 0
	mov [rsp+14], bx
	sub rsp, 32
	mov rbx, 0
	mov [rsp+8], rbx
	lea rbx, [rsp+46]
	mov [rsp+16], rbx
	mov rbx, 2
	mov [rsp+24], rbx
	call read
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+0], rbx
	mov rbx, [rsp+0]
	mov rcx, 0
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L1
	sub rsp, 16
	mov rbx, STR6
	mov [rsp+0], rbx
	mov rbx, [rsp+16]
	mov [rsp+8], rbx
	call error
	add rsp, 16
	jmp .L2
	.L1:
	.L2:
	mov bl, [rsp+14]
	mov [rbp+16], bl
	jmp .L0
	.L0:
	leave
	ret

global int_to_string:function
int_to_string:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rcx, [rbp+32]
	mov rsi, [rbp+40]
	dec rsi
	mov [rbp+40], rsi
	lea rbx, [rcx+rsi*1]
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov rcx, 0
	cmp rbx, rcx
	setl bl
	mov [rsp+7], bl
	mov bl, [rsp+7]
	test bl, bl
	je .L1
	mov rbx, [rbp+24]
	neg rbx
	mov [rbp+24], rbx
	jmp .L2
	.L1:
	.L2:
	mov rbx, [rsp+8]
	mov cl, 0
	mov [rbx], cl
	mov rbx, [rsp+8]
	dec rbx
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov rcx, 0
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L3
	mov rbx, [rsp+8]
	dec rbx
	mov [rsp+8], rbx
	inc rbx
	mov cl, '0'
	mov [rbx], cl
	jmp .L4
	.L3:
	.L4:
	.L5:
	mov rbx, [rbp+24]
	test rbx, rbx
	setne cl
	je .L8
	mov rbx, [rbp+40]
	test rbx, rbx
	setne cl
	.L8:
	test cl, cl
	je .L7
	mov rbx, [rsp+8]
	mov rax, [rbp+24]
	mov rcx, 10
	xor rdx, rdx
	idiv rcx
	mov rax, rdx
	mov cl, '0'
	add al, cl
	mov [rbx], al
	.L6:
	mov rax, [rbp+24]
	mov rbx, 10
	xor rdx, rdx
	idiv rbx
	mov [rbp+24], rax
	mov rbx, [rbp+40]
	dec rbx
	mov [rbp+40], rbx
	mov rbx, [rsp+8]
	dec rbx
	mov [rsp+8], rbx
	jmp .L5
	.L7:
	mov bl, [rbp+48]
	test bl, bl
	je .L9
	mov rbx, [rbp+40]
	.L11:
	test rbx, rbx
	je .L13
	mov rcx, [rsp+8]
	dec rcx
	mov [rsp+8], rcx
	inc rcx
	mov sil, [rbp+48]
	mov [rcx], sil
	.L12:
	dec rbx
	jmp .L11
	.L13:
	jmp .L10
	.L9:
	.L10:
	mov bl, [rsp+7]
	test bl, bl
	je .L14
	mov rbx, [rsp+8]
	dec rbx
	mov [rsp+8], rbx
	inc rbx
	mov cl, '-'
	mov [rbx], cl
	jmp .L15
	.L14:
	.L15:
	mov rbx, [rsp+8]
	mov rcx, 1
	add rbx, rcx
	mov [rbp+16], rbx
	jmp .L0
	.L0:
	leave
	ret

global uint_to_string:function
uint_to_string:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rcx, [rbp+32]
	mov rsi, [rbp+40]
	dec rsi
	mov [rbp+40], rsi
	lea rbx, [rcx+rsi*1]
	mov [rsp+8], rbx
	mov rbx, [rsp+8]
	mov cl, 0
	mov [rbx], cl
	mov rbx, [rsp+8]
	dec rbx
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov rcx, 0
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L1
	mov rbx, [rsp+8]
	dec rbx
	mov [rsp+8], rbx
	inc rbx
	mov cl, '0'
	mov [rbx], cl
	jmp .L2
	.L1:
	.L2:
	.L3:
	mov rbx, [rbp+24]
	test rbx, rbx
	setne cl
	je .L6
	mov rbx, [rbp+40]
	test rbx, rbx
	setne cl
	.L6:
	test cl, cl
	je .L5
	mov rbx, [rsp+8]
	mov rax, [rbp+24]
	mov rcx, 10
	xor rdx, rdx
	div rcx
	mov rax, rdx
	mov cl, '0'
	add al, cl
	mov [rbx], al
	.L4:
	mov rax, [rbp+24]
	mov rbx, 10
	xor rdx, rdx
	div rbx
	mov [rbp+24], rax
	mov rbx, [rbp+40]
	dec rbx
	mov [rbp+40], rbx
	mov rbx, [rsp+8]
	dec rbx
	mov [rsp+8], rbx
	jmp .L3
	.L5:
	mov bl, [rbp+48]
	test bl, bl
	je .L7
	mov rbx, [rbp+40]
	.L9:
	test rbx, rbx
	je .L11
	mov rcx, [rsp+8]
	dec rcx
	mov [rsp+8], rcx
	inc rcx
	mov sil, [rbp+48]
	mov [rcx], sil
	.L10:
	dec rbx
	jmp .L9
	.L11:
	jmp .L8
	.L7:
	.L8:
	mov rbx, [rsp+8]
	mov rcx, 1
	add rbx, rcx
	mov [rbp+16], rbx
	jmp .L0
	.L0:
	leave
	ret

global string_to_int:function
string_to_int:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, [rbp+32]
	mov rcx, 1
	neg rcx
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L1
	sub rsp, 16
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	call strlen
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rbp+32], rbx
	jmp .L2
	.L1:
	.L2:
	mov rbx, 0
	mov [rsp+8], rbx
	mov bl, 0
	mov [rsp+7], bl
	.L3:
	mov rbx, [rbp+32]
	test rbx, rbx
	je .L5
	mov rbx, [rbp+24]
	mov cl, [rbx]
	mov bl, '-'
	cmp cl, bl
	sete bl
	test bl, bl
	je .L6
	mov cl, [rsp+7]
	test cl, cl
	sete bl
	mov [rsp+7], bl
	jmp .L7
	.L6:
	mov rbx, [rbp+24]
	mov cl, [rbx]
	mov bl, '0'
	cmp cl, bl
	setae bl
	test bl, bl
	je .L9
	mov rcx, [rbp+24]
	mov sil, [rcx]
	mov cl, '9'
	cmp sil, cl
	setbe bl
	.L9:
	test bl, bl
	je .L8
	mov rax, [rsp+8]
	mov rbx, 10
	imul rbx
	mov rcx, [rbp+24]
	movsx rbx, BYTE [rcx]
	mov rcx, '0'
	sub rbx, rcx
	add rax, rbx
	mov [rsp+8], rax
	jmp .L7
	.L8:
	.L7:
	.L4:
	mov rbx, [rbp+24]
	inc rbx
	mov [rbp+24], rbx
	mov rbx, [rbp+32]
	dec rbx
	mov [rbp+32], rbx
	jmp .L3
	.L5:
	mov bl, [rsp+7]
	test bl, bl
	je .L10
	mov rbx, [rsp+8]
	neg rbx
	mov [rsp+8], rbx
	jmp .L11
	.L10:
	.L11:
	mov rbx, [rsp+8]
	mov [rbp+16], rbx
	jmp .L0
	.L0:
	leave
	ret

global read:function
read:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+24]
	mov rcx, [rbp+32]
	mov r8, [rbp+40]
	mov rax, 0
    mov rdi, rbx
    mov rsi, rcx
    mov rdx, r8
    syscall
    mov [rbp+16], rax
	.L0:
	leave
	ret

global write:function
write:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+24]
	mov rcx, [rbp+32]
	mov r8, [rbp+40]
	mov rax, 1
    mov rdi, rbx
    mov rsi, rcx
    mov rdx, r8
    syscall
    mov [rbp+16], rax
	.L0:
	leave
	ret

global exit:function
exit:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	mov rax, 60
    mov rdi, rbx
    syscall
	.L0:
	leave
	ret
extern main


section .data
stdout_buff:
times 1024 db 0
stdout_cursor:
dq 0


section .rodata
STR0:
db "0123456789ABCDEF",0
STR1:
db "true ",0
STR2:
db "false",0
STR3:
db "",10,"Unexpected format specifier %",0
STR4:
db "",10,"Unexpected format specifier %",0
STR5:
db "input() error: %i",0
STR6:
db "input_char() error: %i",0
FP0:
dq 6.28318530718
FP1:
dq 6.28318530718
FP2:
dq 6.28318530718
FP3:
dq 0.0
FP4:
dq 10000.0
