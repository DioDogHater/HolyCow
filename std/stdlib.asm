section .text
BITS 64
CPU ALL
default REL

global syscall1:function
syscall1:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+24]
	mov rcx, [rbp+32]
	mov rax, rbx
         mov rdi, rcx
         syscall
         mov [rbp+16], rax
	mov rbx, [rbp+16]
	xor rcx, rcx
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L1
	mov rbx, [rbp+16]
	neg rbx
	mov [errno], rbx
	.L1:
	.L2:
	.L0:
	leave
	ret

global syscall2:function
syscall2:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+24]
	mov rcx, [rbp+32]
	mov r8, [rbp+40]
	mov rax, rbx
         mov rdi, rcx
         mov rsi, r8
         syscall
         mov [rbp+16], rax
	mov rbx, [rbp+16]
	xor rcx, rcx
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L1
	mov rbx, [rbp+16]
	neg rbx
	mov [errno], rbx
	.L1:
	.L2:
	.L0:
	leave
	ret

global syscall3:function
syscall3:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+24]
	mov rcx, [rbp+32]
	mov r8, [rbp+40]
	mov r9, [rbp+48]
	mov rax, rbx
         mov rdi, rcx
         mov rsi, r8
         mov rdx, r9
         syscall
         mov [rbp+16], rax
	mov rbx, [rbp+16]
	xor rcx, rcx
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L1
	mov rbx, [rbp+16]
	neg rbx
	mov [errno], rbx
	.L1:
	.L2:
	.L0:
	leave
	ret

global fcntl:function
fcntl:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	mov rbx, 0x48
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	mov rbx, [rbp+32]
	mov [rsp+24], rbx
	mov rbx, [rbp+40]
	mov [rsp+32], rbx
	call syscall3
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rbp+16], rbx
	.L0:
	leave
	ret

global read:function
read:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	xor rbx, rbx
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	mov rbx, [rbp+32]
	mov [rsp+24], rbx
	mov rbx, [rbp+40]
	mov [rsp+32], rbx
	call syscall3
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rbp+16], rbx
	.L0:
	leave
	ret

global write:function
write:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	mov rbx, 0x1
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	mov rbx, [rbp+32]
	mov [rsp+24], rbx
	mov rbx, [rbp+40]
	mov [rsp+32], rbx
	call syscall3
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rbp+16], rbx
	.L0:
	leave
	ret

global open:function
open:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	mov rbx, 0x2
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	mov rbx, [rbp+32]
	mov [rsp+24], rbx
	mov rbx, [rbp+40]
	mov [rsp+32], rbx
	call syscall3
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rbp+16], rbx
	.L0:
	leave
	ret

global exit:function
exit:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov rbx, 0x3c
	mov [rsp+8], rbx
	mov rbx, [rbp+16]
	mov [rsp+16], rbx
	call syscall1
	add rsp, 32
	.L0:
	leave
	ret

global socket:function
socket:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	mov rbx, 0x29
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	mov rbx, [rbp+32]
	mov [rsp+24], rbx
	mov rbx, [rbp+40]
	mov [rsp+32], rbx
	call syscall3
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rbp+16], rbx
	.L0:
	leave
	ret

global connect:function
connect:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	mov rbx, 0x2a
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	mov rbx, [rbp+32]
	mov [rsp+24], rbx
	mov rbx, [rbp+40]
	mov [rsp+32], rbx
	call syscall3
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rbp+16], rbx
	.L0:
	leave
	ret

global accept:function
accept:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	mov rbx, 0x2b
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	mov rbx, [rbp+32]
	mov [rsp+24], rbx
	mov rbx, [rbp+40]
	mov [rsp+32], rbx
	call syscall3
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rbp+16], rbx
	.L0:
	leave
	ret

global bind:function
bind:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	mov rbx, 0x31
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	mov rbx, [rbp+32]
	mov [rsp+24], rbx
	mov rbx, [rbp+40]
	mov [rsp+32], rbx
	call syscall3
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rbp+16], rbx
	.L0:
	leave
	ret

global listen:function
listen:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov rbx, 0x32
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	mov rbx, [rbp+32]
	mov [rsp+24], rbx
	call syscall2
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rbp+16], rbx
	.L0:
	leave
	ret

global close:function
close:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov rbx, 0x3
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	call syscall1
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rbp+16], rbx
	.L0:
	leave
	ret

global htonl:function
htonl:
	push rbp
	mov rbp, rsp
	mov ebx, [rbp+20]
	bswap ebx
	mov [rbp+16], ebx
	.L0:
	leave
	ret

global htons:function
htons:
	push rbp
	mov rbp, rsp
	mov bx, [rbp+20]
	mov ax, bx
	xchg al, ah	
mov bx, ax
	.L0:
	leave
	ret

global ioctl:function
ioctl:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	mov rbx, 0x10
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	mov rbx, [rbp+32]
	mov [rsp+24], rbx
	mov rbx, [rbp+40]
	mov [rsp+32], rbx
	call syscall3
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rbp+16], rbx
	jmp .L0
	.L0:
	leave
	ret

global tcgetattr:function
tcgetattr:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rbx, 0x5401
	mov [rsp+16], rbx
	mov rbx, [rbp+32]
	mov [rsp+24], rbx
	call ioctl
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rbp+16], rbx
	jmp .L0
	.L0:
	leave
	ret

global tcsetattr:function
tcsetattr:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+32]
	xor rcx, rcx
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L1
	sub rsp, 32
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rbx, 0x5402
	mov [rsp+16], rbx
	mov rbx, [rbp+40]
	mov [rsp+24], rbx
	call ioctl
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rbp+16], rbx
	jmp .L0
	jmp .L2
	.L1:
	mov rbx, [rbp+32]
	mov rcx, 0x1
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L3
	sub rsp, 32
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rbx, 0x5403
	mov [rsp+16], rbx
	mov rbx, [rbp+40]
	mov [rsp+24], rbx
	call ioctl
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rbp+16], rbx
	jmp .L0
	jmp .L2
	.L3:
	mov rbx, [rbp+32]
	mov rcx, 0x2
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L4
	sub rsp, 32
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rbx, 0x5404
	mov [rsp+16], rbx
	mov rbx, [rbp+40]
	mov [rsp+24], rbx
	call ioctl
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rbp+16], rbx
	jmp .L0
	jmp .L2
	.L4:
	.L2:
	mov rbx, 0xffffffffffffffff
	mov [rbp+16], rbx
	jmp .L0
	.L0:
	leave
	ret

global cfmakeraw:function
cfmakeraw:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	mov rsi, [rbp+16]
	mov ecx, [rsi+0]
	and ecx, 0xfffffa14
	mov [rbx+0], ecx
	mov rbx, [rbp+16]
	mov rsi, [rbp+16]
	mov ecx, [rsi+4]
	and ecx, 0xfffffffe
	mov [rbx+4], ecx
	mov rbx, [rbp+16]
	mov rsi, [rbp+16]
	mov ecx, [rsi+12]
	and ecx, 0xffff7fe4
	mov [rbx+12], ecx
	mov rbx, [rbp+16]
	mov rsi, [rbp+16]
	mov ecx, [rsi+8]
	and ecx, 0xffffecff
	mov [rbx+8], ecx
	mov rbx, [rbp+16]
	mov rsi, [rbp+16]
	mov ecx, [rsi+8]
	or ecx, 0x300
	mov [rbx+8], ecx
	mov rcx, [rbp+16]
	lea rbx, [rcx+16]
	mov rcx, 0x10
	mov sil, 0x1
	mov [rbx+rcx*1], sil
	mov rcx, [rbp+16]
	lea rbx, [rcx+16]
	mov rcx, 0x11
	xor sil, sil
	mov [rbx+rcx*1], sil
	.L0:
	leave
	ret

global nanosleep:function
nanosleep:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov rbx, 0x23
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	mov rbx, [rbp+32]
	mov [rsp+24], rbx
	call syscall2
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rbp+16], rbx
	jmp .L0
	.L0:
	leave
	ret

global sleep:function
sleep:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	lea rbx, [rsp+0]
	movsd xmm0, [rbp+16]
	cvttsd2si rcx, xmm0
	mov [rbx+0], rcx
	movsd xmm0, [rbp+16]
	movsd xmm1, [FP0]
	movsd xmm2, xmm0
	divsd xmm2, xmm1
	roundsd xmm2, xmm2, 0
	subsd xmm0, xmm2
	movsd xmm1, [FP1]
	mulsd xmm0, xmm1
	cvttsd2si rcx, xmm0
	mov [rbx+8], rcx
	sub rsp, 32
	lea rbx, [rsp+32]
	mov [rsp+8], rbx
	xor rbx, rbx
	mov [rsp+16], rbx
	call nanosleep
	add rsp, 32
	.L0:
	leave
	ret

global msleep:function
msleep:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	lea rbx, [rsp+0]
	mov rax, [rbp+16]
	mov rcx, 0x3e8
	xor rdx, rdx
	div rcx
	mov [rbx+0], rax
	mov rax, [rbp+16]
	mov rcx, 0x3e8
	xor rdx, rdx
	div rcx
	mov rax, rdx
	mov rcx, 0xf4240
	mul rcx
	mov [rbx+8], rax
	sub rsp, 32
	lea rbx, [rsp+32]
	mov [rsp+8], rbx
	xor rbx, rbx
	mov [rsp+16], rbx
	call nanosleep
	add rsp, 32
	.L0:
	leave
	ret

global usleep:function
usleep:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	lea rbx, [rsp+0]
	mov rax, [rbp+16]
	mov rcx, 0xf4240
	xor rdx, rdx
	div rcx
	mov [rbx+0], rax
	mov rax, [rbp+16]
	mov rcx, 0xf4240
	xor rdx, rdx
	div rcx
	mov rax, rdx
	mov rcx, 0x3e8
	mul rcx
	mov [rbx+8], rax
	sub rsp, 32
	lea rbx, [rsp+32]
	mov [rsp+8], rbx
	xor rbx, rbx
	mov [rsp+16], rbx
	call nanosleep
	add rsp, 32
	.L0:
	leave
	ret

global clock_gettime:function
clock_gettime:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov rbx, 0xe4
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	mov rbx, [rbp+32]
	mov [rsp+24], rbx
	call syscall2
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rbp+16], rbx
	jmp .L0
	.L0:
	leave
	ret

