section .data
    result db 1        ; Variable to store the factorial result (initialized to 1)

section .text
    global _start

_start:
    mov ecx, 5         ; Set loop counter to 5 (the number for which we want to find the factorial)

fact_loop:
    dec ecx            ; Decrement the loop counter (ecx)
    cmp ecx, 0         ; Compare if ecx is 0
    jz end_loop        ; If ecx is 0, the loop is done, jump to the end_loop

    mov eax, ecx       ; Load the current loop counter value into eax
    mul byte [result]  ; Multiply the current loop counter value (eax) with the result

    mov [result], al   ; Store the lower 8 bits of the result in the result variable
    mov [result + 1], ah ; Store the upper 8 bits of the result (if any) in the result variable

    jmp fact_loop      ; Jump back to the fact_loop to continue the multiplication

end_loop:
    ; At this point, the result of the factorial is stored in the 'result' variable
    ; You can use it as needed

    ; Add your code here to do something with the result (e.g., print it)

    ; Exit the program
    mov eax, 1         ; 'exit' system call number
    xor ebx, ebx       ; status code 0
    int 0x80           ; invoke the kernel to exit the program
