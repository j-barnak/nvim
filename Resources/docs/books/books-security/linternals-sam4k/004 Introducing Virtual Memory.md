# Linternals: Introducing Virtual Memory

January 15, 2022

[\#linux](https://sam4k.com/tags/linux/)

[\#kernel](https://sam4k.com/tags/kernel/)

[\#memory](https://sam4k.com/tags/memory/)

![Linternals: Introducing Virtual Memory](./Linternals_%20Introducing%20Virtual%20Memory%20_%20sam4k_files/linternals.gif)

Alright, let’s get stuck into some Linternals! As the title suggests, this post will be exploring the ins and outs of virtual memory with regards to modern Linux systems.

I say Linux systems, but this topic, like many in this series, treads the line between examining the Linux kernel and the hardware it runs on, but who cares, it’s still interesting right? And I guess it is one of the fundamental building blocks of modern systems too…

That said, I’ll try abstract away from getting too stuck into the knitty gritty of hardware specifics where possible (no promises though!), so forgive any gross over simplifications for what can be a deceptively complex topic.  

In this part I’ll lay the groundwork by covering some fundamentals such as the differences between physical and virtual memory, the virtual address space and how user-mode and the kernel interact with it this virtual address space.

In a later part (or parts, given my track record), we’ll dive a bit deeper and look into how this is implemented and the ways we can really take advantage of virtual memory.

## Contents

- [0x01 What IS Virtual Memory?](https://sam4k.com/linternals-virtual-memory-part-1/#0x01-what-is-virtual-memory)
  - [Physical Memory](https://sam4k.com/linternals-virtual-memory-part-1/#physical-memory)
  - [Queue Virtual Memory](https://sam4k.com/linternals-virtual-memory-part-1/#queue-virtual-memory)
- [0x02 The Virtual Address Space](https://sam4k.com/linternals-virtual-memory-part-1/#0x02-the-virtual-address-space)
  - [Let’s Touch on Addressing & Hexadecimal](https://sam4k.com/linternals-virtual-memory-part-1/#lets-touch-on-addressing-hexadecimal)
  - [That’s a Big VAS](https://sam4k.com/linternals-virtual-memory-part-1/#thats-a-big-vas)
  - [VAS Overview](https://sam4k.com/linternals-virtual-memory-part-1/#vas-overview)
    - Advantages of Virtual Memory
- [0x03 The VM Split](https://sam4k.com/linternals-virtual-memory-part-1/#0x03-the-vm-split)
  - [About Processes](https://sam4k.com/linternals-virtual-memory-part-1/#about-processes)
  - [User-mode & Kernel-mode](https://sam4k.com/linternals-virtual-memory-part-1/#user-mode-kernel-mode)
  - [Queue The VM Split!](https://sam4k.com/linternals-virtual-memory-part-1/#queue-the-vm-split)
- [Next Time!](https://sam4k.com/linternals-virtual-memory-part-1/#next-time)

## 0x01 What IS Virtual Memory?

Virtual memory, every compsci student knows what virtual memory is right, it’s uh, virtual memory, you know, memory that’s not physical? Yeah, I’m realising it can be a bit fiddly to describe virtual memory in a succinct and intuitive way.

![](./Linternals_%20Introducing%20Virtual%20Memory%20_%20sam4k_files/areyouready.gif)

### Physical Memory

Let’s start with what virtual memory ***ISN’Tish***, and that’s physical! The term “physical memory” typically refers to your system’s RAM (random-access memory). This is the volatile memory your operating system uses for all things transient.

While having your memory cleared when your system is powered-off\[1\] may seem inconvenient, RAM’s speed makes it ideal for use-cases where volatility doesn’t matter.

Keeping this brief, there’s actually a lot of use-cases for RAM. Like, a lot. The software you’re using to view this post? Loaded into and running in RAM. The operating system running that software? Loaded into and running in RAM.

Often we say how a program is “loaded into memory” and yes, you guessed it, this ubiquitous “memory” and RAM AKA physical memory are all one-and-the-same. We use non-volatile storage such as SSDs and HDDs to store our kernel, binaries, configs and stuff and then when we need to use them, they’re loaded into the much faster RAM for use.

You may also hear RAM referred to as primary memory and SSDs & HDDs as secondary memory.

1.  Unless… [here’s a paper](http://citpsite.s3-website-us-east-1.amazonaws.com/oldsite-htdocs/pub/coldboot.pdf) from 2008 USENIX Security Composium about recovering data from RAM

### Queue Virtual Memory

Okay, so now we have a general grasp of physical memory and the integral role it plays, it’s time to introduce the titular virtual memory!

As we alluded to above, basically everything wants a piece of RAM. Using `ps` we can see just how many processes are vying for a slice of our precious RAM:

``` chroma
$ ps -e --no-headers | wc -l
404
```

And if anyone has ever looked into building or upgrading a PC, they’ll know that GB for GB, RAM is a lot more expensive than it’s non-volatile counterparts.

![](./Linternals_%20Introducing%20Virtual%20Memory%20_%20sam4k_files/needmoremem-1.gif)

Not to mention, as the “random-access” implies, systems are able to access any memory location in physical memory directly, meaning things can get chaotic real fast if every process is trying to find and manage which bits of memory are up for grabs.

Queue virtual memory: a means to abstract processes away from the low level organisation of physical memory (this burden is passed to the kernel) by providing a Virtual Address Space.

## 0x02 The Virtual Address Space

Sweet, so the Virtual Address Space (VAS) provides a physical memory abstraction for processes to use by shifting the burden of managing low level organisation to the kernel! Cool cool … so, uh, how exactly?

Instead of having processes (and by extension their programmers) deal with accessing and managing physical memory directly, using virtual memory provides **each process with it’s own** virtual address space.

This virtual address space represents the range of all **addressable physical memory**. Let’s unpack that for a second. Not all free RAM, or even all the RAM you have installed in your computer, but all the possible physical memory your computer **could** address if it had it.

Modern 64-bit systems can handle 64 bits of data at a time. This means on typical 64-bit architectures, like Intel’s x86_64 and aarch64, pointers to memory can be 64-bits long. So, theoretically speaking, we can have up to 264 different addresses\[1\].

This means our virtual address space on a 64-bit system ranges from `0x0 - 0xffffffffffffffff`. That’s a lot of bytes!

1.  For anyone wondering on this value, a “bit” is a binary value, it can be a 0 or 1. So 64 of them can represent a combination of 264 different values

### Let’s Touch on Addressing & Hexadecimal

Some of you will notice that I wrote the address in hexadecimal (hex), which is a base 16 number system; tl;dr being the numbers go up to 16 instead 10 before becoming 2 digits.

We use hexadecimal over decimal because as a base 16 system, it lines up perfectly with the binary (base 2) system that forms the fundamental of computing architecture and as a result all manner of digital data representation.

The reason hexadecimal “lines up perfectly” is that 16 is a power 2; 24 specifically, which basically means that 1 hex digit can perfectly represent any 4 binary digits. 2 hex for 8 binary and so on. Whereas decimal simply doesn’t align like this.

![](./Linternals_%20Introducing%20Virtual%20Memory%20_%20sam4k_files/mathematical.gif)

So for things like memory, which is often byte-addressable, hexadecimal provides as a more readable and information dense alternative to using binary.

### That’s a Big VAS

Back to the VAS, some of you might have clocked that `0xffffffffffffffff` is an awful lot of bytes, right? Yep, unless you have 264 bytes AKA ~18 Exabytes AKA 18874368 Terabytes, then we’re clearly addressing far more memory we have on our primary and secondary memory combined! And for each process?! What gives?

First and foremost, remember, this is a **virtual** address space provided to processes. The reality is the majority of this address space will go unused. For virtual memory to actually be used, and take up space, the virtual address has to be mapped to some physical address.

Mapped?? For virtual memory to be used by a process it first needs to be **mapped** to a physical address, where the data actually resides. It’s the kernels job to handle this and manage the book keeping for memory management.

At one point or another, the virtual memory address needs to be translated to the physical address where the data is actually located, this process is called address translation.You bet we’ll be looking into that some more later!

But let’s use this moment to remind ourselves that ***each process has it’s own virtual address space***. So effectively, each process lives in a sandbox, believing it has unfettered access to addresses `0x0 - 0xffffffffffffffff`. Processes are not aware/able to access the virtual address space of another process.

![](./Linternals_%20Introducing%20Virtual%20Memory%20_%20sam4k_files/addresstrans_basic-3.png)

Drastically over simplified view of how two processes can use the same virtual address which however translates to a different physical address. 

So this means that process 1 & process 2 could make use of the same virtual address in their respective virtual address space, however these would both be translated by the kernel to two DIFFERENT physical addresses. Still following?

### VAS Overview

So to summarise what we’ve learned so far: each process running on a Linux system has it’s own virtual address space. This VAS can span the entire addressable space for that architecture, however virtual addresses are only used after they have been mapped by the kernel to a physical address i.e they are actually taking up some space in physical memory.

It’s the kernels role to do all the bookkeeping and lower-level memory organisation around translating this virtual address to the actual physical address1.

This way, processes and their programmers don’t need to concern themselves with any low-level memory organisation or even worry about other processes, they just have to interact with this broad VAS and the kernel will handle the rest.

#### Advantages of Virtual Memory

Given the above, one of the most obvious advantages of virtual memory is that it takes a lot of the burden off of programmers with regards to memory management.

However, as we’ll touch on more later, using a virtual memory scheme affords us several other important advantages as well:

- It allows the kernel, behind the scenes, to actual map virtual addresses to **secondary memory** (SSDs & HDDs). This allows us to map less used/important2 data to the slower secondary memory and free up our scarce RAM for data that needs it.
- The address translation process and abstraction of physical memory allows us to implement additional features, notably security related ones, to our memory management

1.  I say “around translating” as technically the actual address translation is done at a lower level, by the CPU
2.  Another gross simplification, we might touch later on the metrics behind these decisions

## 0x03 The VM Split

Okay, let’s explore a little more how the virtual address space is used in Linux, as it’s not just a matter of throwing a 18EB address space at a user process and saying have at it!

### About Processes

I realised I’m throwing around the term process left and right, and while I want to remain focused on the topic at hand, I’ll just touch briefly on what a process is in Linux.

Simply, a process is a running instance of a program\[1\]. Nowadays, programs can get pretty complex and thanks to the advances of programming languages and library support, the burden of reaching these complexity needs are eased.

However, even the most simple “Hello, World!” program in C requires loading shared libraries which in turn need to interact with the kernel to get things done.

Don’t believe me? Take the basic C program below:

``` chroma
#include <stdio.h>
int main() {
   printf("Hello, World!\n");
   return 0;
}
```

With a few commands, we can get a quick insight into what’s going on behind the scenes:

``` chroma
$ ldd hw
        linux-vdso.so.1 (0x00007ffecb53e000)
        libc.so.6 => /usr/lib/libc.so.6 (0x00007fc3747f3000)
        /lib64/ld-linux-x86-64.so.2 => /usr/lib64/ld-linux-x86-64.so.2 (0x00007fc3749f3000)
```

`ldd` prints the shared objects (shared libraries) dependencies required by our dynamically compiled `hw.c`, in our context, this means when we map our program into it’s virtual address space, we’ve also got to map any necessary dependencies too.

``` chroma
$ strace ./hw
execve("./hw", ["./hw"], 0x7ffd3ee6c190 /* 62 vars */) = 0
brk(NULL)                               = 0x563a56b24000
arch_prctl(0x3001 /* ARCH_??? */, 0x7fff70afecc0) = -1 EINVAL (Invalid argument)
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
newfstatat(3, "", {st_mode=S_IFREG|0644, st_size=180840, ...}, AT_EMPTY_PATH) = 0
mmap(NULL, 180840, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7f9ab51e1000
close(3)                                = 0
openat(AT_FDCWD, "/usr/lib/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0`|\2\0\0\0\0\0"..., 832) = 832
pread64(3, "\6\0\0\0\4\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0"..., 784, 64) = 784
pread64(3, "\4\0\0\0@\0\0\0\5\0\0\0GNU\0\2\0\0\300\4\0\0\0\3\0\0\0\0\0\0\0"..., 80, 848) = 80
pread64(3, "\4\0\0\0\24\0\0\0\3\0\0\0GNU\0K@g7\5w\10\300\344\306B4Zp<G"..., 68, 928) = 68
newfstatat(3, "", {st_mode=S_IFREG|0755, st_size=2150424, ...}, AT_EMPTY_PATH) = 0
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f9ab51df000
pread64(3, "\6\0\0\0\4\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0"..., 784, 64) = 784
mmap(NULL, 1880536, PROT_READ, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7f9ab5013000
mmap(0x7f9ab5039000, 1355776, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x26000) = 0x7f9ab5039000
mmap(0x7f9ab5184000, 311296, PROT_READ, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x171000) = 0x7f9ab5184000
mmap(0x7f9ab51d0000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1bc000) = 0x7f9ab51d0000
mmap(0x7f9ab51d6000, 33240, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f9ab51d6000
close(3)                                = 0
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f9ab5011000
arch_prctl(ARCH_SET_FS, 0x7f9ab51e0580) = 0
mprotect(0x7f9ab51d0000, 12288, PROT_READ) = 0
mprotect(0x563a56a14000, 4096, PROT_READ) = 0
mprotect(0x7f9ab523c000, 8192, PROT_READ) = 0
munmap(0x7f9ab51e1000, 180840)          = 0
newfstatat(1, "", {st_mode=S_IFCHR|0600, st_rdev=makedev(0x88, 0x1), ...}, AT_EMPTY_PATH) = 0
brk(NULL)                               = 0x563a56b24000
brk(0x563a56b45000)                     = 0x563a56b45000
write(1, "Hello, World!\n", 14Hello, World!
)         = 14
exit_group(0)                           = ?
+++ exited with 0 +++
```

`strace` allows us to trace system calls and signals. System calls are (as we can learn via `man syscalls`\[1\] the fundamental interface between an application and the Linux kernel.

So as we can see, there’s an awful lot going on under the hood of our little “Hello, World!” program - it isn’t until write at the bottom we see our actual `write` syscall to write our string `"Hello, World!"` to `stdout` (aka the console)!

That’s because the majority of that is setting up the virtual address space for our program. It might not all make sense now, but we can see our dependencies from `ldd` being setup as well as various memory related syscalls including `brk`, `mmap`, `mprotect` and `munmap`.

1.  In Linux world, basically everything is considered a process or a file, so even multiple threads of the same running program are all viewed as separate processes
2.  The second section of man, `man 2`, is for syscall manuals. So if you want to read more about `read` above for example, you can use `man 2 read` for the syscall’s man page

### User-mode & Kernel-mode

So as we just saw, for a program to even be loaded into memory and run as a process, there’s an awful lot of interaction that needs to go on with the kernel.

We established that syscalls act as an interface between an application and the Linux kernel, meaning that on the other end of that syscall there’s some kernel code running.

Let’s pause a moment and quickly touch on why syscalls are even a thing. Why not just have the process do the systemy thing it needs to do directly? Like in a standard library?

The reason is due to privilege levels. The tl;dr on this is that our hardware let’s us select several different privilege levels, and in Linux we make use of two of these. So at any given time we are running in user-mode or kernel-mode.

As a result we also have the terms user-space and kernel-space. Typically stuff in user-space is running in user-mode and stuff in kernel-space run in kernel-mode.

The kernel resides firmly in kernel-space and as such can only be run in kernel-mode and the only way for a user-space process to change the privilege level is via a syscall.

![](./Linternals_%20Introducing%20Virtual%20Memory%20_%20sam4k_files/youshallntpass.gif)

So, syscalls act as gatekeepers of sorts, allowing user-space processes to get the kernel to carry out specific, privileged actions on its behalf, without giving away the keys to the kingdom.

### Queue The VM Split!

So to sum up what we know so far:

- Each process has its own, sandboxed, virtual address space
- Each process needs to run kernel code to setup its VAS, done via syscalls

This begs the question, after we call our syscall and transfer to kernel-mode, we’re still running within the same process context, so how do we know where the kernel code is?

We map the kernel into the VAS, that’s how! Almost like a shared library, the kernel is also mapped into the VAS, I mean we have enough space right?

There’s an overhead to switching the CPU’s context (tl;dr there’s context specific registers that get swapped in and out when we want to run in a different context, e.g. run another process), so to avoid this the kernel is mapped into the same VAS as the process.

This is all implemented by splitting the virtual memory into two sections, the User Virtual Address Space and the Kernel Virtual Address Space:

![](./Linternals_%20Introducing%20Virtual%20Memory%20_%20sam4k_files/vmsplit.png)

x86_64 VM split

On x86_64 Linux systems, we can see the lower 128TB of memory is assigned to the user virtual address space and the upper 128TB is assigned to the kernel virtual address space.The rest? Well that’s just an unused, no man’s land bridging the gap between the two.

In fact, on typical x86_64 setups today only 48 bits of the virtual address are actually used; the most significant 16 bits (MSB 16) are always set to 0 for the User VAS and 1 for the Kernel VAS. Makes it convenient for spotting what kind of address you’re looking at in a debugger!

The exact proportions of the VM split and details like how many bits are used for addressing are architecture & config specific.

## Next Time!

Today we laid the groundwork for our journey to understanding virtual memory on modern Linux systems. We briefly covered what we mean when we talk about physical vs virtual memory, followed by an understanding of the virtual address space itself.

Now that we understand how (and at a high level why) the virtual address space is split up into the two sections - the User VAS & Kernel VAS - next time we can delve deeper into each of these sections.

Furthermore, I want us to get a closer look at the lower level details on what’s going on behind the scene in the kernel in regards to memory management as well as touching on the role the hardware plays in enabling this.

And likely much, much more - so stay tuned!

exit(0);
