section .text
BITS 64
CPU ALL
default REL
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

global Vector2.__neg:function
Vector2.__neg:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	mov rcx, [rbp+24]
	movss xmm0, [rcx+0]
	xorps xmm0, [__FNEG_MASKs]
	movss [rbx+0], xmm0
	mov rcx, [rbp+24]
	movss xmm0, [rcx+4]
	xorps xmm0, [__FNEG_MASKs]
	movss [rbx+4], xmm0
	.L0:
	leave
	ret

global Vector2.__add_Vector2:function
Vector2.__add_Vector2:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	lea rbx, [__GP_TMP]
	mov rdi, [rbp+32]
	mov [rbx], rdi
	movsd xmm1, [__GP_TMP]
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	mov rdi, [r8]
	mov [rbx], rdi
	movsd xmm0, [__GP_TMP]
	call Vector2Add
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	add rsp, 16
	.L0:
	leave
	ret

global Vector2.__add_float:function
Vector2.__add_float:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	movss xmm0, [rbp+32]
	movss xmm1, xmm0
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	mov rdi, [r8]
	mov [rbx], rdi
	movsd xmm0, [__GP_TMP]
	call Vector2AddValue
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	add rsp, 16
	.L0:
	leave
	ret

global Vector2.__add_int:function
Vector2.__add_int:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	movss xmm0, [rbp+32]
	movss xmm1, xmm0
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	mov rdi, [r8]
	mov [rbx], rdi
	movsd xmm0, [__GP_TMP]
	call Vector2AddValue
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	add rsp, 16
	.L0:
	leave
	ret

global Vector2.__sub_Vector2:function
Vector2.__sub_Vector2:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	lea rbx, [__GP_TMP]
	mov rdi, [rbp+32]
	mov [rbx], rdi
	movsd xmm1, [__GP_TMP]
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	mov rdi, [r8]
	mov [rbx], rdi
	movsd xmm0, [__GP_TMP]
	call Vector2Subtract
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	add rsp, 16
	.L0:
	leave
	ret

global Vector2.__sub_float:function
Vector2.__sub_float:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	movss xmm0, [rbp+32]
	movss xmm1, xmm0
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	mov rdi, [r8]
	mov [rbx], rdi
	movsd xmm0, [__GP_TMP]
	call Vector2SubtractValue
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	add rsp, 16
	.L0:
	leave
	ret

global Vector2.__sub_int:function
Vector2.__sub_int:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	movss xmm0, [rbp+32]
	movss xmm1, xmm0
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	mov rdi, [r8]
	mov [rbx], rdi
	movsd xmm0, [__GP_TMP]
	call Vector2SubtractValue
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	add rsp, 16
	.L0:
	leave
	ret

global Vector2.__mul_Vector2:function
Vector2.__mul_Vector2:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	lea rbx, [__GP_TMP]
	mov rdi, [rbp+32]
	mov [rbx], rdi
	movsd xmm1, [__GP_TMP]
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	mov rdi, [r8]
	mov [rbx], rdi
	movsd xmm0, [__GP_TMP]
	call Vector2Multiply
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	add rsp, 16
	.L0:
	leave
	ret

global Vector2.__mul_float:function
Vector2.__mul_float:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	movss xmm0, [rbp+32]
	movss xmm1, xmm0
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	mov rdi, [r8]
	mov [rbx], rdi
	movsd xmm0, [__GP_TMP]
	call Vector2Scale
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	add rsp, 16
	.L0:
	leave
	ret

global Vector2.__mul_int:function
Vector2.__mul_int:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	movss xmm0, [rbp+32]
	movss xmm1, xmm0
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	mov rdi, [r8]
	mov [rbx], rdi
	movsd xmm0, [__GP_TMP]
	call Vector2Scale
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	add rsp, 16
	.L0:
	leave
	ret

global Vector2.__div_Vector2:function
Vector2.__div_Vector2:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	lea rbx, [__GP_TMP]
	mov rdi, [rbp+32]
	mov [rbx], rdi
	movsd xmm1, [__GP_TMP]
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	mov rdi, [r8]
	mov [rbx], rdi
	movsd xmm0, [__GP_TMP]
	call Vector2Divide
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	add rsp, 16
	.L0:
	leave
	ret

global Vector2.__div_float:function
Vector2.__div_float:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	cvtsd2ss xmm0, [FP0]
	movss xmm1, [rbp+32]
	divss xmm0, xmm1
	movss xmm1, xmm0
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	mov rdi, [r8]
	mov [rbx], rdi
	movsd xmm0, [__GP_TMP]
	call Vector2Scale
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	add rsp, 16
	.L0:
	leave
	ret

global Vector2.__div_int:function
Vector2.__div_int:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	cvtsd2ss xmm0, [FP0]
	movss xmm1, [rbp+32]
	divss xmm0, xmm1
	movss xmm1, xmm0
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	mov rdi, [r8]
	mov [rbx], rdi
	movsd xmm0, [__GP_TMP]
	call Vector2Scale
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	add rsp, 16
	.L0:
	leave
	ret

global Vector2.__eq_Vector2:function
Vector2.__eq_Vector2:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	lea rbx, [__GP_TMP]
	mov rdi, [rbp+32]
	mov [rbx], rdi
	movsd xmm1, [__GP_TMP]
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	mov rdi, [r8]
	mov [rbx], rdi
	movsd xmm0, [__GP_TMP]
	call Vector2Equals
	mov [rsp+0], rax
	mov bl, [rsp+0]
	add rsp, 16
	mov [rbp+16], bl
	.L0:
	leave
	ret

global Vector2.length:function
Vector2.length:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	mov rdi, [r8]
	mov [rbx], rdi
	movsd xmm0, [__GP_TMP]
	call Vector2Length
	movss [rsp+0], xmm0
	cvtss2sd xmm0, [rsp+0]
	add rsp, 16
	cvtsd2ss xmm0, xmm0
	movss [rbp+16], xmm0
	.L0:
	leave
	ret

global Vector2.length2:function
Vector2.length2:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	mov rdi, [r8]
	mov [rbx], rdi
	movsd xmm0, [__GP_TMP]
	call Vector2LengthSqr
	movss [rsp+0], xmm0
	cvtss2sd xmm0, [rsp+0]
	add rsp, 16
	cvtsd2ss xmm0, xmm0
	movss [rbp+16], xmm0
	.L0:
	leave
	ret

global Vector2.normalized:function
Vector2.normalized:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	mov rdi, [r8]
	mov [rbx], rdi
	movsd xmm0, [__GP_TMP]
	call Vector2Normalize
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	add rsp, 16
	.L0:
	leave
	ret

global Vector3.__neg:function
Vector3.__neg:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	mov rcx, [rbp+24]
	movss xmm0, [rcx+0]
	xorps xmm0, [__FNEG_MASKs]
	movss [rbx+0], xmm0
	mov rcx, [rbp+24]
	movss xmm0, [rcx+4]
	xorps xmm0, [__FNEG_MASKs]
	movss [rbx+4], xmm0
	mov rcx, [rbp+24]
	movss xmm0, [rcx+8]
	xorps xmm0, [__FNEG_MASKs]
	movss [rbx+8], xmm0
	.L0:
	leave
	ret

global Vector3.__add_Vector3:function
Vector3.__add_Vector3:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	lea rbx, [__GP_TMP]
	cld
	lea rdi, [rbx]
	lea rsi, [rbp+32]
	mov rcx, 3
	rep movsd
	movss xmm3, [__GP_TMP+8]
	movsd xmm2, [__GP_TMP]
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 3
	rep movsd
	movss xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector3Add
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	movss [rbx+8], xmm1
	add rsp, 16
	.L0:
	leave
	ret

global Vector3.__add_float:function
Vector3.__add_float:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	movss xmm0, [rbp+32]
	movss xmm2, xmm0
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 3
	rep movsd
	movss xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector3AddValue
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	movss [rbx+8], xmm1
	add rsp, 16
	.L0:
	leave
	ret

global Vector3.__add_int:function
Vector3.__add_int:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	movss xmm0, [rbp+32]
	movss xmm2, xmm0
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 3
	rep movsd
	movss xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector3AddValue
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	movss [rbx+8], xmm1
	add rsp, 16
	.L0:
	leave
	ret

global Vector3.__sub_Vector3:function
Vector3.__sub_Vector3:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	lea rbx, [__GP_TMP]
	cld
	lea rdi, [rbx]
	lea rsi, [rbp+32]
	mov rcx, 3
	rep movsd
	movss xmm3, [__GP_TMP+8]
	movsd xmm2, [__GP_TMP]
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 3
	rep movsd
	movss xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector3Subtract
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	movss [rbx+8], xmm1
	add rsp, 16
	.L0:
	leave
	ret

global Vector3.__sub_float:function
Vector3.__sub_float:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	movss xmm0, [rbp+32]
	movss xmm2, xmm0
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 3
	rep movsd
	movss xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector3SubtractValue
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	movss [rbx+8], xmm1
	add rsp, 16
	.L0:
	leave
	ret

global Vector3.__sub_int:function
Vector3.__sub_int:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	movss xmm0, [rbp+32]
	movss xmm2, xmm0
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 3
	rep movsd
	movss xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector3SubtractValue
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	movss [rbx+8], xmm1
	add rsp, 16
	.L0:
	leave
	ret

global Vector3.__mul_Vector3:function
Vector3.__mul_Vector3:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	lea rbx, [__GP_TMP]
	cld
	lea rdi, [rbx]
	lea rsi, [rbp+32]
	mov rcx, 3
	rep movsd
	movss xmm3, [__GP_TMP+8]
	movsd xmm2, [__GP_TMP]
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 3
	rep movsd
	movss xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector3Multiply
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	movss [rbx+8], xmm1
	add rsp, 16
	.L0:
	leave
	ret

global Vector3.__mul_float:function
Vector3.__mul_float:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	movss xmm0, [rbp+32]
	movss xmm2, xmm0
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 3
	rep movsd
	movss xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector3Scale
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	movss [rbx+8], xmm1
	add rsp, 16
	.L0:
	leave
	ret

global Vector3.__mul_int:function
Vector3.__mul_int:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	movss xmm0, [rbp+32]
	movss xmm2, xmm0
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 3
	rep movsd
	movss xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector3Scale
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	movss [rbx+8], xmm1
	add rsp, 16
	.L0:
	leave
	ret

global Vector3.__div_Vector3:function
Vector3.__div_Vector3:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	lea rbx, [__GP_TMP]
	cld
	lea rdi, [rbx]
	lea rsi, [rbp+32]
	mov rcx, 3
	rep movsd
	movss xmm3, [__GP_TMP+8]
	movsd xmm2, [__GP_TMP]
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 3
	rep movsd
	movss xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector3Divide
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	movss [rbx+8], xmm1
	add rsp, 16
	.L0:
	leave
	ret

global Vector3.__div_float:function
Vector3.__div_float:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	cvtsd2ss xmm0, [FP0]
	movss xmm1, [rbp+32]
	divss xmm0, xmm1
	movss xmm2, xmm0
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 3
	rep movsd
	movss xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector3Scale
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	movss [rbx+8], xmm1
	add rsp, 16
	.L0:
	leave
	ret

global Vector3.__div_int:function
Vector3.__div_int:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	cvtsd2ss xmm0, [FP0]
	movss xmm1, [rbp+32]
	divss xmm0, xmm1
	movss xmm2, xmm0
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 3
	rep movsd
	movss xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector3Scale
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	movss [rbx+8], xmm1
	add rsp, 16
	.L0:
	leave
	ret

global Vector3.__eq_Vector3:function
Vector3.__eq_Vector3:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	lea rbx, [__GP_TMP]
	cld
	lea rdi, [rbx]
	lea rsi, [rbp+32]
	mov rcx, 3
	rep movsd
	movss xmm3, [__GP_TMP+8]
	movsd xmm2, [__GP_TMP]
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 3
	rep movsd
	movss xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector3Equals
	mov [rsp+0], rax
	mov bl, [rsp+0]
	add rsp, 16
	mov [rbp+16], bl
	.L0:
	leave
	ret

global Vector3.length:function
Vector3.length:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 3
	rep movsd
	movss xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector3Length
	movss [rsp+0], xmm0
	cvtss2sd xmm0, [rsp+0]
	add rsp, 16
	cvtsd2ss xmm0, xmm0
	movss [rbp+16], xmm0
	.L0:
	leave
	ret

global Vector3.length2:function
Vector3.length2:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 3
	rep movsd
	movss xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector3LengthSqr
	movss [rsp+0], xmm0
	cvtss2sd xmm0, [rsp+0]
	add rsp, 16
	cvtsd2ss xmm0, xmm0
	movss [rbp+16], xmm0
	.L0:
	leave
	ret

global Vector3.normalized:function
Vector3.normalized:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 3
	rep movsd
	movss xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector3Normalize
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	movss [rbx+8], xmm1
	add rsp, 16
	.L0:
	leave
	ret

global Vector4.__neg:function
Vector4.__neg:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	mov rcx, [rbp+24]
	movss xmm0, [rcx+0]
	xorps xmm0, [__FNEG_MASKs]
	movss [rbx+0], xmm0
	mov rcx, [rbp+24]
	movss xmm0, [rcx+4]
	xorps xmm0, [__FNEG_MASKs]
	movss [rbx+4], xmm0
	mov rcx, [rbp+24]
	movss xmm0, [rcx+8]
	xorps xmm0, [__FNEG_MASKs]
	movss [rbx+8], xmm0
	mov rcx, [rbp+24]
	movss xmm0, [rcx+12]
	xorps xmm0, [__FNEG_MASKs]
	movss [rbx+12], xmm0
	.L0:
	leave
	ret

global Vector4.__add_Vector4:function
Vector4.__add_Vector4:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	lea rbx, [__GP_TMP]
	cld
	lea rdi, [rbx]
	lea rsi, [rbp+32]
	mov rcx, 2
	rep movsq
	movsd xmm3, [__GP_TMP+8]
	movsd xmm2, [__GP_TMP]
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 2
	rep movsq
	movsd xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector4Add
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	movsd [rbx+8], xmm1
	add rsp, 16
	.L0:
	leave
	ret

global Vector4.__add_float:function
Vector4.__add_float:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	movss xmm0, [rbp+32]
	movss xmm2, xmm0
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 2
	rep movsq
	movsd xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector4AddValue
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	movsd [rbx+8], xmm1
	add rsp, 16
	.L0:
	leave
	ret

global Vector4.__add_int:function
Vector4.__add_int:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	movss xmm0, [rbp+32]
	movss xmm2, xmm0
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 2
	rep movsq
	movsd xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector4AddValue
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	movsd [rbx+8], xmm1
	add rsp, 16
	.L0:
	leave
	ret

global Vector4.__sub_Vector4:function
Vector4.__sub_Vector4:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	lea rbx, [__GP_TMP]
	cld
	lea rdi, [rbx]
	lea rsi, [rbp+32]
	mov rcx, 2
	rep movsq
	movsd xmm3, [__GP_TMP+8]
	movsd xmm2, [__GP_TMP]
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 2
	rep movsq
	movsd xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector4Subtract
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	movsd [rbx+8], xmm1
	add rsp, 16
	.L0:
	leave
	ret

global Vector4.__sub_float:function
Vector4.__sub_float:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	movss xmm0, [rbp+32]
	movss xmm2, xmm0
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 2
	rep movsq
	movsd xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector4SubtractValue
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	movsd [rbx+8], xmm1
	add rsp, 16
	.L0:
	leave
	ret

global Vector4.__sub_int:function
Vector4.__sub_int:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	movss xmm0, [rbp+32]
	movss xmm2, xmm0
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 2
	rep movsq
	movsd xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector4SubtractValue
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	movsd [rbx+8], xmm1
	add rsp, 16
	.L0:
	leave
	ret

global Vector4.__mul_Vector4:function
Vector4.__mul_Vector4:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	lea rbx, [__GP_TMP]
	cld
	lea rdi, [rbx]
	lea rsi, [rbp+32]
	mov rcx, 2
	rep movsq
	movsd xmm3, [__GP_TMP+8]
	movsd xmm2, [__GP_TMP]
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 2
	rep movsq
	movsd xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector4Multiply
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	movsd [rbx+8], xmm1
	add rsp, 16
	.L0:
	leave
	ret

global Vector4.__mul_float:function
Vector4.__mul_float:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	movss xmm0, [rbp+32]
	movss xmm2, xmm0
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 2
	rep movsq
	movsd xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector4Scale
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	movsd [rbx+8], xmm1
	add rsp, 16
	.L0:
	leave
	ret

global Vector4.__mul_int:function
Vector4.__mul_int:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	movss xmm0, [rbp+32]
	movss xmm2, xmm0
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 2
	rep movsq
	movsd xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector4Scale
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	movsd [rbx+8], xmm1
	add rsp, 16
	.L0:
	leave
	ret

global Vector4.__div_Vector4:function
Vector4.__div_Vector4:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	lea rbx, [__GP_TMP]
	cld
	lea rdi, [rbx]
	lea rsi, [rbp+32]
	mov rcx, 2
	rep movsq
	movsd xmm3, [__GP_TMP+8]
	movsd xmm2, [__GP_TMP]
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 2
	rep movsq
	movsd xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector4Divide
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	movsd [rbx+8], xmm1
	add rsp, 16
	.L0:
	leave
	ret

global Vector4.__div_float:function
Vector4.__div_float:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	cvtsd2ss xmm0, [FP0]
	movss xmm1, [rbp+32]
	divss xmm0, xmm1
	movss xmm2, xmm0
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 2
	rep movsq
	movsd xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector4Scale
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	movsd [rbx+8], xmm1
	add rsp, 16
	.L0:
	leave
	ret

global Vector4.__div_int:function
Vector4.__div_int:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	cvtsd2ss xmm0, [FP0]
	movss xmm1, [rbp+32]
	divss xmm0, xmm1
	movss xmm2, xmm0
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 2
	rep movsq
	movsd xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector4Scale
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	movsd [rbx+8], xmm1
	add rsp, 16
	.L0:
	leave
	ret

global Vector4.__eq_Vector4:function
Vector4.__eq_Vector4:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	lea rbx, [__GP_TMP]
	cld
	lea rdi, [rbx]
	lea rsi, [rbp+32]
	mov rcx, 2
	rep movsq
	movsd xmm3, [__GP_TMP+8]
	movsd xmm2, [__GP_TMP]
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 2
	rep movsq
	movsd xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector4Equals
	mov [rsp+0], rax
	mov bl, [rsp+0]
	add rsp, 16
	mov [rbp+16], bl
	.L0:
	leave
	ret

global Vector4.length:function
Vector4.length:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 2
	rep movsq
	movsd xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector4Length
	movss [rsp+0], xmm0
	cvtss2sd xmm0, [rsp+0]
	add rsp, 16
	cvtsd2ss xmm0, xmm0
	movss [rbp+16], xmm0
	.L0:
	leave
	ret

global Vector4.length2:function
Vector4.length2:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 2
	rep movsq
	movsd xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector4LengthSqr
	movss [rsp+0], xmm0
	cvtss2sd xmm0, [rsp+0]
	add rsp, 16
	cvtsd2ss xmm0, xmm0
	movss [rbp+16], xmm0
	.L0:
	leave
	ret

global Vector4.normalized:function
Vector4.normalized:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 2
	rep movsq
	movsd xmm1, [__GP_TMP+8]
	movsd xmm0, [__GP_TMP]
	call Vector4Normalize
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	movsd [rbx+8], xmm1
	add rsp, 16
	.L0:
	leave
	ret

global Matrix.determinant:function
Matrix.determinant:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	sub rsp, 64
	lea rbx, [rsp+0]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 8
	rep movsq
	call MatrixDeterminant
	movss [rsp+0], xmm0
	cvtss2sd xmm0, [rsp+0]
	add rsp, 80
	cvtsd2ss xmm0, xmm0
	movss [rbp+16], xmm0
	.L0:
	leave
	ret

global Matrix.trace:function
Matrix.trace:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	sub rsp, 64
	lea rbx, [rsp+0]
	mov r8, [rbp+24]
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 8
	rep movsq
	call MatrixTrace
	movss [rsp+0], xmm0
	cvtss2sd xmm0, [rsp+0]
	add rsp, 80
	cvtsd2ss xmm0, xmm0
	movss [rbp+16], xmm0
	.L0:
	leave
	ret

global Matrix.transpose:function
Matrix.transpose:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	mov rdi, rbx
	sub rsp, 64
	lea rbx, [rsp+0]
	mov r8, [rbp+24]
	mov r9, rdi
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 8
	rep movsq
	mov rdi, r9
	call MatrixTranspose
	mov rbx, [rsp+0]
	add rsp, 80
	.L0:
	leave
	ret

global Matrix.invert:function
Matrix.invert:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	mov rdi, rbx
	sub rsp, 64
	lea rbx, [rsp+0]
	mov r8, [rbp+24]
	mov r9, rdi
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 8
	rep movsq
	mov rdi, r9
	call MatrixInvert
	mov rbx, [rsp+0]
	add rsp, 80
	.L0:
	leave
	ret

global Matrix.__add_Matrix:function
Matrix.__add_Matrix:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	mov rdi, rbx
	sub rsp, 128
	lea rbx, [rsp+64]
	mov r8, rdi
	cld
	lea rdi, [rbx]
	lea rsi, [rbp+32]
	mov rcx, 8
	rep movsq
	mov rdi, r8
	lea rbx, [rsp+0]
	mov r8, [rbp+24]
	mov r9, rdi
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 8
	rep movsq
	mov rdi, r9
	call MatrixAdd
	mov rbx, [rsp+0]
	add rsp, 144
	.L0:
	leave
	ret

global Matrix.__sub_Matrix:function
Matrix.__sub_Matrix:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	mov rdi, rbx
	sub rsp, 128
	lea rbx, [rsp+64]
	mov r8, rdi
	cld
	lea rdi, [rbx]
	lea rsi, [rbp+32]
	mov rcx, 8
	rep movsq
	mov rdi, r8
	lea rbx, [rsp+0]
	mov r8, [rbp+24]
	mov r9, rdi
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 8
	rep movsq
	mov rdi, r9
	call MatrixSubtract
	mov rbx, [rsp+0]
	add rsp, 144
	.L0:
	leave
	ret

global Matrix.__mul_Matrix:function
Matrix.__mul_Matrix:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	mov rdi, rbx
	sub rsp, 128
	lea rbx, [rsp+64]
	mov r8, rdi
	cld
	lea rdi, [rbx]
	lea rsi, [rbp+32]
	mov rcx, 8
	rep movsq
	mov rdi, r8
	lea rbx, [rsp+0]
	mov r8, [rbp+24]
	mov r9, rdi
	cld
	lea rdi, [rbx]
	lea rsi, [r8]
	mov rcx, 8
	rep movsq
	mov rdi, r9
	call MatrixMultiply
	mov rbx, [rsp+0]
	add rsp, 144
	.L0:
	leave
	ret

global Button.width:function
Button.width:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, [rbp+24]
	movsxd rsi, DWORD [rbx+20]
	mov rbx, [rbp+24]
	mov rdi, [rbx+8]
	call MeasureText
	mov [rsp+0], rax
	mov ebx, [rsp+0]
	add rsp, 16
	mov [rbp+16], ebx
	.L0:
	leave
	ret

global Button.height:function
Button.height:
	push rbp
	mov rbp, rsp
	mov rcx, [rbp+24]
	mov ebx, [rcx+20]
	mov [rbp+16], ebx
	.L0:
	leave
	ret

global Button.draw:function
Button.draw:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	sub rsp, 16
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	call Button.width
	mov ebx, [rsp+0]
	add rsp, 16
	mov [rsp+12], ebx
	lea rbx, [rsp+8]
	mov r8, [rbp+16]
	lea r8, [r8+16]
	mov edi, [r8]
	mov [rbx], edi
	mov rcx, [rbp+16]
	mov bl, [rcx+25]
	test bl, bl
	je .L1
	lea rbx, [rsp+8]
	mov cl, [rsp+8]
	shr cl, 1
	mov [rbx+0], cl
	mov cl, [rsp+9]
	shr cl, 1
	mov [rbx+1], cl
	mov cl, [rsp+10]
	shr cl, 1
	mov [rbx+2], cl
	mov cl, 0xff
	mov [rbx+3], cl
	jmp .L2
	.L1:
	mov rcx, [rbp+16]
	mov bl, [rcx+24]
	test bl, bl
	je .L3
	lea rbx, [rsp+8]
	movzx rax, BYTE [rsp+8]
	shl rax, 1
	mov rcx, 0x3
	xor rdx, rdx
	idiv rcx
	mov [rbx+0], al
	movzx rax, BYTE [rsp+9]
	shl rax, 1
	mov rcx, 0x3
	xor rdx, rdx
	idiv rcx
	mov [rbx+1], al
	movzx rax, BYTE [rsp+10]
	shl rax, 1
	mov rcx, 0x3
	xor rdx, rdx
	idiv rcx
	mov [rbx+2], al
	mov cl, 0xff
	mov [rbx+3], cl
	jmp .L2
	.L3:
	.L2:
	lea rbx, [__GP_TMP]
	mov edi, [rsp+8]
	mov [rbx], edi
	mov r8, QWORD [__GP_TMP+0]
	sub rsp, 32
	mov [rsp+24], r8
	mov [rsp+16], rax
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	call Button.height
	mov r8, [rsp+24]
	mov rax, [rsp+16]
	movsxd rcx, DWORD [rsp+0]
	add rsp, 32
	add rcx, 0xa
	movsxd rdx, DWORD [rsp+12]
	add rdx, 0x14
	mov rbx, [rbp+16]
	movsxd rsi, DWORD [rbx+4]
	sub rsp, 64
	mov [rsp+56], rcx
	mov [rsp+48], rsi
	mov [rsp+40], r8
	mov [rsp+32], rax
	mov [rsp+24], rdx
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	call Button.height
	mov rcx, [rsp+56]
	mov rsi, [rsp+48]
	mov r8, [rsp+40]
	mov rax, [rsp+32]
	mov rdx, [rsp+24]
	movsxd rbx, DWORD [rsp+0]
	add rsp, 64
	sar rbx, 1
	sub rsi, rbx
	sub rsi, 0x5
	mov rbx, [rbp+16]
	movsxd rdi, DWORD [rbx+0]
	movsxd rbx, DWORD [rsp+12]
	sar rbx, 1
	sub rdi, rbx
	sub rdi, 0xa
	call DrawRectangle
	lea rbx, [__GP_TMP]
	mov cl, 0xff
	mov [rbx+0], cl
	mov cl, 0xff
	mov [rbx+1], cl
	mov cl, 0xff
	mov [rbx+2], cl
	mov cl, 0xff
	mov [rbx+3], cl
	mov r8, QWORD [__GP_TMP+0]
	mov rbx, [rbp+16]
	movsxd rcx, DWORD [rbx+20]
	mov rbx, [rbp+16]
	movsxd rdx, DWORD [rbx+4]
	sub rsp, 48
	mov [rsp+40], rcx
	mov [rsp+32], r8
	mov [rsp+24], rax
	mov [rsp+16], rdx
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	call Button.height
	mov rcx, [rsp+40]
	mov r8, [rsp+32]
	mov rax, [rsp+24]
	mov rdx, [rsp+16]
	movsxd rbx, DWORD [rsp+0]
	add rsp, 48
	sar rbx, 1
	sub rdx, rbx
	mov rbx, [rbp+16]
	movsxd rsi, DWORD [rbx+0]
	movsxd rbx, DWORD [rsp+12]
	sar rbx, 1
	sub rsi, rbx
	mov rbx, [rbp+16]
	mov rdi, [rbx+8]
	call DrawText
	.L0:
	leave
	ret

global Button.update:function
Button.update:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, [rbp+16]
	xor cl, cl
	mov [rbx+24], cl
	mov rbx, [rbp+16]
	xor cl, cl
	mov [rbx+25], cl
	sub rsp, 16
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	call Button.width
	mov ebx, [rsp+0]
	add rsp, 16
	mov [rsp+12], ebx
	sub rsp, 16
	call GetMouseX
	mov [rsp+0], rax
	mov ebx, [rsp+0]
	add rsp, 16
	mov [rsp+4], ebx
	sub rsp, 16
	call GetMouseY
	mov [rsp+0], rax
	mov ebx, [rsp+0]
	add rsp, 16
	mov [rsp+8], ebx
	lea rbx, [rsp+4]
	xor rcx, rcx
	movsxd rsi, DWORD [rbx+rcx*4]
	mov rcx, [rbp+16]
	movsxd rbx, DWORD [rcx+0]
	movsxd rcx, DWORD [rsp+12]
	sar rcx, 1
	sub rbx, rcx
	sub rbx, 0xa
	cmp rsi, rbx
	setge bl
	test bl, bl
	je .L5
	lea rcx, [rsp+4]
	xor rsi, rsi
	movsxd rdi, DWORD [rcx+rsi*4]
	mov rsi, [rbp+16]
	movsxd rcx, DWORD [rsi+0]
	movsxd rsi, DWORD [rsp+12]
	sar rsi, 1
	add rcx, rsi
	add rcx, 0xa
	cmp rdi, rcx
	setle bl
	.L5:
	test bl, bl
	je .L4
	lea rcx, [rsp+4]
	mov rsi, 0x1
	movsxd rdi, DWORD [rcx+rsi*4]
	mov rsi, [rbp+16]
	movsxd rcx, DWORD [rsi+4]
	sub rsp, 48
	mov [rsp+47], bl
	mov [rsp+32], rcx
	mov [rsp+24], rdi
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	call Button.height
	mov bl, [rsp+47]
	mov rcx, [rsp+32]
	mov rdi, [rsp+24]
	movsxd rsi, DWORD [rsp+0]
	add rsp, 48
	sar rsi, 1
	sub rcx, rsi
	sub rcx, 0x5
	cmp rdi, rcx
	setge bl
	.L4:
	test bl, bl
	je .L3
	lea rcx, [rsp+4]
	mov rsi, 0x1
	movsxd rdi, DWORD [rcx+rsi*4]
	mov rsi, [rbp+16]
	movsxd rcx, DWORD [rsi+4]
	sub rsp, 48
	mov [rsp+47], bl
	mov [rsp+32], rcx
	mov [rsp+24], rdi
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	call Button.height
	mov bl, [rsp+47]
	mov rcx, [rsp+32]
	mov rdi, [rsp+24]
	movsxd rsi, DWORD [rsp+0]
	add rsp, 48
	sar rsi, 1
	add rcx, rsi
	add rcx, 0x5
	cmp rdi, rcx
	setle bl
	.L3:
	test bl, bl
	je .L1
	sub rsp, 16
	xor rdi, rdi
	call IsMouseButtonDown
	mov [rsp+0], rax
	mov bl, [rsp+0]
	add rsp, 16
	test bl, bl
	je .L6
	mov rbx, [rbp+16]
	mov cl, 0x1
	mov [rbx+25], cl
	.L6:
	.L7:
	mov rbx, [rbp+16]
	mov cl, 0x1
	mov [rbx+24], cl
	.L1:
	.L2:
	.L0:
	leave
	ret

global Missile.draw:function
Missile.draw:
	push rbp
	mov rbp, rsp
	mov rsi, [rbp+16]
	mov cl, [rsi+16]
	test cl, cl
	sete bl
	test bl, bl
	je .L1
	jmp .L0
	.L1:
	.L2:
	lea rbx, [__GP_TMP]
	mov cl, 0xe6
	mov [rbx+0], cl
	mov cl, 0x29
	mov [rbx+1], cl
	mov cl, 0x37
	mov [rbx+2], cl
	mov cl, 0xff
	mov [rbx+3], cl
	mov rdx, QWORD [__GP_TMP+0]
	cvtsd2ss xmm0, [FP1]
	mov rbx, [rbp+16]
	lea rbx, [rbx+0]
	movss xmm1, [rbx+4]
	cvttss2si rsi, xmm1
	mov rbx, [rbp+16]
	lea rbx, [rbx+0]
	movss xmm1, [rbx+0]
	cvttss2si rdi, xmm1
	call DrawCircleLines
	.L0:
	leave
	ret

global Missile.update:function
Missile.update:
	push rbp
	mov rbp, rsp
	mov rsi, [rbp+16]
	mov cl, [rsi+16]
	test cl, cl
	sete bl
	test bl, bl
	je .L1
	jmp .L0
	.L1:
	.L2:
	mov rbx, [rbp+16]
	sub rsp, 32
	mov [rsp+0], rbx
	mov [rsp+24], rbx
	mov rbx, [rbp+16]
	lea rbx, [rbx+0]
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	sub rsp, 32
	mov [rsp+0], rbx
	mov [rsp+24], rbx
	mov rbx, [rbp+16]
	lea rbx, [rbx+8]
	mov [rsp+8], rbx
	movss xmm0, [rbp+24]
	movss [rsp+16], xmm0
	call Vector2.__mul_float
	mov rbx, [rsp+24]
	add rsp, 32
	call Vector2.__add_Vector2
	mov rbx, [rsp+24]
	add rsp, 32
	mov rbx, 0x190
	cvtsi2sd xmm0, rbx
	sub rsp, 16
	movsd [rsp+8], xmm0
	mov rbx, [rbp+16]
	lea rbx, [rbx+0]
	movss xmm0, [rbx+0]
	call fabsf
	movss [rsp+0], xmm0
	movsd xmm0, [rsp+8]
	cvtss2sd xmm1, [rsp+0]
	add rsp, 16
	comisd xmm1, xmm0
	seta bl
	test bl, bl
	jne .L5
	mov rcx, 0x190
	cvtsi2sd xmm0, rcx
	sub rsp, 32
	mov [rsp+31], bl
	movsd [rsp+16], xmm0
	mov rbx, [rbp+16]
	lea rbx, [rbx+0]
	movss xmm0, [rbx+4]
	call fabsf
	movss [rsp+0], xmm0
	mov bl, [rsp+31]
	movsd xmm0, [rsp+16]
	cvtss2sd xmm1, [rsp+0]
	add rsp, 32
	comisd xmm1, xmm0
	seta bl
	.L5:
	test bl, bl
	je .L3
	mov rbx, [rbp+16]
	xor cl, cl
	mov [rbx+16], cl
	.L3:
	.L4:
	movsd xmm0, [FP1]
	sub rsp, 16
	movsd [rsp+8], xmm0
	call GetTime
	movsd [rsp+0], xmm0
	movsd xmm0, [rsp+8]
	movsd xmm1, [rsp+0]
	add rsp, 16
	mov rbx, [rbp+16]
	cvtss2sd xmm2, [rbx+20]
	subsd xmm1, xmm2
	comisd xmm1, xmm0
	seta bl
	test bl, bl
	je .L6
	mov rbx, [rbp+16]
	xor cl, cl
	mov [rbx+16], cl
	.L6:
	.L7:
	.L0:
	leave
	ret

