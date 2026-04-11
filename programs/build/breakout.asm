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

global TTY.unblock_stdin:function
TTY.unblock_stdin:
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
	or rbx, 0x800
	mov [rsp+24], rbx
	call fcntl
	add rsp, 32
	.L0:
	leave
	ret

global TTY.block_stdin:function
TTY.block_stdin:
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
	and rbx, 0xfffffffffffff7ff
	mov [rsp+24], rbx
	call fcntl
	add rsp, 32
	.L0:
	leave
	ret

global TTY.restore_old:function
TTY.restore_old:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	xor rbx, rbx
	mov [rsp+8], rbx
	xor rbx, rbx
	mov [rsp+16], rbx
	lea rbx, [TTY+0]
	mov [rsp+24], rbx
	call tcsetattr
	add rsp, 32
	.L0:
	leave
	ret

global TTY.raw_input:function
TTY.raw_input:
	push rbp
	mov rbp, rsp
	lea rcx, [TTY+0]
	mov ebx, DWORD [rcx+0]
	mov rcx, 0xdada
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L1
	sub rsp, 32
	xor rbx, rbx
	mov [rsp+8], rbx
	lea rbx, [TTY+0]
	mov [rsp+16], rbx
	call tcgetattr
	add rsp, 32
	.L1:
	.L2:
	lea rcx, [TTY+56]
	mov ebx, DWORD [rcx+0]
	mov rcx, 0xdada
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L3
	lea rbx, [TTY+56]
	lea r8, [TTY+0]
	cld
	mov rdi, rbx
	lea rsi, [r8]
	mov rcx, 7
	rep movsq
	lea rbx, [TTY+56]
	lea rsi, [TTY+56]
	mov ecx, [rsi+12]
	and ecx, 0xfffffff5
	mov [rbx+12], ecx
	.L3:
	.L4:
	sub rsp, 32
	xor rbx, rbx
	mov [rsp+8], rbx
	xor rbx, rbx
	mov [rsp+16], rbx
	lea rbx, [TTY+56]
	mov [rsp+24], rbx
	call tcsetattr
	add rsp, 32
	.L0:
	leave
	ret

global vec2.add:function
vec2.add:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	mov rsi, [rbp+24]
	mov ecx, [rsi+0]
	mov esi, [rbp+32]
	add ecx, esi
	mov [rbx+0], ecx
	mov rsi, [rbp+24]
	mov ecx, [rsi+4]
	mov esi, [rbp+36]
	add ecx, esi
	mov [rbx+4], ecx
	jmp .L0
	.L0:
	leave
	ret

global vec2.iadd:function
vec2.iadd:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	mov rsi, [rbp+16]
	mov ecx, [rsi+0]
	mov esi, [rbp+24]
	add ecx, esi
	mov [rbx+0], ecx
	mov rbx, [rbp+16]
	mov rsi, [rbp+16]
	mov ecx, [rsi+4]
	mov esi, [rbp+28]
	add ecx, esi
	mov [rbx+4], ecx
	.L0:
	leave
	ret

global vec2.sub:function
vec2.sub:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	mov rsi, [rbp+24]
	mov ecx, [rsi+0]
	mov esi, [rbp+32]
	sub ecx, esi
	mov [rbx+0], ecx
	mov rsi, [rbp+24]
	mov ecx, [rsi+4]
	mov esi, [rbp+36]
	sub ecx, esi
	mov [rbx+4], ecx
	jmp .L0
	.L0:
	leave
	ret

global vec2.isub:function
vec2.isub:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	mov rsi, [rbp+16]
	mov ecx, [rsi+0]
	mov esi, [rbp+24]
	sub ecx, esi
	mov [rbx+0], ecx
	mov rbx, [rbp+16]
	mov rsi, [rbp+16]
	mov ecx, [rsi+4]
	mov esi, [rbp+28]
	sub ecx, esi
	mov [rbx+4], ecx
	.L0:
	leave
	ret

global vec2.mul:function
vec2.mul:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	mov rcx, [rbp+24]
	mov eax, [rcx+0]
	mov ecx, [rbp+32]
	imul ecx
	mov [rbx+0], eax
	mov rcx, [rbp+24]
	mov eax, [rcx+4]
	mov ecx, [rbp+32]
	imul ecx
	mov [rbx+4], eax
	jmp .L0
	.L0:
	leave
	ret

