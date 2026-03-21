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

global Clamp:function
Clamp:
	push rbp
	mov rbp, rsp
	fld DWORD [rbp+20]
	fstp DWORD [rbp+16]
	fld DWORD [rbp+24]
	fld DWORD [rbp+20]
	fcomip
	fstp st0
	setb bl
	test bl, bl
	je .L1
	fld DWORD [rbp+24]
	fstp DWORD [rbp+16]
	jmp .L2
	.L1:
	.L2:
	fld DWORD [rbp+28]
	fld DWORD [rbp+20]
	fcomip
	fstp st0
	seta bl
	test bl, bl
	je .L3
	fld DWORD [rbp+28]
	fstp DWORD [rbp+16]
	jmp .L4
	.L3:
	.L4:
	.L0:
	leave
	ret

global Lerp:function
Lerp:
	push rbp
	mov rbp, rsp
	fld DWORD [rbp+20]
	fld DWORD [rbp+28]
	fld DWORD [rbp+24]
	fld DWORD [rbp+20]
	fsubp
	fmulp
	faddp
	fstp DWORD [rbp+16]
	.L0:
	leave
	ret

global Normalize:function
Normalize:
	push rbp
	mov rbp, rsp
	fld DWORD [rbp+20]
	fld DWORD [rbp+24]
	fsubp
	fld DWORD [rbp+28]
	fld DWORD [rbp+24]
	fsubp
	fdivp
	fstp DWORD [rbp+16]
	.L0:
	leave
	ret

global Remap:function
Remap:
	push rbp
	mov rbp, rsp
	fld DWORD [rbp+20]
	fld DWORD [rbp+24]
	fsubp
	fld DWORD [rbp+28]
	fld DWORD [rbp+24]
	fsubp
	fdivp
	fld DWORD [rbp+36]
	fld DWORD [rbp+32]
	fsubp
	fmulp
	fld DWORD [rbp+32]
	faddp
	fstp DWORD [rbp+16]
	.L0:
	leave
	ret

global Wrap:function
Wrap:
	push rbp
	mov rbp, rsp
	fld DWORD [rbp+20]
	fld DWORD [rbp+28]
	fld DWORD [rbp+24]
	fsubp
	sub rsp, 16
	fld DWORD [rbp+20]
	fld DWORD [rbp+24]
	fsubp
	fld DWORD [rbp+28]
	fld DWORD [rbp+24]
	fsubp
	fdivp
	fstp DWORD [__FP_TMP]
	movss xmm0, DWORD [__FP_TMP+0]
	call floorf
	movss DWORD [rsp+0], xmm0
	fld DWORD [rsp+0]
	add rsp, 16
	fmulp
	fsubp
	fstp DWORD [rbp+16]
	.L0:
	leave
	ret


extern finite:function
extern log:function
extern ceilf:function
extern log10:function
extern tan:function
extern exp2f:function
extern cos:function
extern fmod:function
extern modf:function
extern logf:function
extern sin:function
extern cbrt:function
extern fmodf:function
extern copysign:function
extern sinf:function
extern asinf:function
extern sinh:function
extern copysignf:function
extern expf:function
extern coshf:function
extern log2:function
extern hypot:function
extern pow:function
extern sinhf:function
extern log2f:function
extern hypotf:function
extern fabs:function
extern powf:function
extern ceil:function
extern tgammaf:function
extern exp2:function
extern floor:function
extern fabsf:function
extern atan:function
extern acos:function
extern floorf:function
extern round:function
extern log10f:function
extern tanf:function
extern sqrt:function
extern atanf:function
extern cosf:function
extern asin:function
extern acosf:function
extern exp:function
extern cosh:function
extern roundf:function
extern sqrtf:function
extern cbrtf:function
extern tgamma:function


section .data
static __FP_TMP:data
__FP_TMP:
dq 0
static __GP_TMP:data
__GP_TMP:
times 64 db 0


section .rodata
