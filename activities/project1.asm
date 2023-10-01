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

	encrypted resb 3		; space to store encrypted
	encrypted_hex_buffer resb 6  ; hex rep of encryoted

	decrypted resb 3		; space to store decrypted msg (same size as msg)
	decrypted_hex_buffer resb 6
	decrypted_text resb 3
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
	mov ebx,encrypted 	; 


encrypt_loop:
    lodsb               ; load next byte of msg to al
    xor al, [edi]
    mov [ebx], al       ; store encrypted byte into encrypted buffer
    inc edi             ; move to next key byte
    inc ebx             ; move to next byte in encrypted buffer
    loop encrypt_loop

done_encrypting:
	 mov byte [ebx], 0

	 ; Convert the encrypted buffer to hexadecimal
    lea esi, encrypted         ; Load the address of the encrypted buffer into esi
    mov ecx, 3                ; Set the loop counter to the length of the encrypted buffer (change this according to your buffer size)
    lea edi, encrypted_hex_buffer ; Load the address of the destination buffer into edi
    call convert_to_hex

    ; Terminate the hexadecimal string with a null terminator
    mov byte [edi], 0         ; Store null terminator at the end of the destination buffer


;write file encrypted
	mov eax,4
	mov ebx, [fd_out]	;file descript
	mov ecx, enc3
	mov edx, len3
	int 0x80

	mov eax,4
	mov ebx, [fd_out]	;file descript
	mov ecx, encrypted_hex_buffer
	mov edx, 6
	int 0x80

	mov eax,4
	mov ebx, [fd_out]	;file descript
	mov ecx, encrypted
	mov edx, 6
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
    mov [ebx], al       ; store encrypted byte into encrypted buffer
    inc edi             ; move to next key byte
    inc ebx             ; move to next byte in encrypted buffer
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

; Input:
;   esi: source buffer (binary)
;   ecx: length of the source buffer (number of bytes)
;   edi: destination buffer (hexadecimal)

convert_to_hex:
    xor ebx, ebx            ; Clear ebx (used for index in destination buffer)
convert_loop:
    test ecx, ecx           ; Check if we have processed all bytes
    jz done_converting      ; If ecx is zero, we are done

    mov al, byte [esi]      ; Load a byte from the source buffer into al

    ; Convert the upper 4 bits to a hexadecimal character
    mov ah, al              ; Copy the original value of al to ah
    shr al, 4               ; Shift right to get the upper 4 bits in al
    call nibble_to_hex_char ; Convert the upper 4 bits to a hexadecimal character
    cmp ebx, 0             ; Check if the first hexadecimal character is '0'
    je skip_leading_zero    ; If it is '0', skip storing it in the destination buffer
    mov [edi + ebx], al     ; Store the hexadecimal character in the destination buffer

    ; Convert the lower 4 bits to a hexadecimal character
    mov al, ah              ; Restore the original value of al (lower 4 bits)
    and al, 0x0F            ; Mask the lower 4 bits to get the hexadecimal value
    call nibble_to_hex_char ; Convert the lower 4 bits to a hexadecimal character
    mov [edi + ebx + 1], al ; Store the hexadecimal character in the destination buffer
    add ebx, 2              ; Move the index in the destination buffer forward by 2 bytes (2 characters)

    inc esi                 ; Move to the next byte in the source buffer
    dec ecx                 ; Decrement the loop counter
    jmp convert_loop        ; Repeat the loop

done_converting:
    ; Null-terminate the string
    mov byte [edi + ebx], 0

    ret

skip_leading_zero:
    ; Convert the lower 4 bits to a hexadecimal character
    mov al, ah              ; Restore the original value of al (lower 4 bits)
    and al, 0x0F            ; Mask the lower 4 bits to get the hexadecimal value
    call nibble_to_hex_char ; Convert the lower 4 bits to a hexadecimal character
    mov [edi + ebx], al     ; Store the hexadecimal character in the destination buffer
    add ebx, 1              ; Move the index in the destination buffer forward by 1 byte (1 character)

    inc esi                 ; Move to the next byte in the source buffer
    dec ecx                 ; Decrement the loop counter
    jmp convert_loop        ; Repeat the loop

nibble_to_hex_char:
    ; Converts a 4-bit value (in al) to its hexadecimal character representation
    cmp al, 9
    jbe skip_addition
    add al, 'A' - 10
    jmp done

skip_addition:
    add al, '0'

done:
    ret


; Binary to ASCII conversion function
binary_to_ascii:
    mov edx, ecx          ; Save the length of the message (number of bytes) in edx
    xor ebx, ebx          ; Clear ebx (used for index in destination buffer)
convert_loop2:
    test edx, edx         ; Check if we have processed all bytes
    jz done_converting2    ; If edx is zero, we are done

    mov al, byte [esi]    ; Load a byte from the source buffer into al
    add al, '0'           ; Convert the binary value to ASCII character ('0' or '1')
    mov [edi + ebx], al   ; Store the ASCII character in the destination buffer

    inc esi               ; Move to the next byte in the source buffer
    inc ebx               ; Move to the next byte in the destination buffer
    dec edx               ; Decrement the loop counter
    jmp convert_loop2      ; Repeat the loop

done_converting2:
    mov byte [edi + ebx], 0 ; Null-terminate the ASCII string
    ret