section .text
BITS 64
CPU X64
default ABS

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
	fld QWORD [rbp+16]
	fisttp QWORD [__FP_TMP]
	mov rcx, QWORD [__FP_TMP]
	mov [rbx+0], rcx
	fld QWORD [rbp+16]
	fld QWORD [FP0]
	fprem
	fstp st0
	fld QWORD [FP1]
	fmulp
	fisttp QWORD [__FP_TMP]
	mov rcx, QWORD [__FP_TMP]
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
	mov [__FP_TMP], rbx
	fild QWORD [__FP_TMP]
	mov rbx, [rsp+8]
	mov [__FP_TMP], rbx
	fild QWORD [__FP_TMP]
	fld QWORD [FP1]
	fdivp
	faddp
	fstp QWORD [rbp+16]
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
	mov rsi, [rdi+24]
	inc rsi
	mov rdi, [rbp+16]
	mov [rdi+24], rsi
	dec rsi
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
	mov rcx, [rbp+16]
	mov [rsp+0], rcx
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
	mov rcx, [rbp+16]
	mov [rsp+0], rcx
	call File.flush
	mov rbx, [rsp+8]
	add rsp, 16
	jmp .L9
	.L11:
	.L9:
	mov rcx, [rbp+24]
	inc rcx
	mov [rbp+24], rcx
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
	mov cl, [rbp+17]
	mov [rsp+1], cl
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
	mov [rsp+14], cl
	mov sil, [rbp+17]
	mov [rsp+1], sil
	call is_alpha
	mov bl, [rsp+15]
	mov cl, [rsp+14]
	mov sil, [rsp+0]
	add rsp, 16
	test sil, sil
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

global set_rounding:function
set_rounding:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	lea rbx, [rsp+14]
	fstcw [rbx]
	mov bx, [rsp+14]
	and bx, 0xf3ff
	mov [rsp+14], bx
	mov bx, [rsp+14]
	movzx cx, BYTE [rbp+16]
	shl cx, 8
	or bx, cx
	mov [rsp+14], bx
	lea rbx, [rsp+14]
	fldcw [rbx]
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
	fld QWORD [rbp+24]
	fld QWORD [FP2]
	fprem
	fstp st0
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
	fld QWORD [rbp+24]
	fld QWORD [FP2]
	fprem
	fstp st0
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
	fld QWORD [rbp+24]
	fld QWORD [FP2]
	fprem
	fstp st0
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
	xor bl, bl
	mov [rsp+0], bl
	call set_rounding
	add rsp, 16
	fld QWORD [rbp+24]
    frndint
    fstp QWORD [rbp+16]
	.L0:
	leave
	ret

global floor:function
floor:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov bl, 0x4
	mov [rsp+0], bl
	call set_rounding
	add rsp, 16
	fld QWORD [rbp+24]
    frndint
    fstp QWORD [rbp+16]
	.L0:
	leave
	ret

global ceil:function
ceil:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov bl, 0x8
	mov [rsp+0], bl
	call set_rounding
	add rsp, 16
	fld QWORD [rbp+24]
    frndint
    fstp QWORD [rbp+16]
	.L0:
	leave
	ret

global trunc:function
trunc:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov bl, 0xc
	mov [rsp+0], bl
	call set_rounding
	add rsp, 16
	fld QWORD [rbp+24]
    frndint
    fstp QWORD [rbp+16]
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
	fld QWORD [rbp+24]
	mov DWORD [__FP_TMP], 0x47000000
	fld DWORD [__FP_TMP]
	fmulp
	fstp QWORD [rsp+8]
	call round
	mov ebx, [rsp+28]
	fld QWORD [rsp+0]
	add rsp, 32
	fisttp DWORD [__FP_TMP]
	mov ebx, DWORD [__FP_TMP]
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
	mov [__FP_TMP], rbx
	fild QWORD [__FP_TMP]
	mov DWORD [__FP_TMP], 0x47000000
	fld DWORD [__FP_TMP]
	fdivp
	fstp QWORD [rbp+16]
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
	mov rcx, [rbp+32]
	mov [rsp+8], rcx
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

global string.set:function
string.set:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	mov rcx, [rbp+24]
	mov [rbx+0], rcx
	mov rbx, [rbp+16]
	mov rsi, [rbp+32]
	mov rdi, 0xffffffffffffffff
	cmp rsi, rdi
	sete sil
	test sil, sil
	je .L1
	sub rsp, 32
	mov [rsp+24], rbx
	mov [rsp+23], sil
	mov rcx, [rbp+24]
	mov [rsp+8], rcx
	call strlen
	mov rbx, [rsp+24]
	mov sil, [rsp+23]
	mov rcx, [rsp+0]
	add rsp, 32
	jmp .L2
	.L1:
	mov rcx, [rbp+32]
	.L2:
	mov [rbx+8], rcx
	mov rbx, [rbp+16]
	xor rcx, rcx
	mov [rbx+16], rcx
	mov rbx, [rbp+16]
	mov rcx, [rbp+40]
	mov [rbx+24], rcx
	.L0:
	leave
	ret

global string.str:function
string.str:
	push rbp
	mov rbp, rsp
	mov rcx, [rbp+24]
	mov rbx, [rcx+24]
	mov rcx, 0x2
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L1
	sub rsp, 32
	mov [rsp+31], sil
	mov rcx, [rbp+24]
	mov rbx, [rcx+0]
	mov [rsp+8], rbx
	call string.str
	mov sil, [rsp+31]
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rbp+16], rbx
	jmp .L0
	.L1:
	.L2:
	mov rdi, [rbp+24]
	mov cl, [rdi+0]
	test cl, cl
	je .L3
	mov rdi, [rbp+24]
	mov rbx, [rdi+0]
	mov r8, [rbp+24]
	mov rdi, [r8+16]
	add rbx, rdi
	jmp .L4
	.L3:
	xor rbx, rbx
	.L4:
	mov [rbp+16], rbx
	.L0:
	leave
	ret

global string.length:function
string.length:
	push rbp
	mov rbp, rsp
	mov rdi, [rbp+24]
	mov rbx, [rdi+24]
	mov rdi, 0x2
	cmp rbx, rdi
	sete bl
	test bl, bl
	je .L1
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov rdi, [rbp+24]
	mov rbx, [rdi+0]
	mov [rsp+8], rbx
	call string.length
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rbp+16], rbx
	jmp .L0
	.L1:
	.L2:
	mov rdi, [rbp+24]
	mov rbx, [rdi+8]
	mov [rbp+16], rbx
	.L0:
	leave
	ret

global string.print:function
string.print:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov rbx, [rbp+24]
	mov [rsp+0], rbx
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	call string.str
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+8], rbx
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	call string.length
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+16], rbx
	call File.write
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	add rsp, 32
	.L0:
	leave
	ret

