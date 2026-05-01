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
	lea rdi, [rbx]
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
	mov rbx, [rsp+40]
	mov cl, [rbx]
	mov [rsp+1], cl
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
	mov rbx, [rsp+40]
	mov cl, [rbx]
	mov [rsp+1], cl
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
	mov rsi, 0x13
	cmp rcx, rsi
	sete bl
	test bl, bl
	jne .L4
	mov rsi, [rbp+24]
	movsxd rcx, DWORD [rsi+4]
	mov rsi, 0x13
	cmp rcx, rsi
	sete bl
	.L4:
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
	je .L7
	movsxd rcx, DWORD [rsp+12]
	sar rcx, 1
	movsxd rsi, DWORD [Paddle+0]
	add rsi, 0x4
	cmp rcx, rsi
	setl bl
	.L7:
	test bl, bl
	je .L5
	movsxd rbx, DWORD [rsp+12]
	sar rbx, 1
	movsxd rcx, DWORD [Paddle+0]
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L11
	mov rsi, [rbp+32]
	movsxd rcx, DWORD [rsi+0]
	xor rsi, rsi
	cmp rcx, rsi
	setg bl
	.L11:
	test bl, bl
	jne .L10
	movsxd rcx, DWORD [rsp+12]
	sar rcx, 1
	movsxd rsi, DWORD [Paddle+0]
	add rsi, 0x4
	dec rsi
	cmp rcx, rsi
	sete bl
	test bl, bl
	je .L12
	mov rsi, [rbp+32]
	movsxd rcx, DWORD [rsi+0]
	xor rsi, rsi
	cmp rcx, rsi
	setl bl
	.L12:
	.L10:
	test bl, bl
	je .L8
	mov rbx, [rbp+32]
	mov rsi, [rbp+32]
	mov ecx, [rsi+0]
	neg ecx
	mov [rbx+0], ecx
	.L8:
	.L9:
	mov rbx, [rbp+32]
	mov rsi, [rbp+32]
	mov ecx, [rsi+4]
	neg ecx
	mov [rbx+4], ecx
	mov bl, 0x1
	mov [rbp+16], bl
	.L5:
	.L6:
	add rsp, 16
	.L1:
	.L2:
	.L0:
	leave
	ret

global Powerups.init:function
Powerups.init:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	lea rbx, [Powerups+0]
	mov [rsp+0], rbx
	xor bl, bl
	mov [rsp+8], bl
	mov rbx, 0x80
	mov [rsp+16], rbx
	call memset
	add rsp, 32
	.L0:
	leave
	ret

global Powerups.new:function
Powerups.new:
	push rbp
	mov rbp, rsp
	mov rbx, QWORD [Powerups+128]
	mov rcx, 0x8
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L1
	sub rsp, 16
	lea rbx, [Powerups+0]
	mov [rsp+8], rbx
	mov rbx, 0x8
	.L3:
	test rbx, rbx
	je .L5
	mov rsi, [rsp+8]
	mov rcx, [rsi+0]
	xor rsi, rsi
	cmp rcx, rsi
	sete cl
	test cl, cl
	je .L6
	jmp .L5
	.L6:
	.L7:
	mov rcx, [rsp+8]
	add rcx, 0x10
	mov [rsp+8], rcx
	.L4:
	dec rbx
	jmp .L3
	.L5:
	mov rbx, [rsp+8]
	mov rcx, 0x1
	mov [rbx+0], rcx
	lea r8, [rbx+8]
	mov ecx, [rbp+16]
	mov [r8+0], ecx
	mov ecx, [rbp+20]
	mov [r8+4], ecx
	lea rcx, [Powerups+128]
	mov rbx, [rcx]
	inc QWORD [rcx]
	add rsp, 16
	.L1:
	.L2:
	.L0:
	leave
	ret

global Powerups.destroy:function
Powerups.destroy:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	xor rcx, rcx
	mov [rbx+0], rcx
	lea rcx, [Powerups+128]
	mov rbx, [rcx]
	dec QWORD [rcx]
	.L0:
	leave
	ret

