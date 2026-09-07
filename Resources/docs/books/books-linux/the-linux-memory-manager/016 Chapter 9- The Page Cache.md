

**9**



**T H E P A G E C A C H E**



By default all file accesses in Linux are mediated by a

transparent cache that sits between userspace and the

underlying disk known as the page cache. This signifi-

cantly boosts performance when reading from/writing

to files as accessing memory is far faster than accessing

a disk. In this chapter we will examine how this func-

tions in detail.

Accessing data stored on permanent storage is significantly slower than

accessing it in memory (except, perhaps, in specific memory-like storage sys-

tems or others this book has yet to anticipate), ranging from greater than 4

times slower when accessing data on an SSD to greater than 80 times slower

when accessing data on a traditional hard drive.

It is therefore sensible to cache this data and hold on to it as long as pos-

sible. This is known as the ‘page cache’, and all file access other than that

specifically intended to bypass it (for instance direct I/O or direct access

(DAX), however both are out of the scope of this book) retrieves and places

data into this cache rather than accessing it directly.

This also simplifies the kernel’s handling of files—any action that would

read data from or write data to disk needs to use a buffer in which to main-

tain this data—the page cache provides this buffer.




Reading from a file therefore becomes a matter of looking it up in the

page cache and, if not present, performing the required I/O to put it there while the requesting process sleeps.

See Sections 9.3 and 9.4 below for details of how we read data from the

page cache via the [read()](https://man7.org/linux/man-pages/man2/read.2.html) and memory-mapped page faults respectively.

Writing to files is rather more complicated, however hardware support

in the Memory Management Unit (MMU) makes life easier—this allows us to map pages read-only, generating a page fault when written to (see Section

6.9), which we can use to notify the file system that a file is about to be writ-ten in a process termed dirty tracking.

We refer to this process as ‘dirty tracking’ as a page which has had data

modified is termed dirty (see Section 10.1 for more on dirty tracking in gen-

eral and Section 10.12 for more on page fault dirty tracking).

This ‘dirty’ data is synchronised to disk in a process known as writeback

which can be triggered directly (e.g. via [fsync()](https://man7.org/linux/man-pages/man2/fsync.2.html)[,](https://man7.org/linux/man-pages/man2/fsync.2.html) [msync()](https://man7.org/linux/man-pages/man2/msync.2.html) or [munmap()](https://man7.org/linux/man-pages/man2/munmap.2.html)[)](https://man7.org/linux/man-pages/man2/munmap.2.html) or indi-rectly as a kernel background task which periodically writes data back to disk according to system configuration (we will examine how this is performed later). We will examine the details of this in the dedicated writeback chapter.

Once the data is synchronised to disk, it is mapped read-only once again

and is therefore termed clean as this point. This is performed by utilising the

reverse mapping (see Chapter 7) to look up what maps the memory pages and then updating all of the mappings.



**N O T E** RAM-backed file systems such as *tmpfs* or abstract file systems like *hugetlbfs*, whose

entries in the page cache constitute the entirety of their state, of course do not require dirty tracking. Theoretically, due to the flexibility of the VFS a file system which ac-tually writes to a permanent medium could eschew dirty tracking as a mechanism for writeback tracking, however it wouldn’t be very sensible to do so.



We have briefly touched upon writeback here, however as it is such a

large topic, we defer discussion of it to the dedicated chapter on the subject.

There are a number of questions that immediately spring to mind re-

garding the page cache – where is it stored? How is it accounted for? How is it accessed and updated?

We will find answers for each of these, however to provide meaningful

answers, we must first step back and examine the Virtual File System (VFS) which provides the generalised kernel file abstraction.



**9.1 The Virtual File System (VFS)**



The kernel supports a huge variety of different file systems by abstracting them through an interface termed the Virtual File System (VFS). Understand-ing how this operates is key to understanding how the page cache operates.

Discussion of the VFS and file systems as a whole is a broad topic, so we

will provide a brief overview of the fundamentals before focusing upon the specifics of the page cache.

The key entity associated with any file in a Linux file system is an inode.

This is an object containing the metadata associated with a file (noting that







directories are considered special kinds of files in Linux) and is described by

the [struct inode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593) kernel data type.



**N O T E** There is debate as to the meaning of the ‘i’, but it is generally accepted to be an abbre-

viation of ‘index’.



Every file and directory is described by an inode, each indexed by an in-

ode number (you can examine these by running ls -i in a shell) maintained in

[struct inode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593)-\>i_ino.

Userland processes typically don’t interact with inodes directly, but

rather with a file descriptor (fd) obtained by [open()](https://man7.org/linux/man-pages/man2/open.2.html)[ing](https://man7.org/linux/man-pages/man2/open.2.html) a file. Each of a pro-

cess’s open files is tracked by the kernel in a [struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) object, which refer-

ences the opened inode via their f_inode field, the current offset within the

file via f_pos, the mode in which the file is opened via f_mode, file path and

other metadata.



**N O T E** Of course the [*open()*](https://man7.org/linux/man-pages/man2/open.2.html) process might be abstracted by something like [*fopen()*](https://man7.org/linux/man-pages/man2/fopen.2.html) or another

library function, underlying it however is the same *open* system call.



As a result, multiple [struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) objects may existing referencing the

same underlying file, each representing a mapping of that file.

Each object within the page cache is uniquely described by a

[struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) object, to which each file-backed [struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) (and

equally [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) refers in their mapping field, as well as [struct inode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593) objects

via their i_mapping field and [struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) objects via their f_mapping fields.



**N O T E** From the perspective of the memory management subsystem, the

[*struct address_space*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) object is the most important metadata for a file or other

cachable entity – it represents an entry in the page cache itself.



Each instance of a mounted filesystem has its core metadata described

by a super block object, [struct super_block](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n1451)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n1451) under which all inodes are main-

tained in the s_inodes linked list.

Each of these objects have customised functions associated with them

which permits a file system to provide its own custom functionality:



• [struct inode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593)-\>i_op specifies the functions the file system provides for

inode operations in an [struct inode_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2137) object. This is typically set when a new inode is first initialised.

• [struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940)-\>f_op specifies the functions the file system provides for file

operations in an [struct file_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2093) object. This is obtained from

each inode’s [struct inode-\>i_fop](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593) field on file open in [do_dentry_open()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/open.c?h=v6.0#n826). The i_fop field is typically set on inode or super block initialisation.

• [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)-\>a_ops specifies the functions the file system pro-

vides for address space operations in a [struct address_space_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n356)

object. This, like [struct inode-\>i_op](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593), is typically set on inode initialisa-tion.







• [struct super_block-\>s_op](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n1451) specifies the functions the file system provides

for super block operations in a [struct super_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2222) object. This is set on super block initialisation.

• [struct vm_area_struct-\>vm_ops](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) specifies the functions the file sys-

tem provides for VMA operations when the region described by the VMA is memory-mapped. These callbacks are wrapped in a

[struct vm_operations_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n539) type.

This is set when the [struct file_operations-\>mmap](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2093) callback is invoked when the VMA is first mapped.



We will examine the operations relevant to the page cache in detail. We

examining the relationships between VFS objects as a whole in Figure 9-1.



[struct task_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)

mm [super_blocks](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/super.c?h=v6.0#n44)

files mmap



[struct files_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fdtable.h?h=v6.0#n49) [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) [struct super_block](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n1451)



fdt vm_file s_inodes



If mapped



[struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) [struct inode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593)

[struct fdtable](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fdtable.h?h=v6.0#n27)

f_inode i_sb

fd f_mapping i_mapping



[struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)

host

i_pages



[struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree//include/linux/mm_types.h?h=v6.0#n72)

mapping

index = 0



*..* *.*

[struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree//include/linux/mm_types.h?h=v6.0#n72)



mapping

index = last page



*Figure 9-1: Core Virtual File System (VFS) Objects*







Underlying it all is the core [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) object, which defines

a mappable page cache entry, i.e. an object which can exist within the page

cache, typically a file.

Where does the [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) ‘mapping’ originate from? It points

to the [struct inode-\>i_data](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593) field, set in [inode_init_always()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/inode.c?h=v6.0#n156) once initialisation

of the inode and mapping object are complete, invoked via [alloc_inode()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/inode.c?h=v6.0#n254),

which is called by file systems when establishing inodes.



**9.2 A Brief Digression: eXtensible Arrays (xarrays)**

A fundamental data structure used within the page cache is the [xarray](https://kernel.org/doc/html/v6.0/core-api/xarray.html) (eX-

tensible array), and as such is worth examining in detail. The intent of the

xarray is to implement a data structure which possesses the following prop-

erties:



• Maps system word size indices to pointer or numerical values while re-

maining space and cache efficient when traversing adjacent entries. Ac-cessing memory immediately before or after an address is vastly easier on a modern CPU’s caches than accessing arbitrary pointers such as in a doubly-linked list.

• Expands and contracts efficiently when new elements are added or re-

moved.

• Perform lockless reads via the [RCU](https://kernel.org/doc/html/v6.0/RCU/rcu.html) mechanism.

• Automatically performs locking on write operations which require it.

• Is able to map a range of keys to a single value.

• Allows elements to be assigned a ‘mark’ which can then be separately

and efficiently iterated over to enable fast categorisation of elements.



**N O T E** Read-Create-Update [(RCU)](https://kernel.org/doc/html/v6.0/RCU/rcu.html) is a locking mechanism which permits users to read data

without having to acquire a lock or perform a memory fence/atomic operation. It

does this by deferring writes to a ‘grace period’ during which there can be no reads.

Using the [RCU](https://kernel.org/doc/html/v6.0/RCU/rcu.html) can significantly improve performance for read-mostly data struc-

tures.



Considering alternatives – A dynamic array is not at all space efficient for

arbitrary keys, a hash is but has poor cache performance as does a red/black

tree, a B-tree needs to store key/value pairs so is not space efficient and the

existing kernel radix tree implementation had poor worst-case space and

time efficiency (an unfortunate index could result in significantly inflated

tree depth).

An xarray can contain two kinds of data – pointers (which must be 4

byte-aligned, we will examine why shortly) and signed, positive numeric values

which can fit inside a pointer (i.e. numbers from zero to [LONG_MAX](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/vdso/limits.h?h=v6.0#n11) inclusive).

An xarray is represented by a lightweight [struct xarray](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n296) object (the funda-

mental user of this type in the page cache is [struct address_space-\>i_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)),

shown in Listing 9-1.







280 */\*\**

281 *\* struct xarray - The anchor of the XArray.* 282 *\* @xa_lock: Lock that protects the contents of the XArray.* 283 *\**

284 *\* To use the xarray, define it statically or embed it in your data structure.*

285 *\* It is a very small data structure, so it does not usually make sense to*

286 *\* allocate it separately and keep a pointer to it in your data structure.*

287 *\**

288 *\* You may use the xa_lock to protect your own data structures as well.* 289 *\*/*

290 */\**

291 *\* If all of the entries in the array are NULL, @xa_head is a NULL pointer.*

292 *\* If the only non-NULL entry in the array is at index 0, @xa_head is that*

293 *\* entry. If any other entry in the array is non-NULL, @xa_head points* 294 *\* to an @xa_node.*

295 *\*/*

296 **struct xarray** {

297 **spinlock_t** xa_lock; 298 */\* private: The rest of the data structure is not to be used directly. \*/* 299 **gfp_t** xa_flags; 300 **void** \_\_rcu \* xa_head; 301 };



*Listing 9-1:* include/linux/xarray.h: [*struct xarray*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n296)



This consists of a spin lock (xa_lock) for operations which cannot be per-

formed under [RCU](https://kernel.org/doc/html/v6.0/RCU/rcu.html) alone, flags (xa_flags) where xarray flags can be speci-fied and the head of the xarray tree xa_head. The latter two fields being pri-vate and not intended for use outside of the xarray code.

We can see what a newly allocated xarray object looks like by examining

[XARRAY_INIT(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n303)shown in Listing 9-2.



303 **\#define XARRAY_INIT**(name, flags) { \\ 304 .xa_lock = **\_\_SPIN_LOCK_UNLOCKED**(name.xa_lock), \\ 305 .xa_flags = flags, \\ 306 .xa_head = **NULL**, \\ 307 }



*Listing 9-2:* include/linux/xarray.h: [*XARRAY_INIT()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n303)



As per the comment in listing 9-1, a NULL entry indicates that the array is

entirely empty and if the array consists of only one entry at index 0, it will be contained in xa_head.

What values can be elements in an xarray? This is described in the com-

ment for [BITS_PER_XA_VALUE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n45)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n45) shown in Listing 9-3.



23 */\**

24 *\* The bottom two bits of the entry determine how the XArray interprets* 25 *\* the contents:*







26 *\**

27 *\* 00: Pointer entry*

28 *\* 10: Internal entry*

29 *\* x1: Value entry or tagged pointer*

30 *\**

31 *\* Attempting to store internal entries in the XArray is a bug.*

32 *\**

33 *\* Most internal entries are pointers to the next node in the tree.*

34 *\* The following internal entries have a special meaning:*

35 *\**

36 *\* 0-62: Sibling entries*

37 *\* 256: Retry entry*

38 *\* 257: Zero entry*

39 *\**

40 *\* Errors are also represented as internal entries, but use the negative*

41 *\* space (-4094 to -2). They're never stored in the slots array; only*

42 *\* returned by the normal API.*

43 *\*/*

44

45 **\#define BITS_PER_XA_VALUE** (**BITS_PER_LONG**- 1)



*Listing 9-3:* include/linux/xarray.h: [*BITS_PER_XA_VALUE()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n45)



This explains why pointers referenced by an xarray must be 4-byte

aligned – to accommodate for these identifiers in the lower two bits for

pointer types.

This also explains why integer values stored within an xarray must be

a positive value of [LONG_MAX](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/vdso/limits.h?h=v6.0#n11) or less – we give up a bit for these value to mark

them as such.

A user of the xarray API should not encounter internal entries unless

a bug arises, so need only concern themselves with whether the entry is a

value or not via [xa_is_value()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n79)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n79) shown in Listing 9-4.



72 */\*\**

73 *\* xa_is_value() - Determine if an entry is a value.*

74 *\* @entry: XArray entry.*

75 *\**

76 *\* Context: Any context.*

77 *\* Return: True if the entry is a value, false if it is a pointer.*

78 *\*/*

79 **static inline bool xa_is_value**(**const void** \*entry)

80 {

81 **return** (**unsigned long**)entry & 1;

82 }



*Listing 9-4:* include/linux/xarray.h: [*xa_is_value()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n79)



We can then extract a value entry via [xa_to_value()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n67)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n67) shown in Listing 9-5.



60 */\*\**







61 *\* xa_to_value() - Get value stored in an XArray entry.* 62 *\* @entry: XArray entry.*

63 *\**

64 *\* Context: Any context.*

65 *\* Return: The value stored in the XArray entry.* 66 *\*/*

67 **static inline unsigned long xa_to_value**(**const void** \*entry) 68 {

69 **return** (**unsigned long**)entry \>\> 1; 70 }



*Listing 9-5:* include/linux/xarray.h: [*xa_to_value()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n67)



And generate it in the first place with [xa_mk_value()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n54)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n54) shown in Listing 9-6.



47 */\*\**

48 *\* xa_mk_value() - Create an XArray entry from an integer.* 49 *\* @v: Value to store in XArray.* 50 *\**

51 *\* Context: Any context.*

52 *\* Return: An entry suitable for storing in the XArray.* 53 *\*/*

54 **static inline void** \***xa_mk_value**(**unsigned long** v) 55 {

56 WARN_ON((**long**)v \< 0); 57 **return** (**void** \*)((v \<\< 1) \| 1); 58 }



*Listing 9-6:* include/linux/xarray.h: [*xa_mk_value()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n54)



However, of course the internal xarray implementation must refer-

ence internal elements. We can determine whether an entry is internal via

[xa_is_internal(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n169)shown in Listing 9-7.



162 */\**

163 *\* xa_is_internal() - Is the entry an internal entry?* 164 *\* @entry: XArray entry.*

165 *\**

166 *\* Context: Any context.*

167 *\* Return: %true if the entry is an internal entry.* 168 *\*/*

169 **static inline bool xa_is_internal**(**const void** \*entry) 170 {

171 **return** ((**unsigned long**)entry & 3) == 2; 172 }



*Listing 9-7:* include/linux/xarray.h: [*xa_is_internal()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n169)



And extract it via [xa_to_internal()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n157)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n157) shown in Listing 9-8.



150 */\**







151 *\* xa_to_internal() - Extract the value from an internal entry.* 152 *\* @entry: XArray entry.*

153 *\**

154 *\* Context: Any context.*

155 *\* Return: The value which was stored in the internal entry.* 156 *\*/*

157 **static inline unsigned long xa_to_internal**(**const void** \*entry) 158 {

159 **return** (**unsigned long**)entry \>\> 2; 160 }



*Listing 9-8:* include/linux/xarray.h: [*xa_to_internal()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n157)



Finally, these values can be created via [xa_mk_internal()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n145)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n145) shown in Listing

9-9.



132 */\**

133 *\* xa_mk_internal() - Create an internal entry.* 134 *\* @v: Value to turn into an internal entry.* 135 *\**

136 *\* Internal entries are used for a number of purposes. Entries 0-255 are* 137 *\* used for sibling entries (only 0-62 are used by the current code). 256*

138 *\* is used for the retry entry. 257 is used for the reserved / zero entry.*

139 *\* Negative internal entries are used to represent errnos. Node pointers* 140 *\* are also tagged as internal entries in some situations.* 141 *\**

142 *\* Context: Any context.*

143 *\* Return: An XArray internal entry corresponding to this value.* 144 *\*/*

145 **static inline void** \***xa_mk_internal**(**unsigned long** v) 146 {

147 **return** (**void** \*)((v \<\< 2) \| 2); 148 }



*Listing 9-9:* include/linux/xarray.h: [*xa_mk_internal()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n145)



As kernel pointers won’t sensibly be placed in the first or last 4 KiB of

virtual address space, we can use these to store special values.

We utilise the space in the uppermost portion of the virtual address

space to be able to store errors – these are encoded as negative integer val-

ues, up to a maximum of-4095 (i.e.[-MAX_ERRNO](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/err.h?h=v6.0#n18)).

This way, errors can be passed back to callers by encoding a negative er-

ror value is an internal entry. Users can check this via [xa_is_err()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n201), shown in

Listing 9-10.



190 */\*\**

191 *\* xa_is_err() - Report whether an XArray operation returned an error* 192 *\* @entry: Result from calling an XArray function* 193 *\**

194 *\* If an XArray operation cannot complete an operation, it will return*







195 *\* a special value indicating an error. This function tells you* 196 *\* whether an error occurred; xa_err() tells you which error occurred.* 197 *\**

198 *\* Context: Any context.*

199 *\* Return: %true if the entry indicates an error.* 200 *\*/*

201 **static inline bool xa_is_err**(**const void** \*entry) 202 {

203 **return unlikely**(**xa_is_internal**(entry) && 204 entry \>= **xa_mk_internal**(-**MAX_ERRNO**)); 205 }



*Listing 9-10:* include/linux/xarray.h: [*xa_is_err()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n201)



These error values can be extracted via [xa_err()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n219), shown in Listing 9-11.



207 */\*\**

208 *\* xa_err() - Turn an XArray result into an errno.* 209 *\* @entry: Result from calling an XArray function.* 210 *\**

211 *\* If an XArray operation cannot complete an operation, it will return* 212 *\* a special pointer value which encodes an errno. This function extracts*

213 *\* the errno from the pointer value, or returns 0 if the pointer does not* 214 *\* represent an errno.*

215 *\**

216 *\* Context: Any context.*

217 *\* Return: A negative errno or 0.* 218 *\*/*

219 **static inline int xa_err**(**void** \*entry) 220 {

221 */\* xa_to_internal() would not do sign extension. \*/* 222 **if** (**xa_is_err**(entry)) 223 **return** (**long**)entry \>\> 2; 224 **return** 0;

225 }



*Listing 9-11:* include/linux/xarray.h: [*xa_err()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n219)



Internal entries typically provide a pointer to a [struct xa_node](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1140) object which

forms part of a tree. An xarray node is described by the [struct xa_node](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1140) type

and check for by [xa_is_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1240), shown in Listing 9-12.



1239 */\* Private \*/*

1240 **static inline bool xa_is_node**(**const void** \*entry) 1241 {

1242 **return** xa_is_internal(entry) && (**unsigned long**)entry \> 4096; 1243 }



*Listing 9-12:* include/linux/xarray.h: [*xa_is_node()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1240)



Converted to a [struct xa_node](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1140) via [xa_to_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1234)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1234) shown in Listing 9-13.







1233 */\* Private \*/*

1234 **static inline struct** xa_node \***xa_to_node**(**const void** \*entry) 1235 {

1236 **return** (**struct** xa_node \*)((**unsigned long**)entry - 2); 1237 }



*Listing 9-13:* include/linux/xarray.h: [*xa_to_node()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1234)

And constructed via [xa_mk_node()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1228)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1228) shown in Listing 9-14.



1227 */\* Private \*/*

1228 **static inline void** \***xa_mk_node**(**const struct** xa_node \*node) 1229 {

1230 **return** (**void** \*)((**unsigned long**)node \| 2); 1231 }



*Listing 9-14:* include/linux/xarray.h: [*xa_mk_node()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1228)

When an internal entry does not refer to a node or an error, it utilises

the lower part of the virtual address space range up to be one of the follow-

ing special cases (as described in the comment in listing 9-3):



**Sibling entry** 0 - 62 – Used only in the advanced xarray API. This indicates

that multiple indices span a single entry in the xarray, with the value indicating the offset this entry is from the spanned one.

**Retry entry** 256 – [XA_RETRY_ENTRY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1269) – Used only in the advanced xarray API. In-

dicates that another thread holds the xa_lock and is midway through up-dating the entry. To avoid obtaining a reference that might be dropped momentarily, restart the operation.

**Zero entry** 257 – [XA_ZERO_ENTRY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n174) – Indicates that the entry is non-empty, but

represents the NULL value. In the normal API (see Section 9.2.1 below for a discussion on xarray APIs) these are simply expressed as NULL values, however the advanced API can encounter these values directly.



That this is a node gives a hint to the internal structure of an xarray – it

is fundamentally a radix tree, though optimised to handle arbitrary address

ranges as its key, improving upon the prior kernel radix tree implementa-

tion.

We examine the [struct xa_node](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1140) data structure in Listing 9-15.



1133 */\**

1134 *\* @count is the count of every non-NULL element in the -\>slots array* 1135 *\* whether that is a value entry, a retry entry, a user pointer,* 1136 *\* a sibling entry or a pointer to the next level of the tree.* 1137 *\* @nr_values is the count of every element in -\>slots which is* 1138 *\* either a value entry or a sibling of a value entry.* 1139 *\*/*

1140 **struct xa_node** {

1141 **unsigned char** shift; */\* Bits remaining in each slot \*/* 1142 **unsigned char** offset; */\* Slot offset in parent \*/*







1143 **unsigned char** count; */\* Total entry count \*/* 1144 **unsigned char** nr_values; */\* Value entry count \*/* 1145 **struct xa_node \_\_rcu** \*parent; */\* NULL at top of tree \*/* 1146 **struct xarray** \*array; */\* The array we belong to \*/* 1147 **union** {

1148 **struct** list_head private_list; */\* For tree user \*/* 1149 **struct** rcu_head rcu_head; */\* Used when freeing node \*/* 1150 };

1151 **void \_\_rcu** \*slots\[**XA_CHUNK_SIZE**\]; 1152 **union** {

1153 **unsigned long** tags\[**XA_MAX_MARKS**\]\[**XA_MARK_LONGS**\]; 1154 **unsigned long** marks\[**XA_MAX_MARKS**\]\[**XA_MARK_LONGS**\]; 1155 };

1156 };



*Listing 9-15:* include/linux/xarray.h: [*struct xa_node*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1140)



Each individual node contains [XA_CHUNK_SIZE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1128) ‘slots’, containing point-

ers. This, for anything other than a tiny embedded system will be 2 6, or 64 pointers (512 bytes for x86-64). Each of these slots consist of entries, some of which might be further nodes.

Rather, similar to a dynamic array, the xarray doubles in capacity

when it runs out of space. Unlike a dynamic array, an xarray achieves

this by installing new [struct xa_node](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1140)[s](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1140) (the first expansion installing one

in [struct xarray-\>xa_head](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n296) with a node entry pointing at the previous head placed in the first slot).

This parent node is inserted at the head with its shift increased by

[XA_CHUNK_SIZE, ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1128)a value which indicates the range of indices over which each node entry spans, e.g. a shift of 6 indicates that the node in slot entry 1 is offset by 26 i.e. 64 indices, entry 2 by 128, etc.

Within an xarray tree, each index is simply determined to be the ith leaf

node (accounting for entries which span multiple indices which are indexed over their whole range) so by expanding the tree in the fashion described above we only increment the maximum used index within the array.

Let’s examine the case of a single value in an xarray, to which we add one

more value (all diagrams below use \* to indicate value and N to indicate a

pointer to a node), shown in Figure 9-2.







[struct xarray](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n296)



xa_head: \*



[struct xarray](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n296)

xa_head



[struct xa_node](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1140)

shift: 0

\* \*



*Figure 9-2: Expanding an xarray From One Element to Two*



In the case of an xarray containing one or no elements, no additional

memory need be allocated and instead the value can simply be placed in the

[struct xarray-\>xa_head](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n296) field.

Now let’s examine how things look once we populate an entire node’s

[XA_CHUNK_SIZE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1128) slot entries, then expand that by a single value, as shown in Fig-

ure 9-3.







[struct xarray](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n296)

xa_head



[struct xa_node](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1140)

shift: 0

...

\* \* \*



[struct xarray](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n296)

xa_head



[struct xa_node](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1140)

shift: 6

N N



[struct xa_node struct xa_node](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1140)

shift: 0 shift: 0 offset: 0 offset: 1

\* \* ... \* \*



*Figure 9-3: Expanding an xarray of* [*XA_CHUNK_SIZE*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1128) *Elements By 1*



We perform the minimum amount of work required to expand the xar-

ray by preserving the existing [struct xa_node](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1140) and referencing it in an entry in

a new [struct xa_node](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1140) which we assign shift [XA_CHUNK_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1126)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1126) which here we take

to be 6 (indicating 26 [XA_CHUNK_SIZE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1128) i.e. 64).

This therefore indicates that all entries in the topmost [struct xa_node](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1140) are

offset by [XA_CHUNK_SIZE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1128) multiplied by the index within the array. We encapsu-

late this in the new [struct xa_node](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1140) object we allocate and assign to the second

entry in the topmost [struct xa_node](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1140)[’s](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1140) array, which adds the 65th entry. This node has offset of 1, and a combination of the parent’s shift and leaf’s offset tells us the location of each value within the array.

The next expansion will occur when the topmost [struct xa_node](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1140) be-

comes full. Since each node contains [XA_CHUNK_SIZE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1128) entries and the top-

level node stores [XA_CHUNK_SIZE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1128) references to leaf nodes, each containing

[XA_CHUNK_SIZE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1128) 2 values, we can therefore store [XA_CHUNK_SIZE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1128) entries, or 4,096

with [XA_CHUNK_SIZE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1128) of 64, meaning that we must expand the xarray after we

reach this point as shown in Figure 9-4.







[struct xarray](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n296)

xa_head



[struct xa_node](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1140)

shift: 6

N N ... N



[struct xa_node struct xa_node](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1140)



offset: 0 ... offset: 63 shift: 0 shift: 0

... ...

\* \* \* \* \* \*



[struct xarray](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n296)

xa_head



[struct xa_node](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1140)

shift: 12

N N



[struct xa_node struct xa_node](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1140)

shift: 6 shift: 6 offset: 0 offset: 1

N N ... N N



[struct xa_node](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1140)

shift: 0

(existing children as shown above) offset: 0

\*



*Figure 9-4: Expanding an xarray of* *2* [*XA_CHUNK_SIZE*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1128)*+1 Elements By 1*







Once again the procedure at a top-level here is quite simple—we allocate

a new [struct xa_node](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1140) which we place immediately below the [struct xarray](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n296) in the head position, and we assign the previous node as the first element in the new array.

The expansion is slightly more involved, as we allocate two nodes rather

than one in order to add a new value entry at the correct shift level.



**N O T E** If entries are added that skip indices (e.g. xarray of size 1, insert an entry at index

4097), then empty entries are added to pad out the xarray to incorporate the newly inserted entry.



So far we’ve examined value entries that exist only in leaf nodes, i.e. at

shift 0. It is in fact possible to maintain entries at higher shifts that span mul-tiple indices, e.g. representing a folio of higher order (an order-1 folio spans 2 subpages, an order-2 folio spans 4, etc., see Sections **??** and **??** for more de-tails).

In order to accommodate such a higher-order value entry for shift levels

other than those which naturally arise on xarray expansion, the process for storing these values is to find the highest shift level less than or equal to the number of spanned indices, and to use ‘sibling’ entries immediately adjacent to it to extend the occupied range.

For instance, if I wish to span 29 indices, The entry for this can be placed

in a shift 6 node (where each entry spans 64 indices) followed by 7 sibling entries (therefore spanning 64×8 i.e. 512 indices as required).

We have mentioned [XA_CHUNK_SIZE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1128) above, so let’s examine the definition

in Listing 9-16.



1115 */\**

1116 *\* The xarray is constructed out of a set of 'chunks' of pointers. Choosing*

1117 *\* the best chunk size requires some tradeoffs. A power of two recommends*

1118 *\* itself so that we can walk the tree based purely on shifts and masks.* 1119 *\* Generally, the larger the better; as the number of slots per level of the*

1120 *\* tree increases, the less tall the tree needs to be. But that needs to be*

1121 *\* balanced against the memory consumption of each node. On a 64-bit system,*

1122 *\* xa_node is currently 576 bytes, and we get 7 of them per 4kB page. If we*

1123 *\* doubled the number of slots per node, we'd get only 3 nodes per 4kB page.*

1124 *\*/*

1125 **\#ifndef XA_CHUNK_SHIFT**

1126 **\#define XA_CHUNK_SHIFT** (**CONFIG_BASE_SMALL** ? 4 : 6) 1127 **\#endif**

1128 **\#define XA_CHUNK_SIZE** (1UL \<\< **XA_CHUNK_SHIFT**) 1129 **\#define XA_CHUNK_MASK** (**XA_CHUNK_SIZE**- 1) 1130 **\#define XA_MAX_MARKS** 3 1131 **\#define XA_MARK_LONGS** **DIV_ROUND_UP**(**XA_CHUNK_SIZE**, **BITS_PER_LONG**)



*Listing 9-16:* include/linux/xarray.h: [*XA_CHUNK_SIZE*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1128)



It’s very useful to associate metadata with xarray entries, so we do so by

using tags and marks associated with each node up to [XA_MAX_MARKS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1130) (3), with







each bit of the tags and marks fields used to tag entries in the chunk of en-

tries contained in this node.

These are stored in a union so are mutually exclusive – the difference

between the two are that marks are propagated up through the tree, making

it easier to efficiently search for marked entries, while tags are not.

Having this facility is very useful, as when traversing a large xarray, it’s

useful to differentiate between different elements and to, for instance,

search only specific kinds of entries which we can indicate by marking or

tagging them.

This is used extensively by the page cache mechanism to mark

dirty/writeback folios as you will observe later in the chapter.



***9.2.1 API***

There are two separate APIs provided in the [xarray](https://kernel.org/doc/html/v6.0/core-api/xarray.html) implementation – the

‘normal’ API and the ‘advanced’ API. The former handles the locking auto-

matically and provides a relatively straightforward interface, with the latter

offering more flexibility but requiring the user to correct perform locking as

required.

We won’t examine the code deeply at all, but as a taster let’s examine a

basic function in the normal API, [xa_store()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/xarray.c?h=v6.0#n1577)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/xarray.c?h=v6.0#n1577) shown in Listing 9-17.



1560 */\*\**

1561 *\* xa_store() - Store this entry in the XArray.* 1562 *\* @xa: XArray.*

1563 *\* @index: Index into array.* 1564 *\* @entry: New entry.*

1565 *\* @gfp: Memory allocation flags.* 1566 *\**

1567 *\* After this function returns, loads from this index will return @entry.* 1568 *\* Storing into an existing multi-index entry updates the entry of every index*

*.*

1569 *\* The marks associated with @index are unaffected unless @entry is %NULL.*

1570 *\**

1571 *\* Context: Any context. Takes and releases the xa_lock.* 1572 *\* May sleep if the @gfp flags permit.* 1573 *\* Return: The old entry at this index on success, xa_err(-EINVAL) if @entry*

1574 *\* cannot be stored in an XArray, or xa_err(-ENOMEM) if memory allocation* 1575 *\* failed.*

1576 *\*/*

1577 **void** \***xa_store**(**struct** xarray \*xa, **unsigned long** index, **void** \*entry, **gfp_t** gfp) 1578 {

1579 **void** \*curr;

1580

1581 **xa_lock**(xa);

1582 curr = **\_\_xa_store**(xa, index, entry, gfp); 1583 **xa_unlock**(xa);

1584







1585 **return** curr;

1586 }



*Listing 9-17:* lib/xarray.c: [*xa_store()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/xarray.c?h=v6.0#n1577)



This stores the entry entry into the [struct xarray](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n296) xa at index index. As you

can see, the [struct xarray-\>xa_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n296) is acquired here on the behalf of the user.

The heavy lifting is performed by [\_\_xa_store()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/xarray.c?h=v6.0#n1540) (eliding out of scope entry

free tracking logic), shown in Listing 9-18.



1525 */\*\**

1526 *\* \_\_xa_store() - Store this entry in the XArray.* 1527 *\* @xa: XArray.*

1528 *\* @index: Index into array.* 1529 *\* @entry: New entry.*

1530 *\* @gfp: Memory allocation flags.* 1531 *\**

1532 *\* You must already be holding the xa_lock when calling this function.* 1533 *\* It will drop the lock if needed to allocate memory, and then reacquire*

1534 *\* it afterwards.*

1535 *\**

1536 *\* Context: Any context. Expects xa_lock to be held on entry. May* 1537 *\* release and reacquire xa_lock if @gfp flags permit.* 1538 *\* Return: The old entry at this index or xa_err() if an error happened.* 1539 *\*/*

1540 **void** \***\_\_xa_store**(**struct** xarray \*xa, **unsigned long** index, **void** \*entry, **gfp_t**

gfp)

1541 {

1542 XA_STATE(xas, xa, index); 1543 **void** \*curr;

1544

1545 **if** (**WARN_ON_ONCE**(**xa_is_advanced**(entry))) 1546 **return XA_ERROR**(-**EINVAL**);

. . .

1550 **do** {

1551 curr = **xas_store**(&xas, entry);

. . .

1554 } **while** (**\_\_xas_nomem**(&xas, gfp)); 1555

1556 **return xas_result**(&xas, curr); 1557 }



*Listing 9-18:* lib/xarray.c: [*\_\_xa_store()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/xarray.c?h=v6.0#n1540)



The function asserts that the entry does not comprise any advanced API

entity via [xa_is_advanced()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1288)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1288) such as [XA_RETRY_ENTRY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1269) or a sibling entry, as the basic API calls are not suited to such operations.

The rest of the logic relies on an advanced API feature, which is used in-

ternally here. The advanced API features tend to use a state iterator variable







of type [struct xa_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1326), which is threaded through function calls. We exam-

ine this object in Listing 9-19.



1309 */\**

1310 *\* The xa_state is opaque to its users. It contains various different pieces*

1311 *\* of state involved in the current operation on the XArray. It should be*

1312 *\* declared on the stack and passed between the various internal routines.*

1313 *\* The various elements in it should not be accessed directly, but only* 1314 *\* through the provided accessor functions. The below documentation is for*

1315 *\* the benefit of those working on the code, not for users of the XArray.* 1316 *\**

1317 *\* @xa_node usually points to the xa_node containing the slot we're operating*

1318 *\* on (and @xa_offset is the offset in the slots array). If there is a* 1319 *\* single entry in the array at index 0, there are no allocated xa_nodes to*

1320 *\* point to, and so we store %NULL in @xa_node. @xa_node is set to* 1321 *\* the value %XAS_RESTART if the xa_state is not walked to the correct* 1322 *\* position in the tree of nodes for this operation. If an error occurs* 1323 *\* during an operation, it is set to an %XAS_ERROR value. If we run off the*

1324 *\* end of the allocated nodes, it is set to %XAS_BOUNDS.* 1325 *\*/*

1326 **struct** xa_state {

1327 **struct** xarray \*xa; 1328 **unsigned long** xa_index; 1329 **unsigned char** xa_shift; 1330 **unsigned char** xa_sibs; 1331 **unsigned char** xa_offset; 1332 **unsigned char** xa_pad; */\* Helps gcc generate better code \*/* 1333 **struct** xa_node \*xa_node; 1334 **struct** xa_node \*xa_alloc; 1335 xa_update_node_t xa_update; 1336 **struct** list_lru \*xa_lru; 1337 };



*Listing 9-19:* include/linux/xarray.h: [*struct xa_state*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1326)



This object is used for traversal as well as updating of xarray elements. It

maintains state about an entry we are interacting with, for example search-

ing for or newly inserting.

Examining each field, eliding the padding and out of scope LRU fields:



• xa – The [struct xarray](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n296) object we are interacting with.

• xa_index – The index within the xarray we are interested in. Entries in

the xarray start at zero and an entry’s index is determined by it being the ith leaf node, offsetting accordingly for any entry which spans a range of indices.

• xa_shift – Indicates the level at which this entry will be placed. This is

only relevant to entries which span multiple indices, ordinary single-index entries will have xa_shift of zero.







• xa_sibs – The number of sibling entries this entry requires.

• xa_offset – The offset of this entry within a given node.

• xa_node – The node within which the entry is located.

• xa_alloc – A pointer to newly allocated memory to be used for perform-

ing this operation.

• xa_update – An optional [xa_update_node_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1305) callback function provided by

the user through the advanced API which is invoked every time either

count or nr_values is updated in the [struct xa_node](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1140) node containing this entry.



The [struct xa_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1326) object is often initialised via the [XA_STATE()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1368) macro,

shown in Listing 9-20.



1360 */\*\**

1361 *\* XA_STATE() - Declare an XArray operation state.* 1362 *\* @name: Name of this operation state (usually xas).* 1363 *\* @array: Array to operate on.* 1364 *\* @index: Initial index of interest.* 1365 *\**

1366 *\* Declare and initialise an xa_state on the stack.* 1367 *\*/*

1368 **\#define XA_STATE**(name, array, index) \\ 1369 **struct** xa_state name = **\_\_XA_STATE**(array, index, 0, 0)



*Listing 9-20:* include/linux/xarray.h: [*XA_STATE()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1368)



Which, in turn, invokes the [\_\_XA_STATE()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1347) macro to actually assign field

values, shown in Listing 9-21.



1347 **\#define \_\_XA_STATE**(array, index, shift, sibs) { \\ 1348 .xa = array, \\ 1349 .xa_index = index, \\ 1350 .xa_shift = shift, \\ 1351 .xa_sibs = sibs, \\ 1352 .xa_offset = 0, \\ 1353 .xa_pad = 0, \\ 1354 .xa_node = **XAS_RESTART**, \\ 1355 .xa_alloc = **NULL**, \\ 1356 .xa_update = **NULL**, \\ 1357 .xa_lru = **NULL**, \\ 1358 }



*Listing 9-21:* include/linux/xarray.h: [*\_\_XA_STATE()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1347)



The [\_\_XA_STATE()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1347) macro can be used directly for cases of entries which

span multiple indices, otherwise [XA_STATE()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1368) is sufficient.

Additionally, a user wishing to interact with an entry spanning mul-

tiple indices, a convenient macro to configure a [struct xa_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1326) object is

[XA_STATE_ORDER(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1382)shown in Listing 9-22.







1371 */\*\**

1372 *\* XA_STATE_ORDER() - Declare an XArray operation state.* 1373 *\* @name: Name of this operation state (usually xas).* 1374 *\* @array: Array to operate on.* 1375 *\* @index: Initial index of interest.* 1376 *\* @order: Order of entry.* 1377 *\**

1378 *\* Declare and initialise an xa_state on the stack. This variant of* 1379 *\* XA_STATE() allows you to specify the 'order' of the element you* 1380 *\* want to operate on.\`*

1381 *\*/*

1382 **\#define XA_STATE_ORDER**(name, array, index, order) \\ 1383 **struct** xa_state name = **\_\_XA_STATE**(array, \\ 1384 (index \>\> order) \<\< order, \\ 1385 order - (order % **XA_CHUNK_SHIFT**), \\ 1386 (1U \<\< (order % **XA_CHUNK_SHIFT**)) - 1)



*Listing 9-22:* include/linux/xarray.h: [*XA_STATE_ORDER()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1382)

This is actually rather useful in understanding entries spanning a range

of indices – order indicates the power of two number of indices to span

(since the primary use case again is the page cache which can comprise

higher order folios, use of this terminology is helpful).

This aligns the index of the entry, determines the next lowest shift value

which can accommodate it (subtracting the remainder after dividing the or-

der by chunk size) and calculating the number of siblings to be one less than

this offset in bytes.

Note that there are certain xa_node values which have particular mean-

ings:



• [XA_ERROR()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1343) – Indicates that an error has occurred identically to an error

being reported for an entry that can be checked via [xa_is_err()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n201) (as de-

scribed in listing 9-10).

• [XAS_BOUNDS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1344) – Indicates that the current iteration has run past the end of

the currently available indices in any node.

• [XAS_RESTART](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1345) – Indicates that the iterator is not in a correct state for traver-

sal and must be restarted. This is the initial default value.



***9.2.2 The Rest***

We have touched on [xa_store()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/xarray.c?h=v6.0#n1577) as an example of how the xarray API is imple-

mented, and examined core data structures used through an xarray traver-

sal.

If we were to dive deep into the API this would require an entire chap-

ter’s worth of exploration. Naturally, we will encounter xarray operations

as we continue to explore the page cache, as these are used extensively, and

from this we can gain insights into how the API is used, especially the ad-

vanced API.







The [xarray documentation](https://kernel.org/doc/html/v6.0/core-api/xarray.html) is, additionally, extensive.

Broadly speaking, simple operations from the basic API are [xa_load()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/xarray.c?h=v6.0#n1456)

which loads an entry from the xarray, [xa_store()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/xarray.c?h=v6.0#n1577) which stores an entry into

the xarray, [xa_erase()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/xarray.c?h=v6.0#n1513) which erases an entry from the xarray and [xa_find()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/xarray.c?h=v6.0#n2013) which finds an entry in the xarray.



**9.3 Reading From a File**



We examine an example of an unbuffered read from a file into a buffer in C

in Listing 9-23.



**\#include** \<fcntl.h\>

**\#include** \<stdio.h\>

**\#include** \<stdlib.h\>

**\#include** \<sys/stat.h\>

**\#include** \<unistd.h\>



**int** main(**void**)

{

**int** fd = **open**("test.txt", **O_RDONLY**); **ssize_t** num_bytes = 0; **int** err = **EXIT_FAILURE**; **struct** stat statbuf; **char** \*buf;

**size_t** size;



**if** (fd == -1) {

**perror**("**open**"); **goto exit**;

}



**if** (**fstat**(fd, &statbuf)) {

**perror**("**fstat**"); **goto exit_close**;

}



size = statbuf.st_size;

**if** (size == 0) {

err = **EXIT_SUCCESS**; **goto exit_close**;

}



buf = **malloc**(size + 1); **if** (!buf) {

**perror**("**malloc**"); **goto exit_close**;

}







**do** {

**ssize_t** ret = **read**(fd, &buf\[num_bytes\], size - num_bytes);



**if** (ret == -1) {

**perror**("**read**"); **goto exit_free**;

}



num_bytes += ret;

} **while** (num_bytes \< size);



buf\[size\] = '\0';

**printf**("%s", buf);



err = **EXIT_SUCCESS**;



**exit_free**:

**free**(buf);

**exit_close**:

**close**(fd);

**exit**:

**return** err;

}



*Listing 9-23: Example file read operation*



This uses [read()](https://man7.org/linux/man-pages/man2/read.2.html) to read data into a buffer from a file descriptor (the com-

monly used alternative [fread()](https://man7.org/linux/man-pages/man3/fread.3.html) does the same, only internally buffered and

with other semantic differences).

This invokes the [read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/read_write.c?h=v6.0#n621) system call, which calls the [ksys_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/read_write.c?h=v6.0#n602) function

in turn. This obtains a [struct fd](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/file.h?h=v6.0#n35) object for the open file descriptor (con-

taining flags and a reference to the [struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) object describing this open

file), incrementing the reference count if necessary via [fdget_pos()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/file.h?h=v6.0#n71), invoking

[vfs_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/read_write.c?h=v6.0#n450) to perform the read before decrementing the reference count if

necessary via [fdput_pos()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/file.h?h=v6.0#n76).



**N O T E** The [*struct file*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) object keeps track of the current position within the file. Given mul-

tiple threads could be accessing this file at the same time, it raises the question of a

possible conflict between multiple reads/writes overlapping one another.

Thankfully, since Linux 3.14, this question is answered with a lock – the

[*FMODE_ATOMIC_POS*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n152) mode is automatically set for regular files and directories if the file

is opened by more than one thread.

In this case, the [*struct file-\>f_pos_lock*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) is automatically acquired on [*fdget_pos()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/file.h?h=v6.0#n71)

and releasing on [*fdput_pos()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/file.h?h=v6.0#n76).

This is codified in POSIX.1-2008/SUSv4 Section XSI 2.9.7 (”Thread Interactions

with Regular File Operations”), see the ‘bugs’ section of the [*read()*](https://man7.org/linux/man-pages/man2/read.2.html) manual page

entry for details.







This is where the flexible implementation of the VFS comes into play –

[vfs_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/read_write.c?h=v6.0#n450) invokes either the [struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940)-\>f_op-\>read() function (a file system-

specified field in the [struct file_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2093) f_op object) if one is provided, or

if read_iter() is specified instead, invoking [new_sync_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/read_write.c?h=v6.0#n379) to call this instead.

The read_iter file operation performs the same task, only making use of

a [struct iov_iter](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/uio.h?h=v6.0#n38) iterator object to perform the task. This approach abstracts I/O operations across a number of different types of I/O entities (pipes,

[iovec](https://man7.org/linux/man-pages/man3/iovec.3.html) objects and userland buffers, among others). We will be focusing solely on the user buffer case.

We examine [new_sync_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/read_write.c?h=v6.0#n379) in Listing 9-24.



379 **static ssize_t new_sync_read**(**struct** file \*filp, **char \_\_user** \*buf, **size_t** len,

loff_t \*ppos)

380 {

381 **struct** kiocb kiocb; 382 **struct** iov_iter iter; 383 **ssize_t** ret;

384

385 **init_sync_kiocb**(&kiocb, filp); 386 kiocb.ki_pos = (ppos ? \*ppos : 0); 387 **iov_iter_ubuf**(&iter, **READ**, buf, len); 388

389 ret = **call_read_iter**(filp, &kiocb, &iter); 390 **BUG_ON**(ret == -**EIOCBQUEUED**); 391 **if** (ppos)

392 \*ppos = kiocb.ki_pos; 393 **return** ret;

394 }



*Listing 9-24:* fs/read_write.c: [*new_sync_read()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/read_write.c?h=v6.0#n379)



This starts by initialising the [struct kiocb](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n341) kernel I/O control block object

via [init_sync_kiocb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2334), setting its ki_filp field to the [struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) object filp,

its ki_flags field to [struct file-\>f_iocb_flags](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) and the ki_ioprio field to the current task’s I/O priority (out of scope for the book) and its ki_pos field to the current file position. All other fields are zeroed.

The ‘I/O control block’ object kiocb acts as state threaded through

the I/O operation, maintained on the stack as the operation is syn-

chronous. The [struct file-\>f_iocb_flags](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) field having been determined via

the [iocb_flags()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n3384) helper function on file open in [do_dentry_open()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/open.c?h=v6.0#n826)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/open.c?h=v6.0#n826) shown in

Listing 9-25.



3384 **static inline int iocb_flags**(**struct** file \*file) 3385 {

3386 **int** res = 0;

3387 **if** (file-\>f_flags & **O_APPEND**) 3388 res \|= **IOCB_APPEND**; 3389 **if** (file-\>f_flags & **O_DIRECT**) 3390 res \|= **IOCB_DIRECT**;







3391 **if** (file-\>f_flags & **O_DSYNC**) 3392 res \|= **IOCB_DSYNC**; 3393 **if** (file-\>f_flags & **\_\_O_SYNC**) 3394 res \|= **IOCB_SYNC**; 3395 **return** res;

3396 }



*Listing 9-25:* include/linux/fs.h: [*iocb_flags()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n3384)



See the manual page for [open](https://man7.org/linux/man-pages/man2/open.2.html) for more details on each of these flags, not-

ing that [\_\_O_SYNC](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/asm-generic/fcntl.h?h=v6.0#n80) is not used directly by the user but rather implies that O_SYNC

has been specified.

After kiocb is initialised, the [struct iov_iter](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/uio.h?h=v6.0#n38) object is set up for [READ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/kernel.h?h=v6.0#n48) of a

user buffer via [iov_iter_ubuf()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/uio.h?h=v6.0#n341), before calling [call_read_iter()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2178) to perform the

actual read prior to a bug condition check and resetting the ppos file position

if relevant.

We examine [call_read_iter()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2178) in Listing 9-26.



2178 **static inline ssize_t call_read_iter**(**struct** file \*file, **struct** kiocb \*kio, 2179 **struct** iov_iter \*iter) 2180 {

2181 **return** file-\>f_op-\>**read_iter**(kio, iter); 2182 }



*Listing 9-26:* include/linux/fs.h: [*call_read_iter()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2178)



This simply invokes the [struct file-\>f_op-\>read_iter()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) function (a file

system-specified field in the [struct file_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2093) f_op field).

Each file system specifies its own function here, though most will

end up invoking internal kernel functions for the core implementation.

Let’s look at a concrete example, the ext4 file system’s implementation

[ext4_file_read_iter() , ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/ext4/file.c?h=v6.0#n115)specified in [ext4_file_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/ext4/file.c?h=v6.0#n913) (eliding out of scope

direct I/O and DAX logic), shown in Listing 9-27.



115 **static ssize_t ext4_file_read_iter**(**struct** kiocb \*iocb, **struct** iov_iter \*to) 116 {

117 **struct** inode \*inode = **file_inode**(iocb-\>ki_filp);

118

119 **if** (**unlikely**(**ext4_forced_shutdown**(**EXT4_SB**(inode-\>i_sb)))) 120 **return**-**EIO**;

121

122 **if** (!**iov_iter_count**(to)) 123 **return** 0; */\* skip atime \*/*

. . .

132 **return generic_file_read_iter**(iocb, to); 133 }



*Listing 9-27:* fs/ext4/file.c: [*ext4_file_read_iter()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/ext4/file.c?h=v6.0#n115)







Other than some ext4-specific handling and the no-op case, this sim-

ply forwards the operation to [generic_file_read_iter()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2756)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2756) implemented in the

[mm/filemap.c](https://elixir.bootlin.com/linux/v6.0/source/mm/filemap.c) file.

When examining file system-specific logic, you’ll quickly notice that all

roads tend to lead back to functions in [mm/filemap.c](https://elixir.bootlin.com/linux/v6.0/source/mm/filemap.c) – which provides what are in essence the kernel’s library functions for page cache operations.

We examine [generic_file_read_iter()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2756) (eliding out of scope direct I/O

logic) in Listing 9-28.



2734 */\*\**

2735 *\* generic_file_read_iter - generic filesystem read routine* 2736 *\* @iocb:* *kernel I/O control block* 2737 *\* @iter:* *destination for the data read* 2738 *\**

2739 *\* This is the "read_iter()" routine for all filesystems* 2740 *\* that can use the page cache directly.* 2741 *\**

2742 *\* The IOCB_NOWAIT flag in iocb-\>ki_flags indicates that -EAGAIN shall* 2743 *\* be returned when no data can be read without waiting for I/O requests*

2744 *\* to complete; it doesn't prevent readahead.* 2745 *\**

2746 *\* The IOCB_NOIO flag in iocb-\>ki_flags indicates that no new I/O* 2747 *\* requests shall be made for the read or for readahead. When no data* 2748 *\* can be read, -EAGAIN shall be returned. When readahead would be* 2749 *\* triggered, a partial, possibly empty read shall be returned.* 2750 *\**

2751 *\* Return:*

2752 *\* \* number of bytes copied, even for partial reads* 2753 *\* \* negative error code (or 0 if IOCB_NOIO) if nothing was read* 2754 *\*/*

2755 **ssize_t**

2756 **generic_file_read_iter**(**struct** kiocb \*iocb, **struct** iov_iter \*iter) 2757 {

2758 **size_t** count = **iov_iter_count**(iter); 2759 **ssize_t** retval = 0; 2760

2761 **if** (!count)

2762 **return** 0; */\* skip atime \*/*

. . .

2806 **return filemap_read**(iocb, iter, retval); 2807 }



*Listing 9-28:* mm/filemap.c: [*generic_file_read_iter()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2756)



This performs the empty iterator no-op check once again, before simply

delegating the heavy lifting to [filemap_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2626)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2626) To summarise, a typical route

from a [read()](https://man7.org/linux/man-pages/man2/read.2.html) call to the kernel actually reading data from the page cache is

shown in Listing 9-29.







[read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/read_write.c?h=v6.0#n621) syscall



[ksys_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/read_write.c?h=v6.0#n602)



[vfs_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/read_write.c?h=v6.0#n450)



[new_sync_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/read_write.c?h=v6.0#n379)



[call_read_iter()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2178)



[generic_file_read_iter()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2756)



[filemap_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2626)



*Figure 9-5:* [*filemap_read()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2626) *Page Cache Retrieval*



We examine [filemap_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2626) (eliding out of scope io_uring-specific and

dcache flush logic) in Listing 9-29.



2613 */\*\**

2614 *\* filemap_read - Read data from the page cache.* 2615 *\* @iocb: The iocb to read.* 2616 *\* @iter: Destination for the data.* 2617 *\* @already_read: Number of bytes already read by the caller.* 2618 *\**

2619 *\* Copies data from the page cache. If the data is not currently present,*

2620 *\* uses the readahead and read_folio address_space operations to fetch it.*

2621 *\**

2622 *\* Return: Total number of bytes copied, including those already read by* 2623 *\* the caller. If an error happens before any bytes are copied, returns* 2624 *\* a negative error number.* 2625 *\*/*

2626 **ssize_t filemap_read**(**struct** kiocb \*iocb, **struct** iov_iter \*iter, 2627 **ssize_t** already_read) 2628 {

2629 **struct** file \*filp = iocb-\>ki_filp; 2630 **struct** file_ra_state \*ra = &filp-\>f_ra; 2631 **struct** address_space \*mapping = filp-\>f_mapping; 2632 **struct** inode \*inode = mapping-\>host; 2633 **struct** folio_batch fbatch; 2634 **int** i, error = 0;

. . .

2636 loff_t isize, end_offset; 2637

2638 **if** (**unlikely**(iocb-\>ki_pos \>= inode-\>i_sb-\>s_maxbytes)) 2639 **return** 0; 2640 **if** (**unlikely**(!**iov_iter_count**(iter)))







2641 **return** 0; 2642

2643 **iov_iter_truncate**(iter, inode-\>i_sb-\>s_maxbytes); 2644 **folio_batch_init**(&fbatch);



*Listing 9-29:* mm/filemap.c: [*filemap_read()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2626) *Initialisation*



We start by performing a couple of sanity checks—the

[struct kiocb](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n341)-\>ki_pos field indicates the current offset within the file, we

check to ensure this does not exceed the [struct inode-\>i_sb-\>s_maxbytes](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593) (i.e.

[struct super_block-\>s_maxbytes](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n1451)) value which indicates the maximum file size permitted on the mounted file system, and again check to ensure the itera-tor isn’t empty.

We then limit the size of the target buffer being written to this maximum

file size via [iov_iter_truncate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/uio.h?h=v6.0#n270) (this is often a very large value, for instance my ext4 system has a limit of 16 TiB).

We process folios in the page cache in [struct folio_batch](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n83) batches, using

the fbatch variable, which we initialise via [folio_batch_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n100)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n100)

Next, we begin a loop where we synchronously work to retrieve a batch of

folios of [PAGEVEC_SIZE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n15) at a time (the standard folio batch size, see Section 11.7

for more on folio batches in general), shown in Listing 9-30.



2646 **do** {

2647 **cond_resched**();

. . .

2657 **if** (**unlikely**(iocb-\>ki_pos \>= **i_size_read**(inode))) 2658 **break**; 2659

2660 error = **filemap_get_pages**(iocb, iter, &fbatch); 2661 **if** (error \< 0) 2662 **break**;



*Listing 9-30:* mm/filemap.c: [*filemap_read()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2626) *page retrieval (Start of Loop)*



We start by conditionally permitting rescheduling of the process on each

loop, relevant only for kernels which lack full preemption via [cond_resched()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n2082)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n2082)

If the position within the [struct kiocb](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n341) object specified by the

ki_pos field is equal to or exceeds the inode-indicated file size as de-

termined by [i_size_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n845) (for 64-bit systems this is precisely equal to

[struct inode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593)-\>i_size), then we are done and exit the loop.

Next, we retrieve the folios from the page cache via [filemap_get_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2546)

which passes the [struct kiocb](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n341) and [struct iov_iter](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/uio.h?h=v6.0#n38) pointers to indicate what

page cache folios to place in the [struct folio_batch](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n83) fbatch object.

We examine [filemap_get_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2546) in detail in section 9.5 below. Invocation

of this function is core to [filemap_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2626) as it is what actually performs the page cache lookup.

Importantly, the reference count of each folio thus returned will be in-

cremented, pinning them in memory for the duration of the operation.







After folios have been retrieved, we perform some post-processing before

we copy the data to the target buffer before looping around again to retrieve

the next batch of data, shown in Listing 9-31.



2664 */\**

2665 *\* i_size must be checked after we know the pages are Uptodate*

*.*

2666 *\**

2667 *\* Checking i_size after the check allows us to calculate* 2668 *\* the correct value for "nr", which means the zero-filled*

2669 *\* part of the page is not copied back to userspace (unless*

2670 *\* another truncate extends the file - this is desired though)*

*.*

2671 *\*/*

2672 isize = **i_size_read**(inode); 2673 **if** (**unlikely**(iocb-\>ki_pos \>= isize)) 2674 **goto put_folios**; 2675 end_offset = **min_t**(loff_t, isize, iocb-\>ki_pos + iter-\>count);

. . .

2683 */\**

2684 *\* When a read accesses the same folio several times, only*

2685 *\* mark it as accessed the first time.* 2686 *\*/*

2687 **if** (!**pos_same_folio**(iocb-\>ki_pos, ra-\>prev_pos - 1, 2688 fbatch.folios\[0\]))

2689 **folio_mark_accessed**(fbatch.folios\[0\]);



*Listing 9-31:* mm/filemap.c: [*filemap_read()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2626) *Post-Processing*



We check to see whether the newly updated file position stored in

[struct kiocb](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n341)-\>ki_pos is equal to or exceeds the current file size (possibly ex-

tended by another thread), only after the folios have been retrieved, to en-

sure that what we copy is actually within the file that we are reading from (as

per the comment). If not, we jump to the put_folios label, and immediately

exit the loop.

We determine the terminating offset of the operation as the minimum

of the size of the file as specified by the inode (isize) and the sum of the

offset into the file [(](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n341)[struct kiocb-\>ki_pos](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n341)) and the remaining bytes to process

[(struct iov_iter-\>count](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/uio.h?h=v6.0#n38)), which indicates the exclusive upper bound of this

read.

Next, we determine whether to mark the first folio as accessed via

[folio_mark_accessed()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n441) (see Section 11.2 for more details on this) – we mark

the folio as such in order to indicate to reclaim that this folio has recently

been used and thus should be a lower priority for reclaim.

Why do we sometimes not do this to the first folio in the batch? This is

because a sequential read may start and stop within the same folio - remem-

ber that the offset into the file is specified at byte granularity, however folios

exist at minimum at base page granularity.







As a result, we might in theory read from bytes 0 to 100, then bytes 101

to 200, then bytes 201 to 300 and so on in the same folio, and as such the folio is really only in demand once, so repeatedly marking the folio accessed would be inaccurate.

As we read through the file, we keep track of the exclusive bound of the

last requested block of data in the [struct file_ra_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n922) object in its prev_pos field. This object (stored in variable ra) stores readahead state of the file, and

is sourced from the [struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940)-\>f_ra field. We go into detail on readahead

in section 9.7, but in this instance it suffices to note that this is where the prev_pos field is stored.

We determine whether the current offset into the file

[(struct kiocb-\>ki_pos](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n341)) and the known last position point to the same first fo-

lio via [pos_same_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2606), shown in Listing 9-32.



2606 **static inline bool pos_same_folio**(loff_t pos1, loff_t pos2, **struct** folio \*

folio)

2607 {

2608 **unsigned int** shift = **folio_shift**(folio); 2609

2610 **return** (pos1 \>\> shift == pos2 \>\> shift); 2611 }



*Listing 9-32:* mm/filemap.c: [*pos_same_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2606)



This simply determines the shift (i.e. the number of bits) comprising the

folio size via [folio_shift()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1634) and offsets each byte position accordingly before comparing them.

Once this check has been completed, we can go ahead and start copying

page cache folios into the iterator, shown in Listing 9-33.



2691 **for** (i = 0; i \< **folio_batch_count**(&fbatch); i++) { 2692 **struct** folio \*folio = fbatch.folios\[i\]; 2693 **size_t** fsize = **folio_size**(folio); 2694 **size_t** offset = iocb-\>ki_pos & (fsize - 1); 2695 **size_t** bytes = **min_t**(loff_t, end_offset - iocb-\>ki_pos

,

2696 fsize - offset); 2697 **size_t** copied; 2698

2699 **if** (end_offset \< **folio_pos**(folio)) 2700 **break**; 2701 **if** (i \> 0) 2702 **folio_mark_accessed**(folio);

. . .

2711 copied = **copy_folio_to_iter**(folio, offset, bytes, iter

);

2712

2713 already_read += copied; 2714 iocb-\>ki_pos += copied;







2715 ra-\>prev_pos = iocb-\>ki_pos; 2716

2717 **if** (copied \< bytes) { 2718 error = -**EFAULT**; 2719 **break**; 2720 } 2721 }



*Listing 9-33:* mm/filemap.c: [*filemap_read()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2626) *Folio Copying*



We iterate through each of the page cache folios obtained via

[filemap_get_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2546) (counting these using [folio_batch_count()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n106)), processing

each individually.

We determine the size of the folio, fsize using [folio_size()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1647)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1647) the offset

within the folio, offset (by masking against the folio size), the number of

bytes to be read from the folio, bytes, equal to either the folio size minus off-

set or, if the read range stops short of the end of the folio, the number of

bytes until the final offset.

If, for some reason, the starting offset of this folio within the file (deter-

mined by [folio_pos()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n814)) exceeds that of the exclusive end bound of the range

being read, end_offset we abort the operation.

For all but the first folio, which has special treatment as described above,

the folio is marked accessed via [folio_mark_accessed()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n441). This is important for

the purposes of reclaim – by reading from the file its associated page cache

folios have been accessed and thus should be deprioritised for reclaim. See

Section 11.2 for more details on how this functions.

The actual copy operation is performed via [copy_folio_to_iter()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2711). If this

fails to copy all of the bytes, which implies that an unrecoverable page fault

occurred (at least part of the buffer is unmapped or read-only for instance),

we store the EFAULT error code in error and we exit out of the copying loop.

Interestingly, on return, if some bytes have been copied, we ignore the er-

ror message and simply return the count of bytes that were copied, meaning

that if a user for instance [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html)’s a region but tries to copy more bytes into

that region then mapped (and no mapping immediately follows it), no error

will be returned.

Prior to checking for this error state, we update the [struct kiocb-\>ki_pos](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n341)

field to update the position, and importantly update the

[struct file_ra_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n922)-\>prev_pos field to indicate how much data has been

successfully read.



2722 **put_folios**:

2723 **for** (i = 0; i \< **folio_batch_count**(&fbatch); i++) 2724 **folio_put**(fbatch.folios\[i\]); 2725 **folio_batch_init**(&fbatch); 2726 } **while** (**iov_iter_count**(iter) && iocb-\>ki_pos \< isize && !error); 2727

2728 **file_accessed**(filp); 2729

2730 **return** already_read ? already_read : error;







2731 }



*Listing 9-34:* mm/filemap.c: [*filemap_read()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2626) *folio cleanup (End of Loop)*



Finally within the loop, we decrement the reference count for each re-

turned folio which was incremented by [filemap_get_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2546), and reset the

folio batch fbatch via [folio_batch_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n100) ready for the next iteration.

The do/while loop is terminated either by the iteration being complete

(i.e. [iov_iter_count()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/uio.h?h=v6.0#n259) returning zero), the [struct kiocb-\>ki_pos](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n341) offset counter being equal to or exceeding the file size, or an error having occurred.

Prior to returning, the function invokes [file_accessed()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2513) which updates

the file’s access time (i.e. atime), via the [touch_atime()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/inode.c?h=v6.0#n1921) function.



**N O T E** Typically modern file systems are mounted with the *relatime* option, to prevent the

file metadata from being updated on each access which would create egregiously un-necessary I/O.

In this mode, the access time is updated if either the file or its metadata was up-

dated since last update, or if the last access was over a day ago ([*touch_atime()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/inode.c?h=v6.0#n1921) calls

[*atime_needs_update()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/inode.c?h=v6.0#n1886) which calls [*relatime_need_update()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/inode.c?h=v6.0#n1810) in turn to perform this check).



The key bit of code we are missing here is the implementation of

[filemap_get_pages(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2546)however we will defer discussion of this to section 9.5 below, and instead look at the other most common means of accessing page cache entries, namely file-backed page faults.



**9.4 File-Backed Read Faults**



If a file is mapped into memory using [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html)[,](https://man7.org/linux/man-pages/man2/mmap.2.html) then looking up its contents from the page cache occurs at the point of page fault. This is another means by which user space applications are able to access file data (in this instance, on demand at page fault time), so we examine it in detail here.

We explored how the page fault logic functions in this instance in section

6.2 (see Figure 6-3 especially and a specific discussion of file-backed faulting

in section 6.8), noting that the heavy lifting is performed in [\_\_do_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4147) (see

Listing 6-32).

We won’t duplicate this listing, instead as this is an operation that oc-

curs at a VMA level, we observe that the fault handling is delegated to the

file system-defined [struct vm_area_struct-\>vm_ops-\>fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) function (i.e.

[struct vm_operations_struct-\>fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n539)).

Again, using ext4 as our example file system, we see that the

[ext4_file_vm_ops-\>fault](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/ext4/file.c?h=v6.0#n758) function forwards the operation to [filemap_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3084)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3084) This is the key ‘library function’ (in essence) provided by the kernel for file-backed faults, and as a result many file systems simply defer the operation to it entirely.

A key difference between this operation and the one performed on read

discussed in section 9.3 above is that the fault occurs on a single folio basis rather than a batch. In some respects this simplifies things, however we also







need to take into account the properties of the VMA into which the folio is

being faulted.

Nuances of the handling of page faults (folio at a time, must sit in the

page fault logic and interact with the page fault API such as interacting with

the [struct vm_fault](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n481) state object, VMA granularity rather than file granularity

among other things) means that logic that is shared between a read and a

page fault must necessarily get somewhat duplicated.

As a result, we will tread similar ground here and in the below discussion

of accessing page cache entries (section 9.5) which perform similar steps as

the [read()](https://man7.org/linux/man-pages/man2/read.2.html) approach (in section 9.3 above), exploring however in detail the

nuanced details in which each differ.

As this function is rather complicated, let’s step back and examine the

function diagrammatically in Figure 9-6, before diving into the function in

detail.





no

Valid index? SIGBUS

yes



Read folio from page cache

via [filemap_get_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n526)



In page cache?

no yes



[do_sync_mmap_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2968) [do_async_mmap_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3037)



Acquire invalidate lock via retry_find To post-processing

[filemap_invalidate_lock_shared()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n809) from Figures in Figure 9-7

9-7, 9-8



Create/get folio from

[\_\_filemap_get_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1914)



yes

Success?

no



yes

Dropped mmap_lock? [VM_FAULT_RETRY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n751)



no



[VM_FAULT_OOM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n742)



*Figure 9-6:* [*filemap_fault()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3084) *Page Cache Retrieval*



We start by checking to ensure that the index into the file is valid, if not

we simply send the process a SIGBUS signal.



**N O T E** The difference between a *SIGBUS* and a *SIGSEGV* signal isn’t always entirely clear. The

lines between the two are rather blurry (both imply an invalid memory access), how-ever broadly speaking:

•A *SIGSEGV* arises when an invalid access to a valid address occurs, e.g. accessing

unmapped memory, or memory to which you do not have permission to access, (e.g. writing to read-only mappings).

•A *SIGBUS* arises when an invalid address is accessed (whether the access is valid

or not), e.g. accessing unaligned addresses on an architecture which doesn’t sup-port unaligned access, or, pertinently, access to portions of a file mapping that are not backed by the file.







This can be trivially triggered by [*mmap()*](https://man7.org/linux/man-pages/man2/mmap.2.html)[’ing](https://man7.org/linux/man-pages/man2/mmap.2.html) a file at a size greater than the file size and accessing a page past the end of the file (a page containing a part of the file will return zeroes for the portion which are not mapped).

The out of scope accesses can be observed in Figures 9-6 and 9-7 (these arise as

the [*struct folio-\>index*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) being deemed invalid). In addition, an error occurring on attempted read of the file (for instance, access to a file on a network filesystem which has encountered connectivity issues) will

cause a *SIGBUS* to arise, as shown in Figure 9-8.



If the index is valid, we invoke [filemap_get_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n526) to see whether the

folio already exists in the page cache. If so, this is a minor fault (more on

these later) and we simply kick off any required asynchronous readahead

via [do_async_mmap_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3037) (see Section 9.7 below for a detailed description

of readahead), and move on to the post-processing phase.

Otherwise, this is a major fault, so we must attempt blocking readahead

via [do_sync_mmap_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2968)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2968) before seeing whether we can read back the fo-

lio we just read (or if readahead failed allocate a folio to populate with disk

data) via [\_\_filemap_get_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1914).

Note that we acquire the invalidate lock in the meantime via

[filemap_invalidate_lock_shared()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n809) to protect against racing folio truncation and

invalidation, more on this in the detailed examination of the code.

If we fail at this point we are out of memory, so depending on whether

we dropped the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)-\>mmap_lock, we either resolve the fault with

[VM_FAULT_RETRY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n751) if we did (in order to simply reacquire it and try again, if

haven’t retried once already) or with [VM_FAULT_OOM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n742) to indicate the out of mem-

ory condition.

If we succeed in this portion of the function, we move on to the post-

processing phase, as shown in Figure 9-7.







From Figure 9-6



Lock folio via

[lock_folio_maybe_drop_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2928)



yes

Go to retry_find in Figure 9-6 Truncated?

no

no

no

Invalidate locked? Up to date?

yes yes



Go to page_not_uptodate no

Index still valid? SIGBUS

in Figure 9-8

yes



Fault complete, set

[VM_FAULT_LOCKED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n750) flag



*Figure 9-7:* [*filemap_fault()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3084) *Post-Processing*



Here we must lock the folio to ensure it is stable and not undergoing up-

date or truncation. Since these operations can take a while to complete, we

will drop the [struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) lock if it is contended – this process

is performed by [lock_folio_maybe_drop_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2928).

After we have acquired the lock, we must now to see if anything changed

underneath us in the mean time – if it has, we retry folio lookup via the retry_find label (and acquiring the invalidation lock if not already held).

There is one specific edge case – where the folio is not ‘up to date’, i.e.

has not been fully retrieved from disk. This can either be due to the reada-head failing to retrieve data, or an error having occurred. We resolve this at

page_not_uptodate, described in Figure 9-8 below.

If the index of this folio in the file is not valid (i.e. truncation has oc-

curred and we have taken it into account, but simply discover our index falls off the end of the file), we send a SIGBUS signal to the process.

Finally if all is good, we complete the operation, indicating the folio is

locked via [VM_FAULT_LOCKED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n750)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n750)

We examine the case in which the folio is not up to date, from label

page_not_uptodate within [filemap_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3084) in Figure 9-8.







From Figure 9-7



Read folio from disk

via [filemap_read_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2382)



yes

[VM_FAULT_RETRY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n751) Dropped mmap_lock?

no



yes

Error? SIGBUS

no



Go to retry_find in Figure 9-6



*Figure 9-8:* [*filemap_fault()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3084) *Page Not Up To Date Handling*



This is relatively straightforward – we try to explicitly read the folio via

[filemap_read_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2382). Regardless of whether an error occurs, if we dropped

the [struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) we indicate that the fault should be tried via

[VM_FAULT_RETRY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n751) (dropping this lock might mean this mapping is simply not

even valid now).

If we did not drop the lock, we check whether an error arose – if so, the

SIGBUS signal is sent to the process, otherwise if all is good and the folio was

retrieved, we jump to the retry_find label described in Figure 9-6.

Now we have examining the function in brief, let’s examine

[filemap_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3084) in detail line-by-line, the initial part of which is shown in List-

ing 9-35.



3061 */\*\**

3062 *\* filemap_fault - read in file data for page fault handling* 3063 *\* @vmf:* *struct vm_fault containing details of the fault* 3064 *\**

3065 *\* filemap_fault() is invoked via the vma operations vector for a* 3066 *\* mapped memory region to read in file data during a page fault.* 3067 *\**

3068 *\* The goto's are kind of ugly, but this streamlines the normal case of having*

3069 *\* it in the page cache, and handles the special cases reasonably without* 3070 *\* having a lot of duplicated code.* 3071 *\**

3072 *\* vma-\>vm_mm-\>mmap_lock must be held on entry.* 3073 *\**

3074 *\* If our return value has VM_FAULT_RETRY set, it's because the mmap_lock* 3075 *\* may be dropped before doing I/O or by lock_folio_maybe_drop_mmap().*







3076 *\**

3077 *\* If our return value does not have VM_FAULT_RETRY set, the mmap_lock* 3078 *\* has not been released.* 3079 *\**

3080 *\* We never return with VM_FAULT_RETRY and a bit from VM_FAULT_ERROR set.* 3081 *\**

3082 *\* Return: bitwise-OR of %VM_FAULT\_ codes.* 3083 *\*/*

3084 **vm_fault_t filemap_fault**(**struct** vm_fault \*vmf) 3085 {

3086 **int** error;

3087 **struct** file \*file = vmf-\>vma-\>vm_file; 3088 **struct** file \*fpin = **NULL**; 3089 **struct** address_space \*mapping = file-\>f_mapping; 3090 **struct** inode \*inode = mapping-\>host; 3091 **pgoff_t** max_idx, index = vmf-\>pgoff; 3092 **struct** folio \*folio; 3093 **vm_fault_t** ret = 0; 3094 **bool** mapping_locked = **false**; 3095

3096 max_idx = **DIV_ROUND_UP**(**i_size_read**(inode), **PAGE_SIZE**); 3097 **if** (**unlikely**(index \>= max_idx)) 3098 **return VM_FAULT_SIGBUS**;



*Listing 9-35:* mm/filemap.c: [*filemap_fault()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3084) *Initialisation*



We begin by initialising variables, recalling from section 6.2 that an

[struct vm_fault](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n481) object threads fault state through the fault process, and we

return a [vm_fault_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n713) value indicating the outcome of the fault handling.

We determine the maximum exclusive index that can reference within the

file-backed mapping, max_idx by rounding up the size of the file (as indicated

by its [struct inode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593) obtained from [i_size_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n845) to the system [PAGE_SIZE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_types.h?h=v6.0#n11)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_types.h?h=v6.0#n11)

If the page offset into the file ([struct vm_fault-\>pgoff](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n481)) equals or exceeds

this the fault extends past the end of the file and we must return a SIGBUS

error, indicated by returning [VM_FAULT_SIGBUS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n743)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n743)

Next, we attempt to retrieve the folio from the page cache, as shown in

Listing 9-36.



3100 */\**

3101 *\* Do we have something in the page cache already?* 3102 *\*/*

3103 folio = **filemap_get_folio**(mapping, index); 3104 **if** (**likely**(folio)) { 3105 */\**

3106 *\* We found the page, so try async readahead before waiting*

*for*

3107 *\* the lock.* 3108 *\*/*

3109 **if** (!(vmf-\>flags & **FAULT_FLAG_TRIED**))







3110 fpin = **do_async_mmap_readahead**(vmf, folio); 3111 **if** (**unlikely**(!**folio_test_uptodate**(folio))) { 3112 **filemap_invalidate_lock_shared**(mapping); 3113 mapping_locked = **true**; 3114 }

3115 } **else** {

3116 */\* No page in the page cache at all \*/* 3117 **count_vm_event**(**PGMAJFAULT**); 3118 **count_memcg_event_mm**(vmf-\>vma-\>vm_mm, **PGMAJFAULT**); 3119 ret = **VM_FAULT_MAJOR**; 3120 fpin = **do_sync_mmap_readahead**(vmf); 3121 **retry_find**:

3122 */\**

3123 *\* See comment in filemap_create_folio() why we need* 3124 *\* invalidate_lock* 3125 *\*/*

3126 **if** (!mapping_locked) { 3127 **filemap_invalidate_lock_shared**(mapping); 3128 mapping_locked = **true**; 3129 }

3130 folio = **\_\_filemap_get_folio**(mapping, index, 3131 **FGP_CREAT**\|**FGP_FOR_MMAP**, 3132 vmf-\>gfp_mask); 3133 **if** (!folio) { 3134 **if** (fpin) 3135 **goto** out_retry; 3136 **filemap_invalidate_unlock_shared**(mapping); 3137 **return VM_FAULT_OOM**; 3138 }

3139 }



*Listing 9-36:* mm/filemap.c: [*filemap_fault()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3084) *Page Cache Retrieval*



We try to retrieve the folio from the page cache using [filemap_get_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n526)

(described in section 9.5 below), and determine what to do based on

whether we successfully retrieve a folio from the page cache or not.

A ‘major’ fault occurs when a process accesses memory mapped to data

which is not currently in memory at all, i.e. file-backed memory that does

not exist in the page cache currently, or anonymous memory which needs to

be swapped back in. In both cases, the major fault entails I/O.

A ‘minor’ fault on the other hand is a page fault which occurs when a

process accesses memory that exists in RAM but is simply not yet mapped

yet (i.e. new anonymous or shmem page private folios, or existing page

cache folios).

We can see this in action here, as should a folio not be present in the

page cache, we denote this by incrementing statistics for the [PGMAJFAULT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vm_event_item.h?h=v6.0#n37) event

type (minor faults can be determined by taking the count of [PGFAULT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vm_event_item.h?h=v6.0#n37) events

and subtracting it by the count of [PGMAJFAULT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vm_event_item.h?h=v6.0#n37) events).







**N O T E** Total page faults across the system can be determined via */proc/vmstat* in the *pgfault*

and *pgmajfault* entries which output the statistics for [*PGFAULT*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vm_event_item.h?h=v6.0#n37) and [*PGMAJFAULT*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/vm_event_item.h?h=v6.0#n37) respec-tively.

Note that these memory management level major fault counters are not the only ones

measuring major and minor faults, for instance each [*struct task_struct*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n727) maintains *min_flt* and *maj_flt* statistics, accessible via */proc/\$pid/stat* (or more conveniently

the [*ps*](https://man7.org/linux/man-pages/man1/ps.1.html) command), [*getrusage()*](https://man7.org/linux/man-pages/man2/getrusage.2.html)[,](https://man7.org/linux/man-pages/man2/getrusage.2.html) among others. In addition, statistics are accounted

for the [*perf*](https://man7.org/linux/man-pages/man1/perf.1.html) utility.

These values won’t perfectly align with the system-wide statistics as these are ac-

counted by [*mm_account_fault()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5077)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n5077) for instance a minor fault that had to be retried as

indicated by the [*FAULT_FLAG_TRIED*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n869) flag is considered a major fault.

See Section 6.2 for more details on page fault handling as a whole.



The simpler case is when the folio is present in the page cache – we do

not have to do anything further in order to back the memory. We do how-ever have to taken into account a couple of considerations.

Firstly, if this fault hasn’t just been retried (as indicated by the

[FAULT_FLAG_TRIED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n869) flag), we try to perform asynchronous readahead via

[do_async_mmap_readahead().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3037)

We test this flag because [FAULT_FLAG_TRIED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n869) is set when a previous attempt

at servicing this page fault relinquished the [struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486). If it had done, it would already have performed this step so we’d be duplicating work.

The asynchronous readahead performed in [do_async_mmap_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3037) will

try to read data we expect the user to access soon into the page cache, asyn-

chronously, naturally. We go into detail on how this functions in section 9.7.

Next we test to see if the folio is not up to date, i.e. does not have the

[PG_uptodate](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n103) flag set. This flag is set when data from disk has been read and the folio populated with it. However, since this folio already exists in the page cache, the only reason this could be the case is if an invalidation (e.g. the cache page no longer represents the file contents and must be updated) is occurring, as we have not yet locked the folio.

In this case, we acquire the [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)-\>invalidate_lock via

[filemap_invalidate_lock_shared()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n809) to synchronise against other invalidations and operations that might race with an invalidation. We set mapping_locked to true to know to release the lock later.

In the instance where no folio could be found in the page cache,

we update statistics to account for this fact (and set the return value to

[VM_FAULT_MAJOR](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n744) accordingly), before simply going ahead and perform-ing synchronous readahead in order to populate the page cache, via

[do_sync_mmap_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2968) (see Section 9.7 for details on what happens here).



**N O T E** Note that this readahead still may not actually retrieve the folio from the disk. For

instance, if a user specifies that a region of memory is random-access memory via

[*madvise()*](https://man7.org/linux/man-pages/man2/madvise.2.html) with the *MADV_RANDOM* flag set, this will cause readahead to abort. We will see below how we retrieve data in this instance.







This function, as well as the asynchronous readahead discussed above

returns a [struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) object, fpin. What does this value represent?

Performing I/O is a lengthy operation, so we prefer not to hold the

[struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) semaphore throughout as this can lead to con-

tention when another thread needs to acquire a write lock (this lock is a read-

write semaphore, so reads happen simultaneously, but writes are exclusive).

If we do so, we must maintain the file’s reference count in order to

ensure that it does not disappear from beneath us while the mmap_lock is

dropped. Therefore, each function which might drop this lock both accepts

and returns an fpin parameter.

The input fpin is checked to see if the file was already pinned (imply-

ing lock released), if not then [get_file()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n988) is called, which increments the

[struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940)-\>f_count reference count before returning the file object, which

is assigned to the local fpin variable.

Once the synchronous readahead is complete, we acquire the

[struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)-\>invalidate_lock via [filemap_invalidate_lock_shared()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n809) if

we had not already done so, and again mark mapping_locked to indicate we

have.

We do so, because we are about to invoke [\_\_filemap_get_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1914) with the

[FGP_CREAT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n502) flag set, indicating that we will create a new folio to be populated

from the disk, and must ensure that no race exists between the creation and

invalidation of the folio.



**N O T E** We will get into this logic in more detail in section 9.5 below, but note that if

[*\_\_filemap_get_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1914) allocates a new folio via [*filemap_alloc_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n955) and adds

it to the page cache via [*filemap_add_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n926), this will cause there to be a single refer-

ence count on the folio.

Therefore, if subsequent logic determines that this folio cannot satisfy the fault (e.g.

if file truncation raced with the fault), it will invoke [*folio_put()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1122) as part of cleanup

which result in the folio being freed.



We will have, most likely, retrieved the folio from disk in the synchronous

readahead above. However in cases where either an error occurred or reada-

head will otherwise not proceed, we may not have.

This can be due to an error or, for instance, the memory having been

marked random-access via [madvise()](https://man7.org/linux/man-pages/man2/madvise.2.html) with the MADV_RANDOM flag set (leading to

the [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) flag possessing the [VM_RAND_READ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n287) flag). In this

case readahead is simply never performed.

Regardless, we must be able to retrieve the folio, whether it is located

from the readahead operation or if it is a freshly allocated one which is not

yet marked up to date (we will consider how to actually retrieve this data in

the discussion around listing 9-37 below.

If we cannot retrieve a folio as needed in [\_\_filemap_get_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1914), even

though [FGP_CREAT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n502) dictates that one should be created if we cannot find an

existing folio, then an out of memory condition has occurred.

If we have taken an fpin, indicating the lock is dropped, we can have the

fault be retried, by which point more memory might be available by includ-







ing the [VM_FAULT_RETRY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n751) flag in the return value (this is handled at the out_retry label, described below).

Otherwise we simply return [VM_FAULT_OOM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n742) indicating an out of memory

condition has occurred and the fault cannot proceed.

After each of these cases are considered, we have post-processing to per-

form, shown in Listing 9-37.



3141 **if** (!**lock_folio_maybe_drop_mmap**(vmf, folio, &fpin)) 3142 **goto out_retry**; 3143

3144 */\* Did it get truncated? \*/* 3145 **if** (**unlikely**(folio-\>mapping != mapping)) { 3146 **folio_unlock**(folio); 3147 **folio_put**(folio); 3148 **goto retry_find**; 3149 }

3150 **VM_BUG_ON_FOLIO**(!**folio_contains**(folio, index), folio); 3151

3152 */\**

3153 *\* We have a locked page in the page cache, now we need to check* 3154 *\* that it's up-to-date. If not, it is going to be due to an error.*

3155 *\*/*

3156 **if** (**unlikely**(!**folio_test_uptodate**(folio))) { 3157 */\**

3158 *\* The page was in cache and uptodate and now it is not.* 3159 *\* Strange but possible since we didn't hold the page lock all*

3160 *\* the time. Let's drop everything get the invalidate lock and*

3161 *\* try again.* 3162 *\*/*

3163 **if** (!mapping_locked) { 3164 **folio_unlock**(folio); 3165 **folio_put**(folio); 3166 **goto retry_find**; 3167 }

3168 **goto page_not_uptodate**; 3169 }

3170

3171 */\**

3172 *\* We've made it this far and we had to drop our mmap_lock, now is the*

3173 *\* time to return to the upper layer and have it re-find the vma and*

3174 *\* redo the fault.* 3175 *\*/*

3176 **if** (fpin) {

3177 **folio_unlock**(folio); 3178 **goto out_retry**; 3179 }

3180 **if** (mapping_locked) 3181 **filemap_invalidate_unlock_shared**(mapping);







3182

3183 */\**

3184 *\* Found the page and have a reference on it.* 3185 *\* We must recheck i_size under page lock.* 3186 *\*/*

3187 max_idx = **DIV_ROUND_UP**(**i_size_read**(inode), **PAGE_SIZE**); 3188 **if** (**unlikely**(index \>= max_idx)) { 3189 **folio_unlock**(folio); 3190 **folio_put**(folio); 3191 **return VM_FAULT_SIGBUS**; 3192 }

3193

3194 vmf-\>page = **folio_file_page**(folio, index); 3195 **return** ret \| **VM_FAULT_LOCKED**;



*Listing 9-37:* mm/filemap.c: [*filemap_fault()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3084) *Post-Processing*



Firstly, we must lock the folio before we can return it to the generic

fault handler logic. we do this via [lock_folio_maybe_drop_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2928)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2928) If the fo-

lio is already locked due to I/O currently occurring on the underlying fo-

lio, this function attempts to release the [struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) via

[maybe_unlock_mmap_for_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n607). Either way it tries to acquire the lock (waiting if

necessary).

If it succeeds we continue, otherwise we attempt to retry the fault, re-

turning [VM_FAULT_RETRY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n751) (see listing 9-39 below).

We examine this function in detail as well as folio locking as a hole in

section 9.11 below.

Now we have the folio locked, we can check for certain to determine

whether the folio is in a good, stable state. We start by determining whether

it was truncated, i.e. the file size having reduced, rendering this folio no

longer part of this file mapping.

By convention, this will be indicated by the [struct folio-\>mapping](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) field

being set to NULL (for instance in [page_cache_delete()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n124)).

Any change to this field has to be performed under the folio lock, so by

now possessing it we can be certain that it will remain stable.

Since it may also in theory have had its mapping reassigned since being

truncated, we simply check to see if the mapping remains the same as be-

fore. If not – we unlock and reduce the folio’s reference count and try find-

ing it/creating it again at retry_find in listing 9-36 above, this time certainly

establishing the invalidation lock.

We perform a CONFIG_DEBUG_VM sanity check to ensure the folio does in-

deed sit at the expected index via [folio_contains()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n698)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n698)

Next, we determine if this folio is actually up to date with the disk (i.e.

possessing the folio flag [PG_uptodate](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n103)). Despite the rather misleading com-

ment suggesting only an ‘error’ might have caused this, other conditions

can cause, as determined in [do_sync_mmap_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2968) – for instance the user

having specified the region as being random access using [madvise()](https://man7.org/linux/man-pages/man2/madvise.2.html) with the

MADV_RANDOM flag, or repeated cache misses.







If the folio is indeed not up to date, we first check to see whether we held

the invalidation lock [(](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)[struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)-\>invalidate_lock). If not, then we retry the operation with this held to account for races by unlocking and re-ducing the reference count on the folio and jumping to retry_find (see list-

ing 9-37 above).

Otherwise, if we have the lock held, we force the issue and proactively

attempt to read the folio from disk at label page_not_uptodate, discussed below

listing 9-38. This will retry the operation when done.

At this stage we have the correct folio. If we dropped the

[struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) to reach this point, it is no longer for certain that the virtual mapping still exists, so we have to inform the generic fault han-

dler that we must retry the fault by returning [VM_FAULT_RETRY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n751)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n751) We do this by

unlocking the folio and jumping to out_retry, described in listing 9-39 de-scribed below.

Now we are sure the folio is as we expect, we drop the invalidate lock via

[filemap_invalidate_unlock_shared()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n820).

We must perform one final check before we can resolve the page fault –

check that the index of the faulting folio still resides within the size of the file, in case it had been truncated prior to the folio being locked.

If this is the case, we unlock the folio, decrement its reference count and

return [VM_FAULT_SIGBUS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n743), indicating that a SIGBUS signal should be sent to the process.

Finally, we have the correct folio and can resolve the page fault. We look

up the sub-page within the folio relating to its index via [folio_file_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n680)

and set this as the [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) to resolve the fault, returning with the

[VM_FAULT_LOCKED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n750) flag set to indicate the folio is locked.

Next we examine the edge case handling within the code, shown in List-

ing 9-38.



3197 **page_not_uptodate**:

3198 */\**

3199 *\* Umm, take care of errors if the page isn't up-to-date.* 3200 *\* Try to re-read it \_once\_. We do this synchronously,* 3201 *\* because there really aren't any performance issues here* 3202 *\* and we need to check for errors.* 3203 *\*/*

3204 fpin = **maybe_unlock_mmap_for_io**(vmf, fpin); 3205 error = **filemap_read_folio**(file, mapping-\>a_ops-\>read_folio, folio); 3206 **if** (fpin)

3207 **goto out_retry**; 3208 **folio_put**(folio); 3209

3210 **if** (!error \|\| error == **AOP_TRUNCATED_PAGE**) 3211 **goto retry_find**; 3212 **filemap_invalidate_unlock_shared**(mapping); 3213

3214 **return VM_FAULT_SIGBUS**;







*Listing 9-38:* mm/filemap.c: [*filemap_fault()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3084) *Page Not Up to Date Case*



This case is only reached if, in listing 9-37 described above, the folio is

not up to date but the invalidate lock, [struct address_space-\>invalidate_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424),

is held. This indicates that no readahead was performed (for instance the

memory is marked random-access or an error arose), and therefore the folio

must be read directly.

Before attempting I/O again, we try to unlock [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)-\>mmap_lock

in order to prevent the virtual address space becoming functionally read-

only throughout the operation via [maybe_unlock_mmap_for_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n607) (see listing 6-

41).

After this is done, we directly attempt to read the data into the folio

via [filemap_read_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2382) (see Listing 9-56), which wraps the file system-

specified [struct address_space-\>a_ops-\>read_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) function (part of the

[struct address_space_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n356) set of callbacks), clearing errors and check-

ing that the folio is up to date after the retry. It does this synchronously,

waiting for the folio to become unlocked by the read operation via

[folio_wait_locked_killable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1028).

See Section 9.6 for a detailed exploration of this function and reading

folios from disk into the page cache in general. See Section 9.11 for details

of how the waiting logic functions.

In the case that we dropped the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)-\>mmap_lock as indicated

by fpin being set, we jump to the out_retry label (discussed after listing 9-39

below) and indicate to the generic fault handler that we wish to retry the

fault, having now read the required folio into the page cache or observed

an error we can retry avoiding (again, we must do this in either case qas the

mapping itself may no longer exist).

If we maintained the lock, we unpin the folio via [folio_put()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1122)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1122) then

check to determine whether an error arose – if none did, or it was an

[AOP_TRUNCATED_PAGE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n300) error indicating the folio may have simply been truncated,

we jump to the retry_find label shown in listing 9-36 discussed above.

Finally we are at a point where an error has occurred that we cannot re-

cover from, so we drop the invalidate lock and indicate the calling process

should receive the SIGBUS signal by returning [VM_FAULT_SIGBUS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n743) since this is an

invalid access.

The final edge case is shown in Listing 9-39.



3216 **out_retry**:

3217 */\**

3218 *\* We dropped the mmap_lock, we need to return to the fault handler to*

3219 *\* re-find the vma and come back and find our hopefully still*

*populated*

3220 *\* page.*

3221 *\*/*

3222 **if** (folio)

3223 **folio_put**(folio); 3224 **if** (mapping_locked)







3225 **filemap_invalidate_unlock_shared**(mapping); 3226 **if** (fpin)

3227 **fput**(fpin); 3228 **return** ret \| **VM_FAULT_RETRY**; 3229 }



*Listing 9-39:* mm/filemap.c: [*filemap_fault()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3084) *Retry Case*



To reach this point, we will have dropped the [struct mm_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486)-\>mmap_lock.

As a result, the faulting memory may have changed beneath us and there-fore the fault cannot continue and must be retried.

Firstly, we unwind our pinned folio by reducing its refer-

ence count via [folio_put()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1122), drop the invalidate lock if held via

[filemap_invalidate_unlock_shared()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n820), and remove the pin on the [struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) via

[fput()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/file_table.c?h=v6.0#n374).

We then return with the [VM_FAULT_RETRY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n751) flag set to indicate that the fault

must be retried.



**9.5 Reading Page Cache Entries**



There are a number of routes by which we read folios from the page cache. Each differs in whether we attempt only to read from the page cache, i.e. in-dicating that an entry was not found if it was not already present there, or into the page cache where, if not already present, we read a folio from disk into the page cache and return this.

In addition we may also choose to read from the page cache, creating

a page cache entry which we mark as not ’uptodate’ (i.e. not yet read from disk) but not proceeding with the read just yet. Examining each case:



**Reading a batch of folios from the page cache** In instances where we

do not want to read into the page cache but rather only from it (in-dicating missing entries if not present), we use functions such as

[filemap_get_folios()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2149), [find_get_entries()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2056) and [find_lock_entries()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2093). These functions simply do not return non-present entries. We examine this in

Section 9.5.1 below.

**Reading a batch of folios into the page cache** In instances where we need

to read a batch of folios from the page cache if already present or from

disk into the page cache if not, we utilise the [filemap_get_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2546) func-

tion, used by [filemap_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2626) described in Section 9.3 above, reads folios in a specified range from the page cache and if not present, reads them from disk, performing readahead as necessary. We describe this in Sec-

tion 9.5.2 below.

**Reading a single folio from the page cache** The [filemap_get_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n526) func-

tion simply checks to see if the folio is present in the cache, retrieving

it if so, returning an error if not. This wraps [\_\_filemap_get_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1914), pass-ing no flags, a function which is also invoked directly elsewhere. In in-

stances where the FGP_CREAT flag is passed to [\_\_filemap_get_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1914)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1914) a folio is allocated in the instance none exist in the page cache and this newly







allocated folio is added to the page cache. It will not be marked up to date, so still needs to be read from disk to be usable. This is examined in

Section 9.5.3 below.

**Reading a single folio into the page cache** A number of filesystem, driver

and other kernel components need to read individual folios from the

page cache, ultimately invoking [do_read_cache_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3472) to do so, which we

examine in Section 9.5.4.



Finally, we examine the actual mechanism of adding a folio to the page

cache in Section 12.2.1.

The functions which actually perform the read from disk are examined

in Section 9.6, and readahead is described in Section 9.7.



***9.5.1 Reading a Batch of Folios From the Page Cache***

Often we simply need to retrieve folios from the page cache for present en-

tries, i.e. entries that already exist within the page cache having already been

read from disk. This is what [find_get_entries()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2056) accomplishes, shown in List-

ing 9-40.



2036 */\*\**

2037 *\* find_get_entries - gang pagecache lookup* 2038 *\* @mapping:* *The address_space to search* 2039 *\* @start:* *The starting page cache index* 2040 *\* @end:* *The final page index (inclusive).* 2041 *\* @fbatch:* *Where the resulting entries are placed.* 2042 *\* @indices:* *The cache indices corresponding to the entries in @entries* 2043 *\**

2044 *\* find_get_entries() will search for and return a batch of entries in* 2045 *\* the mapping. The entries are placed in @fbatch. find_get_entries()* 2046 *\* takes a reference on any actual folios it returns.* 2047 *\**

2048 *\* The entries have ascending indexes. The indices may not be consecutive*

2049 *\* due to not-present entries or large folios.* 2050 *\**

2051 *\* Any shadow entries of evicted folios, or swap entries from* 2052 *\* shmem/tmpfs, are included in the returned array.* 2053 *\**

2054 *\* Return: The number of entries which were found.* 2055 *\*/*

2056 **unsigned find_get_entries**(**struct** address_space \*mapping, **pgoff_t** start, 2057 **pgoff_t** end, **struct** folio_batch \*fbatch, **pgoff_t** \*indices) 2058 {

2059 **XA_STATE**(xas, &mapping-\>i_pages, start); 2060 **struct** folio \*folio; 2061

2062 **rcu_read_lock**();

2063 **while** ((folio = **find_get_entry**(&xas, end, **XA_PRESENT**)) != **NULL**) {







2064 indices\[fbatch-\>nr\] = xas.xa_index; 2065 **if** (!**folio_batch_add**(fbatch, folio)) 2066 **break**; 2067 }

2068 **rcu_read_unlock**(); 2069

2070 **return folio_batch_count**(fbatch); 2071 }



*Listing 9-40:* mm/filemap.c: [*find_get_entries()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2056)



This function walks through the page cache entry’s xarray (as located

in [struct address_space-\>i_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)), locating all folios in the page range start to end inclusive, i.e. all present folios containing the pages within the specified range in the page cache entry. It places these folios into the

[struct folio_batch](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n83) in fbatch up to the maximum folio batch size [(](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n15)[PAGEVEC_SIZE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n15), i.e. 15 folios), containing up to this many folios.

Since we may end up processing non-present folios in the range, we also

need a means of indicating which page offsets each of the batch entries refer

to, so a pointer to an array of pointer offsets of size [PAGEVEC_SIZE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n15) is passed in indices for this purpose.

Each entry is located using [find_get_entry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2001)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2001) with the state of the xar-

ray walk threaded through via the [struct xa_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1326) value xas, initialised via

[XA_STATE().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1368)

The function also returns ‘exceptional’ entries, these are value rather

than pointer entries which indicate that a folio has since been removed,

which can be tested for via [xa_is_value()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n79) which the caller is expected to han-

dle. The whole operation is performed under an [RCU](https://kernel.org/doc/html/v6.0/RCU/rcu.html) lock which protects against other threads manipulating the folio in the interim.

Every folio that it does find has its reference count incremented before

being returned.

We examine [find_get_entry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2001) in Listing 9-41.



2001 **static inline struct** folio \***find_get_entry**(**struct** xa_state \*xas, **pgoff_t** max, 2002 xa_mark_t mark) 2003 {

2004 **struct** folio \*folio; 2005

2006 **retry**:

2007 **if** (mark == **XA_PRESENT**) 2008 folio = **xas_find**(xas, max); 2009 **else**

2010 folio = **xas_find_marked**(xas, max, mark); 2011

2012 **if** (**xas_retry**(xas, folio)) 2013 **goto retry**; 2014 */\**

2015 *\* A shadow entry of a recently evicted page, a swap* 2016 *\* entry from shmem/tmpfs or a DAX entry. Return it*







2017 *\* without attempting to raise page count.* 2018 *\*/*

2019 **if** (!folio \|\| **xa_is_value**(folio)) 2020 **return** folio; 2021

2022 **if** (!**folio_try_get_rcu**(folio)) 2023 **goto reset**; 2024

2025 **if** (**unlikely**(folio != **xas_reload**(xas))) { 2026 **folio_put**(folio); 2027 **goto reset**; 2028 }

2029

2030 **return** folio;

2031 **reset**:

2032 **xas_reset**(xas);

2033 **goto retry**;

2034 }



*Listing 9-41:* mm/filemap.c: [*find_get_entry()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2001)



Though this function can be used to look up entries with specific xarray

marks via [xas_find_marked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/xarray.c?h=v6.0#n1308)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/xarray.c?h=v6.0#n1308) we exclusively consider the case where mark is set

to [XA_PRESENT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n254)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n254) i.e. looking up present folios.

The remainder of the logic resembles that of [filemap_get_read_batch()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2346)

shown in Listing 9-47 above, though most closely matches that of

[mapping_get_entry(). ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1850)In order to avoid repeating ourselves, we defer our de-

scription of this logic to the discussion around Listing in Listing 9-52 below,

and the associated discussion around Listing 9-51 describing the lockless

page cache protocol as a whole.

In the instance where we wish to retrieve folios in this fashion

but also lock them, further effort is required, which is provided in

[find_lock_entries(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2093)shown in Listing 9-42 below. This is utilised by

the cache dropping logic discussed in Section 9.9.4, in the function

[invalidate_mapping_pagevec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n502) shown in Listing 9-116.



2073 */\*\**

2074 *\* find_lock_entries - Find a batch of pagecache entries.* 2075 *\* @mapping:* *The address_space to search.* 2076 *\* @start:* *The starting page cache index.* 2077 *\* @end:* *The final page index (inclusive).* 2078 *\* @fbatch:* *Where the resulting entries are placed.* 2079 *\* @indices:* *The cache indices of the entries in @fbatch.* 2080 *\**

2081 *\* find_lock_entries() will return a batch of entries from @mapping.* 2082 *\* Swap, shadow and DAX entries are included. Folios are returned* 2083 *\* locked and with an incremented refcount. Folios which are locked* 2084 *\* by somebody else or under writeback are skipped. Folios which are* 2085 *\* partially outside the range are not returned.*







2086 *\**

2087 *\* The entries have ascending indexes. The indices may not be consecutive*

2088 *\* due to not-present entries, large folios, folios which could not be* 2089 *\* locked or folios under writeback.* 2090 *\**

2091 *\* Return: The number of entries which were found.* 2092 *\*/*

2093 **unsigned find_lock_entries**(**struct** address_space \*mapping, **pgoff_t** start, 2094 **pgoff_t** end, **struct** folio_batch \*fbatch, **pgoff_t** \*indices) 2095 {

2096 **XA_STATE**(xas, &mapping-\>i_pages, start); 2097 **struct** folio \*folio; 2098

2099 **rcu_read_lock**();

2100 **while** ((folio = **find_get_entry**(&xas, end, **XA_PRESENT**))) { 2101 **if** (!**xa_is_value**(folio)) { 2102 **if** (folio-\>index \< start) 2103 **goto put**; 2104 **if** (folio-\>index + **folio_nr_pages**(folio) - 1 \> end) 2105 **goto put**; 2106 **if** (!**folio_trylock**(folio)) 2107 **goto put**; 2108 **if** (folio-\>mapping != mapping \|\| 2109 **folio_test_writeback**(folio)) 2110 **goto unlock**; 2111 **VM_BUG_ON_FOLIO**(!**folio_contains**(folio, xas.xa_index), 2112 folio); 2113 }

2114 indices\[fbatch-\>nr\] = xas.xa_index; 2115 **if** (!**folio_batch_add**(fbatch, folio)) 2116 **break**; 2117 **continue**; 2118 **unlock**:

2119 **folio_unlock**(folio); 2120 **put**:

2121 **folio_put**(folio); 2122 }

2123 **rcu_read_unlock**(); 2124

2125 **return folio_batch_count**(fbatch); 2126 }



*Listing 9-42:* mm/filemap.c: [*find_lock_entries()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2093)



This function behaves similarly to [find_get_entries()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2056)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2056) only additionally

locking folios it finds (but not waiting on the lock, merely optimistically at-tempting to acquire the lock for each folio). As with that function, we must return page offset indices as we may skip over non-present folios, or en-







counter compound folios which span multiple pages. We of course incre-

ment the reference count of all folios we do find.

[find_lock_entries()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2093) is invoked from callers where the folio is compound,

so we must be careful to ensure that each folio we retrieve is actually within

the specified range (from the page offset start to end inclusive) by testing

that each [struct folio-\>index](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) is within the required range and does not span

beyond it.

Importantly, we do not wait for the folio to be locked, only speculatively

attempt to acquire it via [folio_trylock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n900). If the folio is already locked, we skip

it.

Once safely locked, we must ensure that the folio has not been truncated

or since reallocated and attached to another page cache entry by comparing

[struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256)-\>mapping to mapping. In addition, we do not return folios under

writeback (see the writeback chapter for details)

Finally, before adding folios to the batch, we perform a CONFIG_DEBUG_VM

sanity check to ensure the folio has the correct index.

In [filemap_get_folios()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2149) we retrieve folios in a similar fashion to

[find_get_entry(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2001)only we do not return indices, skip exceptional values and

update the start parameter (which is a pointer in this instance) to the start

of the next folio to be examined once the batch is full.

Unlike [find_lock_entries()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2093)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2093) we permit folios to overhang the start and be-

ginning of the input range. This function is shown in Listing 9-43 (eliding

out of scope hugetlb logic).



2128 */\*\**

2129 *\* filemap_get_folios - Get a batch of folios* 2130 *\* @mapping:* *The address_space to search* 2131 *\* @start:* *The starting page index* 2132 *\* @end:* *The final page index (inclusive)* 2133 *\* @fbatch:* *The batch to fill.* 2134 *\**

2135 *\* Search for and return a batch of folios in the mapping starting at* 2136 *\* index @start and up to index @end (inclusive). The folios are returned*

2137 *\* in @fbatch with an elevated reference count.* 2138 *\**

2139 *\* The first folio may start before @start; if it does, it will contain* 2140 *\* @start. The final folio may extend beyond @end; if it does, it will* 2141 *\* contain @end. The folios have ascending indices. There may be gaps* 2142 *\* between the folios if there are indices which have no folio in the* 2143 *\* page cache. If folios are added to or removed from the page cache* 2144 *\* while this is running, they may or may not be found by this call.* 2145 *\**

2146 *\* Return: The number of folios which were found.* 2147 *\* We also update @start to index the next folio for the traversal.* 2148 *\*/*

2149 **unsigned filemap_get_folios**(**struct** address_space \*mapping, **pgoff_t** \*start, 2150 **pgoff_t** end, **struct** folio_batch \*fbatch) 2151 {







2152 **XA_STATE**(xas, &mapping-\>i_pages, \*start); 2153 **struct** folio \*folio; 2154

2155 **rcu_read_lock**();

2156 **while** ((folio = **find_get_entry**(&xas, end, **XA_PRESENT**)) != **NULL**) { 2157 */\* Skip over shadow, swap and DAX entries \*/* 2158 **if** (**xa_is_value**(folio)) 2159 **continue**; 2160 **if** (!**folio_batch_add**(fbatch, folio)) { 2161 **unsigned long** nr = **folio_nr_pages**(folio);

. . .

2165 \*start = folio-\>index + nr; 2166 **goto out**; 2167 }

2168 }

2169

2170 */\**

2171 *\* We come here when there is no page beyond @end. We take care to not*

2172 *\* overflow the index @start as it confuses some of the callers. This*

2173 *\* breaks the iteration when there is a page at index -1 but that is*

2174 *\* already broken anyway.* 2175 *\*/*

2176 **if** (end == (**pgoff_t**)-1) 2177 \*start = (**pgoff_t**)-1; 2178 **else**

2179 \*start = end + 1; 2180 **out**:

2181 **rcu_read_unlock**(); 2182

2183 **return folio_batch_count**(fbatch); 2184 }



*Listing 9-43:* mm/filemap.c: [*filemap_get_folios()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2149)

This function resembles those that we have examined already so we

won’t belabour the point by going over the logic once again, though do note the careful handling of the case where no page exists beyond end.

There are other variants on the theme of these lookup functions like

[find_get_pages_contig()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2210) and [find_get_pages_range_tag()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2272)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2272) however they broadly resemble what we have already examined so what we have discussed so far should suffice to underline the general mechanisms by which folios are found in the page cache.



***9.5.2 Reading a Batch of Folios Into the Page Cache***

We start by examining [filemap_get_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2546) in Listing 9-44 (eliding out-of-

scope iouring-specific [IOCB_WAITQ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n336) handling), which is used by [filemap_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2626)

(see Section 9.3 and Listing 9-30) to retrieve a batch of folios from the page cache.







2546 **static int filemap_get_pages**(**struct** kiocb \*iocb, **struct** iov_iter \*iter, 2547 **struct** folio_batch \*fbatch) 2548 {

2549 **struct** file \*filp = iocb-\>ki_filp; 2550 **struct** address_space \*mapping = filp-\>f_mapping; 2551 **struct** file_ra_state \*ra = &filp-\>f_ra; 2552 **pgoff_t** index = iocb-\>ki_pos \>\> **PAGE_SHIFT**; 2553 **pgoff_t** last_index; 2554 **struct** folio \*folio; 2555 **int err** = 0;

2556

2557 last_index = **DIV_ROUND_UP**(iocb-\>ki_pos + iter-\>count, **PAGE_SIZE**); 2558 **retry**:

2559 **if** (**fatal_signal_pending**(current)) 2560 **return**-EINTR; 2561

2562 **filemap_get_read_batch**(mapping, index, last_index, fbatch); 2563 **if** (!**folio_batch_count**(fbatch)) { 2564 **if** (iocb-\>ki_flags & **IOCB_NOIO**) 2565 **return**-**EAGAIN**; 2566 **page_cache_sync_readahead**(mapping, ra, filp, index, 2567 last_index - index); 2568 **filemap_get_read_batch**(mapping, index, last_index, fbatch); 2569 }

2570 **if** (!**folio_batch_count**(fbatch)) { 2571 **if** (iocb-\>ki_flags & (**IOCB_NOWAIT** \| **IOCB_WAITQ**)) 2572 **return**-**EAGAIN**; 2573 **err** = **filemap_create_folio**(filp, mapping, 2574 iocb-\>ki_pos \>\> **PAGE_SHIFT**, fbatch); 2575 **if** (**err** == **AOP_TRUNCATED_PAGE**) 2576 **goto retry**; 2577 **return err**; 2578 }

2579

2580 folio = fbatch-\>folios\[**folio_batch_count**(fbatch) - 1\]; 2581 **if** (**folio_test_readahead**(folio)) { 2582 **err** = **filemap_readahead**(iocb, filp, mapping, folio, last_index

);

2583 **if** (**err**)

2584 **goto err**; 2585 }

2586 **if** (!**folio_test_uptodate**(folio)) {

. . .

2590 **err** = **filemap_update_page**(iocb, mapping, iter, folio); 2591 **if** (**err**)

2592 **goto err**; 2593 }







2594

2595 **return** 0;

2596 **err**:

2597 **if** (**err** \< 0)

2598 **folio_put**(folio); 2599 **if** (**likely**(--fbatch-\>nr)) 2600 **return** 0; 2601 **if** (**err** == **AOP_TRUNCATED_PAGE**) 2602 **goto retry**; 2603 **return err**;

2604 }



*Listing 9-44:* mm/filemap.c: [*filemap_get_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2546)



We determine the range of pages we need to read based on the

[struct kiocb](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n341) parameter iocb (see Section 9.3 for more details on this type— it is in effect used to transmit state threaded through the iterator operation).

We use the [struct kiocb-\>ki_pos](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n341) field to determine our position within

the file, shifted by [PAGE_SHIFT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/page_types.h?h=v6.0#n10) to determine the base page index from which we must read, and place this in the index variable.

The whole read operation is ultimately controlled by the [struct iov_iter](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/uio.h?h=v6.0#n38)

object, from which we can determine the number of bytes remaining to be

read from the [struct iov_iter-\>count](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/uio.h?h=v6.0#n38) field.

We use this to calculate the inclusive upper bound of the page index via

[DIV_ROUND_UP()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/math.h?h=v6.0#n37) (noting that if the index is offset into a folio, we will obtain the full folio).



**N O T E** A consequence of this is that if the iterator range is page-aligned, we also read the

folio after the last requested. So for instance, if we try to read a single page, we will actually read two pages, not one.



At this point we have a starting point within the [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) ob-

ject for this page cache entry, index, and an inclusive upper bound on the range we wish to read in last_index and are ready to retrieve associated folios

and place them into the [struct folio_batch](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n83) object, fbatch (see Section 11.7 for more on folio batches).

Before we proceed with this operation, we check to see whether a fatal

signal is pending for the process before we potentially perform any I/O via

readahead (see Section 9.7). If so we exit early, specifying the-EINTR error code.

We perform the actual read of page cache pages via

[filemap_get_read_batch()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2346) which we shall examine below in Listing 9-47.

We check to see whether we retrieved any folios via [folio_batch_count()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n106)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n106)

if not then we try to perform synchronous readahead via

[page_cache_sync_readahead() , ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1210)unless the [IOCB_NOIO](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n337) flag has been specified for the iterator, indicating that I/O is not permitted (used by some spe-cific file systems for scenarios where this is appropriate)—in this case we simply return the EAGAIN error to indicate I/O was requested so repeat the operation.







This function unconditionally reads ahead at least a single

page, even if the read is performed in random-access mode (unlike

[do_sync_mmap_readahead() ), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2968)so we should obtain at least a single folio when we

invoke [filemap_get_read_batch()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2346) again. See Section 9.7 for an exploration of

readahead in general.

Afterwards we encounter a slightly tricky edge case, where we fail to re-

trieve folios even after synchronous readahead:



**Check whether we did in fact retrieve any folios after readahead**

Readahead may fail due to either the system simply being out of mem-ory (it may even be in the midst of servicing an OOM killer event), or

the allocation GFP flags (see Section 2.6 for more on this) did not per-mit an allocation to occur. In addition, extreme memory pressure even

without OOM may have prevented an allocation, for instance if [GFP_NOFS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n337) was specified, but the allocation would require file system access. In these circumstances, there can be significant races between freeing of memory and an attempt at reading it.

**If readahead failed, non-blocking case** We will have to perform I/O so

we start by checking whether [IOCB_NOWAIT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n328) (or the out-of-scope io_uring-

specified [IOCB_WAITQ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n336)) flags are specified, in which case we return the EAGAIN error code to indicate that we would block in instances where that’s not permitted.

**Last-ditch attempt to read data** At this point we are under serious

memory pressure, so we simply try to directly read in a folio, via

[filemap_create_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2489) which both allocates a folio to read the data into and goes ahead and reads it from disk.

**Check for truncation** If [filemap_create_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2489) returns [AOP_TRUNCATED_PAGE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n300) this

indicates that the folio might have been truncated. In this case we jump back to the retry label and attempt the operation again.

**Exit** Finally the readahead failure handling logic exits indicating whether an

error occurred. We have done our best—attempting to retrieve a single folio.



We examine [filemap_create_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2489) in Listing 9-45 below.



2489 **static int filemap_create_folio**(**struct** file \*file, 2490 **struct** address_space \*mapping, **pgoff_t** index, 2491 **struct** folio_batch \*fbatch) 2492 {

2493 **struct** folio \*folio; 2494 **int error**;

2495

2496 folio = **filemap_alloc_folio**(**mapping_gfp_mask**(mapping), 0); 2497 **if** (!folio)

2498 **return**-**ENOMEM**; 2499

2500 */\**







2501 *\* Protect against truncate / hole punch. Grabbing invalidate_lock*

2502 *\* here assures we cannot instantiate and bring uptodate new* 2503 *\* pagecache folios after evicting page cache during truncate* 2504 *\* and before actually freeing blocks. Note that we could* 2505 *\* release invalidate_lock after inserting the folio into* 2506 *\* the page cache as the locked folio would then be enough to* 2507 *\* synchronize with hole punching. But there are code paths* 2508 *\* such as filemap_update_page() filling in partially uptodate* 2509 *\* pages or -\>readahead() that need to hold invalidate_lock* 2510 *\* while mapping blocks for IO so let's hold the lock here as* 2511 *\* well to keep locking rules simple.* 2512 *\*/*

2513 **filemap_invalidate_lock_shared**(mapping); 2514 **error** = **filemap_add_folio**(mapping, folio, index, 2515 **mapping_gfp_constraint**(mapping, **GFP_KERNEL**)); 2516 **if** (**error** == -**EEXIST**) 2517 **error** = **AOP_TRUNCATED_PAGE**; 2518 **if** (**error**)

2519 **goto error**; 2520

2521 **error** = **filemap_read_folio**(file, mapping-\>a_ops-\>read_folio, folio); 2522 **if** (**error**)

2523 **goto error**; 2524

2525 **filemap_invalidate_unlock_shared**(mapping); 2526 **folio_batch_add**(fbatch, folio); 2527 **return** 0;

2528 **error**:

2529 **filemap_invalidate_unlock_shared**(mapping); 2530 **folio_put**(folio); 2531 **return error**;

2532 }



*Listing 9-45:* mm/filemap.c: [*filemap_create_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2489)



We start by allocating a folio via [filemap_alloc_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n955)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n955) return-

ing an out of memory error if we are unable to do so. After this we perform some careful juggling with locking around invalidation via

[filemap_invalidate_lock_shared()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n809), before adding the newly created folio to

the page cache via [filemap_add_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n926) which we examine in Listing 9-54 and

Section 12.2.1.

If we unable to add the folio to the page cache we exit with an error, ex-

plicitly indicating whether this was a duplicate entry caused by truncation via

[AOP_TRUNCATED_PAGE .](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n300)

Finally we perform the actual read from disk via [filemap_read_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2382)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2382) a

function we examine in detail in Section 9.6 and Listing 9-56 below.

Returning to [filemap_get_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2546)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2546) once we have handled this edge case, we

proceed with the usual case—the batch returned by [filemap_get_read_batch()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2346)







contains specific additional information in the final folio in the batch, as this

might either be the last folio before which further readahead is required, or

the last folio before which folios are not up to date with the disk, in which

case the folios need to be read from disk.

In the first case, [filemap_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2534) is performed, see Section 9.7 and

Listing 9-67 for an exploration of this.

In the second case, [filemap_update_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2434) is performed, which we exam-

ine in Listing 9-46 below (eliding out of scope io_uring-specific logic and

distracting no wait handling):



2434 **static int filemap_update_page**(**struct** kiocb \*iocb, 2435 **struct** address_space \*mapping, **struct** iov_iter \*iter, 2436 **struct** folio \*folio) 2437 {

2438 **int** error;

. . .

2444 **filemap_invalidate_lock_shared**(mapping);

. . .

2447 **if** (!**folio_trylock**(folio)) {

. . .

2452 **filemap_invalidate_unlock_shared**(mapping); 2453 */\** 2454 *\* This is where we usually end up waiting for a* 2455 *\* previously submitted readahead to finish.* 2456 *\*/* 2457 **folio_put_wait_locked**(folio, **TASK_KILLABLE**); 2458 **return AOP_TRUNCATED_PAGE**;

. . .

2463 }

2464

2465 error = **AOP_TRUNCATED_PAGE**; 2466 **if** (!folio-\>mapping) 2467 **goto unlock**; 2468

2469 error = 0;

2470 **if** (**filemap_range_uptodate**(mapping, iocb-\>ki_pos, iter, folio)) 2471 **goto unlock**;

. . .

2477 error = **filemap_read_folio**(iocb-\>ki_filp, mapping-\>a_ops-\>read_folio, 2478 folio); 2479 **goto unlock_mapping**; 2480 **unlock**:

2481 **folio_unlock**(folio); 2482 **unlock_mapping**:

2483 **filemap_invalidate_unlock_shared**(mapping); 2484 **if** (error == **AOP_TRUNCATED_PAGE**) 2485 **folio_put**(folio); 2486 **return** error;







2487 }



*Listing 9-46:* mm/filemap.c: [*filemap_update_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2434)



We carefully lock around the invalidation using

[filemap_invalidate_lock_shared()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n809), before trying to obtain a lock on the folio in order to read from disk into it. If there is contention on the lock we release the invalidation lock and combine the decrement of the folio’s reference count and waiting on the lock to be released in a single operation

via [folio_put_wait_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1470). See Section 9.11 for more details on folio locking as a whole. We indicate that this occurred, likely due to a truncation, by

returning [AOP_TRUNCATED_PAGE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n300)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n300)

if the locking is successful, but the [struct folio-\>mapping](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) field is

empty, this indicates a racing truncation occurred and thus we return

[AOP_TRUNCATED_PAGE . ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n300)indicating that this has happened.

We check to see if the folio is uptodate via [filemap_range_uptodate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2408), which

has special handling for this case where the folio is part of an iterator range. If so, then we can simply exit.

Otherwise, we perform the actual read from disk into the folio via

[filemap_read_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2382), a function we examine in detail in Section 9.6 and List-

ing 9-56 below.

When done we unlock the folio and return any error that arose. Other-

wise the folio is now present and uptodate.

Returning to [filemap_get_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2546)[—r](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2546)egardless of whether an update was

required or not, if an error occurs, we drop the final folio’s reference, and if we processed at least one folio successfully, we treat this as if it were a suc-cess. Otherwise, if the error indicated a possible truncation we jump to the retry label, finally returning any error if no folios could be processed.

The heavy lifting of this operation is performed in

[filemap_get_read_batch() , ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2346)which we explore in Listing 9-47.



2337 */\**

2338 *\* filemap_get_read_batch - Get a batch of folios for read* 2339 *\**

2340 *\* Get a batch of folios which represent a contiguous range of bytes in* 2341 *\* the file. No exceptional entries will be returned. If @index is in* 2342 *\* the middle of a folio, the entire folio will be returned. The last* 2343 *\* folio in the batch may have the readahead flag set or the uptodate flag*

2344 *\* clear so that the caller can take the appropriate action.* 2345 *\*/*

2346 **static void filemap_get_read_batch**(**struct** address_space \*mapping, 2347 **pgoff_t** index, **pgoff_t** max, **struct** folio_batch \*fbatch) 2348 {

2349 **XA_STATE**(xas, &mapping-\>i_pages, index); 2350 **struct** folio \*folio; 2351

2352 **rcu_read_lock**();

2353 **for** (folio = **xas_load**(&xas); folio; folio = **xas_next**(&xas)) { 2354 **if** (**xas_retry**(&xas, folio))







2355 **continue**; 2356 **if** (xas.xa_index \> max \|\| **xa_is_value**(folio)) 2357 **break**; 2358 **if** (**xa_is_sibling**(folio)) 2359 **break**; 2360 **if** (!**folio_try_get_rcu**(folio)) 2361 **goto retry**; 2362

2363 **if** (**unlikely**(folio != **xas_reload**(&xas))) 2364 **goto put_folio**; 2365

2366 **if** (!**folio_batch_add**(fbatch, folio)) 2367 **break**; 2368 **if** (!**folio_test_uptodate**(folio)) 2369 **break**; 2370 **if** (**folio_test_readahead**(folio)) 2371 **break**; 2372 **xas_advance**(&xas, folio-\>index + **folio_nr_pages**(folio) - 1); 2373 **continue**; 2374 **put_folio**:

2375 **folio_put**(folio); 2376 **retry**:

2377 **xas_reset**(&xas); 2378 }

2379 **rcu_read_unlock**(); 2380 }



*Listing 9-47:* mm/filemap.c: [*filemap_get_read_batch()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2346)

We use the xarray data structure obtained from the page cache map-

ping’s [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) object to look up folios (see Section 9.2 for more

on this).

Throughout we thread a [struct xa_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1326) object, initialised via [XA_STATE()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1368).

The operation is performed under [RCU](https://kernel.org/doc/html/v6.0/RCU/rcu.html) lock, the discussion of which is

out of scope here, however we can be certain in this circumstance that, while

under this lock the folio cannot be pulled out from beneath us.

We start by checking whether the operation needs to be retried based

on the result of [xas_retry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1504)[—t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1504)hese are cases where the xarray walk must be

restarted. The function invokes [xas_reset()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1487) to reset the walk so we need only

loop around in this circumstance.

Next, we consider edge cases. This list is a great example of just how

careful you have to be around races in the memory management subsys-

tem, and the degree to which things are permitted to remain in flight for

efficiency:



**Has the iteration terminated?** If [struct xa_state-\>xa_index](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1326) exceeds the maxi-

mum inclusive index max, we’re done and exit.

**Is the entry exceptional?** The page cache mechanism sometimes causes

‘exceptional’ entries to be present in the xarray, i.e. ones that contain







values rather than pointers. If this is the case (checked via [xa_is_value()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n79)), then this indicates the folio has been evicted and thus we must abort the operation (we strictly return contiguous entries).

**Did we race with an invalidate/read?** If we race with an invalidation fol-

lowed by another read, this can lead to a higher order folio being loaded, and we may end up observing a tail page. In this instance, sig-

nified by [xa_is_sibling()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1263)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1263) we must abort our iteration.

**Did the folio get released?** We try to get a reference to the folio via

[folio_try_get_rcu(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page_ref.h?h=v6.0#n311)however it may have been ‘frozen’ (see the reclaim chapter on this) in preparation for being freed, something which the

[RCU](https://kernel.org/doc/html/v6.0/RCU/rcu.html) doesn’t protect us again, so we retry in this case.

**Has the folio moved?** We can finally relax a little as we’ve obtained a ref-

erence count to the folio, however it still might have moved (or been removed) in the meantime, so we check by reloading the entry via

[xas_reload()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1567)—if the folio is not the same then we must drop the refer-ence and try this dance again.



See also Listing 9-51 below for a discussion around a highly relevant com-

ment contained in the filemap code which outlines the lockless page cache protocol.

Once we have ruled out these edge cases, we have a folio which has had

its reference count incremented (i.e. is pinned) and is as advertised, so we

add it to the [struct folio_batch](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n83) via [folio_batch_add()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n126).

After this, we then must consider whether the just-added folio both up

to date with the disk via [folio_test_uptodate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n711) and does not have the reada-head flag set (which indicates that this is the point where the last readahead stopped and more need be performed), as checked by *folio_test_readahead()*.

If either of these are the case, then we must return to the caller to have

them deal with this, so we exit early.

Finally, we advance the [struct xa_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1326) past all tail pages (if the folio is

higher order) using [xas_advance()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1612).



***9.5.3 Reading a Single Folio From the Page Cache***

When we perform a page fault, as discussed in Section 9.4, we first need to determine whether that folio is present in the page cache and retrieve it if

so. We do this via [filemap_get_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n526) as shown in Listing 9-48.



516 */\*\**

517 *\* filemap_get_folio - Find and get a folio.* 518 *\* @mapping: The address_space to search.* 519 *\* @index: The page index.* 520 *\**

521 *\* Looks up the page cache entry at @mapping & @index. If a folio is* 522 *\* present, it is returned with an increased refcount.* 523 *\**

524 *\* Otherwise, %NULL is returned.*







525 *\*/*

526 **static inline struct** folio \***filemap_get_folio**(**struct** address_space \*mapping, 527 **pgoff_t** index) 528 {

529 **return \_\_filemap_get_folio**(mapping, index, 0, 0); 530 }



*Listing 9-48:* include/linux/pagemap.h: [*filemap_get_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n526)



The folio is not locked, nor is it read from disk if it is not uptodate nor is

a new folio allocated if one was not already present. The heavy lifting is de-

ferred to [\_\_filemap_get_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1914), which has a great deal of flexibility in its be-

haviour, examined in Listing 9-49 (eliding comments describing flags which

we describe below and out of scope page idle handling).

In addition, [\_\_filemap_get_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1914) can be invoked with a set of flags to

enable a great deal of control over how the folio is retrieved and whether or

not we allocate a new folio and add it to the page cache should one not be

present (as we do on page fault in [filemap_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3084) described in Section 9.4

above).

[\_\_filemap_get_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1914) uses ‘Find Get Page’ (FGP) flags to determine its

behaviour:



**FGP_ACCESSED** The folio will be marked accessed.

**FGP_LOCK** The folio will be returned locked.

**FGP_ENTRY** By default, if the folio entry in the xarray is not actually a

pointer to a folio but is rather ‘exceptional’, i.e. indicates a freshly re-claimed entry (a.k.a. a ‘shadow’ entry, this is out of scope for the book), or a swap entry (see the chapter on swap) or a DAX entry (out of scope for the book), this function will not return them. This flag alters this behaviour and instead returns the entry as-is in this case.

**FGP_CREAT** This is a key behavioural flag—if a folio cannot be found for

whatever reason and this flag is not set, then the function returns NULL. However if this flag is set, then a folio will be allocated, added to the page cache and locked, ready to be read in to. Importantly, the folio will not be up to date, i.e. will not be read from disk, it is up to the caller to do this if required. The call may sleep in this instance

**FGP_FOR_MMAP** Indicates that the folio should be returned unlocked, as

the caller setting this flag, i.e. [filemap_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3084)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3084) as it is the only function to do so, expects it.

**FGP_WRITE** Indicates that the folio will be written to. This ultimately re-

sults in the [\_\_GFP_WRITE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n106) flag being used on folio allocation if FGP_CREATE is also specified and the underlying block device can write back (as de-

termined by [mapping_can_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev.h?h=v6.0#n138). See Section 2.6 for details on this flag. FGP_WRITE also affects idle page handling, however this topic is out of scope for the book.

**FGP_NOFS** (Only meaningful if FGP_CREAT is set) Indicates that the file sys-

tem should not be invoked on allocation by clearing the [\_\_GFP_FS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n215) flag on







physical page allocation. This is typically used when a filesystem must re-trieve a folio but recursive access to the filesystem cannot be permitted (for instance to avoid deadlocks).

**FGP_NOWAIT** If FGP_LOCK is specified, indicates that we should not wait for

the folio to become unlocked before we try to lock it. If we cannot, we indicate this by explicitly returning NULL. Additionally, if FGP_CREAT is spec-

ified, we clear the default [GFP_KERNEL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n333) physical allocation flag and instead

set the combination of [GFP_NOWAIT](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n335) and [\_\_GFP_NOWARN](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n247) to indicate we must not perform direct reclaim (which might cause waiting), implies that no file system or I/O activity may be permitted and does not output warn-

ing about a failure to allocate to the kernel log. See Section 2.6 for more details.

**FGP_STABLE** There are situations where it is important that the folio is

‘stable’, i.e. not undergoing writeback at the present time. Setting this flag ensures that writeback is complete by the time the folio is returned,

as implemented by the [folio_wait_stable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n3078) function. See the writeback chapter for details on how writeback functions as a whole.



We start by examining the beginning of [\_\_filemap_get_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1914) which per-

forms the initial read from the page cache and handles associated FGP flags

in Listing 9-49.



1881 */\*\**

1882 *\* \_\_filemap_get_folio - Find and get a reference to a folio.* 1883 *\* @mapping: The address_space to search.* 1884 *\* @index: The page index.* 1885 *\* @fgp_flags: %FGP flags modify how the folio is returned.* 1886 *\* @gfp: Memory allocation flags to use if %FGP_CREAT is specified.* 1887 *\**

1888 *\* Looks up the page cache entry at @mapping & @index.* 1889 *\**

1890 *\* @fgp_flags can be zero or more of these flags:*

. . .

1907 *\* If %FGP_LOCK or %FGP_CREAT are specified then the function may sleep even*

1908 *\* if the %GFP flags specified for %FGP_CREAT are atomic.* 1909 *\**

1910 *\* If there is a page cache page, it is returned with an increased refcount.*

1911 *\**

1912 *\* Return: The found folio or %NULL otherwise.* 1913 *\*/*

1914 **struct** folio \***\_\_filemap_get_folio**(**struct** address_space \*mapping, **pgoff_t** index

,

1915 **int** fgp_flags, **gfp_t** gfp) 1916 {

1917 **struct** folio \*folio; 1918

1919 **repeat**:







1920 folio = **mapping_get_entry**(mapping, index); 1921 **if** (**xa_is_value**(folio)) { 1922 **if** (fgp_flags & **FGP_ENTRY**) 1923 **return** folio; 1924 folio = **NULL**; 1925 }

1926 **if** (!folio)

1927 **goto no_page**; 1928

1929 **if** (fgp_flags & **FGP_LOCK**) { 1930 **if** (fgp_flags & **FGP_NOWAIT**) { 1931 **if** (!**folio_trylock**(folio)) { 1932 **folio_put**(folio); 1933 **return NULL**; 1934 } 1935 } **else** {

1936 **folio_lock**(folio); 1937 }

1938

1939 */\* Has the page been truncated? \*/* 1940 **if** (**unlikely**(folio-\>mapping != mapping)) { 1941 **folio_unlock**(folio); 1942 **folio_put**(folio); 1943 **goto repeat**; 1944 }

1945 **VM_BUG_ON_FOLIO**(!**folio_contains**(folio, index), folio); 1946 }

1947

1948 **if** (fgp_flags & **FGP_ACCESSED**) 1949 **folio_mark_accessed**(folio);

. . .

1956 **if** (fgp_flags & **FGP_STABLE**) 1957 **folio_wait_stable**(folio);



*Listing 9-49:* mm/filemap.c: [*\_\_filemap_get_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1914) *Reading From Page Cache*



The actual read from the page cache is performed by [mapping_get_entry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1850),

which is examined below in Listing 9-52. Note that this will increment the

reference count of the retrieved folio to pin it in memory, which must be

decremented if something goes wrong.



**N O T E** It’s important to note here that all folios that are read into the page cache whether

faulted-in, read from a file or via readahead will have their reference incremented

when doing so. This is a product of the page cache ‘holding on’ to file data as long

as possible in order to minimise I/O, relying on reclaim to released file-backed folios

under memory pressure.

The reference count is incremented on introduction to the page cache, but also when

added to private filesystem metadata, added to an LRU list, mapped into memory







and thus referenced by a page table, as well as any other mean by which the kernel references it.



We start by examining whether this value is ‘exceptional’, i.e. not NULL

but also not a pointer to a folio, as determined by [xa_is_value()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n79). If FGP_ENTRY has been specified then we simply return this value as the caller expects it, otherwise we treat it as if the folio is not present (which is in fact accurate, these values always provide information describing a missing entry) setting folio to NULL.

Next, we check whether the folio either not found or exceptional without

FGP_ENTRY specified, in which case we defer to the missing page handling at

label no_page, as described below in Listing 9-50.

We then try to lock the folio if requested via FGP_LOCK. If this is not speci-

fied then the caller either performs locking itself, or whether the folio is in flux is immaterial to it. We will return to this logic shortly.

After the locking logic is handled, we simply set the folio accessed via

[folio_mark_accessed()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n441) if FGP_ACCESSED is specified (see the chapter on reclaim

for more on the impact of this) and invoke [folio_wait_stable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n3078) if FGP_STABLE is specified to wait for writeback to complete (see the writeback chapter for more details on writeback).

Returning to the lock logic. This is invoked only if the FGP_LOCK flag is set.

If FGP_NOWAIT is also specified then we don’t wait for the lock but rather use

[folio_trylock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n900) to attempt to acquire a lock if it is not already held. If it is

then we release the reference on the folio via [folio_put()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1122) and return NULL. If

FGP_NOWAIT is not specified we simply use [folio_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n935) to wait for any existing

lock to be released (see Section 9.11 below for more details on folio locking).

Finally, once the lock is acquired we check to determine whether the

folio has been truncated and possibly since allocated to another mapping,

which is indicated by the [struct folio-\>mapping](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) field no longer matching the mapping for which we are looking up folios.

In this instance, we unlock the folio via [folio_unlock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1526), decrement its ref-

erence count via [folio_put()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n1122) and retry the operation by jumping to the repeat flag.

Finally the locking logic performs a sanity check (only applicable if

CONFIG_DEBUG_VM is set) to ensure the index and folio tally to one another.

At this point, if the folio was found, we return it (on line 1998), otherwise

we invoke the missing page logic shown in Listing 9-50.



1958 **no_page**:

1959 **if** (!folio && (fgp_flags & **FGP_CREAT**)) { 1960 **int** err;

1961 **if** ((fgp_flags & **FGP_WRITE**) && **mapping_can_writeback**(mapping)) 1962 gfp \|= **\_\_GFP_WRITE**; 1963 **if** (fgp_flags & **FGP_NOFS**) 1964 gfp &= ~**\_\_GFP_FS**; 1965 **if** (fgp_flags & **FGP_NOWAIT**) { 1966 gfp &= ~**GFP_KERNEL**; 1967 gfp \|= **GFP_NOWAIT** \| **\_\_GFP_NOWARN**;







1968 }

1969

1970 folio = **filemap_alloc_folio**(gfp, 0); 1971 **if** (!folio) 1972 **return NULL**; 1973

1974 **if** (**WARN_ON_ONCE**(!(fgp_flags & (**FGP_LOCK** \| **FGP_FOR_MMAP**)))) 1975 fgp_flags \|= **FGP_LOCK**; 1976

1977 */\* Init accessed so avoid atomic mark_page_accessed later \*/*

1978 **if** (fgp_flags & **FGP_ACCESSED**) 1979 **\_\_folio_set_referenced**(folio); 1980

1981 err = **filemap_add_folio**(mapping, folio, index, gfp); 1982 **if** (**unlikely**(err)) { 1983 **folio_put**(folio); 1984 folio = **NULL**; 1985 **if** (err == -**EEXIST**) 1986 **goto repeat**; 1987 }

1988

1989 */\**

1990 *\* filemap_add_folio locks the page, and for mmap* 1991 *\* we expect an unlocked page.* 1992 *\*/*

1993 **if** (folio && (fgp_flags & **FGP_FOR_MMAP**)) 1994 **folio_unlock**(folio); 1995 }

1996

1997 **return** folio;

1998 }



*Listing 9-50:* mm/filemap.c: [*\_\_filemap_get_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1914) *Missing Page Handling*



We only actually do something in the instance of a missing folio if

FGP_CREAT is specified. In this case, we will allocate a folio and add it into the

page cache.

We start by determining the ‘Get Free Pages’ (GFP) flags to be passed

into the physical allocator. This is discussed in great detail in the Physical

Memory chapter in Section 2.6, and these flags were already discussed in

detail above.

Next we perform the actual allocation via [filemap_alloc_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n955)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n955) which

performs some NUMA-specific behaviour before deferring the operation

to [folio_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mempolicy.c?h=v6.0#n2278) which finally allocates using the physical page allocator via

[alloc_pages(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mempolicy.c?h=v6.0#n2252)see Section 2.8 in the Physical Memory chapter for more on

this.

If this allocation fails, then we simply return NULL. Otherwise we perform

a sanity check to ensure that either we don’t require a lock as indicated by







FGP_FOR_MMAP or we do with FGP_LOCK specified. If this edge case occurs then we warn about it and override by setting this flag anyway (this is meaningful because we may repeat the operation).

We then add the newly allocated folio into the page cache via

[filemap_add_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n926) (see Listing 9-54 and Section 12.2.1 below). Note that this locks the folio as part of this operation.

If an error occurs, we drop our reference on the folio, setting it to NULL

unless the error is that the folio at this position already exists and a race oc-curred, in which case we repeat the operation to get it.

Finally, if FGP_FOR_MMAP is set we unlock the folio via [folio_unlock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1526) as the

caller expects us to.

The actual lookup of a folio in the page cache is performed by

[mapping_get_entry().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1850)

We examine this function in Listing 9-52. However, prior to this there is

a very useful comment contained in the source, shown in Listing 9-51.



1818 */\**

1819 *\* Lockless page cache protocol:* 1820 *\* On the lookup side:*

1821 *\* 1. Load the folio from i_pages* 1822 *\* 2. Increment the refcount if it's not zero* 1823 *\* 3. If the folio is not found by xas_reload(), put the refcount and retry*

1824 *\**

1825 *\* On the removal side:*

1826 *\* A. Freeze the page (by zeroing the refcount if nobody else has a reference)*

1827 *\* B. Remove the page from i_pages* 1828 *\* C. Return the page to the page allocator* 1829 *\**

1830 *\* This means that any page may have its reference count temporarily* 1831 *\* increased by a speculative page cache (or fast GUP) lookup as it can* 1832 *\* be allocated by another user before the RCU grace period expires.* 1833 *\* Because the refcount temporarily acquired here may end up being the* 1834 *\* last refcount on the page, any page allocation must be freeable by* 1835 *\* folio_put().*

1836 *\*/*



*Listing 9-51:* mm/filemap.c: *Lockless Page Cache Protocol*



This protocol details how page cache operations can be performed un-

der [RCU](https://kernel.org/doc/html/v6.0/RCU/rcu.html) lock only (which does not function like a classical lock but rather utilises the fact that we can know when things might be updated to know when it is safe to write to values without anything unexpectedly reading it).

We examine how folio removal happens in the page cache in Section 9.9

below. However broadly the ordering described here, with folios being re-

trieved/removed from the [struct address_space-\>i_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) xarray results in the possibility that the reference count of a folio that has in fact been removed from the xarray has gets temporarily boosted prior to being freed thus pre-venting its freeing.







To handle this, we make sure to always use [xas_reload()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1567) in all instances

where this might happen, for instance in [mapping_get_entry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1850) described in

Listing 9-52 below and in [filemap_get_read_batch()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2346) described in Listing 9-47

described previously.



1838 */\**

1839 *\* mapping_get_entry - Get a page cache entry.* 1840 *\* @mapping: the address_space to search* 1841 *\* @index: The page cache index.* 1842 *\**

1843 *\* Looks up the page cache entry at @mapping & @index. If it is a folio,* 1844 *\* it is returned with an increased refcount. If it is a shadow entry* 1845 *\* of a previously evicted folio, or a swap entry from shmem/tmpfs,* 1846 *\* it is returned without further action.* 1847 *\**

1848 *\* Return: The folio, swap or shadow entry, %NULL if nothing is found.* 1849 *\*/*

1850 **static void** \***mapping_get_entry**(**struct** address_space \*mapping, **pgoff_t** index) 1851 {

1852 **XA_STATE**(xas, &mapping-\>i_pages, index); 1853 **struct** folio \*folio; 1854

1855 **rcu_read_lock**();

1856 **repeat**:

1857 **xas_reset**(&xas);

1858 folio = **xas_load**(&xas); 1859 **if** (**xas_retry**(&xas, folio)) 1860 **goto repeat**; 1861 */\**

1862 *\* A shadow entry of a recently evicted page, or a swap entry from*

1863 *\* shmem/tmpfs. Return it without attempting to raise page count.*

1864 *\*/*

1865 **if** (!folio \|\| **xa_is_value**(folio)) 1866 **goto out**; 1867

1868 **if** (!**folio_try_get_rcu**(folio)) 1869 **goto repeat**; 1870

1871 **if** (**unlikely**(folio != **xas_reload**(&xas))) { 1872 **folio_put**(folio); 1873 **goto repeat**; 1874 }

1875 **out**:

1876 **rcu_read_unlock**(); 1877

1878 **return** folio;

1879 }







*Listing 9-52:* mm/filemap.c: [*mapping_get_entry()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1850)

This parallels [filemap_get_read_batch()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2346) in its general operation (see Listing

9-47 above), though it retrieves only a single folio.

The operation is performed under an [RCU](https://kernel.org/doc/html/v6.0/RCU/rcu.html) lock, as briefly described

above in the discussion around 9-51, is inherently racey so must be per-

formed with care. As in [filemap_get_read_batch()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2346)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2346) we load an entry via

[xas_load()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/xarray.c?h=v6.0#n233) and check whether the entry indicates the operation needs to be

retried via [xas_retry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1504), resetting and repeating the entire operation if so. If no folio is found, we return NULL.

Next we check to see if the entry is ‘exceptional’, i.e. not NULL but also

not a pointer to a folio, this indicates it has recently been freed either as a

‘shadow’ entry left after removal (see Section 9.9 below) or is a swap entry (see the Swap chapter for more). In each case we simply return the value for the caller to deal with.

Next we try to increment the reference count for the folio via

[folio_try_get_rcu(). ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page_ref.h?h=v6.0#n311)This may race with folio removal, so if it fails we simply repeat the operation.

Finally, now we have incremented the reference count we, as discussed,

may race with the folio being moved (or removed) so we reload the entry and check to ensure that the folio matches. If not we drop the reference count and repeat.



***9.5.4 Reading a Single Folio Into the Page Cache***

There are a number of file system, driver and internal kernel callers which ultimately need to retrieve a single folio from the page cache, reading from disk into it if it is not already present. We examine these callers in Figure

9-9.



file systems, drivers, swapon syscall, uprobe



file systems, block, SCSI [read_mapping_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n753) file systems, drivers, shmem



[read_mapping_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n759) [read_cache_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3567) [read_cache_page_gfp()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3590) file systems



[read_cache_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3548) [do_read_cache_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3556)



[do_read_cache_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3472)



*Figure 9-9: Callers Reading a Single Folio Into the Page Cache*



Regardless of what invokes the original read, we ultimately end up in

[do_read_cache_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3472) which we examine in Listing 9-53.







3472 **static struct** folio \***do_read_cache_folio**(**struct** address_space \*mapping, 3473 **pgoff_t** index, **filler_t** filler, **struct** file \*file, **gfp_t** gfp) 3474 {

3475 **struct** folio \*folio; 3476 **int** err;

3477

3478 **if** (!filler)

3479 filler = mapping-\>a_ops-\>**read_folio**; 3480 **repeat**:

3481 folio = **filemap_get_folio**(mapping, index); 3482 **if** (!folio) {

3483 folio = **filemap_alloc_folio**(gfp, 0); 3484 **if** (!folio) 3485 **return ERR_PTR**(-**ENOMEM**); 3486 err = **filemap_add_folio**(mapping, folio, index, gfp); 3487 **if** (**unlikely**(err)) { 3488 **folio_put**(folio); 3489 **if** (err == -**EEXIST**) 3490 **goto repeat**; 3491 */\* Presumably ENOMEM for xarray node \*/* 3492 **return ERR_PTR**(err); 3493 }

3494

3495 **goto** filler; 3496 }

3497 **if** (**folio_test_uptodate**(folio)) 3498 **goto out**; 3499

3500 **if** (!**folio_trylock**(folio)) { 3501 **folio_put_wait_locked**(folio, **TASK_UNINTERRUPTIBLE**); 3502 **goto repeat**; 3503 }

3504

3505 */\* Folio was truncated from mapping \*/* 3506 **if** (!folio-\>mapping) { 3507 **folio_unlock**(folio); 3508 **folio_put**(folio); 3509 **goto repeat**; 3510 }

3511

3512 */\* Someone else locked and filled the page in a very small window \*/*

3513 **if** (**folio_test_uptodate**(folio)) { 3514 **folio_unlock**(folio); 3515 **goto out**; 3516 }

3517

3518 filler:







3519 err = **filemap_read_folio**(file, filler, folio); 3520 **if** (err) {

3521 **folio_put**(folio); 3522 **if** (err == **AOP_TRUNCATED_PAGE**) 3523 **goto repeat**; 3524 **return ERR_PTR**(err); 3525 }

3526

3527 **out**:

3528 **folio_mark_accessed**(folio); 3529 **return** folio;

3530 }



*Listing 9-53:* mm/filemap.c: [*do_read_cache_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3472)



The function is passed an optional [filler_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n493) callback (see Listing

9-57) via the filler parameter, which specifies a function which per-forms the actual read from disk of a folio if necessary. If not speci-

fied, this is defaulted to the [struct address_space_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n356)-specified

[struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)-\>a_ops-\>read_folio filesystem-specific callback. We dis-

cuss how these reads function in Section 9.6 below.

We attempt to retrieve the folio from the page cache via

[filemap_get_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n516) (see Section 9.5.3 and Listing 9-48). If a page cache en-

try is not found, we allocate one via [filemap_alloc_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n955), returning an out of memory error if the allocation files.

We then add this folio into the page cache via [filemap_add_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n926) which

we examine in Listing 9-54 and Section 12.2.1 below.

If we are unable to add the folio to the page cache due to an existing folio

being present at this offset, we simply repeat our attempt to retrieve the folio from the page cache in order to locate the already existing one.

otherwise, if another error arose, we return this error. In both instances

we drop the reference count on the allocated folio such that it will be re-claimed

If we allocated a folio then it cannot be uptodate, so in this instance we

skip straight ahead to ‘filling’ the folio at label filler, i.e. reading it from disk.

If we did indeed locate the folio within the page cache, which at this

point will have its reference count incremented, we check to see if it is up-todate. If so then we have nothing further to do other than housekeeping, jumping to the out label, otherwise we must lock the folio and get ready to read into it from disk.

When we try to lock the folio, we combine the reference count decre-

ment and sleep function in an invocation of [folio_put_wait_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1470)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1470) See Sec-

tion 9.11 for more details on folio locking as a whole.

Before we read from disk, we must perform the typical dance to protect

ourselves against truncation. If we find that the [struct folio-\>mapping](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) refer-ence to page cache object does not match the page cache object under exam-ination then we unlock the folio, decrement its reference count and repeat







the procedure (perhaps allocating a new folio had the prior one been trun-

cated).

Next we examine the edge case where the folio was updated in the very

brief time window available to it. If so we need not read from disk, and so

unlock the folio and exit.

Finally we are in the position where the folio is both locked and in need

of being read from disk in this instance then we perform the read using

[filemap_read_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2382), a function we examine in detail in Section 9.6 and List-

ing 9-56 below.

If this fails, we drop the reference count, repeating the whole op-

eration if this was due to truncation (as indicated by an error code of

[AOP_TRUNCATED_PAGE ), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n300)exiting otherwise.

Finally, all being well, we mark the folio accessed via [folio_mark_accessed](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n441)

(see Listing 11-11 in the reclaim chapter for a discussion fo this function) as

this page cache access indicates that the file has actively been accessed. After

doing so we return the folio, now present and uptodate in the page cache.



***9.5.5 Adding Folios to the Page Cache***

Once folios intended for the page cache have been allocated, they need to

be added to the page cache and inserted into the correct position within the

relevant xarray. This is performed by [filemap_add_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n926) which we examine

in Listing 9-54 (eliding out of scope working set logic).



926 **int filemap_add_folio**(**struct** address_space \*mapping, **struct** folio \*folio, 927 **pgoff_t** index, **gfp_t** gfp) 928 {

929 **void** \*shadow = **NULL**; 930 **int** ret;

931

932 **\_\_folio_set_locked**(folio); 933 ret = **\_\_filemap_add_folio**(mapping, folio, index, gfp, &shadow); 934 **if** (**unlikely**(ret)) 935 **\_\_folio_clear_locked**(folio); 936 **else** {

. . .

948 **folio_add_lru**(folio); 949 }

950 **return** ret;

951 }



*Listing 9-54:* mm/filemap.c: [*filemap_add_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n926)



Note that we track folios which were recently evicted for the working set

logic, which is stored in value fields contained in the xarray which reference

‘shadow’ entries. This is out of scope for the book.

This locks the folio then invokes [\_\_filemap_add_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n838) to do the heavy

lifting, which also clears the lock if no error arose, we clear it manually if one

did. This therefore returns locked folios on success.







Finally if this succeeded, we add the folio to an LRU via [folio_add_lru()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n479)

(see the reclaim chapter in Section **??** and Listing 11-88 for details).

We examine [\_\_filemap_add_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n838) in Listing 9-55 (eliding out of scope

working set logic, debug assertions, huge page, tracing, statistics and cgroup logic).



838 **noinline int \_\_filemap_add_folio**(**struct** address_space \*mapping, 839 **struct** folio \*folio, **pgoff_t** index, **gfp_t** gfp, **void** \*\*shadowp) 840 {

841 **XA_STATE**(xas, &mapping-\>i_pages, index);

. . .

844 **long** nr = 1;

. . .

856 **xas_set_order**(&xas, index, **folio_order**(folio)); 857 nr = **folio_nr_pages**(folio);

. . .

860 gfp &= **GFP_RECLAIM_MASK**; 861 **folio_ref_add**(folio, nr); 862 folio-\>mapping = mapping; 863 folio-\>index = xas.xa_index; 864

865 **do** {

866 **unsigned int** order = **xa_get_order**(xas.xa, xas.xa_index); 867 **void** \*entry, \*old = **NULL**; 868

869 **if** (order \> **folio_order**(folio)) 870 **xas_split_alloc**(&xas, **xa_load**(xas.xa, xas.xa_index), 871 order, gfp); 872 **xas_lock_irq**(&xas); 873 **xas_for_each_conflict**(&xas, entry) { 874 old = entry; 875 **if** (!**xa_is_value**(entry)) { 876 **xas_set_err**(&xas, -**EEXIST**); 877 **goto unlock**; 878 } 879 }

880

881 **if** (old) {

. . .

884 */\* entry may have been split before we acquired lock*

*\*/*

885 order = **xa_get_order**(xas.xa, xas.xa_index); 886 **if** (order \> **folio_order**(folio)) {

. . .

889 **xas_split**(&xas, old, order); 890 **xas_reset**(&xas); 891 } 892 }







893

894 **xas_store**(&xas, folio); 895 **if** (**xas_error**(&xas)) 896 **goto unlock**;

897

898 mapping-\>nrpages += nr;

. . .

907 **unlock**:

908 **xas_unlock_irq**(&xas); 909 } **while** (**xas_nomem**(&xas, gfp));

910

911 **if** (**xas_error**(&xas)) 912 **goto error**;

. . .

915 **return** 0;

916 **error**:

. . .

919 folio-\>mapping = **NULL**; 920 */\* Leave page-\>index set: truncation relies upon it \*/* 921 **folio_put_refs**(folio, nr); 922 **return xas_error**(&xas); 923 }



*Listing 9-55:* mm/filemap.c: [*\_\_filemap_add_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n838)



**N O T E** The majority of the discussion of this function centres around logic relating to work-

ing set detection and ‘shadow entries’ used as part of this logic. This is out of scope

for the book, however since it comprises such a large part of this function it’d be re-

miss not to cover it. For simplicity’s sake you might instead focus on [*xas_store()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/xarray.c?h=v6.0#n777)

which is the actual function call which stores the entry as well as the edge case out of

memory handling.



This establishes a [struct xa_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1326) object to retain xarray state at the speci-

fied index into the [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) page cache entry.

We take special care to account for larger folio size, incrementing the

reference count for the folio being added accordingly and establishing both

its index and [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) mapping.

As part of this, we set up the xas object to be utilised to place the folio

order in the current position via [xas_set_order()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1626)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1626) This does not mean that

any existing entry at this position is of the same order, so we must explicitly

check this later on.

We then enter a loop intended to handle a high memory pressure sce-

narios, it loops only if the [xas_nomem()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/xarray.c?h=v6.0#n300) indicates that an allocation previously

failed due to an out of memory condition (for instance when splitting up an

existing xarray entry).

If this is so, [xas_nomem()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/xarray.c?h=v6.0#n300) attempts to allocate memory, and we loop if it

succeeds, otherwise if out of memory we exit indicating this error.







In ordinary circumstances this loop will be executed in only one itera-

tion.

The complexity here largely centres around working set logic and han-

dling larger folio sizes. As touched upon in Section 9.2, xarray entries which span multiple indexes (i.e. larger folio size) comprise a more complicated tree structure with sibling nodes and so on.

This, combined with the fact that existing entries which have been

evicted may be left behind with a value entry used for working set calcula-tions mean we have to tread carefully here.

We start by determining the order of any existing xarray node in this po-

sition via [xa_get_order()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/xarray.c?h=v6.0#n1761). if this exceeds the order of the folio we intend to add at this position, we must split it such that we obtain an entry of the correct order.

At this point we acquire a lock on the entry, before iterating through any

existing entries via [xas_find_conflict()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/xarray.c?h=v6.0#n1396). Again, we are looking for ‘shadow’ entries, entries which contain values used for working set logic.

If any entry discovered in the range in which we intend to place our fo-

lio is not a value entry, then we have a conflict and indicate an EEXIST error to indicate as much (we are considering a range only if the folio is of order greater than 0).

If we did, in fact, discover a conflicting entry in the range in which we

hope to add our folio, we must split it if it exceeds our required order.

Ultimately the folio is stored in the xarray via [xas_store()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/xarray.c?h=v6.0#n777)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/xarray.c?h=v6.0#n777) the lock elim-

inated and we proceed with error handling if no out of memory condition arose.

Importantly, we update the [struct address_space-\>nrpages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) count to indi-

cate that we have now added a page table entry (perhaps spanning multiple pages if a folio of order greater than 0).

This is very important as this counter is used explicitly in the kernel to

determine how many pages are actually present in the page cache for a given page cache entry.



**9.6 Reading Folios From Disk**



There are two principle means by which data is actually read from disk into

the page cache—readahead, which we explore in section 9.7, and the reading of individual folios from disk (perhaps in a batched operation). We explore the latter in this section.

There are a number of callers which require us to read individual folios

from disk. We’ve already examined two core means of doing so in Section

9.5 when exploring how page cache folios are generally accessed by the ker-nel.

When reading folios via the [read()](https://man7.org/linux/man-pages/man2/read.2.html) system call, we ultimately read fo-

lios in a batch via [filemap_get_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2546) as shown in Listing 9-44 and Section

9.5.2. Equally [filemap_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3084) requires us to read from disk if necessary as

described in Section 9.4 and Listing 9-35.







In addition to this there are a number of filesystem, driver and other sub-

system folio accesses which ultimately invoke [do_read_cache_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3472) (see Fig-

ure 9-9 and Listing 9-53) which reads from disk if necessary.

Regardless of where the operation originates from, the folio is ultimately

read from disk via [filemap_read_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2382) which we examine in Listing 9-56.



2382 **static int filemap_read_folio**(**struct** file \*file, **filler_t filler**, 2383 **struct** folio \*folio) 2384 {

2385 **int** error;

2386

2387 */\**

2388 *\* A previous I/O error may have been due to temporary failures,* 2389 *\* eg. multipath errors. PG_error will be set again if read_folio*

2390 *\* fails.*

2391 *\*/*

2392 **folio_clear_error**(folio); 2393 */\* Start the actual read. The read will unlock the page. \*/* 2394 error = **filler**(file, folio); 2395 **if** (error)

2396 **return** error; 2397

2398 error = **folio_wait_locked_killable**(folio); 2399 **if** (error)

2400 **return** error; 2401 **if** (**folio_test_uptodate**(folio)) 2402 **return** 0; 2403 **if** (file)

2404 **shrink_readahead_size_eio**(&file-\>f_ra); 2405 **return**-**EIO**;

2406 }



*Listing 9-56:* mm/filemap.c: [*filemap_read_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2382)



We require the folio passed into this function to already be locked, ready

to be written in to.

This function is essentially a wrapper around filler which is of type

[filler_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n493) and specifies a callback which performs the actual disk read, de-

fined as shown in Listing 9-57.



493 **typedef int filler_t**(**struct** file \*, **struct** folio \*);



*Listing 9-57:* include/linux/pagemap.h: [*filler_t*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n493)



This function accepts the folio to read from, the [struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) object which

describes the open file we read from and returns an error code or 0 if the

read is successful.

Before we invoke this function, we clear the [PG_error](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n109) flag for the folio on

the assumption that any such prior error was temporary.







If the filler callback returns an error we simply forward this to the caller.

Otherwise we wait for the lock to be released, at which point the folio should be read into and uptodate. If this is so, we return zero to indicate no error arose.

Otherwise, we invoke [shrink_readahead_size_eio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2332) to scale down reada-

head as a result of the error, before returning EIO to indicate that an error arose.

Ultimately the actual read from disk is file-system specific, so we do not

examine this in detail here. However ultimately whatever the implementa-tion, the folio will be unlocked once the data has been read, and marked

with the [PG_uptodate](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n103) folio flag to indicate the data has been read from disk correctly.

This is why, in this function, we can sleep on the folio being unlocked

knowing that the data will be correctly read into the folio by this point (or an error indicated).

Typically, when disk I/O is complete, [page_endio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1634) is invoked, which we

examine in Listing 9-58.



1630 */\**

1631 *\* After completing I/O on a page, call this routine to update the page* 1632 *\* flags appropriately*

1633 *\*/*

1634 **void page_endio**(**struct** page \*page, **bool** is_write, **int** err) 1635 {

1636 **if** (!is_write) {

1637 **if** (!err) { 1638 **SetPageUptodate**(page); 1639 } **else** {

1640 **ClearPageUptodate**(page); 1641 **SetPageError**(page); 1642 }

1643 **unlock_page**(page); 1644 } **else** {

1645 **if** (err) { 1646 **struct** address_space \*mapping; 1647

1648 **SetPageError**(page); 1649 mapping = **page_mapping**(page); 1650 **if** (mapping) 1651 **mapping_set_error**(mapping, err); 1652 }

1653 **end_page_writeback**(page); 1654 }

1655 }



*Listing 9-58:* mm/filemap.c: [*page_endio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1634)



This is divided into two parts—read and write. In both cases we set

the [PG_error](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n109) folio flag should an error have arisen, on write we addition-







ally set an error in the related [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) mapping object via

[mapping_set_error().](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n218)

For writeback we invoke [end_page_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n24) which calls

[folio_end_writeback() , ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1599)which wraps [\_\_folio_end_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n2910) which we explore

in the writeback chapter in Listing **??**.

Pertinent here is the read case—we use the generated folio flag macro

helpers to set/clear folio flags, setting [PG_uptodate](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n103) if no error arose, clearing

it if one did (and setting [PG_error](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n109) if so). In both cases we unlock the folio via

[unlock_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n18) which wraps [folio_unlock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1526). See Section 9.11 for more details

on folio locking as a whole.



**9.7 Readahead**



Readahead is the process by which pages are read into the page cache be-

yond those required by a read or file-backed page fault. This is done on the

basis that it is likely that the user will want to access sequential data so it’s

simply more efficient to read in this data ahead at the same time as request-

ing data preceding it.

The readahead mechanism allows for interleaving of reads by marking a

folio with the [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143) flag when readahead occurs on a major fault (i.e.

one which necessitates the blocking of the calling process until the data can

be read back from disk), such that when this folio is read in a minor fault (i.e.

one where the folio is present in the page cache but simply not yet mapped

to the process), readahead is triggered once again.

The former kind of readahead is termed ‘synchronous’ readahead and

the latter asynchronous. As we read through data sequentially, each time we

come across a [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143) in minor fault we start the next batch of reada-

head and mark a subsequent folio with [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143) to trigger readahead

again.

This allows for a continual process of background, asynchronous reada-

head operations to occur, meaning that for sequential access we can ideally

avoid major page faults from occurring at all in the first place, or at least sig-

nificantly reduce them.

The maximum number of pages that are readahead are, by default,

determined by the block device information object (BDI), specified by

[struct backing_dev_info](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n165)-\>ra_pages.

This parameter can be changed via a [ioctl()](https://man7.org/linux/man-pages/man2/ioctl.2.html) call on the block device file

(e.g. /dev/sda1) using the [BLKRASET](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/fs.h?h=v6.0#n153) command (and retrieved using the [BLKRAGET](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/fs.h?h=v6.0#n154)

command). This defaults to [VM_READAHEAD_PAGES](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1186)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1186) set in [bdi_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/backing-dev.c?h=v6.0#n810)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/backing-dev.c?h=v6.0#n810)

This readahead value can also be read and set in the sysfs directory

/sys/devices/virtual/bdi/\<maj:min\>/read_ahead_kb (where maj and min are the

major and minor device numbers respectively) or more conveniently via

/sys/block/sda1/bdi/read_ahead_kb for e.g. /dev/sda1. This is specified in kilo-

bytes.

You can also use the [blockdev](https://man7.org/linux/man-pages/man8/blockdev.8.html) CLI command via blockdev --getra /dev/sda1

to get the readahead expressed in logical sectors (hardcoded 512 byte units)







for e.g. /dev/sda1 and blockdev --setra 512 /dev/sda1 to set the readahead to e.g. 512 sectors (256 KiB).

Readahead behaviour can further be moderated by the user who can use

[madvise()](https://man7.org/linux/man-pages/man2/madvise.2.html) or [posix_fadvise()](https://man7.org/linux/man-pages/man2/posix_fadvise.2.html) to hint that a file will be accessed sequentially

(via [MADV_SEQUENTIAL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/asm-generic/mman-common.h?h=v6.0#n47) or [POSIX_FADV_SEQUENTIAL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/nclude/uapi/linux/fadvise.h?h=v6.0#n7) respectively), or that it will be

accessed randomly and thus that readahead should not occur (via [MADV_RANDOM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/asm-generic/mman-common.h?h=v6.0#n46)

or [POSIX_FADV_RANDOM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/nclude/uapi/linux/fadvise.h?h=v6.0#n6) respectively).

This therefore allows for three different readahead ‘modes’ maintained

at either the [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) level for file-backed memory map-

pings (using VMA flags) or [struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) level (using file modes), shown in Ta-

ble 9-1.



Table 9-1: Readahead Modes

Mode madvise() Flags posix_fadvise() Flags VMA Flags File Mode

Random-Access [MADV_RANDOM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/asm-generic/mman-common.h?h=v6.0#n46) [POSIX_FADV_RANDOM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/fadvise.h?h=v6.0#n6) [VM_RAND_READ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n287) [FMODE_RANDOM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n143)

Normal [MADV_NORMAL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/asm-generic/mman-common.h?h=v6.0#n45) [POSIX_FADV_NORMAL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/fadvise.h?h=v6.0#n5) - -

Sequential [MADV_SEQUENTIAL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/asm-generic/mman-common.h?h=v6.0#n45) [POSIX_FADV_SEQ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/fadvise.h?h=v6.0#n6) [VM_SEQ_READ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n286) -



The readahead itself is instigated either by the usual [read()](https://man7.org/linux/man-pages/man2/read.2.html) or

page fault mechanisms for reading pages described in Section 9.5 via

[filemap_get_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2546) as shown in Listing 9-44 and Section 9.5.2, or page fault

as shown in [filemap_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3084) as shown in Listing 9-35 and Section 9.4, or ac-cessed directly either by custom filesystem code or other kernel mechanism which require it.

There are two kinds of readahead:



**Synchronous Readahead** Performed when a major page fault occurs, i.e. a

folio is not present in the page cache at all. At this point, we should try to retrieve the folio and initiate readahead from this point on. We read in some folios, and establish an ‘asynchronous tail’— a number of folios in addition to those we have read immediately which we will read once a user accesses one of the synchronous readahead folios. We mark this

folio with the [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143) flag which asynchronous readahead uses to determine when to perform this task. We explore synchronous reada-

head in Section 9.7.1.

**Asynchronous Readahead** Performed when a minor page fault occurs, i.e.

one that exists within the page cache but is not yet mapped by a pro-cess. When this happens, the mapped folio is checked to determine

whether it has the [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143) flag set. If so, asynchronous readahead goes ahead, otherwise no readahead is performed. We explore asyn-

chronous readahead in Section 9.7.2.



We examine the code paths readahead takes through the kernel in Fig-

ure 9-10.





[read()](https://man7.org/linux/man-pages/man2/read.2.html)

if not present in page cache if [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143)

[filemap_get_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2546) [filemap_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2534)

filesystem, huge page fault filesystem



[page_cache_sync_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1210) [filemap_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3084) [page_cache_async_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1233)

major minor

[VM_SEQ_READ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n286) set if [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143)

[page_cache_sync_ra()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1210) [do_sync_mmap_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2968) [do_async_mmap_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3037) [page_cache_async_ra()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n703)

FADV_WILLNEED

if [FMODE_RANDOM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n143)[/](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n143)no RA

[force_page_cache_ra()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n300) [ondemand_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/?h=v6.0#n)



[do_page_cache_ra()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n275) fallback [page_cache_ra_order()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n490)



filesystem

if no a_ops-\>readahead

[page_cache_ra_unbounded()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n200) [read_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n146) a_ops-\>read_folio()



invokes

a_ops-\>readahead() [readahead_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1285)



*Figure 9-10: Readahead Call Paths*



**N O T E** There is additionally a [*readahead()*](https://man7.org/linux/man-pages/man2/readahead.2.html) system call which invokes [*ksys_readahead()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n725), this

is implemented by effectively performing a [*posix_fadvise()*](https://man7.org/linux/man-pages/man2/posix_fadvise.2.html) invocation specifying

[*POSIX_FADV_WILLNEED*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/nclude/uapi/linux/fadvise.h?h=v6.0#n8) via [*vfs_fadvise()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/fadvise.c?h=v6.0#n180). As Figure 9-10 shows, this ultimately in-

vokes [*force_page_cache_ra()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n300)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n300) called via [*force_page_cache_readahead()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n100)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n100) called by

[*generic_fadvise()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/fadvise.c?h=v6.0#n32).



Before we examine how readahead is performed, let’s examine the

means by which readahead state is perpetuated— the [struct readahead_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1168)

object is threaded through readahead calls, as shown in Listing 9-59.



1152 */\*\**

1153 *\* struct readahead_control - Describes a readahead request.* 1154 *\**

1155 *\* A readahead request is for consecutive pages. Filesystems which* 1156 *\* implement the -\>readahead method should call readahead_page() or* 1157 *\* readahead_page_batch() in a loop and attempt to start I/O against* 1158 *\* each page in the request.* 1159 *\**

1160 *\* Most of the fields in this struct are private and should be accessed* 1161 *\* by the functions below.* 1162 *\**

1163 *\* @file: The file, used primarily by network filesystems for authentication.*

1164 *\** *May be NULL if invoked internally by the filesystem.* 1165 *\* @mapping: Readahead this filesystem object.* 1166 *\* @ra: File readahead state. May be NULL.* 1167 *\*/*







1168 **struct** readahead_control { 1169 **struct** file \*file; 1170 **struct** address_space \*mapping; 1171 **struct** file_ra_state \*ra; 1172 */\* private: use the readahead\_\* accessors instead \*/* 1173 **pgoff_t** \_index;

1174 **unsigned int** \_nr_pages; 1175 **unsigned int** \_batch_count; 1176 };



*Listing 9-59:* include/linux/pagemap.h: [*struct readahead_control*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1168)



Examining each field:



**file** The [struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) associated with the readahead operation (if one is

indeed associated with it). These objects describe open file descrip-tors associated with a process (even if closed by a user process after memory-mapping a file, this object will remain as it will be pinned by

the [mmap()](https://man7.org/linux/man-pages/man2/mmap.2.html).) If this field is present, the ra field is typically a pointer to

[struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940)-\>f_ra.

**mapping** The [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) page cache object for which we are per-

forming readahead.

**ra** A [file_ra_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n922) object which tracks statistics associated with the reada-

head operation, which we explore below in Listing 9-61. If a file ob-ject is associated with the operation, this will typically be a pointer to

[struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940)-\>f_ra.

**\_index** (internal) The page index of the first page in this readahead request,

relative to the [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424). Accessible via [readahead_index()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1359) or

[readahead_pos()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1341) if a byte offset is required.

**\_nr_pages** (internal) The number of pages in this readahead request. Ac-

cessible via [readahead_count()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1368) or [readahead_length()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1350) if a byte count is re-quired.

**\_batch_count** (internal) The size, in subpages, of the last folio we read back.

Accessible via [reaahead_batch_count()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1377).



Typically a [struct readahead_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1168) object is initialised by the

[DEFINE_READAHEAD()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1178) macro, as shown in Listing 9-60.



**\#define DEFINE_READAHEAD**(ractl, f, r, m, i) \\

**struct** readahead_control ractl = { \\

.file = f, \\

.mapping = m, \\

.ra = r, \\

.\_index = i, \\

}



*Listing 9-60:* include/linux/pagemap.h: [*DEFINE_READAHEAD()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1178)







This initialises the file, mapping, ra and \_index fields as specified and ze-

roes the \_nr_pages and \_batch_count fields.

We examine file readahead state described by [struct file_ra_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n922) in List-

ing 9-61.



908 */\*\**

909 *\* struct file_ra_state - Track a file's readahead state.* 910 *\* @start: Where the most recent readahead started.* 911 *\* @size: Number of pages read in the most recent readahead.* 912 *\* @async_size: Numer of pages that were/are not needed immediately* 913 *\** *and so were/are genuinely "ahead". Start next readahead when* 914 *\** *the first of these pages is accessed.* 915 *\* @ra_pages: Maximum size of a readahead request, copied from the bdi.* 916 *\* @mmap_miss: How many mmap accesses missed in the page cache.* 917 *\* @prev_pos: The last byte in the most recent read request.* 918 *\**

919 *\* When this structure is passed to -\>readahead(), the "most recent"* 920 *\* readahead means the current readahead.* 921 *\*/*

922 **struct** file_ra_state {

923 **pgoff_t** start;

924 **unsigned int** size; 925 **unsigned int** async_size; 926 **unsigned int** ra_pages; 927 **unsigned int** mmap_miss; 928 **loff_t** prev_pos;

929 };



*Listing 9-61:* include/linux/fs.h: [*struct file_ra_state*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n922)



Examining each field:



**start** The index within the [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) page cache object in which

readahead started.

**size** The number of pages read so far in this readahead.

**async_size** The number of pages from the end of the range at which we

wish to start the next readahead attempt, asynchronously. We keep track

of this by tagging this folio with the [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143) flag (note—only if the folio was not already present in the page cache), which is checked on mi-nor fault and serviced via the asynchronous readahead code path (see

Section 9.7.2).

**ra_pages** Maximum number of pages to readahead, derived from

[struct backing_dev_info](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n165)-\>ra_pages.

**mmap_miss** The number of times a page fault for a given file has led to

a major fault, indicating a cache miss from readahead. We use this in

[do_sync_mmap_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2968) to determine whether to give up on readahead

altogether (if the miss count exceeds [MMAP_LOTSAMISS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2915)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2915) hardcoded to 100 cache misses for a file, then we give up).







**prev_pos** The last byte from the latest read request.



This type is initialised in [file_ra_state_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n139), performed on file open, as

shown in Listing 9-62.



134 */\**

135 *\* Initialise a struct file's readahead state. Assumes that the caller has*

136 *\* memset \*ra to zero.*

137 *\*/*

138 **void**

139 **file_ra_state_init**(**struct** file_ra_state \*ra, **struct** address_space \*mapping) 140 {

141 ra-\>ra_pages = **inode_to_bdi**(mapping-\>host)-\>ra_pages; 142 ra-\>prev_pos = -1; 143 }



*Listing 9-62:* mm/readahead.c: [*file_ra_state_init()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n139)

This function simply sets prev_pos to an invalid value and retrieves the

ra_pages field from the BDI field [struct backing_dev_info-\>ra_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n165) as previ-ously discussed.



***9.7.1 Synchronous Readahead***

There is a significant difference between the reads performed by

[filemap_get_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2546) originating from a [read()](https://man7.org/linux/man-pages/man2/read.2.html) which spans a buffer’s worth of

read and therefore multiple folios and those originating from [filemap_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3084) which comprise the faulting in of a single folio.

We start by examining the conceptually simpler of the two— a file-backed

page fault handled by [filemap_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3084). If a major fault occurs here , we per-

form synchronous readahead via [do_sync_mmap_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2968)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2968) which we examine

in Listing 9-63 (eliding out of scope transparent huge page handling).



2691 */\**

2692 *\* Synchronous readahead happens when we don't even find a page in the page*

2693 *\* cache at all. We don't want to perform IO under the mmap sem, so if we*

*have*

2694 *\* to drop the mmap sem we return the file that was pinned in order for us to*

*do*

2695 *\* that. If we didn't pin a file then we return NULL. The file that is* 2696 *\* returned needs to be fput()'ed when we're done with it.* 2697 *\*/*

2698 **static struct** file \***do_sync_mmap_readahead**(**struct** vm_fault \*vmf) 2699 {

2700 **struct** file \*file = vmf-\>vma-\>vm_file; 2701 **struct** file_ra_state \*ra = &file-\>f_ra; 2702 **struct** address_space \*mapping = file-\>f_mapping; 2703 **DEFINE_READAHEAD**(ractl, file, ra, mapping, vmf-\>pgoff); 2704 **struct** file \*fpin = **NULL**; 2705 **unsigned long** vm_flags = vmf-\>vma-\>vm_flags;







2706 **unsigned int** mmap_miss;

. . .

2726 */\* If we don't want any read-ahead, don't bother \*/* 2727 **if** (vm_flags & **VM_RAND_READ**) 2728 **return** fpin; 2729 **if** (!ra-\>ra_pages) 2730 **return** fpin; 2731

2732 **if** (vm_flags & **VM_SEQ_READ**) { 2733 fpin = **maybe_unlock_mmap_for_io**(vmf, fpin); 2734 **page_cache_sync_ra**(&ractl, ra-\>ra_pages); 2735 **return** fpin; 2736 }

2737

2738 */\* Avoid banging the cache line if not needed \*/* 2739 mmap_miss = **READ_ONCE**(ra-\>mmap_miss); 2740 **if** (mmap_miss \< **MMAP_LOTSAMISS** \* 10) 2741 **WRITE_ONCE**(ra-\>mmap_miss, ++mmap_miss); 2742

2743 */\**

2744 *\* Do we miss much more than hit in this file? If so,* 2745 *\* stop bothering with read-ahead. It will only hurt.* 2746 *\*/*

2747 **if** (mmap_miss \> **MMAP_LOTSAMISS**) 2748 **return** fpin; 2749

2750 */\**

2751 *\* mmap read-around* 2752 *\*/*

2753 fpin = **maybe_unlock_mmap_for_io**(vmf, fpin); 2754 ra-\>start = **max_t**(**long**, 0, vmf-\>pgoff - ra-\>ra_pages / 2); 2755 ra-\>size = ra-\>ra_pages; 2756 ra-\>async_size = ra-\>ra_pages / 4; 2757 ractl.\_index = ra-\>start; 2758 **page_cache_ra_order**(&ractl, ra, 0); 2759 **return** fpin;

2760 }



*Listing 9-63:* mm/filemap.c: [*do_sync_mmap_readahead()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2968)



The function forms part of the faulting mechanism, so will be performed

with the [struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) held. Since this can be significantly con-

tended, we want the ability to be able to drop this lock if I/O in the form of

reading data from disk is performed. If so, the file which is being read into

must be pinned, i.e. have its reference count increased so the object is not

released.







As a result, this function returns a pointer to a [struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) object if the

lock was dropped and a file object was pinned, returning the pinned file.

See Section 6.2 for more details.

We see the use of the [DEFINE_READAHEAD()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1178) macro as shown in List-

ing 9-60 above to define the [struct readahead_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1168) to be threaded

through readahead calls, specifying that [struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940)-\>f_ra be used as the

[struct file_ra_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n922) state.

The other fields placed into the [struct readahead_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1168) object are

straightforward — the faulting file, the [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) page cache ob-ject to which the faulting folio belongs and the page offset of the folio within

the page cache object specified by [struct vm_fault-\>pgoff](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n481).

Immediately, we check to see if the [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) mapping

the faulting folio has the [VM_RAND_READ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n287) flag set, indicating that the mapping is to be accessed in random fashion, i.e. not sequentially. In this case there is no point in proceeding with readahead and we simply abort.

Equally, if the BDI or user indicates that the maximum number of reada-

head pages is zero, then readahead cannot proceed and we also abort the operation in this instance.



**9.7.1.1 Sequential Page Fault Read**

We then determine which of the two modes we will utilise to perform readahead—the first of which is to retrieve the maximum possible number of

readahead pages. This is performed when the [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA)

flag [VM_SEQ_READ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n286) is specified, i.e. indicating sequential readahead (the user

having specified [MADV_SEQUENTIAL](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/asm-generic/mman-common.h?h=v6.0#n45) via [madvise()](https://man7.org/linux/man-pages/man2/madvise.2.html)).

In this instance, we try to drop the [struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) for I/O via

[maybe_unlock_mmap_for_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n607) (see Listing **??** in the page fault chapter for a de-tailed explanation of this) before proceeding with the readahead operation

via [page_cache_sync_ra()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n675) which we explore below in Listing 9-65, specifying

the maximum number of pages to readahead, [struct file_ra_state-\>ra_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n922).

Note that we perform readahead in this mode starting at the current off-

set within the file. We also do not attempt to track whether page faults are being missed, but unconditionally perform readahead in this instance.

When we perform readahead in this mode, this results in ‘on demand’

readahead ultimately invoking [ondemand_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n556)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n556) which heuristically deter-

mines how to size the readahead. We explore this in Listing 9-70 below.



**9.7.1.2 mmap Readaround**

The alternative mode does not start at the current offset within the file, rather it reads around the faulting folio on the assumption that perhaps the user might read backwards as well as forwards. We keep track of how well

readahead is helping with this file using the [struct file_ra_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n922)-\>mmap_miss field.

Each time this function is invoked, it implies a readahead cache miss (as

otherwise we’d not have encountered a major fault), so we increment the

[struct file_ra_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n922)-\>mmap_miss count, unless it exceeds the [MMAP_LOTSAMISS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2915) limit multiplied by 10 at which it is capped.







Each time a cache hit occurs (i.e. a minor fault within the file) this count

is decremented. This occurs in [do_async_mmap_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3037)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3037)

If, at this stage, we exceed the [MMAP_LOTSAMISS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2915) limit (hardcoded to 100

pages), we abort the operation.

Otherwise we specify readahead at the maximum readahead size, cen-

tered on the offset of the page fault within the file, clamping to the start

of the file if necessary. As with the sequential case, we try to drop the

[struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) if we can via [maybe_unlock_mmap_for_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n607), before

proceeding with readahead via [page_cache_ra_order()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n490) as described in Listing

9-77 below.

The configuration of the [struct file_ra_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n922) object is such as to per-

form readahead as shown in Figure 9-11, where each square represents a fo-

lio within the file, the black square indicates the faulting folio, and the grey

square indicates where the [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143) flag will be set, i.e. the point at which

asynchronous readahead will be started next.

The readahead is placed within the middle of the range of pages we

readahead, with the async size equal to one quarter of this range (rounded

down as performed with integers).



ra-\>ra_pages



... ...

vmf-\>pgoff

ra-\>async_size



*Figure 9-11: mmap Readaround Readahead Range*



**9.7.1.3 read() Synchronous Readahead**

If [filemap_get_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2546) (see Listing 9-44 and Section 9.5.2), invoked as

part of a [read()](https://man7.org/linux/man-pages/man2/read.2.html) operation, cannot retrieve any of a batch of folios as

part of the operation, then it proceeds with synchronous readahead

via [page_cache_sync_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1210)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1210) specifying the requested folio count

of req_count equal to the number of folios yet to be read. We examine

[page_cache_sync_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1210) in Listing 9-64.



1196 */\*\**

1197 *\* page_cache_sync_readahead - generic file readahead* 1198 *\* @mapping: address_space which holds the pagecache and I/O vectors* 1199 *\* @ra: file_ra_state which holds the readahead state* 1200 *\* @file: Used by the filesystem for authentication.* 1201 *\* @index: Index of first page to be read.* 1202 *\* @req_count: Total number of pages being read by the caller.* 1203 *\**

1204 *\* page_cache_sync_readahead() should be called when a cache miss happened:*

1205 *\* it will submit the read. The readahead logic may decide to piggyback more*

1206 *\* pages onto the read request if access patterns suggest it will improve* 1207 *\* performance.*

1208 *\*/*







1209 **static inline**

1210 **void page_cache_sync_readahead**(**struct** address_space \*mapping, 1211 **struct** file_ra_state \*ra, **struct** file \*file, **pgoff_t** index, 1212 **unsigned long** req_count) 1213 {

1214 **DEFINE_READAHEAD**(ractl, file, ra, mapping, index); 1215 **page_cache_sync_ra**(&ractl, req_count); 1216 }



*Listing 9-64:* include/linux/pagemap.h: [*page_cache_sync_readahead()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1210)

This declares a [struct readahead_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1168) object to proceed with the reada-

head via [DEFINE_READAHEAD()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1178) macro as shown in Listing 9-60 above, where the

[struct file_ra_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n922) ra parameter has been set by [filemap_get_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2546) to point

to [struct file-\>f_ra](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940).

This object is then passed to [page_cache_sync_ra()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n675) which we examine in

Listing 9-65 below.



**9.7.1.4 Shared Synchronous Readahead**

Both page fault handling invoking synchronous readahead when [VM_SEQ_READ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n286)

is specified, and [filemap_get_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2546) when synchronous readahead is per-

formed in general, ultimately invoke [page_cache_sync_ra()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n675) which we explore

in Listing 9-65.



675 **void page_cache_sync_ra**(**struct** readahead_control \*ractl, 676 **unsigned long** req_count) 677 {

678 **bool** do_forced_ra = ractl-\>file && (ractl-\>file-\>f_mode & **FMODE_RANDOM**

);

679

680 */\**

681 *\* Even if readahead is disabled, issue this request as readahead* 682 *\* as we'll need it to satisfy the requested range. The forced* 683 *\* readahead will do the right thing and limit the read to just the*

684 *\* requested range, which we'll set to 1 page for this case.* 685 *\*/*

686 **if** (!ractl-\>ra-\>ra_pages \|\| **blk_cgroup_congested**()) { 687 **if** (!ractl-\>file) 688 **return**; 689 req_count = 1; 690 do_forced_ra = **true**; 691 }

692

693 */\* be dumb \*/*

694 **if** (do_forced_ra) { 695 **force_page_cache_ra**(ractl, req_count); 696 **return**;

697 }

698







699 **ondemand_readahead**(ractl, **NULL**, req_count); 700 }



*Listing 9-65:* mm/readahead.c: [*page_cache_sync_ra()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n675)

This first checks to see whether the [FMODE_RANDOM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n143) flag has been set on the

file (i.e. specified by using [posix_fadvise()](https://man7.org/linux/man-pages/man2/posix_fadvise.2.html) specifying [POSIX_FADV_RANDOM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/fadvise.h?h=v6.0#n6)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/fadvise.h?h=v6.0#n6)

Ordinarily you’d expect this to mean the readahead

would be aborted, and until Linux 2.6.33 in 2010 at commit

[0141450f66c3: readahead: introduce FMODE_RANDOM for POSIX_FADV_RANDOM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=0141450f66c3)

this was so.

However, it was determined that, despite the file being labelled random-

access, reads performed by [read()](https://man7.org/linux/man-pages/man2/read.2.html) would simply invoke multiple reads when

all could have been read in one operation.

This logic is not relevant to page fault on a file-backed mapping with the

[VM_RAND_READ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n287) flag set, as this would have been aborted before reaching here

(this logic wouldn’t be useful in that case, as indeed a file-backed mapping

can be accessed in random fashion and isn’t read a buffer size at a time,

rather a folio at a time by the user).

When this edge case arises, we force the readahead via

[force_page_cache_ra()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n300) which we examine in Listing 9-66 below.

We also consider the case where readahead is disabled altogether—i.e.

where [struct file_ra_state-\>ra_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n922) is set to zero. This may be due to the

device being unable to service readahead, an error having occurred which

caused readahead to be disabled or the user specifying it should not occur.

Note that we do not consider the blk_cgroup_congested() check here as this is

cgroup-related and thus out of scope for the book.

In the case that readahead is disabled, we limit ourself to a single folio

and perform a force readahead so we do at least provide the minimum re-

quired folio.

Note that any folio returned will not be read immediately, but rather have

the I/O scheduled asynchronously. The caller must deal with a folio which

is not yet uptodate (which both [read()](https://man7.org/linux/man-pages/man2/read.2.html)-mandated and page fault-mandated

readahead do).

In the likely case that readahead is not forced, then we perform ‘on de-

mand’ readahead via [ondemand_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n556), which we explore in Listing 9-70

below.



**9.7.1.5 Forced Readahead**

When readahead should no proceed normally due to a file having

[FMODE_RANDOM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n143) set or if readahead is disabled altogether, we force a simple form

of readahead via [force_page_cache_ra()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n300) as shown in Listing 9-66 below.



296 */\**

297 *\* Chunk the readahead into 2 megabyte units, so that we don't pin too much*

298 *\* memory at once.*

299 *\*/*

300 **void force_page_cache_ra**(**struct** readahead_control \*ractl, 301 **unsigned long** nr_to_read)







302 {

303 **struct** address_space \*mapping = ractl-\>mapping; 304 **struct** file_ra_state \*ra = ractl-\>ra; 305 **struct** backing_dev_info \*bdi = **inode_to_bdi**(mapping-\>host); 306 **unsigned long** max_pages, index; 307

308 **if** (**unlikely**(!mapping-\>a_ops-\>read_folio && !mapping-\>a_ops-\>readahead

))

309 **return**;

310

311 */\**

312 *\* If the request exceeds the readahead window, allow the read to*

313 *\* be up to the optimal hardware IO size* 314 *\*/*

315 index = **readahead_index**(ractl); 316 max_pages = **max_t**(**unsigned long**, bdi-\>io_pages, ra-\>ra_pages); 317 nr_to_read = **min_t**(**unsigned long**, nr_to_read, max_pages); 318 **while** (nr_to_read) { 319 **unsigned long** this_chunk = (2 \* 1024 \* 1024) / **PAGE_SIZE**; 320

321 **if** (this_chunk \> nr_to_read) 322 this_chunk = nr_to_read; 323 ractl-\>\_index = index; 324 **do_page_cache_ra**(ractl, this_chunk, 0); 325

326 index += this_chunk; 327 nr_to_read -= this_chunk; 328 }

329 }



*Listing 9-66:* mm/readahead.c: [*force_page_cache_ra()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n300)



This aborts if the [struct address_space-\>a_ops](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) address space operations

of the [struct address_space_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n356) page cache object do not specify a readahead() or a read_folio() callback (the latter is used as a fallback if the first is not specified when performing readahead) as readahead in that in-stance simply cannot proceed.

Otherwise, a simple form of readahead proceeds until all requested

pages have been readahead.

The [struct backing_dev_info-\>io_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n165) field determines the maximum

number of pages which can be read in a single submitted I/O request and thus sets a ceiling on the maximum number of pages to be read

(which is otherwise set to [struct file_ra_state-\>ra_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n922) which defaults to

[struct backing_dev_info](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n165)-\>ra_pages, but can be altered elsewhere).

We use this value as a ceiling on nr_to_read which specifies how many

pages should be force-readahead. We then loop, reading up to a maximum

of 2 MiB chunks of data at a time, using [do_page_cahe_ra()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n275) to do the heavy lifting.







***9.7.2 Asynchronous Readahead***

Asynchronous readahead is performed when a minor fault occurs, i.e. the

page cache entry is found on page fault or [read()](https://man7.org/linux/man-pages/man2/read.2.html)[-mandat](https://man7.org/linux/man-pages/man2/read.2.html)ed file read, and the

most recently read folio has the [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143) flag set.

This is set by either synchronous or asynchronous readahead logic on a

folio to trigger readahead again ahead of a further major fault (thus inter-

leaving readahead operations). Importantly, note that this flag will not be set

on any folio that already existed within the page cache at the point at which

readahead is occurring.

In the case of a [read()](https://man7.org/linux/man-pages/man2/read.2.html)[-mandat](https://man7.org/linux/man-pages/man2/read.2.html)ed minor fault read operation occurring in

[filemap_get_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2546) (see Listing 9-44 above) [filemap_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2534) is invoked to

handle the asynchronous readahead, which we examine in Listing 9-67. This

function is only called if the [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143) flag was set on the folio.



2534 **static int filemap_readahead**(**struct** kiocb \*iocb, **struct** file \*file, 2535 **struct** address_space \*mapping, **struct** folio \*folio, 2536 **pgoff_t** last_index) 2537 {

2538 **DEFINE_READAHEAD**(ractl, file, &file-\>f_ra, mapping, folio-\>index); 2539

2540 **if** (iocb-\>ki_flags & **IOCB_NOIO**) 2541 **return**-**EAGAIN**; 2542 **page_cache_async_ra**(&ractl, folio, last_index - folio-\>index); 2543 **return** 0;

2544 }



*Listing 9-67:* mm/filemap.c: [*filemap_readahead()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2534)



This defines the [struct readahead_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1168) object as you would expect

using [DEFINE_READAHEAD()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1178) macro (as shown in Listing 9-60 above), however

note that it explicitly sets the \_index field to [struct folio-\>index](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256), i.e. setting

the operation to proceed forward at and including the folio marked by

[PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143).

If the kernel I/O operation [struct kiocb](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n341) state variable iocb has the

[IOCB_NOIO](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n337) flag set, we must abort with a EAGAIN error as of course, we are

about to perform I/O.

We then defer the operation to [page_cache_async_ra()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n703), specifying that the

entire range of data starting from this folio is to be read. We examine this

function below in Listing 9-69.



**N O T E** As discussed above around [*filemap_get_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2546) (see Listing 9-44), if the range of

folios being read is page-aligned, and we have read only part of the file, then we will

read one folio after the range, i.e. inclusive of *last_index*. We may also mark this fo-

lio with [*PG_readahead*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143), in which case we will immediately trigger readahead, invoking

[*filemap_readahead()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2534) with *last_index* equal to [*struct folio*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256)*-\>index*, therefore passing

a *req_count* of 0 to [*page_cache_async_ra()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n703).



In the case of a page fault, [filemap_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3084) unconditionally calls

[do_async_mmap_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3037) as long as this is the first time the fault has







been tried. It does this without checking for [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143) leaving this to

[do_async_mmap_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3037) to perform. We examine this function in Listing

9-68.



3032 */\**

3033 *\* Asynchronous readahead happens when we find the page and PG_readahead,* 3034 *\* so we want to possibly extend the readahead further. We return the file*

*that*

3035 *\* was pinned if we have to drop the mmap_lock in order to do IO.* 3036 *\*/*

3037 **static struct** file \***do_async_mmap_readahead**(**struct** vm_fault \*vmf, 3038 **struct** folio \*folio) 3039 {

3040 **struct** file \*file = vmf-\>vma-\>vm_file; 3041 **struct** file_ra_state \*ra = &file-\>f_ra; 3042 **DEFINE_READAHEAD**(ractl, file, ra, file-\>f_mapping, vmf-\>pgoff); 3043 **struct** file \*fpin = **NULL**; 3044 **unsigned int** mmap_miss; 3045

3046 */\* If we don't want any read-ahead, don't bother \*/* 3047 **if** (vmf-\>vma-\>vm_flags & **VM_RAND_READ** \|\| !ra-\>ra_pages) 3048 **return** fpin; 3049

3050 mmap_miss = **READ_ONCE**(ra-\>mmap_miss); 3051 **if** (mmap_miss)

3052 **WRITE_ONCE**(ra-\>mmap_miss, --mmap_miss); 3053

3054 **if** (**folio_test_readahead**(folio)) { 3055 fpin = **maybe_unlock_mmap_for_io**(vmf, fpin); 3056 **page_cache_async_ra**(&ractl, folio, ra-\>ra_pages); 3057 }

3058 **return** fpin;

3059 }



*Listing 9-68:* mm/filemap.c: [*do_async_mmap_readahead()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3037)



This defines the readahead object as you would expect via

[DEFINE_READAHEAD()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1178) macro (as shown in Listing 9-60 above), maintaining the

same file pinning logic as described above in Section 9.7.1 for synchronous readahead.

If the [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) mapping specifies the [VM_RAND_READ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n287) flag

or readahead is disabled, there is nothing to do and we simply exit.

Otherwise, we update the [struct file_ra_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n922)-\>mmap_miss field, reducing

the miss count even if this folio does not specify [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143), as the fact a minor fault occurred at all implies a cache hit.

Finally, if [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143) is specified, we go ahead and invoke asynchronous

readahead, first performing the [struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) dropping

dance via [maybe_unlock_mmap_for_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n607) before performing the readahead via

[page_cache_async_ra()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n703) which we examine in Listing 9-69 below.







**9.7.2.1 Shared Asynchronous Readahead**

Asynchronous readahead for both [read()](https://man7.org/linux/man-pages/man2/read.2.html)[-mandat](https://man7.org/linux/man-pages/man2/read.2.html)ed and page fault reada-

head is ultimately deferred to [page_cache_async_ra()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n703) which we examine in List-

ing 9-69 below (eliding out of scope cgroup logic).



703 **void page_cache_async_ra**(**struct** readahead_control \*ractl, 704 **struct** folio \*folio, **unsigned long** req_count) 705 {

706 */\* no readahead \*/* 707 **if** (!ractl-\>ra-\>ra_pages) 708 **return**;

709

710 */\**

711 *\* Same bit is used for PG_readahead and PG_reclaim.* 712 *\*/*

713 **if** (**folio_test_writeback**(folio)) 714 **return**;

715

716 **folio_clear_readahead**(folio);

. . .

721 **ondemand_readahead**(ractl, folio, req_count); 722 }



*Listing 9-69:* mm/readahead.c: [*page_cache_async_ra()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n703)



If readahead is disabled (indicated by the [struct file_ra_state-\>ra_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n922)

field being set to zero), then there is nothing to do here and we abort.

Otherwise we are careful about writebac[k—](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n116)[PG_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n116) implies that the

[PG_reclaim](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n119) flag might be set, which [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143) overloads and so in this in-

stance, to avoid a bug arising from this being unintentionally set, we abort

the operation.

Otherwise, we clear the [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143) flag as we are now about to process

it and we do not want a competing asynchronous readahead operation to

begin.

Finally, we defer the actual readahead to on-demand readahead via

[ondemand_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n556), which we explore in Listing 9-70 below.



***9.7.3 On-Demand Readahead***

When asynchronous readahead occurs, or either synchronous [read()](https://man7.org/linux/man-pages/man2/read.2.html)[-](https://man7.org/linux/man-pages/man2/read.2.html)

mandated readahead (via [filemap_get_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2546) shown in Listing 9-44 above)

or page fault-mandated synchronous readahead in the presence of the

[VM_SEQ_READ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n286) flag occurs, this results in the kernel performing ‘on-demand’

readahead.

In this instance, the kernel is permitted to use heuristics to determine

how to adjust the readahead as it proceeds rather than it being mandated by

a caller.

As this function is rather complicated and relies upon heuristics, we will

briefly examine an example of how readahead behaves for a series of se-







quential [read()](https://man7.org/linux/man-pages/man2/read.2.html) operations of 1 page each of a very large file not yet in the page cache, with a maximum readahead count of 32 pages, as shown in Fig-

ure 9-12.



...



Sync RA R ...

4 pages

Async RA R R ... ...

8 pages

Async RA R ... R ... ...

16 pages

Async RA ... R ... R ... ...

32 pages

Async RA ... ... R ... R ... ...

32 pages

etc.



*Figure 9-12: Example On-Demand* [*read()*](https://man7.org/linux/man-pages/man2/read.2.html) *Readahead for Sequential Single-Page Reads*



Note that dashed boxes denote folios not yet in the page cache, the

shaded boxes denote the folio currently being read by [filemap_get_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2546)

(see Listing 9-44) and R denotes the folio tagged with the [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143) flag.

As we will examine shortly, the initial synchronous readahead is scaled

to 4 pages given a maximum number of readahead pages of 32 pages (which the typical default) and reading a single page at a time. This is determined

by [get_init_ra_size()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n337) (see Listing 9-76 below).

The first folio tagged with [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143) is offset by the request size (in this

case 1 page). Since [filemap_get_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2546) reads an additional page past the last

if page-aligned (see discussion around Listing 9-44 for details), we will always trigger the first asynchronous readahead immediately after the synchronous one.

This first asynchronous readahead then doubles the readahead size to 8

pages, as mandated by [get_next_ra_size()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n355) (see Listing 9-72).

From here on in the process continues until we reach the maximum

readahead size of 32 pages. Note that we enter into a pattern of kicking off asynchronous readahead at the start of processing the minor faults associ-ated with the next readhead block of folios, so are continually avoiding ma-jor faults on a sequential read, as intended.

Even if the user closes the file descriptor and opens another reading the

same file (and thus we no longer have access to the [struct file_ra_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n922) ob-

ject in [struct file-\>f_ra](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940)), we are able to recover this state on encountering

the next [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143) via [page_cache_next_miss()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1765) (see this in context in Listing

9-71 below).

In fact, even in the case of synchronous readahead that is not the

first that has occurred in the file, we attempt to ascertain any evidence of







context-based sequential reads via [try_context_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n427) (see Listing 9-73

below).

In all cases the on-demand readahead does its best to read in pages if

there’s any evidence at all of sequential reads, given the significant perfor-

mance benefits of having this data in memory rather than having to wait for

it to be read from the disk.

As we explore in the reclaim chapter, the kernel very quickly reads in

page cache data but will equally quickly reclaim it under memory pressure,

so it is entirely fine to be profligate here.

Let’s examine this in detail in the function which performs on-demand

readahead, [ondemand_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n556), which we examine starting with Listing 9-70

below.



553 */\**

554 *\* A minimal readahead algorithm for trivial sequential/random reads.* 555 *\*/*

556 **static void ondemand_readahead**(**struct** readahead_control \*ractl, 557 **struct** folio \*folio, **unsigned long** req_size) 558 {

559 **struct** backing_dev_info \*bdi = **inode_to_bdi**(ractl-\>mapping-\>host); 560 **struct** file_ra_state \*ra = ractl-\>ra; 561 **unsigned long** max_pages = ra-\>ra_pages; 562 **unsigned long** add_pages; 563 **pgoff_t** index = **readahead_index**(ractl); 564 **pgoff_t** expected, prev_index; 565 **unsigned int** order = folio ? **folio_order**(folio) : 0;

566

567 */\**

568 *\* If the request exceeds the readahead window, allow the read to* 569 *\* be up to the optimal hardware IO size* 570 *\*/*

571 **if** (req_size \> max_pages && bdi-\>io_pages \> max_pages) 572 max_pages = **min**(req_size, bdi-\>io_pages);



*Listing 9-70:* mm/readahead.c: [*ondemand_readahead()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n556) *prelude*



We start by obtaining the index from which we should proceed from

the [struct readahead_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1168) object and the folio order if a folio is sup-

plied (if a folio is supplied, this implies asynchronous readahead). We

also place the maximum pages that can be readahead, derived from

[struct file_ra_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n922)-\>ra_pages in max_pages.

We then check to ensure that the requested readahead size exceeds

the maximum pages. If it does this not taken as a hard limit, rather the

[struct backing_dev_info](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n165)-\>io_pages field indicating the maximum optimal num-

ber of pages to retrieve in a single I/O operation is used as maximum page

count.

Once we have established some initial state, we start trying to heuristi-

cally determine where we are with the readahead and how to proceed, which

we explore in Listing 9-71.







574 */\**

575 *\* start of file*

576 *\*/*

577 **if** (!index)

578 **goto initial_readahead**; 579

580 */\**

581 *\* It's the expected callback index, assume sequential access.*

582 *\* Ramp up sizes, and push forward the readahead window.* 583 *\*/*

584 expected = **round_up**(ra-\>start + ra-\>size - ra-\>async_size, 585 1**UL** \<\< order); 586 **if** (index == expected \|\| index == (ra-\>start + ra-\>size)) { 587 ra-\>start += ra-\>size; 588 ra-\>size = **get_next_ra_size**(ra, max_pages); 589 ra-\>async_size = ra-\>size; 590 **goto readit**; 591 }

592

593 */\**

594 *\* Hit a marked folio without valid readahead state.* 595 *\* E.g. interleaved reads.* 596 *\* Query the pagecache for async_size, which normally equals to*

597 *\* readahead size. Ramp it up and use it as the new readahead size.*

598 *\*/*

599 **if** (folio) {

600 **pgoff_t** start; 601

602 **rcu_read_lock**(); 603 start = **page_cache_next_miss**(ractl-\>mapping, index + 1, 604 max_pages); 605 **rcu_read_unlock**(); 606

607 **if** (!start \|\| start - index \> max_pages) 608 **return**; 609

610 ra-\>start = start; 611 ra-\>size = start - index; */\* old async_size \*/* 612 ra-\>size += req_size; 613 ra-\>size = **get_next_ra_size**(ra, max_pages); 614 ra-\>async_size = ra-\>size; 615 **goto readit**; 616 }

617

618 */\**

619 *\* oversize read*

620 *\*/*







621 **if** (req_size \> max_pages) 622 **goto initial_readahead**;

623

624 */\**

625 *\* sequential cache miss* 626 *\* trivial case: (index - prev_index) == 1* 627 *\* unaligned reads: (index - prev_index) == 0* 628 *\*/*

629 prev_index = (**unsigned long long**)ra-\>prev_pos \>\> **PAGE_SHIFT**; 630 **if** (index - prev_index \<= 1**UL**) 631 **goto initial_readahead**;

632

633 */\**

634 *\* Query the page cache and look for the traces(cached history pages)*

635 *\* that a sequential stream would leave behind.* 636 *\*/*

637 **if** (**try_context_readahead**(ractl-\>mapping, ra, index, req_size, 638 max_pages)) 639 **goto readit**;



*Listing 9-71:* mm/readahead.c: [*ondemand_readahead()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n556) *heuristics*



We have special handling for the case where we are at the beginning of

the file under readahead, so if the readahead index is 0, we proceed to this

immediately.

Next we consider the asynchronous readahead case— we expect asyn-

chronous readahead to kick in precisely [struct file_ra_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n922)-\>async_size

pages prior to the end of the range (see Figure 9-11 for instance). In the

instance we have an asynchronous readahead hit and prepare for the next

readahead.

In this instance, we proceed with readahead, offsetting the next reada-

head to proceed immediately after the folios the last readahead populated,

setting the asynchronous size to be equal to the readahead size (i.e. placing

it at the start of the next readahead batch) and obtaining the new readahead

size via [get_next_ra_size()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n355)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n355) which we examine in Listing 9-72.



351 */\**

352 *\* Get the previous window size, ramp it up, and* 353 *\* return it as the new window size.* 354 *\*/*

355 **static unsigned long get_next_ra_size**(**struct** file_ra_state \*ra, 356 **unsigned long** max) 357 {

358 **unsigned long** cur = ra-\>size;

359

360 **if** (cur \< max / 16) 361 **return** 4 \* cur; 362 **if** (cur \<= max / 2) 363 **return** 2 \* cur;







364 **return** max;

365 }



*Listing 9-72:* mm/readahead.c: [*get_next_ra_size()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n355)



This is entirely heuristic and scales the readahead by a factor of 4 if the

size is less than 1/16th of the maximum possible (meaning at most 2 scale up operations are necessary to surpass this), doubles it if it is less than or equal to half of the maximum readahead size and set to the maximum reada-head size otherwise.

Note that, since we will now proceed with this readahead, all readahead

pages should be in place when the folio at the beginning of the next block

which will have [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143) set is encountered, we should encounter no ma-jor faults.

If we do encounter a major fault (perhaps by accessing a folio out-

side of the readahead range, perhaps due to an interleaved read), the

[struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940)-\>f_ra will be reset.

In this case, we might encounter a [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143) flag but this occurring in

an unexpected position. In this instance, the folio parameter will be set by the calling asynchronous readahead handler so we can explicitly check for it.

Here we attempt to heuristically determine where the next block should

be located via [page_cache_next_miss()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1765), which scans the page cache looking for a non-present page from this point on.

If none is found, or it is located beyond the maximum number of reada-

head pages we abort.

Otherwise we setup the next readahead using this heuristically obtained

information in precisely the same way as if it were discovered where it was expected.

Next we consider the case where the requester requested more than the

maximum pages (even taking into account the increase that is applied to

[struct backing_dev_info](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/backing-dev-defs.h?h=v6.0#n165)-\>io_pages), which we treat the same as if this were ini-tial readahead which we explore below.

The [struct file_ra_state-\>prev_pos](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n922) field is updated in [filemap_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2626) on

each read to indicate the position of the last [read()](https://man7.org/linux/man-pages/man2/read.2.html)-mandated read. If this is was 0 or 1 pages ago, we again treat this as if it were initial readahead as this implies a sequential cache miss.

This might be caused by a series of [read()](https://man7.org/linux/man-pages/man2/read.2.html) invocations of a single page

which amount to sequential reads and thus imply that readahead on this ba-sis makes sense here.

Finally we become fully heuristic and go to great lengths to deter-

mine whether traces exist that imply a sequential read is proceeding, via

[try_context_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n427) which we examine in Listing 9-73 below.



424 **static int try_context_readahead**(**struct** address_space \*mapping, 425 **struct** file_ra_state \*ra, 426 **pgoff_t** index, 427 **unsigned long** req_size, 428 **unsigned long** max) 429 {







430 **pgoff_t** size;

431

432 size = **count_history_pages**(mapping, index, max);

433

434 */\**

435 *\* not enough history pages:* 436 *\* it could be a random read* 437 *\*/*

438 **if** (size \<= req_size) 439 **return** 0;

440

441 */\**

442 *\* starts from beginning of file:* 443 *\* it is a strong indication of long-run stream (or whole-file-read)*

444 *\*/*

445 **if** (size \>= index) 446 size \*= 2;

447

448 ra-\>start = index; 449 ra-\>size = **min**(size + req_size, max); 450 ra-\>async_size = 1;

451

452 **return** 1;

453 }



*Listing 9-73:* mm/readahead.c: [*try_context_readahead()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n427)



This utilises [count_history_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n412) (which we examine in Listing 9-74

below) to determine how many pages from index - 1 up to index - max are

present in the page cache as an estimate on contiguously cached pages indi-

cating a sequential read pattern.

If the size is less than that requested, we accept that this is not a sequen-

tial read pattern.

Otherwise, we accept that it is. If the cached page count in size equals

or exceeds the index, i.e. offset into the file, this indicates that entries from

the start of the file to here have been stored in the page cache, which heavily

implies that this is a read of the whole file, at which point the size is doubled

to increase the readahead we are about to establish.

We then set [struct file_ra_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n922)fields such that we start at the current in-

dex, reading the combination of the size we have established was previously

contiguously read in (possibly doubled) and the requested size (up to a max-

imum of the maximum readahead size), and establish that we will provoke

the next asynchronous readahead at the end of this block.

Examining [count_history_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n412) in Listing 9-74:



406 */\**

407 *\* Count contiguously cached pages from @index-1 to @index-@max,* 408 *\* this count is a conservative estimation of* 409 *\** *- length of the sequential read sequence, or*







410 *\** *- thrashing threshold in memory tight systems* 411 *\*/*

412 **static pgoff_t count_history_pages**(**struct** address_space \*mapping, 413 **pgoff_t** index, **unsigned long** max) 414 {

415 **pgoff_t** head;

416

417 **rcu_read_lock**();

418 head = **page_cache_prev_miss**(mapping, index - 1, max); 419 **rcu_read_unlock**(); 420

421 **return** index - 1 - head; 422 }



*Listing 9-74:* mm/readahead.c: [*count_history_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n412)



This uses [page_cache_prev_miss()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1801) to scan backwards through the xarray

describing the [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) page cache object, returning the index of the first entry, starting from index - 1 which is not present in the cache.

Subtracting this from index - 1 provides the contiguous range. Finally, once all of these heuristics have been applied, we proceed with

actually executing readahead, as explored in Listing 9-75 below.



641 */\**

642 *\* standalone, small random read* 643 *\* Read as is, and do not pollute the readahead state.* 644 *\*/*

645 **do_page_cache_ra**(ractl, req_size, 0); 646 **return**;

647

648 **initial_readahead**:

649 ra-\>start = index; 650 ra-\>size = **get_init_ra_size**(req_size, max_pages); 651 ra-\>async_size = ra-\>size \> req_size ? ra-\>size - req_size : ra-\>size;

652

653 **readit**:

654 */\**

655 *\* Will this read hit the readahead marker made by itself?* 656 *\* If so, trigger the readahead marker hit now, and merge* 657 *\* the resulted next readahead window into the current one.* 658 *\* Take care of maximum IO pages as above.* 659 *\*/*

660 **if** (index == ra-\>start && ra-\>size == ra-\>async_size) { 661 add_pages = **get_next_ra_size**(ra, max_pages); 662 **if** (ra-\>size + add_pages \<= max_pages) { 663 ra-\>async_size = add_pages; 664 ra-\>size += add_pages; 665 } **else** {

666 ra-\>size = max_pages;







667 ra-\>async_size = max_pages \>\> 1; 668 }

669 }

670

671 ractl-\>\_index = ra-\>start; 672 **page_cache_ra_order**(ractl, ra, order); 673 }



*Listing 9-75:* mm/readahead.c: [*ondemand_readahead()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n556) *readahead invocations*



In the instance that no sequential readahead could be detected, then we

treat this like a random read, and defer it to [do_page_cache_ra()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n275) to perform

the readahead, specifying zero look ahead and not modifying the readahead

state at all.

In the case that initial readahead is to be performed, we reset the start

to the current index, determine the size to readahead via the heuristic

[get_init_ra_size()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n337) which we examine in Listing 9-76 below.

We set the position at which to perform the next asynchronous reada-

head operation (as mandated by [struct file_ra_state-\>async_size](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n922)) to be equal

to either the a number of pages equal to the newly determined size from the

end, should this size exceed that requested, or if not, offset by the requested

size.



331 */\**

332 *\* Set the initial window size, round to next power of 2 and square* 333 *\* for small size, x 4 for medium, and x 2 for large* 334 *\* for 128k (32 page) max ra* 335 *\* 1-2 page = 16k, 3-4 page 32k, 5-8 page = 64k, \> 8 page = 128k initial* 336 *\*/*

337 **static unsigned long get_init_ra_size**(**unsigned long** size, **unsigned long** max) 338 {

339 **unsigned long** newsize = **roundup_pow_of_two**(size);

340

341 **if** (newsize \<= max / 32) 342 newsize = newsize \* 4; 343 **else if** (newsize \<= max / 4) 344 newsize = newsize \* 2; 345 **else**

346 newsize = max;

347

348 **return** newsize;

349 }



*Listing 9-76:* mm/readahead.c: [*get_init_ra_size()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n337)



This heuristically determines the size to be equal to the requested size

rounded up to the nearest power of two and squared, then multiplied by 4

should it be less than or equal to 1/32 of the maximum readahead size, mul-

tiplied by 2 should be less than or equal to 1/4 of the maximum readahead

size or otherwise simply set to the maximum readahead size.







This then falls through to the readit label where sequential readahead is

performed, the same logic invoked by other logic above which calls into this.

There is an additional check to see if the specified we can merge the next

asynchronous readahead point, doing so if we can (note that we place the

next [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143) either at the start of the next readahead block or halfway through it if we are capped at the maximum readahead pages).

Finally, we set the [struct readahead_control](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1168) readahead index and defer

the actual readahead itself to the [page_cache_ra_order()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n490) function which we

explore in Listing 9-77 below.



***9.7.4 Common Readahead Code***

There are two functions which are ultimately invoked to perform the reada-

head into the page cache, [page_cache_ra_order()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n490) which we examine in Listing

9-77 below and [do_page_cache_ra()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n275) which we examine in Listing 9-78.



490 **void page_cache_ra_order**(**struct** readahead_control \*ractl, 491 **struct** file_ra_state \*ra, **unsigned int** new_order) 492 {

493 **struct** address_space \*mapping = ractl-\>mapping; 494 **pgoff_t** index = **readahead_index**(ractl); 495 **pgoff_t** limit = (**i_size_read**(mapping-\>host) - 1) \>\> **PAGE_SHIFT**; 496 **pgoff_t** mark = index + ra-\>size - ra-\>async_size; 497 **int** err = 0;

498 **gfp_t** gfp = **readahead_gfp_mask**(mapping); 499

500 **if** (!**mapping_large_folio_support**(mapping) \|\| ra-\>size \< 4) 501 **goto fallback**; 502

503 limit = **min**(limit, index + ra-\>size - 1); 504

505 **if** (new_order \< **MAX_PAGECACHE_ORDER**) { 506 new_order += 2; 507 **if** (new_order \> **MAX_PAGECACHE_ORDER**) 508 new_order = **MAX_PAGECACHE_ORDER**; 509 **while** ((1 \<\< new_order) \> ra-\>size) 510 new_order--; 511 }

512

513 **filemap_invalidate_lock_shared**(mapping); 514 **while** (index \<= limit) { 515 **unsigned int** order = new_order; 516

517 */\* Align with smaller pages if needed \*/* 518 **if** (index & ((1**UL** \<\< order) - 1)) { 519 order = **\_\_ffs**(index); 520 **if** (order == 1) 521 order = 0;







522 }

523 */\* Don't allocate pages past EOF \*/* 524 **while** (index + (1**UL** \<\< order) - 1 \> limit) { 525 **if** (--order == 1) 526 order = 0; 527 }

528 err = **ra_alloc_folio**(ractl, index, mark, order, gfp); 529 **if** (err)

530 **break**; 531 index += 1**UL** \<\< order; 532 }

533

534 **if** (index \> limit) { 535 ra-\>size += index - limit - 1; 536 ra-\>async_size += index - limit - 1; 537 }

538

539 **read_pages**(ractl); 540 **filemap_invalidate_unlock_shared**(mapping);

541

542 */\**

543 *\* If there were already pages in the page cache, then we may have*

544 *\* left some gaps. Let the regular readahead code take care of this*

545 *\* situation.*

546 *\*/*

547 **if** (!err)

548 **return**;

549 **fallback**:

550 **do_page_cache_ra**(ractl, ra-\>size, ra-\>async_size); 551 }



*Listing 9-77:* mm/readahead.c: [*page_cache_ra_order()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n490)



This function uses [mapping_large_folio_support()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n313) to determine whether to

proceed or revert to fallback. This is out of scope for the book and only the

case if the file system has enabled large folio support, which only a minority

do. In any case, it is only relevant when transparent huge page functionality

is available which renders the function out of scope for the book, and it is

therefore included here for informational purposes only.

We instead note that the fallback case as well as forced readahead utilise

[do_page_cache_ra()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n275) to perform readahead, which we examine in Listing 9-78.



269 */\**

270 *\* do_page_cache_ra() actually reads a chunk of disk. It allocates* 271 *\* the pages first, then submits them for I/O. This avoids the very bad* 272 *\* behaviour which would occur if page allocations are causing VM writeback.*

273 *\* We really don't want to intermingle reads and writes like that.* 274 *\*/*

275 **static void do_page_cache_ra**(**struct** readahead_control \*ractl,







276 **unsigned long** nr_to_read, **unsigned long** lookahead_size) 277 {

278 **struct** inode \*inode = ractl-\>mapping-\>host; 279 **unsigned long** index = **readahead_index**(ractl); 280 loff_t isize = **i_size_read**(inode); 281 **pgoff_t** end_index; */\* The last page we want to read \*/* 282

283 **if** (isize == 0)

284 **return**;

285

286 end_index = (isize - 1) \>\> **PAGE_SHIFT**; 287 **if** (index \> end_index) 288 **return**;

289 */\* Don't read past the page containing the last byte of the file \*/*

290 **if** (nr_to_read \> end_index - index) 291 nr_to_read = end_index - index + 1; 292

293 **page_cache_ra_unbounded**(ractl, nr_to_read, lookahead_size); 294 }



*Listing 9-78:* mm/readahead.c: [*do_page_cache_ra()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n275)



The lookahead_size parameter will be set to

[struct file_ra_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n922)-\>async_size if falling back from [page_cache_ra_order()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n490), otherwise it will be set to zero either when performing random reada-

heads in [ondemand_readahead()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n556) (see Listing 9-75), or a forced readahead via

[force_page_cache_ra()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n300) (see Listing **??**).

This starts by checking whether the file is now truncated, i.e. pos-

sessing a zero size. If so, we abort. Equally, if the starting index, set as

[struct readahead_control-\>\_index](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1168), exceeds the last page of data in the file given its size, we also abort.

Finally the number of pages to read is capped by the file size, before de-

ferring the actual readahead operation to [page_cache_ra_unbounded()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n200), which we

examine in Listing 9-79 below.



186 */\*\**

187 *\* page_cache_ra_unbounded - Start unchecked readahead.* 188 *\* @ractl: Readahead control.* 189 *\* @nr_to_read: The number of pages to read.* 190 *\* @lookahead_size: Where to start the next readahead.* 191 *\**

192 *\* This function is for filesystems to call when they want to start* 193 *\* readahead beyond a file's stated i_size. This is almost certainly* 194 *\* not the function you want to call. Use page_cache_async_readahead()* 195 *\* or page_cache_sync_readahead() instead.* 196 *\**

197 *\* Context: File is referenced by caller. Mutexes may be held by caller.* 198 *\* May sleep, but will not reenter filesystem to reclaim memory.* 199 *\*/*







200 **void page_cache_ra_unbounded**(**struct** readahead_control \*ractl, 201 **unsigned long** nr_to_read, **unsigned long** lookahead_size) 202 {

203 **struct** address_space \*mapping = ractl-\>mapping; 204 **unsigned long** index = **readahead_index**(ractl); 205 **gfp_t** gfp_mask = **readahead_gfp_mask**(mapping); 206 **unsigned long** i;

207

208 */\**

209 *\* Partway through the readahead operation, we will have added* 210 *\* locked pages to the page cache, but will not yet have submitted*

211 *\* them for I/O. Adding another page may need to allocate memory,*

212 *\* which can trigger memory reclaim. Telling the VM we're in* 213 *\* the middle of a filesystem operation will cause it to not* 214 *\* touch file-backed pages, preventing a deadlock. Most (all?)* 215 *\* filesystems already specify \_\_GFP_NOFS in their mapping's* 216 *\* gfp_mask, but let's be explicit here.* 217 *\*/*

218 **unsigned int** nofs = **memalloc_nofs_save**();

219

220 **filemap_invalidate_lock_shared**(mapping); 221 */\**

222 *\* Preallocate as many pages as we will need.* 223 *\*/*

224 **for** (i = 0; i \< nr_to_read; i++) { 225 **struct** folio \*folio = **xa_load**(&mapping-\>i_pages, index + i);

226

227 **if** (folio && !**xa_is_value**(folio)) { 228 */\** 229 *\* Page already present? Kick off the current batch*

230 *\* of contiguous pages before continuing with the* 231 *\* next batch. This page may be the one we would* 232 *\* have intended to mark as Readahead, but we don't*

233 *\* have a stable reference to this page, and it's* 234 *\* not worth getting one just for that.* 235 *\*/* 236 **read_pages**(ractl); 237 ractl-\>\_index++; 238 i = ractl-\>\_index + ractl-\>\_nr_pages - index - 1; 239 **continue**; 240 }

241

242 folio = **filemap_alloc_folio**(gfp_mask, 0); 243 **if** (!folio) 244 **break**; 245 **if** (**filemap_add_folio**(mapping, folio, index + i, 246 gfp_mask) \< 0) {







247 **folio_put**(folio); 248 **read_pages**(ractl); 249 ractl-\>\_index++; 250 i = ractl-\>\_index + ractl-\>\_nr_pages - index - 1;

251 **continue**; 252 }

253 **if** (i == nr_to_read - lookahead_size) 254 **folio_set_readahead**(folio); 255 ractl-\>\_nr_pages++; 256 }

257

258 */\**

259 *\* Now start the IO. We ignore I/O errors - if the folio is not* 260 *\* uptodate then the caller will launch read_folio again, and* 261 *\* will then handle the error.* 262 *\*/*

263 **read_pages**(ractl); 264 **filemap_invalidate_unlock_shared**(mapping); 265 **memalloc_nofs_restore**(nofs); 266 }



*Listing 9-79:* mm/readahead.c: [*page_cache_ra_unbounded()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n200)



This function performs the meat and potatoes of allocating and placing

folios into the page cache, then triggering the underlying block device to read data into them.

We establish the GFP flags to use when performing physical memory

allocations using [readahead_gfp_mask()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n488)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n488) which uses [mapping_gfp_mask()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n272) to deter-

mine those flags appropriate for the [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) mapping as well as

specifying [\_\_GFP_NORETRY](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n221) and [\_\_GFP_NOWARN](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n247) to prevent allocation retry or warn-

ing on failure of allocation here. See Section 2.6 in the Physical Memory chapter for more details.

We also utilise [memalloc_nofs_save()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched/mm.h?h=v6.0#n319) to implicitly prevent [\_\_GFP_FS](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n215) from

being set on allocations here to avoid deadlocking. Again, see the Physical Memory chapter for more details on this.

We acquire the invalidation lock over the opera-

tion via [filemap_invalidate_lock_shared()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n809) (releasing it via

[filemap_invalidate_unlock_shared()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n820) afterwards) to prevent a competing operation performing any kind of possible invalidation interfering.

We then loop through each page in the xarray associated with the page

cache [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) object, first checking to see if somehow we’re in a position where the folio is actually already present in the page cache.

If so, we go ahead and perform I/O for these pages via [read_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n146) (see

Listing 9-80 below), updating the index count accordingly to account for the pages read before continuing with the loop.

Otherwise, we allocate a folio of order-0 (higher order folios are

handled by [do_page_cache_ra()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n275), whose logic is out of the scope of this

book) via [filemap_alloc_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n955), before adding it to the page cache via







[filemap_add_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n926) (see Listing 9-54 in Section for more details). Note that

this function returns locked folios ready to have data written into them.

If adding the folio to the page cache fails, we drop its reference count

and attempt to read data into the pages via [read_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n146) in the same fashion

we did if the page was already present and continue the loop past whatever

pages were read.

Next, we see the code which sets the [PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143) flag, if the index is

equal to the size of the readhead to perform less the lookahead size.



**N O T E** For completeness we note that this flag is also set for the higher order case in

[*ra_alloc_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n471) as invoked by [*page_cache_ra_order()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n490) —again this is out of scope

for the book so we explore this no further.



After this is complete, we kick off the physical readahead using

[read_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n146) as shown in Listing 9-80 below.



***9.7.5 Physical Readahead***

The actual physical act of reading data from disk for the purposes of reada-

head is performed by [read_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n146), which we examine in Listing 9-80 (eliding

out of scope block device plug logic and an extraneous bug check).



146 **static void read_pages**(**struct** readahead_control \*rac) 147 {

148 **const struct** address_space_operations \*aops = rac-\>mapping-\>a_ops; 149 **struct** folio \*folio;

. . .

152 **if** (!**readahead_count**(rac)) 153 **return**;

. . .

157 **if** (aops-\>**readahead**) { 158 aops-\>**readahead**(rac); 159 */\**

160 *\* Clean up the remaining folios. The sizes in -\>ra* 161 *\* may be used to size the next readahead, so make sure* 162 *\* they accurately reflect what happened.* 163 *\*/*

164 **while** ((folio = **readahead_folio**(rac)) != **NULL**) { 165 **unsigned long** nr = **folio_nr_pages**(folio);

166

167 **folio_get**(folio); 168 rac-\>ra-\>size -= nr; 169 **if** (rac-\>ra-\>async_size \>= nr) { 170 rac-\>ra-\>async_size -= nr; 171 **filemap_remove_folio**(folio); 172 } 173 **folio_unlock**(folio); 174 **folio_put**(folio);







175 }

176 } **else** {

177 **while** ((folio = **readahead_folio**(rac)) != **NULL**) 178 aops-\>**read_folio**(rac-\>file, folio); 179 }

. . .

184 }



*Listing 9-80:* mm/readahead.c: [*read_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/readahead.c?h=v6.0#n146)



We start by checking [struct readahead_control-\>\_nr_pages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1168) via

[readahead_count()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1368), if this is zero then there is nothing to do and we abort.

Then we determine how to proceed—if the file system pro-

vides [struct address_space-\>a_ops](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) address space operations of the

[struct address_space_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n356) type specifying a readahead() handler, then we use this to cause the file system to perform the actual readahead, reading into each folio.

If none is provided, then we fallback to using [readahead_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1285)

to retrieve each folio in the range and then invoke individual

[struct address_space_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n356)-\>read_folio calls to perform the readahead manually.

If the file system is unable to readahead all of the folios, we manually it-

erate through those that remain and remove them from the page cache al-

together via [filemap_remove_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n248) (see Listing 9-88 in Section 9.9 for more details).

We make sure in this instance to update the

[struct file_ra_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n922)-\>async_size value to remain valid within the reada-head range.

The file system-specified [struct address_space_operations-\>read_folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n356) han-

dler typically uses [readahead_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1285) to retrieve the folio in the first instance,

as does our fallback handler, so we examine this in Listing 9-81.



1277 */\*\**

1278 *\* readahead_folio - Get the next folio to read.* 1279 *\* @ractl: The current readahead request.* 1280 *\**

1281 *\* Context: The folio is locked. The caller should unlock the folio once*

1282 *\* all I/O to that folio has completed.* 1283 *\* Return: A pointer to the next folio, or %NULL if we are done.* 1284 *\*/*

1285 **static inline struct** folio \***readahead_folio**(**struct** readahead_control \*ractl) 1286 {

1287 **struct** folio \*folio = **\_\_readahead_folio**(ractl); 1288

1289 **if** (folio)

1290 **folio_put**(folio); 1291 **return** folio;

1292 }







*Listing 9-81:* include/linux/pagemap.h: [*readahead_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1285)



This simply defers the heavy lifting to [\_\_readahead_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1241)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1241) drop-

ping the folio’s reference count to unpin it once done. We examine

[\_\_readahead_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1241) in Listing 9-82 (eliding some distracting bug checks).



1241 **static inline struct** folio \***\_\_readahead_folio**(**struct** readahead_control \*ractl) 1242 {

1243 **struct** folio \*folio;

. . .

1246 ractl-\>\_nr_pages -= ractl-\>\_batch_count; 1247 ractl-\>\_index += ractl-\>\_batch_count; 1248

1249 **if** (!ractl-\>\_nr_pages) { 1250 ractl-\>\_batch_count = 0; 1251 **return NULL**; 1252 }

1253

1254 folio = **xa_load**(&ractl-\>mapping-\>i_pages, ractl-\>\_index);

. . .

1256 ractl-\>\_batch_count = **folio_nr_pages**(folio); 1257

1258 **return** folio;

1259 }



*Listing 9-82:* include/linux/pagemap.h: [*\_\_readahead_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1241)



Everything is performed at a granularity determined by the

[struct readahead_control-\>\_batch_count](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1168) field, which is set in each instance by

the previous folio’s size.

This is because the readahead state is set to point to the folio we are now

loading and thus on the next iteration we must know the previous folio’s size

in order to skip past it to the next one.

This simply uses [xa_load()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/xarray.c?h=v6.0#n1456) to retrieve the folio from the page cache at the

current readahead index, returning NULL if we have exceeded the size of the

readahead.

This therefore allows this function to be used in the loops we have seen

thus far to iterate through each folio in a readahead range.



**9.8 Fault-Around**



In order to minimise the amount of time spent faulting memory in, the

page faulting mechanism will perform ‘fault-around’ on read fault in

[do_read_fault()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4509).

Importantly, this only performs minor faults, i.e. faulting in memory that

is already present in the page cache, in a batch, skipping anything that re-

quires a major fault.







We discuss this faulting mechanism in section 6.5 in the page fault chap-

ter, however let’s review [do_fault_around()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4463) (previously shown in listing 6-28)

repeated here for convenience in Listing 9-83.



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

4470 nr_pages = **READ_ONCE**(fault_around_bytes) \>\> **PAGE_SHIFT**; 4471 mask = ~(nr_pages \* **PAGE_SIZE**- 1) & **PAGE_MASK**; 4472

4473 address = **max**(address & mask, vmf-\>vma-\>vm_start); 4474 off = ((vmf-\>address - address) \>\> **PAGE_SHIFT**) & (**PTRS_PER_PTE**- 1); 4475 start_pgoff -= off; 4476

4477 */\**

4478 *\* end_pgoff is either the end of the page table, the end of* 4479 *\* the vma or nr_pages from start_pgoff, depending what is nearest.*

4480 *\*/*

4481 end_pgoff = start_pgoff -4482 ((address \>\> **PAGE_SHIFT**) & (**PTRS_PER_PTE**- 1)) + 4483 **PTRS_PER_PTE**- 1; 4484 end_pgoff = **min3**(end_pgoff, vma_pages(vmf-\>vma) + vmf-\>vma-\>vm_pgoff -

1,







4485 start_pgoff + nr_pages - 1); 4486

4487 **if** (**pmd_none**(\*vmf-\>pmd)) { 4488 vmf-\>prealloc_pte = **pte_alloc_one**(vmf-\>vma-\>vm_mm); 4489 **if** (!vmf-\>prealloc_pte) 4490 **return VM_FAULT_OOM**; 4491 }

4492

4493 **return** vmf-\>vma-\>vm_ops-\>**map_pages**(vmf, start_pgoff, end_pgoff); 4494 }



*Listing 9-83:* mm/memory.c: [*do_fault_around()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4463)



Broadly speaking this reads up to [fault_around_bytes](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4407) (configurable by the

/sys/kernel/debug/fault_around_bytes sysfs tunable) of data to fault in around

the faulting address, if the file system supports it.

This defaults to 64 KiB or 16 pages if they are of 4 KiB size (as in x86-64). We align the start of the range to the fault around size and then fault in

the number of requested pages containing the faulting address (e.g. address

0x1000 will fault in pages in the range 0 to 0xf000 inclusive).

We then clamp this to VMA and page table boundaries, so we avoid any

issue with acquiring locks and avoid complexity as a result.

We go into more detail about this in the page fault

See Section 6.5 in the Page Fault chapter for a detailed explanation of

this code which we explore in more detail.

Here we will instead focus on the [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA)’s

vm_ops-\>map_pages() function which performs the heavy lifting here (part of

the [struct vm_operations_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n539) callbacks).

As with reading data and handling file-mapped page fault resolution, file

systems are free to do what they want but typically use a library function, in

this case [filemap_map_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3322). We examine this function in Listing 9-84 (elid-

ing out of scope huge page and hardware poisoning handling).



3322 **vm_fault_t filemap_map_pages**(**struct** vm_fault \*vmf, 3323 **pgoff_t** start_pgoff, **pgoff_t** end_pgoff) 3324 {

3325 **struct** vm_area_struct \*vma = vmf-\>vma; 3326 **struct** file \*file = vma-\>vm_file; 3327 **struct** address_space \*mapping = file-\>f_mapping; 3328 **pgoff_t** last_pgoff = start_pgoff; 3329 **unsigned long** addr; 3330 **XA_STATE**(xas, &mapping-\>i_pages, start_pgoff); 3331 **struct** folio \*folio; 3332 **struct** page \*page; 3333 **unsigned int** mmap_miss = **READ_ONCE**(file-\>f_ra.mmap_miss); 3334 **vm_fault_t** ret = 0; 3335

3336 **rcu_read_lock**();

3337 folio = **first_map_page**(mapping, &xas, end_pgoff);







3338 **if** (!folio)

3339 **goto out**;

. . .

3346 addr = vma-\>vm_start + ((start_pgoff - vma-\>vm_pgoff) \<\< **PAGE_SHIFT**); 3347 vmf-\>pte = **pte_offset_map_lock**(vma-\>vm_mm, vmf-\>pmd, addr, &vmf-\>ptl); 3348 **do** {

. . .

3350 page = **folio_file_page**(folio, xas.xa_index);

. . .

3354 **if** (mmap_miss \> 0) 3355 mmap_miss--; 3356

3357 addr += (xas.xa_index - last_pgoff) \<\< **PAGE_SHIFT**; 3358 vmf-\>pte += xas.xa_index - last_pgoff; 3359 last_pgoff = xas.xa_index; 3360

3361 */\**

3362 *\* NOTE: If there're PTE markers, we'll leave them to be* 3363 *\* handled in the specific fault path, and it'll prohibit the*

3364 *\* fault-around logic.* 3365 *\*/*

3366 **if** (!**pte_none**(\*vmf-\>pte)) 3367 **goto unlock**; 3368

3369 */\* We're about to handle the fault \*/* 3370 **if** (vmf-\>address == addr) 3371 ret = **VM_FAULT_NOPAGE**; 3372

3373 **do_set_pte**(vmf, page, addr); 3374 */\* no need to invalidate: a not-present page won't be cached*

*\*/*

3375 **update_mmu_cache**(vma, addr, vmf-\>pte);

. . .

3381 **folio_unlock**(folio); 3382 **continue**; 3383 **unlock**:

. . .

3388 **folio_unlock**(folio); 3389 **folio_put**(folio); 3390 } **while** ((folio = **next_map_page**(mapping, &xas, end_pgoff)) != **NULL**); 3391 **pte_unmap_unlock**(vmf-\>pte, vmf-\>ptl); 3392 **out**:

3393 **rcu_read_unlock**(); 3394 **WRITE_ONCE**(file-\>f_ra.mmap_miss, mmap_miss); 3395 **return** ret;

3396 }



*Listing 9-84:* mm/filemap.c: [*filemap_map_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3322)







After some initialisation and establishment of an xarray [struct xa_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1326)

object via [XA_STATE()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1368), initialising it to point at the first page offset of the

sought folio.

We retrieve the first folio in the range using [first_map_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3306) which we

examine in Listing **??**.



3306 **static inline struct** folio \***first_map_page**(**struct** address_space \*mapping, 3307 **struct** xa_state \*xas, 3308 **pgoff_t** end_pgoff) 3309 {

3310 **return next_uptodate_page**(**xas_find**(xas, end_pgoff), 3311 mapping, xas, end_pgoff); 3312 }



*Listing 9-85:* mm/filemap.c: [*first_map_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3306)



This calls the [next_uptodate_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3265) helper function which we examine

shortly in Listing 9-87.

We provide a folio to it using [xas_find()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/xarray.c?h=v6.0#n1239), specifying that we wish to find

the next folio up to and including end_pgoff.

Later in the loop we utilise [next_map_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3314) which we examine in Listing

**??**.



3314 **static inline struct** folio \***next_map_page**(**struct** address_space \*mapping, 3315 **struct** xa_state \*xas, 3316 **pgoff_t** end_pgoff) 3317 {

3318 **return next_uptodate_page**(**xas_next_entry**(xas, end_pgoff), 3319 mapping, xas, end_pgoff); 3320 }



*Listing 9-86:* mm/filemap.c: [*next_map_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3314)



This is roughly equivalent to [first_map_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3306), only it uses [xas_next_entry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1669)

which is an inline, more efficient version of [xas_find()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/xarray.c?h=v6.0#n1239) for finding the next

entry.

Each of these are simply helpers which find the next [PG_uptodate](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n103) folio

in the page cache within this range, i.e. the next folio which is present and

valid there.

We’ll return to [next_uptodate_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3265) shortly and in the mean time exam-

ine the logic which uses it.

If [first_map_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3306) fails to find a folio, then this implies there are no suit-

able folios in the page cache in the specified range and we simply abort.

Otherwise, we determine the address to be equal to the start

of the VMA less the difference between start_pgoff and the

[struct vm_area_struct-\>vm_pgoff](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) field. This might seem odd, but takes into ac-

count the fact that [mremap()](https://man7.org/linux/man-pages/man2/mremap.2.html) can actually move a VMA while maintaining the

same [struct vm_area_struct-\>vm_pgoff](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) even when it is no longer valid, in order

to avoid having to update reverse mapping data structures unnecessarily (see

Section 8.2.3 for more details).







This mimics the logic found in [linear_page_index()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n845)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n845) see the discussion

around this in Listing 7-23 for further discussion.

Once this address is obtained, we acquire a lock around the PTE page

table via [pte_offset_map_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2302) (see the Virtual Memory chapter for details of page tables and locking).

With this lock acquired, we’re able to manipulate the PTE entry and thus

very quickly directly perform a minor fault operation here.

We loop around, invoking [next_map_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3314) (see Listing **??**) on each itera-

tion to obtain the next valid page.

Note that at this stage, either [first_map_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3306) or [next_map_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3314) (both

invoking [next_uptodate_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3265)) will have incremented the reference count and obtained a lock on the folio and also ensured that it is stable and has not been truncated as well as being uptodate.

We may actually encounter the same folio multiple times if it is greater

in size than order-0, with the lookup functions simply incrementing the in-

dex each time. We therefore start each loop by determining the [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72)

subpage at the current index via [folio_file_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n680).

We keep track of the [struct file-\>f_ra](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) [struct file_ra_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n922)-\>mmap_miss

readahead counter, which we update after the operation is complete.

We then update offsets to take into account the fact that this might be a

subpage within a larger folio, before determining if the PTE in question is empty or not—it is only valid to proceed if it is empty, so we move on to the next page if it is not.

If the page fault state field [struct vm_fault-\>address](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n481) is already set to the

target address, this suggests that the file system-specific fault handler has

already installed an address so we set the return value to [VM_FAULT_NOPAGE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n749) to indicate this.

At this stage we perform the actual setting of the PTE to point at the lo-

cated page, i.e. perform a minor fault via [do_set_pte()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n4290) (see Listing 6-35 in

Section 6.8 for a detailed exploration of this function).

For architectures that need it (x86-64 does not) we indicate that this page

table has been updated via update_mmu_cache(). No TLB actions need be per-formed as we require that the PTE entry had to be empty before we pro-ceeded.

After this is done we unlock the [struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) and loop to the next page to

examine.

Note that we only unlock the PTE after the loop is complete—remember

that we ensure we don’t cross page table boundaries, and therefore need only acquire this lock once for a single PTE.

Now we have examined the core logic of this function, let’s return to

[next_uptodate_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3265) in Listing 9-87.



3265 **static struct** folio \***next_uptodate_page**(**struct** folio \*folio, 3266 **struct** address_space \*mapping, 3267 **struct** xa_state \*xas, **pgoff_t** end_pgoff

)

3268 {

3269 **unsigned long** max_idx;







3270

3271 **do** {

3272 **if** (!folio) 3273 **return NULL**; 3274 **if** (**xas_retry**(xas, folio)) 3275 **continue**; 3276 **if** (**xa_is_value**(folio)) 3277 **continue**; 3278 **if** (**folio_test_locked**(folio)) 3279 **continue**; 3280 **if** (!**folio_try_get_rcu**(folio)) 3281 **continue**; 3282 */\* Has the page moved or been split? \*/* 3283 **if** (**unlikely**(folio != **xas_reload**(xas))) 3284 **goto skip**; 3285 **if** (!**folio_test_uptodate**(folio) \|\| **folio_test_readahead**(folio)

)

3286 **goto skip**; 3287 **if** (!**folio_trylock**(folio)) 3288 **goto skip**; 3289 **if** (folio-\>mapping != mapping) 3290 **goto unlock**; 3291 **if** (!**folio_test_uptodate**(folio)) 3292 **goto unlock**; 3293 max_idx = **DIV_ROUND_UP**(**i_size_read**(mapping-\>host), **PAGE_SIZE**); 3294 **if** (xas-\>xa_index \>= max_idx) 3295 **goto unlock**; 3296 **return** folio; 3297 **unlock**:

3298 **folio_unlock**(folio); 3299 **skip**:

3300 **folio_put**(folio); 3301 } **while** ((folio = **xas_next_entry**(xas, end_pgoff)) != **NULL**); 3302

3303 **return NULL**;

3304 }



*Listing 9-87:* mm/filemap.c: [*next_uptodate_page()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3265)



This is a useful helper function that does all of the housekeeping re-

quired to check that a folio is uptodate, stable and suitable to be referenced

while acquiring a reference count on it and locking it while doing all the re-

quired dances and handling all edge cases that might arise.

Note that this function tries to acquire a lock on the folio, if there is con-

tention on it the folio is skipped. The fault around logic is intended to be a

best-effort optimisation, so we will not wait for a lock to become available.







The function is handed a present folio from the page cache, and we per-

form a do/while loop in case we discover this folio is not suitable so we can examine the next.

We cover the case where the xarray entry indicates that the lookup must

be retried via [xas_retry()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1504)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1504) doing so if this is the case. We then determine if the entry contains a value rather than a pointer (which would indicate that

the folio has been evicted) via [xa_is_value()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n79)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n79) and again continue to the next folio if so.

We do a fast check before trying to obtain a reference to see whether

the folio is already locked, if not then we try to obtain a folio lock via

[folio_try_get_rcu(). ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page_ref.h?h=v6.0#n311)If either fail then we examine the next folio.

We check whether the folio has been moved or split via [xas_reload()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1567)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n1567) if so

we decrement the reference count and examine the next folio in the range.

Next we perform the key check – determining whether the folio is upto-

date via [folio_test_uptodate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n711). If not, then it has not yet been read back from the disk and thus cannot be used. Note that we do this prior to obtaining a lock for speed, we will recheck this after a lock is acquired.

We then carefully check to see if the folio has been marked with the

[PG_readahead](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n143) flag. If so, this indicates that upon reading this folio in, fur-ther readahead should be performed. Since we are unable to do so here, we decrement the reference count and examine the next folio.

We then attempt to acquire the folio lock via [folio_trylock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n900)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n900) if this fails

then there is lock contention and we decrement the reference count and examine the next folio.

With the lock acquired, we check to ensure that the [struct folio-\>mapping](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256)

field matches the [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) page cache object we are attempting to access. If not, this indicates truncation, and thus we unlock the folio and examine the next.

Equally, we perform the [PG_uptodate](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n103) check once again with the lock ac-

quired to ensure that it has not been acquired prior to us obtaining the lock.

Finally we perform a sanity check to ensure the file size has not changed

such as to render the current index within the folio invalid, aborting if so.

If all checks are complete, we return the folio. If the loop iterates

through the entire range and finds nothing, then we return NULL and ulti-

mately [filemap_map_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3322) handles this scenario by exiting its own loop.



**9.9 Removing Page Cache Entries and Truncation**



The removal of folios from the page cache involves a lot of moving parts, as what the folios are being used for must be taken into account—importantly, this involves unmapping the folios using the reverse mapping as any number of users might have the page cache folios currently mapped. We explore this

in Section 9.9.3.

However, we start by exploring the fundamental mechanism of removing

a folio from the page cache once this has been taken into account in Section

9.9.1, as this is relatively straight forward in comparison to the machinery that sits above it.







We therefore examine the provided mechanisms for removing folios

from the page cache through truncation, i.e. the process of adjusting file size

or file removal resulting in folios no longer being present in the page cache,

in Section 9.9.2.

Next we examine how the mechanism for dropping caches via the

vm.drop_caches tunable is implemented in Section 9.9.4, before exploring how

this evicts folios altogether from the page cache in Section 9.9.5.



***9.9.1 Removing Folios from the Page Cache***

The most straightforward means of removing a folio from the page cache,

once we know that it ought to be removed is via [filemap_remove_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n248) which

we examine in Listing **??** (eliding some irrelevant inode reclaim logic).



240 */\*\**

241 *\* filemap_remove_folio - Remove folio from page cache.* 242 *\* @folio: The folio.*

243 *\**

244 *\* This must be called only on folios that are locked and have been* 245 *\* verified to be in the page cache. It will never put the folio into* 246 *\* the free list because the caller has a reference on the page.* 247 *\*/*

248 **void filemap_remove_folio**(**struct** folio \*folio) 249 {

250 **struct** address_space \*mapping = folio-\>mapping;

251

252 **BUG_ON**(!**folio_test_locked**(folio)); 253 **spin_lock**(&mapping-\>host-\>i_lock); 254 **xa_lock_irq**(&mapping-\>i_pages); 255 **\_\_filemap_remove_folio**(folio, **NULL**); 256 **xa_unlock_irq**(&mapping-\>i_pages);

. . .

259 **spin_unlock**(&mapping-\>host-\>i_lock);

260

261 **filemap_free_folio**(mapping, folio); 262 }



*Listing 9-88:* mm/filemap.c: [*filemap_remove_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n248)



Note that this function is also wrapped by the legacy

[delete_from_page_cache()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/folio-compat.c?h=v6.0#n121) function.

This requires the incoming folio to be locked, as do all truncation and

folio removal functions. The host inode is locked, and then the xarray which

describes it in turn, which we remove via [\_\_filemap_remove_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n217)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n217) which we

examine in Listing 9-89 below.

Finally this invokes [filemap_free_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n226) which invokes any custom

file system folio freeing logic in [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)-\>a_ops specifying a

[struct address_space_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n356) handler for free_folio().

We examine [\_\_filemap_remove_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n217) in Listing 9-89 (eliding trace hook).







212 */\**

213 *\* Delete a page from the page cache and free it. Caller has to make* 214 *\* sure the page is locked and that nobody else uses it - or that usage* 215 *\* is safe. The caller must hold the i_pages lock.* 216 *\*/*

217 **void \_\_filemap_remove_folio**(**struct** folio \*folio, **void** \*shadow) 218 {

219 **struct** address_space \*mapping = folio-\>mapping;

. . .

222 **filemap_unaccount_folio**(mapping, folio); 223 **page_cache_delete**(mapping, folio, shadow); 224 }



*Listing 9-89:* mm/filemap.c: [*\_\_filemap_remove_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n217)



This updates statistics accordingly via [filemap_unaccount_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n148), be-

fore removing the folio from the associated xarray and updating folio via

[page_cache_delete(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n124)which we examine in Listing 9-90 (eliding out of scope huge page and DAX logic and a debug check).



124 **static void page_cache_delete**(**struct** address_space \*mapping, 125 **struct** folio \*folio, **void** \*shadow) 126 {

127 **XA_STATE**(xas, &mapping-\>i_pages, folio-\>index); 128 **long** nr = 1;

. . .

140 **xas_store**(&xas, shadow); 141 **xas_init_marks**(&xas); 142

143 folio-\>mapping = **NULL**; 144 */\* Leave page-\>index set: truncation lookup relies upon it \*/* 145 mapping-\>nrpages -= nr; 146 }



*Listing 9-90:* mm/filemap.c: [*page_cache_delete()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n124)



This replaces the page cache entry with shadow, which can be used by the

working set logic to track eviction and refaulting (which is out of scope for the book), but in this instance we have passed NULL in any case. The value is

set via [xas_store()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/xarray.c?h=v6.0#n777)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/xarray.c?h=v6.0#n777)

We also clear any marks (such as writeback/dirty etc.) as this folio is now

removed, via [xas_init_marks()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/xarray.c?h=v6.0#n941).

Finally, and very importantly, we mark the folio truncated by setting the

[struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256)-\>mapping field to NULL. This is heavily relied upon in the rest of the kernel to detect when a folio is truncated, and equally eliminates any incorrect reverse mapping traversal from a now-truncated folio.

We also update the [struct address_space-\>nrpages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) count to indicate that

this folio has been removed from the xarray describing the page cache entry.







In addition to removing a single folio, folios can be removed from the

page cache in batches via [delete_from_page_cache_batch()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n318) which we examine in

Listing 9-91 (eliding trace hook and out of scope inode reclaim logic).



318 **void delete_from_page_cache_batch**(**struct** address_space \*mapping, 319 **struct** folio_batch \*fbatch) 320 {

321 **int** i;

322

323 **if** (!**folio_batch_count**(fbatch)) 324 **return**;

325

326 **spin_lock**(&mapping-\>host-\>i_lock); 327 **xa_lock_irq**(&mapping-\>i_pages); 328 **for** (i = 0; i \< **folio_batch_count**(fbatch); i++) { 329 **struct** folio \*folio = fbatch-\>folios\[i\];

. . .

332 **filemap_unaccount_folio**(mapping, folio); 333 }

334 **page_cache_delete_batch**(mapping, fbatch); 335 **xa_unlock_irq**(&mapping-\>i_pages);

. . .

338 **spin_unlock**(&mapping-\>host-\>i_lock);

339

340 **for** (i = 0; i \< **folio_batch_count**(fbatch); i++) 341 **filemap_free_folio**(mapping, fbatch-\>folios\[i\]); 342 }



*Listing 9-91:* mm/filemap.c: [*delete_from_page_cache_batch()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n318)



This mirrors the [\_\_filemap_remove_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n217) logic, only performed in batches

using the [struct folio_batch](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n83) type (see Section 11.7 for more on this).

As before, folios have statistics updated via [filemap_unaccount_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n148) and

any file system custom freeing logic is invoked via [filemap_free_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n226)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n226) The

role played by [page_cache_delete()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n124) in the single folio case is replaced with

[page_cache_delete_batch()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n277) which we examine in Listing 9-92 (eliding out of

scope DAX handling and debug check).



264 */\**

265 *\* page_cache_delete_batch - delete several folios from page cache* 266 *\* @mapping: the mapping to which folios belong* 267 *\* @fbatch: batch of folios to delete* 268 *\**

269 *\* The function walks over mapping-\>i_pages and removes folios passed in* 270 *\* @fbatch from the mapping. The function expects @fbatch to be sorted* 271 *\* by page index and is optimised for it to be dense.* 272 *\* It tolerates holes in @fbatch (mapping entries at those indices are not*

273 *\* modified).*

274 *\**







275 *\* The function expects the i_pages lock to be held.* 276 *\*/*

277 **static void page_cache_delete_batch**(**struct** address_space \*mapping, 278 **struct** folio_batch \*fbatch) 279 {

280 **XA_STATE**(xas, &mapping-\>i_pages, fbatch-\>folios\[0\]-\>index); 281 **long** total_pages = 0; 282 **int** i = 0;

283 **struct** folio \*folio;

. . .

286 **xas_for_each**(&xas, folio, **ULONG_MAX**) { 287 **if** (i \>= **folio_batch_count**(fbatch)) 288 **break**; 289

290 */\* A swap/dax/shadow entry got inserted? Skip it. \*/* 291 **if** (**xa_is_value**(folio)) 292 **continue**; 293 */\**

294 *\* A page got inserted in our range? Skip it. We have our* 295 *\* pages locked so they are protected from being removed.* 296 *\* If we see a page whose index is higher than ours, it* 297 *\* means our page has been removed, which shouldn't be* 298 *\* possible because we're holding the PageLock.* 299 *\*/*

300 **if** (folio != fbatch-\>folios\[i\]) {

. . .

292 **continue**; 293 }

294

295 **WARN_ON_ONCE**(!**folio_test_locked**(folio)); 296

297 folio-\>mapping = **NULL**; 298 */\* Leave folio-\>index set: truncation lookup relies on it \*/*

299

300 i++;

301 **xas_store**(&xas, **NULL**); 302 total_pages += **folio_nr_pages**(folio); 303 }

304 mapping-\>nrpages -= total_pages; 305 }



*Listing 9-92:* mm/filemap.c: [*page_cache_delete_batch()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n277)



This iterates over all of the folios in the range starting from the first folio

in the batch until a number of folios equal to the number in the batch have been examined. As folio looks will have been taken, we are protected from racing truncation, but new folios may have been inserted in the range, which







we skip, asserting in each instance that folio under examination is equal to

the one we expect in the batch.

We then assign NULL to the [struct folio-\>mapping](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) field, and keep a running

count of folio pages to decrement in [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)-\>nrpages, which we

do at the end of the operation.



***9.9.2 Folio Truncation***

There are a number of ways in which file systems and the kernel can trigger

folio truncation in the page cache. We examine the different possible routes

in Figure 9-13.



filesystem



[truncate_setsize()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n771)

filesystem filesystem



[truncate_pagecache()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n738) [truncate_inode_pages_final()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n465)

filesystem, block



[truncate_pagecache_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n846) [truncate_inode_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n450)

filesystem, block



[truncate_inode_pages_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n330)



shmem shmem

[truncate_inode_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n190) [truncate_inode_partial_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n211)



[truncate_cleanup_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n173)



*Figure 9-13: Folio Truncation Code Paths*



First we examine [truncate_setsize()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n771) in Listing 9-93.



758 */\*\**

759 *\* truncate_setsize - update inode and pagecache for a new file size* 760 *\* @inode: inode*

761 *\* @newsize: new file size* 762 *\**

763 *\* truncate_setsize updates i_size and performs pagecache truncation (if* 764 *\* necessary) to @newsize. It will be typically be called from the filesystem'*

*s*

765 *\* setattr function when ATTR_SIZE is passed in.* 766 *\**

767 *\* Must be called with a lock serializing truncates and writes (generally* 768 *\* i_rwsem but e.g. xfs uses a different lock) and before all filesystem* 769 *\* specific block truncation has been performed.* 770 *\*/*







771 **void truncate_setsize**(**struct** inode \*inode, **loff_t** newsize) 772 {

773 **loff_t** oldsize = inode-\>i_size; 774

775 **i_size_write**(inode, newsize); 776 **if** (newsize \> oldsize) 777 **pagecache_isize_extended**(inode, oldsize, newsize); 778 **truncate_pagecache**(inode, newsize); 779 }



*Listing 9-93:* mm/truncate.c: [*truncate_setsize()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n771)



This updates the file size via [i_size_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n873) and, if extended, handles this

via [pagecache_isize_extended()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n801). We are focused on files shrinking so we do not examine these.

The truncation is then deferring to [truncate_pagecache()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n738) which we exam-

ine in Listing 9-94.



723 */\*\**

724 *\* truncate_pagecache - unmap and remove pagecache that has been truncated*

725 *\* @inode: inode*

726 *\* @newsize: new file size* 727 *\**

728 *\* inode's new i_size must already be written before truncate_pagecache* 729 *\* is called.*

730 *\**

731 *\* This function should typically be called before the filesystem* 732 *\* releases resources associated with the freed range (eg. deallocates* 733 *\* blocks). This way, pagecache will always stay logically coherent* 734 *\* with on-disk format, and the filesystem would not have to deal with* 735 *\* situations such as writepage being called for a page that has already* 736 *\* had its underlying blocks deallocated.* 737 *\*/*

738 **void truncate_pagecache**(**struct** inode \*inode, **loff_t** newsize) 739 {

740 **struct** address_space \*mapping = inode-\>i_mapping; 741 **loff_t** holebegin = **round_up**(newsize, **PAGE_SIZE**); 742

743 */\**

744 *\* unmap_mapping_range is called twice, first simply for* 745 *\* efficiency so that truncate_inode_pages does fewer* 746 *\* single-page unmaps. However after this first call, and* 747 *\* before truncate_inode_pages finishes, it is possible for* 748 *\* private pages to be COWed, which remain after* 749 *\* truncate_inode_pages finishes, hence the second* 750 *\* unmap_mapping_range call must be made for correctness.* 751 *\*/*

752 **unmap_mapping_range**(mapping, holebegin, 0, 1); 753 **truncate_inode_pages**(mapping, newsize);







754 **unmap_mapping_range**(mapping, holebegin, 0, 1); 755 }



*Listing 9-94:* mm/truncate.c: [*truncate_pagecache()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n738)



This unmaps mappings to the portion of the folio that has shrunk (if in-

deed it has), using [unmap_mapping_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3592) to perform the unmapping, which

we examine in Section 9.9.3.

The unmapping is done once before truncation and once after, as the

comment points out both to reduce the number of operations the trun-

cation operation need perform as well as handling any late Copy-on-Write

faults.

It defers the actual truncation operation to [truncate_inode_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n450) which

we examine in Listing 9-96.

Before we examine this, we examine [truncate_inode_pages_final()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n465) in List-

ing 9-95.



456 */\*\**

457 *\* truncate_inode_pages_final - truncate \*all\* pages before inode dies* 458 *\* @mapping: mapping to truncate* 459 *\**

460 *\* Called under (and serialized by) inode-\>i_rwsem.* 461 *\**

462 *\* Filesystems have to use this in the .evict_inode path to inform the* 463 *\* VM that this is the final truncate and the inode is going away.* 464 *\*/*

465 **void truncate_inode_pages_final**(**struct** address_space \*mapping) 466 {

467 */\**

468 *\* Page reclaim can not participate in regular inode lifetime* 469 *\* management (can't call iput()) and thus can race with the* 470 *\* inode teardown. Tell it when the address space is exiting,* 471 *\* so that it does not install eviction information after the* 472 *\* final truncate has begun.* 473 *\*/*

474 **mapping_set_exiting**(mapping);

475

476 **if** (!**mapping_empty**(mapping)) { 477 */\**

478 *\* As truncation uses a lockless tree lookup, cycle* 479 *\* the tree lock to make sure any ongoing tree* 480 *\* modification that does not see AS_EXITING is* 481 *\* completed before starting the final truncate.* 482 *\*/*

483 **xa_lock_irq**(&mapping-\>i_pages); 484 **xa_unlock_irq**(&mapping-\>i_pages); 485 }

486

487 **truncate_inode_pages**(mapping, 0);







488 }



*Listing 9-95:* mm/truncate.c: [*truncate_inode_pages_final()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n465)



This function is invoked just before an inode is destroyed completely,

which ultimately defers the truncation operation (with size set to zero as the

file is being removed) to [truncate_inode_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n450) which we examine in Listing

9-96.



437 */\*\**

438 *\* truncate_inode_pages - truncate \*all\* the pages from an offset* 439 *\* @mapping: mapping to truncate* 440 *\* @lstart: offset from which to truncate* 441 *\**

442 *\* Called under (and serialised by) inode-\>i_rwsem and* 443 *\* mapping-\>invalidate_lock.* 444 *\**

445 *\* Note: When this function returns, there can be a page in the process of*

446 *\* deletion (inside \_\_filemap_remove_folio()) in the specified range. Thus*

447 *\* mapping-\>nrpages can be non-zero when this function returns even after*

448 *\* truncation of the whole mapping.* 449 *\*/*

450 **void truncate_inode_pages**(**struct** address_space \*mapping, **loff_t** lstart) 451 {

452 **truncate_inode_pages_range**(mapping, lstart, (**loff_t**)-1); 453 }

454 EXPORT_SYMBOL(**truncate_inode_pages**);



*Listing 9-96:* mm/truncate.c: [*truncate_inode_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n450)



This invokes [truncate_inode_pages_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n330) specifying the end offset to be

unbounded. We examine this function in Listing 9-98.

The kernel also provides [truncate_pagecache_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n846)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n846) which we examine in

Listing 9-97.



833 */\*\**

834 *\* truncate_pagecache_range - unmap and remove pagecache that is hole-punched*

835 *\* @inode: inode*

836 *\* @lstart: offset of beginning of hole* 837 *\* @lend: offset of last byte of hole* 838 *\**

839 *\* This function should typically be called before the filesystem* 840 *\* releases resources associated with the freed range (eg. deallocates* 841 *\* blocks). This way, pagecache will always stay logically coherent* 842 *\* with on-disk format, and the filesystem would not have to deal with* 843 *\* situations such as writepage being called for a page that has already* 844 *\* had its underlying blocks deallocated.* 845 *\*/*

846 **void truncate_pagecache_range**(**struct** inode \*inode, **loff_t** lstart, **loff_t** lend) 847 {







848 **struct** address_space \*mapping = inode-\>i_mapping; 849 **loff_t** unmap_start = **round_up**(lstart, **PAGE_SIZE**); 850 **loff_t** unmap_end = **round_down**(1 + lend, **PAGE_SIZE**) - 1; 851 */\**

852 *\* This rounding is currently just for example: unmap_mapping_range*

853 *\* expands its hole outwards, whereas we want it to contract the hole*

854 *\* inwards. However, existing callers of truncate_pagecache_range are*

855 *\* doing their own page rounding first. Note that unmap_mapping_range*

856 *\* allows holelen 0 for all, and we allow lend -1 for end of file.*

857 *\*/*

858

859 */\**

860 *\* Unlike in truncate_pagecache, unmap_mapping_range is called only*

861 *\* once (before truncating pagecache), and without "even_cows" flag:*

862 *\* hole-punching should not remove private COWed pages from the hole.*

863 *\*/*

864 **if** ((**u64**)unmap_end \> (**u64**)unmap_start) 865 **unmap_mapping_range**(mapping, unmap_start, 866 1 + unmap_end - unmap_start, 0); 867 **truncate_inode_pages_range**(mapping, lstart, lend); 868 }



*Listing 9-97:* mm/truncate.c: [*truncate_pagecache_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n846)



This provides the means for file system to ‘hole punch’ files, that is

to delete portions of a file in order that the can be treated as if they were

sparse. When we do so, we must unmap the hole-punched region and trun-

cate within this range.

This function achieves that by unmapping in the hole-punched range via

[unmap_mapping_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3592) (see Listing **??**), and truncating the hole-punched range

in [truncate_inode_pages_range()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n330)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n330) which we examine starting at Listing 9-98

(eliding out of scope realtime scheduler hints and debug check).



306 */\*\**

307 *\* truncate_inode_pages_range - truncate range of pages specified by start &*

*end byte offsets*

308 *\* @mapping: mapping to truncate* 309 *\* @lstart: offset from which to truncate* 310 *\* @lend: offset to which to truncate (inclusive)* 311 *\**

312 *\* Truncate the page cache, removing the pages that are between* 313 *\* specified offsets (and zeroing out partial pages* 314 *\* if lstart or lend + 1 is not page aligned).* 315 *\**

316 *\* Truncate takes two passes - the first pass is nonblocking. It will not*

317 *\* block on page locks and it will not block on writeback. The second pass*

318 *\* will wait. This is to prevent as much IO as possible in the affected*

*region.*







319 *\* The first pass will remove most pages, so the search cost of the second*

*pass*

320 *\* is low.*

321 *\**

322 *\* We pass down the cache-hot hint to the page freeing code. Even if the*

323 *\* mapping is large, it is probably the case that the final pages are the most*

324 *\* recently touched, and freeing happens in ascending file offset order.* 325 *\**

326 *\* Note that since -\>invalidate_folio() accepts range to invalidate* 327 *\* truncate_inode_pages_range is able to handle cases where lend + 1 is not*

328 *\* page aligned properly.* 329 *\*/*

330 **void truncate_inode_pages_range**(**struct** address_space \*mapping, 331 **loff_t** lstart, **loff_t** lend) 332 {

333 **pgoff_t** start; */\* inclusive \*/* 334 **pgoff_t** end; */\* exclusive \*/* 335 **struct** folio_batch fbatch; 336 **pgoff_t** indices\[**PAGEVEC_SIZE**\]; 337 **pgoff_t** index; 338 **int** i; 339 **struct** folio \*folio; 340 **bool** same_folio; 341

342 **if** (**mapping_empty**(mapping)) 343 **return**;

344

345 */\**

346 *\* 'start' and 'end' always covers the range of pages to be fully*

347 *\* truncated. Partial pages are covered with 'partial_start' at the*

348 *\* start of the range and 'partial_end' at the end of the range.* 349 *\* Note that 'end' is exclusive while 'lend' is inclusive.* 350 *\*/*

351 start = (lstart + **PAGE_SIZE**- 1) \>\> **PAGE_SHIFT**; 352 **if** (lend == -1)

353 */\**

354 *\* lend == -1 indicates end-of-file so we have to set 'end'*

355 *\* to the highest possible pgoff_t and since the type is* 356 *\* unsigned we're using -1.* 357 *\*/*

358 end = -1; 359 **else**

360 end = (lend + 1) \>\> **PAGE_SHIFT**; 361

362 **folio_batch_init**(&fbatch);



*Listing 9-98:* mm/truncate.c: [*truncate_inode_pages_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n330) *Preface*







As the comment suggests, this function performs two passes, each of

which we examine separately. It uses a [struct folio_batch](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n83) type to perform

this operation in batches (see Section 11.7 for more on this data type).

If the mapping is empty we have nothing to do so abort. Otherwise we

establish start and end to the page-aligned inclusive and exclusive bounds of

the range to examine.

We initialise the folio batch to begin the batched operation via

[folio_batch_init()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n100) before beginning the first pass which we examine in List-

ing **??**.



363 index = start;

364 **while** (index \< end && **find_lock_entries**(mapping, index, end - 1, 365 &fbatch, indices)) { 366 index = indices\[**folio_batch_count**(&fbatch) - 1\] + 1; 367 **truncate_folio_batch_exceptionals**(mapping, &fbatch, indices); 368 **for** (i = 0; i \< **folio_batch_count**(&fbatch); i++) 369 **truncate_cleanup_folio**(fbatch.folios\[i\]); 370 **delete_from_page_cache_batch**(mapping, &fbatch); 371 **for** (i = 0; i \< **folio_batch_count**(&fbatch); i++) 372 **folio_unlock**(fbatch.folios\[i\]); 373 **folio_batch_release**(&fbatch);

. . .

375 }



*Listing 9-99:* mm/truncate.c: [*truncate_inode_pages_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n330) *First Pass*



We use [find_lock_entries()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2093) (see Listing 9-40 in Section 9.5.1) to find page

cache entries in the range, optimistically attempting to lock each, skipping

entries that it can’t lock or have been meanwhile truncated. This therefore

does not block.

We invoke [truncate_folio_batch_exceptionals()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n60) to remove ‘exceptional’ en-

tries in the batch. These are page cache entries which have been evicted but

have left behind data for the working set logic to utilise within the kernel.

This is out of scope for the book, but suffice to say these entries are not valid

and should be filtered.

For each valid folio, we invoke [truncate_cleanup_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n173) to perform the

actual truncation, a function we will return to in Listing 9-103.

Once truncation has completed, we remove the folios from the page

cache (note they are each now locked) via [delete_from_page_cache_batch()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n318) (see

Listing 9-91).

We then unlock each folio and free the folio batch object via

[folio_batch_release() .](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n133)

Once this first pass is complete, we proceed with handling the portion

of the specified range which is not page-aligned on either side of the range,

i.e. partial truncation. Within this range we simply zero values, which we

examine in Listing 9-100.



363 same_folio = (lstart \>\> **PAGE_SHIFT**) == (lend \>\> **PAGE_SHIFT**);







364 folio = **\_\_filemap_get_folio**(mapping, lstart \>\> **PAGE_SHIFT**, **FGP_LOCK**,

0);

365 **if** (folio) {

366 same_folio = lend \< **folio_pos**(folio) + **folio_size**(folio); 367 **if** (!**truncate_inode_partial_folio**(folio, lstart, lend)) { 368 start = folio-\>index + **folio_nr_pages**(folio); 369 **if** (same_folio) 370 end = folio-\>index; 371 }

372 **folio_unlock**(folio); 373 **folio_put**(folio); 374 folio = **NULL**; 375 }

376

377 **if** (!same_folio)

378 folio = **\_\_filemap_get_folio**(mapping, lend \>\> **PAGE_SHIFT**, 379 **FGP_LOCK**, 0); 380 **if** (folio) {

381 **if** (!**truncate_inode_partial_folio**(folio, lstart, lend)) 382 end = folio-\>index; 383 **folio_unlock**(folio); 384 **folio_put**(folio); 385 }



*Listing 9-100:* mm/truncate.c: [*truncate_inode_pages_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n330) *Partial Truncation*



We start by setting same_folio to indicate whether the start and end of

the range exist within the same page. We correct this shortly to account for higher order folios.

We use [FGP_LOCK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n501) to indicate that the folio should be locked, passed to

[\_\_filemap_get_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1914) to retrieve the folio. This will wait for the lock to be-come available if it is currently contended.

Once obtained, we update same_folio to account for the fact that the fo-

lio may be higher order, before invoking [truncate_inode_partial_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n211) to perform the actual heavy lifting.

In the instance that this was a larger order folio and we were unable to

split it we update the start (and possibly the end) of the overall truncation range to skip it (this behaviour is out of scope for the book, however).

After this operation we unlock and drop the reference count for the fo-

lio, before performing the same operation for the end of the range.

After this is complete, we continue with the second pass of the opera-

tion, which we explore in Listing 9-101.



401 index = start;

402 **while** (index \< end) {

. . .

404 **if** (!**find_get_entries**(mapping, index, end - 1, &fbatch, 405 indices)) { 406 */\* If all gone from start onwards, we're done \*/*







407 **if** (index == start) 408 **break**; 409 */\* Otherwise restart to make sure all gone \*/* 410 index = start; 411 **continue**; 412 }

413

414 **for** (i = 0; i \< **folio_batch_count**(&fbatch); i++) { 415 **struct** folio \*folio = fbatch.folios\[i\];

416

417 */\* We rely upon deletion not changing page-\>index \*/*

418 index = indices\[i\];

419

420 **if** (**xa_is_value**(folio)) 421 **continue**;

422

423 **folio_lock**(folio);

. . .

425 **folio_wait_writeback**(folio); 426 **truncate_inode_folio**(mapping, folio); 427 **folio_unlock**(folio); 428 index = **folio_index**(folio) + **folio_nr_pages**(folio) -

1;

429 }

430 **truncate_folio_batch_exceptionals**(mapping, &fbatch, indices); 431 **folio_batch_release**(&fbatch); 432 index++;

433 }

434 }



*Listing 9-101:* mm/truncate.c: [*truncate_inode_pages_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n330) *Second Pass*



In this pass we retrieve the raw entries via [find_get_entries()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2056) (see Listing

9-40 and Section 9.5.1).

We then proceed as before. If the [find_get_entries()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2056) fails (perhaps be-

cause all entries are eliminated) then if we the operation is partially com-

plete we restart to ensure we get everything, otherwise we abort.

Note that we may encounter entries deleted by the previous pass. We rely

on the fact that we intentionally leave the [struct folio-\>index](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256) field in place

even when deleted to correctly keep track of indices in the range (which

[find_get_entries()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2056) has placed in the indices array).

We skip non-folio pointer entries then this time intentionally wait for

the folio lock to become available via [folio_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n935) (see Listing 9-137), be-

fore waiting for any writeback to complete also via [folio_wait_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n3031) (see

Listing 9-146, and Section 9.11 for more details on folio locking in general).

This ensures that the folio is stable if it was not competitively truncated, be-

fore relying on [truncate_inode_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n190) to perform the actual truncation and

deletion of the folio.







Next we examine [truncate_inode_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n190) in Listing 9-102.



190 **int truncate_inode_folio**(**struct** address_space \*mapping, **struct** folio \*folio) 191 {

192 **if** (folio-\>mapping != mapping) 193 **return**-**EIO**; 194

195 **truncate_cleanup_folio**(folio); 196 **filemap_remove_folio**(folio); 197 **return** 0;

198 }



*Listing 9-102:* mm/truncate.c: [*truncate_inode_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n190)



This assumes the passed folio is locked, then performs the usual trunca-

tion dance (we are meant to be truncating, if somebody else has got to it first then there’s nothing for us to do and return an error to indicate that this is unexpected).

We then perform the truncation via [truncate_cleanup_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n173),

which we examine in Listing 9-103, removing the folio altogether via

[filemap_remove_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n248) (see Listing **??**).



163 */\**

164 *\* If truncate cannot remove the fs-private metadata from the page, the page*

165 *\* becomes orphaned. It will be left on the LRU and may even be mapped into*

166 *\* user pagetables if we're racing with filemap_fault().* 167 *\**

168 *\* We need to bail out if page-\>mapping is no longer equal to the original*

169 *\* mapping. This happens a) when the VM reclaimed the page while we waited on*

170 *\* its lock, b) when a concurrent invalidate_mapping_pages got there first and*

171 *\* c) when tmpfs swizzles a page between a tmpfs inode and swapper_space.* 172 *\*/*

173 **static void truncate_cleanup_folio**(**struct** folio \*folio) 174 {

175 **if** (**folio_mapped**(folio)) 176 unmap_mapping_folio(folio); 177

178 **if** (**folio_has_private**(folio)) 179 **folio_invalidate**(folio, 0, **folio_size**(folio)); 180

181 */\**

182 *\* Some filesystems seem to re-dirty the page even after* 183 *\* the VM has canceled the dirty bit (eg ext3 journaling).* 184 *\* Hence dirty accounting check is placed after invalidation.* 185 *\*/*

186 **folio_cancel_dirty**(folio); 187 **folio_clear_mappedtodisk**(folio); 188 }







*Listing 9-103:* mm/truncate.c: [*truncate_cleanup_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n173)



We perform unmapping of the folio if it is currently mapped (as inferred

by map count via [folio_mapped()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n758)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/util.c?h=v6.0#n758) via [unmap_mapping_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3521) (see Listing 9-106).

If the folio has private state then this indicates that there may be state

the file system needs to invalidate, in this case we invoke [folio_invalidate()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n154)

which, if the page cache entry’s address space operations specified in

[struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)-\>a_ops of type [struct address_space_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n356) possesses a

handler for invalidate_folio(), invokes this handler.

Finally we have some edge case handling to take care of—revoking any

erroneous [PG_dirty](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n104) flag via [folio_cancel_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1061) before removing the [f](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#nPG_mappedtodisk)[lag.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#nPG_mappedtodisk)

Finally we examine [truncate_inode_partial_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n211) in Listing 9-104 (eliding

out of scope huge page handling).



200 */\**

201 *\* Handle partial folios. The folio may be entirely within the* 202 *\* range if a split has raced with us. If not, we zero the part of the* 203 *\* folio that's within the \[start, end\] range, and then split the folio if*

204 *\* it's large. split_page_range() will discard pages which now lie beyond*

205 *\* i_size, and we rely on the caller to discard pages which lie within a* 206 *\* newly created hole.*

207 *\**

208 *\* Returns false if splitting failed so the caller can avoid* 209 *\* discarding the entire folio which is stubbornly unsplit.* 210 *\*/*

211 **bool truncate_inode_partial_folio**(**struct** folio \*folio, **loff_t** start, **loff_t**

end)

212 {

213 **loff_t** pos = **folio_pos**(folio); 214 **unsigned int** offset, length;

215

216 **if** (pos \< start)

217 offset = start - pos; 218 **else**

219 offset = 0; 220 length = **folio_size**(folio); 221 **if** (pos + length \<= (**u64**)end) 222 length = length - offset; 223 **else**

224 length = end + 1 - pos - offset;

225

226 **folio_wait_writeback**(folio); 227 **if** (length == **folio_size**(folio)) { 228 **truncate_inode_folio**(folio-\>mapping, folio); 229 **return true**; 230 }

231







232 */\**

233 *\* We may be zeroing pages we're about to discard, but it avoids* 234 *\* doing a complex calculation here, and then doing the zeroing* 235 *\* anyway if the page split fails.* 236 *\*/*

237 **folio_zero_range**(folio, offset, length); 238

239 **if** (**folio_has_private**(folio)) 240 **folio_invalidate**(folio, offset, length); 241 **if** (!**folio_test_large**(folio)) 242 **return true**;

. . .

249 }



*Listing 9-104:* mm/truncate.c: [*truncate_inode_partial_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n211)



This function handles the portion of truncated folios which are not page-

aligned. Obviously in this case we cannot actually remove entries from the page cache, so we zero the data in the range instead.

We start by determining the offset of the start within the file, and clamp-

ing the length of the operation within the folio, we wait for any ongoing

writeback via [folio_wait_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n3031) (see Listing 9-146, and Section 9.11 for more on this) before checking the edge case that we do, in fact, span the en-

tire folio, in which case we truncate it via [truncate_inode_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n190) (see Listing

9-102) and exit.

Otherwise, we zero the portion of the range required via

[folio_zero_range() , ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/highmem.h?h=v6.0#n421)before completing the same invalidate check as in

[truncate_cleanup_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n173) (see discussion around Listing 9-103 above).

Finally, there is logic pertaining to huge page handling, however this is

out of scope for the book so we don’t examine this part of the function.



***9.9.3 Unmapping Folios***

An important part of truncation is dealing with processes which currently have these page cache entries mapped.

We handle this by simply unmapping all truncated folios for all folios

which are mapped.

If we want to unmap folios over the span of a byte range, we utilise

[unmap_mapping_range() , ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3592)which we examine in Listing **??**.



3575 */\*\**

3576 *\* unmap_mapping_range - unmap the portion of all mmaps in the specified* 3577 *\* address_space corresponding to the specified byte range in the underlying*

3578 *\* file.*

3579 *\**

3580 *\* @mapping: the address space containing mmaps to be unmapped.* 3581 *\* @holebegin: byte in first page to unmap, relative to the start of* 3582 *\* the underlying file. This will be rounded down to a PAGE_SIZE* 3583 *\* boundary. Note that this is different from truncate_pagecache(), which*







3584 *\* must keep the partial page. In contrast, we must get rid of* 3585 *\* partial pages.*

3586 *\* @holelen: size of prospective hole in bytes. This will be rounded* 3587 *\* up to a PAGE_SIZE boundary. A holelen of zero truncates to the* 3588 *\* end of the file.*

3589 *\* @even_cows: 1 when truncating a file, unmap even private COWed pages;* 3590 *\* but 0 when invalidating pagecache, don't throw away private data.* 3591 *\*/*

3592 **void unmap_mapping_range**(**struct** address_space \*mapping, 3593 **loff_t const** holebegin, **loff_t const** holelen, **int** even_cows) 3594 {

3595 **pgoff_t** hba = holebegin \>\> **PAGE_SHIFT**; 3596 **pgoff_t** hlen = (holelen + **PAGE_SIZE**- 1) \>\> **PAGE_SHIFT**; 3597

3598 */\* Check for overflow. \*/* 3599 **if** (**sizeof**(holelen) \> **sizeof**(hlen)) { 3600 **long long** holeend = 3601 (holebegin + holelen + **PAGE_SIZE**- 1) \>\> **PAGE_SHIFT**; 3602 **if** (holeend & ~(**long long**)**ULONG_MAX**) 3603 hlen = **ULONG_MAX**- hba + 1; 3604 }

3605

3606 **unmap_mapping_pages**(mapping, hba, hlen, even_cows); 3607 }



*Listing 9-105:* mm/memory.c: [*unmap_mapping_range()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3592)



After performing some housekeeping to ensure overflow doesn’t occur,

the operation is ultimately deferred to [unmap_mapping_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3556), which we exam-

ine below in Listing 9-107.

This is parameterised by even_cow to indicate whether Copy-on-Write fo-

lios should also be unmapped in this range.

If we wish to unmap a single folio, we can do so via [unmap_mapping_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3521),

which we examine in Listing 9-106 (eliding a debug check).



3510 */\*\**

3511 *\* unmap_mapping_folio() - Unmap single folio from processes.* 3512 *\* @folio: The locked folio to be unmapped.* 3513 *\**

3514 *\* Unmap this folio from any userspace process which still has it mmaped.* 3515 *\* Typically, for efficiency, the range of nearby pages has already been* 3516 *\* unmapped by unmap_mapping_pages() or unmap_mapping_range(). But once* 3517 *\* truncation or invalidation holds the lock on a folio, it may find that* 3518 *\* the page has been remapped again: and then uses unmap_mapping_folio()* 3519 *\* to unmap it finally.*

3520 *\*/*

3521 **void unmap_mapping_folio**(**struct** folio \*folio) 3522 {

3523 **struct** address_space \*mapping = folio-\>mapping;







3524 **struct** zap_details details = { }; 3525 **pgoff_t** first_index; 3526 **pgoff_t** last_index;

. . .

3530 first_index = folio-\>index; 3531 last_index = folio-\>index + **folio_nr_pages**(folio) - 1; 3532

3533 details.even_cows = **false**; 3534 details.single_folio = folio; 3535 details.zap_flags = **ZAP_FLAG_DROP_MARKER**; 3536

3537 **i_mmap_lock_read**(mapping); 3538 **if** (**unlikely**(!**RB_EMPTY_ROOT**(&mapping-\>i_mmap.rb_root))) 3539 **unmap_mapping_range_tree**(&mapping-\>i_mmap, first_index, 3540 last_index, &details); 3541 **i_mmap_unlock_read**(mapping); 3542 }



*Listing 9-106:* mm/memory.c: [*unmap_mapping_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3521)



We prepare ourselves for the mapping removal (termed ‘zapping’), spec-

ifying the [ZAP_FLAG_DROP_MARKER](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n3395) flag to indicate that we are removing the folio entirely.

While we examine the process of zapping in detail in Section 7.1.4, in

this section we will briefly explore this topic for the purposes of observing the unmapping of page cache entries utilising this functionality.

if the page cache object’s red/black tree rooted in

[struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424)-\>i_mmap is empty then there is nothing to do, other-

wise we defer the operation to [unmap_mapping_range_tree()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3489)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3489) which we examine

in Listing 9-108.

See the reverse mapping chapter for more details on this tree structure.

Next we examine [unmap_mapping_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3556) which performs the unmapping

of a page range. We examine this in Listing 9-107.



3544 */\*\**

3545 *\* unmap_mapping_pages() - Unmap pages from processes.* 3546 *\* @mapping: The address space containing pages to be unmapped.* 3547 *\* @start: Index of first page to be unmapped.* 3548 *\* @nr: Number of pages to be unmapped. 0 to unmap to end of file.* 3549 *\* @even_cows: Whether to unmap even private COWed pages.* 3550 *\**

3551 *\* Unmap the pages in this address space from any userspace process which*

3552 *\* has them mmaped. Generally, you want to remove COWed pages as well when*

3553 *\* a file is being truncated, but not when invalidating pages from the page*

3554 *\* cache.*

3555 *\*/*

3556 **void unmap_mapping_pages**(**struct** address_space \*mapping, **pgoff_t** start, 3557 **pgoff_t** nr, **bool** even_cows) 3558 {







3559 **struct** zap_details details = { }; 3560 **pgoff_t** first_index = start; 3561 **pgoff_t** last_index = start + nr - 1; 3562

3563 details.even_cows = even_cows; 3564 **if** (last_index \< first_index) 3565 last_index = **ULONG_MAX**; 3566

3567 **i_mmap_lock_read**(mapping); 3568 **if** (**unlikely**(!**RB_EMPTY_ROOT**(&mapping-\>i_mmap.rb_root))) 3569 **unmap_mapping_range_tree**(&mapping-\>i_mmap, first_index, 3570 last_index, &details); 3571 **i_mmap_unlock_read**(mapping); 3572 }



*Listing 9-107:* mm/memory.c: [*unmap_mapping_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3556)



This defers the operation to [unmap_mapping_range_tree()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3489)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3489) being careful to

handle an overflow scenario (unmapping from the start onwards if one is

detected).

We examine [unmap_mapping_range_tree()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3489) in Listing 9-108.



3489 **static inline void unmap_mapping_range_tree**(**struct** rb_root_cached \*root, 3490 **pgoff_t** first_index, 3491 **pgoff_t** last_index, 3492 **struct** zap_details \*details) 3493 {

3494 **struct** vm_area_struct \*vma; 3495 **pgoff_t** vba, vea, zba, zea; 3496

3497 **vma_interval_tree_foreach**(vma, root, first_index, last_index) { 3498 vba = vma-\>vm_pgoff; 3499 vea = vba + **vma_pages**(vma) - 1; 3500 zba = max(first_index, vba); 3501 zea = min(last_index, vea); 3502

3503 **unmap_mapping_range_vma**(vma, 3504 ((zba - vba) \<\< **PAGE_SHIFT**) + vma-\>vm_start, 3505 ((zea - vba + 1) \<\< **PAGE_SHIFT**) + vma-\>vm_start, 3506 details); 3507 }

3508 }



*Listing 9-108:* mm/memory.c: [*unmap_mapping_range_tree()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3489)



This iterates through each of the [struct vm_area_struct](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n403) (VMA) objects

which potentially map this folio via [vma_interval_tree_foreach()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2555) (see Listing

7-42 in Section in the reverse mapping chapter for more details on this).

For each of these, we attempt to perform the actual unmapping via

[unmap_mapping_range_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3482) which we examine in Listing 9-109.







3482 **static void unmap_mapping_range_vma**(**struct** vm_area_struct \*vma, 3483 **unsigned long** start_addr, **unsigned long** end_addr, 3484 **struct** zap_details \*details) 3485 {

3486 **zap_page_range_single**(vma, start_addr, end_addr - start_addr, details)

;

3487 }



*Listing 9-109:* mm/memory.c: [*unmap_mapping_range_vma()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n3482)



This simply wraps [zap_page_range_single()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1770) which we examine in Listing

9-110 (eliding out of scope MMU notifier logic).



1761 */\*\**

1762 *\* zap_page_range_single - remove user pages in a given range* 1763 *\* @vma: vm_area_struct holding the applicable pages* 1764 *\* @address: starting address of pages to zap* 1765 *\* @size: number of bytes to zap* 1766 *\* @details: details of shared cache invalidation* 1767 *\**

1768 *\* The range must fit into one VMA.* 1769 *\*/*

1770 **static void zap_page_range_single**(**struct** vm_area_struct \*vma, **unsigned long**

address,

1771 **unsigned long** size, **struct** zap_details \*details) 1772 {

. . .

1774 **struct** mmu_gather tlb; 1775

1776 **lru_add_drain**();

. . .

1779 **tlb_gather_mmu**(&tlb, vma-\>vm_mm); 1780 **update_hiwater_rss**(vma-\>vm_mm);

. . .

1782 **unmap_single_vma**(&tlb, vma, address, range.end, details);

. . .

1784 **tlb_finish_mmu**(&tlb); 1785 }



*Listing 9-110:* mm/memory.c: [*zap_page_range_single()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1770)



This invokes [unmap_single_vma()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/memory.c?h=v6.0#n1652) (see Listing 7-59 in Section 7.1.3), per-

forming TLB invalidation utilising [tlb_gather_mmu()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n297) (see Listing 7-54 in Sec-

tion 7.1.2), and complete the TLB invalidation in [tlb_finish_mmu()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/mmu_gather.c?h=v6.0#n325) (see List-

ing 7-79 in Section 7.1.4), using [update_hiwater_rss()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h?h=v6.0#n2026) to update the high wa-termark of RSS memory usage accordingly.

At this point, all processes which map the truncated mapping will now

have it unmapped and will thus page fault if accessing a file within the trun-cated range.







***9.9.4 Dropping Caches***

The vm.drop_caches tunable is a means through which the kernel will ‘drop’

(i.e. free) all clean page cache pages (as well as optionally dropping all cached

slab entries, however this is out of scope for this chapter).

A typical use of this is measuring the performance of a program which

interacts with I/O with a desire to eliminate measurement noise, shown in

Listing 9-111.



\$ echo 1 \| sudo tee /proc/sys/vm/drop_caches

\$ sudo sysctl vm.drop_caches=1 \# alternative



*Listing 9-111: Example use of* *drop_caches* *interface*



This is not something that a user should ordinarily do in a production

system, as caches will be reclaimed when the system comes under memory

pressure (see the reclaim chapter), so clearing this caches will only degrade

system performance.

Let’s have a look at the kernel implementation – the sysctl is config-

ured in the [vm_table](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sysctl.c?h=v6.0#n2087) object and interactions with it are set to be handled by

[drop_caches_sysctl_handler()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/drop_caches.c?h=v6.0#n50), shown in Listing 9-112.



50 **int drop_caches_sysctl_handler**(**struct** ctl_table \*table, **int** write,

51 **void** \*buffer, **size_t** \*length, loff_t \*ppos)

52 {

53 **int** ret;

54

55 ret = **proc_dointvec_minmax**(table, write, buffer, length, ppos);

56 **if** (ret)

57 **return** ret;

58 **if** (write) {

59 **static int** stfu;

60

61 **if** (**sysctl_drop_caches** & 1) {

62 **iterate_supers**(**drop_pagecache_sb**, **NULL**);

63 **count_vm_event**(**DROP_PAGECACHE**);

64 }

65 **if** (**sysctl_drop_caches** & 2) {

66 **drop_slab**();

67 **count_vm_event**(**DROP_SLAB**);

68 }

69 **if** (!stfu) {

70 **pr_info**("%s (%d): drop_caches: %d\n",

71 current-\>comm, **task_pid_nr**(current),

72 **sysctl_drop_caches**);

73 }

74 stfu \|= **sysctl_drop_caches** & 4;

75 }

76 **return** 0;

77 }







*Listing 9-112:* fs/drop_caches.c: [*drop_caches_sysctl_handler()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/drop_caches.c?h=v6.0#n50)



The [proc_dointvec_minmax()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sysctl.c?h=v6.0#n882) function simply retrieves parameters from the

sysctl invocation which are used to determine how to proceed.

If the user passes a value which sets bit 0, then the page cache is cleared.

If bit 1 is set slab caches are dropped via [drop_slab()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1031)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1031) Finally setting bit 2 lim-its kernel log output.

The function [iterate_supers()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/super.c?h=v6.0#n710) executes a function over all active super

blocks, shown in Listing 9-113.



702 */\*\**

703 *\** *iterate_supers - call function for all active superblocks* 704 *\** *@f: function to call* 705 *\** *@arg: argument to pass to it* 706 *\**

707 *\** *Scans the superblock list and calls given function, passing it* 708 *\** *locked superblock and given argument.* 709 *\*/*

710 **void iterate_supers**(**void** (\*f)(**struct** super_block \*, **void** \*), **void** \*arg) 711 {

712 **struct** super_block \*sb, \*p = **NULL**; 713

714 **spin_lock**(&sb_lock); 715 **list_for_each_entry**(sb, &**super_blocks**, s_list) { 716 **if** (**hlist_unhashed**(&sb-\>s_instances)) 717 **continue**; 718 sb-\>s_count++; 719 **spin_unlock**(&sb_lock); 720

721 **down_read**(&sb-\>s_umount); 722 **if** (sb-\>s_root && (sb-\>s_flags & **SB_BORN**)) 723 f(sb, arg); 724 **up_read**(&sb-\>s_umount); 725

726 **spin_lock**(&sb_lock); 727 **if** (p)

728 **\_\_put_super**(p); 729 p = sb;

730 }

731 **if** (p)

732 **\_\_put_super**(p); 733 **spin_unlock**(&sb_lock); 734 }



*Listing 9-113:* fs/super.c: [*iterate_supers()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/super.c?h=v6.0#n710)







The [super_blocks](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/super.c?h=v6.0#n44) list is a global variable protected by [sb_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/super.c?h=v6.0#n45) containing

all super blocks in the system (as shown in Figure 9-1), tied together by the

s_list field.

The [struct super_block-\>s_instances](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n1451) field is the node threaded through

super blocks tying them to a [struct file_system_type](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2524). If it is unhashed and

thus doesn’t belong to any known file system, we skip this entry.

We increment the super block’s reference count s_count directly, before

dropping the super block list lock sb_lock in order to perform the callback

on the superblock without contending this lock.

We also drop the s_umount semaphore to prevent the file system from be-

ing unmounted beneath us as we do this.

We only reference a super block if the [SB_BORN](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n1397) flag is set, indicating that

the file system is mounted.

After the operation is done, we drop the reference count of the previ-

ously referenced super block via [\_\_put_super()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/super.c?h=v6.0#n286) (this is delayed to avoid the

need for a safe list iteration).

The function we iterate over is [drop_pagecache_sb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/drop_caches.c?h=v6.0#n18), shown in Listing 9-

114.



18 **static void drop_pagecache_sb**(**struct** super_block \*sb, **void** \*unused)

19 {

20 **struct** inode \*inode, \*toput_inode = **NULL**;

21

22 **spin_lock**(&sb-\>s_inode_list_lock);

23 **list_for_each_entry**(inode, &sb-\>s_inodes, i_sb_list) {

24 **spin_lock**(&inode-\>i_lock);

25 */\**

26 *\* We must skip inodes in unusual state. We may also skip*

27 *\* inodes without pages but we deliberately won't in case*

28 *\* we need to reschedule to avoid softlockups.*

29 *\*/*

30 **if** ((inode-\>i_state & (**I_FREEING**\|**I_WILL_FREE**\|**I_NEW**)) \|\|

31 (**mapping_empty**(inode-\>i_mapping) && !**need_resched**())) {

32 **spin_unlock**(&inode-\>i_lock);

33 **continue**;

34 }

35 **\_\_iget**(inode);

36 **spin_unlock**(&inode-\>i_lock);

37 **spin_unlock**(&sb-\>s_inode_list_lock);

38

39 **invalidate_mapping_pages**(inode-\>i_mapping, 0, -1);

40 **iput**(toput_inode);

41 toput_inode = inode;

42

43 **cond_resched**();

44 **spin_lock**(&sb-\>s_inode_list_lock);

45 }

46 **spin_unlock**(&sb-\>s_inode_list_lock);







47 **iput**(toput_inode); 48 }



*Listing 9-114:* fs/drop_caches.c: [*drop_pagecache_sb()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/drop_caches.c?h=v6.0#n18)



The [struct super_block-\>s_inode_list_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n1451) lock is held in order to access

the super block’s s_inodes list, after which the inode’s individual [struct inode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593) lock is acquired.

If the inode is in an ‘unusual’ state, e.g. one of the below cases apply,

then it is skipped:



• Its i_state has the [I_FREEING](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2439) flag set – This indicates that the inode is

about to be freed, pending dirty data being written back.

• Its i_state has the [I_WILL_FREE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2438) flag set – This indicates that the inode is

about to be freed (i.e. set the I_FREEING flag).

• Its i_state has the [I_NEW](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2437) flag set – This indicates that the inode is newly

created and may be incorrectly duplicated. The inode is only stable once this flag is cleared and this is used to address races in inode creation.

• The [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) page cache object associated with the in-

ode does not map any pages (as determined by [mapping_empty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n135)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n135) and rescheduling is not required – freeing inodes would be redundant here.



Special care is taken to avoid contention on s_inode_list_lock,

as many such objects may be traversed in some circumstances which can lead to soft lookup, therefore if a reschedule is re-quired, we proceed (thereby dropping this lock). See commit

[c27d82f52f75: fs/drop_caches.c: avoid softlockups in drop_pagecache_sb()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=c27d82f52f75) for details.

If the inode passes these tests, we increment its reference count via

[\_\_iget()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/inode.c?h=v6.0#n441) and drop its lock (since now it cannot disappear from beneath us)

as well as the [struct super_block](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n1451)-\>s_inode_list_lock.

The actual freeing of the cache is accomplished via

[invalidate_mapping_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n564). We take special care to drop the inode ref-erence count for the previous inode in order to avoid a lock inversion, as well as allowing the process to be rescheduled with locks dropped via

[cond_resched()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n2082) (relevant only to kernels without full preemption).



**N O T E** A lock (ordering) inversion occurs when the ordering of two or more acquired locks is

unintentionally reversed between locking and unlocking, causing a deadlock.



We examine the [invalidate_mapping_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n564) function in detail in Listing

9-115.



550 */\*\**

551 *\* invalidate_mapping_pages - Invalidate all clean, unlocked cache of one*

*inode*

552 *\* @mapping: the address_space which holds the cache to invalidate* 553 *\* @start: the offset 'from' which to invalidate* 554 *\* @end: the offset 'to' which to invalidate (inclusive)*







555 *\**

556 *\* This function removes pages that are clean, unmapped and unlocked,* 557 *\* as well as shadow entries. It will not block on IO activity.* 558 *\**

559 *\* If you want to remove all the pages of one inode, regardless of* 560 *\* their use and writeback state, use truncate_inode_pages().* 561 *\**

562 *\* Return: the number of the cache entries that were invalidated* 563 *\*/*

564 **unsigned long invalidate_mapping_pages**(**struct** address_space \*mapping, 565 **pgoff_t** start, **pgoff_t** end) 566 {

567 **return invalidate_mapping_pagevec**(mapping, start, end, **NULL**); 568 }



*Listing 9-115:* mm/truncate.c: [*invalidate_mapping_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n564)



This defers the operation to [invalidate_mapping_pagevec()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n502), shown in List-

ing 9-116.



491 */\*\**

492 *\* invalidate_mapping_pagevec - Invalidate all the unlocked pages of one inode*

493 *\* @mapping: the address_space which holds the pages to invalidate* 494 *\* @start: the offset 'from' which to invalidate* 495 *\* @end: the offset 'to' which to invalidate (inclusive)* 496 *\* @nr_pagevec: invalidate failed page number for caller* 497 *\**

498 *\* This helper is similar to invalidate_mapping_pages(), except that it*

*accounts*

499 *\* for pages that are likely on a pagevec and counts them in @nr_pagevec,*

*which*

500 *\* will be used by the caller.* 501 *\*/*

502 **unsigned long invalidate_mapping_pagevec**(**struct** address_space \*mapping, 503 **pgoff_t** start, **pgoff_t** end, **unsigned long** \*nr_pagevec) 504 {

505 **pgoff_t** indices\[**PAGEVEC_SIZE**\]; 506 **struct** folio_batch fbatch; 507 **pgoff_t** index = start; 508 **unsigned long** ret; 509 **unsigned long** count = 0; 510 **int** i;

511

512 **folio_batch_init**(&fbatch); 513 **while** (**find_lock_entries**(mapping, index, end, &fbatch, indices)) { 514 **for** (i = 0; i \< **folio_batch_count**(&fbatch); i++) { 515 **struct** folio \*folio = fbatch.folios\[i\];

516

517 */\* We rely upon deletion not changing folio-\>index \*/*







518 index = indices\[i\]; 519

520 **if** (**xa_is_value**(folio)) { 521 count += **invalidate_exceptional_entry**(mapping, 522 index,

523 folio);

524 **continue**; 525 } 526 index += **folio_nr_pages**(folio) - 1; 527

528 ret = **mapping_evict_folio**(mapping, folio); 529 **folio_unlock**(folio); 530 */\** 531 *\* Invalidation is a hint that the folio is no longer*

532 *\* of interest and try to speed up its reclaim.* 533 *\*/* 534 **if** (!ret) { 535 **deactivate_file_folio**(folio); 536 */\* It is likely on the pagevec of a remote CPU*

*\*/*

537 **if** (nr_pagevec) 538 (\*nr_pagevec)++; 539 } 540 count += ret; 541 }

542 **folio_batch_remove_exceptionals**(&fbatch); 543 **folio_batch_release**(&fbatch); 544 **cond_resched**(); 545 index++;

546 }

547 **return** count;

548 }



*Listing 9-116:* mm/truncate.c: [*invalidate_mapping_pagevec()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n502)



This function retrieves folios a [struct folio_batch](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n83) at a time (see Section

11.7 for a broader discussion of these) using [find_lock_entries()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2093).

We will examine [find_lock_entries()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2093) in Section 9.5.1 and in Listing 9-42,

however as the name suggests, it finds folios associated with the mapping

(i.e. [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) object) in the given range, which are locked (i.e.

have the [PG_locked](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n101) folio flag applied).

We will also examine folio locking in Section 9.11, but broadly speaking

this causes any other thread simultaneously performing an operation on the folio to sleep until the folio is unlocked.

We process each of the now locked file folios one at a time in order to

evict them from memory. For each folio we:



• Handle exceptional entries that might be present in the returned folio

batch which contain a shadow entry for an already evicted folio. This is







determined by [xa_is_value()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/xarray.h?h=v6.0#n79) (see Section 9.2), which checks whether the

[xarray](https://kernel.org/doc/html/v6.0/core-api/xarray.html) entry returned is tagged as a value rather than a pointer.

• Attempt to remove the entry from the page cache via

[mapping_evict_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n270) (we will examine this in Listing 9-117 shortly). If the eviction failed, the fact we wanted to remove it in the first instance means it is sensible to deactivate the folio so it is reclaimed sooner which

we do via [deactivate_file_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n664) (see chapter 11 for more on reclaim and active/inactive folios).



Finally, after we have processed all folios, we eliminate any ‘exceptional’

entries via [folio_batch_remove_exceptionals()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n1046) in order to be able to pass the

batch to [folio_batch_release()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagevec.h?h=v6.0#n133) which ultimately frees all of the underlying

physical pages via [release_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/swap.c?h=v6.0#n934).



**N O T E** It may seem confusing to reference ‘shadow’ and ‘exceptional’ entries, however for the

time being you should simply gloss over these points and note that these are edge cases

that we must address here. Exceptional entries are a product of ‘eXtensible Arrays’

(see Section 9.2) and shadow entries part of the working set logic (out of scope for the

book).



***9.9.5 Folio Eviction***

When dropping caches, the [mapping_evict_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n270) function is used to evict

folios which have had their caches dropped. We examine this in Listing 9-

117.



270 **static long mapping_evict_folio**(**struct** address_space \*mapping, 271 **struct** folio \*folio) 272 {

273 **if** (**folio_test_dirty**(folio) \|\| **folio_test_writeback**(folio)) 274 **return** 0; 275 */\* The refcount will be elevated if any page in the folio is mapped \*/*

276 **if** (**folio_ref_count**(folio) \> 277 **folio_nr_pages**(folio) + **folio_has_private**(folio) + 1) 278 **return** 0; 279 **if** (**folio_has_private**(folio) && !**filemap_release_folio**(folio, 0)) 280 **return** 0;

281

282 **return remove_mapping**(mapping, folio); 283 }



*Listing 9-117:* mm/truncate.c: [*mapping_evict_folio()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/truncate.c?h=v6.0#n270)



This function assumes the folio passed in is already locked. If the folio is dirty or is undergoing writeback, then there is nothing to

do and we duly abort the operation. In either case, we would experience

data loss if the folio were to be evicted at this stage.







We also check see if the folio is pinned by the kernel, i.e. has an elevated

reference count compared to what would be expected it were only refer-enced by userland.

If the folio has private data associated with it, this implies that custom

release logic must be applied on an invalidation like this, which we perform

in [filemap_release_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3924)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3924)

This invokes the [struct address_space-\>a_ops-\>release_folio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) handler if

it exists (from the [struct address_space_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n356) object specified by the file system for custom handling).

Finally, the folio is removed from the page cache altogether via

[remove_mapping(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/vmscan.c?h=v6.0#n1397)which is part of the reclaim logic used for removing folios under memory pressure, and whose logic we share. We examine this in List-ing **??** in the reclaim chapter.



**9.10 Buffers and Block I/O**



While the Page Cache abstracts file operations from the underlying disk, rubber must ultimately meet road and (if not a RAM-backed mapping) I/O must be performed in order to actually retrieve data from or write data to disk. Typically this will be via the use of a block device. That is a storage de-vice that operates at a granularity of blocks.

The smallest size a block can be is 512 bytes, and the maximum it can be

is the base page size, which is 4 KiB on x86-64. This is therefore referred to as the device’s block size.

A block device can be envisioned as an array of blocks, with the index

of each block within the array referred to as its block number. Abstracting devices in this way is termed Logical Block Addressing (LBA).

We thus must be able to translate between page cache entries’ folios and

the block numbers of the blocks spanned by them.

The fundamental data structure used to map each block within a page is

[struct buffer_head . ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n61)This has historically been used for both this mapping and as the fundamental unit of block I/O operations.

However in the modern kernel this data structure is used only for map-

ping purposes, with block device I/O operations encoded in [struct bio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/blk_types.h?h=v6.0#n252) ob-

jects which we will come on to in Section 9.10.5.



***9.10.1 An Introduction to Buffer Heads***

The [struct buffer_head](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n61) data structure encodes a mapping between blocks and memory pages.

This data structure is a rather unloved corner of the kernel and file sys-

tems do not have to use them, but many do, although for far less than they did in the past.

The primary modern purpose of buffer heads is to map blocks (which

can be, for instance, of size 512 bytes, less than page size) to positions within pages. There are alternative mechanisms for this such as the iomap function-







ality implemented in the [include/linux/iomap.h](https://elixir.bootlin.com/linux/v6.0/source/include/linux/iomap.h) header but discussion of this

is out of scope for the book.

We examine [struct buffer_head](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n61) in Listing 9-118.



52 */\**

53 *\* Historically, a buffer_head was used to map a single block*

54 *\* within a page, and of course as the unit of I/O through the*

55 *\* filesystem and block layers. Nowadays the basic I/O unit*

56 *\* is the bio, and buffer_heads are used for extracting block*

57 *\* mappings (via a get_block_t call), for tracking state within*

58 *\* a page (via a page_mapping) and for wrapping bio submission*

59 *\* for backward compatibility reasons (e.g. submit_bh).*

60 *\*/*

61 **struct** buffer_head {

62 **unsigned long** b_state; */\* buffer state bitmap (see above) \*/*

63 **struct** buffer_head \*b_this_page;*/\* circular list of page's buffers \*/*

64 **struct** page \*b_page; */\* the page this bh is mapped to \*/*

65

66 **sector_t** b_blocknr; */\* start block number \*/*

67 **size_t** b_size; */\* size of mapping \*/*

68 **char** \*b_data; */\* pointer to data within the page \*/*

69

70 **struct** block_device \*b_bdev;

71 bh_end_io_t \*b_end_io; */\* I/O completion \*/*

72 **void** \*b_private; */\* reserved for b_end_io \*/*

73 **struct** list_head b_assoc_buffers; */\* associated with another mapping*

*\*/*

74 **struct** address_space \*b_assoc_map; */\* mapping this buffer is*

75 *associated with \*/*

76 **atomic_t** b_count; */\* users using this buffer_head \*/*

77 **spinlock_t** b_uptodate_lock; */\* Used by the first bh in a page, to*

78 *\* serialise IO completion of other*

79 *\* buffers in the page \*/*

80 };



*Listing 9-118:* include/linux/buffer_head.h: [*struct buffer_head*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n61)



The key field b_state contains a bit set of [enum bh_state_bits](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n21) fields describ-

ing the buffer state as shown in Listing 9-119.



21 **enum** bh_state_bits {

22 BH_Uptodate, */\* Contains valid data \*/*

23 BH_Dirty, */\* Is dirty \*/*

24 BH_Lock, */\* Is locked \*/*

25 BH_Req, */\* Has been submitted for I/O \*/*

26

27 BH_Mapped, */\* Has a disk mapping \*/*

28 BH_New, */\* Disk mapping was newly created by get_block \*/*

29 BH_Async_Read, */\* Is under end_buffer_async_read I/O \*/*







30 BH_Async_Write, */\* Is under end_buffer_async_write I/O \*/* 31 BH_Delay, */\* Buffer is not yet allocated on disk \*/* 32 BH_Boundary, */\* Block is followed by a discontiguity \*/* 33 BH_Write_EIO, */\* I/O error on write \*/* 34 BH_Unwritten, */\* Buffer is allocated on disk but not written \*/* 35 BH_Quiet, */\* Buffer Error Prinks to be quiet \*/* 36 BH_Meta, */\* Buffer contains metadata \*/* 37 BH_Prio, */\* Buffer should be submitted with REQ_PRIO \*/* 38 BH_Defer_Completion, */\* Defer AIO completion to workqueue \*/* 39

40 BH_PrivateStart,*/\* not a state bit, but the first bit available* 41 *\* for private allocation by other entities* 42 *\*/* 43 };



*Listing 9-119:* include/linux/buffer_head.h: [*enum bh_state_bits*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n21)



Considering each field in [struct buffer_head](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n61):



**b_state** Describes the current state of the buffer, i.e. the region of memory

mapped to the associated on-disk block, consisting of a bitwise-or com-

bined bitmap of [enum bh_state_bits](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n21) flags as shown in Listing 9-119.

**b_this_page** If the block size is less than that of the page, then multiple

buffer heads will be required to describe the blocks containing the page’s data. This field is used to tie them together, in a circular singly-linked list.

**b_page** The [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) the blocks map to.

**b_blocknr** The block number that this mapping starts at.

**b_size** The size of the mapping, in bytes.

**b_data** A convenient field containing a pointer to the offset within the page

to which this block maps. The kernel typically uses the direct mapping

to make this easy via [set_bh_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1441).

**b_bdev** A reference to the object describing the block device of type

[struct block_device.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/blk_types.h?h=v6.0#n40)

**b_end_io** A callback invoked when I/O is completed of type [bh_end_io_t](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n50)

with signature void (bh_end_io_t)(struct buffer_head \*bh, int uptodate). This is called passing the buffer head and a boolean indicating whether the I/O operation managed to synchronise the block with the disk.

**b_private** A void \* user-defined field made available to the b_end_io callback

to pass any required additional state.

**b_assoc_buffers** A [struct list_head](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/types.h?h=v6.0#n178) node enabling the buffer head to be

kept in another linked list.

**b_assoc_map** The [struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) page cache mapping object within

which this buffer and page reside.







**b_count** An atomic reference count of the number of users of this buffer

head. Incremented by [get_bh()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n313) and decremented by [put_bh()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n318)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n318)

**b_uptodate_lock** A lock, present in the first buffer head within the

b_this_page linked list, used to ensure serialisation between multiple buffers within a page when I/O completes in order that the underlying

page is only marked [PG_updtodate](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n103) when all blocks are up to date. Used for

instance in [end_buffer_async_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n244) and [end_buffer_async_write()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n342), both of which are used as b_end_io callbacks. Some file systems use this for the same purpose.



Buffer heads are allocated from a slab cache in [alloc_buffer_head()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n2972)

(via [kmem_cache_zalloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/slab.h?h=v6.0#n721)[)](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/slab.h?h=v6.0#n721) and are always attached to a folio in its

[struct folio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n256)-\>private field.

Not every page cache folio needs to have a buffer head attached, though

precisely how this operates is up to the file system. However, reads into the

page cache typically do not cause buffer heads to get attached a folio, but

writes do unless the file system uses some other method for tracking writes.

This is because data read into the page cache is only accessible by user-

land (signified by the uptodate flag) once every block that comprises a fo-

lio is read. Since we encapsulate actual I/O operations in [struct bio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/blk_types.h?h=v6.0#n252) objects

(see Section 9.10.5 below), which specifies a callback to be invoked when

done, we obviate the need for mapping blocks to folios, since when the read

is complete this information is no longer required.

Writes are different. These are ongoing, occur after a folio has been

made available to userspace and are performed on a block level, so we need

some means of tracking the current state of writes per-block. Therefore,

we do attach buffer heads to folios when writing data if the file system uses

buffer heads.



***9.10.2 blockdev***

We’ve discussed the relationship between disk blocks and file page cache en-

tries, however in order for a file system to function correctly, it must be able

to access metadata on disk which does not form part of the data associated

with any file. Equally, the kernel makes it possible to access the raw data con-

tained on a disk via the device file representing that disk’s block device, e.g.

/dev/sda1 as a typical example of such a device.

In both cases we require block-level access to the data contained on the

disk, and it would be sensible to keep this data in the page cache. This is

achieved via the special blockdev file system.

Each block device is described by the [struct block_device](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/blk_types.h?h=v6.0#n40) type, which is al-

located and initialised by [add_partition()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/partitions/core.c?h=v6.0#n305)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/partitions/core.c?h=v6.0#n305) Each partition on a disk comprises

an individual block device.

The actual allocation of the block device is performed by [bdev_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/bdev.c?h=v6.0#n479)

which allocates an inode in the blockdev file system (represented by the spe-

cial [blockdev_superblock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/bdev.c?h=v6.0#n458) super block). This inode, and more importantly its

[struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) page cache mapping, represent the entire block device

and is placed in [struct block_device-\>bd_inode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/blk_types.h?h=v6.0#n40).







Unlike a typical file system where the inode number is assigned on cre-

ation the blockdev file system, existing as an abstract and ephemeral in-

memory entity, assigns the inode number [struct inode-\>i_ino](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n593) to be equal to

the device number of the block device in [bdev_add()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/bdev.c?h=v6.0#n507), as shown in Listing 9-120.



**N O T E** A device number, consisting of a major and a minor number pair, describes a device

in the system and are represented in the devtmpfs file system typically mounted at */dev* as special files whose major and minor can be viewed via *ls -l*.



507 **void bdev_add**(**struct** block_device \*bdev, dev_t dev) 508 {

509 bdev-\>bd_dev = dev; 510 bdev-\>bd_inode-\>i_rdev = dev; 511 bdev-\>bd_inode-\>i_ino = dev; 512 **insert_inode_hash**(bdev-\>bd_inode); 513 }



*Listing 9-120:* block/bdev.c: [*bdev_add()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/bdev.c?h=v6.0#n507)



When the inode for a block device file such as /dev/sda1 is cre-

ated, [init_special_inode()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/inode.c?h=v6.0#n2292) is invoked which assigns it the [def_blk_fops](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/fops.c?h=v6.0#n673)

[struct file_operations](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n2093) callbacks.

This is important, because this inode is not the same inode

as the one created on block device initialisation and placed in

[struct block_device-\>bd_inode](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/blk_types.h?h=v6.0#n40) in [bdev_alloc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/bdev.c?h=v6.0#n479).

In order for the device to access the same page cache entry as the block

device’s regardless of which device file is used the [def_blk_fops-\>open](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/fops.c?h=v6.0#n673) func-

tion, [blkdev_open()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/fops.c?h=v6.0#n465) sets up the opened [struct file](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) object accordingly as

shown in Listing 9-121 (eliding irrelevant code).



465 **static int blkdev_open**(**struct** inode \*inode, **struct** file \*filp) 466 {

467 **struct** block_device \*bdev;

. . .

485 bdev = **blkdev_get_by_dev**(inode-\>i_rdev, filp-\>f_mode, filp); 486 **if** (**IS_ERR**(bdev)) 487 **return PTR_ERR**(bdev); 488

489 filp-\>private_data = bdev; 490 filp-\>f_mapping = bdev-\>bd_inode-\>i_mapping; 491 filp-\>f_wb_err = **filemap_sample_wb_err**(filp-\>f_mapping); 492 **return** 0;

493 }



*Listing 9-121:* block/fops.c: [*blkdev_open()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/fops.c?h=v6.0#n465)



This invokes [blkdev_get_by_dev()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/bdev.c?h=v6.0#n785) which in turn calls [blkdev_get_no_open()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/bdev.c?h=v6.0#n735)

which uses [ilookup()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/inode.c?h=v6.0#n1478) to lookup the inode whose number we assigned to de-

vice number in [bdev_add()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/bdev.c?h=v6.0#n507) (see Listing 9-120).







We assign the block device’s [struct block_device-\>bd_inode-\>i_mapping](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/blk_types.h?h=v6.0#n40)

[struct address_space](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) page cache mapping object to [struct file-\>f_mapping](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) and

set the [struct file-\>private_data](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n940) field to the [struct block_device](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/blk_types.h?h=v6.0#n40) object.

This is important, as the device file inode essentially points at the block

device, and thus each device file is meaningless in itself, only the contents of

the block device itself matter.



**9.10.2.1 blockdev Buffers**

The blockdev filesystem exposes the entirety of the raw data contained

within the partition, directly accessible via a flat file in Logical Block Ad-

dressing fashion.

This is critical as by simply calculating the number of blocks per page in

the file system, we now have the means to directly access the block device at

any arbitrary block number.



**N O T E** Rather irritatingly, the kernel often denominates filesystem related indexes in terms

of ‘logical sectors’, hardcoded to 512 bytes each, of type [*sector_t*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/types.h?h=v6.0#n125)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/types.h?h=v6.0#n125) rather than more

sensibly subdividing by block or bytes.

Adding to this is the fact that the kernel is not always consistent in doing so, nor does

the use of the [*sector_t*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/types.h?h=v6.0#n125) type necessarily indicate that a value is expressed in sectors.

Therefore, when examining file system code, take care to ensure any values you ob-

serve are expressed in the units you expect.



The page cache entries containing these block device pages exist entirely

in parallel, and are duplicates of, any already existing in the page cache for

the files which they back.

Therefore it is ill-advised to directly access this data when a filesystem

is mounted, especially if writing to the block device directly, a write which

might race against those from dirty file pages.



**N O T E** However, from a user’s perspective, directly accessing block devices when unmounted

is very useful. This enables operations such as writing a disk image to a USB stick to

be performed very easily.



However, the most useful aspect of having this interface from a file sys-

tem’s perspective is the ability to access those blocks on the underlying disk

which contain metadata, which would not otherwise be readily accessible.

The page cache entries containing this raw block data are the buffers re-

ferred to in /proc/meminfo and thus the [free](https://man7.org/linux/man-pages/man1/free.1.html) command line tool, as deter-

mined by [meminfo_proc_show()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/meminfo.c?h=v6.0#n32) and [si_meminfo()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v6.0#n5965) in turn. This value is calcu-

lated via [nr_blockdev_pages()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/bdev.c?h=v6.0#n515) shown in Listing 9-122.



515 **long nr_blockdev_pages**(**void**) 516 {

517 **struct** inode \*inode; 518 **long** ret = 0;

519

520 **spin_lock**(&blockdev_superblock-\>s_inode_list_lock);







521 **list_for_each_entry**(inode, &blockdev_superblock-\>s_inodes, i_sb_list) 522 ret += inode-\>i_mapping-\>nrpages; 523 **spin_unlock**(&blockdev_superblock-\>s_inode_list_lock); 524

525 **return** ret;

526 }



*Listing 9-122:* block/bdev.c: [*nr_blockdev_pages()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/bdev.c?h=v6.0#n515)



You can observe that this walks all blockdev inodes (which are mapped

by device), accumulating [struct address_space-\>nrpages](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n424) allocated page counts.



***9.10.3 Accessing Blocks***

There are a number of functions which leverage blockdev in order to di-rectly lookup blocks on the backing block device for a filesystem in order to be able to retrieve filesystem metadata. These operate in terms of the

[struct buffer_head](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n61) type, which returns data describing the block looked up

and are shown in Figure 9-14.



[sb_bread()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n337) [sb_bread_unmovable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n343) [sb_getblk()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n361) [sb_getblk_gfp()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n368)



[\_\_bread_gfp()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1375)



If not uptodate



[\_\_bread_slow()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1168) [\_\_getblk_gfp()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1326)



If [\_\_find_get_block()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1301) fails

[\_\_getblk_slow()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1015) [\_\_find_get_block()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1301)



If not in cache



[grow_buffers()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n990) [\_\_find_get_block_slow()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n189)



[grow_dev_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n926)



*Figure 9-14: Accessing Disk Blocks*



**N O T E** As with much in the filesystem code, filesystems can implement their own versions of

these functions. For instance, ext4 implements their own [*ext4_sb_bread()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/ext4/super.c?h=v6.0#n250) function

which performs the work of [*sb_bread()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n337) with changes made specific to ext4. These functions should be interpreted therefore as utility functions for performing block reads rather than a canonical implementation.



Broadly speaking, Figure 9-14 can be divided into those functions which

wish to retrieve a [struct buffer_head](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n61) describing a block within a buffer, and







expect the buffer to be read into the page cache if the page cache entry is

not uptodate—[sb_bread()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n337) (shown in Listing 9-123) and [sb_bread_unmovable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n343)

(shown in Listing 9-124)—and those which simply retrieve a buffer head for

the block even if the buffer is not uptodate— [sb_getblk()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n361) (shown in Listing

9-125) and [sb_getblk_gfp()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n368) (shown in Listing 9-126).

In either case, if the buffer page is not present or does not have buffer

heads attached, a slow patch is taken to allocate memory for these in

[\_\_getblk_slow()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1015) (see Listing **??**).

The variants of the initial functions determine how any allocation of

buffer heads, if necessary, should be performed, with [sb_bread_unmovable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n343)

used when the allocation must be unmovable and [sb_getblk_gfp()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n368) used when

the ability to specify GFP physical allocation flags is required (see Section 2.6

for details on these).



336 **static inline struct** buffer_head \* 337 **sb_bread**(**struct** super_block \*sb, **sector_t** block) 338 {

339 **return \_\_bread_gfp**(sb-\>s_bdev, block, sb-\>s_blocksize, **\_\_GFP_MOVABLE**); 340 }



*Listing 9-123:* include/linux/buffer_head.h: [*sb_bread()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n337)



This function defers the heavy lifting to [\_\_bread_gfp()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1375) (see Listing 9-127),

looking up the [struct block_device](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/blk_types.h?h=v6.0#n40) block device upon which the super block

resides via the [struct super_block](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/fs.h?h=v6.0#n1451)-\>s_bdev field, as well as its blocksize, the

sought block, and the [\_\_GFP_MOVABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n75) physical page flag indicating that the

buffer head allocation can be movable.



342 **static inline struct** buffer_head \* 343 **sb_bread_unmovable**(**struct** super_block \*sb, **sector_t** block) 344 {

345 **return \_\_bread_gfp**(sb-\>s_bdev, block, sb-\>s_blocksize, 0); 346 }



*Listing 9-124:* include/linux/buffer_head.h: [*sb_bread_unmovable()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n343)



[sb_bread_unmovable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n343) does the same thing as [sb_bread()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n337)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n337) only does not spec-

ify [\_\_GFP_MOVABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n75)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n75) which will result in an unmovable [struct buffer_head](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n61) alloca-

tion.



360 **static inline struct** buffer_head \* 361 **sb_getblk**(**struct** super_block \*sb, sector_t block) 362 {

363 **return \_\_getblk_gfp**(sb-\>s_bdev, block, sb-\>s_blocksize, **\_\_GFP_MOVABLE**)

;

364 }



*Listing 9-125:* include/linux/buffer_head.h: [*sb_getblk()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n361)







This function defers its heavy lifting to [\_\_getblk_gfp()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1326) (see Listing 9-131),

specifying [\_\_GFP_MOVABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/gfp_types.h?h=v6.0#n75) to indicate that the buffer head physical allocation should be movable.



367 **static inline struct** buffer_head \* 368 **sb_getblk_gfp**(**struct** super_block \*sb, sector_t block, **gfp_t** gfp) 369 {

370 **return \_\_getblk_gfp**(sb-\>s_bdev, block, sb-\>s_blocksize, gfp); 371 }



*Listing 9-126:* include/linux/buffer_head.h: [*sb_getblk_gfp()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n368)



[sb_getblk_gfp()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n368) does the same thing as [sb_getblk()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n361)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n361) only permits the speci-

fication of GFP flags via the gfp parameter.

Ultimately each of [sb_bread()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n337) and [sb_bread_unmovable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n343) ultimately invoke

[\_\_bread_gfp(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1375)shown in Listing 9-127.



1362 */\*\**

1363 *\* \_\_bread_gfp() - reads a specified block and returns the bh* 1364 *\* @bdev: the block_device to read from* 1365 *\* @block: number of block* 1366 *\* @size: size (in bytes) to read* 1367 *\* @gfp: page allocation flag* 1368 *\**

1369 *\* Reads a specified block, and returns buffer head that contains it.* 1370 *\* The page cache can be allocated from non-movable area* 1371 *\* not to prevent page migration if you set gfp to zero.* 1372 *\* It returns NULL if the block was unreadable.* 1373 *\*/*

1374 **struct** buffer_head \*

1375 **\_\_bread_gfp**(**struct** block_device \*bdev, sector_t block, 1376 **unsigned** size, **gfp_t** gfp) 1377 {

1378 **struct** buffer_head \*bh = **\_\_getblk_gfp**(bdev, block, size, gfp); 1379

1380 **if** (**likely**(bh) && !**buffer_uptodate**(bh)) 1381 bh = **\_\_bread_slow**(bh); 1382 **return** bh;

1383 }



*Listing 9-127:* fs/buffer.c: [*\_\_bread_gfp()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1375)



This retrieves the [struct buffer_head](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n61) describing the block using

[\_\_getblk_gfp()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1326) then, if the block of interest is not uptodate, then it is read

from disk via [\_\_bread_slow()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1168), shown in Listing 9-128.



1168 **static struct** buffer_head \***\_\_bread_slow**(**struct** buffer_head \*bh) 1169 {

1170 **lock_buffer**(bh);

1171 **if** (**buffer_uptodate**(bh)) {







1172 **unlock_buffer**(bh); 1173 **return** bh; 1174 } **else** {

1175 **get_bh**(bh); 1176 bh-\>b_end_io = **end_buffer_read_sync**; 1177 **submit_bh**(**REQ_OP_READ**, bh); 1178 **wait_on_buffer**(bh); 1179 **if** (**buffer_uptodate**(bh)) 1180 **return** bh; 1181 }

1182 **brelse**(bh);

1183 **return NULL**;

1184 }



*Listing 9-128:* fs/buffer.c: [*\_\_bread_slow()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1168)



Reading a block using [\_\_bread_slow()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1168) is performed using the legacy

[submit_bh()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n2723) function (see Listing 9-135 in Section 9.10.6) which wraps the op-

eration in a [struct bio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/blk_types.h?h=v6.0#n252) (see Section 9.10.5 for a description of this process).

The function [end_buffer_read_sync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n157) function is specified as the callback

to invoke once the read operation is complete. We explore this in Listing

9-129.



153 */\**

154 *\* Default synchronous end-of-IO handler.. Just mark it up-to-date and* 155 *\* unlock the buffer. This is what ll_rw_block uses too.* 156 *\*/*

157 **void end_buffer_read_sync**(**struct** buffer_head \*bh, **int** uptodate) 158 {

159 **\_\_end_buffer_read_notouch**(bh, uptodate); 160 **put_bh**(bh);

161 }



*Listing 9-129:* fs/buffer.c: [*end_buffer_read_sync()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n157)



This function defers the operation to [\_\_end_buffer_read_notouch()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n142) shown

in Listing 9-130 before dropping the buffer head reference count via

[put_bh()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n318).



134 */\**

135 *\* End-of-IO handler helper function which does not touch the bh after* 136 *\* unlocking it.*

137 *\* Note: unlock_buffer() sort-of does touch the bh after unlocking it, but*

138 *\* a race there is benign: unlock_buffer() only use the bh's address for* 139 *\* hashing after unlocking the buffer, so it doesn't actually touch the bh*

140 *\* itself.*

141 *\*/*

142 **static void \_\_end_buffer_read_notouch**(**struct** buffer_head \*bh, **int** uptodate) 143 {

144 **if** (uptodate) {







145 **set_buffer_uptodate**(bh); 146 } **else** {

147 */\* This happens, due to failed read-ahead attempts. \*/* 148 **clear_buffer_uptodate**(bh); 149 }

150 **unlock_buffer**(bh); 151 }



*Listing 9-130:* fs/buffer.c: [*\_\_end_buffer_read_notouch()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n142)



This simply marks the buffer uptodate if the read succeeded, before un-

locking the buffer (clearing the [BH_Locked](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n24) flag in [struct buffer_head-\>b_state](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n61)).

Returning to [\_\_bread_slow()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1168) in Listing 9-128, we see that after submitting

the buffer head, we wait for the operation to complete, via [wait_on_buffer()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n388)

which, if the buffer is locked, invokes [\_\_wait_on_buffer()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n120)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n120) This defers the wait-

ing to [wait_on_bit_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/wait_bit.h?h=v6.0#n96) which is out of scope for the book, but causes the pro-cess to wait until the bit is cleared.

Finally, [\_\_bread_slow()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1168) returns the buffer head if it is uptodate, otherwise

if an error occurred, drops the reference to the buffer head via [brelse()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/buffer_head.h?h=v6.0#n324) and returns NULL.

Regardless of the function invoked, all ultimately call [\_\_getblk_gfp()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1326)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1326)

shown in Listing 9-131.



1317 */\**

1318 *\* \_\_getblk_gfp() will locate (and, if necessary, create) the buffer_head* 1319 *\* which corresponds to the passed block_device, block and size. The* 1320 *\* returned buffer has its reference count incremented.* 1321 *\**

1322 *\* \_\_getblk_gfp() will lock up the machine if grow_dev_page's* 1323 *\* try_to_free_buffers() attempt is failing. FIXME, perhaps?* 1324 *\*/*

1325 **struct** buffer_head \*

1326 **\_\_getblk_gfp**(**struct** block_device \*bdev, sector_t block, 1327 **unsigned** size, **gfp_t** gfp) 1328 {

1329 **struct** buffer_head \*bh = **\_\_find_get_block**(bdev, block, size); 1330

1331 **might_sleep**();

1332 **if** (bh == **NULL**)

1333 bh = **\_\_getblk_slow**(bdev, block, size, gfp); 1334 **return** bh;

1335 }



*Listing 9-131:* fs/buffer.c: [*\_\_getblk_gfp()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1326)



At this point we will not examine the logic any further as we are straying

from memory management code into that of the file system.







***9.10.4 Block Writes***

We will not dwell too long on the block write mechanism as this is rather

logic belonging to the file system subsystem rather than memory manage-

ment, but we will briefly examine some relevant functions, starting with

[\_\_block_commit_write(), ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n2061)as shown in Listing 9-132.



2061 **static int \_\_block_commit_write**(**struct** inode \*inode, **struct** page \*page, 2062 **unsigned** from, **unsigned** to) 2063 {

2064 **unsigned** block_start, block_end; 2065 **int** partial = 0;

2066 **unsigned** blocksize; 2067 **struct** buffer_head \*bh, \*head; 2068

2069 bh = head = **page_buffers**(page); 2070 blocksize = bh-\>b_size; 2071

2072 block_start = 0;

2073 **do** {

2074 block_end = block_start + blocksize; 2075 **if** (block_end \<= from \|\| block_start \>= to) { 2076 **if** (!**buffer_uptodate**(bh)) 2077 partial = 1; 2078 } **else** {

2079 **set_buffer_uptodate**(bh); 2080 **mark_buffer_dirty**(bh); 2081 }

2082 **if** (**buffer_new**(bh)) 2083 **clear_buffer_new**(bh); 2084

2085 block_start = block_end; 2086 bh = bh-\>b_this_page; 2087 } **while** (bh != head); 2088

2089 */\**

2090 *\* If this is a partial write which happened to make all buffers* 2091 *\* uptodate then we can optimize away a bogus read_folio() for* 2092 *\* the next read(). Here we 'discover' whether the page went* 2093 *\* uptodate as a result of this (potentially partial) write.* 2094 *\*/*

2095 **if** (!partial)

2096 **SetPageUptodate**(page); 2097 **return** 0;

2098 }



*Listing 9-132:* fs/buffer.c: [*\_\_block_commit_write()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n2061)







This is invoked when writeback is complete, marking each buffer in the

specified range uptodate, and checking if all other buffers in the range are

equally marked as such we set the folio [PG_updtodate](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n103) flag.

This is a flag relevant to reading in data from disk, but a write might re-

sult in the same goal as, having overwritten data that would otherwise render the folio not uptodate we achieve an uptodate state.

The read equivalent of this is [end_buffer_async_read()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n244).

We mark a block dirty via [mark_buffer_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1079) as part of file write dirty

tracking, see Section 10.12 in the writeback chapter for more details. We

explore this function in Listing 9-133 (eliding irrelevant trace and cgroup logic).



1044 */\**

1045 *\* The relationship between dirty buffers and dirty pages:* 1046 *\**

1047 *\* Whenever a page has any dirty buffers, the page's dirty bit is set, and*

1048 *\* the page is tagged dirty in the page cache.* 1049 *\**

1050 *\* At all times, the dirtiness of the buffers represents the dirtiness of* 1051 *\* subsections of the page. If the page has buffers, the page dirty bit is*

1052 *\* merely a hint about the true dirty state.* 1053 *\**

1054 *\* When a page is set dirty in its entirety, all its buffers are marked dirty*

1055 *\* (if the page has buffers).* 1056 *\**

1057 *\* When a buffer is marked dirty, its page is dirtied, but the page's other*

1058 *\* buffers are not.*

1059 *\**

1060 *\* Also. When blockdev buffers are explicitly read with bread(), they* 1061 *\* individually become uptodate. But their backing page remains not* 1062 *\* uptodate - even if all of its buffers are uptodate. A subsequent* 1063 *\* block_read_full_folio() against that folio will discover all the uptodate*

1064 *\* buffers, will set the folio uptodate and will perform no I/O.* 1065 *\*/*

1066

1067 */\*\**

1068 *\* mark_buffer_dirty - mark a buffer_head as needing writeout* 1069 *\* @bh: the buffer_head to mark dirty* 1070 *\**

1071 *\* mark_buffer_dirty() will set the dirty bit against the buffer, then set*

1072 *\* its backing page dirty, then tag the page as dirty in the page cache* 1073 *\* and then attach the address_space's inode to its superblock's dirty* 1074 *\* inode list.*

1075 *\**

1076 *\* mark_buffer_dirty() is atomic. It takes bh-\>b_page-\>mapping-\>private_lock,*

1077 *\* i_pages lock and mapping-\>host-\>i_lock.* 1078 *\*/*

1079 **void mark_buffer_dirty**(**struct** buffer_head \*bh)







1080 {

1081 **WARN_ON_ONCE**(!**buffer_uptodate**(bh));

. . .

1085 */\**

1086 *\* Very \*carefully\* optimize the it-is-already-dirty case.* 1087 *\**

1088 *\* Don't let the final "is it dirty" escape to before we* 1089 *\* perhaps modified the buffer.* 1090 *\*/*

1091 **if** (**buffer_dirty**(bh)) { 1092 **smp_mb**(); 1093 **if** (**buffer_dirty**(bh)) 1094 **return**; 1095 }

1096

1097 **if** (!**test_set_buffer_dirty**(bh)) { 1098 **struct** page \*page = bh-\>b_page; 1099 **struct** address_space \*mapping = **NULL**;

. . .

1102 **if** (!**TestSetPageDirty**(page)) { 1103 mapping = **page_mapping**(page); 1104 **if** (mapping) 1105 **\_\_set_page_dirty**(page, mapping, 0); 1106 }

. . .

1108 **if** (mapping) 1109 **\_\_mark_inode_dirty**(mapping-\>host, **I_DIRTY_PAGES**); 1110 }

1111 }



*Listing 9-133:* fs/buffer.c: [*mark_buffer_dirty()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n1079)

This starts by very cautiously performing a check to see if the buffer was

already marked dirty with a memory barrier set to prevent CPU pipelining

from confusing matters. We then mark the buffer dirty and, if the page was

not already marked dirty, we invoke [\_\_set_page_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1054)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1054) We also make sure to

mark the inode dirty via [\_\_mark_inode_dirty()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2363)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/fs-writeback.c?h=v6.0#n2363)

See the discussion around dirty tracking in the writeback chapter in Sec-

tions 10.12 and 10.12 for more details on this as a whole.



***9.10.5 Block I/O (BIO) Operations***

Again, we are straying from memory management into file system logic

here, so we will examine things very briefly.

The fundamental operator of a block I/O operation is the bio, as de-

scribed by the [struct bio](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/blk_types.h?h=v6.0#n252) type. It describes an asynchronous I/O operation

that is submitted to the relevant block device.

These operations are typically submitted via [submit_bio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/blk-core.c?h=v6.0#n820) to be performed

by the relevant block device asynchronously.







Let’s additionally examine the case When files are synchronised, per-

formed by [generic_file_fsync()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/libfs.c?h=v6.0#n1150) (see Listing **??** in the writeback chapter), the

function [blkdev_issue_flush()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/blk-flush.c?h=v6.0#n459) is called in order to submit an I/O operation to

the block subsystem. We examine it in 9-134.



452 */\*\**

453 *\* blkdev_issue_flush - queue a flush* 454 *\* @bdev:* *blockdev to issue flush for* 455 *\**

456 *\* Description:*

457 *\** *Issue a flush for the block device in question.* 458 *\*/*

459 **int blkdev_issue_flush**(**struct** block_device \*bdev) 460 {

461 **struct** bio bio;

462

463 **bio_init**(&bio, bdev, **NULL**, 0, **REQ_OP_WRITE** \| **REQ_PREFLUSH**); 464 **return submit_bio_wait**(&bio); 465 }



*Listing 9-134:* block/blk-flush.c: [*blkdev_issue_flush()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/blk-flush.c?h=v6.0#n459)



Here we initialise this object with [bio_init](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/bio.c?h=v6.0#n241), specifying a zero size and re-

questing a flush, before submitting the operation and waiting for it to com-

plete via [submit_bio_wait()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/bio.c?h=v6.0#n1319).



***9.10.6 Buffer Head I/O Operations***

The legacy wrapper function used for submitting buffer heads for read I/O

is [submit_bh()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n2723) shown in Listing 9-135.



2723 **int submit_bh**(blk_opf_t opf, **struct** buffer_head \*bh) 2724 {

2725 **return submit_bh_wbc**(opf, bh, **NULL**); 2726 }



*Listing 9-135:* fs/buffer.c: [*submit_bh()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n2723)



This function defers the heavy lifting to [submit_bh_wbc()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n2676) which also han-

dles writes, shown in Listing 9-136 (eliding out of scope fscrypt and cgroup logic).



2676 tatic **int submit_bh_wbc**(blk_opf_t opf, **struct** buffer_head \*bh, 2677 **struct** writeback_control \*wbc) 2678 {

2679 **const enum** req_op op = opf & **REQ_OP_MASK**; 2680 **struct** bio \*bio;

2681

2682 **BUG_ON**(!**buffer_locked**(bh)); 2683 **BUG_ON**(!**buffer_mapped**(bh));







2684 **BUG_ON**(!bh-\>b_end_io); 2685 **BUG_ON**(**buffer_delay**(bh)); 2686 **BUG_ON**(**buffer_unwritten**(bh)); 2687

2688 */\**

2689 *\* Only clear out a write error when rewriting* 2690 *\*/*

2691 **if** (**test_set_buffer_req**(bh) && (op == **REQ_OP_WRITE**)) 2692 **clear_buffer_write_io_error**(bh); 2693

2694 **if** (**buffer_meta**(bh)) 2695 opf \|= **REQ_META**; 2696 **if** (**buffer_prio**(bh)) 2697 opf \|= **REQ_PRIO**; 2698

2699 bio = **bio_alloc**(bh-\>b_bdev, 1, opf, **GFP_NOIO**);

. . .

2703 bio-\>bi_iter.bi_sector = bh-\>b_blocknr \* (bh-\>b_size \>\> 9); 2704

2705 **bio_add_page**(bio, bh-\>b_page, bh-\>b_size, **bh_offset**(bh)); 2706 **BUG_ON**(bio-\>bi_iter.bi_size != bh-\>b_size); 2707

2708 bio-\>bi_end_io = end_bio_bh_io_sync; 2709 bio-\>bi_private = bh; 2710

2711 */\* Take care of bh's that straddle the end of the device \*/* 2712 **guard_bio_eod**(bio); 2713

2714 **if** (wbc) {

2715 **wbc_init_bio**(wbc, bio);

. . .

2716 }

2717

2718 **submit_bio**(bio);

2719 **return** 0;

2720 }



*Listing 9-136:* fs/buffer.c: [*submit_bh_wbc()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/buffer.c?h=v6.0#n2676)



Again, we do not dwell too long on this function, which we present here

for informational purposes, but rather note that this converts the buffer op-

eration into a block I/O one, using [submit_bio()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/block/blk-core.c?h=v6.0#n820) to submit it to the block sub-

system, asynchronously.



**9.11 Folio Locking and Waiting**

When performing certain operations, we need to indicate that the folio

should not be accessed until that operation is complete, functioning like a







mutual exclusion lock. This is implemented via the [PG_locked](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n101) folio flag, and

if a lock is required unconditionally, applied via [folio_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n935) which we exam-

ine in Listing 9-137.



913 */\*\**

914 *\* folio_lock() - Lock this folio.* 915 *\* @folio: The folio to lock.* 916 *\**

917 *\* The folio lock protects against many things, probably more than it* 918 *\* should. It is primarily held while a folio is being brought uptodate,*

919 *\* either from its backing file or from swap. It is also held while a* 920 *\* folio is being truncated from its address_space, so holding the lock* 921 *\* is sufficient to keep folio-\>mapping stable.* 922 *\**

923 *\* The folio lock is also held while write() is modifying the page to* 924 *\* provide POSIX atomicity guarantees (as long as the write does not* 925 *\* cross a page boundary). Other modifications to the data in the folio* 926 *\* do not hold the folio lock and can race with writes, eg DMA and stores*

927 *\* to mapped pages.*

928 *\**

929 *\* Context: May sleep. If you need to acquire the locks of two or* 930 *\* more folios, they must be in order of ascending index, if they are* 931 *\* in the same address_space. If they are in different address_spaces,* 932 *\* acquire the lock of the folio which belongs to the address_space which*

933 *\* has the lowest address in memory first.* 934 *\*/*

935 **static inline void folio_lock**(**struct** folio \*folio) 936 {

937 **might_sleep**();

938 **if** (!**folio_trylock**(folio)) 939 **\_\_folio_lock**(folio); 940 }



*Listing 9-137:* include/linux/pagemap.h: [*folio_lock()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n935)



Note that the legacy [lock_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n953) function does the equivalent operation

for the [struct page](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n72) type.

As the comment suggests, there are a number of different purposes for

which the folio lock is used, primary among them being bringing the folio uptodate. In addition folios which are being faulted in are locked, as are fo-

lios which are being truncated or undergoing [write()](https://man7.org/linux/man-pages/man2/write.2.html).

The lock is held in these instances such that the kernel does not try to ac-

cess a folio which does not have valid state when it requires it, and addition-ally has a means of ‘stabilising’ a folio, especially with respect to truncation, by acquiring the lock.

The page cache separates the state of a folio being allocated and placed

in the page cache and that folio having data read back from disk (at which

point it is termed ‘uptodate’ as indicated by the [PG_uptodate](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n103) folio flag.







A folio can sit in this state awaiting an asynchronous I/O operation for

potentially quite some time, which is why the faulting mechanism for in-

stance implements the [maybe_unlock_mmap_for_io()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/internal.h?h=v6.0#n607) mechanism for dropping

the highly contended [struct mm_struct-\>mmap_lock](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm_types.h?h=v6.0#n486) when waiting for this to

complete.

It also means that the act of waiting for a lock is quite a bit more involved

than a typical mutual exclusion lock—by acquiring a lock using for instance

via [folio_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n935), we imply that this thread should wait for any I/O that need

be performed before the lock can be relinquished.

This also means that code which begins asynchronous I/O to read

in data implicitly waits for that I/O, for instance the page fault mecha-

nism after performing synchronous readahead (see Section **??**) invokes

[lock_folio_maybe_drop_mmap()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n2928) which locks the folio (if the fault state permits),

implicitly waiting on the I/O to complete.

This also explains why so much kernel code first attempts the optimistic

[folio_trylock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n900) before engaging the lock, as this implies no waiting on I/O

whatsoever. Even [folio_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n935) tries this first as we can see in Listing 9-137.

We examine [folio_trylock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n900) in Listing 9-138.



888 */\*\**

889 *\* folio_trylock() - Attempt to lock a folio.* 890 *\* @folio: The folio to attempt to lock.* 891 *\**

892 *\* Sometimes it is undesirable to wait for a folio to be unlocked (eg* 893 *\* when the locks are being taken in the wrong order, or if making* 894 *\* progress through a batch of folios is more important than processing* 895 *\* them in order). Usually folio_lock() is the correct function to call.* 896 *\**

897 *\* Context: Any context.*

898 *\* Return: Whether the lock was successfully acquired.* 899 *\*/*

900 **static inline bool folio_trylock**(**struct** folio \*folio) 901 {

902 **return likely**(!**test_and_set_bit_lock**(PG_locked, **folio_flags**(folio, 0))

);

903 }



*Listing 9-138:* include/linux/pagemap.h: [*folio_trylock()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n900)



Which simply performs a bitwise operation which tests to see whether

[PG_locked](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n101) is set, if not setting it. Note that the legacy [trylock_page()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n908) wraps this

function.

Since a folio lock implies that a thread can sleep waiting on I/O, we im-

plement the ability to specify that a fatal signal could interrupt this process

(by default it is uninterruptible), doing so via [folio_lock_killable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n973) which we

examine in Listing 9-139.



963 */\*\**

964 *\* folio_lock_killable() - Lock this folio, interruptible by a fatal signal.*







965 *\* @folio: The folio to lock.* 966 *\**

967 *\* Attempts to lock the folio, like folio_lock(), except that the sleep* 968 *\* to acquire the lock is interruptible by a fatal signal.* 969 *\**

970 *\* Context: May sleep; see folio_lock().* 971 *\* Return: 0 if the lock was acquired; -EINTR if a fatal signal was received.*

972 *\*/*

973 **static inline int folio_lock_killable**(**struct** folio \*folio) 974 {

975 **might_sleep**();

976 **if** (!**folio_trylock**(folio)) 977 **return \_\_folio_lock_killable**(folio); 978 **return** 0;

979 }



*Listing 9-139:* include/linux/pagemap.h: [*folio_lock_killable()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n973)



This differs from the unconditional [folio_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n935) in that it returns an

error code indicating whether it succeeded or not. In addition, it invokes

[\_\_folio_lock_killable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1662) (see Listing **??**) rather than [\_\_folio_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1662) (shown in

Listing 9-140) which specifies that the operation is killable.

Note that this is wrapped by the legacy [lock_page_killable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n986) function.



1658 */\*\**

1659 *\* \_\_folio_lock - Get a lock on the folio, assuming we need to sleep to get it*

*.*

1660 *\* @folio: The folio to lock* 1661 *\*/*

1662 **void \_\_folio_lock**(**struct** folio \*folio) 1663 {

1664 **folio_wait_bit_common**(folio, PG_locked, **TASK_UNINTERRUPTIBLE**, 1665 **EXCLUSIVE**); 1666 }



*Listing 9-140:* mm/filemap.c: [*\_\_folio_lock()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1662)



This function defers the heavy lifting of causing the process to sleep to

[folio_wait_bit_common()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1216), which we examine in Listing 9-150 below. This spec-

ifies [TASK_UNINTERRUPTIBLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n86) to indicate that the thread mustn’t be interrupted during this operation.

It also specifies [EXCLUSIVE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1185) to indicate that the flag should be set when the

waiting thread is woken. This is an enumeration value from [enum behavior](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1184)

which we examine in Listing 9-141.



1181 */\**

1182 *\* A choice of three behaviors for folio_wait_bit_common():* 1183 *\*/*

1184 **enum** behavior {

1185 **EXCLUSIVE**, */\* Hold ref to page and take the bit when woken, like*







1186 *\* \_\_folio_lock() waiting on then setting PG_locked.*

1187 *\*/* 1188 **SHARED**, */\* Hold ref to page and check the bit when woken, like* 1189 *\* folio_wait_writeback() waiting on PG_writeback.*

1190 *\*/* 1191 **DROP**, */\* Drop ref to page before wait, no check when woken,* 1192 *\* like folio_put_wait_locked() on PG_locked.* 1193 *\*/* 1194 };



*Listing 9-141:* mm/filemap.c: [*enum behavior*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1184)



We examine [\_\_folio_lock_killable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1669) in Listing **??**.



1669 **int \_\_folio_lock_killable**(**struct** folio \*folio) 1670 {

1671 **return folio_wait_bit_common**(folio, PG_locked, **TASK_KILLABLE**, 1672 **EXCLUSIVE**); 1673 }



*Listing 9-142:* mm/filemap.c: [*\_\_folio_lock_killable()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1669)



Here the [TASK_KILLABLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n105) flag is used to indicate that the thread can be

killed during the operation.

The fact that we are implementing careful waiting code which has poten-

tially sleeping threads waiting on the change of the flag, we must therefore

implement careful handling on unlock in [folio_unlock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1526) which we examine in

Listing 9-143 (eliding distracting bug checks).



1517 */\*\**

1518 *\* folio_unlock - Unlock a locked folio.* 1519 *\* @folio: The folio.*

1520 *\**

1521 *\* Unlocks the folio and wakes up any thread sleeping on the page lock.* 1522 *\**

1523 *\* Context: May be called from interrupt or process context. May not be* 1524 *\* called from NMI context.* 1525 *\*/*

1526 **void folio_unlock**(**struct** folio \*folio) 1527 {

. . .

1532 **if** (**clear_bit_unlock_is_negative_byte**(**PG_locked**, **folio_flags**(folio, 0)

))

1533 **folio_wake_bit**(folio, **PG_locked**); 1534 }



*Listing 9-143:* mm/filemap.c: [*folio_unlock()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1526)



This invokes [folio_wake_bit()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1127) to wake any thread waiting on the lock to be

cleared. We examine this in Listing 9-144.







1127 **static void folio_wake_bit**(**struct** folio \*folio, **int** bit_nr) 1128 {

1129 wait_queue_head_t \*q = **folio_waitqueue**(folio); 1130 **struct** wait_page_key key; 1131 **unsigned long** flags; 1132 wait_queue_entry_t bookmark; 1133

1134 key.folio = folio; 1135 key.bit_nr = bit_nr; 1136 key.page_match = 0; 1137

1138 bookmark.flags = 0; 1139 bookmark.private = **NULL**; 1140 bookmark.func = **NULL**; 1141 **INIT_LIST_HEAD**(&bookmark.entry); 1142

1143 **spin_lock_irqsave**(&q-\>lock, flags); 1144 **\_\_wake_up_locked_key_bookmark**(q, **TASK_NORMAL**, &key, &bookmark); 1145

1146 **while** (bookmark.flags & **WQ_FLAG_BOOKMARK**) { 1147 */\**

1148 *\* Take a breather from holding the lock,* 1149 *\* allow pages that finish wake up asynchronously* 1150 *\* to acquire the lock and remove themselves* 1151 *\* from wait queue* 1152 *\*/*

1153 **spin_unlock_irqrestore**(&q-\>lock, flags); 1154 **cpu_relax**(); 1155 **spin_lock_irqsave**(&q-\>lock, flags); 1156 **\_\_wake_up_locked_key_bookmark**(q, **TASK_NORMAL**, &key, &bookmark)

;

1157 }

1158

1159 */\**

1160 *\* It's possible to miss clearing waiters here, when we woke our page*

1161 *\* waiters, but the hashed waitqueue has waiters for other pages on it*

*.*

1162 *\* That's okay, it's a rare case. The next waker will clear it.* 1163 *\**

1164 *\* Note that, depending on the page pool (buddy, hugetlb, ZONE_DEVICE,*

1165 *\* other), the flag may be cleared in the course of freeing the page;*

1166 *\* but that is not required for correctness.* 1167 *\*/*

1168 **if** (!**waitqueue_active**(q) \|\| !key.page_match) 1169 **folio_clear_waiters**(folio); 1170

1171 **spin_unlock_irqrestore**(&q-\>lock, flags);







1172 }



*Listing 9-144:* mm/filemap.c: [*folio_wake_bit()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1127)



We won’t get into the gritty details of this function, but we shall note a

few things here—there is an underlying mechanism which maintains wait

queues for folios to allow for us to queue up threads waiting on a folio flag

to change. This wait queue is accessible via [folio_waitqueue()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1027)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1027) Wait queues

are a means by which the kernel allows for threads to wait for certain events

to arise while sleeping.

We also note here that a folio with waiters will have the [PG_waiters](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n108) flag

specified. This is made more explicit in [folio_wake()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1174) which explicitly only

invokes [folio_wake_bit()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1127) if this is set, as shown in Listing 9-145.



1174 **static void folio_wake**(**struct** folio \*folio, **int** bit) 1175 {

1176 **if** (!**folio_test_waiters**(folio)) 1177 **return**;

1178 **folio_wake_bit**(folio, bit); 1179 }



*Listing 9-145:* mm/filemap.c: [*folio_wake()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1174)



This is utilised by [folio_end_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1624) to wake waiters on the

[PG_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n116) flag given that writeback at this point will have completed.

As should be clear by now, it is possible to wait on folio flags other than

[PG_locked](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n101). this is indeed done in [folio_wait_writeback()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n3031) to wait for writeback

to complete for a folio for file systems and block devices which require it (see

the writeback chapter for details on how this is utilised).

We examine this in Listing 9-146 (eliding an out of scope trace hook).



3019 */\*\**

3020 *\* folio_wait_writeback - Wait for a folio to finish writeback.* 3021 *\* @folio: The folio to wait for.* 3022 *\**

3023 *\* If the folio is currently being written back to storage, wait for the* 3024 *\* I/O to complete.*

3025 *\**

3026 *\* Context: Sleeps. Must be called in process context and with* 3027 *\* no spinlocks held. Caller should hold a reference on the folio.* 3028 *\* If the folio is not locked, writeback may start again after writeback* 3029 *\* has finished.*

3030 *\*/*

3031 **void folio_wait_writeback**(**struct** folio \*folio) 3032 {

3033 **while** (**folio_test_writeback**(folio)) {

. . .

3035 **folio_wait_bit**(folio, **PG_writeback**); 3036 }

3037 }







*Listing 9-146:* mm/page-writeback.c: [*folio_wait_writeback()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page-writeback.c?h=v6.0#n3031)

This simply loops while the [PG_writeback](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n116) flag is set, waiting

on [folio_wait_bit()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1445)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1445) This function is simply a wrapper around

[folio_wait_bit_common()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1216) (see Listing **??**) specifying [TASK_UNINTERRUPTIBLE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n86) but

setting [SHARED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1188) to indicate that we are waiting for the bit to be cleared, but not

setting it at this point (unlike [EXCLUSIVE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1185) used by [folio_lock()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n935) in Listing 9-137

above. We examine this in Listing 9-147.



1445 **void folio_wait_bit**(**struct** folio \*folio, **int** bit_nr) 1446 {

1447 **folio_wait_bit_common**(folio, bit_nr, **TASK_UNINTERRUPTIBLE**, **SHARED**); 1448 }



*Listing 9-147:* mm/filemap.c: [*folio_wait_bit()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1445)

The [folio_put_wait_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1470) function, as referenced by

[do_read_cache_folio() , ](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n3472)uses the [DROP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1191) behaviour to drop a reference and then

wait for unlock, as shown in Listing 9-148.



1457 */\*\**

1458 *\* folio_put_wait_locked - Drop a reference and wait for it to be unlocked*

1459 *\* @folio: The folio to wait for.* 1460 *\* @state: The sleep state (TASK_KILLABLE, TASK_UNINTERRUPTIBLE, etc).* 1461 *\**

1462 *\* The caller should hold a reference on @folio. They expect the page to*

1463 *\* become unlocked relatively soon, but do not wish to hold up migration* 1464 *\* (for example) by holding the reference while waiting for the folio to* 1465 *\* come unlocked. After this function returns, the caller should not* 1466 *\* dereference @folio.*

1467 *\**

1468 *\* Return: 0 if the folio was unlocked or -EINTR if interrupted by a signal.*

1469 *\*/*

1470 **int folio_put_wait_locked**(**struct** folio \*folio, **int** state) 1471 {

1472 **return folio_wait_bit_common**(folio, **PG_locked**, state, **DROP**); 1473 }



*Listing 9-148:* mm/filemap.c: [*folio_put_wait_locked()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1470)

This, as with other wait functionality, defers the operation to

[folio_wait_bit_common()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1216) which we will examine in Listing **??** shortly.

Sometimes we want to wait on [PG_locked](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n101) without acquiring the lock. We

utilise [SHARED](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1188) semantics via [folio_wait_bit()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1445) (see Listing 9-147 above) to do so

in [folio_wait_locked()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1022) as shown in Listing 9-149.



1015 */\**

1016 *\* Wait for a folio to be unlocked.* 1017 *\**

1018 *\* This must be called with the caller "holding" the folio,*







1019 *\* ie with increased folio reference count so that the folio won't* 1020 *\* go away during the wait.* 1021 *\*/*

1022 **static inline void folio_wait_locked**(**struct** folio \*folio) 1023 {

1024 **if** (**folio_test_locked**(folio)) 1025 **folio_wait_bit**(folio, **PG_locked**); 1026 }



*Listing 9-149:* include/linux/pagemap.h: [*folio_wait_locked()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1022)



Equally [folio_wait_locked_killable()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/pagemap.h?h=v6.0#n1028) does the same thing, only permitting

the thread to be interrupted by fatal signals.

Finally, let’s examine [folio_wait_bit_common()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1216) starting in Listing 9-150

(eliding out of scope PSI and delayed accounting thrashing logic).



1216 **static inline int folio_wait_bit_common**(**struct** folio \*folio, **int** bit_nr, 1217 **int** state, **enum** behavior behavior) 1218 {

1219 **wait_queue_head_t** \*q = **folio_waitqueue**(folio); 1220 **int** unfairness = **sysctl_page_lock_unfairness**; 1221 **struct** wait_page_queue wait_page; 1222 **wait_queue_entry_t** \*wait = &wait_page.wait;

. . .

1237 **init_wait**(wait);

1238 wait-\>func = **wake_page_function**; 1239 wait_page.folio = folio; 1240 wait_page.bit_nr = bit_nr; 1241

1242 **repeat**:

1243 wait-\>flags = 0;

1244 **if** (behavior == **EXCLUSIVE**) { 1245 wait-\>flags = **WQ_FLAG_EXCLUSIVE**; 1246 **if** (--unfairness \< 0) 1247 wait-\>flags \|= **WQ_FLAG_CUSTOM**; 1248 }

1249

1250 */\**

1251 *\* Do one last check whether we can get the* 1252 *\* page bit synchronously.* 1253 *\**

1254 *\* Do the folio_set_waiters() marking before that* 1255 *\* to let any waker we \_just\_ missed know they* 1256 *\* need to wake us up (otherwise they'll never* 1257 *\* even go to the slow case that looks at the* 1258 *\* page queue), and add ourselves to the wait* 1259 *\* queue if we need to sleep.* 1260 *\**

1261 *\* This part needs to be done under the queue*







1262 *\* lock to avoid races.* 1263 *\*/*

1264 **spin_lock_irq**(&q-\>lock); 1265 **folio_set_waiters**(folio); 1266 **if** (!**folio_trylock_flag**(folio, bit_nr, wait)) 1267 **\_\_add_wait_queue_entry_tail**(q, wait); 1268 **spin_unlock_irq**(&q-\>lock); 1269

1270 */\**

1271 *\* From now on, all the logic will be based on* 1272 *\* the WQ_FLAG_WOKEN and WQ_FLAG_DONE flag, to* 1273 *\* see whether the page bit testing has already* 1274 *\* been done by the wake function.* 1275 *\**

1276 *\* We can drop our reference to the folio.* 1277 *\*/*

1278 **if** (behavior == **DROP**) 1279 **folio_put**(folio);



*Listing 9-150:* mm/filemap.c: [*folio_wait_bit_common()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1216) *preamble*



We won’t examine this function in absolute microscopic detail, but we

will examine the key elements of it. A lot of this functionality derives from the kernel’s wait queue implementation, which this relies upon to queue up threads waiting for folio bits to be cleared.

The function which is invoked when a bit is changed is

[wake_page_function()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1076), one which we won’t examine in order to avoid getting bogged down in write queue implementation details but we will reproduce the comment here which explains how each of the wait queue flags we estab-

lish here are utilised in Listing 9-151.



1042 */\**

1043 *\* The page wait code treats the "wait-\>flags" somewhat unusually, because*

1044 *\* we have multiple different kinds of waits, not just the usual "exclusive"*

1045 *\* one.*

1046 *\**

1047 *\* We have:*

1048 *\**

1049 *\* (a) no special bits set:* 1050 *\**

1051 *\** *We're just waiting for the bit to be released, and when a waker* 1052 *\** *calls the wakeup function, we set WQ_FLAG_WOKEN and wake it up,* 1053 *\** *and remove it from the wait queue.* 1054 *\**

1055 *\** *Simple and straightforward.* 1056 *\**

1057 *\* (b) WQ_FLAG_EXCLUSIVE:* 1058 *\**

1059 *\** *The waiter is waiting to get the lock, and only one waiter should*







1060 *\** *be woken up to avoid any thundering herd behavior. We'll set the* 1061 *\** *WQ_FLAG_WOKEN bit, wake it up, and remove it from the wait queue.* 1062 *\**

1063 *\** *This is the traditional exclusive wait.* 1064 *\**

1065 *\* (c) WQ_FLAG_EXCLUSIVE \| WQ_FLAG_CUSTOM:* 1066 *\**

1067 *\** *The waiter is waiting to get the bit, and additionally wants the* 1068 *\** *lock to be transferred to it for fair lock behavior. If the lock* 1069 *\** *cannot be taken, we stop walking the wait queue without waking* 1070 *\** *the waiter.*

1071 *\**

1072 *\** *This is the "fair lock handoff" case, and in addition to setting* 1073 *\** *WQ_FLAG_WOKEN, we set WQ_FLAG_DONE to let the waiter easily see* 1074 *\** *that it now has the lock.* 1075 *\*/*

1076 **static int wake_page_function**(wait_queue_entry_t \*wait, **unsigned** mode, **int**

sync, **void** \*arg)

1077 {

. . .

1125 }



*Listing 9-151:* mm/filemap.c: [*wake_page_function()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1076)



Returning to Listing 9-150, we see that we reference the

[sysctl_page_lock_unfairness](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1214) global variable, which refers to the

vm.page_lock_unfairness tunable.

This is used to limit how often we will tolerate the lock being stolen from

underneath us in [EXCLUSIVE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1185) mode, i.e. the one in which we intend to take the

lock as soon as another thread has relinquished it. This has already occurred

once as we are having to wait, so we decrement this value to begin with. If

we exceed this limit, we finally set the WQ_FLAG_CUSTOM flag to indicate that we

now be given this lock regardless, as handled by [wake_page_function()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1076).

Before we enter into the wait loop, we make one last gasp effort to ac-

quire the flag we desire, while setting [PG_waiters](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/page-flags.h?h=v6.0#n108) to indicate there are threads

waiting on a flag. If we can’t acquire the flag, we add the current thread to

the wait queue.

Next, if the [DROP](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1191) mode is specified, we drop a folio reference as the se-

mantics imply.

We examine the core waiting loop in Listing 9-152 below.



1281 */\**

1282 *\* Note that until the "finish_wait()", or until* 1283 *\* we see the WQ_FLAG_WOKEN flag, we need to* 1284 *\* be very careful with the 'wait-\>flags', because* 1285 *\* we may race with a waker that sets them.* 1286 *\*/*

1287 **for** (;;) {

1288 **unsigned int** flags;







1289

1290 **set_current_state**(state); 1291

1292 */\* Loop until we've been woken or interrupted \*/* 1293 flags = **smp_load_acquire**(&wait-\>flags); 1294 **if** (!(flags & **WQ_FLAG_WOKEN**)) { 1295 **if** (**signal_pending_state**(state, current)) 1296 **break**; 1297

1298 **io_schedule**(); 1299 **continue**; 1300 }

1301

1302 */\* If we were non-exclusive, we're done \*/* 1303 **if** (behavior != **EXCLUSIVE**) 1304 **break**; 1305

1306 */\* If the waker got the lock for us, we're done \*/* 1307 **if** (flags & **WQ_FLAG_DONE**) 1308 **break**; 1309

1310 */\**

1311 *\* Otherwise, if we're getting the lock, we need to* 1312 *\* try to get it ourselves.* 1313 *\**

1314 *\* And if that fails, we'll have to retry this all.* 1315 *\*/*

1316 **if** (**unlikely**(**test_and_set_bit**(bit_nr, **folio_flags**(folio, 0)))) 1317 **goto repeat**; 1318

1319 wait-\>flags \|= **WQ_FLAG_DONE**; 1320 **break**;

1321 }



*Listing 9-152:* mm/filemap.c: [*folio_wait_bit_common()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1216) *main loop*

We start by setting the scheduler mode specified in the state parameter

via [set_current_state()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n207)[,](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n207) i.e. whether the task should be uninterruptible or killable.

We then loop, waiting for the work queue to be woken, rescheduling

(and thus sleeping this process) via [io_schedule()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n303)[.](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sched.h?h=v6.0#n303)

At this stage, if the mode was not exclusive, we are done and can exit the

loop. Equally if the wait queue flag WQ_FLAG_DONE is set in [EXCLUSIVE](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1185) mode, we have the lock and can exit.

Otherwise we check to see if the lock has been taken from underneath

us, looping back to the repeat label if so to perform unfairness checks.

Finally, if we have the lock we mark it and exit the loop.

Next, we wrap things up in Listing 9-153.







1216 */\**

1217 *\* If a signal happened, this 'finish_wait()' may remove the last* 1218 *\* waiter from the wait-queues, but the folio waiters bit will remain*

1219 *\* set. That's ok. The next wakeup will take care of it, and trying*

1220 *\* to do it here would be difficult and prone to races.* 1221 *\*/*

1222 **finish_wait**(q, wait);

. . .

1337 */\**

1338 *\* NOTE! The wait-\>flags weren't stable until we've done the* 1339 *\* 'finish_wait()', and we could have exited the loop above due* 1340 *\* to a signal, and had a wakeup event happen after the signal* 1341 *\* test but before the 'finish_wait()'.* 1342 *\**

1343 *\* So only after the finish_wait() can we reliably determine* 1344 *\* if we got woken up or not, so we can now figure out the final* 1345 *\* return value based on that state without races.* 1346 *\**

1347 *\* Also note that WQ_FLAG_WOKEN is sufficient for a non-exclusive* 1348 *\* waiter, but an exclusive one requires WQ_FLAG_DONE.* 1349 *\*/*

1350 **if** (behavior == **EXCLUSIVE**) 1351 **return** wait-\>flags & **WQ_FLAG_DONE** ? 0 : -**EINTR**; 1352

1353 **return** wait-\>flags & **WQ_FLAG_WOKEN** ? 0 : -**EINTR**; 1354 }



*Listing 9-153:* mm/filemap.c: [*folio_wait_bit_common()*](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/filemap.c?h=v6.0#n1216) *suffix*



We wrap up the wait queue operation via [finish_wait()](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/sched/wait.c?h=v6.0#n387), before perform-

ing some careful checks to see if we were interrupted by a signal, returning

the EINTR error if we were.

At this point the waiting is complete and the desired behaviour has been

achieved.



