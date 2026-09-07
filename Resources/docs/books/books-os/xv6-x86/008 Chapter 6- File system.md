**Chapter 6**  
  
**File system**  
  
The purpose of a file system is to organize and store data. File systems typically support sharing of data among users and applications, as well as persistence so that data is still available after a reboot.  
  
The xv6 file system provides Unix-like files, directories, and pathnames (see Chap- ter 0), and stores its data on an IDE disk for persistence (see Chapter 3). The file sys- tem addresses several challenges:  
  
• The file system needs on-disk data structures to represent the tree of named di- rectories and files, to record the identities of the blocks that hold each file’s con- tent, and to record which areas of the disk are free.  
  
• The file system must support crash recovery. That is, if a crash (e.g., power failure) occurs, the file system must still work correctly after a restart. The risk is that a crash might interrupt a sequence of updates and leave inconsistent on-disk data structures (e.g., a block that is both used in a file and marked free).  
  
• Different processes may operate on the file system at the same time, so the file system code must coordinate to maintain invariants.  
  
• Accessing a disk is orders of magnitude slower than accessing memory, so the file system must maintain an in-memory cache of popular blocks.  
  
The rest of this chapter explains how xv6 addresses these challenges.  
  
**Overview**  
  
The xv6 file system implementation is organized in seven layers, shown in Figure 6-1. The disk layer reads and writes blocks on an IDE hard drive. The buffer cache layer caches disk blocks and synchronizes access to them, making sure that only one kernel process at a time can modify the data stored in any particular block. The log- ging layer allows higher layers to wrap updates to several blocks in a transaction, and ensures that the blocks are updated atomically in the face of crashes (i.e., all of them are updated or none). The inode layer provides individual files, each represented as an inode with a unique i-number and some blocks holding the file’s data. The directory layer implements each directory as a special kind of inode whose content is a sequence of directory entries, each of which contains a file’s name and i-number. The pathname layer provides hierarchical path names like /usr/rtm/xv6/fs.c, and resolves them with recursive lookup. The file descriptor layer abstracts many Unix resources (e.g., pipes, devices, files, etc.) using the file system interface, simplifying the lives of applica- tion programmers.  
  
The file system must have a plan for where it stores inodes and content blocks on the disk. To do so, xv6 divides the disk into several sections, as shown in Figure 6-2. The file system does not use block 0 (it holds the boot sector). Block 1 is called the  
  
persistence crash recovery transaction inode  
  
DRAFT as of September 4, 2018 75 https://pdos.csail.mit.edu/6.828/xv6  
  
![](media/a13c0f45d6bccc818b4ae24eae7b7ca0dc8fbf4c.jpg)  
Directory Inode  
  
Logging Buffer cache  
  
**Figure 6-1**. Layers of the xv6 file system.  
  
superblock; it contains metadata about the file system (the file system size in blocks, the number of data blocks, the number of inodes, and the number of blocks in the log). Blocks starting at 2 hold the log. After the log are the inodes, with multiple inodes per block. After those come bitmap blocks tracking which data blocks are in use. The remaining blocks are data blocks; each is either marked free in the bitmap block, or holds content for a file or directory. The superblock is filled in by a separate program, called mfks, which builds an initial file system.  
  
The rest of this chapter discusses each layer, starting with the buffer cache. Look out for situations where well-chosen abstractions at lower layers ease the design of higher ones.  
  
**Buffer cache layer**  
  
The buffer cache has two jobs: (1) synchronize access to disk blocks to ensure that only one copy of a block is in memory and that only one kernel thread at a time uses that copy; (2) cache popular blocks so that they don’t need to be re-read from the slow disk. The code is in bio.c .  
  
The main interface exported by the buffer cache consists of bread and bwrite ; the former obtains a buf containing a copy of a block which can be read or modified in memory, and the latter writes a modified buffer to the appropriate block on the disk. A kernel thread must release a buffer by calling brelse when it is done with it. The buffer cache uses a per-buffer sleep-lock to ensure that only one thread at a time uses each buffer (and thus each disk block); bread returns a locked buffer, and brelse releases the lock.  
  
Let’s return to the buffer cache. The buffer cache has a fixed number of buffers to hold disk blocks, which means that if the file system asks for a block that is not al- ready in the cache, the buffer cache must recycle a buffer currently holding some other block. The buffer cache recycles the least recently used buffer for the new block. The assumption is that the least recently used buffer is the one least likely to be used again  
  
superblock mfks+code bread+code bwrite+code buf brelse+code  
  
DRAFT as of September 4, 2018 76 https://pdos.csail.mit.edu/6.828/xv6  
  
boot super log inodes bit map data .... data  
  
0 1 2  
  
**Figure 6-2**. Structure of the xv6 file system. The header fs.h (4050) contains constants and data struc- tures describing the exact layout of the file system.  
  
soon.  
  
**Code: Buffer cache**  
  
The buffer cache is a doubly-linked list of buffers. The function binit, called by main (1230), initializes the list with the NBUF buffers in the static array buf (4450-4459) . All other access to the buffer cache refer to the linked list via bcache.head, not the buf array.  
  
A buffer has two state bits associated with it. B_VALID indicates that the buffer contains a copy of the block. B_DIRTY indicates that the buffer content has been mod- ified and needs to be written to the disk.  
  
Bread (4502) calls bget to get a buffer for the given sector (4506). If the buffer needs to be read from disk, bread calls iderw to do that before returning the buffer. Bget (4466) scans the buffer list for a buffer with the given device and sector num- bers (4472-4480). If there is such a buffer, bget acquires the sleep-lock for the buffer. bget then returns the locked buffer.  
  