global string.compare:function
string.compare:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	sub rsp, 32
	mov [rsp+24], rbx
	mov [rsp+23], cl
	mov [rsp+22], sil
	mov rdi, [rbp+24]
	mov [rsp+8], rdi
	call string.length
	mov rbx, [rsp+24]
	mov cl, [rsp+23]
	mov sil, [rsp+22]
	mov rdi, [rsp+0]
	add rsp, 32
	sub rsp, 48
	mov [rsp+40], rbx
	mov [rsp+39], cl
	mov [rsp+38], sil
	mov [rsp+24], rdi
	mov r8, [rbp+32]
	mov [rsp+8], r8
	call string.length
	mov rbx, [rsp+40]
	mov cl, [rsp+39]
	mov sil, [rsp+38]
	mov rdi, [rsp+24]
	mov r8, [rsp+0]
	add rsp, 48
	cmp rdi, r8
	setb dil
	test dil, dil
	je .L1
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	call string.length
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	mov rbx, [rsp+0]
	add rsp, 32
	jmp .L2
	.L1:
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call string.length
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	mov rbx, [rsp+0]
	add rsp, 32
	.L2:
	mov [rsp+8], rbx
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	call string.str
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+8], rbx
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call string.str
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+16], rbx
	mov rbx, [rsp+40]
	mov [rsp+24], rbx
	call strcmp
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
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
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	call string.compare
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	mov rbx, [rsp+0]
	add rsp, 32
	xor r8, r8
	cmp rbx, r8
	sete bl
	mov [rbp+16], bl
	.L0:
	leave
	ret

global string.is_heap:function
string.is_heap:
	push rbp
	mov rbp, rsp
	mov r8, [rbp+24]
	mov rbx, [r8+24]
	mov r8, 0x1
	cmp rbx, r8
	sete bl
	mov [rbp+16], bl
	.L0:
	leave
	ret

global string.is_stack:function
string.is_stack:
	push rbp
	mov rbp, rsp
	mov r8, [rbp+24]
	mov rbx, [r8+24]
	mov r8, 0x2
	cmp rbx, r8
	sete bl
	test bl, bl
	je .L1
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov r8, [rbp+24]
	mov rbx, [r8+0]
	mov [rsp+8], rbx
	call string.is_stack
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	mov bl, [rsp+0]
	add rsp, 32
	mov [rbp+16], bl
	.L1:
	.L2:
	mov r8, [rbp+24]
	mov rbx, [r8+24]
	xor r8, r8
	cmp rbx, r8
	sete bl
	mov [rbp+16], bl
	.L0:
	leave
	ret

global string.from_str:function
string.from_str:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	mov [rsp+47], cl
	mov [rsp+46], sil
	mov [rsp+45], dil
	mov rbx, [rbp+16]
	mov [rsp+0], rbx
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	xor rbx, rbx
	mov [rsp+24], rbx
	call string.set
	mov cl, [rsp+47]
	mov sil, [rsp+46]
	mov dil, [rsp+45]
	add rsp, 48
	.L0:
	leave
	ret

global string.from_heap:function
string.from_heap:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	mov [rsp+47], cl
	mov [rsp+46], sil
	mov [rsp+45], dil
	mov rbx, [rbp+16]
	mov [rsp+0], rbx
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	mov rbx, 0x1
	mov [rsp+24], rbx
	call string.set
	mov cl, [rsp+47]
	mov sil, [rsp+46]
	mov dil, [rsp+45]
	add rsp, 48
	.L0:
	leave
	ret

global string.share:function
string.share:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	mov [rsp+47], cl
	mov [rsp+46], sil
	mov [rsp+45], dil
	mov rbx, [rbp+16]
	mov [rsp+0], rbx
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	xor rbx, rbx
	mov [rsp+16], rbx
	mov rbx, 0x2
	mov [rsp+24], rbx
	call string.set
	mov cl, [rsp+47]
	mov sil, [rsp+46]
	mov dil, [rsp+45]
	add rsp, 48
	.L0:
	leave
	ret

global print_str:function
print_str:
	push rbp
	mov rbp, rsp
	mov r8, [rbp+16]
	test r8, r8
	sete bl
	test bl, bl
	je .L1
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, STR1
	mov [rsp+0], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+8], rbx
	mov rbx, QWORD [stdout]
	mov [rsp+16], rbx
	call print_str
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	jmp .L0
	.L1:
	.L2:
	mov rbx, [rbp+24]
	mov r8, 0xffffffffffffffff
	cmp rbx, r8
	sete bl
	test bl, bl
	je .L3
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	call strlen
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rbp+24], rbx
	.L3:
	.L4:
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	call File.write
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	.L0:
	leave
	ret

global print_char:function
print_char:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, [rbp+24]
	mov [rsp+0], rbx
	lea rbx, [rbp+16]
	mov [rsp+8], rbx
	mov rbx, 0x1
	mov [rsp+16], rbx
	call File.write
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
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
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	sub rsp, 48
	mov [rsp+47], cl
	mov [rsp+46], sil
	mov [rsp+45], dil
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	lea rbx, [rsp+80]
	mov [rsp+16], rbx
	mov rbx, 0x40
	mov [rsp+24], rbx
	xor bl, bl
	mov [rsp+32], bl
	call int_to_string
	mov cl, [rsp+47]
	mov sil, [rsp+46]
	mov dil, [rsp+45]
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rsp+0], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	call print_str
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
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
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	sub rsp, 48
	mov [rsp+47], cl
	mov [rsp+46], sil
	mov [rsp+45], dil
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	lea rbx, [rsp+80]
	mov [rsp+16], rbx
	mov rbx, 0x40
	mov [rsp+24], rbx
	xor bl, bl
	mov [rsp+32], bl
	call uint_to_string
	mov cl, [rsp+47]
	mov sil, [rsp+46]
	mov dil, [rsp+45]
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rsp+0], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	call print_str
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
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
	mov r8, 0x3f
	xor r9b, r9b
	mov [rbx+r8*1], r9b
	mov rbx, STR2
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	add rbx, 0x1e
	mov [rsp+0], rbx
	mov rbx, [rbp+16]
	xor r8, r8
	cmp rbx, r8
	sete bl
	test bl, bl
	je .L1
	mov rbx, [rsp+0]
	dec rbx
	mov [rsp+0], rbx
	inc rbx
	mov r8b, 0x30
	mov [rbx], r8b
	.L1:
	.L2:
	.L3:
	mov rbx, [rbp+16]
	test rbx, rbx
	je .L5
	mov rbx, [rsp+0]
	mov r8, [rsp+8]
	mov r9, [rbp+16]
	and r9, 0xf
	mov r10b, [r8+r9*1]
	mov [rbx], r10b
	.L4:
	mov rbx, [rbp+16]
	shr rbx, 4
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
	mov r8b, 0x78
	mov [rbx], r8b
	mov rbx, [rsp+0]
	mov r8b, 0x30
	mov [rbx], r8b
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, [rsp+32]
	mov [rsp+0], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	call print_str
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
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
	xor r8, r8
	cmp rbx, r8
	setl bl
	test bl, bl
	je .L1
	sub rsp, 16
	mov [rsp+15], cl
	mov [rsp+14], sil
	mov [rsp+13], dil
	mov bl, 0x2d
	mov [rsp+0], bl
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	call print_char
	mov cl, [rsp+15]
	mov sil, [rsp+14]
	mov dil, [rsp+13]
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
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, [rsp+72]
	mov [rsp+0], rbx
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	call print_udecimal
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	sub rsp, 16
	mov [rsp+15], cl
	mov [rsp+14], sil
	mov [rsp+13], dil
	mov bl, 0x2e
	mov [rsp+0], bl
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	call print_char
	mov cl, [rsp+15]
	mov sil, [rsp+14]
	mov dil, [rsp+13]
	add rsp, 16
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	sub rsp, 48
	mov [rsp+47], cl
	mov [rsp+46], sil
	mov [rsp+45], dil
	mov rbx, [rsp+112]
	mov [rsp+8], rbx
	lea rbx, [rsp+80]
	mov [rsp+16], rbx
	mov rbx, 0x5
	mov [rsp+24], rbx
	mov bl, 0x30
	mov [rsp+32], bl
	call uint_to_string
	mov cl, [rsp+47]
	mov sil, [rsp+46]
	mov dil, [rsp+45]
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rsp+0], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	call print_str
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	.L0:
	leave
	ret

global print_double:function
print_double:
	push rbp
	mov rbp, rsp
	sub rsp, 160
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
	mov [rsp+15], cl
	mov [rsp+14], sil
	mov [rsp+13], dil
	mov bl, 0x2d
	mov [rsp+0], bl
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call print_char
	mov cl, [rsp+15]
	mov sil, [rsp+14]
	mov dil, [rsp+13]
	add rsp, 16
	fld QWORD [rbp+16]
	fchs
	fstp QWORD [rbp+16]
	.L1:
	.L2:
	fld QWORD [rbp+16]
	fisttp QWORD [__FP_TMP]
	mov rbx, QWORD [__FP_TMP]
	mov [rsp+16], rbx
	sub rsp, 32
	mov [rsp+24], rbx
	mov [rsp+23], cl
	mov [rsp+22], sil
	mov [rsp+21], dil
	fld QWORD [rbp+16]
	mov r8, [rsp+48]
	mov [__FP_TMP], r8
	fild QWORD [__FP_TMP]
	fsubp
	sub rsp, 48
	mov [rsp+40], rbx
	mov [rsp+39], cl
	mov [rsp+38], sil
	mov [rsp+37], dil
	fld QWORD [FP4]
	fstp QWORD [rsp+8]
	mov r8, [rbp+24]
	mov [__FP_TMP], r8
	fild QWORD [__FP_TMP]
	fstp QWORD [rsp+16]
	call pow
	mov rbx, [rsp+40]
	mov cl, [rsp+39]
	mov sil, [rsp+38]
	mov dil, [rsp+37]
	fld QWORD [rsp+0]
	add rsp, 48
	fmulp
	fstp QWORD [rsp+8]
	call round
	mov rbx, [rsp+24]
	mov cl, [rsp+23]
	mov sil, [rsp+22]
	mov dil, [rsp+21]
	fld QWORD [rsp+0]
	add rsp, 32
	fisttp QWORD [__FP_TMP]
	mov rbx, QWORD [__FP_TMP]
	mov [rsp+8], rbx
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, [rsp+48]
	mov [rsp+0], rbx
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call print_udecimal
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	sub rsp, 16
	mov [rsp+15], cl
	mov [rsp+14], sil
	mov [rsp+13], dil
	mov bl, 0x2e
	mov [rsp+0], bl
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call print_char
	mov cl, [rsp+15]
	mov sil, [rsp+14]
	mov dil, [rsp+13]
	add rsp, 16
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	sub rsp, 48
	mov [rsp+47], cl
	mov [rsp+46], sil
	mov [rsp+45], dil
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
	mov cl, [rsp+47]
	mov sil, [rsp+46]
	mov dil, [rsp+45]
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rsp+0], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	call print_str
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	.L0:
	leave
	ret

static left_align:function
left_align:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+24]
	mov r8, 0xffffffffffffffff
	cmp rbx, r8
	sete bl
	test bl, bl
	je .L1
	sub rsp, 16
	mov [rsp+15], cl
	mov [rsp+14], sil
	mov [rsp+13], dil
	mov rbx, STR3
	mov [rsp+0], rbx
	call error
	mov cl, [rsp+15]
	mov sil, [rsp+14]
	mov dil, [rsp+13]
	add rsp, 16
	.L1:
	.L2:
	mov r8, [rbp+16]
	mov rbx, [r8+24]
	mov r8, [rbp+24]
	sub rbx, r8
	mov r8, [rbp+32]
	cmp rbx, r8
	setae bl
	test bl, bl
	je .L3
	jmp .L0
	.L3:
	.L4:
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov r8, [rbp+16]
	mov rbx, [r8+8]
	mov r9, [rbp+16]
	mov r8, [r9+24]
	add rbx, r8
	mov [rsp+0], rbx
	mov bl, [rbp+40]
	mov [rsp+8], bl
	mov rbx, [rbp+32]
	mov r9, [rbp+16]
	mov r8, [r9+24]
	sub rbx, r8
	mov r8, [rbp+24]
	add rbx, r8
	mov [rsp+16], rbx
	call memset
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	mov rbx, [rbp+16]
	mov r8, [rbp+24]
	mov r9, [rbp+32]
	add r8, r9
	mov [rbx+24], r8
	.L0:
	leave
	ret

static right_align:function
right_align:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, [rbp+24]
	mov r8, 0xffffffffffffffff
	cmp rbx, r8
	sete bl
	test bl, bl
	je .L1
	sub rsp, 16
	mov [rsp+15], cl
	mov [rsp+14], sil
	mov [rsp+13], dil
	mov rbx, STR4
	mov [rsp+0], rbx
	call error
	mov cl, [rsp+15]
	mov sil, [rsp+14]
	mov dil, [rsp+13]
	add rsp, 16
	.L1:
	.L2:
	mov r8, [rbp+16]
	mov rbx, [r8+24]
	mov r8, [rbp+24]
	sub rbx, r8
	mov r8, [rbp+32]
	cmp rbx, r8
	setae bl
	test bl, bl
	je .L3
	jmp .L0
	.L3:
	.L4:
	mov rbx, [rbp+24]
	mov r8, [rbp+32]
	add rbx, r8
	mov r9, [rbp+16]
	mov r8, [r9+24]
	mov r9, [rbp+24]
	sub r8, r9
	sub rbx, r8
	mov [rsp+8], rbx
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov r8, [rbp+16]
	mov rbx, [r8+8]
	mov r8, [rsp+40]
	add rbx, r8
	mov [rsp+0], rbx
	mov r8, [rbp+16]
	mov rbx, [r8+8]
	mov r8, [rbp+24]
	add rbx, r8
	mov [rsp+8], rbx
	mov r8, [rbp+16]
	mov rbx, [r8+24]
	mov r8, [rbp+24]
	sub rbx, r8
	mov [rsp+16], rbx
	call memmove
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov r8, [rbp+16]
	mov rbx, [r8+8]
	mov r8, [rbp+24]
	add rbx, r8
	mov [rsp+0], rbx
	mov bl, [rbp+40]
	mov [rsp+8], bl
	mov rbx, [rsp+40]
	mov r8, [rbp+24]
	sub rbx, r8
	mov [rsp+16], rbx
	call memset
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	mov rbx, [rbp+16]
	mov r8, [rbp+24]
	mov r9, [rbp+32]
	add r8, r9
	mov [rbx+24], r8
	.L0:
	leave
	ret

static center:function
center:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, [rbp+24]
	mov r8, 0xffffffffffffffff
	cmp rbx, r8
	sete bl
	test bl, bl
	je .L1
	sub rsp, 16
	mov [rsp+15], cl
	mov [rsp+14], sil
	mov [rsp+13], dil
	mov rbx, STR5
	mov [rsp+0], rbx
	call error
	mov cl, [rsp+15]
	mov sil, [rsp+14]
	mov dil, [rsp+13]
	add rsp, 16
	.L1:
	.L2:
	mov r8, [rbp+16]
	mov rbx, [r8+24]
	mov r8, [rbp+24]
	sub rbx, r8
	mov r8, [rbp+32]
	cmp rbx, r8
	setae bl
	test bl, bl
	je .L3
	jmp .L0
	.L3:
	.L4:
	mov rbx, [rbp+32]
	mov r9, [rbp+16]
	mov r8, [r9+24]
	mov r9, [rbp+24]
	sub r8, r9
	sub rbx, r8
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov r8, [rsp+8]
	shr r8, 1
	add rbx, r8
	mov [rsp+0], rbx
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov r8, [rbp+16]
	mov rbx, [r8+8]
	mov r8, [rsp+32]
	add rbx, r8
	mov [rsp+0], rbx
	mov r8, [rbp+16]
	mov rbx, [r8+8]
	mov r8, [rbp+24]
	add rbx, r8
	mov [rsp+8], rbx
	mov r8, [rbp+16]
	mov rbx, [r8+24]
	mov r8, [rbp+24]
	sub rbx, r8
	mov [rsp+16], rbx
	call memmove
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov r8, [rbp+16]
	mov rbx, [r8+8]
	mov r8, [rbp+24]
	add rbx, r8
	mov [rsp+0], rbx
	mov bl, [rbp+40]
	mov [rsp+8], bl
	mov rbx, [rsp+32]
	mov r8, [rbp+24]
	sub rbx, r8
	mov [rsp+16], rbx
	call memset
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov r8, [rbp+16]
	mov rbx, [r8+8]
	mov r8, [rsp+32]
	add rbx, r8
	mov r9, [rbp+16]
	mov r8, [r9+24]
	add rbx, r8
	mov r8, [rbp+24]
	sub rbx, r8
	mov [rsp+0], rbx
	mov bl, [rbp+40]
	mov [rsp+8], bl
	mov rbx, [rsp+40]
	shr rbx, 1
	mov r8, [rsp+40]
	and r8, 0x1
	add rbx, r8
	mov [rsp+16], rbx
	call memset
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	mov rbx, [rbp+16]
	mov r8, [rbp+24]
	mov r9, [rbp+32]
	add r8, r9
	mov [rbx+24], r8
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
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	call strlen
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+16], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+8], rbx
	sub rsp, 16
	.L1:
	mov rbx, [rsp+32]
	test rbx, rbx
	je .L2
	sub rsp, 48
	mov [rsp+47], cl
	mov [rsp+46], sil
	mov [rsp+45], dil
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	mov bl, 0x25
	mov [rsp+16], bl
	mov rbx, [rsp+80]
	mov [rsp+24], rbx
	xor bl, bl
	mov [rsp+32], bl
	call strfind
	mov cl, [rsp+47]
	mov sil, [rsp+46]
	mov dil, [rsp+45]
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rsp+8], rbx
	mov rbx, [rsp+8]
	mov r8, 0xffffffffffffffff
	cmp rbx, r8
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
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, [rbp+16]
	mov [rsp+0], rbx
	mov rbx, [rsp+40]
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	call print_str
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	jmp .L6
	.L5:
	mov rbx, [rbp+16]
	inc rbx
	mov r8b, [rbx]
	mov bl, 0x69
	cmp r8b, bl
	sete bl
	test bl, bl
	je .L7
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, [rbp+24]
	mov r8, [rsp+72]
	inc r8
	mov [rsp+72], r8
	dec r8
	mov r9, [rbx+r8*8]
	mov [rsp+0], r9
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call print_decimal
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	jmp .L6
	.L7:
	mov rbx, [rbp+16]
	inc rbx
	mov r8b, [rbx]
	mov bl, 0x75
	cmp r8b, bl
	sete bl
	test bl, bl
	je .L8
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, [rbp+24]
	mov r8, [rsp+72]
	inc r8
	mov [rsp+72], r8
	dec r8
	mov r9, [rbx+r8*8]
	mov [rsp+0], r9
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call print_udecimal
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	jmp .L6
	.L8:
	mov rbx, [rbp+16]
	inc rbx
	mov r8b, [rbx]
	mov bl, 0x78
	cmp r8b, bl
	sete bl
	test bl, bl
	je .L9
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, [rbp+24]
	mov r8, [rsp+72]
	inc r8
	mov [rsp+72], r8
	dec r8
	mov r9, [rbx+r8*8]
	mov [rsp+0], r9
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call print_hex
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	jmp .L6
	.L9:
	mov rbx, [rbp+16]
	inc rbx
	mov r8b, [rbx]
	mov bl, 0x73
	cmp r8b, bl
	sete bl
	test bl, bl
	je .L10
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, [rbp+24]
	mov r8, [rsp+72]
	inc r8
	mov [rsp+72], r8
	dec r8
	mov r9, [rbx+r8*8]
	mov [rsp+0], r9
	mov rbx, 0xffffffffffffffff
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	call print_str
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	jmp .L6
	.L10:
	mov rbx, [rbp+16]
	inc rbx
	mov r8b, [rbx]
	mov bl, 0x53
	cmp r8b, bl
	sete bl
	test bl, bl
	je .L11
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, [rbp+24]
	mov r8, [rsp+72]
	inc r8
	mov [rsp+72], r8
	dec r8
	mov r9, [rbx+r8*8]
	mov [rsp+0], r9
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call string.print
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	jmp .L6
	.L11:
	mov rbx, [rbp+16]
	inc rbx
	mov r8b, [rbx]
	mov bl, 0x63
	cmp r8b, bl
	sete bl
	test bl, bl
	je .L12
	sub rsp, 16
	mov [rsp+15], cl
	mov [rsp+14], sil
	mov [rsp+13], dil
	mov rbx, [rbp+24]
	mov r8, [rsp+56]
	inc r8
	mov [rsp+56], r8
	dec r8
	mov r9b, [rbx+r8*8]
	mov [rsp+0], r9b
	mov rbx, QWORD [stdout]
	mov [rsp+8], rbx
	call print_char
	mov cl, [rsp+15]
	mov sil, [rsp+14]
	mov dil, [rsp+13]
	add rsp, 16
	jmp .L6
	.L12:
	mov rbx, [rbp+16]
	inc rbx
	mov r8b, [rbx]
	mov bl, 0x5b
	cmp r8b, bl
	sete bl
	test bl, bl
	je .L13
	mov r8, [rbp+32]
	mov rbx, [r8+24]
	mov [rsp+24], rbx
	jmp .L6
	.L13:
	mov rbx, [rbp+16]
	inc rbx
	mov r8b, [rbx]
	mov bl, 0x4c
	cmp r8b, bl
	sete bl
	test bl, bl
	je .L14
	sub rsp, 48
	mov [rsp+47], cl
	mov [rsp+46], sil
	mov [rsp+45], dil
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, [rsp+72]
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov r8, [rsp+88]
	inc r8
	mov [rsp+88], r8
	dec r8
	mov r9, [rbx+r8*8]
	mov [rsp+16], r9
	mov bl, 0x20
	mov [rsp+24], bl
	call left_align
	mov cl, [rsp+47]
	mov sil, [rsp+46]
	mov dil, [rsp+45]
	add rsp, 48
	jmp .L6
	.L14:
	mov rbx, [rbp+16]
	inc rbx
	mov r8b, [rbx]
	mov bl, 0x52
	cmp r8b, bl
	sete bl
	test bl, bl
	je .L15
	sub rsp, 48
	mov [rsp+47], cl
	mov [rsp+46], sil
	mov [rsp+45], dil
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, [rsp+72]
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov r8, [rsp+88]
	inc r8
	mov [rsp+88], r8
	dec r8
	mov r9, [rbx+r8*8]
	mov [rsp+16], r9
	mov bl, 0x20
	mov [rsp+24], bl
	call right_align
	mov cl, [rsp+47]
	mov sil, [rsp+46]
	mov dil, [rsp+45]
	add rsp, 48
	jmp .L6
	.L15:
	mov rbx, [rbp+16]
	inc rbx
	mov r8b, [rbx]
	mov bl, 0x43
	cmp r8b, bl
	sete bl
	test bl, bl
	je .L16
	sub rsp, 48
	mov [rsp+47], cl
	mov [rsp+46], sil
	mov [rsp+45], dil
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, [rsp+72]
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov r8, [rsp+88]
	inc r8
	mov [rsp+88], r8
	dec r8
	mov r9, [rbx+r8*8]
	mov [rsp+16], r9
	mov bl, 0x20
	mov [rsp+24], bl
	call center
	mov cl, [rsp+47]
	mov sil, [rsp+46]
	mov dil, [rsp+45]
	add rsp, 48
	jmp .L6
	.L16:
	mov rbx, [rbp+16]
	inc rbx
	mov r8b, [rbx]
	mov bl, 0x41
	cmp r8b, bl
	sete bl
	test bl, bl
	je .L17
	sub rsp, 16
	mov rbx, [rbp+24]
	mov r8, [rsp+56]
	inc r8
	mov [rsp+56], r8
	dec r8
	mov r9, [rbx+r8*8]
	mov [rsp+8], r9
	sub rsp, 48
	mov [rsp+47], cl
	mov [rsp+46], sil
	mov [rsp+45], dil
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	xor rbx, rbx
	mov [rsp+8], rbx
	mov rbx, [rsp+56]
	mov [rsp+16], rbx
	mov bl, 0x20
	mov [rsp+24], bl
	call left_align
	mov cl, [rsp+47]
	mov sil, [rsp+46]
	mov dil, [rsp+45]
	add rsp, 48
	add rsp, 16
	jmp .L6
	.L17:
	mov rbx, [rbp+16]
	inc rbx
	mov r8b, [rbx]
	mov bl, 0x54
	cmp r8b, bl
	sete bl
	test bl, bl
	je .L18
	sub rsp, 16
	mov rbx, [rsp+40]
	mov r8, 0xffffffffffffffff
	cmp rbx, r8
	sete bl
	test bl, bl
	je .L19
	sub rsp, 16
	mov [rsp+15], cl
	mov [rsp+14], sil
	mov [rsp+13], dil
	mov rbx, STR6
	mov [rsp+0], rbx
	call error
	mov cl, [rsp+15]
	mov sil, [rsp+14]
	mov dil, [rsp+13]
	add rsp, 16
	.L19:
	.L20:
	mov rbx, [rbp+24]
	mov r8, [rsp+56]
	inc r8
	mov [rsp+56], r8
	dec r8
	mov r9, [rbx+r8*8]
	mov [rsp+8], r9
	mov r8, [rbp+32]
	mov rbx, [r8+24]
	mov r8, [rsp+40]
	sub rbx, r8
	mov r8, [rsp+8]
	cmp rbx, r8
	seta bl
	test bl, bl
	je .L21
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov r8, [rbp+32]
	mov rbx, [r8+8]
	mov r8, [rsp+72]
	add rbx, r8
	mov r8, [rsp+40]
	add rbx, r8
	mov [rsp+0], rbx
	xor bl, bl
	mov [rsp+8], bl
	mov r8, [rbp+32]
	mov rbx, [r8+24]
	mov r8, [rsp+72]
	sub rbx, r8
	mov r8, [rsp+40]
	sub rbx, r8
	mov [rsp+16], rbx
	call memset
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	mov rbx, [rbp+32]
	mov r8, [rsp+40]
	mov r9, [rsp+8]
	add r8, r9
	mov [rbx+24], r8
	.L21:
	.L22:
	add rsp, 16
	jmp .L6
	.L18:
	mov rbx, [rbp+16]
	inc rbx
	mov r8b, [rbx]
	mov bl, 0x62
	cmp r8b, bl
	sete bl
	test bl, bl
	je .L23
	mov rbx, [rbp+24]
	mov r8, [rsp+40]
	inc r8
	mov [rsp+40], r8
	dec r8
	mov r9, [rbx+r8*8]
	test r9, r9
	je .L24
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, STR7
	mov [rsp+0], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	call print_str
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	jmp .L25
	.L24:
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, STR8
	mov [rsp+0], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	call print_str
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	.L25:
	jmp .L6
	.L23:
	mov rbx, [rbp+16]
	inc rbx
	mov r8b, [rbx]
	mov bl, 0x46
	cmp r8b, bl
	sete bl
	test bl, bl
	je .L26
	sub rsp, 16
	mov [rsp+15], cl
	mov [rsp+14], sil
	mov [rsp+13], dil
	mov rbx, [rbp+24]
	mov r8, [rsp+56]
	inc r8
	mov [rsp+56], r8
	dec r8
	mov r9d, [rbx+r8*8]
	mov [rsp+0], r9d
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call print_fixed
	mov cl, [rsp+15]
	mov sil, [rsp+14]
	mov dil, [rsp+13]
	add rsp, 16
	jmp .L6
	.L26:
	mov rbx, [rbp+16]
	inc rbx
	mov r8b, [rbx]
	mov bl, 0x66
	cmp r8b, bl
	sete bl
	test bl, bl
	je .L27
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, [rbp+24]
	mov r8, [rsp+72]
	inc r8
	mov [rsp+72], r8
	dec r8
	fld QWORD [rbx+r8*8]
	fstp QWORD [rsp+0]
	mov rbx, 0x4
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	call print_double
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	jmp .L6
	.L27:
	mov rbx, [rbp+16]
	inc rbx
	mov r8b, [rbx]
	mov bl, 0x30
	cmp r8b, bl
	sete bl
	test bl, bl
	je .L28
	sub rsp, 80
	mov rbx, [rbp+16]
	inc rbx
	mov [rbp+16], rbx
	mov rbx, [rbp+16]
	inc rbx
	mov r8b, [rbx]
	mov bl, 0x31
	cmp r8b, bl
	setb bl
	test bl, bl
	jne .L31
	mov r8, [rbp+16]
	inc r8
	mov r9b, [r8]
	mov r8b, 0x39
	cmp r9b, r8b
	seta bl
	.L31:
	test bl, bl
	je .L29
	sub rsp, 16
	mov [rsp+15], cl
	mov [rsp+14], sil
	mov [rsp+13], dil
	mov rbx, STR9
	mov [rsp+0], rbx
	call error
	mov cl, [rsp+15]
	mov sil, [rsp+14]
	mov dil, [rsp+13]
	add rsp, 16
	.L29:
	.L30:
	mov rbx, [rbp+16]
	inc rbx
	movzx r8, BYTE [rbx]
	sub r8, 0x30
	mov [rsp+8], r8
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	sub rsp, 48
	mov [rsp+47], cl
	mov [rsp+46], sil
	mov [rsp+45], dil
	mov rbx, [rbp+24]
	mov r8, [rsp+200]
	inc r8
	mov [rsp+200], r8
	dec r8
	mov r9, [rbx+r8*8]
	mov [rsp+8], r9
	lea rbx, [rsp+96]
	mov [rsp+16], rbx
	mov rbx, [rsp+88]
	inc rbx
	mov [rsp+24], rbx
	mov bl, 0x30
	mov [rsp+32], bl
	call uint_to_string
	mov cl, [rsp+47]
	mov sil, [rsp+46]
	mov dil, [rsp+45]
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rsp+0], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	call print_str
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	add rsp, 80
	jmp .L6
	.L28:
	mov rbx, [rbp+16]
	inc rbx
	mov r8b, [rbx]
	mov bl, 0x25
	cmp r8b, bl
	sete bl
	test bl, bl
	je .L32
	sub rsp, 16
	mov [rsp+15], cl
	mov [rsp+14], sil
	mov [rsp+13], dil
	mov bl, 0x25
	mov [rsp+0], bl
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	call print_char
	mov cl, [rsp+15]
	mov sil, [rsp+14]
	mov dil, [rsp+13]
	add rsp, 16
	jmp .L6
	.L32:
	mov rbx, [rbp+16]
	inc rbx
	mov r8b, [rbx]
	mov bl, 0x2a
	cmp r8b, bl
	sete bl
	test bl, bl
	je .L33
	sub rsp, 16
	mov rbx, [rbp+16]
	inc rbx
	mov [rbp+16], rbx
	mov rbx, [rsp+48]
	dec rbx
	mov [rsp+48], rbx
	mov rbx, [rbp+24]
	mov r8, [rsp+56]
	inc r8
	mov [rsp+56], r8
	dec r8
	mov r9, [rbx+r8*8]
	mov [rsp+8], r9
	mov rbx, [rbp+16]
	inc rbx
	mov r8b, [rbx]
	mov bl, 0x73
	cmp r8b, bl
	sete bl
	test bl, bl
	je .L34
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, [rbp+24]
	mov r8, [rsp+88]
	inc r8
	mov [rsp+88], r8
	dec r8
	mov r9, [rbx+r8*8]
	mov [rsp+0], r9
	mov rbx, [rsp+40]
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	call print_str
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	jmp .L35
	.L34:
	mov rbx, [rbp+16]
	inc rbx
	mov r8b, [rbx]
	mov bl, 0x63
	cmp r8b, bl
	sete bl
	test bl, bl
	je .L36
	sub rsp, 16
	mov rbx, [rbp+24]
	mov r8, [rsp+72]
	inc r8
	mov [rsp+72], r8
	dec r8
	mov r9b, [rbx+r8*8]
	mov [rsp+15], r9b
	mov rbx, [rsp+24]
	.L37:
	test rbx, rbx
	je .L39
	sub rsp, 32
	mov [rsp+24], rbx
	mov [rsp+23], cl
	mov [rsp+22], sil
	mov [rsp+21], dil
	mov r8b, [rsp+47]
	mov [rsp+0], r8b
	mov r8, [rbp+32]
	mov [rsp+8], r8
	call print_char
	mov rbx, [rsp+24]
	mov cl, [rsp+23]
	mov sil, [rsp+22]
	mov dil, [rsp+21]
	add rsp, 32
	.L38:
	dec rbx
	jmp .L37
	.L39:
	add rsp, 16
	jmp .L35
	.L36:
	mov rbx, [rbp+16]
	inc rbx
	mov r8b, [rbx]
	mov bl, 0x4c
	cmp r8b, bl
	sete bl
	test bl, bl
	je .L40
	sub rsp, 16
	mov rbx, [rbp+24]
	mov r8, [rsp+72]
	inc r8
	mov [rsp+72], r8
	dec r8
	mov r9b, [rbx+r8*8]
	mov [rsp+15], r9b
	sub rsp, 48
	mov [rsp+47], cl
	mov [rsp+46], sil
	mov [rsp+45], dil
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, [rsp+104]
	mov [rsp+8], rbx
	mov rbx, [rsp+72]
	mov [rsp+16], rbx
	mov bl, [rsp+63]
	mov [rsp+24], bl
	call left_align
	mov cl, [rsp+47]
	mov sil, [rsp+46]
	mov dil, [rsp+45]
	add rsp, 48
	add rsp, 16
	jmp .L35
	.L40:
	mov rbx, [rbp+16]
	inc rbx
	mov r8b, [rbx]
	mov bl, 0x52
	cmp r8b, bl
	sete bl
	test bl, bl
	je .L41
	sub rsp, 16
	mov rbx, [rbp+24]
	mov r8, [rsp+72]
	inc r8
	mov [rsp+72], r8
	dec r8
	mov r9b, [rbx+r8*8]
	mov [rsp+15], r9b
	sub rsp, 48
	mov [rsp+47], cl
	mov [rsp+46], sil
	mov [rsp+45], dil
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, [rsp+104]
	mov [rsp+8], rbx
	mov rbx, [rsp+72]
	mov [rsp+16], rbx
	mov bl, [rsp+63]
	mov [rsp+24], bl
	call right_align
	mov cl, [rsp+47]
	mov sil, [rsp+46]
	mov dil, [rsp+45]
	add rsp, 48
	add rsp, 16
	jmp .L35
	.L41:
	mov rbx, [rbp+16]
	inc rbx
	mov r8b, [rbx]
	mov bl, 0x43
	cmp r8b, bl
	sete bl
	test bl, bl
	je .L42
	sub rsp, 16
	mov rbx, [rbp+24]
	mov r8, [rsp+72]
	inc r8
	mov [rsp+72], r8
	dec r8
	mov r9b, [rbx+r8*8]
	mov [rsp+15], r9b
	sub rsp, 48
	mov [rsp+47], cl
	mov [rsp+46], sil
	mov [rsp+45], dil
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	mov rbx, [rsp+104]
	mov [rsp+8], rbx
	mov rbx, [rsp+72]
	mov [rsp+16], rbx
	mov bl, [rsp+63]
	mov [rsp+24], bl
	call center
	mov cl, [rsp+47]
	mov sil, [rsp+46]
	mov dil, [rsp+45]
	add rsp, 48
	add rsp, 16
	jmp .L35
	.L42:
	mov rbx, [rbp+16]
	inc rbx
	mov r8b, [rbx]
	mov bl, 0x41
	cmp r8b, bl
	sete bl
	test bl, bl
	je .L43
	sub rsp, 16
	mov rbx, [rbp+24]
	mov r8, [rsp+72]
	inc r8
	mov [rsp+72], r8
	dec r8
	mov r9b, [rbx+r8*8]
	mov [rsp+15], r9b
	sub rsp, 48
	mov [rsp+47], cl
	mov [rsp+46], sil
	mov [rsp+45], dil
	mov rbx, [rbp+32]
	mov [rsp+0], rbx
	xor rbx, rbx
	mov [rsp+8], rbx
	mov rbx, [rsp+72]
	mov [rsp+16], rbx
	mov bl, [rsp+63]
	mov [rsp+24], bl
	call left_align
	mov cl, [rsp+47]
	mov sil, [rsp+46]
	mov dil, [rsp+45]
	add rsp, 48
	add rsp, 16
	jmp .L35
	.L43:
	mov rbx, [rbp+16]
	inc rbx
	mov r8b, [rbx]
	mov bl, 0x54
	cmp r8b, bl
	sete bl
	test bl, bl
	je .L44
	mov rbx, [rsp+40]
	mov r8, 0xffffffffffffffff
	cmp rbx, r8
	sete bl
	test bl, bl
	je .L45
	sub rsp, 16
	mov [rsp+15], cl
	mov [rsp+14], sil
	mov [rsp+13], dil
	mov rbx, STR10
	mov [rsp+0], rbx
	call error
	mov cl, [rsp+15]
	mov sil, [rsp+14]
	mov dil, [rsp+13]
	add rsp, 16
	.L45:
	.L46:
	mov r8, [rbp+32]
	mov rbx, [r8+24]
	mov r8, [rsp+40]
	sub rbx, r8
	mov r8, [rsp+8]
	cmp rbx, r8
	seta bl
	test bl, bl
	je .L47
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov r8, [rbp+32]
	mov rbx, [r8+8]
	mov r8, [rsp+72]
	add rbx, r8
	mov [rsp+0], rbx
	mov r8, [rbp+32]
	mov rbx, [r8+8]
	mov r9, [rbp+32]
	mov r8, [r9+24]
	add rbx, r8
	mov r8, [rsp+40]
	sub rbx, r8
	mov [rsp+8], rbx
	mov rbx, [rsp+40]
	mov [rsp+16], rbx
	call memmove
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov r8, [rbp+32]
	mov rbx, [r8+8]
	mov r8, [rsp+72]
	add rbx, r8
	mov r8, [rsp+40]
	add rbx, r8
	mov [rsp+0], rbx
	xor bl, bl
	mov [rsp+8], bl
	mov r8, [rbp+32]
	mov rbx, [r8+24]
	mov r8, [rsp+72]
	sub rbx, r8
	mov r8, [rsp+40]
	sub rbx, r8
	mov [rsp+16], rbx
	call memset
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	mov rbx, [rbp+32]
	mov r8, [rsp+40]
	mov r9, [rsp+8]
	add r8, r9
	mov [rbx+24], r8
	.L47:
	.L48:
	jmp .L35
	.L44:
	mov rbx, [rbp+16]
	inc rbx
	mov r8b, [rbx]
	mov bl, 0x66
	cmp r8b, bl
	sete bl
	test bl, bl
	je .L49
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, [rbp+24]
	mov r8, [rsp+88]
	inc r8
	mov [rsp+88], r8
	dec r8
	fld QWORD [rbx+r8*8]
	fstp QWORD [rsp+0]
	mov rbx, [rsp+40]
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	call print_double
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	jmp .L35
	.L49:
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, STR11
	mov [rsp+0], rbx
	mov rbx, 0x2
	mov [rsp+8], rbx
	mov rbx, [rbp+16]
	dec rbx
	mov [rsp+16], rbx
	call error
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	.L35:
	add rsp, 16
	jmp .L6
	.L33:
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, STR12
	mov [rsp+0], rbx
	mov rbx, [rbp+16]
	inc rbx
	movzx r8, BYTE [rbx]
	mov [rsp+8], r8
	call error
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	.L6:
	mov rbx, [rsp+8]
	test rbx, rbx
	je .L50
	mov rbx, [rbp+16]
	mov r8, [rsp+8]
	add rbx, r8
	mov [rbp+16], rbx
	mov rbx, [rsp+32]
	mov r8, [rsp+8]
	sub rbx, r8
	mov [rsp+32], rbx
	jmp .L51
	.L50:
	mov rbx, [rbp+16]
	add rbx, 0x2
	mov [rbp+16], rbx
	mov rbx, [rsp+32]
	sub rbx, 0x2
	mov [rsp+32], rbx
	.L51:
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
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, [rbp+16]
	mov [rsp+0], rbx
	lea rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rbx, QWORD [stdout]
	mov [rsp+16], rbx
	call print_format
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	.L0:
	leave
	ret

