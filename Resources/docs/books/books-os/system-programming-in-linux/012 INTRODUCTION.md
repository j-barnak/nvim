INTRODUCTION

I designed this book to help you learn how to write system and utility programs on Linux. Much of it applies to other Unix systems as well.

Whether you’re a Unix/Linux user or computer science student who

wants to dive deeper into the Unix/Linux programming interface, or

you’ve been told by someone else that you’d benefit from learning more about it, or you’re just plain curious and ready to explore a new path, this book will guide you to that end. No matter how you arrived here,

I’m glad to have your ear, and I hope that I keep your interest through the journey.

What Will You Learn from This Book?

Unlike many other books on this subject, this one doesn’t require you to have any prior programming experience with Unix or Linux in

particular, and it doesn’t require you to be an expert programmer

already. It assumes that you know little to nothing about the Linux

programming interface, and it builds your knowledge and ability to

learn more, one small step at a time. If you flip through the book now and see material in later chapters that seems too advanced to

understand, don’t fret. By the time we get there, you should understand all of it easily. For the details about exactly what you need to know to

benefit from this book, see “What Should You Know to Understand This Book?” on page xxxii.

I had several different goals when I designed and wrote this book

that reflect the various ways that we interact with Unix/Linux:

To teach you how to write programs on and for the Unix operating

system, and Linux in particular

To improve your ability to work efficiently within a Unix/Linux

environment

To teach you how the Unix operating system is designed and

structured so that you have a deeper understanding of what

happens “under the hood,” so to speak

To give you an appreciation of the marvel and magic of Unix so

that you’ll want to learn more

These are pretty hefty objectives, and they may seem to be too much

to attain in a single book. To do so, the book is neither thorough nor comprehensive. It isn’t a reference book on everything Unix. It doesn’t cover every aspect of programming in the Unix environment, and it

doesn’t go deeply into each topic that it does cover.

Instead, it’s a hands-on tutorial, and it covers what I believe is

enough to give you a solid background and show you how you can learn

more about each topic on your own. It’s also conceptual, showing you

not just *what* various features do and how to use them but also *how* they work so that you understand *why* you need to do what you do and why something is not working the way you expected it to when things go

wrong.

How Will This Book Teach You?

I’ve written this book as if I, like you, know very little about the Unix programming interfaces, and we are going to learn about them together.

I don’t just tell you how this or that works. Instead, I share my thought processes as if I’m exploring new topics with you, and we both have to find the resources that explain these new topics. I follow this same

approach when developing programs in the book, sharing my thinking

about a program’s design and details in the course of taking it from

initial concept to executable code. I decided to take this approach

because, as a teacher, I believe that my first goal is to teach you a

method of learning.

In this sense, my approach tries to adhere to the principles

embodied in the well-known proverb often attributed to the Chinese

philosopher Lao Tzu, paraphrased as follows:

Give a person a fish and they will eat for a day. Teach a person to fish and they will eat for a lifetime.

I strongly believe in this teaching philosophy.

I make one exception to this strategy when, in the course of covering

a particular programming concept or interface, I decide that you ought to know more about the underlying operating system structures or

workings, and then I put on a different hat, becoming the

knowledgeable teacher and sharing what I know. At these times, I don’t pretend that I know nothing.

*Using Open Source Software*

The fact that Unix has been an open source operating system is

fundamental to the teaching method on which this book is based. Each

time I introduce a new topic, my strategy is to explain the underlying concepts, perhaps look at the design and structure of the relevant

interfaces, and then pick a command to implement. We’ll go through a

few iterations together to get it right, fixing problems and learning

about what did and didn’t work until we’re satisfied with the solution.

Then, after it’s all tidied up, we may sometimes look at fragments of actual Linux or GNU library implementations. None of this would be

possible with proprietary code.

*Presenting Different Perspectives*

When I present material about a particular subject, I often do so from three different perspectives, reflecting the roles that you might play at different times:

That of a nonprogramming user, because it presents the command-

level view of Unix. As a programmer, you need to understand how a

nonprogramming user will work with the code you develop.

That of a system programmer, in that it presents the information

needed to write system programs in a Unix/Linux system. When

developing new code, you need to become comfortable choosing

the best interfaces for your project.

That of a computer scientist, because it examines the internal

structure of the GNU/Linux operating system. Very often,

understanding the concrete representations and abstractions

employed by the operating system enables you to write more

efficient code.

I’ll usually begin by looking at a topic through the eyes of an

ordinary user and then switch to the eyes of a programmer. Sometimes,

before changing to the programmer’s view, I’ll explore the structures

and operating system concepts to appeal to the computer scientist in

you. Seeing the material from all of these perspectives can make you a better system programmer.

*Using Example Programs*

This book is predicated on a learning model in which you and I

investigate new components of the Unix/Linux programming interface

and then develop code based on them. To this end, I’ve written about

200 example programs to accompany the book. You can download all of

these programs in order to read and experiment with them. However, I

strongly believe that the best way to learn how to program is to write code. I encourage you to start by modifying those programs and then

writing programs like them from scratch. The more you do this, the

better and more efficient you’ll be at developing software on Linux

systems. See “Online Materials” on page xxxvii for details about how to obtain copies of the programs.

What Should You Know to Understand This Book?

I’ve tried to make the prerequisite background for the book minimal,

but this is a technically challenging subject. You should have the

following background to get the most out of this book:

You must be able to write programs in either C or C++ with ease.

Your level of experience should correspond to a year of

programming at the college level. For example, you should be

familiar with standard data structures such as stacks, lists, queues,

and trees. If you’re a Java programmer or a Python programmer,

you’ll be at a disadvantage because the interfaces in Unix are

written in C, and you’ll have to transition to C.

You should be comfortable enough working in the command line

in Unix to be able to perform routine tasks such as navigating

directories, listing their contents, and viewing and editing files.

You should know how to compile and build programs from the

command line.

*The Role of C in This Book*

C is the native language of the programming interfaces in Unix systems.

You could write C++ programs that use these interfaces, but all of the programming examples I use are written in C. This implies that you

should be able to read and understand simple C programs. If you can

write in C++, you’re sufficiently prepared to write in C, although many C++ programmers don’t realize this.

Many people who know C++ often think that they don’t know C and they get discouraged needlessly. The C++ language is more or less a

superset of C. If you know C++, you know a great deal of C. There are a few minor differences in syntax here and there. The bigger problem is

that most C++ programmers don’t know how to use the C libraries.

Most use C++ stream I/O and don’t know how to use the functions from

C’s Standard I/O Library, which they see as archaic. These functions are usually much more useful and efficient than those found in C++. Where

I taught for more than 40 years, the basic programming classes used

C++, but most students who took my classes in Unix system

programming quickly adapted to C, and some preferred it.

*Utility Programs*

At the very least, you need to know how to compile and build programs

on Linux or other Unix systems. I don’t cover how to use any program

development tools in this book other than showing you how to build

the programs using the GNU gcc compiler collection. However, you’ll

be a more efficient programmer if you know how to use a few software

development system utilities. The most important of these tools are:

**make** For maintaining program collections

**gdb** An indispensable command line debugging tool

**valgrind** To help find memory leaks and bad pointers in code

**git** A command line tool for version control

If you’re used to using an integrated development environment (IDE)

such as Eclipse or NetBeans, try to toss its training wheels away and

learn how to use these tools instead.

*System Requirements*

The book assumes that you have access to a Linux system on which you

can develop programs. It doesn’t matter which flavor of Linux you use.

I’ve been using Ubuntu for several years; many other distributions are available. You don’t need to install it on your machine if you have

remote access to a Linux system, although working remotely is

generally slower. You can also install a Linux virtual machine on your host computer as your work environment for this book.

If you don’t have superuser privilege for your system, you’ll either