global time:function
time:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	sub rsp, 32
	xor rbx, rbx
	mov [rsp+8], rbx
	lea rbx, [rsp+32]
	mov [rsp+16], rbx
	call clock_gettime
	add rsp, 32
	mov rbx, [rsp+0]
	cvtsi2ss xmm0, rbx
	cvtss2sd xmm0, xmm0
	mov rbx, [rsp+8]
	cvtsi2ss xmm1, rbx
	cvtss2sd xmm1, xmm1
	movsd xmm2, [FP1]
	divsd xmm1, xmm2
	addsd xmm0, xmm1
	movsd [rbp+16], xmm0
	jmp .L0
	.L0:
	leave
	ret

global File.write:function
File.write:
	push rbp
	mov rbp, rsp
	mov rsi, [rbp+16]
	mov ecx, DWORD [rsi+36]
	and rcx, 0x1
	test rcx, rcx
	sete bl
	test bl, bl
	je .L1
	jmp .L0
	.L1:
	.L2:
	mov rcx, [rbp+16]
	mov ebx, DWORD [rcx+32]
	mov rcx, 0x3
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L3
	sub rsp, 32
	mov rcx, [rbp+16]
	mov rbx, [rcx+0]
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	mov rbx, [rbp+32]
	mov [rsp+24], rbx
	call write
	add rsp, 32
	jmp .L0
	.L3:
	.L4:
	mov rbx, [rbp+32]
	.L5:
	test rbx, rbx
	je .L7
	mov rsi, [rbp+16]
	mov rcx, [rsi+8]
	mov rdi, [rbp+16]
	lea rdi, [rdi+24]
	mov rsi, [rdi]
	inc QWORD [rdi]
	mov rdi, [rbp+24]
	mov r8b, [rdi]
	mov [rcx+rsi*1], r8b
	mov rsi, [rbp+16]
	mov ecx, DWORD [rsi+32]
	mov rsi, 0x2
	cmp rcx, rsi
	sete cl
	test cl, cl
	je .L10
	mov rsi, [rbp+24]
	mov dil, [rsi]
	mov sil, 0xa
	cmp dil, sil
	sete cl
	.L10:
	test cl, cl
	je .L8
	sub rsp, 16
	mov [rsp+8], rbx
	mov rbx, [rbp+16]
	mov [rsp+0], rbx
	call File.flush
	mov rbx, [rsp+8]
	add rsp, 16
	jmp .L9
	.L8:
	mov rsi, [rbp+16]
	mov rcx, [rsi+24]
	mov rdi, [rbp+16]
	mov rsi, [rdi+16]
	cmp rcx, rsi
	setae cl
	test cl, cl
	je .L11
	mov rsi, [rbp+16]
	mov rcx, [rsi+0]
	xor rsi, rsi
	cmp rcx, rsi
	setl cl
	test cl, cl
	je .L12
	jmp .L7
	.L12:
	.L13:
	sub rsp, 16
	mov [rsp+8], rbx
	mov rbx, [rbp+16]
	mov [rsp+0], rbx
	call File.flush
	mov rbx, [rsp+8]
	add rsp, 16
	jmp .L9
	.L11:
	.L9:
	inc QWORD [rbp+24]
	mov rcx, [rbp+24]
	.L6:
	dec rbx
	jmp .L5
	.L7:
	.L0:
	leave
	ret

global File.read:function
File.read:
	push rbp
	mov rbp, rsp
	mov rcx, [rbp+24]
	mov rbx, [rcx+0]
	xor rcx, rcx
	cmp rbx, rcx
	setl bl
	test bl, bl
	jne .L3
	mov rsi, [rbp+24]
	mov ecx, DWORD [rsi+36]
	and rcx, 0x2
	test rcx, rcx
	sete bl
	.L3:
	test bl, bl
	je .L1
	xor rbx, rbx
	mov [rbp+16], rbx
	jmp .L0
	.L1:
	.L2:
	sub rsp, 32
	mov rcx, [rbp+24]
	mov rbx, [rcx+0]
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	mov rbx, [rbp+40]
	mov [rsp+24], rbx
	call read
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rbp+16], rbx
	.L0:
	leave
	ret

global File.print:function
File.print:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov rbx, [rbp+24]
	mov [rsp+0], rbx
	lea rbx, [rbp+32]
	mov [rsp+8], rbx
	mov rbx, [rbp+16]
	mov [rsp+16], rbx
	call print_format
	add rsp, 32
	.L0:
	leave
	ret

global File.println:function
File.println:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov rbx, [rbp+24]
	mov [rsp+0], rbx
	lea rbx, [rbp+32]
	mov [rsp+8], rbx
	mov rbx, [rbp+16]
	mov [rsp+16], rbx
	call print_format
	add rsp, 32
	sub rsp, 32
	mov rbx, [rbp+16]
	mov [rsp+0], rbx
	mov rbx, STR0
	mov [rsp+8], rbx
	mov rbx, 0x1
	mov [rsp+16], rbx
	call File.write
	add rsp, 32
	.L0:
	leave
	ret

global File.set_buffering:function
File.set_buffering:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	mov rsi, [rbp+16]
	mov ecx, [rsi+36]
	and ecx, 0xf
	mov esi, [rbp+24]
	or ecx, esi
	mov [rbx+36], ecx
	.L0:
	leave
	ret

global File.set_buffer:function
File.set_buffer:
	push rbp
	mov rbp, rsp
	mov rcx, [rbp+24]
	test rcx, rcx
	sete bl
	test bl, bl
	je .L1
	sub rsp, 16
	mov rbx, [rbp+16]
	mov [rsp+0], rbx
	mov rbx, 0x3
	mov [rsp+8], rbx
	call File.set_buffering
	add rsp, 16
	.L1:
	.L2:
	mov rbx, [rbp+16]
	mov rcx, [rbp+24]
	mov [rbx+8], rcx
	mov rbx, [rbp+16]
	mov rcx, [rbp+32]
	mov [rbx+16], rcx
	.L0:
	leave
	ret

global File.flush:function
File.flush:
	push rbp
	mov rbp, rsp
	mov rcx, [rbp+16]
	mov rbx, [rcx+0]
	xor rcx, rcx
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L1
	jmp .L0
	.L1:
	.L2:
	mov rcx, [rbp+16]
	mov ebx, DWORD [rcx+36]
	and rbx, 0x1
	test rbx, rbx
	setne cl
	je .L5
	mov rsi, [rbp+16]
	mov ebx, DWORD [rsi+32]
	mov rsi, 0x3
	cmp rbx, rsi
	setne cl
	.L5:
	test cl, cl
	je .L3
	sub rsp, 32
	mov rcx, [rbp+16]
	mov rbx, [rcx+0]
	mov [rsp+8], rbx
	mov rcx, [rbp+16]
	mov rbx, [rcx+8]
	mov [rsp+16], rbx
	mov rcx, [rbp+16]
	mov rbx, [rcx+24]
	mov [rsp+24], rbx
	call write
	add rsp, 32
	.L3:
	.L4:
	mov rbx, [rbp+16]
	xor rcx, rcx
	mov [rbx+24], rcx
	.L0:
	leave
	ret

global absi:function
absi:
	push rbp
	mov rbp, rsp
	mov rcx, [rbp+24]
	xor rsi, rsi
	cmp rcx, rsi
	setl cl
	test cl, cl
	je .L1
	mov rbx, [rbp+24]
	neg rbx
	jmp .L2
	.L1:
	mov rbx, [rbp+24]
	.L2:
	mov [rbp+16], rbx
	.L0:
	leave
	ret

global absf:function
absf:
	push rbp
	mov rbp, rsp
	movsd xmm0, [rbp+24]
    andpd xmm0, [__FABS_MASKd]
    movsd [rbp+16], xmm0
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
	mov rbx, 0x8
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
	.L0:
	leave
	ret

global is_alpha:function
is_alpha:
	push rbp
	mov rbp, rsp
	mov bl, [rbp+17]
	mov cl, 0x61
	cmp bl, cl
	setae bl
	test bl, bl
	je .L2
	mov cl, [rbp+17]
	mov sil, 0x7a
	cmp cl, sil
	setbe bl
	.L2:
	test bl, bl
	jne .L1
	mov cl, [rbp+17]
	mov sil, 0x41
	cmp cl, sil
	setae bl
	test bl, bl
	je .L3
	mov cl, [rbp+17]
	mov sil, 0x5a
	cmp cl, sil
	setbe bl
	.L3:
	.L1:
	mov [rbp+16], bl
	.L0:
	leave
	ret

global is_num:function
is_num:
	push rbp
	mov rbp, rsp
	mov bl, [rbp+17]
	mov cl, 0x30
	cmp bl, cl
	setae bl
	test bl, bl
	je .L1
	mov cl, [rbp+17]
	mov sil, 0x39
	cmp cl, sil
	setbe bl
	.L1:
	mov [rbp+16], bl
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
	.L0:
	leave
	ret

global to_lower:function
to_lower:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov [rsp+15], bl
	mov bl, [rbp+17]
	mov [rsp+1], bl
	call is_alpha
	mov bl, [rsp+15]
	mov cl, [rsp+0]
	add rsp, 16
	test cl, cl
	je .L1
	mov bl, [rbp+17]
	or bl, 0x20
	jmp .L2
	.L1:
	mov bl, [rbp+17]
	.L2:
	mov [rbp+16], bl
	.L0:
	leave
	ret

global to_upper:function
to_upper:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov [rsp+15], bl
	mov bl, [rbp+17]
	mov [rsp+1], bl
	call is_alpha
	mov bl, [rsp+15]
	mov cl, [rsp+0]
	add rsp, 16
	test cl, cl
	je .L1
	mov bl, [rbp+17]
	and bl, 0xdf
	jmp .L2
	.L1:
	mov bl, [rbp+17]
	.L2:
	mov [rbp+16], bl
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

global pow:function
pow:
	push rbp
	mov rbp, rsp
	fld QWORD [rbp+32]
    fld QWORD [rbp+24]
    fyl2x
    fld1
    fld st1
    fprem
    f2xm1
    fadd
    fscale
    fxch st1
    fstp st0
    fstp QWORD [rbp+16]
	.L0:
	leave
	ret

global log:function
log:
	push rbp
	mov rbp, rsp
	fld QWORD [rbp+24]
    fld1
    fldl2t
    fdivp
    fld QWORD [rbp+24]
    fyl2x
    fstp QWORD [rbp+16]
    fstp st0
	.L0:
	leave
	ret