global Powerups.update:function
Powerups.update:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	lea rbx, [Powerups+0]
	mov [rsp+8], rbx
	mov rbx, 0x8
	.L1:
	test rbx, rbx
	je .L3
	mov rsi, [rsp+8]
	mov rcx, [rsi+0]
	mov rsi, 0x1
	cmp rcx, rsi
	sete cl
	test cl, cl
	je .L4
	mov rsi, [rsp+8]
	lea rsi, [rsi+8]
	lea rsi, [rsi+4]
	inc DWORD [rsi]
	movsxd rcx, DWORD [rsi]
	mov rsi, 0x14
	cmp rcx, rsi
	sete cl
	test cl, cl
	je .L6
	sub rsp, 16
	mov [rsp+8], rbx
	mov rbx, [rsp+24]
	mov [rsp+0], rbx
	call Powerups.destroy
	mov rbx, [rsp+8]
	add rsp, 16
	.L6:
	.L7:
	mov rsi, [rsp+8]
	lea rsi, [rsi+8]
	movsxd rcx, DWORD [rsi+4]
	mov rsi, 0x13
	cmp rcx, rsi
	setge cl
	test cl, cl
	je .L11
	movsxd rsi, DWORD [Paddle+0]
	mov r8, [rsp+8]
	lea r8, [r8+8]
	movsxd rdi, DWORD [r8+0]
	sar rdi, 1
	cmp rsi, rdi
	setle cl
	.L11:
	test cl, cl
	je .L10
	mov rdi, [rsp+8]
	lea rdi, [rdi+8]
	movsxd rsi, DWORD [rdi+0]
	sar rsi, 1
	movsxd rdi, DWORD [Paddle+0]
	add rdi, 0x4
	cmp rsi, rdi
	setl cl
	.L10:
	test cl, cl
	je .L8
	sub rsp, 16
	mov [rsp+8], rbx
	mov rbx, [rsp+24]
	mov [rsp+0], rbx
	call Powerups.destroy
	mov rbx, [rsp+8]
	add rsp, 16
	sub rsp, 16
	mov [rsp+8], rbx
	call Balls.new
	mov rbx, [rsp+8]
	add rsp, 16
	.L8:
	.L9:
	.L4:
	.L5:
	mov rcx, [rsp+8]
	add rcx, 0x10
	mov [rsp+8], rcx
	.L2:
	dec rbx
	jmp .L1
	.L3:
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
	mov rbx, 0x90
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
	mov rsi, 0x6
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
	sub rsp, 32
	xor rbx, rbx
	mov [rsp+8], rbx
	mov rbx, 0x3
	mov [rsp+16], rbx
	call randint
	mov rbx, [rsp+0]
	add rsp, 32
	xor rcx, rcx
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L8
	sub rsp, 16
	mov ebx, [rbp+20]
	mov [rsp+0], ebx
	mov ebx, [rbp+24]
	mov [rsp+4], ebx
	call Powerups.new
	add rsp, 16
	.L8:
	.L9:
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

global Ball.check_collisions:function
Ball.check_collisions:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov bl, 0x1
	mov [rbp+16], bl
	sub rsp, 32
	mov rbx, [rbp+24]
	lea rbx, [rbx+8]
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
	mov rbx, [rbp+24]
	lea rbx, [rbx+8]
	sub rsp, 32
	mov [rsp+24], rbx
	xor rbx, rbx
	mov [rsp+8], rbx
	mov rbx, 0x2
	mov [rsp+16], rbx
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
	mov rbx, [rbp+24]
	lea rbx, [rbx+0]
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	mov r8, [rbp+24]
	lea r8, [r8+8]
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
	mov rbx, [rbp+24]
	lea rbx, [rbx+8]
	mov rsi, [rbp+24]
	lea rsi, [rsi+8]
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
	mov rbx, [rbp+24]
	lea rbx, [rbx+8]
	mov rsi, [rbp+24]
	lea rsi, [rsi+8]
	mov ecx, [rsi+4]
	neg ecx
	mov [rbx+4], ecx
	jmp .L5
	.L7:
	movsxd rbx, DWORD [rsp+12]
	mov rcx, 0x14
	cmp rbx, rcx
	setge bl
	test bl, bl
	je .L8
	sub rsp, 16
	mov rbx, [rbp+24]
	mov [rsp+0], rbx
	call Balls.destroy
	add rsp, 16
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
	mov rbx, [rbp+24]
	lea rbx, [rbx+0]
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	lea rbx, [rbx+8]
	mov [rsp+16], rbx
	call Blocks.check_hit
	mov bl, [rsp+31]
	mov cl, [rsp+0]
	add rsp, 32
	or bl, cl
	mov [rbp+16], bl
	mov bl, [rbp+16]
	sub rsp, 32
	mov [rsp+31], bl
	mov rbx, [rbp+24]
	lea rbx, [rbx+0]
	mov [rsp+8], rbx
	mov rbx, [rbp+24]
	lea rbx, [rbx+8]
	mov [rsp+16], rbx
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
	mov rcx, [rbp+16]
	mov bl, [rcx+16]
	test bl, bl
	je .L1
	.L3:
	sub rsp, 16
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	call Ball.check_collisions
	mov bl, [rsp+0]
	add rsp, 16
	test bl, bl
	je .L4
	jmp .L3
	.L4:
	sub rsp, 16
	mov rbx, [rbp+16]
	lea rbx, [rbx+0]
	mov [rsp+0], rbx
	lea rbx, [rsp+8]
	mov r8, [rbp+16]
	lea r8, [r8+8]
	mov rdi, [r8]
	mov [rbx], rdi
	call vec2.iadd
	add rsp, 16
	.L1:
	.L2:
	.L0:
	leave
	ret

