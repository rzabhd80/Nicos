; BIOS mounts the loader into 0x7c00 address
[org 0x7c00] 


;includes:
%include "real/load_sector_bios.asm"
%include "protected/gdt_table_32.asm"
%include "protected/activate_32bit_mode.asm"
;consts:

;vars :
kernel_current_size db 0
bios_boot_drive     db 0x00

jmp real_mode

real_mode:
 [bits 16]
 ;init base and stack pointer 
 mov bp, 0x0500
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