If there is no cached buffer for the given sector, bget must make one, possibly reusing a buffer that held a different sector. It scans the buffer list a second time, looking for a buffer that is not locked and not dirty: any such buffer can be used. Bget edits the buffer metadata to record the new device and sector number and ac- quires its sleep-lock. Note that the assignment to flags clears B_VALID, thus ensuring that bread will read the block data from disk rather than incorrectly using the buffer’s previous contents.  
  
It is important that there is at most one cached buffer per disk sector, to ensure that readers see writes, and because the file system uses locks on buffers for synchro- nization. bget ensures this invariant by holding the bache.lock continuously from the first loop’s check of whether the block is cached through the second loop’s declara- tion that the block is now cached (by setting dev, blockno, and refcnt). This causes the check for a block’s presence and (if not present) the designation of a buffer to hold the block to be atomic.  
  
It is safe for bget to acquire the buffer’s sleep-lock outside of the bcache.lock critical section, since the non-zero b-\>refcnt prevents the buffer from being re-used for a different disk block. The sleep-lock protects reads and writes of the block’s buffered content, while the bcache.lock protects information about which blocks are cached.  
  
If all the buffers are busy, then too many processes are simultaneously executing file system calls; bget panics. A more graceful response might be to sleep until a  
  
binit+code main+code NBUF+code bcache.head+code B_VALID+code B_DIRTY+code bget+code iderw+code bget+code bget+code B_VALID+code  
  
DRAFT as of September 4, 2018 77 https://pdos.csail.mit.edu/6.828/xv6  
  
buffer became free, though there would then be a possibility of deadlock.  
  
Once bread has read the disk (if needed) and returned the buffer to its caller, the caller has exclusive use of the buffer and can read or write the data bytes. If the caller does modify the buffer, it must call bwrite to write the changed data to disk before releasing the buffer. Bwrite (4515) calls iderw to talk to the disk hardware, after setting B_DIRTY to indicate that iderw should write (rather than read).  
  
When the caller is done with a buffer, it must call brelse to release it. (The name brelse, a shortening of b-release, is cryptic but worth learning: it originated in Unix and is used in BSD, Linux, and Solaris too.) Brelse (4526) releases the sleep-lock and moves the buffer to the front of the linked list (4537-4542). Moving the buffer causes the list to be ordered by how recently the buffers were used (meaning released): the first buffer in the list is the most recently used, and the last is the least recently used. The two loops in bget take advantage of this: the scan for an existing buffer must process the entire list in the worst case, but checking the most recently used buffers first (start- ing at bcache.head and following next pointers) will reduce scan time when there is good locality of reference. The scan to pick a buffer to reuse picks the least recently used buffer by scanning backward (following prev pointers).  
  
**Logging layer**  
  
One of the most interesting problems in file system design is crash recovery. The problem arises because many file system operations involve multiple writes to the disk, and a crash after a subset of the writes may leave the on-disk file system in an incon- sistent state. For example, suppose a crash occurs during file truncation (setting the length of a file to zero and freeing its content blocks). Depending on the order of the disk writes, the crash may either leave an inode with a reference to a content block that is marked free, or it may leave an allocated but unreferenced content block.  
  
The latter is relatively benign, but an inode that refers to a freed block is likely to cause serious problems after a reboot. After reboot, the kernel might allocate that block to another file, and now we have two different files pointing unintentionally to the same block. If xv6 supported multiple users, this situation could be a security problem, since the old file’s owner would be able to read and write blocks in the new file, owned by a different user.  
  
Xv6 solves the problem of crashes during file system operations with a simple form of logging. An xv6 system call does not directly write the on-disk file system data structures. Instead, it places a description of all the disk writes it wishes to make in a log on the disk. Once the system call has logged all of its writes, it writes a special commit record to the disk indicating that the log contains a complete operation. At that point the system call copies the writes to the on-disk file system data structures. After those writes have completed, the system call erases the log on disk.  
  
If the system should crash and reboot, the file system code recovers from the crash as follows, before running any processes. If the log is marked as containing a complete operation, then the recovery code copies the writes to where they belong in the on-disk file system. If the log is not marked as containing a complete operation, the recovery code ignores the log. The recovery code finishes by erasing the log.  
  
bread+code bwrite+code iderw+code B_DIRTY+code brelse+code  
  
log  
  
commit  
  
DRAFT as of September 4, 2018 78 https://pdos.csail.mit.edu/6.828/xv6  
  
Why does xv6’s log solve the problem of crashes during file system operations? If the crash occurs before the operation commits, then the log on disk will not be marked as complete, the recovery code will ignore it, and the state of the disk will be as if the operation had not even started. If the crash occurs after the operation com- mits, then recovery will replay all of the operation’s writes, perhaps repeating them if the operation had started to write them to the on-disk data structure. In either case, the log makes operations atomic with respect to crashes: after recovery, either all of the operation’s writes appear on the disk, or none of them appear.  
  
**Log design**  
  
The log resides at a known fixed location, specified in the superblock. It consists of a header block followed by a sequence of updated block copies (‘‘logged blocks’’). The header block contains an array of sector numbers, one for each of the logged blocks, and the count of log blocks. The count in the header block on disk is either zero, indicating that there is no transaction in the log, or non-zero, indicating that the log contains a complete committed transaction with the indicated number of logged blocks. Xv6 writes the header block when a transaction commits, but not before, and sets the count to zero after copying the logged blocks to the file system. Thus a crash midway through a transaction will result in a count of zero in the log’s header block; a crash after a commit will result in a non-zero count.  
  
