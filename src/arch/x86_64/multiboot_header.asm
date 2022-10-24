; multiboot_header.asm
; contains definitions to make the kernel multiboot(GRUB) compatible.

; custom section name could be .bss or .text also
section .multiboot_header
    ; function definition     
    header_start:     
        ; magic number for multiboot 2
        dd 0xe85250d6
        ; architecture 0 means we will use x86 4 means mips etc.
        dd 0
        ; header length this is required by multiboot too.
        ; and we calculate it like this
        dd header_end - header_start
        ; checsum -> -(magic + architecture + header_length)
        ; the additional 0x100000000 
        ; in the checksum calculation is a small hack to avoid a compiler warning
        dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start))

        ; insert optional multiboot tags here (read the multiboot spec for tags)

        ; required end tag
        dw 0    ; type 
        dw 0    ; flags
        dd 8    ; size

    header_end:
