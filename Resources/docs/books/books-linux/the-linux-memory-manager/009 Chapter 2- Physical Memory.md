
 

**2**

 

**P H Y S I C A L M E M O R Y**

 

Physical memory describes all of the memory on a sys-

tem which can be addressed arbitrarily by at least one

core. Typically this will be in the form of RAM mod-

ules but could include other forms of random-access

stores. Over the course of this chapter we will explore

how the kernel manages, allocates and abstracts this

resource.

Physical addresses tell the CPU where to find a particular byte of memory.

For example, DRAM stores each individual byte on a specific row and col-

umn in a specific array known as a bank, accessed by a specific channel on a

DIMM stored in a specific slot. The physical address encodes all of this infor-

mation.

Within the kernel, physical addresses are assigned the [phys_addr_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/types.h?h=v6.0#n153) type

which is equal to the word size, e.g. for a 64-bit system this is simply an un-

signed 64-bit integer.

If we were to try to manage every byte of memory individually the over-

head associated with trying to keep a track of it would exceed the amount

of available memory in the system. This is obviously intractable so we have

to compromise and subdivide memory into aggregate blocks, which we call

pages.


 

The base page size of an architecture is the hardware-configured mini-

mum supported page size and thus the fundamental unit of memory. For x86-64 this is 212 or 4,096 bytes, for arm64 and other architectures how-ever this can vary. In the Linux kernel the base page size is defined to be PAGE_SIZE bytes (This is architecture-specific and so declared in the appropri-ate arch/ header file).

We subdivide pages further into nodes and zones. Let’s examine what each

of these mean:

Large server boxes may support more than once CPU socket with some

memory modules attached to one CPU, some attached to another and so on, with some slow means of interconnect between remote blocks of mem-ory.

Systems with memory arranged in this configuration are said to have a

Non-Uniform Memory Access (NUMA) memory architecture.

 

**N O T E** In addition, systems may even have blocks of memory that don’t have a CPU asso-

ciated with them and are slow for any core to access, or are attached to a CPU with locality to other memory also attached to the same CPU, but possess other characteris-tics which reduces the speed of access to them.

 

Even single-CPU systems on modern hardware are typically treated as

NUMA, only with a single NUMA node defined which owns all physical memory.

In order for the kernel to take these heterogeneous memory blocks into

account it subdivides them into physically contiguous domains known as nodes, with each page of physical memory belonging to one and only one node.

Within each node memory is further divided based on physical address

ranges into areas known as zones. This is either because that range of mem-ory naturally possesses an important characteristic or because a range of memory has been arbitrarily assigned to a particular purpose. Zones overlap nodes.

It is important to note that for a modern system which has NUMA en-

abled, physical memory allocation will always be parameterised by node and zone (even if they may have been automatically determined by a function higher up the call stack).

In order to efficiently allocate memory the kernel allocates memory in

power-of-two numbers of base pages at a time with the order of an allocated page being equal this power-of-two e.g. an order-3 allocation consists of 23 = 8 base pages of memory.

Each base page of physical memory has metadata associated with it

which is stored in [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) objects, with aggregate blocks of 1 or more

base pages represented as a [struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) object.

For convenience we define the useful notion of a Page Frame Number

(PFN) which is simply the physical address divided by the page size, in other words if you were to conceive of physical pages as elements in an array, the

PFN is the index of a page in that array. [PFN_PHYS()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pfn.h?h=v6.0#n21) and [PHYS_PFN()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pfn.h?h=v6.0#n22) are used to convert between the two.

 



 

Memory is further divided into page blocks (the order of which is defined

by [pageblock_order](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pageblock-flags.h?h=v6.0#n36), 9 on x86-64, i.e. 512 pages). These are the smallest num-

ber of pages which can have a migrate type applied to them. A migrate type

determines whether pages can be migrated i.e. moved around, described by

[enum migratetype. ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n42)More on this later.

Let’s examine an example physical memory layout in Figure 2-1.

 

Node 2

 

Zone C

 

Node 1

Page

Page

block

Zone B

 

Node 0

 

Zone A

 

Physical

address

0

 

*Figure 2-1: Example physical memory layout*

 

The line represents physical memory from zero to the maximum avail-

able to the system.

Note that this diagram excludes memory holes, (blocks of physical mem-

ory inaccessible for use as ordinary memory—either empty, reserved or used

by devices) for simplicity.

Each node and zone subdivides the physical address space into contigu-

ous blocks of memory, with zones overlapping nodes. Each node and zone

are page-aligned so base pages belong definitely to a node and a zone.

 



 

**N O T E** It is actually possible for distinct nodes and zones to overlap one another, for instance

in cases where access times for memory in the overlapping region are equivalent in each node, however for the sake of brevity we will assume these ranges are distinct.

 

**2.1 struct page**

 

In order to manage pages of memory we must store metadata about them— flags to identify what characteristics the page has, reference count to deter-mine whether we can free the page or not and a whole host of other meta-data specific to how they are used.

 

**N O T E** Rather than confuse matters and include every permutation of kernel configuration

and platform we focus on modern 64-bit, little-endian architectures with sensible configurations. This might seem like heresy, but trying to cover everything would render this book unreadable and my sanity unknowable.

 

The data type that encapsulates this data is [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) which, for mod-

ern 64-bit systems contains:

 

• A flags field which specifies attributes of the page and additionally en-

codes zone and optionally node information (it can also encode ‘section’ information under certain configuration options, this is out of scope at

this point.) set via [set_page_zone()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1570) and [set_page_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1576) and accessed via

[page_zonenum()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n781) and [page_to_nid()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1244)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1244)

• A 40-byte metadata union, a union of a series of data structures which

varies depending on what the page is being used for. This is used to store pertinent metadata to the page depending on type, or if used for

‘slab’ pages (see the slab chapter for more on this) the whole [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72)

is cast to a [struct slab](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/slab.h?h=v6.0#n9) object, which shares flags, \_refcount and memcg_data fields but overwrites the metadata union and \_mapcount/page_type fields.

• If not a slab page—a union of either a \_mapcount variable (which should be

accessed via [page_mapcount()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n825)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n825) counting page table mappings if the page is mappable in userland (or a page_type field giving further details on the page type.

• A reference count \_refcount field (which should be accessed via

[page_ref_count()) ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page_ref.h?h=v6.0#n65)used to determine if this page can be freed typically

incremented by [get_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1093) and decremented by [put_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1167).

• A memcg_data field used to store data pertinent to memory cgroups, typi-

cally a pointer to a cgroup data structure.

 

In total the size of the structure on a modern x86-64 system is 64 bytes

(the typical size of a L1 cache line) and is typically laid out in such a way that

it is accessed contiguously in memory meaning that [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) objects can be accessed very efficiently.

Each [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) represents the smallest page size the kernel (and typ-

ically the system) supports (e.g. for x86-64 this is 4 KiB), however physi-cally contiguous pages can be compounded together resulting in compound

 



 

pages allocated as a block. In order to square this circle we designate the first

[struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) of a compound page a head page and the remainder tail pages.

Compound pages will always consist of a power-of-2 number of base

pages equal to 2 order and referred to as ‘order-N’ pages, e.g. an order-0 page

is 20 1 = 1 base page in size, an order-1 page is 2 = 2 base pages in size, an

order-2 page is 2 2 = 4 base pages in size and so forth.

To add to the confusion, it is possible to allocate higher order pages with-

out them being compound – in which case it is assumed the owner of the

page simply knows which [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) represents the higher-order page. In

order to obtain a compound page, the \_\_GFP_COMP flag must be set (more on

GFP flags later).

The terminology is confusing here – both higher order pages and base

pages are referred to simply as pages. A good rule of thumb is, unless quali-

fied as a ‘compound’ page or an ‘order-N’ page, it is usually safe to assume

that the term ‘page’ refers to a page of base size, especially when expressed

as a unit e.g. ‘137 pages’.

Overall the philosophy of [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) is to utilise the space taken up by

each object as efficiently as possible, squeezing out the available space for

all its worth. As a result there is a heavy use of unions overloading the use

of each offset within the struct as well as the aforementioned casting of

[struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) to [struct slab](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/slab.h?h=v6.0#n9) (this object is used for slab allocation, see the slab

## chapter for more on this).

Historically when a [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) has been referred to (for example

as a function parameter), it has not been possible to guarantee that it

wasn’t a tail page. The solution until recently has been to always invoke

[compound_head()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n260) which, if it was indeed a tail page exchanged it for its head.

However rather sensibly the kernel has moved towards explicitly indicat-

ing that these parameters are not tail pages so that this uncertainty can be

eliminated. This is achieved by using the [struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) type which maps one-

to-one to a [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) but is always either non-compound or a head page.

Helper functions exist to ease the transition as interfaces are updated, and

for the moment [struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) contains a top-level union with a [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) so

it is very easy to convert between the two. More on this later.

After excising fields that aren’t relevant to a modern x86-64 system the

definition is as follows, as shown in Listing 2-1.

 

72 **struct** page {

73 **unsigned long** flags; */\* Atomic flags, some possibly*

74 *\* updated asynchronously \*/*

75 */\**

76 *\* Five words (20/40 bytes) are available in this union.*

77 *\* WARNING: bit 0 of the first word is used for PageTail(). That*

78 *\* means the other users of this union MUST NOT use the bit to*

79 *\* avoid collision and false-positive PageTail().*

80 *\*/*

81 **union** {

. . . */\* ... (metadata union) ... \*/*

186 };

 



 

187

188 **union** { */\* This union is 4 bytes in size. \*/* 189 */\**

190 *\* If the page can be mapped to userspace, encodes the number*

191 *\* of times this page is referenced by a page table.* 192 *\*/*

193 **atomic_t** \_mapcount; 194

195 */\**

196 *\* If the page is neither PageSlab nor mappable to userspace,*

197 *\* the value stored here may help determine what this page*

198 *\* is used for. See page-flags.h for a list of page types*

199 *\* which are currently stored here.* 200 *\*/*

201 **unsigned int** page_type; 202 };

203

204 */\* Usage count. \*DO NOT USE DIRECTLY\*. See page_ref.h \*/* 205 **atomic_t** \_refcount; 206

207 **\#ifdef CONFIG_MEMCG**

208 **unsigned long** memcg_data; 209 **\#endif**

. . .

229 } **\_struct_page_alignment**;

 

*Listing 2-1:* include/linux/mm_types.h: [*struct page*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) *definition*

 

The [\_struct_page_alignment](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n67) define specifies that the page should be

aligned to double system word size (e.g. 16 bytes for 64-bit systems) if CONFIG_HAVE_ALIGNED_STRUCT_PAGE is set which it typically will be on modern sys-tems. This permits the SLUB allocator to perform atomic operations at this size for better performance. Ultimately for x86-64 and arm64 this should have no impact as in both cases struct page will be of cache line size – i.e. 64

bytes, as shown in Listing 2-2.

 

66 **\#ifdef CONFIG_HAVE_ALIGNED_STRUCT_PAGE** 67 **\#define** \_struct_page_alignment \_\_aligned(2 \* **sizeof**(**unsigned long**)) 68 **\#else**

69 **\#define** \_struct_page_alignment 70 **\#endif**

 

*Listing 2-2:* include/linux/mm_types.h: [*\_struct_page_alignment*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n67)

 

In graphical form (the digits on the left indicate byte offset, the vertical

divisions indicate either different entries in a union or being cast to another

type) as shown in Figure 2-2.

 



 

0

 

4 unsigned long **flags**

 

8

 

12

 

16

 

20

 

24

 

28 **(metadata union)**

**struct slab** fields

32

 

36

 

40

 

44

 

48

atomic_t **\_mapcount** unsigned int **page_type**

52

atomic_t **\_refcount**

56

 

60 unsigned long **memcg_data**

 

64

Userspace mappable Kernel non-slab page Slab page

 

*Figure 2-2:* [*struct page*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) *layout for a typical 64-bit architecture*

 

***2.1.1 Metadata***

**2.1.1.1 Anonymous/page cache pages**

If a page is either allocated as a simple ‘anonymous’ page (i.e. not tied to a

file and not used for any special purpose requiring more metadata) or is a

part of the page cache (a page containing data for a memory-mapped file,

either explicitly mapped in or cached automatically, see later chapter on this

topic) then the metadata union used is, as shown in Listing 2-3.

 

82 **struct** { */\* Page cache and anonymous pages \*/*

83 */\*\**

84 *\* @lru: Pageout list, eg. active_list protected by*

85 *\* lruvec-\>lru_lock. Sometimes used as a generic list*

 



 

86 *\* by the page owner.* 87 *\*/* 88 **union** { 89 **struct** list_head lru; 90

91 */\* Or, for the Unevictable "LRU list" slot \*/*

92 **struct** { 93 */\* Always even, to negate PageTail \*/*

94 **void** \*\_\_filler; 95 */\* Count page's or folio's mlocks \*/*

96 **unsigned int** mlock_count; 97 }; 98

99 */\* Or, free page \*/*

100 **struct** list_head buddy_list; 101 **struct** list_head pcp_list; 102 }; 103 */\* See page-flags.h for PAGE_MAPPING_FLAGS \*/* 104 **struct** address_space \*mapping; 105 **pgoff_t** index; */\* Our offset within mapping.*

*\*/*

106 */\*\** 107 *\* @private: Mapping-private opaque data.* 108 *\* Usually used for buffer_heads if PagePrivate.* 109 *\* Used for swp_entry_t if PageSwapCache.* 110 *\* Indicates order in the buddy system if PageBuddy.*

111 *\*/* 112 **unsigned long** private; 113 };

 

*Listing 2-3:* include/linux/mm_types.h: [*Anonymous page/page cache*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n82) *metadata union struct*

 

This consists of:

 

• lru/mlock_count – A union of either a list head field, lru, which is used

to connect the page to a list maintained in possibly Least Recently Used (LRU) order or, if the page contains LRU list metadata itself, then the field is mlock_count a count of the number of times this memory has been

[mlock() ’d.](https://man7.org/linux/man-pages/man2/mlock.2.html)

• mapping – A rather deceptively typed and named field – it points to

a page cache-specific [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) mapping field if this page is part of the page cache (as one might expect), however the lower 2 bits

are given over to flags and if the [PAGE_MAPPING_ANON](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n635) flag is set alone it

will instead point to a [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) object (see later chapter on this topic). If the page does not appear on LRU lists (termed ‘non-LRU’)

it may set the the [PAGE_MAPPING_MOVABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n636) flag in which case the mapping

points at a [struct movable_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/migrate.h?h=v6.0#n52) object. Finally, if the flags are set to

[PAGE_MAPPING_KSM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n637) (a combination of the prior two) it points to a private

 



 

KSM data structure. KSM is [Kernel Samepage Merging](https://kernel.org/doc/html/v6.0/admin-guide/mm/ksm.html), which allows for memory pages to be de-duplicated, typically used by virtual machines. All rather confusing!

• index – If this page is within a page (or swap) cache this field indicates

the offset of this page within the mapped file.

• private – A field containing private data that the filesystem which owns

the page can use for its own purposes (see the [PG_private](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n52) comment for more details).

 

**N O T E** A list head is a structure containing pointers to previous and next nodes in a doubly-

linked ring list, implemented neatly by keeping nodes within structures and using the

statically known offset of the entry from the start of the structure to be able to retrieve

node contents at compile-time, see [*include/linux/list.h*](https://elixir.bootlin.com/linux/v6.0/source/include/linux/list.h) to see the implementation.

 

We examine this in graphical form in Figure 2-3.

 

8

 

12

 

16 struct list_head **lru**

unsigned int **mlock_count**

20

 

24

 

28 struct address_space **\*mapping**

 

32

 

36 pgoff_t **index**

 

40

 

44 unsigned long **private**

 

48

Anonymous page Page cache

 

*Figure 2-3:* [*Anonymous page/page cache*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n82) *metadata union struct*

 



 

**2.1.1.2 Tail pages**

Tail page metadata is represented in a slightly less clear fashion – two unions containing overlapping information from the following structs, as shown in

Listing 2-4.

 

136 **struct** { */\* Tail pages of compound page \*/* 137 **unsigned long** compound_head; */\* Bit zero is set \*/* 138

139 */\* First tail page only \*/* 140 **unsigned char** compound_dtor; 141 **unsigned char** compound_order; 142 **atomic_t** compound_mapcount; 143 **atomic_t** compound_pincount; 144 **\#ifdef CONFIG_64BIT**

145 **unsigned int** compound_nr; */\* 1 \<\< compound_order \*/* 146 **\#endif**

147 };

148 **struct** { */\* Second tail page of compound page \*/* 149 **unsigned long** \_compound_pad_1; */\* compound_head \*/* 150 **unsigned long** \_compound_pad_2; 151 */\* For both global and memcg \*/* 152 **struct** list_head deferred_list; 153 };

 

*Listing 2-4:* include/linux/mm_types.h: [*Tail page*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n136) *metadata union structs*

Every tail page has the compound_head field set which is a pointer to the

head page with the lower bit additionally set (this is how we identify tail

pages via [PageTail()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n290)[).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n290) This is set by [set_compound_head()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n806), as shown in Listing

2-5.

 

806 **static \_\_always_inline void set_compound_head**(**struct** page \*page, **struct** page \*

head)

807 {

808 **WRITE_ONCE**(page-\>compound_head, (**unsigned long**)head + 1); 809 }

 

*Listing 2-5:* include/linux/page-flags.h: [*set_compound_head()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n806)

The call stack for this is [prep_compound_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n809) which calls

[prep_compound_tail()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n801), as shown in Listing 2-6.

 

801 **static void prep_compound_tail**(**struct** page \*head, **int** tail_idx) 802 {

803 **struct** page \*p = head + tail_idx; 804

805 p-\>mapping = **TAIL_MAPPING**; 806 **set_compound_head**(p, head); 807 }

 

*Listing 2-6:* mm/page_alloc.c: [*prep_compound_tail()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n801)

 



 

Note that this sets the mapping field to the known ‘poisoned’ value

[TAIL_MAPPING](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/poison.h?h=v6.0#n34) to mark these pages as being tail pages to make them more eas-

ily identifiable when debugging.

The first tail page contains additional information on the compound

page (since a page is compound if it contains more than one of the mini-

mum page size, we know for sure there will be at least one tail page to place

this in).

We set this additional data in [prep_compound_head()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n793) which is also in-

voked by [prep_compound_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n809) which sets the compound_dtor, compound_order,

compound_mapcount, compound_pincount and compound_nr fields as shown in Listing

2-7.

 

793 **static void prep_compound_head**(**struct** page \*page, **unsigned int** order) 794 {

795 **set_compound_page_dtor**(page, COMPOUND_PAGE_DTOR); 796 **set_compound_order**(page, order); 797 **atomic_set**(**compound_mapcount_ptr**(page), -1); 798 **atomic_set**(**compound_pincount_ptr**(page), 0); 799 }

 

*Listing 2-7:* mm/page_alloc.c: [*prep_compound_head()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n793)

Note that we set the initial mapcount field to -1 to indicate that no mapping

has yet been established. Examining the setters and getters referenced here

in Listing 2-8.

 

891 **static inline void set_compound_page_dtor**(**struct** page \*page, 892 **enum** compound_dtor_id compound_dtor) 893 {

894 **VM_BUG_ON_PAGE**(compound_dtor \>= **NR_COMPOUND_DTORS**, page); 895 page\[1\].compound_dtor = compound_dtor; 896 }

 

*Listing 2-8:* include/linux/mm.h: [*set_compound_page_dtor()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n891)

The compound order is set in [set_compound_order()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n905) as shown in Listing

2-9.

 

905 **static inline void set_compound_order**(**struct** page \*page, **unsigned int** order) 906 {

907 page\[1\].compound_order = order; 908 **\#ifdef CONFIG_64BIT**

909 page\[1\].compound_nr = 1U \<\< order; 910 **\#endif**

911 }

 

*Listing 2-9:* include/linux/mm.h: [*set_compound_order()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n905)

We obtain the compound mapcount via [compound_mapcount_ptr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n309) as shown

in Listing 2-10.

 

309 **static inline atomic_t** \***compound_mapcount_ptr**(**struct** page \*page)

 



 

310 {

311 **return** &page\[1\].compound_mapcount; 312 }

 

*Listing 2-10:* include/linux/mm_types.h: [*compound_mapcount_ptr()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n309)

 

Finally, we obtain the compound pincount via [compound_pincount_ptr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n314) as

shown in Listing 2-11.

 

314 **static inline atomic_t** \***compound_pincount_ptr**(**struct** page \*page) 315 {

316 **return** &page\[1\].compound_pincount; 317 }

 

*Listing 2-11:* include/linux/mm_types.h: [*compound_pincount_ptr()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n314)

 

The order referred to here defines the number of pages compounded

together – the number of base pages contained in a compound page is equal to 2order. using a power-of-2 allows us to use a buddy allocator to efficiently

allocate (more on that later!) The maximum order is equal to [MAX_ORDER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n28)- 1 (typically 10, i.e. 210 = 1024 pages, on x86-64 this is 4 MiB).

You can see that each field being set is offset by 1 from the head page –

confirming that this data is stored in the first tail page.

We can see how these are invoked by [prep_compound_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n809) in Listing 2-12.

 

809 **void prep_compound_page**(**struct** page \*page, **unsigned int** order) 810 {

811 **int** i;

812 **int** nr_pages = 1 \<\< order; 813

814 **\_\_SetPageHead**(page); 815 **for** (i = 1; i \< nr_pages; i++) 816 **prep_compound_tail**(page, i); 817

818 **prep_compound_head**(page, order); 819 }

 

*Listing 2-12:* mm/page_alloc.c: [*prep_compound_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n809)

 

Here \_\_SetPageHead() sets a flag to indicate that the page is a head page,

before invoking the functions we have explored above. These flag options

are generated using macros, e.g. [\_\_SETPAGEFLAG()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n399) and ultimately set the flags

field in the [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) object.

The [deferred_list](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n152) field is used by the transparent huge page (see later

## chapter on this topic) logic to store individual constituent pages for deferred

processing, typically accessed via [page_deferred_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/huge_mm.h?h=v6.0#n294)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/huge_mm.h?h=v6.0#n294)

Huge pages (page sizes larger than the smallest supported page size)

must consist of a compound page so we know will have at least two tail pages

and therefore can safely reference a second tail page, as shown in Listing 2-

13.

 



 

294 **static inline struct** list_head \***page_deferred_list**(**struct** page \*page) 295 {

296 */\**

297 *\* See organization of tail pages of compound page in* 298 *\* "struct page" definition.* 299 *\*/*

300 **return** &page\[2\].deferred_list; 301 }

 

*Listing 2-13:* include/linux/huge_mm.h: [*page_deferred_list()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/huge_mm.h?h=v6.0#n294)

 

We examine this in graphical form in Figure 2-4.

 

8

 

12 unsigned long **compound_head**

 

16

unsigned char

**compound_dtor**, **compound_order**

20

atomic_t **compound_mapcount**

24

atomic_t **compound_pincount**

28

unsigned int **compound_nr**

32 struct list_head **deferred_list**

 

36

 

40

 

44

 

48

First tail page Second tail page (if huge) All other tail pages

 

*Figure 2-4:* [*Tail page*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n136) *metadata union fields*

 

Reviewing what each field is used for:

 

• compound_head – Pointer to the head page of the compound page with its

high bit set (e.g. if the head page resided at 0xf00ba100 then this value would be 0xf00ba101 and require the lower bit to be masked off). A com-

mon task for a function that takes a [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) as an argument is to check whether the page is in fact a tail page and in that case obtain its

head. This is achieved through the [compound_head()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n260) macro (more on this later!) this field allows us to determine if a page is a tail page via

[PageTail()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n290) or more generally compound via [PageCompound()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n295)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n295)

 



 

• compound_dtor – This determines the destructor for the compound

page, i.e. the function to invoke on freeing of the page. This is one of

[enum compound_dtor_id](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n878) (see Listing 2-14) which is used to index into the

[compound_page_dtors](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n410) array (see Listing 2-15) to invoke the appropriate de-

structor in [destroy_large_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n821)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n821)

 

877 */\* Keep the enum in sync with compound_page_dtors array in mm/page_alloc.c*

*\*/*

878 **enum** compound_dtor_id { 879 **NULL_COMPOUND_DTOR**, 880 **COMPOUND_PAGE_DTOR**, 881 **\#ifdef CONFIG_HUGETLB_PAGE** 882 **HUGETLB_PAGE_DTOR**, 883 **\#endif**

884 **\#ifdef CONFIG_TRANSPARENT_HUGEPAGE** 885 **TRANSHUGE_PAGE_DTOR**, 886 **\#endif**

887 **NR_COMPOUND_DTORS**, 888 };

 

*Listing 2-14:* include/linux/mm.h: [*enum compound_dtor_id*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n878)

 

We examine the compound page destructor array in Listing 2-15.

 

410 compound_page_dtor \* **const** compound_page_dtors\[**NR_COMPOUND_DTORS**\] = { 411 \[NULL_COMPOUND_DTOR\] = **NULL**, 412 \[COMPOUND_PAGE_DTOR\] = **free_compound_page**, 413 **\#ifdef CONFIG_HUGETLB_PAGE** 414 \[HUGETLB_PAGE_DTOR\] = **free_huge_page**, 415 **\#endif**

416 **\#ifdef CONFIG_TRANSPARENT_HUGEPAGE** 417 \[TRANSHUGE_PAGE_DTOR\] = **free_transhuge_page**, 418 **\#endif**

419 };

 

*Listing 2-15:* mm/page_alloc.c: [*compound_page_dtors\[\]*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n410)

 

• compound_order – As previously discussed, this defines the order of the

possibly-compound page, expressed as a power-of-two – an order-1 page is 21 2 = 2 base pages in size (e.g. 8 KiB for x86-64), an order-2 page is 2 =

4 base pages in size and so on.

• compound_mapcount – A count of the number of times the compound

page as a whole has been mapped into virtual memory. This super-

sedes the \_mapcount field in any of individual [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) components of the the compound page and is referenced instead by functions such

as [compound_mapcount()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n800)[/](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n800)[folio_entire_mapcount()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n789) and [page_mapcount()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n825) if the page is compound.

• compound_pincount – When the compound page constitutes user memory

and these pages are ‘pinned’ in place (i.e. made such that they cannot

 



 

be moved or paged out, more on user pages and pinning later), this field is used to store a precise count of the number of times the compound page has been pinned.

• compound_nr – A field added for convenience in 64-bit architectures which

is equal to 2compound_order i.e. the number of base pages this compound page occupies.

• deferred_list – As described previously, this is used as part of the trans-

parent huge page functionality, see later chapter on this topic.

 

**2.1.1.3 Page table pages**

Page tables (see later chapter on this topic) require a lock to synchronise

changes, and typically it is efficient to ‘split’ these locks at the lowest two

page table levels (designated ‘PTEs’ and ‘PMDs’ – we go into more detail

on what these mean in the next chapter) so there are separate locks for each

individual page. Additionally there are some huge page and architecture-

specific metadata that is convenient to store in the essentially ‘free’ data

store that is a [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) in use. Examining the struct as shown in Listing

2-16.

 

**N O T E** Note as with the [*struct page*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) code listing we are assuming [*ALLOC_SPLIT_PTLOCKS*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types_task.h?h=v6.0#n25) is not

set which is the case for modern 64-bit architectures as this parameter is determined

by whether the spinlock size exceeds the number of bytes in an *unsigned long* which

will not be the case unless lock debugging is configured.

 

154 **struct** { */\* Page table pages \*/* 155 **unsigned long** \_pt_pad_1; */\* compound_head \*/* 156 **pgtable_t** pmd_huge_pte; */\* protected by page-\>ptl \*/* 157 **unsigned long** \_pt_pad_2; */\* mapping \*/* 158 **union** { 159 **struct** mm_struct \*pt_mm; */\* x86 pgds only \*/* 160 **atomic_t** pt_frag_refcount; */\* powerpc \*/* 161 };

. . .

165 **spinlock_t** ptl;

. . .

167 };

 

*Listing 2-16:* include/linux/mm_types.h: [*Page table*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n154) *metadata union struct*

 

Note that the padding in this struct ensures the tail page bit in

compound_head is clear so [PageTail()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n290) will return false, and as a non-tail page

efforts space is left to ensure the mapping field from the page cache struct is

null (you will note that the metadata union structs each go to pains to en-

sure this is the case – the [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) will be zeroed other than fields in use).

Similarly, where the [mapping](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n104) would be for the anonymous/page cache entry

is kept zeroed to avoid mistaking the page for either an anonymous or page

cache one.

 



 

Considering each field:

 

• pmd_huge_pte – This is used by the transparent hugepage functionality

(see later chapter on this topic) to tie a potentially huge PMD to an un-

derlying fallback PTE. Its type is pgtable_t which for [x86-64](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n488) and [arm64](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/arm64/include/asm/page.h?h=v6.0#n42) is

typedef’d to a [struct page\*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72). If USE_SPLIT_PMD_PTLOCKS is set (typically the

case, see below) then [pmd_huge_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2358) references this field.

• pt_mm – This is used by the x86 architecture to store a pointer from the

PGD page table to its relevant [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) (more on this later!)

• pt_frag_refcount – This is a PowerPC-specific field (for sake of brevity I

examine only x86-64 in this book).

• ptl – This lock is used for PTE page tables when [USE_SPLIT_PTE_PTLOCKS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types_task.h?h=v6.0#n22)

is set (when the maximum number of cores defined by CONFIG_NR_CPUS, which typically defaults to at least 64, is greater than or equal to CONFIG_SPLIT_PTLOCK_CPUS , which typically defaults to 4, so this is almost certainly the case for any modern system) and used for PMD page ta-

bles when [USE_SPLIT_PMD_PTLOCKS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types_task.h?h=v6.0#n23) is set (when USE_SPLIT_PTE_PTLOCKS and CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK are set which is typically the case), otherwise a shared lock is used.

 

We examine this in graphical form in Figure 2-5.

 

8

 

12

 

16

 

20 pgtable_t **pmd_huge_pte**

 

24

 

28

 

32

 

36 struct mm_struct \***pt_mm** atomic_t **pt_frag_refcount**

 

40

 

44 spinlock_t **ptl**

 

48

x86-64 PowerPC Other architectures

 

*Figure 2-5:* [*Page table*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n154) *metadata union struct*

 



 

**2.1.1.4 Other metadata**

There are additional structs contained in the [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) metadata union

that are very specific and less core to the functioning of the physical mem-

ory allocator so I won’t go over them in detail, however for completeness

let’s examine them, starting with the [page_pool](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n114) metadata union struct as

shown in Listing 2-17.

 

114 **struct** { */\* page_pool used by netstack \*/* 115 */\*\** 116 *\* @pp_magic: magic value to avoid recycling non* 117 *\* page_pool allocated pages.* 118 *\*/* 119 **unsigned long** pp_magic; 120 **struct** page_pool \*pp; 121 **unsigned long** \_pp_mapping_pad; 122 **unsigned long** dma_addr; 123 **union** { 124 */\*\** 125 *\* dma_addr_upper: might require a 64-bit* 126 *\* value on 32-bit architectures.* 127 *\*/* 128 **unsigned long** dma_addr_upper; 129 */\*\** 130 *\* For frag page support, not supported in*

131 *\* 32-bit architectures with 64-bit DMA.* 132 *\*/* 133 **atomic_long_t** pp_frag_count; 134 }; 135 };

 

*Listing 2-17:* include/linux/mm_types.h: [*page_pool*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n114) *metadata union struct*

 

We examine the [page_pool](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n114) metadata union struct in graphical form in

Figure 2-6.

 



 

8

 

12 unsigned long **pp_magic**

 

16

 

20 struct page_pool **\*pp**

 

24

 

28

 

32

 

36 unsigned long **dma_addr**

 

40

 

44 unsigned long **dma_addr_upper** atomic_long_t **pp_frag_count**

 

48

32-bit architecture 64-bit architecture

 

*Figure 2-6:* [*page_pool*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n114) *metadata union struct*

 

Note that pp_magic maintains clear lower bits to ensure it isn’t misidenti-

fied as a compound tail page via [PageTail()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n290) and equally the mapping offset is kept zeroed to ensure that the page is not inadvertently mistaken for a page cache entry.

We examine the [ZONE_DEVICE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n168) metadata union struct in Listing 2-18.

 

168 **struct** { */\* ZONE_DEVICE pages \*/* 169 */\*\* @pgmap: Points to the hosting device page map. \*/*

170 **struct** dev_pagemap \*pgmap; 171 **void** \*zone_device_data; 172 */\** 173 *\* ZONE_DEVICE private pages are counted as being*

174 *\* mapped so the next 3 words hold the mapping, index,*

175 *\* and private fields from the source anonymous or*

176 *\* page cache page while the page is migrated to*

*device*

177 *\* private memory.* 178 *\* ZONE_DEVICE MEMORY_DEVICE_FS_DAX pages also* 179 *\* use the mapping, index, and private fields when*

 



 

180 *\* pmem backed DAX files are mapped.* 181 *\*/* 182 };

 

*Listing 2-18:* include/linux/mm_types.h: [*ZONE_DEVICE*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n168) *metadata union struct*

 

We examine the [ZONE_DEVICE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n168) metadata union struct in graphical form in

Figure 2-7.

 

8

 

12 struct dev_pagemap **\*pgmap**

 

16

 

20 void **\*zone_device_data**

 

24

 

28 struct address_space **\*mapping**

 

32

 

36 pgoff_t **index**

 

40

 

44 unsigned long **private**

 

48

 

*Figure 2-7:* [*ZONE_DEVICE*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n168) *metadata union struct*

 

While the struct defines the upper two parameters (again noting

that alignment of the pgmap pointer will ensure that lower bits are clear to

avoid misidentification of the page) the lower three are adapted from the

[Anonymous page/page cache](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n82) metadata union struct.

 

**2.1.1.5 RCU head**

Finally, the metadata union contains a [Read, Copy, Update (RCU)](https://kernel.org/doc/html/v6.0/RCU/whatisRCU.html) data struc-

ture – [struct rcu_head](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/types.h?h=v6.0#n224) – for use in freeing pages from the slab allocator effi-

ciently. This appears to be unnecessary as [struct slab](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/slab.h?h=v6.0#n9) declares this separately

and shares bits with the [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) object.

 



 

***2.1.2 struct slab***

The [struct slab](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/slab.h?h=v6.0#n9) object is declared separately from [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) and does not form part of its metadata union but is however cast to/from it, converting

from pages to slabs via [page_slab()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/slab.h?h=v6.0#n120) and back again via [slab_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/slab.h?h=v6.0#n132)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/slab.h?h=v6.0#n132) It is there-fore effectively a metadata union entry, though maintained in a separate

data structure and as per figure 2-2.

This object is used to track state relating to the kernel slab allocator

caching objects for allocation in this page, see later chapter on this topic.

I won’t dwell too long on what each field refers to as going into detail on

this is better suited to the slab chapter however, briefly, each of the three dif-ferent slab allocators (SLAB, SLUB and SLOB) typically share the following fields:

 

• slab_list – The doubly-linked list node that allows slab pages to be

placed on free lists as deemed appropriate by the specific slab algorithm used. Alignment of this field ensures the lowest bit will be clear and so it

won’t be mistaken by [PageTail()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n290) for a tail page.

• rcu_head – This forms the fundamental data structure permitting the

use of [Read, Copy, Update (RCU)](https://kernel.org/doc/html/v6.0/RCU/whatisRCU.html) for [struct slab](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/slab.h?h=v6.0#n9) objects. I will cover the specifics of this in more detail in the slab chapter. Similar to slab_list alignment ensures this won’t be mistaken for a tail page.

• slab_cache – The slab cache object this particular slab belongs to. Note

that this coincides with the anonymous page/page cache [mapping](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n104) field so we rely on alignment here to ensure the lower bits will not be set falsely indicating an anonymous or movable page.

 

We examine the [struct slab](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/slab.h?h=v6.0#n9) data structure in Listing 2-19.

 

8 */\* Reuses the bits in struct page \*/* 9 **struct** slab {

10 **unsigned long** \_\_page_flags; 11

12 **\#if defined**(**CONFIG_SLAB**)

13

14 **union** {

15 **struct** list_head slab_list; 16 **struct** rcu_head rcu_head; 17 };

18 **struct** kmem_cache \*slab_cache; 19 **void** \*freelist; */\* array of free object indexes \*/* 20 **void** \*s_mem; */\* first object \*/* 21 **unsigned int** active; 22

23 **\#elif defined**(**CONFIG_SLUB**) 24

25 **union** {

26 **struct** list_head slab_list; 27 **struct** rcu_head rcu_head;

 



 

28 **\#ifdef CONFIG_SLUB_CPU_PARTIAL**

29 **struct** {

30 **struct** slab \*next;

31 **int** slabs; */\* Nr of slabs left \*/*

32 };

33 **\#endif**

34 };

35 **struct** kmem_cache \*slab_cache;

36 */\* Double-word boundary \*/*

37 **void** \*freelist; */\* first free object \*/*

38 **union** {

39 **unsigned long** counters;

40 **struct** {

41 **unsigned** inuse:16;

42 **unsigned** objects:15;

43 **unsigned** frozen:1;

44 };

45 };

46 **unsigned int** \_\_unused;

47

48 **\#elif defined**(**CONFIG_SLOB**)

49

50 **struct** list_head slab_list;

51 **void** \*\_\_unused_1;

52 **void** \*freelist; */\* first free block \*/*

53 **long** units;

54 **unsigned int** \_\_unused_2;

55

56 **\#else**

57 **\#error** "Unexpected slab allocator configured"

58 **\#endif**

59

60 **atomic_t** \_\_page_refcount;

61 **\#ifdef CONFIG_MEMCG**

62 **unsigned long** memcg_data;

63 **\#endif**

64 };

 

*Listing 2-19:* mm/slab.h: [*struct slab*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/slab.h?h=v6.0#n9)

 

There are different slab allocators available and the structure varies

according to which one is used (and if SLUB is chosen, whether the

CONFIG_SLUB_CPU_PARTIAL configuration options is set).

We examine each class of slab allocator in turn.

 



 

**2.1.2.1 SLAB allocator**

 

0

 

4

 

8

 

12

 

16 struct list_head **slab_list** struct rcu_head **rcu_head**

 

20

 

24

 

28 struct kmem_cache **\*slab_cache**

 

32

 

36 void **\*freelist**

 

40

 

44 void **\*s_mem**

 

48

unsigned int **active**

52

Active slab page RCU freeing slab page

 

*Figure 2-8:* *CONFIG_SLAB [struct slab](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/slab.h?h=v6.0#n9)*

 

Each different allocator has slightly different fields, examining fields specific to the SLAB allocator (unfortunately slab allocation is out of scope for the book):

 

• freelist – A First In-First Out (FIFO) queue of indexes of free objects

indexing into s_mem.

• s_mem – A contiguous array of slab objects which freelist indexes into.

• active – This is a count of the number of slab objects in use (i.e. that

have been allocated from this page).

 



 

**2.1.2.2 SLUB allocator**

 

0

 

4

 

8

 

12 struct slab **\*next**

 

16 struct list_head **slab_list** struct rcu_head **rcu_head**

int **slabs**

20

 

24

 

28 struct kmem_cache **\*slab_cache**

 

32

 

36 void **\*freelist**

 

40

 

44 unsigned long **counters** = unsigned **inuse**:16, **objects**:15, **frozen**:1

 

48

 

52

Active slab page Active, per-CPU partial caches RCU freeing slab page

 

*Figure 2-9:* *CONFIG_SLUB [struct slab](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/slab.h?h=v6.0#n9)*

 

Note that the ‘active, per-CPU partial caches’ fields here are enabled by set-

ting the CONFIG_SLUB_CPU_PARTIAL configuration option.

Briefly examining each SLUB-specific field:

 

• next – (only if CONFIG_SLUB_CPU_PARTIAL is set) If the current slab object

only represents a partial portion of the overall cache, this points at the next slab.

• slabs – (only if CONFIG_SLUB_CPU_PARTIAL is set) The number of slabs in this

particular cache.

• freelist – Thread-safe accessible list of free objects.

• counters – This consists of the bitfields inuse, objects and frozen, with the

counters variable provided for convenience to enable copying all of them at once.

 



 

**2.1.2.3 SLOB allocator**

 

0

 

4

 

8

 

12

 

16 struct list_head **slab_list**

 

20

 

24

 

28

 

32

 

36 void **\*freelist**

 

40

 

44 long **units**

 

48

 

52

 

*Figure 2-10:* *CONFIG_SLOB [struct slab](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/slab.h?h=v6.0#n9)*

 

Briefly examining fields unique to the SLOB:

 

• freelist – Pointer to the first free [struct slob_block](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/slob.c?h=v6.0#n91)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/slob.c?h=v6.0#n91)

• units – If positive, indicates the size of this block, if negative indicates

the offset of the next block.

 

***2.1.3 Page flags***

Page flags describing their attributes are kept in three separate fields in

[struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72):

 



 

• [struct page-\>flags](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n73) – This field specialises any of a large number of flags

each of which are defined in [enum pageflags](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n100)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n100) There are 28 basic flags as well as additional flags which overload these.

• [struct page-\>page_type](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n201) – This field defines additional fields for non-slab,

non-user mappable pages, declared as preprocessor macros but still maintaining the same PG\_ prefix as flags fields.

• [struct page-\>mapping](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n104) – The lower two bits of this field can be set to ei-

ther [PAGE_MAPPING_ANON](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n635), [PAGE_MAPPING_MOVABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n636)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n636) or the combination of both –

[PAGE_MAPPING_KSM. ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n637)These indicate whether the page is anonymous, mov-able or part of the Kernel Samepage Merging (KSM) functionality. These of course are prefixed with the PAGE_MAPPING\_ prefix.

 

The majority of page flags and related functions are defined in the

[include/linux/page-flags.h](https://elixir.bootlin.com/linux/v6.0/source/include/linux/page-flags.h) header. Flags are accessed by test/set/clear func-

tions of the form xxxPageyyy. The majority are generated by macros, but a

few which require special handling are manually declared. Regardless they

all follow the same naming convention:

 

• **Page**xxx**()** – This is a boolean function that simply tests whether the flag

is set or not.

• **SetPage**xxx**()** – This sets the flag and guarantees this is done atomically.

• **\_\_SetPage**xxx**()** – This sets the flag but is not guaranteed to be atomic.

• **TestSetPage**xxx**()** – This sets the flag and returns the old state as a

boolean, guaranteed to be done atomically.

• **ClearPage**xxx**()** – This clears the flag and guarantees this is done atomi-

cally.

• **\_\_ClearPage**xxx**()** – This clears the flag but is not guaranteed to be atomic.

• **TestClearPage**xxx**()** – This clears the flag and returns the old state as a

boolean, guaranteed to be done atomically.

 

In most cases, flags specify a policy which performs a check on the page

and potentially transforms which page the flags are accessed on:

 

• [PF_POISONED_CHECK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n350) – Checks whether the flags field is set to a known ‘poi-

son’ value meaning that the flags are invalid via [PagePoisoned()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n302). This is always enforced and checked by all policies below in addition to their own checks.

• [PF_ANY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n353) – Can be used on any page, regardless of whether it is compound,

head or tail.

• [PF_HEAD](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n354) – Transform page to a head page if its compound or do nothing

if not via [compound_head()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n260) .

• [PF_ONLY_HEAD](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n355) – Always check to ensure this isn’t a tail page.

• [PF_NO_TAIL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n358) – Check to ensure this is not a tail page if setting/clearing.

• [PF_NO_COMPOUND](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n361) – Check to ensure it isn’t a compound page if setting/-

clearing.

 



 

• [PF_SECOND](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n364) – Always check to ensure it is a head page, accesses flags on

second page (i.e. first tail page).

 

Note that these checks are performed via [VM_BUG_ON_PGFLAGS()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmdebug.h?h=v6.0#n104) which will

only do something meaningful at runtime if CONFIG_DEBUG_VM_PGTABLE is config-ured.

We examine all available page flag helpers in Table 2-1.

 



 

Table 2-1: Page flag helpers

Test Set Clear Policy Flag PageActive SetPageActive (\_\_,Test)ClearPageActive PF_HEAD PG_active

[PageAnon](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n661) *†* - - - PAGE_MAPPING_ANON

[PageAnonExclusive](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n1018) [SetPageAnonExclusive](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n1025) ([\_\_](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n1039)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n1039)[ClearPageAnonExclusive](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n1032) PF_ANY *←* *∗∗* *∗∗* *∗∗*PG_anon_exclusive

PageBuddy*∗* *∗* *∗* \_\_SetPageBuddy \_\_ClearPageBudy - PG_buddy PageChecked SetPageChecked ClearPageChecked PF_NO_COMPOUND *←*PG_checked

[PageCompound*‡*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n295) - [ClearPageCompound](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n817)[*‡*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n817) - -PageDirty (Test)SetPageDirty (\_\_,Test)ClearPageDirty PF_HEAD PG_dirty PageDoubleMap (Test)SetPageDoubleMap (Test)ClearPageDoubleMap PF_SECOND *←*PG_double_map PageError SetPageError (Test)ClearPageError PF_NO_TAIL PG_error PageForeign SetPageForeign ClearPageForeign PF_NO_COMPOUND *←*PG_foreign PageGuard*∗* *∗* *∗* \_\_SetPageGuard \_\_ClearPageGuard - PG_guard PageHasHWPoisoned (Test)SetPageHasHWPoisoned (Test)ClearPageHasHWPoisoned PF_SECOND *←*PG_has_hwpoisoned

[PageHead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n785) *∗∗* \_\_SetPageHead (\_\_)ClearPageHead PF_ANY PG_head

[PageHeadHuge*‡*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/hugetlb.c?h=v6.0#n1871) - - - -

[PageHuge](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/hugetlb.c?h=v6.0#n1857) *‡* - - - -PageHWPoison (Test)SetPageHWPoison (Test)ClearPageHWPoison PF_ANY PG_hwpoison PageIdle SetPageIdle ClearPageIdle PF_ANY PG_idle PageIsolated SetPageIsolated ClearPageIsolated PF_ANY *←*PG_isolated

[PageKsm*†*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n691) - - - PAGE_MAPPING_KSM PageLocked \_\_SetPageLocked \_\_ClearPageLocked PF_NO_TAIL PG_locked PageLRU SetPageLRU (\_\_,Test)ClearPageLRU PF_HEAD PG_lru PageMappedToDisk SetPageMappedToDisk ClearPageMappedToDisk PF_NO_TAIL PG_mappedtodisk

[PageMappingFlags](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n651)*†* - - - PAGE_MAPPING_FLAGS PageMlocked (Test)SetPageMlocked (\_\_,Test)ClearPageMlocked PF_NO_TAIL PG_mlocked

([\_\_](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n672)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/compaction.c?h=v6.0#n113)[PageMovable](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/compaction.c?h=v6.0#n113)*†* [\_\_SetPageMovable](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/compaction.c?h=v6.0#n129)*†* [\_\_ClearPageMovable](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/compaction.c?h=v6.0#n137)[*†*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/compaction.c?h=v6.0#n137) - PAGE_MAPPING_MOVABLE PageOffline *∗* *∗* *∗* \_\_SetPageOffline \_\_ClearPageOffline - PG_offline PageOwnerPriv1 SetPageOwnerPriv1 (Test)ClearPageOwnerPriv1 PF_ANY PG_owner_priv_1 PagePinned (Test)SetPagePinned (Test)ClearPagePinned PF_NO_COMPOUND PG_pinned

[PagePoisoned*‡*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n302) - - - -PagePrivate SetPagePrivate ClearPagePrivate PF_ANY PG_private PagePrivate2 (Test)SetPagePrivate2 (Test)ClearPagePrivate2 PF_ANY PG_private_2 PageReadahead SetPageReadahead (Test)ClearPageReadahead PF_NO_COMPOUND *←*PG_readahead PageReclaim SetPageReclaim (Test)ClearPageReclaim PF_NO_TAIL PG_reclaim PageReferenced (\_\_)SetPageReferenced (\_\_,Test)ClearPageReferenced PF_HEAD PG_referenced PageReported \_\_SetPageReported \_\_ClearPageReported PF_NO_COMPOUND *←*PG_reported PageReserved (\_\_)SetPageReserved (\_\_)ClearPageReserved PF_NO_COMPOUND PG_reserved PageSavePinned SetPageSavePinned ClearPageSavePinned PF_NO_COMPOUND *←*PG_savepinned PageSkipKASanPoison SetSkipKASanPoison ClearSkipKASanPoison PF_HEAD PG_skip_kasan_poison PageSlab \_\_SetPageSlab \_\_ClearPageSlab PF_NO_TAIL PG_slab PageSlobFree SetPageSlobFree ClearPageSlobFree PF_NO_TAIL *←*PG_slob_free PageSwapBacked (\_\_)SetPageSwapBacked (\_\_)ClearPageSwapBacked PF_NO_TAIL PG_swapbacked

[PageSwapCache](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n547)*∗∗* SetPageSwapCache ClearPageSwapCache PF_NO_TAIL *←*PG_swapcache PageTable*∗* *∗* *∗* -\_\_SetPageTable \_\_ClearPageTable PG_table

[PageTail](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n290) *‡* - - - -

[PageTransCompound](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n863) *‡* - - - -

[PageTransHuge](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n847)*‡* - - - -

[PageTransTail](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n873)*‡* - - - -PageUncached SetPageUncached ClearPageUncached PF_NO_COMPOUND PG_uncached PageUnevictable SetPageUnevictable (\_\_,Test)ClearPageUnevictable PF_HEAD PG_unevictable

[PageUptodate*∗∗*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n728) [*∗∗*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n755) ( [\_\_](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n750) [)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n755) [SetPageUptodate](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n755) ClearPageUptodate PF_NO_TAIL PG_uptodate PageVmemmapSelfHosted SetPageVmemmapSelfHosted ClearPageVmemmapSelfHosted PF_ANY *←*PG_owner_priv_1 PageWaiters SetPageWaiters ClearPageWaiters PF_ONLY_HEAD PG_waiters PageWorkingset SetPageWorkingset (Test)ClearPageWorkingset PF_HEAD PG_workingset PageWriteback (Test)SetPageWriteback (Test)ClearPageWriteback PF_NO_TAIL PG_writeback PageXenRemapped SetPageXenRemapped ClearPageXenRemapped PF_NO_COMPOUND *←*PG_xen_remapped PageYoung SetPageYoung TestClearPageYoung PF_ANY PG_young

 

Key:

 



 

• (no symbol) – Denotes that the flag is stored in [struct page-\>flags](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n73) and the

function was generated by a macro.

• *∗* – Denotes that the flag is stored in [struct page-\>page_type](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n201) and the func-

tion was generated by a macro.

• *∗∗* – Denotes that the function refers to a [struct page-\>flags](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n73) flag but is

implemented manually rather than being generated by a macro.

• *†* – Denotes that the flag is stored in [struct page-\>mapping](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n104) and is imple-

mented manually rather than being generated by a macro.

• *‡* – Denotes that the function is implemented manually but has no flag

associated with it but follows the same naming convention.

• *←* – Denotes a flag that overloads an existing flag rather than having its

own bit assigned.

 

The PG_arch_1, PG_arch_2 and PG_fscache flags from [enum pageflags](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n100) do not

have functions associated with them so they were excluded from the pre-ceding table. Additionally, a number of these flags are dependent on config options being set to be available.

We will examine each flag individually, however before we do so let’s ex-

amine the key [struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) data structure.

 

**2.2 struct folio**

 

While compound pages are a useful abstraction they cause an unfortunate

ambiguity for any code working with a pointer to a [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) – you might always be dealing with an arbitrary tail page. This is a problem because com-pound page metadata is located either on the head page or one of the tail pages immediately following it.

As a result, any function that must process a struct page has historically

passed it through [compound_head()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n260) which takes a page as input and is guaran-teed to returns either the head page if it is compound or the page itself if it is not.

This is clearly suboptimal and results in functions being unintentionally

weakly typed – there is no way to know whether a function parameterised by struct page is intended to interact with head (or non-compound) pages or tail pages without examining the code carefully.

[struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) addresses these shortcomings by explicitly guaranteeing

that it is either non-compound or the head of a compound page. it is binary-compatible with struct page and can be used in place of it with the use of some wrapper functions which translate between struct page and

struct folio – [page_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n275) and [folio_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n288)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n288)

These wrapper functions are intended to be removed the kernel over

time as it moves towards using struct folio’s directly in more and more places.

The [struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) declaration also provides a wonderful description: “A folio is a physically, virtually and logically contiguous set of bytes. It

is a power-of-two in size, and it is aligned to that same power-of-two. It is at

 



 

least as large as PAGE_SIZE. If it is in the page cache, it is at a file offset which

is a multiple of that power-of-two. It may be mapped into userspace at an

address which is at an arbitrary page offset, but its kernel virtual address is

aligned to its size.”

We will examine allocation of physical memory later in this chapter and

virtual memory in the next, but suffice to say the two are aligned precisely as

described here.

We examining the [struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) data structure in Listing 2-20.

 

231 */\*\**

232 *\* struct folio - Represents a contiguous set of bytes.* 233 *\* @flags: Identical to the page flags.* 234 *\* @lru: Least Recently Used list; tracks how recently this folio was used.*

235 *\* @mlock_count: Number of times this folio has been pinned by mlock().* 236 *\* @mapping: The file this page belongs to, or refers to the anon_vma for* 237 *\** *anonymous memory.*

238 *\* @index: Offset within the file, in units of pages. For anonymous memory,*

239 *\** *this is the index from the beginning of the mmap.* 240 *\* @private: Filesystem per-folio data (see folio_attach_private()).* 241 *\** *Used for swp_entry_t if folio_test_swapcache().* 242 *\* @\_mapcount: Do not access this member directly. Use folio_mapcount() to*

243 *\** *find out how many times this folio is mapped by userspace.* 244 *\* @\_refcount: Do not access this member directly. Use folio_ref_count()* 245 *\** *to find how many references there are to this folio.* 246 *\* @memcg_data: Memory Control Group data.* 247 *\**

248 *\* A folio is a physically, virtually and logically contiguous set* 249 *\* of bytes. It is a power-of-two in size, and it is aligned to that* 250 *\* same power-of-two. It is at least as large as %PAGE_SIZE. If it is* 251 *\* in the page cache, it is at a file offset which is a multiple of that* 252 *\* power-of-two. It may be mapped into userspace at an address which is* 253 *\* at an arbitrary page offset, but its kernel virtual address is aligned* 254 *\* to its size.*

255 *\*/*

256 **struct** folio {

257 */\* private: don't document the anon union \*/* 258 **union** {

259 **struct** {

260 */\* public: \*/*

261 **unsigned long** flags; 262 **union** { 263 **struct** list_head lru; 264 */\* private: avoid cluttering the output \*/* 265 **struct** { 266 **void** \*\_\_filler; 267 */\* public: \*/*

268 **unsigned int** mlock_count; 269 */\* private: \*/*

 



 

270 }; 271 */\* public: \*/*

272 }; 273 **struct** address_space \*mapping; 274 **pgoff_t** index; 275 **void** \*private; 276 **atomic_t** \_mapcount; 277 **atomic_t** \_refcount; 278 **\#ifdef CONFIG_MEMCG**

279 **unsigned long** memcg_data; 280 **\#endif**

281 */\* private: the union with struct page is transitional \*/* 282 };

283 **struct** page page; 284 };

285 };

 

*Listing 2-20:* include/linux/mm_types.h: [*struct folio*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256)

 

This mirrors the [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) structure for anonymous/page cache pages,

and is unioned with the struct page type for convenience (this is used by

[folio_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n288)).

We examine this in graphical form in Figure 2-11.

 



 

0

 

4 unsigned long **flags**

 

8

 

12

 

16 struct list_head **lru**

unsigned int **mlock_count**

20

 

24

 

28 struct address_space **\*mapping**

**struct page** fields

32

 

36 pgoff_t **index**

 

40

 

44 unsigned long **private**

 

48

atomic_t **\_mapcount**

52

atomic_t **\_refcount**

56

 

60 unsigned long **memcg_data**

 

64

Anonymous page Page cache Page union

 

*Figure 2-11:* [*struct folio*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256)

 

As the majority of use cases of page structures are anonymous pages

or page cache pages, the folio data structure directly contains these fields

which are binary-compatible with [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) (i.e. fields are placed precisely

at the same offsets as the same fields in struct page).

Let’s examine the code of helpers which convert between [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) and

[struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) code.

[folio_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n288) and its sister function [page_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n275) are key amongst these as

they allow for the transition between [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) and [struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256)

We examine [page_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n275) in Listing 2-21.

 

262 */\*\**

263 *\* page_folio - Converts from page to folio.* 264 *\* @p: The page.*

 



 

265 *\**

266 *\* Every page is part of a folio. This function cannot be called on a* 267 *\* NULL pointer.*

268 *\**

269 *\* Context: No reference, nor lock is required on @page. If the caller* 270 *\* does not hold a reference, this call may race with a folio split, so* 271 *\* it should re-check the folio still contains this page after gaining* 272 *\* a reference on the folio.* 273 *\* Return: The folio which contains this page.* 274 *\*/*

275 **\#define page_folio**(p) (**\_Generic**((p), \\ 276 **const struct** page \*: (**const struct** folio \*)**\_compound_head**(p), \\ 277 **struct** page \*: (**struct** folio \*)**\_compound_head**(p)))

 

*Listing 2-21:* include/linux/page-flags.h: [*page_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n275)

 

We examine [folio_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n288) in Listing 2-22.

 

279 */\*\**

280 *\* folio_page - Return a page from a folio.* 281 *\* @folio: The folio.*

282 *\* @n: The page number to return.* 283 *\**

284 *\* @n is relative to the start of the folio. This function does not* 285 *\* check that the page number lies within @folio; the caller is presumed* 286 *\* to have a reference to the page.* 287 *\*/*

288 **\#define folio_page**(folio, n) **nth_page**(&(folio)-\>page, n)

 

*Listing 2-22:* include/linux/page-flags.h: [*folio_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n288)

 

As the transition from page to folio can be taken from any base page

[page_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n275) implicitly applies [\_compound_head()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n251) which is the untyped version

of [compound_head()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n260)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n260) and thus this function need only be parameterised only by the page.

[folio_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n288) is a little trickier, as the caller may either wish to access the

head page or a specific tail page. This is addressed by providing an index parameter so the caller can indicate which page is required.

As some flags are located on tail pages, it is convenient to have a helper

function which retrieves page flags located on a specific page, which is pro-

vided by [folio_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n315) as shown in Listing 2-23.

 

315 **static unsigned long** \***folio_flags**(**struct** folio \*folio, **unsigned** n) 316 {

317 **struct** page \*page = &folio-\>page; 318

319 **VM_BUG_ON_PGFLAGS**(**PageTail**(page), page); 320 **VM_BUG_ON_PGFLAGS**(n \> 0 && !**test_bit**(PG_head, &page-\>flags), page); 321 **return** &page\[n\].flags; 322 }

 



 

*Listing 2-23:* include/linux/page-flags.h: [*folio_flags()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n315)

 

Which does what you’d expect, with debug assertions to check sanity (en-

abled only if CONFIG_DEBUG_VM_PGTABLE is set). The assertions ensure that the

folio page isn’t a tail page (this would imply something had gone horribly

wrong) and if a tail page is being tested, that the head page has PG_head set

asserting that this is a compound page under examination.

The [struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) fields have the same meaning as [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) and sim-

ilarly \_mapcount and \_refcount fields should not be accessed directly but via

[folio_mapcount()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n849) and [folio_ref_count()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page_ref.h?h=v6.0#n87) respectively (though the reference

count will typically be handled by [folio_get()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1087) and [folio_put()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1122)).

Flag helpers are generated in the same way they are for struct page’s

in the [include/linux/page-flags.h](https://elixir.bootlin.com/linux/v6.0/source/include/linux/page-flags.h) header, only with the convention that

they have a folio\_ prefix rather than a Page one. Additionally policies

are not enforced in the same way, rather the macros prefix the specified

policy with FOLIO\_ and defines are set for each policy, e.g. [FOLIO_PF_ANY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n369)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n369)

This selects the appropriate page to check via folio_flags() but skips any

CONFIG_DEBUG_VM_PGTABLE checks. Examining equivalent folio prefixes:

 

• **folio_test**\_xxx**()** (equivalent of **Page**xxx**()**

• **folio_set**\_xxx**()** (equivalent of **SetPage**xxx**()**)

• **\_\_folio_set**\_xxx**()** (equivalent of **\_\_SetPage**xxx**()**

• **folio_test_set**\_xxx**()** (equivalent of **TestSetPage**xxx**()**

• **folio_clear**\_xxx**()** (equivalent of **ClearPage**xxx**()**

• **\_\_folio_clear**\_xxx**()** (equivalent of **\_\_ClearPage**xxx**()**)

• **folio_test_clear**\_xxx**()** (equivalent of **TestClearPage**xxx**()**)

 

We Examine all folio flag helpers in Table 2-2.

 



 

Table 2-2: Folio flag helpers Test Set Clear Page Flag folio_test_active folio_set_active (\_\_)folio\_(test\_)clear_active 0 PG_active

[folio_test_anon](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n656) -*†* - 0 PAGE_MAPPING_ANON folio_test_checked folio_set_checked folio_clear_checked 0 PG_checked *←* folio_test_dirty folio\_(test\_)set_dirty (\_\_)folio\_(test\_)clear_dirty 0 PG_dirty folio_test_double_map folio\_(test\_)set_double_map folio\_(test\_)clear_double_map 1 PG_double_map *←* folio_test_error folio_set_error folio\_(test\_)clear_error 0 PG_error folio_test_foreign folio_set_foreign folio_clear_foreign 0 PG_foreign *←* folio_test_has_hwpoisoned folio\_(test\_)set_has_hwpoisoned folio\_(test\_)clear_has_hwpoisoned 1 PG_has_hwpoisoned *←*

[folio_test_head](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n780)*∗∗* \_\_folio_set_head (\_\_)folio_clear_head 0 PG_head

[folio_test_hugetlb](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n829) -*‡* - 0 -folio_test_hwpoison folio\_(test\_)set_hwpoison folio\_(test\_)clear_hwpoison 0 PG_hwpoison folio_test_idle folio_set_idle folio_clear_idle 0 PG_idle folio_test_isolated folio_set_isolated folio_clear_isolated 0 PG_isolated *←*

[folio_test_ksm](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n685) -*†* - 0 PAGE_MAPPING_KSM

[folio_test_large](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n801)*∗∗* - - 0 PG_head folio_test_locked \_\_folio_set_locked \_\_folio_clear_locked 0 PG_locked folio_test_lru folio_set_lru (\_\_)folio\_(test\_)clear_lru 0 PG_lru folio_test_mappedtodisk folio_set_mappedtodisk folio_clear_mappedtodisk 0 PG_mappedtodisk

[folio_mapping_flags](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n646) -*†* - 0 PAGE_MAPPING_FLAGS folio_test_mlocked folio\_(test\_)set_mlocked (\_\_)folio\_(test\_)clear_mlocked 0 PG_mlocked

[folio_test_movable](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/migrate.h?h=v6.0#n133) - - 0 PAGE_MAPPING_MOVABLE folio_test_owner_priv_1 folio_set_owner_priv_1 folio\_(test\_)clear_owner_priv_1 0 PG_owner_priv_1 folio_test_pinned folio\_(test\_)set_pinned folio\_(test\_)clear_pinned 0 PG_pinned folio_test_private folio_set_private folio_clear_private 0 PG_private folio_test_private_2 folio\_(test\_)set_private_2 folio\_(test\_)clear_private_2 0 PG_private_2 folio_test_readahead folio_set_readahead folio\_(test\_)clear_readahead 0 PG_readahead *←* folio_test_reclaim folio_set_reclaim folio\_(test\_)clear_reclaim 0 PG_reclaim folio_test_referenced (\_\_)folio_set_referenced (\_\_)folio\_(test\_)clear_referenced 0 PG_referenced folio_test_reported \_\_folio_set_reported \_\_folio_clear_reported 0 PG_reported *←* folio_test_reserved (\_\_)folio_set_reserved (\_\_)folio_clear_reserved 0 PG_reserved folio_test_savepinned folio_set_savepinned folio_clear_savepinned 0 PG_savepinned *←* folio_test_skip_kasan_poison folio_set_skip_kasan_poison folio_clear_skip_kasan_poison 0 PG_skip_kasan_poison folio_test_slab \_\_folio_set_slab \_\_folio_clear_slab 0 PG_slab folio_test_slob_free folio_set_slob_free folio_clear_slob_free 0 PG_slob_free *←* folio_test_swapbacked (\_\_)folio_set_swapbacked (\_\_)folio_clear_swapbacked 0 PG_swapbacked

[folio_test_swapcache](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n541)*∗∗* folio_set_swapcache folio_clear_swapcache 0 *←*PG_swapcache

[folio_test_transhuge](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n853) -*‡* - 0 -folio_test_uncached folio_set_uncached folio_clear_uncached 0 PG_uncached folio_test_unevictable folio_set_unevictable (\_\_)folio\_(test\_)clear_unevictable 0 PG_unevictable

[folio_test_uptodate](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n711)*∗∗* [*∗∗*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n739) [(](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n733) [\_\_](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n733) ) [folio_mark_uptodate](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n739) folio_clear_uptodate 0 PG_uptodate folio_test_vmemmap_self_hosted folio_set_vmemmap_self_hosted folio_clear_vmemmap_self_hosted 0 PG_owner_priv_1 *←* folio_test_waiters folio_set_waiters folio_clear_waiters 0 PG_waiters folio_test_workingset folio_set_workingset folio\_(test\_)clear_workingset 0 PG_workingset folio_test_writeback folio\_(test\_)set_writeback folio\_(test\_)clear_writeback 0 PG_writeback folio_test_xen_remapped folio_set_xen_remapped folio_clear_xen_remapped 0 PG_xen_remapped *←* folio_test_young folio_set_young folio_test_clear_young 0 PG_young

 

As before the key is as follows:

 

• (no symbol) – Denotes that the flag is stored in [struct folio-\>flags](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n261) and

the function was generated by a macro.

• *∗∗* – Denotes that the function refers to a [struct folio-\>flags](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n261) flag but is

implemented manually rather than being generated by a macro.

• *†* – Denotes that the flag is stored in [struct folio-\>mapping](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n273) and is imple-

mented manually rather than being generated by a macro.

• *‡* – Denotes that the function is implemented manually but has no flag

associated with it but follows the same naming convention.

• *←* – Denotes a flag that overloads an existing flag rather than having its

own bit assigned.

 



 

Notes:

 

• As no policies are actually applied for the folio flag helpers, the policy

column is replaced with a [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) offset indicating which struct page actually contains the flags field referenced by the helper.

• No folio flag helpers refer to [struct page-\>page_type](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n201).

• [folio_mapping_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n646) (the equivalent of [PageMappingFlags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n651)) breaks the

convention of folio flag tests being prefixed with folio_test\_.

 

**2.3 Physical memory model**

 

While we have discussed [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) (and equivalently [struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) objects),

we have not explored where exactly these are kept and how they are main-

tained. How this is done is termed the [physical memory model](https://kernel.org/doc/html/v6.0/vm/memory-model.html) of a system. It

describes how struct page objects are laid out and, as this layout is designed

to represent physical memory, it is also a representation of how memory is

laid out in the system.

Converting from physical addresses (very often conveniently represented

as Page Frame Numbers (PFNs), physical addresses shifted by page size

to become an index into physical memory as if it were one giant array) to

[struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) or [struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) objects, or vice-versa, is a key task within the ker-

nel and performed whenever we need to access page metadata from an ad-

dress or vice-versa.

Doing so is achieved via the [page_to_pfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/memory_model.h?h=v6.0#n52) and [pfn_to_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/memory_model.h?h=v6.0#n53) macros whose

ultimate implementations differ depending on memory model.

There are two different memory models available – a ‘flat’ memory

model specified by CONFIG_FLATMEM and a ‘sparse’ memory model specified

by CONFIG_SPARSEMEM.

The flat memory model declares a global variable [mem_map](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n99) which is sim-

ply an array of struct page entries. There are redundant entries for mem-

ory holes and memory hot-plugging is unavailable. This is not practical in a

modern system and therefore we will not examine it any further.

The sparse memory model maintains sections which represent disparate,

‘sparse’ blocks of contiguous physical memory. The sparse memory model

can be further modified by additional configuration options:

 

• CONFIG_SPARSEMEM_VMEMMAP – Provides a virtual mapping global [vmemmap](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64.h?h=v6.0#n258) vari-

able which implements a virtual equivalent to the mem_map variable for fast implementations of page_to_pfn() and pfn_to_page(). Virtual mem-

ory is discussed in Chapter 3—briefly, it allows for physical memory to be mapped to arbitrary addresses.

• CONFIG_SPARSEMEM_EXTREME – Permits for dynamic allocation of sections (de-

scribed) below, allowing for complete flexibility in memory layout.

 

A modern system will use a sparse memory model and define both of

these configuration options so we examine only this configuration.

 



 

***2.3.1 Sections***

In a sparse memory model contiguous blocks of physical memory are repre-

sented by sections. Each section is represented by a [struct mem_section](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1424) object in a dynamically allocated (since we assume CONFIG_SPARSEMEM_EXTREME is set)

array [struct mem_section \*\*mem_section](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/sparse.c?h=v6.0#n27).

The mem_section array is two dimensional, with the first index being

termed a section root index and the second an index into the root. Each root

consists of a base page containing an array of a [SECTIONS_PER_ROOT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1455) count of

[struct mem_section](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1424) objects. More on this below.

Each section spans SECTION_SIZE_BITS SECTION_SIZE_BITS bits (therefore 2

bytes). By default this is 27 bits or 128 MiB (this is the case for

[SECTION_SIZE_BITS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/sparsemem.h?h=v6.0#n26) for x86-64 and [SECTION_SIZE_BITS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/arm64/include/asm/sparsemem.h?h=v6.0#n26) for arm64 with page size below 64 KiB).

Examining [struct mem_section](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1424) as shown in Listing 2-24 (since we assume

a sparse memory model we elide the CONFIG_PAGE_EXTENSION portion of this struct).

 

1424 **struct** mem_section {

1425 */\**

1426 *\* This is, logically, a pointer to an array of struct* 1427 *\* pages. However, it is stored with some other magic.* 1428 *\* (see sparse.c::sparse_init_one_section())* 1429 *\**

1430 *\* Additionally during early boot we encode node id of* 1431 *\* the location of the section here to guide allocation.* 1432 *\* (see sparse.c::memory_present())* 1433 *\**

1434 *\* Making it a UL at least makes someone do a cast* 1435 *\* before using it wrong.* 1436 *\*/*

1437 **unsigned long** section_mem_map; 1438

1439 **struct** mem_section_usage \*usage;

. . .

1448 */\**

1449 *\* WARNING: mem_section must be a power-of-2 in size for the* 1450 *\* calculation and use of SECTION_ROOT_MASK to make sense.* 1451 *\*/*

1452 };

 

*Listing 2-24:* include/linux/mmzone.h: [*struct mem_section*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1424)

 

The section_mem_map field contains a pointer to the [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) array and

takes advantage of the fact that it will be aligned to at least 6 bits to store

some [SECTION\_\*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1490) flags to store various attributes of the section.

The page array can be accessed via [\_\_section_mem_map_addr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1528)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1528) However, as

we are only considering systems which have CONFIG_SPARSEMEM_VMEMMAP set, we

 



 

generally have no need to access pages this way as we can simply offset into

the architecture-specific vmemmap array to access these pages.

The usage field is an [struct mem_section_usage](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1412) object which contains a

bitmap indicating whether a PFN is a valid area of memory or not (i.e.

whether we can actually use it) and flags describing page blocks contained

within the section.

 

**N O T E** A bitmap is a series of bytes which treat individual bits within the bytes as booleans

at offset equal to the bit offset.

 

Section flags stored in section_mem_map are as follows:

 

• [SECTION_MARKED_PRESENT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1518) – Indicates that a section of memory is actually

physically present in the system. This is tested by [present_section()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1535)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1535)

[present_section_nr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1540) and [pfn_in_present_section()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1653)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1653)

• [SECTION_HAS_MEM_MAP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1519) – Determines whether the section_mem_map field

actually refers to an array of [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) objects or not, i.e. whether

the section itself is valid. This is checked by [valid_section()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1545) and

[valid_section_nr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1555) and more importantly [pfn_valid()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1627)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1627)

• [SECTION_IS_ONLINE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1520) – Determines whether hotpluggable memory is actually

online and checked by [online_section()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1560) and [online_section_nr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1579)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1579)

• [SECTION_IS_EARLY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1521) – Determines whether the section is undergoing early

memory initialisation. Checked by [early_section()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1550).

• [SECTION_TAINT_ZONE_DEVICE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1523) – Used in conjunction with SECTION_IS_ONLINE

to indicate that a section is part of a ZONE_DEVICE. Checked by

[online_device_section()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1566). This topic is out of scope for the book.

 

We examine [struct mem_section_usage](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1412) in Listing 2-25.

 

1412 **struct** mem_section_usage { 1413 **\#ifdef CONFIG_SPARSEMEM_VMEMMAP** 1414 **DECLARE_BITMAP**(subsection_map, **SUBSECTIONS_PER_SECTION**); 1415 **\#endif**

1416 */\* See declaration of similar field in struct zone \*/* 1417 **unsigned long** pageblock_flags\[0\]; 1418 };

 

*Listing 2-25:* include/linux/mmzone.h: [*struct mem_section_usage*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1412)

The subsection_map field is a bitmap indicating whether a subsection is

valid, i.e. whether we are actually able to use it. A PFN can be converted

to a subsection via [subsection_map_index()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1596) and checked for validity via

[pfn_section_valid().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1602)

Each section is divided into subsections of [SUBSECTION_SIZE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1397)

bytes size [(](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1396)[SUBSECTION_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1396) bits), hard coded to 2 MiB. There are

[SUBSECTIONS_PER_SECTION](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1406) subsections in each section, assuming 27 bits section

size this results in 64 subsections per section.

Note that we track only whether a subsection is valid, not a page, so the

granularity of tracking whether pages are actually valid or not is 2 MiB. In

 



 

the early stages of memory initialisation when memory ranges are identi-fied, the entire subsection containing valid pages are marked valid.

 

***2.3.2 PFN validity***

Determining if a Page Frame Number (PFN) is valid therefore reduces to a process of determining a PFN’s section/subsection then checking this

subsection_map bitmap. This is performed by [pfn_valid()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1627) which checks valid-

ity of the section via [valid_section()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1545) and the validity of a PFN’s subsection via

[pfn_section_valid()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1602) as shown in Listing 2-26.

 

1602 **static inline int pfn_section_valid**(**struct** mem_section \*ms, **unsigned long** pfn) 1603 {

1604 **int** idx = **subsection_map_index**(pfn); 1605

1606 **return test_bit**(idx, ms-\>usage-\>subsection_map); 1607 }

 

*Listing 2-26:* include/linux/mmzone.h: [*pfn_section_valid()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1602)

We determine the subsection index within the section via

[subsection_map_index(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1596)which we use to index into the usage-\>subsection_map

field of the section as shown in Listing 2-27.

 

1596 **static inline int subsection_map_index**(**unsigned long** pfn) 1597 {

1598 **return** (pfn & ~(PAGE_SECTION_MASK)) / PAGES_PER_SUBSECTION; 1599 }

 

*Listing 2-27:* include/linux/mmzone.h: [*subsection_map_index()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1596)

Which simply finds the subsection offset by taking the lower bits of the

PFN offsetting into the section and dividing by the number of pages per sub-section.

 

***2.3.3 Converting between PFN and section***

Working with section necessitates converting between PFNs and

[struct mem_section](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1424) objects. This is achieved via a number of functions. Firstly,

[pfn_to_section_nr(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1384)which simply determines the section number, i.e. the in-dex of the section (imagining physical memory being a simple array) as

shown in Listing 2-28.

 

1384 **static inline unsigned long pfn_to_section_nr**(**unsigned long** pfn) 1385 {

1386 **return** pfn \>\> **PFN_SECTION_SHIFT**; 1387 }

 

*Listing 2-28:* include/linux/mmzone.h: [*pfn_to_section_nr()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1384)

A more useful function is [\_\_pfn_to_section()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1589) which converts a PFN di-

rectly to a [struct mem_section](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1424) object as shown in Listing 2-29.

 



 

1589 **static inline struct** mem_section \***\_\_pfn_to_section**(**unsigned long** pfn) 1590 {

1591 **return \_\_nr_to_section**(**pfn_to_section_nr**(pfn)); 1592 }

 

*Listing 2-29:* include/linux/mmzone.h: [*\_\_pfn_to_section()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1589)

This invokes [pfn_to_section_nr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1384) to obtain the PFN’s section number,

then [\_\_nr_to_section()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1475) to convert this to a struct mem_section as shown in List-

ing 2-30.

 

1475 **static inline struct** mem_section \***\_\_nr_to_section**(**unsigned long** nr) 1476 {

1477 **unsigned long** root = **SECTION_NR_TO_ROOT**(nr); 1478

1479 **if** (**unlikely**(root \>= **NR_SECTION_ROOTS**)) 1480 **return NULL**; 1481

1482 **\#ifdef CONFIG_SPARSEMEM_EXTREME** 1483 **if** (!mem_section \|\| !mem_section\[root\]) 1484 **return NULL**; 1485 **\#endif**

1486 **return** &mem_section\[root\]\[nr & **SECTION_ROOT_MASK**\]; 1487 }

 

*Listing 2-30:* include/linux/mmzone.h: [*\_\_nr_to_section()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1475)

This determines which root the section belongs to via

[SECTION_NR_TO_ROOT()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1460) (which simply divides the section number by

[SECTIONS_PER_ROOT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1455)) and looks up the section in the [mem_section\[\]\[\]](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/sparse.c?h=v6.0#n27) array by

placing this in the first index and determining the second array index via

[SECTION_ROOT_MASK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1462) which masks the lower bits.

 

***2.3.4 Page block flags***

The pageblock_flags\[\] array in [struct mem_section_usage](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1412)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1412) also termed the sec-

tion’s use map, contains flags which set attributes for page blocks contained

within the section.

It is of [SECTION_BLOCKFLAGS_BITS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1377) bits (and thus [usemap_size()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/sparse.c?h=v6.0#n311)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/sparse.c?h=v6.0#n311) bytes) in size

as shown in Listing 2-31

 

1377 **\#define SECTION_BLOCKFLAGS_BITS** \\ 1378 ((1UL \<\< (**PFN_SECTION_SHIFT**- pageblock_order)) \* **NR_PAGEBLOCK_BITS**)

 

*Listing 2-31:* include/linux/mmzone.h: [*SECTION_BLOCKFLAGS_BITS*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1377)

This essentially multiplies the number of page blocks each section

can contain by [NR_PAGEBLOCK_BITS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pageblock-flags.h?h=v6.0#n28). This latter value is the last entry in

[enum_pageblock_bits](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pageblock-flags.h?h=v6.0#n18) denoting its size as shown in Listing 2-32.

 

18 **enum** pageblock_bits {

 



 

19 PB_migrate,

20 PB_migrate_end = PB_migrate + PB_migratetype_bits - 1, 21 */\* 3 bits required for migrate types \*/* 22 PB_migrate_skip,*/\* If set the block is skipped by compaction \*/* 23

24 */\**

25 *\* Assume the bits will always align on a word. If this assumption*

26 *\* changes then get/set pageblock needs updating.* 27 *\*/*

28 **NR_PAGEBLOCK_BITS** 29 };

 

*Listing 2-32:* include/linux/pageblock-flags.h: [*enum pageblock_bits*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pageblock-flags.h?h=v6.0#n18)

 

This ‘reserves’ sufficient space for each of the migrate types declared in

[enum migratetype](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n42) as well as adding space for an additional compaction flag.

To obtain this ‘use map’ the [section_to_usemap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1470) function can be used to

simply obtains the section’s-\>usage-\>pageblock_flags field. This is, in turn,

used by [get_pageblock_bitmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n530)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n530)

This value is described as a bitmap but returns NR_PAGEBLOCK_BITS at a time

rather than single bits.

Accessing these values is performed by [get_pfnblock_flags_mask()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n580) which in

turn invokes [\_\_get_pfnblock_flags_mask()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n551) as shown in Listing 2-33.

 

550 **static \_\_always_inline**

551 **unsigned long \_\_get_pfnblock_flags_mask**(**const struct** page \*page, 552 **unsigned long** pfn, 553 **unsigned long** mask) 554 {

555 **unsigned long** \*bitmap; 556 **unsigned long** bitidx, word_bitidx; 557 **unsigned long** word; 558

559 bitmap = **get_pageblock_bitmap**(page, pfn); 560 bitidx = **pfn_to_bitidx**(page, pfn); 561 word_bitidx = bitidx / **BITS_PER_LONG**; 562 bitidx &= (**BITS_PER_LONG**-1); 563 */\**

564 *\* This races, without locks, with set_pfnblock_flags_mask(). Ensure*

565 *\* a consistent read of the memory array, so that results, even though*

566 *\* racy, are not corrupted.* 567 *\*/*

568 word = **READ_ONCE**(bitmap\[word_bitidx\]); 569 **return** (word \>\> bitidx) & mask; 570 }

 

*Listing 2-33:* mm/page_alloc.c: [*\_\_get_pfnblock_flags_mask()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n551)

 



 

This simply looks up the index within the bitmap determined by

[pfn_to_bitidx()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n540) and applies the supplied mask. Examining pfn_to_bitidx()

as shown in Listing 2-34.

 

540 **static inline int pfn_to_bitidx**(**const struct** page \*page, **unsigned long** pfn) 541 {

542 **\#ifdef CONFIG_SPARSEMEM**

543 pfn &= (**PAGES_PER_SECTION**-1); 544 **\#else**

545 pfn = pfn -**round_down**(**page_zone**(page)-\>zone_start_pfn,

pageblock_nr_pages);

546 **\#endif** */\* CONFIG_SPARSEMEM \*/* 547 **return** (pfn \>\> pageblock_order) \* **NR_PAGEBLOCK_BITS**; 548 }

 

*Listing 2-34:* mm/page_alloc.c: [*pfn_to_bitidx()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n540)

 

This takes the lower bits of the PFN by masking with the lower bits of

[PAGES_PER_SECTION](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1374), shifts by pageblock order (note this order is expressed in

base pages so we neatly handle PFN being expressed in page units) and mul-

tiplies by NR_PAGEBLOCK_BITS which is the size of data we are retrieving.

 

**N O T E** As this is a power-of-2 the classic bitwise trick of simply subtracting one for all bits

below it to be set to use as a mask is applied. E.g. *0b1000*- 1 is *0b0111*.

 

These values are set by [set_pfnblock_flags_mask()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n599) which performs a similar

operation only taking care to handle data races.

An important use of the ‘use map’ is to obtain a page block’s

migrate type via [get_pageblock_migratetype()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n102) which simply invokes

[get_pfnblock_flags_mask()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n580) with [MIGRATETYPE_MASK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n100).

The compaction skip flag is also retrieved from get_pfnblock_flags_mask()

in [get_pageblock_skip()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pageblock-flags.h?h=v6.0#n71)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pageblock-flags.h?h=v6.0#n71)

 

***2.3.5 Looking up struct page/struct folio objects***

As CONFIG_SPARSEMEM_VMEMMAP is set, [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) objects (and thus [struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256)

objects) are looked up via the vmemmap global (x86-64’s [vmemmap](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_64.h?h=v6.0#n258) is simply an off-

set into the kernel’s established virtual memory map, as is arm64’s [vmemmap](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/arm64/include/asm/pgtable.h?h=v6.0#n27)).

Converting from PFN to page is achieved via [pfn_to_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/memory_model.h?h=v6.0#n53) which is a

macro that invokes [\_\_pfn_to_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/memory_model.h?h=v6.0#n25) as shown in Listing 2-35.

 

25 **\#define \_\_pfn_to_page**(pfn) (**vmemmap** + (pfn))

 

*Listing 2-35:* include/asm-generic/memory_model.h: [*\_\_pfn_to_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/memory_model.h?h=v6.0#n25)

 

Equally converting the other way, as shown in Listing 2-36.

 

26 **\#define \_\_page_to_pfn**(page) (**unsigned long**)((page) -**vmemmap**)

 

*Listing 2-36:* include/asm-generic/memory_model.h: [*\_\_page_to_pfn()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/memory_model.h?h=v6.0#n26)

 



 

These are incredibly simple as the virtual memory map has already been

set up and designed to simply be offset into, and of course this is a very effi-cient means of looking up pages.

We will speak more about virtual memory in the next chapter but

broadly it is a means by which disparate pages of physical memory can be mapped to arbitrary ‘virtual’ addresses.

 

**2.4 Nodes and Zones**

The physical layout of a computer may result in different regions of memory having different access times depending from which core they are accessed. For example consider a dual-socket machine – these typically have banks of RAM attached to each CPU socket. Accesses to memory attached to a given socket will be fast, however accesses to memory belonging to another socket will have to pass over some kind of interconnect, and will therefore be slow relative to ‘local’ memory.

In order to take this into account, the kernel subdivides cores and mem-

ory into NUMA nodes. Memory attached to a NUMA node has uniform memory access time for cores which also reside within that node.

The architecture of a real system can be complicated and intercon-

nects between different nodes can have varying ‘distances’ between them. The architecture of these can be examined on a system by invoking numactl --hardware .

Each node represents a physically contiguous range of memory, though

within that range there may be ‘holes’ (either memory that is not present at all or ranges that are reserved for devices or system).

A zone describes a physically contiguous range of memory which is cat-

egorised by that range having a distinct attribute – for example ZONE_DMA32 describes the zone over which 32-bit devices can perform Direct Memory Access (DMA) operations.

A given physical memory address belongs to one and only one zone and

one and only one node. However, zones can and typically do overlap nodes.

Each node is represented by the [pg_data_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905) type. Each of these contain an

array of [struct zone](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n515) objects which represent the portion of the zone that is present in that node.

Each zone has watermarks specified which determine reclaim (the effort to

free up, i.e. ‘reclaim’ memory) behaviour, as shown in Figure 2-12.

 



 

Free pages

 

If any zone in a node

Allocate pages that could be allocated

from at the requested

High order has free pages

Start indirect equal to or exceeding reclaim on the high water mark, all nodes indirect reclaim sleeps

Low for that node.

 

Minimum

Direct reclaim,

block until page

allocated, or OOM.

Time

 

*Figure 2-12: Zone Watermarks*

 

As seen above, when free pages in a zone pass these watermarks, then

the following happens:

 

• [WMARK_MIN](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n350) – When free base pages in the zone are at or below the sum of

WMARK_MIN and the lowmem reserve (see below) then the allocation blocks

while direct reclaim (see section 11.3 for more details) is performed – the kernel will try to free up memory sufficient to satisfy the allocation. If it cannot, an Out Of Memory (OOM) condition may arise (see the OOM chapter on this for more details).

• [WMARK_LOW](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n351) – When free base pages in the zone are at or below WMARK_LOW

the kswapd kernel process is woken up to perform indirect reclaim (see

section 11.4 for more details) to attempt to free up pages in the back-

ground for all nodes in the allocation nodemask via [wake_all_kswapds()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree//mm/page_alloc.c?h=v6.0#n4796)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree//mm/page_alloc.c?h=v6.0#n4796)

• [WMARK_HIGH](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n352) – When free base pages in any zone that could be allocated

from by the failing allocation in the node at the requested order, which had dipped below WMARK_LOW is at or above WMARK_HIGH, the kswapd process for that nodeis put to sleep.

• [WMARK_PROMO](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n353) – A watermark used in NUMA balancing memory tiering

mode. This has a very specific purpose, see the [sysctl/kernel documen-](https://kernel.org/doc/html/v6.0/admin-guide/sysctl/kernel.html#numa-balancing)

[tation](https://kernel.org/doc/html/v6.0/admin-guide/sysctl/kernel.html#numa-balancing) for more details.

 

Examining a simplified version of [pg_data_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905) stripping out all but the core

fields as shown in Listing 2-37.

 

905 **typedef struct** pglist_data { 906 */\**

907 *\* node_zones contains just the zones for THIS node. Not all of the*

908 *\* zones may be populated, but it is the full list. It is referenced*

*by*

909 *\* this node's node_zonelists as well as other node's node_zonelists.*

910 *\*/*

911 **struct** zone node_zones\[**MAX_NR_ZONES**\];

 



 

912

913 */\**

914 *\* node_zonelists contains references to all zones in all nodes.* 915 *\* Generally the first zones will be references to this node's* 916 *\* node_zones.*

917 *\*/*

918 **struct** zonelist node_zonelists\[**MAX_ZONELISTS**\]; 919

920 **int** nr_zones; */\* number of populated zones in this node \*/*

. . .

942 **unsigned long** node_start_pfn; 943 **unsigned long** node_present_pages; */\* total number of physical pages \*/* 944 **unsigned long** node_spanned_pages; */\* total size of physical page* 945 *range, including holes \*/* 946 **int** node_id;

. . .

970 */\**

971 *\* This is a per-node reserve of pages that are not available* 972 *\* to userspace allocations.* 973 *\*/*

974 **unsigned long** totalreserve_pages;

. . .

1008 **unsigned long** flags;

. . .

1015 } **pg_data_t**;

 

*Listing 2-37:* include/linux/mmzone.h: *Simplified [pg_data_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905)*

 

Each node’s pg_data_t object contains all of the struct zone objects associ-

ated with that node within it. It is often referred to as a pgdat.

Examining each of these fields:

 

• node_zones – An array of [struct zone](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n515) objects each of which describing the

portion of that zone that overlap this node. MAX_NR_ZONES is generated at build time based on kernel configuration and indicates the maximum number of zones the system supports.

• node_zonelists – An array of [struct zonelist](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n878) objects describing zones al-

locations should try to allocate from, in order. Examining it as shown in

Listing 2-38.

 

878 **struct** zonelist {

879 **struct** zoneref \_zonerefs\[**MAX_ZONES_PER_ZONELIST** + 1\]; 880 };

 

*Listing 2-38:* include/linux/mmzone.h: [*struct zonelist*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n878)

 

There are [MAX_ZONELISTS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n852) of these struct zonelist, which on a NUMA sys-

tem are [ZONELIST_FALLBACK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n844) (index 0) and [ZONELIST_NOFALLBACK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n850) (index 1). The default zonelist used is ZONELIST_FALLBACK which permits fallback to nodes other than the one requested one, The ZONELIST_NOFALLBACK option

 



 

is to support the \_\_GFP_THISNODE allocation flag, and the zonelist is chosen

by [gfp_zonelist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n167)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n167)

Examining [struct zoneref](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n859) as shown in Listing 2-39.

 

859 **struct** zoneref {

860 **struct** zone \*zone; */\* Pointer to actual zone \*/*

861 **int** zone_idx; */\* zone_idx(zoneref-\>zone) \*/*

862 };

 

*Listing 2-39:* include/linux/mmzone.h: [*struct zoneref*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n859)

 

This references [struct zone](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n515) with a zone index stored for convenience.

Accessors are provided to access these fields – [zonelist_zone()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1229) to access

the struct zone object, [zonelist_zone_idx()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1234) to access the index and for

convenience [zonelist_node_idx()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1239) provides the index of the node associ-

ated with this zone via [zone_to_nid()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1110)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1110) There are zone entries here even for zones that are not populated (a zone is populated if it contains at least one present page, i.e. a page that is within the node/zone memory range and actually allocatable).

All zones on online nodes can be iterated through via [for_each_zone()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1216)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1216) all populated zones on online nodes can be iterated through via

[for_each_populated_zone().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1221)

• nr_zones – Count of the number of populated zones in this node (zones

which have at least one present page). A zone is determined to be popu-

lated via [populated_zone()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1104).

• node_start_pfn – The Page Frame Number (PFN) of the first page

spanned by this node. Note that this might not be a present page. The

last PFN is not stored but rather deduced via [node_end_pfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1021) which in

turn invokes [pgdat_end_pfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1023) which obtains an exclusive bound by simply adding node_spanned_pages to node_start_pfn.

• node_present_pages – Determines the number of present pages, i.e. pages

that are allocatable within the node (not part of a memory hole, on-line and available). A memory hole is a range of physical memory that is unavailable for ordinary use due to either not physically existing, or being mapped to devices or reserved for systems use. Accessed via

[node_present_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1017).

• node_spanned_pages – The range of physical memory spanned by this

node, including PFNs that are not allocatable. This is accessed via

[node_spanned_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1018).

• node_id – Also known as the node’s nid, an index identifying the node.

• totalreserve_pages – Counts the number of pages reserved per-node

in order to service high priority allocations and prevent a total ex-haustion of RAM. This is determined by the vm.lowmem_reserve_ratio and vm.min_free_kbytes sysctl tunables and determined by

[calculate_totalreserve_pages().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n8607)

 



 

• flags – Specifies flags that indicate various characteristics of the node

used to modify reclaim behaviour. The bits used for the flags are de-

clared in [enum pgdat_flags](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n685):

**–** PGDAT_DIRTY – Indicates that there are an excess of dirty pages on

the node which are at the end of the LRU and thus not otherwise

queued for reclaim soon. This is set in [shrink_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n3194).

**–** PGDAT_WRITEBACK – Indicates that there are an excess of pages in write-

back (i.e. writing back their contest to disk) for the purposes of re-claim. This is also set in shrink_node().

**–** PGDAT_RECLAIM_LOCKED – Indicates that reclaim is taking place on the

node and used to prevent concurrent reclaim attempts. Set and

cleared in [node_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4808)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4808)

 

Accessing nodes is performed via the [NODE_DATA()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1186) helper function by node

index (or nid). The ID of a node can be determined via [page_to_nid()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1244) (it is

encoded into the [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) flags field).

Zones are described by [enum zone_type](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n420)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n420) Available zones are determined by

kernel configuration but for a modern 64-bit system typically consist of:

 

• ZONE_DMA – On the x86-64 architecture this spans the range a museum-

worthy legacy device is able to perform Direct Memory Access (DMA) upon (DMA is a means by which hardware can transfer data to/from memory independently of the CPU). For a typical x86-system this spans the first 24 bits of memory, i.e. 16 MiB. However, for other architec-tures, notably arm64, this may span all of the memory aside from those put into optional zones. This is the case when devices can access mem-ory anywhere and there is no need to separate.

• ZONE_DMA32 – This spans the range a 32-bit DMA device is able to perform

DMA upon, except in the case of all physical memory (aside from those put in optional zones) residing in ZONE_DMA.

• ZONE_NORMAL – This comprises the remainder of memory not located in

other zones.

• ZONE_MOVABLE – This is a special zone that has to be enabled via the

kernelcore and/or movablecore command line parameters. The kernelcore designated memory, will exist in zones other than ZONE_MOVABLE, the re-mainder will, if it would have otherwise been placed in ZONE_NORMAL, be contained within ZONE_MOVABLE. The purpose of doing this is to maintain allocations that can be moved around by the kernel in a physically con-tiguous region rather than mixing movable and unmovable memory together. This helps reduce fragmentation and improves the availability of higher order pages.

 

Examining a simplified version of [struct zone](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n515) stripping out all but the

core fields as shown in Listing 2-40.

 

515 **struct** zone {

516 */\* Read-mostly fields \*/* 517

 



 

518 */\* zone watermarks, access with \*\_wmark_pages(zone) macros \*/* 519 **unsigned long** \_watermark\[**NR_WMARK**\]; 520 **unsigned long** watermark_boost;

521

522 **unsigned long** nr_reserved_highatomic;

523

524 */\**

525 *\* We don't know if the memory that we're going to allocate will be*

526 *\* freeable or/and it will be released eventually, so to avoid totally*

527 *\* wasting several GB of ram we must reserve some of the lower zone*

528 *\* memory (otherwise we risk to run OOM on the lower zones despite*

529 *\* there being tons of freeable ram on the higher zones). This array*

*is*

530 *\* recalculated at runtime if the sysctl_lowmem_reserve_ratio sysctl*

531 *\* changes.*

532 *\*/*

533 **long** lowmem_reserve\[**MAX_NR_ZONES**\];

. . .

536 **int** node;

. . .

538 **struct** pglist_data \*zone_pgdat; 539 **struct** per_cpu_pages **\_\_percpu** \*per_cpu_pageset; 540 **struct** per_cpu_zonestat **\_\_percpu** \*per_cpu_zonestats; 541 */\**

542 *\* the high and batch values are copied to individual pagesets for*

543 *\* faster access*

544 *\*/*

545 **int** pageset_high; 546 **int** pageset_batch;

. . .

556 */\* zone_start_pfn == zone_start_paddr \>\> PAGE_SHIFT \*/* 557 **unsigned long** zone_start_pfn;

. . .

601 **atomic_long_t** managed_pages; 602 **unsigned long** spanned_pages; 603 **unsigned long** present_pages;

. . .

611 **const char** \*name;

. . .

632 */\* free areas of different sizes \*/* 633 **struct** free_area free_area\[**MAX_ORDER**\];

634

635 */\* zone flags, see below \*/* 636 **unsigned long** flags;

637

638 */\* Primarily protects free_area \*/* 639 **spinlock_t** lock;

 



 

. . .

677 **bool** contiguous;

. . .

680 */\* Zone statistics \*/* 681 **atomic_long_t** vm_stat\[**NR_VM_ZONE_STAT_ITEMS**\]; 682 **atomic_long_t** vm_numa_event\[**NR_VM_NUMA_EVENT_ITEMS**\]; 683 } **\_\_\_\_cacheline_internodealigned_in_smp**;

 

*Listing 2-40:* include/linux/mmzone.h: *Simplified [struct zone](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n515)*

 

Looking at each field:

 

• \_watermark – An array of [NR_WMARK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n354) watermark values expressed in base

pages for each of the watermarks – WMARK_MIN, WMARK_LOW, WMARK_HIGH and WMARK_PROMO. These should not be accessed directly but rather via

[wmark_pages(),](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n381) [min_wmark_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n378), [low_wmark_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n379) or [high_wmark_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n380).

• watermark_boost – A value which is added to watermarks in order to re-

claim early. set in [boost_watermark()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2711) with the magnitude being scaled by the vm.watermark_boost_factor tuneable. This is set when a pageblock mixes migrate types of different types and is a heuristic designed to reduce fragmentation, and therefore boost_watermark() is only set from

[steal_suitable_fallback().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2756)

• nr_reserved_highatomic – The number of pages reserved for exclusive

high-order atomic allocations.

• lowmem_reserve – Specifies the number of pages which should be held in

reserve when pages are allocated from zones other than the one speci-fied by the allocation. This is to prevent exhaustion of pages by alloca-tions which do not have to allocate pages from each zone. Discussed in

more detail below. Set in [setup_per_zone_lowmem_reserve()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n8648) and controlled by the vm.lowmem_reserve_ratio tuneable.

• node – Indicates the node ID (or nid) of the zone to which this [struct zone](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n515)

belongs. Accessed by [zone_to_nid()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1110) and set by by [zone_set_nid()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1115)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1115)

• zone_pgdat – A pointer to the [pg_data_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905) object representing the node this

zone belongs to.

• per_cpu_pageset – Pointer to a per-CPU array of [struct per_cpu_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n384)

which describes Per-CPU-Pages (or page sets) which act as a per-CPU cache of free pages to avoid locks on page allocation/freeing. See sec-

tion 2.7.3 for more details. Per-CPU arrays (with [sparse](https://kernel.org/doc/html/v6.0/dev-tools/sparse.html) tag \_\_percpu) have an entry for each core and when accessed are offset according to the

current core. Care is taken to avoid [false sharing](https://en.wikipedia.org/wiki/False_sharing) between cache lines.

• per_cpu_zonestats – Per-CPU zone statistics contained in

[struct per_cpu_zonestat](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n398) objects.

• pageset_high – The value to set each [struct per_cpu_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n384)-\>high specifying

the maximum number of base pages each page set should contain. Set

by [pageset_update()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n7135) (which is set by [\_\_zone_set_pageset_high_and_batch()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n7164)[).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n7164)

 



 

• pageset_batch – The value to set each [struct per_cpu_pages-\>batch](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n384) speci-

fying the batch size of pages to retrieve when refilling PCP lists . Set by

[pageset_update()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n7135) (which is set by [\_\_zone_set_pageset_high_and_batch()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n7164)).

• zone_start_pfn – The Page Frame Number (PFN) of the first physical base

page spanned by this zone.

• spanned_pages – The number of base pages over which this zone object

spans, e.g. zone_end_pfn - zone_start_pfn, this includes all ‘holes’ and re-served pages.

• present_pages – The number of physically available base pages – equal to

the number of spanned pages minus any unavailable pages (i.e. ‘holes’).

• managed_pages – The number of page available to the buddy allocator (this

is effectively present base pages minus reserved pages).

• name – A pointer to a string describing the zone (e.g. “ZONE_NORMAL”), taken

from the [zone_names\[\]](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n380) static array.

• free_area – Array of [struct free_area](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n105) free lists indexed by order (each

struct free_area contains per-migrate type lists of [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) ).

• flags – Flags which impact zone behaviour as defined by [enum zone_flags](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n696).

• lock – Spin lock for the zone, used for access to free lists.

• contiguous – A boolean value indicating that there are no holes in this

zone, which is used as an optimisation in [pageblock_pfn_to_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n345)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n345)

• vm_stat – Statistics for this zone.

• vm_numa_event – NUMA-specific statistics for this zone.

 

Whether a PFN is spanned by a zone can be determined via

[zone_spans_pfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n722) which simply checks whether a PFN is less than or equal to

[struct zone](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n515)-\>zone_start_pfn and less than [zone_end_pfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n717).

 

***2.4.1 Low memory reserve***

The low memory reserve mechanism is designed to prevent exhaustion of

pages in zones with fewer resources by allocations which could be serviced

by zones with more. This only comes into play if an allocation is attempted

in a particular zone but is unable to be fulfilled by that zone. If so, the allo-

cator attempts to allocate from the zone below it.

As discussed previously, a modern 64-bit system will consist of the follow-

ing zones (though ZONE_MOVABLE and ZONE_DEVICE are optional):

 

1. ZONE_DMA

2. ZONE_DMA32

3. ZONE_NORMAL

4. ZONE_MOVABLE

5. ZONE_DEVICE

 



 

This is also the order in which the zones are declared in [enum zone_type](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n420)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n420)

This means that ZONE_DMA32 sits below ZONE_NORMAL and ZONE_DEVICE sits above ZONE_MOVABLE and so on.

Therefore, an allocation designated to be taken from ZONE_MOVABLE could,

if no memory were available there, be taken from ZONE_NORMAL, ZONE_DMA32 or ZONE_DMA.

In order to decide how to apply the low memory reserve to these alloca-

tions, the tunable vm.lowmem_reserve_ratio is used. This specifies a range of integers which align with available zones. For example on my system I ob-serve:

 

\[~\]\$ sysctl vm.lowmem_reserve_ratio

vm.lowmem_reserve_ratio = 256 128 32 0 0

 

Each integer relates to each zone in ascending order, so ratios are as-

signed as shown in Table 2-3.

 

Table 2-3: Low memory zone ratios

ZONE_DMA ZONE_DMA32 ZONE_NORMAL ZONE_MOVABLE ZONE_DEVICE

1*/*256 1*/*128 1*/*32 0 0

 

Note that non-zero ratios are inverted to determine the additional re-

serve multiplier for each zone. Zero indicates no adjustment.

This is a rather confusing subject so it’s important to be clear – the ratio

we use is specified by which zone we actually end up allocating in, and is ap-plied to the sum of the managed pages of the ones we could have allocated in but did not. For example if we requested ZONE_NORMAL but ended up allocating in ZONE_DMA we will establish a reserve of 1*/*256 of the sum of managed pages in ZONE_NORMAL and ZONE_DMA32.

The heuristic is implemented this way in order for the penalty to be pro-

portional to the available pages that could have been allocated from but were not.

We visualise this in table 2-4.

 

Table 2-4: Low memory zone penalties

Actual Requested zone zone ZONE_DMA ZONE_DMA32 ZONE_NORMAL ZONE_MOVABLE ZONE_DEVICE

ZONE_DMA 1 *•/*256 1*/*256 1*/*256 1*/*256 ZONE_DMA32 1*/*128 1*/*128 1*/*128 *•*

ZONE_NORMAL 1 *•/*32 1*/*32 ZONE_MOVABLE 0 *•* ZONE_DEVICE *•*

 

The low memory reserve values can be observed in /proc/zoneinfo listed

under ‘protection’, providing low memory base page reserve counts for each requested zone sequentially, for example on my machine:

 



 

Node 0, zone DMA

managed 3977

protection: (0, 2991, 10163, 30084, 30084)

Node 0, zone DMA32

managed 765917

protection: (0, 0, 14344, 54185, 54185)

Node 0, zone Normal

managed 1836032

protection: (0, 0, 0, 159364, 159364)

Node 0, zone Movable

managed 5099663

protection: (0, 0, 0, 0, 0)

Node 0, zone Device

managed 0

protection: (0, 0, 0, 0, 0)

 

We examine summed managed pages in Table 2-5.

 

Table 2-5: Bypassed zone pages

Actual Requested zone zone ZONE_DMA ZONE_DMA32 ZONE_NORMAL ZONE_MOVABLE ZONE_DEVICE

ZONE_DMA 765,917 2,601,949 7,701,612 7,701,612 *•*

ZONE_DMA32 1,836,032 6,935,695 6,935,695 *•*

ZONE_NORMAL 5,099,663 5,099,663 *•* ZONE_MOVABLE 0 *•* ZONE_DEVICE *•*

 

If we apply the ratios we can observe the reserve page requirements in

Table 2-6.

 

Table 2-6: Reserve page requirements

Actual Requested zone zone ZONE_DMA ZONE_DMA32 ZONE_NORMAL ZONE_MOVABLE ZONE_DEVICE

ZONE_DMA 2,991 *•* 10,163 30,084 30,084 ZONE_DMA32 14,344 *•* 54,185 54,185 ZONE_NORMAL 159,364 *•* 159,364 ZONE_MOVABLE 0 *•* ZONE_DEVICE *•*

 

And you can see that these values align with those reported by

/proc/zoneinfo correctly.

These reserve values are added to the minimum watermark value as de-

termined by [\_\_zone_watermark_ok()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3968) as shown in Listing 2-59.

 

3995 */\**

3996 *\* Check watermarks for an order-0 allocation request. If these* 3997 *\* are not met, then a high-order request also cannot go ahead*

 



 

3998 *\* even if a suitable page happened to be free.* 3999 *\*/*

4000 **if** (free_pages \<= min + z-\>lowmem_reserve\[highest_zoneidx\]) 4001 **return false**;

 

*Listing 2-41:* mm/page_alloc.c: *Excerpt from [\_\_zone_watermark_ok()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3968)*

 

This is invoked by [zone_watermark_fast()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4039) – if free pages exceed this value

the allocation is not permitted as shown in Listing 2-58.

 

4060 **if** (usable_free \> mark + z-\>lowmem_reserve\[highest_zoneidx\]) 4061 **return true**;

 

*Listing 2-42:* mm/page_alloc.c: *Excerpt from [zone_watermark_fast()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4039)*

 

In both cases the lowmem_reserve\[\] value is referenced using the

highest_zoneidx value, indicating the zone that the allocation was requested at.

These page counts are established by [setup_per_zone_lowmem_reserve()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n8648)

where you can see this algorithm in action. Note that this is triggered by the

early memory setup function [init_per_zone_wmark_min()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n8804) and on changes in the

tunable via [lowmem_reserve_ratio_sysctl_handler()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n8924).

Examining setup_per_zone_lowmem_reserve() as shown in Listing 2-43.

 

8642 */\**

8643 *\* setup_per_zone_lowmem_reserve - called whenever* 8644 *\** *sysctl_lowmem_reserve_ratio changes. Ensures that each zone* 8645 *\** *has a correct pages reserved value, so an adequate number of* 8646 *\** *pages are left in the zone after a successful \_\_alloc_pages().* 8647 *\*/*

8648 **static void setup_per_zone_lowmem_reserve**(**void**) 8649 {

8650 **struct** pglist_data \*pgdat; 8651 **enum** zone_type i, j; 8652

8653 **for_each_online_pgdat**(pgdat) { 8654 **for** (i = 0; i \< **MAX_NR_ZONES**- 1; i++) { 8655 **struct** zone \*zone = &pgdat-\>node_zones\[i\]; 8656 **int** ratio = sysctl_lowmem_reserve_ratio\[i\]; 8657 **bool** clear = !ratio \|\| !**zone_managed_pages**(zone); 8658 **unsigned long** managed_pages = 0; 8659

8660 **for** (j = i + 1; j \< **MAX_NR_ZONES**; j++) { 8661 **struct** zone \*upper_zone = &pgdat-\>node_zones\[j

\];

8662

8663 managed_pages += **zone_managed_pages**(upper_zone

);

8664

8665 **if** (clear)

 



 

8666 zone-\>lowmem_reserve\[j\] = 0; 8667 **else** 8668 zone-\>lowmem_reserve\[j\] =

managed_pages / ratio;

8669 } 8670 }

8671 }

8672

8673 */\* update totalreserve_pages \*/* 8674 **calculate_totalreserve_pages**(); 8675 }

 

*Listing 2-43:* mm/page_alloc.c: [*setup_per_zone_lowmem_reserve()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n8648)

 

Here we can see that we iterate through each zone of each online node,

cumulatively summing managed pages for each zone above our own and ap-

plying the specified ratio to these as described above.

This also triggers a call to [calculate_totalreserve_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n8607) which calculates

total reserved pages combining the lowmem reserve and high watermark of

each node and zone.

 

***2.4.2 Total reserved pages***

We keep track of the total number of reserved pages within each node in

[struct pglist_data-\>totalreserve_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905) and the sum of these across all nodes

and zones in the global value [totalreserve_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n264).

What does it mean for pages to be reserved in this context? Simply that

we consider them to be unavailable for userland allocation.

These values are calculated in [calculate_totalreserve_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n8607) which is in-

voked in [setup_per_zone_lowmem_reserve()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n8648) when the vm.lowmem_reserve_ratio

tunable is changed and [\_\_setup_per_zone_wmarks()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n8677) which is invoked when

the vm.min_free_kbytes tunable is changed or memory is hot-added or hot-

removed.

We examine [calculate_totalreserve_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n8607) in Listing 2-44.

 

8603 */\**

8604 *\* calculate_totalreserve_pages - called when sysctl_lowmem_reserve_ratio* 8605 *\** *or min_free_kbytes changes.* 8606 *\*/*

8607 **static void calculate_totalreserve_pages**(**void**) 8608 {

8609 **struct** pglist_data \*pgdat; 8610 **unsigned long** reserve_pages = 0; 8611 **enum** zone_type i, j; 8612

8613 **for_each_online_pgdat**(pgdat) { 8614

8615 pgdat-\>totalreserve_pages = 0; 8616

 



 

8617 **for** (i = 0; i \< **MAX_NR_ZONES**; i++) { 8618 **struct** zone \*zone = pgdat-\>node_zones + i; 8619 **long** max = 0; 8620 **unsigned long** managed_pages = **zone_managed_pages**(zone)

;

8621

8622 */\* Find valid and maximum lowmem_reserve in the zone*

*\*/*

8623 **for** (j = i; j \< **MAX_NR_ZONES**; j++) { 8624 **if** (zone-\>lowmem_reserve\[j\] \> max) 8625 max = zone-\>lowmem_reserve\[j\]; 8626 } 8627

8628 */\* we treat the high watermark as reserved pages. \*/*

8629 max += **high_wmark_pages**(zone); 8630

8631 **if** (max \> managed_pages) 8632 max = managed_pages; 8633

8634 pgdat-\>totalreserve_pages += max; 8635

8636 reserve_pages += max; 8637 }

8638 }

8639 totalreserve_pages = reserve_pages; 8640 }

 

*Listing 2-44:* mm/page_alloc.c: [*calculate_totalreserve_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n8607)

 

We obtain the most conservative value possible – a combination of the

maximum low memory reserve described above in section 2.4.1 with the high water mark of each zone.

Recall that at the low water mark indirect reclaim is initiated (a back-

ground process which tries to ‘reclaim’, i.e. evict pages from memory, which prioritises freeing memory used to cache file data), and at the minimum wa-ter mark this is done rather more forcefully, as a blocking call.

The high water mark denotes the point at which indirect reclaim is

halted. When free memory passes through this level, nothing happens, it is only meaningful when performing reclaim (see the reclaim chapter for a detailed examination of how this functions).

However, it is a useful heuristic for a zone being in good health – if its

free pages sit above the high water mark, then no reclaim is necessary under any circumstances.

This algorithm sums the high water mark with the maximum possible

low memory zone protection – this is to account for the worst case scenario allocation in each zone, i.e. an allocation from the zone which bypasses the most pages in order to allocate from a lower one.

 



 

**2.5 Migrate types**

 

Within the kernel physical memory is subdivided into node, zone, order and

migrate type. Nodes divide memory by memory locality (i.e. whether access-

ing some memory involves obtaining it from a long ‘distance’), zones divide

memory by memory range, which can be of critical importance to hardware

(if a device cannot DMA to/from memory allocated for that purpose it’s use-

less) or meaningful for the purposes of grouping like allocations together (as

is the case for ZONE_MOVABLE and ZONE_DEVICE). Order determines the amount of

physically contiguous memory allocated. But what about migrate type?

Migrate types, as the name implies, categorises pages based on their mo-

bility. Some memory is able to be moved, some is able to be reclaimed and

some is entirely unmovable. What does ‘moving’ memory in this context

mean? When memory is virtually mapped (more on this in the next chap-

ter), users of the memory are oblivious to the actual physical pages being

referenced. As a result, these mappings can be moved around by the kernel

(termed migration, covered in detail in the chapter on this subject).

These three cases form the fundamental migrate types, though there are

additional types for specific use case. These are defined by [enum migratetype](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n42)[:](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n42)

 

• MIGRATE_UNMOVABLE – These pages cannot be migrated at all. This is typ-

ically the case for kernel allocations which are accessed essentially di-rectly indexed by their physical address and thus no abstraction exists to permit page movement.

• MIGRATE_MOVABLE – These pages can be migrated without restriction. Typi-

cally the case for userland allocations.

• MIGRATE_RECLAIMABLE – Rather confusingly this refers specifically to slab-

allocated memory that is otherwise unmovable but might be shrunk un-der memory pressure by invoking ‘page shrinkers’ to remove unused

pages. This is typically specified by the [SLAB_ACCOUNT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/slab.h?h=v6.0#n104) flag when invoking

[kmem_cache_create().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/slab_common.c?h=v6.0#n387)

• MIGRATE_HIGHATOMIC – A special migrate type used to reserve memory for

atomic allocations (ones that are performed in an uninterruptible state) of higher order.

• MIGRATE_CMA – These pages are used for allocating memory using the Con-

tiguous Memory Allocator (CMA). This mechanism reserves memory early in boot which is then added back to the buddy allocator under MIGRATE_CMA. These pages can be used for MIGRATE_MOVABLE allocations or CMA-specific ones but nothing else. This way, pages can be moved as necessary to provide physically contiguous blocks of memory on de-mand. The details of how CMA is implemented are out of scope for this book.

• MIGRATE_ISOLATE – Pages marked with this migrate type are not permit-

ted to be allocated at all. This is used by the CMA mechanism early on to transfer memory from other migrate types to MIGRATE_CMA, as well as memory hot-plugging. The details of this are out of scope for this book.

 



 

The purpose of categorising memory in this way is in furtherance of the

never ending and inevitably heuristic quest to reduce memory fragmenta-tion. In the context of a buddy allocator (as described in the last chapter), we coalesce smaller pages into larger ones when they are freed. If we find that allocated memory sits between blocks that could otherwise be coalesced with their buddies and those pages are movable, we can migrate them.

However, if we mix movable and unmovable pages together, we can end

up in painful situations where this fragmentation prevents us from being able to do so. Equally, for slab allocations which are otherwise unmovable, we can shrink memory freeing up contiguous space which can then be coa-lesced. Again if unmovable pages sit between shrinkable memory our ability to do so is impeded.

It is therefore sensible to group these different migrate types together.

The kernel does this by assigning migrate types to page blocks. These are con-

tiguous blocks of physical memory of order [pageblock_order](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pageblock-flags.h?h=v6.0#n36) which is typically order-9 (i.e. 2 MiB of memory). These blocks are naturally aligned, so are able to be coalesced to page block order.

How is this actually implemented in the kernel? All free lists are subdi-

vided by migrate type (more on free lists later) and allocations will specify which migrate type is required (more on this later also), and so pages can be allocated for the desired migrate type.

The migrate type of a page is determined via [get_pageblock_migratetype()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n102)

which looks up the migrate type assigned to a page block (see section 2.3.4 for details of how and where this is stored). This is used when freeing pages to know which free lists to place them in. This is not the case for Per-CPU-Page (PCP) lists which stores migrate type separately for fast access, but PCP pages derive their migrate type from the page block in the first instance. See

section 2.7.3 for more details on this.

During early boot all available page blocks are marked MIGRATE_MOVABLE

by [memmap_init_zone_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n6942) which invokes [memmap_init_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n6701) and finally

[set_pageblock_migratetype()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n625) which actually sets this.

When allocations are attempted but no pages exist of the required

migrate type, migrate type stealing occurs. This is where free pages are taken from another migrate type and placed in the free list of the re-quired migrate type to be able to fulfil the request. This is implemented in

[\_\_rmqueue_fallback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2998). This is covered in section 2.8.6 in considerable detail.

\_\_rmqueue_fallback() will try to fallback to another migrate type as

specified by a list of fallbacks in priority order of mergeable migrate

types as determined by [find_suitable_fallback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2838) (only unmovable, mov-able and reclaimable migrate types are mergeable – as specified by

[migratetype_is_mergeable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n89)).

Crucially, except in one very specific case, this effort will try to steal the

largest order page possible. This helps reduce fragmentation by reducing the degree to which these efforts will cause page blocks to end up mixing up migrate types.

The fact we are able to ‘steal’ pages from other migrate types means it

is possible for a page block to contain a mix of migrate types. This is un-

 



 

desirable but sometimes necessary under memory pressure. As a result,

[get_pageblock_migratetype()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n102) is merely heuristic and a page block’s migrate

type is set to the migrate type most represented within the page block. Note

that if migrate type fragmentation occurs, watermarks are subject to a boost,

reserving more pages in order to offset the increased fragmentation.

Importantly, the fact that this stealing mechanism attempts to steal the

largest possible order page from another migrate type means it is often the

case that page block order pages or above can be stolen, which are then sim-

ply reassigned to the required migrate type. This means that during early

allocations of the buddy allocator page blocks can be transferred from the

default of MIGRATE_MOVABLE to other migrate types as required without incur-

ring fragmentation (once one higher order page is transferred it can be split

into smaller pages as needed).

Also it’s important to note that [can_steal_fallback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2690) will simply permit

page blocks to be transferred from one type to another if the target migrate

type is MIGRATE_RECLAIMABLE or MIGRATE_UNMOVABLE. As both of these cannot be

migrated (MIGRATE_RECLAIMABLE pages can only be shrunk relative to one an-

other), so stealing actually migratable pages that could otherwise later be

coalesced together is considered more of a sin than simply taking a whole

block at a time.

There couldn’t be a greater example of how migrate types are a heuristic

mechanism for the reduction of fragmentation which is itself by its nature a

heuristic task.

 

**2.6 GFP flags**

 

When allocating memory GFP (‘Get Free Pages’) flags are used to specify

how memory is to be allocated. All kernel allocations must specify these

flags which are defined in the [include/linux/gfp.h](https://elixir.bootlin.com/linux/v6.0/source/include/linux/gfp.h) header.

The flags are comprised of a series of modifiers which are prefixed with

\_\_GFP e.g. \_\_GFP_DMA, and useful combinations which are prefixed GFP\_, e.g.

GFP_KERNEL. The flags can be bitwise-or combined as needed. The kernel di-

vides modifiers into different categories, which we will examine in turn.

 

***2.6.1 Physical address zone modifiers***

These specify which zone the allocation should originate from:

 

• \_\_GFP_DMA – Indicates that the allocation should originate from ZONE_DMA.

• \_\_GFP_HIGHMEM – Indicates that the allocation should originate from

ZONE_HIGHMEM. Not relevant for 64-bit systems.

• \_\_GFP_DMA32 – Indicates that the allocation should originate from

ZONE_DMA32.

 

The GFP_ZONEMASK values provides a mask for all of these values in ad-

ditional to \_\_GFP_MOVABLE which indicates that a page can be placed in

ZONE_MOVABLE, if configured and available.

 



 

**N O T E** *ZONE_MOVABLE* is a zone that exists if the *kernelcore* and/or *movablecore* command

line parameters are specified which provides a physically contiguous range of memory where movable pages can be placed.

 

***2.6.2 Page mobility and placement hints***

These flags indicate how mobile pages can be (e.g. to what degree the kernel can move them around):

 

• \_\_GFP_MOVABLE – Indicates that the page should have a migrate type of

MIGRATE_MOVABLE (determined by [gfp_migratetype()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n16)) and whose pages can be moved by the kernel as needed (the process of moving underlying pages of memory is termed migration). Additionally, it indicates that if ZONE_MOVABLE spans sufficient pages memory can be allocated from this zone. This flag straddles both the mobility and zone modifier cat-egories.

• \_\_GFP_RECLAIMABLE – Indicates that the page should have a migrate type

of MIGRATE_RECLAIMABLE (again, determined by gfp_migratetype()). For slab allocations it refers to memory which has the SLAB_RECLAIM_ACCOUNT flag set which can have unused pages freed via ‘shrinkers’ on reclaim (not to be confused with \_\_GFP_RECLAIM). More on that in the slab chapter.

• \_\_GFP_WRITE – A hint indicating that file-backed memory will be

written to. This is a placement hint as it sets the spread_dirty_pages flag in the allocation context (more on allocation context later) in

[prepare_alloc_pages() . ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5297)This will be used to distribute potentially dirty pages amongst nodes in order that no node has its dirty page limit exceeded (dirty pages are pages that have changes which need to be flushed back to disk). This is only respected on the allocator’s fast path, if no node is available with a sufficiently low dirty page count, then this flag will be ignored.

• \_\_GFP_HARDWALL – A hint indicating that the process’s cgroup cpuset.mems

setting should be honoured, i.e. that allocations should occur on the specified nodes only (cpusets are a feature of cgroups which allows users

to limit processes to specific CPUs and memory nodes). See the [cgroup](https://kernel.org/doc/html/v6.0/admin-guide/cgroup-v2.html#cpuset-interface-files)

[v2 admin guide on cpuset settings](https://kernel.org/doc/html/v6.0/admin-guide/cgroup-v2.html#cpuset-interface-files). This is set in [prepare_alloc_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5297)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5297) Note that cgroups are out of scope for the book.

• \_\_GFP_THISNODE – Strictly requires that pages must be allocated from the

requested node. This is used in [gfp_zonelist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n167) to restrict available zones to those only on the specified node.

• \_\_GFP_ACCOUNT – Indicates that, if the cgroups kmemcg controller is en-

abled, this page should be ‘charged’ to it, and if not permitted by the controller to allocate then no allocation will occur. Referenced directly

in [\_\_alloc_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5513).

 



 

***2.6.3 Watermark modifiers***

These flags determine how watermark limits are enforced on allocation and

relatedly how zone emergency reserves can be made us of:

 

• \_\_GFP_ATOMIC – This indicates that the caller can’t sleep (and as a result

direct reclaim) due to being in an atomic context such as an interrupt handler. A number of tweaks are performed on allocation to suit this scenario.

• \_\_GFP_HIGH – This indicates that the allocation is high-priority and must

be performed in order for the system to make forward progress. This will reduce watermarks making more reserved memory available to allo-cators, as \_\_GFP_HIGH implies the allocator flag ALLOC_HIGH.

• \_\_GFP_MEMALLOC – This is an extreme flag to use as it makes all memory

within a zone available for allocation regardless of watermarks. It is in-tended for cases where the caller knows that memory is on the verge of being made available immediately after this allocation. This flag should generally only be used by the memory manager subsystem internally as it risks exhausted memory entirely otherwise.

• \_\_GFP_NOMEMALLOC – Expressly forbids access to emergency memory re-

serves altogether. Overrides \_\_GFP_MEMALLOC if both flags are set.

 

***2.6.4 Reclaim modifiers***

These flags indicate what reclaim can be performed on allocation:

 

**N O T E** Reclaim is the process by which physical memory is reclaimed by discarding file-

backed pages and swapping out to disk, discussed in far more detail in Chapter 11.

 

• \_\_GFP_IO – Indicates that I/O may be performed. This is used by the re-

claim logic in [may_enter_fs()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1570) – if the memory is in the swap buffer (see later chapters on this) and \_\_GFP_FS is not set. It is also used in com-paction logic (again, see the chapter on this) to determine if I/O can

be performed during this process, as checked in [try_to_compact_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/compaction.c?h=v6.0#n2571)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/compaction.c?h=v6.0#n2571) Clearing this flag is used when no I/O at all can be permitted. Will typi-cally be used via the helper flag GFP_NOIO.

• \_\_GFP_FS – Indicates that low-level filesystem calls should be performed

(whether I/O is performed at all is determined by \_\_GFP_IO). This is typ-ically cleared when filesystem locks are acquired and an allocation re-sulting in filesystem operations might cause deadlock. This is used in re-

claim via the [may_enter_fs()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1570) check – if \_\_GFP_FS is set, then this is set true unconditionally. Will typically be invoked via the helper flag GFP_NOFS.

• \_\_GFP_DIRECT_RECLAIM – Indicates that direct reclaim can be performed –

this is where, under severe memory pressure, the allocator tries to re-claim memory immediately upon allocation. This should be cleared if failing to allocate is acceptable (e.g. there are fallback options). Direct

 



 

reclaim might sleep. If this flag is cleared then the OOM killer will not

be invoked (checked in [\_\_alloc_pages_slowpath()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015), see the reclaim chapter for more on this).

• \_\_GFP_KSWAPD_RECLAIM – Indicates that indirect reclaim can be performed by

the kswapd kernel thread when the low watermark level is reached for a zone. See the reclaim chapter for more details.

• \_\_GFP_RECLAIM – A helper flag which can be used to determine whether

reclaim is set at all or to enable/disable reclaim altogether. Equal to \_\_GFP_DIRECT_RECLAIM \| \_\_GFP_KSWAPD_RECLAIM.

• \_\_GFP_RETRY_MAYFAIL – If a page has a costly order (i.e. has order greater

than [PAGE_ALLOC_COSTLY_ORDER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n40)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n40) then we typically don’t retry a direct re-claim attempt. This overrides this behaviour. Additionally, if set, the

OOM killer will not be invoked (checked in [\_\_alloc_pages_may_oom()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4381)).

• \_\_GFP_NORETRY – Only attempt to direct reclaim once then give up, even if

forward progress could have been made in another attempt. This also does not invoke the OOM killer if insufficient memory is available to satisfy the request.

• \_\_GFP_NOFAIL – A drastic flag that should be used with great care, this

does the diametric opposite of \_\_GFP_NORETRY and direct reclaim instead loops indefinitely until a page is successfully obtained. Sanity prevails in that a kernel warning will be generated if you attempt this with pages of order 2 or greater.

 

***2.6.5 Action modifiers***

Action modifiers either enable or disable specific actions taken by the alloca-tor:

 

• \_\_GFP_NOWARN – Prevent the kernel from outputting warnings about allo-

cation failures, most pertinently in [warn_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4335). Typically used when performing allocations for which their are fallbacks or otherwise whose failures are not abnormal events.

• \_\_GFP_COMP – Indicates that, if the allocation is of greater than order 0, the

page should be configured to be compound via [prep_compound_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n809)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n809)

• \_\_GFP_ZERO – After allocating a page, zero the memory. Used in e.g.

[get_zeroed_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5605). Checked in [want_init_on_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n3051) and performed in

[post_alloc_hook()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2467) which invokes [kernel_init_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1381) to do the heavy lift-ing. If \_\_GFP_SKIP_ZERO is set this is ignored.

• \_\_GFP_ZEROTAGS – Zeros memory tags (an arm64-specific memory secu-

rity feature), ultimately implemented in [tag_clear_highpage()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/arm64/mm/fault.c?h=v6.0#n931) which is in

turn invoked by [post_alloc_hook()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2467). Only applicable if \_\_GFP_ZERO is set and \_\_GFP_SKIP_ZERO is not.

• \_\_GFP_SKIP_ZERO – If set, prevents page/tag zeroing even if the ap-

propriate GFP flags are also set. Available and relevant only if CONFIG_KASAN_HW_TAGS is set.

 



 

• \_\_GFP_SKIP_KASAN_UNPOISON – Causes KASAN to skip unpoisioning on page

allocation. KASAN is out of scope for this book. Available and relevant only if CONFIG_KASAN_HW_TAGS is set.

• \_\_GFP_SKIP_KASAN_POISON – Causes KASAN to skip poisoning on page

free. KASAN is out of scope for this book. Available and relevant only if CONFIG_KASAN_HW_TAGS is set.

• \_\_GFP_NOLOCKDEP – If lock dependency tracking is enabled (via

CONFIG_LOCKDEP) this appears to disable direct reclaim in order to avoid

lock dependency checking there in [\_\_need_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4656).

 

***2.6.6 Predefined GFP flag combinations***

Rather than specifying individual flags it is far more convenient to use a sen-

sible predefined combination of them. Examining each of these:

 

• GFP_KERNEL – \_\_GFP_RECLAIM, \_\_GFP_IO, \_\_GFP_FS – Standard kernel allocation,

both direct and indirect reclaim is permitted, as is disk I/O. May sleep.

• GFP_HIGHUSER_MOVABLE – GFP_HIGHUSER, \_\_GFP_MOVABLE, \_\_GFP_SKIP_KASAN_POISON

– The typical userland allocation which is allocated from

[do_anonymous_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4031) which invokes [alloc_zeroed_user_highpage_movable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/highmem.h?h=v6.0#n226) though more typically you have an arch-specific one, i.e. x86-

64 has [alloc_zeroed_user_highpage_movable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page.h?h=v6.0#n37) and arm64 has

[alloc_zeroed_user_highpage_movable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/arm64/mm/fault.c?h=v6.0#n915) also. These both combine this flag with \_\_GFP_ZERO to perform the zeroing. The reference to high memory is not relevant to modern 64-bit systems so is not meaningful here.

• GFP_HIGHUSER – GFP_USER, \_\_GFP_HIGHMEM – Equivalent to GFP_USER for modern

64-bit systems.

• GFP_USER – \_\_GFP_RECLAIM, \_\_GFP_IO, \_\_GFP_FS, \_\_GFP_HARDWALL – Used for allo-

cations that are typically to be accessed by both the kernel and userland (because it does not mark the memory movable). Also provides the ba-sis for flag sets for other userland allocations. Identical to kernel except that hardwall is enabled, permitting cpuset usage.

• GFP_ATOMIC – \_\_GFP_ATOMIC, \_\_GFP_HIGH, \_\_GFP_KSWAPD_RECLAIM – Allocation un-

der conditions where the caller cannot sleep (e.g. in interrupt context) but indirect reclaim is permissible and the allocation should be marked high-priority.

• GFP_KERNEL_ACCOUNT – GFP_KERNEL, \_\_GFP_ACCOUNT – Kernel allocation with

kmemcg accounting.

• GFP_NOWAIT – \_\_GFP_KSWAPD_RECLAIM – Only permits indirect reclaim, disables

I/O and filesystem access altogether on direct reclaim and is to be used when absolutely no delays can be tolerated on allocation.

• GFP_NOIO – \_\_GFP_RECLAIM – The same as GFP_KERNEL except both \_\_GFP_IO

and \_\_GFP_FS flags are not set meaning no I/O at all is permitted on di-rect reclaim. Typically this should not be used directly but rather set by

[memalloc_noio_save()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n288) and unset by [memalloc_noio_restore()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n303).

 



 

• GFP_NOFS – \_\_GFP_RECLAIM, \_\_GFP_IO – Will direct reclaim and potentially

perform I/O (and thus possibly sleep) but will not use low level filesys-tem interfaces. This is typically applicable where locks are held in the filesystem and reclaim using filesystem interfaces might deadlock. As with GFP_NOIO this should not be used directly but rather set via

[memalloc_nofs_save()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n319) and unset by [memalloc_nofs_restore()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n334).

• GFP_DMA – \_\_GFP_DMA – No reclaim whatsoever and allocate from ZONE_DMA.

Used for very legacy device memory allocation. In the case of architec-tures that place all memory only in ZONE_DMA this designation is less mean-ingful.

• GFP_DMA32 – \_\_GFP_DMA32 – No reclaim whatsoever and allocate from

ZONE_DMA32. Used for device memory allocation where the device has a 32-bit address bus width.

• GFP_TRANSHUGE_LIGHT – GFP_HIGHUSER_MOVABLE, \_\_GFP_COMP, \_\_GFP_NOMEMALLOC,

\_\_GFP_NOWARN, with \_\_GFP_RECLAIM masked – Used for Transparent Huge Page allocations (THP), see huge page chapter for more details on this. This light version attempts no reclaim and is designed to fail fast if the allocation fails.

• GFP_TRANSHUGE – GFP_TRANSHUGE_LIGHT, \_\_GFP_DIRECT_RECLAIM – Another THP

flag which additionally enables direct reclaim.

 

***2.6.7 Memalloc Flags***

It is possible to specify process-specific flags which, while they are set, ad-just allocation GFP flags. These are used for situations where the process cannot perform certain actions. The GFP modifications are applied by

[current_gfp_context()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n203) except for PF_MEMALLOC. The process flags are as follows:

 

• PF_MEMALLOC_NOIO – This clears \_\_GFP_IO and \_\_GFP_FS flags disabling all di-

rect reclaim I/O or filesystem access. Set by [memalloc_noio_save()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n288) and

restored by [memalloc_noio_restore()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n303)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n303)

• PF_MEMALLOC_NOFS – This clears \_\_GFP_FS disabling all direct reclaim

filesystem access. Set by [memalloc_nofs_save()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n319) and restored by

[memalloc_nofs_restore()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n334).

• PF_MEMALLOC_PIN – This clears \_\_GFP_MOVABLE ensuring that the migrate type

will not be MIGRATE_MOVABLE. Set by [memalloc_pin_save()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n351) and restored by

[memalloc_pin_restore().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n359)

• PF_MEMALLOC – This prevents reclaim from occurring (as checked in

[\_\_need_reclaim()) ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4656)and ignores watermarks (setting the allocation

flag ALLOC_NO_WATERMARKS in [\_\_gfp_pfmemalloc_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4876)). This is set by

[memalloc_noreclaim_save()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n339) and restored by [memalloc_noreclaim_restore()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n346).

 



 

**2.7 Buddy allocator**

 

***2.7.1 Algorithm***

The key algorithm underpinning physical memory allocation in the kernel

is a buddy allocator. This is a conceptually simple algorithm for allocating

memory in power-of-2 chunks and is able to very quickly coalesce blocks of

memory when they are freed, as described in the previous chapter on alloca-

tors.

Briefly recapping – the idea is to initially divide available memory

into the largest possible power-of-two blocks up to a maximum limit

[(MAX_ORDER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n28) - 1). The kernel’s buddy allocator allocates base pages of mem-

ory (the slab allocator allow for allocations of smaller size, see the following

## chapter on slab allocators for details on this). Each power-of-two block size is

termed the block’s order order , which equates to 2 base pages.

A separate free list is maintained for each node, zone, order and migrate

type. When memory is allocated, the allocator tries allocating from the or-

der requested. If no block is available at this size, it checks each free list for

orders greater than requested until it finds an available block. If this fails,

then different migrate types are tried (see section 2.8.6 for more details on

this).

At this point the block is split into two parts to add 2 pages to the free

list for order - 1. Each block that is split is called the buddy of the other. This

process is repeated until pages at the required order are available.

The real ‘trick’ of the buddy allocator is being able to quickly determine

the PFN of the buddy of a block given its PFN. To do this, we ensure that

each block of memory is aligned to its block size. By doing so, it becomes

very simple to determine the address of the two blocks that a larger block

was split into e.g. if the order-3 block at PFN 0b01011000 were split into two

order-2 blocks, this would result in buddies at 0b01011000 and 0b01011100.

This makes it very easy to determine a block’s ‘buddy’ in constant time

– simply flip the bit at position order, e.g. in the example given above, flip

bit 2. This would map 0b01011000 to buddy 0b01011100 and 0b01011100 to buddy

0b01011000 as expected.

Another nice property of using a buddy allocator is that we can obtain

the combined PFN of a coalesced block and its buddy by performing a bit-

wise and between them - this will clear the order bit leaving the lower of the

two addresses which now comprises both at order + 1, e.g. 0b01011100 and

0b01011000 have a combined PFN of 0b01011000.

To achieve this programmatically we need to use the exclusive or binary

operation to achieve the bit flip which is done in [\_\_find_buddy_pfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n308) as shown

in Listing 2-45.

 

307 **static inline unsigned long** 308 **\_\_find_buddy_pfn**(**unsigned long** page_pfn, **unsigned int** order) 309 {

310 **return** page_pfn ^ (1 \<\< order); 311 }

 



 

*Listing 2-45:* mm/internal.h: [*\_\_find_buddy_pfn()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n308)

 

When freeing pages, we also try to coalesce them. This is the beauty of

the buddy allocator algorithm – since each block is either of maximum or-der or has been divided into two, we simply try to coalesce with our buddy, then try to coalesce that block with its buddy and so on until we obtain the largest block possible, thereby doing the inverse of the splitting performed on allocation.

Since looking up our buddy is incredibly simple, this can be done very

quickly and the whole operation takes O(MAX_ORDER) time.

The actual process of obtaining a buddy page involves a little more effort

as shown in Listing 2-46.

 

327 **static inline struct** page \***find_buddy_page_pfn**(**struct** page \*page, 328 **unsigned long** pfn, **unsigned int** order, **unsigned long** \*

buddy_pfn)

329 {

330 **unsigned long** \_\_buddy_pfn = **\_\_find_buddy_pfn**(pfn, order); 331 **struct** page \*buddy; 332

333 buddy = page + (\_\_buddy_pfn - pfn); 334 **if** (buddy_pfn)

335 \*buddy_pfn = \_\_buddy_pfn; 336

337 **if** (**page_is_buddy**(page, buddy, order)) 338 **return** buddy; 339 **return NULL**;

340 }

 

*Listing 2-46:* mm/internal.h: [*find_buddy_page_pfn()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n327)

 

This function obtains both the buddy PFN and its [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) Note that

\_\_buddy_pfn - pfn might underflow (all values are unsigned), however this is intentional – the buddy PFN might be greater than or less than the page’s

PFN. What is key here is the invocation of [page_is_buddy()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n269) which checks that

the buddy page is actually present and available as shown in Listing 2-47.

 

256 */\**

257 *\* This function checks whether a page is free && is the buddy* 258 *\* we can coalesce a page and its buddy if* 259 *\* (a) the buddy is not in a hole (check before calling!) &&* 260 *\* (b) the buddy is in the buddy system &&* 261 *\* (c) a page and its buddy have the same order &&* 262 *\* (d) a page and its buddy are in the same zone.* 263 *\**

264 *\* For recording whether a page is in the buddy system, we set PageBuddy.*

265 *\* Setting, clearing, and testing PageBuddy is serialized by zone-\>lock.* 266 *\**

 



 

267 *\* For recording page's order, we use page_private(page).* 268 *\*/*

269 **static inline bool page_is_buddy**(**struct** page \*page, **struct** page \*buddy, 270 **unsigned int** order) 271 {

272 **if** (!**page_is_guard**(buddy) && !**PageBuddy**(buddy)) 273 **return false**;

274

275 **if** (**buddy_order**(buddy) != order) 276 **return false**;

277

278 */\**

279 *\* zone check is done late to avoid uselessly calculating* 280 *\* zone/node ids for pages that could never merge.* 281 *\*/*

282 **if** (**page_zone_id**(page) != **page_zone_id**(buddy)) 283 **return false**;

284

285 **VM_BUG_ON_PAGE**(**page_count**(buddy) != 0, buddy);

286

287 **return true**;

288 }

 

*Listing 2-47:* mm/internal.h: [*page_is_buddy()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n269)

 

Examining the logic:

 

1. Guard pages are out of scope for this chapter (and only relevant if

CONFIG_DEBUG_PAGEALLOC is set in any case) so disregarding these we start by checking whether the page is managed by the buddy page allocator via PageBuddy(). This should handle all cases of buddy pages not being available.

2. Next we check to ensure the candidate buddy page is actually of the

same order as the page whose buddy we are seeking via [buddy_order()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n237)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n237)

Buddy pages store their order in the private field of [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) and this retrieves it.

3. Finally, we ensure that the buddies do not cross a zone boundary.

 

See the previous chapter on allocators for a detailed examination of the

buddy allocator algorithm.

 

***2.7.2 Free lists***

Free lists are subdivided by node, zone, order and migrate type.

Node metadata is stored in [pg_data_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905) objects which contains per-zone

data in the [struct zone](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n515) [pg_data_t-\>node_zones\[MAX_NR_ZONES\]](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n911) field.

Each struct zone contains an array of free lists for each page order size in

the [struct free_area](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n105) struct [zone-\>free_area\[MAX_ORDER\]](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n633) field protected by the

spinlock_t lock field.

 



 

It’s important to note that one zone (which is fundamentally a physical

address range) might be subdivided into several struct zone objects, as each node’s portion of a zone will have its own object.

Examining the [struct free_area](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n105) type as shown in Listing 2-48.

 

105 **struct** free_area {

106 **struct** list_head free_list\[**MIGRATE_TYPES**\]; 107 **unsigned long** nr_free; 108 };

 

*Listing 2-48:* include/linux/mmzone.h: [*struct free_area*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n105)

 

This simply contains the heads of the free lists themselves per-migrate

type and a count of free blocks. The free lists consist of [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) objects which use the struct page-\>lru field to store list nodes.

Pages are added to free lists via via [add_to_free_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1008) and

[add_to_free_list_tail()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1018), moved to a different free list via [move_to_free_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1032)

and deleted from a free list via [del_page_from_free_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1040).

 

***2.7.3 Per-CPU free Pages (PCPs)/Pagesets***

Aside from the core free lists there is an additional ‘cache’ of per-CPU free lists for pages of lower orders to allow efficient allocation without

acquiring a lock to do so, stored in [struct per_cpu_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n384) objects in the

[struct zone-\>per_cpu_pageset](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n539) field. Per-CPU Pages are abbreviated PCPs, and the set of each CPU’s PCPs is referred to as its pageset.

Each physical allocation first tries to allocate from pageset pages, and

each free tries to free to pageset pages. These pages are essentially in limbo (they are not actually freed) and act as a cache between allocations and the actual free lists as an optimisation.

 

**N O T E** You can obtain per-zone pagestat statistics via */proc/zoneinfo*.

 

We examine the [struct per_cpu_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n384) type in Listing 2-49.

 

383 */\* Fields and list protected by pagesets local_lock in page_alloc.c \*/* 384 **struct** per_cpu_pages {

385 **spinlock_t** lock; */\* Protects lists field \*/* 386 **int** count; */\* number of pages in the list \*/* 387 **int** high; */\* high watermark, emptying needed \*/* 388 **int** batch; */\* chunk size for buddy add/remove \*/* 389 **short** free_factor; */\* batch scaling factor during free \*/* 390 **\#ifdef CONFIG_NUMA**

391 **short** expire; */\* When 0, remote pagesets are drained \*/* 392 **\#endif**

393

394 */\* Lists of pages, one per migrate type stored on the pcp-lists \*/*

395 **struct** list_head lists\[**NR_PCP_LISTS**\]; 396 } **\_\_\_\_cacheline_aligned_in_smp**;

 



 

*Listing 2-49:* include/linux/mmzone.h: [*struct per_cpu_pages*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n384)

 

This is stored in the [struct zone](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n515) type with an entry for each system

CPU. Per-CPU data is essentially an array of data (aligned to cache line

size to avoid [false sharing](https://en.wikipedia.org/wiki/False_sharing)), indexed by CPU. They are usually allocated

by [alloc_percpu()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/percpu.h?h=v6.0#n136) and referenced by [per_cpu_ptr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/percpu-defs.h?h=v6.0#n233) or, for convenience,

[this_cpu_ptr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/percpu-defs.h?h=v6.0#n265). We examine the [struct zone](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n515) per-CPU pageset field in Listing

2-50.

 

515 **struct** zone {

. . .

539 **struct** per_cpu_pages **\_\_percpu** \*per_cpu_pageset;

. . .

683 } **\_\_\_\_cacheline_internodealigned_in_smp**;

 

*Listing 2-50:* include/linux/mmzone.h: [*struct zone*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n515) *per_cpu_pageset field*

 

Entries are initialised by [build_all_zonelists_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n6605) during early boot

which uses [boot_pageset](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n6554) initially until the memory manager is initialised.

After the memory manager is initialised, [setup_zone_pageset()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n7197) is used to

allocate pagesets overriding the initial boot values via [alloc_percpu()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/percpu.h?h=v6.0#n136) and ini-

tialises them via [per_cpu_pages_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n6550) and [zone_set_pageset_high_and_batch()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n7180)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n7180)

Pagesets get populated if the page order is not too costly on free (see

next section on freeing where we go into more detail), up to and including

order of [PAGE_ALLOC_COSTLY_ORDER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n40)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n40) which is currently set to 3, meaning that

pages of order-0, order-1, order-2 and order-3 can form part of pagesets.

[pcp_allowed_order()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n753) is used to determine whether a page order is permitted

in a PCP.

[NR_PCP_LISTS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n369) specifies the number of lists per pageset, which is equal to

the number of migrate types which are permitted on PCPs, [MIGRATE_PCPTYPES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n46)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n46)

multiplied by PAGE_ALLOC_COSTLY_ORDER + 1 (i.e. the count of orders sup-

ported), plus NR_PCP_THP which is set to 1 if CONFIG_TRANSPARENT_HUGEPAGE is set.

This provides free lists for all supported migrate types and page orders (plus

an additional ‘order’ for transparent huge pages, more on this in the chapter

on huge pages). Examining each field:

 

• lock – Lock to protect the lists field typically acquired via

[pcp_spin_lock_irqsave()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n209) or [pcp_spin_trylock_irqsave()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n212) and released

by [pcp_spin_unlock_irqrestore()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n218)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n218) Note that we disable IRQs because

[free_pcppages_bulk()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1535) requires it (see the comment in [drain_zone_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3168) for more explanation).

• count – This is a simple count of the number of base pages in the page-

set (when a page is freed to/allocated from a pageset, the count field is incremented/decremented by 2order).

• high – Indicates the high watermark of pages permitted to be on this

pageset. If exceeded, pages are drained back to the ordinary free lists.

This value is not read directly but rather via [nr_pcp_high()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3417) which either returns the high value, or a lesser value depending on whether the zone

 



 

is undergoing reclaim/too many higher order pages are present on the

pageset. Updated by [pageset_update()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n7135). This is set either to a default— the zone ‘low watermark’, which is the number of free pages allowed in a zone before reclaim starts, divided by the number of CPUs— via

[zone_highsize()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n7071) or via the vm.percpu_pagelist_high_fraction tunable.

• batch – Determines the minimum number of base pages to allocate

into a list for a specific migrate type/order when it is empty, and how many base pages to free back to free lists when the high watermark is exceeded. The actual number of pages to allocate is determined by

[\_\_rmqueue_pcplist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3738) and to free back by [nr_pcp_free()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3388). This field is set by

[zone_batchsize()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n7023) to the smaller of 1 MiB/0.1% of the managed pages of the zone.

• free_factor – A value which is divided by 2 on allocation from a pageset

and multiplied by 2 on pages being freed to a pageset. batch is multiplied by 2free_factor when freeing pageset pages back to the free lists. If this value is greater than zero, then we always free pages back to free lists when freeing an order-1 or greater page to a pageset to reduce higher order fragmentation. See the following section for more details on this. This is a form of exponential back-off.

• expire – This field is used by [refresh_cpu_vm_stats()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmstat.c?h=v6.0#n819) to drain a batch of

pagesets for remote zones (i.e. on node in which the core executing the refresh does not reside) after a delay.

• lists – Contains PCP free lists for every supported migrate type and or-

der. The lists are of [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) objects tied together using their lru field.

 

**2.8 Allocator implementation**

 

***2.8.1 Visualising the allocator***

The functions which ultimately invoke the physical page allocator are as

follows. The key function underlying the allocator is [\_\_alloc_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5513)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5513) with

[\_\_alloc_pages_bulk()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5360) being a version of the same logic designed for efficient

allocation of multiple pages in bulk as shown in Figure **??**.

 



[get_zeroed_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5605) [alloc_pages_exact()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5808)

 

[folio_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mempolicy.c?h=v6.0#n2278) [alloc_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n286) [\_\_get_free_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5594) [kmalloc_order()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/slab_common.c?h=v6.0#n924)

 

[alloc_slab_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/slub.c?h=v6.0#n1821) Node? [alloc_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mempolicy.c?h=v6.0#n2252) [\_\_folio_alloc_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n247)

no

yes

 

[alloc_pages_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n260) [\_\_alloc_pages_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n238) [\_\_alloc_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5513) [\_\_folio_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5577)

If fails

[\_\_alloc_pages_bulk()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5360) [alloc_pages_bulk_array()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n219)

 

[alloc_pages_bulk_array_mempolicy()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mempolicy.c?h=v6.0#n2349) [alloc_pages_bulk_array_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n225)

 

*Figure 2-13: Physical page allocation in the kernel*

 

Note that:

 

• Denotes functions that are exported.

 

• Denotes the key functions which all others ultimately arrive at.

 

As this demonstrates, all non-bulk physical memory allocations are ul-

timately performed by [\_\_alloc_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5513). This is therefore the key function

to analyse in order to understand physical allocation within the kernel as

shown in Listing 2-51.

 

5513 **struct** page \***\_\_alloc_pages**(**gfp_t** gfp, **unsigned int** order, **int** preferred_nid, 5514 **nodemask_t** \*nodemask)

 

*Listing 2-51:* mm/page_alloc.c: [*\_\_alloc_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5513) *prototype*

 

The gfp field specifies GFP flags which includes any zone specification,

order specifies the required page order (if greater than 0 then the function

returns a compound page), preferred_nid specifies a preferred node for the

allocation and nodemask specifies which nodes we are able to allocate memory

on. The [nodemask_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/nodemask.h?h=v6.0#n99) type is a bitmap of size equal to [MAX_NUMNODES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/numa.h?h=v6.0#n12)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/numa.h?h=v6.0#n12)

It then uses these to generate a base set of parameters used throughout

the allocation via [prepare_alloc_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5297) and [current_gfp_context()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n203)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n203) This results

in initial values of:

 

• order = order

• alloc_gfp = gfp

**–** & ~\_\_GFP_FS if PF_MEMALLOC_NOIO/PF_MEMALLOC_NOFS is set. **–** & ~\_\_GFP_IO if PF_MEMALLOC_NOIO is set. **–** & ~\_\_GFP_MOVABLE if PF_MEMALLOC_PIN is set.

 



 

• alloc_flags = ALLOC_WMARK_LOW

**–** \| ALLOC_KSWAPD if \_\_GFP_KSWAP_RECLAIM is set. **–** \| ALLOC_NOFRAGMENT if ZONE_NORMAL and ZONE_DMA32 populated. **–** \| ALLOC_CPUSET if cpusets enabled and interrupt context/nodemask

set.

• ac = struct alloc_context {

. zonelist = [node_zonelist(preferred_nid,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n185) gfp)

. migratetype = [gfp_migratetype(gfp)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n16)

. highest_zoneidx = [gfp_zone(gfp)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n149) . spread_dirty_pages = gfp & \_\_GFP_WRITE

. preferred_zoneref = [first_zones_zonelist(zonelist,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1289) highest_zoneidx, nodemask) . nodemask = nodemask \[or if cpusets enabled, not in interrupt context and no

nodemask specified = cpuset_current_mems_allowed\]

}

 

Let’s go on a whistle-stop tour of \_\_alloc_pages() and examine the entire

call stack involved in allocating physical memory as shown in Figure 2-14.

 

Initialise GFP and alloc flags

 

Try to allocate from [get_page_from_freelist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4166)

 

yes

Success? Return [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72)

 

no

 

Reset gfp, nodemask and spread_dirty_pages

 

Try to allocate from [\_\_alloc_pages_slowpath()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015)

 

*Figure 2-14: Visualisation of* [*\_\_alloc_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5513)

 

Initialisation of flags consists of applying the global GFP mask

[gfp_allowed_mask](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n342) (typically only applicable during boot), obtaining any

process-specific memalloc flag settings via [current_gfp_context()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n203), invoking

[prepare_alloc_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5297) to set up an [struct alloc_context](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n209) object and possibly

modify the alloc flags before finally applying [alloc_flags_nofragment()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4119) to avoid fragmentation in ZONE_DMA32.

The net result of these flags and their initial values are described on the

previous page.

Note that we do not explore [\_\_alloc_pages_slowpath()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015) here but rather ex-

amine this in Listing 11-1 in Chapter 11 on reclaim, as this is where direct reclaim takes place.

 



 

Get the next zone in ac-\>zonelist, starting at

ac-\>preferred_zoneref, if none remain return NULL

 

If cpusets enabled and ALLOC_CPUSET set,

no

check that CPU associated with node Allowed?

is permitted via [\_\_cpuset_node_allowed()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/cgroup/cpuset.c?h=v6.0#n3569)

yes

 

If spread dirty pages enabled check no we are within limits

[node_dirty_ok()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n483) Within limits?

yes

 

If ALLOC_NOFALLBACK, more than 1 online

no

node and we are looking at a zone other On local node? Reset loop

than preferred, check if on local node

yes

 

Check if zone free pages are above

no

watermark via [zone_watermark_fast()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4039) Watermark OK?

and ALLOC_NO_WATERMARKS not set

yes

 

succeeded failed

[node_reclaim()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4808)?

 

no

[rmqueue()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3821) page from this zone Success?

 

yes

Prepare page via [prep_new_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2529) and possibly reserve pageblock

via [reserve_highatomic_pageblock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2873)

 

Return [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72)

 

*Figure 2-15: Visualisation of* [*get_page_from_freelist()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4166)

 



 

Check if order is per-

yes

mitted to use PCP list Can use PCP? Invoke [rmqueue_pcplist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3778)

via [pcp_allowed_order()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n753)

no

 

Invoke [rmqueue_buddy()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3700)

 

Check whether the

zone is boosted

 

yes

Boosted? Wake up kswapd

no

 

Return page

 

*Figure 2-16: Visualisation of* [*rmqueue()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3821)

 

Acquire zone-\>lock

Check if higher order yes Try to allocate from

Harder? MIGRATE_HIGHATOMIC via

and ALLOC_HARDER set

[\_\_rmqueue_smallest()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2554)

no

 

no

Allocate from [\_\_rmqueue()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3080) Success?

yes

Release zone-\>lock Release zone-\>lock

Return no yes Update zone free page

Success?

NULL stats, [check_new_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2389)

 

no

OK?

 

yes

 

Update zone NUMA stats Return page

 

*Figure 2-17: Visualisation of* [*rmqueue_buddy()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3700)

 

[\_\_rmqueue()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3080) is a simple wrapper around [\_\_rmqueue_smallest()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2554) with the

added logic of falling back to [\_\_rmqueue_fallback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2998) to steal from another mi-

grate type if this fails as shown in Figure 2-18.

 



 

Get page via [\_\_rmqueue_smallest()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2554)

 

Success?

no yes

 

Get page from

Return page

[\_\_rmqueue_fallback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2998)

 

*Figure 2-18: Visualisation of* [*\_\_rmqueue()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3080)

 

[rmqueue_pcplist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3778) is a simple mechanism for retrieving a page from

the PCP lists so there is not much benefit in visualising it. Let’s examine

[\_\_rmqueue_smallest()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2554) as this is where pages are actually retrieved from free

lists as shown in Figure 2-19.

 

Set current_order to the requested order Return NULL

 

no

 

Check if current_order

Valid?

valid (below MAX_ORDER)

yes

 

Increment no Try to remove page from free

Got page?

current_order list via [get_page_from_free_area()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n110)

yes

 

Split buddies via [expand()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2340)

 

Return page of order

 

*Figure 2-19: Visualisation of* [*\_\_rmqueue_smallest()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2554)

 

We visualise [expand()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2340), whose logic is rather simple, in Figure **??**.

 



 

Check if can split the page (order \> requested)

 

Add the second half of the page to a

free list via [add_to_free_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1008)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1008) decre-

ment page order and [set_buddy_order()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n951)

 

*Figure 2-20: Visualisation of* [*expand()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2340)

 

Finally, let’s examine [\_\_rmqueue_fallback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2998)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2998) this is invoked when no page

of the required migrate type is available and a page needs to be ‘stolen’ from

another migrate type as shown in Figure 2-21.

 



 

Check if ALLOC_NOFRAGMENT is set

 

Set?

yes no

 

Set min_order to Set min_order to

page block order requested order

 

Set current_order to MAX_ORDER - 1

Return false

(we loop in decreasing order)

 

yes

 

Decrement current_order Check if current_order \< min_order Less?

no

 

no

 

Found? [find_suitable_fallback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2838)

yes

 

Check edge case: If we can’t steal,

request MIGRATE_MOVABLE and this page Edge case?

has higher order than requested no yes

 

Steal page via Find smallest steal-

[steal_suitable_fallback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2756) able page instead

 

*Figure 2-21: Visualisation of* [*\_\_rmqueue_fallback()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2998)

 

A key point to note here is that under ordinary circumstances the largest

possible page is ‘stolen’ from another migrate type. We can grab a page at a

page block size or more than we simply convert the entire page block with

zero fragmentation.

 

***2.8.2*** \_\_alloc_pages()

Examining the actual function (stripping out of scope memcg and trace

point logic) as shown in Listing 2-52.

 

5510 */\**

5511 *\* This is the 'heart' of the zoned buddy allocator.*

 



 

5512 *\*/*

5513 **struct** page \***\_\_alloc_pages**(**gfp_t** gfp, **unsigned int** order, **int** preferred_nid, 5514 **nodemask_t** \*nodemask) 5515 {

5516 **struct** page \*page; 5517 **unsigned int** alloc_flags = **ALLOC_WMARK_LOW**; 5518 **gfp_t** alloc_gfp; */\* The gfp_t that was actually used for allocation \*/* 5519 **struct** alloc_context ac = { }; 5520

5521 */\**

5522 *\* There are several places where we assume that the order value is*

*sane*

5523 *\* so bail out early if the request is out of bound.* 5524 *\*/*

5525 **if** (**WARN_ON_ONCE_GFP**(order \>= **MAX_ORDER**, gfp)) 5526 **return NULL**; 5527

5528 gfp &= gfp_allowed_mask; 5529 */\**

5530 *\* Apply scoped allocation constraints. This is mainly about GFP_NOFS*

5531 *\* resp. GFP_NOIO which has to be inherited for all allocation*

*requests*

5532 *\* from a particular context which has been marked by* 5533 *\* memalloc_no{fs,io}\_{save,restore}. And PF_MEMALLOC_PIN which*

*ensures*

5534 *\* movable zones are not used during allocation.* 5535 *\*/*

5536 gfp = **current_gfp_context**(gfp); 5537 alloc_gfp = gfp;

5538 **if** (!**prepare_alloc_pages**(gfp, order, preferred_nid, nodemask, &ac, 5539 &alloc_gfp, &alloc_flags)) 5540 **return NULL**; 5541

5542 */\**

5543 *\* Forbid the first pass from falling back to types that fragment*

5544 *\* memory until all local zones are considered.* 5545 *\*/*

5546 alloc_flags \|= **alloc_flags_nofragment**(ac.preferred_zoneref-\>zone, gfp)

;

5547

5548 */\* First allocation attempt \*/* 5549 page = **get_page_from_freelist**(alloc_gfp, order, alloc_flags, &ac); 5550 **if** (**likely**(page)) 5551 **goto** out; 5552

5553 alloc_gfp = gfp;

5554 ac.spread_dirty_pages = **false**;

 



 

5555

5556 */\**

5557 *\* Restore the original nodemask if it was potentially replaced with*

5558 *\* &cpuset_current_mems_allowed to optimize the fast-path attempt.*

5559 *\*/*

5560 ac.nodemask = nodemask; 5561

5562 page = **\_\_alloc_pages_slowpath**(alloc_gfp, order, &ac); 5563

5564 out:

. . .

5573 **return** page;

5574 }

 

*Listing 2-52:* mm/page_alloc.c: *Simplified [\_\_alloc_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5513)*

 

The top level logic is as follows:

 

1. Check to ensure the specified order is within the permitted range (0 to

MAX_ORDER - 1).

2. Mask gfp against gfp_allowed_mask – this is only relevant during early boot

and power state transition.

3. Invoke [current_gfp_context()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n203) to adjust GFP flags according to whether

the current thread has memalloc flags set. These are set when the thread is performing allocations in a context where certain types of allocations cannot be permitted and are set in the thread’s flags field:

• PF_MEMALLOC_NOIO – This clears \_\_GFP_IO and \_\_GFP_FS meaning no

I/O or low-level filesystem operations can occur during allocation. This is important when filesystem locks are held during an alloca-

tion to avoid deadlock. Set by [memalloc_noio_save()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n288) and cleared by

[memalloc_noio_restore()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n303).

• PF_MEMALLOC_NOFS – Similar to PF_MEMALLOC_NOIO but a weaker constraint

– This clears \_\_GFP_FS meaning no low-level filesystem operations can

occur during allocation. Set by [memalloc_nofs_save()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n319) and cleared by

[memalloc_nofs_restore()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n334).

• PF_MEMALLOC_PIN – This prevents allocated memory from be-

ing movable by clearing the \_\_GFP_MOVABLE GFP flag. Set by

[memalloc_pin_save()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n351) and cleared by [memalloc_pin_restore()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n359). This is cur-

rently only used in [\_\_gup_longterm_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/gup.c?h=v6.0#n2063).

4. After taking a copy of the gfp flags in alloc_gfp invoke

[prepare_alloc_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5297) which sets alloc_gfp, alloc_flags and the

[struct alloc_context](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n209) object ac. These three values parameterise the fast path allocation attempt. Under certain circumstances this step can fail.

5. Update alloc_flags to set ALLOC_NOFRAGMENT in order to avoid memory frag-

mentation between zones if [alloc_flags_nofragment()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4119) deems this neces-sary.

 



 

6. Attempt fast path allocation via [get_page_from_freelist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4166)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4166) parameterised

by alloc_gfp, order, alloc_flags and ac.

7. If and only if this fails – restore the original gfp flags to alloc_gfp, dis-

able dirty page spreading, reset the mask of allowable nodes and invoke

[\_\_alloc_pages_slowpath()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015) to perform slow path allocation. The bulk of this logic forms part of direct memory reclaim, which will be examined in the reclaim chapter.

 

For most allocations we can simplify this to – generate

[struct alloc_context](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n209) based on input parameters, try fast path, if failed, try slow path.

Let’s examine struct alloc_context as shown in Listing 2-53.

 

196 */\**

197 *\* Structure for holding the mostly immutable allocation parameters passed*

198 *\* between functions involved in allocations, including the alloc_pages\** 199 *\* family of functions.*

200 *\**

201 *\* nodemask, migratetype and highest_zoneidx are initialized only once in* 202 *\* \_\_alloc_pages() and then never change.* 203 *\**

204 *\* zonelist, preferred_zone and highest_zoneidx are set first in* 205 *\* \_\_alloc_pages() for the fast path, and might be later changed* 206 *\* in \_\_alloc_pages_slowpath(). All other functions pass the whole structure*

207 *\* by a const pointer.*

208 *\*/*

209 **struct** alloc_context {

210 **struct** zonelist \*zonelist; 211 **nodemask_t** \*nodemask; 212 **struct** zoneref \*preferred_zoneref; 213 **int** migratetype;

214

215 */\**

216 *\* highest_zoneidx represents highest usable zone index of* 217 *\* the allocation request. Due to the nature of the zone,* 218 *\* memory on lower zone than the highest_zoneidx will be* 219 *\* protected by lowmem_reserve\[highest_zoneidx\].* 220 *\**

221 *\* highest_zoneidx is also used by reclaim/compaction to limit* 222 *\* the target zone since higher zone than this index cannot be* 223 *\* usable for this allocation request.* 224 *\*/*

225 **enum** zone_type highest_zoneidx; 226 **bool** spread_dirty_pages; 227 };

 

*Listing 2-53:* mm/internal.h: [*struct alloc_context*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n209)

 



 

This data structure is threaded through all allocation paths. Examining

each field:

 

• zonelist – A [struct zonelist](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n878) is a list of zones that will be tried for allo-

cation. The zone list used during allocation is the one which deter-mine which zones will be tried. There are two possible zonelists – all available zones, and those available only on the preferred_nid node. In

fast-path allocation this is determine via [node_zonelist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n185)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n185) selecting the ZONELIST_FALLBACK zonelist (i.e. the one containing the zones of all nodes) by default or selecting the ZONELIST_NOFALLBACK (i.e. the one containing only the zones of the selected node) if the \_\_GFP_THISNODE flag has been specified.

• nodemask – Simply passes through the nodemask parameter passed to

[\_\_alloc_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5513). If the cgroups cpusets feature is enabled and no nodemask is provided in task context (i.e. not interrupt context) then this to the cpuset_current_mems_allowed global.

• highest_zoneidx – The index of the highest zone type (e.g. ZONE_DMA32) that

will be examined as determined by GFP flags via [gfp_zone()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n149). This is de-termined via the physical address zone modifiers described in section

2.6.1. This is the requested zone for the allocation – i.e. the zone the allo-cator was intended to be taken from.

• preferred_zoneref – This field is set last and determines the zone

which we first look at when iterating through each zone. This uses

[first_zones_zonelist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n1289) to find the first zone in ac-\>zonelist that is at or below ac-\>highest_zoneidx which exists on ac-\>nodemask.

• migratetype – The migratetype of the allocation as determined by

[gfp_migratetype()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n16) determined by GFP page mobility flags described in

section 2.6.2. In early boot there is a global variable which may also im-pact mobility —page_group_by_mobility_disabled—but for ordinary alloca-tions this isn’t a consideration..

• spread_dirty_pages – Set true if \_\_GFP_WRITE is set.

 

We can see this in action in [prepare_alloc_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5297) (excluding out-of-scope

CMA code) as shown in Listing 2-54.

 

5297 **static inline bool prepare_alloc_pages**(**gfp_t** gfp_mask, **unsigned int** order, 5298 **int** preferred_nid, **nodemask_t** \*nodemask, 5299 **struct** alloc_context \*ac, **gfp_t** \*alloc_gfp, 5300 **unsigned int** \*alloc_flags) 5301 {

5302 ac-\>highest_zoneidx = **gfp_zone**(gfp_mask); 5303 ac-\>zonelist = **node_zonelist**(preferred_nid, gfp_mask); 5304 ac-\>nodemask = nodemask; 5305 ac-\>migratetype = **gfp_migratetype**(gfp_mask); 5306

5307 **if** (**cpusets_enabled**()) { 5308 \*alloc_gfp \|= **\_\_GFP_HARDWALL**;

 



 

5309 */\**

5310 *\* When we are in the interrupt context, it is irrelevant*

5311 *\* to the current task context. It means that any node ok.*

5312 *\*/*

5313 **if** (**in_task**() && !ac-\>nodemask) 5314 ac-\>nodemask = &cpuset_current_mems_allowed; 5315 **else**

5316 \*alloc_flags \|= **ALLOC_CPUSET**; 5317 }

5318

5319 might_alloc(gfp_mask); 5320

5321 **if** (**should_fail_alloc_page**(gfp_mask, order)) 5322 **return false**;

. . .

5326 */\* Dirty zone balancing only done in the fast path \*/* 5327 ac-\>spread_dirty_pages = (gfp_mask & **\_\_GFP_WRITE**); 5328

5329 */\**

5330 *\* The preferred zone is used for statistics but crucially it is* 5331 *\* also used as the starting point for the zonelist iterator. It* 5332 *\* may get reset for allocations that ignore memory policies.* 5333 *\*/*

5334 ac-\>preferred_zoneref = **first_zones_zonelist**(ac-\>zonelist, 5335 ac-\>highest_zoneidx, ac-\>nodemask);

5336

5337 **return true**;

5338 }

 

*Listing 2-54:* mm/page_alloc.c: [*prepare_alloc_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5297)

 

The logic largely follows the description of [struct alloc_context](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n209) fields

above, with some nuances – if the cgroup cpusets are enabled, then \_\_GFP_HARDWALL is set in the GFP flags and ALLOC_CPUSET set in allocation flags (see later for more on allocation flags) if not in task context or a nodemask is specified.

Additionally, [should_fail_alloc_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3933) is called to determine whether

a page fault should fail under CONFIG_FAIL_PAGE_ALLOC (ultimately invoking

[\_\_should_fail_alloc_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3883)). This is enabled if fault injection is enabled (via

CONFIG_FAULT_INJECTION) but this is beyond the scope of the book (see the [fault](https://kernel.org/doc/html/v6.0/fault-injection/index.html)

[injection documentation](https://kernel.org/doc/html/v6.0/fault-injection/index.html) for more details).

Before invoking [prepare_alloc_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5297)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5297) [\_\_alloc_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5513) defaults alloc_flags

to ALLOC_WMARK_LOW. prepare_alloc_pages() also possibly sets the ALLOC_CPUSET flag.

These are additional flags beyond GFP flags which determine how al-

locations should be performed – let’s examine them now (all declared in

[mm/internal.h).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n756)

Firstly, considering the watermark flags:

 



 

• ALLOC_WMARK_MIN – Only allocate if the zone watermark is at or above the

minimum watermark (taking into account reserves, and checking that at least one page exists if allocating higher order).

• ALLOC_WMARK_LOW – Same as above, for the low watermark. Default be-

haviour.

• ALLOC_WMARK_HIGH – Same as above, for the high watermark.

• ALLOC_NO_WATERMARKS – Ignore watermarks on allocation.

 

These flags are kept in sync with the equivalent enum entries in

[enum zone_watermarks](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n349) so the index can simply be extracted by applying the

ALLOC_WMARK_MASK. This is used for example in [get_page_from_freelist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4166)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4166) (the

fast-path allocation logic).

The remaining flags are set at higher bits and can be combined:

 

• ALLOC_OOM – Indicates that the task is being targeted as an Out-Of-

Memory (OOM) victim and watermarks should be reduced to permit allocations as the process is about to die anyway.

• ALLOC_HARDER – Try to allocate harder than usual. Reduces watermarks to

permit allocation even in low memory scenarios.

• ALLOC_HIGH – Indicates high-priority allocation, which further reduces wa-

termarks. Implied by \_\_GFP\_\_HIGH.

• ALLOC_CPUSET – cpuset-specific allocation flag out of scope for this book.

• ALLOC_CMA – Indicates a CMA allocation, out of scope for this book.

• ALLOC_NOFRAGMENT – Indicates that allocations should not steal pages from

other migratetype pageblocks.

• ALLOC_KSWAPD – Indicates that kswapd processes should be woken to per-

form indirect reclaim. These are kernel threads that work to reclaim free pages back to zones, covered further in the reclaim chapter.

 

Let’s examine [get_page_from_freelist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4166) (simplified to remove some com-

ments and deferred [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) initialisation). We can divide the function

up into three parts. Firstly the initial portion and the beginning of the zone

loop as shown in Listing 2-55.

 

4165 **static struct** page \*

4166 **get_page_from_freelist**(**gfp_t** gfp_mask, **unsigned int** order, **int** alloc_flags, 4167 **const struct** alloc_context \*ac

)

4168 {

4169 **struct** zoneref \*z; 4170 **struct** zone \*zone; 4171 **struct** pglist_data \*last_pgdat = **NULL**; 4172 **bool** last_pgdat_dirty_ok = **false**; 4173 **bool** no_fallback; 4174

4175 **retry**:

 



 

4176 */\**

4177 *\* Scan zonelist, looking for a zone with enough free.* 4178 *\* See also \_\_cpuset_node_allowed() comment in kernel/cgroup/cpuset.c.*

4179 *\*/*

4180 no_fallback = alloc_flags & **ALLOC_NOFRAGMENT**; 4181 z = ac-\>preferred_zoneref; 4182 **for_next_zone_zonelist_nodemask**(zone, z, ac-\>highest_zoneidx, 4183 ac-\>nodemask) {

 

*Listing 2-55:* mm/page_alloc.c: *Preface of [get_page_from_freelist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4166)*

 

We are iterating through each zone specified by the node mask to find a

candidate from which we can obtain pages. The loop code firstly examines

edge cases as shown in Listing 2-56.

 

4184 **struct** page \*page; 4185 **unsigned long** mark; 4186

4187 **if** (**cpusets_enabled**() && 4188 (alloc_flags & **ALLOC_CPUSET**) && 4189 !**\_\_cpuset_zone_allowed**(zone, gfp_mask)) 4190 **continue**;

. . .

4210 **if** (ac-\>spread_dirty_pages) { 4211 **if** (last_pgdat != zone-\>zone_pgdat) { 4212 last_pgdat = zone-\>zone_pgdat; 4213 last_pgdat_dirty_ok = **node_dirty_ok**(zone-\>

zone_pgdat);

4214 } 4215

4216 **if** (!last_pgdat_dirty_ok) 4217 **continue**; 4218 }

4219

4220 **if** (no_fallback && nr_online_nodes \> 1 && 4221 zone != ac-\>preferred_zoneref-\>zone) { 4222 **int** local_nid; 4223

4224 */\** 4225 *\* If moving to a remote node, retry but allow* 4226 *\* fragmenting fallbacks. Locality is more important*

4227 *\* than fragmentation avoidance.* 4228 *\*/* 4229 local_nid = **zone_to_nid**(ac-\>preferred_zoneref-\>zone); 4230 **if** (**zone_to_nid**(zone) != local_nid) { 4231 alloc_flags &= ~**ALLOC_NOFRAGMENT**; 4232 **goto retry**; 4233 } 4234 }

 



 

*Listing 2-56:* mm/page_alloc.c: [*get_page_from_freelist()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4166) *edge cases*

 

Here we perform a few checks:

 

• If ALLOC_CPUSET is set and the CPU is not allowed under the cgroup cpuset

functionality then we reject the zone.

• If the spread_dirty_pages allocation flag has been set (via the \_\_GFP_WRITE

GFP flag having been passed), we check each new node to see if it has

exceeded dirty page limits via [node_dirty_ok()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n483). If it has then we do not allocate from it as the \_\_GFP_WRITE hints that this will be a file-backed al-location and thus we would only be exceeding the dirty limit by even more.

• If the ALLOC_NOFRAGMENT flag has been set and we are not on the preferred

node, then we clear this flag and retry the operation.

 

Finally we perform the vital step of the zone watermark check and the

actual allocation of the requested page as shown in Listing 2-57.

 

4237 **if** (!**zone_watermark_fast**(zone, order, mark, 4238 ac-\>highest_zoneidx, alloc_flags, 4239 gfp_mask)) {

. . .

4277 }

4278

4279 **try_this_zone**:

4280 page = **rmqueue**(ac-\>preferred_zoneref-\>zone, zone, order, 4281 gfp_mask, alloc_flags, ac-\>migratetype); 4282 **if** (page) { 4283 **prep_new_page**(page, order, gfp_mask, alloc_flags); 4284

4285 */\** 4286 *\* If this is a high-order atomic allocation then*

*check*

4287 *\* if the pageblock should be reserved for the future*

4288 *\*/* 4289 **if** (**unlikely**(order && (alloc_flags & **ALLOC_HARDER**))) 4290 **reserve_highatomic_pageblock**(page, zone, order

);

4291

4292 **return** page; 4293 } **else** {

. . .

4301 }

4302 }

4303

4304 */\**

4305 *\* It's possible on a UMA machine to get through all zones that are*

 



 

4306 *\* fragmented. If avoiding fragmentation, reset and try again.* 4307 *\*/*

4308 **if** (no_fallback) { 4309 alloc_flags &= ~**ALLOC_NOFRAGMENT**; 4310 **goto retry**; 4311 }

4312

4313 **return NULL**;

4314 }

 

*Listing 2-57:* mm/page_alloc.c: [*get_page_from_freelist()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4166) *watermark check and page retrieval*

 

The key steps here are the fast-path zone watermark check via

[zone_watermark_fast()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4039) (we exclude the ‘slow’ watermark check case if this function fails, as this is covered in the reclaim chapter) and the ac-

tual retrieval of pages via [rmqueue()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3821) with the page being prepared via

[prep_new_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2529). We will examine each of these in turn.

In order to check whether the zone watermark has been exceeded we use

zone_watermark_fast() as shown in Listing 2-58.

 

4039 **static inline bool zone_watermark_fast**(**struct** zone \*z, **unsigned int** order, 4040 **unsigned long** mark, **int** highest_zoneidx, 4041 **unsigned int** alloc_flags, **gfp_t** gfp_mask) 4042 {

4043 **long** free_pages;

4044

4045 free_pages = **zone_page_state**(z, **NR_FREE_PAGES**); 4046

4047 */\**

4048 *\* Fast check for order-0 only. If this fails then the reserves* 4049 *\* need to be calculated.* 4050 *\*/*

4051 **if** (!order) {

4052 **long** usable_free; 4053 **long** reserved; 4054

4055 usable_free = free_pages; 4056 reserved = **\_\_zone_watermark_unusable_free**(z, 0, alloc_flags); 4057

4058 */\* reserved may over estimate high-atomic reserves. \*/* 4059 usable_free -= **min**(usable_free, reserved); 4060 **if** (usable_free \> mark + z-\>lowmem_reserve\[highest_zoneidx\]) 4061 **return true**; 4062 }

4063

4064 **if** (**\_\_zone_watermark_ok**(z, order, mark, highest_zoneidx, alloc_flags, 4065 free_pages)) 4066 **return true**;

 



 

4067 */\**

4068 *\* Ignore watermark boosting for GFP_ATOMIC order-0 allocations* 4069 *\* when checking the min watermark. The min watermark is the* 4070 *\* point where boosting is ignored so that kswapd is woken up* 4071 *\* when below the low watermark.* 4072 *\*/*

4073 **if** (**unlikely**(!order && (gfp_mask & **\_\_GFP_ATOMIC**) && z-\>watermark_boost 4074 && ((alloc_flags & **ALLOC_WMARK_MASK**) == **WMARK_MIN**))) { 4075 mark = z-\>\_watermark\[**WMARK_MIN**\]; 4076 **return \_\_zone_watermark_ok**(z, order, mark, highest_zoneidx, 4077 alloc_flags, free_pages); 4078 }

4079

4080 **return false**;

4081 }

 

*Listing 2-58:* mm/page_alloc.c: [*zone_watermark_fast()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4039)

 

The [\_\_zone_watermark_unusable_free()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3939) function returns how many base

pages are designated ‘unusable’ within the zone – this defaults to the page

order minus 1 (or 0 if order-0). This ensures that we always leave at least one

page of the specified order in the zone at all times except for order-0. If nei-

ther ALLOC_HARDER or ALLOC_OOM are set also includes the pages kept reserved for

high atomic page blocks.

In the fast path (order-0 pages) this is all we need to determine whether

the zone watermark check has passed (also taking into account lowmem re-

serves as discussed in section 2.4 above).

For higher-order allocators or cases whether this fast check failed, we

invoke the slow path function [\_\_zone_watermark_ok()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3968) (Stripping out-of-scope

CMA code) as shown in Listing 2-59.

 

3968 **bool \_\_zone_watermark_ok**(**struct** zone \*z, **unsigned int** order, **unsigned long**

mark,

3969 **int** highest_zoneidx, **unsigned int** alloc_flags, 3970 **long** free_pages) 3971 {

3972 **long** min = mark;

3973 **int** o;

3974 **const bool** alloc_harder = (alloc_flags & (**ALLOC_HARDER**\|**ALLOC_OOM**)); 3975

3976 */\* free_pages may go negative - that's OK \*/* 3977 free_pages -= **\_\_zone_watermark_unusable_free**(z, order, alloc_flags); 3978

3979 **if** (alloc_flags & **ALLOC_HIGH**) 3980 min -= min / 2; 3981

3982 **if** (**unlikely**(alloc_harder)) { 3983 */\**

3984 *\* OOM victims can try even harder than normal ALLOC_HARDER*

 



 

3985 *\* users on the grounds that it's definitely going to be in*

3986 *\* the exit path shortly and free memory. Any allocation it*

3987 *\* makes during the free path will be small and short-lived.*

3988 *\*/*

3989 **if** (alloc_flags & **ALLOC_OOM**) 3990 min -= min / 2; 3991 **else**

3992 min -= min / 4; 3993 }

3994

3995 */\**

3996 *\* Check watermarks for an order-0 allocation request. If these* 3997 *\* are not met, then a high-order request also cannot go ahead* 3998 *\* even if a suitable page happened to be free.* 3999 *\*/*

4000 **if** (free_pages \<= min + z-\>lowmem_reserve\[highest_zoneidx\]) 4001 **return false**; 4002

4003 */\* If this is an order-0 request then the watermark is fine \*/* 4004 **if** (!order)

4005 **return true**; 4006

4007 */\* For a high-order request, check at least one suitable page is free*

*\*/*

4008 **for** (o = order; o \< **MAX_ORDER**; o++) { 4009 **struct** free_area \*area = &z-\>free_area\[o\]; 4010 **int** mt;

4011

4012 **if** (!area-\>nr_free) 4013 **continue**; 4014

4015 **for** (mt = 0; mt \< **MIGRATE_PCPTYPES**; mt++) { 4016 **if** (!**free_area_empty**(area, mt)) 4017 **return true**; 4018 }

. . .

4026 **if** (alloc_harder && !**free_area_empty**(area, **MIGRATE_HIGHATOMIC**)

)

4027 **return true**; 4028 }

4029 **return false**;

4030 }

 

*Listing 2-59:* mm/page_alloc.c: [*\_\_zone_watermark_ok()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3968)

 

As before, [\_\_zone_watermark_unusable_free()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3939) is used to take into account

reserved pages.

 



 

After this, we examine the impact of allocation flags that reduce the min-

imum required number of free pages (ALLOC_OOM supersedes ALLOC_HARDER so if

both are set only ALLOC_OOM takes effect.):

 

Table 2-7: Alloc flag watermark impact

ALLOC_HIGH ALLOC_OOM ALLOC_HARDER ∆ Req’d pages

*•* *−*25%

*•* *−*50%

*•* *−*50%

*•* *•* *−*62*.*5% *•* *•* *−*75%

 

The motivation for reducing watermark requirements even further un-

der OOM conditions is that a process that is a target for OOM (and thus al-

locating with ALLOC_OOM set) will soon be killed so allowing it to allocate some

more memory is immaterial – the memory will be freed very soon.

Low mem reserves are taken into account (as discussed in section 2.4).

For order-0 pages these checks are sufficient.

For higher-order pages additional checks are performed – at least one

page at or above the required order must exist for PCP-usable migrate

types (MIGRATE_UNMOVABLE, MIGRATE_MOVABLE, or MIGRATE_RECLAIMABLE). If either

ALLOC_HARDER or ALLOC_OOM are set, then the MIGRATE_HIGHATOMIC migratetype can

also be used.

Looking back to [zone_watermark_fast()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4039) we cover a very specific edge case –

for order-0 pages, allocated via \_\_GFP_ATOMIC, with zone watermark boost and

allocation flags set to ALLOC_WMARK_MIN we invoke [\_\_zone_watermark_ok()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3968) again

with the watermark set to WMARK_MIN, i.e. removing the watermark boost alto-

gether under these specific circumstances.

 

***2.8.3 rmqueue()***

Once we have established the zone to allocate from, we need to actually per-

form the allocation from a freelist. This is achieved via [rmqueue()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3821) (stripping

out-of-scope CMA code) as shown in Listing 2-60.

 

3820 **static inline**

3821 **struct** page \***rmqueue**(**struct** zone \*preferred_zone, 3822 **struct** zone \*zone, **unsigned int** order, 3823 **gfp_t** gfp_flags, **unsigned int** alloc_flags, 3824 **int** migratetype) 3825 {

3826 **struct** page \*page; 3827

3828 */\**

3829 *\* We most definitely don't want callers attempting to* 3830 *\* allocate greater than order-1 page units with \_\_GFP_NOFAIL.* 3831 *\*/*

3832 **WARN_ON_ONCE**((gfp_flags & **\_\_GFP_NOFAIL**) && (order \> 1));

 



 

3833

3834 **if** (**likely**(**pcp_allowed_order**(order))) {

. . .

3841 page = **rmqueue_pcplist**(preferred_zone, zone, order, 3842 gfp_flags, migratetype, alloc_flags);

3843 **if** (**likely**(page)) 3844 **goto out**;

. . .

3846 }

3847

3848 page = **rmqueue_buddy**(preferred_zone, zone, order, alloc_flags, 3849 migratetype); 3850

3851 **out**:

3852 */\* Separate test+clear to avoid unnecessary atomics \*/* 3853 **if** (**unlikely**(**test_bit**(**ZONE_BOOSTED_WATERMARK**, &zone-\>flags))) { 3854 **clear_bit**(**ZONE_BOOSTED_WATERMARK**, &zone-\>flags); 3855 **wakeup_kswapd**(zone, 0, 0, **zone_idx**(zone)); 3856 }

3857

3858 **VM_BUG_ON_PAGE**(page && **bad_range**(zone, page), page); 3859 **return** page;

3860 }

 

*Listing 2-60:* mm/page_alloc.c: [*rmqueue()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3821)

The logic is as follows:

 

1. If the order of the allocation is such that Per-CPU-Pages (PCPs) can be

used as indicated by [pcp_allowed_order()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n753) (see section 2.7.3 for more de-

tails), then we allocate from these using [rmqueue_pcplist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3778)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3778) This avoids the need for acquiring a zone lock.

2. If we are unable to retrieve a page from the PCP, invoke [rmqueue_buddy()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3700)

to retrieve the page directly from the buddy allocator.

3. If the watermark for the zone has been boosted, then kswapd is woken up

to perform indirect reclaim. We go into detail about this in the reclaim chapter. This boosting occurs when migrate type fragmentation occurs

(see section 2.8.6) in order to reduce the impact of fragmented page blocks.

 

***2.8.4 rmqueue_buddy()***

We examine [rmqueue_buddy()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3700) in Listing 2-61 (eliding statistical updates).

 

3699 **static \_\_always_inline**

3700 **struct** page \***rmqueue_buddy**(**struct** zone \*preferred_zone, **struct** zone \*zone, 3701 **unsigned int** order, **unsigned int** alloc_flags, 3702 **int** migratetype) 3703 {

 



 

3704 **struct** page \*page; 3705 **unsigned long** flags; 3706

3707 **do** {

3708 page = **NULL**; 3709 **spin_lock_irqsave**(&zone-\>lock, flags); 3710 */\**

3711 *\* order-0 request can reach here when the pcplist is skipped*

3712 *\* due to non-CMA allocation context. HIGHATOMIC area is* 3713 *\* reserved for high-order atomic allocation, so order-0* 3714 *\* request should skip it.* 3715 *\*/*

3716 **if** (order \> 0 && alloc_flags & **ALLOC_HARDER**) 3717 page = **\_\_rmqueue_smallest**(zone, order,

**MIGRATE_HIGHATOMIC**);

3718 **if** (!page) { 3719 page = **\_\_rmqueue**(zone, order, migratetype, alloc_flags

);

3720 **if** (!page) { 3721 **spin_unlock_irqrestore**(&zone-\>lock, flags); 3722 **return NULL**; 3723 } 3724 }

. . .

3727 **spin_unlock_irqrestore**(&zone-\>lock, flags); 3728 } **while** (**check_new_pages**(page, order));

. . .

3733 **return** page;

3734 }

 

*Listing 2-61:* mm/page_alloc.c: [*rmqueue_buddy()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3700)

 

Here we enter a loop where we either allocate a page from

MIGRATE_HIGHATOMIC if ALLOC_HARDER is set via [\_\_rmqueue_smallest()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2554) or via

[\_\_rmqueue()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3080) if either the former is not the case or it fails. It then updates

zone statistics. The loop invokes [check_new_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2389) which ensures the page re-

turned from the free list is correctly set up as a free page and prints an alert

in the kernel ring buffer. This should nearly never loop (typically this would

occur if a use-after-free bug had arisen in the kernel).

 

***2.8.5 rmqueue_pcplist()***

Examining [rmqueue_pcplist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3778) as shown in Listing 2-62.

 

3777 */\* Lock and remove page from the per-cpu list \*/* 3778 **static struct** page \***rmqueue_pcplist**(**struct** zone \*preferred_zone, 3779 **struct** zone \*zone, **unsigned int** order, 3780 **gfp_t** gfp_flags, **int** migratetype, 3781 **unsigned int** alloc_flags)

 



 

3782 {

3783 **struct** per_cpu_pages \*pcp; 3784 **struct** list_head \*list; 3785 **struct** page \*page; 3786 **unsigned long** flags; 3787 **unsigned long \_\_maybe_unused** UP_flags; 3788

3789 */\**

3790 *\* spin_trylock may fail due to a parallel drain. In the future, the*

3791 *\* trylock will also protect against IRQ reentrancy.* 3792 *\*/*

3793 **pcp_trylock_prepare**(UP_flags); 3794 pcp = **pcp_spin_trylock_irqsave**(zone-\>per_cpu_pageset, flags); 3795 **if** (!pcp) {

3796 **pcp_trylock_finish**(UP_flags); 3797 **return NULL**; 3798 }

3799

3800 */\**

3801 *\* On allocation, reduce the number of pages that are batch freed.*

3802 *\* See nr_pcp_free() where free_factor is increased for subsequent*

3803 *\* frees.*

3804 *\*/*

3805 pcp-\>free_factor \>\>= 1; 3806 list = &pcp-\>lists\[**order_to_pindex**(migratetype, order)\]; 3807 page = **\_\_rmqueue_pcplist**(zone, order, migratetype, alloc_flags, pcp,

list);

3808 **pcp_spin_unlock_irqrestore**(pcp, flags); 3809 **pcp_trylock_finish**(UP_flags); 3810 **if** (page) {

3811 **\_\_count_zid_vm_events**(**PGALLOC**, **page_zonenum**(page), 1); 3812 **zone_statistics**(preferred_zone, zone, 1); 3813 }

3814 **return** page;

3815 }

 

*Listing 2-62:* mm/page_alloc.c: [*rmqueue_pcplist()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3778)

 

The logic is as follows:

 

1. Setup PCP lock via [pcp_trylock_prepare()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n139) (disabling IRQs to avoid reen-

try), acquiring the PCP lock via [pcp_spin_trylock_irqsave()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n212)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n212)

2. Retrieve the [struct per_cpu_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n384) object specific to this zone and CPU. If

lock cannot be acquired fails, restore IRQs via [pcp_trylock_finish()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n140) and return NULL.

3. Divide the ‘free factor’ by 2. This value is used to scale the number of

PCP pages that are freed back to ordinary free lists. For each page that

 



 

is freed to a PCP list the value is doubled, for each page that is allocated from a PCP list it is halved. As we are allocating here, we halve.

4. Determine the correct PCP list to retrieve a page from using

[order_to_pindex()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n723) which simply determines the array index of that a PCP list for specific order and migrate type.

5. Actually retrieve the page via [\_\_rmqueue_pcplist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3738).

6. Release the PCP lock via [pcp_spin_unlock_irqrestore()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n218) and re-enable IRQs

via [pcp_trylock_finish()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n140).

7. Update some statistics if the page was correctly retrieved and return the

result.

 

Examining [\_\_rmqueue_pcplist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3738) as shown in Listing 2-63.

 

3736 */\* Remove page from the per-cpu list, caller must protect the list \*/* 3737 **static inline**

3738 **struct** page \***\_\_rmqueue_pcplist**(**struct** zone \*zone, **unsigned int** order, 3739 **int** migratetype, 3740 **unsigned int** alloc_flags, 3741 **struct** per_cpu_pages \*pcp, 3742 **struct** list_head \*list) 3743 {

3744 **struct** page \*page; 3745

3746 **do** {

3747 **if** (**list_empty**(list)) { 3748 **int** batch = **READ_ONCE**(pcp-\>batch); 3749 **int** alloced; 3750

3751 */\** 3752 *\* Scale batch relative to order if batch implies* 3753 *\* free pages can be stored on the PCP. Batch can* 3754 *\* be 1 for small zones or for boot pagesets which*

3755 *\* should never store free pages as the pages may* 3756 *\* belong to arbitrary zones.* 3757 *\*/* 3758 **if** (batch \> 1) 3759 batch = **max**(batch \>\> order, 2); 3760 alloced = **rmqueue_bulk**(zone, order, 3761 batch, list, 3762 migratetype, alloc_flags); 3763

3764 pcp-\>count += alloced \<\< order; 3765 **if** (**unlikely**(**list_empty**(list))) 3766 **return NULL**; 3767 }

3768

3769 page = **list_first_entry**(list, **struct** page, pcp_list);

 



 

3770 **list_del**(&page-\>pcp_list); 3771 pcp-\>count -= 1 \<\< order; 3772 } **while** (**check_new_pcp**(page, order)); 3773

3774 **return** page;

3775 }

 

*Listing 2-63:* mm/page_alloc.c: [*\_\_rmqueue_pcplist()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3738)

 

The logic of this is as follows:

 

1. If the PCP list is empty, refill it using [rmqueue_bulk()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3117)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3117) We refill based on

the [per_cpu_pages-\>batch](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n384) field, refilling *max*(*⌊* *batch* *order* *⌋**,* 2) of pages of or-2 der equal to specified order. If this fails to allocate pages, we abort and return NULL.

2. Retrieve the first entry from the PCP list, delete it from the list, update

the stats.

3. Check the page via [check_new_pcp()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2416) if CONFIG_DEBUG_PAGEALLOC is enabled. If

it fails, repeat page retrieval. If success, return page.

 

Examining [\_\_rmqueue()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3080) (out-of-scope CMA logic removed for clarity) as

shown in Listing 2-64.

 

3079 **static \_\_always_inline struct** page \* 3080 **\_\_rmqueue**(**struct** zone \*zone, **unsigned int** order, **int** migratetype, 3081 **unsigned int** alloc_flags) 3082 {

3083 **struct** page \*page;

. . .

3099 **retry**:

3100 page = **\_\_rmqueue_smallest**(zone, order, migratetype); 3101 **if** (**unlikely**(!page)) {

. . .

3105 **if** (!page && **\_\_rmqueue_fallback**(zone, order, migratetype, 3106 alloc_flags))

3107 **goto retry**; 3108 }

3109 **return** page;

3110 }

 

*Listing 2-64:* mm/page_alloc.c: [*\_\_rmqueue()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3080)

 

This is simply a wrapper around \_\_rmqueue_smallest() with fallback page

allocation provided via [\_\_rmqueue_fallback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2998). The fallback will try to move pages from a fallback migrate type to the migrate type we require, then re-tries the operation.

 

***2.8.6 Migrate type fallback***

Examining [\_\_rmqueue_fallback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2998) as shown in Listing 2-65.

 



 

2987 */\**

2988 *\* Try finding a free buddy page on the fallback list and put it on the free*

2989 *\* list of requested migratetype, possibly along with other pages from the*

*same*

2990 *\* block, depending on fragmentation avoidance heuristics. Returns true if*

2991 *\* fallback was found so that \_\_rmqueue_smallest() can grab it.* 2992 *\**

2993 *\* The use of signed ints for order and current_order is a deliberate* 2994 *\* deviation from the rest of this file, to make the for loop* 2995 *\* condition simpler.*

2996 *\*/*

2997 **static \_\_always_inline bool** 2998 **\_\_rmqueue_fallback**(**struct** zone \*zone, **int** order, **int** start_migratetype, 2999 **unsigned int** alloc_flags) 3000 {

3001 **struct** free_area \*area; 3002 **int** current_order; 3003 **int** min_order = order; 3004 **struct** page \*page; 3005 **int** fallback_mt;

3006 **bool** can_steal;

3007

3008 */\**

3009 *\* Do not steal pages from freelists belonging to other pageblocks*

3010 *\* i.e. orders \< pageblock_order. If there are no local zones free,*

3011 *\* the zonelists will be reiterated without ALLOC_NOFRAGMENT.* 3012 *\*/*

3013 **if** (alloc_flags & **ALLOC_NOFRAGMENT**) 3014 min_order = pageblock_order; 3015

3016 */\**

3017 *\* Find the largest available free page in the other list. This*

*roughly*

3018 *\* approximates finding the pageblock with the most free pages, which*

3019 *\* would be too costly to do exactly.* 3020 *\*/*

3021 **for** (current_order = **MAX_ORDER**- 1; current_order \>= min_order; 3022 --current_order) { 3023 area = &(zone-\>free_area\[current_order\]); 3024 fallback_mt = **find_suitable_fallback**(area, current_order, 3025 start_migratetype, **false**, &can_steal); 3026 **if** (fallback_mt == -1) 3027 **continue**; 3028

3029 */\**

3030 *\* We cannot steal all free pages from the pageblock and the*

 



 

3031 *\* requested migratetype is movable. In that case it's better*

*to*

3032 *\* steal and split the smallest available page instead of the*

3033 *\* largest available page, because even if the next movable*

3034 *\* allocation falls back into a different pageblock than this*

3035 *\* one, it won't cause permanent fragmentation.* 3036 *\*/*

3037 **if** (!can_steal && start_migratetype == **MIGRATE_MOVABLE** 3038 && current_order \> order) 3039 **goto find_smallest**; 3040

3041 **goto do_steal**; 3042 }

3043

3044 **return false**;

3045

3046 **find_smallest**:

3047 **for** (current_order = order; current_order \< **MAX_ORDER**; 3048 current_order++) {

3049 area = &(zone-\>free_area\[current_order\]); 3050 fallback_mt = **find_suitable_fallback**(area, current_order, 3051 start_migratetype, **false**, &can_steal); 3052 **if** (fallback_mt != -1) 3053 **break**; 3054 }

3055

3056 */\**

3057 *\* This should not happen - we already found a suitable fallback*

3058 *\* when looking for the largest page.* 3059 *\*/*

3060 **VM_BUG_ON**(current_order == **MAX_ORDER**); 3061

3062 **do_steal**:

3063 page = **get_page_from_free_area**(area, fallback_mt); 3064

3065 **steal_suitable_fallback**(zone, page, alloc_flags, start_migratetype, 3066 can_steal);

3067

3068 **trace_mm_page_alloc_extfrag**(page, order, current_order, 3069 start_migratetype, fallback_mt); 3070

3071 **return true**;

3072

3073 }

 

*Listing 2-65:* mm/page_alloc.c: [*\_\_rmqueue_fallback()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2998)

 



 

If [\_\_rmqueue_fallback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2998) is called we have failed to find a page of the re-

quired migrate type at or above the required order so we fallback to moving

pages from another migrate type to the desired one.

A page’s migrate type is determined from the page block it belongs to

via [get_pageblock_migratetype()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n102)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n102) however this is only a heuristic as we can

‘steal’ pages from one migrate block for another at a granularity less than

this. When a page is freed it will end up returning to a free list associate with

migrate type of its page block. If ALLOC_NOFRAGMENT is set then this will not be

permitted.

 

**N O T E** Page blocks are aligned sets of physical pages of a specific size. Page block granular-

ity for x86-64 is order 9 or 512 base pages for example.

 

The logic is as follows:

 

1. If ALLOC_FRAGMENT is set the minimum order (of page to be moved from a

fallback migrate type to the one we require) to set is the pageblock or-der, otherwise set this to the required order.

2. Iterating from largest allowable order (MAX_ORDER - 1, typically 10) to the

minimum order, if [find_suitable_fallback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2838) indicates a suitable fallback migrate type can’t be fined, then loop again. If none can be found, re-turning false indicating that no fallback could be found. This iteration is an approximate means of finding the migrate type with the most free pages.

3. If [find_suitable_fallback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2838) indicated that we cannot steal the whole page

block the required migrate type is MIGRATE_MOVABLE and we are consider-ing moving an order larger than required we prefer to move the smallest possible page. Exit the loop and perform the find_smallest branch.

4. Otherwise, perform the do_steal branch.

5. The find_smallest branch repeats the top-level iteration only from small-

est to largest page size. This is used when we would get less fragmenta-tion than trying to find the migrate type with approximately the most free pages. Once this is complete, we fall through to the do_steal branch.

6. The do_steal branch invokes [steal_suitable_fallback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2756) to perform the

actual stealing of pages, updates statistics and returns true to indicate

that the steal was successful and [\_\_rmqueue()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3080) should be retried.

 

It’s important to note here that, as discussed in section 2.5, as a result

of this stealing mechanism migrate types at the page block level are merely

heuristic – we can end up with page blocks containing a mix of different mi-

grate types. This is something we try to avoid by ‘stealing’ the largest possi-

ble pages such that we can ideally simply change a page block’s migrate type

with no fragmentation.

However, if we are forced to mix migrate types, we reserve more memory

to prevent further fragmentation – we achieve this through zone boosting

whenever we encounter this situation. This increases watermarks, thereby

causing reclaim to occur sooner.

 



 

The watermark boost is applied by [boost_watermark()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2711) which is called only

in [steal_suitable_fallback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2756)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2756)

Examining [find_suitable_fallback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2838) as shown in Listing 2-66.

 

2832 */\**

2833 *\* Check whether there is a suitable fallback freepage with requested order.*

2834 *\* If only_stealable is true, this function returns fallback_mt only if* 2835 *\* we can steal other freepages all together. This would help to reduce* 2836 *\* fragmentation due to mixed migratetype pages in one pageblock.* 2837 *\*/*

2838 **int find_suitable_fallback**(**struct** free_area \*area, **unsigned int** order, 2839 **int** migratetype, **bool** only_stealable, **bool** \*can_steal) 2840 {

2841 **int** i;

2842 **int** fallback_mt;

2843

2844 **if** (area-\>nr_free == 0) 2845 **return**-1; 2846

2847 \*can_steal = **false**; 2848 **for** (i = 0;; i++) { 2849 fallback_mt = fallbacks\[migratetype\]\[i\]; 2850 **if** (fallback_mt == **MIGRATE_TYPES**) 2851 **break**; 2852

2853 **if** (**free_area_empty**(area, fallback_mt)) 2854 **continue**; 2855

2856 **if** (**can_steal_fallback**(order, migratetype)) 2857 \*can_steal = **true**; 2858

2859 **if** (!only_stealable) 2860 **return** fallback_mt; 2861

2862 **if** (\*can_steal) 2863 **return** fallback_mt; 2864 }

2865

2866 **return**-1;

2867 }

 

*Listing 2-66:* mm/page_alloc.c: [*find_suitable_fallback()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2838)

 

And [can_steal_fallback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2690) which it invokes as shown in Listing 2-67.

 

2678 */\**

2679 *\* When we are falling back to another migratetype during allocation, try to*

2680 *\* steal extra free pages from the same pageblocks to satisfy further* 2681 *\* allocations, instead of polluting multiple pageblocks.*

 



 

2682 *\**

2683 *\* If we are stealing a relatively large buddy page, it is likely there will*

2684 *\* be more free pages in the pageblock, so try to steal them all. For* 2685 *\* reclaimable and unmovable allocations, we steal regardless of page size,*

2686 *\* as fragmentation caused by those allocations polluting movable pageblocks*

2687 *\* is worse than movable allocations stealing from unmovable and reclaimable*

2688 *\* pageblocks.*

2689 *\*/*

2690 **static bool can_steal_fallback**(**unsigned int** order, **int** start_mt) 2691 {

2692 */\**

2693 *\* Leaving this order check is intended, although there is* 2694 *\* relaxed order check in next check. The reason is that* 2695 *\* we can actually steal whole pageblock if this condition met,* 2696 *\* but, below check doesn't guarantee it and that is just heuristic*

2697 *\* so could be changed anytime.* 2698 *\*/*

2699 **if** (order \>= pageblock_order) 2700 **return true**; 2701

2702 **if** (order \>= pageblock_order / 2 \|\| 2703 start_mt == **MIGRATE_RECLAIMABLE** \|\| 2704 start_mt == **MIGRATE_UNMOVABLE** \|\| 2705 page_group_by_mobility_disabled) 2706 **return true**; 2707

2708 **return false**;

2709 }

 

*Listing 2-67:* mm/page_alloc.c: [*can_steal_fallback()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2690)

 

The logic depends on the [fallbacks\[\]](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2586) array which encodes the primary

and secondary fallbacks for each migrate type, as shown in Table 2-8.

 

Table 2-8: Migrate type fallbacks

Migrate type Primary fallback Secondary fallback MIGRATE_UNMOVABLE MIGRATE_RECLAIMABLE MIGRATE_MOVABLE MIGRATE_MOVABLE MIGRATE_RECLAIMABLE MIGRATE_UNMOVABLE MIGRATE_RECLAIMABLE MIGRATE_UNMOVABLE MIGRATE_MOVABLE

 

Note that other migrate types do not have fallbacks.

The logic is as follows:

 

1. If the free list contains no pages, return -1 indicating that no suitable

fallback could be found.

2. Try the primary fallback, checking whether pages exist at the required

order and migrate type via [free_area_empty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n117)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n117) If not, try the secondary. If both fail, return -1 indicating that no suitable fallback could be found.

 



 

3. Set the can_steal output parameter to the result of [can_steal_fallback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2690).

This checks whether the order is greater than or equal to half of a page block (at which point we can treat the page block as be-ing majority the required migrate type once stolen), or if the allo-cation is MIGRATE_RECLAIMABLE or MIGRATE_UNMOVABLE we steal regard-less rather than mix unmovable pages in movable page blocks.

[page_group_by_mobility_disabled](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n450) will also cause a steal to always occur, however this is only relevant to systems with very low memory.

4. If only_stealable is not set (the case for any page_alloc.c allocation invoca-

tion) then we return the chosen migrate type, otherwise we only return it if can_steal has been set.

 

Examining [steal_suitable_fallback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2756) as shown in Listing 2-68.

 

2748 */\**

2749 *\* This function implements actual steal behaviour. If order is large enough,*

2750 *\* we can steal whole pageblock. If not, we first move freepages in this* 2751 *\* pageblock to our migratetype and determine how many already-allocated pages*

2752 *\* are there in the pageblock with a compatible migratetype. If at least half*

2753 *\* of pages are free or compatible, we can change migratetype of the pageblock*

2754 *\* itself, so pages freed in the future will be put on the correct free list.*

2755 *\*/*

2756 **static void steal_suitable_fallback**(**struct** zone \*zone, **struct** page \*page, 2757 **unsigned int** alloc_flags, **int** start_type, **bool** whole_block) 2758 {

2759 **unsigned int** current_order = **buddy_order**(page); 2760 **int** free_pages, movable_pages, alike_pages; 2761 **int** old_block_type; 2762

2763 old_block_type = **get_pageblock_migratetype**(page); 2764

2765 */\**

2766 *\* This can happen due to races and we want to prevent broken* 2767 *\* highatomic accounting.* 2768 *\*/*

2769 **if** (**is_migrate_highatomic**(old_block_type)) 2770 **goto single_page**; 2771

2772 */\* Take ownership for orders \>= pageblock_order \*/* 2773 **if** (current_order \>= pageblock_order) { 2774 **change_pageblock_range**(page, current_order, start_type); 2775 **goto single_page**; 2776 }

2777

2778 */\**

2779 *\* Boost watermarks to increase reclaim pressure to reduce the* 2780 *\* likelihood of future fallbacks. Wake kswapd now as the node* 2781 *\* may be balanced overall and kswapd will not wake naturally.*

 



 

2782 *\*/*

2783 **if** (**boost_watermark**(zone) && (alloc_flags & **ALLOC_KSWAPD**)) 2784 **set_bit**(**ZONE_BOOSTED_WATERMARK**, &zone-\>flags); 2785

2786 */\* We are not allowed to try stealing from the whole block \*/* 2787 **if** (!whole_block) 2788 **goto single_page**; 2789

2790 free_pages = **move_freepages_block**(zone, page, start_type, 2791 &movable_pages); 2792 */\**

2793 *\* Determine how many pages are compatible with our allocation.* 2794 *\* For movable allocation, it's the number of movable pages which* 2795 *\* we just obtained. For other types it's a bit more tricky.* 2796 *\*/*

2797 **if** (start_type == **MIGRATE_MOVABLE**) { 2798 alike_pages = movable_pages; 2799 } **else** {

2800 */\**

2801 *\* If we are falling back a RECLAIMABLE or UNMOVABLE*

*allocation*

2802 *\* to MOVABLE pageblock, consider all non-movable pages as*

2803 *\* compatible. If it's UNMOVABLE falling back to RECLAIMABLE*

*or*

2804 *\* vice versa, be conservative since we can't distinguish the*

2805 *\* exact migratetype of non-movable pages.* 2806 *\*/*

2807 **if** (old_block_type == **MIGRATE_MOVABLE**) 2808 alike_pages = pageblock_nr_pages 2809 - (free_pages + movable_pages)

;

2810 **else**

2811 alike_pages = 0; 2812 }

2813

2814 */\* moving whole block can fail due to zone boundary conditions \*/* 2815 **if** (!free_pages)

2816 **goto single_page**; 2817

2818 */\**

2819 *\* If a sufficient number of pages in the block are either free or of*

2820 *\* comparable migratability as our allocation, claim the whole block.*

2821 *\*/*

2822 **if** (free_pages + alike_pages \>= (1 \<\< (pageblock_order-1)) \|\| 2823 page_group_by_mobility_disabled) 2824 **set_pageblock_migratetype**(page, start_type); 2825

 



 

2826 **return**;

2827

2828 **single_page**:

2829 **move_to_free_list**(page, zone, current_order, start_type); 2830 }

 

*Listing 2-68:* mm/page_alloc.c: [*steal_suitable_fallback()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2756)

Examining the logic:

 

1. If the existing page block migrate type is set to MIGRATE_HIGHATOMIC due to

race conditions, then do not attempt to steal the whole page block and instead take the single_page branch.

2. If the required order is equal to or exceeds the page block order then

we simply change the migrate type of each page block in range, since for the allocation to be permitted they must all contain only free pages, then we invoke the single_page branch to move the pages to the new mi-grate type free list.

3. If neither of the above cases apply and we are able to do so we invoke

[boost_watermark()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2711) to add a watermark boost, then if ALLOC_KSWAPD is set we set the ZONE_BOSTED_WATERMARK bit to ensure kswapd, a kernel process which

performs indirect reclaim, is woken up. See Chapter 11 for details.

4. If we are not permitted to steal the whole page block to the new migrate

type, simply skip ahead to the single_page branch.

5. We are now at the point where we need to steal a block but the page

block potentially consists of a mix of allocated and free pages of the old migrate type. Free pages within the page block containing the page are

moved using [move_freepages_block()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2645) (and [move_freepages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2608)), being careful not to cross zone boundaries. The number of allocated, but movable pages is assigned to movable_pages. The number of free pages moved is returned and assigned to free_pages.

6. Next we calculate alike_pages, which is a count of the number of allo-

cated pages within the pageblock are compatible with the desired migrate type:

• If the target migrate type is movable, the number of pages is simply

equal to the number of allocated, movable pages within the page-block, i.e. movable_pages.

• Otherwise if the source page block is MIGRATE_MOVABLE, this is equal to

all unmovable pages within the page block.

• Otherwise if neither the source nor the target migrate type is

MIGRATE_MOVABLE we consider no pages to be alike. We do this to be conservative as we can’t easily distinguish between different non-movable migrate types.

7. If no free pages were moved in move_freepages_block() we jump to the

single_page branch.

8. Otherwise, we determine whether to change the page block migrate

type to the target by summing free_pages and alike_pages and seeing if

 



 

this is equal to or exceeds half the page block size (i.e. if the pages which are alike and the free pages that will have been moved between migrate types dominate the page block). If so we set the page block migratetype

via [set_pageblock_migratetype()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n625)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n625)

9. The single_page branch invokes [move_to_free_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1032) to ‘steal’ the page to

the target migrate type.

 

Examining [\_\_rmqueue_smallest()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2554) as shown in Listing 2-69.

 

2553 **static \_\_always_inline**

2554 **struct** page \***\_\_rmqueue_smallest**(**struct** zone \*zone, **unsigned int** order, 2555 **int** migratetype) 2556 {

2557 **unsigned int** current_order; 2558 **struct** free_area \*area; 2559 **struct** page \*page; 2560

2561 */\* Find a page of the appropriate size in the preferred list \*/* 2562 **for** (current_order = order; current_order \< **MAX_ORDER**; ++current_order

) {

2563 area = &(zone-\>free_area\[current_order\]); 2564 page = **get_page_from_free_area**(area, migratetype); 2565 **if** (!page) 2566 **continue**; 2567 **del_page_from_free_list**(page, zone, current_order); 2568 **expand**(zone, page, order, current_order, migratetype); 2569 **set_pcppage_migratetype**(page, migratetype); 2570 **trace_mm_page_alloc_zone_locked**(page, order, migratetype, 2571 **pcp_allowed_order**(order) && 2572 migratetype \< **MIGRATE_PCPTYPES**); 2573 **return** page; 2574 }

2575

2576 **return NULL**;

2577 }

 

*Listing 2-69:* mm/page_alloc.c: [*\_\_rmqueue_smallest()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2554)

 

This functions assumes the zone spinlock is being held and contains the

allocation part of the buddy algorithm:

 

1. Iterate through each order from the target page order to maximum.

2. Try to obtain a page for the target order and migrate type, using

[get_page_from_free_area()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n110) to obtain the page and [del_page_from_free_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1040) to delete it from the free list.

3. If successful invoke [expand()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2340) which, if an order higher than required was

allocated, places the unneeded pages back on the appropriate freelists.

 



 

4. Invoke [set_pcppage_migratetype()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n305) to set [struct page-\>index](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) to the migrate

type for convenience when this page is freed to a PCP list in= future.

Additionally we register a [trace event](https://kernel.org/doc/html/v6.0/trace/events.html) for this allocation.

 

Examining [expand()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2340) as shown in Listing 2-70.

 

2340 **static inline void expand**(**struct** zone \*zone, **struct** page \*page, 2341 **int** low, **int** high, **int** migratetype) 2342 {

2343 **unsigned long** size = 1 \<\< high; 2344

2345 **while** (high \> low) { 2346 high--;

2347 size \>\>= 1; 2348 **VM_BUG_ON_PAGE**(**bad_range**(zone, &page\[size\]), &page\[size\]); 2349

2350 */\**

2351 *\* Mark as guard pages (or page), that will allow to* 2352 *\* merge back to allocator when buddy will be freed.* 2353 *\* Corresponding page table entries will not be touched,* 2354 *\* pages will stay not present in virtual address space* 2355 *\*/*

2356 **if** (**set_page_guard**(zone, &page\[size\], high, migratetype)) 2357 **continue**; 2358

2359 **add_to_free_list**(&page\[size\], zone, high, migratetype); 2360 **set_buddy_order**(&page\[size\], high); 2361 }

2362 }

 

*Listing 2-70:* mm/page_alloc.c: [*expand()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2340)

 

As each page order represents a power of 2 splitting up a higher order

page simply consists of dividing a page into two of the order below, placing one of these on the appropriate free list and repeating the process for the other until we end up with the page we want to return and its buddy which is the last we place on a free list.

This will be invoked with high set to the order that was allocated and low

set to the required order and we loop high - low times, placing high - low pages onto freelists. Each loop starts by decrementing high meaning this field specifies the order of the page after splitting. The invocation of

[set_page_guard()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n860) is only relevant if CONFIG_DEBUG_PAGEALLOC is set so for brevity we will disregard it.

Throughout the iteration the size variable tracks the size, expressed

in base pages, of the split pages. We choose to free the latter portion of

the split page back to the freelist via [add_to_free_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1008) by referencing

&page\[size\], setting its buddy order correctly using [set_buddy_order()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n951)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n951)

 



 

This ultimately leaves a page of the required order at page. Since we are

about to remove this from its free list and provide it to a process we do not

need to set buddy order.

The kernel contains a mechanism for reserving a page block’s worth of

memory exclusively for high-order atomic allocations (allocations performed

where the kernel cannot sleep, e.g. under interrupt context) as shown in

Listing 2-71.

 

2869 */\**

2870 *\* Reserve a pageblock for exclusive use of high-order atomic allocations if*

2871 *\* there are no empty page blocks that contain a page with a suitable order*

2872 *\*/*

2873 **static void reserve_highatomic_pageblock**(**struct** page \*page, **struct** zone \*zone, 2874 **unsigned int** alloc_order) 2875 {

2876 **int** mt;

2877 **unsigned long** max_managed, flags; 2878

2879 */\**

2880 *\* Limit the number reserved to 1 pageblock or roughly 1% of a zone.*

2881 *\* Check is race-prone but harmless.* 2882 *\*/*

2883 max_managed = (zone_managed_pages(zone) / 100) + pageblock_nr_pages;

2884 **if** (zone-\>nr_reserved_highatomic \>= max_managed) 2885 **return**;

2886

2887 **spin_lock_irqsave**(&zone-\>lock, flags); 2888

2889 */\* Recheck the nr_reserved_highatomic limit under the lock \*/* 2890 **if** (zone-\>nr_reserved_highatomic \>= max_managed) 2891 **goto out_unlock**; 2892

2893 */\* Yoink! \*/*

2894 mt = **get_pageblock_migratetype**(page); 2895 */\* Only reserve normal pageblocks (i.e., they can merge with others)*

*\*/*

2896 **if** (**migratetype_is_mergeable**(mt)) { 2897 zone-\>nr_reserved_highatomic += pageblock_nr_pages; 2898 **set_pageblock_migratetype**(page, **MIGRATE_HIGHATOMIC**); 2899 **move_freepages_block**(zone, page, **MIGRATE_HIGHATOMIC**, **NULL**); 2900 }

2901

2902 **out_unlock**:

2903 **spin_unlock_irqrestore**(&zone-\>lock, flags); 2904 }

 

*Listing 2-71:* mm/page_alloc.c: [*reserve_highatomic_pageblock()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2873)

 



 

This is invoked by [get_page_from_freelist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4166) (see listing **??**) if the alloca-

tion is higher than order-0 and the ALLOC_HARDER flag is set (typically set for atomic allocations under memory pressure.) The page block is only moved

to MIGRATE_HIGHATOMIC if [migratetype_is_mergeable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n89) which indicates whether a migrate type can have fallbacks.

The use of this migrate type is covered in more detail in the reclaim

chapter. Examining [rmqueue_bulk()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3117) (With out-of-scope CMA logic removed)

as shown in Listing 2-72.

 

3112 */\**

3113 *\* Obtain a specified number of elements from the buddy allocator, all under*

3114 *\* a single hold of the lock, for efficiency. Add them to the supplied list.*

3115 *\* Returns the number of new pages which were placed at \*list.* 3116 *\*/*

3117 **static int rmqueue_bulk**(**struct** zone \*zone, **unsigned int** order, 3118 **unsigned long** count, **struct** list_head \*list, 3119 **int** migratetype, **unsigned int** alloc_flags) 3120 {

3121 **int** i, allocated = 0; 3122

3123 */\* Caller must hold IRQ-safe pcp-\>lock so IRQs are disabled. \*/* 3124 **spin_lock**(&zone-\>lock); 3125 **for** (i = 0; i \< count; ++i) { 3126 **struct** page \*page = **\_\_rmqueue**(zone, order, migratetype, 3127 alloc_flags);

3128 **if** (**unlikely**(page == **NULL**)) 3129 **break**; 3130

3131 **if** (**unlikely**(**check_pcp_refill**(page, order))) 3132 **continue**; 3133

3134 */\**

3135 *\* Split buddy pages returned by expand() are received here in*

3136 *\* physical page order. The page is added to the tail of* 3137 *\* caller's list. From the callers perspective, the linked*

*list*

3138 *\* is ordered by page number under some conditions. This is*

3139 *\* useful for IO devices that can forward direction from the*

3140 *\* head, thus also in the physical page order. This is useful*

3141 *\* for IO devices that can merge IO requests if the physical*

3142 *\* pages are ordered properly.* 3143 *\*/*

3144 **list_add_tail**(&page-\>pcp_list, list); 3145 allocated++;

. . .

3149 }

3150

3151 */\**

 



 

3152 *\* i pages were removed from the buddy list even if some leak due* 3153 *\* to check_pcp_refill failing so adjust NR_FREE_PAGES based* 3154 *\* on i. Do not confuse with 'allocated' which is the number of* 3155 *\* pages added to the pcp list.* 3156 *\*/*

3157 **\_\_mod_zone_page_state**(zone, NR_FREE_PAGES, -(i \<\< order)); 3158 **spin_unlock**(&zone-\>lock); 3159 **return** allocated; 3160 }

 

*Listing 2-72:* mm/page_alloc.c: [*rmqueue_bulk()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3117)

[rmqueue_bulk()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3117) attempts to remove count pages of order from zone’s

migratetype free list with alloc_flags set and adds them to list, returning the

number of pages actually allocated.

The heavy lifting is performed by the previously examined [\_\_rmqueue()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3080),

with page state being checked by [check_pcp_refill()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2426) which performs checks

to ensure returned pages are valid typically to avoid use-after-free bugs.

 

***2.8.7 New page preparation***

When a page is ready to be returned from the buddy allocator it needs to

have some final preparations applied. This is done via [prep_new_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2529) which

is called from [get_page_from_freelist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4166) and [\_\_alloc_pages_bulk()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5360). Examining

the code as shown in Listing 2-73.

 

2529 **static void prep_new_page**(**struct** page \*page, **unsigned int** order, **gfp_t**

gfp_flags,

2530 **unsigned int**

alloc_flags)

2531 {

2532 **post_alloc_hook**(page, order, gfp_flags); 2533

2534 **if** (order && (gfp_flags & **\_\_GFP_COMP**)) 2535 **prep_compound_page**(page, order); 2536

2537 */\**

2538 *\* page is set pfmemalloc when ALLOC_NO_WATERMARKS was necessary to*

2539 *\* allocate the page. The expectation is that the caller is taking*

2540 *\* steps that will free more memory. The caller should avoid the page*

2541 *\* being used for !PFMEMALLOC purposes.* 2542 *\*/*

2543 **if** (alloc_flags & **ALLOC_NO_WATERMARKS**) 2544 **set_page_pfmemalloc**(page); 2545 **else**

2546 **clear_page_pfmemalloc**(page); 2547 }

 

*Listing 2-73:* mm/page_alloc.c: [*prep_new_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2529)

 



 

All pages invoke [post_alloc_hook()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2467) which performs basic initialisation

which always includes:

 

• Clear [struct page-\>private](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) via [set_page_private()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n335).

• Set the ref count to 1 via [set_page_refcounted()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n157).

• Zero pages if configured to do so via [kernel_init_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1381) (e.g. if

\_\_GFP_ZERO is set).

 

Compound pages also invoke [prep_compound_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n809) which has already been

discussed in section 2.1.1.

 

**2.9 Freeing pages**

 

Pages allocated by the kernel are reference-counted as they can be use by multiple different processes (for instance memory shared between forked process por multiple references to a file mapping). The refer-

ence count is stored in the [struct page-\>\_refcount](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) field (or equivalently

[struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256)-\>\_refcount). This field tracks the number of ‘users’ of the page which is ultimately freed once this count reaches zero.

[get_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1093) or [folio_get()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1087) increments a page’s reference count and

[put_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1167) or [folio_put()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1122) decrements it (the \_refcount field should never be directly referenced).

[put_page_testzero()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n721) atomically decrement a page’s reference counter and

checks whether it has reached zero. This is used by all publicly exported page free functions.

Freeing of kernel pages is typically performed by [\_\_free_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5631), whether

via the slab allocator or directly. Userland pages are freed using folio which

invokes [release_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n934) (see section 7.1 for more details).

Ultimately all frees end up in one of two places – [free_unref_page_commit()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3435)

if freeing from PCP lists or [\_\_free_one_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1102) otherwise. These comprise the heart of the allocator’s freeing mechanism.

The logic for freeing pages is simpler than that of allocating them – allo-

cation might incur reclaim or require special handling (for example allocat-ing in an atomic context or with recursive file system locks held) – whereas freeing pages merely consists of deciding where to put them and coalescing them with free buddy pages if possible.

As the underlying mechanisms are not complicated there is no need to

visualise them in diagrammatic form, rather we examine the relevant func-tions directly.

There is, however, complexity around how exactly underlying functions

are invoked – there are many entry points to the freeing mechanism which take into account that pages being freed may be of order-0 or compound, may be being freed in bulk or not as well as the aforementioned reference

counting mechanism. We visualise this in Figure 2-22.

 



[put_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1167)

 

[\_\_pagevec_release()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n1026) [folio_put()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1122)

If [folio_put_testzero()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n727)

 

[put_pages_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n138) [release_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n934) [\_\_folio_put()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n121)

If [put_page_testzero()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n721) If [put_page_testzero()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n721)

 

Pages compound? Page compound?

 

no yes yes no

[free_unref_page_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3510) [\_\_folio_put_large()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n108) [\_\_folio_put_small()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n101)

Apply[\_\_page_cache_release()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n80) Apply[\_\_page_cache_release()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n80)

 

[free_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n326) [destroy_large_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n821) [free_unref_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3467)

(or couldn’t lock PCP)

[free_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5641) [free_compound_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n787) MIGRATE_ISOLATE?

yes no

If [put_page_testzero()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n721)

[\_\_free_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5631) [free_the_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n764) [free_one_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1607) [free_unref_page_commit()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3435)

Acquire zone-\>lock If pcp-\>count \>= high

yes

[\_\_free_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp.h?h=v6.0#n325) PCP order?

no

[\_\_free_pages_ok()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1697)

Acquirezone-\>lock

 

[\_\_free_one_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1102)

[free_pcppages_bulk()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1535)

Acquire zone-\>lock

 

*Figure 2-22: Freeing physical pages*

 

Note that:

 

• Denotes functions that are exported.

 

• Denotes the key functions which all others ultimately arrive at.

 

The two key functions for freeing pages are [free_unref_page_commit()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3435)

and [\_\_free_one_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1102)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1102) with the former freeing a page to the PCP lists

and the latter freeing a page to the underlying free lists. Let’s examine

free_unref_page_commit() first as shown in Listing 2-74.

 

3435 **static void free_unref_page_commit**(**struct** zone \*zone, **struct** per_cpu_pages \*

pcp,

3436 **struct** page \*page, **int** migratetype, 3437 **unsigned int** order) 3438 {

3439 **int** high;

3440 **int** pindex;

 



 

3441 **bool** free_high;

3442

3443 **\_\_count_vm_event**(PGFREE); 3444 pindex = **order_to_pindex**(migratetype, order); 3445 **list_add**(&page-\>pcp_list, &pcp-\>lists\[pindex\]); 3446 pcp-\>count += 1 \<\< order; 3447

3448 */\**

3449 *\* As high-order pages other than THP's stored on PCP can contribute*

3450 *\* to fragmentation, limit the number stored when PCP is heavily* 3451 *\* freeing without allocation. The remainder after bulk freeing* 3452 *\* stops will be drained from vmstat refresh context.* 3453 *\*/*

3454 free_high = (pcp-\>free_factor && order && order \<=

**PAGE_ALLOC_COSTLY_ORDER**);

3455

3456 high = **nr_pcp_high**(pcp, zone, free_high); 3457 **if** (pcp-\>count \>= high) { 3458 **int** batch = **READ_ONCE**(pcp-\>batch); 3459

3460 **free_pcppages_bulk**(zone, **nr_pcp_free**(pcp, high, batch,

free_high), pcp, pindex);

3461 }

3462 }

 

*Listing 2-74:* mm/page_alloc.c: [*free_unref_page_commit()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3435)

 

The initial part of the code is straightforward – we determine which PCP

list to place the page on, place it there and update stats. The only complexity that arises here is in determining when to free or pages from the PCP lists to the underlying free lists.

We determine when to flush PCP pages to free lists via [nr_pcp_high()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3417).

This calculates the effective high watermark of the current CPU’s PCP free pages.

When we have determined that PCP pages need to be flushed back to

free lists, we do so via [free_pcppages_bulk()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1535) which determines how many

pages we free via [nr_pcp_free()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3388)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3388)

We set the free_high variable if the PCP free_factor is set, the page is com-

pound and the page order is such that it is eligible to be present on PCP lists. While you might think this wouldn’t be necessary in a function specifi-cally designed for PCP page freeing, huge pages can also be present on PCP lists if transparent huge pages are enabled.

We examine [nr_pcp_high()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3417) in Listing 2-75.

 

3417 **static int nr_pcp_high**(**struct** per_cpu_pages \*pcp, **struct** zone \*zone, 3418 **bool** free_high) 3419 {

3420 **int** high = **READ_ONCE**(pcp-\>high); 3421

 



 

3422 **if** (**unlikely**(!high \|\| free_high)) 3423 **return** 0; 3424

3425 **if** (!**test_bit**(**ZONE_RECLAIM_ACTIVE**, &zone-\>flags)) 3426 **return** high; 3427

3428 */\**

3429 *\* If reclaim is active, limit the number of pages that can be* 3430 *\* stored on pcp lists* 3431 *\*/*

3432 **return min**(**READ_ONCE**(pcp-\>batch) \<\< 2, high); 3433 }

 

*Listing 2-75:* mm/page_alloc.c: [*nr_pcp_high()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3417)

 

We can see that, if no PCP high watermark is set (which should only be

the case in early kernel stages) or free_high is set, we indicate that flushing of

PCP lists should go ahead no matter what.

As the comment in listing 2-74 indicates, free_high is set in cases where

an allocation has been performed from a PCP list without a subsequent free

and the page is higher order. This is because higher order pages on PCP lists

are rather prone to causing fragmentation (higher order pages can always be

broken down into lower order ones, the reverse is not so). You’ll note that

the memory management subsystem contains a great many heuristics. These

are the results of optimisations based on real world experience.

Next, if reclaim is not indicated within the zone, we simply use the PCP

list’s designated high watermark level. If it is, then we select whichever is the

smaller of the batch size multiplied by 4 or the high water mark (typically the

former is considerably smaller). This is, again, a carefully tuned heuristic.

We can see that the PCP pages act as a per-core cache where pages are

preferentially allocated from and freed to. By doing so we avoid expensive

zone locks and thus improve performance of allocating and freeing memory.

Examining [nr_pcp_free()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3388) as shown in Listing 2-76.

 

3388 **static int nr_pcp_free**(**struct** per_cpu_pages \*pcp, **int** high, **int** batch, 3389 **bool** free_high) 3390 {

3391 **int** min_nr_free, max_nr_free; 3392

3393 */\* Free everything if batch freeing high-order pages. \*/* 3394 **if** (**unlikely**(free_high)) 3395 **return** pcp-\>count; 3396

3397 */\* Check for PCP disabled or boot pageset \*/* 3398 **if** (**unlikely**(high \< batch)) 3399 **return** 1; 3400

3401 */\* Leave at least pcp-\>batch pages on the list \*/* 3402 min_nr_free = batch;

 



 

3403 max_nr_free = high - batch; 3404

3405 */\**

3406 *\* Double the number of pages freed each time there is subsequent*

3407 *\* freeing of pages without any allocation.* 3408 *\*/*

3409 batch \<\<= pcp-\>free_factor; 3410 **if** (batch \< max_nr_free) 3411 pcp-\>free_factor++; 3412 batch = **clamp**(batch, min_nr_free, max_nr_free); 3413

3414 **return** batch;

3415 }

 

*Listing 2-76:* mm/page_alloc.c: [*nr_pcp_free()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3388)

 

In line with its affect on [nr_pcp_high()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3417)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3417) if free_high is set we clear all PCP

pages rather than a batch. Also, if the PCP is disabled or we are in the boot phase, we free a page a time.

In most cases however, we observe the following process:

 

• Set bounds: min_nr_free set to the batch size and max_nr_free set to the

PCP high watermark value minus a batch. This means we always free at least a batch, but always leave at least one batch size of pages on the PCP.

• Multiply the batch size by 2free_factor and increase free_factor if this in-

crease does not exceed the maximum permissible number of pages to

drain. As discussed in section 2.7.3, this is a heuristic which ensures that pages stored on PCP lists are proportionate to pages allocated from them, exponentially increasing the number of pages drained back to free lists if intervening allocations do not occur.

• Finally, we clamp the number of pages to drain to a range within

min_nr_free to max_nr_free.

 

[free_pcppages_bulk(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1535)as the name suggests, frees a number of PCP pages

in bulk as shown in Listing 2-77.

 

1535 **static void free_pcppages_bulk**(**struct** zone \*zone, **int** count, 1536 **struct** per_cpu_pages \*pcp, 1537 **int** pindex) 1538 {

1539 **int** min_pindex = 0; 1540 **int** max_pindex = **NR_PCP_LISTS**- 1; 1541 **unsigned int** order; 1542 **bool** isolated_pageblocks; 1543 **struct** page \*page; 1544

1545 */\**

1546 *\* Ensure proper count is passed which otherwise would stuck in the*

1547 *\* below while (list_empty(list)) loop.*

 



 

1548 *\*/*

1549 count = **min**(pcp-\>count, count); 1550

1551 */\* Ensure requested pindex is drained first. \*/* 1552 pindex = pindex - 1; 1553

1554 */\* Caller must hold IRQ-safe pcp-\>lock so IRQs are disabled. \*/* 1555 **spin_lock**(&zone-\>lock); 1556 isolated_pageblocks = **has_isolate_pageblock**(zone); 1557

1558 **while** (count \> 0) {

. . .

1602 }

1603

1604 **spin_unlock**(&zone-\>lock); 1605 }

 

*Listing 2-77:* mm/page_alloc.c: [*free_pcppages_bulk()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1535) *top level*

This initially:

 

• Performs a sanity check to ensure that we only attempt to free as many

pages as are available.

• Decrements the pindex by one (the index into the PCP list determined by

order and migrate type) in order that the inner loop which initially in-crements this causes the freed page’s order/migrate type to be drained first.

• Acquires a zone lock around the inner loop.

• Determines whether the zone contains any MIGRATE_ISOLATE pageblocks

via [has_isolate_pageblock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-isolation.h?h=v6.0#n6) which checks the zone’s nr_isolate_pageblock counter to do so.

 

Before invoking the inner loop until count has reached zero (this counts

the name of base pages to be drained) as shown in Listing 2-78.

 

1559 **struct** list_head \*list; 1560 **int** nr_pages; 1561

1562 */\* Remove pages from lists in a round-robin fashion. \*/* 1563 **do** {

1564 **if** (++pindex \> max_pindex) 1565 pindex = min_pindex; 1566 list = &pcp-\>lists\[pindex\]; 1567 **if** (!**list_empty**(list)) 1568 **break**; 1569

1570 **if** (pindex == max_pindex) 1571 max_pindex--; 1572 **if** (pindex == min_pindex)

 



 

1573 min_pindex++; 1574 } **while** (1); 1575

1576 order = **pindex_to_order**(pindex); 1577 nr_pages = 1 \<\< order; 1578 **BUILD_BUG_ON**(**MAX_ORDER** \>= (1\<\<**NR_PCP_ORDER_WIDTH**)); 1579 **do** {

1580 **int** mt; 1581

1582 page = **list_last_entry**(list, **struct** page, pcp_list); 1583 mt = **get_pcppage_migratetype**(page); 1584

1585 */\* must delete to avoid corrupting pcp list \*/* 1586 **list_del**(&page-\>pcp_list); 1587 count -= nr_pages; 1588 pcp-\>count -= nr_pages; 1589

1590 **if** (**bulkfree_pcp_prepare**(page)) 1591 **continue**; 1592

1593 */\* MIGRATE_ISOLATE page should not go to pcplists \*/*

1594 **VM_BUG_ON_PAGE**(is_migrate_isolate(mt), page); 1595 */\* Pageblock could have been isolated meanwhile \*/*

1596 **if** (**unlikely**(isolated_pageblocks)) 1597 mt = **get_pageblock_migratetype**(page); 1598

1599 **\_\_free_one_page**(page, page_to_pfn(page), zone, order,

mt, FPI_NONE);

1600 **trace_mm_page_pcpu_drain**(page, order, mt); 1601 } **while** (count \> 0 && !**list_empty**(list));

 

*Listing 2-78:* mm/page_alloc.c: [*free_pcppages_bulk()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1535) *inner loop*

 

Examining the logic:

 

• As the comment suggests, we begin by traversing PCP lists in a round-

robin fashion, beginning with the order and migrate type of the page being freed. Since PCP lists are laid out by migrate type for each order, this means we free pages of each migrate type in order from unmovable, movable, and reclaimable at each increasing order until we wrap around to the lowest order and migrate type.

• We take the last page in the PCP list and use [get_pcppage_migratetype()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n300) to

retrieve its migrate type. This was placed in the index field of the PCP

page’s [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) to optimise lookup.

• The page is deleted from the PCP free list and stats are updated.

[bulkfree_pcp_prepare()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1524) is invoked which in turn calls [check_free_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1292) (more if CONFIG_DEBUG_VM is set) to ensure the page is as expected.

 



 

• If there are isolated pageblocks within the zone, the PCP page might

have been isolated since being freed so to be safe we retrieve the page block designated migrate type in this instance.

• Finally, we invoke [\_\_free_one_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1102) to perform the heavy lifting of actu-

ally freeing the pages. This function assumes a zone lock is held.

 

**2.9.0.1 FPI flags**

Free Page Internal (FPI) flags adjust page free behaviour.

Examining the signature of [\_\_free_one_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1102) as shown in Listing 2-79.

 

1102 **static inline void \_\_free_one_page**(**struct** page \*page, 1103 **unsigned long** pfn, 1104 **struct** zone \*zone, **unsigned int** order, 1105 **int** migratetype, **fpi_t** fpi_flags)

 

*Listing 2-79:* mm/page_alloc.c: [*\_\_free_one_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1102) *signature*

 

We can see that there is a fpi_flags parameter of type [fpi_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n87)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n87) This declares

flags which impact page free behaviour:

 

• [FPI_NONE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n90) – No impact on freeing behaviour.

• [FPI_SKIP_REPORT_NOTIFY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n100) – This interacts with the [free page reporting](https://kernel.org/doc/html/v6.0/vm/free_page_reporting.html) mecha-

nism to indicate that no such report should be generated for this page.

• [FPI_TO_TAIL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n112) – Forces pages to be freed to the back of the relevant free list.

This is an optimisation used in specific instances where shuffling pages (the usual behaviour) is known to be unnecessary or inappropriate.

• [FPI_SKIP_KASAN_POISON](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n123) – The linux kernel address sanitiser [(](https://kernel.org/doc/html/v6.0/dev-tools/kasan.html)[KASAN](https://kernel.org/doc/html/v6.0/dev-tools/kasan.html)[)](https://kernel.org/doc/html/v6.0/dev-tools/kasan.html) is a

mechanism that is intended to catch errors in dynamic memory alloca-tion. One part of its operation is to ‘poison’, i.e. uniquely mark unused pages with a recognisable pattern that can be detected and highlighted as a use-after-free. This flag causes this not to be done for pages where this is not appropriate.

 

These flags all specify bits in a bit field so they can be combined as

needed.

 

***2.9.1 \_\_free_one_page()***

Examining the top-level logic of [\_\_free_one_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1102) as shown in Listing 2-80.

 

1102 **static inline void \_\_free_one_page**(**struct** page \*page, 1103 **unsigned long** pfn, 1104 **struct** zone \*zone, **unsigned int** order, 1105 **int** migratetype, **fpi_t** fpi_flags) 1106 {

1107 **struct** capture_control \*capc = **task_capc**(zone); 1108 **unsigned long** buddy_pfn; 1109 **unsigned long** combined_pfn;

 



 

1110 **struct** page \*buddy; 1111 **bool** to_tail;

1112

1113 **VM_BUG_ON**(!**zone_is_initialized**(zone)); 1114 **VM_BUG_ON_PAGE**(page-\>flags & **PAGE_FLAGS_CHECK_AT_PREP**, page); 1115

1116 **VM_BUG_ON**(migratetype == -1); 1117 **if** (**likely**(!**is_migrate_isolate**(migratetype))) 1118 **\_\_mod_zone_freepage_state**(zone, 1 \<\< order, migratetype); 1119

1120 **VM_BUG_ON_PAGE**(pfn & ((1 \<\< order) - 1), page); 1121 **VM_BUG_ON_PAGE**(**bad_range**(zone, page), page); 1122

1123 **while** (order \< **MAX_ORDER**- 1) {

. . .

1161 }

. . .

1181 }

 

*Listing 2-80:* mm/page_alloc.c: [*\_\_free_one_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1102) *top-level logic*

 

The code performs the following steps:

 

1. Initial setup and sanity checks.

2. Merge loop – This is the part of the code that implements the coalescing

part of the buddy allocator, i.e. checking whether the page’s buddy is free, if so coalescing into an order-order + 1 page and looping round and trying to coalesce that block. This is why the loop iterates up to but not including the maximum allowed order of MAX_ORDER - 1, since each iteration may result in coalescing to a order + 1 page.

3. Add page to free list – Finally the logic adds the page to the appropriate

free list.

 

Note that the code refers to compaction via [struct capture_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n432), how-

ever this is out of scope for this chapter, see the chapter on compaction and migration for more on this.

Examining the [\_\_free_one_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1102) merge loop as shown in Listing 2-81.

 

1124 **if** (**compaction_capture**(capc, page, order, migratetype)) { 1125 **\_\_mod_zone_freepage_state**(zone, -(1 \<\< order), 1126 migratetype);

1127 **return**; 1128 }

1129

1130 buddy = **find_buddy_page_pfn**(page, pfn, order, &buddy_pfn); 1131 **if** (!buddy) 1132 **goto done_merging**; 1133

1134 **if** (**unlikely**(order \>= pageblock_order)) {

 



 

1135 */\** 1136 *\* We want to prevent merge between freepages on*

*pageblock*

1137 *\* without fallbacks and normal pageblock. Without*

*this,*

1138 *\* pageblock isolation could cause incorrect freepage*

*or CMA*

1139 *\* accounting or HIGHATOMIC accounting.* 1140 *\*/* 1141 **int** buddy_mt = **get_pageblock_migratetype**(buddy); 1142

1143 **if** (migratetype != buddy_mt 1144 && (!**migratetype_is_mergeable**(

migratetype) \|\|

1145 !**migratetype_is_mergeable**(

buddy_mt)))

1146 **goto done_merging**; 1147 }

1148

1149 */\**

1150 *\* Our buddy is free or it is CONFIG_DEBUG_PAGEALLOC guard*

*page,*

1151 *\* merge with it and move up one order.* 1152 *\*/*

1153 **if** (**page_is_guard**(buddy)) 1154 **clear_page_guard**(zone, buddy, order, migratetype); 1155 **else**

1156 **del_page_from_free_list**(buddy, zone, order); 1157 combined_pfn = buddy_pfn & pfn; 1158 page = page + (combined_pfn - pfn); 1159 pfn = combined_pfn; 1160 order++;

 

*Listing 2-81:* mm/page_alloc.c: [*\_\_free_one_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1102) *merge loop*

 

This code is invoked while order \< MAX_ORDER - 1. Examining the logic

(noting that, again, we defer discussion of compaction code to the relevant

chapter):

 

1. Find buddy page – This is the key step in the merging process – we

need to determine if there is a page we can coalesce this one with via

[find_buddy_page_pfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n327) (this makes use of the buddy allocator algorithm

described in section 2.7.1 and the previous chapter). If no such page exists we exit the loop as no further coalescing is possible.

2. Check if cross a page block boundary – If we are page block order or

above then we are merging pages across two page blocks. As we heuristi-cally assign migrate type by page block, we need to check to ensure that the buddy’s migrate type is mergeable with the page we are coalescing

 



 

it into (ultimately we will place the coalesced page on a free list of the

original page’s migrate type). We do this via [migratetype_is_mergeable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n89).

3. Remove the buddy page from its free list – Finally we remove the buddy

page from its free list, then update the PFN, page and order accordingly before looping to see if we can coalesce again.

 

Finally after any coalescing has taken place we add our newly merged

page to the appropriate free list as shown in Listing 2-82.

 

1163 **done_merging**:

1164 **set_buddy_order**(page, order); 1165

1166 **if** (fpi_flags & **FPI_TO_TAIL**) 1167 to_tail = **true**; 1168 **else if** (**is_shuffle_order**(order)) 1169 to_tail = **shuffle_pick_tail**(); 1170 **else**

1171 to_tail = **buddy_merge_likely**(pfn, buddy_pfn, page, order); 1172

1173 **if** (to_tail)

1174 **add_to_free_list_tail**(page, zone, order, migratetype); 1175 **else**

1176 **add_to_free_list**(page, zone, order, migratetype); 1177

1178 */\* Notify page reporting subsystem of freed page \*/* 1179 **if** (!(fpi_flags & **FPI_SKIP_REPORT_NOTIFY**)) 1180 **page_reporting_notify_free**(order);

 

*Listing 2-82:* mm/page_alloc.c: [*\_\_free_one_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1102) *add page to free list*

 

Other than free page reporting (out of scope for this book), the only

complexity here is the decision of whether to add a page to the head or the tail of the free list. If FPI_TO_TAIL is set the algorithmic mechanism is overridden, otherwise we start by determining if a memory shuffle need

occur via [is_shuffle_order()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/shuffle.h?h=v6.0#n28)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/shuffle.h?h=v6.0#n28) This is only applicable for order-10 pages and only if CONFIG_SHUFFLE_PAGE_ALLOCATOR is set (this is a feature that is de-signed to make the page allocator more efficient in the presence of a direct-mapping memory-side-cache. This topic is out of scope for the book). If so,

[shuffle_pick_tail()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/shuffle.c?h=v6.0#n162) is called to randomly select whether to place to page on the tail of the free list or not.

Under ordinary circumstances whether to place the page on the tail of

the free list is determined by [buddy_merge_likely()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1062)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1062) As the name suggests this determines whether pages are likely to be merged soon. If they are, it is a good idea to put the page on the tail of the list so it doesn’t get allocated soon (and thus made unavailable for merging).

After choosing where to put the page, [add_to_free_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1008) or

[add_to_free_list_tail()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1018) is called as appropriate.

Examining [buddy_merge_likely()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1062) as shown in Listing 2-83.

 



 

1053 */\**

1054 *\* If this is not the largest possible page, check if the buddy* 1055 *\* of the next-highest order is free. If it is, it's possible* 1056 *\* that pages are being freed that will coalesce soon. In case,* 1057 *\* that is happening, add the free page to the tail of the list* 1058 *\* so it's less likely to be used soon and more likely to be merged* 1059 *\* as a higher order page* 1060 *\*/*

1061 **static inline bool**

1062 **buddy_merge_likely**(**unsigned long** pfn, **unsigned long** buddy_pfn, 1063 **struct** page \*page, **unsigned int** order) 1064 {

1065 **unsigned long** higher_page_pfn; 1066 **struct** page \*higher_page; 1067

1068 **if** (order \>= **MAX_ORDER**- 2) 1069 **return false**; 1070

1071 higher_page_pfn = buddy_pfn & pfn; 1072 higher_page = page + (higher_page_pfn - pfn); 1073

1074 **return find_buddy_page_pfn**(higher_page, higher_page_pfn, order + 1, 1075 **NULL**) != **NULL**; 1076 }

 

*Listing 2-83:* mm/page_alloc.c: [*buddy_merge_likely()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n1062)

 

The key thing to note here is that we are examining pages at order + 1

which might be merged into a page of order + 2 (if pages of order order were

mergeable to order + 1 we would have already merged them).

In effect we are checking whether, should this page’s buddy get freed,

would that result in a merge to order + 2? We achieve this by simply invoking

[find_buddy_page_pfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n327) for order + 1 to see if its buddy is available.

 

