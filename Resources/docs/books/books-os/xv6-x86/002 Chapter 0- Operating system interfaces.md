**Chapter 0**  
  
**Operating system interfaces**  
  
The job of an operating system is to share a computer among multiple programs and to provide a more useful set of services than the hardware alone supports. The operating system manages and abstracts the low-level hardware, so that, for example, a word processor need not concern itself with which type of disk hardware is being used. It also shares the hardware among multiple programs so that they run (or ap- pear to run) at the same time. Finally, operating systems provide controlled ways for programs to interact, so that they can share data or work together.  
  
An operating system provides services to user programs through an interface. Designing a good interface turns out to be difficult. On the one hand, we would like the interface to be simple and narrow because that makes it easier to get the imple- mentation right. On the other hand, we may be tempted to offer many sophisticated features to applications. The trick in resolving this tension is to design interfaces that rely on a few mechanisms that can be combined to provide much generality.  
  
This book uses a single operating system as a concrete example to illustrate oper- ating system concepts. That operating system, xv6, provides the basic interfaces intro- duced by Ken Thompson and Dennis Ritchie’s Unix operating system, as well as mim- icking Unix’s internal design. Unix provides a narrow interface whose mechanisms combine well, offering a surprising degree of generality. This interface has been so successful that modern operating systems—BSD, Linux, Mac OS X, Solaris, and even, to a lesser extent, Microsoft Windows—have Unix-like interfaces. Understanding xv6 is a good start toward understanding any of these systems and many others.  
  
As shown in Figure 0-1, xv6 takes the traditional form of a kernel, a special pro- gram that provides services to running programs. Each running program, called a pro- cess, has memory containing instructions, data, and a stack. The instructions imple- ment the program’s computation. The data are the variables on which the computa- tion acts. The stack organizes the program’s procedure calls.  
  
When a process needs to invoke a kernel service, it invokes a procedure call in the operating system interface. Such a procedure is called a system call. The system call enters the kernel; the kernel performs the service and returns. Thus a process al- ternates between executing in user space and kernel space .  
  
The kernel uses the CPU’s hardware protection mechanisms to ensure that each process executing in user space can access only its own memory. The kernel executes with the hardware privileges required to implement these protections; user programs execute without those privileges. When a user program invokes a system call, the hardware raises the privilege level and starts executing a pre-arranged function in the kernel.  
  
The collection of system calls that a kernel provides is the interface that user pro- grams see. The xv6 kernel provides a subset of the services and system calls that Unix kernels traditionally offer. Figure 0-2 lists all of xv6’s system calls.  
  
interface design kernel  
  
process system call user space kernel space  
  
DRAFT as of September 4, 2018 7 https://pdos.csail.mit.edu/6.828/xv6  
  
process  
  
user space  
  
kernel space  
  
shell  
  
![](media/3b9adb02e35fae3a7893e4343e471dbde1da7b98.jpg)  
system call  
  
Kernel  
  
cat  
  
**Figure 0-1**. A kernel and two user processes.  
  
The rest of this chapter outlines xv6’s services—processes, memory, file descrip- tors, pipes, and file system—and illustrates them with code snippets and discussions of how the shell, which is the primary user interface to traditional Unix-like systems, uses them. The shell’s use of system calls illustrates how carefully they have been designed. The shell is an ordinary program that reads commands from the user and exe- cutes them. The fact that the shell is a user program, not part of the kernel, illustrates the power of the system call interface: there is nothing special about the shell. It also means that the shell is easy to replace; as a result, modern Unix systems have a variety of shells to choose from, each with its own user interface and scripting features. The xv6 shell is a simple implementation of the essence of the Unix Bourne shell. Its im- plementation can be found at line (8550) .  
  
**Processes and memory**  
  
An xv6 process consists of user-space memory (instructions, data, and stack) and per-process state private to the kernel. Xv6 can time-share processes: it transparently switches the available CPUs among the set of processes waiting to execute. When a process is not executing, xv6 saves its CPU registers, restoring them when it next runs the process. The kernel associates a process identifier, or pid, with each process.  
  
A process may create a new process using the fork system call. Fork creates a new process, called the child process, with exactly the same memory contents as the calling process, called the parent process. Fork returns in both the parent and the child. In the parent, fork returns the child’s pid; in the child, it returns zero. For example, consider the following program fragment:  
  
```cpp
int pid = fork();

if(pid > 0){

printf("parent: child=%d\n", pid);

pid = wait();

printf("child %d is done\n", pid);

} else if(pid == 0){ printf("child: exiting\n"); exit();

} else {

printf("fork error\n");

}
```
  
The exit system call causes the calling process to stop executing and to release re- sources such as memory and open files. The wait system call returns the pid of an  
  
shell time-share pid+code fork+code child process parent process fork+code exit+code wait+code  
  
DRAFT as of September 4, 2018 8 https://pdos.csail.mit.edu/6.828/xv6  
  
**System** **call Description**  
  
```cpp
fork() Create a process

exit() Terminate the current process

wait() Wait for a child process to exit

kill(pid) Terminate process pid

getpid() Return the current process’s pid

sleep(n) Sleep for n clock ticks

exec(filename, *argv) Load a file and execute it

sbrk(n) Grow process’s memory by n bytes

open(filename, flags) Open a file; the flags indicate read/write
```
  
read(fd, buf, n) Read n bytes from an open file into buf  
  
```cpp
write(fd, buf, n) Write n bytes to an open file

close(fd) Release open file fd

dup(fd) Duplicate fd

pipe(p) Create a pipe and return fd’s in p

chdir(dirname) Change the current directory

mkdir(dirname) Create a new directory

mknod(name, major, minor) Create a device file

fstat(fd) Return info about an open file

link(f1, f2) Create another name (f2) for the file f1

unlink(filename) Remove a file
```
  
**Figure 0-2**. Xv6 system calls  
  
exited child of the current process; if none of the caller’s children has exited, wait waits for one to do so. In the example, the output lines  
  
parent: child=1234  
  
child: exiting  
  
might come out in either order, depending on whether the parent or child gets to its printf call first. After the child exits the parent’s wait returns, causing the parent to print  
  
parent: child 1234 is done  
  
Although the child has the same memory contents as the parent initially, the parent and child are executing with different memory and different registers: changing a vari- able in one does not affect the other. For example, when the return value of wait is stored into pid in the parent process, it doesn’t change the variable pid in the child. The value of pid in the child will still be zero.  
  
The exec system call replaces the calling process’s memory with a new memory image loaded from a file stored in the file system. The file must have a particular for- mat, which specifies which part of the file holds instructions, which part is data, at which instruction to start, etc. xv6 uses the ELF format, which Chapter 2 discusses in more detail. When exec succeeds, it does not return to the calling program; instead, the instructions loaded from the file start executing at the entry point declared in the ELF header. Exec takes two arguments: the name of the file containing the executable and an array of string arguments. For example:  
  
wait+code printf+code wait+code exec+code exec+code  
  
DRAFT as of September 4, 2018 9 https://pdos.csail.mit.edu/6.828/xv6  
  
char \*argv\[3\]; argv\[0\] = "echo"; argv\[1\] = "hello"; argv\[2\] = 0; exec("/bin/echo", argv); printf("exec error\n");  
  
This fragment replaces the calling program with an instance of the program /bin/echo running with the argument list echo hello. Most programs ignore the first argument, which is conventionally the name of the program.  
  
The xv6 shell uses the above calls to run programs on behalf of users. The main structure of the shell is simple; see main (8701). The main loop reads a line of input from the user with getcmd. Then it calls fork, which creates a copy of the shell pro- cess. The parent calls wait, while the child runs the command. For example, if the user had typed ‘‘echo hello’’ to the shell, runcmd would have been called with ‘‘ echo hello’’ as the argument. runcmd (8606) runs the actual command. For ‘‘echo hello’’, it would call exec (8626). If exec succeeds then the child will execute instructions from echo instead of runcmd. At some point echo will call exit, which will cause the par- ent to return from wait in main (8701). You might wonder why fork and exec are not combined in a single call; we will see later that separate calls for creating a process and loading a program is a clever design.  
  
Xv6 allocates most user-space memory implicitly: fork allocates the memory re- quired for the child’s copy of the parent’s memory, and exec allocates enough memory to hold the executable file. A process that needs more memory at run-time (perhaps for malloc) can call sbrk(n) to grow its data memory by n bytes; sbrk returns the location of the new memory.  
  
Xv6 does not provide a notion of users or of protecting one user from another; in Unix terms, all xv6 processes run as root.  
  
**I/O and File descriptors**  
  
A file descriptor is a small integer representing a kernel-managed object that a process may read from or write to. A process may obtain a file descriptor by opening a file, directory, or device, or by creating a pipe, or by duplicating an existing descrip- tor. For simplicity we’ll often refer to the object a file descriptor refers to as a ‘‘file’’; the file descriptor interface abstracts away the differences between files, pipes, and de- vices, making them all look like streams of bytes.  
  
Internally, the xv6 kernel uses the file descriptor as an index into a per-process ta- ble, so that every process has a private space of file descriptors starting at zero. By convention, a process reads from file descriptor 0 (standard input), writes output to file descriptor 1 (standard output), and writes error messages to file descriptor 2 (standard error). As we will see, the shell exploits the convention to implement I/O redirection and pipelines. The shell ensures that it always has three file descriptors open (8707) , which are by default file descriptors for the console.  
  
The read and write system calls read bytes from and write bytes to open files named by file descriptors. The call read(fd, buf, n) reads at most n bytes from the  
  
getcmd+code fork+code exec+code fork+code exec+code malloc+code sbrk+code  
  
file descriptor  
  
DRAFT as of September 4, 2018 10 https://pdos.csail.mit.edu/6.828/xv6  
  
file descriptor fd, copies them into buf, and returns the number of bytes read. Each file descriptor that refers to a file has an offset associated with it. Read reads data from the current file offset and then advances that offset by the number of bytes read: a subsequent read will return the bytes following the ones returned by the first read . When there are no more bytes to read, read returns zero to signal the end of the file. The call write(fd, buf, n) writes n bytes from buf to the file descriptor fd and returns the number of bytes written. Fewer than n bytes are written only when an er- ror occurs. Like read, write writes data at the current file offset and then advances that offset by the number of bytes written: each write picks up where the previous one left off.  
  
The following program fragment (which forms the essence of cat) copies data from its standard input to its standard output. If an error occurs, it writes a message to the standard error.  
  
```cpp
char buf[512]; int n; for(;;){

n = read(0, buf, sizeof buf);

if(n == 0) break; if(n < 0){

fprintf(2, "read error\n");

exit();

}

if(write(1, buf, n) != n){ fprintf(2, "write error\n"); exit();

}

}
```
  
The important thing to note in the code fragment is that cat doesn’t know whether it is reading from a file, console, or a pipe. Similarly cat doesn’t know whether it is printing to a console, a file, or whatever. The use of file descriptors and the conven- tion that file descriptor 0 is input and file descriptor 1 is output allows a simple imple- mentation of cat .  
  
The close system call releases a file descriptor, making it free for reuse by a fu- ture open, pipe, or dup system call (see below). A newly allocated file descriptor is al- ways the lowest-numbered unused descriptor of the current process.  
  
File descriptors and fork interact to make I/O redirection easy to implement. Fork copies the parent’s file descriptor table along with its memory, so that the child starts with exactly the same open files as the parent. The system call exec replaces the calling process’s memory but preserves its file table. This behavior allows the shell to implement I/O redirection by forking, reopening chosen file descriptors, and then exec- ing the new program. Here is a simplified version of the code a shell runs for the command cat \< input.txt :  
  