global sin:function
sin:
	push rbp
	mov rbp, rsp
	movsd xmm0, [rbp+24]
	movsd xmm1, [FP2]
	movsd xmm2, xmm0
	divsd xmm2, xmm1
	roundsd xmm2, xmm2, 0
	subsd xmm0, xmm2
	movsd [rbp+24], xmm0
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
	movsd xmm0, [rbp+24]
	movsd xmm1, [FP2]
	movsd xmm2, xmm0
	divsd xmm2, xmm1
	roundsd xmm2, xmm2, 0
	subsd xmm0, xmm2
	movsd [rbp+24], xmm0
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
	movsd xmm0, [rbp+24]
	movsd xmm1, [FP2]
	movsd xmm2, xmm0
	divsd xmm2, xmm1
	roundsd xmm2, xmm2, 0
	subsd xmm0, xmm2
	movsd [rbp+24], xmm0
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
	movsd xmm0, [rbp+24]
    roundsd xmm0, xmm0, 0
    movsd [rbp+16], xmm0
	.L0:
	leave
	ret

global floor:function
floor:
	push rbp
	mov rbp, rsp
	movsd xmm0, [rbp+24]
    roundsd xmm0, xmm0, 1
    movsd [rbp+16], xmm0
	.L0:
	leave
	ret

global ceil:function
ceil:
	push rbp
	mov rbp, rsp
	movsd xmm0, [rbp+24]
    roundsd xmm0, xmm0, 2
    movsd [rbp+16], xmm0
	.L0:
	leave
	ret

global trunc:function
trunc:
	push rbp
	mov rbp, rsp
	movsd xmm0, [rbp+24]
    roundsd xmm0, xmm0, 3
    movsd [rbp+16], xmm0
	.L0:
	leave
	ret

global fixed.from_int:function
fixed.from_int:
	push rbp
	mov rbp, rsp
	mov ebx, [rbp+24]
	shl ebx, 15
	mov [rbp+16], ebx
	.L0:
	leave
	ret

global fixed.from_float:function
fixed.from_float:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov [rsp+28], ebx
	movsd xmm0, [rbp+24]
	movsd xmm1, [FP3]
	mulsd xmm0, xmm1
	movsd [rsp+8], xmm0
	call round
	mov ebx, [rsp+28]
	movsd xmm0, [rsp+0]
	add rsp, 32
	cvttsd2si ebx, xmm0
	mov [rbp+16], ebx
	.L0:
	leave
	ret

global fixed.from_string:function
fixed.from_string:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, [rbp+32]
	mov rcx, 0xffffffffffffffff
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
	.L1:
	.L2:
	xor ebx, ebx
	mov [rsp+12], ebx
	xor ebx, ebx
	mov [rsp+8], ebx
	mov ebx, 0x1
	mov [rsp+4], ebx
	xor bl, bl
	mov [rsp+3], bl
	xor bl, bl
	mov [rsp+2], bl
	.L3:
	mov rbx, [rbp+32]
	test rbx, rbx
	je .L5
	mov rbx, [rbp+24]
	mov cl, [rbx]
	mov bl, 0x2d
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
	mov bl, 0x30
	cmp cl, bl
	setae bl
	test bl, bl
	je .L9
	mov rcx, [rbp+24]
	mov sil, [rcx]
	mov cl, 0x39
	cmp sil, cl
	setbe bl
	.L9:
	test bl, bl
	je .L8
	mov bl, [rsp+2]
	test bl, bl
	je .L10
	mov ebx, [rsp+8]
	shl ebx, 1
	lea ebx, [ebx+ebx*4]
	mov rsi, [rbp+24]
	movzx ecx, BYTE [rsi]
	sub ecx, 0x30
	shl ecx, 15
	add ebx, ecx
	mov [rsp+8], ebx
	mov ebx, [rsp+4]
	shl ebx, 1
	lea ebx, [ebx+ebx*4]
	mov [rsp+4], ebx
	jmp .L11
	.L10:
	mov ebx, [rsp+12]
	shl ebx, 1
	lea ebx, [ebx+ebx*4]
	mov rsi, [rbp+24]
	movzx ecx, BYTE [rsi]
	sub ecx, 0x30
	shl ecx, 15
	add ebx, ecx
	mov [rsp+12], ebx
	.L11:
	jmp .L7
	.L8:
	mov rbx, [rbp+24]
	mov cl, [rbx]
	mov bl, 0x2e
	cmp cl, bl
	sete bl
	test bl, bl
	je .L12
	mov bl, 0x1
	mov [rsp+2], bl
	jmp .L7
	.L12:
	.L7:
	.L4:
	inc QWORD [rbp+24]
	mov rbx, [rbp+24]
	dec QWORD [rbp+32]
	mov rbx, [rbp+32]
	jmp .L3
	.L5:
	mov ebx, [rsp+12]
	mov eax, [rsp+8]
	mov ecx, [rsp+4]
	xor rdx, rdx
	idiv ecx
	and eax, 0x7fff
	add ebx, eax
	mov [rsp+12], ebx
	mov bl, [rsp+3]
	test bl, bl
	je .L13
	mov ebx, [rsp+12]
	neg ebx
	mov [rsp+12], ebx
	.L13:
	.L14:
	mov ebx, [rsp+12]
	mov [rbp+16], ebx
	.L0:
	leave
	ret

global fixed.to_int:function
fixed.to_int:
	push rbp
	mov rbp, rsp
	movsxd rbx, DWORD [rbp+24]
	sar rbx, 15
	mov [rbp+16], rbx
	.L0:
	leave
	ret

global fixed.to_float:function
fixed.to_float:
	push rbp
	mov rbp, rsp
	movsxd rbx, DWORD [rbp+24]
	cvtsi2ss xmm0, rbx
	cvtss2sd xmm0, xmm0
	movsd xmm1, [FP3]
	divsd xmm0, xmm1
	movsd [rbp+16], xmm0
	.L0:
	leave
	ret

global fixed.mul:function
fixed.mul:
	push rbp
	mov rbp, rsp
	movsxd rax, DWORD [rbp+20]
	movsxd rbx, DWORD [rbp+24]
	imul rbx
	sar rax, 15
	mov [rbp+16], eax
	.L0:
	leave
	ret

global fixed.div:function
fixed.div:
	push rbp
	mov rbp, rsp
	movsxd rax, DWORD [rbp+20]
	shl rax, 15
	movsxd rbx, DWORD [rbp+24]
	xor rdx, rdx
	idiv rbx
	mov [rbp+16], eax
	.L0:
	leave
	ret

global fixed.mod:function
fixed.mod:
	push rbp
	mov rbp, rsp
	movsxd rax, DWORD [rbp+20]
	shl rax, 15
	movsxd rbx, DWORD [rbp+24]
	xor rdx, rdx
	idiv rbx
	mov rax, rdx
	mov [rbp+16], eax
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

global memmove:function
memmove:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	mov rcx, [rbp+24]
	cmp rbx, rcx
	seta bl
	test bl, bl
	je .L1
	std
	mov rbx, [rbp+16]
	mov rcx, [rbp+32]
	dec rcx
	add rbx, rcx
	mov [rbp+16], rbx
	mov rbx, [rbp+24]
	mov rcx, [rbp+32]
	dec rcx
	add rbx, rcx
	mov [rbp+24], rbx
	jmp .L2
	.L1:
	cld
	.L2:
	mov rbx, [rbp+16]
	mov r8, [rbp+24]
	mov r9, [rbp+32]
	mov rdi, rbx
    mov rsi, r8
    mov rcx, r9
    rep movsb
	.L0:
	leave
	ret

global strlen:function
strlen:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+24]
	xor al, al
    mov rdi, rbx
    mov rcx, ~0
    cld
    repne scasb
    not rcx
    dec rcx
    mov [rbp+16], rcx
	.L0:
	leave
	ret

global strfind:function
strfind:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+40]
	mov rcx, 0xffffffffffffffff
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
	mov [rbp+40], rbx
	.L1:
	.L2:
	mov bl, [rbp+48]
	test bl, bl
	je .L3
	std
	mov rbx, [rbp+24]
	mov rcx, [rbp+40]
	dec rcx
	add rbx, rcx
	mov [rbp+24], rbx
	jmp .L4
	.L3:
	cld
	.L4:
	mov bl, [rbp+32]
	mov rsi, [rbp+24]
	mov r8, [rbp+40]
	inc r8
	mov al, bl
    mov rdi, rsi
    mov rcx, r8
    repne scasb
    sub r8, rcx
    dec r8
    mov [rbp+16], r8
	mov rbx, [rbp+16]
	mov rcx, [rbp+40]
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L5
	mov rbx, 0xffffffffffffffff
	mov [rbp+16], rbx
	.L5:
	.L6:
	.L0:
	leave
	ret

global strdfind:function
strdfind:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+40]
	mov rcx, 0xffffffffffffffff
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
	mov [rbp+40], rbx
	.L1:
	.L2:
	mov bl, [rbp+48]
	test bl, bl
	je .L3
	std
	mov rbx, [rbp+24]
	mov rcx, [rbp+40]
	dec rcx
	add rbx, rcx
	mov [rbp+24], rbx
	jmp .L4
	.L3:
	cld
	.L4:
	mov bl, [rbp+32]
	mov rsi, [rbp+24]
	mov r8, [rbp+40]
	inc r8
	mov al, bl
    mov rdi, rsi
    mov rcx, r8
    repe scasb
    sub r8, rcx
    dec r8
    mov [rbp+16], r8
	mov rbx, [rbp+16]
	mov rcx, [rbp+40]
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L5
	mov rbx, 0xffffffffffffffff
	mov [rbp+16], rbx
	.L5:
	.L6:
	.L0:
	leave
	ret

global strcpy:function
strcpy:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+40]
	mov rcx, 0xffffffffffffffff
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L1
	sub rsp, 16
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call strlen
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rbp+40], rbx
	.L1:
	.L2:
	sub rsp, 32
	mov rbx, [rbp+24]
	mov [rsp+0], rbx
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	mov rbx, [rbp+40]
	mov [rsp+16], rbx
	call memcpy
	add rsp, 32
	mov rbx, [rbp+24]
	mov rcx, [rbp+40]
	add rbx, rcx
	mov [rbp+24], rbx
	mov rbx, [rbp+24]
	xor cl, cl
	mov [rbx], cl
	mov rbx, [rbp+24]
	mov [rbp+16], rbx
	.L0:
	leave
	ret

global strcmp:function
strcmp:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+40]
	mov rcx, 0xffffffffffffffff
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
	mov [rbp+40], rbx
	.L1:
	.L2:
	mov rbx, [rbp+24]
	mov r8, [rbp+32]
	mov r9, [rbp+40]
	mov rsi, rbx
    mov rdi, r8
    mov rcx, r9
    repe cmpsb
    dec rsi
    dec rdi
    mov cl, [rsi]
    mov ch, [rdi]
    sub cl, ch
    mov [rbp+16], cl
	.L0:
	leave
	ret

