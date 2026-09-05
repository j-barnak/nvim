
 

**7**

 

**R E V E R S E M A P P I N G S**

 

When we try to reclaim or migrate memory, we oper-

ate at the folio level. We need the ability to efficiently

look up VMAs which map that memory in order that

we can ensure the mapping correctly accounts for the

change in the physical pages which back it. The means

by which we map in reverse from the folio to VMAs

is termed the ’reverse mapping’, which we explore in

this chapter.

A key operation within the kernel is looking up the VMAs which map a

given folio. Consider the motivating example of reclaim trying to unmap a

freed page from the VMAs which reference it (via [try_to_unmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1812)) – in reclaim

we only have the folio, so we need to be able to discover which VMAs it is

mapped into (remembering that forking means a single anonymous page

could be mapped into many processes as Copy-on-Write mappings). This

is termed the folio’s reverse mapping (the ‘forward’ mapping being the page

table mappings from virtual address to physical).

VMAs are ephemeral by nature – they can be split, merged and forked,

and thus have many-to-many relationships spanning process address spaces.

In this section we will focus on how we trace back folios to their VMAs dur-

ing VMA lifetime.


 

***7.0.1 Anonymous reverse mappings***

This is a confusing topic so let’s examine things from first principles – con-sider what would happen if we simply mapped each folio directly to a single VMA – immediately this would be unworkable, as on fork a folio is refer-enced by two different VMAs in two different processes, each set to Copy-on-Write.

How about each folio maintaining a list of related VMAs? This would be

unworkable as there would both be substantial duplication and it would be prohibitively inefficient to perform splitting, merging and forking opera-tions.

We must therefore maintain an intermediary object which folios can point

to. We access this via the [struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256)-\>mapping field. If the folio is part of the

page cache, this field points to a [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) object which describes

a page cache object (typically a file), otherwise it points to a [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) object which describes a set of anonymous folios.

Firstly let’s examine how a newly initialised [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) object and its

related [struct anon_vma_chain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82) (AVC) and [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) objects interact, noting that:-

 

A

• Denotes that B is a member of a list declared in A.

B

A

• Denotes that B is a node in a red/black tree rooted in A.

B

 

[vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403)

.anon_vma

.anon_vma_chain

 

[anon_vma_chain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82)

.vma

.anon_vma

.same_vma

.rb

 

[anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31)

.root

.num_children = 1

.num_active_vmas = 1

.parent

.rb_root

 

*Figure 7-1: Initial* [*struct anon_vma*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) *state*

 



 

It’s important to note that a newly initialised VMA object will not have a

[struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) object allocated or attached to it until anonymous folios are

faulted in. We will examine this more closely when we examine the related

code in detail.

The [struct anon_vma_chain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82) (AVC) object sits between [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403)

(VMA) and anon_vma objects and allows each VMA to maintain a list of

anon_vma objects containing folios mapped into it. Its usefulness will become

apparent as we work through more examples.

We maintain an interval tree \* between each anon_vma and anon_vma_chain

object, rooted in the anon_vma.rb_root field, with each node kept in the

anon_vma_chain.rb field. This is keyed by the [folio-\>index](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) field which is

set to the virtual page offset† of the address at which it is mapped (via

[\_\_page_set_anon_rmap()) ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1129)and determines each folio’s offset within the map-

ping.

This is critical, as after a VMA split different folios can map to different

VMAs depending on their offset within the mapping, so when trying to de-

termine the VMA with which a folio is associated we need to be able to do so

efficiently. In addition we try to merge adjacent anon_vma objects where possi-

ble, so the ability for a single object to span many mappings is very useful.

Each anon_vma maintains pointers to parent and root anon_vma objects

which are updated on process fork and define the fork hierarchy. Locking

is performed using the root anon_vma’s rwsem semaphore for all objects in the

hierarchy.

The number of anon_vma objects whose parent field points at this anon_vma

is tracked in the num_children field, which is primarily used to permit reuse of

empty anon_vma objects.

Each VMA backed by anonymous memory points to an anon_vma object

which newly faulted-in memory will be mapped to. The number of VMAs

that point to an anon_vma is tracked in the num_active_vmas field, which can also

be utilised to permit reuse of empty anon_vma objects.

The root and parent fields are initialised to point to the [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31)

itself as we will need to use the only lock available to us and on unlinking

this root object, decrementing the parent’s num_children count indeed should

decrement this object’s count. The initial case is trivial, things get more in-

teresting once we fork a process:-

 

\*. An interval tree is a red/black search tree which makes it easy to traverse ordered interval

ranges.

†. The virtual page offset of a folio is its mapped virtual address divided by the page size. If you

imagine all base pages of virtual memory to be an array, this would be an entry’s index. Note

that if a VMA is moved via [mremap()](https://man7.org/linux/man-pages/man2/mremap.2.html)[,](https://man7.org/linux/man-pages/man2/mremap.2.html) the original virtual page offset is retained.

 



 

Parent process Child process

 

[vm_area_struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403)

.anon_vma .anon_vma .anon_vma_chain .anon_vma_chain

 

[anon_vma_chain anon_vma_chain anon_vma_chain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82)

.vma .vma .vma .anon_vma .anon_vma .anon_vma .same_vma .same_vma .same_vma .rb .rb .rb

 

[anon_vma anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) .root .root .num_children = 2 .num_children = 0 .num_active_vmas = 1 .num_active_vmas = 1 .parent .parent .rb_root .rb_root

 

*Figure 7-2: Forked* [*struct anon_vma*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31)

 

After the process forks we have two sets of folios we need to track – those

belonging to the parent process which are mapped into the child process as Copy-on-Write, and folios that been written to and therefore copied.

In order to manage these two sets of folios, we must maintain two sepa-

rate [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) objects – the existing one associated with the parent pro-cess one which represents the CoW folios and a new one which represents folios which have been copied and is linked to the child process.

Since the child process’s VMA can reference the parent’s CoW folios, we

need to connect the parent’s anon_vma to the child’s VMA so CoW folios are able to reference back to both VMAs, as well as providing a link in the other direction so VMA operations can be performed for both VMAs correctly.

However, once a folio is copied to the child process (and this is no longer

CoW), it can only be associated with the child VMA, so we need to maintain a link between the new anon_vma and only the child VMA.

The above demonstrates that we must maintain separate interval trees of

VMAs for each anon_vma and separate lists of anon_vmas for each VMA since CoW implies that parent and child process address spaces have asymmetric dependencies upon each other’s anonymous folios.

 



 

Since no node can exist in more than one tree at any one time, nor can

one list node exist in more than one list at the same time\*, we must maintain

entirely separate trees for each anon_vma and entirely separate lists for each

VMA.

In order to achieve this we introduce the [struct anon_vma_chain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82) (AVC)

type – which simply act as nodes connecting VMAs and anon_vma objects,

each representing a connection between a specific VMA and anon_vma. Each

VMA owns its own AVCs, storing them on their anon_vma_chain list, each of

which can reference any anon_vma object.

Note that the interval tree entries for the parent and child

VMAs of the shared anon_vma will have the same keys, meaning that

looking up folios in the address range will return both VMAs (via

[anon_vma_interval_tree_foreach()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2572)).

Another means by which reverse mapping manipulations can occur is

VMA splitting and merging (see section 5.1 for more details), for which

these mechanisms remain equally useful.

Consider a series of folios, each of which are associated with a VMA,

which shortly afterwards has its middle portion unmapped. We now split

the VMA into two, but it would be inefficient to adjust each folio to point at

different anon_vma objects.

This is where the interval tree structure comes into its own – we can sim-

ply remove all AVCs associated with the VMA from the anon_vma’s interval

tree, create a new VMA and associated AVC, then link to the appropriate

AVC based on the [struct folio-\>index](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) field:-

 

\*. To see why, consider what make up these data structures – list nodes can only reference pre-

vious and subsequent nodes, so there is simply no way to link two lists together without them

becoming one aggregate list, equally binary tree nodes must reference up to two nodes below

them, traversing from one tree to another is not possible.

 



[vm_area_struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) .anon_vma .anon_vma .anon_vma_chain .anon_vma_chain

 

[anon_vma_chain anon_vma_chain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82) .vma .vma .anon_vma .anon_vma .same_vma .same_vma .rb .rb

 

[anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31)

.root

.num_children = 1

.num_active_vmas = 2

.parent

.rb_root

 

*Figure 7-3:* [*struct anon_vma*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) *state after VMA split*

 

Here we simply create a new [anon_vma_chain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82) object for the newly split

VMA, link both VMAs to the [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) object (as both will place new folios in this block), and link the anon_vma object to both AVC objects in the interval tree, mapping each part of the split range to their respective VMAs.

Again, the AVC object represents a connection between a VMA and an

anon_vma object, acting as the ‘glue’ between these objects. It’s clear here that this structure allows for arbitrary VMA manipulation and forking.

Something worth noting here is that in each instance where we have

needed to create a new AVC object, we have made at least one copy of the connection to a preexisting anon_vma object.

A VMA of a forked child process needs to reference CoW pages and a

split VMA needs to reference the shared anon_vma. Note that if the VMA be-ing copied from had more than 1 AVC object, it follows that we would want to copy all of them (as each of them reference things the copying VMA must also reference).

We will return to this shortly, as cloning an anon_vma is precisely how this

functionality is implemented.

Let’s examine what happens after figure 7-3 is merged back together:-

 



[vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403)

.anon_vma

.anon_vma_chain

 

[anon_vma_chain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82)

.vma

.anon_vma

.same_vma

.rb

 

[anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31)

.root

.num_children = 1

.num_active_vmas = 1

.parent

.rb_root

 

*Figure 7-4:* [*struct anon_vma*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) *state after split VMAs merged*

 

As you can see, this is identical to figure 7-1, i.e. the original state is re-

stored. The kernel endeavours to ensure that each [struct anon_vma_chain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82) ob-

ject denotes a connection between distinct [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) and

[struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) objects.

What about the merge of two separate VMAs with independent anon_vma

objects? This is prohibited and contiguous VMAs remain separate. This is

because a VMA can designate one and only one anon_vma object to map newly

faulted folios to and it would be prohibitively expensive to remap folios to

a single anon_vma. This is checked by [is_mergeable_anon_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1015)), which we will

examine in detail shortly:-

 



[vm_area_struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) .anon_vma .anon_vma .anon_vma_chain .anon_vma_chain

 

[anon_vma_chain anon_vma_chain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82) .vma .vma .anon_vma .anon_vma .same_vma .same_vma .rb .rb

 

[anon_vma anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) .root .root .num_children = 1 .num_children = 1 .num_active_vmas = 1 .num_active_vmas = 1 .parent .parent .rb_root .rb_root

 

*Figure 7-5: VMAs with separate* [*struct anon_vma*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31)[*s*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) *after attempted merge*

 

***7.0.2 Key points***

Since this is such a complicated and confusing topic, let’s highlight some useful key points which can help us reason about anonymous reverse mappings:-

 

• The purpose of a reverse mapping is simply to be able to locate all the

VMAs which map a given folio.

• Each [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) object simply represents a collection of folios which

are used for anonymous mappings. They exist because VMAs are sub-ject to a lot of change and it would be slow to look up folios each time this happened, so instead we map folios to this object.

• A [struct anon_vma_chain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82) (AVC) object simply represents a connection be-

tween a VMA and an anon_vma.

• There exists one and only one AVC object connecting any distinct pair

of VMA and anon_vma objects.

• Each AVC connects in both directions – VMAs are able to determine

which anon_vma objects they potentially map using the list headed by their anon_vma_chain field, and anon_vma objects can determine VMAs via their interval tree rooted in their rb_root field.

• Each anon_vma object can reference multiple different VMAs using the

AVC objects as connectors using its interval tree rooted in rb_root.

• We determine which VMA belongs to which folio by using the folio’s

index field, which for anonymous mappings specifies the virtual page off-set of the folio. This is then indexed into the interval tree rooted in the

 



 

anon_vma’s rb_root field to obtain an AVC from which we can determine the VMA.

• The whole reason for this complexity is that VMAs can be split and

merged as memory is mapped, unmapped and modified by things such