fork+code exec+code  
  
DRAFT as of September 4, 2018 11 https://pdos.csail.mit.edu/6.828/xv6  
  
```cpp
char *argv[2]; argv[0] = "cat"; argv[1] = 0; if(fork() == 0) { close(0);

open("input.txt", O_RDONLY);

exec("cat", argv);

}
```
  
After the child closes file descriptor 0, open is guaranteed to use that file descriptor for the newly opened input.txt: 0 will be the smallest available file descriptor. Cat then executes with file descriptor 0 (standard input) referring to input.txt .  
  
The code for I/O redirection in the xv6 shell works in exactly this way (8630). Re- call that at this point in the code the shell has already forked the child shell and that runcmd will call exec to load the new program. Now it should be clear why it is a good idea that fork and exec are separate calls. Because if they are separate, the shell can fork a child, use open, close, dup in the child to change the standard input and output file descriptors, and then exec. No changes to the program being exec-ed ( cat in our example) are required. If fork and exec were combined into a single system call, some other (probably more complex) scheme would be required for the shell to redirect standard input and output, or the program itself would have to understand how to redirect I/O.  
  
Although fork copies the file descriptor table, each underlying file offset is shared between parent and child. Consider this example:  
  
```cpp
if(fork() == 0) { write(1, "hello ", 6); exit();

} else {

wait();

write(1, "world\n", 6);

}
```
  
At the end of this fragment, the file attached to file descriptor 1 will contain the data hello world. The write in the parent (which, thanks to wait, runs only after the child is done) picks up where the child’s write left off. This behavior helps produce sequential output from sequences of shell commands, like (echo hello; echo world) \>output.txt .  
  
The dup system call duplicates an existing file descriptor, returning a new one that refers to the same underlying I/O object. Both file descriptors share an offset, just as the file descriptors duplicated by fork do. This is another way to write hello world into a file:  
  
```cpp
fd = dup(1);

write(1, "hello ", 6);

write(fd, "world\n", 6);
```
  
Two file descriptors share an offset if they were derived from the same original file descriptor by a sequence of fork and dup calls. Otherwise file descriptors do not share offsets, even if they resulted from open calls for the same file. Dup allows shells  
  
DRAFT as of September 4, 2018 12 https://pdos.csail.mit.edu/6.828/xv6  
  
to implement commands like this: ls existing-file non-existing-file \> tmp1 2\>&1. The 2\>&1 tells the shell to give the command a file descriptor 2 that is a dupli- cate of descriptor 1. Both the name of the existing file and the error message for the non-existing file will show up in the file tmp1. The xv6 shell doesn’t support I/O redi- rection for the error file descriptor, but now you know how to implement it.  
  
File descriptors are a powerful abstraction, because they hide the details of what they are connected to: a process writing to file descriptor 1 may be writing to a file, to a device like the console, or to a pipe.  
  
**Pipes**  
  
A pipe is a small kernel buffer exposed to processes as a pair of file descriptors, one for reading and one for writing. Writing data to one end of the pipe makes that data available for reading from the other end of the pipe. Pipes provide a way for processes to communicate.  
  
The following example code runs the program wc with standard input connected to the read end of a pipe.  
  
```cpp
int p[2];

char *argv[2]; argv[0] = "wc"; argv[1] = 0; pipe(p);

if(fork() == 0) { close(0); dup(p[0]); close(p[0]); close(p[1]); exec("/bin/wc", argv); } else {

close(p[0]);

write(p[1], "hello world\n", 12);

close(p[1]);

}
```
  
The program calls pipe, which creates a new pipe and records the read and write file descriptors in the array p. After fork, both parent and child have file descriptors refer- ring to the pipe. The child dups the read end onto file descriptor 0, closes the file de- scriptors in p, and execs wc. When wc reads from its standard input, it reads from the pipe. The parent closes the read side of the pipe, writes to the pipe, and then closes the write side.  
  
