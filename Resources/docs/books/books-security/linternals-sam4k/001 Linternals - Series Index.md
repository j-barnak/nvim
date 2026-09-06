# Linternals

November 10, 2023

This is a series of posts exploring Linux kernel internals, with a focus on accessibility and getting some hands on in the process! For more info, check out [my introduction post](https://sam4k.com/linternals-introduction/).

## The (Modern) Boot Process

This (unfinished) subseries covers the Linux kernel’s boot process.

- [Linternals: The (Modern) Boot Process \[0x01\]](https://sam4k.com/linternals-the-modern-boot-process-part-1/) discusses GPTs, powering on the system and UEFI
- [Linternals: The (Modern) Boot Process \[0x02\]](https://sam4k.com/linternals-the-modern-boot-process-part-2/) discusses bootloaders, initial kernel setup and decompression

## Virtual Memory

This subseries introduces the concept of virtual memory in the context of Linux.

- [Linternals: Introducing Virtual Memory](https://sam4k.com/linternals-virtual-memory-part-1/)
- [Linternals: The User Virtual Address Space](https://sam4k.com/linternals-virtual-memory-0x02/)
- [Linternals: The Kernel Virtual Address Space](https://sam4k.com/linternals-virtual-memory-part-3/)

## Memory Allocators

This subseries talks about memory allocation in the Linux kernel and it’s two main allocators: the page allocator and the slab allocator.

- [Linternals: Introducing Memory Allocators & The Page Allocator](https://sam4k.com/linternals-memory-allocators-part-1/)
- [Linternals: The Slab Allocator](https://sam4k.com/linternals-memory-allocators-0x02/)

## Memory Management

This is an ambitious subseries attempting to delve into the memory management subsystem of the Linux kernel, initially using a simple C program as a case study.

- [Linternals: Exploring The mm Subsystem via mmap \[0x01\]](https://sam4k.com/linternals-exploring-the-mm-subsystem-part-1/) introduces the concept of memory management, the kernel’s `mm/` subsystem and begins exploring `mmap()`.
- [Linternals: Exploring The mm Subsystem via mmap \[0x02\]](https://sam4k.com/linternals-exploring-the-mm-subsystem-part-2/) continues to explore `mmap()`, specifically mapping anonymous private memory; including how memory areas are represented and managed; as well as our virtual addresses are chosen.
