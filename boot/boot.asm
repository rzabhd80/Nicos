; BIOS mounts the loader into 0x7c00 address
[org 0x7c00] 


;includes:
%include "real/load_sector_bios.asm"
%include "protected/gdt_table_32.asm"
%include "protected/activate_32bit_mode.asm"
%include "long/detect_long_mode.asm"
%include "long/activate_64bit_mode.asm"
%include "long/init_page_table.asm"
%include "long/gdt_table.asm"

;consts:
    kernel_start_addr equ 0x8200

;vars :
kernel_current_size db 0
bios_boot_drive     db 0x00

jmp real_mode

boot_sector_hold:
    jmp $

real_mode:
 [bits 16]
 ;init base and stack pointer 
 mov bp, 0x0500
 mov sp, bp
 ;store the id of boot drive
 mov byte[bios_boot_drive], dl
 ;load sectors for kernel
 ;and bootloader
 mov bx, 0x0002
 mov cx, [kernel_current_size]
 add cx,2
 mov dx, 0x7E00
 call load_sector_bios
 ;activating 32bit mode:
 call activate_32bit_mode
 times 510 - ($ - $$) db 0x00
 ; Magic number
 dw 0xAA55


begin_protected:
    [bits 32]
    call detect_long_mode
    cmp eax, 0x00
    je halt
    call init_page_table
    call activate_64bit_mode
    jmp $ ; to ensure that no 32 bit op is in the pipeline
    times 512 - ($ - bootsector_extended) db 0x00

[bits 64]


halt:
    cli
    hlt