global strequal:function
strequal:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	call strlen
	mov rbx, [rsp+0]
	add rsp, 16
	sub rsp, 32
	mov [rsp+24], rbx
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call strlen
	mov rbx, [rsp+24]
	mov rcx, [rsp+0]
	add rsp, 32
	cmp rbx, rcx
	setne bl
	test bl, bl
	je .L1
	xor bl, bl
	mov [rbp+16], bl
	jmp .L0
	.L1:
	.L2:
	sub rsp, 32
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+24], rbx
	call strcmp
	movsx rbx, BYTE [rsp+0]
	add rsp, 32
	xor rcx, rcx
	cmp rbx, rcx
	sete bl
	mov [rbp+16], bl
	.L0:
	leave
	ret

global string.ref_cnt:function
string.ref_cnt:
	push rbp
	mov rbp, rsp
	mov rcx, [rbp+24]
	mov rbx, [rcx+0]
	mov rsi, [rbp+24]
	mov rcx, [rsi+16]
	sub rbx, rcx
	sub rbx, 0x8
	mov [rbp+16], rbx
	.L0:
	leave
	ret

global string.mem_size:function
string.mem_size:
	push rbp
	mov rbp, rsp
	mov rcx, [rbp+24]
	mov rbx, [rcx+16]
	mov rsi, [rbp+24]
	mov rcx, [rsi+8]
	add rbx, rcx
	mov [rbp+16], rbx
	.L0:
	leave
	ret

global string.share:function
string.share:
	push rbp
	mov rbp, rsp
	mov rcx, [rbp+16]
	mov rbx, [rcx+24]
	xor rcx, rcx
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L1
	jmp .L0
	.L1:
	.L2:
	mov rbx, [rbp+16]
	mov rcx, 0x2
	mov [rbx+24], rcx
	sub rsp, 32
	mov [rsp+24], rbx
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	call string.ref_cnt
	mov rbx, [rsp+24]
	mov rcx, [rsp+0]
	add rsp, 32
	mov rbx, [rcx]
	inc QWORD [rcx]
	.L0:
	leave
	ret

global string.print:function
string.print:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov rbx, [rbp+24]
	mov [rsp+0], rbx
	mov rcx, [rbp+16]
	mov rbx, [rcx+0]
	mov [rsp+8], rbx
	mov rcx, [rbp+16]
	mov rbx, [rcx+8]
	mov [rsp+16], rbx
	call File.write
	add rsp, 32
	.L0:
	leave
	ret

global string.compare:function
string.compare:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rsi, [rbp+24]
	mov rcx, [rsi+8]
	mov rdi, [rbp+32]
	mov rsi, [rdi+8]
	cmp rcx, rsi
	setb cl
	test cl, cl
	je .L1
	mov rcx, [rbp+24]
	mov rbx, [rcx+8]
	jmp .L2
	.L1:
	mov rcx, [rbp+32]
	mov rbx, [rcx+8]
	.L2:
	mov [rsp+8], rbx
	sub rsp, 32
	mov rcx, [rbp+24]
	mov rbx, [rcx+0]
	mov [rsp+8], rbx
	mov rcx, [rbp+32]
	mov rbx, [rcx+0]
	mov [rsp+16], rbx
	mov rbx, [rsp+40]
	mov [rsp+24], rbx
	call strcmp
	movsx rbx, BYTE [rsp+0]
	add rsp, 32
	mov [rbp+16], rbx
	.L0:
	leave
	ret

global string.is_equal:function
string.is_equal:
	push rbp
	mov rbp, rsp
	mov rcx, [rbp+24]
	mov rbx, [rcx+8]
	mov rsi, [rbp+32]
	mov rcx, [rsi+8]
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L1
	sub rsp, 32
	mov [rsp+31], bl
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	call string.compare
	mov bl, [rsp+31]
	mov rcx, [rsp+0]
	add rsp, 32
	xor rsi, rsi
	cmp rcx, rsi
	sete bl
	.L1:
	mov [rbp+16], bl
	.L0:
	leave
	ret

global string.is_heap:function
string.is_heap:
	push rbp
	mov rbp, rsp
	mov rcx, [rbp+24]
	mov rbx, [rcx+24]
	mov rcx, 0x1
	cmp rbx, rcx
	sete bl
	mov [rbp+16], bl
	.L0:
	leave
	ret

global string.is_shared:function
string.is_shared:
	push rbp
	mov rbp, rsp
	mov rcx, [rbp+24]
	mov rbx, [rcx+24]
	mov rcx, 0x2
	cmp rbx, rcx
	sete bl
	mov [rbp+16], bl
	.L0:
	leave
	ret

global string.from_str:function
string.from_str:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+32]
	xor rcx, rcx
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L1
	sub rsp, 16
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	call strlen
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rbp+32], rbx
	.L1:
	.L2:
	mov rbx, [rbp+16]
	mov rcx, [rbp+24]
	mov [rbx+0], rcx
	mov rcx, [rbp+32]
	mov [rbx+8], rcx
	xor rcx, rcx
	mov [rbx+16], rcx
	xor rcx, rcx
	mov [rbx+24], rcx
	.L0:
	leave
	ret

global string.from_shared:function
string.from_shared:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, [rbp+24]
	mov [rsp+0], rbx
	call string.share
	add rsp, 16
	mov rbx, [rbp+16]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 4
	rep movsq
	.L0:
	leave
	ret

global print_str:function
print_str:
	push rbp
	mov rbp, rsp
	mov rcx, [rbp+16]
	test rcx, rcx
	sete bl
	test bl, bl
	je .L1
	sub rsp, 32
	mov rbx, STR1
	mov [rsp+0], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+8], rbx
	mov rbx, QWORD [stdout]
	mov [rsp+16], rbx
	call print_str
	add rsp, 32
	jmp .L0
	.L1:
	.L2:
	mov rbx, [rbp+24]
	mov rcx, 0xffffffffffffffff
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L3
	sub rsp, 16
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	call strlen
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rbp+24], rbx
	.L3:
	.L4:
	sub rsp, 32
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	call File.write
	add rsp, 32
	.L0:
	leave
	ret

global print_char:function
print_char:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov rbx, [rbp+24]
	mov [rsp+0], rbx
	lea rbx, [rbp+16]
	mov [rsp+8], rbx
	mov rbx, 0x1
	mov [rsp+16], rbx
	call File.write
	add rsp, 32
	.L0:
	leave
	ret

global print_decimal:function
print_decimal:
	push rbp
	mov rbp, rsp
	sub rsp, 64
	sub rsp, 32
	sub rsp, 48
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	lea rbx, [rsp+80]
	mov [rsp+16], rbx
	mov rbx, 0x40
	mov [rsp+24], rbx
	xor bl, bl
	mov [rsp+32], bl
	call int_to_string
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rsp+0], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	call print_str
	add rsp, 32
	.L0:
	leave
	ret

global print_udecimal:function
print_udecimal:
	push rbp
	mov rbp, rsp
	sub rsp, 64
	sub rsp, 32
	sub rsp, 48
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	lea rbx, [rsp+80]
	mov [rsp+16], rbx
	mov rbx, 0x40
	mov [rsp+24], rbx
	xor bl, bl
	mov [rsp+32], bl
	call uint_to_string
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rsp+0], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	call print_str
	add rsp, 32
	.L0:
	leave
	ret

global print_hex:function
print_hex:
	push rbp
	mov rbp, rsp
	sub rsp, 80
	lea rbx, [rsp+16]
	mov rcx, 0x3f
	xor sil, sil
	mov [rbx+rcx*1], sil
	mov rbx, STR2
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	add rbx, 0x3e
	mov [rsp+0], rbx
	mov rbx, [rbp+16]
	xor rcx, rcx
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L1
	mov rbx, [rsp+0]
	dec QWORD [rsp+0]
	mov cl, 0x30
	mov [rbx], cl
	.L1:
	.L2:
	.L3:
	mov rbx, [rbp+16]
	test rbx, rbx
	je .L5
	mov rbx, [rsp+0]
	mov rcx, [rsp+8]
	mov rsi, [rbp+16]
	and rsi, 0xf
	mov dil, [rcx+rsi*1]
	mov [rbx], dil
	.L4:
	mov rbx, [rbp+16]
	shr rbx, 4
	mov [rbp+16], rbx
	dec QWORD [rsp+0]
	mov rbx, [rsp+0]
	jmp .L3
	.L5:
	sub rsp, 32
	mov rbx, [rsp+32]
	inc rbx
	mov [rsp+0], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	call print_str
	add rsp, 32
	.L0:
	leave
	ret

global print_binary:function
print_binary:
	push rbp
	mov rbp, rsp
	sub rsp, 96
	lea rbx, [rsp+16]
	mov rcx, 0x4f
	xor sil, sil
	mov [rbx+rcx*1], sil
	lea rbx, [rsp+16]
	add rbx, 0x4e
	mov [rsp+8], rbx
	mov rbx, [rbp+16]
	xor rcx, rcx
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L1
	mov rbx, [rsp+8]
	dec QWORD [rsp+8]
	mov cl, 0x30
	mov [rbx], cl
	.L1:
	.L2:
	.L3:
	mov rbx, [rbp+16]
	test rbx, rbx
	je .L5
	mov rbx, [rsp+8]
	mov cl, [rbp+16]
	and cl, 0x1
	add cl, 0x30
	mov [rbx], cl
	.L4:
	mov rbx, [rbp+16]
	shr rbx, 1
	mov [rbp+16], rbx
	dec QWORD [rsp+8]
	mov rbx, [rsp+8]
	jmp .L3
	.L5:
	sub rsp, 32
	mov rbx, [rsp+40]
	inc rbx
	mov [rsp+0], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	call print_str
	add rsp, 32
	.L0:
	leave
	ret

