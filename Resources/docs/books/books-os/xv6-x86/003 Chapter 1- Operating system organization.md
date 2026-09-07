**Chapter 1**  
  
**Operating system organization**  
  
A key requirement for an operating system is to support several activities at once. For example, using the system call interface described in chapter 0 a process can start new processes with fork. The operating system must time-share the resources of the computer among these processes. For example, even if there are more processes than there are hardware processors, the operating system must ensure that all of the pro- cesses make progress. The operating system must also arrange for isolation between the processes. That is, if one process has a bug and fails, it shouldn’t affect processes that don’t depend on the failed process. Complete isolation, however, is too strong, since it should be possible for processes to interact; pipelines are an example. Thus an operating system must fulfil three requirements: multiplexing, isolation, and interaction.  
  
This chapter provides an overview of how operating systems are organized to achieve these 3 requirements. It turns out there are many ways to do so, but this text focuses on mainstream designs centered around a monolithic kernel, which is used by many Unix operating systems. This chapter introduces xv6’s design by tracing the cre- ation of the first process when xv6 starts running. In doing so, the text provides a glimpse of the implementation of all major abstractions that xv6 provides, how they interact, and how the three requirements of multiplexing, isolation, and interaction are met. Most of xv6 avoids special-casing the first process, and instead reuses code that xv6 must provide for standard operation. Subsequent chapters will explore each ab- straction in more detail.  
  
Xv6 runs on Intel 80386 or later (‘‘x86’’) processors on a PC platform, and much of its low-level functionality (for example, its process implementation) is x86-specific. This book assumes the reader has done a bit of machine-level programming on some architecture, and will introduce x86-specific ideas as they come up. Appendix A briefly outlines the PC platform.  
  
**Abstracting physical resources**  
  
The first question one might ask when encountering an operating system is why have it at all? That is, one could implement the system calls in Figure 0-2 as a library, with which applications link. In this plan, each application could even have its own li- brary tailored to its needs. Applications could directly interact with hardware re- sources and use those resources in the best way for the application (e.g., to achieve high or predictable performance). Some operating systems for embedded devices or real-time systems are organized in this way.  
  
The downside of this library approach is that, if there is more than one applica-  
  
time-share isolation monolithic kernel  
  
DRAFT as of September 4, 2018 17 https://pdos.csail.mit.edu/6.828/xv6  
  
tion running, the applications must be well-behaved. For example, each application must periodically give up the processor so that other applications can run. Such a co- operative time-sharing scheme may be OK if all applications trust each other and have no bugs. It’s more typical for applications to not trust each other, and to have bugs, so one often wants stronger isolation than a cooperative scheme provides.  
  
To achieve strong isolation it’s helpful to forbid applications from directly access- ing sensitive hardware resources, and instead to abstract the resources into services. For example, applications interact with a file system only through open, read, write , and close system calls, instead of read and writing raw disk sectors. This provides the application with the convenience of pathnames, and it allows the operating system (as the implementor of the interface) to manage the disk.  
  
Similarly, Unix transparently switches hardware processors among processes, sav- ing and restoring register state as necessary, so that applications don’t have to be aware of time sharing. This transparency allows the operating system to share processors even if some applications are in infinite loops.  
  
As another example, Unix processes use exec to build up their memory image, instead of directly interacting with physical memory. This allows the operating system to decide where to place a process in memory; if memory is tight, the operating sys- tem might even store some of a process’s data on disk. Exec also provides users with the convenience of a file system to store executable program images.  
  
Many forms of interaction among Unix processes occur via file descriptors. Not only do file descriptors abstract away many details (e.g. where data in a pipe or file is stored), they also are defined in a way that simplifies interaction. For example, if one application in a pipeline fails, the kernel generates end-of-file for the next process in the pipeline.  
  
As you can see, the system call interface in Figure 0-2 is carefully designed to provide both programmer convenience and the possibility of strong isolation. The Unix interface is not the only way to abstract resources, but it has proven to be a very good one.  
  
**User mode, kernel mode, and system calls**  
  
