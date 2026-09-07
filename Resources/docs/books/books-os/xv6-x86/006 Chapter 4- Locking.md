**Chapter 4**  
  
**Locking**  
  
Xv6 runs on multiprocessors: computers with multiple CPUs executing indepen- dently. These multiple CPUs share physical RAM, and xv6 exploits the sharing to maintain data structures that all CPUs read and write. This sharing raises the possibil- ity of one CPU reading a data structure while another CPU is mid-way through up- dating it, or even multiple CPUs updating the same data simultaneously; without care- ful design such parallel access is likely to yield incorrect results or a broken data struc- ture. Even on a uniprocessor, an interrupt routine that uses the same data as some in- terruptible code could damage the data if the interrupt occurs at just the wrong time. Any code that accesses shared data concurrently must have a strategy for main- taining correctness despite concurrency. The concurrency may arise from accesses by multiple cores, or by multiple threads, or by interrupt code. xv6 uses a handful of sim- ple concurrency control strategies; much more sophistication is possible. This chapter focuses on one of the strategies used extensively in xv6 and many other systems: the lock .  
  
A lock provides mutual exclusion, ensuring that only one CPU at a time can hold the lock. If a lock is associated with each shared data item, and the code always holds the associated lock when using a given item, then we can be sure that the item is used from only one CPU at a time. In this situation, we say that the lock protects the data item.  
  
The rest of this chapter explains why xv6 needs locks, how xv6 implements them, and how it uses them. A key observation will be that if you look at some code in xv6, you must ask yourself if another processor (or interrupt) could change the intended behavior of the code by modifying data (or hardware resources) it depends on. You must keep in mind that a single C statement can be several machine instructions and thus another processor or an interrupt may muck around in the middle of a C state- ment. You cannot assume that lines of code on the page are executed atomically. Concurrency makes reasoning about correctness much more difficult.  
  
**Race conditions**  
  
As an example of why we need locks, consider several processors sharing a single disk, such as the IDE disk in xv6. The disk driver maintains a linked list of the out- standing disk requests (4226) and processors may add new requests to the list concur- rently (4354). If there were no concurrent requests, you might implement the linked list as follows:  
  
lock  
  
DRAFT as of September 4, 2018 51 https://pdos.csail.mit.edu/6.828/xv6  
  
CPU 1 15 16  
  
```cpp
Memory l->next list

l->next list
```
  
CPU2 15 16  
  
Time  
  
**Figure 4-1**. Example race  
  
1  
  
2  
  
3  
  
4  
  
5  
  
6  
  
7  
  
8  
  
9  
  
10  
  
11  
  
12  
  
13  
  
14  
  
15  
  
16  
  
17  
  
```cpp
struct list { int data;

struct list *next; };

struct list *list = 0; void

insert(int data) {

struct list *l;

l = malloc(sizeof *l); l->data = data; l->next = list; list = l;

}
```
  
race condition  
  
This implementation is correct if executed in isolation. However, the code is not cor- rect if more than one copy executes concurrently. If two CPUs execute insert at the same time, it could happen that both execute line 15 before either executes 16 (see Figure 4-1). If this happens, there will now be two list nodes with next set to the for- mer value of list. When the two assignments to list happen at line 16, the second one will overwrite the first; the node involved in the first assignment will be lost.  
  
The lost update at line 16 is an example of a race condition. A race condition is a situation in which a memory location is accessed concurrently, and at least one access is a write. A race is often a sign of a bug, either a lost update (if the accesses are writes) or a read of an incompletely-updated data structure. The outcome of a race depends on the exact timing of the two CPUs involved and how their memory opera- tions are ordered by the memory system, which can make race-induced errors difficult to reproduce and debug. For example, adding print statements while debugging in-  
  
DRAFT as of September 4, 2018 52 https://pdos.csail.mit.edu/6.828/xv6  
  
sert might change the timing of the execution enough to make the race disappear. The usual way to avoid races is to use a lock. Locks ensure mutual exclusion, so  
  
that only one CPU can execute insert at a time; this makes the scenario above im- possible. The correctly locked version of the above code adds just a few lines (not numbered):  
  
```cpp
6 struct list *list = 0;

struct lock listlock;

7

8 void

9 insert(int data)

10 {

11 struct list *l;

12 l = malloc(sizeof *l);

13 l->data = data;

14

acquire(&listlock);

15 l->next = list;

16 list = l;

release(&listlock);

17 }
```
  
The sequence of instructions between acquire and release is often called a critical section, and the lock protects list .  
  
When we say that a lock protects data, we really mean that the lock protects some collection of invariants that apply to the data. Invariants are properties of data struc- tures that are maintained across operations. Typically, an operation’s correct behavior depends on the invariants being true when the operation begins. The operation may temporarily violate the invariants but must reestablish them before finishing. For ex- ample, in the linked list case, the invariant is that list points at the first node in the list and that each node’s next field points at the next node. The implementation of insert violates this invariant temporarily: in line 15, l points to the next list element, but list does not point at l yet (reestablished at line 16). The race condition we ex- amined above happened because a second CPU executed code that depended on the list invariants while they were (temporarily) violated. Proper use of a lock ensures that only one CPU at a time can operate on the data structure in the critical section, so that no CPU will execute a data structure operation when the data structure’s invari- ants do not hold.  
  
You can think of locks as serializing concurrent critical sections so that they run one at a time, and thus preserve invariants (assuming they are correct in isolation). You can also think of critical sections as being atomic with respect to each other, so that a critical section that obtains the lock later sees only the complete set of changes from earlier critical sections, and never sees partially-completed updates.  
  
Note that it would also be correct to move up acquire to earlier in insert. For example, it is fine to move the call to acquire up to before line 12. This may reduce paralellism because then the calls to malloc are also serialized. The section "Using locks" below provides some guidelines for where to insert acquire and release invo- cations.  
  
mutual exclusion critical section serializing  
  
DRAFT as of September 4, 2018 53 https://pdos.csail.mit.edu/6.828/xv6  
  
**Code: Locks**  
  
Xv6 has two types of locks: spin-locks and sleep-locks. We’ll start with spin-locks. Xv6 represents a spin-lock as a struct spinlock (1501). The important field in the structure is locked, a word that is zero when the lock is available and non-zero when it is held. Logically, xv6 should acquire a lock by executing code like  
  
```cpp
21 void

22 acquire(struct spinlock *lk)

23 {

24 for(;;) {

25 if(!lk->locked) { 26 lk->locked = 1; 27 break; 28 } 29 } 30 }
```
  
Unfortunately, this implementation does not guarantee mutual exclusion on a multi- processor. It could happen that two CPUs simultaneously reach line 25, see that lk- \>locked is zero, and then both grab the lock by executing line 26. At this point, two different CPUs hold the lock, which violates the mutual exclusion property. Rather than helping us avoid race conditions, this implementation of acquire has its own race condition. The problem here is that lines 25 and 26 executed as separate actions. In order for the routine above to be correct, lines 25 and 26 must execute in one atomic (i.e., indivisible) step.  
  
To execute those two lines atomically, xv6 relies on a special x86 instruction, xchg  
  
(0569). In one atomic operation, xchg swaps a word in memory with the contents of a register. The function acquire (1574) repeats this xchg instruction in a loop; each iter- ation atomically reads lk-\>locked and sets it to 1 (1581). If the lock is already held, lk-\>locked will already be 1, so the xchg returns 1 and the loop continues. If the xchg returns 0, however, acquire has successfully acquired the lock—locked was 0 and is now 1—so the loop can stop. Once the lock is acquired, acquire records, for debugging, the CPU and stack trace that acquired the lock. If a process forgets to re- lease a lock, this information can help to identify the culprit. These debugging fields are protected by the lock and must only be edited while holding the lock.  
  
The function release (1602) is the opposite of acquire: it clears the debugging fields and then releases the lock. The function uses an assembly instruction to clear locked, because clearing this field should be atomic so that the xchg instruction won’t see a subset of the 4 bytes that hold locked updated. The x86 guarantees that a 32-bit movl updates all 4 bytes atomically. Xv6 cannot use a regular C assignment, because the C language specification does not specify that a single assignment is atomic.  
  
Xv6’s implementation of spin-locks is x86-specific, and xv6 is thus not directly portable to other processors. To allow for portable implementations of spin-locks, the C language supports a library of atomic instructions; a portable operating system would use those instructions.  
  
**Code: Using locks**  
  
struct spinlock+code  
  
acquire+code atomic xchg+code acquire+code release+code  
  
DRAFT as of September 4, 2018 54 https://pdos.csail.mit.edu/6.828/xv6  
  
Xv6 uses locks in many places to avoid race conditions. A simple example is in the IDE driver (4200). As mentioned in the beginning of the chapter, iderw (4354) has a queue of disk requests and processors may add new requests to the list concurrently  
  
(4369). To protect this list and other invariants in the driver, iderw acquires the ide- lock (4365) and releases it at the end of the function.  
  
Exercise 1 explores how to trigger the IDE driver race condition that we saw at the beginning of the chapter by moving the acquire to after the queue manipulation. It is worthwhile to try the exercise because it will make clear that it is not that easy to trigger the race, suggesting that it is difficult to find race-conditions bugs. It is not un- likely that xv6 has some races.  
  
A hard part about using locks is deciding how many locks to use and which data and invariants each lock protects. There are a few basic principles. First, any time a variable can be written by one CPU at the same time that another CPU can read or write it, a lock should be introduced to keep the two operations from overlapping. Second, remember that locks protect invariants: if an invariant involves multiple memory locations, typically all of them need to be protected by a single lock to ensure the invariant is maintained.  
  
The rules above say when locks are necessary but say nothing about when locks are unnecessary, and it is important for efficiency not to lock too much, because locks reduce parallelism. If parallelism isn’t important, then one could arrange to have only a single thread and not worry about locks. A simple kernel can do this on a multipro- cessor by having a single lock that must be acquired on entering the kernel and re- leased on exiting the kernel (though system calls such as pipe reads or wait would pose a problem). Many uniprocessor operating systems have been converted to run on multiprocessors using this approach, sometimes called a ‘‘giant kernel lock,’’ but the ap- proach sacrifices parallelism: only one CPU can execute in the kernel at a time. If the kernel does any heavy computation, it would be more efficient to use a larger set of more fine-grained locks, so that the kernel could execute on multiple CPUs simultane- ously.  
  
Ultimately, the choice of lock granularity is an exercise in parallel programming. Xv6 uses a few coarse data-structure specific locks (see Figure 4-2). For example, xv6 has a lock that protects the whole process table and its invariants, which are described in Chapter 5. A more fine-grained approach would be to have a lock per entry in the process table so that threads working on different entries in the process table can pro- ceed in parallel. However, it complicates operations that have invariants over the whole process table, since they might have to acquire several locks. Subsequent chap- ters will discuss how each part of xv6 deals with concurrency, illustrating how to use locks.  
  
**Deadlock and lock ordering**  
  
If a code path through the kernel must hold several locks at the same time, it is im- portant that all code paths acquire the locks in the same order. If they don’t, there is a risk of deadlock. Let’s say two code paths in xv6 need locks A and B, but code path 1 acquires locks in the order A then B, and the other path acquires them in the order B  
  
iderw+code idelock+code  
  
DRAFT as of September 4, 2018 55 https://pdos.csail.mit.edu/6.828/xv6  
  
**Lock Description**  
  
bcache.lock Protects allocation of block buffer cache entries  
  
cons.lock Serializes access to console hardware, avoids intermixed output  
  
ftable.lock Serializes allocation of a struct file in file table  
  
icache.lock Protects allocation of inode cache entries  
  
idelock Serializes access to disk hardware and disk queue  
  
kmem.lock Serializes allocation of memory  
  
log.lock Serializes operations on the transaction log  
  
pipe’s p-\>lock Serializes operations on each pipe  
  
ptable.lock Serializes context switching, and operations on proc-\>state and proctable  
  
tickslock Serializes operations on the ticks counter  
  
inode’s ip-\>lock Serializes operations on each inode and its content  
  
buf’s b-\>lock Serializes operations on each block buffer  
  
**Figure 4-2**. Locks in xv6  
  
then A. This situation can result in a deadlock if two threads execute the code paths concurrently. Suppose thread T1 executes code path 1 and acquires lock A, and thread T2 executes code path 2 and acquires lock B. Next T1 will try to acquire lock B, and T2 will try to acquire lock A. Both acquires will block indefinitely, because in both cases the other thread holds the needed lock, and won’t release it until its acquire re- turns. To avoid such deadlocks, all code paths must acquire locks in the same order. The need for a global lock acquisition order means that locks are effectively part of each function’s specification: callers must invoke functions in a way that causes locks to be acquired in the agreed-on order.  
  
Xv6 has many lock-order chains of length two involving the ptable.lock, due to the way that sleep works as discussed in Chapter 5. For example, ideintr holds the ide lock while calling wakeup, which acquires the ptable lock. The file system code contains xv6’s longest lock chains. For example, creating a file requires simultaneously holding a lock on the directory, a lock on the new file’s inode, a lock on a disk block buffer, idelock, and ptable.lock. To avoid deadlock, file system code always acquires locks in the order mentioned in the previous sentence.  
  
**Interrupt handlers**  
  
Xv6 uses spin-locks in many situations to protect data that is used by both interrupt handlers and threads. For example, a timer interrupt might (3414) increment ticks at about the same time that a kernel thread reads ticks in sys_sleep (3823). The lock tickslock serializes the two accesses.  
  
Interrupts can cause concurrency even on a single processor: if interrupts are en- abled, kernel code can be stopped at any moment to run an interrupt handler instead. Suppose iderw held the idelock and then got interrupted to run ideintr. Ideintr would try to lock idelock, see it was held, and wait for it to be released. In this situ- ation, idelock will never be released—only iderw can release it, and iderw will not continue running until ideintr returns—so the processor, and eventually the whole system, will deadlock.  
  
ideintr+code wakeup+code ptable+code ticks+code sys_sleep+code tickslock+code iderw+code idelock+code ideintr+code  
  
DRAFT as of September 4, 2018 56 https://pdos.csail.mit.edu/6.828/xv6  
  
To avoid this situation, if a spin-lock is used by an interrupt handler, a processor must never hold that lock with interrupts enabled. Xv6 is more conservative: when a processor enters a spin-lock critical section, xv6 always ensures interrupts are disabled on that processor. Interrupts may still occur on other processors, so an interrupt’s ac- quire can wait for a thread to release a spin-lock; just not on the same processor.  
  
xv6 re-enables interrupts when a processor holds no spin-locks; it must do a little book-keeping to cope with nested critical sections. acquire calls pushcli (1667) and release calls popcli (1679) to track the nesting level of locks on the current processor. When that count reaches zero, popcli restores the interrupt enable state that existed at the start of the outermost critical section. The cli and sti functions execute the x86 interrupt disable and enable instructions, respectively.  
  
It is important that acquire call pushcli before the xchg that might acquire the lock (1581). If the two were reversed, there would be a few instruction cycles when the lock was held with interrupts enabled, and an unfortunately timed interrupt would deadlock the system. Similarly, it is important that release call popcli only after the xchg that releases the lock (1581) .  
  
**Instruction and memory ordering**  
  
This chapter has assumed that code executes in the order in which the code ap- pears in the program. Many compilers and processors, however, execute code out of order to achieve higher performance. If an instruction takes many cycles to complete, a processor may want to issue the instruction early so that it can overlap with other instructions and avoid processor stalls. For example, a processor may notice that in a serial sequence of instructions A and B are not dependent on each other and start in- struction B before A so that it will be completed when the processor completes A. A compiler may perform a similar re-ordering by emitting instruction B before instruc- tion A in the executable file. Concurrency, however, may expose this reordering to software, which can lead to incorrect behavior.  
  
For example, in this code for insert, it would be a disaster if the compiler or processor caused the effects of line 4 (or 2 or 5) to be visible to other cores after the effects of line 6:  
  
```cpp
1 l = malloc(sizeof *l);

2 l->data = data;

3 acquire(&listlock);

4 l->next = list;

5 list = l;

6 release(&listlock);
```
  
If the hardware or compiler would re-order, for example, the effects of line 4 to be vis- ible after line 6, then another processor can acquire listlock and observe that list points to l, but it won’t observe that l-\>next is set to the remainder of the list and won’t be able to read the rest of the list.  
  
To tell the hardware and compiler not to perform such re-orderings, xv6 uses \_\_sync_synchronize(), in both acquire and release. \_sync_synchronize() is a memory barrier: it tells the compiler and CPU to not reorder loads or stores across  
  
pushcli+code popcli+code acquire+code xchg+code release+code popcli+code xchg+code  
  
DRAFT as of September 4, 2018 57 https://pdos.csail.mit.edu/6.828/xv6  
  
the barrier. Xv6 worries about ordering only in acquire and release, because con- current access to data structures other than the lock structure is performed between acquire and release .  
  
**Sleep locks**  
  
Sometimes xv6 code needs to hold a lock for a long time. For example, the file system (Chapter 6) keeps a file locked while reading and writing its content on the disk, and these disk operations can take tens of milliseconds. Efficiency demands that the processor be yielded while waiting so that other threads can make progress, and this in turn means that xv6 needs locks that work well when held across context switches. Xv6 provides such locks in the form of sleep-locks .  
  
Xv6 sleep-locks support yielding the processor during their critical sections. This property poses a design challenge: if thread T1 holds lock L1 and has yielded the pro- cessor, and thread T2 wishes to acquire L1, we have to ensure that T1 can execute while T2 is waiting so that T1 can release L1. T2 can’t use the spin-lock acquire func- tion here: it spins with interrupts turned off, and that would prevent T1 from running. To avoid this deadlock, the sleep-lock acquire routine (called acquiresleep) yields the processor while waiting, and does not disable interrupts.  
  
acquiresleep (4622) uses techniques that will be explained in Chapter 5. At a high level, a sleep-lock has a locked field that is protected by a spinlock, and ac- quiresleep’s call to sleep atomically yields the CPU and releases the spin-lock. The result is that other threads can execute while acquiresleep waits.  
  
Because sleep-locks leave interrupts enabled, they cannot be used in interrupt handlers. Because acquiresleep may yield the processor, sleep-locks cannot be used inside spin-lock critical sections (though spin-locks can be used inside sleep-lock criti- cal sections).  
  
Xv6 uses spin-locks in most situations, since they have low overhead. It uses sleep-locks only in the file system, where it is convenient to be able to hold locks across lengthy disk operations.  
  
**Limitations of locks**  
  
Locks often solve concurrency problems cleanly, but there are times when they are awkward. Subsequent chapters will point out such situations in xv6; this section out- lines some of the problems that come up.  
  
Sometimes a function uses data which must be guarded by a lock, but the func- tion is called both from code that already holds the lock and from code that wouldn’t otherwise need the lock. One way to deal with this is to have two variants of the function, one that acquires the lock, and the other that expects the caller to already hold the lock; see wakeup1 for an example (2953). Another approach is for the function to require callers to hold the lock whether the caller needs it or not, as with sched  
  
(2758). Kernel developers need to be aware of such requirements.  
  
It might seem that one could simplify situations where both caller and callee need a lock by allowing recursive locks, so that if a function holds a lock, any function it  
  
sleep-locks recursive locks  
  
DRAFT as of September 4, 2018 58 https://pdos.csail.mit.edu/6.828/xv6  
  
calls is allowed to re-acquire the lock. However, the programmer would then need to reason about all combinations of caller and callee, because it will no longer be the case that the data structure’s invariants always hold after an acquire. Whether recursive locks are better than xv6’s use of conventions about functions that require a lock to be held is not clear. The larger lesson is that (as with global lock ordering to avoid dead- lock) lock requirements sometimes can’t be private, but intrude themselves on the in- terfaces of functions and modules.  
  
A situation in which locks are insufficient is when one thread needs to wait for another thread’s update to a data structure, for example when a pipe’s reader waits for some other thread to write the pipe. The waiting thread cannot hold the lock on the data, since that would prevent the update it is waiting for. Instead, xv6 provides a sepa- rate mechanism that jointly manages the lock and event wait; see the description of sleep and wakeup in Chapter 5.  
  
**Real world**  
  
Concurrency primitives and parallel programming are active areas of research, because programming with locks is still challenging. It is best to use locks as the base for higher-level constructs like synchronized queues, although xv6 does not do this. If you program with locks, it is wise to use a tool that attempts to identify race conditions, because it is easy to miss an invariant that requires a lock.  
  
Most operating systems support POSIX threads (Pthreads), which allow a user process to have several threads running concurrently on different processors. Pthreads has support for user-level locks, barriers, etc. Supporting Pthreads requires support from the operating system. For example, it should be the case that if one pthread blocks in a system call, another pthread of the same process should be able to run on that processor. As another example, if a pthread changes its process’s address space (e.g., grow or shrink it), the kernel must arrange that other processors that run threads of the same process update their hardware page tables to reflect the change in the ad- dress space. On the x86, this involves shooting down the Translation Look-aside Buffer (TLB) of other processors using inter-processor interrupts (IPIs).  
  
It is possible to implement locks without atomic instructions, but it is expensive, and most operating systems use atomic instructions.  
  
Locks can be expensive if many processors try to acquire the same lock at the same time. If one processor has a lock cached in its local cache, and another proces- sor must acquire the lock, then the atomic instruction to update the cache line that holds the lock must move the line from the one processor’s cache to the other proces- sor’s cache, and perhaps invalidate any other copies of the cache line. Fetching a cache line from another processor’s cache can be orders of magnitude more expensive than fetching a line from a local cache.  
  
To avoid the expenses associated with locks, many operating systems use lock-free data structures and algorithms. For example, it is possible to implement a linked list like the one in the beginning of the chapter that requires no locks during list searches, and one atomic instruction to insert an item in a list. Lock-free programming is more complicated, however, than programming locks; for example, one must worry about in-  
  
Translation Look- aside Buffer (TLB)  
  
DRAFT as of September 4, 2018 59 https://pdos.csail.mit.edu/6.828/xv6  
  
struction and memory reordering. Programming with locks is already hard, so xv6 avoids the additional complexity of lock-free programming.  
  
**Exercises**  
  
1. Move the acquire in iderw to before sleep. Is there a race? Why don’t you observe it when booting xv6 and run stressfs? Increase critical section with a dummy loop; what do you see now? explain.  
  
2. Remove the xchg in acquire. Explain what happens when you run xv6?  
  
3. Write a parallel program using POSIX threads, which is supported on most op- erating systems. For example, implement a parallel hash table and measure if the num- ber of puts/gets scales with increasing number of cores.  
  
4. Implement a subset of Pthreads in xv6. That is, implement a user-level thread library so that a user process can have more than 1 thread and arrange that these threads can run in parallel on different processors. Come up with a design that cor- rectly handles a thread making a blocking system call and changing its shared address space.  
  
DRAFT as of September 4, 2018 60 https://pdos.csail.mit.edu/6.828/xv6  
  