result dw 0

;; Converts string to uint
;; Parameters: si - string to convert
;; Returns:    ax - converted int
;;             bl - error code
string_to_int:
    pusha
    mov dx, si; save pointer to string
    mov ax, 0
    mov word [result], 0
    .string_to_int_loop:
        ;; check if null character is reached
        cmp byte [si], 0
        je .string_to_int_end
        ;; check if character is digit
        cmp byte [si], '0'
        jl .string_to_int_error
        cmp byte [si], '9'
        jg .string_to_int_error
        ;; convert character to int
        mov bx, 0
        mov bl, [si]
        sub bl, '0'
        ;; multiply current number by 10
        mov cx, 10
        mul cx
        ;; add current digit
        add ax, bx
        inc si
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
;;             di - buffer to store string
;; Returns:    Nothing
;; Mutates:    di
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
        mov [di], dl
        inc di
        loop .int_to_string_loop2
    mov byte [di], 0
    popa
    ret


;; Converts string to hexadecimal
;; Parameters: es:bp - string to convert
;; Returns:    ax - converted hex
;;             bl - error code
string_to_hex:
    pusha
    mov dx, bp; save pointer to string
    mov ax, 0
    mov word [result], 0
    .string_to_hex_loop:
        ;; check if null character is reached
        cmp byte [es:bp], 0
        je .string_to_hex_end
        ;; check if character is digit
        cmp byte [es:bp], '0'
        jl .string_to_hex_error
        cmp byte [es:bp], '9'
        jle .string_to_hex_digit
        ;; check if character is uppercase letter
        cmp byte [es:bp], 'A'
        jl .string_to_hex_error
        cmp byte [es:bp], 'F'
        jg .string_to_hex_error
        ;; convert character to int
        mov bx, 0
        mov bl, [es:bp]
        sub bl, 'A'
        add bl, 10
        ;; multiply current number by 16
        mov cx, 16
        mul cx
        ;; add current digit
        add ax, bx
        inc bp
        jmp .string_to_hex_loop
    .string_to_hex_digit:
        ;; convert character to int
        mov bx, 0
        mov bl, [es:bp]
        sub bl, '0'
        ;; multiply current number by 16
        mov cx, 16
        mul cx
        ;; add current digit
        add ax, bx
        inc bp
        jmp .string_to_hex_loop
    .string_to_hex_error:
        popa
        mov bl, 1
        mov ax, 0
        ret
    .string_to_hex_end:
        mov [result], ax
        popa
        mov bl, 0
        mov ax, [result]
        ret

;; Converts hexadecimal to string
;; Parameters: ax - hex to convert
;;             es:di - buffer to store string
;; Returns:    Nothing
;; Mutates:    es:di
hex_to_string:
    pusha
    mov bx, 16
    mov cx, 0
    .hex_to_string_loop:
        xor dx, dx
        div bx
        push dx
        inc cx
        cmp ax, 0
        jne .hex_to_string_loop
    .hex_to_string_loop2:
        pop dx
        cmp dl, 10
        jl .hex_to_string_digit
        add dl, 'A'
        sub dl, 10
        jmp .hex_to_string_write
    .hex_to_string_digit:
        add dl, '0'
    .hex_to_string_write:
        mov [es:di], dl
        inc di
        loop .hex_to_string_loop2
    mov byte [es:di], 0
    popa
    ret