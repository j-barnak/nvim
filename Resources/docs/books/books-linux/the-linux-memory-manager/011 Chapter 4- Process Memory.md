


**4**



**P R O C E S S M E M O R Y**



We’ve examined how the kernel manages physical and

maps virtual memory. This provides the foundation

upon which to explore arguably the most important

area of the linux memory manager – process memory.

This is the means by which processes allocate, free,

map and unmap memory and importantly, the entire

means by which userland processes interact with mem-

ory.

Given that the kernel’s reason for being is to provide abstractions for

userland, which is another way of saying: provide abstractions for userland

processes, these are therefore the key interfaces to understand in order to

gain a deep understand of memory management as a whole.

We examine a simple userland program which allocates and frees system

memory in Listing 4-1.



**\#include** \<stdio.h\>

**\#include** \<stdlib.h\>

**\#include** \<sys/mman.h\>



**int main**(**void**)

{




**char** \*ptr = **mmap**(**NULL**, 20000, **PROT_READ** \| **PROT_WRITE**,

**MAP_PRIVATE** \| **MAP_ANONYMOUS**, -1, 0);



**if** (ptr == **MAP_FAILED** \|\| **munmap**(ptr, 20000) != 0) {

**perror**("**mmap**"); **return EXIT_FAILURE**;

}



**return EXIT_SUCCESS**;

}



*Listing 4-1:* *Simple use of* *mmap* *and* *munmap*

Note that we use [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) rather than [malloc()](https://man7.org/linux/man-pages/man3/malloc.3.html) as the latter uses a userland

allocator occasionally interacting with the kernel to obtain memory, whereas the former directly maps memory into the userland process which may be

backed by anonymous\* pages allocated by the kernel’s physical allocator. We specify MAP_PRIVATE and MAP_ANONYMOUS flags so we expect to be allocated anony-mous physical pages.

We can use the † /proc/\$pid/smaps procfs interface to observe virtual mem-

ory layout. Examining this for Listing 4-1 after the mmap() call which in this

instance has returned a pointer to 0x7ffff7fbf000, as shown in Listing 4-4.



\$ **cat** /proc/\$PID/smaps



**7ffff7fbf000-7ffff7fc4000** rw-p 00000000 00:00 0 Size: 20 kB



**Rss:** **0 kB**



*Listing 4-2:* */proc/\$PID/smaps* *output after* *mmap()* *of* *0x7ffff7fbf000*

We can see that the memory region containing our pointer is present,

but there is something odd going on here – ‘RSS’ is short for ‘Resident Set Size’ which indicates how much memory is actually allocated, but it reports 0 bytes, i.e. nothing has been allocated (note that the requested 20,000 bytes was page-aligned to 20 KiB i.e. 20,480 bytes). What is going on?

Answering in two parts – firstly what exactly are /proc/\$pid/smaps re-

ferring to if not actual page tables and physical pages? The answer are Virtual Memory Areas (VMAs) – these are blocks of contiguous memory which share characteristics (e.g. permissions, flags, etc.) described by the

[struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) type.

Secondly, and more importantly, how can memory be allocated from

userland’s perspective but neither allocated nor mapped from the kernel’s? The answer arises from the fact that the kernel gets to decide what happens when hardware page faults occurs. Page faults are triggered when either un-mapped memory is accessed or operations prohibited by page flags occur



\*. ‘Anonymous’ pages are those that are backed by physical memory, not files. †. We will go over memory-specific procfs interfaces in great detail in a later chapter.





(e.g. writing into memory marked read-only) and crucially, the kernel can

catch and handle these, correcting the issue and resuming the process if ap-

propriate.

As a result, it becomes possible to defer memory allocation until the first

instance a process tries to access it. When they do, a page fault occurs and

the kernel can access the process’s [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) object (this describes its

address space and contains all of its VMAs) and check whether there is a

VMA containing the accessed address and then allocate the physical backing

memory and any page tables that are needed, pointing them at the backing

page and resuming the process. This technique is termed demand paging.

This concept of demand paging is one which the kernel heavily relies

upon. Another is Copy-on-Write (CoW). This is where a read-write memory

mapping is mapped read-only, and when a page fault arises on write, the un-

derlying page is copied, hence ‘copy on write’.

This is useful for speeding up forking of processes as we can simply es-

tablish CoW mappings to the parent process and avoid having to copy any

underlying memory at all, but is also useful when allocating memory.

Early on the kernel establishes a zero page, which is simply a page with all

of its contents set to zero. When mapping private memory, the kernel can

simply map the memory as CoW to the zero page – when read this memory

will read zero, when written to it will be copied, establishing the actual allo-

cated memory.

A memory mapping can map underlying physical memory alone map-

ping) or an underlying file. We describe the former as anonymous-backed and

the latter as file-backed.

Anonymous memory is capable of being ‘swapped out’ if it possesses the

PG_swapbacked folio flag, at which point no folio will be associated with the

mapping and the data will be written to disk, ‘swapped in’ again on page

fault. More on this in the chapter on swap memory.



**4.1 Overcommit**



The ability to allocate more memory than is actually installed in the system

