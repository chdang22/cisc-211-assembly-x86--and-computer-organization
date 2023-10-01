_foobar:
    push    ebp
    mov     ebp, esp
    sub     esp, 16
    mov     eax, DWORD[ebp+8]
    add     eax, 2
    mov     DWORD[ebp-4], eax
    mov     eax, DWORD[ebp+12]
    add     eax, 3
    mov     DWORD[ebp-8], eax
    mov     eax, DWORD[ebp+16]
    add     eax, 4
    mov     DWORD[ebp-12], eax
    mov     eax, DWORD[ebp-8]
    mov     edx, DWORD[ebp-4]
    lea     eax, [edx+eax]
    add     eax, DWORD[ebp-12]
    mov     DWORD[ebp-16], eax
    mov     eax, DWORD[ebp-4]
    imul    eax, DWORD[ebp-8]
    imul    eax, DWORD[ebp-12]
    add     eax, DWORD[ebp-16]
    ret

section .text
        global _start
_start:
     push    5
     push    10
     push    15
     call    _foobar

     mov     ebx, 0
     mov     eax, 1