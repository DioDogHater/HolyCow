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
	or rbx, 0x800
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
	and rbx, 0xfffffffffffff7ff
	mov [rsp+24], rbx
	call fcntl
	add rsp, 32
	.L0:
	leave
	ret

global food.generate:function
food.generate:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	lea rbx, [food+0]
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
	lea rbx, [snake+16]
	mov [rsp+8], rbx
	sub rsp, 16
	xor rbx, rbx
	mov [rsp+8], rbx
	.L1:
	mov rbx, [rsp+8]
	mov rcx, QWORD [snake+8]
	cmp rbx, rcx
	setb bl
	test bl, bl
	je .L3
	lea rcx, [food+0]
	mov ebx, [rcx+0]
	mov rsi, [rsp+24]
	mov ecx, [rsi+0]
	cmp ebx, ecx
	sete bl
	test bl, bl
	je .L6
	lea rsi, [food+0]
	mov ecx, [rsi+4]
	mov rdi, [rsp+24]
	mov esi, [rdi+4]
	cmp ecx, esi
	sete bl
	.L6:
	test bl, bl
	je .L4
	lea rbx, [food+0]
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
	lea rbx, [snake+16]
	mov [rsp+24], rbx
	xor rbx, rbx
	mov [rsp+8], rbx
	jmp .L2
	.L4:
	.L5:
	mov rbx, [rsp+24]
	add rbx, 0x8
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

global snake.init:function
snake.init:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	lea rbx, [snake+16]
	mov [rsp+0], rbx
	xor bl, bl
	mov [rsp+8], bl
	mov rbx, 0x1000
	mov [rsp+16], rbx
	call memset
	add rsp, 32
	lea rbx, [snake+16]
	mov ecx, 0x10
	mov [rbx+0], ecx
	mov ecx, 0x8
	mov [rbx+4], ecx
	mov rbx, 0x1
	mov [snake+8], rbx
	lea rbx, [snake+0]
	xor ecx, ecx
	mov [rbx+0], ecx
	xor ecx, ecx
	mov [rbx+4], ecx
	.L0:
	leave
	ret

global snake.get_direction:function
snake.get_direction:
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
	.L1:
	.L2:
	lea rbx, [rsp+16]
	mov rcx, [rsp+8]
	dec rcx
	mov sil, [rbx+rcx*1]
	mov [rsp+7], sil
	mov bl, [rsp+7]
	mov cl, 0x77
	cmp bl, cl
	sete bl
	test bl, bl
	je .L5
	lea rsi, [snake+0]
	mov ecx, [rsi+4]
	test ecx, ecx
	sete bl
	.L5:
	test bl, bl
	je .L3
	lea rbx, [snake+0]
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
	lea rsi, [snake+0]
	mov ecx, [rsi+4]
	test ecx, ecx
	sete bl
	.L7:
	test bl, bl
	je .L6
	lea rbx, [snake+0]
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
	lea rsi, [snake+0]
	mov ecx, [rsi+0]
	test ecx, ecx
	sete bl
	.L9:
	test bl, bl
	je .L8
	lea rbx, [snake+0]
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
	lea rsi, [snake+0]
	mov ecx, [rsi+0]
	test ecx, ecx
	sete bl
	.L11:
	test bl, bl
	je .L10
	lea rbx, [snake+0]
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

global snake.move_body:function
snake.move_body:
	push rbp
	mov rbp, rsp
	mov rbx, QWORD [snake+8]
	mov rcx, 0x1
	cmp rbx, rcx
	setg bl
	test bl, bl
	je .L1
	sub rsp, 32
	lea rbx, [snake+16]
	add rbx, 0x8
	mov [rsp+0], rbx
	lea rbx, [snake+16]
	mov [rsp+8], rbx
	mov rbx, QWORD [snake+8]
	dec rbx
	shl rbx, 3
	mov [rsp+16], rbx
	call memmove
	add rsp, 32
	.L1:
	.L2:
	lea rbx, [snake+16]
	lea rsi, [snake+16]
	mov ecx, [rsi+0]
	lea rdi, [snake+0]
	mov esi, [rdi+0]
	add ecx, esi
	mov [rbx+0], ecx
	lea rbx, [snake+16]
	lea rsi, [snake+16]
	mov ecx, [rsi+4]
	lea rdi, [snake+0]
	mov esi, [rdi+4]
	add ecx, esi
	mov [rbx+4], ecx
	.L0:
	leave
	ret

