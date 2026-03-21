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

global init:function
init:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	lea rbx, [board]
	mov [rsp+0], rbx
	mov bl, 0x20
	mov [rsp+8], bl
	mov rbx, 0x9
	mov [rsp+16], rbx
	call memset
	add rsp, 32
	mov bl, 0x20
	mov [player], bl
	.L0:
	leave
	ret

global print_board:function
print_board:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	lea rbx, [board]
	mov [rsp+8], rbx
	xor rbx, rbx
	mov [rsp+0], rbx
	sub rsp, 16
	mov rbx, STR0
	mov [rsp+0], rbx
	call println
	add rsp, 16
	mov bl, 0x3
	.L1:
	test bl, bl
	je .L3
	mov rcx, [rsp+0]
	test rcx, rcx
	je .L4
	sub rsp, 32
	mov [rsp+31], bl
	mov rcx, STR1
	mov [rsp+0], rcx
	mov rcx, 0xa
	mov [rsp+8], rcx
	mov rcx, 0x2d
	mov [rsp+16], rcx
	call println
	mov bl, [rsp+31]
	add rsp, 32
	jmp .L5
	.L4:
	.L5:
	sub rsp, 48
	mov [rsp+47], bl
	mov rcx, STR2
	mov [rsp+0], rcx
	mov rcx, [rsp+48]
	inc rcx
	mov [rsp+48], rcx
	mov [rsp+8], rcx
	mov rcx, [rsp+56]
	movzx rsi, BYTE [rcx]
	mov [rsp+16], rsi
	mov rcx, [rsp+56]
	inc rcx
	mov [rsp+56], rcx
	movzx rsi, BYTE [rcx]
	mov [rsp+24], rsi
	mov rcx, [rsp+56]
	inc rcx
	mov [rsp+56], rcx
	movzx rsi, BYTE [rcx]
	mov [rsp+32], rsi
	call println
	mov bl, [rsp+47]
	add rsp, 48
	mov rcx, [rsp+8]
	inc rcx
	mov [rsp+8], rcx
	.L2:
	dec bl
	jmp .L1
	.L3:
	.L0:
	leave
	ret

global check_win:function
check_win:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	xor rbx, rbx
	mov [rsp+8], rbx
	mov bl, 0x3
	.L1:
	test bl, bl
	je .L3
	lea rcx, [board]
	mov rsi, [rsp+8]
	mov dil, [rcx+rsi*1]
	mov cl, [rbp+17]
	cmp dil, cl
	sete cl
	test cl, cl
	je .L7
	lea rsi, [board]
	mov rdi, [rsp+8]
	mov r8, 0x1
	add rdi, r8
	mov r8b, [rsi+rdi*1]
	mov sil, [rbp+17]
	cmp r8b, sil
	sete cl
	.L7:
	test cl, cl
	je .L6
	lea rsi, [board]
	mov rdi, [rsp+8]
	mov r8, 0x2
	add rdi, r8
	mov r8b, [rsi+rdi*1]
	mov sil, [rbp+17]
	cmp r8b, sil
	sete cl
	.L6:
	test cl, cl
	je .L4
	mov cl, 0x1
	mov [rbp+16], cl
	jmp .L0
	jmp .L5
	.L4:
	.L5:
	mov rcx, [rsp+8]
	mov rsi, 0x3
	add rcx, rsi
	mov [rsp+8], rcx
	.L2:
	dec bl
	jmp .L1
	.L3:
	xor rbx, rbx
	mov [rsp+8], rbx
	mov bl, 0x3
	.L8:
	test bl, bl
	je .L10
	lea rcx, [board]
	mov rsi, [rsp+8]
	mov dil, [rcx+rsi*1]
	mov cl, [rbp+17]
	cmp dil, cl
	sete cl
	test cl, cl
	je .L14
	lea rsi, [board]
	mov rdi, 0x3
	mov r8, [rsp+8]
	add rdi, r8
	mov r8b, [rsi+rdi*1]
	mov sil, [rbp+17]
	cmp r8b, sil
	sete cl
	.L14:
	test cl, cl
	je .L13
	lea rsi, [board]
	mov rdi, 0x6
	mov r8, [rsp+8]
	add rdi, r8
	mov r8b, [rsi+rdi*1]
	mov sil, [rbp+17]
	cmp r8b, sil
	sete cl
	.L13:
	test cl, cl
	je .L11
	mov cl, 0x1
	mov [rbp+16], cl
	jmp .L0
	jmp .L12
	.L11:
	.L12:
	mov rcx, [rsp+8]
	inc rcx
	mov [rsp+8], rcx
	.L9:
	dec bl
	jmp .L8
	.L10:
	lea rbx, [board]
	xor rcx, rcx
	mov sil, [rbx+rcx*1]
	mov bl, [rbp+17]
	cmp sil, bl
	sete bl
	test bl, bl
	je .L18
	lea rcx, [board]
	mov rsi, 0x4
	mov dil, [rcx+rsi*1]
	mov cl, [rbp+17]
	cmp dil, cl
	sete bl
	.L18:
	test bl, bl
	je .L17
	lea rcx, [board]
	mov rsi, 0x8
	mov dil, [rcx+rsi*1]
	mov cl, [rbp+17]
	cmp dil, cl
	sete bl
	.L17:
	test bl, bl
	je .L15
	mov bl, 0x1
	mov [rbp+16], bl
	jmp .L0
	jmp .L16
	.L15:
	.L16:
	lea rbx, [board]
	mov rcx, 0x2
	mov sil, [rbx+rcx*1]
	mov bl, [rbp+17]
	cmp sil, bl
	sete bl
	test bl, bl
	je .L22
	lea rcx, [board]
	mov rsi, 0x4
	mov dil, [rcx+rsi*1]
	mov cl, [rbp+17]
	cmp dil, cl
	sete bl
	.L22:
	test bl, bl
	je .L21
	lea rcx, [board]
	mov rsi, 0x6
	mov dil, [rcx+rsi*1]
	mov cl, [rbp+17]
	cmp dil, cl
	sete bl
	.L21:
	test bl, bl
	je .L19
	mov bl, 0x1
	mov [rbp+16], bl
	jmp .L0
	jmp .L20
	.L19:
	.L20:
	xor bl, bl
	mov [rbp+16], bl
	jmp .L0
	.L0:
	leave
	ret