global vec2.imul:function
vec2.imul:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	mov rcx, [rbp+16]
	mov eax, [rcx+0]
	mov ecx, [rbp+24]
	imul ecx
	mov [rbx+0], eax
	mov rbx, [rbp+16]
	mov rcx, [rbp+16]
	mov eax, [rcx+4]
	mov ecx, [rbp+24]
	imul ecx
	mov [rbx+4], eax
	.L0:
	leave
	ret

global vec2.div:function
vec2.div:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	mov rcx, [rbp+24]
	mov eax, [rcx+0]
	mov ecx, [rbp+32]
	xor rdx, rdx
	idiv ecx
	mov [rbx+0], eax
	mov rcx, [rbp+24]
	mov eax, [rcx+4]
	mov ecx, [rbp+32]
	xor rdx, rdx
	idiv ecx
	mov [rbx+4], eax
	jmp .L0
	.L0:
	leave
	ret

global vec2.idiv:function
vec2.idiv:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	mov rcx, [rbp+16]
	mov eax, [rcx+0]
	mov ecx, [rbp+24]
	imul ecx
	mov [rbx+0], eax
	mov rbx, [rbp+16]
	mov rcx, [rbp+16]
	mov eax, [rcx+4]
	mov ecx, [rbp+24]
	imul ecx
	mov [rbx+4], eax
	.L0:
	leave
	ret

global vec2.dot:function
vec2.dot:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+24]
	movsxd rax, DWORD [rbx+0]
	movsxd rbx, DWORD [rbp+32]
	imul rbx
	mov rcx, [rbp+24]
	movsxd rbx, DWORD [rcx+4]
	movsxd rcx, DWORD [rbp+36]
	mov rsi, rax
	mov rax, rbx
	imul rcx
	mov rbx, rax
	mov rax, rsi
	add rax, rbx
	mov [rbp+16], rax
	jmp .L0
	.L0:
	leave
	ret

global vec2.is_equal:function
vec2.is_equal:
	push rbp
	mov rbp, rsp
	mov rcx, [rbp+24]
	mov ebx, [rcx+0]
	mov ecx, [rbp+32]
	cmp ebx, ecx
	sete bl
	test bl, bl
	je .L1
	mov rsi, [rbp+24]
	mov ecx, [rsi+4]
	mov esi, [rbp+36]
	cmp ecx, esi
	sete bl
	.L1:
	mov [rbp+16], bl
	jmp .L0
	.L0:
	leave
	ret

global vec2.print:function
vec2.print:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov rbx, STR0
	mov [rsp+0], rbx
	mov rcx, [rbp+16]
	movsxd rbx, DWORD [rcx+0]
	mov [rsp+8], rbx
	mov rcx, [rbp+16]
	movsxd rbx, DWORD [rcx+4]
	mov [rsp+16], rbx
	call println
	add rsp, 32
	.L0:
	leave
	ret

global Input.get:function
Input.get:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	xor ebx, ebx
	mov [Input+0], ebx
	xor bl, bl
	mov [Input+4], bl
	sub rsp, 32
	mov rbx, QWORD [stdin]
	mov [rsp+8], rbx
	lea rbx, [rsp+56]
	mov [rsp+16], rbx
	mov rbx, 0x18
	mov [rsp+24], rbx
	call File.read
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+16], rbx
	mov rbx, [rsp+16]
	xor rcx, rcx
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L1
	jmp .L0
	.L1:
	.L2:
	lea rbx, [rsp+24]
	mov [rsp+8], rbx
	mov rbx, [rsp+16]
	.L3:
	test rbx, rbx
	je .L5
	sub rsp, 32
	mov [rsp+24], rbx
	mov rcx, [rsp+40]
	mov sil, [rcx]
	mov [rsp+1], sil
	call to_lower
	mov rbx, [rsp+24]
	mov cl, [rsp+0]
	add rsp, 32
	mov sil, 0x61
	cmp cl, sil
	sete cl
	test cl, cl
	je .L6
	lea rsi, [Input+0]
	dec DWORD [rsi]
	mov ecx, [rsi]
	jmp .L7
	.L6:
	sub rsp, 32
	mov [rsp+24], rbx
	mov rcx, [rsp+40]
	mov sil, [rcx]
	mov [rsp+1], sil
	call to_lower
	mov rbx, [rsp+24]
	mov cl, [rsp+0]
	add rsp, 32
	mov sil, 0x64
	cmp cl, sil
	sete cl
	test cl, cl
	je .L8
	lea rsi, [Input+0]
	inc DWORD [rsi]
	mov ecx, [rsi]
	jmp .L7
	.L8:
	mov rcx, [rsp+8]
	mov sil, [rcx]
	mov cl, 0x20
	cmp sil, cl
	sete cl
	test cl, cl
	je .L9
	mov cl, 0x1
	mov [Input+4], cl
	jmp .L7
	.L9:
	mov rcx, [rsp+8]
	mov sil, [rcx]
	mov cl, 0x71
	cmp sil, cl
	sete cl
	test cl, cl
	je .L10
	mov cl, 0x1
	mov [Game+0], cl
	jmp .L7
	.L10:
	.L7:
	.L4:
	dec rbx
	jmp .L3
	.L5:
	.L0:
	leave
	ret

global Blocks.init:function
Blocks.init:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	lea rbx, [Blocks+0]
	mov [rsp+0], rbx
	mov bl, 0x1
	mov [rsp+8], bl
	mov rbx, 0x78
	mov [rsp+16], rbx
	call memset
	add rsp, 32
	.L0:
	leave
	ret

global Blocks.collide:function
Blocks.collide:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	movsxd rbx, DWORD [rbp+20]
	xor rcx, rcx
	cmp rbx, rcx
	setl bl
	test bl, bl
	jne .L5
	movsxd rcx, DWORD [rbp+20]
	mov rsi, 0x30
	cmp rcx, rsi
	setge bl
	.L5:
	test bl, bl
	jne .L4
	movsxd rcx, DWORD [rbp+24]
	xor rsi, rsi
	cmp rcx, rsi
	setl bl
	.L4:
	test bl, bl
	jne .L3
	movsxd rcx, DWORD [rbp+24]
	mov rsi, 0x5
	cmp rcx, rsi
	setge bl
	.L3:
	test bl, bl
	je .L1
	xor bl, bl
	mov [rbp+16], bl
	jmp .L0
	.L1:
	.L2:
	lea rbx, [Blocks+0]
	mov ecx, DWORD [rbp+20]
	shr rcx, 1
	add rbx, rcx
	mov ecx, DWORD [rbp+24]
	shl rcx, 3
	lea rcx, [rcx+rcx*2]
	add rbx, rcx
	mov [rsp+8], rbx
	mov rbx, [rsp+8]
	mov cl, [rbx]
	mov [rbp+16], cl
	mov bl, [rbp+16]
	test bl, bl
	je .L6
	mov rbx, [rsp+8]
	xor cl, cl
	mov [rbx], cl
	lea rcx, [Game+8]
	mov rbx, [rcx]
	inc QWORD [rcx]
	.L6:
	.L7:
	.L0:
	leave
	ret

