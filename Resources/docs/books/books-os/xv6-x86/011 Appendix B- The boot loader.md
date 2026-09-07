**Appendix B**  
  
**The boot loader**  
  
When an x86 PC boots, it starts executing a program called the BIOS (Basic In- put/Output System), which is stored in non-volatile memory on the motherboard. The BIOS’s job is to prepare the hardware and then transfer control to the operating sys- tem. Specifically, it transfers control to code loaded from the boot sector, the first 512-byte sector of the boot disk. The boot sector contains the boot loader: instruc- tions that load the kernel into memory. The BIOS loads the boot sector at memory address 0x7c00 and then jumps (sets the processor’s %ip) to that address. When the boot loader begins executing, the processor is simulating an Intel 8088, and the loader’s job is to put the processor in a more modern operating mode, to load the xv6 kernel from disk into memory, and then to transfer control to the kernel. The xv6 boot load- er comprises two source files, one written in a combination of 16-bit and 32-bit x86 assembly (bootasm.S; (9100)) and one written in C (bootmain.c; (9200) ).  
  
**Code: Assembly bootstrap**  
  
The first instruction in the boot loader is cli (9112), which disables processor in- terrupts. Interrupts are a way for hardware devices to invoke operating system func- tions called interrupt handlers. The BIOS is a tiny operating system, and it might have set up its own interrupt handlers as part of the initializing the hardware. But the BIOS isn’t running anymore—the boot loader is—so it is no longer appropriate or safe to handle interrupts from hardware devices. When xv6 is ready (in Chapter 3), it will re-enable interrupts.  
  
The processor is in real mode, in which it simulates an Intel 8088. In real mode there are eight 16-bit general-purpose registers, but the processor sends 20 bits of ad- dress to memory. The segment registers %cs, %ds, %es, and %ss provide the additional bits necessary to generate 20-bit memory addresses from 16-bit registers. When a pro- gram refers to a memory address, the processor automatically adds 16 times the value of one of the segment registers; these registers are 16 bits wide. Which segment regis- ter is usually implicit in the kind of memory reference: instruction fetches use %cs , data reads and writes use %ds, and stack reads and writes use %ss .  
  
boot loader real mode  
  
DRAFT as of September 4, 2018 99 https://pdos.csail.mit.edu/6.828/xv6  
  
Xv6 pretends that an x86 instruction uses a virtual address for its memory operands, but an x86 instruction actually uses a logical address (see Figure B-1). A logical address consists of a segment selector and an offset, and is sometimes written as segment:offset. More often, the segment is implicit and the program only directly manipulates the offset. The segmentation hardware performs the translation described above to generate a linear address. If the paging hardware is enabled (see Chapter 2), it translates linear addresses to physical addresses; otherwise the processor uses linear ad- dresses as physical addresses.  
  
The boot loader does not enable the paging hardware; the logical addresses that it uses are translated to linear addresses by the segmentation harware, and then used di- rectly as physical addresses. Xv6 configures the segmentation hardware to translate logical to linear addresses without change, so that they are always equal. For historical reasons we have used the term virtual address to refer to addresses manipulated by programs; an xv6 virtual address is the same as an x86 logical address, and is equal to the linear address to which the segmentation hardware maps it. Once paging is en- abled, the only interesting address mapping in the system will be linear to physical. The BIOS does not guarantee anything about the contents of %ds, %es, %ss, so first order of business after disabling interrupts is to set %ax to zero and then copy that zero into %ds, %es, and %ss (9115-9118) .  
  
A virtual segment:offset can yield a 21-bit physical address, but the Intel 8088 could only address 20 bits of memory, so it discarded the top bit: 0xffff0+0xffff = 0x10ffef, but virtual address 0xffff:0xffff on the 8088 referred to physical address 0x0ffef. Some early software relied on the hardware ignoring the 21st address bit, so when Intel introduced processors with more than 20 bits of physical address, IBM pro- vided a compatibility hack that is a requirement for PC-compatible hardware. If the second bit of the keyboard controller’s output port is low, the 21st physical address bit is always cleared; if high, the 21st bit acts normally. The boot loader must enable the 21st address bit using I/O to the keyboard controller on ports 0x64 and 0x60 (9120- 9136) .  
  
