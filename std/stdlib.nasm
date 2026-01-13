
global memset
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

global memcpy
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

global strlen
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

global print_str
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
	mov rbx, [rbp+16]
	mov rcx, [rbp+24]
	mov rax, 1
    mov rdi, 1
    mov rsi, rbx
    mov rdx, rcx
    syscall
	.L0:
	leave
	ret

global print_decimal
print_decimal:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	sub rsp, 16
	sub rsp, 32
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	lea rbx, [rsp+48]
	mov [rsp+16], rbx
	mov rbx, 32
	mov [rsp+24], rbx
	call int_to_string
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+0], rbx
	mov rbx, 1
	neg rbx
	mov [rsp+8], rbx
	call print_str
	mov rbx, 0
	add rsp, 16
	.L0:
	leave
	ret

global print_hex
print_hex:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	mov bl, 0
	lea rcx, [rsp+16]
	mov rsi, 31
	mov [rcx+rsi*1], bl
	mov rbx, STR0
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	mov rcx, 30
	add rbx, rcx
	mov [rsp+0], rbx
	.L1:
	mov rbx, [rbp+16]
	test rbx, rbx
	je .L2
	mov rbx, [rsp+8]
	mov rcx, [rbp+16]
	mov rsi, 0xF
	and rcx, rsi
	mov sil, [rbx+rcx*1]
	mov rbx, [rsp+0]
	mov [rbx], sil
	mov rax, [rbp+16]
	mov rbx, 16
	xor rdx, rdx
	div rbx
	mov [rbp+16], rax
	mov rbx, [rsp+0]
	dec rbx
	mov [rsp+0], rbx
	jmp .L1
	.L2:
	mov bl, 'x'
	mov rcx, [rsp+0]
	dec rcx
	mov [rsp+0], rcx
	inc rcx
	mov [rcx], bl
	mov bl, '0'
	mov rcx, [rsp+0]
	mov [rcx], bl
	sub rsp, 16
	mov rbx, [rsp+16]
	mov [rsp+0], rbx
	mov rbx, 1
	neg rbx
	mov [rsp+8], rbx
	call print_str
	mov rbx, 0
	add rsp, 16
	.L0:
	leave
	ret

global input
input:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+24]
	mov rcx, [rbp+32]
	mov rax, 0
    mov rdi, 0
    mov rsi, rbx
    mov rdx, rcx
    syscall
    mov [rbp+16], rax
	.L0:
	leave
	ret

global int_to_string
int_to_string:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rcx, [rbp+32]
	mov rsi, [rbp+40]
	mov rdi, 1
	sub rsi, rdi
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
	mov bl, 0
	mov rcx, [rsp+8]
	mov [rcx], bl
	mov rbx, [rsp+8]
	dec rbx
	mov [rsp+8], rbx
	.L3:
	mov rbx, [rbp+24]
	test rbx, rbx
	setne cl
	je .L5
	mov rbx, [rsp+8]
	mov rsi, [rbp+32]
	sub rbx, rsi
	mov rsi, [rbp+40]
	cmp rbx, rsi
	setb bl
	and cl, bl
	.L5:
	test cl, cl
	je .L4
	mov al, [rbp+24]
	mov bl, 10
	xor ah, ah
	div bl
	mov al, ah
	mov bl, '0'
	add al, bl
	mov rbx, [rsp+8]
	mov [rbx], al
	mov rax, [rbp+24]
	mov rbx, 10
	xor rdx, rdx
	idiv rbx
	mov [rbp+24], rax
	mov rbx, [rsp+8]
	dec rbx
	mov [rsp+8], rbx
	inc rbx
	jmp .L3
	.L4:
	mov bl, [rsp+7]
	test bl, bl
	je .L6
	mov bl, '-'
	mov rcx, [rsp+8]
	dec rcx
	mov [rsp+8], rcx
	inc rcx
	mov [rcx], bl
	jmp .L7
	.L6:
	.L7:
	mov rbx, [rsp+8]
	mov rcx, 1
	add rbx, rcx
	mov [rbp+16], rbx
	jmp .L0
	.L0:
	leave
	ret

global string_to_int
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
	je .L4
	mov rbx, [rbp+24]
	mov cl, [rbx]
	mov bl, '-'
	cmp cl, bl
	sete bl
	test bl, bl
	je .L5
	mov bl, [rsp+7]
	test bl, bl
	sete cl
	mov [rsp+7], cl
	jmp .L6
	.L5:
	mov rbx, [rbp+24]
	mov cl, [rbx]
	mov bl, '0'
	cmp cl, bl
	setae bl
	test bl, bl
	je .L8
	mov rcx, [rbp+24]
	mov sil, [rcx]
	mov cl, '9'
	cmp sil, cl
	setbe cl
	and bl, cl
	.L8:
	test bl, bl
	je .L7
	mov rax, [rsp+8]
	mov rbx, 10
	imul rbx
	mov rcx, [rbp+24]
	movsx rbx, BYTE [rcx]
	mov rcx, '0'
	sub rbx, rcx
	add rax, rbx
	mov [rsp+8], rax
	jmp .L6
	.L7:
	.L6:
	mov rbx, [rbp+24]
	inc rbx
	mov [rbp+24], rbx
	mov rbx, [rbp+32]
	dec rbx
	mov [rbp+32], rbx
	jmp .L3
	.L4:
	mov bl, [rsp+7]
	test bl, bl
	je .L9
	mov rbx, [rsp+8]
	neg rbx
	mov [rsp+8], rbx
	jmp .L10
	.L9:
	.L10:
	mov rbx, [rsp+8]
	mov [rbp+16], rbx
	jmp .L0
	.L0:
	leave
	ret

global exit
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


section .rodata
STR0:
	db "0123456789ABCDEF",0