global Blocks.check_hit:function
Blocks.check_hit:
	push rbp
	mov rbp, rsp
	mov bl, 0x1
	mov [rbp+16], bl
	sub rsp, 16
	mov rcx, [rbp+24]
	mov ebx, [rcx+0]
	mov rsi, [rbp+32]
	mov ecx, [rsi+0]
	add ebx, ecx
	mov [rsp+4], ebx
	mov rcx, [rbp+24]
	mov ebx, [rcx+4]
	mov [rsp+8], ebx
	call Blocks.collide
	mov bl, [rsp+0]
	add rsp, 16
	test bl, bl
	je .L1
	mov rbx, [rbp+32]
	mov rsi, [rbp+32]
	mov ecx, [rsi+0]
	neg ecx
	mov [rbx+0], ecx
	jmp .L2
	.L1:
	sub rsp, 16
	mov rcx, [rbp+24]
	mov ebx, [rcx+0]
	mov [rsp+4], ebx
	mov rcx, [rbp+24]
	mov ebx, [rcx+4]
	mov rsi, [rbp+32]
	mov ecx, [rsi+4]
	add ebx, ecx
	mov [rsp+8], ebx
	call Blocks.collide
	mov bl, [rsp+0]
	add rsp, 16
	test bl, bl
	je .L3
	mov rbx, [rbp+32]
	mov rsi, [rbp+32]
	mov ecx, [rsi+4]
	neg ecx
	mov [rbx+4], ecx
	jmp .L2
	.L3:
	sub rsp, 16
	mov rcx, [rbp+24]
	mov ebx, [rcx+0]
	mov rsi, [rbp+32]
	mov ecx, [rsi+0]
	add ebx, ecx
	mov [rsp+4], ebx
	mov rcx, [rbp+24]
	mov ebx, [rcx+4]
	mov rsi, [rbp+32]
	mov ecx, [rsi+4]
	add ebx, ecx
	mov [rsp+8], ebx
	call Blocks.collide
	mov bl, [rsp+0]
	add rsp, 16
	test bl, bl
	je .L4
	mov rbx, [rbp+32]
	mov rsi, [rbp+32]
	mov ecx, [rsi+0]
	neg ecx
	mov [rbx+0], ecx
	mov rbx, [rbp+32]
	mov rsi, [rbp+32]
	mov ecx, [rsi+4]
	neg ecx
	mov [rbx+4], ecx
	jmp .L2
	.L4:
	xor bl, bl
	mov [rbp+16], bl
	.L2:
	.L0:
	leave
	ret

global Paddle.update:function
Paddle.update:
	push rbp
	mov rbp, rsp
	mov ebx, DWORD [Paddle+0]
	mov ecx, DWORD [Input+0]
	add ebx, ecx
	mov [Paddle+0], ebx
	movsxd rbx, DWORD [Paddle+0]
	xor rcx, rcx
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L1
	xor ebx, ebx
	mov [Paddle+0], ebx
	jmp .L2
	.L1:
	movsxd rbx, DWORD [Paddle+0]
	mov rcx, 0x14
	cmp rbx, rcx
	setge bl
	test bl, bl
	je .L3
	mov ebx, 0x14
	mov [Paddle+0], ebx
	jmp .L2
	.L3:
	.L2:
	.L0:
	leave
	ret

global Paddle.check_hit:function
Paddle.check_hit:
	push rbp
	mov rbp, rsp
	xor bl, bl
	mov [rbp+16], bl
	mov rcx, [rbp+32]
	movsxd rbx, DWORD [rcx+4]
	xor rcx, rcx
	cmp rbx, rcx
	setg bl
	test bl, bl
	je .L3
	mov rsi, [rbp+24]
	movsxd rcx, DWORD [rsi+4]
	mov rdi, [rbp+32]
	movsxd rsi, DWORD [rdi+4]
	add rcx, rsi
	mov rsi, 0xf
	cmp rcx, rsi
	sete bl
	.L3:
	test bl, bl
	je .L1
	sub rsp, 16
	mov rcx, [rbp+24]
	mov ebx, [rcx+0]
	mov rsi, [rbp+32]
	mov ecx, [rsi+0]
	add ebx, ecx
	mov [rsp+12], ebx
	movsxd rbx, DWORD [rsp+12]
	sar rbx, 1
	movsxd rcx, DWORD [Paddle+0]
	cmp rbx, rcx
	setge bl
	test bl, bl
	je .L6
	movsxd rcx, DWORD [rsp+12]
	sar rcx, 1
	movsxd rsi, DWORD [Paddle+0]
	add rsi, 0x4
	cmp rcx, rsi
	setl bl
	.L6:
	test bl, bl
	je .L4
	movsxd rbx, DWORD [rsp+12]
	sar rbx, 1
	movsxd rcx, DWORD [Paddle+0]
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L10
	mov rsi, [rbp+32]
	movsxd rcx, DWORD [rsi+0]
	xor rsi, rsi
	cmp rcx, rsi
	setg bl
	.L10:
	test bl, bl
	jne .L9
	movsxd rcx, DWORD [rsp+12]
	sar rcx, 1
	movsxd rsi, DWORD [Paddle+0]
	add rsi, 0x4
	dec rsi
	cmp rcx, rsi
	sete bl
	test bl, bl
	je .L11
	mov rsi, [rbp+32]
	movsxd rcx, DWORD [rsi+0]
	xor rsi, rsi
	cmp rcx, rsi
	setl bl
	.L11:
	.L9:
	test bl, bl
	je .L7
	mov rbx, [rbp+32]
	mov rsi, [rbp+32]
	mov ecx, [rsi+0]
	neg ecx
	mov [rbx+0], ecx
	.L7:
	.L8:
	mov rbx, [rbp+32]
	mov rsi, [rbp+32]
	mov ecx, [rsi+4]
	neg ecx
	mov [rbx+4], ecx
	mov bl, 0x1
	mov [rbp+16], bl
	.L4:
	.L5:
	add rsp, 16
	.L1:
	.L2:
	.L0:
	leave
	ret

