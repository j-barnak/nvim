**Chapter 7. Thanks for the Memory**

*A master was explaining the nature of the Tao to one of his novices.*

*"The Tao is embodied in all software—regardless of how insignificant," said the master.*

*"Is the Tao in a hand-held calculator?" asked the novice. "It is," came the reply.*

*"Is the Tao in a video game?" continued the novice. "It is even in a video game," said the master.*

*"And is the Tao in the DOS for a personal computer?"*

*The master coughed and shifted his position slightly. "That would be in the stack frame Bob, and the* *lesson is over for today," he said.*

—Geoffrey James, *The Tao of Programming*

the Intel 80x86 family…the Intel 80x86 memory model and how it got that way…virtual memory…cache memory…the data segment and heap… memory leaks…bus error—take the train…some light relief—the thing king and the paging game

This chapter starts with a discussion of memory architecture for the Intel 80x86 processor family (the processor at the heart of the IBM PC). It contrasts PC memory with the virtual memory feature found on other systems. A knowledge of memory architecture helps a programmer to understand some of the C conventions and restrictions.

![Image 74](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-142_1.png)

**The Intel 80x86 Family**

Modern Intel processors can trace their heritage all the way back to the earliest Intel chips. As customers became more sophisticated and demanding in their use of chip sets, Intel was always ready with compatible follow-on processors. Compatibility made it easy for customers to move to newer chips, but it severely restricted the amount of innovation that was possible. The modern Pentium is a direct descendant of Intel's 8086 from 15 years before, and it contains architectural irregularities to provide backwards compatibility with it (meaning that programs compiled for an 8086 will run on a Pentium). Referring to the innovation/compatibility trade-off, some people have unkindly commented that "Intel puts the 'backward' in 'backward compatible'…" (see Figure 7-1).

***Figure 7-1. The Intel 80x86 Family: Putting the "Backward" in "Backward Compatible"***

The Intel 4004 was a 4-bit microcontroller built in 1970 to satisfy the specific needs of a single customer, Busicom—a Japanese calculator company. The Intel design engineer conceived the idea of producing a general-purpose programmable chip, instead of the custom logic for each different customer that was the rule at the time. Intel thought they'd sell a few hundred, but a general-purpose design turned out to have vastly wider applicability. Four bits was too limiting, so in April 1972 an 8-bit version, the 8008, was launched. Two years later, that in turn spawned the 8080, which was the first chip powerful enough to be called a microcomputer. It included the entire 8008 instruction set and added 30 more instructions of its own, initiating a trend that continues to this day. If the 4004 was

![Image 75](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-143_1.png)

the chip that got Intel started, the 8080 was the chip that made its fortune, boosting the company's turnover to more than \$1 billion annually and placing it high on the Fortune 500 list.

The 8085 processor took advantage of advances in integration technology to squeeze a three chip combination onto one. In essence, it was an 8080 combined with the 8224 clock driver and the 8228

controller, all on a single chip. Although its internal data bus was still 8-bit, it used a 16-bit address bus, so it could address 216 or 64 Kbytes of memory.

Introduced in 1978, the 8086 improved on the 8085 by allowing 16 bits on the data bus and 20 bits on the address bus permitting a massive (at the time) 1 Mbyte of possible memory. In an unusual design decision, the addresses are formed by overlapping two 16-bit words to form a 20-bit address, rather than concatenating them to form a 32-bit address (see Figure 7-2). The 8086 was not 8085-compatible at the instruction-set level, but assembler macros helped convert programs to the newer architecture easily.

***Figure 7-2. How the Intel 8086 Addresses Memory***

Its irregular addressing scheme allowed the 8086 to run 8085-ported code more simply; once the segment registers were loaded with a fixed value they could be ignored, allowing the 16-bit addresses of the 8085 to be used directly. The design team rejected the idea of forming addresses by concatenating the segment word; that would provide 32 bits of addressing or 4 Gbytes, which was an impossibly large amount of memory at the time.

Now that this basic addressing model was laid down, all subsequent 80x86 processors had to follow it or give up compatibility. If the 8080 was the chip that brought Intel to prominence, the 8086 was the chip that kept it there. We'll probably never know exactly why IBM selected the Intel 8088 (an 8-bit sibling of the 8086) as the CPU for its new PC back in 1979, in the face of so many technically superior alternatives from companies like Motorola or National Semiconductor. By selecting an Intel chip, IBM made Intel's fortune for the next two decades, just as IBM also made Microsoft's fortune by selecting MS-DOS as the operating executive. Ironically, in August 1993 Intel's stock valuation of \$26.6 billion rose above IBM's stock valuation of \$24.5 billion, and Intel eclipsed IBM as the most valuable electronics company in America.

![Image 76](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-144_1.png)

Intel and Microsoft have effectively become the new IBM, reaping undeserved windfall profits from their closed proprietary systems. IBM is trying desperately to regain its former position by using the PowerPC to challenge Intel's hardware monopoly, and using OS/2 to challenge Microsoft's software monopoly. The OS/2 challenge has probably failed, but it's too early to pass judgment on the PowerPC.

The 8088 processor, as used in the first IBM PC, was just a cheap 8-bit version of the 8086, allowing the wealth of existing 8-bit support chips to be used. All further 80x86 refinements were of the

"smaller, faster, costlier, and more instructions" variety. The 80186 took this path, introducing 10 not-very-important new instructions. The 80286 was just the 80186 (minus some built-in peripheral ports) but with the first attempt to extend the address space. It moved the memory controller off-chip, and provided an ambitiously named *virtual* mode in which the segment register isn't added to the offset, but is used to index a table holding the actual segment address. This kind of addressing was also known as protected mode and it was still 16-bit-based. MS-Windows uses 286 protected mode as its standard addressing mode.

The 80386 is the 80286 with two new addressing modes: 32-bit protected mode and virtual 8086

mode. Microsoft's new flagship operating system, NT, and MS-Windows in enhanced mode both use 32-bit protected mode. This is why NT requires at least a 386 to run. The other kind of addressing, virtual 8086 mode, creates a virtual 8086 machine with 1 Mbyte of address space. Several of them can run at once, supporting multiple virtual MS-DOS sessions, each of which thinks it's running on its own 8086. At about this time, you should be thinking that the gyrations necessary to cope with the limitations of the original addressing scheme are pretty incredible, and you'd be right. The 80x86 is a difficult and frustrating architecture for which to write compilers and application programs.

All these processors can have coprocessors, usually to implement floating point in hardware. The 8087 and 80287 coprocessors are identical, except that the 287 can address the same extended memory as the 286. The 387 can address using the same modes as the 386, but also adds some built-in transcendental functions.

**Software Dogma**

**Choosing Components for the IBM PC**

Some, perhaps most, of the IBM decisions about the PC were definitely made on nontechnical grounds. Before deciding on MS-DOS, IBM arranged a meeting with Gary Kildall of Digital Research to consider CP/M. On the day of the meeting, so the story runs, the weather was so good that Gary decided to fly his private plane instead. The IBM managers, perhaps annoyed at being stood up, soon cut a deal with Microsoft instead.