Real mode’s 16-bit general-purpose and segment registers make it awkward for a program to use more than 65,536 bytes of memory, and impossible to use more than a megabyte. x86 processors since the 80286 have a protected mode, which allows physi- cal addresses to have many more bits, and (since the 80386) a ‘‘32-bit’’ mode that caus- es registers, virtual addresses, and most integer arithmetic to be carried out with 32 bits rather than 16. The xv6 boot sequence enables protected mode and 32-bit mode as follows.  
  
In protected mode, a segment register is an index into a segment descriptor table (see Figure B-2). Each table entry specifies a base physical address, a maximum virtual address called the limit, and permission bits for the segment. These permissions are the protection in protected mode: the kernel can use them to ensure that a program uses only its own memory.  
  
xv6 makes almost no use of segments; it uses the paging hardware instead, as Chapter 2 describes. The boot loader sets up the segment descriptor table gdt (9182- 9185) so that all segments have a base address of zero and the maximum possible limit (four gigabytes). The table has a null entry, one entry for executable code, and one en-  
  
boot loader logical address linear address virtual address protected mode segment descriptor table  
  
gdt+code  
  
DRAFT as of September 4, 2018 100 https://pdos.csail.mit.edu/6.828/xv6  
  
16  
  
Logical Address  
  
32  
  
Linear Address  
  
protected mode  
  
Selector Offset  
  
32 20 12  
  
16  
  
8  
  
0  
  
Base Limit Flags  
  
GDT/LDT  
  
**Figure B-2**. Segments in protected mode.  
  
try to data. The code segment descriptor has a flag set that indicates that the code should run in 32-bit mode (0660). With this setup, when the boot loader enters protect- ed mode, logical addresses map one-to-one to physical addresses.  
  
The boot loader executes an lgdt instruction (9141) to load the processor’s global descriptor table (GDT) register with the value gdtdesc (9187-9189), which points to the table gdt .  
  
Once it has loaded the GDT register, the boot loader enables protected mode by setting the 1 bit (CR0_PE) in register %cr0 (9142-9144). Enabling protected mode does not immediately change how the processor translates logical to physical addresses; it is only when one loads a new value into a segment register that the processor reads the GDT and changes its internal segmentation settings. One cannot directly modify %cs , so instead the code executes an ljmp (far jump) instruction (9153), which allows a code segment selector to be specified. The jump continues execution at the next line (9156)  
  
but in doing so sets %cs to refer to the code descriptor entry in gdt. That descriptor describes a 32-bit code segment, so the processor switches into 32-bit mode. The boot loader has nursed the processor through an evolution from 8088 through 80286 to 80386.  
  
The boot loader’s first action in 32-bit mode is to initialize the data segment reg- isters with SEG_KDATA (9158-9161). Logical address now map directly to physical ad- dresses. The only step left before executing C code is to set up a stack in an unused region of memory. The memory from 0xa0000 to 0x100000 is typically littered with device memory regions, and the xv6 kernel expects to be placed at 0x100000. The boot loader itself is at 0x7c00 through 0x7e00 (512 bytes). Essentially any other sec- tion of memory would be a fine location for the stack. The boot loader chooses 0x7c00 (known in this file as \$start) as the top of the stack; the stack will grow down from there, toward 0x0000, away from the boot loader.  
  
Finally the boot loader calls the C function bootmain (9168). Bootmain’s job is to load and run the kernel. It only returns if something has gone wrong. In that case, the code sends a few output words on port 0x8a00 (9170-9176). On real hardware, there is no device connected to that port, so this code does nothing. If the boot loader is running inside a PC simulator, port 0x8a00 is connected to the simulator itself and can transfer control back to the simulator. Simulator or not, the code then executes an infinite loop (9177-9178). A real boot loader might attempt to print an error message first.  
  
boot loader global descriptor  
  
table gdtdesc+code gdt+code CR0_PE+code gdt+code SEG_KDATA+code bootmain+code  
  
DRAFT as of September 4, 2018 101 https://pdos.csail.mit.edu/6.828/xv6  
  
**Code:** **C bootstrap**  
  
The C part of the boot loader, bootmain.c (9200), expects to find a copy of the kernel executable on the disk starting at the second sector. The kernel is an ELF for- mat binary, as we have seen in Chapter 2. To get access to the ELF headers, bootmain loads the first 4096 bytes of the ELF binary (9214). It places the in-memory copy at ad- dress 0x10000 .  
  
