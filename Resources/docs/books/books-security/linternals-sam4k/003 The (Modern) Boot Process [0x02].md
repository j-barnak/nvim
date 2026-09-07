# Linternals: The (Modern) Boot Process \[0x02\]

October 10, 2021

[\#linux](https://sam4k.com/tags/linux/)

[\#kernel](https://sam4k.com/tags/kernel/)



Welcome to the second part of my totally-wasn’t-meant-to-be-a-one-part Linux internals post on the modern boot process! [Last time](https://sam4k.com/linternals-the-modern-boot-process-part-1/) I set the scene and covered the GUID Partition Table (GPT) scheme for formatting your storage device; briefly touched on what happens when you power on your computer and what happens when it hands over control to UEFI.

So without anymore rambling and rehashing, let’s jump right back into the action. UEFI has just consulted the EFI variables in NVRAM to determine boot order, locate the first available bootloader on the list and will now transfer control over to it …

## Contents

- [0x03 Optional Bootloader](https://sam4k.com/linternals-the-modern-boot-process-part-2/#0x03-optional-bootloader)
  - [Wait This Is Optional?](https://sam4k.com/linternals-the-modern-boot-process-part-2/#wait-this-is-optional)
- [0x04 The Kernel (Setup)](https://sam4k.com/linternals-the-modern-boot-process-part-2/#0x04-the-kernel-setup)
  - [Getting to Main](https://sam4k.com/linternals-the-modern-boot-process-part-2/#getting-to-main)
  - [The First C](https://sam4k.com/linternals-the-modern-boot-process-part-2/#the-first-c)
  - [And Back To Assembly](https://sam4k.com/linternals-the-modern-boot-process-part-2/#and-back-to-assembly)
  - [Decompression Time!](https://sam4k.com/linternals-the-modern-boot-process-part-2/#decompression-time)
    - First Some Background
    - Back To Decompression
- [Next Time](https://sam4k.com/linternals-the-modern-boot-process-part-2/#0x05-the-kernel-initialisation)

## 0x03 Optional Bootloader



There’s a number of different bootloaders out there that you can use with your Linux system, each with their own pros and cons, but at their core they’ll all need to meet the requirements laid out by the Linux Boot Protocol\[1\].

For reference, any specifics in this section will be referring to the common GNU GRUB 2 bootloader. It’s worth noting that while we’re operating within a Linux context, GRUB 2 and other bootloaders are capable of booting a variety of systems, not just Linux.

In days gone this was a multi-stage process due to the size constraints of the old BIOS+MBR system, however nowadays the entire bootloader can be stored in the ESP and UEFI can hand control straight over. In the case of GRUB 2, this is `grub_main(void)` over in [grub-core/kern/main.c](https://github.com/rhboot/grub2/blob/master/grub-core/kern/main.c), so feel free to follow along.  

First things first there’s going to be some architecture-specific machine initialisation, like setting up the console; some rudimentary memory management; locating and loading dependencies/addons (e.g. GRUB modules); loading any configs etc.

With initialisation handled, the bootloader is in a position to be able to do it’s job. Typically modern bootloaders like GRUB will provide an interactive menu to the user, with varying degrees of features. Invariably, however, should be the option to boot one or more kernels/operating systems.

As a quick aside, in GRUB this post-initialisation mode is called “normal mode” and we can see this in a call to `grub_load_normal_mode()` at the end of `grub_main()`, and yes  keen-eyed and battle-scarred GRUB users might notice a call to `grub_rescue_run ()` just under that. So, if normal mode falls through, we end up at the dreaded `grub rescue >`…



Anyway, back to generic bootloader things, when we select our kernel (or more likely let the timer tick down and select the default option) - which is of course a Linux one, right?! - we begin the “Linux Boot Protocol” as outlined above\[1\] to get our chosen kernel up and running.

The short and sweet of this is that the bootloader will bootstrap the kernel by loading into memory the “kernel real-mode code”, consisting of the kernel setup and kernel boot sector, creating a memory mapping similar to the one seen below:

```
        ~                        ~
        |  Protected-mode kernel |
100000  +------------------------+
        |  I/O memory hole       |
0A0000  +------------------------+
        |  Reserved for BIOS     | Leave as much as possible unused
        ~                        ~
        |  Command line          | (Can also be below the X+10000 mark)
X+10000 +------------------------+
        |  Stack/heap            | For use by the kernel real-mode code.
X+08000 +------------------------+
        |  Kernel setup          | The kernel real-mode code.
        |  Kernel boot sector    | The kernel legacy boot sector.
X       +------------------------+
        |  Boot loader           | <- Boot sector entry point 0000:7C00
001000  +------------------------+
        |  Reserved for MBR/BIOS |
000800  +------------------------+
        |  Typically used by MBR |
000600  +------------------------+
        |  BIOS use only         |
000000  +------------------------+

... where the address X is as low as the design of the boot loader permits.
```

Without going down the rabbit hole, the tl;dr on “real-mode” is that modern processors have several “processor modes” (legacy modes, long mode). These control how the processor sees and manages the system memory and the tasks that use it. For legacy reasons, processors boot into real-mode and this is the mode we have been running in so far[](http://flint.cs.yale.edu/feng/cos/resources/BIOS/procModes.htm)[\[3\]](https://en.wikipedia.org/wiki/X86-64#Operating_modes).

One of the limits of the “legacy” real-mode is a limit of 1MB addressable RAM. Yep. Old school right? So that explains why the memory map above only goes to `100000` and why the area beyond it is labelled “Protected-mode kernel”, neat!

Back to the kernel real-mode code we’ve loaded into memory for the kernel setup. Once loaded into memory, the bootloader will read and set fields from the kernel setup header, which can be found at a fixed offset from the start of the setup code\[4\].

This header helps define the information necessary for the bootloader to hand over control directly to the kernel setup code.

### Wait This Is Optional?

The keen-eyed of you will be wondering why the section was titled “Optional Bootloader” - after all that all seemed kinda crucial right? Well, harnessing the flexibility and power of UEFI over Legacy BIOS, “the Linux kernel supports EFISTUB booting which allows [**EFI**](https://wiki.archlinux.org/title/EFI) firmware to load the kernel as an EFI executable”[\[5\]](https://wiki.archlinux.org/title/EFISTUB).

However, bear in mind that there are tradeoffs between using EFISTUB and the more feature-rich bootloaders-of-old like GRUB 2.

1.  For x86, we can find this in `[linux/documentation/ARCH/boot[ing].rst](https://github.com/torvalds/linux/blob/master/Documentation/x86/boot.rst)`
2.  See `grub_main(void)` over in [grub-core/kern/main.c](https://github.com/rhboot/grub2/blob/master/grub-core/kern/main.c), first thing we call is arch specific `grub_machine_init()`.
3.  <https://en.wikipedia.org/wiki/X86-64#Operating_modes>
4.  For x86 we can see this action over in  `[/arch/x86/boot/header.S](https://github.com/torvalds/linux/blob/0adb32858b0bddf4ada5f364a84ed60b196dbcda/arch/x86/boot/header.S#L297)`
5.  <https://wiki.archlinux.org/title/EFISTUB>

## 0x04 The Kernel (Setup)



Okay, so we’re not QUITE in the kernel proper yet, we still need to run the kernel setup code (`/arch/x86/boot/header.S` for x86) in order to basically get a suitable environment up an running to be able to run [arch/x86/boot/main.c](https://github.com/torvalds/linux/blob/v4.16/arch/x86/boot/main.c) in real mode, the first bit of C code! And THEN we can start to look into loading the rest of the kernel into memory. Anyway:

### Getting to Main

In order to get to main, header.S does some housekeeping to make sure everything is how it should be. This includes making sure all the segment register values are aligned, setting up the stack, BSS area as well as some error handling in the form of a checking a setup signature to ensure everything’s looking good before jumping to main.

### The First C

It’s all starting to kick off now! Except we’re still not technically in the kernel yet, as that’s still sat in a compressed image, waiting to be freed\![1\] For the sake of brevity, I’m going to quickly cover some of the key steps we take after running [arch/x86/boot/main.c](https://github.com/torvalds/linux/blob/v4.16/arch/x86/boot/main.c) in order to ultimately decompress the kernel and run the actual kernel.

Initialisation, initialisation and then some more initialisation! During this stage the heap, console, keyboard, video mode and more are initialised. Furthermore CPU validation is carried out as well as memory detection in order to provide a map of available RAM to the CPU.

Another important part of the setup is the transition into protected mode and then 64-bit mode. Remember earlier we mentioned how we’ve been running in real-mode, one of several processor modes, which comes with a limit of 1MB addressable RAM?

The last task of [arch/x86/boot/main.c](https://github.com/torvalds/linux/blob/v4.16/arch/x86/boot/main.c) is to shed those shackles and enable the transition into protected mode; the tl;dr is this is a more powerful mode with full access to the system’s memory, multitasking and support for virtual memory. After setting up the Interrupt & Global Descriptor Tables (IGT, GDT) among other things, we jump to the 32-bit protected mode entry point.

### And Back To Assembly

Yep, that’s right, the 32-bit entry point is defined in [arch/x86/boot/compressed/head_64.S](https://github.com/torvalds/linux/blob/v4.16/arch/x86/boot/compressed/head_64.S) and will cover some more setup, similar to what we saw for real-mode, as well as enabling the transition into long mode AKA 64-bit mode. So many modes, right?

Well, technically 64-bit mode is an enhancement of protected mode and is the native mode for [x86_64](https://en.wikipedia.org/wiki/X86-64) processors. It provides additional features and capabilities; allowing the CPU to take advantage of 64-bit processing.

During this stage some more setup occurs, the GDT is updated, page tables are initialised and after entering 64-bit mode, we jump to the 64-bit entry point in [head_64.S](https://github.com/torvalds/linux/blob/v4.16/arch/x86/boot/compressed/head_64.S).

### Decompression Time!



#### First Some Background

Okay, there’s a lot to unpack here (haha), so I’ll try to keep things brief. At boot time, the kernel is typically sat on disk as a compressed image. You can check this out for yourself:

``` console
[sam4k ~]$ ls /boot
...  efi  grub  ...  vmlinuz-linux
[sam4k ~]$ file /boot/vmlinuz-linux 
/boot/vmlinuz-linux: Linux kernel x86 boot executable bzImage ...
```

With a little peek, we can see our kernel as it’s stored on disk! You’ll notice a couple of things here, one being that the kernel is compressed as a `bzImage` and that it’s an executable?!

The `bzImage`, big zImage, format was developed (unsurprisingly) to tackle size limitations for a growing Linux kernel. Although original compressed with gzip, newer kernels have wider support, including LZMA & bzip2[\[2\]](https://en.wikipedia.org/wiki/Vmlinux#bzImage).

`bzImage` files also follows a specific format, containing concatenated `bootsect.o` + `setup.o` + `misc.o` + `piggy.o`. Where `piggy.o` contains a gzipped `vmlinux` file in its data section[\[2\]](https://en.wikipedia.org/wiki/Vmlinux#bzImage). Still following?

Now, the `vmlinux` file (notice we dropped the z) is a statically linked executable file that contains the Linux kernel in one of the object file formats supported by Linux, typically (and in thise case) the Executable and Linkable Format AKA ELF[\[3\]](https://en.wikipedia.org/wiki/Vmlinux).

Out-of-scope for now, but the vmlinux is really neat, being an ELF means you can load it up into a debugger just like any other ELF, and make use of any symbols.

#### Back To Decompression

Okay, we’d just jumped to the 64-bit entry point in [arch/x86/boot/compressed/head_64.S](https://github.com/torvalds/linux/blob/v4.16/arch/x86/boot/compressed/head_64.S) after transitioning to 64-bit mode. Now, like the last mode transition, there’s some more low level house keeping done and

After the transition to 64-bit mode there’s some more low level house keeping done, including figuring out where the decompressed kernels going to go, copying the compressed kernel their and then preparing the params for the `extract_kernel` function[\[4\]](https://github.com/torvalds/linux/blob/v4.16/arch/x86/boot/compressed/misc.c)!

As a security nerd, one of these parameters, the output of the decompressed kernel involves a call to `choose_random_location`[\[5\]](https://github.com/torvalds/linux/blob/v4.16/arch/x86/boot/compressed/kaslr.c) - this is integral to providing kernel address space layout randomization by randomizing where the kernel code is placed at boot time[\[6\]](https://en.wikipedia.org/wiki/Address_space_layout_randomization#Kernel_address_space_layout_randomization).

Some checks and a `__decompress` call later, the kernel is decompressed. The decompression is done in place (remember we made a copy of the compressed kernel earlier). However, we still need to move the now decompressed kernel to the right place, and that’s where `parse_elf` (remember the kernel image is an ELF executable!) and `handle_relocations` come in\[7\].

The tl;dr on these functions is to check the ELF header, load the various segments into memory (bearing in mind our KASLR), adjusting kernel addresses as necessary and finally moving everything to the right place in memory.

Next? After extract is complete, we jump to the kernel!

1.  You can check this out for yourself by exploring your `/boot/` folder
2.  <https://en.wikipedia.org/wiki/Vmlinux#bzImage>
3.  <https://en.wikipedia.org/wiki/Vmlinux>
4.  [arch/x86/boot/compressed/misc.c](https://github.com/torvalds/linux/blob/v4.16/arch/x86/boot/compressed/misc.c)
5.  [arch/x86/boot/compressed/kaslr.c](https://github.com/torvalds/linux/blob/v4.16/arch/x86/boot/compressed/kaslr.c)
6.  <https://en.wikipedia.org/wiki/Address_space_layout_randomization#Kernel_address_space_layout_randomization>
7.  You can find the src for these functions over in [/arch/x86/boot/compressed/misc.c](https://github.com/torvalds/linux/blob/master/arch/x86/boot/compressed/misc.c)

## 0x05 The Kernel (Initialisation)



Yep, this fella is turning into a 3-part epic. Apologies! Tune in next time where we’ll cover the last two phases of the boot process I want to cover (hopefully in one post…):

- 0x05 The Kernel (Initialisation)
- 0x06 Systemd (Yikes)

exit(0);