Bill Gates had bought the rights to Seattle Computer Product's QDOS, \[1\] cleaned it up a little, and renamed it "MS-DOS". The rest, as they say, is history. IBM was happy, Intel was happy, and Microsoft was very, very happy. Digital Research was not happy, and Seattle Computer Products became successively unhappier over the years as they realized they had pretty much given away the rights to the best-selling computer program ever. They did retain the right to sell MS-DOS if they sold the hardware at the same time, and this was why you used to see copies of MS-DOS available from Seattle Computer Products, improbably

bundled with alarmingly useless Intel boards and chips, to fulfill the letter of their contract with Microsoft.

Don't feel too sorry for Seattle Computer Products—their QDOS was itself extensively based on Gary Kildall's CP/M, and he'd rather be flying. Bill Gates later bought a super-fast Porsche 959 with his cut of the profits. This car cost three-quarters of a million dollars, but problems arose with U.S. Customs on import. The Porsche 959 cannot be driven in the U.S.A. because it has not passed the government-mandated crash-worthiness tests. The car lies unused in a warehouse in Oakland to this day—one Gates product that will definitely never crash.

\[1\] This literally stood for "Quick and Dirty Operating System."

The 80486 is a repackaged 80386 that is a little faster because the bus lacks states that allow coprocessors. The 486 coprocessor is either built in or disallowed, called DX and SX, respectively.

The 486 adds a few modest instructions and has an on-board cache (fast processor memory), which accounts for most of the rest of the performance improvement. That brings us to the present day, where, in a tremendous burst of innovation and trademark squabbling, Intel named its latest chip the Pentium, not the 80586. It's faster, more expensive, supports all previous instructions, and introduces some new ones. It's safe to anticipate that the 80686 is planned to be faster and more expensive, and will provide some additional instructions. Intel's internal motto for their continual introduction of new chips is "be fast or be dead," and they certainly live by it. As my old grandmother used to say as she worked away at her spinning wheel, "Those who do not remember history are doomed to have serious backward compatibility problems, especially if they change the addressing modes or wordsize of their architecture."

**The Intel 80x86 Memory Model and How It Got That Way**

As we saw in the previous chapter, the term segment has at least two different meanings (there's also a third OS memory-management-related meaning):

A segment on UNIX is *a section of related stuff in a binary*.

A segment in the Intel x86 memory model is *the result of a design in which (for compatibility reasons)* *the address space is not uniform, but is divided into 64-Kbyte ranges known as segments.*

In its most basic form, a segment started out on the 8086 as a 64-Kbyte region of memory that was pointed to by a segment register. An address is formed by taking the value in a segment register and shifting it left four places (or equivalently, multiplying by 16). Yet a third way of looking at this is to consider that the segment register value has been made a 20-bit quantity by appending four zeros.

Then the 16-bit offset says where the address is in that segment. If you add the contents of the segment register to the offset, you will obtain the final address. One quirk: just as there are many different pairs of numbers that total, for example, 24, there are many different segment + offset pairs that point to the same address.

**Handy Heuristic**

![Image 77](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-146_1.png)

![Image 78](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-146_2.png)

**Different-Looking Pointers, Same Address**

An address on the Intel 8086 is formed by combining a 16-bit segment with a 16-bit offset.

The segment is shifted left four places before the offset is added. This means that many different segment/offset pairs can point to the same one address.

segment

offset

resulting address

(shifted left 4 bits)

A0000

\+ FFFF

= AFFFF

:

AFFF0

\+ 000F

= AFFFF

In general, there will be 0x1000 (4096) different segment/offset combinations that point to the same one address.

A C compiler-writer needs to make sure that pointers are compared in canonical form on a PC, otherwise two pointers that have different bit patterns but designate the same address may wrongly compare unequal. This will be done for you if you use the "huge" keyword, but does not occur for the

"large" model. The far keyword in Microsoft C indicates that the pointer stores the contents of the segment register and the offset. The near keyword means the pointer just holds a 16-bit offset, and it will use the value already in the data or stack segment register.

**Handy Heuristic**

**A Guide to Memory Prefix Use**

**Prefix** **Power of Two** **Meaning**

**Number of Bytes**

Kilo 210 One

thousand

bytes

1,024

Mega 220 One

million

bytes 1,048,576

Giga 230 One

billion

bytes 1,073,741,824

Tera 240

One trillion bytes

1,099,511,627,776

Bubba 264

Eighteen billion billion bytes 18,446,744,073,709,551,616

![Image 79](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-147_1.png)

While on the subject of these numbers, note that all disk manufacturers use decimal rather than binary notation for disk capacity. Thus a 2-Gbyte disk will hold 2,000,000,000 bytes and not 2,147,483,648

bytes.

A 64-bit address space is *really* large. It can fit an entire movie for high-definition TV in memory at once. They haven't yet settled the specification for high-definition TV, but it will probably be close to SVGA which is 1024 x 768 pixels, each of which needs, say, three bytes of color information.

At 30 frames per second (as in the current NTSC standard) a two-hour movie would take: 120 minutes= x 60 seconds x 30 frames x 786,432 pixels x 3 color bytes

= 509,607,936,000 bytes

= 500Gbytes of memory

So you could fit not just one, but 36 million high-definition TV movies (orders of magnitude more than every movie ever made, and then some) into a 64-bit virtual address space. You still have to leave room for the operating system, but that's OK. The UNIX kernel is constrained by the current SVID \[1\] to 512 Mbytes. Of course, there's still the small matter of physical disk to back up this virtual memory.

\[1\] The SVID – System V Interface Definition – is a weighty document that describes the System V API.

The real challenge in computer architecture today is not memory *capacity*, but memory *speed*. Your brand new shiny red Pentium chip isn't going to win you anything if your software is actually constrained by disk and memory latency (access time). To be precise, there is a wide and increasing gap between memory and CPU performance. Over the past decade CPU's have doubled in speed every one-and-a-half to two years. Memory gets twice as dense (64-Kb chips increase to 128 Kb) in the same period, but its access time only improves by 10%. Main memory access time will be even more important on huge address space machines. When you have access to huge amounts of data, the latency for moving it around will start to dominate software performance. Expect to see a lot more use of cache and related technologies in the future.

**Handy Heuristic**

**Where the MS-DOS 640Kb Limit Comes From**

There's a hard memory limit of 640Kbytes available to applications that run under MS-DOS. The limit arises from the maximum address range of the Intel 8086, the original DOS

machine. The 8086 supported 20-bit addresses, restricting it to 1 Mbyte memory in total.

That address space was further limited by reserving certain segments (64Kbyte chunks) for

![Image 80](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-148_1.png)

system use:

**segment**

**reserved for**

F0000 to FFFFF

64 Kb for permanent ROM area BIOS, diagnostics, etc.

D0000 to EFFFF

128 Kb for cartridge ROM area

C0000 to CFFFF

64 Kb for BIOS extensions (XT hard disk)

B0000 to BFFFF

64 Kb for conventional memory display

A0000 to AFFFF 64 Kb for display memory extension

leaving

00000 to 9FFFF

640 Kb for application program use.

A billion and a trillion have different meanings in the U.S. and England. In the U.S. they are a thousand million (109) and a million million (1012), respectively. In England they are bigger, a million million (1012) and a million million million (1018)), respectively. We prefer the American usage because the magnitude increments are consistent from thousand (103) to million (106) to billion (109) to trillion (1012). A billionaire in England is much richer than a billionaire in the U.S.—until the exchange rate sinks to £1,000 per \$1, that is.

