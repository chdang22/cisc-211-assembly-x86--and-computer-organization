section .data
	plain db 'Plain text: pup', 0xA, 0xD
	len1 equ $- plain
	
	key2 db 'Key: paw',0xA, 0xD
	len2 equ $- key2
	
	enc3 db 'Encrypted: '
	len3 equ $- enc3

	dec4 db 0xA,'Decrypted: '
	len4 equ $- dec4
	
	message db 'pup'		; plain text msg to be encrypt (secret message)
	key db 'paw'			; key
	keydecryption db 01110000b, 01100001b, 01110111b ; "paw" in binary (01110000 01100001 01110111)

	filename db 'output.txt', 0h ; filename to create

	

section .bss
	encrypted resb 6
	decrypted resb 6

	fd_out resb 1

section .text
	GLOBAL _start

_start:
	;create file
	mov     ecx, 0711o 			; set all permissions to read, write, execute (octal format)
    mov     ebx, filename       ; filename we will create
    mov     eax, 8              ; invoke SYS_CREAT (kernel opcode 8)
    int     0x80                ; call the kernel
 	
 	;save file desriptor
 	mov [fd_out], eax

 	;file open operation
    mov eax, 5          ; sys open
    mov ebx, filename	;ptr
    mov ecx, 1 			;flags wtrite only
    int 0x80			


    ;write to file first two lines
    mov eax,4
	mov ebx, [fd_out]	;file descript
	mov ecx, plain
	mov edx, len1
	int 0x80

	mov eax,4
	mov ebx, [fd_out]	;file descript
	mov ecx, key2
	mov edx, len2
	int 0x80


	; load address of msg and key into registers
	mov esi, message
	mov edi, key
	mov ecx,3			; length of msg
	mov ebx, encrypted	;store encrypted


encrypt_loop:
    lodsb               ; load next byte of msg to al
    xor al, [edi]
    mov [ebx], al
    inc edi             ; move to next key byte
    inc ebx
    loop encrypt_loop

	mov byte [ebx], 0

;write file encrypted
	mov eax,4
	mov ebx, [fd_out]	;file descript
	mov ecx, enc3
	mov edx, len3
	int 0x80

	mov eax,4
	mov ebx, [fd_out]	;file descript
	mov ecx, encrypted
	mov edx, 4
	int 0x80


	xor ebx,ebx
;decryption
	; Load the encrypted message and key
	mov esi, encrypted     ; Address of the encrypted message
	mov edi, keydecryption           ; Address of the key
	mov ecx, 3             ; Length of the message
	mov ebx, decrypted
decrypt_loop:
    lodsb               ; load next byte of msg to al
    xor al, [edi]
    mov [ebx], al
    inc edi             ; move to next key byte
    inc ebx
    loop decrypt_loop
	
	mov byte [ebx], 0

;write file decrypted
	mov eax,4
	mov ebx, [fd_out]	;file descript
	mov ecx, dec4
	mov edx, len4
	int 0x80

	mov eax,4
	mov ebx, [fd_out]	;file descript
	mov ecx, decrypted
	mov edx, 3
	int 0x80

  	;file close operation
    mov eax, 6          ;file handling system call
    mov ebx, [fd_out]
    int 0x80

    mov eax, 1
    int 0x80

