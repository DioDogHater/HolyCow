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

global Board.reset:function
Board.reset:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov rcx, [rbp+16]
	lea rbx, [rcx+0]
	mov [rsp+0], rbx
	mov bl, 0x20
	mov [rsp+8], bl
	mov rbx, 0x9
	mov [rsp+16], rbx
	call memset
	add rsp, 32
	mov rbx, [rbp+16]
	mov cl, 0x20
	mov [rbx+9], cl
	.L0:
	leave
	ret

global Board.change_turn:function
Board.change_turn:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	mov rdi, [rbp+16]
	mov sil, [rdi+9]
	mov dil, 0x58
	cmp sil, dil
	sete sil
	test sil, sil
	je .L1
	mov cl, 0x4f
	jmp .L2
	.L1:
	mov cl, 0x58
	.L2:
	mov [rbx+9], cl
	sub rsp, 32
	mov [rsp+31], sil
	mov rbx, STR0
	mov [rsp+0], rbx
	mov rcx, [rbp+16]
	movzx rbx, BYTE [rcx+9]
	mov [rsp+8], rbx
	call println
	mov sil, [rsp+31]
	add rsp, 32
	.L0:
	leave
	ret

global Board.get:function
Board.get:
	push rbp
	mov rbp, rsp
	mov rcx, [rbp+24]
	lea rbx, [rcx+0]
	mov rax, [rbp+32]
	mov rcx, 0x3
	mul rcx
	mov rcx, [rbp+40]
	add rax, rcx
	mov cl, [rbx+rax*1]
	mov [rbp+16], cl
	.L0:
	leave
	ret

global Board.place:function
Board.place:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+32]
	xor rcx, rcx
	cmp rbx, rcx
	setl bl
	test bl, bl
	jne .L5
	mov rcx, [rbp+32]
	mov rdi, 0x2
	cmp rcx, rdi
	setg bl
	.L5:
	test bl, bl
	jne .L4
	mov rcx, [rbp+40]
	xor rdi, rdi
	cmp rcx, rdi
	setl bl
	.L4:
	test bl, bl
	jne .L3
	mov rcx, [rbp+40]
	mov rdi, 0x2
	cmp rcx, rdi
	setg bl
	.L3:
	test bl, bl
	je .L1
	sub rsp, 32
	mov [rsp+31], sil
	mov rbx, STR1
	mov [rsp+0], rbx
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	mov rbx, [rbp+40]
	mov [rsp+16], rbx
	call println
	mov sil, [rsp+31]
	add rsp, 32
	xor bl, bl
	mov [rbp+16], bl
	jmp .L0
	jmp .L2
	.L1:
	.L2:
	sub rsp, 48
	mov [rsp+47], sil
	mov rbx, [rbp+24]
	mov [rsp+8], rbx
	mov rbx, [rbp+32]
	mov [rsp+16], rbx
	mov rbx, [rbp+40]
	mov [rsp+24], rbx
	call Board.get
	mov sil, [rsp+47]
	mov bl, [rsp+0]
	add rsp, 48
	mov cl, 0x20
	cmp bl, cl
	setne bl
	test bl, bl
	je .L6
	sub rsp, 32
	mov [rsp+31], sil
	mov rbx, STR2
	mov [rsp+0], rbx
	mov rbx, STR3
	mov rcx, [rbp+32]
	movzx rdi, BYTE [rbx+rcx*1]
	mov [rsp+8], rdi
	mov rbx, STR4
	mov rcx, [rbp+40]
	movzx rdi, BYTE [rbx+rcx*1]
	mov [rsp+16], rdi
	call println
	mov sil, [rsp+31]
	add rsp, 32
	xor bl, bl
	mov [rbp+16], bl
	jmp .L0
	jmp .L7
	.L6:
	.L7:
	mov rcx, [rbp+24]
	lea rbx, [rcx+0]
	mov rax, [rbp+32]
	mov rcx, 0x3
	mul rcx
	mov rcx, [rbp+40]
	add rax, rcx
	mov rdi, [rbp+24]
	mov cl, [rdi+9]
	mov [rbx+rax*1], cl
	mov bl, 0x1
	mov [rbp+16], bl
	jmp .L0
	.L0:
	leave
	ret

global Board.print_board:function
Board.print_board:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov [rsp+15], sil
	mov rbx, STR5
	mov [rsp+0], rbx
	call println
	mov sil, [rsp+15]
	add rsp, 16
	sub rsp, 16
	xor rbx, rbx
	mov [rsp+8], rbx
	.L1:
	mov rbx, [rsp+8]
	mov rcx, 0x3
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L3
	mov rbx, [rsp+8]
	xor rcx, rcx
	cmp rbx, rcx
	setg bl
	test bl, bl
	je .L4
	sub rsp, 32
	mov [rsp+31], sil
	mov rbx, STR6
	mov [rsp+0], rbx
	mov rbx, 0xa
	mov [rsp+8], rbx
	mov rbx, 0x2d
	mov [rsp+16], rbx
	call println
	mov sil, [rsp+31]
	add rsp, 32
	jmp .L5
	.L4:
	.L5:
	sub rsp, 48
	mov [rsp+47], sil
	mov rbx, STR7
	mov [rsp+0], rbx
	mov rbx, [rsp+56]
	mov rcx, 0x1
	add rbx, rcx
	mov [rsp+8], rbx
	mov rcx, [rbp+16]
	lea rbx, [rcx+0]
	mov rax, [rsp+56]
	mov rcx, 0x3
	mul rcx
	movzx rcx, BYTE [rbx+rax*1]
	mov [rsp+16], rcx
	mov rcx, [rbp+16]
	lea rbx, [rcx+0]
	mov rax, [rsp+56]
	mov rcx, 0x3
	mul rcx
	mov rcx, 0x1
	add rax, rcx
	movzx rcx, BYTE [rbx+rax*1]
	mov [rsp+24], rcx
	mov rcx, [rbp+16]
	lea rbx, [rcx+0]
	mov rax, [rsp+56]
	mov rcx, 0x3
	mul rcx
	mov rcx, 0x2
	add rax, rcx
	movzx rcx, BYTE [rbx+rax*1]
	mov [rsp+32], rcx
	call println
	mov sil, [rsp+47]
	add rsp, 48
	.L2:
	mov rbx, [rsp+8]
	inc rbx
	mov [rsp+8], rbx
	dec rbx
	jmp .L1
	.L3:
	add rsp, 16
	.L0:
	leave
	ret

global Board.check_win:function
Board.check_win:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	xor rbx, rbx
	mov [rsp+8], rbx
	mov rbx, 0x3
	.L1:
	test rbx, rbx
	je .L3
	mov rdi, [rbp+24]
	lea rcx, [rdi+0]
	mov rdi, [rsp+8]
	mov r8b, [rcx+rdi*1]
	mov cl, [rbp+32]
	cmp r8b, cl
	sete cl
	test cl, cl
	je .L7
	mov r8, [rbp+24]
	lea rdi, [r8+0]
	mov r8, [rsp+8]
	mov r9, 0x1
	add r8, r9
	mov r9b, [rdi+r8*1]
	mov dil, [rbp+32]
	cmp r9b, dil
	sete cl
	.L7:
	test cl, cl
	je .L6
	mov r8, [rbp+24]
	lea rdi, [r8+0]
	mov r8, [rsp+8]
	mov r9, 0x2
	add r8, r9
	mov r9b, [rdi+r8*1]
	mov dil, [rbp+32]
	cmp r9b, dil
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
	mov rdi, 0x3
	add rcx, rdi
	mov [rsp+8], rcx
	.L2:
	dec rbx
	jmp .L1
	.L3:
	xor rbx, rbx
	mov [rsp+8], rbx
	mov rbx, 0x3
	.L8:
	test rbx, rbx
	je .L10
	mov rdi, [rbp+24]
	lea rcx, [rdi+0]
	mov rdi, [rsp+8]
	mov r8b, [rcx+rdi*1]
	mov cl, [rbp+32]
	cmp r8b, cl
	sete cl
	test cl, cl
	je .L14
	mov r8, [rbp+24]
	lea rdi, [r8+0]
	mov r8, 0x3
	mov r9, [rsp+8]
	add r8, r9
	mov r9b, [rdi+r8*1]
	mov dil, [rbp+32]
	cmp r9b, dil
	sete cl
	.L14:
	test cl, cl
	je .L13
	mov r8, [rbp+24]
	lea rdi, [r8+0]
	mov r8, 0x6
	mov r9, [rsp+8]
	add r8, r9
	mov r9b, [rdi+r8*1]
	mov dil, [rbp+32]
	cmp r9b, dil
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
	dec rbx
	jmp .L8
	.L10:
	mov rcx, [rbp+24]
	lea rbx, [rcx+0]
	xor rcx, rcx
	mov dil, [rbx+rcx*1]
	mov bl, [rbp+32]
	cmp dil, bl
	sete bl
	test bl, bl
	je .L18
	mov rdi, [rbp+24]
	lea rcx, [rdi+0]
	mov rdi, 0x4
	mov r8b, [rcx+rdi*1]
	mov cl, [rbp+32]
	cmp r8b, cl
	sete bl
	.L18:
	test bl, bl
	je .L17
	mov rdi, [rbp+24]
	lea rcx, [rdi+0]
	mov rdi, 0x8
	mov r8b, [rcx+rdi*1]
	mov cl, [rbp+32]
	cmp r8b, cl
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
	mov rcx, [rbp+24]
	lea rbx, [rcx+0]
	mov rcx, 0x2
	mov dil, [rbx+rcx*1]
	mov bl, [rbp+32]
	cmp dil, bl
	sete bl
	test bl, bl
	je .L22
	mov rdi, [rbp+24]
	lea rcx, [rdi+0]
	mov rdi, 0x4
	mov r8b, [rcx+rdi*1]
	mov cl, [rbp+32]
	cmp r8b, cl
	sete bl
	.L22:
	test bl, bl
	je .L21
	mov rdi, [rbp+24]
	lea rcx, [rdi+0]
	mov rdi, 0x6
	mov r8b, [rcx+rdi*1]
	mov cl, [rbp+32]
	cmp r8b, cl
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

