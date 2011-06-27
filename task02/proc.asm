%ifndef PROC_ASM
%define PROC_ASM

section .text
    ;257114
	problem01:
        mov [fnum1], dword 0	    ; first number  0	
        mov [snum1], dword 1	    ; second number 1
        mov [sum1],  dword 0
        mov cx, 27
        find:
            test [fnum1], word 1
            jz nextnum
            mov ax, [fnum1]
            mov dx, [fnum1 + 2]
            add [sum1], ax
            adc [sum1 + 2], dx
            nextnum:
                mov ax, [snum1]
                mov dx, [snum1 + 2]
                add [fnum1], ax
                adc [fnum1 + 2], dx
                xchg ax, [fnum1]
                xchg dx, [fnum1 + 2]
                xchg ax, [snum1]
                xchg dx, [snum1 + 2]
                loop find
        mov ax, [sum1]
        mov dx, [sum1 + 2]
        ret
        
    ;-355323
    problem02:
	mov [fnum2], dword 1	    ; first number   1	
	mov [snum2], dword -1	    ; second number -1
    mov [sum2],  dword 0
	mov cx, 28   ; counter
	find2:
		test [fnum2], word 1
		jz nextnum2
        mov ax, [fnum2]
        mov dx, [fnum2 + 2]
		add [sum2], ax
		adc [sum2 + 2], dx
		nextnum2:
			mov ax, [snum2]
            mov dx, [snum2 + 2]
            sub [fnum2], ax
			sbb [fnum2 + 2], dx
            xchg ax, [fnum2]
            xchg dx, [fnum2 + 2]
            xchg ax, [snum2]
            xchg dx, [snum2 + 2]
			loop find2
    mov ax, [sum2]
	mov dx, [sum2 + 2]
    ret
    
section .data
	sum1  dd 0
    sum2  dd 0
	fnum1 dd 0 ; first num
	snum1 dd 0 ; second num
    fnum2 dd 0 ; first num
	snum2 dd 0 ; second num
%endif
