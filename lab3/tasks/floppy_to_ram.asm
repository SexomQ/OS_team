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
    mov di, hex_conversion_buffer
    call prompt
    ;; Convert the string to a hex
    mov si, hex_conversion_buffer
    call hex_string_to_int
    mov [ram_address], ax
  
    call clear_current_row

    ; mov di, conversion_buffer
    ; mov ax, [number_of_sectors]
    ; call int_to_string
    ; mov si, hex_conversion_buffer
    ; call print_string

read_floppy_ram:
    ; Set up the RAM address to store the data
    mov bx, [ram_address]  ; RAM address to store the data
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

    ; print the data from the RAM address
    mov ch, byte [number_of_sectors]
    pusha
    mov bx, [ram_address]
    mov es, bx
    xor bx, bx
    xor dx, dx
    mov ah, 0eh

    .loop_sectors:
        cmp ch, 0
        je stop_printing

        xor dx, dx
        .loop_sector:
            cmp dx, 512
            je .loop_sectors_dec

            mov al, [es:bx]
            int 10h

            inc bx
            inc dx
            jmp .loop_sector

        .loop_sectors_dec:
            dec ch
            jmp .loop_sectors
    popa
    jmp stop_printing
    
    ; jmp print_ram
    ; ret

; check_simp:
;     ; mov di, conversion_buffer
;     ; mov ax, [number_of_sectors]
;     ; call int_to_string
;     ; mov si, conversion_buffer
;     ; call print_string

;     mov byte [number_of_sectors], 0x05

;     mov ch, byte [number_of_sectors]
;     pusha
;     .loop:
;         cmp ch, 0
;         je stop_printing

;         mov al, "S"
;         mov ah, 0x0e
;         int 10h

;         dec ch
;         jmp .loop
;     popa
;     jmp stop_printing


; print_ram:
;     xor cx, cx
;     mov bx, 0x4000
;     mov es, bx
;     xor bx, bx
;     xor dx, dx
;     mov ah, 0eh
;     jmp print_str_from_ram

; print_str_from_ram:
;     cmp cx, 1024
;     je stop_printing

;     mov al, [es:bx]
;     int 10h

;     inc cx
;     inc bx
;     jmp print_str_from_ram

; ; ; check_if_last_sector:
; ; ;     cmp 
; ; ;     je stop_printing
; ; ;     dec dl

; ; ;     xor cx, cx

; ; ;     jmp print_str_from_ram


stop_printing:
    mov al, "E"
    mov ah, 0x0e
    int 10h