global print_fixed:function
print_fixed:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	movsxd rbx, DWORD [rbp+16]
	xor rcx, rcx
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L1
	sub rsp, 16
	mov bl, 0x2d
	mov [rsp+0], bl
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	call print_char
	add rsp, 16
	mov ebx, [rbp+16]
	neg ebx
	mov [rbp+16], ebx
	.L1:
	.L2:
	mov ebx, DWORD [rbp+16]
	shr rbx, 15
	mov [rsp+40], rbx
	mov eax, DWORD [rbp+16]
	and rax, 0x7fff
	mov rbx, 0x2710
	mul rbx
	shr rax, 15
	mov [rsp+32], rax
	sub rsp, 16
	mov rbx, [rsp+56]
	mov [rsp+0], rbx
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	call print_udecimal
	add rsp, 16
	sub rsp, 16
	mov bl, 0x2e
	mov [rsp+0], bl
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	call print_char
	add rsp, 16
	sub rsp, 32
	sub rsp, 48
	mov rbx, [rsp+112]
	mov [rsp+8], rbx
	lea rbx, [rsp+80]
	mov [rsp+16], rbx
	mov rbx, 0x5
	mov [rsp+24], rbx
	mov bl, 0x30
	mov [rsp+32], bl
	call uint_to_string
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rsp+0], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	call print_str
	add rsp, 32
	.L0:
	leave
	ret

global print_double:function
print_double:
	push rbp
	mov rbp, rsp
	sub rsp, 160
	movsd xmm0, [FP4]
	movsd xmm1, [rbp+16]
	comisd xmm1, xmm0
	setb bl
	mov [rsp+31], bl
	mov bl, [rsp+31]
	test bl, bl
	je .L1
	sub rsp, 16
	mov bl, 0x2d
	mov [rsp+0], bl
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call print_char
	add rsp, 16
	movsd xmm0, [rbp+16]
	xorpd xmm0, [__FNEG_MASKd]
	movsd [rbp+16], xmm0
	.L1:
	.L2:
	movsd xmm0, [rbp+16]
	cvttsd2si rbx, xmm0
	mov [rsp+16], rbx
	sub rsp, 32
	mov [rsp+24], rbx
	movsd xmm0, [rbp+16]
	mov rbx, [rsp+48]
	cvtsi2ss xmm1, rbx
	cvtss2sd xmm1, xmm1
	subsd xmm0, xmm1
	sub rsp, 32
	movsd [rsp+24], xmm0
	movsd xmm0, [FP5]
	movsd [rsp+8], xmm0
	mov rbx, [rbp+24]
	cvtsi2ss xmm0, rbx
	cvtss2sd xmm0, xmm0
	movsd [rsp+16], xmm0
	call pow
	movsd xmm0, [rsp+24]
	movsd xmm1, [rsp+0]
	add rsp, 32
	mulsd xmm0, xmm1
	movsd [rsp+8], xmm0
	call round
	mov rbx, [rsp+24]
	movsd xmm0, [rsp+0]
	add rsp, 32
	cvttsd2si rbx, xmm0
	mov [rsp+8], rbx
	sub rsp, 16
	mov rbx, [rsp+32]
	mov [rsp+0], rbx
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call print_udecimal
	add rsp, 16
	sub rsp, 16
	mov bl, 0x2e
	mov [rsp+0], bl
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call print_char
	add rsp, 16
	sub rsp, 32
	sub rsp, 48
	mov rbx, [rsp+88]
	mov [rsp+8], rbx
	lea rbx, [rsp+112]
	mov [rsp+16], rbx
	mov rbx, [rbp+24]
	inc rbx
	mov [rsp+24], rbx
	mov bl, 0x30
	mov [rsp+32], bl
	call uint_to_string
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rsp+0], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	call print_str
	add rsp, 32
	.L0:
	leave
	ret

static left_align:function
left_align:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+24]
	mov rcx, 0xffffffffffffffff
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L1
	sub rsp, 16
	mov rbx, STR3
	mov [rsp+0], rbx
	call error
	add rsp, 16
	.L1:
	.L2:
	mov rcx, [rbp+16]
	mov rbx, [rcx+24]
	mov rcx, [rbp+24]
	sub rbx, rcx
	mov rcx, [rbp+32]
	cmp rbx, rcx
	setae bl
	test bl, bl
	je .L3
	jmp .L0
	.L3:
	.L4:
	sub rsp, 32
	mov rcx, [rbp+16]
	mov rbx, [rcx+8]
	mov rsi, [rbp+16]
	mov rcx, [rsi+24]
	add rbx, rcx
	mov [rsp+0], rbx
	mov bl, [rbp+40]
	mov [rsp+8], bl
	mov rbx, [rbp+32]
	mov rsi, [rbp+16]
	mov rcx, [rsi+24]
	sub rbx, rcx
	mov rcx, [rbp+24]
	add rbx, rcx
	mov [rsp+16], rbx
	call memset
	add rsp, 32
	mov rbx, [rbp+16]
	mov rcx, [rbp+24]
	mov rsi, [rbp+32]
	add rcx, rsi
	mov [rbx+24], rcx
	.L0:
	leave
	ret

static right_align:function
right_align:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, [rbp+24]
	mov rcx, 0xffffffffffffffff
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L1
	sub rsp, 16
	mov rbx, STR4
	mov [rsp+0], rbx
	call error
	add rsp, 16
	.L1:
	.L2:
	mov rcx, [rbp+16]
	mov rbx, [rcx+24]
	mov rcx, [rbp+24]
	sub rbx, rcx
	mov rcx, [rbp+32]
	cmp rbx, rcx
	setae bl
	test bl, bl
	je .L3
	jmp .L0
	.L3:
	.L4:
	mov rbx, [rbp+24]
	mov rcx, [rbp+32]
	add rbx, rcx
	mov rsi, [rbp+16]
	mov rcx, [rsi+24]
	mov rsi, [rbp+24]
	sub rcx, rsi
	sub rbx, rcx
	mov [rsp+8], rbx
	sub rsp, 32
	mov rcx, [rbp+16]
	mov rbx, [rcx+8]
	mov rcx, [rsp+40]
	add rbx, rcx
	mov [rsp+0], rbx
	mov rcx, [rbp+16]
	mov rbx, [rcx+8]
	mov rcx, [rbp+24]
	add rbx, rcx
	mov [rsp+8], rbx
	mov rcx, [rbp+16]
	mov rbx, [rcx+24]
	mov rcx, [rbp+24]
	sub rbx, rcx
	mov [rsp+16], rbx
	call memmove
	add rsp, 32
	sub rsp, 32
	mov rcx, [rbp+16]
	mov rbx, [rcx+8]
	mov rcx, [rbp+24]
	add rbx, rcx
	mov [rsp+0], rbx
	mov bl, [rbp+40]
	mov [rsp+8], bl
	mov rbx, [rsp+40]
	mov rcx, [rbp+24]
	sub rbx, rcx
	mov [rsp+16], rbx
	call memset
	add rsp, 32
	mov rbx, [rbp+16]
	mov rcx, [rbp+24]
	mov rsi, [rbp+32]
	add rcx, rsi
	mov [rbx+24], rcx
	.L0:
	leave
	ret

static center:function
center:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, [rbp+24]
	mov rcx, 0xffffffffffffffff
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L1
	sub rsp, 16
	mov rbx, STR5
	mov [rsp+0], rbx
	call error
	add rsp, 16
	.L1:
	.L2:
	mov rcx, [rbp+16]
	mov rbx, [rcx+24]
	mov rcx, [rbp+24]
	sub rbx, rcx
	mov rcx, [rbp+32]
	cmp rbx, rcx
	setae bl
	test bl, bl
	je .L3
	jmp .L0
	.L3:
	.L4:
	mov rbx, [rbp+32]
	mov rsi, [rbp+16]
	mov rcx, [rsi+24]
	mov rsi, [rbp+24]
	sub rcx, rsi
	sub rbx, rcx
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov rcx, [rsp+8]
	shr rcx, 1
	add rbx, rcx
	mov [rsp+0], rbx
	sub rsp, 32
	mov rcx, [rbp+16]
	mov rbx, [rcx+8]
	mov rcx, [rsp+32]
	add rbx, rcx
	mov [rsp+0], rbx
	mov rcx, [rbp+16]
	mov rbx, [rcx+8]
	mov rcx, [rbp+24]
	add rbx, rcx
	mov [rsp+8], rbx
	mov rcx, [rbp+16]
	mov rbx, [rcx+24]
	mov rcx, [rbp+24]
	sub rbx, rcx
	mov [rsp+16], rbx
	call memmove
	add rsp, 32
	sub rsp, 32
	mov rcx, [rbp+16]
	mov rbx, [rcx+8]
	mov rcx, [rbp+24]
	add rbx, rcx
	mov [rsp+0], rbx
	mov bl, [rbp+40]
	mov [rsp+8], bl
	mov rbx, [rsp+32]
	mov rcx, [rbp+24]
	sub rbx, rcx
	mov [rsp+16], rbx
	call memset
	add rsp, 32
	sub rsp, 32
	mov rcx, [rbp+16]
	mov rbx, [rcx+8]
	mov rcx, [rsp+32]
	add rbx, rcx
	mov rsi, [rbp+16]
	mov rcx, [rsi+24]
	add rbx, rcx
	mov rcx, [rbp+24]
	sub rbx, rcx
	mov [rsp+0], rbx
	mov bl, [rbp+40]
	mov [rsp+8], bl
	mov rbx, [rsp+40]
	shr rbx, 1
	mov rcx, [rsp+40]
	and rcx, 0x1
	add rbx, rcx
	mov [rsp+16], rbx
	call memset
	add rsp, 32
	mov rbx, [rbp+16]
	mov rcx, [rbp+24]
	mov rsi, [rbp+32]
	add rcx, rsi
	mov [rbx+24], rcx
	.L0:
	leave
	ret