Each system call’s code indicates the start and end of the sequence of writes that must be atomic with respect to crashes. To allow concurrent execution of file system operations by different processes, the logging system can accumulate the writes of mul- tiple system calls into one transaction. Thus a single commit may involve the writes of multiple complete system calls. To avoid splitting a system call across transactions, the logging system only commits when no file system system calls are underway.  
  
The idea of committing several transactions together is known as group commit . Group commit reduces the number of disk operations because it amortizes the fixed cost of a commit over multiple operations. Group commit also hands the disk system more concurrent writes at the same time, perhaps allowing the disk to write them all during a single disk rotation. Xv6’s IDE driver doesn’t support this kind of batching , but xv6’s file system design allows for it.  
  
Xv6 dedicates a fixed amount of space on the disk to hold the log. The total number of blocks written by the system calls in a transaction must fit in that space. This has two consequences. No single system call can be allowed to write more dis- tinct blocks than there is space in the log. This is not a problem for most system calls, but two of them can potentially write many blocks: write and unlink. A large file write may write many data blocks and many bitmap blocks as well as an inode block; unlinking a large file might write many bitmap blocks and an inode. Xv6’s write sys- tem call breaks up large writes into multiple smaller writes that fit in the log, and un- link doesn’t cause problems because in practice the xv6 file system uses only one bitmap block. The other consequence of limited log space is that the logging system cannot allow a system call to start unless it is certain that the system call’s writes will fit in the space remaining in the log.  
  
group commit batching write+code unlink+code  
  
DRAFT as of September 4, 2018 79 https://pdos.csail.mit.edu/6.828/xv6  
  
**Code: logging**  
  
A typical use of the log in a system call looks like this:  
  
```cpp
begin_op();

...

bp = bread(...); bp->data[...] = ...; log_write(bp);

...

end_op();
```
  
begin_op (4828) waits until the logging system is not currently committing, and until there is enough unreserved log space to hold the writes from this call. log.outstanding counts the number of system calls that have reserved log space; the total reserved space is log.outstanding times MAXOPBLOCKS. Incrementing log.outstanding both reserves space and prevents a commit from occuring during this system call. The code conservatively assumes that each system call might write up to MAXOPBLOCKS distinct blocks.  
  
log_write (4922) acts as a proxy for bwrite. It records the block’s sector number in memory, reserving it a slot in the log on disk, and marks the buffer B_DIRTY to pre- vent the block cache from evicting it. The block must stay in the cache until commit- ted: until then, the cached copy is the only record of the modification; it cannot be written to its place on disk until after commit; and other reads in the same transaction must see the modifications. log_write notices when a block is written multiple times during a single transaction, and allocates that block the same slot in the log. This op- timization is often called absorption. It is common that, for example, the disk block containing inodes of several files is written several times within a transaction. By ab- sorbing several disk writes into one, the file system can save log space and can achieve better performance because only one copy of the disk block must be written to disk. end_op (4853) first decrements the count of outstanding system calls. If the count  
  
is now zero, it commits the current transaction by calling commit(). There are four stages in this process. write_log() (4885) copies each block modified in the transac- tion from the buffer cache to its slot in the log on disk. write_head() (4804) writes the header block to disk: this is the commit point, and a crash after the write will re- sult in recovery replaying the transaction’s writes from the log. install_trans (4772)  
  
reads each block from the log and writes it to the proper place in the file system. Fi- nally end_op writes the log header with a count of zero; this has to happen before the next transaction starts writing logged blocks, so that a crash doesn’t result in recovery using one transaction’s header with the subsequent transaction’s logged blocks. recover_from_log (4818) is called from initlog (4756), which is called during boot before the first user process runs. (2865) It reads the log header, and mimics the actions of end_op if the header indicates that the log contains a committed transac- tion.  
  
An example use of the log occurs in filewrite (6002). The transaction looks like this:  
  
begin_op+code log_write+code bwrite+code absorption end_op+code install_trans+code recover_from_log+cod initlog+code filewrite+code  
  
DRAFT as of September 4, 2018 80 https://pdos.csail.mit.edu/6.828/xv6  
  
```cpp
begin_op();

ilock(f->ip);

r = writei(f->ip, ...); iunlock(f->ip); end_op();
```
  
This code is wrapped in a loop that breaks up large writes into individual transactions of just a few sectors at a time, to avoid overflowing the log. The call to writei writes many blocks as part of this transaction: the file’s inode, one or more bitmap blocks, and some data blocks.  
  
**Code: Block allocator**  
  
File and directory content is stored in disk blocks, which must be allocated from a free pool. xv6’s block allocator maintains a free bitmap on disk, with one bit per block. A zero bit indicates that the corresponding block is free; a one bit indicates that it is in use. The program mkfs sets the bits corresponding to the boot sector, su- perblock, log blocks, inode blocks, and bitmap blocks.  
  
The block allocator provides two functions: balloc allocates a new disk block, and bfree frees a block. Balloc The loop in balloc at (5022) considers every block, starting at block 0 up to sb.size, the number of blocks in the file system. It looks for a block whose bitmap bit is zero, indicating that it is free. If balloc finds such a block, it updates the bitmap and returns the block. For efficiency, the loop is split into two pieces. The outer loop reads each block of bitmap bits. The inner loop checks all BPB bits in a single bitmap block. The race that might occur if two processes try to allocate a block at the same time is prevented by the fact that the buffer cache only lets one process use any one bitmap block at a time.  
  
Bfree (5052) finds the right bitmap block and clears the right bit. Again the exclu- sive use implied by bread and brelse avoids the need for explicit locking.  
  
As with much of the code described in the remainder of this chapter, balloc and bfree must be called inside a transaction.  
  
**Inode layer**  
  
The term inode can have one of two related meanings. It might refer to the on- disk data structure containing a file’s size and list of data block numbers. Or ‘‘inode’’ might refer to an in-memory inode, which contains a copy of the on-disk inode as well as extra information needed within the kernel.  
  
The on-disk inodes are packed into a contiguous area of disk called the inode blocks. Every inode is the same size, so it is easy, given a number n, to find the nth inode on the disk. In fact, this number n, called the inode number or i-number, is how inodes are identified in the implementation.  
  
The on-disk inode is defined by a struct dinode (4078). The type field distin- guishes between files, directories, and special files (devices). A type of zero indicates that an on-disk inode is free. The nlink field counts the number of directory entries that refer to this inode, in order to recognize when the on-disk inode and its data  
  
writei+code balloc+code bfree+code inode  
  
struct dinode+code  
  
DRAFT as of September 4, 2018 81 https://pdos.csail.mit.edu/6.828/xv6  
  
blocks should be freed. The size field records the number of bytes of content in the file. The addrs array records the block numbers of the disk blocks holding the file’s content.  
  
The kernel keeps the set of active inodes in memory; struct inode (4162) is the in-memory copy of a struct dinode on disk. The kernel stores an inode in memory only if there are C pointers referring to that inode. The ref field counts the number of C pointers referring to the in-memory inode, and the kernel discards the inode from memory if the reference count drops to zero. The iget and iput functions acquire and release pointers to an inode, modifying the reference count. Pointers to an inode can come from file descriptors, current working directories, and transient kernel code such as exec .  
  
There are four lock or lock-like mechanisms in xv6’s inode code. icache.lock protects the invariant that an inode is present in the cache at most once, and the in- variant that a cached inode’s ref field counts the number of in-memory pointers to the cached inode. Each in-memory inode has a lock field containing a sleep-lock, which ensures exclusive access to the inode’s fields (such as file length) as well as to the inode’s file or directory content blocks. An inode’s ref, if it is greater than zero, causes the system to maintain the inode in the cache, and not re-use the cache entry for a different inode. Finally, each inode contains a nlink field (on disk and copied in memory if it is cached) that counts the number of directory entries that refer to a file; xv6 won’t free an inode if its link count is greater than zero.  
  
A struct inode pointer returned by iget() is guaranteed to be valid until the corresponding call to iput(); the inode won’t be deleted, and the memory referred to by the pointer won’t be re-used for a different inode. iget() provides non-exclusive access to an inode, so that there can be many pointers to the same inode. Many parts of the file system code depend on this behavior of iget(), both to hold long-term ref- erences to inodes (as open files and current directories) and to prevent races while avoiding deadlock in code that manipulates multiple inodes (such as pathname lookup).  
  
The struct inode that iget returns may not have any useful content. In order to ensure it holds a copy of the on-disk inode, code must call ilock. This locks the inode (so that no other process can ilock it) and reads the inode from the disk, if it has not already been read. iunlock releases the lock on the inode. Separating acqui- sition of inode pointers from locking helps avoid deadlock in some situations, for ex- ample during directory lookup. Multiple processes can hold a C pointer to an inode returned by iget, but only one process can lock the inode at a time.  
  
The inode cache only caches inodes to which kernel code or data structures hold C pointers. Its main job is really synchronizing access by multiple processes; caching is secondary. If an inode is used frequently, the buffer cache will probably keep it in memory if it isn’t kept by the inode cache. The inode cache is write-through, which means that code that modifies a cached inode must immediately write it to disk with iupdate .  
  
**Code: Inodes**  
  
struct inode+code iget+code iput+code ilock+code  
  
DRAFT as of September 4, 2018 82 https://pdos.csail.mit.edu/6.828/xv6  
  
To allocate a new inode (for example, when creating a file), xv6 calls ialloc  
  
(5204). Ialloc is similar to balloc: it loops over the inode structures on the disk, one block at a time, looking for one that is marked free. When it finds one, it claims it by writing the new type to the disk and then returns an entry from the inode cache with the tail call to iget (5218). The correct operation of ialloc depends on the fact that only one process at a time can be holding a reference to bp: ialloc can be sure that some other process does not simultaneously see that the inode is available and try to claim it.  
  
Iget (5254) looks through the inode cache for an active entry (ip-\>ref \> 0) with the desired device and inode number. If it finds one, it returns a new reference to that inode. (5263-5267). As iget scans, it records the position of the first empty slot (5268- 5269), which it uses if it needs to allocate a cache entry.  
  
Code must lock the inode using ilock before reading or writing its metadata or content. Ilock (5303) uses a sleep-lock for this purpose. Once ilock has exclusive ac- cess to the inode, it reads the inode from disk (more likely, the buffer cache) if needed. The function iunlock (5331) releases the sleep-lock, which may cause any processes sleeping to be woken up.  
  
Iput (5358) releases a C pointer to an inode by decrementing the reference count  
  
(5376). If this is the last reference, the inode’s slot in the inode cache is now free and can be re-used for a different inode.  
  
If iput sees that there are no C pointer references to an inode and that the inode has no links to it (occurs in no directory), then the inode and its data blocks must be freed. Iput calls itrunc to truncate the file to zero bytes, freeing the data blocks; sets the inode type to 0 (unallocated); and writes the inode to disk (5366) .  
  
The locking protocol in iput in the case in which it frees the inode deserves a closer look. One danger is that a concurrent thread might be waiting in ilock to use this inode (e.g. to read a file or list a directory), and won’t be prepared to find the in- ode is not longer allocated. This can’t happen because there is no way for a system call to get a pointer to a cached inode if it has no links to it and ip-\>ref is one. That one reference is the reference owned by the thread calling iput. It’s true that iput checks that the reference count is one outside of its icache.lock critical section, but at that point the link count is known to be zero, so no thread will try to acquire a new refer- ence. The other main danger is that a concurrent call to ialloc might choose the same inode that iput is freeing. This can only happen after the iupdate writes the disk so that the inode has type zero. This race is benign; the allocating thread will po- litely wait to acquire the inode’s sleep-lock before reading or writing the inode, at which point iput is done with it.  
  
iput() can write to the disk. This means that any system call that uses the file system may write the disk, because the system call may be the last one having a refer- ence to the file. Even calls like read() that appear to be read-only, may end up calling iput(). This, in turn, means that even read-only system calls must be wrapped in transactions if they use the file system.  
  
There is a challenging interaction between iput() and crashes. iput() doesn’t truncate a file immediately when the link count for the file drops to zero, because some process might still hold a reference to the inode in memory: a process might still  
  
ialloc+code balloc+code iget+code iget+code ilock+code ilock+code iunlock+code iput+code itrunc+code iput+code  
  
DRAFT as of September 4, 2018 83 https://pdos.csail.mit.edu/6.828/xv6  
  
dinode type  
  
major minor nlink size address 1  
  
..... address 12 indirect  
  
data  
  
...  
  
data  
  
data  
  
indirect block address 1  
  
..... address 128  
  
...  
  
data  
  
**Figure 6-3**. The representation of a file on disk.  
  
be reading and writing to the file, because it successfully opened it. But, if a crash hap- pens before the last process closes the file descriptor for the file, then the file will be marked allocated on disk but no directory entry points to it.  
  
File systems handle this case in one of two ways. The simple solution is that on recovery, after reboot, the file system scans the whole file system for files that are marked allocated, but have no directory entry pointing to them. If any such file exists, then it can free those files.  
  
The second solution doesn’t require scanning the file system. In this solution, the file system records on disk (e.g., in the super block) the inode inumber of a file whose link count drops to zero but whose reference count isn’t zero. If the file system re- moves the file when its reference counts reaches 0, then it updates the on-disk list by removing that inode from the list. On recovery, the file system frees any file in the list. Xv6 implements neither solution, which means that inodes may be marked allo- cated on disk, even though they are not in use anymore. This means that over time xv6 runs the risk that it may run out of disk space.  
  
**Code: Inode content**  
  
The on-disk inode structure, struct dinode, contains a size and an array of block numbers (see Figure 6-3). The inode data is found in the blocks listed in the dinode’s addrs array. The first NDIRECT blocks of data are listed in the first NDIRECT  
  
struct dinode+code NDIRECT+code  
  
DRAFT as of September 4, 2018 84 https://pdos.csail.mit.edu/6.828/xv6  
  
entries in the array; these blocks are called direct blocks. The next NINDIRECT blocks of data are listed not in the inode but in a data block called the indirect block. The last entry in the addrs array gives the address of the indirect block. Thus the first 6 kB (NDIRECT×BSIZE) bytes of a file can be loaded from blocks listed in the inode, while the next 64kB (NINDIRECT×BSIZE) bytes can only be loaded after consulting the indi- rect block. This is a good on-disk representation but a complex one for clients. The function bmap manages the representation so that higher-level routines such as readi and writei, which we will see shortly. Bmap returns the disk block number of the bn’th data block for the inode ip. If ip does not have such a block yet, bmap allocates  
  
direct blocks NINDIRECT+code indirect block BSIZE+code bmap+code readi+code writei+code bmap+code NDIRECT+code NINDIRECT+code itrunc+code readi+code  
  
one.  
  
The function bmap (5410) begins by picking off the easy case: the first NDIRECT  
  
writei+code writei+code readi+code  
  
blocks are listed in the inode itself (5415-5419). The next NINDIRECT blocks are listed in the indirect block at ip-\>addrs\[NDIRECT\]. Bmap reads the indirect block (5426) and then reads a block number from the right position within the block (5427). If the block number exceeds NDIRECT+NINDIRECT, bmap panics; writei contains the check that prevents this from happening (5566) .  
  
Bmap allocates blocks as needed. An ip-\>addrs\[\] or indirect entry of zero indi- cates that no block is allocated. As bmap encounters zeros, it replaces them with the numbers of fresh blocks, allocated on demand. (5416-5417, 5424-5425) .  
  
itrunc frees a file’s blocks, resetting the inode’s size to zero. Itrunc (5456) starts by freeing the direct blocks (5462-5467), then the ones listed in the indirect block (5472- 5475), and finally the indirect block itself (5477-5478) .  
  
Bmap makes it easy for readi and writei to get at an inode’s data. Readi (5503)  
  
starts by making sure that the offset and count are not beyond the end of the file. Reads that start beyond the end of the file return an error (5514-5515) while reads that start at or cross the end of the file return fewer bytes than requested (5516-5517). The main loop processes each block of the file, copying data from the buffer into dst  
  
(5519-5524). writei (5553) is identical to readi, with three exceptions: writes that start at or cross the end of the file grow the file, up to the maximum file size (5566-5567); the loop copies data into the buffers instead of out (5572); and if the write has extended the file, writei must update its size (5577-5580) .  
  
Both readi and writei begin by checking for ip-\>type == T_DEV. This case handles special devices whose data does not live in the file system; we will return to this case in the file descriptor layer.  
  
The function stati (5488) copies inode metadata into the stat structure, which is exposed to user programs via the stat system call.  
  
**Code: directory layer**  
  
A directory is implemented internally much like a file. Its inode has type T_DIR and its data is a sequence of directory entries. Each entry is a struct dirent (4115) , which contains a name and an inode number. The name is at most DIRSIZ (14) char- acters; if shorter, it is terminated by a NUL (0) byte. Directory entries with inode number zero are free.  
  
The function dirlookup (5611) searches a directory for an entry with the given  
  
writei+code readi+code writei+code T_DEV+code stati+code stat+code T_DIR+code struct dirent+code DIRSIZ+code dirlookup+code  
  
DRAFT as of September 4, 2018 85 https://pdos.csail.mit.edu/6.828/xv6  
  
name. If it finds one, it returns a pointer to the corresponding inode, unlocked, and sets \*poff to the byte offset of the entry within the directory, in case the caller wishes to edit it. If dirlookup finds an entry with the right name, it updates \*poff, releases the block, and returns an unlocked inode obtained via iget. Dirlookup is the reason that iget returns unlocked inodes. The caller has locked dp, so if the lookup was for ., an alias for the current directory, attempting to lock the inode before returning would try to re-lock dp and deadlock. (There are more complicated deadlock scenar- ios involving multiple processes and .., an alias for the parent directory; . is not the only problem.) The caller can unlock dp and then lock ip, ensuring that it only holds one lock at a time.  
  
The function dirlink (5652) writes a new directory entry with the given name and inode number into the directory dp. If the name already exists, dirlink returns an error (5658-5662). The main loop reads directory entries looking for an unallocated entry. When it finds one, it stops the loop early (5622-5623), with off set to the offset of the available entry. Otherwise, the loop ends with off set to dp-\>size. Either way, dirlink then adds a new entry to the directory by writing at offset off (5672-5675) .  
  
**Code: Path names**  
  
Path name lookup involves a succession of calls to dirlookup, one for each path component. Namei (5790) evaluates path and returns the corresponding inode. The function nameiparent is a variant: it stops before the last element, returning the inode of the parent directory and copying the final element into name. Both call the general- ized function namex to do the real work.  
  
Namex (5755) starts by deciding where the path evaluation begins. If the path be- gins with a slash, evaluation begins at the root; otherwise, the current directory (5759- 5762). Then it uses skipelem to consider each element of the path in turn (5764). Each iteration of the loop must look up name in the current inode ip. The iteration begins by locking ip and checking that it is a directory. If not, the lookup fails (5765-5769) . (Locking ip is necessary not because ip-\>type can change underfoot—it can’t—but because until ilock runs, ip-\>type is not guaranteed to have been loaded from disk.) If the call is nameiparent and this is the last path element, the loop stops early, as per the definition of nameiparent; the final path element has already been copied into name, so namex need only return the unlocked ip (5770-5774). Finally, the loop looks for the path element using dirlookup and prepares for the next iteration by setting ip = next (5775-5780). When the loop runs out of path elements, it returns ip .  
  
The procedure namex may take a long time to complete: it could involve several disk operations to read inodes and directory blocks for the directories traversed in the pathname (if they are not in the buffer cache). Xv6 is carefully designed so that if an invocation of namex by one kernel thread is blocked on a disk I/O, another kernel thread looking up a different pathname can proceed concurrently. namex locks each directory in the path separately so that lookups in different directories can proceed in parallel.  
  
This concurrency introduces some challenges. For example, while one kernel thread is looking up a pathname another kernel thread may be changing the directory  
  
iget+code .+code ..+code dirlink+code dirlookup+code nameiparent+code namex+code skipelem+code ilock+code nameiparent+code namex+code dirlookup+code  
  
DRAFT as of September 4, 2018 86 https://pdos.csail.mit.edu/6.828/xv6  
  
tree by unlinking a directory. A potential risk is that a lookup may be searching a di- rectory that has been deleted by another kernel thread and its blocks have been re- used for another directory or file.  
  
Xv6 avoids such races. For example, when executing dirlookup in namex, the lookup thread holds the lock on the directory and dirlookup returns an inode that was obtained using iget. iget increases the reference count of the inode. Only after receiving the inode from dirlookup does namex release the lock on the directory. Now another thread may unlink the inode from the directory but xv6 will not delete the inode yet, because the reference count of the inode is still larger than zero. Another risk is deadlock. For example, next points to the same inode as ip when looking up ".". Locking next before releasing the lock on ip would result in a deadlock. To avoid this deadlock, namex unlocks the directory before obtaining a lock on next. Here again we see why the separation between iget and ilock is important.  
  
**File descriptor layer**  
  
A cool aspect of the Unix interface is that most resources in Unix are represented as files, including devices such as the console, pipes, and of course, real files. The file descriptor layer is the layer that achieves this uniformity.  
  
Xv6 gives each process its own table of open files, or file descriptors, as we saw in Chapter 0. Each open file is represented by a struct file (4150), which is a wrapper around either an inode or a pipe, plus an i/o offset. Each call to open creates a new open file (a new struct file): if multiple processes open the same file independently, the different instances will have different i/o offsets. On the other hand, a single open file (the same struct file) can appear multiple times in one process’s file table and also in the file tables of multiple processes. This would happen if one process used open to open the file and then created aliases using dup or shared it with a child using fork. A reference count tracks the number of references to a particular open file. A file can be open for reading or writing or both. The readable and writable fields track this.  
  
All the open files in the system are kept in a global file table, the ftable. The file table has a function to allocate a file (filealloc), create a duplicate reference (filedup), release a reference (fileclose), and read and write data (fileread and filewrite ).  
  
The first three follow the now-familiar form. Filealloc (5876) scans the file table for an unreferenced file (f-\>ref == 0) and returns a new reference; filedup (5902) in- crements the reference count; and fileclose (5914) decrements it. When a file’s refer- ence count reaches zero, fileclose releases the underlying pipe or inode, according to the type.  
  
The functions filestat, fileread, and filewrite implement the stat, read , and write operations on files. Filestat (5952) is only allowed on inodes and calls stati. Fileread and filewrite check that the operation is allowed by the open mode and then pass the call through to either the pipe or inode implementation. If the file represents an inode, fileread and filewrite use the i/o offset as the offset for the operation and then advance it (5975-5976, 6015-6016). Pipes have no concept of off-  
  
struct file+code open+code dup+code fork+code ftable+code filealloc+code filedup+code fileclose+code fileread+code filewrite+code filedup+code fileclose+code filestat+code fileread+code filewrite+code stat+code read+code write+code stati+code  
  
DRAFT as of September 4, 2018 87 https://pdos.csail.mit.edu/6.828/xv6  
  
set. Recall that the inode functions require the caller to handle locking (5955-5957, 5974- 5977, 6025-6028). The inode locking has the convenient side effect that the read and write offsets are updated atomically, so that multiple writing to the same file simultaneously cannot overwrite each other’s data, though their writes may end up interlaced.  
  
**Code: System calls**  
  
With the functions that the lower layers provide the implementation of most sys- tem calls is trivial (see sysfile.c). There are a few calls that deserve a closer look. The functions sys_link and sys_unlink edit directories, creating or removing references to inodes. They are another good example of the power of using transac- tions. Sys_link (6202) begins by fetching its arguments, two strings old and new (6207) . Assuming old exists and is not a directory (6211-6214), sys_link increments its ip- \>nlink count. Then sys_link calls nameiparent to find the parent directory and final path element of new (6227) and creates a new directory entry pointing at old’s in- ode (6230). The new parent directory must exist and be on the same device as the ex- isting inode: inode numbers only have a unique meaning on a single disk. If an error like this occurs, sys_link must go back and decrement ip-\>nlink .  
  
Transactions simplify the implementation because it requires updating multiple disk blocks, but we don’t have to worry about the order in which we do them. They ei- ther will all succeed or none. For example, without transactions, updating ip-\>nlink before creating a link, would put the file system temporarily in an unsafe state, and a crash in between could result in havoc. With transactions we don’t have to worry about this.  
  
Sys_link creates a new name for an existing inode. The function create (6357)  
  
creates a new name for a new inode. It is a generalization of the three file creation system calls: open with the O_CREATE flag makes a new ordinary file, mkdir makes a new directory, and mkdev makes a new device file. Like sys_link, create starts by caling nameiparent to get the inode of the parent directory. It then calls dirlookup to check whether the name already exists (6367). If the name does exist, create’s be- havior depends on which system call it is being used for: open has different semantics from mkdir and mkdev. If create is being used on behalf of open (type == T_FILE ) and the name that exists is itself a regular file, then open treats that as a success, so create does too (6371). Otherwise, it is an error (6372-6373). If the name does not al- ready exist, create now allocates a new inode with ialloc (6376). If the new inode is a directory, create initializes it with . and .. entries. Finally, now that the data is initialized properly, create can link it into the parent directory (6389). Create, like sys_link, holds two inode locks simultaneously: ip and dp. There is no possibility of deadlock because the inode ip is freshly allocated: no other process in the system will hold ip’s lock and then try to lock dp .  
  
Using create, it is easy to implement sys_open, sys_mkdir, and sys_mknod . Sys_open (6401) is the most complex, because creating a new file is only a small part of what it can do. If open is passed the O_CREATE flag, it calls create (6414). Otherwise, it calls namei (6420). Create returns a locked inode, but namei does not, so sys_open must lock the inode itself. This provides a convenient place to check that directories  
  
sys_link+code sys_unlink+code nameiparent+code sys_link+code create+code open+code O_CREATE+code mkdir+code mkdev+code sys_link+code create+code nameiparent+code dirlookup+code mkdir+code mkdev+code T_FILE+code ialloc+code .+code ..+code create+code sys_link+code sys_open+code sys_mkdir+code sys_mknod+code open+code O_CREATE+code namei+code sys_open+code  
  
DRAFT as of September 4, 2018 88 https://pdos.csail.mit.edu/6.828/xv6  
  
are only opened for reading, not writing. Assuming the inode was obtained one way or the other, sys_open allocates a file and a file descriptor (6432) and then fills in the file (6442-6446). Note that no other process can access the partially initialized file since it is only in the current process’s table.  
  
Chapter 5 examined the implementation of pipes before we even had a file sys- tem. The function sys_pipe connects that implementation to the file system by pro- viding a way to create a pipe pair. Its argument is a pointer to space for two integers, where it will record the two new file descriptors. Then it allocates the pipe and in- stalls the file descriptors.  
  
**Real world**  
  
The buffer cache in a real-world operating system is significantly more complex than xv6’s, but it serves the same two purposes: caching and synchronizing access to the disk. Xv6’s buffer cache, like V6’s, uses a simple least recently used (LRU) eviction policy; there are many more complex policies that can be implemented, each good for some workloads and not as good for others. A more efficient LRU cache would elimi- nate the linked list, instead using a hash table for lookups and a heap for LRU evic- tions. Modern buffer caches are typically integrated with the virtual memory system to support memory-mapped files.  
  
Xv6’s logging system is inefficient. A commit cannot occur concurrently with file system system calls. The system logs entire blocks, even if only a few bytes in a block are changed. It performs synchronous log writes, a block at a time, each of which is likely to require an entire disk rotation time. Real logging systems address all of these problems.  
  
Logging is not the only way to provide crash recovery. Early file systems used a scavenger during reboot (for example, the UNIX fsck program) to examine every file and directory and the block and inode free lists, looking for and resolving inconsisten- cies. Scavenging can take hours for large file systems, and there are situations where it is not possible to resolve inconsistencies in a way that causes the original system calls to be atomic. Recovery from a log is much faster and causes system calls to be atomic in the face of crashes.  
  
Xv6 uses the same basic on-disk layout of inodes and directories as early UNIX; this scheme has been remarkably persistent over the years. BSD’s UFS/FFS and Linux’s ext2/ext3 use essentially the same data structures. The most inefficient part of the file system layout is the directory, which requires a linear scan over all the disk blocks dur- ing each lookup. This is reasonable when directories are only a few disk blocks, but is expensive for directories holding many files. Microsoft Windows’s NTFS, Mac OS X’s HFS, and Solaris’s ZFS, just to name a few, implement a directory as an on-disk bal- anced tree of blocks. This is complicated but guarantees logarithmic-time directory lookups.  
  
Xv6 is naive about disk failures: if a disk operation fails, xv6 panics. Whether this is reasonable depends on the hardware: if an operating systems sits atop special hard- ware that uses redundancy to mask disk failures, perhaps the operating system sees failures so infrequently that panicking is okay. On the other hand, operating systems  
  
sys_pipe+code fsck+code  
  
DRAFT as of September 4, 2018 89 https://pdos.csail.mit.edu/6.828/xv6  
  
using plain disks should expect failures and handle them more gracefully, so that the loss of a block in one file doesn’t affect the use of the rest of the file system.  
  
Xv6 requires that the file system fit on one disk device and not change in size. As large databases and multimedia files drive storage requirements ever higher, operating systems are developing ways to eliminate the ‘‘one disk per file system’’ bottleneck. The basic approach is to combine many disks into a single logical disk. Hardware solutions such as RAID are still the most popular, but the current trend is moving toward im- plementing as much of this logic in software as possible. These software implementa- tions typically allow rich functionality like growing or shrinking the logical device by adding or removing disks on the fly. Of course, a storage layer that can grow or shrink on the fly requires a file system that can do the same: the fixed-size array of in- ode blocks used by xv6 would not work well in such environments. Separating disk management from the file system may be the cleanest design, but the complex inter- face between the two has led some systems, like Sun’s ZFS, to combine them.  
  
Xv6’s file system lacks many other features of modern file systems; for example, it lacks support for snapshots and incremental backup.  
  
Modern Unix systems allow many kinds of resources to be accessed with the same system calls as on-disk storage: named pipes, network connections, remotely-ac- cessed network file systems, and monitoring and control interfaces such as /proc. In- stead of xv6’s if statements in fileread and filewrite, these systems typically give each open file a table of function pointers, one per operation, and call the function pointer to invoke that inode’s implementation of the call. Network file systems and us- er-level file systems provide functions that turn those calls into network RPCs and wait for the response before returning.  
  
**Exercises**  
  
1. Why panic in balloc? Can xv6 recover?  
  
2. Why panic in ialloc? Can xv6 recover?  
  
3. Why doesn’t filealloc panic when it runs out of files? Why is this more common and therefore worth handling?  
  
4. Suppose the file corresponding to ip gets unlinked by another process between sys_link’s calls to iunlock(ip) and dirlink. Will the link be created correctly? Why or why not?  
  
6. create makes four function calls (one to ialloc and three to dirlink) that it requires to succeed. If any doesn’t, create calls panic. Why is this acceptable? Why can’t any of those four calls fail?  
  
7. sys_chdir calls iunlock(ip) before iput(cp-\>cwd), which might try to lock cp-\>cwd, yet postponing iunlock(ip) until after the iput would not cause deadlocks. Why not?  
  
8. Implement the lseek system call. Supporting lseek will also require that you modify filewrite to fill holes in the file with zero if lseek sets off beyond f-\>ip- \>size.  
  
9. Add O_TRUNC and O_APPEND to open, so that \> and \>\> operators work in the shell.  
  
fileread+code filewrite+code  
  
DRAFT as of September 4, 2018 90 https://pdos.csail.mit.edu/6.828/xv6  
  
10. Modify the file system to support symbolic links.  
  
DRAFT as of September 4, 2018 91 https://pdos.csail.mit.edu/6.828/xv6  
  