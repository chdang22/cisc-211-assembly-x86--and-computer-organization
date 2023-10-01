section .text
	global _start

_start:
;eq1 = -var1*10
	;math
	mov al, [var1] 		;AL = var1
	neg al				;negate var1
	;below i dont need to use imul bc -0*10 is not signed arithmetic
	;however i assume -var1 was included to make practive with imul
	;so i used imul to satisfy what i think is goal of activity
	imul eax,eax,10 	;Multiply AL (negated var1) by 10 and store the result in EAX
    ;convert and store
    add eax, '0'		;convert
    mov [result], eax	;put product in result memory
	
	;print msg1
	mov eax, 4 			;write
	mov ebx, 1  		;out
	mov ecx, msg1		;ptr msg1
	mov edx, len1		;msg1 length
	int 0x80			;syscall

	;print result
    mov eax, 4        	; write
	mov ebx, 1        	; out
	mov ecx, result   	; move the result to ecx to print
	mov edx, 1       	; Length of the output
	int 0x80  
;eq2=v1+v2+v3+v4
	;math
	mov eax, [var1]
	mov ebx, [var2]
	add eax,ebx			;eax=var1+var2
	mov ecx, [var3]
	mov edx, [var4]
	add ecx, edx		;ecx=var3+var4
	add eax, ecx		;eax= eax+ecx
	
	add eax, '0'		;convert
	mov [result], eax	;put product in result memory
    
	;print msg2
	mov eax, 4 			;write
	mov ebx, 1  		;out
	mov ecx, msg2		;ptr msg2
	mov edx, len2		;msg2 length
	int 0x80			;syscall

	;print result
    mov eax, 4        	; write
	mov ebx, 1        	; out
	mov ecx, result   	; move the result to ecx to print
	mov edx, 1       	; length of the output
	int 0x80  
;eq3=(-var*var2)+var3
	;math
	mov al, [var1] 		;AL = var1 = multiplicand
	neg al				;negate var1
	mov dl, [var2]		;multiplier	
	imul dl 			;eax=al*dl=-var1*var2
	mov ebx, [var3]
	add eax,ebx			;eax+=ebx
	
	;convert and store
    add eax, '0'		;convert
    mov [result], eax	;put product in result memory

    ;print msg3
	mov eax, 4 			;write
	mov ebx, 1  		;out
	mov ecx, msg3		;ptr msg3
	mov edx, len3		;msg3 length
	int 0x80			;syscall

	;print result
    mov eax, 4        	; write
	mov ebx, 1        	; out
	mov ecx, result   	; move the result to ecx to print
	mov edx, 1       	; length of the output
	int 0x80  
;eq4 = (var1*var2)/(var2-3)
	;math
	mov al, [var1] 		;al = var1 = multiplicand		
	mov bl, [var2]		;bl =multiplier	
	mul bl 				;al=al*bl=var1*var2
	mov cl, [var2]		;cl=var2
	sub cl, 3  			;cl=var2-3
	div cl				;al=ax/cl(if doing int div)

	;convert and store
    add al, '0'		;convert
    mov [result], eax	;put product in result memory

    ;print msg4
	mov eax, 4 			;write
	mov ebx, 1  		;out
	mov ecx, msg4		;ptr msg4
	mov edx, len4		;msg4 length
	int 0x80			;syscall

	;print result
    mov eax, 4        	; write
	mov ebx, 1        	; out
	mov ecx, result   	; move the result to ecx to print
	mov edx, 1       	; length of the output
	int 0x80  


	;exit
	mov eax,1
	int 0x80





section .data
	msg1 db 'Eq1= '			;msgs for display eq results
	len1 equ $ - msg1		;offset size of msgs

	msg2 db 0xA,'Eq2= '
	len2 equ $ - msg2

	msg3 db 0xA,'Eq3= '
	len3 equ $ - msg3
	
	msg4 db 0xA,'Eq4= '
	len4 equ $ - msg4

	var1 db 0				;initialized variables
	var2 db 4
	var3 db 2
	var4 db 3

section .bss
	result resb 1			;unitialized result to store results from equations