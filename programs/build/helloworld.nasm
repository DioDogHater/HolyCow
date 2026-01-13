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
	sub rsp, 32
	mov rbx, 0
	mov [rsp+24], rbx
	mov rax, [rsp+24]
	mov rbx, 5
	imul rbx
	mov rbx, 5
	add rax, rbx
	mov [rsp+16], rax
	mov bl, '5'
	mov [rsp+15], bl
	mov rbx, STR0
	mov [rsp+0], rbx
	sub rsp, 16
	mov rbx, [rsp+16]
	mov [rsp+0], rbx
	call print_str
	mov rbx, 0
	add rsp, 16
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
