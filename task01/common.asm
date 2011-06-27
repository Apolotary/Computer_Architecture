%ifndef COMMON_ASM
%define COMMON_ASM

ROWS    equ 80
COLUMNS equ 25

section .text

    set_video_mode:
        push ax

        mov ah, 0
        mov al, 3
        int 0x10

        pop ax

        ret

    clear_screen:
        push ax
        push bx
        push cx
        push es

        mov cx, 0xB800
        mov es, cx

        mov al, ROWS
        mov bl, COLUMNS
        mul bl
        dec ax

        mov cx, ax
        xor bx, bx

        .next:
            mov [es:bx], byte 0
            add bx, 2

            loop .next

        mov [x], byte 0
        mov [y], byte 0

        pop es
        pop cx
        pop bx
        pop ax

        ret

    exit:
        mov ax, 0x4C00
        int 0x21

    put_char:
        push bx
        push dx
        push cx
        push es

        mov cx, 0xB800
        mov es, cx

        push ax
        mov al, [y]
        mov cl, COLUMNS
        mul cl
        add ax, [x]
        mov cx, 2
        mul cx
        mov bx, ax
        pop ax

        mov [es:bx], al

        inc byte [x]
        .check_x:
            cmp [x], byte COLUMNS
            jne .check_y

            mov [x], byte 0
            inc byte [y]

        .check_y:
            cmp [y], byte ROWS
            jne .end

            mov [y], byte 0

        .end:
            pop es
            pop cx
            pop dx
            pop bx

            ret

    print_string:
        push ax
        push si

        .loop:
            mov al, [si]

            cmp al, 0
            je .end

            call put_char
            inc si

            jmp .loop

        .end:
            pop si
            pop ax

            ret

    print_number:
        push ax
        push bx
        push cx
        push dx
        push di

        mov di, buffer
        xor cx, cx

        .loop:
            mov bx, 10
            div bx

            add dx, '0'
            mov [di], dl

            inc di
            inc cx
            xor dx, dx

            cmp ax, 0
            je .print

            jmp .loop

        .print:
            dec di
            mov al, [di]

            call put_char

            loop .print

        pop di
        pop dx
        pop cx
        pop bx
        pop ax

        ret

section .data
    x db 0
    y db 0

section .bss
    buffer resb 100

%endif