global Board.check_tie:function
Board.check_tie:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rcx, [rbp+24]
	lea rbx, [rcx+0]
	mov [rsp+8], rbx
	mov rbx, 0x9
	.L1:
	test rbx, rbx
	je .L3
	mov rcx, [rsp+8]
	mov dil, [rcx]
	mov cl, 0x20
	cmp dil, cl
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
	dec rbx
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
	mov [rsp+15], sil
	lea rbx, [game]
	mov [rsp+0], rbx
	call Board.reset
	mov sil, [rsp+15]
	add rsp, 16
	sub rsp, 16
	mov [rsp+15], sil
	mov rbx, STR8
	mov [rsp+0], rbx
	call println
	mov sil, [rsp+15]
	add rsp, 16
	.L1:
	sub rsp, 16
	mov [rsp+15], sil
	lea rbx, [game]
	mov [rsp+0], rbx
	call Board.print_board
	mov sil, [rsp+15]
	add rsp, 16
	sub rsp, 16
	mov [rsp+15], sil
	lea rbx, [game]
	mov [rsp+0], rbx
	call Board.change_turn
	mov sil, [rsp+15]
	add rsp, 16
	sub rsp, 48
	.L3:
	sub rsp, 32
	mov [rsp+31], sil
	lea rbx, [rsp+64]
	mov [rsp+8], rbx
	mov rbx, 0x10
	mov [rsp+16], rbx
	call input
	mov sil, [rsp+31]
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rsp+24], rbx
	lea rbx, [rsp+32]
	mov cl, [rbx]
	mov bl, 0x71
	cmp cl, bl
	sete bl
	test bl, bl
	je .L5
	jmp .L0
	jmp .L6
	.L5:
	.L6:
	mov rbx, [rsp+24]
	mov rcx, 0x2
	cmp rbx, rcx
	setne bl
	test bl, bl
	jne .L10
	sub rsp, 16
	mov [rsp+15], bl
	mov [rsp+14], sil
	lea rcx, [rsp+48]
	xor rdi, rdi
	mov r8b, [rcx+rdi*1]
	mov [rsp+1], r8b
	call is_num
	mov bl, [rsp+15]
	mov sil, [rsp+14]
	mov cl, [rsp+0]
	add rsp, 16
	test cl, cl
	sete bl
	.L10:
	test bl, bl
	jne .L9
	sub rsp, 16
	mov [rsp+15], bl
	mov [rsp+14], sil
	lea rcx, [rsp+48]
	mov rdi, 0x1
	mov r8b, [rcx+rdi*1]
	mov [rsp+1], r8b
	call is_alpha
	mov bl, [rsp+15]
	mov sil, [rsp+14]
	mov cl, [rsp+0]
	add rsp, 16
	test cl, cl
	sete bl
	.L9:
	test bl, bl
	je .L7
	sub rsp, 16
	mov [rsp+15], sil
	mov rbx, STR9
	mov [rsp+0], rbx
	call println
	mov sil, [rsp+15]
	add rsp, 16
	jmp .L3
	jmp .L8
	.L7:
	.L8:
	lea rcx, [rsp+32]
	movzx rbx, BYTE [rcx]
	mov rcx, 0x31
	sub rbx, rcx
	mov [rsp+16], rbx
	sub rsp, 16
	mov [rsp+15], sil
	lea rbx, [rsp+48]
	mov rcx, 0x1
	mov dil, [rbx+rcx*1]
	mov [rsp+1], dil
	call to_upper
	mov sil, [rsp+15]
	movzx rbx, BYTE [rsp+0]
	add rsp, 16
	mov rcx, 0x41
	sub rbx, rcx
	mov [rsp+8], rbx
	sub rsp, 48
	mov [rsp+47], sil
	lea rbx, [game]
	mov [rsp+8], rbx
	mov rbx, [rsp+64]
	mov [rsp+16], rbx
	mov rbx, [rsp+56]
	mov [rsp+24], rbx
	call Board.place
	mov sil, [rsp+47]
	mov bl, [rsp+0]
	add rsp, 48
	test bl, bl
	je .L11
	jmp .L4
	jmp .L12
	.L11:
	.L12:
	jmp .L3
	.L4:
	add rsp, 48
	sub rsp, 32
	mov [rsp+31], sil
	lea rbx, [game]
	mov [rsp+8], rbx
	mov bl, 0x58
	mov [rsp+16], bl
	call Board.check_win
	mov sil, [rsp+31]
	mov bl, [rsp+0]
	add rsp, 32
	test bl, bl
	je .L13
	sub rsp, 16
	mov [rsp+15], sil
	mov rbx, STR10
	mov [rsp+0], rbx
	call println
	mov sil, [rsp+15]
	add rsp, 16
	jmp .L14
	.L13:
	sub rsp, 32
	mov [rsp+31], sil
	lea rbx, [game]
	mov [rsp+8], rbx
	mov bl, 0x4f
	mov [rsp+16], bl
	call Board.check_win
	mov sil, [rsp+31]
	mov bl, [rsp+0]
	add rsp, 32
	test bl, bl
	je .L15
	sub rsp, 16
	mov [rsp+15], sil
	mov rbx, STR11
	mov [rsp+0], rbx
	call println
	mov sil, [rsp+15]
	add rsp, 16
	jmp .L14
	.L15:
	sub rsp, 32
	mov [rsp+31], sil
	lea rbx, [game]
	mov [rsp+8], rbx
	call Board.check_tie
	mov sil, [rsp+31]
	mov bl, [rsp+0]
	add rsp, 32
	test bl, bl
	je .L16
	sub rsp, 16
	mov [rsp+15], sil
	mov rbx, STR12
	mov [rsp+0], rbx
	call println
	mov sil, [rsp+15]
	add rsp, 16
	jmp .L14
	.L16:
	jmp .L1
	.L14:
	sub rsp, 16
	mov [rsp+15], sil
	lea rbx, [game]
	mov [rsp+0], rbx
	call Board.print_board
	mov sil, [rsp+15]
	add rsp, 16
	sub rsp, 16
	mov [rsp+15], sil
	mov rbx, STR13
	mov [rsp+0], rbx
	call println
	mov sil, [rsp+15]
	add rsp, 16
	sub rsp, 16
	mov [rsp+15], sil
	sub rsp, 16
	mov [rsp+15], sil
	call input_char
	mov sil, [rsp+15]
	mov bl, [rsp+0]
	add rsp, 16
	mov [rsp+1], bl
	call to_lower
	mov sil, [rsp+15]
	mov bl, [rsp+0]
	add rsp, 16
	mov cl, 0x79
	cmp bl, cl
	sete bl
	test bl, bl
	je .L17
	sub rsp, 16
	mov [rsp+15], sil
	lea rbx, [game]
	mov [rsp+0], rbx
	call Board.reset
	mov sil, [rsp+15]
	add rsp, 16
	jmp .L18
	.L17:
	jmp .L2
	.L18:
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
global game:data
game:
times 9 db 0
db 32
times 6 db 0


section .rodata
STR0:
db "TURN: %c",0
STR1:
db "Coordinates (%i, %i) are invalid!",0
STR2:
db "Coordinates %c%c are already taken!",0
STR3:
db "123",0
STR4:
db "ABC",0
STR5:
db "  A   B   C",0
STR6:
db "  %*c",0
STR7:
db "%u %c | %c | %c",0
STR8:
db "Controls:",10,"Enter 'q' to leave.",10,"Enter the row number + column letter to choose a square to fill.",10,"",0
STR9:
db "Invalid input! Enter the row number + column letter.",10,"Example: 2C",0
STR10:
db "",10,"== X wins! ==",0
STR11:
db "",10,"== O wins! ==",0
STR12:
db "",10,"==== TIE ====",0
STR13:
db "",10,"<< GAME OVER! >>",10,"- Play again? (y/n) -",0