global print_format:function
print_format:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	xor rbx, rbx
	mov [rsp+24], rbx
	sub rsp, 16
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	call strlen
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rsp+16], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+8], rbx
	sub rsp, 16
	.L1:
	mov rbx, [rsp+32]
	test rbx, rbx
	je .L2
	sub rsp, 48
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	mov bl, 0x25
	mov [rsp+16], bl
	mov rbx, [rsp+80]
	mov [rsp+24], rbx
	xor bl, bl
	mov [rsp+32], bl
	call strfind
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rsp+8], rbx
	mov rbx, [rsp+8]
	mov rcx, 0xffffffffffffffff
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L3
	mov rbx, [rsp+32]
	mov [rsp+8], rbx
	.L3:
	.L4:
	mov rbx, [rsp+8]
	test rbx, rbx
	je .L5
	sub rsp, 32
	mov rbx, [rbp+16]
	mov [rsp+0], rbx
	mov rbx, [rsp+40]
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	call print_str
	add rsp, 32
	jmp .L6
	.L5:
	mov rbx, [rbp+16]
	inc rbx
	mov cl, [rbx]
	mov bl, 0x69
	cmp cl, bl
	sete bl
	test bl, bl
	je .L7
	sub rsp, 16
	mov rbx, [rbp+24]
	mov rcx, [rsp+56]
	inc QWORD [rsp+56]
	mov rsi, [rbx+rcx*8]
	mov [rsp+0], rsi
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call print_decimal
	add rsp, 16
	jmp .L6
	.L7:
	mov rbx, [rbp+16]
	inc rbx
	mov cl, [rbx]
	mov bl, 0x75
	cmp cl, bl
	sete bl
	test bl, bl
	je .L8
	sub rsp, 16
	mov rbx, [rbp+24]
	mov rcx, [rsp+56]
	inc QWORD [rsp+56]
	mov rsi, [rbx+rcx*8]
	mov [rsp+0], rsi
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call print_udecimal
	add rsp, 16
	jmp .L6
	.L8:
	mov rbx, [rbp+16]
	inc rbx
	mov cl, [rbx]
	mov bl, 0x78
	cmp cl, bl
	sete bl
	test bl, bl
	je .L9
	sub rsp, 16
	mov rbx, [rbp+24]
	mov rcx, [rsp+56]
	inc QWORD [rsp+56]
	mov rsi, [rbx+rcx*8]
	mov [rsp+0], rsi
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call print_hex
	add rsp, 16
	jmp .L6
	.L9:
	mov rbx, [rbp+16]
	inc rbx
	mov cl, [rbx]
	mov bl, 0x73
	cmp cl, bl
	sete bl
	test bl, bl
	je .L10
	sub rsp, 32
	mov rbx, [rbp+24]
	mov rcx, [rsp+72]
	inc QWORD [rsp+72]
	mov rsi, [rbx+rcx*8]
	mov [rsp+0], rsi
	mov rbx, 0xffffffffffffffff
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	call print_str
	add rsp, 32
	jmp .L6
	.L10:
	mov rbx, [rbp+16]
	inc rbx
	mov cl, [rbx]
	mov bl, 0x53
	cmp cl, bl
	sete bl
	test bl, bl
	je .L11
	sub rsp, 16
	mov rbx, [rbp+24]
	mov rcx, [rsp+56]
	inc QWORD [rsp+56]
	mov rsi, [rbx+rcx*8]
	mov [rsp+0], rsi
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call string.print
	add rsp, 16
	jmp .L6
	.L11:
	mov rbx, [rbp+16]
	inc rbx
	mov cl, [rbx]
	mov bl, 0x63
	cmp cl, bl
	sete bl
	test bl, bl
	je .L12
	sub rsp, 16
	mov rbx, [rbp+24]
	mov rcx, [rsp+56]
	inc QWORD [rsp+56]
	mov sil, [rbx+rcx*8]
	mov [rsp+0], sil
	mov rbx, QWORD [stdout]
	mov [rsp+8], rbx
	call print_char
	add rsp, 16
	jmp .L6
	.L12:
	mov rbx, [rbp+16]
	inc rbx
	mov cl, [rbx]
	mov bl, 0x5b
	cmp cl, bl
	sete bl
	test bl, bl
	je .L13
	mov rcx, [rbp+32]
	mov rbx, [rcx+24]
	mov [rsp+24], rbx
	jmp .L6
	.L13:
	mov rbx, [rbp+16]
	inc rbx
	mov cl, [rbx]
	mov bl, 0x4c
	cmp cl, bl
	sete bl
	test bl, bl
	je .L14
	sub rsp, 32
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, [rsp+56]
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov rcx, [rsp+72]
	inc QWORD [rsp+72]
	mov rsi, [rbx+rcx*8]
	mov [rsp+16], rsi
	mov bl, 0x20
	mov [rsp+24], bl
	call left_align
	add rsp, 32
	jmp .L6
	.L14:
	mov rbx, [rbp+16]
	inc rbx
	mov cl, [rbx]
	mov bl, 0x52
	cmp cl, bl
	sete bl
	test bl, bl
	je .L15
	sub rsp, 32
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, [rsp+56]
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov rcx, [rsp+72]
	inc QWORD [rsp+72]
	mov rsi, [rbx+rcx*8]
	mov [rsp+16], rsi
	mov bl, 0x20
	mov [rsp+24], bl
	call right_align
	add rsp, 32
	jmp .L6
	.L15:
	mov rbx, [rbp+16]
	inc rbx
	mov cl, [rbx]
	mov bl, 0x43
	cmp cl, bl
	sete bl
	test bl, bl
	je .L16
	sub rsp, 32
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, [rsp+56]
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov rcx, [rsp+72]
	inc QWORD [rsp+72]
	mov rsi, [rbx+rcx*8]
	mov [rsp+16], rsi
	mov bl, 0x20
	mov [rsp+24], bl
	call center
	add rsp, 32
	jmp .L6
	.L16:
	mov rbx, [rbp+16]
	inc rbx
	mov cl, [rbx]
	mov bl, 0x41
	cmp cl, bl
	sete bl
	test bl, bl
	je .L17
	sub rsp, 16
	mov rbx, [rbp+24]
	mov rcx, [rsp+56]
	inc QWORD [rsp+56]
	mov rsi, [rbx+rcx*8]
	mov [rsp+8], rsi
	sub rsp, 32
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	xor rbx, rbx
	mov [rsp+8], rbx
	mov rbx, [rsp+40]
	mov [rsp+16], rbx
	mov bl, 0x20
	mov [rsp+24], bl
	call left_align
	add rsp, 32
	add rsp, 16
	jmp .L6
	.L17:
	mov rbx, [rbp+16]
	inc rbx
	mov cl, [rbx]
	mov bl, 0x54
	cmp cl, bl
	sete bl
	test bl, bl
	je .L18
	sub rsp, 16
	mov rbx, [rsp+40]
	mov rcx, 0xffffffffffffffff
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L19
	sub rsp, 16
	mov rbx, STR6
	mov [rsp+0], rbx
	call error
	add rsp, 16
	.L19:
	.L20:
	mov rbx, [rbp+24]
	mov rcx, [rsp+56]
	inc QWORD [rsp+56]
	mov rsi, [rbx+rcx*8]
	mov [rsp+8], rsi
	mov rcx, [rbp+32]
	mov rbx, [rcx+24]
	mov rcx, [rsp+40]
	sub rbx, rcx
	mov rcx, [rsp+8]
	cmp rbx, rcx
	seta bl
	test bl, bl
	je .L21
	sub rsp, 32
	mov rcx, [rbp+32]
	mov rbx, [rcx+8]
	mov rcx, [rsp+72]
	add rbx, rcx
	mov rcx, [rsp+40]
	add rbx, rcx
	mov [rsp+0], rbx
	xor bl, bl
	mov [rsp+8], bl
	mov rcx, [rbp+32]
	mov rbx, [rcx+24]
	mov rcx, [rsp+72]
	sub rbx, rcx
	mov rcx, [rsp+40]
	sub rbx, rcx
	mov [rsp+16], rbx
	call memset
	add rsp, 32
	mov rbx, [rbp+32]
	mov rcx, [rsp+40]
	mov rsi, [rsp+8]
	add rcx, rsi
	mov [rbx+24], rcx
	.L21:
	.L22:
	add rsp, 16
	jmp .L6
	.L18:
	mov rbx, [rbp+16]
	inc rbx
	mov cl, [rbx]
	mov bl, 0x62
	cmp cl, bl
	sete bl
	test bl, bl
	je .L23
	mov rbx, [rbp+24]
	mov rcx, [rsp+40]
	inc QWORD [rsp+40]
	mov rsi, [rbx+rcx*8]
	test rsi, rsi
	je .L24
	sub rsp, 32
	mov rbx, STR7
	mov [rsp+0], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	call print_str
	add rsp, 32
	jmp .L25
	.L24:
	sub rsp, 32
	mov rbx, STR8
	mov [rsp+0], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	call print_str
	add rsp, 32
	.L25:
	jmp .L6
	.L23:
	mov rbx, [rbp+16]
	inc rbx
	mov cl, [rbx]
	mov bl, 0x42
	cmp cl, bl
	sete bl
	test bl, bl
	je .L26
	sub rsp, 16
	mov rbx, [rbp+24]
	mov rcx, [rsp+56]
	inc QWORD [rsp+56]
	mov rsi, [rbx+rcx*8]
	mov [rsp+0], rsi
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call print_binary
	add rsp, 16
	jmp .L6
	.L26:
	mov rbx, [rbp+16]
	inc rbx
	mov cl, [rbx]
	mov bl, 0x46
	cmp cl, bl
	sete bl
	test bl, bl
	je .L27
	sub rsp, 16
	mov rbx, [rbp+24]
	mov rcx, [rsp+56]
	inc QWORD [rsp+56]
	mov esi, [rbx+rcx*8]
	mov [rsp+0], esi
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call print_fixed
	add rsp, 16
	jmp .L6
	.L27:
	mov rbx, [rbp+16]
	inc rbx
	mov cl, [rbx]
	mov bl, 0x66
	cmp cl, bl
	sete bl
	test bl, bl
	je .L28
	sub rsp, 32
	mov rbx, [rbp+24]
	mov rcx, [rsp+72]
	inc QWORD [rsp+72]
	movsd xmm0, [rbx+rcx*8]
	movsd [rsp+0], xmm0
	mov rbx, 0x4
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	call print_double
	add rsp, 32
	jmp .L6
	.L28:
	mov rbx, [rbp+16]
	inc rbx
	mov cl, [rbx]
	mov bl, 0x30
	cmp cl, bl
	sete bl
	test bl, bl
	je .L29
	sub rsp, 80
	inc QWORD [rbp+16]
	mov rbx, [rbp+16]
	mov rbx, [rbp+16]
	inc rbx
	mov cl, [rbx]
	mov bl, 0x31
	cmp cl, bl
	setb bl
	test bl, bl
	jne .L32
	mov rcx, [rbp+16]
	inc rcx
	mov sil, [rcx]
	mov cl, 0x39
	cmp sil, cl
	seta bl
	.L32:
	test bl, bl
	je .L30
	sub rsp, 16
	mov rbx, STR9
	mov [rsp+0], rbx
	call error
	add rsp, 16
	.L30:
	.L31:
	mov rbx, [rbp+16]
	inc rbx
	movzx rcx, BYTE [rbx]
	sub rcx, 0x30
	mov [rsp+8], rcx
	sub rsp, 32
	sub rsp, 48
	mov rbx, [rbp+24]
	mov rcx, [rsp+200]
	inc QWORD [rsp+200]
	mov rsi, [rbx+rcx*8]
	mov [rsp+8], rsi
	lea rbx, [rsp+96]
	mov [rsp+16], rbx
	mov rbx, [rsp+88]
	inc rbx
	mov [rsp+24], rbx
	mov bl, 0x30
	mov [rsp+32], bl
	call uint_to_string
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rsp+0], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	call print_str
	add rsp, 32
	add rsp, 80
	jmp .L6
	.L29:
	mov rbx, [rbp+16]
	inc rbx
	mov cl, [rbx]
	mov bl, 0x25
	cmp cl, bl
	sete bl
	test bl, bl
	je .L33
	sub rsp, 16
	mov bl, 0x25
	mov [rsp+0], bl
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call print_char
	add rsp, 16
	jmp .L6
	.L33:
	mov rbx, [rbp+16]
	inc rbx
	mov cl, [rbx]
	mov bl, 0x2a
	cmp cl, bl
	sete bl
	test bl, bl
	je .L34
	sub rsp, 16
	inc QWORD [rbp+16]
	mov rbx, [rbp+16]
	dec QWORD [rsp+48]
	mov rbx, [rsp+48]
	mov rbx, [rbp+24]
	mov rcx, [rsp+56]
	inc QWORD [rsp+56]
	mov rsi, [rbx+rcx*8]
	mov [rsp+8], rsi
	mov rbx, [rbp+16]
	inc rbx
	mov cl, [rbx]
	mov bl, 0x73
	cmp cl, bl
	sete bl
	test bl, bl
	je .L35
	sub rsp, 32
	mov rbx, [rbp+24]
	mov rcx, [rsp+88]
	inc QWORD [rsp+88]
	mov rsi, [rbx+rcx*8]
	mov [rsp+0], rsi
	mov rbx, [rsp+40]
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	call print_str
	add rsp, 32
	jmp .L36
	.L35:
	mov rbx, [rbp+16]
	inc rbx
	mov cl, [rbx]
	mov bl, 0x63
	cmp cl, bl
	sete bl
	test bl, bl
	je .L37
	sub rsp, 16
	mov rbx, [rbp+24]
	mov rcx, [rsp+72]
	inc QWORD [rsp+72]
	mov sil, [rbx+rcx*8]
	mov [rsp+15], sil
	mov rbx, [rsp+24]
	.L38:
	test rbx, rbx
	je .L40
	sub rsp, 32
	mov [rsp+24], rbx
	mov bl, [rsp+47]
	mov [rsp+0], bl
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call print_char
	mov rbx, [rsp+24]
	add rsp, 32
	.L39:
	dec rbx
	jmp .L38
	.L40:
	add rsp, 16
	jmp .L36
	.L37:
	mov rbx, [rbp+16]
	inc rbx
	mov cl, [rbx]
	mov bl, 0x42
	cmp cl, bl
	sete bl
	test bl, bl
	je .L41
	sub rsp, 16
	mov rbx, [rbp+24]
	mov rcx, [rsp+72]
	inc QWORD [rsp+72]
	mov rsi, [rbx+rcx*8]
	mov [rsp+8], rsi
	mov rbx, [rsp+24]
	.L42:
	test rbx, rbx
	je .L44
	sub rsp, 32
	mov [rsp+24], rbx
	mov rbx, [rsp+40]
	inc QWORD [rsp+40]
	movzx rcx, BYTE [rbx]
	mov [rsp+0], rcx
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call print_hex
	mov rbx, [rsp+24]
	add rsp, 32
	sub rsp, 32
	mov [rsp+24], rbx
	mov bl, 0x2f
	mov [rsp+0], bl
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call print_char
	mov rbx, [rsp+24]
	add rsp, 32
	.L43:
	dec rbx
	jmp .L42
	.L44:
	add rsp, 16
	jmp .L36
	.L41:
	mov rbx, [rbp+16]
	inc rbx
	mov cl, [rbx]
	mov bl, 0x4c
	cmp cl, bl
	sete bl
	test bl, bl
	je .L45
	sub rsp, 16
	mov rbx, [rbp+24]
	mov rcx, [rsp+72]
	inc QWORD [rsp+72]
	mov sil, [rbx+rcx*8]
	mov [rsp+15], sil
	sub rsp, 32
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, [rsp+88]
	mov [rsp+8], rbx
	mov rbx, [rsp+56]
	mov [rsp+16], rbx
	mov bl, [rsp+47]
	mov [rsp+24], bl
	call left_align
	add rsp, 32
	add rsp, 16
	jmp .L36
	.L45:
	mov rbx, [rbp+16]
	inc rbx
	mov cl, [rbx]
	mov bl, 0x52
	cmp cl, bl
	sete bl
	test bl, bl
	je .L46
	sub rsp, 16
	mov rbx, [rbp+24]
	mov rcx, [rsp+72]
	inc QWORD [rsp+72]
	mov sil, [rbx+rcx*8]
	mov [rsp+15], sil
	sub rsp, 32
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, [rsp+88]
	mov [rsp+8], rbx
	mov rbx, [rsp+56]
	mov [rsp+16], rbx
	mov bl, [rsp+47]
	mov [rsp+24], bl
	call right_align
	add rsp, 32
	add rsp, 16
	jmp .L36
	.L46:
	mov rbx, [rbp+16]
	inc rbx
	mov cl, [rbx]
	mov bl, 0x43
	cmp cl, bl
	sete bl
	test bl, bl
	je .L47
	sub rsp, 16
	mov rbx, [rbp+24]
	mov rcx, [rsp+72]
	inc QWORD [rsp+72]
	mov sil, [rbx+rcx*8]
	mov [rsp+15], sil
	sub rsp, 32
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, [rsp+88]
	mov [rsp+8], rbx
	mov rbx, [rsp+56]
	mov [rsp+16], rbx
	mov bl, [rsp+47]
	mov [rsp+24], bl
	call center
	add rsp, 32
	add rsp, 16
	jmp .L36
	.L47:
	mov rbx, [rbp+16]
	inc rbx
	mov cl, [rbx]
	mov bl, 0x41
	cmp cl, bl
	sete bl
	test bl, bl
	je .L48
	sub rsp, 16
	mov rbx, [rbp+24]
	mov rcx, [rsp+72]
	inc QWORD [rsp+72]
	mov sil, [rbx+rcx*8]
	mov [rsp+15], sil
	sub rsp, 32
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	xor rbx, rbx
	mov [rsp+8], rbx
	mov rbx, [rsp+56]
	mov [rsp+16], rbx
	mov bl, [rsp+47]
	mov [rsp+24], bl
	call left_align
	add rsp, 32
	add rsp, 16
	jmp .L36
	.L48:
	mov rbx, [rbp+16]
	inc rbx
	mov cl, [rbx]
	mov bl, 0x54
	cmp cl, bl
	sete bl
	test bl, bl
	je .L49
	mov rbx, [rsp+40]
	mov rcx, 0xffffffffffffffff
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L50
	sub rsp, 16
	mov rbx, STR10
	mov [rsp+0], rbx
	call error
	add rsp, 16
	.L50:
	.L51:
	mov rcx, [rbp+32]
	mov rbx, [rcx+24]
	mov rcx, [rsp+40]
	sub rbx, rcx
	mov rcx, [rsp+8]
	cmp rbx, rcx
	seta bl
	test bl, bl
	je .L52
	sub rsp, 32
	mov rcx, [rbp+32]
	mov rbx, [rcx+8]
	mov rcx, [rsp+72]
	add rbx, rcx
	mov [rsp+0], rbx
	mov rcx, [rbp+32]
	mov rbx, [rcx+8]
	mov rsi, [rbp+32]
	mov rcx, [rsi+24]
	add rbx, rcx
	mov rcx, [rsp+40]
	sub rbx, rcx
	mov [rsp+8], rbx
	mov rbx, [rsp+40]
	mov [rsp+16], rbx
	call memmove
	add rsp, 32
	sub rsp, 32
	mov rcx, [rbp+32]
	mov rbx, [rcx+8]
	mov rcx, [rsp+72]
	add rbx, rcx
	mov rcx, [rsp+40]
	add rbx, rcx
	mov [rsp+0], rbx
	xor bl, bl
	mov [rsp+8], bl
	mov rcx, [rbp+32]
	mov rbx, [rcx+24]
	mov rcx, [rsp+72]
	sub rbx, rcx
	mov rcx, [rsp+40]
	sub rbx, rcx
	mov [rsp+16], rbx
	call memset
	add rsp, 32
	mov rbx, [rbp+32]
	mov rcx, [rsp+40]
	mov rsi, [rsp+8]
	add rcx, rsi
	mov [rbx+24], rcx
	.L52:
	.L53:
	jmp .L36
	.L49:
	mov rbx, [rbp+16]
	inc rbx
	mov cl, [rbx]
	mov bl, 0x66
	cmp cl, bl
	sete bl
	test bl, bl
	je .L54
	sub rsp, 32
	mov rbx, [rbp+24]
	mov rcx, [rsp+88]
	inc QWORD [rsp+88]
	movsd xmm0, [rbx+rcx*8]
	movsd [rsp+0], xmm0
	mov rbx, [rsp+40]
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	call print_double
	add rsp, 32
	jmp .L36
	.L54:
	sub rsp, 32
	mov rbx, STR11
	mov [rsp+0], rbx
	mov rbx, 0x2
	mov [rsp+8], rbx
	mov rbx, [rbp+16]
	dec rbx
	mov [rsp+16], rbx
	call error
	add rsp, 32
	.L36:
	add rsp, 16
	jmp .L6
	.L34:
	sub rsp, 16
	mov rbx, STR12
	mov [rsp+0], rbx
	mov rbx, [rbp+16]
	inc rbx
	movzx rcx, BYTE [rbx]
	mov [rsp+8], rcx
	call error
	add rsp, 16
	.L6:
	mov rbx, [rsp+8]
	test rbx, rbx
	je .L55
	mov rbx, [rbp+16]
	mov rcx, [rsp+8]
	add rbx, rcx
	mov [rbp+16], rbx
	mov rbx, [rsp+32]
	mov rcx, [rsp+8]
	sub rbx, rcx
	mov [rsp+32], rbx
	jmp .L56
	.L55:
	mov rbx, [rbp+16]
	add rbx, 0x2
	mov [rbp+16], rbx
	mov rbx, [rsp+32]
	sub rbx, 0x2
	mov [rsp+32], rbx
	.L56:
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
	sub rsp, 32
	mov rbx, [rbp+16]
	mov [rsp+0], rbx
	lea rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rbx, QWORD [stdout]
	mov [rsp+16], rbx
	call print_format
	add rsp, 32
	.L0:
	leave
	ret

