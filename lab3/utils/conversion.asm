result dw 0
;; Converts string to uint
;; Parameters: es:bp - string to convert
;; Returns:    ax - converted int
;;             bl - error code
string_to_int:
    pusha
    mov dx, bp; save pointer to string
    mov ax, 0
    mov word [result], 0
    .string_to_int_loop:
        ;; check if null character is reached
        cmp byte [es:bp], 0
        je .string_to_int_end
        ;; check if character is digit
        cmp byte [es:bp], '0'
        jl .string_to_int_error
        cmp byte [es:bp], '9'
        jg .string_to_int_error
        ;; convert character to int
        mov bx, 0
        mov bl, [es:bp]
        sub bl, '0'
        ;; multiply current number by 10
        mov cx, 10
        mul cx
        ;; add current digit
        add ax, bx
        inc bp
        jmp .string_to_int_loop
    .string_to_int_error:
        popa
        mov bl, 1
        mov ax, 0
        ret
    .string_to_int_end:
        mov [result], ax
        popa
        mov bl, 0
        mov ax, [result]
        ret

