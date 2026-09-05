**Chapter 6. Poetry in Motion: Runtime Data Structures**

*\#41: The Enterprise meets God, and it's a child, a computer, or a C program.*

*\#42: While boldly on the way to where only a few people have been recently, the Enterprise computer* *is subverted by a powerful alien life-form, shaped amazingly like a human.*

*\#43: Trekkers encounter hostile computer intelligence, and abuse philosophy or logic to cause it to* *self-destruct.*

*\#44: Trekkers encounter a civilization that bears an uncanny resemblance to a previous Earth society.*

*\#45: Disease causes one or more crew members to age rapidly. Also seen in reverse: key crew* *members regress to childhood, physically, mentally, or both.*

*\#46: An alien being becomes embedded in body of a Trekker and takes over. Still waiting to see this* *one in reverse…*

*\#47: The captain violates the Prime Directive, then either endangers the Enterprise or has an affair* *with an attractive alien, or both, while trying to rectify matters.*

*\#48: The captain eventually brings peace to two primitive warring societies ("we come in peace, shoot* *to kill") on a world that is strangely reminiscent of Earth.*

—Professor Snopes' *Book of Canonical Star Trek Plots, and Delicious Yam Recipes* a.out and a.out folklore…segments…what the OS does with your a.out…what the C runtime does with your a.out…what happens when a function gets called: the procedure activation record…helpful C tools…some light relief—Princeton programming puzzle

One of the classic dichotomies in programming language theory is the distinction between code and data. Some languages, like LISP, unite these elements; others, like C, usually maintain the division.

The Internet worm, described in Chapter 2, was hard to understand because its method of attack was based on transforming data into code. The distinction between code and data can also be analyzed as a division between compiletime and runtime. Most of the work of a compiler is concerned with translating code; most of the necessary data storage management happens at runtime. This chapter describes the hidden data structures of the runtime system.

There are three reasons to learn about the runtime system:

• It will help you tune code for the highest performance.

• It will help you understand more advanced material.

• It will help you diagnose problems more easily, when you run into trouble.

**a.out and a.out Folklore**

Did you ever wonder how the name "a.out" was chosen? Having all output files default to the same name, a.out, can be inconvenient, as you might forget which source file it came from, and you will overwrite it on the next compilation of any file. Most people have a vague impression that the name originated with traditional UNIX brevity, and "a" is the first letter of the alphabet, so it's the first letter you hit for a new filename. Actually, it's nothing to do with any of this.

It's an abbreviation for "assembler output"! The old BSD manpage even hints at this: NAME

a.out - assembler and link editor output format

One problem: it's not assembler output—it's linker output!

The "assembler output" name is purely historical. On the PDP-7 (even before the B language), there was no linker. Programs were created by assembling the catenation of all the source files, and the resulting assembler output went in a.out. The convention stuck around for the final output even after a linker was finally written for the PDP-11; the name had come to mean "a new program ready to try to execute." So the a.out default name is an example in UNIX of "no good reason, but we always did it that way"!

Executable files on UNIX are also labelled in a special way so that systems can recognize their special properties. It's a common programming technique to label or tag important data with a unique number identifying what it is. The labelling number is often termed a "magic" number; it confers the mysterious power of being able to identify a collection of random bits. For example, the superblock (the fundamental data structure in a UNIX filesystem) is tagged with the following magic number:

\#define FS_MAGIC 0x011954

That strange-looking number isn't wholly random. It's Kirk McKusick's birthday. Kirk, the implementor of the Berkeley fast file system, wrote this code in the late 1970's, but magic numbers are so useful that this one is still in the source base today (in file sys/fs/ufs_fs.h). Not only does it promote file system reliability, but also, every file systems hacker now knows to send Kirk a birthday card for January 19.

There's a similar magic number for a.out files. Prior to AT&T's System V release of UNIX, an a.out was identified by the magic number 0407 at offset zero. And how was 0407 selected as the "magic number" identifying a UNIX object file? It's the opcode for an unconditional branch instruction (relative to the program counter) on a PDP-11! If you're running on a PDP-11 or VAX in compatibility mode, you can just start executing at the first word of the file, and the magic number (located there) will branch you past the a.out header and into the first real executable instruction of the program. The PDP-11 was the canonical UNIX machine at the time when a.out needed a magic number. Under SVr4, executables are marked by the first byte of a file containing hex 7F followed by the letters "ELF" at bytes 2, 3, and 4 of the file.

**Segments**

Object files and executables come in one of several different formats. On most SVr4 implementations the format is called ELF (originally "Extensible Linker Format", now "Executable and Linking Format"). On other systems, the executable format is COFF (Common Object-File Format). And on BSD UNIX (rather like the Buddha having Buddha-nature), a.out files have a.out format. You can find out more about the format used on a UNIX system by typing man a.out and reading the manpage.