need to get sudo privilege or ask the person who maintains the machine to make sure the system has the needed packages, which include:

The GNU compiler collection (gcc)

All man pages, including manpages-dev, man-db, manpages-posix, and

manpages-posix-dev

The man-db package, which lets you search through man pages, but

you’ll have to run the command mandb as a superuser to initialize the

database for searching

The make utility, gdb, git, and valgrind

You’ll have to check which package manager your variant of Linux uses

for installing packages if you need to install any of these.

About UNIX, Unix, Linux, and More

Unix has a history dating back to 1969, and since that time many

different variants have been developed, of which Linux is one. In 1969, and for many years after that, Unix was always written as *UNIX* because its name was a pun based on an earlier system named *MULTICS* on which its original developers worked. In fact, for a very short period of time, it was called UNICS. In 1993, *UNIX* became a registered

trademark of The Open Group, a consortium of companies. The term

*Unix* is not trademarked and doesn’t refer to any one operating system.

In general, it refers to any operating system that is what people often call *Unix-like*. In the interest of clarity, when the term *UNIX* appears in the text, it refers very narrowly to any operating system that has been certified by The Open Group as conforming to its branding of the term

or to those versions of Unix predating the trademark whose name was

written as UNIX at the time. I mostly use the word *Unix*, which in some contexts has a precise meaning and in others does not.

One important consequence of the fact that there are so many different varieties of Unix is that a program that works on one Unix

system may not work on another. This problem led over time to the

standardization of Unix. Chapter 1 contains a brief history of the various applicable standards. The general problem of writing programs

that work across a variety of operating systems is called *portability*.

Chapter 1 also describes steps that you can take to make your code portable to Unix systems other than the one on which you wrote it,

provided that they conform to one standard or another.

The term *Linux* poses a slightly different problem. Technically speaking, Linux is not an entire operating system with all of its utilities and programs that come bundled together in an installation package. It’s just what’s commonly called the *kernel*, a term defined in Chapter 1. The rest of the operating system is mostly programs and libraries developed by GNU as part of the GNU Project