global check_tie:function
check_tie:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	lea rbx, [board]
	mov [rsp+8], rbx
	mov bl, 0x9
	.L1:
	test bl, bl
	je .L3
	mov rcx, [rsp+8]
	mov sil, [rcx]
	mov cl, 0x20
	cmp sil, cl
	sete cl
	test cl, cl
	je .L4
	xor cl, cl
	mov [rbp+16], cl
	jmp .L0
	jmp .L5
	.L4:
	.L5:
	mov rcx, [rsp+8]
	inc rcx
	mov [rsp+8], rcx
	.L2:
	dec bl
	jmp .L1
	.L3:
	mov bl, 0x1
	mov [rbp+16], bl
	jmp .L0
	.L0:
	leave
	ret

global main:function
main:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	call init
	sub rsp, 16
	mov rbx, STR3
	mov [rsp+0], rbx
	call println
	add rsp, 16
	.L1:
	mov rbx, QWORD [state]
	mov rcx, 0x1
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L3
	mov bl, BYTE [player]
	mov cl, 0x58
	cmp bl, cl
	sete bl
	test bl, bl
	je .L5
	mov bl, 0x4f
	mov [player], bl
	jmp .L6
	.L5:
	mov bl, 0x58
	mov [player], bl
	.L6:
	call print_board
	sub rsp, 16
	mov rbx, STR4
	mov [rsp+0], rbx
	movzx rbx, BYTE [player]
	mov [rsp+8], rbx
	call println
	add rsp, 16
	mov rbx, 0x2
	mov [state], rbx
	jmp .L4
	.L3:
	mov rbx, QWORD [state]
	mov rcx, 0x2
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L7
	sub rsp, 32
	sub rsp, 32
	lea rbx, [rsp+64]
	mov [rsp+8], rbx
	mov rbx, 0x10
	mov [rsp+16], rbx
	call input
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+24], rbx
	lea rbx, [rsp+32]
	mov cl, [rbx]
	mov bl, 0x71
	cmp cl, bl
	sete bl
	test bl, bl
	je .L8
	jmp .L2
	jmp .L9
	.L8:
	.L9:
	mov rbx, [rsp+24]
	mov rcx, 0x2
	cmp rbx, rcx
	setne bl
	test bl, bl
	jne .L13
	sub rsp, 16
	mov [rsp+15], bl
	lea rcx, [rsp+48]
	mov sil, [rcx]
	mov [rsp+1], sil
	call is_num
	mov bl, [rsp+15]
	mov cl, [rsp+0]
	add rsp, 16
	test cl, cl
	sete bl
	.L13:
	test bl, bl
	jne .L12
	sub rsp, 16
	mov [rsp+15], bl
	lea rcx, [rsp+48]
	mov rsi, 0x1
	add rcx, rsi
	mov sil, [rcx]
	mov [rsp+1], sil
	call is_alpha
	mov bl, [rsp+15]
	mov cl, [rsp+0]
	add rsp, 16
	test cl, cl
	sete bl
	.L12:
	test bl, bl
	je .L10
	sub rsp, 16
	mov rbx, STR5
	mov [rsp+0], rbx
	call println
	add rsp, 16
	jmp .L1
	jmp .L11
	.L10:
	.L11:
	lea rcx, [rsp+32]
	movzx rbx, BYTE [rcx]
	mov rcx, 0x31
	sub rbx, rcx
	mov [rsp+16], rbx
	sub rsp, 16
	lea rbx, [rsp+48]
	mov rcx, 0x1
	add rbx, rcx
	mov cl, [rbx]
	mov [rsp+1], cl
	call to_lower
	movzx rbx, BYTE [rsp+0]
	add rsp, 16
	mov rcx, 0x61
	sub rbx, rcx
	mov [rsp+8], rbx
	mov rbx, [rsp+16]
	xor rcx, rcx
	cmp rbx, rcx
	setl bl
	test bl, bl
	jne .L18
	mov rcx, [rsp+16]
	mov rsi, 0x2
	cmp rcx, rsi
	setg bl
	.L18:
	test bl, bl
	jne .L17
	mov rcx, [rsp+8]
	xor rsi, rsi
	cmp rcx, rsi
	setl bl
	.L17:
	test bl, bl
	jne .L16
	mov rcx, [rsp+8]
	mov rsi, 0x2
	cmp rcx, rsi
	setg bl
	.L16:
	test bl, bl
	je .L14
	sub rsp, 32
	mov rbx, STR6
	mov [rsp+0], rbx
	mov rbx, [rsp+48]
	mov [rsp+8], rbx
	mov rbx, [rsp+40]
	mov [rsp+16], rbx
	call println
	add rsp, 32
	jmp .L1
	jmp .L15
	.L14:
	.L15:
	lea rbx, [board]
	mov rax, [rsp+16]
	mov rcx, 0x3
	mul rcx
	mov rcx, [rsp+8]
	add rax, rcx
	mov cl, [rbx+rax*1]
	mov bl, 0x20
	cmp cl, bl
	setne bl
	test bl, bl
	je .L19
	sub rsp, 32
	mov rbx, STR7
	mov [rsp+0], rbx
	mov rbx, [rsp+48]
	mov [rsp+8], rbx
	mov rbx, [rsp+40]
	mov [rsp+16], rbx
	call println
	add rsp, 32
	jmp .L1
	jmp .L20
	.L19:
	.L20:
	lea rbx, [board]
	mov rax, [rsp+16]
	mov rcx, 0x3
	mul rcx
	mov rcx, [rsp+8]
	add rax, rcx
	mov cl, BYTE [player]
	mov [rbx+rax*1], cl
	sub rsp, 16
	mov bl, BYTE [player]
	mov [rsp+1], bl
	call check_win
	mov bl, [rsp+0]
	add rsp, 16
	test bl, bl
	je .L21
	mov rbx, 0x3
	mov [state], rbx
	jmp .L22
	.L21:
	sub rsp, 16
	call check_tie
	mov bl, [rsp+0]
	add rsp, 16
	test bl, bl
	je .L23
	mov rbx, 0x3
	mov [state], rbx
	jmp .L22
	.L23:
	mov rbx, 0x1
	mov [state], rbx
	.L22:
	add rsp, 32
	jmp .L4
	.L7:
	call print_board
	sub rsp, 16
	mov rbx, STR8
	mov [rsp+0], rbx
	call println
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
	sete bl
	test bl, bl
	je .L24
	call init
	mov rbx, 0x1
	mov [state], rbx
	jmp .L25
	.L24:
	jmp .L2
	.L25:
	.L4:
	jmp .L1
	.L2:
	sub rsp, 16
	mov rbx, STR9
	mov [rsp+0], rbx
	call println
	add rsp, 16
	xor rbx, rbx
	mov [rbp+16], rbx
	jmp .L0
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
global board:data
board:
times 9 db 0
global player:data
player:
db 32
global state:data
state:
dq 1


section .rodata
STR0:
db "  A   B   C",0
STR1:
db "  %*c",0
STR2:
db "%u %c | %c | %c",0
STR3:
db "Controls:",10,"Enter 'q' to leave.",10,"Enter the row number + column letter to choose a square to fill.",10,"",0
STR4:
db "TURN: %c",0
STR5:
db "Invalid input! Enter the row number + column letter.",10,"EX: 2C",0
STR6:
db "(%i, %i) is not a valid coordinate!",0
STR7:
db "(%i, %i) is full!",0
STR8:
db "",10,"<< GAME OVER! >>",10,"- Play again? (y/n) -",0
STR9:
db "Thank you for playing! :)",0
