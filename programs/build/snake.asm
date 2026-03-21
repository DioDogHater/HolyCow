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
	mov esi, 0xfffffa14
	and ecx, esi
	mov [rbx+0], ecx
	mov rbx, [rbp+16]
	mov rsi, [rbp+16]
	mov ecx, [rsi+4]
	mov esi, 0xfffffffe
	and ecx, esi
	mov [rbx+4], ecx
	mov rbx, [rbp+16]
	mov rsi, [rbp+16]
	mov ecx, [rsi+12]
	mov esi, 0xffff7fe4
	and ecx, esi
	mov [rbx+12], ecx
	mov rbx, [rbp+16]
	mov rsi, [rbp+16]
	mov ecx, [rsi+8]
	mov esi, 0xffffecff
	and ecx, esi
	mov [rbx+8], ecx
	mov rbx, [rbp+16]
	mov rsi, [rbp+16]
	mov ecx, [rsi+8]
	mov esi, 0x300
	or ecx, esi
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
	jmp .L0
	.L0:
	leave
	ret

global nonblock_stdin:function
nonblock_stdin:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	xor rbx, rbx
	mov [rsp+8], rbx
	mov rbx, 0x4
	mov [rsp+16], rbx
	sub rsp, 32
	xor rbx, rbx
	mov [rsp+8], rbx
	mov rbx, 0x3
	mov [rsp+16], rbx
	xor rbx, rbx
	mov [rsp+24], rbx
	call fcntl
	mov rbx, [rsp+0]
	add rsp, 32
	mov rcx, 0x800
	or rbx, rcx
	mov [rsp+24], rbx
	call fcntl
	add rsp, 32
	.L0:
	leave
	ret

global block_stdin:function
block_stdin:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	xor rbx, rbx
	mov [rsp+8], rbx
	mov rbx, 0x4
	mov [rsp+16], rbx
	sub rsp, 32
	xor rbx, rbx
	mov [rsp+8], rbx
	mov rbx, 0x3
	mov [rsp+16], rbx
	xor rbx, rbx
	mov [rsp+24], rbx
	call fcntl
	mov rbx, [rsp+0]
	add rsp, 32
	mov rcx, 0xfffffffffffff7ff
	and rbx, rcx
	mov [rsp+24], rbx
	call fcntl
	add rsp, 32
	.L0:
	leave
	ret

global get_direction:function
get_direction:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	sub rsp, 32
	xor rbx, rbx
	mov [rsp+8], rbx
	lea rbx, [rsp+40]
	mov [rsp+16], rbx
	mov rbx, 0x18
	mov [rsp+24], rbx
	call read
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+0], rbx
	xor bl, bl
	mov [rbp+16], bl
	mov rbx, [rsp+0]
	xor rcx, rcx
	cmp rbx, rcx
	setle bl
	test bl, bl
	je .L1
	jmp .L0
	jmp .L2
	.L1:
	.L2:
	lea rbx, [rsp+8]
	mov rcx, [rsp+0]
	mov rsi, 0x1
	sub rcx, rsi
	mov sil, [rbx+rcx*1]
	mov bl, 0x77
	cmp sil, bl
	sete bl
	test bl, bl
	je .L5
	mov ecx, DWORD [last_direction+4]
	test ecx, ecx
	sete bl
	.L5:
	test bl, bl
	je .L3
	lea rbx, [last_direction]
	xor ecx, ecx
	mov [rbx+0], ecx
	mov ecx, 0xffffffff
	mov [rbx+4], ecx
	jmp .L4
	.L3:
	lea rbx, [rsp+8]
	mov rcx, [rsp+0]
	mov rsi, 0x1
	sub rcx, rsi
	mov sil, [rbx+rcx*1]
	mov bl, 0x73
	cmp sil, bl
	sete bl
	test bl, bl
	je .L7
	mov ecx, DWORD [last_direction+4]
	test ecx, ecx
	sete bl
	.L7:
	test bl, bl
	je .L6
	lea rbx, [last_direction]
	xor ecx, ecx
	mov [rbx+0], ecx
	mov ecx, 0x1
	mov [rbx+4], ecx
	jmp .L4
	.L6:
	lea rbx, [rsp+8]
	mov rcx, [rsp+0]
	mov rsi, 0x1
	sub rcx, rsi
	mov sil, [rbx+rcx*1]
	mov bl, 0x61
	cmp sil, bl
	sete bl
	test bl, bl
	je .L9
	mov ecx, DWORD [last_direction+0]
	test ecx, ecx
	sete bl
	.L9:
	test bl, bl
	je .L8
	lea rbx, [last_direction]
	mov ecx, 0xffffffff
	mov [rbx+0], ecx
	xor ecx, ecx
	mov [rbx+4], ecx
	jmp .L4
	.L8:
	lea rbx, [rsp+8]
	mov rcx, [rsp+0]
	mov rsi, 0x1
	sub rcx, rsi
	mov sil, [rbx+rcx*1]
	mov bl, 0x64
	cmp sil, bl
	sete bl
	test bl, bl
	je .L11
	mov ecx, DWORD [last_direction+0]
	test ecx, ecx
	sete bl
	.L11:
	test bl, bl
	je .L10
	lea rbx, [last_direction]
	mov ecx, 0x1
	mov [rbx+0], ecx
	xor ecx, ecx
	mov [rbx+4], ecx
	jmp .L4
	.L10:
	lea rbx, [rsp+8]
	mov rcx, [rsp+0]
	mov rsi, 0x1
	sub rcx, rsi
	mov sil, [rbx+rcx*1]
	mov bl, 0x71
	cmp sil, bl
	sete bl
	test bl, bl
	je .L12
	mov bl, 0x1
	mov [rbp+16], bl
	jmp .L4
	.L12:
	.L4:
	.L0:
	leave
	ret

global generate_food:function
generate_food:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	lea rbx, [food]
	sub rsp, 32
	mov [rsp+24], rbx
	xor rcx, rcx
	mov [rsp+8], rcx
	mov rcx, 0x20
	mov [rsp+16], rcx
	call randint
	mov rbx, [rsp+24]
	mov ecx, [rsp+0]
	add rsp, 32
	mov [rbx+0], ecx
	sub rsp, 32
	mov [rsp+24], rbx
	xor rcx, rcx
	mov [rsp+8], rcx
	mov rcx, 0x10
	mov [rsp+16], rcx
	call randint
	mov rbx, [rsp+24]
	mov ecx, [rsp+0]
	add rsp, 32
	mov [rbx+4], ecx
	lea rbx, [snake]
	mov [rsp+8], rbx
	sub rsp, 16
	xor rbx, rbx
	mov [rsp+8], rbx
	.L1:
	mov rbx, [rsp+8]
	mov rcx, QWORD [snake_length]
	cmp rbx, rcx
	setb bl
	test bl, bl
	je .L3
	mov ebx, DWORD [food+0]
	mov rsi, [rsp+24]
	mov ecx, [rsi+0]
	cmp ebx, ecx
	sete bl
	test bl, bl
	je .L6
	mov ecx, DWORD [food+4]
	mov rdi, [rsp+24]
	mov esi, [rdi+4]
	cmp ecx, esi
	sete bl
	.L6:
	test bl, bl
	je .L4
	lea rbx, [food]
	sub rsp, 32
	mov [rsp+24], rbx
	xor rcx, rcx
	mov [rsp+8], rcx
	mov rcx, 0x20
	mov [rsp+16], rcx
	call randint
	mov rbx, [rsp+24]
	mov ecx, [rsp+0]
	add rsp, 32
	mov [rbx+0], ecx
	sub rsp, 32
	mov [rsp+24], rbx
	xor rcx, rcx
	mov [rsp+8], rcx
	mov rcx, 0x10
	mov [rsp+16], rcx
	call randint
	mov rbx, [rsp+24]
	mov ecx, [rsp+0]
	add rsp, 32
	mov [rbx+4], ecx
	lea rbx, [snake]
	mov [rsp+24], rbx
	xor rbx, rbx
	mov [rsp+8], rbx
	jmp .L5
	.L4:
	.L5:
	mov rbx, [rsp+24]
	mov rcx, 0x8
	add rbx, rcx
	mov [rsp+24], rbx
	.L2:
	mov rbx, [rsp+8]
	inc rbx
	mov [rsp+8], rbx
	jmp .L1
	.L3:
	add rsp, 16
	.L0:
	leave
	ret

global init_game:function
init_game:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	lea rbx, [snake]
	mov [rsp+0], rbx
	xor bl, bl
	mov [rsp+8], bl
	mov rax, 0x200
	mov rbx, 0x8
	mul rbx
	mov [rsp+16], rax
	call memset
	add rsp, 32
	lea rbx, [snake]
	xor rcx, rcx
	lea rbx, [rbx+rcx*8]
	mov ecx, 0x10
	mov [rbx+0], ecx
	mov ecx, 0x8
	mov [rbx+4], ecx
	mov rbx, 0x1
	mov [snake_length], rbx
	lea rbx, [last_direction]
	xor ecx, ecx
	mov [rbx+0], ecx
	xor ecx, ecx
	mov [rbx+4], ecx
	call generate_food
	.L0:
	leave
	ret

global draw_game:function
draw_game:
	push rbp
	mov rbp, rsp
	sub rsp, 544
	sub rsp, 32
	lea rbx, [rsp+64]
	mov [rsp+0], rbx
	mov bl, 0x20
	mov [rsp+8], bl
	mov rbx, 0x200
	mov [rsp+16], rbx
	call memset
	add rsp, 32
	lea rbx, [snake]
	mov [rsp+24], rbx
	mov ebx, DWORD [last_direction+0]
	xor ecx, ecx
	cmp ebx, ecx
	setg bl
	test bl, bl
	je .L1
	lea rbx, [rsp+32]
	mov rsi, [rsp+24]
	mov ecx, DWORD [rsi+0]
	mov rsi, [rsp+24]
	mov eax, DWORD [rsi+4]
	mov rsi, 0x20
	mul rsi
	add rcx, rax
	mov sil, 0x3e
	mov [rbx+rcx*1], sil
	jmp .L2
	.L1:
	mov ebx, DWORD [last_direction+0]
	xor ecx, ecx
	cmp ebx, ecx
	setl bl
	test bl, bl
	je .L3
	lea rbx, [rsp+32]
	mov rsi, [rsp+24]
	mov ecx, DWORD [rsi+0]
	mov rsi, [rsp+24]
	mov eax, DWORD [rsi+4]
	mov rsi, 0x20
	mul rsi
	add rcx, rax
	mov sil, 0x3c
	mov [rbx+rcx*1], sil
	jmp .L2
	.L3:
	mov ebx, DWORD [last_direction+4]
	xor ecx, ecx
	cmp ebx, ecx
	setl bl
	test bl, bl
	je .L4
	lea rbx, [rsp+32]
	mov rsi, [rsp+24]
	mov ecx, DWORD [rsi+0]
	mov rsi, [rsp+24]
	mov eax, DWORD [rsi+4]
	mov rsi, 0x20
	mul rsi
	add rcx, rax
	mov sil, 0x5e
	mov [rbx+rcx*1], sil
	jmp .L2
	.L4:
	lea rbx, [rsp+32]
	mov rsi, [rsp+24]
	mov ecx, DWORD [rsi+0]
	mov rsi, [rsp+24]
	mov eax, DWORD [rsi+4]
	mov rsi, 0x20
	mul rsi
	add rcx, rax
	mov sil, 0x76
	mov [rbx+rcx*1], sil
	.L2:
	mov rbx, [rsp+24]
	mov rcx, 0x8
	add rbx, rcx
	mov [rsp+24], rbx
	lea rbx, [snake]
	mov [rsp+16], rbx
	mov rbx, QWORD [snake_length]
	mov rcx, 0x1
	sub rbx, rcx
	.L5:
	test rbx, rbx
	je .L7
	mov rsi, [rsp+24]
	mov ecx, [rsi+0]
	mov rdi, [rsp+16]
	mov esi, [rdi+0]
	sub ecx, esi
	test ecx, ecx
	je .L8
	lea rcx, [rsp+32]
	mov rdi, [rsp+24]
	mov esi, DWORD [rdi+0]
	mov rdi, [rsp+24]
	mov eax, DWORD [rdi+4]
	mov rdi, 0x20
	mul rdi
	add rsi, rax
	mov dil, 0x2d
	mov [rcx+rsi*1], dil
	jmp .L9
	.L8:
	lea rcx, [rsp+32]
	mov rdi, [rsp+24]
	mov esi, DWORD [rdi+0]
	mov rdi, [rsp+24]
	mov eax, DWORD [rdi+4]
	mov rdi, 0x20
	mul rdi
	add rsi, rax
	mov dil, 0x7c
	mov [rcx+rsi*1], dil
	.L9:
	mov rcx, [rsp+24]
	mov rsi, 0x8
	add rcx, rsi
	mov [rsp+24], rcx
	mov rcx, [rsp+16]
	mov rsi, 0x8
	add rcx, rsi
	mov [rsp+16], rcx
	.L6:
	dec rbx
	jmp .L5
	.L7:
	lea rbx, [rsp+32]
	mov ecx, DWORD [food+0]
	mov eax, DWORD [food+4]
	mov rsi, 0x20
	mul rsi
	add rcx, rax
	mov sil, 0x6f
	mov [rbx+rcx*1], sil
	lea rbx, [rsp+32]
	mov [rsp+8], rbx
	sub rsp, 32
	mov rbx, STR0
	mov [rsp+0], rbx
	mov rbx, 0x20
	mov [rsp+8], rbx
	mov rbx, 0x3d
	mov [rsp+16], rbx
	call println
	add rsp, 32
	mov bl, 0x10
	.L10:
	test bl, bl
	je .L12
	sub rsp, 32
	mov [rsp+31], bl
	mov rcx, STR1
	mov [rsp+0], rcx
	mov rcx, 0x20
	mov [rsp+8], rcx
	mov rcx, [rsp+40]
	mov [rsp+16], rcx
	call println
	mov bl, [rsp+31]
	add rsp, 32
	mov rcx, [rsp+8]
	mov rsi, 0x20
	add rcx, rsi
	mov [rsp+8], rcx
	.L11:
	dec bl
	jmp .L10
	.L12:
	sub rsp, 32
	mov rbx, STR2
	mov [rsp+0], rbx
	mov rbx, 0x20
	mov [rsp+8], rbx
	mov rbx, 0x3d
	mov [rsp+16], rbx
	call println
	add rsp, 32
	.L0:
	leave
	ret

global main:function
main:
	push rbp
	mov rbp, rsp
	sub rsp, 128
	sub rsp, 32
	xor rbx, rbx
	mov [rsp+8], rbx
	lea rbx, [rsp+104]
	mov [rsp+16], rbx
	call tcgetattr
	add rsp, 32
	lea rbx, [rsp+16]
	cld
	mov rdi, rbx
	lea rsi, [rsp+72]
	mov rcx, 7
	rep movsq
	mov ebx, [rsp+28]
	mov ecx, 0xfffffff5
	and ebx, ecx
	mov [rsp+28], ebx
	sub rsp, 32
	xor rbx, rbx
	mov [rsp+8], rbx
	xor rbx, rbx
	mov [rsp+16], rbx
	lea rbx, [rsp+48]
	mov [rsp+24], rbx
	call tcsetattr
	add rsp, 32
	call nonblock_stdin
	call init_game
	sub rsp, 16
	call time
	fld QWORD [rsp+0]
	add rsp, 16
	fstp DWORD [rsp+12]
	fld DWORD [rsp+12]
	fld QWORD [FP2]
	fsubp
	fstp DWORD [rsp+8]
	xor bl, bl
	mov [rsp+7], bl
	.L1:
	sub rsp, 16
	call draw_game
	sub rsp, 16
	call time
	fld QWORD [rsp+0]
	add rsp, 16
	fstp DWORD [rsp+28]
	sub rsp, 32
	mov rbx, STR3
	mov [rsp+0], rbx
	mov rbx, QWORD [snake_length]
	mov [rsp+8], rbx
	mov rbx, 0x10
	mov [rsp+16], rbx
	call println
	add rsp, 32
	fld DWORD [rsp+28]
	fstp DWORD [rsp+24]
	sub rsp, 16
	call get_direction
	mov bl, [rsp+0]
	add rsp, 16
	mov [rsp+23], bl
	mov rbx, QWORD [snake_length]
	mov rcx, 0x1
	cmp rbx, rcx
	setg bl
	test bl, bl
	je .L3
	sub rsp, 32
	lea rbx, [snake]
	mov rcx, 0x8
	add rbx, rcx
	mov [rsp+0], rbx
	lea rbx, [snake]
	mov [rsp+8], rbx
	mov rax, QWORD [snake_length]
	mov rbx, 0x1
	sub rax, rbx
	mov rbx, 0x8
	mul rbx
	mov [rsp+16], rax
	call memmove
	add rsp, 32
	jmp .L4
	.L3:
	.L4:
	lea rbx, [snake]
	lea rsi, [snake]
	mov ecx, [rsi+0]
	mov esi, DWORD [last_direction+0]
	add ecx, esi
	mov [rbx+0], ecx
	lea rbx, [snake]
	lea rsi, [snake]
	mov ecx, [rsi+4]
	mov esi, DWORD [last_direction+4]
	add ecx, esi
	mov [rbx+4], ecx
	lea rcx, [snake]
	mov ebx, [rcx+0]
	xor ecx, ecx
	cmp ebx, ecx
	setl bl
	test bl, bl
	jne .L9
	lea rsi, [snake]
	mov ecx, [rsi+0]
	mov esi, 0x20
	cmp ecx, esi
	setge bl
	.L9:
	test bl, bl
	jne .L8
	lea rsi, [snake]
	mov ecx, [rsi+4]
	xor esi, esi
	cmp ecx, esi
	setl bl
	.L8:
	test bl, bl
	jne .L7
	lea rsi, [snake]
	mov ecx, [rsi+4]
	mov esi, 0x10
	cmp ecx, esi
	setge bl
	.L7:
	test bl, bl
	je .L5
	mov bl, 0x1
	mov [rsp+23], bl
	jmp .L6
	.L5:
	.L6:
	lea rbx, [snake]
	mov rcx, 0x8
	add rbx, rcx
	mov [rsp+8], rbx
	mov rbx, QWORD [snake_length]
	mov rcx, 0x1
	sub rbx, rcx
	.L10:
	test rbx, rbx
	je .L12
	lea rsi, [snake]
	mov ecx, [rsi+0]
	mov rdi, [rsp+8]
	mov esi, [rdi+0]
	cmp ecx, esi
	sete cl
	test cl, cl
	je .L15
	lea rdi, [snake]
	mov esi, [rdi+4]
	mov r8, [rsp+8]
	mov edi, [r8+4]
	cmp esi, edi
	sete cl
	.L15:
	test cl, cl
	je .L13
	mov cl, 0x1
	mov [rsp+23], cl
	jmp .L12
	jmp .L14
	.L13:
	.L14:
	mov rcx, [rsp+8]
	mov rsi, 0x8
	add rcx, rsi
	mov [rsp+8], rcx
	.L11:
	dec rbx
	jmp .L10
	.L12:
	lea rcx, [snake]
	mov ebx, [rcx+0]
	mov ecx, DWORD [food+0]
	cmp ebx, ecx
	sete bl
	test bl, bl
	je .L18
	lea rsi, [snake]
	mov ecx, [rsi+4]
	mov esi, DWORD [food+4]
	cmp ecx, esi
	sete bl
	.L18:
	test bl, bl
	je .L16
	lea rbx, [snake]
	mov rcx, QWORD [snake_length]
	inc rcx
	mov [snake_length], rcx
	dec rcx
	lea rbx, [rbx+rcx*8]
	lea rcx, [snake]
	mov rsi, QWORD [snake_length]
	mov rdi, 0x2
	sub rsi, rdi
	mov rdi, [rcx+rsi*8]
	mov [rbx], rdi
	call generate_food
	jmp .L17
	.L16:
	.L17:
	sub rsp, 16
	fld QWORD [FP3]
	fstp QWORD [rsp+0]
	call sleep
	add rsp, 16
	mov bl, [rsp+23]
	test bl, bl
	je .L19
	sub rsp, 16
	mov rbx, STR4
	mov [rsp+0], rbx
	call print
	add rsp, 16
	call flush_stdout
	sub rsp, 32
	xor rbx, rbx
	mov [rsp+8], rbx
	xor rbx, rbx
	mov [rsp+16], rbx
	mov rbx, 0x40
	mov [rsp+24], rbx
	call read
	add rsp, 32
	call block_stdin
	sub rsp, 32
	xor rbx, rbx
	mov [rsp+8], rbx
	xor rbx, rbx
	mov [rsp+16], rbx
	lea rbx, [rsp+120]
	mov [rsp+24], rbx
	call tcsetattr
	add rsp, 32
	sub rsp, 16
	fld QWORD [FP4]
	fstp QWORD [rsp+0]
	call sleep
	add rsp, 16
	sub rsp, 16
	sub rsp, 16
	call input_char
	mov bl, [rsp+0]
	add rsp, 16
	mov [rsp+1], bl
	call to_lower
	mov bl, [rsp+0]
	add rsp, 16
	mov cl, 0x79
	cmp bl, cl
	setne bl
	test bl, bl
	je .L21
	jmp .L0
	jmp .L22
	.L21:
	.L22:
	call init_game
	xor bl, bl
	mov [rsp+23], bl
	call nonblock_stdin
	sub rsp, 32
	xor rbx, rbx
	mov [rsp+8], rbx
	xor rbx, rbx
	mov [rsp+16], rbx
	lea rbx, [rsp+64]
	mov [rsp+24], rbx
	call tcsetattr
	add rsp, 32
	jmp .L20
	.L19:
	.L20:
	add rsp, 16
	jmp .L1
	.L2:
	.L0:
	leave
	ret