All these different formats have the concept of segments in common. There will be lots more about segments later, but as far as object files are concerned, they are simply areas within a binary file where all the information of a particular type (e.g., symbol table entries) is kept. The term *section* is also widely used; sections are the smallest unit of organization in an ELF file. A segment typically contains several sections.

Don't confuse the concept of segment on UNIX with the concept of segment on the Intel x86

architecture.

• A segment on UNIX is *a section of related stuff in a binary*.

• A segment in the Intel x86 memory model is *the result of a design in which (for compatibility* *reasons) the address space is not uniform, but is divided into 64-Kbyte ranges known as* *segments.*

The topic of segments on the Intel x86 architecture really deserves a chapter of its own. \[1\] For the remainder of this book, the term segment has the UNIX meaning unless otherwise stated.

\[1\] And it pretty near has one, too! See next chapter.

When you run size on an executable, it tells you the size of three segments known as text, data, and bss in the file:

% echo; echo "text data bss total" ; size a.out

text data bss total

1548 + 4236 + 4004 = 9788

Size doesn't print the headings, so use echo to generate them.

Another way to examine the contents of an executable file is to use the nm or dump utilities. Compile the source below, and run nm on the resulting a.out.

char pear\[40\];

static double peach;

int mango = 13;

static long melon = 2001;

main () {

int i=3, j, \*ip;

ip=malloc(sizeof(i));

pear\[5\] = i;

peach = 2.0\*mango;

}

Excerpts from running nm are shown below (minor editing changes have been made to the output to make it more accessible):

% nm -sx a.out

Symbols from a.out:

\[Index\] Value Size Type Bind Segment Name

...

\[29\] \|0x00020790\|0x00000008\|OBJT \|LOCL \|.bss peach

\[42\] \|0x0002079c\|0x00000028\|OBJT \|GLOB \|.bss pear

\[43\] \|0x000206f4\|0x00000004\|OBJT \|GLOB \|.data mango

\[30\] \|0x000206f8\|0x00000004\|OBJT \|LOCL \|.data melon

\[36\] \|0x00010628\|0x00000058\|FUNC \|GLOB \|.text main

\[50\] \|0x000206e4\|0x00000038\|FUNC \|GLOB \|UNDEF malloc

...

Figure 6-1 shows what the compiler/linker puts in each segment:

***Figure 6-1. What Kinds of C Statements End Up in Which Segments?***

![Image 62](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-123_1.png)

![Image 63](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-123_2.png)

The BSS segment gets its name from abbreviating "Block Started by Symbol"—a pseudo-op from the old IBM 704 assembler, carried over into UNIX, and there ever since. Some people like to remember it as "Better Save Space." Since the BSS segment only holds variables that don't have any value yet, it doesn't actually need to store the image of these variables. The size that BSS will require at runtime is recorded in the object file, but BSS (unlike the data segment) doesn't take up any actual space in the object file.

**Programming Challenge**

**Look at the Segments in an Executable**

1\. Compile the "hello world" program, run ls -l on the executable to get its overall size, and run size to get the sizes of the segments within it.

2\. Add the declaration of a global array of 1000 ints, recompile, and repeat the measurements. Notice the differences.

