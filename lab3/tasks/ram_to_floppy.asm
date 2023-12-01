
ram_to_floppy:
    call clear_screen
    ; print "Enter RAM address: "
    mov si, RAM_ADDRESS_PROMPT
    call print_string
    ; read RAM address
    mov si, ram_address
    call print