If no data is available, a read on a pipe waits for either data to be written or all file descriptors referring to the write end to be closed; in the latter case, read will re- turn 0, just as if the end of a data file had been reached. The fact that read blocks until it is impossible for new data to arrive is one reason that it’s important for the child to close the write end of the pipe before executing wc above: if one of wc’s file descriptors referred to the write end of the pipe, wc would never see end-of-file.  
  
pipe  
  
DRAFT as of September 4, 2018 13 https://pdos.csail.mit.edu/6.828/xv6  
  
The xv6 shell implements pipelines such as grep fork sh.c \| wc -l in a man- ner similar to the above code (8650). The child process creates a pipe to connect the left end of the pipeline with the right end. Then it calls fork and runcmd for the left end of the pipeline and fork and runcmd for the right end, and waits for both to fin- ish. The right end of the pipeline may be a command that itself includes a pipe (e.g., a \| b \| c), which itself forks two new child processes (one for b and one for c). Thus, the shell may create a tree of processes. The leaves of this tree are commands and the interior nodes are processes that wait until the left and right children complete. In principle, you could have the interior nodes run the left end of a pipeline, but doing so correctly would complicate the implementation.  
  
Pipes may seem no more powerful than temporary files: the pipeline  
  
echo hello world \| wc  
  
could be implemented without pipes as  
  
echo hello world \>/tmp/xyz; wc \</tmp/xyz  
  
Pipes have at least four advantages over temporary files in this situation. First, pipes automatically clean themselves up; with the file redirection, a shell would have to be careful to remove /tmp/xyz when done. Second, pipes can pass arbitrarily long streams of data, while file redirection requires enough free space on disk to store all the data. Third, pipes allow for parallel execution of pipeline stages, while the file ap- proach requires the first program to finish before the second starts. Fourth, if you are implementing inter-process communication, pipes’ blocking reads and writes are more efficient than the non-blocking semantics of files.  
  
**File system**  
  
The xv6 file system provides data files, which are uninterpreted byte arrays, and directories, which contain named references to data files and other directories. The di- rectories form a tree, starting at a special directory called the root. A path like /a/b/c refers to the file or directory named c inside the directory named b inside the directo- ry named a in the root directory /. Paths that don’t begin with / are evaluated relative to the calling process’s current directory, which can be changed with the chdir system call. Both these code fragments open the same file (assuming all the directories in- volved exist):  
  
```cpp
chdir("/a");

chdir("b");

open("c", O_RDONLY);

open("/a/b/c", O_RDONLY);
```
  
The first fragment changes the process’s current directory to /a/b; the second neither refers to nor changes the process’s current directory.  
  
There are multiple system calls to create a new file or directory: mkdir creates a new directory, open with the O_CREATE flag creates a new data file, and mknod creates a new device file. This example illustrates all three:  
  
root path  
  
current directory  
  
DRAFT as of September 4, 2018 14 https://pdos.csail.mit.edu/6.828/xv6  
  
```cpp
mkdir("/dir");

fd = open("/dir/file", O_CREATE|O_WRONLY);

close(fd);

mknod("/console", 1, 1);
```
  
Mknod creates a file in the file system, but the file has no contents. Instead, the file’s metadata marks it as a device file and records the major and minor device numbers (the two arguments to mknod), which uniquely identify a kernel device. When a pro- cess later opens the file, the kernel diverts read and write system calls to the kernel device implementation instead of passing them to the file system.  
  
fstat retrieves information about the object a file descriptor refers to. It fills in a struct stat, defined in stat.h as:  
  
```cpp
#define T_DIR 1 // Directory #define T_FILE 2 // File #define T_DEV 3 // Device struct stat {

short type; // Type of file

int dev; // File system’s disk device

uint ino; // Inode number

short nlink; // Number of links to file

uint size; // Size of file in bytes

};
```
  
A file’s name is distinct from the file itself; the same underlying file, called an in- ode, can have multiple names, called links. The link system call creates another file system name referring to the same inode as an existing file. This fragment creates a new file named both a and b .  
  
```cpp
open("a", O_CREATE|O_WRONLY);

link("a", "b");
```
  
Reading from or writing to a is the same as reading from or writing to b. Each inode is identified by a unique inode number. After the code sequence above, it is possible to determine that a and b refer to the same underlying contents by inspecting the result of fstat: both will return the same inode number (ino), and the nlink count will be set to 2.  
  
The unlink system call removes a name from the file system. The file’s inode and the disk space holding its content are only freed when the file’s link count is zero and no file descriptors refer to it. Thus adding  
  
unlink("a");  
  
to the last code sequence leaves the inode and file content accessible as b. Further- more,  
  
```cpp
fd = open("/tmp/xyz", O_CREATE|O_RDWR);

unlink("/tmp/xyz");
```
  
is an idiomatic way to create a temporary inode that will be cleaned up when the pro- cess closes fd or exits.  
  
Shell commands for file system operations are implemented as user-level pro- grams such as mkdir, ln, rm, etc. This design allows anyone to extend the shell with  
  
inode links  
  
DRAFT as of September 4, 2018 15 https://pdos.csail.mit.edu/6.828/xv6  
  
new user commands by just adding a new user-level program. In hindsight this plan seems obvious, but other systems designed at the time of Unix often built such com- mands into the shell (and built the shell into the kernel).  
  
One exception is cd, which is built into the shell (8716). cd must change the cur- rent working directory of the shell itself. If cd were run as a regular command, then the shell would fork a child process, the child process would run cd, and cd would change the child’s working directory. The parent’s (i.e., the shell’s) working directory would not change.  
  
**Real world**  
  
Unix’s combination of the ‘‘standard’’ file descriptors, pipes, and convenient shell syntax for operations on them was a major advance in writing general-purpose reusable programs. The idea sparked a whole culture of ‘‘software tools’’ that was re- sponsible for much of Unix’s power and popularity, and the shell was the first so-called ‘‘scripting language.’’ The Unix system call interface persists today in systems like BSD, Linux, and Mac OS X.  
  
The Unix system call interface has been standardized through the Portable Oper- ating System Interface (POSIX) standard. Xv6 is not POSIX compliant. It misses sys- tem calls (including basic ones such as lseek), it implements systems calls only par- tially, etc. Our main goals for xv6 are simplicity and clarity while providing a simple UNIX-like system-call interface. Several people have extended xv6 with a few more basic system calls and a simple C library so that they can run basic Unix programs. Modern kernels, however, provide many more system calls, and many more kinds of kernel services, than xv6. For example, they support networking, windowing systems, user-level threads, drivers for many devices, and so on. Modern kernels evolve contin- uously and rapidly, and offer many features beyond POSIX.  
  
For the most part, modern Unix-derived operating systems have not followed the early Unix model of exposing devices as special files, like the console device file dis- cussed above. The authors of Unix went on to build Plan 9, which applied the ‘‘re- sources are files’’ concept to modern facilities, representing networks, graphics, and oth- er resources as files or file trees.  
  
The file system abstraction has been a powerful idea. Even so, there are other models for operating system interfaces. Multics, a predecessor of Unix, abstracted file storage in a way that made it look like memory, producing a very different flavor of interface. The complexity of the Multics design had a direct influence on the designers of Unix, who tried to build something simpler.  
  
This book examines how xv6 implements its Unix-like interface, but the ideas and concepts apply to more than just Unix. Any operating system must multiplex process- es onto the underlying hardware, isolate processes from each other, and provide mech- anisms for controlled inter-process communication. After studying xv6, you should be able to look at other, more complex operating systems and see the concepts underlying xv6 in those systems as well.  
  
DRAFT as of September 4, 2018 16 https://pdos.csail.mit.edu/6.828/xv6  
  