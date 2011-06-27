org 0x100 
section .text
	;-355323
	call set_video_mode
	mov [fnum], dword 1	    ; first number 1	
	mov [snum], dword -1	; second number -1
    mov [sum], dword 0
	mov cx, 28   ; counter
	find:
		test [fnum], word 1
		jz nextnum
        mov ax, [fnum]
        mov dx, [fnum + 2]
		add [sum], ax
		adc [sum + 2], dx
		nextnum:
			mov ax, [snum]
            mov dx, [snum + 2]
            sub [fnum], ax
			sbb [fnum + 2], dx
            xchg ax, [fnum]
            xchg dx, [fnum + 2]
            xchg ax, [snum]
            xchg dx, [snum + 2]
			loop find
	; print
	mov ax, [sum]
	mov dx, [sum + 2]
	call print_int
	call exit
section .data
    sum  dd 0
	fnum dd 0 ; first num
	snum dd 0 ; second num
%include "common.asm"
