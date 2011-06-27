org 0x100 
;-98209
section .text
	call set_video_mode
    call problem01
    mov [sum], ax
    mov [sum + 2], dx
    call problem02
    add [sum], ax
    adc [sum + 2], dx
	mov ax, [sum]
	mov dx, [sum + 2]
	call print_int
	call exit
section .data
	sum  dd 0
%include "common.asm"
%include "proc.asm"
