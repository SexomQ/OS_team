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

    mov ah, 0x02
    mov dh, 0x00
    mov dl, 0x00
    int 0x10

    jmp read_floppy_ram

read_floppy_ram:
    ; Set up the RAM address to store the data
    mov bx, 0x4000  ; RAM address to store the data
    mov es, bx  ; Set the segment register to the RAM address
    mov bx, 0x0000  ; Offset to the RAM address

    ; Set up the floppy disk parameters
    mov ah, 0x02  ; Read sector function
    mov al, byte [number_of_sectors]  ; Number of sectors to read
    mov ch, byte [cylinder]  ; Cylinder number
    mov cl, byte [sector] ; Sector number
    mov dh, byte [head]  ; Head number
    mov dl, byte [BOOT_DISK]  ; Drive number (0x00 for floppy disk)

    int 0x13  ; BIOS interrupt

    mov ax, 0x4000
    mov ds, ax
    mov es, ax
    mov ss, ax

    ; jmp menu

print_ram:
    xor cx, cx
    mov bx, 0x4000
    mov es, bx
    xor bx, bx
    mov ah, 0eh
    call print_str_from_ram

print_str_from_ram:
    cmp cx, 512
    je stop_printing

    mov al, [es:bx]
    int 10h

    inc cx
    inc bx
    jmp print_str_from_ram


stop_printing:
    ret