Strong isolation requires a hard boundary between applications and the operating system. If the application makes a mistake, we don’t want the operating system to fail or other applications to fail. Instead, the operating system should be able to clean up the failed application and continue running other applications. To achieve strong iso- lation, the operating system must arrange that applications cannot modify (or even read) the operating system’s data structures and instructions and that applications can- not access other process’s memory.  
  
Processors provide hardware support for strong isolation. For example, the x86 processor, like many other processors, has two modes in which the processor can exe- cute instructions: kernel mode and user mode. In kernel mode the processor is allowed to execute privileged instructions. For example, reading and writing the disk (or any other I/O device) involves privileged instructions. If an application in user mode at-  
  
kernel mode user mode privileged instructions  
  
DRAFT as of September 4, 2018 18 https://pdos.csail.mit.edu/6.828/xv6  
  
tempts to execute a privileged instruction, then the processor doesn’t execute the in- struction, but switches to kernel mode so that the software in kernel mode can clean up the application, because it did something it shouldn’t be doing. Figure 0-1 in Chap- ter 0 illustrates this organization. An application can execute only user-mode instruc- tions (e.g., adding numbers, etc.) and is said to be running in user space, while the software in kernel mode can also execute privileged instructions and is said to be run- ning in kernel space. The software running in kernel space (or in kernel mode) is called the kernel .  
  
An application that wants to read or write a file on disk must transition to the kernel to do so, because the application itself can not execute I/O instructions. Proces- sors provide a special instruction that switches the processor from user mode to kernel mode and enters the kernel at an entry point specified by the kernel. (The x86 proces- sor provides the int instruction for this purpose.) Once the processor has switched to kernel mode, the kernel can then validate the arguments of the system call, decide whether the application is allowed to perform the requested operation, and then deny it or execute it. It is important that the kernel sets the entry point for transitions to kernel mode; if the application could decide the kernel entry point, a malicious appli- cation could enter the kernel at a point where the validation of arguments etc. is skipped.  
  
**Kernel organization**  
  
A key design question is what part of the operating system should run in kernel mode. One possibility is that the entire operating system resides in the kernel, so that the implementations of all system calls run in kernel mode. This organization is called a monolithic kernel .  
  
In this organization the entire operating system runs with full hardware privilege. This organization is convenient because the OS designer doesn’t have to decide which part of the operating system doesn’t need full hardware privilege. Furthermore, it easy for different parts of the operating system to cooperate. For example, an operating system might have a buffer cache that can be shared both by the file system and the virtual memory system.  
  
A downside of the monolithic organization is that the interfaces between different parts of the operating system are often complex (as we will see in the rest of this text), and therefore it is easy for an operating system developer to make a mistake. In a monolithic kernel, a mistake is fatal, because an error in kernel mode will often result in the kernel to fail. If the kernel fails, the computer stops working, and thus all appli- cations fail too. The computer must reboot to start again.  
  
To reduce the risk of mistakes in the kernel, OS designers can minimize the amount of operating system code that runs in kernel mode, and execute the bulk of the operating system in user mode. This kernel organization is called a microkernel . Figure 1-1 illustrates this microkernel design. In the figure, the file system runs as  
  
a user-level process. OS services running as processes are called servers. To allow ap- plications to interact with the file server, the kernel provides an inter-process commu- nication mechanism to send messages from one user-mode process to another. For  
  
user space kernel space kernel  
  
monolithic kernel microkernel  
  
DRAFT as of September 4, 2018 19 https://pdos.csail.mit.edu/6.828/xv6  
  
microkernel  
  
user space  
  
kernel space  
  
shell  
  
![](media/dbc2fcbbad79f3ba6e44199b388413008d804f29.jpg)  
Send message Microkernel  
  
File server  
  
**Figure 1-1**. A microkernel with a file system server  
  
example, if an application like the shell wants to read or write a file, it sends a message to the file server and waits for a response.  
  
In a microkernel, the kernel interface consists of a few low-level functions for starting applications, sending messages, accessing device hardware, etc. This organiza- tion allows the kernel to be relatively simple, as most of the operating system resides in user-level servers.  
  
Xv6 is implemented as a monolithic kernel, following most Unix operating sys- tems. Thus, in xv6, the kernel interface corresponds to the operating system interface, and the kernel implements the complete operating system. Since xv6 doesn’t provide many services, its kernel is smaller than some microkernels.  
  
**Process overview**  
  
The unit of isolation in xv6 (as in other Unix operating systems) is a process. The process abstraction prevents one process from wrecking or spying on another process’s memory, CPU, file descriptors, etc. It also prevents a process from wrecking the kernel itself, so that a process can’t subvert the kernel’s isolation mechanisms. The kernel must implement the process abstraction with care because a buggy or malicious appli- cation may trick the kernel or hardware in doing something bad (e.g., circumventing enforced isolation). The mechanisms used by the kernel to implement processes in- clude the user/kernel mode flag, address spaces, and time-slicing of threads.  
  
To help enforce isolation, the process abstraction provides the illusion to a pro- gram that it has its own private machine. A process provides a program with what ap- pears to be a private memory system, or address space, which other processes cannot read or write. A process also provides the program with what appears to be its own CPU to execute the program’s instructions.  
  
Xv6 uses page tables (which are implemented by hardware) to give each process its own address space. The x86 page table translates (or ‘‘maps’’) a virtual address (the address that an x86 instruction manipulates) to a physical address (an address that the processor chip sends to main memory).  
  
Xv6 maintains a separate page table for each process that defines that process’s address space. As illustrated in Figure 1-2, an address space includes the process’s user memory starting at virtual address zero. Instructions come first, followed by global variables, then the stack, and finally a ‘‘heap’’ area (for malloc) that the process can ex- pand as needed.  
  
process address space  
  
virtual address physical address user memory  
  
DRAFT as of September 4, 2018 20 https://pdos.csail.mit.edu/6.828/xv6  
  
0xFFFFFFFF  
  
free memory kernel  
  
0x80100000 0x80000000  
  
text and data BIOS  
  
heap user stack  
  
![](media/28ad87e83170c4206044dc1fbe9d9624f3e18edb.jpg)  
user  
  
user text and data  
  
0  
  
**Figure 1-2**. Layout of a virtual address space  
  
Each process’s address space maps the kernel’s instructions and data as well as the user program’s memory. When a process invokes a system call, the system call exe- cutes in the kernel mappings of the process’s address space. This arrangement exists so that the kernel’s system call code can directly refer to user memory. In order to leave plenty of room for user memory, xv6’s address spaces map the kernel at high ad- dresses, starting at 0x80100000 .  
  
The xv6 kernel maintains many pieces of state for each process, which it gathers into a struct proc (2337). A process’s most important pieces of kernel state are its page table, its kernel stack, and its run state. We’ll use the notation p-\>xxx to refer to elements of the proc structure.  
  
Each process has a thread of execution (or thread for short) that executes the pro- cess’s instructions. A thread can be suspended and later resumed. To switch transpar- ently between processes, the kernel suspends the currently running thread and resumes another process’s thread. Much of the state of a thread (local variables, function call return addresses) is stored on the thread’s stacks. Each process has two stacks: a user stack and a kernel stack (p-\>kstack). When the process is executing user instructions, only its user stack is in use, and its kernel stack is empty. When the process enters the kernel (for a system call or interrupt), the kernel code executes on the process’s kernel stack; while a process is in the kernel, its user stack still contains saved data, but isn’t actively used. A process’s thread alternates between actively using its user stack and its kernel stack. The kernel stack is separate (and protected from user code) so that the kernel can execute even if a process has wrecked its user stack.  
  
When a process makes a system call, the processor switches to the kernel stack, raises the hardware privilege level, and starts executing the kernel instructions that im- plement the system call. When the system call completes, the kernel returns to user space: the hardware lowers its privilege level, switches back to the user stack, and re- sumes executing user instructions just after the system call instruction. A process’s thread can ‘‘block’’ in the kernel to wait for I/O, and resume where it left off when the  
  
struct proc+code p-\>xxx+code thread p-\>kstack+code  
  