extern int_to_fixed:function
extern log:function
extern fraction_to_fixed:function
extern sin:function
extern print_char:function
extern trunc:function
extern print:function
extern set_rounding:function
extern div_fixed:function
extern pow:function
extern memmove:function
extern mul_fixed:function
extern random:function
extern is_num:function
extern memset:function
extern exit:function
extern read:function
extern tan:function
extern int_to_string:function
extern string_to_int:function
extern string_to_fixed:function
extern write:function
extern print_format:function
extern strcmp:function
extern strfind:function
extern absf:function
extern fixed_to_int:function
extern print_fixed:function
extern absi:function
extern floor:function
extern uint_to_string:function
extern strdfind:function
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
extern cos:function
extern strcpy:function
extern print_double:function
extern syscall1:function
extern syscall2:function
extern syscall3:function
extern mod_fixed:function
extern println:function
extern round:function
extern sqrt:function
extern error:function
extern randint:function
extern print_hex:function
extern atan2:function
extern is_alnum:function


section .data
static __FP_TMP:data
__FP_TMP:
dq 0
static __GP_TMP:data
__GP_TMP:
times 64 db 0
global snake:data
snake:
times 4096 db 0
global last_direction:data
last_direction:
times 8 db 0
global snake_length:data
snake_length:
times 8 db 0
global food:data
food:
times 8 db 0


section .rodata
STR0:
db "",0x1b,"[2J",0x1b,"[H+%*c+",0
STR1:
db "|%*s|",0
STR2:
db "+%*c+",0
STR3:
db "SCORE: %04%APress q to quit.",0
STR4:
db "> GAME OVER <",10,"Play again? (y/n) ",0
FP0:
dq 1.0
FP1:
dq 1000000000.0
FP2:
dq 0.1
FP3:
dq 0.075
FP4:
dq 0.25
