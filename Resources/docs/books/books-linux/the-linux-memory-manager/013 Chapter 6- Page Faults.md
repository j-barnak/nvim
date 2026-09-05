
 

**6**

 

**P A G E F A U L T S**

 

In linux, the actual physical allocation of userland

memory occurs not on mapping but when a page fault

occurs on access to that memory. A page fault arises

when a user attempts to access virtual memory that ei-

ther does not have a valid page table mapping or for

which the page table mapping does not allow the at-

tempted action (e.g. writing to a read-only mapping).

In this chapter we examine this mechanism in detail.

The page faults themselves arise due to the computer’s Memory Man-

agement Unit (MMU) detecting an invalid access. The kernel can tell the

hardware to invoke its handler when this occurs and modern hardware per-

mits the mapping to be corrected, i.e. ‘fixing up’ the page fault, if the kernel

deems the access to have been valid.

When page faults occur at an address contained within a valid mapping,

the kernel is then able to ‘back’ this memory by performing the physical al-

location of that memory and updating the page table mapping to correctly

reference it. Doing so is termed demand paging because the actual allocation

of memory occurs on demand rather than on mapping.

When this occurs, the pages are said to be ‘faulted in’ (which we can fur-

ther subdivide into ‘read faulting’ and ‘write faulting’). Note that a page


 

fault can be pre-triggered when using [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) via the MAP_POPULATE flag. This is, from the kernel’s point of view, equivalent to write faulting them in.

The page fault mechanism permits a disconnect between mapping user-

land memory and both allocating physical memory and establishing page table mappings to it – all that is required for userland memory to be valid is for the range to be contained within a VMA with the appropriate flags.

Broadly speaking there are two types of page faults – those arising for

anonymous mappings and those arising for file-backed ones. They each have different semantics, with the former allocating physical memory to back them and the latter checking the page cache to see if the file is already avail-able and mapping to that if so and if not invoke filesystem functionality to place the data into the page cache before mapping it.

Complexity arises around swap, page migration and NUMA balancing,

each of which result specific actions being taken on page faults, however dis-cussion of these are deferred to their respective chapters.

When it comes to architecture-specific functionality we must speak about

a specific architecture as otherwise discussing the topic would quickly be-come impractical.

 

**6.1 Hardware page fault handling**

 

Implementations differ in how they handle hardware page fault handling, but after doing so they each share common fault handling code.

We examine how x86-64 invokes the general fault handling logic from an

x86-64 hardware fault in Figure 6-1.

 



 

[handle_page_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1476)

 

Yes No

[do_kern_addr_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1147) Kernel address? [do_user_addr_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1220)

 

Spurious? Kernel exec fault?

Otherwise Yes

If No [spurious_kernel_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1007)

Yes

**Ignore** **Bad area handling** Reserved bit fault?

 

Yes No Yes No

Yes

[access_error()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1076)? [expand_stack()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2553)? Faults off/no mm?

Yes

No Lock [mm-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) No

 

No Found? [find_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2253)

 

Lock [mm-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)

From figure 6-2 (retry)

[handle_mm_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5129)

 

To figure 6-3

 

*Figure 6-1: Overview of x86-64 hardware page faulting*

 

The x86-64 architecture defines a handler for the hardware page fault at

[exc_page_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1500) which in turn invokes [handle_page_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1476) as shown in Listing

6-1.

 

1475 **static \_\_always_inline void** 1476 **handle_page_fault**(**struct** pt_regs \*regs, **unsigned long** error_code, 1477 **unsigned long** address) 1478 {

. . .

1484 */\* Was the fault on kernel-controlled part of the address space? \*/*

1485 **if** (**unlikely**(**fault_in_kernel_space**(address))) { 1486 **do_kern_addr_fault**(regs, error_code, address); 1487 } **else** {

1488 **do_user_addr_fault**(regs, error_code, address); 1489 */\**

1490 *\* User address page fault handling might have reenabled* 1491 *\* interrupts. Fixing up all potential exit points of* 1492 *\* do_user_addr_fault() and its leaf functions is just not*

1493 *\* doable w/o creating an unholy mess or turning the code* 1494 *\* upside down.*

 



 

1495 *\*/*

1496 **local_irq_disable**(); 1497 }

1498 }

 

*Listing 6-1:* arch/x86/mm/fault.c: [*handle_page_fault()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1476)

 

We start by determining whether the fault occurred in kernel space

via [fault_in_kernel_space()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1128) and then using this to determine which of

[do_kern_addr_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1147) or [do_user_addr_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1220) to invoke.

 

***6.1.1 Kernel page faults***

Firstly, we will examine how page faults that occur in the kernel portion of virtual address space are handled. The usual functionality available to userspace such as faulting in pages are not available to the kernel, and there-fore most of the time a page fault in a kernel address indicates an error state, however there are occasions where this is not the case.

Regardless, this necessitates entirely separate handling from userland

page faults, which is handled by [fault_in_kernel_space()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1128) as shown in Listing

6-2.

 

1128 **bool fault_in_kernel_space**(**unsigned long** address) 1129 {

1130 */\**

1131 *\* On 64-bit systems, the vsyscall page is at an address above* 1132 *\* TASK_SIZE_MAX, but is not considered part of the kernel* 1133 *\* address space.* 1134 *\*/*

1135 **if** (**IS_ENABLED**(**CONFIG_X86_64**) && **is_vsyscall_vaddr**(address)) 1136 **return false**; 1137

1138 **return** address \>= **TASK_SIZE_MAX**; 1139 }

 

*Listing 6-2:* arch/x86/mm/fault.c: [*fault_in_kernel_space()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1128)

 

This first checks if the page fault is for the legacy vsyscall page via

[is_vsyscall_vaddr(). ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n794)This is a page of memory ostensibly mapped into userspace to improve performance of some system calls, however this func-tionality is typically disabled or emulated (via CONFIG_X86_VSYSCALL_EMULATION) due to security concerns.

Otherwise, it simply checks to see if the virtual address is equal to or ex-

ceeds [TASK_SIZE_MAX](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_64_types.h?h=v6.0#n64) which is the first address outside of the userland mem-ory range.

Faults in kernel address space is handled by [do_kern_addr_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1147) (eliding

irrelevant 32-bit and kprobe cases) as shown in Listing 6-3.

 

1141 */\**

1142 *\* Called for all faults where 'address' is part of the kernel address*

 



 

1143 *\* space. Might get called for faults that originate from \*code\* that* 1144 *\* ran in userspace or the kernel.* 1145 *\*/*

1146 **static void**

1147 **do_kern_addr_fault**(**struct** pt_regs \*regs, **unsigned long** hw_error_code, 1148 **unsigned long** address) 1149 {

. . .

1191 */\* Was the fault spurious, caused by lazy TLB invalidation? \*/* 1192 **if** (**spurious_kernel_fault**(hw_error_code, address)) 1193 **return**;

. . .

1199 */\**

1200 *\* Note, despite being a "bad area", there are quite a few* 1201 *\* acceptable reasons to get here, such as erratum fixups* 1202 *\* and handling kernel code that can fault, like get_user().* 1203 *\**

1204 *\* Don't take the mm semaphore here. If we fixup a prefetch* 1205 *\* fault we could otherwise deadlock:* 1206 *\*/*

1207 **bad_area_nosemaphore**(regs, hw_error_code, address); 1208 }

 

*Listing 6-3:* arch/x86/mm/fault.c: [*do_kern_addr_fault()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1147)

 

Firstly we determine whether the kernel fault was spurious – that is, due

to lazy TLB, a kernel TLB entry is permitted to go stale, meaning that an

invalid access to a write-protected or execution-protected region of memory

may occur due to the TLB entry (see section 7.1).

 

**N O T E** The Transaction Lookaside Buffer (TLB) is a key hardware cache between virtual

and physical addresses used to avoid having to walk the page table for every memory

access.

 

Therefore, if the kernel tries to write to read-only memory or execute in

NX (no execute) memory we must check whether the page table entry actu-

ally does permit this despite the fault. We do this in [spurious_kernel_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1007)

as shown in Listing 6-4.

 

985 */\**

986 *\* Handle a spurious fault caused by a stale TLB entry.* 987 *\**

988 *\* This allows us to lazily refresh the TLB when increasing the* 989 *\* permissions of a kernel page (RO -\> RW or NX -\> X). Doing it* 990 *\* eagerly is very expensive since that implies doing a full* 991 *\* cross-processor TLB flush, even if no stale TLB entries exist* 992 *\* on other processors.*

993 *\**

994 *\* Spurious faults may only occur if the TLB contains an entry with*

 



 

995 *\* fewer permission than the page table entry. Non-present (P = 0)* 996 *\* and reserved bit (R = 1) faults are never spurious.* 997 *\**

998 *\* There are no security implications to leaving a stale TLB when* 999 *\* increasing the permissions on a page.*

1000 *\**

1001 *\* Returns non-zero if a spurious fault was handled, zero otherwise.* 1002 *\**

1003 *\* See Intel Developer's Manual Vol 3 Section 4.10.4.3, bullet 3* 1004 *\* (Optional Invalidation).* 1005 *\*/*

1006 **static noinline int**

1007 **spurious_kernel_fault**(**unsigned long** error_code, **unsigned long** address) 1008 {

1009 **pgd_t** \*pgd;

1010 **p4d_t** \*p4d;

1011 **pud_t** \*pud;

1012 **pmd_t** \*pmd;

1013 **pte_t** \*pte;

1014 **int** ret;

1015

1016 */\**

1017 *\* Only writes to RO or instruction fetches from NX may cause* 1018 *\* spurious faults.* 1019 *\**

1020 *\* These could be from user or supervisor accesses but the TLB* 1021 *\* is only lazily flushed after a kernel mapping protection* 1022 *\* change, so user accesses are not expected to cause spurious* 1023 *\* faults.*

1024 *\*/*

1025 **if** (error_code != (**X86_PF_WRITE** \| **X86_PF_PROT**) && 1026 error_code != (**X86_PF_INSTR** \| **X86_PF_PROT**)) 1027 **return** 0; 1028

1029 pgd = init_mm.pgd + **pgd_index**(address); 1030 **if** (!**pgd_present**(\*pgd)) 1031 **return** 0; 1032

1033 p4d = **p4d_offset**(pgd, address); 1034 **if** (!**p4d_present**(\*p4d)) 1035 **return** 0; 1036

1037 **if** (**p4d_large**(\*p4d)) 1038 **return spurious_kernel_fault_check**(error_code, (**pte_t** \*) p4d); 1039

1040 pud = **pud_offset**(p4d, address); 1041 **if** (!**pud_present**(\*pud))

 



 

1042 **return** 0; 1043

1044 **if** (**pud_large**(\*pud)) 1045 **return spurious_kernel_fault_check**(error_code, (**pte_t** \*) pud); 1046

1047 pmd = **pmd_offset**(pud, address); 1048 **if** (!**pmd_present**(\*pmd)) 1049 **return** 0; 1050

1051 **if** (**pmd_large**(\*pmd)) 1052 **return spurious_kernel_fault_check**(error_code, (**pte_t** \*) pmd); 1053

1054 pte = **pte_offset_kernel**(pmd, address); 1055 **if** (!**pte_present**(\*pte)) 1056 **return** 0; 1057

1058 ret = **spurious_kernel_fault_check**(error_code, pte); 1059 **if** (!ret)

1060 **return** 0; 1061

1062 */\**

1063 *\* Make sure we have permissions in PMD.* 1064 *\* If not, then there's a bug in the page tables:* 1065 *\*/*

1066 ret = **spurious_kernel_fault_check**(error_code, (**pte_t** \*) pmd); 1067 **WARN_ONCE**(!ret, "PMD has incorrect permission bits\n"); 1068

1069 **return** ret;

1070 }

 

*Listing 6-4:* arch/x86/mm/fault.c: [*spurious_kernel_fault()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1007)

 

This simply walks the page tables, checking whether each page table level

is present, and if so if it is potentially a huge page (see huge page chapter for

more on this topic) checking whether the huge page entry (equivalent to a

PTE) is valid, otherwise (if the page table mappings are present) reaching

the PTE itself and performing this check there.

There is an additional check for PTE in case the PMD has incorrect per-

missions set as an additional bug check.

Each of these checks is performed by [spurious_kernel_fault_check()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n974) as

shown in Listing 6-5.

 

974 **static int spurious_kernel_fault_check**(**unsigned long** error_code, **pte_t** \*pte) 975 {

976 **if** ((error_code & **X86_PF_WRITE**) && !**pte_write**(\*pte)) 977 **return** 0;

978

979 **if** ((error_code & **X86_PF_INSTR**) && !**pte_exec**(\*pte)) 980 **return** 0;

 



 

981

982 **return** 1;

983 }

 

*Listing 6-5:* arch/x86/mm/fault.c: [*spurious_kernel_fault_check()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n974)

 

This simply checks whether the PTE (or PTE equivalent) page table en-

try does indeed match the page fault, where [X86_PF_WRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/trap_pf.h?h=v6.0#n18) and [X86_PF_INSTR](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/trap_pf.h?h=v6.0#n21) are page fault error codes that represent a write to read-only memory and

execution of code in NX memory respectively, checked by [pte_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n157) and

[pte_exec().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n172)

Coming back to [do_kern_addr_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1147)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1147) if the fault was not spurious, we in-

voke [bad_area_nosemaphore()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n852), which is used to handle invalid memory accesses

when no [struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) semaphore is held. This in turn invokes