DRAFT as of September 4, 2018 21 https://pdos.csail.mit.edu/6.828/xv6  
  
0xFFFFFFFF  
  
![](media/01c4f765887863b761c10f278e61ec0181319200.jpg)  
0x80100000 0x80000000  
  
text and data BIOS  
  
Top physical memory  
  
![](media/ba54765fbb537ce61d6874cf79f9e32644d2ed59.jpg)  
4 Mbyte  
  
text and data  
  
![](media/350f6891d361a83d0e150048e1c8349cf56bc182.jpg)  
![](media/a2deace6f51b36d20ff391e08ca18595cc788e79.jpg)  
kernel text and data  
  
0  
  
Virtual address space  
  
BIOS Physical memory  
  
0  
  
**Figure 1-3**. Layout of a virtual address space  
  
I/O has finished.  
  
p-\>state indicates whether the process is allocated, ready to run, running, wait- ing for I/O, or exiting.  
  
p-\>pgdir holds the process’s page table, in the format that the x86 hardware ex- pects. xv6 causes the paging hardware to use a process’s p-\>pgdir when executing that process. A process’s page table also serves as the record of the addresses of the physical pages allocated to store the process’s memory.  
  
**Code: the first address space**  
  
To make the xv6 organization more concrete, we’ll look how the kernel creates the first address space (for itself), how the kernel creates and starts the first process, and how that process performs the first system call. By tracing these operations we see in detail how xv6 provides strong isolation for processes. The first step in providing strong iso- lation is setting up the kernel to run in its own address space.  
  
When a PC powers on, it initializes itself and then loads a boot loader from disk into memory and executes it. Appendix B explains the details. Xv6’s boot loader loads the xv6 kernel from disk and executes it starting at entry (1044). The x86 paging hard- ware is not enabled when the kernel starts; virtual addresses map directly to physical addresses.  
  
The boot loader loads the xv6 kernel into memory at physical address 0x100000 . The reason it doesn’t load the kernel at 0x80100000, where the kernel expects to find its instructions and data, is that there may not be any physical memory at such a high address on a small machine. The reason it places the kernel at 0x100000 rather than 0x0 is because the address range 0xa0000:0x100000 contains I/O devices.  
  
To allow the rest of the kernel to run, entry sets up a page table that maps virtu-  
  
p-\>state+code p-\>pgdir+code boot loader entry+code  
  
DRAFT as of September 4, 2018 22 https://pdos.csail.mit.edu/6.828/xv6  
  
al addresses starting at 0x80000000 (called KERNBASE (0207)) to physical addresses start- ing at 0x0 (see Figure 1-2). Setting up two ranges of virtual addresses that map to the same physical memory range is a common use of page tables, and we will see more examples like this one.  
  
The entry page table is defined in main.c (1306). We look at the details of page ta- bles in Chapter 2, but the short story is that entry 0 maps virtual addresses 0:0x400000 to physical addresses 0:0x400000. This mapping is required as long as entry is executing at low addresses, but will eventually be removed.  
  
Entry 512 maps virtual addresses KERNBASE:KERNBASE+0x400000 to physical ad- dresses 0:0x400000. This entry will be used by the kernel after entry has finished; it maps the high virtual addresses at which the kernel expects to find its instructions and data to the low physical addresses where the boot loader loaded them. This mapping restricts the kernel instructions and data to 4 Mbytes.  
  
Returning to entry, it loads the physical address of entrypgdir into control reg- ister %cr3. The value in %cr3 must be a physical address. It wouldn’t make sense for %cr3 to hold the virtual address of entrypgdir, because the paging hardware doesn’t know how to translate virtual addresses yet; it doesn’t have a page table yet. The sym- bol entrypgdir refers to an address in high memory, and the macro V2P_WO (0213)  
  
subtracts KERNBASE in order to find the physical address. To enable the paging hard- ware, xv6 sets the flag CR0_PG in the control register %cr0.  
  
The processor is still executing instructions at low addresses after paging is en- abled, which works since entrypgdir maps low addresses. If xv6 had omitted entry 0 from entrypgdir, the computer would have crashed when trying to execute the in- struction after the one that enabled paging.  
  
