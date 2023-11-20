BITS 16
ORG 7c00H

%define BACKSPACE 0x08
%define ENTER 0x0D
%define ESC 0x1B

%define BLOCK_ALEX 4

main:
    mov [BOOT_DISK], dl
    call clear_screen

    mov bh, 0
    mov bl, 0x09
    mov dx, 0x0100
    mov bp, message
    call print_string

    jmp $

clear_screen:
    mov ah, 0; set the video mode
    mov al, 3; 80x25 text mode
    int 10h
    ret

BOOT_DISK dw 0

message dw "Hello, World!", 0

%include "lab3/utils/string.asm"

cursor_coords:
cursor_x db 0
cursor_y db 1

buffer:
resb 64 ; will overflow, but that's ok. Keep as last variable

times 510-($-$$) db 0
db 0x55, 0xAA