global Missiles.init:function
Missiles.init:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	xor rbx, rbx
	mov [rsp+8], rbx
	.L1:
	mov rbx, [rsp+8]
	mov rcx, 0x10
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L3
	lea rcx, [Missiles+0]
	mov rsi, [rsp+8]
	lea rsi, [rsi+rsi*2]
	lea rbx, [rcx+rsi*8]
	xor cl, cl
	mov [rbx+16], cl
	.L2:
	mov rbx, [rsp+8]
	inc QWORD [rsp+8]
	jmp .L1
	.L3:
	add rsp, 16
	.L0:
	leave
	ret

global Missiles.new:function
Missiles.new:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	xor rbx, rbx
	mov [rsp+8], rbx
	.L1:
	mov rbx, [rsp+8]
	mov rcx, 0x10
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L3
	lea rdi, [Missiles+0]
	mov r8, [rsp+8]
	lea r8, [r8+r8*2]
	lea rsi, [rdi+r8*8]
	mov cl, [rsi+16]
	test cl, cl
	sete bl
	test bl, bl
	je .L4
	lea rbx, [Missiles+0]
	mov rcx, [rsp+8]
	lea rcx, [rcx+rcx*2]
	lea rbx, [rbx+rcx*8]
	lea r8, [rbx+0]
	mov rdi, [rbp+16]
	mov [r8], rdi
	lea r8, [rbx+8]
	mov rdi, [rbp+24]
	mov [r8], rdi
	mov cl, 0x1
	mov [rbx+16], cl
	sub rsp, 16
	mov [rsp+8], rbx
	call GetTime
	movsd [rsp+0], xmm0
	mov rbx, [rsp+8]
	cvtsd2ss xmm0, [rsp+0]
	add rsp, 16
	movss [rbx+20], xmm0
	jmp .L3
	.L4:
	.L5:
	.L2:
	mov rbx, [rsp+8]
	inc QWORD [rsp+8]
	jmp .L1
	.L3:
	add rsp, 16
	.L0:
	leave
	ret

global Missiles.draw:function
Missiles.draw:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	xor rbx, rbx
	mov [rsp+8], rbx
	.L1:
	mov rbx, [rsp+8]
	mov rcx, 0x10
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L3
	sub rsp, 16
	lea rcx, [Missiles+0]
	mov rsi, [rsp+24]
	lea rsi, [rsi+rsi*2]
	lea rbx, [rcx+rsi*8]
	mov [rsp+0], rbx
	call Missile.draw
	add rsp, 16
	.L2:
	mov rbx, [rsp+8]
	inc QWORD [rsp+8]
	jmp .L1
	.L3:
	add rsp, 16
	.L0:
	leave
	ret

global Missiles.update:function
Missiles.update:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	xor rbx, rbx
	mov [rsp+8], rbx
	.L1:
	mov rbx, [rsp+8]
	mov rcx, 0x10
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L3
	sub rsp, 16
	lea rcx, [Missiles+0]
	mov rsi, [rsp+24]
	lea rsi, [rsi+rsi*2]
	lea rbx, [rcx+rsi*8]
	mov [rsp+0], rbx
	movss xmm0, [rbp+16]
	movss [rsp+8], xmm0
	call Missile.update
	add rsp, 16
	.L2:
	mov rbx, [rsp+8]
	inc QWORD [rsp+8]
	jmp .L1
	.L3:
	add rsp, 16
	.L0:
	leave
	ret

global Spaceship.init:function
Spaceship.init:
	push rbp
	mov rbp, rsp
	lea rbx, [Spaceship+0]
	cvtsd2ss xmm0, [FP2]
	movss [rbx+0], xmm0
	cvtsd2ss xmm0, [FP2]
	movss [rbx+4], xmm0
	lea rbx, [Spaceship+8]
	cvtsd2ss xmm0, [FP2]
	movss [rbx+0], xmm0
	cvtsd2ss xmm0, [FP2]
	movss [rbx+4], xmm0
	cvtsd2ss xmm0, [FP2]
	movss [Spaceship+16], xmm0
	cvtsd2ss xmm0, [FP2]
	movss [Spaceship+20], xmm0
	movsd xmm0, [FP2]
	movsd [Spaceship+32], xmm0
	mov rbx, 0x64
	mov [Spaceship+40], rbx
	.L0:
	leave
	ret

global Spaceship.shoot:function
Spaceship.shoot:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	sub rsp, 16
	call GetTime
	movsd [rsp+0], xmm0
	movsd xmm0, [rsp+0]
	add rsp, 16
	movsd [rsp+8], xmm0
	movsd xmm0, [FP3]
	movsd xmm1, [rsp+8]
	movsd xmm2, [Spaceship+32]
	subsd xmm1, xmm2
	comisd xmm1, xmm0
	setae bl
	test bl, bl
	je .L1
	sub rsp, 16
	lea rbx, [rsp+8]
	sub rsp, 16
	lea rcx, [rsp+0]
	sub rsp, 16
	mov [rsp+8], rcx
	mov [rsp+0], rbx
	movss xmm0, [Spaceship+16]
	movss xmm1, xmm0
	lea rbx, [__GP_TMP]
	cvtsd2ss xmm0, [FP2]
	movss [rbx+0], xmm0
	cvtsd2ss xmm0, [FP4]
	movss [rbx+4], xmm0
	movsd xmm0, [__GP_TMP]
	call Vector2Rotate
	mov rcx, [rsp+0]
	mov rcx, [rsp+8]
	movsd [rcx], xmm0
	mov rbx, [rsp+0]
	add rsp, 16
	sub rsp, 32
	mov [rsp+0], rbx
	mov [rsp+24], rbx
	lea rbx, [rsp+32]
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	lea r8, [Spaceship+8]
	mov rdi, [r8]
	mov [rbx], rdi
	call Vector2.__add_Vector2
	mov rbx, [rsp+24]
	add rsp, 48
	lea rbx, [rsp+0]
	sub rsp, 32
	mov [rsp+0], rbx
	mov [rsp+24], rbx
	lea rbx, [Spaceship+0]
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	sub rsp, 16
	lea rcx, [rsp+0]
	sub rsp, 32
	mov [rsp+0], rcx
	mov [rsp+24], rbx
	mov [rsp+16], rcx
	lea rbx, [rsp+88]
	mov [rsp+8], rbx
	call Vector2.normalized
	mov rbx, [rsp+24]
	mov rcx, [rsp+16]
	add rsp, 32
	sub rsp, 32
	mov [rsp+0], rbx
	mov [rsp+24], rbx
	lea rbx, [rsp+32]
	mov [rsp+8], rbx
	cvtsd2ss xmm0, [FP5]
	movss [rsp+16], xmm0
	call Vector2.__mul_float
	mov rbx, [rsp+24]
	add rsp, 48
	call Vector2.__add_Vector2
	mov rbx, [rsp+24]
	add rsp, 32
	sub rsp, 16
	lea rbx, [rsp+0]
	mov rdi, [rsp+16]
	mov [rbx], rdi
	lea rbx, [rsp+8]
	mov rdi, [rsp+24]
	mov [rbx], rdi
	call Missiles.new
	add rsp, 16
	movsd xmm0, [rsp+24]
	movsd [Spaceship+32], xmm0
	add rsp, 16
	.L1:
	.L2:
	.L0:
	leave
	ret

global Spaceship.damage:function
Spaceship.damage:
	push rbp
	mov rbp, rsp
	lea rbx, [Spaceship+8]
	sub rsp, 32
	mov [rsp+0], rbx
	mov [rsp+24], rbx
	lea rbx, [Spaceship+0]
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	mov rdi, [rbp+16]
	mov [rbx], rdi
	call Vector2.__sub_Vector2
	mov rbx, [rsp+24]
	add rsp, 32
	mov rbx, QWORD [Spaceship+40]
	sub rbx, 0xa
	mov [Spaceship+40], rbx
	mov rbx, QWORD [Spaceship+40]
	xor rcx, rcx
	cmp rbx, rcx
	setle bl
	test bl, bl
	je .L1
	mov rbx, 0x2
	mov [Game+0], rbx
	.L1:
	.L2:
	.L0:
	leave
	ret

global Spaceship.draw:function
Spaceship.draw:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	lea rbx, [rsp+24]
	sub rsp, 16
	lea rcx, [rsp+0]
	sub rsp, 16
	mov [rsp+8], rcx
	mov [rsp+0], rbx
	movss xmm0, [Spaceship+16]
	movss xmm1, xmm0
	lea rbx, [__GP_TMP]
	cvtsd2ss xmm0, [FP6]
	movss [rbx+0], xmm0
	cvtsd2ss xmm0, [FP5]
	movss [rbx+4], xmm0
	movsd xmm0, [__GP_TMP]
	call Vector2Rotate
	mov rcx, [rsp+0]
	mov rcx, [rsp+8]
	movsd [rcx], xmm0
	mov rbx, [rsp+0]
	add rsp, 16
	sub rsp, 32
	mov [rsp+0], rbx
	mov [rsp+24], rbx
	lea rbx, [rsp+32]
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	lea r8, [Spaceship+0]
	mov rdi, [r8]
	mov [rbx], rdi
	call Vector2.__add_Vector2
	mov rbx, [rsp+24]
	add rsp, 48
	lea rbx, [rsp+16]
	sub rsp, 16
	lea rcx, [rsp+0]
	sub rsp, 16
	mov [rsp+8], rcx
	mov [rsp+0], rbx
	movss xmm0, [Spaceship+16]
	movss xmm1, xmm0
	lea rbx, [__GP_TMP]
	cvtsd2ss xmm0, [FP2]
	movss [rbx+0], xmm0
	cvtsd2ss xmm0, [FP7]
	movss [rbx+4], xmm0
	movsd xmm0, [__GP_TMP]
	call Vector2Rotate
	mov rcx, [rsp+0]
	mov rcx, [rsp+8]
	movsd [rcx], xmm0
	mov rbx, [rsp+0]
	add rsp, 16
	sub rsp, 32
	mov [rsp+0], rbx
	mov [rsp+24], rbx
	lea rbx, [rsp+32]
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	lea r8, [Spaceship+0]
	mov rdi, [r8]
	mov [rbx], rdi
	call Vector2.__add_Vector2
	mov rbx, [rsp+24]
	add rsp, 48
	lea rbx, [rsp+8]
	sub rsp, 16
	lea rcx, [rsp+0]
	sub rsp, 16
	mov [rsp+8], rcx
	mov [rsp+0], rbx
	movss xmm0, [Spaceship+16]
	movss xmm1, xmm0
	lea rbx, [__GP_TMP]
	cvtsd2ss xmm0, [FP8]
	movss [rbx+0], xmm0
	cvtsd2ss xmm0, [FP5]
	movss [rbx+4], xmm0
	movsd xmm0, [__GP_TMP]
	call Vector2Rotate
	mov rcx, [rsp+0]
	mov rcx, [rsp+8]
	movsd [rcx], xmm0
	mov rbx, [rsp+0]
	add rsp, 16
	sub rsp, 32
	mov [rsp+0], rbx
	mov [rsp+24], rbx
	lea rbx, [rsp+32]
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	lea r8, [Spaceship+0]
	mov rdi, [r8]
	mov [rbx], rdi
	call Vector2.__add_Vector2
	mov rbx, [rsp+24]
	add rsp, 48
	lea rbx, [__GP_TMP]
	mov cl, 0xf5
	mov [rbx+0], cl
	mov cl, 0xf5
	mov [rbx+1], cl
	mov cl, 0xf5
	mov [rbx+2], cl
	mov cl, 0xff
	mov [rbx+3], cl
	mov rdi, QWORD [__GP_TMP+0]
	lea rbx, [__GP_TMP]
	mov r8, rdi
	mov rdi, [rsp+8]
	mov [rbx], rdi
	mov rdi, r8
	movsd xmm2, [__GP_TMP]
	lea rbx, [__GP_TMP]
	mov r8, rdi
	mov rdi, [rsp+16]
	mov [rbx], rdi
	mov rdi, r8
	movsd xmm1, [__GP_TMP]
	lea rbx, [__GP_TMP]
	mov r8, rdi
	mov rdi, [rsp+24]
	mov [rbx], rdi
	mov rdi, r8
	movsd xmm0, [__GP_TMP]
	call DrawTriangleLines
	mov rbx, 0x1
	test rbx, rbx
	je .L1
	lea rbx, [__GP_TMP]
	mov cl, 0xe6
	mov [rbx+0], cl
	mov cl, 0x29
	mov [rbx+1], cl
	mov cl, 0x37
	mov [rbx+2], cl
	mov cl, 0xff
	mov [rbx+3], cl
	mov rdx, QWORD [__GP_TMP+0]
	cvtsd2ss xmm0, [FP9]
	lea rbx, [Spaceship+24]
	movss xmm1, [rbx+4]
	cvttss2si rsi, xmm1
	lea rbx, [Spaceship+24]
	movss xmm1, [rbx+0]
	cvttss2si rdi, xmm1
	call DrawCircleLines
	.L1:
	.L2:
	.L0:
	leave
	ret

global Spaceship.update:function
Spaceship.update:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	sub rsp, 16
	mov rdi, 0x20
	call IsKeyDown
	mov [rsp+0], rax
	mov bl, [rsp+0]
	add rsp, 16
	test bl, bl
	je .L1
	call Spaceship.shoot
	.L1:
	.L2:
	sub rsp, 16
	mov rdi, 0x57
	call IsKeyDown
	mov [rsp+0], rax
	movzx rbx, BYTE [rsp+0]
	add rsp, 16
	sub rsp, 16
	mov [rsp+8], rbx
	mov rdi, 0x53
	call IsKeyDown
	mov [rsp+0], rax
	mov rbx, [rsp+8]
	movzx rcx, BYTE [rsp+0]
	add rsp, 16
	sub rbx, rcx
	cvtsi2ss xmm0, rbx
	movss [rsp+12], xmm0
	lea rbx, [Spaceship+8]
	sub rsp, 32
	mov [rsp+0], rbx
	mov [rsp+24], rbx
	lea rbx, [Spaceship+8]
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	movss xmm0, [Spaceship+16]
	movss xmm1, xmm0
	lea rbx, [__GP_TMP]
	cvtsd2ss xmm0, [FP2]
	movss [rbx+0], xmm0
	cvtsd2ss xmm0, [FP10]
	movss xmm2, [rbp+16]
	mulss xmm0, xmm2
	movss xmm2, [rsp+60]
	mulss xmm0, xmm2
	movss [rbx+4], xmm0
	movsd xmm0, [__GP_TMP]
	call Vector2Rotate
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	add rsp, 16
	call Vector2.__add_Vector2
	mov rbx, [rsp+24]
	add rsp, 32
	movss xmm0, [Spaceship+20]
	sub rsp, 16
	movss [rsp+12], xmm0
	mov rdi, 0x44
	call IsKeyDown
	mov [rsp+0], rax
	movss xmm0, [rsp+12]
	movzx rbx, BYTE [rsp+0]
	add rsp, 16
	sub rsp, 32
	mov [rsp+24], rbx
	movss [rsp+20], xmm0
	mov rdi, 0x41
	call IsKeyDown
	mov [rsp+0], rax
	mov rbx, [rsp+24]
	movss xmm0, [rsp+20]
	movzx rcx, BYTE [rsp+0]
	add rsp, 32
	sub rbx, rcx
	cvtsi2ss xmm1, rbx
	cvtsd2ss xmm2, [FP11]
	mulss xmm1, xmm2
	movss xmm2, [rbp+16]
	mulss xmm1, xmm2
	addss xmm0, xmm1
	movss [Spaceship+20], xmm0
	lea rbx, [Spaceship+0]
	sub rsp, 32
	mov [rsp+0], rbx
	mov [rsp+24], rbx
	lea rbx, [Spaceship+0]
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	sub rsp, 32
	mov [rsp+0], rbx
	mov [rsp+24], rbx
	lea rbx, [Spaceship+8]
	mov [rsp+8], rbx
	movss xmm0, [rbp+16]
	movss [rsp+16], xmm0
	call Vector2.__mul_float
	mov rbx, [rsp+24]
	add rsp, 32
	call Vector2.__add_Vector2
	mov rbx, [rsp+24]
	add rsp, 32
	movss xmm0, [Spaceship+16]
	movss xmm1, [Spaceship+20]
	movss xmm2, [rbp+16]
	mulss xmm1, xmm2
	addss xmm0, xmm1
	movss [Spaceship+16], xmm0
	lea rbx, [Spaceship+24]
	sub rsp, 16
	lea rcx, [rsp+0]
	sub rsp, 16
	mov [rsp+8], rcx
	mov [rsp+0], rbx
	movss xmm0, [Spaceship+16]
	movss xmm1, xmm0
	lea rbx, [__GP_TMP]
	cvtsd2ss xmm0, [FP2]
	movss [rbx+0], xmm0
	cvtsd2ss xmm0, [FP12]
	movss [rbx+4], xmm0
	movsd xmm0, [__GP_TMP]
	call Vector2Rotate
	mov rcx, [rsp+0]
	mov rcx, [rsp+8]
	movsd [rcx], xmm0
	mov rbx, [rsp+0]
	add rsp, 16
	sub rsp, 32
	mov [rsp+0], rbx
	mov [rsp+24], rbx
	lea rbx, [rsp+32]
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	lea r8, [Spaceship+0]
	mov rdi, [r8]
	mov [rbx], rdi
	call Vector2.__add_Vector2
	mov rbx, [rsp+24]
	add rsp, 48
	mov rbx, 0xfffffffffffffe70
	cvtsi2sd xmm0, rbx
	lea rbx, [Spaceship+0]
	cvtss2sd xmm1, [rbx+0]
	comisd xmm1, xmm0
	setb bl
	test bl, bl
	je .L3
	lea rbx, [Spaceship+0]
	mov rcx, 0x190
	cvtsi2ss xmm0, rcx
	movss [rbx+0], xmm0
	jmp .L4
	.L3:
	mov rbx, 0x190
	cvtsi2sd xmm0, rbx
	lea rbx, [Spaceship+0]
	cvtss2sd xmm1, [rbx+0]
	comisd xmm1, xmm0
	seta bl
	test bl, bl
	je .L5
	lea rbx, [Spaceship+0]
	mov rcx, 0xfffffffffffffe70
	cvtsi2ss xmm0, rcx
	movss [rbx+0], xmm0
	jmp .L4
	.L5:
	.L4:
	mov rbx, 0xfffffffffffffe70
	cvtsi2sd xmm0, rbx
	lea rbx, [Spaceship+0]
	cvtss2sd xmm1, [rbx+4]
	comisd xmm1, xmm0
	setb bl
	test bl, bl
	je .L6
	lea rbx, [Spaceship+0]
	mov rcx, 0x190
	cvtsi2ss xmm0, rcx
	movss [rbx+4], xmm0
	jmp .L7
	.L6:
	mov rbx, 0x190
	cvtsi2sd xmm0, rbx
	lea rbx, [Spaceship+0]
	cvtss2sd xmm1, [rbx+4]
	comisd xmm1, xmm0
	seta bl
	test bl, bl
	je .L8
	lea rbx, [Spaceship+0]
	mov rcx, 0xfffffffffffffe70
	cvtsi2ss xmm0, rcx
	movss [rbx+4], xmm0
	jmp .L7
	.L8:
	.L7:
	.L0:
	leave
	ret

global Asteroids.init:function
Asteroids.init:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	xor rbx, rbx
	mov [rsp+8], rbx
	.L1:
	mov rbx, [rsp+8]
	mov rcx, 0x10
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L3
	lea rcx, [Asteroids+0]
	mov rsi, [rsp+8]
	mov rdi, rsi
	shl rsi, 5
	lea rsi, [rsi + rdi*8]
	lea rsi, [rsi + rdi*4]
	add rsi, rdi
	lea rbx, [rcx+rsi*4]
	xor cl, cl
	mov [rbx+174], cl
	.L2:
	mov rbx, [rsp+8]
	inc QWORD [rsp+8]
	jmp .L1
	.L3:
	add rsp, 16
	sub rsp, 16
	call GetTime
	movsd [rsp+0], xmm0
	movsd xmm0, [rsp+0]
	add rsp, 16
	movsd [Asteroids+2880], xmm0
	mov rbx, QWORD [Game+0]
	mov rcx, 0x1
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L4
	movsd xmm0, [FP0]
	jmp .L5
	.L4:
	movsd xmm0, [FP0]
	.L5:
	movsd [Asteroids+2888], xmm0
	.L0:
	leave
	ret

global Asteroids.new:function
Asteroids.new:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	call rand
	mov [rsp+0], rax
	mov rbx, [rsp+8]
	mov rax, [rsp+0]
	add rsp, 16
	mov rcx, 0x32
	xor rdx, rdx
	idiv rcx
	mov rax, rdx
	add rax, 0x19
	mov [rbx+176], eax
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	call rand
	mov [rsp+0], rax
	mov rbx, [rsp+8]
	mov ax, [rsp+0]
	add rsp, 16
	mov cx, 0xa
	xor rdx, rdx
	div cx
	mov ax, dx
	add ax, 0x6
	mov [rbx+172], ax
	cvtsd2ss xmm0, [FP13]
	mov rcx, [rbp+16]
	movzx rbx, WORD [rcx+172]
	cvtsi2ss xmm1, rbx
	divss xmm0, xmm1
	movss [rsp+12], xmm0
	sub rsp, 16
	xor rbx, rbx
	mov [rsp+8], rbx
	.L1:
	mov rbx, [rsp+8]
	mov rsi, [rbp+16]
	movzx rcx, WORD [rsi+172]
	cmp rbx, rcx
	setb bl
	test bl, bl
	je .L3
	mov rcx, [rbp+16]
	lea rbx, [rcx+44]
	mov rcx, [rsp+8]
	lea rbx, [rbx+rcx*8]
	sub rsp, 16
	mov [rsp+8], rbx
	movss xmm0, [rsp+44]
	mov rbx, [rsp+24]
	cvtsi2ss xmm1, rbx
	mulss xmm0, xmm1
	movss xmm1, xmm0
	lea rbx, [__GP_TMP]
	sub rsp, 16
	lea rcx, [rsp+0]
	cvtsd2ss xmm0, [FP2]
	movss [rcx+0], xmm0
	cvtsd2ss xmm0, [FP14]
	movss [rcx+4], xmm0
	sub rsp, 48
	mov [rsp+0], rbx
	mov [rsp+40], rbx
	mov [rsp+32], rax
	movss [rsp+28], xmm1
	lea rbx, [rsp+48]
	mov [rsp+8], rbx
	sub rsp, 16
	call rand
	mov [rsp+0], rax
	mov rax, [rsp+0]
	add rsp, 16
	mov rbx, 0xa
	xor rdx, rdx
	idiv rbx
	mov rax, rdx
	mov rcx, [rbp+16]
	mov ebx, DWORD [rcx+176]
	add rax, rbx
	cvtsi2ss xmm0, rax
	movss [rsp+16], xmm0
	call Vector2.__mul_int
	mov rbx, [rsp+40]
	mov rax, [rsp+32]
	movss xmm1, [rsp+28]
	add rsp, 64
	movsd xmm0, [__GP_TMP]
	call Vector2Rotate
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	add rsp, 16
	.L2:
	mov rbx, [rsp+8]
	inc QWORD [rsp+8]
	jmp .L1
	.L3:
	add rsp, 16
	sub rsp, 16
	call rand
	mov [rsp+0], rax
	mov rbx, [rsp+0]
	add rsp, 16
	and rbx, 0x3
	mov [rsp+0], rbx
	mov rbx, [rsp+0]
	mov rcx, 0x1
	cmp rbx, rcx
	setle bl
	test bl, bl
	je .L4
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	call rand
	mov [rsp+0], rax
	mov rbx, [rsp+8]
	mov rax, [rsp+0]
	add rsp, 16
	mov rcx, 0x320
	xor rdx, rdx
	idiv rcx
	mov rax, rdx
	sub rax, 0x190
	cvtsi2ss xmm0, rax
	movss [rbx+0], xmm0
	mov rsi, [rsp+0]
	xor rdi, rdi
	cmp rsi, rdi
	sete sil
	test sil, sil
	je .L6
	mov rsi, [rbp+16]
	mov ecx, DWORD [rsi+176]
	neg rcx
	add rcx, 0xfffffffffffffe70
	jmp .L7
	.L6:
	mov rsi, [rbp+16]
	mov ecx, DWORD [rsi+176]
	add rcx, 0x190
	.L7:
	cvtsi2ss xmm0, rcx
	movss [rbx+4], xmm0
	jmp .L5
	.L4:
	mov rbx, [rbp+16]
	mov rsi, [rsp+0]
	mov rdi, 0x2
	cmp rsi, rdi
	sete sil
	test sil, sil
	je .L8
	mov rsi, [rbp+16]
	mov ecx, DWORD [rsi+176]
	neg rcx
	add rcx, 0xfffffffffffffe70
	jmp .L9
	.L8:
	mov rsi, [rbp+16]
	mov ecx, DWORD [rsi+176]
	add rcx, 0x190
	.L9:
	cvtsi2ss xmm0, rcx
	movss [rbx+0], xmm0
	sub rsp, 16
	mov [rsp+8], rbx
	call rand
	mov [rsp+0], rax
	mov rbx, [rsp+8]
	mov rax, [rsp+0]
	add rsp, 16
	mov rcx, 0x320
	xor rdx, rdx
	idiv rcx
	mov rax, rdx
	sub rax, 0x190
	cvtsi2ss xmm0, rax
	movss [rbx+4], xmm0
	.L5:
	mov rbx, [rbp+16]
	lea rbx, [rbx+8]
	sub rsp, 16
	lea rcx, [rsp+0]
	sub rsp, 16
	mov [rsp+8], rcx
	mov [rsp+0], rbx
	sub rsp, 16
	mov [rsp+8], rax
	call rand
	mov [rsp+0], rax
	mov rax, [rsp+8]
	mov rbx, [rsp+0]
	add rsp, 16
	mov rcx, 0x1e
	mov rsi, rax
	mov rax, rbx
	xor rdx, rdx
	idiv rcx
	mov rax, rdx
	mov rbx, rax
	mov rax, rsi
	sub rbx, 0xf
	cvtsi2ss xmm0, rbx
	cvtsd2ss xmm1, [FP15]
	mulss xmm0, xmm1
	movss xmm1, xmm0
	lea rbx, [__GP_TMP]
	sub rsp, 48
	mov [rsp+0], rbx
	mov [rsp+40], rbx
	mov [rsp+32], rax
	movss [rsp+28], xmm1
	mov rbx, [rbp+16]
	lea rbx, [rbx+0]
	mov [rsp+8], rbx
	call Vector2.normalized
	mov rbx, [rsp+40]
	mov rax, [rsp+32]
	movss xmm1, [rsp+28]
	add rsp, 48
	movsd xmm0, [__GP_TMP]
	call Vector2Rotate
	mov rcx, [rsp+0]
	mov rcx, [rsp+8]
	movsd [rcx], xmm0
	mov rbx, [rsp+0]
	add rsp, 16
	sub rsp, 32
	mov [rsp+0], rbx
	mov [rsp+24], rbx
	lea rbx, [rsp+32]
	mov [rsp+8], rbx
	sub rsp, 16
	call rand
	mov [rsp+0], rax
	mov rax, [rsp+0]
	add rsp, 16
	mov rbx, 0x32
	xor rdx, rdx
	idiv rbx
	mov rax, rdx
	add rax, 0x32
	neg rax
	cvtsi2ss xmm0, rax
	movss [rsp+16], xmm0
	call Vector2.__mul_int
	mov rbx, [rsp+24]
	add rsp, 48
	mov rbx, [rbp+16]
	lea rbx, [rbx+16]
	sub rsp, 16
	mov [rsp+8], rbx
	call Vector2Zero
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	add rsp, 16
	mov rbx, [rbp+16]
	lea rbx, [rbx+24]
	sub rsp, 16
	mov [rsp+8], rbx
	call Vector2Zero
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	add rsp, 16
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	call rand
	mov [rsp+0], rax
	mov rbx, [rsp+8]
	mov rax, [rsp+0]
	add rsp, 16
	mov rcx, 0x168
	xor rdx, rdx
	idiv rcx
	mov rax, rdx
	cvtsi2ss xmm0, rax
	cvtsd2ss xmm1, [FP15]
	mulss xmm0, xmm1
	movss [rbx+32], xmm0
	mov rbx, [rbp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	call rand
	mov [rsp+0], rax
	mov rbx, [rsp+8]
	mov rax, [rsp+0]
	add rsp, 16
	mov rcx, 0x168
	xor rdx, rdx
	idiv rcx
	mov rax, rdx
	sub rax, 0xb4
	cvtsi2ss xmm0, rax
	cvtsd2ss xmm1, [FP15]
	mulss xmm0, xmm1
	movss [rbx+36], xmm0
	mov rbx, [rbp+16]
	cvtsd2ss xmm0, [FP2]
	movss [rbx+40], xmm0
	mov rbx, [rbp+16]
	mov cl, 0x1
	mov [rbx+174], cl
	.L0:
	leave
	ret

global Asteroids.spawn:function
Asteroids.spawn:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	xor rbx, rbx
	mov [rsp+8], rbx
	.L1:
	mov rbx, [rsp+8]
	mov rcx, 0x10
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L3
	lea rdi, [Asteroids+0]
	mov r8, [rsp+8]
	mov r9, r8
	shl r8, 5
	lea r8, [r8 + r9*8]
	lea r8, [r8 + r9*4]
	add r8, r9
	lea rsi, [rdi+r8*4]
	mov cl, [rsi+174]
	test cl, cl
	sete bl
	test bl, bl
	je .L4
	lea rbx, [Asteroids+0]
	mov rcx, [rsp+8]
	mov rsi, rcx
	shl rcx, 5
	lea rcx, [rcx + rsi*8]
	lea rcx, [rcx + rsi*4]
	add rcx, rsi
	lea rbx, [rbx+rcx*4]
	sub rsp, 16
	mov [rsp+0], rbx
	mov [rsp+8], rbx
	call Asteroids.new
	mov rbx, [rsp+8]
	add rsp, 16
	jmp .L3
	.L4:
	.L5:
	.L2:
	mov rbx, [rsp+8]
	inc QWORD [rsp+8]
	jmp .L1
	.L3:
	add rsp, 16
	.L0:
	leave
	ret

global Asteroids.draw:function
Asteroids.draw:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	xor rbx, rbx
	mov [rsp+8], rbx
	.L1:
	mov rbx, [rsp+8]
	mov rcx, 0x10
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L3
	sub rsp, 16
	lea rcx, [Asteroids+0]
	mov rsi, [rsp+24]
	mov rdi, rsi
	shl rsi, 5
	lea rsi, [rsi + rdi*8]
	lea rsi, [rsi + rdi*4]
	add rsi, rdi
	lea rbx, [rcx+rsi*4]
	mov [rsp+0], rbx
	call Asteroid.draw
	add rsp, 16
	.L2:
	mov rbx, [rsp+8]
	inc QWORD [rsp+8]
	jmp .L1
	.L3:
	add rsp, 16
	.L0:
	leave
	ret

global Asteroids.update:function
Asteroids.update:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	sub rsp, 16
	call GetTime
	movsd [rsp+0], xmm0
	movsd xmm0, [rsp+0]
	add rsp, 16
	movsd [rsp+8], xmm0
	movsd xmm0, [Asteroids+2888]
	movsd xmm1, [rsp+8]
	movsd xmm2, [Asteroids+2880]
	subsd xmm1, xmm2
	comisd xmm1, xmm0
	seta bl
	test bl, bl
	je .L1
	call Asteroids.spawn
	movsd xmm0, [rsp+8]
	movsd [Asteroids+2880], xmm0
	mov rbx, QWORD [Game+0]
	mov rcx, 0x1
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L3
	sub rsp, 16
	movsd xmm0, [FP16]
	movsd xmm1, xmm0
	movsd xmm0, [Asteroids+2888]
	movsd xmm2, [FP17]
	mulsd xmm0, xmm2
	call fmax
	movsd [rsp+0], xmm0
	movsd xmm0, [rsp+0]
	add rsp, 16
	movsd [Asteroids+2888], xmm0
	.L3:
	.L4:
	.L1:
	.L2:
	sub rsp, 16
	xor rbx, rbx
	mov [rsp+8], rbx
	.L5:
	mov rbx, [rsp+8]
	mov rcx, 0x10
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L7
	sub rsp, 16
	lea rcx, [Asteroids+0]
	mov rsi, [rsp+24]
	mov rdi, rsi
	shl rsi, 5
	lea rsi, [rsi + rdi*8]
	lea rsi, [rsi + rdi*4]
	add rsi, rdi
	lea rbx, [rcx+rsi*4]
	mov [rsp+0], rbx
	movss xmm0, [rbp+16]
	movss [rsp+8], xmm0
	call Asteroid.update
	add rsp, 16
	.L6:
	mov rbx, [rsp+8]
	inc QWORD [rsp+8]
	jmp .L5
	.L7:
	add rsp, 16
	.L0:
	leave
	ret

global Asteroid.colliding_with:function
Asteroid.colliding_with:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	movss xmm0, [rbp+40]
	movss xmm3, xmm0
	lea rbx, [__GP_TMP]
	mov rdi, [rbp+32]
	mov [rbx], rdi
	movsd xmm2, [__GP_TMP]
	mov rcx, [rbp+24]
	mov ebx, DWORD [rcx+176]
	cvtsi2ss xmm0, rbx
	movss xmm1, xmm0
	lea rbx, [__GP_TMP]
	mov r8, [rbp+24]
	lea r8, [r8+0]
	mov rdi, [r8]
	mov [rbx], rdi
	movsd xmm0, [__GP_TMP]
	call CheckCollisionCircles
	mov [rsp+0], rax
	mov bl, [rsp+0]
	add rsp, 16
	mov [rbp+16], bl
	jmp .L0
	.L0:
	leave
	ret

global Asteroid.draw:function
Asteroid.draw:
	push rbp
	mov rbp, rsp
	sub rsp, 144
	mov rsi, [rbp+16]
	mov cl, [rsi+174]
	test cl, cl
	sete bl
	test bl, bl
	je .L1
	jmp .L0
	.L1:
	.L2:
	sub rsp, 16
	xor rbx, rbx
	mov [rsp+8], rbx
	.L3:
	mov rbx, [rsp+8]
	mov rsi, [rbp+16]
	movzx rcx, WORD [rsi+172]
	cmp rbx, rcx
	setb bl
	test bl, bl
	je .L5
	lea rbx, [rsp+0]
	mov rsi, [rbp+16]
	lea rcx, [rsi+44]
	mov rsi, [rsp+8]
	mov rdi, [rcx+rsi*8]
	mov [rbx], rdi
	lea rbx, [rsp+24]
	mov rcx, [rsp+8]
	lea rbx, [rbx+rcx*8]
	sub rsp, 16
	lea rcx, [rsp+0]
	sub rsp, 16
	mov [rsp+8], rcx
	mov [rsp+0], rbx
	mov rbx, [rbp+16]
	movss xmm0, [rbx+32]
	movss xmm1, xmm0
	lea rbx, [__GP_TMP]
	mov rdi, [rsp+32]
	mov [rbx], rdi
	movsd xmm0, [__GP_TMP]
	call Vector2Rotate
	mov rcx, [rsp+0]
	mov rcx, [rsp+8]
	movsd [rcx], xmm0
	mov rbx, [rsp+0]
	add rsp, 16
	sub rsp, 32
	mov [rsp+0], rbx
	mov [rsp+24], rbx
	lea rbx, [rsp+32]
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	mov r8, [rbp+16]
	lea r8, [r8+0]
	mov rdi, [r8]
	mov [rbx], rdi
	call Vector2.__add_Vector2
	mov rbx, [rsp+24]
	add rsp, 48
	.L4:
	mov rbx, [rsp+8]
	inc QWORD [rsp+8]
	jmp .L3
	.L5:
	add rsp, 16
	lea rbx, [rsp+8]
	mov rsi, [rbp+16]
	movzx rcx, WORD [rsi+172]
	lea rbx, [rbx+rcx*8]
	lea rcx, [rsp+8]
	xor rsi, rsi
	mov rdi, [rcx+rsi*8]
	mov [rbx], rdi
	lea rbx, [__GP_TMP]
	mov cl, 0xff
	mov [rbx+0], cl
	mov cl, 0xff
	mov [rbx+1], cl
	mov cl, 0xff
	mov [rbx+2], cl
	mov cl, 0xff
	mov [rbx+3], cl
	mov rdx, QWORD [__GP_TMP+0]
	mov rbx, [rbp+16]
	movzx rsi, WORD [rbx+172]
	inc rsi
	lea rdi, [rsp+8]
	call DrawLineStrip
	mov rbx, 0x1
	test rbx, rbx
	je .L6
	lea rbx, [__GP_TMP]
	mov cl, 0xe6
	mov [rbx+0], cl
	mov cl, 0x29
	mov [rbx+1], cl
	mov cl, 0x37
	mov [rbx+2], cl
	mov cl, 0xff
	mov [rbx+3], cl
	mov rdx, QWORD [__GP_TMP+0]
	mov rcx, [rbp+16]
	mov ebx, DWORD [rcx+176]
	cvtsi2ss xmm0, rbx
	mov rbx, [rbp+16]
	lea rbx, [rbx+0]
	movss xmm1, [rbx+4]
	cvttss2si rsi, xmm1
	mov rbx, [rbp+16]
	lea rbx, [rbx+0]
	movss xmm1, [rbx+0]
	cvttss2si rdi, xmm1
	call DrawCircleLines
	.L6:
	.L7:
	.L0:
	leave
	ret

global Asteroid.update:function
Asteroid.update:
	push rbp
	mov rbp, rsp
	mov rsi, [rbp+16]
	mov cl, [rsi+174]
	test cl, cl
	sete bl
	test bl, bl
	je .L1
	jmp .L0
	.L1:
	.L2:
	mov rbx, [rbp+16]
	lea rbx, [rbx+8]
	sub rsp, 32
	mov [rsp+0], rbx
	mov [rsp+24], rbx
	mov rbx, [rbp+16]
	lea rbx, [rbx+8]
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	mov r8, [rbp+16]
	lea r8, [r8+16]
	mov rdi, [r8]
	mov [rbx], rdi
	call Vector2.__add_Vector2
	mov rbx, [rsp+24]
	add rsp, 32
	mov rbx, [rbp+16]
	mov rcx, [rbp+16]
	movss xmm0, [rcx+36]
	mov rcx, [rbp+16]
	movss xmm1, [rcx+40]
	addss xmm0, xmm1
	movss [rbx+36], xmm0
	mov rbx, [rbp+16]
	lea rbx, [rbx+16]
	sub rsp, 16
	mov [rsp+8], rbx
	call Vector2Zero
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	add rsp, 16
	mov rbx, [rbp+16]
	cvtsd2ss xmm0, [FP2]
	movss [rbx+40], xmm0
	mov rbx, [rbp+16]
	sub rsp, 32
	mov [rsp+0], rbx
	mov [rsp+24], rbx
	mov rbx, [rbp+16]
	lea rbx, [rbx+0]
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	sub rsp, 16
	lea rcx, [rsp+0]
	sub rsp, 48
	mov [rsp+0], rcx
	mov [rsp+40], rbx
	mov [rsp+32], rcx
	mov rbx, [rbp+16]
	lea rbx, [rbx+8]
	mov [rsp+8], rbx
	movss xmm0, [rbp+24]
	movss [rsp+16], xmm0
	call Vector2.__mul_float
	mov rbx, [rsp+40]
	mov rcx, [rsp+32]
	add rsp, 48
	sub rsp, 32
	mov [rsp+0], rbx
	mov [rsp+24], rbx
	lea rbx, [rsp+32]
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	mov r8, [rbp+16]
	lea r8, [r8+24]
	mov rdi, [r8]
	mov [rbx], rdi
	call Vector2.__add_Vector2
	mov rbx, [rsp+24]
	add rsp, 48
	call Vector2.__add_Vector2
	mov rbx, [rsp+24]
	add rsp, 32
	mov rbx, [rbp+16]
	mov rcx, [rbp+16]
	movss xmm0, [rcx+32]
	mov rcx, [rbp+16]
	movss xmm1, [rcx+36]
	movss xmm2, [rbp+24]
	mulss xmm1, xmm2
	addss xmm0, xmm1
	movss [rbx+32], xmm0
	mov rbx, [rbp+16]
	lea rbx, [rbx+24]
	sub rsp, 16
	mov [rsp+8], rbx
	call Vector2Zero
	mov rbx, [rsp+0]
	mov rbx, [rsp+8]
	movsd [rbx], xmm0
	add rsp, 16
	mov rcx, [rbp+16]
	mov ebx, DWORD [rcx+176]
	add rbx, 0x190
	cvtsi2sd xmm0, rbx
	movsd xmm1, [FP18]
	addsd xmm0, xmm1
	sub rsp, 16
	movsd [rsp+8], xmm0
	mov rbx, [rbp+16]
	lea rbx, [rbx+0]
	movss xmm0, [rbx+0]
	call fabsf
	movss [rsp+0], xmm0
	movsd xmm0, [rsp+8]
	cvtss2sd xmm1, [rsp+0]
	add rsp, 16
	comisd xmm1, xmm0
	seta bl
	test bl, bl
	jne .L5
	mov rsi, [rbp+16]
	mov ecx, DWORD [rsi+176]
	add rcx, 0x190
	cvtsi2sd xmm0, rcx
	movsd xmm1, [FP18]
	addsd xmm0, xmm1
	sub rsp, 32
	mov [rsp+31], bl
	movsd [rsp+16], xmm0
	mov rbx, [rbp+16]
	lea rbx, [rbx+0]
	movss xmm0, [rbx+4]
	call fabsf
	movss [rsp+0], xmm0
	mov bl, [rsp+31]
	movsd xmm0, [rsp+16]
	cvtss2sd xmm1, [rsp+0]
	add rsp, 32
	comisd xmm1, xmm0
	seta bl
	.L5:
	test bl, bl
	je .L3
	mov rbx, [rbp+16]
	xor cl, cl
	mov [rbx+174], cl
	.L3:
	.L4:
	sub rsp, 16
	xor rbx, rbx
	mov [rsp+8], rbx
	.L6:
	mov rbx, [rsp+8]
	mov rcx, 0x10
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L8
	lea rcx, [Asteroids+0]
	mov rsi, [rsp+8]
	mov rdi, rsi
	shl rsi, 5
	lea rsi, [rsi + rdi*8]
	lea rsi, [rsi + rdi*4]
	add rsi, rdi
	lea rbx, [rcx+rsi*4]
	mov [rsp+0], rbx
	mov rbx, [rbp+16]
	mov rcx, [rsp+0]
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L9
	jmp .L7
	.L9:
	.L10:
	mov rcx, [rsp+0]
	mov bl, [rcx+174]
	test bl, bl
	je .L13
	sub rsp, 32
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	mov r8, [rsp+32]
	lea r8, [r8+0]
	mov rdi, [r8]
	mov [rbx], rdi
	mov rcx, [rsp+32]
	mov ebx, DWORD [rcx+176]
	cvtsi2ss xmm0, rbx
	movss [rsp+24], xmm0
	call Asteroid.colliding_with
	mov bl, [rsp+0]
	add rsp, 32
	.L13:
	test bl, bl
	je .L11
	sub rsp, 64
	mov rbx, [rbp+16]
	mov eax, DWORD [rbx+176]
	mov rcx, [rbp+16]
	mov ebx, DWORD [rcx+176]
	mul rbx
	cvtsi2ss xmm0, rax
	movss [rsp+56], xmm0
	mov rbx, [rsp+64]
	mov eax, DWORD [rbx+176]
	mov rcx, [rsp+64]
	mov ebx, DWORD [rcx+176]
	mul rbx
	cvtsi2ss xmm0, rax
	movss [rsp+60], xmm0
	lea rbx, [rsp+48]
	sub rsp, 32
	mov [rsp+0], rbx
	mov [rsp+24], rbx
	mov rbx, [rsp+96]
	lea rbx, [rbx+0]
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	mov r8, [rbp+16]
	lea r8, [r8+0]
	mov rdi, [r8]
	mov [rbx], rdi
	call Vector2.__sub_Vector2
	mov rbx, [rsp+24]
	add rsp, 32
	lea rbx, [rsp+40]
	sub rsp, 32
	mov [rsp+0], rbx
	mov [rsp+24], rbx
	lea rbx, [rsp+80]
	mov [rsp+8], rbx
	call Vector2.normalized
	mov rbx, [rsp+24]
	add rsp, 32
	lea rbx, [rsp+32]
	movss xmm0, [rsp+44]
	xorps xmm0, [__FNEG_MASKs]
	movss [rbx+0], xmm0
	movss xmm0, [rsp+40]
	movss [rbx+4], xmm0
	lea rbx, [rsp+24]
	sub rsp, 16
	mov [rsp+8], rbx
	lea rbx, [__GP_TMP]
	mov rdi, [rsp+56]
	mov [rbx], rdi
	movsd xmm1, [__GP_TMP]
	lea rbx, [__GP_TMP]
	mov r8, [rbp+16]
	lea r8, [r8+8]
	mov rdi, [r8]
	mov [rbx], rdi
	movsd xmm0, [__GP_TMP]
	call Vector2DotProduct
	movss [rsp+0], xmm0
	mov rbx, [rsp+8]
	movss xmm0, [rsp+0]
	add rsp, 16
	movss [rbx+0], xmm0
	sub rsp, 16
	mov [rsp+8], rbx
	lea rbx, [__GP_TMP]
	mov rdi, [rsp+48]
	mov [rbx], rdi
	movsd xmm1, [__GP_TMP]
	lea rbx, [__GP_TMP]
	mov r8, [rbp+16]
	lea r8, [r8+8]
	mov rdi, [r8]
	mov [rbx], rdi
	movsd xmm0, [__GP_TMP]
	call Vector2DotProduct
	movss [rsp+0], xmm0
	mov rbx, [rsp+8]
	movss xmm0, [rsp+0]
	add rsp, 16
	movss [rbx+4], xmm0
	lea rbx, [rsp+16]
	sub rsp, 16
	mov [rsp+8], rbx
	lea rbx, [__GP_TMP]
	mov rdi, [rsp+56]
	mov [rbx], rdi
	movsd xmm1, [__GP_TMP]
	lea rbx, [__GP_TMP]
	mov r8, [rsp+80]
	lea r8, [r8+8]
	mov rdi, [r8]
	mov [rbx], rdi
	movsd xmm0, [__GP_TMP]
	call Vector2DotProduct
	movss [rsp+0], xmm0
	mov rbx, [rsp+8]
	movss xmm0, [rsp+0]
	add rsp, 16
	movss [rbx+0], xmm0
	sub rsp, 16
	mov [rsp+8], rbx
	lea rbx, [__GP_TMP]
	mov rdi, [rsp+48]
	mov [rbx], rdi
	movsd xmm1, [__GP_TMP]
	lea rbx, [__GP_TMP]
	mov r8, [rsp+80]
	lea r8, [r8+8]
	mov rdi, [r8]
	mov [rbx], rdi
	movsd xmm0, [__GP_TMP]
	call Vector2DotProduct
	movss [rsp+0], xmm0
	mov rbx, [rsp+8]
	movss xmm0, [rsp+0]
	add rsp, 16
	movss [rbx+4], xmm0
	lea rbx, [rsp+8]
	cvtsd2ss xmm0, [FP19]
	lea rcx, [rsp+56]
	xor rsi, rsi
	movss xmm1, [rcx+rsi*4]
	mulss xmm0, xmm1
	lea rcx, [rsp+56]
	mov rsi, 0x1
	movss xmm1, [rcx+rsi*4]
	mulss xmm0, xmm1
	movss xmm1, [rsp+24]
	movss xmm2, [rsp+16]
	subss xmm1, xmm2
	mulss xmm0, xmm1
	lea rcx, [rsp+56]
	xor rsi, rsi
	movss xmm1, [rcx+rsi*4]
	lea rcx, [rsp+56]
	mov rsi, 0x1
	movss xmm2, [rcx+rsi*4]
	addss xmm1, xmm2
	divss xmm0, xmm1
	movss [rbx+0], xmm0
	lea rcx, [rsp+56]
	xor rsi, rsi
	movss xmm0, [rcx+rsi*4]
	xorps xmm0, [__FNEG_MASKs]
	lea rcx, [rsp+56]
	mov rsi, 0x1
	movss xmm1, [rcx+rsi*4]
	mulss xmm0, xmm1
	movss xmm1, [rsp+28]
	mov rcx, [rbp+16]
	movss xmm2, [rcx+36]
	mov rsi, [rbp+16]
	mov ecx, DWORD [rsi+176]
	cvtsi2ss xmm3, rcx
	mulss xmm2, xmm3
	addss xmm1, xmm2
	movss xmm2, [rsp+20]
	mov rcx, [rsp+64]
	movss xmm3, [rcx+36]
	mov rsi, [rsp+64]
	mov ecx, DWORD [rsi+176]
	cvtsi2ss xmm4, rcx
	mulss xmm3, xmm4
	subss xmm2, xmm3
	subss xmm1, xmm2
	mulss xmm0, xmm1
	cvtsd2ss xmm1, [FP20]
	lea rcx, [rsp+56]
	xor rsi, rsi
	movss xmm2, [rcx+rsi*4]
	lea rcx, [rsp+56]
	mov rsi, 0x1
	movss xmm3, [rcx+rsi*4]
	addss xmm2, xmm3
	mulss xmm1, xmm2
	divss xmm0, xmm1
	movss [rbx+4], xmm0
	movss xmm0, [rsp+24]
	movss xmm1, [rsp+8]
	lea rbx, [rsp+56]
	xor rcx, rcx
	movss xmm2, [rbx+rcx*4]
	divss xmm1, xmm2
	addss xmm0, xmm1
	movss [rsp+4], xmm0
	movss xmm0, [rsp+28]
	movss xmm1, [rsp+12]
	lea rbx, [rsp+56]
	xor rcx, rcx
	movss xmm2, [rbx+rcx*4]
	divss xmm1, xmm2
	addss xmm0, xmm1
	movss [rsp+0], xmm0
	mov rbx, [rbp+16]
	lea rbx, [rbx+16]
	sub rsp, 32
	mov [rsp+0], rbx
	mov [rsp+24], rbx
	mov rbx, [rbp+16]
	lea rbx, [rbx+16]
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	sub rsp, 16
	lea rcx, [rsp+0]
	sub rsp, 16
	lea rsi, [rsp+0]
	sub rsp, 48
	mov [rsp+0], rsi
	mov [rsp+40], rbx
	mov [rsp+32], rcx
	mov [rsp+24], rsi
	lea rbx, [rsp+152]
	mov [rsp+8], rbx
	movss xmm0, [rsp+116]
	movss [rsp+16], xmm0
	call Vector2.__mul_float
	mov rbx, [rsp+40]
	mov rcx, [rsp+32]
	mov rsi, [rsp+24]
	add rsp, 48
	sub rsp, 48
	mov [rsp+0], rcx
	mov [rsp+40], rbx
	mov [rsp+32], rcx
	lea rbx, [rsp+48]
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	sub rsp, 32
	mov [rsp+0], rbx
	mov [rsp+24], rbx
	lea rbx, [rsp+176]
	mov [rsp+8], rbx
	movss xmm0, [rsp+144]
	movss [rsp+16], xmm0
	call Vector2.__mul_float
	mov rbx, [rsp+24]
	add rsp, 32
	call Vector2.__add_Vector2
	mov rbx, [rsp+40]
	mov rcx, [rsp+32]
	add rsp, 64
	sub rsp, 32
	mov [rsp+0], rbx
	mov [rsp+24], rbx
	lea rbx, [rsp+32]
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	mov r8, [rbp+16]
	lea r8, [r8+8]
	mov rdi, [r8]
	mov [rbx], rdi
	call Vector2.__sub_Vector2
	mov rbx, [rsp+24]
	add rsp, 48
	call Vector2.__add_Vector2
	mov rbx, [rsp+24]
	add rsp, 32
	mov rbx, [rbp+16]
	mov rcx, [rbp+16]
	movss xmm0, [rcx+40]
	movss xmm1, [rsp+12]
	cvtsd2ss xmm2, [FP3]
	lea rcx, [rsp+56]
	xor rsi, rsi
	movss xmm3, [rcx+rsi*4]
	mulss xmm2, xmm3
	mov rsi, [rbp+16]
	mov ecx, DWORD [rsi+176]
	cvtsi2ss xmm3, rcx
	mulss xmm2, xmm3
	divss xmm1, xmm2
	addss xmm0, xmm1
	movss [rbx+40], xmm0
	mov rbx, [rbp+16]
	lea rbx, [rbx+24]
	sub rsp, 32
	mov [rsp+0], rbx
	mov [rsp+24], rbx
	lea rbx, [rsp+72]
	mov [rsp+8], rbx
	cvtsd2ss xmm0, [FP3]
	sub rsp, 32
	movss [rsp+28], xmm0
	lea rbx, [rsp+112]
	mov [rsp+8], rbx
	call Vector2.length
	movss xmm0, [rsp+28]
	movss xmm1, [rsp+0]
	add rsp, 32
	mov rcx, [rbp+16]
	mov ebx, DWORD [rcx+176]
	cvtsi2ss xmm2, rbx
	subss xmm1, xmm2
	mov rcx, [rsp+96]
	mov ebx, DWORD [rcx+176]
	cvtsi2ss xmm2, rbx
	subss xmm1, xmm2
	mulss xmm0, xmm1
	movss [rsp+16], xmm0
	call Vector2.__mul_float
	mov rbx, [rsp+24]
	add rsp, 32
	add rsp, 64
	.L11:
	.L12:
	.L7:
	mov rbx, [rsp+8]
	inc QWORD [rsp+8]
	jmp .L6
	.L8:
	add rsp, 16
	mov rbx, QWORD [Game+0]
	mov rcx, 0x1
	cmp rbx, rcx
	setne bl
	test bl, bl
	je .L14
	jmp .L0
	.L14:
	.L15:
	sub rsp, 16
	xor rbx, rbx
	mov [rsp+8], rbx
	.L16:
	mov rbx, [rsp+8]
	mov rcx, 0x10
	cmp rbx, rcx
	setl bl
	test bl, bl
	je .L18
	lea rcx, [Missiles+0]
	mov rsi, [rsp+8]
	lea rsi, [rsi+rsi*2]
	lea rbx, [rcx+rsi*8]
	mov [rsp+0], rbx
	mov rcx, [rsp+0]
	mov bl, [rcx+16]
	test bl, bl
	je .L21
	sub rsp, 32
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	mov r8, [rsp+32]
	lea r8, [r8+0]
	mov rdi, [r8]
	mov [rbx], rdi
	cvtsd2ss xmm0, [FP1]
	movss [rsp+24], xmm0
	call Asteroid.colliding_with
	mov bl, [rsp+0]
	add rsp, 32
	.L21:
	test bl, bl
	je .L19
	mov rbx, [rbp+16]
	xor cl, cl
	mov [rbx+174], cl
	mov rbx, [rsp+0]
	xor cl, cl
	mov [rbx+16], cl
	mov rbx, QWORD [Game+8]
	inc rbx
	mov [Game+8], rbx
	mov rbx, QWORD [Game+8]
	mov rcx, QWORD [Game+16]
	cmp rbx, rcx
	seta bl
	test bl, bl
	je .L22
	mov rbx, QWORD [Game+8]
	mov [Game+16], rbx
	.L22:
	.L23:
	jmp .L0
	.L19:
	.L20:
	.L17:
	mov rbx, [rsp+8]
	inc QWORD [rsp+8]
	jmp .L16
	.L18:
	add rsp, 16
	sub rsp, 32
	mov rbx, [rbp+16]
	mov [rsp+8], rbx
	lea rbx, [rsp+16]
	lea r8, [Spaceship+24]
	mov rdi, [r8]
	mov [rbx], rdi
	cvtsd2ss xmm0, [FP9]
	movss [rsp+24], xmm0
	call Asteroid.colliding_with
	mov bl, [rsp+0]
	add rsp, 32
	test bl, bl
	je .L24
	sub rsp, 16
	lea rbx, [rsp+0]
	mov r8, [rbp+16]
	lea r8, [r8+0]
	mov rdi, [r8]
	mov [rbx], rdi
	call Spaceship.damage
	add rsp, 16
	mov rbx, [rbp+16]
	xor cl, cl
	mov [rbx+174], cl
	jmp .L0
	.L24:
	.L25:
	.L0:
	leave
	ret

global main:function
main:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov rdi, [rbp+32]
	call srand
	mov rdx, STR0
	mov rsi, 0x320
	mov rdi, 0x320
	call InitWindow
	mov rdi, 0x78
	call SetTargetFPS
	lea rbx, [rsp+8]
	lea r8, [rbx+0]
	mov rcx, 0x190
	cvtsi2ss xmm0, rcx
	movss [r8+0], xmm0
	mov rcx, 0x190
	cvtsi2ss xmm0, rcx
	movss [r8+4], xmm0
	lea r8, [rbx+8]
	cvtsd2ss xmm0, [FP2]
	movss [r8+0], xmm0
	cvtsd2ss xmm0, [FP2]
	movss [r8+4], xmm0
	cvtsd2ss xmm0, [FP2]
	movss [rbx+16], xmm0
	cvtsd2ss xmm0, [FP0]
	movss [rbx+20], xmm0
	call Asteroids.init
	.L1:
	sub rsp, 16
	call WindowShouldClose
	mov [rsp+0], rax
	mov bl, [rsp+0]
	add rsp, 16
	test bl, bl
	je .L3
	jmp .L2
	.L3:
	.L4:
	call PollInputEvents
	call BeginDrawing
	lea rbx, [__GP_TMP]
	xor cl, cl
	mov [rbx+0], cl
	xor cl, cl
	mov [rbx+1], cl
	xor cl, cl
	mov [rbx+2], cl
	mov cl, 0xff
	mov [rbx+3], cl
	mov rdi, QWORD [__GP_TMP+0]
	call ClearBackground
	mov rsi, 0x30c
	xor rdi, rdi
	call DrawFPS
	mov rbx, QWORD [Game+0]
	xor rcx, rcx
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L5
	sub rsp, 112
	lea rbx, [rsp+80]
	mov ecx, 0x190
	mov [rbx+0], ecx
	mov ecx, 0x190
	mov [rbx+4], ecx
	mov rcx, STR1
	mov [rbx+8], rcx
	lea r8, [rbx+16]
	xor cl, cl
	mov [r8+0], cl
	mov cl, 0xe4
	mov [r8+1], cl
	mov cl, 0x30
	mov [r8+2], cl
	mov cl, 0xff
	mov [r8+3], cl
	mov ecx, 0x1a
	mov [rbx+20], ecx
	xor cl, cl
	mov [rbx+24], cl
	xor cl, cl
	mov [rbx+25], cl
	lea rbx, [rsp+48]
	mov ecx, 0x190
	mov [rbx+0], ecx
	mov ecx, 0x230
	mov [rbx+4], ecx
	mov rcx, STR2
	mov [rbx+8], rcx
	lea r8, [rbx+16]
	mov cl, 0x82
	mov [r8+0], cl
	mov cl, 0x82
	mov [r8+1], cl
	mov cl, 0x82
	mov [r8+2], cl
	mov cl, 0xff
	mov [r8+3], cl
	mov ecx, 0x1a
	mov [rbx+20], ecx
	xor cl, cl
	mov [rbx+24], cl
	xor cl, cl
	mov [rbx+25], cl
	lea rbx, [rsp+16]
	mov ecx, 0x190
	mov [rbx+0], ecx
	mov ecx, 0x2b5
	mov [rbx+4], ecx
	mov rcx, STR3
	mov [rbx+8], rcx
	lea r8, [rbx+16]
	mov cl, 0xe6
	mov [r8+0], cl
	mov cl, 0x29
	mov [r8+1], cl
	mov cl, 0x37
	mov [r8+2], cl
	mov cl, 0xff
	mov [r8+3], cl
	mov ecx, 0x1a
	mov [rbx+20], ecx
	xor cl, cl
	mov [rbx+24], cl
	xor cl, cl
	mov [rbx+25], cl
	sub rsp, 16
	lea rbx, [rsp+96]
	mov [rsp+0], rbx
	call Button.update
	add rsp, 16
	sub rsp, 16
	lea rbx, [rsp+64]
	mov [rsp+0], rbx
	call Button.update
	add rsp, 16
	sub rsp, 16
	lea rbx, [rsp+32]
	mov [rsp+0], rbx
	call Button.update
	add rsp, 16
	mov bl, [rsp+105]
	test bl, bl
	je .L7
	xor rbx, rbx
	mov [Game+8], rbx
	call Spaceship.init
	call Asteroids.init
	call Missiles.init
	mov rbx, 0x1
	mov [Game+0], rbx
	.L7:
	.L8:
	mov bl, [rsp+73]
	test bl, bl
	je .L9
	mov rbx, 0x3
	mov [Game+0], rbx
	.L9:
	.L10:
	mov bl, [rsp+41]
	test bl, bl
	je .L11
	jmp .L2
	.L11:
	.L12:
	sub rsp, 16
	call GetFrameTime
	movss [rsp+0], xmm0
	movss xmm0, [rsp+0]
	add rsp, 16
	movss [rsp+12], xmm0
	sub rsp, 16
	movss xmm0, [rsp+28]
	movss [rsp+0], xmm0
	call Asteroids.update
	add rsp, 16
	sub rsp, 32
	lea rbx, [rsp+0]
	cld
	lea rdi, [rbx]
	lea rsi, [rsp+152]
	mov rcx, 3
	rep movsq
	call BeginMode2D
	add rsp, 32
	call Asteroids.draw
	call EndMode2D
	lea rbx, [__GP_TMP]
	mov cl, 0xff
	mov [rbx+0], cl
	mov cl, 0xff
	mov [rbx+1], cl
	mov cl, 0xff
	mov [rbx+2], cl
	mov cl, 0xff
	mov [rbx+3], cl
	mov r8, QWORD [__GP_TMP+0]
	mov rcx, 0x32
	mov rdx, 0x10a
	sub rsp, 48
	mov [rsp+40], rcx
	mov [rsp+32], r8
	mov [rsp+24], rax
	mov [rsp+16], rdx
	mov rsi, 0x32
	mov rdi, STR0
	call MeasureText
	mov [rsp+0], rax
	mov rcx, [rsp+40]
	mov r8, [rsp+32]
	mov rax, [rsp+24]
	mov rdx, [rsp+16]
	movsxd rsi, DWORD [rsp+0]
	add rsp, 48
	sar rsi, 1
	neg rsi
	add rsi, 0x190
	mov rdi, STR0
	call DrawText
	sub rsp, 16
	lea rbx, [rsp+96]
	mov [rsp+0], rbx
	call Button.draw
	add rsp, 16
	sub rsp, 16
	lea rbx, [rsp+64]
	mov [rsp+0], rbx
	call Button.draw
	add rsp, 16
	sub rsp, 16
	lea rbx, [rsp+32]
	mov [rsp+0], rbx
	call Button.draw
	add rsp, 16
	add rsp, 112
	jmp .L6
	.L5:
	mov rbx, QWORD [Game+0]
	mov rcx, 0x1
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L13
	sub rsp, 48
	lea rbx, [rsp+16]
	mov ecx, 0x190
	mov [rbx+0], ecx
	mov ecx, 0xa
	mov [rbx+4], ecx
	mov rcx, STR3
	mov [rbx+8], rcx
	lea r8, [rbx+16]
	mov cl, 0xe6
	mov [r8+0], cl
	mov cl, 0x29
	mov [r8+1], cl
	mov cl, 0x37
	mov [r8+2], cl
	mov cl, 0xff
	mov [r8+3], cl
	mov ecx, 0x10
	mov [rbx+20], ecx
	xor cl, cl
	mov [rbx+24], cl
	xor cl, cl
	mov [rbx+25], cl
	sub rsp, 16
	lea rbx, [rsp+32]
	mov [rsp+0], rbx
	call Button.update
	add rsp, 16
	mov bl, [rsp+41]
	test bl, bl
	je .L14
	xor rbx, rbx
	mov [Game+0], rbx
	.L14:
	.L15:
	lea rbx, [__GP_TMP]
	mov cl, 0xff
	mov [rbx+0], cl
	mov cl, 0xff
	mov [rbx+1], cl
	mov cl, 0xff
	mov [rbx+2], cl
	mov cl, 0xff
	mov [rbx+3], cl
	mov r8, QWORD [__GP_TMP+0]
	mov rcx, 0x18
	xor rdx, rdx
	xor rsi, rsi
	sub rsp, 48
	mov [rsp+40], rcx
	mov [rsp+32], rsi
	mov [rsp+24], r8
	mov [rsp+16], rax
	mov [rsp+8], rdx
	xor rax, rax
	mov rdx, QWORD [Spaceship+40]
	mov rsi, QWORD [Game+8]
	mov rdi, STR4
	call TextFormat
	mov [rsp+0], rax
	mov rcx, [rsp+40]
	mov rsi, [rsp+32]
	mov r8, [rsp+24]
	mov rax, [rsp+16]
	mov rdx, [rsp+8]
	mov rdi, [rsp+0]
	add rsp, 48
	call DrawText
	sub rsp, 16
	xor rax, rax
	mov rsi, QWORD [Game+16]
	mov rdi, STR5
	call TextFormat
	mov [rsp+0], rax
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rsp+8], rbx
	lea rbx, [__GP_TMP]
	mov cl, 0xff
	mov [rbx+0], cl
	mov cl, 0xff
	mov [rbx+1], cl
	mov cl, 0xff
	mov [rbx+2], cl
	mov cl, 0xff
	mov [rbx+3], cl
	mov r8, QWORD [__GP_TMP+0]
	mov rcx, 0x18
	xor rdx, rdx
	sub rsp, 48
	mov [rsp+40], rcx
	mov [rsp+32], r8
	mov [rsp+24], rax
	mov [rsp+16], rdx
	mov rsi, 0x18
	mov rdi, [rsp+56]
	call MeasureText
	mov [rsp+0], rax
	mov rcx, [rsp+40]
	mov r8, [rsp+32]
	mov rax, [rsp+24]
	mov rdx, [rsp+16]
	movsxd rsi, DWORD [rsp+0]
	add rsp, 48
	neg rsi
	add rsi, 0x320
	mov rdi, [rsp+8]
	call DrawText
	sub rsp, 16
	call GetFrameTime
	movss [rsp+0], xmm0
	movss xmm0, [rsp+0]
	add rsp, 16
	movss [rsp+4], xmm0
	sub rsp, 16
	movss xmm0, [rsp+20]
	movss [rsp+0], xmm0
	call Spaceship.update
	add rsp, 16
	sub rsp, 16
	movss xmm0, [rsp+20]
	movss [rsp+0], xmm0
	call Asteroids.update
	add rsp, 16
	sub rsp, 16
	movss xmm0, [rsp+20]
	movss [rsp+0], xmm0
	call Missiles.update
	add rsp, 16
	sub rsp, 16
	lea rbx, [rsp+32]
	mov [rsp+0], rbx
	call Button.draw
	add rsp, 16
	sub rsp, 32
	lea rbx, [rsp+0]
	cld
	lea rdi, [rbx]
	lea rsi, [rsp+88]
	mov rcx, 3
	rep movsq
	call BeginMode2D
	add rsp, 32
	call Spaceship.draw
	call Asteroids.draw
	call Missiles.draw
	call EndMode2D
	add rsp, 48
	jmp .L6
	.L13:
	mov rbx, QWORD [Game+0]
	mov rcx, 0x2
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L16
	sub rsp, 48
	lea rbx, [rsp+16]
	mov ecx, 0x190
	mov [rbx+0], ecx
	mov ecx, 0x2ee
	mov [rbx+4], ecx
	mov rcx, STR6
	mov [rbx+8], rcx
	lea r8, [rbx+16]
	mov cl, 0x50
	mov [r8+0], cl
	mov cl, 0x50
	mov [r8+1], cl
	mov cl, 0x50
	mov [r8+2], cl
	mov cl, 0xff
	mov [r8+3], cl
	mov ecx, 0x1a
	mov [rbx+20], ecx
	xor cl, cl
	mov [rbx+24], cl
	xor cl, cl
	mov [rbx+25], cl
	sub rsp, 16
	lea rbx, [rsp+32]
	mov [rsp+0], rbx
	call Button.update
	add rsp, 16
	mov bl, [rsp+41]
	test bl, bl
	je .L17
	xor rbx, rbx
	mov [Game+0], rbx
	.L17:
	.L18:
	lea rbx, [__GP_TMP]
	mov cl, 0xe6
	mov [rbx+0], cl
	mov cl, 0x29
	mov [rbx+1], cl
	mov cl, 0x37
	mov [rbx+2], cl
	mov cl, 0xff
	mov [rbx+3], cl
	mov r8, QWORD [__GP_TMP+0]
	mov rcx, 0x1e
	mov rdx, 0x10a
	sub rsp, 48
	mov [rsp+40], rcx
	mov [rsp+32], r8
	mov [rsp+24], rax
	mov [rsp+16], rdx
	mov rsi, 0x1e
	mov rdi, STR7
	call MeasureText
	mov [rsp+0], rax
	mov rcx, [rsp+40]
	mov r8, [rsp+32]
	mov rax, [rsp+24]
	mov rdx, [rsp+16]
	movsxd rsi, DWORD [rsp+0]
	add rsp, 48
	sar rsi, 1
	neg rsi
	add rsi, 0x190
	mov rdi, STR8
	call DrawText
	sub rsp, 16
	xor rax, rax
	mov rdx, QWORD [Game+16]
	mov rsi, QWORD [Game+8]
	mov rdi, STR9
	call TextFormat
	mov [rsp+0], rax
	mov rbx, [rsp+0]
	add rsp, 16
	mov [rsp+8], rbx
	lea rbx, [__GP_TMP]
	mov cl, 0xe6
	mov [rbx+0], cl
	mov cl, 0x29
	mov [rbx+1], cl
	mov cl, 0x37
	mov [rbx+2], cl
	mov cl, 0xff
	mov [rbx+3], cl
	mov r8, QWORD [__GP_TMP+0]
	mov rcx, 0x1e
	mov rdx, 0x190
	sub rsp, 48
	mov [rsp+40], rcx
	mov [rsp+32], r8
	mov [rsp+24], rax
	mov [rsp+16], rdx
	mov rsi, 0x1e
	mov rdi, [rsp+56]
	call MeasureText
	mov [rsp+0], rax
	mov rcx, [rsp+40]
	mov r8, [rsp+32]
	mov rax, [rsp+24]
	mov rdx, [rsp+16]
	movsxd rsi, DWORD [rsp+0]
	add rsp, 48
	sar rsi, 1
	neg rsi
	add rsi, 0x190
	mov rdi, [rsp+8]
	call DrawText
	sub rsp, 16
	lea rbx, [rsp+32]
	mov [rsp+0], rbx
	call Button.draw
	add rsp, 16
	add rsp, 48
	jmp .L6
	.L16:
	mov rbx, QWORD [Game+0]
	mov rcx, 0x3
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L19
	sub rsp, 48
	lea rbx, [rsp+16]
	mov ecx, 0x190
	mov [rbx+0], ecx
	mov ecx, 0x2ee
	mov [rbx+4], ecx
	mov rcx, STR6
	mov [rbx+8], rcx
	lea r8, [rbx+16]
	mov cl, 0x50
	mov [r8+0], cl
	mov cl, 0x50
	mov [r8+1], cl
	mov cl, 0x50
	mov [r8+2], cl
	mov cl, 0xff
	mov [r8+3], cl
	mov ecx, 0x1a
	mov [rbx+20], ecx
	xor cl, cl
	mov [rbx+24], cl
	xor cl, cl
	mov [rbx+25], cl
	mov rbx, STR10
	mov [rsp+8], rbx
	lea rbx, [__GP_TMP]
	mov cl, 0xe6
	mov [rbx+0], cl
	mov cl, 0x29
	mov [rbx+1], cl
	mov cl, 0x37
	mov [rbx+2], cl
	mov cl, 0xff
	mov [rbx+3], cl
	mov r8, QWORD [__GP_TMP+0]
	mov rcx, 0x1e
	mov rdx, 0x32
	sub rsp, 48
	mov [rsp+40], rcx
	mov [rsp+32], r8
	mov [rsp+24], rax
	mov [rsp+16], rdx
	mov rsi, 0x1e
	mov rdi, [rsp+56]
	call MeasureText
	mov [rsp+0], rax
	mov rcx, [rsp+40]
	mov r8, [rsp+32]
	mov rax, [rsp+24]
	mov rdx, [rsp+16]
	movsxd rsi, DWORD [rsp+0]
	add rsp, 48
	sar rsi, 1
	neg rsi
	add rsi, 0x190
	mov rdi, [rsp+8]
	call DrawText
	sub rsp, 16
	lea rbx, [rsp+32]
	mov [rsp+0], rbx
	call Button.update
	add rsp, 16
	mov bl, [rsp+41]
	test bl, bl
	je .L20
	xor rbx, rbx
	mov [Game+0], rbx
	.L20:
	.L21:
	sub rsp, 16
	lea rbx, [rsp+32]
	mov [rsp+0], rbx
	call Button.draw
	add rsp, 16
	add rsp, 48
	jmp .L6
	.L19:
	.L6:
	call EndDrawing
	jmp .L1
	.L2:
	call CloseWindow
	.L0:
	leave
	ret


