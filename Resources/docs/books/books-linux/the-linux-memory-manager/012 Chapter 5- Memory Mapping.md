**M E M O R Y M A P P I N G**

 

As explored in Chapter 3 on Virtual Memory, a key ca-

pacity of a modern operating system is the ability to

map virtual memory as it pleases and with which the

properties it desires. Doing so is termed memory map-

ping, a topic we explore in detail here.

Examining the layout of a process in memory as shown in Figure 5-1.


 

Stack

 

Program break

Heap

 

.bss

.data

.rodata

Virtual

.text

address

 

*Figure 5-1: Simplified ELF image layout in memory*

There are two principle means by which a process such as this allocates

memory – the [brk()](https://man7.org/linux/man-pages/man2/brk.2.html) system call and the [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) system call.

The code of the process is stored in the .text segment, read-only static

data in .rodata, initialised static data in .data and uninitialised data in .bss.

Any non-trivial program requires dynamically allocated memory, which

comes in two forms – the automatically expanding **stack**, an area of memory that for most architectures grows downwards (including x86-64). Expansion and contraction of the stack happens automatically by page fault (see section

6.10) without the program author having to do anything explicitly\*.

However, if memory is required that is too large for the stack or if its life-

time extends beyond that of the currently running function it must be allo-cated from the **heap**.

The two main functions that a programmer will be familiar with for allo-

cating from the heap are [malloc()](https://man7.org/linux/man-pages/man2/malloc.2.html) and [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html), and more so the former of the two.

 

***5.0.1 Program break***

The classic means of expanding the dynamic memory used by a process is to expand the program break. This begins at (and is initialised to) the upper bound of the .bss section, and represents the portion of process memory referred to as the heap.

The [malloc()](https://man7.org/linux/man-pages/man2/malloc.2.html) allocator expands and shrinks this region in response to

userland allocation requests which is typically used for smaller allocations,

with larger ones deferred to [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html)[.](https://man7.org/linux/man-pages/man2/mmap.2.html)

 

\*. Although it may manipulated at runtime via Variable Length Arrays (VLAs) or the use of [alloca()](https://man7.org/linux/man-pages/man2/alloca.2.html) functions like .



 

The program break is typically manipulated by the standard C library

function [sbrk()](https://man7.org/linux/man-pages/man2/sbrk.2.html) which increments or decrements the program break by

the specified offset, with the current program break available by invoking

sbrk(0) . A less useful version of this is the brk() function which sets the pro-

gram break to a specific address.

Underlying both functions is the brk() system call which adjusts the pro-

gram break and adjusts VMAs to mark the new heap as valid. We examine it

in Listing 5-1.

 

153 **SYSCALL_DEFINE1**(brk, **unsigned long**, brk) 154 {

155 **unsigned long** newbrk, oldbrk, origbrk; 156 **struct** mm_struct \*mm = current-\>mm; 157 **struct** vm_area_struct \*next; 158 **unsigned long** min_brk; 159 **bool** populate;

160 **bool** downgraded = **false**; 161 **LIST_HEAD**(uf);

162

163 **if** (**mmap_write_lock_killable**(mm)) 164 **return**-**EINTR**;

165

166 origbrk = mm-\>brk;

. . .

179 min_brk = mm-\>start_brk;

. . .

181 **if** (brk \< min_brk) 182 **goto out**;

183

184 */\**

185 *\* Check against rlimit here. If this check is done later after the*

*test*

186 *\* of oldbrk with newbrk then it can escape the test and let the data*

187 *\* segment grow beyond its set limit the in case where the limit is*

188 *\* not page aligned -Ram Gupta* 189 *\*/*

190 **if** (**check_data_rlimit**(**rlimit**(**RLIMIT_DATA**), brk, mm-\>start_brk, 191 mm-\>end_data, mm-\>start_data)) 192 **goto out**;

193

194 newbrk = **PAGE_ALIGN**(brk); 195 oldbrk = **PAGE_ALIGN**(mm-\>brk); 196 **if** (oldbrk == newbrk) { 197 mm-\>brk = brk; 198 **goto success**; 199 }

200

201 */\**

 



 

202 *\* Always allow shrinking brk.* 203 *\* \_\_do_munmap() may downgrade mmap_lock to read.* 204 *\*/*

205 **if** (brk \<= mm-\>brk) { 206 **int** ret;

207

208 */\**

209 *\* mm-\>brk must to be protected by write mmap_lock so update*

*it*

210 *\* before downgrading mmap_lock. When \_\_do_munmap() fails,*

211 *\* mm-\>brk will be restored from origbrk.* 212 *\*/*

213 mm-\>brk = brk; 214 ret = **\_\_do_munmap**(mm, newbrk, oldbrk-newbrk, &uf, **true**); 215 **if** (ret \< 0) { 216 mm-\>brk = origbrk; 217 **goto out**; 218 } **else if** (ret == 1) { 219 downgraded = **true**; 220 }

221 **goto success**; 222 }

223

224 */\* Check against existing mmap mappings. \*/* 225 next = **find_vma**(mm, oldbrk); 226 **if** (next && newbrk + **PAGE_SIZE** \> **vm_start_gap**(next)) 227 **goto out**; 228

229 */\* Ok, looks good - let it rip. \*/* 230 **if** (**do_brk_flags**(oldbrk, newbrk-oldbrk, 0, &uf) \< 0) 231 **goto out**; 232 mm-\>brk = brk;

233

234 **success**:

235 populate = newbrk \> oldbrk && (mm-\>def_flags & **VM_LOCKED**) != 0; 236 **if** (downgraded)

237 **mmap_read_unlock**(mm); 238 **else**

239 **mmap_write_unlock**(mm); 240 **userfaultfd_unmap_complete**(mm, &uf); 241 **if** (populate)

242 **mm_populate**(oldbrk, newbrk - oldbrk); 243 **return** brk;

244

245 **out**:

246 **mmap_write_unlock**(mm); 247 **return** origbrk;

 



 

248 }

 

*Listing 5-1:* mm/mmap.c: *syscall: [brk()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n153)*

 

We acquire a write lock from the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)-\>mmap_lock semaphore

around the system call, as we are potentially manipulating VMAs.

We then perform a series of sanity checks – ensuring the requested pro-

gram break is not less than the beginning of the heap (mm-\>start_brk) and

that the [RLIMIT_DATA](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/asm-generic/resource.h?h=v6.0#n18) resource limit is not exceeded (via [check_data_rlimit()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2604)).

We page align the existing and candidate page break values, then per-

form a check for the simple case of the break remaining the same as it was.

After these preliminary checks are complete we are able to perform the ac-

tual operation:

 

• If the caller is attempting to shrink the program break, this always suc-

ceeds and utilises the shared [munmap()](https://man7.org/linux/man-pages/man2/munmap.2.html) code path via [\_\_do_munmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2754)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2754) This may downgrade the write mmap_lock to a read lock in doing so.

• Otherwise, we invoke the key VMA function [find_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2253) to find the

first VMA which follows or contains this address (if any) and check whether we leave at least a page between us and any following VMA via

[vm_start_gap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2758) (which takes into account the need for a stack guard gap if the next VMA grows downward), if not we abort.

• Finally we perform the actual program break adjustment via

[do_brk_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2973) which we examine in detail below.

 

After a successful program break adjustment has been performed we

perform some cleanup tasks and ‘populate’ (i.e. fault in) the memory range

via [mm_populate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2660) if the page break was extended, except if [mlockall()](https://man7.org/linux/man-pages/man2/mlockall.2.html) has

been invoked with the MCL_FUTURE flag set, indicating that all future memory

should be mlock’d and thus must be allowed to fault in when the memory is

used.

The core function which does the heavy lifting of page break extension is

[do_brk_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2973) as shown in Listing 5-2.

 

2968 */\**

2969 *\* this is really a simplified "do_mmap". it only handles* 2970 *\* anonymous maps. eventually we may be able to do some* 2971 *\* brk-specific accounting here.* 2972 *\*/*

2973 **static int do_brk_flags**(**unsigned long** addr, **unsigned long** len, **unsigned long**

flags, **struct** list_head \*uf)

2974 {

2975 **struct** mm_struct \*mm = current-\>mm; 2976 **struct** vm_area_struct \*vma, \*prev; 2977 **struct** rb_node \*\*rb_link, \*rb_parent; 2978 **pgoff_t** pgoff = addr \>\> **PAGE_SHIFT**; 2979 **int** error;

2980 **unsigned long** mapped_addr; 2981

 



 

2982 */\* Until we need other flags, refuse anything except VM_EXEC. \*/*

2983 **if** ((flags & (~**VM_EXEC**)) != 0) 2984 **return**-**EINVAL**; 2985 flags \|= **VM_DATA_DEFAULT_FLAGS** \| **VM_ACCOUNT** \| mm-\>def_flags; 2986

2987 mapped_addr = **get_unmapped_area**(**NULL**, addr, len, 0, **MAP_FIXED**); 2988 **if** (**IS_ERR_VALUE**(mapped_addr)) 2989 **return** mapped_addr; 2990

2991 error = **mlock_future_check**(mm, mm-\>def_flags, len); 2992 **if** (error)

2993 **return** error; 2994

2995 */\* Clear old maps, set up prev, rb_link, rb_parent, and uf \*/* 2996 **if** (**munmap_vma_range**(mm, addr, len, &prev, &rb_link, &rb_parent, uf)) 2997 **return**-**ENOMEM**; 2998

2999 */\* Check against address space limits \*after\* clearing old maps... \*/*

3000 **if** (!**may_expand_vm**(mm, flags, len \>\> **PAGE_SHIFT**)) 3001 **return**-**ENOMEM**; 3002

3003 **if** (mm-\>map_count \> **sysctl_max_map_count**) 3004 **return**-**ENOMEM**; 3005

3006 **if** (**security_vm_enough_memory_mm**(mm, len \>\> **PAGE_SHIFT**)) 3007 **return**-**ENOMEM**; 3008

3009 */\* Can we just expand an old private anonymous mapping? \*/* 3010 vma = **vma_merge**(mm, prev, addr, addr + len, flags, 3011 **NULL**, **NULL**, pgoff, **NULL**, **NULL_VM_UFFD_CTX**, **NULL**); 3012 **if** (vma)

3013 **goto out**; 3014

3015 */\**

3016 *\* create a vma struct for an anonymous mapping* 3017 *\*/*

3018 vma = **vm_area_alloc**(mm); 3019 **if** (!vma) {

3020 **vm_unacct_memory**(len \>\> **PAGE_SHIFT**); 3021 **return**-**ENOMEM**; 3022 }

3023

3024 **vma_set_anonymous**(vma); 3025 vma-\>vm_start = addr; 3026 vma-\>vm_end = addr + len; 3027 vma-\>vm_pgoff = pgoff; 3028 vma-\>vm_flags = flags;

 



 

3029 vma-\>vm_page_prot = **vm_get_page_prot**(flags); 3030 **vma_link**(mm, vma, prev, rb_link, rb_parent); 3031 **out**:

3032 **perf_event_mmap**(vma); 3033 mm-\>total_vm += len \>\> **PAGE_SHIFT**; 3034 mm-\>data_vm += len \>\> **PAGE_SHIFT**; 3035 **if** (flags & **VM_LOCKED**) 3036 mm-\>locked_vm += (len \>\> **PAGE_SHIFT**); 3037 vma-\>vm_flags \|= **VM_SOFTDIRTY**; 3038 **return** 0;

3039 }

 

*Listing 5-2:* mm/mmap.c: [*do_brk_flags()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2973)

In order to avoid duplication we’ll examine the logic here but not dive

too deep as the approach is broadly the same as mmap() and we will examine

the underlying details in section 5.0.2.

We start with a check – if the flags argument is set, only the VM_EXEC vmap

flag is valid. In the usual brk() system call code path this value is zero to 0 so

we can disregard this.

The flags are then defaulted to the default flags specified by

[struct mm_struct-\>def_flags](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) , [VM_ACCOUNT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n292) to indicate that the memory should

be accounted as being in use by the userland portion of this process, and

[VM_DATA_DEFAULT_FLAGS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_types.h?h=v6.0#n38) specifying the default flags set for all data pages.

For x86-64 this is aliased to [VM_DATA_FLAGS_TSK_EXEC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n380), which sets VM_READ,

VM_WRITE, VM_MAYREAD, VM_MAYWRITE, VM_MAYEXEC (it can, if the user specifies an exe-

cutable heap, be set to VM_EXEC but this would be unusual!).

We then perform the following steps:

 

1. Confirm that the memory we wish to expand the page break into is valid

by invoking [get_unmapped_area()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2209) (see section 5.0.5), specifying MAP_FIXED to indicate that only the specified address is acceptable. Note that on x86-64, despite the name of the function, it only checks that the size increase does not exceed the maximum permissible and performs no further checks, so the address may in fact be mapped (though performing a brk() system call this should not be the case as we have already asserted that the range is clear).

2. Check that we don’t exceed the RLIMIT_MEMLOCK limit if mlockall() has been

called with MCL_FUTURE set via [mlock_future_check()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1317).

3. Unmap all existing mappings in the range via [munmap_vma_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n556) – this

will have no effect for a brk() system call as we will have already asserted,

under lock, that no such mappings exist. However [vm_brk_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n3041), which

also invokes [do_brk_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2973), makes no such guarantees so this check is more pertinent to that caller.

4. Check we are permitted to expand our vm space based on the address

space limit RLIMIT_AS and the data limit RLIMIT_DATA via [may_expand_vm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n3252)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n3252)

5. Check that the total map count set by the vm.max_map_count tunable is not

exceeded.

 



 

6. Check to ensure we have sufficient memory and our mem-

ory usage does not violate any security rules in the system via

[security_vm_enough_memory_mm().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/security/security.c?h=v6.0#n830)

7. Attempt to simply expand a preceding or following VMA to encompass

the new area via [vma_merge()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1122).

8. If this is not possible, we allocate a new VMA via [vm_area_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n455), mark-

ing it anonymous via [vma_set_anonymous()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n624), setting its core flags and link-

ing it to surrounding VMAs via [vma_link()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n645).

 

Whether merged or not, we update mmap statistics and set the VMA’s

[VM_SOFTDIRTY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n301) flag.

Note that we will examine some of these invoked functions in more de-

tail below as this borrows liberally from the broader [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) functionality.

It’s important to note that both [brk()](https://man7.org/linux/man-pages/man2/brk.2.html) and [sbrk()](https://man7.org/linux/man-pages/man2/sbrk.2.html) are not functions which

users should use directly, rather they should only be used by the userland

allocator in [malloc()](https://man7.org/linux/man-pages/man2/malloc.2.html) and [free()](https://man7.org/linux/man-pages/man2/free.2.html) implementations.

In fact, if you try to use these functions yourself you will likely end up

disrupting the userland allocator’s operation and of course you can have no expectation that the program break won’t be moved by it.

In the vast majority of cases a user need not concern themselves with any

kernel memory interfaces at all. However there are cases where a file needs to be memory-mapped, or more fine-grained control is required over the mapping, which is where mmap() comes into play:

 

***5.0.2 mmap()***

[mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) is arguably the key interface between userland and the kernel for map-ping memory and thus worth examining in extensive detail. Let’s begin by

examining the userland interface itself in Listing 5.0.2.

 

**void** \***mmap**(**void** \*addr, **size_t** length, **int** prot, **int** flags,

**int** fd, **off_t** offset);

 

The function maps memory into the virtual address space as defined by

these parameters, returning either the page-aligned virtual address of the mapped region or MAP_FAILED (i.e. (void \*)-1), setting errno to the error that arose.

Examining each of the parameters:

 

• addr – This is either NULL if the returned address is of no importance

(which is the typical means of invoking this function), or the virtual ad-dress the mapping should start from.

If the MAP_FIXED flag is set then mapping at this address is a hard require-ment (and the function will return an error if it cannot map here). Oth-erwise it is a hint which the kernel will make a best effort to fulfil, but may not be able to.

 



 

All memory mapped by the kernel will be page-aligned, so if a hint ad-dress is specified which is not, the kernel will page-align it. If MAP_FIXED is specified and the address is not page-aligned, an error will occur.

• length – The size of the memory to be mapped, in bytes. The actual size

of the mapping will be page-aligned, so this value will be rounded up to the nearest base page.

• prot – This determines how the memory is intended to be accessed and

maps onto VMA flags. PROT_NONE (set as a single value not a flag) indi-

cates that the memory cannot be accessed at all\*, PROT_READ, PROT_WRITE and PROT_EXEC can be combined to indicate whether the memory can be read from, written to or executed.

Each of PROT_READ, PROT_WRITE and PROT_EXEC are converted to [VM_READ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n266)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n266)

[VM_WRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n267) and [VM_EXEC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n268) respectively via [calc_vm_prot_bits()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mman.h?h=v6.0#n138).

• flags – These determine the characteristics of the allocation, which we

will examine below.

• fd – If the mapping is anonymous, then this should be set to-1. Oth-

erwise it specifies the file descriptor of the file to be mapped. This file descriptor can be safely closed after the mapping has been performed.

• offset – This is only meaningful if a file is being mapped and determines

the offset within the file, in bytes, from which to start the mapping. It must be page-aligned, or an-EINVAL error will be returned. The offset can be outside of the size of the file at the time it is mapped, as the file size might change in future rendering the mapping valid. However if the file is accessed at a time when the offset is invalid a page fault will arise.

 

***5.0.3 mmap map flags***

Flags which alter mapping behaviour are passed in the flags field (each of

which can be bitwise-combined).

These are either referenced directly in the kernel, or converted directly

to VMA flags via [calc_vm_flag_bits()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mman.h?h=v6.0#n150) (applicable to MAP_GROWSDOWN, MAP_LOCKED

and MAP_SYNC) (note that [\_calc_vm_trans()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mman.h?h=v6.0#n129) is simply an optimised means of de-

termining if a flag is set) as shown in Listing 5-3.

 

146 */\**

147 *\* Combine the mmap "flags" argument into "vm_flags" used internally.* 148 *\*/*

149 **static inline unsigned long** 150 **calc_vm_flag_bits**(**unsigned long** flags) 151 {

 

\*. While it might seem somewhat pointless, PROT_NONE can be be useful reserving virtual memory MAP_FIXED ranges that are later overwritten using (see below for more details on this) or for im-

plementing guard pages in userland, i.e. memory that, if touched, generates a page fault. These

can be placed at the end of valid memory ranges to protect against access of buffer overflows or

otherwise out of range memory accesses to mitigate exploits or buggy code.

 



 

152 **return \_calc_vm_trans**(flags, **MAP_GROWSDOWN**, **VM_GROWSDOWN** ) \| 153 **\_calc_vm_trans**(flags, **MAP_LOCKED**, **VM_LOCKED** ) \| 154 **\_calc_vm_trans**(flags, **MAP_SYNC**, **VM_SYNC** ) \| 155 **arch_calc_vm_flag_bits**(flags); 156 }

 

*Listing 5-3:* include/linux/mman.h: [*calc_vm_flag_bits()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mman.h?h=v6.0#n150)

 

Examining each of the possible flags that can be passed in the flags field:

 

• MAP_PRIVATE – Mutually exclusive with MAP_SHARED. Indicates that a Copy

On Write (COW) mapping should be obtained. This can be used with both anonymous and file-backed mappings. Typically this is combined with MAP_ANONYMOUS to indicate that an un-shared, anonymous mapping is required. However, it can also be spec-ified for file-backed mappings, in which case it gains very specific seman-tics – becoming a Copy-on-Write read-only mapping to the underlying page cache entry.

If this mapping is written to, then the Copy-on-Write triggers and the mapping behaves as if it were anonymous, only initialised with the con-tents of the mapped file.

However, if after this pages within the file are truncated (which can occur if the file is deleted, overwritten or shrunk in size) the anonymous pages are freed and it reverts back to being a Copy-on-Write page cache map-ping (triggering SIGBUS if data does not exist in the file at the accessed page).

See section 6.6 for more details on how this functions.

• MAP_SHARED – Indicates that more than one process might map the same

underlying physical memory. This can be used both with anonymous and file-backed mappings, with the latter meaning that each process which maps the same file also maps the same page cache pages. Shared anonymous memory is useful for sharing memory between forked processes, as it prevents the mapping from adopting Copy-on-Write semantics. Behind the scenes, the memory is actually mapped as an deleted copy of /dev/zero effectively residing in tmpfs (setup via

[shmem_zero_setup() ), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/shmem.c?h=v6.0#n4226)however for all intents and purposes it is an anony-mous mapping.

• MAP_SHARED_VALIDATE – The MAP_SHARED flag, for legacy compatibility rea-

sons, does not confirm that the flags parameter contains only valid flags. If this needs to checked, use MAP_SHARED_VALIDATE instead.

• MAP_ANON/MAP_ANONYMOUS – Indicates that the underlying mapping should

be backed by RAM only and when faulted in, physical memory should be allocated to back it.

• MAP_POPULATE – Fault in the mapped memory immediately using the

kernel’s GUP functionality (see section 8.1.2). This invokes the

[mm_populate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2660) function (and [\_\_mm_populate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1652) in turn). Note that this fault-ing in is best effort, if an error occurs during faulting it is ignored, there-

 



 

fore it is possible that memory mapped this way may still result in page faults.

• MAP_FIXED – Indicates that the addr parameter is not a hint but rather a

hard requirement. The specified address must be suitable for a virtual mapping for the architecture, which typically means it must be page-aligned, failure to do so will result in an error.

It’s important to note that this flag will cause [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) to unmap any map-pings which already exist at the specified address, so this is a rather dan-gerous flag to use, and in typical usage should only be used to overwrite an already existing mapping (perhaps a PROT_NONE mapping) to ensure mappings are not unexpectedly overwritten.

• MAP_FIXED_NOREPLACE – This is equivalent to the MAP_FIXED flag, only avoid-

ing the dangerous unmapping (i.e. replacing) behaviour, returning an error if the mapping would do so.

• MAP_GROWSDOWN – Indicates that this mapping is a stack and should

grow downwards (this is a user-defined stack and thus not tied to the architecture-dependent direction of program stack growth). Memory mapped this way has the special quality of stacks, which is that the valid VMA range is not necessarily static. When unmapped mem-ory below the start of the stack is accessed, rather than a segfault arising,

[expand_downwards()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2441) is called which extends the start of the VMA to en-compass the range up to and including the faulting address (see section

6.10 for details on this).

Stack expansion is controlled by the RLIMIT_STACK limit which is checked on page fault, this can be set to being unlimited at which case stack ex-

pansion is limited only by overcommit settings (see section 4.1) and the RLIMIT_AS and RLIMIT_DATA user-specified limits. Clashes with other mappings are avoided as the kernel maintains a gap

between the bottom of the stack and the immediate prior mapping\* of

[stack_guard_gap](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2516) bytes. This can be configured by the kernel command line parameter stack_guard_gap, but defaults to 256 base pages, which for x86-64 implies 1 MiB.

• MAP_LOCKED – Indicates that all memory faulted in for this mapping should

be [mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html)’d (see section 8.2.1 for more on this). This is equivalent to

setting the [VM_LOCKED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n282) VMA flag. The purpose of locking memory like this is to prevent it from being re-claimed or swapped out. This is necessary for regions of memory which the user requires to remain strictly resident in memory, though doing so adds memory pressure.

If this flag is specified, then MAP_POPULATE is implied (as checked in

[do_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1369)). Since this function ignores any errors which occur when

 

\*. For architectures which grow program stacks upwards, they maintain this gap above the stack, [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) however this is not relevant to the discussion as an [’d](https://man7.org/linux/man-pages/man2/mmap.2.html) stack can only grow downwards. The

gap is enforced in both directions regardless of architecture.

 



 

faulting in memory this does not guarantee that further page faults will not occur.

As the [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) documentation indicates, if such faulting behaviour is not

desired, then [mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html) should be used separately to guarantee that mem-ory is faulted in.

• MAP_NORESERVE – Indicates that no swap space should be reserved for a

mapping. The practical impact of this is:

**–** The containing VMA will have the [VM_NORESERVE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n293) flag set, except if

overcommit mode (see section 4.1) [OVERCOMMIT_NEVER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/mman.h?h=v6.0#n14) is set, which

overrules this\*.

**–** Otherwise, the containing VMA is determined to be non-accountable

by [accountable_mapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1669) which results in the VMA flag [VM_ACCOUNT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n292) not being set.

**–** As a result, when mapping non-stack memory in [OVERCOMMIT_GUESS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/mman.h?h=v6.0#n12)

overcommit mode, the free memory check in [\_\_vm_enough_memory()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n1022) is not performed (which in this mode simply checks that the map-ping size does not exceed the sum of the total physical mem-ory installed and swap space). Security hooks also invoked by

[security_vm_enough_memory_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/security/security.c?h=v6.0#n830) are not run either.

**–** This is true of [OVERCOMMIT_ALWAYS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/mman.h?h=v6.0#n13), but this mode always permits over-

commit so it typically has no bearing, unless a security hook would have otherwise disallowed the mapping.

**–** As a result, for overcommit modes other than [OVERCOMMIT_NEVER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/mman.h?h=v6.0#n14),

the Committed_AS statistic seen in /proc/meminfo is not updated

[(vm_acct_memory()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mman.h?h=v6.0#n73) is not invoked on mapping/unmapping).

**–** Only writable, private mappings are accountable in any case, so this

mapping flag is only meaningful for private anonymous mappings or MAP_PRIVATE file-backed mappings.

• MAP_SYNC – This is only meaningful for shared mappings, and requires

MAP_SHARED_VALIDATE to also be specified as if only MAP_SHARED is this flag is

explicitly masked out by applying [LEGACY_MAP_MASK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mman.h?h=v6.0#n38) in [do_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1369). The flag is only meaningful for DAX (which provides Direct Ac-cess not mediated by the page cache to memory-like devices), caus-ing dirty metadata to be flushed on write faults as checked by

[dax_fault_is_synchronous()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/dax.c?h=v6.0#n836). DAX is out of scope for this book.

This flag is mapped to [VM_SYNC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n295) by [calc_vm_flag_bits()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mman.h?h=v6.0#n150)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mman.h?h=v6.0#n150)

• MAP_UNINITIALIZED – Anonymous pages mapped by [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) are always ze-

roed for security reasons. However, on no-MMU systems alone and only if CONFIG_MMAP_ALLOWED_UNINITIALIZED is set then uninitialised anonymous mappings permitted when the MMAP_UNINITIALIZED flag is set. This is only used on embedded devices due to the huge security hole this introduces, and is in any case limited in practice to those devices which do not possess an MMU so on modern architectures such as x86-64 this will simply not be permitted.

 

\*. Except for hugetlb but this is out of scope for this discussion.



 

• MAP_32BIT – Only implemented for the x86 architecture. Indicates that

mappings should only be mapped into the first 32-bits of virtual address space.

This is checked by [arch_get_unmapped_area()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/sys_x86_64.c?h=v6.0#n123) which uses the legacy bottom-up mmap layout, with start and end addresses constrained by

[find_start_end()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/sys_x86_64.c?h=v6.0#n96) to fit within the 32-bit range. If the mapping was not

specified to be legacy, [arch_get_unmapped_area_topdown()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/sys_x86_64.c?h=v6.0#n161) is called, however this explicitly checks for MAP_32BIT and falls back to the legacy mode if so.

• MAP_HUGETLB, MAP_HUGE_2MB, MAP_HUGE_1GB – MAP_HUGETLB specifies that a [hugetlb](https://kernel.org/doc/html/v6.0/admin-guide/mm/hugetlbpage.html)

huge page should be used, with the size of the huge page specified by the latter two flags. This is handled by the hugetlb logic which is out of scope here.

• MAP_NONBLOCK – A legacy flag which currently results in the bizarre be-

haviour of, if MAP_POPULATE is also set, cancelling the MAP_POPULATE opera-tion. This briefly did more than this in the distant past.

• MAP_STACK – Does nothing. May do something in the future.

• MAP_FILE – Deprecated and ignored.

• MAP_DENYWRITE – Deprecated and ignored.

• MAP_EXECUTABLE – Deprecated and ignored.

 

***5.0.4 mmap kernel implementation***

The mmap() system call implementation is architecture-specific. We examine

the x86-64 version in Listing 5-4.

 

86 **SYSCALL_DEFINE6**(mmap, **unsigned long**, addr, **unsigned long**, len,

87 **unsigned long**, prot, **unsigned long**, flags,

88 **unsigned long**, fd, **unsigned long**, off)

89 {

90 **if** (off & ~**PAGE_MASK**)

91 **return**-**EINVAL**;

92

93 **return ksys_mmap_pgoff**(addr, len, prot, flags, fd, off \>\> PAGE_SHIFT);

94 }

 

*Listing 5-4:* arch/x86/kernel/sys_x86_64.c: [*syscall:mmap()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/sys_x86_64.c?h=v6.0#n86)

This invokes [ksys_mmap_pgoff()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1548) which has the same parameters as the

mmap() function, only the offset is expressed in pages, not bytes\* (excluding

out of scope huge page handling) as shown in Listing 5-5.

 

1548 **unsigned long ksys_mmap_pgoff**(**unsigned long** addr, **unsigned long** len, 1549 **unsigned long** prot, **unsigned long** flags,

 

\*. This is utilised by the [mmap2()](https://man7.org/linux/man-pages/man2/mmap2.2.html) system call which permits the avoidance of overflow for systems off_t whose is 32-bits and who need to be able to offset further. This system call is aliased to

[mmap_pgoff()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1593) which calls ksys_mmap_pgoff() directly.

 



 

1550 **unsigned long** fd, **unsigned long** pgoff) 1551 {

1552 **struct** file \*file = **NULL**; 1553 **unsigned long** retval; 1554

1555 **if** (!(flags & **MAP_ANONYMOUS**)) { 1556 **audit_mmap_fd**(fd, flags); 1557 file = **fget**(fd); 1558 **if** (!file) 1559 **return**-**EBADF**;

. . .

1584 }

1585

1586 retval = **vm_mmap_pgoff**(file, addr, len, prot, flags, pgoff);

. . .

1588 **if** (file)

1589 **fput**(file); 1590 **return** retval;

1591 }

 

*Listing 5-5:* mm/mmap.c: [*ksys_mmap_pgoff()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1548)

 

This is essentially pass-through to [vm_mmap_pgoff()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n539), obtaining the

[struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) for file-backed mappings and incrementing its reference count

via [fget()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/file.c?h=v6.0#n924). Examining vm_mmap_pgoff() (eliding out of scope userfaultfd logic)

as shown in Listing 5-6.

 

539 **unsigned long vm_mmap_pgoff**(**struct** file \*file, **unsigned long** addr, 540 **unsigned long** len, **unsigned long** prot, 541 **unsigned long** flag, **unsigned long** pgoff) 542 {

543 **unsigned long** ret; 544 **struct** mm_struct \*mm = current-\>mm; 545 **unsigned long** populate; 546 **LIST_HEAD**(uf);

547

548 ret = **security_mmap_file**(file, prot, flag); 549 **if** (!ret) {

550 **if** (**mmap_write_lock_killable**(mm)) 551 **return**-**EINTR**; 552 ret = **do_mmap**(file, addr, len, prot, flag, pgoff, &populate, 553 &uf); 554 **mmap_write_unlock**(mm);

. . .

556 **if** (populate) 557 **mm_populate**(ret, populate); 558 }

559 **return** ret;

560 }

 



 

*Listing 5-6:* mm/util.c: [*vm_mmap_pgoff()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n539)

 

This starts by invoking [security_mmap_file()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/security/security.c?h=v6.0#n1589) to provide a security hook

for memory mapping of files, before acquiring the process address space’s

[struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) semaphore for writing, performing the heavy lift-

ing in [do_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1369).

The function finishes by populating (i.e. pre-faulting) the range via

[mm_populate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2660) if specified (e.g. the user having specified MAP_POPULATE). This

ultimately calls [\_\_mm_populate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n1652) which is described in section 8.1.9.

We examine the key [do_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1369) function starting in Listing 5-7.

 

1366 */\**

1367 *\* The caller must write-lock current-\>mm-\>mmap_lock.* 1368 *\*/*

1369 **unsigned long do_mmap**(**struct** file \*file, **unsigned long** addr, 1370 **unsigned long** len, **unsigned long** prot, 1371 **unsigned long** flags, **unsigned long** pgoff, 1372 **unsigned long** \*populate, **struct** list_head \*uf) 1373 {

1374 **struct** mm_struct \*mm = current-\>mm; 1375 **vm_flags_t** vm_flags; 1376 **int** pkey = 0;

1377

1378 \*populate = 0;

1379

1380 **if** (!len)

1381 **return**-**EINVAL**; 1382

1383 */\**

1384 *\* Does the application expect PROT_READ to imply PROT_EXEC?* 1385 *\**

1386 *\* (the exception is when the underlying filesystem is noexec* 1387 *\* mounted, in which case we dont add PROT_EXEC.)* 1388 *\*/*

1389 **if** ((prot & **PROT_READ**) && (current-\>personality & **READ_IMPLIES_EXEC**)) 1390 **if** (!(file && **path_noexec**(&file-\>f_path))) 1391 prot \|= **PROT_EXEC**; 1392

1393 */\* force arch specific MAP_FIXED handling in get_unmapped_area \*/* 1394 **if** (flags & **MAP_FIXED_NOREPLACE**) 1395 flags \|= **MAP_FIXED**;

 

*Listing 5-7:* mm/mmap.c: [*do_mmap()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1369) *parameter filtering*

 

We start with some simple initialisation and filtering of parameters. If

no length is specified we exit with an error, otherwise if PROT_READ implies

PROT_EXEC, as it does on some architectures (or otherwise specified via the

process’s [personality()](https://man7.org/linux/man-pages/man2/personality.2.html)[).](https://man7.org/linux/man-pages/man2/personality.2.html)

 



 

Finally, we ensure MAP_FIXED is always set if MAP_FIXED_NOREPLACE is to ensure

architecture-specific logic run in [get_unmapped_area()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2209) which is run only if the former flag is present is correctly invoked.

We examine the next part of the function in Listing 5-8.

 

1397 **if** (!(flags & **MAP_FIXED**)) 1398 addr = **round_hint_to_min**(addr); 1399

1400 */\* Careful about overflows.. \*/* 1401 len = **PAGE_ALIGN**(len); 1402 **if** (!len)

1403 **return**-**ENOMEM**; 1404

1405 */\* offset overflow? \*/* 1406 **if** ((pgoff + (len \>\> **PAGE_SHIFT**)) \< pgoff) 1407 **return**-**EOVERFLOW**; 1408

1409 */\* Too many mappings? \*/* 1410 **if** (mm-\>map_count \> **sysctl_max_map_count**) 1411 **return**-**ENOMEM**; 1412

1413 */\* Obtain the address to map to. we verify (or select) it and ensure*

1414 *\* that it represents a valid section of the address space.* 1415 *\*/*

1416 addr = **get_unmapped_area**(file, addr, len, pgoff, flags); 1417 **if** (**IS_ERR_VALUE**(addr)) 1418 **return** addr; 1419

1420 **if** (flags & **MAP_FIXED_NOREPLACE**) { 1421 **if** (**find_vma_intersection**(mm, addr, addr + len)) 1422 **return**-**EEXIST**; 1423 }

. . .

1431 */\* Do simple checking here so the lower-level routines won't have*

1432 *\* to. we assume access permissions have been handled by the open*

1433 *\* of the memory object, so we don't do any here.* 1434 *\*/*

1435 vm_flags = **calc_vm_prot_bits**(prot, pkey) \| **calc_vm_flag_bits**(flags) \| 1436 mm-\>def_flags \| **VM_MAYREAD** \| **VM_MAYWRITE** \| **VM_MAYEXEC**; 1437

1438 **if** (flags & **MAP_LOCKED**) 1439 **if** (!**can_do_mlock**()) 1440 **return**-**EPERM**; 1441

1442 **if** (**mlock_future_check**(mm, vm_flags, len)) 1443 **return**-**EAGAIN**;

 

*Listing 5-8:* mm/mmap.c: [*do_mmap()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1369) *initial checks and setup*

 



 

We start by ensuring that any specified hint address passed as addr (i.e.

where the MAP_FIXED flag has not been specified) is correctly page-aligned and

greater than the minimum permitted by [mmap_min_addr](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/security/min_addr.c?h=v6.0#n8) via [round_hint_to_min()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1308)

as shown in Listing 5-9.

 

1304 */\**

1305 *\* If a hint addr is less than mmap_min_addr change hint to be as* 1306 *\* low as possible but still greater than mmap_min_addr* 1307 *\*/*

1308 **static inline unsigned long round_hint_to_min**(**unsigned long** hint) 1309 {

1310 hint &= **PAGE_MASK**; 1311 **if** (((**void** \*)hint != **NULL**) && 1312 (hint \< **mmap_min_addr**)) 1313 **return PAGE_ALIGN**(**mmap_min_addr**); 1314 **return** hint;

1315 }

 

*Listing 5-9:* mm/mmap.c: [*round_hint_to_min()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1308)

 

We then ensure that both the len and pgoff parameters are checked to

ensure they are not so close to the maximum value for their types that they

might overflow.

Next, we test to see if the [struct mm_struct-\>map_count](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) parameter (counting

the number of virtual mappings in the process address space) exceeds the

vm.max_map_count tunable. If so we error out.

Where precisely this mapping will be situated in virtual memory is deter-

mined by the critical function function [get_unmapped_area()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2209). As this function

is rather a large topic, we defer discussion of it to section 5.0.5.

If MAP_FIXED_NOREPLACE is specified, we determine whether any existing

VMA intersects with the input address range via [find_vma_intersection()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2729)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2729) er-

roring out if so.

VMA flags always default to VM_MAYREAD, VM_MAYWRITE and VM_MAYEXEC –

we will unset these flags should any be determined not to be applicable.

In addition, further VMA flags are implied by prot and flags, this being

mapped by via [calc_vm_prot_bits()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mman.h?h=v6.0#n138) (simply mapping PROT_xxx to VM_xxx) and

[calc_vm_flag_bits()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mman.h?h=v6.0#n150) (as described in listing 5-3 above), combined with the de-

fault process address spaces flags specified in [struct mm_struct-\>def_flags](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486).

We then apply two [mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html)[-specif](https://man7.org/linux/man-pages/man2/mlock.2.html)ic checks. The first is [can_do_mlock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n40)

which checks to ensure the RLIMIT_MEMLOCK is non-zero (or the thread pos-

sesses the CAP_IPC_LOCK [capability](https://man7.org/linux/man-pages/man7/capabilities.7.html)\* which overrides this limit). The second

is [mlock_future_check()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1317) which, if [VM_LOCKED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n282) is set (i.e. via MAP_LOCKED), ensures

that locking the length of this mapping would not cause the RLIMIT_MEMLOCK

user limit to be exceeded (again, unless the thread possesses the CAP_IPC_LOCK

[capability).](https://man7.org/linux/man-pages/man7/capabilities.7.html)

 

\*. Capabilities are a fine-grained means of assigning permissions on a per-thread basis.

 



 

Once these checks are complete, we go ahead and check the flags field

is valid and adjust VMA flags as necessary. There is separate logic for both file-backed and anonymous mappings, beginning with the file-backed case as

shown in Listing 5-10.

 

1445 **if** (file) {

1446 **struct** inode \*inode = **file_inode**(file); 1447 **unsigned long** flags_mask; 1448

1449 **if** (!**file_mmap_ok**(file, inode, pgoff, len)) 1450 **return**-**EOVERFLOW**; 1451

1452 flags_mask = **LEGACY_MAP_MASK** \| file-\>f_op-\>

mmap_supported_flags;

1453

1454 **switch** (flags & **MAP_TYPE**) { 1455 **case MAP_SHARED**: 1456 */\** 1457 *\* Force use of MAP_SHARED_VALIDATE with non-legacy*

1458 *\* flags. E.g. MAP_SYNC is dangerous to use with* 1459 *\* MAP_SHARED as you don't know which consistency*

*model*

1460 *\* you will get. We silently ignore unsupported flags*

1461 *\* with MAP_SHARED to preserve backward compatibility.*

1462 *\*/* 1463 flags &= **LEGACY_MAP_MASK**; 1464 **fallthrough**; 1465 **case MAP_SHARED_VALIDATE**: 1466 **if** (flags & ~flags_mask) 1467 **return**-**EOPNOTSUPP**; 1468 **if** (prot & **PROT_WRITE**) { 1469 **if** (!(file-\>f_mode & **FMODE_WRITE**)) 1470 **return**-**EACCES**; 1471 **if** (**IS_SWAPFILE**(file-\>f_mapping-\>host)) 1472 **return**-**ETXTBSY**; 1473 } 1474

1475 */\** 1476 *\* Make sure we don't allow writing to an append-only*

1477 *\* file..* 1478 *\*/* 1479 **if** (**IS_APPEND**(inode) && (file-\>f_mode & **FMODE_WRITE**)) 1480 **return**-**EACCES**; 1481

1482 vm_flags \|= **VM_SHARED** \| **VM_MAYSHARE**; 1483 **if** (!(file-\>f_mode & **FMODE_WRITE**)) 1484 vm_flags &= ~(**VM_MAYWRITE** \| **VM_SHARED**); 1485 **fallthrough**;

 



 

1486 **case MAP_PRIVATE**: 1487 **if** (!(file-\>f_mode & **FMODE_READ**)) 1488 **return**-**EACCES**; 1489 **if** (**path_noexec**(&file-\>f_path)) { 1490 **if** (vm_flags & **VM_EXEC**) 1491 **return**-**EPERM**; 1492 vm_flags &= ~**VM_MAYEXEC**; 1493 } 1494

1495 **if** (!file-\>f_op-\>mmap) 1496 **return**-**ENODEV**; 1497 **if** (vm_flags & (**VM_GROWSDOWN**\|**VM_GROWSUP**)) 1498 **return**-**EINVAL**; 1499 **break**; 1500

1501 **default**:

1502 **return**-**EINVAL**; 1503 }

 

*Listing 5-10:* mm/mmap.c: [*do_mmap()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1369) *file-backed flag checks*

 

We start by checking the size of the mapped file is reasonable via

[file_mmap_ok()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1353) as shown in Listing 5-11.

 

1353 **static inline bool file_mmap_ok**(**struct** file \*file, **struct** inode \*inode, 1354 **unsigned long** pgoff, **unsigned long** len) 1355 {

1356 **u64** maxsize = **file_mmap_size_max**(file, inode); 1357

1358 **if** (maxsize && len \> maxsize) 1359 **return false**; 1360 maxsize -= len;

1361 **if** (pgoff \> maxsize \>\> **PAGE_SHIFT**) 1362 **return false**; 1363 **return true**;

1364 }

 

*Listing 5-11:* mm/mmap.c: [*file_mmap_ok()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1353)

 

This checks that the length of the mapping (the len parameter) is less

than or equal to the maximum permissible size and the offset within the

mapping (the pgoff parameter, expressed in base pages) would not result

in an offset into the file that would exceed the maximum size.

The maximum size is determined by [file_mmap_size_max()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1334). The

key aim of this function is to avoid overflow for 32-bit systems as the

file size is 64-bit but we must ensure that indexes into this region are

correct even for drivers which might not behave correctly. For 64-

bit systems this is not a concern. This logic was added in commit

[be83bbf80682: mmap: introduce sane default mmap limits](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=be83bbf80682).

 



 

After this check is performed, we establish a mask of accepted map-

ping flags by combining [LEGACY_MAP_MASK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mman.h?h=v6.0#n38) with flags additionally supported

by the file system, as determined by the [struct file_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2093) handler in

[struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940)-\>f_op-\>mmap_supported_flags.

The [LEGACY_MAP_MASK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mman.h?h=v6.0#n38) consists of the key mapping flags. Excluding dep-

recated and hugetlb flags this consists of MAP_SHARED, MAP_PRIVATE, MAP_FIXED, MAP_ANONYMOUS, MAP_UNINITIALIZED, MAP_GROWSDOWN MAP_LOCKED, MAP_NORESERVE, MAP_POPULATE and MAP_32BIT.

The type of mapping is masked by [MAP_TYPE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/asm-generic/mman-common.h?h=v6.0#n21) which masks MAP_PRIVATE,

MAP_SHARED and MAP_SHARED_VALIDATE and we process these flags as follows:

 

• MAP_SHARED – For legacy reasons, when this flag is specified, we permit

unrecognised or invalid flags to be specified which are silently ignored

by simply masking against [LEGACY_MAP_MASK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mman.h?h=v6.0#n38)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mman.h?h=v6.0#n38) By doing so, we both main-tain the legacy behaviour of not validating flags, while simultaneously preventing the use of flags which might be dangerous if used uninten-tionally (e.g. MAP_SHARED). With flags now masked to a valid subset, we can simply fall through to the MAP_SHARED_VALIDATE case and share the proceeding logic between two cases.

• MAP_SHARED_VALIDATE – Having already established the set of

valid flags as being those specified by LEGACY_MAP_MASK and file-\>f_op-\>mmap_supported_flags, so we simply return an error should flags specify any flags other than these. If the mapping is read/write (i.e. PROT_WRITE is specified), then we ensure that the file is open with write permissions and that the file is not desig-nated a swap file, if either of these are not the case, we return an error. Additionally, if the file is append-only, we cannot permit the caller to memory map the file in write mode, as this would emphatically not be append-only, so equally we raise an error should this be attempted.

Finally, we specify shared mapping-specific VMA flags – [VM_MAYSHARE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n275) and

if the file is writable [VM_SHARED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n269), otherwise we clear the [VM_MAYWRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n273) flag. Again, we share logic between different modes by falling through to the MAP_PRIVATE case at this point.

• MAP_PRIVATE – If the file is not opened in read mode, then naturally we

error out. Equally, if the file is mounted on a file system which does

not permit execution (checked via [path_noexec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/exec.c?h=v6.0#n109)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/exec.c?h=v6.0#n109) we either error out

if [VM_EXEC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n268) is set (implied by PROT_EXEC) or otherwise clear the [VM_MAYEXEC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n274) VMA flag.

We then perform an absolutely key check – if the [struct file_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2093)

handler in [struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940)-\>f_op-\>mmap is not specified (somethign that most be provided by the filesystem), then memory-mapping this file is simply not supported so we must error out.

 



 

Finally, if this memory would be mapped as a stack (implied by

[VM_GROWSDOWN](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n277)\* ), then we error out, as mapping memory file-backed and a stack simply makes no sense.

 

Having examined the file-backed logic, let’s consider the far simpler

anonymous mapping logic in LIsting 5-12

 

1504 } **else** {

1505 **switch** (flags & **MAP_TYPE**) { 1506 **case MAP_SHARED**: 1507 **if** (vm_flags & (**VM_GROWSDOWN**\|**VM_GROWSUP**)) 1508 **return**-**EINVAL**; 1509 */\** 1510 *\* Ignore pgoff.* 1511 *\*/* 1512 pgoff = 0; 1513 vm_flags \|= **VM_SHARED** \| **VM_MAYSHARE**; 1514 **break**; 1515 **case MAP_PRIVATE**: 1516 */\** 1517 *\* Set pgoff according to addr for anon_vma.* 1518 *\*/* 1519 pgoff = addr \>\> **PAGE_SHIFT**; 1520 **break**; 1521 **default**:

1522 **return**-**EINVAL**; 1523 }

1524 }

 

*Listing 5-12:* mm/mmap.c: [*do_mmap()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1369) *anonymous flag checks*

If the mapping is shared, then we check to ensure this mapping is not a

stack (a shared stack makes no sense). If it is shared, then we reset the offset

into the mapping specified by pgoff, since the shared anonymous mapping

is actually achieved by mapping a deleted inode of a tmpfs copy of /dev/zero,

and offsetting into this makes no sense.

We additionally set [VM_SHARED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n269) and [VM_MAYSHARE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n275) to indicate that this is a

shared mapping.

If the mapping is private, then importantly, we specify a virtual page off-

set (again ignoring any that might have erroneously been specified by the

user) – which is simply the virtual address shifted by the base page size. This

is useful for forking, see the discussion of the reverse mapping (Chapter 7)

for more on how this is utilised.

Finally, if neither MAP_SHARED or MAP_PRIVATE are specified, we error out.

Note that MAP_SHARED_VALIDATE is not a valid flag for anonymous mappings.

Examining the final part of [do_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1369) in Listing 5-13.

 

\*. Some architectures may specify the VM_GROWSUP flag to indicate a stack which grows upward,

however we do not consider such architectures here.



 

1526 */\**

1527 *\* Set 'VM_NORESERVE' if we should not account for the* 1528 *\* memory use of this mapping.* 1529 *\*/*

1530 **if** (flags & **MAP_NORESERVE**) { 1531 */\* We honor MAP_NORESERVE if allowed to overcommit \*/* 1532 **if** (**sysctl_overcommit_memory** != **OVERCOMMIT_NEVER**) 1533 vm_flags \|= **VM_NORESERVE**; 1534

1535 */\* hugetlb applies strict overcommit unless MAP_NORESERVE \*/*

1536 **if** (file && **is_file_hugepages**(file)) 1537 vm_flags \|= **VM_NORESERVE**; 1538 }

1539

1540 addr = **mmap_region**(file, addr, len, vm_flags, pgoff, uf); 1541 **if** (!**IS_ERR_VALUE**(addr) && 1542 ((vm_flags & **VM_LOCKED**) \|\| 1543 (flags & (**MAP_POPULATE** \| **MAP_NONBLOCK**)) == **MAP_POPULATE**)) 1544 \*populate = len; 1545 **return** addr;

1546 }

 

*Listing 5-13:* mm/mmap.c: [*do_mmap()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1369) *shared mapping logic*

 

We start by handling the MAP_NORESERVE case. If the overcommit mode

(see section 4.1) is not [OVERCOMMIT_NEVER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/mman.h?h=v6.0#n14) or if this is huge page file, then the

[VM_NORESERVE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n293) flag is set (see the discussion of map flags above for more dis-cussion on this).

Finally, with all flags set and checks performed, the actual mapping is

performed by [mmap_region()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1681), which we will examine below.

If this succeeds, MAP_POPULATE semantics are checked – if the region is not

locked (which would already have been populated), MAP_POPULATE is specified but MAP_NONBLOCK is not then the population is performed.

We start examining [mmap_region()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1681) in Listing 5-14.

 

1681 **unsigned long mmap_region**(**struct** file \*file, **unsigned long** addr, 1682 **unsigned long** len, vm_flags_t vm_flags, **unsigned long** pgoff, 1683 **struct** list_head \*uf) 1684 {

1685 **struct** mm_struct \*mm = current-\>mm; 1686 **struct** vm_area_struct \*vma, \*prev, \*merge; 1687 **int** error;

1688 **struct** rb_node \*\*rb_link, \*rb_parent; 1689 **unsigned long** charged = 0; 1690

1691 */\* Check against address space limit. \*/* 1692 **if** (!**may_expand_vm**(mm, vm_flags, len \>\> **PAGE_SHIFT**)) { 1693 **unsigned long** nr_pages;

 



 

1694

1695 */\**

1696 *\* MAP_FIXED may remove pages of mappings that intersects with*

1697 *\* requested mapping. Account for the pages it would unmap.*

1698 *\*/*

1699 nr_pages = **count_vma_pages_range**(mm, addr, addr + len); 1700

1701 **if** (!**may_expand_vm**(mm, vm_flags, 1702 (len \>\> **PAGE_SHIFT**) - nr_pages)) 1703 **return**-**ENOMEM**; 1704 }

1705

1706 */\* Clear old maps, set up prev, rb_link, rb_parent, and uf \*/* 1707 **if** (**munmap_vma_range**(mm, addr, len, &prev, &rb_link, &rb_parent, uf)) 1708 **return**-**ENOMEM**; 1709 */\**

1710 *\* Private writable mapping: check memory availability* 1711 *\*/*

1712 **if** (**accountable_mapping**(file, vm_flags)) { 1713 charged = len \>\> **PAGE_SHIFT**; 1714 **if** (**security_vm_enough_memory_mm**(mm, charged)) 1715 **return**-**ENOMEM**; 1716 vm_flags \|= **VM_ACCOUNT**; 1717 }

1718

1719 */\**

1720 *\* Can we just expand an old mapping?* 1721 *\*/*

1722 vma = **vma_merge**(mm, prev, addr, addr + len, vm_flags, 1723 **NULL**, file, pgoff, **NULL**, **NULL_VM_UFFD_CTX**, **NULL**); 1724 **if** (vma)

1725 **goto** out;

 

*Listing 5-14:* mm/mmap.c: [*mmap_region()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1681) *initialisation and early exit*

 

We start by checking the address space limit via [may_expand_vm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n3252)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n3252) which

ensures RLIMIT_AS and RLIMIT_DATA limits are respected. If this is apparently

violated, we perform the expensive task of accounting for any overlapping

mappings using [count_vma_pages_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n567) and subtract this from the checked

total, before trying again.

Note that any overlap of VMAs within the mapped range must imply

MAP_FIXED was specified, as otherwise the calling code would have errored

out by now, so we can simply go ahead and unmap any memory already

within the range via [munmap_vma_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n556). This, for convenience, invokes

[find_vma_links()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n488) to find the previous VMA, parent node, and pointer to

where the newly inserted VMA should be referenced from (i.e. a pointer

to its parent’s left or right node field).

 



 

See section 5.0.6 below for a detailed examination of how memory is un-

mapped.

Finally, if we can simply merge the candidate new VMA with an existing

VMA either immediately prior to succeeding it, then we do so via [vma_merge()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1122) and avoid having to allocate and set up a new VMA.

We examine the code which allocates and initialises a new VMA in List-

ing 5-15.

 

*/\**

*\* Determine the object being mapped and call the appropriate \* specific mapper. the address has already been validated, but \* not unmapped, but the maps are removed from the list. \*/*

vma = **vm_area_alloc**(mm);

**if** (!vma) {

error = -**ENOMEM**;

**goto unacct_error**;

}

 

vma-\>vm_start = addr;

vma-\>vm_end = addr + len;

vma-\>vm_flags = vm_flags;

vma-\>vm_page_prot = **vm_get_page_prot**(vm_flags); vma-\>vm_pgoff = pgoff;

 

**if** (file) {

**if** (vm_flags & **VM_SHARED**) {

error = **mapping_map_writable**(file-\>f_mapping); **if** (error)

**goto free_vma**;

}

 

vma-\>vm_file = **get_file**(file); error = **call_mmap**(file, vma); **if** (error)

**goto unmap_and_free_vma**;

 

*/\* Can addr have changed??*

*\**

*\* Answer: Yes, several device drivers can do it in their \** *f_op-\>mmap method. -DaveM \* Bug: If addr is changed, prev, rb_link, rb_parent should \** *be updated for vma_link() \*/*

**WARN_ON_ONCE**(addr != vma-\>vm_start);

 

addr = vma-\>vm_start;

 



 

*/\* If vm_flags changed after call_mmap(), we should try merge vma again*

*\* as we may succeed this time.*

*\*/*

**if** (**unlikely**(vm_flags != vma-\>vm_flags && prev)) {

merge = **vma_merge**(mm, prev, vma-\>vm_start, vma-\>vm_end, vma-\>vm_flags,

**NULL**, vma-\>vm_file, vma-\>vm_pgoff, **NULL**, **NULL_VM_UFFD_CTX**, **NULL**

);

**if** (merge) {

*/\* -\>mmap() can change vma-\>vm_file and fput the original file.*

*So*

*\* fput the vma-\>vm_file here or we would add an extra fput for*

*file*

*\* and cause general protection fault ultimately.*

*\*/*

**fput**(vma-\>vm_file); **vm_area_free**(vma); vma = merge;

*/\* Update vm_flags to pick up the change. \*/*

vm_flags = vma-\>vm_flags;

**goto unmap_writable**;

}

}

 

vm_flags = vma-\>vm_flags;

} **else if** (vm_flags & **VM_SHARED**) {

error = **shmem_zero_setup**(vma);

**if** (error)

**goto free_vma**;

} **else** {

**vma_set_anonymous**(vma);

}

 

*/\* Allow architectures to sanity-check the vm_flags \*/* **if** (!**arch_validate_flags**(vma-\>vm_flags)) {

error = -**EINVAL**;

**if** (file)

**goto unmap_and_free_vma**;

**else**

**goto free_vma**;

}

 

**vma_link**(mm, vma, prev, rb_link, rb_parent);

 

*Listing 5-15:* mm/mmap.c: [*mmap_region()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1681) *VMA allocation and initialisation*

 

We allocate and initialise a new VMA via [vm_area_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n455) (for more de-

tails on this see section 4.4.2), before assigning the VMA’s vm_start, vm_end,

vm_flags and vm_pgoff with input parameters.

 



 

The protection flags applicable to the VMA are determined via the

architecture-specific [vm_get_page_prot()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgprot.c?h=v6.0#n35) function, described in detail in the

virtual memory chapter in section 3.1.3.

As usual, the file-backed mapping case is more complicated than the

anonymous one – we start by indicating that we have a new writable map-

ping via [mapping_map_writable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n526) (the kernel questionably assumes that it is im-

plicit that [VM_SHARED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n269) implies that the mapping is writable) if shared.

Next, we increment the reference count on the [struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) associ-

ated with the mapping, before invoking the filesystem’s customised

[struct file_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2093) handler in file-\>f_op-\>mmap via [call_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2190), erroring out if this fails.

We assert that we don’t have buggy drivers doing insane things with

the address, before checking for an edge case – the call to the file system’s memory mapping hook above may have altered VMA flags which may cause a previously failed merge to now succeed, so we try the merge again via

[vma_merge()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1122), cleaning up after ourselves and exiting if so.

Skipping the anonymous shared case for now which we shall return to

shortly – if the VMA is private and anonymous, we invoke [vma_set_anonymous()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n624)

which clears the [vm_area_alloc()-\>vm_ops](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n455) field to explicitly indicate that the VMA is anonymous (note that, on allocation the VMA has its fields ini-

tialised by [vma_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n614) which defaults vm_ops to a static empty [dummy_vm_ops](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n616) ob-ject).

In the case of a shared anonymous mapping (i.e. one which the user has

specified both MAP_ANONYMOUS and MAP_SHARED), special handling is required, as the kernel does not truly support shared anonymous mappings, but rather must work around this with RAM-based file-backed handling. This is done

in [shmem_zero_setup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/shmem.c?h=v6.0#n4226) as shown in Listing 5-16.

 

4222 */\*\**

4223 *\* shmem_zero_setup - setup a shared anonymous mapping* 4224 *\* @vma: the vma to be mmapped is prepared by do_mmap* 4225 *\*/*

4226 **int shmem_zero_setup**(**struct** vm_area_struct \*vma) 4227 {

4228 **struct** file \*file; 4229 loff_t size = vma-\>vm_end - vma-\>vm_start; 4230

4231 */\**

4232 *\* Cloning a new file under mmap_lock leads to a lock ordering*

*conflict*

4233 *\* between XFS directory reading and selinux: since this file is only*

4234 *\* accessible to the user through its mapping, use S_PRIVATE flag to*

4235 *\* bypass file security, in the same way as shmem_kernel_file_setup().*

4236 *\*/*

4237 file = **shmem_kernel_file_setup**("dev/zero", size, vma-\>vm_flags); 4238 **if** (**IS_ERR**(file)) 4239 **return PTR_ERR**(file); 4240

 



 

4241 **if** (vma-\>vm_file) 4242 **fput**(vma-\>vm_file); 4243 vma-\>vm_file = file; 4244 vma-\>vm_ops = &shmem_vm_ops; 4245

4246 **return** 0;

4247 }

 

*Listing 5-16:* mm/shmem.c: [*shmem_zero_setup()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/shmem.c?h=v6.0#n4226)

This establishes a copy of /dev/zero of the designated size as an unlinked

tmpfs file\* (i.e. one tied to a newly generated tmpfs inode which is in effect

deleted from the file system but which through reference count we keep

around), setting up vm_file and vm_ops accordingly. The heavy lifting of this

is performed by [shmem_kernel_file_setup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/shmem.c?h=v6.0#n4191)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/shmem.c?h=v6.0#n4191) the description of which is out of

scope here.

Once this setup is established for each of the file-backed, anonymous

shared and anonymous private cases, we invoke the arch_validate_flags()

function which provides a hook for some architectures which need to vali-

date VMA flags when VMAs are created.

We then link this newly allocated and now set up VMA into the VMA

linked list and red/black tree via [vma_link()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n645) (see listing 4-21).

Finally, let’s examine [mmap_region()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1681)’s error handling and shared code

(eliding out of scope huge page, uprobe and performance event logic) in

Listing 5-17.

 

1806

. . .

1813 */\* Once vma denies write, undo our temporary denial count \*/* 1814 **unmap_writable**:

1815 **if** (file && vm_flags & **VM_SHARED**) 1816 **mapping_unmap_writable**(file-\>f_mapping); 1817 file = vma-\>vm_file; 1818 **out**:

. . .

1821 **vm_stat_account**(mm, vm_flags, len \>\> **PAGE_SHIFT**); 1822 **if** (vm_flags & **VM_LOCKED**) { 1823 **if** ((vm_flags & **VM_SPECIAL**) \|\| **vma_is_dax**(vma) \|\| 1824 **is_vm_hugetlb_page**(vma) \|\| 1825 vma == **get_gate_vma**(current-\>mm)) 1826 vma-\>vm_flags &= **VM_LOCKED_CLEAR_MASK**; 1827 **else**

1828 mm-\>locked_vm += (len \>\> **PAGE_SHIFT**); 1829 }

. . .

1834 */\**

 

\*. Note that ‘shmem’ implements the RAM-based file systems, most notable of which is tmpfs.



 

1835 *\* New (or expanded) vma always get soft dirty status.* 1836 *\* Otherwise user-space soft-dirty page tracker won't* 1837 *\* be able to distinguish situation when vma area unmapped,* 1838 *\* then new mapped in-place (which must be aimed as* 1839 *\* a completely new data area).* 1840 *\*/*

1841 vma-\>vm_flags \|= **VM_SOFTDIRTY**; 1842

1843 **vma_set_page_prot**(vma); 1844

1845 **return** addr;

1846

1847 **unmap_and_free_vma**:

1848 **fput**(vma-\>vm_file); 1849 vma-\>vm_file = **NULL**; 1850

1851 */\* Undo any partial mapping done by a device driver. \*/* 1852 **unmap_region**(mm, vma, prev, vma-\>vm_start, vma-\>vm_end); 1853 **if** (vm_flags & **VM_SHARED**) 1854 **mapping_unmap_writable**(file-\>f_mapping); 1855 **free_vma**:

1856 **vm_area_free**(vma); 1857 **unacct_error**:

1858 **if** (charged)

1859 **vm_unacct_memory**(charged); 1860 **return** error;

1861 }

 

*Listing 5-17:* mm/mmap.c: [*mmap_region()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1681) *error handling and shared logic*

 

Each of the error handling cases effectively undo existing actions as ex-

pected, so we will not examine these closely and instead focus on the out case, i.e. the shared logic for all cases.

We start by updating statistics via [vm_stat_account()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n3277)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n3277) before performing

some checks around [mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html) logic – if the mapping is special (e.g. instances

where [vm_normal_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n612) would return NULL, i.e. those mappings which have no

[struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) (and thus no [struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) associated with them), or are special by being one of the (out scope) instances of being a direct access, hugetlb or

gate mapping, the [VM_LOCKED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n282) is silently cleared.

If the locked mapping is permitted the process address space’s

[struct mm_struct-\>locked_vm](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) field is updated accordingly.

We always set the [soft-dirty](https://kernel.org/doc/html/v6.0/admin-guide/mm/soft-dirty.html) VMA flag [VM_SOFTDIRTY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n301), as otherwise as the

comment indicates, there is no means by which userland can correctly ac-count for memory being unmapped then freshly mapped in place.

Finally, the [struct vm_area_struct-\>vm_page_prot](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) field of the VMA, used to

determine the protection bits for the PTE entries used to map in this map-

ping are set by [vma_set_page_prot()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n90) as shown in Listing 5-18.

 

89 */\* Update vma-\>vm_page_prot to reflect vma-\>vm_flags. \*/*

 



 

90 **void vma_set_page_prot**(**struct** vm_area_struct \*vma)

91 {

92 **unsigned long** vm_flags = vma-\>vm_flags;

93 **pgprot_t** vm_page_prot;

94

95 vm_page_prot = **vm_pgprot_modify**(vma-\>vm_page_prot, vm_flags);

96 **if** (**vma_wants_writenotify**(vma, vm_page_prot)) {

97 vm_flags &= ~**VM_SHARED**;

98 vm_page_prot = **vm_pgprot_modify**(vm_page_prot, vm_flags);

99 }

100 */\* remove_protection_ptes reads vma-\>vm_page_prot without mmap_lock \*/*

101 **WRITE_ONCE**(vma-\>vm_page_prot, vm_page_prot); 102 }

 

*Listing 5-18:* mm/mmap.c: [*vma_set_page_prot()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n90)

 

This establishes page protection flags as determined by

[vm_pgprot_modify() , ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n84)which again sets the flags according to the architecture-

specific [vm_get_page_prot()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgprot.c?h=v6.0#n35) function (again, described in detail in the virtual

memory chapter in section 3.1.3), but also establishes that a read-only page

fault will occur for file systems which require write notification for shared,

writable pages, checked via [vma_wants_writenotify()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1630).

This is vital, as the majority of physically-backed file systems must be

aware of a dirty page being written to so they know to write them back to

disk at some later point. This process is known as **dirty tracking**, and is es-

tablished here by setting flags as if [VM_SHARED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n269) was not specified, which de-

faults to a read only mapping (this is intended for Copy-on-Write mappings

but doubles up usefully here for write notify shared ones).

Examining [vma_wants_writenotify()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1630) as shown in Listing 5-19.

 

1624 */\**

1625 *\* Some shared mappings will want the pages marked read-only* 1626 *\* to track write events. If so, we'll downgrade vm_page_prot* 1627 *\* to the private version (using protection_map\[\] without the* 1628 *\* VM_SHARED bit).*

1629 *\*/*

1630 **int vma_wants_writenotify**(**struct** vm_area_struct \*vma, **pgprot_t** vm_page_prot) 1631 {

1632 vm_flags_t vm_flags = vma-\>vm_flags; 1633 **const struct** vm_operations_struct \*vm_ops = vma-\>vm_ops; 1634

1635 */\* If it was private or non-writable, the write bit is already clear*

*\*/*

1636 **if** ((vm_flags & (**VM_WRITE**\|**VM_SHARED**)) != ((**VM_WRITE**\|**VM_SHARED**))) 1637 **return** 0; 1638

1639 */\* The backer wishes to know when pages are first written to? \*/* 1640 **if** (vm_ops && (vm_ops-\>**page_mkwrite** \|\| vm_ops-\>**pfn_mkwrite**)) 1641 **return** 1;

 



 

1642

1643 */\* The open routine did something to the protections that*

*pgprot_modify*

1644 *\* won't preserve? \*/* 1645 **if** (**pgprot_val**(vm_page_prot) != 1646 **pgprot_val**(**vm_pgprot_modify**(vm_page_prot, vm_flags))) 1647 **return** 0; 1648

1649 */\**

1650 *\* Do we need to track softdirty? hugetlb does not support softdirty*

1651 *\* tracking yet.*

1652 *\*/*

1653 **if** (**vma_soft_dirty_enabled**(vma) && !**is_vm_hugetlb_page**(vma)) 1654 **return** 1; 1655

1656 */\* Specialty mapping? \*/* 1657 **if** (vm_flags & **VM_PFNMAP**) 1658 **return** 0; 1659

1660 */\* Can the mapping track the dirty pages? \*/* 1661 **return** vma-\>vm_file && vma-\>vm_file-\>f_mapping && 1662 **mapping_can_writeback**(vma-\>vm_file-\>f_mapping); 1663 }

 

*Listing 5-19:* mm/mmap.c: [*vma_wants_writenotify()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1630)

Write notify is only applicable to write-shared mappings, so we only pro-

ceed with the check if the mapping is write-shared. In all instances of a write-

shared mapping possessing the [struct vm_operations_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n539) page_mkwrite or pfn_mkwrite (for special mappings) handlers provided for by a file system, then write notify naturally must be enabled.

The rest of the function deals with various edge cases – if the read-only

flag simply won’t be preserved, then we cannot enable write-notify, other-

wise we check to see if [soft-dirty](https://kernel.org/doc/html/v6.0/admin-guide/mm/soft-dirty.html) is enabled via [vma_soft_dirty_enabled()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n867) (which

confusingly checks to see whether [VM_SOFTDIRTY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n301) is cleared – because that indi-cates that the page is not soft-dirty and we need write notification to deter-mine when it becomes dirtied). We do not do this in the hugetlb case as this does not support soft-dirty.

If the mapping is special, i.e. the underlying memory it maps is not de-

scribed by [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) objects, and pfn_mkwrite has not been specified, then we have no need for write notification.

Finally, if the mapping is file-backed and the mapping’s associated

[struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) object is capable of writeback (see the page cache chapter for more on this), we assume write notification is required.

 

***5.0.5 Choosing where to map***

In order to determine which unmapped area in which to place a new map-

ping the function function [get_unmapped_area()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2209) is invoked in Listing 5-20.

 



 

2208 **unsigned long**

2209 **get_unmapped_area**(**struct** file \*file, **unsigned long** addr, **unsigned long** len, 2210 **unsigned long** pgoff, **unsigned long** flags) 2211 {

2212 **unsigned long** (\***get_area**)(**struct** file \*, **unsigned long**, 2213 **unsigned long**, **unsigned long**, **unsigned long**)

;

2214

2215 **unsigned long** error = **arch_mmap_check**(addr, len, flags); 2216 **if** (error)

2217 **return** error; 2218

2219 */\* Careful about overflows.. \*/* 2220 **if** (len \> **TASK_SIZE**) 2221 **return**-**ENOMEM**; 2222

2223 **get_area** = current-\>mm-\>**get_unmapped_area**; 2224 **if** (file) {

2225 **if** (file-\>f_op-\>**get_unmapped_area**) 2226 **get_area** = file-\>f_op-\>**get_unmapped_area**; 2227 } **else if** (flags & **MAP_SHARED**) { 2228 */\**

2229 *\* mmap_region() will call shmem_zero_setup() to create a file*

*,*

2230 *\* so use shmem's get_unmapped_area in case it can be huge.*

2231 *\* do_mmap() will clear pgoff, so match alignment.* 2232 *\*/*

2233 pgoff = 0; 2234 **get_area** = **shmem_get_unmapped_area**; 2235 }

2236

2237 addr = **get_area**(file, addr, len, pgoff, flags); 2238 **if** (**IS_ERR_VALUE**(addr)) 2239 **return** addr; 2240

2241 **if** (addr \> **TASK_SIZE**- len) 2242 **return**-**ENOMEM**; 2243 **if** (**offset_in_page**(addr)) 2244 **return**-**EINVAL**; 2245

2246 error = **security_mmap_addr**(addr); 2247 **return** error ? error : addr; 2248 }

 

*Listing 5-20:* mm/mmap.c: [*get_unmapped_area()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2209)

 

This function either returns a virtual address to place a mapping target-

ing address addr (which will be equal to zero should no specific address hint

 



 

be provided), of size len bytes, at a page offset within the mapping of pgoff,

with [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) flags supplied in the flags parameter, or an error value.

An architecture-specific check is performed via [arch_mmap_check()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n63)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n63) how-

ever for x86-64 this is a no-op. After checking to ensure that the specified length is sane, we determine which function to use:

 

• If file-backed and the [struct file-\>f_op](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) (of type [struct file_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2093))

file operations object contains a get_unmapped_area function, we use this. This is usually a function which ultimately calls the general unmapped area handler, but augments it for the specific purposes of the file sys-tem.

• If not file-backed, but MAP_SHARED is specified (i.e. this is an anonymous,

shared mapping), the shmem\*-specific function [shmem_get_unmapped_area()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/shmem.c?h=v6.0#n2135) is called, which ultimately invokes the general unmapped area handler below with some additional handling for huge pages.

• Otherwise, the general unmapped area handler is invoked, which is

specified in the [struct mm_struct-\>get_unmapped_area](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) field.

 

The general unmapped area handler is determined early in a process’s

life in [setup_new_exec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/exec.c?h=v6.0#n1433) which invokes [arch_pick_mmap_layout()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/mmap.c?h=v6.0#n129)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/mmap.c?h=v6.0#n129) As the name implies, this is architecture-specific. For x86-64, this specifies the use of

[arch_get_unmapped_area_topdown()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/sys_x86_64.c?h=v6.0#n161) unless it is a legacy mmap() invocation, de-

termined by [mmap_is_legacy()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/mmap.c?h=v6.0#n62)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/mmap.c?h=v6.0#n62) in which case [arch_get_unmapped_area()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/sys_x86_64.c?h=v6.0#n123) is used instead.

Examining [mmap_is_legacy()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/mmap.c?h=v6.0#n62) as shown in Listing 5-21.

 

62 **static int mmap_is_legacy**(**void**) 63 {

64 **if** (current-\>personality & **ADDR_COMPAT_LAYOUT**) 65 **return** 1; 66

67 **return sysctl_legacy_va_layout**; 68 }

 

*Listing 5-21:* arch/x86/mm/mmap.c: [*mmap_is_legacy()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/mmap.c?h=v6.0#n62)

This will result in a legacy mmap if the [personality](https://man7.org/linux/man-pages/man2/personality.2.html) of the process speci-

fies ADDR_COMPAT_LAYOUT, or if the sysctl tunable vm.legacy_va_layout is set. This

can be set using the [setarch](https://man7.org/linux/man-pages/man8/setarch.8.html) CLI tool.

Examining the general unmapped area handler used for all but legacy

cases, [arch_get_unmapped_area_topdown()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/sys_x86_64.c?h=v6.0#n161) (this is architecture-specific, so as usual we limit ourselves to the x86-64 case for brevity) as shown in Listing

5-22.

 

160 **unsigned long**

161 **arch_get_unmapped_area_topdown**(**struct** file \*filp, **const unsigned long** addr0, 162 **const unsigned long** len, **const unsigned long** pgoff,

 

\*. shmem is the filesystem which underlies tmpfs and ramfs.



 

163 **const unsigned long** flags) 164 {

165 **struct** vm_area_struct \*vma; 166 **struct** mm_struct \*mm = current-\>mm; 167 **unsigned long** addr = addr0; 168 **struct** vm_unmapped_area_info info;

169

170 */\* requested length too big for entire address space \*/* 171 **if** (len \> **TASK_SIZE**) 172 **return**-**ENOMEM**;

173

174 */\* No address checking. See comment at mmap_address_hint_valid() \*/*

175 **if** (flags & **MAP_FIXED**) 176 **return** addr;

177

178 */\* for MAP_32BIT mappings we force the legacy mmap base \*/* 179 **if** (!**in_32bit_syscall**() && (flags & **MAP_32BIT**)) 180 **goto bottomup**;

181

182 */\* requesting a specific address \*/* 183 **if** (addr) {

184 addr &= **PAGE_MASK**; 185 **if** (!**mmap_address_hint_valid**(addr, len)) 186 **goto get_unmapped_area**;

187

188 vma = **find_vma**(mm, addr); 189 **if** (!vma \|\| addr + len \<= **vm_start_gap**(vma)) 190 **return** addr; 191 }

192 **get_unmapped_area**:

193

194 info.flags = **VM_UNMAPPED_AREA_TOPDOWN**; 195 info.length = len; 196 info.low_limit = **PAGE_SIZE**; 197 info.high_limit = **get_mmap_base**(0);

198

199 */\**

200 *\* If hint address is above DEFAULT_MAP_WINDOW, look for unmapped area*

201 *\* in the full address space.* 202 *\**

203 *\* !in_32bit_syscall() check to avoid high addresses for x32* 204 *\* (and make it no op on native i386).* 205 *\*/*

206 **if** (addr \> **DEFAULT_MAP_WINDOW** && !**in_32bit_syscall**()) 207 info.high_limit += **TASK_SIZE_MAX**-**DEFAULT_MAP_WINDOW**;

208

209 info.align_mask = 0;

 



 

210 info.align_offset = pgoff \<\< **PAGE_SHIFT**; 211 **if** (filp) {

212 info.align_mask = **get_align_mask**(); 213 info.align_offset += **get_align_bits**(); 214 }

215 addr = **vm_unmapped_area**(&info); 216 **if** (!(addr & ~**PAGE_MASK**)) 217 **return** addr; 218 **VM_BUG_ON**(addr != -**ENOMEM**); 219

220 **bottomup**:

221 */\**

222 *\* A failed mmap() very likely causes application failure,* 223 *\* so fall back to the bottom-up function here. This scenario* 224 *\* can happen with large stack limits and large mmap()* 225 *\* allocations.*

226 *\*/*

227 **return arch_get_unmapped_area**(filp, addr0, len, pgoff, flags); 228 }

 

*Listing 5-22:* *x86-64-specific* *arch/x86/kernel/sys_x86_64.c**: x86-64-specific*

[*arch_get_unmapped_area_topdown()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/sys_x86_64.c?h=v6.0#n161)

 

We start by performing a basic sanity check – if the length exceeds the

entire permitted virtual address range, then this mapping is clearly invalid and we error out. This kind of check is largely useful for corrupted inputs, as a functioning user would never specify such a significantly incorrect parame-ter.

If the user has specified MAP_FIXED, there is no work to do, so we simply

exit. Equally, if this is a mapping that is limited to 32-bits via MAP_32BIT, we force the legacy bottom-up approach.

We then handle the case of a hint being provided (i.e. the [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) function

being invoked with a non-NULL addr parameter, but with MAP_FIXED not having been specified). Firstly, we page-align the address as this is a strict require-ment of any mmap() mapping.

Next, [mmap_address_hint_valid()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/mmap.c?h=v6.0#n209) is called to ensure the hint is sensible –

this checks to ensure the mapping would not exceed the maximum address-able virtual range and that a mapping does not straddle the 4-level and 5-level x86-64 mapping ranges as this could cause difficult bugs to arise.

Finally, we check to see if the hint would overlap a VMA (including any

stack guard gap) – if it does we simply obtain the appropriate address using the unmapped area logic as if it were not specified. Otherwise, if no overlap, we use the (page-aligned) hint as supplied.

Ultimately, we specify a valid range – from a minimum of 1 page into the

virtual address space (to permit NULL pointers to address 0 to function) to the

base mmap address obtained by [get_mmap_base()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/mmap.c?h=v6.0#n153) which simply retrieves the

[struct mm_struct-\>mmap_base](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) value for the process address space.

This mmap_base parameter is determined by [arch_pick_mmap_layout()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/mmap.c?h=v6.0#n129)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/mmap.c?h=v6.0#n129)

invoked by [setup_new_exec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/exec.c?h=v6.0#n1433) when a process is initially executed. The

 



 

[arch_pick_mmap_base()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/mmap.c?h=v6.0#n118) function is called to obtain this base, which ultimately

invokes [mmap_base()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/mmap.c?h=v6.0#n82) as shown in Listing 5-23.

 

82 **static unsigned long mmap_base**(**unsigned long** rnd, **unsigned long** task_size,

83 **struct** rlimit \*rlim_stack)

84 {

85 **unsigned long** gap = rlim_stack-\>rlim_cur;

86 **unsigned long** pad = **stack_maxrandom_size**(task_size) + stack_guard_gap;

87 **unsigned long** gap_min, gap_max;

88

89 */\* Values close to RLIM_INFINITY can overflow. \*/*

90 **if** (gap + pad \> gap)

91 gap += pad;

92

93 */\**

94 *\* Top of mmap area (just below the process stack).*

95 *\* Leave an at least ~128 MB hole with possible stack randomization.*

96 *\*/*

97 gap_min = **SIZE_128M**;

98 gap_max = (task_size / 6) \* 5;

99

100 **if** (gap \< gap_min) 101 gap = gap_min; 102 **else if** (gap \> gap_max) 103 gap = gap_max;

104

105 **return PAGE_ALIGN**(task_size - gap - rnd); 106 }

 

*Listing 5-23:* arch/x86/mm/mmap.c: *x86-64 [mmap_base()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/mmap.c?h=v6.0#n82)*

 

This establishes a gap below the top of the maximum virtual address

which will determine the maximum address at which we will assign un-

mapped space to a new mapping.

This is always clamped between 128 MiB and 5 of the maximum virtual

6

address space, in order to provide a sensible gap between the end of the

mapping and the top of the available address space.

This base value is supplemented by a random value for security purposes

for both the mapping itself (represented by rnd) and the stack which is offset

by the maximum size this could be as determined by [stack_maxrandom_size()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/mmap.c?h=v6.0#n41)

(for 64-bit systems this is 1 GiB).

The final result is determined to be the combination of the maximum

stack size and randomisation, the stack guard gap (a gap maintained be-

tween stacks and other mappings in order to ensure one cannot bump up

against the other) and the random bytes up to the maximum amount of en-

tropy as determined by [mmap_rnd_bits](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n69)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n69) specified by CONFIG_ARCH_MMAP_RAND_BITS

which for x86-64 defaults to 28 bits (256 MiB), but which can also be ad-

justed via the vm.mmap_rnd_bits tunable.

 



 

With this value set, an [struct vm_unmapped_area_info](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2677) object is populated

with these bounds and alignment set according to architecture require-

ments, and [vm_unmapped_area()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2074) is called to do the heavy lifting of determin-ing where to place the mapping. For the top-down case (the only one we

are considering here), [unmapped_area_topdown()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1966) is ultimately called (eliding

an align mask check that is not relevant to x86-64) as shown in Listing 5-24.

 

1966 **static unsigned long unmapped_area_topdown**(**struct** vm_unmapped_area_info \*info) 1967 {

1968 **struct** mm_struct \*mm = current-\>mm; 1969 **struct** vm_area_struct \*vma; 1970 **unsigned long** length, low_limit, high_limit, gap_start, gap_end;

. . .

1977 */\**

1978 *\* Adjust search limits by the desired length.* 1979 *\* See implementation comment at top of unmapped_area().* 1980 *\*/*

1981 gap_end = info-\>high_limit; 1982 **if** (gap_end \< length) 1983 **return**-**ENOMEM**; 1984 high_limit = gap_end - length; 1985

1986 **if** (info-\>low_limit \> high_limit) 1987 **return**-**ENOMEM**; 1988 low_limit = info-\>low_limit + length; 1989

1990 */\* Check highest gap, which does not precede any rbtree node \*/* 1991 gap_start = mm-\>highest_vm_end; 1992 **if** (gap_start \<= high_limit) 1993 **goto found_highest**; 1994

1995 */\* Check if rbtree root looks promising \*/* 1996 **if** (**RB_EMPTY_ROOT**(&mm-\>mm_rb)) 1997 **return**-**ENOMEM**; 1998 vma = **rb_entry**(mm-\>mm_rb.rb_node, **struct** vm_area_struct, vm_rb); 1999 **if** (vma-\>rb_subtree_gap \< length) 2000 **return**-**ENOMEM**; 2001

2002 **while** (**true**) {

2003 */\* Visit right subtree if it looks promising \*/* 2004 gap_start = vma-\>vm_prev ? **vm_end_gap**(vma-\>vm_prev) : 0; 2005 **if** (gap_start \<= high_limit && vma-\>vm_rb.rb_right) { 2006 **struct** vm_area_struct \*right = 2007 **rb_entry**(vma-\>vm_rb.rb_right, 2008 **struct** vm_area_struct, vm_rb); 2009 **if** (right-\>rb_subtree_gap \>= length) { 2010 vma = right; 2011 **continue**;

 



 

2012 } 2013 }

2014

2015 **check_current**:

2016 */\* Check if current node has a suitable gap \*/* 2017 gap_end = **vm_start_gap**(vma); 2018 **if** (gap_end \< low_limit) 2019 **return**-**ENOMEM**; 2020 **if** (gap_start \<= high_limit && 2021 gap_end \> gap_start && gap_end - gap_start \>= length) 2022 **goto found**; 2023

2024 */\* Visit left subtree if it looks promising \*/* 2025 **if** (vma-\>vm_rb.rb_left) { 2026 **struct** vm_area_struct \*left = 2027 **rb_entry**(vma-\>vm_rb.rb_left, 2028 **struct** vm_area_struct, vm_rb); 2029 **if** (left-\>rb_subtree_gap \>= length) { 2030 vma = left; 2031 **continue**; 2032 } 2033 }

2034

2035 */\* Go back up the rbtree to find next candidate node \*/* 2036 **while** (**true**) { 2037 **struct** rb_node \*prev = &vma-\>vm_rb; 2038 **if** (!rb_parent(prev)) 2039 **return**-**ENOMEM**; 2040 vma = **rb_entry**(rb_parent(prev), 2041 **struct** vm_area_struct, vm_rb); 2042 **if** (prev == vma-\>vm_rb.rb_right) { 2043 gap_start = vma-\>vm_prev ? 2044 **vm_end_gap**(vma-\>vm_prev) : 0; 2045 **goto check_current**; 2046 } 2047 }

2048 }

2049

2050 **found**:

2051 */\* We found a suitable gap. Clip it with the original high_limit. \*/*

2052 **if** (gap_end \> info-\>high_limit) 2053 gap_end = info-\>high_limit; 2054

2055 **found_highest**:

2056 */\* Compute highest gap address at the desired alignment \*/* 2057 gap_end -= info-\>length;

. . .

 



 

2060 **VM_BUG_ON**(gap_end \< info-\>low_limit); 2061 **VM_BUG_ON**(gap_end \< gap_start); 2062 **return** gap_end;

2063 }

 

*Listing 5-24:* mm/mmap.c: [*unmapped_area_topdown()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1966)

 

Firstly it’s worth examining the comment referenced by the code from

the bottom-up version of the function, [unmapped_area()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1863) as shown in Listing

5-25.

 

1865 */\**

1866 *\* We implement the search by looking for an rbtree node that* 1867 *\* immediately follows a suitable gap. That is,* 1868 *\* - gap_start = vma-\>vm_prev-\>vm_end \<= info-\>high_limit - length;*

1869 *\* - gap_end* *= vma-\>vm_start* *\>= info-\>low_limit* *+ length;* 1870 *\* - gap_end - gap_start \>= length* 1871 *\*/*

 

*Listing 5-25:* mm/mmap.c: [*unmapped_area()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1863) *comment*

 

So it’s important to remember that rather than looking for an address

which has sufficient space for the VMA we wish to insert, we are instead looking for a node with a large enough gap to place it.

We therefore start by establishing high_limit as being equal to the maxi-

mum address (gap_end) less the length of the mapping and low_limit as being equal to the minimum address (info-\>low_limit) plus the length of the map-ping.

We use the cached value [struct mm_struct-\>highest_vm_end](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) to see if we

can simply slot in at the end of mapped values, if so we can proceed to the found_highest label (note that this value takes into account the stack guard

gap determined by [vm_end_gap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2770)[).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2770)

If this check fails, then this means there is not sufficient space at the end

of the address space, and therefore we must find a place to slot in behind an-other VMA.

We therefore have to traverse the tree to find where to place the new

mapping. In each VMA we traverse, we rely entirely on the metadata we

store in each VMA in the [struct vm_area_struct-\>rb_subtree_gap](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) field. This maintains a track of the largest gap either between this VMA and the VMA previous or any of the VMAs below it in the tree.

Throughout the traversal, we maintain gap_start and gap_end as the

bounds of each gap we have found, adjusting them as we go. We offset these

using [vm_start_gap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2758) and [vm_end_gap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2770) (on the VMA prior to the one under examination) which obtain the start/end of the VMA respectively, offsetting by the stack guard gap if the VMAs are stacks, being careful about overflow.

We start by ensuring the root red/black tree node is valid and that at

least one node in the tree has a sufficient gap (by examining the root’s rb_subtree_gap we can determine this immediately).

As we are looking for the largest possible value, we start by always travers-

ing the right node (as a balanced search tree, this will always result in VMAs

 



 

at higher addresses) if there is sufficient subtree gap until we reach a node

without any right sub tree, where the check_current label is declared.

If gap_end is below the lower limit, this means that the gap before the

VMA we are examining is insufficient to contain the candidate mapping so

we must error out. Otherwise, we check to see whether there is sufficient

gap before this VMA.

Note that we are looking to place an entry before the highest node (since

otherwise we would be placing the VMA at the end of the process address

space and we have already checked for this), so we establish gap_start and

gap_end to be equal to the (stack guard adjusted) end of the previous VMA

and the (also stack guard adjusted) beginning of this one – if this can fit the

VMA then we proceed to the found label.

Otherwise, we must traverse any present left nodes, and loop around

again – when we resume the loop, we will prefer to traverse right nodes at

each instance of left node we have traversed so will always trend towards the

VMA at the maximum address with sufficient gap for the mapping.

If the current VMA under examination is a leaf node in the tree and has

an insufficient gap to store the VMA, we traverse back up the tree, looking

for the first instance of a parent VMA for which this node was greater (i.e.

on the right of the tree), then proceeding to examine the left hand nodes of

this one. If this fails to find a parent, then the search fails and we error out.

When we finally find a sufficient gap, we use gap_end to store the end of

the gap (taking into account the stack guard gap), clamped to the original

maximum limit specified, less the length of the mapping, and return this

value.

For the purposes of illustrating this process, let’s examine a tree which

ultimately does not contain a sufficient gap and the order in which nodes

will be traversed as shown in Figure 5-2.

 

6

 

8 4

 

9 7 5 1

 

2

 

3

 

*Figure 5-2: VMA tree gap traversal example*

 

As you can see, the algorithm implemented in [unmapped_area_topdown()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1966)

results in a traversal from ‘rightmost’ node (i.e. the one with the largest ad-

dress) to the leftmost (i.e. the one with the smallest address).

 



 

***5.0.6 Unmapping memory***

Unmapping memory allocated by [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) (or otherwise) can be performed

by [munmap()](https://man7.org/linux/man-pages/man2/munmap.2.html) which accepts a virtual address and length, over which range all VMAs will be removed and reference count dropped on all underlying

pages. This is implemented in the munmap system call as shown in LIsting 5-26.

 

2881 **SYSCALL_DEFINE2**(**munmap**, **unsigned long**, addr, **size_t**, len) 2882 {

2883 addr = **untagged_addr**(addr); 2884 **return \_\_vm_munmap**(addr, len, **true**); 2885 }

 

*Listing 5-26:* mm/mmap.c: [*munmap()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2881) *system call*

 

This defers the unmapping operation to [\_\_vm_munmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2850)\* which acquires a

write lock on [struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) before invoking [\_\_do_munmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2754) to do the heavy lifting (eliding out of scope userfaultfd logic) as shown in Listing

5-27.

 

2850 **static int \_\_vm_munmap**(**unsigned long** start, **size_t** len, **bool** downgrade) 2851 {

2852 **int** ret;

2853 **struct** mm_struct \*mm = current-\>mm; 2854 **LIST_HEAD**(uf);

2855

2856 **if** (**mmap_write_lock_killable**(mm)) 2857 **return**-**EINTR**; 2858

2859 ret = **\_\_do_munmap**(mm, start, len, &uf, downgrade); 2860 */\**

2861 *\* Returning 1 indicates mmap_lock is downgraded.* 2862 *\* But 1 is not legal return value of vm_munmap() and munmap(), reset*

2863 *\* it to 0 before return.* 2864 *\*/*

2865 **if** (ret == 1) {

2866 **mmap_read_unlock**(mm); 2867 ret = 0;

2868 } **else**

2869 **mmap_write_unlock**(mm);

. . .

2872 **return** ret;

2873 }

 

*Listing 5-27:* mm/mmap.c: [*\_\_vm_munmap()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2850)

 

Examining [\_\_do_munmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2754) as shown in Listing 5-28.

 

\*. The untagged_addr() invocation is only relevant to specific architectures which tag virtual addresses for specific purposes and is out of scope here.

 



 

2754 **int \_\_do_munmap**(**struct** mm_struct \*mm, **unsigned long** start, **size_t** len, 2755 **struct** list_head \*uf, **bool** downgrade) 2756 {

2757 **unsigned long** end; 2758 **struct** vm_area_struct \*vma, \*prev, \*last; 2759

2760 **if** ((**offset_in_page**(start)) \|\| start \> **TASK_SIZE** \|\| len \> **TASK_SIZE**-

start)

2761 **return**-**EINVAL**; 2762

2763 len = **PAGE_ALIGN**(len); 2764 end = start + len; 2765 **if** (len == 0)

2766 **return**-**EINVAL**; 2767

2768 */\**

2769 *\* arch_unmap() might do unmaps itself. It must be called* 2770 *\* and finish any rbtree manipulation before this code* 2771 *\* runs and also starts to manipulate the rbtree.* 2772 *\*/*

2773 **arch_unmap**(mm, start, end); 2774

2775 */\* Find the first overlapping VMA where start \< vma-\>vm_end \*/* 2776 vma = **find_vma_intersection**(mm, start, end); 2777 **if** (!vma)

2778 **return** 0; 2779 prev = vma-\>vm_prev; 2780

2781 */\**

2782 *\* If we need to split any vma, do it now to save pain later.* 2783 *\**

2784 *\* Note: mremap's move_vma VM_ACCOUNT handling assumes a partially*

2785 *\* unmapped vm_area_struct will remain in use: so lower split_vma* 2786 *\* places tmp vma above, and higher split_vma places tmp vma below.*

2787 *\*/*

2788 **if** (start \> vma-\>vm_start) { 2789 **int** error; 2790

2791 */\**

2792 *\* Make sure that map_count on return from munmap() will* 2793 *\* not exceed its limit; but let map_count go just above* 2794 *\* its limit temporarily, to help free resources as expected.*

2795 *\*/*

2796 **if** (end \< vma-\>vm_end && mm-\>map_count \>= **sysctl_max_map_count**

)

2797 **return**-**ENOMEM**; 2798

 



 

2799 error = **\_\_split_vma**(mm, vma, start, 0); 2800 **if** (error) 2801 **return** error; 2802 prev = vma; 2803 }

2804

2805 */\* Does it split the last one? \*/* 2806 last = **find_vma**(mm, end); 2807 **if** (last && end \> last-\>vm_start) { 2808 **int** error = **\_\_split_vma**(mm, last, end, 1); 2809 **if** (error) 2810 **return** error; 2811 }

2812 vma = **vma_next**(mm, prev);

. . .

2829 */\* Detach vmas from rbtree \*/* 2830 **if** (!**detach_vmas_to_be_unmapped**(mm, vma, prev, end)) 2831 downgrade = **false**; 2832

2833 **if** (downgrade)

2834 **mmap_write_downgrade**(mm); 2835

2836 **unmap_region**(mm, vma, prev, start, end); 2837

2838 */\* Fix up all other VM information \*/* 2839 **remove_vma_list**(mm, vma); 2840

2841 **return** downgrade ? 1 : 0; 2842 }

 

*Listing 5-28:* mm/mmap.c: [*\_\_do_munmap()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2754)

 

We start by checking that the start value is both page-aligned (via

[offset_in_page()) ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1769)and a valid virtual address (via comparison to [TASK_SIZE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_64_types.h?h=v6.0#n75)), er-roring out if invalid, before checking to ensure no overflow occurs on sum-ming start and len.

Some architectures might hook the unmap operation via [arch_unmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/mm_hooks.h?h=v6.0#n20),

however this is currently only meaning for powerpc.

We identify the first [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) which sits within the

designated range via [find_vma_intersection()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2729) (see 4.4.5 for more on VMA traversal), exiting early if we fail to do so.

While we free memory in the range, we have provided the user with a

free hand as to the address range they’ve specified – there might be multiple VMAs contained within the range, all of which must be freed, and in addi-

tion the range might overlap VMAs as shown in Figure 5-3.

 



 

start start + len

 

*Figure 5-3: munmap() VMA cases*

 

We deal with the overlapping VMAs using [\_\_split_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2676) (see section 5.1.4

for a detailed exploration of VMA splitting), being careful to check to ensure

splitting this way does not result in us exceeding the vm.max_map_count tunable

if the specified range contains only one VMA, which we are now splitting

(this net, incrementing the number of mapped VMAs by one).

Now we have split any overlapping VMAs, we must isolate the VMAs in

the range in order to iterate through them and remove each of them which

we do via [detach_vmas_to_be_unmapped()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2633) (described below). If this returns

true, this indicates that we no longer require a write lock held against the

[struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) semaphore, so we downgrade to a read lock.

Finally, we perform TLB invalidation and reference count deduction

and possible freeing of underlying physical pages via [unmap_region()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2612) (see

section 7.1.1 for an in depth description of this process) before invoking

[remove_vma_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2589) to update statistics and accounted memory (which we will

examine shortly).

Examining [detach_vmas_to_be_unmapped()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2633) as shown in Listing 5-29.

 

2628 */\**

2629 *\* Create a list of vma's touched by the unmap, removing them from the mm's*

2630 *\* vma list as we go..*

2631 *\*/*

2632 **static bool**

2633 **detach_vmas_to_be_unmapped**(**struct** mm_struct \*mm, **struct** vm_area_struct \*vma, 2634 **struct** vm_area_struct \*prev, **unsigned long** end) 2635 {

2636 **struct** vm_area_struct \*\*insertion_point; 2637 **struct** vm_area_struct \*tail_vma = **NULL**; 2638

2639 insertion_point = (prev ? &prev-\>vm_next : &mm-\>mmap); 2640 vma-\>vm_prev = **NULL**; 2641 **do** {

2642 **vma_rb_erase**(vma, &mm-\>mm_rb); 2643 **if** (vma-\>vm_flags & **VM_LOCKED**) 2644 mm-\>locked_vm -= **vma_pages**(vma); 2645 mm-\>map_count--; 2646 tail_vma = vma; 2647 vma = vma-\>vm_next; 2648 } **while** (vma && vma-\>vm_start \< end); 2649 \*insertion_point = vma; 2650 **if** (vma) {

 



 

2651 vma-\>vm_prev = prev; 2652 **vma_gap_update**(vma); 2653 } **else**

2654 mm-\>highest_vm_end = prev ? **vm_end_gap**(prev) : 0; 2655 tail_vma-\>vm_next = **NULL**; 2656

2657 */\* Kill the cache \*/* 2658 **vmacache_invalidate**(mm); 2659

2660 */\**

2661 *\* Do not downgrade mmap_lock if we are next to VM_GROWSDOWN or* 2662 *\* VM_GROWSUP VMA. Such VMAs can change their size under* 2663 *\* down_read(mmap_lock) and collide with the VMA we are about to unmap*

*.*

2664 *\*/*

2665 **if** (vma && (vma-\>vm_flags & **VM_GROWSDOWN**)) 2666 **return false**; 2667 **if** (prev && (prev-\>vm_flags & **VM_GROWSUP**)) 2668 **return false**; 2669 **return true**;

2670 }

 

*Listing 5-29:* mm/mmap.c: [*detach_vmas_to_be_unmapped()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2633)

 

We start by determining the ‘insertion point’, i.e. the pointer which we

must update to reflect the removal of these VMAs. If the range being re-move does not start at the very beginning of the process address space, this

will be a pointer to the previous VMA’s the [struct vm_area_struct-\>vm_next](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403)

field, otherwise it is a pointer to the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)-\>mmap field which which is the beginning of the list of VMAs in the address space.

Next we start the process of detaching the VMAs in the range by set-

ting the first VMA’s vm_prev to NULL and keeping track of the last VMA in the range via tail_vma in order to eventually set its vm_next field to NULL also.

We then loop through each VMA in the range, removing it from the pro-

cess address space’s red/black tree via [vma_rb_erase()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n450) (see section 4.4.4 for more on this), and decrementing the map_count of the process address space.

When this is complete, we place the VMA immediately proceeding the

removed range in the insertion point, update the gap metadata associated with the red/black tree and isolate the tail VMA from the rest of the tree.

Now we have in removed the VMAs from both the red/black tree and

the VMA linked list, they effectively no longer exist. We therefore invalidate

the VMA cache via [vmacache_invalidate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmacache.h?h=v6.0#n23) (see section 4.4.5.1 for more on the VMA cache).

Finally, we determine whether we can downgrade from a write to a read

lock on the [struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) semaphore – if the immediately pro-ceeding VMA is a stack that grows down the preceding one is a stack which grows up, we do not downgrade as stacks can alter their vm_start (if a down-wards growing stack) or vm_end (if an upward growing stack) which could

 



 

cause inadvertent accesses to TLB cache entries not yet invalidated for the

removed range.

Finally, examining [remove_vma_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2589) as shown in Listing 5-30.

 

2583 */\**

2584 *\* Ok - we have the memory areas we should free on the vma list,* 2585 *\* so release them, and do the vma updates.* 2586 *\**

2587 *\* Called with the mm semaphore held.* 2588 *\*/*

2589 **static void remove_vma_list**(**struct** mm_struct \*mm, **struct** vm_area_struct \*vma) 2590 {

2591 **unsigned long** nr_accounted = 0; 2592

2593 */\* Update high watermark before we lower total_vm \*/* 2594 **update_hiwater_vm**(mm); 2595 **do** {

2596 **long** nrpages = **vma_pages**(vma); 2597

2598 **if** (vma-\>vm_flags & **VM_ACCOUNT**) 2599 nr_accounted += nrpages; 2600 **vm_stat_account**(mm, vma-\>vm_flags, -nrpages); 2601 vma = **remove_vma**(vma); 2602 } **while** (vma);

2603 **vm_unacct_memory**(nr_accounted); 2604 **validate_mm**(mm);

2605 }

 

*Listing 5-30:* mm/mmap.c: [*remove_vma_list()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2589)

 

We start by updating the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)-\>hiwater_vm statistic (as we

are about to reduce total_vm so we ensure that keep this consistent) via

[update_hiwater_vm().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2034)

Then, for each VMA to be removed, we update the mm_struct’s exec_vm,

stack_vm and data_vm statistics via [vm_stat_account()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n3277), counting the number of

accounted pages for VMAs which are, in fact accounted. Finally we close and

free each [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) object via [remove_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n137) (which we will examine

shortly).

Once each VMA is processed we update per-CPU Committed_AS statistics

via [vm_unacct_memory()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mman.h?h=v6.0#n78) and, if CONFIG_DEBUG_VM_RB is specified, validate the pro-

cess address space via [validate_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n351)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n351)

Examining [remove_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n137) as shown in Listing 5-31.

 

134 */\**

135 *\* Close a vm structure and free it, returning the next.* 136 *\*/*

137 **static struct** vm_area_struct \***remove_vma**(**struct** vm_area_struct \*vma) 138 {

139 **struct** vm_area_struct \*next = vma-\>vm_next;

 



 

140

141 **might_sleep**();

142 **if** (vma-\>vm_ops && vma-\>vm_ops-\>**close**) 143 vma-\>vm_ops-\>**close**(vma); 144 **if** (vma-\>vm_file) 145 **fput**(vma-\>vm_file); 146 **mpol_put**(**vma_policy**(vma)); 147 **vm_area_free**(vma); 148 **return** next;

149 }

 

*Listing 5-31:* mm/mmap.c: [*remove_vma()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n137)

If the VMA is file-backed and the file system has specified a close func-

tion to be invoked when a VMA is removed, this is called. Equally, if a

[struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) object is associated with this VMA, its reference count is reduced, as is that of any associated NUMA memory policy, before the VMA itself is

freed via [vm_area_free()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n484) (see listing 5-45).

 

**5.1 VMA merge and split**

 

***5.1.1 VMA merge***

Virtual regions of userland memory, represented by [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMAs), are separated both by their location in memory and their attributes

(as determined by [can_vma_merge_before()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1041) and [can_vma_merge_after()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1063)- both of which will examine shortly). When VMAs are mapped/remapped via

[mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html), [mremap()](https://man7.org/linux/man-pages/man2/mremap.2.html) or [brk()](https://man7.org/linux/man-pages/man2/brk.2.html) system calls or when their attributes are changed

by e.g. [mprotect()](https://man7.org/linux/man-pages/man2/mprotect.2.html) we may be able to merge them. This merge operation is

performed by [vma_merge()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1122) (with a write lock on the [struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)

semaphore held), whose primary\* parameters are:

 

• mm – The mm_struct associated with the process.

• prev – The VMA immediately preceding the virtual range to be merged

(or NULL if the inserted VMA will be the first VMA in the address space).

• addr – The first address of either the VMA to be inserted in the address

space or the range whose attributes are being altered.

• end – The exclusive upper bound of this range (i.e. the first virtual ad-

dress which sits above the range but is not a part of it).

• vm_flags – The VMA flags of the region being merged.

 

There are eight possible cases in which a merge can occur (where prev,

area and next are the previous, adjacent and next VMAs respectively):

 

1. New mapping, merge both – prev-\>vm_end is equal to addr, end is equal to

next-\>vm_start and both are mergeable.

 

\*. There are further parameters which we will examine when we look at the function in detail.



 

2. New mapping, merge previous – prev-\>vm_end is equal to addr and prev is

mergeable.

3. New mapping, merge next – end is equal to next-\>vm_start and next is merge-

able.

4. Adjust mapping, merge next, shrink previous – addr is equal to area-\>vm_start,

end is equal to both prev-\>vm_end and next-\>vm_start but only next is mergeable.

5. Adjust mapping, merge previous, shrink current – addr is equal to both

area-\>vm_start and prev-\>vm_end, but only prev is mergeable.

6. Adjust mapping, merge both – addr is equal to both area-\>vm_start and

prev-\>vm_end, end is equal to next-\>vm_start and both prev and next are mergeable.

7. Adjust mapping, merge previous – addr is equal to both area-\>vm_start and

prev-\>vm_end, end is equal to area-\>vm_end and only prev is mergeable.

8. Adjust mapping, merge next – addr is equal to area-\>vm_start, end is equal to

next-\>vm_start and only next is mergeable.

 

We visualise this in Figure 5-4.

 



 

**1. New mapping** merge both

 

**2. New mapping** merge previous

 

**3. New mapping** merge next

 

**4. Adjust mapping** merge next, shrink previous

 

**5. Adjust mapping** merge previous, shrink current

 

**6. Adjust mapping** merge both

 

**7. Adjust mapping** merge previous

 

**8. Adjust mapping** merge next

 

*Figure 5-4:* [*vma_merge()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1122) *merge cases*

 

These cases are each explicitly referenced in the code numbered as

above. Note that the input range simply specifies the range over which we try to either expand existing VMAs to cover, either spanning an empty mem-ory ‘hole’ (cases 1 - 3) or after adjusting the attributes of an existing VMA (cases 4-8).

VMA merging is performed by [vma_merge()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1122). Eliding out of scope user-

faultfd, it is invoked from:

 



 

• [mmap_region()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1681) – When memory is first mapped via [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) then we attempt

to expand existing VMAs to cover the mapped range. This saves us hav-ing to allocate a new VMA and maintains the invariant that immediately adjacent VMAs must possess different attributes (cases 1 - 3).

• [do_brk_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2973) – Similar to the mmap() case, we try to merge the mapped

range with existing VMAs rather than allocate a new one if possible (cases 1 - 3).

• [copy_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n3173) – Used by [remap()](https://man7.org/linux/man-pages/man2/mremap.2.html) to copy a VMA to a new location. We deter-

mine whether the new VMA can be merged in the location to which it has been relocated (cases 1 - 3).

• [mprotect_fixup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mprotect.c?h=v6.0#n539) – Used by [mprotect()](https://man7.org/linux/man-pages/man2/mprotect.2.html) to change the protection flags of

a portion of a VMA. It attempts to merge the newly adjusted memory range with those adjacent, if it cannot then the existing VMA will be split (cases 4 - 8).

• [madvise_update_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n139) – Invoked by [madvise()](https://man7.org/linux/man-pages/man2/madvise.2.html) in cases where the VMA flags

might have changed, in which case an attempt must be made to merge the existing VMA with those adjacent, if it cannot then the existing VMA will be split (cases 4 - 8).

• [mlock_fixup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n404) – When the [mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html) system call might result in the [VM_LOCKED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n282)

flag either being set or cleared (either via [apply_vma_lock_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n468) or

[apply_mlockall_flags()), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n660)we must attempt to merge the adjusted range with adjacent VMAs, or otherwise split the adjusted region (cases 4 - 8).

• [mbind_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mempolicy.c?h=v6.0#n785) – Part of what determines the attributes of a VMA is its

NUMA memory policy (for more on NUMA as a whole, see the NUMA

chapter). Given this is the case, when the [mbind()](https://man7.org/linux/man-pages/man2/mbind.2.html) system call is invoked we must, similar to the other VMA adjustment cases, check whether we can merge the adjusted region with adjacent VMAs, or otherwise me must split it (cases 4 - 8).

 

An important subtlety to note here for functions which adjust a mapping

(i.e. specify an address range which spans an existing VMA) is that the input

address (addr) will either be equal to va_start of a VMA (which will be desig-

nated area), in which case prev will be the VMA prior to the spanned one, or

if offset, prev will specify the VMA which is spanned and can be merged in

case 4 only.

Now we have examined each of the merge cases, let’s examine the

[vma_merge()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1122) function itself as shown in Listing 5-32.

 

1122 **struct** vm_area_struct \***vma_merge**(**struct** mm_struct \*mm, 1123 **struct** vm_area_struct \*prev, **unsigned long** addr, 1124 **unsigned long** end, **unsigned long** vm_flags, 1125 **struct** anon_vma \*anon_vma, **struct** file \*file, 1126 **pgoff_t** pgoff, **struct** mempolicy \*policy, 1127 **struct** vm_userfaultfd_ctx vm_userfaultfd_ctx, 1128 **struct** anon_vma_name \*anon_name) 1129 {

 



 

1130 **pgoff_t** pglen = (end - addr) \>\> **PAGE_SHIFT**; 1131 **struct** vm_area_struct \*area, \*next; 1132 **int** err;

1133

1134 */\**

1135 *\* We later require that vma-\>vm_flags == vm_flags,* 1136 *\* so this tests vma-\>vm_flags & VM_SPECIAL, too.* 1137 *\*/*

1138 **if** (vm_flags & **VM_SPECIAL**) 1139 **return NULL**; 1140

1141 next = **vma_next**(mm, prev); 1142 area = next;

1143 **if** (area && area-\>vm_end == end) */\* cases 6, 7, 8 \*/* 1144 next = next-\>vm_next; 1145

1146 */\* verify some invariant that must be enforced by the caller \*/* 1147 **VM_WARN_ON**(prev && addr \<= prev-\>vm_start); 1148 **VM_WARN_ON**(area && end \> area-\>vm_end); 1149 **VM_WARN_ON**(addr \>= end); 1150

1151 */\**

1152 *\* Can it merge with the predecessor?* 1153 *\*/*

1154 **if** (prev && prev-\>vm_end == addr && 1155 **mpol_equal**(vma_policy(prev), policy) && 1156 **can_vma_merge_after**(prev, vm_flags, 1157 anon_vma, file, pgoff, 1158 vm_userfaultfd_ctx, anon_name)) {

1159 */\**

1160 *\* OK, it can. Can we now merge in the successor as well?*

1161 *\*/*

1162 **if** (next && end == next-\>vm_start && 1163 **mpol_equal**(policy, vma_policy(next)) && 1164 **can_vma_merge_before**(next, vm_flags, 1165 anon_vma, file, 1166 pgoff+pglen, 1167 vm_userfaultfd_ctx,

anon_name) &&

1168 **is_mergeable_anon_vma**(prev-\>anon_vma, 1169 next-\>anon_vma, **NULL**)) { 1170 */\* cases 1, 6 \*/* 1171 err = **\_\_vma_adjust**(prev, prev-\>vm_start, 1172 next-\>vm_end, prev-\>vm_pgoff, **NULL**, 1173 prev); 1174 } **else** */\* cases 2, 5, 7 \*/* 1175 err = **\_\_vma_adjust**(prev, prev-\>vm_start,

 



 

1176 end, prev-\>vm_pgoff, **NULL**, prev); 1177 **if** (err)

1178 **return NULL**; 1179 **khugepaged_enter_vma**(prev, vm_flags); 1180 **return** prev; 1181 }

 

*Listing 5-32:* mm/mmap.c: [*vma_merge()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1122) *preface and predecessor merge*

 

Note that the callers of this function will hold a

[struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) write lock. The callers of this function guar-

antee that the address range specified by addr and end will fulfil one of the

following criteria:

 

• addr-end will span a hole, i.e. unmapped memory (if mergeable, this will

be one of cases 1 - 3).

• addr-end will span a portion of prev (if end is equal to prev-\>end then case

4 may apply if another VMA is immediately adjacent).

• addr will be equal to area-\>vm_start in all other cases (if mergeable then

this will be one of cases 5 - 8).

 

We obtain the VMA after prev using [vma_next()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n532). If prev is NULL (mean-

ing that the input memory range spans either the first VMA in the address

space or the memory hole prior to the first VMA) then it simply obtains the

first VMA via mm_struct-\>mmap.

We then assign area to this VMA, updating next to point at the VMA after

it only if the entire area VMA is spanned by addr and end (cases 6 - 8).

Finally before checking mergeability, we assert some fundamentals – if

the input addr starts prior to prev, ends after area-\>vm_end or nonsensically

addr and end do not represent a valid range of memory then something has

gone horribly wrong.

We start by checking whether we can merge with prev – this covers cases

1, 2, 5 - 7. The general mergeability of prev is determined by [mpol_equal()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mempolicy.h?h=v6.0#n101)

which determines whether NUMA memory policy is equal (see the NUMA

## chapter for more on memory policies), deferring all other mergeability

checks to to [can_vma_merge_after()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1063)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1063)

We then need to differentiate between cases 1 and 6 (where both prev

and next are merged) and all others by checking whether next is mergeable in

the same fashion – checking memory policy and mergeability, only this time

via [can_vma_merge_before()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1041)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1041)

One difference is that [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) mergeability is checked between

prev and next via [is_mergeable_anon_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1015)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1015) We will examine this function in

detail later (and you can read more about anon_vma objects and the reverse

mapping in Chapter 7), but this is the only criteria that isn’t guaranteed to

be compatible between prev and next when both have been determined to be

mergeable with the input address range.

Finally, the heavy lifting of the merge is deferred to [\_\_vma_adjust()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n699). We

will examine this function shortly as well as how it is parameterised.

 



 

If an error occurs when adjusting, we return NULL to indicate no merge

was possible otherwise, since we will have folded the address range into prev we return this as the newly merged VMA.

Let’s examine the cases where we cannot merge with prev as shown in

Listing 5-33.

 

1183 */\**

1184 *\* Can this new request be merged in front of next?* 1185 *\*/*

1186 **if** (next && end == next-\>vm_start && 1187 **mpol_equal**(policy, vma_policy(next)) && 1188 **can_vma_merge_before**(next, vm_flags, 1189 anon_vma, file, pgoff+pglen, 1190 vm_userfaultfd_ctx, anon_name)) {

1191 **if** (prev && addr \< prev-\>vm_end) */\* case 4 \*/* 1192 err = **\_\_vma_adjust**(prev, prev-\>vm_start, 1193 addr, prev-\>vm_pgoff, **NULL**, next); 1194 **else** { */\* cases 3, 8 \*/* 1195 err = **\_\_vma_adjust**(area, addr, next-\>vm_end, 1196 next-\>vm_pgoff - pglen, **NULL**, next); 1197 */\** 1198 *\* In case 3 area is already equal to next and* 1199 *\* this is a noop, but in case 8 "area" has* 1200 *\* been removed and next was expanded over it.* 1201 *\*/* 1202 area = next; 1203 }

1204 **if** (err)

1205 **return NULL**; 1206 **khugepaged_enter_vma**(area, vm_flags); 1207 **return** area; 1208 }

1209

1210 **return NULL**;

1211 }

 

*Listing 5-33:* mm/mmap.c: [*vma_merge()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1122) *successor merge only*

 

We start by checking whether we can merge with next at all as above (only

without performing an additional [is_mergeable_anon_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1015) check) – if we can-not then no merge is possible at all and we indicate this by returning NULL.

Otherwise, we check to see whether the address range spans the end of

prev (case 4), in which case we return area which will have been merged with next and comprises the newly merged VMA carved out of the end of prev and the entirety of next.

Otherwise, in case 3 we will already have assigned area to next and in case

8 we will eliminate area and adjust next to envelop it so in both instances we return next.

 



 

In both cases we again perform the heavy lifting in [\_\_vma_adjust()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n699)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n699) which

we examine in section 5.1.3.

 

***5.1.2 Mergeability***

Once we have established that VMAs are adjacent, we determine whether

a VMA is mergeable with another via [can_vma_merge_after()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1063) when checking

whether a candidate VMA can be merged after prev, or [can_vma_merge_before()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1041)

when checking whether a candidate VMA can be merged before next as

shown in Listing 5-34.

 

1055 */\**

1056 *\* Return true if we can merge this (vm_flags,anon_vma,file,vm_pgoff)* 1057 *\* beyond (at a higher virtual address and file offset than) the vma.* 1058 *\**

1059 *\* We cannot merge two vmas if they have differently assigned (non-NULL)* 1060 *\* anon_vmas, nor if same anon_vma is assigned but offsets incompatible.* 1061 *\*/*

1062 **static int**

1063 **can_vma_merge_after**(**struct** vm_area_struct \*vma, **unsigned long** vm_flags, 1064 **struct** anon_vma \*anon_vma, **struct** file \*file, 1065 **pgoff_t** vm_pgoff, 1066 **struct** vm_userfaultfd_ctx vm_userfaultfd_ctx, 1067 **struct** anon_vma_name \*anon_name) 1068 {

1069 **if** (**is_mergeable_vma**(vma, file, vm_flags, vm_userfaultfd_ctx,

anon_name) &&

1070 **is_mergeable_anon_vma**(anon_vma, vma-\>anon_vma, vma)) { 1071 **pgoff_t** vm_pglen; 1072 vm_pglen = **vma_pages**(vma); 1073 **if** (vma-\>vm_pgoff + vm_pglen == vm_pgoff) 1074 **return** 1; 1075 }

1076 **return** 0;

1077 }

 

*Listing 5-34:* mm/mmap.c: [*can_vma_merge_after()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1063)

 

This defers the heavy lifting to the helper functions [is_mergeable_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n989)

and [is_mergeable_anon_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1015) which we will examine shortly.

Other than these checks, we perform one final one – the virtual page off-

set of the candidate VMA must be equal to that of the previous one (passed

as vma).

[can_vma_merge_before()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1041) is similar but with a simplified vm_pgoff check as we

need only check equality as shown in Listing 5-35.

 

1029 */\**

1030 *\* Return true if we can merge this (vm_flags,anon_vma,file,vm_pgoff)* 1031 *\* in front of (at a lower virtual address and file offset than) the vma.*

 



 

1032 *\**

1033 *\* We cannot merge two vmas if they have differently assigned (non-NULL)*

1034 *\* anon_vmas, nor if same anon_vma is assigned but offsets incompatible.*

1035 *\**

1036 *\* We don't check here for the merged mmap wrapping around the end of*

*pagecache*

1037 *\* indices (16TB on ia32) because do_mmap() does not permit mmap's which*

1038 *\* wrap, nor mmaps which cover the final page at index -1UL.* 1039 *\*/*

1040 **static int**

1041 **can_vma_merge_before**(**struct** vm_area_struct \*vma, **unsigned long** vm_flags, 1042 **struct** anon_vma \*anon_vma, **struct** file \*file, 1043 **pgoff_t** vm_pgoff, 1044 **struct** vm_userfaultfd_ctx vm_userfaultfd_ctx, 1045 **struct** anon_vma_name \*anon_name) 1046 {

1047 **if** (**is_mergeable_vma**(vma, file, vm_flags, vm_userfaultfd_ctx,

anon_name) &&

1048 **is_mergeable_anon_vma**(anon_vma, vma-\>anon_vma, vma)) { 1049 **if** (vma-\>vm_pgoff == vm_pgoff) 1050 **return** 1; 1051 }

1052 **return** 0;

1053 }

 

*Listing 5-35:* mm/mmap.c: [*can_vma_merge_before()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1041)

 

The mergeability of a VMA is fundamentally determined by the predi-

cate function [is_mergeable_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n989) as shown in Listing 5-36.

 

985 */\**

986 *\* If the vma has a -\>close operation then the driver probably needs to*

*release*

987 *\* per-vma resources, so we don't attempt to merge those.* 988 *\*/*

989 **static inline int is_mergeable_vma**(**struct** vm_area_struct \*vma, 990 **struct** file \*file, **unsigned long** vm_flags, 991 **struct** vm_userfaultfd_ctx vm_userfaultfd_ctx, 992 **struct anon_vma_name** \*anon_name) 993 {

994 */\**

995 *\* VM_SOFTDIRTY should not prevent from VMA merging, if we* 996 *\* match the flags but dirty bit -- the caller should mark* 997 *\* merged VMA as dirty. If dirty bit won't be excluded from* 998 *\* comparison, we increase pressure on the memory system forcing*

999 *\* the kernel to generate new VMAs when old one could be*

1000 *\* extended instead.* 1001 *\*/*

1002 **if** ((vma-\>vm_flags ^ vm_flags) & ~**VM_SOFTDIRTY**)

 



 

1003 **return** 0; 1004 **if** (vma-\>vm_file != file) 1005 **return** 0; 1006 **if** (vma-\>vm_ops && vma-\>vm_ops-\>close) 1007 **return** 0; 1008 **if** (!**is_mergeable_vm_userfaultfd_ctx**(vma, vm_userfaultfd_ctx)) 1009 **return** 0; 1010 **if** (!**anon_vma_name_eq**(**anon_vma_name**(vma), anon_name)) 1011 **return** 0; 1012 **return** 1;

1013 }

 

*Listing 5-36:* mm/mmap.c: [*is_mergeable_vma()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n989)

 

Note that this check is essentially determining whether two VMAs are

effectively identical. We maintain this state in each VMA so that we can de-

scribe virtual memory ranges using as little space as possible, which is why

we merge identical VMAs in the first instance.

Examining each of these criteria (other than out of scope userfaultfd

handling):

 

1. vm_flags must be equal, excluding VM_SOFTDIRTY which, as the comment

describes, is not worth the added memory pressure of treating it as the basis for otherwise identical VMAs being separate from one another.

For example, when initially mapping memory in [mmap_region()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1681) or

[do_brk_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2973) the VM_SOFTDIRTY flag is set unconditionally, so the flag is maintained correctly.

2. vm_file – If file-backed, the VMAs must be backed by the same file.

3. vm_ops-\>close – If VMA operations are provided (i.e. this is a non-

anonymous mapping), the existence of a close() handler implies that, as per the comment, the driver implementing this probably has distinct per-VMA state, so merging is not safe.

This function, if specified, is invoked in [remove_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n137) (which is ultimately invoked on unmap or when the process memory is torn down).

4. anon_vma_name – Anonymous VMAs can be specifically named when the

region serves a specific purpose, e.g. stack, heap (shown in square brack-ets in /proc/\$pid/maps and /proc/\$pid/smaps). Naturally, anonymous VMAs are not mergeable with one another if the names differ.

 

Finally, we have specific handling to ensure that reverse-mapping

[struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) objects (see Chapter 7) associated with each VMA are equiv-

alent, via [is_mergeable_anon_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1015) (see listing 7-19). This is discussed in detail

in the reverse mapping section 7.0.11.

 

***5.1.3 VMA adjust***

The [\_\_vma_adjust()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n699) function is parameterised as shown in Table 5-1.

 



 

Table 5-1: [\_\_vma_adjust()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n699) parameters

Parameter Case

1 2 3 4 5 6 7 8

vma prev next prev area start prev-\>vm_start addr prev-\>vm_start addr end next-\>vm_end end next-\>vm_end addr end next-\>vm_end area-\>vm_end next-\>vm_end

pgoff prev-\>vm_pgoff *⋆* prev-\>vm_pgoff *⋆* insert NULL expand prev next prev next

*⋆* next-\>vm_pgoff - (end - addr) \>\> PAGE_SHIFT

 

Examining each parameter:

 

• vma – The VMA which will be adjusted to become the newly merged

VMA.

• start – The address at which the newly merged mapping will begin (i.e.

the merged VMA’s vm_start).

• end – The exclusive bound of the newly merged mapping (i.e. the

merged VMA’s vm_end).

• pgoff – The merged VMA’s vm_pgoff.

• insert – The VMA to insert. Not used in the merging logic.

• expand – The VMA to expand (either forwards or backwards) in order to

obtain the newly merged VMA.

 

The [\_\_vma_adjust()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n699) function is huge, so let’s look at it piece-by-piece (elid-

ing out of scope uprobe and huge page handling).

We begin by determining what to do with the VMA that follows vma, in

the cases where we are not inserting a VMA (i.e. merge cases). Let’s start by taking a look at the code, then we’ll try to unpack it as best we can as shown

in Listing 5-37.

 

692 */\**

693 *\* We cannot adjust vm_start, vm_end, vm_pgoff fields of a vma that* 694 *\* is already present in an i_mmap tree without adjusting the tree.* 695 *\* The following helper function should be used when such adjustments* 696 *\* are necessary. The "insert" vma (if any) is to be inserted* 697 *\* before we drop the necessary locks.* 698 *\*/*

699 **int \_\_vma_adjust**(**struct** vm_area_struct \*vma, **unsigned long** start, 700 **unsigned long** end, **pgoff_t** pgoff, **struct** vm_area_struct \*insert, 701 **struct** vm_area_struct \*expand) 702 {

703 **struct** mm_struct \*mm = vma-\>vm_mm; 704 **struct** vm_area_struct \*next = vma-\>vm_next, \*orig_vma = vma; 705 **struct** address_space \*mapping = **NULL**; 706 **struct** rb_root_cached \*root = **NULL**; 707 **struct** anon_vma \*anon_vma = **NULL**;

 



 

708 **struct** file \*file = vma-\>vm_file; 709 **bool** start_changed = **false**, end_changed = **false**; 710 **long** adjust_next = 0; 711 **int** remove_next = 0;

712

713 **if** (next && !insert) { 714 **struct** vm_area_struct \*exporter = **NULL**, \*importer = **NULL**;

715

716 **if** (end \>= next-\>vm_end) { 717 */\** 718 *\* vma expands, overlapping all the next, and* 719 *\* perhaps the one after too (mprotect case 6).* 720 *\* The only other cases that gets here are* 721 *\* case 1, case 7 and case 8.* 722 *\*/* 723 **if** (next == expand) { 724 */\** 725 *\* The only case where we don't expand "vma"*

726 *\* and we expand "next" instead is case 8.*

727 *\*/* 728 **VM_WARN_ON**(end != next-\>vm_end); 729 */\** 730 *\* remove_next == 3 means we're* 731 *\* removing "vma" and that to do so we* 732 *\* swapped "vma" and "next".* 733 *\*/* 734 remove_next = 3; 735 **VM_WARN_ON**(file != next-\>vm_file); 736 **swap**(vma, next); 737 } **else** { 738 **VM_WARN_ON**(expand != vma); 739 */\** 740 *\* case 1, 6, 7, remove_next == 2 is case 6,*

741 *\* remove_next == 1 is case 1 or 7.* 742 *\*/* 743 remove_next = 1 + (end \> next-\>vm_end); 744 **VM_WARN_ON**(remove_next == 2 && 745 end != next-\>vm_next-\>vm_end); 746 */\* trim end to next, for case 6 first pass \*/*

747 end = next-\>vm_end; 748 }

749

750 exporter = next; 751 importer = vma;

752

753 */\**

 



 

754 *\* If next doesn't have anon_vma, import from vma*

*after*

755 *\* next, if the vma overlaps with it.* 756 *\*/* 757 **if** (remove_next == 2 && !next-\>anon_vma) 758 exporter = next-\>vm_next; 759

760 } **else if** (end \> next-\>vm_start) { 761 */\** 762 *\* vma expands, overlapping part of the next:* 763 *\* mprotect case 5 shifting the boundary up.* 764 *\*/* 765 adjust_next = (end - next-\>vm_start); 766 exporter = next; 767 importer = vma; 768 **VM_WARN_ON**(expand != importer); 769 } **else if** (end \< vma-\>vm_end) { 770 */\** 771 *\* vma shrinks, and !insert tells it's not* 772 *\* split_vma inserting another: so it must be* 773 *\* mprotect case 4 shifting the boundary down.* 774 *\*/* 775 adjust_next = -(vma-\>vm_end - end); 776 exporter = vma; 777 importer = next; 778 **VM_WARN_ON**(expand != importer); 779 }

 

*Listing 5-37:* mm/mmap.c: [*\_\_vma_adjust()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n699) *initialisation*

 

Within this function we declare the following local variables (frustrat-

ingly next is declared here and differs from [vma_merge()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1122) in some cases, in all

descriptions below next refers to [\_\_vma_adjust()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n699)’s next:

 

• next – The VMA immediately after vma (importantly, note that this is not

always equal to the next VMA declared in vma_merge(), we will address this below).

• adjust_next – The number of bytes by which we offset next-\>vm_start (re-

ducing this value in case 4 and increasing it in case 5), as well equiva-lently updating the page delta in next-\>vm_pgoff. Only relevant in cases 4 and 5.

• remove_next denotes the following:

**–** 0 – No VMA removal will occur (cases 2 -5). **–** 1 – next will be removed (cases 1, 7) **–** 2 – next and next-\>vm_next will be removed (case 6). **–** 3 – vma and next have been swapped. The original next will be re-

moved (case 8).

 



 

This is rather intricate and confusing, not helped by the fact that next

is defined differently from the next within vma_merge() and that in case 8 we

swap vma and next.

It’s a good idea when trying to understand this code to constantly refer

back to figure 5-4 as the code (and consequently the book) repeatedly refers

to the numbered cases.

To make life easier, let’s look at an expanded version of figure 5-1, re-

moving the insert parameter which is always NULL and pgoff and adding next,

adjust_next and remove_next (note that in case 8 vma and next are swapped. we

show the post-swap state). We examine this in table 5-2.

 

Table 5-2: [\_\_vma_adjust()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n699) internal variables (relative to [vma_merge()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1122)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1122)

Variable Case

1 2 3 4 5 6 7 8

vma prev next prev next *∗* *Internal* next next next-\>vm_next next area area *∗* adjust_next 0 0 *∗∗ †* remove_next 1 0 2 1 3 start prev-\>vm_start addr prev-\>vm_start addr end next-\>vm_end end next-\>vm_end addr end next-\>vm_end area-\>vm_end next-\>vm_end *‡* expand prev next prev next exporter next NULL prev area area area *††* importer prev NULL next prev next

 

Note that the references to next within the table refer to next as declared

in [vma_merge()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1122)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1122)

Key:

 

• *∗* – case 8 – Indicates that the vma (originally area) and next (originally

next ) parameters have been swapped.

• *∗∗* – case 4 – The **negative** value addr - prev-\>vm_end indicating the num-

ber of bytes next-\>vm_start must be offset by to expand the next VMA. next-\>vm_pgoff is updated accordingly too.

• *†* – case 5 – The **positive** value end - area-\>vm_start indicating the num-

ber of bytes area-\>vm_start must be offset by (i.e. shrunk) to accommo-date the expanded prev VMA. next-\>vm_pgoff is updated accordingly too.

• *‡* – case 6 – The operation is performed in two passes – the first pass sets

end to area-\>vm_end and the second sets it to next-\>vm_end.

• *††* – case 6 – If area has no anon_vma field, then exporter is set to next.

 

The purpose of the code above is to initialise these values in the case

where no insertion is occurring (which is true of merge) and the internal

next value is not NULL.

The exporter and importer variables are used to handle an edge case as

shown in Listing 5-38.

 

781 */\**

782 *\* Easily overlooked: when mprotect shifts the boundary,*

 



 

783 *\* make sure the expanding vma has anon_vma set if the* 784 *\* shrinking vma had, to cover any anon pages imported.* 785 *\*/*

786 **if** (exporter && exporter-\>anon_vma && !importer-\>anon_vma) { 787 **int** error; 788

789 importer-\>anon_vma = exporter-\>anon_vma; 790 error = **anon_vma_clone**(importer, exporter); 791 **if** (error) 792 **return** error; 793 }

794 }

 

*Listing 5-38:* mm/mmap.c: [*\_\_vma_adjust()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n699) *importer/exporter*

 

This ensures that the [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) object state is propagated from a

merging source (the exporter) to a merged destination (the importer). See

## Chapter 7 for more on these objects and how they relate to the reverse map-ping.

Now we have established the initial status of the VMA adjustment, it’s

time to perform the heavy lifting as shown in Listing 5-39.

 

795 **again**:

. . .

798 **if** (file) {

799 mapping = file-\>f_mapping; 800 root = &mapping-\>i_mmap;

. . .

806 **i_mmap_lock_write**(mapping); 807 **if** (insert) { 808 */\** 809 *\* Put into interval tree now, so instantiated pages*

810 *\* are visible to arm/parisc \_\_flush_dcache_page* 811 *\* throughout; but we cannot insert into address* 812 *\* space until vma start or end is updated.* 813 *\*/* 814 **\_\_vma_link_file**(insert); 815 }

816 }

817

818 anon_vma = vma-\>anon_vma; 819 **if** (!anon_vma && adjust_next) 820 anon_vma = next-\>anon_vma; 821 **if** (anon_vma) {

822 **VM_WARN_ON**(adjust_next && next-\>anon_vma && 823 anon_vma != next-\>anon_vma); 824 **anon_vma_lock_write**(anon_vma); 825 **anon_vma_interval_tree_pre_update_vma**(vma); 826 **if** (adjust_next)

 



 

827 **anon_vma_interval_tree_pre_update_vma**(next); 828 }

829

830 **if** (file) {

831 **flush_dcache_mmap_lock**(mapping); 832 **vma_interval_tree_remove**(vma, root); 833 **if** (adjust_next) 834 **vma_interval_tree_remove**(next, root); 835 }

836

837 **if** (start != vma-\>vm_start) { 838 vma-\>vm_start = start; 839 start_changed = **true**; 840 }

841 **if** (end != vma-\>vm_end) { 842 vma-\>vm_end = end; 843 end_changed = **true**; 844 }

845 vma-\>vm_pgoff = pgoff; 846 **if** (adjust_next) { 847 next-\>vm_start += adjust_next; 848 next-\>vm_pgoff += adjust_next \>\> **PAGE_SHIFT**; 849 }

850

851 **if** (file) {

852 **if** (adjust_next) 853 **vma_interval_tree_insert**(next, root); 854 **vma_interval_tree_insert**(vma, root); 855 **flush_dcache_mmap_unlock**(mapping); 856 }

 

*Listing 5-39:* mm/mmap.c: [*\_\_vma_adjust()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n699) *VMA update*

This is prefixed with the again label which is used in case 6 to perform

multiple passes to merge both the previous and next VMAs.

Let’s examine what is happening here:

 

• If vma is file-backed, we place the file’s [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) page cache

object into mapping, the root of the VMA interval tree in root and then

acquire its lock via [i_mmap_lock_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n464) (acquiring a write lock on the mapping-\>i_mmap_rwsem semaphore). If this is an insertion rather than a merge we cover a corner case for spe-cific architectures.

• When VMAs are adjusted, we must reconstruct the interval trees associ-

ated with them which are used to look up VMAs from the folio as part

of the reverse mapping between folios and VMAs (see Chapter 7 for a deeper discussion of this).

This is necessary, as these are keyed on vm_start which is about to

change. The [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) object tracks anonymous mappings, and

 



 

thus, prior to adjustment, we remove all entries in the anon_vma interval

tree via [anon_vma_interval_tree_pre_update_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n471). A write lock is also ac-quired over the anon_vma tree (maintained to account for forked Copy on

Write mappings) via [anon_vma_lock_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n119). If adjust_next is set by the previous code, indicating that the (internal) next VMA will be adjusted to, then we do the same with this VMA as well.

We also cover a corner case where vma lacks any target anon_vma object but adjust_next indicates the (internal) next VMA will have its updated and possesses a non-null anon_vma – in this instance we set anon_vma to this object.

• Equally, we must do the equivalent for the address_space page cache

object associated with a file-backed VMA (note that MAP_PRIVATE map-pings can be present in both interval trees). This is performed via

vma_interval_tree_remove()\* . Similar to the anonymous case, we perform the same operation on the (internal) next VMA if adjust_next is non-zero.

• At this point we go ahead and make the changes to vma – if vm_start is up-

dated we set start_changed, equally if vm_end is changed we set end_changed. We also update vm_pgoff.

• If adjust_next has been set, we perform this adjustment by simply offset-

ting next-\>vm_start and next-\>vm_pgoff.

• Finally, we reinsert vma (and next if adjust_next indicates we are adjusting

the VMA too) into the page cache [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) object’s i_mmap interval tree.

 

Note the sporadic \*dcache\*() functions are for architectures which re-

quire the hardware cache to be updated manually when mappings change. This is not the case for x86-64 so we do not consider it, however note that this informs some of the ordering decisions made here.

Once this process is complete, we handle VMA removal or (non-merge)

insertion as shown in Listing 5-40.

 

858 **if** (remove_next) { 859 */\**

860 *\* vma_merge has merged next into vma, and needs* 861 *\* us to remove next before dropping the locks.* 862 *\*/*

863 **if** (remove_next != 3) 864 **\_\_vma_unlink**(mm, next, next); 865 **else**

866 */\** 867 *\* vma is not before next if they've been* 868 *\* swapped.* 869 *\**

 

\*. Note that this function is generated via the [INTERVAL_TREE_DEFINE()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/interval_tree_generic.h?h=v6.0#n28) macro in [mm/interval_tree.c](https://elixir.bootlin.com/linux/v6.0/source/mm/interval_tree.c)[.](https://elixir.bootlin.com/linux/v6.0/source/mm/interval_tree.c)



 

870 *\* pre-swap() next-\>vm_start was reduced so* 871 *\* tell validate_mm_rb to ignore pre-swap()* 872 *\* "next" (which is stored in post-swap()* 873 *\* "vma").* 874 *\*/* 875 **\_\_vma_unlink**(mm, next, vma); 876 **if** (file) 877 **\_\_remove_shared_vm_struct**(next, file, mapping); 878 } **else if** (insert) { 879 */\**

880 *\* split_vma has split insert from vma, and needs* 881 *\* us to insert it before dropping the locks* 882 *\* (it may either follow vma or precede it).* 883 *\*/*

884 **\_\_insert_vm_struct**(mm, insert); 885 } **else** {

886 **if** (start_changed) 887 **vma_gap_update**(vma); 888 **if** (end_changed) { 889 **if** (!next) 890 mm-\>highest_vm_end = **vm_end_gap**(vma); 891 **else if** (!adjust_next) 892 **vma_gap_update**(next); 893 }

894 }

895

896 **if** (anon_vma) {

897 **anon_vma_interval_tree_post_update_vma**(vma); 898 **if** (adjust_next) 899 **anon_vma_interval_tree_post_update_vma**(next); 900 **anon_vma_unlock_write**(anon_vma); 901 }

902

903 **if** (file) {

904 **i_mmap_unlock_write**(mapping);

. . .

909 }

 

*Listing 5-40:* mm/mmap.c: [*\_\_vma_adjust()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n699) *VMA removal/insertion*

We use [\_\_vma_unlink()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n682) to perform the actual removal of the next VMA\* as

shown in Listing 5-41.

 

682 **static \_\_always_inline void \_\_vma_unlink**(**struct** mm_struct \*mm, 683 **struct** vm_area_struct \*vma,

 

\*. Note that the special case handling for remove_next equal to 3 (i.e. case 8 with the swapped

vma and next parameters) varies what it passes to the ignore parameter, which is only relevant if

CONFIG_DEBUG_VM_RB is specified.



 

684 **struct** vm_area_struct \*ignore) 685 {

686 **vma_rb_erase_ignore**(vma, &mm-\>mm_rb, ignore); 687 **\_\_vma_unlink_list**(mm, vma); 688 */\* Kill the cache \*/* 689 **vmacache_invalidate**(mm); 690 }

 

*Listing 5-41:* mm/mmap.c: [*\_\_vma_unlink()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n682)

 

The [vma_rb_erase_ignore()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n432) invocation ultimately performs the removal

from the VMA red/black tree via [\_\_vma_rb_erase()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n422)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n422) [vmacache_invalidate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmacache.h?h=v6.0#n23) in-

validates the current VMA cache and [\_\_vma_unlink_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n293) removes the VMA

from the linked list as shown in Listing 5-42.

 

293 **void \_\_vma_unlink_list**(**struct** mm_struct \*mm, **struct** vm_area_struct \*vma) 294 {

295 **struct** vm_area_struct \*prev, \*next; 296

297 next = vma-\>vm_next; 298 prev = vma-\>vm_prev; 299 **if** (prev)

300 prev-\>vm_next = next; 301 **else**

302 mm-\>mmap = next; 303 **if** (next)

304 next-\>vm_prev = prev; 305 }

 

*Listing 5-42:* mm/util.c: [*\_\_vma_unlink_list()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n293)

 

This handles the case where either vm_next or vm_prev is NULL correctly. If the VMA is file-mapped, the VMA is removed from the interval tree via

[\_\_remove_shared_vm_struct()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n107) as shown in Listing 7-82.

 

104 */\**

105 *\* Requires inode-\>i_mapping-\>i_mmap_rwsem* 106 *\*/*

107 **static void \_\_remove_shared_vm_struct**(**struct** vm_area_struct \*vma, 108 **struct** file \*file, **struct** address_space \*mapping) 109 {

110 **if** (vma-\>vm_flags & **VM_SHARED**) 111 **mapping_unmap_writable**(mapping); 112

113 **flush_dcache_mmap_lock**(mapping); 114 **vma_interval_tree_remove**(vma, &mapping-\>i_mmap); 115 **flush_dcache_mmap_unlock**(mapping); 116 }

 

*Listing 5-43:* mm/mmap.c: [*\_\_remove_shared_vm_struct()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n107)

 



 

The \*dcache\*() operations are for architectures which require manual

data cache maintenance on mapping, however for architectures like x86-64

this is a no-op. [mapping_unmap_writable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n532) is called to track writable mappings

of the page cache object (on the assumption that any shared mapping might

be written to at any time\*).

The actual removal from the [struct address_space-\>i_mmap](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) interval tree is

performed by vma_interval_tree_remove().

If the operation is an insertion rather than a merge, [\_\_insert_vm_struct()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n670)

is called instead. We examine this function in section 5.1.4 as part of the

discussion around splitting VMAs.

If we neither remove nor insert a VMA, we perform some account-

ing – [vma_gap_update()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n404) updates internal state used within the red/black

tree to keep track of gaps between a VMA and the nearest subtree

VMA using common augmented red/black tree kernel code, and the

[struct mm_struct-\>highest_vm_end](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) field is updated as necessary.

Finally if we have a [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) object we have updated we reestab-

lish interval tree links via [anon_vma_interval_tree_post_update_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n480) for

vma and next if adjust_next is non-zero before unlocking the anon_vma via

[anon_vma_unlock_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n124).

Finally, if vma is file-backed, we need to unlock the page cache object’s

interval tree via [i_mmap_unlock_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n474)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n474)

After any removal performed here is complete, there are some final

cleanup tasks we must take care before finally invoking [validate_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n392) to en-

sure that the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) object is in a valid state as shown in Listing 5-

44.

 

911 **if** (remove_next) {

. . .

916 **if** (next-\>anon_vma) 917 **anon_vma_merge**(vma, next); 918 mm-\>map_count--; 919 **mpol_put**(**vma_policy**(next)); 920 **vm_area_free**(next); 921 */\**

922 *\* In mprotect's case 6 (see comments on vma_merge),* 923 *\* we must remove another next too. It would clutter* 924 *\* up the code too much to do both in one go.* 925 *\*/*

926 **if** (remove_next != 3) { 927 */\** 928 *\* If "next" was removed and vma-\>vm_end was* 929 *\* expanded (up) over it, in turn* 930 *\* "next-\>vm_prev-\>vm_end" changed and the* 931 *\* "vma-\>vm_next" gap must be updated.*

 

\*. This functionality is largely used as part of cache maintenance for architectures which re-memfd quire it but is also used for write sealing of objects created via [memfd_create()](https://man7.org/linux/man-pages/man2/memfd_create.2.html) .

 



 

932 *\*/* 933 next = vma-\>vm_next; 934 } **else** {

935 */\** 936 *\* For the scope of the comment "next" and* 937 *\* "vma" considered pre-swap(): if "vma" was* 938 *\* removed, next-\>vm_start was expanded (down)*

939 *\* over it and the "next" gap must be updated.*

940 *\* Because of the swap() the post-swap() "vma"*

941 *\* actually points to pre-swap() "next"* 942 *\* (post-swap() "next" as opposed is now a* 943 *\* dangling pointer).* 944 *\*/* 945 next = vma; 946 }

947 **if** (remove_next == 2) { 948 remove_next = 1; 949 end = next-\>vm_end; 950 **goto again**; 951 }

952 **else if** (next) 953 **vma_gap_update**(next); 954 **else** {

955 */\** 956 *\* If remove_next == 2 we obviously can't* 957 *\* reach this path.* 958 *\** 959 *\* If remove_next == 3 we can't reach this* 960 *\* path because pre-swap() next is always not*

961 *\* NULL. pre-swap() "next" is not being* 962 *\* removed and its next-\>vm_end is not altered*

963 *\* (and furthermore "end" already matches* 964 *\* next-\>vm_end in remove_next == 3).* 965 *\** 966 *\* We reach this only in the remove_next == 1*

967 *\* case if the "next" vma that was removed was*

968 *\* the highest vma of the mm. However in such*

969 *\* case next-\>vm_end == "end" and the extended*

970 *\* "vma" has vma-\>vm_end == next-\>vm_end so* 971 *\* mm-\>highest_vm_end doesn't need any update*

972 *\* in remove_next == 1 case.* 973 *\*/* 974 **VM_WARN_ON**(mm-\>highest_vm_end != **vm_end_gap**(vma)); 975 }

976 }

. . .

980 **validate_mm**(mm);

 



 

981

982 **return** 0;

983 }

 

*Listing 5-44:* mm/mmap.c: [*\_\_vma_adjust()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n699) *VMA post-removal housekeeping and VMA*

*validation*

 

We start by merging the (now unlinked) next VMA’s [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) ob-

ject with the current one via [anon_vma_merge()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n162). See Chapter 7 for a deep dive

on this and the reverse mapping as a whole.

The [struct mm_struct-\>map_count](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) field is decremented to reflect the now-

removed VMA, the reference count on the NUMA VMA policy is decre-

mented via [(](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mempolicy.h?h=v6.0#nmpol_put())see the NUMA chapter for more on this) and the VMA is ac-

tually freed via [vm_area_free()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n484) as shown in Listing 5-45.

 

484 **void vm_area_free**(**struct** vm_area_struct \*vma) 485 {

486 **free_anon_vma_name**(vma); 487 **kmem_cache_free**(vm_area_cachep, vma); 488 }

 

*Listing 5-45:* kernel/fork.c: [*vm_area_free()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n484)

 

This frees up any existent anonymous VMA name via [free_anon_vma_name()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n192)

and then simply invokes the slab cache free function [kmem_cache_free()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/slub.c?h=v6.0#n3550) to re-

lease the VMA object itself.

Next there’s something of a dance to cover case 8 (where remove_next is

3) – in this instance we want to ensure we update the internal VMA sub-tree

gap value correctly which we do shortly afterwards for all cases accordingly.

In case 6, signified by remove_next being equal to 2, we have to loop

around to the again label and go again, decrementing remove_next to indicate

that we are looping.

You will recall from figure 5-2 (specifically discussed in the key section

below) that we initially set end to area-\>vm_end on first pass, because the in-

ternal variable next is in fact set to area in [vma_merge()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1122)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1122) Here, having just re-

moved the area VMA, end is reset to next-\>vm_end and we then merge the

newly merged prev and area VMAs with next on the next iteration, which we

examine in Figure 5-5.

 



 

Iteration 1

 

prev area next

 

Iteration 2

 

next

 

*Figure 5-5: Case 6 iterations*

 

After updating the VMA gap (a previously discussed internal implemen-

tation detail), we also perform an additional check in the instance where no internal next variable is specified in order to ensure that, if we reached the last VMA in the process address space, the mm_struct-\>highest_vm_end field is set correctly.

Finally, we perform some integrity checks via [validate_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n392) if and only if

CONFIG_DEBUG_VM_RB is defined.

It’s important to note that in the above we do not actually adjust the

position of the VMA within the red/black tree (other than the case where we remove or insert a VMA of course). This is because any such change of bounds by its nature does not change the ordering, only the gap between VMAs which we do account for.

 

***5.1.4 VMA split***

We have now examined how VMAs are merged together, however we also have to examine the case where a portion of a VMA is removed which results in a VMA split.

Eliding out of scope userfaultfd, it is invoked from:

 

• [mbind_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mempolicy.c?h=v6.0#n785) – When changing the NUMA policy over an address range

via [mbind()](https://man7.org/linux/man-pages/man2/mbind.2.html) this may result in a VMA split as well as a merge, depending on the range being adjusted.

• [mlock_fixup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mlock.c?h=v6.0#n404) – When [mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html)’ing ranges of memory, again we might split

as well as merge depending on the range being locked/unlocked.

• [mprotect_fixup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mprotect.c?h=v6.0#n539) – When invoking [mprotect()](https://man7.org/linux/man-pages/man2/mprotect.2.html) over an address range simi-

larly we may need either to merge or to split the VMA to account for the change in protection.

• [madvise_update_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/madvise.c?h=v6.0#n139) – When performing a [madvise()](https://man7.org/linux/man-pages/man2/madvise.2.html) over an address

range to adjust that range’s attributes, this may result in a VMA split.

Note that we invoke the internal [\_\_split_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2676) function in this instance.

• [\_\_do_munmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2754) – When unmapping memory ranges, this might result in a

‘hole’ within a VMA and thus the need to split it. This uses the internal

[\_\_split_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2676) function.

 



 

One means of doing this is via the wrapper function [split_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2740), which

the first 3 cases above call as shown in Listing 5-46.

 

2736 */\**

2737 *\* Split a vma into two pieces at address 'addr', a new vma is allocated* 2738 *\* either for the first part or the tail.* 2739 *\*/*

2740 **int split_vma**(**struct** mm_struct \*mm, **struct** vm_area_struct \*vma, 2741 **unsigned long** addr, **int** new_below) 2742 {

2743 **if** (mm-\>map_count \>= **sysctl_max_map_count**) 2744 **return**-**ENOMEM**; 2745

2746 **return \_\_split_vma**(mm, vma, addr, new_below); 2747 }

 

*Listing 5-46:* mm/mmap.c: [*split_vma()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2740)

 

While the heavy lifting is deferred to [\_\_split_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2676), this usefully adds a

check against the vm.max_map_count tunable to ensure that a split would not

exceed this limit.

Examining [\_\_split_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2676) as shown in Listing 5-47.

 

2672 */\**

2673 *\* \_\_split_vma() bypasses sysctl_max_map_count checking. We use this where it*

2674 *\* has already been checked or doesn't make sense to fail.* 2675 *\*/*

2676 **int \_\_split_vma**(**struct** mm_struct \*mm, **struct** vm_area_struct \*vma, 2677 **unsigned long** addr, **int** new_below) 2678 {

2679 **struct** vm_area_struct \*new; 2680 **int** err;

2681

2682 **if** (vma-\>vm_ops && vma-\>vm_ops-\>**may_split**) { 2683 err = vma-\>vm_ops-\>**may_split**(vma, addr); 2684 **if** (err)

2685 **return** err; 2686 }

2687

2688 new = **vm_area_dup**(vma); 2689 **if** (!new)

2690 **return**-**ENOMEM**; 2691

2692 **if** (new_below)

2693 new-\>vm_end = addr; 2694 **else** {

2695 new-\>vm_start = addr; 2696 new-\>vm_pgoff += ((addr - vma-\>vm_start) \>\> **PAGE_SHIFT**); 2697 }

 



 

2698

2699 err = **vma_dup_policy**(vma, new); 2700 **if** (err)

2701 **goto out_free_vma**; 2702

2703 err = **anon_vma_clone**(new, vma); 2704 **if** (err)

2705 **goto out_free_mpol**; 2706

2707 **if** (new-\>vm_file) 2708 **get_file**(new-\>vm_file); 2709

2710 **if** (new-\>vm_ops && new-\>vm_ops-\>**open**) 2711 new-\>vm_ops-\>**open**(new); 2712

2713 **if** (new_below)

2714 err = **vma_adjust**(vma, addr, vma-\>vm_end, vma-\>vm_pgoff + 2715 ((addr - new-\>vm_start) \>\> **PAGE_SHIFT**), new); 2716 **else**

2717 err = **vma_adjust**(vma, vma-\>vm_start, addr, vma-\>vm_pgoff, new)

;

2718

2719 */\* Success. \*/*

2720 **if** (!err)

2721 **return** 0; 2722

2723 */\* Clean everything up if vma_adjust failed. \*/* 2724 **if** (new-\>vm_ops && new-\>vm_ops-\>**close**) 2725 new-\>vm_ops-\>**close**(new); 2726 **if** (new-\>vm_file) 2727 **fput**(new-\>vm_file); 2728 **unlink_anon_vmas**(new); 2729 **out_free_mpol**:

2730 **mpol_put**(vma_policy(new)); 2731 **out_free_vma**:

2732 **vm_area_free**(new); 2733 **return** err;

2734 }

 

*Listing 5-47:* mm/mmap.c: [*\_\_split_vma()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2676)

 

This begins by checking whether the [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA)’s

[struct vm_operations_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n539) vm_ops field has a may_split() predicate defined, which might be the case for a non-anonymous mapping. This gives file sys-tems the chance to determine whether a split is permitted.

Next we duplicate the VMA, which will form the splitcopy of the VMA

caused by the split in [vm_area_dup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n465) as shown in Listing 5-48.

 

465 **struct** vm_area_struct \***vm_area_dup**(**struct** vm_area_struct \*orig)

 



 

466 {

467 **struct** vm_area_struct \*new = **kmem_cache_alloc**(vm_area_cachep,

**GFP_KERNEL**);

468

469 **if** (new) {

470 **ASSERT_EXCLUSIVE_WRITER**(orig-\>vm_flags); 471 **ASSERT_EXCLUSIVE_WRITER**(orig-\>vm_file); 472 */\**

473 *\* orig-\>shared.rb may be modified concurrently, but the clone*

474 *\* will be reinitialized.* 475 *\*/*

476 \*new = **data_race**(\*orig); 477 **INIT_LIST_HEAD**(&new-\>anon_vma_chain); 478 new-\>vm_next = new-\>vm_prev = **NULL**; 479 **dup_anon_vma_name**(orig, new); 480 }

481 **return** new;

482 }

 

*Listing 5-48:* kernel/fork.c: [*vm_area_dup()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n465)

This principally copies the existing VMA by assignment, but also resets

the anon_vma_chain field (it will need to be re-added to this), and clears vm_prev

and vm_next ready to be reinserted in right place. Any anonymous VMA

name is also duplicated via [dup_anon_vma_name()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n183).

Note that the vm_rb node entry is not altered, this will be set correctly

when we link this VMA into the tree.

The new_below parameter determines whether the new, duplicated VMA

starts at addr or ends at it, as shown in Figure 5-6.

 

vma-\>vm_start addr vma-\>vm_end

 

!new_below

Post-split new vma

 

new_below

new Post-split vma

 

*Figure 5-6: Split VMA cases*

We duly update the new VMA’s vm_start/vm_end and vm_pgoff fields.

We duplicate the VMA policy via [vma_dup_policy()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mempolicy.c?h=v6.0#n2370) (see the NUMA chap-

ter for details), duplicate the [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) object via [anon_vma_clone()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n279) (see

## Chapter 7 for details on these objects within the reverse mapping), incre-

ment the reference count on the [struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) object associated with the VMA

if file-backed and invoke the [struct vm_operations_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n539) vm_ops-\>open() call-

back if one is specified (i.e. a non-anonymous mapping which wishes to be

notified of this).

 



 

Once this housekeeping is done, we are ready to perform the actual split.

This is done via [vma_adjust()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2581) as shown in Listing 5-49.

 

2581 **static inline int vma_adjust**(**struct** vm_area_struct \*vma, **unsigned long** start, 2582 **unsigned long** end, **pgoff_t** pgoff, **struct** vm_area_struct \*insert) 2583 {

2584 **return \_\_vma_adjust**(vma, start, end, pgoff, insert, **NULL**); 2585 }

 

*Listing 5-49:* include/linux/mm.h: [*vma_adjust()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2581)

 

Which ultimately invokes [\_\_vma_adjust()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n699) as described in section 5.1.3 de-

scribed above, only specifying the insert parameter and setting the start and end according to new_below.

The insert version of \_\_vma_adjust(), after adjusting the existing VMA’s

bounds, invokes [\_\_insert_vm_struct()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n670) to perform the insertion of new as

shown in Listing 5-50.

 

666 */\**

667 *\* Helper for vma_adjust() in the split_vma insert case: insert a vma into the*

668 *\* mm's list and rbtree. It has already been inserted into the interval tree.*

669 *\*/*

670 **static void \_\_insert_vm_struct**(**struct** mm_struct \*mm, **struct** vm_area_struct \*

vma)

671 {

672 **struct** vm_area_struct \*prev; 673 **struct** rb_node \*\*rb_link, \*rb_parent; 674

675 **if** (**find_vma_links**(mm, vma-\>vm_start, vma-\>vm_end, 676 &prev, &rb_link, &rb_parent)) 677 **BUG**();

678 **\_\_vma_link**(mm, vma, prev, rb_link, rb_parent); 679 mm-\>map_count++;

680 }

 

*Listing 5-50:* mm/mmap.c: [*\_\_insert_vm_struct()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n670)

 

This uses [find_vma_links()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n488) to find the VMA prior to the one we are in-

serting as well as red/black tree nodes for the parent in rb_parent and the position the new node will reside in set in rb_link. We use these to perform

the link in [\_\_vma_link()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n637) and increment the [struct mm_struct-\>mmap_count](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) field to indicate that a new VMA has been added.

Examining [\_\_vma_link()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n637) as shown in Listing 5-51.

 

636 **static void**

637 **\_\_vma_link**(**struct** mm_struct \*mm, **struct** vm_area_struct \*vma, 638 **struct** vm_area_struct \*prev, **struct** rb_node \*\*rb_link, 639 **struct** rb_node \*rb_parent) 640 {

641 **\_\_vma_link_list**(mm, vma, prev);

 



 

642 **\_\_vma_link_rb**(mm, vma, rb_link, rb_parent); 643 }

 

*Listing 5-51:* mm/mmap.c: [*\_\_vma_link()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n637)

 

This links the new VMA into the linked list via [\_\_vma_link_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n275) and the

red/black tree via [\_\_vma_link_rb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n595).

Finally, [\_\_split_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2676) performs clean up in the case where the split failed. Overall the split is considerably simpler than the merge – each instance

of splitting is the same, the only variable factor is whether we place the

newly duplicated split VMA above or below the specified address.

 

