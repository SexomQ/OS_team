; create a program in nasm to read from RAM, and write to floppy. the ram address {XXXX:YYYY}, will be inputed by the user, the {HEAD, TRACK, SECTOR} for the floppy will also be user inputted. The data block of "Q" bytes from RAM should be dislpayed on the screen. After compliting the disk writing operation, the error code should be displayed on the screen.

ram_to_floppy:
    mov byte [head], 0
    mov byte [cylinder], 0
    mov byte [sector], 0
    mov byte [sector_write_count], 0
    mov word [ram_address], 0
    mov word [ram_address + 2], 0

    call clear_screen
    ; print "Enter RAM address: "
    ; get the ram address
    mov si, RAM_ADDRESS_PROMPT
    mov di, hex_conversion_buffer
    call prompt
    ;; Convert the string to a hex
    mov si, hex_conversion_buffer
    mov di, ram_address
    call string_to_hex
  
    call clear_current_row

    ; get the offset address
    mov si, RAM_OFFSET_PROMPT
    mov di, hex_conversion_buffer
    call prompt
    ;; Convert the string to a hex
    mov si, hex_conversion_buffer
    mov di, ram_address + 2
    call string_to_hex

    call clear_current_row

    ; print "Enter floppy head: "
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
    ;; Get the number of bytes to write "Q"
    mov si, BYTES_PROMPT
    mov di, conversion_buffer
    call prompt
    ;; Convert the string to a number
    mov si, conversion_buffer
    call string_to_int
    mov byte [sector_write_count], al

    call clear_current_row

    
    ; ; write the string to floppy
    ; mov ah, 3; write to floppy
    ; mov al, byte [sector_write_count]
    ; mov ch, byte [cylinder]
    ; mov cl, byte [sector]
    ; mov dl, byte [BOOT_DISK]
    ; mov dh, byte [head]
    ; mov bx, floppy_buffer
    ; int 13h


    