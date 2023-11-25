%define BACKSPACE 0x08
%define ENTER 0x0D
%define ESC 0x1B
%define ARROW_UP_SCANCODE 0x48
%define ARROW_DOWN_SCANCODE 0x50
%define MAX_CHARACTER_COUNT 64

%define MENU_MESSAGES_COUNT 3
%define BLOCK_ALEX 4

%include "utils/string/common.asm"

section .data
    menu_selection db 0

    KEYBOARD_FLOPPY_MSG db "KEYBOARD ==> FLOPPY", 0
    FLOPPY_RAM_MSG db "FLOPPY ==> RAM", 0
    RAM_FLOPPY_MSG db "RAM ==> FLOPPY", 0
    SELECTED_PREFIX db "> ", 0
    UNSELECTED_PREFIX db "  ", 0
    MENU_MESSAGES dw KEYBOARD_FLOPPY_MSG, FLOPPY_RAM_MSG, RAM_FLOPPY_MSG
    cursor_coords:
        cursor_x db 0
        cursor_y db 1

    row db 0

section .bss
    buffer: resb 257

section .text
    global main

main:
    call menu
    jmp $

clear_screen:
    mov ah, 0; set the video mode
    mov al, 3; 80x25 text mode
    int 10h
    ret

menu:
    call print_menu; print the menu
    .menu_read_char:
        mov ah, 0
        int 16h
    
    cmp ah, ARROW_UP_SCANCODE; if the character is arrow up
    je .menu_handle_arrow_up; jump to handle_arrow_up
    cmp ah, ARROW_DOWN_SCANCODE; if the character is arrow down
    je .menu_handle_arrow_down; jump to handle_arrow_down
    cmp al, ENTER; if the character is enter
    je .menu_handle_enter; jump to handle_enter
    jmp .menu_read_char; else jump to read_char

    .menu_handle_arrow_up:
        ;; decrement the menu selection and get the modulo of the menu selection and the number of messages
        dec byte [menu_selection]
        cmp byte [menu_selection], -1
        jne .menu_handle_arrow_up_not_overflow
        mov byte [menu_selection], MENU_MESSAGES_COUNT - 1
        .menu_handle_arrow_up_not_overflow:
        call print_menu; print the menu
        jmp .menu_read_char; read another character
    
    .menu_handle_arrow_down:
        ;; incremenet the menu selection and get the modulo of the menu selection and the number of messages
        inc byte [menu_selection]
        cmp byte [menu_selection], MENU_MESSAGES_COUNT
        jne .menu_handle_arrow_down_not_overflow
        mov byte [menu_selection], 0
        .menu_handle_arrow_down_not_overflow:
        call print_menu; print the menu
        jmp .menu_read_char; read another character
    
    .menu_handle_enter:
        ;; not yet implemented
        cmp byte [menu_selection], 0
        je keyboard_to_floppy
        cmp byte [menu_selection], 1
        ; je .menu_handle_floppy_ram
        cmp byte [menu_selection], 2
        ; je .menu_handle_ram_floppy
        jmp .menu_read_char; read another character

print_menu:
    call clear_screen
    mov cl, 0
    mov si, MENU_MESSAGES
    .print_menu_loop:
        cmp cl, MENU_MESSAGES_COUNT; if the message number is equal to the number of messages
        je .print_menu_end; jump to print_menu_end
        mov bh, 0; page numbers
        mov bl, 07H; text attribute
        mov dh, cl; row
        mov dl, 0; column
        cmp cl, [menu_selection]; if the message number is equal to the menu selection
        je .print_menu_selected; jump to print_selected
        jmp .print_menu_unselected; else jump to print_unselected
        .print_menu_selected:
            mov bp, SELECTED_PREFIX
            jmp .print_menu_prefix
        .print_menu_unselected:
            mov bp, UNSELECTED_PREFIX
        .print_menu_prefix:
            call print_string; print the prefix
        mov bp, [si]; pointer to the message
        mov dl, 3; column
        call print_string; print the message
        add si, 2; increment the message pointer
        inc cl; increment the message number
        jmp .print_menu_loop; loop
    .print_menu_end:
        ret

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

; %include "lab3/utils/conversion.asm"