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
	mov rbx, 16
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
	mov rbx, 21505
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
	mov rcx, 0
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L1
	sub rsp, 32
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rbx, 21506
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
	mov rcx, 1
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L3
	sub rsp, 32
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rbx, 21507
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
	mov rcx, 2
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L4
	sub rsp, 32
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rbx, 21508
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
	mov rbx, -1
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
	mov esi, 18446744073709550100
	and ecx, esi
	mov [rbx+0], ecx
	mov rbx, [rbp+16]
	mov rsi, [rbp+16]
	mov ecx, [rsi+4]
	mov esi, 18446744073709551614
	and ecx, esi
	mov [rbx+4], ecx
	mov rbx, [rbp+16]
	mov rsi, [rbp+16]
	mov ecx, [rsi+12]
	mov esi, 18446744073709518820
	and ecx, esi
	mov [rbx+12], ecx
	mov rbx, [rbp+16]
	mov rsi, [rbp+16]
	mov ecx, [rsi+8]
	mov esi, 18446744073709546751
	and ecx, esi
	mov [rbx+8], ecx
	mov rbx, [rbp+16]
	mov rsi, [rbp+16]
	mov ecx, [rsi+8]
	mov esi, 768
	or ecx, esi
	mov [rbx+8], ecx
	mov rcx, [rbp+16]
	lea rbx, [rcx+16]
	mov rcx, 16
	mov sil, 1
	mov [rbx+rcx*1], sil
	mov rcx, [rbp+16]
	lea rbx, [rcx+16]
	mov rcx, 17
	mov sil, 0
	mov [rbx+rcx*1], sil
	.L0:
	leave
	ret

global nanosleep:function
nanosleep:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov rbx, 35
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
	sub rsp, 8
	fistp QWORD [rsp]
	pop rcx
	mov [rbx+0], rcx
	fld QWORD [rbp+16]
	fld QWORD [FP0]
	fprem
