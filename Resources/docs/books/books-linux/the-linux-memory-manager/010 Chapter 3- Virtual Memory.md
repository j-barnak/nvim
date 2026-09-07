


**3**



**V I R T U A L M E M O R Y**



Arguably the most important memory feature pro-

vided by hardware is the ability to abstract memory

addresses altogether. This forms the basis of modern

memory management by allowing separation of the ad-

dress spaces of each running process as well as permit-

ting the kernel to decide the permissions of memory

ranges and how to handle invalid accesses. Over the

course of this chapter we’ll examine how the kernel

initializes and manages virtual memory.

In the past, hardware placed no restriction on software being able to ac-

cess all available physical memory on a machine. This is problematic in a

number of respects:



**Stability** A program can access memory regardless of whose it is—its own,

another program’s or the system’s. This means that a programming er-ror resulting in the access of unintended memory can result in unrecov-erable memory corruption, a system hang if you are lucky, and/or data loss if you are not.

**Complexity** Loading programs is significantly complicated. The OS has to

ensure that it loads programs in such a position in memory that it not




only doesn’t overlap that of other programs but also doesn’t overlap the memory they are yet to use.

**Security** Every process is as privileged as any other and can access data no

matter how sensitive at will, which means that in effect there is no secu-rity between programs at all.

**Contiguity** A contiguous block of memory is one that spans an address

range without gaps. If you expose physical memory directly, then ob-taining contiguous blocks of memory becomes a real problem; you don’t control the physical memory layout so fragmentation is an ever-present threat and memory cannot be moved because any program referencing it holds a pointer to the actual location in memory, which would be invalidated on any attempt to move it. A sensible program will expect to be allocated contiguous memory, so as a result, memory ex-haustion due to fragmentation becomes likely.

**Capacity** When physical memory is exposed directly, you can access only

the physical memory available to the system. This might seem a moot point, but facilities like paging are unavailable rendering running out of memory a critical system failure.



Different approaches to solving these problems have been tried through-

out the history of computing, but the one hardware developers have con-verged upon is virtual memory.

The concept is simple. Rather than expose physical memory directly, use

virtual addresses that can be mapped arbitrarily to physical addresses at page granularity and alignment. Once this is place, you can have each process be-lieve it has all of the memory available to itself, which at a stroke eliminates all of the aforementioned issues.



**N O T E** I differentiate between programs and processes here because without virtual memory,

the concept of a process is rather meaningless.



The concept of virtual memory really does necessitate a separation be-

tween “privileged” kernel code and “unprivileged” user space as the ability to map virtual memory to physical implies access to all memory and thus only the kernel can be permitted to do this.

Ultimately support for virtual memory has to come from hardware,

which provides the ability to change virtual memory mappings and deter-mines whether currently executed code is privileged or not (thus whether or not the mapping can be changed).

Using this facility, a kernel can switch out virtual mappings for user space

processes so each has their own independent virtual address space. The kernel provides system calls to allocate memory into their address space at a page granularity thus abstracting the process of obtaining memory altogether. From the kernel’s point of view, this is a two-step process: allocating physical memory, then mapping it into the process.

When user space processes access unmapped memory or memory they

are not permitted to, or try to perform an operation that’s not permitted







in that virtual memory range (for example, write in a read-only mapping or

execute code in memory marked non-executable), the CPU generates a page

fault, a hardware exception that the kernel can trap and respond to.

When accessing arbitrary memory that it should not, the kernel can seg-

fault the process in a fashion every application programmer is familiar with.

However, page faults can also be used to facilitate other useful functionality

(a non-exhaustive list):



**Demand paging** We said earlier that userland memory allocation from the

kernel’s perspective is a two-step process: physical allocation and virtual mapping. However, the kernel can also choose to be “lazy” and instead make this a zero-step operation—simply updating an internal data struc-ture signifying that the allocated memory range is a valid virtual mem-ory range. Doing so allows it to defer the actual allocation and mapping to when the memory is accessed rather than allocated (and a page fault

is raised). This is a powerful concept that we’ll revisit in Chapter 4 on

process memory, and Chapter 6 page faults.

**Copy-On-Write (CoW) semantics** An important facility for a Unix operating

system is the ability to fork processes. This is where a process makes an exact copy of itself that executes independently as a new child process. Virtual memory permits a very efficient means of doing so: copy the virtual memory mappings (but not the underlying physical memory) and mark them read-only and “copy on write.” As the name suggests, this instructs the kernel to copy the underlying physical memory only when it is written to. By marking the mapping read-only, we can use the resultant page fault to copy only those pages that are written to.

**NUMA balancing** In a NUMA system a core may take longer to access some

memory that is not “local”—that is, physically near it. It may not be ob-vious which core will ultimately access a particular memory page, so in order to ensure that memory allocations are efficiently distributed, user-land memory can be periodically unmapped, allowing for migrate-on-fault semantics—that is, if the current core accessing the memory on fault is not local to it, migrate and re-map.



As the hardware mechanics virtual memory relies upon are inevitably

architecture-specific, I have, for brevity, chosen to focus on x86-64 for the

those parts of the kernel code which interface with the hardware directly

(as I have done so across the book). This applies to only a minority of the

code examined here, so the majority of the contents of this chapter remain

relevant regardless of architecture.



**3.1 Page Tables**



In the previous chapter on physical memory allocation, I remarked that

memory must be divided into pages in order to be managed sensibly. The

same applies to virtual memory mappings that also have to be mapped at a

page granularity to remain manageable.







This leaves us with a question: how should we map virtual pages to phys-

ical ones? Subdividing memory into pages alone doesn’t save us from mem-ory exhaustion, as a 64-bit system has up to 264 bytes of available address space. If memory were subdivided into 4KiB pages and directly mapped, this would result in 4,503,599,627,370,496 pages, and the mapping metadata alone would require 32 petabytes of RAM. Increasing page size to anything within a sensible range would do little to resolve this.

Of course no realistic system would have any use for mapping all possible

virtual memory addresses at once, so we need some means of denoting that some of the virtual address space is not mapped. Given that the majority of virtual address space will remain unmapped at all times, the solution is to use a sparse mapping—that is, mapping only what we need in such a way as to eliminate as much metadata as possible for empty mappings.

We need to store metadata in memory, and since the smallest unit of

memory that can be allocated is a single base page, the most efficient means of obtaining a sparse mapping is to subdivide each virtual address into a page’s worth of possible mappings at a time. We denote each of these map-ping tables page tables.

Page tables are arranged in a hierarchy of page table levels; for a page

to exist at a lower level in the hierarchy, at least one entry has to exist at a higher level pointing to it. This means we only ever allocate metadata if we have at least one mapping in it and minimize wasted space on nil mappings.

The page table hierarchy begins with a global page table that’s always

accessible to a given process, called the page global directory (PGD). The PGD provides physical addresses for page tables at the next level of granularity, which provides physical addresses for the next lower page table level, and so on, until finally we provide the physical address of the mapped data.

How do we map a virtual address to entries in page tables? We treat the

address as a series of adjacent indices into each page table level and finally into the page itself.

For clarity, let’s examine concrete examples. We’ll consider page table

semantics for x86-64 here, but the concepts remain the same for other archi-tectures. With a page size of 4KiB and 8 bytes per address, this means the minimum number of mappings we can set is 512 pages at a time (2MiB of address space).

Since 512 = 2 9 12 and 4,096 = 2, we require 12 bits for the data page offset

that the virtual address points at and 9 bits for each page table level. Modern x86-64 hardware can support up to 57 bits of physical memory. Since virtu-ally addressing memory that cannot exist physically is pointless, this implies that only the lower 57 bits of a virtual memory address are meaningful, and thus we require up to five page table levels to map virtual memory.



**N O T E** In x84-64, virtual addresses must be of canonical form, which means that all upper

bits must be equal to the highest permissible bit. For example, if bit-56 is 0, then bits 57 through 63 must be 0 also. If it is 1, they must also be 1.



It turns out five-level x86-64 virtual addresses are the maximum any ar-

chitecture supports. Most consumer x86-64 systems support only 48 bits







(four levels), and other architectures or configurations might support sig-

nificantly less. The kernel deals with this by defining five page table levels

and cleverly using macros to ignore levels that don’t exist (folding them into

the level above).

Table 3-1 shows the page tables within the kernel (note that type declara-

tions are architecture-specific).



Table 3-1: Page Table Levels

Level Entry type Count Bit offset Description

PGD [pgd_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n265) [PTRS_PER_PGD](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n56) [PGDIR_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n55) Page global directory

P4D [p4d_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n312) [PTRS_PER_P4D](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n62) [P4D_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n61) Page fourth-level directory

PUD [pud_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n338) [PTRS_PER_PUD](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n84) [PUD_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n83) Page upper directory

PMD [pmd_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n364) [PTRS_PER_PMD](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n91) [PMD_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n90) Page middle directory

PTE [pte_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n21) [PTRS_PER_PTE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n96) [PAGE_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_types.h?h=v6.0#n10) Page table entry directory



Each of these entry types defines an individual entry in these tables that

contains the physical address of a page table of the next level in the hierar-

chy (or in the case of a PTE, the address of the data page containing the data

referenced by the virtual address), so PGDs contain physical addresses of

P4Ds, P4Ds contain physical addresses of PUDs, and so on.

As a form of rudimentary type safety, these are implemented as bare

structs wrapping their underlying values. The kernel defines the underly-

ing fundamental data types in, for x86-64, 64-bit specific wrappers shown in

Listing 3-1.



14 **typedef unsigned long** pteval_t;

15 **typedef unsigned long** pmdval_t;

16 **typedef unsigned long** pudval_t;

17 **typedef unsigned long** p4dval_t;

18 **typedef unsigned long** pgdval_t;

. . .

21 **typedef struct** { pteval_t pte; } **pte_t**;



*Listing 3-1:* arch/x86/include/asm/pgtable_64_types.h:

[*page table entry value types*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n14)



These value types are then wrapped by the actual page table type wrap-

pers shown in Listing 3-2.



265 **typedef struct** { pgdval_t pgd; } **pgd_t**;

. . .

312 **typedef struct** { p4dval_t p4d; } **p4d_t**;

. . .

338 **typedef struct** { pudval_t pud; } **pud_t**;

. . .

364 **typedef struct** { pmdval_t pmd; } **pmd_t**;



*Listing 3-2:* arch/x86/include/asm/pgtable_types.h: [*page table entry types*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n265)







Declaring these this way means the compiler checks to ensure that a PGD

entry is never supplanted for a P4D, a P4D for a PUD, and so on.



***3.1.1 Page Table Operations***

There are myriad, mostly architecture-specific, helper functions for page table operations. We’ll examine these briefly to provide an idea of the scope of kernel operations.

First, we’ll consider the page table flags specific to the PGD and P4D

page table levels shown in Table 3-2. As these levels don’t map pages directly and normally don’t have their flags altered, fewer operations are defined for them.



Table 3-2: Page Table Helper Functions: PGD and P4D

PGD P4D

Get raw value [pgd_val()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n99) [p4d_val()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n103)

Cast raw value [\_\_pgd()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n100) [\_\_p4d()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n104)

Get index [pgd_index()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n86) [p4d_index()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n900)

Get next level [*†* pgd_offset()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n133) [p4d_offset()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n925)

Get flags [pgd_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n306) [p4d_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n400)

Get PFN [pgd_pfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n212) [p4d_pfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n207)

Get page table [**struct page**](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) [pgd_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n922) [p4d_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n887)

Get next entry address [pgd_addr_end()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n793) [p4d_addr_end()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n799)

Get fine-grained lock (split)- -

Get fine-grained lock (shared)- -

Acquire fine-graned lock- -

In bad state? [pgd_bad()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n932) [p4d_bad()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n889)

Is empty? [pgd_none()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n945) [p4d_none()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n868)

Are the same? [pgd_same()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n663) [p4d_same()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n656)

From PFN/flags- -

From [struct page/flags](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72)- -

From entry/flags- -

Set flags- -

Clear flags- -

Set entry [set_pgd()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n76) [set_p4d()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n81)

Set entry with check- -

Clear [pgd_clear()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n77) [p4d_clear()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n85)

Get or allocate next level [pgd_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgtable.c?h=v6.0#n424) [p4d_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2195)

Get/allocate w/tracking- [p4d_alloc_track()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/pgalloc-track.h?h=v6.0#n6)

Allocate- [\_\_p4d_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5182)

Free [pgd_free()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgtable.c?h=v6.0#n471) [p4d_free()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgalloc.h?h=v6.0#n159)

Set from [**struct page**](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) [pgd_populate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgalloc.h?h=v6.0#n134) [p4d_populate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgalloc.h?h=v6.0#n113)



We then examine page table helper functions for the PUD, PMD, and

PTE page table levels in Table 3-3. Key: *⋆* – The PTE lock is applied at the same time as obtaining the PTE entry via

[pte_offset_map_lock() .](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2302)

*⋆⋆* – For kernel allocations, retrieving or allocationg a PTE can be performed

via [pte_alloc_kernel_track()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/pgalloc-track.h?h=v6.0#n46)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/pgalloc-track.h?h=v6.0#n46)

*†* – We can also use [pgd_offset_k()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n141) for kernel mappings.







Table 3-3: Page Table Helper Functions: PUD, PMD, PTE

PUD PMD PTE

Get raw value [pud_val()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n108) [pmd_val()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n113) [pte_val()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n117)

Cast raw value [\_\_pud()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n109) [\_\_pmd()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n114) [\_\_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n118)

Get index [pud_index()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n77) [pmd_index()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n69) [pte_index()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n62)

Get next level [pud_offset()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n117) [pmd_offset()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n109) [pte_offset_map()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n103)

Get flags [pud_pgprot()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n647) [pmd_pgprot()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n646) [pte_pgprot()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n645)

Get PFN [pud_pfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n200) [pmd_pfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n193) [pte_pfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n186)

Get page table [**struct page**](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) [pud_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n846) [pmd_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n805) [pte_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n224)

Get next entry address [pud_addr_end()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n806) [pmd_addr_end()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n813) -

Get fine-grained lock (split)- [pmd_lockptr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2337) [pte_lockptr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2246)

Get fine-grained lock (shared) [pud_lockptr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2403) [pmd_lockptr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2362) [pte_lockptr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2271)

Acquire fine-graned lock [pud_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2408) [pmd_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2374) *⋆*

In bad state? [pud_bad()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n855) [pmd_bad()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n816) -

Is empty? [pud_none()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n827) [pmd_none()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n788) [pte_none()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n723)

Are the same? [pud_same()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n649) [pmd_same()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n644) [pte_same()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n729)

From PFN/flags [pfn_pud()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n593) [pfn_pmd()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n585) [pfn_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n577)

From [struct page/flags](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72)- [mk_pmd()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1084) [mk_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n814)

From entry/flags- [pmd_modify()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n623) [pte_modify()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n609)

Set flags [pud_set_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n444) [pmd_set_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n373) [pte_set_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n277)

Clear flags [pud_clear_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n451) [pmd_clear_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n380) [pte_clear_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n284)

Set entry [set_pud()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n89) [set_pmd()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n73) [set_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n68)

Set entry with check [set_pud_at()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1018) [set_pmd_at()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1011) [set_pte_at()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1004)

Clear [pud_clear()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n93) [pmd_clear()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n97) [pte_clear()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n96)

Get or allocate next level [pud_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2202) [pmd_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2209) [pte_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2316)

Get/allocate w/tracking [pud_alloc_track()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/pgalloc-track.h?h=v6.0#n19) [pmd_alloc_track()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/pgalloc-track.h?h=v6.0#n32) *⋆⋆*

Allocate [\_\_pud_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5205) [\_\_pmd_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5228) [\_\_pte_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n466)

Free [pud_free()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/pgalloc.h?h=v6.0#n182) [pmd_free()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/pgalloc.h?h=v6.0#n138) [pte_free()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/pgalloc.h?h=v6.0#n99)

Set from [**struct page**](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) [pud_populate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgtable.c?h=v6.0#n188) [pmd_populate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgalloc.h?h=v6.0#n78) -



These helper functions are used through the memory manager for page

table allocation, initialisation, modification, clean up, and freeing among

many other tasks.

x86-64 pages can be set to three different sizes: 4KiB, 2MiB, and 1GiB.

The kernel exposes the ability to change naturally aligned mappings of

4KiB pages to mappings at the larger pages sizes. These mappings are then

termed huge pages.This is done for cache efficiency.

At the time of writing, most commercially available x86-64 hardware

doesn’t support five page table levels. The concept of a P4D page table level

still exists, only it is “folded” into the page table above and assigned size of

zero, so in effect, it’s ignored and the compiler eliminates any redundant

code.

Additionally, x86-64 implements huge pages in rather a straightforward

fashion, simply dropping a page table and setting the appropriate page flag.

Two huge page sizes are available: 2 MiB and 1 GiB.

We start by examining the layout of a five-level, 4 KiB page size configu-

ration in Figure 3-1.





[PGDIR_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n55) [P4D_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n61) [PUD_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n83) [PMD_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n90) [PAGE_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_types.h?h=v6.0#n10)

PGD P4D PUD PMD PTE offset

Virtual address: 1111111 110101110 011100110 011000111 011110101 011011011 111011101111



mm-\>pgd

PGD P4D PUD PMD PTE



Physical address: 000000000000 0000000000000000000010111000111010010010 111011101111



[MAX_PHYSMEM_BITS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/sparsemem.h?h=v6.0#n27)



*Figure 3-1: x86-64 five-level page table layout, 4 KiB pages*



Note that the PGD’s address is determined using the process’s

[struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) object, via the pgd field (we examine this data type in consid-

erable detail in Chapter 4). For x86-64, the high bits must be equal to the up-per most meaningful bit to be valid (termed “canonical form”). Additionally,

there are maximum [MAX_PHYSMEM_BITS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/sparsemem.h?h=v6.0#n27) available in physical memory, which for 5-level is 52 bits or 4 PiB of memory.

We can remove the PTE page table level to obtain 2 MiB huge page sizes,

as shown in Figure 3-2.





[PGDIR_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n55) [P4D_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n61) [PUD_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n83) [PMD_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n90)

PGD P4D PUD PMD offset

Virtual address: 1111111 110101110 011100110 011000111 011110101 011011011111011101111



mm-\>pgd

PGD P4D PUD PMD



Physical address: 000000000000 0000000000000000000010111000111 011011011111011101111



[MAX_PHYSMEM_BITS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/sparsemem.h?h=v6.0#n27)



*Figure 3-2: x86-64 5-level page table layout, 2 MiB huge pages*



As you can see, the data page offset simply extended to consume the

next page table level and a page table level is dropped. We can do this again

to obtain 5-level x86-64 1 GiB huge page tables, as shown in Figure 3-3.





[PGDIR_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n55) [P4D_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n61) [PUD_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n83)

PGD P4D PUD offset

Virtual address: 1111111 110101110 011100110 011000111 011110101011011011111011101111



mm-\>pgd

PGD P4D PUD



Physical address: 000000000000 0000000000000000000010 011110101011011011111011101111



[MAX_PHYSMEM_BITS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/sparsemem.h?h=v6.0#n27)



*Figure 3-3: x86-64 five-level page table layout, 1 GiB huge pages*



Again we drop a page table level and expand the data page offset to ac-

commodate the difference.

The four-level page table configuration is very similar, only with the P4D

level elided. Figure 3-4 shows the 4KiB page case.





[PGDIR_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n74) [PUD_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n83) [PMD_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n90) [PAGE_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_types.h?h=v6.0#n10)

PGD offset PUD PMD PTE

Virtual address: 1111111111111111 110101110 011000111 011110101 011011011 111011101111



mm-\>pgd

PGD PUD PMD PTE



Physical address: 000000000000000000 0000000000000010111000111010010010 111011101111



[MAX_PHYSMEM_BITS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/sparsemem.h?h=v6.0#n27)



*Figure 3-4: x86-64 4-level page table layout, 4 KiB pages*



We drop the P4D page table level, but also note that [MAX_PHYSMEM_BITS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/sparsemem.h?h=v6.0#n27) goes

to 46 bits from 52, and [PGDIR_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n74) drops to a 39-bit offset to accommodate

the reduction in address space. As before, all higher bits outside of the vir-

tual address range must be set to the same value as the most significant valid

bit for the virtual address to be canonical.

As with five-level page tables, we can achieve 2 MiB and 1 GiB huge page

tables by dropping the lowest page table levels. Figure 3-5 shows the the 4-

level 2 MiB huge page case.





[PGDIR_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n74) [PUD_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n83) [PMD_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n90)

PGD PUD PMD offset

Virtual address: 1111111111111111 110101110 011000111 011110101 011011011111011101111



mm-\>pgd

PGD PUD PMD



Physical address: 000000000000000000 0000000000000010111000111 011011011111011101111



[MAX_PHYSMEM_BITS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/sparsemem.h?h=v6.0#n27)



*Figure 3-5: x86-64 four-level page table layout, 2MiB huge pages*



Finally, similar to the five-level case, we can obtain 2GiB huge pages by

also dropping the PMD level, as shown in Figure 3-6.





[PGDIR_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n74) [PUD_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n83)

PGD PUD offset

Virtual address: 1111111111111111 110101110 011000111 011110101011011011111011101111



mm-\>pgd

PGD PUD



Physical address: 000000000000000000 0000000000000010 011110101011011011111011101111



[MAX_PHYSMEM_BITS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/sparsemem.h?h=v6.0#n27)



*Figure 3-6: x86-64 four-level page table layout, 1GiB huge pages*



***3.1.2 Page Table Flags***

Since page tables must be aligned to the page size, this leaves lower bits of

page table entries clear (12 lower bits in the case of x86-64 at a 4KiB page

size), and since physical page address size is limited (57 bits in five-level, 48

bits in four-level), we have additional redundancy at the higher bits of the

entries. As a result, we (and the hardware) can mask these bits when looking

up physical addresses and free them up to be able to store page table flags

that describe attributes of the mapping (for example, read-only/read-write,

executable, kernel/user, and so on).

Page table flags are represented by the [pgprot_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n263) type, which, like the page

table entry types previously described, is a C struct wrapping a [pgprotval_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n19) (a

typedef of an unsigned 64-bit integer). Raw values are converted to this type

via [\_\_pgprot()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n177) or [\_\_pg()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n178)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n178) and the raw value is extracted via [pgprot_val()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n176)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n176)

Page flags vary by architecture. As mentioned previously, we’ll focus on

x86-64, but the concepts remain similar for all architectures, so it’s not a ma-

jor task to adapt these to whatever architecture you are using.







Figure 3-7 shows how page table flags are extracted from page table en-

tries.



101100 001001000001010110110101101100001001000001010 1101101011010

[\_PAGE_PRESENT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n41)

[\_PAGE_RW](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n42)

[\_PAGE_USER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n43)

[\_PAGE_PWT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n44)

[\_PAGE_PCD](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n45)

[\_PAGE_ACCESSED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n46)

[\_PAGE_DIRTY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n47)

[\_PAGE_PSE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n48)

[\_PAGE_PAT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n53)

[\_PAGE_GLOBAL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n49)

[\_PAGE_SOFTW1](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n50)

[\_PAGE_SOFTW2](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n51)

[\_PAGE_SOFTW3](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n52)

[\_PAGE_PAT_LARGE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n54)

[\_PAGE_SOFTW4](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n113)

[\_PAGE_PKEY_BIT0](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n58)

[\_PAGE_PKEY_BIT1](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n59)

[\_PAGE_PKEY_BIT2](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n60)

[\_PAGE_PKEY_BIT3](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n61)

[\_PAGE_NX](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n111)



*Figure 3-7: x86-64 page table flags*



Table 3-4 shows which page tables each of these flags relate to.



Table 3-4: x86-64 page table flags

Flag Bit Description PGD P4D PUD PMD PTE

[\_PAGE_PRESENT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n41) 0 Is the page mapped? *•* *•* *•* *•* *•*

[\_PAGE_RW](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n42) 1 Page writable if set *•* *•* *•* *•* *•*

[\_PAGE_USER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n43) 2 Unprivileged user page *•* *•* *•* *•* *•*

[\_PAGE_PWT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n44) 3 Write-through cache *•* *•* *•* *•* *•*

[\_PAGE_PCD](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n45) 4 Cache disabled *•* *•* *•* *•* *•*

[\_PAGE_ACCESSED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n46) 5 Has page been accessed? *•* *•* *•* *•* *•*

[\_PAGE_DIRTY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n47) 6 Has page been written to? 1GiB 2 MiB *•*

[\_PAGE_PSE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n48) 7 Is this a huge page? 1GiB 2MiB

[\_PAGE_PAT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n53) 7 Page Attribute Table applies *×* *×* *•*

[\_PAGE_GLOBAL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n49) 8 Mapping survives context switch 1GiB 2MiB *•*

[\_PAGE_SOFTW1](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n50) 9 Software-defined *•* *•* *•* *•* *•*

[\_PAGE_SOFTW2](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n51) 10 Software-defined *•* *•* *•* *•* *•*

[\_PAGE_SOFTW3](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n52) 11 Software-defined *•* *•* *•* *•* *•*

[\_PAGE_PAT_LARGE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n54) 12 PAT flag for huge pages 1GiB 2MiB

[\_PAGE_SOFTW4](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n113) 58 Software-defined *•* *•* *•* *•* *•*

[\_PAGE_PKEY_BIT0](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n58) 59 Protection key 1GiB 2MiB *•*

[\_PAGE_PKEY_BIT1](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n59) 60 Protection key 1GiB 2MiB *•*

[\_PAGE_PKEY_BIT2](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n60) 61 Protection key 1GiB 2MiB *•*

[\_PAGE_PKEY_BIT3](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n61) 62 Protection key 1GiB 2MiB *•*

[\_PAGE_NX](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n111) 63 Non-executable *•* *•* *•* *•* *•*







Note that, while the hardware might support these flags (in this instance

x86-64), the kernel may not explicitly expose nor use these at every page ta-

ble level.

In addition a number of flags overload others for specific purposes

(mostly the software-defined flags), as shown in Table 3-5.



Table 3-5: x86-64 Overloaded Page Table Flags

Flag Overloads Bit Description

[\_PAGE_PROTNONE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n120) \_PAGE_GLOBAL 8 PROT_NONE mapped page

[\_PAGE_SPECIAL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n55) \_PAGE_SOFTW1 9 Has no [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72)

[\_PAGE_CPA_TEST](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n56) \_PAGE_SOFTW1 9 PAT test flag

[\_PAGE_UFFD_WP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n103) \_PAGE_SOFTW2 10 [*userfaultfd*](https://kernel.org/doc/html/v6.0/admin-guide/mm/userfaultfd.html) managed page

[\_PAGE_SOFT_DIRTY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n81) \_PAGE_SOFTW3 11 Software-defined dirty flag

[\_PAGE_DEVMAP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n112) \_PAGE_SOFTW4 58 ZONE_DEVICE page



The following list describes each flag:



**\_PAGE_PRESENT** Indicates that the page directory/data page referred to is ac-

tually resident in memory. If this flag is not set, any attempt to access memory at an address described by this entry will fault.

Checked by [pte_present()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n734) (also returns true if \_PAGE_PROTNONE is set, see

description later in this list), [pmd_present()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n759) (also returns true if either \_PAGE_PROTNONE or \_PAGE_PSE are set—the latter to avoid an edge-case race

condition), [pud_present()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n832)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n832) [p4d_present()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n873) and [pgd_present()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n906)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n906)

**\_PAGE_RW** Indicates that a page can be written to as well as read from. If this

flag is clear, attempts to write to the page will fault.

Checked by [pte_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n157), [pmd_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1106)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1106) and [pud_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1141)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1141) Set by [pte_mkwrite()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n338)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n338)

[pmd_mkwrite(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n439)and [pud_mkwrite()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n493). Cleared by [pte_wrprotect()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n318),

[pmd_wrprotect()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n414), and [pud_wrprotect()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n468)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n468)

**\_PAGE_USER** If set, indicates that this memory is accessible when the CPU is

set to ring 3 privilege level (that is, user mode). If this flag is cleared and access to the memory is attempted from user mode, a fault will be raised.

No helper methods for x86-64 check this flag directly, but, in addition to checking \_PAGE_PRESENT and, if appropriate, \_PAGE_RW, it is checked by

[pte_access_permitted(),](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1409) [pmd_access_permitted()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1415), and [pud_access_permitted()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1421).

**\_PAGE_PWT** Indicates that memory accesses should be write-through, that is,

writes should not be cached but immediately written back to the physical bus. Typically used for memory-mapped devices where writes must not be cached.

**\_PAGE_PCD** Indicates that cache should be disabled when reading from this

page. Again this is typically used for memory-mapped devices, for exam-ple, registers which must be read from without delay. Can be combined with \_\_PAGE_PWT when no caching whatsoever can be permitted.

**\_PAGE_ACCESSED** A “sticky” flag, set but never cleared by hardware when the

page is read from (this is what makes it sticky). The kernel can clear it,







which means it can be used to determine if a page is in active use or not (an important trick!)

This flag is checked via [pte_young()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n132), [pmd_young()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n142)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n142) and [pud_young()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n152)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n152) Set by

[pte_mkyoung(),](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n333) [pmd_mkyoung()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n434)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n434) and [pud_mkyoung()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n488)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n488) Cleared by [pte_mkold()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n313)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n313)

[pmd_mkold()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n404), and [pud_mkold()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n458)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n458) The “young” and “old” refer to the age of the mapping in the sense that newer “younger” pages are likely to be regularly accessed, whereas older pages are not. More on how this flag is used in the chapter on reclaim.

**\_PAGE_DIRTY** Another ‘sticky’ flag, set but never cleared by hardware when the

page is written to. Again, the kernel can clear it, which can be used in order to determine when to flush memory-mapped pages to disk.

Checked by [pte_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n127), [pmd_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n137)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n137) and [pud_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n147)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n147) Set by

[pte_mkdirty(),](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n328) [pmd_mkdirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n419)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n419) and [pud_mkdirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n473) (note that these also set

the \_PAGE_SOFT_DIRTY flag described later). Cleared by [pte_mkclean()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n308)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n308)

[pmd_mkclean(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n409)and [pud_mkclean()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n463).

**\_PAGE_PSE** Determines whether a PMD points at a 2MiB data huge page rather

than a PTE, or whether a PUD points at a 1GiB data huge page rather than a PMD. If this is set, the hardware will stop decoding page tables at this level and use the appropriately aligned data page contained within the entry to determine the resultant data page.

Checked by [pte_huge()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n162)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n162) [pmd_large()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n227), and [pud_large()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n849), set by [pte_mkhuge()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n343)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n343)

[pmd_mkhuge()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n429), and [pud_mkhuge()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n483) and cleared by [pte_clrhuge()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n348). Note that the functions which reference PTE here will be using cast PMD/PUD entries as PTE entries cannot be marked huge.

**\_PAGE_PAT/\_PAGE_PAT_LARGE** Indicates that this page has a Page Attribute Ta-

ble (PAT) associated with it (the \_PAGE_PAT_LARGE variant is for huge page sizes). Discussion of this topic is out of scope for this book.

**\_PAGE_GLOBAL** If set, then context switching does not result in this address’s

Translation Lookaside Buffer (TLB), a cache of virtual address to physi-cal, discussed in more detail later) being cleared. Useful for kernel map-pings that should remain mapped regardless of which process is run-ning. This needs to be treated with care given concerns around melt-down/spectre vulnerabilities, however.

Checked by [pte_global()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n167), set by [pte_mkglobal()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n353)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n353) and cleared by

