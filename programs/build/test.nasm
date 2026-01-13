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
	mov rbx, 5
	mov [rsp+8], rbx
	mov rbx, [rsp+8]
	.L1:
	test rbx, rbx
	je .L2
	sub rsp, 16
	mov [rsp+8], rbx
	mov rcx, STR0
	mov [rsp+0], rcx
	call print_str
	mov rbx, [rsp+8]
	mov rcx, 0
	add rsp, 16
	dec rbx
	jmp .L1
	.L2:
	mov rcx, 0
	mov [rbp+16], rcx
	jmp .L0
	.L0:
	leave
	ret
extern memset
extern memcpy
extern strlen
extern print_strlen
extern print_str
extern print_decimal
extern print_hex
extern input
extern exit


section .data


section .rodata
STR0:
	db "Hello world!",10,"",0