global Balls.init:function
Balls.init:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	lea rbx, [Balls+0]
	mov [rsp+0], rbx
	xor bl, bl
	mov [rsp+8], bl
	mov rbx, 0x140
	mov [rsp+16], rbx
	call memset
	add rsp, 32
	.L0:
	leave
	ret

global Balls.new:function
Balls.new:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, QWORD [Balls+320]
	mov rcx, 0x10
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L1
	jmp .L0
	.L1:
	.L2:
	lea rbx, [Balls+0]
	mov [rsp+8], rbx
	mov rbx, 0x10
	.L3:
	test rbx, rbx
	je .L5
	mov rdi, [rsp+8]
	mov sil, [rdi+16]
	test sil, sil
	sete cl
	test cl, cl
	je .L6
	jmp .L5
	.L6:
	.L7:
	mov rcx, [rsp+8]
	add rcx, 0x14
	mov [rsp+8], rcx
	.L4:
	dec rbx
	jmp .L3
	.L5:
	mov rbx, [rsp+8]
	lea r8, [rbx+0]
	mov ecx, DWORD [Paddle+0]
	shl ecx, 1
	add ecx, 0x4
	mov [r8+0], ecx
	mov ecx, 0x12
	mov [r8+4], ecx
	lea r8, [rbx+8]
	xor ecx, ecx
	mov [r8+0], ecx
	xor ecx, ecx
	mov [r8+4], ecx
	mov cl, 0x1
	mov [rbx+16], cl
	lea rcx, [Balls+320]
	mov rbx, [rcx]
	inc QWORD [rcx]
	.L0:
	leave
	ret

global Balls.destroy:function
Balls.destroy:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	xor cl, cl
	mov [rbx+16], cl
	lea rcx, [Balls+320]
	dec QWORD [rcx]
	mov rbx, [rcx]
	xor rcx, rcx
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L1
	mov bl, 0x1
	mov [Game+0], bl
	.L1:
	.L2:
	.L0:
	leave
	ret

