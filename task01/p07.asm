org 0x100

section .text
        ;104743
        call set_video_mode

        mov [res+2], word 2
        mov [res], word 0

        mov si, 10001
        find:
                mov ax, [res+2]
                mov dx, [res]

                ; Split the num by two
                mov bx, 2
                div bx
                mov bx, ax

                mov cx, 2

                .divide:
                        mov ax, [res + 2]
                        mov dx, [res]

                        div cx
                        cmp dx, 0
                        je .next

                        cmp cx, bx
                        je .counter

                        inc cx

                        jmp .divide

                .counter:
                        dec si
                        cmp si, 2
                        je found

                .next:
                        add [res+2], word 1
                        adc [res], word 0
                        jmp find

                found:
                        mov ax, [res+2]
                        mov dx, [res]
                        call print_number

        call exit

section .data
        res     dd 0

%include "common.asm"