3\. Now add an initial value in the declaration of the array (remember, C doesn't force you to provide a value for every element of an array in an initializer). This will move the array from the BSS segment to the data segment. Repeat the measurements. Notice the differences.

4\. Now add the declaration of a big array local to a function. Declare a second big local array with an initializer. Repeat the measurements. Is data defined locally inside a function stored in the executable? Does it make any difference if it's initialized or not?

5\. What changes occur to file and segment sizes if you compile for debugging? For maximum optimization?

![Image 64](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-124_1.png)

Analyze the results of the above "Programming Challenge" to convince yourself that:

• the data segment is kept in the object file

• the BSS segment isn't kept in the object file (except for a note of its runtime size requirements)

• the text segment is the one most affected by optimization

• the a.out file size is affected by compiling for debugging, but the segments are not.

**What the OS Does with Your a.out**

Now we see why the a.out file is organized into segments. The segments conveniently map into objects that the runtime linker can load directly! The loader just takes each segment image in the file and puts it directly into memory. The segments essentially become memory areas of an executing program, each with a dedicated purpose. This is shown in Figure 6-2.

***Figure 6-2. How the Segments of an Executable are Laid Out in Memory***

The text segment contains the program instructions. The loader copies that directly from the file into memory (typically with the mmap() system call), and need never worry about it again, as program text typically never changes in value nor size. Some operating systems and linkers can even assign appropriate permissions to the different sections in segments, for example, text can be made read-and-execute-only, some data can be made read-write-no-execute, other data made read-only, and so on.

The data segment contains the initialized global and static variables, complete with their assigned values. The size of the BSS segment is then obtained from the executable, and the loader obtains a

block of this size, putting it right after the data segment. This block is zeroed out as it is put in the program's address space. The entire stretch of data and BSS is usually just referred to jointly as the data segment at this point. This is because a segment, in OS memory management terms, is simply a range of consecutive virtual addresses, so adjacent segments are coalesced. The data segment is typically the largest segment in any process.

The diagram shows the memory layout of a program that is about to begin execution. We still need some memory space for local variables, temporaries, parameter passing in function calls, and the like.

A stack segment is allocated for this. We also need heap space for dynamically allocated memory.

This will be set up on demand, as soon as the first call to malloc() is made.

Note that the lowest part of the virtual address space is unmapped; that is, it is within the address space of the process, but has not been assigned to a physical address, so any references to it will be illegal. This is typically a few Kbytes of memory from address zero up. It catches references through null pointers, and pointers that have small integer values.

When you take shared libraries into account, a process address space appears, as shown in Figure 6-3.

***Figure 6-3. Virtual Address Space Layout, Showing Shared Libraries***

![Image 65](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-126_1.png)

**What the C Runtime Does with Your a.out**

Now we come to the fine detail of how C organizes the data structures of a running program. There are a number of runtime data structures: the stack, activation records, data, heap, and so on. We will look at each of these in turn, and analyze the C features that they support.

**The Stack Segment**

The stack segment contains a single data structure, the stack. A classic computer science object, the stack is a dynamic area of memory that implements a last-in-first-out queue, somewhat similar to a stack of plates in a cafeteria. The classic definition of a stack says that it can have any number of plates on it, but the only valid operations are to add or remove a plate from the top of the stack. That is, values can be pushed onto the stack, and retrieved by popping them off. A push operation makes the stack grow larger, and a pop removes a value from it.

Compiler-writers take a slightly more flexible approach. We add or delete plates only from the top, but we can also change values that are on a plate in the middle of the stack. A function can access

![Image 66](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-127_1.png)

variables local to its calling function via parameters or global pointers. The runtime maintains a pointer, often in a register and usually called sp, that indicates the current top of the stack. The stack segment has three major uses, two concerned with functions and one with expression evaluation:

• The stack provides the storage area for local variables declared inside functions. These are known as "automatic variables" in C terminology.

• The stack stores the "housekeeping" information involved when a function call is made. This housekeeping information is known as a stack frame or, more generally, a procedure activation record. We'll describe it in detail a little later, but for now be aware that it includes the address from which the function was called (i.e., where to jump back to when the called function is finished), any parameters that won't fit into registers, and saved values of registers.

• The stack also works as a scratch-pad area—every time the program needs some temporary storage, perhaps to evaluate a lengthy arithmetic expression, it can push partial results onto the stack, popping them when needed. Storage obtained by the alloca() call is also on the stack. Don't use alloca() to get memory that you want to outlive the routine that allocates it. (It will be overwritten by the next function call.) A stack would not be needed except for recursive calls. If not for these, a fixed amount of space for local variables, parameters, and return addresses would be known at compiletime and could be allocated in the BSS. Early implementations of BASIC, COBOL, and FORTRAN did not permit recursive calls of functions, so they did not need a dynamic stack at runtime. Allowing recursive calls means that we must find a way to permit mul-tiple instances of local variables to be in existence at one time, though only the most recently created will be accessed — the classic specification of a stack.

**Programming Challenge**

**Stack Hack**

Compile and run this small test program to discover the approximate location of the stack on your system:

\#include \<stdio.h\>

main()

{

int i;

printf("The stack top is near %p\n", &i);

return 0;

}

Discover the data and text segment locations, and the heap within the data segment, by declaring variables that will be placed in those segments and printing their addresses. Make

![Image 67](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-128_1.png)

the stack grow by calling a function, and declaring some large local arrays.

What's the address of the top of the stack now?

The stack may be located at a different address on different architectures and for different OS

revisions. Although we talk about the top of the stack, the stack grows downwards on most processors, towards memory addresses with lower values.

**What Happens When a Function Gets Called: The Procedure**

**Activation Record**

This section describes how the C runtime manages the program within its own address space. Actually, the runtime routines for C are remarkably few and lightweight. In contrast to, say, C++ or Ada, if a C

program wants some service such as dynamic storage allocation, it usually has to ask for it explicitly.

This makes C a very efficient language, but it does place an extra burden on the programmer.

One of the services that is provided automatically is keeping track of the call chain—which routines have called which others, and where control will pass back to, on the next "return" statement. The classic mechanism that takes care of this is the procedure activation record on the stack. There will be a procedure activation record (or its equivalent) for each call statement executed. The procedure activation record is a data structure that sup-ports an invocation of a procedure, and also records everything needed to get back to where you came from before the call. (See Figure 6-4.)

***Figure 6-4. A Canonical Procedure Activation Record***

The description of the contents of activation records is illustrative. The exact structure will vary from implementation to implementation. The order of the fields may be quite different. There may be an area for saving register values before making the call. The include file,

/usr/include/sys/frame.h, shows how a stack frame looks on your UNIX system. On SPARC, a stack frame is large—several dozen words in size—because it provides room to save register windows. On the x86 architecture, the frame is somewhat smaller. The runtime maintains a

![Image 68](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-129_1.png)

pointer, often in a register and usually called fp, which indicates the active stack frame. This will be the stack frame nearest to or at the top of the stack.

**Software Dogma**

**Astonishing C Fact!**

Most modern algorithmic languages allow functions (as well as data) to be defined inside functions. C does not allow functions to be nested this way. All functions in C are at the top lexical level.

This restriction slightly simplifies C implementations. In languages like Pascal, Ada, Modula-2, PL/I, or Algol-60, which do allow lexically nested procedures, an activation record will typically contain a pointer to the activation record of its enclosing function. This pointer is termed a *static link,* \[1\] and it allows the nested procedure to access the stack frame of the enclosing procedure, and hence the data local to the enclosing procedure. Remember that there may be several invocations of an enclosing procedure active at once. The static link in the nested procedure's activation record will point to the appropriate stack frame, allowing the correct instances of local data to be addressed.

This type of access (a reference to a data item defined in a lexically enclosing scope) is known as an *uplevel reference*. The static link (pointing to the stack frame of the lexically enclosing procedure determined at compiletime) is so named because it contrasts with the dynamic link of the frame pointer chain (pointing to the stack frame of the immediately previous procedure invocation at runtime).

In Sun's Pascal compiler, the static link is treated as an additional hidden parameter, passed at the end of the argument list when needed. This allows Pascal routines to have the same activation record, and thus to use the same code generator, and to work with C routines. C

itself does not allow nested functions; therefore, it does not have uplevel references to data in them, and thus does not need a static link in its activation records. Some people are urging that C++ should be given the ability to have nested functions.

\[1\] Don't, for God's sake, confuse the *static link* in a procedure activation record, which permits uplevel references to local data in a lexically enclosing procedure, with a *static link* of the previous chapter that describes the obsolete method of binding a copy of all the libraries into an executable. In the previous chapter, *static* meant "done at compiletime". Here, it means "referring to the lexical layout of the program".

The code example below will be used to show the activation records on the stack at various points in execution. This is a hard concept to represent in a book, because we have to deal with the dynamic flow of control rather than the static code that a listing shows. Admittedly, this is difficult to follow, but as Wendy Kaminer remarked in her classic psy-chological text, *I'm Dysfunctional; You're* *Dysfunctional*, only people who die very young learn all they really need to know in kindergarten.

1 a (int i) {

![Image 69](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-130_1.png)

2 if (i\>0)

3 a(--i);

4 else

5 printf("i has reached zero ");

6 return;

7 }

8

9 main(){

10 a(1);

11 }

If we compile and run the above program, the flow of control is shown in Figure 6-5. Each dashed box shows a fragment of source that makes a function call. The statements executed are shown in bold print. As control passes from one function to another, the new state of the stack is shown underneath.

Execution starts at main, and the stack grows downwards.

***Figure Figure6-5. An Activation Record is Created at Runtime for Each Function Call***

Compiler-writers will try to speed up programs by not storing information that will not be used. Other optimizations include keeping information in registers instead of on the stack, not pushing a complete stack frame for a leaf function (a function that doesn't make any calls itself), and making the callee responsible for saving registers, rather than the caller. The "pointer to previous frame" within each frame simplifies the task of popping the stack back to the previous record when the current function returns.

**Programming Challenge**

![Image 70](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-131_1.png)

**The Stack Frame**

1\. Manually trace the flow of control in the above program, and fill in the stack frames at each call statement. For each return address, use the line number to which it will go back.

2\. Compile the program for real, and run it under the debugger. Look at the additions to the stack when a function has been called. Compare with your desk checked results to work out exactly what a stack frame looks like on your system.

Remember that compiler-writers will try to place as much of an activation record in registers as possible (because it's faster), so some of this may not be visible on the stack.

Refer to the frame.h file to see the layout of a stack frame.

**The auto and static keywords**

The description of how the stack implements function calling also explains why it doesn't work to return a pointer to a local automatic variable from a function, like this: char \* favorite_fruit () {

char deciduous \[\] = "apple";

return deciduous;

}

The automatic variable deciduous is allocated on the stack when the function is entered; after the function is exited, the variable no longer exists, and the stack space can be overwritten at any time.

Pointers that have lost their validity in this way (by referencing something that is no longer live) are known as "dangling pointers"—they don't reference anything useful, just kind of dangle in space. If you need to return a pointer to something defined in a function, then define the thing as static.

This will ensure that space for the variable is allocated in the data segment instead of on the stack. The lifetime of the variable is thus the lifetime of the program, and as a side effect it retains its value even after the function that defines it exits. That value will still be available when the function is next entered.

The storage class specifier auto is never needed. It is mostly meaningful to a compiler-writer making an entry in a symbol table—it says "this storage is automatically allocated on entering the block" (as opposed to statically allocated at compiletime, or dynamically allocated on the heap). Auto is pretty much meaningless to all other programmers, since it can only be used inside a function, but data declarations in a function have this attribute by default. The only use we have ever found for the auto keyword is to make your declarations line up neatly, like this: register int filbert;

auto int almond;

static int hazel;

instead of:

register int filbert;

int almond;

static int hazel;

**A Stack Frame Might Not Be on the Stack**

Although we talk about a "stack frame" being "pushed on the stack," an activation record need not be on the stack. It's actually faster and better to keep as much as possible of the activation record in registers. The SPARC architecture takes this to the limit with a concept called "register windows" in which the chip has a set of registers solely dedicated to holding parameters in procedure activation records. Empty stack frames are still pushed for each call; if the call chain goes so deep that you run out of register windows, the registers are reclaimed by spilling them to the frame space already reserved on the stack.

Some languages, such as Xerox PARC's Mesa and Cedar, have activation records allocated as linked lists in the heap. Activation records for recursive procedures were also heap-allocated for the first PL/I implementations (leading to criticism of slow performance, because the stack is usually a much faster place from which to acquire memory).

**Threads of Control**

It should now be clear how different threads of control (i.e., what used to be called "lightweight processes") can be supported within a process. Simply have a different stack dedicated to each thread of control. If a thread calls foo(), which calls bar(), which calls baz(), while the main program is executing other routines, each needs a stack of its own to keep track of where each is. Each thread gets a stack of 1Mb (grown as needed) and a page of red zone betweeen each thread's stack. Threads are a very powerful programming paradigm, which provide a performance advantage even on a uniprocessor. However, this is a book on C, not on threads; you can and should seek out more details on threads.

**setjmp and longjmp**

We can also mention what setjmp() and longjmp() do, since they are implemented by manipulating activation records. Many novice programmers do not know about this powerful mechanism, since it's a feature unique to C. They partially compensate for C's limited branching ability, and they work in pairs like this:

• setjmp(jmp_buf j) must be called first. It says *use the variable* j *to remember where* *you are now. Return 0 from the call*.

• longjmp(jmp_buf j,int i) can then be called. It says *go back to the place that* *the* j *is remembering*. *Make it look like you're returning from the original* setjmp(), *but* *return the value of* i *so the code can tell when you actually got back here via* longjmp().

Phew!

• The contents of the j are destroyed when it is used in a longjmp().

Setjmp saves a copy of the program counter and the current pointer to the top of the stack. This saves some initial values, if you like. Then longjmp restores these values, effectively transferring control and resetting the state back to where you were when you did the save. It's termed "unwinding the stack," because you unroll activation records from the stack until you get to the saved one. Although it causes a branch, longjmp differs from a goto in that:

• A goto can't jump out of the current function in C (that's why this is a "longjmp"— you can jump a long way away, even to a function in a different file).

• You can only longjmp back to somewhere you have already been, where you did a setjmp, and that still has a live activation record. In this respect, setjmp is more like a "come from"

statement than a "go to". Longjmp takes an additional integer argument that is passed back, and lets you figure out whether you got here from longjmp or from carrying on from the previous statement.

The following code shows an example of setjmp() and longjmp().

\#include \<setjmp.h\>

jmp_buf buf;

\#include \<setjmp.h\>

banana() {

printf("in banana()\n");

longjmp(buf, 1);

/\*NOTREACHED\*/

printf("you'll never see this, because I longjmp'd");

}

main()

{

if (setjmp(buf))

printf("back in main\n");

else {

printf("first time through\n");

banana();

}

}

The resulting output is:

% a.out

first time through

in banana()

back in main

![Image 71](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-134_1.png)

Point to watch: the only reliable way to ensure that a local variable retains the value that it had at the time of the longjmp is to declare it volatile. (This is for variables whose value changes between the execution of setjmp and the return of longjmp.)

A setjmp/longjmp is most useful for error recovery. As long as you haven't returned from the function yet, if you discover a unrecoverable error, you can transfer control back to the main input loop and start again from there. Some people use setjmp/longjmp to return from a chain of umpteen functions at once. Others use them to shield potentially dangerous code, for example, when dereferencing a suspicious pointer as shown in the following example.

switch(setjmp(jbuf)) {

case 0:

apple = \*suspicious;

break;

case 1:

printf("suspicious is indeed a bad pointer\n");

break;

default:

die("unexpected value returned by setjmp");

}

This needs a handler for the segmentation violation signal, which will do the corresponding longjmp(jbuf,1) as explained in the next chapter. Setjmp and longjmp have mutated into the more general exception routines "catch" and "throw" in C++.

**Programming Challenge**

**Jump to It!**

Take the source of a program you have already written and add setjmp/longjmp to it, so that on receiving some particular input it will start over again.

The header file \<setjmp.h\> needs to be included in any source file that uses setjmp or longjmp.

Like goto's, setjmp/longjmp can make it hard to understand and debug a program. They are best avoided except in the specific situations described.

**The Stack Segment Under UNIX**

On UNIX, the stack grows automatically as a process needs more space. The programmer can just assume that the stack is indefinitely large. This is one of the many advantages that UNIX has over operating environments such as MS-DOS. UNIX implementations generally use some form of virtual memory. When you try to access beyond the space currently allocated for the stack, it generates a hardware interrupt known as a *page fault*. A page fault is processed in one of several ways, depending on whether the reference was valid or invalid.

The kernel normally handles a reference to an invalid address by sending the appropriate signal (segmentation fault probably) to the offending process. There's a small "red zone" region just below the top of the stack. A reference to there doesn't pass on a fault; instead, the operating system increases the stack segment size by a good chunk. Details vary among UNIX implementations, but in effect, additional virtual memory is mapped into the address space following the end of the current stack. The memory mapping hardware ensures you cannot access memory outside that which the operating system has allocated to your process.

**The Stack Segment Under MS-DOS**

In DOS, the stack size has to be specified as part of building the executable, and it cannot be grown at runtime. If you guess wrongly, and your stack gets bigger than the space you've allocated, you and your program both lose, and if you've turned checking on, you'll get the STACK OVERFLOW!

message. This can also appear at compiletime, when you've exceeded the limits of a segment.

Turbo C will tell you Segment overflowed maximum size *\<lsegname\>* if too much data or code had to be combined into a single segment. The limit is 64Kbytes, due to the 80x86

architecture.

The method of specifying stack size varies with the compiler you're using. With Microsoft compilers, the programmer can specify the stack size as a linker parameter. The STACK:nnnn

parameter tells the Microsoft linker to allow nnnn bytes for the stack.

The Borland compilers use a variable with a special name:

unsigned int \_stklen = 0x4000; /\* 16K stack \*/

Other compiler vendors have different methods for doing this. Check the programmer reference guides under "stack size" for the details.

**Helpful C Tools**

This section contains some lists (grouped by function) of helpful C tools you should know about, and what they do, in tables 6-1 through 6-4. We've already hinted at a few of these that help you peek inside a process or an a.out file. Some are specific to Sun OS. This section provides an easy-to-read summary of what each does, and where to find them. After studying the summary here, read the

manpage for each, and try running each on a couple of different a.out's—the "hello world" program, and a big program.

Go through these carefully—investing 15 minutes now in trying each one will save you hours later in solving a hard bug.

***Table 6-1. Tools to Examine Source***

**Tool Where**

**to**

**What It Does**

**Find It**

cb

Comes with

C program beautifier. Run your source through this filter to put it in a the compiler

standard layout and indentation. Comes from Berkeley.

indent

Does the same things cb does. Comes from AT & T.

cdecl This book

Unscrambles C declarations.

cflow Comes with

Prints the caller/callee relationships of a program.

the compiler

cscope Comes with

An interactive ASCII-based C program browser. We use it in the OS

the compiler

group to check the impact of changes to header files. It provides quick answers to questions like: "How many commands use libthread?" or "Who are all the kmem readers?"

ctags /usr/bin

Creates a tags file for use in vi editor. A tags file speeds up examining program source by maintaining a table of where most objects are located.

lint

Comes with

A C program checker.

the compiler

sccs


A source code version control system.

vgrind /usr/bin

A formatter for printing nice C listings.

Doctors can use x-rays, sonograms, arthroscopes, and exploratory operations to look inside their patients. These tools are the x-rays of the software world.

***Table 6-2. Tools to Examine Executables***

**Tool Where**

**to**

**What It Does**

**Find It**

dis


Object code disassembler

dump -


Prints dynamic linking information

Lv

ldd

/usr/bin

Prints the dynamic libraries this file needs

nm


Prints the symbol table of an object file

strings /usr/bin

Looks at the strings embedded in a binary. Useful for looking at the error messages a binary can generate, built-in file names, and (sometimes) symbol names or version and copyright information.

sum

/usr/bin

Prints checksum and block count for a file. An-swers questions like: "Are two executables the same version?" "Did the transmission go OK?"

***Table 6-3. Tools to Help with Debugging***

![Image 72](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-137_1.png)

**Tool Where**

**to**

**What It Does**

**Find It**

truss

/usr/bin

The SVr4 version of trace. This tool prints out the system calls that an executable makes. Use it to see what a binary is doing, and why it's stuck or failing. This is a great help!

ps

/usr/bin

Displays process characteristics.

ctrace

Comes with Modifies your source to print lines as they are executed. A great tool for compiler

small programs!

debugger Comes with Interactive debugger.

compiler

file

/usr/bin

Tells you what a file contains (e.g., executable, data, ASCII, shell script, archive, etc.).

***Table 6-4. Tools to Help with Performance Tuning***

**Tool Where**

**to**

**Find**

**What It Does**

**It**

collector Comes with

(SunOS only) Collects runtime performance data under the control debugger

of the debugger.

analyzer Comes with

(SunOS only) Analyzes collected performance data.

debugger

gprof


Displays the call-graph profile data (identifies the compute-

intensive functions).

prof


Displays the percentage of time spent in each routi ne.

tcov

Comes with

Displays a count of how often each statement is executed (identifies compiler

the compute-intensive loops within a function).

time

/usr/bin/time

Displays the total real and CPU time used by a program.

If you're working on the OS kernel, most of the runtime tools are not available to you, because the kernel does not run as a user process. The compiletime tools, like lint, work, but otherwise we have to use the stone knives and flint axes: putting nonrandom patterns in memory to see when they are overwritten (two favorites are the hex constants dead-beef and abadcafe), using printf 's or their equivalent, and logging trace information.

**Software Dogma**

**Debugging the Ker nel with grep**

A kernel "panics", or comes to an abrupt halt, when it detects a situation that "cannot" arise.

For example, it finds a null pointer when looking for some essential data. Since there is no way it can recover from this, the safest course is to halt the processor before more data disappears. To solve a panic, you must first consider what happened that could possibly

frighten an operating system.

The kernel development group at Sun had one obscure bug that was very difficult to track down. The symptom was that kernel memory was getting overwritten at random, occasionally panicking the system.

Two of our top engineers worked on this, and they noticed that it was always the 19th byte from the beginning of a memory block that was being creamed. This is an uncommon offset, unlike the more usual 2, 4, or 8 that occur everywhere. One of the engineers had a brainwave and used the offset to home in on the bug. He suggested they use the kernel debugger kadb to disassemble the kernel binary image (it took an hour!) into an ASCII file.

They then grepped the file, looking for "store" instructions where the operand indicated offset 19! One of these was almost guaranteed to be the instruction causing the corruption.

There were only eight of these, and they were all in the subsystem that dealt with process control. Now they were pretty sure *where* the problem was, and just needed to find out *what* it was. Further effort eventually yielded the cause: a race condition on a process control structure. This resulted in one thread marking the memory for return to the system before another thread had truly finished with it. Result: the kernel memory allocator then gave the memory away to someone else, but the process control code thought it still held it, and wrote into it, causing the otherwise impossible-to-find corruption!

Debugging an OS kernel with grep—what a concept. Sometimes even source tools can help solve runtime problems!

While on the subject of useful tools, Table 0-5 lists some ways to see exactly what the configuration of a Sun system is. However, none of these tools can help you unless you practice using them.

***Table 6-5. Tools to Help Identify Your Hardware***

**What It Identifies**

**Typical Output**

**How to Invoke It**

Kernel architecture

sun4c

/usr/kvm/arch -k

Any OS patches

no patches are installed

/usr/bin/showrev -p

applied

Various hard ware

lots

/usr/sbin/prtconf

things

CPU clock rate

40MHz processor

/usr/sbin/psrinfo -v

hostid 554176fe

/usr/ucb/hostid

Memory

32Mb

Displayed on power up

Serial number

4290302

Displayed on power up

ROM revision

2.4.1

Displayed on power up

Mounted disk

198Mb disk

/usr/bin/df -F ufs -k

Swap space

40Mb

/etc/swap -s

Ethernet address

8:0:20:f:8c:60

/usr/sbin/ifconfig -a

The ethernet address is built into the

machine

![Image 73](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-139_1.png)

IP address

le0=129.144.248.36

/usr/sbin/ifconfig -a

The IP address is built into the network

Floating-point

FPU's frequency appears to be 38.2 fpversion comes with the compiler hardware

MHz

**Some Light Relief—Programming Puzzles at CMU**

A few years ago, the Computer Science Department at Carnegie-Mellon University regularly ran a small programming contest for its incoming graduate students. The contest was intended to give the new researchers some hands-on experience with the department systems and let them demonstrate their star potential. CMU has a long and distinguished involvement with computers, stretching back to the pioneering days, so you'd typically expect some outstanding entries in a programming competition there.

The form of the contest varied from year to year, and in one particular year it was very simple.

Contestants had to read a file of numbers and print the average. There were only two rules: 1. The program had to run as fast as possible.

2\. The program had to be written in Pascal or C.

The rival programs were grouped together and submitted in batches by a faculty member. Students could submit as many entries as they wished; this encouraged the use of non-deterministic probabilistic algorithms (algorithms that would guess at certain characteristics of the data set and use the guess to obtain faster performance). The golden rule was that the program which ran in the shortest amount of time won the contest.

The graduate students duly retired to dark corners and started whacking their various programs. Most of them had three or four versions to enter and run. At this point, the reader is invited to guess the techniques that helped the programs run fast.

**Programming Challenge**

**How to Exceed the Speed Limit?**

Imagine that you have been given the task of writing a program to read a file of 10,000

numbers and calculate the average. Your program must run in the shortest amount of time.

What programming and compiler techniques will you use to achieve this?

Most people guess the biggest wins will come through code optimization, either explicitly in the code, or implicitly by using the correct compiler options. The standard code optimizations are techniques

like loop unrolling, in-line function expansion, common subexpression elimination, improved register allocation, omitting runtime checks on array bounds, loop-invariant code motion, operator strength reduction (turning exponen-tiation into multiplication, turning multiplication into bit-shifting and/or addition), and so on.

The data file contained about 10,000 numbers, so assuming it took a millisecond just to read and process each number (about par for the systems at the time), the fastest possible program would take about ten seconds.

The actual results were very surprising. The fastest program, as reported by the operating system, took minus three seconds. That's right—the winner ran in a negative amount of time! The next fastest apparently took just a few milliseconds, while the entry in third place came in just under the expected 10 seconds. Obviously, some devious programming had taken place, but what and how? A detailed scrutiny of the winning programs eventually supplied the answer.

The program that apparently ran backwards in time had taken advantage of the operating system. The programmer knew where the process control block was stored relative to the base of the stack. He crafted a pointer to access the process control block and overwrote the "CPU-time-used" field with a very high value. \[2\] The operating system wasn't expecting CPU times that large, and it misinterpreted the very large positive number as a negative number under the two's complement scheme.

\[2\] A flagrant abuse of the rules, ranking equal to the time Argentinian soccer ace Diego Maradona used his forearm to nudge the ball into the England net for the winning goal in the 1986 soccer World Cup.

The runner-up, whose program took just a few milliseconds, had been equally cunning in a different way. He had used the rules of the competition rather than exotic coding. He submitted two different entries. One entry read the numbers, calculated the answer in the normal way, and wrote the result to a file; the second entry spent most of its time asleep, but woke up briefly every few seconds and checked if the answer file existed. When it did, it printed it out. The second process only took a few milliseconds of total CPU time. Since contestants were allowed to submit multiple entries, the smaller time counted and put him in second place.

The programmer whose entry came in third, taking slightly less than the calculated minimum time, had the most elaborate scheme. He had worked out the optimized machine code instructions to solve the problem, and stored the instructions as an array of integers in his program. It was easy to overwrite a return address on the stack (as Bob Morris, Jr. later did with the Internet worm of 1988) and cause the program to jump into and start executing this array. These instructions solved the problem honestly in record time.

There was an uproar among the faculty when these stratagems were uncovered. Some of the staff were in favor of severely reprimanding the winners. A younger group of professors proposed instead awarding them an extra prize in recognition of their ingenuity. In the end, a compromise was reached.

No prizes were awarded, no punishments were handed down, and the results stuck. Sadly, the contest was a casualty of the strong feelings, and this incident marked the final year it was held.

**For Advanced Students Only**

A word to the wise: it's possible to embed assembler code in C source. This is usually only done for the most machine-specific things in the depths of the OS kernel, like setting specific registers on changing from supervisor mode to user mode. Here's how we plant a no-op (or other instruction) in a C function using a SunPro SPARCompiler:

banana() { asm("nop"); }

Here's how you embed assembly language instructions using Microsoft C on a PC: \_\_asm mov ah, 2

\_\_asm mov dl, 43h

You can also prefix the assembler code with the keyword "\_ \_asm". You can also use the keyword once, and put all the assembler code in a pair of braces, like this: \_\_asm {

mov ah, 2

mov dl, 43h

int 21h

}

Little checking is done for you, and it's easy to create programs that bomb out. But it's a good way to experiment with and learn the instruction set of a machine. Take a look at the SPARC architecture manual, the assembler manual (which mostly talks about syntax and directives), and a databook from one of the SPARC vendors, such as Cypress Semiconductor's "SPARC RISC User's Guide."