[\_\_bad_area_nosemaphore()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n800) with the signal error set to [SEGV_MAPERR](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/asm-generic/siginfo.h?h=v6.0#n232) as shown in

Listing 6-6.

 

799 **static void**

800 **\_\_bad_area_nosemaphore**(**struct** pt_regs \*regs, **unsigned long** error_code, 801 **unsigned long** address, **u32** pkey, **int** si_code) 802 {

803 **struct** task_struct \*tsk = current; 804

805 **if** (!**user_mode**(regs)) { 806 **kernelmode_fixup_or_oops**(regs, error_code, address, 807 **SIGSEGV**, si_code, pkey); 808 **return**;

809 }

810

. . .

849 }

 

*Listing 6-6:* arch/x86/mm/fault.c: *Kernel handling in [\_\_bad_area_nosemaphore()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n800)*

 

Note that we elide the user-mode handling of this function which we

discuss in section 6.11. This passes through to [kernelmode_fixup_or_oops()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n712) as

shown in Listing 6-7.

 

711 **static noinline void**

712 **kernelmode_fixup_or_oops**(**struct** pt_regs \*regs, **unsigned long** error_code, 713 **unsigned long** address, **int** signal, **int** si_code, 714 **u32** pkey) 715 {

716 **WARN_ON_ONCE**(**user_mode**(regs)); 717

718 */\* Are we prepared to handle this kernel fault? \*/* 719 **if** (**fixup_exception**(regs, **X86_TRAP_PF**, error_code, address)) { 720 */\**

721 *\* Any interrupt that takes a fault gets the fixup. This makes*

722 *\* the below recursive fault logic only apply to a faults from*

 



 

723 *\* task context.* 724 *\*/*

725 **if** (**in_interrupt**()) 726 **return**;

727

728 */\**

729 *\* Per the above we're !in_interrupt(), aka. task context.*

730 *\**

731 *\* In this case we need to make sure we're not recursively*

732 *\* faulting through the emulate_vsyscall() logic.* 733 *\*/*

734 **if** (current-\>thread.sig_on_uaccess_err && signal) { 735 **sanitize_error_code**(address, &error_code);

736

737 **set_signal_archinfo**(address, error_code);

738

739 **if** (si_code == **SEGV_PKUERR**) { 740 **force_sig_pkuerr**((**void \_\_user** \*)address, pkey)

;

741 } **else** { 742 */\* XXX: hwpoison faults will set the wrong*

*code. \*/*

743 **force_sig_fault**(signal, si_code, (**void \_\_user**

\*)address);

744 } 745 }

746

747 */\**

748 *\* Barring that, we can do the fixup and be happy.* 749 *\*/*

750 **return**;

751 }

752

753 */\**

754 *\* AMD erratum \#91 manifests as a spurious page fault on a PREFETCH*

755 *\* instruction.*

756 *\*/*

757 **if** (**is_prefetch**(regs, error_code, address)) 758 **return**;

759

760 **page_fault_oops**(regs, error_code, address); 761 }

 

*Listing 6-7:* arch/x86/mm/fault.c: [*kernelmode_fixup_or_oops()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n712)

 

We first check to see if we are fixing up an exception from the kernel

uaccess interface via [fixup_exception()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/extable.c?h=v6.0#n205)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/extable.c?h=v6.0#n205) Section 8.1.1 covers this in detail, but

briefly – this is a means by which the kernel can access userland mappings

 



 

directly, i.e. by simply accessing a userland virtual address, but it can only be performed in certain designated places in the kernel in case of unhandled page faults.

If we indeed we were fixing up (not in the case we are examining here –

as the fault is in a kernel address, not userland), then no oops will be caused and we perform one more specific check – if we are not in interrupt context,

and the current [struct task_struct-\>thread](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) architecture-specific thread in-

formation state [struct thread_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/processor.h?h=v6.0#n469) has its sig_on_uaccess_err flag set, and a signal has been specified, then this signal is sent.

Finally, we cover an AMD spurious page fault edge case, before accepting

that this was an invalid access and thus a kernel oops must be raised and

invoking [page_fault_oops()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n632).

 

**N O T E** A kernel oops means that something has gone terribly wrong in the kernel. It will,

under ordinary circumstances, simply cause the running userland process to be *SIGKILL* ’d with a message reported to the kernel log, however if this is a kernel thread or under other circumstances (such as the tunable *kernel.panic_on_oops* being set) then this results in the kernel panicking, i.e. the kernel being halted altogether.

 

Examining [page_fault_oops()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n632) as shown in Listing 6-8.

 

631 **static noinline void**

632 **page_fault_oops**(**struct** pt_regs \*regs, **unsigned long** error_code, 633 **unsigned long** address) 634 {

635 **\#ifdef CONFIG_VMAP_STACK**

636 **struct** stack_info info; 637 **\#endif**

638 **unsigned long** flags; 639 **int** sig;

640

641 **if** (**user_mode**(regs)) { 642 */\**

643 *\* Implicit kernel access from user mode? Skip the stack* 644 *\* overflow and EFI special cases.* 645 *\*/*

646 **goto oops**; 647 }

648

649 **\#ifdef CONFIG_VMAP_STACK**

650 */\**

651 *\* Stack overflow? During boot, we can fault near the initial* 652 *\* stack in the direct map, but that's not an overflow -- check* 653 *\* that we're in vmalloc space to avoid this.* 654 *\*/*

655 **if** (**is_vmalloc_addr**((**void** \*)address) && 656 **get_stack_guard_info**((**void** \*)address, &info)) { 657 */\**

 



 

658 *\* We're likely to be running with very little stack space*

659 *\* left. It's plausible that we'd hit this condition but* 660 *\* double-fault even before we get this far, in which case*

661 *\* we're fine: the double-fault handler will deal with it.*

662 *\**

663 *\* We don't want to make it all the way into the oops code*

664 *\* and then double-fault, though, because we're likely to* 665 *\* break the console driver and lose most of the stack dump.*

666 *\*/*

667 **call_on_stack**(**\_\_this_cpu_ist_top_va**(**DF**) -**sizeof**(**void**\*), 668 **handle_stack_overflow**, 669 **ASM_CALL_ARG3**, 670 , \[arg1\] "r" (regs), \[arg2\] "r" (address), \[arg3

\] "r" (&info));

671

672 **unreachable**(); 673 }

674 **\#endif**

675

676 */\**

677 *\* Buggy firmware could access regions which might page fault. If*

678 *\* this happens, EFI has a special OOPS path that will try to* 679 *\* avoid hanging the system.* 680 *\*/*

681 **if** (**IS_ENABLED**(**CONFIG_EFI**)) 682 **efi_crash_gracefully_on_page_fault**(address);

683

684 */\* Only not-present faults should be handled by KFENCE. \*/* 685 **if** (!(error_code & **X86_PF_PROT**) && 686 **kfence_handle_page_fault**(address, error_code & **X86_PF_WRITE**, regs)

)

687 **return**;

688

689 **oops**:

690 */\**

691 *\* Oops. The kernel tried to access some bad page. We'll have to* 692 *\* terminate things with extreme prejudice:* 693 *\*/*

694 flags = **oops_begin**();

695

696 **show_fault_oops**(regs, error_code, address);

697

698 **if** (**task_stack_end_corrupted**(current)) 699 **printk**(**KERN_EMERG** "Thread overran stack, or stack corrupted\n"

);

700

701 sig = **SIGKILL**;

 



 

702 **if** (**\_\_die**("Oops", regs, error_code)) 703 sig = 0;

704

705 */\* Executive summary in case the body of the oops scrolled away \*/*

706 **printk**(**KERN_DEFAULT** "CR2: %016lx\n", address); 707

708 **oops_end**(flags, regs, sig); 709 }

 

*Listing 6-8:* arch/x86/mm/fault.c: [*page_fault_oops()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n632)

 

Note this function is explicitly invoked for invalid accesses to kernel map-

pings. It performs a few specific checks if we are in kernel context, if we are in userland trying to access kernel memory then these are skipped:

 

• Was this was a stack overflow due to hitting a ‘guard page’? (i.e. a page

mapped such that it will fault just below the stack so this condition is detectable) if we use vmalloc kernel stacks (this makes it easy to detect this situation, whereas kernel stacks using the direct mapping make it harder to track this condition).

• If the kernel is EFI-enabled via CONFIG_EFI, then perform specific han-

dling for buggy firmware.

• Finally, if [kfence](https://kernel.org/doc/html/v6.0/dev-tools/kfence.html) handling is enabled (via CONFIG_KFENCE), then let this logic

handle the fault if it arose due to the memory not being present.

 

After these checks are complete, we perform the oops itself, updat-

ing the kernel log and performing ordinary kernel oops handling via

[oops_begin()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/dumpstack.c?h=v6.0#n324), [show_fault_oops()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n507), [\_\_die()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/dumpstack.c?h=v6.0#n422) and [oops_end()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/dumpstack.c?h=v6.0#n350) (this topic is out of scope for the book).

 

***6.1.2 Userland page faults***

Now let’s examine the userland case – note that this is invoked both in user-land and kernel mode when accessing userland addresses. This is handled in

[do_user_addr_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1220).

Let’s start by examining the initial checks performed by this function

(eliding out of scope kprobe and SMAP handling) as shown in Listing 6-9.

 

1219 **static inline**

1220 **void do_user_addr_fault**(**struct** pt_regs \*regs, 1221 **unsigned long** error_code, 1222 **unsigned long** address) 1223 {

1224 **struct** vm_area_struct \*vma; 1225 **struct** task_struct \*tsk; 1226 **struct** mm_struct \*mm; 1227 **vm_fault_t** fault; 1228 **unsigned int** flags = **FAULT_FLAG_DEFAULT**; 1229

 



 

1230 tsk = current;

1231 mm = tsk-\>mm;

1232

1233 **if** (**unlikely**((error_code & (**X86_PF_USER** \| **X86_PF_INSTR**)) ==

**X86_PF_INSTR**)) {

1234 */\**

1235 *\* Whoops, this is kernel mode code trying to execute from*

1236 *\* user memory. Unless this is AMD erratum \#93, which* 1237 *\* corrupts RIP such that it looks like a user address,* 1238 *\* this is unrecoverable. Don't even try to look up the* 1239 *\* VMA or look for extable entries.* 1240 *\*/*

1241 **if** (**is_errata93**(regs, address)) 1242 **return**; 1243

1244 **page_fault_oops**(regs, error_code, address); 1245 **return**;

1246 }

1247

. . .

1252 */\**

1253 *\* Reserved bits are never expected to be set on* 1254 *\* entries in the user portion of the page tables.* 1255 *\*/*

1256 **if** (**unlikely**(error_code & **X86_PF_RSVD**)) 1257 **pgtable_bad**(regs, error_code, address);

. . .

1277 */\**

1278 *\* If we're in an interrupt, have no user context or are running* 1279 *\* in a region with pagefaults disabled then we must not take the*

*fault*

1280 *\*/*

1281 **if** (**unlikely**(**faulthandler_disabled**() \|\| !mm)) { 1282 **bad_area_nosemaphore**(regs, error_code, address); 1283 **return**;

1284 }

1285

1286 */\**

1287 *\* It's safe to allow irq's after cr2 has been saved and the* 1288 *\* vmalloc fault has been handled.* 1289 *\**

1290 *\* User-mode registers count as a user access even for any* 1291 *\* potential system fault or CPU buglet:* 1292 *\*/*

1293 **if** (**user_mode**(regs)) { 1294 **local_irq_enable**(); 1295 flags \|= **FAULT_FLAG_USER**;

 



 

1296 } **else** {

1297 **if** (regs-\>flags & **X86_EFLAGS_IF**) 1298 **local_irq_enable**(); 1299 }

1300

1301 **perf_sw_event**(**PERF_COUNT_SW_PAGE_FAULTS**, 1, regs, address); 1302

1303 **if** (error_code & **X86_PF_WRITE**) 1304 flags \|= **FAULT_FLAG_WRITE**; 1305 **if** (error_code & **X86_PF_INSTR**) 1306 flags \|= **FAULT_FLAG_INSTRUCTION**; 1307

1308 **\#ifdef CONFIG_X86_64**

1309 */\**

1310 *\* Faults in the vsyscall page might need emulation. The* 1311 *\* vsyscall page is at a high address (\>PAGE_OFFSET), but is* 1312 *\* considered to be part of the user address space.* 1313 *\**

1314 *\* The vsyscall page does not have a "real" VMA, so do this* 1315 *\* emulation before we go searching for VMAs.* 1316 *\**

1317 *\* PKRU never rejects instruction fetches, so we don't need* 1318 *\* to consider the PF_PK bit.* 1319 *\*/*

1320 **if** (**is_vsyscall_vaddr**(address)) { 1321 **if** (**emulate_vsyscall**(error_code, regs, address)) 1322 **return**; 1323 }

1324 **\#endif**

 

*Listing 6-9:* arch/x86/mm/fault.c: [*do_user_addr_fault()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1220) *Initial checks*

 

The logic is as follows:

 

• Check whether the fault is arising from the kernel (indicated by the er-

ror code not having [X86_PF_USER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/trap_pf.h?h=v6.0#n19) set) is trying to execute code (indicated

via [X86_PF_INSTR](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/trap_pf.h?h=v6.0#n21)). This is simply not permitted – under no circumstances should kernel mode attempt to execute code from userland, least of all when that causes a page fault.

• If the error code indicates that a page table entry flipped reserved bits,

raise an oops via [pgtable_bad()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n584)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n584)

• If page fault handling is disabled or we are in atomic context (for ex-

ample in an IRQ handler) as determined by [faulthandler_disabled()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/uaccess.h?h=v6.0#n232)

(which checks these two cases via [in_atomic()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/preempt.h?h=v6.0#n174) and [pagefault_disabled()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/uaccess.h?h=v6.0#n217))

or there is no [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) context (e.g. this is a classical kernel thread), then we do not process the page fault and instead invoke

[bad_area_nosemaphore(). ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n852)We discuss the various userland address bad ad-dress scenarios below.

 



 

• If the fault occurred in user mode, we set the [FAULT_FLAG_USER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n870) flag to in-

dicate this (more on fault flags below). We additionally conditionally enable local IRQs. Interrupt handling is out of scope for the book.

• After updating statistics, specify [FAULT_FLAG_WRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n864) if the fault was a write

fault or [FAULT_FLAG_INSTRUCTION](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n872) was on execution.

• If the fault occurred in the legacy vsyscall page, then provide emulation

for this if appropriate. Discussion of this is out of scope for the book.

 

Next, we acquire the [struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_struct.h?h=v6.0#n486) and invoke the generic

fault handling logic as shown in Listing 6-10.

 

1326 */\**

1327 *\* Kernel-mode access to the user address space should only occur* 1328 *\* on well-defined single instructions listed in the exception* 1329 *\* tables. But, an erroneous kernel fault occurring outside one of*

1330 *\* those areas which also holds mmap_lock might deadlock attempting*

1331 *\* to validate the fault against the address space.* 1332 *\**

1333 *\* Only do the expensive exception table search when we might be at*

1334 *\* risk of a deadlock. This happens if we* 1335 *\* 1. Failed to acquire mmap_lock, and* 1336 *\* 2. The access did not originate in userspace.* 1337 *\*/*

1338 **if** (**unlikely**(!**mmap_read_trylock**(mm))) { 1339 **if** (!**user_mode**(regs) && !**search_exception_tables**(regs-\>ip)) { 1340 */\** 1341 *\* Fault from code in kernel from* 1342 *\* which we do not expect faults.* 1343 *\*/* 1344 **bad_area_nosemaphore**(regs, error_code, address); 1345 **return**; 1346 }

1347 **retry**:

1348 **mmap_read_lock**(mm); 1349 } **else** {

1350 */\**

1351 *\* The above down_read_trylock() might have succeeded in* 1352 *\* which case we'll have missed the might_sleep() from* 1353 *\* down_read():* 1354 *\*/*

1355 **might_sleep**(); 1356 }

1357

1358 vma = **find_vma**(mm, address); 1359 **if** (**unlikely**(!vma)) { 1360 **bad_area**(regs, error_code, address); 1361 **return**;

 



 

1362 }

1363 **if** (**likely**(vma-\>vm_start \<= address)) 1364 **goto good_area**; 1365 **if** (**unlikely**(!(vma-\>vm_flags & **VM_GROWSDOWN**))) { 1366 **bad_area**(regs, error_code, address); 1367 **return**;

1368 }

1369 **if** (**unlikely**(**expand_stack**(vma, address))) { 1370 **bad_area**(regs, error_code, address); 1371 **return**;

1372 }

1373

1374 */\**

1375 *\* Ok, we have a good vm_area for this memory access, so* 1376 *\* we can handle it..* 1377 *\*/*

1378 **good_area**:

1379 **if** (**unlikely**(**access_error**(error_code, vma))) { 1380 **bad_area_access_error**(regs, error_code, address, vma); 1381 **return**;

1382 }

1383

1384 */\**

1385 *\* If for any reason at all we couldn't handle the fault,* 1386 *\* make sure we exit gracefully rather than endlessly redo* 1387 *\* the fault. Since we never set FAULT_FLAG_RETRY_NOWAIT, if* 1388 *\* we get VM_FAULT_RETRY back, the mmap_lock has been unlocked.* 1389 *\**

1390 *\* Note that handle_userfault() may also release and reacquire*

*mmap_lock*

1391 *\* (and not return with VM_FAULT_RETRY), when returning to userland to*

1392 *\* repeat the page fault later with a VM_FAULT_NOPAGE retval* 1393 *\* (potentially after handling any pending signal during the return to*

1394 *\* userland). The return to userland is identified whenever* 1395 *\* FAULT_FLAG_USER\|FAULT_FLAG_KILLABLE are both set in flags.* 1396 *\*/*

1397 fault = **handle_mm_fault**(vma, address, flags, regs);

 

*Listing 6-10:* arch/x86/mm/fault.c: [*do_user_addr_fault()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1220) *fault handling*

 

If we can’t immediately acquire the [struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_struct.h?h=v6.0#n486), we enter

a very specific edge case – to avoid a deadlock occurring in kernel uaccess handling when this lock is already held we perform the expensive kernel

[search_exception_tables()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/extable.c?h=v6.0#n54) operation here – if this fails then we are done. If we can obtain the lock, then this check will only be performed if the user-

land fault handler is unable to handle the fault. See section 8.1.1 for more on uaccess.

 



 

We now find ourselves in the core page fault handling logic with the

mm_struct read lock held and ready to proceed with the generic page fault

logic. We start by finding the VMA (we cover this in section 4.4.5) via

[find_vma(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2253)which determines the first VMA whose vm_end exceeds the fault-

ing address.

Once we have determined which VMA fulfils this requirement, we must

determine whether the faulting address sits within it by seeing if it sits

above its vm_start. If so, we’re good and move on to good_area to perform the

generic page fault handling.

If not, we check to see if this is a stack that grows downwards – which it

would need to be for the address to be valid and for it to be less than this

VMA’s vm_start. We perform this check via [expand_stack()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2553) which in turn in-

vokes [expand_downwards()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2441)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2441) See section 6.10 for a detailed analysis of this.

Prior to handing over to the generic page table handler, we invoke

[access_error()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1076) to ensure that access is indeed permitted for the VMA (for

example, a write fault might occur on a Copy on Write mapping, but it also

might occur on a readonly one and we have to differentiate between the

two):

Prior to handing over to the generic page fault handler [handle_mm_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5129)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5129)

we check to ensure that it is a valid access via [access_error()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1076)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1076) returning 0 if

the access is OK, 1 otherwise (eliding out of scope protection keys and SGX

checks) as shown in Listing 6-11.

 

1075 **static inline int**

1076 **access_error**(**unsigned long** error_code, **struct** vm_area_struct \*vma) 1077 {

1078 */\* This is only called for the current mm, so: \*/* 1079 **bool** foreign = **false**;

. . .

1110 **if** (error_code & **X86_PF_WRITE**) { 1111 */\* write, present and write, not present: \*/* 1112 **if** (**unlikely**(!(vma-\>vm_flags & **VM_WRITE**))) 1113 **return** 1; 1114 **return** 0; 1115 }

1116

1117 */\* read, present: \*/* 1118 **if** (**unlikely**(error_code & **X86_PF_PROT**)) 1119 **return** 1; 1120

1121 */\* read, not present: \*/* 1122 **if** (**unlikely**(!**vma_is_accessible**(vma))) 1123 **return** 1; 1124

1125 **return** 0;

1126 }

 

*Listing 6-11:* arch/x86/mm/fault.c: [*access_error()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1076)

 



 

We indicate an access error if:

 

• The fault was a write fault but the VMA does not permit writes (so this is

confirmed not to be a Copy on Write error).

• The fault was a protection fault, i.e. the memory is present, but not per-

mitted to be read.

• The VMA is designated as not being accessible via [vma_is_accessible()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n659)

(i.e., none of the flags specified in [VM_ACCESS_FLAGS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n404) are set – neither

[VM_READ ,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n266) [VM_WRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n267) nor [VM_EXEC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n268)).

 

If at any point a bad access is detected, we handle this in [bad_area()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n873)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n873) We

will examine this in detail in section 6.11. After all these checks are com-plete, we are ready to perform the generic page table handling that’s shared

between all architectures via [handle_mm_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5129)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5129) see section 6.2 for a very de-tailed analysis of this!

Finally, after the page fault handling is complete, we handle any post-

fault actions as determined by the results of the page fault as shown in List-

ing 6-12.

 

1399 **if** (**fault_signal_pending**(fault, regs)) { 1400 */\**

1401 *\* Quick path to respond to signals. The core mm code* 1402 *\* has unlocked the mm for us if we get here.* 1403 *\*/*

1404 **if** (!**user_mode**(regs)) 1405 **kernelmode_fixup_or_oops**(regs, error_code, address, 1406 **SIGBUS**, **BUS_ADRERR**, 1407 **ARCH_DEFAULT_PKEY**); 1408 **return**;

1409 }

1410

1411 */\* The fault is fully completed (including releasing mmap lock) \*/*

1412 **if** (fault & **VM_FAULT_COMPLETED**) 1413 **return**;

1414

1415 */\**

1416 *\* If we need to retry the mmap_lock has already been released,* 1417 *\* and if there is a fatal signal pending there is no guarantee* 1418 *\* that we made any progress. Handle this case first.* 1419 *\*/*

1420 **if** (**unlikely**(fault & **VM_FAULT_RETRY**)) { 1421 flags \|= **FAULT_FLAG_TRIED**; 1422 **goto** retry; 1423 }

1424

1425 **mmap_read_unlock**(mm); 1426 **if** (**likely**(!(fault & **VM_FAULT_ERROR**))) 1427 **return**;

 



 

1428

1429 **if** (**fatal_signal_pending**(current) && !**user_mode**(regs)) { 1430 **kernelmode_fixup_or_oops**(regs, error_code, address, 1431 0, 0, **ARCH_DEFAULT_PKEY**); 1432 **return**;

1433 }

1434

1435 **if** (fault & **VM_FAULT_OOM**) { 1436 */\* Kernel mode? Handle exceptions or die: \*/* 1437 **if** (!**user_mode**(regs)) { 1438 **kernelmode_fixup_or_oops**(regs, error_code, address, 1439 **SIGSEGV**, **SEGV_MAPERR**, 1440 **ARCH_DEFAULT_PKEY**); 1441 **return**; 1442 }

1443

1444 */\**

1445 *\* We ran out of memory, call the OOM killer, and return the*

1446 *\* userspace (which will retry the fault, or kill us if we got*

1447 *\* oom-killed):* 1448 *\*/*

1449 **pagefault_out_of_memory**(); 1450 } **else** {

1451 **if** (fault & (**VM_FAULT_SIGBUS**\|**VM_FAULT_HWPOISON**\| 1452 **VM_FAULT_HWPOISON_LARGE**)) 1453 **do_sigbus**(regs, error_code, address, fault); 1454 **else if** (fault & **VM_FAULT_SIGSEGV**) 1455 **bad_area_nosemaphore**(regs, error_code, address); 1456 **else**

1457 **BUG**(); 1458 }

1459 }

 

*Listing 6-12:* arch/x86/mm/fault.c: [*do_user_addr_fault()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1220) *post-fault handling*

This logic behaves according to the [enum vm_fault_reason](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n741) returned by

[handle_mm_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5129), with special handling for signals. These form a bitmap and

thus can be combined:

 

***6.1.3 Success conditions***

• [VM_FAULT_COMPLETED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n755) – The page fault is complete and has been entirely

resolved with [struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) released. This occurs in a specific situation – on the first fault attempt

with retry allowed (via [FAULT_FLAG_ALLOW_RETRY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n866) and tested in

[fault_flag_allow_retry_first()) ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n453)on a shared page write fault which dirt-

ies the page in [fault_dirty_shared_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2993) and checks whether the un-

lock can occur in [maybe_unlock_mmap_for_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n607) after balancing dirty pages

via [balance_dirty_pages_ratelimited()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1949)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1949) We discuss the dirty shared page

 



 

faulting logic and FAULT_FLAG_ALLOW_RETRY logic below and writeback in the page cache chapter.

• [~VM_FAULT_ERROR](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n763) – The page fault is complete and has been resolved, how-

ever the mmap_lock is still held and must be released. VM_FAULT_ERROR is a bitmask of the error conditions described below.

 

***6.1.4 Informational***

• [VM_FAULT_MAJOR](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n744) – Indicates that a major fault has occurred. A major fault is

one that occurs when the memory being faulted is not present in RAM – typically this means an expensive disk access is required – either by swapping in memory or loading a page into the page cache. A minor page fault is any other page fault.

• [VM_FAULT_NOPAGE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n749) – Indicates that the PTE has been populated but we can-

not determine to which folio it points, i.e. the [struct vm_fault-\>page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n481) field is unspecified (we will take a closer look at this data structure in sec-

tion 6.2, but broadly it contains page fault state). Typically used when a race condition replaces the PTE entry or the PTE was never intended to point to a data page in the first place.

• [VM_FAULT_WRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n745) – Indicates that a write fault occurred. This is

only used by the out-of-scope [Kernel Samepage Merging (KSM)](https://kernel.org/doc/html/v6.0/mm/ksm.html) logic, which was removed shortly after kernel v6 (in commit

[cb8d86331343: mm: remove VM_FAULT_WRITE).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=cb8d86331343)

• [VM_FAULT_LOCKED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n750) – Indicates that the faulted-in folio has been marked

locked, i.e. had its [PG_locked](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n101) folio flag set.

• [VM_FAULT_DONE_COW](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n753) – Indicates the VMA-specific fault handler has already

handled the Copy-on-Write operation. Used only by the [Direct Access for](https://kernel.org/doc/html/v6.0/filesystems/dax.html)

[files (DAX)](https://kernel.org/doc/html/v6.0/filesystems/dax.html) which is out of scope for the book.

• [VM_FAULT_NEEDDSYNC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n754) – Indicates a DAX mapping requires synchronisation.

Discussion of DAX is out of scope for the book.

 

***6.1.5 Error conditions***

• [VM_FAULT_RETRY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n751) – mmap_lock released – Indicates that an attempt has been

made to acquire locks but failed, so rather than block on them, the func-tion has exited early to permit a retry. This only occurs once, and only if

[FAULT_FLAG_ALLOW_RETRY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n866) was set. On the second attempt, [FAULT_FLAG_TRIED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n869) is set to indicate that it has been tried once.

• [VM_FAULT_OOM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n742) – mmap_lock released – The system lacks sufficient memory to

allocate the memory and any direct reclaim performed has been insuf-ficient to change this fact – the Out of Memory (OOM) killer must be invoked to free some up (see the chapter on this for more details).

• [VM_FAULT_SIGBUS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n743) – Indicates that an access was made to an invalid address

in a mapping (e.g. reading past the extant pages of a memory-mapped file). the process will be sent the SIGBUS signal.

 



 

• [VM_FAULT_SIGSEGV](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n748) – Indicates that an access was made to either unmapped

memory or memory for which the user does not have permission. The process will be sent the SIGSEGV signal.

• [VM_FAULT_HWPOISON](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n746), [VM_FAULT_HWPOISON_LARGE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n747) – Indicates that the memory

being accessed has been marked as hardware ‘poisoned’ as part of the CONFIG_MEMORY_FAILURE functionality. Discussion of this is out of scope for the book.

• [VM_FAULT_FALLBACK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n752) – Indicates that a huge page fault failed and should

fallback to using ordinary base pages. We defer discussion of huge pages to the huge page chapter so won’t examine this case in detail here.

 

We examine the post-fault logic in Figure 6-2.

 

From figure 6-3

 

[handle_mm_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5129) complete

 

Yes No

[fault_signal_pending() ?](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/signal.h?h=v6.0#n429)

[mm-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) unlkd

 

No Yes

Kernel mode? **Done** [VM_FAULT_COMPLETED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n755)[?](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n755)

[mm-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) unlkd

No No

No

[VM_FAULT_ERROR](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n763)? [VM_FAULT_RETRY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n751)[?](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n751)

Yes Unlck [mm-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)

Yes [mm-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) unlkd Yes

Yes To figure 6-1, set [FAULT_FLAG_TRIED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n869)

[kernelmode_fixup_or_oops()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n712) Kernel [fatal_signal_pending()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/signal.h?h=v6.0#n408)?

 

Yes

No

Yes

Kernel mode? [VM_FAULT_OOM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n742)?

 

No No

Any other

[pagefault_out_of_memory()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n1186) Which flag? [BUG()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/bug.h?h=v6.0#n66)

[VM_FAULT_SIGBUS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n743)

[VM_FAULT_HWPOISON](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n746)

[VM_FAULT_SIGSEGV](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n748)

[VM_FAULT_HWPOISON_LARGE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n747)

 

[do_sigbus()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n934) [bad_area_nosemaphore()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n852)

 

*Figure 6-2: Overview of post-fault handling in* [*do_user_addr_fault()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree//arch/x86/mm/fault.c?h=v6.0#n1220)

 

Note that after the page fault handler returns and the process can still be

scheduled (i.e. is not subject to a segfault) the access will be tried again. The

page fault handler will, on a successful page fault, have updated the page

tables and thus the access will now succeed.

 



 

We start by checking whether a fault-specific signal is pending for the

process via [fault_signal_pending()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/signal.h?h=v6.0#n429) – this is specific to the case where the

generic page fault handled has returned [VM_FAULT_RETRY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n751) and intended to break the process of retrying the page fault if a signal is pending as shown

in Listing 6-13.

 

423 */\**

424 *\* This should only be used in fault handlers to decide whether we* 425 *\* should stop the current fault routine to handle the signals* 426 *\* instead, especially with the case where we've got interrupted with* 427 *\* a VM_FAULT_RETRY.*

428 *\*/*

429 **static inline bool fault_signal_pending**(**vm_fault_t** fault_flags, 430 **struct** pt_regs \*regs) 431 {

432 **return unlikely**((fault_flags & **VM_FAULT_RETRY**) && 433 (**fatal_signal_pending**(**current**) \|\| 434 (**user_mode**(regs) && **signal_pending**(**current**)))); 435 }

 

*Listing 6-13:* include/linux/sched/signal.h: [*fault_signal_pending()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/signal.h?h=v6.0#n429)

 

If we are in kernel mode and a fatal signal (i.e. SIGKILL) is pending

for this process or if in user mode and any signal is pending, then we should break out to handle this. In the kernel case, we ultimately trigger

[kernelmode_fixup_or_oops()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n712) as the page fault must be handled for forward progress, user mode can simply be allowed to page fault again.

If there is no fault signal pending, we check to see whether

[handle_mm_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5129) reports that the page fault handling is complete

via [VM_FAULT_COMPLETED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n755) – this also means the read lock taken on the

[struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) semaphore will have been released so we can sim-ply exit.

If not, we check to see whether the [VM_FAULT_RETRY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n751) flag was set, if so

this indicates both that the page faulting must be retried and that the

mmap_lock has been released. This sets the [FAULT_FLAG_TRIED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n869) flag on the next handle_mm_fault() to indicate to the generic handler that we have retried al-

ready. See section 6.2 for details on why and when we specify this.

Next we release the lock unconditionally and determine whether we are

dealing with an error or not by comparing the fault handler return value

with [VM_FAULT_ERROR](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n763) – if not, then we simply return.

Otherwise we examine the different possible error states:

 

• A fatal signal (i.e. SIGKILL is pending and we are in kernel mode – if we

in user mode we can simply carry on and defer this, however in kernel we must resolve it immediately as we can’t risk returning from where the kernel instantiated the user memory access with it still pending. In this

case we invoke [kernelmode_fixup_or_oops()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n712) to handle the issue.

• [VM_FAULT_OOM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n742) – There is insufficient memory to service the request, even

with direct reclaim. If in kernel mode we have no choice but to invoke

 



 

the [kernelmode_fixup_or_oops()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n712) handler, however in usermode we can in-

voke the Out of Memory (OOM) Killer via [pagefault_out_of_memory()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n1186)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n1186) See the OOM killer chapter for more on this.

• [VM_FAULT_SIGBUS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n743), [VM_FAULT_HWPOISON](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n746), [VM_FAULT_HWPOISON_LARGE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n747) – Raise a SIGBUS

signal to the user process via [do_sigbus()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n934).

• [VM_FAULT_SIGSEGV](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n748) – Raise a SIGSEGV signal to the user process via

[bad_area_nosemaphore().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n852)

• Any other flag – This should not occur, the only means by which it could

other than a corrupted return value would be for handler to return

[VM_FAULT_FALLBACK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n752), however this is should not be possible here. We catch

either case with an oops-causing [BUG()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/bug.h?h=v6.0#n66)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/bug.h?h=v6.0#n66)

 

**6.2 Page fault handling**

 

We now reach the core of page fault handling in the kernel – the generic

page fault handler used on all architectures – [handle_mm_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5129)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5129) This is one

of the most important functions in the entire kernel, and the place which

userland memory is actually mapped.

We have explored the [enum vm_fault_reason](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n741) return types above – these are

used both internally within the handler as well as to indicate to the caller

what the outcome of the page fault was.

Let’s examine the [enum fault_flag](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n863) bitmap flags that are passed in to the

function (and threaded through the fault logic itself) to indicate both the

type of page fault to be handled and properties of it:

 

• [FAULT_FLAG_WRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n864) – Indicates that the fault was a write protection fault, i.e.

the user attempted to write to a read-only mapping (which may or may not be a Copy on write page).

• [FAULT_FLAG_MKWRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n865) – internal – Indicates that the fault has resulted

in the need for the page table mapping to be made writeable for

a VMA where [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) [-\>vm_ops-\>page_mkwrite()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n539) or struct vm_area_struct-\>vm_ops-\>pfn_mkwrite() have been specified for the VMA and invoked by the fault handler. Set internally by

[do_page_mkwrite()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2959) and [wp_pfn_shared()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3286)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3286)

• [FAULT_FLAG_ALLOW_RETRY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n866) – Indicates that, if a folio lock cannot be obtained,

to simply abort the faulting logic and to return [VM_FAULT_RETRY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n751) to indi-

cate that the fault should be tried again, this time with [FAULT_FLAG_TRIED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n869) set to indicate that the fault has already been tried. Setting this on retry means that a retry will only occur once, as checked by

[fault_flag_allow_retry_first().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n453)

This is checked by [\_\_folio_lock_or_retry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1713), invoked in turn by

[lock_page_or_retry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n998) as well as [maybe_unlock_mmap_for_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n607) which itself is

invoked in turn by [lock_folio_maybe_drop_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2928)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2928) This is only applicable in places where a folio lock is obtained, i.e. file-backed folios when making the disk and memory representation con-

sistent with one another, either in [do_swap_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3718) (covered in the swap

 



 

chapter), DAX logic (out of scope), or most likely, on file-backed page

fault via [filemap_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3084) (see the page cache chapter for more on this.). These will release the read lock on the semaphore

[struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) unless FAULT_FLAG_RETRY_NOWAIT is spec-ified (described below). Use of this flag can help avoid mmap_lock contention while attempting to lock the folio.

• [FAULT_FLAG_RETRY_NOWAIT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n867) – A flag used by the Get User Pages (GUP) logic

when [FOLL_NOWAIT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2887) is specified (see section 8.1.2 for more on this) as well as a number of drivers and the s390 architecture.

This further modifies the FAULT_FLAG_ALLOW_RETRY flag to indicate that

a retry should be permitted but also for [\_\_folio_lock_or_retry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1713) and

[lock_folio_maybe_drop_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2928) to not drop the mmap_lock nor wait to release the folio lock. This prevents further sleeping when trying to unlock the folio (and later reacquire the mmap_lock) while waiting on the lock hence ‘no wait’.

This is not used as part of the core faulting in logic described in the pre-vious section but rather in other invocations of the page fault handler such as GUP.

• [FAULT_FLAG_KILLABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n868) – Indicates that the process which is faulting is in a

state where it can be sent the SIGKILL signal if necessary. The net result is that the lock functions described above used in the

retry case invoke [\_\_folio_lock_killable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1669) instead of [\_\_folio_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1662) and

[folio_wait_locked_killable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1028) instead of [folio_wait_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1022) and the GUP

function [fixup_user_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1327) explicitly checks for a SIGKILL signal.

• [FAULT_FLAG_TRIED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n869) – Set when FAULT_FLAG_RETRY has been specified and the

fault is being retried. This ensures that a retry only occurs once. See the description of FAULT_FLAG_ALLOW_RETRY above.

• [FAULT_FLAG_USER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n870) – Indicates that the fault originates from userland. This

flag not being set implies the fault originates from the kernel. Impor-tantly, this does not refer to the address which is faulting, which is as-sumed to be userland. Kernel address faulting is handled separately by

[do_kern_addr_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1147).

• [FAULT_FLAG_REMOTE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n871) – Indicates that we are faulting in memory for a pro-

cess address space other than ours. This is used by the Get User Pages (GUP) interface and some drivers which are explicitly accessing remote process address spaces and does not form part of ordinary page fault-

ing. See section 8.1.2 for more on GUP.

The net result of this is for [handle_mm_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5129) (and for GUP,

[vma_permits_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1275) to check access via [arch_vma_access_permitted()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/mmu_context.h?h=v6.0#n207).

• [FAULT_FLAG_INSTRUCTION](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n872) – Indicates that the fault occurred when fetching

an instruction, i.e. executing code.

• [FAULT_FLAG_INTERRUPTIBLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n873) – Indicates that the faulting can

be interrupted by non-fatal signals, this is only relevant to

[userfaultfd](https://man7.org/linux/man-pages/man2/userfaultfd.2.html), which is out of scope for the book which checks for

 



 

this in [userfaultfd_get_blocking_state()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/userfaultfd.c?h=v6.0#n350) which is referenced by

[handle_userfault() .](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/userfaultfd.c?h=v6.0#n376)

• [FAULT_FLAG_UNSHARE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n874) – Indicates that the faulting anonymous page should

be ‘unshared’ if it is a Copy on Write (CoW) page and marked exclusive.

This is used by GUP in [faultin_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n960). Note that this flag is invalid if this is a write fault (indicated by FAULT_FLAG_WRITE) which would be copying the page anyway.

That this is required is ultimately determined by [gup_must_unshare()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2985)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2985) in-

voked by [follow_page_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n519)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n519) See section 8.1.2 for a detailed discussion of GUP.

[c89357e27f20: mm: support GUP-triggered unsharing of anonymous pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=c89357e27f20) in-troduces this feature, explicitly to avoid a situation where a forked folio might get CoW’d, meaning the userland mapping would point at a dif-ferent folio.

• [FAULT_FLAG_ORIG_PTE_VALID](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n875) – Indicates whether the orig_pte field in

[struct vm_fault](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n481) field contains a valid entry. If this flag is set then it does, otherwise it does not.

This is set or cleared in [handle_pte_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4860) depending on whether the

struct vm_fault-\>pmd field is empty (as determined by [pmd_none()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n788)[).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n788)

 

The default set of flags are set to [FAULT_FLAG_DEFAULT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n436) – this consists of the

[FAULT_FLAG_ALLOW_RETRY,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n866) [FAULT_FLAG_KILLABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n868) and [FAULT_FLAG_INTERRUPTIBLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n873) flags.

These are set on hardware page fault handling.

The generic page handling function [handle_mm_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5129) is invoked both by

the architecture-specific logic described in section 6.1, and by a number of

other parts of the kernel too – the out of scope AMD IOMMU driver, HMM,

KSM and ftrace components, but more pertinently – GUP via [faultin_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n960)

and [fixup_user_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1327) (see section 8.1.2 for a detailed description of GUP).

Now, let’s examine [handle_mm_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5129) as shown in Listing 6-14.

 

5123 */\**

5124 *\* By the time we get here, we already hold the mm semaphore* 5125 *\**

5126 *\* The mmap_lock may have been released depending on flags and our* 5127 *\* return value. See filemap_fault() and \_\_folio_lock_or_retry().* 5128 *\*/*

5129 **vm_fault_t handle_mm_fault**(**struct** vm_area_struct \*vma, **unsigned long** address, 5130 **unsigned int** flags, **struct** pt_regs \*regs) 5131 {

5132 **vm_fault_t** ret;

5133

5134 **\_\_set_current_state**(**TASK_RUNNING**); 5135

5136 **count_vm_event**(**PGFAULT**); 5137 **count_memcg_event_mm**(vma-\>vm_mm, **PGFAULT**); 5138

5139 */\* do counter updates before entering really critical section. \*/*

 



 

5140 **check_sync_rss_stat**(current); 5141

5142 **if** (!**arch_vma_access_permitted**(vma, flags & **FAULT_FLAG_WRITE**, 5143 flags & **FAULT_FLAG_INSTRUCTION**, 5144 flags & **FAULT_FLAG_REMOTE**)) 5145 **return VM_FAULT_SIGSEGV**; 5146

5147 */\**

5148 *\* Enable the memcg OOM handling for faults triggered in user* 5149 *\* space. Kernel faults are handled more gracefully.* 5150 *\*/*

5151 **if** (flags & **FAULT_FLAG_USER**) 5152 **mem_cgroup_enter_user_fault**(); 5153

5154 **if** (**unlikely**(**is_vm_hugetlb_page**(vma))) 5155 ret = **hugetlb_fault**(vma-\>vm_mm, vma, address, flags); 5156 **else**

5157 ret = **\_\_handle_mm_fault**(vma, address, flags); 5158

5159 **if** (flags & **FAULT_FLAG_USER**) { 5160 **mem_cgroup_exit_user_fault**(); 5161 */\**

5162 *\* The task may have entered a memcg OOM situation but* 5163 *\* if the allocation error was handled gracefully (no* 5164 *\* VM_FAULT_OOM), there is no need to kill anything.* 5165 *\* Just clean up the OOM state peacefully.* 5166 *\*/*

5167 **if** (**task_in_memcg_oom**(current) && !(ret & **VM_FAULT_OOM**)) 5168 **mem_cgroup_oom_synchronize**(**false**); 5169 }

5170

5171 **mm_account_fault**(regs, address, flags, ret); 5172

5173 **return** ret;

5174 }

 

*Listing 6-14:* mm/memory.c: [*handle_mm_fault()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5129)

 

This starts by setting the task to the [TASK_RUNNING](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n84) state, as the process is

considered to be running as it services the page fault, no matter its prior scheduler state.

There’s numerous statistical updates, out of scope for this section cgroup

handling (see the cgroup chapter for a detailed examination), leaving us with three core steps:

 

• [arch_vma_access_permitted()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/mmu_context.h?h=v6.0#n207) – We perform architecture-specific checks

to ensure the VMA is accessible parameterised by the fault being write, execute and/or remote.

 



 

• [\_\_handle_mm_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4967) – This is the core of the generic page fault handler,

which we will examine shortly.

• After the fault is complete, we perform accounting via [mm_account_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5077)

– this tracks major (the page was not present in RAM at all and likely had to be read from disk) and minor faults (the page was present in memory and at worst had to be allocated by the physical allocator) as well as tracking performance statistics.

 

Throughout the generic page fault handler, \_\_handle_mm_fault() threads

state through a [struct vm_fault](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n481) object as shown in Listing 6-15.

 

481 **struct** vm_fault {

482 **const struct** {

483 **struct** vm_area_struct \*vma; */\* Target VMA \*/* 484 **gfp_t** gfp_mask; */\* gfp mask to be used for*

*allocations \*/*

485 **pgoff_t** pgoff; */\* Logical page offset based*

*on vma \*/*

486 **unsigned long** address; */\* Faulting virtual address -*

*masked \*/*

487 **unsigned long** real_address; */\* Faulting virtual address -*

*unmasked \*/*

488 };

489 **enum** fault_flag flags; */\* FAULT_FLAG_xxx flags* 490 *\* XXX: should really be 'const' \*/*

491 **pmd_t** \*pmd; */\* Pointer to pmd entry matching* 492 *\* the 'address' \*/* 493 **pud_t** \*pud; */\* Pointer to pud entry matching* 494 *\* the 'address'* 495 *\*/* 496 **union** {

497 **pte_t** orig_pte; */\* Value of PTE at the time of fault*

*\*/*

498 **pmd_t** orig_pmd; */\* Value of PMD at the time of fault,* 499 *\* used by PMD fault only.* 500 *\*/* 501 };

502

503 **struct** page \*cow_page; */\* Page handler may use for COW fault*

*\*/*

504 **struct** page \*page; */\* -\>fault handlers should return a* 505 *\* page here, unless VM_FAULT_NOPAGE*

506 *\* is set (which is also implied by*

507 *\* VM_FAULT_ERROR).* 508 *\*/* 509 */\* These three entries are valid only while holding ptl lock \*/* 510 **pte_t** \*pte; */\* Pointer to pte entry matching* 511 *\* the 'address'. NULL if the page*

 



 

512 *\* table hasn't been allocated.* 513 *\*/* 514 **spinlock_t** \*ptl; */\* Page table lock.* 515 *\* Protects pte page table if 'pte'*

516 *\* is not NULL, otherwise pmd.* 517 *\*/* 518 **pgtable_t** prealloc_pte; */\* Pre-allocated pte page table.* 519 *\* vm_ops-\>map_pages() sets up a page*

520 *\* table from atomic context.* 521 *\* do_fault_around() pre-allocates*

522 *\* page table to avoid allocation from*

523 *\* atomic context.* 524 *\*/* 525 };

 

*Listing 6-15:* include/linux/mm.h: [*struct vm_fault*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n481)

 

This consists of a set of constant fields which define the page

fault and do not change throughout – the vma field containing the

[struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) that we are faulting pages for, gfp_mask spec-ifying the GFP mask to be applied to file-backed allocations made during the page fault (see the chapter on physical memory for a deep dive on GFP

flags) as obtained from [\_\_get_fault_gfp_mask()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2939).

This defaults to [GFP_KERNEL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n333)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n333) but will otherwise be set to the

[struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)-\>gfp_mask field bitwise combined with [\_\_GFP_FS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n215) and

[\_\_GFP_IO](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n214). Next, pgoff specifies the page offset of this faulting page within the

VMA, as determined by [linear_page_index()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n845) (see listing 7-23 and discussion around it for details as to how). address contains the page-aligned faulting address and real_address the unaligned one.

The rest of the fields can vary throughout the page fault – flags contains

the previously described fault flags, pmd and pud containing pointers to the PMD and PUD entries which may or may not need to be allocated for the mapping (see the virtual memory chapter for more on page table structure), and pte containing a reference to the PTE entry if the page table lock ptl has been acquired.

Finally, either orig_pte or orig_pmd contain the original PTE or PMD at the

time of fault if required, page contains the physical [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) allocated or assigned to the mapping, cow_page contains the newly CoW’d page if a Copy-on-Write operation has occurred and prealloc_pte contains a pre-allocated PTE page table if one has been allocated.

We examine the generic page fault mechanism from top-down starting in

Figure 6-3.

Note that:

A

• Denotes that A calls B but performs other actions after it returns.

B

 



 

• This diagram elides huge page, device mapping and other non-core

functionality, assumes x86-64 architecture and simplifies aspects of the logic for clarity.

 

[handle_mm_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5129)

 

[\_\_handle_mm_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4967)

Allocate/set P4D, PUD, PMD page tables

[handle_pte_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4860)

 

[pte_none()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n723)?

Update mapping No Yes Allocate mapping

 

[pte_present()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n734)? [vma_is_anonymous()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n629)[?](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n629)

Yes

No No Yes

Is NUMA page if

[pte_protnone()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n775) and [do_swap_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3718) [do_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4617) [do_anonymous_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4031)

[vma_is_accessible()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n659)

 

Yes No

Is NUMA? [do_numa_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4681) vm_ops-\>fault? [pte_none()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n723)[?](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n723)

No

(under lock)

No Yes VM_FAULT_NOPAGE

Yes

Take PTE lock FAULT_FLAG_WRITE?

VM_FAULT_SIGBUS

Yes

PTE changed?

No No VM_SHARED?

WP fault if [!pte_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n157) Yes No

and FAULT_FLAG_WRITE

Yes

or FAULT_FLAG_UNSHARE [do_read_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4509) [do_shared_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4574) [do_cow_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4535)

 

Unlock PTE

WP fault?

and return 0

[\_\_do_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4147)

Yes

(Folio lock acquired)

[do_wp_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3360) No

No

[finish_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4345) [do_set_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4290)

(Folio lock held)

Set dirty, accessed via Yes

FAULT_FLAG_WRITE?

[pte_mkdirty(),](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n328) [pte_mkyoung()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n333)

[set_pte_at()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1004)

 

*Figure 6-3: Overview of simplified non-huge generic page fault logic*

 

Examining the core function, [\_\_handle_mm_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4967), eliding huge page han-

dling which we address in the huge page chapter as shown in Listing 6-16.

 

4961 */\**

4962 *\* By the time we get here, we already hold the mm semaphore*

 



 

4963 *\**

4964 *\* The mmap_lock may have been released depending on flags and our* 4965 *\* return value. See filemap_fault() and \_\_folio_lock_or_retry().* 4966 *\*/*

4967 **static vm_fault_t \_\_handle_mm_fault**(**struct** vm_area_struct \*vma, 4968 **unsigned long** address, **unsigned int** flags) 4969 {

4970 **struct** vm_fault vmf = { 4971 .vma = vma, 4972 .address = address & **PAGE_MASK**, 4973 .real_address = address, 4974 .flags = flags, 4975 .pgoff = **linear_page_index**(vma, address), 4976 .gfp_mask = **\_\_get_fault_gfp_mask**(vma), 4977 };

4978 **struct** mm_struct \*mm = vma-\>vm_mm; 4979 **unsigned long** vm_flags = vma-\>vm_flags; 4980 **pgd_t** \*pgd;

4981 **p4d_t** \*p4d;

4982 **vm_fault_t** ret;

4983

4984 pgd = **pgd_offset**(mm, address); 4985 p4d = **p4d_alloc**(mm, pgd, address); 4986 **if** (!p4d)

4987 **return VM_FAULT_OOM**; 4988

4989 vmf.pud = **pud_alloc**(mm, p4d, address); 4990 **if** (!vmf.pud)

4991 **return VM_FAULT_OOM**;

. . .

5019 vmf.pmd = **pmd_alloc**(mm, vmf.pud, address); 5020 **if** (!vmf.pmd)

5021 **return VM_FAULT_OOM**;

. . .

5033 vmf.orig_pmd = \*vmf.pmd;

. . .

5059 **return handle_pte_fault**(&vmf); 5060 }

 

*Listing 6-16:* mm/memory.c: [*\_\_handle_mm_fault()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4967)

 

This sets up the [struct vm_fault](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n481) object as previously described, then walks

the page tables to the address, allocating new page tables if necessary via

[p4d_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2195), [pud_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2202) and [pmd_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2209)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2209) We examine page table structure and allocation in detail in the virtual memory chapter, however to be explicit about how we are allocating page tables here (if allocation is required) it is done so as follows (for x86-64):

 



 

**P4D** – Allocated via [p4d_alloc_one()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgalloc.h?h=v6.0#n150) with the [GFP_KERNEL_ACCOUNT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n334) GFP flags set

(see the physical memory chapter for a discussion of GFP flags) obtain-

ing a physical page via [get_zeroed_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5605). Sets the relevant PGD entry to point at it.

**PUD** – Allocated via [\_\_pud_alloc_one()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/pgalloc.h?h=v6.0#n150) with the [GFP_PGTABLE_USER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/pgalloc.h?h=v6.0#n8) GFP flags

set obtaining a physical page via [get_zeroed_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5605). Sets the relevant P4D entry to point at it.

**PMD** – Allocated via [pmd_alloc_one()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/pgalloc.h?h=v6.0#n119) with the [GFP_PGTABLE_USER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/pgalloc.h?h=v6.0#n8) GFP flags set

obtaining a physical page via [alloc_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mempolicy.c?h=v6.0#n2252). Sets the relevant PUD entry to point at it.

 

Note that in each potential page table allocation we explicitly check to

see whether the allocation succeeded, if not we return [VM_FAULT_OOM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n742) to indi-

cate that we have insufficient memory to fault this memory in.

The remainder of the fault handling logic is deferred to

[handle_pte_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4860) (eliding huge page logic) as shown in Listing 6-17.

 

4860 **static vm_fault_t handle_pte_fault**(**struct** vm_fault \*vmf) 4861 {

4862 **pte_t** entry;

4863

4864 **if** (**unlikely**(**pmd_none**(\*vmf-\>pmd))) {

. . .

4871 vmf-\>pte = **NULL**; 4872 vmf-\>flags &= ~**FAULT_FLAG_ORIG_PTE_VALID**; 4873 } **else** {

. . .

4894 vmf-\>pte = **pte_offset_map**(vmf-\>pmd, vmf-\>address); 4895 vmf-\>orig_pte = \*vmf-\>pte; 4896 vmf-\>flags \|= **FAULT_FLAG_ORIG_PTE_VALID**; 4897

4898 */\**

4899 *\* some architectures can have larger ptes than wordsize,* 4900 *\* e.g.ppc44x-defconfig has CONFIG_PTE_64BIT=y and* 4901 *\* CONFIG_32BIT=y, so READ_ONCE cannot guarantee atomic* 4902 *\* accesses. The code below just needs a consistent view* 4903 *\* for the ifs and we later double check anyway with the* 4904 *\* ptl lock held. So here a barrier will do.* 4905 *\*/*

4906 **barrier**(); 4907 **if** (**pte_none**(vmf-\>orig_pte)) { 4908 **pte_unmap**(vmf-\>pte); 4909 vmf-\>pte = **NULL**; 4910 }

4911 }

4912

4913 **if** (!vmf-\>pte) {

 



 

4914 **if** (**vma_is_anonymous**(vmf-\>vma)) 4915 **return do_anonymous_page**(vmf); 4916 **else**

4917 **return do_fault**(vmf); 4918 }

4919

4920 **if** (!**pte_present**(vmf-\>orig_pte)) 4921 **return do_swap_page**(vmf); 4922

4923 **if** (**pte_protnone**(vmf-\>orig_pte) && **vma_is_accessible**(vmf-\>vma)) 4924 **return do_numa_page**(vmf); 4925

4926 vmf-\>ptl = **pte_lockptr**(vmf-\>vma-\>vm_mm, vmf-\>pmd); 4927 **spin_lock**(vmf-\>ptl); 4928 entry = vmf-\>orig_pte; 4929 **if** (**unlikely**(!**pte_same**(\*vmf-\>pte, entry))) { 4930 **update_mmu_tlb**(vmf-\>vma, vmf-\>address, vmf-\>pte); 4931 **goto unlock**; 4932 }

4933 **if** (vmf-\>flags & (**FAULT_FLAG_WRITE**\|**FAULT_FLAG_UNSHARE**)) { 4934 **if** (!**pte_write**(entry)) 4935 **return do_wp_page**(vmf); 4936 **else if** (**likely**(vmf-\>flags & **FAULT_FLAG_WRITE**)) 4937 entry = **pte_mkdirty**(entry); 4938 }

4939 entry = **pte_mkyoung**(entry); 4940 **if** (**ptep_set_access_flags**(vmf-\>vma, vmf-\>address, vmf-\>pte, entry, 4941 vmf-\>flags & **FAULT_FLAG_WRITE**)) { 4942 **update_mmu_cache**(vmf-\>vma, vmf-\>address, vmf-\>pte); 4943 } **else** {

4944 */\* Skip spurious TLB flush for retried page fault \*/* 4945 **if** (vmf-\>flags & **FAULT_FLAG_TRIED**) 4946 **goto unlock**; 4947 */\**

4948 *\* This is needed only for protection faults but the arch code*

4949 *\* is not yet telling us if this is a protection fault or not.*

4950 *\* This still avoids useless tlb flushes for .text page faults*

4951 *\* with threads.* 4952 *\*/*

4953 **if** (vmf-\>flags & **FAULT_FLAG_WRITE**) 4954 **flush_tlb_fix_spurious_fault**(vmf-\>vma, vmf-\>address); 4955 }

4956 **unlock**:

4957 **pte_unmap_unlock**(vmf-\>pte, vmf-\>ptl); 4958 **return** 0;

4959 }

 

*Listing 6-17:* mm/memory.c: [*handle_pte_fault()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4860)

 



 

We start by checking whether the PMD is newly allocated (and thus

empty), if so, we mark the [struct vm_fault-\>pte](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n481) field to NULL and clear the

[FAULT_FLAG_ORIG_PTE_VALID](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n875) flag to indicate that no PTE is yet allocated.

Otherwise, the mapping is valid up to the PTE level, and we set the pte

field to the point at the PTE entry, via [pte_offset_map()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n103) (note that for a 64-bit

architecture no actual ‘mapping’ takes place), take a copy of it at this point in

time in orig_pte and set the FAULT_FLAG_ORIG_PTE_VALID flag.

If the PTE entry is empty (as determined via [pte_none()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n723), a PTE entry

might be empty but not be fully zeroed as a mask is applied), we set the PTE

field to NULL.

We are now at a significant point in the page fault handling – if there is

no PTE entry this means nothing is yet mapped (not even a Copy on Write

mapping) and the fault is about allocating memory or looking up a page

cache entry, as determined by [vma_is_anonymous()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n629) as shown in Listing 6-18.

 

629 **static inline bool vma_is_anonymous**(**struct** vm_area_struct \*vma) 630 {

631 **return** !vma-\>vm_ops; 632 }

 

*Listing 6-18:* include/linux/mm.h: [*vma_is_anonymous()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n629)

 

This is a key definition – if a [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) lacks customised

[struct vm_operations_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n539) vm_ops , then it is anonymous, i.e. only non-

anonymous (typically file-backed) memory mappings require customised

VMA operation handling.

If this function determines that the VMA is indeed anonymous, then the

fault is handled by [do_anonymous_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4031)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4031) if non-anonymous then it is handled

by [do_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4617). We examine both shortly

Otherwise we check to see whether the PTE entry is non-empty but not

present (i.e. lacking the [\_PAGE_BIT_PRESENT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n10) bit), if so then it is a swapped out

page, handled by [do_swap_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3718) which is discussed in the swap chapter.

Next we check to see if the page has been unmapped as part of NUMA

balancing, which is handled by [do_numa_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4681) (see the NUMA chapter for a

detailed explanation of this).

Finally, we reach the Copy on Write handler – [do_wp_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3360) – this handles

write-protect faults, including the vitally important case of handling a Copy

on Write (CoW) page faulting.

 

***6.2.1 Edge cases***

We have moved very quickly over the key logic here, but there are some edge

cases we must consider. After checking for the NUMA page case, we acquire

the PTE page table lock via [pte_lockptr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2246)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2246) then check to see if the fault has

been handled by a racing fault handler – if so we simply unlock the PTE and

exit [(](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n413)[update_mmu_tlb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n413) is not relevant for non-MIPS/xtensa architectures).

Next, we have logic dealing with the case where either a read fault or a

spurious write fault has occurred. In this case, if a write fault has arisen,

 



 

the entry we are building based on the original PTE is marked dirty via

[pte_mkdirty().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n328)

In any case, this entry is then marked accessed via [pte_mkyoung()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n333) and then

the flags are possibly changed via [ptep_set_access_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgtable.c?h=v6.0#n486) which indicates whether they have changed and, if dirty, sets them (it is not worth updating should other flags have changed).

We then reach specific handling for a spurious fault caused by an out-

dated TLB entry\* – on x86-64 this requires no additional handling and

[flush_tlb_fix_spurious_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1082) is therefore a no-op.

 

***6.2.2 Page flags***

We will examine each of these in turn. Note that in each case, the page table

flags are determined via [vm_get_page_prot()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgprot.c?h=v6.0#n35) (initially at least, possibly modi-fied if a non-anonymous VMA requires write notification, we will discuss this

in section 6.9) and stored in the VMA’s vm_page_prot field – see figure 3.13 for details as to how these are mapped but broadly these are determined by the presence or lack of VM_SHARED, VM_READ, VM_WRITE and VM_EXEC.

Importantly – All mappings which are not VM_SHARED are marked read-only

by default and are thus copy-on-write mappings. This applies both to anony-mous mappings and MAP_PRIVATE file-backed mappings.

 

**6.3 Anonymous page fault**

 

At this point, the page fault has occurred in a memory range described by an anonymous VMA, and that VMA has no Copy on Write mapping or any other established and requires a page to be allocated.

This is handled via [do_anonymous_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4031) (eliding out of scope huge page,

userfaultfd and cgroup logic) as shown in Listing 6-19.

 

4026 */\**

4027 *\* We enter with non-exclusive mmap_lock (to exclude vma changes,* 4028 *\* but allow concurrent faults), and pte mapped but not yet locked.* 4029 *\* We return with mmap_lock still held, but pte unmapped and unlocked.* 4030 *\*/*

4031 **static vm_fault_t do_anonymous_page**(**struct** vm_fault \*vmf) 4032 {

4033 **struct** vm_area_struct \*vma = vmf-\>vma; 4034 **struct** page \*page; 4035 **vm_fault_t** ret = 0; 4036 **pte_t** entry;

4037

4038 */\* File mapping without -\>vm_ops ? \*/* 4039 **if** (vma-\>vm_flags & **VM_SHARED**)

 

\*. The TLB is the Transaction Lookaside Buffer – a cache that maps virtual addresses to phys-ical ones with all relevant page table flags. This being outdated can cause faults to occur when the mapping in the page table is in fact valid.



 

4040 **return VM_FAULT_SIGBUS**; 4041

4042 */\**

4043 *\* Use pte_alloc() instead of pte_alloc_map(). We can't run* 4044 *\* pte_offset_map() on pmds where a huge pmd might be created* 4045 *\* from a different thread.* 4046 *\**

4047 *\* pte_alloc_map() is safe to use under mmap_write_lock(mm) or when*

4048 *\* parallel threads are excluded by other means.* 4049 *\**

4050 *\* Here we only have mmap_read_lock(mm).* 4051 *\*/*

4052 **if** (**pte_alloc**(vma-\>vm_mm, vmf-\>pmd)) 4053 **return VM_FAULT_OOM**;

. . .

4059 */\* Use the zero-page for reads \*/* 4060 **if** (!(vmf-\>flags & **FAULT_FLAG_WRITE**) && 4061 !**mm_forbids_zeropage**(vma-\>vm_mm)) { 4062 entry = **pte_mkspecial**(**pfn_pte**(**my_zero_pfn**(vmf-\>address), 4063 vma-\>vm_page_prot)); 4064 vmf-\>pte = **pte_offset_map_lock**(vma-\>vm_mm, vmf-\>pmd, 4065 vmf-\>address, &vmf-\>ptl); 4066 **if** (!**pte_none**(\*vmf-\>pte)) { 4067 **update_mmu_tlb**(vma, vmf-\>address, vmf-\>pte); 4068 **goto unlock**; 4069 }

4070 ret = **check_stable_address_space**(vma-\>vm_mm); 4071 **if** (ret)

4072 **goto unlock**;

. . .

4078 **goto setpte**; 4079 }

4080

4081 */\* Allocate our own private page. \*/* 4082 **if** (**unlikely**(**anon_vma_prepare**(vma))) 4083 **goto oom**; 4084 page = **alloc_zeroed_user_highpage_movable**(vma, vmf-\>address); 4085 **if** (!page)

4086 **goto oom**;

. . .

4092 */\**

4093 *\* The memory barrier inside \_\_SetPageUptodate makes sure that* 4094 *\* preceding stores to the page contents become visible before* 4095 *\* the set_pte_at() write.* 4096 *\*/*

4097 **\_\_SetPageUptodate**(page); 4098

 



 

4099 entry = **mk_pte**(page, vma-\>vm_page_prot); 4100 entry = **pte_sw_mkyoung**(entry); 4101 **if** (vma-\>vm_flags & **VM_WRITE**) 4102 entry = **pte_mkwrite**(**pte_mkdirty**(entry)); 4103

4104 vmf-\>pte = **pte_offset_map_lock**(vma-\>vm_mm, vmf-\>pmd, vmf-\>address, 4105 &vmf-\>ptl); 4106 **if** (!**pte_none**(\*vmf-\>pte)) { 4107 **update_mmu_cache**(vma, vmf-\>address, vmf-\>pte); 4108 **goto release**; 4109 }

4110

4111 ret = **check_stable_address_space**(vma-\>vm_mm); 4112 **if** (ret)

4113 **goto release**;

. . .

4122 **inc_mm_counter_fast**(vma-\>vm_mm, **MM_ANONPAGES**); 4123 **page_add_new_anon_rmap**(page, vma, vmf-\>address); 4124 **lru_cache_add_inactive_or_unevictable**(page, vma); 4125 **setpte**:

4126 **set_pte_at**(vma-\>vm_mm, vmf-\>address, vmf-\>pte, entry); 4127

4128 */\* No need to invalidate - it was non-present before \*/* 4129 **update_mmu_cache**(vma, vmf-\>address, vmf-\>pte); 4130 **unlock**:

4131 **pte_unmap_unlock**(vmf-\>pte, vmf-\>ptl); 4132 **return** ret;

4133 **release**:

4134 **put_page**(page);

4135 **goto unlock**;

4136 **oom_free_page**:

4137 **put_page**(page);

4138 **oom**:

4139 **return VM_FAULT_OOM**; 4140 }

 

*Listing 6-19:* mm/memory.c: [*do_anonymous_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4031)

 

We start by checking whether the [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) has the

[VM_SHARED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n269) flag set – if so, something has gone wrong, as this flag should not be set if the VMA is anonymous.

This might seem counter-intuitive, as memory can indeed be mapped

as both ‘anonymous’ and shared via MAP_SHARED and MAP_ANONYMOUS, however doing so does not result in an anonymous mapping, rather it memory-maps

 



 

an unlinked tmpfs clone of /dev/zero which is assigned its own inode. (see

## Chapter 5 for more on memory mapping)\*.

Next we go right ahead and allocate a new PTE (if necessary) via

[pte_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2316), assigning it to the PMD entry referenced in [struct vm_fault-\>pmd](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n481)

if so. If this fails, we report out of memory via [VM_FAULT_OOM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n742).

 

***6.3.1 Zero page***

A very useful concept within the page faulting mechanism is the idea of

the ‘zero page’. This is a page of pre-allocated and zeroed memory that is

mapped as a Copy on Write page upon read fault.

This way, no actual physical memory need be allocated for anonymous

read faults and the actual allocation can be deferred until it is written to.

This is determined by the fact that a write fault has not occurred

(i.e. [FAULT_FLAG_WRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n864) was not set), noting that we know this is not a

shared mapping as we have checked this above. It is also mediated by

[mm_forbids_zeropage() , ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n129)however this is only prohibited on the s390 architec-

ture, so not relevant to our focused upon architecture, x86-64.

The PFN of the zero page is determined via [my_zero_pfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n1221) which simply

references an external variable [zero_pfn](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n159) as shown in Listing 6-20.

 

1221 **static inline unsigned long my_zero_pfn**(**unsigned long** addr) 1222 {

1223 **extern unsigned long zero_pfn**; 1224 **return zero_pfn**;

1225 }

 

*Listing 6-20:* include/linux/pgtable.h: [*my_zero_pfn()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n1221)

 

this PFN is set up in [init_zero_pfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n167) which obtains the actual zero page

via [ZERO_PAGE()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n56)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n56) then uses [page_to_pfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/memory_model.h?h=v6.0#n52) to convert it to a PFN as shown in

Listing 6-21.

 

164 */\**

165 *\* CONFIG_MMU architectures set up ZERO_PAGE in their paging_init()* 166 *\*/*

167 **static int \_\_init init_zero_pfn**(**void**) 168 {

169 zero_pfn = **page_to_pfn**(**ZERO_PAGE**(0)); 170 **return** 0;

171 }

172 **early_initcall**(**init_zero_pfn**);

 

*Listing 6-21:* mm/memory.c: [*init_zero_pfn()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n167)

 

\*. [mmap_region()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1681) invokes the functions [shmem_zero_setup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/shmem.c?h=v6.0#n4226)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/shmem.c?h=v6.0#n4226) [shmem_kernel_file_setup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/shmem.c?h=v6.0#n4191) and

[\_\_shmem_file_setup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/shmem.c?h=v6.0#n4148) in turn to do so. Note that this memory is still swap-backed so will be added

to the anonymous LRU list

 



 

Using [early_initcall()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/init.h?h=v6.0#n269) to declare that it must be run during early initiali-

sation of the kernel.

The x86-64 architecture establishes [ZERO_PAGE()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n56) in reference to a page of

memory reserved in the static .bss (therefore zeroed) section of the kernel

image, [empty_zero_page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/head_64.S?h=v6.0#n670) as shown in Listing 6-22.

 

50 */\**

51 *\* ZERO_PAGE is a global shared page that is always zero: used* 52 *\* for zero-mapped memory areas etc..* 53 *\*/*

54 **extern unsigned long empty_zero_page**\[**PAGE_SIZE** / **sizeof**(**unsigned long**)\] 55 **\_\_visible**;

56 **\#define ZERO_PAGE**(vaddr) ((**void**)(vaddr),**virt_to_page**(**empty_zero_page**))

 

*Listing 6-22:* arch/x86/include/asm/pgtable.h: [*ZERO_PAGE()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n56)

 

This uses [virt_to_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page.h?h=v6.0#n69) to convert this kernel image address to a

[struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72).

We convert the PFN obtained from [my_zero_pfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n1221) to a PTE via [pfn_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n577)

and then marked ‘special’ via [pte_mkspecial()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n363), which simply sets the

[\_PAGE_SPECIAL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n55) to indicate that this is not an ordinary mapping.

This will be allocated on Copy on Write in [wp_page_copy()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3090) which uses

[alloc_zeroed_user_highpage_movable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page.h?h=v6.0#n37) to zero it (we touch on Copy on Write

pages below in section 6.9).

The PTE table’s lock is then acquired and PTE entry address retrieved

via [pte_offset_map_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2302) (note for 64-bit architectures no ‘mapping’ is re-quired).

The MMU TLB is updated for architectures that require this to be done

manually via update_mmu_tlb(), however this is not needed in the x86-64 archi-tecture.

Finally, we check to see whether the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) is stable via

[check_stable_address_space()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/oom.h?h=v6.0#n102) – an ‘unstable’ address space being one where the Out of Memory (OOM) killer has started to reap the address space. If so, a mapping can be pulled out from underneath us, so simply unlock and exit, otherwise we proceed to setting the PTE entry.

 

***6.3.2 anon_vma preparation***

We must set up the [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) object associated with the VMA

if one does not already exist via [anon_vma_prepare()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n154) – this checks the

[struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA)’s anon_vma field, if NULL then it allocates a new

object or merges with an existing adjacent one via [\_\_anon_vma_prepare()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n187)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n187) and

allocates and connects a [struct anon_vma_chain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82) object to bind the anon_vma to the VMA.

See Chapter 7 for a very in-depth explanation of the reverse mapping as

a whole.

Note that, while we are setting up an anon_vma object here, we have yet to

point a folio at it, this is performed later, as described below.

 



 

***6.3.3 Physical page allocation***

The physical page for the mapping is allocated via the physical allocation

macro [alloc_zeroed_user_highpage_movable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page.h?h=v6.0#n37) (examining the x86-64 specific

version) as shown in Listing 6-23.

 

37 **\#define alloc_zeroed_user_highpage_movable**(vma, vaddr) \\

38 **alloc_page_vma**(**GFP_HIGHUSER_MOVABLE** \| **\_\_GFP_ZERO**, vma, vaddr)

 

*Listing 6-23:* arch/x86/include/asm/page.h: [*alloc_zeroed_user_highpage_movable()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page.h?h=v6.0#n37)

 

This invokes [alloc_page_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n287) with [GFP_HIGHUSER_MOVABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n342) and [\_\_GFP_ZERO](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n249) set,

the former being a set of other physical allocation flags specifically intended

for userland memory allocation which, for a 64-bit system amount to:

 

• [\_\_GFP_ZERO](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n249) – Zero the memory after allocating it. This is critical for user

memory, as failing to do so could result in highly insecure information leakage, not to mention that userland entirely relies upon this.

• [\_\_GFP_MOVABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n75) – A key defining characteristic of userland memory is that

it can be migrated, i.e. moved around as necessary. Userland does not care which physical address a virtual mapping points at, so we can move as is convenient. See the chapter on migration/compaction for more on when and how we do this.

The net result is that the memory is assigned the migrate type

[MIGRATE_MOVABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n44), a heuristic to try to prevent movable and unmovable

memory residing in the same page block. See section 2.6.2 for more on this.

• [\_\_GFP_SKIP_KASAN_POISON](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n253), [\_\_GFP_SKIP_KASAN_UNPOISON](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n252) – Out of scope hints for

the kernel’s [KASAN](https://kernel.org/doc/html/v6.0/dev-tools/kasan.html) functionality.

• [\_\_GFP_DIRECT_RECLAIM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n216) – Indicates that the memory can be directly re-

claimed if memory pressure is so high that free pages in the zone from which it is being allocated falls below the minimum permissible level.

See section 2.4 for more on this.

• [\_\_GFP_KSWAPD_RECLAIM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n217) – Indicates that indirect reclaim, performed by the

kswapd kernel thread, will be triggered if memory pressure causes the zone from which this memory is allocated to fall blow its low watermark.

Again, see section 2.4 for more on this.

• [\_\_GFP_IO](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n214) – Indicates that I/O can be performed as a part of this alloca-

tion.

• [\_\_GFP_FS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n215) – Indicates that file systems can be utilised as part of the alloca-

tion.

• [\_\_GFP_HARDWALL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n107) – Indicates that, when used within a cgroup, the mem-

ory’s cpuset.mems setting should honoured. See the cgroup chapter for more details on this.

 

See section 2.6 for an in-depth explanation of GFP flags and chapter 2 in

general for a broad examination of physical memory allocation as a whole.

Examining [alloc_page_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n287) itself as shown in Listing 6-24.

 



 

287 **static inline struct** page \***alloc_page_vma**(**gfp_t** gfp, 288 **struct** vm_area_struct \*vma, **unsigned long** addr) 289 {

290 **struct** folio \*folio = **vma_alloc_folio**(gfp, 0, vma, addr, **false**); 291

292 **return** &folio-\>page; 293 }

 

*Listing 6-24:* include/linux/gfp.h: [*alloc_page_vma()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n287)

 

This invokes [vma_alloc_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mempolicy.c?h=v6.0#n2151) which takes into account the NUMA mem-

ory policy specified by the user for this VMA and allocates accordingly (see the NUMA chapter for a detailed analysis of this), before ultimately perform-

ing the allocation via [\_\_folio_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5577) which in turn invokes the core physical

memory allocation function [\_\_alloc_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5513)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5513)

After the memory is allocated we set the folio flag [PG_uptodate](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n103) via

\_\_SetPageUptodate(), a flag indicating whether memory is sychronised with disk. For anonymous memory, this is trivially true.

 

***6.3.4 Setting up the PTE entry***

We then move on to setting up the PTE entry, starting by setting the

flags inferred from the [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA)’s vm_flags stored in its

vm_page_prot field via [mk_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n814), noting that these mappings always map Copy on Write (i.e. readonly) by default unless the mapping is shared.

We invoke [pte_sw_mkyoung()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n467), which sets the accessed page table flag for

architectures which do not set this in hardware. However, sensible modern architectures including the focused upon x86-64 do so, so in this case this does nothing.

Next, we adjust the PTE flags if this is a write fault, as in this case we

actually do not wish this page to be Copy on Write, since we have just allo-cated a page for it (a read-only fault should hit the zero page logic described

above), so mark the page table mapping both writable, dirty and [soft-dirty](https://kernel.org/doc/html/v6.0/admin-guide/mm/soft-dirty.html)

(the page has indeed been ‘touched’ by a write fault) via [pte_mkwrite()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n338) and

[pte_mkdirty().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n328)

A pointer to the PTE entry itself is then placed in the [struct vm_fault](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n481)-\>pte

field, with its lock acquired and placed in the ptl field, using the pmd field to obtain the address of the PTE page which we may have allocated previously.

Because we only just acquired a lock for this PTE, we have to check

for race conditions, and thus now check to see if we were beaten to it via

[pte_none(). ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n723)If so we simply release the physical page and return.

Otherwise, we check whether we are in a ‘stable’ address space (i.e. one

not targeted by the OOM killer) as we did in the zero page code path via

[check_stable_address_space()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/oom.h?h=v6.0#n102). If not we release the page and abort the opera-tion.

We then increment the anonymous page statistics via

[inc_mm_counter_fast() .](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n203)

 



 

***6.3.5 Adding to the reverse mapping and LRU and setting the PTE***

As this is user memory, we have a couple of additional tasks to perform –

Firstly, we must point the folio at the [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) object which represents

this via [page_add_new_anon_rmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1262) (see listing 7-20). See section 7.0.12 for a

detailed examination of this.

Secondly, we must add the folio to the ‘Least Recently Used’ LRU

caching mechanism via [lru_cache_add_inactive_or_unevictable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n503) – this is a

means by which the kernel keeps a track of how recently folios have been ac-

cessed when making decisions about which folios to swap out or evict from

the page cache. See section 11.2 for a detailed analysis of this.

We are now ready to actually set the PTE entry via [set_pte_at()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1004) (which

calls [set_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n68) in turn).

Afterwards, we unlock the PTE lock and return – the page has been

faulted in, with all page tables correctly set up and the memory added to

both the reverse mapping and LRU mechanisms as appropriate.

 

**6.4 Non-anonymous page fault**

 

Non-anonymous page faults are handled by [do_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4617)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4617) which determines

which handler to invoke as shown in Listing 6-25.

 

4609 */\**

4610 *\* We enter with non-exclusive mmap_lock (to exclude vma changes,* 4611 *\* but allow concurrent faults).* 4612 *\* The mmap_lock may have been released depending on flags and our* 4613 *\* return value. See filemap_fault() and \_\_folio_lock_or_retry().* 4614 *\* If mmap_lock is released, vma may become invalid (for example* 4615 *\* by other thread calling munmap()).* 4616 *\*/*

4617 **static vm_fault_t do_fault**(**struct** vm_fault \*vmf) 4618 {

4619 **struct** vm_area_struct \*vma = vmf-\>vma; 4620 **struct** mm_struct \*vm_mm = vma-\>vm_mm; 4621 **vm_fault_t** ret;

4622

4623 */\**

4624 *\* The VMA was not fully populated on mmap() or missing VM_DONTEXPAND*

4625 *\*/*

4626 **if** (!vma-\>vm_ops-\>fault) { 4627 */\**

4628 *\* If we find a migration pmd entry or a none pmd entry, which*

4629 *\* should never happen, return SIGBUS* 4630 *\*/*

4631 **if** (**unlikely**(!**pmd_present**(\*vmf-\>pmd))) 4632 ret = **VM_FAULT_SIGBUS**; 4633 **else** {

4634 vmf-\>pte = **pte_offset_map_lock**(vmf-\>vma-\>vm_mm,

 



 

4635 vmf-\>pmd, 4636 vmf-\>address, 4637 &vmf-\>ptl); 4638 */\** 4639 *\* Make sure this is not a temporary clearing of pte*

4640 *\* by holding ptl and checking again. A R/M/W update*

4641 *\* of pte involves: take ptl, clearing the pte so that*

4642 *\* we don't have concurrent modification by hardware*

4643 *\* followed by an update.* 4644 *\*/* 4645 **if** (**unlikely**(**pte_none**(\*vmf-\>pte))) 4646 ret = **VM_FAULT_SIGBUS**; 4647 **else** 4648 ret = **VM_FAULT_NOPAGE**; 4649

4650 **pte_unmap_unlock**(vmf-\>pte, vmf-\>ptl); 4651 }

4652 } **else if** (!(vmf-\>flags & **FAULT_FLAG_WRITE**)) 4653 ret = **do_read_fault**(vmf); 4654 **else if** (!(vma-\>vm_flags & **VM_SHARED**)) 4655 ret = **do_cow_fault**(vmf); 4656 **else**

4657 ret = **do_shared_fault**(vmf); 4658

4659 */\* preallocated pagetable is unused: free it \*/* 4660 **if** (vmf-\>prealloc_pte) { 4661 **pte_free**(vm_mm, vmf-\>prealloc_pte); 4662 vmf-\>prealloc_pte = **NULL**; 4663 }

4664 **return** ret;

4665 }

 

*Listing 6-25:* mm/memory.c: [*do_fault()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4617)

 

This starts with specific handling for an edge case – non-anonymous

mappings are assumed to provide their own fault-handling logic (which

is often simply delegated to [filemap_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3084)) within the fault field of the

[struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA)’s [struct vm_operations_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n539) vm_ops field.

If this is not present, something has gone wrong – either we have en-

countered something broken, in which case we return [VM_FAULT_SIGBUS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n743) to indi-cate that the SIGBUS signal must be sent to the faulting process, or we have en-

countered a race condition, in which case we must return [VM_FAULT_NOPAGE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n749) to indicate that we do not know which folio this fault belongs (i.e. it has been faulted in elsewhere).

If the PMD is not present, then things are certainly broken and thus in

this case we unconditionally return VM_FAULT_SIGBUS, otherwise we perform

the same [pte_none()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n723) check we performed in [handle_pte_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4860), only this time

 



 

having acquired the PTE lock – either returning VM_FAULT_SIGBUS if the entry

is still empty or VM_FAULT_NOPAGE otherwise.

This allows us to account for the situation where

the PTE has been read by another fault, cleared before

then being being written to as described in the commit

[ff09d7ec9786: mm/memory.c: recheck page table entry with page table lock held](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=ff09d7ec9786).

What remains are the various types of faults which are delegated:

 

**Read fault** – [do_read_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4509) is invoked when a read fault arises (i.e.

[FAULT_FLAG_WRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n864) was not set).

MAP_PRIVATE file-backed mapping write fault – [do_cow_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4535) is invoked when

a file-backed MAP_PRIVATE mapping experiences a page write fault (see

## Chapter 5 for more on memory mapping in general). In this case, we must treat this as a Copy on Write fault, despite no existing read-only mapping existing, since the semantics of this type of mapping are that the page cache entry must be CoW’d on write.

**Shared write fault** – [do_shared_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4574) is invoked when a write fault has oc-

curred for a shared mapping (i.e. within a VMA which has the [VM_SHARED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n269) flag set).

 

After invoking the handlers to service the fault, the

[struct vm_fault](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n481)-\>prealloc_pte field is checked to see if any pre-allocated

PTE page table allocation remains – if so this is freed before returning the

result obtained from the appropriate page fault handler.

Each of these handlers invokes [\_\_do_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4147) to fault-in the memory via the

the [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA)’s [struct vm_operations_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n539) vm_ops-\>fault

handler, which returns a locked folio. This populates the appropriate fields

in the [struct vm_fault](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n481) object, which is then actually applied via [finish_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4345)

and the PTE installed (and added to the reverse mapping and LRU lists) via

[do_set_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4290).

 

***6.4.1 Folio locks***

When performing these operations, we enter states where a folio might be

updated and thus must be considered unavailable for any further operations

until the lock is released – this is so the folio remains stable throughout the

operation, i.e. is not modified in a way that races with the ongoing opera-

tion such as removing the mapping or similar changes.

In each of the below operations, the shared \_\_do_fault() handler acquires

the folio lock, and the shared logic for completing the fault in [finish_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4345)

assumes this lock is held throughout.

These locks are acquired via [folio_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n935) or the [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) equivalent

[lock_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n953) and unlocked via [folio_unlock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1526) or [unlock_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n18).

Page fault handlers may indicate that they have acquired this lock via

[VM_FAULT_LOCKED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n750), and on fault or page_mkwrite are expected to do so, with spe-

cial handling for cases where this is not so.

It’s important to note that these functions are not simply setting or clear-

ing the folio [PG_locked](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n101) flag but sleep and wait on the flag to be cleared.

 



 

There is a lot of intricate machinery around these locks and their interac-

tion with page cache operations like writeback, however we defer the discus-sion of this to the page cache chapter where we can examine it in detail.

We will examine the aforementioned \_\_do_fault() and finish_fault()

shared logic in section 6.8, meanwhile let’s examine each of these handlers individually:

 

**6.5 Non-anonymous read page fault**

Non-anonymous read faults are handled by [do_read_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4509) as shown in List-

ing 6-26.

 

4509 **static vm_fault_t do_read_fault**(**struct** vm_fault \*vmf) 4510 {

4511 **vm_fault_t** ret = 0; 4512

4513 */\**

4514 *\* Let's call -\>map_pages() first and use -\>fault() as fallback* 4515 *\* if page by the offset is not ready to be mapped (cold cache or* 4516 *\* something).*

4517 *\*/*

4518 **if** (**should_fault_around**(vmf)) { 4519 ret = **do_fault_around**(vmf); 4520 **if** (ret)

4521 **return** ret; 4522 }

4523

4524 ret = **\_\_do_fault**(vmf); 4525 **if** (**unlikely**(ret & (**VM_FAULT_ERROR** \| **VM_FAULT_NOPAGE** \| **VM_FAULT_RETRY**)

))

4526 **return** ret; 4527

4528 ret \|= **finish_fault**(vmf); 4529 **unlock_page**(vmf-\>page); 4530 **if** (**unlikely**(ret & (**VM_FAULT_ERROR** \| **VM_FAULT_NOPAGE** \| **VM_FAULT_RETRY**)

))

4531 **put_page**(vmf-\>page); 4532 **return** ret;

4533 }

 

*Listing 6-26:* mm/memory.c: [*do_read_fault()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4509)

This for the most part simply invokes [\_\_do_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4147) to populate the

[struct vm_fault](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n481) object and [finish_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4345) to apply the faulted in memory, tak-ing care to handle error states.

The key difference however is in the fault-around logic – when reading in

from a file, it is useful to try to map easily obtained pages if we can on the usually reasonable assumption that subsequent pages are likely to be read next (i.e. only performing minor faults).

 



 

A typical example of this would be where a number of folios of a file ex-

ist in the page cache but are not yet mapped in the faulting VMA. In this

case it is relatively cheap to simply map these, but if they had to be retrieved

from disk this would not be the case.

This is distinct from read-ahead, where folios are loaded from disk

and into the page cache in anticipation of further reads, which is an ex-

pensive operation. The fault-around is specified by the filesystem via the

[struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA)’s [struct vm_operations_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n539) vm_ops-\>map_pages

handler which is often delegated to the generic [filemap_map_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3322).

Whether fault-around can occur is determined via [should_fault_around()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4497)

and mediated by the static variable [fault_around_bytes](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4407), which

defaults to 64 KiB but is configurable via the debugfs tunable

/sys/kernel/debug/fault_around_bytes.

This value must be equal to a power-of-2, i.e. a page order and if spec-

ified otherwise is rounded down to the nearest such value (this is done in

[fault_around_bytes_set() ). ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4421)It must also be no larger than the area which can

be mapped by a PTE, i.e. [PTRS_PER_PTE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n96) pages, as it does not cross page bound-

aries.

Important: This means that the range that is faulted ‘around’ truly is

around the address. For instance, if 16 pages (the default for a 4 KiB page

size) are faulted in, it will be the 16 pages containing the faulting address, not

those that come immediately afterwards.

E.g. if the faulting address was 0xe000, then addresses in the range 0 to

0xf000 inclusive would be faulted in, not the 16 pages at or beyond 0xe000

(reading ahead is what readahead does, and is distinct, discussed in section

9.7 in the page cache chapter).

Examining [should_fault_around()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4497) as shown in Listing 6-27.

 

4496 */\* Return true if we should do read fault-around, false otherwise \*/* 4497 **static inline bool should_fault_around**(**struct** vm_fault \*vmf) 4498 {

4499 */\* No -\>map_pages? No way to fault around... \*/* 4500 **if** (!vmf-\>vma-\>vm_ops-\>map_pages) 4501 **return false**; 4502

4503 **if** (**uffd_disable_fault_around**(vmf-\>vma)) 4504 **return false**; 4505

4506 **return fault_around_bytes** \>\> **PAGE_SHIFT** \> 1; 4507 }

 

*Listing 6-27:* mm/memory.c: [*should_fault_around()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4497)

 

Other than a userfaultfd-specific check (out of scope for the book),

this simply checks to see that the map_pages handler is available and that

fault_around_bytes specifies at least 1 page.

The actual fault-around is performed in [do_fault_around()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4463). If it returns

anything other than 0 then this indicates that either an error has occurred or

 



 

the read faulting address has already been faulted in (which will be reported

as [VM_FAULT_NOPAGE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n749)), and we should not proceed with the fault.

Examining this function as shown in Listing 6-28.

 

4443 */\**

4444 *\* do_fault_around() tries to map few pages around the fault address. The hope*

4445 *\* is that the pages will be needed soon and this will lower the number of*

4446 *\* faults to handle.*

4447 *\**

4448 *\* It uses vm_ops-\>map_pages() to map the pages, which skips the page if it's*

4449 *\* not ready to be mapped: not up-to-date, locked, etc.* 4450 *\**

4451 *\* This function doesn't cross the VMA boundaries, in order to call map_pages*

*()*

4452 *\* only once.*

4453 *\**

4454 *\* fault_around_bytes defines how many bytes we'll try to map.* 4455 *\* do_fault_around() expects it to be set to a power of two less than or equal*

4456 *\* to PTRS_PER_PTE.*

4457 *\**

4458 *\* The virtual address of the area that we map is naturally aligned to* 4459 *\* fault_around_bytes rounded down to the machine page size* 4460 *\* (and therefore to page order). This way it's easier to guarantee* 4461 *\* that we don't cross page table boundaries.* 4462 *\*/*

4463 **static vm_fault_t do_fault_around**(**struct** vm_fault \*vmf) 4464 {

4465 **unsigned long** address = vmf-\>address, nr_pages, mask; 4466 **pgoff_t** start_pgoff = vmf-\>pgoff; 4467 **pgoff_t** end_pgoff; 4468 **int** off;

4469

4470 nr_pages = **READ_ONCE**(**fault_around_bytes**) \>\> **PAGE_SHIFT**; 4471 mask = ~(nr_pages \* **PAGE_SIZE**- 1) & **PAGE_MASK**; 4472

4473 address = **max**(address & mask, vmf-\>vma-\>vm_start); 4474 off = ((vmf-\>address - address) \>\> **PAGE_SHIFT**) & (**PTRS_PER_PTE**- 1); 4475 start_pgoff -= off; 4476

4477 */\**

4478 *\* end_pgoff is either the end of the page table, the end of* 4479 *\* the vma or nr_pages from start_pgoff, depending what is nearest.*

4480 *\*/*

4481 end_pgoff = start_pgoff -4482 ((address \>\> **PAGE_SHIFT**) & (**PTRS_PER_PTE**- 1)) + 4483 **PTRS_PER_PTE**- 1; 4484 end_pgoff = **min3**(end_pgoff, **vma_pages**(vmf-\>vma) + vmf-\>vma-\>vm_pgoff -

1,

 



 

4485 start_pgoff + nr_pages - 1); 4486

4487 **if** (**pmd_none**(\*vmf-\>pmd)) { 4488 vmf-\>prealloc_pte = **pte_alloc_one**(vmf-\>vma-\>vm_mm); 4489 **if** (!vmf-\>prealloc_pte) 4490 **return VM_FAULT_OOM**; 4491 }

4492

4493 **return** vmf-\>vma-\>vm_ops-\>**map_pages**(vmf, start_pgoff, end_pgoff); 4494 }

 

*Listing 6-28:* mm/memory.c: [*do_fault_around()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4463)

This delegates the operation to the [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA)’s ob-

ject [struct vm_operations_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n539) vm_ops-\>map_pages handler is passed the

[struct vm_fault](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n481) object along with a range of offsets to map in start_pgoff and

end_pgoff. Prior to calling this, if the PMD entry is not set, we ‘preallocate’ a

new PTE table and place it in the prealloc_pte field for the handler to use.

We perform this pre-allocation to avoid issues with

any invocation of the allocator that may occur from

atomic context within the map_pages handler (introduced in

[7267ec008b5c: mm: postpone page table allocation until we have page to map](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=7267ec008b5c) and

refined in [f9ce0be71d1f: mm: Cleanup faultaround and finish_fault() codepaths](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=f9ce0be71d1f)[).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=f9ce0be71d1f)

The remaining code calculates what start_pgoff and end_pgoff should be.

This is quite tricky so we’ll go over it carefully:

 

• We determine the number of pages specified by fault_around_bytes and

store this in nr_pages.

• We obtain a mask at the granularity of the fault-around block size, i.e. for

64 KiB this will mask out blocks of memory in 64 KiB chunks\*.

• We want to keep the range over which we span aligned to the fault-

around value, which is guaranteed to be a power-of-2, after which we fault in only this man pages – this means that we are guaranteed not to

cross a page table boundary †. Why? Virtual addresses are, by the structure of page tables, aligned to the ad-dress range they span, e.g. you cannot possibly cross a PTE page table boundary unless a virtual address passes through a value aligned to 2 MiB (the range a PTE table can map).

Since we explicitly restrict fault_around_bytes to being at last equal to the size of a base page, less than 2 MiB and a power-of-2 which we align the start and end range of the faulted in addresses to, it’s simply not pos-

 

\*. This uses a very common bit-wise trick – if you subtract 1 from a power of 2 you obtain a 0b01000 mask for its lower bits (e.g. yields 0b00111 ) and then if you complement that you mask

out the higher bits, including that bit value (e.g. 0b01000 yields 0b111...11000).

†. Page table boundaries are point at which an increment in a virtual address causes the map-

ping to be specified by at least one different page table, e.g. moving from one PTE to another

or one PMD or another and so on (if the page table entries mapping an address sit in the last

entry of more than one page tables, then it’s possible for many to be crossed at once).

 



 

sible to step outside of the bounds of the page table (note that we also clamp this range to that of the containing VMA).

For example, a range starting at 0x200000 of 0x200000 bytes will terminate at 0x3fffff, not crossing the boundary.

• Returning to the code, we apply the previously obtained mask to our ad-

dress, which aligns it to fault_around_bytes. We must take into account this might result in a value less than the starting address, e.g. consider a vm_start of 0x51000 and an address of 0x5f000, if we were to align to 0x10000 this would result in an address of 0x50000, which precedes the VMA.

We resolve this issue by ‘clamping’ to the start of the VMA should it ex-ceed our aligned value.

• Earlier, we set start_pgoff to the [struct vm_fault-\>pgoff](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n481) field (set by

[linear_page_index()) ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n845)which will have been offset by the address’s page offset into the VMA. We must take into account that the start address might now be offset from this, so subtract the appropriate value from start_pgoff.

• Next we must obtain the inclusive end page offset to map, end_pgoff. The

fact that we must ‘clamp’ the start of the range to fault around to the start of the VMA presents a problem – this value might not be aligned to nr_pages, so if we simply add nr_pages we might pass a page boundary regardless. We might also exceed the end of the VMA vm_end. To resolve this issue we must choose the minimum of three values – the end of the PTE, vm_end and simply offsetting by nr_pages - 1. We must keep in mind that our start_pgoff value not only encodes the offset of the address within the VMA but also but also the offset of the VMA itself in the underlying page cache object (typically a file), thus this necessitates something of a dance here.

To obtain the offset which will be mapped to the final PTE entry, we must subtract from start_pgoff the portion of the target start address which is not aligned with the PTE, i.e. by masking against the lower bits

of [PTRS_PER_PTE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n96)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n96) then offset by the maximum index into the page table (since end_pgoff is an inclusive bound), i.e. adding PTRS_PER_PTE - 1. We place this in end_pgoff. The other two values are obtained simply – we can figure out vm_end rela-tive to the page offset by adding the number of pages spanned by it (via

[vma_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2782)) to the VMA’s vm_pgoff and subtracting 1. Obtaining the end of the fault-around block is very simply – we just off-set start_pgoff by nr_pages - 1.

• We now possess both start_pgoff and end_pgoff and are ready to invoke

the map_pages handler.

 

We discuss the specifies of the default map_pages handler in the page

cache chapter in section 9.8.

 



 

**6.6 Non-anonymous MAP_PRIVATE Copy on Write page**

**fault**

 

When a mapping is obtained via [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html)’d for a file but with MAP_PRIVATE spec-

ified, this necessitates special handling – if a read-fault occurs, then this will

result in a Copy on Write mapping that, other than being mapped read-only

is equivalent in hardware to that of a shared mapping.

However, once a write fault occurs, the folio is copied into an anonymous

page. This therefore creates the edge case of a non-anonymous mapping

that can experience a Copy-on-Write fault.

Importantly, if the file mapping is truncated such that a mapped page

is no longer valid (e.g. a file is opened with the O_TRUNC flag for overwrite

or [ftruncate()](https://man7.org/linux/man-pages/man2/ftruncate.2.html) is invoked with a size at or below that of the mapped page),

then the mapping is invalidated, losing all of the data written into any such

CoW’d anonymous pages.

This is what makes this type of mapping hazardous – the underlying file

must remain intact for them to remain valid. This is true of shared map-

pings too, except the data written will be written back to the underlying file

so is not lost.

This edge case is handled via [do_cow_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4535) (eliding out of scope cgroup

handling) as shown in Listing 6-29.

 

4535 **static vm_fault_t do_cow_fault**(**struct** vm_fault \*vmf) 4536 {

4537 **struct** vm_area_struct \*vma = vmf-\>vma; 4538 **vm_fault_t** ret;

4539

4540 **if** (**unlikely**(**anon_vma_prepare**(vma))) 4541 **return VM_FAULT_OOM**; 4542

4543 vmf-\>cow_page = **alloc_page_vma**(**GFP_HIGHUSER_MOVABLE**, vma, vmf-\>address

);

4544 **if** (!vmf-\>cow_page) 4545 **return VM_FAULT_OOM**;

. . .

4554 ret = **\_\_do_fault**(vmf); 4555 **if** (**unlikely**(ret & (**VM_FAULT_ERROR** \| **VM_FAULT_NOPAGE** \| **VM_FAULT_RETRY**)

))

4556 **goto uncharge_out**; 4557 **if** (ret & **VM_FAULT_DONE_COW**) 4558 **return** ret; 4559

4560 **copy_user_highpage**(vmf-\>cow_page, vmf-\>page, vmf-\>address, vma); 4561 **\_\_SetPageUptodate**(vmf-\>cow_page); 4562

4563 ret \|= **finish_fault**(vmf); 4564 **unlock_page**(vmf-\>page); 4565 **put_page**(vmf-\>page);

 



 

4566 **if** (**unlikely**(ret & (**VM_FAULT_ERROR** \| **VM_FAULT_NOPAGE** \| **VM_FAULT_RETRY**)

))

4567 **goto uncharge_out**; 4568 **return** ret;

4569 **uncharge_out**:

4570 **put_page**(vmf-\>cow_page); 4571 **return** ret;

4572 }

 

*Listing 6-29:* mm/memory.c: [*do_cow_fault()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4535)

 

This somewhat mirrors [do_anonymous_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4031) (see listing 6-

19), except that rather than allocating a page to copy into via

[alloc_zeroed_user_highpage_movable(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page.h?h=v6.0#n37)it allocates using [alloc_page_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n287) di-

rectly specifying [GFP_HIGHUSER_MOVABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n342)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n342) Since we’ll be directly copying into this page, there is no need to zero it.

Additionally this allocated page is placed into the

[struct vm_fault](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n481)-\>cow_page field rather than the page field, and if no such

allocation is possible, returns [VM_FAULT_OOM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n742) to indicate an out of memory condition.

Prior to this, we set up the reverse mapping via [anon_vma_prepare()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n154) (again,

see Chapter 7 for a deeper explanation) as this mapping has now become anonymous.

However, this differs from an anonymous page fault in that we must in-

voke [\_\_do_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4147) to populate the [struct vm_fault-\>page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n481) field in order for us to copy it to the cow_page.

If an error arises, we drop our reference to the cow_page and exit. Other-

wise, if [VM_FAULT_DONE_COW](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n753) is returned, this indicates the Copy on Write was performed for us and we can simply return.

If neither are the case, we will now have a pointer to the page cache en-

try folio in page and a pointer to the CoW anonymous page folio is cow_page.

We must then perform the copy via [copy_user_highpage()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/highmem.h?h=v6.0#n306) which, on a 64-bit

system, is equivalent to invoking [copy_user_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page.h?h=v6.0#n31)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page.h?h=v6.0#n31) obtaining kernel virtual

addresses for the specified folios via [page_to_virt()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n114)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n114) which amounts to a

[memcpy()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/lib/memcpy_64.S?h=v6.0#n46).

We assign the folio flag [PG_uptodate](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n103) to cow_page as with an anonymous

page fault, before deferring the completion of the fault (including establish-

ing the PTE entry) to [finish_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4345)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4345)

The page at this stage will be locked (having been so by \_\_do_fault()), so

we unlock it, then remove our reference to it via [put_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1167). Finally, we check against error conditions or ones which indicate that cow_page was not used (in which case dropping a reference from it) before returning.

 

**6.7 Non-anonymous shared write fault**

 

When a non-anonymous page faults which is mapped shared (i.e. [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html)’d us-

ing MAP_SHARED), translating into the VMA possessing a [VM_SHARED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n269) flag, having

 



 

not been read faulted before, it undergoes a shared write fault, handled by

[do_shared_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4574) as shown in Listing 6-30.

 

4574 **static vm_fault_t do_shared_fault**(**struct** vm_fault \*vmf) 4575 {

4576 **struct** vm_area_struct \*vma = vmf-\>vma; 4577 **vm_fault_t** ret, tmp; 4578

4579 ret = **\_\_do_fault**(vmf); 4580 **if** (**unlikely**(ret & (**VM_FAULT_ERROR** \| **VM_FAULT_NOPAGE** \| **VM_FAULT_RETRY**)

))

4581 **return** ret; 4582

4583 */\**

4584 *\* Check if the backing address space wants to know that the page is*

4585 *\* about to become writable* 4586 *\*/*

4587 **if** (vma-\>vm_ops-\>page_mkwrite) { 4588 **unlock_page**(vmf-\>page); 4589 tmp = **do_page_mkwrite**(vmf); 4590 **if** (**unlikely**(!tmp \|\| 4591 (tmp & (**VM_FAULT_ERROR** \| **VM_FAULT_NOPAGE**)))) { 4592 **put_page**(vmf-\>page); 4593 **return** tmp; 4594 }

4595 }

4596

4597 ret \|= **finish_fault**(vmf); 4598 **if** (**unlikely**(ret & (**VM_FAULT_ERROR** \| **VM_FAULT_NOPAGE** \| 4599 **VM_FAULT_RETRY**))) { 4600 **unlock_page**(vmf-\>page); 4601 **put_page**(vmf-\>page); 4602 **return** ret; 4603 }

4604

4605 ret \|= **fault_dirty_shared_page**(vmf); 4606 **return** ret;

4607 }

 

*Listing 6-30:* mm/memory.c: [*do_shared_fault()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4574)

 

As with the other non-anonymous fault handlers, this performs

the actual faulting in via [\_\_do_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4147) performs error checks and estab-

lishes the new mapping via [finish_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4345)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4345) but varies in two respects –

if the [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA)’s object [struct vm_operations_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n539)

vm_ops-\>page_mkwrite handler is specified, then this suggests that the un-

derlying filesystem or equivalent wishes to be notified when a shared

folio becomes writable and secondly, dirty page state is updated via

[fault_dirty_shared_page().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2993)

 



 

Examining [do_page_mkwrite()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2959) (eliding out of scope swap logic) as shown in

Listing 6-31.

 

2953 */\**

2954 *\* Notify the address space that the page is about to become writable so that*

2955 *\* it can prohibit this or wait for the page to get into an appropriate state.*

2956 *\**

2957 *\* We do this without the lock held, so that it can sleep if it needs to.* 2958 *\*/*

2959 **static vm_fault_t do_page_mkwrite**(**struct** vm_fault \*vmf) 2960 {

2961 **vm_fault_t** ret;

2962 **struct** page \*page = vmf-\>page; 2963 **unsigned int** old_flags = vmf-\>flags; 2964

2965 vmf-\>flags = **FAULT_FLAG_WRITE**\|**FAULT_FLAG_MKWRITE**;

. . .

2971 ret = vmf-\>vma-\>vm_ops-\>**page_mkwrite**(vmf); 2972 */\* Restore original flags so that caller is not surprised \*/* 2973 vmf-\>flags = old_flags; 2974 **if** (**unlikely**(ret & (**VM_FAULT_ERROR** \| **VM_FAULT_NOPAGE**))) 2975 **return** ret; 2976 **if** (**unlikely**(!(ret & **VM_FAULT_LOCKED**))) { 2977 **lock_page**(page); 2978 **if** (!page-\>mapping) { 2979 **unlock_page**(page); 2980 **return** 0; */\* retry \*/* 2981 }

2982 ret \|= **VM_FAULT_LOCKED**; 2983 } **else**

2984 **VM_BUG_ON_PAGE**(!**PageLocked**(page), page); 2985 **return** ret;

2986 }

 

*Listing 6-31:* mm/memory.c: [*do_page_mkwrite()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2959)

 

This allows an underlying filesystem to be able to deny write access to

a folio or perform operations required to permit this when either a read-

only mapping becomes writable (invoked from [wp_page_shared()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3304), discussed

in section 6.9) or here when a shared mapping is first written to without an intervening read.

This ultimately invokes the [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA)’s object

[struct vm_operations_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n539) vm_ops-\>page_mkwrite handler with the flags

[FAULT_FLAG_WRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n864) and [FAULT_FLAG_MKWRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n865) set.

After this we exit if an error is raised or it is indicated the fault has other-

wise been handled. We relock the folio if necessary and, should the address space no longer be valid (indicative of a file truncation or other form of in-

validation of the folio in respect of its associated [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)), the

 



 

function returns 0 which indicates to [do_shared_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4574) that the fault is com-

plete (and will refault).

The other difference between other fault handlers is the invocation of

[fault_dirty_shared_page(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2993)which is used to handle the fact that either a read-

only non-anonymous mapping is becoming writable (see section 6.9 for dis-

cussion of this case), or, as here, a newly write faulted in shared mapping.

This is invoked with the folio locked, meaning it can rely on the folio re-

maining stable throughout the operation, which it releases when it is com-

plete. We defer discussion of the details of this function to the page cache

chapter.

 

**6.8 Shared non-anonymous fault logic**

 

The non-anonymous fault handlers all share logic – [\_\_do_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4147) which

performs the actual faulting in of the folio, locking it as it does so and

[finish_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4345) which performs the actual mapping of the faulted-in folio

(and presumes that it is locked as it does so).

Let’s examine \_\_do_fault() to begin with, eliding the out of scope page

poisoning logic as shown in Listing 6-32.

 

4142 */\**

4143 *\* The mmap_lock must have been held on entry, and may have been* 4144 *\* released depending on flags and vma-\>vm_ops-\>fault() return value.* 4145 *\* See filemap_fault() and \_\_lock_page_retry().* 4146 *\*/*

4147 **static vm_fault_t \_\_do_fault**(**struct** vm_fault \*vmf) 4148 {

4149 **struct** vm_area_struct \*vma = vmf-\>vma; 4150 **vm_fault_t** ret;

4151

4152 */\**

4153 *\* Preallocate pte before we take page_lock because this might lead to*

4154 *\* deadlocks for memcg reclaim which waits for pages under writeback:*

4155 *\** *lock_page(A)* 4156 *\** *SetPageWriteback(A)* 4157 *\** *unlock_page(A)* 4158 *\* lock_page(B)*

4159 *\** *lock_page(B)* 4160 *\* pte_alloc_one*

4161 *\** *shrink_page_list* 4162 *\** *wait_on_page_writeback(A)* 4163 *\** *SetPageWriteback(B)* 4164 *\** *unlock_page(B)* 4165 *\** *\# flush A, B to clear the writeback* 4166 *\*/*

4167 **if** (**pmd_none**(\*vmf-\>pmd) && !vmf-\>prealloc_pte) { 4168 vmf-\>prealloc_pte = **pte_alloc_one**(vma-\>vm_mm); 4169 **if** (!vmf-\>prealloc_pte)

 



 

4170 **return VM_FAULT_OOM**; 4171 }

4172

4173 ret = vma-\>vm_ops-\>**fault**(vmf); 4174 **if** (**unlikely**(ret & (**VM_FAULT_ERROR** \| **VM_FAULT_NOPAGE** \| **VM_FAULT_RETRY**

\|

4175 **VM_FAULT_DONE_COW**))) 4176 **return** ret;

. . .

4195 **if** (**unlikely**(!(ret & **VM_FAULT_LOCKED**))) 4196 **lock_page**(vmf-\>page); 4197 **else**

4198 **VM_BUG_ON_PAGE**(!**PageLocked**(vmf-\>page), vmf-\>page); 4199

4200 **return** ret;

4201 }

 

*Listing 6-32:* mm/memory.c: [*\_\_do_fault()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4147)

 

This logic begins with some careful handling of the pre-allocation of

the PTE if no PTE is pointed at by the PMD entry, should it not already be pre-allocated. This is to avoid a deadlock under writeback (a topic we discuss in the page cache chapter) were the faulting logic to have to per-form this allocation. This was added and is well described in commit

[63f3655f9501: mm, memcg: fix reclaim deadlock with writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=63f3655f9501).

Next we simply defer the fault handling to the underlying

[struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA)’s object [struct vm_operations_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n539) vm_ops-\>fault handler, before checking for errors or cases which require us to exit with no further action taken in which case we exit early.

Finally, we check whether the fault handler did indeed lock the folio (via

the [VM_FAULT_LOCKED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n750) flag) and do so ourselves if not, as the caller expects the folio to be locked after this operation so we can safely map it without it dis-appearing from beneath us.

The intricacies of what is actually implemented in this handler, which is

often deferred to [filemap_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3084) are discussed in detail in the page cache chapter.

Once the folio has been faulted in, we must establish it in its map-

ping and perform final setup while the folio is locked. This is handled by

[finish_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4345) (eliding out of scope huge page and devmap handling) as

shown in Listing 6-33.

 

4330 */\*\**

4331 *\* finish_fault - finish page fault once we have prepared the page to fault*

4332 *\**

4333 *\* @vmf: structure describing the fault* 4334 *\**

4335 *\* This function handles all that is needed to finish a page fault once the*

4336 *\* page to fault in is prepared. It handles locking of PTEs, inserts PTE for*

4337 *\* given page, adds reverse page mapping, handles memcg charges and LRU*

 



 

4338 *\* addition.*

4339 *\**

4340 *\* The function expects the page to be locked and on success it consumes a*

4341 *\* reference of a page being mapped (for the PTE which maps it).* 4342 *\**

4343 *\* Return: %0 on success, %VM_FAULT\_ code in case of error.* 4344 *\*/*

4345 **vm_fault_t finish_fault**(**struct** vm_fault \*vmf) 4346 {

4347 **struct** vm_area_struct \*vma = vmf-\>vma; 4348 **struct** page \*page; 4349 **vm_fault_t** ret;

4350

4351 */\* Did we COW the page? \*/* 4352 **if** ((vmf-\>flags & **FAULT_FLAG_WRITE**) && !(vma-\>vm_flags & **VM_SHARED**)) 4353 page = vmf-\>cow_page; 4354 **else**

4355 page = vmf-\>page; 4356

4357 */\**

4358 *\* check even for read faults because we might have lost our CoWed*

4359 *\* page*

4360 *\*/*

4361 **if** (!(vma-\>vm_flags & **VM_SHARED**)) { 4362 ret = **check_stable_address_space**(vma-\>vm_mm); 4363 **if** (ret)

4364 **return** ret; 4365 }

4366

4367 **if** (**pmd_none**(\*vmf-\>pmd)) {

. . .

4374 **if** (vmf-\>prealloc_pte) 4375 **pmd_install**(vma-\>vm_mm, vmf-\>pmd, &vmf-\>prealloc_pte); 4376 **else if** (**unlikely**(**pte_alloc**(vma-\>vm_mm, vmf-\>pmd))) 4377 **return VM_FAULT_OOM**; 4378 }

. . .

4387 vmf-\>pte = **pte_offset_map_lock**(vma-\>vm_mm, vmf-\>pmd, 4388 vmf-\>address, &vmf-\>ptl); 4389

4390 */\* Re-check under ptl \*/* 4391 **if** (**likely**(!**vmf_pte_changed**(vmf))) { 4392 **do_set_pte**(vmf, page, vmf-\>address); 4393

4394 */\* no need to invalidate: a not-present page won't be cached*

*\*/*

4395 **update_mmu_cache**(vma, vmf-\>address, vmf-\>pte);

 



 

4396

4397 ret = 0;

4398 } **else** {

4399 **update_mmu_tlb**(vma, vmf-\>address, vmf-\>pte); 4400 ret = **VM_FAULT_NOPAGE**; 4401 }

4402

4403 **pte_unmap_unlock**(vmf-\>pte, vmf-\>ptl); 4404 **return** ret;

4405 }

 

*Listing 6-33:* mm/memory.c: [*finish_fault()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4345)

 

We start by determining which field of the [struct vm_fault](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n481) object actually

contains the faulted-in page – if this was a MAP_PRIVATE mapping and a write fault, then cow_page, otherwise it will be located in page.

We then perform a careful check of the state of the address space via

[check_stable_address_space()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/oom.h?h=v6.0#n102) in the MAP_PRIVATE case, as if the Out Of Mem-ory (OOM) killer has been activated, our CoW page may disappear beneath us (see the Out Of Memory killer chapter for more on this).

If the PTE has not yet been allocated, we allocate either from

the pre-allocated PTE or directly, before acquiring a PTE lock via

[pte_offset_map_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2302) (again note for 64-bit architectures no ‘mapping’ is re-quired).

With the PTE lock acquired, we check to see if the PTE has changed

via [vmf_pte_changed()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4322) – if so, we return [VM_FAULT_NOPAGE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n749) to indicate that it has changed beneath us and thus the allocated page is not required. Examining

this function as shown in Listing 6-34.

 

4322 **static bool vmf_pte_changed**(**struct** vm_fault \*vmf) 4323 {

4324 **if** (vmf-\>flags & **FAULT_FLAG_ORIG_PTE_VALID**) 4325 **return** !**pte_same**(\*vmf-\>pte, vmf-\>orig_pte); 4326

4327 **return** !**pte_none**(\*vmf-\>pte); 4328 }

 

*Listing 6-34:* mm/memory.c: [*vmf_pte_changed()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4322)

 

If an original PTE entry was stored (i.e. a PTE table was assigned to the

appropriate PMD at the time and thus the original PTE entry could be ob-tained, even if empty) then we check to see if it has changed prior to us ac-quiring the PTE table lock by comparing it to the original.

If not, then the PTE table will not have been allocated at the time and

thus one will have been allocated with each PTE entry being empty and we can check to see if anything has changed by checking to see if it still is via

[pte_none().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n723)

If nothing has changed beneath us, we then set the PTE to map

the newly faulted-in page and perform various housekeeping tasks via

[do_set_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4290) as shown in Listing 6-35.

 



 

4290 **void do_set_pte**(**struct** vm_fault \*vmf, **struct** page \*page, **unsigned long** addr) 4291 {

4292 **struct** vm_area_struct \*vma = vmf-\>vma; 4293 **bool** uffd_wp = **pte_marker_uffd_wp**(vmf-\>orig_pte); 4294 **bool** write = vmf-\>flags & **FAULT_FLAG_WRITE**; 4295 **bool** prefault = vmf-\>address != addr; 4296 **pte_t** entry;

4297

4298 **flush_icache_page**(vma, page); 4299 entry = **mk_pte**(page, vma-\>vm_page_prot); 4300

4301 **if** (prefault && **arch_wants_old_prefaulted_pte**()) 4302 entry = **pte_mkold**(entry); 4303 **else**

4304 entry = **pte_sw_mkyoung**(entry); 4305

4306 **if** (write)

4307 entry = **maybe_mkwrite**(**pte_mkdirty**(entry), vma); 4308 **if** (**unlikely**(uffd_wp)) 4309 entry = **pte_mkuffd_wp**(**pte_wrprotect**(entry)); 4310 */\* copy-on-write page \*/* 4311 **if** (write && !(vma-\>vm_flags & **VM_SHARED**)) { 4312 **inc_mm_counter_fast**(vma-\>vm_mm, **MM_ANONPAGES**); 4313 **page_add_new_anon_rmap**(page, vma, addr); 4314 **lru_cache_add_inactive_or_unevictable**(page, vma); 4315 } **else** {

4316 **inc_mm_counter_fast**(vma-\>vm_mm, mm_counter_file(page)); 4317 **page_add_file_rmap**(page, vma, **false**); 4318 }

4319 **set_pte_at**(vma-\>vm_mm, addr, vmf-\>pte, entry); 4320 }

 

*Listing 6-35:* mm/memory.c: [*do_set_pte()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4290)

 

For architectures that require it, the instruction cache is manually

flushed, however this is not the case for x86-64.

Then [arch_wants_old_prefaulted_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n141) (relevant to arm64) and

[pte_sw_mkyoung()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n468) (relevant to MIPS) handle some edge case page table update

logic. Neither of these are relevant to x86-64.

Similar to [do_anonymous_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4031), the PTE entry is marked writable and dirty

if the fault was a write fault. This is checked via [maybe_mkwrite()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n977) which simply

marks the mapping writable if its containing VMA has [VM_WRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n267) specified.

GUP can trigger write faults for non-writable VMAs hence the need for this

check.

Finally we differentiate between a MAP_PRIVATE Copy on Write page and a

shared one – in both cases the relevant statistics are updated and in the for-

mer case the newly faulted page is added to the anonymous reverse mapping

 



 

via [page_add_new_anon_rmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1262) (see listing 7-20 and section 7.0.12 for a detailed examination of this).

In the latter case the folio is added to the file reverse mapping via

[page_add_file_rmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1293) (for a broader discussion of the reverse mapping see

## Chapter 7).

 

**6.9 Write-protected page fault**

 

When a mapping exists on a write fault but the existing mapping is read-only

(though with [VM_WRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n267) set), or the Get User Pages (GUP) logic requests that

an anonymous memory mapping is unshared via [FAULT_FLAG_UNSHARE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n874) we need

to perform a Copy on Write operation. This case is handled by [do_wp_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3360)

as shown in Figure 6-4.

 

[do_wp_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3360) (PTE lock held)

 

Set vmf-\>pageto copyable page via Return 0

[vm_normal_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n612)

From To [wp_page_reuse()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3046) Yes

[wp_pfn_shared()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3286) vm_ops-\>pfn_mkwrite [,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3286) If no

Yes

[wp_page_shared()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3304) IsNULL? Unshare? [wp_pfn_shared()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3286)

No

No No

Yes, NULL page

[wp_page_reuse()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3046) Is anon folio? Shared writeable?

No Yes Yes, non-anonymous folio No

Yes

Unshare? Exclusive? [wp_page_copy()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3090) [wp_page_shared()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3304)

Yes If novm_ops-\>pfn_mkwrite No

Yes To [wp_page_reuse()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3046)

Return 0 refs *\>* 3?

No

No

[lru_add_drain()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n727) Is LRU folio?

Yes

Yes

refs *\>* 1 & swap cache?

No

No

[trylock_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n908)?

Yes

Yes

[try_to_free_swap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n1590) In swap cache?

No

refs *̸* Yes

= 1? [unlock_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n18)

No

[unlock_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n18) [page_move_anon_rmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1102)

 

*Figure 6-4: Simplified overview of write-protect fault handler* [*do_wp_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3360)

 



 

Note that the case of an attempted write access to a VMA area

which does not have [VM_WRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n267) set this will have already been handled by

[access_error()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1076).

This function applies to both anonymous and non-anonymous map-

pings, as anonymous mappings can become Copy on Write when a process

is forked, and non-anonymous mappings, if mapped via MAP_PRIVATE, also re-

quire Copy on Write semantics.

[do_wp_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3360) is invoked with the PTE table containing the entry in ques-

tion locked. Examining this, eliding out of scope userfaultfd and KSM logic

as shown in Listing 6-36.

 

3338 */\**

3339 *\* This routine handles present pages, when* 3340 *\* \* users try to write to a shared page (FAULT_FLAG_WRITE)* 3341 *\* \* GUP wants to take a R/O pin on a possibly shared anonymous page* 3342 *\** *(FAULT_FLAG_UNSHARE)* 3343 *\**

3344 *\* It is done by copying the page to a new address and decrementing the* 3345 *\* shared-page counter for the old page.* 3346 *\**

3347 *\* Note that this routine assumes that the protection checks have been* 3348 *\* done by the caller (the low-level page fault routine in most cases).* 3349 *\* Thus, with FAULT_FLAG_WRITE, we can safely just mark it writable once we've*

3350 *\* done any necessary COW.* 3351 *\**

3352 *\* In case of FAULT_FLAG_WRITE, we also mark the page dirty at this point even*

3353 *\* though the page will change only once the write actually happens. This* 3354 *\* avoids a few races, and potentially makes it more efficient.* 3355 *\**

3356 *\* We enter with non-exclusive mmap_lock (to exclude vma changes,* 3357 *\* but allow concurrent faults), with pte both mapped and locked.* 3358 *\* We return with mmap_lock still held, but pte unmapped and unlocked.* 3359 *\*/*

3360 **static vm_fault_t do_wp_page**(**struct** vm_fault \*vmf) 3361 **\_\_releases**(vmf-\>ptl) 3362 {

3363 **const bool** unshare = vmf-\>flags & **FAULT_FLAG_UNSHARE**; 3364 **struct** vm_area_struct \*vma = vmf-\>vma; 3365

3366 **VM_BUG_ON**(unshare && (vmf-\>flags & **FAULT_FLAG_WRITE**)); 3367 **VM_BUG_ON**(!unshare && !(vmf-\>flags & **FAULT_FLAG_WRITE**));

. . .

3384 vmf-\>page = **vm_normal_page**(vma, vmf-\>address, vmf-\>orig_pte); 3385 **if** (!vmf-\>page) { 3386 **if** (**unlikely**(unshare)) { 3387 */\* No anonymous page -\> nothing to do. \*/* 3388 **pte_unmap_unlock**(vmf-\>pte, vmf-\>ptl); 3389 **return** 0;

 



 

3390 }

3391

3392 */\**

3393 *\* VM_MIXEDMAP !pfn_valid() case, or VM_SOFTDIRTY clear on a*

3394 *\* VM_PFNMAP VMA.* 3395 *\**

3396 *\* We should not cow pages in a shared writeable mapping.*

3397 *\* Just mark the pages writable and/or call ops-\>pfn_mkwrite.*

3398 *\*/*

3399 **if** ((vma-\>vm_flags & (**VM_WRITE**\|**VM_SHARED**)) == 3400 (**VM_WRITE**\|**VM_SHARED**)) 3401 **return wp_pfn_shared**(vmf); 3402

3403 **pte_unmap_unlock**(vmf-\>pte, vmf-\>ptl); 3404 **return wp_page_copy**(vmf); 3405 }

3406

3407 */\**

3408 *\* Take out anonymous pages first, anonymous shared vmas are* 3409 *\* not dirty accountable.* 3410 *\*/*

3411 **if** (**PageAnon**(vmf-\>page)) { 3412 **struct** page \*page = vmf-\>page; 3413

3414 */\**

3415 *\* If the page is exclusive to this process we must reuse the*

3416 *\* page without further checks.* 3417 *\*/*

3418 **if** (**PageAnonExclusive**(page)) 3419 **goto reuse**; 3420

3421 */\**

3422 *\* We have to verify under page lock: these early checks are*

3423 *\* just an optimization to avoid locking the page and freeing*

3424 *\* the swapcache if there is little hope that we can reuse.*

3425 *\**

3426 *\* PageKsm() doesn't necessarily raise the page refcount.*

3427 *\*/*

3428 **if** (**PageKsm**(page) \|\| **page_count**(page) \> 3) 3429 **goto copy**; 3430 **if** (!**PageLRU**(page)) 3431 */\** 3432 *\* Note: We cannot easily detect+handle references*

*from*

3433 *\* remote LRU pagevecs or references to PageLRU()*

*pages.*

3434 *\*/*

 



 

3435 **lru_add_drain**(); 3436 **if** (**page_count**(page) \> 1 + **PageSwapCache**(page)) 3437 **goto copy**; 3438 **if** (!**trylock_page**(page)) 3439 **goto copy**; 3440 **if** (**PageSwapCache**(page)) 3441 **try_to_free_swap**(page); 3442 **if** (**PageKsm**(page) \|\| **page_count**(page) != 1) { 3443 **unlock_page**(page); 3444 **goto copy**; 3445 }

3446 */\**

3447 *\* Ok, we've got the only page reference from our mapping* 3448 *\* and the page is locked, it's dark out, and we're wearing*

3449 *\* sunglasses. Hit it.* 3450 *\*/*

3451 **page_move_anon_rmap**(page, vma); 3452 **unlock_page**(page); 3453 **reuse**:

3454 **if** (**unlikely**(unshare)) { 3455 **pte_unmap_unlock**(vmf-\>pte, vmf-\>ptl); 3456 **return** 0; 3457 }

3458 **wp_page_reuse**(vmf); 3459 **return VM_FAULT_WRITE**; 3460 } **else if** (unshare) { 3461 */\* No anonymous page -\> nothing to do. \*/* 3462 **pte_unmap_unlock**(vmf-\>pte, vmf-\>ptl); 3463 **return** 0; 3464 } **else if** (**unlikely**((vma-\>vm_flags & (**VM_WRITE**\|**VM_SHARED**)) == 3465 (**VM_WRITE**\|**VM_SHARED**))) { 3466 **return wp_page_shared**(vmf); 3467 }

3468 **copy**:

3469 */\**

3470 *\* Ok, we need to copy. Oh, well..* 3471 *\*/*

3472 **get_page**(vmf-\>page); 3473

3474 **pte_unmap_unlock**(vmf-\>pte, vmf-\>ptl);

. . .

3479 **return wp_page_copy**(vmf); 3480 }

 

*Listing 6-36:* mm/memory.c: [*do_wp_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3360)

 

This starts by asserting that, if the [FAULT_FLAG_UNSHARE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n874) flag has been spec-

ified, that the [FAULT_FLAG_WRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n864) cannot be – i.e. they are mutually exclusive.

 



 

Equally, if FAULT_FLAG_UNSHARE has not been specified, then FAULT_FLAG_WRITE must be.

Next, we obtain the [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) object associated with the PTE via

[vm_normal_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n612) and place it in the [struct vm_fault-\>page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n481) field. See section

6.12 for more on this.

We then deal with the case in which no copyable page object is associated

with the PTE (i.e. a special case handled by vm_normal_page() – if we are un-sharing then there is simply nothing to do and we exit.

However, if there is no copyable page mapped and it is shared writable –

we delegate the operation to [wp_pfn_shared()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3286) – this is specific to a [VM_MIXEDMAP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n306)

or [VM_PFNMAP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n279) mapping with [VM_SHARED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n269) set. We will discuss this is more detail below when we examine wp_pfn_shared().

If there is no copyable page mapped and neither of two previously de-

scribed cases apply, which can occur for example if the mapping points at

the zero page, then we simply go ahead and copy it via [wp_page_copy()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3090) with the PTE map released.

Next we have separate handling for anonymous and non-anonymous

mappings – dealing with non-anonymous first, as this is far simpler.

 

***6.9.1 Non-anonymous folios***

if we are unsharing then there is simply nothing to do as this operation is not supported for non-anonymous pages.

Otherwise we check to see if the non-anonymous [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403)

(VMA) is writable and shared, if so we handle this fault with the

[wp_page_shared()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3304) handler – this is the case where the PTE mapping is read-only.

It might seem odd that a writable shared non-anonymous mapping

would have a readonly PTE (which is what would have to have happened to reach this point in the code), however this is explicitly the case when

[vma_set_page_prot()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n90) on memory map, or [mprotect_fixup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mprotect.c?h=v6.0#n539) on modifying

a memory region’s protection on [mprotect()](https://man7.org/linux/man-pages/man2/mprotect.2.html), determines that a non-anonymous VMA requires notification when a mapping becomes writable,

as determined by [vma_wants_writenotify()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1630)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1630)

 

***6.9.2 Anonymous folios***

Anonymous mappings (with a copyable source folio) comprise the bulk of the complexity of the function. The logic consists of trying our hardest to reuse folios if we can. We perform the quickest checks first, before going through a process of removing unnecessary references and seeing whether

doing so renders reuse possible (via [wp_page_reuse()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3046)).

Examining this (note we elide out of scope [Kernel Samepage Merging](https://kernel.org/doc/html/v6.0/mm/ksm.html)

[(KSM)](https://kernel.org/doc/html/v6.0/mm/ksm.html) logic):

 

**Anonymous exclusive** folio – The [PG_anon_exclusive](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n152) folio flag is set, meaning

that there is one and only one reference to the folio which can simply be

reused via [wp_page_reuse()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3046)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3046)

 



 

**Excessive folio references** – Since the folio is not yet locked, we try to avoid

doing so if we don’t stand any chance of reusing the folio.

Folio batches concerned with LRU operations (such as [folio_add_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n479)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n479) obtain a reference on a folio before adding them to the folio batch (see

section 11.7 for details on folio batches) and in addition there might be a swap cache reference (see swap chapter for details of the swap cache). Therefore, if the number of references to the folio (as determined by

[page_count()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page_ref.h?h=v6.0#n92) (which defers to [folio_ref_count()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page_ref.h?h=v6.0#n87) and ultimately atomi-cally reads the folio’s \_refcount field) exceeds these 3 potential sources of ephemeral references, then it’s really not worth attempting to reuse a

folio and we shortcut to copying the page via [wp_page_copy()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3090).

**Non-LRU** folio – If the folio in question is non-LRU, i.e. is on a folio

batch in the process of being added to an LRU list or otherwise moved around, we hold an excess reference.

In order to try to cheaply clear such a reference, we drain folios

from the local CPU’s LRU folio batches via [lru_add_drain()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n727)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n727) This and the related check above were added in commit d4c470970d45 –

[mm: optimize do_wp_page() for fresh pages in local LRU pagevecs](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=d4c470970d45).

**Excessive folio references** **again** – Now we have drained the LRU, we ex-

plicitly check to see if we have additional references in excess of the swap cache one – if so, then we must copy.

**Free swap cache** – We start by trying to lock the folio via [trylock_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n908), this

is a non-sleeping lock – if we fail then we simply copy the folio. Now locked, we can reliably check whether the folio is in the swap cache,

and attempting to quickly free it from there using [try_to_free_swap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n1590). See the swap chapter for more on the swap cache.

**Final excessive folio references check** – Now, if we have more than 1 refer-

ence, we have no more tricks left to reduce them. We are then definitely in a situation where we have to copy the folio.

**Folio reuse** – We are finally at a point where we definitely have only one

reference and can go ahead and try to reuse the folio rather than copy it.

We start by invoking [page_move_anon_rmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1102) which sets the folio’s mapping

field to the [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) object the [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) con-taining it points at. E.g., if a process had faulted in a folio, forks and then the parent unmaps it and the child accesses the folio triggering a write fault, this logic would point to the child’s anon_vma instead (see

## Chapter 7 for more on this).

This function additionally sets the [PG_anon_exclusive](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n152) to indicate that the folio is now mapped exclusively.

Afterwards, the folio is unlocked via [unlock_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n18) and check to see if we are GUP unsharing – if we are, then the fault is complete and the unshare has been successful.

Finally, for all other cases we reuse the folio via [wp_page_reuse()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3046)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3046)

 



 

***6.9.3 Folio/PFN sharing***

When a non-anonymous or non-folio backed (see section 6.12 for more on these) shared writable mapping write faults, we resolve this via

[wp_page_shared()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3304) for the former case and [wp_pfn_shared()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3286) for the latter.

The primary reason that this kind of fault occurs is because the map-

ping has been intentionally marked readonly so the underlying filesys-tem can be notified when the mapping is made writable, as determined

by the [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA)’s object [struct vm_operations_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n539) vm_ops-\>page_mkwrite or vm_ops-\>pfn_mkwrite handlers respectively.

Each ultimately invokes [wp_page_reuse()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3046) to mark the PTE writable. Both functions are similar to one another in that they ultimately invoke

the mkwrite handler, only [wp_page_shared()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3304) has additional handling for the un-

derlying folio. Examining the PFN case first as shown in Listing 6-37.

 

3282 */\**

3283 *\* Handle write page faults for VM_MIXEDMAP or VM_PFNMAP for a VM_SHARED* 3284 *\* mapping*

3285 *\*/*

3286 **static vm_fault_t wp_pfn_shared**(**struct** vm_fault \*vmf) 3287 {

3288 **struct** vm_area_struct \*vma = vmf-\>vma; 3289

3290 **if** (vma-\>vm_ops && vma-\>vm_ops-\>**pfn_mkwrite**) { 3291 **vm_fault_t** ret; 3292

3293 **pte_unmap_unlock**(vmf-\>pte, vmf-\>ptl); 3294 vmf-\>flags \|= **FAULT_FLAG_MKWRITE**; 3295 ret = vma-\>vm_ops-\>**pfn_mkwrite**(vmf); 3296 **if** (ret & (**VM_FAULT_ERROR** \| **VM_FAULT_NOPAGE**)) 3297 **return** ret; 3298 **return finish_mkwrite_fault**(vmf); 3299 }

3300 **wp_page_reuse**(vmf); 3301 **return VM_FAULT_WRITE**; 3302 }

 

*Listing 6-37:* mm/memory.c: [*wp_pfn_shared()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3286)

 

If there is no pfn_mkwrite handler then this simply forwards the fault han-

dling to [wp_page_reuse()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3046). Otherwise, the PTE lock is released so the mkwrite

handler can sleep if necessary without lock contention, [FAULT_FLAG_MKWRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n865) fault flag is set to indicate that this faulting behaviour is desired, and the handler itself is invoked.

If an error or [VM_FAULT_NOPAGE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n749) condition arises we simply exit with the er-

ror, otherwise we finalise the operation in [finish_mkwrite_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3264) which reac-quires the PTE lock (which wp_page_reuse() expects), checks to see if the PTE changed from underneath us before invoking wp_page_reuse() as shown in

Listing 6-38.

 



 

3248 */\*\**

3249 *\* finish_mkwrite_fault - finish page fault for a shared mapping, making PTE*

3250 *\** *writeable once the page is prepared* 3251 *\**

3252 *\* @vmf: structure describing the fault* 3253 *\**

3254 *\* This function handles all that is needed to finish a write page fault in a*

3255 *\* shared mapping due to PTE being read-only once the mapped page is prepared.*

3256 *\* It handles locking of PTE and modifying it.* 3257 *\**

3258 *\* The function expects the page to be locked or other protection against* 3259 *\* concurrent faults / writeback (such as DAX radix tree locks).* 3260 *\**

3261 *\* Return: %0 on success, %VM_FAULT_NOPAGE when PTE got changed before* 3262 *\* we acquired PTE lock.*

3263 *\*/*

3264 **vm_fault_t finish_mkwrite_fault**(**struct** vm_fault \*vmf) 3265 {

3266 **WARN_ON_ONCE**(!(vmf-\>vma-\>vm_flags & **VM_SHARED**)); 3267 vmf-\>pte = **pte_offset_map_lock**(vmf-\>vma-\>vm_mm, vmf-\>pmd, vmf-\>address

,

3268 &vmf-\>ptl); 3269 */\**

3270 *\* We might have raced with another page fault while we released the*

3271 *\* pte_offset_map_lock.* 3272 *\*/*

3273 **if** (!**pte_same**(\*vmf-\>pte, vmf-\>orig_pte)) { 3274 **update_mmu_tlb**(vmf-\>vma, vmf-\>address, vmf-\>pte); 3275 **pte_unmap_unlock**(vmf-\>pte, vmf-\>ptl); 3276 **return VM_FAULT_NOPAGE**; 3277 }

3278 **wp_page_reuse**(vmf); 3279 **return** 0;

3280 }

 

*Listing 6-38:* mm/memory.c: [*finish_mkwrite_fault()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3264)

 

For more details on the [VM_MIXEDMAP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n306) and [VM_PFNMAP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n279) mappings which neces-

sitate this machinery see section 6.12.

In the more common case of a shared, writeable non-anonymous map-

ping which has a read-only mapping (most likely because the VMA fulfils

[vma_wants_writenotify()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1630)) the write fault is handled by [wp_page_shared()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3304) as

shown in Listing 6-39.

 

3304 **static vm_fault_t wp_page_shared**(**struct** vm_fault \*vmf) 3305 **\_\_releases**(vmf-\>ptl) 3306 {

3307 **struct** vm_area_struct \*vma = vmf-\>vma;

 



 

3308 **vm_fault_t** ret = **VM_FAULT_WRITE**; 3309

3310 **get_page**(vmf-\>page); 3311

3312 **if** (vma-\>vm_ops && vma-\>vm_ops-\>**page_mkwrite**) { 3313 **vm_fault_t** tmp; 3314

3315 **pte_unmap_unlock**(vmf-\>pte, vmf-\>ptl); 3316 tmp = **do_page_mkwrite**(vmf); 3317 **if** (**unlikely**(!tmp \|\| (tmp & 3318 (**VM_FAULT_ERROR** \| **VM_FAULT_NOPAGE**)))) { 3319 **put_page**(vmf-\>page); 3320 **return** tmp; 3321 }

3322 tmp = **finish_mkwrite_fault**(vmf); 3323 **if** (**unlikely**(tmp & (**VM_FAULT_ERROR** \| **VM_FAULT_NOPAGE**))) { 3324 **unlock_page**(vmf-\>page); 3325 **put_page**(vmf-\>page); 3326 **return** tmp; 3327 }

3328 } **else** {

3329 **wp_page_reuse**(vmf); 3330 **lock_page**(vmf-\>page); 3331 }

3332 ret \|= **fault_dirty_shared_page**(vmf); 3333 **put_page**(vmf-\>page); 3334

3335 **return** ret;

3336 }

 

*Listing 6-39:* mm/memory.c: [*wp_page_shared()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3304)

 

This maintains the same structure as [wp_pfn_shared()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3286)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3286) only with ma-

chinery to deal with the fact that we have an underlying folio to contend with. The first difference being that we increment the reference counter

for the folio via [get_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1093) over the operation and decrement it on exit via

[put_page().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1167)

If a page_mkwrite handler is in place, we invoke it via [do_page_mkwrite()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2959) (as

described in section 6.7, listing 6-31, when [do_shared_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4574) invokes it) which acquires a folio lock if successful. This operation is performed with the PTE table unlocked to permit sleeping in the handler.

Finally this handling invokes [finish_mkwrite_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3264) as described above to

reacquire the PTE lock and invoke [wp_page_reuse()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3046) to reuse the underlying folio.

If the VMA does not require notifying of a shared mapping being made

writable (i.e. it does not possess a page_mkwrite handler), then the function simply invokes wp_page_reuse() and locks the folio.

 



 

Handling the fact that this mapping has now been marked dirty is per-

formed via [fault_dirty_shared_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2993) which expects the underlying folio to be

locked. After this is complete, the folio reference is dropped as we no longer

have to be concerned about it disappearing beneath us during this opera-

tion. Examining this function as shown in Listing 6-40.

 

2988 */\**

2989 *\* Handle dirtying of a page in shared file mapping on a write fault.* 2990 *\**

2991 *\* The function expects the page to be locked and unlocks it.* 2992 *\*/*

2993 **static vm_fault_t fault_dirty_shared_page**(**struct** vm_fault \*vmf) 2994 {

2995 **struct** vm_area_struct \*vma = vmf-\>vma; 2996 **struct** address_space \*mapping; 2997 **struct** page \*page = vmf-\>page; 2998 **bool** dirtied;

2999 **bool** page_mkwrite = vma-\>vm_ops && vma-\>vm_ops-\>page_mkwrite; 3000

3001 dirtied = **set_page_dirty**(page); 3002 **VM_BUG_ON_PAGE**(**PageAnon**(page), page); 3003 */\**

3004 *\* Take a local copy of the address_space - page.mapping may be zeroed*

3005 *\* by truncate after unlock_page().* *The address_space itself remains* 3006 *\* pinned by vma-\>vm_file's reference. We rely on unlock_page()'s*

3007 *\* release semantics to prevent the compiler from undoing this copying*

*.*

3008 *\*/*

3009 mapping = **page_rmapping**(page); 3010 **unlock_page**(page); 3011

3012 **if** (!page_mkwrite) 3013 **file_update_time**(vma-\>vm_file); 3014

3015 */\**

3016 *\* Throttle page dirtying rate down to writeback speed.* 3017 *\**

3018 *\* mapping may be NULL here because some device drivers do not* 3019 *\* set page.mapping but still dirty their pages* 3020 *\**

3021 *\* Drop the mmap_lock before waiting on IO, if we can. The file* 3022 *\* is pinning the mapping, as per above.* 3023 *\*/*

3024 **if** ((dirtied \|\| page_mkwrite) && mapping) { 3025 **struct** file \*fpin; 3026

3027 fpin = **maybe_unlock_mmap_for_io**(vmf, **NULL**); 3028 **balance_dirty_pages_ratelimited**(mapping);

 



 

3029 **if** (fpin) { 3030 **fput**(fpin); 3031 **return VM_FAULT_COMPLETED**; 3032 }

3033 }

3034

3035 **return** 0;

3036 }

 

*Listing 6-40:* mm/memory.c: [*fault_dirty_shared_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2993)

 

This somewhat overlaps with the page cache logic which, being such a

large and important subject, I defer to the page cache chapter, however we will briefly touch on it here. See this chapter for a far more thorough exami-nation.

The folio itself is set dirty and any [struct address_mapping](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) handling for

this operation is performed in [set_page_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n60) (which is a legacy wrapper

around [folio_mark_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2730)[).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2730)

With this operation complete, we obtain the address_mapping object of the

folio via [page_rmapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n747) and unlock the folio. This dance is required to han-dle the fact that truncation may result in the mapping being zeroed when not under lock.

If there was no page_mkwrite handler, the file associated with the mapping

has its ctime and mtime fields updated via [file_update_time()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/inode.c?h=v6.0#n2110)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/inode.c?h=v6.0#n2110)

Finally, if the folio was successfully dirtied or a page_mkwrite handler exists

(and was invoked) and an address_space mapping exists for it, we immediately

release the [struct mm_structmmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) lock if possible as we are about to wait on I/O and want to reduce contention.

We determine whether we can do so via [maybe_unlock_mmap_for_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n607) as

shown in Listing 6-41.

 

607 **static inline struct** file \***maybe_unlock_mmap_for_io**(**struct** vm_fault \*vmf, 608 **struct** file \*fpin) 609 {

610 **int** flags = vmf-\>flags; 611

612 **if** (fpin)

613 **return** fpin; 614

615 */\**

616 *\* FAULT_FLAG_RETRY_NOWAIT means we don't want to wait on page locks*

*or*

617 *\* anything, so we only pin the file and drop the mmap_lock if only*

618 *\* FAULT_FLAG_ALLOW_RETRY is set, while this is the first attempt.*

619 *\*/*

620 **if** (**fault_flag_allow_retry_first**(flags) && 621 !(flags & **FAULT_FLAG_RETRY_NOWAIT**)) { 622 fpin = **get_file**(vmf-\>vma-\>vm_file); 623 **mmap_read_unlock**(vmf-\>vma-\>vm_mm);

 



 

624 }

625 **return** fpin;

626 }

 

*Listing 6-41:* mm/internal.h: [*maybe_unlock_mmap_for_io()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n607)

 

We only drop the lock if retry is still permitted as determined by

[fault_flag_allow_retry_first()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n453) (i.e. the fault flag [FAULT_FLAG_ALLOW_RETRY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n866) is set

and [FAULT_FLAG_TRIED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n869) is not) as long as [FAULT_FLAG_RETRY_NOWAIT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n867) is not specified

(this explicitly indicates that we do not want to wait for I/O).

The mapping is pinned via its [struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) vm_file field if the

mmap_lock was released. Dirty page are then potentially written back

depending on the dirty page tunables such as vm.dirty_ratio via

[balance_dirty_pages_ratelimited(). ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1949)See the page cache chapter for a detailed

analysis of this.

If a file pin was acquired, this is released and [VM_FAULT_COMPLETED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n755) is re-

turned to indicate that the fault has been handled and lock released, oth-

erwise we return 0 to indicate that no additional fault flags need be set.

 

***6.9.4 Page reuse***

When reusing a shared writeable non-anonymous PFN or folio (via

[wp_pfn_shared()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3286) or [wp_page_shared()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3304)), or when an anonymous page has been

determined to possess only a single reference reuse of the underlying folio is

handled by [wp_page_reuse()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3046) as shown in Listing 6-42

 

3038 */\**

3039 *\* Handle write page faults for pages that can be reused in the current vma*

3040 *\**

3041 *\* This can happen either due to the mapping being with the VM_SHARED flag,*

3042 *\* or due to us being the last reference standing to the page. In either* 3043 *\* case, all we need to do here is to mark the page as writable and update*

3044 *\* any related book-keeping.* 3045 *\*/*

3046 **static inline void wp_page_reuse**(**struct** vm_fault \*vmf) 3047 \_\_releases(vmf-\>ptl) 3048 {

3049 **struct** vm_area_struct \*vma = vmf-\>vma; 3050 **struct** page \*page = vmf-\>page; 3051 **pte_t** entry;

3052

3053 **VM_BUG_ON**(!(vmf-\>flags & **FAULT_FLAG_WRITE**)); 3054 **VM_BUG_ON**(page && **PageAnon**(page) && !**PageAnonExclusive**(page)); 3055

3056 */\**

3057 *\* Clear the pages cpupid information as the existing* 3058 *\* information potentially belongs to a now completely* 3059 *\* unrelated process.* 3060 *\*/*

 



 

3061 **if** (page)

3062 **page_cpupid_xchg_last**(page, (1 \<\< **LAST_CPUPID_SHIFT**) - 1); 3063

3064 **flush_cache_page**(vma, vmf-\>address, pte_pfn(vmf-\>orig_pte)); 3065 entry = **pte_mkyoung**(vmf-\>orig_pte); 3066 entry = **maybe_mkwrite**(**pte_mkdirty**(entry), vma); 3067 **if** (**ptep_set_access_flags**(vma, vmf-\>address, vmf-\>pte, entry, 1)) 3068 **update_mmu_cache**(vma, vmf-\>address, vmf-\>pte); 3069 **pte_unmap_unlock**(vmf-\>pte, vmf-\>ptl); 3070 **count_vm_event**(**PGREUSE**); 3071 }

 

*Listing 6-42:* mm/memory.c: [*wp_page_reuse()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3046)

 

The [NUMA balancing](https://kernel.org/doc/html/v6.0/mm/balance.html) logic tracks the last CPU which accessed a folio via

a cpupid field typically encoded in the [struct folio-\>flags](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) field (or if the ar-chitecture and kernel configuration means there is insufficient space here,

in the \_last_cpupid field). We clear this field via [page_cpupid_xchg_last()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmzone.c?h=v6.0#n94) as this information is now invalidated (the folio may last have been accessed by an unrelated sharing process).

The flush_cache_page() and update_mmu_cache() functions are invoked for

architectures which need manual memory cache maintenance, however our focused upon architecture x86-64 does not require this.

A new PTE entry is derived from the original PTE entry

[struct vm_fault](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n481)-\>orig_pte only with its accessed flag set by [pte_mkyoung()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n333), dirt-

ied by [pte_mkdirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n328) and set writable by [maybe_mkwrite()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n977) if the VMA has its

[VM_WRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n267) flag set.

The flags are updated by [ptep_set_access_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1035) before the PTE page

table lock is released and statistics are updated.

 

***6.9.5 Folio copying***

If all else has failed and we simply need to Copy-on-Write or unshare be-cause there are multiple references to the share read-only folio then we must

go ahead and copy it. This is handled by [wp_page_copy()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3090) (eliding out of scope mmu notifier, userfaultfd, delay accounting and cgroup logic) as shown in

Listing 6-43.

 

3073 */\**

3074 *\* Handle the case of a page which we actually need to copy to a new page,*

3075 *\* either due to COW or unsharing.* 3076 *\**

3077 *\* Called with mmap_lock locked and the old page referenced, but* 3078 *\* without the ptl held.*

3079 *\**

3080 *\* High level logic flow:* 3081 *\**

3082 *\* - Allocate a page, copy the content of the old page to the new one.* 3083 *\* - Handle book keeping and accounting - cgroups, mmu-notifiers, etc.*

 



 

3084 *\* - Take the PTL. If the pte changed, bail out and release the allocated page*

3085 *\* - If the pte is still the way we remember it, update the page table and all*

3086 *\** *relevant references. This includes dropping the reference the page-table* 3087 *\** *held to the old page, as well as updating the rmap.* 3088 *\* - In any case, unlock the PTL and drop the reference we took to the old*

*page.*

3089 *\*/*

3090 **static vm_fault_t wp_page_copy**(**struct** vm_fault \*vmf) 3091 {

3092 **const bool** unshare = vmf-\>flags & **FAULT_FLAG_UNSHARE**; 3093 **struct** vm_area_struct \*vma = vmf-\>vma; 3094 **struct** mm_struct \*mm = vma-\>vm_mm; 3095 **struct** page \*old_page = vmf-\>page; 3096 **struct** page \*new_page = **NULL**; 3097 **pte_t** entry;

3098 **int** page_copied = 0;

. . .

3103 **if** (**unlikely**(**anon_vma_prepare**(vma))) 3104 **goto oom**; 3105

3106 **if** (**is_zero_pfn**(**pte_pfn**(vmf-\>orig_pte))) { 3107 new_page = **alloc_zeroed_user_highpage_movable**(vma, 3108 vmf-\>address);

3109 **if** (!new_page) 3110 **goto oom**; 3111 } **else** {

3112 new_page = **alloc_page_vma**(**GFP_HIGHUSER_MOVABLE**, vma, 3113 vmf-\>address); 3114 **if** (!new_page) 3115 **goto oom**; 3116

3117 **if** (!**\_\_wp_page_copy_user**(new_page, old_page, vmf)) { 3118 */\** 3119 *\* COW failed, if the fault was solved by other,* 3120 *\* it's fine. If not, userspace would re-fault on* 3121 *\* the same address and we will handle the fault* 3122 *\* from the second attempt.* 3123 *\*/* 3124 **put_page**(new_page); 3125 **if** (old_page) 3126 **put_page**(old_page);

. . .

3129 **return** 0; 3130 }

3131 }

. . .

3137 **\_\_SetPageUptodate**(new_page);

 



 

. . .

3144 */\**

3145 *\* Re-check the pte - we dropped the lock* 3146 *\*/*

3147 vmf-\>pte = **pte_offset_map_lock**(mm, vmf-\>pmd, vmf-\>address, &vmf-\>ptl);

 

*Listing 6-43:* mm/memory.c: [*wp_page_copy()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3090) *folio copying*

 

The function is called with a reference on the input folio (if it is backed

by one, i.e. not a pure PFN mapping) so it won’t disappear beneath us.

At this stage, the folio being copied to will be anonymous – either by

simply being an anonymous mapping, or if this is a MAP_PRIVATE-mapped file-

backed mapping, then on Copy on Write the [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA)

will exist in both the [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) and [struct address_mapping](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)-\>i_mmap re-verse mapping trees.

As a result, we must allocated and prepare the anon_vma associated with

this mapping if this has not already been done, via [anon_vma_prepare()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n154). See

## Chapter 7 for more details on the reverse mapping.

Next, we perform the actual copy of the folio itself – if it is a zero page

mapping, then no copying is required and we simply acquire a zeroed page

via [alloc_zeroed_user_highpage_movable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page.h?h=v6.0#n37)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page.h?h=v6.0#n37) If we cannot allocate we defer to the

out of memory logic which returns [VM_FAULT_OOM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n742) and ultimately invokes the Out Of Memory (OOM) killer (see the chapter on this for more details).

Otherwise, we allocate a new folio (note, not zeroed, as we are about to

copy to it) via [alloc_page_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n287) and copy the page via [\_\_wp_page_copy_user()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2844)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2844) If this fails, we decrement reference counts for the source and newly allocated folios and return zero – if the fault was resolved by a racing fault handler then we can simply carry on, if not then we will refault and can try again.

The \_\_wp_page_copy_user() function is trivial for the folio-backed case, but

more involved for special PFN mappings, so we defer examining it to section

6.12.

After the copying has completed, we mark the folio up to date via the

[PG_uptodate](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n103) flag using the generated \_\_SetPageUptodate helper function.

Next we handle updating the PTE and perform the remaining

housekeeping tasks. We start by acquiring the PTE table lock via

[pte_offset_map_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2302) which is held in preparation for updating the PTE en-try.

Examining the remaining logic as shown in Listing 6-44.

 

3148 **if** (**likely**(**pte_same**(\*vmf-\>pte, vmf-\>orig_pte))) { 3149 **if** (old_page) { 3150 **if** (!**PageAnon**(old_page)) { 3151 **dec_mm_counter_fast**(mm, 3152 **mm_counter_file**(old_page)); 3153 **inc_mm_counter_fast**(mm, **MM_ANONPAGES**); 3154 } 3155 } **else** {

3156 **inc_mm_counter_fast**(mm, **MM_ANONPAGES**); 3157 }

 



 

3158 **flush_cache_page**(vma, vmf-\>address, **pte_pfn**(vmf-\>orig_pte)); 3159 entry = **mk_pte**(new_page, vma-\>vm_page_prot); 3160 entry = **pte_sw_mkyoung**(entry); 3161 **if** (**unlikely**(unshare)) { 3162 **if** (**pte_soft_dirty**(vmf-\>orig_pte)) 3163 entry = **pte_mksoft_dirty**(entry);

. . .

3166 } **else** {

3167 entry = **maybe_mkwrite**(**pte_mkdirty**(entry), vma); 3168 }

3169

3170 */\**

3171 *\* Clear the pte entry and flush it first, before updating the*

3172 *\* pte with the new entry, to keep TLBs on different CPUs in*

3173 *\* sync. This code used to set the new PTE then flush TLBs,*

*but*

3174 *\* that left a window where the new PTE could be loaded into*

3175 *\* some TLBs while the old PTE remains in others.* 3176 *\*/*

3177 **ptep_clear_flush_notify**(vma, vmf-\>address, vmf-\>pte); 3178 **page_add_new_anon_rmap**(new_page, vma, vmf-\>address); 3179 **lru_cache_add_inactive_or_unevictable**(new_page, vma); 3180 */\**

3181 *\* We call the notify macro here because, when using secondary*

3182 *\* mmu page tables (such as kvm shadow page tables), we want*

*the*

3183 *\* new page to be mapped directly into the secondary page*

*table.*

3184 *\*/*

3185 **BUG_ON**(unshare && **pte_write**(entry)); 3186 **set_pte_at_notify**(mm, vmf-\>address, vmf-\>pte, entry); 3187 **update_mmu_cache**(vma, vmf-\>address, vmf-\>pte); 3188 **if** (old_page) { 3189 */\** 3190 *\* Only after switching the pte to the new page may*

3191 *\* we remove the mapcount here. Otherwise another* 3192 *\* process may come and find the rmap count*

*decremented*

3193 *\* before the pte is switched to the new page, and*

3194 *\* "reuse" the old page writing into it while our pte*

3195 *\* here still points into it and can be read by other*

3196 *\* threads.* 3197 *\** 3198 *\* The critical issue is to order this* 3199 *\* page_remove_rmap with the ptp_clear_flush above.*

3200 *\* Those stores are ordered by (if nothing else,)* 3201 *\* the barrier present in the atomic_add_negative*

 



 

3202 *\* in page_remove_rmap.* 3203 *\** 3204 *\* Then the TLB flush in ptep_clear_flush ensures that*

3205 *\* no process can access the old page before the* 3206 *\* decremented mapcount is visible. And the old page*

3207 *\* cannot be reused until after the decremented* 3208 *\* mapcount is visible. So transitively, TLBs to* 3209 *\* old page will be flushed before it can be reused.*

3210 *\*/* 3211 **page_remove_rmap**(old_page, vma, **false**); 3212 }

3213

3214 */\* Free the old page.. \*/* 3215 new_page = old_page; 3216 page_copied = 1; 3217 } **else** {

3218 **update_mmu_tlb**(vma, vmf-\>address, vmf-\>pte); 3219 }

3220

3221 **if** (new_page)

3222 **put_page**(new_page); 3223

3224 **pte_unmap_unlock**(vmf-\>pte, vmf-\>ptl);

. . .

3230 **if** (old_page) {

3231 **if** (page_copied) 3232 **free_swap_cache**(old_page); 3233 **put_page**(old_page); 3234 }

. . .

3237 **return** (page_copied && !unshare) ? **VM_FAULT_WRITE** : 0; 3238 **oom_free_new**:

3239 **put_page**(new_page); 3240 **oom**:

3241 **if** (old_page)

3242 **put_page**(old_page);

. . .

3245 **return VM_FAULT_OOM**; 3246 }

 

*Listing 6-44:* mm/memory.c: [*wp_page_copy()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3090) *PTE update, housekeeping*

 

Given that we previously dropped the PTE page table lock and have only

just reacquired, we need to check that the PTE has not changed from be-neath us. If not, then we proceed to set up the PTE, starting by updating statistics.

 



 

On x86-64 we do not need to flush the cache manually so

flush_cache_page() and related functions are no-ops which we needn’t con-

sider, equally pte_mksoft_dirty() is not relevant.

If we aren’t simply unsharing a mapping, we mark it dirty via

[pte_mkdirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n328) and set writable by [maybe_mkwrite()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n977) if the VMA has its [VM_WRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n267)

flag set as in other fault handlers.

Next we reach more nuanced logic. We are in the awkward situation

where we are updating which physical address an existing virtual mapping

points to. This means that CPUs might each individually possess a cached

mapping between the virtual address and old physical address in their TLB

cache, so we have to be very careful to ensure that the change in mapping is

updated coherently across the system.

We start by invoking [ptep_clear_flush_notify()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmu_notifier.h?h=v6.0#n588) – since MMU notification

is out of scope for the book, we consider only [ptep_clear_flush()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/pgtable-generic.c?h=v6.0#n91) which is

called in turn by ptep_clear_flush_notify() as shown in Listing 6-45.

 

91 **pte_t ptep_clear_flush**(**struct** vm_area_struct \*vma, **unsigned long** address,

92 **pte_t** \*ptep)

93 {

94 **struct** mm_struct \*mm = (vma)-\>vm_mm;

95 **pte_t** pte;

96 pte = **ptep_get_and_clear**(mm, address, ptep);

97 **if** (**pte_accessible**(mm, pte))

98 **flush_tlb_page**(vma, address);

99 **return** pte;

100 }

 

*Listing 6-45:* mm/pgtable-generic.c: [*ptep_clear_flush()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/pgtable-generic.c?h=v6.0#n91)

 

This clears the PTE via [ptep_get_and_clear()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1048) which retrieves the previous

PTE entry before zeroing the entry and returns what was previously there.

We then determine whether the PTE was accessible in the first place (i.e.

might be present in a TLB at all) via [pte_accessible()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n747) as shown in Listing 6-

46.

 

747 **static inline bool pte_accessible**(**struct** mm_struct \*mm, **pte_t** a) 748 {

749 **if** (**pte_flags**(a) & **\_PAGE_PRESENT**) 750 **return true**;

751

752 **if** ((**pte_flags**(a) & **\_PAGE_PROTNONE**) && 753 **atomic_read**(&mm-\>tlb_flush_pending)) 754 **return true**;

755

756 **return false**;

757 }

 

*Listing 6-46:* arch/x86/include/asm/pgtable.h: [*pte_accessible()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n747)

 



 

If the PTE entry was marked present, or if it had the [\_PAGE_PROTNONE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n120)

page table flag set and a flush was pending as determined by

[struct mm_struct-\>tlb_flush_pending](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) (i.e. a mapping undergoing NUMA re-balancing requiring a flush, see the NUMA chapter for more on that), then it is deemed accessible.

Finally, if we do need to flush the TLB cache for this entry, we do this via

[flush_tlb_page(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/tlbflush.h?h=v6.0#n238)the mechanism of which we discuss in detail in section 7.1.

Once this operation is complete any other CPU which attempts to access

this memory will trigger a page fault and end up racing with us, rather than accessing the inappropriate physical address.

This means that we can now simply set the PTE without concern for TLB

state, anything that races with us on this will either page fault as described above or receive the correct mapping, nothing is stale.

We proceed by adding the new anonymous folio to the reverse mapping

via [page_add_new_anon_rmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1262) (see section 7.0.12 for more on this) and add the

folio to the relevant LRU list via [lru_cache_add_inactive_or_unevictable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n503) in

order that it can be reclaimed (see section 11.7 for more on how the LRU lists function).

We set the PTE entry via [set_pte_at_notify()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmu_notifier.h?h=v6.0#n637), again as MMU notification

is out of scope for the book we won’t examine this aspect of the logic, but

note that this ultimately calls [set_pte_at()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1004) and [set_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n68) in turn.

Afterwards we have some careful logic around decrementing the copied-

from folio’s map count via [page_remove_rmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1429) – the reverse mapping logic

described in Chapter 7 might result in an inappropriate reuse of a visible folio. However this being placed after our clearing of the PTE entry avoids this issue.

Finally the new_page local variable is pointed at the old folio in order that

it has a reference decremented rather than the newly assigned page.

Once this is complete, we ultimately reduce the reference count to the

old folio by two both for the newly increment reference count and to ac-count for the removal of the underlying reference from this now-CoW’d mapping.

Otherwise, for example if the PTE has been changed from beneath us

(e.g. another page fault has raced with us and ‘won’), we decrement the ref-erence to the possibly newly allocated folio and the reference incremented source folio as necessary.

We additionally unlock the PTE page table lock, try free the swap cache

if the folio was indeed copied via [free_swap_cache()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n280), which checks whether this lacks a map count and tries to acquire a lock to do so (see the swap chap-ter for more on this).

Finally, if a page was copied and it was not an unshare operation, we indi-

cate so by returning [VM_FAULT_WRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n745)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n745)

 

**6.10 Stack expansion**

 

In [do_user_addr_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1220), if a [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) cannot be found which contains the faulting address, but one was found that sits above it

 



 

which possesses the [VM_GROWSDOWN](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n277) flag, then we invoke [expand_stack()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2553) to ex-

pand the stack.

In Linux, stacks automatically expand up to the maximum specified by

the stack size rlimit and this is the functionality which permits this. The

check is performed by [expand_stack()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2553). We examine the case where the stack

grows downwards, which is true of most modern architectures and certain of

x86-64.

This in turn invokes [expand_downwards()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2441) which is parameterised by the

faulting address and the VMA which sits above it (eliding out of scope huge

page, performance event tracking and debug logic) as shown in Listing 6-47.

 

2438 */\**

2439 *\* vma is the first one with address \< vma-\>vm_start. Have to extend vma.*

2440 *\*/*

2441 **int expand_downwards**(**struct** vm_area_struct \*vma, 2442 **unsigned long** address) 2443 {

2444 **struct** mm_struct \*mm = vma-\>vm_mm; 2445 **struct** vm_area_struct \*prev; 2446 **int** error = 0;

2447

2448 address &= **PAGE_MASK**; 2449 **if** (address \< **mmap_min_addr**) 2450 **return**-**EPERM**; 2451

2452 */\* Enforce stack_guard_gap \*/* 2453 prev = vma-\>vm_prev; 2454 */\* Check that both stack segments have the same anon_vma? \*/* 2455 **if** (prev && !(prev-\>vm_flags & **VM_GROWSDOWN**) && 2456 **vma_is_accessible**(prev)) { 2457 **if** (address - prev-\>vm_end \< **stack_guard_gap**) 2458 **return**-**ENOMEM**; 2459 }

2460

2461 */\* We must make sure the anon_vma is allocated. \*/* 2462 **if** (**unlikely**(**anon_vma_prepare**(vma))) 2463 **return**-**ENOMEM**; 2464

2465 */\**

2466 *\* vma-\>vm_start/vm_end cannot change under us because the caller* 2467 *\* is required to hold the mmap_lock in read mode. We need the* 2468 *\* anon_vma lock to serialize against concurrent expand_stacks.* 2469 *\*/*

2470 **anon_vma_lock_write**(vma-\>anon_vma); 2471

2472 */\* Somebody else might have raced and expanded it already \*/* 2473 **if** (address \< vma-\>vm_start) { 2474 **unsigned long** size, grow;

 



 

2475

2476 size = vma-\>vm_end - address; 2477 grow = (vma-\>vm_start - address) \>\> **PAGE_SHIFT**; 2478

2479 error = -**ENOMEM**; 2480 **if** (grow \<= vma-\>vm_pgoff) { 2481 error = **acct_stack_growth**(vma, size, grow); 2482 **if** (!error) { 2483 */\** 2484 *\* vma_gap_update() doesn't support concurrent*

2485 *\* updates, but we only hold a shared*

*mmap_lock*

2486 *\* lock here, so we need to protect against*

2487 *\* concurrent vma expansions.* 2488 *\* anon_vma_lock_write() doesn't help here, as*

2489 *\* we don't guarantee that all growable vmas*

2490 *\* in a mm share the same root anon vma.* 2491 *\* So, we reuse mm-\>page_table_lock to guard*

2492 *\* against concurrent vma expansions.* 2493 *\*/* 2494 **spin_lock**(&mm-\>page_table_lock); 2495 **if** (vma-\>vm_flags & **VM_LOCKED**) 2496 mm-\>locked_vm += grow; 2497 **vm_stat_account**(mm, vma-\>vm_flags, grow); 2498 **anon_vma_interval_tree_pre_update_vma**(vma); 2499 vma-\>vm_start = address; 2500 vma-\>vm_pgoff -= grow; 2501 **anon_vma_interval_tree_post_update_vma**(vma); 2502 **vma_gap_update**(vma); 2503 **spin_unlock**(&mm-\>page_table_lock);

. . .

2506 } 2507 }

2508 }

2509 **anon_vma_unlock_write**(vma-\>anon_vma);

. . .

2512 **return** error;

2513 }

 

*Listing 6-47:* mm/mmap.c: [*expand_downwards()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2441)

 

We start by examining the nearest VMA beneath the stack VMA and,

if accessible (as determined by [vma_is_accessible()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n659)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n659) which simply checks

whether either [VM_READ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n266)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n266) [VM_WRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n267), or [VM_EXEC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n268) are set), checks to ensure that

the end of that VMA sits at least [stack_guard_gap](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2516) bytes below this one (this defaults to 256 base pages, which for an architecture with 4 KiB pages is 1 MiB below, but can be adjusted via the kernel command line parameter stack_guard_gap).

 



 

We then ensure that a [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) object is assigned to the VMA. We then must perform some intricate lock negotiation in order to pre-

vent concurrent updates – write-locking the anon_vma to prevent concurrent

stack expansion before re-checking that the VMA has not already been up-

dated.

If it has not, then we first check to see if the required growth of the stack

is less than or equal to the virtual page offset of the VMA vm_pgoff – if it was

larger then the start address would fall below zero.

Next, we perform checks to ensure that the stack expansion is permitted,

via [acct_stack_growth()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2312)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2312) which we will examine shortly.

If this is permitted, we then perform another intricate bit of lock wiz-

ardly by bizarrely acquiring the [struct mm_struct-\>page_table_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486). This is re-

quired because we update the VMA gap (as discussed in section 5.1) which

cannot be permitted to occur concurrently with other racing faults which

also hold the read lock on the mm_struct-\>mmap_lock semaphore. See section

4.3.4.1 for more on process address space locking.

If the VMA has the [VM_LOCKED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n282) flag set, indicating that all future alloca-

tions should be automatically mlocked, i.e. pinned in memory (specified via

[mlockall()](https://man7.org/linux/man-pages/man2/mlockall.2.html) with the MCL_FUTURE flag set or via MAP_LOCKED on [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html)[),](https://man7.org/linux/man-pages/man2/mmap.2.html) then we

update the mm_struct-\>locked_vm statistic appropriately.

We update the mm_struct-\>stack_vm and mm_struct-\>total_vm statistics via

[vm_stat_account()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n3277) before performing reverse mapping housekeeping (see

## Chapter 7) – removing references in the [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31)[-r](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31)ooted interval trees

referencing the VMA via the VMA’s [struct anon_vma_chain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82) glue objects using

[anon_vma_interval_tree_pre_update_vma().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n471)

This is needed because the entries in this tree are keyed by the VMA’s

vm_pgoff field which we are about to update.

We then adjust the vm_start and vm_pgoff fields to place the faulting ad-

dress within the realm of the VMA, before reestablishing the reverse map-

ping via [anon_vma_interval_tree_post_update_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n480).

The VMA has its subtree gap calculation updated via [vma_gap_update()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n404)

after which the page_table_lock is released as it is no longer required. Finally

the anon_vma lock is released and the operation is complete.

Returning to [acct_stack_growth()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2312) (eliding huge page logic) as shown in

Listing 6-48.

 

2307 */\**

2308 *\* Verify that the stack growth is acceptable and* 2309 *\* update accounting. This is shared with both the* 2310 *\* grow-up and grow-down cases.* 2311 *\*/*

2312 **static int acct_stack_growth**(**struct** vm_area_struct \*vma, 2313 **unsigned long** size, **unsigned long** grow) 2314 {

2315 **struct** mm_struct \*mm = vma-\>vm_mm; 2316 **unsigned long** new_start; 2317

2318 */\* address space limit tests \*/*

 



 

2319 **if** (!**may_expand_vm**(mm, vma-\>vm_flags, grow)) 2320 **return**-**ENOMEM**; 2321

2322 */\* Stack limit test \*/* 2323 **if** (size \> **rlimit**(**RLIMIT_STACK**)) 2324 **return**-**ENOMEM**; 2325

2326 */\* mlock limit tests \*/* 2327 **if** (**mlock_future_check**(mm, vma-\>vm_flags, grow \<\< **PAGE_SHIFT**)) 2328 **return**-**ENOMEM**;

. . .

2336 */\**

2337 *\* Overcommit.. This must be the final test, as it will* 2338 *\* update security statistics.* 2339 *\*/*

2340 **if** (**security_vm_enough_memory_mm**(mm, grow)) 2341 **return**-**ENOMEM**; 2342

2343 **return** 0;

2344 }

 

*Listing 6-48:* mm/mmap.c: [*acct_stack_growth()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2312)

The first check is whether the address space limit RLIMIT_AS and data seg-

ment limit RLIMIT_DATA are being observed via [may_expand_vm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n3252)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n3252)

Net, we explicitly ensure that the stack is not growing beyond the max-

imum permissible stack size as specified by RLIMIT_STACK, before checking

if RLIMIT_MEMLOCK is exceeded, if applicable via [mlock_future_check()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1317) (relevant

when [mlockall()](https://man7.org/linux/man-pages/man2/mlockall.2.html) has been called for the process with the MCL_FUTURE flag set).

Finally, [security_vm_enough_memory_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/security/security.c?h=v6.0#n830) is called to ensure that we do not

exceed available memory depending on overcommit mode (see section 4.1) as well as performing any existing security hook checks.

 

**6.11 Userland bad area handling**

 

All accesses to incorrect areas of the address space in userland end up

invoking [\_\_bad_area_nosemaphore()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n800)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n800) whether invoked directly or from

[bad_area_nosemaphore(),](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n852) [\_\_bad_area()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n859) or [bad_area()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n873).

Examining this function, eliding kernel handling as shown in Listing 6-

49.

 

799 **static void**

800 **\_\_bad_area_nosemaphore**(**struct** pt_regs \*regs, **unsigned long** error_code, 801 **unsigned long** address, **u32** pkey, **int** si_code) 802 {

803 **struct** task_struct \*tsk = current;

. . .

811 **if** (!(error_code & **X86_PF_USER**)) { 812 */\* Implicit user access to kernel memory -- just oops \*/*

 



 

813 **page_fault_oops**(regs, error_code, address); 814 **return**;

815 }

816

817 */\**

818 *\* User mode accesses just cause a SIGSEGV.* 819 *\* It's possible to have interrupts off here:* 820 *\*/*

821 **local_irq_enable**();

822

823 */\**

824 *\* Valid to do another page fault here because this one came* 825 *\* from user space:* 826 *\*/*

827 **if** (**is_prefetch**(regs, error_code, address)) 828 **return**;

829

830 **if** (**is_errata100**(regs, address)) 831 **return**;

832

833 **sanitize_error_code**(address, &error_code);

834

835 **if** (**fixup_vdso_exception**(regs, X86_TRAP_PF, error_code, address)) 836 **return**;

837

838 **if** (**likely**(**show_unhandled_signals**)) 839 **show_signal_msg**(regs, error_code, address, tsk);

840

841 **set_signal_archinfo**(address, error_code);

842

843 **if** (si_code == **SEGV_PKUERR**) 844 **force_sig_pkuerr**((**void \_\_user** \*)address, pkey); 845 **else**

846 **force_sig_fault**(**SIGSEGV**, si_code, (**void \_\_user** \*)address);

847

848 **local_irq_disable**(); 849 }

 

*Listing 6-49:* arch/x86/mm/fault.c: *x86-64 [\_\_bad_area_nosemaphore()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n800) userland*

*handling*

 

We start by considering an edge case – a kernel-mode fault but from a

process with userland registers and at a userland address – this is specif-

ically to handle a new (at the time of writing) feature from intel – CET –

which provides security mitigations using a shadow userland stack (see

[x86/fault: \#PF improvements, mostly related to USER bit](https://lore.kernel.org/all/cover.1612924255.git.luto@kernel.org/) for more on this). In

this case we just trigger an oops via [page_fault_oops()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n632).

We make sure for the rest of the handling to enable local IRQ handling

as there is now no reason for this these to be suppressed. We then check

 



 

two very specific cases – was this a fault that arose from the CPU prefetching

memory? This is checked in [is_prefetch()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n121) and is this an ancient AMD K8

processor with a very specific errata as checked by [is_errata100()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n452)? In either case we simply exit and can refault if necessary.

The reported error is adjusted to avoid leaking information about

kernel page tables in case of user mode access to kernel addresses via

[sanitize_error_code()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n605) as shown in Listing 6-50.

 

605 **static void sanitize_error_code**(**unsigned long** address, 606 **unsigned long** \*error_code) 607 {

608 */\**

609 *\* To avoid leaking information about the kernel page* 610 *\* table layout, pretend that user-mode accesses to* 611 *\* kernel addresses are always protection faults.* 612 *\**

613 *\* NB: This means that failed vsyscalls with vsyscall=none* 614 *\* will have the PROT bit. This doesn't leak any* 615 *\* information and does not appear to cause any problems.* 616 *\*/*

617 **if** (address \>= **TASK_SIZE_MAX**) 618 \*error_code \|= **X86_PF_PROT**; 619 }

 

*Listing 6-50:* arch/x86/mm/fault.c: [*sanitize_error_code()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n605)

 

We check whether we need to perform a fixup for VDSO via

[fixup_vdso_exception(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/entry/vdso/extable.c?h=v6.0#n12)a mechanism by which certain system calls can use memory shared between the kernel and userland to improve performance. Discussion of this is out of scope for the book.

If unhandled segfaults are set to be displayed in the kernel log via

[show_unhandled_signals, ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1073)then this is output via [show_signal_msg()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n768), an output

many programmers will be familiar with as shown in Listing 6-51.

 

763 */\**

764 *\* Print out info about fatal segfaults, if the show_unhandled_signals* 765 *\* sysctl is set:*

766 *\*/*

767 **static inline void**

768 **show_signal_msg**(**struct** pt_regs \*regs, **unsigned long** error_code, 769 **unsigned long** address, **struct** task_struct \*tsk) 770 {

771 **const char** \*loglvl = **task_pid_nr**(tsk) \> 1 ? **KERN_INFO** : **KERN_EMERG**; 772

773 **if** (!**unhandled_signal**(tsk, **SIGSEGV**)) 774 **return**;

775

776 **if** (!**printk_ratelimit**()) 777 **return**;

 



 

778

779 **printk**("%s%s\[%d\]: segfault at %lx ip %px sp %px error %lx", 780 loglvl, tsk-\>comm, **task_pid_nr**(tsk), address, 781 (**void** \*)regs-\>ip, (**void** \*)regs-\>sp, error_code);

782

783 **print_vma_addr**(**KERN_CONT** " in ", regs-\>ip);

784

785 **printk**(**KERN_CONT** "\n");

786

787 **show_opcodes**(regs, loglvl); 788 }

 

*Listing 6-51:* arch/x86/mm/fault.c: [*show_signal_msg()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n768)

The architecture-specific [struct thread_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/processor.h?h=v6.0#n469) object contained in the pro-

cess’s [struct task_sched](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727)-\>thread field is updated by [set_signal_archinfo()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n621)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n621) stor-

ing the error code and faulting address.

The signal is then transmitted to the userland process via either

[force_sig_pkuerr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/signal.c?h=v6.0#n1792) if the error arose due to protection keys (a topic which

is out of scope for the book) or [force_sig_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/signal.c?h=v6.0#n1722) for a standard SIGSEGV fault.

Finally, local IRQs are disabled as the fault handling expects them to be

when this function is completed.

 

**6.12 Special mappings**

 

Some userland mappings are deemed ‘special’, defined by there being no

[struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) (and thus no [struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) object) to describe the underlying phys-

ical memory range. These might actually exist, but it might not be desired

that the usual reference count mechanisms be applied to them (e.g. kernel

memory mapped into userland).

For modern architectures a user-definable page table flag is used to des-

ignate a mapping as being special – for x86-64 this flag is [\_PAGE_SPECIAL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n55)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n55) This

makes checking for this simple in [pte_special()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n177).

There are broadly two forms of special mappings, characterised by their

mutually exclusive [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) flags – [VM_PFNMAP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n279)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n279) which

represents a linear mapping between virtual addresses and PFNs, and

[VM_MIXEDMAP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n306), which represents a range that can mix mappings that are PFN-

only and those with describing folios.

The [vm_normal_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n612) function is used to obtain a page object for at a spe-

cific address within a specific VMA, examining this (eliding out of scope de-

vmap logic and logic for architectures that do not support a special mapping

page table flag) as shown in Listing 6-52.

 

570 */\**

571 *\* vm_normal_page -- This function gets the "struct page" associated with a*

*pte.*

572 *\**

573 *\* "Special" mappings do not wish to be associated with a "struct page" (*

*either*

 



 

574 *\* it doesn't exist, or it exists but they don't want to touch it). In this*

575 *\* case, NULL is returned here. "Normal" mappings do have a struct page.* 576 *\**

577 *\* There are 2 broad cases. Firstly, an architecture may define a pte_special*

*()*

578 *\* pte bit, in which case this function is trivial. Secondly, an architecture*

579 *\* may not have a spare pte bit, which requires a more complicated scheme,*

580 *\* described below.*

581 *\**

582 *\* A raw VM_PFNMAP mapping (ie. one that is not COWed) is always considered a*

583 *\* special mapping (even if there are underlying and valid "struct pages").*

584 *\* COWed pages of a VM_PFNMAP are always normal.* 585 *\**

586 *\* The way we recognize COWed pages within VM_PFNMAP mappings is through the*

587 *\* rules set up by "remap_pfn_range()": the vma will have the VM_PFNMAP bit*

588 *\* set, and the vm_pgoff will point to the first PFN mapped: thus every*

*special*

589 *\* mapping will always honor the rule* 590 *\**

591 *\** *pfn_of_page == vma-\>vm_pgoff + ((addr - vma-\>vm_start) \>\> PAGE_SHIFT)* 592 *\**

593 *\* And for normal mappings this is false.* 594 *\**

595 *\* This restricts such mappings to be a linear translation from virtual*

*address*

596 *\* to pfn. To get around this restriction, we allow arbitrary mappings so long*

597 *\* as the vma is not a COW mapping; in that case, we know that all ptes are*

598 *\* special (because none can have been COWed).* 599 *\**

600 *\**

601 *\* In order to support COW of arbitrary special mappings, we have VM_MIXEDMAP.*

602 *\**

603 *\* VM_MIXEDMAP mappings can likewise contain memory with or without "struct*

604 *\* page" backing, however the difference is that \_all\_ pages with a struct*

605 *\* page (that is, those where pfn_valid is true) are refcounted and considered*

606 *\* normal pages by the VM. The disadvantage is that pages are refcounted* 607 *\* (which can be slower and simply not an option for some PFNMAP users). The*

608 *\* advantage is that we don't have to follow the strict linearity rule of*

609 *\* PFNMAP mappings in order to support COWable mappings.* 610 *\**

611 *\*/*

612 **struct** page \***vm_normal_page**(**struct** vm_area_struct \*vma, **unsigned long** addr, 613 **pte_t** pte) 614 {

615 **unsigned long** pfn = **pte_pfn**(pte); 616

617 **if** (**IS_ENABLED**(**CONFIG_ARCH_HAS_PTE_SPECIAL**)) {

 



 

618 **if** (**likely**(!**pte_special**(pte))) 619 **goto check_pfn**; 620 **if** (vma-\>vm_ops && vma-\>vm_ops-\>**find_special_page**) 621 **return** vma-\>vm_ops-\>**find_special_page**(vma, addr); 622 **if** (vma-\>vm_flags & (**VM_PFNMAP** \| **VM_MIXEDMAP**)) 623 **return NULL**; 624 **if** (**is_zero_pfn**(pfn)) 625 **return NULL**;

. . .

637 **print_bad_pte**(vma, addr, pte, **NULL**); 638 **return NULL**; 639 }

. . .

661 **check_pfn**:

662 **if** (**unlikely**(pfn \> **highest_memmap_pfn**)) { 663 **print_bad_pte**(vma, addr, pte, **NULL**); 664 **return NULL**; 665 }

666

667 */\**

668 *\* NOTE! We still have PageReserved() pages in the page tables.* 669 *\* eg. VDSO mappings can cause them to exist.* 670 *\*/*

671 **out**:

672 **return pfn_to_page**(pfn); 673 }

 

*Listing 6-52:* mm/memory.c: [*vm_normal_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n612)

 

This will return NULL in the case of the zero page or special mappings ex-

cept when a VMA’s [struct vm_operations_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n539) vm_ops-\>find_special_page han-

dler is provided. This is only used in one place (within the xen driver, which

is a virtualisation framework), so this is unlikely to be the case.

The [VM_MIXEDMAP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n306) variant of this permits insertion of individual pages into

an existing VMA via [vm_insert_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1976) for multiple pages and [vm_insert_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2035)

for individual ones. A simpler interface for this is [vm_map_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2105). Non-page

entries can be mapped as part of a page fault handler via [vmf_insert_mixed()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2354).

We will not examine VM_MIXEDMAP mappings in detail, as it is out of scope

for the book, however it is important to be aware such mappings exist and

are used for mapping kernel or device memory to userland.

The [VM_PFNMAP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n279) approach is the simpler of the two primary forms of

special mappings, typically used to simply map ranges of kernel mem-

ory into userland, typically via [remap_pfn_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2540)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2540) which ultimately invokes

[remap_pfn_range_notrack()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2475) to do the heavy lifting as shown in Listing 6-53.

 

2471 */\**

2472 *\* Variant of remap_pfn_range that does not call track_pfn_remap. The caller*

2473 *\* must have pre-validated the caching bits of the pgprot_t.* 2474 *\*/*

 



 

2475 **int remap_pfn_range_notrack**(**struct** vm_area_struct \*vma, **unsigned long** addr, 2476 **unsigned long** pfn, **unsigned long** size, **pgprot_t** prot) 2477 {

2478 **pgd_t** \*pgd;

2479 **unsigned long** next; 2480 **unsigned long** end = addr + **PAGE_ALIGN**(size); 2481 **struct** mm_struct \*mm = vma-\>vm_mm; 2482 **int** err;

2483

2484 **if** (**WARN_ON_ONCE**(!**PAGE_ALIGNED**(addr))) 2485 **return**-**EINVAL**; 2486

2487 */\**

2488 *\* Physically remapped pages are special. Tell the* 2489 *\* rest of the world about it:* 2490 *\** *VM_IO tells people not to look at these pages* 2491 *\** *(accesses can have side effects).* 2492 *\** *VM_PFNMAP tells the core MM that the base pages are just* 2493 *\** *raw PFN mappings, and do not have a "struct page" associated* 2494 *\** *with them.* 2495 *\** *VM_DONTEXPAND* 2496 *\** *Disable vma merging and expanding with mremap().* 2497 *\** *VM_DONTDUMP*

2498 *\** *Omit vma from core dump, even when VM_IO turned off.* 2499 *\**

2500 *\* There's a horrible special case to handle copy-on-write* 2501 *\* behaviour that some programs depend on. We mark the "original"*

2502 *\* un-COW'ed pages by matching them up with "vma-\>vm_pgoff".* 2503 *\* See vm_normal_page() for details.* 2504 *\*/*

2505 **if** (**is_cow_mapping**(vma-\>vm_flags)) { 2506 **if** (addr != vma-\>vm_start \|\| end != vma-\>vm_end) 2507 **return**-**EINVAL**; 2508 vma-\>vm_pgoff = pfn; 2509 }

2510

2511 vma-\>vm_flags \|= **VM_IO** \| **VM_PFNMAP** \| **VM_DONTEXPAND** \| **VM_DONTDUMP**; 2512

2513 **BUG_ON**(addr \>= end); 2514 pfn -= addr \>\> **PAGE_SHIFT**; 2515 pgd = **pgd_offset**(mm, addr); 2516 **flush_cache_range**(vma, addr, end); 2517 **do** {

2518 next = **pgd_addr_end**(addr, end); 2519 err = **remap_p4d_range**(mm, pgd, addr, next, 2520 pfn + (addr \>\> **PAGE_SHIFT**), prot); 2521 **if** (err)

 



 

2522 **return** err; 2523 } **while** (pgd++, addr = next, addr != end); 2524

2525 **return** 0;

2526 }

 

*Listing 6-53:* mm/memory.c: [*remap_pfn_range_notrack()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2475)

 

This walks the page tables of the userland mappings, allocating where

necessary, placing the specified kernel PFN in the PTE in [remap_pte_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2378)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2378)

Note that the vm_pgoff is set to the PFN of the beginning of the range if this

is a Copy On Write mapping. This is required for architectures that do not

have a special PTE flag so have to differentiate using this to identify the orig-

inal mapping.

When a Copy on Write fault occurs for a Copy on Write mapping (i.e.

not shared), this operation is handled by [\_\_wp_page_copy_user()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2844) (eliding logic

for architectures that don’t have hardware accessed bits) as shown in Listing

6-54.

 

2844 **static inline bool \_\_wp_page_copy_user**(**struct** page \*dst, **struct** page \*src, 2845 **struct** vm_fault \*vmf) 2846 {

2847 **bool** ret;

2848 **void** \*kaddr;

2849 **void \_\_user** \*uaddr; 2850 **bool** locked = **false**; 2851 **struct** vm_area_struct \*vma = vmf-\>vma; 2852 **struct** mm_struct \*mm = vma-\>vm_mm; 2853 **unsigned long** addr = vmf-\>address; 2854

2855 **if** (**likely**(src)) { 2856 **copy_user_highpage**(dst, src, addr, vma); 2857 **return true**; 2858 }

2859

2860 */\**

2861 *\* If the source page was a PFN mapping, we don't have* 2862 *\* a "struct page" for it. We do a best-effort copy by* 2863 *\* just copying from the original user address. If that* 2864 *\* fails, we just zero-fill it. Live with it.* 2865 *\*/*

2866 kaddr = **kmap_atomic**(dst); 2867 uaddr = (**void \_\_user** \*)(addr & **PAGE_MASK**);

. . .

2893 */\**

2894 *\* This really shouldn't fail, because the page is there* 2895 *\* in the page tables. But it might just be unreadable,* 2896 *\* in which case we just give up and fill the result with* 2897 *\* zeroes.*

 



 

2898 *\*/*

2899 **if** (**\_\_copy_from_user_inatomic**(kaddr, uaddr, **PAGE_SIZE**)) { 2900 **if** (locked) 2901 **goto warn**; 2902

2903 */\* Re-validate under PTL if the page is still mapped \*/* 2904 vmf-\>pte = **pte_offset_map_lock**(mm, vmf-\>pmd, addr, &vmf-\>ptl); 2905 locked = **true**; 2906 **if** (!**likely**(**pte_same**(\*vmf-\>pte, vmf-\>orig_pte))) { 2907 */\* The PTE changed under us, update local tlb \*/* 2908 **update_mmu_tlb**(vma, addr, vmf-\>pte); 2909 ret = **false**; 2910 **goto pte_unlock**; 2911 }

2912

2913 */\**

2914 *\* The same page can be mapped back since last copy attempt.*

2915 *\* Try to copy again under PTL.* 2916 *\*/*

2917 **if** (**\_\_copy_from_user_inatomic**(kaddr, uaddr, **PAGE_SIZE**)) { 2918 */\** 2919 *\* Give a warn in case there can be some obscure* 2920 *\* use-case* 2921 *\*/* 2922 **warn**:

2923 **WARN_ON_ONCE**(1); 2924 **clear_page**(kaddr); 2925 }

2926 }

2927

2928 ret = **true**;

2929

2930 **pte_unlock**:

2931 **if** (locked)

2932 **pte_unmap_unlock**(vmf-\>pte, vmf-\>ptl); 2933 **kunmap_atomic**(kaddr); 2934 **flush_dcache_page**(dst); 2935

2936 **return** ret;

2937 }

 

*Listing 6-54:* mm/memory.c: [*\_\_wp_page_copy_user()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2844)

 

This is also used for non-special mapping copying, however this is a triv-

ial case handled by [copy_user_highpage()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/highmem.h?h=v6.0#n306), with the rest of the logic dedicated to special mappings.

In order to perform the Copy On Write, the kernel simply copies from

the source page using its userland mapping (which will have the appropriate

 



 

PFN set) into the newly allocated page via [\_\_copy_from_user_inatomic()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/uaccess.h?h=v6.0#n59), which

is an unsafe version of the usual copy_from_user() function (see section 8.1.1

for more on this).

If the copy fails, we try again until PTE page table lock, if this fails we

simply clear the target page.

We have moved quickly through this topic as, while it’s useful to be aware

of these types of mappings and how they’re handled on page fault, the intri-

cate details of how these are used sit outside the scope of the book.

 