global Ball.check_collisions:function
Ball.check_collisions:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov bl, 0x1
	mov [rbp+16], bl
	sub rsp, 32
	lea rbx, [Ball+8]
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	xor ecx, ecx
	mov [rbx+0], ecx
	xor ecx, ecx
	mov [rbx+4], ecx
	call vec2.is_equal
	mov bl, [rsp+0]
	add rsp, 32
	test bl, bl
	je .L3
	mov bl, BYTE [Input+4]
	.L3:
	test bl, bl
	je .L1
	lea rbx, [Ball+8]
	sub rsp, 32
	mov [rsp+24], rbx
	xor rcx, rcx
	mov [rsp+8], rcx
	mov rcx, 0x2
	mov [rsp+16], rcx
	call randint
	mov rbx, [rsp+24]
	mov ecx, [rsp+0]
	add rsp, 32
	shl ecx, 1
	dec ecx
	mov [rbx+0], ecx
	mov ecx, 0xffffffff
	mov [rbx+4], ecx
	.L1:
	.L2:
	lea rbx, [rsp+8]
	sub rsp, 32
	mov [rsp+0], rbx
	lea rbx, [Ball+0]
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	lea r8, [Ball+8]
	mov rdi, [r8]
	mov [rbx], rdi
	call vec2.add
	add rsp, 32
	movsxd rbx, DWORD [rsp+8]
	xor rcx, rcx
	cmp rbx, rcx
	setl bl
	test bl, bl
	jne .L6
	movsxd rcx, DWORD [rsp+8]
	mov rsi, 0x30
	cmp rcx, rsi
	setge bl
	.L6:
	test bl, bl
	je .L4
	lea rbx, [Ball+8]
	lea rsi, [Ball+8]
	mov ecx, [rsi+0]
	neg ecx
	mov [rbx+0], ecx
	jmp .L5
	.L4:
	movsxd rbx, DWORD [rsp+12]
	xor rcx, rcx
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L7
	lea rbx, [Ball+8]
	lea rsi, [Ball+8]
	mov ecx, [rsi+4]
	neg ecx
	mov [rbx+4], ecx
	jmp .L5
	.L7:
	movsxd rbx, DWORD [rsp+12]
	mov rcx, 0x10
	cmp rbx, rcx
	setge bl
	test bl, bl
	je .L8
	mov bl, 0x1
	mov [Game+0], bl
	xor bl, bl
	mov [rbp+16], bl
	jmp .L0
	jmp .L5
	.L8:
	xor bl, bl
	mov [rbp+16], bl
	.L5:
	mov bl, [rbp+16]
	sub rsp, 32
	mov [rsp+31], bl
	lea rcx, [Ball+0]
	mov [rsp+8], rcx
	lea rcx, [Ball+8]
	mov [rsp+16], rcx
	call Blocks.check_hit
	mov bl, [rsp+31]
	mov cl, [rsp+0]
	add rsp, 32
	or bl, cl
	mov [rbp+16], bl
	mov bl, [rbp+16]
	sub rsp, 32
	mov [rsp+31], bl
	lea rcx, [Ball+0]
	mov [rsp+8], rcx
	lea rcx, [Ball+8]
	mov [rsp+16], rcx
	call Paddle.check_hit
	mov bl, [rsp+31]
	mov cl, [rsp+0]
	add rsp, 32
	or bl, cl
	mov [rbp+16], bl
	.L0:
	leave
	ret