extern IsMaterialValid:function
extern putc:function
extern Vector4Divide:function
extern SetWindowOpacity:function
extern Vector2Invert:function
extern DrawRing:function
extern ImageCopy:function
extern QuaternionInvert:function
extern IsWindowHidden:function
extern GetScreenWidth:function
extern FileExists:function
extern ImageDrawRectangleRec:function
extern BeginMode3D:function
extern EndBlendMode:function
extern ImageDrawRectangleLines:function
extern UnloadAudioStream:function
extern Vector3MoveTowards:function
extern fputc:function
extern log:function
extern GetFileLength:function
extern ImageDrawTriangleLines:function
extern QuaternionTransform:function
extern ImageDither:function
extern GenMeshKnot:function
extern GetRayCollisionQuad:function
extern WaitTime:function
extern DrawTriangle:function
extern CheckCollisionCircleLine:function
extern LoadModelAnimations:function
extern SetWindowState:function
extern LoadDirectoryFilesEx:function
extern sprintf:function
extern IsMouseButtonReleased:function
extern DrawPixelV:function
extern CheckCollisionPointCircle:function
extern UnloadImage:function
extern GenMeshCube:function
extern Vector3Zero:function
extern GetSplinePointBasis:function
extern ImageDrawTriangle:function
extern Vector2One:function
extern Vector2Length:function
extern QuaternionLength:function
extern SetAudioStreamPan:function
extern sin:function
extern cbrt:function
extern GetCurrentMonitor:function
extern ExportDataAsCode:function
extern Vector2AddValue:function
extern QuaternionSubtractValue:function
extern puts:function
extern copysign:function
extern IsGamepadButtonReleased:function
extern IsGamepadButtonUp:function
extern GenMeshCone:function
extern Vector3AddValue:function
extern setstate:function
extern Vector2DotProduct:function
extern Vector3Refract:function
extern Vector4AddValue:function
extern GetRayCollisionTriangle:function
extern QuaternionScale:function
extern CheckCollisionCircles:function
extern IsImageValid:function
extern GetMusicTimePlayed:function
extern Vector2ClampValue:function
extern QuaternionFromMatrix:function
extern fminf:function
extern LoadVrStereoConfig:function
extern DrawPixel:function
extern GetSplinePointLinear:function
extern LoadImageFromMemory:function
extern ImageFromChannel:function
extern ImageAlphaPremultiply:function
extern GetModelBoundingBox:function
extern LoadSoundFromWave:function
extern UnloadMusicStream:function
extern fwrite:function
extern DrawCircleLinesV:function
extern Vector3CrossProduct:function
extern fputs:function
extern DrawSphereEx:function
extern UnloadMaterial:function
extern expf:function
extern coshf:function
extern MakeDirectory:function
extern DrawText:function
extern DrawBillboardRec:function
extern IsAudioDeviceReady:function
extern LoadWave:function
extern Lerp:function
extern log2:function
extern SaveFileText:function
extern ToggleFullscreen:function
extern TextJoin:function
extern ExportWave:function
extern pow:function
extern DrawCircleV:function
extern CheckCollisionCircleRec:function
extern ImageDrawLineEx:function
extern MeasureText:function
extern DrawCubeWires:function
extern rename:function
extern DrawSplineBezierQuadratic:function
extern Vector4Normalize:function
extern DrawRectangleGradientH:function
extern DrawTriangleFan:function
extern Vector2Negate:function
extern hypotf:function
extern IsWindowMinimized:function
extern TextInsert:function
extern TextToSnake:function
extern DrawRay:function
extern GetTouchX:function
extern DrawTriangle3D:function
extern fclose:function
extern RestoreWindow:function
extern SetTargetFPS:function
extern GetTouchY:function
extern CheckCollisionPointLine:function
extern GenImageGradientSquare:function
extern DrawModelEx:function
extern DrawModelPoints:function
extern strtoul:function
extern GetFileExtension:function
extern IsModelValid:function
extern GetMonitorPhysicalHeight:function
extern GetRandomValue:function
extern ImageColorReplace:function
extern TextToFloat:function
extern setvbuf:function
extern LoadAutomationEventList:function
extern GetKeyPressed:function
extern DrawTriangleLines:function
extern ClearWindowState:function
extern DrawCircle:function
extern Vector3Unproject:function
extern ImageColorTint:function
extern TextReplace:function
extern labs:function
extern SetAudioStreamBufferSizeDefault:function
extern ExportImage:function
extern GenImagePerlinNoise:function
extern QuaternionCubicHermiteSpline:function
extern acos:function
extern SetWindowTitle:function
extern GetFileNameWithoutExt:function
extern DrawModelWiresEx:function
extern Vector2DistanceSqr:function
extern DrawRectangleGradientV:function
extern PauseSound:function
extern fflush:function
extern ImageFlipVertical:function
extern GetMonitorName:function
extern SetGesturesEnabled:function
extern GenImageFontAtlas:function
extern atanf:function
extern MemAlloc:function
extern IsFileDropped:function
extern ColorAlphaBlend:function
extern Vector2SubtractValue:function
extern DrawSplineBasis:function
extern CheckCollisionBoxes:function
extern GetGestureHoldDuration:function
extern Vector2Refract:function
extern GetWindowPosition:function
extern ColorToInt:function
extern SetSoundPitch:function
extern Vector2Scale:function
extern fseek:function
extern CheckCollisionPointRec:function
extern UpdateTextureRec:function
extern TextFormat:function
extern WaveCopy:function
extern IsAudioStreamPlaying:function
extern Vector2Add:function
extern QuaternionSubtract:function
extern SetExitKey:function
extern CodepointToUTF8:function
extern StopSound:function
extern sqrtf:function
extern Vector2Distance:function
extern GenImageCellular:function
extern ImageResizeNN:function
extern ImageDraw:function
extern LoadModel:function
extern Vector3Distance:function
extern Vector4Distance:function
extern ColorIsEqual:function
extern UnloadFontData:function
extern UpdateModelAnimation:function
extern SetSoundPan:function
extern LoadImageColors:function
extern DrawSphere:function
extern GetShaderLocationAttrib:function
extern SetTextureWrap:function
extern LoadFont:function
extern DrawCircle3D:function
extern QuaternionNormalize:function
extern malloc:function
extern LoadCodepoints:function
extern Vector2Lerp:function
extern fprintf:function
extern SetWindowPosition:function
extern GetScreenHeight:function
extern ImageDrawLine:function
extern ImageDrawTriangleStrip:function
extern TextIsEqual:function
extern SetModelMeshMaterial:function
extern exit:function
extern Vector4Lerp:function
extern ChangeDirectory:function
extern UnloadCodepoints:function
extern Vector3Divide:function
extern ImageDrawTriangleFan:function
extern DrawTextureEx:function
extern TextToPascal:function
extern WindowShouldClose:function
extern IsGamepadButtonPressed:function
extern IsModelAnimationValid:function
extern Vector3Project:function
extern MatrixSubtract:function
extern ColorTint:function
extern SetTextLineSpacing:function
extern PlaySound:function
extern MatrixLookAt:function
extern LoadWaveFromMemory:function
extern GetWorldToScreen2D:function
extern fread:function
extern GetCodepointPrevious:function
extern IsAudioStreamProcessed:function
extern SetAudioStreamPitch:function
extern ceilf:function
extern log10:function
extern tan:function
extern SetWindowMinSize:function
extern GetMonitorRefreshRate:function
extern DrawRectangle:function
extern BeginVrStereoMode:function
extern GetGestureDragAngle:function
extern GenMeshTorus:function
extern ExportWaveAsCode:function
extern SetWindowMaxSize:function
extern GetMonitorPhysicalWidth:function
extern LoadFileText:function
extern DrawCylinderEx:function
extern SetMusicPitch:function
extern modf:function
extern StopAutomationEventRecording:function
extern TextLength:function
extern logf:function
extern DrawLineStrip:function
extern setbuf:function
extern DisableEventWaiting:function
extern ImageDrawPixelV:function
extern DrawModelWires:function
extern GetShapesTextureRectangle:function
extern DrawPolyLinesEx:function
extern DrawBillboardPro:function
extern Vector3Min:function
extern DrawCircleSectorLines:function
extern UnloadWaveSamples:function
extern fmodf:function
extern InitWindow:function
extern ImageFormat:function
extern GetMeshBoundingBox:function
extern SetMusicPan:function
extern Vector3Max:function
extern QuaternionAddValue:function
extern QuaternionSlerp:function
extern EncodeDataBase64:function
extern DrawLine3D:function
extern MatrixInvert:function
extern Vector3DotProduct:function
extern ImageDrawLineV:function
extern sinf:function
extern GetShaderLocation:function
extern GetGestureDragVector:function
extern Vector3ClampValue:function
extern GetMonitorCount:function
extern GenMeshHemiSphere:function
extern fmaxf:function
extern sinh:function
extern GetMusicTimeLength:function
extern Vector4Equals:function
extern EndShaderMode:function
extern GetMouseDelta:function
extern ColorToHSV:function
extern Vector3Clamp:function
extern GetScreenToWorldRayEx:function
extern GetCameraMatrix2D:function
extern GetCharPressed:function
extern DrawRectangleRounded:function
extern ExportImageAsCode:function
extern UnloadModel:function
extern LoadMaterialDefault:function
extern UnloadModelAnimation:function
extern SetShaderValueMatrix:function
extern GetShapesTexture:function
extern ImageResize:function
extern SeekMusicStream:function
extern Remap:function
extern SetShaderValueV:function
extern GetWorkingDirectory:function
extern DrawTriangleStrip:function
extern LoadShader:function
extern GetTouchPosition:function
extern IsFileExtension:function
extern IsMouseButtonDown:function
extern DrawRingLines:function
extern DrawSplineCatmullRom:function
extern LoadMusicStreamFromMemory:function
extern Wrap:function
extern DrawCapsule:function
extern absf:function
extern IsKeyPressedRepeat:function
extern GenImageColor:function
extern ImageDrawRectangleV:function
extern MatrixRotateX:function
extern tgammaf:function
extern UnloadRandomSequence:function
extern SetMouseScale:function
extern UpdateCameraPro:function
extern TextAppend:function
extern IsMusicStreamPlaying:function
extern MatrixRotateY:function
extern GenMeshHeightmap:function
extern MatrixRotateZ:function
extern SetWindowSize:function
extern IsGamepadButtonDown:function
extern SetWindowIcons:function
extern SetShaderValue:function
extern TextCopy:function
extern SetClipboardText:function
extern GetMouseX:function
extern GenMeshCylinder:function
extern fabsf:function
extern floor:function
extern EndScissorMode:function
extern GetMouseY:function
extern Vector4MoveTowards:function
extern ComputeMD5:function
extern ImageDrawCircle:function
extern IsFontValid:function
extern DrawCubeV:function
extern Vector3Reject:function
extern GetGesturePinchVector:function
extern ImageDrawTriangleEx:function
extern LoadFontFromMemory:function
extern OpenURL:function
extern CheckCollisionLines:function
extern DrawCapsuleWires:function
extern LoadDirectoryFiles:function
extern LoadImageAnim:function
extern ExportFontAsCode:function
extern Vector3One:function
extern SaveFileData:function
extern IsPathFile:function
extern atof:function
extern ComputeSHA1:function
extern IsKeyReleased:function
extern SetMousePosition:function
extern CheckCollisionPointTriangle:function
extern UnloadUTF8:function
extern TextToCamel:function
extern cosf:function
extern asin:function
extern GetMouseWheelMoveV:function
extern DrawLineV:function
extern Vector4SubtractValue:function
extern atoi:function
extern exp:function
extern cosh:function
extern DrawPolyLines:function
extern ColorContrast:function
extern Vector3Angle:function
extern remove:function
extern LoadTextureCubemap:function
extern DrawRectangleRoundedLines:function
extern Vector4Scale:function
extern MatrixRotateXYZ:function
extern atol:function
extern BeginScissorMode:function
extern GetGamepadName:function
extern ImageAlphaClear:function
extern DrawTextEx:function
extern GetGlyphInfo:function
extern QuaternionIdentity:function
extern strfromd:function
extern cbrtf:function
extern ImageResizeCanvas:function
extern LoadModelFromMesh:function
extern strfromf:function
extern GetClipboardImage:function
extern MeasureTextEx:function
extern DrawGrid:function
extern DrawMeshInstanced:function
extern MatrixDecompose:function
extern ImageAlphaMask:function
extern UnloadImagePalette:function
extern Vector3Barycenter:function
extern EndVrStereoMode:function
extern ftell:function
extern tgamma:function
extern LoadImageFromScreen:function
extern GetPixelDataSize:function
extern fopen:function
extern srand:function
extern abort:function
extern ColorBrightness:function
extern CloseAudioDevice:function
extern PlayAutomationEvent:function
extern SetGamepadMappings:function
extern CheckCollisionBoxSphere:function
extern Vector2Divide:function
extern QuaternionDivide:function
extern MaximizeWindow:function
extern WaveFormat:function
extern DrawRectangleRec:function
extern ImageAlphaCrop:function
extern ImageColorGrayscale:function
extern IsRenderTextureValid:function
extern MatrixScale:function
extern DrawPlane:function
extern MatrixAdd:function
extern finite:function
extern GetColor:function
extern DrawSphereWires:function
extern Vector4Invert:function
extern MatrixIdentity:function
extern feof:function
extern GetFileName:function
extern GetGamepadButtonPressed:function
extern MatrixOrtho:function
extern free:function
extern GetDirectoryPath:function
extern UnloadAutomationEventList:function
extern GenImageText:function
extern SetAudioStreamVolume:function
extern getc:function
extern IsShaderValid:function
extern LoadShaderFromMemory:function
extern UnloadDroppedFiles:function
extern DrawTextPro:function
extern MatrixTrace:function
extern system:function
extern ImageTextEx:function
extern ColorAlpha:function
extern GetCodepoint:function
extern Vector2Zero:function
extern Vector2Multiply:function
extern fmod:function
extern IsMouseButtonUp:function
extern Vector3Multiply:function
extern ClearBackground:function
extern Vector3DistanceSqr:function
extern Vector4Zero:function
extern Vector4Multiply:function
extern GetMonitorWidth:function
extern UnloadFileText:function
extern fgetc:function
extern IsWindowReady:function
extern GetApplicationDirectory:function
extern Vector4Length:function
extern GetWorldToScreen:function
extern DrawSplineSegmentBezierQuadratic:function
extern GenMeshTangents:function
extern UpdateModelAnimationBones:function
extern IsGamepadAvailable:function
extern UpdateCamera:function
extern Vector3RotateByAxisAngle:function
extern BeginBlendMode:function
extern ImageRotateCCW:function
extern ResumeAudioStream:function
extern Vector3Add:function
extern Vector4DotProduct:function
extern ColorNormalize:function
extern MatrixDeterminant:function
extern fscanf:function
extern LoadRenderTexture:function
extern Normalize:function
extern Vector3Equals:function
extern copysignf:function
extern EndMode2D:function
extern DrawPoly:function
extern UnloadVrStereoConfig:function
extern SetMouseCursor:function
extern hypot:function
extern ImageDrawCircleLinesV:function
extern UpdateTexture:function
extern LoadFontEx:function
extern Vector2Rotate:function
extern Vector3Perpendicular:function
extern SetTraceLogLevel:function
extern DirectoryExists:function
extern IsSoundValid:function
extern Vector3ToFloatV:function
extern abs:function
extern ImageDrawText:function
extern TextToInteger:function
extern InitAudioDevice:function
extern QuaternionFromAxisAngle:function
extern ImageCrop:function
extern sinhf:function
extern UnloadImageColors:function
extern DrawTextCodepoint:function
extern DrawRectangleV:function
extern DrawTextureRec:function
extern DrawBillboard:function
extern log2f:function
extern LoadFileData:function
extern ImageFromImage:function
extern ImageColorInvert:function
extern ImageColorBrightness:function
extern Vector4Negate:function
extern IsWindowMaximized:function
extern DrawEllipse:function
extern GetSplinePointBezierCubic:function
extern PauseAudioStream:function
extern ceil:function
extern IsWindowFocused:function
extern GetMonitorPosition:function
extern DrawTextureNPatch:function
extern Vector2LengthSqr:function
extern ExportMeshAsCode:function
extern ResumeMusicStream:function
extern LoadAudioStream:function
extern QuaternionToMatrix:function
extern MatrixPerspective:function
extern GetRenderWidth:function
extern Vector2MoveTowards:function
extern BeginShaderMode:function
extern MemRealloc:function
extern GetGestureDetected:function
extern GetSplinePointBezierQuad:function
extern ExportImageToMemory:function
extern GetRayCollisionBox:function
extern Vector2Transform:function
extern EndDrawing:function
extern DecodeDataBase64:function
extern SetTextureFilter:function
extern Vector3OrthoNormalize:function
extern atan:function
extern ColorFromHSV:function
extern GetCodepointNext:function
extern StopAudioStream:function
extern GetCollisionRec:function
extern ImageDrawRectangle:function
extern QuaternionToEuler:function
extern LoadUTF8:function
extern floorf:function
extern LoadImageFromTexture:function
extern LoadTextureFromImage:function
extern DrawCylinder:function
extern rewind:function
extern getenv:function
extern log10f:function
extern tanf:function
extern GetFPS:function
extern LoadSound:function
extern IsWindowResized:function
extern ImageClearBackground:function
extern IsAudioStreamValid:function
extern SetAutomationEventList:function
extern DrawTextCodepoints:function
extern GenMeshCubicmap:function
extern PauseMusicStream:function
extern Vector4Min:function
extern MatrixFrustum:function
extern ImageRotateCW:function
extern UpdateSound:function
extern SetWindowIcon:function
extern EndTextureMode:function
extern GetGamepadAxisCount:function
extern LoadImageRaw:function
extern LoadMusicStream:function
extern IsMusicValid:function
extern Vector4Max:function
extern GenMeshSphere:function
extern SetConfigFlags:function
extern ferror:function
extern DrawCircleSector:function
extern UnloadMesh:function
extern BeginDrawing:function
extern LoadImagePalette:function
extern ColorLerp:function
extern UploadMesh:function
extern Vector2Clamp:function
extern printf:function
extern EndMode3D:function
extern DrawSplineSegmentBezierCubic:function
extern ImageBlurGaussian:function
extern ImageDrawTextEx:function
extern LoadSoundAlias:function
extern StopMusicStream:function
extern DrawRectanglePro:function
extern DrawSplineLinear:function
extern UnloadTexture:function
extern UnloadRenderTexture:function
extern TextSubtext:function
extern PlayAudioStream:function
extern initstate:function
extern IsWindowState:function
extern SetAutomationEventBaseFrame:function
extern GetSplinePointCatmullRom:function
extern DrawTextureV:function
extern DrawLine:function
extern UnloadSoundAlias:function
extern Vector3RotateByQuaternion:function
extern putchar:function
extern DrawLineBezier:function
extern DrawEllipseLines:function
extern DrawFPS:function
extern ImageToPOT:function
extern ImageDrawCircleV:function
extern DrawModelPointsEx:function
extern Vector3Lerp:function
extern MinimizeWindow:function
extern GetTouchPointId:function
extern BeginTextureMode:function
extern DrawCircleLines:function
extern DrawMesh:function
extern atan2f:function
extern EnableEventWaiting:function
extern PollInputEvents:function
extern SetMouseOffset:function
extern GenImageWhiteNoise:function
extern GetFontDefault:function
extern GetGlyphIndex:function
extern GetWindowScaleDPI:function
extern IsKeyDown:function
extern IsTextureValid:function
extern sscanf:function
extern DrawRectangleLines:function
extern Vector3LengthSqr:function
extern Vector3Invert:function
extern DrawModel:function
extern GetRayCollisionSphere:function
extern IsWaveValid:function
extern DrawSplineBezierCubic:function
extern GetMonitorHeight:function
extern MemFree:function
extern LoadDroppedFiles:function
extern realloc:function
extern LoadMaterials:function
extern Vector3Transform:function
extern TakeScreenshot:function
extern PlayMusicStream:function
extern GenImageChecked:function
extern CheckCollisionSpheres:function
extern GetMasterVolume:function
extern exp2f:function
extern cos:function
extern GetRayCollisionMesh:function
extern QuaternionToAxisAngle:function
extern ungetc:function
extern QuaternionMultiply:function
extern DrawSplineSegmentLinear:function
extern GetImageAlphaBorder:function
extern WaveCrop:function
extern QuaternionNlerp:function
extern ColorFromNormalized:function
extern Vector3Length:function
extern SetGamepadVibration:function
extern Vector4One:function
extern QuaternionFromVector3ToVector3:function
extern fmin:function
extern UpdateMeshBuffer:function
extern scanf:function
extern GenMeshPoly:function
extern Vector3SubtractValue:function
extern Vector3Reflect:function
extern fmax:function
extern SetWindowMonitor:function
extern DrawRectangleRoundedLinesEx:function
extern UnloadSound:function
extern Vector2Angle:function
extern DrawCube:function
extern SetSoundVolume:function
extern StartAutomationEventRecording:function
extern LoadFontFromImage:function
extern Vector3Scale:function
extern freopen:function
extern GetTime:function
extern DrawPoint3D:function
extern QuaternionAdd:function
extern clearerr:function
extern ImageColorContrast:function
extern DrawTexturePro:function
extern SetMasterVolume:function
extern Vector2Equals:function
extern asinf:function
extern SetShaderValueTexture:function
extern LoadTexture:function
extern TextSplit:function
extern TextToLower:function
extern QuaternionEquals:function
extern DrawCylinderWires:function
extern DrawLineEx:function
extern Vector2LineAngle:function
extern MatrixTranspose:function
extern GetClipboardText:function
extern GetMouseWheelMove:function
extern LoadImageAnimFromMemory:function
extern MatrixMultiply:function
extern GetTouchPointCount:function
extern UnloadWave:function
extern Vector2Normalize:function
extern GenMeshPlane:function
extern GetGesturePinchAngle:function
extern GenImageGradientRadial:function
extern GetRenderHeight:function
extern IsSoundPlaying:function
extern UnloadShader:function
extern LoadRandomSequence:function
extern ImageMipmaps:function
extern ResumeSound:function
extern Vector3Negate:function
extern Vector3CubicHermite:function
extern IsKeyPressed:function
extern DrawRectangleLinesEx:function
extern fabs:function
extern powf:function
extern UnloadFileData:function
extern IsGestureDetected:function
extern getchar:function
extern GetCameraMatrix:function
extern GetMousePosition:function
extern DrawSplineSegmentBasis:function
extern ImageDrawCircleLines:function
extern TextFindIndex:function
extern exp2:function
extern GetPrevDirectoryPath:function
extern DrawTexture:function
extern Vector4LengthSqr:function
extern strtod:function
extern BeginMode2D:function
extern GetScreenToWorld2D:function
extern ExportAutomationEventList:function
extern SetShapesTexture:function
extern GetPixelColor:function
extern UpdateAudioStream:function
extern strtof:function
extern GetImageColor:function
extern GenTextureMipmaps:function
extern LoadImage:function
extern MatrixTranslate:function
extern GetWindowHandle:function
extern ImageKernelConvolution:function
extern MatrixRotate:function
extern MatrixToFloatV:function
extern rand:function
extern SetMusicVolume:function
extern CompressData:function
extern GenImageGradientLinear:function
extern IsWindowFullscreen:function
extern UnloadModelAnimations:function
extern strtol:function
extern round:function
extern GetWorldToScreenEx:function
extern ImageText:function
extern LoadWaveSamples:function
extern Vector4DistanceSqr:function
extern Vector2Min:function
extern sqrt:function
extern IsKeyUp:function
extern Vector2Reflect:function
extern UnloadDirectoryFiles:function
extern Vector2Max:function
extern strtold:function
extern acosf:function
extern DrawSplineSegmentCatmullRom:function
extern SetMaterialTexture:function
extern SetWindowFocused:function
extern IsFileNameValid:function
extern SetPixelColor:function
extern DrawTriangleStrip3D:function
extern DrawCubeWiresV:function
extern DrawBoundingBox:function
extern Clamp:function
extern Vector2Subtract:function
extern calloc:function
extern roundf:function
extern CloseWindow:function
extern SetRandomSeed:function
extern DrawCircleGradient:function
extern DrawRectangleGradientEx:function
extern GetCodepointCount:function
extern Vector3Subtract:function
extern GetFileModTime:function
extern DecompressData:function
extern GetGamepadAxisMovement:function
extern DrawCylinderWiresEx:function
extern ExportMesh:function
extern Vector4Subtract:function
extern MatrixRotateZYX:function
extern Fade:function
extern UpdateMusicStream:function
extern Vector4Add:function
extern setlinebuf:function
extern TraceLog:function
extern LoadFontData:function
extern ImageRotate:function
extern ImageDrawPixel:function
extern GetGlyphAtlasRec:function
extern snprintf:function
extern TextToUpper:function
extern SwapScreenBuffer:function
extern atan2:function
extern GetScreenToWorldRay:function
extern IsMouseButtonPressed:function
extern CheckCollisionRecs:function
extern Vector3Normalize:function
extern QuaternionFromEuler:function
extern ToggleBorderlessWindowed:function
extern CheckCollisionPointPoly:function
extern ImageFlipHorizontal:function
extern QuaternionLerp:function
extern perror:function
extern GetFrameTime:function
extern ComputeCRC32:function
extern UnloadFont:function
extern __exception_push:function
extern __exception_pop:function
extern __exception_throw:function