[pte_clrglobal()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n358).

**\_PAGE_SOFTW\[1-4\]** These flags are explicitly software-only and overloaded for

various other flags described next.

**\_PAGE_PKEY_BIT\[0-3\]** These flags implement Intel memory protection keys, a

topic which is out of scope for this book.

**\_PAGE_NX** If set, code cannot be executed in this page. This is a vital security

tool as it prevents exploit code from being able to execute arbitrary code in regions of memory used for storing data such as stack or heap alloca-tions. This flag should only be cleared for explicit code mappings (and those pages should be marked read-only).

Checked by [pte_exec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n172) and set by [pte_mkexec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n323)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n323)







**\_PAGE_PROTNONE** Overloads \_PAGE_GLOBAL, and is only set if \_PAGE_PRESENT is not

set. Indicates that the page is mapped but is intended to always result in page faults should it be accessed. Useful for guard pages placed after regions of memory that risk buffer overruns where it is desired that a

segfault should be raised when this occurs. Set by [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) as a PROT_NONE parameter.

Checked by [pte_protnone()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n775) and [pmd_protnone()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n781). Both assert that the

\_PAGE_PRESENT flag is not set. [pte_present()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n734) and [pmd_present()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n759) assert that either the \_PAGE_PRESENT or \_PAGE_PROTNONE flags are set. Note that the physical address encoded in the entry on modification via

[pte_modify()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n609) or [pmd_modify()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n623) is inverted each time \_PAGE_PROTNONE is either set or cleared. This is to prevent unwanted speculative memory reads for memory that is intended not to be read.

**\_PAGE_SPECIAL** Overloads \_PAGE_SOFTW1. This indicates that the mapping

should not be associated with a [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) ; either it is device memory or the mapping is not intended to interact with physical page tracking.

Checked by [pte_special()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n177) and set by [pte_mkspecial()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n363)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n363)

**\_PAGE_CPA_TEST** Overloads \_PAGE_SOFTW1. A flag used by PAT for self-test, out of

scope for this book.

**\_PAGE_UFFD_WP** Overloads \_PAGE_SOFTW2. Used to indicate a [userfaultfd](https://kernel.org/doc/html/v6.0/admin-guide/mm/userfaultfd.html) managed

page, out of scope for this book.

**\_PAGE_SOFT_DIRTY** Overloads \_PAGE_SOFTW3. [Soft-dirty PTEs](https://kernel.org/doc/html/v6.0/admin-guide/mm/soft-dirty.html) are an added layer

of dirty page tracking which can be used by userland to keep track of pages which have been written to by a process since an arbitrary point in time. A user can clear these flags for all pages used by a process by writ-ing to /proc/\$pid/clear_refs, then read back the page table flags using

/proc/\$pid/pagemap . The clearing logic is performed by [clear_soft_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n1090).

Checked by [pte_soft_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n499)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n499) [pmd_soft_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n504), and [pud_soft_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n509)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n509)

Set by [pte_mksoft_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n514), [pmd_mksoft_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n519), and [pud_mksoft_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n524)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n524)

Cleared by [pte_clear_soft_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n529), [pmd_clear_soft_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n534)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n534) and

[pud_clear_soft_dirty().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n539)

**\_PAGE_DEVMAP** Overloads \_PAGE_SOFTW4 – Used to indicate a ZONE_DEVICE page,

out of scope for this book.



***3.1.3 Page Flag Combinations***

A number of useful page table flag combinations are defined for specific

purposes such as setting flags for user and kernel pages (excluding out of

scope encrypted memory flags), as shown in Table 3-6.







Table 3-6: x86-64 Page Flag Combinations

Flag \_\_PP \_\_RW \_USR \_\_\_A \_\_NX \_\_\_D \_PSE \_\_\_G \_\_WP \_\_NC

[\_\_PAGE_KERNEL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n189) *•* *•* *•* *•* *•* *•*

[\_\_PAGE_KERNEL_IO](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n204) *•* *•* *•* *•* *•* *•*

[\_\_PAGE_KERNEL_EXEC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n190) *•* *•* *•* *•* *•*

[\_\_PAGE_KERNEL_RO](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n195) *•* *•* *•* *•* *•*

[\_\_PAGE_KERNEL_ROX](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n196) *•* *•* *•* *•*

[\_\_PAGE_KERNEL_VVAR](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n198) *•* *•* *•* *•* *•* *•*

[\_\_PAGE_KERNEL_LARGE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n199) *•* *•* *•* *•* *•* *•* *•*

[\_\_PAGE_KERNEL_LARGE_EXEC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n200) *•* *•* *•* *•* *•* *•*

[\_\_PAGE_KERNEL_WP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n201) *•* *•* *•* *•* *•* *•* *•*

[\_\_PAGE_KERNEL_NOCACHE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n197) *•* *•* *•* *•* *•* *•* *•*

[\_\_PAGE_KERNEL_IO_NOCACHE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n205) *•* *•* *•* *•* *•* *•* *•*

[\_PAGE_TABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n194) *•* *•* *•* *•* *•*

[\_KERNPG_TABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n192) *•* *•* *•* *•*

[PAGE_NONE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n180) *•* *•*

[PAGE_SHARED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n181) *•* *•* *•* *•* *•*

[PAGE_SHARED_EXEC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n182) *•* *•* *•* *•*

[PAGE_COPY_EXEC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n184) *•* *•* *•*

[PAGE_READONLY_EXEC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n187) *•* *•* *•*

[PAGE_COPY_NOEXEC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n183) *•* *•* *•* *•*

[PAGE_COPY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n185) *•* *•* *•* *•*

[PAGE_READONLY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n186) *•* *•* *•* *•*

[PAGE_KERNEL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n217) *⋆* *•* *•* *•* *•* *•*

[PAGE_KERNEL_RO](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n195) *⋆* *•* *•* *•* *•*

[PAGE_KERNEL_EXEC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n190) *⋆* *•* *•* *•* *•*

[PAGE_KERNEL_ROX](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n196) *⋆* *•* *•* *•*

[PAGE_KERNEL_NOCACHE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n197) *⋆* *•* *•* *•* *•* *•* *•*

[PAGE_KERNEL_LARGE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n199) *⋆* *•* *•* *•* *•* *•* *•*

[PAGE_KERNEL_LARGE_EXEC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n200) *⋆* *•* *•* *•* *•* *•*

[PAGE_KERNEL_VVAR](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n198) *⋆* *•* *•* *•* *•* *•*



Key:



[\_\_PP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n163) is an abbreviation of \_PAGE_PRESENT.

[\_\_RW](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n164) is an abbreviation of \_PAGE_RW.

[\_USR](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n165) is an abbreviation of \_PAGE_USER.

[\_\_\_A](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n166) is an abbreviation of \_PAGE_ACCESSED.

[\_\_NX](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n169) is an abbreviation of \_PAGE_NX.

[\_\_\_D](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n167) is an abbreviation of \_PAGE_DIRTY.

[\_PSE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n174) is an abbreviation of \_PAGE_PSE.

[\_\_\_G](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n168) is an abbreviation of \_PAGE_GLOBAL.







[\_\_WP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n172) is an abbreviation of \_\_PAGE_PWT.

[\_\_NC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n173) is an abbreviation of \_\_PAGE_PWT and \_\_PAGE_PCD.

*⋆* – \_PAGE_GLOBAL is only set if hardware mitigation for the meltdown

