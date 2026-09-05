![](/tmp/audit/iter1/epubregen/system-programming-in-linux/media/index-118_1.jpg)

2 FUNDAMENTALS OF SYSTEM

PROGRAMMING

The first chapter explained how system programs differ from the typical programs that you write in an introductory software development

course. In this chapter, we turn our attention to the core concepts that you need to understand, not just for writing programs in general but for writing system programs. I’ll cover several basic principles of

programming in a Unix environment as well as those specifically related to system programming. In addition, I’ll explain how to solve certain

problems that are common to all projects, such as handling errors,

parsing and checking the command line, and obtaining environment

strings.

We’ll start with the topics related to general programming and then

move on to the fundamentals of system programming, including system

calls, the relationship between system calls and libraries, handling

system call and library function errors, and making your programs

portable.

Whereas ordinary programs typically interact only with a user and

the user’s files, system programs usually interact with many different types of system resources. Writing them requires a deeper

understanding of the system interfaces to these resources as well as their structure and purpose.

For example, if your program has to acquire data from a shared resource, such as a file that another process may have already opened, you’ll be better equipped to write it if you know what happens when

files are opened, how Linux manages open files, and how processes

interact with them. If your program has to control a different type of shared resource, such as a terminal window, you’ll need to understand

how terminals work.

A completely different problem is how to design a program that

might get a delivery of data not when it asked for it, but at some later, unpredictable time. This is an example of asynchronous I/O, which we

explore in Chapter 17. Similarly, a process may need to pause its execution until some other process has performed some other task, such as when a program plays a game of chess against another program.

Neither program is allowed to make a move until the other has finished its turn. Writing these types of programs requires familiarity with the system resources for process synchronization.

Object Libraries

Most likely, almost every program you’ve written has made calls to

functions you didn’t write but that are part of some library installed on your system. The functions that you call to read from or print to the

screen are contained in a library, most likely a standard library, such as the C Standard Library (for example, printf()) or the C++ Input/Output Library based on iostreams (for example, the insertion operator of the ostream cout object). You may not have thought much about libraries

before, but they play a key role in programming.

When you’ve been writing programs for a while, you might realize

that you keep writing certain functions over and over again for different projects. To avoid rewriting them each time, perhaps you copy them

from one directory to another, possibly tweaking them a bit depending

on how you plan to reuse them.

Suppose you discover while working on your latest project that one

of the functions you’re reusing in this way has a bug. You can fix it in the current copy, but then you’ll have to find all of the other projects that

use that function and fix the bug in them as well. It’s not a very efficient organizing principle.

Wouldn’t it be better if you could create a repository of those

frequently used functions in such a way that each new project could just link to it? Although such a repository could be a collection of source code files, it would be even better if it were a bundle of *object modules*, code that’s already compiled and ready to link into a program.

One advantage of an object code bundle instead of a source code

bundle is that you don’t have to compile it every time. Also, if you plan on sharing your work with others, you could distribute the object code and not worry that it might be modified, unintentionally or otherwise, or possibly broken. Those issues are possible if you distribute just the source code. If you did distribute the object code, you’d most likely

need to distribute a header file that contained all declarations of the functions and other symbols contained in the object code.

In Unix systems, doing so isn’t just possible, it’s also relatively easy.

Unix has tools that let you create your own libraries and tools that can view and modify libraries. Appendix A contains detailed instructions on how to create libraries in Unix.

An *object library*, also called a *software library*, is a file that bundles together, in a structured way, the compiled object code from multiple

functions so that programs can call them easily. Libraries aren’t stand-alone executables; they don’t have a main() function, and you can’t run them. They contain function implementations and sometimes type

definitions and constants needed by those functions or by code that calls them. Figure 2-1 depicts a hypothetical library named *libsnw.a*.

![](/tmp/audit/iter1/epubregen/system-programming-in-linux/media/index-121_1.jpg)

*Figure 2-1: A small object library with three modules and an index that serves as a table of* *contents*

The index in Figure 2-1 is essentially a look-up table that contains the addresses relative to the start of the file of all symbols defined in the library, which makes those symbols easy to find.

*System Libraries*

System calls are usually very low-level primitives. They do very simple tasks because the Unix operating system was designed to keep the

kernel as small as possible. For the same reason, the kernel typically doesn’t provide many routines that do similar things. For example, the kernel has a single function to perform almost all read operations, and when it reads from storage devices such as disks, it reads large blocks of data from a specified device to specified system buffers. It doesn’t have a different system call to read a character at a time, nor one that reads formatted input, both of which are useful functions to have. In short, just a single kernel function performs almost all input operations!

To compensate for the kernel’s simplicity, Unix’s designers

augmented the programming interface with an extensive set of higher-

level routines that are kept in libraries. These routines provide a much richer set of primitives for programming in Unix. Many library

functions ultimately make system calls to the kernel, but some don’t

because they don’t need any kernel services. We say that these functions operate entirely *in user space*, meaning that they never need kernel services.

Unix systems also contain libraries for various specialized tasks, such as asynchronous input and output, sharing memory, terminal control,

login and logout management, and so on. Using any of these libraries

requires that the library’s header file be included in the code with the appropriate \#include directive (for example, \#include \<termios.h\>) and, sometimes, that the library be linked explicitly because it isn’t in a standard place. Volume 3 of the Unix Manual Pages contains man pages

for all functions that are part of libraries.

*Static and Shared Libraries*

Unix systems support two kinds of libraries: static and shared. A *static* *library*, short for “statically linked library,” is a library whose code can be linked to the program statically, after the program is compiled, to create the program executable file. In other words, the linker copies the library functions referenced by the program out of the library and inserts them into the program executable, after which it resolves all unresolved

symbols to enable jumps into and out of those functions. Static libraries in Unix have filenames that end in *.a*, such as *libm.a* and *libc.a*. The *.a* suffix is a reminder that these libraries used to be called *archives*.

In contrast, a *shared library* is a library whose object code is not copied into the executable, but is instead linked to the program at

runtime. *Runtime* is the interval of time during which the program is actually running. Because the code in these libraries is linked at runtime, they’re also called *dynamic libraries* or *dynamical y linked libraries*.

NOTE

*The fact that a shared library is also cal ed a dynamical y linked library* *doesn’t imply that they’re the same as what Microsoft cal s a* DLL *.*

*While DLL is short for “dynamical y linked library” also, DLLs are* *different from Unix shared libraries. I’l use the term* shared library *so* *as not to cause any confusion.*

With shared libraries, calls to functions or references to other

symbols in the library are linked only when the program actually

executes the calls or accesses the symbols for the first time. Shared

libraries have names ending in *.so*, possibly followed by a numeric suffix of the form *.\<number\>* , such as *libc.so.6*, where the number refers to a specific version. The *.so* suffix is short for “shared object.”

Static linking, which was the original form of linking used in most

operating systems, including Unix, resolves references to externally

defined symbols such as functions by copying the library code directly into the executable file when the executable file is built. The *linkage* *editor*, also called the *link editor* or simply the *linker*, performs static linking. The term *linker* is a bit ambiguous, so I avoid using it. The ld program is the static linker in Linux.

The primary reason to use static linking, perhaps now the only

reason, is that statically linked executables are self-contained and can run reliably on multiple platforms. For example, a program might use a particular version of a graphical toolkit such as GTK that may not be

present on all systems. If the toolkit’s libraries are statically linked into the executable, the executable can run on other systems with the same

machine architecture without requiring that the users on those systems install the specific library files.

When a library is dynamically linked to a program, the linkage

editor inserts records into the program for symbols from the library to indicate that these symbols will be resolved when they are first reached during the program’s execution. When the program is loaded into

memory, the dynamic linker checks whether that library is already in

memory and, if not, finds a place in memory for it and loads it. As the program executes, each time a new symbol is reached, the dynamic

linker links it to the library. Programs can experience slightly longer running times with dynamic linking, because whenever an unresolved

symbol is found and must be resolved, there’s a bit of overhead in locating the library and linking to it.

Linux systems have two dynamic linkers: ld.so and ld-linux.so. The

former links and loads the old-style executable format known as *a.out* binaries, and the latter links and loads executables in the modern

Executable and Linking Format (ELF). ELF is a standard format for

executable files, object files, and libraries. It replaces the older *a.out* format and the Common Object File Format (COFF), which was

created to replace *a.out*. ELF was developed by UNIX System

Laboratories and has been adopted by almost all Unix vendors.

*The Advantages of Shared Libraries*

Shared libraries have several advantages over static ones. One is that because the executable program file doesn’t contain the code of the

libraries that must be linked to it, the executable file is smaller. Its reduced size means that loading into memory is faster and it uses less space on disk as well. Shared libraries also result in more efficient use of memory. Instead of multiple copies of a library being physically

incorporated into multiple programs, a single memory-resident copy of

the library is linked to each program, reducing the amount of memory

in use. Shared libraries are designed so that when processes execute

their code, it isn’t modified.

Another advantage of linking to shared libraries is that when a

library is updated, the programs that link to it don’t need to be modified or recompiled, provided that the library interfaces aren’t changed by the update. For example, if bugs are discovered and fixed in these libraries, all that’s necessary is to obtain the modified libraries and install them. In contrast, if libraries are statically linked, all programs that use them would need to be recompiled.

Still other advantages are related to security issues. Hackers often try to attack applications through knowledge of specific addresses in the

executable code. Methods of deterring such types of attacks involve

randomizing the locations of various relocatable segments in the code.

With statically linked executables, only the stack and heap address can be randomized; all instructions always have a fixed address when the

executable is run. With dynamically linked executables, the kernel has the ability to load the libraries at arbitrary addresses, independent of each other, so that library code can have different addresses in each run, which makes such attacks much harder.

*Commands to Query a Library’s Contents*

We have a choice of commands for seeing what a library file contains.

For static libraries, we can use the ar command, which can print a wide range of information. In the simplest case, we can print out a table of contents with its t option. We don’t need a hyphen before the t because technically it’s not an option but an *operation code*. For example, to see the objects in the C++ standard library, you can enter: \$ **ar t**

**/lib/gcc/x86_64-linux-gnu/11/libstdc++.a** compatibility.o *--snip-*

*-* array_type_info.o atexit_arm.o atexit_thread.o atomicity.o bad_alloc.o

*--snip--*

The path to *libstdc++.a* may be different on your system. You can also use the objdump command to view executable program files and shared

libraries. The -a option prints the index with information about the

original object files: \$ **objdump -a libsnw.a** In archive libsnw.a: sort.o: file format elf32-i386 rw-r--r-- 1220/400 2032 Apr 23 21:56 2007 sort.o cardinal.o: file format elf32-i386 rw-r--r-- 1220/400 1580 Apr 23 21:56

2007 cardinal.o bsearch.o: file format elf32-i386 rw-r--r-- 1220/400

1784 Apr 23 23:13 2007 bsearch.o

The -t option limits output to static symbols: \$ **objdump -t libsnw.a** In archive libsnw.a: sort.o: file format elf32-i386 SYMBOL TABLE:

00000000 l df \*ABS\* 00000000 sort.cpp 00000000 l d .text 00000000

.text 00000000 l d .data 00000000 .data 00000000 l d .bss 00000000 .bss 00000000 l d .gcc_except_table 00000000 .gcc_except_table 00000000 l

d .gnu.linkonce.t.\_ZStgtIcSt11char_traitsIcESaIcEEbRKSbIT. .

00000000 l d .eh_frame 00000000 .eh_frame 00000000 l d .note.GNU-

stack 00000000 .note.GNU-stack *--snip--*

The man page for objdump explains how to read its output.

For shared libraries, you can use the nm command with the -D or --

dynamic option. The following shows how to use it to view the

dynamically linkable symbols in the C standard library: \$ **nm -j -D**

**/lib/x86_64-linux-gnu/libc.so.6** *--snip--*

\_IO_do_write@@GLIBC_2.2.5 \_IO_doallocbuf@@GLIBC_2.2.5

\_IO_enable_locks@@GLIBC_PRIVATE \_IO_fclose@@GLIBC_2.2.5

\_IO_fdopen@@GLIBC_2.2.5 \_IO_feof@@GLIBC_2.2.5

\_IO_ferror@@GLIBC_2.2.5 \_IO_fflush@@GLIBC_2.2.5 *--snip--*

The -j forces nm to print just the symbols and suppress other

information.

Another tool you can use is readelf, which can display the contents of any ELF file, including object files. The readelf command is an example of a *binary utility*, a command designed to work with binary files such as ELF files. On some systems such as Solaris, you need to use elfdump

because readelf isn’t available.

To understand the output of readelf, you need to understand the

structure of ELF files and the notation used by readelf. But if all you want to do is check what functions or other symbols are in an

executable, you can enter **readelf -s *elf-file*** **\| more**, and you’ll see a large amount of output, a screenful at a time.

For example, I can run readelf on a program, say *myprogram*, that was linked to a *libutils.so* shared library and see all symbols, as shown here: \$

**readelf -s myprogram** Symbol table '.dynsym' contains 17 entries: Num: Value Size Type Bind Vis Ndx Name 0: 00000000 0 NOTYPE

LOCAL DEFAULT UND 1: 00000000 0 FUNC GLOBAL

DEFAULT UND **show_time** 2: 00000000 0 NOTYPE WEAK

DEFAULT UND \_\_gmon_start\_\_ *--snip--*

The fact that show_time has a value of 0 means that it is not yet bound to an address. This is to be expected, because the actual binding will not take place until runtime.

To learn more, first read the man page for ELF and then read the

page for readelf. You can also download the specification of ELF from

various websites such as the Linux Foundation