( [*https://www.gnu.org/gnu/gnu.xhtml*)](https://www.gnu.org/gnu/gnu.xhtml). (GNU is a recursively defined acronym for GNU’s Not Unix.) For this reason, many people believe it

should be called *GNU/Linux*. I am one of those who believe that its name should reflect the major contribution to it by the GNU Project;

therefore, when I want to refer specifically to the entire operating

system, I’ll sometimes call it GNU/Linux as a reminder, but when I

refer specifically to its kernel, I’ll call it Linux.

Scope, Content, and Organization

This book covers most of the basic programming interfaces in Linux,

but not all of them. In particular, it covers locales and

internationalization, files and filesystems, various methods of I/O from basic to advanced, signals, timers, processes, threads, many interprocess communication facilities, client-server programming, terminals and

terminal I/O, the *ncurses* library, login accounting, and other system databases. It does not cover access control lists, capabilities, sockets, or pseudoterminals.

*Chapter Organization*

The book has 19 chapters that build upon one another. I wrote this book as if I were teaching in a classroom and you’re there with me, and we’ve embarked on a journey in which we learn this material together. I don’t expect a reader who starts in Chapter 7 to understand it any more than I would expect a student who missed the first six classes of a course to understand much in the seventh class.

Chapter 1: Core Concepts Explains what system programming is and how it differs from other kinds of programming. It introduces the

fundamental concepts and components of the Unix operating system,

such as users and groups, files and directories, processes, and so on, and it explains the man pages and how we’ll use them. It also covers

some of the history of Unix and the key standards.

Chapter 2: Fundamentals of System Programming Introduces concepts related to programming in a Unix environment and working

with the kernel application programming interface (API). It covers

object libraries and the difference between static and shared libraries, system calls, error handling, portability and feature test macros,

system limits, and internationalization of programs. It also covers how programs can access the environment strings and their command line

arguments, and process command line options.

Chapter 3: Time, Dates, and Locales Presents the methodology for learning system programming that the rest of the book follows

and explains how the source code repository that contains all example

programs is organized. It applies this methodology to the

development of programs that work with dates and times in Unix and

introduces basic methods of internationalizing programs.

Chapter 4: Basic Concepts of File I/O Introduces core concepts of files and file I/O in Unix, including universal I/O, open file

connections, file descriptors, and the parts of the kernel API relevant to I/O. It also covers file permissions, the types of user IDs, and the setuid facility. It develops a simplified copy command and explores

issues related to performance and buffering.

Chapter 5: File I/O and Login Accounting Introduces the file pointer, seeking operations, and a few more advanced methods of I/O.

It introduces system data files related to users and logins, and it

develops simplified versions of the lastlog and last commands.

Chapter 6: Overview of Filesystems and Files Dives into the structure of disks, disk partitions, disk filesystems, and their internals.

It introduces parts of the kernel API for accessing filesystem

attributes, file attributes, and more, and it also introduces the Linux virtual filesystem and how it works. It then develops simple versions

of the stat and statfs commands.

Chapter 7: The Directory Hierarchy Explains the structure of directories and the directory hierarchy. It explores the parts of the

kernel API and the standard libraries for processing directories and

the directory hierarchy, including methods of traversing the

hierarchy. Here, we develop simple ls, pwd, and du commands.

Chapter 8: Introduction to Signals Covers the core concepts of signals and how they’re used in Unix systems. It introduces the parts

of the kernel API related to sending signals, signal handling, signal

registration, and signal blocking. It also discusses the design of signal handlers and the concept of asynchronous signal safety.

Chapter 9: Timers and Sleep Functions Introduces timing elements for programs and explains fundamental concepts related to

timing, such as clocks, hardware interval timers, and more. It

introduces several different sleep functions and software interval

timers, and it also develops a couple of programs that act like system monitors.

Chapter 10: Process Fundamentals Introduces the fundamentals of processes: what they are, how they’re organized, and how they’re

managed and represented internally by the kernel. It introduces the

Executable and Linking Format (ELF) file format and how it is used

to create process images, and it also introduces the *proc*

pseudofilesystem. Here we develop a simplified ps command.

Chapter 11: Process Creation and Termination Introduces the parts of the kernel API related to the creation, termination, and

management of processes, including calls for the synchronization of

parent and child processes. It develops a simplified shell program.

Chapter 12: Introduction to Interprocess Communication The first of two chapters dedicated to interprocess communication (IPC).

It covers POSIX shared memory, semaphores, and POSIX message

queues. It develops a few programs that demonstrate the application

of these IPC facilities.

Chapter 13: Pipes and FIFOs Introduces unnamed pipes and named pipes, also called FIFOs, and goes into details of the semantics of opening, reading, writing, and closing pipes and FIFOs. It develops a simple FIFO-based server.

Chapter 14: Client-Server Applications and Daemons Covers concepts related to the development of client-server applications,

including system logging facilities and conversion of processes into

daemons. It develops both an iterative server similar to the calc

command and a concurrent server.

Chapter 15: Introduction to Threads The first of two chapters on multithreaded programs. It covers thread basics, explores much of

the *Pthreads* library related to thread creation and management, and develops a multithreaded server.

Chapter 16: Thread Synchronization Covers the parts of the *Pthreads* API related to the synchronization of threads, including mutexes, condition variables, barriers, and read-write locks.

Chapter 17: Alternative Methods of I/O Explores I/O models beyond the standard blocking I/O model. In particular, it covers

nonblocking I/O and polling, signal-driven I/O, POSIX

asynchronous I/O, and multiplexed I/O using the select() system

call.

Chapter 18: Terminals and Terminal I/O Covers terminals and terminal I/O, beginning with the special needs of interactive

programs. It examines the structure of terminal driver software and

support for terminal configuration in the kernel, after which it explores methods of configuring the terminal such as the termios and

ioctl interfaces. It develops a simplified stty command.

Chapter 19: Interactive Programming and the ncurses Library

Covers configuring the terminal for interactive programs, including

noncanonical mode programming. It introduces the *ncurses* library’s API and develops a few programs based on it, ending with a simple

version of the top command.

Appendix A: Creating Libraries Shows how to create and manage static and shared libraries.

Appendix B: Unicode and UTF-8 Offers a short tutorial on Unicode and the variable-length representation of Unicode known as

UTF-8.

Appendix C: Date and Time Format Specifiers Presents a table of the date and time specifiers, with examples, used in the formatting of dates and times by various functions and system utilities.

*Online Materials*

To keep the book from becoming too long, programs are generally not

presented in their entirety. Instead, they’re available online along with other materials. You can access them on the book’s web page at

[*https://nostarch.com/introduction-system-programming-linux*](https://nostarch.com/introduction-system-programming-linux).

Source Code

All of the source code that appears in this book, as well as other example programs, is available for download at

[*https://github.com/stewartweiss/intro-linux-sys-prog*](https://github.com/stewartweiss/intro-linux-sys-prog) and as a ZIP file from

[*https://nostarch.com/introduction-system-programming-linux*](https://nostarch.com/introduction-system-programming-linux). The programs are organized by chapter. Each chapter directory contains a makefile for building and maintaining the programs in that directory, and I include a master makefile that can build and maintain all of the programs in this repository. The top-level directory has a *README* file that explains the

licensing and has instructions for maintaining the programs. I have tried to write thorough inline documentation for all programs.

There are also three directories named *common*, *include*, and *lib*. The first contains source code and header files for functions that are used in multiple chapters. The makefile there can build a library file that is copied into *lib* and copy the headers into *include*.

All complete programs in the repository are covered by the GNU

General Public License (Version 3), a copy of which is in the repository.

The source code for all library functions in the *common* directory is covered by the GNU Lesser General Public License (Version 3), a copy

of which is also in the repository.

Command Line Online Chapter

The book also includes in its online resources a short summary of the

basics of using the command line, titled “Working in the Command

Interface.” This covers the set of basic commands needed to perform

essential tasks.

make Tutorial

I’ve written a make tutorial for those who want to know how to use this utility program in elementary ways. The book’s web page has a link to a GitHub repository that contains the tutorial and instructions for how to use it.

Solutions to Exercises

Solutions to selected exercises from the ends of each chapter are

available online in a single ZIP file that you can download from the

website.

Conventions and Format

I’ve tried to follow fixed conventions and style throughout the book to make it easier to read. These include the book’s typography, the format

of command input and output, names of things, dates and times, and more.

*Typographical Conventions*

I use a monospaced font for all code, input and output of programs, file contents, and the names of all commands and executable programs. For

example, I would write “bash is a popular shell in Linux.” I use *italic* text for the names of all files and directories, as in “The executable program file for the bash shell is */bin/bash*.”

*Notation*

In the description of a command or function I use square brackets (\[ \]) to enclose optional elements. The brackets are not part of the

command. Italic text denotes placeholders, not actual text that you type.

An ellipsis (...) means more than one copy of the preceding token. For example, in the description

ls \[ *option*\] ... \[ *directory_name*\] ...

the words *option* and *directory_name* are placeholders. The square brackets indicate that both the option specifiers and the argument to the ls

command are optional but that all option specifiers must precede any

directory names and that option specifiers and directory names can

occur multiple times, as in:

ls -l -t chapter01 chapter02

Here, -l and -t are two options and chapter01 and chapter02 are two

arguments.

I use a vertical bar (\|) to indicate exactly one choice among multiple alternatives. For example, the description

bash \[ *option*\] ... \[ *command_string* \| *file*\]

indicates that after all options, you can supply either a command string or the name of a file but not both.

Throughout the book, I’ll use the \$ character as the prompt string displayed inside a terminal window. Any text that you would enter is

shown in boldface. For example, the echo command just prints whatever

text you enter after it on the command line. I would demonstrate how

you use it as follows:

\$ **echo 'Is this really how echo works?'**

Is this really how echo works?

\$

Notice that the prompt character is displayed again. This is how I

indicate that you’re seeing *al* of the command’s output and that the command terminated. When showing all output would require too

many lines, I’ll snip some of the lines by putting the word *--snip--* in place of the removed output, as in:

\$ **ls /var**

backups/

cache/

*--snip--*

\$

I’ll also use an ellipsis on a single line when I’ve deleted some of the text on that line. In the Unix system that you use for following along with this book, the prompt character that you see might be something

other than \$. Many systems might have a default prompt that includes

more information, such as your login name or the name of the

computer. In fact, you are usually able to customize your prompt.

In code listings, I’ll sometimes omit parts of the code to save space.

I’ll indicate this either with a *--snip--* in place of multiple lines of code, as in

int main()

*--snip--*

return 0;

}

or, when I want to specify what’s missing, I’ll use this notation:

if ( argc \< 2 )

// OMITTED: Handle missing argument

else

I’ll also write all pseudocode that appears in code listings in //-style comment blocks, reserving /\*...\*/-style blocks for actual comments.

*Example Program Naming Conventions*

I try to adhere to a program naming convention for the example

programs that I’ve written for the book. Using a convention helps you

(and me) guess what a program does from its name. The chapters in

general contain three types of example programs:

Programs that implement a simplified version of an existing Unix

command. In this case, the program name is formed by prefixing

the actual command name by spl\_. For instance, spl_ls is the book’s

version of ls, and the source file is named *spl_ls.c*.

Programs that do nothing except demonstrate basic use of a

function introduced in a chapter. These have names that end in the

suffix *\_demo.c*, such as *getenv_demo.c*.

Programs that don’t implement an existing command but do more

than just demonstrate how to call and use a function. I try to give

these names that describe what they do. The program *showal users.c* in Chapter 5 is an example of one.

If a chapter has multiple versions of a program, a sequence number

is appended to the basename of the function, as in *spl_date1.c* and *spl_date2.c*.

*Dates and Identities*

It’s common practice in the computer book industry to change any dates and timestamps in program and command output to either a point very

far in the past or to some future time well beyond the book’s release

date so that the book isn’t dated. I do this whenever possible, but

sometimes when date and time themselves are the subject of a chapter

and altering true output would make an explanation more difficult, I don’t.

None of the usernames that appear in the output of programs are

those of real people, except for mine. Any similarity to a real person’s name is coincidental. I alter the output of commands that display actual usernames so that they aren’t those of real people.

Suggestions and Corrections

I’ve tried my best to find bugs and mistakes in the example programs

and the text of the book, but I can’t imagine that I found and corrected them all. Along the same lines, I sometimes rewrote an explanation

many times over, trying to make sure it is easy and enjoyable to read and accurate, but again, I am not perfect, and you may find places in the

book that you think could be written better.

If you’d like to make suggestions or corrections to the text of the

book, please email me at [*stewart.weiss@acm.org*](mailto:stewart.weiss@acm.org) or email

[*errata@nostarch.com*](mailto:errata@nostarch.com). Include either a page number or a piece of identifying text that is long enough to be unique. If you find bugs or more serious flaws in the code (I hope not), if you’re familiar with Git, please open an issue on [*https://github.com/stewartweiss/intro-linux-sys-*](https://github.com/stewartweiss/intro-linux-sys-prog)

[*prog*.](https://github.com/stewartweiss/intro-linux-sys-prog)

I hope that you learn a lot from this book. Even more important, I

hope that it shows you how you can learn what it doesn’t cover on your own. Finally, I hope it’s enjoyable to read and that you gain an

appreciation for the marvel and magic of Unix.

![](/tmp/audit/iter1/epubregen/system-programming-in-linux/media/index-51_1.jpg)