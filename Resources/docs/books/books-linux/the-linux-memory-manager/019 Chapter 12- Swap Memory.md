**S W A P M E M O R Y**

 

Overcommit and demand paging mean that Linux

permits more memory to be mapped by processes

than the RAM installed on the system. This means

that when a lot of memory is used, the kernel must re-

claim memory in order to satisfy future memory re-

quests. Swap provides a means by which to reclaim

anonymous memory by writing it out to disk. We will

explore the means by which this is achieved in this

chapter.

When memory needs to be reclaimed from the page cache, the kernel

can simply drop clean pages from it, freeing up memory quickly at the cost

of the next access to that page resulting in a major fault.

This isn’t the case for anonymous memory, however, which cannot sim-

ply be dropped. Instead it is “swapped out” to disk to be “swapped in” later

if accessed.

A complexity that arises with this is that the swap out operation takes

time to complete, and meanwhile it could be swapped back in at any time.

This means that the kernel must provide some special means of marking

memory as being swapped out for some processes which maps it (via “swap


 

entries”) and designating such memory as being not long for this world (oc-cupying the “swap cache”). We explore both in detail.

The swap is often misunderstood as a means to add memory capacity to

a system or act as a memory reserve, however it is neither–its entire purpose in life is to provide the means for anonymous memory to undergo reclaim, thereby providing a mean of balancing memory pressure between anony-mous memory and the page cache.

This is important, as under heavy memory pressure reclaiming either

page cache folios or anonymous memory alone is likely to cause “thrashing”, and having the ability to reclaim anonymous memory helps address this.

 

**N O T E** Thrashing describes the pathological condition in which heavy memory pressure re-

sults in the system being in a perpetual state of faulting data in from disk (whether swapped in or read into the page cache from disk) and writing it back out again (ei-ther through swapping it out or writing back dirty file data to disk). This results in the system becoming slow and unstable, and ultimately unusable if the situation is not resolved.

 

As a result swap is inescapably linked to both reclaim (see Chapter 11)

and page faulting (see Chapter 6). We will examine how, under memory pressure, reclaim triggers swap-out, and how, when swapped out memory is accessed, a page fault triggers swap-in.

 

**12.1 The Swap Cache**

 

The page cache acts as a bridge between data that exists on disk and the pro-cesses that interact with it, abstracting reading from files (see Chapter **??**)

and writing back to them when necessary (see Chapter 10).

This simplifies accesses to storage and provides a means of resolving

races between processes reading from and writing to files which might un-dergo reclaim midway through.

The swap cache performs a similar role for anonymous memory, al-

though unlike file pages in the page cache, anonymous memory is not placed in the swap cache until it is has been swapped out in the first in-stance.

The “swap cache” therefore is a repository of folios which reclaim has de-

cided ought to be swapped out, which may or may not yet be swapped out, or may have just been swapped back in. It is the swap cache that resolves these races.

As is customary for this book we will build understanding of the swap

cache by examining how it functions “bottom-up”, i.e. examine the data structures and algorithms which implement it, and using this to understand how this fits together with the rest of the swap implementation.

The swap cache is defined by the [swapper_spaces](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n40) array, which is an array

of [MAX_SWAPFILES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n125) pointers each of which point at an array of [nr_swapper_spaces](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n41)

[struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) objects, as shown in Listing **??**.

 

40 **struct** address_space \***swapper_spaces**\[**MAX_SWAPFILES**\] **\_\_read_mostly**;

 



 

41 **static unsigned int nr_swapper_spaces**\[**MAX_SWAPFILES**\] **\_\_read_mostly**;

 

*Listing 12-1:* mm/swap_state.c: [*swapper_spaces*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n40) *and [nr_swapper_spaces](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n41)*

 

In effect, [swapper_spaces](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n40) is a 2 dimensional array, with the first dimension

being fixed and the second dynamically allocated, whose length is equal to

[nr_swapper_spaces\[i\]](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n41) (for the ith swap file).

Each dynamic array contained within [swapper_spaces](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n40) represents the space

available in a specific swap file or partition (for the sake of the swap imple-

mentation we refer to all swap backing sources as swap files).

Each [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) object is used as a “fake” page cache object de-