global println:function
println:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, [rbp+16]
	mov [rsp+0], rbx
	lea rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rbx, QWORD [stdout]
	mov [rsp+16], rbx
	call print_format
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	sub rsp, 16
	mov [rsp+15], cl
	mov [rsp+14], sil
	mov [rsp+13], dil
	mov bl, 0xa
	mov [rsp+0], bl
	mov rbx, QWORD [stdout]
	mov [rsp+8], rbx
	call print_char
	mov cl, [rsp+15]
	mov sil, [rsp+14]
	mov dil, [rsp+13]
	add rsp, 16
	.L0:
	leave
	ret

global error:function
error:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, [rbp+16]
	mov [rsp+0], rbx
	lea rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rbx, QWORD [stdout]
	mov [rsp+16], rbx
	call print_format
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	sub rsp, 16
	mov [rsp+15], cl
	mov [rsp+14], sil
	mov [rsp+13], dil
	mov bl, 0xa
	mov [rsp+0], bl
	mov rbx, QWORD [stdout]
	mov [rsp+8], rbx
	call print_char
	mov cl, [rsp+15]
	mov sil, [rsp+14]
	mov dil, [rsp+13]
	add rsp, 16
	sub rsp, 16
	mov [rsp+15], cl
	mov [rsp+14], sil
	mov [rsp+13], dil
	mov rbx, 0xffffffffffffffff
	mov [rsp+0], rbx
	call exit
	mov cl, [rsp+15]
	mov sil, [rsp+14]
	mov dil, [rsp+13]
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
	mov [rsp+15], cl
	mov [rsp+14], sil
	mov [rsp+13], dil
	mov rbx, QWORD [stdout]
	mov [rsp+0], rbx
	call File.flush
	mov cl, [rsp+15]
	mov sil, [rsp+14]
	mov dil, [rsp+13]
	add rsp, 16
	sub rsp, 48
	mov [rsp+47], cl
	mov [rsp+46], sil
	mov [rsp+45], dil
	mov rbx, QWORD [stdin]
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	mov [rsp+16], rbx
	mov rbx, [rbp+32]
	mov [rsp+24], rbx
	call File.read
	mov cl, [rsp+47]
	mov sil, [rsp+46]
	mov dil, [rsp+45]
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rsp+8], rbx
	mov rbx, [rsp+8]
	xor r8, r8
	cmp rbx, r8
	setl bl
	test bl, bl
	je .L1
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, STR13
	mov [rsp+0], rbx
	mov rbx, [rsp+40]
	mov [rsp+8], rbx
	call error
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
	.L1:
	.L2:
	mov rbx, [rbp+24]
	mov r8, [rsp+8]
	dec r8
	mov [rsp+8], r8
	xor r9b, r9b
	mov [rbx+r8*1], r9b
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
	mov [rsp+15], cl
	mov [rsp+14], sil
	mov [rsp+13], dil
	mov rbx, QWORD [stdout]
	mov [rsp+0], rbx
	call File.flush
	mov cl, [rsp+15]
	mov sil, [rsp+14]
	mov dil, [rsp+13]
	add rsp, 16
	xor bx, bx
	mov [rsp+14], bx
	sub rsp, 48
	mov [rsp+47], cl
	mov [rsp+46], sil
	mov [rsp+45], dil
	mov rbx, QWORD [stdin]
	mov [rsp+8], rbx
	lea rbx, [rsp+62]
	mov [rsp+16], rbx
	mov rbx, 0x2
	mov [rsp+24], rbx
	call File.read
	mov cl, [rsp+47]
	mov sil, [rsp+46]
	mov dil, [rsp+45]
	mov rbx, [rsp+0]
	add rsp, 48
	mov [rsp+0], rbx
	mov rbx, [rsp+0]
	xor r8, r8
	cmp rbx, r8
	setl bl
	test bl, bl
	je .L1
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, STR14
	mov [rsp+0], rbx
	mov rbx, [rsp+32]
	mov [rsp+8], rbx
	call error
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	add rsp, 32
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
	mov r8, [rbp+32]
	mov r9, [rbp+40]
	dec r9
	mov [rbp+40], r9
	lea rbx, [r8+r9*1]
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	xor r8, r8
	cmp rbx, r8
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
	xor r8b, r8b
	mov [rbx], r8b
	mov rbx, [rsp+8]
	dec rbx
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	xor r8, r8
	cmp rbx, r8
	sete bl
	test bl, bl
	je .L3
	mov rbx, [rsp+8]
	dec rbx
	mov [rsp+8], rbx
	inc rbx
	mov r8b, 0x30
	mov [rbx], r8b
	mov rbx, [rbp+40]
	dec rbx
	mov [rbp+40], rbx
	.L3:
	.L4:
	.L5:
	mov rbx, [rbp+24]
	test rbx, rbx
	setne r8b
	je .L8
	mov rbx, [rbp+40]
	test rbx, rbx
	setne r8b
	.L8:
	test r8b, r8b
	je .L7
	mov rbx, [rsp+8]
	mov rax, [rbp+24]
	mov r8, 0xa
	xor rdx, rdx
	idiv r8
	mov rax, rdx
	add al, 0x30
	mov [rbx], al
	.L6:
	mov rax, [rbp+24]
	mov rbx, 0xa
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
	mov r8, [rsp+8]
	dec r8
	mov [rsp+8], r8
	inc r8
	mov r9b, [rbp+48]
	mov [r8], r9b
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
	dec rbx
	mov [rsp+8], rbx
	inc rbx
	mov r8b, 0x2d
	mov [rbx], r8b
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
	mov r8, [rbp+32]
	mov r9, [rbp+40]
	dec r9
	mov [rbp+40], r9
	lea rbx, [r8+r9*1]
	mov [rsp+8], rbx
	mov rbx, [rsp+8]
	xor r8b, r8b
	mov [rbx], r8b
	mov rbx, [rsp+8]
	dec rbx
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	xor r8, r8
	cmp rbx, r8
	sete bl
	test bl, bl
	je .L1
	mov rbx, [rsp+8]
	dec rbx
	mov [rsp+8], rbx
	inc rbx
	mov r8b, 0x30
	mov [rbx], r8b
	mov rbx, [rbp+40]
	dec rbx
	mov [rbp+40], rbx
	.L1:
	.L2:
	.L3:
	mov rbx, [rbp+24]
	test rbx, rbx
	setne r8b
	je .L6
	mov rbx, [rbp+40]
	test rbx, rbx
	setne r8b
	.L6:
	test r8b, r8b
	je .L5
	mov rbx, [rsp+8]
	mov rax, [rbp+24]
	mov r8, 0xa
	xor rdx, rdx
	div r8
	mov rax, rdx
	add al, 0x30
	mov [rbx], al
	.L4:
	mov rax, [rbp+24]
	mov rbx, 0xa
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
	mov r8, [rsp+8]
	dec r8
	mov [rsp+8], r8
	inc r8
	mov r9b, [rbp+48]
	mov [r8], r9b
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
	mov r8, 0xffffffffffffffff
	cmp rbx, r8
	sete bl
	test bl, bl
	je .L1
	sub rsp, 32
	mov [rsp+31], cl
	mov [rsp+30], sil
	mov [rsp+29], dil
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	call strlen
	mov cl, [rsp+31]
	mov sil, [rsp+30]
	mov dil, [rsp+29]
	mov rbx, [rsp+0]
	add rsp, 32
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
	mov r8b, [rbx]
	mov bl, 0x2d
	cmp r8b, bl
	sete bl
	test bl, bl
	je .L6
	mov r8b, [rsp+7]
	test r8b, r8b
	sete bl
	mov [rsp+7], bl
	jmp .L7
	.L6:
	mov rbx, [rbp+24]
	mov r8b, [rbx]
	mov bl, 0x30
	cmp r8b, bl
	setae bl
	test bl, bl
	je .L9
	mov r8, [rbp+24]
	mov r9b, [r8]
	mov r8b, 0x39
	cmp r9b, r8b
	setbe bl
	.L9:
	test bl, bl
	je .L8
	mov rbx, [rsp+8]
	shl rbx, 1
	lea rbx, [rbx+rbx*4]
	mov r9, [rbp+24]
	movzx r8, BYTE [r9]
	sub r8, 0x30
	add rbx, r8
	mov [rsp+8], rbx
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
	.L10:
	.L11:
	mov rbx, [rsp+8]
	mov [rbp+16], rbx
	.L0:
	leave
	ret


