extern _puts
extern _printf
extern _scanf

section .data
    msg1            db "a*x^2 + b*x + c = 0 ", 0
    msg2            db "a: ", 0
    msg3            db "b: ", 0
    msg4            db "c: ", 0
    msg5            db "Discriminant < 0, no real roots", 0
    input_format    db "%lf"
    output_format   db "Discriminant: %lf", 10, 0
    output_root1    db "Root 1: %lf", 10, 0
    output_root2    db "Root 2: %lf", 10, 0
    
    temp_bsq        dq 0.0
    temp_fac        dq 0.0
    discrmnt        dq 0.0
    counter         dq 0.0
    const_a         dq 0.0
    const_b         dq 0.0
    const_c         dq 0.0
    four            dq 4.0
    res             dq 0.0
    root_one        dq 0.0
    root_two        dq 0.0
    minus_one       dq -1.0
    two             dq 2.0
    
section .text
global _main

_main:
    push ebp
	mov ebp, esp
    ; a*x^2 + b*x + c = 0 
    push msg1
	call _puts
	add esp, 4
    ; a:
    push msg2
	call _puts
	add esp, 4
    
    push const_a
    push input_format
    call _scanf
    add esp, 8
    ; b:
    push msg3
	call _puts
	add esp, 4
    
    push const_b
    push input_format
    call _scanf
    add esp, 8
    ; c:
    push msg4
	call _puts
	add esp, 4
    
    push const_c
    push input_format
    call _scanf
    add esp, 8
   
    ; discr b^2 - 4*a*c
    
    ; b^2
    fld  qword [temp_bsq]
    fadd qword [const_b]
    fmul qword [const_b]
    fstp qword [temp_bsq]
    ; 4*a*c
    fld  qword [temp_fac]
    fadd qword [const_a]
    fmul qword [const_c]
    fmul qword [four]
    fstp qword [temp_fac]
    ; b^2 - 4*a*c
    fld  qword [temp_bsq]
    fsub qword [temp_fac]
    fstp qword [discrmnt]
    ; print and compare
    push dword [discrmnt + 4]
	push dword [discrmnt]
	push output_format
	call _printf
    add esp, 12
    
    cmp dword [discrmnt + 4], dword 0
    jl .print_roots_with_error
    
    fld   qword [discrmnt]
    fsqrt 
    fstp  qword [discrmnt]
    
    ; root1 = (-b + discr) / 2a
    fld  qword [root_one]
    fadd qword [const_b]
    fmul qword [minus_one]
    fadd qword [discrmnt]
    fdiv qword [const_a]
    fdiv qword [two]
    fstp qword [root_one]
    
    ; root2 = (-b - discr) / 2a
    fld  qword [root_two]
    fadd qword [const_b]
    fmul qword [minus_one]
    fsub qword [discrmnt]
    fdiv qword [const_a]
    fdiv qword [two]
    fstp qword [root_two]
    
    jmp .print_roots
    
    .print_roots_with_error:
        push msg5
        call _puts
        add esp, 4
        jmp .end
    
    .print_roots:
        push dword [root_one + 4]
        push dword [root_one]
        push output_root1 
        call _printf
        add esp, 12
        
        push dword [root_two + 4]
        push dword [root_two]
        push output_root2
        call _printf
        add esp, 12
    
    .end:
        xor eax, eax
        mov esp, ebp
        pop ebp
	ret
    