fstp st0
	fld QWORD [FP1]
	fmulp
	sub rsp, 8
	fistp QWORD [rsp]
	pop rcx
	mov [rbx+8], rcx
	sub rsp, 32
	lea rbx, [rsp+32]
	mov [rsp+8], rbx
	mov rbx, 0
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
	mov rcx, 1000
	xor rdx, rdx
	div rcx
	mov [rbx+0], rax
	mov rax, [rbp+16]
	mov rcx, 1000
	xor rdx, rdx
	div rcx
	mov rax, rdx
	mov rcx, 1000000
	mul rcx
	mov [rbx+8], rax
	sub rsp, 32
	lea rbx, [rsp+32]
	mov [rsp+8], rbx
	mov rbx, 0
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
	mov rcx, 1000000
	xor rdx, rdx
	div rcx
	mov [rbx+0], rax
	mov rax, [rbp+16]
	mov rcx, 1000000
	xor rdx, rdx
	div rcx
	mov rax, rdx
	mov rcx, 1000
	mul rcx
	mov [rbx+8], rax
	sub rsp, 32
	lea rbx, [rsp+32]
	mov [rsp+8], rbx
	mov rbx, 0
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
	mov rbx, 228
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
	mov rbx, 0
	mov [rsp+8], rbx
	lea rbx, [rsp+32]
	mov [rsp+16], rbx
	call clock_gettime
	add rsp, 32
	mov rbx, [rsp+0]
	push rbx
	fild QWORD [rsp]
	add rsp, 8
	mov rbx, [rsp+8]
	push rbx
	fild QWORD [rsp]
	add rsp, 8
	fld QWORD [FP2]
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
	mov rbx, 72
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
	mov rbx, 0
	mov [rsp+8], rbx
	mov rbx, 4
	mov [rsp+16], rbx
	sub rsp, 32
	mov rbx, 0
	mov [rsp+8], rbx
	mov rbx, 3
	mov [rsp+16], rbx
	mov rbx, 0
	mov [rsp+24], rbx
	call fcntl
	mov rbx, [rsp+0]
	add rsp, 32
	mov rcx, 2048
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
	mov rbx, 0
	mov [rsp+8], rbx
	mov rbx, 4
	mov [rsp+16], rbx
	sub rsp, 32
	mov rbx, 0
	mov [rsp+8], rbx
	mov rbx, 3
	mov [rsp+16], rbx
	mov rbx, 0
	mov [rsp+24], rbx
	call fcntl
	mov rbx, [rsp+0]
	add rsp, 32
	mov rcx, -2049
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
	mov rbx, 0
	mov [rsp+8], rbx
	lea rbx, [rsp+40]
	mov [rsp+16], rbx
	mov rbx, 24
	mov [rsp+24], rbx
	call read
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+0], rbx
	mov rbx, [rsp+0]
	mov rcx, 0
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
	mov rsi, 1
	sub rcx, rsi
	mov sil, [rbx+rcx*1]
	mov bl, 119
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
	mov rbx, [rbp+16]
	test rbx, rbx
	je .L0
	mov ecx, 0
	mov [rbx+0], ecx
	mov ecx, -1
	mov [rbx+4], ecx
	jmp .L0
	jmp .L4
	.L3:
	lea rbx, [rsp+8]
	mov rcx, [rsp+0]
	mov rsi, 1
	sub rcx, rsi
	mov sil, [rbx+rcx*1]
	mov bl, 115
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
	mov rbx, [rbp+16]
	test rbx, rbx
	je .L0
	mov ecx, 0
	mov [rbx+0], ecx
	mov ecx, 1
	mov [rbx+4], ecx
	jmp .L0
	jmp .L4
	.L6:
	lea rbx, [rsp+8]
	mov rcx, [rsp+0]
	mov rsi, 1
	sub rcx, rsi
	mov sil, [rbx+rcx*1]
	mov bl, 97
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
	mov rbx, [rbp+16]
	test rbx, rbx
	je .L0
	mov ecx, -1
	mov [rbx+0], ecx
	mov ecx, 0
	mov [rbx+4], ecx
	jmp .L0
	jmp .L4
	.L8:
	lea rbx, [rsp+8]
	mov rcx, [rsp+0]
	mov rsi, 1
	sub rcx, rsi
	mov sil, [rbx+rcx*1]
	mov bl, 100
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
	mov rbx, [rbp+16]
	test rbx, rbx
	je .L0
	mov ecx, 1
	mov [rbx+0], ecx
	mov ecx, 0
	mov [rbx+4], ecx
	jmp .L0
	jmp .L4
	.L10:
	lea rbx, [rsp+8]
	mov rcx, [rsp+0]
	mov rsi, 1
	sub rcx, rsi
	mov sil, [rbx+rcx*1]
	mov bl, 113
	cmp sil, bl
	sete bl
	test bl, bl
	je .L12
	mov rbx, [rbp+24]
	mov cl, 1
	mov [rbx], cl
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
	mov rcx, 0
	mov [rsp+8], rcx
	mov rcx, 32
	mov [rsp+16], rcx
	call randint
	mov rbx, [rsp+24]
	mov ecx, [rsp+0]
	add rsp, 32
	mov [rbx+0], ecx
	sub rsp, 32
	mov [rsp+24], rbx
	mov rcx, 0
	mov [rsp+8], rcx
	mov rcx, 16
	mov [rsp+16], rcx
	call randint
	mov rbx, [rsp+24]
	mov ecx, [rsp+0]
	add rsp, 32
	mov [rbx+4], ecx
	lea rbx, [snake]
	mov [rsp+8], rbx
	sub rsp, 16
	mov rbx, 0
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
	mov r8, [rsp+24]
	mov esi, [r8+4]
	cmp ecx, esi
	sete bl
	.L6:
	test bl, bl
	je .L4
	lea rbx, [food]
	sub rsp, 32
	mov [rsp+24], rbx
	mov rcx, 0
	mov [rsp+8], rcx
	mov rcx, 32
	mov [rsp+16], rcx
	call randint
	mov rbx, [rsp+24]
	mov ecx, [rsp+0]
	add rsp, 32
	mov [rbx+0], ecx
	sub rsp, 32
	mov [rsp+24], rbx
	mov rcx, 0
	mov [rsp+8], rcx
	mov rcx, 16
	mov [rsp+16], rcx
	call randint
	mov rbx, [rsp+24]
	mov ecx, [rsp+0]
	add rsp, 32
	mov [rbx+4], ecx
	lea rbx, [snake]
	mov [rsp+24], rbx
	mov rbx, 0
	mov [rsp+8], rbx
	jmp .L5
	.L4:
	.L5:
	mov rbx, [rsp+24]
	mov rcx, 8
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
	mov bl, 0
	mov [rsp+8], bl
	mov rax, 512
	mov rbx, 8
	mul rbx
	mov [rsp+16], rax
	call memset
	add rsp, 32
	lea rbx, [snake]
	mov rcx, 0
	lea rbx, [rbx+rcx*8]
	mov ecx, 16
	mov [rbx+0], ecx
	mov ecx, 8
	mov [rbx+4], ecx
	mov rbx, 1
	mov [snake_length], rbx
	lea rbx, [last_direction]
	mov ecx, 0
	mov [rbx+0], ecx
	mov ecx, 0
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
	mov bl, 32
	mov [rsp+8], bl
	mov rbx, 512
	mov [rsp+16], rbx
	call memset
	add rsp, 32
	lea rbx, [snake]
	mov [rsp+24], rbx
	mov ebx, DWORD [last_direction+0]
	mov ecx, 0
	cmp ebx, ecx
	setg bl
	test bl, bl
	je .L1
	lea rbx, [rsp+32]
	mov rsi, [rsp+24]
	mov ecx, DWORD [rsi+0]
	mov rsi, [rsp+24]
	mov eax, DWORD [rsi+4]
	mov rsi, 32
	mul rsi
	add rcx, rax
	mov sil, 62
	mov [rbx+rcx*1], sil
	jmp .L2
	.L1:
	mov ebx, DWORD [last_direction+0]
	mov ecx, 0
	cmp ebx, ecx
	setl bl
	test bl, bl
	je .L3
	lea rbx, [rsp+32]
	mov rsi, [rsp+24]
	mov ecx, DWORD [rsi+0]
	mov rsi, [rsp+24]
	mov eax, DWORD [rsi+4]
	mov rsi, 32
	mul rsi
	add rcx, rax
	mov sil, 60
	mov [rbx+rcx*1], sil
	jmp .L2
	.L3:
	mov ebx, DWORD [last_direction+4]
	mov ecx, 0
	cmp ebx, ecx
	setl bl
	test bl, bl
	je .L4
	lea rbx, [rsp+32]
	mov rsi, [rsp+24]
	mov ecx, DWORD [rsi+0]
	mov rsi, [rsp+24]
	mov eax, DWORD [rsi+4]
	mov rsi, 32
	mul rsi
	add rcx, rax
	mov sil, 94
	mov [rbx+rcx*1], sil
	jmp .L2
	.L4:
	lea rbx, [rsp+32]
	mov rsi, [rsp+24]
	mov ecx, DWORD [rsi+0]
	mov rsi, [rsp+24]
	mov eax, DWORD [rsi+4]
	mov rsi, 32
	mul rsi
	add rcx, rax
	mov sil, 118
	mov [rbx+rcx*1], sil
	.L2:
	mov rbx, [rsp+24]
	mov rcx, 8
	add rbx, rcx
	mov [rsp+24], rbx
	lea rbx, [snake]
	mov [rsp+16], rbx
	mov rbx, QWORD [snake_length]
	mov rcx, 1
	sub rbx, rcx
	.L5:
	test rbx, rbx
	je .L7
	mov rsi, [rsp+24]
	mov ecx, [rsi+0]
	mov r8, [rsp+16]
	mov esi, [r8+0]
	sub ecx, esi
	test ecx, ecx
	je .L8
	lea rcx, [rsp+32]
	mov r8, [rsp+24]
	mov esi, DWORD [r8+0]
	mov r8, [rsp+24]
	mov eax, DWORD [r8+4]
	mov r8, 32
	mul r8
	add rsi, rax
	mov r8b, 45
	mov [rcx+rsi*1], r8b
	jmp .L9
	.L8:
	lea rcx, [rsp+32]
	mov r8, [rsp+24]
	mov esi, DWORD [r8+0]
	mov r8, [rsp+24]
	mov eax, DWORD [r8+4]
	mov r8, 32
	mul r8
	add rsi, rax
	mov r8b, 124
	mov [rcx+rsi*1], r8b
	.L9:
	mov rcx, [rsp+24]
	mov rsi, 8
	add rcx, rsi
	mov [rsp+24], rcx
	mov rcx, [rsp+16]
	mov rsi, 8
	add rcx, rsi
	mov [rsp+16], rcx
	.L6:
	dec rbx
	jmp .L5
	.L7:
	lea rbx, [rsp+32]
	mov ecx, DWORD [food+0]
	mov eax, DWORD [food+4]
	mov rsi, 32
	mul rsi
	add rcx, rax
	mov sil, 111
	mov [rbx+rcx*1], sil
	lea rbx, [rsp+32]
	mov [rsp+8], rbx
	sub rsp, 32
	mov rbx, STR0
	mov [rsp+0], rbx
	mov rbx, 32
	mov [rsp+8], rbx
	mov rbx, 61
	mov [rsp+16], rbx
	call println
	add rsp, 32
	mov bl, 16
	.L10:
	test bl, bl
	je .L12
	sub rsp, 32
	mov [rsp+31], bl
	mov rcx, STR1
	mov [rsp+0], rcx
	mov rcx, 32
	mov [rsp+8], rcx
	mov rcx, [rsp+40]
	mov [rsp+16], rcx
	call println
	mov bl, [rsp+31]
	add rsp, 32
	mov rcx, [rsp+8]
	mov rsi, 32
	add rcx, rsi
	mov [rsp+8], rcx
	.L11:
	dec bl
	jmp .L10
	.L12:
	sub rsp, 32
	mov rbx, STR2
	mov [rsp+0], rbx
	mov rbx, 32
	mov [rsp+8], rbx
	mov rbx, 61
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
	sub rsp, 144
	sub rsp, 32
	mov rbx, 0
	mov [rsp+8], rbx
	lea rbx, [rsp+120]
	mov [rsp+16], rbx
	call tcgetattr
	add rsp, 32
	lea rbx, [rsp+32]
	cld
	mov rdi, rbx
	lea rsi, [rsp+88]
	mov rcx, 7
	rep movsq
	mov ebx, [rsp+44]
	mov ecx, 18446744073709551605
	and ebx, ecx
	mov [rsp+44], ebx
	sub rsp, 32
	mov rbx, 0
	mov [rsp+8], rbx
	mov rbx, 0
	mov [rsp+16], rbx
	lea rbx, [rsp+64]
	mov [rsp+24], rbx
	call tcsetattr
	add rsp, 32
	call nonblock_stdin
	call init_game
	sub rsp, 16
	call time
	fld QWORD [rsp+0]
	add rsp, 16
	fstp QWORD [rsp+24]
	fld QWORD [rsp+24]
	fld QWORD [FP3]
	fsubp
	fstp QWORD [rsp+16]
	mov bl, 0
	mov [rsp+15], bl
	.L1:
	sub rsp, 16
	call draw_game
	sub rsp, 16
	call time
	fld QWORD [rsp+0]
	add rsp, 16
	fstp QWORD [rsp+40]
	sub rsp, 16
	mov rbx, STR3
	mov [rsp+0], rbx
	mov rbx, QWORD [snake_length]
	mov [rsp+8], rbx
	call println
	add rsp, 16
	fld QWORD [rsp+40]
	fstp QWORD [rsp+32]
	lea rbx, [last_direction]
	sub rsp, 16
	mov [rsp+0], rbx
	lea rbx, [rsp+47]
	mov [rsp+8], rbx
	call get_direction
	add rsp, 16
	mov rbx, QWORD [snake_length]
	mov rcx, 1
	cmp rbx, rcx
	setg bl
	test bl, bl
	je .L3
	sub rsp, 32
	lea rbx, [snake]
	mov rcx, 8
	add rbx, rcx
	mov [rsp+0], rbx
	lea rbx, [snake]
	mov [rsp+8], rbx
	mov rax, QWORD [snake_length]
	mov rbx, 1
	sub rax, rbx
	mov rbx, 8
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
	mov ecx, 0
	cmp ebx, ecx
	setl bl
	test bl, bl
	jne .L9
	lea rsi, [snake]
	mov ecx, [rsi+0]
	mov esi, 32
	cmp ecx, esi
	setge bl
	.L9:
	test bl, bl
	jne .L8
	lea rsi, [snake]
	mov ecx, [rsi+4]
	mov esi, 0
	cmp ecx, esi
	setl bl
	.L8:
	test bl, bl
	jne .L7
	lea rsi, [snake]
	mov ecx, [rsi+4]
	mov esi, 16
	cmp ecx, esi
	setge bl
	.L7:
	test bl, bl
	je .L5
	mov bl, 1
	mov [rsp+31], bl
	jmp .L6
	.L5:
	.L6:
	lea rbx, [snake]
	mov rcx, 8
	add rbx, rcx
	mov [rsp+8], rbx
	mov rbx, QWORD [snake_length]
	mov rcx, 1
	sub rbx, rcx
	.L10:
	test rbx, rbx
	je .L12
	lea rsi, [snake]
	mov ecx, [rsi+0]
	mov r8, [rsp+8]
	mov esi, [r8+0]
	cmp ecx, esi
	sete cl
	test cl, cl
	je .L15
	lea r8, [snake]
	mov esi, [r8+4]
	mov rdi, [rsp+8]
	mov r8d, [rdi+4]
	cmp esi, r8d
	sete cl
	.L15:
	test cl, cl
	je .L13
	mov cl, 1
	mov [rsp+31], cl
	jmp .L12
	jmp .L14
	.L13:
	.L14:
	mov rcx, [rsp+8]
	mov rsi, 8
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
	mov r8, 2
	sub rsi, r8
	mov rdi, [rcx+rsi*8]
	mov [rbx], rdi
	call generate_food
	jmp .L17
	.L16:
	.L17:
	sub rsp, 16
	fld QWORD [FP4]
	fstp QWORD [rsp+0]
	call sleep
	add rsp, 16
	mov bl, [rsp+31]
	test bl, bl
	je .L19
	sub rsp, 16
	mov rbx, STR4
	mov [rsp+0], rbx
	call print
	add rsp, 16
	call flush_stdout
	sub rsp, 32
	mov rbx, 0
	mov [rsp+8], rbx
	mov rbx, 0
	mov [rsp+16], rbx
	mov rbx, 64
	mov [rsp+24], rbx
	call read
	add rsp, 32
	call block_stdin
	sub rsp, 32
	mov rbx, 0
	mov [rsp+8], rbx
	mov rbx, 0
	mov [rsp+16], rbx
	lea rbx, [rsp+136]
	mov [rsp+24], rbx
	call tcsetattr
	add rsp, 32
	sub rsp, 16
	fld QWORD [FP5]
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
	mov cl, 121
	cmp bl, cl
	setne bl
	test bl, bl
	je .L21
	jmp .L2
	jmp .L22
	.L21:
	.L22:
	call init_game
	mov bl, 0
	mov [rsp+31], bl
	call nonblock_stdin
	sub rsp, 32
	mov rbx, 0
	mov [rsp+8], rbx
	mov rbx, 0
	mov [rsp+16], rbx
	lea rbx, [rsp+80]
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
extern absi
extern absf
extern random
extern randint
extern is_alpha
extern is_num
extern is_alnum
extern to_lower
extern to_upper
extern set_rounding
extern sqrt
extern pow
extern log
extern sin
extern cos
extern tan
extern atan2
extern round
extern floor
extern ceil
extern trunc
extern int_to_fixed
extern fraction_to_fixed
extern string_to_fixed
extern fixed_to_int
extern mul_fixed
extern div_fixed
extern mod_fixed
extern memset
extern memcpy
extern memmove
extern strlen
extern strfind
extern strdfind
extern strcpy
extern strcmp
extern strequal
extern flush_stdout
extern print_str
extern print_char
extern print_decimal
extern print_udecimal
extern print_hex
extern print_fixed
extern print_float
extern print_format
extern print
extern println
extern error
extern input
extern input_char
extern int_to_string
extern uint_to_string
extern string_to_int
extern read
extern write
extern exit
extern syscall1
extern syscall2
extern syscall3


section .data
snake:
times 4096 db 0
last_direction:
times 8 db 0
snake_length:
dq 0
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
db "SCORE: %04	Press q to quit.",0
STR4:
db "> GAME OVER <",10,"Play again? (y/n) ",0
FP0:
dq 1.0
FP1:
dq 1000000000.0
FP2:
dq 1000000000.0
FP3:
dq 0.1
FP4:
dq 0.075
FP5:
dq 0.25