Now entry needs to transfer to the kernel’s C code, and run it in high memory. First it makes the stack pointer, %esp, point to memory to be used as a stack (1058). All symbols have high addresses, including stack, so the stack will still be valid even when the low mappings are removed. Finally entry jumps to main, which is also a high address. The indirect jump is needed because the assembler would otherwise generate a PC-relative direct jump, which would execute the low-memory version of main. Main cannot return, since the there’s no return PC on the stack. Now the kernel is running in high addresses in the function main (1217) .  
  
**Code: creating the first process**  
  
Now we’ll look at how the kernel creates user-level processes and ensures that they are strongly isolated.  
  
After main (1217) initializes several devices and subsystems, it creates the first pro- cess by calling userinit (2520). Userinit’s first action is to call allocproc. The job of allocproc (2473) is to allocate a slot (a struct proc) in the process table and to initialize the parts of the process’s state required for its kernel thread to execute. Al- locproc is called for each new process, while userinit is called only for the very first process. Allocproc scans the proc table for a slot with state UNUSED (2480-2482). When it finds an unused slot, allocproc sets the state to EMBRYO to mark it as used and gives the process a unique pid (2469-2489). Next, it tries to allocate a kernel stack for  
  
KERNBASE+code entry+code entrypgdir+code V2P_WO+code CR0_PG+code main+code main+code main+code allocproc+code EMBRYO+code pid+code  
  
DRAFT as of September 4, 2018 23 https://pdos.csail.mit.edu/6.828/xv6  
  
top of new stack  
  
```cpp
p->tf address forkret will return to

p->context
```
  
esp  
  
...  
  
eip  
  
...  
  
edi  
  
trapret eip  
  
...  
  
edi  
  
```cpp
(empty)

p->kstack
```
  
**Figure 1-4**. A new kernel stack.  
  
the process’s kernel thread. If the memory allocation fails, allocproc changes the state back to UNUSED and returns zero to signal failure.  
  
Now allocproc must set up the new process’s kernel stack. allocproc is written so that it can be used by fork as well as when creating the first process. allocproc sets up the new process with a specially prepared kernel stack and set of kernel regis- ters that cause it to ‘‘return’’ to user space when it first runs. The layout of the pre- pared kernel stack will be as shown in Figure 1-4. allocproc does part of this work by setting up return program counter values that will cause the new process’s kernel thread to first execute in forkret and then in trapret (2507-2512). The kernel thread will start executing with register contents copied from p-\>context. Thus setting p- \>context-\>eip to forkret will cause the kernel thread to execute at the start of forkret (2853). This function will return to whatever address is at the bottom of the stack. The context switch code (3059) sets the stack pointer to point just beyond the end of p-\>context. allocproc places p-\>context on the stack, and puts a pointer to trapret just above it; that is where forkret will return. trapret restores user regis- ters from values stored at the top of the kernel stack and jumps into the process (3324) . This setup is the same for ordinary fork and for creating the first process, though in the latter case the process will start executing at user-space location zero rather than at a return from fork .  
  
As we will see in Chapter 3, the way that control transfers from user software to the kernel is via an interrupt mechanism, which is used by system calls, interrupts, and exceptions. Whenever control transfers into the kernel while a process is running, the hardware and xv6 trap entry code save user registers on the process’s kernel stack. userinit writes values at the top of the new stack that look just like those that would  
  
forkret+code trapret+code p-\>context+code forkret+code trapret+code forkret+code trapret+code userinit+code  
  
DRAFT as of September 4, 2018 24 https://pdos.csail.mit.edu/6.828/xv6  
  
be there if the process had entered the kernel via an interrupt (2533-2539), so that the or- dinary code for returning from the kernel back to the process’s user code will work. These values are a struct trapframe which stores the user registers. Now the new process’s kernel stack is completely prepared as shown in Figure 1-4.  
  
The first process is going to execute a small program (initcode.S; (8400)). The process needs physical memory in which to store this program, the program needs to be copied to that memory, and the process needs a page table that maps user-space addresses to that memory.  
  
userinit calls setupkvm (1818) to create a page table for the process with (at first) mappings only for memory that the kernel uses. We will study this function in detail in Chapter 2, but at a high level setupkvm and userinit create an address space as shown in Figure 1-2.  
  
The initial contents of the first process’s user-space memory are the compiled form of initcode.S; as part of the kernel build process, the linker embeds that binary in the kernel and defines two special symbols, \_binary_initcode_start and \_bina- ry_initcode_size, indicating the location and size of the binary. Userinit copies that binary into the new process’s memory by calling inituvm, which allocates one page of physical memory, maps virtual address zero to that memory, and copies the bi- nary to that page (1886) .  
  
Then userinit sets up the trap frame (0602) with the initial user mode state: the %cs register contains a segment selector for the SEG_UCODE segment running at privi- lege level DPL_USER (i.e., user mode rather than kernel mode), and similarly %ds, %es , and %ss use SEG_UDATA with privilege DPL_USER. The %eflags FL_IF bit is set to al- low hardware interrupts; we will reexamine this in Chapter 3.  
  
The stack pointer %esp is set to the process’s largest valid virtual address, p-\>sz . The instruction pointer is set to the entry point for the initcode, address 0.  
  
The function userinit sets p-\>name to initcode mainly for debugging. Setting p-\>cwd sets the process’s current working directory; we will examine namei in detail in Chapter 6.  
  
Once the process is initialized, userinit marks it available for scheduling by set- ting p-\>state to RUNNABLE .  
  
**Code: Running the first process**  
  
Now that the first process’s state is prepared, it is time to run it. After main calls userinit, mpmain calls scheduler to start running processes (1257). Scheduler (2758)  
  
looks for a process with p-\>state set to RUNNABLE, and there’s only one: initproc. It sets the per-cpu variable proc to the process it found and calls switchuvm to tell the hardware to start using the target process’s page table (1879). Changing page tables while executing in the kernel works because setupkvm causes all processes’ page tables to have identical mappings for kernel code and data. switchuvm also sets up a task state segment SEG_TSS that instructs the hardware to execute system calls and inter- rupts on the process’s kernel stack. We will re-examine the task state segment in Chapter 3.  
  
scheduler now sets p-\>state to RUNNING and calls swtch (3059) to perform a  
  
```cpp
struct

trapframe+code initcode.S+code userinit+code setupkvm+code initcode.S+code _binary_initcode_start _binary_initcode_size+ inituvm+code SEG_UCODE+code DPL_USER+code SEG_UDATA+code DPL_USER+code FL_IF+code userinit+code p->name+code p->cwd+code namei+code userinit+code RUNNABLE+code mpmain+code scheduler+code switchuvm+code setupkvm+code SEG_TSS+code scheduler+code swtch+code
```
  
DRAFT as of September 4, 2018 25 https://pdos.csail.mit.edu/6.828/xv6  
  
```cpp
context switch to the target process’s kernel thread. swtch first saves the current regis- ters. The current context is not a process but rather a special per-cpu scheduler con- text, so scheduler tells swtch to save the current hardware registers in per-cpu stor- age (cpu->scheduler) rather than in any process’s kernel thread context. swtch then loads the saved registers of the target kernel thread (p->context) into the x86 hard- ware registers, including the stack pointer and instruction pointer. We’ll examine swtch in more detail in Chapter 5. The final ret instruction (3078) pops the target process’s %eip from the stack, finishing the context switch. Now the processor is run- ning on the kernel stack of process p .

Allocproc had previously set initproc’s p->context->eip to forkret, so the ret starts executing forkret. On the first invocation (that is this one), forkret (2853)

runs initialization functions that cannot be run from main because they must be run in the context of a regular process with its own kernel stack. Then, forkret returns. Allocproc arranged that the top word on the stack after p->context is popped off would be trapret, so now trapret begins executing, with %esp set to p->tf . Trapret (3324) uses pop instructions to restore registers from the trap frame (0602) just as swtch did with the kernel context: popal restores the general registers, then the popl instructions restore %gs, %fs, %es, and %ds. The addl skips over the two fields trapno and errcode. Finally, the iret instruction pops %cs, %eip, %flags, %esp, and %ss from the stack. The contents of the trap frame have been transferred to the CPU state, so the processor continues at the %eip specified in the trap frame. For init- proc, that means virtual address zero, the first instruction of initcode.S .
```
  