as [mprotect()](https://man7.org/linux/man-pages/man2/mprotect.2.html) and most vexingly of all – forking of processes.

• If a VMA has more than one entry in its anon_vma_chain list this means

the memory it maps is forked from a parent process, thus you can de-termine whether a VMA is a ‘child VMA’ by checking the length of this list.

• The fact that forking exists means that an anon_vma can reference VMAs

from multiple different processes.

• The fact that VMAs can be split and we try to reuse adjacent VMA

anon_vma objects, an anon_vma object can also reference multiple VMAs in the same process.

• anon_vma objects themselves exist in a tree (technically it’s not a tree as

the root of the tree connects to itself, but within the kernel it’s referred to as a tree). This is used to to keep a track of child node count for the purposes of potential anon_vma reuse and to link each anon_vma to its root in order to both share an anon_vma lock across the entire fork hierarchy and to enable us to keep track of un-CoW’d, shared folios.

• Looking up VMAs from the reverse mapping when a fork has occurred

can result in VMAs that may contain the folio being sought – as it may have since been CoW’d to a child process. It is up to the code ‘walking’

the reverse mapping (see section 9.9.3) to determine whether the folio actually is present in that VMA. Mappings can change at any time, so

this must in general be checked. See section 7.0.16 for more on this.

 

***7.0.3 File reverse mappings***

We touch on the page cache in Chapter **??** and cover it in substantial detail

in the page cache chapter, however the reverse mapping logic is relatively

straightforward, so let’s examine this here.

Life is substantially easier for shared file-backed reverse mappings as split-

ting/merging of VMAs and forking of processes doesn’t change the fact

that, fundamentally, the same underlying object is referenced and thus

the complex machinery required for anonymous reverse mappings can be

avoided.

The page cache equivalent of the anon_vma object described above is the

[struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) object. This represents an object in the page cache, usu-

ally a file and a VMA references this in its vm_file field via a [struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) ob-

ject (which represents a process’s open file).

Similar to anonymous reverse mappings a page cache folio maps to its

address_space via the folio’s mapping field, with its offset into the mapping

specified via its index field.

Obtaining VMAs that may map a cache entry is straightforward – the

i_mmap field is a red/black interval tree containing VMA nodes contained

 



 

within each VMA’s shared.rb union field (the lack of Copy-on-Write obviates the need for an intermediate object equivalent to anon_vma_chain).

*Figure 7-6: Page cache-backed reverse mapping*

 

[vm_area_struct vm_area_struct vm_area_struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) .shared.rb .shared.rb .shared.rb .shared.rb .vm_file .vm_file .vm_file .vm_file

 

[file file file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940)

.f_mapping .f_mapping .f_mapping

 

[address_space address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)

.i_mmap .i_mmap .i_pages .i_pages

 

[folio folio folio folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256)

.mapping .mapping .mapping .mapping

 

Each page cache-backed folio provides a reverse mapping via the mapping

field pointing at the [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) object representing the page cache entry.

Each address_space has an i_mmap field which is the root of a red/black in-

terval tree of [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) objects which are keyed on each

[struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256)’s index field which indicates the page offset of this folio within the page cache entry (as opposed to anonymous page folios which put vir-tual page offset in this field). We can do so as these folios will only ever span a single page cache entry.

File-backed VMAs can split and merge just like their anonymous counter-

parts, differing in that the same address_space is always referenced. On the

other hand, each [struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) references an open file with a specific offset and are, by their nature, ephemeral.

Separate VMAs within the same process may reference the same file

object (e.g. if a file-backed VMA is split by having a page in the middle un-mapped), or entirely distinct file objects (e.g. mapped from different file descriptors).

Forked shared file mappings continue to reference the same address_space

underneath, so we don’t need an additional data structure sat between this object and VMAs to account for this and can therefore simply reference VMAs directly from the i_mmap interval tree.

An interesting thing to note is that address_space objects actually do ref-

erence their folios in i_pages. This field is an [eXtensible array](https://kernel.org/doc/html/v6.0/core-api/xarray.html) which is a clever means of storing an (extensible of course) array of pointers to, in this case, folios.

 



 

This permits the efficient lookup of folios associated with a page cache

entry (e.g. [filemap_get_folios()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2149)[),](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2149) an operation which is not possible (or nec-

essary) for anonymous mappings.

Being able to reference folios from a [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) is critical be-

cause files can have changes made to them which require underlying folios

to be evicted, events which occur at a file granularity (rather than at a folio

granularity like anonymous memory being evicted). An example of this is

[filemap_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2626) which permits reading from the page cache even in the ab-

sence of a mapping.

An awkward edge case is a privately mapped file-backed mapping (e.g.

[c alled ](https://man7.org/linux/man-pages/man2/mmap().2.html)with a file descriptor to map a file but with the MAP_PRIVATE flag set).

This is described in detail in section 6.6, however in brief – VMAs mapped

like this can appear in both address_space i_mmap trees and anon_vma rb_root

trees (via [struct anon_vma_chain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82) objects) at the same time.

These are strange beasts – Copy-on-Write mappings to the relevant page

cache entries which, on write, become entirely anonymous mappings. How-

ever belonging to both file-backed and anonymous reverse mapping trees

means that they do not behave entirely like an anonymous mapping even

after the Copy-on-Write has occurred.

When file-mapped pages are truncated (e.g. overwritten or reduced in

size), i_mmap is used to look up VMAs and clear down page table mappings

(see section 6.6 for more on this edge case) and see the chapter on page

cache for a detailed exploration of file-mapped pages function.

This means that MAP_PRIVATE file mappings, which still exist in the relevant

i_mmap tree, have this done to them even if they have performed Copy-on-Write,

and all changes to the anonymous backing folios is lost.

For more details on the address_space type and a broader discussion of

the page cache, see the chapter dedicated to this topic.

 

***7.0.4 Anonymous reverse mapping types***

**7.0.4.1 Relevant VMA fields**

After that whirlwind tour through reverse mapping, let’s take a step back

and examine each type in detail, starting with the fields relevant to anon_vma

objects present in the [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) data type:-

 

403 **struct** vm_area_struct {

. . .

454 */\**

455 *\* A file's MAP_PRIVATE vma can be in both i_mmap tree and anon_vma*

456 *\* list, after a COW of one of the file pages. A MAP_SHARED vma* 457 *\* can only be in the i_mmap tree. An anonymous MAP_PRIVATE, stack*

458 *\* or brk vma (with NULL file) can only be in an anon_vma list.* 459 *\*/*

460 **struct** list_head anon_vma_chain; */\* Serialized by mmap_lock &* 461 *\* page_table_lock \*/*

 



 

462 **struct** anon_vma \*anon_vma; */\* Serialized by page_table_lock \*/*

. . .

483 } \_\_randomize_layout;

 

*Listing 7-1:* include/linux/mm_types.h: [*struct vm_area_struct*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) *anon_vma fields*

 

Examining each field:-

 

• anon_vma_chain – This heads the list containing AVC objects related to this

VMA, linked by the same_vma field.

• anon_vma – This points to the anon_vma object which newly faulted-in

anonymous folios will be mapped to, which is referred to as its active VMA. Importantly – if no folios have yet been faulted in, this field will be NULL.

 

**7.0.4.2 struct anon_vma**

And now examining [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31), the core anonymous reverse mapping data structure:-

 

17 */\**

18 *\* The anon_vma heads a list of private "related" vmas, to scan if* 19 *\* an anonymous page pointing to this anon_vma needs to be unmapped:* 20 *\* the vmas on the list will be related by forking, or by splitting.* 21 *\**

22 *\* Since vmas come and go as they are split and merged (particularly* 23 *\* in mprotect), the mapping field of an anonymous page cannot point* 24 *\* directly to a vma: instead it points to an anon_vma, on whose list* 25 *\* the related vmas can be easily linked or unlinked.* 26 *\**

27 *\* After unlinking the last vma on the list, we must garbage collect* 28 *\* the anon_vma object itself: we're guaranteed no page can be* 29 *\* pointing to this anon_vma once its vma list is empty.* 30 *\*/*

31 **struct** anon_vma {

32 **struct** anon_vma \*root; */\* Root of this anon_vma tree \*/* 33 **struct** rw_semaphore rwsem; */\* W: modification, R: walking the*

*list \*/*

34 */\**

35 *\* The refcount is taken on an anon_vma when there is no* 36 *\* guarantee that the vma of page tables will exist for* 37 *\* the duration of the operation. A caller that takes* 38 *\* the reference is responsible for clearing up the* 39 *\* anon_vma if they are the last user on release* 40 *\*/*

41 **atomic_t** refcount; 42

43 */\**

44 *\* Count of child anon_vmas. Equals to the count of all anon_vmas that*

 



 

45 *\* have -\>parent pointing to this one, including itself.*

46 *\**

47 *\* This counter is used for making decision about reusing anon_vma*

48 *\* instead of forking new one. See comments in function anon_vma_clone*

*.*

49 *\*/*

50 **unsigned long** num_children;

51 */\* Count of VMAs whose -\>anon_vma pointer points to this object. \*/*

52 **unsigned long** num_active_vmas;

53

54 **struct** anon_vma \*parent; */\* Parent of this anon_vma \*/*

55

56 */\**

57 *\* NOTE: the LSB of the rb_root.rb_node is set by*

58 *\* mm_take_all_locks() \_after\_ taking the above lock. So the*

59 *\* rb_root must only be read/written after taking the above lock*

60 *\* to be sure to see a valid next pointer. The LSB bit itself*

61 *\* is serialized by a system wide lock only visible to*

62 *\* mm_take_all_locks() (mm_all_locks_mutex).*

63 *\*/*

64

65 */\* Interval tree of private "related" vmas \*/*

66 **struct** rb_root_cached rb_root;

67 };

 

*Listing 7-2:* include/linux/rmap.h: [*struct anon_vma*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31)

 

Examining each field:-

 

• root – This points at the [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31)object which sits at the top of all

forked processes above the one that owns this anon_vma. This is primarily used to share the root object’s rwsem lock between all forked objects.

• rwsem – A [read/write semaphore](https://kernel.org/doc/html/v6.0/locking/locktypes.html#rw-semaphore) used to synchronise access to all

anon_vma objects and the rb nodes contained within [struct anon_vma_chain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82) objects.

Note that we do not lock at an anon_vma granularity, rather we lock the en-tire anon_vma tree by locking only the root anon_vma object (i.e. the ultimate parent of all the forks under which an anon_vma sits, as referenced by the root field).

Being a read/write semaphore, read locks are non-exclusive with respect to other read locks but write locks are exclusive. This lock is typically

acquired via [anon_vma_lock_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n129) and [anon_vma_lock_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n119) and unlocked

via [anon_vma_unlock_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n139) and [anon_vma_unlock_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n124). There is also a try

variant of the read – [anon_vma_trylock_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n134).

• refcount – An atomic reference count representing the number of

times this object is referenced. Incremented by [get_anon_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n106) and

decremented by [put_anon_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n113) (which performs heavy lifting in

 



 

[\_\_put_anon_vma()). ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n2343)This is also manipulated elsewhere directly within in-ternal rmap functions.

• num_children – Counts the number of anon_vma objects whose parent field

points at this anon_vma. Used along with num_active_vmas to determine

whether anon_vma objects can be reused in [anon_vma_clone()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n279).

• num_active_vmas – Counts the number of VMAs whose anon_vma field

points at this object. Used in conjunction with num_children to permit anon_vma object reuse.

• parent – Points at the anon_vma object of the parent process which forked

this one. Used to maintain correct num_children counts, incrementing in

[anon_vma_fork()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n333) and decrementing in [unlink_anon_vmas()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n395).

• rb_root – The root of a red/black interval tree with anon_vma_chain nodes

connecting the anon_vma object to VMAs which map folios referencing it. The interval tree is keyed on the folio’s index field which, for anonymous memory, is set to the virtual page offset of the address at which it was

originally mapped\* (via [\_\_page_set_anon_rmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1129)[).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1129) Each VMA specifies its starting virtual page offset in their vm_pgoff field. There can be multiple VMAs present within the same interval range (e.g. forked process VMAs), different VMAs can be mapped to different virtual page offsets (e.g. split VMAs) or a combination of both.

 

**7.0.4.3 struct anon_vma_chain**

Examining the [struct anon_vma_chain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82) object:-

 

69 */\**

70 *\* The copy-on-write semantics of fork mean that an anon_vma* 71 *\* can become associated with multiple processes. Furthermore,* 72 *\* each child process will have its own anon_vma, where new* 73 *\* pages for that process are instantiated.* 74 *\**

75 *\* This structure allows us to find the anon_vmas associated* 76 *\* with a VMA, or the VMAs associated with an anon_vma.* 77 *\* The "same_vma" list contains the anon_vma_chains linking* 78 *\* all the anon_vmas associated with this VMA.* 79 *\* The "rb" field indexes on an interval tree the anon_vma_chains* 80 *\* which link all the VMAs associated with this anon_vma.* 81 *\*/*

82 **struct** anon_vma_chain {

83 **struct** vm_area_struct \*vma; 84 **struct** anon_vma \*anon_vma; 85 **struct** list_head same_vma; */\* locked by mmap_lock & page_table_lock*

*\*/*

 

\*. [mremap()](https://man7.org/linux/man-pages/man2/mremap.2.html) retains the original virtual page offsets if it moves a VMA. See section 8.2.3 for a detailed discussion of this.



 

86 **struct** rb_node rb; */\* locked by anon_vma-\>rwsem*

*\*/*

87 **unsigned long** rb_subtree_last;

88 **\#ifdef CONFIG_DEBUG_VM_RB**

89 **unsigned long** cached_vma_start, cached_vma_last;

90 **\#endif**

91 };

 

*Listing 7-3:* include/linux/rmap.h: [*struct anon_vma_chain*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82)

 

Examining each field:-

 

• vma – This is the [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) object which this object is

linking to an anon_vma object.

• anon_vma – The [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) object being linked to a VMA.

• same_vma – The [struct list_head](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/types.h?h=v6.0#n178) object which is the node connecting

this to the anon_vma_chain field in the owning VMA object and other

[struct anon_vma_chain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82) objects in the list.

• rb – The node of the red/black interval tree, rooted in a related

[struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31)’s rb_root field.

• rb_subtree_last – Stores the largest exclusive end bound of the inter-

val of elements within this subtree. A field required for the interval

tree implementation (see [include/linux/interval_tree_generic.h](https://elixir.bootlin.com/linux/v6.0/source/include/linux/interval_tree_generic.h) and

[mm/interval_tree.c](https://elixir.bootlin.com/linux/v6.0/source/mm/interval_tree.c) for implementation details).

• cached_vma_start – Used by the VM red/black tree debug functionality

(set by the CONFIG_DEBUG_VM_RB flag) to ensure that virtual page offsets of the start of the referenced VMA is correct.

• cached_vma_last – Used by the same debug functionality to ensure that

virtual page offsets of the end of the referenced VMA is correct.

 

***7.0.5 Anonymous reverse mapping initialisation***

Now we have examined how reverse mappings function and the types which

underlie anonymous reverse mappings, let’s consider how they are ini-

tialised in the first place.

Each [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) references the [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) object

which newly allocated anonymous folios will be mapped to in its anon_vma

field. Importantly, this field is set to NULL by default and is only populated

when anonymous memory is faulted in and an anon_vma is required.

The initial setup of the anon_vma objects is performed in [anon_vma_prepare()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n154)

which is invoked by functions faulting in anonymous pages, i.e.

[do_anonymous_page(),](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4031) [wp_page_copy()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3090), [do_cow_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4535) and the stack expansion

functions [expand_downwards()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2441) and [expand_upwards()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2351) (it is also invoked by huge

page and migration functions but these are out of scope here) as shown in

Listing 7-4.

 

154 **static inline int anon_vma_prepare**(**struct** vm_area_struct \*vma)

 



 

155 {

156 **if** (**likely**(vma-\>anon_vma)) 157 **return** 0; 158

159 **return \_\_anon_vma_prepare**(vma); 160 }

 

*Listing 7-4:* include/linux/rmap.h: [*anon_vma_prepare()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n154)

 

This is invoked unconditionally and only actually performs the allocation

and initialisation of an anon_vma object if none already exists, which is done in

[\_\_anon_vma_prepare()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n187), as shown in Listing 7-5.

 

159 */\*\**

160 *\* \_\_anon_vma_prepare - attach an anon_vma to a memory region* 161 *\* @vma: the memory region in question* 162 *\**

163 *\* This makes sure the memory mapping described by 'vma' has* 164 *\* an 'anon_vma' attached to it, so that we can associate the* 165 *\* anonymous pages mapped into it with that anon_vma.* 166 *\**

167 *\* The common case will be that we already have one, which* 168 *\* is handled inline by anon_vma_prepare(). But if* 169 *\* not we either need to find an adjacent mapping that we* 170 *\* can re-use the anon_vma from (very common when the only* 171 *\* reason for splitting a vma has been mprotect()), or we* 172 *\* allocate a new one.*

173 *\**

174 *\* Anon-vma allocations are very subtle, because we may have* 175 *\* optimistically looked up an anon_vma in folio_lock_anon_vma_read()* 176 *\* and that may actually touch the rwsem even in the newly* 177 *\* allocated vma (it depends on RCU to make sure that the* 178 *\* anon_vma isn't actually destroyed).* 179 *\**

180 *\* As a result, we need to do proper anon_vma locking even* 181 *\* for the new allocation. At the same time, we do not want* 182 *\* to do any locking for the common case of already having* 183 *\* an anon_vma.*

184 *\**

185 *\* This must be called with the mmap_lock held for reading.* 186 *\*/*

187 **int \_\_anon_vma_prepare**(**struct** vm_area_struct \*vma) 188 {

189 **struct** mm_struct \*mm = vma-\>vm_mm; 190 **struct** anon_vma \*anon_vma, \*allocated; 191 **struct** anon_vma_chain \*avc; 192

193 **might_sleep**();

194

 



 

195 avc = **anon_vma_chain_alloc**(**GFP_KERNEL**); 196 **if** (!avc)

197 **goto out_enomem**;

198

199 anon_vma = **find_mergeable_anon_vma**(vma); 200 allocated = **NULL**; 201 **if** (!anon_vma) {

202 anon_vma = **anon_vma_alloc**(); 203 **if** (**unlikely**(!anon_vma)) 204 **goto out_enomem_free_avc**; 205 anon_vma-\>num_children++; */\* self-parent link for new root \*/* 206 allocated = anon_vma; 207 }

208

209 **anon_vma_lock_write**(anon_vma); 210 */\* page_table_lock to protect against threads \*/* 211 **spin_lock**(&mm-\>page_table_lock); 212 **if** (**likely**(!vma-\>anon_vma)) { 213 vma-\>anon_vma = anon_vma; 214 **anon_vma_chain_link**(vma, avc, anon_vma); 215 anon_vma-\>num_active_vmas++; 216 allocated = **NULL**; 217 avc = **NULL**; 218 }

219 **spin_unlock**(&mm-\>page_table_lock); 220 **anon_vma_unlock_write**(anon_vma);

221

222 **if** (**unlikely**(allocated)) 223 **put_anon_vma**(allocated); 224 **if** (**unlikely**(avc)) 225 **anon_vma_chain_free**(avc);

226

227 **return** 0;

228

229 **out_enomem_free_avc**:

230 **anon_vma_chain_free**(avc); 231 **out_enomem**:

232 **return**-**ENOMEM**;

233 }

 

*Listing 7-5:* mm/rmap.c: [*\_\_anon_vma_prepare()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n187)

 

There is a lot to unpack here, so let’s start by examining how we actually

perform the allocations of the [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) and [struct anon_vma_chain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82) ob-

jects.

We start by allocating the [struct anon_vma_chain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82) object associated with the

candidate anon_vma. Note that we are only performing this action because the

 



 

VMA does not have a anon_vma to point at, so we might not have to allocate a new anon_vma but instead might be able to reuse an existing one.

However in any case we absolutely do need to allocate a new

anon_vma_chain, as this represents the connection between a VMA and an

anon_vma. We do this in [anon_vma_chain_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n139) as shown in Listing 7-6.

 

139 **static inline struct** anon_vma_chain \***anon_vma_chain_alloc**(**gfp_t** gfp) 140 {

141 **return kmem_cache_alloc**(**anon_vma_chain_cachep**, gfp); 142 }

 

*Listing 7-6:* mm/rmap.c: [*anon_vma_chain_alloc()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n139)

 

The actual allocation is performed by the slab function

[kmem_cache_alloc() . ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/slub.c?h=v6.0#n3271)We go into detail on this in the slab chapter, however fundamentally this function allows for the efficient allocation of objects of a specific type.

In this case, we template objects using the [anon_vma_chain_cachep](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n87) object

which is initialised early in [anon_vma_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n459).

We free anon_vma_chain objects via [anon_vma_chain_free()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n144) as shown in List-

ing 7-7.

 

144 **static void** anon_vma_chain_free(**struct** anon_vma_chain \*anon_vma_chain) 145 {

146 **kmem_cache_free**(anon_vma_chain_cachep, anon_vma_chain); 147 }

 

*Listing 7-7:* mm/rmap.c: [*anon_vma_chain_free()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n144)

 

Which simply invokes the standard slab free function [kmem_cache_free()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/slub.c?h=v6.0#n3550)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/slub.c?h=v6.0#n3550)

Turning now to the allocation of anon_vma objects via [anon_vma_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n89) as

shown in Listing 7-8.

 

89 **static inline struct** anon_vma \***anon_vma_alloc**(**void**) 90 {

91 **struct** anon_vma \*anon_vma; 92

93 anon_vma = **kmem_cache_alloc**(anon_vma_cachep, **GFP_KERNEL**); 94 **if** (anon_vma) {

95 **atomic_set**(&anon_vma-\>refcount, 1); 96 anon_vma-\>num_children = 0; 97 anon_vma-\>num_active_vmas = 0; 98 anon_vma-\>parent = anon_vma; 99 */\**

100 *\* Initialise the anon_vma root to point to itself. If called*

101 *\* from fork, the root will be reset to the parents anon_vma.*

102 *\*/*

103 anon_vma-\>root = anon_vma; 104 }

105

 



 

106 **return** anon_vma;

107 }

 

*Listing 7-8:* mm/rmap.c: [*anon_vma_alloc()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n89)

 

Again, we use [kmem_cache_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/slub.c?h=v6.0#n3271) to allocate the actual object, this time

using the [anon_vma_cachep](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n86) slab cache object. A difference from anon_vma_chain

allocations here is that this is set up to invoke a constructor on allocation,

[anon_vma_ctor()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n450) as shown in Listing 7-9.

 

450 **static void anon_vma_ctor**(**void** \*data) 451 {

452 **struct** anon_vma \*anon_vma = data;

453

454 **init_rwsem**(&anon_vma-\>rwsem); 455 **atomic_set**(&anon_vma-\>refcount, 0); 456 anon_vma-\>rb_root = **RB_ROOT_CACHED**; 457 }

 

*Listing 7-9:* mm/rmap.c: [*anon_vma_ctor()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n450)

 

So taking into account this and anon_vma_alloc(), on initialisation a

[struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) object is initialised such that its fields are initialised such

that:-

 

• root – Set to point to itself. This is required as all locking performed on

the rwsem is performed at the root of the anon_vma tree, and thus if the tree consists of only one anon_vma, as is the case when first initialised, we must lock ourself. Additionally, it is used to assign all non-exclusive mapped folios to the root of the anon_vma tree when swapped back in or

migrated (see section 7.0.12 for more on this).

• rwsem – Initialised via [init_rwsem()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rwsem.h?h=v6.0#n106) to an unlocked state.

• refcount – When allocated within the cache this is atomically ini-

tialised to zero, however when this object is obtained from the cache in anon_vma_alloc() it is atomically set to 1 as by definition, allocating it means that we maintain a reference to it.

• num_children – We initially set this to zero, but as part of

[\_\_anon_vma_prepare()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n187) we increment this to 1. We do this because on preparation we don’t know whether we can merge an existing anon_vma and thus it is more generic to initially set this to zero and to simply incre-ment on preparation.

• num_active_vmas – Equally set to zero on allocation but incremented in

\_\_anon_vma_prepare() when a VMA is pointed at it.

• parent – Similar to root, this is set to point at the anon_vma object itself.

This field is used to update the child count of a forked anon_vma’s parent which, since we root a singular anon_vma is itself, is logically also itself.

• rb_root – This is initialised as any red/black tree in the kernel by setting

it to the default NULL state defined by [RB_ROOT_CACHED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rbtree_types.h?h=v6.0#n32).

 



 

***7.0.6 Reusing adjacent VMA’s anon_vma objects***

Returning to [\_\_anon_vma_prepare()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n187) (in listing 7-5), we see that we try to merge

the use of an existing [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) object with this VMA – as we index by anonymously mapped folios’s originally mapped virtual page offset (as op-posed to file page offset for file mappings), which is in turn used to lookup VMAs in the rb_root-rooted interval tree, an anon_vma can reference multiple VMAs with ease and thus merging across adjacent virtual mappings with the same attributes is highly feasible.

We could in theory merge other compatible anon_vma objects (we dis-

cuss what constitutes compatible anon_vma objects below) due to the virtual page offset, however doing so would be time-consuming, and the fact that

[mremap()](https://man7.org/linux/man-pages/man2/mremap.2.html) retains the original virtual page offset if it moves pages makes this

more complicated (see section 8.2.3 for an in-depth discussion of mremap()).

We therefore do attempt to do so in order to minimise kernel overhead,

which is performed in [find_mergeable_anon_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1276) as shown in Listing 7-10.

 

1268 */\**

1269 *\* find_mergeable_anon_vma is used by anon_vma_prepare, to check* 1270 *\* neighbouring vmas for a suitable anon_vma, before it goes off* 1271 *\* to allocate a new anon_vma. It checks because a repetitive* 1272 *\* sequence of mprotects and faults may otherwise lead to distinct* 1273 *\* anon_vmas being allocated, preventing vma merge in subsequent* 1274 *\* mprotect.*

1275 *\*/*

1276 **struct** anon_vma \***find_mergeable_anon_vma**(**struct** vm_area_struct \*vma) 1277 {

1278 **struct** anon_vma \*anon_vma = **NULL**; 1279

1280 */\* Try next first. \*/* 1281 **if** (vma-\>vm_next) { 1282 anon_vma = **reusable_anon_vma**(vma-\>vm_next, vma, vma-\>vm_next); 1283 **if** (anon_vma) 1284 **return** anon_vma; 1285 }

1286

1287 */\* Try prev next. \*/* 1288 **if** (vma-\>vm_prev) 1289 anon_vma = **reusable_anon_vma**(vma-\>vm_prev, vma-\>vm_prev, vma); 1290

1291 */\**

1292 *\* We might reach here with anon_vma == NULL if we can't find* 1293 *\* any reusable anon_vma.* 1294 *\* There's no absolute need to look only at touching neighbours:* 1295 *\* we could search further afield for "compatible" anon_vmas.* 1296 *\* But it would probably just be a waste of time searching,* 1297 *\* or lead to too many vmas hanging off the same anon_vma.* 1298 *\* We're trying to allow mprotect remerging later on,*

 



 

1299 *\* not trying to minimize memory used for anon_vmas.* 1300 *\*/*

1301 **return** anon_vma;

1302 }

 

*Listing 7-10:* mm/mmap.c: [*find_mergeable_anon_vma()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1276)

 

This simply attempts to determine whether either the previous or next

VMA has a compatible VMA. If so, it returns its [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) object to be

used instead of a newly allocated one.

We test what constitutes an anon_vma-mergeable VMA via

[reusable_anon_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1257) as shown in Listing 7-11.

 

1235 */\**

1236 *\* Do some basic sanity checking to see if we can re-use the anon_vma* 1237 *\* from 'old'. The 'a'/'b' vma's are in VM order - one of them will be* 1238 *\* the same as 'old', the other will be the new one that is trying* 1239 *\* to share the anon_vma.* 1240 *\**

1241 *\* NOTE! This runs with mmap_lock held for reading, so it is possible that*

1242 *\* the anon_vma of 'old' is concurrently in the process of being set up* 1243 *\* by another page fault trying to merge \_that\_. But that's ok: if it* 1244 *\* is being set up, that automatically means that it will be a singleton* 1245 *\* acceptable for merging, so we can do all of this optimistically. But* 1246 *\* we do that READ_ONCE() to make sure that we never re-load the pointer.* 1247 *\**

1248 *\* IOW: that the "list_is_singular()" test on the anon_vma_chain only* 1249 *\* matters for the 'stable anon_vma' case (ie the thing we want to avoid* 1250 *\* is to return an anon_vma that is "complex" due to having gone through* 1251 *\* a fork).*

1252 *\**

1253 *\* We also make sure that the two vma's are compatible (adjacent,* 1254 *\* and with the same memory policies). That's all stable, even with just* 1255 *\* a read lock on the mmap_lock.* 1256 *\*/*

1257 **static struct** anon_vma \***reusable_anon_vma**(**struct** vm_area_struct \*old, **struct**

vm_area_struct \*a, **struct** vm_area_struct \*b)

1258 {

1259 **if** (**anon_vma_compatible**(a, b)) { 1260 **struct** anon_vma \*anon_vma = **READ_ONCE**(old-\>anon_vma); 1261

1262 **if** (anon_vma && **list_is_singular**(&old-\>anon_vma_chain)) 1263 **return** anon_vma; 1264 }

1265 **return NULL**;

1266 }

 

*Listing 7-11:* mm/mmap.c: [*reusable_anon_vma()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1257)

 



 

The fundamental check is performed via [anon_vma_compatible()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1226) which we

examine below, however note that also require the candidate anon_vma to pos-

sess a single entry in its [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403)-\>anon_vma_chain list, i.e. to not be a VMA which is derived from a fork. For simplicity, we will aggregate this

condition with those imposed by [anon_vma_compatible()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1226) as shown in Listing

7-12.

 

1213 */\**

1214 *\* Rough compatibility check to quickly see if it's even worth looking* 1215 *\* at sharing an anon_vma.* 1216 *\**

1217 *\* They need to have the same vm_file, and the flags can only differ* 1218 *\* in things that mprotect may change.* 1219 *\**

1220 *\* NOTE! The fact that we share an anon_vma doesn't \_have\_ to mean that* 1221 *\* we can merge the two vma's. For example, we refuse to merge a vma if* 1222 *\* there is a vm_ops-\>close() function, because that indicates that the* 1223 *\* driver is doing some kind of reference counting. But that doesn't* 1224 *\* really matter for the anon_vma sharing case.* 1225 *\*/*

1226 **static int anon_vma_compatible**(**struct** vm_area_struct \*a, **struct** vm_area_struct

\*b)

1227 {

1228 **return** a-\>vm_end == b-\>vm_start && 1229 **mpol_equal**(**vma_policy**(a), **vma_policy**(b)) && 1230 a-\>vm_file == b-\>vm_file && 1231 !((a-\>vm_flags ^ b-\>vm_flags) & ~(**VM_ACCESS_FLAGS** \|

**VM_SOFTDIRTY**)) &&

1232 b-\>vm_pgoff == a-\>vm_pgoff + ((b-\>vm_start - a-\>vm_start) \>\>

**PAGE_SHIFT**);

1233 }

 

*Listing 7-12:* mm/mmap.c: [*anon_vma_compatible()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1226)

 

In aggregate, [reusable_anon_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1257) and anon_vma_compatible() impose the

following conditions in order for two VMAs to be considered [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31)[-](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31)mergeable are as follows (designating the preceding VMA A and the follow-ing VMA B:-

 

1. The end of A’s virtual mapping must be exactly equal to the beginning of

B ’s, i.e. the VMAs must be adjacent.

2. The NUMA memory policy of both VMAs must be equivalent. This is

checked by [mpol_equal()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mempolicy.h?h=v6.0#n101)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mempolicy.h?h=v6.0#n101) This is out of scope for this chapter, but see the NUMA chapter for more on memory policies.

3. Both A and B must have equivalent vm_file – either both are anony-

mous, or both are MAP_PRIVATE mappings mapping the same file (a sim-ple file mapping would not be applicable here as it would not possess an anon_vma object).

 



 

4. Both A and B’s VMA flags must be identical, except for the basic ac-

cess flags [VM_ACCESS_FLAGS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n404) which comprise [VM_READ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n266)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n266) [VM_WRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n267), and [VM_EXEC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n268)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n268) From the point of view of anonymous folio reverse mapping, the access rights established by the page their table mappings and the fact that dis-tinct access rights require distinct VMAs are irrelevant. Additionally the

[VM_SOFTDIRTY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n301) flag is ignored as it is a purely informative flag and does not denote an actual difference in VMA behaviour.

5. The vm_pgoff of the latter VMA must be equal to the vm_pgoff of the

preceding VMA offset by the different in their vm_start fields, in other words, if a file is mapped, the offset of the latter VMA within it must be precisely where the former VMA left off. If the VMAs are anonymous then this is equivalent to them being immediately adjacent.

6. The adjacent VMA which already maps to the anon_vma must not have an

anon_vma_chain list larger than one, i.e. it must not part of a forked child process which has inherited this mapping from its parent.

 

Looking more closely at this final re-

quirement – this was introduced in commit

[d0e9fe1758f2: Simplify and comment on anon_vma re-use for anon_vma_prepare](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=d0e9fe1758f2) by

Linus to simplify VMA merging when [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) objects are mapped.

This establishes the invariant that if two VMAs specify the same anon_vma

object in their anon_vma fields, they will have identical [struct anon_vma_chain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82)s

in the sense that they will have a single AVC that links the same anon_vma to

themselves.

Since the kernel already establishes the criteria that VMAs with associ-

ated anon_vma objects may only be merged if each VMA points to same one

(via [is_mergeable_anon_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1015)), adding the additional criteria that we cannot

reuse an anon_vma unless the VMA that points to it has no mappings to par-

ent anon_vma objects makes merging easy – we simply unlink the VMA being

removed from its anon_vma and we’re done (in [anon_vma_merge()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n162)).

If we didn’t have this criteria, we would have to carefully check and move

any mappings to parent anon_vma objects and be very careful about locking

throughout.

Note that there is one other place from which we can reuse anon_vma ob-

jects – on cloning an existing VMA’s anon_vma structure in [anon_vma_clone()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n279)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n279)

We discuss this below.

 

***7.0.7 Connecting anon_vma objects***

We connect a [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) object to a [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) object

via [anon_vma_chain_link()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n149):-

 

149 **static void anon_vma_chain_link**(**struct** vm_area_struct \*vma, 150 **struct** anon_vma_chain \*avc, 151 **struct** anon_vma \*anon_vma) 152 {

153 avc-\>vma = vma;

 



 

154 avc-\>anon_vma = anon_vma; 155 **list_add**(&avc-\>same_vma, &vma-\>anon_vma_chain); 156 **anon_vma_interval_tree_insert**(avc, &anon_vma-\>rb_root); 157 }

 

*Listing 7-13:* mm/rmap.c: [*anon_vma_chain_link()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n149)

 

This is a convenience function which assigns the AVC’s vma and anon_vma

fields to the anon_vma and VMA it links, adding the AVC to the front of the

VMA’s anon_vma_chain list via [list_add()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/list.h?h=v6.0#n86) and the anon_vma’s interval tree rooted

in rb_root via [anon_vma_interval_tree_insert()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/interval_tree.c?h=v6.0#n75)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/interval_tree.c?h=v6.0#n75)

Note that [\_\_anon_vma_prepare()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n187) invokes this to connect the newly allocated

anon_vma and [struct anon_vma_chain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82) in addition to a number of other callers.

 

***7.0.8 Cloning anon_vma objects***

It might seem surprising, but the fundamental function for splitting and

forking [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) structures is cloning an existing VMA’s connections to anon_vma objects.

However, the more you think about it, the more it makes sense – if there

is more than one connection to anon_vma objects, that implies the VMA has been forked, and thus all existing such connections must be maintained no matter what.

On splitting a VMA, we share the existing anon_vma so that must be main-

tained for the newly split VMA (see figure 7-3), and on fork we of course im-port the connections to the parent to our child VMA before adding our own new anon_vma for CoW’d pages.

This clone operation is performed in [anon_vma_clone()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n279) as shown in Listing

7-14.

 

261 */\**

262 *\* Attach the anon_vmas from src to dst.* 263 *\* Returns 0 on success, -ENOMEM on failure.* 264 *\**

265 *\* anon_vma_clone() is called by \_\_vma_adjust(), \_\_split_vma(), copy_vma() and*

266 *\* anon_vma_fork(). The first three want an exact copy of src, while the last*

267 *\* one, anon_vma_fork(), may try to reuse an existing anon_vma to prevent*

268 *\* endless growth of anon_vma. Since dst-\>anon_vma is set to NULL before call,*

269 *\* we can identify this case by checking (!dst-\>anon_vma && src-\>anon_vma).*

270 *\**

271 *\* If (!dst-\>anon_vma && src-\>anon_vma) is true, this function tries to find*

272 *\* and reuse existing anon_vma which has no vmas and only one child anon_vma.*

273 *\* This prevents degradation of anon_vma hierarchy to endless linear chain in*

274 *\* case of constantly forking task. On the other hand, an anon_vma with more*

275 *\* than one child isn't reused even if there was no alive vma, thus rmap* 276 *\* walker has a good chance of avoiding scanning the whole hierarchy when it*

277 *\* searches where page is mapped.* 278 *\*/*

279 **int anon_vma_clone**(**struct** vm_area_struct \*dst, **struct** vm_area_struct \*src)

 



 

280 {

281 **struct** anon_vma_chain \*avc, \*pavc; 282 **struct** anon_vma \*root = **NULL**;

283

284 **list_for_each_entry_reverse**(pavc, &src-\>anon_vma_chain, same_vma) { 285 **struct** anon_vma \*anon_vma;

286

287 avc = **anon_vma_chain_alloc**(**GFP_NOWAIT** \| **\_\_GFP_NOWARN**); 288 **if** (**unlikely**(!avc)) { 289 **unlock_anon_vma_root**(root); 290 root = **NULL**; 291 avc = **anon_vma_chain_alloc**(**GFP_KERNEL**); 292 **if** (!avc) 293 **goto enomem_failure**; 294 }

295 anon_vma = pavc-\>anon_vma; 296 root = **lock_anon_vma_root**(root, anon_vma); 297 **anon_vma_chain_link**(dst, avc, anon_vma);

298

299 */\**

300 *\* Reuse existing anon_vma if it has no vma and only one* 301 *\* anon_vma child.* 302 *\**

303 *\* Root anon_vma is never reused:* 304 *\* it has self-parent reference and at least one child.* 305 *\*/*

306 **if** (!dst-\>anon_vma && src-\>anon_vma && 307 anon_vma-\>num_children \< 2 && 308 anon_vma-\>num_active_vmas == 0) 309 dst-\>anon_vma = anon_vma; 310 }

311 **if** (dst-\>anon_vma) 312 dst-\>anon_vma-\>num_active_vmas++; 313 **unlock_anon_vma_root**(root); 314 **return** 0;

315

316 **enomem_failure**:

317 */\**

318 *\* dst-\>anon_vma is dropped here otherwise its degree can be*

*incorrectly*

319 *\* decremented in unlink_anon_vmas().* 320 *\* We can safely do this because callers of anon_vma_clone() don't*

*care*

321 *\* about dst-\>anon_vma if anon_vma_clone() failed.* 322 *\*/*

323 dst-\>anon_vma = **NULL**; 324 **unlink_anon_vmas**(dst);

 



 

325 **return**-**ENOMEM**;

326 }

 

*Listing 7-14:* mm/rmap.c: [*anon_vma_clone()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n279)

This takes an existing [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA)’s links to

[struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) objects makes a copy of them. It achieves this by iterating

in reverse order through the source VMA’s anon_vma_chain list\*, allocating a new AVC, linking them to each of the source VMA’s linked anon_vma objects

and the target VMA via [anon_vma_chain_link()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n149).

Over the course of the iteration we acquire the appropriate root

[struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) lock via [lock_anon_vma_root()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n243)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n243) a convenience function which unlocks and relocks if the linked anon_vma sits in a different tree.

If this function is called when forking, then the destination anon_vma’s

anon_vma field will be NULL, which is used to perform fork-specific and non-fork specific logic.

If the clone operation is not caused by a fault (i.e .the destination VMA

already has an [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) object assigned), its num_active_vmas field is in-cremented as cloning an existing VMA’s anon_vma structure indicates that we are assigning a new VMA to the destination’s anon_vma.

[anon_vma_clone()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n279) is used by [\_\_vma_adjust()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n699) – a function invoked when ad-

justing VMAs including merging them, [\_\_split_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2676) – a function invoked

when splitting VMAs, [copy_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n3173) – a function invoked when performing a

[mremap()](https://man7.org/linux/man-pages/man2/mremap.2.html) operation and finally [anon_vma_fork()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n333) when a VMA is in the process of being forked.

 

***7.0.9 Reusing anon_vma objects on fork***

Similar to [\_\_anon_vma_prepare()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n187) discussed in section 7.0.6, [anon_vma_clone()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n279) attempts to reuse existing anon_vma objects where possible when a fork is per-formed.

We first determine that this is a fork operation by checking that the desti-

nation VMA has no anon_vma set, then checks the following criteria:-

 

1. A source anon_vma is present.

2. It has one or no children (i.e. it is not the root of an anon_vma tree which

has forked already)

3. Vitally – it has num_active_vmas set to zero – i.e. it is a zombie object with

no VMAs pointing at it whatsoever.

 

Under what circumstances does this occur? If a process repeatedly

forks with each child process quickly exiting (and thus each invoking

[unlink_anon_vmas() ), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n395)they leave behind empty anon_vma objects simply point-ing to child AVC objects resulting in an otherwise unnecessary growth in anon_vma objects.

 

\*. In reverse order because newer [struct anon_vma_chain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82) objects are appended to the front of this list rather than the rear, and when we add these to the target VMA’s list we are appending to the front so in order to maintain the same order we must iterate backwards.



 

***7.0.10 Forking anon_vma objects***

Forking is one of the key operations in any unix system, where a process is

cloned from a ‘parent’ process into a ‘child’ one which maps the parent’s

memories only utilising Copy-on-Write semantics to do so efficiently.

When forking a process, [dup_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n580) is invoked to perform the duplication

of all existing memory mappings. This in turn invokes [anon_vma_fork()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n333) to per-

form the forking with respect to anon_vma objects as shown in Listing 7-15.

 

328 */\**

329 *\* Attach vma to its own anon_vma, as well as to the anon_vmas that* 330 *\* the corresponding VMA in the parent process is attached to.* 331 *\* Returns 0 on success, non-zero on failure.* 332 *\*/*

333 **int anon_vma_fork**(**struct** vm_area_struct \*vma, **struct** vm_area_struct \*pvma) 334 {

335 **struct** anon_vma_chain \*avc; 336 **struct** anon_vma \*anon_vma; 337 **int** error;

338

339 */\* Don't bother if the parent process has no anon_vma here. \*/* 340 **if** (!pvma-\>anon_vma) 341 **return** 0;

342

343 */\* Drop inherited anon_vma, we'll reuse existing or allocate new. \*/*

344 vma-\>anon_vma = **NULL**;

345

346 */\**

347 *\* First, attach the new VMA to the parent VMA's anon_vmas,* 348 *\* so rmap can find non-COWed pages in child processes.* 349 *\*/*

350 error = **anon_vma_clone**(vma, pvma); 351 **if** (error)

352 **return** error;

353

354 */\* An existing anon_vma has been reused, all done then. \*/* 355 **if** (vma-\>anon_vma) 356 **return** 0;

357

358 */\* Then add our own anon_vma. \*/* 359 anon_vma = **anon_vma_alloc**(); 360 **if** (!anon_vma)

361 **goto out_error**; 362 anon_vma-\>num_active_vmas++; 363 avc = **anon_vma_chain_alloc**(**GFP_KERNEL**); 364 **if** (!avc)

365 **goto out_error_free_anon_vma**;

366

 



 

367 */\**

368 *\* The root anon_vma's rwsem is the lock actually used when we* 369 *\* lock any of the anon_vmas in this anon_vma tree.* 370 *\*/*

371 anon_vma-\>root = pvma-\>anon_vma-\>root; 372 anon_vma-\>parent = pvma-\>anon_vma; 373 */\**

374 *\* With refcounts, an anon_vma can stay around longer than the* 375 *\* process it belongs to. The root anon_vma needs to be pinned until*

376 *\* this anon_vma is freed, because the lock lives in the root.* 377 *\*/*

378 **get_anon_vma**(anon_vma-\>root); 379 */\* Mark this anon_vma as the one where our new (COWed) pages go. \*/*

380 vma-\>anon_vma = anon_vma; 381 **anon_vma_lock_write**(anon_vma); 382 **anon_vma_chain_link**(vma, avc, anon_vma); 383 anon_vma-\>parent-\>num_children++; 384 **anon_vma_unlock_write**(anon_vma); 385

386 **return** 0;

387

388 **out_error_free_anon_vma**: 389 **put_anon_vma**(anon_vma); 390 **out_error**:

391 **unlink_anon_vmas**(vma); 392 **return**-**ENOMEM**;

393 }

 

*Listing 7-15:* mm/rmap.c: [*anon_vma_fork()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n333)

 

This firstly checks whether the existing VMA is even pointed at a

[struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) object – if not then nothing need be done.

Otherwise, the function:-

 

1. Invokes the above described [anon_vma_clone()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n279) function to clone links to

its parent’s anon_vma objects.

2. Checks whether it reused an anon_vma – if so, the function returns.

3. If not, allocates a new one via [anon_vma_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n89) and a

[struct anon_vma_chain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82) object via [anon_vma_chain_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n139)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n139)

4. Determines the new anon_vma’s root from the parent’s anon_vma’s root

and sets its parent, then acquires an additional reference on the root anon_vma.

5. Points this VMA at the newly allocated anon_vma as the new CoW target

and links everything together via [anon_vma_chain_link()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n149).

 

When a page is un-CoW’d in [do_wp_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3360) it either creates a new

anon_vma mapping via [page_add_new_anon_rmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1262) or, if it is now exclusively owned by a single process, it moves the page from the parent anon_vma via

 



 

[page_move_anon_rmap() . ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1102)We examine this and other folio reverse mapping ma-

nipulation in section 7.0.12 below.

Note that any existing shared folios which are either swapped back in or

migrated via [page_add_anon_rmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1200) will be pointed at the root anon_vma. Again

see section 7.0.12 below for more.

Important – The fact that an anon_vma object maps to a forked child’s VMA

does not necessarily mean that VMA maps it. The child may have since

CoW’d the folio, and in reality at any time a mapping might disappear from

under us.

The purpose of the reverse mapping is only to find candidate VMAs

where a mapping might exist, we must check the mapping is actually present

when walking the reverse mapping – we discuss precisely how we do this in

section 7.0.16.

 

***7.0.11 VMA split and merge***

There are two functions in which an anon_vma clone occurs – [\_\_vma_adjust()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n699)

which is the core function invoked for modifying VMAs, and [\_\_split_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2676)

which is invoked when VMAs are split (and which subsequently calls

\_\_vma_adjust() to account for changes in VMA structure).

The former clones only if, for example, [mprotect()](https://man7.org/linux/man-pages/man2/mprotect.2.html) changes VMA bound-

aries due to changing protection attributes of portions of a VMA (e.g. one

region read/write, another read-only) and one portion needs to import the

anon_vma objects of the other.

The latter clones in all cases as of course it is creating a new

[struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) which must import the existing anon_vma hier-

archy.

However, what needs to be clarified is – when such changes are made,

what precisely updates the rb_root interval tree entries to point to the correct

AVC objects after the change is made?

The answer is that this is performed in in \_\_vma_adjust() which, prior to

performing adjustments to the VMA’s vm_start, vm_end and vm_pgoff fields (all

of which are used by the interval tree to determine which VMA to map to),

invokes [anon_vma_interval_tree_pre_update_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n471) as shown in Listing 7-16.

 

456 */\**

457 *\* vma has some anon_vma assigned, and is already inserted on that* 458 *\* anon_vma's interval trees.* 459 *\**

460 *\* Before updating the vma's vm_start / vm_end / vm_pgoff fields, the* 461 *\* vma must be removed from the anon_vma's interval trees using* 462 *\* anon_vma_interval_tree_pre_update_vma().* 463 *\**

464 *\* After the update, the vma will be reinserted using* 465 *\* anon_vma_interval_tree_post_update_vma().* 466 *\**

467 *\* The entire update must be protected by exclusive mmap_lock and by* 468 *\* the root anon_vma's mutex.*

 



 

469 *\*/*

470 **static inline void**

471 **anon_vma_interval_tree_pre_update_vma**(**struct** vm_area_struct \*vma) 472 {

473 **struct** anon_vma_chain \*avc; 474

475 **list_for_each_entry**(avc, &vma-\>anon_vma_chain, same_vma) 476 **anon_vma_interval_tree_remove**(avc, &avc-\>anon_vma-\>rb_root); 477 }

 

*Listing 7-16:* mm/mmap.c: [*anon_vma_interval_tree_pre_update_vma()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n471)

 

This simply rips through all [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) objects linked to the VMA

and removes all references to the VMA via [anon_vma_interval_tree_remove()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/interval_tree.c?h=v6.0#n85).

Once the adjustment is made, [anon_vma_interval_tree_post_update_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n480) is called to restore these to the now corrected VMA intervals as shown in List-

ing 7-17.

 

479 **static inline void**

480 **anon_vma_interval_tree_post_update_vma**(**struct** vm_area_struct \*vma) 481 {

482 **struct** anon_vma_chain \*avc; 483

484 **list_for_each_entry**(avc, &vma-\>anon_vma_chain, same_vma) 485 **anon_vma_interval_tree_insert**(avc, &avc-\>anon_vma-\>rb_root); 486 }

 

*Listing 7-17:* mm/mmap.c: [*anon_vma_interval_tree_post_update_vma()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n480)

 

Another task performed in [\_\_vma_adjust()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n699)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n699) when merging two VMAs

which are permitted to be merged (more on this shortly), the actual opera-

tion is performed via [anon_vma_merge()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n162) which, as described in section 7.0.6, is able to perform this action by simply removing the absorbed VMA’s AVC

state as shown in Listing 7-18.

 

162 **static inline void anon_vma_merge**(**struct** vm_area_struct \*vma, 163 **struct** vm_area_struct \*next) 164 {

165 **VM_BUG_ON_VMA**(vma-\>anon_vma != next-\>anon_vma, vma); 166 **unlink_anon_vmas**(next); 167 }

 

*Listing 7-18:* include/linux/rmap.h: [*anon_vma_merge()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n162)

 

The removal of the absorbed VMA’s [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) objects is performed

by [unlink_anon_vmas()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n395) which we discuss below.

The actual merge itself is performed by [vma_merge()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1122) which ultimately de-

termines whether anon_vma objects can be merged via [is_mergeable_anon_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1015)

as shown in Listing 7-19.

 

1015 **static inline int is_mergeable_anon_vma**(**struct** anon_vma \*anon_vma1,

 



 

1016 **struct** anon_vma \*anon_vma2, 1017 **struct** vm_area_struct \*vma) 1018 {

1019 */\**

1020 *\* The list_is_singular() test is to avoid merging VMA cloned from*

1021 *\* parents. This can improve scalability caused by anon_vma lock.* 1022 *\*/*

1023 **if** ((!anon_vma1 \|\| !anon_vma2) && (!vma \|\| 1024 **list_is_singular**(&vma-\>anon_vma_chain))) 1025 **return** 1; 1026 **return** anon_vma1 == anon_vma2; 1027 }

 

*Listing 7-19:* mm/mmap.c: [*is_mergeable_anon_vma()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1015)

 

If both VMAs possess anon_vma objects then the test is simple – they must

both assign newly allocated folios to the same anon_vma (i.e. each VMA’s

anon_vma field must point to the same anon_vma).

If either lacks an anon_vma, then the test reduces to ensuring that the

VMA is not the product of a fork, as pointing a non-forked VMA at a forked

anon_vma would be misleading.

Note that the check on whether vma is NULL is used specifically by

vma_merge() when checking whether preceding and succeeding VMAs are

anon_vma-mergeable in which case this check is not relevant.

 

***7.0.12 Folio anon_vma operations***

The principle means by which a folio is linked to a [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) is via

[page_add_new_anon_rmap() . ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1262)This is invoked when the folio is newly allocated

and thus less care need be taken with existing folio state:-

 

1249 */\*\**

1250 *\* page_add_new_anon_rmap - add mapping to a new anonymous page* 1251 *\* @page:* *the page to add the mapping to* 1252 *\* @vma:* *the vm area in which the mapping is added* 1253 *\* @address:* *the user virtual address mapped* 1254 *\**

1255 *\* If it's a compound page, it is accounted as a compound page. As the page*

1256 *\* is new, it's assume to get mapped exclusively by a single process.* 1257 *\**

1258 *\* Same as page_add_anon_rmap but must only be called on \*new\* pages.* 1259 *\* This means the inc-and-test can be bypassed.* 1260 *\* Page does not have to be locked.* 1261 *\*/*

1262 **void page_add_new_anon_rmap**(**struct** page \*page, 1263 **struct** vm_area_struct \*vma, **unsigned long** address) 1264 {

1265 **const bool** compound = **PageCompound**(page);

 



 

1266 **int** nr = compound ? **thp_nr_pages**(page) : 1; 1267

1268 **VM_BUG_ON_VMA**(address \< vma-\>vm_start \|\| address \>= vma-\>vm_end, vma); 1269 **\_\_SetPageSwapBacked**(page); 1270 **if** (compound) {

1271 **VM_BUG_ON_PAGE**(!**PageTransHuge**(page), page); 1272 */\* increment count (starts at -1) \*/* 1273 **atomic_set**(**compound_mapcount_ptr**(page), 0); 1274 **atomic_set**(**compound_pincount_ptr**(page), 0); 1275

1276 **\_\_mod_lruvec_page_state**(page, **NR_ANON_THPS**, nr); 1277 } **else** {

1278 */\* increment count (starts at -1) \*/* 1279 **atomic_set**(&page-\>\_mapcount, 0); 1280 }

1281 **\_\_mod_lruvec_page_state**(page, **NR_ANON_MAPPED**, nr); 1282 **\_\_page_set_anon_rmap**(page, vma, address, 1); 1283 }

 

*Listing 7-20:* mm/rmap.c: [*page_add_new_anon_rmap()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1262)

 

This sets the [PG_swapbacked](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n120) folio flag as this folio is now established as

anonymous, initialises the critical \_mapcount field (this is initialised to-1 on allocation, and thus setting to zero is an increment, indicating that the fo-lio is now mapped), updates statistics and handles the Transparent Huge Page (THP) case of a compound folio (see the huge page chapter for more on this).

Finally the actual assignment to the [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) is performed in

[\_\_page_set_anon_rmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1129) which we shall examine shortly.

This function is invoked by all the usual fault handling logic –

[do_anonymous_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4031) when new anonymous pages are faulted in, [do_swap_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3718)

when new swap pages are faulted in, [wp_page_copy()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3090) when a page has to

be copied for a CoW mapping, [copy_present_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n905) after a fork (and after

[anon_vma_fork()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n333) has been performed) and [do_set_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4290) after a MAP_PRIVATE file-backed mapping has been CoW’d.

The function is also refrence dby migrate, huge page, uprobe, swap file

and [userfaultfd()](https://man7.org/linux/man-pages/man2/userfaultfd.2.html) logic but discussion of this is outside the scope of this sec-tion.

If we are adding a new mapping to a folio that already possesses map-

ping, we have to be a little more careful as shown in Listing 7-21.

 

1188 */\*\**

1189 *\* page_add_anon_rmap - add pte mapping to an anonymous page* 1190 *\* @page:* *the page to add the mapping to* 1191 *\* @vma:* *the vm area in which the mapping is added* 1192 *\* @address:* *the user virtual address mapped* 1193 *\* @flags:* *the rmap flags* 1194 *\**

1195 *\* The caller needs to hold the pte lock, and the page must be locked in*

 



 

1196 *\* the anon_vma case: to serialize mapping,index checking after setting,* 1197 *\* and to ensure that PageAnon is not being upgraded racily to PageKsm* 1198 *\* (but PageKsm is never downgraded to PageAnon).* 1199 *\*/*

1200 **void page_add_anon_rmap**(**struct** page \*page, 1201 **struct** vm_area_struct \*vma, **unsigned long** address, **rmap_t** flags) 1202 {

1203 **bool** compound = flags & **RMAP_COMPOUND**; 1204 **bool** first;

1205

1206 **if** (**unlikely**(**PageKsm**(page))) 1207 **lock_page_memcg**(page); 1208 **else**

1209 **VM_BUG_ON_PAGE**(!**PageLocked**(page), page); 1210

1211 **if** (compound) {

1212 **atomic_t** \*mapcount; 1213 **VM_BUG_ON_PAGE**(!**PageLocked**(page), page); 1214 **VM_BUG_ON_PAGE**(!**PageTransHuge**(page), page); 1215 mapcount = **compound_mapcount_ptr**(page); 1216 first = **atomic_inc_and_test**(mapcount); 1217 } **else** {

1218 first = **atomic_inc_and_test**(&page-\>\_mapcount); 1219 }

1220 **VM_BUG_ON_PAGE**(!first && (flags & **RMAP_EXCLUSIVE**), page); 1221 **VM_BUG_ON_PAGE**(!first && **PageAnonExclusive**(page), page); 1222

1223 **if** (first) {

1224 **int** nr = compound ? **thp_nr_pages**(page) : 1; 1225 */\**

1226 *\* We use the irq-unsafe \_\_{inc\|mod}\_zone_page_stat because*

1227 *\* these counters are not modified in interrupt context, and*

1228 *\* pte lock(a spinlock) is held, which implies preemption* 1229 *\* disabled.* 1230 *\*/*

1231 **if** (compound) 1232 **\_\_mod_lruvec_page_state**(page, **NR_ANON_THPS**, nr); 1233 **\_\_mod_lruvec_page_state**(page, **NR_ANON_MAPPED**, nr); 1234 }

1235

1236 **if** (**unlikely**(**PageKsm**(page))) 1237 **unlock_page_memcg**(page); 1238

1239 */\* address might be in next vma when migration races vma_adjust \*/*

1240 **else if** (first)

1241 **\_\_page_set_anon_rmap**(page, vma, address, 1242 !!(flags & **RMAP_EXCLUSIVE**));

 



 

1243 **else**

1244 **\_\_page_check_anon_rmap**(page, vma, address); 1245

1246 **mlock_vma_page**(page, vma, compound); 1247 }

 

*Listing 7-21:* mm/rmap.c: [*page_add_anon_rmap()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1200)

 

This is broadly similar to [page_add_new_anon_rmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1262) with some additional

checks, Kernel Same-page Merging (KSM) handling (out of scope for the book), incrementing of the map count rather than setting it outright and performing statistical updates only if this is the first mapping (as determined

by [atomic_inc_and_test()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/atomic/atomic-instrumented.h?h=v6.0#n580), which returns true if the incremented value is zero).

An additional difference is the use of the [rmap_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n172) for passing flags specify-

ing characteristics of the mapping:-

 

• [RMAP_NONE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n178) – No special treatment, if the [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) pointer page is in

fact a subpage of a compound folio, then it is mapped at the PTE level rather than a huge page.

• [RMAP_EXCLUSIVE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n181) – Indicates that this is an exclusive mapping of the folio to

a single process.

• [RMAP_COMPOUND](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n187) – Indicates that the folio is mapped as a huge page.

 

We also invoke [mlock_vma_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n527) which sets the folios as [mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html)[’d](https://man7.org/linux/man-pages/man2/mlock.2.html) if the

[VM_LOCKED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n282) flag is set in the VMA (typically via a user specifying the MCL_FUTURE

flag). See section 8.2.1 for more on this.

[page_add_anon_rmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1200) is invoked by KSM and huge memory logic (the for-

mer out of scope for the book, the latter discussed exclusively in the huge

page chapter), as well as in [restore_exclusive_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n717) (with RMAP_NONE speci-fied) on restoring an exclusive PTE entry when forking, on swapping in

via [do_swap_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3718), on migration in [remove_migration_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/migrate.c?h=v6.0#n173) and when making

PTEs unused when swapped out in [unuse_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swapfile.c?h=v6.0#n1772).

For both page_add_anon_rmap() and page_add_new_anon_rmap(), the actual

mapping of the folio is performed in [\_\_page_set_anon_rmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1129) as shown in List-

ing 7-22.

 

1122 */\*\**

1123 *\* \_\_page_set_anon_rmap - set up new anonymous rmap* 1124 *\* @page:* *Page or Hugepage to add to rmap* 1125 *\* @vma:* *VM area to add page to.* 1126 *\* @address:* *User virtual address of the mapping* 1127 *\* @exclusive: the page is exclusively owned by the current process* 1128 *\*/*

1129 **static void \_\_page_set_anon_rmap**(**struct** page \*page, 1130 **struct** vm_area_struct \*vma, **unsigned long** address, **int** exclusive) 1131 {

1132 **struct** anon_vma \*anon_vma = vma-\>anon_vma; 1133

1134 **BUG_ON**(!anon_vma);

 



 

1135

1136 **if** (**PageAnon**(page)) 1137 **goto out**; 1138

1139 */\**

1140 *\* If the page isn't exclusively mapped into this vma,* 1141 *\* we must use the \_oldest\_ possible anon_vma for the* 1142 *\* page mapping!*

1143 *\*/*

1144 **if** (!exclusive)

1145 anon_vma = anon_vma-\>root; 1146

1147 */\**

1148 *\* page_idle does a lockless/optimistic rmap scan on page-\>mapping.*

1149 *\* Make sure the compiler doesn't split the stores of anon_vma and*

1150 *\* the PAGE_MAPPING_ANON type identifier, otherwise the rmap code* 1151 *\* could mistake the mapping for a struct address_space and crash.*

1152 *\*/*

1153 anon_vma = (**void** \*) anon_vma + **PAGE_MAPPING_ANON**; 1154 **WRITE_ONCE**(page-\>mapping, (**struct** address_space \*) anon_vma); 1155 page-\>index = **linear_page_index**(vma, address); 1156 **out**:

1157 **if** (exclusive)

1158 **SetPageAnonExclusive**(page); 1159 }

 

*Listing 7-22:* mm/rmap.c: [*\_\_page_set_anon_rmap()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1129)

 

The logic of this function is as follows:-

 

1. Check whether the folio has already been marked anonymous via

[PageAnon()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n661) which is a simple wrapper around [folio_test_anon()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n656) which sim-

ply checks whether the mapping field has [PAGE_MAPPING_ANON](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n635) set (more on this below).

2. Important – If the page is not exclusively mapped via [RMAP_EXCLUSIVE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n181)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n181)

it will be mapped to the root [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) rather than the one the

[struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) points at. This makes sense for forked pro-cesses (the ones for which root will point at anything other than them-selves) as these will be Copy-on-Write folios only moved to a dedicated anon_vma once the CoW occurs. This is typically used when swapping in

via [do_swap_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3718) and on migration in [remove_migration_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/migrate.c?h=v6.0#n173).

3. The folio’s mapping field is set to the anon_vma object offset by

[PAGE_MAPPING_ANON](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n635) which is used to indicate that the mapping is not to a

[struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) but rather an anon_vma object.

4. The index of the folio is set to the virtual page offset of the folio within

the VMA via [linear_page_index()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n845).

5. If the mapping is exclusive, the [PG_anon_exclusive](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n152) folio flag is set.

 



 

Examining [linear_page_index()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n845) as shown in Listing 7-23.

 

845 **static inline pgoff_t linear_page_index**(**struct** vm_area_struct \*vma, 846 **unsigned long** address) 847 {

848 **pgoff_t** pgoff;

849 **if** (**unlikely**(**is_vm_hugetlb_page**(vma))) 850 **return linear_hugepage_index**(vma, address); 851 pgoff = (address - vma-\>vm_start) \>\> **PAGE_SHIFT**; 852 pgoff += vma-\>vm_pgoff; 853 **return** pgoff;

854 }

 

*Listing 7-23:* include/linux/pagemap.h: [*linear_page_index()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n845)

 

Putting aside the out of scope huge page edge case, this determines the

page offset of the specified address within the VMA and adds this to the VMA’s vm_pgoff field. For anonymous mappings this field is set to the virtual page offset of the mapping.

Note that there is a special case handled very carefully here – [mremap()](https://man7.org/linux/man-pages/man2/mremap.2.html) can

move VMAs around, but to avoid having to update the index field of the as-sociated folios, the vm_pgoff field is kept the same. This explains why we find the page offset of the address relative to the start of the VMA then offset by vm_pgoff rather than simply shifting the address by the page size. See section

8.2.3 for an in depth description of mremap().

If a folio is CoW’d but is the sole remaining instance, instead of adding it

to an anon_vma we move it via [page_move_anon_rmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1102) as shown in Listing 7-24.

 

1092 */\*\**

1093 *\* page_move_anon_rmap - move a page to our anon_vma* 1094 *\* @page:* *the page to move to our anon_vma* 1095 *\* @vma:* *the vma the page belongs to* 1096 *\**

1097 *\* When a page belongs exclusively to one process after a COW event,* 1098 *\* that page can be moved into the anon_vma that belongs to just that* 1099 *\* process, so the rmap code will not search the parent or sibling* 1100 *\* processes.*

1101 *\*/*

1102 **void page_move_anon_rmap**(**struct** page \*page, **struct** vm_area_struct \*vma) 1103 {

1104 **struct** anon_vma \*anon_vma = vma-\>anon_vma; 1105 **struct** page \*subpage = page; 1106

1107 page = **compound_head**(page); 1108

1109 **VM_BUG_ON_PAGE**(!PageLocked(page), page); 1110 **VM_BUG_ON_VMA**(!anon_vma, vma); 1111

1112 anon_vma = (**void** \*) anon_vma + **PAGE_MAPPING_ANON**;

 



 

1113 */\**

1114 *\* Ensure that anon_vma and the PAGE_MAPPING_ANON bit are written* 1115 *\* simultaneously, so a concurrent reader (eg folio_referenced()'s*

1116 *\* folio_test_anon()) will not see one without the other.* 1117 *\*/*

1118 **WRITE_ONCE**(page-\>mapping, (**struct** address_space \*) anon_vma); 1119 **SetPageAnonExclusive**(subpage); 1120 }

 

*Listing 7-24:* mm/rmap.c: [*page_move_anon_rmap()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1102)

 

This simply sets the mapping and the [PG_anon_exclusive](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n152) folio flag. Removing the anon_vma mapping from a folio is performed by

[page_remove_rmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1429) as shown in Listing 7-73.

 

1421 */\*\**

1422 *\* page_remove_rmap - take down pte mapping from a page* 1423 *\* @page:* *page to remove mapping from* 1424 *\* @vma:* *the vm area from which the mapping is removed* 1425 *\* @compound:* *uncharge the page as compound or small page* 1426 *\**

1427 *\* The caller needs to hold the pte lock.* 1428 *\*/*

1429 **void page_remove_rmap**(**struct** page \*page, 1430 **struct** vm_area_struct \*vma, **bool** compound) 1431 {

1432 **lock_page_memcg**(page); 1433

1434 **if** (!**PageAnon**(page)) { 1435 **page_remove_file_rmap**(page, compound); 1436 **goto** out; 1437 }

1438

1439 **if** (compound) {

1440 **page_remove_anon_compound_rmap**(page); 1441 **goto** out; 1442 }

1443

1444 */\* page still mapped by someone else? \*/* 1445 **if** (!**atomic_add_negative**(-1, &page-\>\_mapcount)) 1446 **goto** out; 1447

1448 */\**

1449 *\* We use the irq-unsafe \_\_{inc\|mod}\_zone_page_stat because* 1450 *\* these counters are not modified in interrupt context, and* 1451 *\* pte lock(a spinlock) is held, which implies preemption disabled.*

1452 *\*/*

1453 **\_\_dec_lruvec_page_state**(page, **NR_ANON_MAPPED**); 1454

 



 

1455 **if** (**PageTransCompound**(page)) 1456 **deferred_split_huge_page**(compound_head(page)); 1457

1458 */\**

1459 *\* It would be tidy to reset the PageAnon mapping here,* 1460 *\* but that might overwrite a racing page_add_anon_rmap* 1461 *\* which increments mapcount after us but sets mapping* 1462 *\* before us: so leave the reset to free_unref_page,* 1463 *\* and remember that it's only reliable while mapped.* 1464 *\* Leaving it set also helps swapoff to reinstate ptes* 1465 *\* faster for those pages still in swapcache.* 1466 *\*/*

1467 out:

1468 **unlock_page_memcg**(page); 1469

1470 **munlock_vma_page**(page, vma, compound); 1471 }

 

*Listing 7-25:* mm/rmap.c: [*page_remove_rmap()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1429)

 

This either defers to [page_remove_file_rmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1342) if a file mapping,

[page_remove_anon_compound_rmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1380) (for Transparent Huge Pages, out of scope for this section) if it’s a compound mapping or simply decrements the fo-lio’s \_mapcount field and if it has reached-1, decrement stats on the number of anonymous mapped pages.

After some THP and cgroup handling (out of scope for this section)

[munlock_vma_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n534) is called to remove any existing mlock() condition of the

folios if the [VM_LOCKED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n282) flag of the VMA is set (see section 8.2.1 for more de-tails on this).

This removal is invoked by [zap_pte_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1402)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1402) [wp_page_copy()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3090) when an

old page is freed, the reverse mapping walk function [try_to_unmap_one()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1476) when unmapping memory (discussed in more detail below in section

9.9.3), and the reverse mapping walk functions [try_to_migrate_one()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1833) and

[page_make_device_exclusive_one()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n2166) in addition to some out of scope KSM and huge page functions.

Note the importance of the folio’s \_mapcount field – this is incremented

when the folio is mapped and decremented where, as here, it is unmapped. It is used here and in other places to determine whether a folio is mapped at all, exclusively mapped or part of a shared mapping.

 

***7.0.13 File-backed reverse mapping folio operations***

File-backed folios also count the number of mapping VMAs via \_mapcount,

adding the mapping to the folio reverse mapping via [page_add_file_rmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1293):-

 

1285 */\*\**

1286 *\* page_add_file_rmap - add pte mapping to a file page* 1287 *\* @page:* *the page to add the mapping to*

 



 

1288 *\* @vma:* *the vm area in which the mapping is added* 1289 *\* @compound:* *charge the page as compound or small page* 1290 *\**

1291 *\* The caller needs to hold the pte lock.* 1292 *\*/*

1293 **void page_add_file_rmap**(**struct** page \*page, 1294 **struct** vm_area_struct \*vma, **bool** compound) 1295 {

1296 **int** i, nr = 0;

1297

1298 **VM_BUG_ON_PAGE**(compound && !**PageTransHuge**(page), page); 1299 **lock_page_memcg**(page);

. . .

1331 **if** (**atomic_inc_and_test**(&page-\>\_mapcount)) 1332 nr++;

. . .

1335 **if** (nr)

1336 **\_\_mod_lruvec_page_state**(page, **NR_FILE_MAPPED**, nr); 1337 **unlock_page_memcg**(page); 1338

1339 **mlock_vma_page**(page, vma, compound); 1340 }

 

*Listing 7-26:* mm/rmap.c: [*page_add_file_rmap()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1293)

 

We elide out of scope huge page handling. Here we simply increment

the \_mapcount and also invoke [mlock_vma_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n527) to handle mlock’d VMAs.

Removal of file-backed folio mappings is performed via [page_remove_rmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1429)

which in turn invokes [page_remove_file_rmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1342) as shown in Listing 7-74.

 

1342 **static void page_remove_file_rmap**(**struct** page \*page, **bool** compound) 1343 {

1344 **int** i, nr = 0;

1345

1346 **VM_BUG_ON_PAGE**(compound && !**PageHead**(page), page);

. . .

1372 **if** (**atomic_add_negative**(-1, &page-\>\_mapcount)) 1373 nr++;

. . .

1376 **if** (nr)

1377 **\_\_mod_lruvec_page_state**(page, **NR_FILE_MAPPED**, -nr); 1378 }

 

*Listing 7-27:* mm/rmap.c: [*page_remove_file_rmap()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1342)

 

Eliding the out of scope huge page considerations, this simply deducts

the folio’s mapcount.

 



 

***7.0.14 Unlinking anon_vma objects***

When a [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) needs to unlink all attached

[struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) mappings, the code doing so invokes [unlink_anon_vmas()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n395):-

 

395 **void unlink_anon_vmas**(**struct** vm_area_struct \*vma) 396 {

397 **struct** anon_vma_chain \*avc, \*next; 398 **struct** anon_vma \*root = **NULL**; 399

400 */\**

401 *\* Unlink each anon_vma chained to the VMA. This list is ordered*

402 *\* from newest to oldest, ensuring the root anon_vma gets freed last.*

403 *\*/*

404 **list_for_each_entry_safe**(avc, next, &vma-\>anon_vma_chain, same_vma) { 405 **struct** anon_vma \*anon_vma = avc-\>anon_vma; 406

407 root = **lock_anon_vma_root**(root, anon_vma); 408 **anon_vma_interval_tree_remove**(avc, &anon_vma-\>rb_root); 409

410 */\**

411 *\* Leave empty anon_vmas on the list - we'll need* 412 *\* to free them outside the lock.* 413 *\*/*

414 **if** (**RB_EMPTY_ROOT**(&anon_vma-\>rb_root.rb_root)) { 415 anon_vma-\>parent-\>num_children--; 416 **continue**; 417 }

418

419 **list_del**(&avc-\>same_vma); 420 **anon_vma_chain_free**(avc); 421 }

422 **if** (vma-\>anon_vma) { 423 vma-\>anon_vma-\>num_active_vmas--; 424

425 */\**

426 *\* vma would still be needed after unlink, and anon_vma will*

*be prepared*

427 *\* when handle fault.* 428 *\*/*

429 vma-\>anon_vma = **NULL**; 430 }

431 **unlock_anon_vma_root**(root); 432

433 */\**

434 *\* Iterate the list once more, it now only contains empty and unlinked*

 



 

435 *\* anon_vmas, destroy them. Could not do before due to \_\_put_anon_vma*

*()*

436 *\* needing to write-acquire the anon_vma-\>root-\>rwsem.* 437 *\*/*

438 **list_for_each_entry_safe**(avc, next, &vma-\>anon_vma_chain, same_vma) { 439 **struct** anon_vma \*anon_vma = avc-\>anon_vma;

440

441 **VM_WARN_ON**(anon_vma-\>num_children); 442 **VM_WARN_ON**(anon_vma-\>num_active_vmas); 443 **put_anon_vma**(anon_vma);

444

445 **list_del**(&avc-\>same_vma); 446 **anon_vma_chain_free**(avc); 447 }

448 }

 

*Listing 7-28:* mm/rmap.c: [*unlink_anon_vmas()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n395)

 

This iterates through a [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA)’s anon_vma_chain

list, looking up each [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) object it is linked too via each

[struct anon_vma_chain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82) object, and removes the VMA from the underlying

anon_vma.

This is performed under the lock of the root anon_vma via

[lock_anon_vma_root()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n243), a convenience function which acquires a write lock on

the read/write semaphore, releasing the previous and acquiring the new

one if we encounter an AVC pointing to a different anon_vma tree.

If any are therefore rendered empty, its num_children count is subtracted

and it remains on the anon_vma_chain for later processing. This is because we

need to call [put_anon_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n113) to decrement the anon_vma’s reference count and

free it if it reaches zero, which itself requires a write lock on the root read-

/write semaphore so we must process the list and release this lock before we

can process these.

If the entry is not empty then we simply delete the entry from the list and

free the AVC via [anon_vma_chain_free()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n144)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n144) Note this means that anon_vma objects

can stick around and even become ‘zombies’ if they form part of an anon_vma

tree, however we have mechanisms for reusing these, as discussed in section

7.0.9.

After this process is complete, we decrement the VMA’s target

anon_vma-\>num_active_vmas field and set its target anon_vma to NULL.

Once this is done, the lock is released and we can then finally clear

down the empty anon_vma’s. This is done via put_anon_vma() before remov-

ing the ABC from the anon_vma_chain VMA list and freeing the AVC via

anon_vma_chain_free() as above.

Examining [put_anon_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n113) as shown in Listing 7-29.

 

113 **static inline void put_anon_vma**(**struct** anon_vma \*anon_vma) 114 {

115 **if** (**atomic_dec_and_test**(&anon_vma-\>refcount)) 116 **\_\_put_anon_vma**(anon_vma);

 



 

117 }

 

*Listing 7-29:* include/linux/rmap.h: [*put_anon_vma()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n113)

 

The refcount is decremented and if it reaches zero, [\_\_put_anon_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n2343) as

shown in Listing 7-30.

 

2343 **void \_\_put_anon_vma**(**struct** anon_vma \*anon_vma) 2344 {

2345 **struct** anon_vma \*root = anon_vma-\>root; 2346

2347 **anon_vma_free**(anon_vma); 2348 **if** (root != anon_vma && **atomic_dec_and_test**(&root-\>refcount)) 2349 **anon_vma_free**(root); 2350 }

 

*Listing 7-30:* mm/rmap.c: [*\_\_put_anon_vma()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n2343)

 

This frees the anon_vma and, if the roots reference count is 1, frees that

too.

 

***7.0.15 Walking the reverse mapping***

We have examined how the reverse mapping is structured and maintained in detail – however we have yet to examine it in action, i.e. being used to per-form an operation on a folio’s VMAs.

The key function which perform this action is [rmap_walk()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n2494) as shown in

Listing 7-31.

 

2494 **void rmap_walk**(**struct** folio \*folio, **struct** rmap_walk_control \*rwc) 2495 {

2496 **if** (**unlikely**(**folio_test_ksm**(folio))) 2497 **rmap_walk_ksm**(folio, rwc); 2498 **else if** (**folio_test_anon**(folio)) 2499 **rmap_walk_anon**(folio, rwc, **false**); 2500 **else**

2501 **rmap_walk_file**(folio, rwc, **false**); 2502 }

 

*Listing 7-31:* mm/rmap.c: [*rmap_walk()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n2494)

 

Alternatively the same thing can be achieved via [rmap_walk_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n2505)

which assumes the relevant reverse mapping locks are held

(the root [struct anon_vma-\>rwsem](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) lock if anonymous, and the

[struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)-\>i_mmap_rwsem) lock if file-backed as shown in Listing 7-

32.

 

2504 */\* Like rmap_walk, but caller holds relevant rmap lock \*/* 2505 **void rmap_walk_locked**(**struct** folio \*folio, **struct** rmap_walk_control \*rwc) 2506 {

2507 */\* no ksm support for now \*/*

 



 

2508 **VM_BUG_ON_FOLIO**(**folio_test_ksm**(folio), folio); 2509 **if** (folio_test_anon(folio)) 2510 **rmap_walk_anon**(folio, rwc, **true**); 2511 **else**

2512 **rmap_walk_file**(folio, rwc, **true**); 2513 }

 

*Listing 7-32:* mm/rmap.c: [*rmap_walk_locked()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n2505)

 

The Kernel Same-page Merging (KSM) handling is out of scope, so we

will elide this discussion. Before we dive into the individual walk functions,

let’s examine [struct rmap_walk_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n390) as shown in Listing 7-33.

 

379 */\**

380 *\* rmap_walk_control: To control rmap traversing for specific needs* 381 *\**

382 *\* arg: passed to rmap_one() and invalid_vma()* 383 *\* try_lock: bail out if the rmap lock is contended* 384 *\* contended: indicate the rmap traversal bailed out due to lock contention*

385 *\* rmap_one: executed on each vma where page is mapped* 386 *\* done: for checking traversing termination condition* 387 *\* anon_lock: for getting anon_lock by optimized way rather than default* 388 *\* invalid_vma: for skipping uninterested vma* 389 *\*/*

390 **struct** rmap_walk_control { 391 **void** \*arg;

392 **bool** try_lock;

393 **bool** contended;

394 */\**

395 *\* Return false if page table scanning in rmap_walk should be stopped.*

396 *\* Otherwise, return true.* 397 *\*/*

398 **bool** (\*rmap_one)(**struct** folio \*folio, **struct** vm_area_struct \*vma, 399 **unsigned long** addr, **void** \*arg); 400 **int** (\*done)(**struct** folio \*folio); 401 **struct** anon_vma \*(\*anon_lock)(**struct** folio \*folio, 402 **struct** rmap_walk_control \*rwc); 403 **bool** (\*invalid_vma)(**struct** vm_area_struct \*vma, **void** \*arg); 404 };

 

*Listing 7-33:* include/linux/rmap.h: [*struct rmap_walk_control*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n390)

 

This allows a caller to specify parameters for the walk and a series of

functions that will be invoked at specific points during the walk:-

 

• arg – This is an arbitrary user-defined value which will be passed to the

rmap_one() and invalid_vma() on invocation during the walk (and available to anon_lock()) via the rwc object). This can be useful if the walk has to thread some kind of state through it.

 



 

• try_lock – Indicates whether to abort the walk if the root [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31)

read/write semaphore becomes contended. If it does, the contended field

will be set true. This is used when the [anon_vma_trylock_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n134) variant of the lock should be preferred (and thus we don’t try to wait to acquire a

lock) over [anon_vma_lock_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n129)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n129)

• contended – See above.

• rmap_one – A function that is called for each of the folio’s located

[struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA)’s object. If the function returns false, then the walk is aborted.

• done – Checked after each VMA is examined, parameterised by a folio

and used to determine whether the operation is complete. If this is non-NULL and return true then the walk is terminated.

• anon_lock – An optional function which is used instead of the default

locking mechanism, [rmap_walk_anon_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n2352) if a more efficient means can be determined by the caller.

• invalid_vma – Used to determine whether a VMA is of interest or not – if

it returns true then this VMA is skipped.

 

Examining the [rmap_walk_anon()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n2393) function as shown in Listing 7-34.

 

2384 */\**

2385 *\* rmap_walk_anon - do something to anonymous page using the object-based* 2386 *\* rmap method*

2387 *\* @page: the page to be handled* 2388 *\* @rwc: control variable according to each walk type* 2389 *\**

2390 *\* Find all the mappings of a page using the mapping pointer and the vma*

*chains*

2391 *\* contained in the anon_vma struct it points to.* 2392 *\*/*

2393 **static void rmap_walk_anon**(**struct** folio \*folio, 2394 **struct** rmap_walk_control \*rwc, **bool** locked) 2395 {

2396 **struct** anon_vma \*anon_vma; 2397 **pgoff_t** pgoff_start, pgoff_end; 2398 **struct** anon_vma_chain \*avc; 2399

2400 **if** (locked) {

2401 anon_vma = **folio_anon_vma**(folio); 2402 */\* anon_vma disappear under us? \*/* 2403 **VM_BUG_ON_FOLIO**(!anon_vma, folio); 2404 } **else** {

2405 anon_vma = **rmap_walk_anon_lock**(folio, rwc); 2406 }

2407 **if** (!anon_vma)

2408 **return**;

 



 

2409

2410 pgoff_start = **folio_pgoff**(folio); 2411 pgoff_end = pgoff_start + **folio_nr_pages**(folio) - 1; 2412 **anon_vma_interval_tree_foreach**(avc, &anon_vma-\>rb_root, 2413 pgoff_start, pgoff_end) { 2414 **struct** vm_area_struct \*vma = avc-\>vma; 2415 **unsigned long** address = **vma_address**(&folio-\>page, vma); 2416

2417 **VM_BUG_ON_VMA**(address == -**EFAULT**, vma); 2418 **cond_resched**(); 2419

2420 **if** (rwc-\>**invalid_vma** && rwc-\>**invalid_vma**(vma, rwc-\>arg)) 2421 **continue**; 2422

2423 **if** (!rwc-\>**rmap_one**(folio, vma, address, rwc-\>arg)) 2424 **break**; 2425 **if** (rwc-\>**done** && rwc-\>**done**(folio)) 2426 **break**; 2427 }

2428

2429 **if** (!locked)

2430 **anon_vma_unlock_read**(anon_vma); 2431 }

 

*Listing 7-34:* mm/rmap.c: [*rmap_walk_anon()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n2393)

 

If a lock is held elsewhere (i.e. [rmap_walk_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n2505) was invoked), then the

[struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) object is obtained via the [folio_anon_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n778) helper function as

shown in Listing 7-35.

 

778 **struct** anon_vma \***folio_anon_vma**(**struct** folio \*folio) 779 {

780 **unsigned long** mapping = (**unsigned long**)folio-\>mapping;

781

782 **if** ((mapping & **PAGE_MAPPING_FLAGS**) != **PAGE_MAPPING_ANON**) 783 **return NULL**; 784 **return** (**void** \*)(mapping -**PAGE_MAPPING_ANON**); 785 }

 

*Listing 7-35:* mm/util.c: [*folio_anon_vma()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n778)

 

This function extracts the anon_vma mapping from a folio. Since the folio’s

mapping field can be overloaded with either [PAGE_MAPPING_ANON](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n635) (indicating it is

an anonymous mapping), [PAGE_MAPPING_MOVABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n636) or [PAGE_MAPPING_KSM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n637) (a combi-

nation of the previous two), we must compare the [PAGE_MAPPING_FLAGS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n638)-masked

bits precisely with PAGE_MAPPING_ANON to determine that this is anonymous.

This function then simply extracts the [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) from this field and

returns it.

Examining [rmap_walk_anon_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n2352) as shown in Listing 7-36.

 



 

2352 **static struct** anon_vma \***rmap_walk_anon_lock**(**struct** folio \*folio, 2353 **struct** rmap_walk_control \*rwc) 2354 {

2355 **struct** anon_vma \*anon_vma; 2356

2357 **if** (rwc-\>**anon_lock**) 2358 **return** rwc-\>**anon_lock**(folio, rwc); 2359

2360 */\**

2361 *\* Note: remove_migration_ptes() cannot use folio_lock_anon_vma_read()*

2362 *\* because that depends on page_mapped(); but not all its usages* 2363 *\* are holding mmap_lock. Users without mmap_lock are required to*

2364 *\* take a reference count to prevent the anon_vma disappearing* 2365 *\*/*

2366 anon_vma = **folio_anon_vma**(folio); 2367 **if** (!anon_vma)

2368 **return NULL**; 2369

2370 **if** (**anon_vma_trylock_read**(anon_vma)) 2371 **goto out**; 2372

2373 **if** (rwc-\>try_lock) { 2374 anon_vma = **NULL**; 2375 rwc-\>contended = **true**; 2376 **goto out**; 2377 }

2378

2379 **anon_vma_lock_read**(anon_vma); 2380 **out**:

2381 **return** anon_vma;

2382 }

 

*Listing 7-36:* mm/rmap.c: [*rmap_walk_anon_lock()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n2352)

 

If a custom anon_lock() function is supplied, then this is used. Otherwise,

we determine the anon_vma object from the folio via [folio_anon_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n778) as de-scribed previously.

We then try to acquire a read lock on the anon_vma tree’s root object via

[anon_vma_trylock_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n134). If this does not succeed, and the try_lock field is specified, we mark the lock contended and abort. Otherwise we wait for the

lock the be available via [anon_vma_lock_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n129).

Returning to [rmap_walk_anon_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n2352), we next determine the range of

[struct anon_vma_chain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82) objects mapping our anon_vma object to VMAs via

[folio_pgoff()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n835) which, for non-huge mapping just uses the folio’s index field.

We determine which AVCs span this range via the macro defined in

[anon_vma_interval_tree_foreach()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2572) as shown in Listing 7-37.

 

2572 **\#define anon_vma_interval_tree_foreach**(avc, root, start, last) \\

 



 

2573 **for** (avc = **anon_vma_interval_tree_iter_first**(root, start, last); \\ 2574 avc; avc = **anon_vma_interval_tree_iter_next**(avc, start, last))

 

*Listing 7-37:* include/linux/mm.h: [*anon_vma_interval_tree_foreach()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2572)

 

This iterates through all of the [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA)s connected

to this folio’s [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) field via [struct anon_vma_chain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n82) connecting ob-

jects.

In each of the iterations of this loop executed by [rmap_walk_anon()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n2393), we de-

termine the address of the folio within the VMA via [vma_address()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n579) (and in

turn [vma_pgoff_address()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n553)), then run it through the provided invalid_vma(),

rmap_one() and done() functions with semantics as described above.

Examining the equivalent walk function for file-backed folios,

[rmap_walk_file()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n2441) as shown in Listing 7-38.

 

2433 */\**

2434 *\* rmap_walk_file - do something to file page using the object-based rmap*

*method*

2435 *\* @page: the page to be handled* 2436 *\* @rwc: control variable according to each walk type* 2437 *\**

2438 *\* Find all the mappings of a page using the mapping pointer and the vma*

*chains*

2439 *\* contained in the address_space struct it points to.* 2440 *\*/*

2441 **static void rmap_walk_file**(**struct** folio \*folio, 2442 **struct** rmap_walk_control \*rwc, **bool** locked) 2443 {

2444 **struct** address_space \*mapping = **folio_mapping**(folio); 2445 **pgoff_t** pgoff_start, pgoff_end; 2446 **struct** vm_area_struct \*vma; 2447

2448 */\**

2449 *\* The page lock not only makes sure that page-\>mapping cannot* 2450 *\* suddenly be NULLified by truncation, it makes sure that the* 2451 *\* structure at mapping cannot be freed and reused yet,* 2452 *\* so we can safely take mapping-\>i_mmap_rwsem.* 2453 *\*/*

2454 **VM_BUG_ON_FOLIO**(!**folio_test_locked**(folio), folio); 2455

2456 **if** (!mapping)

2457 **return**;

2458

2459 pgoff_start = **folio_pgoff**(folio); 2460 pgoff_end = pgoff_start + **folio_nr_pages**(folio) - 1; 2461 **if** (!locked) {

2462 **if** (**i_mmap_trylock_read**(mapping)) 2463 **goto lookup**; 2464

 



 

2465 **if** (rwc-\>try_lock) { 2466 rwc-\>contended = **true**; 2467 **return**; 2468 }

2469

2470 **i_mmap_lock_read**(mapping); 2471 }

2472 **lookup**:

2473 **vma_interval_tree_foreach**(vma, &mapping-\>i_mmap, 2474 pgoff_start, pgoff_end) { 2475 **unsigned long** address = **vma_address**(&folio-\>page, vma); 2476

2477 **VM_BUG_ON_VMA**(address == -**EFAULT**, vma); 2478 **cond_resched**(); 2479

2480 **if** (rwc-\>**invalid_vma** && rwc-\>**invalid_vma**(vma, rwc-\>arg)) 2481 **continue**; 2482

2483 **if** (!rwc-\>**rmap_one**(folio, vma, address, rwc-\>arg)) 2484 **goto done**; 2485 **if** (rwc-\>**done** && rwc-\>**done**(folio)) 2486 **goto done**; 2487 }

2488

2489 **done**:

2490 **if** (!locked)

2491 **i_mmap_unlock_read**(mapping); 2492 }

 

*Listing 7-38:* mm/rmap.c: [*rmap_walk_file()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n2441)

This mirrors [rmap_walk_anon()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n2393)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n2393) only with the equivalent operations for file-

backed mappings.

In both cases, we determine a folio’s virtual address via [vma_address()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n579) as

shown in Listing 7-39.

 

573 */\**

574 *\* Return the start of user virtual address of a page within a vma.* 575 *\* Returns -EFAULT if all of the page is outside the range of vma.* 576 *\* If page is a compound head, the entire compound page is considered.* 577 *\*/*

578 **static inline unsigned long** 579 vma_address(**struct** page \*page, **struct** vm_area_struct \*vma) 580 {

581 **VM_BUG_ON_PAGE**(**PageKsm**(page), page); */\* KSM page-\>index unusable \*/* 582 **return vma_pgoff_address**(**page_to_pgoff**(page), **compound_nr**(page), vma); 583 }

 

*Listing 7-39:* mm/internal.h: [*vma_address()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n579)

 



 

This functions by determining the page offset of the folio within the

mapping via [page_to_pgoff()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n790) (for anything other than huge pages this will

simply be the [struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256)[’s](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) index field), which is passed to [vma_pgoff_address()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n553)

to do the heavy lifting, as shown in Listing 7-40.

 

548 */\**

549 *\* Return the start of user virtual address at the specific offset within* 550 *\* a vma.*

551 *\*/*

552 **static inline unsigned long** 553 **vma_pgoff_address**(**pgoff_t** pgoff, **unsigned long** nr_pages, 554 **struct** vm_area_struct \*vma) 555 {

556 **unsigned long** address;

557

558 **if** (pgoff \>= vma-\>vm_pgoff) { 559 address = vma-\>vm_start + 560 ((pgoff - vma-\>vm_pgoff) \<\< **PAGE_SHIFT**); 561 */\* Check for address beyond vma (or wrapped through 0?) \*/*

562 **if** (address \< vma-\>vm_start \|\| address \>= vma-\>vm_end) 563 address = -**EFAULT**; 564 } **else if** (pgoff + nr_pages - 1 \>= vma-\>vm_pgoff) { 565 */\* Test above avoids possibility of wrap to 0 on 32-bit \*/*

566 address = vma-\>vm_start; 567 } **else** {

568 address = -**EFAULT**; 569 }

570 **return** address;

571 }

 

*Listing 7-40:* mm/internal.h: [*vma_pgoff_address()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n553)

 

For non-compound (i.e. in this scenario, non-huge) pages, this is sim-

ply the provided page offset, less the [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA)’s vm_pgoff

field, multiplied by base page size and added to the vm_start field – in other

words, the virtual address of the folio within the mapping, as required.

Note that for anonymous backings the page offsets are virtual page off-

sets and for file backings the page offsets are 0-indexed offsets into the page

cache object.

The additional logic here accounts for a compound case wrapping

around on 32-bit systems and of course, if the folio does not reside within

the VMA, it returns an error.

The equivalent to [folio_anon_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n778) is [folio_mapping()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n799)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n799) as shown in Listing

7-41.

 

787 */\*\**

788 *\* folio_mapping - Find the mapping where this folio is stored.* 789 *\* @folio: The folio.*

790 *\**

 



 

791 *\* For folios which are in the page cache, return the mapping that this* 792 *\* page belongs to. Folios in the swap cache return the swap mapping* 793 *\* this page is stored in (which is different from the mapping for the* 794 *\* swap file or swap device where the data is stored).* 795 *\**

796 *\* You can call this for folios which aren't in the swap cache or page* 797 *\* cache and it will return NULL.* 798 *\*/*

799 **struct** address_space \***folio_mapping**(**struct** folio \*folio) 800 {

801 **struct** address_space \*mapping; 802

803 */\* This happens if someone calls flush_dcache_page on slab page \*/*

804 **if** (**unlikely**(**folio_test_slab**(folio))) 805 **return NULL**; 806

807 **if** (**unlikely**(**folio_test_swapcache**(folio))) 808 **return swap_address_space**(**folio_swap_entry**(folio)); 809

810 mapping = folio-\>mapping; 811 **if** ((**unsigned long**)mapping & **PAGE_MAPPING_FLAGS**) 812 **return NULL**; 813

814 **return** mapping;

815 }

 

*Listing 7-41:* mm/util.c: [*folio_mapping()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n799)

This performs a check against a race with the kernel slab mechanism (see

the slab chapter for more on this), then a swap cache check (see the swap chapter for a discussion of the kernel swap mechanism, this is out of scope

here), before finally checking whether any [PAGE_MAPPING_FLAGS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n638) have been set -if they have, the mapping is invalid and it returns NULL, otherwise it returns a

pointer to the relevant [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) object.

[rmap_walk_file()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n2441) then performs a check to ensure that the folio is not

locked (more on folio locking in the page cache chapter), and aborts if no address_space object could be found.

Next the offsets to be searched for are determined in precisely the same

fashion as in [rmap_walk_anon()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n2393)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n2393) then the try lock/lock dance is performed,

only this time against the i_mmap_rwsem lock, using [i_mmap_trylock_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n479) and

[i_mmap_lock_read() .](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n484)

We loop over the mappings using [vma_interval_tree_foreach()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2555) as shown in

Listing 7-42.

 

2555 **\#define vma_interval_tree_foreach**(vma, root, start, last) \\ 2556 **for** (vma = **vma_interval_tree_iter_first**(root, start, last); \\ 2557 vma; vma = **vma_interval_tree_iter_next**(vma, start, last))

 

*Listing 7-42:* include/linux/mm.h: [*vma_interval_tree_foreach()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2555)

 



 

Which iterates through i_mmap returning all of the related

[struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA)s. The operations performed on them mirror

those performed by rmap_walk_anon().

Finally, the i_mmap_rwsem read lock is released via [i_mmap_unlock_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n489) if

this is not invoked via [rmap_walk_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n2505)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n2505)

There are a number of users of this mechanism, each of which make in-

tricate use of this functionality. For brevity, we won’t examine these closely

but instead list some core examples:-

 

• [folio_referenced()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n900) – An absolutely critical function used in reclaim to

determine the number of mappings which reference the specified folio.

• [try_to_unmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1812) – Another absolutely critical function, and indeed the mo-

tivating case we discussed at the start of this section – this attempts to unmap the specified folio from all VMAs which map it. This can call ei-ther the unlocked or the locked version of the walk function depending on passed flags.

• [folio_mkclean()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1035) – Clears the dirty flag for the specified folio

and marks the mapping write-protected as part of writeback via

[folio_clear_dirty_for_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2826).

• [try_to_migrate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n2120) – Used as part of the migration process (see the chapter

on this for more details on this topic as a whole), replacing mappings with swap cache entries (for details on the swap cache, see the swap chapter). This can call either the unlocked or the locked version of the walk function depending on passed flags.

• [folio_make_device_exclusive()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n2261) – Used to mark a folio as being exclusively

owned by a specific device, as invoked by [make_device_exclusive_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n2310) as part of the functionality provided by CONFIG_DEVICE_PRIVATE.

• [remove_migration_ptes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/migrate.c?h=v6.0#n270) – Removes migration entries and sets actual

page mappings as part of the migration process. This can call either the unlocked or the locked version of the walk function depending on its locked parameter.

 

***7.0.16 Walking the VMA***

Recall that the reverse mapping might reference VMAs which do not, in fact,

map the folio being walked – the folio may have since been CoW’d to a child

process, but the parent’s [struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) will still map to the child’s VMA.

This is something that has to be checked once a VMA is obtained from

the reverse mapping. In addition a mapping can disappear from beneath

us at any time, without a lock on the PTE we simply cannot be sure that the

mapping still exists, so this is absolutely necessary.

We therefore must walk the page tables to check that the folio is indeed

mapped by the VMA at a specific address, and acquire its PTE lock while

we do so. This is performed by [page_vma_mapped_walk()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_vma_mapped.c?h=v6.0#n151) and mediated by the

[struct page_vma_mapped_walk](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n316) object, which we shall examine first as shown in

Listing 7-43.

 



 

316 **struct** page_vma_mapped_walk { 317 **unsigned long** pfn; 318 **unsigned long** nr_pages; 319 **pgoff_t** pgoff;

320 **struct** vm_area_struct \*vma; 321 **unsigned long** address; 322 **pmd_t** \*pmd;

323 **pte_t** \*pte;

324 **spinlock_t** \*ptl;

325 **unsigned int** flags; 326 };

 

*Listing 7-43:* include/linux/rmap.h: [*struct page_vma_mapped_walk*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n316)

 

Examining each field:-

 

• pfn – required – The Page Frame Number (PFN) of the folio we are check-

ing the mappings for. This is the physical address of the folio divided by

the base page size and can be obtained for a folio via [folio_pfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1463).

• nr_pages – required – The number of base pages to iterate over start-

ing from the PFN. Typically this will be equal to 1 except for huge pages or for operations which are iterating over a range of folios like

[pfn_mkclean_range().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1072)

• pgoff – required – The page offset of the folio. For anything other than

huge pages this will be equal to the [struct folio-\>index](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) field.

• vma – required – The [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) whose page table map-

pings we are walking.

• address – required – The virtual address we are checking exists within

the VMA. In the usual case where this walk is being called from within

a reverse-mapping walk this will have been determined via [vma_address()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n579).

• pmd – output – A pointer to the PMD entry associated with this mapping.

• pte – output – A pointer to the PTE entry associated with this mapping.

• ptl – output – The page table lock which will be acquired should a map-

ping be discovered.

• flags – required (can be zero) – Flags which modify the behaviour of the

walk – can either be zero if there are no special requirements, [PVMW_SYNC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n312) if checks which might result in race conditions are to be avoided and

[PVMW_MIGRATION](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n314) if, instead of PTEs, we are looking for migration entries (see the migration chapter for more on this).

 

Often these parameters are set by macro, specifically

[DEFINE_FOLIO_VMA_WALK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n338) and the [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) equivalent [DEFINE_PAGE_VMA_WALK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n328)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n328)

Examining the former as shown in Listing 7-44.

 

338 **\#define DEFINE_FOLIO_VMA_WALK**(name, \_folio, \_vma, \_address, \_flags) \\ 339 **struct** page_vma_mapped_walk name = { \\

 



 

340 .pfn = **folio_pfn**(\_folio), \\ 341 .nr_pages = **folio_nr_pages**(\_folio), \\ 342 .pgoff = **folio_pgoff**(\_folio), \\ 343 .vma = \_vma, \\ 344 .address = \_address, \\ 345 .flags = \_flags, \\ 346 }

 

*Listing 7-44:* include/linux/rmap.h: [*DEFINE_FOLIO_VMA_WALK*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n338)

 

This determines the PFN via [folio_pfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1463)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1463) the page count via

[folio_nr_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1598) and the page offset via [folio_pgoff()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n835).

The [page_vma_mapped_walk()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_vma_mapped.c?h=v6.0#n151) function itself accepts a single parameter of

a [struct page_vma_mapped_walk](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n316) object and returns true if a valid mapping is re-

ceived, with pmd, pte and ptl set and false when none remain, with the ptl

lock released.

This function is therefore typically called in a while loop in order

to handle huge page cases. If this process needs to be exited early,

[page_vma_mapped_walk_done()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n348) can be called, which unlocks the page table lock,

thus aborting the process as shown in Listing 7-45.

 

348 **static inline void** page_vma_mapped_walk_done(**struct** page_vma_mapped_walk \*pvmw

)

349 {

350 */\* HugeTLB pte is set to the relevant page table entry without*

*pte_mapped. \*/*

351 **if** (pvmw-\>pte && !**is_vm_hugetlb_page**(pvmw-\>vma)) 352 **pte_unmap**(pvmw-\>pte); 353 **if** (pvmw-\>ptl)

354 **spin_unlock**(pvmw-\>ptl); 355 }

 

*Listing 7-45:* include/linux/rmap.h: [*page_vma_mapped_walk_done()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n348)

 

For anything resembling a modern system, [pte_unmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n104) is a no-op, so this

simply frees the PTE page table lock ptl.

Examining [page_vma_mapped_walk()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_vma_mapped.c?h=v6.0#n151) (eliding out of scope huge page and

devmap logic) as shown in Listing 7-46.

 

127 */\*\**

128 *\* page_vma_mapped_walk - check if @pvmw-\>pfn is mapped in @pvmw-\>vma at* 129 *\* @pvmw-\>address*

130 *\* @pvmw: pointer to struct page_vma_mapped_walk. page, vma, address and flags*

131 *\* must be set. pmd, pte and ptl must be NULL.* 132 *\**

133 *\* Returns true if the page is mapped in the vma. @pvmw-\>pmd and @pvmw-\>pte*

*point*

134 *\* to relevant page table entries. @pvmw-\>ptl is locked. @pvmw-\>address is*

135 *\* adjusted if needed (for PTE-mapped THPs).* 136 *\**

 



 

137 *\* If @pvmw-\>pmd is set but @pvmw-\>pte is not, you have found PMD-mapped page*

138 *\* (usually THP). For PTE-mapped THP, you should run page_vma_mapped_walk() in*

139 *\* a loop to find all PTEs that map the THP.* 140 *\**

141 *\* For HugeTLB pages, @pvmw-\>pte is set to the relevant page table entry* 142 *\* regardless of which page table level the page is mapped at. @pvmw-\>pmd is*

143 *\* NULL.*

144 *\**

145 *\* Returns false if there are no more page table entries for the page in* 146 *\* the vma. @pvmw-\>ptl is unlocked and @pvmw-\>pte is unmapped.* 147 *\**

148 *\* If you need to stop the walk before page_vma_mapped_walk() returned false,*

149 *\* use page_vma_mapped_walk_done(). It will do the housekeeping.* 150 *\*/*

151 **bool page_vma_mapped_walk**(**struct page_vma_mapped_walk** \*pvmw) 152 {

153 **struct** vm_area_struct \*vma = pvmw-\>vma; 154 **struct** mm_struct \*mm = vma-\>vm_mm; 155 **unsigned long** end; 156 **pgd_t** \*pgd;

157 **p4d_t** \*p4d;

158 **pud_t** \*pud;

159 **pmd_t** pmde;

160

161 */\* The only possible pmd mapping has been handled on last iteration \*/*

162 **if** (pvmw-\>pmd && !pvmw-\>pte) 163 **return not_found**(pvmw); 164

165 **if** (**unlikely**(**is_vm_hugetlb_page**(vma))) {

. . .

181 }

182

183 end = **vma_address_end**(pvmw); 184 **if** (pvmw-\>pte)

185 **goto next_pte**; 186 **restart**:

187 **do** {

188 pgd = **pgd_offset**(mm, pvmw-\>address); 189 **if** (!**pgd_present**(\*pgd)) { 190 **step_forward**(pvmw, **PGDIR_SIZE**); 191 **continue**; 192 }

193 p4d = **p4d_offset**(pgd, pvmw-\>address); 194 **if** (!**p4d_present**(\*p4d)) { 195 **step_forward**(pvmw, **P4D_SIZE**); 196 **continue**; 197 }

 



 

198 pud = **pud_offset**(p4d, pvmw-\>address); 199 **if** (!**pud_present**(\*pud)) { 200 **step_forward**(pvmw, **PUD_SIZE**); 201 **continue**; 202 }

203

204 pvmw-\>pmd = **pmd_offset**(pud, pvmw-\>address); 205 */\**

206 *\* Make sure the pmd value isn't cached in a register by the*

207 *\* compiler and used as a stale value after we've observed a*

208 *\* subsequent update.* 209 *\*/*

210 pmde = **READ_ONCE**(\*pvmw-\>pmd);

211

212 **if** (**pmd_trans_huge**(pmde) \|\| **is_pmd_migration_entry**(pmde) \|\| 213 (**pmd_present**(pmde) && **pmd_devmap**(pmde))) {

. . .

238 } **else if** (!**pmd_present**(pmde)) {

. . .

251 **step_forward**(pvmw, **PMD_SIZE**); 252 **continue**; 253 }

254 **if** (!**map_pte**(pvmw)) 255 **goto next_pte**; 256 **this_pte**:

257 **if** (**check_pte**(pvmw)) 258 **return true**; 259 **next_pte**:

260 **do** {

261 pvmw-\>address += **PAGE_SIZE**; 262 **if** (pvmw-\>address \>= end) 263 **return not_found**(pvmw); 264 */\* Did we cross page table boundary? \*/* 265 **if** ((pvmw-\>address & (**PMD_SIZE**-**PAGE_SIZE**)) == 0) { 266 **if** (pvmw-\>ptl) { 267 **spin_unlock**(pvmw-\>ptl); 268 pvmw-\>ptl = **NULL**; 269 } 270 **pte_unmap**(pvmw-\>pte); 271 pvmw-\>pte = **NULL**; 272 **goto restart**; 273 } 274 pvmw-\>pte++; 275 **if** ((pvmw-\>flags & **PVMW_SYNC**) && !pvmw-\>ptl) { 276 pvmw-\>ptl = **pte_lockptr**(mm, pvmw-\>pmd); 277 **spin_lock**(pvmw-\>ptl); 278 }

 



 

279 } **while** (**pte_none**(\*pvmw-\>pte)); 280

281 **if** (!pvmw-\>ptl) { 282 pvmw-\>ptl = **pte_lockptr**(mm, pvmw-\>pmd); 283 **spin_lock**(pvmw-\>ptl); 284 }

285 **goto this_pte**; 286 } **while** (pvmw-\>address \< end); 287

288 **return false**;

289 }

 

*Listing 7-46:* mm/page_vma_mapped.c: [*page_vma_mapped_walk()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_vma_mapped.c?h=v6.0#n151)

 

This uses helper functions to adjust the state of the

[struct page_vma_mapped_walk](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n316) object – [not_found()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_vma_mapped.c?h=v6.0#n10) and [step_forward()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_vma_mapped.c?h=v6.0#n120). The

former simply invokes [page_vma_mapped_walk_done()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n348) and returns false, there-fore aborting the operation, let’s examine the latter as shown in Listing

7-47.

 

120 **static void step_forward**(**struct** page_vma_mapped_walk \*pvmw, **unsigned long** size

)

121 {

122 pvmw-\>address = (pvmw-\>address + size) & ~(size - 1); 123 **if** (!pvmw-\>address) 124 pvmw-\>address = **ULONG_MAX**; 125 }

 

*Listing 7-47:* mm/page_vma_mapped.c: [*step_forward()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_vma_mapped.c?h=v6.0#n120)

 

This advances the address field by the specified size, clearing the lower

bits as it does so. If the value wraps around, ULONG_MAX is set, i.e. placing the address at the maximum possible value and therefore aborting the opera-tion on the next iteration.

The [vma_address_end()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n589) helper function is critical here – it determines the

first address after that spanned by the folio (i.e. an exclusive bound). Exam-

ining it as shown in Listing 7-48.

 

585 */\**

586 *\* Then at what user virtual address will none of the range be found in vma?*

587 *\* Assumes that vma_address() already returned a good starting address.* 588 *\*/*

589 **static inline unsigned long vma_address_end**(**struct** page_vma_mapped_walk \*pvmw) 590 {

591 **struct** vm_area_struct \*vma = pvmw-\>vma; 592 **pgoff_t** pgoff;

593 **unsigned long** address; 594

595 */\* Common case, plus -\>pgoff is invalid for KSM \*/* 596 **if** (pvmw-\>nr_pages == 1)

 



 

597 **return** pvmw-\>address + **PAGE_SIZE**;

598

599 pgoff = pvmw-\>pgoff + pvmw-\>nr_pages; 600 address = vma-\>vm_start + ((pgoff - vma-\>vm_pgoff) \<\< **PAGE_SHIFT**); 601 */\* Check for address beyond vma (or wrapped through 0?) \*/* 602 **if** (address \< vma-\>vm_start \|\| address \> vma-\>vm_end) 603 address = vma-\>vm_end; 604 **return** address;

605 }

 

*Listing 7-48:* mm/internal.h: [*vma_address_end()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n589)

 

For single-page folios (i.e. non-huge), this simply returns the address field

incremented by base page size. Otherwise, this limits the return value to the

final address of the [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA).

PTEs are mapped via [map_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_vma_mapped.c?h=v6.0#n16) which, eliding out of scope swap and mi-

gration cases, is rather simple as shown in Listing 7-49.

 

16 **static bool map_pte**(**struct** page_vma_mapped_walk \*pvmw)

17 {

18 pvmw-\>pte = **pte_offset_map**(pvmw-\>pmd, pvmw-\>address);

19 **if** (!(pvmw-\>flags & **PVMW_SYNC**)) {

20 **if** (pvmw-\>flags & **PVMW_MIGRATION**) {

. . .

47 } **else if** (!**pte_present**(\*pvmw-\>pte))

48 **return false**;

49 }

50 }

51 pvmw-\>ptl = **pte_lockptr**(pvmw-\>vma-\>vm_mm, pvmw-\>pmd);

52 **spin_lock**(pvmw-\>ptl);

53 **return true**;

54 }

 

*Listing 7-49:* mm/page_vma_mapped.c: [*map_pte()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_vma_mapped.c?h=v6.0#n16)

 

The PTE entry is obtained via [pte_offset_map()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n103) from the previously ob-

tained pmd entry, the PTE lock is obtained via [pte_lockptr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2246) and placed in the

ptl field before being locked.

Before a candidate PTE is returned, the [check_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_vma_mapped.c?h=v6.0#n75) function is called.

With migration and swap cases elided as out of scope for this section, the

function is relatively simple as shown in Listing 7-50.

 

56 */\*\**

57 *\* check_pte - check if @pvmw-\>page is mapped at the @pvmw-\>pte*

58 *\* @pvmw: page_vma_mapped_walk struct, includes a pair pte and page for*

*checking*

59 *\**

60 *\* page_vma_mapped_walk() found a place where @pvmw-\>page is \*potentially\**

61 *\* mapped. check_pte() has to validate this.*

62 *\**

 



 

63 *\* pvmw-\>pte may point to empty PTE, swap PTE or PTE pointing to* 64 *\* arbitrary page.*

65 *\**

66 *\* If PVMW_MIGRATION flag is set, returns true if @pvmw-\>pte contains*

*migration*

67 *\* entry that points to @pvmw-\>page or any subpage in case of THP.* 68 *\**

69 *\* If PVMW_MIGRATION flag is not set, returns true if pvmw-\>pte points to*

70 *\* pvmw-\>page or any subpage in case of THP.* 71 *\**

72 *\* Otherwise, return false.* 73 *\**

74 *\*/*

75 **static bool check_pte**(**struct** page_vma_mapped_walk \*pvmw) 76 {

77 **unsigned long** pfn; 78

79 **if** (pvmw-\>flags & **PVMW_MIGRATION**) {

. . .

90 } **else if** (**is_swap_pte**(\*pvmw-\>pte)) {

. . .

100 } **else** {

101 **if** (!**pte_present**(\*pvmw-\>pte)) 102 **return false**; 103

104 pfn = **pte_pfn**(\*pvmw-\>pte); 105 }

106

107 **return** (pfn - pvmw-\>pfn) \< pvmw-\>nr_pages; 108 }

 

*Listing 7-50:* mm/page_vma_mapped.c: [*check_pte()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_vma_mapped.c?h=v6.0#n75)

 

This simply checks whether the PTE entry has its present bit set via

[pte_present(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n734)obtains the PFN specified by the PTE entry via [pte_pfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n186) and checks that this is within the nr_pages specified.

Now we have examined the helper functions, we can return to the logic

of [page_vma_mapped_walk()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_vma_mapped.c?h=v6.0#n151):-

 

1. Determine the PGD entry for the target address via [pgd_offset()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n133) and

confirm it has its present bit set via [pgd_present()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n906)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n906) if not we advance to the next PGD entry.

2. Determine the P4D entry for the target address via [p4d_offset()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n925) and con-

firm it has its present bit set via [p4d_present()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n873)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n873) if not we advance to the next P4D entry.

3. Determine the PUD entry for the target address via [pud_offset()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n117) and

confirm it has its present bit set via [pud_present()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n832)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n832) if not we advance to the next PUD entry.

 



 

4. Determine the PMD entry for the target address via [pmd_offset()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n109) and

place it in the pvmw object’s pmd field. Then check it has its present bit set

via [pmd_present()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n759)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n759) if not we advance to the next PMD entry.

5. If we reach this stage with all the prior entries, we attempt to map the

PTE referenced by the PMD entry via [map_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_vma_mapped.c?h=v6.0#n16) as described above, if we cannot we advance to the next_pte logic.

6. If we were able to map, we then invoke [check_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_vma_mapped.c?h=v6.0#n75) as described above –

if the check passes, we return true to indicate that we have found a valid PTE. Note that the PTE lock is held at this point so the caller can oper-ate on this mapping without fear of it disappearing.

7. If the map or check failed, we enter the next_pte logic – this attempts to

find the first non-empty PTE in the folio range, which is then subject to the same checks and the process repeated throughout the range. This would only be required for huge pages, as ordinary mappings would

span only one and exit quickly by invoking [not_found()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_vma_mapped.c?h=v6.0#n10).

 

***7.0.17 Summary***

The reverse mapping functionality provides a critical link between folios and

overlying VMAs, without which core kernel functionality could not be imple-

mented.

The equivalence between the anonymous and file-backed versions of the

reverse mapping are critical, as the kernel can then therefore lookup map-

pings indifferent to what backs a specific folio.

The subject is complicated and confusing, but once you break it down

into the motivating reasons for maintaining the mapping and examining the

more involved intricacies of the mechanism – changes in VMAs and forking

– it becomes clear that the complexity serves an important service.

It’s important to emphasise that the reverse mapping find VMAs which

might map the folio being sought, but examining of the ‘forward’ mappings

is still required via [page_vma_mapped_walk()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_vma_mapped.c?h=v6.0#n151)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_vma_mapped.c?h=v6.0#n151)

 

**7.1 Freeing userland memory and the TLB**

 

Freeing pages mapped by userland is more complicated than it might seem

as a result of modern memory management hardware, specifically the Trans-

action Lookaside Buffer (TLB) which maintains a cache between virtual ad-

dresses and physical addresses on each CPU core.

We briefly touched on this topic in the virtual memory chapter, however

now we have a good grounding in how userland memory functions in the

kernel, we will look at how we interact with this hardware in practice.

Kernel memory by its nature requires significantly less maintenance –

there is only one kernel mapping, memory allocated from the slab or page

allocators are mapped through the direct mapping which requires very little

 



 

TLB maintenance\* and cases where memory is actually mapped and un-mapped like vmalloc are infrequent enough that they require little special handling.

Userland on the other hand is eminently complicated – there are multi-

ple address spaces each of which could be running simultaneously on mul-tiple CPUs and actively utilising each core’s TLB cache at the point of mem-ory being freed.

We therefore must be especially careful about how we interact with the

TLB and only free userland pages once the TLB is definitely invalidated across all cores sharing the same address space.

The process of gathering TLB operations to perform is termed

MMU-gather and described in detail in the generic assembly header

[include/asm-generic/tlb.h.](https://elixir.bootlin.com/linux/v6.0/source/include/asm-generic/tlb.h)

The order in which operations are performed is:-

 

1. Remove page table mappings (but TLB entries may remain in multiple

CPU caches)

2. Invalidate TLB caches (now nothing should be accessing the pages)

3. (If freeing memory) Finally, free the underlying pages

 

***7.1.1 Unmapping memory mapped regions***

See Chapter 5 for more on memory mapping as a whole.

When examining how the TLB functionality works, it’s instructive to

examine a motivating example. One of the key users of the MMU gather

functionality is the code which unmaps [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html)[’d](https://man7.org/linux/man-pages/man2/mmap.2.html) memory ranges. This is ulti-

mately performed by [unmap_region()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2612) as shown in Listing 7-51.

 

2607 */\**

2608 *\* Get rid of page table information in the indicated region.* 2609 *\**

2610 *\* Called with the mm semaphore held.* 2611 *\*/*

2612 **static void unmap_region**(**struct** mm_struct \*mm, 2613 **struct** vm_area_struct \*vma, **struct** vm_area_struct \*prev, 2614 **unsigned long** start, **unsigned long** end) 2615 {

2616 **struct** vm_area_struct \*next = **vma_next**(mm, prev); 2617 **struct** mmu_gather tlb; 2618

2619 **lru_add_drain**();

2620 **tlb_gather_mmu**(&tlb, mm); 2621 **update_hiwater_rss**(mm);

 

\*. Mappings which exist there will always be mapped to the same physical memory under most circumstances (though a few exist where the direct mapping might get updated like memory hotplug).

 



 

2622 **unmap_vmas**(&tlb, vma, start, end); 2623 **free_pgtables**(&tlb, vma, prev ? prev-\>vm_end : **FIRST_USER_ADDRESS**, 2624 next ? next-\>vm_start : **USER_PGTABLES_CEILING**

);

2625 **tlb_finish_mmu**(&tlb); 2626 }

 

*Listing 7-51:* mm/mmap.c: [*unmap_region()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2612)

 

We start by invoking [tlb_gather_mmu()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n297) which initialises a [struct mmu_gather](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n267)

object which will be used throughout the operation. The heavy lifting of per-

forming cache invalidations is handled by [unmap_vmas()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1716), page tables are freed

via [free_pgtables()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n405) before the TLB operation is executed (invalidating the

cache and freeing memory) via [tlb_finish_mmu()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n325)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n325)

It’s important to note that prior to this call being made, vma will either

not be attached to any subsequent VMAs in the process address space, or

will have been detached from subsequent VMAs.

This is important as later we rely on this fact to iterate through affected

VMAs (described in section 7.1.5).

 

***7.1.2 MMU gather initialisation***

The [struct mmu_gather](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n267) data structure maintains state throughout the TLB

operation:-

 

263 */\**

264 *\* struct mmu_gather is an opaque type used by the mm code for passing around*

265 *\* any data needed by arch specific code for tlb_remove_page.* 266 *\*/*

267 **struct** mmu_gather {

268 **struct** mm_struct \*mm;

269

270 **\#ifdef CONFIG_MMU_GATHER_TABLE_FREE** 271 **struct** mmu_table_batch \*batch; 272 **\#endif**

273

274 **unsigned long** start; 275 **unsigned long** end; 276 */\**

277 *\* we are in the middle of an operation to clear* 278 *\* a full mm and can make some optimizations* 279 *\*/*

280 **unsigned int** fullmm : 1;

281

282 */\**

283 *\* we have performed an operation which* 284 *\* requires a complete flush of the tlb* 285 *\*/*

 



 

286 **unsigned int** need_flush_all : 1; 287

288 */\**

289 *\* we have removed page directories* 290 *\*/*

291 **unsigned int** freed_tables : 1; 292

293 */\**

294 *\* at which levels have we cleared entries?* 295 *\*/*

296 **unsigned int** cleared_ptes : 1; 297 **unsigned int** cleared_pmds : 1; 298 **unsigned int** cleared_puds : 1; 299 **unsigned int** cleared_p4ds : 1; 300

301 */\**

302 *\* tracks VM_EXEC \| VM_HUGETLB in tlb_start_vma* 303 *\*/*

304 **unsigned int** vma_exec : 1; 305 **unsigned int** vma_huge : 1; 306 **unsigned int** vma_pfn : 1; 307

308 **unsigned int** batch_count; 309

310 **\#ifndef CONFIG_MMU_GATHER_NO_GATHER** 311 **struct** mmu_gather_batch \*active; 312 **struct** mmu_gather_batch local; 313 **struct** page \*\_\_pages\[**MMU_GATHER_BUNDLE**\]; 314

315 **\#ifdef CONFIG_MMU_GATHER_PAGE_SIZE** 316 **unsigned int** page_size; 317 **\#endif**

318 **\#endif**

319 };

 

*Listing 7-52:* include/asm-generic/tlb.h: [*struct mmu_gather*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n267)

 

This stores mm, a pointer to the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) which describes the pro-

cess address space whose TLB state we are modifying, the start and (exclu-sive) end of the range being operated upon in start and end.

MMU operations are divided into batches which are described by the

[struct mmu_gather_batch](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n241) type which we will examine shortly. The total batch count is tracked by the batch_count field, with a pointer to the current batch stored in active.

The local and \_\_pages fields overlap one another as the

struct mmu_gather_batch object has a variable array as its final field and this forms the initial batch (further batches are allocated).

 



 

Finally there are a number of well-documented flags and a

[struct mmu_table_batch](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n193) object referenced in the batch field used for freeing

page tables. Page table size (to accommodate huge pages) is stored in the

page_size field.

Whether we batch operations at all is determined by

CONFIG_MMU_GATHER_NO_GATHER , whether we store variable page size is deter-

mined by CONFIG_MMU_GATHER_PAGE_SIZE and whether we batch page table

TLB operations is determined by CONFIG_MMU_GATHER_TABLE_FREE. Modern

architectures will typically specify all of these, and x86-64 certainly does so

we will proceed on the assumption they are all set.

Examining [struct mmu_gather_batch](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n241) as shown in Listing 7-53.

 

241 **struct** mmu_gather_batch { 242 **struct** mmu_gather_batch \*next; 243 **unsigned int** nr; 244 **unsigned int** max; 245 **struct** page \*pages\[\]; 246 };

 

*Listing 7-53:* include/asm-generic/tlb.h: [*struct mmu_gather_batch*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n241)

 

The batch consists of pages, an array of [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) objects which are un-

dergoing TLB cache invalidation, which is specified as a variable length

array placed immediately after the other fields. There are nr pages up to a

maximum of max with the next batch, if any, pointed at by next.

For the initial local copy of this object (which will typically be on the

stack) max is set to [MMU_GATHER_BUNDLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n239) (hardcoded to 8). Afterwards a base page

is allocated for each new batch with these fields adjusted accordingly.

We examine [tlb_gather_mmu()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n297) in Listing 7-54.

 

289 */\*\**

290 *\* tlb_gather_mmu - initialize an mmu_gather structure for page-table tear-*

*down*

291 *\* @tlb: the mmu_gather structure to initialize* 292 *\* @mm: the mm_struct of the target address space* 293 *\**

294 *\* Called to initialize an (on-stack) mmu_gather structure for page-table* 295 *\* tear-down from @mm.*

296 *\*/*

297 **void tlb_gather_mmu**(**struct** mmu_gather \*tlb, **struct** mm_struct \*mm) 298 {

299 **\_\_tlb_gather_mmu**(tlb, mm, **false**); 300 }

 

*Listing 7-54:* mm/mmu_gather.c: [*tlb_gather_mmu()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n297)

 

It’s worth noting that there is an alternative to this function which

performs this operation across the entirety of the process address space,

[tlb_gather_mmu_fullmm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n313) as shown in Listing 7-55.

 



 

302 */\*\**

303 *\* tlb_gather_mmu_fullmm - initialize an mmu_gather structure for page-table*

*tear-down*

304 *\* @tlb: the mmu_gather structure to initialize* 305 *\* @mm: the mm_struct of the target address space* 306 *\**

307 *\* In this case, @mm is without users and we're going to destroy the* 308 *\* full address space (exit/execve).* 309 *\**

310 *\* Called to initialize an (on-stack) mmu_gather structure for page-table*

311 *\* tear-down from @mm.*

312 *\*/*

313 **void tlb_gather_mmu_fullmm**(**struct** mmu_gather \*tlb, **struct** mm_struct \*mm) 314 {

315 **\_\_tlb_gather_mmu**(tlb, mm, **true**); 316 }

 

*Listing 7-55:* mm/mmu_gather.c: [*tlb_gather_mmu_fullmm*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n313)

 

These each differ only in whether they specify the fullmm boolean argu-

ment to [\_\_tlb_gather_mmu()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n265) which does the heavy lifting as shown in Listing

7-56.

 

265 **static void \_\_tlb_gather_mmu**(**struct** mmu_gather \*tlb, **struct** mm_struct \*mm, 266 **bool** fullmm) 267 {

268 tlb-\>mm = mm;

269 tlb-\>fullmm = fullmm; 270

271 **\#ifndef CONFIG_MMU_GATHER_NO_GATHER** 272 tlb-\>need_flush_all = 0; 273 tlb-\>local.next = **NULL**; 274 tlb-\>local.nr = 0; 275 tlb-\>local.max = **ARRAY_SIZE**(tlb-\>\_\_pages); 276 tlb-\>active = &tlb-\>local; 277 tlb-\>batch_count = 0; 278 **\#endif**

279

280 **tlb_table_init**(tlb); 281 **\#ifdef CONFIG_MMU_GATHER_PAGE_SIZE** 282 tlb-\>page_size = 0; 283 **\#endif**

284

285 **\_\_tlb_reset_range**(tlb); 286 **inc_tlb_flush_pending**(tlb-\>mm); 287 }

 

*Listing 7-56:* mm/mmu_gather.c: [*\_\_tlb_gather_mmu()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n265)

 



 

This initialises all fields in the [struct mmu_gather](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n267) object, setting active to

point to the local stack object before initialising it.

[tlb_table_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n239) simply sets batch to NULL, [\_\_tlb_reset_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n331) resets flags

and the start and end values to preset initial values as shown in Listing 7-57.

 

331 **static inline void \_\_tlb_reset_range**(**struct** mmu_gather \*tlb) 332 {

333 **if** (tlb-\>fullmm) { 334 tlb-\>start = tlb-\>end = ~0; 335 } **else** {

336 tlb-\>start = **TASK_SIZE**; 337 tlb-\>end = 0; 338 }

339 tlb-\>freed_tables = 0; 340 tlb-\>cleared_ptes = 0; 341 tlb-\>cleared_pmds = 0; 342 tlb-\>cleared_puds = 0; 343 tlb-\>cleared_p4ds = 0; 344 */\**

345 *\* Do not reset mmu_gather::vma\_\* fields here, we do not* 346 *\* call into tlb_start_vma() again to set them if there is an* 347 *\* intermediate flush.* 348 *\*/*

349 }

 

*Listing 7-57:* include/asm-generic/tlb.h: [*\_\_tlb_reset_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n331)

Finally, we invoke the function [inc_tlb_flush_pending()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n242) which incre-

ments the [struct mm_struct-\>tlb_flush_pending](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) atomic counter to indi-

cate that a TLB flush is pending \*. This value will be decremented via

[dec_tlb_flush_pending()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n283) once the flush operation is complete and is checked

via [mm_tlb_flush_pending()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n296) and [mm_tlb_flush_nested()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n309) for the nested case.

 

***7.1.3 VMA unmapping***

Once we establish the [struct mmu_gather](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n267) object, ready to perform TLB opera-

tions upon it we do so via [unmap_vmas()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1716):-

 

1698 */\*\**

1699 *\* unmap_vmas - unmap a range of memory covered by a list of vma's* 1700 *\* @tlb: address of the caller's struct mmu_gather* 1701 *\* @vma: the starting vma* 1702 *\* @start_addr: virtual address at which to start unmapping*

 

\*. One of the primary place where this value is utilised is in the x86-64 specific [pte_accessible()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n747)

when determining whether an unmapped entry used in [ptep_clear_flush()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/pgtable-generic.c?h=v6.0#n91)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/pgtable-generic.c?h=v6.0#n91) This was

introduced to avoid a data race with a concurrent NUMA balance, added in commit

[20841405940e7: mm: fix TLB flush race between migration, and change_protection_range.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=20841405940e7)

 



 

1703 *\* @end_addr: virtual address at which to end unmapping* 1704 *\**

1705 *\* Unmap all pages in the vma list.* 1706 *\**

1707 *\* Only addresses between \`start' and \`end' will be unmapped.* 1708 *\**

1709 *\* The VMA list must be sorted in ascending virtual address order.* 1710 *\**

1711 *\* unmap_vmas() assumes that the caller will flush the whole unmapped address*

1712 *\* range after unmap_vmas() returns. So the only responsibility here is to*

1713 *\* ensure that any thus-far unmapped pages are flushed before unmap_vmas()*

1714 *\* drops the lock and schedules.* 1715 *\*/*

1716 **void unmap_vmas**(**struct** mmu_gather \*tlb, 1717 **struct** vm_area_struct \*vma, **unsigned long** start_addr, 1718 **unsigned long** end_addr) 1719 {

1720 **struct** mmu_notifier_range range; 1721 **struct** zap_details details = { 1722 .zap_flags = **ZAP_FLAG_DROP_MARKER**, 1723 */\* Careful - we need to zap private pages too! \*/* 1724 .even_cows = **true**, 1725 };

1726

1727 **mmu_notifier_range_init**(&range, **MMU_NOTIFY_UNMAP**, 0, vma, vma-\>vm_mm, 1728 start_addr, end_addr); 1729 **mmu_notifier_invalidate_range_start**(&range); 1730 **for** ( ; vma && vma-\>vm_start \< end_addr; vma = vma-\>vm_next) 1731 **unmap_single_vma**(tlb, vma, start_addr, end_addr, &details); 1732 **mmu_notifier_invalidate_range_end**(&range); 1733 }

 

*Listing 7-58:* mm/memory.c: [*unmap_vmas()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1716)

The [MMU notifier](https://kernel.org/doc/html/v6.0/mm/mmu_notifier.html) logic is out of scope, however briefly this provides a

means by which interested parties can be notified of key memory manage-ment events used by, for example, virtualisation in order to manage memory for guests.

Other than this, we establish a [struct zap_details](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1347) state to be used when

zapping the address range. Zapping pages in an address range removes their

page table entries, decrements the underlying [struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256)-\>\_mapcount and performs related cleanup.

The [ZAP_FLAG_DROP_MARKER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n3395) flag is userfaultfd-specific and thus out of scope

for the book. We additionally set the even_cows option as we are performing an unqualified unmapping in this instance.

Note that the input vma parameter is simply the first VMA in the range

which we iterate through, passing each to [unmap_single_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1652) (eliding out of

scope huge page and uprobe handling) as shown in Listing 7-59.

 



 

1652 **static void unmap_single_vma**(**struct** mmu_gather \*tlb, 1653 **struct** vm_area_struct \*vma, **unsigned long** start_addr, 1654 **unsigned long** end_addr, 1655 **struct** zap_details \*details) 1656 {

1657 **unsigned long** start = **max**(vma-\>vm_start, start_addr); 1658 **unsigned long** end; 1659

1660 **if** (start \>= vma-\>vm_end) 1661 **return**;

1662 end = **min**(vma-\>vm_end, end_addr); 1663 **if** (end \<= vma-\>vm_start) 1664 **return**;

. . .

1669 **if** (**unlikely**(vma-\>vm_flags & **VM_PFNMAP**)) 1670 **untrack_pfn**(vma, 0, 0); 1671

1672 **if** (start != end) {

. . .

1694 **unmap_page_range**(tlb, vma, start, end, details); 1695 }

1696 }

 

*Listing 7-59:* mm/memory.c: [*unmap_single_vma()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1652)

 

The [untrack_pfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pat/memtype.c?h=v6.0#n1094) handling for PFN mappings is architecture-specific

and out of scope for the book. Otherwise, after clamping start and end

to be within the current VMA the per-VMA unmapping is forwarded to

[unmap_page_range() , ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1631)which zaps the page rage in the specified vma.

 

***7.1.4 Zapping memory ranges***

Examining [unmap_page_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1631):-

 

1631 **void unmap_page_range**(**struct** mmu_gather \*tlb, 1632 **struct** vm_area_struct \*vma, 1633 **unsigned long** addr, **unsigned long** end, 1634 **struct** zap_details \*details) 1635 {

1636 **pgd_t** \*pgd;

1637 **unsigned long** next; 1638

1639 **BUG_ON**(addr \>= end); 1640 **tlb_start_vma**(tlb, vma); 1641 pgd = **pgd_offset**(vma-\>vm_mm, addr); 1642 **do** {

1643 next = **pgd_addr_end**(addr, end);

 



 

1644 **if** (**pgd_none_or_clear_bad**(pgd)) 1645 **continue**; 1646 next = **zap_p4d_range**(tlb, vma, pgd, addr, next, details); 1647 } **while** (pgd++, addr = next, addr != end); 1648 **tlb_end_vma**(tlb, vma); 1649 }

 

*Listing 7-60:* mm/memory.c: [*unmap_page_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1631)

 

This follows the typical page table walking pattern – obtaining a pointer

to the PGD entry mapping addr via [pgd_offset()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n133)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n133) before finding the next PGD

entry via [pgd_addr_end()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n793).

It differs a little in that it uses [pgd_none_or_clear_bad()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n840) which checks

whether the PGD entry is empty via [pgd_none()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n945)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n945) whether it is not as expected

via [pgd_bad()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n932) and in this instance clearing the entry. This makes sense in the instance of clearing entries, as given the entry is corrupted and we intend to clear at least part of the range it represents the best means of fixing it is to at least make it consistent in the portion whose desired state we know.

The next level in the page table hierarchy is handled by [zap_p4d_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1612)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1612)

which we shall return to shortly.

In relation to the MMU gather logic, we can see here in practice two key

functions – [tlb_start_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n489) and [tlb_end_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n500)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n500)

These indicate that a TLB flush operation is about to begin and about to

finish, respectively. Examining [tlb_start_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n489) as shown in Listing 7-61.

 

484 */\**

485 *\* In the case of tlb vma handling, we can optimise these away in the* 486 *\* case where we're doing a full MM flush. When we're doing a munmap,* 487 *\* the vmas are adjusted to only cover the region to be torn down.* 488 *\*/*

489 **static inline void tlb_start_vma**(**struct** mmu_gather \*tlb, **struct** vm_area_struct

\*vma)

490 {

491 **if** (tlb-\>fullmm)

492 **return**;

493

494 **tlb_update_vma_flags**(tlb, vma); 495 **\#ifndef CONFIG_MMU_GATHER_NO_FLUSH_CACHE** 496 **flush_cache_range**(vma, vma-\>vm_start, vma-\>vm_end); 497 **\#endif**

498 }

 

*Listing 7-61:* include/asm-generic/tlb.h: [*tlb_start_vma()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n489)

 

In the case that the fullmm flag has been specified, we are in any case per-

forming this operation over the entire process address space and thus indi-vidual VMAs need not be considered and so in that case the function simply

exits. Of course, in the context of the [unmap_region()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2612) operation, this will not be set.

 



 

The [flush_cache_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/cacheflush.h?h=v6.0#n33) function is called to ensure the TLB cache for

the VMA range is consistent for those architectures which require manual

cache maintenance operations, the focused upon architecture x86-64 does

not require this.

In any case, [tlb_update_vma_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n398) is called which updates state in the

[struct mmu_gather](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n267) object according to reflect that of the VMA as shown in

Listing 7-62.

 

397 **static inline void**

398 **tlb_update_vma_flags**(**struct** mmu_gather \*tlb, **struct** vm_area_struct \*vma) 399 {

400 */\**

401 *\* flush_tlb_range() implementations that look at VM_HUGETLB (tile,*

402 *\* mips-4k) flush only large pages.* 403 *\**

404 *\* flush_tlb_range() implementations that flush I-TLB also flush D-TLB*

405 *\* (tile, xtensa, arm), so it's ok to just add VM_EXEC to an existing*

406 *\* range.*

407 *\**

408 *\* We rely on tlb_end_vma() to issue a flush, such that when we reset*

409 *\* these values the batch is empty.* 410 *\*/*

411 tlb-\>vma_huge = **is_vm_hugetlb_page**(vma); 412 tlb-\>vma_exec = !!(vma-\>vm_flags & **VM_EXEC**); 413 tlb-\>vma_pfn = !!(vma-\>vm_flags & (**VM_PFNMAP**\|**VM_MIXEDMAP**)); 414 }

 

*Listing 7-62:* include/asm-generic/tlb.h: [*tlb_update_vma_flags()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n398)

 

In order to keep the order of this analysis in line with the order in which

steps actually occur in the kernel, we shall return to [tlb_end_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n500) at the point

at which it would be invoked in a zap operation.

Returning to our traversal of the page tables as shown in Listing 7-63.

 

1612 **static inline unsigned long zap_p4d_range**(**struct** mmu_gather \*tlb, 1613 **struct** vm_area_struct \*vma, **pgd_t** \*pgd, 1614 **unsigned long** addr, **unsigned long** end, 1615 **struct** zap_details \*details) 1616 {

1617 **p4d_t** \*p4d;

1618 **unsigned long** next; 1619

1620 p4d = **p4d_offset**(pgd, addr); 1621 **do** {

1622 next = **p4d_addr_end**(addr, end); 1623 **if** (**p4d_none_or_clear_bad**(p4d)) 1624 **continue**; 1625 next = **zap_pud_range**(tlb, vma, p4d, addr, next, details); 1626 } **while** (p4d++, addr = next, addr != end);

 



 

1627

1628 **return** addr;

1629 }

 

*Listing 7-63:* mm/memory.c: [*zap_p4d_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1612)

 

This mirrors [unmap_page_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1631) (see listing 7-60) except referenc-

ing the P4D equivalent functions – [p4d_offset()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n925), [p4d_addr_end()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n799) and

[p4d_none_or_clear_bad()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n851).

Examining the PUD equivalent (eliding out of scope huge page and de-

vice mapping handling) as shown in Listing 7-64.

 

1583 **static inline unsigned long zap_pud_range**(**struct** mmu_gather \*tlb, 1584 **struct** vm_area_struct \*vma, **p4d_t** \*p4d, 1585 **unsigned long** addr, **unsigned long** end, 1586 **struct** zap_details \*details) 1587 {

1588 **pud_t** \*pud;

1589 **unsigned long** next; 1590

1591 pud = **pud_offset**(p4d, addr); 1592 **do** {

1593 next = **pud_addr_end**(addr, end);

. . .

1602 **if** (**pud_none_or_clear_bad**(pud)) 1603 **continue**; 1604 next = **zap_pmd_range**(tlb, vma, pud, addr, next, details);

. . .

1607 } **while** (pud++, addr = next, addr != end); 1608

1609 **return** addr;

1610 }

 

*Listing 7-64:* mm/memory.c: [*zap_pud_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1583)

 

This resembles the two levels above, except referencing the PUD equiva-

lent functions – [pud_offset()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n117)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n117) [pud_addr_end()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n806) and [pud_none_or_clear_bad()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n862).

Examining the PMD equivalent (eliding out of scope swap, huge page

and device mapping handling) as shown in Listing 7-65.

 

1537 **static inline unsigned long zap_pmd_range**(**struct** mmu_gather \*tlb, 1538 **struct** vm_area_struct \*vma, **pud_t** \*pud, 1539 **unsigned long** addr, **unsigned long** end, 1540 **struct** zap_details \*details) 1541 {

1542 **pmd_t** \*pmd;

1543 **unsigned long** next; 1544

1545 pmd = **pmd_offset**(pud, addr); 1546 **do** {

 



 

1547 next = **pmd_addr_end**(addr, end);

. . .

1566 */\**

1567 *\* Here there can be other concurrent MADV_DONTNEED or* 1568 *\* trans huge page faults running, and if the pmd is* 1569 *\* none or trans huge it can change under us. This is* 1570 *\* because MADV_DONTNEED holds the mmap_lock in read* 1571 *\* mode.*

1572 *\*/*

1573 **if** (**pmd_none_or_trans_huge_or_clear_bad**(pmd)) 1574 **goto** next; 1575 next = **zap_pte_range**(tlb, vma, pmd, addr, next, details); 1576 next:

. . .

1578 } **while** (pmd++, addr = next, addr != end); 1579

1580 **return** addr;

1581 }

 

*Listing 7-65:* mm/memory.c: [*zap_pmd_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1537)

 

This maintains much of the logic as seen previously, differing in that

[pmd_none_or_trans_huge_or_clear_bad()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n1348) incorporates huge page logic, out of

scope for this section. Otherwise the [pmd_offset()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n109) and [pmd_addr_end()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n813) func-

tions follow the established pattern.

Finally we reach the key function which performs the operation,

[zap_pte_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1402) (eliding out of scope swap, migration, userfaultfd and hard-

ware poisioning logic) as shown in Listing 7-66.

 

1402 **static unsigned long zap_pte_range**(**struct** mmu_gather \*tlb, 1403 **struct** vm_area_struct \*vma, **pmd_t** \*pmd, 1404 **unsigned long** addr, **unsigned long** end, 1405 **struct** zap_details \*details) 1406 {

1407 **struct** mm_struct \*mm = tlb-\>mm; 1408 **int** force_flush = 0; 1409 **int** rss\[**NR_MM_COUNTERS**\]; 1410 **spinlock_t** \*ptl;

1411 **pte_t** \*start_pte; 1412 **pte_t** \*pte;

1413 swp_entry_t entry; 1414

1415 **tlb_change_page_size**(tlb, **PAGE_SIZE**); 1416 **again**:

1417 **init_rss_vec**(rss); 1418 start_pte = **pte_offset_map_lock**(mm, pmd, addr, &ptl); 1419 pte = start_pte;

1420 **flush_tlb_batched_pending**(mm); 1421 **arch_enter_lazy_mmu_mode**();

 



 

*Listing 7-66:* mm/memory.c: [*zap_pte_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1402) *preface*

 

We start by setting the page size to [PAGE_SIZE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_types.h?h=v6.0#n11) via [tlb_change_page_size()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n452)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n452)

which is relevant only to huge page handling.

The rss array is zeroed via [init_rss_vec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n496) and the PTE entry as-

sociated with the beginning address addr is assigned to start_pte via

[pte_offset_map_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2302) while also acquiring the PTE lock. This is also assigned to pte.

Finally two interesting functions are called here –

[arch_enter_lazy_mmu_mode()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n1011) which is relevant only to x86 paravirtualisa-tion and the powerpc and sparc architectures (and thus out of scope), and

[flush_tlb_batched_pending()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n721) as shown in Listing 7-67.

 

706 */\**

707 *\* Reclaim unmaps pages under the PTL but do not flush the TLB prior to* 708 *\* releasing the PTL if TLB flushes are batched. It's possible for a parallel*

709 *\* operation such as mprotect or munmap to race between reclaim unmapping*

710 *\* the page and flushing the page. If this race occurs, it potentially allows*

711 *\* access to data via a stale TLB entry. Tracking all mm's that have TLB* 712 *\* batching in flight would be expensive during reclaim so instead track* 713 *\* whether TLB batching occurred in the past and if so then do a flush here*

714 *\* if required. This will cost one additional flush per reclaim cycle paid*

715 *\* by the first operation at risk such as mprotect and mumap.* 716 *\**

717 *\* This must be called under the PTL so that an access to tlb_flush_batched*

718 *\* that is potentially a "reclaim vs mprotect/munmap/etc" race will*

*synchronise*

719 *\* via the PTL.*

720 *\*/*

721 **void flush_tlb_batched_pending**(**struct** mm_struct \*mm) 722 {

723 **int** batch = **atomic_read**(&mm-\>tlb_flush_batched); 724 **int** pending = batch & **TLB_FLUSH_BATCH_PENDING_MASK**; 725 **int** flushed = batch \>\> **TLB_FLUSH_BATCH_FLUSHED_SHIFT**; 726

727 **if** (pending != flushed) { 728 **flush_tlb_mm**(mm); 729 */\**

730 *\* If the new TLB flushing is pending during flushing, leave*

731 *\* mm-\>tlb_flush_batched as is, to avoid losing flushing.*

732 *\*/*

733 **atomic_cmpxchg**(&mm-\>tlb_flush_batched, batch, 734 pending \| (pending \<\<

**TLB_FLUSH_BATCH_FLUSHED_SHIFT**));

735 }

736 }

 



 

*Listing 7-67:* mm/rmap.c: [*flush_tlb_batched_pending()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n721)

 

This function, as its name implies, flushes any pending batched TLB op-

erations. This is tracked via the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)-\>tlb_flush_batched field.

This field is used to track pending and flushed TLB operations used

during reclaim via the reverse mapping in [try_to_unmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1812)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1812) We shall explore

this in detail in the reclaim chapter. The actual flush is performed via

[flush_tlb_mm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/tlbflush.h?h=v6.0#n223) which performs a TLB flush across the entire process ad-

dress space. This ultimately defers the operation to the architecture-specific

[flush_tlb_mm_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n981) which we will examine shortly.

Returning to [zap_pte_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1402) we enter its main loop (eliding out of scope

userfaultfd, swap, migration and hardware poison logic) as shown in Listing

**??**.

 

1422 **do** {

1423 **pte_t** ptent = \*pte; 1424 **struct** page \*page; 1425

1426 **if** (**pte_none**(ptent)) 1427 **continue**; 1428

1429 **if** (**need_resched**()) 1430 **break**; 1431

1432 **if** (**pte_present**(ptent)) { 1433 page = **vm_normal_page**(vma, addr, ptent); 1434 **if** (**unlikely**(!**should_zap_page**(details, page))) 1435 **continue**; 1436 ptent = **ptep_get_and_clear_full**(mm, addr, pte, 1437 tlb-\>fullmm); 1438 **tlb_remove_tlb_entry**(tlb, pte, addr);

. . .

1441 **if** (**unlikely**(!page)) 1442 **continue**; 1443

1444 **if** (!**PageAnon**(page)) { 1445 **if** (**pte_dirty**(ptent)) { 1446 force_flush = 1; 1447 **set_page_dirty**(page); 1448 } 1449 **if** (**pte_young**(ptent) && 1450 **likely**(!(vma-\>vm_flags & **VM_SEQ_READ**))) 1451 **mark_page_accessed**(page); 1452 } 1453 rss\[**mm_counter**(page)\]--; 1454 **page_remove_rmap**(page, vma, **false**); 1455 **if** (**unlikely**(**page_mapcount**(page) \< 0))

 



 

1456 **print_bad_pte**(vma, addr, ptent, page); 1457 **if** (**unlikely**(**\_\_tlb_remove_page**(tlb, page))) { 1458 force_flush = 1; 1459 addr += **PAGE_SIZE**; 1460 **break**; 1461 } 1462 **continue**; 1463 }

. . .

1508 } **while** (pte++, addr += **PAGE_SIZE**, addr != end);

 

*Listing 7-68:* mm/memory.c: [*zap_pte_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1402) *main loop*

 

The top-level logic here checks whether the PTE entry is empty via

[pte_none()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n723) or non-present via [pte_present()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n734) – if either of these are the case

then no action need be taken. This logic additionally calls [need_resched()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n2206) to determine whether rescheduling would be appropriate (breaking out of the loop to do so) as the unmapping can be a lengthily operation.

The page associated with the mapping is obtained via [vm_normal_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n612)

(see section 6.12 for details on this and special mappings for which will re-turn NULL).

We next call [should_zap_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1365) to determine whether the [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) ob-

ject can be zapped as shown in Listing 7-69.

 

1364 */\* Decides whether we should zap this page with the page pointer specified \*/* 1365 **static inline bool should_zap_page**(**struct** zap_details \*details, **struct** page \*

page)

1366 {

1367 */\* If we can make a decision without \*page.. \*/* 1368 **if** (**should_zap_cows**(details)) 1369 **return true**; 1370

1371 */\* E.g. the caller passes NULL for the case of a zero page \*/* 1372 **if** (!page)

1373 **return true**; 1374

1375 */\* Otherwise we should only zap non-anon pages \*/* 1376 **return** !**PageAnon**(page); 1377 }

 

*Listing 7-69:* mm/memory.c: [*should_zap_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1365)

 

This primarily determines whether this is a Copy On Write (i.e. anony-

mous) page which, unless the [struct zap_details-\>even_cows](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1347) flag is set

(checked by [should_zap_cows()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1354) – note that if no details are provided this de-faults to doing so), is not performed.

The next step is subtle – [ptep_get_and_clear_full()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n1057) re-retrieves the PTE

and clears the PTE entry. This is important as, prior to the TLB operation, we must ensure that page table entries do not point to the page whose entry

 



 

we are clearing, otherwise the TLB could immediately be repopulated with

the stale entry.

The TLB entry is marked removed via [tlb_remove_tlb_entry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n563) as shown in

Listing 7-70.

 

556 */\*\**

557 *\* tlb_remove_tlb_entry - remember a pte unmapping for later tlb invalidation.*

558 *\**

559 *\* Record the fact that pte's were really unmapped by updating the range,* 560 *\* so we can later optimise away the tlb invalidate.* *This helps when* 561 *\* userspace is unmapping already-unmapped pages, which happens quite a lot.*

562 *\*/*

563 **\#define tlb_remove_tlb_entry**(tlb, ptep, address) \\ 564 **do** { \\ 565 **tlb_flush_pte_range**(tlb, address, **PAGE_SIZE**); \\ 566 **\_\_tlb_remove_tlb_entry**(tlb, ptep, address); \\ 567 } **while** (0)

 

*Listing 7-70:* include/asm-generic/tlb.h: [*tlb_remove_tlb_entry()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n563)

 

The [\_\_tlb_remove_tlb_entry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n553) function is used for architectures which re-

quire manual TLB cache maintenance to indicate that an entry is to be re-

moved, however this is a no-op for x86-64.

Examining [tlb_flush_pte_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n524) as shown in Listing 7-71.

 

520 */\**

521 *\* tlb_flush\_{pte\|pmd\|pud\|p4d}\_range() adjust the tlb-\>start and tlb-\>end,*

522 *\* and set corresponding cleared\_\*.* 523 *\*/*

524 **static inline void tlb_flush_pte_range**(**struct** mmu_gather \*tlb, 525 **unsigned long** address, **unsigned long** size

)

526 {

527 **\_\_tlb_adjust_range**(tlb, address, size); 528 tlb-\>cleared_ptes = 1; 529 }

 

*Listing 7-71:* include/asm-generic/tlb.h: [*tlb_flush_pte_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n524)

 

This marks that PTEs have been cleared and updates the

[struct mmu_gather](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n267) range parameters via [\_\_tlb_adjust_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n323) as shown in List-

ing 7-72.

 

323 **static inline void \_\_tlb_adjust_range**(**struct** mmu_gather \*tlb, 324 **unsigned long** address, 325 **unsigned int** range_size) 326 {

327 tlb-\>start = **min**(tlb-\>start, address); 328 tlb-\>end = **max**(tlb-\>end, address + range_size); 329 }

 



 

*Listing 7-72:* include/asm-generic/tlb.h: [*\_\_tlb_adjust_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n323)

 

As we walk through each PTE entry we adjust the start and end values

in order that at the end of the walk these are equal to a range that spans all mappings to be removed (and perhaps some gaps).

At this point we check to see whether we are dealing with a special map-

ping – i.e. one for which a [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) does not exist (again see section 6.12 for more details on this), if so we have no further action to perform. Other-wise we process the page object:-

 

• If the page is not anonymous (i.e. not [PageAnon()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n661)[):-](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n661)

**–** Take special care to ensure the underlying folio is correctly marked

dirty so dirty pages are guaranteed to be written back correctly, via

[set_page_dirty(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n60)ultimately invoking [folio_mark_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2730) (see the page cache chapter for more details on this).

The force_flush flag is set to ensure that a TLB flush occurs immedi-ately under the PTE lock rather than being batched up, as otherwise a racing write back could try to flush the TLB, find an empty PTE entry and not correctly wait for stale TLB entries to be invalidated before starting write back.

**–** Equally, if the page has been recently accessed as indicated by the

[\_PAGE_ACCESSED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n46) page table flag as checked by [pte_young()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n132)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n132) and the

[VM_SEQ_READ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n286) flag has not been set on the VMA, indicating that this page may indeed be accessed again soon, albeit not from this map-

ping, then the underlying folio is updated via [mark_page_accessed()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n48)

(which ultimately calls [folio_mark_accessed()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n441)[).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n441)

 

After this the rss field containing statistics for various different types of

pages is updated, using [mm_counter()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2002) to identify which statistic to decrement.

The page is marked for removal from the reverse mapping via

[page_remove_rmap() , ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1429)which is very important for tearing down the link between the virtual mapping and thus PTE now being unmapped and the underlying page (eliding out of scope cgroup and huge page logic) as shown in Listing

7-73.

 

1421 */\*\**

1422 *\* page_remove_rmap - take down pte mapping from a page* 1423 *\* @page:* *page to remove mapping from* 1424 *\* @vma:* *the vm area from which the mapping is removed* 1425 *\* @compound:* *uncharge the page as compound or small page* 1426 *\**

1427 *\* The caller needs to hold the pte lock.* 1428 *\*/*

1429 **void page_remove_rmap**(**struct** page \*page, 1430 **struct** vm_area_struct \*vma, **bool** compound) 1431 {

. . .

1434 **if** (!**PageAnon**(page)) {

 



 

1435 **page_remove_file_rmap**(page, compound); 1436 **goto out**; 1437 }

. . .

1444 */\* page still mapped by someone else? \*/* 1445 **if** (!**atomic_add_negative**(-1, &page-\>\_mapcount)) 1446 **goto out**; 1447

1448 */\**

1449 *\* We use the irq-unsafe \_\_{inc\|mod}\_zone_page_stat because* 1450 *\* these counters are not modified in interrupt context, and* 1451 *\* pte lock(a spinlock) is held, which implies preemption disabled.*

1452 *\*/*

1453 **\_\_dec_lruvec_page_state**(page, **NR_ANON_MAPPED**);

. . .

1458 */\**

1459 *\* It would be tidy to reset the PageAnon mapping here,* 1460 *\* but that might overwrite a racing page_add_anon_rmap* 1461 *\* which increments mapcount after us but sets mapping* 1462 *\* before us: so leave the reset to free_unref_page,* 1463 *\* and remember that it's only reliable while mapped.* 1464 *\* Leaving it set also helps swapoff to reinstate ptes* 1465 *\* faster for those pages still in swapcache.* 1466 *\*/*

1467 **out**:

. . .

1470 **munlock_vma_page**(page, vma, compound); 1471 }

 

*Listing 7-73:* mm/rmap.c: [*page_remove_rmap()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1429)

 

It’s important to note that in actual fact this does not clear the mapped field

at this stage. Note that the reverse mapping by its nature does not provide a

data structure connecting VMAs to pages (this must be determined by walk-

ing page tables), but rather folios are linked to either page cache entries or a

[struct anon_vma](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/rmap.h?h=v6.0#n31) object via their mapping fields.

The key thing here is that the [struct folio-\>\_mapcount](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) field is decre-

mented. Importantly, this field is initialised to-1 when first allocated,

such that 0 indicates it is mapped by a single mapping, 1 by 2, etc., so this

[atomic_add_negative()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/atomic/atomic-instrumented.h?h=v6.0#n588) invocation, which subtracts 1 and returns true if the

number is now negative. If not, then the page is mapped by somebody else.

If this is not the case, we update statistics and unlock the page via

[munlock_vma_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n534) if it was previously locked via [mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html)[.](https://man7.org/linux/man-pages/man2/mlock.2.html)

If the page was not in fact an anonymous one, [page_remove_file_rmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1342) is

instead invoked (eliding out of scope huge page logic) as shown in Listing

7-74.

 

1342 **static void page_remove_file_rmap**(**struct** page \*page, **bool** compound) 1343 {

 



 

1344 **int** i, nr = 0;

. . .

1372 **if** (**atomic_add_negative**(-1, &page-\>\_mapcount)) 1373 nr++;

. . .

1376 **if** (nr)

1377 **\_\_mod_lruvec_page_state**(page, **NR_FILE_MAPPED**, -nr); 1378 }

 

*Listing 7-74:* mm/rmap.c: [*page_remove_file_rmap()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1342)

Which effectively does the same thing.

Returning to [zap_pte_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1402) (listing 7-68), after checking that the map-

count is valid (note that [page_mapcount()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n825) returns the \_mapcount field incre-

mented by 1), [\_\_tlb_remove_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n438) is invoked to action the removal of the page. If this fails then a full flush is forced and the loop is aborted.

The [\_\_tlb_remove_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n438) function invokes [\_\_tlb_remove_page_size()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n79) in turn,

passing [PAGE_SIZE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_types.h?h=v6.0#n11) as the page_size argument.

This adds the page to the active batch [struct mmu_gather_batch](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n241) object as

shown in Listing 7-75.

 

79 **bool \_\_tlb_remove_page_size**(**struct** mmu_gather \*tlb, **struct** page \*page, **int**

page_size)

80 {

81 **struct** mmu_gather_batch \*batch; 82

83 **VM_BUG_ON**(!tlb-\>end); 84

85 **\#ifdef CONFIG_MMU_GATHER_PAGE_SIZE** 86 **VM_WARN_ON**(tlb-\>page_size != page_size); 87 **\#endif**

88

89 batch = tlb-\>active; 90 */\**

91 *\* Add the page and check if we are full. If so* 92 *\* force a flush.* 93 *\*/*

94 batch-\>pages\[batch-\>nr++\] = page; 95 **if** (batch-\>nr == batch-\>max) { 96 **if** (!**tlb_next_batch**(tlb)) 97 **return true**; 98 batch = tlb-\>active; 99 }

100 **VM_BUG_ON_PAGE**(batch-\>nr \> batch-\>max, page); 101

102 **return false**;

103 }

 

*Listing 7-75:* mm/mmu_gather.c: [*\_\_tlb_remove_page_size()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n79)

 



 

We simply add the page to the active batch’s pages array, then checks to

see whether the batch is full, if so [tlb_next_batch()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n17) is invoked to obtain the

next one, if it can, indicating whether it succeeded or not.

Examining [tlb_next_batch()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n17) as shown in Listing 7-76.

 

17 **static bool tlb_next_batch**(**struct** mmu_gather \*tlb)

18 {

19 **struct** mmu_gather_batch \*batch;

20

21 batch = tlb-\>active;

22 **if** (batch-\>next) {

23 tlb-\>active = batch-\>next;

24 **return true**;

25 }

26

27 **if** (tlb-\>batch_count == **MAX_GATHER_BATCH_COUNT**)

28 **return false**;

29

30 batch = (**void** \*)**\_\_get_free_pages**(**GFP_NOWAIT** \| **\_\_GFP_NOWARN**, 0);

31 **if** (!batch)

32 **return false**;

33

34 tlb-\>batch_count++;

35 batch-\>next = **NULL**;

36 batch-\>nr = 0;

37 batch-\>max = **MAX_GATHER_BATCH**;

38

39 tlb-\>active-\>next = batch;

40 tlb-\>active = batch;

41

42 **return true**;

43 }

 

*Listing 7-76:* mm/mmu_gather.c: [*tlb_next_batch()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n17)

 

This checks whether the batch already has a next batch object available,

activating this, whether the [struct mmu_gather](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n267) object’s batch_count exceeds

[MAX_GATHER_BATCH_COUNT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n257) which is the number of batches containing 10,000

pages (19 for x86-64).

The maximum number of pages in each batch is determined by the

size remaining in a page allocated to store a batch and the array of pages,

[MAX_GATHER_BATCH, ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n248)which on x86-64 is equal to 509.

Returning to [zap_pte_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1402) (listing 7-68) for the last time, where the

[zap_pte_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1402) operation is finalised as shown in Listing 7-77.

 

1510 **add_mm_rss_vec**(mm, rss); 1511 **arch_leave_lazy_mmu_mode**(); 1512

1513 */\* Do the actual TLB flush before dropping ptl \*/*

 



 

1514 **if** (force_flush)

1515 **tlb_flush_mmu_tlbonly**(tlb); 1516 **pte_unmap_unlock**(start_pte, ptl); 1517

1518 */\**

1519 *\* If we forced a TLB flush (either due to running out of* 1520 *\* batch buffers or because we needed to flush dirty TLB* 1521 *\* entries before releasing the ptl), free the batched* 1522 *\* memory too. Restart if we didn't do everything.* 1523 *\*/*

1524 **if** (force_flush) { 1525 force_flush = 0; 1526 **tlb_flush_mmu**(tlb); 1527 }

1528

1529 **if** (addr != end) { 1530 **cond_resched**(); 1531 **goto again**; 1532 }

1533

1534 **return** addr;

1535 }

 

*Listing 7-77:* mm/memory.c: [*zap_pte_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1402) *finalisation*

 

Firstly, this registers RSS statistics changes via [add_mm_rss_vec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n501)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n501) exits

architecture-specific lazy MMU mode via [arch_leave_lazy_mmu_mode()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pgtable.h?h=v6.0#n1012) (only relevant for SPARC).

If we must force the flush, [tlb_flush_mmu_tlbonly()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n416) is called (we return

to this in section 7.1.6 below) is called prior to releasing the PTE lock via

[pte_unmap_unlock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2311) to avoid a race with a write back (discussed above). Note this only flushes the range, it does not free underlying pages.

Finally, after the lock is released, a flush is performed and pages are freed

via [tlb_flush_mmu()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n259).

If we had to break out of the loop, we conditionally reschedule in case

any more urgent task need be performed via [cond_resched()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n2082) and loop to the again label.

Returning to [unmap_page_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1631), this invokes [tlb_end_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n500) after each

VMA has been flushed as shown in Listing 7-78.

 

500 **static inline void tlb_end_vma**(**struct** mmu_gather \*tlb, **struct** vm_area_struct \*

vma)

501 {

502 **if** (tlb-\>fullmm)

503 **return**;

504

505 */\**

506 *\* VM_PFNMAP is more fragile because the core mm will not track the*

 



 

507 *\* page mapcount -- there might not be page-frames for these PFNs*

*after*

508 *\* all. Force flush TLBs for such ranges to avoid munmap() vs* 509 *\* unmap_mapping_range() races.* 510 *\*/*

511 **if** (tlb-\>vma_pfn \|\| !**IS_ENABLED**(**CONFIG_MMU_GATHER_MERGE_VMAS**)) { 512 */\**

513 *\* Do a TLB flush and reset the range at VMA boundaries; this*

*avoids*

514 *\* the ranges growing with the unused space between*

*consecutive VMAs.*

515 *\*/*

516 **tlb_flush_mmu_tlbonly**(tlb); 517 }

518 }

 

*Listing 7-78:* include/asm-generic/tlb.h: [*tlb_end_vma()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n500)

 

This takes special care to avoid races for PFN only mappings (see section

6.12 for more on this).

Finally, [unmap_region()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2612) invokes [free_pgtables()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n405) to clear page tables (see

section 7.1.5 below) and then [tlb_finish_mmu()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n325) to finish the batched TLB op-

eration as shown in Listing 7-79.

 

318 */\*\**

319 *\* tlb_finish_mmu - finish an mmu_gather structure* 320 *\* @tlb: the mmu_gather structure to finish* 321 *\**

322 *\* Called at the end of the shootdown operation to free up any resources that*

323 *\* were required.*

324 *\*/*

325 **void tlb_finish_mmu**(**struct** mmu_gather \*tlb) 326 {

327 */\**

328 *\* If there are parallel threads are doing PTE changes on same range*

329 *\* under non-exclusive lock (e.g., mmap_lock read-side) but defer TLB*

330 *\* flush by batching, one thread may end up seeing inconsistent PTEs*

331 *\* and result in having stale TLB entries. So flush TLB forcefully*

332 *\* if we detect parallel PTE batching threads.* 333 *\**

334 *\* However, some syscalls, e.g. munmap(), may free page tables, this*

335 *\* needs force flush everything in the given range. Otherwise this*

336 *\* may result in having stale TLB entries for some architectures,* 337 *\* e.g. aarch64, that could specify flush what level TLB.* 338 *\*/*

339 **if** (**mm_tlb_flush_nested**(tlb-\>mm)) { 340 */\**

341 *\* The aarch64 yields better performance with fullmm by* 342 *\* avoiding multiple CPUs spamming TLBI messages at the*

 



 

343 *\* same time.* 344 *\**

345 *\* On x86 non-fullmm doesn't yield significant difference*

346 *\* against fullmm.* 347 *\*/*

348 tlb-\>fullmm = 1; 349 **\_\_tlb_reset_range**(tlb); 350 tlb-\>freed_tables = 1; 351 }

352

353 **tlb_flush_mmu**(tlb); 354

355 **\#ifndef CONFIG_MMU_GATHER_NO_GATHER** 356 **tlb_batch_list_free**(tlb); 357 **\#endif**

358 **dec_tlb_flush_pending**(tlb-\>mm); 359 }

 

*Listing 7-79:* mm/mmu_gather.c: [*tlb_finish_mmu()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n325)

 

This checks whether another TLB flush has been initiated by calling

the predicate function [mm_tlb_flush_nested()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n309) (which simply checks whether

[struct mm_struct-\>tlb_flush_pending](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) is greater than 1) in which case it switches to a flush of the entire process address space.

The actual flush and freeing of memory is performed via [tlb_flush_mmu()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n259)

which we discuss in section 7.1.6.

After this is done, the batch list is freed via [tlb_batch_list_free()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n68)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n68)

and finally the number of concurrent TLB flushes is decremented via

[dec_tlb_flush_pending()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_inline.h?h=v6.0#n283).

 

***7.1.5 Freeing page tables***

Page tables are freed via [free_pgtables()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n405) (eliding out of scope huge page logic):-

 

405 **void** free_pgtables(**struct** mmu_gather \*tlb, **struct** vm_area_struct \*vma, 406 **unsigned long** floor, **unsigned long** ceiling) 407 {

408 **while** (vma) {

409 **struct** vm_area_struct \*next = vma-\>vm_next; 410 **unsigned long** addr = vma-\>vm_start; 411

412 */\**

413 *\* Hide vma from rmap and truncate_pagecache before freeing*

414 *\* pgtables* 415 *\*/*

416 **unlink_anon_vmas**(vma); 417 **unlink_file_vma**(vma);

 



 

. . .

423 */\** 424 *\* Optimization: gather nearby vmas into one call down*

425 *\*/* 426 **while** (next && next-\>vm_start \<= vma-\>vm_end +

**PMD_SIZE**

427 && !**is_vm_hugetlb_page**(next)) { 428 vma = next; 429 next = vma-\>vm_next; 430 **unlink_anon_vmas**(vma); 431 **unlink_file_vma**(vma); 432 } 433 **free_pgd_range**(tlb, addr, vma-\>vm_end, 434 floor, next ? next-\>vm_start : ceiling);

. . .

436 vma = next; 437 }

438 }

 

*Listing 7-80:* mm/memory.c: [*free_pgtables()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n405)

 

This both removes page tables and unlinks reverse mapping via

[unlink_anon_vmas()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n395) (see section 7.0.14 for a description of this) and file map-

ping objects via [unlink_file_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n122) as shown in Listing 7-81.

 

118 */\**

119 *\* Unlink a file-based vm structure from its interval tree, to hide* 120 *\* vma from rmap and vmtruncate before freeing its page tables.* 121 *\*/*

122 **void unlink_file_vma**(**struct** vm_area_struct \*vma) 123 {

124 **struct** file \*file = vma-\>vm_file;

125

126 **if** (file) {

127 **struct** address_space \*mapping = file-\>f_mapping; 128 **i_mmap_lock_write**(mapping); 129 **\_\_remove_shared_vm_struct**(vma, file, mapping); 130 **i_mmap_unlock_write**(mapping); 131 }

132 }

 

*Listing 7-81:* mm/mmap.c: [*unlink_file_vma()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n122)

 

This removes the VMA object from the [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)’s interval tree

via [\_\_remove_shared_vm_struct()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n107) (eliding out of scope manual cache mainte-

nance logic irrelevant to x86-64) as shown in Listing 7-82.

 

104 */\**

105 *\* Requires inode-\>i_mapping-\>i_mmap_rwsem* 106 *\*/*

 



 

107 **static void \_\_remove_shared_vm_struct**(**struct** vm_area_struct \*vma, 108 **struct** file \*file, **struct** address_space \*mapping) 109 {

110 **if** (vma-\>vm_flags & **VM_SHARED**) 111 **mapping_unmap_writable**(mapping);

. . .

114 **vma_interval_tree_remove**(vma, &mapping-\>i_mmap);

. . .

116 }

 

*Listing 7-82:* mm/mmap.c: [*\_\_remove_shared_vm_struct()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n107)

 

This atomically decrements the [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)-\>i_mmap_writable

counter via [mapping_unmap_writable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n532) if the mapping is shared, to indicate that a potentially writable page cache object has been unmapped. In any case it removes the VMA from the page cache object’s interval tree.

It’s important to take a step back and to consider what we are doing here

– we are removing these reverse mapping links from all the VMAs at and beyond the one provided to the function (which is the first in the range of VMAS to unmap).

This seems as if it would affect unrelated VMAs, however the call as-

sumes implicitly that the VMAs being processed here, with vma being the first, have already been split and all VMAs in the range span only the range being freed and are not attached to the other VMAs in the process address space.

For an unmapping, [unmap_region()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2612) is called from [\_\_do_munmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2754) which per-

forms this detachment via [detach_vmas_to_be_unmapped()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n2633) (see Chapter 5 for more on memory mapping in general).

As a result, we can optimise the operation and batch the page table re-

moval and reverse mapping unlinking for each VMA.

Note that, since we have already cleared the PTE entry for each mapping,

we need not concern ourselves with this task. The granularity at which we free page tables is always at the PMD level, as each PMD entry spans an en-tire PTE directory page, e.g. on x86-64, 2 MiB of mappings. Only when we know for sure we can free such a range do we free the underlying PTE direc-tory.

We pass the PMD-level range of addresses to [free_pgd_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n343) (eliding

huge page logic) as shown in Listing 7-83.

 

340 */\**

341 *\* This function frees user-level page tables of a process.* 342 *\*/*

343 **void free_pgd_range**(**struct** mmu_gather \*tlb, 344 **unsigned long** addr, **unsigned long** end, 345 **unsigned long** floor, **unsigned long** ceiling) 346 {

347 **pgd_t** \*pgd;

348 **unsigned long** next; 349

 



 

350 */\**

351 *\* The next few lines have given us lots of grief...* 352 *\**

353 *\* Why are we testing PMD\* at this top level? Because often* 354 *\* there will be no work to do at all, and we'd prefer not to* 355 *\* go all the way down to the bottom just to discover that.* 356 *\**

357 *\* Why all these "- 1"s? Because 0 represents both the bottom* 358 *\* of the address space and the top of it (using -1 for the* 359 *\* top wouldn't help much: the masks would do the wrong thing).* 360 *\* The rule is that addr 0 and floor 0 refer to the bottom of* 361 *\* the address space, but end 0 and ceiling 0 refer to the top* 362 *\* Comparisons need to use "end - 1" and "ceiling - 1" (though* 363 *\* that end 0 case should be mythical).* 364 *\**

365 *\* Wherever addr is brought up or ceiling brought down, we must* 366 *\* be careful to reject "the opposite 0" before it confuses the* 367 *\* subsequent tests. But what about where end is brought down* 368 *\* by PMD_SIZE below? no, end can't go down to 0 there.* 369 *\**

370 *\* Whereas we round start (addr) and ceiling down, by different* 371 *\* masks at different levels, in order to test whether a table* 372 *\* now has no other vmas using it, so can be freed, we don't* 373 *\* bother to round floor or end up - the tests don't need that.* 374 *\*/*

375

376 addr &= **PMD_MASK**; 377 **if** (addr \< floor) { 378 addr += **PMD_SIZE**; 379 **if** (!addr) 380 **return**; 381 }

382 **if** (ceiling) {

383 ceiling &= **PMD_MASK**; 384 **if** (!ceiling) 385 **return**; 386 }

387 **if** (end - 1 \> ceiling - 1) 388 end -= **PMD_SIZE**; 389 **if** (addr \> end - 1) 390 **return**;

. . .

396 pgd = **pgd_offset**(tlb-\>mm, addr); 397 **do** {

398 next = **pgd_addr_end**(addr, end); 399 **if** (**pgd_none_or_clear_bad**(pgd)) 400 **continue**;

 



 

401 **free_p4d_range**(tlb, pgd, addr, next, floor, ceiling); 402 } **while** (pgd++, addr = next, addr != end); 403 }

 

*Listing 7-83:* mm/memory.c: [*free_pgd_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n343)

 

The initial operations are quite intricate as the very large comment

suggests:-

 

• We perform a test to ensure the range is valid at a PMD granularity

(which notably is the granularity at which the page table unmap oper-ations are being performed in any case) here rather than later to quickly exit no-op cases.

• We denote the bottom and top of the address range by zero, therefore

in order to perform correct comparisons, we must subtract 1 from the upper bounds, therefore all such comparisons to end and ceiling must be decremented by one.

• When adding PMD_SIZE to addr in the addr \< floor branch, we explicitly

check for overflow and return if it occurs. This would suggest addr is less than the floor but the PMD-aligned floor is at the end of the address space.

• If the ceiling, aligned to PMD size (and not 0 indicating the top of the

address space), would be equal to zero, then we do not span at least a PTE directory’s worth of mappings, and thus can’t be sure it is safe to free at the PMD level, so must abort.

• If the now PMD-aligned ceiling would exceed the end value, this means

we must round end down to keep it below ceiling. If this would result in addr no longer being in range, we exit.

 

After this, we perform a fairly typical page table walk, deferring the next

level of the operation to [free_p4d_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n307)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n307) Note that the entry of the level above is cleared at the level below, i.e. it is the P4D freeing function that will clear the PGD entry, the PUD freeing function that will clear the P4D entry etc.

 

307 **static inline void free_p4d_range**(**struct** mmu_gather \*tlb, **pgd_t** \*pgd, 308 **unsigned long** addr, **unsigned long** end, 309 **unsigned long** floor, **unsigned long** ceiling) 310 {

311 **p4d_t** \*p4d;

312 **unsigned long** next; 313 **unsigned long** start; 314

315 start = addr;

316 p4d = **p4d_offset**(pgd, addr); 317 **do** {

318 next = **p4d_addr_end**(addr, end); 319 **if** (**p4d_none_or_clear_bad**(p4d))

 



 

320 **continue**; 321 **free_pud_range**(tlb, p4d, addr, next, floor, ceiling); 322 } **while** (p4d++, addr = next, addr != end);

323

324 start &= **PGDIR_MASK**; 325 **if** (start \< floor) 326 **return**;

327 **if** (ceiling) {

328 ceiling &= **PGDIR_MASK**; 329 **if** (!ceiling) 330 **return**; 331 }

332 **if** (end - 1 \> ceiling - 1) 333 **return**;

334

335 p4d = **p4d_offset**(pgd, start); 336 **pgd_clear**(pgd);

337 **p4d_free_tlb**(tlb, p4d, start); 338 }

 

*Listing 7-84:* mm/memory.c: [*free_p4d_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n307)

 

This begins by performing page table freeing at the PUD level, before

clearing the containing PGD entry. This is achieved by obtaining the P4D

entry via [p4d_offset()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n925)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n925) clearing the PGD entry via [pgd_clear()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n77) before perform-

ing a TLB state update via [p4d_free_tlb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n657). Note this only occurs if the input

range spans a P4D.

This sets the [struct mmu_gather](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n267)-\>freed_tables flag, adjusts the range to en-

compass the entire P4D entry as well as performing architecture-specific

operations via [\_\_p4d_free_tlb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgtable.c?h=v6.0#n84) (which for x86-64 simply informs any para-

virtualised host that this has occurred).

Examining the PUD level as shown in Listing 7-85.

 

273 **static inline void free_pud_range**(**struct** mmu_gather \*tlb, **p4d_t** \*p4d, 274 **unsigned long** addr, **unsigned long** end, 275 **unsigned long** floor, **unsigned long** ceiling) 276 {

277 **pud_t** \*pud;

278 **unsigned long** next; 279 **unsigned long** start;

280

281 start = addr;

282 pud = **pud_offset**(p4d, addr); 283 **do** {

284 next = **pud_addr_end**(addr, end); 285 **if** (**pud_none_or_clear_bad**(pud)) 286 **continue**; 287 **free_pmd_range**(tlb, pud, addr, next, floor, ceiling); 288 } **while** (pud++, addr = next, addr != end);

 



 

289

290 start &= **P4D_MASK**; 291 **if** (start \< floor) 292 **return**;

293 **if** (ceiling) {

294 ceiling &= **P4D_MASK**; 295 **if** (!ceiling) 296 **return**; 297 }

298 **if** (end - 1 \> ceiling - 1) 299 **return**;

300

301 pud = **pud_offset**(p4d, start); 302 **p4d_clear**(p4d);

303 **pud_free_tlb**(tlb, pud, start); 304 **mm_dec_nr_puds**(tlb-\>mm); 305 }

 

*Listing 7-85:* mm/memory.c: [*free_pud_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n273)

 

This is almost entirely identical to the P4D level, only dif-

fering in that it invokes [mm_dec_nr_puds()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2122) which decrements the

[struct mm_struct-\>pgtables_bytes](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) field accordingly.

At the PMD level as shown in Listing 7-86.

 

239 **static inline void free_pmd_range**(**struct** mmu_gather \*tlb, **pud_t** \*pud, 240 **unsigned long** addr, **unsigned long** end, 241 **unsigned long** floor, **unsigned long** ceiling) 242 {

243 **pmd_t** \*pmd;

244 **unsigned long** next; 245 **unsigned long** start; 246

247 start = addr;

248 pmd = **pmd_offset**(pud, addr); 249 **do** {

250 next = **pmd_addr_end**(addr, end); 251 **if** (**pmd_none_or_clear_bad**(pmd)) 252 **continue**; 253 **free_pte_range**(tlb, pmd, addr); 254 } **while** (pmd++, addr = next, addr != end); 255

256 start &= **PUD_MASK**; 257 **if** (start \< floor) 258 **return**;

259 **if** (ceiling) {

260 ceiling &= **PUD_MASK**; 261 **if** (!ceiling) 262 **return**;

 



 

263 }

264 **if** (end - 1 \> ceiling - 1) 265 **return**;

266

267 pmd = **pmd_offset**(pud, start); 268 **pud_clear**(pud);

269 **pmd_free_tlb**(tlb, pmd, start); 270 **mm_dec_nr_pmds**(tlb-\>mm); 271 }

 

*Listing 7-86:* mm/memory.c: [*free_pmd_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n239)

 

This again follows the same pattern, invoking [mm_dec_nr_pmds()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2150) to update

[struct mm_struct-\>pgtables_bytes](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486).

The [\_\_pmd_free_tlb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgalloc.h?h=v6.0#n90) function differs here in that, in addition to paravir-

tualisation calls, it also ultimately invokes [\_\_\_pmd_free_tlb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgtable.c?h=v6.0#n61) which handles

some architecture-specific logic as well as invoking the PMD page table de-

structor [pgtable_pmd_page_dtor()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2390) which frees locks updates statistics and re-

moves the [PG_table](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n942) flag from the underlying folio.

Finally the PTE function as shown in Listing 7-87.

 

226 */\**

227 *\* Note: this doesn't free the actual pages themselves. That* 228 *\* has been handled earlier when unmapping all the memory regions.* 229 *\*/*

230 **static void free_pte_range**(**struct** mmu_gather \*tlb, **pmd_t** \*pmd, 231 **unsigned long** addr) 232 {

233 **pgtable_t** token = **pmd_pgtable**(\*pmd); 234 **pmd_clear**(pmd);

235 **pte_free_tlb**(tlb, token, addr); 236 **mm_dec_nr_ptes**(tlb-\>mm); 237 }

 

*Listing 7-87:* mm/memory.c: [*free_pte_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n230)

 

This is significantly less involved, as we have already established

that we clear at the PMD granularity so no checks are required for this.

[pte_free_tlb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n630) marks [struct mmu_gather](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n267)-\>freed_tables and adjusting the tlb

range as with the other levels.

It also in turn invokes [\_\_pte_free_tlb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgalloc.h?h=v6.0#n58) which invokes [\_\_\_pte_free_tlb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/pgtable.c?h=v6.0#n53) in

turn. Other than paravirtualised calls, this invokes the PTE destructor via

[pgtable_pte_page_dtor()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2295) which, as at the PMD level, frees the page table lock,

clears the folio flag and adjusts statistics.

 



 

***7.1.6 Flushing the TLB***

The TLB mechanisms already described provide us with two sets of data – a

range of virtual addresses which require their TLB cache to be invalidated\*

and an array of [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) objects that need to have their reference counter decremented and may need to be freed.

Note that the flushing logic is architecture-dependent, however for

brevity as usual we simply go ahead and examine the x86-64 case through-out.

The key function for flushing the TLB and freeing pages is

[tlb_flush_mmu()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n259) as shown in Listing 7-88.

 

259 **void tlb_flush_mmu**(**struct** mmu_gather \*tlb) 260 {

261 **tlb_flush_mmu_tlbonly**(tlb); 262 **tlb_flush_mmu_free**(tlb); 263 }

 

*Listing 7-88:* mm/mmu_gather.c: [*tlb_flush_mmu()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n259)

 

With the [tlb_flush_mmu_tlbonly()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n416) function performing the TLB flushing

and [tlb_flush_mmu_free()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n251) which potentially frees pages. Note that these func-tions are also called individually where it is sensible to do so.

Examining [tlb_flush_mmu_tlbonly()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n416) (eliding an out of scope MMU notifier

call) as shown in Listing 7-89.

 

416 **static inline void** tlb_flush_mmu_tlbonly(**struct** mmu_gather \*tlb) 417 {

418 */\**

419 *\* Anything calling \_\_tlb_adjust_range() also sets at least one of*

420 *\* these bits.*

421 *\*/*

422 **if** (!(tlb-\>freed_tables \|\| tlb-\>cleared_ptes \|\| tlb-\>cleared_pmds \|\| 423 tlb-\>cleared_puds \|\| tlb-\>cleared_p4ds)) 424 **return**;

425

426 **tlb_flush**(tlb);

. . .

428 **\_\_tlb_reset_range**(tlb); 429 }

 

*Listing 7-89:* include/asm-generic/tlb.h: [*tlb_flush_mmu_tlbonly()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n416)

 

Not that the fields indicating that individual page table levels have been

cleared like cleared_ptes are huge table-specific and out of scope.

 

\*. We use ‘invalidate’ and ‘flush’ interchangeably here. Typically the difference between the two is that the former simply marks the cache invalid while the latter also write what is cached to the backing store, however in the case of a TLB this doesn’t make sense so the two can be considered equivalent.

 



 

If something has changed in the range, then [tlb_flush()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/tlb.h?h=v6.0#n10) is invoked and

the range is reset by [\_\_tlb_reset_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n331) to mark that the flush has occurred.

Examining the flush function as shown in Listing 7-90.

 

10 **static inline void tlb_flush**(**struct** mmu_gather \*tlb)

11 {

12 **unsigned long** start = 0UL, end = **TLB_FLUSH_ALL**;

13 **unsigned int** stride_shift = **tlb_get_unmap_shift**(tlb);

14

15 **if** (!tlb-\>fullmm && !tlb-\>need_flush_all) {

16 start = tlb-\>start;

17 end = tlb-\>end;

18 }

19

20 **flush_tlb_mm_range**(tlb-\>mm, start, end, stride_shift, tlb-\>

freed_tables);

21 }

 

*Listing 7-90:* arch/x86/include/asm/tlb.h: [*tlb_flush()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/tlb.h?h=v6.0#n10)

 

Note that stride_shift will be set to [PAGE_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_types.h?h=v6.0#n10) for non-huge pages. The start and end values will either span the range specified by the

[struct mmu_gather](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n267) object or the entire range to [TLB_FLUSH_ALL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/tlbflush.h?h=v6.0#n18) (this is hard-

coded to the maximum unsigned long value possible) if either fullmm or

need_flush_all is specified.

The heavy lifting is performed by [flush_tlb_mm_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n981) as shown in Listing

7-91.

 

981 **void flush_tlb_mm_range**(**struct** mm_struct \*mm, **unsigned long** start, 982 **unsigned long** end, **unsigned int** stride_shift, 983 **bool** freed_tables) 984 {

985 **struct** flush_tlb_info \*info; 986 **u64** new_tlb_gen;

987 **int** cpu;

988

989 cpu = **get_cpu**();

990

991 */\* Should we flush just the requested range? \*/* 992 **if** ((end == **TLB_FLUSH_ALL**) \|\| 993 ((end - start) \>\> stride_shift) \> **tlb_single_page_flush_ceiling**) { 994 start = 0; 995 end = **TLB_FLUSH_ALL**; 996 }

997

998 */\* This is also a barrier that synchronizes with switch_mm(). \*/* 999 new_tlb_gen = **inc_mm_tlb_gen**(mm);

1000

1001 info = **get_flush_tlb_info**(mm, start, end, stride_shift, freed_tables,

 



 

1002 new_tlb_gen); 1003

1004 */\**

1005 *\* flush_tlb_multi() is not optimized for the common case in which*

*only*

1006 *\* a local TLB flush is needed. Optimize this use-case by calling*

1007 *\* flush_tlb_func_local() directly in this case.* 1008 *\*/*

1009 **if** (**cpumask_any_but**(**mm_cpumask**(mm), cpu) \< nr_cpu_ids) { 1010 **flush_tlb_multi**(**mm_cpumask**(mm), info); 1011 } **else if** (mm == **this_cpu_read**(cpu_tlbstate.loaded_mm)) { 1012 **lockdep_assert_irqs_enabled**(); 1013 **local_irq_disable**(); 1014 **flush_tlb_func**(info); 1015 **local_irq_enable**(); 1016 }

1017

1018 **put_flush_tlb_info**(); 1019 **put_cpu**();

1020 }

 

*Listing 7-91:* arch/x86/mm/tlb.c: [*flush_tlb_mm_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n981)

 

We start by disabling preemption and obtaining the processor CPU via

[get_cpu()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/smp.h?h=v6.0#n267).

We then determine whether we should flush the entire range – this can

be activated by the caller specifying so or if the number of pages to flush

exceeds [tlb_single_page_flush_ceiling](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n937) which is hardcoded to 33 pages.

This exists as an optimisation where the range-based flush operations

may end up less efficient than a simple global TLB flush.

[inc_mm_tlb_gen()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/tlbflush.h?h=v6.0#n243) is called which is used to track which generation of TLB

operation is being performed, used to synchronise these operations with context switches.

The generation of a TLB operation is a simple atomically accessed,

monotonically incrementing, counter which keeps a track of which TLB state a CPU currently possesses.

The [get_flush_tlb_info()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n945) function establishes a new [struct flush_tlb_info](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/tlbflush.h?h=v6.0#n187)

object which is threaded through remaining logic as shown in Listing 7-92.

 

174 */\**

175 *\* TLB flushing:*

176 *\**

177 *\* - flush_tlb_all() flushes all processes TLBs* 178 *\* - flush_tlb_mm(mm) flushes the specified mm context TLB's* 179 *\* - flush_tlb_page(vma, vmaddr) flushes one page* 180 *\* - flush_tlb_range(vma, start, end) flushes a range of pages* 181 *\* - flush_tlb_kernel_range(start, end) flushes a range of kernel pages*

182 *\* - flush_tlb_multi(cpumask, info) flushes TLBs on multiple cpus* 183 *\**

 



 

184 *\* ..but the i386 has somewhat limited tlb flushing capabilities,* 185 *\* and page-granular flushes are available only on i486 and up.* 186 *\*/*

187 **struct** flush_tlb_info {

188 */\**

189 *\* We support several kinds of flushes.* 190 *\**

191 *\* - Fully flush a single mm. .mm will be set, .end will be* 192 *\** *TLB_FLUSH_ALL, and .new_tlb_gen will be the tlb_gen to* 193 *\** *which the IPI sender is trying to catch us up.* 194 *\**

195 *\* - Partially flush a single mm. .mm will be set, .start and* 196 *\** *.end will indicate the range, and .new_tlb_gen will be set* 197 *\** *such that the changes between generation .new_tlb_gen-1 and* 198 *\** *.new_tlb_gen are entirely contained in the indicated range.* 199 *\**

200 *\* - Fully flush all mms whose tlb_gens have been updated. .mm* 201 *\** *will be NULL, .end will be TLB_FLUSH_ALL, and .new_tlb_gen* 202 *\** *will be zero.* 203 *\*/*

204 **struct** mm_struct \*mm; 205 **unsigned long** start; 206 **unsigned long** end; 207 **u64** new_tlb_gen; 208 **unsigned int** initiating_cpu; 209 u8 stride_shift; 210 u8 freed_tables; 211 };

 

*Listing 7-92:* arch/x86/include/asm/tlbflush.h: [*struct flush_tlb_info*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/tlbflush.h?h=v6.0#n187)

 

We then reach an important part of the logic and an absolutely key part

of the TLB flush mechanism. If the memory in question is accessed by more

than one CPU, we need to perform a TLB remote shootdown operation.

A TLB remote shootdown occurs when we initiate an inter-processor-

interrupt (IPI) to indicate to other CPUs that they must flush their TLBs.

This is an expensive operation and best avoided, so if we need only flush the

current CPU we do so.

The fundamental function which performs the actual hardware TLB

flushing is [flush_tlb_func()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n723), to which we shall return. This is called directly

if we do not need to perform a remote shootdown, otherwise it is called by

each affected CPU.

How do we determine which CPUs have access to the memory described

by the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) object? This is determined via [mm_cpumask()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n696) which

looks up the cpu_bitmap field which tracks this information.

Finally when the operation is complete, the [put_cpu()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/smp.h?h=v6.0#n268) function is called

which re-enables preemption (note that the info object does not require any

‘put’ operation other than in debug modes).

 



 

The function which is invoked when a remote shootdown is re-

quired is [flush_tlb_multi()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n921)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n921) which in turn invokes [\_\_flush_tlb_multi()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n31) and

[native_flush_tlb_multi()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n889) (eliding out of scope tracing logic) as shown in List-

ing 7-93.

 

889 STATIC_NOPV **void native_flush_tlb_multi**(**const struct** cpumask \*cpumask, 890 **const struct** flush_tlb_info \*info) 891 {

. . .

904 */\**

905 *\* If no page tables were freed, we can skip sending IPIs to* 906 *\* CPUs in lazy TLB mode. They will flush the CPU themselves* 907 *\* at the next context switch.* 908 *\**

909 *\* However, if page tables are getting freed, we need to send the*

910 *\* IPI everywhere, to prevent CPUs in lazy TLB mode from tripping*

911 *\* up on the new contents of what used to be page tables, while* 912 *\* doing a speculative memory access.* 913 *\*/*

914 **if** (info-\>freed_tables) 915 **on_each_cpu_mask**(cpumask, flush_tlb_func, (**void** \*)info, **true**); 916 **else**

917 **on_each_cpu_cond_mask**(tlb_is_not_lazy, flush_tlb_func, 918 (**void** \*)info, 1, cpumask); 919 }

 

*Listing 7-93:* arch/x86/mm/tlb.c: [*native_flush_tlb_multi()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n889)

 

The heavy lifting of the IPI is performed via [on_each_cpu_mask()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/smp.h?h=v6.0#n90) and

[on_each_cpu_cond_mask()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/smp.c?h=v6.0#n1145), however discussion of this is out of scope for the book.

If no page tables are freed, then we skip those processes which are cur-

rently marked as being in lazy TLB mode (see section 7.1.8 for more details on this).

Both the remote and local shootdown variants ultimately invoke

[flush_tlb_func()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n723) where the actual flushing takes place (eliding tracing, statis-

tics and ASID logic) as shown in Listing 7-94.

 

716 */\**

717 *\* flush_tlb_func()'s memory ordering requirement is that any* 718 *\* TLB fills that happen after we flush the TLB are ordered after we* 719 *\* read active_mm's tlb_gen. We don't need any explicit barriers* 720 *\* because all x86 flush operations are serializing and the* 721 *\* atomic64_read operation won't be reordered by the compiler.* 722 *\*/*

723 **static void flush_tlb_func**(**void** \*info) 724 {

725 */\**

726 *\* We have three different tlb_gen values in here. They are:*

 



 

727 *\**

728 *\* - mm_tlb_gen:* *the latest generation.* 729 *\* - local_tlb_gen: the generation that this CPU has already caught*

730 *\** *up to.* 731 *\* - f-\>new_tlb_gen: the generation that the requester of the flush*

732 *\** *wants us to catch up to.* 733 *\*/*

734 **const struct** flush_tlb_info \*f = info; 735 **struct** mm_struct \*loaded_mm = **this_cpu_read**(cpu_tlbstate.loaded_mm); 736 **u32** loaded_mm_asid = **this_cpu_read**(cpu_tlbstate.loaded_mm_asid); 737 **u64** local_tlb_gen = **this_cpu_read**(cpu_tlbstate.ctxs\[loaded_mm_asid\].

tlb_gen);

738 **bool** local = **smp_processor_id**() == f-\>initiating_cpu; 739 **unsigned long** nr_invalidate = 0; 740 **u64** mm_tlb_gen;

741

742 */\* This code cannot presently handle being reentered. \*/* 743 **VM_WARN_ON**(!**irqs_disabled**());

744

745 **if** (!local) {

. . .

749 */\* Can only happen on remote CPUs \*/* 750 **if** (f-\>mm && f-\>mm != loaded_mm) 751 **return**; 752 }

753

754 **if** (**unlikely**(loaded_mm == &init_mm)) 755 **return**;

. . .

760 **if** (**this_cpu_read**(cpu_tlbstate_shared.is_lazy)) { 761 */\**

762 *\* We're in lazy mode. We need to at least flush our* 763 *\* paging-structure cache to avoid speculatively reading* 764 *\* garbage into our TLB. Since switching to init_mm is barely*

765 *\* slower than a minimal flush, just switch to init_mm.* 766 *\**

767 *\* This should be rare, with native_flush_tlb_multi() skipping*

768 *\* IPIs to lazy TLB mode CPUs.* 769 *\*/*

770 **switch_mm_irqs_off**(**NULL**, &init_mm, **NULL**); 771 **return**;

772 }

773

774 **if** (**unlikely**(f-\>new_tlb_gen != **TLB_GENERATION_INVALID** && 775 f-\>new_tlb_gen \<= local_tlb_gen)) { 776 */\**

777 *\* The TLB is already up to date in respect to f-\>new_tlb_gen.*

 



 

778 *\* While the core might be still behind mm_tlb_gen, checking*

779 *\* mm_tlb_gen unnecessarily would have negative caching*

*effects*

780 *\* so avoid it.* 781 *\*/*

782 **return**;

783 }

784

785 */\**

786 *\* Defer mm_tlb_gen reading as long as possible to avoid cache* 787 *\* contention.*

788 *\*/*

789 mm_tlb_gen = **atomic64_read**(&loaded_mm-\>context.tlb_gen); 790

791 **if** (**unlikely**(local_tlb_gen == mm_tlb_gen)) { 792 */\**

793 *\* There's nothing to do: we're already up to date. This can*

794 *\* happen if two concurrent flushes happen -- the first flush*

*to*

795 *\* be handled can catch us all the way up, leaving no work for*

796 *\* the second flush.* 797 *\*/*

798 **goto done**; 799 }

800

801 **WARN_ON_ONCE**(local_tlb_gen \> mm_tlb_gen); 802 **WARN_ON_ONCE**(f-\>new_tlb_gen \> mm_tlb_gen);

 

*Listing 7-94:* arch/x86/mm/tlb.c: [*flush_tlb_func()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n723) *initialisation and guard clauses*

 

We start by retrieving per-CPU state from [cpu_tlbstate](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/tlbflush.h?h=v6.0#n138) indicating the cur-

rently loaded [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) object in loaded_mm, the local TLB generation in local_tlb_gen and whether the operation is local in local.

We assert that IRQs are disabled, abort the operation if this the TLB

batch we are parameterised by does not specify the same process address space as this CPU and ensure that we are not running in the context of the

zygote kernel space [init_mm](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/init-mm.c?h=v6.0#n30).

If the current CPU is in lazy TLB mode (see section 7.1.8 for more on

this), i.e. we are a kernel thread which has ‘borrowed’ the page table map-pings of the previously running process, it is simpler at this point to just

switch to the zygote process which we do via [switch_mm_irqs_off()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n489).

If the generation number is not valid, then we abort, otherwise we finally

read the current generation number of the currently loaded process address space and place it in mm_tlb_gen. If this matches the current CPU’s generation (stored in local_tlb_gen) then we have nothing to do.

Finally, we perform some sanity checks on the TLB generation, before

moving ahead with the TLB flush itself as shown in Listing 7-95.

 



 

804 */\**

805 *\* If we get to this point, we know that our TLB is out of date.* 806 *\* This does not strictly imply that we need to flush (it's* 807 *\* possible that f-\>new_tlb_gen \<= local_tlb_gen), but we're* 808 *\* going to need to flush in the very near future, so we might* 809 *\* as well get it over with.* 810 *\**

811 *\* The only question is whether to do a full or partial flush.* 812 *\**

813 *\* We do a partial flush if requested and two extra conditions* 814 *\* are met:*

815 *\**

816 *\* 1. f-\>new_tlb_gen == local_tlb_gen + 1. We have an invariant that*

817 *\** *we've always done all needed flushes to catch up to* 818 *\** *local_tlb_gen. If, for example, local_tlb_gen == 2 and* 819 *\** *f-\>new_tlb_gen == 3, then we know that the flush needed to bring* 820 *\** *us up to date for tlb_gen 3 is the partial flush we're* 821 *\** *processing.* 822 *\**

823 *\** *As an example of why this check is needed, suppose that there* 824 *\** *are two concurrent flushes. The first is a full flush that* 825 *\** *changes context.tlb_gen from 1 to 2. The second is a partial* 826 *\** *flush that changes context.tlb_gen from 2 to 3. If they get* 827 *\** *processed on this CPU in reverse order, we'll see* 828 *\** *local_tlb_gen == 1, mm_tlb_gen == 3, and end != TLB_FLUSH_ALL.* 829 *\** *If we were to use \_\_flush_tlb_one_user() and set local_tlb_gen*

*to*

830 *\** *3, we'd be break the invariant: we'd update local_tlb_gen above* 831 *\** *1 without the full flush that's needed for tlb_gen 2.* 832 *\**

833 *\* 2. f-\>new_tlb_gen == mm_tlb_gen. This is purely an optimization.*

834 *\** *Partial TLB flushes are not all that much cheaper than full TLB* 835 *\** *flushes, so it seems unlikely that it would be a performance win* 836 *\** *to do a partial flush if that won't bring our TLB fully up to* 837 *\** *date. By doing a full flush instead, we can increase* 838 *\** *local_tlb_gen all the way to mm_tlb_gen and we can probably* 839 *\** *avoid another flush in the very near future.* 840 *\*/*

841 **if** (f-\>end != **TLB_FLUSH_ALL** && 842 f-\>new_tlb_gen == local_tlb_gen + 1 && 843 f-\>new_tlb_gen == mm_tlb_gen) { 844 */\* Partial flush \*/* 845 **unsigned long** addr = f-\>start;

846

847 */\* Partial flush cannot have invalid generations \*/* 848 **VM_WARN_ON**(f-\>new_tlb_gen == **TLB_GENERATION_INVALID**);

849

 



 

850 */\* Partial flush must have valid mm \*/* 851 **VM_WARN_ON**(f-\>mm == **NULL**); 852

853 nr_invalidate = (f-\>end - f-\>start) \>\> f-\>stride_shift; 854

855 **while** (addr \< f-\>end) { 856 **flush_tlb_one_user**(addr); 857 addr += 1UL \<\< f-\>stride_shift; 858 }

. . .

861 } **else** {

862 */\* Full flush. \*/* 863 nr_invalidate = **TLB_FLUSH_ALL**; 864

865 **flush_tlb_local**();

. . .

868 }

869

870 */\* Both paths above update our state to mm_tlb_gen. \*/* 871 **this_cpu_write**(cpu_tlbstate.ctxs\[loaded_mm_asid\].tlb_gen, mm_tlb_gen); 872

873 */\* Tracing is done in a unified manner to reduce the code size \*/*

874 **done**:

. . .

879 }

 

*Listing 7-95:* arch/x86/mm/tlb.c: [*flush_tlb_func()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n723) *flushing*

 

At this point the flush is either performed per each stride,

via [flush_tlb_one_user()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n1139) (for range-based flushing) or globally via

[flush_tlb_local()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n1192).

The range-based approach ultimately invokes [native_flush_tlb_one_user()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n1120)

which performs the flush via the x86-64 invlpg instruction.

The global flush ultimately invokes [native_flush_tlb_local()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n1177) which per-

forms the flush by replacing the contents of the x86-64 cr3 control register.

After the flush is complete, the CPU’s TLB generation is updated.

 

***7.1.7 Freeing pages***

[struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) objects are freed via [tlb_flush_mmu_free()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n251) which invokes

[tlb_batch_pages_flush()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n45) in turn:-

 

45 **static void tlb_batch_pages_flush**(**struct** mmu_gather \*tlb) 46 {

47 **struct** mmu_gather_batch \*batch; 48

49 **for** (batch = &tlb-\>local; batch && batch-\>nr; batch = batch-\>next) { 50 **struct** page \*\*pages = batch-\>pages;

 



 

51

52 **do** {

53 */\**

54 *\* limit free batch count when PAGE_SIZE \> 4K*

55 *\*/*

56 **unsigned int** nr = **min**(512U, batch-\>nr);

57

58 **free_pages_and_swap_cache**(pages, nr);

59 pages += nr;

60 batch-\>nr -= nr;

61

62 **cond_resched**();

63 } **while** (batch-\>nr);

64 }

65 tlb-\>active = &tlb-\>local;

66 }

 

*Listing 7-96:* mm/mmu_gather.c: [*tlb_batch_pages_flush()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n45)

 

This walks all of the [struct mmu_gather_batch](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/asm-generic/tlb.h?h=v6.0#n241) objects, freeing via

[free_pages_and_swap_cache()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n303) as shown in Listing 7-97.

 

299 */\**

300 *\* Passed an array of pages, drop them all from swapcache and then release*

301 *\* them. They are removed from the LRU and freed if this is their last use.*

302 *\*/*

303 **void free_pages_and_swap_cache**(**struct** page \*\*pages, **int** nr) 304 {

305 **struct** page \*\*pagep = pages; 306 **int** i;

307

308 **lru_add_drain**();

309 **for** (i = 0; i \< nr; i++) 310 **free_swap_cache**(pagep\[i\]); 311 **release_pages**(pagep, nr); 312 }

 

*Listing 7-97:* mm/swap_state.c: [*free_pages_and_swap_cache()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n303)

 

This drains folio batches to ensure that there are no odd non-LRU cases

to deal with when freeing these pages via [lru_add_drain()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n727) (see section 11.7

for more on folio batches), before freeing related swap caches (see the swap

## chapter for more on that) via [free_swap_cache()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap_state.c?h=v6.0#n280).

The actual decrement of the page reference count and possible freeing

is achieved via [release_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n934) (eliding out of scope huge page, zone device,

cgroup and statistics logic) as shown in Listing 7-98.

 

926 */\*\**

927 *\* release_pages - batched put_page()* 928 *\* @pages: array of pages to release*

 



 

929 *\* @nr: number of pages*

930 *\**

931 *\* Decrement the reference count on all the pages in @pages. If it* 932 *\* fell to zero, remove the page from the LRU and free it.* 933 *\*/*

934 **void release_pages**(**struct** page \*\*pages, **int** nr) 935 {

936 **int** i;

937 **LIST_HEAD**(pages_to_free); 938 **struct** lruvec \*lruvec = **NULL**; 939 **unsigned long** flags = 0; 940 **unsigned int** lock_batch; 941

942 **for** (i = 0; i \< nr; i++) { 943 **struct** folio \*folio = **page_folio**(pages\[i\]); 944

945 */\**

946 *\* Make sure the IRQ-safe lock-holding time does not get* 947 *\* excessive with a continuous string of pages from the* 948 *\* same lruvec. The lock is held only if lruvec != NULL.* 949 *\*/*

950 **if** (lruvec && ++lock_batch == **SWAP_CLUSTER_MAX**) { 951 **unlock_page_lruvec_irqrestore**(lruvec, flags); 952 lruvec = **NULL**; 953 }

. . .

970 **if** (!**folio_put_testzero**(folio)) 971 **continue**;

. . .

982 **if** (**folio_test_lru**(folio)) { 983 **struct** lruvec \*prev_lruvec = lruvec; 984

985 lruvec = **folio_lruvec_relock_irqsave**(folio, lruvec, 986 &flags

);

987 **if** (prev_lruvec != lruvec) 988 lock_batch = 0; 989

990 **lruvec_del_folio**(lruvec, folio); 991 **\_\_folio_clear_lru_flags**(folio); 992 }

993

994 */\**

995 *\* In rare cases, when truncation or holepunching raced with*

996 *\* munlock after VM_LOCKED was cleared, Mlocked may still be*

997 *\* found set here. This does not indicate a problem, unless*

998 *\* "unevictable_pgs_cleared" appears worryingly large.*

 



 

999 *\*/*

1000 **if** (**unlikely**(**folio_test_mlocked**(folio))) { 1001 **\_\_folio_clear_mlocked**(folio);

. . .

1004 }

1005

1006 **list_add**(&folio-\>lru, &pages_to_free); 1007 }

1008 **if** (lruvec)

1009 **unlock_page_lruvec_irqrestore**(lruvec, flags);

. . .

1012 **free_unref_page_list**(&pages_to_free); 1013 }

 

*Listing 7-98:* mm/swap.c: [*release_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n934)

 

We won’t go into extensive detail here as this is the purview of the phys-

ical memory chapter, however the key thing is the [folio_put_testzero()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n727) call

which decrements the folio’s reference count and if it is non-zero we move to

the next folio.

The actual physical allocation is ultimately performed by

[free_unref_page_list().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n3510)

Note that we do not perform a check on the folio map count. This is be-

cause every mapping will also result in the folio’s reference counter being

incremented – this may exceed the map count (the kernel may need to take

a reference) but will never be below it.

 

***7.1.8 Lazy TLB mode***

Lazy TLB mode is a feature within the kernel whereby kernel threads are

able to simply ‘borrow’ the address space of the previous running process

rather than performing a costly context switch when context switching from

a userland process to a kernel thread.

The fact that a process has entered lazy TLB mode is set by

[enter_lazy_tlb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n663) as shown in Listing 7-99.

 

650 */\**

651 *\* Please ignore the name of this function. It should be called* 652 *\* switch_to_kernel_thread().* 653 *\**

654 *\* enter_lazy_tlb() is a hint from the scheduler that we are entering a* 655 *\* kernel thread or other context without an mm. Acceptable implementations*

656 *\* include doing nothing whatsoever, switching to init_mm, or various clever*

657 *\* lazy tricks to try to minimize TLB flushes.* 658 *\**

659 *\* The scheduler reserves the right to call enter_lazy_tlb() several times*

660 *\* in a row. It will notify us that we're going back to a real mm by* 661 *\* calling switch_mm_irqs_off().* 662 *\*/*

 



 

663 **void enter_lazy_tlb**(**struct** mm_struct \*mm, **struct** task_struct \*tsk) 664 {

665 **if** (**this_cpu_read**(cpu_tlbstate.loaded_mm) == &init_mm) 666 **return**;

667

668 **this_cpu_write**(cpu_tlbstate_shared.is_lazy, **true**); 669 }

 

*Listing 7-99:* arch/x86/mm/tlb.c: [*enter_lazy_tlb()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n663)

 

This stores the fact that a process is lazy so the TLB logic can know that

there is not an issue as a result. In addition, the fact that we do this can re-sult in corrupted TLB in kernel mode, which is an expected side effect – the

[spurious_kernel_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/fault.c?h=v6.0#n1007) function explicitly handles this by (see section 6.1 on hardware page faulting).

When a process is switched and it is no longer appropriate to maintain

lazy TLB mode, this is achieved in [switch_mm_irqs_off()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n489)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/mm/tlb.c?h=v6.0#n489)

 
