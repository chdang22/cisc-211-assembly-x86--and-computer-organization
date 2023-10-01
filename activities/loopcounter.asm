section .data

 	filename db 'counter_fun.txt', 0
    newline db 0xA, 0xD
    len equ $- newline
section .bss
	counter resd 1 ;for increment
	counter_text resb 6
	fd_out resb 1 	; to hold file descriptor
section .text
	GLOBAL _start

_start:
	; File open operation
	mov eax, 5			;file handle call
	mov ebx, filename	
	mov ecx, 1
	mov edx, 0777o
	int 0x80

	mov [fd_out], eax 	;store file descriptor in fd_out

	; Function call
	push 20000
	call count

	call int_to_str

; Print the counter_text for debugging
    mov eax, 4              ; SYS_WRITE system call
    mov ebx, 1              ; File descriptor 1 (stdout)
    mov ecx, counter_text   ; Pointer to the string
    mov edx, 5              ; Length of the string
    int 0x80                ; Call the kernel to print the counter_text

	; Write to file
	mov eax, 4              ; SYS_WRITE system call
    mov ebx, [fd_out]       ; File descriptor
    mov ecx, counter_text        ; Pointer to the string
    mov edx, 5            	; Length of the string
    int 0x80  
    
    ; Write to file
    mov eax, 4              ; SYS_WRITE system call
    mov ebx, [fd_out]       ; File descriptor
    mov ecx, newline   ; Pointer to the string
    mov edx, len              ; Length of the string
    int 0x80                ; Call the kernel to write the counter_text to file


    ; Close the file
    mov eax, 6              ; SYS_CLOSE system call
    mov ebx, [fd_out]       ; File descriptor
    int 0x80                ; Call the kernel to close the file

    ; Exit the program
    mov eax, 1              ; SYS_EXIT system call
    int 0x80                ; Call the kernel to exit


; count function: generates counter to given argument
;	takes integer as count

count:
	pop edx 	; pop ret address 		
	pop ecx		; pop value into ecx as loop counter
	push edx 	; push ret address back onto stack
	mov eax, 0 	;
	mov ebx, 1	;incrementer

	count_loop:
		add [counter], ebx	;increment counter
		loop count_loop		; loop and decrement ecx

	ret

int_to_str:
	mov ebx, counter_text	;to hold string int
	mov ecx, 10		;divide by 10 to obtain digits
	mov eax, [counter]	;eax holds integer
	

	add ebx, 5	;pt edx to end of buffer
	digit_loop:
		xor edx, edx	;clear high 32 bits of dividend
		div ecx			; div eax by 10, quotient in eax, remain in edx
		add dl, '0'		; convert remainder to ascii

		dec ebx			; dec edi as offset to access next left byte

		mov [ebx], dl 	;use edi as offset to pt to indedx

		
 		
 		test eax, eax           ; Check if quotient is zero
    	jnz digit_loop          ; If not zero, continue loop
		
		ret 	;return after loop


	