At this point, %eip holds zero and %esp holds 4096. These are virtual addresses in the process’s address space. The processor’s paging hardware translates them into physical addresses. allocuvm has set up the process’s page table so that virtual address zero refers to the physical memory allocated for this process, and set a flag (PTE_U ) that tells the paging hardware to allow user code to access that memory. The fact that userinit (2533) set up the low bits of %cs to run the process’s user code at CPL=3 means that the user code can only use pages with PTE_U set, and cannot modify sensi- tive hardware registers such as %cr3. So the process is constrained to using only its own memory.  
  
**The first system call: exec**  
  
Now that we have seen how the kernel provides strong isolation for processes, let’s look at how a user-level process re-enters the kernel to ask for services that it cannot perform itself.  
  
The first action of initcode.S is to invoke the exec system call. As we saw in Chapter 0, exec replaces the memory and registers of the current process with a new program, but it leaves the file descriptors, process id, and parent process unchanged. Initcode.S (8409) begins by pushing three values on the stack—\$argv, \$init ,  
  
and \$0—and then sets %eax to SYS_exec and executes int T_SYSCALL: it is asking the kernel to run the exec system call. If all goes well, exec never returns: it starts run- ning the program named by \$init, which is a pointer to the NUL-terminated string /init (8422-8424). The other argument is the argv array of command-line arguments;  
  
cpu- \>scheduler+code  
  
swtch+code ret+code forkret+code ret+code forkret+code forkret+code main+code p-\>context+code trapret+code swtch+code popal+code popl+code addl+code iret+code initproc+code initcode.S+code allocuvm+code PTE_U+code userinit+code exec+code SYS_exec+code T_SYSCALL+code exec+code  
  
DRAFT as of September 4, 2018 26 https://pdos.csail.mit.edu/6.828/xv6  
  
the zero at the end of the array marks its end. If the exec fails and does return, init- code loops calling the exit system call, which definitely should not return (8416-8420) . This code manually crafts the first system call to look like an ordinary system call, which we will see in Chapter 3. As before, this setup avoids special-casing the first process (in this case, its first system call), and instead reuses code that xv6 must provide for standard operation.  
  
Chapter 2 will cover the implementation of exec in detail, but at a high level it replaces initcode with the /init binary, loaded out of the file system. Now init- code (8400) is done, and the process will run /init instead. Init (8510) creates a new console device file if needed and then opens it as file descriptors 0, 1, and 2. Then it loops, starting a console shell, handles orphaned zombies until the shell exits, and re- peats. The system is up.  
  
**Real world**  
  
In the real world, one can find both monolithic kernels and microkernels. Many Unix kernels are monolithic. For example, Linux has a monolithic kernel, although some OS functions run as user-level servers (e.g., the windowing system). Kernels such as L4, Minix, QNX are organized as a microkernel with servers, and have seen wide deployment in embedded settings.  
  
Most operating systems have adopted the process concept, and most processes look similar to xv6’s. A real operating system would find free proc structures with an explicit free list in constant time instead of the linear-time search in allocproc; xv6 uses the linear scan (the first of many) for simplicity.  
  
**Exercises**  
  
1. Set a breakpoint at swtch. Single step with gdb’s stepi through the ret to forkret , then use gdb’s finish to proceed to trapret, then stepi until you get to initcode at virtual address zero.  
  
2. KERNBASE limits the amount of memory a single process can use, which might be irritating on a machine with a full 4 GB of RAM. Would raising KERNBASE allow a process to use more memory?  
  
exit+code /init+code initcode+code /init+code  
  
DRAFT as of September 4, 2018 27 https://pdos.csail.mit.edu/6.828/xv6  
  