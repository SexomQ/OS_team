%define SECTORS_PER_TRACK 18
%define HEADS 2
%define SECTOR_SIZE 512

%define MESSAGE_REPEAT_COUNT 10
%define SECTOR_BEGIN_ALEX 91
%define SECTOR_END_ALEX 120

chs_sector dw 0
chs_head dw 0
chs_cylinder dw 0

;; Converts a linear sector number to a CHS address.
;; Parameters: ax = linear sector number
;; Returns:    ch = cylinder
;;             dh = head
;;             cl = sector
lba_to_chs:
    pusha
    ;; sector = (LBA % SECTORS_PER_TRACK) + 1
    mov cx, ax; save LBA to cx
    mov dx, 0; clear dx
    mov ax, cx; restore LBA from cx
    mov bx, SECTORS_PER_TRACK
    div bx
    inc dx
    mov [chs_cylinder], dx
    ;; head = (LBA / SECTORS_PER_TRACK) % HEADS
    mov ax, cx; restore LBA from cx
    mov dx, 0; clear dx
    mov bx, SECTORS_PER_TRACK
    div bx
    mov dx, 0; clear dx
    mov bx, HEADS
    div bx
    mov [chs_head], dx
    ;; cylinder = (LBA / SECTORS_PER_TRACK) / HEADS
    mov ax, bx; restore LBA from bx
    mov dx, 0; clear dx
    mov bx, SECTORS_PER_TRACK
    div bx
    mov dx, 0; clear dx
    mov bx, HEADS
    div bx
    mov [chs_cylinder], ax
    popa

    mov ch, [chs_cylinder]
    mov dh, [chs_head]
    mov cl, [chs_sector]
    ret

insert_initial_floppy_data:
    ;; Make the input string
    mov cx, MESSAGE_REPEAT_COUNT
    mov si, ALEX_MESSAGE
    mov di, floppy_buffer
    call repeat_string
    ;;; Write the string to the floppy
    ;; convert LBA to CHS
    mov ax, SECTOR_BEGIN_ALEX
    ; call lba_to_chs
    ;; write the sector
    mov ah, 03H
    mov al, 01H
    mov bx, ALEX_MESSAGE - 0x7e00
    mov ch, 0
    mov dh, 1
    mov cl, 29
    mov dl, 0
    ; int 13H
    ;; convert LBA to CHS
    mov ax, SECTOR_END_ALEX
    call lba_to_chs
    ;; write the sector
    mov ah, 03H
    mov al, 01H
    mov bx, floppy_buffer
    mov dl, 0
    ; int 13H

    ret
