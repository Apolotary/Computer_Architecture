extern _perror

extern _fopen
extern _fclose

extern _fread
extern _fwrite

extern _fgetc
extern _fputc

section .data
    ; BMP Header
    bmp_header:
        magic_signature       dw 0
        file_size             dd 0
        reserved              dd 0
        pixel_array_offset    dd 0
        
        bmp_struct_size       equ $-bmp_header

    ; DIB Header
    dib_header:
        dib_header_size       dd 0
        image_width           dd 0
        image_height          dd 0
        planes                dw 0
        bits_per_pixel        dw 0
        compression           dd 0
        image_size            dd 0
        x_pixel_per_meter     dd 0
        y_pixel_per_meter     dd 0
        colors_in_colortable  dd 0
        important_color_count dd 0
        
        dib_struct_size       equ $-dib_header
    
    ; Descriptors
    src_file  db "test.bmp", 0
    dest_file db "result.bmp", 0
    
    ; for fopen
    open_format     db "r", 0
    write_format    db "w", 0
    fo_src          dw 0
    fo_dest         dw 0
    
    ; mysterious shift
    shift           dw 0
    
    ; rounding modes
    r_up            dw 1024
    fs_temp         db 0
    fs_tempn        db 0
    
    ; channels
    blue            dw 0
	green           dw 0
	red             dw 0
    
    blue2           dw 0
	green2          dw 0
	red2            dw 0
    
    blue3           dw 0
	green3          dw 0
	red3            dw 0
    
    ; poor temps
    temp            dw 0
    thirty_two      dw 32.0
    four            dw 4
    counter_ex      dw 0
    counter_in      dw 0
    padding         dw 0
    max_csize       dw 255
    
    red_a           dw 0.393
    red_b           dw 0.769
    red_c           dw 0.189
    
    green_a         dw 0.349
    green_b         dw 0.686
    green_c         dw 0.168
    
    blue_a          dw 0.272
    blue_b          dw 0.534
    blue_c          dw 0.131

section .text
global _main

_main:
    push ebp
    mov ebp, esp

    ; src = fopen(argv[1], "r");
    push open_format
    push src_file
    call _fopen
    add esp, 8
    mov dword[fo_src], eax
    
    ; dst = fopen(argv[2], "w");
    push write_format
    push dest_file
    call _fopen
    add esp, 8
    mov dword[fo_dest], eax
		
    ; fread(&src_bmp_header, sizeof(src_bmp_header), 1, src);
    push dword[fo_src]
    push dword 1
    push dword bmp_struct_size
    push bmp_header
    call _fread
    add esp, 16

	; fread(&src_dib_header, sizeof(src_dib_header), 1, src);
    push dword[fo_src]
    push dword 1
    push dword dib_struct_size
    push dib_header
    call _fread
    add esp, 16
    
    ; fwrite(&src_bmp_header, sizeof(src_bmp_header), 1, dst);
    push dword[fo_dest]
    push dword 1
    push dword bmp_struct_size
    push bmp_header
    call _fwrite
    add esp, 16
    
	; fwrite(&src_dib_header, sizeof(src_dib_header), 1, dst);
    push dword[fo_dest]
    push dword 1
    push dword dib_struct_size
    push dib_header
    call _fwrite
    add esp, 16
    
    ;shift = src_bmp_header.pixel_array_offset - 
	;			sizeof(src_bmp_header) - 
	;			src_dib_header.dib_header_size;
    fld  dword [shift]
    fadd dword [pixel_array_offset]
    fsub dword [bmp_struct_size]
    fsub dword [dib_struct_size]
    fistp dword [shift]
    
    ; while(shift--)
	; {
    ;    fputc(fgetc(src), dst);
	; }
    .shift_loop:
        ; fgetc(src)
        push dword[fo_src]
        call _fgetc
        add esp, 4
    
        ; fputc(fgetc(src), dst);
        push dword[fo_dest]
        push eax
        call _fputc
        add esp, 8
        
        dec dword [shift]
        cmp dword [shift], dword 0
        jnbe .shift_loop
        
    ; shift = ((int) ceil(src_dib_header.image_width * src_dib_header.bit_per_pixel / 32.0)) * 4;   
    ; src_dib_header.image_width * src_dib_header.bit_per_pixel / 32.0
    fld   dword [temp]
    fadd  dword [image_width]
    fmul  dword [bits_per_pixel]
    fdiv  dword [thirty_two]
    
    fstcw word  [fs_temp]
    push eax
    mov eax, fs_temp
    mov dword[fs_tempn], eax
    pop eax
    
    push ecx
    mov ecx, r_up
    or  dword[fs_temp], ecx
    pop ecx
    
    fldcw word  [fs_temp]
    fistp dword [temp]
    fldcw word  [fs_tempn]
    
    fld   dword [temp]
    fmul  dword [four]
    fistp  dword [shift]
        
    ; shift -= src_dib_header.image_width * 3;
    fld   dword [shift]
    fsub  dword [image_width]
    fsub  dword [image_width]
    fsub  dword [image_width]
    fistp  dword [shift]
    
    ; for (i = 0; i < src_dib_header.image_height; ++i)
	.extern_loop:	

        ; padding = shift;
        push eax
        mov eax, shift
        mov dword[padding], eax
        pop eax
        
        ; for (j = 0; j < src_dib_header.image_width; ++j)
        .intern_loop:
            
            ; blue = fgetc(src);
            push dword[fo_src]
            call _fgetc
            add esp, 4
            mov dword [blue], eax
            
            ; green = fgetc(src);
            push dword[fo_src]
            call _fgetc
            add esp, 4
            mov dword [green], eax
            
            ; red = fgetc(src);
            push dword[fo_src]
            call _fgetc
            add esp, 4
            mov dword [red], eax
            
            ; uint32_t red2    = (0.393 * red + 0.769 * green + 0.189 * blue);
            fld  dword [red]
            fmul dword [red_a]
            fistp dword [red2]
            
            fld  dword [green]
            fmul dword [red_b]
            fadd dword [red2]
            fistp dword [red2]
            
            fld  dword [blue]
            fmul dword [red_c]
            fadd dword [red2]
            fistp dword [red2]
            
            ; uint32_t green2  = (0.349 * red + 0.686 * green + 0.168 * blue);
            fld  dword [red]
            fmul dword [green_a]
            fistp dword [green2]
            
            fld  dword [green]
            fmul dword [green_b]
            fadd dword [green2]
            fistp dword [green2]
            
            fld  dword [blue]
            fmul dword [green_c]
            fadd dword [green2]
            fistp dword [green2]
            
			; uint32_t blue2   = (0.272 * red + 0.534 * green + 0.131 * blue);
            fld  dword [red]
            fmul dword [blue_a]
            fistp dword [blue2]
            
            fld  dword [green]
            fmul dword [blue_b]
            fadd dword [blue2]
            fistp dword [blue2]
            
            fld  dword [blue]
            fmul dword [blue_c]
            fadd dword [blue2]
            fistp dword [blue2]
            
            ; if (red2 > 255)
            ; {
            ;   red2 = 255;
            ; }
            push ecx
            mov  ecx, max_csize
            cmp dword[red2], ecx
            pop ecx
            jbe .check_green
            push eax
            mov eax, max_csize
            mov dword[red2], eax
            pop eax

            ; if (green2 > 255)
            ; {
            ;   green2 = 255;
            ; }
            .check_green:
                push ecx
                mov  ecx, max_csize
                cmp dword[green2], ecx
                pop ecx
                jbe .check_blue
                push eax
                mov eax, max_csize
                mov dword[green2], eax
                pop eax
            
            ; if (blue2 > 255)
            ; {
            ;   blue2 = 255;
            ; }
            .check_blue:
                push ecx
                mov  ecx, max_csize
                cmp dword[blue2], ecx
                pop ecx
                jbe .alls_right
                push eax
                mov eax, max_csize
                mov dword[blue2], eax
                pop eax
                
            .alls_right:
                ; uint8_t red3 = red2;
                push eax
                mov eax, red2
                mov dword[red3], eax
                pop eax
                
                ; uint8_t green3 = green2;
                push eax
                mov eax, green2
                mov dword[green3], eax
                pop eax
                
                ; uint8_t blue3 = blue2;
                push eax
                mov eax, blue2
                mov dword[blue3], eax
                pop eax
                
                ; fputc(blue3, dst);
                push dword[fo_dest]
                push blue3
                call _fputc
                add esp, 8
                
				; fputc(green3, dst);
                push dword[fo_dest]
                push green3
                call _fputc
                add esp, 8
                
				; fputc(red3, dst);
                push dword[fo_dest]
                push red3
                call _fputc
                add esp, 8
            
            inc dword[counter_in]
            push ecx
            mov  ecx, image_width
            cmp dword[counter_in], ecx
            pop ecx
            jnae .intern_loop
            
            ; while (padding--)
			; {
            ;   fputc(fgetc(src), dst);
			; }
            .that_while:
                ; fgetc(src)
                push dword[fo_src]
                call _fgetc
                add esp, 4
            
                ; fputc(fgetc(src), dst);
                push dword[fo_dest]
                push eax
                call _fputc
                add esp, 8
                
                dec dword[padding]
                cmp dword[padding], dword 0
                jnbe .that_while
        
        inc dword[counter_ex]
        push ecx
        mov  ecx, image_height
        cmp dword[counter_ex], ecx
        pop ecx
        jnae .extern_loop
    
    ; while ((tmp = fgetc(src)) != EOF)
    ; {
    ;    fputc(tmp, dst);
    ; }
    .another_while:
        ; tmp = fgetc(src)
        push dword[fo_src]
        call _fgetc
        add esp, 4
        
        ; (tmp = fgetc(src)) != EOF
        cmp eax, 0
        jb .exit_loop
        
        ; fputc(tmp, dst);
        push dword[fo_dest]
        push eax
        call _fputc
        add esp, 8
        
        jmp .another_while
    
    .exit_loop:    
    
    ; fclose(src);
    push dword[fo_src]
    call _fclose
    add esp, 4
    
    ; fclose(dst);
    push dword[fo_dest]
    call _fclose
    add esp, 4
    
    xor eax, eax
    mov esp, ebp
    pop ebp
    
    ret
    