global Ball.update:function
Ball.update:
	push rbp
	mov rbp, rsp
	.L1:
	sub rsp, 16
	call Ball.check_collisions
	mov bl, [rsp+0]
	add rsp, 16
	test bl, bl
	je .L2
	jmp .L1
	.L2:
	sub rsp, 16
	lea rbx, [Ball+0]
	mov [rsp+0], rbx
	lea rbx, [rsp+8]
	lea r8, [Ball+8]
	mov rdi, [r8]
	mov [rbx], rdi
	call vec2.iadd
	add rsp, 16
	.L0:
	leave
	ret

global Screen.clear:function
Screen.clear:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	lea rbx, [Screen+0]
	mov [rsp+0], rbx
	mov bl, 0x20
	mov [rsp+8], bl
	mov rbx, 0x300
	mov [rsp+16], rbx
	call memset
	add rsp, 32
	sub rsp, 16
	mov rbx, STR1
	mov [rsp+0], rbx
	call print
	add rsp, 16
	sub rsp, 16
	mov rbx, QWORD [stdout]
	mov [rsp+0], rbx
	call File.flush
	add rsp, 16
	.L0:
	leave
	ret

global Screen.print:function
Screen.print:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	lea rbx, [Screen+0]
	mov [rsp+24], rbx
	lea rbx, [Blocks+0]
	mov [rsp+16], rbx
	mov rbx, 0x78
	.L1:
	test rbx, rbx
	je .L3
	mov rcx, [rsp+16]
	inc QWORD [rsp+16]
	mov sil, [rcx]
	test sil, sil
	je .L4
	mov r8, [rsp+24]
	mov cl, 0x5b
	mov [r8], cl
	mov r8, [rsp+24]
	inc r8
	mov cl, 0x5d
	mov [r8], cl
	.L4:
	.L5:
	mov rcx, [rsp+24]
	add rcx, 0x2
	mov [rsp+24], rcx
	.L2:
	dec rbx
	jmp .L1
	.L3:
	lea rcx, [Screen+0]
	mov rsi, 0x2d0
	lea rbx, [rcx+rsi*1]
	mov [rsp+24], rbx
	mov ebx, DWORD [Paddle+0]
	shl ebx, 1
	mov [rsp+12], ebx
	mov rbx, [rsp+24]
	mov ecx, DWORD [rsp+12]
	inc DWORD [rsp+12]
	add rbx, rcx
	mov cl, 0x3c
	mov [rbx], cl
	mov rbx, 0x6
	.L6:
	test rbx, rbx
	je .L8
	mov r8, [rsp+24]
	mov ecx, DWORD [rsp+12]
	inc DWORD [rsp+12]
	add r8, rcx
	mov cl, 0x3d
	mov [r8], cl
	.L7:
	dec rbx
	jmp .L6
	.L8:
	mov rbx, [rsp+24]
	mov ecx, DWORD [rsp+12]
	inc DWORD [rsp+12]
	add rbx, rcx
	mov cl, 0x3e
	mov [rbx], cl
	lea rcx, [Ball+0]
	movsxd rbx, DWORD [rcx+0]
	xor rcx, rcx
	cmp rbx, rcx
	setge bl
	test bl, bl
	je .L13
	lea rsi, [Ball+0]
	movsxd rcx, DWORD [rsi+0]
	mov rsi, 0x30
	cmp rcx, rsi
	setl bl
	.L13:
	test bl, bl
	je .L12
	lea rsi, [Ball+0]
	movsxd rcx, DWORD [rsi+4]
	xor rsi, rsi
	cmp rcx, rsi
	setge bl
	.L12:
	test bl, bl
	je .L11
	lea rsi, [Ball+0]
	movsxd rcx, DWORD [rsi+4]
	mov rsi, 0x10
	cmp rcx, rsi
	setl bl
	.L11:
	test bl, bl
	je .L9
	lea rbx, [Screen+0]
	lea rsi, [Ball+0]
	mov ecx, DWORD [rsi+0]
	lea rdi, [Ball+0]
	mov esi, DWORD [rdi+4]
	shl rsi, 4
	lea rsi, [rsi+rsi*2]
	add rcx, rsi
	mov sil, 0x40
	mov [rbx+rcx*1], sil
	.L9:
	.L10:
	lea rbx, [Screen+0]
	mov [rsp+24], rbx
	mov rbx, 0x10
	.L14:
	test rbx, rbx
	je .L16
	sub rsp, 32
	mov [rsp+24], rbx
	mov rcx, STR2
	mov [rsp+0], rcx
	mov rcx, 0x30
	mov [rsp+8], rcx
	mov rcx, [rsp+56]
	mov [rsp+16], rcx
	call println
	mov rbx, [rsp+24]
	add rsp, 32
	mov rcx, [rsp+24]
	add rcx, 0x30
	mov [rsp+24], rcx
	.L15:
	dec rbx
	jmp .L14
	.L16:
	sub rsp, 48
	mov rbx, STR3
	mov [rsp+0], rbx
	mov rbx, QWORD [Game+8]
	mov [rsp+8], rbx
	mov rbx, 0x18
	mov [rsp+16], rbx
	mov rbx, 0x3d
	mov [rsp+24], rbx
	mov rbx, 0x18
	mov [rsp+32], rbx
	mov rbx, 0x3d
	mov [rsp+40], rbx
	call println
	add rsp, 48
	.L0:
	leave
	ret

