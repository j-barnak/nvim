The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

**10**

 

**W R I T E B A C K**

 

Writeback, as the names suggests, is the process by

which Linux ultimately writes data back to disk from

the page cache. The kernel must maintain a trade-off

between caching writes in memory and writing back

to disk and handle scenarios under which dirtying ex-

ceeds writeback bandwidth. We discuss how all of this

is performed within this chapter.

In order to track which page cache folios need writeback, we track which

ones have had changes made to them since they were last synchronised to

disk. These pages are termed dirty. Those which are in sync with the disk

(and uptodate, i.e. have already successfully been read from disk) are termed

clean. We discuss the process of tracking dirty data in Section 10.1.

The actual process of writeback is performed one of two ways—

periodically in the background, or when explicit synchronisation is trig-

gered. When folios are dirtied, they automatically become subject to back-

ground writeback. In detail:

Writeback in Linux is divided into several different stages:

 

**Dirty Tracking** We first need to know that data has changed in the page

cache, which occurs when data is written to the page cache. Both the folio written to and the inode describing the file are marked dirty as de-

scribed in Section 10.1.

The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

**Dirty Page Balancing** Each time data is marked dirty, the kernel checks to

see whether either the amount of dirty data exceeds vm.dirty_bytes, or the ratio between this data and available memory exceeds vm.dirty_ratio. If this is the case, the I/O operation blocks and writeback is performed

immediately, as described in Section 10.14.

**Background Dirty Page Balancing** If direct balancing is not required,

the kernel check to see whether the amount of dirty data exceeds vm.dirty_background_bytes, or the ratio between this data and available memory exceeds vm.dirty_background_ratio (these are mutually exclusive, of one tuneable is set, the other is cleared). In either case, the writeback work queue thread is immediately woken to perform background write-

back. Again, see Section 10.14 for details on this process.

**Synchronisation** A user can additionally opt to manually trigger synchroni-

