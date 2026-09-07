

**1**



**I N T R O D U C T I O N**



The memory management subsystem is arguably the

core of the Linux kernel, forming the foundation

upon which the rest of the kernel and all of userspace

operates. Despite its fundamental nature, it is surpris-

ingly complicated and intricate.

The Linux Memory Manager explores the Linux kernel’s memory man-

agement subsystem in detail. In this chapter we will explore the approach

taken, who the book is aimed it,



**1.1 Approach**



Many kernel books take the approach of providing an overview and then

hand-waving away details, that is a top-down approach..

The key motivating philosophy of the Linux Memory Manager was to do

entirely the opposite—explore each part of the memory management sub-

system starting with basic principles, and then work from the bottom-up to

form a broader understanding of the topic at hand.

Within the kernel there can be no better source of truth than the source

code itself, so we explore kernel functionality by exploring its code, which is

reproduced in extensive snippets.

In effect, this book tries to combine a source commentary with in depth

analysis of concepts explored in both extensive discussions of the concepts




at hand along side a large number of diagrams which aim to put each con-cept into perspective.

As the kernel is constantly evolving and this book necessarily must target

a static kernel version, the intent is that by taking this approach, not only will the reader acquire understanding of fundamentals which are unlikely to change, but more importantly develop their skills at exploring kernel source so that they can adapt and update their knowledge to the latest version of the code.



**1.2 Who Is This Book For?**



This book is aimed at developers who already have some fundamental un-derstanding of the C programming language and operating system basics, and have an interest in exploring under the hood to see how Linux manages memory in as much detail as they may want to do so.

This spans from that most wonderful of things—a genuinely curious

(perhaps aspiring?) kernel hacker to a professional kernel developer, either working with or making use of the memory management subsystem.

The intent is to bring out the hidden tribal knowledge within this code-

base as much as possible and in the spirit of open source software make it more widely available to curious hackers all over the world!



**1.3 Book Overview**

## **Chapter 1: Introduction** A description of the contents of the book.

## **Chapter 2: Physical Memory** A description of how a system’s memory is

managed on its most fundamental level—the allocation of its physically installed RAM.

## **Chapter 3: Virtual Memory** The why, what and how, page tables, page ta-

ble flags, page table sizes, virtual memory layout, direct mapping, ker-nel/userland split and a detailed description of vmalloc().

## **Chapter 4: Process Memory** An overview of how userland memory is

structured—mm_struct, Process VMAs, Copy-on-Write and more.

## **Chapter 5: Memory Mapping** A description of how memory mapping is

performed within the kernel -mmap, brk (used by malloc()) and how map-pings (via VMAs) are split/merged.

## **Chapter 6: Page Faults** A detailed examination of how page faults are han-

dled and propagated within the kernel.

## **Chapter 7: The Reverse Mapping** A detailed look at how the kernel maps

raw physical pages of userland memory back to the abstract VMA repre-sentation, in addition to how this is used to free memory.

## **Chapter 8: Manipulating Userland Memory** A detailed examination of how

the kernel accesses userland memory. Also a brief look at how memory ranges can be manipulated by madvise().



**2** Chapter 1




## **Chapter 9: The Page Cache** A detailed look into the page cache, how it in-

teracts with the Linux virtual file system, read-ahead, read-behind and generally a very focused discussion of how the memory subsystem inter-acts with VFS.

## **Chapter 10: Writeback** A description of how writeback proceeds both orig-

inating from write() operations and memory-mapped files, how dirty data is tracked, how synchronisation functions within the kernel and how dirty throttling is applied.

## **Chapter 11: Reclaim and Memory Pressure** A detailed explanation of how

reclaim operations, what direct and indirect reclaim are, how it interacts with demand paging, higher order page starvation, etc.

## **Chapter 12: Swap Memory** A detailed description of how the swap oper-

ations in the kernel and how pages are paged out and paged back in again.

## **Chapter 13: The Out of Memory (OOM) Killer** A deep dive into how it

works, how to tune it, the what, why and how.

## **Chapter 14: Practical Memory Management** A brief overview of practical

memory management techniques - procfs interfaces, tuneables, decod-ing out of memory reports and more. Generally a practical ’how to’ for sysadmins/developers.



Introduction **3**