global println:function
println:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov rbx, [rbp+16]
	mov [rsp+0], rbx
	lea rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rbx, QWORD [stdout]
	mov [rsp+16], rbx
	call print_format
	add rsp, 32
	sub rsp, 16
	mov bl, 0xa
	mov [rsp+0], bl
	mov rbx, QWORD [stdout]
	mov [rsp+8], rbx
	call print_char
	add rsp, 16
	.L0:
	leave
	ret

global error:function
error:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov rbx, [rbp+16]
	mov [rsp+0], rbx
	lea rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rbx, QWORD [stdout]
	mov [rsp+16], rbx
	call print_format
	add rsp, 32
	sub rsp, 16
	mov bl, 0xa
	mov [rsp+0], bl
	mov rbx, QWORD [stdout]
	mov [rsp+8], rbx
	call print_char
	add rsp, 16
	sub rsp, 16
	mov rbx, 0xffffffffffffffff
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
	sub rsp, 16
	mov rbx, QWORD [stdout]
	mov [rsp+0], rbx
	call File.flush
	add rsp, 16
	sub rsp, 32
	mov rbx, QWORD [stdin]
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	mov rbx, [rbp+32]
	mov [rsp+24], rbx
	call File.read
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+8], rbx
	mov rbx, [rsp+8]
	xor rcx, rcx
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L1
	sub rsp, 16
	mov rbx, STR13
	mov [rsp+0], rbx
	mov rbx, [rsp+24]
	mov [rsp+8], rbx
	call error
	add rsp, 16
	.L1:
	.L2:
	mov rbx, [rbp+24]
	dec QWORD [rsp+8]
	mov rcx, [rsp+8]
	xor sil, sil
	mov [rbx+rcx*1], sil
	mov rbx, [rsp+8]
	mov [rbp+16], rbx
	.L0:
	leave
	ret

