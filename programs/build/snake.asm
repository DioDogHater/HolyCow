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
	mov rbx, QWORD [stdin]
	mov [rsp+8], rbx
	lea rbx, [rsp+48]
	mov [rsp+16], rbx
	mov rbx, 0x10
	mov [rsp+24], rbx
	call File.read
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+8], rbx
	xor bl, bl
	mov [rbp+16], bl
	mov rbx, [rsp+8]
	xor rcx, rcx
	cmp rbx, rcx
	setle bl
	test bl, bl
	je .L1
	jmp .L0
	jmp .L2
	.L1:
	.L2:
	lea rbx, [rsp+16]
	mov rcx, [rsp+8]
	mov rsi, 0x1
	sub rcx, rsi
	mov sil, [rbx+rcx*1]
	mov [rsp+7], sil
	mov bl, [rsp+7]
	mov cl, 0x77
	cmp bl, cl
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
	mov bl, [rsp+7]
	mov cl, 0x73
	cmp bl, cl
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
	mov bl, [rsp+7]
	mov cl, 0x61
	cmp bl, cl
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
	mov bl, [rsp+7]
	mov cl, 0x64
	cmp bl, cl
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
	mov bl, [rsp+7]
	mov cl, 0x71
	cmp bl, cl
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
	movsxd rbx, DWORD [last_direction+0]
	xor rcx, rcx
	cmp rbx, rcx
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
	movsxd rbx, DWORD [last_direction+0]
	xor rcx, rcx
	cmp rbx, rcx
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
	movsxd rbx, DWORD [last_direction+4]
	xor rcx, rcx
	cmp rbx, rcx
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
	sub rsp, 16
	mov rbx, STR0
	mov [rsp+0], rbx
	call print
	add rsp, 16
	sub rsp, 32
	mov rbx, STR1
	mov [rsp+0], rbx
	mov rbx, 0x20
	mov [rsp+8], rbx
	mov rbx, 0x3d
	mov [rsp+16], rbx
	call println
	add rsp, 32
	mov rbx, 0x10
	.L10:
	test rbx, rbx
	je .L12
	sub rsp, 32
	mov [rsp+24], rbx
	mov rcx, STR2
	mov [rsp+0], rcx
	mov rcx, 0x20
	mov [rsp+8], rcx
	mov rcx, [rsp+40]
	mov [rsp+16], rcx
	call println
	mov rbx, [rsp+24]
	add rsp, 32
	mov rcx, [rsp+8]
	mov rsi, 0x20
	add rcx, rsi
	mov [rsp+8], rcx
	.L11:
	dec rbx
	jmp .L10
	.L12:
	sub rsp, 32
	mov rbx, STR1
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
	fld QWORD [FP0]
	fsubp
	fstp DWORD [rsp+8]
	xor bl, bl
	mov [rsp+7], bl
	sub rsp, 16
	.L1:
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
	movsxd rbx, DWORD [rcx+0]
	xor rcx, rcx
	cmp rbx, rcx
	setl bl
	test bl, bl
	jne .L9
	lea rsi, [snake]
	movsxd rcx, DWORD [rsi+0]
	mov rsi, 0x20
	cmp rcx, rsi
	setge bl
	.L9:
	test bl, bl
	jne .L8
	lea rsi, [snake]
	movsxd rcx, DWORD [rsi+4]
	xor rsi, rsi
	cmp rcx, rsi
	setl bl
	.L8:
	test bl, bl
	jne .L7
	lea rsi, [snake]
	movsxd rcx, DWORD [rsi+4]
	mov rsi, 0x10
	cmp rcx, rsi
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
	mov r8, rcx
	mov r9, rsi
	mov rdi, [rcx+rsi*8]
	mov [rbx], rdi
	sub rsp, 16
	mov [rsp+8], r8
	mov [rsp+0], r9
	call generate_food
	mov r8, [rsp+8]
	mov r9, [rsp+0]
	add rsp, 16
	jmp .L17
	.L16:
	.L17:
	sub rsp, 32
	mov [rsp+24], r8
	mov [rsp+16], r9
	fld QWORD [FP1]
	fstp QWORD [rsp+0]
	call sleep
	mov r8, [rsp+24]
	mov r9, [rsp+16]
	add rsp, 32
	mov bl, [rsp+23]
	test bl, bl
	je .L19
	sub rsp, 32
	mov [rsp+24], r8
	mov [rsp+16], r9
	mov rbx, STR4
	mov [rsp+0], rbx
	call print
	mov r8, [rsp+24]
	mov r9, [rsp+16]
	add rsp, 32
	sub rsp, 32
	mov [rsp+24], r8
	mov [rsp+16], r9
	mov rbx, QWORD [stdout]
	mov [rsp+0], rbx
	call File.flush
	mov r8, [rsp+24]
	mov r9, [rsp+16]
	add rsp, 32
	sub rsp, 48
	mov [rsp+40], r8
	mov [rsp+32], r9
	mov rbx, QWORD [stdin]
	mov [rsp+8], rbx
	xor rbx, rbx
	mov [rsp+16], rbx
	mov rbx, 0x40
	mov [rsp+24], rbx
	call File.read
	mov r8, [rsp+40]
	mov r9, [rsp+32]
	add rsp, 48
	sub rsp, 16
	mov [rsp+8], r8
	mov [rsp+0], r9
	call block_stdin
	mov r8, [rsp+8]
	mov r9, [rsp+0]
	add rsp, 16
	sub rsp, 48
	mov [rsp+40], r8
	mov [rsp+32], r9
	xor rbx, rbx
	mov [rsp+8], rbx
	xor rbx, rbx
	mov [rsp+16], rbx
	lea rbx, [rsp+136]
	mov [rsp+24], rbx
	call tcsetattr
	mov r8, [rsp+40]
	mov r9, [rsp+32]
	add rsp, 48
	sub rsp, 32
	mov [rsp+24], r8
	mov [rsp+16], r9
	fld QWORD [FP2]
	fstp QWORD [rsp+0]
	call sleep
	mov r8, [rsp+24]
	mov r9, [rsp+16]
	add rsp, 32
	sub rsp, 32
	mov [rsp+24], r8
	mov [rsp+16], r9
	sub rsp, 32
	mov [rsp+24], r8
	mov [rsp+16], r9
	call input_char
	mov r8, [rsp+24]
	mov r9, [rsp+16]
	mov bl, [rsp+0]
	add rsp, 32
	mov [rsp+1], bl
	call to_lower
	mov r8, [rsp+24]
	mov r9, [rsp+16]
	mov bl, [rsp+0]
	add rsp, 32
	mov cl, 0x79
	cmp bl, cl
	setne bl
	test bl, bl
	je .L21
	jmp .L0
	jmp .L22
	.L21:
	.L22:
	sub rsp, 16
	mov [rsp+8], r8
	mov [rsp+0], r9
	call init_game
	mov r8, [rsp+8]
	mov r9, [rsp+0]
	add rsp, 16
	xor bl, bl
	mov [rsp+23], bl
	sub rsp, 16
	mov [rsp+8], r8
	mov [rsp+0], r9
	call nonblock_stdin
	mov r8, [rsp+8]
	mov r9, [rsp+0]
	add rsp, 16
	sub rsp, 48
	mov [rsp+40], r8
	mov [rsp+32], r9
	xor rbx, rbx
	mov [rsp+8], rbx
	xor rbx, rbx
	mov [rsp+16], rbx
	lea rbx, [rsp+80]
	mov [rsp+24], rbx
	call tcsetattr
	mov r8, [rsp+40]
	mov r9, [rsp+32]
	add rsp, 48
	jmp .L20
	.L19:
	.L20:
	jmp .L1
	.L2:
	add rsp, 16
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
extern File.set_buffering:function
extern File.set_buffer:function
extern File.flush:function
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
extern string.new:function


section .data
static __FP_TMP:data
__FP_TMP:
dq 0
static __GP_TMP:data
__GP_TMP:
times 64 db 0
extern stdout:data
extern stdin:data
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
extern File:data
extern fixed:data
extern string:data


section .rodata
STR0:
db "",0x1b,"[2J",0x1b,"[H",0
STR1:
db "+%*c+",0
STR2:
db "|%*s|",0
STR3:
db "SCORE: %04%APress q to quit.",0
STR4:
db "> GAME OVER <",10,"Play again? (y/n) ",0
FP0:
dq 0.1
FP1:
dq 0.075
FP2:
dq 0.25