sation to the disk via a number of system calls, e.g. [sync()](https://man7.org/linux/man-pages/man2/sync.2.html)[.](https://man7.org/linux/man-pages/man2/sync.2.html) We examine how manual synchronisation to disk is performed in the kernel in Sec-

tion 10.6.

**Background Writeback** If not immediately awoken, the writeback kernel

thread is otherwise woken up vm.dirty_writeback_centisecs (expressed in ‘centiseconds’, or hundredths of a second) after the last time this check was performed.

**Writing Back to Disk** Either synchronisation is requested or the writeback

work queue thread has identified data that need to be written back, i.e. older than vm.dirty_expire_centisecs. In either case writeback to disk is

begun, as described in in Section 10.10.

**Writing Back to the Block Device** Ultimately the actual I/O must be sub-

mitted to the underlying block device. What we must write back is deter-mined by the levels above, which are then translated into block opera-

tions, which we examine in Section 9.10.4.

 

**10.1 Dirty Tracking in the Kernel**

 

In order to keep track of what needs to be written back to disk in the page cache we need to track two separate things–the dirty folios themselves and the inodes which back them.

Recalling from Section 4.5 that the [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) object is en-

veloped by its describing [struct inode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593) object, we can observe how this track-

ing is performed in Figure 10-1.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

[bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) [inode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593)

 

[address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)

b_dirty

 

i_pages

 

[xarray](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n296)

 

Dirty

 

Dirty

 

[folio folio folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256)

 

*Figure 10-1: Dirty Page and inode Tracking*

 

Each device which ‘backs’ the data stored in the page cache is termed

a ‘Backing Device’, and data associated with it is termed ’Backing Device

Information’ or BDI for short. BDI is typically used interchangeably to

describe the backing device itself, as will we. These are described by the

[struct backing_dev_info](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n165) type.

The state of writeback on each BDI is tracked using a [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)

object, and it is here that dirty inodes are tracked in its b_dirty list as shown

in Figure 10-1.

We tag dirty folios in the [struct address_space-\>i_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) xarray us-

ing [xas_set_mark()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/xarray.c?h=v6.0#n878) which uses the xarray mark functionality to set the

[PAGECACHE_TAG_DIRTY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n452) tag.

This enables us to very quickly iterate through all dirty pages in an

[struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) using [xas_for_each_marked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1773).

Once we have tagged the dirty pages, we also need to keep track of which

inodes possess [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) objects which have dirty pages attached.

These are termed ‘dirty inodes’.

If the kernel configuration option CONFIG_CGROUP_WRITEBACK is not set, this

object is simply accessible via [struct backing_dev_info-\>wb](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n165) field and we simply

maintain a single writeback object per BDI.

This makes sense, as writeback is limited by each backing device’s avail-

able I/O bandwidth, so the state should be tied to each of these devices.

However, if cgroups are in use, available bandwidth in the BDI may

be subdivided between cgroups. Discussion of cgroups is out of scope

for the book, but it is useful to note that if CONFIG_CGROUP_WRITEBACK is set,

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

then a pointer to the [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) relevant object is stored in the

[struct inode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593)-\>i_wb field instead.

In either case, we obtain the relevant BDI writeback object via

[inode_to_wb().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev.h?h=v6.0#n240)

Maintaining this list is how we track which pages inodes are dirty and

whose pages need writeback. We examine how this is ultimately performed

in Section 10.10.

Placing inodes into the dirty list and marking pages as dirty typically oc-

cur either through a write operation such as that accomplished through the

[write()](https://man7.org/linux/man-pages/man2/write.2.html) system call, discussed in Section 10.12, or by a page fault occurring

on a memory-mapped file-backed page, discussed in Section 10.12.

 

**10.2 Marking the Folio Dirty**

 

Regardless of what makes the pages dirty, we mark the xarray accordingly in

[\_\_folio_mark_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2607), as shown in Listing 10-1.

 

2594 */\**

2595 *\* Mark the folio dirty, and set it dirty in the page cache, and mark* 2596 *\* the inode dirty.*

2597 *\**

2598 *\* If warn is true, then emit a warning if the folio is not uptodate and has*

2599 *\* not been truncated.*

2600 *\**

2601 *\* The caller must hold lock_page_memcg(). Most callers have the folio* 2602 *\* locked. A few have the folio blocked from truncation through other* 2603 *\* means (eg zap_page_range() has it mapped and is holding the page table*

2604 *\* lock). This can also be called from mark_buffer_dirty(), which I* 2605 *\* cannot prove is always protected against truncate.* 2606 *\*/*

2607 **void \_\_folio_mark_dirty**(**struct** folio \*folio, **struct** address_space \*mapping, 2608 **int** warn) 2609 {

2610 **unsigned long** flags; 2611

2612 **xa_lock_irqsave**(&mapping-\>i_pages, flags); 2613 **if** (folio-\>mapping) { */\* Race with truncate? \*/* 2614 **WARN_ON_ONCE**(warn && !folio_test_uptodate(folio)); 2615 **folio_account_dirtied**(folio, mapping); 2616 **\_\_xa_set_mark**(&mapping-\>i_pages, folio_index(folio), 2617 **PAGECACHE_TAG_DIRTY**); 2618 }

2619 **xa_unlock_irqrestore**(&mapping-\>i_pages, flags); 2620 }

 

*Listing 10-1:* mm/page-writeback.c: [*\_\_folio_mark_dirty()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2607)

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

Here the mark is set to [PAGECACHE_TAG_DIRTY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n452) for the folio under lock, with

care to avoid a race with truncation (see Section 9.9 for more on this opera-

tion), which naturally clears the [struct folio-\>mapping](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) field.

Statistics are updated in [folio_account_dirtied()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2552)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2552) which also assigns the

[struct inode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593)-\>i_wb field if not already set via [inode_attach_wb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n239).

 

**10.3 Marking the inode Dirty**

 

Now we have marked the dirty folios in the xarray, we need to add the sur-

rounding dirty inodes to the BDI dirty list, so we know what to write back

when the time comes.

This is performed in [\_\_mark_inode_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2363)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2363) which again is invoked both

when writeback performed via the [write()](https://man7.org/linux/man-pages/man2/write.2.html) system call or when a page fault

occurs.

The page cache code must handle the case of both writing back changes

to inode metadata itself as well as the underlying folios. We will examine

only writing back the underlying data. However note that the inode flags

[I_DIRTY_SYNC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2433) and [I_DIRTY_DATASYNC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2434), combined in the mask [I_DIRTY_INODE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2455)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2455) repre-

sent the need to write back this metadata.

In addition, the kernel handles a special case of changes to file time

metadata for a filesystem mounted with the lazytime option specified via

[I_DIRTY_TIME](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2447). Again, this is out of scope for our discussion, but it is worth

noting that these cases are handled.

 

**N O T E** Linux provides three timestamps associated with file metadata encapsulated in a

file’s inode—*atime*, *ctime* and *mtime*. These specify the last time the file was accessed,

the last time its metadata was changed and the last time the underlying file data was

modified, respectively.

Typically file systems are mounted such that the access time is updated only if the

*mtime* or *ctime* was updated more recently (*relatime* mode), or written to disk only

when absolutely necessary (*lazytime* mode).

 

The [I_DIRTY_PAGES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2435) flag specifies that the underlying file data has been

dirtied, which is what we focus upon. We therefore examine the logic specif-

ically tied to this case in [\_\_mark_inode_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2363) in Listing 10-2, eliding all irrele-

vant code.

 

2363 **void \_\_mark_inode_dirty**(**struct** inode \*inode, **int** flags) 2364 {

2365 **struct** super_block \*sb = inode-\>i_sb;

. . .

2367 **struct** bdi_writeback \*wb = **NULL**;

. . .

2406 **spin_lock**(&inode-\>i_lock);

. . .

2409 **if** ((inode-\>i_state & flags) != flags) { 2410 **const int** was_dirty = inode-\>i_state & **I_DIRTY**; 2411

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2412 **inode_attach_wb**(inode, **NULL**);

. . .

2417 inode-\>i_state \|= flags; 2418

2419 */\**

2420 *\* Grab inode's wb early because it requires dropping i_lock*

*and we*

2421 *\* need to make sure following checks happen atomically with*

*dirty*

2422 *\* list handling so that we don't move inodes under flush*

*worker's*

2423 *\* hands.* 2424 *\*/*

2425 **if** (!was_dirty) { 2426 wb = **locked_inode_to_wb_and_lock_list**(inode); 2427 **spin_lock**(&inode-\>i_lock); 2428 }

2429

2430 */\**

2431 *\* If the inode is queued for writeback by flush worker, just*

2432 *\* update its dirty state. Once the flush worker is done with*

2433 *\* the inode it will place it on the appropriate superblock*

2434 *\* list, based upon its state.* 2435 *\*/*

2436 **if** (inode-\>i_state & **I_SYNC_QUEUED**) 2437 **goto out_unlock**; 2438

2439 */\**

2440 *\* Only add valid (hashed) inodes to the superblock's* 2441 *\* dirty list. Add blockdev inodes as well.* 2442 *\*/*

2443 **if** (!**S_ISBLK**(inode-\>i_mode)) { 2444 **if** (**inode_unhashed**(inode)) 2445 **goto out_unlock**; 2446 }

2447 **if** (inode-\>i_state & **I_FREEING**) 2448 **goto out_unlock**; 2449

2450 */\**

2451 *\* If the inode was already on b_dirty/b_io/b_more_io, don't*

2452 *\* reposition it (that would break b_dirty time-ordering).*

2453 *\*/*

2454 **if** (!was_dirty) { 2455 **struct** list_head \*dirty_list; 2456 **bool** wakeup_bdi = **false**; 2457

2458 inode-\>dirtied_when = **jiffies**;

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

. . .

2462 **if** (inode-\>i_state & **I_DIRTY**) 2463 dirty_list = &wb-\>b_dirty;

. . .

2467 wakeup_bdi = **inode_io_list_move_locked**(inode, wb, 2468 dirty_list);

2469

2470 **spin_unlock**(&wb-\>list_lock); 2471 **spin_unlock**(&inode-\>i_lock);

. . .

2474 */\** 2475 *\* If this is the first dirty inode for this bdi,* 2476 *\* we have to wake-up the corresponding bdi thread*

2477 *\* to make sure background write-back happens* 2478 *\* later.* 2479 *\*/* 2480 **if** (wakeup_bdi && 2481 (wb-\>bdi-\>capabilities & **BDI_CAP_WRITEBACK**)) 2482 **wb_wakeup_delayed**(wb); 2483 **return**; 2484 }

2485 }

2486 **out_unlock**:

2487 **if** (wb)

2488 **spin_unlock**(&wb-\>list_lock); 2489 **out_unlock_inode**:

2490 **spin_unlock**(&inode-\>i_lock); 2491 }

 

*Listing 10-2:* fs/fs-writeback.c: [*\_\_mark_inode_dirty()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2363)

 

The flags specified for the dirtying operation are provided by the

flags parameter. As previously discussed, we are only interested in the

[I_DIRTY_PAGES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2435) flag, however note that the [I_DIRTY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2456) mask includes this flag.

Interacting with the [struct inode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593) fields is performed under its i_lock spin-

lock and we begin by proceeding only if this dirtying represents a change in

the inode’s state, maintained in its [struct inode-\>i_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593) field—if nothing has

changed, there’s nothing to do.

Next we determine whether the node was previously dirty in the

was_dirty predicate. This would only be set true if the flags had changed, but

varied whether the inode, pages or lazytime dirty flags were set.

If the inode has transitioned from being clean to dirty, we obtain the rel-

evant [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) object early via [locked_inode_to_wb_and_lock_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n301).

This handles the CONFIG_CGROUP_WRITEBACK case using [inode_to_wb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev.h?h=v6.0#n240) and ac-

counting for races, ensuring that reference counting is performed correctly

and acquires the [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>list_lock spin lock.

We do this early, as the kernel thread which ultimately flushes

data back to disk (see Section 10.10) may race with us if we do not

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

acquire this at this stage. We must re-lock [struct inode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593)-\>i_lock as

[locked_inode_to_wb_and_lock_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n301) releases it.

If the inode is already queued for writeback, as indicated by the

[I_SYNC_QUEUED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2452) flag being set in [struct inode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593)-\>i_state, we abort as no action is required.

Next we check to see whether the inode is hashed in the inode cache, a

hash table maintained for fast access by the VFS. If it is not, then the inode is not in a state where it can be correctly dirty tracked, so we abort. We make

an exception for blockdev inodes (see Section 9.10.2).

Finally, if the inode is in the process of being freed as indicated by the

[I_FREEING](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2439), we do not need to proceed with marking it dirty.

We always keep track of when the inode was marked dirty in its

[struct inode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593)-\>dirtied_when field, which is vital for making decisions on

writeback (see Section 10.10 for more details on how this plays a role), be-

fore placing the inode on the dirty list at [struct bdi_writeback-\>b_dirty](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) via

[inode_io_list_move_locked() .](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n118)

An important nuance to take into account here is that, when dirtying

pages, the inode passed to the function is the [struct address_space-\>host](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) one. In the case of accessing a block device directly via e.g. /dev/sda1, it is a special blockdev inode that is present here rather than the inode of the individual device file, which keeps the dirtying time consistent.

See Section 9.10.2 for more details on blockdev and accessing block de-

vices directly via device files.

 

**N O T E** The kernel counts time in jiffies, which is an internal kernel field that is updated a

certain number of times a second.

 

[inode_io_list_move_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n118) proceeds to place the inode on the BDI’s dirty

list [struct bdi_writeback-\>b_dirty](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) using its [struct inode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593)-\>i_io_list list node.

Each block device has a writeback flush kernel thread which performs

background writeback based on tuneable configuration (see Section 10.11 for details), which is woken up when the first dirty inode is placed on its as-

sociated [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) dirty list.

We achieve this by first checking whether wakeup needs to be done

in [inode_io_list_move_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n118), which uses the [wb_io_lists_populated()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n85)

function to do so, which in turn sets the [WB_has_dirty_io](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n27) flag in the

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>state field to track this if this is the case.

We then use the result of this call, if the BDI is capable of writeback, by

invoking [wb_wakeup_delayed()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/backing-dev.c?h=v6.0#n258) which we explore in Listing 10-32 in Section

10.10.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

**10.4 Page Fault Dirty Tracking**

 

[handle_pte_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4860)

 

[do_wp_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3360)

 

[wp_page_shared()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3304) [fault_dirty_shared_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2993)

 

[do_page_mkwrite()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2959) [balance_dirty_pages_ratelimited()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1949)

 

vm_ops-\>page_mkwrite()

 

[filemap_page_mkwrite()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3399)

 

[folio_mark_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2730)

 

a_op-\>dirty_folio()

Typically

[block_dirty_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n616)

 

[\_\_folio_mark_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2607) [\_\_mark_inode_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2363)

 

*Figure 10-2: Typical Write Fault Dirty Page Tracking*

 

We have already discussed how folios are read from disk in Section 9.4 above,

but we have not yet explored how data is written back to disk when modified

in a memory-mapped file, which we will do so here.

We leverage the hardware memory management to determine when a

file-backed mapping is written to by making the mapping read-only when it

is clean, and triggering a file system-specific hook when it is written to.

This is handled in [wp_page_shared()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3304) which is discussed in Section 6.9 and

Listing 6-39. This ultimately invokes [do_page_mkwrite()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2959) (discussed in Listing

6-31), which calls the [struct vm_operations_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n539)-\>page_mkwrite callback speci-

fied in the VMA [struct vm_area_struct-\>vm_ops](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) field.

As discussed in Section 9.1, when a VMA is memory-mapped, its

[struct file_operations-\>mmap](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2093) is invoked in [struct file-\>f_op](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) and it is this

which specifies the [struct vm_area_struct-\>vm_ops](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) callbacks in which

page_mkwrite is specified..

The majority of files systems use a generic function when memory map-

ping, [generic_file_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3433) as shown in Listing 10-3.

 

3431 */\* This is used for a general mmap of a disk file \*/* 3432

3433 **int generic_file_mmap**(**struct** file \*file, **struct** vm_area_struct \*vma)

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

3434 {

3435 **struct** address_space \*mapping = file-\>f_mapping; 3436

3437 **if** (!mapping-\>a_ops-\>read_folio) 3438 **return**-**ENOEXEC**; 3439 file_accessed(file); 3440 vma-\>vm_ops = &**generic_file_vm_ops**; 3441 **return** 0;

3442 }

 

*Listing 10-3:* mm/filemap.c: [*generic_file_mmap()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3433)

 

This function sets [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403)-\>vm_ops to the [generic_file_vm_ops](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3425)

object, which specifies each of the fault, map_pages and page_mkwrite callbacks,

shown in Listing 10-4.

 

3425 **const struct** vm_operations_struct **generic_file_vm_ops** = { 3426 .fault = **filemap_fault**, 3427 .map_pages = **filemap_map_pages**, 3428 .page_mkwrite = **filemap_page_mkwrite**, 3429 };

 

*Listing 10-4:* mm/filemap.c: [*generic_file_vm_ops*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3425)

 

We have already discussed [filemap_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3084) in Listing 9-35 and

[filemap_map_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3322) in Listing 9-84 in Section 9.4 above.

However, we have yet to examine [filemap_page_mkwrite()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3399), which deter-

mines how the folio dirtying takes place, as shown in Listing 10-5.

 

3399 **vm_fault_t filemap_page_mkwrite**(**struct** vm_fault \*vmf) 3400 {

3401 **struct** address_space \*mapping = vmf-\>vma-\>vm_file-\>f_mapping; 3402 **struct** folio \*folio = **page_folio**(vmf-\>page); 3403 **vm_fault_t** ret = **VM_FAULT_LOCKED**; 3404

3405 **sb_start_pagefault**(mapping-\>host-\>i_sb); 3406 **file_update_time**(vmf-\>vma-\>vm_file); 3407 **folio_lock**(folio); 3408 **if** (folio-\>mapping != mapping) { 3409 **folio_unlock**(folio); 3410 ret = **VM_FAULT_NOPAGE**; 3411 **goto out**; 3412 }

3413 */\**

3414 *\* We mark the folio dirty already here so that when freeze is in*

3415 *\* progress, we are guaranteed that writeback during freezing will*

3416 *\* see the dirty folio and writeprotect it again.* 3417 *\*/*

3418 **folio_mark_dirty**(folio); 3419 **folio_wait_stable**(folio);

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

3420 **out**:

3421 **sb_end_pagefault**(mapping-\>host-\>i_sb); 3422 **return** ret;

3423 }

 

*Listing 10-5:* mm/filemap.c: [*filemap_page_mkwrite()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3399)

 

This starts by invoking [sb_start_pagefault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n1928) which increments a

[struct sb_writers](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n1445) read/write semaphore specific to page faults, which is in

place in order to permit the freezing of file systems such that they can be kept

stable, as shown in Listing 10-6. [sb_end_pagefault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n1863) reverts this lock.

 

1909 */\*\**

1910 *\* sb_start_pagefault - get write access to a superblock from a page fault*

1911 *\* @sb: the super we write to* 1912 *\**

1913 *\* When a process starts handling write page fault, it should embed the* 1914 *\* operation into sb_start_pagefault() - sb_end_pagefault() pair to get* 1915 *\* exclusion against file system freezing. This is needed since the page fault*

1916 *\* is going to dirty a page. This function increments number of running page*

1917 *\* faults preventing freezing. If the file system is already frozen, the* 1918 *\* function waits until the file system is thawed.* 1919 *\**

1920 *\* Since page fault freeze protection behaves as a lock, users have to*

*preserve*

1921 *\* ordering of freeze protection and other filesystem locks. It is advised to*

1922 *\* put sb_start_pagefault() close to mmap_lock in lock ordering. Page fault*

1923 *\* handling code implies lock dependency:* 1924 *\**

1925 *\* mmap_lock*

1926 *\** *-\> sb_start_pagefault* 1927 *\*/*

1928 **static inline void sb_start_pagefault**(**struct** super_block \*sb) 1929 {

1930 **\_\_sb_start_write**(sb, **SB_FREEZE_PAGEFAULT**); 1931 }

 

*Listing 10-6:* include/linux/fs.h: [*sb_start_pagefault()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n1928)

 

The mtime and ctime of the file are updated via [file_update_time()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/inode.c?h=v6.0#n2110)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/inode.c?h=v6.0#n2110) and

then a folio lock is acquired via [folio_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n913)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n913) As is typical in fault handling

logic, this returns the folio locked and expects the caller to unlock as re-

quired.

Once the lock is acquired, as is traditional we check to ensure the folio

has not been truncated by ensuring the mapping is as expected.

Once we have obtained the correct, locked folio, we go ahead and mark

the folio dirty in [folio_mark_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2730), shown in Listing 10-8.

We will examine this function shortly, but prior to doing so we will ex-

amine what remains, specifically [folio_wait_stable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n3078)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n3078) which we explore in

Listing 10-7.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

3065 */\*\**

3066 *\* folio_wait_stable() - wait for writeback to finish, if necessary.* 3067 *\* @folio: The folio to wait on.* 3068 *\**

3069 *\* This function determines if the given folio is related to a backing* 3070 *\* device that requires folio contents to be held stable during writeback.*

3071 *\* If so, then it will wait for any pending writeback to complete.* 3072 *\**

3073 *\* Context: Sleeps. Must be called in process context and with* 3074 *\* no spinlocks held. Caller should hold a reference on the folio.* 3075 *\* If the folio is not locked, writeback may start again after writeback* 3076 *\* has finished.*

3077 *\*/*

3078 **void folio_wait_stable**(**struct** folio \*folio) 3079 {

3080 **if** (**folio_inode**(folio)-\>i_sb-\>s_iflags & **SB_I_STABLE_WRITES**) 3081 **folio_wait_writeback**(folio); 3082 }

 

*Listing 10-7:* mm/page-writeback.c: [*folio_wait_stable()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n3078)

 

Once the page fault is complete and the folio is unlocked, it becomes

possible for the mapping userland code to write to the folio at will. If the folio is in the midst of being written back to the underlying block device, a user could race with this code and cause a torn write. Consider a buffer that contains:

AAAAAA

Imagine that the first three bytes have been written back to the block device, but afterwards a user writes BBBBBB to the buffer, before writeback completes, permitting the final three bytes to be written from this new buffer state. Af-ter this has happened, the disk will contain:

AAABBB

Which will be observable data corruption, and the kernel will mark the folio clean and uptodate as if it reflected the contents of the disk although it does not.

Regardless of what the kernel does to mitigate this, when the second

write occurs, the folio will be marked dirty and the on-disk representation will eventually be written out and be made consistent with the page cache.

For many modern file systems and backing devices, this suffices. The

user has to expect that it is feasible that a write in such a system could end up corrupted however unlikely the race is, and thus power loss might result in observable corruption.

In some cases however, we cannot tolerate this possibility. For instance,

the NFS file system allows other systems to observe the written data. Also some block devices might not be able to tolerate this kind of race midway through a write, or either a block device or filesystem may rely on check-sums remaining consistent.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

In these cases, either the file system institutes its own means of maintain-

ing consistency, or the block device or file system sets a flag to indicate that

writes must be stable, i.e. that we must wait for any parallel writeback to com-

plete before proceeding.

This is achieved via the [SB_I_STABLE_WRITES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/linux/fs.h?h=v6.0#n1421) super block flag set in

[struct super_block-\>s_iflags](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n1451). This is either set by the file system itself, or de-

termined by the block device in [set_bdev_super()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/super.c?h=v6.0#n1230) via the [bdev_stable_writes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/blkdev.h?h=v6.0#n1267)

predicated that checks for the [QUEUE_FLAG_STABLE_WRITES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/blkdev.h?h=v6.0#n568) flag.

This is required for a RAID 5 array for instance, which ensures parity

across disks which cannot be guaranteed if writes are unstable.

If stable writes are required, then we wait for any remaining writeback to

complete via [folio_wait_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n3031)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n3031) This forms part of the folio wait logic,

and thus is discussed in Section 9.11 and Listing 9-146.

See also Section 10.10 and Listing 10-26 for further discussion about this

issue.

Returning to folio dirtying, we can observe this function in Listing 10-8.

 

2717 */\*\**

2718 *\* folio_mark_dirty - Mark a folio as being modified.* 2719 *\* @folio: The folio.*

2720 *\**

2721 *\* The folio may not be truncated while this function is running.* 2722 *\* Holding the folio lock is sufficient to prevent truncation, but some* 2723 *\* callers cannot acquire a sleeping lock. These callers instead hold* 2724 *\* the page table lock for a page table which contains at least one page* 2725 *\* in this folio. Truncation will block on the page table lock as it* 2726 *\* unmaps pages before removing the folio from its mapping.* 2727 *\**

2728 *\* Return: True if the folio was newly dirtied, false if it was already dirty.*

2729 *\*/*

2730 **bool folio_mark_dirty**(**struct** folio \*folio) 2731 {

2732 **struct** address_space \*mapping = **folio_mapping**(folio); 2733

2734 **if** (**likely**(mapping)) { 2735 */\**

2736 *\* readahead/lru_deactivate_page could remain* 2737 *\* PG_readahead/PG_reclaim due to race with*

*folio_end_writeback*

2738 *\* About readahead, if the folio is written, the flags would*

*be*

2739 *\* reset. So no problem.* 2740 *\* About lru_deactivate_page, if the folio is redirtied,* 2741 *\* the flag will be reset. So no problem. but if the* 2742 *\* folio is used by readahead it will confuse readahead* 2743 *\* and make it restart the size rampup process. But it's* 2744 *\* a trivial problem.* 2745 *\*/*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2746 **if** (**folio_test_reclaim**(folio)) 2747 **folio_clear_reclaim**(folio); 2748 **return** mapping-\>a_ops-\>**dirty_folio**(mapping, folio); 2749 }

2750

2751 **return noop_dirty_folio**(mapping, folio); 2752 }

 

*Listing 10-8:* mm/page-writeback.c: [*folio_mark_dirty()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2730)

 

We start by handling a race condition, before deferring to the file

system-specific [struct address_space-\>a_ops-\>dirty_folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) function in its

[struct address_space_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n356) callback object.

Again, this can be customised per-file system, but many file systems will

defer this to a generic library function, [block_dirty_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n616), shown in Listing

10-9 (eliding out of scope cgroup logic).

 

591 */\**

592 *\* Add a page to the dirty page list.* 593 *\**

594 *\* It is a sad fact of life that this function is called from several places*

595 *\* deeply under spinlocking. It may not sleep.* 596 *\**

597 *\* If the page has buffers, the uptodate buffers are set dirty, to preserve*

598 *\* dirty-state coherency between the page and the buffers. It the page does*

599 *\* not have buffers then when they are later attached they will all be set*

600 *\* dirty.*

601 *\**

602 *\* The buffers are dirtied before the page is dirtied. There's a small race*

603 *\* window in which a writepage caller may see the page cleanness but not the*

604 *\* buffer dirtiness. That's fine. If this code were to set the page dirty*

605 *\* before the buffers, a concurrent writepage caller could clear the page*

*dirty*

606 *\* bit, see a bunch of clean buffers and we'd end up with dirty buffers/clean*

607 *\* page on the dirty page list.* 608 *\**

609 *\* We use private_lock to lock against try_to_free_buffers while using the*

610 *\* page's buffer list. Also use this to protect against clean buffers being*

611 *\* added to the page after it was set dirty.* 612 *\**

613 *\* FIXME: may need to call -\>reservepage here as well. That's rather up to*

*the*

614 *\* address_space though.*

615 *\*/*

616 **bool block_dirty_folio**(**struct** address_space \*mapping, **struct** folio \*folio) 617 {

618 **struct** buffer_head \*head; 619 **bool** newly_dirty; 620

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

621 **spin_lock**(&mapping-\>private_lock); 622 head = **folio_buffers**(folio); 623 **if** (head) {

624 **struct** buffer_head \*bh = head;

625

626 **do** {

627 **set_buffer_dirty**(bh); 628 bh = bh-\>b_this_page; 629 } **while** (bh != head); 630 }

. . .

636 newly_dirty = !**folio_test_set_dirty**(folio); 637 **spin_unlock**(&mapping-\>private_lock);

638

639 **if** (newly_dirty)

640 **\_\_folio_mark_dirty**(folio, mapping, 1);

. . .

639 **if** (newly_dirty)

640 **\_\_mark_inode_dirty**(mapping-\>host, **I_DIRTY_PAGES**);

641

642 **return** newly_dirty; 643 }

 

*Listing 10-9:* fs/buffer.c: [*block_dirty_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n616)

 

This starts by performing some block logic, setting any attached

[struct buffer_head](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n61) objects to be marked dirty. See Section 9.10.1 for more

on buffers heads, but in brief this retrieves attached buffer heads mapping

disk blocks to the folio via [folio_buffers()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n182)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n182) iterates through each setting the

dirty flag.

This operation is performed with the [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)-\>private_lock

spin lock acquired, as any attached buffer heads are placed in the

[struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256)-\>private field.

The actual dirtying of the folio is relatively straightforward, invoking

[\_\_folio_mark_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2607) as discussed around Listing 10-1 above, which marks

the folios dirty in their xarray, and [\_\_mark_inode_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2363)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2363) shown in Listing 10-

2 which marks the actual inode dirty and adds it to the [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)

dirty list as discussed above.

These operations are only performed if the folio was not already marked

dirty, and the function returns a boolean to indicate whether this was the

case for convenience.

After the folio dirtying is complete, the page fault handler performs var-

ious house keeping tasks and then in [wp_page_shared()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3304) (see Section 6.9 and

Listing 6-39), calls [fault_dirty_shared_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2993) (see Listing 6-40), which executes

the important [balance_dirty_pages_ratelimited()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1949) function, which we cover in

Section 10.14 below and Listing **??**.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

This balancing is performed whenever folios are dirtied and is a key part

of the writeback mechanism. Since this always occurs we defer the descrip-

tion of this to Section 10.14.

 

**10.5 File Write Dirty Tracking**

 

[write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/read_write.c?h=v6.0#n646) syscall

 

[ksys_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/read_write.c?h=v6.0#n637)

 

[vfs_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/read_write.c?h=v6.0#n584)

 

[new_sync_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/read_write.c?h=v6.0#n491)

 

[call_write_iter()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2187)

 

f_op-\>write_iter()

 

[generic_file_write_iter()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3890) [generic_write_sync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2866)

If synced

[\_\_generic_file_write_iter()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3800) [vfs_fsync_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n180)

 

[generic_perform_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3701) [balance_dirty_pages_ratelimited()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1949)

 

a_ops-\>write_begin() [copy_page_from_iter_atomic()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/iov_iter.c?h=v6.0#n804) a_ops-\>write_end()

Typically Typically

[block_write_begin()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n2106) [\_\_block_write_begin()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n2053) [generic_write_end()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n2165)

 

[grab_cache_page_write_begin()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n111) [\_\_block_write_begin_int()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1968) [block_write_end()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n2129)

 

[pagecache_get_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n99) Read non-present folios into [\_\_block_commit_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n2061)

page cache as necessary

[\_\_filemap_get_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1914) [mark_buffer_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1079)

 

[\_\_set_page_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1054) [\_\_mark_inode_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2363)

 

[\_\_folio_mark_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2607)

 

*Figure 10-3: Typical File Write Dirty Page Tracking*

 

We have already discussed how files are read from the page cache using the

[read()](https://man7.org/linux/man-pages/man2/read.2.html) system call in Section 9.3. On write we perform essentially the same

task as a write page fault does (discussed in Section 10.12 above), only span-

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

ning the whole range of the write and copying data from the input user

buffer into the page cache folios.

Assuming a file system exposes the [struct file-\>f_op-\>write_iter](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) call-

back, then the write system call will call [ksys_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/read_write.c?h=v6.0#n626), which calls [vfs_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/read_write.c?h=v6.0#n564)

and [new_sync_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/read_write.c?h=v6.0#n481) in turn which invokes [struct file-\>f_op-\>write_iter](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) in

[call_write_iter()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2184).

Again, the file system is free to do what it wants, however in very many

cases file systems use the library function [generic_file_write_iter()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3889). This

in turn invokes [\_\_generic_file_write_iter()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3800) to perform the heavy lifting

(with the [struct inode-\>i_rwsem](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593) read/write semaphore held for write), and

[generic_write_sync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2866) to synchronise the data to disk if the write was config-

ured to do so.

We discuss write synchronisation in Section 10.6, and examine

[generic_write_sync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2866) in Listing 10-14 within that section.

We examine [\_\_generic_file_write_iter()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3800) in Listing 10-10, eliding out of

scope direct write logic.

 

3779 */\*\**

3780 *\* \_\_generic_file_write_iter - write data to a file* 3781 *\* @iocb:* *IO state structure (file, offset, etc.)* 3782 *\* @from:* *iov_iter with data to write* 3783 *\**

3784 *\* This function does all the work needed for actually writing data to a* 3785 *\* file. It does all basic checks, removes SUID from the file, updates* 3786 *\* modification times and calls proper subroutines depending on whether we*

3787 *\* do direct IO or a standard buffered write.* 3788 *\**

3789 *\* It expects i_rwsem to be grabbed unless we work on a block device or*

*similar*

3790 *\* object which does not need locking at all.* 3791 *\**

3792 *\* This function does \*not\* take care of syncing data in case of O_SYNC write.*

3793 *\* A caller has to handle it. This is mainly due to the fact that we want to*

3794 *\* avoid syncing under i_rwsem.* 3795 *\**

3796 *\* Return:*

3797 *\* \* number of bytes written, even for truncated writes* 3798 *\* \* negative error code if no data has been written at all* 3799 *\*/*

3800 **ssize_t \_\_generic_file_write_iter**(**struct** kiocb \*iocb, **struct** iov_iter \*from) 3801 {

3802 **struct** file \*file = iocb-\>ki_filp; 3803 **struct** address_space \*mapping = file-\>f_mapping; 3804 **struct** inode \*inode = mapping-\>host; 3805 **ssize_t** written = 0; 3806 **ssize_t** err; 3807 **ssize_t** status; 3808

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

3809 */\* We can write back this queue in page reclaim \*/* 3810 current-\>backing_dev_info = **inode_to_bdi**(inode); 3811 err = **file_remove_privs**(file); 3812 **if** (err)

3813 **goto out**; 3814

3815 err = **file_update_time**(file); 3816 **if** (err)

3817 **goto out**;

. . .

3866 written = **generic_perform_write**(iocb, from); 3867 **if** (**likely**(written \> 0)) 3868 iocb-\>ki_pos += written;

. . .

3870 **out**:

3871 current-\>backing_dev_info = **NULL**; 3872 **return** written ? written : err; 3873 }

 

*Listing 10-10:* mm/filemap.c: [*\_\_generic_file_write_iter()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3800)

 

This function first sets the current thread’s backing device field to

the inode’s backing device object obtained from [inode_to_bdi()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/backing-dev.c?h=v6.0#n977), removes any special file privileges that might exist such as suid or capabilities via

[file_remove_privs(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/inode.c?h=v6.0#n2052)updates mtime and ctime accordingly via [file_update_time()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/inode.c?h=v6.0#n2110)

before deferring to [generic_perform_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3701) to execute the write.

After the write is complete, the iterator write position is updated accord-

ingly and the current thread’s backing device field is cleared.

The actual ‘meat’ of the write is performed in [generic_perform_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3701)

which we examine in Listing 10-11 (eliding out of scope real time kernel logic and x86-64 irrelevant dcache flushes).

 

3701 **ssize_t generic_perform_write**(**struct** kiocb \*iocb, **struct** iov_iter \*i) 3702 {

3703 **struct** file \*file = iocb-\>ki_filp; 3704 loff_t pos = iocb-\>ki_pos; 3705 **struct** address_space \*mapping = file-\>f_mapping; 3706 **const struct** address_space_operations \*a_ops = mapping-\>a_ops; 3707 **long** status = 0;

3708 **ssize_t** written = 0; 3709

3710 **do** {

3711 **struct** page \*page; 3712 **unsigned long** offset; */\* Offset into pagecache page \*/* 3713 **unsigned long** bytes; */\* Bytes to write to page \*/* 3714 **size_t** copied; */\* Bytes copied from user \*/* 3715 **void** \*fsdata; 3716

3717 offset = (pos & (**PAGE_SIZE**- 1));

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

3718 bytes = **min_t**(**unsigned long**, **PAGE_SIZE**- offset, 3719 **iov_iter_count**(i)); 3720

3721 **again**:

3722 */\**

3723 *\* Bring in the user page that we will copy from \_first\_.* 3724 *\* Otherwise there's a nasty deadlock on copying from the* 3725 *\* same page as we're writing to, without it being marked* 3726 *\* up-to-date.* 3727 *\*/*

3728 **if** (**unlikely**(**fault_in_iov_iter_readable**(i, bytes) == bytes)) { 3729 status = -**EFAULT**; 3730 **break**; 3731 }

3732

3733 **if** (**fatal_signal_pending**(current)) { 3734 status = -**EINTR**; 3735 **break**; 3736 }

3737

3738 status = a_ops-\>**write_begin**(file, mapping, pos, bytes, 3739 &page, &fsdata); 3740 **if** (**unlikely**(status \< 0)) 3741 **break**;

. . .

3746 copied = **copy_page_from_iter_atomic**(page, offset, bytes, i);

. . .

3749 status = a_ops-\>**write_end**(file, mapping, pos, bytes, copied, 3750 page, fsdata); 3751 **if** (**unlikely**(status != copied)) { 3752 **iov_iter_revert**(i, copied - max(status, 0L)); 3753 **if** (**unlikely**(status \< 0)) 3754 **break**; 3755 }

. . .

3758 **if** (**unlikely**(status == 0)) { 3759 */\** 3760 *\* A short copy made -\>write_end() reject the* 3761 *\* thing entirely. Might be memory poisoning* 3762 *\* halfway through, might be a race with munmap,* 3763 *\* might be severe memory pressure.* 3764 *\*/* 3765 **if** (copied) 3766 bytes = copied; 3767 **goto again**; 3768 }

3769 pos += status;

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

3770 written += status; 3771

3772 **balance_dirty_pages_ratelimited**(mapping); 3773 } **while** (**iov_iter_count**(i)); 3774

3775 **return** written ? written : status; 3776 }

 

*Listing 10-11:* mm/filemap.c: [*generic_perform_write()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3701)

 

For brevity we will skip over some of the iterator housekeeping here

which we have already examined in detail in Section 9.3 for the read case, and focus on the parts of the function specific to the write operation.

The function is divided into three key areas, as highlighted in Fig-

ure 10-3—a ‘write begin’ operation, the copying of the data from the

user buffer into the page cache folio via [copy_page_from_iter_atomic()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/iov_iter.c?h=v6.0#n804)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/iov_iter.c?h=v6.0#n804) and a ‘write end’ operation which ultimately marks dirty folios in

the [struct address_space-\>i_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) xarray and adds dirty inodes to the

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>b_dirty dirty list.

As usual, the write begin operation,

[struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)-\>a_ops-\>write_begin (part of the

[struct address_space_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n356) callback object) is customisable by the file sys-

tem, but is often deferred to the generic library function [block_write_begin()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n2106),

which we examine in Listing 10-12.

 

2100 */\**

2101 *\* block_write_begin takes care of the basic task of block allocation and*

2102 *\* bringing partial write blocks uptodate first.* 2103 *\**

2104 *\* The filesystem needs to handle block truncation upon failure.* 2105 *\*/*

2106 **int block_write_begin**(**struct** address_space \*mapping, loff_t pos, **unsigned** len, 2107 **struct** page \*\*pagep, get_block_t \*get_block) 2108 {

2109 **pgoff_t** index = pos \>\> **PAGE_SHIFT**; 2110 **struct** page \*page; 2111 **int** status;

2112

2113 page = **grab_cache_page_write_begin**(mapping, index); 2114 **if** (!page)

2115 **return**-**ENOMEM**; 2116

2117 status = **\_\_block_write_begin**(page, pos, len, get_block); 2118 **if** (**unlikely**(status)) { 2119 **unlock_page**(page); 2120 **put_page**(page); 2121 page = **NULL**; 2122 }

2123

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2124 \*pagep = page;

2125 **return** status;

2126 }

 

*Listing 10-12:* fs/buffer.c: [*block_write_begin()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n2106)

 

This starts by actually pulling the page cache folio from the page cache

via [grab_cache_page_write_begin()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n111), shown in Listing **??**.

 

111 **struct** page \***grab_cache_page_write_begin**(**struct** address_space \*mapping, 112 **pgoff_t** index) 113 {

114 **unsigned** fgp_flags = **FGP_LOCK** \| **FGP_WRITE** \| **FGP_CREAT** \| **FGP_STABLE**;

115

116 **return pagecache_get_page**(mapping, index, fgp_flags, 117 **mapping_gfp_mask**(mapping)); 118 }

 

*Listing 10-13:* mm/folio-compat.c: [*grab_cache_page_write_begin()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n111)

 

The [pagecache_get_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n99) function this defers to ultimately wraps the

[\_\_filemap_get_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1914) function we examined in Section 9.5.3 and the Listings

starting with **??**.

This sets the [FGP_LOCK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n501), [FGP_WRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n503), [FGP_CREAT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n502) and [FGP_STABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n509) flags which

cause the returned the folio to be locked, to be writable, to be created if it

does not exist and for it to have had [folio_wait_stable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n3078) run after obtaining it

(see Listing 10-7 for more details on what this stability means).

This means that this function should either return the page cache entry

or NULL if we were unable to allocate a new one. Therefore [block_write_begin()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n2106)

exits with an ENOMEM error if this fails.

[block_write_begin()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n2106) defers its heavy lifting to [\_\_block_write_begin()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n2053) which,

in turn, defers its heavy lifting to [\_\_block_write_begin_int()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1968).

The [\_\_block_write_begin_int()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1968) function sets up [struct buffer_head](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n61) objects,

described in Section 9.10.1, which map disk blocks to folios and reads any

data into the page cache that has not previous been read before proceeding.

This function is very block I/O specific, so discussion of this is out of

scope. However see Section 9.10.4 for a brief discussion on block writes.

We now have all page cache folios present in memory and can

safely copy from the user buffer into the page cache entries via

[copy_page_from_iter_atomic()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/iov_iter.c?h=v6.0#n804). Once this is done, it’s time to mark the folios

and inodes dirty ready for writeback.

Again, the file system has a great deal of control over this, with the

write end callback being specified in [struct address_space-\>a_ops-\>write_end](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424).

However again file systems often defer this to the library function

[generic_write_end().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n2165)

The [generic_write_end()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n2165) function performs general housekeeping but oth-

erwise defers the heavy lifting to [block_write_end()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n2129)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n2129) which in turn defers the

key logic to [\_\_block_commit_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n2061)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n2061)

The [\_\_block_commit_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n2061) function is rather block I/O-specific, so we

defer examination of this to Section 9.10.4 and Listing 9-132.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

However the key thing to note is that on first dirtying a folio, this func-

tion invokes [mark_buffer_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1079). Again we defer discussion of this to Section

9.10.4 below, and in Listing 9-133.

However regardless we observe the key fact that, if newly dirty, the rel-

evant folio is marked dirty by [mark_buffer_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1079) using [\_\_set_page_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1054)

(which is simply a wrapper around [\_\_folio_mark_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2607) as discussed around

Listing 10-1 above. This marks folios dirty in their relevant xarray.

[mark_buffer_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1079) also marks the inode dirty via [\_\_mark_inode_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2363)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2363)

shown in Listing 10-2 above, which marks the actual inode dirty and adds it

to the [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) dirty list as previously discussed.

This explains clearly how writing a file results in page cache folios

being correctly marked dirty. However one more task is performed by

[generic_perform_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3701), which is to perform dirty page balancing via

[balance_dirty_pages_ratelimited(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1949)as discussed below in Section 10.14 and

Listing 10-79.

 

**10.6 Synchronising to Disk**

 

Sometimes a user needs to ensure that the page cache is synchronised to disk manually which ultimately invokes the core writeback logic described in

Section 10.10. This can be achieved through various system calls as shown in

Figure 10-4 (we elide the [sync_file_range()](https://man7.org/linux/man-pages/man2/sync_file_range.2.html) and [sync_file_range2()](https://man7.org/linux/man-pages/man2/sync_file_range2.2.html) system calls here as these are considered dangerous).

 

[fsync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n218) syscall [fdatasync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n223) syscall [sync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n111) syscall [syncfs()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n149) syscall

 

[do_fsync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n206) [sync_bdevs()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/bdev.c?h=v6.0#n1021) [ksys_sync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n97) [sync_filesystem()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n30)

 

[vfs_fsync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n200) [wakeup_flusher_threads()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2269) [sync_fs_one_sb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n80) [sync_inodes_one_sb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n74)

 

[vfs_fsync_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n180) [msync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/msync.c?h=v6.0#n32) syscall s_op-\>sync_fs() [sync_inodes_sb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2667)

 

f_op-\>fsync() [\*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2866) [generic_write_sync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2866) [filemap_write_and_wait()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n667) [writeback_inodes_sb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2637)

 

[generic_file_fsync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/libfs.c?h=v6.0#n1150) [blkdev_issue_flush()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/blk-flush.c?h=v6.0#n459) [sync_blockdev()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/bdev.c?h=v6.0#n193)

 

[\_\_generic_file_fsync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/libfs.c?h=v6.0#n1108) [sync_inode_metadata()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2736) [sync_blockdev_nowait()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/bdev.c?h=v6.0#n181)

 

[sync_mapping_buffers()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n541) [file_write_and_wait_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n767) [filemap_flush()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n452)

 

*Figure 10-4: Page Cache Synchronisation*

 

Key:

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

A

• Denotes that A is a an entry point to the synchronisation process.

B

A

• Denotes that B is a function which forms part of the actual write

B

back procedure described in Section 10.10.

 

\*Note that we also include the [generic_write_sync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2866) call, which we dis-

cussed in Section 10-3. This is invoked by [generic_file_write_iter()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3889) if a file

is opened with synchronisation options specified (and the file system opts to

use this general library function). We examine this function in Listing 10-14.

 

2861 */\**

2862 *\* Sync the bytes written if this was a synchronous write. Expect ki_pos* 2863 *\* to already be updated for the write, and will return either the amount* 2864 *\* of bytes passed in, or an error if syncing the file failed.* 2865 *\*/*

2866 **static inline ssize_t generic_write_sync**(**struct** kiocb \*iocb, **ssize_t** count) 2867 {

2868 **if** (**iocb_is_dsync**(iocb)) { 2869 **int** ret = **vfs_fsync_range**(iocb-\>ki_filp, 2870 iocb-\>ki_pos - count, iocb-\>ki_pos - 1, 2871 (iocb-\>ki_flags & **IOCB_SYNC**) ? 0 : 1); 2872 **if** (ret)

2873 **return** ret; 2874 }

2875

2876 **return** count;

2877 }

 

*Listing 10-14:* include/linux/fs.h: [*generic_write_sync()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2866)

 

This ultimately defers the operation to [vfs_fsync_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n180) which we de-

scribe below in Listing 10-19. The operation is performed when the itera-

tor described by [struct kiocb](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n341) is configured to synchronise as checked for by

[iocb_is_dsync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2855).

 

**10.7 sync**

 

The most general means of synchronising the page cache to disk is via the

[sync()](https://man7.org/linux/man-pages/man2/sync.2.html) syscall, which is familiar to most Linux users via the [sync](https://man7.org/linux/man-pages/man1/sync.1.html) CLI tool

which, if no parameters are specified, invokes this system call to perform a

general file system sync. We examine the [sync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n111) system call in Listing 10-15.

 

111 **SYSCALL_DEFINE0**(sync)

112 {

113 **ksys_sync**();

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

114 **return** 0;

115 }

 

*Listing 10-15:* fs/sync.c: [*sync()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n111) *system call*

 

This defers the core of the operation to [ksys_sync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n97) which we examine in

Listing 10-16.

Note that we keep track of the reason for writeback using the

[enum wb_reason](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n44) enumeration type. We indicate here that we are performing

writeback to perform synchronisation via [WB_REASON_SYNC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n47).

 

87 */\**

88 *\* Sync everything. We start by waking flusher threads so that most of* 89 *\* writeback runs on all devices in parallel. Then we sync all inodes reliably*

90 *\* which effectively also waits for all flusher threads to finish doing* 91 *\* writeback. At this point all data is on disk so metadata should be stable*

92 *\* and we tell filesystems to sync their metadata via -\>sync_fs() calls.* 93 *\* Finally, we writeout all block devices because some filesystems (e.g. ext2)*

94 *\* just write metadata (such as inodes or bitmaps) to block device page cache*

95 *\* and do not sync it on their own in -\>sync_fs().* 96 *\*/*

97 **void ksys_sync**(**void**)

98 {

99 **int** nowait = 0, wait = 1;

100

101 **wakeup_flusher_threads**(**WB_REASON_SYNC**); 102 **iterate_supers**(**sync_inodes_one_sb**, **NULL**); 103 **iterate_supers**(**sync_fs_one_sb**, &nowait); 104 **iterate_supers**(**sync_fs_one_sb**, &wait); 105 **sync_bdevs**(**false**); 106 **sync_bdevs**(**true**); 107 **if** (**unlikely**(**laptop_mode**)) 108 **laptop_sync_completion**(); 109 }

 

*Listing 10-16:* fs/sync.c: [*ksys_sync()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n97)

 

The function pipelines the synchronisation by first ensuring I/O is sub-

mitted for all pending writeback requests, before synchronising each I/O op-eration, waiting for each to complete one-by-one. This proceeds as follows:

 

**Wake up flusher threads** We start by waking up the background writeback

flushing kernel thread via [wakeup_flusher_threads()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2269)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2269) We examine the be-

haviour of these threads in Section 10.10 below. This should cause I/O operations to be submitted for all dirty inodes.

**Synchronously writeback** Iterate through each super block performing syn-

chronisation using [iterate_supers()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/super.c?h=v6.0#n710) to perform the iteration, synchronis-

ing data and filesystem metadata via [sync_inodes_one_sb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n74)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n74) This wraps a

call to [sync_inodes_sb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2667), which we examine in Section 10.10 and Listing

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

10-39. This is the key function which actually performs the synchronised writeback.

**Synchronise super block metadata** Ensure superblock metadata is syn-

chronised as implemented by the super block operation (provided

in the callback object of type [struct super_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2222)) specified in

[struct super_block-\>s_op-\>sync_fs](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n1451). This is wrapped by [sync_fs_one_sb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n80)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n80) As this concerns filesystem metadata we don’t examine it in detail.

**Synchronise blockdev device** Synchronise I/O operations caused by filesys-

tem metadata writes (see Section 9.10.2 for more on the raw blockdev

file system) via [sync_bdevs()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/bdev.c?h=v6.0#n1021), which is out of scope for the book.

**Laptop mode handling** This is a special mode which is out of scope of the

book.

 

**10.8 syncfs**

 

The [syncfs()](https://man7.org/linux/man-pages/man2/syncfs.2.html) system call performs the same task as [sync()](https://man7.org/linux/man-pages/man2/sync.2.html) only it operates

only on the file system containing the specified file. The [syncfs()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n149) system call

wraps a call to [sync_filesystem()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n30)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n30) described in Listing 10-17.

 

25 */\**

26 *\* Write out and wait upon all dirty data associated with this*

27 *\* superblock. Filesystem data as well as the underlying block*

28 *\* device. Takes the superblock lock.*

29 *\*/*

30 **int sync_filesystem**(**struct** super_block \*sb)

31 {

32 **int** ret = 0;

33

34 */\**

35 *\* We need to be protected against the filesystem going from*

36 *\* r/o to r/w or vice versa.*

37 *\*/*

38 WARN_ON(!**rwsem_is_locked**(&sb-\>s_umount));

39

40 */\**

41 *\* No point in syncing out anything if the filesystem is read-only.*

42 *\*/*

43 **if** (**sb_rdonly**(sb))

44 **return** 0;

45

46 */\**

47 *\* Do the filesystem syncing work. For simple filesystems*

48 *\* writeback_inodes_sb(sb) just dirties buffers with inodes so we have*

49 *\* to submit I/O for these buffers via sync_blockdev(). This also*

50 *\* speeds up the wait == 1 case since in that case write_inode()*

51 *\* methods call sync_dirty_buffer() and thus effectively write one*

*block*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

52 *\* at a time.*

53 *\*/*

54 **writeback_inodes_sb**(sb, **WB_REASON_SYNC**); 55 **if** (sb-\>s_op-\>**sync_fs**) { 56 ret = sb-\>s_op-\>**sync_fs**(sb, 0); 57 **if** (ret)

58 **return** ret; 59 }

60 ret = **sync_blockdev_nowait**(sb-\>s_bdev); 61 **if** (ret)

62 **return** ret; 63

64 **sync_inodes_sb**(sb); 65 **if** (sb-\>s_op-\>**sync_fs**) { 66 ret = sb-\>s_op-\>**sync_fs**(sb, 1); 67 **if** (ret)

68 **return** ret; 69 }

70 **return sync_blockdev**(sb-\>s_bdev); 71 }

 

*Listing 10-17:* fs/sync.c: [*sync_filesystem()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n30)

 

This proceeds only if the super block is read/write (naturally), checked

by [sb_rdonly()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2297)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2297) It follows the pattern that [ksys_sync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n97) establishes of initiating background writeback before performing blocking writeback.

 

**Initiate folio writeback** We begin the process of writing back on this super

block via [writeback_inodes_sb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2637)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2637) This is performed asynchronously. See

Listing 10-40 in Section 10.10 for details.

**Initiate super block synchronisation** As in [ksys_sync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n97) super block meta-

data synchronisation is performed via s_op-\>sync_fs, in this instance without waiting on the process to complete.

**Initiate blockdev synchronisation** File system metadata and data written

raw to the block device is stored in the blockdev file system, described

in Section 9.10.2. The [sync_blockdev_nowait()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/bdev.c?h=v6.0#n181) function wraps a call to

[filemap_flush()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n452) on the blockdev inode to trigger asynchronous writeback

on this data. See Listing 10-68 in Section 10.10 for details.

**Wait on folio writeback** We now perform writeback of dirty folios, waiting

on each to operation to complete in [sync_inodes_sb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2667) as shown in Listing

10-39 and Section 10.10.

**Wait on super block synchronisation** We invoke s_op-\>sync_fs() again, only

specifying that this should be done synchronously waiting on each oper-ation. This synchronises super block metadata.

**Wait on blockdev synchronisation** Finally we wait on writeback for

the blockdev file system describing the block device the super

block is mounted on via [sync_blockdev()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/bdev.c?h=v6.0#n193)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/bdev.c?h=v6.0#n193) This ultimately invokes

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

[filemap_write_and_wait()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n58) which invokes [filemap_write_and_wait_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n667) for

the entire address range. We explore this function in Listing 10-71 and

Section 10.10.

 

**10.9 fsync**

 

Synchronisation can be performed on a file level as well as on a general or

file system level. This is achieved via either the [fsync()](https://man7.org/linux/man-pages/man2/fsync.2.html) or [fdatasync()](https://man7.org/linux/man-pages/man2/fdatasync.2.html) system

calls, with kernel implementations in [fsync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n218) and [fdatasync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n223) respectively.

Both of these functions ultimately invoke [do_fsync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n206) as shown in Listing

10-18, with the former setting datasync to 0 (i.e. false) and the latter setting it

to 1 (i.e. true). This indicates whether filesystem metadata should be written

back alongside data folios (the former case) or not (the latter case).

 

206 **static int do_fsync**(**unsigned int** fd, **int** datasync) 207 {

208 **struct** fd f = **fdget**(fd); 209 **int** ret = -**EBADF**;

210

211 **if** (f.file) {

212 ret = **vfs_fsync**(f.file, datasync); 213 **fdput**(f); 214 }

215 **return** ret;

216 }

 

*Listing 10-18:* fs/sync.c: [*do_fsync()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n206)

 

This increments the reference count for the [struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) associated with

the supplied fd if valid and deferring the operation to [vfs_fsync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n200), before

dropping the reference count after this is complete and returning any error

that arose.

The [vfs_fsync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n200) function is a simple wrapper around the

[vfs_fsync_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n180), passing an input range specifying that the entirety of the

file should be synchronised. We examine this function in Listing 10-19 (elid-

ing out of scope dirty time logic).

 

169 */\*\**

170 *\* vfs_fsync_range - helper to sync a range of data & metadata to disk* 171 *\* @file:* *file to sync* 172 *\* @start:* *offset in bytes of the beginning of data range to sync* 173 *\* @end:* *offset in bytes of the end of data range (inclusive)* 174 *\* @datasync:* *perform only datasync* 175 *\**

176 *\* Write back data in range @start..@end and metadata for @file to disk. If*

177 *\* @datasync is set only metadata needed to access modified file data is* 178 *\* written.*

179 *\*/*

180 **int vfs_fsync_range**(**struct** file \*file, loff_t start, loff_t end, **int** datasync)

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

181 {

182 **struct** inode \*inode = file-\>f_mapping-\>host; 183

184 **if** (!file-\>f_op-\>**fsync**) 185 **return**-**EINVAL**;

. . .

188 **return** file-\>f_op-\>**fsync**(file, start, end, datasync); 189 }

 

*Listing 10-19:* fs/sync.c: [*vfs_fsync_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n180)

 

This defers the fsync operation to the [struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940)-\>f_op-\>fsync function

from its [struct file_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2093) callback object.

As always, file systems are able to implement things however they choose,

however typically they invoke a library function provided for this operation,

[generic_file_fsync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/libfs.c?h=v6.0#n1150) shown in Listing **??**.

 

1140 */\*\**

1141 *\* generic_file_fsync - generic fsync implementation for simple filesystems*

1142 *\** *with flush* 1143 *\* @file:* *file to synchronize* 1144 *\* @start:* *start offset in bytes* 1145 *\* @end:* *end offset in bytes (inclusive)* 1146 *\* @datasync:* *only synchronize essential metadata if true* 1147 *\**

1148 *\*/*

1149

1150 **int generic_file_fsync**(**struct** file \*file, loff_t start, loff_t end, 1151 **int** datasync) 1152 {

1153 **struct** inode \*inode = file-\>f_mapping-\>host; 1154 **int** err;

1155

1156 err = **\_\_generic_file_fsync**(file, start, end, datasync); 1157 **if** (err)

1158 **return** err; 1159 **return blkdev_issue_flush**(inode-\>i_sb-\>s_bdev); 1160 }

 

*Listing 10-20:* fs/libfs.c: [*generic_file_fsync()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/libfs.c?h=v6.0#n1150)

 

This defers the heavy lifting of the operation to [\_\_generic_file_fsync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/libfs.c?h=v6.0#n1108),

issuing a block device flush operation on the underlying block device via

[blkdev_issue_flush()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/blk-flush.c?h=v6.0#n459) afterwards, shown in Listing 9-134 described in Section

9.10.5.

We examine [\_\_generic_file_fsync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/libfs.c?h=v6.0#n1108) in Listing 10-21.

 

1096 */\*\**

1097 *\* \_\_generic_file_fsync - generic fsync implementation for simple filesystems*

1098 *\**

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1099 *\* @file:* *file to synchronize* 1100 *\* @start:* *start offset in bytes* 1101 *\* @end:* *end offset in bytes (inclusive)* 1102 *\* @datasync:* *only synchronize essential metadata if true* 1103 *\**

1104 *\* This is a generic implementation of the fsync method for simple* 1105 *\* filesystems which track all non-inode metadata in the buffers list* 1106 *\* hanging off the address_space structure.* 1107 *\*/*

1108 **int \_\_generic_file_fsync**(**struct** file \*file, loff_t start, loff_t end, 1109 **int** datasync) 1110 {

1111 **struct** inode \*inode = file-\>f_mapping-\>host; 1112 **int** err;

1113 **int** ret;

1114

1115 err = **file_write_and_wait_range**(file, start, end); 1116 **if** (err)

1117 **return** err; 1118

1119 **inode_lock**(inode); 1120 ret = **sync_mapping_buffers**(inode-\>i_mapping); 1121 **if** (!(inode-\>i_state & **I_DIRTY_ALL**)) 1122 **goto out**; 1123 **if** (datasync && !(inode-\>i_state & **I_DIRTY_DATASYNC**)) 1124 **goto out**; 1125

1126 err = **sync_inode_metadata**(inode, 1); 1127 **if** (ret == 0)

1128 ret = err; 1129

1130 **out**:

1131 **inode_unlock**(inode); 1132 */\* check and advance again to catch errors after syncing out buffers*

*\*/*

1133 err = **file_check_and_advance_wb_err**(file); 1134 **if** (ret == 0)

1135 ret = err; 1136 **return** ret;

1137 }

 

*Listing 10-21:* fs/libfs.c: [*\_\_generic_file_fsync()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/libfs.c?h=v6.0#n1108)

 

This performs the write via [file_write_and_wait_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n767) which we examine

in Listing 10-74 and Section 10.10.

We acquire the inode lock and submit any outstanding I/O related to the

file via [sync_mapping_buffers()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n541)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n541) which is out of scope for the book.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

Now we have the inode lock we can then check the current state of

the inode to determine whether to write back inode-specific metadata via

[sync_inode_metadata()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2736) — if the inode is not dirty at all then there is no need, equally if the user has not specified that only data pages should be written back (as specified by the datasync parameter) we do write back.

We also cover the edge case where the caller specified that we should

only writeback data pages but the inode is still marked dirty for data pages, then it is appropriate to write this metadata back to disk.

Finally, we retrieve any errors that arose during the operation and return

them to the caller via [file_check_and_advance_wb_err()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n723)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n723)

 

**10.10 Writing Back to Disk**

 

The code paths which perform the ultimate writeback operation to disk are

shown in Figure 10-5.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

[do_writepages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2457)

 

a_ops-\>writepages()

Typically

[generic_writepages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2439)

 

[write_cache_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2281) [clear_page_dirty_for_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n72)

 

[\_\_writepage()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2420) [folio_clear_dirty_for_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2826)

 

Mark folio clean, make

a_ops-\>writepage()

mappings readonly

Typically

[block_write_full_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n2619) Asynchronous I/O completed

 

[set_page_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n54) [\_\_block_write_full_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1709) [end_page_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n24)

See Section 9.10.4 for block-level writeback.

 

[folio_start_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n765) [folio_end_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1599)

 

[\_\_folio_start_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2955) [\_\_folio_end_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2910)

 

Clear folio [PG_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n116) flag,

Set folio [PG_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n116) flag, Clear [PAGECACHE_TAG_WRITEBACK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n453) flag,

Clear [PAGECACHE_TAG_DIRTY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n453) flag, Remove inode from

Set [PAGECACHE_TAG_WRITEBACK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n453) flag,

i_sb-\>s_inodes_wb.

Add inode to i_sb-\>s_inodes_wb.

 

*Figure 10-5: Core Writeback Code Paths*

 

There are two principle means through which data is ultimately written

back to disk—periodically by background flusher threads, or directly through

a flush operation (see Section 10.6 for details on how this can be performed

via system call).

However from the kernel’s perspective there is a more important

distinction—those operations which span file systems, and are dealt with

by the background flusher thread (confusingly spanning both background

writeback and general synchronisation), which we explore in Section 10.11,

and those which are a product of file synchronisation which we explore in

Section 10.13.

Both however must interact with block device (BDI) dirty tracking. Re-

call from figure 10-1 that each BDI has one or more [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)

objects associated with it, each of which independently represents pending

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

writeback work which can be throttled according to the current I/O band-width of the block device.

The only instance in which there will be more [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) objects

than BDIs is where memory cgroups are utilised for writeback. This is out of scope for the book.

We examine the [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) type in Listing 10-22, eliding out of

scope cgroup logic and dirty time stamp tracking.

 

83 */\**

84 *\* Each wb (bdi_writeback) can perform writeback operations, is measured* 85 *\* and throttled, independently. Without cgroup writeback, each bdi* 86 *\* (bdi_writeback) is served by its embedded bdi-\>wb.*

. . .

104 *\*/*

105 **struct** bdi_writeback {

106 **struct** backing_dev_info \*bdi; */\* our parent bdi \*/* 107

108 **unsigned long** state; */\* Always use atomic bitops on this \*/* 109 **unsigned long** last_old_flush; */\* last old data flush \*/* 110

111 **struct** list_head b_dirty; */\* dirty inodes \*/* 112 **struct** list_head b_io; */\* parked for writeback \*/* 113 **struct** list_head b_more_io; */\* parked for more writeback \*/*

. . .

115 **spinlock_t** list_lock; */\* protects the b\_\* lists \*/* 116

117 **atomic_t** writeback_inodes; */\* number of inodes under writeback \*/* 118 **struct** percpu_counter stat\[**NR_WB_STAT_ITEMS**\]; 119

120 **unsigned long** bw_time_stamp; */\* last time write bw is updated \*/* 121 **unsigned long** dirtied_stamp; 122 **unsigned long** written_stamp; */\* pages written at bw_time_stamp \*/* 123 **unsigned long** write_bandwidth; */\* the estimated write bandwidth \*/* 124 **unsigned long** avg_write_bandwidth; */\* further smoothed write bw, \> 0*

*\*/*

125

126 */\**

127 *\* The base dirty throttle rate, re-calculated on every 200ms.* 128 *\* All the bdi tasks' dirty rate will be curbed under it.* 129 *\* @dirty_ratelimit tracks the estimated @balanced_dirty_ratelimit*

130 *\* in small steps and is much more smooth/stable than the latter.* 131 *\*/*

132 **unsigned long** dirty_ratelimit; 133 **unsigned long** balanced_dirty_ratelimit; 134

135 **struct** fprop_local_percpu completions; 136 **int** dirty_exceeded; 137 **enum** wb_reason start_all_reason;

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

138

139 **spinlock_t** work_lock; */\* protects work_list & dwork*

*scheduling \*/*

140 **struct** list_head work_list; 141 **struct** delayed_work dwork; */\* work item used for writeback \*/* 142 **struct** delayed_work bw_dwork; */\* work item used for bandwidth*

*estimate \*/*

143

144 **unsigned long** dirty_sleep; */\* last wait \*/*

145

146 **struct** list_head bdi_node; */\* anchored at bdi-\>wb_list \*/*

. . .

163 };

 

*Listing 10-22:* include/linux/backing-dev-defs.h: [*struct bdi_writeback*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)

 

We already discussed the b_dirty list in Section 10.1, which is the key list

which keeps track of all the dirty inodes requiring writeback.

We also maintain a great many statistics which are used to maintain

flusher thread behaviour as described at the start of Section **??**, which we

will discuss shortly when examining background writeback, and the process

of balancing dirty writes as a whole in Section 10.14 below.

The key fields for background writeback are b_io and b_more_io which

keep track of inodes which have been scheduled for writeback immediately,

and those which will be processed on the next background flush interval.

See Section 10.11 for a detailed examination of the background writeback

process.

Ultimately writeback is performed against specific inodes, with

details as to how the writeback should be performed expressed via a

[struct writeback_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n50) object (see Listing 10-24) in [do_writepages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2457) (see List-

ing 10-23).

However, when specifying writeback spanning a subset of dirty inodes

with specific behaviour as we do for background writeback (see Section

10.11) and synchronisation (see Section 10.6), we need to specify required

writeback behaviour using only a subset of [struct writeback_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n50) fields.

This is achieved by the [struct wb_writeback_work](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42) type (we examine

this in Section 10.11, see Listing 10-38) which is ultimately passed into

[wb_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1988) (see Listing 10-55 in the same section).

When work in addition to the background writeback described in Section

10.11 is required to be performed (for instance by synchronisation), these

are specified in the [struct bdi_writeback-\>work_list](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) field and processed by

[wb_do_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2174) (see Listing 10-50 in Section 10.11) when the background

flusher thread is awoken.

No matter what path is taken, the actual process of writeback is per-

formed in [do_writepages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2457) as shown in Listing 10-23.

 

2457 **int do_writepages**(**struct** address_space \*mapping, **struct** writeback_control \*wbc

)

2458 {

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2459 **int** ret;

2460 **struct** bdi_writeback \*wb; 2461

2462 **if** (wbc-\>nr_to_write \<= 0) 2463 **return** 0; 2464 wb = **inode_to_wb_wbc**(mapping-\>host, wbc); 2465 **wb_bandwidth_estimate_start**(wb); 2466 **while** (1) {

2467 **if** (mapping-\>a_ops-\>**writepages**) 2468 ret = mapping-\>a_ops-\>**writepages**(mapping, wbc); 2469 **else**

2470 ret = **generic_writepages**(mapping, wbc); 2471 **if** ((ret != -**ENOMEM**) \|\| (wbc-\>sync_mode != **WB_SYNC_ALL**)) 2472 **break**; 2473

2474 */\**

2475 *\* Lacking an allocation context or the locality or writeback*

2476 *\* state of any of the inode's pages, throttle based on* 2477 *\* writeback activity on the local node. It's as good a* 2478 *\* guess as any.* 2479 *\*/*

2480 **reclaim_throttle**(**NODE_DATA**(**numa_node_id**()), 2481 **VMSCAN_THROTTLE_WRITEBACK**); 2482 }

2483 */\**

2484 *\* Usually few pages are written by now from those we've just*

*submitted*

2485 *\* but if there's constant writeback being submitted, this makes sure*

2486 *\* writeback bandwidth is updated once in a while.* 2487 *\*/*

2488 **if** (**time_is_before_jiffies**(**READ_ONCE**(wb-\>bw_time_stamp) + 2489 **BANDWIDTH_INTERVAL**)) 2490 **wb_update_bandwidth**(wb); 2491 **return** ret;

2492 }

 

*Listing 10-23:* mm/page-writeback.c: [*do_writepages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2457)

 

We start by obtaining the [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) object associated with this

[struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) page cache object using [inode_to_wb_wbc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev.h?h=v6.0#n251).

We maintain an estimate on writeback bandwidth using per-CPU

statistics for the number of dirtied and written base pages, maintained in

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>stat array.

Before writeback we set the current dirtied and written base pages in the

dirtied_stamp and written_stamp fields and the last updated timestamp field

bw_time_stamp via [wb_bandwidth_estimate_start()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1383)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1383)

We then enter a loop in which the actual write operation is deferred to

the [struct address_space-\>a_ops-\>writepages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) handler (from the page cache en-

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

try’s [struct address_space_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n356) callback object), or [generic_writepages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2439) if

the file system does not specify one.

The loop continues only if the writepages operation failed due to lack of

memory and the [struct writeback_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n50)[-specif](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n50)ied synchronisation mode is

set to [WB_SYNC_ALL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n42)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n42) i.e. indicating that the caller expects the operation to be

complete on return.

In this instance reclaim behaviour is adjusted to account for this scenario

in [reclaim_throttle()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1104) (see the chapter on reclaim for more details on this).

Finally, if we are within the bandwidth interval [BANDWIDTH_INTERVAL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n58), hard-

coded to 200ms, we update the bandwidth statistics via [wb_update_bandwidth()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1373)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1373)

Regardless of whether [generic_writepages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2439) is used or a file

system-supplied callback is used, an ordinary file systems will in-

voke [write_cache_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2281) shown in Listing 10-25, passing in a call-

back which writes to each page of function type [writepage_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n377)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n377) i.e.

writepage(struct page \*page, struct writeback_control \*wbc, void \*data).

Before examining [write_cache_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2281) let’s examine

[struct writeback_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n50) in Listing 10-24 (eliding out of scope cgroup

and swap plug logic).

 

45 */\**

46 *\* A control structure which tells the writeback code what to do. These are*

47 *\* always on the stack, and hence need no locking. They are always*

*initialised*

48 *\* in a manner such that unspecified fields are set to zero.*

49 *\*/*

50 **struct** writeback_control {

51 **long** nr_to_write; */\* Write this many pages, and*

*decrement*

52 *this for each page written \*/*

53 **long** pages_skipped; */\* Pages which were not written \*/*

54

55 */\**

56 *\* For a_ops-\>writepages(): if start or end are non-zero then this is*

57 *\* a hint that the filesystem need only write out the pages inside*

*that*

58 *\* byterange. The byte at \`end' is included in the writeout request.*

59 *\*/*

60 **loff_t** range_start;

61 **loff_t** range_end;

62

63 **enum** writeback_sync_modes sync_mode;

64

65 **unsigned** for_kupdate:1; */\* A kupdate writeback \*/*

66 **unsigned** for_background:1; */\* A background writeback \*/*

67 **unsigned** tagged_writepages:1; */\* tag-and-write to avoid livelock \*/*

68 **unsigned** for_reclaim:1; */\* Invoked from the page allocator \*/*

69 **unsigned** range_cyclic:1; */\* range_start is cyclic \*/*

70 **unsigned** for_sync:1; */\* sync(2) WB_SYNC_ALL writeback \*/*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

71 **unsigned** unpinned_fscache_wb:1; */\* Cleared I_PINNING_FSCACHE_WB \*/*

. . .

102 };

 

*Listing 10-24:* include/linux/writeback.h: [*struct writeback_control*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n50)

Examining each field:

 

**nr_to_write** The number of pages to write, or LONG_MAX if all dirty pages

should be written. This is ignored if the synchronisation mode is set to

anything other than [WB_SYNC_NONE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n41), i.e. if synchronisation is required on each writeback.

**pages_skipped** The number of pages which were not able to be written,

accumulated through the writeback operation.

**range_start** The start of the range to be written, or 0 if all dirty pages in the

inode should be written.

**range_end** The inclusive end of the range, or LLONG_MAX if all dirty pages in

the inode should be written.

**sync_mode** Indicates whether the kernel should wait on each write. This

field is of the type [enum writeback_sync_modes](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n40). If set to [WB_SYNC_NONE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n41) no sync

is performed, otherwise if set to [WB_SYNC_ALL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n42) the kernel will wait after each writeback.

**for_kupdate** Bit flag indicating that this is an ordinary background flush

periodically writing back inodes older than vm.dirty_expire_centisecs.

See Section 10.11.

**for_background** Bit flag indicating that either the ratio between dirty pages

and available memory has exceeded vm.dirty_background_ratio or the sum of dirty bytes has exceeded v.dirty_background_bytes and therefore write-back is required until this is resolved.

**tagged_writepages** Bit field used to avoid a livelock situation where more

and more pages are marked dirty faster than we can write them back.

This causes all entries in the [struct address_space-\>i_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) xarray tagged

with [PAGECACHE_TAG_DIRTY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n452) to be tagged with [PAGECACHE_TAG_TOWRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n452) and for

these to be looked up by [write_cache_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2281) rather than dirty-tagged pages.

**for_reclaim** Bit field that indicates that the writeback has been triggered by

reclaim in [pageout()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1215). See the reclaim chapter for more details.

**range_cyclic** Bit field that indicates that rather than specifying a range

over which to scan in range_start and range_end, we operate cyclically

over the entire range of pages within the [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) using its writeback_index field to store the page offset of the next page to write back.

**for_sync** Bit field indicating that a full sync is being performed. When

queueing I/O via [queue_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1425) as part of the background writeback pro-cess, if this flag is set, the expire time is not taken into account. In ad-

dition, [\_\_writeback_single_inode()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1576) does not wait on writeout as a calling

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

function handles this separately. This is set in [sync_inodes_sb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2667) and indi-

cates that the user has invoked a [sync()](https://man7.org/linux/man-pages/man2/sync.2.html) system call.

**unpinned_fscache_wb** Indicates that an underlying folio is pinned by the

file system. Out of scope for the book.

 

Now we have examined the [struct writeback_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n50) type, we can examine

how it is used on writeback in [write_cache_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2281) in Listing 10-25 (eliding

out of scope trace logic).

 

2250 */\*\**

2251 *\* write_cache_pages - walk the list of dirty pages of the given address space*

*and write all of them.*

2252 *\* @mapping: address space structure to write* 2253 *\* @wbc: subtract the number of written pages from \*@wbc-\>nr_to_write* 2254 *\* @writepage: function called for each page* 2255 *\* @data: data passed to writepage function* 2256 *\**

2257 *\* If a page is already under I/O, write_cache_pages() skips it, even* 2258 *\* if it's dirty. This is desirable behaviour for memory-cleaning writeback,*

2259 *\* but it is INCORRECT for data-integrity system calls such as fsync(). fsync*

*()*

2260 *\* and msync() need to guarantee that all the data which was dirty at the time*

2261 *\* the call was made get new I/O started against them. If wbc-\>sync_mode is*

2262 *\* WB_SYNC_ALL then we were called for data integrity and we must wait for*

2263 *\* existing IO to complete.* 2264 *\**

2265 *\* To avoid livelocks (when other process dirties new pages), we first tag*

2266 *\* pages which should be written back with TOWRITE tag and only then start*

2267 *\* writing them. For data-integrity sync we have to be careful so that we do*

2268 *\* not miss some pages (e.g., because some other process has cleared TOWRITE*

2269 *\* tag we set). The rule we follow is that TOWRITE tag can be cleared only*

2270 *\* by the process clearing the DIRTY tag (and submitting the page for IO).*

2271 *\**

2272 *\* To avoid deadlocks between range_cyclic writeback and callers that hold*

2273 *\* pages in PageWriteback to aggregate IO until write_cache_pages() returns,*

2274 *\* we do not loop back to the start of the file. Doing so causes a page* 2275 *\* lock/page writeback access order inversion - we should only ever lock* 2276 *\* multiple pages in ascending page-\>index order, and looping back to the*

*start*

2277 *\* of the file violates that rule and causes deadlocks.* 2278 *\**

2279 *\* Return: %0 on success, negative error code otherwise* 2280 *\*/*

2281 **int write_cache_pages**(**struct** address_space \*mapping, 2282 **struct** writeback_control \*wbc, writepage_t **writepage**, 2283 **void** \*data) 2284 {

2285 **int** ret = 0;

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2286 **int** done = 0;

2287 **int** error;

2288 **struct** pagevec pvec; 2289 **int** nr_pages;

2290 **pgoff_t** index;

2291 **pgoff_t** end; */\* Inclusive \*/* 2292 **pgoff_t** done_index; 2293 **int** range_whole = 0; 2294 **xa_mark_t** tag;

2295

2296 **pagevec_init**(&pvec); 2297 **if** (wbc-\>range_cyclic) { 2298 index = mapping-\>writeback_index; */\* prev offset \*/* 2299 end = -1; 2300 } **else** {

2301 index = wbc-\>range_start \>\> **PAGE_SHIFT**; 2302 end = wbc-\>range_end \>\> **PAGE_SHIFT**; 2303 **if** (wbc-\>range_start == 0 && wbc-\>range_end == **LLONG_MAX**) 2304 range_whole = 1; 2305 }

2306 **if** (wbc-\>sync_mode == **WB_SYNC_ALL** \|\| wbc-\>tagged_writepages) { 2307 **tag_pages_for_writeback**(mapping, index, end); 2308 tag = **PAGECACHE_TAG_TOWRITE**; 2309 } **else** {

2310 tag = **PAGECACHE_TAG_DIRTY**; 2311 }

2312 done_index = index;

 

*Listing 10-25:* mm/page-writeback.c: [*write_cache_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2281) *initialisation*

 

Note that the function is passed a void \* field in data which contains

user-defined data that file systems which perform custom invocations of this function can use to thread a value through to the writepage function.

In [generic_writepages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2439) the [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) mapping object is placed in this field.

The function operations on batches of pages utilising the [struct pagevec](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n22)

type. This is a legacy version of the [struct folio_batch](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n74) type (see Section

11.7 for more details on this type), but behaves identically other than stor-

ing [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) objects rather than [struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) ones. We initialise this via

[pagevec_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n38), and it contains up to [PAGEVEC_SIZE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n15) (hardcoded to 15) pages.

We then set the start and end page indexes for the range we will explore

in index and end respectively (note that end is an inclusive bound).

If the operation is cyclic, we use [struct address_space-\>writeback_index](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) to

retrieve the last successfully written to page index, and set the unsigned long end object to -1, which is converted to the largest value the type can repre-sent, indicating we should examine the whole range.

In non-cyclic mode, we use the range_start and range_end fields of the

[struct writeback_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n50) argument to determine which page indexes to span,

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

setting range_whole to true if this implies a scan of the whole of the page

cache object.

Finally, we determine how to identify dirty pages for writeback—if

[struct writeback_control-\>tagged_writepages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n50) is set or if a full synchronisation is

to be performed (which will be slow as we wait on each writeout), we imme-

diately update all currently dirty folios setting the [PAGECACHE_TAG_TOWRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n452) xar-

ray tag via [tag_pages_for_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2228), and set tag to whichever tag we should

look up.

As discussed above, we do this to avoid live locks where a process dirties

pages faster than we can write them back.

Next we examine the core loop of this function in Listing 10-26.

 

2313 **while** (!done && (index \<= end)) { 2314 **int** i;

2315

2316 nr_pages = **pagevec_lookup_range_tag**(&pvec, mapping, &index,

end,

2317 tag); 2318 **if** (nr_pages == 0) 2319 **break**; 2320

2321 **for** (i = 0; i \< nr_pages; i++) { 2322 **struct** page \*page = pvec.pages\[i\]; 2323

2324 done_index = page-\>index; 2325

2326 **lock_page**(page); 2327

2328 */\** 2329 *\* Page truncated or invalidated. We can freely skip*

*it*

2330 *\* then, even for data integrity operations: the page*

2331 *\* has disappeared concurrently, so there could be no*

2332 *\* real expectation of this data integrity operation*

2333 *\* even if there is now a new, dirty page at the same*

2334 *\* pagecache address.* 2335 *\*/* 2336 **if** (**unlikely**(page-\>mapping != mapping)) { 2337 **continue_unlock**:

2338 **unlock_page**(page); 2339 **continue**; 2340 } 2341

2342 **if** (!**PageDirty**(page)) { 2343 */\* someone wrote it for us \*/* 2344 **goto continue_unlock**; 2345 } 2346

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2347 **if** (**PageWriteback**(page)) { 2348 **if** (wbc-\>sync_mode != **WB_SYNC_NONE**) 2349 **wait_on_page_writeback**(page); 2350 **else** 2351 **goto continue_unlock**; 2352 } 2353

2354 **BUG_ON**(**PageWriteback**(page)); 2355 **if** (!**clear_page_dirty_for_io**(page)) 2356 **goto continue_unlock**;

. . .

2359 error = (\***writepage**)(page, wbc, data); 2360 **if** (**unlikely**(error)) { 2361 */\** 2362 *\* Handle errors according to the type of*

2363 *\* writeback. There's no need to continue for*

2364 *\* background writeback. Just push done_index*

2365 *\* past this page so media errors won't choke*

2366 *\* writeout for the entire file. For integrity*

2367 *\* writeback, we must process the entire dirty*

2368 *\* set regardless of errors because the fs may*

2369 *\* still have state to clear for each page. In*

2370 *\* that case we continue processing and return*

2371 *\* the first error.* 2372 *\*/* 2373 **if** (error == **AOP_WRITEPAGE_ACTIVATE**) { 2374 **unlock_page**(page); 2375 error = 0; 2376 } **else if** (wbc-\>sync_mode != **WB_SYNC_ALL**) { 2377 ret = error; 2378 done_index = page-\>index + 1; 2379 done = 1; 2380 **break**; 2381 } 2382 **if** (!ret) 2383 ret = error; 2384 } 2385

2386 */\** 2387 *\* We stop writing back only if we are not doing* 2388 *\* integrity sync. In case of integrity sync we have*

*to*

2389 *\* keep going until we have written all the pages*

2390 *\* we tagged for writeback prior to entering this loop*

*.*

2391 *\*/* 2392 **if** (--wbc-\>nr_to_write \<= 0 &&

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2393 wbc-\>sync_mode == **WB_SYNC_NONE**) { 2394 done = 1; 2395 **break**; 2396 } 2397 }

2398 **pagevec_release**(&pvec); 2399 **cond_resched**(); 2400 }

 

*Listing 10-26:* mm/page-writeback.c: [*write_cache_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2281) *main loop*

This starts by looking up page cache entries in the specified range via

[pagevec_lookup_range_tag()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n1058) which wraps a call to [find_get_pages_range_tag()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2272)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2272)

which retrieves pages with the specified tag via [find_get_entry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2001)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2001) shown in

Listing 9-41 and Section 9.5.1, setting index to the lower bound at which the

next search should commence.

If no pages were retrieved we exit the loop, otherwise we iterate through

each retrieved page, locking them as they go. We perform a typical check

as, prior to the lock, the page may have been truncated beneath us (and the

[struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) we are examining may have been used for another purpose) by

ensuring [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72)-\>mapping is equal to the expected page cache mapping.

If not, we unlock the page and move on to the next page.

Note that, since we’ve updated index field, we track the last completed

page index in the done_index field.

We are about to mark the folio clean for writeback, so if it is currently

marked clean, the write has already been performed by somebody else and

we can simply skip to the next page.

Equally, if the folio is marked with the writeback flag, which is set by the

block I/O logic once the writepage has been submitted, then a parallel write-

back is in action.

It is however possible for folios to be re-dirtied midway through a write-

back operation, so we must handle this scenario correctly.

If this is a synchronous operation we wait for this to complete via

[wait_on_page_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n30) (see Section 9.11 for more details on waiting on fo-

lios) since we need to ensure this operation has successfully completed. Oth-

erwise, we simply move on to the next page, and rely on the newly dirtied

page being written back once expired.

After a sanity check to ensure that the page no longer has the writeback

flag set, we move on to one of the most critical parts of the operation. In or-

der to maintain dirty tracking as described in Section 10.1, we must mark

the page mappings of all mapped pages being written read-only once write-

back begins before clearing the folio’s dirty flag.

This way, if a file write or file-backed page fault occurs in the meantime,

we redirty the folio and correctly mark it for writeback at a late point. This is

achieved by [clear_page_dirty_for_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n72), which wraps [folio_clear_dirty_for_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2826)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2826)

which we will explore shortly in detail in Listing 10-30.

 

**N O T E** When a page fault occurs, most modern file systems and block devices will not wait

for a folio undergoing writeback to complete. Rather, they rely on the fact that any

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

further writes to the folio will cause it to be marked dirty and thus written back again at a later date. This does mean that an unfortunate race can result in torn writes,

i.e. observable data corruption. We discussed this in Section 10.12 and Listing 10-7

in reference to a page fault, but this is equally applicable to a [*write()*](https://man7.org/linux/man-pages/man2/write.2.html) operation.

 

Note that on page fault [folio_wait_stable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n3078) (see Listing 10-7) is invoked

to check to see whether the file system or block device requires waiting on

writeback in [filemap_page_mkwrite()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3399) and also via [grab_cache_page_write_begin()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n111)

on a [write()](https://man7.org/linux/man-pages/man2/write.2.html) call (see Listing 10-5).

This renders the correct ‘cleaning’ of the folios to be written to in

[folio_clear_dirty_for_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2826) absolutely critical. Page faults and [write()](https://man7.org/linux/man-pages/man2/write.2.html) opera-tions will be blocked from interfering with this operation into it is complete as this is protected by the folio lock.

If we are unable to mark the folio clean for I/O (for instance if it was al-

ready marked dirty), then we simply move on to the next folio.

Otherwise, we invoke the passed-in writepage function to perform the

underlying page writeback. This of course varies by file system, and op-erates at the block level. A commonly used function for this operation is

[\_\_mpage_writepage(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/mpage.c?h=v6.0#n448)however discussion of this is out of scope for the book.

We pass the [struct writeback_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n50) state to this function so it knows to han-dle the specified synchronisation requirements.

Note that importantly, the page passed to writepage() is locked when

passed, but will be unlocked once the operation is complete, except in the

specific case of an error being returned of value [AOP_WRITEPAGE_ACTIVATE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n299)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n299) This indicates that the page writeback has completed, and this is not in fact an error but rather indicates the page is locked and must be unlocked by us.

Regardless of the implementation of the writepage() callback, the func-

tion will ultimately invoke [folio_start_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n765) when the writeback starts

(which in turn wraps [\_\_folio_start_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2955)) which sets the folio write-back flag if not already set, and marks the relevant entry in the page cache

object’s xarray with the [t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#nPAGECACHE_TAG_WRITEBACK)[ag.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#nPAGECACHE_TAG_WRITEBACK) See Listing 10-28 for details.

Equally, when the I/O operation is complete, [folio_end_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1599) is

invoked, which in turn invokes [\_\_folio_end_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2910) (see Listing 10-29)

which clears the writeback flag from the folio and the [t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#nPAGECACHE_TAG_WRITEBACK)[ag](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#nPAGECACHE_TAG_WRITEBACK) from its xarray.

Next we have some rather fragile error handling. As the comment sug-

gests, in cases other where where we must synchronise the write (the ‘in-tegrity writeback’ case), we can simply abort the writeback and return the error.

However in the case of a synchronised write we simply record the first

error and carry on.

Finally, if we have reached or exceeded the specified

[struct writeback_control-\>nr_to_write](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n50) limit and are not synchronising, we are done and can abort the operation.

Once the loop is complete, we handle some cyclic range edge cases as

shown in Listing 10-27.

 

2402 */\**

2403 *\* If we hit the last page and there is more work to be done: wrap*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2404 *\* back the index back to the start of the file for the next* 2405 *\* time we are called.* 2406 *\*/*

2407 **if** (wbc-\>range_cyclic && !done) 2408 done_index = 0; 2409 **if** (wbc-\>range_cyclic \|\| (range_whole && wbc-\>nr_to_write \> 0)) 2410 mapping-\>writeback_index = done_index; 2411

2412 **return** ret;

2413 }

 

*Listing 10-27:* mm/page-writeback.c: [*write_cache_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2281) *cyclic edge cases*

 

If the range is cyclic and we were not able to process all dirty

pages (for instance if [struct writeback_control-\>nr_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n50) was set to

scan the whole file and an error did not occur), we reset the index to

start at on the next cycle to the beginning of the page cache entry in

[struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)-\>writeback_index.

If the range was cyclic and [struct writeback_control-\>nr_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n50)

was specified and that number of pages were processed, we set

[struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)-\>writeback_index to the next index at which we should

resume writeback.

Finally we have the edge case of a non-cyclic writeback, but where the

entire range of the page cache entry is required to be written back, but pages

remain to be written (or an unlimited number were specified to be written),

in which case we also set this offset in order that a cyclical write will pick up

where it left off.

By doing this, we avoid situations where folios at the beginning of a page

cache entry keep on being dirtied and written back without writing back

later folios.

We examine [\_\_folio_start_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2955) in Listing 10-28, eliding statistical

updates, out of scope cgroup logic and details that distract from the core of

this function.

 

2955 **bool \_\_folio_start_writeback**(**struct** folio \*folio, **bool** keep_write) 2956 {

2957 **long** nr = **folio_nr_pages**(folio); 2958 **struct** address_space \*mapping = **folio_mapping**(folio); 2959 **bool** ret;

2960 **int** access_ret;

. . .

2964 **XA_STATE**(xas, &mapping-\>i_pages, **folio_index**(folio)); 2965 **struct** inode \*inode = mapping-\>host; 2966 **struct** backing_dev_info \*bdi = **inode_to_bdi**(inode); 2967 **unsigned long** flags; 2968

2969 **xas_lock_irqsave**(&xas, flags); 2970 **xas_load**(&xas); 2971 ret = **folio_test_set_writeback**(folio);

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2972 **if** (!ret) { 2973 **bool** on_wblist; 2974

2975 on_wblist = **mapping_tagged**(mapping, 2976 **PAGECACHE_TAG_WRITEBACK**);

2977

2978 **xas_set_mark**(&xas, **PAGECACHE_TAG_WRITEBACK**);

. . .

2992 **if** (mapping-\>host && !on_wblist) 2993 **sb_mark_inode_writeback**(mapping-\>host); 2994 }

2995 **if** (!**folio_test_dirty**(folio)) 2996 **xas_clear_mark**(&xas, **PAGECACHE_TAG_DIRTY**); 2997 **if** (!keep_write) 2998 **xas_clear_mark**(&xas, **PAGECACHE_TAG_TOWRITE**); 2999 **xas_unlock_irqrestore**(&xas, flags);

. . .

3015 **return** ret;

3016 }

 

*Listing 10-28:* mm/page-writeback.c: [*\_\_folio_start_writeback()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2955)

 

This sets the folio’s writeback flag if not already set and marks it tagged

as [PAGECACHE_TAG_WRITEBACK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n452) in the relevant xarray entry, clearing any existing

[f lag ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#nPAGECACHE_TAG_DIRTY)to indicate that I/O has been submitted.

Except in an edge case specific to the ext4 file system the keep_write flag

will be false, therefore any existing [PAGECACHE_TAG_TOWRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n454) will has this mark

cleared also (see discussion around [write_cache_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2281) in Listing 10-25 for details on how this is utilised).

It also invokes [sb_mark_inode_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1251) for the first writeback folio in

the mapping, which places the inode on the super block’s writeback list,

[struct super_block-\>i_wb_list](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n1451). This will be reversed when the writeback op-eration is complete.

When the writeback has completed, [folio_end_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1599) will be invoked

(most likely via [page_endio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1634), see Listing 9-58 in the page cache chapter), which performs some reclaim-specific logic out of scope for this chapter,

before invoking [\_\_folio_end_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2910) shown in Listing 10-29 before waking

anything waiting on the writeback via [folio_wake()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1174) as shown in Listing 9-145

in Section 9.11. Again we elide irrelevant detail to focus on the core of what this does.

 

2910 **bool \_\_folio_end_writeback**(**struct** folio \*folio) 2911 {

2912 **long** nr = **folio_nr_pages**(folio); 2913 **struct** address_space \*mapping = **folio_mapping**(folio); 2914 **bool** ret;

. . .

2918 **struct** inode \*inode = mapping-\>host; 2919 **struct** backing_dev_info \*bdi = **inode_to_bdi**(inode);

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2920 **unsigned long** flags; 2921

2922 **xa_lock_irqsave**(&mapping-\>i_pages, flags); 2923 ret = **folio_test_clear_writeback**(folio); 2924 **if** (ret) { 2925 **\_\_xa_clear_mark**(&mapping-\>i_pages, **folio_index**(folio), 2926 **PAGECACHE_TAG_WRITEBACK**);

. . .

2932 **if** (!**mapping_tagged**(mapping, 2933 **PAGECACHE_TAG_WRITEBACK**))

2934 **wb_inode_writeback_end**(wb);

. . .

2936 }

2937

2938 **if** (mapping-\>host && !**mapping_tagged**(mapping, 2939 **PAGECACHE_TAG_WRITEBACK**))

2940 **sb_clear_inode_writeback**(mapping-\>host); 2941

2942 **xa_unlock_irqrestore**(&mapping-\>i_pages, flags);

. . .

2952 **return** ret;

2953 }

 

*Listing 10-29:* mm/page-writeback.c: [*\_\_folio_end_writeback()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2910)

 

This is more or less the inverse of [\_\_folio_start_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2955)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2955) clearing

the folio’s writeback flag and removing xarray tags. Two important points

to note—if this was the final folio to have its [t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#nPAGECACHE_TAG_WRITEBACK)[ag](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#nPAGECACHE_TAG_WRITEBACK) cleared, then two extra

tasks are performed—a worker thread is scheduled to update the band-

width estimate in the [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) object via [wb_inode_writeback_end()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2893)

(see section 10.14 for more details on how these values are used) and

[sb_clear_inode_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1269) removes the containing inode from the super

block’s writeback list block’s writeback list, [struct super_block](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n1451)-\>i_wb_list.

Finally, we examine the key [folio_clear_dirty_for_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2826) function in Listing

10-30, eliding less critical logic around update of statistics and debug checks.

 

2812 */\**

2813 *\* Clear a folio's dirty flag, while caring for dirty memory accounting.* 2814 *\* Returns true if the folio was previously dirty.* 2815 *\**

2816 *\* This is for preparing to put the folio under writeout. We leave* 2817 *\* the folio tagged as dirty in the xarray so that a concurrent* 2818 *\* write-for-sync can discover it via a PAGECACHE_TAG_DIRTY walk.* 2819 *\* The -\>writepage implementation will run either folio_start_writeback()* 2820 *\* or folio_mark_dirty(), at which stage we bring the folio's dirty flag* 2821 *\* and xarray dirty tag back into sync.* 2822 *\**

2823 *\* This incoherency between the folio's dirty flag and xarray tag is* 2824 *\* unfortunate, but it only exists while the folio is locked.*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2825 *\*/*

2826 **bool folio_clear_dirty_for_io**(**struct** folio \*folio) 2827 {

2828 **struct** address_space \*mapping = **folio_mapping**(folio); 2829 **bool** ret = **false**;

. . .

2833 **if** (mapping && **mapping_can_writeback**(mapping)) { 2834 **struct** inode \*inode = mapping-\>host; 2835 **struct** bdi_writeback \*wb;

. . .

2838 */\**

2839 *\* Yes, Virginia, this is indeed insane.* 2840 *\**

2841 *\* We use this sequence to make sure that* 2842 *\* (a) we account for dirty stats properly* 2843 *\* (b) we tell the low-level filesystem to* 2844 *\** *mark the whole folio dirty if it was* 2845 *\** *dirty in a pagetable. Only to then* 2846 *\* (c) clean the folio again and return 1 to* 2847 *\** *cause the writeback.* 2848 *\**

2849 *\* This way we avoid all nasty races with the* 2850 *\* dirty bit in multiple places and clearing* 2851 *\* them concurrently from different threads.* 2852 *\**

2853 *\* Note! Normally the "folio_mark_dirty(folio)"* 2854 *\* has no effect on the actual dirty bit - since* 2855 *\* that will already usually be set. But we* 2856 *\* need the side effects, and it can help us* 2857 *\* avoid races.* 2858 *\**

2859 *\* We basically use the folio "master dirty bit"* 2860 *\* as a serialization point for all the different* 2861 *\* threads doing their things.* 2862 *\*/*

2863 **if** (**folio_mkclean**(folio)) 2864 **folio_mark_dirty**(folio); 2865 */\**

2866 *\* We carefully synchronise fault handlers against*

2867 *\* installing a dirty pte and marking the folio dirty*

2868 *\* at this point. We do this by having them hold the*

2869 *\* page lock while dirtying the folio, and folios are*

2870 *\* always locked coming in here, so we get the desired*

2871 *\* exclusion.* 2872 *\*/*

. . .

2874 **if** (**folio_test_clear_dirty**(folio)) {

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

. . .

2879 ret = **true**; 2880 }

. . .

2882 **return** ret; 2883 }

2884 **return folio_test_clear_dirty**(folio); 2885 }

 

*Listing 10-30:* mm/page-writeback.c: [*folio_clear_dirty_for_io()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2826)

 

This starts by checking whether the [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) page cache ob-

ject is capable of writing back at all via [mapping_can_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev.h?h=v6.0#n138)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev.h?h=v6.0#n138) which deter-

mines this from the underlying BDI.

If not then the operation is simple, we use folio_test_clear_dirty() to

check if the folio was marked dirty, if so we simply clear the flag and return

indicating that we have done this.

As can be determined from the colourful comment, the writeback case is

rather more tricky.

We perform the most critical task of this function, which is to use

the reverse mapping to mark all page mappings to the folio read-only via

[folio_mkclean()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1035) which returns the number of page table mappings that were

marked read-only. See Chapter 7 on the reverse mapping for details as to

how this is achieved.

At this point, any writes that are performed to memory mappings of this

folio will cause a page fault which will re-dirty the folio. This cannot happen

while the [folio_clear_dirty_for_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2826) function is in-flight, as the folio lock is

held at this point, and page faults also acquire this lock, so we serialise on it

(see Section 10.12 for more on dirty tracking on page faults).

Writes via [write()](https://man7.org/linux/man-pages/man2/write.2.html) are safe as these always correctly mark the written-to

folios dirty (see Section 10.12 for details on dirty tracking over [write()](https://man7.org/linux/man-pages/man2/write.2.html) opera-

tions).

This provides a guarantee that any further writes to the folio will cause

those writes to be correctly accounted as dirtying the folio and result in later

writeback. This is absolutely critical to the correct functioning of writeback

as it eliminiates the possibility of a race on writeback causing writes to be

‘missed’.

As the comment suggest however there is some nuance here in ensuring

that all state is correctly serialised and statistics are correctly updated. The

[folio_mark_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2730) function (see Section 10.12 and Listing 10-8) is called after

the page table mapping cleaning performed by [folio_mkclean()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/rmap.c?h=v6.0#n1035) marks at least

one mapping clean.

This serialises any possible race condition between concurrent clearing

of the folio dirty flag from multiple threads and ensuring that the folio is in

a correct dirty state to be processed by writeback.

Once this is done, we can simply invoke folio_test_clear_dirty() to clear

the folio dirty flag and begin writeback, if another thread has not already

cleared the folio at this point.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

As the comment states, the fact we hold a folio lock on page fault pre-

vents a race between a dirty page table entry being installed and flipping the folio to dirty.

 

**10.11 File System and Background Writeback**

 

When folios are dirtied within the file system, we must track which fo-lios and inodes are dirty in order that we can later write them back.

This is achieved by storing dirty folios in [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) and the

[struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)-\>i_pages xarray as described in Section 10.12.

This is how most writeback within the kernel is performed, both periodic

background writeback and file system synchronisation via [sync()](https://man7.org/linux/man-pages/man2/sync.2.html) and [syncfs()](https://man7.org/linux/man-pages/man2/syncfs.2.html)

system calls as described in Section 10.6.

The exception to this rule is file synchronisation via e.g. [fsync()](https://man7.org/linux/man-pages/man2/fsync.2.html) which

directly invokes per-file writeback. We explore this in Section 10.13.

We examine how the process of file system writeback occurs in Figure

10-6.

 

Scheduled to be executed at vm.dirty_writeback_centisecs intervals.

[bdi_wq](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/backing-dev.c?h=v6.0#n36) ...

 

[bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)

Each [bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) schedules work in

[bdi_wq](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/backing-dev.c?h=v6.0#n36) using its dwork field.

 

dwork

b_io

b_dirty

Move from b_dirty to b_io

via [queue_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1416)

 

[inode inode inode inode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593)

 

... ...

i_io_list i_io_list i_io_list i_io_list

 

Older than vm.dirty_expire_centisecs

 

*Figure 10-6: File System Writeback*

 

The process of file system level writeback is accomplished via a [work](https://kernel.org/doc/html/v6.0/core-api/workqueue.html)

[queue, ](https://kernel.org/doc/html/v6.0/core-api/workqueue.html)which is a kernel API which abstracts the ability to perform a series of tasks in a kernel thread.

All [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) objects share the same [struct workqueue_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/workqueue.c?h=v6.0#n257)

work queue object, [bdi_wq](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/backing-dev.c?h=v6.0#n36)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/backing-dev.c?h=v6.0#n36)

 

**N O T E** Work queues are a generic means by which the kernel can execute work asyn-

chronously and in the context of a process, using a kernel-managed thread pool.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

The [bdi_wq](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/backing-dev.c?h=v6.0#n36) work queue is initialised in [default_bdi_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/backing-dev.c?h=v6.0#n234), shown in List-

ing 10-31.

 

234 **static int \_\_init default_bdi_init**(**void**) 235 {

236 bdi_wq = **alloc_workqueue**("writeback", **WQ_MEM_RECLAIM** \| **WQ_UNBOUND** \| 237 **WQ_SYSFS**, 0); 238 **if** (!bdi_wq)

239 **return**-**ENOMEM**; 240 **return** 0;

241 }

 

*Listing 10-31:* mm/backing-dev.c: [*default_bdi_init()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/backing-dev.c?h=v6.0#n234)

 

This function allocates a work queue via [alloc_workqueue()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/workqueue.c?h=v6.0#n4287), notably set-

ting [WQ_UNBOUND](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/workqueue.h?h=v6.0#n304) to indicate that the work can be scheduled on any core, and

[WQ_MEM_RECLAIM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/workqueue.h?h=v6.0#n304) to indicate that the work queue may be used during the mem-

ory reclaim process and thus might operate under very low memory condi-

tions.

Before any folios are dirtied, this queue is empty. However, when a fo-

lio is dirtied in [\_\_mark_inode_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2363) (see Listing 10-2 in Section 10.1), we

check to see whether the associated [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) has any dirty fo-

lios attached to it. If not, then we queue the [struct delayed_work](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/workqueue.h?h=v6.0#n110) task in

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>dwork on [bdi_wq](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/backing-dev.c?h=v6.0#n36) via [wb_wakeup_delayed()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/backing-dev.c?h=v6.0#n258)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/backing-dev.c?h=v6.0#n258) shown in List-

ing 10-32.

We keep track of whether a [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) has associated

dirty folios in [wb_io_lists_populated()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n90)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n90) which checks this condition in

[wb_has_dirty_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev.h?h=v6.0#n51), which checks whether the [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>status field

has the [WB_has_dirty_io](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n27) bit set. If this bit was not previously present, it is im-

mediately set at this point, and is cleared in [wb_io_lists_depopulated()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n98) at the

point no dirty folios remain.

As a result, no writeback work is actually performed when a block device

has no dirtied folios, in other words the work queue task is only ‘woken up’

when there is work to do.

 

244 */\**

245 *\* This function is used when the first inode for this wb is marked dirty. It*

246 *\* wakes-up the corresponding bdi thread which should then take care of the*

247 *\* periodic background write-out of dirty inodes. Since the write-out would*

248 *\* starts only 'dirty_writeback_interval' centisecs from now anyway, we just*

249 *\* set up a timer which wakes the bdi thread up later.* 250 *\**

251 *\* Note, we wouldn't bother setting up the timer, but this function is on the*

252 *\* fast-path (used by '\_\_mark_inode_dirty()'), so we save few context switches*

253 *\* by delaying the wake-up.* 254 *\**

255 *\* We have to be careful not to postpone flush work if it is scheduled for*

256 *\* earlier. Thus we use queue_delayed_work().* 257 *\*/*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

258 **void wb_wakeup_delayed**(**struct** bdi_writeback \*wb) 259 {

260 **unsigned long** timeout; 261

262 timeout = **msecs_to_jiffies**(dirty_writeback_interval \* 10); 263 **spin_lock_irq**(&wb-\>work_lock); 264 **if** (**test_bit**(**WB_registered**, &wb-\>state)) 265 **queue_delayed_work**(bdi_wq, &wb-\>dwork, timeout); 266 **spin_unlock_irq**(&wb-\>work_lock); 267 }

 

*Listing 10-32:* mm/backing-dev.c: [*wb_wakeup_delayed()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/backing-dev.c?h=v6.0#n258)

 

This checks to see whether the object has been correctly initialised and

registered via the [WB_registered](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n25) flag and then queues the work via the work

queue utility function [queue_delayed_work()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/workqueue.h?h=v6.0#n514).

The time interval is based on the vm.dirty_writeback_centisecs tunable

which is known to the kernel via the [dirty_writeback_interval](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n101) global value.

When each [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) object is initialised in [wb_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/backing-dev.c?h=v6.0#n281)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/backing-dev.c?h=v6.0#n281) it has

its dwork field set to invoke [wb_workfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2205) which is the core function which per-forms file system writeback.

We will examine this in Listing 10-44, however we will first examine in a

little more detail how the kernel interacts with these work queue tasks. One thing to note at this stage is that each time a queued delayed work queue

item is complete, i.e. invoking [wb_workfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2205) in this case, it is completely re-moved from the queue, and thus we must reschedule, which this function does.

The periodic background writeback is only one scenario in which write-

back needs to be performed, another is for instance when file synchronisa-tion is performed at which point the writeback needs to be performed imme-diately.

When synchronisation wakes up flusher threads, or if writeback work

other than periodic writeback still needs to be performed after writeback

has occurred, this is ultimately performed by [wb_wakeup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n135)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n135) which we examine

in Listing 10-33.

 

135 **static void wb_wakeup**(**struct** bdi_writeback \*wb) 136 {

137 **spin_lock_irq**(&wb-\>work_lock); 138 **if** (**test_bit**(WB_registered, &wb-\>state)) 139 **mod_delayed_work**(**bdi_wq**, &wb-\>dwork, 0); 140 **spin_unlock_irq**(&wb-\>work_lock); 141 }

 

*Listing 10-33:* fs/fs-writeback.c: [*wb_wakeup()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n135)

 

This function uses [mod_delayed_work()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/workqueue.h?h=v6.0#n529) to set the delay to zero, effectively

causing the task to be executed immediately, i.e. invoking [wb_workfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2205) for the

specified [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) immediately.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

When file system super blocks need to be explicitly synchronised, this

is done by adding [struct wb_writeback_work](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42) objects (see Listing 10-38) to

the [struct bdi_writeback-\>work_list](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) and then immediately waking up the

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)’s writeback work queue thread via [wb_queue_work()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n159) which

we examine in Listing 10-34 (eliding out of scope tracing logic).

 

159 **static void wb_queue_work**(**struct** bdi_writeback \*wb, 160 **struct** wb_writeback_work \*work) 161 {

. . .

164 **if** (work-\>done)

165 **atomic_inc**(&work-\>done-\>cnt);

166

167 **spin_lock_irq**(&wb-\>work_lock);

168

169 **if** (**test_bit**(**WB_registered**, &wb-\>state)) { 170 **list_add_tail**(&work-\>list, &wb-\>work_list); 171 **mod_delayed_work**(**bdi_wq**, &wb-\>dwork, 0); 172 } **else**

173 **finish_writeback_work**(wb, work);

174

175 **spin_unlock_irq**(&wb-\>work_lock); 176 }

 

*Listing 10-34:* fs/fs-writeback.c: [*wb_queue_work()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n159)

 

This starts by incrementing the atomic counter of the

[struct wb_completion](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n63) field stored in [struct wb_writeback_work](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42)-\>done if this field

is set. This field is used by the caller to track when a specified work task is

complete.

If the [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) object is registered, i.e. not removed or

in the process of removal, then the work task is simply added to the

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>work_list and the same [mod_delayed_work()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/workqueue.h?h=v6.0#n529) trick as used

by [wb_wakeup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n135) is used to wake up the associated writeback wait queue task.

if the [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) is not registered, then [finish_writeback_work()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n143) is

invoked to perform clean up tasks.

Note that when a BDI device or related cgroup structure is unregistered,

the kernel invokes [wb_shutdown()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/backing-dev.c?h=v6.0#n334) which also invokes immediate execution of

writeback, however for space we will disregard this.

Before diving into the implementation of file system and back-

ground writeback, we examine how [wb_wakeup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n135), [wb_wakeup_delayed()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/backing-dev.c?h=v6.0#n258) and

[wb_queue_work()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n159) are invoked in Figure 10-7 (eliding out of scope dirty time,

cgroup and laptop mode handling).

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

From [sync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n111) syscall vm.dirty_writeback_centisecs

Reclaim-triggered writeback

see Figure 10-4 changed

 

[ksys_sync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n97) [dirty_writeback_centisecs_handler()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2022) [shrink_inactive_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2402)

 

Dirty ratio exceeded,

[wakeup_flusher_threads()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2269)

See Section 10.14

 

[balance_dirty_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1557) [\_\_wakeup_flusher_threads_bdi()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2246) [\_\_mark_inode_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2363)

 

[wb_start_background_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1219) [wb_start_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1188) [wb_workfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2205)

 

[wb_queue_work()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n159) [wb_wakeup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n135) [wb_wakeup_delayed()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/backing-dev.c?h=v6.0#n258)

 

From [sync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n111) / [syncfs()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n149)

[bdi_split_work_to_wbs()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n936) [sync_inodes_sb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2667)

syscalls see Figure 10-4

 

[\_\_writeback_inodes_sb_nr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2588) [writeback_inodes_sb_nr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2620) [writeback_inodes_sb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2637)

 

From [syncfs()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n149) syscall

see Figure 10-4

 

*Figure 10-7: File System Writeback Wakeup*

 

This diagram shows all of the means by which [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) write-

back work queue threads can be woken up to perform the actual writeback, which is another way of saying all of the means file system-level writeback can be performed.

We have explored the various means by which file system synchronisa-

tion can be performed in Section 10.6, and here we see how the file system-

level synchronisation system calls, [sync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n111) and [syncfs()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n149) ultimately wake up the

file system via [wakeup_flusher_threads()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2269) which we examine below in Listing

10-35.

When synchronisation is started, the request to perform writeback

of inodes is performed asynchronously by [writeback_inodes_sb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2637) and syn-

chronously by [sync_inodes_sb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2667) which we examine in Listings 10-40 and 10-39 below, respectively.

The flusher threads are also awoken by reclaim in [shrink_inactive_list()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2402),

which we explore in detail in the dedicated reclaim chapter. When vm.dirty_writeback_centisecs is altered, this also causes flusher threads to be

awoken immediately via [dirty_writeback_centisecs_handler()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2022)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2022)

When the vm.dirty_background_ratio or vm.dirty_background_bytes lim-

its are breached when we dirty a folio, we invoke background writeback, if the vm.dirty_ratio or vm.dirty_bytes limits are breached then the pro-cess doing this waits on the operation to complete. This is all achieved in

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

[balance_dirty_pages() , ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1557)which we discuss in detail in Section 10.14, invoking

the background writeback in [wb_start_background_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1219) which simply

wraps [wb_wakeup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n135)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n135)

We have also previously explored how the first dirty inode associated

with a [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) can trigger the standard background flushing

process (invoked at vm.dirty_writeback_centisecs intervals) in Listing 10-2 and

Section 10.1 which we observe here also invoking [wb_wakeup_delayed()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/backing-dev.c?h=v6.0#n258).

We note that the actual worker function executed when the work queue

is awoken, [wb_workfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2205), must reschedule itself via [wb_wakeup_delayed()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/backing-dev.c?h=v6.0#n258)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/backing-dev.c?h=v6.0#n258) though

also note that if it has immediate work to do, it reinvokes itself immediately

via [wb_wakeup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n135)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n135) We will examine this function in detail in Listing 10-44 be-

low.

We examine the function which wakes up the flusher threads for each

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105), [wakeup_flusher_threads()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2269) in Listing 10-35.

 

2266 */\**

2267 *\* Wakeup the flusher threads to start writeback of all currently dirty pages*

2268 *\*/*

2269 **void wakeup_flusher_threads**(**enum** wb_reason reason) 2270 {

2271 **struct** backing_dev_info \*bdi; 2272

2273 */\**

2274 *\* If we are expecting writeback progress we must submit plugged IO.*

2275 *\*/*

2276 **blk_flush_plug**(current-\>plug, **true**); 2277

2278 **rcu_read_lock**();

2279 **list_for_each_entry_rcu**(bdi, &bdi_list, bdi_list) 2280 **\_\_wakeup_flusher_threads_bdi**(bdi, reason); 2281 **rcu_read_unlock**(); 2282 }

 

*Listing 10-35:* fs/fs-writeback.c: [*wakeup_flusher_threads()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2269)

 

We disregard the [blk_flush_plug()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/blkdev.h?h=v6.0#n1025) function here as this is an out of scope

scaling optimisation for the block layer, as well as the [RCU](https://kernel.org/doc/html/v6.0/RCU/rcu.html)[-specif](https://kernel.org/doc/html/v6.0/RCU/rcu.html)ic optimised

locking logic as equally out of scope.

The key thing to note here is that we iterate through each block de-

vice in the global variable [bdi_list](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/backing-dev.c?h=v6.0#n33) which contains these, and invokes

[\_\_wakeup_flusher_threads_bdi()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2246) on each of them, shown in Listing 10-36.

 

2246 **static void \_\_wakeup_flusher_threads_bdi**(**struct** backing_dev_info \*bdi, 2247 **enum** wb_reason reason) 2248 {

2249 **struct** bdi_writeback \*wb; 2250

2251 **if** (!**bdi_has_dirty_io**(bdi)) 2252 **return**;

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2253

2254 **list_for_each_entry_rcu**(wb, &bdi-\>wb_list, bdi_node) 2255 **wb_start_writeback**(wb, reason); 2256 }

 

*Listing 10-36:* fs/fs-writeback.c: [*\_\_wakeup_flusher_threads_bdi()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2246)

 

This function starts by invoking [bdi_has_dirty_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev.h?h=v6.0#n56) to determine if

any associated [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) object has outstanding dirty I/O to perform, as if not waking the threads is not useful. It then iterates

through each of the BDI’s [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) objects, stored as a list in

[struct backing_dev_info](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n165)-\>wb_list and invokes [wb_start_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1188) on each,

which we examine in Listing 10-37.

 

1188 **static void wb_start_writeback**(**struct** bdi_writeback \*wb, **enum** wb_reason reason

)

1189 {

1190 **if** (!**wb_has_dirty_io**(wb)) 1191 **return**;

1192

1193 */\**

1194 *\* All callers of this function want to start writeback of all* 1195 *\* dirty pages. Places like vmscan can call this at a very* 1196 *\* high frequency, causing pointless allocations of tons of* 1197 *\* work items and keeping the flusher threads busy retrieving* 1198 *\* that work. Ensure that we only allow one of them pending and* 1199 *\* inflight at the time.* 1200 *\*/*

1201 **if** (**test_bit**(**WB_start_all**, &wb-\>state) \|\| 1202 **test_and_set_bit**(**WB_start_all**, &wb-\>state)) 1203 **return**;

1204

1205 wb-\>start_all_reason = reason; 1206 **wb_wakeup**(wb);

1207 }

 

*Listing 10-37:* fs/fs-writeback.c: [*wb_start_writeback()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1188)

 

If the [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) object does not have dirty I/O associated with

it (i.e. entries on one of its b_dirty, b_io or b_more_io lists), then there is noth-

ing to do and we abort. This is checked via [wb_has_dirty_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev.h?h=v6.0#n51) which checks

for the [WB_has_dirty_io](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n27) flag, conditionally set by [wb_io_lists_populated()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n85) and

conditionally cleared by [wb_io_lists_depopulated()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n98)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n98) both invoked when entries may be added or removed from lists respectively.

As the comment suggests, we maintain a specific flag for the case of

wanting to writeback all dirty folios to prevent duplicate invocations for ef-

ficiency, via the [WB_start_all](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n28) flag which we both set and clear here.

Finally we invoke [wb_wakeup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n135) as described in Listing 10-33. In order to indicate to writeback that we have work to perform other

than periodic writeback of folios older than vm.dirty_expire_centisecs,

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

we maintain the [struct bdi_writeback-\>work_list](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) which maintains a list of

[struct wb_writeback_work](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42) objects, a type which is essentially a subset of the

[struct writeback_control . ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n50)We examine this in Listing 10-38.

 

39 */\**

40 *\* Passed into wb_writeback(), essentially a subset of writeback_control*

41 *\*/*

42 **struct** wb_writeback_work {

43 **long** nr_pages;

44 **struct** super_block \*sb;

45 **enum** writeback_sync_modes sync_mode;

46 **unsigned int** tagged_writepages:1;

47 **unsigned int** for_kupdate:1;

48 **unsigned int** range_cyclic:1;

49 **unsigned int** for_background:1;

50 **unsigned int** for_sync:1; */\* sync(2) WB_SYNC_ALL writeback \*/*

51 **unsigned int** auto_free:1; */\* free on completion \*/*

52 **enum** wb_reason reason; */\* why was writeback initiated? \*/*

53

54 **struct** list_head list; */\* pending work list \*/*

55 **struct** wb_completion \*done; */\* set if the caller waits \*/*

56 };

 

*Listing 10-38:* fs/fs-writeback.c: [*struct wb_writeback_work*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42)

 

This is a subset of [struct writeback_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n50) (see Listing 10-24) but includes

some additional fields:

 

**nr_pages** This field indicates the number of pages to write, similar to

[struct writeback_control-\>nr_to_write](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n50), though accounted separately.

**sb** The [struct super_block](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n1451) which is undergoing writeback, or if NULL, all su-

perblocks.

**list** A [struct list_head](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/types.h?h=v6.0#n178) node used to place [struct wb_writeback_work](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42) objects in

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>work_list.

**done** A [struct wb_completion](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n63) object used to notify waiters that the work has

been completed. item

**auto_free** A flag indicating whether the work object should be freed au-

tomatically when the writeback is complete by [finish_writeback_work()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n143)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n143)

This is needed because [bdi_split_work_to_wbs()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n936) might allocate a

[struct wb_writeback_work](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42) object using the slab allocator, which needs to be freed. Other invocations use stack-allocated objects so do not need this so will not set this flag.

 

Importantly, while the actual underlying writeback as described in

Section 10.10 is performed in terms of [struct writeback_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n50) objects,

file system writeback, whether specific writeback invoked by synchroni-

sation functions, or periodic background writeback is performed using

[struct wb_writeback_work](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42) objects.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

Let’s examine how [struct bdi_writeback-\>work_list](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) gets populated. This is

required by [sync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n111) and [syncfs()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/sync.c?h=v6.0#n149) system calls in order to specify what should be written back immediately rather than awaiting periodic writeback, per-

formed in two stages—synchronous writeback performed by [sync_inodes_sb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2667)

and asynchronous writeback performed by [writeback_inodes_sb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2637)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2637)

Let’s start by examining [sync_inodes_sb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2667) in Listing 10-39.

 

2660 */\*\**

2661 *\* sync_inodes_sb* *-* *sync sb inode pages* 2662 *\* @sb: the superblock*

2663 *\**

2664 *\* This function writes and waits on any dirty inode belonging to this* 2665 *\* super_block.*

2666 *\*/*

2667 **void sync_inodes_sb**(**struct** super_block \*sb) 2668 {

2669 **struct** backing_dev_info \*bdi = sb-\>s_bdi; 2670 **DEFINE_WB_COMPLETION**(done, bdi); 2671 **struct** wb_writeback_work work = { 2672 .sb = sb, 2673 .sync_mode = **WB_SYNC_ALL**, 2674 .nr_pages = **LONG_MAX**, 2675 .range_cyclic = 0, 2676 .done = &done, 2677 .reason = **WB_REASON_SYNC**, 2678 .for_sync = 1, 2679 };

2680

2681 */\**

2682 *\* Can't skip on !bdi_has_dirty() because we should wait for !dirty*

2683 *\* inodes under writeback and I_DIRTY_TIME inodes ignored by* 2684 *\* bdi_has_dirty() need to be written out too.* 2685 *\*/*

2686 **if** (bdi == &**noop_backing_dev_info**) 2687 **return**;

2688 **WARN_ON**(!**rwsem_is_locked**(&sb-\>s_umount)); 2689

2690 */\* protect against inode wb switch, see inode_switch_wbs_work_fn() \*/*

2691 **bdi_down_write_wb_switch_rwsem**(bdi); 2692 **bdi_split_work_to_wbs**(bdi, &work, **false**); 2693 **wb_wait_for_completion**(&done); 2694 **bdi_up_write_wb_switch_rwsem**(bdi); 2695

2696 **wait_sb_inodes**(sb); 2697 }

 

*Listing 10-39:* fs/fs-writeback.c: [*sync_inodes_sb()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2667)

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

This establishes a [struct wb_writeback_work](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42) object spanning all dirty folios

(as indicated by setting nr_pages to LONG_MAX) for the [struct super_block](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n1451) object

describing the file system being synchronised. The object is marked to indi-

cate that synchronisation should occur.

A [struct wb_completion](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n63) object is established via the [DEFINE_WB_COMPLETION()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n80)

macro, which is used to wait on the operation completing, which is waited

on via [wb_wait_for_completion()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n188)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n188) Discussion of the details of this are omitted

for brevity.

If the block device is unspecified we take no action and we provide a ker-

nel warning should an unexpected race occur between this operation and

unmounting of the super block.

After acquiring the appropriate lock, the actual queueing of the work

is deferred to [bdi_split_work_to_wbs()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n936) which we will examine later in Listing

10-43.

Finally, this invokes [wait_sb_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2503) in order to synchronise concurrent

synchronisation operations. Again, for brevity, we do not examine this in

detail.

We examine the asynchronous version of this performed by

[writeback_inodes_sb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2637) in Listing 10-40.

 

2628 */\*\**

2629 *\* writeback_inodes_sb -* *writeback dirty inodes from given super_block* 2630 *\* @sb: the superblock*

2631 *\* @reason: reason why some writeback work was initiated* 2632 *\**

2633 *\* Start writeback on some inodes on this super_block. No guarantees are made*

2634 *\* on how many (if any) will be written, and this function does not wait* 2635 *\* for IO completion of submitted IO.* 2636 *\*/*

2637 **void writeback_inodes_sb**(**struct** super_block \*sb, **enum** wb_reason reason) 2638 {

2639 **return writeback_inodes_sb_nr**(sb, **get_nr_dirty_pages**(), reason); 2640 }

 

*Listing 10-40:* fs/fs-writeback.c: [*writeback_inodes_sb()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2637)

 

This function obtains an upper bound for the number of dirty pages via

[get_nr_dirty_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/inode.c?h=v6.0#n93) and uses this to define the number of pages to write in

[writeback_inodes_sb_nr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2620) to which it defers the operation, shown in Listing

10-41.

 

2610 */\*\**

2611 *\* writeback_inodes_sb_nr -* *writeback dirty inodes from given super_block* 2612 *\* @sb: the superblock*

2613 *\* @nr: the number of pages to write* 2614 *\* @reason: reason why some writeback work initiated* 2615 *\**

2616 *\* Start writeback on some inodes on this super_block. No guarantees are made*

2617 *\* on how many (if any) will be written, and this function does not wait*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2618 *\* for IO completion of submitted IO.* 2619 *\*/*

2620 **void writeback_inodes_sb_nr**(**struct** super_block \*sb, 2621 **unsigned long** nr, 2622 **enum** wb_reason reason) 2623 {

2624 **\_\_writeback_inodes_sb_nr**(sb, nr, reason, **false**); 2625 }

 

*Listing 10-41:* fs/fs-writeback.c: [*writeback_inodes_sb_nr()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2620)

 

This performs writeback without synchronisation in the

[\_\_writeback_inodes_sb_nr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2588) function, shown in Listing 10-42.

 

2588 **static void \_\_writeback_inodes_sb_nr**(**struct** super_block \*sb, **unsigned long** nr, 2589 **enum** wb_reason reason, **bool** skip_if_busy) 2590 {

2591 **struct** backing_dev_info \*bdi = sb-\>s_bdi; 2592 **DEFINE_WB_COMPLETION**(done, bdi); 2593 **struct** wb_writeback_work work = { 2594 .sb = sb, 2595 .sync_mode = **WB_SYNC_NONE**, 2596 .tagged_writepages = 1, 2597 .done = &done, 2598 .nr_pages = nr, 2599 .reason = reason, 2600 };

2601

2602 **if** (!**bdi_has_dirty_io**(bdi) \|\| bdi == &**noop_backing_dev_info**) 2603 **return**;

2604 **WARN_ON**(!**rwsem_is_locked**(&sb-\>s_umount)); 2605

2606 **bdi_split_work_to_wbs**(sb-\>s_bdi, &work, skip_if_busy); 2607 **wb_wait_for_completion**(&done); 2608 }

 

*Listing 10-42:* fs/fs-writeback.c: [*\_\_writeback_inodes_sb_nr()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2588)

 

This resembles [sync_inodes_sb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2667) (see Listing 10-39) except that synchro-

nisation is not specified and the careful locking performed for the syn-chronous call is not performed here.

In each case, the heavy lifting is performed by [bdi_split_work_to_wbs()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n936)

which we examine in Listing 10-43.

 

925 */\*\**

926 *\* bdi_split_work_to_wbs - split a wb_writeback_work to all wb's of a bdi*

927 *\* @bdi: target backing_dev_info* 928 *\* @base_work: wb_writeback_work to issue* 929 *\* @skip_if_busy: skip wb's which already have writeback in progress* 930 *\**

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

931 *\* Split and issue @base_work to all wb's (bdi_writeback's) of @bdi which* 932 *\* have dirty inodes. If @base_work-\>nr_page isn't %LONG_MAX, it's* 933 *\* distributed to the busy wbs according to each wb's proportion in the* 934 *\* total active write bandwidth of @bdi.* 935 *\*/*

936 **static void bdi_split_work_to_wbs**(**struct** backing_dev_info \*bdi, 937 **struct** wb_writeback_work \*base_work, 938 **bool** skip_if_busy) 939 {

940 **struct** bdi_writeback \*last_wb = **NULL**; 941 **struct** bdi_writeback \*wb = **list_entry**(&bdi-\>wb_list, 942 **struct** bdi_writeback, bdi_node);

943

944 **might_sleep**();

945 **restart**:

946 **rcu_read_lock**();

947 **list_for_each_entry_continue_rcu**(wb, &bdi-\>wb_list, bdi_node) { 948 **DEFINE_WB_COMPLETION**(fallback_work_done, bdi); 949 **struct** wb_writeback_work fallback_work; 950 **struct** wb_writeback_work \*work; 951 **long** nr_pages;

952

953 **if** (last_wb) { 954 **wb_put**(last_wb); 955 last_wb = **NULL**; 956 }

957

958 */\* SYNC_ALL writes out I_DIRTY_TIME too \*/* 959 **if** (!**wb_has_dirty_io**(wb) && 960 (base_work-\>sync_mode == **WB_SYNC_NONE** \|\| 961 **list_empty**(&wb-\>b_dirty_time))) 962 **continue**; 963 **if** (skip_if_busy && **writeback_in_progress**(wb)) 964 **continue**;

965

966 nr_pages = **wb_split_bdi_pages**(wb, base_work-\>nr_pages);

967

968 work = **kmalloc**(**sizeof**(\*work), **GFP_ATOMIC**); 969 **if** (work) { 970 \*work = \*base_work; 971 work-\>nr_pages = nr_pages; 972 work-\>auto_free = 1; 973 **wb_queue_work**(wb, work); 974 **continue**; 975 }

976

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

977 */\* alloc failed, execute synchronously using on-stack fallback*

*\*/*

978 work = &fallback_work; 979 \*work = \*base_work; 980 work-\>nr_pages = nr_pages; 981 work-\>auto_free = 0; 982 work-\>done = &fallback_work_done; 983

984 **wb_queue_work**(wb, work); 985

986 */\**

987 *\* Pin @wb so that it stays on @bdi-\>wb_list. This allows*

988 *\* continuing iteration from @wb after dropping and* 989 *\* regrabbing rcu read lock.* 990 *\*/*

991 **wb_get**(wb); 992 last_wb = wb; 993

994 **rcu_read_unlock**(); 995 **wb_wait_for_completion**(&fallback_work_done); 996 **goto restart**; 997 }

998 **rcu_read_unlock**(); 999

1000 **if** (last_wb)

1001 **wb_put**(last_wb); 1002 }

 

*Listing 10-43:* fs/fs-writeback.c: [*bdi_split_work_to_wbs()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n936)

 

This function is meaningful only when cgroup writeback is used, mean-

ing that multiple [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) objects can be tied to a single BDI. This topic is therefore somewhat out of scope but as this is a key function, it’s important to examine it nonetheless, albeit briefly.

This ultimately invokes [wb_queue_work()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n159) described in Listing 10-

34 above, splitting the work across [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) objects using

[wb_split_bdi_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n906) to do so fairly based on writeback bandwidth.

An interesting point to note here is that this function attempts to per-

form the operation asynchronously, allocating its [struct wb_writeback_work](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42)

objects using a [GFP_ATOMIC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n332) (since we are in a context where we can’t take

the locks that an [GFP_KERNEL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n333) allocation would take see Section 2.6 for more details on GFP flags). If this fails, then it uses a stack-allocated

[struct wb_writeback_work](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42) object and does so synchronously.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

**10.12 Flusher Thread Operation**

 

We have now explored how the flusher thread is ultimately invoked in detail,

so it’s time to examine what it actually does. The function which the flusher

threads invoke is [wb_workfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2205)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2205) shown in Listing 10-44 (eliding trace hooks).

 

2201 */\**

2202 *\* Handle writeback of dirty data for the device backed by this bdi. Also* 2203 *\* reschedules periodically and does kupdated style flushing.* 2204 *\*/*

2205 **void wb_workfn**(**struct** work_struct \*work) 2206 {

2207 **struct** bdi_writeback \*wb = **container_of**(**to_delayed_work**(work), 2208 **struct** bdi_writeback, dwork); 2209 **long** pages_written; 2210

2211 **set_worker_desc**("flush-%s", **bdi_dev_name**(wb-\>bdi)); 2212

2213 **if** (**likely**(!**current_is_workqueue_rescuer**() \|\| 2214 !**test_bit**(**WB_registered**, &wb-\>state))) { 2215 */\**

2216 *\* The normal path. Keep writing back @wb until its* 2217 *\* work_list is empty. Note that this path is also taken* 2218 *\* if @wb is shutting down even when we're running off the*

2219 *\* rescuer as work_list needs to be drained.* 2220 *\*/*

2221 **do** {

2222 pages_written = **wb_do_writeback**(wb);

. . .

2224 } **while** (!**list_empty**(&wb-\>work_list)); 2225 } **else** {

2226 */\**

2227 *\* bdi_wq can't get enough workers and we're running off* 2228 *\* the emergency worker. Don't hog it. Hopefully, 1024 is*

2229 *\* enough for efficient IO.* 2230 *\*/*

2231 pages_written = **writeback_inodes_wb**(wb, 1024, 2232 **WB_REASON_FORKER_THREAD**);

. . .

2234 }

2235

2236 **if** (!**list_empty**(&wb-\>work_list)) 2237 **wb_wakeup**(wb); 2238 **else if** (**wb_has_dirty_io**(wb) && **dirty_writeback_interval**) 2239 **wb_wakeup_delayed**(wb); 2240 }

 

*Listing 10-44:* fs/fs-writeback.c: [*wb_workfn()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2205)

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

The flusher thread is implemented as a wait queue thread as described

at the start of Section 10.11. It is established with the [WQ_MEM_RECLAIM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/workqueue.h?h=v6.0#n304) flag set

(see [default_bdi_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/backing-dev.c?h=v6.0#n234) shown in Listing 10-31), the details of which are out of scope for the book but generally this means that a ‘rescuer’ thread always exists to ensure that, even under extreme memory pressure, this function executes.

If you examine running processes, you’ll observe a \[writeback\] kernel

thread. This is running the rescuer thread, as can be observed using procfs

as shown in Listing 10-45.

 

\$ sudo cat /proc/\$(pidof -sw "writeback")/stack

\[\<0\>\] rescuer_thread+0x2b0/0x3b0

\[\<0\>\] kthread+0xe5/0x120

\[\<0\>\] ret_from_fork+0x31/0x50

\[\<0\>\] ret_from_fork_asm+0x1b/0x30

 

*Listing 10-45: procfs Output of Writeback Rescuer Thread Call Stack*

 

This thread is not used outside of extreme memory pressure, rather the

threads that typically execute writeback are kworker threads, invoked by the

kernel’s wait queue implementation and used by [bdi_wq](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/backing-dev.c?h=v6.0#n36). These have rather generic names, something like kworker/u32:0-writeback. This indicates that the thread is invoked unbound (meaning it can run on any core) on pool 32 and happens to be assigned to CPU 0 to handle writeback events.

These kernel threads are only guaranteed to exist during the actual op-

eration and are, by their natural, ephemeral. However to assist with iden-

tification of these threads should they be long lasting, [wb_workfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2205) adds an

additional description to the running thread using [set_worker_desc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/workqueue.c?h=v6.0#n4642).

Taking the example of kworker/u32:0-events_unbound, this thread will in-

stead be renamed to kworker/u32:0-flush-259:0, assuming that the BDI being written back to has major and minor version number of 259 and 0 respec-tively.

As a result of this rescuer thread mechanism we can observe in List-

ing 10-44, note that [wb_workfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2205) takes special care to handle this case via

[current_is_workqueue_rescuer().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/workqueue.c?h=v6.0#n4549)

If it is not, or the [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) to which this operation belongs

is deregistered so needs clean up on the usual path (i.e. work list drained),

then writeback is invoked via the core path in [wb_do_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2222) which we

examine below in Listing 10-50.

We invoke [wb_do_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2222) at least once, repeating the operation should

work remain on the [struct bdi_writeback-\>work_list](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) indicating that immedi-ate synchronisation work needs to be performed.

If the rescuer thread is in use, then a special path is taken to prevent hog-

ging of this extremely limited resource. The [writeback_inodes_wb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1951) function is invoked and writes back 1,024 pages in the background. We examine this

function in Listing 10-49.

Finally the function must reschedule itself, as once the delayed work

item assigned to [bdi_wq](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/backing-dev.c?h=v6.0#n36) has been executed, invoking this function, it is also removed the work queue altogether.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

If, despite looping on writeback, the [struct bdi_writeback-\>work_list](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) is still

non-empty, then we immediately re-invoke the function via [wb_wakeup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n135), oth-

erwise we schedule the next invocation vm.dirty_writeback_centisecs later via

[wb_wakeup_delayed(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/backing-dev.c?h=v6.0#n258)only if we have outstanding I/O or dirty folios to pro-

cess. We can rely on [\_\_mark_inode_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2363) to wake up the flusher threads

again if new dirtying occurs after all inodes have been submitted for write-

back.

We examine the code paths invoked by [wb_workfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2205) in Figure 10-8.

 

[wb_workfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2205)

 

[writeback_inodes_wb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1951) [wb_do_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2174)

 

[wb_check_background_flush()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2095) [wb_check_old_data_flush()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2113) [wb_check_start_all()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2147)

 

[queue_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1416) [wb_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1988)

 

[\_\_writeback_inodes_wb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1917) [writeback_sb_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772)

 

[\_\_writeback_single_inode()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1576)

 

[do_writepages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2457)

 

See Section 10.10

 

*Figure 10-8:* [*wb_workfn()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2205) *Code Paths*

 

**N O T E** [*queue_io()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1416) is called by both [*writeback_inodes_wb()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1951) and [*wb_writeback()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1988)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1988) prior to

calling [*writeback_sb_inodes()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772). We denote this with a dashed outline, but since

[*queue_io()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1416) is so critical a function it’s important to highlight it here.

 

Ultimately the task of the functions shown in Figure 10-8 is to prepare

[struct wb_writeback_work](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42) objects to define the actual writeback work to

be performed by [writeback_sb_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772), and to move dirtied inodes from

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>b_dirty to [struct bdi_writeback-\>b_io](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) (and possibly

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>b_more_io which we will explore shortly) before per-

forming the actual writeback via [do_writepages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2457) as described in Section

10.10.

Both [\_\_writeback_inodes_wb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1917) and [wb_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1988) use [queue_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1416)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1416)

This is a key function which transfers dirty inodes from the

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>b_dirty list to the b_io list, which we examine in Listing

10-46 (eliding out of scope dirty time handling and trace callbacks).

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

Dirtied inodes transition through three different lists—b_dirty, b_io and

b_more_io. The key move is from b_dirty to b_io, which determines which in-

odes will be processed by [writeback_sb_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772) (see Listing 10-57) and are

placed there by [queue_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1416) (see Listing 10-46).

We examine how these transition in Figure 10-9 (eliding out of scope

cgroup logic and list moves performed by [writeback_single_inode()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1670)[).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1670)

 

[inode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593)

[\_\_mark_inode_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2363)

 

b_dirty

 

[queue_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1416)

 

[redirty_tail()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1308)\*

[bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)

 

[queue_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1416)

 

b_io b_more_io

[inode_cgwb_move_to_attached()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n278) [requeue_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1318)

via [requeue_inode()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1505)

 

\* Also [redirty_tail_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1293),

Removed from lists

which [redirty_tail()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1308) invokes.

 

*Figure 10-9:* [*struct bdi_writeback*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) *lifecycle in* [*writeback_sb_inodes()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772)

 

A folio that is written back at a file-system level (i.e. not synchronised

by [fsync()](https://man7.org/linux/man-pages/man2/fsync.2.html) or similar system calls) goes through the following life-cycle (as

shown in Figure 10-9):

 

**Dirtying** When an inode is first dirtied, it is added to the

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>b_dirty list by [\_\_mark_inode_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2363) (see Section for

dirty tracking via [write()](https://man7.org/linux/man-pages/man2/write.2.html) and Section for dirty tracking via page fault,

both of which end up invoking [\_\_mark_inode_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2363).

**Queueing** When the writeback flusher thread for a [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) ob-

ject has been invoked (as shown in Figure 10-8), it ultimately places eligi-

ble inodes from the b_dirty list into the b_io list via [queue_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1416) (see Listing

10-46).

In addition, [queue_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1416) moves any previously outstanding I/O from the b_more_io list back to b_io (we will examine this in detail, but briefly, if inodes are unable to be submitted for write back due to bandwidth or other constraints, they get added to b_more_io to be requeued at the next invocation.

**Submitting** As shown in Figure 10-8, once inodes have been queued for

I/O, [writeback_sb_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772) (see Listing 10-57) is invoked for all file sys-

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

tem writeback. This function iterates through all inodes belonging to

the specified [struct super_block](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n1451) and [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) and attempts to submit them for I/O.

**Requeueing** If [writeback_sb_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772) is unable to submit inodes for writeback

to the block level (discussed in Section 9.10.4), then the inodes must

be requeued, i.e. either placed back into b_dirty via [redirty_tail_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1293)

or [redirty_tail()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1308), or placed into b_more_io to be processed the next time

the flusher thread is invoked via [requeue_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1318)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1318) We discuss both cases this

when we examine this function in Listing 10-57.

**Dequeueing** If everything has gone correctly in [writeback_sb_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772) and

no requeueing was yet necessary, [requeue_inode()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1505) is invoked, which checks each state in which the inode might be in, requeueing if neces-sary, but if all has gone as planned and the inode has been correctly submitted for I/O, it is then removed from the b_io list altogether via

[inode_cgwb_move_to_attached()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n278) which has cgroup-specific handling but also deletes the inode from the list.

 

**N O T E** An important point to pay attention to here is that the *b_dirty* list is

ordered from youngest to eldest. Therefore, [*\_\_mark_inode_dirty()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2363) uses

[*inode_io_list_move_locked()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n118) to place the newly dirtied folio at the head of

[*struct bdi_writeback*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)*-\>b_dirty*, however [*writeback_sb_inodes()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772) processes inodes

that have been moved from *b_dirty* to *b_io* backwards as it is the inode updated least

recently that must be written back first.

 

In exploring this lifecycle, we will first examine the queueing step, per-

formed by [queue_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1416) in Listing 10-46.

 

1405 */\**

1406 *\* Queue all expired dirty inodes for io, eldest first.* 1407 *\* Before*

1408 *\** *newly dirtied* *b_dirty* *b_io* *b_more_io* 1409 *\** *=============\>* *gf* *edc* *BA* 1410 *\* After*

1411 *\** *newly dirtied* *b_dirty* *b_io* *b_more_io* 1412 *\** *=============\>* *g* *fBAedc* 1413 *\** *\|* 1414 *\** *+--\> dequeue for IO* 1415 *\*/*

1416 **static void queue_io**(**struct** bdi_writeback \*wb, **struct** wb_writeback_work \*work, 1417 **unsigned long** dirtied_before) 1418 {

1419 **int** moved;

. . .

1422 **assert_spin_locked**(&wb-\>list_lock); 1423 **list_splice_init**(&wb-\>b_more_io, &wb-\>b_io); 1424 moved = **move_expired_inodes**(&wb-\>b_dirty, &wb-\>b_io, dirtied_before);

. . .

1429 **if** (moved)

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1430 **wb_io_lists_populated**(wb);

. . .

1432 }

 

*Listing 10-46:* fs/fs-writeback.c: [*queue_io()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1416)

 

Note that this function is parameterised by dirtied_before, which specifies

the [struct inode-\>dirtied_when](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593) at which time (or prior) inodes are considered for writeback.

This varies depending on the caller—[writeback_inodes_wb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2231) simply

writes back inodes based on the current time regardless (see Listing

10-49 below), whereas [wb_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1988) specifies the current time less

vm.dirty_expire_centisecs if the [struct wb_writeback_work](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42) object specifies that the writeback is periodic background writeback (we examine this in Listing

10-55).

This function starts by invoking [list_splice_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/list.h?h=v6.0#n487), which takes the

list specified in the first parameter [(](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>b_more_io), and places it at the front of the list specified in the second parameter

[(struct bdi_writeback-\>b_io](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)), and clears the original list.

Importantly, [queue_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1416) is only invoked if [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>b_io is

empty, so b_more_io, if non-empty, is always processed first before any other I/O is queued, and this queueing is not repeated before all entries are pro-

cessed by [writeback_sb_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772)

Note that [writeback_sb_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772) processes inodes in

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>b_io backwards, so the existing order of inodes is preserved.

Next, inodes which are older than dirtied_before are moved from

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>b_dirty to b_io via [move_expired_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1354) which we ex-

amine in Listing 10-47.

 

1350 */\**

1351 *\* Move expired (dirtied before dirtied_before) dirty inodes from* 1352 *\* @delaying_queue to @dispatch_queue.* 1353 *\*/*

1354 **static int move_expired_inodes**(**struct** list_head \*delaying_queue, 1355 **struct** list_head \*dispatch_queue, 1356 **unsigned long** dirtied_before) 1357 {

1358 **LIST_HEAD**(tmp);

1359 **struct** list_head \*pos, \*node; 1360 **struct** super_block \*sb = **NULL**; 1361 **struct** inode \*inode; 1362 **int** do_sb_sort = 0; 1363 **int** moved = 0;

1364

1365 **while** (!**list_empty**(delaying_queue)) { 1366 inode = **wb_inode**(delaying_queue-\>prev); 1367 **if** (**inode_dirtied_after**(inode, dirtied_before)) 1368 **break**;

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1369 **spin_lock**(&inode-\>i_lock); 1370 **list_move**(&inode-\>i_io_list, &tmp); 1371 moved++;

1372 inode-\>i_state \|= **I_SYNC_QUEUED**; 1373 **spin_unlock**(&inode-\>i_lock); 1374 **if** (**sb_is_blkdev_sb**(inode-\>i_sb)) 1375 **continue**; 1376 **if** (sb && sb != inode-\>i_sb) 1377 do_sb_sort = 1; 1378 sb = inode-\>i_sb; 1379 }

1380

1381 */\* just one sb in list, splice to dispatch_queue and we're done \*/*

1382 **if** (!do_sb_sort) { 1383 **list_splice**(&tmp, dispatch_queue); 1384 **goto out**; 1385 }

1386

1387 */\**

1388 *\* Although inode's i_io_list is moved from 'tmp' to 'dispatch_queue',*

1389 *\* we don't take inode-\>i_lock here because it is just a pointless*

*overhead.*

1390 *\* Inode is already marked as I_SYNC_QUEUED so writeback list handling*

*is*

1391 *\* fully under our control.* 1392 *\*/*

1393 **while** (!**list_empty**(&tmp)) { 1394 sb = **wb_inode**(tmp.prev)-\>i_sb; 1395 **list_for_each_prev_safe**(pos, node, &tmp) { 1396 inode = **wb_inode**(pos); 1397 **if** (inode-\>i_sb == sb) 1398 **list_move**(&inode-\>i_io_list, dispatch_queue); 1399 }

1400 }

1401 **out**:

1402 **return** moved;

1403 }

 

*Listing 10-47:* fs/fs-writeback.c: [*move_expired_inodes()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1354)

 

The delaying_queue parameter is set to [struct bdi_writeback-\>b_dirty](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) and

dispatch_queue is set to [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>b_io.

The function loops through dirty inodes backwards, obtaining the

[struct inode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593) object associated with each entry via [wb_inode()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n70), and moves the

inode to the front of the tmp list if it is as old or older than dirtied_before (as

checked by [inode_dirtied_after()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1333)[).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1333)

This traversal assumes that b_dirty is maintained in an ordering of

youngest inode to eldest, which is correct, as at each point of being dirtied,

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

an inode is placed at the front of the list. This makes the list a queue, though in reverse order.

Traversing the list in reverse and appending to the front of the accumu-

lating list maintains the order. Consider an input list: ABCD

After each iteration of this loop, assuming all inodes are old enough to be queued, the list will be accumulated thusly:

D

CD

BCD

ABCD

And therefore the order is maintained as expected.

The inode has the [I_SYNC_QUEUED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2452) flag set which indicates it is queued for

I/O, which is cleared once the inode has been requeued or dequeued.

Finally in this loop, we check to determine whether the superblock con-

taining the inode is the special blockdev superblock, if not, the loop up-dates the do_sb_sort variable to indicate whether the inodes span multiple superblocks, in which case they must be sorted by super block.

If we are dealing with inodes in a single super block, then no sort-

ing is required and we simply transfer all inodes directly. Otherwise,

[writeback_sb_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772) expects inodes to be grouped by superblock.

The final loop iterates backwards through each entry in b_dirty, checking

for each inode that has the same superblock as the final entry, moving these from the tmp list to the output queue accordingly.

Consider a b_dirty list consisting of inodes from 3 superblocks a, b and

c . These will be present in b_dirty ordered from youngest to eldest, but in-odes of different superblocks will be interleaved. Denoting the ordering by subscript, consider the following b_dirty (and thus tmp, assuming all expired) list:

a 1a2b1a3c1c2b2a4

In the first iteration, the last entry is a 4 so we accumulate entries to b_io for superblock a as follows:

a 4

a3a4

a2a3a4

a1a2a3a4

This leaves tmp as follows:

b 1c1c2b2

We next append entries to b_io for superblock b as follows: b 2a1a2a3a4

b1b2a1a2a3a4

Finally, we are left with tmp as follows:

c c 12

Which trivially gets prepended to b_io thusly: c 2b1b2a1a2a3a4

c1c2b1b2a1a2a3a4

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

When we examine [writeback_sb_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772) in Listing 10-57, we will see how this

ordering is relied upon to correctly process superblocks as expected.

Finally, the function returns a boolean value indicating whether inodes

were moved or not.

Returning to [queue_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1416) shown in Listing 10-46, we note that after the

move has occurred, we invoke [wb_io_lists_populated()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n85), which we examine in

Listing 10-48.

 

85 **static bool wb_io_lists_populated**(**struct** bdi_writeback \*wb)

86 {

87 **if** (**wb_has_dirty_io**(wb)) {

88 **return false**;

89 } **else** {

90 **set_bit**(**WB_has_dirty_io**, &wb-\>state);

91 **WARN_ON_ONCE**(!wb-\>avg_write_bandwidth);

92 **atomic_long_add**(wb-\>avg_write_bandwidth,

93 &wb-\>bdi-\>tot_write_bandwidth);

94 **return true**;

95 }

96 }

 

*Listing 10-48:* fs/fs-writeback.c: [*wb_io_lists_populated()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n85)

 

This function returns a boolean indicating whether this is the first

dirty inode added to the [struct bdi_writeback-\>b_dirty](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) list, which is used in

[inode_io_list_move_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n118) which is used, in turn by [\_\_mark_inode_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2363) (see

Listing 10-2) to wake up flusher threads on first dirty.

However, [queue_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1416) ignores the return value and instead uses this to set

the [WB_has_dirty_io](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n27) flag in [struct bdi_writeback-\>flags](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105), and also updates write-

back bandwidth statistics (we discuss bandwidth and throttling in Section

10.14).

The sister function of [wb_io_lists_populated()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n85)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n85) [wb_io_lists_depopulated()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n98),

is invoked when inodes are removed from I/O lists, which clears this flag if

there are no inodes on any of the b-lists, dirty or I/O.

 

**N O T E** We can observe from these hook functions that the writeback flusher threads are an

entirely on-demand facility. The [*WB_has_dirty_io*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n27) flag serialises any ongoing process

of flusher thread writeback and dirtying of folios, ensuring that, should there be dirty

folios to flush, the thread is always woken up, but if there aren’t, it isn’t.

 

Now we have examined inode queuing, and before diving into the

core [wb_do_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2174) function which dispatches the various forms of

writeback (and thusly different forms of queueing I/O) we examine

[writeback_inodes_wb() , ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1951)which is invoked by [wb_workfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2205) when memory is crit-

ically low and the ‘rescuer’ thread is used. We examine this function in List-

ing 10-49, eliding out of scope block device plug logic.

 

1951 **static long writeback_inodes_wb**(**struct** bdi_writeback \*wb, **long** nr_pages, 1952 **enum** wb_reason reason)

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1953 {

1954 **struct** wb_writeback_work work = { 1955 .nr_pages = nr_pages, 1956 .sync_mode = **WB_SYNC_NONE**, 1957 .range_cyclic = 1, 1958 .reason = reason, 1959 };

. . .

1963 **spin_lock**(&wb-\>list_lock); 1964 **if** (**list_empty**(&wb-\>b_io)) 1965 **queue_io**(wb, &work, jiffies); 1966 **\_\_writeback_inodes_wb**(wb, &work); 1967 **spin_unlock**(&wb-\>list_lock);

. . .

1970 **return** nr_pages - work.nr_pages; 1971 }

 

*Listing 10-49:* fs/fs-writeback.c: [*writeback_inodes_wb()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1951)

 

This function establishes [struct wb_writeback_work](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42) with synchronisation

disabled and with cyclical range enabled (meaning blocks of nr_pages pages are written back cycling around the page cache entries for each inode in each superblock).

We acquire [struct bdi_writeback-\>list_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) in order to modify the b\_-

lists, then invoke [queue_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1416) to transfer inodes with outstanding I/O from b_more_io to b_io and unconditionally queue all b_dirty inodes regardless of whether they have expired or not, as this is an emergency measure for ex-treme memory pressure, and dirty inodes must be written back in order for reclaim to proceed.

In this instance the actual writeback is performed by

[\_\_writeback_inodes_wb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1917), which we shall return to in Listing 10-56.

Having examined this emergency writeback mode, we return to the usual

procedure and examine [wb_do_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2174) in Listing 10-50 (eliding out of scope tracing hook).

 

2171 */\**

2172 *\* Retrieve work items and do the writeback they describe* 2173 *\*/*

2174 **static long wb_do_writeback**(**struct** bdi_writeback \*wb) 2175 {

2176 **struct** wb_writeback_work \*work; 2177 **long** wrote = 0;

2178

2179 **set_bit**(**WB_writeback_running**, &wb-\>state); 2180 **while** ((work = **get_next_work_item**(wb)) != **NULL**) {

. . .

2182 wrote += **wb_writeback**(wb, work); 2183 **finish_writeback_work**(wb, work); 2184 }

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2185

2186 */\**

2187 *\* Check for a flush-everything request* 2188 *\*/*

2189 wrote += **wb_check_start_all**(wb); 2190

2191 */\**

2192 *\* Check for periodic writeback, kupdated() style* 2193 *\*/*

2194 wrote += **wb_check_old_data_flush**(wb); 2195 wrote += **wb_check_background_flush**(wb); 2196 **clear_bit**(**WB_writeback_running**, &wb-\>state); 2197

2198 **return** wrote;

2199 }

 

*Listing 10-50:* fs/fs-writeback.c: [*wb_do_writeback()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2174)

 

During core writeback in [wb_do_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2174), the

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>state field has the [WB_writeback_running](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n26) flag set,

which is used by the [writeback_in_progress()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev.h?h=v6.0#n131) to determine whether a write-

back is in progress, used by [balance_dirty_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1557) and [bdi_split_work_to_wbs()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n936)

to avoid unnecessary work.

The function starts by looping through all of the writeback work in addi-

tion to the standard periodic writeback, [get_next_work_item()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2081) to pop the next

entry off the [struct bdi_writeback-\>work_list](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105). We examine this in Listing **??**.

 

2078 */\**

2079 *\* Return the next wb_writeback_work struct that hasn't been processed yet.*

2080 *\*/*

2081 **static struct** wb_writeback_work \***get_next_work_item**(**struct** bdi_writeback \*wb) 2082 {

2083 **struct** wb_writeback_work \*work = **NULL**; 2084

2085 **spin_lock_irq**(&wb-\>work_lock); 2086 **if** (!**list_empty**(&wb-\>work_list)) { 2087 work = **list_entry**(wb-\>work_list.next, 2088 **struct** wb_writeback_work, list); 2089 **list_del_init**(&work-\>list); 2090 }

2091 **spin_unlock_irq**(&wb-\>work_lock); 2092 **return** work;

2093 }

 

*Listing 10-51:* fs/fs-writeback.c: [*get_next_work_item()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2081)

 

This is the mirror image of [wb_queue_work()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n159) (shown in Listing 10-34),

which places [struct wb_writeback_work](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42) entries on the tail (i.e. end) of the list,

so here we pop from the head of the list (i.e. its first entry) each time. This

makes this a work queue.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

Each time an entry is retrieved the work_lock is taken and the work entry

is deleted from the work list and reinitialised via [list_del_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/list.h?h=v6.0#n204)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/list.h?h=v6.0#n204)

Each individual work entry is then passed directly to [wb_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1988), the

core writeback function, as a priority before any periodic work is considered.

This is vital, as this work will be specified by synchronisation operations

and specify writeback work that must be performed immediately.

After each work item is processed, [finish_writeback_work()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n143)

is invoked which handles freeing of the work object if

[struct wb_writeback_work-\>auto_free](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42) is specified and calling back any

callers which are waiting on [struct wb_writeback_work-\>done](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42).

Once these work list items have been processed, we proceed

with the usual, periodic cases, which are handled by three differ-

ent functions—[wb_check_start_all()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2147)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2147) [wb_check_old_data_flush()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2113) and

[wb_check_background_flush() .](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2095)

The [wb_check_start_all()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2147) function is the function which ultimately per-

forms the writeback that [wb_start_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1188) scheduled (see Listing 10-37).

We examine this in Listing 10-52.

 

2147 **static long wb_check_start_all**(**struct** bdi_writeback \*wb) 2148 {

2149 **long** nr_pages;

2150

2151 **if** (!**test_bit**(**WB_start_all**, &wb-\>state)) 2152 **return** 0; 2153

2154 nr_pages = **get_nr_dirty_pages**(); 2155 **if** (nr_pages) {

2156 **struct** wb_writeback_work work = { 2157 .nr_pages = **wb_split_bdi_pages**(wb, nr_pages), 2158 .sync_mode = **WB_SYNC_NONE**, 2159 .range_cyclic = 1, 2160 .reason = wb-\>start_all_reason, 2161 };

2162

2163 nr_pages = **wb_writeback**(wb, &work); 2164 }

2165

2166 **clear_bit**(**WB_start_all**, &wb-\>state); 2167 **return** nr_pages;

2168 }

 

*Listing 10-52:* fs/fs-writeback.c: [*wb_check_start_all()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2147)

 

This uses [get_nr_dirty_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1182) to obtain an estimate of the number

of dirty pages, establishing a [struct wb_writeback_work](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42) object, specifying that the number of pages should be scaled to the write bandwidth of the

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) object describing the writeback via [wb_split_bdi_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n906)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n906) This is specifically implemented to handle cgroup-mediated writeback which is out of scope of the book so we will not examine this.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

The work is cyclic, and thus we set [struct address_space-\>writeback_index](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)

of each relevant page cache entry to the next index at which we should re-

sume writeback (see discussion around Listing 10-25 for more details).

The work is only performed if the [WB_start_all](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n28) flag is set in

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>state , and cleared once it is complete. We have already

ensured only one such action should be in flight at any one time (see the dis-

cussion around Listing Listing 10-37 for details).

Ultimately the function, as with each that initiate file system writeback,

defers to [wb_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1988) (see Listing 10-55).

The [wb_check_background_flush()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2095) function checks to see if the back-

ground writeback limits established by vm.dirty_background_bytes or

vm.dirty_background_ratio have been exceeded. We examine it in Listing **??**.

 

2095 **static long wb_check_background_flush**(**struct** bdi_writeback \*wb) 2096 {

2097 **if** (**wb_over_bg_thresh**(wb)) { 2098

2099 **struct** wb_writeback_work work = { 2100 .nr_pages = **LONG_MAX**, 2101 .sync_mode = **WB_SYNC_NONE**, 2102 .for_background = 1, 2103 .range_cyclic = 1, 2104 .reason = **WB_REASON_BACKGROUND**, 2105 };

2106

2107 **return wb_writeback**(wb, &work); 2108 }

2109

2110 **return** 0;

2111 }

 

*Listing 10-53:* fs/fs-writeback.c: [*wb_check_background_flush()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2095)

 

This determines whether the background writeback threshold has been

exceeded via [wb_over_bg_thresh()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1964)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1964) We examine this in Section 10.14 and List-

ing 10-103. If the limits are exceeded, we then perform background write-

back of all dirty pages attached to the the [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)

We indicate that this operation is for background writeback by setting

the for_background flag.

These prior functions are run only if either synchronisation is requested

or background writeback is triggered, the true workhorse of writeback is

[wb_check_old_data_flush(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2113)which performs ordinary periodic writeback. We

examine it in Listing **??**.

 

2113 **static long wb_check_old_data_flush**(**struct** bdi_writeback \*wb) 2114 {

2115 **unsigned long** expired; 2116 **long** nr_pages;

2117

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2118 */\**

2119 *\* When set to zero, disable periodic writeback* 2120 *\*/*

2121 **if** (!**dirty_writeback_interval**) 2122 **return** 0; 2123

2124 expired = wb-\>last_old_flush + 2125 **msecs_to_jiffies**(**dirty_writeback_interval** \* 10); 2126 **if** (**time_before**(jiffies, expired)) 2127 **return** 0; 2128

2129 wb-\>last_old_flush = jiffies; 2130 nr_pages = **get_nr_dirty_pages**(); 2131

2132 **if** (nr_pages) {

2133 **struct** wb_writeback_work work = { 2134 .nr_pages = nr_pages, 2135 .sync_mode = **WB_SYNC_NONE**, 2136 .for_kupdate = 1, 2137 .range_cyclic = 1, 2138 .reason = **WB_REASON_PERIODIC**, 2139 };

2140

2141 **return wb_writeback**(wb, &work); 2142 }

2143

2144 **return** 0;

2145 }

 

*Listing 10-54:* fs/fs-writeback.c: [*wb_check_old_data_flush()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2113)

 

The vm.dirty_expire_centisecs tunable is maintained in the

[dirty_writeback_interval](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n101) global variable. If this is set to zero, this implies that periodic writeback is simply disabled and so the function exists.

Otherwise, before proceeding with periodic writeback, we check to

determine whether [struct bdi_writeback-\>last_old_flush](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) is younger than vm.dirty_expire_centisecs. If so, we abort the operation, which helps us avoid fruitless examination of inodes which will not be old enough to have ex-pired.

We indicate that the writeback is the standard periodic writeback of ex-

pired inodes by setting the for_kupdate flag. This form of writeback can be referred to as a ‘kupdate’ writeback for historic reasons.

Again we initiate a cyclic writeback for all dirty pages and defer the heavy

lifting to [wb_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1988)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1988) which we examine in Listing 10-55 (eliding out of scope trace and block device plug hooks).

 

1973 */\**

1974 *\* Explicit flushing or periodic writeback of "old" data.* 1975 *\**

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1976 *\* Define "old": the first time one of an inode's pages is dirtied, we mark*

*the*

1977 *\* dirtying-time in the inode's address_space. So this periodic writeback*

*code*

1978 *\* just walks the superblock inode list, writing back any inodes which are*

1979 *\* older than a specific point in time.* 1980 *\**

1981 *\* Try to run once per dirty_writeback_interval. But if a writeback event*

1982 *\* takes longer than a dirty_writeback_interval interval, then leave a* 1983 *\* one-second gap.*

1984 *\**

1985 *\* dirtied_before takes precedence over nr_to_write. So we'll only write back*

1986 *\* all dirty pages if they are all attached to "old" mappings.* 1987 *\*/*

1988 **static long wb_writeback**(**struct** bdi_writeback \*wb, 1989 **struct** wb_writeback_work \*work) 1990 {

1991 **long** nr_pages = work-\>nr_pages; 1992 **unsigned long** dirtied_before = jiffies; 1993 **struct** inode \*inode; 1994 **long** progress;

. . .

1998 **spin_lock**(&wb-\>list_lock); 1999 **for** (;;) {

2000 */\**

2001 *\* Stop writeback when nr_pages has been consumed* 2002 *\*/*

2003 **if** (work-\>nr_pages \<= 0) 2004 **break**; 2005

2006 */\**

2007 *\* Background writeout and kupdate-style writeback may* 2008 *\* run forever. Stop them if there is other work to do* 2009 *\* so that e.g. sync can proceed. They'll be restarted* 2010 *\* after the other works are all done.* 2011 *\*/*

2012 **if** ((work-\>for_background \|\| work-\>for_kupdate) && 2013 !**list_empty**(&wb-\>work_list)) 2014 **break**; 2015

2016 */\**

2017 *\* For background writeout, stop when we are below the* 2018 *\* background dirty threshold* 2019 *\*/*

2020 **if** (work-\>for_background && !**wb_over_bg_thresh**(wb)) 2021 **break**; 2022

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2023 */\**

2024 *\* Kupdate and background works are special and we want to*

2025 *\* include all inodes that need writing. Livelock avoidance is*

2026 *\* handled by these works yielding to any other work so we are*

2027 *\* safe.*

2028 *\*/*

2029 **if** (work-\>for_kupdate) { 2030 dirtied_before = jiffies -2031 **msecs_to_jiffies**(dirty_expire_interval \* 10); 2032 } **else if** (work-\>for_background) 2033 dirtied_before = jiffies;

. . .

2036 **if** (**list_empty**(&wb-\>b_io)) 2037 **queue_io**(wb, work, dirtied_before); 2038 **if** (work-\>sb) 2039 progress = **writeback_sb_inodes**(work-\>sb, wb, work); 2040 **else**

2041 progress = **\_\_writeback_inodes_wb**(wb, work);

. . .

2044 */\**

2045 *\* Did we write something? Try for more* 2046 *\**

2047 *\* Dirty inodes are moved to b_io for writeback in batches.*

2048 *\* The completion of the current batch does not necessarily*

2049 *\* mean the overall work is done. So we keep looping as long*

2050 *\* as made some progress on cleaning pages or inodes.* 2051 *\*/*

2052 **if** (progress) 2053 **continue**; 2054 */\**

2055 *\* No more inodes for IO, bail* 2056 *\*/*

2057 **if** (**list_empty**(&wb-\>b_more_io)) 2058 **break**; 2059 */\**

2060 *\* Nothing written. Wait for some inode to* 2061 *\* become available for writeback. Otherwise* 2062 *\* we'll just busyloop.* 2063 *\*/*

. . .

2065 inode = **wb_inode**(wb-\>b_more_io.prev); 2066 **spin_lock**(&inode-\>i_lock); 2067 **spin_unlock**(&wb-\>list_lock); 2068 */\* This function drops i_lock... \*/* 2069 **inode_sleep_on_writeback**(inode); 2070 **spin_lock**(&wb-\>list_lock); 2071 }

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

2072 **spin_unlock**(&wb-\>list_lock);

. . .

2075 **return** nr_pages - work-\>nr_pages; 2076 }

 

*Listing 10-55:* fs/fs-writeback.c: [*wb_writeback()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1988)

 

**N O T E** Moving forward we will refer to the standard periodic background writeback as

*kupdate* to clearly separate this from inlvboldbackground writeback executed because

the *vm.background_ratio* or *vm.background_bytes* background dirty limits were ex-

ceeded.

 

This function loops until either—the [struct wb_writeback_work-\>nr_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42)

field is at or below zero, indicating the work is complete, the task is

background or kupdate writeback but there is outstanding higher priority work

to be performed, the task is performing background writeback but the

threshold has been reached, or finally no progress has been made.

We examine the details of the logic of this function in Figure 10-10.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

Work is complete when

[struct wb_writeback_work-\>nr_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42) 0. *≤*

 

Yes

Complete? Exit

 

No

Other

Kind of work?

Background kupdate

 

There is other, higher priority work

if [struct bdi_writeback-\>work_list](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)

is non-empty.

 

Exit, [wb_workfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2205)

Yes

Other work? will immediately

Exit

reschedule

No

No, Background

[wb_over_bg_thresh()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1964) No, kupdate [?](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1964)

 

Yes, update

dirtied_before

Examine all inodes older

Examine all inodes vm.dirty_expire_centisecs than

 

Pending I/O exists if

[struct bdi_writeback-\>b_io](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) is non-empty.

 

No

[queue_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1416) Pending I/O?

 

Yes

Superblock specified if

Superblock?

[struct wb_writeback_work-\>sb](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42) is non-NULL. Yes No

 

Per-SB

[writeback_sb_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772) [\_\_writeback_inodes_wb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1917)

 

Yes

Progress?

 

No

Yes No

b_more_io? Exit

 

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>b_more_io [inode_sleep_on_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1482) on eldest

inodes may have I_SYNC set. b_more_io inode to wait for I_SYNC.

 

*Figure 10-10:* [*wb_writeback()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1988) *Logic*


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

**N O T E** An important nuance to note here is that the *dirtied_before* argument is set prior to

the loop starting. Therefore, any inodes dirtied after the loop begins will be processed,

avoiding live locks where newly inodes cause the loop to continue indefinitely. This

value is updated, however, if this is background or *kupdate* writeback as described

below.

 

This operates in a loop, processing all pending work specified by func-

tions called by [wb_workfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2205) (see Listing 10-44), whose call graph can be ob-

served in Figure 10-8.

Note that the function relies on this when encountering pending work

items in [struct bdi_writeback-\>work_list](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105), exiting in order that [wb_workfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2205) can

immediately reinvoke the flusher thread to process the pending work, priori-

tising it over any background or kupdate writeback.

Equally, [writeback_sb_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772) and [\_\_writeback_inodes_wb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1917) periodically

exit in order to check termination conditions such as the background write-

back threshold no longer being exceeded for a background writeback task

(checked via [wb_over_bg_thresh()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1964), which we examine in Section 10.14 and List-

ing 10-103).

If this is a background writeback, the dirtied_when parameter is reset

to the current time permitting the writeback of newly dirtied inodes un-

til dirty pages is reduced below the background dirty threshold. Equally a

kupdate writeback invocation examines inodes older than the current time

less vm.dirty_expire_centisecs and updates this on each loop. Other forms of

writeback do not reset this time.

It is here where the core invocation of [queue_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1416) is performed (see

Listing 10-46), before either [writeback_sb_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772) (see Listing 10-57) or

[\_\_writeback_inodes_wb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1917) are invoked (see Listing 10-56). The former is the key

writeback function for writeback to a specific superblock, which the latter

invokes for each inode’s super block individually.

We partition inodes by superblock as we require each super

block to be locked against unmount during the writeback operation.

[\_\_writeback_inodes_wb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1917) acquires this lock for each inode’s super block which

we will examine in Listing 10-56.

As discussed around the listing for [move_expired_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1354) (invoked by

[queue_io()), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1416)Listing 10-47, the queued inode list is sorted by super block, so

we will already naturally have this ordering when processing inodes.

As further inodes might have been dirtied during this operation,

this function will continue to loop as long as progress is made by

[writeback_sb_inodes() .](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772)

If no progress is made, then we check the edge case where inodes could

not be processed due to various reasons (which we will examine shortly

when we explore [writeback_sb_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772)[),](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772) and have thus been appended to

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>b_more_io.

These may be due to a concurrent writeback process having been initi-

ated. When an inode is submitted to [writeback_sb_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772) it has its i_state

field updated with the [I_SYNC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2442) flag set, which is only cleared once the inode

has all dirty folios submitted for writeback to the underlying block device.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

This failing to have occurred, resulting in the inode being transferred to

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>b_more_io, means it is sensible for us to wait for the next inode which we plan to process to have its I/O submitted to avoid potentially

busy-looping in [wb_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1988).

This is performed by [inode_sleep_on_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1482) which causes the process

to sleep until this flag is cleared, if it is indeed currently set.

We next examine the function which performs writeback on all super

blocks owned by all inodes scheduled for writeback, [\_\_writeback_inodes_wb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1917)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1917)

which we examine in Listing 10-56.

 

1917 **static long \_\_writeback_inodes_wb**(**struct** bdi_writeback \*wb, 1918 **struct** wb_writeback_work \*work) 1919 {

1920 **unsigned long** start_time = **jiffies**; 1921 **long** wrote = 0;

1922

1923 **while** (!**list_empty**(&wb-\>b_io)) { 1924 **struct** inode \*inode = **wb_inode**(wb-\>b_io.prev); 1925 **struct** super_block \*sb = inode-\>i_sb; 1926

1927 **if** (!**trylock_super**(sb)) { 1928 */\** 1929 *\* trylock_super() may fail consistently due to* 1930 *\* s_umount being grabbed by someone else. Don't use*

1931 *\* requeue_io() to avoid busy retrying the inode/sb.*

1932 *\*/* 1933 **redirty_tail**(inode, wb); 1934 **continue**; 1935 }

1936 wrote += **writeback_sb_inodes**(sb, wb, work); 1937 **up_read**(&sb-\>s_umount); 1938

1939 */\* refer to the same tests at the end of writeback_sb_inodes*

*\*/*

1940 **if** (wrote) { 1941 **if** (**time_is_before_jiffies**(start_time + **HZ** / 10**UL**)) 1942 **break**; 1943 **if** (work-\>nr_pages \<= 0) 1944 **break**; 1945 }

1946 }

1947 */\* Leave any unwritten inodes on b_io \*/* 1948 **return** wrote;

1949 }

 

*Listing 10-56:* fs/fs-writeback.c: [*\_\_writeback_inodes_wb()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1917)

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

This function simply iterates through each of the inodes in

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>b_io, working backwards, therefore working from the

oldest inode to youngest.

It then attempts to acquire the inode’s [struct super_block-\>s_umount](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n1451) lock

via [trylock_super()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/super.c?h=v6.0#n413). It does not wait on this lock, if the lock is not imme-

diately available, the inode is immediately ‘redirtied’, i.e. placed on the

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>b_dirty list via [redirty_tail()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1308) (we examine this later in

Listing 10-59).

Each inode is then subject to writeback via the core [writeback_sb_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772)

function (see Listing 10-57). This function returns the number of pages

which have successfully been scheduled for writeback, which we accumulate

and ultimately return to the caller.

This function is rate-limited (in a similar fashion to [writeback_sb_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772))

to a hardcoded maximum one tenth of a second interval between iterations,

assuming at least 1 page has been written back (i.e. we process all inodes

until we make at least 1 page’s progress). Additionally we manually check to

see if the work task has been completed, at which point we exit early.

This allows for the function to exit to its caller on a regular basis to see if

any conditions have arisen which would terminate the writeback.

Now we have examined the functions which ultimately invoke

[writeback_sb_inodes() , ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772)it’s time to examine this function in detail, which we

do in Listing 10-57 (eliding irrelevant tracing hooks and realtime scheduler

rescheduling logic).

 

1763 */\**

1764 *\* Write a portion of b_io inodes which belong to @sb.* 1765 *\**

1766 *\* Return the number of pages and/or inodes written.* 1767 *\**

1768 *\* NOTE! This is called with wb-\>list_lock held, and will* 1769 *\* unlock and relock that for each inode it ends up doing* 1770 *\* IO for.*

1771 *\*/*

1772 **static long writeback_sb_inodes**(**struct** super_block \*sb, 1773 **struct** bdi_writeback \*wb, 1774 **struct** wb_writeback_work \*work) 1775 {

1776 **struct** writeback_control wbc = { 1777 .sync_mode = work-\>sync_mode, 1778 .tagged_writepages = work-\>tagged_writepages, 1779 .for_kupdate = work-\>for_kupdate, 1780 .for_background = work-\>for_background, 1781 .for_sync = work-\>for_sync, 1782 .range_cyclic = work-\>range_cyclic, 1783 .range_start = 0, 1784 .range_end = **LLONG_MAX**, 1785 };

1786 **unsigned long** start_time = jiffies;

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1787 **long** write_chunk; 1788 **long** total_wrote = 0; */\* count both pages and inodes \*/*

 

*Listing 10-57:* fs/fs-writeback.c: [*writeback_sb_inodes()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772) *preface*

 

The writeback core, as described in Section 10.10 uses the

[struct writeback_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n50) object to manage the process (explored in Listing

10-24), which we must generate based on the [struct wb_writeback_work](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42) argu-ment.

We always specify the entire range of the dirty inodes by setting

range_start and range_end appropriately. For writeback spanning only a sub-

set of folios belonging to an inode, file writeback by [fsync()](https://man7.org/linux/man-pages/man2/fsync.2.html) and related APIs

must be used (see Section 10.13).

At this stage we do not specify the nr_to_write parameter, which we will

specify later on in the function based on an empirically determined ‘chunk size’ which we will discuss below.

We note the start time using the global jiffies value before proceeding

with the core writeback loop beginning in Listing 10-58.

 

1790 **while** (!**list_empty**(&wb-\>b_io)) { 1791 **struct** inode \*inode = **wb_inode**(wb-\>b_io.prev); 1792 **struct** bdi_writeback \*tmp_wb; 1793 **long** wrote; 1794

1795 **if** (inode-\>i_sb != sb) { 1796 **if** (work-\>sb) { 1797 */\** 1798 *\* We only want to write back data for this*

1799 *\* superblock, move all inodes not belonging*

1800 *\* to it back onto the dirty list.* 1801 *\*/* 1802 **redirty_tail**(inode, wb); 1803 **continue**; 1804 } 1805

1806 */\** 1807 *\* The inode belongs to a different superblock.* 1808 *\* Bounce back to the caller to unpin this and* 1809 *\* pin the next superblock.* 1810 *\*/* 1811 **break**; 1812 }

1813

1814 */\**

1815 *\* Don't bother with new inodes or inodes being freed, first*

1816 *\* kind does not need periodic writeout yet, and for the*

*latter*

1817 *\* kind writeout is handled by the freer.* 1818 *\*/*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1819 **spin_lock**(&inode-\>i_lock); 1820 **if** (inode-\>i_state & (**I_NEW** \| **I_FREEING** \| **I_WILL_FREE**)) { 1821 **redirty_tail_locked**(inode, wb); 1822 **spin_unlock**(&inode-\>i_lock); 1823 **continue**; 1824 }

1825 **if** ((inode-\>i_state & **I_SYNC**) && wbc.sync_mode != **WB_SYNC_ALL**)

{

1826 */\** 1827 *\* If this inode is locked for writeback and we are*

*not*

1828 *\* doing writeback-for-data-integrity, move it to* 1829 *\* b_more_io so that writeback can proceed with the*

1830 *\* other inodes on s_io.* 1831 *\** 1832 *\* We'll have another go at writing back this inode*

1833 *\* when we completed a full scan of b_io.* 1834 *\*/* 1835 **requeue_io**(inode, wb); 1836 **spin_unlock**(&inode-\>i_lock);

. . .

1838 **continue**; 1839 }

1840 **spin_unlock**(&wb-\>list_lock); 1841 */\**

1842 *\* We already requeued the inode if it had I_SYNC set and we*

1843 *\* are doing WB_SYNC_NONE writeback. So this catches only the*

1844 *\* WB_SYNC_ALL case.* 1845 *\*/*

1846 **if** (inode-\>i_state & **I_SYNC**) { 1847 */\* Wait for I_SYNC. This function drops i_lock... \*/*

1848 **inode_sleep_on_writeback**(inode); 1849 */\* Inode may be gone, start again \*/* 1850 **spin_lock**(&wb-\>list_lock); 1851 **continue**; 1852 }

 

*Listing 10-58:* fs/fs-writeback.c: [*writeback_sb_inodes()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772) *initial checks*

 

We iterate through each [struct inode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593) in the [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>b_io

list, moving backwards through the list, therefore acquiring the eldest inode

first which is the appropriate ordering as the intent is to minimise how out

of date the on-disk representation of the data is in comparison to its state in

the page cache.

We then perform a series of initial checks, firstly ensuring that the inode

belongs to the super block. This is important, as we enter this function with

the super block locked against unmount, and therefore absolutely must limit

ourselves to processing inodes which belong to specified superblock.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

In order to put this check in context we examine from where

[writeback_sb_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772) is called. This is either by either [\_\_writeback_inodes_wb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1917)

(see Listing 10-56) or [wb_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1988) (see Listing 10-55).

In the former case, [\_\_writeback_inodes_wb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1917) is invoked either by

[writeback_inodes_wb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1951) which specifies a [struct wb_writeback_work](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42) object without sb specified and iterates through inodes backwards invoking

[writeback_sb_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772) specifying a super block of [struct inode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593)-\>i_sb, or via

[wb_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1988) again only when no [struct wb_writeback_work-\>sb](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42) is specified.

When we queue inodes via [move_expired_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1354) (see Listing 10-47, note

this function is invoked by [queue_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1416) shown in Listing 10-46) we ensure that inodes are grouped by superblock.

Therefore, in the case of writeback arising via [\_\_writeback_inodes_wb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1917)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1917) the

test for work-\>sb simply does not apply, and this check simply breaks out of

the loop (thereby exiting the function) which causes [\_\_writeback_inodes_wb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1917) to iterate to the next superblock which is locked against unmount.

The remaining case is an invocation from [wb_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1988) (see Listing 10-

55) where [struct wb_writeback_work-\>sb](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42) is specified.

The [struct wb_writeback_work-\>sb](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42) parameter is set in two places—

[\_\_writeback_inodes_sb_nr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2588) (see Listing 10-42) and [sync_inodes_sb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2667) (see List-

ing 10-39), each of which are precipitated by a [sync()](https://man7.org/linux/man-pages/man2/sync.2.html) or [syncfs()](https://man7.org/linux/man-pages/man2/syncfs.2.html) system call, the former iterating through all superblocks and the later limiting itself to a single one.

We can observe how these functions queue work and wake up the write-

back flusher threads in Figure 10-7.

In each of these instances, when queueing work via [queue_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1416), inodes

which belong to another superblock may indeed be queued for writeback,

which we simply append to the the [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>b_dirty list.

Since we can rely on inodes being partitioned by superblock, by simply

continuing the loop here each time we encounter an irrelevant inode, we will eventually reach the inodes which need writeback.

Since we keep ‘redirtying’ the inodes, these will eventually get picked

up again. If they are inodes belonging to a synchronisation-specified

[struct wb_writeback_work](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42) task found in [struct bdi_writeback-\>work_list](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105), these

will simply be scheduled to be processed later by [wb_workfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2205) (see Listing 10-

44), if they are specific to background or kupdate flushing, these are pro-

cessed last by [wb_workfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2205) so will get queued later. We can see how this logic

fits into [wb_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1988) in Figure 10-10.

The ‘redirtying’ process is performed by [redirty_tail()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1308) shown in Listing

10-59.

 

1308 **static void redirty_tail**(**struct** inode \*inode, **struct** bdi_writeback \*wb) 1309 {

1310 **spin_lock**(&inode-\>i_lock); 1311 **redirty_tail_locked**(inode, wb); 1312 **spin_unlock**(&inode-\>i_lock); 1313 }

 

*Listing 10-59:* fs/fs-writeback.c: [*redirty_tail()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1308)

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

This locks the inode and defers the actual redirtying to

[redirty_tail_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1293) shown in Listing 10-60.

 

1284 */\**

1285 *\* Redirty an inode: set its when-it-was dirtied timestamp and move it to the*

1286 *\* furthest end of its superblock's dirty-inode list.* 1287 *\**

1288 *\* Before stamping the inode's -\>dirtied_when, we check to see whether it is*

1289 *\* already the most-recently-dirtied inode on the b_dirty list. If that is*

1290 *\* the case then the inode must have been redirtied while it was being written*

1291 *\* out and we don't reset its dirtied_when.* 1292 *\*/*

1293 **static void redirty_tail_locked**(**struct** inode \*inode, **struct** bdi_writeback \*wb) 1294 {

1295 **assert_spin_locked**(&inode-\>i_lock); 1296

1297 **if** (!**list_empty**(&wb-\>b_dirty)) { 1298 **struct** inode \*tail; 1299

1300 tail = **wb_inode**(wb-\>b_dirty.next); 1301 **if** (**time_before**(inode-\>dirtied_when, tail-\>dirtied_when)) 1302 inode-\>dirtied_when = jiffies; 1303 }

1304 **inode_io_list_move_locked**(inode, wb, &wb-\>b_dirty); 1305 inode-\>i_state &= ~**I_SYNC_QUEUED**; 1306 }

 

*Listing 10-60:* fs/fs-writeback.c: [*redirty_tail_locked()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1293)

 

This ultimately moves the inode to the tail of the

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>b_dirty list using [inode_io_list_move_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n118)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n118) clearing

its [I_SYNC_QUEUED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2452) flag to indicate that the inode is no longer queued for

writeback (a flag that is set by [move_expired_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1354)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1354) shown in Listing 10-47).

 

**N O T E** Despite [*redirty_tail_locked()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1293)’s name, the [*inode_io_list_move_locked()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n118) function ul-

timately invokes [*list_move()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/list.h?h=v6.0#n215) rather than [*list_move_tail()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/list.h?h=v6.0#n226), meaning that the inode

is actually placed at the head of [*struct bdi_writeback-\>b_dirty*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) rather than its tail.

However, since we process inodes backwards, the inode is thereby placed at the back of

this list, so is conceptually indeed its tail.

 

We have to be careful about the inode’s timestamp here, it is vital to

maintain the ordering of inodes on [struct bdi_writeback-\>b_dirty](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) in age or-

der, so before placing the inode at the head of this list, we examine the ex-

isting head. If it is older than this, which was the previously youngest entry in

this list, we restamp it to the current time.

Returning to the [writeback_sb_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772) initial check logic we were exam-

ining in Listing 10-58, we next acquire the [struct inode-\>i_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593) as we wish to

keep the inode stable as we examine it for subsequent state checks.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

We check whether the inode is either new, freeing or soon to be freed.

As the comment suggests, none of these indicate writeout is currently re-

quired. We redirty the inode using [redirty_tail_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1293) directly as we al-ready hold the inode’s lock, unlock it and continue on to the next inode.

Finally, we check the case where the inode is already being processed for

writeback. This can occur if [writeback_single_inode()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1670) has been triggered to immediately writeback an inode.

We don’t examine [writeback_single_inode()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1670) for the sake of brevity, but

broadly speaking it mimics [writeback_sb_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772) only explicitly writing only a

single inode with a user-specified [struct writeback_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n50) object.

inodes are serialised between these calls using the [I_SYNC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2442) state flag, which

is set immediately after this check is successfully completed.

There are two variants of this case we must consider—where synchro-

nisation is required, i.e. where completion of writeback implies that the data is actually written back to disk rather than simply scheduled to be written back, and where this is not required. This is indicated by the

[struct wb_writeback_work-\>sync_mode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42) being set to the [enum writeback_sync_mode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n40)

value [WB_SYNC_ALL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n42)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n42)

In the case where it is not required, we can simply requeue the inode for

later processing by placing it on the [struct bdi_writeback-\>b_more_io](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) list using

[requeue_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1318) which very simply moves the inode to this list as shown in List-ing **??**.

 

1315 */\**

1316 *\* requeue inode for re-scanning after bdi-\>b_io list is exhausted.* 1317 *\*/*

1318 **static void requeue_io**(**struct** inode \*inode, **struct** bdi_writeback \*wb) 1319 {

1320 **inode_io_list_move_locked**(inode, wb, &wb-\>b_more_io); 1321 }

 

*Listing 10-61:* fs/fs-writeback.c: [*requeue_io()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1318)

 

You can observe how the [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>b_more_io list is processed

in [wb_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1988) (see Listing 10-55) in Figure 10-10. Note that all entries in

this list are immediately queued on the next invocation of [queue_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1416) (see

Listing 10-46).

If we do require sync however, we do not move the inode, but rather wait

for the writeback process to complete via [inode_sleep_on_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1482).

Once these checks are complete, we are ready to move on with schedul-

ing the actual writeback in [writeback_sb_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772) which we examine in Listing

10-62.

 

1854 inode-\>i_state \|= **I_SYNC**; 1855 **wbc_attach_and_unlock_inode**(&wbc, inode); 1856

1857 write_chunk = **writeback_chunk_size**(wb, work); 1858 wbc.nr_to_write = write_chunk; 1859 wbc.pages_skipped = 0;

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1860

1861 */\**

1862 *\* We use I_SYNC to pin the inode in memory. While it is set*

1863 *\* evict_inode() will wait so the inode cannot be freed.* 1864 *\*/*

1865 **\_\_writeback_single_inode**(inode, &wbc); 1866

1867 **wbc_detach_inode**(&wbc); 1868 work-\>nr_pages -= write_chunk - wbc.nr_to_write; 1869 wrote = write_chunk - wbc.nr_to_write - wbc.pages_skipped;

1870 wrote = wrote \< 0 ? 0 : wrote; 1871 total_wrote += wrote;

. . .

 

*Listing 10-62:* fs/fs-writeback.c: [*writeback_sb_inodes()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772) *writeback*

 

We start by marking the inode being processed for writeback via [I_SYNC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2442),

preventing any other part of the kernel from simultaneously attempting

writeback (i.e. [writeback_single_inode()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1670)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1670) nor attempt to evict the inode meta-

data from memory.

The function invokes [wbc_attach-and_unlock_inode()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n691) which is out of scope

for our discussion here as it is specific to cgroup-moderated writeback, how-

ever note that it as the function name suggests drops the inode lock.

It’s at this point we determine how many pages to write back via

[writeback_chunk_size(). ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1732)This determines how many pages to attempt to write-

back in one operation. Note that for writeback work which is either synchro-

nised (i.e. [struct wb_writeback_work-\>sync_mode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42) is set to [WB_SYNC_ALL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n42)) or those

tasks which have [struct wb_writeback_work](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42)-\>tagged_writeback set, this chunking

doesn’t apply (this applies to [\_\_writeback_inodes_sb_nr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2588) and [sync_inodes_wb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2667)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2667)

both of which are invoked by [sync()](https://man7.org/linux/man-pages/man2/sync.2.html) and/or [syncfs()](https://man7.org/linux/man-pages/man2/syncfs.2.html) system calls).

We defer the description of [writeback_chunk_size()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1732) to Section 10.14 in

Listing 10-102 as this relates directly to dirty throttling logic within the ker-

nel.

Again the [wbc_detach_inode()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n761) function relates to cgroup writeback func-

tionality and thus is out of scope for the book. Finally the actual writeback

is executed in [\_\_writeback_single_inode()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1576)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1576) which we examine below in Listing

10-67.

After the writeback has been kicked off, statistics are updated

accordingl[y—](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42)[struct wb_writeback_work-\>nr_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n42) is decremented by the num-

ber of pages written back or skipped and the total actually written pages is

added to the total_write counter which is ultimately returned to the caller.

Finally, we examine the post-writeback handling at the end of the core

loop in Listing 10-63.

 

1886 */\**

1887 *\* Requeue @inode if still dirty. Be careful as @inode may*

1888 *\* have been switched to another wb in the meantime.* 1889 *\*/*

1890 tmp_wb = **inode_to_wb_and_lock_list**(inode);

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1891 **spin_lock**(&inode-\>i_lock); 1892 **if** (!(inode-\>i_state & **I_DIRTY_ALL**)) 1893 total_wrote++; 1894 **requeue_inode**(inode, tmp_wb, &wbc); 1895 **inode_sync_complete**(inode); 1896 **spin_unlock**(&inode-\>i_lock); 1897

1898 **if** (**unlikely**(tmp_wb != wb)) { 1899 **spin_unlock**(&tmp_wb-\>list_lock); 1900 **spin_lock**(&wb-\>list_lock); 1901 }

1902

1903 */\**

1904 *\* bail out to wb_writeback() often enough to check* 1905 *\* background threshold and other termination conditions.*

1906 *\*/*

1907 **if** (total_wrote) { 1908 **if** (**time_is_before_jiffies**(start_time + **HZ** / 10UL)) 1909 **break**; 1910 **if** (work-\>nr_pages \<= 0) 1911 **break**; 1912 }

1913 }

1914 **return** total_wrote; 1915 }

 

*Listing 10-63:* fs/fs-writeback.c: [*writeback_sb_inodes()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772) *suffix*

We start by looking up the current [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) object associated

with the inode. This might have changed if cgroup-mediate writeback is in place which we take care to account for (though discussion of this is out of scope for the book). We also increment total_wrote if the inode metadata itself was written back.

There are two key functions which are invoked at this point—

[requeue_inode()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1505), which determines whether the inode needs to be requeued

or writeback is complete for it, which we examine in Listing 10-64 and

[inode_sync_complete() , ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1323)whose core task is to clear the inode’s [I_SYNC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2442) flag, wak-ing up anything that was waiting on it to be cleared.

After this is done, the function checks to determine if the hard-coded

tenth of a second interval period has expired since the previously stored start time of the operation, in which case we break out of the loop and re-

turn to [wb_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1988) (see Listing 10-55) to proceed as shown in Figure 10-

10, in case conditions have arisen which would result in termination of the writeback.

The requeue logic in [requeue_inode()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1505) crucially checks whether the inode

was completely written out, whether work remains and where to place the

inode. We examine it in Listing 10-64 (eliding out of scope dirty time han-dling).

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1497 */\**

1498 *\* Find proper writeback list for the inode depending on its current state and*

1499 *\* possibly also change of its state while we were doing writeback. Here we*

1500 *\* handle things such as livelock prevention or fairness of writeback among*

1501 *\* inodes. This function can be called only by flusher thread - noone else*

1502 *\* processes all inodes in writeback lists and requeueing inodes behind*

*flusher*

1503 *\* thread's back can have unexpected consequences.* 1504 *\*/*

1505 **static void requeue_inode**(**struct** inode \*inode, **struct** bdi_writeback \*wb, 1506 **struct** writeback_control \*wbc) 1507 {

1508 **if** (inode-\>i_state & **I_FREEING**) 1509 **return**;

1510

1511 */\**

1512 *\* Sync livelock prevention. Each inode is tagged and synced in one*

1513 *\* shot. If still dirty, it will be redirty_tail()'ed below. Update*

1514 *\* the dirty time to prevent enqueue and sync it again.* 1515 *\*/*

1516 **if** ((inode-\>i_state & **I_DIRTY**) && 1517 (wbc-\>sync_mode == **WB_SYNC_ALL** \|\| wbc-\>tagged_writepages)) 1518 inode-\>dirtied_when = jiffies; 1519

1520 **if** (wbc-\>pages_skipped) { 1521 */\**

1522 *\* writeback is not making progress due to locked* 1523 *\* buffers. Skip this inode for now.* 1524 *\*/*

1525 **redirty_tail_locked**(inode, wb); 1526 **return**;

1527 }

1528

1529 **if** (**mapping_tagged**(inode-\>i_mapping, **PAGECACHE_TAG_DIRTY**)) { 1530 */\**

1531 *\* We didn't write back all the pages. nfs_writepages()* 1532 *\* sometimes bales out without doing anything.* 1533 *\*/*

1534 **if** (wbc-\>nr_to_write \<= 0) { 1535 */\* Slice used up. Queue for next turn. \*/* 1536 **requeue_io**(inode, wb); 1537 } **else** {

1538 */\** 1539 *\* Writeback blocked by something other than* 1540 *\* congestion. Delay the inode for some time to* 1541 *\* avoid spinning on the CPU (100% iowait)* 1542 *\* retrying writeback of the dirty page/inode*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1543 *\* that cannot be performed immediately.* 1544 *\*/* 1545 **redirty_tail_locked**(inode, wb); 1546 }

1547 } **else if** (inode-\>i_state & **I_DIRTY**) { 1548 */\**

1549 *\* Filesystems can dirty the inode during writeback operations*

*,*

1550 *\* such as delayed allocation during submission or metadata*

1551 *\* updates after data IO completion.* 1552 *\*/*

1553 **redirty_tail_locked**(inode, wb);

. . .

1558 } **else** {

1559 */\* The inode is clean. Remove from writeback lists. \*/* 1560 **inode_cgwb_move_to_attached**(inode, wb); 1561 }

1562 }

 

*Listing 10-64:* fs/fs-writeback.c: [*requeue_inode()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1505)

 

This processes each inode, determining whether to place it back on

the [struct bdi_writeback-\>b_dirty](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) list via [redirty_tail_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1293) (see List-

ing 10-60), requeue it onto the [struct bdi_writeback-\>b_more_io](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) list via

[requeue_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1318) (see Listing **??**) or remove it from these lists altogether via

[inode_cgwb_move_to_attached()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n278) (see Listing 10-65).

We explore the logic of this function in Figure 10-11.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

inode is [?](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2439)

[I_FREEING](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2439) Yes Leave on b_io,

evictor will handle.

No

Live lock is a risk if this is a syn-

chronisation update (WB_SYNC_ALL

or work-\>tagged_writepages

is specified).

 

Yes Update dirtied_when

Sync update?

to the current time.

No

Redirty via Yes

Skipped pages?

[redirty_tail_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1293)

No No

 

wbc-\>nr_to_write 0? *≤* Yes

inode dirty pages?

 

Yes No

Requeue via [requeue_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1318) Yes Dirty inode?

 

No

Remove from lists via

[inode_cgwb_move_to_attached()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n278)

 

*Figure 10-11:* [*requeue_inode()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1505) *Logic*

 

We start by checking whether the inode is currently being freed, if so

we need do nothing as this will eventually be evicted. In addition logic else-

where in the writeback code will skip freeing inodes so it has no material

impact on writeback.

We then cover a special case where we try to avoid live-lock when

performing synchronisation writeback, where inodes may be con-

stantly redirtied and processed again. We avoid this by resetting the

[struct inode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593)-\>dirtied_when timestamp to now, which causes those inodes to

not be queued again on the next loop in [wb_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1988) (see Listing 10-55), as

shown in Figure 10-10.

Next we determine if any pages were skipped during writeback due to

the filesystem declining to perform writeback, a count of which is main-

tained in [struct writeback_control-\>pages_skipped](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n50). If so, then we cannot make

further progress on this inode at this time (perhaps requiring locks to be re-

leased before proceeding), and therefore we redirty the inode in question via

[redirty_tail_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1293) (see Listing 10-60).

We then consider cases where the inode is still dirty—in this instance we

must requeue the inode as it has not yet completed its writeback I/O.

We start by determining if any inode folios are still dirty using the xarray

associated with the inode’s [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) via [mapping_tagged()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n459). if so,

then we proceed on the basis that dirty data remains.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

In this case, where we have simply written at or beyond the current spec-

ified chunk size, we requeue the I/O for a subsequent run via [requeue_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1318) (see Listing **??**).

If it was not the ‘slice’ of data being insufficient to writeback the

entire inode, we take the safe route and simply redirty the inode via

[redirty_tail_locked() .](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1293)

If no folio associated with the inode is dirty but the inode is still marked

as such, then this indicates that inode metadata itself requires writeback so

in this instance we also redirty via [redirty_tail_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1293)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1293)

Finally, if no requeueing is deemed to be required, we remove the inode

from all lists using [inode_cgwb_move_to_attached()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n278)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n278) as shown in Listing 10-65.

 

270 */\*\**

271 *\* inode_cgwb_move_to_attached - put the inode onto wb-\>b_attached list* 272 *\* @inode: inode of interest with i_lock held* 273 *\* @wb: target bdi_writeback* 274 *\**

275 *\* Remove the inode from wb's io lists and if necessarily put onto b_attached*

276 *\* list. Only inodes attached to cgwb's are kept on this list.* 277 *\*/*

278 **static void inode_cgwb_move_to_attached**(**struct** inode \*inode, 279 **struct** bdi_writeback \*wb) 280 {

281 **assert_spin_locked**(&wb-\>list_lock); 282 **assert_spin_locked**(&inode-\>i_lock); 283

284 inode-\>i_state &= ~**I_SYNC_QUEUED**; 285 **if** (wb != &wb-\>bdi-\>wb) 286 **list_move**(&inode-\>i_io_list, &wb-\>b_attached); 287 **else**

288 **list_del_init**(&inode-\>i_io_list); 289 **wb_io_lists_depopulated**(wb); 290 }

 

*Listing 10-65:* fs/fs-writeback.c: [*inode_cgwb_move_to_attached()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n278)

 

This function starts by clearing the inode’s [I_SYNC_QUEUED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2452) flag to indi-

cate that it is no longer on any queue. The move logic is specific to cgroup

writeback where the inode’s [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) may have changed. This is out of scope for the book, so we rather consider the case where it is sim-ply removed from the list on which it resides and has its list node reset by

[list_del_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/list.h?h=v6.0#n204).

This also invokes [wb_io_lists_depopulated()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n98)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n98) which does the inverse of

[wb_io_lists_populated()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n85) (see Listing 10-48) and clears the [WB_has_dirty_io](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n27) flag

in the [struct bdi_writeback-\>state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) field, as shown in Listing 10-66.

 

98 **static void wb_io_lists_depopulated**(**struct** bdi_writeback \*wb) 99 {

100 **if** (**wb_has_dirty_io**(wb) && **list_empty**(&wb-\>b_dirty) &&

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

101 **list_empty**(&wb-\>b_io) && **list_empty**(&wb-\>b_more_io)) { 102 **clear_bit**(**WB_has_dirty_io**, &wb-\>state); 103 **WARN_ON_ONCE**(**atomic_long_sub_return**(wb-\>avg_write_bandwidth, 104 &wb-\>bdi-\>tot_write_bandwidth) \< 0);

105 }

106 }

 

*Listing 10-66:* fs/fs-writeback.c: [*wb_io_lists_depopulated()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n98)

 

This resets the [WB_has_dirty_io](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n27) flag if all [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) lists are

empty, and updates bandwidth statistics.

Returning to [writeback_sb_inodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1772), specifically the portion which invokes

writeback as shown in Listing 10-62, this invokes [\_\_writeback_single_inode()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1576)

which invokes the actual writeback, which we examine in Listing 10-67 (elid-

ing irrelevant trace hook points and out of scope dirty time handling and

fscache pinning logic).

 

1564 */\**

1565 *\* Write out an inode and its dirty pages (or some of its dirty pages,*

*depending*

1566 *\* on @wbc-\>nr_to_write), and clear the relevant dirty flags from i_state.*

1567 *\**

1568 *\* This doesn't remove the inode from the writeback list it is on, except* 1569 *\* potentially to move it from b_dirty_time to b_dirty due to timestamp* 1570 *\* expiration. The caller is otherwise responsible for writeback list*

*handling.*

1571 *\**

1572 *\* The caller is also responsible for setting the I_SYNC flag beforehand and*

1573 *\* calling inode_sync_complete() to clear it afterwards.* 1574 *\*/*

1575 **static int**

1576 **\_\_writeback_single_inode**(**struct** inode \*inode, **struct** writeback_control \*wbc) 1577 {

1578 **struct** address_space \*mapping = inode-\>i_mapping; 1579 **long** nr_to_write = wbc-\>nr_to_write; 1580 **unsigned** dirty;

1581 **int** ret;

1582

1583 **WARN_ON**(!(inode-\>i_state & **I_SYNC**));

. . .

1587 ret = **do_writepages**(mapping, wbc); 1588

1589 */\**

1590 *\* Make sure to wait on the data before writing out the metadata.* 1591 *\* This is important for filesystems that modify metadata on data* 1592 *\* I/O completion. We don't do it for sync(2) writeback because it has*

*a*

1593 *\* separate, external IO completion path and -\>sync_fs for*

*guaranteeing*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1594 *\* inode metadata is written back correctly.* 1595 *\*/*

1596 **if** (wbc-\>sync_mode == **WB_SYNC_ALL** && !wbc-\>for_sync) { 1597 **int** err = **filemap_fdatawait**(mapping); 1598 **if** (ret == 0) 1599 ret = err; 1600 }

. . .

1615 */\**

1616 *\* Get and clear the dirty flags from i_state. This needs to be done*

1617 *\* after calling writepages because some filesystems may redirty the*

1618 *\* inode during writepages due to delalloc. It also needs to be done*

1619 *\* after handling timestamp expiration, as that may dirty the inode*

*too.*

1620 *\*/*

1621 **spin_lock**(&inode-\>i_lock); 1622 dirty = inode-\>i_state & **I_DIRTY**; 1623 inode-\>i_state &= ~dirty; 1624

1625 */\**

1626 *\* Paired with smp_mb() in \_\_mark_inode_dirty(). This allows* 1627 *\* \_\_mark_inode_dirty() to test i_state without grabbing i_lock -*

1628 *\* either they see the I_DIRTY bits cleared or we see the dirtied*

1629 *\* inode.*

1630 *\**

1631 *\* I_DIRTY_PAGES is always cleared together above even if @mapping*

1632 *\* still has dirty pages. The flag is reinstated after smp_mb() if*

1633 *\* necessary. This guarantees that either \_\_mark_inode_dirty()* 1634 *\* sees clear I_DIRTY_PAGES or we see PAGECACHE_TAG_DIRTY.* 1635 *\*/*

1636 **smp_mb**();

1637

1638 **if** (**mapping_tagged**(mapping, **PAGECACHE_TAG_DIRTY**)) 1639 inode-\>i_state \|= **I_DIRTY_PAGES**;

. . .

1648 **spin_unlock**(&inode-\>i_lock); 1649

1650 */\* Don't write the inode if only I_DIRTY_PAGES was set \*/* 1651 **if** (dirty & ~**I_DIRTY_PAGES**) { 1652 **int** err = **write_inode**(inode, wbc); 1653 **if** (ret == 0) 1654 ret = err; 1655 }

. . .

1658 **return** ret;

1659 }

 

*Listing 10-67:* fs/fs-writeback.c: [*\_\_writeback_single_inode()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1576)

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

This function immediately invokes [do_writepages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2457) shown in Listing 10-23

and Section 10.10 which performs the actual writeback. The remainder of

the function performs housekeeping tasks after completion.

We next cover the case of synchronised writeback which has not origi-

nated from a synchronisation system call such as [sync()](https://man7.org/linux/man-pages/man2/sync.2.html) or [syncfs()](https://man7.org/linux/man-pages/man2/syncfs.2.html)[.](https://man7.org/linux/man-pages/man2/syncfs.2.html) In those

cases, waiting is handled by the calling functions [(](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2637)[writeback_inodes_sb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2637), see

Listing 10-40 and [sync_inodes_sb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2667)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2667) see Listing 10-39), so in these instances

[\_\_writeback_single_inode()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1576) need not perform the wait. For other synchronis-

ing cases, this is not the case and we must explicitly wait, which is achieved

via [filemap_fdatawait()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n41) which we examine in the subsequent file writeback

Section 10.13 in Listing 10-72.

In all invocations of this function, the dirty flags of the inode are cleared,

regardless of the outcome of the operation, under [struct inode-\>i_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593).

If we subsequently discover that at least one page cache folio contain-

ing the data of the inode remains dirty, we update the inode state re-

gardless, with a careful locking negotiation, pairing a memory barrier

with [\_\_mark_inode_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2363) (see Listing 10-2) to permit the latter to check

[struct inode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593)-\>i_state without a lock.

Finally, if the inode metadata is dirty, the inode is written back via

[write_inode(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1434)however this is out of scope for the book.

 

**10.13 File Writeback**

 

We’ve seen how writeback proceeds at a file system granularity, but there re-

mains another means by which writeback can proceed—at a file granularity.

Users can request the synchronisation of an open file descriptor to disk

via the [fsync()](https://man7.org/linux/man-pages/man2/fsync.2.html) or [fdatasync()](https://man7.org/linux/man-pages/man2/fdatasync.2.html) system calls and the synchronisation of individ-

ual pages of a [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) memory-mapped file via [msync()](https://man7.org/linux/man-pages/man2/msync.2.html)[.](https://man7.org/linux/man-pages/man2/msync.2.html)

 

**N O T E** Users can also specify the synchronisation of individual pages of an open file descrip-

tor via [*sync_file_range()*](https://man7.org/linux/man-pages/man2/sync_file_range.2.html), however the use of this system call is heavily discouraged

as dangerous, so we don’t examine it in detail. This system call ultimately invokes

the same functions that we examine here in any case.

 

In Section 10.6 and Figure 10-4 we examine these synchronisation meth-

ods, each of which ultimately invoke the kernel functions [filemap_flush()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n452)

(see Listing 10-68), [file_write_and_wait_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n767) (see Listing 10-74) and

[file_write_and_wait_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n767) (see Listing 10-74). In addition, we’ve observed

that [\_\_writeback_single_inode()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1576) (see Listing 10-67) invokes [filemap_fdatawait()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n41)

(see Listing 10-72).

We will examine each of these functions, but the key point to observe

here is that ultimately all of these functions and any others which per-

form writeback on a file granularity ultimately invoke two core functions—

[\_\_filemap_fdatawrite_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n411) and [\_\_filemap_fdatawait_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n501)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n501)

We observe how each of the aforementioned calls ultimately end up call-

ing this pair functions in Figure 10-12.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

[fsync()](https://man7.org/linux/man-pages/man2/fsync.2.html) and [fdatasync()](https://man7.org/linux/man-pages/man2/fdatasync.2.html)

 

[file_write_and_wait_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n767)

 

[syncfs()](https://man7.org/linux/man-pages/man2/syncfs.2.html) for blockdev [syncfs()](https://man7.org/linux/man-pages/man2/syncfs.2.html) for blockdev [\_\_writeback_single_inode()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n1576)

 

[filemap_flush()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n452) [filemap_write_and_wait()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n58) [filemap_fdatawait()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n41)

 

[\_\_filemap_fdatawrite()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n424) [filemap_write_and_wait_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n667) [filemap_fdatawait_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n548)

 

[\_\_filemap_fdatawrite_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n411) [\_\_filemap_fdatawait_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n501)

 

*Figure 10-12: File Writeback Call Stack*

 

Let’s examine each of the functions referenced here, starting with

[filemap_flush()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n452) in Listing 10-68.

 

443 */\*\**

444 *\* filemap_flush - mostly a non-blocking flush* 445 *\* @mapping:* *target address_space* 446 *\**

447 *\* This is a mostly non-blocking flush. Not suitable for data-integrity* 448 *\* purposes - I/O may not be started against all dirty pages.* 449 *\**

450 *\* Return: %0 on success, negative error code otherwise.* 451 *\*/*

452 **int filemap_flush**(**struct** address_space \*mapping) 453 {

454 **return \_\_filemap_fdatawrite**(mapping, **WB_SYNC_NONE**); 455 }

 

*Listing 10-68:* mm/filemap.c: [*filemap_flush()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n452)

 

This function simply defers its operation to [\_\_filemap_fdatawrite()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n424)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n424) speci-

fying [WB_SYNC_NONE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n41) to indicate that no synchronisation should be applied. We

examine this in Listing 10-69.

 

424 **static inline int \_\_filemap_fdatawrite**(**struct** address_space \*mapping, 425 **int** sync_mode)

426 {

427 **return \_\_filemap_fdatawrite_range**(mapping, 0, **LLONG_MAX**, sync_mode); 428 }

 

*Listing 10-69:* mm/filemap.c: [*\_\_filemap_fdatawrite()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n424)

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

This simply defers its operation to the core function [\_\_filemap_fdatawrite](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n411),

specifying that the entire file be written back. We examine this in Listing

10-69.

Next we examine [filemap_write_and_wait()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n667) in **??**.

 

58 **static inline int filemap_write_and_wait**(**struct** address_space \*mapping)

59 {

60 **return filemap_write_and_wait_range**(mapping, 0, **LLONG_MAX**);

61 }

 

*Listing 10-70:* /include/linux/pagemap.h: [*filemap_write_and_wait()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree//include/linux/pagemap.h?h=v6.0#n58)

 

This simply defers the heavy lifting to [filemap_write_and_wait_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n667)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n667) spec-

ifying the entire range of the Listing 10-71.

 

654 \*\*

655 \* **filemap_write_and_wait_range**- write out & wait on a file range 656 \* @mapping: the address_space **for** the pages 657 \* @lstart: offset in bytes where the range starts 658 \* @lend: offset in bytes where the range ends (inclusive) 659 \*

660 \* Write out and wait upon file offsets lstart-\>lend, inclusive. 661 \*

662 \* Note that @lend is inclusive (describes the last byte to be written) so

663 \* that this function can be used to write to the very end-of-file (end = -1).

664 \*

665 \* Return: error status of the address space. 666 \*/

667 **int filemap_write_and_wait_range**(**struct** address_space \*mapping, 668 loff_t lstart, loff_t lend) 669 {

670 **int** err = 0, err2;

671

672 **if** (**mapping_needs_writeback**(mapping)) { 673 err = **\_\_filemap_fdatawrite_range**(mapping, lstart, lend, 674 **WB_SYNC_ALL**); 675 */\**

676 *\* Even if the above returned error, the pages may be* 677 *\* written partially (e.g. -ENOSPC), so we wait for it.* 678 *\* But the -EIO is special case, it may indicate the worst*

679 *\* thing (e.g. bug) happened, so we avoid waiting for it.* 680 *\*/*

681 **if** (err != -**EIO**) 682 **\_\_filemap_fdatawait_range**(mapping, lstart, lend); 683 }

684 err2 = **filemap_check_errors**(mapping); 685 **if** (!err)

686 err = err2; 687 **return** err;

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

688 }

 

*Listing 10-71:* mm/filemap.c: [*filemap_write_and_wait_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n667)

 

This uses [mapping_needs_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n625) to determine whether to proceed

which simply checks whether [struct address_space-\>nrpages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) is non-zero. This field indicates how many pages are present in the page cache for this page cache entry, if none are present then writeback can not possibly proceed and therefore there is no point in trying to do so.

After this, the actual writing is performed by [\_\_filemap_fdatawrite_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n411)

(see Listing 10-75) specifying [WB_SYNC_ALL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n42) to indicate that all writes will be synchronised.

Other than in the case where an EIO error arises (indicating an error

which would have prevented writeback generally), we then wait for the op-

eration to complete via [\_\_filemap_fdatawait_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n501) (shown in Listing 10-77).

This seems redundant, as we have already specified [WB_SYNC_ALL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n42)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n42) however

this flag only results in waiting on writeback in the file system writeback logic described above, for file writeback, we must perform the waiting our-selves and this flag simply provides the context to underlying logic that the operation will proceed synchronously.

Finally this checks for errors that occurred during writeback that

will have been placed in the [struct address_space-\>flags](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) field. This is

done via [filemap_check_errors()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n344)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n344) which clears these flags and reports the relevant errors (prioritising ones that were returned directly by

[\_\_filemap_fdatawrite_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n411).

Next we examine [filemap_fdatawait()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n41) in Listing 10-72.

 

41 **static inline int filemap_fdatawait**(**struct** address_space \*mapping) 42 {

43 **return filemap_fdatawait_range**(mapping, 0, **LLONG_MAX**); 44 }

 

*Listing 10-72:* include/linux/pagemap.h: [*filemap_fdatawait()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n41)

 

This defers its operation to [filemap_fdatawait_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n548)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n548) specifying that the

writeback for the entire file should be waited upon. This is shown in Listing

10-73.

 

532 */\*\**

533 *\* filemap_fdatawait_range - wait for writeback to complete* 534 *\* @mapping:* *address space structure to wait for* 535 *\* @start_byte:* *offset in bytes where the range starts* 536 *\* @end_byte:* *offset in bytes where the range ends (inclusive)* 537 *\**

538 *\* Walk the list of under-writeback pages of the given address space* 539 *\* in the given range and wait for all of them. Check error status of* 540 *\* the address space and return it.* 541 *\**

542 *\* Since the error status of the address space is cleared by this function,*

543 *\* callers are responsible for checking the return value and handling and/or*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

544 *\* reporting the error.*

545 *\**

546 *\* Return: error status of the address space.* 547 *\*/*

548 **int filemap_fdatawait_range**(**struct** address_space \*mapping, loff_t start_byte, 549 loff_t end_byte) 550 {

551 **\_\_filemap_fdatawait_range**(mapping, start_byte, end_byte); 552 **return filemap_check_errors**(mapping); 553 }

 

*Listing 10-73:* mm/filemap.c: [*filemap_fdatawait_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n548)

 

This defers the heavy lifting to [\_\_filemap_fdatawait_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n501) (shown in List-

ing 10-77), before running [filemap_check_errors()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n344) to pick up any errors at-

tached to the [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) object.

Finally, we examine [file_write_and_wait_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n767)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n767) shown in Listing 10-74.

 

751 */\*\**

752 *\* file_write_and_wait_range - write out & wait on a file range* 753 *\* @file:* *file pointing to address_space with pages* 754 *\* @lstart:* *offset in bytes where the range starts* 755 *\* @lend:* *offset in bytes where the range ends (inclusive)* 756 *\**

757 *\* Write out and wait upon file offsets lstart-\>lend, inclusive.* 758 *\**

759 *\* Note that @lend is inclusive (describes the last byte to be written) so*

760 *\* that this function can be used to write to the very end-of-file (end = -1).*

761 *\**

762 *\* After writing out and waiting on the data, we check and advance the* 763 *\* f_wb_err cursor to the latest value, and return any errors detected there.*

764 *\**

765 *\* Return: %0 on success, negative error code otherwise.* 766 *\*/*

767 **int file_write_and_wait_range**(**struct** file \*file, loff_t lstart, loff_t lend) 768 {

769 **int** err = 0, err2; 770 **struct** address_space \*mapping = file-\>f_mapping;

771

772 **if** (**mapping_needs_writeback**(mapping)) { 773 err = **\_\_filemap_fdatawrite_range**(mapping, lstart, lend, 774 **WB_SYNC_ALL**); 775 */\* See comment of filemap_write_and_wait() \*/* 776 **if** (err != -**EIO**) 777 **\_\_filemap_fdatawait_range**(mapping, lstart, lend); 778 }

779 err2 = **file_check_and_advance_wb_err**(file); 780 **if** (!err)

781 err = err2;

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

782 **return** err;

783 }

 

*Listing 10-74:* mm/filemap.c: [*file_write_and_wait_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n767)

This defers the write and wait to [\_\_filemap_fdatawrite_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n411) (see List-

ing 10-75) and [\_\_filemap_fdatawait_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n501) (see Listing 10-77) similar to

[filemap_write_and_wait_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n667) shown in Listing 10-71 above. However a key

difference here is that this function invokes [file_check_and_advance_wb_err()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n723)

rather than [filemap_check_errors()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n344)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n344) This keeps track of the last write error at

a [struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) granularity. For brevity we will omit a close examination fo this logic.

Now we have examined the core means by which we reach

[\_\_filemap_fdatawrite_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n411) and [\_\_filemap_fdatawait_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n501)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n501) we will examine these functions in detail.

We begin by examining [\_\_filemap_fdatawrite_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n411) in Listing 10-75.

 

394 */\*\**

395 *\* \_\_filemap_fdatawrite_range - start writeback on mapping dirty pages in*

*range*

396 *\* @mapping:* *address space structure to write* 397 *\* @start:* *offset in bytes where the range starts* 398 *\* @end:* *offset in bytes where the range ends (inclusive)* 399 *\* @sync_mode: enable synchronous operation* 400 *\**

401 *\* Start writeback against all of a mapping's dirty pages that lie* 402 *\* within the byte offsets \<start, end\> inclusive.* 403 *\**

404 *\* If sync_mode is WB_SYNC_ALL then this is a "data integrity" operation, as*

405 *\* opposed to a regular memory cleansing writeback. The difference between*

406 *\* these two operations is that if a dirty page/buffer is encountered, it must*

407 *\* be waited upon, and not just skipped over.* 408 *\**

409 *\* Return: %0 on success, negative error code otherwise.* 410 *\*/*

411 **int \_\_filemap_fdatawrite_range**(**struct** address_space \*mapping, loff_t start, 412 loff_t end, **int** sync_mode) 413 {

414 **struct** writeback_control wbc = { 415 .sync_mode = sync_mode, 416 .nr_to_write = **LONG_MAX**, 417 .range_start = start, 418 .range_end = end, 419 };

420

421 **return filemap_fdatawrite_wbc**(mapping, &wbc); 422 }

 

*Listing 10-75:* mm/filemap.c: [*\_\_filemap_fdatawrite_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n411)

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

This establishes a [struct writeback_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n50) object used to proceed with

writeback, passing this to [filemap_fdatawrite_wbc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n378) to perform the writeback,

as shown in Listing 10-76.

 

368 */\*\**

369 *\* filemap_fdatawrite_wbc - start writeback on mapping dirty pages in range*

370 *\* @mapping:* *address space structure to write* 371 *\* @wbc:* *the writeback_control controlling the writeout* 372 *\**

373 *\* Call writepages on the mapping using the provided wbc to control the* 374 *\* writeout.*

375 *\**

376 *\* Return: %0 on success, negative error code otherwise.* 377 *\*/*

378 **int filemap_fdatawrite_wbc**(**struct** address_space \*mapping, 379 **struct** writeback_control \*wbc) 380 {

381 **int** ret;

382

383 **if** (!**mapping_can_writeback**(mapping) \|\| 384 !**mapping_tagged**(mapping, **PAGECACHE_TAG_DIRTY**)) 385 **return** 0;

386

387 **wbc_attach_fdatawrite_inode**(wbc, mapping-\>host); 388 ret = **do_writepages**(mapping, wbc); 389 **wbc_detach_inode**(wbc); 390 **return** ret;

391 }

 

*Listing 10-76:* mm/filemap.c: [*filemap_fdatawrite_wbc()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n378)

 

This starts by checking whether the mapping has any pages in the page

cache via [mapping_can_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev.h?h=v6.0#n138) and whether any are tagged dirty, checked

via [mapping_tagged()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n459)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n459) either of these not being the case indicates that there is

no writeback to perform and if so we simply exit early.

Otherwise we invoke writeback cgroup-specific logic via

[wbc_attach_fdatawrite_inode()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n269) and [wbc_detach_inode()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n761) surrounding the core

writeback function [do_writepages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2457) (see Listing 10-23).

The cgroup writeback logic is out of scope for the book, and the core

writeback logic is described in detail in Section 10.10.

We will now examine the core [\_\_filemap_fdatawait_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n501) function in

Listing 10-77.

 

501 **static void \_\_filemap_fdatawait_range**(**struct** address_space \*mapping, 502 **loff_t** start_byte, **loff_t** end_byte) 503 {

504 **pgoff_t** index = start_byte \>\> **PAGE_SHIFT**; 505 **pgoff_t** end = end_byte \>\> **PAGE_SHIFT**; 506 **struct** pagevec pvec;

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

507 **int** nr_pages;

508

509 **if** (end_byte \< start_byte) 510 **return**;

511

512 **pagevec_init**(&pvec); 513 **while** (index \<= end) { 514 **unsigned** i; 515

516 nr_pages = **pagevec_lookup_range_tag**(&pvec, mapping, &index, 517 end, **PAGECACHE_TAG_WRITEBACK**); 518 **if** (!nr_pages) 519 **break**; 520

521 **for** (i = 0; i \< nr_pages; i++) { 522 **struct** page \*page = pvec.pages\[i\]; 523

524 **wait_on_page_writeback**(page); 525 **ClearPageError**(page); 526 }

527 **pagevec_release**(&pvec); 528 **cond_resched**(); 529 }

530 }

 

*Listing 10-77:* mm/filemap.c: [*\_\_filemap_fdatawait_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n501)

 

This iterates through folio batches at a time of folios tagged

with [PAGECACHE_TAG_WRITEBACK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n453) (it uses the legacy form of folio batches,

[struct pagevec](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n22). This behaves the same as folio batches, which are described

in Section 11.7).

It uses [pagevec_lookup_range_tag()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n1058) (which in turn invokes

[find_get_pages_range_tag()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2272)) to retrieve folios tagged with

[PAGECACHE_TAG_WRITEBACK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n453), i.e. ones which are in the midst of being writ-

ten back, and then uses [wait_on_page_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n30) to wait until this operation is complete.

The [wait_on_page_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n30) function wraps [folio_wait_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n3031), which

we examine in Section 9.11 and Listing 9-146. This causes the process to sleep until each folio’s writeback flag has been cleared, indicating the folio has been written back.

After each wait period, if the folio had been marked with an error using

the [PG_error](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n109) flag this is cleared using the ClearPageError() flag.

After each batch is processed, it is freed via [pagevec_release()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n68) and real-

time kernel scheduling modes are able to reschedule using [cond_resched()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n2082) (this is out of scope for the book).

The net result is all folios being written back to disk are waited upon as

required.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

**10.14 Dirty Throttling**

 

In the process of performing writeback, it is absolutely vital to ensure that

the system does not get overwhelmed with writeback requests to the point

that the system becomes unstable.

In such a circumstance the system might become unstable as critical

functions such as swap become bogged down, preventing the computer

from being able to function correctly at all.

In addition, reaching a point where the number of dirty pages is such

that the page cache is significantly inconsistent with the disk state it is

caching dramatically increases the risk of data corruption should writeback

not quickly resolve the situation.

Under ordinary circumstances no restrictions need be applied, pages can

be dirtied and then written back as normal. However once a certain degree

of pages are dirty, the kernel must take steps to mitigate this scenario.

The primary means by which this is mediated is through the

vm.dirty_background_ratio (or alternatively vm.dirty_background_bytes) and

vm.dirty_ratio (or vm.dirty_bytes) tunables.

These specify the maximum degree to which the system accumulates

dirty pages, with the ratio values expressed as a proportion of available

‘dirtyable’ memory, i.e. memory that could be dirtied, before certain action

is taken by the kernel:

 

**Background dirty limits** vm.dirty_background_ratio (or, alternatively, ex-

pressed as vm.dirty_background_bytes) dictate when the kernel addresses the issue that page cache state has become significantly inconsistent against disk state by initiating writeback that, as the name suggests, oc-curs in the background utilising the file system writeback described in

Section 10.11. This defaults to using vm.dirty_background_ratio equal to 10% of dirtyable memory.

**Foreground dirty limits** vm.dirty_ratio (or alternatively vm.dirty_bytes) dic-

tate the hard limit at which processes writing back to a block device block when dirtying pages until writeback can ensure that the proportion of dirty pages has dropped below this threshold again. This defaults to us-ing vm.dirty_ratio equal to 20% of dirtyable memory.

 

This does not tell the whole story, however. Between these two limits, it’s

important to ensure that we throttle dirtying of pages according to the level

of bandwidth utilised per block device, taking proactive steps to avoid the

worst case scenario of the hard limit being reached globally from occurring.

It’s also important to note that all the writeback that actually occurs as a

result of dirty throttling is performed via background writeback, we throttle

by simply ‘pausing’ processes which require it to keep us at an acceptable

dirtying rate.

The overall process of activating background writeback and blocking pro-

cesses in order to manage writeback is termed dirty throttling.

We will examine how this works in detail, but before we do we will exam-

ine what the ratio versions of the aforementioned tunables are a proportion

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

of. This is what is referred to as the global (i.e. system-wide) dirtyable pages count.

This is determined by the [global_dirtyable_memory()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n344) function, shown in

Listing 10-78 (eliding out of scope 32-bit system high memory logic).

 

338 */\*\**

339 *\* global_dirtyable_memory - number of globally dirtyable pages* 340 *\**

341 *\* Return: the global number of pages potentially available for dirty* 342 *\* page cache. This is the base value for the global dirty limits.* 343 *\*/*

344 **static unsigned long global_dirtyable_memory**(**void**) 345 {

346 **unsigned long** x;

347

348 x = **global_zone_page_state**(**NR_FREE_PAGES**); 349 */\**

350 *\* Pages reserved for the kernel should not be considered* 351 *\* dirtyable, to prevent a situation where reclaim has to* 352 *\* clean pages in order to balance the zones.* 353 *\*/*

354 x -= **min**(x, **totalreserve_pages**); 355

356 x += **global_node_page_state**(**NR_INACTIVE_FILE**); 357 x += **global_node_page_state**(**NR_ACTIVE_FILE**);

. . .

362 **return** x + 1; */\* Ensure that we never return 0 \*/* 363 }

 

*Listing 10-78:* mm/page-writeback.c: [*global_dirtyable_memory()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n344)

 

This uses kernel statistics to determine how many free pages are available

on the system, as each free page could end up mapped to a page cache entry and become dirty. It sums this with the total number of file pages, subtract-

ing the global [totalreserve_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n264) count, which comprises the sum of all zone

high water marks and worst-case low memory reserve (see Section 2.4.2 for details on how this is calculated).

The means by which dirty throttling is applied is by the

[balance_dirty_pages_ratelimited()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1949) function being invoked each time a page

cache object is dirtied, which we examine in Listing 10-79.

This should be invoked by any function which dirties page cache entries,

after the dirtying has taken place. This is therefore invoked by numerous file system-specific functions, but also generic writeback functionality, specifi-

cally in [generic_perform_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3701) as part of file write dirty tracking (see Section

10.12 and Listing 10-11) and in [fault_dirty_shared_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n2993) (see Listing 6-40 in

Section 6.9) as part of memory-mapped page fault handling.

 

1937 */\*\**

1938 *\* balance_dirty_pages_ratelimited - balance dirty memory state.*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1939 *\* @mapping: address_space which was dirtied.* 1940 *\**

1941 *\* Processes which are dirtying memory should call in here once for each page*

1942 *\* which was newly dirtied. The function will periodically check the system's*

1943 *\* dirty state and will initiate writeback if needed.* 1944 *\**

1945 *\* Once we're over the dirty memory limit we decrease the ratelimiting* 1946 *\* by a lot, to prevent individual processes from overshooting the limit* 1947 *\* by (ratelimit_pages) each.* 1948 *\*/*

1949 **void balance_dirty_pages_ratelimited**(**struct** address_space \*mapping) 1950 {

1951 **balance_dirty_pages_ratelimited_flags**(mapping, 0); 1952 }

 

*Listing 10-79:* mm/page-writeback.c: [*balance_dirty_pages_ratelimited()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1949)

 

This invokes [balance_dirty_pages_ratelimited_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1880) in turn, which we

examine below in Listing 10-81. Before we do so, we should examine how

the dirty balancing functions conceptually.

The ultimate intent is to prevent the number of dirty pages in the system

from exceeding a proportion of all ‘dirtyable’ pages (vm.dirty_ratio) or an

explicit number of bytes (vm.dirty_bytes).

However precisely how we do this matters. The least sensible way of do-

ing this would be to wait until the system hits the global dirty limit and cause

all threads that dirty pages to sleep until writeback brings us back below the

limit.

Imagine a single thread writing to a slow medium at a rate exceeding its

ability to write back—having the kernel block all writeback to all block de-

vices until we drop below the limit would cause all writing threads to stall

until the slow medium had all of its data written out, resulting in an unstable

system.

In this scenario it is also difficult to determine how long to wait for and

getting this wrong could lock up the system altogether.

So this is certainly not sensible, however nor is throttling threads too

soon—in the instance where the number of dirtied pages are below the dirty

threshold, it’d simply be wasteful to unnecessarily put any thread to sleep

when dirtying pages.

 

**N O T E** To avoid having to repeatedly refer to *vm.dirty_background_ratio* or

*vm.dirty_background_bytes*, and *vm.dirty_ratio* or *vm.dirty_bytes*, we will instead

say ‘background threshold’ and ‘dirty threshold’ respectively, from this point on.

 

We must therefore find a solution that performs better. Ultimately the

kernel’s weapon for battling too many dirty pages is to put threads to sleep

so they can no longer dirty pages. All of the dirty throttling logic attempts to

do so in sensible fashion as follows:

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

**Throttle threads earlier** Instead of only putting threads to sleep at the dirty

threshold, we start doing so prior to reaching this limit so we avoid un-necessarily long stalls.

**Divide dirtying into scopes** Designate two different ‘scopes’ within which

dirtying can occur—a freerun scope where no dirtying threads are put to sleep at all, and a global dirty control scope where threads are put to sleep for an appropriate period of time up to the dirty threshold.

**Keep track of writeback bandwidth** In order to inform the degree to which

threads are paused, we keep track of each [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)[’s](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) write bandwidth, i.e. how many dirty pages per second are written back on av-

erage in [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>avg_write_bandwidth.

**Scale threads based on dirty rate** The degree to which a thread contributes

towards the number of dirtied pages is equal to the number of pages dirtied since last paused, therefore we use this metric to scale throttling per-thread.

**Keep track of each thread’s dirtied pages** In order to scale threads this way

it is vital to track how many pages each thread has dirtied. This is done

in [struct task_struct-\>nr_dirtied](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) which counts how many pages were dirt-

ied since last examined by [balance_dirty_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1557) (which we examine be-

low in Listing 10-97) at [struct task_struct-\>dirty_paused_when](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727).

**Establish a per-block device, per-thread dirty rate limit** Ideally each thread

would be limited to a dirtying rate equal to the writeback bandwidth divided by the number of threads writing back. We are unable to deter-mine precisely how many threads are writing back at any one time (and this can vary tremendously), but we can deduce this. The determined

dirty rate is stored in [struct bdi_writeback-\>dirty_ratelimit](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105).

**Establish an ideal setpoint of global dirty pages** We want to strike a bal-

ance between causing threads to sleep too much and hitting the dirty threshold, so establish the mid point between these two as the setpoint of global dirty pages which we aim to maintain during the period when dirtying rate exceeds writeback bandwidth.

**Smoothly adjust dirty rate limits to maintain setpoint** It is criti-

cal to ‘smooth out’ the degree by which we pause threads, which we achieve by smoothing out the rate at which we adjust the

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>dirty_ratelimit. We do so by scaling per-thread dirty rate by a position ratio, a coefficient which ranges from 0 to 2, ad-justed such as to eventually converge on a value of 1, at which point the number of dirtied pages will be equal to the set point.

**Scale thread pauses by distance from dirty rate** Once we have establish a

smoothed target per-thread per-block device dirty rate, we can use this to scale pauses such that we can pause each thread for either a shorter or a longer period of time such that the dirty rate trends towards the setpoint.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

**Maintain minimum and maximum thread pause times** To avoid a pause

so short that it has no material impact on dirty rate, or one so long as to cause a thread to become unresponsive, maintain minimum and max-

imum pause times using [wb_min_pause()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1434) and [wb_max_pause()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1415)[(capped](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1415) at

[MAX_PAUSE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n47), hardcoded to 200ms).

 

The point at which we transition from freerun to global dirty control

scope is determined by [dirty_freerun_ceiling()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n701) which we examine in List-

ing 10-80 which is determined to be halfway between background and dirty

threshold.

 

701 **static unsigned long dirty_freerun_ceiling**(**unsigned long** thresh, 702 **unsigned long** bg_thresh) 703 {

704 **return** (thresh + bg_thresh) / 2; 705 }

 

*Listing 10-80:* mm/page-writeback.c: [*dirty_freerun_ceiling()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n701)

 

This implementation results in heavy dirtying proceeding as shown in

Figure 10-13.

 

Global Dirty Control Scope

Dirty Threshold

 

Setpoint

 

es Freerun Ceiling ag

P

ty

Dir Background Threshold

 

Time

 

*Figure 10-13: Example Dirty Page Throttling*

 

Here dirtying threads cause a dramatic increase in dirtied pages before

hitting the background threshold at which point writeback begins slowing

things down. However this is insufficient to curtail the rate at which pages

are dirtied, so the dirtying exceeds the freerun ceiling before threads start

being slowed down, establishing an equilibrium around the setpoint.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

**10.15 Rate-Limited Dirty Throttling**

 

It is relatively expensive to perform this balancing operation even if it results in no action being taken, so in addition to performing this bal-ancing we also rate limit the operation itself. We can observe this in

[balance_dirty_pages_ratelimited_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1880) which we examine in Listing 10-81.

 

1863 */\*\**

1864 *\* balance_dirty_pages_ratelimited_flags - Balance dirty memory state.* 1865 *\* @mapping: address_space which was dirtied.* 1866 *\* @flags: BDP flags.*

1867 *\**

1868 *\* Processes which are dirtying memory should call in here once for each page*

1869 *\* which was newly dirtied. The function will periodically check the system's*

1870 *\* dirty state and will initiate writeback if needed.* 1871 *\**

1872 *\* See balance_dirty_pages_ratelimited() for details.* 1873 *\**

1874 *\* Return: If @flags contains BDP_ASYNC, it may return -EAGAIN to* 1875 *\* indicate that memory is out of balance and the caller must wait* 1876 *\* for I/O to complete. Otherwise, it will return 0 to indicate* 1877 *\* that either memory was already in balance, or it was able to sleep* 1878 *\* until the amount of dirty memory returned to balance.* 1879 *\*/*

1880 **int balance_dirty_pages_ratelimited_flags**(**struct** address_space \*mapping, 1881 **unsigned int** flags) 1882 {

1883 **struct** inode \*inode = mapping-\>host; 1884 **struct** backing_dev_info \*bdi = **inode_to_bdi**(inode); 1885 **struct** bdi_writeback \*wb = **NULL**; 1886 **int** ratelimit;

1887 **int** ret = 0;

1888 **int** \*p;

1889

1890 **if** (!(bdi-\>capabilities & **BDI_CAP_WRITEBACK**)) 1891 **return** ret; 1892

1893 **if** (**inode_cgwb_enabled**(inode)) 1894 wb = **wb_get_create_current**(bdi, **GFP_KERNEL**); 1895 **if** (!wb)

1896 wb = &bdi-\>wb; 1897

1898 ratelimit = **current**-\>nr_dirtied_pause; 1899 **if** (wb-\>dirty_exceeded) 1900 ratelimit = **min**(ratelimit, 32 \>\> (**PAGE_SHIFT**- 10)); 1901

1902 **preempt_disable**(); 1903 */\**

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1904 *\* This prevents one CPU to accumulate too many dirtied pages without*

1905 *\* calling into balance_dirty_pages(), which can happen when there are*

1906 *\* 1000+ tasks, all of them start dirtying pages at exactly the same*

1907 *\* time, hence all honoured too large initial task-\>nr_dirtied_pause.*

1908 *\*/*

1909 p = **this_cpu_ptr**(&**bdp_ratelimits**); 1910 **if** (**unlikely**(**current**-\>nr_dirtied \>= ratelimit)) 1911 \*p = 0;

1912 **else if** (**unlikely**(\*p \>= **ratelimit_pages**)) { 1913 \*p = 0;

1914 ratelimit = 0; 1915 }

1916 */\**

1917 *\* Pick up the dirtied pages by the exited tasks. This avoids lots of*

1918 *\* short-lived tasks (eg. gcc invocations in a kernel build) escaping*

1919 *\* the dirty throttling and livelock other long-run dirtiers.* 1920 *\*/*

1921 p = **this_cpu_ptr**(&dirty_throttle_leaks); 1922 **if** (\*p \> 0 && **current**-\>nr_dirtied \< ratelimit) { 1923 **unsigned long** nr_pages_dirtied; 1924 nr_pages_dirtied = **min**(\*p, ratelimit -**current**-\>nr_dirtied); 1925 \*p -= nr_pages_dirtied; 1926 **current**-\>nr_dirtied += nr_pages_dirtied; 1927 }

1928 **preempt_enable**(); 1929

1930 **if** (**unlikely**(**current**-\>nr_dirtied \>= ratelimit)) 1931 ret = **balance_dirty_pages**(wb, **current**-\>nr_dirtied, flags); 1932

1933 **wb_put**(wb);

1934 **return** ret;

1935 }

 

*Listing 10-81:* mm/page-writeback.c: [*balance_dirty_pages_ratelimited_flags()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1880)

 

We start by checking whether the underlying block device is even ca-

pable of writeback. If not, then there is nothing to do. Next we obtain the

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) object associated with this mapping. The logic here is

writeback cgroup-specific so out of scope.

After this we examine state associated with the last dirty throttle opera-

tion performed both by this thread and this CPU.

We query the [struct task_struct-\>nr_dirtied_pause](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) field associated with

the current process, which indicates how many pages can be dirtied before

we invoke the actual dirty throttling logic at [balance_dirty_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1557) logic (see

Listing 10-97).

This value is set by [balance_dirty_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1557) to a value obtained from

[dirty_poll_interval()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1406) (see Listing 10-91) when the number of dirtied pages is

still within the freerun region (which could be relatively large), or the num-

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

ber of pages that would be dirtied before reaching the minimum pause inter-val (as it’d be pointless trying to balance dirty pages if we are below this) as

determined by [wb_min_pause()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1434) (see Listing 10-96), a value which will be rela-tively small.

We cap this value to a hardcoded value, equal to 32 KiB of data (i.e. 8

pages for 4 KiB page size) if we have previously exceeded the dirty threshold

(as determined by [struct bdi_writeback-\>dirty_exceeded](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)) to cause earlier dirty throttling to ensure we bring things under control quickly.

After this we perform a careful check to see whether the number of

pages dirtied for this CPU (using the per-CPU [bdp_ratelimits](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1845) static value) exceeds the rate limit (if the current process’s number of dirty pages has not already done so).

This check is performed against the hardcoded [ratelimit_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n66) value (set

to 32 pages), which sets a maximum number of dirty pages per CPU after

which an invocation of [balance_dirty_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1557) must occur in order to perform dirty throttling.

This is done in order to avoid a scenario where a great many processes

dirty at the same time in the freerunning regime resulting in a relatively

large [struct task_struct-\>nr_dirtied_pause](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) value, the combined dirtying of which might push us over the dirty threshold or at least delay us bringing things back under control.

We therefore use this per-CPU check to set a hard upper limit on how

many pages can be dirtied before dirty throttling occurs regardless of the number of processes.

If this edge case does arise then the ratelimit value is set to zero, mean-

ing that the subsequent comparison between [struct task_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727)-\>nr_dirtied and ratelimit will always cause a balance to occur.

The [bdp_ratelimits](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1845) values for each CPU are updated when fo-

lios are dirtied in [folio_account_dirtied()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2552), as are each process’s

[struct task_struct-\>nr_dirtied](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727).

After this we perform another edge case check where we account for pro-

cesses which exited before dirty throttling was able to take into account the

process’s [struct task_struct-\>nr_dirtied](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727).

On thread exit in [do_exit()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/exit.c?h=v6.0#n736)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/exit.c?h=v6.0#n736) the per-CPU value [dirty_throttle_leaks](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1861) is up-

dated, accumulating the ‘left over’ nr_dirtied value.

This value is then simply added to the current thread’s

[struct task_struct-\>nr_dirtied](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) value to ensure that threads are scaled cor-rectly.

This is specifically implemented to avoid a worst case scenario where a

number of processes exit with a [struct task_struct-\>nr_dirtied](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) value close

but not equal to [struct task_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727)-\>nr_dirtied_pause which would otherwise potentially significantly delay dirty throttling being performed.

Finally we perform the core check—determining whether the thread’s

[struct task_struct-\>nr_dirtied](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) value equals or exceeds the determined rate

limit value. If so, we invoke the [balance_dirty_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1557) (see Listing 10-97) func-tion in order to perform dirty throttling.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

We will examine [balance_dirty_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1557) shortly, but before we do so let’s

examine the various statistics which are used in dirty throttle logic and how

they are updated.

The key parameters we need are the number of pages dirtied and written

and the rate at which pages are dirtied/written. For threads we also want to

track the number of pages dirtied since we last paused a thread and when to

assess the same thing per-thread.

 

**10.16 Dirty Throttle Statistics**

Let’s examine each field which we regularly update:

 

• [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)[-\>stats\[WB_DIRTIED\]](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n34) – Measures the number of folios

dirtied under this [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105). This uses a [struct percpu_counter](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/percpu_counter.h?h=v6.0#n20) to track this parameter, with per-CPU values accumulated in batches of

[WB_STAT_BATCH](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n39) folios by [wb_stat_mod()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev.h?h=v6.0#n65) in [folio_account_dirtied()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2552) when a

folio is dirtied, which is invoked by [\_\_folio_mark_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2607) (see Listing 10-

1 in Section 10.1). It is also reduced in [folio_account_redirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2615) if a file system rejects the dirtying of a folio, discussion of this is out of scope for the book however.

• [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)[-\>stats\[WB_WRITTEN\]](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n35) – Measures the number of fo-

lios written back under this [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105). This is updated by

[\_\_wb_writeout_add()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n578) which is called by [\_\_folio_end_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2910) when write-

back has completed (see Listing 10-29 in Section 10.10). The same

batched per-CPU logic applies to [WB_WRITTEN](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n35) as with [WB_DIRTIED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n34).

• [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>dirtied_stamp – A copy of [stats\[WB_DIRTIED\]](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n34) taken

at bw_time_stamp at the same time written_stamp is taken, so the two values can be used in conjunction with one another. This is done in

[\_\_wb_update_bandwidth()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1330) (or [wb_bandwidth_estimate_start()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1330) if writeback

has become idle). The [\_\_wb_update_bandwidth()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1330) function is invoked pe-

riodically at [BANDWIDTH_INTERVAL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n58) (200ms) intervals, as well as invoked by

[balance_dirty_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1557) and [do_writepages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2457) (at points at which the facts on the ground may have changed).

• [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>written_stamp – A copy of [stats\[WB_WRITTEN\]](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n35),

updated alongside [stats\[WB_DIRTIED\]](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n34) in [\_\_wb_update_bandwidth()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1330) or

[wb_bandwidth_estimate_start()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1330).

• [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>bw_time_stamp – The time at which

[\_\_wb_update_bandwidth()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1330) or [wb_bandwidth_estimate_start()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1330) was last executed.

• [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>write_bandwidth – The number of pages writ-

ten per second for this [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) This is updated in

[wb_update_write_bandwidth()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1068) by [\_\_wb_update_bandwidth()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1330).

• [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>avg_write_bandwidth – A smoothed average derived

from write_bandwidth which evens out short-term variations in the write bandwidth figure.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

• [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>balanced_dirty_ratelimit – The per-thread limit on

the number of pages dirtied per second for this [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) up-

dated in [wb_update_dirty_ratelimit()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1172) invoked by [\_\_wb_update_bandwidth()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1330) but, importantly, only when the update_ratelimit parameter is specified, which is not the case on periodic bandwidth update but rather invoked

only by [balance_dirty_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1557) immediately prior to this rate limit being used to make dirty throttle decisions. This value is scaled using the posi-tion ratio coefficient in order to implement sensible dirty throttling, we will discuss the details of this shortly.

• [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>dirty_ratelimit – Logically equivalent to

balanced_dirty_ratelimit , however updated in small steps to provide an smoothed averaged dirty rate limit with lower variance.

• [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>bw_dwork – A [struct delayed_work](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/workqueue.h?h=v6.0#n110) object which pro-

vides a work queue for bandwidth update operations. The bandwidth

update is ultimately performed in [\_\_wb_update_bandwidth()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1330) as described

above, the work queue periodically invoking [wb_update_bandwidth_workfn()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/backing-dev.c?h=v6.0#n269) to do so. This work queue and thus the bandwidth updating (importantly not updating the dirty rate limit) is scheduled by

[wb_inode_writeback_end()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2893) to be run after a delay of [BANDWIDTH_INTERVAL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n58)

(200ms), called by [\_\_folio_end_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2910) when writeback has completed

(see Listing 10-29 in Section 10.10). Thus this is only called when writes are actually occurring.

• [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>completions – Maintains a count of the number of

written back pages which have successfully completed writeback for this

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105). This is stored in such a way as to easily calculate the proportion of this value against overall writeback completion rate.

This is updated in [wb_domain_writeout_add()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n555) which is in turn invoked by

[\_\_wb_writeout_add()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n578) and [\_\_folio_end_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2910) when writeback has com-

pleted (see Listing 10-29 in Section 10.10).

• [struct wb_domain-\>completions](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n133) – The [struct wb_domain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n133) object is used to de-

scribe a domain of writeback. The only domain we consider is the global one (any other is relevant only to cgroup-mediated writeback which is out of scope for the book), which is maintained in the global variable

[global_wb_domain. ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n120)Its Completions field is the system-wide equivalent to

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>completions, and stored in a similar fashion (up-

dated at precisely the same point in [wb_domain_writeout_add()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n555)[).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n555)

• [struct task_struct-\>nr_dirtied](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) – A count of the number of pages dirtied

since we last paused the thread due to dirty throttling. This is updated

in [folio_account_dirtied()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2552) when a folio is dirtied, which is invoked by

[\_\_folio_mark_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2607) (see Listing 10-1 in Section 10.1). It is also reduced

in [folio_account_redirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2615) if a file system rejects the dirtying of a folio. It

is reset to zero when a thread is paused in [balance_dirty_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1557)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1557)

• [struct task_struct-\>dirty_paused_when](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) – A timestamp indicating when last

the thread was paused (or permitted to freerun).

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

• [struct task_struct-\>nr_dirtied_pause](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) – The number of pages which

must be dirtied by this thread before dirty throttling is applied in

[balance_dirty_pages() . ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1557)Determined to be either the minimum pause time

if the thread was paused, or by [dirty_poll_interval()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1406) (see Listing **??**) if the thread is freerunning.

 

**10.17 Bandwidth Updates**

 

Let’s examine the functions we’ve referred to here, starting with bandwidth

updates in [\_\_wb_update_bandwidth()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1330)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1330) which we explore in Listing 10-82 (eliding

out of scope cgroup writeback logic).

 

1330 **static void \_\_wb_update_bandwidth**(**struct** dirty_throttle_control \*gdtc, 1331 **struct** dirty_throttle_control \*mdtc, 1332 **bool** update_ratelimit) 1333 {

1334 **struct** bdi_writeback \*wb = gdtc-\>wb; 1335 **unsigned long** now = **jiffies**; 1336 **unsigned long** elapsed; 1337 **unsigned long** dirtied; 1338 **unsigned long** written; 1339

1340 **spin_lock**(&wb-\>list_lock); 1341

1342 */\**

1343 *\* Lockless checks for elapsed time are racy and delayed update after*

1344 *\* IO completion doesn't do it at all (to make sure written pages are*

1345 *\* accounted reasonably quickly). Make sure elapsed \>= 1 to avoid* 1346 *\* division errors.* 1347 *\*/*

1348 elapsed = **max**(now - wb-\>bw_time_stamp, 1**UL**); 1349 dirtied = **percpu_counter_read**(&wb-\>stat\[**WB_DIRTIED**\]); 1350 written = **percpu_counter_read**(&wb-\>stat\[**WB_WRITTEN**\]); 1351

1352 **if** (update_ratelimit) { 1353 **domain_update_dirty_limit**(gdtc, now); 1354 **wb_update_dirty_ratelimit**(gdtc, dirtied, elapsed);

. . .

1364 }

1365 **wb_update_write_bandwidth**(wb, elapsed, written); 1366

1367 wb-\>dirtied_stamp = dirtied; 1368 wb-\>written_stamp = written; 1369 **WRITE_ONCE**(wb-\>bw_time_stamp, now); 1370 **spin_unlock**(&wb-\>list_lock); 1371 }

 

*Listing 10-82:* mm/page-writeback.c: [*\_\_wb_update_bandwidth()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1330)

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

This uses the [struct dirty_throttle_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n123) object to thread state through

the function (as is used elsewhere in dirty throttling). The only version of this we concern ourselves with is the so-called gdtc which refers to global dirty throttle control (the mdtc value refers to out-of-scope cgroup writeback dirty throttle control).

We examine this type in Listing 10-84 shortly. For the time being, we can

simply observe that it is passed to called functions and from it we obtain the

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) object to which it pertains from its wb field.

The function derives the elapsed time since last the bandwidth was up-

dated (avoiding a potential later division by zero by assigning it one if it turns out to be zero).

The dirtied and written values are derived from

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>stats as described above.

If called from [balance_dirty_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1557) with update_ratelimit set,

we update the dirty limit for the [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) object via

[wb_update_dirty_ratelimit()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1172) (see Listing 10-92). We also update the global

[struct wb_domain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n133) dirty limit using [domain_update_dirty_limit()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1147), however this is really only relevant for cgroup writeback so we do not examine it in detail.

Finally we always update [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) write bandwidth statis-

tics via [wb_update_write_bandwidth()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1068) (see Listing 10-85), as well as setting

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>dirtied_stamp and written_stamp values as well as the bw_time_stamp.

When this function is periodically invoked at [BANDWIDTH_INTERVAL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n58) (200ms)

intervals, this is done via [wb_update_bandwidth()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1373), which we examine in Listing

10-83.

 

1373 **void wb_update_bandwidth**(**struct** bdi_writeback \*wb) 1374 {

1375 **struct** dirty_throttle_control gdtc = { **GDTC_INIT**(wb) }; 1376

1377 **\_\_wb_update_bandwidth**(&gdtc, **NULL**, **false**); 1378 }

 

*Listing 10-83:* mm/page-writeback.c: [*wb_update_bandwidth()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1373)

 

Importantly, this establishes a local [struct dirty_throttle_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n123) ob-

ject with its wb field set to the appropriate [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) object to be

passed into [\_\_wb_update_bandwidth()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1330) using [GDTC_INIT()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n152) to initialise it.

We now return to the [struct dirty_throttle_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n123) type, examining it in

Listing 10-84, eliding out of scope cgroup writeback fields.

 

122 */\* consolidated parameters for balance_dirty_pages() and its subroutines \*/* 123 **struct** dirty_throttle_control {

. . .

128 **struct** bdi_writeback \*wb; 129 **struct** fprop_local_percpu \*wb_completions; 130

131 **unsigned long** avail; */\* dirtyable \*/* 132 **unsigned long** dirty; */\* file_dirty + write + nfs \*/*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

133 **unsigned long** thresh; */\* dirty threshold \*/* 134 **unsigned long** bg_thresh; */\* dirty background threshold*

*\*/*

135

136 **unsigned long** wb_dirty; */\* per-wb counterparts \*/* 137 **unsigned long** wb_thresh; 138 **unsigned long** wb_bg_thresh;

139

140 **unsigned long** pos_ratio; 141 };

 

*Listing 10-84:* mm/page-writeback.c: [*struct dirty_throttle_control*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n123)

 

Each time this is used in a context where a [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) must

be referenced, this is set by the calling functions in the wb field, with

wb_completions set to the [struct bdi_writeback-\>completions](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) field.

The avail field indicates the total number of dirtyable pages as deter-

mined by [global_dirtyable_memory()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n344) (see Listing 10-78) and the dirty field set

to the sum of global dirty and writeback pages.

The thresh and bg_thresh value are set to the dirty threshold and back-

ground dirty threshold system values in [domain_dirty_limits()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n374).

The [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-specific wb_dirty value is set in [wb_dirty_limits()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1509)

(see Listing 10-89), along side wb_thresh and wb_bg_thresh.

Finally, the pos_ratio field, specifying the position ratio coefficient which

is carefully calculated as part of the dirty throttling mechanism, is set in

[wb_position_ratio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n889) (see Listing 10-86), which we examine later.

Generally speaking, changes made to an [struct dirty_throttle_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n123)

object are ultimately invoked by the core dirty throttle function

[balance_dirty_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1557) (see Listing 10-97).

Returning to [\_\_wb_update_bandwidth()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1330) (see Listing 10-82), we will

start by examining the common write bandwidth update logic in

[wb_update_write_bandwidth()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1068) in Listing 10-85.

 

1068 **static void wb_update_write_bandwidth**(**struct** bdi_writeback \*wb, 1069 **unsigned long** elapsed, 1070 **unsigned long** written) 1071 {

1072 **const unsigned long** period = **roundup_pow_of_two**(3 \* **HZ**); 1073 **unsigned long** avg = wb-\>avg_write_bandwidth; 1074 **unsigned long** old = wb-\>write_bandwidth; 1075 **u64** bw;

1076

1077 */\**

1078 *\* bw = written \* HZ / elapsed* 1079 *\**

1080 *\** *bw \* elapsed + write_bandwidth \* (period -*

*elapsed)*

1081 *\* write_bandwidth =*

*---------------------------------------------------*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1082 *\** *period* 1083 *\**

1084 *\* @written may have decreased due to folio_account_redirty().* 1085 *\* Avoid underflowing @bw calculation.* 1086 *\*/*

1087 bw = written -**min**(written, wb-\>written_stamp); 1088 bw \*= **HZ**;

1089 **if** (**unlikely**(elapsed \> period)) { 1090 bw = **div64_ul**(bw, elapsed); 1091 avg = bw; 1092 **goto out**; 1093 }

1094 bw += (**u64**)wb-\>write_bandwidth \* (period - elapsed); 1095 bw \>\>= **ilog2**(period); 1096

1097 */\**

1098 *\* one more level of smoothing, for filtering out sudden spikes* 1099 *\*/*

1100 **if** (avg \> old && old \>= (**unsigned long**)bw) 1101 avg -= (avg - old) \>\> 3; 1102

1103 **if** (avg \< old && old \<= (**unsigned long**)bw) 1104 avg += (old - avg) \>\> 3; 1105

1106 **out**:

1107 */\* keep avg \> 0 to guarantee that tot \> 0 if there are dirty wbs \*/*

1108 avg = **max**(avg, 1**LU**); 1109 **if** (**wb_has_dirty_io**(wb)) { 1110 **long** delta = avg - wb-\>avg_write_bandwidth; 1111 **WARN_ON_ONCE**(**atomic_long_add_return**(delta, 1112 &wb-\>bdi-\>tot_write_bandwidth) \<= 0);

1113 }

1114 wb-\>write_bandwidth = bw; 1115 **WRITE_ONCE**(wb-\>avg_write_bandwidth, avg); 1116 }

 

*Listing 10-85:* mm/page-writeback.c: [*wb_update_write_bandwidth()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1068)

 

**N O T E** The dirty throttling logic we explore from this point on involves some rather delicate

mathematics. Rather than dwell too long on these, we shall examine the core of the functions under examination, showing the remainder so as to leave further mathe-matical examination of the details as an exercise for the reader.

 

Note that in this function and many others, careful choices around how

integer mathematical operations are performed occur, such as using power-

of-2 values for instance here via [roundup_pow_of_two()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/log2.h?h=v6.0#n174)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/log2.h?h=v6.0#n174) In service of brevity, we do not examine these too closely but rather proceed referring to what the value ultimately represents.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

Note that this function is passed [struct bdi_writeback-\>stats\[WB_WRITTEN\]](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)

via the written parameter.

We subtract the value that this was at when last we obtained a band-

width from the [struct bdi_writeback-\>written_stamp](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) field (which the calling

[\_\_wb_update_bandwidth()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1330) function will update after this function is complete),

obtaining the number of pages written since we last updated the bandwidth

value.

We attempt to obtain a rolling average over a hardcoded period of 3 sec-

onds (the multiplication in this function of values with HZ are to convert

them to the internal kernel time metric of jiffies).

If the elapsed period happens to exceed this period then we simply take

the write bandwidth (and smoothed averaged write bandwidth) to be equal

to ∆*written* and exit the function early.

*elapsed*

Otherwise, we calculate the write bandwidth to be equal to ∆*written* +

*period*

*old* *×* *period**−**elapsed*, providing a rolling average over the hardcoded 3 second *period*

period.

After obtaining this value from [struct bdi_writeback-\>write_bandwidth](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105), we

perform some careful smoothing against the previous average value, assign-

ing this to [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>avg_write_bandwidth.

 

**10.18 Dirty Position Control Ratio**

 

Before we examine the dirty rate calculation, let’s reflect on the dirty position

control ratio, which we maintain in [struct dirty_throttle_control-\>pos_ratio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n123).

This value is determined in [wb_position_ratio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n889) which we examine in Listing

10-86.

As discussed previously, this is a coefficient we use to scale the dirty rate

limit such that each individual thread converges on the desired set point

under writeback pressure, clamped to a minimum of zero and a maximum

of two, allowing for the dirty rate to be at most doubled if the dirtying rate

is running to low, or turned into a hard limit if the dirty rate is so high as to

overwhelm the block device.

We examine how this value is intended to be maintained in Figure 10-14.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

Global dirty control scope

2

 

atio

R

 

osition 1

P

 

0

freerun setpoint limit

Dirty Pages

 

*Figure 10-14: Example Dirty Position Control Ratio*

 

Compare this figure to the impact this is intended to have in Figure 10-

13. The intent is to maintain a position ratio of 1, and varying this only when thread dirty rate differs from write bandwidth scaled by the number of threads.

The dirty position control ratio is determined in [wb_position_ratio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n889),

which we examine in Listing 10-86. Note that we elide handling of block de-

vice strict limit logic for brevity (as specified by [BDI_CAP_STRICTLIMIT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev.h?h=v6.0#n118)[),](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev.h?h=v6.0#n118) and a number of comments that would make the function overlong.

 

889 **static void wb_position_ratio**(**struct** dirty_throttle_control \*dtc) 890 {

891 **struct** bdi_writeback \*wb = dtc-\>wb; 892 **unsigned long** write_bw = **READ_ONCE**(wb-\>avg_write_bandwidth); 893 **unsigned long** freerun = **dirty_freerun_ceiling**(dtc-\>thresh, dtc-\>

bg_thresh);

894 **unsigned long** limit = **hard_dirty_limit**(dtc_dom(dtc), dtc-\>thresh); 895 **unsigned long** wb_thresh = dtc-\>wb_thresh; 896 **unsigned long** x_intercept; 897 **unsigned long** setpoint; */\* dirty pages' target balance point*

*\*/*

898 **unsigned long** wb_setpoint; 899 **unsigned long** span; 900 **long long** pos_ratio; */\* for scaling up/down the rate limit*

*\*/*

901 **long** x;

902

903 dtc-\>pos_ratio = 0; 904

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

905 **if** (**unlikely**(dtc-\>dirty \>= limit)) 906 **return**;

. . .

913 setpoint = (freerun + limit) / 2; 914 pos_ratio = **pos_ratio_polynom**(setpoint, dtc-\>dirty, limit);

. . .

987 */\**

988 *\* We have computed basic pos_ratio above based on global situation.*

*If*

989 *\* the wb is over/under its share of dirty pages, we want to scale*

990 *\* pos_ratio further down/up. That is done by the following mechanism.*

991 *\*/*

. . .

1018 **if** (**unlikely**(wb_thresh \> dtc-\>thresh)) 1019 wb_thresh = dtc-\>thresh; 1020 */\**

1021 *\* It's very possible that wb_thresh is close to 0 not because the*

1022 *\* device is slow, but that it has remained inactive for long time.*

1023 *\* Honour such devices a reasonable good (hopefully IO efficient)* 1024 *\* threshold, so that the occasional writes won't be blocked and*

*active*

1025 *\* writes can rampup the threshold quickly.* 1026 *\*/*

1027 wb_thresh = **max**(wb_thresh, (limit - dtc-\>dirty) / 8); 1028 */\**

1029 *\* scale global setpoint to wb's:* 1030 *\** *wb_setpoint = setpoint \* wb_thresh / thresh* 1031 *\*/*

1032 x = **div_u64**((**u64**)wb_thresh \<\< 16, dtc-\>thresh \| 1); 1033 wb_setpoint = setpoint \* (**u64**)x \>\> 16; 1034 */\**

1035 *\* Use span=(8\*write_bw) in single wb case as indicated by* 1036 *\* (thresh - wb_thresh ~= 0) and transit to wb_thresh in JBOD case.*

1037 *\**

1038 *\** *wb_thresh* *thresh - wb_thresh* 1039 *\* span = --------- \* (8 \* write_bw) + ------------------ \* wb_thresh*

1040 *\** *thresh* *thresh* 1041 *\*/*

1042 span = (dtc-\>thresh - wb_thresh + 8 \* write_bw) \* (**u64**)x \>\> 16; 1043 x_intercept = wb_setpoint + span; 1044

1045 **if** (dtc-\>wb_dirty \< x_intercept - span / 4) { 1046 pos_ratio = **div64_u64**(pos_ratio \* (x_intercept - dtc-\>wb_dirty

),

1047 (x_intercept - wb_setpoint) \| 1); 1048 } **else**

1049 pos_ratio /= 4;

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1050

1051 */\**

1052 *\* wb reserve area, safeguard against dirty pool underrun and disk*

*idle*

1053 *\* It may push the desired control point of global dirty pages higher*

1054 *\* than setpoint.* 1055 *\*/*

1056 x_intercept = wb_thresh / 2; 1057 **if** (dtc-\>wb_dirty \< x_intercept) { 1058 **if** (dtc-\>wb_dirty \> x_intercept / 8) 1059 pos_ratio = **div_u64**(pos_ratio \* x_intercept, 1060 dtc-\>wb_dirty); 1061 **else**

1062 pos_ratio \*= 8; 1063 }

1064

1065 dtc-\>pos_ratio = pos_ratio; 1066 }

 

*Listing 10-86:* mm/page-writeback.c: [*wb_position_ratio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n889)

 

We won’t delve too deeply into the mathematics here, rather we will

make some simple observations around the logic.

If the global number of dirty pages exceeds the dirty threshold (specified

in limit), then we do not need to calculate the ratio, we set it to zero such that we get the maximum process pause.

We note that the setpoint is determined to be half way between the

freerun value determined by [dirty_freerun_ceiling()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n701) (see Listing 10-80) and

the dirty threshold determined by [hard_dirty_limit()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n707) (since cgroup writeback is out of scope for the book, we consider only the case where this is equal to the global dirty threshold).

The [dirty_freerun_ceiling()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n701) function determines the freerun zone to start

halfway between the background threshold and dirty threshold values, and thus this establishes the setpoint as halfway between this value and the dirty threshold.

By default, vm.dirty_background_ratio is set to 10% of dirtyable memory

and vm.dirty_ratio is set to 20%. This therefore implies that freerun by de-fault (i.e. no attempt to dirty throttle) applies up to 15% of dirtyable mem-ory, with a setpoint of 17.5%.

While we won’t examine the mathematics, it’s instructive to observe

[pos_ratio_polynom()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n797) in Listing 10-87.

 

783 */\**

784 *\** *setpoint - dirty 3* 785 *\** *f(dirty) := 1.0 + (----------------)* 786 *\** *limit - setpoint* 787 *\**

788 *\* it's a 3rd order polynomial that subjects to* 789 *\**

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

790 *\* (1) f(freerun) = 2.0 =\> rampup dirty_ratelimit reasonably fast* 791 *\* (2) f(setpoint) = 1.0 =\> the balance point* 792 *\* (3) f(limit)* *= 0* *=\> the hard limit* 793 *\* (4) df/dx* *\<= 0* *=\> negative feedback control* 794 *\* (5) the closer to setpoint, the smaller \|df/dx\| (and the reverse)* 795 *\** *=\> fast response on large errors; small oscillation near setpoint* 796 *\*/*

797 **static long long pos_ratio_polynom**(**unsigned long** setpoint, 798 **unsigned long** dirty, 799 **unsigned long** limit) 800 {

801 **long long** pos_ratio; 802 **long** x;

803

804 x = **div64_s64**(((**s64**)setpoint - (**s64**)dirty) \<\< **RATELIMIT_CALC_SHIFT**, 805 (limit - setpoint) \| 1); 806 pos_ratio = x;

807 pos_ratio = pos_ratio \* x \>\> **RATELIMIT_CALC_SHIFT**; 808 pos_ratio = pos_ratio \* x \>\> **RATELIMIT_CALC_SHIFT**; 809 pos_ratio += 1 \<\< **RATELIMIT_CALC_SHIFT**;

810

811 **return clamp**(pos_ratio, 0**LL**, 2**LL** \<\< **RATELIMIT_CALC_SHIFT**); 812 }

 

*Listing 10-87:* mm/page-writeback.c: [*pos_ratio_polynom()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n797)

 

Importantly, note that lengths are taken in order to maintain this cal-

culation using integers (the kernel cannot sensibly perform floating point

operations), therefore to work around the fact that this ratio is inevitably a

floating point multiplier of a thread’s dirty rate, we bit-shift the calculation

by [RATELIMIT_CALC_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n60) (10 bits), shifting back again once the calculation is

complete.

The function calculates the ratio to be *setpoint* *dirty* 3 *−* 1 + ( ), where dirty is *limit* *−* *setpoint*

the total number of dirty pages, and limit the dirty threshold.

The result of this function is explicitly clamped between zero and two,

matching the required range of the value.

The ratio indicates the divergence between the number of dirty pages

and the setpoint, as a proportion of the part of the global dirty control

scope range between the set point and the dirty threshold, i.e. scaling higher

if this is small relative to if this is large.

If dirty pages are in excess of the setpoint the second part of this equa-

tion will be negative, causing the dirty rate to be scaled down, otherwise it

will be positive, causing the dirty throttle rate to be scaled up.

Returning to [wb_position_ratio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n889) in Listing 10-86 above, we observe

that once this global pos_ratio value has been obtained, we must take into

account the proportion of the [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-specific dirty thresh-

old [struct dirty_throttle_control-\>wb_thresh](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n123) to the global dirty threshold

[struct dirty_throttle_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n123)-\>thresh.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

We therefore obtain a scaled [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-specific setpoint

wb_setpoint equal to *setpoint* *×* *wb*\_*thresh*, which is then used to scale the posi-*thresh* tion ratio accordingly.

Again we do not dwell the mathematical details of this function as they

are somewhat out of the scope of the book.

 

**10.19 Dirty Limits**

 

As we’ve examined both global and [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)[-specif](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)ic threshold values, let’s look at how these are calculated. The global values are calcu-

lated in [domain_dirty_limits()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n374) as shown in Listing 10-88 (eliding out of scope cgroup writeback and tracing logic).

 

365 */\*\**

366 *\* domain_dirty_limits - calculate thresh and bg_thresh for a wb_domain* 367 *\* @dtc: dirty_throttle_control of interest* 368 *\**

369 *\* Calculate @dtc-\>thresh and -\>bg_thresh considering* 370 *\* vm_dirty\_{bytes\|ratio} and dirty_background\_{bytes\|ratio}. The caller* 371 *\* must ensure that @dtc-\>avail is set before calling this function. The* 372 *\* dirty limits will be lifted by 1/4 for real-time tasks.* 373 *\*/*

374 **static void domain_dirty_limits**(**struct** dirty_throttle_control \*dtc) 375 {

376 **const unsigned long** available_memory = dtc-\>avail;

. . .

378 **unsigned long** bytes = vm_dirty_bytes; 379 **unsigned long** bg_bytes = dirty_background_bytes; 380 */\* convert ratios to per-PAGE_SIZE for higher precision \*/* 381 **unsigned long** ratio = (vm_dirty_ratio \* **PAGE_SIZE**) / 100; 382 **unsigned long** bg_ratio = (dirty_background_ratio \* **PAGE_SIZE**) / 100; 383 **unsigned long** thresh; 384 **unsigned long** bg_thresh; 385 **struct** task_struct \*tsk;

. . .

407 **if** (bytes)

408 thresh = **DIV_ROUND_UP**(bytes, **PAGE_SIZE**); 409 **else**

410 thresh = (ratio \* available_memory) / **PAGE_SIZE**; 411

412 **if** (bg_bytes)

413 bg_thresh = **DIV_ROUND_UP**(bg_bytes, **PAGE_SIZE**); 414 **else**

415 bg_thresh = (bg_ratio \* available_memory) / **PAGE_SIZE**; 416

417 **if** (bg_thresh \>= thresh) 418 bg_thresh = thresh / 2; 419 tsk = current;

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

420 **if** (**rt_task**(tsk)) { 421 bg_thresh += bg_thresh / 4 + global_wb_domain.dirty_limit /

32;

422 thresh += thresh / 4 + global_wb_domain.dirty_limit / 32; 423 }

424 dtc-\>thresh = thresh; 425 dtc-\>bg_thresh = bg_thresh;

. . .

430 }

 

*Listing 10-88:* mm/page-writeback.c: [*domain_dirty_limits()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n374)

 

This retrieves the vm.dirty_bytes from the [vm_dirty_bytes](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n96) global variable

and places it in bytes, vm.dirty_background_bytes from [dirty_background_bytes](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n79)

and places it in bg_bytes, vm.dirty_ratio from [vm_dirty_ratio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n90) and places it in

ratio and vm.dirty_background_ratio from [dirty_background_ratio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n73) and places it

in bg_ratio.

The code then applies these tunables—if vm.dirty_bytes was spec-

ified then the threshold (expressed in pages) is calculated to sim-

ply be this value divided by and aligned to page size. Otherwise if

vm.dirty_ratio was specified instead, this ratio is taken and multiplied by

[struct dirty_throttle_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n123)-\>avail (which has previously been set to the

number of available, dirtyable bytes as calculated by [global_dirtyable_memory()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n344)

shown in Listing 10-78, and divided by page size to obtain threshold page

count stored in thresh.

Equally the same process is applied to the background threshold value

which is stored in bg_thresh.

Finally, we consider the case where background threshold is erroneously

higher than the dirty threshold, which cannot be permitted. In this instance

we set the background threshold to half of dirty threshold as a sensible com-

promise.

There is some special handling for threads with real-time priority where

the thresholds are increased, before assigning the thresh and bg_thresh fields

of [domain_dirty_limits()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n374) to the values calculated as described above.

We determine [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-specific threshold values in

[wb_dirty_limits()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1509) which we explore in Listing 10-89.

 

1509 **static inline void wb_dirty_limits**(**struct** dirty_throttle_control \*dtc) 1510 {

1511 **struct** bdi_writeback \*wb = dtc-\>wb; 1512 **unsigned long** wb_reclaimable; 1513

1514 */\**

1515 *\* wb_thresh is not treated as some limiting factor as* 1516 *\* dirty_thresh, due to reasons* 1517 *\* - in JBOD setup, wb_thresh can fluctuate a lot* 1518 *\* - in a system with HDD and USB key, the USB key may somehow* 1519 *\** *go into state (wb_dirty \>\> wb_thresh) either because* 1520 *\** *wb_dirty starts high, or because wb_thresh drops low.*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1521 *\** *In this case we don't want to hard throttle the USB key* 1522 *\** *dirtiers for 100 seconds until wb_dirty drops under* 1523 *\** *wb_thresh. Instead the auxiliary wb control line in* 1524 *\** *wb_position_ratio() will let the dirtier task progress* 1525 *\** *at some rate \<= (write_bw / 2) for bringing down wb_dirty.* 1526 *\*/*

1527 dtc-\>wb_thresh = **\_\_wb_calc_thresh**(dtc); 1528 dtc-\>wb_bg_thresh = dtc-\>thresh ? 1529 div_u64((**u64**)dtc-\>wb_thresh \* dtc-\>bg_thresh, dtc-\>thresh) :

0;

1530

1531 */\**

1532 *\* In order to avoid the stacked BDI deadlock we need* 1533 *\* to ensure we accurately count the 'dirty' pages when* 1534 *\* the threshold is low.* 1535 *\**

1536 *\* Otherwise it would be possible to get thresh+n pages* 1537 *\* reported dirty, even though there are thresh-m pages* 1538 *\* actually dirty; with m+n sitting in the percpu* 1539 *\* deltas.*

1540 *\*/*

1541 **if** (dtc-\>wb_thresh \< 2 \* **wb_stat_error**()) { 1542 wb_reclaimable = **wb_stat_sum**(wb, **WB_RECLAIMABLE**); 1543 dtc-\>wb_dirty = wb_reclaimable + **wb_stat_sum**(wb, **WB_WRITEBACK**)

;

1544 } **else** {

1545 wb_reclaimable = **wb_stat**(wb, **WB_RECLAIMABLE**); 1546 dtc-\>wb_dirty = wb_reclaimable + **wb_stat**(wb, **WB_WRITEBACK**); 1547 }

1548 }

 

*Listing 10-89:* mm/page-writeback.c: [*wb_dirty_limits()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1509)

 

This defers the calculation of the [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)[-specif](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)ied dirty

threshold to to [\_\_wb_calc_thresh()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n749) which we examine shortly in Listing

10-90. After doing so, we simply calculate the background equivalent,

[struct dirty_throttle_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n123)-\>wb_bg_thresh to be equal to the proportion be-tween global background and dirty threshold multiplied by wb_thresh.

After this we determine the count of dirty pages associated with the

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) object, using the count of dirtied folios associated with

the writeback object via the [WB_RECLAIMABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n32) statistic summed with the num-ber of pages undergoing writeback (mirroring the global calculation), using

[WB_WRITEBACK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n33).

We are cautious if the threshold is especially low in which case we do

not accept the batch error associated with these statistics being updated

in [WB_STAT_BATCH](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n39) increments (as indicated by [wb_stat_error()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev.h?h=v6.0#n96)[).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev.h?h=v6.0#n96) If so we use

[wb_stat_sum()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev.h?h=v6.0#n86) rather than [wb_stat()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev.h?h=v6.0#n81) to force the summing of each per-CPU value rather than taking the typical batch-updated value.

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

We store this dirty count in [struct dirty_throttle_control-\>wb_dirty](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n123).

Let’s now examine [\_\_wb_calc_thresh()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n749) which performs the actual per-

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) dirty threshold calculation in Listing 10-90.

 

728 */\*\**

729 *\* \_\_wb_calc_thresh - @wb's share of dirty throttling threshold* 730 *\* @dtc: dirty_throttle_context of interest* 731 *\**

732 *\* Note that balance_dirty_pages() will only seriously take it as a hard limit*

733 *\* when sleeping max_pause per page is not enough to keep the dirty pages*

*under*

734 *\* control. For example, when the device is completely stalled due to some*

*error*

735 *\* conditions, or when there are 1000 dd tasks writing to a slow 10MB/s USB*

*key.*

736 *\* In the other normal situations, it acts more gently by throttling the tasks*

737 *\* more (rather than completely block them) when the wb dirty pages go high.*

738 *\**

739 *\* It allocates high/low dirty limits to fast/slow devices, in order to*

*prevent*

740 *\* - starving fast devices* 741 *\* - piling up dirty pages (that will take long time to sync) on slow devices*

742 *\**

743 *\* The wb's share of dirty limit will be adapting to its throughput and* 744 *\* bounded by the bdi-\>min_ratio and/or bdi-\>max_ratio parameters, if set.*

745 *\**

746 *\* Return: @wb's dirty limit in pages. The term "dirty" in the context of* 747 *\* dirty balancing includes all PG_dirty and PG_writeback pages.* 748 *\*/*

749 **static unsigned long \_\_wb_calc_thresh**(**struct** dirty_throttle_control \*dtc) 750 {

751 **struct** wb_domain \*dom = **dtc_dom**(dtc); 752 **unsigned long** thresh = dtc-\>thresh; 753 **u64** wb_thresh;

754 **unsigned long** numerator, denominator; 755 **unsigned long** wb_min_ratio, wb_max_ratio;

756

757 */\**

758 *\* Calculate this BDI's share of the thresh ratio.* 759 *\*/*

760 **fprop_fraction_percpu**(&dom-\>completions, dtc-\>wb_completions, 761 &numerator, &denominator);

762

763 wb_thresh = (thresh \* (100 -**bdi_min_ratio**)) / 100; 764 wb_thresh \*= numerator; 765 wb_thresh = **div64_ul**(wb_thresh, denominator);

766

767 **wb_min_max_ratio**(dtc-\>wb, &wb_min_ratio, &wb_max_ratio);

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

768

769 wb_thresh += (thresh \* wb_min_ratio) / 100; 770 **if** (wb_thresh \> (thresh \* wb_max_ratio) / 100) 771 wb_thresh = thresh \* wb_max_ratio / 100; 772

773 **return** wb_thresh; 774 }

 

*Listing 10-90:* mm/page-writeback.c: [*\_\_wb_calc_thresh()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n749)

 

This obtains a fraction representing the proportion of

[struct dirty_throttle_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n123)-\>wb_completions to [struct wb_domain-\>completions](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/writeback.h?h=v6.0#n133), obtaining the fraction’s numerator and denominator. Again we disregard the

cgroup logic, so here we assume that [dtc_dom()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n168) returns [global_wb_domain](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n120) which represents total system statistics.

We fundamentally determine the [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-specific dirty

threshold to be equal to *wb*\_*thresh* = *thresh* *×* *wb*\_*completions* , where thresh *completions* is the system-wide dirty threshold, wb_completions the number of pages which

completed writeback for this [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) and completions the num-ber of pages which completed writeback in the system.

This value is additionally modified to account for BDI

minimum and maximum ratio sysfs tunables described in

[Documentation/ABI/testing/sysfs-class-bdi](https://elixir.bootlin.com/linux/v6.0/source/Documentation/ABI/testing/sysfs-class-bdi) tunables documentation. The min-imum and maximum ratios default to 0% and 100% respectively, so unless these are specified to be otherwise, this will have no effect.

 

**10.20 Dirty Poll Interval**

 

Let’s briefly examine [dirty_poll_interval()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1406)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1406) which determines the

[struct task_struct-\>nr_dirtied_pause](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) value for freerunning threads. This is

shown in Listing 10-91.

 

1398 */\**

1399 *\* After a task dirtied this many pages, balance_dirty_pages_ratelimited()*

1400 *\* will look to see if it needs to start dirty throttling.* 1401 *\**

1402 *\* If dirty_poll_interval is too low, big NUMA machines will call the*

*expensive*

1403 *\* global_zone_page_state() too often. So scale it near-sqrt to the safety*

*margin*

1404 *\* (the number of pages we may dirty without exceeding the dirty limits).* 1405 *\*/*

1406 **static unsigned long dirty_poll_interval**(**unsigned long** dirty, 1407 **unsigned long** thresh) 1408 {

1409 **if** (thresh \> dirty) 1410 **return** 1UL \<\< (**ilog2**(thresh - dirty) \>\> 1); 1411

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1412 **return** 1;

1413 }

 

*Listing 10-91:* mm/page-writeback.c: [*dirty_poll_interval()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1406)

 

This determines the number of pages to be dirtied prior to *√*

2 lg(*thresh* *dirty*)*/*2 *−* which is equivalent to *thresh* *−* *dirty*, though con-

strained to an integer calculation form of this. If the threshold somehow

exceeds the dirty threshold at this point we default the result to 1 to encour-

age dirty throttling to occur almost immediately.

 

**10.21 Dirty Rate Limit**

 

We have now examined the means by which a great many of the param-

eters upon which dirty throttling relies are obtained. The last remain-

ing such parameters is are dirty rate limits which are determined by

[wb_update_dirty_ratelimit()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1172) upon dirty throttling, which we explore in List-

ing 10-92 (eliding out of scope BDI strict limit mode and tracing logic and

some superfluous comments).

 

1166 */\**

1167 *\* Maintain wb-\>dirty_ratelimit, the base dirty throttle rate.* 1168 *\**

1169 *\* Normal wb tasks will be curbed at or below it in long term.* 1170 *\* Obviously it should be around (write_bw / N) when there are N dd tasks.*

1171 *\*/*

1172 **static void wb_update_dirty_ratelimit**(**struct** dirty_throttle_control \*dtc, 1173 **unsigned long** dirtied, 1174 **unsigned long** elapsed) 1175 {

1176 **struct** bdi_writeback \*wb = dtc-\>wb; 1177 **unsigned long** dirty = dtc-\>dirty; 1178 **unsigned long** freerun = **dirty_freerun_ceiling**(dtc-\>thresh, dtc-\>

bg_thresh);

1179 **unsigned long** limit = **hard_dirty_limit**(**dtc_dom**(dtc), dtc-\>thresh); 1180 **unsigned long** setpoint = (freerun + limit) / 2; 1181 **unsigned long** write_bw = wb-\>avg_write_bandwidth; 1182 **unsigned long** dirty_ratelimit = wb-\>dirty_ratelimit; 1183 **unsigned long** dirty_rate; 1184 **unsigned long** task_ratelimit; 1185 **unsigned long** balanced_dirty_ratelimit; 1186 **unsigned long** step; 1187 **unsigned long** x;

1188 **unsigned long** shift; 1189

1190 */\**

1191 *\* The dirty rate will match the writeout rate in long term, except*

1192 *\* when dirty pages are truncated by userspace or re-dirtied by FS.*

1193 *\*/*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1194 dirty_rate = (dirtied - wb-\>dirtied_stamp) \* **HZ** / elapsed; 1195

1196 */\**

1197 *\* task_ratelimit reflects each dd's dirty rate for the past 200ms.*

1198 *\*/*

1199 task_ratelimit = (**u64**)dirty_ratelimit \* 1200 dtc-\>pos_ratio \>\> **RATELIMIT_CALC_SHIFT**

;

1201 task_ratelimit++; */\* it helps rampup dirty_ratelimit from tiny values*

*\*/*

1202

1203 */\**

1204 *\* A linear estimation of the "balanced" throttle rate. The theory is,*

1205 *\* if there are N dd tasks, each throttled at task_ratelimit, the wb's*

1206 *\* dirty_rate will be measured to be (N \* task_ratelimit). So the*

*below*

1207 *\* formula will yield the balanced rate limit (write_bw / N).* 1208 *\**

1209 *\* Note that the expanded form is not a pure rate feedback:* 1210 *\** *rate\_(i+1) = rate\_(i) \* (write_bw / dirty_rate)*

*(1)*

1211 *\* but also takes pos_ratio into account:* 1212 *\** *rate\_(i+1) = rate\_(i) \* (write_bw / dirty_rate) \* pos_ratio*

*(2)*

. . .

1226 *\* So we end up using (2) to always keep* 1227 *\** *rate\_(i+1) ~= (write_bw / N)*

*(8)*

1228 *\* regardless of the value of pos_ratio. As long as (8) is satisfied,*

1229 *\* pos_ratio is able to drive itself to 1.0, which is not only where*

1230 *\* the dirty count meet the setpoint, but also where the slope of*

1231 *\* pos_ratio is most flat and hence task_ratelimit is least fluctuated*

*.*

1232 *\*/*

1233 balanced_dirty_ratelimit = **div_u64**((**u64**)task_ratelimit \* write_bw, 1234 dirty_rate \| 1); 1235 */\**

1236 *\* balanced_dirty_ratelimit ~= (write_bw / N) \<= write_bw* 1237 *\*/*

1238 **if** (**unlikely**(balanced_dirty_ratelimit \> write_bw)) 1239 balanced_dirty_ratelimit = write_bw; 1240

1241 */\**

1242 *\* We could safely do this and return immediately:* 1243 *\**

1244 *\** *wb-\>dirty_ratelimit = balanced_dirty_ratelimit;* 1245 *\**

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

*Listing 10-92:* mm/page-writeback.c: [*wb_update_dirty_ratelimit()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1172) *basic*

*calculation*

 

We start by examining the core dirty rate logic. The function is invoked

by [\_\_wb_update_bandwidth()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1330) (see Listing 10-82) which is in turn invoked by

[balance_dirty_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1557) with the update_ratelimit parameter set, having set the

appropriate fields in the [struct dirty_throttle_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n123) object, including the

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) object and associated thresholds.

We start by performing a simple calculation to obtain

dirty_rate *dirtied* *dirtied*\_ *−**stamp* —we calculate , where dirtied is *elapsed*

equal to the [struct bdi_writeback-\>stats\[WB_DIRTIED\]](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) parameter

snapshotted in [\_\_wb_update_bandwidth()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1330)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n1330) dirtied_stamp equal to

[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>dirtied_stamp and therefore the previous dirtied

timestamp and elapsed is the time period since the last time we updated the

dirty rate. This therefore gives us a raw, linear dirty rate since last updated.

Note that we also multiply by the global value HZ, this converts the elapsed

time from the kernel-internal jiffies time metric to seconds such that this

rate has units of dirty pages per second.

Note that, importantly, this is the per[-](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)[struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105) dirty rate

rather than global dirty rate.

 

**N O T E** Here I refer to threads in order specifically to differentiate between processes which

may have multiple threads each writing back separately and the actual running

threads to which this dirty throttling applies (and equally, to which the global

[*current*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/current.h?h=v6.0#n18) macro refers). Within the kernel, there is no process abstraction but rather

a task one, embodied in a [*struct task_struct*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) type. Each task is at a thread granu-

larity rather than a process one.

 

The dirty_ratelimit variable is set to [struct bdi_writeback-\>dirty_ratelimit](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105),

i.e. the previous per-thread dirty rate limit.

After having obtained this, we multiply this by position ratio, previ-

ously calculated in [wb_position_ratio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n889) (see Listing 10-86) which we place in

task_ratelimit, incrementing by 1 to prevent truly tiny rate limits.

The position ratio is a modifier used to adjust the dirty rate limit such

that it converges on the setpoint, so this task_ratelimit value represents the

target, per-thread dirty rate.

Note that this is the previous dirty rate, now adjusted to converge on the

setpoint, we need a means of sensibly obtaining the current dirty rate that

should be applied per-thread.

This is where a magical inference takes place. Ideally, once at the set-

point, we would use all of the available write bandwidth provided by the

block device (which may vary over time).

Thus if we had N processes and write_bw average write bandwidth (ob-

tained from [struct bdi_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n105)-\>avg_write_bandwidth), we’d aim to maintain

a per-thread dirty limit of *write*\_*bw* .

*N*

The issue is that we do not know N. Instead we infer it—if we assume that

the dirty rate expressed in dirty_rate is achieving this aim, then we can infer

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

that *dirty*\_*rate* = *N* *×* *task*\_*ratelimit*, as each thread which is writing back would be operating at this rate limit.

Since this is the task_ratelimit field which has the position ratio applied,

this assumption will converge to being true as the ratio coefficient adjusts dirtying rate to achieve a steady state set point.

We can therefore determine the new balanced (among threads) dirty limit

to be:

*task*\_*ratelimit**×**write*\_*bw*

Which, since we have inferred that *dirty*\_*rate* = *N* *×* *dirty*\_*rate*

*task* \_*ratelimit* (or we

are a least converging towards this) reduces to:

*task*\_*ratelimit**×**write*\_*bw* *write*\_*bw* = *task* \_ *ratelimit* *×* *N* *N* Therefore matching the dirty rate limit to the evenly-divided per-thread write bandwidth value. This forms the core of our calculation of the new dirty rate.

However, it is also useful to maintain a smoothed equivalent of this value

which does not vary as much as this potentially will to ease calculations which might otherwise contain a great deal of variance, so we take steps to

do so as shown in Listing 10-93.

 

1246 \* However to get a more stable dirty_ratelimit, the below elaborated

1247 \* code makes use of task_ratelimit to filter out singular points and

1248 \* limit the step size. 1249 \*

1250 \* The below code essentially only uses the relative value of 1251 \*

1252 \* task_ratelimit - dirty_ratelimit 1253 \* = (pos_ratio - 1) \* dirty_ratelimit 1254 \*

1255 \* which reflects the direction and size of dirty position error. 1256 \*/

1257

1258 */\**

1259 *\* dirty_ratelimit will follow balanced_dirty_ratelimit iff* 1260 *\* task_ratelimit is on the same side of dirty_ratelimit, too.* 1261 *\* For example, when* 1262 *\* - dirty_ratelimit \> balanced_dirty_ratelimit* 1263 *\* - dirty_ratelimit \> task_ratelimit (dirty pages are above setpoint)*

1264 *\* lowering dirty_ratelimit will help meet both the position and rate*

1265 *\* control targets. Otherwise, don't update dirty_ratelimit if it will*

1266 *\* only help meet the rate target. After all, what the users*

*ultimately*

1267 *\* feel and care are stable dirty rate and small position error.* 1268 *\**

1269 *\* \|task_ratelimit - dirty_ratelimit\| is used to limit the step size*

1270 *\* and filter out the singular points of balanced_dirty_ratelimit.*

*Which*

1271 *\* keeps jumping around randomly and can even leap far away at times*

1272 *\* due to the small 200ms estimation period of dirty_rate (we want to*

 


The Linux Memory Manager (Early Access) © 2025 by Lorenzo Stoakes

 

1273 *\* keep that period small to reduce time lags).* 1274 *\*/*

1275 step = 0;

. . .

1296 **if** (dirty \< setpoint) { 1297 x = **min3**(wb-\>balanced_dirty_ratelimit, 1298 balanced_dirty_ratelimit, task_ratelimit); 1299 **if** (dirty_ratelimit \< x) 1300 step = x - dirty_ratelimit; 1301 } **else** {

1302 x = **max3**(wb-\>balanced_dirty_ratelimit, 1303 balanced_dirty_ratelimit, task_ratelimit); 1304 **if** (dirty_ratelimit \> x) 1305 step = dirty_ratelimit - x; 1306 }

1307

1308 */\**

1309 *\* Don't pursue 100% rate matching. It's impossible since the balanced*

1310 *\* rate itself is constantly fluctuating. So decrease the track speed*

1311 *\* when it gets close to the target. Helps eliminate pointless tremors*