scribing up to a maximum of [SWAP_ADDRESS_SPACE_PAGES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.h?h=v6.0#n28) pages each, equal to

16,384 pages or (assuming 4 KiB pages) 64 MiB of data.

Therefore, if we know a specific page offset within a swap file, we need

only shift it by [SWAP_ADDRESS_SPACE_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.h?h=v6.0#n27) bits to determine the index of the

[struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) to which it belongs.

If we know the index of the swap file (which is referred to, rather confus-

ingly, as its “type”), and the offset of the page we wish to retrieve from the

swap cache within it, we are able to locate the page in [swapper_spaces](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n40)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n40)

The combination of these two bits of information is referred to as a

“swap entry” and described by the [swp_entry_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n820) type alias, which simply wraps

an unsigned long value, as shown in Listing 12-2. This value is architecture-

independent.

 

814 */\**

815 *\* A swap entry has to fit into a "unsigned long", as the entry is hidden*

816 *\* in the "index" field of the swapper address space.* 817 *\*/*

818 **typedef struct** {

819 **unsigned long** val; 820 } **swp_entry_t**;

 

*Listing 12-2:* include/linux/mm_types.h: [*swp_entry_t*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n820)

 

Swap entries are encoded via [swp_entry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swapops.h?h=v6.0#n41) as shown in Listing 12-3.

 

38 */\**

39 *\* Store a type+offset into a swp_entry_t in an arch-independent format*

40 *\*/*

41 **static inline swp_entry_t swp_entry**(**unsigned long** type, **pgoff_t** offset)

42 {

43 **swp_entry_t** ret;

44

45 ret.val = (type \<\< **SWP_TYPE_SHIFT**) \| (offset & **SWP_OFFSET_MASK**);

46 **return** ret;

47 }

 

*Listing 12-3:* include/linux/swapops.h: [*swp_entry()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swapops.h?h=v6.0#n41)

 

The “type” referred to here, though oddly named, refers to the swap file

index. The type values are shifted up to the high bits by [SWP_TYPE_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swapops.h?h=v6.0#n23), and

 



 

the offset has the [SWP_OFFSET_MASK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swapops.h?h=v6.0#n24) applied, limiting its value to that of the un-

signed long [swp_entry_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n820) type less the high bits used for the type value.

We can access swapper [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) objects via the

[swap_address_space()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.h?h=v6.0#n30) macro, as shown in Listing 12-4.

 

30 **\#define swap_address_space**(entry) \\ 31 (&**swapper_spaces**\[**swp_type**(entry)\]\[**swp_offset**(entry) \\ 32 \>\> **SWAP_ADDRESS_SPACE_SHIFT**\])

 

*Listing 12-4:* mm/swap.h: [*swap_address_space()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.h?h=v6.0#n30)

As discussed previously, each [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) in swapper space

manages [SWAP_ADDRESS_SPACE_PAGES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.h?h=v6.0#n28) pages, meaning that shifting by

[SWAP_ADDRESS_SPACE_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.h?h=v6.0#n27) obtains the correct index within the dynamic array.

We determine the index of the swap file (or its “type”) via [swp_type()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swapops.h?h=v6.0#n53)

which we examine in Listing 12-5.

 

49 */\**

50 *\* Extract the \`type' field from a swp_entry_t. The swp_entry_t is in* 51 *\* arch-independent format* 52 *\*/*

53 **static inline unsigned swp_type**(**swp_entry_t** entry) 54 {

55 **return** (entry.val \>\> **SWP_TYPE_SHIFT**); 56 }

 

*Listing 12-5:* include/linux/swapops.h: [*swp_type()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swapops.h?h=v6.0#n53)

This simply shifts the [swp_entry_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n820) to extract the type value. We extract the

page offset from the entry via [swp_offset()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swapops.h?h=v6.0#n62) which we examine in Listing 12-6.

 

58 */\**

59 *\* Extract the \`offset' field from a swp_entry_t. The swp_entry_t is in* 60 *\* arch-independent format* 61 *\*/*

62 **static inline pgoff_t swp_offset**(**swp_entry_t** entry) 63 {

64 **return** entry.val & **SWP_OFFSET_MASK**; 65 }

 

*Listing 12-6:* include/linux/swapops.h: [*swp_offset()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swapops.h?h=v6.0#n62)

Both of these functions simply invert what was performed in [swp_entry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swapops.h?h=v6.0#n41)

(see Listing 12-3) to obtain the component type and offset fields contained within the entry.

 

***12.1.1 Swapper Initialisation***

A swap file is made available to the kernel via the [swapon()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n2981) system call, which

in turn invokes [init_swap_address_space()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n661), which we examine in Listing 12-7.

 

661 **int init_swap_address_space**(**unsigned int** type, **unsigned long** nr_pages)

 



 

662 {

663 **struct** address_space \*spaces, \*space; 664 **unsigned int** i, nr;

665

666 nr = **DIV_ROUND_UP**(nr_pages, **SWAP_ADDRESS_SPACE_PAGES**); 667 spaces = **kvcalloc**(nr, **sizeof**(**struct** address_space), **GFP_KERNEL**); 668 **if** (!spaces)

669 **return**-**ENOMEM**; 670 **for** (i = 0; i \< nr; i++) { 671 space = spaces + i; 672 **xa_init_flags**(&space-\>i_pages, **XA_FLAGS_LOCK_IRQ**); 673 **atomic_set**(&space-\>i_mmap_writable, 0); 674 space-\>a_ops = &**swap_aops**; 675 */\* swap cache doesn't use writeback related tags \*/* 676 **mapping_set_no_writeback_tags**(space); 677 }

678 **nr_swapper_spaces**\[type\] = nr; 679 **swapper_spaces**\[type\] = spaces;

680

681 **return** 0;

682 }

 

*Listing 12-7:* mm/swap_state.c: [*init_swap_address_space()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n661)

 

This function is passed the index of the swapper file (it’s “type”), and the

number of pages the swap file is able to store, which is used to calculate the

number of [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) objects that are required to describe these

available pages.

We allocate the space required to store these objects via [kvcalloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/slab.h?h=v6.0#n771) which

allocates using the kernel slab allocator (the kernel equivalent of malloc()),

equal to the number of pages divided by [SWAP_ADDRESS_SPACE_PAGES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.h?h=v6.0#n28), rounding

up.

Each of the “fake” [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) objects are initialised, disabling

writeback functionality as this is not utilised, and importantly setting the

[struct address_space_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n356) to [swap_aops](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n32)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n32) which importantly sets the

writepage callback to [swap_writepage()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_io.c?h=v6.0#n181) which we examine later in Listing 12-

27.

 

**N O T E** The [*struct address_space*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) associated with each entry in the [*swapper_spaces*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n40) arrays

are independent of those describing the underlying swap file or partition, they are

entirely an abstraction.

 

We then set the [nr_swapper_spaces](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n41) field to the page count, and then assign

our newly allocated [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) array to the appropriate entry in

[swapper_spaces](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n40).

 



 

***12.1.2 Assigning Folios to the Swap Cache***

Once we have placed a folio into the swap cache, we need to be able to look up the swap cache entry it belongs to. We do so by setting the

[struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72)-\>private field for each subpage of the folio (see Section 2.2 for a detailed explanation of folios and how they relate to their subpages) to a

[swp_entry_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n820) value which in turn allows us to look up the swap cache entry.

 

**N O T E** All of the subpages of a folio will be placed in the same [*struct address_space*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) as con-

secutive pages. Therefore the swap entries for the folio will be contiguous from the

from [*struct folio*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256)*-\>private* up to the number of pages the folio spans.

 

This is done in [add_to_swap_cache()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n88) which we examine in Listing 12-22

below in Section 12.2. This function simply invokes [set_page_private()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/nclude/linux/mm_types.h?h=v6.0#n335) to do so.

This field can be used by file mappings, but since only anonymous

memory can be swapped out, it is safe for us to use it. Memory that is

present in the swap cache also has the folio flag [PG_swapcache](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n158) set, so we

know if this is set that we ought to look at [struct folio-\>private](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) rather than

[struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256)-\>mapping .

This allows us to cleverly share some of the file handling code and apply

it to swap cache entries, most importantly within reclaim, where the dirty

state of swapper space [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) objects determines whether a

swap cache entry needs to be written to disk (see Section 12.2 for details).

The utility function [folio_mapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n799) (see Listing 7-41) abstracts this swap

lookup. For convenience we show the relevant part of this function here in

Listing 12-8.

 

799 **struct** address_space \***folio_mapping**(**struct** folio \*folio) 800 {

. . .

807 **if** (**unlikely**(**folio_test_swapcache**(folio))) 808 **return swap_address_space**(**folio_swap_entry**(folio));

. . .

815 }

 

*Listing 12-8:* mm/util.c: [*folio_mapping()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n799) *Swap Cache Handling*

 

This invokes [swap_address_space()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.h?h=v6.0#n30) (as shown in Listing 12-4) to look up

the entry, which in turn obtains the [swp_entry_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n820) entry via [folio_swap_entry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n348)

which we examine in Listing 12-9.

 

348 **static inline swp_entry_t folio_swap_entry**(**struct** folio \*folio) 349 {

350 **swp_entry_t** entry = { .val = **page_private**(&folio-\>page) }; 351 **return** entry;

352 }

 

*Listing 12-9:* include/linux/swap.h: [*folio_swap_entry()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n348)

 



 

Which simply looks up the swap entry from [struct folio-\>private](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) via

[page_private()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n333).

 

***12.1.3 Page Table Mappings***

When memory is swapped out it doesn’t get unmapped, but rather the

page table mappings are updated to reference the swap cache by encoding

a [swp_entry_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n820) at the PTE level (see Chapter 3 for details on page table levels),

or equivalent for huge pages.

Since the [swp_entry_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n820) spans the size of an unsigned long type and a page

table entry is typically equally as long, we must sacrifice some bits of the off-

set portion of the swap entry to permit each architecture to set hardware-

specific page table bits accordingly.

We identify swap PTEs using [is_swap_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swapops.h?h=v6.0#n68), which we examine in Listing

12-10.

 

67 */\* check whether a pte points to a swap entry \*/*

68 **static inline int is_swap_pte**(**pte_t** pte)

69 {

70 **return** !**pte_none**(pte) && !**pte_present**(pte);

71 }

 

*Listing 12-10:* include/linux/swapops.h: [*is_swap_pte()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swapops.h?h=v6.0#n68)

 

The defining characteristic of a PTE swap entry is that the present bit has

not been set, but the entry is not otherwise clear (see Section 3.1.2 for more

details on page tables and their flags).

We determine whether the present bit is set via [pte_present()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n734) and

whether it is clear via [pte_none()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n723)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n723)

The [swp_entry_to_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swapops.h?h=v6.0#n90) function allows the conversion of the architecture-

independent [swp_entry_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n820) value to a PTE entry suitable for the architecture

and ready to be inserted in the page table. We examine it in Listing 12-11.

 

86 */\**

87 *\* Convert the arch-independent representation of a swp_entry_t into the*

88 *\* arch-dependent pte representation.*

89 *\*/*

90 **static inline pte_t swp_entry_to_pte**(**swp_entry_t** entry)

91 {

92 **swp_entry_t** arch_entry;

93

94 arch_entry = **\_\_swp_entry**(**swp_type**(entry), **swp_offset**(entry));

95 **return \_\_swp_entry_to_pte**(arch_entry);

96 }

 

*Listing 12-11:* include/linux/swapops.h: [*swp_entry_to_pte()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swapops.h?h=v6.0#n90)

 

This extracts the type (i.e. swap file index) and offset of the swap entry

via [swp_type()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swapops.h?h=v6.0#n53) (see Listing 12-5) and [swp_offset()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swapops.h?h=v6.0#n62) (see Listing 12-6) respec-

tively.

 



 

This is then passed to the architecture-specific [\_\_swp_entry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64.h?h=v6.0#n234) function

which generates an entry that can be placed within the PTE. We examine

this function in Listing 12-12.

Finally, the function invokes the architecture-specific [\_\_swp_entry_to_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64.h?h=v6.0#n240)

which converts the generated PTE value contained in a [swp_entry_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n820) value to a

PTE-specific type, [pte_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n21). For x86-64, this is simply pass-through.

 

229 */\**

230 *\* Shift the offset up "too far" by TYPE bits, then down again* 231 *\* The offset is inverted by a binary not operation to make the high* 232 *\* physical bits set.*

233 *\*/*

234 **\#define \_\_swp_entry**(type, offset) ((**swp_entry_t**) { \\ 235 (~(**unsigned long**)(offset) \<\< **SWP_OFFSET_SHIFT** \>\> **SWP_TYPE_BITS**) \\ 236 \| ((**unsigned long**)(type) \<\< (64-**SWP_TYPE_BITS**)) })

 

*Listing 12-12:* arch/x86/include/asm/pgtable_64.h: [*\_\_swp_entry()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64.h?h=v6.0#n234)

 

The x86-64-specific [\_\_swp_entry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64.h?h=v6.0#n234) function first shifts the bitwise-inverse

of the offset value by [SWP_OFFSET_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64.h?h=v6.0#n219), this is done in order to truncate higher bits above that for which x86-64 provides space. We examine this

value in Listing 12-13.

 

**N O T E** We invert the offset value in order to mitigate the *L1TF* side-channel vulnerability,

discussion of which is outside the scope of the book. However the intent is that this inversion results in an invalid physical address being specified (even once shifted back into place) and thus prevents speculation, mitigating the issue.

 

218 */\* We always extract/encode the offset by shifting it all the way up, and then*

*down again \*/*

219 **\#define SWP_OFFSET_SHIFT** (**SWP_OFFSET_FIRST_BIT**+**SWP_TYPE_BITS**)

 

*Listing 12-13:* arch/x86/include/asm/pgtable_64.h: [*SWP_OFFSET_SHIFT*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64.h?h=v6.0#n219)

 

The [SWP_OFFSET_FIRST_BIT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64.h?h=v6.0#n216) value is equal to [\_PAGE_BIT_PROTNONE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n39) plus one,

i.e. indicating that this bit and those below it are preserved in the PTE and subtracted from available space for the offset. This occupies 9 bits. The

[SWP_TYPE_BITS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64.h?h=v6.0#n214) value is equal to 5, so that means that the preserved bits and the type value occupy 14 bits, leaving 50 bits for the offset.

 

**N O T E** This operation therefore zeroes all of the lower bits. The meanings of any existing bits

are therefore null and void. The defining characteristic of the swap entry is that it is both non-present (typically least significant bit is clear) and non-empty.

 

Returning to [\_\_swp_entry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64.h?h=v6.0#n234) in Listing 12-12, we therefore see that unavail-

able upper bits for the swap offset are truncated, after which we shift right

by [SWP_TYPE_BITS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64.h?h=v6.0#n214), making room for the type (i.e. swap file index) at the most significant bits before placing it there.

The inverse of [swp_entry_to_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swapops.h?h=v6.0#n90) is [pte_to_swp_entry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swapops.h?h=v6.0#n77) which converts a

swap PTE to a [swp_entry_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n820). We examine this in Listing 12-11.

 



 

73 */\**

74 *\* Convert the arch-dependent pte representation of a swp_entry_t into an*

75 *\* arch-independent swp_entry_t.*

76 *\*/*

77 **static inline swp_entry_t pte_to_swp_entry**(**pte_t** pte)

78 {

79 **swp_entry_t** arch_entry;

80

81 pte = **pte_swp_clear_flags**(pte);

82 arch_entry = **\_\_pte_to_swp_entry**(pte);

83 **return swp_entry**(**\_\_swp_type**(arch_entry), **\_\_swp_offset**(arch_entry));

84 }

 

*Listing 12-14:* include/linux/swapops.h: [*pte_to_swp_entry()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swapops.h?h=v6.0#n77)

 

This starts with a new aspect to swap PTEs—clearing any existing “swap

flags” that were established for the mapping via [pte_swp_clear_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swapops.h?h=v6.0#n27)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swapops.h?h=v6.0#n27) which

we examine in Listing 12-15.

We define a number of flags which “borrow” existing bits in the por-

tion of the PTE which we have reserved for flags, i.e. for x86-64, at bit

[SWP_OFFSET_FIRST_BIT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64.h?h=v6.0#n216) or below.

This preserves information that we wish to maintain at the PTE level and

retain even while the mapping is swapped out.

 

26 */\* Clear all flags but only keep swp_entry_t related information \*/*

27 **static inline pte_t pte_swp_clear_flags**(**pte_t** pte)

28 {

29 **if** (**pte_swp_exclusive**(pte))

30 pte = **pte_swp_clear_exclusive**(pte);

31 **if** (**pte_swp_soft_dirty**(pte))

32 pte = **pte_swp_clear_soft_dirty**(pte);

33 **if** (**pte_swp_uffd_wp**(pte))

34 pte = **pte_swp_clear_uffd_wp**(pte);

35 **return** pte;

36 }

 

*Listing 12-15:* include/linux/swapops.h: [*pte_swp_clear_flags()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swapops.h?h=v6.0#n27)

 

This indicates three possible flags—a “swap exclusive” flag,

[\_PAGE_SWP_EXCLUSIVE, ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n169)which determines if the swap entry is mapped exclu-

sively to this PTE, a soft-dirty flag which propagates the software-defined

dirty bit (see the [soft-dirty](https://kernel.org/doc/html/v6.0/admin-guide/mm/soft-dirty.html) documentation for details), [\_PAGE_SWP_SOFT_DIRTY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n97)

and an out-of-scope userfaultfd flag used to track user write protect fault

handling, [\_PAGE_SWP_UFFD_WP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n104)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n104)

In each instance, we check for the flag, and if set, clear it. We won’t look

into the functions which do this directly as they are simple wrappers around

the aforementioned flag values.

Returning to [pte_to_swp_entry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swapops.h?h=v6.0#n77) (see Listing 12-14), after we clear the

flags we now have a value of type [pte_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n21) containing the raw PTE with lower

 



 

bits cleared. We then use the architecture-specific [\_\_pte_to_swp_entry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64.h?h=v6.0#n238) to

convert it to a [swp_entry_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n820) (for x86-64 this is pass-through).

Finally we extract the architecture-specific type (i.e. swap file index) and

offset using [\_\_swp_type()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64.h?h=v6.0#n224) and [\_\_swp_offset()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64.h?h=v6.0#n227) respectively which simply invert

the operations performed by [\_\_swp_entry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64.h?h=v6.0#n234) (see Listing 12-12).

These are fed into the architecture-independent [swp_entry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swapops.h?h=v6.0#n41) function,

as shown in Listing 12-3, which simply combines the two values into a

[swp_entry_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n820).

 

**12.2 Swapping Out**

 

Swapping out occurs as part of reclaim (see Chapter 11). The key function

of which is [shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) (see the discussion around Listing 11-63 for a fuller discussion of this function).

We examine how swapping out is performed in Figure 12-1.

 

Reclaim

 

If not already in swap cache If swap out writeback complete

[shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589)

 

If mapped If dirty [\_\_remove_mapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1289)

 

[add_to_swap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n174) [try_to_unmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1812) [pageout()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1215) [free_unref_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3510)

 

1. Add folio to swap 2. Iterate through 3. Swap folio out 4. (After writeback

cache, increment all mappings, drop to disk, begin asyn- complete) Remove

reference count, assign reference count chronous writeback. the folio from swap

[PG_swapcache](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n158) flag, for each, replace cache then free the

Assign [swp_entry_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n820) to PTE entries with folio from memory.

[struct folio-\>private](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256), swap entries.

mark dirty.

 

(See Section 12.2.1) (See Section 12.2.2) (See Section 12.2.3) (See Section 12.2.4)

 

*Figure 12-1: Swap Out Overview*

 

**N O T E** When paged out, the folio will be moved to the head of the appropriate LRU list (re-

claim is performed from the tail). This delays any attempt to actually free the memory until the folio is next considered for reclaim. However, a folio which has just com-

pleted writeback and has the [*PG_reclaim*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n119) flag set (as it will be on swap out) is immedi-

ately placed on the inactive tail to be reclaimed next via [*folio_rotate_reclaimable()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n283),

called from [*folio_end_writeback()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1599)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1599) See Chapter 11 on reclaim for more details.

 



 

While we have examined [shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) in detail already, for the pur-

poses of examining how it performs swapping out we will examine only the

parts of it which perform tasks related to this, starting in Listing 12-16.

 

1589 **static unsigned int shrink_page_list**(**struct** list_head \*page_list, 1590 **struct** pglist_data \*pgdat, 1591 **struct** scan_control \*sc, 1592 **struct** reclaim_stat \*stat, 1593 **bool** ignore_references) 1594 {

. . .

1608 **while** (!**list_empty**(page_list)) {

. . .

1766 */\**

1767 *\* Anonymous process memory has backing store?* 1768 *\* Try to allocate it some swap space here.* 1769 *\* Lazyfree folio could be freed directly* 1770 *\*/*

1771 **if** (**folio_test_anon**(folio) && **folio_test_swapbacked**(folio)) { 1772 **if** (!**folio_test_swapcache**(folio)) {

. . .

1791 **if** (!**add_to_swap**(folio)) {

. . .

1793 **goto activate_locked_split**;

. . .

1803 } 1804 }

. . .

1804 }

. . .

 

*Listing 12-16:* mm/vmscan.c: [*shrink_page_list()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) *Adding to Swap Cache*

 

This determines whether the folio is eligible to be swapped out—

whether it is both anonymous and swap-backed, the former checked by

[folio_test_anon()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n656) and the latter by checking for the [PG_swapbacked](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n120) folio flag.

 

**N O T E** The [*PG_swapbacked*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n120) flag is set in [*page_add_new_anon_rmap()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1262) when anonymous mem-

ory is allocated (see Chapter 7), and when folios are swapped in (via [*do_swap_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3718)

and [*\_\_read_swap_cache_async()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n409)). Anonymous memory without [*PG_swapbacked*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n120) set is

lazyfree (i.e. memory marked by user with the [*MADV_FREE*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/asm-generic/mman-common.h?h=v6.0#n52) flag via [*madvise()*](https://man7.org/linux/man-pages/man2/madvise.2.html) to eventu-

ally be freed on reclaim) see Chapter 8). Therefore the [*PG_swapbacked*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n120) flag is a defin-

ing characteristic of anonymous memory.

 

If it is indeed permitted to be swapped out, then we invoke [add_to_swap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n174)

to add it to the swap cache, a function we explore in Listing 12-20 in Section

12.2.1.

Next, we consider how swap entries are inserted into the page table on

swap out, which we examine in Listing 12-17.

 



 

1822 */\**

1823 *\* The folio is mapped into the page tables of one or more*

1824 *\* processes. Try to unmap it here.* 1825 *\*/*

1826 **if** (**folio_mapped**(folio)) { 1827 **enum** ttu_flags flags = **TTU_BATCH_FLUSH**;

. . .

1833 **try_to_unmap**(folio, flags); 1834 **if** (**folio_mapped**(folio)) {

. . .

1839 **goto activate_locked**; 1840 } 1841 }

 

*Listing 12-17:* mm/vmscan.c: [*shrink_page_list()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) *Setting Up Swap Entries*

 

Note that we only perform an action here if the folio is mapped, as de-

termined by the [folio_mapped()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n758) helper function. This function looks up the

folio’s map count, as explored in Chapter 2, which is used to track the num-ber of PTEs (or if a huge page, PMDs or PUDs) the folio is mapped into (for

more on PUD, PMD and PTE page tables, see Chapter 3).

This makes sense, as obviously attempting to unmap a folio which is not

currently mapped would be an exercise in pointlessness. Since the folio is locked at this stage we can rely on the state of the mapping not changing until reclaim has been performed upon it.

The function which ultimately performs the unmapping is [try_to_unmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1812)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1812)

In the case of swapping out, this instead introduces swap entries into the relevant PTE entries which indicates to the kernel that, if these mappings are faulted upon, a swap in operation has to take place.

We examine the parts of [try_to_unmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1812) pertinent to adding swap entries

in Listing 12-23 in Section 12.2.2.

If, after the attempted unmapping, the folio remains mapped, this indi-

cates that the unmapped failed. In this instance we “activate” the folio, i.e. if it was not already on the active LRU, putting it there so it can be examined

next time (the folio will be added to the end of this list). See Chapter 11 for more details on active/inactive LRUs.

Next, we consider how we actually perform the swapping out to disk,

which we examine in Listing 12-18.

 

1843 mapping = **folio_mapping**(folio); 1844 **if** (**folio_test_dirty**(folio)) {

. . .

1886 **switch** (**pageout**(folio, mapping, &plug)) { 1887 **case PAGE_KEEP**: 1888 **goto keep_locked**; 1889 **case PAGE_ACTIVATE**: 1890 **goto activate_locked**; 1891 **case PAGE_SUCCESS**:

 



 

. . .

1896 **if** (**folio_test_dirty**(folio)) 1897 **goto keep**;

. . .

1903 **if** (!**folio_trylock**(folio)) 1904 **goto keep**; 1905 **if** (**folio_test_dirty**(folio) \|\| 1906 **folio_test_writeback**(folio)) 1907 **goto keep_locked**; 1908 mapping = **folio_mapping**(folio); 1909 **fallthrough**; 1910 **case PAGE_CLEAN**: 1911 ; */\* try to free the folio below \*/* 1912 } 1913 }

. . .

 

*Listing 12-18:* mm/vmscan.c: [*shrink_page_list()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) *Swapping Out to Disk*

 

At this stage, the folio should be marked dirty, either by virtue of the

anonymous folio having been written to (and thus not being a Copy-on-

Write mapping), thus resulting in the dirty bit being set in the PTE and

the folio’s dirty flag having been set in [try_to_unmap_one()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1476) as invoked by

[try_to_unmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1812) as discussed in Listing 12-23 and Section 12.2.2, or as as a re-

sult of [add_to_swap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n174) marking it dirty as shown in Listing 12-20 and Section

12.2.1.

This means that the test for the folio’s dirty flag shown in Listing 12-18

will succeed, and thus [pageout()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1215) will be invoked to perform the actual write

out to disk, a function whose swap-specific behaviour we examine in Listing

12-26 and Section 12.2.3.

After the [pageout()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1215) call is complete, we determine its outcome—if

the asynchronous I/O was initiated to swap the folio out to disk, then

[PAGE_SUCCESS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1206) is returned and the folio is unlocked.

At this point it’s a case of checking whether the folio was somehow

redirtied (i.e. could not be written out), cannot be immediately relocked

(e.g. a synchronous write back occurred such as for a RAM-backed file sys-

tem), or if writeback is currently underway (a likely outcome, see Chapter 10

for details on how writeback functions).

In each of these instances we “keep” the folio (perhaps activating it), as

we cannot immediately attempt to free it. This means that freeing the folio

will be deferred to a later stage (again, see Chapter 11 for a detailed analysis

of the reclaim mechanism).

In the usual course of events, the folio will be subject to [pageout()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1215) which

swaps out the folio to disk asynchronously, then placed back on its LRU list

i.e. “kept”, then when next subject to reclaim, finally freed.

The reclaim logic which causes the freeing of the folio is shown in Listing

12-19.

 

1843 **if** (**folio_test_anon**(folio) && !**folio_test_swapbacked**(folio)) {

 



 

. . .

1973 } **else if** (!mapping \|\| !**\_\_remove_mapping**(mapping, folio, **true**, 1974 sc-\>target_mem_cgroup

))

1975 **goto keep_locked**; 1976

1977 **folio_unlock**(folio);

. . .

1992 **list_add**(&folio-\>lru, &free_pages); 1993 **continue**; 1994

1995 **activate_locked_split**:

. . .

2004 **activate_locked**:

2005 */\* Not a candidate for swapping, so reclaim swap space. \*/*

2006 **if** (**folio_test_swapcache**(folio) &&

. . .

2008 **folio_test_mlocked**(folio))) 2009 **try_to_free_swap**(&folio-\>page);

. . .

2017 **keep_locked**:

2018 **folio_unlock**(folio); 2019 **keep**:

2020 **list_add**(&folio-\>lru, &ret_pages);

. . .

2023 }

. . .

2040 **free_unref_page_list**(&free_pages); 2041

2042 **list_splice**(&ret_pages, page_list);

. . .

2048 }

 

*Listing 12-19:* mm/vmscan.c: [*shrink_page_list()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) *Freeing Swap*

 

**N O T E** Whatever pages are left in the *page_list* after this function is complete are eventu-

ally placed back on the appropriate LRU via [*move_pages_to_lru()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2323).

 

Note that the mapping value here will be set to the result of [folio_mapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n799),

not to be confused with [folio_mapped()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n758) which indicates whether the folio is mapped by any userland process.

So for an entry in the swap cache not currently undergoing writeback,

mapping will always be non-NULL, meaning that should we reach this point in

[shrink_page_list() , ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589)we will always invoke [\_\_remove_mapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1289).

We explore the swap-relevant parts of [\_\_remove_mapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1289) in Listing 12-29

and Section 12.2.4. This function checks that nothing unexpectedly refer-ences the folio, then drops the reference count “freezing” it, before remov-ing it from the swap cache and freeing up relevant resources.

 



 

Once this has been done, the folio is unlocked and added to the

free_pages list which is ultimately freed via [free_unref_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3510) (see Section

2.9 for more details on the physical page allocator’s freeing mechanism).

The final swap case handled by [shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) is one where a swap

cache folio has become ineligible for being swapped out, by being [mlock](https://man7.org/linux/man-pages/man2/mlock.2.html)[ed](https://man7.org/linux/man-pages/man2/mlock.2.html)

(there is also a cgroup-specific case not shown in the listing but this is out of

scope for the book).

In this instance we simply wish to free up the swap cache entry associated

with the folio, which we do via [try_to_free_swap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n1590), a function we examine in

Listing 12-31 and Section 12.2.4.

We note that all instances of activation or keeping the folio we place the

folio on to the ret_pages list which are ultimately placed back into the appro-

priate LRU list (see Section 11.2 for more details on LRU lists in general).

Let’s examine each of this stages of swapping out one-by-one.

 

***12.2.1 Adding a Folio to the Swap Cache***

When we designate folios to be swapped out, we must first place them into

the swap cache, which we perform by invoking [add_to_swap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n174) during reclaim

in [shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) as described in Section 12.2. We examine this function

in Listing 12-20.

 

164 */\*\**

165 *\* add_to_swap - allocate swap space for a folio* 166 *\* @folio: folio we want to move to swap* 167 *\**

168 *\* Allocate swap space for the folio and add the folio to the* 169 *\* swap cache.*

170 *\**

171 *\* Context: Caller needs to hold the folio lock.* 172 *\* Return: Whether the folio was added to the swap cache.* 173 *\*/*

174 **bool add_to_swap**(**struct** folio \*folio) 175 {

176 **swp_entry_t** entry; 177 **int** err;

. . .

182 entry = **folio_alloc_swap**(folio); 183 **if** (!entry.val)

184 **return false**;

185

186 */\**

187 *\* XArray node allocations from PF_MEMALLOC contexts could* 188 *\* completely exhaust the page allocator. \_\_GFP_NOMEMALLOC* 189 *\* stops emergency reserves from being allocated.* 190 *\**

191 *\* TODO: this could cause a theoretical memory reclaim* 192 *\* deadlock in the swap out path.*

 



 

193 *\*/*

194 */\**

195 *\* Add it to the swap cache.* 196 *\*/*

197 err = **add_to_swap_cache**(&folio-\>page, entry, 198 **\_\_GFP_HIGH**\|**\_\_GFP_NOMEMALLOC**\|**\_\_GFP_NOWARN**, **NULL**); 199 **if** (err)

200 */\**

201 *\* add_to_swap_cache() doesn't return -EEXIST, so we can*

*safely*

202 *\* clear SWAP_HAS_CACHE flag.* 203 *\*/*

204 **goto fail**; 205 */\**

206 *\* Normally the folio will be dirtied in unmap because its* 207 *\* pte should be dirty. A special case is MADV_FREE page. The* 208 *\* page's pte could have dirty bit cleared but the folio's* 209 *\* SwapBacked flag is still set because clearing the dirty bit* 210 *\* and SwapBacked flag has no lock protected. For such folio,* 211 *\* unmap will not set dirty bit for it, so folio reclaim will* 212 *\* not write the folio out. This can cause data corruption when* 213 *\* the folio is swapped in later. Always setting the dirty flag* 214 *\* for the folio solves the problem.* 215 *\*/*

216 **folio_mark_dirty**(folio); 217

218 **return true**;

219

220 **fail**:

221 **put_swap_page**(&folio-\>page, entry); 222 **return false**;

223 }

 

*Listing 12-20:* mm/swap_state.c: [*add_to_swap()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n174)

 

We start by allocating a swap entry using [folio_alloc_swap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_slots.c?h=v6.0#n302), which we

examine in Listing 12-21 (eliding out of scope huge page and cgroup han-dling).

This uses a global per-CPU cache of swap slots and attempts to assign

from here rather than resorting to actually allocating a swap entry from the underlying swap medium (file or partition).

If allocated, then the returned [swp_entry_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n820) value encodes the specific

swap file and offset within it that contains this entry. If there insufficient space available to allocate swap, then we return false.

If we successfully allocate a swap entry, we then proceed to add it to the

pertinent [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) swapper space via [add_to_swap_cache()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n88).

At this point it is absolutely critical that the underlying folio be marked

dirty, which we anticipate will be the case upon setting page table swap en-

 



 

tries (see Section 12.2.2), however to ensure that this is always the case, we

mark the folio dirty via [folio_mark_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2730).

If any error occurs after the swap entry is created, we drop its reference

count within the swap file via [put_swap_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n1331).

Note that the swap file handling logic which determines how to interact

with the swap file itself, as implemented in [mm/swapfile.c](https://elixir.bootlin.com/linux/v6.0/source/mm/swapfile.c)[,](https://elixir.bootlin.com/linux/v6.0/source/mm/swapfile.c) is complicated, and

the detail of this is out of scope for the book. We rather focus on the higher

level abstractions which form part of the swap implementation.

 

302 **swp_entry_t folio_alloc_swap**(**struct** folio \*folio) 303 {

304 **swp_entry_t** entry; 305 **struct** swap_slots_cache \*cache;

306

307 entry.val = 0;

. . .

315 */\**

316 *\* Preemption is allowed here, because we may sleep* 317 *\* in refill_swap_slots_cache(). But it is safe, because* 318 *\* accesses to the per-CPU data structure are protected by the* 319 *\* mutex cache-\>alloc_lock.* 320 *\**

321 *\* The alloc path here does not touch cache-\>slots_ret* 322 *\* so cache-\>free_lock is not taken.* 323 *\*/*

324 cache = **raw_cpu_ptr**(&**swp_slots**);

325

326 **if** (**likely**(**check_cache_active**() && cache-\>slots)) { 327 **mutex_lock**(&cache-\>alloc_lock); 328 **if** (cache-\>slots) { 329 **repeat**:

330 **if** (cache-\>nr) { 331 entry = cache-\>slots\[cache-\>cur\]; 332 cache-\>slots\[cache-\>cur++\].val = 0; 333 cache-\>nr--; 334 } **else if** (**refill_swap_slots_cache**(cache)) { 335 **goto repeat**; 336 } 337 }

338 **mutex_unlock**(&cache-\>alloc_lock); 339 **if** (entry.val) 340 **goto out**; 341 }

342

343 **get_swap_pages**(1, &entry, 1); 344 **out**:

. . .

349 **return** entry;

 



 

350 }

 

*Listing 12-21:* mm/swap_slots.c: [*folio_alloc_swap()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_slots.c?h=v6.0#n302)

 

The [folio_alloc_swap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_slots.c?h=v6.0#n302) function starts by checking a swap slot cache,

maintained in the [swp_slots](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_slots.c?h=v6.0#n38) static value. This maintains [SWAP_SLOTS_CACHE_SIZE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap_slots.h?h=v6.0#n9)

number of swap slot values (hard-coded to be equal to [SWAP_BATCH](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n35) or 64 slots).

For brevity, we won’t examine this implementation in detail, but in ei-

ther the case where the cache needs refilling or the cache is either disabled

or needs refilling, the [get_swap_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n1043) is called to obtain swap entries from available swap files.

 

**N O T E** As previously discussed, we will not examine the swap file implementation in detail,

as it rapidly becomes a file system discussion rather than a memory management one.

 

Returning to [add_to_swap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n174) (as shown in Listing 12-20), we note that

the key logic for adding the newly allocated swap entry (i.e. now tied to a specific offset in a swap file on disk) to the swap cache is performed by

[add_to_swap_cache(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n88)as shown in Listing 12-22 (eliding out of scope working set shadow entry tracking and debug logic).

 

84 */\**

85 *\* add_to_swap_cache resembles filemap_add_folio on swapper_space,* 86 *\* but sets SwapCache flag and private instead of mapping and index.* 87 *\*/*

88 **int add_to_swap_cache**(**struct** page \*page, **swp_entry_t** entry, 89 **gfp_t** gfp, **void** \*\*shadowp) 90 {

91 **struct** address_space \*address_space = **swap_address_space**(entry); 92 **pgoff_t** idx = **swp_offset**(entry); 93 **XA_STATE_ORDER**(xas, &address_space-\>i_pages, idx, **compound_order**(page)

);

94 **unsigned long** i, nr = **thp_nr_pages**(page);

. . .

101 **page_ref_add**(page, nr); 102 **SetPageSwapCache**(page); 103

104 **do** {

105 **xas_lock_irq**(&xas); 106 **xas_create_range**(&xas); 107 **if** (**xas_error**(&xas)) 108 **goto unlock**; 109 **for** (i = 0; i \< nr; i++) {

. . .

116 **set_page_private**(page + i, entry.val + i); 117 **xas_store**(&xas, page); 118 **xas_next**(&xas); 119 }

 



 

120 address_space-\>nrpages += nr; 121 **\_\_mod_node_page_state**(**page_pgdat**(page), **NR_FILE_PAGES**, nr); 122 **\_\_mod_lruvec_page_state**(page, **NR_SWAPCACHE**, nr); 123 **unlock**:

124 **xas_unlock_irq**(&xas); 125 } **while** (**xas_nomem**(&xas, gfp));

126

127 **if** (!**xas_error**(&xas)) 128 **return** 0;

129

130 **ClearPageSwapCache**(page); 131 **page_ref_sub**(page, nr); 132 **return xas_error**(&xas); 133 }

 

*Listing 12-22:* mm/swap_state.c: [*add_to_swap_cache()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n88)

 

In [add_to_swap_cache()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n88) we can observe that the [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) object

which we obtain via [swap_address_space()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.h?h=v6.0#n30) (as shown in Listing 12-4) is makes

use of the [struct address_space-\>i_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) xarray in order to store swap cache

pages (see Section 9.2 in Chapter 9 for more on xarray).

We won’t dwell too deeply on the xarray primitives used here (again, see

Section 9.2 for a detailed analysis), but rather observe how we update both

the folio and the swapper address space to mark that this folio is now in the

swap cache.

We obtain the offset within the swap address via [swp_offset()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swapops.h?h=v6.0#n62) (see List-

ing 12-6), and then construct xarray state to be able to iterate through the

relevant sub-pages contained within the folio.

 

**N O T E** In this instance, the only occasion when the folio would be larger than order-0 is if

it were a Transparent Huge Page. This is out of scope for the book, but we can see

that we obtain the number of sub-pages via [*thp_nr_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n951) which simply looks up the

compound number of pages, see Chapter 2 for more details on compound folios.

 

We pin the folio by incrementing its reference via [page_ref_add()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page_ref.h?h=v6.0#n118), and

mark the folio with the [PG_swapcache](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n158) flag via the SetPageSwapCache() macro-

generated helper function.

For each individual sub-page of the folio, we set its [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72)-\>private

field to the [swp_entry_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n820) describing its location in this swap address space,

through use of the [set_page_private()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n335) function. Note that we offset each en-

try by sub-page index if a compound folio to account for it being offset in

the xarray.

We discuss how this field is accessed in Section 12.1.2. This field is ulti-

mately accessed via [folio_mapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n799)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n799) whose swap-relevant parts we examine in

Listing 12-8.

We update the [struct address_space-\>nrpages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) field accordingly to count

the number of entries in the swapper address space and also update statis-

tics accordingly.

 



 

Finally, if no error arose we simply exit, therwise we clear the folio’s

[PG_swapcache](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n158) flag, unpin it via [page_ref_sub()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page_ref.h?h=v6.0#n130) and return the error.

 

***12.2.2 Setting Page Table Swap Entries***

Returning to Figure 12-1, we observe that after adding an entry to the swap cache reclaim then proceeds to remove page table mappings via

[try_to_unmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1812), which we examine in Listing 12-23.

 

1801 */\*\**

1802 *\* try_to_unmap - Try to remove all page table mappings to a folio.* 1803 *\* @folio: The folio to unmap.* 1804 *\* @flags: action and flags* 1805 *\**

1806 *\* Tries to remove all the page table entries which are mapping this* 1807 *\* folio. It is the caller's responsibility to check if the folio is* 1808 *\* still mapped if needed (use TTU_SYNC to prevent accounting races).* 1809 *\**

1810 *\* Context: Caller must hold the folio lock.* 1811 *\*/*

1812 **void try_to_unmap**(**struct** folio \*folio, **enum** ttu_flags flags) 1813 {

1814 **struct** rmap_walk_control rwc = { 1815 .rmap_one = **try_to_unmap_one**, 1816 .arg = (**void** \*)flags, 1817 .done = **page_not_mapped**, 1818 .anon_lock = **folio_lock_anon_vma_read**, 1819 };

1820

1821 **if** (flags & **TTU_RMAP_LOCKED**) 1822 **rmap_walk_locked**(folio, &rwc); 1823 **else**

1824 **rmap_walk**(folio, &rwc); 1825 }

 

*Listing 12-23:* mm/rmap.c: [*try_to_unmap()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1812)

 

The [try_to_unmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1812) function utilises the reverse mapping functionality

(see Chapter 7 for details on this) to find all [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) mappings which might reference the specified folio, and calls the specified

callback function, which is [try_to_unmap_one()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1476)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1476) whose swap-specific code we

examine in Listing 12-24.

We stop the traversal if the specified [page_not_mapped()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1796) function returns

true, which in turn checks whether [folio_mapped()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n758) returns false—this function

simply (atomically) checks whether the [struct folio-\>\_mapcount](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) field is greater than or equal to zero (this is equal to the number of mappings of the folio minus one, so a value of zero implies that it is mapped once).

We pass [enum ttu_flags](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n93) to the function which specify various options for

modifying the operation, we will not examine these in detail.

 



 

We examine the swap-specific logic in [try_to_unmap_one()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1476) in Listing

12-24 (eliding logic irrelevant to swap handling, TTU flags not set by

[shrink_page_list() , ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589)out of scope MMU notifier logic, huge page handling,

userfautlfd handling, hardware poisoning, architecture-specific virtualisa-

tion, lazy free (i.e. MADV_FREE via [madvise()](https://man7.org/linux/man-pages/man2/madvise.2.html)), high watermark RSS handling,

architecture-specific missing PTE flag handling and debug checks).

 

1476 **static bool try_to_unmap_one**(**struct** folio \*folio, **struct** vm_area_struct \*vma, 1477 **unsigned long** address, **void** \*arg) 1478 {

1479 **struct** mm_struct \*mm = vma-\>vm_mm; 1480 **DEFINE_FOLIO_VMA_WALK**(pvmw, folio, vma, address, 0); 1481 **pte_t** pteval;

1482 **struct** page \*subpage; 1483 **bool** anon_exclusive, ret = **true**;

. . .

1485 **enum** ttu_flags flags = (**enum** ttu_flags)(**long**)arg;

. . .

1520 **while** (**page_vma_mapped_walk**(&pvmw)) {

. . .

1524 */\**

1525 *\* If the folio is in an mlock()d vma, we must not swap it out*

*.*

1526 *\*/*

1527 **if** (!(flags & **TTU_IGNORE_MLOCK**) && 1528 (vma-\>vm_flags & **VM_LOCKED**)) { 1529 */\* Restore the mlock which got missed \*/* 1530 **mlock_vma_folio**(folio, vma, **false**); 1531 **page_vma_mapped_walk_done**(&pvmw); 1532 ret = **false**; 1533 **break**; 1534 }

1535

1536 subpage = **folio_page**(folio, 1537 **pte_pfn**(\*pvmw.pte) -**folio_pfn**(folio))

;

1538 address = pvmw.address; 1539 anon_exclusive = **folio_test_anon**(folio) && 1540 **PageAnonExclusive**(subpage); 1541

1542 **if** (**folio_test_hugetlb**(folio)) {

. . .

1583 } **else** {

. . .

1585 */\** 1586 *\* Nuke the page table entry. When having to clear*

1587 *\* PageAnonExclusive(), we always have to flush.* 1588 *\*/*

 



 

1589 **if** (**should_defer_flush**(mm, flags) && !anon_exclusive)

{

. . .

1598 pteval = **ptep_get_and_clear**(mm, address, pvmw.

pte);

. . .

1601 } **else** { 1602 pteval = **ptep_clear_flush**(vma, address, pvmw.

pte);

1603 } 1604 }

. . .

1613 */\* Set the dirty flag on the folio now the pte is gone. \*/*

1614 **if** (**pte_dirty**(pteval)) 1615 **folio_mark_dirty**(folio);

. . .

1620 **if** (**PageHWPoison**(subpage) && !(flags & **TTU_IGNORE_HWPOISON**)) {

. . .

1645 } **else if** (**folio_test_anon**(folio)) { 1646 **swp_entry_t** entry = { .val = **page_private**(subpage) }; 1647 **pte_t** swp_pte;

. . .

1707 **if** (**swap_duplicate**(entry) \< 0) { 1708 **set_pte_at**(mm, address, pvmw.pte, pteval); 1709 ret = **false**; 1710 **page_vma_mapped_walk_done**(&pvmw); 1711 **break**; 1712 }

. . .

1720 **if** (anon_exclusive && 1721 **page_try_share_anon_rmap**(subpage)) { 1722 **swap_free**(entry); 1723 **set_pte_at**(mm, address, pvmw.pte, pteval); 1724 ret = **false**; 1725 **page_vma_mapped_walk_done**(&pvmw); 1726 **break**; 1727 }

. . .

1745 **dec_mm_counter**(mm, **MM_ANONPAGES**); 1746 **inc_mm_counter**(mm, **MM_SWAPENTS**); 1747 swp_pte = **swp_entry_to_pte**(entry); 1748 **if** (anon_exclusive) 1749 swp_pte = **pte_swp_mkexclusive**(swp_pte); 1750 **if** (**pte_soft_dirty**(pteval)) 1751 swp_pte = **pte_swp_mksoft_dirty**(swp_pte);

. . .

1754 **set_pte_at**(mm, address, pvmw.pte, swp_pte);

 



 

. . .

1758 } **else** {

. . .

1771 }

. . .

1780 **page_remove_rmap**(subpage, vma, **folio_test_hugetlb**(folio));

. . .

1783 **folio_put**(folio); 1784 }

. . .

1788 **return** ret;

1789 }

 

*Listing 12-24:* mm/rmap.c: [*try_to_unmap_one()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1476) *Swap Logic*

 

The [try_to_unmap_one()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1476) function starts by declaring a

[struct page_vma_mapped_walk](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n316) type (see Listing 12-25) used to thread state

while iterating through the page tables mapping the folio, initialised by

[DEFINE_FOLIO_VMA_WALK()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n338) and iterated through via [page_vma_mapped_walk()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_vma_mapped.c?h=v6.0#n151).

 

316 **struct** page_vma_mapped_walk { 317 **unsigned long** pfn; 318 **unsigned long** nr_pages; 319 **pgoff_t** pgoff;

320 **struct** vm_area_struct \*vma; 321 **unsigned long** address; 322 **pmd_t** \*pmd;

323 **pte_t** \*pte;

324 **spinlock_t** \*ptl;

325 **unsigned int** flags; 326 };

 

*Listing 12-25:* include/linux/rmap.h: [*struct page_vma_mapped_walk*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n316)

 

The [struct page_vma_mapped_walk](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n316) type encodes state about the currently

examined PTE as well as the PTE lock it acquired to allow us to interact with

the PTE, which we must release once we’re done with it.

The [page_vma_mapped_walk()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_vma_mapped.c?h=v6.0#n151) function walks the page tables and acquires

the PTE lock for us (placed in [struct page_vma_mapped_walk-\>ptl](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n316)), handling all

edge cases and detecting whether the mapping is still valid, returning true if

the iteration can continue, otherwise returning false.

 

**N O T E** At this stage, we can safely assume that the [*struct mm_struct*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)*-\>mmap_lock* is held.

 

We can therefore safely assume that [struct page_vma_mapped_walk-\>pte](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n316) can

be updated throughout the operation.

In the case of swap out, [shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) calls with the [TTU_BATCH_FLUSH](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n98)

flag set (and optionally a huge PMD flag but this is out of scope for the

book), therefore [TTU_IGNORE_MLOCK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n95) will not be set and so we must consider the

[mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html) edge case.

 



 

The edge case arises when the [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) flag [VM_LOCKED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n282)

has been set, indicating that all memory described by the VMA should be

locked by [mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html)[,](https://man7.org/linux/man-pages/man2/mlock.2.html) however it has somehow not been marked by [PG_mlocked](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n123) or

[PG_unevictable](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n121), or has otherwise somehow ended up in reclaim.

We resolve this edge case by invoking [mlock_vma_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n511) to resolve the sit-

uation, before terminating the iteration via [page_vma_mapped_walk_done()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n348) and

exiting the loop. See Section 8.2.1 in Chapter 8 for more on [mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html)[.](https://man7.org/linux/man-pages/man2/mlock.2.html)

With this edge case accounted for, we determine the subpage via

[folio_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n288), obtaining the offset by calculating the difference between the PFN of the folio (i.e. the head page) and that of the PTE.

This way, if we happen to be examining a compound folio spread over

multiple PTEs (possible in some huge page scenarios), we will examine each

of tail sub-pages individually (see Chapter 2 for more details on PTEs, folios and compound pages).

We determine whether this is an anonymous page which is mapped ex-

clusively by only one process, as this changes how the kernel handles such mappings and is a trait we encode in swapped out folios. We retain this state in anon_exclusive.

 

**N O T E** When updating PTEs, it is very important to ensure that the update proceeds in a

predictable order. We therefore always clear the PTE entry (causing accesses to that address that hit the page tables to fault) before setting it to a new value. We must also then ensure that the Transaction Lookaside Buffer (TLB) that caches virtual to physical addresses is appropriately cleared.

 

The [should_defer_flush()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n691) function indicates whether both [TTU_BATCH_FLUSH](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n98)

is set (true for reclaim) and whether the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) is in use by any other CPUs. If both are true, then we are permitted and it is worthwhile for us to batch flushing the TLB rather than flushing at each point of clearing the PTE entry.

In addition, if the mapping is anonymous-exclusive, then we know for

certain that no other CPU could be accessing the mapping and thus batch-ing is not useful.

In the case that we defer flushing, we invoke [ptep_get_and_clear()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1048) to clear

and retrieve the PTE value atomically, without any update to the TLB. Oth-

erwise, we invoke [ptep_clear_flush()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/pgtable-generic.c?h=v6.0#n91) (see Listing 6-45 in Chapter 6), which

both calls [ptep_get_and_clear()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1048) and clears the TLB flush.

See Section 7.1 in Chapter 7 for more on freeing memory and TLB

maintenance.

As we have cleared the PTE, it now makes sense to mark the folio dirty

via [folio_mark_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2730), something that is absolutely critical for the swap write

out to occur (see Section 12.2.3) as we make use of the fact that the swap cache folios are dirty to start this write-out.

Having previously set the [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72)-\>private field to the [swp_entry_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n820) de-

scribing its assigned position in a swap file (see Section 12.2.1), we retrieve this entry ready to place it in the PTE.

We use the oddly-named [swap_duplicate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n3357) to increment the swap entry’s

reference count, if this fails we restore the original PTE and abort the walk.

 



 

Next, if the folio is anonymous-exclusive, we invoke

[page_try_share_anon_rmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n285) to strip it of the [PG_anon_exclusive](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n152) flag in

preparation for swap out. If this fails, we again restore the PTE and abort

the walk, freeing the swap file entry via [swap_free()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n1319)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n1319)

With edge cases handled, we update statistics to account for the swap

out, convert the [swp_entry_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n820) value to a PTE value via [swp_entry_to_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swapops.h?h=v6.0#n90) (see

Listing 12-11), and proceed by setting swap-specific PTE flags for things

we wish to retain and restore on page in—The anonymous-exclusive trait via

[pte_swp_mkexclusive()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1286) and the soft-dirty flag via [pte_swp_mksoft_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1303).

Having obtained a swap PTE entry and assigned flags, we then set the

PTE itself via [set_pte_at()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1004). At this stage, the swap entry is set.

Finally, we decrement the page’s map count, update statistics and handle

related edge cases via [page_remove_rmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1429)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1429) and decrement the folio’s reference

count via [folio_put()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1122), as a mapping of a folio takes a reference on it and the

mapping has now been removed.

 

***12.2.3 Swapping Out to Disk***

We observe in Figure 12-1 that [shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) invokes [pageout()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1215) on dirty

folios that need to be reclaimed.

As demonstrated previously, by this stage the swap out procedure will

have guaranteed all folios to be swapped out will indeed be dirty, therefore

[pageout()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1215) is invoked on these folios, which we explore in Listing 12-26 (elid-

ing out of scope cgroup and non-swap specific logic).

 

1211 */\**

1212 *\* pageout is called by shrink_page_list() for each dirty page.* 1213 *\* Calls -\>writepage().*

1214 *\*/*

1215 **static pageout_t pageout**(**struct** folio \*folio, **struct** address_space \*mapping, 1216 **struct** swap_iocb \*\*plug) 1217 {

. . .

1253 **if** (**folio_clear_dirty_for_io**(folio)) { 1254 **int** res;

1255 **struct** writeback_control wbc = { 1256 .sync_mode = **WB_SYNC_NONE**, 1257 .nr_to_write = **SWAP_CLUSTER_MAX**, 1258 .range_start = 0, 1259 .range_end = **LLONG_MAX**, 1260 .for_reclaim = 1, 1261 .swap_plug = plug, 1262 };

1263

1264 **folio_set_reclaim**(folio); 1265 res = mapping-\>a_ops-\>**writepage**(&folio-\>page, &wbc); 1266 **if** (res \< 0) 1267 **handle_write_error**(mapping, folio, res);

 



 

1268 **if** (res == **AOP_WRITEPAGE_ACTIVATE**) { 1269 **folio_clear_reclaim**(folio); 1270 **return PAGE_ACTIVATE**; 1271 }

1272

1273 **if** (!**folio_test_writeback**(folio)) { 1274 */\* synchronous write or broken a_ops? \*/* 1275 **folio_clear_reclaim**(folio); 1276 }

. . .

1279 **return PAGE_SUCCESS**; 1280 }

1281

1282 **return PAGE_CLEAN**; 1283 }

 

*Listing 12-26:* mm/vmscan.c: [*pageout()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1215) *Recap*

 

The [pageout()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1215) function marks the [struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) with the [PG_reclaim](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n119) flag

during this operation, which will trigger writeback and in turn set the

[PG_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n116) flag and start asynchronous I/O to perform the actual write to disk.

Prior to doing this, [folio_clear_dirty_for_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2826) is invoked, which clears the

folio’s dirty flag, and marks all mappings to the folio read-only such that we can track whether anything else dirties the folio as they would generate a

page fault if they did so (see Listing 10-30 in Chapter 10 for more details on this dance).

We call the [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)-\>a_ops callback (the callbacks being spec-

ified as a [struct address_space_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n356) object) for writing a single page, writepage() to perform the actual writeback.

 

**N O T E** We specify that up to [*SWAP_CLUSTER_MAX*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n214) (hardcoded to 32) base pages should

be written at one time—when writing to non-block device (file system-mediated) back ends, page writes are batched up and submitted when the batch size reaches

[*SWAP_CLUSTER_MAX*. ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n214)We don’t examine the file system swap code in detail but this batch size is important and dictates batch sizing in reclaim generally (see Chapter

11).

 

This is where the swap logic comes into play, as the address space pro-

vided to [pageout()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1215) by [shrink_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) is derived from [folio_mapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n799) (see

Listing 12-8), which explicitly checks to see if the folio is in the swap cache and if so returns the swapper address space.

The address space operations for the swapper address space are set

by [init_swap_address_space()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n661) on initialisation to [swap_aops](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n32), which sets the

writepage callback to [swap_writepage()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_io.c?h=v6.0#n181), which is what is invoked here, and we

examine in Listing 12-27 (eliding out of scope architecture-specific handling and front-swap logic).

 

177 */\**

 



 

178 *\* We may have stale swap cache pages in memory: notice* 179 *\* them here and get rid of the unnecessary final write.* 180 *\*/*

181 **int swap_writepage**(**struct** page \*page, **struct** writeback_control \*wbc) 182 {

183 **int** ret = 0;

184

185 **if** (**try_to_free_swap**(page)) { 186 **unlock_page**(page); 187 **goto out**; 188 }

. . .

205 ret = **\_\_swap_writepage**(page, wbc, end_swap_bio_write); 206 **out**:

207 **return** ret;

208 }

 

*Listing 12-27:* mm/page_io.c: [*swap_writepage()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_io.c?h=v6.0#n181)

 

The [swap_writepage()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_io.c?h=v6.0#n181) function starts by trying to free swap cache if there

are no swapped out references to this folio as checked by [try_to_free_swap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n1590)

(which we examine in Listing 12-31 and Section 12.2.4). If so we exit without

having to kick off a write. Otherwise, we invoke [\_\_swap_writepage()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_io.c?h=v6.0#n335), which we

examine in Listing 12-28.

Note that we pass [\_\_swap_writepage()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_io.c?h=v6.0#n335) a pointer to [end_swap_bio_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_io.c?h=v6.0#n31) to

be called when the asynchronous write is complete, and handle errors.

We examine [\_\_swap_writepage()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_io.c?h=v6.0#n335) in Listing 12-28, eliding out of scope de-

bug checks and an irrelevant comment.

 

335 **int \_\_swap_writepage**(**struct** page \*page, **struct** writeback_control \*wbc, 336 **bio_end_io_t** end_write_func) 337 {

338 **struct** bio \*bio;

339 **int** ret;

340 **struct** swap_info_struct \*sis = **page_swap_info**(page);

. . .

348 **if** (**data_race**(sis-\>flags & **SWP_FS_OPS**)) 349 **return swap_writepage_fs**(page, wbc);

350

351 ret = **bdev_write_page**(sis-\>bdev, **swap_page_sector**(page), page, wbc); 352 **if** (!ret) {

353 **count_swpout_vm_event**(page); 354 **return** 0; 355 }

356

357 bio = **bio_alloc**(sis-\>bdev, 1, 358 **REQ_OP_WRITE** \| **REQ_SWAP** \| **wbc_to_write_flags**(wbc), 359 **GFP_NOIO**); 360 bio-\>bi_iter.bi_sector = **swap_page_sector**(page);

 



 

361 bio-\>bi_end_io = end_write_func; 362 **bio_add_page**(bio, page, **thp_size**(page), 0); 363

364 **bio_associate_blkg_from_page**(bio, page); 365 **count_swpout_vm_event**(page); 366 **set_page_writeback**(page); 367 **unlock_page**(page); 368 **submit_bio**(bio);

369

370 **return** 0;

371 }

 

*Listing 12-28:* mm/page_io.c: [*\_\_swap_writepage()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_io.c?h=v6.0#n335)

 

The logic in [\_\_swap_writepage()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_io.c?h=v6.0#n335) makes reference to the swap file imple-

mentation, which we do not dive into in detail as this strays too far into file system territory, however we shall examine it from a broad top level.

We retrieve metadata about the swap entry, and determine whether

we ought to invoke the containing file system to perform the writeback, in

which case we invoke [swap_writepage_fs()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_io.c?h=v6.0#n294). We don’t examine this function in detail as it again pertains very much to file system logic.

If not, then we allocate a [struct bio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/blk_types.h?h=v6.0#n252) object (see Section 9.10.5 in Chap-

ter 9 for more details on this) to describe the I/O operation that is to be

performed asynchronously, before setting the [PG_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n116) flag on the

[struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) to indicate writeback is underway and unlocking the page before

submitting the block I/O operation via [submit_bio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/blk-core.c?h=v6.0#n820).

The [end_swap_bio_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_io.c?h=v6.0#n31) function called when asynchronous I/O com-

pletes invokes [end_page_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n24) which calls [folio_end_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1599) in turn

(see Listing **??** in Chapter 10), which importantly terminates writeback and

calls [folio_rotate_reclaimable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n283) which puts it next in line for reclaim — ensur-

ing the logic contained in Section 12.2.4 immediately upon writeback.

 

***12.2.4 Freeing a Swapped Out Folio***

Finally, after writeback has been kicked off on swap out and completes,

[folio_rotate_reclaimable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n283) is called which causes the folio to be subject

to immediate reclaim, at which point we can observe in Figure 12-1 that

[shrink_page_list(](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589)) invokes [\_\_remove_mapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1289) to attempt to clear the mapping

from the swap cache, and [free_unref_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3510) to free the folio itself.

We don’t examine the logic surrounding [free_unref_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3510) as this is

a general physical folio freeing mechanism and one we cover in Section 2.9

and Chapter 2.

However, we do wish to examine in detail the logic surrounding removal

of a folio from the swap cache.

We therefore examine core and swap-specific logic in [\_\_remove_mapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1289)

in Listing 12-29 (eliding out of scope working set, cgroup and non-swap spe-cific logic).

 

1285 */\**

 



 

1286 *\* Same as remove_mapping, but if the page is removed from the mapping, it*

1287 *\* gets returned with a refcount of 0.* 1288 *\*/*

1289 **static int \_\_remove_mapping**(**struct** address_space \*mapping, **struct** folio \*folio

,

1290 **bool** reclaimed, **struct** mem_cgroup \*target_memcg) 1291 {

1292 **int** refcount;

. . .

1300 **xa_lock_irq**(&mapping-\>i_pages); 1301 */\**

1302 *\* The non racy check for a busy page.* 1303 *\**

1304 *\* Must be careful with the order of the tests. When someone has* 1305 *\* a ref to the page, it may be possible that they dirty it then* 1306 *\* drop the reference. So if PageDirty is tested before page_count*

1307 *\* here, then the following race may occur:* 1308 *\**

1309 *\* get_user_pages(&page);* 1310 *\* \[user mapping goes away\]* 1311 *\* write_to(page);* 1312 *\** *!PageDirty(page)* *\[good\]* 1313 *\* SetPageDirty(page);* 1314 *\* put_page(page);* 1315 *\** *!page_count(page)* *\[good, discard it\]* 1316 *\**

1317 *\* \[oops, our write_to data is lost\]* 1318 *\**

1319 *\* Reversing the order of the tests ensures such a situation cannot*

1320 *\* escape unnoticed. The smp_rmb is needed to ensure the page-\>flags*

1321 *\* load is not satisfied before that of page-\>\_refcount.* 1322 *\**

1323 *\* Note that if SetPageDirty is always performed via set_page_dirty,*

1324 *\* and thus under the i_pages lock, then this ordering is not required*

*.*

1325 *\*/*

1326 refcount = 1 + **folio_nr_pages**(folio); 1327 **if** (!**folio_ref_freeze**(folio, refcount)) 1328 **goto cannot_free**; 1329 */\* note: atomic_cmpxchg in page_ref_freeze provides the smp_rmb \*/*

1330 **if** (**unlikely**(**folio_test_dirty**(folio))) { 1331 **folio_ref_unfreeze**(folio, refcount); 1332 **goto cannot_free**; 1333 }

1334

1335 **if** (**folio_test_swapcache**(folio)) { 1336 **swp_entry_t** swap = **folio_swap_entry**(folio);

 



 

. . .

1340 **\_\_delete_from_swap_cache**(folio, swap, shadow); 1341 **xa_unlock_irq**(&mapping-\>i_pages); 1342 **put_swap_page**(&folio-\>page, swap); 1343 } **else** {

. . .

1374 }

1375

1376 **return** 1;

1377

1378 **cannot_free**:

1379 **xa_unlock_irq**(&mapping-\>i_pages); 1380 **if** (!**folio_test_swapcache**(folio)) 1381 **spin_unlock**(&mapping-\>host-\>i_lock); 1382 **return** 0;

1383 }

 

*Listing 12-29:* mm/vmscan.c: [*\_\_remove_mapping()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1289) *Swap Logic*

 

The [\_\_remove_mapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1289) function starts by freezing the reference count

of the folio via [folio_ref_freeze()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page_ref.h?h=v6.0#n325), which cannot be elevated by either being mapped in userland or in-use by the kernel, or the freezing fails.

We have already determined by this point that the folio is not dirty or

currently in a state of writeback, and thus will have been swapped out to disk.

 

**N O T E** We explore folio freezing further in Chapter 11 on reclaim, however broadly it atom-

ically compares and exchanges an expecting reference count with zero, ensuring that we do not race with anything that might pin the folio in place. Unfreezing reverses this operation.

 

We explicitly check whether the folio is dirty (and thus not in a state

where it can be freed) and unfreeze via [folio_ref_unfreeze()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page_ref.h?h=v6.0#n340) and abort if so.

Note the comment describing the careful ordering of updating the refer-

ence count and checking for the dirty flag.

In the case of a swap cache entry we delete the folio from the swapper

[struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) via [\_\_delete_from_swap_cache()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n139)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n139) and clear its [PG_swapcache](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n158)

flag, which we examine in Listing 12-30 (eliding out of scope debug checks),

before invoking [put_swap_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n1331) to decrement the reference on the swap en-try.

 

135 */\**

136 *\* This must be called only on folios that have* 137 *\* been verified to be in the swap cache.* 138 *\*/*

139 **void \_\_delete_from_swap_cache**(**struct** folio \*folio, 140 swp_entry_t entry, **void** \*shadow) 141 {

142 **struct** address_space \*address_space = **swap_address_space**(entry);

 



 

143 **int** i;

144 **long** nr = **folio_nr_pages**(folio); 145 **pgoff_t** idx = **swp_offset**(entry); 146 **XA_STATE**(xas, &address_space-\>i_pages, idx);

. . .

152 **for** (i = 0; i \< nr; i++) { 153 **void** \*entry = **xas_store**(&xas, shadow);

. . .

155 **set_page_private**(**folio_page**(folio, i), 0); 156 **xas_next**(&xas); 157 }

158 **folio_clear_swapcache**(folio); 159 address_space-\>nrpages -= nr; 160 **\_\_node_stat_mod_folio**(folio, **NR_FILE_PAGES**, -nr); 161 **\_\_lruvec_stat_mod_folio**(folio, **NR_SWAPCACHE**, -nr); 162 }

 

*Listing 12-30:* mm/swap_state.c: [*\_\_delete_from_swap_cache()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n139)

 

The [\_\_delete_from_swap_cache()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n139) looks up the appropriate swapper

[struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) via [swap_address_space()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.h?h=v6.0#n30) (see Listing 12-4) and its index

from [swp_offset()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swapops.h?h=v6.0#n62) (see Listing 12-6), before performing an xarray traversal,

setting the entry to the shadow value.

The shadow value is in reference to workout set tracing logic which is out

of scope for the book, so for the sake of argument we can consider this to be

NULL (which very often it will be at any rate).

The [struct page-\>private](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) field is cleared for every subpage so it no longer

references this swap entry and the [PG_swapcache](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n158) flag flag is cleared for the

folio, before updating statistics accordingly.

Note that this does not free the folio, the [shrink_page_list(](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1589) logic

does this separately by batching up folios to delete and passing them to

[free_unref_page_list().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3510)

Another means by which swap entries can potentially removed from the

swap cache is [try_to_free_swap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n1590), which we examine in Listing 12-31 9eliding

debug checks and power management logic.

 

1586 */\**

1587 *\* If swap is getting full, or if there are no more mappings of this page,*

1588 *\* then try_to_free_swap is called to free its swap space.* 1589 *\*/*

1590 **int try_to_free_swap**(**struct** page \*page) 1591 {

1592 **struct** folio \*folio = **page_folio**(page);

. . .

1595 **if** (!**folio_test_swapcache**(folio)) 1596 **return** 0; 1597 **if** (**folio_test_writeback**(folio)) 1598 **return** 0; 1599 **if** (**folio_swapped**(folio))

 



 

1600 **return** 0;

. . .

1620 **delete_from_swap_cache**(folio); 1621 **folio_set_dirty**(folio); 1622 **return** 1;

1623 }

 

*Listing 12-31:* mm/swapfile.c: [*try_to_free_swap()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n1590)

The [try_to_free_swap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n1590) function performs a series of sanity checks to en-

sure that the operation is proceeding on a folio that is in the swap cache, not in the process of being written out and has at least one reference to

the swapped out folio (as checked by [folio_swapped()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n1571)), before invoking

[delete_from_swap_cache()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n231) which we examine in Listing 12-32.

 

225 */\**

226 *\* This must be called only on folios that have* 227 *\* been verified to be in the swap cache and locked.* 228 *\* It will never put the folio into the free list,* 229 *\* the caller has a reference on the folio.* 230 *\*/*

231 **void delete_from_swap_cache**(**struct** folio \*folio) 232 {

233 **swp_entry_t** entry = **folio_swap_entry**(folio); 234 **struct** address_space \*address_space = **swap_address_space**(entry); 235

236 **xa_lock_irq**(&address_space-\>i_pages); 237 **\_\_delete_from_swap_cache**(folio, entry, **NULL**); 238 **xa_unlock_irq**(&address_space-\>i_pages); 239

240 **put_swap_page**(&folio-\>page, entry); 241 **folio_ref_sub**(folio, **folio_nr_pages**(folio)); 242 }

 

*Listing 12-32:* mm/swap_state.c: [*delete_from_swap_cache()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n231)

The [delete_from_swap_cache()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n231) function obtains the [swp_entry_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n820) associated

with the [struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) via [folio_swap_entry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n348) (see Listing 12-9), before obtain-

ing the swapper [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) via [swap_address_space()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.h?h=v6.0#n30) (see Listing 12-

4).

A lock is acquired over the [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)-\>i_pages xarray, before

invoking [\_\_delete_from_swap_cache()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n139) (see Listing 12-30) to perform the actual

removal from the swap cache, before invoking [put_swap_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n1331) to decrement the reference on the swap entry and decrementing the folio’s reference

count via [folio_ref_sub()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page_ref.h?h=v6.0#n137)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page_ref.h?h=v6.0#n137)

 

**12.3 Swapping In**

 

We have examined swapping out, and observed in Section 12.2.2 that we replace the PTE page table entry for the swapped-out mapping with an

 



 

architecture-specific encoding of the [swp_entry_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n820) describing in which swap

file and offset within it the faulted page is located, along with a number of

swap flags.

As a result, there is a very clear point at which swap in occurs—when a

page fault occurs on a swapped out page. And from the PTE we are able to

ascertain both where in the swap file the page might be swapped out to or

where in the swap cache the page is located.

 

**N O T E** The reason for a swap cache is precisely because page faults might occur at any time,

and writing back to disk takes time to complete, so we must both indicate to the fault-

ing mechanism that the swapped out page should be looked up in the swap while also

storing the folio in the swap cache in the meantime.

 

***12.3.1 Page Fault on a Swapped Out Page***

We examine the page fault mechanism in great detail in Chapter 6, however

we note that the point at which we determine the nature of the fault occurs

in [handle_pte_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4860) which determines that the fault is caused by memory

being swapped out when the PTE is non-empty, but is marked non-present

(see Chapter 3 on Virtual Memory for details on the various page table flags

including the present flag).

This then invokes [do_swap_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3718) to handle the fault, which we examine

starting in Listing 12-33 (eliding out of scope non-swap entry logic, cgroup

logic, working set logic, hardware page poisoning logic, Kernel Same page

Merging (KSM) logic, bug checks, userfaultfd handling,a nd architecture-

specific cache flushing logic).

 

3710 */\**

3711 *\* We enter with non-exclusive mmap_lock (to exclude vma changes,* 3712 *\* but allow concurrent faults), and pte mapped but not yet locked.* 3713 *\* We return with pte unmapped and unlocked.* 3714 *\**

3715 *\* We return with the mmap_lock locked or unlocked in the same cases* 3716 *\* as does filemap_fault().* 3717 *\*/*

3718 **vm_fault_t do_swap_page**(**struct** vm_fault \*vmf) 3719 {

3720 **struct** vm_area_struct \*vma = vmf-\>vma; 3721 **struct** page \*page = **NULL**, \*swapcache; 3722 **struct** swap_info_struct \*si = **NULL**; 3723 rmap_t rmap_flags = **RMAP_NONE**; 3724 **bool** exclusive = **false**; 3725 **swp_entry_t** entry; 3726 **pte_t** pte;

3727 **int** locked;

3728 **vm_fault_t** ret = 0;

. . .

3734 entry = **pte_to_swp_entry**(vmf-\>orig_pte);

 



 

. . .

3758 */\* Prevent swapoff from happening to us. \*/* 3759 si = **get_swap_device**(entry); 3760 **if** (**unlikely**(!si)) 3761 **goto out**; 3762

3763 page = **lookup_swap_cache**(entry, vma, vmf-\>address); 3764 swapcache = page;

 

*Listing 12-33:* mm/memory.c: [*do_swap_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3718) *Preface*

 

We start [do_swap_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3718) by initialising local variables and obtaining the

[swp_entry_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n820) from the PTE using [pte_to_swp_entry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swapops.h?h=v6.0#n77) (see Listing 12-14 and Sec-

tion 12.1.3 for details).

We then obtain metadata regarding the swap via [get_swap_device()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n1247)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n1247) incre-

menting a reference count on the swap file to ensure that a [swapoff()](https://man7.org/linux/man-pages/man2/swapoff.2.html) cannot be performed beneath us.

 

**N O T E** We do not delve too deeply into [*mm/swapfile.c*](https://elixir.bootlin.com/linux/v6.0/source/mm/swapfile.c) implementation details as these

rapidly become the remit of file system logic rather than memory management.

 

We then check the swap cache to see whether the page is still located in

the swap cache via [lookup_swap_cache()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n325)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n325) which we examine in detail in Listing

12-39 and Section 12.3.2.

If we can locate the page in the swap cache then we do not need to read

from the disk and can simply proceed with mapping the page directly from

the swap cache, after considering edge cases as shown in Listing 12-35.

Otherwise, we must read from disk, the logic for which we examine in

Listing 12-34.

 

3766 **if** (!page) {

3767 **if** (**data_race**(si-\>flags & **SWP_SYNCHRONOUS_IO**) && 3768 **\_\_swap_count**(entry) == 1) { 3769 */\* skip swapcache \*/* 3770 page = **alloc_page_vma**(**GFP_HIGHUSER_MOVABLE**, vma, 3771 vmf-\>address); 3772 **if** (page) { 3773 **\_\_SetPageLocked**(page); 3774 **\_\_SetPageSwapBacked**(page);

. . .

3788 **lru_cache_add**(page); 3789

3790 */\* To provide entry to swap_readpage() \*/*

3791 **set_page_private**(page, entry.val); 3792 **swap_readpage**(page, **true**, **NULL**); 3793 **set_page_private**(page, 0); 3794 } 3795 } **else** {

3796 page = **swapin_readahead**(entry, **GFP_HIGHUSER_MOVABLE**,

 



 

3797 vmf); 3798 swapcache = page; 3799 }

3800

3801 **if** (!page) { 3802 */\** 3803 *\* Back out if somebody else faulted in this pte* 3804 *\* while we released the pte lock.* 3805 *\*/* 3806 vmf-\>pte = **pte_offset_map_lock**(vma-\>vm_mm, vmf-\>pmd, 3807 vmf-\>address, &vmf-\>ptl); 3808 **if** (**likely**(**pte_same**(\*vmf-\>pte, vmf-\>orig_pte))) 3809 ret = **VM_FAULT_OOM**; 3810 **goto unlock**; 3811 }

3812

3813 */\* Had to read the page from swap area: Major fault \*/* 3814 ret = **VM_FAULT_MAJOR**; 3815 **count_vm_event**(**PGMAJFAULT**);

. . .

3824 }

3825

3826 locked = **lock_page_or_retry**(page, vma-\>vm_mm, vmf-\>flags); 3827

3828 **if** (!locked) {

3829 ret \|= **VM_FAULT_RETRY**; 3830 **goto out_release**; 3831 }

 

*Listing 12-34:* mm/memory.c: [*do_swap_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3718) *Reading From Disk*

 

If the swap device indicates that it is more efficient to perform syn-

chronous I/O as indicated by the [SWP_SYNCHRONOUS_IO](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n209) flag being specified in

the swap device’s metadata, and we are the only ones referencing this swap

entry, then we take a direct path, bypass the swap cache altogether read the

page from the swap directly.

We do so by allocating a user page via [alloc_page_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n287)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n287) setting locked

and swap-backed flags adding it to the appropriate LRU (see Section 11.2

in Chapter 11 for more on LRU lists) via [lru_cache_add()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n85) (which ultimately

invokes [folio_add_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n479)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n479) see Listing 11-88 also in Chapter 11).

We then invoke [swap_readpage()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_io.c?h=v6.0#n448) specifying that the read should be per-

formed synchronously, having set the [struct page-\>private](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) to the [swp_entry_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n820)

value describing this swap entry prior to doing so via [set_page_private()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n335) be-

fore clearing it afterwards.

We examine [swap_readpage()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_io.c?h=v6.0#n448) in Listing 12-40 in Section 12.3.3. in the usual case, we do not perform synchronous readahead, but rather

perform “swap readahead”, similar to page cache readahead, i.e. reading

 



 

additional pages beyond that requested in anticipation of the user needing them in the near future.

This is performed via [swapin_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n847) which we examine in Listing 12-

41 and Section 12.3.3.

In this instance we assign swapcache to the retrieved page in order to

record the fact that the [swapin_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n847) function call will have placed this page in the swap cache.

We then consider the situation in which either we had insufficient mem-

ory in order to allocate the page, or a race occurred in [swapin_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n847)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n847)

We determine which of the cases have occurred by locking the PTE and

checking to see whether the PTE matches what we faulted on—if not we have been raced with, otherwise we have run out of memory and indicate as

much by update the return value to indicate so with [VM_FAULT_OOM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n742) (see Chap-

ter 6 for details on the page fault mechanism as a whole).

In both cases in which we were not able to obtain a page, we abort the

fault and exit.

Finally, if the page was successfully retrieved, we count this as a major

fault, i.e. one which resulted in I/O.

 

**N O T E** In the instance that asynchronous I/O has been started in order to retrieve data from

the swap, the [*struct page*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) we retrieve will be locked and not [*PG_uptodate*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n103)—that is, allo-cated but not yet read from the swap.

 

The last few lines in Listing 12-35 are of critical importance—we try to ac-

quire a lock on the page we have just obtained via [lock_page_or_retry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n998), which checks to determine whether we can simply try retry the fault and drop the

[struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) to avoid unnecessary contention on it (see Sec-

tion 6.2 and Chapter 6 for more details).

In the instance where we can simply try again later, [lock_page_or_retry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n998)

will return false, otherwise it will wait until the lock is available (see Section

9.11 for details on how this mechanism functions).

Why is waiting for the lock here so critical? In the instance of asyn-

chronous I/O being performed (the far more likely case), the page will be locked, and only unlocked when the data is read into memory (at which

point the [PG_uptodate](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n103) flag will be set on the folio).

See Section 9.6 in Chapter 9 for more details on how data is read from

disk into folios.

Therefore this lock acts as a barrier—prior to it, it is likely that the page

does not contain swapped out data, afterwards either it does, a retry is indi-cated or an error arose.

In the case of a retry being required, we abort setting [VM_FAULT_RETRY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n751)

in the return value to indicate to the page fault mechanism that the fault

should be retried (again see Chapter 6 for more details on the page fault mechanism).

With the swapped out read from disk, we consider edge cases as shown

in Listing 12-35.

 

3833 **if** (swapcache) {

 



 

3834 */\**

3835 *\* Make sure try_to_free_swap or swapoff did not release the*

3836 *\* swapcache from under us. The page pin, and pte_same test*

3837 *\* below, are not enough to exclude that. Even if it is still*

3838 *\* swapcache, we need to check that the page's swap has not*

3839 *\* changed.* 3840 *\*/*

3841 **if** (**unlikely**(!**PageSwapCache**(page) \|\| 3842 **page_private**(page) != entry.val)) 3843 **goto out_page**;

. . .

3858 */\**

3859 *\* If we want to map a page that's in the swapcache writable,*

*we*

3860 *\* have to detect via the refcount if we're really the*

*exclusive*

3861 *\* owner. Try removing the extra reference from the local LRU*

3862 *\* pagevecs if required.* 3863 *\*/*

3864 **if** ((vmf-\>flags & **FAULT_FLAG_WRITE**) && page == swapcache && 3865 !**PageKsm**(page) && !**PageLRU**(page)) 3866 **lru_add_drain**(); 3867 }

. . .

3871 */\**

3872 *\* Back out if somebody else already faulted in this pte.* 3873 *\*/*

3874 vmf-\>pte = **pte_offset_map_lock**(vma-\>vm_mm, vmf-\>pmd, vmf-\>address, 3875 &vmf-\>ptl); 3876 **if** (**unlikely**(!**pte_same**(\*vmf-\>pte, vmf-\>orig_pte))) 3877 **goto out_nomap**; 3878

3879 **if** (**unlikely**(!**PageUptodate**(page))) { 3880 ret = **VM_FAULT_SIGBUS**; 3881 **goto out_nomap**; 3882 }

. . .

3895 */\**

3896 *\* Check under PT lock (to protect against concurrent fork() sharing*

3897 *\* the swap entry concurrently) for certainly exclusive pages.* 3898 *\*/*

3899 **if** (!**PageKsm**(page)) {

. . .

3904 exclusive = **pte_swp_exclusive**(vmf-\>orig_pte); 3905 **if** (page != swapcache) { 3906 */\** 3907 *\* We have a fresh page that is not exposed to the*

 



 

3908 *\* swapcache -\> certainly exclusive.* 3909 *\*/* 3910 exclusive = **true**; 3911 } **else if** (exclusive && **PageWriteback**(page) && 3912 **data_race**(si-\>flags & **SWP_STABLE_WRITES**)) { 3913 */\** 3914 *\* This is tricky: not all swap backends support* 3915 *\* concurrent page modifications while under writeback*

*.*

3916 *\** 3917 *\* So if we stumble over such a page in the swapcache*

3918 *\* we must not set the page exclusive, otherwise we*

*can*

3919 *\* map it writable without further checks and modify*

*it*

3920 *\* while still under writeback.* 3921 *\** 3922 *\* For these problematic swap backends, simply drop*

*the*

3923 *\* exclusive marker: this is perfectly fine as we*

*start*

3924 *\* writeback only if we fully unmapped the page and*

3925 *\* there are no unexpected references on the page*

*after*

3926 *\* unmapping succeeded. After fully unmapped, no* 3927 *\* further GUP references (FOLL_GET and FOLL_PIN) can*

3928 *\* appear, so dropping the exclusive marker and*

*mapping*

3929 *\* it only R/O is fine.* 3930 *\*/* 3931 exclusive = **false**; 3932 }

3933 }

 

*Listing 12-35:* mm/memory.c: [*do_swap_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3718) *Edge Case Handling*

 

Now we have a lock on the page, we first consider cases where the swap

cache has been set, checking to ensure that page has not been freed from the swap cache under us, or if it is still a swap cache page that it refers to the same swap entry that we faulted on, aborting if either of these are not the case.

We then carefully ensure that we do not have an elevated reference

count on the folio, as in the instance of a write fault we explicitly need to know whether we exclusively map the entry.

If something is in a folio batch (previously known as lruvec) pending

flush to the appropriate LRU, we flush it to the appropriate LRU list (see

Sections 11.7.12 on folio batch drain and 11.2 in Chapter 11 for more on this mechanism)—the upshot of this is that drop the reference count as a re-

 



 

sult in order to ensure we avoid false negatives when determining whether a

folio is exclusively referenced later.

Next, we acquire a lock on the PTE, stabilising it and then immediately

check to ensure it has not changed from beneath us due to a race. If it has,

we abort. Also, if at this point the page is not marked [PG_uptodate](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n103)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n103) we must

have encountered an error when reading swap data from the disk, and thus

abort, indicating that a terminal SIGBUS signal should be sent to the faulting

process.

Finally, we carefully determine whether the page is indeed mapped ex-

clusively. We encode this in a swap flag based on whether the swapped out

page, which we retrieve via [pte_swp_exclusive()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1291).

If the swap cache does not match the page we are adding a mapping for,

then we know this is a newly allocated page and thus must by definition be

exclusively mapped.

Otherwise, we consider the case where [pte_swp_exclusive()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1291) indicates

the page is indeed mapped exclusively, but is also in the process of write-

back in a scenario where stable writes are required, as indicated by the

[SWP_STABLE_WRITES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n208) flag.

In this case, we must avoid indicating that the page is mapped exclusive,

even if it is otherwise indicated, otherwise we will simply make the mapping

writable and the swap backend, which cannot handle having the swap modi-

fied when writing back to disk, might encounter this scenario. We avoid it by

simply not considering the folio mapped exclusive under these conditions.

After handling these edge cases, we move on to mapping the swapped in

page and freeing up the swap and swap cache as appropriate. We examine

this in Listing 12-36.

 

3935 */\**

3936 *\* Remove the swap entry and conditionally try to free up the*

*swapcache.*

3937 *\* We're already holding a reference on the page but haven't mapped it*

3938 *\* yet.*

3939 *\*/*

3940 **swap_free**(entry); 3941 **if** (**should_try_to_free_swap**(page, vma, vmf-\>flags)) 3942 **try_to_free_swap**(page); 3943

3944 **inc_mm_counter_fast**(vma-\>vm_mm, **MM_ANONPAGES**); 3945 **dec_mm_counter_fast**(vma-\>vm_mm, **MM_SWAPENTS**); 3946 pte = **mk_pte**(page, vma-\>vm_page_prot); 3947

3948 */\**

3949 *\* Same logic as in do_wp_page(); however, optimize for pages that are*

3950 *\* certainly not shared either because we just allocated them without*

3951 *\* exposing them to the swapcache or because the swap entry indicates*

3952 *\* exclusivity.*

3953 *\*/*

3954 **if** (!**PageKsm**(page) && (exclusive \|\| **page_count**(page) == 1)) {

 



 

3955 **if** (vmf-\>flags & **FAULT_FLAG_WRITE**) { 3956 pte = **maybe_mkwrite**(**pte_mkdirty**(pte), vma); 3957 vmf-\>flags &= ~**FAULT_FLAG_WRITE**; 3958 ret \|= **VM_FAULT_WRITE**; 3959 }

3960 rmap_flags \|= **RMAP_EXCLUSIVE**; 3961 }

. . .

3963 **if** (**pte_swp_soft_dirty**(vmf-\>orig_pte)) 3964 pte = **pte_mksoft_dirty**(pte);

. . .

3969 vmf-\>orig_pte = pte;

. . .

3976 **page_add_anon_rmap**(page, vma, vmf-\>address, rmap_flags);

. . .

3980 **set_pte_at**(vma-\>vm_mm, vmf-\>address, vmf-\>pte, pte);

. . .

3983 **unlock_page**(page); 3984 **if** (page != swapcache && swapcache) { 3985 */\**

3986 *\* Hold the lock to avoid the swap entry to be reused* 3987 *\* until we take the PT lock for the pte_same() check* 3988 *\* (to avoid false positives from pte_same). For* 3989 *\* further safety release the lock after the swap_free* 3990 *\* so that the swap count won't change under a* 3991 *\* parallel locked swapcache.* 3992 *\*/*

3993 **unlock_page**(swapcache); 3994 **put_page**(swapcache); 3995 }

3996

3997 **if** (vmf-\>flags & **FAULT_FLAG_WRITE**) { 3998 ret \|= **do_wp_page**(vmf); 3999 **if** (ret & **VM_FAULT_ERROR**) 4000 ret &= **VM_FAULT_ERROR**; 4001 **goto out**; 4002 }

 

*Listing 12-36:* mm/memory.c: [*do_swap_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3718) *Mapping Page and Freeing Swap*

 

We start by freeing the swap entry associated with the underlying swap

file via [swap_free()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n1319) (we don’t examine this in detail as with the rest of the un-derlying swap file logic due to leaning rather towards file system code), and

then attempt to free the swap cache if it makes sense to via [try_to_free_swap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n1590)

(see Listing 12-31 in Section 12.2.4).

We determine whether we should via [should_try_to_free_swap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3638) which we

examine in Listing 12-37.

 

3638 **static inline bool should_try_to_free_swap**(**struct** page \*page,

 



 

3639 **struct** vm_area_struct \*vma, 3640 **unsigned int** fault_flags) 3641 {

3642 **if** (!**PageSwapCache**(page)) 3643 **return false**; 3644 **if** (**mem_cgroup_swap_full**(page) \|\| (vma-\>vm_flags & **VM_LOCKED**) \|\| 3645 **PageMlocked**(page)) 3646 **return true**; 3647 */\**

3648 *\* If we want to map a page that's in the swapcache writable, we* 3649 *\* have to detect via the refcount if we're really the exclusive* 3650 *\* user. Try freeing the swapcache to get rid of the swapcache* 3651 *\* reference only in case it's likely that we'll be the exlusive user.*

3652 *\*/*

3653 **return** (fault_flags & **FAULT_FLAG_WRITE**) && !**PageKsm**(page) && 3654 **page_count**(page) == 2; 3655 }

 

*Listing 12-37:* mm/memory.c: [*should_try_to_free_swap()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3638)

 

We start [should_try_to_free_swap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3638) by checking whether the page is

marked swap cache—of course, if it is not, we cannot free it from the swap

cache and so indicate false.

Then, if the page has been marked by [mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html) to be kept resident in mem-

ory, it simply cannot be swapped out, so maintaining it in the swap cache

makes absolutely no sense and so in this instance we indicate that it should

be freed.

Finally, we consider the case of a write fault in which the swap cache is

the only other entity holding a reference on this page, if so then it makes

sense to free the swap cache entry to drop this in order that the page has an

exclusive mapping.

 

**N O T E** We are so careful about exclusive mapping in the instance of a write fault, as we

later invoke [*do_wp_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3360) if the mapping is not exclusive, which might result in the

page being copied if this is not so.

 

Returning to the portion of [do_swap_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3718) explored in Listing 12-36, af-

ter we potentially free the swap cache entry, we update statistics accordingly

to account for the swap in and establish a new PTE entry that points to the

read in page.

Next, all of the hard work to ensure we accurately determine whether

we are exclusively mapped pays off, as check whether we have determined

explicitly that this is an exclusive mapping (via the exclusive boolean vari-

able) or if the reference count of the folio is equal to one, as checked by

[page_count()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page_ref.h?h=v6.0#n92).

If this is the case, and this is a write fault, we simply make the PTE write-

only via [maybe_mkwrite()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n977) (the “maybe” here refers to the fact that we double

check that the containing [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) has the [VM_WRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n267) flag

set, indicating that it can be written to), clear the [FAULT_FLAG_WRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n864) fault flag

 



 

and set [VM_FAULT_WRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n745) in the return value to simply cause the mapping to be made writable.

We also set the [RMAP_EXCLUSIVE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n181) flag when adding the folio to the reverse

mapping later to indicate to this logic that this is an exclusive mapping.

Next, we reinstate any [soft-dirty](https://kernel.org/doc/html/v6.0/admin-guide/mm/soft-dirty.html) flag that was previously set on the map-

ping as indicated by the swap flag that stored this.

We add this page to the reverse mapping via [page_add_anon_rmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1200) (see

Listing 7-21 in Section 7.0.12 and Chapter 7 for a detailed treatment of this

functionality), before finally setting the PTE via [set_pte_at()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1004) (see Chapter 3 for more on page tables).

With the page read from the cache, added to the reverse mapping and

the PTE set up, we can now unlock the page. We also check to see if we hold a reference to a now redundant swapcache page, which we free if we do so.

Finally, if the [FAULT_FLAG_WRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n864) flag is set on the fault, i.e. this was a write

fault but non-exclusive, then we must handle this as a Copy-on-Write page

fault, as handled by [do_wp_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3360) (see Listing 6-36 in Section 6.9 and Chapter

6 for a detailed exploration of this).

With the swap page now read in from disk or the swap cache, and the

PTE pointing to it installed in place, we have only to examine cleanup and

error cases, which we explore in Listing 12-38.

 

3935 **unlock**:

3936 **pte_unmap_unlock**(vmf-\>pte, vmf-\>ptl); 3937 **out**:

3938 **if** (si)

3939 **put_swap_device**(si); 3940 **return** ret;

3941 **out_nomap**:

3942 **pte_unmap_unlock**(vmf-\>pte, vmf-\>ptl); 3943 **out_page**:

3944 **unlock_page**(page); 3945 **out_release**:

3946 **put_page**(page);

3947 **if** (page != swapcache && swapcache) { 3948 **unlock_page**(swapcache); 3949 **put_page**(swapcache); 3950 }

3951 **if** (si)

3952 **put_swap_device**(si); 3953 **return** ret;

3954 }

 

*Listing 12-38:* mm/memory.c: [*do_swap_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3718) *Suffix*

 

If the swap in operation works correctly, or we exited early, we revoke

the PTE lock, drop any reference to the swap device and return the fault handling value that we have calculated throughout the operation.

In the case of an error arising where the mapping has failed, we release

the PTE lock, unlock the page if necessary and drop a reference to the page

 



 

if necessary, before doing the same for the swap cache page if it differs and

dropping the reference to the swap device if necessary, before returning the

specified fault handling return value.

This simply mirrors cleanup on the successful path through the function,

accounting for the fact that the error paths will not have had a chance to do

this themselves yet.

This concludes the analysis of the swap fault mechanism, which is the

means by which memory is swapped back in after being swapped out, or

simply retrieved from the swap cache if not yet successfully swapped out.

 

**N O T E** In the case of a page being retrieved from the swap cache before the write out to disk

is complete, we will have marked the swap entry clear and available for reuse by any-

thing else swapping out via [*swap_free()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n1319), meaning that we do not occupy swap space

unnecessarily.

 

***12.3.2 Looking Up a Folio in the Swap Cache***

In [do_swap_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3718), we attempt to look up the page in the swap cache via

[lookup_swap_cache(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n325)which we examine in Listing 12-39 (eliding out of scope

huge page logic).

 

319

320 */\**

321 *\* Lookup a swap entry in the swap cache. A found page will be returned* 322 *\* unlocked and with its refcount incremented - we rely on the kernel* 323 *\* lock getting page table operations atomic even if we drop the page* 324 *\* lock before returning.* 325 *\*/*

326 **struct** page \***lookup_swap_cache**(swp_entry_t entry, **struct** vm_area_struct \*vma, 327 **unsigned long** addr) 328 {

329 **struct** page \*page; 330 **struct** swap_info_struct \*si;

331

332 si = **get_swap_device**(entry); 333 **if** (!si)

334 **return NULL**; 335 page = **find_get_page**(**swap_address_space**(entry), **swp_offset**(entry)); 336 **put_swap_device**(si);

337

338 **if** (page) {

339 **bool** vma_ra = **swap_use_vma_readahead**(); 340 **bool** readahead;

. . .

349 readahead = **TestClearPageReadahead**(page); 350 **if** (vma && vma_ra) { 351 **unsigned long** ra_val; 352 **int** win, hits;

 



 

353

354 ra_val = **GET_SWAP_RA_VAL**(vma); 355 win = **SWAP_RA_WIN**(ra_val); 356 hits = **SWAP_RA_HITS**(ra_val); 357 **if** (readahead) 358 hits = **min_t**(**int**, hits + 1, **SWAP_RA_HITS_MAX**); 359 **atomic_long_set**(&vma-\>swap_readahead_info, 360 **SWAP_RA_VAL**(addr, win, hits)); 361 }

362

363 **if** (readahead) { 364 **count_vm_event**(**SWAP_RA_HIT**); 365 **if** (!vma \|\| !vma_ra) 366 **atomic_inc**(&**swapin_readahead_hits**); 367 }

368 }

369

370 **return** page;

371 }

 

*Listing 12-39:* mm/swap_state.c: [*lookup_swap_cache()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n325)

 

We start by first pinning the swap device via [get_swap_device()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n1247)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n1247) and if this

yields NULL indicating we were unable to, we also return NULL indicating we could not find a swap cache entry.

Next we leverage the fact we are using a [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) object for

the swapper by utilising the page cache’s [find_get_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n560) function, which ul-

timately invokes [\_\_filemap_get_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1914) (see Listing 9-49 in Section 9.5.3 and

## Chapter 9 for more details) to look up the page in the [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)’s xarray.

With that done, we drop the reference to the swap device via

[put_swap_device()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n510).

The remainder of the function concerns swap readahead, a topic we

will explore in more detail in Section 12.3.3, but this is similar to the page cache’s readahead logic, in that we read a batch of folios into the swap cache,

marking individual pages with the [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143) flag, such that when that one is retrieved from the swap cache, it indicates that we should trigger a read of further folios.

In the case of swap readahead, we do not do this right away, but rather

simply record the fact that we ought to read in more pages on the next occa-sion on which we read from the swap.

The method by which the swap readahead does this is to increment the

number of folios to readahead on each occasion a [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143) flag is en-countered.

There are two types of swap readahead algorithms available—cluster

readahead and VMA readahead. The former reads sequential swap slots, and the latter reads sequential virtual pages.

 



 

Cluster readahead is less efficient than VMA readahead, as users read

data sequentially in the virtual address space, , however it is more efficient

in terms of disk accesses for slow rotational devices such as hard drives (as

opposed to SSDs for whom bursts of small random accesses are less prob-

lematic).

The function [swap_use_vma_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n314) determine which to use, and is

predicated on a sysfs-tunable flag which allows a user to completely disable

swap readahead ([enable_vma_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n42)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n42) and a count of the number of swap

files which are based on rotational media ([nr_rotate_swap](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n101))—if this is greater

than zero, VMA readahead is disabled.

The VMA readahead state is stored in

[struct vm_area_struct-\>swap_readahead_info](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) which can be retrieved using

the macro [GET_SWAP_RA_VAL()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n59) (and generated via [SWAP_RA_VAL()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n59)[).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n59)

This state value encodes three integers—a window size (which can be ex-

tracted from the readahead value via [SWAP_RA_WIN()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n50)[),](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n50) a count of the number

of times folios with [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143) set have been hit (which can be obtained

from the readahead value via [SWAP_RA_HITS()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n49)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n49) and a base page-aligned address

which can be obtained from the readahead value via [SWAP_RA_ADDR()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n51)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n51)

Note that by default, [GET_SWAP_RA_VAL()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n59) encodes a hit count of four, and all

else zeroed in order to provide an initial number of folios to retrieve.

We will explore how this functions in more detail in Section 12.3.3, but

returning to [lookup_swap_cache()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n325) in Listing 12-39, we observe that, if VMA

readahead is enabled, we simply increment the hit count (up to a maximum

of [SWAP_RA_HITS_MAX](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n46)) alongside the existing window size and the address which

we looked up, if indeed the [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143) flag was set on the looked up folio.

Otherwise, if the [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143) flag was not set, we simply update the ad-

dress value to the one we just looked up.

If VMA readahead is not enabled (or if no VMA was specified), we up-

date the [swapin_readahead_hits](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n62) atomic static value, which is utilised by the

cluster readahead algorithm.

Finally, we return the retrieved page, if we located one.

 

***12.3.3 Reading Swapped Out Folios From Disk***

When reading a swapped out page directly from the disk, we do so with

[swap_readpage()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_io.c?h=v6.0#n448), which we examine in Listing 12-40 (eliding out of scope

working set, delayed account, front swap logic and debug asserts).

 

448 **int swap_readpage**(**struct** page \*page, **bool** synchronous, 449 **struct** swap_iocb \*\*plug) 450 {

451 **struct** bio \*bio;

452 **int** ret = 0;

453 **struct** swap_info_struct \*sis = **page_swap_info**(page);

. . .

476 **if** (**data_race**(sis-\>flags & **SWP_FS_OPS**)) { 477 **swap_readpage_fs**(page, plug); 478 **goto out**;

 



 

479 }

480

481 **if** (sis-\>flags & **SWP_SYNCHRONOUS_IO**) { 482 ret = **bdev_read_page**(sis-\>bdev, **swap_page_sector**(page), page); 483 **if** (!ret) { 484 **count_vm_event**(**PSWPIN**); 485 **goto out**; 486 }

487 }

488

489 ret = 0;

490 bio = **bio_alloc**(sis-\>bdev, 1, **REQ_OP_READ**, **GFP_KERNEL**); 491 bio-\>bi_iter.bi_sector = **swap_page_sector**(page); 492 bio-\>bi_end_io = **end_swap_bio_read**; 493 **bio_add_page**(bio, page, **thp_size**(page), 0); 494 */\**

495 *\* Keep this task valid during swap readpage because the oom killer*

*may*

496 *\* attempt to access it in the page fault retry time check.* 497 *\*/*

498 **if** (synchronous) { 499 **get_task_struct**(current); 500 bio-\>bi_private = current; 501 }

502 **count_vm_event**(**PSWPIN**); 503 **bio_get**(bio);

504 **submit_bio**(bio);

505 **while** (synchronous) { 506 **set_current_state**(**TASK_UNINTERRUPTIBLE**); 507 **if** (!**READ_ONCE**(bio-\>bi_private)) 508 **break**; 509

510 **blk_io_schedule**(); 511 }

512 **\_\_set_current_state**(**TASK_RUNNING**); 513 **bio_put**(bio);

514

515 **out**:

. . .

519 **return** ret;

520 }

 

*Listing 12-40:* mm/page_io.c: [*swap_readpage()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_io.c?h=v6.0#n448)

 

Similar to [\_\_swap_writepage()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_io.c?h=v6.0#n335), we won’t delve too deeply into

[swap_readpage()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_io.c?h=v6.0#n448)’s implementation as this leans into file I/O logic rather than memory management somewhat.

 



 

We start by checking if [SWP_FS_OPS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n205) is set on the swap device, which indi-

cates that swap operations should pass through the file system. In this in-

stance, we defer the operation to [swap_readpage_fs()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_io.c?h=v6.0#n411). For brevity we will not

examine this in detail.

If the swap device indicates it is more efficient to access data sequentially

via the [SWP_SYNCHRONOUS_IO](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n209) flag, then we go ahead and read the page directly

via [bdev_read_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/bdev.c?h=v6.0#n322)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/bdev.c?h=v6.0#n322)

We then ultimately generate a [struct bio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/blk_types.h?h=v6.0#n252) object (see Section 9.10.5 in

## Chapter 9 for more details on this) which we submit to the block device via

[submit_bio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/blk-core.c?h=v6.0#n820).

If the synchronous parameter is specified, then we place the task in an un-

interruptible sleep while we wait for the IO to complete via [blk_io_schedule()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/blk-core.c?h=v6.0#n1183)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/blk-core.c?h=v6.0#n1183)

Overall this function ultimately invokes the block I/O layer to read the

data from disk, asynchronously (unless synchronous is set).

When performing readahead as instigated by [do_swap_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3718)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3718) the

[swapin_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n847) function is invoked. we explore this in Listing 12-41.

 

835 */\*\**

836 *\* swapin_readahead - swap in pages in hope we need them soon* 837 *\* @entry: swap entry of this memory* 838 *\* @gfp_mask: memory allocation flags* 839 *\* @vmf: fault information* 840 *\**

841 *\* Returns the struct page for entry and addr, after queueing swapin.* 842 *\**

843 *\* It's a main entry function for swap readahead. By the configuration,* 844 *\* it will read ahead blocks by cluster-based(ie, physical disk based)* 845 *\* or vma-based(ie, virtual address based on faulty address) readahead.* 846 *\*/*

847 **struct** page \***swapin_readahead**(**swp_entry_t** entry, **gfp_t** gfp_mask, 848 **struct** vm_fault \*vmf) 849 {

850 **return swap_use_vma_readahead**() ? 851 **swap_vma_readahead**(entry, gfp_mask, vmf) : 852 **swap_cluster_readahead**(entry, gfp_mask, vmf); 853 }

 

*Listing 12-41:* mm/swap_state.c: [*swapin_readahead()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n847)

 

The [swapin_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n847) function uses [swap_use_vma_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n314) (as

discussed in Section 12.3.2) to determine whether to perform cluster

readahead (explored in Section 12.3.4) via [swap_cluster_readhead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n607) (as

shown in Listing **??**), or VMA readahead (explored in Section 12.3.5) via

[swap_vma_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n785) (as shown in Listing 12-48).

The [read_swap_cache_async()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap-state.c?h=v6.0#n513) helper function is used to allocate a page,

read it into the swap cache and then read swapped out data from disk into

the page, optionally synchronously. We examine it in Listing 12-42.

 

507 */\**

 



 

508 *\* Locate a page of swap in physical memory, reserving swap cache space* 509 *\* and reading the disk if it is not already cached.* 510 *\* A failure return means that either the page allocation failed or that* 511 *\* the swap entry is no longer in use.* 512 *\*/*

513 **struct** page \***read_swap_cache_async**(swp_entry_t entry, **gfp_t** gfp_mask, 514 **struct** vm_area_struct \*vma, 515 **unsigned long** addr, **bool** do_poll, 516 **struct** swap_iocb \*\*plug) 517 {

518 **bool** page_was_allocated; 519 **struct** page \*retpage = **\_\_read_swap_cache_async**(entry, gfp_mask, 520 vma, addr, &page_was_allocated); 521

522 **if** (page_was_allocated) 523 **swap_readpage**(retpage, do_poll, plug); 524

525 **return** retpage;

526 }

 

*Listing 12-42:* mm/swap-state.c: [*read_swap_cache_async()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap-state.c?h=v6.0#n513)

 

Ultimately the [read_swap_cache_async()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap-state.c?h=v6.0#n513) function wraps

[\_\_read_swap_cache_async(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap-state.c?h=v6.0#n409)which we examine in Listing 12-43.

This allocates a page and adds it to the swap cache. If this succeeds, then

we read data from disk into the page via [swap_readpage()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_io.c?h=v6.0#n448)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_io.c?h=v6.0#n448) which we examine

in Listing 12-40.

We examine [\_\_read_swap_cache_async()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap-state.c?h=v6.0#n409) in Listing 12-43 (eliding out of

scope working set and cgroup logic).

 

409 **struct** page \***\_\_read_swap_cache_async**(swp_entry_t entry, **gfp_t** gfp_mask, 410 **struct** vm_area_struct \*vma, **unsigned long** addr, 411 **bool** \*new_page_allocated) 412 {

413 **struct** swap_info_struct \*si; 414 **struct** page \*page;

. . .

417 \*new_page_allocated = **false**; 418

419 **for** (;;) {

420 **int** err;

421 */\**

422 *\* First check the swap cache. Since this is normally* 423 *\* called after lookup_swap_cache() failed, re-calling* 424 *\* that would confuse statistics.* 425 *\*/*

426 si = **get_swap_device**(entry); 427 **if** (!si)

428 **return NULL**;

 



 

429 page = **find_get_page**(**swap_address_space**(entry), 430 **swp_offset**(entry)); 431 **put_swap_device**(si); 432 **if** (page) 433 **return** page;

434

435 */\**

436 *\* Just skip read ahead for unused swap slot.* 437 *\* During swap_off when swap_slot_cache is disabled,* 438 *\* we have to handle the race between putting* 439 *\* swap entry in swap cache and marking swap slot* 440 *\* as SWAP_HAS_CACHE. That's done in later part of code or*

441 *\* else swap_off will be aborted if we return NULL.* 442 *\*/*

443 **if** (!**\_\_swp_swapcount**(entry) && **swap_slot_cache_enabled**) 444 **return NULL**;

445

446 */\**

447 *\* Get a new page to read into from swap. Allocate it now,*

448 *\* before marking swap_map SWAP_HAS_CACHE, when -EEXIST will*

449 *\* cause any racers to loop around until we add it to cache.*

450 *\*/*

451 page = **alloc_page_vma**(gfp_mask, vma, addr); 452 **if** (!page) 453 **return NULL**;

454

455 */\**

456 *\* Swap entry may have been freed since our caller observed it*

*.*

457 *\*/*

458 err = **swapcache_prepare**(entry); 459 **if** (!err) 460 **break**;

461

462 **put_page**(page); 463 **if** (err != -**EEXIST**) 464 **return NULL**;

465

466 */\**

467 *\* We might race against \_\_delete_from_swap_cache(), and* 468 *\* stumble across a swap_map entry whose SWAP_HAS_CACHE* 469 *\* has not yet been cleared. Or race against another* 470 *\* \_\_read_swap_cache_async(), which has set SWAP_HAS_CACHE*

471 *\* in swap_map, but not yet added its page to swap cache.* 472 *\*/*

473 **schedule_timeout_uninterruptible**(1); 474 }

 



 

475

476 */\**

477 *\* The swap entry is ours to swap in. Prepare the new page.* 478 *\*/*

479

480 **\_\_SetPageLocked**(page); 481 **\_\_SetPageSwapBacked**(page);

. . .

486 */\* May fail (-ENOMEM) if XArray node allocation failed. \*/* 487 **if** (**add_to_swap_cache**(page, entry, gfp_mask & **GFP_RECLAIM_MASK**, &

shadow))

488 **goto fail_unlock**;

. . .

495 */\* Caller will initiate read into locked page \*/* 496 **lru_cache_add**(page); 497 \*new_page_allocated = **true**; 498 **return** page;

499

500 **fail_unlock**:

501 **put_swap_page**(page, entry); 502 **unlock_page**(page); 503 **put_page**(page);

504 **return NULL**;

505 }

 

*Listing 12-43:* mm/swap-state.c: [*\_\_read_swap_cache_async()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap-state.c?h=v6.0#n409)

 

In [\_\_read_swap_cache_async()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap-state.c?h=v6.0#n409) we immediately enter into a loop, which is

used to account for the fact that we may race against other swap operations and want to retry our operation if this occurs.

We start by looking into the swap cache to se if the page is already

present, via [find_get_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n560) (this ultimately invokes [\_\_filemap_get_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1914)

(see Listing 9-49 in Section 9.5.3 and Chapter 9 for more details), again taking advantage of the fact that we maintain the swap cache using a

[struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) object and therefore can reuse this page cache function-ality here.

Throughout this lookup we ensure that the swap device is pinned via

[get_swap_device()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n1247), exiting if the device has been made unavailable.

If the page is present in the swap cache, we return it. Otherwise, we must

add a page to the swap cache at the location specified by the [swp_entry_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n820) value encoded into entry we are instructed to read.

If we see that nothing is swapped out at this location, we skip the reada-

head if the swap cache is enabled. There is a race condition that means we cannot do this if it is disabled, as alluded to by the preceding comment.

We then allocate a page to add to the swap via [alloc_page_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n287) (see Chap-

ter 2 for more on physical page allocation), returning NULL if we unable to do so.

 



 

We invoke the swap file-specific logic in preparation for this entry to be

added to the swap cache via [swapcache_prepare()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n3374). We won’t explore this in

detail as the specifics of the swap file implementation are out of scope (as

rather closer to file system code than memory management), but it’s impor-

tant to note this can cause an error, especially if the swap entry was freed

underneath us.

If no error arose, then we break out of loop. If one did indeed occur,

then we free up the page by decrementing its reference count, before de-

termining whether the error was indeed one of the entry being freed in the

meantime (indicated by EEXIST), if not we exit returning NULL, otherwise we

wait a while, loop around and try again.

After the loop has exited, we are now ready to prepare the file and add it

to the swap cache. We mark it locked and swap-backed (it will remain locked

until data from disk is read into it elsewhere), and then add it to the swap

cache via [add_to_swap_cache()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n88) (see Listing 12-22).

If this fails we free up state and return the error, otherwise we add it to

the appropriate LRU list (see Section 11.2 in Chapter 11 for more on LRU

lists) via [lru_cache_add()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n85) (which ultimately invokes [folio_add_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n479), see Listing

11-88 also in Chapter 11).

 

***12.3.4 Swap Cluster Readahead***

Swap cluster readhead is a simplistic approach to readahead that uses the

[swapin_readahead_hits](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n62) atomic static value to track the number of occasions

that a [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143) flag has been encountered on a page when looking up

from the swap cache (set by the readahead logic after reading in a number

of pages at the point at which the logic determines it would be efficient to

load another batch of pages).

This value is then used to determine how many more pages to readahead

in each batch.

Cluster readahead is implemented in [swap_cluster_readhead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n607)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n607) which we

examine in Listing **??** (eliding out of scope block plug logic).

 

589 */\*\**

590 *\* swap_cluster_readahead - swap in pages in hope we need them soon* 591 *\* @entry: swap entry of this memory* 592 *\* @gfp_mask: memory allocation flags* 593 *\* @vmf: fault information* 594 *\**

595 *\* Returns the struct page for entry and addr, after queueing swapin.* 596 *\**

597 *\* Primitive swap readahead code. We simply read an aligned block of* 598 *\* (1 \<\< page_cluster) entries in the swap area. This method is chosen* 599 *\* because it doesn't cost us any seek time. We also make sure to queue* 600 *\* the 'original' request together with the readahead ones...* 601 *\**

602 *\* This has been extended to use the NUMA policies from the mm triggering* 603 *\* the readahead.*

 



 

604 *\**

605 *\* Caller must hold read mmap_lock if vmf-\>vma is not NULL.* 606 *\*/*

607 **struct** page \***swap_cluster_readahead**(swp_entry_t entry, **gfp_t** gfp_mask, 608 **struct** vm_fault \*vmf) 609 {

610 **struct** page \*page; 611 **unsigned long** entry_offset = **swp_offset**(entry); 612 **unsigned long** offset = entry_offset; 613 **unsigned long** start_offset, end_offset; 614 **unsigned long** mask; 615 **struct** swap_info_struct \*si = **swp_swap_info**(entry);

. . .

618 **bool** do_poll = **true**, page_allocated; 619 **struct** vm_area_struct \*vma = vmf-\>vma; 620 **unsigned long** addr = vmf-\>address; 621

622 mask = **swapin_nr_pages**(offset) - 1; 623 **if** (!mask)

624 **goto skip**; 625

626 do_poll = **false**;

627 */\* Read a page_cluster sized and aligned cluster around offset. \*/*

628 start_offset = offset & ~mask; 629 end_offset = offset \| mask; 630 **if** (!start_offset) */\* First page is swap header. \*/* 631 start_offset++; 632 **if** (end_offset \>= si-\>max) 633 end_offset = si-\>max - 1;

. . .

636 **for** (offset = start_offset; offset \<= end_offset ; offset++) { 637 */\* Ok, do the async read-ahead now \*/* 638 page = **\_\_read_swap_cache_async**( 639 **swp_entry**(swp_type(entry), offset), 640 gfp_mask, vma, addr, &page_allocated); 641 **if** (!page) 642 **continue**; 643 **if** (page_allocated) { 644 **swap_readpage**(page, **false**, &splug); 645 **if** (offset != entry_offset) { 646 **SetPageReadahead**(page); 647 **count_vm_event**(**SWAP_RA**); 648 } 649 }

650 **put_page**(page); 651 }

. . .

 



 

655 **lru_add_drain**(); */\* Push any new pages onto the LRU now \*/* 656 **skip**:

. . .

658 **return read_swap_cache_async**(entry, gfp_mask, vma, addr, do_poll, **NULL**

);

659 }

 

*Listing 12-44:* mm/swap_state.c: [*swap_cluster_readhead()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n607)

 

The approach in [swap_cluster_readhead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n607) is simple, we use

[swapin_readahead_hits](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n62) to determine the number of pages to readahead in

from consecutive swap slots and then read those in.

We determine how many pages to read via [swapin_nr_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n568) which we

examine in Listing 12-45 shortly.

The returned value will be a power-of-2, so by subtracting 1 we obtain a

bit mask we can use to calculate an start and end offset describing a range

which is aligned to the cluster size and equal to its size.

We account for the fact that the first page stored in the swap file, i.e. at

index 0, is a metadata header by offsetting if the start offset was masked to

zero, and also cap the end offset according to the size of the swap file.

We then iterate through each of the entries, allocating a new page to

read from disk and adding it to the swap cache via [\_\_read_swap_cache_async()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n409)

(see Listing 12-43), and if this allocated successfully, initiating a read from

disk into the that memory via [swap_readpage()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_io.c?h=v6.0#n448) (see Listing 12-40).

For each page that is not the first, we set the [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143) flag in or-

der that this causes [lookup_swap_cache()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n325) (see Listing 12-39) to increment

[swapin_readahead_hits .](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n62)

After each loop, we drop the increment page reference count, then force

any batched operations to place pages into an LRU list (see Section 11.2 in

## Chapter 11 for more details on LRU lists) via [lru_add_drain()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n727) (see Listing 11-

110 in Section 11.7.12 and Chapter 11).

Finally, we make sure that page that triggered the readahead is read in via

[read_swap_cache_async()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n513), which we examine in Listing 12-42 in Section 12.3.3.

We examine [swapin_nr_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n568) in Listing 12-45.

 

568 **static unsigned long swapin_nr_pages**(**unsigned long** offset) 569 {

570 **static unsigned long** prev_offset; 571 **unsigned int** hits, pages, max_pages; 572 **static atomic_t last_readahead_pages**;

573

574 max_pages = 1 \<\< **READ_ONCE**(**page_cluster**); 575 **if** (max_pages \<= 1) 576 **return** 1;

577

578 hits = **atomic_xchg**(&**swapin_readahead_hits**, 0); 579 pages = **\_\_swapin_nr_pages**(**READ_ONCE**(prev_offset), offset, hits, 580 max_pages, 581 **atomic_read**(&**last_readahead_pages**));

 



 

582 **if** (!hits)

583 **WRITE_ONCE**(prev_offset, offset); 584 **atomic_set**(&**last_readahead_pages**, pages); 585

586 **return** pages;

587 }

 

*Listing 12-45:* mm/swap_state.c: [*swapin_nr_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n568)

 

The [swapin_nr_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n568) function is parameterised on a number of static

variables. The first is [page_cluster](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n47)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n47) which determines the maximum power-of-two number of pages to readahead in cluster readahead mode.

This is set by [swap_setup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n1071) early in the kernel lifetime, which we examine

in Listing 12-46.

 

1068 */\**

1069 *\* Perform any setup for the swap system* 1070 *\*/*

1071 **void \_\_init swap_setup**(**void**) 1072 {

1073 **unsigned long** megs = **totalram_pages**() \>\> (20 -**PAGE_SHIFT**); 1074

1075 */\* Use a smaller cluster for small-memory machines \*/* 1076 **if** (megs \< 16)

1077 **page_cluster** = 2; 1078 **else**

1079 **page_cluster** = 3; 1080 */\**

1081 *\* Right now other parts of the system means that we* 1082 *\* \_really\_ don't want to cluster much more* 1083 *\*/*

1084 }

 

*Listing 12-46:* mm/swap.c: [*swap_setup()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n1071)

 

The [swap_setup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n1071) function sets the power-of-two number of pages to

readahead in [page_cluster](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n47) to two if there are 16 megabytes or less available in the system, or three if there is more, in order to conserve memory in low memory devices.

This equates to a maximum of 4 pages for very low memory systems or 8

for all others.

Note that this can also be updated via the sysctl tunable vm.page-cluster

for custom control of cluster readahead.

 

**N O T E** We also use this value in VMA readahead to determine the maximum number of

pages to readahead, see [*swap_ra_info()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n709) in Section 12.3.5 to see how this is used.

 

Returning to [swapin_nr_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n568) and Listing 12-45, we see that if the user

has set [page_cluster](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n47) to zero, then we return one, indicating that in effect no readahead should take place.

 



 

After considering this edge case, we then atomically exchange the

[swapin_readahead_hits](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap-state.c?h=v6.0#n62) with zero, resetting this value and therefore retriev-

ing the number of hits on pages with [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143) set (i.e. for swap cluster

readahead, that is all of the pages that were readahead previously).

The [swapin_readahead_hits](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap-state.c?h=v6.0#n62) value defaults to four if not previously set, to

ensure the first cluster readahead results in a reasonable batch of pages be-

ing read in at once.

We retain a function-scope static variable prev_offset to keep track of the

last offset within a swap file we encountered when there were no hits, which

should equate to the beginning of a readahead range.

Equally, we track the last number of pages we calculated should be reada-

head in the function-scope static variable last_readahead_pages.

With these values in hand, we pass the last known of these and the offset,

number of hits and maximum pages to readahead to [\_\_swapin_nr_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n528) (see

Listing 12-47), which does the heavy lifting of determining the number of

pages to readahead.

 

528 **static unsigned int \_\_swapin_nr_pages**(**unsigned long** prev_offset, 529 **unsigned long** offset, 530 **int** hits, 531 **int** max_pages, 532 **int** prev_win) 533 {

534 **unsigned int** pages, last_ra;

535

536 */\**

537 *\* This heuristic has been found to work well on both sequential and*

538 *\* random loads, swapping to hard disk or to SSD: please don't ask*

539 *\* what the "+ 2" means, it just happens to work well, that's all.*

540 *\*/*

541 pages = hits + 2; 542 **if** (pages == 2) { 543 */\**

544 *\* We can have no readahead hits to judge by: but must not get*

545 *\* stuck here forever, so check for an adjacent offset instead*

546 *\* (and don't even bother to check whether swap type is same).*

547 *\*/*

548 **if** (offset != prev_offset + 1 && offset != prev_offset - 1) 549 pages = 1; 550 } **else** {

551 **unsigned int** roundup = 4; 552 **while** (roundup \< pages) 553 roundup \<\<= 1; 554 pages = roundup; 555 }

556

557 **if** (pages \> max_pages) 558 pages = max_pages;

 



 

559

560 */\* Don't shrink readahead too fast \*/* 561 last_ra = prev_win / 2; 562 **if** (pages \< last_ra) 563 pages = last_ra; 564

565 **return** pages;

566 }

 

*Listing 12-47:* mm/swap_state.c: [*\_\_swapin_nr_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n528)

 

**N O T E** Swap VMA readahead also uses this function to determine the number of pages to

readahead, see [*swap_ra_info()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n709) in Listing 12-50 and Section **??** to see how this is used.

 

The [\_\_swapin_nr_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n528) function, like much of the kernel, is highly heuris-

tic and tuned to real-world workloads.

We start by determining a baseline number, equal to the number of

readahead hits we’ve encountered (on the basis that if we have read a num-ber of pages in a previously readahead range then reading ahead more is likely to be worthwhile) plus a minimum two pages.

If we are at two pages only, this indicates no hits were encountered, and

we need to determine whether readahead is appropriate at all—we do so by checking to see if the offset is immediately adjacent to the previous offset at which no hits were registered.

If this is the case, then it suggests we are reading sequentially, and thus

more readahead is appropriate, otherwise we reset pages to one.

If we have encountered hits, then we round up to a minimum of four

pages, increasing in powers-of-two. If this exceeds the maximum allowed pages, we cap this number to the maximum.

Finally, having been passed in the last_readahead_pages value from

[swapin_nr_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n568) (see Listing 12-45) which indicates the last number of pages that were determined should be readahead via cluster readahead as the prev_win parameter.

We make sure that we reduce the readahead window by at most half on

each occasion it drops so we do not scale down readahead too quickly.

 

**N O T E** We do not consider which swap file (otherwise known as swap type, i.e. the index

of the swap file) these indexes pertain to, so inevitably there is a chance that we will miscalculate here. As this is all intended to be a heuristic in order to improve swap read performance, the decision has been made that keeping this simple trumps such miscalculations.

 

***12.3.5 Swap VMA Readahead***

When [swapin_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n847) (see Listing 12-41) invokes VMA swap readahead, as

determined by [swap_use_vma_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n314) (see Section 12.3.2 for an exploration

 



 

of this), the [swap_vma_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n785) function is invoked, which we explore in

Listing 12-48 (eliding out of scope block plugging logic).

 

771 */\*\**

772 *\* swap_vma_readahead - swap in pages in hope we need them soon* 773 *\* @fentry: swap entry of this memory* 774 *\* @gfp_mask: memory allocation flags* 775 *\* @vmf: fault information* 776 *\**

777 *\* Returns the struct page for entry and addr, after queueing swapin.* 778 *\**

779 *\* Primitive swap readahead code. We simply read in a few pages whose* 780 *\* virtual addresses are around the fault address in the same vma.* 781 *\**

782 *\* Caller must hold read mmap_lock if vmf-\>vma is not NULL.* 783 *\**

784 *\*/*

785 **static struct** page \***swap_vma_readahead**(**swp_entry_t** fentry, **gfp_t** gfp_mask, 786 **struct** vm_fault \*vmf) 787 {

. . .

790 **struct** vm_area_struct \*vma = vmf-\>vma; 791 **struct** page \*page; 792 **pte_t** \*pte, pentry; 793 **swp_entry_t** entry; 794 **unsigned int** i;

795 **bool** page_allocated; 796 **struct** vma_swap_readahead ra_info = { 797 .win = 1, 798 };

799

800 **swap_ra_info**(vmf, &ra_info); 801 **if** (ra_info.win == 1) 802 **goto skip**;

. . .

805 **for** (i = 0, pte = ra_info.ptes; i \< ra_info.nr_pte; 806 i++, pte++) { 807 pentry = \*pte; 808 **if** (!**is_swap_pte**(pentry)) 809 **continue**; 810 entry = **pte_to_swp_entry**(pentry); 811 **if** (**unlikely**(**non_swap_entry**(entry))) 812 **continue**; 813 page = **\_\_read_swap_cache_async**(entry, gfp_mask, vma, 814 vmf-\>address, &page_allocated);

815 **if** (!page) 816 **continue**; 817 **if** (page_allocated) {

 



 

818 **swap_readpage**(page, **false**, &splug); 819 **if** (i != ra_info.offset) { 820 **SetPageReadahead**(page); 821 **count_vm_event**(**SWAP_RA**); 822 } 823 }

824 **put_page**(page); 825 }

. . .

828 **lru_add_drain**();

829 **skip**:

. . .

831 **return read_swap_cache_async**(fentry, gfp_mask, vma, vmf-\>address, 832 ra_info.win == 1, **NULL**); 833 }

 

*Listing 12-48:* mm/swap_state.c: [*swap_vma_readahead()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n785)

 

We start by establishing a [struct vma_swap_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n337) state object which we

thread state through the operation. We examine this in Listing 12-49 (as-suming a 64-bit architecture).

 

337 **struct** vma_swap_readahead { 338 **unsigned short** win; 339 **unsigned short** offset; 340 **unsigned short** nr_pte;

. . .

342 **pte_t** \*ptes;

. . .

346 };

 

*Listing 12-49:* include/linux/swap.h: [*struct vma_swap_readahead*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n337)

 

This keeps track of the window of pages over which reclaim should occur,

the offset of the swap entry we are reading in the first instance and a count of the number of PTEs whose swap entries we intend to readahead as well as a pointer to the first PTE entry in the PTE page table containing the PTEs we are reading ahead (which can in effect be treated like an array).

We set up this state in [swap_ra_info()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n709) which we examine in Listing 12-50,

this contains core readahead logic which decides how readahead should pro-ceed.

With this state established, we first check whether the window size is only

a single entry, if so then we have no readahead to do and skip to the end of the function.

Otherwise, we iterate through PTEs—skipping those which are not swap

PTEs or are non-swap PTE entries (out of scope for the book, but these are things like migration entries which share the characteristics of swap entries but don’t refer to swap).

 



 

**N O T E** We copy the PTE into *pentry* as we do not hold the lock on the PTEs and they may be

unmapped or otherwise modified during the course of the loop.

 

We then read the page for the entry via [\_\_read_swap_cache_async()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n409) (see

Listing 12-43), continuing the loop to the next entry if this failed.

If it succeeds, then we read from disk into the swap entry via

[swap_readpage()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_io.c?h=v6.0#n448) (see Listing 12-40).

If the offset doesn’t refer to that of the swap entry requested to be read,

i.e. refers to swap entries being read ahead, we mark these with [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143)

so [lookup_swap_cache()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n325) updates VMA swap readahead state when these are

later read from (see Listing 12-39).

We drop the page reference, and after the loop is complete, we force

any batched operations to place pages into an LRU list (see Section 11.2 in

## Chapter 11 for more details on LRU lists) via [lru_add_drain()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n727) (see Listing 11-

110 in Section 11.7.12 and Chapter 11).

Finally, and also if the readahead operation was skipped, we use the

[read_swap_cache_async()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n513) function to ensure the originally requested swap en-

try is read (see Listing 12-42 in Section 12.3.3).

We run this function synchronously in the case that we skipped reada-

head.

The [swap_ra_info()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n709) function populates the [struct vma_swap_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n337) state

object but also in doing so implements the logic of swap VMA readahead.

We examine this in Listing 12-50 (assuming x86-64 architecture).

 

709 **static void swap_ra_info**(**struct** vm_fault \*vmf, 710 **struct** vma_swap_readahead \*ra_info) 711 {

712 **struct** vm_area_struct \*vma = vmf-\>vma; 713 **unsigned long** ra_val; 714 **unsigned long** faddr, pfn, fpfn; 715 **unsigned long** start, end; 716 **pte_t** \*pte, \*orig_pte; 717 **unsigned int** max_win, hits, prev_win, win, left;

. . .

722 max_win = 1 \<\< **min_t**(**unsigned int**, **READ_ONCE**(page_cluster), 723 **SWAP_RA_ORDER_CEILING**); 724 **if** (max_win == 1) { 725 ra_info-\>win = 1; 726 **return**;

727 }

728

729 faddr = vmf-\>address; 730 orig_pte = pte = **pte_offset_map**(vmf-\>pmd, faddr);

731

732 fpfn = **PFN_DOWN**(faddr); 733 ra_val = **GET_SWAP_RA_VAL**(vma); 734 pfn = **PFN_DOWN**(**SWAP_RA_ADDR**(ra_val)); 735 prev_win = **SWAP_RA_WIN**(ra_val);

 



 

736 hits = **SWAP_RA_HITS**(ra_val); 737 ra_info-\>win = win = **\_\_swapin_nr_pages**(pfn, fpfn, hits, 738 max_win, prev_win); 739 **atomic_long_set**(&vma-\>swap_readahead_info, 740 **SWAP_RA_VAL**(faddr, win, 0)); 741

742 **if** (win == 1) {

. . .

744 **return**;

745 }

. . .

748 **if** (fpfn == pfn + 1) 749 **swap_ra_clamp_pfn**(vma, faddr, fpfn, fpfn + win, &start, &end); 750 **else if** (pfn == fpfn + 1) 751 **swap_ra_clamp_pfn**(vma, faddr, fpfn - win + 1, fpfn + 1, 752 &start, &end); 753 **else** {

754 left = (win - 1) / 2; 755 **swap_ra_clamp_pfn**(vma, faddr, fpfn - left, fpfn + win - left, 756 &start, &end); 757 }

758 ra_info-\>nr_pte = end - start; 759 ra_info-\>offset = fpfn - start; 760 pte -= ra_info-\>offset;

. . .

762 ra_info-\>ptes = pte;

. . .

769 }

 

*Listing 12-50:* mm/swap_state.c: [*swap_ra_info()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n709)

 

In [swap_ra_info()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n709) we make use of the [page_cluster](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n47) static variable to deter-

mine the maximum number of pages to readahead, as also used for swap

cluster readahead (see Section 12.3.4).

 

**N O T E** In swap VMA readahead we limit the window size to a maximum of the power-of-two

value [*SWAP_RA_ORDER_CEILING*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n330), which is hard-coded to five, meaning 32 pages.

 

We term this the maximum window over which readahead might occur.

If this is equal to one, then no readahead will happen and we can simply exit

indicating so by setting [struct vma_swap_readahead-\>win](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n337) to one.

At this point, since we are examining a series of contiguous virtual ad-

dresses, we need to read the PTE of each mapping in order to retrieve the

[swp_entry_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n820) value stored within these entries.

In order to be able to efficiently do this, we take advantage of the fact we

are invoked on the fault path and therefore have access to the [struct vm_fault](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n481)

object describing the fault (see Chapter 6 for more details on fault handling in general), from which we can obtain the PTE of the faulting address.

 



 

We set faddr to the faulting address and both orig_pte and pte to the fault-

ing PTE.

In order to avoid any expensive page table walks, we constrain ourselves

to the remainder of the PTE page table starting at the faulting PTE. The

logic for this lies later in the code, firstly we retrieve the virtual PFN (see

## Chapter 2 for more on physical addresses and Page Frame Numbers or PFNs

– essentially the address divided by page size, that is if you consider memory

to be in effect an array of base pages, the index into that array) containing

the page in which the faulting address resides via [PFN_DOWN()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pfn.h?h=v6.0#n20), and store it in

fpfn .

We say “virtual” PFN here as typically PFNs refer to a page offset for

physical addresses, however in this case we are using the same concept only

for the virtual fault address.

We retrieve the [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) encoded

swap VMA readahead state via [GET_SWAP_RA_VAL()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n59) (stored in

[struct vm_area_struct-\>swap_readahead_info](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403)), from which we derive state

about the last swap lookup. The number of readahead hits is written by

[lookup_swap_cache()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n325) (see Listing 12-39) on swap lookup, and the last faulting

address and window size are written by this function later in the code.

We use this to retrieve the virtual PFN of the last retrieved address which

we store in pfn, the previous window size (i.e. the previous number of pages

we determined to readahead) as stored in prev_win and the number of hits

stored in hits.

We reuse the [\_\_swapin_nr_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n528) function (see Listing 12-47) as also used

in the swap cluster readahead logic.

One key difference here is rather than using offsets into the swap, we use

virtual PFN offsets in order to measure distance between pages being read

from swap, hence we pass pfn as prev_offset and fpfn as offset.

After determining the number of pages to readahead, we update the

[struct vma_swap_readahead-\>win](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n337) field and the local win value accordingly.

With these determined, we reset the hit count to zero and update the

VMA swap readahead state in [struct vm_area_struct-\>swap_readahead_info](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) to

contain the faulting address and determined window size to be the previ-

ous values for these when next we readahead. We generate this value via

[SWAP_RA_VAL().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n59)

Again if we determine that the window size is equal one at this stage, this

indicates that no readahead should occur, so we exit in this case.

Otherwise, we must be careful to ensure that we examine only PTEs in

this page table and not beyond. We do so via the [swap_ra_clamp_pfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n696) func-

tion, which we examine in Listing 12-51.

This function accepts parameters for the VMA, the faulting address, the

left-most PFN and the right-most PFN over which we propose to readahead,

as well as output parameters for the determined start and end of the reada-

head range.

We consider three different scenarios:

 



 

**Forward Sequential Access** The swap is being faulted in moving forwards

through sequential pages, so readahead from the page fpfn to the (exclu-sive) end of the window fpfn + win.

**Backwards Sequential Access** The swap is being faulted in moving back-

wards through sequential pages, so readahead up to and including the faulting page between fpn - win + 1 and fpfn + 1.

**Random Access** The swap is being faulted in using some other access pat-

tern, so split the difference and readahead pages half of which lie prior to the faulting address, and half of which lie after it.

 

Once we have determined start and end virtual PFN values, we can use

these to determine the number of PFNs for [swap_vma_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n785) to read through, and is simply determined to be end - start which we place in

[struct vma_swap_readahead-\>nr_pte](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n337).

Equally the faulting PFN is offset from the start of the range

by the number of pages between fpfn and start so we populate

[struct vma_swap_readahead-\>offset](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n337) with this value.

We offset pte by this offset value, and then assign it to

[struct vma_swap_readahead-\>pte](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n337) to provide the first PTE entry in the PTE page

table to be examined by [swap_vma_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n785).

We examine the key [swap_ra_clamp_pfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n696) function in Listing 12-51.

 

696 **static inline void swap_ra_clamp_pfn**(**struct** vm_area_struct \*vma, 697 **unsigned long** faddr, 698 **unsigned long** lpfn, 699 **unsigned long** rpfn, 700 **unsigned long** \*start, 701 **unsigned long** \*end) 702 {

703 \*start = **max3**(lpfn, **PFN_DOWN**(vma-\>vm_start), 704 **PFN_DOWN**(faddr & **PMD_MASK**)); 705 \*end = **min3**(rpfn, **PFN_DOWN**(vma-\>vm_end), 706 **PFN_DOWN**((faddr & **PMD_MASK**) + **PMD_SIZE**)); 707 }

 

*Listing 12-51:* mm/swap_state.c: [*swap_ra_clamp_pfn()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n696)

 

The [swap_ra_clamp_pfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n696) function determines start and end virtual PFN val-

ues which are equal to lpfn and rpfn respectively, only clamped to the start and end of the VMA and PTE page tables containing the PTE entries map-ping the pages containing lpfn and rpfn.

We obtain start by taking the maximum of lpfn, the virtual PFN of the

[struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA)’s start address, and the lowest virtual PFN con-tained within the PTE which also contains the PTE entry mapping the lpfn page.

We determine the latter of these values by applying the [PMD_MASK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n99) to the

faulting address, which masks the high bits of the address which identify

 



 

which PMD page table it refers to, and thus constraining the address to a

single PMD entry, which is the PTE page table.

 

**N O T E** This might be slightly hard to follow, as visualising how page tables are laid out can

get confusing fast, review Chapter 3 on virtual memory layout to observe how the

page tables interact with one another.

 

We obtain end by taking the minimum of rpfn, the virtual PFN of the

[struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA)’s (exclusive) end address, and the virtual PFN

of the next PTE page table after the one containing the faulting address.

The end value is always an exclusive value, i.e. the last virtual PFN in the

readahead range plus one.

As usual the complicated part of determining end is the constraint to the

end of the page table. We essentially apply the same technique we did for

start by applying the [PMD_MASK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n99) mask, only we also offset by [PMD_SIZE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64_types.h?h=v6.0#n98) to ensure

we get the page table after the one containing the faulting address.

Since we obtain the minimum of these three values, we never fall off the

end of either the VMA or the PTE page table.

 