global snake.check_collisions:function
snake.check_collisions:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	lea rcx, [snake+16]
	movsxd rbx, DWORD [rcx+0]
	xor rcx, rcx
	cmp rbx, rcx
	setl bl
	test bl, bl
	jne .L5
	lea rsi, [snake+16]
	movsxd rcx, DWORD [rsi+0]
	mov rsi, 0x20
	cmp rcx, rsi
	setge bl
	.L5:
	test bl, bl
	jne .L4
	lea rsi, [snake+16]
	movsxd rcx, DWORD [rsi+4]
	xor rsi, rsi
	cmp rcx, rsi
	setl bl
	.L4:
	test bl, bl
	jne .L3
	lea rsi, [snake+16]
	movsxd rcx, DWORD [rsi+4]
	mov rsi, 0x10
	cmp rcx, rsi
	setge bl
	.L3:
	test bl, bl
	je .L1
	mov bl, 0x1
	mov [rbp+16], bl
	jmp .L0
	.L1:
	.L2:
	lea rbx, [snake+16]
	add rbx, 0x8
	mov [rsp+8], rbx
	mov rbx, QWORD [snake+8]
	dec rbx
	.L6:
	test rbx, rbx
	je .L8
	lea rsi, [snake+16]
	mov ecx, [rsi+0]
	mov rdi, [rsp+8]
	mov esi, [rdi+0]
	cmp ecx, esi
	sete cl
	test cl, cl
	je .L11
	lea rdi, [snake+16]
	mov esi, [rdi+4]
	mov r8, [rsp+8]
	mov edi, [r8+4]
	cmp esi, edi
	sete cl
	.L11:
	test cl, cl
	je .L9
	mov cl, 0x1
	mov [rbp+16], cl
	jmp .L0
	.L9:
	.L10:
	mov rcx, [rsp+8]
	add rcx, 0x8
	mov [rsp+8], rcx
	.L7:
	dec rbx
	jmp .L6
	.L8:
	xor bl, bl
	mov [rbp+16], bl
	.L0:
	leave
	ret

global snake.eat_food:function
snake.eat_food:
	push rbp
	mov rbp, rsp
	lea rcx, [snake+16]
	mov ebx, [rcx+0]
	lea rsi, [food+0]
	mov ecx, [rsi+0]
	cmp ebx, ecx
	sete bl
	test bl, bl
	je .L3
	lea rsi, [snake+16]
	mov ecx, [rsi+4]
	lea rdi, [food+0]
	mov esi, [rdi+4]
	cmp ecx, esi
	sete bl
	.L3:
	test bl, bl
	je .L1
	lea rbx, [snake+16]
	mov rcx, QWORD [snake+8]
	inc rcx
	mov [snake+8], rcx
	dec rcx
	lea rbx, [rbx+rcx*8]
	lea rcx, [snake+16]
	mov rsi, QWORD [snake+8]
	sub rsi, 0x2
	mov rdi, [rcx+rsi*8]
	mov [rbx], rdi
	call food.generate
	.L1:
	.L2:
	.L0:
	leave
	ret

