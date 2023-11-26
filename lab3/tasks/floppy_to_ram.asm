menu_handle_floppy_ram:
    call clear_screen

    ;; Get the floppy head
    mov si, HEAD_PROMPT
    mov di, conversion_buffer
    call prompt
    ;; Convert the string to a number
    mov si, conversion_buffer
    call string_to_int
    mov byte [head], al
s
    call clear_current_row

    ; get the cylinder
    mov si, CYLINDER_PROMPT
    mov di, conversion_buffer
    call prompt
    ;; Convert the string to a number
    mov si, conversion_buffer
    call string_to_int
    mov byte [cylinder], al

    call clear_current_row

    ; get the sector
    mov si, SECTOR_PROMPT
    mov di, conversion_buffer
    call prompt
    ;; Convert the string to a number
    mov si, conversion_buffer
    call string_to_int
    mov byte [sector], al

    call clear_current_row

    ; get the number of sectors
    mov si, NUMBER_OF_SECTORS_PROMPT
    mov di, conversion_buffer
    call prompt
    ;; Convert the string to a number
    mov si, conversion_buffer
    call string_to_int
    mov byte [number_of_sectors], al

    call clear_current_row

    ; get the ram address
    mov si, RAM_ADDRESS_PROMPT
    mov di, conversion_buffer
    call prompt
    ;; Convert the string to a hex
    mov si, conversion_buffer
    call string_to_hex
    mov [ram_address], ax

    call clear_current_row

    ; print the ram address
    mov ax, [ram_address]
    call hex_to_string
    mov si, [es:di]
    mov bh, 0
    mov bl, 07H
    mov dh, 0
    mov dl, 0
    call print_string


    

    ; jmp menu

read_sectors_from_drive:
    ; Input: bx - drive number, cx - sector count, dx - offset, si - RAM address, di - buffer address
    ; Output: Data read from the drive is stored in the 'buffer' array

    ; Convert the sector count and offset to CHS values if needed
    ; For simplicity, assuming a flat addressing model (LBA addressing)
    mov ax, 0x0201       ; AH=02h (read sectors), AL=01h (number of sectors to read)
    mov ch, 0            ; Cylinder number (assuming LBA)
    mov cl, byte [ram_offset] ; Sector number
    mov dh, 0            ; Head number
    mov dl, byte [bx]    ; Drive number

    ; Calculate LBA address (if needed)
    ; You may need to adjust this calculation based on your drive's geometry
    mov ax, [ram_offset]
    mov bx, 512           ; Sector size (assuming 512 bytes)
    mul bx
    add ax, [si]
    mov di, ax            ; LBA address in DI

    ; Prepare buffer address
    mov es, di            ; ES:DI points to the destination buffer

    ; Issue BIOS interrupt 0x13 to read sectors
    int 0x13

    ; Check for error (AH should be 0)
    cmp ah, 0
    jne .read_error

    ret

    .read_error:
    ; Handle read error (AH contains error code)
    ; Implement your error handling logic here
    ret