section .data align=16
__FP_TMP: times 4 dq 0
__GP_TMP: times 4 dq 0
extern stdin:data
extern stdout:data
extern stderr:data
global FP_PRECISION:data
FP_PRECISION:
dq 0.0000010000
global Game:data
Game:
dq 0
dq 0
dq 0
extern Missile:data
global Missiles:data
Missiles:
times 384 db 0
global Spaceship:data
Spaceship:
dq 0
dq 0
dd 0
dd 0
dq 0
dq 0
dq 0
extern Asteroid:data
global Asteroids:data
Asteroids:
times 2880 db 0
dq 0
dq 0


section .rodata align=16
__FABS_MASKd: dq 0x7FFFFFFFFFFFFFFF, 0
__FABS_MASKs: dd 0x7FFFFFFF, 0, 0, 0
__FNEG_MASKd: dq 0x8000000000000000, 0
__FNEG_MASKs: dd 0x80000000, 0, 0, 0
STR0:
db "Asteroids",0
dd 0
STR1:
db "PLAY",0
db 0
STR2:
db "Controls",0
times 5 db 0
STR3:
db "Quit",0
db 0
STR4:
db "SCORE: %d",10,"HEALTH: %d",0
db 0
STR5:
db "HIGHSCORE: %d",0
STR6:
db "Return to main menu",0
dw 0
STR7:
db "Game over",0
dd 0
STR8:
db "Game over!",0
times 3 db 0
STR9:
db "SCORE: %d",10,"HIGHSCORE: %d",0
times 6 db 0
STR10:
db "W / D : Move forwards / backwards",10,"A / D : Turn left / right",10,"SPACE : Shoot missiles",10,"",10,"Avoid missiles and shoot them to get points!",0
times 5 db 0
FP0:
dq 1.0000000000
FP1:
dq 5.0000000000
FP2:
dq 0.0000000000
FP3:
dq 0.5000000000
FP4:
dq -500.0000000000
FP5:
dq 25.0000000000
FP6:
dq 21.2500000000
FP7:
dq -25.0000000000
FP8:
dq -21.2500000000
FP9:
dq 18.7500000000
FP10:
dq -90.0000000000
FP11:
dq 2.0000000000
FP12:
dq 8.3333333333
FP13:
dq 6.2831853072
FP14:
dq -1.0000000000
FP15:
dq 0.0174532925
FP16:
dq 0.2500000000
FP17:
dq 0.9950000000
FP18:
dq 0.0100000000
FP19:
dq -2.0000000000
FP20:
dq 3.0000000000
