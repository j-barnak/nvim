**Index**  
  
., 86, 88  
  
.., 86, 88  
  
/init, 27, 35 \_binary_initcode_size, 25 \_binary_initcode_start, 25 \_start, 102  
  
absorption, 80 acquire, 54, 57 addl, 26  
  
address space, 20 allocproc, 23 allocuvm, 26, 35–36 alltraps, 42–43 argc, 36  
  
argfd, 45 argint, 45 argptr, 45 argstr, 45 argv, 36 atomic, 54  
  
B_DIRTY, 47–48, 77–78 B_VALID, 47–48, 77 balloc, 81, 83 batch, 49 batching, 79 bcache.head, 77 begin_op, 80 bfree, 81 bget, 77 binit, 77 block, 47 bmap, 85  
  
boot loader, 22, 99–101 bootmain, 101  
  
bread, 76, 78 brelse, 76, 78 BSIZE, 85  
  
buf, 76  
  
busy waiting, 48, 66 bwrite, 76, 78, 80 chan, 66, 69  
  
child process, 8 cli, 46 commit, 78  
  
conditional synchronization, 65 contexts, 62  
  
control registers, 96 convoys, 72 copyout, 36 coroutines, 64 cp-\>tf, 44 cpu-\>scheduler, 26, 62–63 CR0_PE, 101  
  
CR0_PG, 23  
  
CR_PSE, 37  
  
crash recovery, 75 create, 88 critical section, 53 current directory, 14 deadlocked, 67 direct blocks, 85 dirlink, 86 dirlookup, 85–86, 88 DIRSIZ, 85  
  
DPL_USER, 25, 42 driver, 46  
  
dup, 87  
  
ELF format, 35 ELF_MAGIC, 35 EMBRYO, 23 end_op, 80  
  
entry, 22–23, 102 entrypgdir, 23 exception, 39  
  
exec, 9–11, 26, 36, 42 exit, 8, 27, 63–64, 71 fetchint, 45  
  
file descriptor, 10 filealloc, 87 fileclose, 87 filedup, 87 fileread, 87, 90 filestat, 87 filewrite, 80, 87, 90 FL_IF, 25  
  
fork, 8, 10–11, 87 forkret, 24, 26, 64 freerange, 33 fsck, 89 ftable, 87 gdt, 100–101 gdtdesc, 101  
  
getcmd, 10  
  
global descriptor table, 101 group commit, 79  
  
I/O ports, 97 ialloc, 83, 88 IDE_BSY, 47 IDE_DRDY, 47 IDE_IRQ, 47 ideinit, 47 ideintr, 48, 56 idelock, 55–56  
  
iderw, 47–48, 55–56, 77–78 idestart, 48  
  
idewait, 47 idt, 42 idtinit, 46 IF, 42, 46  
  
iget, 82–83, 86 ilock, 82–83, 86 indirect block, 85 initcode, 27 initcode.S, 25–26, 41 initlog, 80  
  
initproc, 26 inituvm, 25 inode, 15, 75, 81 insl, 48 install_trans, 80 instruction pointer, 96 int, 40–42  
  
interface design, 7 interrupt, 39 interrupt handler, 40 ioapicenable, 47 iput, 82–83  
  
iret, 26, 41, 44 IRQ_TIMER,, 46 isolation, 17 itrunc, 83, 85 iunlock, 83 kalloc, 34 KERNBASE, 23 kernel, 7, 19  
  
kernel mode, 18, 40 kernel space, 7, 19 kfree, 33  
  
DRAFT as of September 4, 2018 105 https://pdos.csail.mit.edu/6.828/xv6  
  
kinit1, 33 kinit2, 33 kmap, 32 kvmalloc, 30, 32 lapicinit, 46  
  
linear address, 99–100 links, 15  
  
loaduvm, 35  
  
lock, 51  
  
log, 78  
  
log_write, 80  
  
logical address, 99–100  
  
main, 23, 26, 32–33, 42, 47, 77 malloc, 10  
  
mappages, 32 memory-mapped I/O, 97 mfks, 76  
  
microkernel, 19–20 mkdev, 88  
  
mkdir, 88  
  
monolithic kernel, 17, 19 mpmain, 25  
  
multiplexing, 61 mutual exclusion, 53 mycpu, 65  
  
myproc, 65  
  
namei, 25, 35, 88 nameiparent, 86, 88 namex, 86  
  
```cpp
NBUF, 77 NDIRECT, 84–85 NINDIRECT, 85 O_CREATE, 88 open, 87–88 p->context, 24, 26, 64 p->cwd, 25

p->kstack, 21, 71 p->name, 25 p->pgdir, 22, 71 p->state, 22 p->sz, 45 p->xxx, 21 page, 29
```
  
page directory, 29  
  
page table entries (PTEs), 29 page table pages, 29  
  
panic, 44  
  
parent process, 8 path, 14 persistence, 75  
  
PGROUNDUP, 33  
  
physical address, 20, 99 PHYSTOP, 32–33  
  
pid, 8, 23 pipe, 13 piperead, 70 pipewrite, 70 polling, 48, 66 popal, 26 popcli, 57 popl, 26 printf, 9  
  
priority inversion, 72 privileged instructions, 18 proc-\>killed, 44 process, 7–8, 20 program counter, 95 protected mode, 100–101 ptable, 56  
  
ptable.lock, 63–64, 69 PTE_P, 29  
  
PTE_U, 26, 30, 32 PTE_W, 30 pushcli, 57  
  
race condition, 52 read, 87  
  
readi, 35, 85 readseg, 102 real mode, 99 recover_from_log, 80 recursive locks, 58 release, 54, 57 ret, 26  
  
root, 14  
  
round robin, 72 RUNNABLE, 25, 64, 68–70 sbrk, 10, 34  
  
sched, 62–64, 68, 71 scheduler, 25, 63–64 sector, 47  
  
SEG_KDATA, 101 SEG_TSS, 25 SEG_UCODE, 25 SEG_UDATA, 25 seginit, 37  
  
segment descriptor table, 100 segment registers, 96 sequence coordination, 65 serializing, 53  
  
setupkvm, 25, 32, 35  
  
```cpp
shell, 8 signal, 73 skipelem, 86 sleep, 63, 66, 68 sleep-locks, 58 SLEEPING, 68–69 stat, 85, 87 stati, 85, 87 sti, 46 stosb, 102 struct buf, 47 struct context, 62 struct cpu, 65 struct dinode, 81, 84 struct dirent, 85 struct elfhdr, 35 struct file, 87 struct inode, 82 struct pipe, 70 struct proc, 21, 71 struct run, 33 struct spinlock, 54 struct trapframe, 25 superblock, 76 switchuvm, 25, 42, 46, 64 swtch, 25–26, 62–64, 71 SYS_exec, 26, 44 sys_exec, 42 sys_link, 88 sys_mkdir, 88 sys_mknod, 88 sys_open, 88 sys_pipe, 89 sys_sleep, 56 sys_unlink, 88 syscall, 44 system call, 7 T_DEV, 85 T_DIR, 85 T_FILE, 88 T_SYSCALL, 26, 42, 44 tf->trapno, 44 thread, 21 thundering herd, 73 ticks, 56 tickslock, 56 time-share, 8, 17 transaction, 75

Translation Look-aside Buffer (TLB), 35, 59
```
  
DRAFT as of September 4, 2018 106 https://pdos.csail.mit.edu/6.828/xv6  
  
trap, 40  
  
trap, 43–44, 46, 48, 62 trapret, 24, 26, 44 tvinit, 42  
  
type cast, 33  
  
unlink, 79  
  
user memory, 20 user mode, 18, 40 user space, 7, 19 userinit, 24–26 ustack, 36 V2P_WO, 23 vectors\[i\], 42 virtual address, 20, 100 wait channel, 66  
  
wait, 8–9, 64, 71  
  
wakeup, 46, 56, 66, 68–69 wakeup1, 69  
  
walkpgdir, 32, 35 write, 79, 87 writei, 81, 85 xchg, 54, 57 yield, 62–64 ZOMBIE, 71  
  
DRAFT as of September 4, 2018  
  
107  
  
https://pdos.csail.mit.edu/6.828/xv6  
  