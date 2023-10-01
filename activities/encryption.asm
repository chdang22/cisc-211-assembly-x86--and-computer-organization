section .data
;text to write to file (like labels)
	plain db 'Plain text: pup', 0xA, 0xD
	len1 equ $- plain
	
	key2 db 'Key: paw',0xA, 0xD
	len2 equ $- key2
	
	enc3 db 'Encrypted: '
	len3 equ $- enc3

	dec4 db 0xA, 0xD, 'Decrypted: '
	len4 equ $- dec4
	
;text for decryption and encryption
	message db 'pup'		; plain text msg to be encrypt (secret message)
	key db 'paw'			; key
	keydecryption db 01110000b, 01100001b, 01110111b ; "paw" in binary (b is to let system know is binary)

	filename db 'output.txt', 0h ; filename to create

	
section .bss
	;variables to hold results and conversion
	encrypted resb 6	;store encryption
	decrypted resb 6	;store decryption
	encrypted_hex resb 6;store hex version of encryption

	fd_out resb 1 		;hold file descriptor

section .text
	GLOBAL _start
	GLOBAL binary_to_hex    ; Declare binary_to_hex as global

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
    mov ebx, filename	; ptr
    mov ecx, 1 			; flags wtrite only
    int 0x80			


    ;write to file first two lines
    mov eax,4
	mov ebx, [fd_out]	; file descript
	mov ecx, plain		; "Plain text: pup'"
	mov edx, len1
	int 0x80

	mov eax,4
	mov ebx, [fd_out]	;file descript
	mov ecx, key2		;'Key: paw'
	mov edx, len2
	int 0x80

;begin encryption
	; load address of msg and key into registers
	mov esi, message	; source (pup)
	mov edi, key 		; destination (paw)
	mov ecx,3			; length of msg (loop counter)
	mov ebx, encrypted	; store encrypted (result of xor source with destination)

;encryption loop : loads one byte at a time into al and xor with corresponding edi (key) byte
encrypt_loop:
    lodsb               ; load next byte of msg to al
    xor al, [edi]		; xor pup and paw
    mov [ebx], al 		; store byte into ebx
    inc edi             ; move to next key byte
    inc ebx 			; next position in ebx, ready for next iteration to store in
    loop encrypt_loop


    ; call convert to hex
    ;takes esi and edi as arguments
    mov esi, encrypted		; address of source buffer (binary)
    mov ecx, 3 				; len of source (3 bytes, 8 bit binary)
    mov edi, encrypted_hex	; destination address (for hex rep of binary)
    call binary_to_hex

;write file encrypted
	mov eax,4
	mov ebx, [fd_out]	;file descript
	mov ecx, enc3
	mov edx, len3
	int 0x80

	mov eax,4
	mov ebx, [fd_out]	;file descript
	mov ecx, encrypted_hex
	mov edx, 6
	int 0x80

;decryption
	; Load the encrypted message and key
	mov esi, encrypted     		; Address of the encrypted message
	mov edi, keydecryption      ; Address of the key
	mov ecx, 3             		; Length of the message
	mov ebx, decrypted			; address to hold decrypted
decrypt_loop:
    lodsb               ; load next byte of encrypted to al
    xor al, [edi]		; xor enrcypted and key
    mov [ebx], al 		; store byte in decrypted
    inc edi             ; move to next key byte
    inc ebx				; next byte in decrypted 
    loop decrypt_loop
	
	mov byte [ebx], 0 	;null terminate

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
;   esi: Pointer to 3 bytes of 8-bit binary data
;   edi: Pointer to the destination buffer to store the hexadecimal string
;	1. convert loop: loads 8 bit integer into al
;					 calls byte to hex
;	2. byte to hex: splits 8 bit into 2 nibbles and calls nibble to hex, then stores into destination buffer
;	3. nibble to hex:
binary_to_hex:
    mov ecx, 3          ; Number of bytes to convert
    mov ebx, edi        ; Destination buffer pointer

convert_loop:
    mov al, byte [esi]  ; Load the next byte of binary data
    call byte_to_hex    ; Convert the byte to hexadecimal and store it in the destination buffer

    inc esi             ; Move to the next byte in the source buffer
    add ebx, 2          ; Move to the next 2 bytes in the destination buffer (for two hexadecimal characters)
    loop convert_loop   ; Repeat the loop for the next byte

    ret

; Converts a single byte (8-bit value in al) to its hexadecimal representation and stores it in the destination buffer (ebx)
byte_to_hex:
	;first left 4 bits (first nibble)
    mov ah, al          ; Copy the original value of al to ah
    shr al, 4           ; Shift right to get the upper 4 bits in al
    call nibble_to_hex_char ; Convert the upper 4 bits to a hexadecimal character
    mov [ebx], al       ; Store the hexadecimal character in the destination buffer

    ; Convert the lower 4 bits to a hexadecimal character
    mov al, ah          ; Restore the original value of al (lower 4 bits)
    and al, 0x0F        ; Mask the lower 4 bits to get the hexadecimal value
    call nibble_to_hex_char ; Convert the lower 4 bits to a hexadecimal character
    mov [ebx + 1], al   ; Store the hexadecimal character in the destination buffer

    ret 	;return to convert loop

; Converts a 4-bit value (in al) to its hexadecimal character representation
nibble_to_hex_char:
    cmp al, 9			;compare nibble with 9
    jbe skip_addition	; go to skip addition if value is less than or equal to 9

    ; if AL is greater than nine it represents a value 10 to 15 (A-F)
    ; it needs to be converted corresponding hex char
    add al, 'A' - 10 	; gives us ascii hex code of char (A-F)
    jmp done

skip_addition:
	; if less than or equal to 9, it represents value from 0-9 in hex
	; so dont do anything
    add al, '0' 		;conver to string representation

done:
    ret 	;return from nibble function back to byte to hex