;; Checks if 2 strings are equal
;; Parameters: es:bp - pointer to string 1
;;             es:di    - pointer to string 2
;; Returns:    zf    - 1 if strings are equal, 0 otherwise
str_equal:
    pusha
    mov [pointer_store], bp
    mov [pointer_store2], di
    .str_equal_loop:
        mov al, [es:bp]
        mov ah, [es:di]
        cmp al, ah
        jne .str_equal_end
        cmp al, 0
        je .str_equal_end
        inc bp
        inc di
        jmp .str_equal_loop
    .str_equal_end:
        mov bp, [pointer_store]
        mov di, [pointer_store2]
        popa
        ret
