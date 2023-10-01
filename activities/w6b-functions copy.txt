section .data
	
	odd dw 'Odd', 0xA
	len1 equ $ - odd

	even dw 'Even', 0xA
	len2 equ $ - even

	num db 55

section .text
	GLOBAL _start

_start:
	mov eax, [num]
	push eax	
	call parity
	
	mov eax, 1
	int 0x80

parity:
	; function: check parity of number
	; input: eax, number to check (passed via stack)
	; output: print even or odd onto terminal
   	push ebp
   	mov ebp,esp
    mov eax, [ebp+8]   ; Load the argument into ax
    add esp, 4      ; Restore the original stack pointer (undo sub ebp, 2)


	test eax, 1	; test lsb to check if 0 or 1
	jz is_even	; if 0 (even), j label


	; else is odd
	mov eax, 4	; sys_write
	mov ebx, 1	; stdout
	mov ecx, odd	; ptr odd msg
	mov edx, len1	;length
	int 0x80
	
	ret

is_even:
	mov eax, 4	; sys_write
	mov ebx, 1	; stdout
	mov ecx, even	; ptr even msg
	mov edx, len2	;length
	int 0x80
	ret
	