There's a 640 Kb limit in MS-DOS that arises from the 1 Mbyte total address space of the 8086 chip.

MS-DOS reserves six entire segments for its own use. This only leaves the 10 64-Kbyte segments starting at address 0 available to applications (and the lowest addresses in 0 block are also reserved for system use as buffers and MS-DOS working store). As Bill Gates said in 1981, "640 K ought to be enough for anybody." When the PC first came out, 640Kb seemed like a tremendous amount of memory. In fact, the first PC came configured with only 16K of RAM as standard.

**Handy Heuristic**

**PC Memory Models**

Microsoft C recognizes these memory models:

small

All pointers are 16 bits, limiting code and data to a single segment each, and the overall program size to 128 K.

large

All pointers are 32 bits. The program can contain many 64-K segments.

medium Function pointers are 32 bits, so there can be many code segments. Data pointers are 16 bits, so there can only be one 64-K data segment.

compact The other way around from medium: function pointers are 16 bits, so the code must be less than 64K. Data pointers are 32 bits so the data can occupy many segments. Stack data is still limited to a single 64-K

segment, though.

Microsoft C recognizes these non-standard keywords; when applied to an object pointer or a function pointer, they override the memory model for that particular pointer only.

\_\_near A 16-bit pointer

\_\_far A 32-bit pointer, but the object pointed to must be all in one segment (no object may be larger than 64 K), i.e., once you load the segment register you can address all of the object from it.

\_\_huge A 32-bit pointer, and the restriction about all being in one segment is lifted.

Example: char \_\_huge \* banana;

Note that these keywords modify the item immediately to their right, in contrast to the const and volatile type qualifiers which modify the pointer immediately to their left.

In addition to the defaults, you can always explicitly declare near, far, and huge pointers in any model. Huge pointers always do comparisons and pointer arithmetic based on canonical

\[1\] values. In canonical form, a pointer offset is always in the range 0 to 15. If two pointers are in canonical form, then an unsigned long comparison will produce accurate results.

It is difficult and error-prone to compile the interaction between array and struct sizes, pointer sizes, memory models, and 80x86 hardware operating modes.

\[1\] We know, we know. We're using "canonical" in the canonical way.

As the spreadsheets and word processors gradually proved themselves, they placed ever-increasing demands on memory. People have devoted a tremendous amount of energy to coping with the limited address space of the IBM PC. A variety of memory expanders and extenders have been produced, but there is no satisfactory portable solution. MS-DOS 1.0 was essentially a port of CP/M to 8086. All later versions retained compatibility with the earliest one. This is why DOS 6.0 is still single-tasking and still uses the "real-address" (8086-compatible) mode of an 80x86, thus maintaining the limits on user program address space. The 8086 memory model has other undesirable effects. Every program that runs on MS-DOS runs with unlimited privilege, permitting easy attacks by virus software. PC

viruses would be almost unknown if MS-DOS used the memory and task protection hardware built into every Intel x86 processor from the 80286 onwards.

**Virtual Memory**

*If it's there and you can see it—it's real*

*If it's not there and you can see it—it's virtual*

*If it's there and you can't see it—it's transparent*

*If it's not there and you can't see it—you erased it!*

—IBM poster explaining virtual memory, circa 1978

![Image 81](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-150_1.png)

It is very inconvenient for a program to be restricted by the amount of main memory installed on a machine, as happens on MS-DOS. So early on in computing, the concept of virtual memory was developed to remove this restriction. The basic idea is to use cheap but slow disk space to extend your fast but expensive main memory. The regions of memory that are actually in use by a program at any given instant are brought into physical memory. When regions of memory lie untouched for a while, they are likely to be saved off to disk, making room to bring in other memory areas that are being used.

All modern computer system from the largest supercomputers to the smallest workstations, with the sole exception of PC's, use virtual memory.

Moving unused parts out to disk used to be done manually by the programmer, back in the early days of computing when snakes could walk. Programmers had to expend vast amounts of effort keeping track of what was in memory at a given time, and rolling segments in and out as needed. Older languages like COBOL still contain a large vocabulary of features for expressing this memory overlaying—totally obsolete and inexplicable to the current generation of programmers.

Multilevel store is a familiar concept. We see it elsewhere on a computer (e.g., in registers vs. main memory). In theory, every memory location could be a register. In practice, this would be prohibitively expensive, so we trade off access speed for a cheaper implementation. Virtual memory just extends this one stage further, using disk instead of main memory to hold the image of a running process. So we have a continuum.

**Handy Heuristic**

![Image 82](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-151_1.png)

Processes on SunOS execute in a 32-bit address space. The OS arranges matters so that each process thinks it has exclusive access to the entire address space. The illusion is sus-tained by "virtual memory," which shares access to the machine's physical memory and uses disk to hold data when memory fills up. Data is continually moved from memory to disk and back again as a process runs.

Memory management hardware translates virtual addresses to physical addresses, and lets a process run anywhere in the system's real memory. Application programmers only ever see the virtual addresses, and don't have any way to tell when their process has migrated out to disk and back into memory again, except by observing elapsed time or looking at system commands like "ps". Figure 7-3

illustrates the virtual memory basics.

***Figure 7-3. The Basics of Virtual Memory***

![Image 83](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-152_1.png)

Virtual memory is organized into "pages." A page is the unit that the OS moves around and protects, typically a few Kbytes in size. You can look at the pagesize on your system by typing

/usr/ucb/pagesize. When a memory image travels between disk and physical memory we say it is being paged in (if going to memory) or paged out (going to disk).

Potentially, all the memory associated with a process will need to be used by the system. If the process is unlikely to run soon (perhaps it is low-priority or is sleeping), all of the physical memory resources allocated to it can be taken away and backed up on disk. The process is then said to be "swapped out."

There is a special "swap area" on disk that holds memory that has been paged or swapped. The swap area will usually be several times bigger than the physical memory on the machine. Only user processes ever page and swap. The SunOS kernel is always memory-resident.

A process can only operate on pages that are in memory. When a process makes a reference to a page that isn't in memory, the MMU generates a page fault. The kernel responds to the event and decides whether the reference was valid or invalid. If invalid, the kernel signals "segmentation violation" to the process. If valid, the kernel retrieves the page from the disk. Once the page gets back into memory, the process becomes unblocked and can start running again—without ever knowing it had been held up for a page-in event.

SunOS has a unified view of the disk filesystem and main memory. The OS uses an identical underlying data structure (the vnode, or "virtual node") to manipulate each. All virtual memory operations are organized around the single philosophy of mapping a file region to a memory region.

