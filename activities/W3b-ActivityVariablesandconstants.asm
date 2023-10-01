section .text
	global _start

_start: 
	
	mov eax, var1
	mov ebx, var2
	add eax, ebx
	add eax, '0'

	mov [result], eax
	mov eax, 4
	mov ebx, 1
	mov ecx, msg
	mov edx, len
	int 0x80

	mov eax,4
	mov ebx,1
	mov ecx, sum
	mov edx, 1
	int 0x80

	mov eax,1
	int 0x80


section .data
msg db 'Sum', 0xA,0xD
len equ $ - msg

var1 db 10
var2 db 15

section .bss
	result resb 1