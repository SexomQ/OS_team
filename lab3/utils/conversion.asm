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

;; Converts uint to string
;; Parameters: ax - uint to convert
;;             es:di - buffer to store string
;; Returns:    Nothing
;; Mutates:    es:di
int_to_string:
    pusha
    mov bx, 10
    mov cx, 0
    .int_to_string_loop:
        xor dx, dx
        div bx
        push dx
        inc cx
        cmp ax, 0
        jne .int_to_string_loop
    .int_to_string_loop2:
        pop dx
        add dl, '0'
        mov [es:di], dl
        inc di
        loop .int_to_string_loop2
    mov byte [es:di], 0
    popa
    ret
