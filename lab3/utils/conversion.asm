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


hex_string_to_int:
    ; Input: SI - pointer to the null-terminated hex string
    ; Output: AX - hexadecimal value, BL - error code

    xor ax, ax  ; Clear AX

    .next_char:
        lodsb  ; Load next byte from SI into AL, increment SI

        ; Check if we've reached the end of the string
        test al, al
        jz .end

        ; Convert character to decimal
        sub al, '0'
        cmp al, 9
        jbe .add
        sub al, 7  ; Adjust for A-F

    .add:
        ; Add to AX, with multiplication by 16 (since it's hexadecimal)
        shl ax, 4
        add ax, ax

        jmp .next_char

    .end:
        ret