global init_game:function
init_game:
	push rbp
	mov rbp, rsp
	call snake.init
	call food.generate
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
	lea rbx, [snake+16]
	mov [rsp+24], rbx
	lea rcx, [snake+0]
	movsxd rbx, DWORD [rcx+0]
	xor rcx, rcx
	cmp rbx, rcx
	setg bl
	test bl, bl
	je .L1
	lea rbx, [rsp+32]
	mov rsi, [rsp+24]
	mov ecx, DWORD [rsi+0]
	mov rdi, [rsp+24]
	mov esi, DWORD [rdi+4]
	shl rsi, 5
	add rcx, rsi
	mov sil, 0x3e
	mov [rbx+rcx*1], sil
	jmp .L2
	.L1:
	lea rcx, [snake+0]
	movsxd rbx, DWORD [rcx+0]
	xor rcx, rcx
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L3
	lea rbx, [rsp+32]
	mov rsi, [rsp+24]
	mov ecx, DWORD [rsi+0]
	mov rdi, [rsp+24]
	mov esi, DWORD [rdi+4]
	shl rsi, 5
	add rcx, rsi
	mov sil, 0x3c
	mov [rbx+rcx*1], sil
	jmp .L2
	.L3:
	lea rcx, [snake+0]
	movsxd rbx, DWORD [rcx+4]
	xor rcx, rcx
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L4
	lea rbx, [rsp+32]
	mov rsi, [rsp+24]
	mov ecx, DWORD [rsi+0]
	mov rdi, [rsp+24]
	mov esi, DWORD [rdi+4]
	shl rsi, 5
	add rcx, rsi
	mov sil, 0x5e
	mov [rbx+rcx*1], sil
	jmp .L2
	.L4:
	lea rbx, [rsp+32]
	mov rsi, [rsp+24]
	mov ecx, DWORD [rsi+0]
	mov rdi, [rsp+24]
	mov esi, DWORD [rdi+4]
	shl rsi, 5
	add rcx, rsi
	mov sil, 0x76
	mov [rbx+rcx*1], sil
	.L2:
	mov rbx, [rsp+24]
	add rbx, 0x8
	mov [rsp+24], rbx
	lea rbx, [snake+16]
	mov [rsp+16], rbx
	mov rbx, QWORD [snake+8]
	dec rbx
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
	mov r8, [rsp+24]
	mov edi, DWORD [r8+4]
	shl rdi, 5
	add rsi, rdi
	mov dil, 0x2d
	mov [rcx+rsi*1], dil
	jmp .L9
	.L8:
	lea rcx, [rsp+32]
	mov rdi, [rsp+24]
	mov esi, DWORD [rdi+0]
	mov r8, [rsp+24]
	mov edi, DWORD [r8+4]
	shl rdi, 5
	add rsi, rdi
	mov dil, 0x7c
	mov [rcx+rsi*1], dil
	.L9:
	mov rcx, [rsp+24]
	mov [rsp+16], rcx
	mov rcx, [rsp+24]
	add rcx, 0x8
	mov [rsp+24], rcx
	.L6:
	dec rbx
	jmp .L5
	.L7:
	lea rbx, [rsp+32]
	lea rsi, [food+0]
	mov ecx, DWORD [rsi+0]
	lea rdi, [food+0]
	mov esi, DWORD [rdi+4]
	shl rsi, 5
	add rcx, rsi
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
	add rcx, 0x20
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
	and ebx, 0xfffffff5
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
	xor bl, bl
	mov [rsp+15], bl
	.L1:
	call draw_game
	sub rsp, 32
	mov rbx, STR3
	mov [rsp+0], rbx
	mov rbx, QWORD [snake+8]
	mov [rsp+8], rbx
	mov rbx, 0x10
	mov [rsp+16], rbx
	call println
	add rsp, 32
	sub rsp, 16
	call snake.get_direction
	mov bl, [rsp+0]
	add rsp, 16
	mov [rsp+15], bl
	call snake.move_body
	sub rsp, 16
	call snake.check_collisions
	mov bl, [rsp+0]
	add rsp, 16
	test bl, bl
	je .L3
	mov bl, 0x1
	mov [rsp+15], bl
	.L3:
	.L4:
	call snake.eat_food
	mov rbx, QWORD [snake+8]
	mov rcx, 0x200
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L5
	mov bl, 0x1
	mov [rsp+15], bl
	.L5:
	.L6:
	sub rsp, 16
	fld QWORD [FP0]
	fld QWORD [FP1]
	mov rbx, QWORD [snake+8]
	mov [__FP_TMP], rbx
	fild QWORD [__FP_TMP]
	fmulp
	fsubp
	fstp QWORD [rsp+0]
	call sleep
	add rsp, 16
	mov bl, [rsp+15]
	test bl, bl
	je .L7
	sub rsp, 16
	mov rbx, STR4
	mov [rsp+0], rbx
	call print
	add rsp, 16
	sub rsp, 16
	mov rbx, QWORD [stdout]
	mov [rsp+0], rbx
	call File.flush
	add rsp, 16
	sub rsp, 32
	mov rbx, QWORD [stdin]
	mov [rsp+8], rbx
	xor rbx, rbx
	mov [rsp+16], rbx
	mov rbx, 0x40
	mov [rsp+24], rbx
	call File.read
	add rsp, 32
	call block_stdin
	sub rsp, 32
	xor rbx, rbx
	mov [rsp+8], rbx
	xor rbx, rbx
	mov [rsp+16], rbx
	lea rbx, [rsp+104]
	mov [rsp+24], rbx
	call tcsetattr
	add rsp, 32
	sub rsp, 16
	fld QWORD [FP2]
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
	je .L9
	jmp .L0
	.L9:
	.L10:
	call init_game
	xor bl, bl
	mov [rsp+15], bl
	call nonblock_stdin
	sub rsp, 32
	xor rbx, rbx
	mov [rsp+8], rbx
	xor rbx, rbx
	mov [rsp+16], rbx
	lea rbx, [rsp+48]
	mov [rsp+24], rbx
	call tcsetattr
	add rsp, 32
	.L7:
	.L8:
	jmp .L1
	.L2:
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
global snake:data
snake:
times 8 db 0
times 8 db 0
times 4096 db 0
global food:data
food:
times 8 db 0


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
dq 0.125
FP1:
dq 0.0025
FP2:
dq 0.25