The next step is a quick check that this probably is an ELF binary, and not an uninitialized disk. Bootmain reads the section’s content starting from the disk location off bytes after the start of the ELF header, and writes to memory starting at address paddr. Bootmain calls readseg to load data from disk (9238) and calls stosb to zero the remainder of the segment (9240). Stosb (0492) uses the x86 instruction rep stosb to initialize every byte of a block of memory.  
  
The kernel has been compiled and linked so that it expects to find itself at virtual addresses starting at 0x80100000. Thus, function call instructions must mention desti- nation addresses that look like 0x801xxxxx; you can see examples in kernel.asm . This address is configured in kernel.ld (9311). 0x80100000 is a relatively high ad- dress, towards the end of the 32-bit address space; Chapter 2 explains the reasons for this choice. There may not be any physical memory at such a high address. Once the kernel starts executing, it will set up the paging hardware to map virtual addresses starting at 0x80100000 to physical addresses starting at 0x00100000; the kernel as- sumes that there is physical memory at this lower address. At this point in the boot process, however, paging is not enabled. Instead, kernel.ld specifies that the ELF paddr start at 0x00100000, which causes the boot loader to copy the kernel to the low physical addresses to which the paging hardware will eventually point.  
  
The boot loader’s final step is to call the kernel’s entry point, which is the instruc- tion at which the kernel expects to start executing. For xv6 the entry address is 0x10000c:  
  
\# objdump -f kernel  
  
```cpp
kernel: file format elf32-i386 architecture: i386, flags 0x00000112: EXEC_P, HAS_SYMS, D_PAGED

start address 0x0010000c
```
  
By convention, the \_start symbol specifies the ELF entry point, which is defined in the file entry.S (1040). Since xv6 hasn’t set up virtual memory yet, xv6’s entry point is the physical address of entry (1044) .  
  
**Real world**  
  
The boot loader described in this appendix compiles to around 470 bytes of ma- chine code, depending on the optimizations used when compiling the C code. In or- der to fit in that small amount of space, the xv6 boot loader makes a major simplify- ing assumption, that the kernel has been written to the boot disk contiguously starting at sector 1. More commonly, kernels are stored in ordinary file systems, where they may not be contiguous, or are loaded over a network. These complications require the  
  
readseg+code stosb+code \_start+code entry+code  
  
DRAFT as of September 4, 2018 102 https://pdos.csail.mit.edu/6.828/xv6  
  
boot loader to be able to drive a variety of disk and network controllers and under- stand various file systems and network protocols. In other words, the boot loader itself must be a small operating system. Since such complicated boot loaders certainly won’t fit in 512 bytes, most PC operating systems use a two-step boot process. First, a sim- ple boot loader like the one in this appendix loads a full-featured boot-loader from a known disk location, often relying on the less space-constrained BIOS for disk access rather than trying to drive the disk itself. Then the full loader, relieved of the 512-byte limit, can implement the complexity needed to locate, load, and execute the desired kernel. Modern PCs avoid many of the above complexities, because they support the Unified Extensible Firmware Interface (UEFI), which allows the PC to read a larger boot loader from the disk (and start it in protected and 32-bit mode).  
  
This appendix is written as if the only thing that happens between power on and the execution of the boot loader is that the BIOS loads the boot sector. In fact the BIOS does a huge amount of initialization in order to make the complex hardware of a modern computer look like a traditional standard PC. The BIOS is really a small operating system embedded in the hardware, which is present after the computer has booted.  
  
**Exercises**  
  
1. Due to sector granularity, the call to readseg in the text is equivalent to read- seg((uchar\*)0x100000, 0xb500, 0x1000). In practice, this sloppy behavior turns out not to be a problem Why doesn’t the sloppy readsect cause problems?  
  
2. Suppose you wanted bootmain() to load the kernel at 0x200000 instead of 0x100000, and you did so by modifying bootmain() to add 0x100000 to the va of each ELF section. Something would go wrong. What?  
  
3. It seems potentially dangerous for the boot loader to copy the ELF header to mem- ory at the arbitrary location 0x10000. Why doesn’t it call malloc to obtain the memo- ry it needs?  
  
DRAFT as of September 4, 2018 103 https://pdos.csail.mit.edu/6.828/xv6  
  