vulnerability is available. Otherwise [Page Table Isolation (PTI)](https://kernel.org/doc/html/v6.0/x86/pti.html)

[(X86_FEATURE_PTI) ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/cpufeatures.h?h=v6.0#n205)is enabled and this flag is not set. This flag is set up in

[probe_page_size_mask()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n225) on boot. Note that, while this is a CPU feature flag, it is software-only and does not reflect a hardware mitigation.



Kernel page mappings will use one of the PAGE_KERNEL\_\* flag variants

based on requirements. Page tables are mapped using either \_PAGE_TABLE for

user page tables and \_KERNPG_TABLE for kernel page tables.

Userland page flags are determined by the VM\_ flags (VM_SHRED, VM_READ,

VM_WRITE, and VM_EXEC) and mapped in [vm_get_page_prot()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgprot.c?h=v6.0#n35), as shown in Table

3-7.



Table 3-7: x86-64 VM Flag to Page Flag Mappings

VM_SHARED VM_READ VM_WRITE VM_EXEC Flag

PAGE_NONE

*•* PAGE_NONE

*•* PAGE_READONLY

*•* PAGE_COPY

*•* *•* PAGE_COPY

*•* PAGE_READONLY_EXEC

*•* *•* PAGE_READONLY_EXEC

*•* *•* PAGE_COPY_EXEC

*•* *•* *•* PAGE_COPY_EXEC

*•* PAGE_NONE *•* *•* PAGE_READONLY *•* *•* PAGE_SHARED *•* *•* *•* PAGE_SHARED *•* *•* PAGE_READONLY_EXEC *•* *•* *•* PAGE_READONLY_EXEC *•* *•* *•* PAGE_SHARED_EXEC *•* *•* *•* *•* PAGE_SHARED_EXEC



## Chapter 4 on Process Memory will go into more detail as to how these

VM\_ flags are determined.



***3.1.4 Page Table Traversal***

We will go into detail as to how page table entries are managed in Chapter

6 on Page Faults. However, to get a general idea as to how page tables are

traversed manually, consider [follow_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5269) as shown in Listing 3-3.



5269 **int follow_pte**(**struct** mm_struct \*mm, **unsigned long** address, 5270 **pte_t** \*\*ptepp, **spinlock_t** \*\*ptlp) 5271 {

5272 **pgd_t** \*pgd;

5273 **p4d_t** \*p4d;







5274 **pud_t** \*pud;

5275 **pmd_t** \*pmd;

5276 **pte_t** \*ptep;

5277

5278 pgd = **pgd_offset**(mm, address); 5279 **if** (**pgd_none**(\*pgd) \|\| **unlikely**(**pgd_bad**(\*pgd))) 5280 **goto out**; 5281

5282 p4d = **p4d_offset**(pgd, address); 5283 **if** (**p4d_none**(\*p4d) \|\| **unlikely**(**p4d_bad**(\*p4d))) 5284 **goto out**; 5285

5286 pud = **pud_offset**(p4d, address); 5287 **if** (**pud_none**(\*pud) \|\| **unlikely**(**pud_bad**(\*pud))) 5288 **goto out**; 5289

5290 pmd = **pmd_offset**(pud, address); 5291 **VM_BUG_ON**(**pmd_trans_huge**(\*pmd)); 5292

5293 **if** (**pmd_none**(\*pmd) \|\| **unlikely**(**pmd_bad**(\*pmd))) 5294 **goto out**; 5295

5296 ptep = **pte_offset_map_lock**(mm, pmd, address, ptlp); 5297 **if** (!**pte_present**(\*ptep)) 5298 **goto unlock**; 5299 \*ptepp = ptep;

5300 **return** 0;

5301 **unlock**:

5302 **pte_unmap_unlock**(ptep, \*ptlp); 5303 **out**:

5304 **return**-**EINVAL**;

5305 }



*Listing 3-3:* mm/memory.c: [*follow_pte()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5269)



This uses the address to determine indexes of each page table entry, us-

ing [pgd_offset()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n133) to determine the PGD entry, [p4d_offset()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n925) to determine P4D

entry, [pud_offset()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n117) to determine PUD entry, [pmd_offset()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n109) to determine PMD

entry, and [pte_offset_map_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2302) to obtain the PTE entry while also acquiring a fine-grained PTE spin lock.

Each retrieval entry is checked to ensure it is not empty via pXX_offset()

and is a valid state via pXX_bad().



***3.1.5 Page Table Locking***

When page table entries are modified, a lock must be acquired. There is a

per-process spin lock, [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)-\>page_table_lock, which is used for all page levels other than PMD and PTE.







For example, [\_\_p4d_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5182) allocates a P4D page and installs it in a

PGD entry, acquiring page_table_lock along the way, [\_\_pud_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5205) and

[\_\_pmd_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5228) do the same, installing a PUD in a P4D entry and a PMD in

a PUD entry, respectively. However, [\_\_pte_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n466) does things differently

by calling [pmd_install()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n440) which acquires [pmd_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2374), possibly fine-grained.

Finally, when obtaining a PTE entry for the purposes of modifying it,

[pte_offset_map_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2302) calls [pte_lockptr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2246) to obtain a possibly fine-grained PTE

lock.

Why a possibly fine-grained lock? That’s because the kernel deter-

mines whether to use fine-grained spinlocks for PTEs based on the

[USE_SPLIT_PTE_PTLOCKS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types_task.h?h=v6.0#n22) define and for PMDs via [USE_SPLIT_PMD_PTLOCKS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types_task.h?h=v6.0#n23)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types_task.h?h=v6.0#n23) Fine-

grained locks are stored in the [struct page-\>ptl](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) field (see previous chapter

for more on [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) layout), and are either a pointer to a dynamically al-

located spin lock via [ptlock_ptr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2240), or are an inline spin lock via the identically

named [ptlock_ptr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2222). This is determined by [ALLOC_SPLIT_PTLOCKS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types_task.h?h=v6.0#n25)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types_task.h?h=v6.0#n25) Let’s examine

these defines in Listing 3-4.



22 **\#define USE_SPLIT_PTE_PTLOCKS** (**NR_CPUS** \>= **CONFIG_SPLIT_PTLOCK_CPUS**)

23 **\#define USE_SPLIT_PMD_PTLOCKS** (**USE_SPLIT_PTE_PTLOCKS** && \\

24 **IS_ENABLED**(**CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK**))

25 **\#define ALLOC_SPLIT_PTLOCKS** (**SPINLOCK_SIZE** \> **BITS_PER_LONG**/8)



*Listing 3-4:* include/linux/mm_types_task.h: [*Page table locking defines*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types_task.h?h=v6.0#n22)

The splitting is based on a heuristic where if the system has sufficient

CPUs for potential contention to be enough for the benefit of acquiring

fine-grained locks at PTE (and possibly PMD) levels to exceed the cost of

acquiring/releasing more locks. The number of cores where this comes into

play and whether to do the same for PMDs is configurable.

Whether we allocate these fine-grained locks is based purely on whether

we can fit the spin lock into the single long that struct page-\>ptl occupies, as

determined by ALLOC_SPLIT_PTLOCKS.

See Chapter 4 on Process Memory for some discussion of the nuances of

the use of page_table_lock.



**3.2 The Address Space**

Virtual address space describes all of the virtual addresses that could possi-

bly be used in a system. Since virtual memory is by its nature arbitrary, the

layout of virtual address space is entirely up to the kernel (as is what virtual

addresses are permitted to be used by userland processes).

We must reserve a portion of the address space for the kernel. Given

the vast size of the 64-bit address space, we simply divide the address space

in half with the lower addresses assigned to user space and the higher ad-

dresses assigned to the kernel.

As discussed previously, x86-64 must have all unusable bits of virtual

addresses set to the most-significant valid bit in order to be in canonical

form. Therefore, if the most significant bit is 0, then so are all the remaining

higher bits and equally so if it is 1. Therefore, userland addresses will always







have the most significant bit cleared, and kernel addresses will have the most significant bit set, making it easy to differentiate between the two.

Note that we are constrained in which addresses we can use by this

canonical form. For 4-level page tables this limits us to use of the lowest 48 bits of virtual addresses (covering 256TiB), with 128TiB assigned to the ker-nel; for 5-level the lowest 57 bits (covering 128PiB) with 64PiB assigned to the kernel.

We maintain a portion of the kernel virtual address space for the direct

mapping, which contains all non-device physical addresses mapped into virtual such that the kernel can access physical memory quickly and conve-niently (more on this topic in the next section).

In order for this to fit in the kernel virtual address space the direct map-

ping cannot span all possible physical memory in its entirety (otherwise all of the virtual address space would be taken up just by the direct mapping), nor can it take up half as this would occupy all kernel mappings. The max-imum sensible amount of space for it to occupy is therefore one quarter of the available address space, and this is what is reserved.

This, therefore, also constrains the maximum physical memory which is

limited to [MAX_PHYSMEM_BITS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/sparsemem.h?h=v6.0#n27). For 4-level there are 48 bits of physical memory available; if we take a quarter of this, then we are left with 46 bits (64TiB). For 5-level we are limited by hardware, so while we have reserved 55 bits of 57 for the direct mapping (32PiB), we are in fact currently limited to using 52 bits (4PiB) of physical address space.

Userland address space is always constrained to the first half of avail-

able address space and is entirely dedicated to the current userland pro-

cess. The [kernel space](https://kernel.org/doc/html/v6.0/x86/x86_64/mm.html) (in the upper half of available address space), however, has specific regions mapped. Kernel Address Space Layout Randomisation (KASLR), a security mitigation mechanism (the details of which are out of scope for the book), results in offsets to these regions, but the subdivision remains the same.



**N O T E** Kernel Address Space Layout Randomisation (KASLR) is a technique whereby ker-

nel regions of memory are offset in order to prevent exploits from reliably targeting specific memory.



The exact addresses vary depending on whether the hardware supports

4-level or 5-level page tables. Let’s examine the 5-level case first in Figure 3-8.





0xffffffffffffffff

(hole)

0xffffffffffe00000

8MiB vsyscalls

0xffffffffff600000

1GiB, or 1.5GiB if KASLR Module mapping space

0xffffffffc0000000 = [MODULES_VADDR](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n144)

1GiB, or 512MiB if KASLR Kernel text mapping

0xffffffff80000000 = [\_\_START_KERNEL_map](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_64_types.h?h=v6.0#n50)

(hole)

0xffffffff00000000 = [EFI_VA_START](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n159)

64GiB EFI region mapping space

0xffffffef00000000 = [EFI_VA_END](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n160)

(hole)

0xffffff8000000000

0.5TiB %esp fixup stacks

0xffffff0000000000 = [ESPFIX_BASE_ADDR](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n154)

(hole)

0xfffffe8000000000

0.5TiB cpu_entry_area mapping

0xfffffe0000000000

(hole)

0xfffffc0000000000

8PiB KASAN shadow memory

0xffdf000000000000

(hole)

0xffd6000000000000

0.5PiB Virtual memory map

0xffd4000000000000 = [VMEMMAP_START](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n135)

(hole)

0xffd2000000000000 = [VMALLOC_END + 1](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n142)

12.5PiB vmalloc/ioremap space

0xffa0000000000000 = [VMALLOC_START](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n133)

(hole)

0xff91000000000000

32PiB Direct mapping

0xff11000000000000 = [PAGE_OFFSET](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_types.h?h=v6.0#n36)

0.25PiB LDT remap for PTI

0xff10000000000000

4PiB Hypervisor reserved space Virtual

0xff00000000000000 address



*Figure 3-8: x86-64 5-level kernel virtual address layout*



Next, we examine the 4-level case, which is similar but restricted to 48

bits, shown in Figure 3-9.





0xffffffffffffffff

(hole)

0xffffffffffe00000

8MiB vsyscalls

0xffffffffff600000

1GiB, or 1.5GiB if KASLR Module mapping space

0xffffffffc0000000 = [MODULES_VADDR](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n144)

1GiB, or 512MiB if KASLR Kernel text mapping

0xffffffff80000000 = [\_\_START_KERNEL_map](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_64_types.h?h=v6.0#n50)

(hole)

0xffffffff00000000 = [EFI_VA_START](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n159)

64GiB EFI region mapping space

0xffffffef00000000 = [EFI_VA_END](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n160)

(hole)

0xffffff8000000000

0.5TiB %esp fixup stacks

0xffffff0000000000 = [ESPFIX_BASE_ADDR](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n154)

(hole)

0xfffffe8000000000

0.5TiB cpu_entry_area mapping

0xfffffe0000000000

(hole)

0xfffffc0000000000

16TiB KASAN shadow memory

0xffffec0000000000

(hole)

0xffffeb0000000000

1TiB Virtual memory map

0xffffea0000000000 = [VMEMMAP_START](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n135)

(hole)

0xffffe90000000000 = [VMALLOC_END + 1](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n142)

32TiB vmalloc/ioremap space

0xffffc90000000000 = [VMALLOC_START](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n133)

(hole)

0xffffc88000000000

64TiB Direct mapping

0xffff888000000000 = [PAGE_OFFSET](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_types.h?h=v6.0#n36)

0.5TiB LDT remap for PTI

0xffff880000000000

8TiB Hypervisor reserved space Virtual

0xffff800000000000 address



*Figure 3-9: x86-64 4-level kernel virtual address layout*







**3.3 Direct Mapping**



As we limit maximum physical memory while at the same time possessing a

truly vast 64-bit address space, it becomes feasible for the kernel to simply

map all accessible physical memory into the kernel address space, which it

does in what is known as the direct mapping.

This is hugely convenient as it makes converting between virtual and

physical addresses incredibly simple and obviates the need to manipulate

page table mappings for the vast majority of kernel memory tasks.

We’ll examine the direct mapping but also how direct mappings are

bootstrapped in the early phases of kernel initialisation. We examine this

in such detail not only because it is interesting and important to understand

how we establish it, but also because it gives us insight into the interaction

between virtual and physical memory and how one is mapped to another in

specific detail.

The direct mapping is placed at [PAGE_OFFSET](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_types.h?h=v6.0#n36) which on x86-64 maps to

[\_\_PAGE_OFFSET. ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_64_types.h?h=v6.0#n45)When CONFIG_DYNAMIC_MEMORY_LAYOUT is set this maps to an ex-

ternally defined variable [page_offset_base](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_64.h?h=v6.0#n15), that can vary according to KASLR.

Addresses are translated from physical to virtual via [\_\_va()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page.h?h=v6.0#n59) (the macro

version) or [phys_to_virt()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/io.h?h=v6.0#n150) (an inline function equivalent which simply

invokes \_\_va()). Addresses are converted the other way via [\_\_pa()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page.h?h=v6.0#n42) or

[virt_to_phys()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/io.h?h=v6.0#n131), as shown in Listing 3-5.



42 **\#define \_\_pa**(x) **\_\_phys_addr**((**unsigned long**)(x))

. . .

59 **\#define \_\_va**(x) ((**void** \*)((**unsigned long**)(x)+**PAGE_OFFSET**))



*Listing 3-5:* arch/x86/include/asm/page.h: [*\_\_pa()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page.h?h=v6.0#n42) *and* [*\_\_va()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page.h?h=v6.0#n59)



The translation from physical to virtual is, due to the direct mapping,

simplicity itself—simply offset by PAGE_OFFSET, and you have your answer.

The translation from virtual to physical, however, is more involved. This

function permits the conversion from kernel addresses either from the direct

mapping virtual range or from the kernel text mapping (where the kernel

ELF image is loaded) so must differentiate between the two.

The logic is applied in [\_\_phys_addr_nodebug()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_64.h?h=v6.0#n19)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_64.h?h=v6.0#n19) which starts by subtracting

[\_\_START_KERNEL_map](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_64_types.h?h=v6.0#n50) from the address. This is the start of the kernel virtual

address space which contains the kernel text mapping (without taking into

account KASLR) as shown in Listing 3-6.



19 **static \_\_always_inline unsigned long \_\_phys_addr_nodebug**(**unsigned long** x)

20 {

21 **unsigned long** y = x -**\_\_START_KERNEL_map**;

22

23 */\* use the carry flag to determine if x was \< \_\_START_KERNEL_map \*/*

24 x = y + ((x \> y) ? phys_base : (**\_\_START_KERNEL_map**-**PAGE_OFFSET**));

25

26 **return** x;

27 }







*Listing 3-6:* arch/x86/include/asm/page_64.h: [*\_\_phys_addr_nodebug()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_64.h?h=v6.0#n19)



Since the kernel places the text mapping at a higher address than the di-

rect mapping, this means y is either negative (meaning this is not located within the kernel text mapping) or positive and equal to the offset from \_\_START_KERNEL_map . We then use this to determine the offset into one of the two regions. If the region is the kernel text mapping, then we offset by any

KASLR adjustment set in [phys_base](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_64.h?h=v6.0#n13)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_64.h?h=v6.0#n13)



***3.3.1 Bootstrapping***

In this early stage of x86-64 memory initialisation we find ourselves in some-thing of a chicken-and-egg situation. In order to access page tables, we need to use the direct mapping to look up physical addresses. However, to do that, we need page tables mapped.

To resolve this, the kernel reserves a small area of memory in the kernel

ELF image itself: [early_pgt_alloc](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n187). This is a buffer in which the kernel places the very first page tables allocated for the direct mapping. The PGD is al-

ready specified as part of [init_mm](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/init-mm.c?h=v6.0#n30) as [swapper_pg_dir](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64.h?h=v6.0#n29) (which in turn points at

[init_top_pgt](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/head_64.S?h=v6.0#n599)), so we need only generate page tables below this.

This space has to be sufficient to handle the worst case of huge pages not

being available, which for each aligned 2MiB of physical memory requires a 4KiB page to be allocated for each of the P4D, PUD, PMD, and PTE directo-ries.

early_pgt_alloc reserves a portion of the early kernel ELF image in the

brk section, but in order to access this, it must be requested via [extend_brk()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/setup.c?h=v6.0#n198)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/setup.c?h=v6.0#n198)

This is done by [early_alloc_pgt_buf()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n188), which sets up the pgt_buf contain-

ing these early page tables, with [pgt_buf_start](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n106) set to the start of the buffer,

[pgt_buf_end](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n107) set to the current exclusive end of the used portion of the buffer,

and [pgt_buf_top](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n108) specifying capacity as shown in Listing 3-7.



187 **RESERVE_BRK**(early_pgt_alloc, **INIT_PGT_BUF_SIZE**); 188 **void \_\_init early_alloc_pgt_buf**(**void**) 189 {

190 **unsigned long** tables = **INIT_PGT_BUF_SIZE**; 191 **phys_addr_t** base; 192

193 base = **\_\_pa**(**extend_brk**(tables, **PAGE_SIZE**)); 194

195 pgt_buf_start = base \>\> **PAGE_SHIFT**; 196 pgt_buf_end = pgt_buf_start; 197 pgt_buf_top = pgt_buf_start + (tables \>\> **PAGE_SHIFT**); 198 }



*Listing 3-7:* arch/x86/mm/init.c: [*early_alloc_pgt_buf()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n188)



In x86-64 we absolutely must have access to the ‘ISA’ memory range (that

is, the first megabyte of physical memory) before doing anything else for







architecture-specific reasons, so this reserved space must have sufficient

room for page tables to map this, as well as sufficient space for page tables

to map wherever future page table allocations will go.



***3.3.2 Direct Mapping Initialization***

The number of page tables is determined by [INIT_PGD_PAGE_TABLES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n177)[:](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n177) 3 for 4-

level and 4 for 5-level. The actual number of pages needed to be reserved is

then doubled and set as [INIT_PGD_PAGE_COUNT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n181) to cover the ISA and page table

regions. However, if KASLR is applied (meaning the direct mapping location

in virtual memory is offset by a random amount), we have to take into ac-

count a worse-case scenario where the offset causes these mappings to cross

a PGD entry boundary, meaning we need to allocate twice as many pages. In

that case [INIT_PGD_PAGE_COUNT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n183) is equal to four times the number of page table

levels below PGD rather than double.

The direct mapping is set up during boot in [init_mem_mapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n738) along with

other initialisation tasks. This function uses the early boot memory alloca-

tor memblocks abstraction to determine the physical memory that needs to be

mapped (omitting the 32-bit case and some code not relevant to the discus-

sion), as shown in Listing 3-8.



738 **void \_\_init init_mem_mapping**(**void**) 739 {

740 **unsigned long** end;

741

742 **pti_check_boottime_disable**(); 743 **probe_page_size_mask**(); 744 **setup_pcid**();

. . .

747 end = max_pfn \<\< **PAGE_SHIFT**;

. . .

752 */\* the ISA range is always mapped regardless of memory holes \*/* 753 **init_memory_mapping**(0, **ISA_END_ADDRESS**, **PAGE_KERNEL**);

754

755 */\* Init the trampoline, possibly with KASLR memory offset \*/* 756 **init_trampoline**();

757

758 */\**

759 *\* If the allocation is in bottom-up direction, we setup direct*

*mapping*

760 *\* in bottom-up, otherwise we setup direct mapping in top-down.* 761 *\*/*

762 **if** (**memblock_bottom_up**()) { 763 **unsigned long** kernel_end = **\_\_pa_symbol**(\_end);

764

765 */\**

766 *\* we need two separate calls here. This is because we want to*

767 *\* allocate page tables above the kernel. So we first map*







768 *\* \[kernel_end, end) to make memory above the kernel be mapped*

769 *\* as soon as possible. And then use page tables allocated*

*above*

770 *\* the kernel to map \[ISA_END_ADDRESS, kernel_end).* 771 *\*/*

772 **memory_map_bottom_up**(kernel_end, end); 773 **memory_map_bottom_up**(**ISA_END_ADDRESS**, kernel_end); 774 } **else** {

775 **memory_map_top_down**(**ISA_END_ADDRESS**, end); 776 }

. . .

793 }



*Listing 3-8:* arch/x86/mm/init.c: *Simplified [init_mem_mapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n738)*



The [pti_check_boottime_disable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pti.c?h=v6.0#n78), [setup_pcid()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n263), and [init_trampoline()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n723) func-

tions are all used to mitigate the meltdown vulnerability and are out of scope for this discussion.

However, [probe_page_size_mask()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n225) is relevant. This determines which page

flags can be used via a mask as well as whether 2MiB and 1GiB huge pages

are enabled. Let’s examine this in Listing 3-9, stripping the irrelevant page flag mask code.



225 **static void \_\_init probe_page_size_mask**(**void**) 226 {

227 */\**

228 *\* For pagealloc debugging, identity mapping will use small pages.*

229 *\* This will simplify cpa(), which otherwise needs to support*

*splitting*

230 *\* large pages into small in interrupt context, etc.* 231 *\*/*

232 **if** (**boot_cpu_has**(**X86_FEATURE_PSE**) && !**debug_pagealloc_enabled**()) 233 page_size_mask \|= 1 \<\< **PG_LEVEL_2M**; 234 **else**

235 direct_gbpages = 0; 236

237 */\* Enable PSE if available \*/* 238 **if** (**boot_cpu_has**(**X86_FEATURE_PSE**)) 239 **cr4_set_bits_and_update_boot**(**X86_CR4_PSE**);

. . .

254 */\* Enable 1 GB linear kernel mappings if available: \*/* 255 **if** (direct_gbpages && **boot_cpu_has**(**X86_FEATURE_GBPAGES**)) { 256 printk(**KERN_INFO** "Using GB pages **for** direct mapping\n"); 257 page_size_mask \|= 1 \<\< **PG_LEVEL_1G**; 258 } **else** {

259 direct_gbpages = 0; 260 }

261 }







*Listing 3-9:* arch/x86/mm/init.c: *Simplified [probe_page_size_mask()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n225)*



First, we determine whether 2MiB pages are available by check-

ing both the CPU flag which indicates this ([X86_FEATURE_PSE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/cpufeatures.h?h=v6.0#n32)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/cpufeatures.h?h=v6.0#n32) and the

[debug_pagealloc_enabled()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n3069) function which indicates whether both

CONFIG_DEBUG_PAGEALLOC is set and whether this debug mode is enabled for

early memory initialization. Since any even vaguely modern x86-64 CPU will

support 2MiB huge pages, the debug flag really is the deciding factor as to

whether these huge pages will be available.

Next, if 2MiB pages are available (a prerequisite to having 1GiB huge

pages available as well) and [X86_FEATURE_GBPAGES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/cpufeatures.h?h=v6.0#n67) is set (that is, the CPU sup-

ports 1GiB huge pages—again, any modern x86-64 CPU will), then we enable

this page size.

Note that this function sets global variables [direct_gbpages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n966) and

[page_size_mask](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n210), which are used in the rest of the early direct mapping logic.

We’ll see where these pages are allocated from later. In the meantime,

let’s examine how mappings are performed. We have two choices:



1. Allocate bottom-up using [memory_map_bottom_up()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n677), starting from the end

of the kernel image mapping, determined from the global variable [\_end](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/boot/boot.h?h=v6.0#n171), to the end of available physical memory determined from the global

variable [max_pfn](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memblock.c?h=v6.0#n106)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memblock.c?h=v6.0#n106) then from the end of the ISA mapping, [ISA_END_ADDRESS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/e820/types.h?h=v6.0#n103)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/e820/types.h?h=v6.0#n103) up to the end of the kernel mapping.

2. Allocate top-down using [memory_map_top_down()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n612), starting from the end of

available physical memory to the end of the ISA mapping.



**N O T E** The *max_pfn* global explicitly indicates the end of available physical memory, and sets

the upper bound for the direct mapping. This is determined very early in the boot

process.



The choice of which approach is used is based on where we want page ta-

bles to be allocated. If we allocate bottom-up, they end up immediately af-

ter the kernel image. If top-down, which is the default, then they are allo-

cated as high as possible in memory. Which way we go is determined by

[memblock_bottom_up()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/memblock.h?h=v6.0#n473).



**N O T E** An example of a situation where we would allocate bottom-up is [memory hotplug](https://kernel.org/doc/html/v6.0/admin-guide/mm/memory-hotplug.html) be-

ing enabled and the *movable_node* kernel command line parameter being set. This

marks hot-pluggable memory as being entirely within *ZONE_MOVABLE*. So, in order to

avoid unmovable page table allocations being placed in hotpluggable memory (which

will be physically higher than the kernel image), we would then prefer to allocate

page tables as low as possible. Note that the point at which the kernel image is loaded

is the lowest point above which physical memory is broadly available without over-

lap).



Let’s examine the bottom-up approach performed by

[memory_map_bottom_up()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n677) in Listing 3-10.







677 **static void \_\_init memory_map_bottom_up**(**unsigned long** map_start, 678 **unsigned long** map_end) 679 {

680 **unsigned long** next, start; 681 **unsigned long** mapped_ram_size = 0; 682 */\* step_size need to be small so pgt_buf from BRK could cover it \*/*

683 **unsigned long** step_size = **PMD_SIZE**; 684

685 start = map_start; 686 min_pfn_mapped = start \>\> **PAGE_SHIFT**;

. . .

694 **while** (start \< map_end) { 695 **if** (step_size && map_end - start \> step_size) { 696 next = **round_up**(start + 1, step_size); 697 **if** (next \> map_end) 698 next = map_end; 699 } **else** {

700 next = map_end; 701 }

702

703 mapped_ram_size += **init_range_memory_mapping**(start, next); 704 start = next; 705

706 **if** (mapped_ram_size \>= step_size) 707 step_size = **get_new_step_size**(step_size); 708 }

709 }



*Listing 3-10:* arch/x86/mm/init.c: [*memory_map_bottom_up()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n677)



We initialize direct mappings from map_start to the exclusive bound

map_end . We allocate up to step_size of memory at a time. If our starting point is not aligned to step_size, then we start by allocating a block up to the next physical address aligned to this step size, and allocate step_size blocks up un-til we are a step size away from the end of the mapping (noting that step size can be increased over time!).

We start with a step size equal to [PMD_SIZE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n98)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n98) which is 2MiB. As the com-

ment suggests, this is chosen to ensure the previously described pgt_buf has sufficient space for page table allocation. Since, in the worst case, we can only map a PTE directory’s worth of aligned mappings before running out of space, and noting that we allocate up to the next addressed aligned to the step size, then this should be 2MiB (the amount of address space a PTE di-rectory can map, with 512 4KiB entries).

You can see this logic in place at the beginning of the loop, with each

block of memory allocated by [init_range_memory_mapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n555)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n555) and the next step

size determined by [get_new_step_size()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n583). We’ll come to the actual allocation shortly.







Next, let’s examine how we determine the next step in [get_new_step_size()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n583)

in Listing 3-11.



583 **static unsigned long \_\_init get_new_step_size**(**unsigned long** step_size) 584 {

585 */\**

586 *\* Initial mapped size is PMD_SIZE (2M).* 587 *\* We can not set step_size to be PUD_SIZE (1G) yet.* 588 *\* In worse case, when we cross the 1G boundary, and* 589 *\* PG_LEVEL_2M is not set, we will need 1+1+512 pages (2M + 8k)* 590 *\* to map 1G range with PTE. Hence we use one less than the* 591 *\* difference of page table level shifts.* 592 *\**

593 *\* Don't need to worry about overflow in the top-down case, on 32bit,*

594 *\* when step_size is 0, round_down() returns 0 for start, and that*

595 *\* turns it into 0x100000000ULL.* 596 *\* In the bottom-up case, round_up(x, 0) returns 0 though too, which*

597 *\* needs to be taken into consideration by the code below.* 598 *\*/*

599 **return** step_size \<\< (**PMD_SHIFT**-**PAGE_SHIFT**- 1); 600 }



*Listing 3-11:* arch/x86/mm/init.c: [*get_new_step_size()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n583)



As the comment suggests, in the worst case of allocating 1GiB of address

space with no huge page support where we are a crossing a page boundary,

we will need to allocate 512 PTE pages or 2MiB, in addition to 4KiB for each

higher level page table. The comment is incorrect for 5-level, as in this case

crossing a 512 GiB boundary requires a new P4D, PUD, and PMD, which

amounts to 12KiB of additional space.

Regardless, the solution is to simply divide by 2, requiring half as much

as space as this worst case and ensuring that we have sufficient direct map-

ping to accommodate it.

We examine the opposite direction performed by [memory_map_top_down()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n612) in

Listing 3-12.



612 **static void \_\_init memory_map_top_down**(**unsigned long** map_start, 613 **unsigned long** map_end) 614 {

615 **unsigned long** real_end, last_start; 616 **unsigned long** step_size; 617 **unsigned long** addr; 618 **unsigned long** mapped_ram_size = 0;

619

620 */\**

621 *\* Systems that have many reserved areas near top of the memory,* 622 *\* e.g. QEMU with less than 1G RAM and EFI enabled, or Xen, will* 623 *\* require lots of 4K mappings which may exhaust pgt_buf.* 624 *\* Start with top-most PMD_SIZE range aligned at PMD_SIZE to ensure*







625 *\* there is enough mapped memory that can be allocated from* 626 *\* memblock.*

627 *\*/*

628 addr = **memblock_phys_alloc_range**(**PMD_SIZE**, **PMD_SIZE**, map_start, 629 map_end); 630 **memblock_phys_free**(addr, **PMD_SIZE**); 631 real_end = addr + **PMD_SIZE**; 632

633 */\* step_size need to be small so pgt_buf from BRK could cover it \*/*

634 step_size = **PMD_SIZE**; 635 max_pfn_mapped = 0; */\* will get exact value next \*/* 636 min_pfn_mapped = real_end \>\> **PAGE_SHIFT**; 637 last_start = real_end; 638

639 */\**

640 *\* We start from the top (end of memory) and go to the bottom.* 641 *\* The memblock_find_in_range() gets us a block of RAM from the*

642 *\* end of RAM in \[min_pfn_mapped, max_pfn_mapped) used as new pages*

643 *\* for page table.* 644 *\*/*

645 **while** (last_start \> map_start) { 646 **unsigned long** start; 647

648 **if** (last_start \> step_size) { 649 start = **round_down**(last_start - 1, step_size); 650 **if** (start \< map_start) 651 start = map_start; 652 } **else**

653 start = map_start; 654 mapped_ram_size += **init_range_memory_mapping**(start, 655 last_start); 656 last_start = start; 657 min_pfn_mapped = last_start \>\> **PAGE_SHIFT**; 658 **if** (mapped_ram_size \>= step_size) 659 step_size = **get_new_step_size**(step_size); 660 }

661

662 **if** (real_end \< map_end) 663 **init_range_memory_mapping**(real_end, map_end); 664 }



*Listing 3-12:* arch/x86/mm/init.c: [*memory_map_top_down()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n612)



This is significantly more complicated than [memory_map_bottom_up()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n677),

though it broadly follows the same approach, only working backwards.

First, this function does something quite unusual—it allocates physi-

cal memory from memblock (an early memory allocator, out of scope for

the book), calling [memblock_phys_alloc_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memblock.c?h=v6.0#n1441) for [PMD_SIZE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n98) size and align-







ment, retrieves the allocated physical address and immediately frees it via

[memblock_phys_free()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memblock.c?h=v6.0#n842).

This is done not to actually allocate memory but to obtain the last physi-

cally contiguous block of PMD_SIZE (2MiB) size and alignment. One important

thing to note here is that this, similar to the direct mapping allocation, will

allocate top-down unless [memblock_bottom_up()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/memblock.h?h=v6.0#n473) returns true, but if it returned

true, we would be allocating bottom up, so we can safely make the assump-

tion that this is what we’ll get.

We do this, as the comment suggests, because there might be many re-

served blocks of memory at the high end of physical memory. If this is so,

we may end up trying to allocate a block of memory and only being able to

allocate some small proportion of it, exhausting pgt_buf without sufficient

space to store further page tables. By reserving an aligned 2MiB of space for

page tables, we should have more than enough space.

From here, things proceed as they do with memory_map_bottom_up(), only

in reverse, with one additional step of invoking [init_range_memory_mapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n555)

to map all memory past the memblock allocated range that was previously

skipped.

Now that we have looked at how we determine which ranges of mem-

ory to allocate and in what order, along with how the direct memory map-

ping is bootstrapped, we need to look at how the mapping is actually

performed. This is via init_range_memory_mapping(), which in turn invokes

[init_memory_mapping() .](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n519)

Let’s examine [init_range_memory_mapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n555) in Listing 3-13.



542 */\**

543 *\* We need to iterate through the E820 memory map and create direct mappings*

544 *\* for only E820_TYPE_RAM and E820_KERN_RESERVED regions. We cannot simply*

545 *\* create direct mappings for all pfns from \[0 to max_low_pfn) and* 546 *\* \[4GB to max_pfn) because of possible memory holes in high addresses* 547 *\* that cannot be marked as UC by fixed/variable range MTRRs.* 548 *\* Depending on the alignment of E820 ranges, this may possibly result* 549 *\* in using smaller size (i.e. 4K instead of 2M or 1G) page tables.* 550 *\**

551 *\* init_mem_mapping() calls init_range_memory_mapping() with big range.* 552 *\* That range would have hole in the middle or ends, and only ram parts* 553 *\* will be mapped in init_range_memory_mapping().* 554 *\*/*

555 **static unsigned long \_\_init init_range_memory_mapping**( 556 **unsigned long** r_start, 557 **unsigned long** r_end) 558 {

559 **unsigned long** start_pfn, end_pfn; 560 **unsigned long** mapped_ram_size = 0; 561 **int** i;

562

563 **for_each_mem_pfn_range**(i, **MAX_NUMNODES**, &start_pfn, &end_pfn, **NULL**) { 564 **u64** start = **clamp_val**(**PFN_PHYS**(start_pfn), r_start, r_end);







565 **u64** end = **clamp_val**(**PFN_PHYS**(end_pfn), r_start, r_end); 566 **if** (start \>= end) 567 **continue**; 568

569 */\**

570 *\* if it is overlapping with brk pgt, we need to* 571 *\* alloc pgt buf from memblock instead.* 572 *\*/*

573 can_use_brk_pgt = **max**(start, (**u64**)pgt_buf_end\<\<**PAGE_SHIFT**) \>= 574 **min**(end, (**u64**)pgt_buf_top\<\<**PAGE_SHIFT**); 575 **init_memory_mapping**(start, end, **PAGE_KERNEL**); 576 mapped_ram_size += end - start; 577 can_use_brk_pgt = **true**; 578 }

579

580 **return** mapped_ram_size; 581 }



*Listing 3-13:* arch/x86/mm/init.c: [*init_range_memory_mapping()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n555)



This is the core method for mapping ranges of memory from

r_start to the exclusive bound r_end. The key point here is that, by using

[for_each_mem_pfn_range() , ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/memblock.h?h=v6.0#n283)this function only examines memory that is physi-cally available in the specified range, excluding memory holes.

The start and end ranges of each block are clamped to the input range via

[clamp_val()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/minmax.h?h=v6.0#n137), that is, kept between r_start and r_end. Since this clamps to an inclusive range and also because clamping could cause the start to exceed the end, that the range is still valid is checked immediately afterwards.

The global variable [can_use_brk_pgt](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n112) is set according to whether

this space is exhausted, before the core memory mapping function

[init_memory_mapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n519) is called to perform the mapping itself, as shown in

Listing 3-14.



519 **unsigned long** \_\_ref **init_memory_mapping**(**unsigned long** start, 520 **unsigned long** end, **pgprot_t** prot) 521 {

522 **struct** map_range mr\[**NR_RANGE_MR**\]; 523 **unsigned long** ret = 0; 524 **int** nr_range, i;

525

526 **pr_debug**("**init_memory_mapping**: \[mem %#010lx-%#010lx\]\n", 527 start, end - 1); 528

529 **memset**(mr, 0, **sizeof**(mr)); 530 nr_range = **split_mem_range**(mr, 0, start, end); 531

532 **for** (i = 0; i \< nr_range; i++) 533 ret = **kernel_physical_mapping_init**(mr\[i\].start, mr\[i\].end, 534 mr\[i\].page_size_mask,







535 prot);

536

537 **add_pfn_range_mapped**(start \>\> **PAGE_SHIFT**, ret \>\> **PAGE_SHIFT**);

538

539 **return** ret \>\> **PAGE_SHIFT**; 540 }



*Listing 3-14:* arch/x86/mm/init.c: [*init_memory_mapping()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n519)

This is the fundamental function which performs the mappings. Note

that [init_mem_mapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n738) starts by calling this directly for the ISA memory

range because we know on the x86-64 architecture this whole range should

be accessible.

Since we can map ranges using huge pages when a portion of the range is

aligned to 2MiB or 1GiB, and that the range is not guaranteed to be aligned,

we therefore might have to map at multiple page sizes. Considering the

worst case, we may have to allocate 4KiB, 2MiB, 1GiB, 2MiB, and 4KiB

pages, or five different page sizes, as shown in Figure 3-10.



0x3fdff000 0x80201000



0x3fe00000 0x80200000



start 0x40000000 0x80000000 end



1GiB boundaries

2MiB boundaries

4KiB boundaries



*Figure 3-10: Worst-case direct mapping page size combination*



We store this maximum number of map ranges in [NR_RANGE_MR](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n308)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n308) We keep

track of these memory ranges using the [struct map_range](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n204) data type as shown

in Listing 3-15.



204 **struct** map_range {

205 **unsigned long** start; 206 **unsigned long** end; 207 **unsigned** page_size_mask; 208 };



*Listing 3-15:* arch/x86/mm/init.c: [*struct map_range*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n204)

We maintain NR_RANGE_MR of these objects for every possible page size,

populating these via [split_mem_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n386). These ranges will then be used for

the actual page mapping. This therefore subdivides the input range into up

to five memory ranges, saving each via [save_mr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n311) as shown in Listing 3-16.







311 **static int \_\_meminit save_mr**(**struct** map_range \*mr, **int** nr_range, 312 **unsigned long** start_pfn, **unsigned long** end_pfn, 313 **unsigned long** page_size_mask) 314 {

315 **if** (start_pfn \< end_pfn) { 316 **if** (nr_range \>= **NR_RANGE_MR**) 317 **panic**("run out of range **for** init_memory_mapping\n"); 318 mr\[nr_range\].start = start_pfn\<\<**PAGE_SHIFT**; 319 mr\[nr_range\].end = end_pfn\<\<**PAGE_SHIFT**; 320 mr\[nr_range\].page_size_mask = page_size_mask; 321 nr_range++; 322 }

323

324 **return** nr_range;

325 }



*Listing 3-16:* arch/x86/mm/init.c: [*save_mr()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n311)



The check to determine whether the range is actually valid is performed

here, and the memory range is simply not saved if it is not valid. This means that we can calculate the range of memory up to the next aligned addressed and call save_mr() directly rather than having to check separately each time.

Additionally, range checking is performed, so a programming error

which would otherwise cause a buffer overflow is avoided. The possibly in-cremented nr_range index is returned so the caller can iterate through the array for all valid ranges.

The [split_mem_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n386) function starts by moving through page sizes from

small to large, designated head pages, then large to small, designated tail pages, calling save_mr() for each to save if such a range exists. We will exam-ine the head and tail portions of the function separately, starting with the

head in Listing 3-17.



386 **static int \_\_meminit split_mem_range**(**struct** map_range \*mr, **int** nr_range, 387 **unsigned long** start, 388 **unsigned long** end) 389 {

390 **unsigned long** start_pfn, end_pfn, limit_pfn; 391 **unsigned long** pfn; 392 **int** i;

393

394 limit_pfn = **PFN_DOWN**(end); 395

396 */\* head if not big page alignment ? \*/* 397 pfn = start_pfn = **PFN_DOWN**(start);

. . .

410 end_pfn = **round_up**(pfn, **PFN_DOWN**(**PMD_SIZE**)); 411

412 **if** (end_pfn \> limit_pfn)







413 end_pfn = limit_pfn; 414 **if** (start_pfn \< end_pfn) { 415 nr_range = **save_mr**(mr, nr_range, start_pfn, end_pfn, 0); 416 pfn = end_pfn; 417 }

418

419 */\* big page (2M) range \*/* 420 start_pfn = **round_up**(pfn, **PFN_DOWN**(**PMD_SIZE**));

. . .

424 end_pfn = **round_up**(pfn, **PFN_DOWN**(**PUD_SIZE**)); 425 **if** (end_pfn \> **round_down**(limit_pfn, **PFN_DOWN**(**PMD_SIZE**))) 426 end_pfn = **round_down**(limit_pfn, **PFN_DOWN**(**PMD_SIZE**));

. . .

429 **if** (start_pfn \< end_pfn) { 430 nr_range = **save_mr**(mr, nr_range, start_pfn, end_pfn, 431 page_size_mask & (1\<\<**PG_LEVEL_2M**)); 432 pfn = end_pfn; 433 }

. . .

436 */\* big page (1G) range \*/* 437 start_pfn = **round_up**(pfn, **PFN_DOWN**(**PUD_SIZE**)); 438 end_pfn = **round_down**(limit_pfn, **PFN_DOWN**(**PUD_SIZE**)); 439 **if** (start_pfn \< end_pfn) { 440 nr_range = **save_mr**(mr, nr_range, start_pfn, end_pfn, 441 page_size_mask & 442 ((1\<\<**PG_LEVEL_2M**)\|(1\<\<**PG_LEVEL_1G**))); 443 pfn = end_pfn; 444 }



*Listing 3-17:* arch/x86/mm/init.c: [*split_mem_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n386) *head pages*



Examining the head page logic:



**4KiB head pages** Set pfn to start_pfn, that is, the PFN of the start argument

and end_pfn to the next 2MiB aligned PFN (or the end PFN). If the range is valid, we save it, setting pfn to the beginning of the 2MiB page range.

**2MiB head pages** Set start_pfn to the first 2MiB aligned PFN and end_pfn to

the first 1GiB aligned PFN in the range. If this is invalid then set end_pfn to the last 2MiB aligned PFN instead. If the range is valid, save it and update pfn to end_pfn.

**1GiB head pages** Set start_pfn to the first 1GiB aligned PFN and end_pfn

to last 1GiB aligned PFN of limit_pfn, noting that this is an exclusive bound. This can therefore encompass multiple gigabyte-sized pages. If the range is valid, it is saved and pfn set to end_pfn. Both 2MiB and 1Gib page size flags are set.



Let’s examine the remainder of [split_mem_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n386) in Listing 3-18.



446 */\* tail is not big page (1G) alignment \*/*







447 start_pfn = **round_up**(pfn, **PFN_DOWN**(**PMD_SIZE**)); 448 end_pfn = **round_down**(limit_pfn, **PFN_DOWN**(**PMD_SIZE**)); 449 **if** (start_pfn \< end_pfn) { 450 nr_range = **save_mr**(mr, nr_range, start_pfn, end_pfn, 451 page_size_mask & (1\<\<**PG_LEVEL_2M**)); 452 pfn = end_pfn; 453 }

. . .

456 */\* tail is not big page (2M) alignment \*/* 457 start_pfn = pfn;

458 end_pfn = limit_pfn; 459 nr_range = **save_mr**(mr, nr_range, start_pfn, end_pfn, 0); 460

461 **if** (!after_bootmem) 462 **adjust_range_page_size_mask**(mr, nr_range); 463

464 */\* try to merge same page size and continuous \*/* 465 **for** (i = 0; nr_range \> 1 && i \< nr_range - 1; i++) { 466 **unsigned long** old_start; 467 **if** (mr\[i\].end != mr\[i+1\].start \|\| 468 mr\[i\].page_size_mask != mr\[i+1\].page_size_mask) 469 **continue**; 470 */\* move it \*/* 471 old_start = mr\[i\].start; 472 **memmove**(&mr\[i\], &mr\[i+1\], 473 (nr_range - 1 - i) \* **sizeof**(**struct** map_range)); 474 mr\[i--\].start = old_start; 475 nr_range--; 476 }

477

478 **for** (i = 0; i \< nr_range; i++) 479 pr_debug(" \[mem %#010lx-%#010lx\] page %s\n", 480 mr\[i\].start, mr\[i\].end - 1, 481 page_size_string(&mr\[i\])); 482

483 **return** nr_range;

484 }



*Listing 3-18:* arch/x86/mm/init.c: [*split_mem_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n386) *tail pages and merge*



The tail page logic is as follows:



**2MiB tail pages** We set start_pfn to the next 2MiB aligned page, and end_pfn

to the last 2MiB aligned page and save the range if valid, setting pfn to the end of the range if so.

**4KiB tail pages** We set start_pfn to where we left off previously and end_pfn

to limit_pfn to pick up all remaining pages, saving the range if it is valid.







Note that [PFN_DOWN()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pfn.h?h=v6.0#n20) simply determines the PFN for the input physical ad-

dress, rounding down. [round_up()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/math.h?h=v6.0#n25) rounds up to the next multiple of the spec-

ified power-of-2 argument, that is aligns to it. Equally, [round_down()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/math.h?h=v6.0#n35) rounds

down to the next aligned value.

The technique of invoking round_up() or round_down() aligning to

PFN_DOWN(PMD_SIZE) or PFN_DOWN(PUD_SIZE) causes the value to be aligned to

either 2MiB or 1GiB, rounding up or down. This is a key part of how

[split_mem_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n386) operates, as it is subdividing into aligned blocks of pages

at each possible size.

Also note that each time we invoke [save_mr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n311) we apply the global

[page_size_mask](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n210), so we may actually end up with pages aligned to huge page

sizes but with the page_size_mask field set to a lower page size.

Once we’ve extracted all of the page size-aligned memory ranges,

we need to perform a few more steps. The first step involves invoking

[adjust_range_page_size_mask()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n331), which we’ll examine in Listing 3-19.



**N O T E** The [*adjust_range_page_size_mask()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n331) function is only called if the global flag

[*after_bootmem*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n200) is not set. This flag denotes that the buddy allocator is available and

the early stage memory allocator is no longer being used—however, this is not the case

when the direct mapping is being initialized, which we’re examining, so we can as-

sume not.



331 **static void** \_\_ref **adjust_range_page_size_mask**(**struct** map_range \*mr, 332 **int** nr_range) 333 {

334 **int** i;

335

336 **for** (i = 0; i \< nr_range; i++) { 337 **if** ((page_size_mask & (1\<\<**PG_LEVEL_2M**)) && 338 !(mr\[i\].page_size_mask & (1\<\<**PG_LEVEL_2M**))) { 339 **unsigned long** start = round_down(mr\[i\].start, **PMD_SIZE**

);

340 **unsigned long** end = round_up(mr\[i\].end, **PMD_SIZE**);

. . .

347 **if** (**memblock_is_region_memory**(start, end - start)) 348 mr\[i\].page_size_mask \|= 1\<\<**PG_LEVEL_2M**; 349 }

350 **if** ((page_size_mask & (1\<\<**PG_LEVEL_1G**)) && 351 !(mr\[i\].page_size_mask & (1\<\<**PG_LEVEL_1G**))) { 352 **unsigned long** start = round_down(mr\[i\].start, **PUD_SIZE**

);

353 **unsigned long** end = round_up(mr\[i\].end, **PUD_SIZE**);

354

355 **if** (**memblock_is_region_memory**(start, end - start)) 356 mr\[i\].page_size_mask \|= 1\<\<**PG_LEVEL_1G**; 357 }

358 }







359 }



*Listing 3-19:* arch/x86/mm/init.c: [*adjust_range_page_size_mask()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n331)



This checks each memory range to see if it is contiguous to physical

memory, possibly beyond the input range, which allows us to map it as a larger huge page even if it has not been flagged as such so far. This check

is performed by [memblock_is_region_memory()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memblock.c?h=v6.0#n1827)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memblock.c?h=v6.0#n1827)

If so, then we re-flag it at the appropriate huge page size and assume the

low-level mapping logic will utilize existing huge page mappings if they al-ready exist.

For example, in the case where we adjust a 4KiB page range to 2MiB,

then the next memory range tries to map the portion of the original that has now been remapped to 2MiB will note that a huge page mapping already exists.

Finally, we merge any adjacent memory ranges of the same page size

mask. This can happen when the global page size mask disallows certain page sizes, and head and tail page ranges end up next to each other. For ex-ample, if 1GiB pages are not available, then we might map head 2MiB pages to the first 1GiB aligned PFN and tail 2MiB pages to the last 2MiB aligned PFN.

Going back to [init_memory_mapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n519) in Listing 3-14), once we have split

the memory ranges and set up our struct map_range array, we then need to

create the actual mappings via [kernel_physical_mapping_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n782)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n782) as shown in

Listing 3-20.



781 **unsigned long \_\_meminit**

782 **kernel_physical_mapping_init**(**unsigned long** paddr_start, 783 **unsigned long** paddr_end, 784 **unsigned long** page_size_mask, **pgprot_t** prot) 785 {

786 **return \_\_kernel_physical_mapping_init**(paddr_start, paddr_end, 787 page_size_mask, prot, **true**); 788 }



*Listing 3-20:* arch/x86/mm/init_64.c: [*kernel_physical_mapping_init()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n782)



This simply invokes [\_\_kernel_physical_mapping_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n725) with the init argu-

ment set to true, with this function doing the heavy lifting of the actual map-ping.

Note that all of these kernel mappings utilize the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)

global value [init_mm](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n684) for keeping track of the mappings. We’ll come onto

struct mm_struct in Chapter 4 on Process Memory in considerable detail but for now consider it to be where mapping state is contained.

Next let’s examine [\_\_kernel_physical_mapping_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n725) in Listing 3-21.



724 **static unsigned long \_\_meminit** 725 **\_\_kernel_physical_mapping_init**(**unsigned long** paddr_start, 726 **unsigned long** paddr_end, 727 **unsigned long** page_size_mask,







728 **pgprot_t** prot, **bool** init) 729 {

730 **bool** pgd_changed = **false**; 731 **unsigned long** vaddr, vaddr_start, vaddr_end, vaddr_next, paddr_last;

732

733 paddr_last = paddr_end; 734 vaddr = (**unsigned long**)**\_\_va**(paddr_start); 735 vaddr_end = (**unsigned long**)**\_\_va**(paddr_end); 736 vaddr_start = vaddr;

737

738 **for** (; vaddr \< vaddr_end; vaddr = vaddr_next) { 739 **pgd_t** \*pgd = **pgd_offset_k**(vaddr); 740 **p4d_t** \*p4d;

741

742 vaddr_next = (vaddr & **PGDIR_MASK**) + **PGDIR_SIZE**;

743

744 **if** (**pgd_val**(\*pgd)) { 745 p4d = (**p4d_t** \*)**pgd_page_vaddr**(\*pgd); 746 paddr_last = **phys_p4d_init**(p4d, **\_\_pa**(vaddr), 747 **\_\_pa**(vaddr_end), 748 page_size_mask, 749 prot, init); 750 **continue**; 751 }

752

753 p4d = **alloc_low_page**(); 754 paddr_last = **phys_p4d_init**(p4d, **\_\_pa**(vaddr), **\_\_pa**(vaddr_end), 755 page_size_mask, prot, init);

756

757 **spin_lock**(&**init_mm**.page_table_lock); 758 **if** (**pgtable_l5_enabled**()) 759 **pgd_populate_init**(&**init_mm**, pgd, p4d, init); 760 **else**

761 **p4d_populate_init**(&**init_mm**, **p4d_offset**(pgd, vaddr), 762 (**pud_t** \*) p4d, init);

763

764 **spin_unlock**(&**init_mm**.page_table_lock); 765 pgd_changed = **true**; 766 }

767

768 **if** (pgd_changed)

769 **sync_global_pgds**(vaddr_start, vaddr_end - 1);

770

771 **return** paddr_last; 772 }



*Listing 3-21:* arch/x86/mm/init_64.c: [*\_\_kernel_physical_mapping_init()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n725)







We iterate over the virtual address range of the input physical range that

the direct mapping is intended to provide, incrementing the PGD index on each iteration.

We invoke [pgd_offset_k()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n141) to retrieve the PGD entry containing the ad-

dress of the P4D directory for each virtual address. If this entry is already populated, then instead of allocating, we simply retrieve the virtual address

of this page via [pgd_page_vaddr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n913), and populate it for our address range via

[phys_p4d_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree//arch/x86/mm/init_64.c?h=v6.0#n674).

Otherwise, we allocate a new page via [alloc_low_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/mm_internal.h?h=v6.0#n6)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/mm_internal.h?h=v6.0#n6) initialize as dis-

cussed previously, and assign via [p4d_populate_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n73)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n73) which invokes the \_safe

variant of [p4d_populate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgalloc.h?h=v6.0#n113), [p4d_populate_safe()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgalloc.h?h=v6.0#n119) during memory initialization. This achieves the same as the “unsafe” version except it checks to ensure that a page table entry is not being overwritten with something different. The populations differs based on whether there are 5 page table levels or 4, because with 4 the level can be treated as a PUD rather than a P4D.

Finally, if a PGD entry is changed, [sync_global_pgds()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n212) is invoked. For kernel mappings, PGD changes are a problem as each process has

its own separate PGD table so changes which affect PGD mappings must be synced between them all.

Additionally, if PTI is enabled then each PGD will be a separate kernel

page table, if not then they are each shared with userspace mappings.



**N O T E** PGD synchronisation is only a concern during kernel initialization. Once the direct

mapping is set up and the memory management subsystem is established, PGDs do not need to be synchronized again.



While setting up mappings, we move through each page level performing

similar actions. We’ll look at each level in detail, but let’s take some time to examine sync_global_pgds() and alloc_low_page(), starting with the former,

shown in Listing 3-22.



208 */\**

209 *\* When memory was added make sure all the processes MM have* 210 *\* suitable PGD entries in the local PGD level page.* 211 *\*/*

212 **static void sync_global_pgds**(**unsigned long** start, **unsigned long** end) 213 {

214 **if** (**pgtable_l5_enabled**()) 215 **sync_global_pgds_l5**(start, end); 216 **else**

217 **sync_global_pgds_l4**(start, end); 218 }



*Listing 3-22:* arch/x86/mm/init_64.c: [*sync_global_pgds()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n212)



There is separate logic for 5-level and 4-level. As they are very similar,

we’ll examine the 5-level logic only. All PGDs are stored on the [pgd_list](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n170)

linked list, which is added to via [pgd_list_add()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgtable.c?h=v6.0#n93) and removed from via

[pgd_list_del()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgtable.c?h=v6.0#n100).







PGDs are added to these lists when they are constructed in [pgd_ctor()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgtable.c?h=v6.0#n123)

(which is invoked in turn by [pgd_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgtable.c?h=v6.0#n424)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgtable.c?h=v6.0#n424) and removed when they are destruc-

ted in [pgd_dtor()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgtable.c?h=v6.0#n143) (which is invoked in turn by [pgd_free()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgtable.c?h=v6.0#n471)[).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgtable.c?h=v6.0#n471)

Let’s examine [sync_global_pgds_l5()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n127) in Listing 3-23.



127 **static void sync_global_pgds_l5**(**unsigned long** start, **unsigned long** end) 128 {

129 **unsigned long** addr;

130

131 **for** (addr = start; addr \<= end; addr = **ALIGN**(addr + 1, **PGDIR_SIZE**)) { 132 **const pgd_t** \*pgd_ref = **pgd_offset_k**(addr); 133 **struct** page \*page;

134

135 */\* Check for overflow \*/* 136 **if** (addr \< start) 137 **break**;

138

139 **if** (**pgd_none**(\*pgd_ref)) 140 **continue**;

141

142 **spin_lock**(&pgd_lock); 143 **list_for_each_entry**(page, &pgd_list, lru) { 144 **pgd_t** \*pgd; 145 **spinlock_t** \*pgt_lock;

146

147 pgd = (**pgd_t** \*)**page_address**(page) + **pgd_index**(addr); 148 */\* the pgt_lock only for Xen \*/* 149 pgt_lock = &**pgd_page_get_mm**(page)-\>page_table_lock; 150 **spin_lock**(pgt_lock);

151

152 **if** (!**pgd_none**(\*pgd_ref) && !**pgd_none**(\*pgd)) 153 **BUG_ON**(**pgd_page_vaddr**(\*pgd) != **pgd_page_vaddr**

(\*pgd_ref));

154

155 **if** (**pgd_none**(\*pgd)) 156 **set_pgd**(pgd, \*pgd_ref);

157

158 **spin_unlock**(pgt_lock); 159 }

160 **spin_unlock**(&pgd_lock); 161 }

162 }



*Listing 3-23:* arch/x86/mm/init_64.c: [*sync_global_pgds_l5()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n127)



This function takes the current kernel PGD and synchronizes all map-

pings from it to all other PGDs in the range start to end, inclusive. The cur-

rent reference PGD entry is stored in pgd_ref. The global [pgd_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n169) is used to

protect accesses to [pgd_list](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n170).







For present entries, we retrieve the address of the PGD via [page_address()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1708)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1708)

which in turn invokes [page_to_virt()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n114) and [\_\_va()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page.h?h=v6.0#n59)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page.h?h=v6.0#n59) In addition, we can deter-

mine the offset at which a virtual address lies within the PGD via [pgd_index()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n86)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n86)

After taking appropriate locks, we check the edge case where both the

source and target PGD entry are populated. In this instance, we cannot per-mit replacing the referenced P4D with another (and thus possibly leaking the existing mapping). We therefore raise a kernel bug (and under these cir-cumstances, likely a panic) if anything but the flags are changed.

Finally, we set the entry via [set_pgd()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n76) and continue the process for all

other entries in the range.

Returning to [\_\_kernel_physical_mapping_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n725), we see that it invokes

[alloc_low_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/mm_internal.h?h=v6.0#n6) to perform the actual allocation of pages, which in turn it-

self invokes [alloc_low_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n123) with num set to 1, as shown in Listing 3-24.



123 **\_\_ref void** \***alloc_low_pages**(**unsigned int** num) 124 {

125 **unsigned long** pfn; 126 **int** i;

127

128 **if** (after_bootmem) { 129 **unsigned int** order; 130

131 order = **get_order**((**unsigned long**)num \<\< **PAGE_SHIFT**); 132 **return** (**void** \*)**\_\_get_free_pages**(**GFP_ATOMIC** \| **\_\_GFP_ZERO**, order

);

133 }

134

135 **if** ((pgt_buf_end + num) \> pgt_buf_top \|\| !can_use_brk_pgt) { 136 **unsigned long** ret = 0; 137

138 **if** (min_pfn_mapped \< max_pfn_mapped) { 139 ret = **memblock_phys_alloc_range**( 140 **PAGE_SIZE** \* num, **PAGE_SIZE**, 141 min_pfn_mapped \<\< **PAGE_SHIFT**, 142 max_pfn_mapped \<\< **PAGE_SHIFT**); 143 }

144 **if** (!ret && can_use_brk_pgt) 145 ret = **\_\_pa**(**extend_brk**(**PAGE_SIZE** \* num, **PAGE_SIZE**)); 146

147 **if** (!ret) 148 **panic**("**alloc_low_pages**: can not alloc memory"); 149

150 pfn = ret \>\> **PAGE_SHIFT**; 151 } **else** {

152 pfn = pgt_buf_end; 153 pgt_buf_end += num; 154 }

155







156 **for** (i = 0; i \< num; i++) { 157 **void** \*adr;

158

159 adr = **\_\_va**((pfn + i) \<\< **PAGE_SHIFT**); 160 **clear_page**(adr); 161 }

162

163 **return \_\_va**(pfn \<\< **PAGE_SHIFT**); 164 }



*Listing 3-24:* arch/x86/mm/init.c: [*alloc_low_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n123)



Again, we can assume that [after_bootmem](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n200) is not set as we are initializing

the direct mapping. We then see whether we can use the PGT buffer. If not,

we allocate using memblock from within the range specified by the globals

[min_pfn_mapped](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n110) and [max_pfn_mapped](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/setup.c?h=v6.0#n65). These are updated and expanded as the

direct mapping expands. If no memory can be allocated, then the kernel

panics.

If memory is allocated from the pgt_buf, then it’s as simple as expanding

[pgt_buf_end](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init.c?h=v6.0#n107). After this we clear pages via [clear_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_64.h?h=v6.0#n48) and return the virtual

address of the first.

Now let’s examine the next stage of this process in [phys_p4d_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n674)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n674) shown

in Listing 3-25.



673 **static unsigned long \_\_meminit** 674 **phys_p4d_init**(**p4d_t** \*p4d_page, **unsigned long** paddr, **unsigned long** paddr_end, 675 **unsigned long** page_size_mask, **pgprot_t** prot, **bool** init) 676 {

677 **unsigned long** vaddr, vaddr_end, vaddr_next, paddr_next, paddr_last;

678

679 paddr_last = paddr_end; 680 vaddr = (**unsigned long**)**\_\_va**(paddr); 681 vaddr_end = (**unsigned long**)**\_\_va**(paddr_end);

682

683 **if** (!**pgtable_l5_enabled**()) 684 **return phys_pud_init**((**pud_t** \*) p4d_page, paddr, paddr_end, 685 page_size_mask, prot, init);

686

687 **for** (; vaddr \< vaddr_end; vaddr = vaddr_next) { 688 **p4d_t** \*p4d = p4d_page + **p4d_index**(vaddr); 689 **pud_t** \*pud;

690

691 vaddr_next = (vaddr & **P4D_MASK**) + **P4D_SIZE**; 692 paddr = **\_\_pa**(vaddr);

693

694 **if** (paddr \>= paddr_end) { 695 paddr_next = **\_\_pa**(vaddr_next); 696 **if** (!after_bootmem && 697 !**e820\_\_mapped_any**(paddr & **P4D_MASK**, paddr_next,







698 **E820_TYPE_RAM**) && 699 !**e820\_\_mapped_any**(paddr & **P4D_MASK**, paddr_next, 700 **E820_TYPE_RESERVED_KERN**)) 701 **set_p4d_init**(p4d, \_\_p4d(0), init); 702 **continue**; 703 }

704

705 **if** (!**p4d_none**(\*p4d)) { 706 pud = **pud_offset**(p4d, 0); 707 paddr_last = **phys_pud_init**(pud, paddr, **\_\_pa**(vaddr_end)

,

708 page_size_mask, prot, init); 709 **continue**; 710 }

711

712 pud = **alloc_low_page**(); 713 paddr_last = **phys_pud_init**(pud, paddr, **\_\_pa**(vaddr_end), 714 page_size_mask, prot, init); 715

716 **spin_lock**(&init_mm.page_table_lock); 717 **p4d_populate_init**(&init_mm, p4d, pud, init); 718 **spin_unlock**(&init_mm.page_table_lock); 719 }

720

721 **return** paddr_last; 722 }



*Listing 3-25:* arch/x86/mm/init_64.c: [*phys_p4d_init()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n674)



This is broadly similar to [\_\_kernel_physical_mapping_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n725) but has a num-

ber of differences.

If 5-level page tables are disabled, we simply skip to the PUD level. Oth-

erwise, we iterate through the virtual address range, with each step moving to the next entry in the P4D. Similar to \_\_kernel_physical_mapping_init(), we reuse the existing mapping if it is in place. Otherwise, we allocate a new

PUD via [alloc_low_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/mm_internal.h?h=v6.0#n6) and populate the P4D entry while holding the shared page_table_lock.

However, a key difference here is we explicitly check for the situation

where, somehow, the physical address is out of range. If it is, we clear the P4D entry if and only if there is no RAM or kernel reserved memory as spec-

ified by the E820 PC architecture memory map via [e820\_\_mapped_any()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/e820.c?h=v6.0#n100)—this is used to explicitly clear page table entries for memory holes (places where no accessible physical memory exists).



**N O T E** E820 refers to a BIOS call, which is used on PCs early in boot to get a physical mem-

ory map. *e820* refers to what to place in the AX register to invoke the call.







The [phys_p4d_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n674) function returns the exclusive bound of physically

mapped memory in any case, which is updated when [phys_pud_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n587) is in-

voked to initialize the underlying PUD.

One thing to note with the P4D initialization that differs from others is

the use of virtual addresses to iterate through the memory. This is because

the [PAGE_OFFSET](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_types.h?h=v6.0#n36) addressed used to offset physical addresses in the direct map-

ping to find virtual ones is not guaranteed to be P4D aligned due to restric-

tions on the maximum KASLR offset.

The code therefore uses a conversion to and from virtual addresses to

ensure that when dealing with physical addresses they are always aligned and

to remove any implicit assumption about alignment from the code. This was

changed in commit 432c833218dd.

We’ll examine the initial part of [phys_pud_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n587) in Listing 3-26.



586 **static unsigned long \_\_meminit** 587 **phys_pud_init**(**pud_t** \*pud_page, **unsigned long** paddr, **unsigned long** paddr_end, 588 **unsigned long** page_size_mask, **pgprot_t** \_prot, **bool** init) 589 {

590 **unsigned long** pages = 0, paddr_next; 591 **unsigned long** paddr_last = paddr_end; 592 **unsigned long** vaddr = (**unsigned long**)**\_\_va**(paddr); 593 **int** i = **pud_index**(vaddr);

594

595 **for** (; i \< **PTRS_PER_PUD**; i++, paddr = paddr_next) {



*Listing 3-26:* arch/x86/mm/init_64.c: [*phys_pud_init()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n587) *preamble and loop*



Note that here we loop through all entries in the PUD starting at the be-

ginning of the range, even if we extend beyond the range, for which we have

special handling.

Next we initialize some values and check to see if we’re beyond the speci-

fied range—if so, we clear any entries that may exist for ranges which do not

have any accessible memory, or memory holes. As we are initializing mem-

ory ranges sequentially, we are opportunistically ensuring that we clear any

potentially incorrect page table entries spanning memory holes as we go,

which is shown in Listing 3-27.



596 **pud_t** \*pud; 597 **pmd_t** \*pmd; 598 **pgprot_t** prot = \_prot;

599

600 vaddr = (**unsigned long**)**\_\_va**(paddr); 601 pud = pud_page + **pud_index**(vaddr); 602 paddr_next = (paddr & **PUD_MASK**) + **PUD_SIZE**;

603

604 **if** (paddr \>= paddr_end) { 605 **if** (!after_bootmem && 606 !**e820\_\_mapped_any**(paddr & **PUD_MASK**, paddr_next, 607 **E820_TYPE_RAM**) &&







608 !**e820\_\_mapped_any**(paddr & **PUD_MASK**, paddr_next, 609 **E820_TYPE_RESERVED_KERN**)) 610 **set_pud_init**(pud, **\_\_pud**(0), init); 611 **continue**; 612 }



*Listing 3-27:* arch/x86/mm/init_64.c: [*phys_pud_init()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n587) *loop initialisation and PA check*



Next, if we are reusing an existing PUD entry, we have to consider 1GiB

huge pages and the ordinary 2MiB/4KiB case. If the PUD entry isn’t large, we proceed as before. If it is, we have to check to see if the page size mask permits 1GiB huge pages. If so, we simply continue as normal. If not, we enter into an edge case where we need to clear the huge page entry. We ex-

amine this in Listing 3-28.



614 **if** (!**pud_none**(\*pud)) { 615 **if** (!**pud_large**(\*pud)) { 616 pmd = **pmd_offset**(pud, 0); 617 paddr_last = **phys_pmd_init**(pmd, paddr, 618 paddr_end, 619 page_size_mask,

620 prot, init); 621 **continue**; 622 } 623 */\** 624 *\* If we are ok with PG_LEVEL_1G mapping, then we will*

625 *\* use the existing mapping.* 626 *\** 627 *\* Otherwise, we will split the gbpage mapping but use*

628 *\* the same existing protection bits except for large*

629 *\* page, so that we don't violate Intel's TLB* 630 *\* Application note (317080) which says, while*

*changing*

631 *\* the page sizes, new and old translations should*

632 *\* not differ with respect to page frame and* 633 *\* attributes.* 634 *\*/* 635 **if** (page_size_mask & (1 \<\< **PG_LEVEL_1G**)) { 636 **if** (!after_bootmem) 637 pages++; 638 paddr_last = paddr_next; 639 **continue**; 640 } 641 prot = **pte_pgprot**(**pte_clrhuge**(\*(**pte_t** \*)pud)); 642 }



*Listing 3-28:* arch/x86/mm/init_64.c: [*phys_pud_init()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n587) *existing entry*







If there is no existing entry, we have to either mark the page as huge or

allocate a new PMD and assign it. We try to use a 1GiB huge page if speci-

fied to do so by the page_size_mask argument, resetting the paddr_last value

to take this into account. If we are not permitted to use a huge page, we allo-

cate and assign as before, calling into [phys_pmd_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n502)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n502) shown in Listing 3-31.

Next let’s examine the case of a new entry in [phys_pud_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n587) shown in

Listing 3-29.



644 **if** (page_size_mask & (1\<\<**PG_LEVEL_1G**)) { 645 pages++; 646 **spin_lock**(&init_mm.page_table_lock);

647

648 prot = **\_\_pgprot**(**pgprot_val**(prot) \| **\_PAGE_PSE**);

649

650 **set_pte_init**((**pte_t** \*)pud, 651 **pfn_pte**((paddr & **PUD_MASK**) \>\> **PAGE_SHIFT**, 652 prot), 653 init); 654 **spin_unlock**(&init_mm.page_table_lock); 655 paddr_last = paddr_next; 656 **continue**; 657 }

658

659 pmd = **alloc_low_page**(); 660 paddr_last = **phys_pmd_init**(pmd, paddr, paddr_end, 661 page_size_mask, prot, init);

662

663 **spin_lock**(&init_mm.page_table_lock); 664 **pud_populate_init**(&init_mm, pud, pmd, init); 665 **spin_unlock**(&init_mm.page_table_lock); 666 }



*Listing 3-29:* arch/x86/mm/init_64.c: [*phys_pud_init()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n587) *new entry*



Finally, we keep a track of the number of 1GiB huge pages allocated via

the pages variable, which we use to update stats with before returning the last

mapped physical address, paddr_last, as shown in Listing 3-30.



668 **update_page_count**(**PG_LEVEL_1G**, pages);

669

670 **return** paddr_last; 671 }



*Listing 3-30:* arch/x86/mm/init_64.c: [*phys_pud_init()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n587) *after loop*



The structure of [phys_pmd_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n502) is very similar to [phys_pud_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n587) as shown

in Listing 3-31.



501 **static unsigned long \_\_meminit** 502 **phys_pmd_init**(**pmd_t** \*pmd_page, **unsigned long** paddr, **unsigned long** paddr_end,







503 **unsigned long** page_size_mask, **pgprot_t** prot, **bool** init) 504 {

505 **unsigned long** pages = 0, paddr_next; 506 **unsigned long** paddr_last = paddr_end; 507

508 **int** i = **pmd_index**(paddr); 509

510 **for** (; i \< **PTRS_PER_PMD**; i++, paddr = paddr_next) { 511 **pmd_t** \*pmd = pmd_page + **pmd_index**(paddr); 512 **pte_t** \*pte; 513 **pgprot_t** new_prot = prot; 514

515 paddr_next = (paddr & **PMD_MASK**) + **PMD_SIZE**; 516 **if** (paddr \>= paddr_end) { 517 **if** (!after_bootmem && 518 !**e820\_\_mapped_any**(paddr & **PMD_MASK**, paddr_next, 519 **E820_TYPE_RAM**) && 520 !**e820\_\_mapped_any**(paddr & **PMD_MASK**, paddr_next, 521 **E820_TYPE_RESERVED_KERN**)) 522 **set_pmd_init**(pmd, **\_\_pmd**(0), init); 523 **continue**; 524 }

525

526 **if** (!**pmd_none**(\*pmd)) { 527 **if** (!**pmd_large**(\*pmd)) { 528 **spin_lock**(&init_mm.page_table_lock); 529 pte = (**pte_t** \*)**pmd_page_vaddr**(\*pmd); 530 paddr_last = **phys_pte_init**(pte, paddr, 531 paddr_end, prot,

532 init); 533 **spin_unlock**(&init_mm.page_table_lock); 534 **continue**; 535 } 536 */\** 537 *\* If we are ok with PG_LEVEL_2M mapping, then we will*

538 *\* use the existing mapping,* 539 *\** 540 *\* Otherwise, we will split the large page mapping but*

541 *\* use the same existing protection bits except for*

542 *\* large page, so that we don't violate Intel's TLB*

543 *\* Application note (317080) which says, while*

*changing*

544 *\* the page sizes, new and old translations should*

545 *\* not differ with respect to page frame and* 546 *\* attributes.* 547 *\*/* 548 **if** (page_size_mask & (1 \<\< **PG_LEVEL_2M**)) {







549 **if** (!after_bootmem) 550 pages++; 551 paddr_last = paddr_next; 552 **continue**; 553 } 554 new_prot = **pte_pgprot**(**pte_clrhuge**(\*(**pte_t** \*)pmd)); 555 }

556

557 **if** (page_size_mask & (1\<\<**PG_LEVEL_2M**)) { 558 pages++; 559 **spin_lock**(&init_mm.page_table_lock); 560 **set_pte_init**((**pte_t** \*)pmd, 561 **pfn_pte**((paddr & **PMD_MASK**) \>\> **PAGE_SHIFT**, 562 **\_\_pgprot**(**pgprot_val**(prot) \|

**\_PAGE_PSE**)),

563 init); 564 **spin_unlock**(&init_mm.page_table_lock); 565 paddr_last = paddr_next; 566 **continue**; 567 }

568

569 pte = **alloc_low_page**(); 570 paddr_last = **phys_pte_init**(pte, paddr, paddr_end, new_prot,

init);

571

572 **spin_lock**(&init_mm.page_table_lock); 573 **pmd_populate_kernel_init**(&init_mm, pmd, pte, init); 574 **spin_unlock**(&init_mm.page_table_lock); 575 }

576 **update_page_count**(**PG_LEVEL_2M**, pages); 577 **return** paddr_last; 578 }



*Listing 3-31:* arch/x86/mm/init_64.c: [*phys_pmd_init()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n502)



The only difference is that 2MiB huge pages are considered and the pop-

ulate command is named [pmd_populate_kernel_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n76) with \_kernel\_ explicitly

labelled.

Finally, let’s consider the far simpler [phys_pte_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n448), shown in Listing 3-

32.



447 **static unsigned long \_\_meminit** 448 **phys_pte_init**(**pte_t** \*pte_page, **unsigned long** paddr, **unsigned long** paddr_end, 449 **pgprot_t** prot, **bool** init) 450 {

451 **unsigned long** pages = 0, paddr_next; 452 **unsigned long** paddr_last = paddr_end; 453 **pte_t** \*pte;

454 **int** i;







455

456 pte = pte_page + **pte_index**(paddr); 457 i = **pte_index**(paddr); 458

459 **for** (; i \< **PTRS_PER_PTE**; i++, paddr = paddr_next, pte++) { 460 paddr_next = (paddr & **PAGE_MASK**) + **PAGE_SIZE**; 461 **if** (paddr \>= paddr_end) { 462 **if** (!after_bootmem && 463 !**e820\_\_mapped_any**(paddr & **PAGE_MASK**, paddr_next, 464 **E820_TYPE_RAM**) && 465 !**e820\_\_mapped_any**(paddr & **PAGE_MASK**, paddr_next, 466 **E820_TYPE_RESERVED_KERN**)) 467 **set_pte_init**(pte, \_\_pte(0), init); 468 **continue**; 469 }

470

471 */\**

472 *\* We will re-use the existing mapping.* 473 *\* Xen for example has some special requirements, like mapping*

474 *\* pagetable pages as RO. So assume someone who pre-setup*

475 *\* these mappings are more intelligent.* 476 *\*/*

477 **if** (!**pte_none**(\*pte)) { 478 **if** (!after_bootmem) 479 pages++; 480 **continue**; 481 }

482

483 **if** (0)

484 **pr_info**(" pte=%p addr=%lx pte=%016lx\n", pte, paddr, 485 **pfn_pte**(paddr \>\> **PAGE_SHIFT**, **PAGE_KERNEL**).pte)

;

486 pages++;

487 **set_pte_init**(pte, **pfn_pte**(paddr \>\> **PAGE_SHIFT**, prot), init); 488 paddr_last = (paddr & **PAGE_MASK**) + **PAGE_SIZE**; 489 }

490

491 **update_page_count**(**PG_LEVEL_4K**, pages); 492

493 **return** paddr_last; 494 }



*Listing 3-32:* arch/x86/mm/init_64.c: [*phys_pte_init()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n448)



This is similar to the other functions, only with no need to consider huge

pages or populating/allocating any further page tables.

In each case of 1GiB, 2MiB huge pages, and 4KiB non-huge pages we

initialize the final entry via [set_pte_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n91) (this and the other set\_\*\_init func-







tions being generated by macros), using [pfn_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n577) to encode the data page

physical address and page flags.

While we went into considerable detail in this section to explain the ini-

tialization of direct mapping, it is a very useful exercise not only in under-

standing how this is initialized but also to see page table manipulation in

action.



**3.4 An Introduction to the Transaction Lookaside Buffer**

Traversing page tables is expensive, so the hardware provides caches to

speed up translation of virtual addresses. The most important of these is

Transaction Lookaside Buffer (TLB), which is in effect a hash between virtual

and physical addresses, permitting the hardware to avoid a page table traver-

sal when looking up a virtual address.

As we modify page tables it is critical to ensure that any pre-existing TLB

entries are cleared in order that incorrect address translations do not occur.

In x86-64, the current PGD is set in the CR3 control register. When this is

changed the TLB is automatically flushed, so context switching between pro-

cesses achieves a TLB flush along side it, except for mappings marked with

the \_PAGE_GLOBAL flag.

When a single page’s mapping is invalidated, however, we would rather

simply clear any existent TLB entry for it. In x86-64 this is done via the

invlpg instruction and ultimately performed by [native_flush_tlb_one_user()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n1120),

shown in Listing 3-33.



**N O T E** Note that this makes reference to the x86-64 feature Process Context Identifiers

(PCIDs), which is used by the [Page Table Isolation (PTI)](https://kernel.org/doc/html/v6.0/x86/pti.html) functionality for mitiga-

tion against the meltdown vulnerability. Discussion of this is out of scope here.



1120 **STATIC_NOPV void native_flush_tlb_one_user**(**unsigned long** addr) 1121 {

1122 **u32** loaded_mm_asid = **this_cpu_read**(cpu_tlbstate.loaded_mm_asid); 1123

1124 asm **volatile**("invlpg (%0)" ::"r" (addr) : "memory"); 1125

1126 **if** (!**static_cpu_has**(**X86_FEATURE_PTI**)) 1127 **return**;

1128

1129 */\**

1130 *\* Some platforms \#GP if we call invpcid(type=1/2) before CR4.PCIDE=1.*

1131 *\* Just use invalidate_user_asid() in case we are called early.* 1132 *\*/*

1133 **if** (!**this_cpu_has**(**X86_FEATURE_INVPCID_SINGLE**)) 1134 **invalidate_user_asid**(loaded_mm_asid); 1135 **else**

1136 **invpcid_flush_one**(**user_pcid**(loaded_mm_asid), addr); 1137 }







*Listing 3-33:* arch/x86/mm/tlb.c: [*native_flush_tlb_one_user()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n1120)



The [native_flush_tlb_one_user()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n1120) function is called by

[\_\_flush_tlb_one_user(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n30)which is called in turn by [flush_tlb_one_user()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n1139). This is invoked by many different call paths for TLB cache invalidation for both kernel and userland. The alternative, global flush, is ultimately

performed by [native_flush_tlb_global()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n1147) that either uses PCID invalidation or writes CR3 to flush globally.

The use of huge pages can make a very big difference in TLB

performance—since huge pages span a far wider range of memory, the en-tries cached in the TLB face far less contention. For example, 2MiB huge pages span 512 4KiB pages, meaning a potentially huge reduction in the number of page table walks required. 1GiB huge pages span 262,144 4KiB pages with a further order of magnitude reduction in TLB contention under ideal circumstances.

The discussion is kept intentionally brief here as we will go into more

detail on TLB maintenance in Chapter 7 on the Reverse Mapping.



**3.5 The Kernel Virtual Memory Allocator (vmalloc)**



Allocating memory in the kernel is typically performed using the slab allo-

cator via [kmalloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/slab.h?h=v6.0#n586) (slab allocation is out of scope for the book), but this acts solely as a physical memory allocator and uses the direct mapping to return a virtual address. Since contiguous physical memory is in short supply, try-ing to allocate larger blocks of memory using the slab allocator may not be entirely useful or wise.

The kernel provides a mechanism for the allocation of virtually contigu-

ous memory, vmalloc, allocating via [vmalloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3292) and freeing via [vfree()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2764)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2764)

The [vmalloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3292) function accepts an arbitrary size parameter in bytes for

which sufficient underlying pages will be allocated, with page tables gener-ated to span the range.

Additionally, existing physical memory can be mapped and unmapped

via [vmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2812) and [vunmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2788).

Let’s examine [vmalloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3292) in Listing 3-34.



3280 */\*\**

3281 *\* vmalloc - allocate virtually contiguous memory* 3282 *\* @size:* *allocation size* 3283 *\**

3284 *\* Allocate enough pages to cover @size from the page level* 3285 *\* allocator and map them into contiguous kernel virtual space.* 3286 *\**

3287 *\* For tight control over page level allocator and protection flags* 3288 *\* use \_\_vmalloc() instead.* 3289 *\**

3290 *\* Return: pointer to the allocated memory or %NULL on error* 3291 *\*/*







3292 **void** \***vmalloc**(**unsigned long** size) 3293 {

3294 **return \_\_vmalloc_node**(size, 1, **GFP_KERNEL**, **NUMA_NO_NODE**, 3295 **\_\_builtin_return_address**(0)); 3296 }



*Listing 3-34:* mm/vmalloc.c: [*vmalloc()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3292)



If a caller wishes to allocate memory that is automatically zeroed,

[vzalloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3332) provides this functionality, as shown in Listing 3-35.



3332 **void** \***vzalloc**(**unsigned long** size) 3333 {

3334 **return \_\_vmalloc_node**(size, 1, **GFP_KERNEL** \| **\_\_GFP_ZERO**, **NUMA_NO_NODE**, 3335 **\_\_builtin_return_address**(0)); 3336 }



*Listing 3-35:* mm/vmalloc.c: [*vzalloc()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3332)



Each of these invoke [\_\_vmalloc_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3258)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3258) which is shown in Listing 3-36.



3239 */\*\**

3240 *\* \_\_vmalloc_node - allocate virtually contiguous memory* 3241 *\* @size:* *allocation size* 3242 *\* @align:* *desired alignment* 3243 *\* @gfp_mask:* *flags for the page level allocator* 3244 *\* @node:* *node to use for allocation or NUMA_NO_NODE* 3245 *\* @caller:* *caller's return address* 3246 *\**

3247 *\* Allocate enough pages to cover @size from the page level allocator with*

3248 *\* @gfp_mask flags. Map them into contiguous kernel virtual space.* 3249 *\**

3250 *\* Reclaim modifiers in @gfp_mask - \_\_GFP_NORETRY, \_\_GFP_RETRY_MAYFAIL* 3251 *\* and \_\_GFP_NOFAIL are not supported* 3252 *\**

3253 *\* Any use of gfp flags outside of GFP_KERNEL should be consulted* 3254 *\* with mm people.*

3255 *\**

3256 *\* Return: pointer to the allocated memory or %NULL on error* 3257 *\*/*

3258 **void** \***\_\_vmalloc_node**(**unsigned long** size, **unsigned long** align, 3259 **gfp_t** gfp_mask, **int** node, **const void** \*caller) 3260 {

3261 **return \_\_vmalloc_node_range**(size, align, **VMALLOC_START**, **VMALLOC_END**, 3262 gfp_mask, **PAGE_KERNEL**, 0, node, caller); 3263 }



*Listing 3-36:* mm/vmalloc.c: [*\_\_vmalloc_node()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3258)



You can see that [vmalloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3292) invokes this with alignment set to 1, the GFP

mask set to GFP_KERNEL, the node mas set to NUMA_NO_NODE (specifying that no







specific node is required to be allocated on), and caller set to the return ad-

dress of the function, which is used for reporting. Equally, [vzalloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3332) passes the same parameters, only additionaly specifying that the memory range be zeroed via \_\_GFP_ZERO.

There are a number of different allocation functions which can be used

to perform a kernel virtual memory allocation, but all ultimately invoke

[\_\_vmalloc_node_range(). ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3111)Figure 3-11 illustrates these allocators.



[vcalloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n740) [\_\_vcalloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n729)



[vmalloc_array()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n717) [\_\_vmalloc_array()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n702)



[vmalloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3292) [vzalloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3332) [\_\_vmalloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3273) [vmalloc_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3370) [vzalloc_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3388)



[vmalloc_32()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3416) [\_\_vmalloc_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3258) [vmalloc_user()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3348)



[vmalloc_32_user()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3432) [\_\_vmalloc_node_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3111) [vmalloc_huge()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3311)



*Figure 3-11: vmalloc allocators*



Each of these end up invoking [\_\_vmalloc_node_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3111), the “heart” of the

virtual allocator. Let’s examine the beginning of this function in Listing 3-37 (stripping out of scope KASAN and kmemleak logic).



3111 **void** \***\_\_vmalloc_node_range**(**unsigned long** size, **unsigned long** align, 3112 **unsigned long** start, **unsigned long** end, **gfp_t** gfp_mask

,

3113 **pgprot_t** prot, **unsigned long** vm_flags, **int** node, 3114 **const void** \*caller) 3115 {

3116 **struct** vm_struct \*area; 3117 **void** \*ret;

. . .

3119 **unsigned long** real_size = size; 3120 **unsigned long** real_align = align; 3121 **unsigned int** shift = **PAGE_SHIFT**; 3122

3123 **if** (**WARN_ON_ONCE**(!size)) 3124 **return NULL**; 3125

3126 **if** ((size \>\> **PAGE_SHIFT**) \> **totalram_pages**()) { 3127 **warn_alloc**(gfp_mask, **NULL**, 3128 "vmalloc error: size %lu, exceeds total pages", 3129 real_size); 3130 **return NULL**; 3131 }







3132

3133 **if** (vmap_allow_huge && (vm_flags & **VM_ALLOW_HUGE_VMAP**)) { 3134 **unsigned long** size_per_node; 3135

3136 */\**

3137 *\* Try huge pages. Only try for PAGE_KERNEL allocations,* 3138 *\* others like modules don't yet expect huge pages in* 3139 *\* their allocations due to apply_to_page_range not* 3140 *\* supporting them.* 3141 *\*/*

3142

3143 size_per_node = size; 3144 **if** (node == **NUMA_NO_NODE**) 3145 size_per_node /= **num_online_nodes**(); 3146 **if** (**arch_vmap_pmd_supported**(prot) && size_per_node \>= **PMD_SIZE**

)

3147 shift = **PMD_SHIFT**; 3148 **else**

3149 shift = **arch_vmap_pte_supported_shift**(size_per_node); 3150

3151 align = **max**(real_align, 1UL \<\< shift); 3152 size = **ALIGN**(real_size, 1UL \<\< shift); 3153 }



*Listing 3-37:* mm/vmalloc.c: [*\_\_vmalloc_node_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3111) *preface*



Note that the start and (exclusive) end bound parameters specify the

range in which the allocation can be obtained from.

Typically these are set to VMALLOC_START and VMALLOC_END respectively, indi-

cating that any portion of the vmalloc space can be used.

After ensuring the specified size parameter is of a reasonable size, the

VM_ALLOW_HUGE_VMAP flag is checked to see if huge pages can be used (and

whether the size is large enough for this). If no specific node is specified,

then we anticipate the worst case NUMA memory policy of interleaved

pages per node—therefore requiring size to be equal to the huge page size

times the number of nodes in this instance.

The function then checks [arch_vmap_pmd_supported()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/vmalloc.h?h=v6.0#n19) to see if huge pages

are supported at all and [arch_vmap_pte_supported_shift()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmalloc.h?h=v6.0#n112) is used for a Power

PC architecture edge case. Size and alignment are adjusted accordingly.

Listing 3-38 shows the remainder of the [\_\_vmalloc_node_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3111) function.



3155 **again**:

3156 area = **\_\_get_vm_area_node**(real_size, align, shift, **VM_ALLOC** \| 3157 **VM_UNINITIALIZED** \| vm_flags, start, end,

node,

3158 gfp_mask, caller); 3159 **if** (!area) {

3160 **bool** nofail = gfp_mask & **\_\_GFP_NOFAIL**; 3161 **warn_alloc**(gfp_mask, **NULL**,







3162 "vmalloc error: size %lu, vm_struct allocation failed%

s",

3163 real_size, (nofail) ? ". Retrying." : ""); 3164 **if** (nofail) { 3165 **schedule_timeout_uninterruptible**(1); 3166 **goto again**; 3167 }

3168 **goto fail**; 3169 }

. . .

3195 */\* Allocate physical pages and map them into vmalloc space. \*/* 3196 ret = **\_\_vmalloc_area_node**(area, gfp_mask, prot, shift, node); 3197 **if** (!ret)

3198 **goto fail**;

. . .

3215 */\**

3216 *\* In this function, newly allocated vm_struct has VM_UNINITIALIZED*

3217 *\* flag. It means that vm_struct is not fully initialized.* 3218 *\* Now, it is fully initialized, so remove this flag here.* 3219 *\*/*

3220 **clear_vm_uninitialized_flag**(area); 3221

3222 size = **PAGE_ALIGN**(size);

. . .

3226 **return** area-\>addr; 3227

3228 **fail**:

3229 **if** (shift \> **PAGE_SHIFT**) { 3230 shift = **PAGE_SHIFT**; 3231 align = real_align; 3232 size = real_size; 3233 **goto again**; 3234 }

3235

3236 **return NULL**;

3237 }



*Listing 3-38:* mm/vmalloc.c: [*\_\_vmalloc_node_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3111) *core*



A virtual memory area node of type [struct vm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmalloc.h?h=v6.0#n48) (more on this data

type shortly) is initialized via [\_\_get_vm_area_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2459) (see Listing 3-40). This tries to find a suitable range of available vmalloc address space of the required size and updates vmalloc state to track it. If this fails, the same operation is tried again if the \_\_GFP_NO_FAIL flag was specified, otherwise the operation fails.

Next, the actual allocation and mapping is performed by

[\_\_vmalloc_area_node() , ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2988)before clearing the VM_UNINITIALIZED flag in the gener-ated vm_struct (this structure is still referenced within vmalloc).







On failure, if huge pages were used, we try again only this time using an

ordinary page size.

We examine [struct vm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmalloc.h?h=v6.0#n48) in Listing 3-39.



48 **struct** vm_struct {

49 **struct** vm_struct \*next;

50 **void** \*addr;

51 **unsigned long** size;

52 **unsigned long** flags;

53 **struct** page \*\*pages;

54 **\#ifdef CONFIG_HAVE_ARCH_HUGE_VMALLOC**

55 **unsigned int** page_order;

56 **\#endif**

57 **unsigned int** nr_pages;

58 **phys_addr_t** phys_addr;

59 **const void** \*caller;

60 };



*Listing 3-39:* include/linux/vmalloc.h: [*struct vm_struct*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmalloc.h?h=v6.0#n48)



Let’s go over each field:



next – Used by early initialization functions to maintain a list of early vmal-

loc areas with a head entry at [vmlist](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2269), manipulated via [vm_area_add_early()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2299)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2299)

[vm_area_register_early() , ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2327)and [vmalloc_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2388)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2388)

addr – The virtual address of the start of the allocated block.

size – The size, in bytes, of the allocated block.

flags – vmalloc flags associated with the block.

pages – An array of pointers to the [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) objects describing the physi-

cal memory backing the vmalloc area.

page_order – Either 0 or if huge pages are used, the huge page order.

nr_pages – The number of base pages spanning the allocated block.

phys_addr – Ostensibly a physical address associated with the mapped block,

but doesn’t appear to be used.

caller – A pointer containing the return address of the function that in-

voked the entrypoint into vmalloc. This is used for debug output (for example, via /proc/vmallocinfo) to indicate what function requested each block.



The vmalloc flags determine how vmalloc allocations are performed and

are either set by the function the user has called into, or if calling via some-

thing like [get_vm_area()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2526)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2526) these can be specified. Flags can be combined:



• VM_IOREMAP – This indicates that the allocation will be used for I/O opera-

tions in the vein of [ioremap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/ioremap.c?h=v6.0#n331)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/ioremap.c?h=v6.0#n331) This is out of scope for this discussion.

• VM_ALLOC – Indicates that this is an ordinary vmalloc allocation.







• VM_MAP – Indicates the memory is to be mapped. This field is used as the

default flag in invocations of [vmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2812), however it does not appear to have any impact on actual vmalloc behaviour.

• VM_USERMAP – Indicates that the vmalloc block can be remapped

into userland. [remap_vmalloc_range_partial()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3588) (which is invoked by

[remap_vmalloc_range() ) ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3648)checks that flag is set (as well as VM_DMA_COHERENT)

or otherwise aborts. Set by [vmalloc_user()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3348) and [vmalloc_32_user()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3432)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3432)

• VM_DMA_COHERENT – Indicates that the memory is to be used for coherent

DMA allocations. Out of scope of discussion here.

• VM_UNINITIALIZED – This flag is set when the area is first created, and

cleared once it is set up via [clear_vm_uninitialized_flag()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2448)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2448) It is only used

by [show_numa_info()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n4053), invoked via [s_show()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n4090)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n4090) which is part of the [vmalloc_op](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n4154) object used for /proc/vmallocinfo, causing no data to be output when the block is not initialized.

• VM_NO_GUARD – Used to prevent the addition of a guard page on alloca-

tion. By default an additional page is marked as used by vmalloc but

not mapped in [\_\_get_vm_area_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2459). This prevents any subsequent vmal-loc allocations from allocating the page, so a buffer overrun won’t just blend into another region of vmalloc and an overrun will definitely trig-ger a page fault. A notable use of vmalloc guard pages are kernel stacks

(when CONFIG_VMAP_STACK is set), for example, in [page_fault_oops()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n632)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n632) where a stack overflow can be detected and dealt with rather than causing a ker-nel oops due to it being a page fault in kernel mode. Setting this flag to disable guard pages is not advised.

• VM_KASAN – Makes use of the kernel address sanitizer, out of scope for this

discussion.

• VM_FLUSH_RESET_PERMS – Used to ensure that the TLB is entirely flushed for

the vmalloc block memory range, and any lazy references to the memory range are cleared also (vmalloc lazily flushes the TLB cache on unmap to amortise the time taken for this slow operation). The direct mapping range that points at the pages is also invalidated.

• VM_MAP_PUT_PAGES – If set in the invocation of [vmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2812)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2812) then ownership of

the pages is passed to vmalloc and the underlying pages will be put (and

possibly freed) on [vfree()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2764)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2764)

• VM_ALLOW_HUGE_VMAP – Allows for huge pages to be used in the vmalloc allo-

cation. If this is set, the requested allocation size is sufficiently large, and the system supports it, then huge pages will be used.

• VM_DEFER_KMEMLEAK – Defers kmemleak checks, out of scope for this discus-

sion.



***3.5.1 Finding a Free Block***

The [\_\_vmalloc_node_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3111) function calls [\_\_get_vm_area_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2459) to find a free

memory block, which we examine in Listing 3-40 (stripping out of scope KASAN and I/O remap logic).







2459 **static struct** vm_struct \***\_\_get_vm_area_node**(**unsigned long** size, 2460 **unsigned long** align, **unsigned long** shift, **unsigned long** flags, 2461 **unsigned long** start, **unsigned long** end, **int** node, 2462 **gfp_t** gfp_mask, **const void** \*caller) 2463 {

2464 **struct** vmap_area \*va; 2465 **struct** vm_struct \*area; 2466 **unsigned long** requested_size = size; 2467

2468 **BUG_ON**(**in_interrupt**()); 2469 size = **ALIGN**(size, 1ul \<\< shift); 2470 **if** (**unlikely**(!size)) 2471 **return NULL**;

. . .

2477 area = **kzalloc_node**(**sizeof**(\*area), gfp_mask & **GFP_RECLAIM_MASK**, node); 2478 **if** (**unlikely**(!area)) 2479 **return NULL**; 2480

2481 **if** (!(flags & **VM_NO_GUARD**)) 2482 size += **PAGE_SIZE**; 2483

2484 va = **alloc_vmap_area**(size, align, start, end, node, gfp_mask); 2485 **if** (**IS_ERR**(va)) { 2486 **kfree**(area); 2487 **return NULL**; 2488 }

2489

2490 **setup_vmalloc_vm**(area, va, flags, caller);

. . .

2504 **return** area;

2505 }



*Listing 3-40:* mm/vmalloc.c: *Simplified [\_\_get_vm_area_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2459)*



The function starts by asserting we are not in an interrupt context, align-

ing the size to the input page shift (possibly huge) and ensuring that the

alignment didn’t overflow the size.

Next, we allocate memory for the vm_struct from the slab allocator via

[kzalloc_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/slab.h?h=v6.0#n742), masking the gfp_mask against [GFP_RECLAIM_MASK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n24)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n24) which limits

input GFP flags to those that impact watermark checking and reclaim be-

haviour. If this fails, the function returns NULL.

As mentioned previously in the description of vmalloc flags, if

VM_NO_GUARD is not set, then the size is extended by PAGE_SIZE, or 1 extra page.

This will result in an additional page being marked as used by vmalloc, and

thus unavailable for other vmalloc allocations, but the page will not actually

be mapped or allocated so any attempt to access it (like a buffer overrun) will

result in a page fault.







You can see this is the case as the additional page is added here

where vmalloc metadata is being setup but not in [\_\_vmalloc_area_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2988) where the actual backing page allocation and mapping is performed, and

[get_vm_area_size()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmalloc.h?h=v6.0#n198) explicitly excludes the guard page on backing page alloca-tion.

We then allocate a [struct vmap_area](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmalloc.h?h=v6.0#n62) via [alloc_vmap_area()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1569)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1569) If this fails, we

free the previously allocated vm_struct and return NULL.

Otherwise, we connect the two objects using [setup_vmalloc_vm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2440)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2440) which

acquires the [vmap_area_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n719) spin lock and invokes [setup_vmalloc_vm_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2430) to

assign the initial vm_struct fields, shown in Listing 3-41.



2430 **static inline void setup_vmalloc_vm_locked**(**struct** vm_struct \*vm, 2431 **struct** vmap_area \*va, **unsigned long** flags, **const void** \*caller) 2432 {

2433 vm-\>flags = flags; 2434 vm-\>addr = (**void** \*)va-\>va_start; 2435 vm-\>size = va-\>va_end - va-\>va_start; 2436 vm-\>caller = caller; 2437 va-\>vm = vm;

2438 }

2439

2440 **static void setup_vmalloc_vm**(**struct** vm_struct \*vm, **struct** vmap_area \*va, 2441 **unsigned long** flags, **const void** \*caller) 2442 {

2443 **spin_lock**(&vmap_area_lock); 2444 **setup_vmalloc_vm_locked**(vm, va, flags, caller); 2445 **spin_unlock**(&vmap_area_lock); 2446 }



*Listing 3-41:* mm/vmalloc.c: [*setup_vmalloc_vm()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2440) *and* [*setup_vmalloc_vm_locked()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2430)



As you can see, there is a direct relationship between the vm_struct and

the vmap_area objects, with the former containing metadata for the allocated block and the latter acting as a node in a red-black tree and a linked list rep-resenting the vmalloc space.

We construct things this way in order to make it efficient to look up

vmalloc metadata and to establish which portions of vmalloc space are avail-able for allocation.

Returning to [\_\_get_vm_area_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2459), note that it allocates a vmap_area via

[alloc_vmap_area()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1569). Let’s examine the initial portion of the function in Listing

3-42 (removing out of scope KASAN and kmemleak logic).



1569 **static struct** vmap_area \***alloc_vmap_area**(**unsigned long** size, 1570 **unsigned long** align, 1571 **unsigned long** vstart, **unsigned long** vend, 1572 **int** node, **gfp_t** gfp_mask) 1573 {

1574 **struct** vmap_area \*va; 1575 **unsigned long** freed;







1576 **unsigned long** addr; 1577 **int** purged = 0;

1578 **int** ret;

1579

1580 **BUG_ON**(!size);

1581 **BUG_ON**(**offset_in_page**(size)); 1582 **BUG_ON**(!**is_power_of_2**(align)); 1583

1584 **if** (**unlikely**(!vmap_initialized)) 1585 **return ERR_PTR**(-**EBUSY**); 1586

1587 **might_sleep**();

1588 gfp_mask = gfp_mask & **GFP_RECLAIM_MASK**; 1589

1590 va = **kmem_cache_alloc_node**(vmap_area_cachep, gfp_mask, node); 1591 **if** (**unlikely**(!va)) 1592 **return ERR_PTR**(-**ENOMEM**);



*Listing 3-42:* mm/vmalloc.c: [*alloc_vmap_area()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1569) *preface*



Here, we ensure that the inputs are sane, ensuring that vmalloc is initial-

ized before invoking [kmem_cache_alloc_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/slub.c?h=v6.0#n3296) to allocate memory from a slab

cache set up expressly to provide [struct vmap_area](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmalloc.h?h=v6.0#n62) objections. If this alloca-

tion fails, we return an error.

At this point we’ve allocated the vmap_area but have yet to insert it into

vmalloc state. Let’s examine the core logic in Listing 3-43.



1600 **retry**:

1601 **preload_this_cpu_lock**(&free_vmap_area_lock, gfp_mask, node); 1602 addr = **\_\_alloc_vmap_area**(&free_vmap_area_root, &free_vmap_area_list, 1603 size, align, vstart, vend); 1604 **spin_unlock**(&free_vmap_area_lock); 1605

1606 */\**

1607 *\* If an allocation fails, the "vend" address is* 1608 *\* returned. Therefore trigger the overflow path.* 1609 *\*/*

1610 **if** (**unlikely**(addr == vend)) 1611 **goto overflow**; 1612

1613 va-\>va_start = addr; 1614 va-\>va_end = addr + size; 1615 va-\>vm = **NULL**;

1616

1617 **spin_lock**(&vmap_area_lock); 1618 **insert_vmap_area**(va, &vmap_area_root, &vmap_area_list); 1619 **spin_unlock**(&vmap_area_lock); 1620

1621 **BUG_ON**(!**IS_ALIGNED**(va-\>va_start, align));







1622 **BUG_ON**(va-\>va_start \< vstart); 1623 **BUG_ON**(va-\>va_end \> vend);

. . .

1631 **return** va;



*Listing 3-43:* mm/vmalloc.c: [*alloc_vmap_area()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1569) *core*



This logic is divided into two parts:



1. Find and allocate a free block of vmalloc memory via [\_\_alloc_vmap_area()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1476)

(with [free_vmap_area_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n720) held) using the red/black binary search

tree rooted in [free_vmap_area_root](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n754) and the free list headed by

[free_vmap_area_list.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n742)

2. Insert the newly allocated block into the vmalloc tree rooted in

[vmap_area_root](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n723) and headed by [vmap_area_list](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n722) (with [vmap_area_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n719) held).



We’ll examine each of these shortly.

The invocation of \_\_alloc_vmap_area() can fail, in which case it returns

vend to indicate this and we jump to the overflow branch described in Listing

3-44. Otherwise, we set up the vmap_area fields appropriately, insert the area, perform some sanity checks, and return the area object.

Finally, we handle overflow in [alloc_vmap_area()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1569)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1569) shown in Listing 3-44.



1633 **overflow**:

1634 **if** (!purged) {

1635 **purge_vmap_area_lazy**(); 1636 purged = 1; 1637 **goto retry**; 1638 }

1639

1640 freed = 0;

1641 **blocking_notifier_call_chain**(&vmap_notify_list, 0, &freed); 1642

1643 **if** (freed \> 0) {

1644 purged = 0; 1645 **goto retry**; 1646 }

1647

1648 **if** (!(gfp_mask & **\_\_GFP_NOWARN**) && **printk_ratelimit**()) 1649 pr_warn("vmap allocation **for** size %lu failed: use vmalloc=\<

size\> to increase size\n",

1650 size); 1651

1652 **kmem_cache_free**(vmap_area_cachep, va); 1653 **return ERR_PTR**(-**EBUSY**); 1654 }



*Listing 3-44:* mm/vmalloc.c: [*alloc_vmap_area()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1569) *overflow handling*







This code attempts to free up vmalloc space, first by invoking

[purge_vmap_area_lazy()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1768) if this has not previously been tried, then retrying

the operation. Next, [blocking_notifier_call_chain()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/notifier.c?h=v6.0#n370) is tried to invoke any

shrinkers registered by vmalloc users. If memory is freed, the operation is

retried. If not, it is aborted and an EBUSY error code returned.



**N O T E** Shrinkers are a means by which kernel slab memory can be freed under mem-

ory pressure (this is out of scope for the book). [*blocking_notifier_call_chain()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/notifier.c?h=v6.0#n370)

references the [*vmap_notify_list*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n782) blocking notifier. Users of vmalloc can

register or unregister shrinkers via [*register_vmap_purge_notifier()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1656) and

[*unregister_vmap_purge_notifier()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1662), respectively, though this only appears to be used

by a couple of GPU drivers at present.



By default the vmalloc address space area is 32TiB in size for 4-level

or 12.5PiB for 5-level x86-64 and similar for other modern architectures,

so possessing insufficient space is unlikely to occur except on highly con-

strained hardware.

In order to avoid flushing the TLB too often (an expensive opera-

tion), when vmalloc memory is freed it is typically instead added to the

[purge_vmap_area_list](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n727) and only freed when either the number of entries on

the list reaches the [lazy_max_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1684) threshold, or vmalloc space is exhausted.

Both ultimately invoke [\_\_purge_vmap_area_lazy()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1708) to actually purge the blocks.

We examine the core [\_\_alloc_vmap_area()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1476) in Listing 3-45.



1471 */\**

1472 *\* Returns a start address of the newly allocated area, if success.* 1473 *\* Otherwise a vend is returned that indicates failure.* 1474 *\*/*

1475 **static \_\_always_inline unsigned long** 1476 **\_\_alloc_vmap_area**(**struct** rb_root \*root, **struct** list_head \*head, 1477 **unsigned long** size, **unsigned long** align, 1478 **unsigned long** vstart, **unsigned long** vend) 1479 {

1480 **bool** adjust_search_size = **true**; 1481 **unsigned long** nva_start_addr; 1482 **struct** vmap_area \*va; 1483 **int** ret;

1484

1485 */\**

1486 *\* Do not adjust when:* 1487 *\** *a) align \<= PAGE_SIZE, because it does not make any sense.* 1488 *\** *All blocks(their start addresses) are at least PAGE_SIZE* 1489 *\** *aligned anyway;* 1490 *\** *b) a short range where a requested size corresponds to exactly* 1491 *\** *specified \[vstart:vend\] interval and an alignment \> PAGE_SIZE.* 1492 *\** *With adjusted search length an allocation would not succeed.* 1493 *\*/*







1494 **if** (align \<= **PAGE_SIZE** \|\| (align \> **PAGE_SIZE** && (vend - vstart) ==

size))

1495 adjust_search_size = **false**; 1496

1497 va = **find_vmap_lowest_match**(root, size, align, vstart,

adjust_search_size);

1498 **if** (**unlikely**(!va)) 1499 **return** vend; 1500

1501 **if** (va-\>va_start \> vstart) 1502 nva_start_addr = **ALIGN**(va-\>va_start, align); 1503 **else**

1504 nva_start_addr = **ALIGN**(vstart, align); 1505

1506 */\* Check the "vend" restriction. \*/* 1507 **if** (nva_start_addr + size \> vend) 1508 **return** vend; 1509

1510 */\* Update the free vmap_area. \*/* 1511 ret = **adjust_va_to_fit_type**(root, head, va, nva_start_addr, size); 1512 **if** (**WARN_ON_ONCE**(ret)) 1513 **return** vend; 1514

1515 **\#if DEBUG_AUGMENT_LOWEST_MATCH_CHECK** 1516 **find_vmap_lowest_match_check**(size, align); 1517 **\#endif**

1518

1519 **return** nva_start_addr; 1520 }



*Listing 3-45:* mm/vmalloc.c: [*\_\_alloc_vmap_area()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1476)



This function starts by determining whether the search size can be ad-

justed, as determined by adjust_search_size. As the comment says, only a sub page-sized alignment or one that fits precisely in the specified range would result in this being disabled.

Next, it invokes [find_vmap_lowest_match()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1236)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1236) which is the workhorse of this

function. Note that we invoke this function without specifying the upper bound, so we’ll need to check this afterwards. This finds the first free block that fulfils size and alignment requirements. If we can’t, we exit early by re-turning vend.

Once we have determined the first free block, we set nva_start_addr to

the largest of vstart and the returned va-\>va_start aligned as needed. Note that we ensure that the returned block will have an address greater than or

equal to vstart because [is_within_this_va()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1210), called by [find_vmap_lowest_match()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1236)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1236) explicitly asserts this.

We then perform the deferred check against vend using this start address

and exit returning vend to indicate failure if we exceed this.







The only remaining task (excluding an out of scope debug check) is

[adjust_va_to_fit_type()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1372), which adjusts the free vmalloc space to account for

the allocation.

We examine [find_vmap_lowest_match()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1236) in Listing 3-46.



*/\**

*\* Find the first free block(lowest start address) in the tree, \* that will accomplish the request corresponding to passing \* parameters. Please note, with an alignment bigger than PAGE_SIZE, \* a search length is adjusted to account for worst case alignment \* overhead.*

*\*/*

**static \_\_always_inline struct** vmap_area \*

**find_vmap_lowest_match**(**struct** rb_root \*root, **unsigned long** size,

**unsigned long** align, **unsigned long** vstart, **bool** adjust_search_size)

{

**struct** vmap_area \*va;

**struct** rb_node \*node;

**unsigned long** length;



*/\* Start from the root. \*/*

node = root-\>rb_node;



*/\* Adjust the search size for alignment overhead. \*/*

length = adjust_search_size ? size + align - 1 : size;



**while** (node) {

va = **rb_entry**(node, **struct** vmap_area, rb_node);



**if** (**get_subtree_max_size**(node-\>rb_left) \>= length &&

vstart \< va-\>va_start) {

node = node-\>rb_left;

} **else** {

**if** (**is_within_this_va**(va, size, align, vstart))

**return** va;



*/\**

*\* Does not make sense to go deeper towards the right*

*\* sub-tree if it does not have a free block that is*

*\* equal or bigger to the requested search length.*

*\*/*

**if** (**get_subtree_max_size**(node-\>rb_right) \>= length) {

node = node-\>rb_right;

**continue**;

}



*/\**

*\* OK. We roll back and find the first right sub-tree,*







*\* that will satisfy the search criteria. It can happen \* due to "vstart" restriction or an alignment overhead \* that is bigger then PAGE_SIZE.*

*\*/*

**while** ((node = **rb_parent**(node))) {

va = **rb_entry**(node, **struct** vmap_area, rb_node); **if** (**is_within_this_va**(va, size, align, vstart))

**return** va;



**if** (**get_subtree_max_size**(node-\>rb_right) \>= length &&

vstart \<= va-\>va_start) {

*/\**

*\* Shift the vstart forward. Please note, we update it*

*with*

*\* parent's start address adding "1" because we do not*

*want*

*\* to enter same sub-tree after it has already been*

*checked*

*\* and no suitable free block found there.*

*\*/*

vstart = va-\>va_start + 1;

node = node-\>rb_right;

**break**;

}

}

}

}



**return NULL**;

}



*Listing 3-46:* mm/vmalloc.c: [*find_vmap_lowest_match()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1236)



This walks the red/black search tree using the twin workhorses of

[get_subtree_max_size()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n770) (which safely accesses the subtree_max_size field of the

node’s [struct vmap_area](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmalloc.h?h=v6.0#n62) object) and [is_within_this_va()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1210) which determines whether the node can contain our aligned size requirements, which we ex-

amine in Listing 3-47.



1209 **static \_\_always_inline bool** 1210 **is_within_this_va**(**struct** vmap_area \*va, **unsigned long** size, 1211 **unsigned long** align, **unsigned long** vstart) 1212 {

1213 **unsigned long** nva_start_addr; 1214

1215 **if** (va-\>va_start \> vstart) 1216 nva_start_addr = **ALIGN**(va-\>va_start, align); 1217 **else**

1218 nva_start_addr = **ALIGN**(vstart, align);







1219

1220 */\* Can be overflowed due to big size or alignment. \*/* 1221 **if** (nva_start_addr + size \< nva_start_addr \|\| 1222 nva_start_addr \< vstart) 1223 **return false**; 1224

1225 **return** (nva_start_addr + size \<= va-\>va_end); 1226 }



*Listing 3-47:* mm/vmalloc.c: [*is_within_this_va()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1210)



**N O T E** As the comment states, this function takes special care to avoid underflow or overflow

in the case of being supplied an overly large size or alignment.



The [find_vmap_lowest_match()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1236) function walks through the tree, finding

the left-most node whose subtree max size is greater than or equal to the

required length. Thinking back to the binary search tree invariant, all nodes

on the left will be located at a lower address than all of those on the right.

Therefore, we are locating the smallest possible entry in the address space.

If we don’t have a smaller left-hand subtree, we first check to see if this

node can satisfy our requirements. If not, we check to see if the right node

can satisfy us. In most cases it should, as logically it will certainly have suffi-

cient subtree size, however it may fail to do so because of alignment reasons

(potentially causing us to underflow vstart).

In this case we have to perform some backtracking, going through each

parent node, checking to see if it fulfils our requirements and if not, we try

to previously unexamined right sub-node, resetting vstart to set a lower-most

bound to indicate that we have examined all values at or below it.

It is clear then that we allocate using a simple first-fit algorithm. This

keeps vmalloc simple and relatively fast to use, and on modern hardware is a

entirely reasonable trade-off as the amount of available virtual address space

is far in excess of what you would ever need to allocate from it so fragmenta-

tion should not present a significant problem (for modern 64-bit hardware

virtual address space is abundant; it is the physical memory that is scarce).

Finally, once we have discovered a [struct vmap_area](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmalloc.h?h=v6.0#n62) free block that is suf-

ficiently large to contain our requirements from find_vmap_lowest_match(),

[\_\_alloc_vmap_area()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1476) calls [adjust_va_to_fit_type()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1372) to extract only what is re-

quired from the free block and adjust it as required, as shown in Listing 3-48.



**static \_\_always_inline int**

**adjust_va_to_fit_type**(**struct** rb_root \*root, **struct** list_head \*head,

**struct** vmap_area \*va, **unsigned long** nva_start_addr, **unsigned long** size)

{

**struct** vmap_area \*lva = **NULL**;

**enum** fit_type type = **classify_va_fit_type**(va, nva_start_addr, size);



**if** (type == **FL_FIT_TYPE**) {







*/\**

*\* No need to split VA, it fully fits.*

*\**

*\* \|* *\|*

*\* V* *NVA* *V*

*\* \|---------------\|*

*\*/*

**unlink_va_augment**(va, root); **kmem_cache_free**(vmap_area_cachep, va);

} **else if** (type == **LE_FIT_TYPE**) {

*/\**

*\* Split left edge of fit VA.*

*\**

*\* \|* *\|*

*\* V NVA V* *R*

*\* \|-------\|-------\|*

*\*/*

va-\>va_start += size;

} **else if** (type == **RE_FIT_TYPE**) {

*/\**

*\* Split right edge of fit VA.*

*\**

*\** *\|* *\|*

*\** *L* *V NVA V*

*\* \|-------\|-------\|*

*\*/*

va-\>va_end = nva_start_addr;

} **else if** (type == **NE_FIT_TYPE**) {

*/\**

*\* Split no edge of fit VA.*

*\**

*\** *\|* *\|*

*\** *L V NVA V R*

*\* \|---\|-------\|---\|*

*\*/*

lva = **\_\_this_cpu_xchg**(ne_fit_preload_node, **NULL**); **if** (**unlikely**(!lva)) {

*/\**

*\* For percpu allocator we do not do any pre-allocation \* and leave it as it is. The reason is it most likely*

*\* never ends up with NE_FIT_TYPE splitting. In case of \* percpu allocations offsets and sizes are aligned to*

*\* fixed align request, i.e. RE_FIT_TYPE and FL_FIT_TYPE \* are its main fitting cases.*

*\**

*\* There are a few exceptions though, as an example it is \* a first allocation (early boot up) when we have "one"*







*\* big free space that has to be split.*

*\**

*\* Also we can hit this path in case of regular "vmap"*

*\* allocations, if "this" current CPU was not preloaded. \* See the comment in alloc_vmap_area() why. If so, then \* GFP_NOWAIT is used instead to get an extra object for \* split purpose. That is rare and most time does not*

*\* occur.*

*\**

*\* What happens if an allocation gets failed. Basically, \* an "overflow" path is triggered to purge lazily freed \* areas to free some memory, then, the "retry" path is \* triggered to repeat one more time. See more details*

*\* in alloc_vmap_area() function.*

*\*/*

lva = **kmem_cache_alloc**(vmap_area_cachep, GFP_NOWAIT); **if** (!lva)

**return**-1;

}



*/\**

*\* Build the remainder.*

*\*/*

lva-\>va_start = va-\>va_start;

lva-\>va_end = nva_start_addr;



*/\**

*\* Shrink this VA to remaining size.*

*\*/*

va-\>va_start = nva_start_addr + size;

} **else** {

**return**-1;

}



**if** (type != **FL_FIT_TYPE**) {

**augment_tree_propagate_from**(va);



**if** (lva) */\* type == NE_FIT_TYPE \*/*

**insert_vmap_area_augment**(lva, &va-\>rb_node, root, head);

}



**return** 0;

}



*Listing 3-48:* mm/vmalloc.c: [*adjust_va_to_fit_type()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1372)

The comments here are excellent and give a good idea as to what is going

on. First, they classify the type of fit via [enum fit_type](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1337), shown in Listing 3-49.







1337 **enum** fit_type {

1338 **NOTHING_FIT** = 0,

1339 **FL_FIT_TYPE** = 1, */\* full fit \*/* 1340 **LE_FIT_TYPE** = 2, */\* left edge fit \*/* 1341 **RE_FIT_TYPE** = 3, */\* right edge fit \*/* 1342 **NE_FIT_TYPE** = 4 */\* no edge fit \*/* 1343 };



*Listing 3-49:* mm/vmalloc.c: [*enum fit_type*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1337)

These are:



**NOTHING_FIT** No fit at all.

**FL_FIT_TYPE** The required block fits perfectly into the free one (that is,

they are of identical size and alignment).

**LE_FIT_TYPE** The free block has some excess space to its ‘right’ (at higher

addresses), but the left fits perfectly.

**RE_FIT_TYPE** The free block has some excess space to its ‘left’ (at lower

addresses), but the right fits perfectly.

**NE_FIT_TYPE** The required block fits within the free block, but it leaves

“gaps” at either side.



The logic that performs this classification is defined in

[classify_va_fit_type(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1346)shown in Listing 3-50.



1345 **static \_\_always_inline enum** fit_type 1346 **classify_va_fit_type**(**struct** vmap_area \*va, 1347 **unsigned long** nva_start_addr, **unsigned long** size) 1348 {

1349 **enum** fit_type type; 1350

1351 */\* Check if it is within VA. \*/* 1352 **if** (nva_start_addr \< va-\>va_start \|\| 1353 nva_start_addr + size \> va-\>va_end) 1354 **return NOTHING_FIT**; 1355

1356 */\* Now classify. \*/* 1357 **if** (va-\>va_start == nva_start_addr) { 1358 **if** (va-\>va_end == nva_start_addr + size) 1359 type = **FL_FIT_TYPE**; 1360 **else**

1361 type = **LE_FIT_TYPE**; 1362 } **else if** (va-\>va_end == nva_start_addr + size) { 1363 type = **RE_FIT_TYPE**; 1364 } **else** {

1365 type = **NE_FIT_TYPE**; 1366 }

1367







1368 **return** type;

1369 }



*Listing 3-50:* mm/vmalloc.c: [*classify_va_fit_type()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1346)



Once we’ve classified the kind of fit, this indicates what we need to do. If

it is a NOTHING_FIT, we simply error out: for LE_FIT_TYPE or RE_FIT_TYPE we need

only adjust the va_start and va_end fields of the free block, respectively. In

each of these cases, no nodes need be removed or added.

In the case of FL_FIT_TYPE we simply remove the node from the tree via

[unlink_va_augment()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n991) and free the area altogether via [kmem_cache_free()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/slub.c?h=v6.0#n3550)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/slub.c?h=v6.0#n3550)

In the case of NE_FIT_TYPE we need to allocate a new block to describe one

of the two separate free blocks, which we achieve using an optimization—

trying to obtain the block from a per-CPU value [ne_fit_preload_node](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n761),

which is populated via [preload_this_cpu_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1543), which in turn is invoked by

[alloc_vmap_area()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1569) on each allocation attempt. The newly allocated block is

assigned as the ‘left’ block and the existing one is truncated to be the ‘right’

block.

Finally, for all cases other than FL_FIT_TYPE, the tree is updated such that

subtree_max_size values are recalculated via [augment_tree_propagate_from()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1051)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1051) and

if a new node was added, it is inserted via [insert_vmap_area_augment()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1078).



***3.5.2 Inserting a Newly Allocated Block***

Finally, we can look to the final step in [alloc_vmap_area()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1569)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1569) invoking

[insert_vmap_area()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1066) on the newly allocated vmap area, shown in Listing 3-51.



1065 **static void**

1066 **insert_vmap_area**(**struct** vmap_area \*va, 1067 **struct** rb_root \*root, **struct** list_head \*head) 1068 {

1069 **struct** rb_node \*\*link; 1070 **struct** rb_node \*parent; 1071

1072 link = **find_va_links**(va, root, **NULL**, &parent); 1073 **if** (link)

1074 **link_va**(va, root, parent, link, head); 1075 }



*Listing 3-51:* mm/vmalloc.c: [*insert_vmap_area()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n1066)



We’ll gloss over [link_va()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n953) here as it essentially uses the kernel’s red/black

tree library code to insert a node into the tree (as well as adding it to the

node list). Instead we’ll focus on [find_va_links()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n848), which finds the location

at which to insert the node, returning a pointer to the parent node’s free left

or right node as well as the parent node itself, shown in Listing 3-52.



839 */\**

840 *\* This function returns back addresses of parent node* 841 *\* and its left or right link for further processing.*







842 *\**

843 *\* Otherwise NULL is returned. In that case all further* 844 *\* steps regarding inserting of conflicting overlap range* 845 *\* have to be declined and actually considered as a bug.* 846 *\*/*

847 **static \_\_always_inline struct** rb_node \*\* 848 **find_va_links**(**struct** vmap_area \*va, 849 **struct** rb_root \*root, **struct** rb_node \*from, 850 **struct** rb_node \*\*parent) 851 {

852 **struct** vmap_area \*tmp_va; 853 **struct** rb_node \*\*link; 854

855 **if** (root) {

856 link = &root-\>rb_node; 857 **if** (**unlikely**(!\*link)) { 858 \*parent = **NULL**; 859 **return** link; 860 }

861 } **else** {

862 link = &from; 863 }

864

865 */\**

866 *\* Go to the bottom of the tree. When we hit the last point* 867 *\* we end up with parent rb_node and correct direction, i name* 868 *\* it link, where the new va-\>rb_node will be attached to.* 869 *\*/*

870 **do** {

871 tmp_va = **rb_entry**(\*link, **struct** vmap_area, rb_node); 872

873 */\**

874 *\* During the traversal we also do some sanity check.* 875 *\* Trigger the BUG() if there are sides(left/right)* 876 *\* or full overlaps.* 877 *\*/*

878 **if** (va-\>va_end \<= tmp_va-\>va_start) 879 link = &(\*link)-\>rb_left; 880 **else if** (va-\>va_start \>= tmp_va-\>va_end) 881 link = &(\*link)-\>rb_right; 882 **else** {

883 **WARN**(1, "vmalloc bug: 0x%lx-0x%lx overlaps with 0x%lx

-0x%lx\n",

884 va-\>va_start, va-\>va_end, tmp_va-\>va_start,

tmp_va-\>va_end);

885

886 **return NULL**;







887 }

888 } **while** (\*link);

889

890 \*parent = &tmp_va-\>rb_node; 891 **return** link;

892 }



*Listing 3-52:* mm/vmalloc.c: [*find_va_links()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n848)



If the root argument is specified, then we begin our search here, check

that there is at least one node, exiting if not. Otherwise, we begin from from.

The logic then simply loops through nodes, moving left if that node is

after the end of the one being inserted, or right otherwise (with a check to

ensure that no buggy vmalloc implementation has led to unexpected over-

laps) and ending once we have a pointer to an empty pointer either in left or

right of the parent before returning it.



***3.5.3 Physical Allocation***

The final part of [\_\_vmalloc_node_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3111) allocates and maps underlying phys-

ical memory via [\_\_vmalloc_area_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2988). This function is parameterized by

gfp_mask, which defines how physical pages will be allocated, and prot, which

defines the page table flags, so the caller has complete control over how

these pages are mapped in.

Let’s examine the first part of this function in Listing 3-53.



2988 **static void** \***\_\_vmalloc_area_node**(**struct** vm_struct \*area, **gfp_t** gfp_mask, 2989 **pgprot_t** prot, **unsigned int** page_shift, 2990 **int** node) 2991 {

2992 **const gfp_t** nested_gfp = (gfp_mask & **GFP_RECLAIM_MASK**) \| **\_\_GFP_ZERO**; 2993 **bool** nofail = gfp_mask & **\_\_GFP_NOFAIL**; 2994 **unsigned long** addr = (**unsigned long**)area-\>addr; 2995 **unsigned long** size = **get_vm_area_size**(area); 2996 **unsigned long** array_size; 2997 **unsigned int** nr_small_pages = size \>\> **PAGE_SHIFT**; 2998 **unsigned int** page_order; 2999 **unsigned int** flags; 3000 **int** ret;

3001

3002 array_size = (**unsigned long**)nr_small_pages \* **sizeof**(**struct** page \*); 3003 gfp_mask \|= **\_\_GFP_NOWARN**; 3004 **if** (!(gfp_mask & (**GFP_DMA** \| **GFP_DMA32**))) 3005 gfp_mask \|= **\_\_GFP_HIGHMEM**; 3006

3007 */\* Please note that the recursion is strictly bounded. \*/* 3008 **if** (array_size \> **PAGE_SIZE**) { 3009 area-\>pages = **\_\_vmalloc_node**(array_size, 1, nested_gfp, node, 3010 area-\>caller);







3011 } **else** {

3012 area-\>pages = **kmalloc_node**(array_size, nested_gfp, node); 3013 }

3014

3015 **if** (!area-\>pages) { 3016 **warn_alloc**(gfp_mask, **NULL**, 3017 "vmalloc error: size %lu, failed to allocated page

array size %lu",

3018 nr_small_pages \* **PAGE_SIZE**, array_size); 3019 **free_vm_area**(area); 3020 **return NULL**; 3021 }



*Listing 3-53:* mm/vmalloc.c: [*\_\_vmalloc_area_node()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2988) *preface*



We start by determining how many base pages will be need to be allo-

cated via [get_vm_area_size()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmalloc.h?h=v6.0#n198)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmalloc.h?h=v6.0#n198) which obtains the area’s size less the guard page,

shown in Listing 3-54.



198 **static inline size_t get_vm_area_size**(**const struct** vm_struct \*area) 199 {

200 **if** (!(area-\>flags & **VM_NO_GUARD**)) 201 */\* return actual size without guard page \*/* 202 **return** area-\>size -**PAGE_SIZE**; 203 **else**

204 **return** area-\>size; 205

206 }



*Listing 3-54:* include/linux/vmalloc.h: [*get_vm_area_size()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmalloc.h?h=v6.0#n198)



Returning to [\_\_vmalloc_area_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2988), we then focus on allocating

the array that contains the pointers to [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72)s to be placed in the

[struct vm_struct-\>pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmalloc.h?h=v6.0#n48) field. If we require less than a page of them, we use

the slab allocator via [kmalloc_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/slab.h?h=v6.0#n608)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/slab.h?h=v6.0#n608) otherwise we perform a nested vmal-loc allocation for the pages with the \_\_GFP_ZERO flag set to zero them via

[\_\_vmalloc_node(). ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n3258)If either of these fail, we raise an error, clean up, and re-turn NULL. We also specify that no warnings should be reported on allocation via \_\_GFP_NOWARN, and set \_\_GFP_HIGHMEM if no DMA flags are set, however this is not relevant to 64-bit architectures. Next, we physically allocate the pages, as

shown in Listing 3-55.



3023 **set_vm_area_page_order**(area, page_shift -**PAGE_SHIFT**); 3024 page_order = **vm_area_page_order**(area); 3025

3026 area-\>nr_pages = **vm_area_alloc_pages**(gfp_mask \| **\_\_GFP_NOWARN**, 3027 node, page_order, nr_small_pages, area-\>pages); 3028

3029 **atomic_long_add**(area-\>nr_pages, &nr_vmalloc_pages); 3030 **if** (gfp_mask & **\_\_GFP_ACCOUNT**) {







3031 **int** i;

3032

3033 **for** (i = 0; i \< area-\>nr_pages; i++) 3034 **mod_memcg_page_state**(area-\>pages\[i\], **MEMCG_VMALLOC**, 1)

;

3035 }

3036

3037 */\**

3038 *\* If not enough pages were obtained to accomplish an* 3039 *\* allocation request, free them via \_\_vfree() if any.* 3040 *\*/*

3041 **if** (area-\>nr_pages != nr_small_pages) { 3042 **warn_alloc**(gfp_mask, **NULL**, 3043 "vmalloc error: size %lu, page order %u, failed to

allocate pages",

3044 area-\>nr_pages \* **PAGE_SIZE**, page_order); 3045 **goto fail**; 3046 }



*Listing 3-55:* mm/vmalloc.c: [*\_\_vmalloc_area_node()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2988) *physical allocation*



We set the [struct vm_struct-\>page_order](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmalloc.h?h=v6.0#n48) field via [set_vm_area_page_order()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2280)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2280)

which asserts that the order is either zero unless if huge allocations are per-

mitted. The actual allocation is performed via [vm_area_alloc_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2897) (to be

covered in Listing 3-57) after which we perform some cgroup accounting

and check to ensure that the allocation succeeded, exiting and indicating

failure if not.

Finally, we map the memory, as shown in Listing 3-56.



3048 */\**

3049 *\* page tables allocations ignore external gfp mask, enforce it* 3050 *\* by the scope API* 3051 *\*/*

3052 **if** ((gfp_mask & (**\_\_GFP_FS** \| **\_\_GFP_IO**)) == **\_\_GFP_IO**) 3053 flags = **memalloc_nofs_save**(); 3054 **else if** ((gfp_mask & (**\_\_GFP_FS** \| **\_\_GFP_IO**)) == 0) 3055 flags = **memalloc_noio_save**(); 3056

3057 **do** {

3058 ret = **vmap_pages_range**(addr, addr + size, prot, area-\>pages, 3059 page_shift); 3060 **if** (nofail && (ret \< 0)) 3061 **schedule_timeout_uninterruptible**(1); 3062 } **while** (nofail && (ret \< 0)); 3063

3064 **if** ((gfp_mask & (**\_\_GFP_FS** \| **\_\_GFP_IO**)) == **\_\_GFP_IO**) 3065 **memalloc_nofs_restore**(flags); 3066 **else if** ((gfp_mask & (**\_\_GFP_FS** \| **\_\_GFP_IO**)) == 0) 3067 **memalloc_noio_restore**(flags);







3068

3069 **if** (ret \< 0) {

3070 **warn_alloc**(gfp_mask, **NULL**, 3071 "vmalloc error: size %lu, failed to map pages", 3072 area-\>nr_pages \* **PAGE_SIZE**); 3073 **goto** fail; 3074 }

3075

3076 **return** area-\>addr; 3077

3078 fail:

3079 **\_\_vfree**(area-\>addr); 3080 **return NULL**;

3081 }



*Listing 3-56:* mm/vmalloc.c: [*\_\_vmalloc_area_node()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2988) *virtual mapping*



We start by ensuring that \_\_GFP_FS and \_\_GFP_IO flags are honored

throughout mapping before performing the actual mapping itself via

[vmap_pages_range() , ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n616)retry the mapping if \_\_GFP_NOFAIL was set by the user, warning and failing if the allocation fails and returning the newly mapped virtual address if it did not.

Let’s dive into how physical allocation is performed in

[vm_area_alloc_pages() , ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2897)starting with examining the initial portion of this func-

tion in Listing 3-57.



**static inline unsigned int**

**vm_area_alloc_pages**(**gfp_t** gfp, **int** nid,

**unsigned int** order, **unsigned int** nr_pages, **struct** page \*\*pages)

{

**unsigned int** nr_allocated = 0;

**struct** page \*page;

**int** i;



*/\**

*\* For order-0 pages we make use of bulk allocator, if*

*\* the page array is partly or not at all populated due \* to fails, fallback to a single page allocator that is \* more permissive.*

*\*/*

**if** (!order) {

**gfp_t** bulk_gfp = gfp & ~**\_\_GFP_NOFAIL**;



**while** (nr_allocated \< nr_pages) {

**unsigned int** nr, nr_pages_request;



*/\**

*\* A maximum allowed request is hard-coded and is 100*

*\* pages per call. That is done in order to prevent a*







*\* long preemption off scenario in the bulk-allocator*

*\* so the range is \[1:100\].*

*\*/*

nr_pages_request = **min**(100U, nr_pages - nr_allocated);



*/\* memory allocation should consider mempolicy, we can't*

*\* wrongly use nearest node when nid == NUMA_NO_NODE,*

*\* otherwise memory may be allocated in only one node,*

*\* but mempolicy wants to alloc memory by interleaving. \*/*

**if** (**IS_ENABLED**(**CONFIG_NUMA**) && nid == **NUMA_NO_NODE**)

nr = **alloc_pages_bulk_array_mempolicy**(bulk_gfp,

nr_pages_request,

pages + nr_allocated);



**else**

nr = **alloc_pages_bulk_array_node**(bulk_gfp, nid,

nr_pages_request,

pages + nr_allocated);



nr_allocated += nr;

**cond_resched**();



*/\**

*\* If zero or pages were obtained partly,*

*\* fallback to a single page allocator.*

*\*/*

**if** (nr != nr_pages_request)

**break**;

}

}



*Listing 3-57:* mm/vmalloc.c: [*vm_area_alloc_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2897) *preface and order-0 allocation*



If the allocations are of order-0 pages, then we simply allo-

cate the pages in bulk using the physical memory allocate via

[alloc_pages_bulk_array_mempolicy()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mempolicy.c?h=v6.0#n2349) if NUMA is enabled and no specific node

is specified, or [alloc_pages_bulk_array_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n225) otherwise. These allow for a

lock to be shared for the whole operation and therefore allocates pages

more efficiently.

We choose to allocate in batches of up to 100 pages to avoid spending

too long in the page allocator and thus risk blocking.

If the allocation fails (we are not allocated the number of pages we need),

then we fall through to the code used for higher order pages where we allo-

cate a page at a time as a fallback, shown in Listing 3-58.



2951 */\* High-order pages or fallback path if "bulk" fails. \*/* 2952

2953 **while** (nr_allocated \< nr_pages) {







2954 **if** (**fatal_signal_pending**(current)) 2955 **break**; 2956

2957 **if** (nid == **NUMA_NO_NODE**) 2958 page = **alloc_pages**(gfp, order); 2959 **else**

2960 page = **alloc_pages_node**(nid, gfp, order); 2961 **if** (**unlikely**(!page)) 2962 **break**; 2963 */\**

2964 *\* Higher order allocations must be able to be treated as*

2965 *\* indepdenent small pages by callers (as they can with* 2966 *\* small-page vmallocs). Some drivers do their own refcounting*

2967 *\* on vmalloc_to_page() pages, some use page-\>mapping,* 2968 *\* page-\>lru, etc.* 2969 *\*/*

2970 **if** (order) 2971 **split_page**(page, order); 2972

2973 */\**

2974 *\* Careful, we allocate and map page-order pages, but* 2975 *\* tracking is done per PAGE_SIZE page so as to keep the* 2976 *\* vm_struct APIs independent of the physical/mapped size.*

2977 *\*/*

2978 **for** (i = 0; i \< (1U \<\< order); i++) 2979 pages\[nr_allocated + i\] = page + i; 2980

2981 **cond_resched**(); 2982 nr_allocated += 1U \<\< order; 2983 }

2984

2985 **return** nr_allocated; 2986 }



*Listing 3-58:* mm/vmalloc.c: [*vm_area_alloc_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2897) *higher order allocation*



After checking to see if we are possibly blocking a fatal signal via

[fatal_signal_pending(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/signal.h?h=v6.0#n408)we allocate a single page directly either via

[alloc_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mempolicy.c?h=v6.0#n2252) if no node is specified, or [alloc_pages_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n260) if one is.

Since we do not set the \_\_GFP_COMP flag when allocating, the page is not

marked compound even if higher order. Therefore, we use [split_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3585) to set the reference count for each individual page and thus establish them as single pages.

The pages array is then filled with the allocated pages and the number of

allocations returned.







***3.5.4 Virtual Mapping***

The key vmalloc mapping code is implemented in [vmap_pages_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n616) as in-

voked by [\_\_vmalloc_area_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2988) (shown in Listing 3-56), as well as [vm_map_ram()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2230)

and [vmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2812)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2812)

We examine this function in Listing 3-59.



604 */\*\**

605 *\* vmap_pages_range - map pages to a kernel virtual address* 606 *\* @addr: start of the VM area to map* 607 *\* @end: end of the VM area to map (non-inclusive)* 608 *\* @prot: page protection flags to use* 609 *\* @pages: pages to map (always PAGE_SIZE pages)* 610 *\* @page_shift: maximum shift that the pages may be mapped with, @pages must*

611 *\* be aligned and contiguous up to at least this shift.* 612 *\**

613 *\* RETURNS:*

614 *\* 0 on success, -errno on failure.* 615 *\*/*

616 **static int vmap_pages_range**(**unsigned long** addr, **unsigned long** end, 617 **pgprot_t** prot, **struct** page \*\*pages, **unsigned int** page_shift) 618 {

619 **int** err;

620

621 err = **vmap_pages_range_noflush**(addr, end, prot, pages, page_shift); 622 **flush_cache_vmap**(addr, end); 623 **return** err;

624 }



*Listing 3-59:* mm/vmalloc.c: [*vmap_pages_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n616)



This performs the core mapping logic in [vmap_pages_range_noflush()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n578) be-

fore flushing memory caches for the range via flush_cache_vmap() if the ar-

chitecture requires it (this is a no-op on x86-64 and arm64). We examine

[vmap_pages_range_noflush()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n578) in Listing 3-60.



578 **int vmap_pages_range_noflush**(**unsigned long** addr, **unsigned long** end, 579 **pgprot_t** prot, **struct** page \*\*pages, **unsigned int** page_shift) 580 {

581 **unsigned int** i, nr = (end - addr) \>\> **PAGE_SHIFT**;

582

583 **WARN_ON**(page_shift \< **PAGE_SHIFT**);

584

585 **if** (!**IS_ENABLED**(**CONFIG_HAVE_ARCH_HUGE_VMALLOC**) \|\| 586 page_shift == **PAGE_SHIFT**) 587 **return vmap_small_pages_range_noflush**(addr, end, prot, pages);

588

589 **for** (i = 0; i \< nr; i += 1U \<\< (page_shift -**PAGE_SHIFT**)) { 590 **int** err;

591







592 err = **vmap_range_noflush**(addr, addr + (1UL \<\< page_shift), 593 **\_\_pa**(**page_address**(pages\[i\])), prot, 594 page_shift); 595 **if** (err)

596 **return** err; 597

598 addr += 1UL \<\< page_shift; 599 }

600

601 **return** 0;

602 }



*Listing 3-60:* mm/vmalloc.c: [*vmap_pages_range_noflush()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n578)



If the architecture doesn’t support huge pages or huge

pages have not been used, then the mapping is performed by

[vmap_small_pages_range_noflush()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n542). Otherwise, each individual page is mapped

via [vmap_range_noflush()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n286).

For brevity, we’ll examine [vmap_small_pages_range_noflush()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n542) only in Listing

3-61.



542 **static int vmap_small_pages_range_noflush**(**unsigned long** addr, **unsigned long**

end,

543 **pgprot_t** prot, **struct** page \*\*pages) 544 {

545 **unsigned long** start = addr; 546 **pgd_t** \*pgd;

547 **unsigned long** next; 548 **int** err = 0;

549 **int** nr = 0;

550 pgtbl_mod_mask mask = 0; 551

552 **BUG_ON**(addr \>= end); 553 pgd = **pgd_offset_k**(addr); 554 **do** {

555 next = **pgd_addr_end**(addr, end); 556 **if** (**pgd_bad**(\*pgd)) 557 mask \|= **PGTBL_PGD_MODIFIED**; 558 err = **vmap_pages_p4d_range**(pgd, addr, next, prot, pages, &nr,

&mask);

559 **if** (err)

560 **return** err; 561 } **while** (pgd++, addr = next, addr != end); 562

563 **if** (mask & **ARCH_PAGE_TABLE_SYNC_MASK**) 564 **arch_sync_kernel_mappings**(start, end); 565

566 **return** 0;

567 }







*Listing 3-61:* mm/vmalloc.c: [*vmap_small_pages_range_noflush()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n542)



This follows a similar pattern through each page table level, keeping

track of which page table entries have been updated via mask. Each invoca-

tion of the pXd_addr_end() function retrieves the virtual address associated

with the next boundary at that level (in this case, the next PGD entry).

One difference at this level is that, for architectures that require it,

[arch_sync_kernel_mappings()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n263) is invoked when an update has occurred that

requires it. For x86-64 this isn’t necessary because during initialization

[preallocate_vmalloc_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n1285) is called to ensure that the shared page table en-

tries that span the vmalloc space are correctly allocated from which all pro-

cess page tables are derived.

We examine [vmap_pages_p4d_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n524) in Listing 3-62.



524 **static int vmap_pages_p4d_range**(**pgd_t** \*pgd, **unsigned long** addr, 525 **unsigned long** end, **pgprot_t** prot, **struct** page \*\*pages, **int** \*nr

,

526 pgtbl_mod_mask \*mask) 527 {

528 **p4d_t** \*p4d;

529 **unsigned long** next;

530

531 p4d = **p4d_alloc_track**(&init_mm, pgd, addr, mask); 532 **if** (!p4d)

533 **return**-**ENOMEM**; 534 **do** {

535 next = **p4d_addr_end**(addr, end); 536 **if** (**vmap_pages_pud_range**(p4d, addr, next, prot, pages, nr,

mask))

537 **return**-**ENOMEM**; 538 } **while** (p4d++, addr = next, addr != end); 539 **return** 0;

540 }



*Listing 3-62:* mm/vmalloc.c: [*vmap_pages_p4d_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n524)



This follows a similar pattern except that [p4d_alloc_track()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/pgalloc-track.h?h=v6.0#n6) is used, which

performs the same role as [p4d_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2195)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2195) keeping track of whether the page

table previously shown was modified (as is the case where a new P4D had to

be allocated and thus the PGD entry modified).

The pXd_alloc_track() functions are used for this purpose for all of the

page table levels in order that the arch_sync_kernel_mappings() logic at the top

level can be applied regardless of which level updates trigger this for the ar-

chitecture.

The equivalent function for PUD page table entries is

[vmap_pages_pud_range(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n506)shown in Listing 3-63.



506 **static int vmap_pages_pud_range**(**p4d_t** \*p4d, **unsigned long** addr,







507 **unsigned long** end, **pgprot_t** prot, **struct** page \*\*pages, **int** \*nr

,

508 pgtbl_mod_mask \*mask) 509 {

510 **pud_t** \*pud;

511 **unsigned long** next; 512

513 pud = **pud_alloc_track**(&init_mm, p4d, addr, mask); 514 **if** (!pud)

515 **return**-**ENOMEM**; 516 **do** {

517 next = **pud_addr_end**(addr, end); 518 **if** (**vmap_pages_pmd_range**(pud, addr, next, prot, pages, nr,

mask))

519 **return**-**ENOMEM**; 520 } **while** (pud++, addr = next, addr != end); 521 **return** 0;

522 }



*Listing 3-63:* mm/vmalloc.c: [*vmap_pages_pud_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n506)



The equivalent for PMDs is [vmap_pages_pmd_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n488)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n488) shown in Listing 3-64.



488 **static int vmap_pages_pmd_range**(**pud_t** \*pud, **unsigned long** addr, 489 **unsigned long** end, **pgprot_t** prot, **struct** page \*\*pages, **int** \*nr

,

490 pgtbl_mod_mask \*mask) 491 {

492 **pmd_t** \*pmd;

493 **unsigned long** next; 494

495 pmd = **pmd_alloc_track**(&init_mm, pud, addr, mask); 496 **if** (!pmd)

497 **return**-**ENOMEM**; 498 **do** {

499 next = **pmd_addr_end**(addr, end); 500 **if** (**vmap_pages_pte_range**(pmd, addr, next, prot, pages, nr,

mask))

501 **return**-**ENOMEM**; 502 } **while** (pmd++, addr = next, addr != end); 503 **return** 0;

504 }



*Listing 3-64:* mm/vmalloc.c: [*vmap_pages_pmd_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n488)



These are each broadly equivalent to one another, however

[vmap_pages_pte_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n457) does more, as shown in Listing 3-65.



457 **static int vmap_pages_pte_range**(**pmd_t** \*pmd, **unsigned long** addr,







458 **unsigned long** end, **pgprot_t** prot, **struct** page \*\*pages, **int** \*nr

,

459 **pgtbl_mod_mask** \*mask) 460 {

461 **pte_t** \*pte;

462

463 */\**

464 *\* nr is a running index into the array which helps higher level* 465 *\* callers keep track of where we're up to.* 466 *\*/*

467

468 pte = **pte_alloc_kernel_track**(pmd, addr, mask); 469 **if** (!pte)

470 **return**-**ENOMEM**; 471 **do** {

472 **struct** page \*page = pages\[\*nr\];

473

474 **if** (**WARN_ON**(!**pte_none**(\*pte))) 475 **return**-**EBUSY**; 476 **if** (**WARN_ON**(!page)) 477 **return**-**ENOMEM**; 478 **if** (**WARN_ON**(!**pfn_valid**(**page_to_pfn**(page)))) 479 **return**-**EINVAL**;

480

481 **set_pte_at**(&init_mm, addr, pte, **mk_pte**(page, prot)); 482 (\*nr)++;

483 } **while** (pte++, addr += **PAGE_SIZE**, addr != end); 484 \*mask \|= **PGTBL_PTE_MODIFIED**; 485 **return** 0;

486 }



*Listing 3-65:* mm/vmalloc.c: [*vmap_pages_pte_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n457)



This function differs from the others in that it both allocates the PTE

directory and assigns the PTE entry. We make sure that PTE entries are

empty, that the backing page is assigned, that the proposed PFN is valid, and

we keep track of the number of pages mapped via nr.

The purpose of examining the vmalloc implementation in this level of

detail was not only to provide understanding of how it is implemented, but

also to examine at length how the virtual as well as physical memory is man-

aged.

As the vmalloc uses a simple first-fit allocator (as opposed to the physical

allocator), we will not examine [vfree()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n2764), which more or less follows similar

patterns.



