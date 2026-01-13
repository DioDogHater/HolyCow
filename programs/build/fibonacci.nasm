section .text
global _start
default ABS
_start:
	mov rax, [rsp+0]
	lea rbx, [rsp+8]
	sub rsp, 32
	mov [rsp+8], rax
	mov [rsp+16], rbx
	call main
	mov rax, 60
	mov rdi, [rsp]
	syscall

global main
main:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, 50
	mov [rsp+0], rbx
	call print_decimal
	mov rbx, 0
	add rsp, 16
	sub rsp, 32
	mov rbx, STR0
	mov [rsp+8], rbx
	mov rbx, 1
	neg rbx
	mov [rsp+16], rbx
	call string_to_int
	mov rbx, [rsp+0]
	add rsp, 32
	mov [rbp+16], rbx
	jmp .L0
	.L0:
	leave
	ret
extern memset
extern memcpy
extern strlen
extern print_str
extern print_decimal
extern print_hex
extern input
extern int_to_string
extern string_to_int
extern exit


section .data


section .rodata
STR0:
	db "10",0