extern malloc:function
extern main:function
extern free:function
extern flush_stdout:function
extern realloc:function
extern string.free:function
extern File.open:function
extern File.close:function
extern string.new:function
extern string.format:function


section .data
static __FP_TMP:data
__FP_TMP:
dq 0
static __GP_TMP:data
__GP_TMP:
times 64 db 0
global stdout:data
stdout:
dq stdout_raw
times 0 db 0
global stdin:data
stdin:
dq stdin_raw
times 0 db 0
global errno:data
errno:
dq 0
times 0 db 0
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
times 0 db 0
static stdin_raw:data
stdin_raw:
dq 0
dq 0
dq 0
dq 0
dd 3
dd 2
times 0 db 0
global File:data
File:
global fixed:data
fixed:
global string:data
string:


section .rodata
STR0:
db "",10,"",0
STR1:
db "(NULL)",0
STR2:
db "0123456789ABCDEF",0
STR3:
db "",10,"Expected %[ before %L to enclose text to align left",0
STR4:
db "",10,"Expected %[ before %R to enclose text to align right",0
STR5:
db "",10,"Expected %[ before %C to enclose text to center",0
STR6:
db "",10,"Expected %[ before %T to enclose text to truncate",10,"",0
STR7:
db "true",0
STR8:
db "false",0
STR9:
db "",10,"Expected in to be in the range [1, 9] in format specifier %%0n",0
STR10:
db "",10,"Expected %[ before %*T to enclose text to truncate",0
STR11:
db "",10,"Unexpected format specifier %%%*s",0
STR12:
db "",10,"Unexpected format specifier %%%c",0
STR13:
db "input() error: %i",0
STR14:
db "input_char() error: %i",0
FP0:
dq 1.0
FP1:
dq 1000000000.0
FP2:
dq 6.28318530718
FP3:
dq 0.0
FP4:
dq 10.0