This has improved performance and allowed considerable code reuse. You may also hear people talk about the "hat layer"—this is the "hardware address translation" software that drives the MMU. It is very hardware-dependent and has to be rewritten for each new computer architecture.

Virtual memory is an indispensable technique in operating system technology now, and it allows a quart of processes to run in a pint pot of memory. The light relief section at the end of this chapter has an additional description of virtual memory, written as a fable. It's a classic.

**Programming Challenge**

![Image 84](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-153_1.png)

**How Much Memory Can You Allocate?**

Run the following program to see how much memory you can allocate in your process.

\#include \<stdio.h\>

\#include \<stdlib.h\>

main() {

int Mb = 0;

while ( malloc(1\<\<20)) ++Mb;

printf("Allocated %d Mb total\n", Mb);

}

The total will depend on the swap space and process limits with which your system was configured. Can you get more if you allocate smaller chunks than a Mbyte? Why?

To run this program on the memory-limited MS-DOS, allocate 1-Kbyte chunks instead of 1-Mbyte chunks.

**Cache Memory**

Cache memory is a further extension of the multi-level store concept. It is a small, expensive, but extremely fast memory buffer that sits somewhere between the CPU and the physical memory. The cache may be on the CPU side of the memory management unit (MMU), as it is in the Sun SPARCstation 2. In this case it caches *virtual* addresses and must be flushed on each context switch.

(See Figure 7-4.) Or the cache may be on the physical memory side of the MMU, as it is in the SPARCstation 10. This allows easy cache sharing with multiprocessor CPU's by caching *physical* addresses.

***Figure 7-4. The Basics of Cache Memory***

![Image 85](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-154_1.png)

All modern processors use cache memory. Whenever data is read from memory, an entire "line"