global input_char:function
input_char:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	sub rsp, 16
	mov rbx, QWORD [stdout]
	mov [rsp+0], rbx
	call File.flush
	add rsp, 16
	xor bx, bx
	mov [rsp+14], bx
	sub rsp, 32
	mov rbx, QWORD [stdin]
	mov [rsp+8], rbx
	lea rbx, [rsp+46]
	mov [rsp+16], rbx
	mov rbx, 0x2
	mov [rsp+24], rbx
	call File.read
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+0], rbx
	mov rbx, [rsp+0]
	xor rcx, rcx
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L1
	sub rsp, 16
	mov rbx, STR14
	mov [rsp+0], rbx
	mov rbx, [rsp+16]
	mov [rsp+8], rbx
	call error
	add rsp, 16
	.L1:
	.L2:
	mov bl, [rsp+14]
	mov [rbp+16], bl
	.L0:
	leave
	ret

global int_to_string:function
int_to_string:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rcx, [rbp+32]
	dec QWORD [rbp+40]
	mov rsi, [rbp+40]
	lea rbx, [rcx+rsi*1]
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	xor rcx, rcx
	cmp rbx, rcx
	setl bl
	mov [rsp+7], bl
	mov bl, [rsp+7]
	test bl, bl
	je .L1
	mov rbx, [rbp+24]
	neg rbx
	mov [rbp+24], rbx
	.L1:
	.L2:
	mov rbx, [rsp+8]
	xor cl, cl
	mov [rbx], cl
	dec QWORD [rsp+8]
	mov rbx, [rsp+8]
	mov rbx, [rbp+24]
	xor rcx, rcx
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L3
	mov rbx, [rsp+8]
	dec QWORD [rsp+8]
	mov cl, 0x30
	mov [rbx], cl
	dec QWORD [rbp+40]
	mov rbx, [rbp+40]
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
	mov rcx, 0xa
	xor rdx, rdx
	idiv rcx
	mov rax, rdx
	add al, 0x30
	mov [rbx], al
	.L6:
	mov rax, [rbp+24]
	mov rbx, 0xa
	xor rdx, rdx
	idiv rbx
	mov [rbp+24], rax
	dec QWORD [rbp+40]
	mov rbx, [rbp+40]
	dec QWORD [rsp+8]
	mov rbx, [rsp+8]
	jmp .L5
	.L7:
	mov bl, [rbp+48]
	test bl, bl
	je .L9
	mov rbx, [rbp+40]
	.L11:
	test rbx, rbx
	je .L13
	mov r8, [rsp+8]
	dec QWORD [rsp+8]
	mov cl, [rbp+48]
	mov [r8], cl
	.L12:
	dec rbx
	jmp .L11
	.L13:
	.L9:
	.L10:
	mov bl, [rsp+7]
	test bl, bl
	je .L14
	mov rbx, [rsp+8]
	dec QWORD [rsp+8]
	mov cl, 0x2d
	mov [rbx], cl
	.L14:
	.L15:
	mov rbx, [rsp+8]
	inc rbx
	mov [rbp+16], rbx
	.L0:
	leave
	ret

global uint_to_string:function
uint_to_string:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rcx, [rbp+32]
	dec QWORD [rbp+40]
	mov rsi, [rbp+40]
	lea rbx, [rcx+rsi*1]
	mov [rsp+8], rbx
	mov rbx, [rsp+8]
	xor cl, cl
	mov [rbx], cl
	dec QWORD [rsp+8]
	mov rbx, [rsp+8]
	mov rbx, [rbp+24]
	xor rcx, rcx
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L1
	mov rbx, [rsp+8]
	dec QWORD [rsp+8]
	mov cl, 0x30
	mov [rbx], cl
	dec QWORD [rbp+40]
	mov rbx, [rbp+40]
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
	mov rcx, 0xa
	xor rdx, rdx
	div rcx
	mov rax, rdx
	add al, 0x30
	mov [rbx], al
	.L4:
	mov rax, [rbp+24]
	mov rbx, 0xa
	xor rdx, rdx
	div rbx
	mov [rbp+24], rax
	dec QWORD [rbp+40]
	mov rbx, [rbp+40]
	dec QWORD [rsp+8]
	mov rbx, [rsp+8]
	jmp .L3
	.L5:
	mov bl, [rbp+48]
	test bl, bl
	je .L7
	mov rbx, [rbp+40]
	.L9:
	test rbx, rbx
	je .L11
	mov r8, [rsp+8]
	dec QWORD [rsp+8]
	mov cl, [rbp+48]
	mov [r8], cl
	.L10:
	dec rbx
	jmp .L9
	.L11:
	.L7:
	.L8:
	mov rbx, [rsp+8]
	inc rbx
	mov [rbp+16], rbx
	.L0:
	leave
	ret

global string_to_int:function
string_to_int:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, [rbp+32]
	mov rcx, 0xffffffffffffffff
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
	.L1:
	.L2:
	xor rbx, rbx
	mov [rsp+8], rbx
	xor bl, bl
	mov [rsp+7], bl
	.L3:
	mov rbx, [rbp+32]
	test rbx, rbx
	je .L5
	mov rbx, [rbp+24]
	mov cl, [rbx]
	mov bl, 0x2d
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
	mov bl, 0x30
	cmp cl, bl
	setae bl
	test bl, bl
	je .L9
	mov rcx, [rbp+24]
	mov sil, [rcx]
	mov cl, 0x39
	cmp sil, cl
	setbe bl
	.L9:
	test bl, bl
	je .L8
	mov rbx, [rsp+8]
	shl rbx, 1
	lea rbx, [rbx+rbx*4]
	mov rsi, [rbp+24]
	movzx rcx, BYTE [rsi]
	sub rcx, 0x30
	add rbx, rcx
	mov [rsp+8], rbx
	jmp .L7
	.L8:
	.L7:
	.L4:
	inc QWORD [rbp+24]
	mov rbx, [rbp+24]
	dec QWORD [rbp+32]
	mov rbx, [rbp+32]
	jmp .L3
	.L5:
	mov bl, [rsp+7]
	test bl, bl
	je .L10
	mov rbx, [rsp+8]
	neg rbx
	mov [rsp+8], rbx
	.L10:
	.L11:
	mov rbx, [rsp+8]
	mov [rbp+16], rbx
	.L0:
	leave
	ret


extern set_rounding:function
extern malloc:function
extern main:function
extern free:function
extern flush_stdout:function
extern realloc:function
extern string.str_equals:function
extern string.free:function
extern File.open:function
extern File.close:function
extern string.new:function
extern string.format:function


section .data align=16
__FP_TMP: times 4 dq 0
__GP_TMP: times 4 dq 0
global stdout:data
stdout:
dq stdout_raw
global stdin:data
stdin:
dq stdin_raw
global errno:data
errno:
dq 0
static stdout_buffer:data
stdout_buffer:
times 4096 db 0
static stdout_raw:data
stdout_raw:
dq 1
dq stdout_buffer
dq 4096
dq 0
dd 2
dd 1
static stdin_raw:data
stdin_raw:
dq 0
dq 0
dq 0
dq 0
dd 3
dd 2
extern File:data
extern fixed:data
extern string:data


section .rodata align=16
__FABS_MASKd: dq 0x7FFFFFFFFFFFFFFF, 0
__FABS_MASKs: dd 0x7FFFFFFF, 0, 0, 0
__FNEG_MASKd: dq 0x8000000000000000, 0
__FNEG_MASKs: dd 0x80000000, 0, 0, 0
STR0:
db "",10,"",0
dd 0
STR1:
db "(NULL)",0
times 7 db 0
STR2:
db "0123456789ABCDEF",0
times 5 db 0
STR3:
db "",10,"Expected %[ before %L to enclose text to align left",0
db 0
STR4:
db "",10,"Expected %[ before %R to enclose text to align right",0
STR5:
db "",10,"Expected %[ before %C to enclose text to center",0
times 5 db 0
STR6:
db "",10,"Expected %[ before %T to enclose text to truncate",10,"",0
dw 0
STR7:
db "true",0
db 0
STR8:
db "false",0
STR9:
db "",10,"Expected in to be in the range [1, 9] in format specifier %%0n",0
times 6 db 0
STR10:
db "",10,"Expected %[ before %*T to enclose text to truncate",0
dw 0
STR11:
db "",10,"Unexpected format specifier %%%*s",0
times 3 db 0
STR12:
db "",10,"Unexpected format specifier %%%c",0
dd 0
STR13:
db "input() error: %i",0
dd 0
STR14:
db "input_char() error: %i",0
times 7 db 0
FP0:
dq 1.0000000000
FP1:
dq 1000000000.0000000000
FP2:
dq 6.2831853072
FP3:
dq 32768.0000000000
FP4:
dq 0.0000000000
FP5:
dq 10.0000000000
