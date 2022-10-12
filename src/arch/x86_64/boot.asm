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
    ; we update the stack pointer so that it points to our
    ; reserved stack memory that we defined inside .bss below
    ; this way we have a stack to use and now we are able to
    ; call functions! we use stack_top here
    ; because stack grows downwards
    mov esp, stack_top


    ; print "OK" to the screen
    mov dword [0xb8000], 0x2f4b2f4f
    ;call error
    hlt

; prints ERR and the given error code to screen and hangs.
; parameter: error code (in ascii) in al register.
error:
    mov dword[0xb8000], 0x4f524f45
    mov dword[0xb8004], 0x4f3a4f52
    mov dword[0xb8008], 0x4f204f20
    mov byte[0xb800a], al
    hlt

; creating a stack
section .bss
stack_bottom:
    resb 64
stack_top: