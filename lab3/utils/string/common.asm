pointer_store dw 0 ; used by str_len to avoid changing extra registers
pointer_store2 dw 0 ; used by str_equal to avoid changing extra registers

;; Gets string length
;; Parameters: es:bp - pointer to string
;; Returns:    cx    - string length
;; Notes:       String must be zero terminated
str_len:
    mov cx, 0
    mov [pointer_store], bp
    cmp byte [es:bp], 0
    je .str_len_end

    .str_len_loop:
        inc cx
        inc bp
        cmp byte [es:bp], 0
        jne .str_len_loop

    .str_len_end:
        mov bp, [pointer_store]
        ret

;; Prints zero terminated string
;; Parameters: bh    - page number
;;             bl    - video attribute http://www.techhelpmanual.com/87-screen_attributes.html
;;             dh,dl - coords to start writing
;;             es:bp - pointer to string
;; Returns:    None
print_string:
    pusha
    mov si, bp
    ;; Get string length
    call str_len
    mov ax, 1300h
    int 10h
    mov bp, si
    popa
    ret
