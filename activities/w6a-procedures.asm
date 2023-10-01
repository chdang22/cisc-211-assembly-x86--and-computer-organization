section .text
    global _start

_start:
    ; initialize counter to ascii for A
    mov eax, 'A'
    mov ecx, 26
    
    loop:
    ; Call print procedure
    mov [letter], eax
    push ecx
    call print
    pop ecx

    ; Inc eax
    inc eax

    ; Jump to generate_characters
    loop loop

    call exit

exit:
    mov eax,1 
    int 0x80

print:
    ; Prepare for printing
    mov eax, 4       ; sys_write
    mov ebx, 1       ; stdout 
    mov ecx, letter    
    mov edx, 1       
    int 0x80   

    ; Print a line feed (ASCII code for line feed)
    mov eax, 4      ; 'sys_write' system call number
    mov ebx, 1      ; File descriptor (stdout)
    mov ecx, lf     ; Value to print (line feed)
    mov edx, 1      ; Number of bytes to be printed (1 character)
    int 0x80        ; Invoke the kernel to print the line feed

    ; Restore letter into eax
    mov eax, [letter] 

    ret             ; Return from procedure

segment .bss
    letter resb 1

section .data
    lf db 10        ; Line feed character