(typically 16 or 32 bytes) is brought into the cache. If the program exhibits good locality of reference (e.g., it's striding down a character string), future references to adjacent data can be retrieved from the fast cache rather than the slow main memory. Cache operates at the same speed as the cycle time of the system, so for a 50 MHz processor, the cache runs at 20 nanoseconds. Main memory might typically be four times slower than this! Cache is more expensive, and needs more space and power than regular memory, so we use it as an adjunct rather than as the exclusive form of memory on a system.

The cache contains a list of addresses and their contents. Its list of addresses is constantly changing, as the processor references new locations. Both reads and writes go through the cache. When the processor wants to retrieve data from a particular address, the request goes first to the cache. If the data is already present in the cache, it can be handed over immediately. Otherwise, the cache passes the request on, and a slower access to main memory takes place. A new line is retrieved, and it takes its place in the cache.

If your program has somewhat perverse behavior and just misses cache every time, you end up with worse performance than if there was no cache at all. This is because all the extra logic of figuring out what is where doesn't come free.

Sun currently uses two types of cache:

• Write-through cache— This always initiates a write to main memory at the same time it writes to the cache.

• Write-back cache— In the first instance, this writes only to cache. The data is transferred to main memory when the cache line is about to be written again and a save hasn't taken place yet. It will also be transferred on a context switch to a different process or the kernel.

![Image 86](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-155_1.png)

In both cases, the instruction stream continues as soon as the cache access completes, without waiting for slower memory to catch up.

The cache on a SPARCstation 2 holds 64 Kbytes of write-through data, and a line is 32 bytes in size.

Much larger caches are becoming commonplace: the SPARCserver 1000 has a 1-Mbyte write-back cache memory. There may be a separate cache for the I/O bus if the processor uses memory-mapped I/O, and there are often separate caches for instructions and data. There can also be multi level caches, and caches also can be applied whenever there is an interface between fast and slow devices (e.g., between disk and memory). PC's often use a main memory cache to help a slow disk. They call this

"RAMdisk". In UNIX, disk inodes are cached in memory. This is why the filesystem can be corrupted by power-ing the machine off without first flushing the cache to disk with the "sync" command.

Cache and virtual memory are both invisible to the applications programmer, but it's important to know the benefits that they provide and the manner in which they can dramatically affect performance.

***Table 7-1. Cache Memories Are Made of This***

**Term Definition**

Line A line is the unit of access to a cache. Each line has two parts: a data section, and a tag specifying the address that it represents.

Block The data content of a line is referred to as a block. A block holds the bytes moved between a line and main memory. A typical block size is 32 bytes.

The contents of a cache line represent a particular block of memory, and it will respond if a processor tries to access that address range. The cache line "pretends" to be that address range in memory, only considerably faster.

"Block" and "line" are used loosely and interchangeably by most people in the computer industry.

Cache A cache consists of a big (typically 64 Kbytes to 1 Mbyte or more) collection of lines.

Sometimes associative memory hardware is used to speed up access to the tags. Cache is located next to the CPU for speed, and the memory system and bus are highly tuned to optimize the movement of cache-block-sized chunks of data.

**Handy Heuristic**

**One Experience with Cache**

Run the following program to see if you can detect cache effects on your system.

\#define DUMBCOPY for (i = 0; i \< 65536; i++) \\

destination\[i\] = source\[i\]

\#define SMARTCOPY memcpy(destination, source, 65536) main()

{

char source\[65536\], destination\[65536\];

int i, j;

for (j = 0; j \< 100; j++)

SMARTCOPY;

}

% cc -O cache.c

% time a.out

1.0 seconds user time

\# change to DUMBCOPY and recompile

% time a.out

7.0 seconds user time

Compile and time the run of the above program two different ways, first as it is, and then with the macro call changed to DUMBCOPY. We measured this on a SPARCstation 2, and there was a consistent large performance degradation with the dumb copy.

The slowdown happens because the source and destination are an exact multiple of the cache size apart. Cache lines on the SS2 aren't filled sequentially—the particular algorithm used happens to fill the same line for main memory addresses that are exact multiples of the cache size apart. This arises from optimized storage of tags—only the high-order bits of each address are put in the tag in this design.

All machines that use a cache (including supercomputers, modern PC's, and everything in between) are subject to performance hits from pathological cases like this one. Your mileage will vary on different machines and different cache implementations.

In this particular case both the source and destination use the same cache line, causing every memory reference to miss the cache and stall the processor while it waited for regular memory to deliver. The library memcpy() routine is especially tuned for high performance.

It unrolls the loop to read for one cache line and then write, which avoids the problem.

Using the smart copy, we were able to get a huge performance improvement. This also shows the folly of drawing conclusions from simple-minded benchmark programs.

**The Data Segment and Heap**

We have covered the background on system-related memory issues, so it's time to revisit the layout of memory inside an individual process. Now that you know the system issues, the process issues will start making a lot more sense. Specifically, we'll begin by taking a closer look at the data segment within a process.

Just as the stack segment grows dynamically on demand, so the data segment contains an object that can do this, namely, the heap, shown in Figure 7-5. The heap area is for dynamically allocated storage, that is, storage obtained through malloc (memory allocate) and accessed through a pointer.

![Image 87](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-157_1.png)

Everything in the heap is anonymous—you cannot access it directly by name, only indirectly through a pointer. The malloc (and friends: calloc, realloc, etc.) library call is the only way to obtain storage from the heap. The function **c** alloc is like malloc, but **c**lears the memory to zero before giving you the pointer. Don't think that the " **c** " in **c** alloc() has anything to do with C programming—it means

"allocate zeroized memory". The function realloc() changes the size of a block of memory pointed to, either growing or shrinking it, often by copying the contents somewhere else and giving you back a pointer to the new location. This is useful when growing the size of tables dynamically—more about this in Chapter 10.

***Figure 7-5. Where the Heap Lives***

Heap memory does not have to be returned in the same order in which it was acquired (it doesn't have to be returned at all), so unordered malloc/free's eventually cause heap fragmentation. The heap must keep track of different regions, and whether they are in use or available to malloc. One scheme is to have a linked list of available blocks (the "free store"), and each block handed to malloc is preceded by a size count that goes with it. Some people use the term *arena* to describe the set of blocks managed by a memory allocator (in SunOS, the area between the end of the data segment and the current position of the break).

Malloced memory is always aligned appropriately for the largest size of atomic access on a machine, and a malloc request may be rounded up in size to some convenient power of two. Freed memory goes back into the heap for reuse, but there is no (convenient) way to remove it from your process and give it back to the operating system.

The end of the heap is marked by a pointer known as the "break". \[2\] When the heap manager needs more memory, it can push the break further away using the system calls brk and sbrk. You typically don't call brk yourself explicitly, but if you malloc enough memory, brk will eventually be called for you. The calls that manage memory are:

\[2\] Your programs will "break" if they reference past the break...

malloc and free— get memory from heap and give it back to heap brk and sbrk— adjust the size of the data segment to an absolute value/by an increment One caution: your program may not call both malloc() and brk(). If you use malloc, malloc expects to have sole control over when brk and sbrk are called. Since sbrk provides the only way for a process to return data segment memory to the kernel, if you use malloc you are effectively prevented from ever shrinking the program data segment in size. To obtain memory that can later be returned to the kernel, use the mmap system call to map the /dev/zero file. To return this memory, use munmap.

**Memory Leaks**

Some programs don't need to manage their dynamic memory use; they simply allocate what they need, and never worry about freeing it. This class includes compilers and other programs that run for a fixed or bounded period of time and then terminate. When such a program finishes, it automatically relinquishes all its memory, and there is little need to spend time giving up each byte as soon as it will no longer be used.

Other programs are more long-lived. Certain utilities such as calendar manager, mailtool, and the operating system itself have to run for days or weeks at a time, and manage the allocation and freeing of dynamic memory. Since C does not usually have garbage collection (automatic identification and deallocation of memory blocks no longer in use) these C programs have to be very careful in their use of malloc() and free(). There are two common types of heap problems:

• freeing or overwriting something that is still in use (this is a "memory corruption")

• not freeing something that is no longer in use (this is a "memory leak") These are among the hardest problems to debug. If the programmer does not free each malloced block when it is no longer needed, the process will acquire more and more memory without releasing the portions no longer in use.

**Handy Heuristic**

![Image 88](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-159_1.png)

**Avoiding Memory Leaks**

Whenever you write malloc, write a corresponding free statement.

If you don't know where to put the "free" that corresponds to your "malloc", then you've probably created a memory leak!

One simple way to avoid this is to use alloca() for your dynamic needs when possible.

The alloca() routine allocates memory on the stack; when you leave the function in which you called it, the memory is automatically freed.

Clearly, this can't be used for structures that need a longer lifetime than the function invocation in which they are created; but for stuff that can live within this constraint, dynamic memory allocation on the stack is a low-overhead choice. Some people deprecate the use of alloca because it is not a portable construct. alloca() is hard to implement efficiently on processors that do not support stacks in hardware.

We use the term "memory leak" because a scarce resource is draining away in a process. The main user-visible symptom of a memory leak is that the guilty process slows down. This happens because larger processes are more likely to have to be swapped out to give other processes a chance to run.

Larger processes also take a longer time to swap in and out. Even though (by definition) the leaked memory itself isn't referenced, it's likely to be on a page with something that is, thus enlarging the working set and slowing performance. An additional point to note is that a leak will usually be larger than the size of the forgotten data structure, because malloc() usually rounds up a storage request to the next larger power-of-two. In the limiting case, a process with a memory leak can slow the whole machine down, not just the user running the offending program. A process has a theoretical size limit that varies from OS to OS. On current releases of SunOS, a process address space can be up to 4

Gbytes; in practice, swap space would be exhausted long before a process leaked enough memory to grow that big. If you're reading this book five years after it was written, say around the turn of the millenium, you'll probably get a good laugh over this by then long-obsolete restriction.

**How to Check for a Memory Leak**

Looking for a memory leak is a two-step process. First you use the swap command to see how much swap space is available:

/usr/sbin/swap -s

total: 17228k bytes allocated + 5396k reserved = 22624k used,

29548k

available

![Image 89](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-160_1.png)

Type the command three or four times over the space of a minute or two, to see if available swap space keeps getting smaller. You can also use others of the /usr/bin/\*stat tools, netstat, vmstat, and so on. If you see an increasing amount of memory being used and never released, one possible explanation is that a process has a memory leak.

**Handy Heuristic**

**Listening to the Network's Heartbeat: Click to Tune**

Of all the network investigative tools, the absolute tops is snoop.

The SVr4 replacement for etherfind, snoop captures packets from the network and displays them on your workstation. You can tell snoop just to concentrate on one or two machines, say your own workstation and your server. This can be useful for troubleshooting connectivity problems—snoop can tell you if the bytes are even leaving your machine.

The absolute best feature of snoop, though, is the -a option. This causes snoop to output a click on the workstation loudspeaker for each packet. You can *listen* to your network ether traffic. Different packet lengths have different modulation. If you use snoop -a a lot, you get good at recognizing the characteristic sounds, and can troubleshoot and literally tune a net "by ear"!

The second step is to identify the suspected process, and see if it is guilty of a memory leak. You may already know which process is causing the problem. If not, the command ps -lu *username* shows the size of all your processes, as in the example below:

F S UID PID PPID C PRI NI ADDR SZ WCHAN TTY TIME COMD

8 S 5303 226 224 80 1 20 ff38f000 199 ff38f1d0 pts/3 0:01 csh

8 O 5303 921 226 29 1 20 ff38c000 143 pts/3 0:00 ps

The column headed SZ is the size of the process in pages. (The pagesize command will tell you how big that is in Kbytes if you really must know.) Again, repeat the command several times; any program that dynamically allocates memory can be observed growing in size. If a process appears to be constantly growing and never leveling off, then suspect a memory leak. It's a sad fact of life that managing dynamic memory is a very difficult programming task. Some public domain X-Window applications are notorious for leaking like the Apple Computer board of directors.

Systems often have different malloc libraries available, including ones tuned for optimal speed or optimal space usage, and to help with debugging. Enter the command man -s 3c malloc

![Image 90](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-161_1.png)

to look at the manpage, and to see all the routines in the malloc family.

Make sure you link with the appropriate library. The SPARCWorks debugger on Solaris 2.x has extensive features to help detect memory leaks; these have supplanted the special malloc libraries on Solaris 1.x.

**Software Dogma**

**The President and the Printtool—A Memory Leak Bug**

The simplest form of memory leak is:

for (i=0; i\<10; i++)

p = malloc(1024);

This is the *Exxon Valdez* of software; it leaks away everything you give it.

With each successive iteration, the previous address held in p is overwritten, and the Kbyte block of memory that it points to "leaks away". Since nothing now points to it, there is no way to access or free that memory. Most memory leaks aren't quite as blatant as overwriting the only pointer to the block before it can be freed, so they are harder to identify and debug.

An interesting case occurred with the printtool software here at Sun. An internal test release of the operating system was installed on the desktop system of Scott McNealy, the company president. \[1\] The president soon noticed that over the course of a couple of days, his workstation became slower and slower. Rebooting fixed it instantly. He reported the problem, and nothing concentrates the mind like a bug report filed by the company president.

We found that the problem was triggered by "printtool", a window interface around the print command. "Printtool" is the kind of software much used by company presidents but not by OS developers, which is why the problem had lain undiscovered. Killing printtool caused the memory leak to stop, but ps -lu scott showed that printtool was only triggering the leak, not growing in size itself. It was necessary to look at the system calls that printtool used.

The design of printtool had it allocate a named pipe (a special type of file that allows two unrelated processes to communicate) and use it to talk to the line printer process. A new pipe was created every few seconds, then destroyed if printtool didn't have anything interesting to tell the printer. The real memory leak bug was in the pipe creation system call.

When a pipe was created, kernel memory was allocated to hold the vnode data structure to control it, but the code that kept a reference count for the structure was off by one.

As a result, when the true number of pipe users dropped to zero, the count stayed at 1, so the kernel always thought the pipe was in use. Thus, the vnode struct was never freed as it should have been when the pipe was closed. Every time a pipe was closed, a few hundred

bytes of memory leaked away in the kernel. This added up to megabytes lost per day—

enough to bring the entry-level workstation that we give presidents to its knees after two or three days.

We corrected the off-by-one bug in the vnode reference count algorithm, and the regular kernel memory free routine kicked in just as it was supposed to. We also changed printtool to use a smarter algorithm than just continually yammering at the printer every few seconds.

The memory leak was plugged, the programmers breathed a sigh of relief, the engineering manager started to smile again, and the president went back to using printtool.

\[1\] Actually, this *is* quite a good idea. Having the president run early release software and participate in the internal testing process keeps everyone on their toes. It ensures that upper management has a good understanding of the evolving product and how fast it is improving.

And it provides product engineering with both the motivation and resources to shake out the last few bugs.

The operating system kernel also manages its memory use dynamically. Many tables of data in the kernel are dynamically allocated, so that no fixed limit is set in advance. If a kernel programming error causes a memory leak, the machine slows down; in the limiting case the machine hangs or even panics. When kernel routines ask for memory they usually wait until it becomes available. If memory is leaking away, eventually there is none available, and everyone ends up waiting—the machine is hung. Memory leaks in the kernel usually show up rapidly, as most paths through the kernel are pretty well travelled. We also have specialized software tools to test for and exercise kernel memory management.

**Bus Error, Take the Train**

When I first started programming on UNIX in the late 1970's, like many people I quickly ran into two common runtime errors:

bus error (core dumped)

and

segmentation fault (core dumped)

At the time these errors were very frustrating: there was no simple explanation of the kind of source errors that caused them, the messages gave no clue where to look in the code, and the difference between them wasn't at all clear. And it's still the same today.

Most of the problem lies in the fact that the errors represent an anomaly the operating system has detected, and the anomaly is reported in terms most convenient to the operating system. The precise causes of a bus error and a segmentation fault will thus vary among different versions of operating system. Here, we describe what they mean on SunOS running on the SPARC architecture, and what causes them.

Both errors occur when hardware tells the OS about a problematic memory reference. The OS

communicates this to the faulting process by sending it a signal. A *signal* is an event notification or a software-generated interrupt, much used in UNIX systems programming and hardly ever used in

![Image 91](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-163_1.png)

applications programming. By default, on receiving the "bus error" or the "segmentation fault" signal, a process will dump core and terminate; but you can impose some different action by setting up a signal handler for these signals.

Signals were modeled on hardware interrupts. Interrupt programming is hard because things happen asynchronously (at unpredictable times); therefore, signal programming and debugging is hard. You can glean more information by reading the manpage for signal, and looking at the include file

/usr/include/sys/signal.h.

**Programming Challenge**

**Catching Signals on the PC**

Signal handling functions are a part of ANSI C now, and they apply equally to PCs as well as UNIX. For example, a PC programmer can use the signal() function to catch Ctrl-Break and prevent a user breaking out of the program.

Write a signal handler to catch the INT 1B (Ctrl-Break) signal on a PC. Have it print a user-friendly message, but not exit.

If you use UNIX, write a signal handler, so that on receiving a control-C (control-C is passed to a UNIX process as a SIGINT signal) the program restarts, rather than quits. The typedefs that will help you define a signal handler are shown in Chapter 3 on declarations.

The header file \<signal.h\> needs to be included in any source file that uses signals.

The "core dump" part of the message is just a throwback to the days when all memory was made of ferrite rings, or "cores". Semiconductor memory has been the rule for 15 years or more, but "core"

persists as a synonym for "main memory".

**Bus Error**

In practice, a bus error is almost always caused by a misaligned read or write. It's called a bus error, because the address bus is the component that chokes if a misaligned load or store is requested.

Alignment means that data items can only be stored at an address that is a multiple of their size. On modern architectures, especially RISC architectures, data alignment is required because the extra logic associated with arbitrary alignment makes the whole memory system much larger and slower. By forcing each individual memory access to remain in one cache line or on a single page, we greatly simplify (and therefore speed up) hardware like cache controllers and memory management units.

The way we express the "no data item may span a page or cache boundary" rule is somewhat indirect, in that we state it in terms of address alignment rather than a prohibition on crossing page boundaries, but it comes down to the same thing. For example, accesses to an 8-byte double are only permitted at addresses that are an exact multiple of 8 bytes. So a double can be stored at address 24, address 8008,

or address 32768, but not at address 1006 (since it is not exactly divisible by 8). Page and cache sizes are carefully designed so that keeping the alignment rule will ensure that no atomic data item spills over a page or cache block boundary.

The requirement for data to be stored aligned always reminds us of the kids' game of walking down a sidewalk without placing a foot on a crack in the paving stones. *"Step on a crack, break your mother 's* *back"* has mutated to *"dereference nonaligned then cuss, cause an error on the bus."* Maybe it's Freudian or something; Mother was frightened by a Fortran I/O channel at an impressionable age. A small program that will cause a bus error is:

union { char a\[10\];

int i;

} u;

int \*p= (int\*) &(u.a\[1\]);

\*p = 17; /\* the misaligned addr in p causes a bus error! \*/

This causes a bus error because the array/int union ensures that character array "a" is also at a reasonably aligned address for an integer, so "a+1" is definitely not. We then try to store 4 bytes into an address that is aligned only for single-byte access. A good compiler will warn about misalignment, but it cannot spot all occurrences.

The compilers automatically allocate and pad data (in memory) to achieve alignment. Of course, there is no such alignment requirement on disk or tape, so programmers can remain blissfully unaware of alignment—until they cast a char pointer to an int pointer, leading to mysterious bus errors. A few years ago bus errors were also generated if a memory parity error was detected. These days memory chips are so reliable, and so well protected by error detection and correction circuitry, that parity errors are almost unheard of at the application programming level. A bus error can also be generated by referencing memory that does not physically exist; you probably won't be able to screw up this badly without help from a naughty device driver.

**Segmentation Fault**

The segmentation fault or violation should already be clear, given the segment model explained earlier.

On Sun hardware, segmentation faults are generated by an exception in the memory management unit (the hardware responsible for supporting virtual memory). The usual cause is dereferencing (looking at the contents of the address contained in) a pointer with an uninitialized or illegal value. The pointer causes a memory reference to a segment that is not part of your address space, and the operating system steps in. A small program that will cause a segmentation fault is: int \*p=0;

\*p = 17; /\* causes a segmentation fault \*/

One subtlety is that it is usually a different programmatic error that led to the pointer having an invalid value. Unlike a bus error, a segmentation fault will therefore be the indirect symptom rather than the cause of the fault.

A worse subtlety is that if the value in the uninitialized pointer happens to be misaligned for the size of data being accessed, it will cause a bus error fault, not a segmentation violation. This is true for most architectures because the CPU sees the address before sending it to the MMU.

![Image 92](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-165_1.png)

![Image 93](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-165_2.png)

**Programming Challenge**

**Test Crash Your Software**

Complete the test program fragments above.

Try running them to see how these bugs are reported by the OS.

*Extra Credit:* Write signal handlers to catch the bus error and segmentation fault signals.

Have them print a more user-friendly message, and exit.

Rerun your program.

The dereferencing of the illegal pointer value may be done explicitly in your code as shown above, or it may occur in a library routine if you pass it a bad value. Unhappily, changing your program (e.g., compiling for debugging or adding extra debugging statements) can easily change the contents of memory such that the problem moves or disappears. Segmentation faults are tough to solve, and only the strong will survive. You know it's a really tough bug when you see your colleagues grimly carrying logic analyz-ers and oscilloscopes into the test lab!

**Software Dogma**

**A Segmentation Violation Bug in SunOS**

We recently had to solve a segmentation fault that was occurring when the ncheck utility was run on a corrupted filesystem. This was a very distressing bug, because you are most likely to use ncheck to investigate filesystems that you suspect of corruption.

The symptom was that ncheck was failing in printf, by dereferencing a null pointer and causing a segmentation violation. The faulty statement was:

(void) printf("%s", p-\>name);

Most junior programmers from Yoyodyne Software Corp. would fix this in a long-winded way:

if (p-\>name != NULL)

(void) printf("%s", p-\>name );

else

(void) printf("(null)");

In cases like this, however, the conditional operator can be used instead to simplify the code and maintain locality of reference:

(void) printf("%s", p-\>name ? p-\>name : "(null)"); A lot of people prefer not to use the — ? — : — conditional operator, because they find it confusing. The operator makes a whole lot more sense when compared with an if statement: if ( *expression*) *statement-when-non-zero* else *statement-when-zero*

*expression* ? *expression-when-non-zero*: *expression-when-zero*

When looked at this way, the conditional operator is quite intuitive, and allows us to feel happy with the one-liner instead of needlessly inflating the size of the code. But never nest one conditional operator inside another, as it quickly becomes too hard to see what goes with what.

Common immediate causes of segmentation fault:

• dereferencing a pointer that doesn't contain a valid value

• dereferencing a null pointer (often because the null pointer was returned from a system routine, and used without checking)

• accessing something without the correct permission—for example, attempting to store a value into a read-only text segment would cause this error

• running out of stack or heap space (virtual memory is huge but not infinite) It's a little bit of an oversimplification, but for most architectures in most cases, a bus error means that the CPU disliked something about that memory reference, while a segv means that the MMU disliked something about it.

The common programming errors that (eventually) lead to something that gives a segmentation fault, in order of occurrence, are:

1\. **Bad pointer value errors:** using a pointer before giving it a value, or passing a bad pointer to a library routine. (Don't be fooled by this one! If the debugger shows that the segv occurred in a system routine, it doesn't mean that the system caused it. The problem is still likely to be in your code.) The third common way to generate a bad pointer is to access something after it has been freed. You can amend your free statements to clear a pointer after freeing what it points to: 2.

![Image 94](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-167_1.png)

free(p); p = NULL;

This ensures that if you do use a pointer after you have freed it, at least the program core dumps at once.

3\. **Overwriting errors:** writing past either end of an array, writing past either end of a malloc'd block, or overwriting some of the heap management structures (this is all too easy to do by writing before the beginning of a malloc'd block).

4\.

p=malloc(256); p\[-1\]=0; p\[256\]=0;

5\. **Free'ing errors:** freeing the same block twice, freeing something that you didn't malloc, freeing some memory that is still in use, or freeing an invalid pointer. A very common free error is to cdr \[3\] down a linked list in a for (p=start; p; p=p-

\>next) loop, then in the loop body do a free(p). This leads a freed pointer to be dereferenced on the next loop iteration, with unpredictable results.

\[3\] Car and cdr are two LISP terms for the head and remainder of a list, respectively.

Cdr'ing down a list is processing the list by picking successive elements off the front.

Car and cdr come from the IBM 704, a 36-bit vacuum-tube processor with 15-bit addresses. Core memory locations were called "registers". CAR meant "contents of address part of register", and CDR was "contents of decrement part of register". These were brief routines, and the LISP 1.5 manual (MIT Press, 1962) lists them in their entirety. Here's CAR

CAR SXA CARX,4

PDX 0,4

CLA 0,4

PAX 0,4

PXD 0,4

CARX AXT \*\*,4

TRA 1,4

LISP 1.0 originally had CTR and CXR, too, contents of tag part of register and contents of index part of register. These weren't very useful, and were dropped from LISP 1.5.

**Handy Heuristic**

![Image 95](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-168_1.png)

**How to Free Elements in a Linked List**

The correct way to free an element while traversing down a linked list is to use a temporary variable to store the address of the next element. Then you can safely free the current element at any time, and not have to worry about referencing it again to get the address of the next. The code is:

struct node \*p, \*start, \*tmp;

for (p=start; p; p=tmp) {

tmp=p-\>next;

free(p);

}

**Software Dogma**

**Is Your Program Out of Space?**

If your program needs more memory than the operating system can give it, it will be terminated with a "segmentation fault". You can distinguish this type of segmentation fault from one of the more bug-based ones by the method described here.

To tell if it ran off the stack, run it under dbx:

% dbx a.out

(dbx) catch SIGSEGV

(dbx) run

...

signal SEGV (segmentation violation) in \<some_routine\>

at 0xeff57708

(dbx) where

If you now see a call chain, then it hasn't run out of stack space.

If instead you see something like:

fetch at 0xeffe7a60 failed -- I/O error

(dbx)

then it probably has run out of stack space. That hex number is the stack address which could not be mapped or retrieved.

You can also try adjusting the segment limits in C-shell: limit stacksize 10

You can adjust the maximum size of the stack and the data segments in the C-shell. The line above sets it to 10 Kbytes. Try giving your program less stack space, and see if it fails at an earlier point. Try giving it more stack space, and see if it now runs successfully. A process will still be limited overall by the size of swap space, which can be found by typing the swap -s command.

Anything can happen with a bad pointer value. The accepted wisdom is that if you're "lucky," it will point outside your address space, so the first use will cause the program to dump core and stop. If you're "unlucky," it will point inside your address space and cor-rupt (overwrite) whatever area of memory it points at. This leads to obscure bugs that are very hard to track down. A number of excellent software tools have come on the market in recent years to aid in solving this kind of problem.

**Some Light Relief—The Thing King and the Paging Game**

The section that follows was written by Jeff Berryman in 1972 when he was working on project MAC

and running one of the early virtual memory systems. Jeff somewhat rue-fully comments that of all the papers he has ever written, this one is the most popular and widely read. It's as applicable today as it was twenty years ago.

**The Paging Game**

This note is a formal non-working paper of the Project MAC Computer Systems Research Division. It should be reproduced and distributed wherever levity is lacking, and may be referenced at your own risk in other publications.

***Rules***

1\. Each player gets several million things.

2\. Things are kept in crates that hold 4096 things each. Things in the same crate are called crate-mates.

3\. Crates are stored either in the workshop or the warehouse. The workshop is almost always too small to hold all the crates.

4\. There is only one workshop but there may be several warehouses. Everybody shares them.

5\. Each thing has its own thing number.

6\. What you do with a thing is to zark it. Everybody takes turns zarking.

7\. You can only zark your things, not anybody else's.

8\. Things can only be zarked when they are in the workshop.

9\. Only the Thing King knows whether a thing is in the workshop or in a warehouse.

10\. The longer a thing goes without being zarked, the grubbier it is said to become.

11\. The way you get things is to ask the Thing King. He only gives out things in multiples of eight. This is to keep the royal overhead down.

12. The way you zark a thing is to give its thing number. If you give the number of a thing that happens to be in a workshop it gets zarked right away. If it is in a warehouse, the Thing King packs the crate containing your thing back into the workshop. If there is no room in the workshop, he first finds the grubbiest crate in the workshop, whether it be yours or somebody else's, and packs it off with all its crate-mates to a warehouse. In its place he puts the crate containing your thing. Your thing then gets zarked and you never know that it wasn't in the workshop all along.

13\. Each player 's stock of things have the same numbers as everybody else's. The Thing King always knows who owns what thing and whose turn it is, so you can't ever accidentally zark somebody else's thing even if it has the same thing number as one of yours.

***Notes***

1\. Traditionally, the Thing King sits at a large, segmented table and is attended to by pages (the so-called "table pages") whose job it is to help the king remember where all the things are and who they belong to.

2\. One consequence of Rule 13 is that everybody's thing numbers will be similar from game to game, regardless of the number of players.

3\. The Thing King has a few things of his own, some of which move back and forth between workshop and warehouse just like anybody else's, but some of which are just too heavy to move out of the workshop.

4\. With the given set of rules, oft-zarked things tend to get kept mostly in the workshop while little-zarked things stay mostly in a warehouse. This is efficient stock control.

*Long Live the Thing King!*

Now doesn't that look a lot more interesting than the non-allegorical translated version below?

***Rules***

1\. Each player gets several million "bytes."

2\. Bytes are kept in "pages" that hold 4096 bytes each. Bytes on the same page have

"locality of reference".

3\. Pages are stored either in memory or on a disk. The memory is almost always too small to hold all the pages.

4\. There is only one memory but there may be several disks. Everybody shares them.

5\. Each byte has its own "virtual address."

6\. What you do with a byte is to "reference" it. Everybody takes turns referencing.

7\. You can only reference your bytes, not anybody else's.

8\. Bytes can only be referenced when they are in memory.

9\. Only the "VM manager" knows whether a byte is in memory or on a disk.

10\. The longer a byte goes without being referenced, the "older" it is said to become.

11\. The way you get bytes is to ask the VM manager. It only gives out bytes in multiples of powers of two. This is to keep overhead down.

![Image 96](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-171_1.png)

12\. The way you reference a byte is to give its virtual address. If you give the address of a byte that happens to be in the memory it gets referenced right away. If it is on disk, the VM manager brings the page containing your byte back into the memory. If there is no room in the memory, it first finds the oldest page in the memory, whether it be yours or somebody else's, and packs it off with the rest of the page to a disk. In its place it puts the page containing your byte. Your byte then gets referenced and you never know that it wasn't in the memory all along.

13\. Each player 's stock of bytes have the same virtual addresses as everybody else's. The VM manager always knows who owns what byte and whose turn it is, so you can't ever accidentally reference somebody else's byte even if it has the same virtual address as one of yours.

***Notes***

1\. Traditionally, the VM manager uses a large, segmented table and "page tables" to remember where all the bytes are and who they belong to.

2\. One consequence of Rule 13 is that everybody's virtual addresses will be similar from run to run, regardless of the number of processes.

3\. The VM manager has a few bytes of his own, some of which move back and forth between memory and disk just like anybody else's, but some of which are just too heavily used to move out of the memory.

4\. With the given set of rules, oft-referenced bytes tend to get kept mostly in the memory while little-used bytes stay mostly in a disk. This is efficient memory utilization.

*Long Live the VM Manager!*

**Programming Solution**

**A Signal Handler to Catch the segv Signal**

\#include \<signal.h\>

\#include \<stdio.h\>

void handler(int s)

{

if (s == SIGBUS) printf(" now got a bus error

signal\n");

if (s == SIGSEGV) printf(" now got a segmentation

![Image 97](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-172_1.png)

violation signal\n");

if (s == SIGILL) printf(" now got an illegal

instruction signal\n");

exit(1);

}

main () {

int \*p=NULL;

signal(SIGBUS, handler);

signal(SIGSEGV, handler);

signal(SIGILL, handler);

\*p=0;

}

Running this program results in this output:

% a.out

now got a segmentation violation signal

Note: this is an example for teaching purposes. Section 7.7.1.1 of the ANSI standard points out that in the circumstances we have here, the behavior is undefined when the signal handler calls any function in the standard library such as printf.

**Programming Solution**

**Using setjmp/longjmp to Recover from a Signal**

This program uses setjmp/longjmp and signal handling, so that on receiving a control-C

(passed to a UNIX process as a SIGINT signal) the program restarts, rather than quits.

\#include \<setjmp.h\>

\#include \<signal.h\>

\#include \<stdio.h\>

jmp_buf buf;

void handler(int s)

{

if (s == SIGINT) printf(" now got a SIGINT

signal\n");

longjmp(buf, 1);