global main:function
main:
	push rbp
	mov rbp, rsp
	call Blocks.init
	call TTY.raw_input
	call TTY.unblock_stdin
	.L1:
	mov cl, BYTE [Game+0]
	test cl, cl
	sete bl
	test bl, bl
	je .L2
	call Screen.clear
	call Screen.print
	call Input.get
	call Paddle.update
	call Ball.update
	sub rsp, 16
	fld QWORD [FP0]
	fstp QWORD [rsp+0]
	call sleep
	add rsp, 16
	jmp .L1
	.L2:
	call TTY.restore_old
	call TTY.block_stdin
	.L0:
	leave
	ret


extern log:function
extern nanosleep:function
extern sin:function
extern print_char:function
extern trunc:function
extern print:function
extern set_rounding:function
extern pow:function
extern memmove:function
extern sleep:function
extern random:function
extern is_num:function
extern memset:function
extern malloc:function
extern exit:function
extern tan:function
extern int_to_string:function
extern string_to_int:function
extern msleep:function
extern usleep:function
extern tcgetattr:function
extern print_format:function
extern fcntl:function
extern strcmp:function
extern strfind:function
extern absf:function
extern print_fixed:function
extern tcsetattr:function
extern absi:function
extern floor:function
extern uint_to_string:function
extern clock_gettime:function
extern strdfind:function
extern free:function
extern flush_stdout:function
extern to_lower:function
extern memcpy:function
extern input_char:function
extern time:function
extern strequal:function
extern strlen:function
extern ioctl:function
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
extern syscall1:function
extern syscall2:function
extern syscall3:function
extern println:function
extern round:function
extern sqrt:function
extern error:function
extern randint:function
extern print_hex:function
extern cfmakeraw:function
extern atan2:function
extern is_alnum:function
extern File.write:function
extern File.read:function
extern File.print:function
extern File.println:function
extern File.set_buffering:function
extern File.set_buffer:function
extern File.flush:function
extern string.str:function
extern string.length:function
extern string.print:function
extern string.compare:function
extern string.is_equal:function
extern string.is_heap:function
extern string.is_stack:function
extern string.free:function
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
extern string.from_heap:function
extern string.share:function
extern string.new:function
extern string.format:function


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
global TTY:data
TTY:
dd 56026
times 4 db 0
times 4 db 0
times 4 db 0
times 32 db 0
times 4 db 0
times 4 db 0
dd 56026
times 4 db 0
times 4 db 0
times 4 db 0
times 32 db 0
times 4 db 0
times 4 db 0
global Game:data
Game:
db 0
times 7 db 0
dq 0
global Input:data
Input:
times 4 db 0
times 1 db 0
times 3 db 0
global Blocks:data
Blocks:
times 120 db 0
global Paddle:data
Paddle:
dd 10
times 4 db 0
global Ball:data
Ball:
dd 24
dd 14
dd 0
dd 0
global Screen:data
Screen:
times 768 db 0


section .rodata
STR0:
db "(%i, %i)",0
STR1:
db "",0x1b,"[2H",0x1b,"[J",0
STR2:
db "%*s",0
STR3:
db "%[|| SCORE: %03 %*L%[ q to exit game. ||%*R",0
FP0:
dq 0.15
