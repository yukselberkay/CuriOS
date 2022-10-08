; boot.asm
; contains kernel booting routines.

; global makes a label public. "start" will be the entry point of the kernel
; it needs to be public
global start


section .text   ; default section that contains executable code
; specifies that the following lines are 32 bit instructions.
; its needed because when bootloader gives the control to the kernel,
; it still is in 32 bit protected mode. so wen can't use 64 bit instructions
; without switching to the long mode.
bits 32
start:
    ; print "OK" to the screen
    mov dword [0xb8000], 0x2f4b2f4f
    hlt
