keyboard_to_floppy:
    call clear_screen
    ; read a character from the keyboard
    .ktf_read_char:
        mov ah, 0
        int 16h

        cmp al, ESC; if the character is backspace
        je .ktf_handle_backspace; jump to handle_backspace
        cmp al, ENTER; if the character is enter
        je .ktf_handle_enter; jump to handle_enter
        jmp .ktf_handle_symbol; jump to handle_symbol

    .ktf_handle_symbol:
        cmp cx, [MAX_CHARACTER_COUNT]; if the character counter is equal to the maximum character count
        je .ktf_read_char

        mov [bx], al; store the character in the buffer
        inc bx; increment the buffer pointer
        inc cx; increment the character counter
        inc byte [cursor_x]; increment the cursor x coordinate
        pusha; save all registers
        mov ah, 0eh; print the character
        int 10h
        popa; restore all registers
        jmp .ktf_read_char; read another character

    .ktf_handle_backspace:
        cmp cx, 0; if the character counter is 0, do nothing
        je .ktf_read_char

        dec bx; decrement the buffer pointer
        dec cx; decrement the character counter
        dec byte [cursor_x]; decrement the cursor x coordinate
        pusha; save all registers
        mov ah, 02H; set the cursor position
        mov bh, 0; page number
        mov dx, [cursor_coords]; cursor coordinates
        int 10h

        mov ah, 0AH; print the character at the cursor position
        mov bh, 0; page number
        mov cx, 2; number of times to print the character
        mov al, ' '; print a space
        int 10h
        popa; restore all registers
        jmp .ktf_read_char; read another character

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
        jmp .ktf_read_char; read another character