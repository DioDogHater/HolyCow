section .text
BITS 64
CPU ALL
default REL

global __exception_push:function
__exception_push:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, QWORD [__exception_idx]
	mov rcx, 0x40
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L1
	sub rsp, 16
	mov rbx, STR0
	mov [rsp+0], rbx
	mov rbx, 0x40
	mov [rsp+8], rbx
	call error
	add rsp, 16
	.L1:
	.L2:
	lea rcx, [__exception_buff]
	mov rsi, QWORD [__exception_idx]
	inc QWORD [__exception_idx]
	lea rsi, [rsi+rsi*2]
	lea rbx, [rcx+rsi*8]
	mov [rsp+8], rbx
	mov rbx, [rsp+8]
	lea rbx, [rbx+16]
	mov rcx, [rsp+8]
	lea rcx, [rcx+8]
	mov rsi, [rsp+8]
	lea rsi, [rsi+0]
	mov QWORD [rbx], rax
    mov QWORD [rcx], rdx
    mov QWORD [rsi], rsp
    add QWORD [rsi], 16
	.L0:
	leave
	ret

global __exception_pop:function
__exception_pop:
	push rbp
	mov rbp, rsp
	mov rbx, QWORD [__exception_idx]
	xor rcx, rcx
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L1
	sub rsp, 16
	mov rbx, STR1
	mov [rsp+0], rbx
	call error
	add rsp, 16
	.L1:
	.L2:
	mov rbx, QWORD [__exception_idx]
	dec QWORD [__exception_idx]
	.L0:
	leave
	ret

global __exception_throw:function
__exception_throw:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov rbx, QWORD [__exception_idx]
	xor rcx, rcx
	cmp rbx, rcx
	sete bl
	test bl, bl
	je .L1
	mov rbx, [rsp+8]
	lea rbx, [rbx+0]
	mov rcx, [rsp+8]
	lea rcx, [rcx+8]
	mov [rbx], rax
	mov [rcx], rdx
	sub rsp, 32
	mov rbx, STR2
	mov [rsp+0], rbx
	mov rcx, [rsp+40]
	mov rbx, [rcx+0]
	mov [rsp+8], rbx
	mov rcx, [rsp+40]
	mov rbx, [rcx+8]
	mov [rsp+16], rbx
	call error
	add rsp, 32
	.L1:
	.L2:
	lea rcx, [__exception_buff]
	dec QWORD [__exception_idx]
	mov rsi, QWORD [__exception_idx]
	lea rsi, [rsi+rsi*2]
	lea rbx, [rcx+rsi*8]
	mov [rsp+8], rbx
	mov rcx, [rsp+8]
	mov rbx, [rcx+0]
	mov rsi, [rsp+8]
	mov rcx, [rsi+8]
	mov rdi, [rsp+8]
	mov rsi, [rdi+16]
	mov rsp, rbx
    mov rbp, rcx
    jmp rsi
	.L0:
	leave
	ret


extern log:function
extern get_allocated_heap:function
extern sin:function
extern print_char:function
extern trunc:function
extern print:function
extern set_rounding:function
extern pow:function
extern memmove:function
extern is_printable:function
extern get_free_heap:function
extern random:function
extern is_num:function
extern memset:function
extern string_to_double:function
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
extern main:function
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
extern _align:function
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
extern is_whitespace:function
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
extern File.get_buffering:function
extern File.set_buffer:function
extern File.flush:function
extern string.print:function
extern string.copy:function
extern string.slice:function
extern string.replace:function
extern string.find:function
extern string.dfind:function
extern string.compare:function
extern string.is_equal:function
extern string.str_equal:function
extern string.is_heap:function
extern string.is_shared:function
extern string.free:function
extern vector.reserve:function
extern vector.copy:function
extern vector.in_range:function
extern vector.at:function
extern vector.pushback:function
extern vector.popback:function
extern vector.append_arr:function
extern vector.append:function
extern vector.insert:function
extern vector.remove:function
extern vector.free:function
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
extern vector.empty:function
extern vector.new:function
extern vector.from_arr:function
extern __exception_push:function
extern __exception_pop:function
extern __exception_throw:function


section .data align=16
__FP_TMP: times 4 dq 0
__GP_TMP: times 4 dq 0
extern stdout:data
extern stdin:data
global __exception_idx:data
__exception_idx:
dq 0
global __exception_buff:data
__exception_buff:
times 1536 db 0
extern File:data
extern fixed:data
extern string:data
extern vector:data


section .rodata align=16
__FABS_MASKd: dq 0x7FFFFFFFFFFFFFFF, 0
__FABS_MASKs: dd 0x7FFFFFFF, 0, 0, 0
__FNEG_MASKd: dq 0x8000000000000000, 0
__FNEG_MASKs: dd 0x80000000, 0, 0, 0
STR0:
db "Max try ... catch limit of %i reached!",0
times 7 db 0
STR1:
db "Cannot pop inexistant exception!",0
times 5 db 0
STR2:
db "Exception %i : %s",0
dd 0
