
 

**14**

 

**P R A C T I C A L M E M O R Y**

 

**M A N A G E M E N T**

 

We’ve explored the detailed internals of numerous features of the kernel

memory manager, however under ordinary circumstances these are details

that are transparent to users.

What users interact with are the interfaces exposed by the kernel. These

consist of:-

 

**Userland** **libc** **memory allocation functions** – [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) (a wrapper around

a syscall) (alongside the related [munmap()](https://man7.org/linux/man-pages/man2/munmap.2.html) and [msync()](https://man7.org/linux/man-pages/man2/msync.2.html)[,](https://man7.org/linux/man-pages/man2/msync.2.html) [brk()](https://man7.org/linux/man-pages/man2/brk.2.html) (alongside

[sbrk()](https://man7.org/linux/man-pages/man2/sbrk.2.html) a wrapper around a syscall) and [malloc()](https://man7.org/linux/man-pages/man3/malloc.3.html) (which maintains an in-ternal userland cache of available memory, using the former two func-tions to obtain memory from the kernel in the first instance). We have examined these in detail in chapters 5 (memory mapping) and 8 (memory ma-nipulation).

**Reading** [**procfs**](https://man7.org/linux/man-pages/man5/proc.5.html) **and** [**sysfs**](https://man7.org/linux/man-pages/man5/sysfs.5.html) **interfaces** – There are a number of means of in-

terrogating memory in the kernel exposed in the procfs and sysfs file systems.

**Tunables** – There are a number of tunable flags available in both procfs and

sysfs which allow a user to perform actions as well as to customise the memory manager’s behaviour.


 

**Crash reports and** **sysrq** – When the Out Of Memory (OOM) killer frees up

memory, it provides a report on currently available memory as well as details of the circumstances around the out of memory condition. This can also be obtained by writing m to /proc/sysrq-trigger.

**Memory manipulation via syscalls** – [madvise()](https://man7.org/linux/man-pages/man2/madvise.2.html) allows for ‘hints’ to be given

to the kernel for a range of virtual memory. [mprotect()](https://man7.org/linux/man-pages/man2/mprotect.2.html) permits the ma-nipulation of access protections for a range of virtual memory (princi-

pally read/write/execute). Memory mapped via [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) can be moved

around using [mremap()](https://man7.org/linux/man-pages/man2/mremap.2.html). Memory ranges can locked to prevent them from

being reclaimed via [mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html) (and unlocked via [munlock()](https://man7.org/linux/man-pages/man2/munlock.2.html)[).](https://man7.org/linux/man-pages/man2/munlock.2.html) See chapter 8 on memory manipulation for more details.

**Tracking memory usage** – Interfaces such as that provided for tracking [soft-](https://kernel.org/doc/html/v6.0/admin-guide/mm/soft-dirty.html)

[dirty](https://kernel.org/doc/html/v6.0/admin-guide/mm/soft-dirty.html) bits, [idle page tracking](https://kernel.org/doc/html/v6.0/admin-guide/mm/idle_page_tracking.html), [soft-dirty](https://kernel.org/doc/html/v6.0/admin-guide/mm/soft-dirty.html) and the [DAMON](https://kernel.org/doc/html/v6.0/admin-guide/mm/damon.html) Data Access MONi-tor – allow for tracking of memory behaviour within processes.

**Examining page table metadata** – Page tables and flags can be examined

via the [page map](https://kernel.org/doc/html/v6.0/admin-guide/mm/pagemap.html) interface via /proc/\$pid/pagemap, /proc/\$pid/kpagecount and /proc/\$pid/kpageflags files.

**Raw access to process memory** – A process’s memory can be accessed di-

rectly via /proc/\$pid/mem with sufficient permission.

**Copying memory** – Memory can be manually transferred between pro-

cesses via [process_vm_readv()](https://man7.org/linux/man-pages/man2/process_vm_readv.2.html) and [process_vm_writev()](https://man7.org/linux/man-pages/man2/process_vm_writev.2.html)[.](https://man7.org/linux/man-pages/man2/process_vm_writev.2.html)

**Sharing memory** – Memory can be shared between processes by numerous

means, for instance mapping anonymous memory via [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) using the MAP_SHARED flag to share memory between a parent and forked child pro-cesses, children, or by multiple processes mapping a shared file, whether RAM-backed or not.

Sharing memory by file descriptor can be achieved by use of sys-

tem V shared memory system calls, the POSIX [shm interface](https://man7.org/linux/man-pages/man7/shm_overview.7.html)[,](https://man7.org/linux/man-pages/man7/shm_overview.7.html) using

[memfd_create()](https://man7.org/linux/man-pages/man2/memfd_create.2.html) to create a RAM-backed anonymous file (i.e. one that does not appear in the file system), or simply by mapping a file.

[**userfaultfd**](https://kernel.org/doc/html/v6.0/admin-guide/mm/userfaultfd.html) – userfaultfd is a means by which userland can handle page

faults and manually decide how to back them.

[ptrace()](https://man7.org/linux/man-pages/man2/ptrace.2.html) – The ptrace functionality permits one process to access the mem-

ory of another for the purposes of debugging (it does this utilising the

Get User Pages or GUP functionality, see section 8.1.2 for more details on this).

[mincore()](https://man7.org/linux/man-pages/man2/mincore.2.html) – The mincore interface allows an application to determine which

pages are resident in memory and which will result in a page fault.

 

Covering each of these in depth would constitute a book of its own, so

instead we will examine a useful subset of these interfaces in detail.

 



 

**14.1 Measuring free memory**

 

When trying to determine how much free memory is available in the system,

a user will almost certainly reach for the [free](https://man7.org/linux/man-pages/man1/free.1.html) utility. For instance:-

 

\[~\]\$ free

total used free shared buff/cache

available

Mem: 65779944 3973116 59395864 232428 3344276

61806828

Swap: 10485756 0 10485756

 

*Listing 14-1:* [*free*](https://man7.org/linux/man-pages/man1/free.1.html) *example*

 

By default the output is expressed in KiB, as a result it’s often useful to

pass the-h flag to obtain ‘human readable’ output:-

 

\[~\]\$ free -h

total used free shared buff/cache

available

Mem: 62Gi 3.8Gi 56Gi 212Mi 3.2Gi 58

Gi

Swap: 9Gi 0B 9Gi

 

*Listing 14-2:* [*free*](https://man7.org/linux/man-pages/man1/free.1.html) *-h* *example*

 

There are a number of other options that can be passed to this com-

mand, but typically this is sufficient for most users.

In order to determine precisely where these number come from,

we should examine where [free](https://man7.org/linux/man-pages/man1/free.1.html) obtains its data from in the first place –

/proc/meminfo (eliding fields not relevant to the output of [free](https://man7.org/linux/man-pages/man1/free.1.html)):-

 

\[~\]\$ cat /proc/meminfo

MemTotal: 65779944 kB

MemFree: 59849892 kB

MemAvailable: 62306792 kB

Buffers: 395824 kB

Cached: 2767732 kB

SwapCached: 0 kB

...

SwapTotal: 10485756 kB

SwapFree: 10485756 kB

...

Shmem: 209176 kB

Slab: 338064 kB

SReclaimable: 207356 kB

SUnreclaim: 130708 kB

...

 



 

*Listing 14-3: Example output of* */proc/meminfo*

 

It is this interface that [free](https://man7.org/linux/man-pages/man1/free.1.html) retrieves its data from, mapped as follows:-

 

• total = MemTotal – Total usable physical memory in the system. This may

be less than installed physical memory if running in a virtual machine, or if some memory is otherwise unavailable.

• used = MemTotal - MemAvailable – Perhaps surprisingly, this is an estimate

of currently in-use memory which cannot be easily dropped on mem-ory pressure, equal to total physical memory available to the system, less heuristically-determined available memory (see below for details).

• free = MemFree – All memory that is not currently in use for any purpose.

• shared = Shmem – The total amount of shmem memory, i.e. memory used

for RAM-backed file systems, most notably tmpfs.

• buff/cache = Buffers + Cached + SReclaimable – The amount of memory

utilised by kernel buffers and the page cache (see the page cache chapter for more details on both) or reclaimable kernel slab allocator pages (see the slab chapter for details on what this means specifically). Buffers is equal to the total number of block device pages, Cached is equal to total file-backed pages minus swap cache (see the swap chapter for details of how swap cache functions) and block device pages. Therefore buff/cache sums to the total number of file-backed and slab-reclaimable pages minus swap cache pages.

• available = MemAvailable – The estimated amount of available memory

without causing swapping, thrashing (a cycle of evicting and refaulting page cache entries which causes significant system stress) or triggering the Out Of Memory killer. See below for details on how this is calcu-lated.

 

**N O T E** See [*https://gitlab.com/procps-ng/procps/-/blob/master/src/free.c*](https://gitlab.com/procps-ng/procps/-/blob/master/src/free.c) and [*https:*](https://gitlab.com/procps-ng/procps/-/blob/master/library/meminfo.c)

[*//gitlab.com/procps-ng/procps/-/blob/master/library/meminfo.c*](https://gitlab.com/procps-ng/procps/-/blob/master/library/meminfo.c) for [*free*](https://man7.org/linux/man-pages/man1/free.1.html) imple-mentation details (as of the time of writing).

 

The most important metric for determining available memory is, natu-

rally, MemAvailable. In most cases, a user determines how much free mem-

ory is available in the system by looking at the available value in [free](https://man7.org/linux/man-pages/man1/free.1.html)[,](https://man7.org/linux/man-pages/man1/free.1.html) so it’s worth investigating the source of this value in detail.

The value is heuristic by nature—in order to avoid thrashing, we must re-

tain a certain proportion of the page cache. In order to avoid reclaim being triggered risking the OOM killer, we must maintain pages above both the

high water mark (see section 2.4 for more on nodes, zones, and watermarks)

and the worst case low memory reserve (see sections 2.4.2 and 2.4.1 respec-tively for details of these).

The algorithm for determining available pages is determined empirically

as follows:

 



 

• Determine the sum of the low water marks for each zone in the system.

This will be used to determine the minimum amount of memory re-served for the page cache and reclaimable kernel (that is slab) memory. In each case, we cap this reserve at half of the size of reclaimable mem-ory.

• Initialise available memory to total free memory minus

[totalreserve_pages . ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n264)The totalreserve_pages value comprises the sum of all zone high water marks and worst-case low memory reserve (see section

2.4.2 for details on how this is calculated).

• Calculate the total size of the page cache (not including shmem), and

add it to available memory on assumption it can be freed, less the sum of low water marks for each zone (capped at half of the non-shmem page cache size—that is, we reserve at maximum half of the non-shmem page cache).

• Calculate the sum of reclaimable slab memory (equal to SReclaimable in

/proc/meminfo), and add it to available memory on assumption it can be freed, less the sum of low water marks for each zone (capped at half of reclaimable slab memory—that is, we reserve at maximum half of slab reclaimable memory).

 

**N O T E** An added complication to page cache considerations is shmem—folios belonging to

these reside in the page cache but for the purposes of LRU (see Chapter 11 for more

on the LRU and reclaim) are treated as anonymous and thus are swapped out un-

der memory pressure. As shmem components can’t be easily dropped under memory

pressure (they need to be swapped out), we do not consider them as part of this calcu-

lation.

 

So in summary – MemAvailable is equal to the sum of free and quickly re-

claimable non-reserved memory.

 

***14.1.1 Kernel implementation of MemAvailable***

The function which generates the data for /proc/meminfo is

[meminfo_proc_show(). ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/meminfo.c?h=v6.0#n32)This in turn invokes [si_mem_available()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5919) to obtain the

MemAvailable value:-

 

5919 **long si_mem_available**(**void**) 5920 {

5921 **long** available;

5922 **unsigned long** pagecache; 5923 **unsigned long** wmark_low = 0; 5924 **unsigned long** pages\[**NR_LRU_LISTS**\]; 5925 **unsigned long** reclaimable; 5926 **struct** zone \*zone; 5927 **int** lru;

5928

 



 

5929 **for** (lru = **LRU_BASE**; lru \< **NR_LRU_LISTS**; lru++) 5930 pages\[lru\] = **global_node_page_state**(**NR_LRU_BASE** + lru); 5931

5932 for_each_zone(zone) 5933 wmark_low += **low_wmark_pages**(zone); 5934

5935 */\**

5936 *\* Estimate the amount of memory available for userspace allocations,*

5937 *\* without causing swapping or OOM.* 5938 *\*/*

5939 available = **global_zone_page_state**(**NR_FREE_PAGES**) -**totalreserve_pages**

;

5940

5941 */\**

5942 *\* Not all the page cache can be freed, otherwise the system will*

5943 *\* start swapping or thrashing. Assume at least half of the page* 5944 *\* cache, or the low watermark worth of cache, needs to stay.* 5945 *\*/*

5946 pagecache = pages\[**LRU_ACTIVE_FILE**\] + pages\[**LRU_INACTIVE_FILE**\]; 5947 pagecache -= **min**(pagecache / 2, wmark_low); 5948 available += pagecache; 5949

5950 */\**

5951 *\* Part of the reclaimable slab and other kernel memory consists of*

5952 *\* items that are in use, and cannot be freed. Cap this estimate at*

*the*

5953 *\* low watermark.* 5954 *\*/*

5955 reclaimable = **global_node_page_state_pages**(**NR_SLAB_RECLAIMABLE_B**) + 5956 **global_node_page_state**(**NR_KERNEL_MISC_RECLAIMABLE**); 5957 available += reclaimable -**min**(reclaimable / 2, wmark_low); 5958

5959 **if** (available \< 0) 5960 available = 0; 5961 **return** available; 5962 }

 

*Listing 14-4:* mm/page_alloc.c: [*si_mem_available()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5919)

 

This function utilises [global_node_page_state()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmstat.h?h=v6.0#n200) to obtain aggregate node

statistical counters indicating the number of pages on each LRU list (see

11.2 for more details on LRUs), by examining the range of available LRU

statistics offset from [LRU_BASE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n274) + [NR_LRU_BASE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n172) consisting of [NR_LRU_LISTS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n284) ele-ments.

The [global_node_page_state()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmstat.h?h=v6.0#n200) function is additionally used to ob-

tain the number of slab-reclaimable pages via [NR_SLAB_RECLAIMABLE_B](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n178) and the number of miscellaneous yet reclaimable kernel buffer pages via

[NR_KERNEL_MISC_RECLAIMABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n211).

 



 

The [global_zone_page_state()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmstat.h?h=v6.0#n179) function is used to obtain total free pages via

[NR_FREE_PAGES, ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n154)minus [totalreserve_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n264) (again, see section 2.4.2 for details on

how this value is obtained).

 

***14.1.2 Higher order folios***

It most cases all a user need know is the total available memory. However,

non-vmalloc kernel memory allocations such as those performed in drivers

will often require higher order allocations. These may arise for instance from

file system operations.

The concept of page orders arise from the nature of the underlying phys-

ical memory allocator within the kernel, the buddy allocator (see section 2.7

for a detailed description).

Folios of higher order are of size *order* 2 base pages, e.g. an order-5 page is

of 5 2 or 32 pages, i.e. on x86-64, 128 KiB in size.

The buddy allocator aggregates physical memory in folios of up to order

[MAX_ORDER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n28)*−*1. When memory of lower orders are allocated and insufficient

folios at that size exist, larger ones are split in half repeatedly until folios of

the appropriate size are made available.

Order-0 pages are therefore the easiest to come by – either you have

some available, or any other higher order folio can be split until you do.

For higher order folios, fragmentation might mean sufficient memory

is available in the system but not physically contiguous memory, i.e. at the

required order. In this instance, memory allocations will fail leading poten-

tially to the Out Of Memory (OOM) killer being invoked.

In addition, NUMA systems further complicate things, as you may re-

quire memory on a specific node. (see section 2.4 for more on nodes and

zones).

 

**N O T E** It may also be the case that for instance a driver requires memory from a specific

zone, e.g. *ZONE_DMA32*, however low memory reserve protects against exhaustion of

this resource (see section 2.4.1), so it is unlikely to cause significant fragmentation

issues.

 

It is therefore useful to get a sense of memory availability for each node,

zone and folio order. This information is available in /proc/buddyinfo, for

example:-

 

\$ cat /proc/buddyinfo

Node 0, zone DMA 0 0 0 0 0 0 0 0 1 1

2

Node 0, zone DMA32 5 6 6 4 5 3 6 6 5 4

221

Node 0, zone Normal 3310 6163 9144 6336 2200 547 106 53 27 14

14288

 

*Listing 14-5: Example of output of* */proc/buddyinfo*

 



 

Each column relates to a folio order, so for instance this indicates that

zones DMA, DMA32 and normal have order-10 folio counts of 2, 221 and 14,288 respectively.

This interface can be useful for determining if fragmentation has oc-

curred or is likely to soon occur within a system – if there is a scarcity of higher order folios, then higher order folio fragmentation becomes signif-icantly more likely.

 

***14.1.3 Summary***

Use [free](https://man7.org/linux/man-pages/man1/free.1.html) or MemAvailable from /proc/meminfo to determine available free mem-ory.

If higher order folio fragmentation is a concern, check /proc/buddyinfo to

determine the current availability of higher order folios.

 

**14.2 Measuring the memory usage of a process**

Often a user will want to assess the impact a particular process has on mem-ory usage in the system.

The most direct means of gathering the details of a process’s memory

usage is via /proc/\$pid/status or the more succinct /proc/\$pid/stat.

 

**N O T E** The */proc/\$pid/statm* interface is frankly rather obsolete and doesn’t provide overly

useful information.

 

Here we will focus on determining the how much resident memory a pro-

cess is using via /proc/\$pid/status, referred to as the Resident Set Size or RSS. This is the amount of memory that has been faulted in to this process specif-ically.

The first port of call is /proc/\$pid/status. For instance, examining the

relevant fields in some example output:-

 

\$ cat /proc/\$pid/status

...

VmHWM: 97384 kB

VmRSS: 97276 kB

RssAnon: 48080 kB RssFile: 49196 kB RssShmem: 0 kB ...

 

*Listing 14-6: Example output of* */proc/\$pid/status*

 

Examining each:-

 

• VmHWM – This indicates the peak resident memory usage of the process,

i.e. the maximum amount of resident memory the process has utilised during its execution.

 



 

• VmRSS – This indicates the amount of resident memory currently in use,

equal to the sum of RssAnon, RssFile and RssShmem.

• RssAnon – The amount of resident memory currently in use for anony-

mous, i.e. non-file backed mappings.

• RssFile – The amount of resident memory currently in use for file-

backed mappings (excluding shmem memory).

• RssShmem – The amount of memory used for shmem files, i.e. ones stored

in tmpfs, ‘anonymous’ shared memory, system V shared memory and the like (see section **??** for more details).

 

These value are derived from the memory management statistical coun-

ters maintained in the kernel to track memory events, the updating of which

is throttled in order to avoid performance impact.

As a result, these values will not quite be accurate. They may be offset up

to [TASK_RSS_EVENTS_THRESH](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree//mm/memory.c?h=v6.0#n207) (64) pages from reality (i.e. 256 KiB on an x86-64

system) per thread. See section 4.6 for a detailed description of RSS counters.

It’s also worth noting that an edge case exists in [vm_insert_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1976)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1976) which

does not synchronise RSS statistics at all. This is used by the zero-copy TCP

receive mechanism within the kernel so if you are utilising this then data re-

trieved this way will have its RSS statistics accounted only after a subsequent

page fault.

If a user wants to determine precise resident memory usage of a process,

the /proc/smaps or far more convenient /proc/smaps_rollup interface provides

this information by explicitly walking a process’s VMAs and determining

memory usage, e.g.:-

 

\$ cat /proc/\$pid/smaps_rollup

564c5c06e000-7fffc2bf1000 ---p 00000000 00:00 0 \[

rollup\]

Rss: 101592 kB

Pss: 71426 kB

Pss_Dirty: 52380 kB

Pss_Anon: 52368 kB

Pss_File: 19046 kB

Pss_Shmem: 12 kB

Shared_Clean: 35892 kB

Shared_Dirty: 28 kB

Private_Clean: 13304 kB

Private_Dirty: 52368 kB

Referenced: 101592 kB

Anonymous: 52368 kB

LazyFree: 0 kB

AnonHugePages: 38912 kB

ShmemPmdMapped: 0 kB

FilePmdMapped: 2048 kB

Shared_Hugetlb: 0 kB

Private_Hugetlb: 0 kB

 



 

Swap: 0 kB SwapPss: 0 kB Locked: 0 kB

 

*Listing 14-7: Example* */proc/\$pid/smaps_rollup* *output*

 

This walks the process address space’s VMAs while holding

[struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) , via [walk_page_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/pagewalk.c?h=v6.0#n512)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/pagewalk.c?h=v6.0#n512) walking each individual

page’s page tables in order to reach the underlying [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72), from which page table flags are used to determine what pages are actually present in

each virtual address range (in [smaps_account()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n444)).

 

***14.2.1 Proportional Set Size***

If multiple processes map a file, each one will have its Resident Set Size (RSS) updated upon faulting in the mapping. Therefore, if for instance 100 processes map a single file, summing the RSS of these processes will result in there seeming to be 100 times the amount of memory used than is used in actuality.

Therefore it is not quite right to say that memory indicates how much

physical memory a process consumes, but rather how much physical mem-ory it maps.

In listing 14-7 we can see entries pertaining to PSS or Proportional Set

Size. This is a means of addressing this issue with overcounting RSS – rather than considering each process which maps a file (for instance, a shared li-brary) to account for the entire size of that file, each page of resident mem-ory is divided by the number times it is mapped (whether in the same pro-

cess or by other processes), i.e. each [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72)[’s](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) map count as determined

by [page_mapcount()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n825).

See below in section 14.5.2 for further discussion of proportional set size

in the context of a process’s /proc/\$pid/smaps output.

 

***14.2.2 Summary***

Generally, it’s sufficient to use /proc/\$pid/status and examine the Rss and VmHWM fields to determine current and peak memory usage respectively.

However, if you require absolute precision, your process spawns a great

many threads, or you want proportional values then use /proc/\$pid/smaps or /proc/\$pid/smaps_rollup.

 

**14.3 Memory mapping using mmap()**

 

The [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) function is the most direct means of establishing memory map-

pings within a process. In most cases, its use is unnecessary, as [malloc()](https://man7.org/linux/man-pages/man2/malloc.2.html) (or

abstractions which wrap it) will utilise [sbrk()](https://man7.org/linux/man-pages/man2/sbrk.2.html) and mmap() to map memory from the kernel as necessary for you, with the added benefit of maintaining efficient sub-page size free lists.

 



 

However there are circumstances where it makes sense to do so, for in-

stance when mapping files and taking advantage of the fact that can you

write directly to and read directly from the page cache.

See section 5.0.2 for an in-depth analysis of how this logic is imple-

mented within the kernel.

The [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) command is comprised of six parameters –

void \*mmap(void \*addr, size_t length, int prot, int flags, int fd, off_t off)

– and returns a pointer to the mapped region, or the MAP_FAILED constant

value, setting errno to indicate why it failed.

The addr parameter specifies where we would prefer the mapping to be

placed, however in typical usage this is usually set to NULL, indicating that we

are happy for the kernel to decide (we will examine cases where we do specify

this shortly).

The length parameter specifies the length of the mapping, which does

not need to be page-aligned, but if it isn’t it will implicitly be rounded up

to a page boundary. prot and flags specify the protection bits (i.e. read-

/write/execute) for the mapping and flags specify flags specifying how the

mapping should be performed.

Finally, fd specifies a file descriptor of the file if mapping one, or -1 if not

and off specifies the offset into that file.

Again, see section 5.0.2 for a detailed examination of the command.

Note that we explore use of [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) for shared memory applications below

in section 14.7.

 

***14.3.1 Mapping anonymous memory***

Therefore, a typical invocation of [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) is as follows:-

 

1 **\#include** \<stdio.h\>

2 **\#include** \<stdlib.h\>

3 **\#include** \<sys/mman.h\>

4 **\#include** \<unistd.h\>

5

6 **int main**(**void**)

7 {

8 **const long** page_size = **sysconf**(**\_SC_PAGESIZE**);

9 **char** \*ptr = **mmap**(**NULL**, page_size, **PROT_READ** \| **PROT_WRITE**,

10 **MAP_ANON** \| **MAP_PRIVATE**, -1, 0);

11

12 **if** (ptr == **MAP_FAILED**) {

13 **perror**("**mmap**");

14 **return EXIT_FAILURE**;

15 }

16

17 */\* ...do things with the mapping... \*/*

18

19 **if** (**munmap**(ptr, page_size)) {

 



 

20 **perror**("**munmap**"); 21 **return EXIT_FAILURE**; 22 }

23

24 **return EXIT_SUCCESS**; 25 }

 

*Listing 14-8: Example of a basic anonymous* [*mmap()*](https://man7.org/linux/man-pages/man2/mmap.2.html) *mapping*

 

We specify PROT_READ and PROT_WRITE as we intend the mapping to be read-

/write, MAP_ANON as shorthand for MAP_ANONYMOUS and MAP_PRIVATE as we have no intention of sharing memory.

We must always check whether [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) returns MAP_FAILED, then eventually

unmap the memory via [munmap()](https://man7.org/linux/man-pages/man2/munmap.2.html)[.](https://man7.org/linux/man-pages/man2/munmap.2.html)

 

***14.3.2 Mapping a file***

Mapping a file is rather more useful, and follows a similar pattern, only we

open a file via [open()](https://man7.org/linux/man-pages/man2/open.2.html) and pass the associated file descriptor alongside an off-set into the file:-

 

1 **\#include** \<fcntl.h\>

2 **\#include** \<stdio.h\>

3 **\#include** \<stdlib.h\>

4 **\#include** \<sys/mman.h\>

5 **\#include** \<sys/stat.h\>

6 **\#include** \<unistd.h\>

7

8 **int main**(**void**)

9 {

10 **int** fd;

11 **char** \*ptr;

12 **struct** stat st;

13

14 fd = **open**("test.txt", **O_RDWR**); 15 **if** (fd == -1) {

16 **perror**("**open**"); 17 **return EXIT_FAILURE**; 18 }

19

20 **if** (**fstat**(fd, &st)) { 21 **perror**("**fstat**"); 22 **return EXIT_FAILURE**; 23 }

24

25 ptr = **mmap**(**NULL**, st.st_size, **PROT_READ** \| **PROT_WRITE**, 26 **MAP_SHARED_VALIDATE**, fd, 0); 27 **if** (ptr == **MAP_FAILED**) {

 



 

28 **perror**("**mmap**");

29 **return EXIT_FAILURE**;

30 }

31

32 **close**(fd);

33

34 */\* ...do things with the mapping... \*/*

35

36 **if** (**msync**(ptr, st.st_size, **MS_SYNC**)) {

37 **perror**("**msync**");

38 **return EXIT_FAILURE**;

39 }

40

41 **if** (**munmap**(ptr, st.st_size)) {

42 **perror**("**munmap**");

43 **return EXIT_FAILURE**;

44 }

45

46 **return EXIT_SUCCESS**;

47 }

 

*Listing 14-9: Example of a basic file* [*mmap()*](https://man7.org/linux/man-pages/man2/mmap.2.html) *mapping*

 

Here we map the file at offset 0, indicating that we are mapping it shared

(we use MAP_SHARED_VALIDATE which is identical to MAP_SHARED but disallows in-

valid map flag combinations).

Note that we do not need to keep the file open any longer after we have

mapped it, the kernel will have looked up the [struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) object and the page

cache [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) object and will have incremented the reference

count on this object, obviating the need for the file to be kept open.

We synchronise our changes to disk via [msync()](https://man7.org/linux/man-pages/man2/msync.2.html)[,](https://man7.org/linux/man-pages/man2/msync.2.html) specifying the MS_SYNC

flag. This is the only flag that actually does any work (other than checks), as

MS_ASYNC is handled implicitly by writeback (see section **??**) and MS_INVALIDATE

only checks whether the mapping is [mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html)’d or not.

This synchronously writes our changes to the file to disk. This is not

done implicitly by [munmap()](https://man7.org/linux/man-pages/man2/munmap.2.html)[,](https://man7.org/linux/man-pages/man2/munmap.2.html) as again the kernel will perform writeback in due

course anyway so it is not necessarily.

Importantly – like anything mapped by [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html)[,](https://man7.org/linux/man-pages/man2/mmap.2.html) the length is rounded up to

the page boundary. Therefore it becomes possible to write, in the example

code shown above, to entries past the end of the file size but within the same

page containing valid data.

In this instance, those writes will do absolutely nothing. When mapping

files via [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html)[,](https://man7.org/linux/man-pages/man2/mmap.2.html) that mapping will remain static regardless of whether the size

of the file changes.

However, what if we map a range larger than the size of the file or it is

truncated to a size less than the page in which we write? In this instance, a

SIGBUS error will arise, which is very important to account for when memory-

mapping files.

 



 

It is also important to note that if an error occurs while accessing the file

(for instance, a network drive mount becomes disconnected), a SIGBUS will occur in this instance also.

Note that a file being removed, or more accurately [unlink()](https://man7.org/linux/man-pages/man2/unlink.2.html)’d has no im-

pact – this simply means the file is no longer hard linked from the opened location, but still exists as an inode on disk (until we are finished with it) and thus an entry in the page cache.

 

***14.3.3 Private file mapping***

There are instances where the semantics required are that a file is mapped, but the user requires writes to that file to not persist to it, but to cause the modified file data to be copied to anonymous memory.

This can be achieved by setting the MAP_PRIVATE flag in [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) when map-

ping the file. This means of mapping a file this way is quite efficient – it is achieved by establishing a copy-on-write read-only mapping to the page

cache (see section 5.0.2 for a detailed analysis of this works under the cov-ers).

However, it is important to remain mindful of the (perhaps surprising)

semantics this implies – if mapped pages in the file are truncated (which can result from a file being overwritten or shrunk for instance), any data written by the user will be lost and the buffer will revert to the newly truncated file

(see section 6.6 for more details).

Examining an example:-

 

1 **\#include** \<fcntl.h\>

2 **\#include** \<stdbool.h\>

3 **\#include** \<stdio.h\>

4 **\#include** \<stdlib.h\>

5 **\#include** \<string.h\>

6 **\#include** \<sys/mman.h\>

7 **\#include** \<sys/stat.h\>

8 **\#include** \<unistd.h\>

9

10 **int main**(**void**)

11 {

12 **int** fd;

13 **char** \*ptr;

14 **struct** stat st;

15

16 fd = **open**("test.txt", **O_RDWR**); 17 **if** (fd == -1) {

18 **perror**("**open**"); 19 **return EXIT_FAILURE**; 20 }

21

22 **if** (**fstat**(fd, &st)) {

 



 

23 **perror**("**fstat**");

24 **return EXIT_FAILURE**;

25 }

26

27 ptr = **mmap**(**NULL**, st.st_size, **PROT_READ** \| **PROT_WRITE**,

28 **MAP_PRIVATE**, fd, 0);

29 **if** (ptr == **MAP_FAILED**) {

30 **perror**("**mmap**");

31 **return EXIT_FAILURE**;

32 }

33

34 **close**(fd);

35

36 **while** (**true**) {

37 **char** chr;

38

39 **if** (**strncmp**(ptr, "exit", 4) == 0)

40 **break**;

41

42 chr = ptr\[0\];

43 **if** (chr \< 'a' \|\| chr == 'z') {

44 ptr\[0\] = 'a';

45 } **else** {

46 ptr\[0\]++;

47 }

48

49 **printf**("%s", ptr);

50 **sleep**(1);

51 }

52

53 **if** (**munmap**(ptr, st.st_size)) {

54 **perror**("**munmap**");

55 **return EXIT_FAILURE**;

56 }

57

58 **return EXIT_SUCCESS**;

59 }

 

*Listing 14-10: Example of a* *MAP_PRIVATE* *file* [*mmap()*](https://man7.org/linux/man-pages/man2/mmap.2.html) *mapping*

 

This program loops updating the contents of the first character of the

file which causes it to be copied to an anonymous page and remain there,

outputting the contents of the buffer as it goes.

However, if another process were to write to the file, you could observe

the data that has been written so far is immediately lost as the mapping is ‘re-

set’ to match that of the file.

 



 

***14.3.4 Fixed mappings***

It can be useful to establish large, empty virtual ranges, within which we map at known virtual addresses, for instance when implementing a custom alloca-tor.

We can achieve this by specifying the addr parameter to [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html)[,](https://man7.org/linux/man-pages/man2/mmap.2.html) along-

side MAP_FIXED. Without MAP_FIXED, the addr parameter is merely advisory, and

[mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) is free to ignore it.

It is important, however, to have established a mapping at the address

you are mapping to the first instance. This is confusing, as it seems odd to attempt to overwrite an existing mapping – intuitive would suggest this

would result in an error, however this is not the case – [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) with the MAP_FIXED flag set will simply overwrite any mapping it spans, replacing it.

If you wish to insist on a specified address but do not want this overwrit-

ing behaviour to occur, you can specify MAP_FIXED_NOREPLACE (in which case an existing, overlapping mapping will cause an error to be raised).

However, if you wish is not so much to have specific fixed addresses, but

rather to have known ones, such as the example of a custom allocator, then you can work around this by first establishing an empty mapping using PROT_NONE, then established fixed mappings within this space.

A PROT_NONE mapping can be as large as you like, it is not accounted for in

more restrictive overcommit modes (see section 4.1 for more on overcom-mit) and will cause page faults if accessed, so this forms the perfect backdrop for such an implementation.

Considering an example:-

 

1 **\#include** \<stdio.h\>

2 **\#include** \<stdlib.h\>

3 **\#include** \<sys/mman.h\>

4 **\#include** \<unistd.h\>

5

6 **\#define MAX_ALLOCS** (100)

7 **\#define ALLOC_SIZE** (1 \<\< 20) */\* 1 MiB \*/* 8

9 **int main**(**void**)

10 {

11 **int** i;

12 **void** \*span;

13 **const unsigned long** page_size = (**unsigned long**)**sysconf**(**\_SC_PAGESIZE**); 14 */\* 4 TiB should be sufficient. \*/* 15 **const unsigned long** size = page_size \<\< 30; 16

17 span = **mmap**(**NULL**, size, **PROT_NONE**, **MAP_ANON** \| **MAP_PRIVATE**, -1, 0); 18 **if** (span == **MAP_FAILED**) { 19 **perror**("**mmap**"); 20 **return EXIT_FAILURE**; 21 }

 



 

22

23 **for** (i = 0; i \< **MAX_ALLOCS**; i++) {

24 **void** \*ptr = **mmap**(span + i \* **ALLOC_SIZE**, **ALLOC_SIZE**,

25 **PROT_READ** \| **PROT_WRITE**,

26 **MAP_FIXED** \| **MAP_ANON** \| **MAP_PRIVATE**, -1, 0);

27

28 **if** (ptr == **MAP_FAILED**) {

29 **perror**("internal **mmap**");

30 **return EXIT_FAILURE**;

31 }

32 }

33

34 */\* Do something with mappings... \*/*

35

36 **if** (**munmap**(span, size)) {

37 **perror**("**munmap**");

38 **return EXIT_FAILURE**;

39 }

40

41 **return EXIT_SUCCESS**;

42 }

 

*Listing 14-11: Example of a fixed* [*mmap()*](https://man7.org/linux/man-pages/man2/mmap.2.html) *mapping*

This maps a giant 4 TiB span of memory as PROT_NONE, before mapping

100 individual 1 MiB read/write mappings within it. One thing to note here

is that [munmap()](https://man7.org/linux/man-pages/man2/munmap.2.html) is highly flexible – all mappings within the specified range are

freed, no matter what is contained within it (see section 5.0.6 for a detailed

discussion of how this is implemented).

 

**14.4 Interpreting Out Of Memory reports**

 

When the Out Of Memory (OOM) killer is invoked (see the OOM chapter

for more details on the OOM killer), it outputs details about what caused

the out of memory condition. Let’s examine an example of this report,

which appears in the kernel log (accessible via dmesg):-

 

\[ 5.168012\] oom invoked oom-killer: gfp_mask=0x140dca(GFP_HIGHUSER_MOVABLE\|\_\_GFP_COMP\|

\_\_GFP_ZERO), order=0, oom_score_adj=0

\[ 5.168019\] CPU: 0 PID: 246 Comm: oom Not tainted 6.0.0+ \#27 \[ 5.168021\] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Arch Linux

1.16.2-1-1 04/01/2014

\[ 5.168022\] Call Trace:

\[ 5.168026\] \<TASK\>

\[ 5.168029\] ? \_\_dump_stack+0x1b/0x21

\[ 5.168034\] ? dump_stack_lvl+0x27/0x3a \[ 5.168036\] ? dump_stack+0xc/0x11

\[ 5.168038\] ? dump_header+0x43/0x97

\[ 5.168040\] ? oom_kill_process+0xd0/0xd5

 



 

\[ 5.168042\] ? out_of_memory+0xbf/0x225 \[ 5.168044\] ? \_\_alloc_pages_may_oom+0xea/0x14f \[ 5.168046\] ? \_\_alloc_pages_slowpath+0x2b3/0x4e6 \[ 5.168048\] ? \_\_alloc_pages+0x157/0x181 \[ 5.168050\] ? \_\_folio_alloc+0xf/0x36

\[ 5.168052\] ? vma_alloc_folio+0x79/0x1d9 \[ 5.168054\] ? do_anonymous_page+0x86/0x31f \[ 5.168056\] ? follow_page_pte+0xe3/0x2a2 \[ 5.168059\] ? handle_pte_fault+0x144/0x168 \[ 5.168060\] ? \_\_handle_mm_fault+0x26c/0x28d \[ 5.168063\] ? handle_mm_fault+0x84/0xf6 \[ 5.168064\] ? faultin_page+0x52/0xc3

\[ 5.168066\] ? \_\_get_user_pages+0x25c/0x311 \[ 5.168068\] ? populate_vma_page_range+0x46/0x67 \[ 5.168070\] ? \_\_mm_populate+0x6b/0x106 \[ 5.168071\] ? vm_mmap_pgoff+0xdd/0xeb

\[ 5.168074\] ? ksys_mmap_pgoff+0x4c/0x154 \[ 5.168076\] ? \_\_do_sys_mmap+0x12/0x23

\[ 5.168078\] ? \_\_se_sys_mmap+0x5/0xa

\[ 5.168079\] ? \_\_x64_sys_mmap+0x20/0x25 \[ 5.168081\] ? do_syscall_64+0x5a/0x86

\[ 5.168083\] ? entry_SYSCALL_64_after_hwframe+0x63/0xcd \[ 5.168086\] \</TASK\>

\[ 5.168087\] Mem-Info:

\[ 5.168087\] active_anon:45 inactive_anon:1997113 isolated_anon:0

active_file:301 inactive_file:300 isolated_file:0

unevictable:0 dirty:56 writeback:0

slab_reclaimable:2419 slab_unreclaimable:4196

mapped:21 shmem:80 pagetables:4493 bounce:0

kernel_misc_reclaimable:0

free:25619 free_pcp:62 free_cma:0

\[ 5.168090\] Node 0 active_anon:180kB inactive_anon:7988452kB active_file:1204kB

inactive_file:1200kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:84kB dirty:224kB writeback:0kB shmem:320kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 7897088kB writeback_tmp:0kB kernel_stack:1792kB pagetables:17972kB all_unreclaimable? yes

\[ 5.168093\] Node 0 DMA free:15360kB boost:0kB min:124kB low:152kB high:180kB

reserved_highatomic:0KB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0 kB unevictable:0kB writepending:0kB present:15992kB managed:15360kB mlocked:0kB bounce:0kB

free_pcp:0kB local_pcp:0kB free_cma:0kB

\[ 5.168097\] lowmem_reserve\[\]: 0 2959 7938 7938 \[ 5.168099\] Node 0 DMA32 free:44940kB boost:0kB min:25148kB low:31432kB high:37716kB

reserved_highatomic:0KB active_anon:0kB inactive_anon:2984160kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129204kB managed:3035452kB mlocked:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB

\[ 5.168102\] lowmem_reserve\[\]: 0 0 4978 4978 \[ 5.168104\] Node 0 Normal free:42176kB boost:0kB min:42304kB low:52880kB high:63456kB

reserved_highatomic:0KB active_anon:180kB inactive_anon:5003724kB active_file:1604kB

 



 

inactive_file:800kB unevictable:0kB writepending:224kB present:5242880kB managed:5097828kB

mlocked:0kB bounce:0kB free_pcp:248kB local_pcp:248kB free_cma:0kB

\[ 5.168107\] lowmem_reserve\[\]: 0 0 0 0

\[ 5.168109\] Node 0 DMA: 0\*4kB 0\*8kB 0\*16kB 0\*32kB 0\*64kB 0\*128kB 0\*256kB 0\*512kB 1\*1024kB (U

) 1\*2048kB (M) 3\*4096kB (M) = 15360kB

\[ 5.168117\] Node 0 DMA32: 1\*4kB (M) 4\*8kB (UM) 4\*16kB (UM) 3\*32kB (U) 3\*64kB (UM) 0\*128kB

1\*256kB (M) 1\*512kB (M) 3\*1024kB (M) 2\*2048kB (UM) 9\*4096kB (M) = 45188kB

\[ 5.168127\] Node 0 Normal: 340\*4kB (UME) 164\*8kB (UE) 113\*16kB (UME) 76\*32kB (UME) 53\*64kB (

UE) 25\*128kB (UE) 6\*256kB (UME) 3\*512kB (UME) 1\*1024kB (E) 0\*2048kB 6\*4096kB (UM) = 42176 kB

\[ 5.168137\] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB

\[ 5.168138\] 706 total pagecache pages

\[ 5.168138\] 0 pages in swap cache

\[ 5.168139\] Free swap = 0kB

\[ 5.168139\] Total swap = 0kB

\[ 5.168140\] 2097019 pages RAM

\[ 5.168141\] 0 pages HighMem/MovableOnly \[ 5.168141\] 59859 pages reserved

\[ 5.168142\] Tasks state (memory values in pages): \[ 5.168142\] \[ pid \] uid tgid total_vm rss pgtables_bytes swapents oom_score_adj

name

\[ 5.168145\] \[ 115\] 0 115 12408 270 90112 0 -250 systemd-

journal

\[ 5.168147\] \[ 130\] 0 130 7476 429 77824 0 -1000 systemd-

udevd

\[ 5.168149\] \[ 135\] 0 135 7312 317 81920 0 0 (udev-

worker)

\[ 5.168150\] \[ 136\] 0 136 7312 317 86016 0 0 (udev-

worker)

\[ 5.168152\] \[ 137\] 0 137 7312 328 77824 0 0 (udev-

worker)

\[ 5.168153\] \[ 138\] 0 138 7312 325 86016 0 0 (udev-

worker)

\[ 5.168154\] \[ 139\] 0 139 7312 328 81920 0 0 (udev-

worker)

\[ 5.168155\] \[ 140\] 0 140 7312 318 65536 0 0 (udev-

worker)

\[ 5.168157\] \[ 141\] 0 141 7312 319 81920 0 0 (udev-

worker)

\[ 5.168158\] \[ 142\] 0 142 7312 329 81920 0 0 (udev-

worker)

\[ 5.168159\] \[ 143\] 0 143 7312 327 77824 0 0 (udev-

worker)

\[ 5.168160\] \[ 144\] 0 144 7312 322 65536 0 0 (udev-

worker)

\[ 5.168161\] \[ 145\] 0 145 7312 321 86016 0 0 (udev-

worker)

 



 

\[ 5.168163\] \[ 146\] 0 146 7481 377 90112 0 0 (udev-

worker)

\[ 5.168164\] \[ 147\] 0 147 7312 323 81920 0 0 (udev-

worker)

\[ 5.168165\] \[ 148\] 0 148 7483 355 90112 0 0 (udev-

worker)

\[ 5.168166\] \[ 149\] 0 149 7312 326 81920 0 0 (udev-

worker)

\[ 5.168167\] \[ 150\] 0 150 7312 325 77824 0 0 (udev-

worker)

\[ 5.168169\] \[ 151\] 0 151 7312 326 86016 0 0 (udev-

worker)

\[ 5.168170\] \[ 152\] 0 152 7312 327 77824 0 0 (udev-

worker)

\[ 5.168171\] \[ 153\] 0 153 7312 327 77824 0 0 (udev-

worker)

\[ 5.168172\] \[ 154\] 0 154 7312 328 81920 0 0 (udev-

worker)

\[ 5.168173\] \[ 155\] 0 155 7345 341 81920 0 0 (udev-

worker)

\[ 5.168174\] \[ 156\] 0 156 7345 329 77824 0 0 (udev-

worker)

\[ 5.168175\] \[ 157\] 0 157 7312 330 77824 0 0 (udev-

worker)

\[ 5.168176\] \[ 158\] 0 158 7312 331 77824 0 0 (udev-

worker)

\[ 5.168178\] \[ 163\] 81 163 2192 131 53248 0 -900 dbus-

daemon

\[ 5.168179\] \[ 166\] 974 166 770 79 40960 0 0 dhcpcd \[ 5.168181\] \[ 167\] 0 167 4315 242 81920 0 0 systemd-

logind

\[ 5.168182\] \[ 169\] 0 169 873 110 40960 0 0 dhcpcd \[ 5.168183\] \[ 170\] 974 170 722 75 40960 0 0 dhcpcd \[ 5.168184\] \[ 171\] 974 171 722 75 40960 0 0 dhcpcd \[ 5.168186\] \[ 183\] 0 183 757 68 40960 0 0 agetty \[ 5.168187\] \[ 184\] 0 184 2125 200 57344 0 0 login \[ 5.168188\] \[ 189\] 1000 189 4894 377 77824 0 100 systemd \[ 5.168189\] \[ 190\] 974 190 767 101 40960 0 0 dhcpcd \[ 5.168191\] \[ 191\] 974 191 767 101 40960 0 0 dhcpcd \[ 5.168192\] \[ 195\] 1000 195 6020 697 77824 0 100 (sd-pam) \[ 5.168193\] \[ 203\] 1000 203 1846 434 49152 0 0 zsh \[ 5.168194\] \[ 246\] 1000 246 33555023 1991355 16007168 0 0 oom \[ 5.168195\] oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),cpuset=/,mems_allowed=0,

global_oom,task_memcg=/user.slice/user-1000.slice/session-c1.scope,task=oom,pid=246,uid =1000

\[ 5.168206\] Out of memory: Killed process 246 (oom) total-vm:134220092kB, anon-rss:7965416kB

, file-rss:4kB, shmem-rss:0kB, UID:1000 pgtables:15632kB oom_score_adj:0

 



 

*Listing 14-12: Example OOM report*

This is rather intimidating and feels, at a glance feels, perhaps, impen-

etrable. Let’s therefore break this down bit-by-bit and analyse the output,

starting with the first line:-

 

***14.4.1 Failed allocation statistics***

The first line in the output outputs statistics related to the allocation which

failed:-

 

\[ 5.168012\] oom invoked oom-killer: gfp_mask=0x140dca(GFP_HIGHUSER_MOVABLE\|

\_\_GFP_COMP\|\_\_GFP_ZERO), order=0, oom_score_adj=0

 

*Listing 14-13: Example OOM failed allocation statistics*

This identifies the process which requested memory leading to the OOM

condition. Importantly, this is not necessarily the process which is hogging

memory, demand paging and overcommit (see section 4.1) dictate that any

process at any time might invoke an OOM condition. It is simply the process

which happened to trip the condition.

This line, generated by [dump_header()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n452), consists of four pieces of

information:-

 

**Invoking process name** – The name of the process that caused the OOM

condition. This process may very well be innocent, and simply hap-pened to request memory under severe memory pressure. In the example above this is a process called ‘oom’.

**GFP mask** – The GFP flags (see section 2.6) used for the physical mem-

ory allocation in question. This is important to note, as it will indicate

whether a specific zone was specified (e.g. [\_\_GFP_DMA32](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n74)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n74) or whether re-

strictive conditions were placed upon the allocation (e.g. [\_\_GFP_ATOMIC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n138)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n138) which might have led to the allocation being infeasible. In the example above however, this is a relatively straightforward user

allocation – [GFP_HIGHUSER_MOVABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n342) has been specified, indicating it was a user allocation which triggered the condition, which must be zeroed

[(\_\_GFP_ZERO) ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n249)and if it were compound to be initialised as a compound

folio ([\_\_GFP_COMP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n248)).

**Requested folio order** – This is very important information – if the re-

quested memory was of order 0, i.e. at the base page size (4 KiB for x86-64) then higher order fragmentation is certainly not the source of the out of memory condition. If it is, then this may well be a contributing factor.

In the example above, the triggering allocation is of order-0, so higher order folio fragmentation is not the cause.

**oom_score_adj** – Indicates the user-defined adjustment made to the out

of memory ‘score’ used to apply a weight to processes which are being

 



 

considered for OOM killing. See the OOM chapter for more details on how this functions.

 

**N O T E** The out of memory killer will not be invoked for higher-order allocations which ex-

ceed [*PAGE_ALLOC_COSTLY_ORDER*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n40), i.e. for any allocation at order-4 or above, as it is un-likely killing processes will do much to help free up such higher order memory under

heavy fragmentation (see section 11.3 for more details on direct reclaim logic).

 

***14.4.2 Stack trace***

Immediately following this is a call stack indicating how the allocation occurred:-

 

\[ 5.168019\] CPU: 0 PID: 246 Comm: oom Not tainted 6.0.0+ \#27 \[ 5.168021\] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS

Arch Linux 1.16.2-1-1 04/01/2014

\[ 5.168022\] Call Trace: \[ 5.168026\] \<TASK\>

\[ 5.168029\] ? \_\_dump_stack+0x1b/0x21 \[ 5.168034\] ? dump_stack_lvl+0x27/0x3a \[ 5.168036\] ? dump_stack+0xc/0x11 \[ 5.168038\] ? dump_header+0x43/0x97 \[ 5.168040\] ? oom_kill_process+0xd0/0xd5 \[ 5.168042\] ? out_of_memory+0xbf/0x225 \[ 5.168044\] ? \_\_alloc_pages_may_oom+0xea/0x14f \[ 5.168046\] ? \_\_alloc_pages_slowpath+0x2b3/0x4e6 \[ 5.168048\] ? \_\_alloc_pages+0x157/0x181 \[ 5.168050\] ? \_\_folio_alloc+0xf/0x36 \[ 5.168052\] ? vma_alloc_folio+0x79/0x1d9 \[ 5.168054\] ? do_anonymous_page+0x86/0x31f \[ 5.168056\] ? follow_page_pte+0xe3/0x2a2 \[ 5.168059\] ? handle_pte_fault+0x144/0x168 \[ 5.168060\] ? \_\_handle_mm_fault+0x26c/0x28d \[ 5.168063\] ? handle_mm_fault+0x84/0xf6 \[ 5.168064\] ? faultin_page+0x52/0xc3 \[ 5.168066\] ? \_\_get_user_pages+0x25c/0x311 \[ 5.168068\] ? populate_vma_page_range+0x46/0x67 \[ 5.168070\] ? \_\_mm_populate+0x6b/0x106 \[ 5.168071\] ? vm_mmap_pgoff+0xdd/0xeb \[ 5.168074\] ? ksys_mmap_pgoff+0x4c/0x154 \[ 5.168076\] ? \_\_do_sys_mmap+0x12/0x23 \[ 5.168078\] ? \_\_se_sys_mmap+0x5/0xa \[ 5.168079\] ? \_\_x64_sys_mmap+0x20/0x25 \[ 5.168081\] ? do_syscall_64+0x5a/0x86 \[ 5.168083\] ? entry_SYSCALL_64_after_hwframe+0x63/0xcd \[ 5.168086\] \</TASK\>

 

*Listing 14-14: Example OOM stack trace*

 



 

Importantly, the first line indicates the CPU on which the allocation

failed, the PID of the failing process (in this example process ‘oom’ possessing

PID 246), the version of the kernel (6.0.0+) and its build ID (in this instance

\#27).

The header additionally indicates whether the kernel has been tainted,

i.e. modified in some way that stability may be compromised compared to a

vanilla kernel (for instance by loading an out-of-tree kernel module). In the

example given, it has not been.

Finally, we observe the kernel stack trace that lead to the out of memory

killers invocation, with a brief description of the hardware upon which the

fault occurred.

We can observe that the page allocation slow path has been invoked (i.e.

direct reclaim was attempted), in [\_\_alloc_pages_slowpath()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5015) (see section 11.1

for a detailed examination fo this code), which lead to the OOM killer being

invoked via [out_of_memory()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n1107).

 

***14.4.3 Global free page statistics***

Following this information about the current state of memory in the system

is reported, starting with global page counts:-

 

\[ 5.168087\] Mem-Info:

\[ 5.168087\] active_anon:45 inactive_anon:1997113 isolated_anon:0

active_file:301 inactive_file:300 isolated_file:0

unevictable:0 dirty:56 writeback:0

slab_reclaimable:2419 slab_unreclaimable:4196

mapped:21 shmem:80 pagetables:4493 bounce:0

kernel_misc_reclaimable:0

free:25619 free_pcp:62 free_cma:0

 

*Listing 14-15: Example OOM memory info – Global free page statistics*

 

This provides a summary of memory status data, invoked from [show_mem()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/show_mem.c?h=v6.0#n11)

starting with global statistics (determined in [show_free_areas()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n6069)).

All values in this section are expressed in base pages, i.e. the minimum

memory page size. For x86-64 pages are 4 KiB in size each. Global file-

backed counts include both mapped and unmapped page cache entries.

Each of these other than free_pcp utilise either [global_node_page_state()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmstat.h?h=v6.0#n200) or

[global_zone_page_state()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmstat.h?h=v6.0#n179) passing an [enum node_stat_item](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n171) or [enum zone_stat_item](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n152)

parameter respectively to specify the desired counters:-

 

• active_anon – node – [NR_ACTIVE_ANON](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n174) (counter for [LRU_ACTIVE_ANON](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n280)) – Total

number of anonymous pages (i.e. those which are not file-backed) which sit on the active LRU (i.e. which have been recently used and are un-

likely to undergo reclaim in the near future, see section 11.2 for details on LRU lists in general).

• inactive_anon – node – [NR_INACTIVE_ANON](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n173) (counter for [LRU_INACTIVE_ANON](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n279)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n279) –

Total number of anonymous pages which sit on the inactive LRU (i.e.

 



 

which have not been recently used and are thus subject to reclaim in the near future should memory pressure arise).

• isolated_anon – node – [NR_ISOLATED_ANON](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n180) – Total number of anonymous

pages which have been (ostensibly temporarily) isolated from an LRU list in order to have an operation performed on them such as migration,

[madvise()](https://man7.org/linux/man-pages/man2/madvise.2.html)-invoked MADV_PAGEOUT request or hotplug via [folio_isolate_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2254)

or [isolate_lru_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n132)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n132) This and the below isolated_file can be a useful metric to determine whether actions which isolate pages from LRU lists (in turn protecting them from reclaim) might have led to an out of memory condition.

• active_file – node – [NR_ACTIVE_FILE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n176) (counter for [LRU_ACTIVE_FILE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n282)) – To-

tal number of file-backed pages which sit on the active LRU. This ex-cludes all shmem pages (i.e. RAM-backed files located in filesystems such as tmpfs), which are swap-backed, and therefore treated as anonymous memory.

• inactive_file – node – [NR_INACTIVE_FILE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n175) (counter for [LRU_INACTIVE_FILE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n281)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n281) –

Total number of file-backed pages which sit on the inactive LRU, exclud-ing shmem pages.

• isolated_file – node – [NR_ISOLATED_FILE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n181) – Total number of file-backed pages

excluding shmem which have been ostensibly temporarily isolated for the same purposes as described in the description of isolated_anon above, only in this instance are non-shmem file-backed pages.

• unevictable – node – [NR_UNEVICTABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n177) (counter for [LRU_UNEVICTABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n283)) – Total

number of pages placed on an unevictable LRU list (in actual fact the memory is not maintained on a list but rather simply designated un-evictable).

These are pages that have both been marked locked via [mlock()](https://man7.org/linux/man-pages/man2/mlock.2.html) and have subsequently been isolated from either anonymous or file LRUs, which removes them from consideration for reclaim until unlocked, effectively pinning this user memory into RAM.

Excessive locking can result in memory pressure so this is a useful met-ric to determine whether a scenario such as this might have occurred.

• dirty – node – [NR_FILE_DIRTY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n197) – Total number of file-backed pages which

have been marked dirty, i.e. files which have been modified but are awaiting being written back to disk.

The number of dirty pages is rate-limited according to the dirty page tunables, for instance vm.dirty_ratio and vm.dirty_background_ratio (the ratio being that of dirty pages and total pages of dirtyable memory (see **??** for more details on the algorithm) expressed as a percentage (see sec-

tion 14.6 below).

Once the foreground dirty limit has been reached, processes will block on I/O until sufficient writeback has occurred to bring the system below this limit.

When a file page undergoes writeback, it is not considered to be dirty in respect of this statistic, so these statistics are non-overlapping.

 



 

• writeback – node – [NR_WRITEBACK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n198) – Total number of file-backed pages which

are undergoing writeback (see section **??** for details of the writeback mechanism), i.e. which are in the process of being written back to disk. As stated in the description of dirty above, this is mutually exclusive with the dirty statistic.

• slab_reclaimable – node – [NR_SLAB_RECLAIMABLE_B](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n178) – Total number of kernel-

allocated slab pages which can be subject to reclaim by invoking slab ‘shrinkers’ which reduce the size of slab caches to reclaim more memory (see section **??** for more details).

• slab_unreclaimable – node – [NR_SLAB_UNRECLAIMABLE_B](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n179) – Total number of

kernel-allocated slab pages which cannot be subject to reclaim and are thus unreclaimable.

A large value in this field might indicate a kernel issue, for instance a driver which is allocating far too much memory and not providing a means to reclaim it.

• mapped – node – [NR_FILE_MAPPED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n194) – Total number of file-backed (non-shmem)

pages which are mapped as such into at least one set of process page tables (i.e. the same page cache entry mapped by multiple processes will only increment this statistic once).

• shmem – node – [NR_SHMEM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n200) – Total number of shmem pages of memory

mapped. This overlaps with anonymous page statistics as these are in effect anonymous (or rather, swap-backed) pages.

• pagetables – node – [NR_PAGETABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n218) – Total number of pages used to popu-

late page tables which map pages into userland memory (see section 3.1 for more on page tables in general).

• bounce – zone – [NR_BOUNCE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n164) – Total number of block device ‘bounce’ buffer

pages that have been allocated. These are used for devices which cannot access the entire range of memory the CPU is able to, which is enabled via CONFIG_BOUNCE which is turned on by default when CONFIG_HIGHMEM is set, i.e. the system is 32-bit.

Since we focus on 64 bit architectures only in this book (and specifically when examining architecture-dependent features, x86-64), this is out of scope.

• kernel_misc_reclaimable – node – [NR_KERNEL_MISC_RECLAIMABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n211) – Total num-

ber of non-slab kernel pages allocated which are otherwise reclaimable. This does not appear to currently be used.

• free – zone – [NR_FREE_PAGES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n154) – Total number of entirely free and allocatable

pages in the system.

• free_pcp – This value is not derived from either global node or zone

statistics, but rather each CPU’s per-cpu-page (PCP) data, from which free pages are accumulated.

The PCP interface provides a fast per-CPU cache for allocating and free-ing of a small number of pages which improves page allocation perfor-

mance (see section 2.7.3 for a complete description).

 



 

This value therefore is the total number of free PCP pages across all CPUs.

• free_cma – zone – [NR_FREE_CMA_PAGES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n168) – The total number of free CMA

pages, a topic which is outside the scope of this book.

 

***14.4.4 Per-node statistics***

Next, statistics are displayed for each online node:-

 

\[ 5.168090\] Node 0 active_anon:180kB inactive_anon:7988452kB active_file

:1204kB inactive_file:1200kB unevictable:0kB isolated(anon):0kB isolated( file):0kB mapped:84kB dirty:224kB writeback:0kB shmem:320kB shmem_thp: 0 kB shmem_pmdmapped: 0kB anon_thp: 7897088kB writeback_tmp:0kB kernel_stack:1792kB pagetables:17972kB all_unreclaimable? yes

 

*Listing 14-16: Example OOM memory info – Per-node statistics*

 

These largely provide the same data as above (although expressed

in KiB), noting that in the example shown there is only a single node. Examining the additional fields, all of which are derived from

[global_node_page_state() , ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmstat.h?h=v6.0#n200)again invoked from [show_free_areas()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n6069):-

 

• shmem_thp – [NR_SHMEM_THPS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n201) – Kilobytes of memory used for shmem (mapping

files in RAM-backed filesystem such as tmpfs) which are allocated with sufficient physical contiguity that they can be mapped as huge pages by the Transparent Huge Page mechanism (see the chapter on huge pages for more on THP).

• shmem_pmdmapped – [NR_SHMEM_PMDMAPPED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n202) – Kilobytes of memory used for shmem

which are currently mapped at the PMD page table level (i.e. which are actually being used as huge pages).

• anon_thp – [NR_ANON_THPS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n205) – Kilobytes of anonymous (i.e. non-file backed)

memory that is currently mapped as huge pages by the Transparent Huge Page system.

• writeback_tmp – [NR_WRITEBACK_TEMP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n199) – Kilobytes of file-backed memory cur-

rently undergoing writeback from temporary buffers. This is currently

only used by the [FUSE](https://man7.org/linux/man-pages/man4/fuse.4.html) userland file system interface.

• kernel_stack – [NR_KERNEL_STACK_KB](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n214) – Kilobytes of memory utilised

for the stack associated with the kernel portion of processes. Up-

dated in [account_kernel_stack()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n490) in the kernel forking code (in

[exit_task_stack_account()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n508) and [dup_task_struct()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/fork.c?h=v6.0#n962)).

• all_unreclaimable? – If indirect reclaim (via the kswapd kernel thread, see

section 11.4 for more details) has failed to make progress freeing any pages on a node several times in a row, then direct reclaim will be at-tempted which will try to make more drastic steps to free memory (see

section 11.3 for details on how this functions).

 



 

At this stage, the node is considered unreclaimable, and thus in that in-stance this field will be set to yes, otherwise it is set to no.

The value is determined by [pg_data_t-\>kswapd_failures](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n905) (incremented each

time [balance_pgdat()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4146) fails to make progress reclaiming memory) – if it

equal to or greater than [MAX_RECLAIM_RETRIES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n170) (hardcoded to 16) then the node is considered unreclaimable.

 

***14.4.5 Zone-specific statistics***

And then zone-specific statistics similar to what you would observe in

/proc/zoneinfo are displayed for each zone in each online node:-

 

\[ 5.168093\] Node 0 DMA free:15360kB boost:0kB min:124kB low:152kB high:180

kB reserved_highatomic:0KB active_anon:0kB inactive_anon:0kB active_file :0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15992kB managed:15360kB mlocked:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB

\[ 5.168097\] lowmem_reserve\[\]: 0 2959 7938 7938

\[ 5.168099\] Node 0 DMA32 free:44940kB boost:0kB min:25148kB low:31432kB

high:37716kB reserved_highatomic:0KB active_anon:0kB inactive_anon :2984160kB active_file:0kB inactive_file:0kB unevictable:0kB writepending :0kB present:3129204kB managed:3035452kB mlocked:0kB bounce:0kB free_pcp :0kB local_pcp:0kB free_cma:0kB

\[ 5.168102\] lowmem_reserve\[\]: 0 0 4978 4978

\[ 5.168104\] Node 0 Normal free:42176kB boost:0kB min:42304kB low:52880kB

high:63456kB reserved_highatomic:0KB active_anon:180kB inactive_anon :5003724kB active_file:1604kB inactive_file:800kB unevictable:0kB writepending:224kB present:5242880kB managed:5097828kB mlocked:0kB bounce :0kB free_pcp:248kB local_pcp:248kB free_cma:0kB

\[ 5.168107\] lowmem_reserve\[\]: 0 0 0 0

 

*Listing 14-17: Example OOM memory info – Per-zone statistics*

 

Importantly, the watermarks and free pages are shown here for each

zone which gives a clear indication of the condition that lead to the out of

memory condition (for instance, if not a higher order page allocation caused

by fragmentation, then likely the minimum watermark has been violated).

See section 2.4 for a detailed discussion of watermarks, but generally

speaking for each zone, once free memory dips below its low water mark,

indirect reclaim (see section 11.4) is started via a background kernel thread

(and stopped once the high watermark is reached).

When free memory dips below its minimum water mark, direct reclaim

(more drastic, blocking efforts to free memory) is tried (see section 11.3). If

progress cannot be made, the out of memory killer is invoked.

Examining the example watermarks:-

 



 

Table 14-1: Example OOM watermark status (KiB)

Zone Minimum Low High Free DMA 124 152 180 15,360 DMA32 45,060 51,344 37,57,628 44,940 Normal 42,304 52,880 63,456 42,176

 

In the output shown in listing 14-17,each zone’s low memory reserve

statistics are shown, labelled as lowmem_reserve\[\]. These are equivalent to the protection values shown in /proc/zoneinfo, and described in detail in section

2.4.1 in detail.

In the example above, each entry contains 4 values, each of which refers

to the 4 zones contained in the node (note that the final zone, movable, does not have statistics displayed separately for it as it is empty in this example).

Each of the low reserve statistics indicate how many additional pages

must be reserved in order to consider allocations from zones above this zone, for instance DMA requires there to be 2,959 pages or 11,836 KiB re-served memory if allocating from DMA32, and 7,938 pages or 31,752 KiB reserved memory if allocating from Normal, etc.

If we take into account low memory reserve values, and assume that fail-

ing allocation is taken from the normal zone (this is the case unless a GFP flag specifying a different zone is shown in the output, not the case in the example), we end up with the following values:-

 

Table 14-2: Example OOM watermark status with low memory reserve (KiB)

Zone Minimum Low High Free DMA 31,876 31,904 31,932 15,360 DMA32 25,148 31432 37,716 44,940 Normal 42,304 52,880 63,456 42,176

 

Factoring in the low memory reserve, we can observe immediately that

no zone can service the memory request, hence why the out of memory con-dition has arisen as free pages in each case represent less than the minimum watermark and all reclaim has already been attempted.

Note that, if any zone has had a ‘boost’ applied, indicating that page

blocks are especially fragmented, then this value should be added to each

of the watermarks. In the example above there is no boost (see section 2.5 for more details).

Each zone within each node is listed, stating the node number, the zone

name and a number of statistics, as determine by [show_free_areas()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n6069) (all values expressed in base pages):-

 

• free – The number of free pages within the zone.

• boost – The amount of watermark boost which is applied. When page

blocks become fragmented, zone watermarks are increased in order to reduce the chances of this causing an out of memory condition.

This value is set in [boost_watermark()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2711) which is triggered from

[steal_suitable_fallback(). ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2756)See section 2.4 for more details.

 



 

• min – The minimum water mark for this zone.

• low – The low water mark for this zone.

• high – The high water mark for this zone.

• reserved_highatomic – [struct zone-\>nr_reserved_highatomic](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n515) – A certain num-

ber of pages can be reserved exclusively for higher order atomic con-text allocations, as obtaining these otherwise might not be feasible. This field contains the number of pages reserved for this purpose. See sec-

tion 2.4 for more details.

• active_anon – The zone-specific count of of anonymous base pages within

the zone which are on the active LRU, i.e. those which are unlikely

to be reclaimed soon. Determined from [zone_page_state()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmstat.h?h=v6.0#n207)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmstat.h?h=v6.0#n207) using field

[NR_ZONE_ACTIVE_ANON.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n157)

• inactive_anon – The zone-specific count of anonymous base pages within

the zone which are on the inactive LRU, i.e. those which are more likely

to be reclaimed soon. Determined from [zone_page_state()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmstat.h?h=v6.0#n207)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmstat.h?h=v6.0#n207) using field

[NR_ZONE_INACTIVE_ANON .](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n156)

• active_file – The zone-specific count of file-backed base pages within

the zone that are on the active LRU, i.e. those which are more likely

to be reclaimed soon. Determined from [zone_page_state()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmstat.h?h=v6.0#n207)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmstat.h?h=v6.0#n207) using field

[NR_ZONE_ACTIVE_FILE.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n159)

• inactive_file – The zone-specific count of file-backed base pages within

the zone that are on the inactive LRU., i.e. those which are less likely

to be reclaimed soon. Determined from [zone_page_state()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmstat.h?h=v6.0#n207)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmstat.h?h=v6.0#n207) using field

[NR_ZONE_INACTIVE_FILE .](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n158)

• unevictable – The number of pages in the zone which have been

[mlock() ’d, ](https://man7.org/linux/man-pages/man2/mlock.2.html)and are thus not on any LRU and not subject to reclaim at all. If this number is high, then this will add memory pressure due to

the inability to reclaim it. Determined from [zone_page_state()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmstat.h?h=v6.0#n207), using field

[NR_ZONE_UNEVICTABLE.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n160)

• writepending – The number of pages in the zone which are either

dirty pending writeback to a file system which performs it, cur-rently under writeback or awaiting being cleaned. Determined from

[zone_page_state()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmstat.h?h=v6.0#n207), using field [NR_ZONE_WRITE_PENDING](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n161)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n161)

Updated in [folio_account_dirtied()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2552) when dirtied, [folio_account_cleaned()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2584)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2584)

[folio_clear_dirty_for_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2826) when cleaned, and [\_\_folio_start_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2955)

and [\_\_folio_end_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2910) when starting/ending writeback (see section **??** for more on writeback).

• present – [struct zone-\>present_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n515) – The number of present pages within

the zone, i.e. the raw range over which it spans which are backed by physical memory.

• managed – [struct zone-\>managed_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n515) – The number of managed pages

within the zone, i.e. present pages which are available to the buddy al-locator (whether allocated or not).

 



 

• mlocked – The number of resident pages which have been marked as

[mlock() ’d. ](https://man7.org/linux/man-pages/man2/mlock.2.html)This may differ from the unevictable value above as the lock-ing of a page and the placing of it on the unevictable list do not occur at

precisely the same time. Determined from [zone_page_state()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmstat.h?h=v6.0#n207)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmstat.h?h=v6.0#n207) using field

[NR_MLOCK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n162).

• bounce – The number of bounce buffers within the zone. This is highly

unlikely to be relevant to a 64-bit system, see the description of this in

section 14.2 above for more details.

• free_pcp – The number of free Per-CPU-Pages (PCPs) on all CPUs for

this zone. See section 2.7.3 for more on PCPs. This is calculated by sum-

ming the per-CPU [struct zone-\>per_cpu_pageset](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n515) values for each online

CPU in [show_free_areas()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n6069).

• local_pcp – The number of free Per-CPU-Pages (PCPs) on the local CPU

for this zone. See section 2.7.3 for more on PCPs.

• free_cma – Related to linux CMA functionality, which is out of scope for

the book.

 

***14.4.6 Zone buddy page statistics***

After this each node and zone outputs its buddy page statistics, giving details similar to /proc/buddyinfo:-

 

\[ 5.168109\] Node 0 DMA: 0\*4kB 0\*8kB 0\*16kB 0\*32kB 0\*64kB 0\*128kB 0\*256kB

0\*512kB 1\*1024kB (U) 1\*2048kB (M) 3\*4096kB (M) = 15360kB

\[ 5.168117\] Node 0 DMA32: 1\*4kB (M) 4\*8kB (UM) 4\*16kB (UM) 3\*32kB (U) 3\*64

kB (UM) 0\*128kB 1\*256kB (M) 1\*512kB (M) 3\*1024kB (M) 2\*2048kB (UM) 9\*4096 kB (M) = 45188kB

\[ 5.168127\] Node 0 Normal: 340\*4kB (UME) 164\*8kB (UE) 113\*16kB (UME) 76\*32

kB (UME) 53\*64kB (UE) 25\*128kB (UE) 6\*256kB (UME) 3\*512kB (UME) 1\*1024kB (E) 0\*2048kB 6\*4096kB (UM) = 42176kB

\[ 5.168137\] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0

hugepages_size=2048kB

 

*Listing 14-18: Example OOM memory info – Zone buddy page statistics*

 

These list available buddy allocator pages (the underlying physical alloca-

tor in the kernel, see 2.7 for details on this) at different physically contiguous block sizes, each of which are equivalent to a folio in increasing order (the order of a folio is the power-of-2 number of adjacent physical base pages it spans, e.g. an order-1 folio is 1 2 2 = 2 pages in size, order-2 2 = 4 pages in size, order-10 10 2 = 1024 pages in size, etc.

At the end of the report, per-node huge page data is also reported. In the example given (from an x86-64 system), the base page size is 4

KiB, in a system with a single node and 3 zones (DMA, DMA32 and Nor-mal). Each of the folio orders has its size explicitly shown and then a series

 



 

of letters in parentheses indicating which migrate type page blocks are avail-

able at each order.

Migrate types determine what blocks of memory pages should be pre-

ferred to be used for. Memory is subdivided like this in order to avoid mix-

ing of memory that is movable (e.g. user memory which the kernel can move

around as it likes), and that which is not (e.g. kernel memory which cannot

be moved).

When memory is freed back to the buddy allocator, it coalesces adjacent

blocks of memory into higher order folios. If some memory that would oth-

erwise be coalesced is currently allocated, if movable, the kernel could move

it elsewhere to enable the operation to continue and to expand physically

contiguous memory (see the chapter on migration and compaction for more

on this).

However, if a single page of memory is unmovable in the middle of this

block, it is fragmented until that is freed. Thus subdividing into chunks,

known as ‘pageblocks’ (of order [pageblock_order](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pageblock-flags.h?h=v6.0#n36)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pageblock-flags.h?h=v6.0#n36) this is typically order-9 for

x86-64) of the same migrate type is a heuristic means of reducing fragmenta-

tion.

See section 2.5 for a detailed analysis of migrate types. The mapping from migrate type to abbreviation seen here is performed

in [show_migration_types()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n6033) and is as follows:-

 

• U – [MIGRATE_UNMOVABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n43) – Unmovable – Kernel allocations which can neither

be reclaimed in any fashion nor moved.

• M – [MIGRATE_MOVABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n44) – Movable – Userland allocations which can be moved.

• E – [MIGRATE_RECLAIMABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n45) – Movable – Kernel slab allocations that can be

shrunk and thus reclaimed, rendering them in effect movable.

• H – [MIGRATE_HIGHATOMIC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n47) – High atomic – Memory that has been specifically

reserved for high-order atomic memory allocations which, operating in atomic mode, cannot wait to receive their memory.

• C – [MIGRATE_CMA](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n59) – CMA – CMA memory, out of scope for the book.

• I – [MIGRATE_ISOLATE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n62) – Isolated – Isolated (non-allocatable) memory as de-

fined by the CONFIG_MEMORY_ISOLATION feature which is out of scope for the book.

 

If memory of one migrate type is required but the zone lacks memory

of this, it can be taken from another kind. The mechanism for doing so is

rather complicated and heuristic (again, see section 2.5 for more details on

this).

In the worst case, fragmentation will be permitted by splitting up page

blocks, however this is avoided as much as possible (as doing so defeats the

purpose of maintaing this heuristic in the first place), and rather entire page

blocks are preferred to be ‘stolen’ at once, i.e. converted to the required mi-

grate type all at once (the migrate types section 2.5 goes into copious details

on this logic).

Some useful rules of thumb:-

 



 

• Migrate types of H, C and I cannot be ‘stolen’ or taken from at all. They

truly are a finite resource.

• Migrate types at pageblock order or higher are more or less irrelevant as

they can immediately be stolen, so if free memory exists at (for instance on x86-64) order-9 or above then migrate type fragmentation is unlikely to be an issue.

• Equally, migrate types at half-pageblock order (e.g. with pageblock size

order-9, this will be equal to order-4) or higher may also be stolen from.

• Allocations of unmovable or reclaimable memory always go ahead and

steal movable pageblocks regardless.

 

Generally speaking, these values are only really worth evaluating if there

is a significant lack of higher order buddy pages, which might indicate frag-mentation. By examining the distribution of migrate types at each order, it might be possible to discern what kind of allocations might be leading to this fragmentation.

Expanding the buddy statistics from our example report to a table:-

 

Table 14-3: Example OOM free buddy pages

Order/Migrate types

Zone Total Free

0 1 2 3 4 5 6 7 8 9 10

DMA 0 0 0 0 0 0 0 0 1 U 1 M 3 M 15,360 KiB

DMA32 1 M 4 UM 4 UM 3 U 3 UM 0 1 M 1 M 3 M 2 UM 9 M 45,188 KiB Normal 340 UME 164 UE 113 UME 76 UME 53 UE 25 UE 6 UME 3 UME 1 E 0 6 UM 42,176 KiB

 

***14.4.7 Global statistics***

The ‘Show memory’ portion of the output is wrapped up with some global statistics:-

 

\[ 5.168138\] 706 total pagecache pages \[ 5.168138\] 0 pages in swap cache \[ 5.168139\] Free swap = 0kB \[ 5.168139\] Total swap = 0kB \[ 5.168140\] 2097019 pages RAM \[ 5.168141\] 0 pages HighMem/MovableOnly \[ 5.168141\] 59859 pages reserved

 

*Listing 14-19: Example OOM global statistics*

 

Each statistic here is relatively self-explanatory, though it’s important to

note that the ‘reserved’ value is physical memory reserved by the system and thus unavailable for allocation, rather than any other definition of this word within memory management, and equal to sum of the differences of each

zone’s present and managed pages (see section 2.4 for more details on this).

Note that all of the above ‘Show memory’ information can also be ob-

tained via the sysrq-trigger interface specifying the m option, for instance:-

 



 

\$ echo m \| sudo tee /proc/sysrq-trigger \>/dev/null

\$ dmesg

... details as above ...

 

*Listing 14-20: Example of obtaining memory info from* */proc/sysrq-trigger*

 

***14.4.8 Out of memory killer report***

Finally, the decision process of the OOM killer is shown with all running

processes listed:-

 

\[ 5.168142\] \[ pid \] uid tgid total_vm rss pgtables_bytes swapents oom_score_adj

name

\[ 5.168145\] \[ 115\] 0 115 12408 270 90112 0 -250 systemd-

journal

\[ 5.168147\] \[ 130\] 0 130 7476 429 77824 0 -1000 systemd-

udevd

\[ 5.168149\] \[ 135\] 0 135 7312 317 81920 0 0 (udev-

worker)

\[ 5.168150\] \[ 136\] 0 136 7312 317 86016 0 0 (udev-

worker)

\[ 5.168152\] \[ 137\] 0 137 7312 328 77824 0 0 (udev-

worker)

\[ 5.168153\] \[ 138\] 0 138 7312 325 86016 0 0 (udev-

worker)

\[ 5.168154\] \[ 139\] 0 139 7312 328 81920 0 0 (udev-

worker)

\[ 5.168155\] \[ 140\] 0 140 7312 318 65536 0 0 (udev-

worker)

\[ 5.168157\] \[ 141\] 0 141 7312 319 81920 0 0 (udev-

worker)

\[ 5.168158\] \[ 142\] 0 142 7312 329 81920 0 0 (udev-

worker)

\[ 5.168159\] \[ 143\] 0 143 7312 327 77824 0 0 (udev-

worker)

\[ 5.168160\] \[ 144\] 0 144 7312 322 65536 0 0 (udev-

worker)

\[ 5.168161\] \[ 145\] 0 145 7312 321 86016 0 0 (udev-

worker)

\[ 5.168163\] \[ 146\] 0 146 7481 377 90112 0 0 (udev-

worker)

\[ 5.168164\] \[ 147\] 0 147 7312 323 81920 0 0 (udev-

worker)

\[ 5.168165\] \[ 148\] 0 148 7483 355 90112 0 0 (udev-

worker)

\[ 5.168166\] \[ 149\] 0 149 7312 326 81920 0 0 (udev-

worker)

 



 

\[ 5.168167\] \[ 150\] 0 150 7312 325 77824 0 0 (udev-

worker)

\[ 5.168169\] \[ 151\] 0 151 7312 326 86016 0 0 (udev-

worker)

\[ 5.168170\] \[ 152\] 0 152 7312 327 77824 0 0 (udev-

worker)

\[ 5.168171\] \[ 153\] 0 153 7312 327 77824 0 0 (udev-

worker)

\[ 5.168172\] \[ 154\] 0 154 7312 328 81920 0 0 (udev-

worker)

\[ 5.168173\] \[ 155\] 0 155 7345 341 81920 0 0 (udev-

worker)

\[ 5.168174\] \[ 156\] 0 156 7345 329 77824 0 0 (udev-

worker)

\[ 5.168175\] \[ 157\] 0 157 7312 330 77824 0 0 (udev-

worker)

\[ 5.168176\] \[ 158\] 0 158 7312 331 77824 0 0 (udev-

worker)

\[ 5.168178\] \[ 163\] 81 163 2192 131 53248 0 -900 dbus-

daemon

\[ 5.168179\] \[ 166\] 974 166 770 79 40960 0 0 dhcpcd \[ 5.168181\] \[ 167\] 0 167 4315 242 81920 0 0 systemd-

logind

\[ 5.168182\] \[ 169\] 0 169 873 110 40960 0 0 dhcpcd \[ 5.168183\] \[ 170\] 974 170 722 75 40960 0 0 dhcpcd \[ 5.168184\] \[ 171\] 974 171 722 75 40960 0 0 dhcpcd \[ 5.168186\] \[ 183\] 0 183 757 68 40960 0 0 agetty \[ 5.168187\] \[ 184\] 0 184 2125 200 57344 0 0 login \[ 5.168188\] \[ 189\] 1000 189 4894 377 77824 0 100 systemd \[ 5.168189\] \[ 190\] 974 190 767 101 40960 0 0 dhcpcd \[ 5.168191\] \[ 191\] 974 191 767 101 40960 0 0 dhcpcd \[ 5.168192\] \[ 195\] 1000 195 6020 697 77824 0 100 (sd-pam) \[ 5.168193\] \[ 203\] 1000 203 1846 434 49152 0 0 zsh \[ 5.168194\] \[ 246\] 1000 246 33555023 1991355 16007168 0 0 oom \[ 5.168195\] oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),cpuset=/,mems_allowed=0,

global_oom,task_memcg=/user.slice/user-1000.slice/session-c1.scope,task=oom,pid=246,uid =1000

\[ 5.168206\] Out of memory: Killed process 246 (oom) total-vm:134220092kB, anon-rss:7965416kB

, file-rss:4kB, shmem-rss:0kB, UID:1000 pgtables:15632kB oom_score_adj:0

 

*Listing 14-21: Example OOM kill report*

 

This lists all running processes within the system, their OOM score ad-

justment (see section **??** for more on this), which is used to make the OOM killer more or less likely to kill a process and a number of statistics includ-ing each process’s PID (from the kernel’s perspective) as well as its TGID (Thread Group ID).

 



 

This output is generated from [dump_tasks()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n423)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n423) which calls [dump_task()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n381) for

each thread. it’s important to note that, in linux, each individual thread is

implemented as a separate process, only with a shared virtual address space

with all other threads spawned from the original process and threads it origi-

nally spawned.

Therefore, when userland encounters a ’PID’ it is in fact a TGID value.

Therefore, in order to recognise a PID as understand within userland, the

TGID column should be referred to.

The total virtual address space occupied by each thread, its Resident Set

Size (RSS), memory used to store page table data and swap space are shown.

The determining factor of which process is killed is a combination of the lat-

ter three of these values, most notably RSS, moderated by the oom_score_adj

value.

Tthe OOM killer displays any constraints applied to the allocation which

might impact the OOM decision (this is relevant to memory cgroup and

NUMA memory policies, both of which are out of scope for the book).

Finally, a summary is shown detailing the killed process, its statistics (sep-

arating anonymous, non-shmem file-backed and shmem resident memory)

and page table and oom_score_adj values.

See the out of memory killer chapter for a more detailed analysis of how

the kernel handles out of memory conditions.

 

**14.5 procfs memory interfaces**

The [procfs](https://man7.org/linux/man-pages/man5/proc.5.html) file system provides a great deal of memory management-specific

information which can be used to gain insight into the memory status of

processes and the system as a whole.

There are a number of different memory interfaces available within the

kernel:-

 

• /proc/vmstat – A wrapper around all global memory statistical counters,

shown in raw form. This lists everything that is counted in the kernel in

units of base pages. The kernel implementation is in [vmstat_show()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmstat.c?h=v6.0#n1842)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmstat.c?h=v6.0#n1842)

• /proc/meminfo – While vmstat is comprehensive in terms of counters, it

lacks basic information such as total memory, the heuristically deter-mined available memory among other useful calculations. meminfo therefore is the more useful primary source of global memory information, expressed in kilobytes for convenience. The kernel imple-

mentation is in [meminfo_proc_show()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/meminfo.c?h=v6.0#n32)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/meminfo.c?h=v6.0#n32)

• /proc/zoneinfo – Shows per-node statistics, followed by per-zone statis-

tics, page counts, low memory reserve values and watermarks. In addi-

tion, per-zone pagesets (or Per-CPU-Pages/PCPs) (see section 2.7.3) are

shown. The kernel implementation is in [zoneinfo_show()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmstat.c?h=v6.0#n1769)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmstat.c?h=v6.0#n1769)

• /proc/buddyinfo – Provides a count of free pages for each node, zone and

folio order. The kernel implementation is in [frag_show()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmstat.c?h=v6.0#n1489)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmstat.c?h=v6.0#n1489)

 



 

• /proc/pagetypeinfo – (requires elevated permissions) – Outputs the page back

order (see the chapter on physical memory for details on the concept of a page block).

This shows the implied pages per-block, a table showing the count of free pages for each node, zone and migrate type and a table showing how many page blocks are assigned to each migrate type per node and

zone. The kernel implementation is in [pagetypeinfo_show()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmstat.c?h=v6.0#n1629). If the CONFIG_PAGE_OWNER configuration option is specified, then this shows additional data, however discussion of this feature is out of scope for the book.

• /proc/pressure/memory – An interface which forms part of the [PSI](https://kernel.org/doc/html/v6.0/accounting/psi.html) (Pres-

sure Stall Information) framework, which attempts to give an idea of memory pressure.

This outputs rolling-average values indicating the proportion of process time some processes are stalled on memory. The kernel implementation

is at [psi_memory_show()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/psi.c?h=v6.0#n1255)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/psi.c?h=v6.0#n1255)

• /proc/slabinfo – (requires elevated permissions) – Provides output listing

the number of allocated and free slab cache objects of each type (see the slab chapter for more details). The kernel implementation is in

[slab_show()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/slab_common.c?h=v6.0#n1066).

• /proc/vmallocinfo – (requires elevated permissions) – A list of allocated vmal-

loc kernel ranges.If available the function which allocated the memory will be listed, along with range size.

For security reasons, the pointers here will be obfuscated (unless the ker-nel command line option no_hash_pointers has been passed). The kernel

implementation is in [s_show()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n4090)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmalloc.c?h=v6.0#n4090)

• /proc/kcore – Maps the physical memory of the system in the form of an

ELF core file. If a tool has symbols available it can seek into this and de-bug the kernel live accessing memory as required. This is implemented

in [fs/proc/kcore.c](https://elixir.bootlin.com/linux/v6.0/source/fs/proc/kcore.c). This is out of scope for the book, but is used to en-able debuggers like crash and drgn to gain debug information about a live running kernel.

• /proc/kpagecount, /proc/kpageflags – (requires elevated permissions) – These

interfaces, part of the [pagemap](https://kernel.org/doc/html/v6.0/admin-guide/mm/pagemap.html) implementation, allow a user to obtain the number of times a particular physical page of memory is mapped into userspace (i.e. its mapcount) and page table flags, respectively. These values can be obtained by treating these files as arrays of 64-bit integers and seeking to the Page Frame Number index (PFN, or index of a physical page, equal to the physical address divided by system page size).

The kernel implementation is implemented in [kpageflags_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/page.c?h=v6.0#n228) and

[kpagecount_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/page.c?h=v6.0#n45).

• /proc/\$pid/status, /proc/\$pid/stat, /proc/\$pid/statm – Shows process sta-

tus, including memory statistics, most notably VmRSS and VmHWM indicating

 



 

the current and high watermark Resident Set Size usage for the process.

The kernel implementation is in [task_mem()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n31).

• /proc/\$pid/maps, /proc/\$pid/smaps, /proc/\$pid/smaps_rollup – A very useful

and important set of interfaces which walk a process’s page tables and accumulates data about each mapping within that process, listing virtual address ranges, permissions, offset, path and major/minor device num-ber for the file if mapping a file and name of anonymous mapping (if any) if it is not.

The maps interface provides one line per-mapping data, smaps provides accumulated statistics about underlying physical pages in addition to this and smaps_rollup outputs the total virtual address range, aggregating these statistics across the whole process.

The kernel implementation are in [show_map()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n345)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n345) [show_smap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n848) and

[show_smaps_rollup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n876) respectively.

• /proc/\$pid/map_files – A handy list of mapped files implemented as a set

of subdirectories with names in the format from-to (where from and to are the hexadecimal page-aligned addresses spanning the range), each of which is symlinked to the file they map. The kernel implementation is in

[proc_map_files_readdir() .](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/base.c?h=v6.0#n2344)

• /proc/\$pid/numa_map – Shows a list of mappings similar to the maps inter-

face, alongside NUMA details, with Nx=y indicating that node x has y pages mapped, mapmax which shows the maximum number of processes mapping a single page in this range encountered during the scan along side other statistics.

The kernel implementation of this is in [show_numa_map()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n1909)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n1909)

• /proc/\$pid/oom_score, /proc/\$pid/oom_adj, /proc/\$pid/oom_score_adj –

oom_score reads the current Out Of Memory (OOM) killer “score” for a process (indicating how much memory it is occupying, with any ad-justment applied) and oom_score_adj allowing this score to be manually adjusted per-process (oom_adj is deprecated). The oom_score_adj is expressed in units of one tenth of a percent of to-tal RAM and swap, and can range from-1000 (-100%) to 1000 (+100%). oom_score is expressed in the same way, only it is normalised to a range of 0 to 2000.

See Chapter 13 and Sections 13.2.1 and 13.2 for more details on this.

The kernel implementation for oom_score is in [proc_oom_score()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/base.c?h=v6.0#n549). For

oom_score_adj, [oom_score_adj_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/base.c?h=v6.0#n1197) implements reading from this value

and [oom_score_adj_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/base.c?h=v6.0#n1213) implements writing to it.

• /proc/\$pid/pagemap – A series of 64-bit values, one for each page in the

virtual address space. Values from these can be obtained by seeking to the virtual page number multiplied by sizeof(uint64_t) (i.e. 8). This is

documented in [pagemap](https://kernel.org/doc/html/v6.0/admin-guide/mm/pagemap.html)[.](https://kernel.org/doc/html/v6.0/admin-guide/mm/pagemap.html) Each encodes a number of fields indicating whether the page is present in RAM/swapped out/not present at all, the Page Frame Number (PFN) of the underlying physical page if present, along side other values.

The kernel implementation is in [pagemap_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n1627)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n1627)

 



 

• /proc/\$pid/mem – Provides raw access to the entire virtual address space

of a process. This is only accessible by the process itself and processes with sufficient permissions to attach to the process for the purposes of tracing.

This is used by debuggers for instance and can be read from and written to. The offset into the file specifies the virtual address to read from or write to (adjusted by seeking).

This functionality is implemented in the kernel via [mem_rw()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/base.c?h=v6.0#n837)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/base.c?h=v6.0#n837) which

utilises the Get User Pages or GUP functionality (see section 8.1.2 for

more details on this) in [access_remote_vm()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5513).

 

These interfaces are largely self-explanatory well documented in the

[procfs](https://man7.org/linux/man-pages/man5/proc.5.html) man pages for the most part, so we won’t go into enormous depth here on each, however let’s take a moment to examine some in detail to ex-plore the kind of information we can obtain:-

 

***14.5.1 A quick tour: Physical memory***

Let’s examine the state of physical memory using procfs interfaces. The first port of call is /proc/meminfo which provides details on available free memory

as discussed in section 14.1 above:-

 

MemTotal: 4000696 kB MemFree: 302552 kB MemAvailable: 3112644 kB

 

*Listing 14-22: Example* */proc/meminfo* *free memory fields*

These fields are calculated in [meminfo_proc_show()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/meminfo.c?h=v6.0#n32) and provide the foun-

dations of understanding available free memory – the total physical, us-able, memory installed on the system, the amount of free memory and the amount of available memory, if reclaimable memory were freed.

Next, examining /proc/zoneinfo which provides per-node, per-zone details

of memory state in the system (focusing on the most important values):-

 

Node 0, zone DMA

per-node stats

nr_inactive_anon 4014

nr_active_anon 43

nr_inactive_file 7977

nr_active_file 9454

nr_unevictable 0

nr_slab_reclaimable 3308

nr_slab_unreclaimable 3963

...

nr_anon_pages 3977

nr_mapped 6017

nr_file_pages 17511

nr_dirty 30

 



 

nr_writeback 0

nr_writeback_temp 0

nr_shmem 80

...

nr_vmscan_write 0

nr_vmscan_immediate_reclaim 0

nr_dirtied 2947

nr_written 2917

nr_throttled_written 0

nr_kernel_misc_reclaimable 0

nr_foll_pin_acquired 0

nr_foll_pin_released 0

nr_kernel_stack 1376

nr_page_table_pages 196

nr_swapcached 0

 

*Listing 14-23: Example* */proc/zoneinfo* *output – per-node statistics*

 

The first zone in each node also includes per-node statistics. These re-

flect the state of counters found in /proc/vmstat, though in this instance

those values specific to the described node.

Following this are per-zone statistics, for instance example output for the

normal zone (focusing on core statistics):-

 

Node 0, zone Normal

pages free 1236891

boost 0

min 10576

low 13220

high 15864

spanned 1310720

present 1310720

managed 1274457

...

protection: (0, 0, 0, 0)

nr_free_pages 1236891

nr_zone_inactive_anon 4014

nr_zone_active_anon 43

nr_zone_inactive_file 7977

nr_zone_active_file 9454

nr_zone_unevictable 0

nr_zone_write_pending 30

nr_mlock 0

...

pagesets

cpu: 0

count: 1913

high: 3305

batch: 63

 



 

vm stats threshold: 42

cpu: 1

count: 1561

high: 3305

batch: 63

vm stats threshold: 42

cpu: 2

count: 815

high: 3305

batch: 63

vm stats threshold: 42

cpu: 3

count: 1920

high: 3305

batch: 63

vm stats threshold: 42

node_unreclaimable: 0

start_pfn: 1048576

 

*Listing 14-24: Example* */proc/zoneinfo* *output – Normal zone statistics*

All values are expressed in base pages. The counters are broadly self-

explanatory, so we shall focus on the zone-specific fields:-

 

• free – The number of free pages in the zone.

• boost – If pageblocks have become fragmented, an additional ‘boost’ is

applied to each watermark to reduce the chances of this causing more fragmentation. If such a boost exists, it will be shown here (see section

2.4 for a detailed explanation).

• min – The minimum watermark. If free pages dip below this level, allo-

cations trigger direct reclaim (see section 11.3) and block until this suc-ceeds or if it cannot, triggers the Out Of Memory (OOM) killer.

• low – The low watermark. If free pages dip below this level, indirect re-

claim is started across all nodes in the permitted nodelist for the alloca-tion (typically this means all nodes).

• high – The high watermark. If indirect reclaim is active for a node, it

sleeps if all zones are at or above their high watermarks.

• spanned – The total number of physical pages spanned over this zone

within this node.

• present – Of spanned pages, the total number that are not holes (regions

of apparent memory addresses that don’t actually address any memory) or otherwise reserved for hardware.

• managed – The number of pages available to the buddy allocator. This dif-

fers from present due to memory being reserved for various purposes

in [free_area_init_core()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n7737), most typically the majority arising from memmap

reservation, i.e. the array of [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) objects which describe each

physical page(see 2.3 for more details on the memory model as a whole).

 



 

• protection – Indicates the low memory reserve values for this zone in

relation to the zones that sit above it in this node (see section 2.4.1 for more details on this).

 

See section 2.4 for more on zones.

Beneath this there is pageset or Per-CPU-Page (PCP) data for each CPU, a

cache which sits between node free lists and physical allocations. Examining

each field:-

 

• count – The number of base pages currently present in this CPU’s Per-

CPU-Page cache (higher order pages are summed according to the base page count they span).

• high – The maximum number of pages that can be held in this CPU’s

cache before they start to get flushed to free lists.

• batch – The number of pages that are placed in the cache from free lists

when populated or freed back to them when the cache exceeds high.

• vm stats threshold – The page increment to PCP statistics required be-

fore the statistics are actually updated.

 

There are separate page sets for each migrate type and orders up to and

including [PAGE_ALLOC_COSTLY_ORDER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n40) (hardcoded to 3). These statistics aggregate

all orders and migrate types. See section 2.7.3 for more on pagesets.

If we wish to examine the current state of the buddy allocator,

/proc/buddyinfo is a good place to start:-

 

Node 0, zone DMA 0 0 0 0 0 0 0 0 1 1

3

Node 0, zone DMA32 3 1 2 2 1 1 3 3 3 3

737

Node 0, zone Normal 2 1 1 0 3 2 1 1 1 1

1206

 

*Listing 14-25: Example output from* */proc/buddyinfo*

 

This very simply outputs free pages for each node, zone and order avail-

able in free lists (and thus excluding Per-CPU-Pages). Reading from left to

right, we can observe counts for order-0 to order-10. So this example data

translates to:-

 

Table 14-4: Example OOM free buddy pages

Order

Zone

0 1 2 3 4 5 6 7 8 9 10

DMA 0 0 0 0 0 0 0 0 1 1 3 DMA32 3 1 2 2 1 1 3 3 3 3 737 Normal 2 1 1 0 3 2 1 1 1 1 1206

 

See section 2.7 for more details on the buddy allocator. If we have sufficient permissions, we can see a more detailed breakdown

in /proc/pagetypeinfo (spacing adjusted slightly for readability):-

 



 

Page block order: 9

Pages per block: 512

 

Free pages count per migrate type at order 0 1 2 3 4 5 6 7 8 9

10

Node 0, zone DMA, type Unmovable 0 0 0 0 0 0 0 0 1 0

0

Node 0, zone DMA, type Movable 0 0 0 0 0 0 0 0 0 1

3

Node 0, zone DMA, type Reclaimable 0 0 0 0 0 0 0 0 0 0

0

Node 0, zone DMA, type HighAtomic 0 0 0 0 0 0 0 0 0 0

0

Node 0, zone DMA32, type Unmovable 1 0 0 0 0 0 1 1 1 1

0

Node 0, zone DMA32, type Movable 2 1 2 2 1 1 2 2 2 2

737

Node 0, zone DMA32, type Reclaimable 0 0 0 0 0 0 0 0 0 0

0

Node 0, zone DMA32, type HighAtomic 0 0 0 0 0 0 0 0 0 0

0

Node 0, zone Normal, type Unmovable 1 0 0 0 1 0 1 0 0 1

0

Node 0, zone Normal, type Movable 0 1 1 0 1 1 0 1 0 0

1206

Node 0, zone Normal, type Reclaimable 1 0 0 0 1 1 0 0 1 0

0

Node 0, zone Normal, type HighAtomic 0 0 0 0 0 0 0 0 0 0

0

 

Number of blocks type Unmovable Movable Reclaimable HighAtomic Node 0, zone DMA 1 7 0 0 Node 0, zone DMA32 2 1526 0 0 Node 0, zone Normal 22 2530 8 0

 

*Listing 14-26: Example output from* */proc/pagetypeinfo*

 

Here each individual set of free pages is broken down into migrate types,

followed by a list of pageblock migrate type designations spanning both freed and allocated memory (recalling that pageblocks are typically order-9 (i.e. 2 MiB) blocks of contiguous physical memory which are divided into

migrate type to reduce fragmentation (see section 2.5 for more details).

The free page output is determined in [pagetypeinfo_showfree_print()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmstat.c?h=v6.0#n1496) and

page block designation is determined in [pagetypeinfo_showblockcount_print()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmstat.c?h=v6.0#n1553)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmstat.c?h=v6.0#n1553)

 



 

***14.5.2 A quick tour: Virtual memory***

Userland virtual memory, by its nature, is tied to processes as each address

space is entirely distinct from any other. Therefore the most useful means of

examining virtual memory ranges is on a per-process basis.

Other than the data available in /proc/\$pid/status and stat/statm variants,

discussed in section 14.2, the most important per-process interfaces to exam-

ine are /proc/\$pid/maps, /proc/\$pid/smaps and /proc/\$pid/smaps_rollup.

Let’s examine these interfaces for an example program (eliding less use-

ful fields and adjusting whitespace):-

 

Name: mupdf

...

VmPeak: 59488 kB

VmSize: 59488 kB

VmLck: 0 kB

VmPin: 0 kB

VmHWM: 19456 kB

VmRSS: 19412 kB

RssAnon: 10664 kB

RssFile: 7980 kB

RssShmem: 768 kB

 

*Listing 14-27: Example output from* */proc/\$pid/status*

 

This indicates that its current, mapped, virtual address space spans

59,488 KiB (VmSize), and reached a peak of 59,488 KiB (VmPeak). It maps

19,412 KiB (VmRSS) of resident memory, having reached a peak of 19,456 KiB

(VmHWM) so far. Of the mapped memory, 10,664 KiB (RssAnon) is anonymous,

7,980 KiB (RssFile) file-backed (non-shmem) and 768 KiB (RssShmem) shmem

(i.e. RAM-backed files).

Examining the /proc/\$pid/maps of this process (skipping a number of

shared library mappings for space):-

 

556cf266e000-556cf26b1000 r--p 00000000 103:05 4805731 /usr/bin/mupdf 556cf26b1000-556cf288f000 r-xp 00043000 103:05 4805731 /usr/bin/mupdf 556cf288f000-556cf2a0d000 r--p 00221000 103:05 4805731 /usr/bin/mupdf 556cf2a0d000-556cf2a1e000 r--p 0039e000 103:05 4805731 /usr/bin/mupdf 556cf2a1e000-556cf49c1000 rw-p 003af000 103:05 4805731 /usr/bin/mupdf 556cf49c1000-556cf49de000 rw-p 00000000 00:00 0

556cf6163000-556cf6b3e000 rw-p 00000000 00:00 0 \[heap\] 7f3591c3d000-7f3591c3f000 r--p 00000000 103:05 4771151 /usr/lib/libXrender.so

.1.3.0

...

7f3591dcc000-7f3591dcf000 r--p 00000000 103:05 4733534 /usr/lib/libpcre2-8.so

.0.11.2

...

7f3592000000-7f3592026000 r--p 00000000 103:05 4721961 /usr/lib/libc.so.6

...

7f3592240000-7f359224d000 rw-p 00000000 00:00 0

 



 

...

7f359224e000-7f3592250000 r--p 00000000 103:05 4766188 /usr/lib/libXdmcp.so

.6.0.0

...

7f35928e9000-7f35928ea000 r--p 00000000 103:05 4721936 /usr/lib/ld-linux-x86

-64.so.2

...

7ffe32c2e000-7ffe32c4f000 rw-p 00000000 00:00 0 \[stack\] 7ffe32de8000-7ffe32dec000 r--p 00000000 00:00 0 \[vvar\] 7ffe32dec000-7ffe32dee000 r-xp 00000000 00:00 0 \[vdso\] ffffffffff600000-ffffffffff601000 --xp 00000000 00:00 0 \[vsyscall\]

 

*Listing 14-28: Example output from* */proc/\$pid/maps*

 

This shows virtual address ranges for mapped memory, both anonymous

and file-backed, each describing a [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403).

After the address range protection flags are shown – r indicating read,

w indicating write, x indicating executable and p or s indicating whether the mapping is private or shared, respectively.

If the mapping is file-backed, then the next columns shows the offset into

the file, the major:minor device numbers for the device upon which the file is mounted and its inode number.

If a file-backed mapping, then the file path is shown in the fi-

nal column. If anonymous, but named (i.e. possessing a non-NULL

[struct vm_area_struct-\>anon_name](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403)) then this is shown in square brackets.

In addition certain anonymous mappings are given names based on

criteria:-

 

**vDSO** – If the VMA has no associated [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) object referenced in

its [struct vm_area_struct-\>mm](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) field, this indicates that this is a kernel map-

ping, and the only way this can be the case is if this is a [vDSO](https://man7.org/linux/man-pages/man7/VDSO.7.html) mapping, i.e. a virtual Dynamic Shared Object – this is memory shared between userland and the kernel to make certain system calls more performant.

**Heap** – If the mapped range starts at or below [struct mm_struct-\>brk](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) and

ends at or above [struct mm_struct-\>start_brk](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486), then the mapping is des-ignated as the heap.

**Stack** – if the mapped range starts at or below [struct mm_struct-\>start_stack](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)

and ends at or above this value, then it is designated the process’s stack

(as determined by [is_stack()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n240)). This is distinct from mappings which have been designated as user-defined stacks by e.g. MAP_GROWSDOWN but is rather intended to indicate the process’s overall stack.

 

Each VMA’s output is implemented in [show_map_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n272)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n272) which is also used

by /proc/\$pid/smaps.

This provides the basic details about mappings, but /proc/\$pid/smaps pro-

vides per-VMA statistics in addition to this (eliding out of scope huge page and page size fields):-

 



 

556cf266e000-556cf26b1000 r--p 00000000 103:05 4805731 /usr/

bin/mupdf

Size: 268 kB

...

Rss: 268 kB

Pss: 268 kB

Pss_Dirty: 0 kB

Shared_Clean: 0 kB

Shared_Dirty: 0 kB

Private_Clean: 268 kB

Private_Dirty: 0 kB

Referenced: 268 kB

Anonymous: 0 kB

LazyFree: 0 kB

...

Swap: 0 kB

SwapPss: 0 kB

Locked: 0 kB

...

VmFlags: rd mr mw me sd

 

*Listing 14-29: Example* */proc/\$pid/smaps* *output*

 

After showing a line with the same data shown in /proc/\$pid/maps for this

VMA, a number of statistics describing the range follow (each expressed in

kilobytes):-

 

• Size – Shows the size of the virtual mapping, equal to

[struct vm_area_struct-\>vm_end](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403)-[struct vm_area_struct-\>vm_start](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403).

• Rss – Resident Set Size – The amount of memory which is resident, i.e.

present in memory, whether file-backed or anonymous. This constitutes all memory in the range that resolves to a physical page of memory.

• Pss – Proportional Set Size – This is the sum of the memory occupied by

all resident pages of memory, each page divided by the number of times it is mapped into a process.

Therefore, memory which is not shared will be accounted the same as Rss, but each page of shared memory will be divided by the map count. If a file is mapped via MAP_PRIVATE, then the portion of the mapping that has been copied into anonymous memory will be accounted the same as anonymous memory, i.e. not divided by map count, whereas the por-tion of the mapping which maps into the page cache will have each page scaled by each page’s map count.

This can get complicated, as files can be mapped at different off-sets meaning map counts may vary page-per-page, in addition to the MAP_PRIVATE case.

Considering a MAP_PRIVATE mapping spanning 10 pages of 4 KiB each, with half of its pages copied to private anonymous memory and half still

 



 

mapping the shared page cache pages for the underlying file, which has been mapped twice.

The Rss value will be 40 KiB, however Pss will be equal to 5 pages of 4 KiB anonymous memory, summing to 20 KiB, in addition to a further 20 KiB of memory shared between two mappings, summing to 10 KiB for a total of 30 KiB Pss. This value is most useful when considering multiple mappings - by sum-ming the PSS values for each process, the total sum will be equal to all of the mapped memory in the system.

Therefore, PSS can be seen as the amount of resident memory utilised by a VMA, assuming we account shared memory as equally divided be-tween all mappings of that memory.

Note that memory which is due to be migrated and thus has a migration entry assigned to it is considered to have a map count of 1.

PSS values are updated in [smaps_page_accumulate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n414), invoked from

[smaps_account()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n444).

• Pss_Dirty – The Proportional Set Size value for all dirty pages (i.e. mem-

ory which has been changed but not yet written back to disk, if file-backed).

• Shared_Clean – The amount of resident memory which is shared and not

dirty. Determined in [smaps_page_accumulate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n414)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n414)

• Shared_Dirty – The amount of resident memory which is shared and

dirty. Determined in [smaps_page_accumulate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n414)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n414)

• Private_Clean – The amount of resident memory which is private

(i.e. possesses a map count of 1) and not dirty. Determined in

[smaps_page_accumulate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n414). This is only meaningful for MAP_PRIVATE mappings of files. For anony-mous memory, simply reading newly mapped memory will yield a map-ping to the zero page which results in no increase in residential memory usage.

However, reading from a MAP_PRIVATE mapping of a file will result in unmodified memory which does occupy residential memory being Copy-on-Written. As soon as that is written to, it will be accounted as Private_Dirty.

• Private_Dirty – The amount of resident memory which is pri-

vate (i.e. possesses a map count of 1) and dirty. Determined in

[smaps_page_accumulate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n414). Private memory can never be cleaned, as there is no writeback of this memory.

• Referenced – The number of resident memory that has either been deter-

mined to be accessed in the [idle page tracking](https://kernel.org/doc/html/v6.0/admin-guide/mm/idle_page_tracking.html) framework (out of scope

for the book), has the hardware-determined [\_PAGE_ACCESSED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable_types.h?h=v6.0#n46) PTE flag

set checked by [pte_young()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/pgtable.h?h=v6.0#n132) indicating it has been accessed recently, or

is marked referenced (i.e. its [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) has the [PG_referenced](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n102) flag set, indicating that reclaim has determined the page to have been accessed recently (reducing the chance of reclaim).

 



 

If this memory is considered for reclaim, the existence of the sticky PTE bit will guarantee this memory will be marked referenced (see the re-claim chapter for more details on the reclaim algorithm, especially sec-

tion 11.2).

Therefore, this value can be taken to be the sum of all memory which has been recently accessed and thus gives an insight into how likely it is for the range to be reclaimed and how recently it has been used.

This value is calculated in [smaps_account()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n444).

• Anonymous – The amount of anonymous, resident memory, as deter-

mined ultimately through [folio_test_anon()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n656), which checks to see whether

[struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72)-\>mapping has the [PAGE_MAPPING_ANON](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n635) flag set.

This value is calculated in [smaps_account()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n444).

• LazyFree – The total amount of ‘lazy’ freed memory, as determined by it

being anonymous but not swap-backed nor dirty.

This is memory that has been indicated that it should be freed via the

[madvise()](https://man7.org/linux/man-pages/man2/madvise.2.html) system call specifying the MADV_FREE flag. This causes the memory to be prioritised for consideration by reclaim, however if they are written to before reclaim occurs they will no longer be freed.

This value is calculated in [smaps_account()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n444).

• Swap – The amount of memory in the range which is not resident but

rather swapped out.

This is determined in [smaps_pte_entry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n523) except for shmem mappings (e.g. tmpfs) which requires a more complicated calculation as performed in

[shmem_swap_usage()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/shmem.c?h=v6.0#n840) and ultimately [shmem_partial_swap_usage()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/shmem.c?h=v6.0#n808).

• SwapPss – The amount of memory in the range which is swapped out, as a

proportional value using the same algortihm as described above for Pss.

This is determined in [smaps_pte_entry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n523).

• Locked – The Proportional Set Size for all memory which has been

[mlock() ’d ](https://man7.org/linux/man-pages/man2/mlock.2.html)(see section 8.2.1 for more on the use of this feature).

Determined in [smaps_page_accumulate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n414)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n414)

• VmFlags – A list of mnemonics which indicate which of the

[struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) flags have been set as described below.

Determined in [show_smap_vma_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n640).

 

Examining the mapping between VMA flags and VmFlags mnemonics

shown in the VmFlags field (eliding arm64-specific flags):-

 



 

Table 14-5: VmFlags mappings

Mnemonic VMA flag

rd VM_READ

wr VM_WRITE

ex VM_EXEC

sh VM_SHARED

mr VM_MAYREAD

mw VM_MAYWRITE

me VM_MAYEXEC

ms VM_MAYSHARE

gd VM_GROWSDOWN

pf VM_PFNMAP

lo VM_LOCKED

io VM_IO

sr VM_SEQ_READ

rr VM_RAND_READ

dc VM_DONTCOPY

de VM_DONTEXPAND

ac VM_ACCOUNT

nr VM_NORESERVE

ht VM_HUGETLB

sf VM_SYNC

ar VM_ARCH_1

wf VM_WIPEONFORK

dd VM_DONTDUMP

sd VM_SOFTDIRTY

mm VM_MIXEDMAP

hg VM_HUGEPAGE

nh VM_NOHUGEPAGE

mg VM_MERGEABLE

um VM_UFFD_MISSING

uw VM_UFFD_WP

ui VM_UFFD_MINOR

 

See section 4.4.1 for a detailed description of each of these flags.

Each of these are determined and output in [show_smap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n848)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n848) with a large

number of the fields calculated in [smap_gather_stats()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n767), which walks the page

tables of the range using [smaps_pte_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n610) for non-huge mappings which

calls [smaps_pte_entry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n523) and ultimately [smaps_account()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n444).

Since these values are obtained from walking the page tables with the

process address space lock held, they are not subject to the same scalability inaccuracies as other memory counters.

Often the distinction between individual VMA statistics is not important

and all we wish to determine are the overall statistics for the process. There-fore for the convenience linux exposes the /proc/\$pid/smaps_rollup interface

(previously referenced in section 14.2):-

 

556cf266e000-7ffe32dee000 ---p 00000000 00:00 0 \[

rollup\]

Rss: 19916 kB

 



 

Pss: 14553 kB

Pss_Dirty: 11360 kB

Pss_Anon: 10976 kB

Pss_File: 3193 kB

Pss_Shmem: 384 kB

Shared_Clean: 5204 kB

Shared_Dirty: 768 kB

Private_Clean: 2968 kB

Private_Dirty: 10976 kB

Referenced: 19916 kB

Anonymous: 10976 kB

LazyFree: 0 kB

AnonHugePages: 8192 kB

ShmemPmdMapped: 0 kB

FilePmdMapped: 0 kB

Shared_Hugetlb: 0 kB

Private_Hugetlb: 0 kB

Swap: 0 kB

SwapPss: 0 kB

Locked: 0 kB

 

*Listing 14-30: Example* */proc/\$pid/smaps_rollup* *output*

This aggregates all of the /proc/\$pid/smaps values across the process,

less the fields determined in [show_smap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n848) (i.e. KernelPageSize, MMUPageSize,

THPeligible and ProtectionKey). It additionally adds three additional

values – Pss_Anon, Pss_File and Pss_Shmem. The output is generated in

[show_smaps_rollup().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/task_mmu.c?h=v6.0#n876)

The Pss_Anon value indicates the Proportional Set Size (PSS) of anony-

mous memory. This comprises of ordinary anonymous memory which will

be equivalent to the RSS value, as well as file-backed memory which has been

mapped via MAP_PRIVATE but has not yet been written to, which is therefore

anonymous but maps shared page cache data, scaled by the number of times

mapped.

The Pss_File value indicates the aggregate PSS of non-shmem (RAM-backed

memory such as tmpfs) file-backed memory mapped using MAP_SHARED.

Finally Pss_Shmem indicates the aggregate PSS of shmem file-backed memory

mapped using MAP_SHARED. The sum of Pss_Anon, Pss_File and Pss_Shmem is equal

to Pss.

 

***14.5.3 A quick tour: Page table introspection***

It is possible, using the /proc/\$pid/pagemap, /proc/kpageflags and

/proc/kpagecount interfaces, to determine a great deal of data about page ta-

ble entries for virtual memory mappings. This is documented in [pagemap](https://kernel.org/doc/html/v6.0/admin-guide/mm/pagemap.html)[.](https://kernel.org/doc/html/v6.0/admin-guide/mm/pagemap.html)

If we offset into the pagemap using virtual page offset, we can then use the

contents of this entry (which, if present, will contain the PFN) to obtain data

from kpagecount and kpageflags.

Let’s examine a program that interacts with these interfaces:-

 



 

1 **\#include** \<fcntl.h\>

2 **\#include** \<stdint.h\>

3 **\#include** \<stdio.h\>

4 **\#include** \<stdlib.h\>

5 **\#include** \<sys/mman.h\>

6 **\#include** \<unistd.h\>

7 **\#include** \<linux/kernel-page-flags.h\> 8

9 **\#define PAGEMAP_SOFTDIRTY** (1UL \<\< 55)

10 **\#define PAGEMAP_EXCLUSIVE** (1UL \<\< 56) 11 **\#define PAGEMAP_FILE** (1UL \<\< 61) 12 **\#define PAGEMAP_SWAPPED** (1UL \<\< 62) 13 **\#define PAGEMAP_PRESENT** (1UL \<\< 63) 14

15 **\#define PAGEMAP_SWAP_OFFSET_SHIFT** (5) 16 **\#define PAGEMAP_SWAP_TYPE_MASK** ((1UL \<\< 5) - 1) 17 */\* 'Bits 0-54 page frame number (PFN) if present \*/* 18 **\#define PAGEMAP_PFN_MASK** ((1UL \<\< 55) - 1) 19

20 **static uint64_t read_u64**(**const char** \*path, **uint64_t** offset) 21 {

22 **uint64_t** ret;

23 **int** fd = **open**(path, O_RDWR); 24

25 **if** (fd \< 0) {

26 **perror**("**open**"); 27 **exit**(1);

28 }

29

30 **if** (**lseek**(fd, offset, SEEK_SET) != offset) { 31 **perror**("**lseek**"); 32 **exit**(1);

33 }

34

35 **if** (**read**(fd, &ret, **sizeof**(ret)) != **sizeof**(ret)) { 36 **perror**("**read**"); 37 **exit**(1);

38 }

39

40 **return** ret;

41 }

 

*Listing 14-31: Example page table introspection (header)*

 

We start by establishing some constants based on the documented values

within the /proc/\$pid/pagemap fields, and implement a simple function for re-

 



 

trieving a 64-bit value from a specific offset within a file which we will reuse

for each of the interfaces.

 

43 **static uint64_t read_pagemap**(**const void** \*ptr)

44 {

45 **const uint64_t** virt_page_num = (**uint64_t**)ptr / **getpagesize**();

46 */\* There is 'one 64-bit value for each virtual page'. \*/*

47 **const uint64_t** offset = virt_page_num \* **sizeof**(**uint64_t**);

48

49 **return read_u64**("/proc/self/pagemap", offset);

50 }

51

52 **static uint64_t** read_kpageflags(**uint64_t** pfn)

53 {

54 **return read_u64**("/proc/kpageflags", pfn \* **sizeof**(**uint64_t**));

55 }

56

57 **uint64_t** read_mapcount(**uint64_t** pfn)

58 {

59 **return read_u64**("/proc/kpagecount", pfn \* **sizeof**(**uint64_t**));

60 }

 

*Listing 14-32: Example page table introspection (interface readers)*

 

Here we utilise the read_u64() helper function to read from each of the

interfaces at the specified locations.

After this, we implement functions to read through each of these values

and describe the obtained data:-

 

62 **static void describe_swapped**(**uint64_t** pagemap)

63 {

64 */\* Swap type and offset encoded in same location as PFN would be. \*/*

65 **const uint64_t** type = pagemap & **PAGEMAP_SWAP_TYPE_MASK**;

66 **const uint64_t** offset =

67 (pagemap & **PAGEMAP_PFN_MASK**) \>\> **PAGEMAP_SWAP_OFFSET_SHIFT**;

68

69 **printf**("swapped: type=%lu, offset=%lu\n", type, offset);

70 }

71

72 **static void describe_kpageflags**(**uint64_t** pfn)

73 {

74 **uint64_t** kpageflags = **read_kpageflags**(pfn);

75

76 */\**

77 *\* There are a huge number of flags declared in*

78 *\* uapi/include/linux/kernel-page-flags.h, we examine a subset.*

79 *\*/*

80

81 **\#define PRINT_FLAGS**(flag) \\

 



 

82 **if** (kpageflags & (1UL \<\< KPF\_##flag)) \\ 83 **printf**(" \[" \#flag "\]"); 84

85 **PRINT_FLAGS**(ACTIVE); 86 **PRINT_FLAGS**(DIRTY); 87 **PRINT_FLAGS**(LOCKED); 88 **PRINT_FLAGS**(LRU); 89 **PRINT_FLAGS**(MMAP); 90 **PRINT_FLAGS**(NOPAGE); 91 **PRINT_FLAGS**(REFERENCED); 92 **PRINT_FLAGS**(SWAPBACKED); 93 **PRINT_FLAGS**(UPTODATE); 94 **PRINT_FLAGS**(WRITEBACK); 95

96 **\#undef PRINT_FLAGS**

97 }

98

99 **static void describe_addr**(**const void** \*ptr)

100 {

101 **uint64_t** pfn, mapcount; 102 **const uint64_t** pagemap = **read_pagemap**(ptr); 103

104 **printf**("%p: ", ptr); 105

106 **if** (!(pagemap & **PAGEMAP_PRESENT**)) { 107 **if** (pagemap & **PAGEMAP_SWAPPED**) { 108 **describe_swapped**(pagemap); 109 **return**; 110 }

111

112 **printf**("\<not present\>\n"); 113 **return**;

114 }

115

116 **printf**("%s: ", (pagemap & **PAGEMAP_FILE**) ? "file" : "anon"); 117

118 pfn = pagemap & **PAGEMAP_PFN_MASK**; 119 **printf**("pfn=%lu", pfn); 120

121 **if** (pagemap & **PAGEMAP_SOFTDIRTY**) 122 **printf**(" \[SD\]"); 123

124 **if** (pagemap & **PAGEMAP_EXCLUSIVE**) 125 **printf**(" \[EX\]"); 126

127 mapcount = **read_mapcount**(pfn); 128 **printf**(" mapped=%lu", mapcount);

 



 

129

130 **describe_kpageflags**(pfn);

131

132 **printf**("\n");

133 }

 

*Listing 14-33: Example page table introspection (describers)*

 

We observe that if the page is not present, then it might be

swapped, and if not swapped then it simply isn’t present at all, be-

fore extracting various flags and utilising the flags declared in

[include/uapi/linux/kernel-page-flags.h](https://elixir.bootlin.com/linux/v6.0/source/include/uapi/linux/kernel-page-flags.h) (note that there are additional, less sta-

ble, flags available in [include/linux/kernel-page-flags.h](https://elixir.bootlin.com/linux/v6.0/source/include/linux/kernel-page-flags.h)) to obtain [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72)[-](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72)

specific flags.

These flags are sometimes directly page flags, and sometimes a pseudo-

flag determined from data relating to that page. These flag values are pre-

fixed by KPF\_ and specified in [fs/proc/page.c](https://elixir.bootlin.com/linux/v6.0/source/fs/proc/page.c).

Finally, examining an example program which maps anonymous mem-

ory, then a file, then writes to file observing the output at each instance:-

 

135 **int** main(**void**)

136 {

137 **int** fd;

138 **char** \*ptr;

139 **const long** page_size = **sysconf**(**\_SC_PAGESIZE**);

140

141 ptr = **mmap**(**NULL**, page_size, **PROT_READ** \| **PROT_WRITE**, 142 **MAP_ANON** \| **MAP_PRIVATE**, -1, 0); 143 **if** (ptr == **MAP_FAILED**) { 144 **perror**("**mmap**"); 145 **return EXIT_FAILURE**; 146 }

147

148 */\* Won't be present yet. \*/* 149 **describe_addr**(ptr); 150 ptr\[0\] = 'x';

151 */\* Anonymous page description. \*/* 152 **describe_addr**(ptr);

153

154 fd = **open**("test.txt", **O_RDWR**); 155 **if** (fd \< 0) {

156 **perror**("**open**"); 157 **return EXIT_FAILURE**; 158 }

159

160 ptr = **mmap**(**NULL**, page_size, **PROT_READ** \| **PROT_WRITE**, 161 MAP_SHARED, fd, 0); 162 **if** (ptr == **MAP_FAILED**) { 163 **perror**("**mmap**");

 



 

164 **return EXIT_FAILURE**; 165 }

166

167 **close**(fd);

168

169 */\* Won't be present yet. \*/* 170 **describe_addr**(ptr); 171 **printf**("test contents: %s", ptr); 172 */\* Now we have read from it, will be present. \*/* 173 **describe_addr**(ptr); 174 ptr\[0\] = 'x';

175 */\* Now we have updated, should see as dirty. \*/* 176 **describe_addr**(ptr); 177

178 **return EXIT_SUCCESS**; 179 }

 

*Listing 14-34: Example page table introspection (main)*

 

**14.6 Memory tunables**

 

There are a number of VM tunables, located in /proc/sys/vm or accessible via

the [sysctl](https://man7.org/linux/man-pages/man8/sysctl.8.html) CLI specified via vm.\<tunable name\>.

The [procfs](https://man7.org/linux/man-pages/man5/proc.5.html) documentation on these is extensive (see also the [sysctl kernel](https://kernel.org/doc/html/v6.0/admin-guide/sysctl/vm.html)

[documentation), ](https://kernel.org/doc/html/v6.0/admin-guide/sysctl/vm.html)so we will examine a core subset of these in detail:-

 

• admin_reserve_kbytes – [sysctl_admin_reserve_kbytes](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n899) – The amount of mem-

ory which should be reserved for administrators (i.e. those with the

[capability](https://man7.org/linux/man-pages/man7/capabilities.7.html) of CAP_SYS_ADMIN) in [OVERCOMMIT_NEVER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/mman.h?h=v6.0#n14) mode. This defaults to the smaller of 8 MiB, and can never exceed 8 MiB. and 1 rd of initial free

32

pages, as determined in [init_admin_reserve()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n3668).

This is checked in [\_\_vm_enough_memory()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n1022), where if the user does not pos-sess the system administration capability, this is subtracted from the per-mitted allocation size.

In other overcommit modes, this has no effect. See section 4.1 for more details on overcommit modes.

• user_reserve_kbytes – Similar to the sysctl_admin_reserve_kbytes tun-

able, this is designed to customise the behaviour of the system in

[OVERCOMMIT_NEVER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/mman.h?h=v6.0#n14) overcommit mode (see section 4.1 for a detailed exami-nation of how overcommit functions in the kernel).

This value specifies the amount of memory to reserve to prevent any one user from causing the system to grind to a halt.

This value is specified in the [sysctl_user_reserve_kbytes](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n898) global value and

initially set in [init_user_reserve()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n3647) which sets it to the minimum of either

1 rd of initial free pages or 128 MiB.

32

• compact_memory, compact_unevictable_allowed, compaction_proactiveness

– The first, when written to, triggers the [sysctl_compaction_handler()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/compaction.c?h=v6.0#n2752)

 



 

function and the state of the latter two tunables are stored in

[sysctl_compact_unevictable_allowed](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/compaction.c?h=v6.0#n1733) and [sysctl_compaction_proactiveness](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/compaction.c?h=v6.0#n2722) respectively.

Writing to compact_memory will trigger compaction immediately, invoking

[compact_nodes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/compaction.c?h=v6.0#n2706) to compact memory in all online nodes within the sys-tem.

the compact_unevictable_allowed tunable determines whether unevictable memory can be compacted, with it permitted by default for non-realtime kernels.

The compaction_proactiveness tunable determines how proactive com-paction is in compacting memory. When the kcompactd kernel thread is running. This is expressed in a percentage value, defaulting to 20%.

This value impacts compaction via the [should_proactive_compact_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/compaction.c?h=v6.0#n2051)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/compaction.c?h=v6.0#n2051) If it is set to 0%, then no compaction will occur at all. See section **??** for a detailed explanation as to how this impacts compaction – broadly speak-ing the higher this value, the more proactive the kernel is about com-pacting pages.

When the compaction_proactiveness tunable is changed,

[compaction_proactiveness_sysctl_handler()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/compaction.c?h=v6.0#n2724) is invoked, which wakes up the kcompactd kernel process for each node to apply the change. See the compaction chapter for a detailed discussion of compaction as a whole.

• dirty_background_bytes/dirty_background_ratio, dirty_bytes/dirty_ratio –

These values dictate how writeback behaves (see section **??** for a detailed discussion of writeback), i.e. at what point modified data gets written back to disk.

The bytes and ratio versions of each are mutually exclusive – when one is set, the other is zeroed. By default the bytes variants are zero, the ratio values used.

The background versions of these tunables determine at what point the per-node background writeback process starts running, writing back data to disk. If bytes are specified, it is simply the number of bytes of dirty data which can be written back to disk.

If a ratio is specified, the value is expressed as a percentage of dirty memory as a proportion of dirtyable memory, i.e. memory that could be dirtied (comprising existing file pages and free pages, calculated in

[global_dirtyable_memory()).](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n344) The non-background values determine the point at which writing to clean pages will cause the writing process to sleep until sufficient write-back is performed. Again, see section **??** for a detailed discussion of the writeback algorithm for both background and sleep-inducing writeback.

The number of dirty pages is equal to the [NR_FILE_DIRTY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mmzone.h?h=v6.0#n197) statistic (used in

[global_node_page_state() ), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vmstat.h?h=v6.0#n200)i.e. the nr_dirty value shown in /proc/zoneinfo or, across the system, the Dirty value shown in /proc/meminfo.

The state of dirty_background_bytes is stored in the [dirty_background_bytes](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n79)

global value, dirty_background_ratio is stored in [dirty_background_ratio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n73),

 



 

dirty_bytes is stored in [vm_dirty_bytes](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n96) and dirty_ratio is stored in

[vm_dirty_ratio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n90).

Each of these values, when modified, are processed by the

[dirty_background_bytes_handler()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n506), [dirty_background_ratio_handler()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n495),

[dirty_bytes_handler()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n531) and [dirty_ratio_handler()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n517) functions respectively.

• dirty_expire_centisecs, dirty_writeback_centisecs – While the above dirty

tunables determine the memory conditions under which writeback be-gins, it does not determine at what time this begins. It would be rather silly to immediately begin writing back dirtied pages the moment they are altered, as users will often perform multiple changes to a page before they are finished.

Equally, it would be ludicrous for the kernel to have to wait until it reaches the point at which there are so many dirty pages that writeback must occur (to avoid mass data loss), before writing out data back to disk.

Therefore, we add some delay before considering dirtied pages for periodic writeback (dirty_expire_centisecs) and wake up the writeback kernel threads every so often to check to see what needs writing back (dirty_writeback_centisecs). Note that young dirtied memory might still be considered for writeback when dirty counts are high. Both values are expressed in centiseconds, i.e. one hundredths of a sec-ond, therefore a value of 100 centiseconds is equivalent to one second, and a value of 1 centisecond is equivalent to 0.01 seconds. The dirty_expire_centisecs value defaults to 30,000 (i.e. 30 seconds), and dirty_writeback_centisecs defaults to 5,000 (i.e. 5 seconds).

dirty_expire_centisecs is stored in the global [dirty_expire_interval](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n108) value, and dirty_writeback_centisecs is stored in the

global [dirty_writeback_interval](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n101) value, which triggers

[dirty_writeback_centisecs_handler()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2022) when changed. See section **??** for a detailed exploration of the linux writeback algo-rithm.

• drop_caches – This interface permits a user to cause page cache and slab

pages to be dropped. There is no good reason to do this in ordinary operation, however it can be useful to do so for the purposes of testing performance in the presence or absence of in-memory caching of files. Outputting 1 to this interfaces drops all entries in the page cache, 2 drops reclaimable slab pages, and 3 performs both. Adding 4 to these values (i.e. setting bit 2) will cause the operation to only output to the kernel log once.

Note that this does not drop caches for dirtied data at any stage, there-fore it will not cause data loss, but equally, when used for the purposes of performance testing, it is important to ensure dirtied pages have been written back to disk otherwise these will remain in the page cache. We examine this interface and how it functions within the kernel in de-

tail in section 9.9.4. The principle function which invokes this action is

[drop_caches_sysctl_handler()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/drop_caches.c?h=v6.0#n50).

 



 

• lowmem_reserve_ratio – Determines the low memory reserves per-zone for

allocations which are falling through to the zone below, expressed as fractions of memory of zones above that could have been used to service the allocation.

This is something of a tricky topic, so see section 2.4.1 for a detailed de-scription of how this functionality works and how the tunable interacts with it.

• max_map_count – Determines the maximum number of VMAs that a pro-

cess may map at any one time.

This value is specified in the [sysctl_max_map_count](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n897) global value,

and defaults to [DEFAULT_MAX_MAP_COUNT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n196), which is equal to 65,536 less

[MAPCOUNT_ELF_CORE_MARGIN .](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n195) This limit exists as the ELF file format creates a section per VMA in coredumps, and the number of sections is stored as an unsigned short (i.e. a 16-bit value). There are additionally some informational sections added, hence the additional margin.

This value is compared against [struct mm_struct-\>map_count](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) which tracks the number of mapped VMAs for a process address space. This check is performed in a number of places in the kernel, most prominently in

[do_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmap.c?h=v6.0#n1369).

• min_free_kbytes – Specifies the minimum amount of free memory which

must be maintained on the system at all times, which is used to calculate zone minimum watermarks.

This is important, as it is critical to maintain some memory at all times, otherwise the kernel or critical userland processes might not be able to operate correctly resulting in a hung or useless system.

The default value is determined by [calculate_min_free_kbytes()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n8788), which

 

attempts to set this value according to available system memory, calcu-*√* lating this to be equal to 4 *p* where *p* is the amount of memory in kilo-bytes which exceeds the high water mark if each zone. On my machine this yields a 67,584 KiB value.

The minimum watermark for each zone is determined by scaling this value against the proportion of total memory each zone manages.

This is stored in the [min_free_kbytes](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n421) global value. When the tunable

is changed, it triggers [min_free_kbytes_sysctl_handler()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n8827) which triggers

[setup_per_zone_wmarks()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n8747) in turn to update watermarks.

• mmap_min_addr – This specifies the minimum address which can be

mapped in a process. This is important, as if for instance an allocation was permitted at virtual address zero, then null handling would become problematic.

This value is stored in [mmap_min_addr](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/security/min_addr.c?h=v6.0#n8)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/security/min_addr.c?h=v6.0#n8) however when input it is kept

in [dac_mmap_min_addr](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/security/min_addr.c?h=v6.0#n10)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/security/min_addr.c?h=v6.0#n10) If the CONFIG_LSM_MMAP_MIN_ADDR value is set, then this will set a hard floor to what value can be specified here.

The update is performed in [update_mmap_min_addr()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/security/min_addr.c?h=v6.0#n16)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/security/min_addr.c?h=v6.0#n16) invoked from

[mmap_min_addr_handler()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/security/min_addr.c?h=v6.0#n32). On my 64-bit x86-64 system this defaults to 64 KiB.

 



 

Update is only permitted if the user has the CAP_SYS_RAWIO [capability](https://man7.org/linux/man-pages/man7/capabilities.7.html)[.](https://man7.org/linux/man-pages/man7/capabilities.7.html)

• oom_dump_tasks, oom_kill_allocating_task – If the oom_dump_tasks tunable is

set to a non-zero value, then all tasks are dumped on invocation of the out of memory killer, otherwise this output is suppressed (can be useful for truly huge systems). Defaults to 1. If oom_kill_allocating_task is specified, then the task which caused the allocation which triggered the OOM killer is killed instead of the one which is determined to consume the most memory.

This is not usually a very good idea as the task that happens to trigger the OOM is not in way likely to be the one who caused it, but rather an innocent bystander. This of course defaults to 0.

• overcommit_memory, overcommit_kbytes/overcommit_ratio – Specifies the over-

commit mode in overcommit_memory – where 0 indicates [OVERCOMMIT_GUESS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/mman.h?h=v6.0#n12)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/mman.h?h=v6.0#n12) 1

indicates [OVERCOMMIT_ALWAYS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/mman.h?h=v6.0#n13)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/mman.h?h=v6.0#n13) and 2 indicates [OVERCOMMIT_NEVER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/mman.h?h=v6.0#n14)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/mman.h?h=v6.0#n14)

In [OVERCOMMIT_GUESS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/mman.h?h=v6.0#n12) mode, which is the default, allocations are permitted as long as they do not exceed the total amount of installed RAM and swap (specifying MAP_NORESERVE bypasses even this check).

In [OVERCOMMIT_ALWAYS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/mman.h?h=v6.0#n13) mode, there are no checks whatsoever and map-

pings of any valid range are permitted, and in [OVERCOMMIT_NEVER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/mman.h?h=v6.0#n14) mode, accountable committed memory is tracked and compared to the limit. The limit is determined to be total swap plus either overcommit_bytes of memory or overcommit_ratio of all installed RAM, which is expressed as a percentage (defaulting to 50%).

The limit can be observed in /proc/meminfo under CommitLimit, and the total committed count as Committed_AS.

See section 4.1 for a detailed discussion of overcommit.

Stored in the [sysctl_overcommit_memory](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n894), [sysctl_overcommit_kbytes](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n896) and

[sysctl_overcommit_ratio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n895) global values.

• page-cluster – Determines the number of pages which are retrieved from

the swap at one time, measured in consecutive pages within the swap. The actual value specifies a page order, i.e. a power-of-two number of base pages, which for machines with anything but the tiniest amount of memory defaults to 3.

This is stored in the global [page_cluster](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n47) variable.

• panic_on_oom – If set to 0, then the OOM killer performs its usual job of

killing the most egregious memory hog (see the OOM killer chapter for details on how it does this). If set to 1 then it will either panic when memory has been exhausted in the system, or proceed as usual if con-strained by either memory policy or cgroup factors (both out of scope for the book).

Finally, if set to 2, linux will always panic in an out of memory condition. This value of course defaults to 0.

This is stored in the global [sysctl_panic_on_oom](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/oom_kill.c?h=v6.0#n55) variable.

• percpu_pagelist_high_fraction – This determines the fraction of pages

in each zone which can be stored on Per-CPU-Pages (or PCPs), which are caches maintained on each CPU to prevent the need for a lock for

 



 

freeing and allocating pages (see section 2.7.3 for more details on how this mechanism works).

The value itself specifies the denominator of the fraction of pages in each zone which will determine the high value for each PCP, i.e. the maximum number of pages which reside there.

If set to zero, which is its default, the kernel will instead determine this value heuristically based on the low watermark for the zone and the number of CPUs in the system. Otherwise if it is specified, then this value simply divides zone managed pages by the denominator specified in the tunable and divides again by the number of CPUs.

This is stored in the global [percpu_pagelist_high_fraction](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n267) vari-able. The calculation of the high count for PCPs is deter-

mined in [zone_highsize()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n7071)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n7071) When the value is changed, the

[percpu_pagelist_high_fraction_sysctl_handler()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n8945) function is called, which performs sanity checks and ensures the value does not cause undue im-balance.

• stat_interval/stat_refresh – VM statistics are stored in per-PCU caches

in order to avoid the updating of node and zone statistics causing per-formance impact by needing to acquire a lock. The statistics are then flushed back to the global state at a regular interval.

The stat_interval tunable specifies this interval, expressed in seconds. A statistics refresh can be triggered manually by writing to stat_refresh. The stat_interval tunable value is stored in the global

[sysctl_stat_interval](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmstat.c?h=v6.0#n1877) value, converted to kernel jiffies (a measure of time within the kernel).

Invoking a manual statistics refresh causes [vmstat_refresh()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmstat.c?h=v6.0#n1885) to be called.

• swappiness – This value expresses in rather heuristic terms, the relative

cost of swapping memory out vs. dropping pages from the page cache on reclaim.

The value ranges from 0 to 200, with lower values indicating swapping is more expensive, and higher values indicating it is less so, with 100 indi-cating that both are of equal performance cost.

This is a tunable in the true sense of the word, as it rather requires a value to be empirically determined. By default this is set to a value of 60, sensibly indicating that swapping out/in is considerably more expensive than dropping references to the page cache.

This value is stored in the global [vm_swappiness](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n181) variable. It is utilised by

[get_scan_count()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n2738) during reclaim to determine how to decide between the two.

See the chapter on reclaim for a detailed examination of how this im-pacts the algorithm.

• watermark_boost_factor, watermark_scale_factor – When pageblocks have

different migrate types mixed into them, this can cause fragmentation

(see section 2.5 for a detailed explanation of migrate types). In order to counteract the impact of this, a boost factor can be applied to the water-marks in a zone when this kind of mixing has occurred.

 



 

The boost factor determines the boost to be a factor of the high water-mark of that zone, which is multiplied by 10,000, and defaults to 15,000 (meaning that the default boost is 1.5x the high water mark of a zone). The watermark_scale_factor determines the distances between watermarks

in each zone, as determined in [\_\_setup_per_zone_wmarks()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n8677)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n8677) multiplied by 10,000. The default value is 10, which implies a distance between mini-mum, low, and high watermarks as 0.1% of the avaliable memory in the node. The maximum permitted value is 3,000 i.e. 30% of available mem-ory.

The watermark_boost_factor tunable state is stored in the

[watermark_boost_factor](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n423) global, and watermark_scale_factor is stored in

[watermark_scale_factor.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n424)

The boost is applied in [boost_watermark()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2711)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n2711)

See section 2.4 for more details on nodes, zones and watermarks.

• zone_reclaim_mode – This tunable determines whether to attempt reclaim

when a zone drops below the required watermark level for the alloca-tion, rather than the default of simply trying the next available zone. This tunable also determines how to go about reclaim in this situation.

Amusingly, the global value which stores this value is [node_reclaim_mode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n4691),

and can be set to the combinable flags [RECLAIM_ZONE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/mempolicy.h?h=v6.0#n71) (1) to try to reclaim

when a zone runs out of memory, [RECLAIM_WRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/mempolicy.h?h=v6.0#n72) (2) to write out dirty

pages during reclaim and [RECLAIM_UNMAP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/mempolicy.h?h=v6.0#n73) (4) to unmap, i.e. swap out pages during reclaim.

The check for this tunable is performed in [get_page_from_freelist()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4166)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n4166)

where [node_reclaim_enabled()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/swap.h?h=v6.0#n438) determines whether this is enabled at all.

 

**14.7 Sharing memory**

 

The use of virtual memory means linux can map the same physical mem-ory from multiple processes simultaneously. This can be used to explicitly share memory between processes, often used as an efficient means of Inter-Process Communication (IPC).

Memory can be shared in a number of different ways, all fundamentally

functioning in the same way – a file-backed mapping (usually a shmem map-ping, i.e. RAM-backed, see section **??** for more details) which each process has obtained access to simultaneously.

Shared memory can be used for Inter-Process Communication (IPC),

however its important to note that simply having the same memory mapped between two processes isn’t sufficient to establish usable IPC – synchronisa-tion between the sharing processes is still required by some means.

 

***14.7.1 System V shared memory***

The system V shared memory interface is the oldest existing shared memory interface available in linux and provides a lot of tooling around the mecha-nism to permit the construction of robust IPC.

 



 

Examining a simple server/client architecture, which simply establishes a

shared memory mapping and has each write to it:-

 

1 **\#include** \<stdio.h\>

2 **\#include** \<stdlib.h\>

3 **\#include** \<string.h\>

4 **\#include** \<sys/types.h\>

5 **\#include** \<sys/ipc.h\>

6 **\#include** \<sys/shm.h\>

7 **\#include** \<unistd.h\>

8

9 **\#define KEY** (1234)

10 **\#define SIZE** (4096)

11 **\#define NUM_LOOPS** (10)

12

13 **int** main(**void**)

14 {

15 **int** i, shmid;

16 **char** \*shm;

17

18 shmid = **shmget**(**KEY**, **SIZE**, **IPC_CREAT** \| 0666);

19 **if** (shmid \< 0) {

20 **perror**("**shmget**");

21 **return EXIT_FAILURE**;

22 }

23

24 shm = **shmat**(shmid, **NULL**, 0);

25 **if** (shm == (**void** \*)-1) {

26 **perror**("**shmat**");

27 **return EXIT_FAILURE**;

28 }

29

30 memset(shm, 0, **SIZE**);

31

32 **for** (i = 0; i \< **NUM_LOOPS**; i++) {

33 shm\[0\] = 'a' + i;

34 **printf**("server: %s\n", shm);

35 **sleep**(1);

36 }

37

38 **return EXIT_SUCCESS**;

39 }

 

*Listing 14-35: Example System V shared memory server*

 

A key is established using [shmget()](https://man7.org/linux/man-pages/man2/shmget.2.html)[,](https://man7.org/linux/man-pages/man2/shmget.2.html) specifying IPC_CREAT to create a new

shared memory ‘segment’. Specifying IPC_CREAT indicates that the segment

should be created rather than simply accessed. The permissions are set for

this region in the same fashion as those that are specified by [chmod()](https://man7.org/linux/man-pages/man2/chmod.2.html)[.](https://man7.org/linux/man-pages/man2/chmod.2.html)

 



 

A pointer to the region is then obtained via [shmat()](https://man7.org/linux/man-pages/man2/shmat.2.html) which attaches to it,

i.e. mapping it into the process. The second parameter specifies the desired addressed or, as here, NULL to indicate that it doesn’t matter which address this is mapped at and the final specifies flags none of which we require here.

At this point we have created a shared memory mapping which can be

accessed by specifying the same key in the client:-

 

1 **\#include** \<stdio.h\>

2 **\#include** \<stdlib.h\>

3 **\#include** \<sys/types.h\>

4 **\#include** \<sys/ipc.h\>

5 **\#include** \<sys/shm.h\>

6 **\#include** \<unistd.h\>

7

8 **\#define KEY** (1234)

9 **\#define SIZE** (4096)

10 **\#define NUM_LOOPS** (10)

11

12 **int** main(**void**)

13 {

14 **int** i, shmid;

15 **char** \*shm;

16

17 shmid = **shmget**(**KEY**, **SIZE**, 0666); 18 **if** (shmid \< 0) {

19 **perror**("**shmget**"); 20 **return EXIT_FAILURE**; 21 }

22

23 shm = **shmat**(shmid, **NULL**, 0); 24 **if** (shm == (**void** \*)-1) { 25 **perror**("**shmat**"); 26 **return EXIT_FAILURE**; 27 }

28

29 **for** (i = 0; i \< **NUM_LOOPS**; i++) { 30 shm\[1\] = 'a' + i; 31 **printf**("client: %s\n", shm); 32 **sleep**(1); 33 }

34

35 **return EXIT_SUCCESS**; 36 }

 

*Listing 14-36: Example System V shared memory client*

 

This largely reflects the server, only without specifying IPC_CREAT, to in-

dicate that we are not creating the shared memory segment, only accessing it.

 



 

Note that this is a very brief overview of how the mechanism works, and

in a production version it’d be sensible to utilise the semaphores and other

machinery the interface exposes to synchronise access to the shared data.

This approach heavily abstracts the underlying mechanisms, however the

overall approach remains the same as any other shared memory approach,

i.e. a shared file is established which multiple processes map in order to ac-

cess the shared memory.

This is implemented in the kernel specifically via the system call [shmget()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/ipc/shm.c?h=v6.0#n834)

which ultimately invokes [newseg()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/ipc/shm.c?h=v6.0#n689) which uses [shmem_kernel_file_setup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/shmem.c?h=v6.0#n4191) to gen-

erate an unlinked tmpfs file (i.e. one that is present in tmpfs but has no file

entry in any directory) which acts as the shared file.

 

***14.7.2 POSIX shared memory***

[POSIX shared memory](https://man7.org/linux/man-pages/man7/shm_overview.7.html) is an updated means of sharing memory available in

linux, intended essentially to be the successor to the System V method.

Again, many different building blocks required for using shared memory

as an IPC mechanism are provided in addition to simply sharing memory

between processes.

This resembles the system V interface, only utilising a file descriptor

which is [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html)’d into shared processes, and a shmem (i.e. RAM-backed) file

is established at /dev/shm/\<name\> where name is specified in [shm_open()](https://man7.org/linux/man-pages/man3/shm_open.3.html)[:-](https://man7.org/linux/man-pages/man3/shm_open.3.html)

 

1 **\#include** \<fcntl.h\>

2 **\#include** \<stdio.h\>

3 **\#include** \<stdlib.h\>

4 **\#include** \<string.h\>

5 **\#include** \<sys/mman.h\>

6 **\#include** \<sys/shm.h\>

7 **\#include** \<unistd.h\>

8

9 **\#define SHM_NAME** "test"

10 **\#define SIZE** (4096)

11 **\#define NUM_LOOPS** (10)

12

13 **int main**(**void**)

14 {

15 **int** i, fd;

16 **char** \*ptr;

17

18 fd = **shm_open**(**SHM_NAME**, **O_CREAT** \| **O_RDWR**, 0666);

19 **if** (fd \< 0) {

20 **perror**("**shm_open**");

21 **return EXIT_FAILURE**;

22 }

23

24 **if** (**ftruncate**(fd, **SIZE**)) {

25 **perror**("**ftruncate**");

 



 

26 **return EXIT_FAILURE**; 27 }

28

29 ptr = **mmap**(**NULL**, **SIZE**, **PROT_READ** \| **PROT_WRITE**, **MAP_SHARED**, fd, 0); 30 **if** (ptr == **MAP_FAILED**) { 31 **perror**("**mmap**"); 32 **return EXIT_FAILURE**; 33 }

34

35 **memset**(ptr, 0, **SIZE**); 36

37 **for** (i = 0; i \< **NUM_LOOPS**; i++) { 38 ptr\[0\] = 'a' + i; 39 **printf**("server: %s\n", ptr); 40 **sleep**(1); 41 }

42

43 */\* Wait until client is done. \*/* 44 **while** (ptr\[1\] != 'a' + (**NUM_LOOPS**- 1)) { 45 **sleep**(1); 46 }

47

48 **if** (**shm_unlink**(**SHM_NAME**)) { 49 **perror**("**shm_unlink**"); 50 **return EXIT_FAILURE**; 51 }

52

53 **return EXIT_SUCCESS**; 54 }

 

*Listing 14-37: Example POSIX shared memory server*

 

Note that, similar to system V shared memory, we must specify that this

function creates the file, only we use the generic O_CREAT as used in [open()](https://man7.org/linux/man-pages/man2/open.2.html), to indicate that the file should be created if it does not already exist. The permissions of the file are specified in the final parameter.

The size of the shared file is set via [ftruncate()](https://man7.org/linux/man-pages/man2/ftruncate.2.html), and can then be used as

a shared memory mapping. The shared file will stay present in the /dev/shm

directory until it is removed via [shm_unlink()](https://man7.org/linux/man-pages/man3/shm_unlink.3.html)[.](https://man7.org/linux/man-pages/man3/shm_unlink.3.html)

Examining the client:-

 

1 **\#include** \<fcntl.h\>

2 **\#include** \<stdio.h\>

3 **\#include** \<stdlib.h\>

4 **\#include** \<sys/mman.h\>

5 **\#include** \<sys/shm.h\>

6 **\#include** \<unistd.h\>

7

8 **\#define SHM_NAME** "test"

 



 

9 **\#define SIZE** (4096)

10 **\#define NUM_LOOPS** (10)

11

12 **int main**(**void**)

13 {

14 **int** i, fd;

15 **char** \*ptr;

16

17 fd = **shm_open**(**SHM_NAME**, **O_RDWR**, 0666);

18 **if** (fd \< 0) {

19 **perror**("**shm_open**");

20 **return EXIT_FAILURE**;

21 }

22

23 ptr = **mmap**(**NULL**, **SIZE**, **PROT_READ** \| **PROT_WRITE**, **MAP_SHARED**, fd, 0);

24 **if** (ptr == **MAP_FAILED**) {

25 **perror**("**mmap**");

26 **return EXIT_FAILURE**;

27 }

28

29 **for** (i = 0; i \< **NUM_LOOPS**; i++) {

30 ptr\[1\] = 'a' + i;

31 **printf**("client: %s\n", ptr);

32 **sleep**(1);

33 }

34

35 **return EXIT_SUCCESS**;

36 }

 

*Listing 14-38: Example POSIX shared memory client*

 

This largely mirrors the server, only with O_CREAT left unspecified. This

implementation overall is less of an abstraction over the filesystem, rather

more obviously establishing a file which is simply [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html)’d by processes shar-

ing the memory.

The implementation relies upon /dev/shm being mapped as a tmpfs file

system which is required by the standard.

 

***14.7.3 Anonymous shared memory across forked processes***

When a process forks a child process, the child process obtains access to the

memory mapped by the parent on a copy-on-write basis, meaning that no

memory is shared by default.

However, through the use of an anonymous shared mapping via [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html),

memory can easily be shared between parent and child:-

 

1 **\#include** \<stdio.h\>

2 **\#include** \<stdlib.h\>

 



 

3 **\#include** \<unistd.h\>

4 **\#include** \<sys/mman.h\>

5 **\#include** \<sys/wait.h\>

6

7 **\#define NUM_LOOPS** (10)

8

9 **int main**(**void**)

10 {

11 **int** i;

12 **pid_t** pid;

13 **const long** page_size = **sysconf**(**\_SC_PAGESIZE**); 14 **char** \*ptr = **mmap**(**NULL**, page_size, **PROT_READ** \| **PROT_WRITE**, 15 **MAP_ANON** \| **MAP_SHARED**, -1, 0); 16

17 **if** (ptr == **MAP_FAILED**) { 18 **perror**("**mmap**"); 19 **return EXIT_FAILURE**; 20 }

21

22 pid = **fork**();

23 **if** (pid == -1) {

24 **perror**("**fork**"); 25 **return EXIT_FAILURE**; 26 }

27

28 */\* Child. \*/*

29 **if** (pid == 0) {

30 **for** (i = 0; i \< **NUM_LOOPS**; i++) { 31 ptr\[1\] = 'a' + i; 32 **printf**("child: %s\n", ptr); 33 **sleep**(1); 34 }

35

36 **return EXIT_SUCCESS**; 37 }

38

39 */\* Parent. \*/*

40 **for** (i = 0; i \< **NUM_LOOPS**; i++) { 41 ptr\[0\] = 'a' + i; 42 **printf**("parent: %s\n", ptr); 43 **sleep**(1); 44 }

45

46 **if** (**waitpid**(pid, **NULL**, 0) == -1) { 47 **perror**("**waitpid**"); 48 **return EXIT_FAILURE**; 49 }

 



 

50

51 **return EXIT_SUCCESS**;

52 }

 

*Listing 14-39: Example anonymous shared mapping across fork*

 

Here we establish a shared, anonymous mapping using a combination of

MAP_ANON and MAP_SHARED. Note that under the covers this actually creates an

unlinked tmpfs file (i.e. one which exists in tmpfs but has no entry in the file

system, see section 5.0.2 for more details).

Therefore, when we fork, this pointer is shared between the parent and

child processes. This example code iterates through letters, outputting both

in parent and child to demonstrate that the memory is, in fact, shared.

 

***14.7.4 Sharing memory via memfd***

Another means of sharing memory between processes is to generate a memfd,

which generates an unlinked shared tmpfs file much like the shared anony-

mous [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) and system V shared memory approaches shown above, how-

ever permitting further special operations on that file descriptor.

Examining a simple server for this approach:-

 

1 **\#define \_GNU_SOURCE**

2 **\#include** \<**fcntl**.h\>

3 **\#include** \<stdio.h\>

4 **\#include** \<stdlib.h\>

5 **\#include** \<string.h\>

6 **\#include** \<sys/mman.h\>

7 **\#include** \<unistd.h\>

8

9 **\#define NAME** "test"

10 **\#define SIZE** (4096)

11 **\#define NUM_LOOPS** (10)

12

13 **int main**(**void**)

14 {

15 **int** i, fd;

16 pid_t pid;

17 **char** \*ptr;

18

19 fd = **memfd_create**(**NAME**, **MFD_ALLOW_SEALING**);

20 **if** (fd \< 0) {

21 **perror**("**memfd_create**");

22 **return EXIT_FAILURE**;

23 }

24

25 **if** (**ftruncate**(fd, **SIZE**)) {

26 **perror**("**ftruncate**");

 



 

27 **return EXIT_FAILURE**; 28 }

29

30 */\* Do not permit the size to change henceforth. \*/* 31 **if** (**fcntl**(fd, **F_ADD_SEALS**, 32 F_SEAL_SHRINK \| **F_SEAL_GROW** \| **F_SEAL_SEAL**) \< 0) { 33 **perror**("**fcntl**"); 34 **return EXIT_FAILURE**; 35 }

36

37 ptr = **mmap**(**NULL**, **SIZE**, **PROT_READ** \| **PROT_WRITE**, **MAP_SHARED**, fd, 0); 38 **if** (ptr == **MAP_FAILED**) { 39 **perror**("**mmap**"); 40 **return EXIT_FAILURE**; 41 }

42

43 **memset**(ptr, 0, **SIZE**); 44

45 pid = **getpid**();

46 **printf**("Running at /proc/%d/fd/%d\n", pid, fd); 47

48 */\* Wait for client... \*/* 49 **while** (ptr\[1\] \< 'a') { 50 **sleep**(1); 51 }

52

53 **for** (i = 0; i \< **NUM_LOOPS**; i++) { 54 ptr\[0\] = 'a' + i; 55 **printf**("server: %s\n", ptr); 56 **sleep**(1); 57 }

58

59 **return EXIT_SUCCESS**; 60 }

 

*Listing 14-40: Example memfd shared mapping server*

 

This establishes a file descriptor via [memfd_create()](https://man7.org/linux/man-pages/man2/memfd_create.2.html), specifying

MFD_ALLOW_SEALING to permit the sealing of the file descriptor, which allows for the limiting of operations which can be performed upon it.

We then establish the size of the shared RAM-backed memory file via

[ftruncate()](https://man7.org/linux/man-pages/man2/ftruncate.2.html), before using [fcntl()](https://man7.org/linux/man-pages/man2/fcntl.2.html) to specify F_SEAL_GROW which is a seal that disallows the growth in size of the shared file and F_SEAL_SEAL which disallows the client from adjust seals further.

Finally we are able to [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html) the file descriptor before outputting the lo-

cation of the file descriptor entry in the process’s procfs fd directory. This is a simplified example for illustration’s sake, in reality you’d transmit the file descriptor using another IPC method such as a UNIX socket.

 



 

Finally we can pass this path to the client:-

 

1 **\#include** \<**fcntl**.h\>

2 **\#include** \<stdio.h\>

3 **\#include** \<stdlib.h\>

4 **\#include** \<sys/mman.h\>

5 **\#include** \<unistd.h\>

6

7 **\#define SIZE** (4096)

8 **\#define NUM_LOOPS** (10)

9

10 **int main**(**int** argc, **char** \*\*argv)

11 {

12 **int** i, fd;

13 **char** \*ptr;

14

15 **if** (argc \< 2) {

16 fprintf(stderr, "usage: %s \[path to fd\]\n", argv\[0\]);

17 **return EXIT_FAILURE**;

18 }

19

20 fd = open(argv\[1\], **O_RDWR**);

21 **if** (fd == -1) {

22 **perror**("open");

23 **return EXIT_FAILURE**;

24 }

25

26 ptr = **mmap**(**NULL**, **SIZE**, **PROT_READ** \| **PROT_WRITE**, **MAP_SHARED**, fd, 0);

27 **if** (ptr == **MAP_FAILED**) {

28 **perror**("**mmap**");

29 **return EXIT_FAILURE**;

30 }

31

32 **close**(fd);

33

34 **for** (i = 0; i \< **NUM_LOOPS**; i++) {

35 ptr\[1\] = 'a' + i;

36 **printf**("client: %s\n", ptr);

37 **sleep**(1);

38 }

39

40 **return EXIT_SUCCESS**;

41 }

 

*Listing 14-41: Example memfd shared mapping client*

 

This simply maps the file descriptor and accesses it as it would any file,

modifying data in the mapping so we can observe both server and client up-

dating data.

 
