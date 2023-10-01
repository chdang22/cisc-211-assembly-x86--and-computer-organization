section .text
        global _start

_start:
        ; xor operand with itself changes operand to 0
        mov byte [var1], 5
        mov eax, [var1]
        xor eax, [var2]             ; lhs unitialzied, rhs initalized

        ;check if result is zero
        test eax,eax            ; check eax is zero
        jz iszero               ; jump to zero block when 0
                                ; if jump not 0, then continue
       
       ;result !=0
        mov eax,'n'             ; store n in eax
        mov [result],eax        ; store n, this will print 'n', ascii 110
        jmp print_result        ; jump to print the result

iszero:
        mov eax,'y'     
        mov [result],eax        ; sotre 'y' in res, this will print 'y', ascii 121
        

print_result:
        ; Print the result ('y' or 'n')
        mov eax, 4           ; syswrite
        mov ebx, 1           ; fd, stdout
        mov ecx, result      ; pointer result
        mov edx, 1           ; 1 byte for the character
        int 0x80             ; syscall

        ; Exit the program
        mov eax, 1           ; sysexit
        int 0x80             ; syscall


segment .data
        var2 db 5              ;hold value 5, will be xor with var1

segment .bss
        result resb 1
        var1 resb 1             ;to hold same value as var2=5