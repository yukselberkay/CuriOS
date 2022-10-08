/*
    linker.ld
    To boot our executable later through GRUB, it should be an ELF
    executable. so we want nasm to create ELF object files instead of plain
    binaries. To do that, we simply pass the -f elf64 argument to nasm.

    To create ELF executable we need to link the object files together
    We use this custom linker script to do that.
    
*/

/*
start is the entry point, bootloader will jump to it
after loading the kernel
*/
ENTRY(start)
/*the executable will have two sections: .boot at the beginning and .text afterwards*/
SECTIONS {
    /*sets the load adress of the first section to 1MB
    which is a conventional place to load a kernel
    We don’t want to load the kernel to e.g. 0x0 
    because there are many special memory areas below the 1MB mark 
    (for example the so-called VGA buffer at 0xb8000, 
    that we use to print OK to the screen).*/
    . = 1M;

    .boot :
    {
        /*Sections named .multiboot_header are added to the first output section 
        (.boot) to ensure they are at the beginning of the executable. 
        This is necessary because GRUB expects to find the Multiboot header 
        very early in the file.*/
        *(.multiboot_header)
    }
    /*the .text output section contains all input sections named .text*/
    .text :
    {
        *(.text)
    }
}