( [*https://refspecs.linuxfoundation.org/LSB_4.1.0/LSB-Core-generic/LSB-*](https://refspecs.linuxfoundation.org/LSB_4.1.0/LSB-Core-generic/LSB-Core-generic/elf-generic.xhtml)

[*Core-generic/elf-generic.xhtml*](https://refspecs.linuxfoundation.org/LSB_4.1.0/LSB-Core-generic/LSB-Core-generic/elf-generic.xhtml)). Chapter 10 explains the structure of ELF

files in detail.

Two other tools, hexdump and od, short for “octal dump,” are sometimes useful. Each can display a file’s raw, uninterpreted bytes

starting from byte 0, with byte addresses, in various output formats such as character when possible, hexadecimal, octal, and decimal.

*Commands to Show the Libraries Linked to a Program*

Another useful tool for determining which shared libraries are linked

into your program is ldd. You can give it the names of one or more

executables or object modules, and it will print those dependencies. The following listing shows how to run it on our hello executable, built from the *hel o.c* program from Listing 1-2: \$ **ldd hello** linux-vdso.so.1

(0x00007ffdbe564000) libc.so.6 =\> /lib/x86_64-linux-gnu/libc.so.6

(0x00007fc2e26a4000) /lib64/ld-linux-x86-64.so.2

(0x00007fc2e28f6000)

This shows that hello is linked only to the dynamic linker *ld-linux-x86-64.so.2* and the GNU C Library, *libc.so.6*, as well as a library named *linux-vdso.so.1*. We don’t need to know much about this library; it’s used by the C Standard Library at runtime to solve some performance issues.

Section 7 of the man page for vdso explains its purpose in more detail.

Let’s look at what dynamic libraries the ls program uses: \$ **ldd**

**/bin/ls** linux-vdso.so.1 (0x00007ffd591a7000) libselinux.so.1 =\>

/lib/x86_64-linux-gnu/libselinux.so.1 (0x00007efc6271. . libc.so.6 =\>

/lib/x86_64-linux-gnu/libc.so.6 (0x00007efc624f6000) libpcre2-8.so.0

=\> /lib/x86_64-linux-gnu/libpcre2-8.so.0 (0x00007efc6245. . /lib64/ld-linux-x86-64.so.2 (0x00007efc62793000)

This output shows that ls is linked to two libraries besides the linking loader and the C standard library. The *libpcre2* library has functions for working with Perl regular expressions, and *libselinux* is the SELinux runtime library. *SELinux* is a security system for Linux that defines access controls for the applications, processes, and files.

We can also use the ltrace and strace tools for seeing which functions are actually called when a program runs. You can learn how to use them from their man pages.

*The C Standard Library*

You’ll find several different C library implementations across Unix systems, but the one you’ll most likely encounter on a GNU/Linux

system is the GNU C Library, GNU’s implementation of the C

Standard Library. People refer to it as *glibc*. The name of the C Standard Library is expected to be *libc.so* on Unix systems, whether it is the GNU

implementation or another.

You can run the ldd command mentioned previously against any C

program to see the absolute pathname to *libc.so.\<n\>* , where *\<n\>* is the latest version number. In the previous example, *libc.so.6* is the file

*/lib/x86_64-linux -gnu/libc.so.6*.

On most Linux systems, this file’s execute bit is set, so that just by running the file, you’ll see version information, as shown here: \$

**/lib/x86_64-linux-gnu/libc.so.6** GNU C Library (Ubuntu GLIBC

2.39-0ubuntu3.1) stable release version 2.39. Copyright (C) 2024 Free

Software Foundation, Inc. This is free software; see the source for

copying conditions. There is NO warranty; not even for

MERCHANTABILITY or FITNESS FOR A PARTICULAR

PURPOSE. Compiled by GNU CC version 11.4.0. libc ABIs:

UNIQUE IFUNC ABSOLUTE For bug reporting instructions, please

see: \<https://bugs.launchpad.net/ubuntu/+source/glibc/+bugs\>.

Because some functions behave differently in different versions of

the library, you might need to design a program so that its execution

flow depends upon which library version is installed. GNU/Linux

systems provide a way to do this with the gnu_get_libc_version() function, which returns a pointer to a string containing the version number. Your program can use this number in conditional instructions, so that at

runtime, it can alter its behavior depending on the version. Its synopsis is as follows: \#include \<gnu/libc-version.h\> const char

\*gnu_get_libc_version(void);

The following program demonstrates its use; it just prints out the

version number: *get_glibc_version.c* \#include \<gnu/libc-version.h\>

\#include \<stdio.h\> int main() { printf("The version of glibc is:

%s\n",gnu_get_libc_version()); return 0; }

We can compile it and run it as follows: \$ **gcc get_glibc_version.c -**

**o get_glibc_version** \$ **./get_glibc_version** The version of glibc is:

2.35

This tells us that we have 2.35 installed on this system.

System Calls

An ordinary function call is a jump into and return from a routine that is part of the code linked into the program making the call, regardless of whether the routine is statically or dynamically linked to the code. A system call is like a conventional function call in that it causes a jump to a routine followed by a return to the caller. But it’s significantly different because it’s a call to a function that is a part of the Unix kernel.

It’s easy to tell whether a function is a system call or a library

function. System call man pages are usually in Section 2, whereas library functions are usually in Section 3. If when you read the man page for a function, its SYNOPSIS shows you that you need to include *unistd.h*, then it’s most likely a system call. If the function is in Section 3, *unistd.h* is not required.

The code that’s executed during a system call is actually kernel code.

Since the kernel code accesses hardware and contains privileged

instructions, it must be run in privileged mode. Since only the kernel runs in privileged mode, this mode is also commonly called *kernel mode* or *privileged mode*. Therefore, during a system call, the process that made the call runs in kernel mode.

Unlike an ordinary function call, a system call causes a change in the execution mode of the processor; systems usually implement this with a *trap instruction*.

NOTE

*A* trap *is a machine instruction that changes the processor mode and* *jumps to a specific location in memory. In older systems, the trap is* *implemented with the* *int 0x80* *instruction. Linux kernels from 2.6 and* *later use the* *sysenter* *instruction, and the GNU C Library glibc 2.3.2*

*and later use* *sysenter.*

The kernel supports a fixed number of system calls on any given system. The syscalls man page lists the names of all calls supported on the system. Each call is associated with a number that’s used as an index into a table of addresses to which control is transferred inside the

kernel. These numbers are system dependent, but each has a symbolic

name defined by a macro. For example, the symbolic name for the

getpid() system call number is \_\_NR_getpid (as well as SYS_getpid for

backward compatibility). As of this writing, the latest Linux kernel has about 450 different system calls. The trap instruction is typically

invoked with a parameter that references this number to specify which

system call to run.

The number of parameters in system calls varies, and the method by

which they’re transferred to the kernel depends on how many there are.

Linux systems use a combination of two different methods:

Register method Parameters are placed into known registers in a

specific order. When the number of parameters exceeds the number

of available registers, the block method is used instead.

Block method The parameters are stored in a block of consecutive

bytes in memory, and the address of the block is passed in a register.

The latest version of Linux does not allow more than six parameters

to a system call.

*Wrapper Functions*

Processes don’t usually invoke system calls directly. Instead they call wrapper functions. A *wrapper function* for a function named foo() does very little other than repackage the parameters of the call to foo(), call foo(), collect its return value, and possibly supply it in a different form to the caller. The GNU C Library *glibc* has wrapper functions for almost all system calls.

Wrapper functions for system calls usually have the same name as

the call itself. They also have to execute the trap instruction to trap to kernel mode.

A wrapper is said to be *thin* if it does almost nothing but pass the arguments in and receive the return values. The GNU C Library

wrapper functions are often very thin, doing little more than copying

arguments to the right registers before invoking the system call and

then setting the value of a global error variable.

Sometimes a wrapper is not so thin, as when the library function has

to decide which of several alternative functions to invoke, depending

upon what is available in the kernel. The truncate() system call is a good example. It can truncate a file to a specified length, discarding the data beyond that length.

The original truncate() function could handle only lengths that could

fit into a 32-bit integer. When filesystems were able to support very

large files, a newer version named truncate64() was added. The newer

function can process lengths representable in 64 bits. The wrapper for truncate() decides which one is provided by the kernel and calls it.

*System Call Execution*

The following list summarizes the steps that take place during a system call:

1\. The user program makes a normal function call to the wrapper

function in the library.

2\. The wrapper function copies the arguments of the call off of the

stack and puts them into the registers where the kernel expects

them.

3\. The wrapper executes the trap, passing the number of the system

call as its argument. This causes the mode switch to supervisor

mode and the jump to the kernel’s system call handler.

4\. The kernel’s system call handler uses the number passed to it to

access the system call vector at that offset. The vector contains the

address in system space of the actual kernel code for that call.

5\. The actual call code is executed, and it passes the return value back to the system call handler.

![](/tmp/audit/iter1/epubregen/system-programming-in-linux/media/index-132_1.jpg)

6\. The handler passes the return value to the wrapper; the return

instruction executed by the handler causes the switch back to user

mode. If an error occurred, the wrapper function makes the error

code available to the program.

Figure 2-2 illustrates these steps schematically from the moment the system call is executed in a user program until it returns from the call.

*Figure 2-2: A sample detailed system call execution flow*

Some system calls don’t have wrappers in the library, and for those,

the programmer has no other choice but to invoke the system call with

the syscall() function, passing the system call’s number and arguments.

Generally speaking, for a system call named foo, its number is defined by a symbolic constant named either \_\_NR_foo or SYS_foo. These macro

definitions are exposed by the header file *sys/syscal .h*, which you’d need to include in the code. They may not be in that file itself, but in an

included file, such as *asm/unistd_32.h* or *asm/unistd_64.h*. The man page for syscall() lists the headers to include.

An example of a system call that may not have a wrapper is gettid(),

which returns the caller’s thread ID. (A wrapper was added to *glibc* starting in version 2.30.) In Chapter 1, we saw a slightly different program that called this function. It’s the same as getpid() for a process with a single thread. The *gettid_demo.c* program in Listing 2-1 uses syscall() to call gettid() and prints the returned ID on the screen.

*gettid_demo.c*

\#include \<unistd.h\>

\#include \<sys/syscall.h\>

\#include \<sys/types.h\>



{

printf("Thread id %ld\n", syscall(SYS_gettid));

/\* Could also pass \_\_NR_gettid \*/


}

*Listing 2-1: A program that uses the* *syscall()* *function to make a system call* Because gettid() has no arguments, it isn’t necessary to pass anything other than the system call number to syscall(). If it did have arguments, they would be passed as parameters after the call’s number.

*Multiple Paths to Kernel Services*

In summary, some of the services that a program needs are satisfied by the following:

Calling a library function that doesn’t need to make a system call

Calling a library function that does make a system call

Making a system call through a wrapper function

In rare cases, using syscall() to make a system call

Figure 2-3 illustrates these various paths to the kernel.

![](/tmp/audit/iter1/epubregen/system-programming-in-linux/media/index-134_1.jpg)

*Figure 2-3: The different control paths for obtaining services, showing the relationship* *between library function calls and system calls*

The figure shows, for example, that if a program calls a library

function that needs to make a system call, the path to the kernel is

through library functions, system call interfaces or wrappers, and then the system call handler.

Handling Errors from System Calls and Library

Functions

A good program should be robust enough to terminate normally even

when system calls and library functions return errors, which means you need to understand how these errors are returned and know the tools at

your disposal for handling them. System calls and library functions use two different methods for indicating that an error occurred.

*System Call Errors*

Almost all system calls return a negative number when an error occurs

in their execution. The absolute value of that number is meaningful; it indicates the type of error. The fact that it is negative is what indicates that it failed. A handful of system calls don’t behave this way, but their man pages indicate when that’s the case. When the system call returns

to the C library wrapper function, if the return value is negative, the wrapper stores the absolute value of the return value into a static

variable named errno, defined in the *errno.h* header file. It also returns -1

to the calling program. By including *errno.h* in your program, you can read the value stored in errno.

A robust program should check the return value of system calls and

handle every possible error. Read the man page to find the list of error values that the particular system call can return. In the ERRORS section on that page, you’ll see the list of error codes that can be returned,

expressed as symbolic constants. You don’t need to know the actual

numbers, just their symbolic names.

USING THE ERRNO VARIABLE

Your program must not declare the errno variable. Because errno is

declared in *errno.h*, including the header also includes its

declaration. If you put another declaration of it in your program, it

would hide the real errno variable and the one your program uses

wouldn’t contain the error values. Also, the program must inspect

errno immediately after the system call because, if your program

calls any other function or makes another system call before it

inspects that variable, the error value may be overwritten by the

error value resulting from the later call.

You can also enter the **errno -l** command to see the list of all possible error codes from all system calls. This command is part of the moreutils package, which may not be installed on your system. If you see an error message after entering that command, you need to install the package. A normal run looks like: \$ **errno -l** EPERM 1 Operation not permitted ENOENT 2 No such file or directory ESRCH 3 No such process

EINTR 4 Interrupted system call EIO 5 Input/output error ENXIO 6

No such device or address E2BIG 7 Argument list too long ENOEXEC

8 Exec format error *--snip--*

Let’s work through an example to demonstrate how to put this

together. We’ll use a small program that makes a relatively simple

system call to gethostname(), which stores the hostname of the computer in its first parameter or returns -1 if it fails. Because gethostname() can return just a few possible error values, it’s a good choice for showing how to handle errors. The first step is to read the gethostname() man page to understand how to call it and respond to the errors. The man page,

which also documents sethostname(), shows us its prototype: \#include

\<unistd.h\> int gethostname(char \*name, size_t len);

The type of the second parameter, size_t, is an unsigned integer type

that is defined by the POSIX.1 standard. Unix systems that conform to

the standard employ this type for all symbols that are supposed to store the size of any kind of object. It’s our first example of a Unix system type.

The man page explains the behavior of gethostname():

gethostname() returns the NULL-terminated hostname in the character array name, which has a length of len bytes. If the NULL-terminated hostname is too large to fit, then the name is truncated, and no error is returned. POSIX.1-2024 states that if such truncation occurs, then it is unspecified whether the returned buffer includes a terminating NULL byte.

Based on this explanation, our program must check the value returned

and handle the error, because if the name array was truncated and is

missing the terminating NULL byte, the program will generate some type of fault, most likely a segmentation fault, when we try to print the name.

The ERRORS section on the man page for gethostname() lists three

possible errors:

**EFAULT** When name is an invalid address

**EINVAL** When len is negative

**ENAMETOOLONG** When len is smaller than the actual size

This list implies that we should have code to handle each case.

Because there are only three, a sequence of if statements can handle

them.

Listing 2-2 contains a complete program, *gethostname_demo.c*, that demonstrates one way to handle the errors from the call to gethostname().

*gethostname_demo.c*

\#include \<unistd.h\>

\#include \<stdio.h\> ➊ \#include \<errno.h\>

void main()

{

char name\[4\]; /\* Declare string to hold returned value. \*/

size_t len = 3; /\* Purposely too small so error is revealed \*/

int returnvalue;

returnvalue = gethostname(name, len); /\* Make the call. \*/

➋ if ( -1 == returnvalue ) {

switch ( errno ) {

case EFAULT:

printf("A bad address was passed for the string name\n"); break; case EINVAL:

printf("The length argument was negative.\n"); break;

case ENAMETOOLONG:

printf("The hostname is too long for the allocated array.\n");

}

}

else

printf("%s\n", name);

}

*Listing 2-2: A program that demonstrates how to handle system call errors by inspecting the* *errno* *variable* The program needs to include *unistd.h* on the first line because gethost

name() is a system call. It includes *errno.h* ➊ in order to use the errno variable. If the if condition ➋ is true, an error occurred and the switch statement selects a custom error message to print, after which the program terminates. If not, the program prints the name returned in the else clause. I purposely made the array too small for most machine names so that when this program is run we get to see the error message. By changing the array size to a large enough number, we prevent the error from occurring.

The following run of the program shows what it outputs, assuming

the hostname is *harpo* and the executable is named *gethostname_demo*: \$

**./gethostname_demo** The hostname is too long for the allocated array.

An alternative to writing your own messages based on the value in

errno is to use either the perror() library function declared in *stdio.h* or the strerror() library function declared in *string.h*. Both of these functions are *locale aware*, which means that if the program in which they’re called is being run by a user who uses a language other than English, the

message will be translated into that language, provided that the system supports it. Locales are described briefly in “Internationalization” on

page 71 and covered in more depth in Chapter 3.

The perror() function writes a message onto the standard error

stream describing the last error encountered during a call to a system or library function. Its synopsis is: \#include \<stdio.h\> void perror(const char \*s);

This function prints the string argument followed by a predefined

message. Usually you pass it the name of the function as the string, as shown in *perror \_demo.c*, displayed in Listing 2-3. This program doesn’t need a switch statement because the selection logic is in perror(). It just calls perror() instead.

*perror_demo.c*

\#include \<unistd.h\>


void main()

{

char name\[4\]; /\* Declare string to hold returned value. \*/

size_t len = 3; /\* Purposely declared too small so error is revealed \*/

int returnvalue;

returnvalue = gethostname(name, len); /\* Make the call. \*/

if ( -1 == returnvalue )

perror("gethostname");

else

printf("%s\n", name);

}

*Listing 2-3: A program that uses* *perror()* *to handle system call errors* Running this program, assumed to be compiled to *perror_demo*, shows what perror() prints: \$

**./perror_demo** gethostname: File name too long

The major drawback to relying on perror() is that by removing the

switch, we’ve eliminated the chance to take different actions depending on the type of error. We can’t, for example, terminate the program for some errors and not others. A lesser drawback is that we can’t customize the error message. Like using errno, your program must call perror()

immediately after the call, because otherwise it won’t have the message for the error from the call.

The strerror() function’s synopsis is: \#include \<string.h\> char

\*strerror(int errnum);

It returns a pointer to a string containing the error message for the

error number passed to it. Therefore, strerror(errno) is the error message associated with errno.

We can modify the preceding example by replacing the call to

perror() with a call to strerror(errno). Here’s the changed portion of the program, which I’ve named *strerror_demo.c*: *strerror_demo.c* \#include

\<unistd.h\> \#include \<string.h\> \#include \<stdio.h\> \#include \<errno.h\> *--*

*snip--* returnvalue = gethostname(name, len); /\* Make the call. \*/ if ( -1

== returnvalue ) printf("gethostname failed: %s\n", strerror(errno)); else printf("%s\n", name); }

This function is not safe to use in a multithreaded program. Two

different thread-safe versions of the program are available in

GNU/Linux systems, both of which are described on the strerror man

page.

*Errors from Library Functions*

Library functions don’t necessarily respond to errors in the same way as system calls. In general, they fall into four different categories with respect to error handling:

Functions that behave exactly the same way as system calls,

returning -1 and setting the value of errno

Functions that don’t return -1 on error but do write the value of the

error into errno, such as the C malloc() function, which returns a NULL

pointer on error and sets the value of errno to the only possible

error it can have, ENOMEM (out of memory)

Functions that don’t use errno for reporting the type of error, such

as the character I/O functions fgetc() and getc(), which return EOF

(the end-of-file return value, defined in *stdio.h*) on error and don’t set errno

Functions from the *Pthreads* library, which we discuss in Chapter

15, that return 0 on success and a positive number as an error value on failure

The only way to know how to handle the errors for the specific function your program is using is to read its man page.

Portability

*Portability* refers to the degree to which your program can run on other computers with little or no modification of the code itself. If, for

example, your code uses features available only in GNU/Linux and you

try to run it on another Unix system without that support, it won’t

behave the same way, and you may not even be able to build it unless

you modify the source code.

Unix’s haphazard growth is partly the cause of this problem, because

over time, three major variants of Unix evolved: BSD, GNU/Linux, and

System V (see Chapter 1). These variants had different features and capabilities, and people created standards to specify how those various systems were supposed to behave. One Unix system can have functions

with the same names as another but whose semantics are different

because they evolved in different variants. We need to know which version of a function our program uses when we compile it on the

development machine and whether it will be the same when we compile

the program on a different machine.

If you’re distributing source code to be built on other computers,

ideally you would design it so that it will compile into an executable whose behavior is what you expect even on other computers.

Portability is tied to the concept of standards because, for example, if your program is intended to adhere to the POSIX.1-2024 standard but

must be built on a system conforming to a different, perhaps older,

POSIX standard, you need to know how to design the code so that it

uses features available on the other computer when the ones you hoped

to use aren’t available. The macro preprocessor’s ability to compile code conditionally based on the values of macro objects is the key to solving this problem.

*Feature Test Macros*

A *feature test macro* is a macro designed to expose features such as constant and function prototypes in a header file when a program is

compiled. For example, the following code is found in the *stdio.h* header:

\#ifdef \_\_USE_GNU /\* Close all streams. . \*/ extern int fcloseall (void);

\#endif

In this example, the declaration of the closeall() function will be

exposed, meaning included in the program when you use the \#include

\<stdio.h\> directive, only if the symbol \_\_USE_GNU is defined when the preprocessor reaches that directive in the program’s code.

The header files and other source code files in the libraries and

system call interfaces contain these conditional compilation directives in order to enable or disable the inclusion of various features. These

feature test macros are designed to allow the libraries and interfaces to conform to multiple standards.

Feature test macros cannot be used to ensure that your program

conforms to a limited standard, because they won’t prevent you from

including header files that haven’t been written to conform to their use.

They’re primarily intended to control which standards to follow in the code.

Let’s consider how to use them to control which features you want

to enable or disable in your program. Suppose you’re about to embark

on a new project and want to use some functions you’ve never used

before. Suppose one of them is the C getline() function, which has many versions. When you look at its man page, you’ll probably see something like the following description: NAME getline, getdelim - delimited

string input SYNOPSIS \#include \<stdio.h\> ssize_t getline(char

\*\*lineptr, size_t \*n, FILE \*stream); ssize_t getdelim(char \*\*lineptr, size_t

\*n, int delim, FILE \*stream); Feature Test Macro Requirements for

glibc (see feature_test_macros(7)): getline(), getdelim(): Since glibc 2.10: \_POSIX_C_SOURCE \>= 200809L Before glibc 2.10:

\_GNU_SOURCE *--snip--*

The page explicitly mentions Feature Test Macro Requirements. What are they, and how are you supposed to use this information?

If the SYNOPSIS section of a function’s man page lists feature test macro requirements, it means that the given prototype or constant declaration will be read by the preprocessor only if the macro is defined *before* including *any* header files, not just the one in which it is declared, but all of them, as in: \#define \_\_GNU_SOURCE \#include \<unistd.h\> \#include

\<stdlib.h\> \#include \<string.h\> *--snip--*

If you understand how the header files use these definitions, the

code will make much more sense to you. I’ll use a simplified version of the *stdio.h* header file to illustrate, because the actual header file is much more complex. The declaration of the prototype for getline() in this file looks roughly like this: \#ifdef \_\_GNU_SOURCE ssize_t getline (char

\*\*\_\_lineptr, size_t \*\_\_n, FILE \*\_\_stream); \#endif

Unless the symbol \_\_GNU_SOURCE is defined when the preprocessor

reads the \#ifdef \_\_GNU_SOURCE line, the getline() function will be skipped over. Therefore, in order for your program to use this version of the

function, you need to define that symbol before any header file is

included, like so: \#define \_\_GNU_SOURCE \#include \<stdio.h\> *--*

*snip--*

Doing this causes the lines that \#ifdef \_\_GNU_SOURCE ... \#endif protects to be read.

The man page in essence tells us that if we want to use either of the

two functions getline() or getdelim(), if our version of *glibc* is 2.10 or later, we need to include the definition: \#define \_POSIX_C_SOURCE

200809L /\* Or any number \>= 200809 \*/ \#include \<stdio.h\>

If our version of *glibc* is older than 2.10, we need to use this macro:

\#define \_GNU_SOURCE \#include \<stdio.h\>

If you don’t remember how to find which version of *glibc* you have, see the “The C Standard Library” on page 57.

As an alternative to defining the macro in the program source code,

we can enable the definition when we compile the code on the

command line using the -D option to gcc, as in \$ **gcc -D\_\_GNU_SOURCE**

**myprog.c -o myprog**

or

\$ **gcc -D_POSIX_C_SOURCE=200809L myprog.c -o myprog**

Some feature test macros are intended to make your program more

portable by preventing nonstandard definitions from being exposed.

Other macros serve the opposite purpose, exposing nonstandard

definitions that aren’t exposed by default. The syntax of the feature test macros on the man page uses the logical-OR and logical-AND

operators: \|\| and &&. The example shown in the feature_test_macros man page is for the acct() function. It’s not important what this function does: SYNOPSIS \#include \<unistd.h\> int acct(const char \*filename); Feature Test Macro Requirements for glibc (see feature_test_macros(7)): acct(): Since glibc 2.21: \_DEFAULT_SOURCE In glibc 2.19 and 2.20:

\_DEFAULT_SOURCE \|\| (\_XOPEN_SOURCE &&

\_XOPEN_SOURCE \< 500) Up to and including glibc 2.19:

\_BSD_SOURCE \|\| (\_XOPEN_SOURCE && \_XOPEN_SOURCE \<

500\) *--snip--*

The interpretation of the logical-OR operator \|\| is that in order to

obtain the declaration of acct() from \<unistd.h\>, either of two options can be applied. One is to include the macro definition \#define \_BSD_SOURCE

before including any header files. The other option contains a logical-AND. You can include the macro \#define \_XOPEN_SOURCE but only if it has a numeric argument after it whose value is less than 500.

The following list describes a few common macros we’ll encounter

when reading code and man pages:

**\_POSIX_SOURCE** Exposes the functionality from the POSIX.1 standard as well as all of the ISO C features

**\_POSIX_C_SOURCE** Controls which POSIX functionality is made

available, determined by its assigned value

**\_XOPEN_SOURCE** Exposes features from POSIX.1, POSIX.2, and

X/Open standards

**\_GNU_SOURCE** Applies only to the *glibc* library and exposes everything in ISO C89, ISO C99, POSIX.1, POSIX.2, BSD, SVID, X/Open, LFS,

and all GNU extensions (if POSIX.1 conflicts with BSD, POSIX

takes precedence)

**\_BSD_SOURCE** Exposes functionality derived from 4.3 BSD Unix, ISO

C, POSIX.1, and POSIX.2

**\_SVID_SOURCE** Exposes functionality derived from SVID (System V

Interface Definitions), ISO C, POSIX.1, POSIX.2, and X/Open

Read the feature_test_macros man page to get a good understanding of

why these macros are needed and how you can use them in general.

We’ll revisit them in later chapters as the need arises.

*Other Portability Issues*

As we start to develop system programs, we’ll see that other factors

affect how portable they are, including the following:

The sizes of various data types

The values of configuration parameters

The sizes and ordering of data members in structures

The set of macros actually available in header files

We’ll address these issues as they arise.

System Limits

All Unix systems set limits on system resources and properties, such as the maximum length of a filename or a pathname and the maximum

length of a username. Various standards specify minimum values for

these maximums. For example, POSIX.1-2024 specifies that

\_POSIX_NAME_MAX is the least value that any conforming system can use as the maximum length of a filename. These specified values are called

*system limits*.

A portable application needs to know what these limits are on each

system on which it runs, and it should be able to adjust its use of

resources accordingly. There are a few different means for getting these limits, depending on their category. POSIX.1-2024 divides system limits into three such categories:

Runtime invariant Those whose values are constant for any

particular Unix system

Pathname variable Filesystem-related limits whose values can vary

on a single system, depending on which filesystem they limit

Runtime increasable Those whose values can be increased at

runtime

For example, most runtime invariant limits are defined in the header

file *limits.h*. A program can call the functions pathconf() and sysconf() to get the values of various limits at runtime. Several programs in later chapters of the book provide examples of how to do this.

Internationalization

In the early days of computing, almost all software was developed for

English speakers. Now, computer systems are used throughout the

world, and we need to design software so that it accommodates local languages and cultural conventions. Sometimes differences in cultural

conventions can lead to ambiguities with serious consequences. Two

simple examples illustrate this issue:

In the United States, people express dates in the format *MM/DD/*

*YYYY*, where *MM* is a two-digit month, *DD* is a two-digit day of the month, and *YYYY* is a four-digit year, such as 07/11/2033. In Europe, the convention is *DD/MM/YYYY*. If a program is

transported from one side of the Atlantic to another and dates are

input or output, it would be hard to know which date is meant by

07/11/2033. Is it November 7 or July 11, 2033?

In the United States, people use commas to separate the three-digit

decimal groups of large numbers, and they use the period as the

*radix character*, commonly called the decimal point, when numbers are written in base 10, such as 1,048,576.00. In Europe, people use

periods to separate the three-digit decimal groups of large

numbers, and they use a comma as the *radix character*, as in

1.048.576,00. Programs designed to parse only one representation

will fail unless they know in which environment they’re running.

Several other cultural conventions differ from one region to another,

such as written languages, paper sizes, monetary units, time units, and measurement units.

The concept of a locale is intended to consolidate the cultural

differences that affect the computational environment. POSIX.1.2024

and SuSv4 \[14\] simultaneously define a *locale* as “the definition of the subset of a user’s environment that depends on language and cultural

conventions.” When a program is designed so that it works correctly no matter where it’s used and performs input and output consistent with

the location in which it’s run, we say the program has been

*internationalized*. *Internationalization* is the process of writing programs that accommodate variations in locales across the globe. Unix systems

are required to provide certain basic support for internationalizing

programs. Chapter 3 contains an introduction to this complex topic.

Processing the Command Line and Environment

In a Unix environment, commands such as \$ **gcc -o main main.c**

**utils.c fileio.c** \# Build executable main from sources.

and

\$ **rm -r f1 f2 f3 dir** \# Recursively remove f1, f2, and f3 from dir.

are examples of *simple commands*. In a simple command, a whitespace-separated list of words may follow the name of a program. In most

shells, the *whitespace* characters that separate words are either a space or a tab. Newline characters terminate commands and do not separate

their words.

A *word* is usually defined to be any sequence of non-whitespace characters not containing shell reserved characters unless they are

escaped with a backslash or enclosed in single quotes. The first word of a simple command is typically the name of a program to be executed,

which might be an executable file or a shell builtin. In the preceding two examples, the programs are gcc and rm, respectively.

In shells that conform to POSIX.1-2024, the command can begin

with one or more variable assignments as well; we’ll see examples of this in Chapter 3. In the rest of this section, when I use the term *command*, I mean a simple command.

When you type a command and press ENTER, the shell makes the

words following the command name available to the program executing

that command. The program needs to distinguish between the words

that are non-option arguments to the command, such as main.c, utils.c, and fileio.c from the previous example, and those that are command

options, such as -o main and -r. In this section, I’ll explain how you can design your programs to extract words from the command line, separate

them into options and arguments, and obtain the values of any

environment variables that may influence the behavior of the program.

*Extracting Command Line Arguments*

To start, we’ll assume that all of the words following the command

name are non-option arguments. In “Extracting Command Line

Options” on page 81, we’ll remove this assumption and revisit how to process a command line that contains options.

In Unix and other POSIX-conforming operating systems, the

operating system, in conjunction with the shell, arranges for the list of words from the command line, which includes both the program name

and the command line arguments, to be made available to the program

itself as a NULL-terminated array of strings passed into the second

parameter of the main() function. The shell takes care of parsing the line, finding the arguments, finding the redirection operators, and possibly evaluating variables and other expressions. For example, in the

command \$ **ls dir1 dir2 \> listing dir3**

the arguments the shell finds are dir1, dir2, and dir3. The phrase \> listing is a redirection; you’re allowed to put redirections between those

arguments, even though it’s a confusing thing that you should never do.

A program’s main() function is allowed to have no parameters, as in

int main() { /\* Program here . . \*/ }

but in this case, it’s unable to access its command line arguments.

The C standard requires compliant implementations of C (C

compilers) to accept a main() function with two parameters, as follows: int main (int argc, char \*argv\[\]) { /\* Program here . . \*/ }

The first parameter is an integer that specifies the number of words

on the command line, which includes the name of the program,

implying that argc *≥* 1. The second parameter is a NULL-terminated array of C strings that stores all of the words from the command line,

including the name of the program, which is always in argv\[0\]. The

command line arguments, if they exist, are stored in argv\[1\], . . . , up to argv\[argc-1\].

Although many programs use argc and argv as the names of these

parameters, there’s nothing special about them; they can be any valid

identifiers you choose. It’s a convention to use the names argc and argv, but you’ll often find programs that use ac and av instead. You could name them foo and bar, for instance, but that would be pretty bad

programming style. Figure 2-4 illustrates how the arguments are made available to the program.

![](/tmp/audit/iter1/epubregen/system-programming-in-linux/media/index-149_1.jpg)

*Figure 2-4: How command line arguments are passed to a program*

Notice that a sequence of words enclosed in single quotes with

embedded whitespace is a single word in the argument list. Also observe that the last element in the argument array is a NULL pointer.

Listing 2-4 is a simple program, *printargs1.c*, that shows one way for a program to access its command line arguments in a program.

*printargs1.c*



{

printf("%s arguments:\n", argv\[0\]);

for ( int i = 1; i \< argc; i++ )

printf("%d: %s\n", i, argv\[i\]);


}

*Listing 2-4: A program that prints its command line arguments* It displays the command name that the user enters to execute the program, followed by the command line arguments

that it receives from the shell, numbered to show their positions, one per line.

Notice that the last argument is in argv\[argc-1\], not argv\[argc\]. Because the array’s last element is a NULL byte, we can also iterate through the arguments until the condition argv\[i\] == NULL is true, as shown in Listing

2-5.

*printargs2.c*


int main(int argc, char \*argv\[\]) {

int i = 1;

printf("%s arguments:\n", argv\[0\]);

while ( argv\[i\] != NULL )

printf("%d: %s\n", i, argv\[i++\]);


}

*Listing 2-5: A program that prints its command line arguments until it finds the* *NULL* *byte in* *the* *argv\[\]* *array* Using pointer arithmetic, we could dispense completely with the index variable i. (This is left as an exercise for the reader.)

*Accessing the Environment*

Within a program, you can also access any of the environment variables that the program inherited. I’ll show three different ways to do this.

Some are more efficient than the others, depending on the program’s

specific needs.

Using the getenv() Function

You can use getenv() to retrieve the value of any environment variable in the environment passed to the program. We saw its use in

“Environments” on page 15. Its synopsis is as follows: \#include

\<stdlib.h\> char \*getenv(const char \*name);

Given name, it searches the environment list for a variable matching

name, and if it finds one, it returns a pointer to its value; otherwise, it returns NULL. For example, the program in Listing 2-6 prints the value of the HOME environment variable, unless it’s not in the environment, in

which case it prints an error message.

*getenv_demo.c*

\#include \<stdlib.h\>


int main()

{

➊ char \*path_to_home;

path_to_home = getenv("HOME");

if ( NULL == path_to_home )

printf("The HOME variable is not in the environment.\n");

else

printf("HOME=%s\n", path_to_home);


}

*Listing 2-6: A program that uses* *getenv()* *to access the environment* The getenv() function returns a pointer to the string inside the actual environment list, not to a copy of that string, which means that if you modify it in your program, you’re modifying the environment. It also means that in your program, the variable that you declare to receive the return value should be a char\*, not a local array. For example, path_to_home ➊ would be declared incorrectly by making it an array of characters, such as char path_to_home\[256\];

since this allocates storage for it and makes path_to_home a constant char pointer. The function wouldn’t be able to assign a value to it, and the compiler will flag it as an error.

POSIX.1-2024 allows an implementation of this function to store

the string whose address is returned in a statically allocated storage location, which means it will be overwritten by a subsequent call. If you intend to call it again, copy the return value to a local variable. For example, the following code may not work on some systems, because by

the time that the value of home is evaluated, the storage has been

overwritten by the return value of getenv() in user = getenv("USER"): *--*

*snip--* char \*home, \*user; home = getenv("HOME"); if ( NULL !=

home ) { user = getenv("USER"); if ( NULL != user ) printf("USER=%s and HOME=%s\n", user, home); } *--snip--*

Instead, you could use a string copying function such as strncpy() to copy the return value into home, as in: char home\[256\]; strncpy(home,

getenv("HOME"), sizeof(home));

![](/tmp/audit/iter1/epubregen/system-programming-in-linux/media/index-152_1.jpg)

If you do this, make sure to include the *string.h* header file, since the declarations of the string copying functions are there.

Using the environ Variable

When a program starts, it’s given access to an externally defined global variable named environ of type char\*\*, which is initialized to point to the start of the environment list inherited by the program, as illustrated in

Figure 2-5.

*Figure 2-5: The* *environ* *pointer*

In Figure 2-5, instead of enclosing the environment strings in quotes, they’re shown as sequences of characters terminated by a NULL

byte (\0). The environ array is terminated by a NULL byte as well.

You can use this variable to access any of the environment strings by

a sequential search through the list. The program in Listing 2-7

demonstrates how to use environ to print the values of all environment variables inherited by the program.

*environ_demo.c*

\#include \<stdlib.h\>


extern char \*\*environ; /\* environ is declared extern because it \*/

/\* is defined outside of the program. \*/

int main()

{

char \*\*envp = environ; /\* Set pointer to start of list. \*/

while ( NULL != \*envp ) {

printf("%s\n", \*envp);

envp++;

}


}

*Listing 2-7: Using* *char \*\*environ* *to search the environment sequentially and print its* *environment strings* In effect, *environ_demo.c* does exactly what the printenv command does.

If all you need are the values of a few environment variables, using

environ is not the best way to obtain them, because you’d need to search the environment linearly, and in the worst case, since the list is

unordered, you’d need to compare every environment variable to the

one(s) you’re trying to find. Since each string comparison can look at every character of every variable name in the worst case, this search can take time proportional to the total number of characters in all

environment variables. The getenv() function does this searching

efficiently, so it’s a better choice.

Using a Third Parameter to main()

The third method for accessing the environment list is to declare the

main() function of any program with a prototype that has a third

parameter: int main(int argc, char \*argv\[\], char \*envp\[\])

This envp parameter points to the start of the environment list inherited by the program in the same way that the environ variable does.

You could then access the environment list with a loop such as: int n

= 0; while ( NULL != envp\[n\] ) { /\* Do something with envp\[n\]. \*/

printf("%s\n", envp\[n++\]); }

If you need only a few variables’ values, it’s better to use getenv().

Even though many systems support this feature, POSIX.1-2024 doesn’t

support it, which implies that on some systems, your code won’t work if you use it, so I advise you not to use it.

*Reporting Usage Errors*

A program that expects one or more command line arguments must

check whether it was provided what it expected. Otherwise, it will

attempt to access locations in the array of arguments that don’t exist, resulting in a fatal error.

For example, suppose you write a program that expects the names of

two files on the command line, the first being the name of a file to open for reading and the second being the name of a file to open for writing.

Let’s say the program executable is named myprog. The correct usage of myprog would be of the form: \$ **./myprog *inputfile outputfile***

The command line must have at least three words for this program

to run properly. If there are more than three, it can ignore the extras.

The program should be allowed to run only if the first parameter to

main(), which is int argc, is at least 3. The program in Listing 2-8

demonstrates how to check for correct usage properly.

*usagecheck_demo.c*


\#include \<stdlib.h\>


{

if ( argc \< 3 ) { /\* Too few arguments \*/

/\* Handle the incorrect usage here. \*/

➊ fprintf(stderr, "usage: %s file1 file2\n", argv\[0\]);

exit(1); }

printf("About to copy from %s to %s\n", argv\[1\], argv\[2\]);

/\* But no code for copying just yet \*/


}

*Listing 2-8: A program that checks for correct usage, printing a message if it is used* *incorrectly* If the user doesn’t supply two or more arguments, the program exits after displaying a message by calling the C fprintf() function ➊, whose first parameter is the C

Library file stream to which to print, in this case, the standard error stream (stderr).

Otherwise, it prints a message saying that it will copy from the first named file to the second.

We’ll see how to copy files in Chapter 4. For now, we just say we’re doing so.

*Extracting the Program Name*

Suppose that we compile *usagecheck_demo.c*, putting the executable into a different directory from our working directory. This command puts it

into the *bin* subdirectory of our home directory: \$ **gcc -o**

**~/bin/usagecheck_demo usagecheck_demo.c**

The ~ character is a shell special character that expands to the pathname of a user’s home directory.

We’ll now run usagecheck_demo from the current working directory

without giving it the name of the output file: \$ **~/bin/usagecheck_demo** **infile** usage: /home/stewart/bin/usagecheck_demo file1 file2

When the program runs, the tilde ~ is expanded to the path

*/home/stewart* and argv\[0\] contains the entire pathname,

*/home/stewart/bin/usagecheck_demo*.

If you don’t want to display the entire pathname of the program but

prefer that it displays only the more concise message usage:

usagecheck_demo file1 file2

regardless of where the executable is, then before you print it, strip off the leading part of the argv\[0\] string so that the only thing left is what comes after the final / character. There are two relatively portable ways to do this, one more general than the other.

One way is to use the strrchr() function declared in *string.h*, whose prototype is: char \*strrchr(const char \*source, int ch);

This function returns a pointer to the rightmost occurrence in source of the ch character. (In C, we can declare characters as int.) If ch isn’t found in source, it returns a NULL pointer.

An algorithm for displaying the characters of the program name after the final / can search for the rightmost slash in the pathname and, if found, display the string that follows it. If it isn’t found, no leading directories exist in the path, so it can print the entire path. If it is found and is the rightmost character, it’s a usage error, since it means the pathname ends in a slash. Trying to run a command whose name ends in

a slash causes most shells to report an error. Listing 2-9 demonstrates this method.

*progname_demo.c*


\#include \<string.h\>


{

char \*forwardslashptr;

char \*suffixptr = NULL;

forwardslashptr = strrchr(argv\[0\], '/');

if ( forwardslashptr != NULL )

➊ suffixptr = forwardslashptr + 1;

else

suffixptr = argv\[0\];

if ( \*suffixptr == '\0' )

fprintf(stderr, "Program name ends in a / character\n");

else

printf("Program name is %s\n", suffixptr);


}

*Listing 2-9: A program that strips the program name of any leading directories using* *strrchr()* For those unfamiliar with C, or if your C is a bit rusty, the instruction suffixptr =

forwardslashptr + 1; ➊ performs *pointer arithmetic* to make suffixptr point to the first character after the forward slash.

When pointer arithmetic appears in code, the compiler translates

addition of an integer *n* to a pointer of type basetype\* into the addition of sizeof (basetype) \* *n* bytes to the pointer’s value. For example, if dblptr is a pointer of type double\* that contains the address 1024, and a double uses 8

bytes, then dblptr + 6 is the address 1024 + (6 × 8) = 1072. It’s worth remembering the strrchr() function because it’s a useful function for

other purposes as well. For example, we can use it to get the suffix of a filename or to get the portion of the filename before the suffix.

An easier, but less general, method of stripping the directories from

the pathname in argv\[0\] is to use the basename() library function, of which there are both POSIX and GNU versions. Their prototypes are the

same char \*basename(char \*path);

but the POSIX function is declared in *libgen.h*, whereas the GNU

version is declared in *string.h*. The POSIX function modifies argv, but the GNU version doesn’t. Furthermore, the man page for basename()

states that the POSIX version implemented in *glibc* has bugs. For these reasons, we’ll use the GNU version to demonstrate.

To use the GNU version, we need to define the \_GNU_SOURCE macro

before including any header files. Listing 2-10 shows the program.

*basename_demo.c*

\#define \_GNU_SOURCE


\#include \<string.h\>


{

char \*progname;

progname = basename(argv\[0\]);

printf("Program name is %s\n", progname);


}

*Listing 2-10: A program using* *basename()* *to strip the program pathname of its leading* *directories* We’ll compile this into an executable in the *~/bin* directory as we did with *usagecheck_demo.c* and run it in the same way: \$ **gcc -o ~/bin/basename_demo** **basename_demo.c** \$ **~/bin/basename_demo** Program name is basename_demo Only the program name is printed, not the full pathname.

*Extracting Command Line Options*

Almost all commands have options, which might be short or long or both. Some commands allow the order of options and arguments to

vary. For example, the following two command lines are equivalent: \$

**gcc myprog.c -o myprog -Wall -I includedir** \$ **gcc -Wall -o**

**myprog -I includedir myprog.c**

POSIX.1-2024 requires that all options should precede all of the

arguments, but some commands don’t conform to this requirement. If a

command has several short options, none of which have arguments, we

can write them in various combinations, such as the following: \$ **ssh -**

**acCfGgKkMN** \$ **ssh -a -c -CfGg -Kk -M -N** \$ **ssh -CfGg -Kk -M -a -**

**c -N**

If options do have arguments, their arguments must follow them

immediately, with whitespace allowed between the option letter and its argument.

The Utility Syntax Guidelines of the POSIX.1.2024 standard

(Section 12.2) contain rules about options that programs should follow to conform to the standard. In particular, a program that conforms to

these requirements should support the following option syntax:

One or more short options that have no option arguments,

followed by at most one option that has an option argument, can be

grouped behind one hyphen (-) delimiter.

The order of different options relative to one another should not

affect program behavior, with one exception. Repeated options that

have required arguments must be interpreted in the order that they

appear. The make utility is an example of a command that allows this.

It can have multiple -f options, and their order does matter.

GNU allows long options, but POSIX.1-2024 doesn’t require them.

Also, GNU allows options to have optional arguments, which POSIX.1-

2024 forbids. Finally, GNU allows arguments to precede options, which

POSIX.1-2024 forbids.

Writing a program that allows the user to enter options in various

forms and in any order, consistent with these requirements, makes

parsing the command line to find all of the options and their arguments a complex task.

Fortunately, Unix systems usually have two library functions named

getopt() and getopt_long() that can do this work for you. The latter is a GNU function that can parse command lines with long options, for

which you need to define \_GNU_SOURCE before the header file inclusions.

Their combined man page is as follows: GETOPT(3) Linux

Programmer's Manual GETOPT(3) NAME getopt, getopt_long,

getopt_long_only, optarg, optind, opterr, optopt - Parse command-line

options SYNOPSIS \#include \<unistd.h\> int getopt(int argc, char \* const argv\[\], const char \*optstring); extern char \*optarg; extern int optind, opterr, optopt; \#include \<getopt.h\> int getopt_long(int argc, char \*

const argv\[\], const char \*optstring, const struct option \*longopts, int

\*longindex); int getopt_long_only(int argc, char \* const argv\[\], const char \*optstring, const struct option \*longopts, int \*longindex); Feature Test Macro Requirements for glibc (see feature_test_macros(7)):

getopt(): \_POSIX_C_SOURCE \>= 2 \|\| \_XOPEN_SOURCE

getopt_long(), getopt_long_only(): \_GNU_SOURCE *--snip--*

Even though these are library functions, to use them you must include

*unistd.h*. The variables optarg, optind, opterr, and optopt are externally defined, and you must not declare them in your program.

The man page explains everything we need to know to use these

functions. If our program expects all arguments to follow all options

before the header files are included, it should define \_POSIX_C_SOURCE with a value greater than or equal to 2 or define \_XOPEN_SOURCE. If we want to allow a user to intermingle options and arguments, it doesn’t need to

define either of these macros.

As mentioned previously, we must define \_GNU_SOURCE to use

getopt_long().

The getopt() function parses the command line arguments. Its first

two arguments, argc and argv, are the argument count and array passed to the main() function. The third argument, optstring, is a string that

identifies the options and their arguments. The string is interpreted

according to the following rules:

A letter by itself is an option without arguments. For example, b represents -b.

A letter with a single colon (:) after it has a *required* argument, and getopt() will place a pointer to the argument in optarg if it exists, and if it’s missing, it will return ?. (See the final rule regarding how a leading : in optstring is used.)

A letter with a double colon (::) after it has an *optional* argument, and getopt() will place a pointer to it in optarg or will set optarg to 0 if it’s missing.

If getopt() finds an undefined option, it will put the character in

optopt, print an error message on stderr, and return ?. You can set

opterr to 0 to suppress the message. It will also perform these

actions if a required option argument is missing.

If the leading character is a :, then if getopt() finds a missing

required option argument, instead of returning a ?, it returns a :,

which makes it possible to distinguish the type of error. A : implies

a missing option argument, and a ? implies an invalid option

character.

Let’s look at a small program that uses getopt(). The option string

":hb::c:1" specifies that -h and -1 are options without arguments, -b is an option with an optional argument, and -c is an option with a required

argument.

The getopt() function initializes the external variable optind to 1.

When getopt() is called repeatedly, it returns each of the option

characters from each of the option elements on the command line.

When it can’t find any more options, it sets optind to be the index in the argv array of the next element to be processed, and it returns -1. Thus, when it returns -1, optind is the index in argv of the first argv element that isn’t an option. (By default, the GNU version of getopt() rearranges the contents of argv as it scans, so that eventually all the nonoptions are at the end.) A program that uses getopt() to parse the command line should consist of two parts:

A loop that calls getopt() repeatedly to find and record all options, option arguments, and any errors in usage, after which it stores the

command arguments in the argv array into suitable variables

Conditional code that uses the presence or absence of options and

arguments found earlier to control the program’s execution

Listing 2-11 demonstrates this idea. It uses the same set of options as in the example we just described. This program doesn’t do anything

other than print a list of the options that it finds as well as its arguments, but it shows how to collect the options found into a set of variables to be used later by the program.

*getopt_demo.c*

\#include \<stdio.h\> /\* For printf() \*/

\#include \<stdlib.h\> /\* For exit() \*/

\#include \<unistd.h\> /\* For getopt() \*/

\#include \<string.h\>

\#define TRUE 1

\#define FALSE 0


{

int ch;

char options\[\] = ":hb::c:1";

int opt_h = 0;

int opt_1 = 0;

int opt_b = 0;

int opt_c = 0;

char b_arg\[32\] = "";

char c_arg\[32\] = "";

opterr = 0; /\* Turn off error messages by getopt(). \*/

while ( TRUE ) {

/\* Call getopt, passing argc and argv and the options string. \*/

ch = getopt(argc, argv, options);

/\* It returns -1 when it finds no more options. \*/

if ( -1 == ch )

break;

switch ( ch ) {

case 'h': /\* h is a switch (no arg). \*/

opt_h = TRUE; break;

case 'b': /\* b has an optional argument. \*/

opt_b = TRUE; if ( 0 != optarg )

strcpy(b_arg, optarg); break;

case 'c': /\* c has a required argument. \*/

opt_c = TRUE;

strcpy(c_arg, optarg); break;

case '1': /\* 1 is a switch (no arg). \*/

opt_1 = TRUE; break;

case '?':

printf("Found invalid option %c\n", optopt); break;

case ':':

printf("Missing required argument\n"); break;

default:

printf("?? getopt returned character code 0%o ??\n", ch);

}

}

/\* Finished processing the command line \*/

/\* Process the options - in this case, just print what was found. \*/

printf("Options found:\n");

if ( opt_h ) printf("-h \n");

if ( opt_1 ) printf("-1 \n");

if ( opt_b ) {

printf("-b ");

if ( strlen(b_arg) \> 0 )

printf("with argument %s\n", b_arg);

else

printf("with no argument \n");

}

if ( opt_c )

printf("-c with argument %s\n", c_arg);

/\* optind is the index of the 1st non-option word in the argv\[\] array. \*/

/\* If optind \< argc, there is at least one word that is not an option. \*/

if ( optind \< argc ) {

printf("non-option ARGV-elements:\n");

while ( optind \< argc )

printf("%s ", argv\[optind++\]);

printf("\n");

}


}

*Listing 2-11: A program that parses the command line for options and arguments* Listing 2-

11 models the usual way to process the options, using a loop and an embedded switch statement in which the fact of finding an option is recorded in a variable associated with that option. This variable is checked later in the program.

For example, if the -h option is a flag to indicate whether to print a help message, the switch code fragment would look like this: switch ( ch )

{ *--snip--* case 'h': print_help = TRUE; break;

Then somewhere in the main program’s body, we’d put code such as: if (

print_help ) print_help_message(); /\* Print the help information. \*/

If the program allows the same option to be present multiple times on

the command line with different arguments, the switch case for that

option needs to store the successive arguments in a suitable data

structure.

*Extracting Numbers from Strings*

Command line arguments and environment values are stored as strings,

even if they represent numbers. When a program receives strings that

are actually numeric, it needs to parse those strings to obtain the

numbers they represent. Fortunately, various library functions can do

this, although some are preferable to others.

Two different classes of functions convert strings to numbers: atoi()

and its cousins atof() and so on, as well as strtol() and its cousins. Table

2-1 summarizes the functions available in a typical Linux system.

Table 2-1: String to Number Conversion Functions

Function

Result type

Remarks

Function

Result type

Remarks

atoi(const char \*nptr)

int

No error

checking

atol(const char \*nptr)

long int

No error

checking

atoll(const char \*nptr)

long long int

No error

checking

atof(const char \*nptr)

double

No error

checking

strtol(const char \*nptr, char \*\*endptr,

long int


int base)

error

strtoll(const char \*nptr, char

long long int


\*\*endptr, int base)

error

strtof(const char \*nptr, char \*\*endptr)

float


error

strtod(const char \*nptr, char \*\*endptr)

double


error

strtold(const char \*nptr, char

long double


\*\*endptr)

error

strtoul(const char \*nptr, char

unsigned long int


\*\*endptr, int base)

error

strtoull(const char \*nptr, char

unsigned long


\*\*endptr, int base)

long int

error

The functions whose names are of the form ato\* have some

disadvantages. One is that they don’t set the errno variable if errors occur, returning 0 instead, which makes it hard to distinguish between a numeric 0 and an error. Second, they don’t do much error checking.

Finally, they can be used only for base 10 numerals, which is not a major limitation, since that’s the base we use most often. If you look at their

man pages, you’ll see that their use is discouraged. In spite of this, I’ll occasionally code with atoi() when I’m writing software for my own use that will be used only a few times and I don’t need to error-check—what people commonly call *throw-away code*.

It’s a better idea to learn how to use strtol() and the related functions because they’re more general and provide robust error-checking. I’ll

describe how to use strtol(); learning how to use the related functions that return numbers of types unsigned long, long long, unsigned long long, and so on is similar.

The synopsis of the strtol() function is as follows: \#include

\<stdlib.h\> long strtol(const char \*nptr, char \*\*endptr, int base); The first parameter (nptr) is a pointer to the string to be converted.

If the second parameter (endptr) isn’t NULL, then after the call, strtol() will store the address of the first invalid character it finds into \*endptr. The last parameter (base) is the base of the numeral, which can be any base from 2 to 36. If you expect base-10 numerals, set the base to 0. Listing 2-

12 shows a simple program, *strtol_demo.c*, that converts base-10

numerals.

*strtol_demo.c*

\#include \<stdlib.h\>


\#include \<errno.h\>


{

char \*endptr;

long val;

if ( argc \< 2 ) {

fprintf(stderr, "Usage: %s str \n", argv\[0\]);

exit(EXIT_FAILURE);

}

➊ errno = 0; /\* To distinguish success/failure after call \*/

val = strtol(argv\[1\], ➋ &endptr, 0);

/\* Check for various possible errors. \*/

➌ if ( errno != 0 ) {

perror("strtol");

exit(EXIT_FAILURE);

}

/\* errno == 0 \*/ ➍ if ( endptr == argv\[1\] ) {

/\* The first invalid char is the first char of the string. \*/

fprintf(stderr, "No digits were found\n");

exit(EXIT_FAILURE);

}

➎ if ( \*endptr != '\0' )

/\* There are non-number characters following the number,

which we can call an error or not, depending. \*/

printf("Characters following the number: \\%s\\\n", endptr);

/\* If we reached here, strtol() successfully parsed a number. \*/

printf("strtol() returned %ld\n", val);

exit(EXIT_SUCCESS);

}

*Listing 2-12: A program that calls* *strtol()* *to convert its first argument to a number* Let’s study some of the details in Listing 2-12. We set errno to 0 ➊ so that after the call, if it’s nonzero we’ll know that an error occurred. We need to do this because the actual number might be 0, implying that we can’t interpret a return value of 0 as an error.

We pass the address of endptr, not endptr itself ➋, to strtol(). After the call, endptr contains the address of the first invalid character. We also check whether errno is 0 ➌ when strtol() returns. If it isn’t 0, a conversion error occurred, and in this case we exit the program because the number might be out of range and we don’t want to attempt to store it.

If errno is 0 ➍, there was no error, but it’s possible that the string was not a number. If endptr points to the start of the string, it wasn’t a number.

Finally, we check for a different possibility ➎. It’s possible that the string is something like 1234abc, which has valid digits followed by

nondigits. If endptr doesn’t point to the end of the string, the string must have nondigits. It’s best in this case to let the calling program know this.

If we run this program with several different types of input, we’ll see how it behaves. Assume the executable is named strtol_demo: \$

**./strtol_demo 100000000000000** strtol() returned 100000000000000 \$

**./strtol_demo -817238172** strtol() returned -817238172 \$

**./strtol_demo +871237abns** Characters following the number: "abns"

strtol() returned 871237 \$ **./strtol_demo kjasdksd** No digits were found \$ **./strtol_demo 71238172381273687236817236** strtol:

Numerical result out of range \$ **./strtol_demo 032** strtol() returned 26

The very last run is revealing. The leading 0 is interpreted by strtol() as an indicator that the number is octal.

Because we’ll need to convert strings to numbers frequently, in

Chapter 3 we’ll develop a few functions based on the strto\* functions that we’ll use in subsequent chapters of the book.

Before leaving this topic, however, let’s consider another very simple way to extract the numeric value of a string using the sscanf() function.

It’s essentially the same as scanf() except it reads from a C string passed to it in its first parameter instead of from the standard input stream. Its synopsis is: \#include \<stdio.h\> int sscanf(const char \*str, const char

\*format, . .);

Like scanf(), its return value is the number of items successfully read and converted to the format specified. By giving it the %d format

specifier and passing the address of an integer as the second argument, we can obtain the integer value of the string.

Listing 2-13 shows how to do this.

*str2int.c*


\#include \<stdlib.h\>

\#include \<string.h\>


{

int x;

if ( argc \< 2 ) {

fprintf(stderr,"usage: %s \<number\>\n", argv\[0\]);

exit(1);

}

sscanf(argv\[1\], " %d", &x);

printf("The number is %d\n", x);


}

*Listing 2-13: A program that uses* *sscanf()* *to convert strings to numbers* This program calls sscanf() just once. I wouldn’t recommend using scanf() when your program needs to convert thousands of strings to numbers, because it is slower than the other methods I described. Also, like atoi(), it doesn’t handle errors as robustly as strtol().

Summary

System programs make requests to the kernel for services that require

kernel-level privileges through the use of system calls. System calls are calls to functions implemented within the kernel.

A library is a file that bundles together the compiled object code

from multiple functions so that they can be called from other programs.

Some libraries are static and are linked to a program as the last stage of compilation, and others are dynamic (or shared) and are linked during

program execution. Using dynamic libraries makes executable files

smaller and makes them load faster. It also saves memory and makes

recompiling programs unnecessary if the libraries are updated without

changes to their interfaces. Several command line tools can inspect

libraries and executable files.

The C Standard Library contains a wide range of functions. Some of

its functions make system calls, and others work only in user space. Both library functions and system calls have very specific ways of returning error information. Any program that you write must handle errors from

these functions.

Because different Unix systems follow standards to varying degrees,

making programs portable can be challenging. Using feature test

macros is a well-supported method to improve the portability of your

programs.

Internationalization is an aspect of programming that is not covered in a typical programming curriculum, but it’s important because

programs might run in a variety of different cultural environments.

Modern programs should be designed to respond to its user’s locale

settings. In the next chapter, we’ll see how to do this.

This chapter showed how to process the command line, extracting

the arguments and options to commands; how to access environment

variables; and how to parse strings to extract their numeric value when they represent numbers. It’s laid the foundation for the rest of the book.

Starting in the next chapter, we’ll apply much of what we’ve just

covered.

Exercises

1\. This exercise is open ended. Navigate to the */usr/bin* directory on the host you’re using. There, run the ldd command on every

executable, and examine the sets of dynamic libraries to which each

executable is linked. Which libraries are used the most? Which

commands link to the most libraries?

2\. The *printargs2.c* program in Listing 2-5 used an integer to iterate through the argv\[\] array. Write a version of it that does not print

the argument numbers and does not use any local variables.

3\. Write a program that prints out the words it receives on the

command line in reverse order, one per line.

4\. Write a program that prints out the words it receives on the

command line sorted by their lengths, from shortest to longest,

one per line. Words of the same length can be in any order.

5\. The program *perror_demo.c* in Listing 2-3 purposely used an array of characters too small for the hostname. Read the man page that

describes the *limits.h* header file, find the system constant that specifies the maximum hostname length, and rewrite the program

so that this error cannot occur.

6. The seq command prints out sequences of numbers. In the simplest case, seq *num1 num2* prints every number from *num1* through *num2*. Write a program that implements this simple form of the command. If

any arguments are missing, if they are not two integers such that

the first is less than or equal to the second, it should print an error message.

![](/tmp/audit/iter1/epubregen/system-programming-in-linux/media/index-171_1.jpg)