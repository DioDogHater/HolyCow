section .text
global _start
_start:
	sub rsp, 16
	call main
	mov rax, 60
	mov rdi, [rsp+8]
	syscall

main:
	push rbp
	mov rbp, rsp
	mov rbx, 5
	mov rax, rbx
	mov rbx, 5
	mov [rsp+24], rbx
	.L0:
	leave
	ret


section .rodata
