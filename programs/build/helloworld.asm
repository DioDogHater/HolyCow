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

global add:function
add:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+24]
	mov rcx, [rbp+32]
	add rbx, rcx
	mov [rbp+16], rbx
	jmp .L0
	.L0:
	leave
	ret

global test:function
test:
	push rbp
	mov rbp, rsp
	mov rbx, [rbp+24]
	mov rax, [rbp+32]
	mov rcx, [rbp+40]
	imul rcx
	add rbx, rax
	mov [rbp+16], rbx
	jmp .L0
	.L0:
	leave
	ret

global print_numbers:function
print_numbers:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	lea rbx, [rbp+24]
	mov [rsp+8], rbx
	mov bl, 0x3e
	mov [rsp+7], bl
	mov rbx, [rbp+16]
	.L1:
	test rbx, rbx
	je .L3
	sub rsp, 32
	mov [rsp+24], rbx
	mov rcx, STR0
	mov [rsp+0], rcx
	movzx rcx, BYTE [rsp+39]
	mov [rsp+8], rcx
	mov rcx, [rsp+40]
	mov rsi, [rcx]
	mov [rsp+16], rsi
	call print
	mov rbx, [rsp+24]
	add rsp, 32
	mov rcx, [rsp+8]
	add rcx, 0x8
	mov [rsp+8], rcx
	mov cl, 0x2c
	mov [rsp+7], cl
	.L2:
	dec rbx
	jmp .L1
	.L3:
	sub rsp, 16
	mov bl, 0xa
	mov [rsp+0], bl
	mov rbx, QWORD [stdout]
	mov [rsp+8], rbx
	call print_char
	add rsp, 16
	.L0:
	leave
	ret

global main:function
main:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	sub rsp, 16
	mov rbx, STR1
	mov [rsp+0], rbx
	call println
	add rsp, 16
	sub rsp, 32
	mov rbx, STR2
	mov [rsp+0], rbx
	mov rbx, 0x5
	mov [rsp+8], rbx
	mov rbx, 0x14
	mov [rsp+16], rbx
	call println
	add rsp, 32
	sub rsp, 16
	mov rbx, STR3
	mov [rsp+0], rbx
	mov rbx, 0x14
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 16
	mov rbx, STR4
	mov [rsp+0], rbx
	mov rbx, 0x14
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 16
	mov rbx, STR5
	mov [rsp+0], rbx
	mov rbx, 0x14
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 16
	mov rbx, STR6
	mov [rsp+0], rbx
	mov rbx, 0x14
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 16
	mov rbx, STR7
	mov [rsp+0], rbx
	mov rbx, 0x14
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 16
	mov rbx, STR8
	mov [rsp+0], rbx
	mov rbx, STR9
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 32
	mov rbx, STR10
	mov [rsp+0], rbx
	mov rbx, 0x5
	mov [rsp+8], rbx
	mov rbx, STR11
	mov [rsp+16], rbx
	call println
	add rsp, 32
	lea rbx, [rsp+16]
	sub rsp, 32
	mov [rsp+0], rbx
	mov rbx, STR12
	mov [rsp+8], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+16], rbx
	call string.from_str
	add rsp, 32
	sub rsp, 16
	mov rbx, STR13
	mov [rsp+0], rbx
	lea rbx, [rsp+32]
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 16
	mov rbx, STR14
	mov [rsp+0], rbx
	mov rbx, 0x40
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 32
	mov rbx, STR15
	mov [rsp+0], rbx
	mov rbx, 0x5
	mov [rsp+8], rbx
	mov rbx, 0x2a
	mov [rsp+16], rbx
	call println
	add rsp, 32
	sub rsp, 16
	mov rbx, STR16
	mov [rsp+0], rbx
	mov rbx, 0xfffffffffffffd79
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 16
	mov rbx, STR17
	mov [rsp+0], rbx
	mov rbx, 0x19084
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 16
	mov rbx, STR18
	mov [rsp+0], rbx
	mov rbx, 0x19
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 16
	mov rbx, STR19
	mov [rsp+0], rbx
	mov rbx, 0xbeef
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 16
	mov rbx, STR20
	mov [rsp+0], rbx
	mov rbx, 0x1
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 32
	mov rbx, STR21
	mov [rsp+8], rbx
	mov rbx, 0xffffffffffffffff
	mov [rsp+16], rbx
	call fixed.from_string
	mov ebx, [rsp+0]
	add rsp, 32
	mov [rsp+12], ebx
	sub rsp, 16
	mov rbx, STR22
	mov [rsp+0], rbx
	movsxd rbx, DWORD [rsp+28]
	mov [rsp+8], rbx
	call println
	add rsp, 16
	sub rsp, 16
	mov rbx, STR23
	mov [rsp+0], rbx
	mov DWORD [__FP_TMP], 0xc181b368
	fld DWORD [__FP_TMP]
	fstp QWORD [rsp+8]
	call println
	add rsp, 16
	sub rsp, 32
	mov rbx, STR24
	mov [rsp+0], rbx
	mov rbx, 0x6
	mov [rsp+8], rbx
	mov DWORD [__FP_TMP], 0xc181b37a
	fld DWORD [__FP_TMP]
	fstp QWORD [rsp+16]
	call println
	add rsp, 32
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
extern string.str:function
extern string.length:function
extern string.print:function
extern string.compare:function
extern string.is_equal:function
extern string.is_heap:function
extern string.is_stack:function
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
extern string.from_heap:function
extern string.share:function
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
extern File:data
extern fixed:data
extern string:data


section .rodata
STR0:
db "%c %i",0
STR1:
db "Hello world!",0
STR2:
db "%A5 chars%A20 chars",0
STR3:
db "[%[Aligned left%L]",0
STR4:
db "[%[Aligned right%R]",0
STR5:
db "[%[Centered%C]",0
STR6:
db "%[This is way too long and I want it short%T",0
STR7:
db "%[This is way too long and I want it short%*T",0
STR8:
db "string:            ",34,"%s",34,"",0
STR9:
db "HolyCow!",0
STR10:
db "length string:     ",34,"%*s",34,"",0
STR11:
db "1234567890",0
STR12:
db "HolyCow string object!",0
STR13:
db "string object:     ",34,"%S",34,"",0
STR14:
db "character:         '%c'",0
STR15:
db "repeated character: %*c",0
STR16:
db "signed int:         %i",0
STR17:
db "unsigned int:       %u",0
STR18:
db "n length uint:      %04",0
STR19:
db "uint (hex):         %x",0
STR20:
db "bool:               %b",0
STR21:
db "-16.2126",0
STR22:
db "fixed point:        %F",0
STR23:
db "float:              %f",0
STR24:
db "float (n digits):   %*f",0
