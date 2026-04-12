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
	sub rsp, 16
	mov rbx, STR0
	mov [rsp+0], rbx
	mov rcx, [rbp+16]
	movzx rbx, BYTE [rcx+9]
	mov [rsp+8], rbx
	call println
	add rsp, 16
	.L0:
	leave
	ret

global Board.get:function
Board.get:
	push rbp
	mov rbp, rsp
	mov rcx, [rbp+24]
	lea rbx, [rcx+0]
	mov rcx, [rbp+32]
	lea rcx, [rcx+rcx*2]
	mov rsi, [rbp+40]
	add rcx, rsi
	mov sil, [rbx+rcx*1]
	mov [rbp+16], sil
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
	mov rsi, 0x2
	cmp rcx, rsi
	setg bl
	.L5:
	test bl, bl
	jne .L4
	mov rcx, [rbp+40]
	xor rsi, rsi
	cmp rcx, rsi
	setl bl
	.L4:
	test bl, bl
	jne .L3
	mov rcx, [rbp+40]
	mov rsi, 0x2
	cmp rcx, rsi
	setg bl
	.L3:
	test bl, bl
	je .L1
	sub rsp, 32
	mov rbx, STR1
	mov [rsp+0], rbx
	mov rbx, [rbp+32]
	mov [rsp+8], rbx
	mov rbx, [rbp+40]
	mov [rsp+16], rbx
	call println
	add rsp, 32
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
	mov rbx, [rbp+40]
	mov [rsp+24], rbx
	call Board.get
	mov bl, [rsp+0]
	add rsp, 32
	mov cl, 0x20
	cmp bl, cl
	setne bl
	test bl, bl
	je .L6
	sub rsp, 32
	mov rbx, STR2
	mov [rsp+0], rbx
	mov rbx, STR3
	mov rcx, [rbp+32]
	movzx rsi, BYTE [rbx+rcx*1]
	mov [rsp+8], rsi
	mov rbx, STR4
	mov rcx, [rbp+40]
	movzx rsi, BYTE [rbx+rcx*1]
	mov [rsp+16], rsi
	call println
	add rsp, 32
	xor bl, bl
	mov [rbp+16], bl
	jmp .L0
	.L6:
	.L7:
	mov rcx, [rbp+24]
	lea rbx, [rcx+0]
	mov rcx, [rbp+32]
	lea rcx, [rcx+rcx*2]
	mov rsi, [rbp+40]
	add rcx, rsi
	mov rdi, [rbp+24]
	mov sil, [rdi+9]
	mov [rbx+rcx*1], sil
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
	mov rbx, STR5
	mov [rsp+0], rbx
	call println
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
	mov rbx, STR6
	mov [rsp+0], rbx
	mov rbx, 0xa
	mov [rsp+8], rbx
	mov rbx, 0x2d
	mov [rsp+16], rbx
	call println
	add rsp, 32
	.L4:
	.L5:
	sub rsp, 48
	mov rbx, STR7
	mov [rsp+0], rbx
	mov rbx, [rsp+56]
	inc rbx
	mov [rsp+8], rbx
	mov rcx, [rbp+16]
	lea rbx, [rcx+0]
	mov rcx, [rsp+56]
	lea rcx, [rcx+rcx*2]
	movzx rsi, BYTE [rbx+rcx*1]
	mov [rsp+16], rsi
	mov rcx, [rbp+16]
	lea rbx, [rcx+0]
	mov rcx, [rsp+56]
	lea rcx, [rcx+rcx*2]
	inc rcx
	movzx rsi, BYTE [rbx+rcx*1]
	mov [rsp+24], rsi
	mov rcx, [rbp+16]
	lea rbx, [rcx+0]
	mov rcx, [rsp+56]
	lea rcx, [rcx+rcx*2]
	add rcx, 0x2
	movzx rsi, BYTE [rbx+rcx*1]
	mov [rsp+32], rsi
	call println
	add rsp, 48
	.L2:
	mov rbx, [rsp+8]
	inc QWORD [rsp+8]
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
	mov rsi, [rbp+24]
	lea rcx, [rsi+0]
	mov rsi, [rsp+8]
	mov dil, [rcx+rsi*1]
	mov cl, [rbp+32]
	cmp dil, cl
	sete cl
	test cl, cl
	je .L7
	mov rdi, [rbp+24]
	lea rsi, [rdi+0]
	mov rdi, [rsp+8]
	inc rdi
	mov r8b, [rsi+rdi*1]
	mov sil, [rbp+32]
	cmp r8b, sil
	sete cl
	.L7:
	test cl, cl
	je .L6
	mov rdi, [rbp+24]
	lea rsi, [rdi+0]
	mov rdi, [rsp+8]
	add rdi, 0x2
	mov r8b, [rsi+rdi*1]
	mov sil, [rbp+32]
	cmp r8b, sil
	sete cl
	.L6:
	test cl, cl
	je .L4
	mov cl, 0x1
	mov [rbp+16], cl
	jmp .L0
	.L4:
	.L5:
	mov rcx, [rsp+8]
	add rcx, 0x3
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
	mov rsi, [rbp+24]
	lea rcx, [rsi+0]
	mov rsi, [rsp+8]
	mov dil, [rcx+rsi*1]
	mov cl, [rbp+32]
	cmp dil, cl
	sete cl
	test cl, cl
	je .L14
	mov rdi, [rbp+24]
	lea rsi, [rdi+0]
	mov rdi, [rsp+8]
	add rdi, 0x3
	mov r8b, [rsi+rdi*1]
	mov sil, [rbp+32]
	cmp r8b, sil
	sete cl
	.L14:
	test cl, cl
	je .L13
	mov rdi, [rbp+24]
	lea rsi, [rdi+0]
	mov rdi, [rsp+8]
	add rdi, 0x6
	mov r8b, [rsi+rdi*1]
	mov sil, [rbp+32]
	cmp r8b, sil
	sete cl
	.L13:
	test cl, cl
	je .L11
	mov cl, 0x1
	mov [rbp+16], cl
	jmp .L0
	.L11:
	.L12:
	inc QWORD [rsp+8]
	mov rcx, [rsp+8]
	.L9:
	dec rbx
	jmp .L8
	.L10:
	mov rcx, [rbp+24]
	lea rbx, [rcx+0]
	xor rcx, rcx
	mov sil, [rbx+rcx*1]
	mov bl, [rbp+32]
	cmp sil, bl
	sete bl
	test bl, bl
	je .L18
	mov rsi, [rbp+24]
	lea rcx, [rsi+0]
	mov rsi, 0x4
	mov dil, [rcx+rsi*1]
	mov cl, [rbp+32]
	cmp dil, cl
	sete bl
	.L18:
	test bl, bl
	je .L17
	mov rsi, [rbp+24]
	lea rcx, [rsi+0]
	mov rsi, 0x8
	mov dil, [rcx+rsi*1]
	mov cl, [rbp+32]
	cmp dil, cl
	sete bl
	.L17:
	test bl, bl
	je .L15
	mov bl, 0x1
	mov [rbp+16], bl
	jmp .L0
	.L15:
	.L16:
	mov rcx, [rbp+24]
	lea rbx, [rcx+0]
	mov rcx, 0x2
	mov sil, [rbx+rcx*1]
	mov bl, [rbp+32]
	cmp sil, bl
	sete bl
	test bl, bl
	je .L22
	mov rsi, [rbp+24]
	lea rcx, [rsi+0]
	mov rsi, 0x4
	mov dil, [rcx+rsi*1]
	mov cl, [rbp+32]
	cmp dil, cl
	sete bl
	.L22:
	test bl, bl
	je .L21
	mov rsi, [rbp+24]
	lea rcx, [rsi+0]
	mov rsi, 0x6
	mov dil, [rcx+rsi*1]
	mov cl, [rbp+32]
	cmp dil, cl
	sete bl
	.L21:
	test bl, bl
	je .L19
	mov bl, 0x1
	mov [rbp+16], bl
	jmp .L0
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
	mov sil, [rcx]
	mov cl, 0x20
	cmp sil, cl
	sete cl
	test cl, cl
	je .L4
	xor cl, cl
	mov [rbp+16], cl
	jmp .L0
	.L4:
	.L5:
	inc QWORD [rsp+8]
	mov rcx, [rsp+8]
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
	lea rbx, [game]
	mov [rsp+0], rbx
	call Board.reset
	add rsp, 16
	sub rsp, 16
	mov rbx, STR8
	mov [rsp+0], rbx
	call println
	add rsp, 16
	.L1:
	sub rsp, 16
	lea rbx, [game]
	mov [rsp+0], rbx
	call Board.print_board
	add rsp, 16
	sub rsp, 16
	lea rbx, [game]
	mov [rsp+0], rbx
	call Board.change_turn
	add rsp, 16
	sub rsp, 48
	.L3:
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
	je .L5
	jmp .L0
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
	lea rcx, [rsp+48]
	xor rsi, rsi
	mov dil, [rcx+rsi*1]
	mov [rsp+1], dil
	call is_num
	mov bl, [rsp+15]
	mov cl, [rsp+0]
	add rsp, 16
	test cl, cl
	sete bl
	.L10:
	test bl, bl
	jne .L9
	sub rsp, 16
	mov [rsp+15], bl
	lea rcx, [rsp+48]
	mov rsi, 0x1
	mov dil, [rcx+rsi*1]
	mov [rsp+1], dil
	call is_alpha
	mov bl, [rsp+15]
	mov cl, [rsp+0]
	add rsp, 16
	test cl, cl
	sete bl
	.L9:
	test bl, bl
	je .L7
	sub rsp, 16
	mov rbx, STR9
	mov [rsp+0], rbx
	call println
	add rsp, 16
	jmp .L3
	.L7:
	.L8:
	lea rbx, [rsp+32]
	movzx rcx, BYTE [rbx]
	sub rcx, 0x31
	mov [rsp+16], rcx
	sub rsp, 16
	lea rbx, [rsp+48]
	mov rcx, 0x1
	mov sil, [rbx+rcx*1]
	mov [rsp+1], sil
	call to_upper
	movzx rbx, BYTE [rsp+0]
	add rsp, 16
	sub rbx, 0x41
	mov [rsp+8], rbx
	sub rsp, 32
	lea rbx, [game]
	mov [rsp+8], rbx
	mov rbx, [rsp+48]
	mov [rsp+16], rbx
	mov rbx, [rsp+40]
	mov [rsp+24], rbx
	call Board.place
	mov bl, [rsp+0]
	add rsp, 32
	test bl, bl
	je .L11
	jmp .L4
	.L11:
	.L12:
	jmp .L3
	.L4:
	add rsp, 48
	sub rsp, 32
	lea rbx, [game]
	mov [rsp+8], rbx
	mov bl, 0x58
	mov [rsp+16], bl
	call Board.check_win
	mov bl, [rsp+0]
	add rsp, 32
	test bl, bl
	je .L13
	sub rsp, 16
	mov rbx, STR10
	mov [rsp+0], rbx
	call println
	add rsp, 16
	jmp .L14
	.L13:
	sub rsp, 32
	lea rbx, [game]
	mov [rsp+8], rbx
	mov bl, 0x4f
	mov [rsp+16], bl
	call Board.check_win
	mov bl, [rsp+0]
	add rsp, 32
	test bl, bl
	je .L15
	sub rsp, 16
	mov rbx, STR11
	mov [rsp+0], rbx
	call println
	add rsp, 16
	jmp .L14
	.L15:
	sub rsp, 16
	lea rbx, [game]
	mov [rsp+8], rbx
	call Board.check_tie
	mov bl, [rsp+0]
	add rsp, 16
	test bl, bl
	je .L16
	sub rsp, 16
	mov rbx, STR12
	mov [rsp+0], rbx
	call println
	add rsp, 16
	jmp .L14
	.L16:
	jmp .L1
	.L14:
	sub rsp, 16
	lea rbx, [game]
	mov [rsp+0], rbx
	call Board.print_board
	add rsp, 16
	sub rsp, 16
	mov rbx, STR13
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
	je .L17
	sub rsp, 16
	lea rbx, [game]
	mov [rsp+0], rbx
	call Board.reset
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


extern log:function
extern sin:function
extern print_char:function
extern trunc:function
extern print:function
extern set_rounding:function
extern pow:function
extern memmove:function
extern random:function
extern is_num:function
extern memset:function
extern malloc:function
extern exit:function
extern tan:function
extern int_to_string:function
extern string_to_int:function
extern print_format:function
extern strcmp:function
extern strfind:function
extern absf:function
extern print_fixed:function
extern absi:function
extern floor:function
extern uint_to_string:function
extern strdfind:function
extern free:function
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
extern realloc:function
extern cos:function
extern strcpy:function
extern print_double:function
extern println:function
extern round:function
extern sqrt:function
extern error:function
extern randint:function
extern print_hex:function
extern atan2:function
extern is_alnum:function
extern File.write:function
extern File.read:function
extern File.print:function
extern File.println:function
extern File.set_buffering:function
extern File.set_buffer:function
extern File.flush:function
extern string.share:function
extern string.print:function
extern string.compare:function
extern string.is_equal:function
extern string.str_equals:function
extern string.is_heap:function
extern string.is_shared:function
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
extern string.from_shared:function
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
global game:data
game:
times 9 db 0
db 32
times 6 db 0
extern File:data
extern fixed:data
extern string:data


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
