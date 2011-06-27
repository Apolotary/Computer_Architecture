org 0x100 

section .text
	;233168
	call set_video_mode

	mov ax, 0
	mov cx, 1000
	find: 
		push ax 
		
 		; divide by 3
		xor dx, dx
		mov bx, 3
		div bx
		cmp dx, 0
		jne .div5 
		
		; if dx == 0, then add to res
		xor ax, ax
		pop ax
		add [res + 2], ax
		adc [res], word 0
		push ax
		jmp .next ; to prevent repeated nums
		
		.div5:
			xor dx, dx
			
			; restore ax
			xor ax, ax
			pop ax
			push ax	
			
			; div by 5
			mov bx, 5
			div bx
			cmp dx, 0
			jne .next
			
			; add if dx == 0
			pop ax
			add [res + 2], ax
			adc [res], word 0
			push ax
			
		.next:
			pop ax
			inc ax
			loop find
		
		; clear
		xor ax, ax
		xor dx, dx
		
		; print
		mov ax, [res + 2]
		mov dx, [res]
		call print_number
		
	call exit


section .data
	res dd 0
	
%include "common.asm"