(deferring the actual mapping and allocation to access time) is termed [**over-**](https://kernel.org/doc/html/v6.0/mm/overcommit-accounting.html)

[**commit**](https://kernel.org/doc/html/v6.0/mm/overcommit-accounting.html). There are three different overcommit modes permitted in the ker-

nel set via the vm.overcommit_memory tuneable and checked by the kernel in

[\_\_vm_enough_memory()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n1022):



• [OVERCOMMIT_GUESS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/mman.h?h=v6.0#n12) (0) – default – If a process tries to allocate an obviously

silly amount of memory i.e. one that exceeds the sum of total installed RAM and swap then the allocation is disallowed, otherwise it is permit-ted.

• [OVERCOMMIT_ALWAYS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/mman.h?h=v6.0#n13) (1) – No checks are performed whatsoever, all allo-

cations are permitted. This might be useful for situations where it is known that huge allocations will be made but remain mostly sparse.

• [OVERCOMMIT_NEVER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/mman.h?h=v6.0#n14) (2) – Attempt to avoid overcommit altogether. The

amount of virtual memory permitted to be allocated by the system as a







whole is calculated in [vm_commit_limit()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n967) and is specified by either the

vm.overcommit_kbytes or vm.overcommit_ratio [VM tuneables](https://kernel.org/doc/html/v6.0/admin-guide/sysctl/vm.html)[.](https://kernel.org/doc/html/v6.0/admin-guide/sysctl/vm.html) The maxi-mum allocation permitted at any one time is the total available swap plus either vm.overcommit_kbytes or vm.overcommit_ratio% of all non-hugetlb RAM. This limit can be observed in /proc/meminfo as CommitLimit. Note that additional space is reserved for root operations (via the vm.admin_reserve_kbytes tuneable) and also for userland processes to en-sure system recovery can always occur via vm.user_reserve_kbytes.



A key difference here is that in OVERCOMMIT_GUESS mode the check is

performed against the amount of memory being allocated, however in OVERCOMMIT_NEVER mode the check is made against the system’s total commit-ted memory size, i.e. the amount of virtual memory allocated by all process but not necessarily physically allocated/mapped by the kernel.

For example, invoking mmap() or malloc() to allocate 1 GiB of RAM will

increase committed memory by 1 GiB while not necessarily increasing phys-ical memory usage at all. This value can be observed in /proc/meminfo as

Committed_AS and the value is stored in the per-CPU counter [vm_committed_as](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n985)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n985)



**N O T E** Per-CPU counters are a mechanism for efficiently accruing counters between CPUs

while permitting some small degree of error equal to the counter batch size, see

[*lib/percpu_counter.c*](https://elixir.bootlin.com/linux/v6.0/source/lib/percpu_counter.c) for more details.



An important caveat here – any memory that is allocated such that it can-

not trigger demand paging, e.g. PROT_NONE or PROT_READ (without PROT_WRITE), will not contributed towards any commit accounting as the memory, if writ-ten to, would result in a segfault.



**N O T E** Additionally, [*mmap()*](https://man7.org/linux/man-pages/man2/mmap.2.html)[’d](https://man7.org/linux/man-pages/man2/mmap.2.html) memory with the *MAP_NORESERVE* flag set does not contribute

towards commit accounting, however this is not honoured in *OVERCOMMIT_NEVER* mode, so is only meaningfully useful in *OVERCOMMIT_GUESS* where even the basic total RAM and swap check is not performed (an exception to this rule are hugetlb mappings but these are out of scope for this discussion).



However memory mapped this way will show up in /proc/\$PID/status

VmSize and VmPeak statistics. This is checked via [security_vm_enough_memory_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/security/security.c?h=v6.0#n830)

(which in turn calls [\_\_vm_enough_memory()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n1022)) which is typically either invoked via

[accountable_mapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1669) or [shmem_acct_size()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/shmem.c?h=v6.0#n165)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/shmem.c?h=v6.0#n165)

Note that no mode prevents demand paging, which is a vital component

of linux systems – when processes [fork](https://man7.org/linux/man-pages/man2/fork.2.html), the memory of the forking process is shared with the child process using a Copy-on-Write (CoW) mechanism which marks the copied pages as read-only while still pointing at underlying physical pages, allowing for child process memory to only be separately al-located if changed. If the memory actually had to be copied each time this fundamental operation would be considerably slower.

Let’s take listing 4-1 and update it to write to the first page as shown in

Listing 4-3.



**\#include** \<stdio.h\>







**\#include** \<stdlib.h\>

**\#include** \<sys/mman.h\>



**int main**(**void**)

{

**char** \*ptr = **mmap**(**NULL**, 20000, **PROT_READ** \| **PROT_WRITE**,

**MAP_PRIVATE** \| **MAP_ANONYMOUS**, -1, 0);



ptr\[0\] = 'x';



**if** (ptr == **MAP_FAILED** \|\| **munmap**(ptr, 20000) != 0) {

**perror**("**mmap**"); **return EXIT_FAILURE**;

}



**return EXIT_SUCCESS**;

}



*Listing 4-3:* *mmap* *touch page then* *munmap*



We can now see that the first page of memory has now been allocated

and observation of the binary /proc/\$PID/pagemap interface indicates that it

has also been mapped as expected as shown in Listing 4-4.



\$ **cat** /proc/\$PID/smaps



**7ffff7fbf000-7ffff7fc4000** rw-p 00000000 00:00 0

Size: 20 kB



**Rss:** **4 kB**



*Listing 4-4:* */proc/\$PID/smaps* *output after* *mmap()* *and touch 1st page*



So to recap – each process has a [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) object describing its ad-

dress space which contains a collection of [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) objects de-

scribing distinct virtual allocations (known as VMAs). When memory is al-

located virtually it does not necessarily allocate physical memory or map it

into the virtual address space, as this can be deferred to the time of access

via page fault in a process known as demand paging.

Let’s examine each of these concepts in more detail, but firstly taking a

step back and looking at userland allocation as a whole, as shown in Figure

4-1.







**4.2 Userland memory from 50,000 feet**



[mm_struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)



[vma vma vma vma vma vma vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403)



[avc avc avc avc](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82) [file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) [file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) [file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) [avc](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940)



[anon_vma anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) [address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) [address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) [anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)



[folio folio folio folio folio folio folio folio folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256)



Data Data Data Data Data Data Data Data Data Data



PTE PTE PTE PTE PTE



PMD PMD PMD PMD



PUD PUD PUD



P4D P4D



PGD PGD



VA VA VA VA VA VA



*Figure 4-1: Overview of userland memory allocation*



Note that:

A

• Denotes that B is a member of a list declared in A.

B

A

• Denotes that B is a node in a red/black tree rooted in A.

B



***4.2.1 Describing userland memory***

This diagram may seem a little overwhelming at first, so let’s examine each element in turn:







[struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) – This is the core data structure describing a process’s en-

tire address space, most notably containing a list and an interval tree\* of Virtual Memory Areas or VMAs which describe each valid range of user-

land memory. Described in section 4.3.

[struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMAs) – This is one of the most important data

structures in the entire memory management subsystem and describes valid userland virtual memory ranges and their attributes. Accessing memory within a range described by a VMA is valid, accessing memory

outside this range is not. Described in section 4.4.

[struct anon_vma_chain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82) – Virtual memory is in a state of constant flux – VMAs

are often split and expanded, processes are forked and take CoW map-pings of their parent’s folios and yet throughout this we must track to which VMA folios belong and vice-versa.

There is, as a result, a many-to-many mapping between VMAs and un-derlying folios. Give that each anonymous (i.e. non-file backed) block of memory is described by an anon_vma, we need an object to ‘glue’ these and VMAs together – the anon_vma_chain object is this glue. This is de-

scribed in detail in Chapter 7.

[struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) – A single file can be mapped from multiple different processes.

When a file is open in a process, a file object describes the open file and usefully for the purposes of file-backed memory mapping, refer-ences the underlying address_space which describes the folios which back the file.

The file object therefore resembles the anon_vma_chain object in that it provides ‘glue’ between file folios and VMAs in a many-to-many map-ping, however it suffers less complexity as each process possesses one and only one file object for each open file and file-backed VMAs are not subject to the same splitting and expansion as anonymous ones. De-

scribed in section 4.5.

[struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) – Each folio which forms part of an anonymous memory

mapping needs to be able to trace back to the VMAs associated with it, which it does via the folio’s mapping field. The object to which they refer is the anon_vma which groups all such folios together. This object, along with anon_vma_chain forms the reverse mapping from folios to VMAs. De-

scribed in detail in Chapter 7.

[struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) – Describes an element that resides within the page

cache, which is the in-memory cached representation of files or other ‘cacheable’ objects such as block device buffers.

The folios which make up entries in the page cache must be able to re-fer back to their owning VMAs, and this object provides the ‘glue’ for them to be able to do so. As with anon_vma objects, these refer to their

address_mapping via the mapping field. Described in section 4.5.



\*. An interval tree is a red/black tree designed to efficiently locate elements containing a value

within intervals.







[struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) – The metadata describing either a single base page of memory

or a compound aggregate of them as provided by the physical allocator. Described in section 2.2.

**Data pages** – These are the underlying base pages of physical memory

which contain the actual data referenced by the virtual mappings and kernel metadata structures.

**Page tables** (PGD - PTE) – These are sparse data structures, each occupying

a base page of memory in x86-64, providing a mapping between virtual and physical addresses. See the previous chapter for a detailed examina-tion of page table structure.

**Virtual Addresses** (VAs) – These are the memory addresses used in user-

land familiar to all programmers and the net result of all the rest of the memory management machinery.



We will spend the rest of this chapter describing each of the process

memory-specific metadata structures referenced above in considerable de-tail.



**4.3 The process address space**



Each process has its memory state stored in [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) objects. These contain all the information the kernel needs to describe a userland process’s virtual memory address space and are referenced by the process state ob-

ject’s [struct task_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727)[’s](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) mm field.

Kernel threads do not require userspace mappings, but it would be in-

efficient to flush the TLB each time you scheduled a kernel thread, so the kernel uses a trick known as a lazy TLB which has existed in the kernel for a very long time.

This stores the previously scheduled task’s struct mm_struct object in the

active_mm field rather than the mm field, which is set to NULL\*. Since the hard-ware will have the page table mappings and PGD loaded from this process, it’s vital that we increment a reference counter and mark that we are relying on this mapping remaining in place. This is performed by the scheduler in

[context_switch()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/core.c?h=v6.0#n5131) as shown in Listing 4-5.



5130 **static \_\_always_inline struct** rq \* 5131 **context_switch**(**struct** rq \*rq, **struct** task_struct \*prev, 5132 **struct** task_struct \*next, **struct** rq_flags \*rf) 5133 {

. . .

5143 */\**

5144 *\* kernel -\> kernel* *lazy + transfer active* 5145 *\** *user -\> kernel* *lazy + mmgrab() active* 5146 *\**



\*. This is not always the case, as kernel threads can actually ‘borrow’ a [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) alto-

gether via [kthread_use_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/kthread.c?h=v6.0#n1405)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/kthread.c?h=v6.0#n1405) but most of the time kernel threads do not do this.





5147 *\* kernel -\>* *user* *switch + mmdrop() active* 5148 *\** *user -\>* *user* *switch* 5149 *\*/*

5150 **if** (!next-\>mm) { *// to kernel* 5151 **enter_lazy_tlb**(prev-\>active_mm, next); 5152

5153 next-\>active_mm = prev-\>active_mm; 5154 **if** (prev-\>mm) *// from user* 5155 **mmgrab**(prev-\>active_mm); 5156 **else**

5157 prev-\>active_mm = **NULL**; 5158 } **else** { *// to user*

. . .

5170 **if** (!prev-\>mm) { *// from kernel* 5171 */\* will mmdrop() in finish_task_switch(). \*/* 5172 rq-\>prev_mm = prev-\>active_mm; 5173 prev-\>active_mm = **NULL**; 5174 }

5175 }

. . .

5185 **return finish_task_switch**(prev); 5186 }



*Listing 4-5:* kernel/sched/core.c: [*context_switch()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/core.c?h=v6.0#n5131)



The [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) reference count (maintained in the atomic

mm-\>mm_count field) is incremented by [mmgrab()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n35) and decremented by [mmdrop()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n42).

The architecture-specific means of indicating a lazy TLB state is performed

by [enter_lazy_tlb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n663).

The key purpose of mm_struct however is to store the state of a process’s

virtual memory address space, most fundamentally a pointer to its PGD ta-

ble (a virtual equivalent of the assignment of the physical address as the root

of the virtual memory mapping in hardware), a collection of all its VMAs

(discussed in detail shortly) and important locks.

Since the data structure encompasses a great many fields and to keep

things focused, we examine only the core fields as shown in Listing 4-6.



486 **struct** mm_struct {

487 **struct** {

488 **struct** vm_area_struct \*mmap; */\* list of VMAs \*/* 489 **struct** rb_root mm_rb; 490 **u64** vmacache_seqnum; */\* per-thread vmacache*

*\*/*

. . .

492 **unsigned long** (\*get_unmapped_area) (**struct** file \*filp, 493 **unsigned long** addr, **unsigned long** len, 494 **unsigned long** pgoff, **unsigned long** flags);

. . .

496 **unsigned long** mmap_base; */\* base of mmap area \*/*







. . .

503 **unsigned long** task_size; */\* size of task vm space \*/* 504 **unsigned long** highest_vm_end; */\* highest vma end address \*/* 505 **pgd_t** \* pgd;

. . .

517 */\*\**

518 *\* @mm_users: The number of users including userspace.* 519 *\**

520 *\* Use mmget()/mmget_not_zero()/mmput() to modify. When this*

521 *\* drops to 0 (i.e. when the task exits and there are no other*

522 *\* temporary reference holders), we also release a reference*

*on*

523 *\* @mm_count (which may then free the &struct mm_struct if*

524 *\* @mm_count also drops to 0).* 525 *\*/*

526 **atomic_t** mm_users; 527

528 */\*\**

529 *\* @mm_count: The number of references to &struct mm_struct*

530 *\* (@mm_users count as 1).* 531 *\**

532 *\* Use mmgrab()/mmdrop() to modify. When this drops to 0, the*

533 *\* &struct mm_struct is freed.* 534 *\*/*

535 **atomic_t** mm_count; 536

537 **\#ifdef CONFIG_MMU**

538 **atomic_long_t** pgtables_bytes; */\* PTE page table pages \*/* 539 **\#endif**

540 **int** map_count; */\* number of VMAs \*/* 541

542 **spinlock_t** page_table_lock; */\* Protects page tables and some* 543 *\* counters* 544 *\*/* 545 */\**

546 *\* With some kernel config, the current mmap_lock's offset*

547 *\* inside 'mm_struct' is at 0x120, which is very optimal, as*

548 *\* its two hot fields 'count' and 'owner' sit in 2 different*

549 *\* cachelines, and when mmap_lock is highly contended, both*

550 *\* of the 2 fields will be accessed frequently, current layout*

551 *\* will help to reduce cache bouncing.* 552 *\**

553 *\* So please be careful with adding new fields before* 554 *\* mmap_lock, which can easily push the 2 fields into one*

555 *\* cacheline.* 556 *\*/*

557 **struct** rw_semaphore mmap_lock;







558

559 **struct** list_head mmlist; */\* List of maybe swapped mm's. These* 560 *\* are globally strung together off*

561 *\* init_mm.mmlist, and are protected*

562 *\* by mmlist_lock* 563 *\*/*

. . .

575 **unsigned long** def_flags;

576

577 */\*\**

578 *\* @write_protect_seq: Locked when any thread is write* 579 *\* protecting pages mapped by this mm to enforce a later COW,*

580 *\* for instance during page table copying for fork().* 581 *\*/*

582 **seqcount_t** write_protect_seq;

. . .

603 **unsigned long** flags; */\* Must use atomic bitops to access \*/*

. . .

610 */\**

611 *\* "owner" points to a task that is regarded as the canonical*

612 *\* user/owner of this mm. All of the following must be true in*

613 *\* order for it to be changed:* 614 *\**

615 *\* current == mm-\>owner* 616 *\* current-\>mm != mm* 617 *\* new_owner-\>mm == mm* 618 *\* new_owner-\>alloc_lock is held* 619 *\*/*

620 **struct** task_struct \_\_rcu \*owner;

. . .

675 } **\_\_randomize_layout**;

676

677 */\**

678 *\* The mm_cpumask needs to be at the end of mm_struct, because it* 679 *\* is dynamically sized based on nr_cpu_ids.* 680 *\*/*

681 **unsigned long** cpu_bitmap\[\]; 682 };



*Listing 4-6:* include/linux/mm_types.h: *Simplified [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)*

Examining each field:



• mmap – Points to the first VMA in the address space, which are connected

together as a linked list via the [vm_area_struct-\>vm_prev,vm_next](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) pointers. VMAs within an mm_struct are kept in sorted order so this will also be the VMA with the lowest address in the process address space.

• mm_rb – The root node of a red/black tree used to efficiently navigate

through VMAs during search operations.







• vmacache_seqnum – A ‘sequence number’ used to keep track of whether

the current VMA cache is valid. These caches are kept per-thread in the

[struct task_struct-\>vmacache](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) field whose validity is tied to matching their

own sequence number to this one. See section 4.4.5 for more on VMA caches.

• get_unmapped_area – The default method used to find unmapped mem-

ory within the process address space used for file-backed mappings if no VMA-specific one is specified and for all non-shared anonymous map-

pings. For x86-64 this is set in [arch_pick_mmap_layout()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/mmap.c?h=v6.0#n129) which typically sets

this to [arch_get_unmapped_area_topdown()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/sys_x86_64.c?h=v6.0#n161)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/sys_x86_64.c?h=v6.0#n161) We examine this in more detail

in section 4.4.

• mmap_base – The minimum address from which [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) allocations will be

performed if no fixed address is specified. This is set up in [setup_new_exec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/exec.c?h=v6.0#n1433)

which in turn invokes [arch_pick_mmap_layout()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/mmap.c?h=v6.0#n129) and then in the case of

x86-64 [arch_pick_mmap_base()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/mmap.c?h=v6.0#n118). This is a value which is set relatively high in the address space to avoid the data section of a process (expanded

by the [brk()](https://man7.org/linux/man-pages/man2/brk.2.html) system call), but low enough to avoid the stack which is al-located from a high address and grows downwards. It is also typically randomised for security reasons.

• task_size – The maximum virtual memory size the process can occupy.

For x86-64 with 4 page table levels this is 128 TiB (less 4 KiB), with 5

page tables it is 64 PiB (less 4 KiB), i.e. equal to [TASK_SIZE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_64_types.h?h=v6.0#n75)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_64_types.h?h=v6.0#n75) See the virtual memory chapter for more on page table mappings.

• highest_vm_end – The maximum exclusive upper bound of VMA con-

tained in the address space, i.e. the ‘end’ of the virtual mapping.

Updated in functions such as [\_\_vma_link_rb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n595)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n595) [\_\_vma_adjust()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n699) and

[detach_vmas_to_be_unmapped()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2633).

• pgd – A virtual mapping of the highest order page table for the address

space, the Page Global Directory (PGD). All page table operations are performed relative to this.

• mm_users – See section 4.3.1 for a description of mm_struct reference

counts.

• mm_count – See section 4.3.1 for a description of mm_struct reference

counts.

• pgtables_bytes – Atomic value indicating the number of bytes oc-

cupied by PTE page tables in the address space. Accessed via

[mm_pgtables_bytes(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2164)incremented via [mm_inc_nr_ptes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2169) and decremented

by [mm_dec_nr_ptes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2174). This is incremented by e.g. [pmd_install()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n440) and decre-

mented by e.g. [free_pte_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n230).

• map_count – A count of the number of VMAs contained within the

mm_struct. This is incremented in [vma_link()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n645), [\_\_insert_vm_struct()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n670)

and [dup_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n580) and decremented in [\_\_vma_adjust()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n699) and

[detach_vmas_to_be_unmapped()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2633).







• page_table_lock – One of the two most important userspace memory

locks, ostensibly protecting page tables that do not possess fine-grained locks, but in reality protecting a number of other mechanisms. Dis-cussed in considerably more detail below.

• mmap_lock – The other of the two most important userspace locks, which

is in actual fact a read/write semaphore. This is discussed in substantial detail, along with page_table_lock, in the below section on this topic.

• mmlist – A [struct list_head](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/types.h?h=v6.0#n178) node used to maintain a linked list of

mm_struct objects which are maintained on the [init_mm-\>mmlist](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/init-mm.c?h=v6.0#n30) list and

protected by [mmlist_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1062). Used by the swap logic and discussed in more detail in the swap chapter.

• def_flags – Specifies default VMA flags to be applied to all VMAs. This is

used most notably by the mlock() functionality to specify VM_LOCKED when

the user invokes [mlockall()](https://man7.org/linux/man-pages/man2/mlockall.2.html) with the MCL_FUTURE flag set to lock all newly

allocated mappings (this is performed in [apply_mlockall_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n660), see sec-

tion 8.2.1 for more details on this specific use of default flags). This flag

is applied in the core mapping functions [do_brk_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n151) and [do_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1369)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1369)

• write_protect_seq – Lock used to protect the operation of write-

protecting pages for e.g. a Copy-on-Write (COW) operation (used in

[copy_page_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1272) for copying page table mappings) and checked by GUP

in the lockless path in [lockless_pages_from_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2915).

• flags – Contains a bitmap of flags describing attributes of the mm_struct,

discussed below in section 4.3.5.

• owner – Indicates which process, represented by a [struct task_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727)

‘owns’ this virtual address space. This is only available if the mem-ory cgroup, memcg, is enabled, via CONFIG_MEMCG, and is initialised by

[mm_init_owner()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1095) (set to a process in [mm_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1109)), cleared by [mm_clear_owner()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1086)

(used in an error branch in [copy_process()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1989)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1989) and assigned to the next

owner via [mm_update_next_owner()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/exit.c?h=v6.0#n390) (invoked on execve() in [exec_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/exec.c?h=v6.0#n977) and

on exit in [exit_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/exit.c?h=v6.0#n478)[).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/exit.c?h=v6.0#n478)

• cpu_bitmap – Used by [mm_cpumask()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n696) to provide a bitmap of type [cpumask_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/cpumask.h?h=v6.0#n19)

indicating to which CPUs this mm_struct is affinitised. Notably used by TLB logic to determine which cores actually need to have TLB cache actions performed in relation to a process.



***4.3.1 mm_struct reference counting***

As described above, there are two reference counts present in the

[struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) object – mm_users and mm_count. Examining each in turn:



**4.3.1.1 mm_users**

Incremented by [mmget()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n98) (or, if we need to be cautious about whether or not

we have already reached zero users, [mmget_not_zero()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n103)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n103) and decremented by

[mmput()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1203) (or, optionally, asynchronously via [mmput_async()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1221).)







Counts the number of userland references to the process address space.

If this value is non-zero then mm_count will also be non-zero (i.e. userspace as a whole counts as 1 mm_count).

When this reference count reaches zero, all userland-specific metadata is

torn down as are all userland mappings via [\_\_mmput()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1179)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1179) Importantly, the kernel mappings remain and so does the object as a whole, with mm_count simply being decremented, only if this reaches zero does the object as a whole get torn down (see below).

Other users which increment this reference counter might include a

forked process (via [copy_process()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1989) which invokes [copy_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1547) which invokes

mmget() in turn), the [move_pages()](https://man7.org/linux/man-pages/man2/move_pages.2.html) syscall for moving pages between nodes via

[kernel_move_pages(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/migrate.c?h=v6.0#n1987)among many other users, often via the [get_task_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1371) and

[access_process_vm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5524) functions.



**4.3.1.2 mm_count**

Incremented by [mmgrab()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n35) and decremented by [mmdrop()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n42).

Counts the number of kernel references to the process address space (im-

portantly, including the process itself i.e. its [struct task_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) object).

The reference count is incremented when lazy TLB mode is entered, ei-

ther by a kernel process reusing the existing process address space mappings without swapping out its PGD (which involves expensive TLB invalidation) or a task such as exiting a process that needs to tear things down but keep

the mm_struct around for a while, e.g. in [exit_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/exit.c?h=v6.0#n478). See the virtual memory chapter for more on the TLB. Any non-zero number of mm_users count as 1 mm_count.

If the reference count drops to zero, this invokes [\_\_mmdrop()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n783) which frees

the mm_struct’s PGD and the mm_struct itself among other housekeeping tasks. By this point all user mappings will already have been freed.



***4.3.2 The initial process address space***

Each processor has an idle task which represents the task that the scheduler

switches in when there is no other processor work to perform\*. It is, ostensi-bly, the process from which all other processes are derived.

The progenitor of each CPU’s idle task is created very early on in kernel

initialisation and is declared statically as [init_task](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/init/init_task.c?h=v6.0#n64)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/init/init_task.c?h=v6.0#n64) Its active_mm field is as-

signed to [init_mm](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/init-mm.c?h=v6.0#n30) which represents the shared mm_struct of each idle task. The mm field is set to NULL because this is a kernel process and thus defined by not

possessing its own individual mm_struct as shown in Listing 4-7.



\*. we use ‘task’ and ‘process’ interchangeably – the data structure representing a process is

[struct task_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) and from a kernel point of view a process is defined by possessing an indi-vidual task object, however in the common vernacular we would describe the same entity as a process. Additional confusion can arise because the kernel treats each individual thread as a separate process whereas a userland programmer might consider each to be part of the same process, however from the kernel point of view, we see these as processes with shared mm_struct objects.







30 **struct** mm_struct init_mm = {

31 .mm_rb = **RB_ROOT**,

32 .pgd = swapper_pg_dir,

33 .mm_users = **ATOMIC_INIT**(2),

34 .mm_count = **ATOMIC_INIT**(1),

35 .write_protect_seq = **SEQCNT_ZERO**(init_mm.write_protect_seq),

36 **MMAP_LOCK_INITIALIZER**(init_mm)

37 .page_table_lock = **\_\_SPIN_LOCK_UNLOCKED**(init_mm.page_table_lock),

38 .arg_lock = **\_\_SPIN_LOCK_UNLOCKED**(init_mm.arg_lock),

39 .mmlist = **LIST_HEAD_INIT**(init_mm.mmlist),

40 .user_ns = &init_user_ns,

41 .cpu_bitmap = **CPU_BITS_NONE**,

42 **\#ifdef CONFIG_IOMMU_SVA**

43 .pasid = **INVALID_IOASID**,

44 **\#endif**

45 **INIT_MM_CONTEXT**(init_mm)

46 };



*Listing 4-7:* mm/init-mm.c: [*init_mm*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/init-mm.c?h=v6.0#n30)



Note that the mm_users field is initialised to 2. This ensures that no spuri-

ous [mmput()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1203) attempts to tear down the object.

The global [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) object init_mm is used for a number of differ-

ent purposes (this is not an exhaustive list):



• As the active mm_struct for the CPU idle tasks as described above and dur-

ing CPU initialisation e.g. in [cpu_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/cpu/common.c?h=v6.0#n2231) where it is the very first active

mm_struct assigned to a CPU and in [finish_cpu()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/cpu.c?h=v6.0#n615) invoked when a CPU goes offline in a hotplug system for example.

• During kernel initialisation, where we need to have both a PGD estab-

lished to perform early memory mappings (e.g. in [fill_p4d()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n243)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n243) as well as access to a shared page_table_lock in order to synchronise page table up-

dates across CPUs (e.g. in [\_\_kernel_physical_mapping_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n725)[).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n725)

• As the mm_struct parameter for kernel-specific page table functions

like [pgd_offset_k()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n141) (which simply uses it to access the kernel PGD), or

[\_\_pte_alloc_kernel()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n478) which uses it to obtain the page_table_lock for kernel PTE allocations.

• As the head of the list of mm_struct objects for process address spaces

used for the swap logic in the init_mm.mmlist field, manipulated in e.g.

[try_to_unuse()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n2038), [drain_mmlist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n2140) and [try_to_unmap_one()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1476).

• In x86-64, when flushing the TLB via [flush_tlb_func()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n723) and lazy TLB is in

force (this is cheaper than a minimum flush), or ‘leaving’ the current

mm_struct via [leave_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n296) used to force a TLB flush by switching to the init_mm if the CPU idle task is set up that way. This function is also used

by the x86-64 specific [use_temporary_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/alternative.c?h=v6.0#n1018) which is used by the text poke

functionality via [\_\_text_poke()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/alternative.c?h=v6.0#n1082) for live kernel patching (e.g. via KGDB).







• When a ‘spurious fault’ occurs in x86-64 in [spurious_kernel_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1007)

where, for efficiency reasons, a TLB entry may be permitted to remain stale with the fault handled here. The init_mm object is used simply to obtain the kernel-specific PGD to check to see if the mapping is valid.



The key purpose is to both have an early kernel process address space

available for kernel initialisation and to also maintain global kernel (i.e. non-userland) state like the head of the mmlist object and the kernel PGD, locks and other global memory state.

The PGD used by init_mm is very important, as it contains the top-level of

all kernel mappings. This is assigned to the static object, [swapper_pg_dir](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64.h?h=v6.0#n29) (in

x86-64 this is an alias for [init_top_pgt](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/head_64.S?h=v6.0#n573)[).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/head_64.S?h=v6.0#n573)



***4.3.3 Kernel PGD maintenance***

Kernel page table mappings are rooted in the PGD defined in [swapper_pg_dir](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64.h?h=v6.0#n29) and assigned to the init_mm.

Userland mappings are always present whether in userland or kernel

mode. On x86-64, which kernel mappings are present is dependent on

whether or not an important security mitigation, termed [Page Table Isolation](https://kernel.org/doc/html/v6.0/x86/pti.html)

[(PTI), ](https://kernel.org/doc/html/v6.0/x86/pti.html)is enabled. This was implemented in order to address the ‘meltdown’ security vulnerability (a detailed discussion of which is outside the scope of this book).

The kernel needs to have userland mappings in place for process-specific

transactions such as system calls in order that it can interact with userland memory, e.g. to copy memory between kernel and userland so these must be maintained between each.



**4.3.3.1 Page Table Isolation**

When the PTI mitigation is not in place, then the mappings are simple – both kernel and userland contain kernel and userland mappings, with the kernel mappings maintaining page flags rendering them unusable in user-land, and kernel mappings maintained such that the TLB is not flushed be-tween context switches (see the virtual memory chapter for more on these flags).

The feature is made available via CONFIG_PAGE_TABLE_ISOLATION but even if

this configuration option is set, the mitigation will only be enabled if the

[X86_FEATURE_PTI](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/cpufeatures.h?h=v6.0#n205) flag is set, which is only enabled if the CPU is vulnerable to

meltdown, checked in [pti_check_boottime_disable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pti.c?h=v6.0#n78).

When PTI is enabled, then PGDs are allocated as order-1, i.e. 8 KiB, fo-

lios and contain two separate PGD tables, one for userland mode and one for kernel mode.

In kernel mode (the first 4 KiB of the order-1 PGD) all kernel and user-

land mappings are present, however userland mappings are marked non-executable in order to avoid any mistake in page table assignment in user-land mode.

In userland mode, however (the last 4 KiB of the order-1 GPD), only a

bare minimum set of kernel mappings are present, the minimum required







to permit kernel transition. By using order-1 PGD pages, we need only flip

a bit to switch between the two, which is what [kernel_to_user_pgdp()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1211) and

[user_to_kernel_pgdp()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1216) do.

Importantly, note that the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)-\>pgd field is set to the kernel

portion of the order-1 PGD, i.e. the lower portion, with the userland map-

pings kept in the adjacent base page. This means initial transitions to an-

other process address space, performed in the kernel, maintain kernel map-

pings.

When a PGD entry needs to be updated for userland, the function

[pti_set_user_pgtbl()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n695) is invoked which, if the PTI mitigation is in place, in-

vokes [\_\_pti_set_user_pgtbl()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pti.c?h=v6.0#n124). This uses [kernel_to_user_pgdp()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1211) to update the

userland portion of the PGD, and adds an equivalent in the kernel portion

of the PGD with execution disabled as previously discussed.

Switching between processes is ultimately performed by

[switch_mm_irqs_off()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n489), typically on context switch via [context_switch()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/core.c?h=v6.0#n5131) (shown

in listing 4-5) but also in other code paths via [switch_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n318) or [activate_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/mmu_context.h?h=v6.0#n135).

These functions change the PGD the CPU is currently using in the hard-

ware, which for x86-64 is specified by the cr3 control register whose value is

determined by [build_cr3()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n157) and set by [load_new_mm_cr3()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n277)[\*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n277).

Note however that we remain in kernel mode as other actions need to

be performed before actually switching into user mode if that is what is re-

quired. As a result, as discussed above, we use the struct mm_struct-\>pgd field

which is pointing at the kernel PGD table, and thus this logic remains largely

unmodified.

The real change arises in the entry code that returns from a sys-

tem call or interrupt (including scheduler interrupts), for example

[common_interrupt_return()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/entry/entry_64.S?h=v6.0#n614) and [entry_SYSCALL_64()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/entry/entry_64.S?h=v6.0#n87) which both invoke the

[SWITCH_TO_KERNEL_CR3()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/entry/calling.h?h=v6.0#n167) and [SWITCH_TO_USER_CR3_STACK()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/entry/calling.h?h=v6.0#n212) assembly macros which

fixup the PGDs accordingly before loading them into cr3.

I have focused on the PTI logic in a fair bit of detail here as a result of

it complicating the otherwise fairly clear logic around kernel and userland

page table mappings, which without this mitigation are simply stored in the

same page tables, only with the kernel mappings explicitly made unavailable

to userland.



**4.3.3.2 Maintaining kernel mappings between processes**

Early kernel code updates [swapper_pg_dir](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64.h?h=v6.0#n29) to include the direct mapping, the

vmalloc area, and other crucial kernel-wide mappings. As a result, a fairly

vast swathe of kernel memory addresses are already established in [init_mm](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/init-mm.c?h=v6.0#n30)

and thus inherited by the proceeding processes which each copy these map-

pings from the former on fork and execution.

When it comes to examining how kernel mappings are propagated when

new userland processes are created we need to consider the two classic exe-

cution operations in a Unix system – [fork()](https://man7.org/linux/man-pages/man2/fork.2.html) and [execve()](https://man7.org/linux/man-pages/man2/execve.2.html)[:](https://man7.org/linux/man-pages/man2/execve.2.html)



\*. There is some additional logic here relating to PCIDs, however this is out of scope for the

book.







On fork, page tables are copied via [copy_page_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1272) which was invoked

in turn by [dup_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n580), [dup_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1510)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1510) [copy_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1547)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1547) [copy_process()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1989) and [kernel_clone()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n2630). This copies the entire contents of the page tables and thus new processes re-ceive a copy of all existing kernel mappings in the PGD as well as all existing userland mappings.

On execve either [kernel_execve()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/exec.c?h=v6.0#n1951) will be invoked or userland will call one

of the exec_ve() variants which invoke [do_execveat_common()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/exec.c?h=v6.0#n1866)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/exec.c?h=v6.0#n1866) Both of these

routes ultimately invoke [mm_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1167) which initialises the newly allocated

[struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) object via [mm_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1109).

This function allocates the PGD via [mm_alloc_pgd()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n727) which ultimately in-

vokes the architecture-specific [pgd_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgtable.c?h=v6.0#n424)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgtable.c?h=v6.0#n424) here examining the x86-64 imple-

mentation as shown in Listing 4-8.



424 **pgd_t** \***pgd_alloc**(**struct** mm_struct \*mm) 425 {

426 **pgd_t** \*pgd;

. . .

430 pgd = **\_pgd_alloc**(); 431

432 **if** (pgd == **NULL**)

433 **goto out**; 434

435 mm-\>pgd = pgd;

. . .

446 */\**

447 *\* Make sure that pre-populating the pmds is atomic with* 448 *\* respect to anything walking the pgd_list, so that they* 449 *\* never see a partially populated pgd.* 450 *\*/*

451 **spin_lock**(&pgd_lock); 452

453 **pgd_ctor**(mm, pgd);

. . .

457 **spin_unlock**(&pgd_lock); 458

459 **return** pgd;

. . .

467 **out**:

468 **return NULL**;

469 }



*Listing 4-8:* arch/x86/mm/pgtable.c: [*pgd_alloc()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgtable.c?h=v6.0#n424)



We exclude pre-population logic here because it is typically not relevant

in a modern system. What is relevant, however, is [pgd_ctor()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgtable.c?h=v6.0#n123) as shown in List-

ing 4-9.



123 **static void pgd_ctor**(**struct** mm_struct \*mm, **pgd_t** \*pgd) 124 {







125 */\* If the pgd points to a shared pagetable level (either the* 126 *ptes in non-PAE, or shared PMD in PAE), then just copy the* 127 *references from swapper_pg_dir. \*/* 128 **if** (**CONFIG_PGTABLE_LEVELS** == 2 \|\| 129 (**CONFIG_PGTABLE_LEVELS** == 3 && **SHARED_KERNEL_PMD**) \|\| 130 **CONFIG_PGTABLE_LEVELS** \>= 4) { 131 **clone_pgd_range**(pgd + **KERNEL_PGD_BOUNDARY**, 132 swapper_pg_dir + **KERNEL_PGD_BOUNDARY**, 133 **KERNEL_PGD_PTRS**); 134 }

135

136 */\* list required to sync kernel mapping updates \*/* 137 **if** (!**SHARED_KERNEL_PMD**) { 138 **pgd_set_mm**(pgd, mm); 139 **pgd_list_add**(pgd); 140 }

141 }



*Listing 4-9:* arch/x86/mm/pgtable.c: [*pgd_ctor()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgtable.c?h=v6.0#n123)

This directly copies from the [swapper_pg_dir](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64.h?h=v6.0#n29) global kernel PGD object for

all addresses in the kernel range, as defined by [KERNEL_PGD_BOUNDARY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n961) (provid-

ing the index of the first PGD entry within the kernel address range) and

[KERNEL_PGD_PTRS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n962) (indicating the number of entries of kernel mappings. This is

done by [clone_pgd_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1242) as shown in Listing 4-10.



1232 */\**

1233 *\* clone_pgd_range(pgd_t \*dst, pgd_t \*src, int count);* 1234 *\**

1235 *\* dst - pointer to pgd range anywhere on a pgd page* 1236 *\* src - ""*

1237 *\* count - the number of pgds to copy.* 1238 *\**

1239 *\* dst and src can be on the same page, but the range must not overlap,* 1240 *\* and must not cross a page boundary.* 1241 *\*/*

1242 **static inline void clone_pgd_range**(**pgd_t** \*dst, **pgd_t** \*src, **int** count) 1243 {

1244 **memcpy**(dst, src, count \* **sizeof**(**pgd_t**)); 1245 **\#ifdef CONFIG_PAGE_TABLE_ISOLATION** 1246 **if** (!**static_cpu_has**(**X86_FEATURE_PTI**)) 1247 **return**;

1248 */\* Clone the user space pgd as well \*/* 1249 **memcpy**(**kernel_to_user_pgdp**(dst), **kernel_to_user_pgdp**(src), 1250 count \* **sizeof**(**pgd_t**)); 1251 **\#endif**

1252 }



*Listing 4-10:* arch/x86/include/asm/pgtable.h: [*clone_pgd_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1242)







The fundamental task here is very simple – copy a single PGD entry from

[swapper_pg_dir](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64.h?h=v6.0#n29) to the target PGD, however there is additional complexity aris-ing from PTI – if PTI is active, then we also need to copy the minimal user space kernel mappings from the user space portion of the initial PGD to this new PGD.

Note that [pgd_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgtable.c?h=v6.0#n424) holds the global [pgd_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n169) over the operation, which

protects [pgd_list](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n170) containing all PGDs in the system and permits this new

PGD to be added via [pgd_list_add()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgtable.c?h=v6.0#n93).

This list is used during early initialisation in x86-64 (most notably of the

direct mapping, see the virtual memory chapter for a detailed examination

of this) via [sync_global_pgds()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/init_64.c?h=v6.0#n212) to ensure that all kernel mappings are kept up-dated, however importantly, after the kernel mappings are initialised, no region of virtual memory that can be mapped into is large enough that the PGD need be updated. Note that most kernel virtual addresses use the di-rect mapping therefore this is really not all that limiting.

Since all of the PGD entries that point to P4D mappings are copied, then

all of the kernel mappings are shared between each process (for PTI, in ker-nel mode only, as described above). Thus all changes at P4D or below are propagated , since all kernel mappings point at the same P4Ds.

On kernel start the init process, PID 1, is initialised in [rest_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/init/main.c?h=v6.0#n681) (in-

voked ultimately from [start_kernel()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/init/main.c?h=v6.0#n929)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/init/main.c?h=v6.0#n929) which invokes [user_mode_thread()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n2730)

setting this process to execute [kernel_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/init/main.c?h=v6.0#n1503). This ultimately calls

[run_init_process()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/init/main.c?h=v6.0#n1416) which, in turn, invokes [kernel_execve()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/exec.c?h=v6.0#n1951) as described above.



***4.3.4 Process address space locking***

The two key locks at the process address space level are the spinlock

[struct mm_struct-\>page_table_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) and struct mm_struct-\>mmap_lock which is a read/write semaphore.

These locks are absolutely critical as they are very heavily utilised and

thus it is useful to examine their usage in detail:



**4.3.4.1 Page table lock**

As described in the virtual memory chapter in section 3.1.4, this lock is used for page table locking at the less-contended higher page table levels, typi-cally all levels above PMD. There are some nuances to this – operations on kernel mappings typically use this lock for PMDs unconditionally, e.g. in

[\_\_pte_alloc_kernel()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n478) which is invoked by vmalloc via [pte_alloc_kernel_track()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/pgalloc-track.h?h=v6.0#n46) and of course, if the architecture doesn’t use split locks for PMD/PTEs at all then this lock will be used for all page table updates.

However, there are cases where the lock is used for non-page table oper-

ations. This used to be more common in the distant kernel past but has now been narrowed down to only a few instances:



• Protecting stack expansion – In [expand_downwards()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2441) (typically used with a

stack) and [expand_upwards()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2351) VMA expansion takes place which results in thread unsafe fields being updated, specifically the VMA gap calcula-tion. Since the mmap_lock semaphore permits simultaneous read access,







page_table_lock is used to place the entire update process in a critical sec-tion. This is simply an overloading of an available lock for an entirely different use.

• Protecting VMA gap calculation – (only applicable if *CONFIG_DEBUG_VM_RB* has

been set) – A calculation of the VMA subtree gap (see the next section on

VMAs to see what this means) is performed in [vma_compute_subtree_gap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n272)

which is invoked in turn by in [browse_rb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n290) (via [validate_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n351)[).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n351) This maintains a page_table_lock over the operation, introduced in com-

mit [acf128d048c7: mm: validate_mm browse_rb SMP race condition](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=acf128d048c7). This

was added because, it this function were to race with [vma_gap_update()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n404)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n404) data corruption could occur. Since this update function is invoked in expand_downwards() and expand_upwards(), and might also hold a read semaphore at the time (rendering the semaphore useless), using this lock resolves the data race.

• Protecting the update of the anon_vma field and chain linkage in

[\_\_anon_vma_prepare()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n187) – Here there may be multiple threads attempting to perform the same action rendering the update a critical section. Again, page_table_lock is a convenient lock to use at this stage. See the section below on reverse mappings for more details on the use of this opera-tion.



**4.3.4.2 mmap lock**

The [struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) field specifies a read/write semaphore object

that is used to synchronise VMAs and any other mm_struct state within the

address space.

It is a very heavily contended lock and used in an enormous number of

places, being arguably one of the most important locks in the entire kernel.

It is therefore worth exploring in some detail:

The [struct rw_semaphore](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rwsem.h?h=v6.0#n47) object is a [lock type](https://kernel.org/doc/html/v6.0/locking/locktypes.html#rw-semaphore) which allows concurrent ac-

cess to critical sections for multiple readers, but importantly only permits

writes when no readers are present. It is designed such that readers cannot

starve writers\*, though in theory the reverse could occur (however in prac-

tice this should never happen).

The lock is designed such that, if threads are simply reading fields, they

do not contend one another (the state is in theory immutable and thus there

is no reason that they should, though this isn’t quite the case, see the above

note about the use of page_table_lock on VMA expansion).

There are a number of helper functions which wrap common operations:



**4.3.4.3 General mmap_lock functions**

• [mmap_init_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmap_lock.h?h=v6.0#n63) – Initialises the lock, used in [mm_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1109) on initialisation

of an mm_struct.



\*. Under circumstances where locks are acquired and released without deadlock, livelock or

programming error. If a read lock failed to be released correctly, then it could indeed starve

a waiting writer, but this is a circumstance that should never occur in a correctly functioning

kernel.





• [mmap_assert_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmap_lock.h?h=v6.0#n153) – Invokes a [lockdep](https://kernel.org/doc/html/v6.0/locking/lockdep-design.html) assert that a lock is held\* and a

[VM_BUG_ON_MM()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmdebug.h?h=v6.0#n39) check which only has in impact if CONFIG_DEBUG_VM is set.

• [mmap_assert_write_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmap_lock.h?h=v6.0#n159) – Invokes a [lockdep](https://kernel.org/doc/html/v6.0/locking/lockdep-design.html) assert that a write

lock is held and a [VM_BUG_ON_MM()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmdebug.h?h=v6.0#n39) check which only has in impact if CONFIG_DEBUG_VM is set.

• [mmap_lock_is_contended()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmap_lock.h?h=v6.0#n165) – A wrapper around [rwsem_is_contended()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rwsem.h?h=v6.0#n119)

which checks to see whether the wait list of threads that wish to per-form an operation which is currently unavailable is non-empty. This

is used by [show_smaps_rollup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n876) to avoid egregious contention on ac-cess to the /proc/\$pid/smaps_rollup interface. This was introduced in

[mm: proc: smaps_rollup: do not stall write attempts on mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=ff9f47f6f00c) (com-mit ff9f47f6f00c) to prevent stalling on use of this interface for processes with large memory footprints. Similar smaps_rollup functionality was ported to BPF bringing along this usage with it, so this function is also

invoked in [task_vma_seq_get_next()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/bpf/task_iter.c?h=v6.0#n308)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/bpf/task_iter.c?h=v6.0#n308)



**4.3.4.4 mmap_lock write functions**

Note that we describe the use of these in more detail below.



• [mmap_write_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmap_lock.h?h=v6.0#n68) – Acquires a write lock on the mm_struct. Wraps

[down_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/locking/rwsem.c?h=v6.0#n1549) on mmap_lock. Ultimately invokes [\_\_down_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/locking/rwsem.c?h=v6.0#n1304) which calls

[\_\_down_write_common()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/locking/rwsem.c?h=v6.0#n1294) setting state to [TASK_UNINTERRUPTIBLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n86), which indicates that while waiting for the lock the thread attempting to acquire the lock should be marked uninterruptible.

• [mmap_write_lock_nested()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmap_lock.h?h=v6.0#n75) – Acquires a nested lock on the mm_struct. Wraps

[down_write_nested()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/locking/rwsem.c?h=v6.0#n1659) on mmap_lock, which only differs from down_write() if CONFIG_DEBUG_LOCK_ALLOC is specified. Used to specify that there is

SINGLE_DEPTH_NESTING in [dup_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n580).

• [mmap_write_lock_killable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmap_lock.h?h=v6.0#n82) – Acquires a write lock on the mm_struct.

Wraps [down_write_killable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/locking/rwsem.c?h=v6.0#n1560) on mmap_lock. Ultimately invokes

[\_\_down_write_killable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/locking/rwsem.c?h=v6.0#n1309) which calls [\_\_down_write_common()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/locking/rwsem.c?h=v6.0#n1294) setting state to

[TASK_KILLABLE, ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n105)which indicates that while waiting for the lock the thread attempting to acquire the lock should respond to deadly signals, but oth-erwise be uninterruptible.

• [mmap_write_trylock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmap_lock.h?h=v6.0#n92) – Tries to acquire a write lock on the mm_struct.

Wraps [down_write_trylock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/locking/rwsem.c?h=v6.0#n1578) on mmap_lock. Ultimately invokes the function

[\_\_down_write_trylock().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/locking/rwsem.c?h=v6.0#n1314)

• [mmap_write_downgrade()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmap_lock.h?h=v6.0#n108) – Converts a write lock on mm_struct into a read

lock, i.e. ‘downgrading’ it. Wraps [downgrade_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/locking/rwsem.c?h=v6.0#n1612) on mmap_lock. Ulti-

mately invokes the function [\_\_downgrade_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/locking/rwsem.c?h=v6.0#n1364)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/locking/rwsem.c?h=v6.0#n1364)

• [mmap_write_unlock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmap_lock.h?h=v6.0#n102) – Releases a write lock on the mm_struct. Wraps

[up_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/locking/rwsem.c?h=v6.0#n1602) on mmap_lock. Ultimately invokes the function [\_\_up_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/locking/rwsem.c?h=v6.0#n1343).



\*. lockdep is a means by which lock dependencies can be checked and locking bugs discovered. It is out of scope for the book.







**4.3.4.5 mmap_lock read functions**

Note that we describe the use of these in more detail below.



• [mmap_read_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmap_lock.h?h=v6.0#n114) – Acquires a read lock on the mm_struct. Wraps

[down_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/locking/rwsem.c?h=v6.0#n1496) on mmap_lock. Ultimately invokes [\_\_down_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/locking/rwsem.c?h=v6.0#n1259) which calls

[\_\_down_read_common()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/locking/rwsem.c?h=v6.0#n1247) setting state to [TASK_UNINTERRUPTIBLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n86)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n86) which indicates that while waiting for the lock the thread attempting to acquire the lock should be marked uninterruptible.

• [mmap_read_lock_killable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmap_lock.h?h=v6.0#n121) – Acquires a read lock on the mm_struct.

Wraps [down_read_killable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/locking/rwsem.c?h=v6.0#n1519) on mmap_lock. Ultimately invokes

[\_\_down_read_killable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/locking/rwsem.c?h=v6.0#n1269) which calls [\_\_down_read_common()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/locking/rwsem.c?h=v6.0#n1247) setting state to

[TASK_KILLABLE, ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n105)which indicates that while waiting for the lock the thread attempting to acquire the lock should respond to deadly signals, but oth-erwise be uninterruptible.

• [mmap_read_trylock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmap_lock.h?h=v6.0#n131) – Tries to acquire a read lock on the mm_struct.

Wraps [down_read_trylock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/locking/rwsem.c?h=v6.0#n1536) on mmap_lock. Ultimately invokes the function

[\_\_down_read_trylock() .](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/locking/rwsem.c?h=v6.0#n1274)

• [mmap_read_unlock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmap_lock.h?h=v6.0#n141) – Releases a read lock on the mm_struct. Wraps

[up_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/locking/rwsem.c?h=v6.0#n1592) on mmap_lock. Ultimately invokes the function [\_\_up_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/locking/rwsem.c?h=v6.0#n1323)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/locking/rwsem.c?h=v6.0#n1323)

• [mmap_read_unlock_non_owner()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmap_lock.h?h=v6.0#n147) – Releases a read lock on the mm_struct.

Wraps [up_read_non_owner()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/locking/rwsem.c?h=v6.0#n1682) which asserts that the thread that will release it is not the ‘owner’ of the lock. Only has an impact if CONFIG_DEBUG_LOCK_ALLOC is defined. Ultimately invokes the function

[\_\_up_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/locking/rwsem.c?h=v6.0#n1323).



**4.3.4.6 Use of mmap locks**

For the purposes of examining the lifetime and users of a process address

space’s mmap_lock the differences between these variants is of less importance

than whether a. a lock is being acquired/released and b. the lock is read-

/write.

In order to get a sense of just how important this lock is in the kernel and

how often it is used, let’s visualise the places where the read/write lock is

acquired/released.

This lock is quite so contended that covering every single usage of it

would be impractical. Therefore, the scope has been limited to:



• Exclude initialisation of [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) objects, as you would expect

the lock to be held here and it is unlikely to see much contention in this phase.

• Exclude all driver usage, huge page functionality, system V-style shared

memory functionality, cgroup and ptrace logic.

• The x86-64 architecture, if logic varies depending on architecture.

• ELF, if examining binary format-specific logic.



Focusing therefore on the core users of this lock let’s examine where

they are acquired and released, relatively exhaustively. This gives us a sense







of both where these locks are acquired as well as the breadth of functions which contend them.

The subsequent diagrams use this key:



Denotes that an mmap_lock is acquired (and typically released) in this function. If

an R W is present this denotes a read lock is acquired, if a is present this denotes

that a write lock is acquired. The meaning of the suffix can vary, as specified by accompanying text, e.g. (Releases) indicates a lock is released, not acquired.



Denotes that an mmap_lock is held on invocation of

this function, but acquired/released elsewhere.



syscall : Denotes that this function is a sys-tem call rather than a function invocation.



Denotes that this function is an interrupt handler, CPU exception handler,

or sits at a transition between user/kernel, rather than a function invocation.



W

syscall: [mremap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mremap.c?h=v6.0#n886)



(Downgrades to)

W R

syscall: [munmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2881) [\_\_vm_munmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2850) [\_\_do_munmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2754)



W

[vm_munmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2875) syscall: [brk()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n153) [do_brk_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2973)



syscall: [map_pgoff()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1593) syscall: [mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/sys_x86_64.c?h=v6.0#n86) syscall: [old_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1610)



(old mm)

R

[exec_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/exec.c?h=v6.0#n977) [elf_map()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/binfmt_elf.c?h=v6.0#n365) [ksys_mmap_pgoff()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1548) syscall: [msync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/msync.c?h=v6.0#n32)



W

[begin_new_exec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/exec.c?h=v6.0#n1243) [vm_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n562) [vm_mmap_pgoff()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n539)



execve() syscalls [load_elf_binary()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/binfmt_elf.c?h=v6.0#n824) [do_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1369) syscall: [remap_file_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2891)



*Figure 4-2: mmap* *mmap_lock* *invocations*





W

[dup_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1510) [dup_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n580)

If not [CLONE_VM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/sched.h?h=v6.0#n11) (i.e. not a thread)

W

[exit_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n3075) [copy_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1547) [copy_process()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1989)



(Via [mmput_async_fn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1213)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1213)

[\_\_mmput()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1179) [mmput_async()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1221) [kernel_clone()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n2630) syscall: [clone3()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n2947)



[mmput()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1203) syscall: [vfork()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n2760) syscall: [fork()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n2744) syscall: [clone()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n2789)



*Figure 4-3: Fork* *mmap_lock* *invocations*



(From figure 4-9)

R

[do_user_addr_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1220)



From figure 4-5 [handle_mm_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5129)



[remove_device_exclusive_entry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3613) [\_\_handle_mm_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4967) [do_numa_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4681)

If [is_device_exclusive_entry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swapops.h?h=v6.0#n153)

Else

[lock_page_or_retry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n998) [do_swap_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3718) [handle_pte_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4860) [do_anonymous_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4031)

(Try drop if can’t lock folio)

(Releases)

R

[\_\_folio_lock_or_retry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1713) [do_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4617) [do_wp_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3360)

(Release if [*fault_flag_allow_retry_first()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n453)

and not *FAULT_FLAG_RETRY_NOWAIT*,

or *FAULT_FLAG_KILLABLE* and [do_read_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4509) [do_cow_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4535) [do_shared_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4574)

[*\_\_folio_lock_killable()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1669) failed to acquire lock)



[\_\_do_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4147)

Via vma-\>vm_ops-\>fault()

[filemap_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3084)



(Releases)

R

[lock_folio_maybe_drop_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2928)



(Try drop if can’t lock folio and not*FAULT_FLAG_RETRY_NOWAIT*)

(Releases)

R

[maybe_unlock_mmap_for_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n607)

(Release if no pinned folio,

[*fault_flag_allow_retry_first()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree//include/linux/mm.h?h=v6.0#n453), and not *FAULT_FLAG_RETRY_NOWAIT*)



*Figure 4-4: Page fault* *mmap_lock* *invocations*



Note: If a fault releases the mmap_lock then the fault handler returns

[VM_FAULT_RETRY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n751) or [VM_FAULT_COMPLETED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n755).







syscall: [process_vm_readv()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/process_vm_access.c?h=v6.0#n291) syscall: [process_vm_writev()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/process_vm_access.c?h=v6.0#n298)



R

[process_vm_rw_single_vec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/process_vm_access.c?h=v6.0#n70) [process_vm_rw_core()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/process_vm_access.c?h=v6.0#n150)



[pin_user_pages_remote()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3186) [pin_user_pages_fast()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3110) [get_user_pages_fast()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3077)



[pin_user_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3221) [get_user_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2245) [internal_get_user_pages_fast()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2964)

Slow path, no *FOLL_FAST_ONLY*

(If FOLL_LONGTERM)

R

[get_user_pages_remote()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2198) [\_\_gup_longterm_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2063) [\_\_gup_longterm_unlocked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2892)



(Reacquires)

R R

[\_\_get_user_pages_remote()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2109) [\_\_get_user_pages_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1387) [get_dump_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1911)



(Reacquires)

R R FOLL_LONGTERM If not set

[fixup_user_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1327) [get_user_pages_unlocked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2272)



To [*handle_mm_fault()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5129) in figure 4-4 [pin_user_pages_unlocked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n3243)



R

[\_\_access_remote_vm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5438) From [access_remote_vm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5513) in figure 4-10



[access_process_vm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5524)



*Figure 4-5: GUP* *mmap_lock* *invocations*



R

[\_\_mm_populate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1652)



After write lock released

W

[do_mlock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n568)



syscall: [mlock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n615) syscall: [mlock2()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n620)



W W W

syscall: [munlock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n633) syscall: [mlockall()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n696) syscall: [munlockall()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n725)



*Figure 4-6:* *mlock() mmap_lock* *invocations*







(Reacquires read lock if

(Releases/reacquires read lock [*faultin_vma_page_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1605) (Releases/reacquires read lock

around [*vfs_fadvise()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/fadvise.c?h=v6.0#n180) call) releases it) around [*vfs_fadvise()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/fadvise.c?h=v6.0#n180) call)

R R R

[madvise_willneed()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n275) [madvise_populate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n881) [madvise_remove()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n942)



[madvise_vma_behavior()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n992)



(Lock taken depends on [madvise_need_mmap_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n50)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n50)

R/W

[do_madvise()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n1371)



syscall: [madvise()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n1424) syscall: [process_madvise()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n1429)



*Figure 4-7:* *madvise() mmap_lock* *invocations*





W

[dump_vma_snapshot()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/coredump.c?h=v6.0#n1148)



[do_coredump()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/coredump.c?h=v6.0#n511)



If [sig_kernel_coredump()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/signal.h?h=v6.0#n445)



[get_signal()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/signal.c?h=v6.0#n2626)



[arch_do_signal_or_restart()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/signal.c?h=v6.0#n865)



[exit_to_user_mode_loop()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/entry/common.c?h=v6.0#n145)



If \_TIF_SIGPENDING



[exit_to_user_mode_prepare()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/entry/common.c?h=v6.0#n191)



[\_\_syscall_exit_to_user_mode_work()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/entry/common.c?h=v6.0#n279) [irqentry_exit_to_user_mode()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/entry/common.c?h=v6.0#n304)



To figure 4-9



[syscall_exit_to_user_mode()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/entry/common.c?h=v6.0#n291) irq: [exc_int3()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/traps.c?h=v6.0#n810) irq: [exc_vmm_communication()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/sev.c?h=v6.0#n1981)



[ret_from_fork()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/entry/entry_64.S?h=v6.0#n287) [exc_debug_user()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/traps.c?h=v6.0#n1088) [irqentry_exit()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/entry/common.c?h=v6.0#n402)



IRQ handlers

irq: [exc_debug()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/traps.c?h=v6.0#n1169)



*Figure 4-8: Core dump (x86-64)* *mmap_lock* *invocation*





syscall: [rt_sigreturn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/signal.c?h=v6.0#n658) exc: [exc_general_protection()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/traps.c?h=v6.0#n719)

If bad frame

[signal_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/signal.c?h=v6.0#n900) [fixup_iopl_exception()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/traps.c?h=v6.0#n609)



R

[print_vma_addr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5545)



[show_signal_msg()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n768) [show_signal()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/traps.c?h=v6.0#n143)



[\_\_bad_area_nosemaphore()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n800) exc: [exc_bounds()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/traps.c?h=v6.0#n548) [gp_user_force_sig_segv()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/traps.c?h=v6.0#n710)



(Releases)

R

[bad_area_nosemaphore()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n852) [\_\_bad_area()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n859) [do_trap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/traps.c?h=v6.0#n158) exc: [exc_alignment_check()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/traps.c?h=v6.0#n370)

To figure 4-4 Before lock taken

R

[do_user_addr_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1220) [bad_area()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n873) [do_error_trap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/traps.c?h=v6.0#n175) [do_int3_user()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/traps.c?h=v6.0#n800)

From figure 4-8

[handle_page_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1476) [bad_area_access_error()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n896) [handle_invalid_op()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/traps.c?h=v6.0#n292) exc: [exc_divide_error()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/traps.c?h=v6.0#n203)



exc: [exc_page_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1500) exc: [exc_overflow()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/traps.c?h=v6.0#n209) exc: [exc_invalid_op()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/traps.c?h=v6.0#n327) exc: [exc_invalid_tss()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/traps.c?h=v6.0#n352)



exc: [exc_segment_not_present()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/traps.c?h=v6.0#n358) exc: [exc_stack_segment()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/traps.c?h=v6.0#n364)



exc: [exc_coproc_segment_overrun()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/traps.c?h=v6.0#n346)



*Figure 4-9: CPU exception (x86-64)* *mmap_lock* *invocations*





/proc/\$pid/map_files

Via [proc_map_files_inode_operations.lookup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/base.c?h=v6.0#n2337) Via [proc_map_files_operations.iterate_shared()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/base.c?h=v6.0#n2434)

R R

[proc_map_files_lookup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/base.c?h=v6.0#n2288) [proc_map_files_instantiate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/base.c?h=v6.0#n2265) [proc_map_files_readdir()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/base.c?h=v6.0#n2344)



Initialised on generated file inode

/proc/\$pid/smaps_rollup

Via [proc_pid_smaps_rollup_operations.open()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n1052)

R

[map_files_get_link()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/base.c?h=v6.0#n2192) /proc/\$pid/numa_maps [smaps_rollup_open()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n1004)

Via [proc_pid_numa_maps_operations.open()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n1999)

R R

[map_files_d_revalidate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/base.c?h=v6.0#n2141) [pid_numa_maps_open()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n1993) [show_smaps_rollup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n876)

Via [proc_pid_numa_maps_op](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n1986)

/proc/\$pid/smaps

Via [proc_pid_smaps_operations.open()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n1045)

[pid_smaps_open()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n999)



Via [proc_pid_smaps_op()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n992)

(Releases)

R R R W

[pagemap_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n1627) [m_start()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n127) [m_stop()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n183) [clear_refs_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n1238)

Via [proc_pid_maps_op()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n351)

Via [proc_pagemap_operations.read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n1736) Via [proc_clear_refs_operations.write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n1314)

/proc/pagemap [pid_maps_open()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n358) /proc/\$pid/clear_refs

Via [proc_pid_maps_operations.open()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n363)

To [*\_\_access_remote_vm()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5438) in figure 4-5 /proc/\$pid/maps /proc/\$pid/mem



[mem_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/base.c?h=v6.0#n892)

Via [proc_mem_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/base.c?h=v6.0#n928)

[access_remote_vm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5513) [mem_rw()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/base.c?h=v6.0#n837)

.read()/write()

[mem_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/base.c?h=v6.0#n898)



[get_mm_proctitle()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/base.c?h=v6.0#n218) [get_mm_cmdline()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/base.c?h=v6.0#n255) [get_task_cmdline()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/base.c?h=v6.0#n342) /proc/\$pid/cmdline

Via [proc_environ_operations.read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/base.c?h=v6.0#n1004)

[environ_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/base.c?h=v6.0#n941) /proc/\$pid/environ [proc_pid_cmdline_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/base.c?h=v6.0#n357) Via [proc_pid_cmdline_ops](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/base.c?h=v6.0#n375) .read()



*Figure 4-10: procfs* *mmap_lock* *invocations*





R

[oom_reap_task_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n567)



[oom_reap_task()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n608)



[oom_reaper()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n639)



Kernel thread for

OOM reaping



R

syscall: [process_mrelease()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n1201)



*Figure 4-11: Out Of Memory (OOM) killer* *mmap_lock* *invocations*



R

[replace_mm_exe_file()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1279)



[prctl_set_mm_exe_file()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sys.c?h=v6.0#n1867)



Before lock taken

R

[prctl_set_mm_map()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sys.c?h=v6.0#n1966)

PR_SET_MM_EXE_FILE

PR_SET_MM_MAP



(Lock taken only if (Lock taken on not above options) *PR_SET_VMA_ANON_NAME*)

R W

[prctl_set_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sys.c?h=v6.0#n2104) [prctl_set_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sys.c?h=v6.0#n2296)

PR_SET_MM PR_SET_VMA



W

syscall: [prctl()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sys.c?h=v6.0#n2348)

(Lock acquired in syscall if *PR_SET_THP_DISABLE*)



*Figure 4-12:* *prctl() mmap_lock* *invocations*







(If MPOL_F_ADDR)

W R R

[do_mbind()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mempolicy.c?h=v6.0#n1240) [do_migrate_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mempolicy.c?h=v6.0#n1085) [do_get_mempolicy()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mempolicy.c?h=v6.0#n914)



[kernel_mbind()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mempolicy.c?h=v6.0#n1450) [kernel_migrate_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mempolicy.c?h=v6.0#n1575) [kernel_get_mempolicy()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mempolicy.c?h=v6.0#n1672)



syscall: [mbind()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mempolicy.c?h=v6.0#n1542) syscall: [migrate_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mempolicy.c?h=v6.0#n1663) syscall: [get_mempolicy()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mempolicy.c?h=v6.0#n1701)



R R W

[add_page_for_migration()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/migrate.c?h=v6.0#n1654) [task_numa_work()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/fair.c?h=v6.0#n2762) syscall: [set_mempolicy_home_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mempolicy.c?h=v6.0#n1471)



Kernel thread for

[do_pages_move()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/migrate.c?h=v6.0#n1748)

NUMA balancing



R

[kernel_move_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/migrate.c?h=v6.0#n1987) [do_pages_stat()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/migrate.c?h=v6.0#n1903) [do_pages_stat_array()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/migrate.c?h=v6.0#n1842)



syscall: [move_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/migrate.c?h=v6.0#n2017)



*Figure 4-13: NUMA* *mmap_lock* *invocations*



R

[unuse_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n1989)



W

[try_to_unuse()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n2038) [do_mprotect_pkey()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mprotect.c?h=v6.0#n662)



[do_mincore()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mincore.c?h=v6.0#n187) syscall: [swapoff()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n2386) syscall: [mprotect()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mprotect.c?h=v6.0#n805)



R

syscall: [mincore()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mincore.c?h=v6.0#n232)



*Figure 4-14: Miscellaneous* *mmap_lock* *invocations*



***4.3.5 Process address space flags***

The [struct mm_struct-\>flags](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) field contains a bitmap of fields that de-scribe attributes of a process address space. These are defined in

[include/linux/sched/coredump.h, ](https://elixir.bootlin.com/linux/v6.0/source/include/linux/sched/coredump.h)(despite being located here not all relate to core dumps). Examining each flag:



**4.3.5.1 Core dump user flags**

A core dump is the means by which, typically on a segfault or otherwise ab-normal exit, the memory state of a process is written to disk to a ‘core file’ (specified in /proc/sys/kernel/core_pattern) which can be examined after the







fact for debugging purposes (see the [/proc/sys/kernel documentation](https://kernel.org/doc/html/v6.0/admin-guide/sysctl/kernel.html) for more

on this).

Note that these indicate values not bit indexes. These occupy the first

[MMF_DUMPABLE_BITS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/coredump.h?h=v6.0#n14) (i.e. 2) bits of the flags field:



• SUID_DUMP_DISABLE – Core dumping is disabled altogether.

• SUID_DUMP_USER – Core dumping will be performed by the process user –

this is the default mode, unless the binary being dumped is setuid and /proc/sys/fs/suid_dumpable indicates a different one.

• SUID_DUMP_ROOT – Core dumping will be performed by the root user.



These are accessed via [\_\_get_dumpable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/coredump.h?h=v6.0#n24) (parameterised by the flags

themselves) and [get_dumpable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/coredump.h?h=v6.0#n24) (parameterised by a mm_struct) and set by

[set_dumpable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/exec.c?h=v6.0#n2079).

Userland can adjust a process’s dump mode via [prctl()](https://man7.org/linux/man-pages/man2/prctl.2.html) (specifying the

PR_SET_DUMPABLE mode), though it is now prohibited to set SUID_DUMP_ROOT this

way. The mode defaults to SUID_DUMP_USER if not otherwise specified.

If a binary is setuid then the mode will be determined by

/proc/sys/fs/suid_dumpable – the index matching each of the modes speci-

fied above (see the [/proc/sys/fs documentation](https://kernel.org/doc/html/v6.0/admin-guide/sysctl/fs.html) for more on this). This is de-

termined in [begin_new_exec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/exec.c?h=v6.0#n1243) and modified if process credentials change in

[commit_creds()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/cred.c?h=v6.0#n447).



**4.3.5.2 Core dump filter flags**

Which classes of memory that get core dumped are also stored in the

struct mm_struct-\>flags fields and specified in /proc/\$pid/coredump_filter (or

via the coredump_filter kernel parameter), see the [proc documentation](https://kernel.org/doc/html/v6.0/filesystems/proc.html) for more

details on how to read and set these.

Note that each VMA can override the dumping process altogether by

specifying the VM_DONTDUMP flag. And on the other hand, certain kinds of

VMAs always get dumped, as determined via [always_dump_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/coredump.c?h=v6.0#n996) – any VMA

that has a name assigned to it is assumed to always be important, as well as

the vsyscall mapping.

Examining each of these flags, which are processed by [vma_dump_size()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/coredump.c?h=v6.0#n1024)[:](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/coredump.c?h=v6.0#n1024)



• MMF_DUMP_ANON_PRIVATE – Dump anonymous, non-huge private VMAs.

• MMF_DUMP_ANON_SHARED – Dump anonymous, non-huge shared VMAs.

• MMF_DUMP_MAPPED_PRIVATE – Dump file-mapped, private VMAs.

• MMF_DUMP_MAPPED_SHARED – Dump file-mapped, shared VMAs (if the

file is anonymous, e.g. created by [memfd()](https://man7.org/linux/man-pages/man2/memfd.2.html)[,](https://man7.org/linux/man-pages/man2/memfd.2.html) then this will degrade to MMF_DUMP_ANON_SHARED).

• MMF_DUMP_ELF_HEADERS – Dump ELF headers. Requires the VM_READ flag to

be set and the VMA to not be offset.

• MMF_DUMP_HUGETLB_PRIVATE – Dump hugetlb private mapping, as deter-

mined via [is_vm_hugetlb_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/hugetlb_inline.h?h=v6.0#n9)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/hugetlb_inline.h?h=v6.0#n9) i.e. requiring the VM_HUGETLB VMA flag to be set. Requires VMA_SHARED to not be set.







• MMF_DUMP_HUGETLB_SHARED – Dump hugetlb shared mapping, determined as

above, only with VMA_SHARED set.

• MMF_DUMP_DAX_PRIVATE – Dumps a DAX (Direct Access for files system, dis-

cussed in [DAX documentation](https://kernel.org/doc/html/v6.0/filesystems/dax.html)) private VMA block. Out of scope for the book.

• MMF_DUMP_DAX_SHARED – Dumps a DAX shared VMA block. Out of scope for

the book.



The default flags are determined by [MMF_DUMP_FILTER_DEFAULT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/coredump.h?h=v6.0#n49)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/coredump.h?h=v6.0#n49) set-

ting MMF_DUMP_ANON_PRIVATE, MMF_DUMP_ANON_SHARED, MMF_DUMP_HUGETLB_PRIVATE and MMF_DUMP_MASK_DEFAULT_ELF which enables MMF_DUMP_ELF_HEADERS if CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is configured.



**4.3.5.3 Other flags**

There are a number of other non-coredump flags which mm_struct objects can possess. Examining them:



• MMF_VM_MERGEABLE – Used by [Kernel Samepage Merging (KSM)](https://kernel.org/doc/html/v6.0/mm/ksm.html) logic to mark

a VMA as mergeable. Out of scope for the book.

• MMF_VM_HUGEPAGE – Used by [Transparent Huge Pages (THP)](https://kernel.org/doc/html/v6.0/mm/transhuge.html) (more on this

in the huge pages chapter) to indicate that folios in this process can be converted into huge pages. Checked by the khugepaged kernel thread on

[khugepaged_fork()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/khugepaged.h?h=v6.0#n27) (called on fork from [dup_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n580). If this flag is set then

[\_\_khugepaged_enter()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/khugepaged.c?h=v6.0#n433) is invoked which marks the mm_struct as available for

use. Checked again on exit in [khugepaged_exit()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/khugepaged.h?h=v6.0#n33) which is called when an

mm_struct is torn down in [\_\_mmput()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1179).

• MMF_HAS_UPROBES – Used to indicate that the mm_struct has [uprobes](https://kernel.org/doc/html/v6.0/trace/uprobetracer.html) present

in its address space. Out of scope for the book.

• MMF_RECALC_UPROBES – Indicates that uprobes need to be recalculated for

this mm_struct. Out of scope for the book.

• MMF_OOM_SKIP – Indicates that memory of the process belonging to the

mm_struct should be ignored by the Out Of Memory (OOM) killer. Set

in [exit_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n3075) when a process is identified to already be an OOM vic-

tim via [mm_is_oom_victim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/oom.h?h=v6.0#n84) (which checks the MMF_OOM_VICTIM flag), in

[oom_reap_task()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n608) after reaping is complete to achieve the same ends and

in [\_\_oom_kill_process()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n917) if the process is the global init process (checked

by [is_global_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n1692)).

• MMF_UNSTABLE – Set by the OOM killer in [\_\_oom_reap_task_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n512) to indi-

cate that the address space being reaped is no longer stable, as indi-

cated by [check_stable_address_space()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/oom.h?h=v6.0#n102) and checked by [do_anonymous_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4031),

[finish_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4345), huge page equivalents and memory migration code.

• MMF_HUGE_ZERO_PAGE – Indicates that a huge zero page has been obtained

for the address space via [mm_get_huge_zero_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/huge_memory.c?h=v6.0#n191)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/huge_memory.c?h=v6.0#n191)

• MMF_DISABLE_THP – Disables Transparent Huge Pages (THP) altogether. Set

by [prctl()](https://man7.org/linux/man-pages/man2/prctl.2.html) (specifying the PR_SET_THP_DISABLE mode), and can be queried







either via prctl() using PR_GET_THP_DISABLE or from observing the status in

proc/\$pid/status. Checked in [hugepage_vma_check()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/huge_memory.c?h=v6.0#n73) (alongside checking the VMA flag VM_NOHUGEPAGE).

• MMF_OOM_VICTIM – Set to indicate that a process is a victim of the OOM

killer in [mark_oom_victim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n757) and checked via [mm_is_oom_victim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/oom.h?h=v6.0#n84) which de-

termines whether to set MMF_OOM_SKIP in [exit_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n3075) as described above.

• MMF_OOM_REAP_QUEUED – Both tested and set in [queue_oom_reaper()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n691) to mark

that the process will be the subject of OOM repeating and to set up the timer to do just that.

• MMF_MULTIPROCESS – Indicates that the mm_struct is referenced by mul-

tiple processes. Set when a process is copied via [copy_process()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1989) in

[copy_oom_score_adj()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n1950) and used in [\_\_set_oom_adj()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/base.c?h=v6.0#n1060) to ensure that the

mm_struct gets pinned (i.e. [mmgrab()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n35) applied to it to increment its mm_count reference count.

• MMF_HAS_PINNED – Set by the Get User Pages (GUP) logic in

[mm_set_has_pinned_flag()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n437) to indicate that FOLL_PIN has been set and thus the invocation of GUP is intended to pin folios in the process. Once set, this is maintained for the process lifetime. Checked in

[page_needs_cow_for_dma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1526) to determine if folios might be pinned for DMA

(which would have set this pinned flag) and in [pte_is_pinned()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n1074) which is

used by [clear_soft_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n1090) to clear the soft dirty flag, but explicitly not when pinned folios could be present.



**4.4 Virtual Memory Areas (VMAs)**



Each contiguous range of virtual memory with similar characteristics (more

specifically ranges which handle page faults\* in the same fashion) are repre-

sented by Virtual Memory Areas (VMAs).

These are ultimately the fundamental building block upon which user-

land memory allocations are built – a process has memory mapped at an

address if it has a VMA spanning the base page containing it.

Since we can ‘fault in’ memory on demand, we don’t actually need to

have physical memory allocated or even page table mappings established

for a memory range to be valid, rather we simply mark that it is valid in its

containing VMA.

Examining a simplified [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (retaining the key fields) as

shown in Listing 4-11.



397 */\**

398 *\* This struct describes a virtual memory area. There is one of these* 399 *\* per VM-area/task. A VM area is any part of the process virtual memory* 400 *\* space that has a special rule for the page-fault handlers (ie a shared*



\*. A page fault occurs when memory is either not virtually mapped or is not permitted to be

accessed in the fashion the user is attempting to (e.g. writing to memory with page table flags

indicating that it is read-only), we shall describe this in considerably more detail shortly.







401 *\* library, the executable area etc).* 402 *\*/*

403 **struct** vm_area_struct {

404 */\* The first cache line has the info for VMA tree walking. \*/* 405

406 **unsigned long** vm_start; */\* Our start address within vm_mm. \*/* 407 **unsigned long** vm_end; */\* The first byte after our end*

*address*

408 *within vm_mm. \*/* 409

410 */\* linked list of VM areas per task, sorted by address \*/* 411 **struct** vm_area_struct \*vm_next, \*vm_prev; 412

413 **struct** rb_node vm_rb; 414

415 */\**

416 *\* Largest free memory gap in bytes to the left of this VMA.* 417 *\* Either between this VMA and vma-\>vm_prev, or between one of the*

418 *\* VMAs below us in the VMA rbtree and its -\>vm_prev. This helps*

419 *\* get_unmapped_area find a free area of the right size.* 420 *\*/*

421 **unsigned long** rb_subtree_gap; 422

423 */\* Second cache line starts here. \*/* 424

425 **struct** mm_struct \*vm_mm; */\* The address space we belong to. \*/* 426

427 */\**

428 *\* Access permissions of this VMA.* 429 *\* See vmf_insert_mixed_prot() for discussion.* 430 *\*/*

431 **pgprot_t** vm_page_prot; 432 **unsigned long** vm_flags; */\* Flags, see mm.h. \*/* 433

434 */\**

435 *\* For areas with an address space and backing store,* 436 *\* linkage into the address_space-\>i_mmap interval tree.* 437 *\**

438 *\* For private anonymous mappings, a pointer to a null terminated*

*string*

439 *\* containing the name given to the vma, or NULL if unnamed.* 440 *\*/*

441

442 **union** {

443 **struct** {

444 **struct** rb_node rb; 445 **unsigned long** rb_subtree_last;







446 } shared; 447 */\**

448 *\* Serialized by mmap_sem. Never use directly because it is*

449 *\* valid only when vm_file is NULL. Use anon_vma_name instead.*

450 *\*/*

451 **struct** anon_vma_name \*anon_name; 452 };

453

454 */\**

455 *\* A file's MAP_PRIVATE vma can be in both i_mmap tree and anon_vma*

456 *\* list, after a COW of one of the file pages. A MAP_SHARED vma* 457 *\* can only be in the i_mmap tree. An anonymous MAP_PRIVATE, stack*

458 *\* or brk vma (with NULL file) can only be in an anon_vma list.* 459 *\*/*

460 **struct** list_head anon_vma_chain; */\* Serialized by mmap_lock &* 461 *\* page_table_lock \*/* 462 **struct** anon_vma \*anon_vma; */\* Serialized by page_table_lock \*/*

463

464 */\* Function pointers to deal with this struct. \*/* 465 **const struct** vm_operations_struct \*vm_ops;

466

467 */\* Information about our backing store: \*/* 468 **unsigned long** vm_pgoff; */\* Offset (within vm_file) in*

*PAGE_SIZE*

469 *units \*/* 470 **struct** file \* vm_file; */\* File we map to (can be NULL). \*/* 471 **void** \* vm_private_data; */\* was vm_pte (shared mem) \*/*

. . .

480 **struct** mempolicy \*vm_policy; */\* NUMA policy for the VMA \*/*

. . .

483 } **\_\_randomize_layout**;



*Listing 4-11:* include/linux/mm_types.h: *Simplified [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403)*



Examining each field:



• vm_start – The first address mapped by this region. Must be page-

aligned.

• vm_end – The exclusive upper bound of memory mapped by this region,

i.e. 1 byte beyond the memory it maps.

• vm_next – The next VMA in the process address space, sorted by address,

or NULL if this is the last.

• vm_prev – The previous VMA in the process address space, sorted by ad-

dress, or NULL if this is the first.

• vm_rb – Node object with linkage for this VMA within the binary red-

black tree of VMAs contained within the process address space and

rooted on [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)-\>mm_rb.







• rb_subtree_gap – The largest free gap in all of the nodes to

the left of us in the binary tree, i.e., the largest difference be-tween the vm_end and vm_start of adjacent VMAs at or below this one. This is used to more efficiently determine an appropri-

ate free area in which to place a mapping in [get_unmapped_area()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2209)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2209)

This is calculated via [vma_gap_callbacks_compute_max()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n395) via the

macro generator [RB_DECLARE_CALLBACKS_MAX()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rbtree_augmented.h?h=v6.0#n120)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rbtree_augmented.h?h=v6.0#n120) This is reference in vma_gap_callbacks_propagate(), generated by the same macro and invoked

by [vma_gap_update()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n404) which performs the subtree gap update. The field is used to determine an unmapped area in which to place a mapping in

[unmapped_area()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1863).

• vm_mm – A pointer to the process address space’s [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) to which

this VMA belongs.

• vm_page_prot – The [pgprot_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n263) protection bits to be applied to PTEs

(or higher order page tables if huge page) within the range defined by the VMA. This is applied in the various page fault handlers, for

example in [do_anonymous_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4031) where the field is referenced via entry = mk_pte(page, vma-\>vm_page_prot). This field is iniitially determined

from the architecture-specific [vm_get_page_prot()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgprot.c?h=v6.0#n35) function, which for x86-

64 are determined by the [protection_map](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgprot.c?h=v6.0#n8) array, as described in the virtual memory chapter in figure 3.13 in which the chosen bits are determined from the vm_flags field described below. Note that this can be further

modified via [vma_set_page_prot()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n90)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n90) specifically when a non-anonymous mapping’s underlying VMA requires that it is notified when a write first

occurs, as determined by [vma_wants_writenotify()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1630).

• vm_flags – Flags describing the VMA. This is a broad topic see below in

section 4.4.1 for a detailed discussion.

• shared.rb – If file-backed (i.e. referencing a [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) object),

a node object used for placement into the interval tree hung off the ad-

dress space’s i_mmap field. Discussed in detail in section 4.5.

• shared.rb_subtree_last – Used in conjunction with the rb note described

above as part of the address space interval tree placement. Again, see

section 4.5 for a discussion of this.

• anon_name – This is held in union with the shared object described above,

so this field is only present in the case of VMAs mapping anonymous memory. This contains a name describing the mapping, e.g. heap, stack, etc. Access to this field is serialised by the mmap_lock semaphore which must be held when this function is invoked. It should be ob-

tained via the [anon_vma_name()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n93) function which asserts that this lock is

held via [mmap_assert_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmap_lock.h?h=v6.0#n153) as described in section 4.3.4.3. This is rep-

resented by a dynamically allocated [struct anon_vma_name](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n391) object which wraps a reference count using the generic kernel reference counter type

[struct kref](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/kref.h?h=v6.0#n19), as well as the string containing the name itself. It is allocated

by [anon_vma_name_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n70), a reference taken on it via [anon_vma_name_get()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n159)

and released by [anon_vma_name_put()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n165) (which, if the reference count







reaches zero, frees it via [anon_vma_name_free()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n86)[).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n86) Anonymous VMA names are only available if CONFIG_ANON_VMA_NAME is specified.

• anon_vma – Represents an object which links folios with VMAs. Since

VMAs are ephemeral and multiple different VMAs can reference the same regions in memory, it is not practical to attempt to reference the VMAs in a folio or the folios in a VMA. Instead, an intermediate object,

the [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31), is used to tie the two together. The use of this object

is termed a memory range’s reverse mapping as described in Chapter 7. This field references this object if such a mapping exists for this VMA.

Access to this field is serialised by the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)-\>page_table_lock

as described in section 4.3.4.1.

• anon_vma_chain – Forking means that an anon_vma object can be-

come tied to multiple different processes. To tie them together,

[struct anon_vma_chain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82) objects are hung off this field using the same_vma

field. See section 4.3.4.1 for more.

• vm_ops – Contains operations defined in the [struct vm_operations_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n539)

which provide callbacks for a number of different operations, arguably the most notable of which is the page fault handler specified in its fault field (and huge page equivalent in its huge_fault field). This field is in-timately tied into page fault behaviour, and we will therefore discuss it

detail in the dedicated section 6.

• vm_pgoff – If file-backed, the offset into the underlying file specified in

base pages. If anonymous, the ‘virtual page offset’ at which the mem-

ory was originally mapped (i.e. before any [mremap()](https://man7.org/linux/man-pages/man2/mremap.2.html)) which is the virtual address of its mapping specified in base pages. In both cases the page

offset of an address within a VMA is determined by [linear_page_index()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n845). There are special cases where this might be different, such as kernel

memory mapped into userland via [remap_pfn_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2540), see section 6.12 for more details on such special mappings.

• vm_file – If file-backed, this references the [struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) object which de-

scribes the file which this memory maps. NULL if the VMA describes an anonymous mapping.

• vm_private_data – A field available for private use by drivers and ‘special’

mappings.

• vm_policy – A field used to keep track of the NUMA ‘memory policy’ that

applies to this memory range as defined by an [struct mempolicy](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mempolicy.h?h=v6.0#n44) object. This is superseded by the vm_ops-\>get_policy() callback if it is specified as

looked up by the [\_\_get_vma_policy()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mempolicy.c?h=v6.0#n1736) function (via [get_vma_policy()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mempolicy.c?h=v6.0#n1773)[).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mempolicy.c?h=v6.0#n1773) See chapter 10 for more details on NUMA.



***4.4.1 VMA flags***

A VMA’s [struct vm_area_struct-\>vm_flags](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) field contains a bit map of flags

which describe its properties and determine what happens on page fault.

Each unique subset of flags defines a distinct VMA, even if two regions







with different flags are immediately adjacent to one another (ignoring VM_SOFTDIRTY which is considered ephemeral). There are other characteris-tics which determine whether one VMA is equivalent to (or mergeable with)

another, as determined by [is_mergeable_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n989)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n989)

Examining each of the flags, all of which are declared in the

[include/linux/mm.h](https://elixir.bootlin.com/linux/v6.0/source/include/linux/mm.h) header. Note that where architecture-specific behaviour is defined, we describe x86-64 for brevity:



• VM_NONE – (not a flag but rather the zero value) – Indicates that no flags

are specified at all. Will result in page table flags equal to [PAGE_NONE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n180). This is equivalent to having absolutely no flags set and is useful for the

[protection_map](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgprot.c?h=v6.0#n8) mappings between VMA flags and page table flags to des-ignate a case where neither VM_SHARED, VM_READ, VM_WRITE nor VM_EXEC is set when masked against those fields alone.

• VM_READ – Set when the memory range a VMA describes has permission

to be read from. When memory is mapped with the PROT_READ flag then this field is set.

• VM_WRITE – Set when the memory range a VMA describes has permission

to be written to. When memory is mapped with the PROT_WRITE flag then this field is set.

• VM_EXEC – Set when the memory range a VMA describes has permission

to be executed. When memory is mapped with the PROT_EXEC flag then this field is set.

• VM_SHARED – Set when the memory range a VMA describes is memory will

be shared between processes. With this set, Copy-on-Write semantics will not apply, otherwise they always will with the memory mapped to

the zero page\*. When memory is mapped with the MAP_SHARED flag then this field is set.

• VM_MAYREAD – This indicates that the memory range a VMA describes is

capable of being read from, even if VM_READ is not currently set, implying

that this might be changed by something like [mprotect()](https://man7.org/linux/man-pages/man2/mprotect.2.html).

• VM_MAYWRITE – This indicates that the memory range a VMA describes is

capable of being written to, even if VM_WRITE is not currently set, implying

that this might be changed by something like [mprotect()](https://man7.org/linux/man-pages/man2/mprotect.2.html). If this is set but VM_SHARED is not, then this mapping will be a Copy-on-Write mapping, as the fact that it can be written to but is not shared implies that it later be-coming will be as a Copy-on-Write mapping. This condition is checked

via [is_cow_mapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1219)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1219)

• VM_MAYEXEC – This indicates that the memory range a VMA describes is

capable of code being executed within it, even if VM_EXEC is not currently

set, implying that this might be changed by something like [mprotect()](https://man7.org/linux/man-pages/man2/mprotect.2.html)[.](https://man7.org/linux/man-pages/man2/mprotect.2.html)



\*. The zero page is an area of memory which is kept zeroed. By pointing Copy-on-Write map-pings to this page initially, reads will be zeroed and writes will actually result a dedicated page of memory being allocated for the mapping.







• VM_MAYSHARE – A slightly odd flag, as VMAs cannot transition between

shared and unshared in the same way they can with the protection flags (read, write and execute). It appears to only be meaningful for architec-tures without MMU where it seems necessary to associate the capability of being shared with a specific VMA. For modern architectures this is interchangeable with VM_SHARED as it can and is only set when this flag is also set.

• VM_GROWSDOWN – Indicates that the VMA describes this process’s stack

which grows downwards. For architectures which have upward growing stacks or both, the VM_GROWSUP flag is also defined.

• VM_PFNMAP – Indicates that the memory range a VMA describes have no

[struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256)s to describe them. This is typically used for mapping device

memory into userland, often via [remap_pfn_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2540).

• VM_LOCKED – Indicates that the memory described by the VMA has been

locked via [mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html)[.](https://man7.org/linux/man-pages/man2/mlock.2.html) It is set before locking memory within the VMA and used both by the mlock logic itself to determine whether it is locking or

unlocking (in [mlock_pte_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n308)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n308) as well as kernel logic which needs to know this, most notably reclaim where a folio may have become subject

to reclaim before it was able to be taken off LRU lists (see section 11.2 for more on this). Memory locked in this way is also faulted in.

• VM_LOCKONFAULT – Defer [mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html)[ing](https://man7.org/linux/man-pages/man2/mlock.2.html) folios until page fault within the mem-

ory range described by this VMA. This is set by the user either passing MLOCK_ONFAULT to mlock2() or MCL_ONFAULT to mlockall(). If a mlock() opera-tion is performed without this flag set, then the range specified is faulted into memory. If the flag is set then the memory is not faulted in, as en-

forced by [populate_vma_page_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1535).

• VM_IO – Indicates that the VMA range maps memory which is backed by

an I/O interface rather than physical memory. This indicates that the memory should not be accessed by the kernel as doing so can cause un-expected side effects. Typically this is backed by memory-mapped I/O device registers but doesn’t necessarily have to be. This is often set by

[remap_pfn_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2540) (which in turn calls [remap_pfn_range_notrack()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2475)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2475) which sets this flag, VM_PFNMAP, VM_DONTEXPAND and VM_DONTDUMP. Typically checks within the kernel avoiding accessing this memory check either this flag or VM_PFNMAP and equally avoid both.

• VM_SEQ_READ – Indicates that the memory (this is really only meaningful if

a file is mapped) by this VMA will be consumed sequentially – increase

readahead pages (via [do_sync_mmap_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2968)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2968) and be more aggressive in

reclaim after they are read (checked for in [folio_referenced_one()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n816)). This is

set via [madvise()](https://man7.org/linux/man-pages/man2/madvise.2.html) using the MADV_SEQUENTIAL flag.

• VM_RAND_READ – Indicates that the memory (this is really only meaningful

if a file is mapped) by this VMA will be consumed non-sequentially, i.e. with random access – readahead is considerably less useful so avoid it (as

enforced in [do_sync_mmap_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2968) and [do_async_mmap_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3037)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3037) This

is set via [madvise()](https://man7.org/linux/man-pages/man2/madvise.2.html) using the MADV_RANDOM flag.







• VM_DONTCOPY – Indicates that this VMA should not be copied when a pro-

cess forks. This is checked in [dup_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n580) and can be set by [madvise()](https://man7.org/linux/man-pages/man2/madvise.2.html) using MADV_DONTFORK and cleared by MADV_DOFORK, as well as being set by the kernel where forking certain memory ranges would be inappropriate.

• VM_DONTEXPAND – Indicates that the VMA must not be expanded by

[mremap()](https://man7.org/linux/man-pages/man2/mremap.2.html). This is useful for cases where it simply would not make any sense to expand such mappings, such as device-mapped memory and

indeed is set by [remap_pfn_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2540).

• VM_DONTDUMP – Indicates that the memory range described by the VMA

should not appear in core dumps. This can be set by [madvise()](https://man7.org/linux/man-pages/man2/madvise.2.html) using MADV_DONTDUMP (and cleared by MADV_DODUMP) but is also set by the kernel for memory which would not be appropriate in a core dump such as device

or secret memory (and again this is set by [remap_pfn_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2540)).

• VM_WIPEONFORK – Indicates that the memory range described by the VMA

should be cleared on fork rather than placed in a Copy-on-Write re-

lationship with its child process. This can be set by [madvise()](https://man7.org/linux/man-pages/man2/madvise.2.html) using MADV_WIPEONFORK (and cleared by MADV_KEEPONFORK), but is also used by the kernel to prevent forking of memory where doing so would be inappro-priate. This flag is only valid for private anonymous memory.

• VM_NORESERVE – Specifies that no swap space should be reserved for the

memory range described by this VMA, though only meaningful if the

overcommit mode (see section 4.1) is not set to [OVERCOMMIT_NEVER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/mman.h?h=v6.0#n14). This

is specified on [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) by specifying the MAP_NORESERVE flag. See the swap chapter for more on how swap functions in the kernel.

• VM_SOFTDIRTY – An ephemeral flag which indicates that memory within

the VMA has been written to since last cleared using the [soft-dirty](https://kernel.org/doc/html/v6.0/admin-guide/mm/soft-dirty.html) func-tionality within the kernel. Unlike other VMA flags, this flag has no bearing as to whether one VMA is independent from another – if two VMAs are identical other than this flag, then they can be merged (as en-

forced by [is_mergeable_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n989)[).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n989)

• VM_ACCOUNT – Indicates that the memory range described by this VMA is

accounted for the purposes of overcommit (see section 4.1 for more on

this), set in [vm_acct_memory()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mman.h?h=v6.0#n73)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mman.h?h=v6.0#n73) Whether memory is accountable or not is

determined by [accountable_mapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1669) – if the VMA has the VM_WRITE flag but has neither VM_NORESERVE nor VM_SHARED set, then it is accountable. Accountable memory updates the Committed_AS statistics observable in /proc/meminfo.

• VM_MIXEDMAP – The memory range described by this VMA contains a mix

of both [struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256)-described memory as well as VM_PFNMAP-style ‘pure PFNs’ mappings. This is used to enable Copy-on-Write of ‘special’ map-pings the discussion of which is out of scope here.

• VM_HUGEPAGE – Indicates that the memory range described by this VMA

has been marked as MADV_HUGEPAGE by [madvise()](https://man7.org/linux/man-pages/man2/madvise.2.html) in order to mark the range

as suitable for coalescing into [Transparent Huge Pages (THP)](https://kernel.org/doc/html/v6.0/admin-guide/mm/transhuge.html)[.](https://kernel.org/doc/html/v6.0/admin-guide/mm/transhuge.html) This is only meaningful if the /sys/kernel/mm/transparent_hugepages/enabled sysfs







tunable is set to madvise. See the huge page chapter for more details on THP.

• VM_NOHUGEPAGE – Similar to VM_HUGEPAGE, this indicates that the memory

range described by this VMA has been marked as MADV_NOHUGEPAGE by

[madvise()](https://man7.org/linux/man-pages/man2/madvise.2.html), indicating that this memory is not suited to being coalesced into a huge page by the THP functionality. See the huge page chapter for more details on THP.

• VM_HUGETLB – Indicates that the memory range described by this VM com-

prises the backing for a [hugetlb](https://kernel.org/doc/html/v6.0/admin-guide/mm/hugetlbpage.html) huge page region of memory. see the huge page chapter for more details on this.

• VM_MERGEABLE – Used by [Kernel Samepage Merging (KSM)](https://kernel.org/doc/html/v6.0/mm/ksm.html) logic to mark a

VMA as mergeable. Out of scope for this book.

• VM_UFFD_MISSING – Used for tracking missing pages within [userfaultfd](https://man7.org/linux/man-pages/man2/userfaultfd.2.html)

memory ranges. This is out of scope for the book.

• VM_UFFD_WP – Used for tracking write-protected pages within [userfaultfd](https://man7.org/linux/man-pages/man2/userfaultfd.2.html)

memory ranges. This is out of scope for the book.

• VM_SYNC – Used by the [Direct Access for files (DAX)](https://kernel.org/doc/html/v6.0/filesystems/dax.html) logic to indicate syn-

chronous page faults should occur. Discussion of DAX is out of scope for the book.



***4.4.2 Allocation and freeing***

VMA objects are allocated via [vm_area_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n455) which simply allocates from a

slab cache via [kmem_cache_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/slub.c?h=v6.0#n3271) (more on this in the slab chapter) as shown

in Listing 4-12.



455 **struct** vm_area_struct \***vm_area_alloc**(**struct** mm_struct \*mm) 456 {

457 **struct** vm_area_struct \*vma;

458

459 vma = **kmem_cache_alloc**(**vm_area_cachep**, **GFP_KERNEL**); 460 **if** (vma)

461 **vma_init**(vma, mm); 462 **return** vma;

463 }



*Listing 4-12:* kernel/fork.c: [*vm_area_alloc()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n455)



This calls [vma_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n614) to perform initialisation as shown in Listing 4-13.



614 **static inline void vma_init**(**struct** vm_area_struct \*vma, **struct** mm_struct \*mm) 615 {

616 **static const struct** vm_operations_struct dummy_vm_ops = {};

617

618 **memset**(vma, 0, **sizeof**(\*vma)); 619 vma-\>vm_mm = mm;

620 vma-\>vm_ops = &dummy_vm_ops;







621 **INIT_LIST_HEAD**(&vma-\>anon_vma_chain); 622 }



*Listing 4-13:* include/linux/mm.h: [*vma_init()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n614)



This zeroes the object, assigns the process’s [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) object to

which the VMA belongs, assigns some zeroed operations dummy_vm_ops and initialises the anon_vma_chain list.

The means by which the kernel decides where to place allocated VMAs

and what triggers this forms the subject of memory mapping, discussed in

## Chapter 5.

Often, the kernel will attempt to manipulate existing VMAs to accom-

modate memory mappings, this is a broad enough subject that it has its own

dedicated section to discuss it – section 5.1.

VMAs are freed via [vm_area_free()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n484) as shown in Listing 5-45.



484 **void vm_area_free**(**struct** vm_area_struct \*vma) 485 {

486 **free_anon_vma_name**(vma); 487 **kmem_cache_free**(vm_area_cachep, vma); 488 }



*Listing 4-14:* kernel/fork.c: [*vm_area_free()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n484)



This ultimately frees the VMA memory to the cache via the slab function

[kmem_cache_free()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/slub.c?h=v6.0#n3550), freeing any allocated anonymous memory mapping name

via [free_anon_vma_name()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n192).



***4.4.3 VMA layout***

VMAs are tied together in two different ways – connected to their owning

[struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) in a doubly-linked list (though not via [struct list_head](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/types.h?h=v6.0#n178)[),](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/types.h?h=v6.0#n178) headed by mm_struct’s mmap field, and joined by each VMA’s vm_prev and vm_next field. Importantly, this list is maintained in virtual address order.

This list permits linear traversal of VMAs and the ability to determine

each VMA’s predecessor and successor, however it is not efficient for look-ing up a specific address. Efficient means of doing so is achieved via a red/black binary search tree rooted in the mm_struct’s mm_rb field, with each VMA hosting a node in their vm_rb field.

The tree is keyed on the vm_end field of VMAs, which are guaranteed to

be non-overlapping (we check this when linking them). When searching, we traverse the tree looking for a node which possesses a vm_end value greater than our start address, then in each case test whether the vm_start is less than our start address.

Let’s consider an example VMA tree with VMAs between 0x0-0x500, 0x500

-0x1000, 0x2000-0x3000, 3250-3750, 0x4000-0x4500 and 0x6000-0x7000 in Figure

4-15.





[mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)

mmap

mm_rb



[vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403)



[vma vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403)



[vma vma vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403)



0 500 1000 1500 2000 2500 3000 3500 4000 4500 5000 5500 6000 6500 7000



Virtual address



*Figure 4-15: Example VMA layout*



Note that here each VMA is shown proportionate to the range they rep-

resent and are arranged such that virtual address increases from left to right.

The VMAs are linked in a binary tree, keyed on

[struct vm_area_struct-\>vm_end](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) while also being connected to one another in a

linked list via vm_prev and vm_next.



***4.4.4 VMA insertion/removal***

We examine the red/black binary tree node type in the kernel [struct rb_node](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rbtree_types.h?h=v6.0#n5)

in Listing 4-15.



5 **struct** rb_node {

6 **unsigned long** \_\_rb_parent_color;

7 **struct** rb_node \*rb_right;

8 **struct** rb_node \*rb_left;

9 } **\_\_attribute\_\_**((**aligned**(**sizeof**(**long**))));



*Listing 4-15:* include/linux/rbtree_types.h: [*struct rb_node*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rbtree_types.h?h=v6.0#n5)



The \_\_rb_parent_color field is used as part of the red/black tree algorithm

(out of scope for this book, but any good algorithm book will cover it), with

rb_left and rb_right pointing to the subtrees containing VMAs with vm_end

less than it to the left, and those with greater vm_end to the right. The root

object [struct rb_root](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rbtree_types.h?h=v6.0#n12) simply wraps a rb_node.

In order to insert new VMAs into a process address space, we need to ob-

tain a pointer to the parent node (this is in order to set the \_\_rb_parent_color

field) and a pointer to either the rb_left or rb_right field to know where to

put the new node.

In order to maintain the linked list we also need to know an adjacent

VMA object, which happens to be the previous one. From this we can find

the next VMA before we were inserted, update it and point ourselves to the

prior and next VMA.







All of these are provided by the [find_vma_links()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n488) function as shown in

Listing 4-16.



488 **static int find_vma_links**(**struct** mm_struct \*mm, **unsigned long** addr, 489 **unsigned long** end, **struct** vm_area_struct \*\*pprev, 490 **struct** rb_node \*\*\*rb_link, **struct** rb_node \*\*rb_parent) 491 {

492 **struct** rb_node \*\*\_\_rb_link, \*\_\_rb_parent, \*rb_prev; 493

494 **mmap_assert_locked**(mm); 495 \_\_rb_link = &mm-\>mm_rb.rb_node; 496 rb_prev = \_\_rb_parent = **NULL**; 497

498 **while** (\*\_\_rb_link) { 499 **struct** vm_area_struct \*vma_tmp; 500

501 \_\_rb_parent = \*\_\_rb_link; 502 vma_tmp = **rb_entry**(\_\_rb_parent, **struct** vm_area_struct, vm_rb); 503

504 **if** (vma_tmp-\>vm_end \> addr) { 505 */\* Fail if an existing vma overlaps the area \*/* 506 **if** (vma_tmp-\>vm_start \< end) 507 **return**-**ENOMEM**; 508 \_\_rb_link = &\_\_rb_parent-\>rb_left; 509 } **else** {

510 rb_prev = \_\_rb_parent; 511 \_\_rb_link = &\_\_rb_parent-\>rb_right; 512 }

513 }

514

515 \*pprev = **NULL**;

516 **if** (rb_prev)

517 \*pprev = **rb_entry**(rb_prev, **struct** vm_area_struct, vm_rb); 518 \*rb_link = \_\_rb_link; 519 \*rb_parent = \_\_rb_parent; 520 **return** 0;

521 }



*Listing 4-16:* mm/mmap.c: [*find_vma_links()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n488)



This function accepts the owning [mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486), the start address of the VMA

we want to link, addr, the exclusive end bound of the VMA we want to link, end, and we output:



• pprev – A pointer to the [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) immediately prior

to this one, or NULL if the inserted VMA would have the lowest virtual address in the process address space.

• rb_link – A pointer to either the rb_left or rb_right field in the parent

node in which a pointer to the newly inserted node must be placed.







• rb_parent – A pointer to the parent node, or NULL if this would be the first

VMA in this address space.



The function works by traversing though each node, determining

whether the containing VMA has a vm_end bound greater than the start ad-

dress of the VMA to be inserted, addr – if so this indicates that we should tra-

verse left. In this case, the VMA could overlap ours – we check this by seeing

if it starts after us, if not we raise an error.

Otherwise we traverse right and in either case we set \_\_rb_link to point

to the node to which we traverse. Since we predicate the loop on this being

non-NULL, the final result will be that this points to NULL and thus is where we

should insert our VMA.

An important nuance here is how we track the previous VMA – this is only

updated when we traverse right. This is correct, as until we traverse right, we

have no predecessor, and when we do so the parent must be the most im-

mediate predecessor as the parent’s vm_end must be less than ours and its left

subtree most be less than itself.

The users of [find_vma_links()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n488) are a little eclectic:



• [\_\_insert_vm_struct()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n670) – This is used as a helper by [\_\_vma_adjust()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n699) as part of

VMA splitting (covered in detail in section 5.1).

• [insert_vm_struct()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n3136) – This is a helper function used to wrap insertion of

VMAs, used by some initialisation functions and the out of scope ‘spe-

cial’ mapping handling function [\_\_install_special_mapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n3372)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n3372)

• [copy_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n3173) – This is used by the [mremap()](https://man7.org/linux/man-pages/man2/mremap.2.html) logic when VMAs need to be

copied around and thus inserted elsewhere.

• [munmap_vma_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n556) – Ironically, this is one of the most common means

by which [find_vma_links()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n488) is invoked for VMA traversal – it is used by

[mmap_region()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1681) and [do_brk_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2973) to unmap any existing mappings while also obtaining the fields required for inserting the new VMA at the same time.



Regardless of the method used to obtain the values returned by

find_vma_links(), a VMA is ultimately ‘linked’ into a process address space

via [\_\_vma_link()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n637) as shown in Listing 5-51.



636 **static void**

637 **\_\_vma_link**(**struct** mm_struct \*mm, **struct** vm_area_struct \*vma, 638 **struct** vm_area_struct \*prev, **struct** rb_node \*\*rb_link, 639 **struct** rb_node \*rb_parent) 640 {

641 **\_\_vma_link_list**(mm, vma, prev); 642 **\_\_vma_link_rb**(mm, vma, rb_link, rb_parent); 643 }



*Listing 4-17:* mm/mmap.c: [*\_\_vma_link()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n637)







This links the VMA being inserted into the VMA linked list and

red/black tree. Note the parameters matching those provided by find_vma_links() – prev, rb_link and rb_parent.

We first insert into the linked list via [\_\_vma_link_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n275)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n275) examining this as

shown in Listing 4-18.



275 **void \_\_vma_link_list**(**struct** mm_struct \*mm, **struct** vm_area_struct \*vma, 276 **struct** vm_area_struct \*prev) 277 {

278 **struct** vm_area_struct \*next; 279

280 vma-\>vm_prev = prev; 281 **if** (prev) {

282 next = prev-\>vm_next; 283 prev-\>vm_next = vma; 284 } **else** {

285 next = mm-\>mmap; 286 mm-\>mmap = vma; 287 }

288 vma-\>vm_next = next; 289 **if** (next)

290 next-\>vm_prev = vma; 291 }



*Listing 4-18:* mm/util.c: [*\_\_vma_link_list()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n275)



This handles the case where this VMA possesses the earliest address in

the process address space (indicated by prev being NULL), correctly updating

the [mm_struct-\>mmap](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) field accordingly.

Both the inserted VMA, its predecessor (or the mm_struct object if first)

and successor (if it exists) are updated.

The node is inserted into the red/black tree via [\_\_vma_link_rb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n595) as shown

in Listing 4-19.



595 **void \_\_vma_link_rb**(**struct** mm_struct \*mm, **struct** vm_area_struct \*vma, 596 **struct** rb_node \*\*rb_link, **struct** rb_node \*rb_parent) 597 {

598 */\* Update tracking information for the gap following the new vma. \*/*

599 **if** (vma-\>vm_next) 600 **vma_gap_update**(vma-\>vm_next); 601 **else**

602 mm-\>highest_vm_end = **vm_end_gap**(vma); 603

604 */\**

605 *\* vma-\>vm_prev wasn't known when we followed the rbtree to find the*

606 *\* correct insertion point for that vma. As a result, we could not*

607 *\* update the vma vm_rb parents rb_subtree_gap values on the way down.*

608 *\* So, we first insert the vma with a zero rb_subtree_gap value* 609 *\* (to be consistent with what we did on the way down), and then*







610 *\* immediately update the gap to the correct value. Finally we* 611 *\* rebalance the rbtree after all augmented values have been set.* 612 *\*/*

613 **rb_link_node**(&vma-\>vm_rb, rb_parent, rb_link); 614 vma-\>rb_subtree_gap = 0; 615 **vma_gap_update**(vma); 616 **vma_rb_insert**(vma, &mm-\>mm_rb); 617 }



*Listing 4-19:* mm/mmap.c: [*\_\_vma_link_rb()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n595)



This performs an update of the VMA’s subtree gap and propa-

gates changes to other nodes(stored in their rb_subtree_gap field) via

[vma_gap_update(). ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n404)This field is used to determine the largest gap between

VMA regions less at or below this one and used by the memory mapping

logic when determining where to place a new VMA. We discuss how this ini-

tial mapping is done in detail in Chapter 5.

We actually insert the node in the tree via [rb_link_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rbtree.h?h=v6.0#n59) which is the

function for doing this in the kernel’s generic red/black tree implementa-

tion.

Finally we invoke [vma_rb_insert()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n413) which kicks off [rb_insert_augmented()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rbtree_augmented.h?h=v6.0#n47) to

balance the tree and also passes it the [vma_gap_callbacks](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n395) callbacks object to

maintain the subtree gap calculations as it does so.

Coming back to [\_\_vma_link()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n637) – this function will either be invoked by

[\_\_insert_vm_struct()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n670) or [vma_link()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n645)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n645) Let’s examine the former, which is some-

what simplistic as shown in Listing 5-50.



666 */\**

667 *\* Helper for vma_adjust() in the split_vma insert case: insert a vma into the*

668 *\* mm's list and rbtree. It has already been inserted into the interval tree.*

669 *\*/*

670 **static void \_\_insert_vm_struct**(**struct** mm_struct \*mm, **struct** vm_area_struct \*

vma)

671 {

672 **struct** vm_area_struct \*prev; 673 **struct** rb_node \*\*rb_link, \*rb_parent;

674

675 **if** (**find_vma_links**(mm, vma-\>vm_start, vma-\>vm_end, 676 &prev, &rb_link, &rb_parent)) 677 **BUG**();

678 **\_\_vma_link**(mm, vma, prev, rb_link, rb_parent); 679 mm-\>map_count++;

680 }



*Listing 4-20:* mm/mmap.c: [*\_\_insert_vm_struct()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n670)



This simply invokes [find_vma_links()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n488), then links what it finds via

[\_\_vma_link()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n637) before incrementing the [mm_struct-\>map_count](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) field to indicate

that a new mapping exists there.

Now examining [vma_link()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n645) as shown in Listing 4-21.







645 **static void vma_link**(**struct** mm_struct \*mm, **struct** vm_area_struct \*vma, 646 **struct** vm_area_struct \*prev, **struct** rb_node \*\*rb_link, 647 **struct** rb_node \*rb_parent) 648 {

649 **struct** address_space \*mapping = **NULL**; 650

651 **if** (vma-\>vm_file) { 652 mapping = vma-\>vm_file-\>f_mapping; 653 **i_mmap_lock_write**(mapping); 654 }

655

656 **\_\_vma_link**(mm, vma, prev, rb_link, rb_parent); 657 **\_\_vma_link_file**(vma); 658

659 **if** (mapping)

660 **i_mmap_unlock_write**(mapping); 661

662 mm-\>map_count++;

663 **validate_mm**(mm);

664 }



*Listing 4-21:* mm/mmap.c: [*vma_link()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n645)



This similarly invokes \_\_vma_link() but additionally includes logic for han-

dling file-backed VMAs, invoking [\_\_vma_link_file()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n619) and acquiring the ap-

propriate lock over the [struct address_space-\>i_mmap](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) interval tree containing VMAs linked to it. See the chapter on the page cache for more on this.

Finally, [validate_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n351) is called, which only does something if

CONFIG_DEBUG_VM_RB is set, validating the subtree gaps set by the VMA logic.

Removal of VMAs is a little more involved, see Chapter 5 for an in-depth

treatment of unmapping memory, however we will examine the function

that is ultimately invoked, [\_\_vma_unlink()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n682) as shown in Listing 5-41.



682 **static \_\_always_inline void \_\_vma_unlink**(**struct** mm_struct \*mm, 683 **struct** vm_area_struct \*vma, 684 **struct** vm_area_struct \*ignore) 685 {

686 **vma_rb_erase_ignore**(vma, &mm-\>mm_rb, ignore); 687 **\_\_vma_unlink_list**(mm, vma); 688 */\* Kill the cache \*/* 689 **vmacache_invalidate**(mm); 690 }



*Listing 4-22:* mm/mmap.c: [*\_\_vma_unlink()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n682)



This starts by erasing the red/black tree node from the VMA tree via

[vma_rb_erase_ignore()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n432) – in turn this invokes [\_\_vma_rb_erase()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n422) which invokes the

generic red/black tree erase function [rb_erase_augmented()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rbtree_augmented.h?h=v6.0#n300)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rbtree_augmented.h?h=v6.0#n300)







Next, it releases the VMA from the linked list via [\_\_vma_unlink_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n293) as

shown in Listing 5-42.



293 **void \_\_vma_unlink_list**(**struct** mm_struct \*mm, **struct** vm_area_struct \*vma) 294 {

295 **struct** vm_area_struct \*prev, \*next;

296

297 next = vma-\>vm_next; 298 prev = vma-\>vm_prev; 299 **if** (prev)

300 prev-\>vm_next = next; 301 **else**

302 mm-\>mmap = next; 303 **if** (next)

304 next-\>vm_prev = prev; 305 }



*Listing 4-23:* mm/util.c: [*\_\_vma_unlink_list()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n293)



This performs the inverse of what [\_\_vma_link_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n275) does, taking a copy of

what comes before and after the VMA before linking them together exclud-

ing the VMA being unlinked, while also taking into account that this might

be the first VMA in the process address space and handling the update of

[mm_struct-\>mmap](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) appropriately.

Finally, the VMA cache is invalidated via [vmacache_invalidate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmacache.h?h=v6.0#n23) which sim-

ply increments the [mm_struct-\>vmacache_seqnum](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) sequence number to do so. See

below for a discussion of the VMA cache as a whole.



***4.4.5 VMA traversal***

Traversing the linked list is straightforward – the [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) fields

vm_prev and vm_next provide easy means of walking these, and each [mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)

specifies the VMA with the earliest virtual address in its mmap field.

Finding VMAs by address however is more involved – we have, after all,

established an entire red/black tree structure in order to do so efficiently.

The principle means of doing so is via [find_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2253) as shown in Listing 4-24.



2252 */\* Look up the first VMA which satisfies addr \< vm_end,* *NULL if none. \*/*

2253 **struct** vm_area_struct \***find_vma**(**struct** mm_struct \*mm, **unsigned long** addr) 2254 {

2255 **struct** rb_node \*rb_node; 2256 **struct** vm_area_struct \*vma; 2257

2258 **mmap_assert_locked**(mm); 2259 */\* Check the cache first. \*/* 2260 vma = **vmacache_find**(mm, addr); 2261 **if** (**likely**(vma))

2262 **return** vma; 2263







2264 rb_node = mm-\>mm_rb.rb_node; 2265

2266 **while** (rb_node) { 2267 **struct** vm_area_struct \*tmp; 2268

2269 tmp = **rb_entry**(rb_node, **struct** vm_area_struct, vm_rb); 2270

2271 **if** (tmp-\>vm_end \> addr) { 2272 vma = tmp; 2273 **if** (tmp-\>vm_start \<= addr) 2274 **break**; 2275 rb_node = rb_node-\>rb_left; 2276 } **else**

2277 rb_node = rb_node-\>rb_right; 2278 }

2279

2280 **if** (vma)

2281 **vmacache_update**(addr, vma); 2282 **return** vma;

2283 }



*Listing 4-24:* mm/mmap.c: [*find_vma()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2253)



As discussed above, VMAs are maintained in a tree keyed on their exclu-

sive upper bound, vm_end, and this function simply returns the VMA with the earliest address (i.e. first) which satisfies the condition that the input address is less than vm_end, or if it cannot find such a VMA, it returns NULL.

This necessitates an additional check being required if you are searching

for an address range, i.e. checking that the start of your range is greater than the returned VMA’s vm_start.

Returning a VMA this way allows for maximum flexibility – we can find

the closest VMA greater than the specified address and via its vm_prev field determine the closest VMA less than it if we need to do so.

This function requires that a read lock is held on the [mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)

semaphore.

The first stage is to checking the VMA cache to see whether it contains

the VMA object for the [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) at the specified address

via [vmacache_find()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmacache.c?h=v6.0#n61). If so, then we simply return this VMA. We will return to VMA caches shortly.

If no VMA cache entry exists, we walk the red/black tree. This simply

traverses the tree from [mm_struct-\>mm_rb](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486), examining each node – if the node under examination ends after our target address, we examine lower ad-dressed VMAs, otherwise we examine higher addressed ones.

When examining nodes which have an vm_end greater than our address,

these could actually contain the target address, so we do the additional check to see whether vm_start is less than or equal to it – if so we can exit early.

When we are done, we update the VMA cache via [vmacache_update()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmacache.c?h=v6.0#n35)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmacache.c?h=v6.0#n35)







**4.4.5.1 VMA cache**

The VMA cache is simply a hash between addresses and VMAs stored in

each thread’s [struct task_struct-\>vmacache](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) field.

It is kept in sync with updated VMA mappings using a ‘se-

quence number’ – This is a simple integer which is maintained in

[mm_struct-\>vmacache_seqnum](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486), which is incremented every time VMA mappings

are updated. If a VMA cache’s sequence number does match this, then it is

invalidated and not used.

The key data structure used in the VMA cache is [struct vmacache](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types_task.h?h=v6.0#n34) as shown

in Listing 4-25.



34 **struct** vmacache {

35 **u64** seqnum;

36 **struct** vm_area_struct \*vmas\[**VMACACHE_SIZE**\];

37 };



*Listing 4-25:* include/linux/mm_types_task.h: [*struct vmacache*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types_task.h?h=v6.0#n34)



This maintains a very simple hash of VMA objects and the aforemen-

tioned sequence number. The number of entries in this hash is defined by

[VMACACHE_SIZE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types_task.h?h=v6.0#n31) which is in turn determined by [VMACACHE_BITS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types_task.h?h=v6.0#n31) and hardcoded to

2 bits, i.e. 4 entries. [VMACACHE_MASK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types_task.h?h=v6.0#n32) specifies the valid hash table array entries

as a bitmask.

The hash used in the lookup is determined by [VMACACHE_HASH()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmacache.c?h=v6.0#n19) as shown in

Listing 4-26.



19 **\#define VMACACHE_HASH**(addr) ((addr \>\> **VMACACHE_SHIFT**) & **VMACACHE_MASK**)



*Listing 4-26:* mm/vmacache.c: [*VMACACHE_HASH()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmacache.c?h=v6.0#n19)



This simply shifts by the [VMACACHE_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmacache.c?h=v6.0#n15) value which is set to [PMD_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n90)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n90)

which on x86-64 is 21. This means that address in 2 megabyte aligned blocks

will all resolve to the same array entry. This has been heuristically deter-

mined to still be a useful granularity.

The lookup of VMA cache entries is performed via [vmacache_find()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmacache.c?h=v6.0#n61) as

shown in Listing 4-27.



61 **struct** vm_area_struct \***vmacache_find**(**struct** mm_struct \*mm, **unsigned long** addr)

62 {

63 **int** idx = **VMACACHE_HASH**(addr);

64 **int** i;

65

66 **count_vm_vmacache_event**(**VMACACHE_FIND_CALLS**);

67

68 **if** (!**vmacache_valid**(mm))

69 **return NULL**;

70

71 **for** (i = 0; i \< **VMACACHE_SIZE**; i++) {

72 **struct** vm_area_struct \*vma = current-\>vmacache.vmas\[idx\];

73







74 **if** (vma) { 75 **\#ifdef CONFIG_DEBUG_VM_VMACACHE** 76 **if** (**WARN_ON_ONCE**(vma-\>vm_mm != mm)) 77 **break**; 78 **\#endif**

79 **if** (vma-\>vm_start \<= addr && vma-\>vm_end \> addr) { 80 **count_vm_vmacache_event**(**VMACACHE_FIND_HITS**); 81 **return** vma; 82 } 83 }

84 **if** (++idx == **VMACACHE_SIZE**) 85 idx = 0; 86 }

87

88 **return NULL**;

89 }



*Listing 4-27:* mm/vmacache.c: [*vmacache_find()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmacache.c?h=v6.0#n61)



We first determine whether the cache is valid via [vmacache_valid()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmacache.c?h=v6.0#n41)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmacache.c?h=v6.0#n41) after

which we iterate through all entries, using the hash value as a starting point only. If we find a VMA that contains the address (we could not reasonably cache VMAs that come after the target address) we return it otherwise we return NULL.

We examine vmacache_valid() in Listing 4-28.



41 **static bool vmacache_valid**(**struct** mm_struct \*mm) 42 {

43 **struct** task_struct \*curr; 44

45 **if** (!**vmacache_valid_mm**(mm)) 46 **return false**; 47

48 curr = current;

49 **if** (mm-\>vmacache_seqnum != curr-\>vmacache.seqnum) { 50 */\**

51 *\* First attempt will always be invalid, initialize* 52 *\* the new cache for this task here.* 53 *\*/*

54 curr-\>vmacache.seqnum = mm-\>vmacache_seqnum; 55 **vmacache_flush**(curr); 56 **return false**; 57 }

58 **return true**;

59 }



*Listing 4-28:* mm/vmacache.c: [*vmacache_valid()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmacache.c?h=v6.0#n41)



This first checks if the VMA belongs to the current task’s [mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) and

that it is not a kernel thread via [vmacache_valid_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmacache.c?h=v6.0#n30), before checking to en-







sure that the sequence numbers of this cache and the mm_struct are equal to

one another. If not, the sequence number is reset, and the cache is flushed

via [vmacache_flush()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmacache.h?h=v6.0#n8) which simply zeroes the vmas array altogether.

Finally, updates made to the VMA cache are performed via

[vmacache_update()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmacache.c?h=v6.0#n35) as shown in Listing 4-29.



35 **void vmacache_update**(**unsigned long** addr, **struct** vm_area_struct \*newvma)

36 {

37 **if** (**vmacache_valid_mm**(newvma-\>vm_mm))

38 current-\>vmacache.vmas\[**VMACACHE_HASH**(addr)\] = newvma;

39 }



*Listing 4-29:* mm/vmacache.c: [*vmacache_update()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmacache.c?h=v6.0#n35)



**4.5 An introduction to the page cache**



Within the kernel, all files, block I/O buffers and other related ‘cacheable’

objects are kept within a key cache in memory – the page cache. We will

briefly examine the fundamentals of this topic and how they relate to pro-

cess memory here, but for more detail on this topic, refer to the dedicated

page cache chapter.

Typically all file are mediated by this cache (the exceptions being cases

where either direct I/O or direct access (DAX) are used, both topics outside

the scope of the book), with both memory-mapped and stream-read opera-

tions reading from this cache (see [filemap_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2626) for the latter).

Each of the objects present in the page cache is described by a

[struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) object, pointed to by the underlying folios in the mapping

field as shown in Listing 4-30.



402 */\*\**

403 *\* struct address_space - Contents of a cacheable, mappable object.* 404 *\* @host: Owner, either the inode or the block_device.* 405 *\* @i_pages: Cached pages.* 406 *\* @invalidate_lock: Guards coherency between page cache contents and* 407 *\** *file offset-\>disk block mappings in the filesystem during invalidates.* 408 *\** *It is also used to block modification of page cache contents through* 409 *\** *memory mappings.*

410 *\* @gfp_mask: Memory allocation flags to use for allocating pages.* 411 *\* @i_mmap_writable: Number of VM_SHARED mappings.* 412 *\* @nr_thps: Number of THPs in the pagecache (non-shmem only).* 413 *\* @i_mmap: Tree of private and shared mappings.* 414 *\* @i_mmap_rwsem: Protects @i_mmap and @i_mmap_writable.* 415 *\* @nrpages: Number of page entries, protected by the i_pages lock.* 416 *\* @writeback_index: Writeback starts here.* 417 *\* @a_ops: Methods.*

418 *\* @flags: Error bits and flags (AS\_\*).* 419 *\* @wb_err: The most recent error which has occurred.* 420 *\* @private_lock: For use by the owner of the address_space.*







421 *\* @private_list: For use by the owner of the address_space.* 422 *\* @private_data: For use by the owner of the address_space.* 423 *\*/*

424 **struct** address_space {

425 **struct** inode \*host; 426 **struct** xarray i_pages; 427 **struct** rw_semaphore invalidate_lock; 428 **gfp_t** gfp_mask; 429 **atomic_t** i_mmap_writable;

. . .

434 **struct** rb_root_cached i_mmap; 435 **struct** rw_semaphore i_mmap_rwsem; 436 **unsigned long** nrpages; 437 **pgoff_t** writeback_index; 438 **const struct** address_space_operations \*a_ops; 439 **unsigned long** flags; 440 **errseq_t** wb_err; 441 **spinlock_t** private_lock; 442 **struct** list_head private_list; 443 **void** \*private_data; 444 } **\_\_attribute\_\_**((**aligned**(**sizeof**(**long**)))) **\_\_randomize_layout**;



*Listing 4-30:* include/linux/fs.h: [*struct address_space*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)



Examining each field:



• host – If this object refers to a file, this field references the file’s

[struct inode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593) object\*. This field can be NULL for non-file objects present within the page cache.

• [†](https://kernel.org/doc/html/v6.0/core-api/xarray.html) i_pages – An [eXtensible array](https://kernel.org/doc/html/v6.0/core-api/xarray.html) of pointers to [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) objects

for page cache-mapped folios. This is inextricably linked to the

[struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256)-\>index field which specifies the page offset of the folio within the page cache mapping (which it references via its mapping field).

• invalidate_lock – A [read/write semaphore](https://kernel.org/doc/html/v6.0/locking/locktypes.html#rw-semaphore) used to synchronise mod-

ifications to the mapping such as reading into the page cache (e.g.

via the function [read_cache_page_gfp()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3590)[),](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3590) adding folios to it (e.g. via the

[filemap_create_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2489) function), or on truncation (acquired by a filesys-

tem using [filemap_invalidate_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n799)[).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n799)

• gfp_mask – The GFP mask (see section 2.6 in the physical memory chap-

ter for more details on these ) applied to folio allocations within this



\*. An inode is a data structure which contains a file system object’s metadata such as file size, access times, and other related information. It is independent of a file’s name or location within the filesystem.

†. The [eXtensible array](https://kernel.org/doc/html/v6.0/core-api/xarray.html) is an efficient data structure for storing a large set of possibly-sparse pointers with the ability to efficiently traverse to next and previous elements. The kernel docu-mentation on this is extensive.







page cache entry. Typically accessed via [mapping_gfp_mask()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n272)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n272) Notably ref-

erenced by [filemap_create_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2489) to allocate page cache folios.

• i_mmap_writable – An atomic count used to determine whether the

object is referenced by at least one writable memory mapping (i.e. a shared mapping). If only copy-on-write mappings have been per-formed (or it is not memory-mapped) this will be set to 0, for the more usual case of an MAP_SHARED file mapping (e.g. under a VMA with

the [VM_SHARED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n269) flag set) this is positive, set by [mapping_map_writable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n526) in

[mmap_region(). ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1681)When a shared mapping is removed this is decremented

by [mapping_unmap_writable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n532). This is implemented as a counter as it can be referenced by multiple VMAs and thus some mappings may be private and others not, with the overall purpose of this being the need to determine whether the underlying folios can be arbitrarily written to by userland (checked by

[mapping_writably_mapped()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n521) which simply determines if this value is greater than zero).

This value can be negative as it is possible to deny writable access via

[mapping_deny_writable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n537) (which fails if the value is not already less than or

equal to zero). This is used by the [memfd](https://man7.org/linux/man-pages/man2/memfd.2.html) functionality when sealing/un-

sealing via the [fcntl()](https://man7.org/linux/man-pages/man2/fcntl.2.html) specifying the F_SEAL_WRITE option. This denial is

reversed via [mapping_allow_writable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n543).

• i_mmap – The root of a red/black interval tree of mappings to this

cacheable object. This tree consists of [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) nodes (i.e. VMAs). It is used most notably by VMA interval tree operations via

[\_\_vma_link_file()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n619). Anonymous mappings equivalently hang their VMAs

from a [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) object. See section 5.1 for more on this.

• i_mmap_rwsem – A [read/write semaphore](https://kernel.org/doc/html/v6.0/locking/locktypes.html#rw-semaphore) used to protect the i_mmap

field. Manipulated by the helper functions [i_mmap_lock_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n464)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n464)

[i_mmap_trylock_write(),](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n469) [i_mmap_unlock_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n474)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n474) [i_mmap_trylock_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n479)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n479)

[i_mmap_lock_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n484) and [i_mmap_unlock_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n489)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n489) A read lock must be held when traversing this interval tree, and a write lock must be held when manipulating it. This is typically invoked by a memory operation which

performs an operation across VMAs, such as [unmap_mapping_range_tree()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3489).

• nrpages – The number of pages of this page cache entry currently

present in the page cache. Importantly, this is not equal to the size

of the file (contained in [struct inode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593)-\>i_size). For instance, a newly opened file which does not have pages in the page cache yet will have zero nrpages, and each time pages are read into the page cache, this is incremented. This therefore gives a count of the pages contained in i_pages . This is protected by i_pages’s xarray locks and manipulated in

functions such as [\_\_filemap_add_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n838) and [page_cache_delete()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n124)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n124)

• writeback_index – Specifies the page offset at which writeback (i.e. the

writing back of modified data in the page cache to its backing store such as a disk) should commence. Used by filesystem implementations and

also in [write_cache_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2281) to trace a writeback operation through to completion. See the page cache chapter for more on writeback.







• a_ops – A [struct address_space_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n356) object which specifies functions

to call for operations on this page cache object and specified by the un-derlying filesystem. Generic functions are often used where the filesys-tem does not need specific behaviour. See the page cache chapter for more on this.

• flags – A bitmap of flags which describes the page cache object using

bits described by [enum mapping_flags](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n193). See the page cache chapter for more details on this.

• wb_err – The last writeback error that occurred for the object. See the

page cache chapter for more on this.

• private_lock – A spinlock reserved for use by the filesystem within which

this object resides.

• private_list – A list head field reserved for use by the filesystem within

which this object resides.

• private_data – A void pointer field reserved for use by the filesystem

within which this object resides.



This object acts as an intermediary between underlying page cache folios

and VMAs as both of these are ephemeral. It may be referenced by VMAs from different processes as equally a file can be mapped from different fo-lios.

The underlying page cache folios which store the data reference the page

cache object via their mapping field. Shared mappings (i.e. MAP_SHARED) directly map the virtual address to the underlying page cache folios.

Private mappings of file-backed memory (which are strange beasts, see

## Chapter 5 for more details) either reference a read-only Copy-on-Write map-ping to the page cache folio or an entirely separate anonymous folio, but whose VMA is retained on the i_mmap tree.

If a VMA is backed by a file then a reference to that file is contained in

its [struct vm_area_struct-\>vm_file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) field. This is what is used by the page fault

machinery to obtain the underlying [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) object, and is set in

[mmap_region()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1681) when the memory is mapped.

The object referenced by a VMA’s vm_file field is a [struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) object

which contains file metadata for a file opened by a process, the most perti-nent of which is the f_mapping field which references the address_space object.

A file in the linux virtual file system has an inode associated with it, which

describes a file’s metadata (but notably not its path). The kernel repre-

sentation of this is the [struct inode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593) object, but an open file is described by struct file which does refer to a specific path.

Since a file-backed VMA will have explicitly been established via a file

descriptor (and thus a file at a specific path) it makes sense to use the file object here. The f_mapping field duplicates the f_inode’s i_mapping field, but since the file’s reference to the inode is cached, it is useful to also cache the mapping. Typically this mapping is simply equal to &f_inode-\>i_data but this can’t always be assumed to be the case.







The more interesting operations involving the page cache

occur on page fault (see section 6) which invoke the VMA’s

[struct vm_area_struct-\>vm_ops-\>fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) handler, either customised by the file

system or, more typically, having been set to the [filemap_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3084) function.

This performs the actual ‘faulting in’ of files, utilising the a_ops set of

functions (a [struct address_space_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n356) object) to perform the under-

lying work required to actually read from and write back to the underlying

file.

An interesting aspect of the page cache is that, when reading data from

disk, it is likely that the user will want to access more than the first page of

data, nor will the underlying block device necessarily be optimised for re-

trieving data at this granularity. Therefore, it makes sense to readahead, i.e.

read more data in the page cache than is requested.

It is also useful to keep page cache entries around even after they are fin-

ished with, as reading file data from the page cache is significantly faster than

reading it from a hard disk and markedly faster than reading from a faster

store such as an SSD or NVMe device.

Therefore the kernel very much favours caching as much file data as pos-

sible and storing it in the page cache, while making it easy for the memory

to equally be freed under memory pressure via reclaim if the memory is re-

quired for something else.

The freeing of the memory is controlled by reclaim (see the reclaim

## chapter for more on this), and precisely how we prioritise what gets freed

first is determined by the position of folios on the appropriate LRU list (see

section 11.2 for more on this).

The address space object is allocated by a file system’s super block (meta-

data describing a filesystem as a whole), described by [struct super_block](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n1451) and

implemented via the [struct super_operations-\>alloc_inode()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2222).

The address space, including its a_ops is set by the file system itself,

for example ext4 initialises inodes in [\_\_ext4_iget()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/ext4/inode.c?h=v6.0#n4735), setting a_ops via

[ext4_set_aops()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/ext4/inode.c?h=v6.0#n3700).

This has been a whistle-stop tour as the page cache is large enough of

a topic to deserve its own chapter, so refer to that for a significantly more

detailed analysis.



**4.6 Per-process memory management statistical counters**



Memory management statistics are vitally important for users as they are the

primary means to determine the status of memory within the system. These

counters track a number of different things, each of which are accessible via

interfaces like procfs (see section 14.5 for more details).

The key per-process memory management counters are:



• [MM_FILEPAGES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types_task.h?h=v6.0#n44) – Counts resident pages containing data backed by files, ex-

cluding those backed by shmem memory (see below).

• [MM_ANONPAGES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types_task.h?h=v6.0#n45) – Counts resident anonymous memory.







• [MM_SWAPENTS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types_task.h?h=v6.0#n46) – Counts the number of anonymous swap entries, i.e. the

number of pages which are currently swapped out.

• [MM_SHMEMPAGES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types_task.h?h=v6.0#n47) – Counts resident pages containing data backed by shmem

files, e.g. tmpfs and shared ‘anonymous’ mappings.



There are [NR_MM_COUNTERS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types_task.h?h=v6.0#n48) of these values maintained in an anonymous

enum .

The values themselves are stored in two places – per-thread

[struct task_rss_stat](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types_task.h?h=v6.0#n54) state stored in [struct task_struct-\>rss_stat](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) and

per-process address space specific [struct mm_rss_stat](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types_task.h?h=v6.0#n60) state stored in

[mm_struct-\>rss_stat](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486).

Why are there two different locations? This is to account for the fact that

these counters belong to the virtual address space, but may be updated by multiple threads, each of which may do so concurrently.



**N O T E** In linux, each individual thread is treated as if it were a different process, each with

independent [*struct task_struct*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) objects all sharing the same [*mm_struct*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)



In order to avoid heavy lock contention, the per-thread values

are updated and only ‘flushed’ to the per-address space values every

[TASK_RSS_EVENTS_THRESH](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n207) events.

We examine the [struct task_rss_stat](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types_task.h?h=v6.0#n54) type in Listing 4-31.



53 */\* per-thread cached information, \*/* 54 **struct** task_rss_stat {

55 **int** events; */\* for synchronization threshold \*/* 56 **int** count\[**NR_MM_COUNTERS**\]; 57 };



*Listing 4-31:* include/linux/mm_types_task.h: [*struct task_rss_stat*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types_task.h?h=v6.0#n54)

The counters are simply stored in the count array, with events tracking the

number of events which have occurred in order to rate limit into batches of

[TASK_RSS_EVENTS_THRESH](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n207) as shown in Listing 4-32.



60 **struct** mm_rss_stat {

61 **atomic_long_t** count\[**NR_MM_COUNTERS**\]; 62 };



*Listing 4-32:* include/linux/mm_types_task.h: [*struct mm_rss_stat*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types_task.h?h=v6.0#n60)

Here an atomic counter is maintained, as individual threads will update

count, so the atomic value synchronises between these.

The counters are incremented and decremented by [inc_mm_counter_fast()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n203)

and [dec_mm_counter_fast()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n204) respectively, both of which delegate the actual op-

erate to [add_mm_counter_fast()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n194) as shown in Listing 4-33.



194 **static void add_mm_counter_fast**(**struct** mm_struct \*mm, **int** member, **int** val) 195 {

196 **struct** task_struct \*task = current; 197







198 **if** (**likely**(task-\>mm == mm)) 199 task-\>rss_stat.count\[member\] += val; 200 **else**

201 **add_mm_counter**(mm, member, val); 202 }



*Listing 4-33:* mm/memory.c: [*add_mm_counter_fast()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n194)



Note that, should the memory access be to a [mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) object which

does not belong to the current process, then this function falls back to

[add_mm_counter(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1973)which simply increments the [mm_struct-\>rss_stat](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) value.

The function which checks whether the per-thread values are ready to

be flushed to the per-address space values is [check_sync_rss_stat()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n208)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n208) which is

invoked in [handle_mm_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5129)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5129) i.e. at the start of the page fault process.



**N O T E** This only occurs if the *SPLIT_RSS_COUNTING* directive is specified, which it is only if

*USE_SPLIT_PTE_PTLOCKS* is also specified. This is the case for x86-64.

Not all means by which statistics might get updated result in a synchronisation of

RSS statistics, for instance the zero-copy TCP receive implementation in the kernel

uses [*vm_insert_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1976) to place data into memory, which does not update RSS statis-

tics at all.



Examining [check_sync_rss_stat()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n208) as shown in Listing 4-34.



208 **static void check_sync_rss_stat**(**struct** task_struct \*task) 209 {

210 **if** (**unlikely**(task != current)) 211 **return**;

212 **if** (**unlikely**(task-\>rss_stat.events++ \> **TASK_RSS_EVENTS_THRESH**)) 213 **sync_mm_rss**(task-\>mm); 214 }



*Listing 4-34:* mm/memory.c: [*check_sync_rss_stat()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n208)



This simply increments the current task’s [struct task_rss_stat.event](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types_task.h?h=v6.0#n54)

value, if it exceeds the threshold value [TASK_RSS_EVENTS_THRESH](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n207) then it invokes

[sync_mm_rss()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n181) as shown in Listing 4-35.



181 **void sync_mm_rss**(**struct** mm_struct \*mm) 182 {

183 **int** i;

184

185 **for** (i = 0; i \< **NR_MM_COUNTERS**; i++) { 186 **if** (current-\>rss_stat.count\[i\]) { 187 **add_mm_counter**(mm, i, current-\>rss_stat.count\[i\]); 188 current-\>rss_stat.count\[i\] = 0; 189 }

190 }

191 current-\>rss_stat.events = 0; 192 }







*Listing 4-35:* mm/memory.c: [*sync_mm_rss()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n181)



This simply iterates through the MM counters and sets the values in the

[mm_struct-\>rss_stat](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) via [add_mm_counter()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1973).

These counters are used to output memory usage statistics to users

via interfaces such as /proc/\$pid/status. It’s important to note that due to the throttling described here, these values will be inaccurate by up to

[TASK_RSS_EVENTS_THRESH](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n207) pages, e.g. on x86-64 up to 256 KiB, per thread.

Therefore, for processes with a great many threads, these values can be

rather unreliable, and an alternative such as /proc/\$pid/smaps_rollup should

be used if absolute accuracy is required. See section 14.5 for a detailed de-scription of the procfs interfaces which read these values.



**N O T E** The inaccuracy of these values has been improved since kernel 6.2, in

[*mm: convert mm's rss stats into percpu_counter*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=f1a7941243c1) (commit *f1a7941243c1*).



