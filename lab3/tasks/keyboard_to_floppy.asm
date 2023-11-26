keyboard_to_floppy:
    call clear_screen
    ;; Get the text
    mov si, TEXT_PROMPT
    mov di, buffer
    call prompt
    ;; Print the text 2 lines below
    mov si, buffer
    mov bh, 0; page number
    mov bl, 07H; text attribute
    mov dx, 0300H; cursor coordinates
    call print_string

    call clear_current_row
    ;; Get the floppy head
    mov si, HEAD_PROMPT
    mov di, conversion_buffer
    call prompt
    ;; Convert the string to a number
    mov si, conversion_buffer
    call string_to_int
    mov byte [head], al

    call clear_current_row
    ;; Get the floppy cylinder
    mov si, CYLINDER_PROMPT
    mov di, conversion_buffer
    call prompt
    ;; Convert the string to a number
    mov si, conversion_buffer
    call string_to_int
    mov byte [cylinder], al

    call clear_current_row
    ;; Get the floppy sector
    mov si, SECTOR_PROMPT
    mov di, conversion_buffer
    call prompt
    ;; Convert the string to a number
    mov si, conversion_buffer
    call string_to_int
    mov byte [sector], al

    call clear_current_row
    ;; Get the number of repetitions
    mov si, REPETITIONS_PROMPT
    mov di, conversion_buffer
    call prompt
    ;; Convert the string to a number
    mov si, conversion_buffer
    call string_to_int
    mov byte [number], al

    .ktf_handle_enter:
        mov ax, 1300H; print string
        mov bh, 0; page number
        mov bl, 07H; text attribute
        ; cx = number of characters to print
        mov dh, [row];
        mov dl, 0; column
        mov bp, buffer; pointer to string
        int 10h

        mov byte [cursor_x], 0; set the cursor x coordinate to 0
        inc byte [row]; increment the row number
        mov bx, buffer; set the buffer pointer to the beginning of the buffer
        xor cx, cx; set the character counter to 0
        pusha; save all registers

        mov ah, 02H; set the cursor position
        mov bh, 0; page number
        mov dx, [cursor_coords]; cursor coordinates
        int 10h
        ; clear line
        mov ah, 0AH; print the character at the cursor position
        mov bh, 0; page number
        mov cx, 80; number of times to print the character
        mov al, ' '; print a space
        int 10h
        popa; restore all registers
    
    jmp menu