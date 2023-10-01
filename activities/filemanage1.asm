section .data

	filename db 'quotes.txt', 0h

	quote1 db 'To be, or not to be, that is the question.', 0xA, 0xD
	len1 equ $- quote1

	quote2 db 'A fool thinks himself to be wise, but a wise man knows himself to be a fool', 0xA, 0xD
	len2 equ $- quote2

section .bss
	fd_out resb 1
section .text

	GLOBAL _start

_start:

	;create
    mov     ecx, 0711o          
    mov     ebx, filename       
    mov     eax, 8              
    int     0x80   

     mov [fd_out],eax

    ; file open
 	mov eax, 5          ;file handling system call
    mov ebx, filename
    mov ecx, 1
    mov edx, 0777o
    int 0x80
    mov [fd_out],eax



    ; write
    mov eax, 4
    mov ebx, [fd_out]
    mov ecx, quote1
    mov edx, len1
    int 0x80

     ; write
    mov eax, 4
    mov ebx, [fd_out]
    mov ecx, quote2
    mov edx, len2
    int 0x80

    ; file close
    mov eax, 6          ;file handling system call
    mov ebx, [fd_out]
    int 0x80

    ; exit
    mov eax,1
    int 0x80