global Balls.update:function
Balls.update:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	lea rbx, [Balls+0]
	mov [rsp+8], rbx
	mov rbx, 0x10
	.L1:
	test rbx, rbx
	je .L3
	sub rsp, 16
	mov [rsp+8], rbx
	mov rbx, [rsp+24]
	mov [rsp+0], rbx
	call Ball.update
	mov rbx, [rsp+8]
	add rsp, 16
	mov rcx, [rsp+8]
	add rcx, 0x14
	mov [rsp+8], rcx
	.L2:
	dec rbx
	jmp .L1
	.L3:
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
	mov rbx, 0x3c0
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
	mov rbx, 0x90
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
	mov rsi, 0x390
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
	sub rsp, 16
	xor rbx, rbx
	mov [rsp+8], rbx
	.L9:
	mov rbx, [rsp+8]
	mov rcx, 0x8
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L11
	sub rsp, 16
	lea rcx, [Powerups+0]
	mov rsi, [rsp+24]
	add rsi, rsi
	lea rbx, [rcx+rsi*8]
	mov [rsp+8], rbx
	mov rcx, [rsp+8]
	mov rbx, [rcx+0]
	mov rcx, 0x1
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L12
	lea rbx, [Screen+0]
	mov rsi, [rsp+8]
	lea rsi, [rsi+8]
	mov ecx, DWORD [rsi+4]
	shl rcx, 4
	lea rcx, [rcx+rcx*2]
	mov rdi, [rsp+8]
	lea rdi, [rdi+8]
	mov esi, DWORD [rdi+0]
	add rcx, rsi
	mov sil, 0x2b
	mov [rbx+rcx*1], sil
	.L12:
	.L13:
	add rsp, 16
	.L10:
	mov rbx, [rsp+8]
	inc QWORD [rsp+8]
	jmp .L9
	.L11:
	add rsp, 16
	sub rsp, 16
	xor rbx, rbx
	mov [rsp+8], rbx
	.L14:
	mov rbx, [rsp+8]
	mov rcx, 0x10
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L16
	sub rsp, 16
	lea rcx, [Balls+0]
	mov rsi, [rsp+24]
	lea rsi, [rsi+rsi*4]
	lea rbx, [rcx+rsi*4]
	mov [rsp+8], rbx
	mov rcx, [rsp+8]
	mov bl, [rcx+16]
	test bl, bl
	je .L17
	lea rbx, [Screen+0]
	mov rsi, [rsp+8]
	lea rsi, [rsi+0]
	mov ecx, DWORD [rsi+4]
	shl rcx, 4
	lea rcx, [rcx+rcx*2]
	mov rdi, [rsp+8]
	lea rdi, [rdi+0]
	mov esi, DWORD [rdi+0]
	add rcx, rsi
	mov sil, 0x40
	mov [rbx+rcx*1], sil
	.L17:
	.L18:
	add rsp, 16
	.L15:
	mov rbx, [rsp+8]
	inc QWORD [rsp+8]
	jmp .L14
	.L16:
	add rsp, 16
	lea rbx, [Screen+0]
	mov [rsp+24], rbx
	mov rbx, 0x14
	.L19:
	test rbx, rbx
	je .L21
	sub rsp, 32
	mov [rsp+24], rbx
	mov rbx, STR2
	mov [rsp+0], rbx
	mov rbx, 0x30
	mov [rsp+8], rbx
	mov rbx, [rsp+56]
	mov [rsp+16], rbx
	call println
	mov rbx, [rsp+24]
	add rsp, 32
	mov rcx, [rsp+24]
	add rcx, 0x30
	mov [rsp+24], rcx
	.L20:
	dec rbx
	jmp .L19
	.L21:
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
	call Powerups.init
	call Balls.init
	call Balls.new
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
	mov rax, QWORD [Game+16]
	mov rbx, 0x5
	xor rdx, rdx
	idiv rbx
	mov rax, rdx
	xor rbx, rbx
	cmp rax, rbx
	sete bl
	test bl, bl
	je .L3
	call Balls.update
	call Powerups.update
	.L3:
	.L4:
	mov rbx, QWORD [Game+8]
	mov rcx, 0x90
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L5
	call Screen.clear
	call Screen.print
	sub rsp, 32
	mov rbx, STR4
	mov [rsp+0], rbx
	mov rbx, 0x2e
	mov [rsp+8], rbx
	mov rbx, 0x2d
	mov [rsp+16], rbx
	call println
	add rsp, 32
	jmp .L2
	.L5:
	.L6:
	sub rsp, 16
	movsd xmm0, [FP0]
	movsd [rsp+0], xmm0
	call sleep
	add rsp, 16
	lea rcx, [Game+16]
	mov rbx, [rcx]
	inc QWORD [rcx]
	jmp .L1
	.L2:
	call TTY.restore_old
	call TTY.block_stdin
	.L0:
	leave
	ret


extern log:function
extern get_allocated_heap:function
extern nanosleep:function
extern sin:function
extern print_char:function
extern trunc:function
extern print:function
extern set_rounding:function
extern pow:function
extern memmove:function
extern sleep:function
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
extern open:function
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
extern syscall1:function
extern syscall2:function
extern syscall3:function
extern println:function
extern is_whitespace:function
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
global TTY:data
TTY:
dd 56026
dd 0
dd 0
dd 0
times 32 db 0
dd 0
dd 0
dd 56026
dd 0
dd 0
dd 0
times 32 db 0
dd 0
dd 0
global Game:data
Game:
db 0
times 7 db 0
dq 0
dq 0
global Input:data
Input:
dd 0
db 0
times 3 db 0
global Balls:data
Balls:
times 320 db 0
dq 0
global Paddle:data
Paddle:
dd 10
dd 0
global Powerups:data
Powerups:
times 128 db 0
dq 0
global Blocks:data
Blocks:
times 144 db 0
global Screen:data
Screen:
times 960 db 0


section .rodata align=16
__FABS_MASKd: dq 0x7FFFFFFFFFFFFFFF, 0
__FABS_MASKs: dd 0x7FFFFFFF, 0, 0, 0
__FNEG_MASKd: dq 0x8000000000000000, 0
__FNEG_MASKs: dd 0x80000000, 0, 0, 0
STR0:
db "(%i, %i)",0
times 5 db 0
STR1:
db "",0x1b,"[2J",0x1b,"[H",0
times 6 db 0
STR2:
db "%*s",0
dw 0
STR3:
db "%[|| SCORE: %03 %*L%[ q to exit game. ||%*R",0
dw 0
STR4:
db "!%[> YOU WIN <%*C!",0
times 3 db 0
FP0:
dq 0.0250000000
