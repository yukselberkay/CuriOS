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
        ; A push eax subtracts 4 from esp and 
        ; does a mov [esp], eax afterwards.
        mov esp, stack_top

        ; here, we perform checks to make sure we can enable long mode
        ; we will print error message if any of these calls fail.
        call check_multiboot
        call check_cpuid
        call check_long_mode

        ; print "OK" to the screen
        mov dword [0xb8000], 0x2f4b2f4f

        ; test error messages
        ;call error
        hlt

    ; prints ERR and the given error code to screen and hangs.
    ; parameter: error code (in ascii) in al register.
    print_error:
        mov dword[0xb8000], 0x4f524f45
        mov dword[0xb8004], 0x4f3a4f52
        mov dword[0xb8008], 0x4f204f20
        mov byte[0xb800a], al
        hlt

    ;To make sure the kernel was really loaded by a Multiboot 
    ;compliant bootloader, we can check the eax register. 
    ;According to the Multiboot specification the bootloader 
    ;must write the magic value 0x36d76289 to it before loading a kernel. 
    ;To verify that we can add a simple function:
    check_multiboot:
        cmp eax, 0x36d76289
        jne .no_multiboot
        ret
    .no_multiboot:
        mov al, "0"
        jmp print_error

    ; CPUID is a CPU instruction that can be used to get various 
    ; information about the CPU. But not every processor supports it. 
    ; CPUID detection is quite laborious, so we just copy a detection function 
    ; from the OSDev wiki:
    check_cpuid:
        ; Basically, the CPUID instruction is supported if we can flip some bit in the FLAGS register
        ; Check if CPUID is supported by attempting to flip the ID bit (bit 21)
        ; in the FLAGS register. If we can flip it, CPUID is available.

        ; Copy FLAGS in to EAX via stack
        pushfd
        pop eax

        ; Copy to ECX as well for comparing later on
        mov ecx, eax

        ; Flip the ID bit
        xor eax, 1 << 21

        ; Copy EAX to FLAGS via the stack
        push eax
        popfd

        ; Copy FLAGS back to EAX (with the flipped bit if CPUID is supported)
        pushfd
        pop eax

        ; Restore FLAGS from the old version stored in ECX 
        ; (i.e. flipping the
        ; ID bit back if it was ever flipped).
        push ecx
        popfd

        ; Compare EAX and ECX. If they are equal then that means the bit
        ; wasn't flipped, and CPUID isn't supported.
        cmp eax, ecx
        je .no_cpuid
        ret
    .no_cpuid:
        mov al, "1"
        jmp print_error

    check_long_mode:
        ; We can use "cpuid" instruction to detect whether long mode
        ; can be used or not
        ; test if extended processor info in available
        mov eax, 0x80000000    ; implicit argument for cpuid
        cpuid                  ; get highest supported argument
        cmp eax, 0x80000001    ; it needs to be at least 0x80000001
        jb .no_long_mode       ; if it's less, the CPU is too old for long mode

        ; use extended info to test if long mode is available
        mov eax, 0x80000001    ; argument for extended processor info
        cpuid                  ; returns various feature bits in ecx and edx
        test edx, 1 << 29      ; test if the LM-bit is set in the D-register
        jz .no_long_mode       ; If it's not set, there is no long mode
        ret
    .no_long_mode:
        mov al, "2"
        jmp print_error


; creating a stack
section .bss
    stack_bottom:
        resb 64
    stack_top: