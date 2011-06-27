extern _puts
extern _printf
extern _scanf

section .data
    msg1            db "Input numbers: ", 0
    input_format    db "%lf"
    output_format   db "Arithmetic Mean: %lf", 10, 0
    
    sum             dq 0.0
    counter         dq 0.0
    temp            dq 0.0
    one             dq 1.0
    res             dq 0.0
    
section .text
global _main

_main:
    push ebp
	mov ebp, esp

    push msg1
	call _puts
	add esp, 4
    mov cx, 0
    
    .read:
        push temp
        push input_format
        call _scanf
        add esp, 8
                
        cmp eax, -1
        je .next
                
        fld  qword [sum]
        fadd qword [temp]
        fstp qword [sum]
        
        fld  qword [counter]
        fadd qword [one]
        fstp qword [counter]
        
        jmp .read
        
    .next:
        
    fld  qword [res]
    fadd qword [sum]
    fdiv qword [counter]
    fstp qword [res]
           
    push dword [res + 4]
	push dword [res]
	push output_format
	call _printf
    add esp, 12
    
	xor eax, eax
    
    mov esp, ebp
    pop ebp
    
	ret
    