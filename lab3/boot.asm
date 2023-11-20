BITS 16
ORG 7c00H

%define BACKSPACE 0x08
%define ENTER 0x0D
%define ESC 0x1B
%define MAX_CHARACTER_COUNT 64

%define BLOCK_ALEX 4

main:
    mov [BOOT_DISK], dl
    call clear_screen

    ; read a character from the keyboard
    read_char:
        mov ah, 0
        int 16h

        cmp al, ESC; if the character is backspace
        je .call_handle_backspace; jump to handle_backspace
        cmp al, ENTER; if the character is enter
        je .call_handle_enter; jump to handle_enter
        jmp .call_handle_symbol; jump to handle_symbol


        .call_handle_backspace:
            call handle_symbol; handle the character
            jmp read_char; read another character

        .call_handle_enter:
            call handle_enter; handle the enter character
            jmp read_char; read another character

        .call_handle_symbol:
            call handle_symbol; handle the character
            jmp read_char; read another character

    jmp $

clear_screen:
    mov ah, 0; set the video mode
    mov al, 3; 80x25 text mode
    int 10h
    ret

handle_symbol:
    cmp cx, MAX_CHARACTER_COUNT; if the character counter is equal to the maximum character count
    je .symbol_done; jump to symbol_done

    mov [bx], al; store the character in the buffer
    inc bx; increment the buffer pointer
    inc cx; increment the character counter
    inc byte [cursor_x]; increment the cursor x coordinate
    pusha; save all registers
    mov ah, 0eh; print the character
    int 10h
    popa; restore all registers
    .symbol_done:
        ret

handle_backspace:
    cmp cx, 0; if the character counter is 0, do nothing
    je .backspace_done

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
    .backspace_done:
    ret

handle_enter:
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
    ret

BOOT_DISK dw 0

message dw "Hello, World!", 0

KEYBOARD_FLOPPY_COMMAND db "KB", 0
WRONG_COMMAND_MESSAGE db "Wrong command!", 0

%include "lab3/utils/string.asm"

cursor_coords:
cursor_x db 0
cursor_y db 1

row db 0

buffer:
resb 64 ; will overflow, but that's ok. Keep as last variable

times 510-($-$$) db 0
db 0x55, 0xAA