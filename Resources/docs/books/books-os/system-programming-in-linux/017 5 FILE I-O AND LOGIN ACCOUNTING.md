5 FILE I/O AND LOGIN ACCOUNTING

In the preceding chapter, we learned the fundamental concepts of file

I/O as well as how to use the basic system calls related to it. Here, we’ll add a few more advanced tools to our repertoire so we can create more

sophisticated programs. First, we’ll consider ways to control the position of the file offset, which is the component of an open file description that stores the position of the next byte to read or write in a file. Being able to control the file offset will give us the means to solve problems we currently can’t solve that require reading from nonconsecutive parts of files. We’ll apply this new knowledge to develop a few programs for

displaying various types of information about login records.

All Unix systems record and maintain information about who has

logged in, when they did so, and more, in order to answer questions

such as who is currently logged in, who has logged in within some past length of time, and when was the last time that one or more users

logged in. We’ll examine the files and data structures that store this information as well as the programming interfaces to them.

When we do the background research to write these programs, we’ll

discover that there are parts of the kernel API that simplify access to particular system databases, and we’ll explore what they do and how we can use them. We’ll then create a few programs that manipulate some of that data. Finally, we’ll discuss a few performance issues and design

choices in the programs we developed.

![](/tmp/audit/iter1/epubregen/system-programming-in-linux/media/index-296_1.jpg)

Controlling the Position of I/O Operations

In Chapter 4, the read operation that we use in the spl_cp1 program is oblivious to the structure of the files it copies; it doesn’t matter whether the transfers are aligned with any structural elements in the file. Figure

5-1 illustrates this idea.

*Figure 5-1: The positions at the start and end of a read operation with respect to structures* *in a file*

The diagram depicts a portion of a file that consists of a sequence of C structs of uniform size. The buffer size in the system call read(fd, buf, bufsize) of that program is not chosen to align with any internal

structure that the file might have. If neither buf nor bufsize is an exact multiple of the size of these structures, the beginning and ending

positions of read operations can fall in the middle of these C structs. For the spl_cp1 program, this doesn’t matter—it ultimately copies all the

bytes from one file to another, preserving their sequence—but other

programs might need to align the starting points of read operations to the starts of these structures.

Programs that need to align their reads and writes with particular

offsets in a file need the ability to move the file offset to the position at which they need to perform their next I/O operation.

*The lseek() System Call*

When a file is first opened, the file offset is set to the start of the file, unless the O_APPEND flag was passed to the open() call. We haven’t yet discussed the significance of the O_APPEND flag, but we’ll do so in Chapters

11 and 17. If read() is called to read *N* bytes from the file, and it succeeds, the file offset is automatically advanced *N* bytes. Similarly, if a

write operation writes *N* bytes, the file offset is advanced *N* bytes. We don’t control this.

When a program explicitly moves the file offset, it’s called *seeking*.

Unix kernels provide a system call named lseek(), which changes the

current file offset’s position. Its man page begins with: SYNOPSIS

\#include \<sys/types.h\> \#include \<unistd.h\> off_t lseek(int fd, off_t offset, int whence); DESCRIPTION lseek() repositions the file offset of the open file description associated with the file descriptor fd to the argument offset according to the directive whence as follows:

SEEK_SET The file offset is set to offset bytes. *--snip--*

The lseek() system call has three parameters: a file descriptor (fd), a distance in bytes (offset), and an integer flag (whence), which can take on one of the following macro constants: SEEK_SET, SEEK_CUR, or SEEK_END. The offset value, which can be given any integer value including negative

numbers, is the number of bytes to move the file offset. A positive value moves it forward, and a negative value moves it backward. The value of whence determines the starting position from which it is to be moved. It has three possible values:

**SEEK_SET** The file offset moves offset bytes relative to the file’s start.

**SEEK_CUR** The file offset moves offset bytes relative to the current value of the file offset.

**SEEK_END** The file offset moves offset bytes relative to the file’s end.

Figure 5-2 illustrates how the file offset is adjusted based on the different parameter values.

![](/tmp/audit/iter1/epubregen/system-programming-in-linux/media/index-298_1.jpg)

*Figure 5-2: The effect of the* *whence* *parameter on the movement of the file offset. In (a) it’s* *moved using* *whence = SEEK_SET, in (b) using* *whence = SEEK_CUR, and in (c) using* *whence*

*= SEEK_END.*

If the resulting value of the file offset would be negative, it’s an error, and it isn’t moved. Instead, lseek() returns -1 and sets errno to EINVAL.

There are several other ways it can fail, and in all cases it returns -1 and sets errno to an error value. The man page lists all of the possible errors.

If lseek() is successful, its return value is the resulting position of the offset as measured in bytes from the beginning of the file. This return value is useful for two purposes. One is that we can get the current

position of the offset with the call: off_t current_pos = lseek(fd, 0, SEEK_CUR);

This call doesn’t move the file offset, and current_pos is its current position.

We can also use lseek() to get the size of a file by seeking to the end and getting the return value: off_t size = lseek(fd, 0, SEEK_END);

Since the file offset is now at the end of the file, the return value is the size of the file in bytes, which we store in size.

Other examples of using lseek() are: lseek(fd, 20, SEEK_SET) /\*

Byte 20 of the file \*/ lseek(fd, -1, SEEK_END) /\* The last byte of the file \*/ lseek(fd, -1, SEEK_CUR) /\* The byte before the current offset \*/

lseek(fd, 0, SEEK_SET) /\* The first byte in the file \*/

In all of the preceding examples, we didn’t try to move the file offset past the end of the file. Let’s look at what happens when we do.

*File Holes*

Although we can’t move the file offset to a position preceding the start of the file, we can move it to a position *after* the end of the file! For example, when the value of offset is positive and whence is SEEK_END, the file offset is moved beyond the end of the file. Data can be written to this position, and this in effect creates a gap in the file between the original end of the file and the start of the data just written. This gap is called a *file hole*. If we then call lseek(fd, 0, SEEK_END), the file offset is advanced to the new end of the file.

The read() system call doesn’t return an error when the file offset is inside a file hole. Instead, it treats the hole as a sequence of NULL bytes (bytes whose value is zero). To be precise, if the file offset is inside a file hole, the call read(fd, buffer, count) fills buffer with a NULL byte for every byte in the hole that it reads. Thus, if all count bytes are within the hole and the buffer is at least count bytes long, buffer\[0...count-1\] will be filled with zeros. If count is large enough that the file offset plus count contains data after the hole, then that data will be stored into buffer following the zeros. Figure 5-3 illustrates a file hole.

![](/tmp/audit/iter1/epubregen/system-programming-in-linux/media/index-300_1.jpg)

*Figure 5-3: A file hole created by seeking past the end of a file and writing data there*

Figure 5-3 depicts a situation in which a process opened a file consisting of the 10 consecutive characters 0123456789, after which it performed a seek that moved the file offset 1,000,000 bytes past the end and then wrote the same sequence of characters (0123456789) at the new file offset. The file size then became 10 + 1,000,000 + 10 = 1,000,020

bytes, even though the file has a hole of 1,000,000 bytes within it.

Listing 5-1 is a program that creates such a file.

*makefilehole.c*

\#define MESSAGE_SIZE 512

\#define BUFFER_SIZE 10

int main(int argc, char \*argv\[\])

{

int fd;

char buffer\[BUFFER_SIZE\];

char message\[MESSAGE_SIZE\];

if ( 2 \> argc ) {

sprintf(message, " %s \<file-to-create\>\n", basename(argv\[0\])); usage_error(message);

}

/\* Create a new file named file_with_hole in the pwd. \*/

if ( (fd = open(argv\[1\], O_WRONLY \| O_CREAT \| O_EXCL, 0644)) \< 0 )

fatal_error(errno, "open");

/\* Fill buffer with a string. \*/

strncpy(buffer, "0123456789", BUFFER_SIZE);

/\* Write the string at the beginning of the file. \*/

if ( write(fd, buffer, BUFFER_SIZE) != BUFFER_SIZE )

fatal_error(errno, "write");

/\* Seek 1,000,000 bytes past the end of the file. \*/

if ( lseek(fd, 1000000, SEEK_END) == -1 )

fatal_error(errno, "lseek");

/\* Write the small string at the new file offset. \*/

if ( write(fd, buffer, BUFFER_SIZE) != BUFFER_SIZE )

fatal_error(errno, "write");

if ( close(fd) == -1 )

fatal_error(errno, "close");

exit(EXIT_SUCCESS);

}

*Listing 5-1: A program that creates a file with a hole* We run it to create a file named *file_with_hole* and inspect its size with the command ls -l file_with_hole: \$

**./makefilehole file_with_hole** \$ **ls -l file_with_hole** -rw-r--r-- 1 stewart stewart 1000020 Jun 3 11:57 file_with_hole

However, the file doesn’t actually contain 1,000,020 bytes.

We can see its actual disk allocation with a few different commands.

One way is to use ls -s --block-size=1. The -s option of ls shows the

number of blocks allocated to the file, and the --block-size=1 option

specifies that the -s option should use units of 1 byte. The command \$

**ls -s --block-size=1 file_with_hole** 8192 file_with_hole

shows that this file actually has 8192 bytes. Since disk blocks on the device where the file resides are 4096 bytes (4KB) each, the file is

allocated two 4096-byte blocks. We’ll explain why it has these two

blocks shortly.

A second method of seeing its actual disk allocation is to use the du

command, which displays disk usage for the files specified as its

arguments. It also accepts a --block-size=1 option to show block size units of 1 byte: \$ **du --block-size=1 file_with_hole** 8192 file_with_hole Even though the file appears to have a size of 1,000,020 bytes when

we use ls -l, it’s allocated only two disk blocks of 4KB each. Files are allocated storage in fixed-size blocks. A write of *N* ≤ 4096 bytes at the start of the file requires one 4KB block. Any remaining bytes of that

![](/tmp/audit/iter1/epubregen/system-programming-in-linux/media/index-302_1.jpg)

block are filled with NULLs. Since we wrote the second string 1,000,010

bytes from the start of the file, the filesystem allocated a second block for the file. The start of that block must be a multiple of 4096 bytes from the start of the file. The largest multiple of 4096 less than

1,000,010 is ⌊1,000,010 / 4096⌋ × 4096, which is 999,424. Thus the

second block starts at byte offset 999,424 in the file. Since 1,000,010 –

999,424 = 586, the start of that second string in the second block is 586

bytes after the start of that block. All bytes preceding that string in that block are filled with zeros, and all bytes after it are filled with zeros.

There are no other blocks. Figure 5-4 illustrates where the string starts in the file and its relationship to the start of the block.

*Figure 5-4: A not-to-scale diagram of the disk blocks allocated to the file with holes that is* *depicted in Figure 5-3*

The od command can show us the actual file contents. We can give it

two options: -a displays any bytes containing characters as the characters themselves rather than their numeric codes, and -Ad displays addresses in decimal instead of the default radix, which is octal: \$ **od -a -Ad**

**file_with_hole** 0000000 0 1 2 3 4 5 6 7 8 9 nul nul nul nul nul nul 0000016 nul nul nul nul nul nul nul nul nul nul nul nul nul nul nul nul \*

1000000 nul nul nul nul nul nul nul nul nul nul 0 1 2 3 4 5 1000016 6 7

8 9 1000020

The \* notation in the third row of output indicates that the missing

lines are identical to the preceding line of 16 NULL bytes. In all other rows, the first column is the decimal address of the first byte in that row.

The remaining fields in a row are the values of the bytes at the 16

successive addresses starting at that address. The nul string means that the byte is zero filled. If the low-order 7 bits of a byte represent a character, the character is displayed. That’s why we see the actual

characters in the output. Even though they look like numbers, they are just characters.

The next time the output of ls -l suggests that a file is of a large size, remember that the actual amount of disk space used by the file might be less. In general, files that appear to be of a large size but really use only a small fraction of that size are called *sparse files*.

Displaying Last Login Information

One problem for which we need to control the position of the file offset is the retrieval and update of login records. Unix systems, like most

operating systems, keep track of logins and logouts. They record the

times that a user logs in and logs out, as well as other information

associated with those events. Ordinary users have permission to read

this data; we don’t need to be a system administrator or have superuser privilege to see it. The data is structured, usually stored as C structures in binary form in disk files. In order to read, update, or write new

records located in particular positions in a file, a program needs to move the file offset to those positions.

We’re going to implement a command that reads data from this type

of file so that we can get experience in managing the file offset. In

particular, we’d like to know which commands print data associated with previous logins on our system, such as the last time that a user logged in or out. We expect that the man page descriptions of such commands will include words such as *login*, *logout*, or *logged*, as well as the word *last*.

Although most commands are in Section 1 (Commands) of the man

pages, commands used for system administration may also be found in

Section 8 (System Management Commands).

We’ll use apropos with the -a option to search for all pages containing both *log* and *last* in these two sections: \$ **apropos -s1,8 -a log last** last (1) - show a listing of last logged in users lastb (1) - show a listing of

last logged in users lastlog (8) - reports the most recent login of all users or of a given user pam_lastlog (8) - PAM module to display date of last login and perform inactive account lock out

The output lists three commands of interest: last, lastb, and lastlog. The first two have the same description, and their man pages are worth

examining. In fact, they have a shared man page, which states that the last command searches back through a file whose typical pathname is

*/var/log/wtmp* and displays a list of users who have logged in and possibly logged out since the date the file was created. The lastb

command is similar, but it reports only on bad login attempts. We’ll

revisit the last command later in this chapter.

THE PATHS.H FILE

Although the man page tells us that the *wtmp* file is in */var/log/*, it may not be in that location on all systems. The locations of

common system files and directories vary from one Unix

distribution to another. To allow applications to be written in a

portable way, when a Unix system is installed, the system header

file */usr/include/paths.h* is populated with macros for the actual pathnames of common system files. For example, it defines

\_PATH_WTMP as a macro name for the pathname of the *wtmp* file

\#define \_PATH_WTMP "/var/log/wtmp"

and \_PATH_MAN as the pathname to the directory storing the

compressed man pages: \#define \_PATH_MAN

"/usr/share/man"

Whenever possible, instead of hardcoding actual pathnames

in a program, it’s better to use the macros. This way, if the

program is compiled and run on a machine in which the

system file is in a different location than the one on which we

developed the code, it will still locate the file.

If you’d like to use the macros from */usr/include/paths.h*, you can modify the header file *sys_hdrs.h* introduced in Chapter 2 to include that header as well, or include *paths.h* in each program needing those macros.

*The lastlog Command*

The lastlog command displays a list of the most recent logins of all users who have ever logged in or, if a username is given to it, the most recent login of that user. Sample output of the command looks like this: \$

**lastlog** *--snip--* sam pts/2 192.168.1.112 Wed Feb 19 22:01:56 -0400

2025 lightdm \*\*Never logged in\*\* nm-openvpn \*\*Never logged in\*\* brit

pts/1 192.168.1.165 Mon Jan 20 11:20:50 -0400 2025 sshd \*\*Never

logged in\*\* *--snip--*

This command displays the username for every user of the system who

has ever logged in, the terminal line on which the login occurred, the host IP address or hostname, whether it was a remote login, and the

time and the date of the login. The time is given in the locale’s time format, because if I run it changing the locale’s LC_TIME category to the Spanish language \$ **LC_TIME=es_ES.utf8 lastlog** *--snip--* sam pts/2

192.168.1.112 mié abr 19 22:01:56 -0400 2023 *--snip--*

it displays the date and time in Spanish.

We’re going to try to implement the lastlog command. Its man page

starts with: LASTLOG(8) System Management Commands

LASTLOG(8) NAME lastlog - reports the most recent login of all

users or of a given user SYNOPSIS lastlog \[options\] DESCRIPTION

lastlog formats and prints the contents of the last login log

/var/log/lastlog file. The login-name, port, and last login time will be printed. The default (no flags) causes lastlog entries to be printed, sorted by their order in /etc/passwd. *--snip--*

After the OPTIONS section, there’s more detailed information about the command and its database file, which the page states is *var/log/lastlog*.

The *paths.h* header file has a macro for this file’s pathname \#define \_PATH_LASTLOG "/var/log/lastlog"

which we’ll use when we implement it.

*The lastlog File*

The *lastlog file* is a database that contains information about each user’s last login. The lastlog command accesses records from this file. The

page tells us that the database file is sparse, which implies that the file holes in it account for most of its size. We can infer something about the organization of the file from the following remark in the CAVEATS

section of the page: CAVEATS Large gaps in UID numbers will cause

the lastlog program to run longer with no output to the screen (i.e. if in lastlog database there is no entries for users with UID between 170 and 800 lastlog will appear to hang as it processes entries with UIDs 171-799).

We now know the following:

There are no entries for users who have never logged in.

The lastlog command produces no output and appears to hang

when it reaches a sequence of user IDs of users who have no

entries.

The file can be sparse.

The file appears to be large if there are users with high user IDs.

Since the file’s size increases as user IDs get higher, and since the

command takes time even though it produces no output when there’s no

record for a user, and since it’s sparse, we can infer that the file is like a large array of records for all possible users such that the location in the file of a user’s record is proportional to the user’s user ID, as shown in

Figure 5-5.

![](/tmp/audit/iter1/epubregen/system-programming-in-linux/media/index-307_1.jpg)

*Figure 5-5: The structure of the* lastlog *file*

Figure 5-5 shows five clusters of user login records, and the rest of the file has no data. In other words, it has file holes. The lastlog

command spends time in these holes only to discover that the associated users have never logged in.

*The lastlog Structure*

The man page doesn’t show us each record’s structure; for that, we need to do more research. To learn about the form and content of this

structure, we check whether there’s a man page for the file itself,

perhaps in the FILES section of the man pages, but there isn’t. We then check whether there’s a header file that defines the structures. That file would most likely be named *lastlog.h* and be located in */usr/include*. Sure enough, that file exists and has just four lines: \$ **more**

**/usr/include/lastlog.h** /\* This header file is used in 4.3BSD to definèstruct lastlog', which we define in \<bits/utmp.h\>. \*/ \#include

\<utmp.h\>

The comment states that the definition of struct lastlog is in *bits/utmp.h*.

If you try to find a directory named *bits* on your system, you’ll discover many of them, and they may not even contain an entry for the *lastlog.h* file.

This leads to a more general question. When we write an \#include

directive in a program, such as \#include \<utmp.h\>

and there are multiple files named *utmp.h* in the filesystem, which of them does the compiler use?

The compiler searches through a sequence of directories for

included files in a well-defined order. Technically, it’s not the compiler, but the compiler’s preprocessor, cpp on GNU/Linux, that defines and

uses this sequence. To display the preprocessor’s search sequence on a GNU/Linux system, we can run the following command: \$ **cpp -v**

**/dev/null -o /dev/null**

The -v is a gcc option that tells cpp to produce *verbose* output. The first argument is the program to preprocess, in this case /dev/null, which is an empty file. The -o /dev/null tells it to throw away the processed code, which in this case is nonexistent. The command runs the preprocessor

on an empty program in verbose mode, outputting its diagnostic report

on the standard error stream (the screen) and throwing away the

standard output.

You’ll see many output lines of messages, but there’ll be a line

starting with \#include \<...\> search starts here:. The lines following that line show the search path for included header files. On my system, I see the following: *--snip--* \#include \<. .\> search starts here:

/usr/lib/gcc/x86_64-linux-gnu/11/include /usr/local/include

/usr/include/x86_64-linux-gnu /usr/include End of search list.

To find the correct *bits/utmp.h* file, we look in each directory in turn, starting with the first. On my system, the first (and only) occurrence of the *bits/utmp.h* file is */usr/include/x86_64-linux-gnu/bits/utmp.h*.

Let’s look at that file: *--snip--* \#ifndef \_UTMP_H \#error "Never include \<bits/utmp.h\> directly; use \<utmp.h\> instead." \#endif \#include

\<paths.h\> \#include \<sys/time.h\> \#include \<sys/types.h\> \#include

\<bits/wordsize.h\> \#define UT_LINESIZE 32 \#define

UT_NAMESIZE 32 \#define UT_HOSTSIZE 256 /\* The structure

describing an entry in the database of previous logins \*/ struct lastlog {

➊ \#if \_\_WORDSIZE_TIME64_COMPAT32 int32_t ll_time; \#else

\_\_time_t ll_time; \#endif char ll_line\[UT_LINESIZE\]; char

ll_host\[UT_HOSTSIZE\]; }; *--snip--*

The warning at the top is that a program should never include *bits/utmp.h* directly. Instead it should include *utmp.h*, because that file includes *bits/utmp.h*.

The lastlog structure has three members. The first is named ll_time

and is either of type \_\_time_t or int32_t. The value of the

\_\_WORDSIZE_TIME64_COMPAT32 ¶ macro determines whether the ll_time member of the lastlog structure is declared as \_\_time_t or int32_t.

How and where is this macro defined? The included file

\<bits/wordsize.h\> is most likely where it’s defined. Its full path would be

*/usr/include/x86_64 -linux-gnu/bits/wordsize.h*. There, we see yet another conditional macro: \#ifdef \_\_x86_64\_\_ \#define

\_\_WORDSIZE_TIME64_COMPAT32 1 /\* Both x86-64 and x32 use

the 64-bit system call interface. \*/ \#define \_\_SYSCALL_WORDSIZE

64 \#else \#define \_\_WORDSIZE_TIME64_COMPAT32 0 \#endif

The macro \_\_x86_64\_\_ is set to true when the compiler is installed on a 64-bit architecture that is running in *32-bit compatibility mode*. This means that the machine can run applications that consist of instructions for a 32-bit architecture even though it’s a 64-bit machine. On such

machines,\_\_WORDSIZE_TIME64 \_COMPAT32 is set to true (1); otherwise, it’s set to false (0).

The comment preceding the conditional macro explains the need

for it. It ensures that if the machine is a 64-bit machine that allows 32-bit applications to run, such as an x86-64 or a ppc64, all applications will see int32_t as the type of ll_time, which is 4 bytes, and otherwise, they’ll all see its type as \_\_time_t, which is 8 bytes on a 64-bit machine and 4

bytes on a 32-bit machine. This implies that when we use the sizeof()

function in C to obtain the number of bytes in the struct lastlog on our system, as in sizeof(struct lastlog), our program will have the correct size, independent of the architecture, implying that we can read the structure safely with a call of the form read(fd, ll_buffer, sizeof(struct lastlog)).

READING STRUCTURES FROM A FILE

You can read an arbitrary C struct such as struct lastlog from a file with file descriptor fd into a local variable, say, ll_record of type

struct lastlog, using the following code: size_t lastlog_struct_size =

sizeof(struct lastlog); size_t num_bytes_read = read(fd, &ll_record, lastlog_struct_size); if ( num_bytes_read \< 0 ) // read() error -

handle it. else if ( num_bytes_read == lastlog_struct_size ) { //

Success - can access members with code such as // printf("%s\n", ll_record.ll_line) else // It was an incomplete read.

You would typically set errno to 0 before the call in order to

determine after the call what, if any, error occurred.

The other two members, ll_line and ll_host, are character arrays. In

the header file just shown, these are of size 32 and 256, respectively.

There is no member that stores a user ID because the records are

indexed by the user ID, and therefore, the address of a record in the file implicitly gives us the user ID. In other words, letting N = sizeof(struct lastlog) be the size of the lastlog structure in bytes, if a structure starts at byte address *m* × *N*, then it represents the last login of the user whose user ID is *m*.

The lastlog structure doesn’t have a username member either, so we

need to find out how to obtain the username of a user whose user ID is given.

Usernames, User IDs, and the passwd File

If we enter **apropos -s2,3 user** to find either a system call or library function that returns the username associated with a given user ID, we’ll get over 100 man pages that match the word *user*. We can inspect the output line by line for a candidate that might work, or we can reduce its size by piping it through the grep filter command. A *filter command* reads its input from the standard input, unless it’s given a filename argument, in which case it reads from the file and outputs a modification of its input on the standard output. The grep filter expects a string argument.

The string can be a pattern, which is best enclosed in single quotes. If

it’s not a pattern, grep searches for that string exactly in every line of its standard input. By default, it outputs only those lines that have a match, so grep name will output only those lines containing the word name. It acts like a sieve, throwing away lines that don’t match. Here’s the result: \$

**apropos -s2,3 user \| grep name** \# Find all entries containing

"name" attr_list (3) - list the names of the user attributes of a filesyste. .

attr_listf (3) - list the names of the user attributes of a filesyste. . cuserid (3) - get username getlogin (3) - get username getlogin_r (3) - get

username getpwnam (3posix) - search user database for a name

getseuserbyname (3) - get SELinux username and level for a given

Linux use. . User: grent (3perl) - by-name interface to Perl's built-in getgr\*() functions User: pwent (3perl) - by-name interface to Perl's

built-in getpw\*() functions

(If your output does not look like this, try explicitly including Section 3posix, as in apropos -s2,3,3posix.) The one result that stands out is getpwnam in Section 3posix of the man pages, since it searches a user database for a name. The three functions whose description is get username return only the username of the calling process, which isn’t what we want.

The POSIX man page for getpwnam is a specification of what the

function should do. The relevant fragments of it are:

GETPWNAM(3POSIX) POSIX Programmer's Manual

GETPWNAM(3POSIX) PROLOG This manual page is part of the

POSIX Programmer's Manual. The Linux implementation of this

interface may differ (consult the corresponding Linux manual page for

details of Linux behavior), or the interface may not be implemented on Linux. NAME getpwnam, getpwnam_r - search user database for a

name SYNOPSIS \#include \<pwd.h\> struct passwd \*getpwnam(const

char \*name); int getpwnam_r(const char \*name, struct passwd \*pwd,

char \*buffer, size_t bufsize, struct passwd \*\*result); DESCRIPTION

The getpwnam() function shall search the user database for an entry

with a matching name. *--snip--*

This seems to be the opposite of what we want. It takes a name argument and searches for a matching user record in a database. We want a

function that searches that database when it’s given a user ID.

However, the page gives us a clue: The function returns a pointer to a struct passwd. We should investigate this structure. Also, we should scroll down to the SEE ALSO section of the page to see whether it mentions other functions that might be more like what we’re after. There, it

mentions the function getpwuid(). Let’s look at its man page:

GETPWNAM(3) Linux Programmer's Manual GETPWNAM(3)

NAME getpwnam, getpwnam_r, getpwuid, getpwuid_r - get password

file entry SYNOPSIS \#include \<sys/types.h\> \#include \<pwd.h\> struct passwd \*getpwnam(const char \*name); struct passwd \*getpwuid(uid_t

uid); int getpwnam_r(const char \*name, struct passwd \*pwd, char \*buf,

size_t buflen, struct passwd \*\*result); int getpwuid_r(uid_t uid, struct passwd \*pwd, char \*buf, size_t buflen, struct passwd \*\*result); *--snip--*

The getpwuid() function returns a pointer to a structure containing the broken-out fields of the record in the password database that matches

the user ID uid. The passwd structure is defined in \<pwd.h\> as follows: struct passwd { char \*pw_name; /\* Username \*/ char \*pw_passwd; /\*

User password \*/ uid_t pw_uid; /\* User ID \*/ gid_t pw_gid; /\* Group

ID \*/ char \*pw_gecos; /\* User information \*/ char \*pw_dir; /\* Home

directory \*/ char \*pw_shell; /\* Shell program \*/ }; See passwd(5) for

more information about these fields. *--snip--*

We’ve found the function we need. The getpwuid() function is given a

user ID and returns a pointer to a passwd structure for the user with that user ID. The passwd structure is summarized on this man page, which

also refers us to the *pwd.h* header file for its declaration. Furthermore, it tells us that there’s a man page in Section 5 named passwd. Since Section 5 contains file formats, this is a description of the password file, named *passwd* in Unix (missing the *or* in *password*).

This man page provides enough information for us to use the

getpwuid() function, but it’s a better idea to learn more about the passwd structure and the *passwd* file before continuing.

*The Password Database*

In Unix systems, all users have an entry in the password database, whose pathname is always */etc/passwd*. That file is a plaintext file, unlike the *lastlog* file, and it’s usually world readable, so you can view its contents

with any of the commands for viewing files, such as less /etc/passwd. Each line in the file represents a single user account, and in Linux it contains seven fields separated by colons. POSIX.1-2024 requires an

implementation to have only five of these fields; the actual password and user information fields are optional. This is what a typical entry looks like: linus:x:501:600:Linus Torvalds:/home/linus:/bin/bash

The first field is the username (linus). The second is the actual

encrypted password, unless it is marked with an x to indicate that the actual password is stored elsewhere. The third field is the user ID (501), and the fourth is the group ID (600). The fifth is traditionally called the *gecos* or *comment* field, and it can contain anything that the system administrator chooses to put there, but it’s often used for the user’s actual name. The next two fields are the absolute pathname of the user’s home directory and their startup shell.

The passwd structure and all functions that work with it are declared

in */usr/include/pwd.h*. The man page for *pwd.h* lists all of the relevant functions, as shown in Listing 5-2.

void endpwent(void);

struct passwd \*getpwent(void);

struct passwd \*getpwnam(const char \*);

int getpwnam_r(const char \*, struct passwd \*, char \*,

size_t, struct passwd \*\*);

struct passwd \*getpwuid(uid_t);

int getpwuid_r(uid_t, struct passwd \*, char \*,

size_t, struct passwd \*\*);

void setpwent(void);

*Listing 5-2: Functions that set and get password database information* We’re going to explore several of these functions shortly, but first let’s see how we can use the getpwuid() function.

The argument of getpwuid() is of type uid_t, which is an integer type.

The return value is a pointer to a passwd structure. The function may

allocate that structure in static memory, which means it can be

overwritten by a subsequent call to any of the functions that return a pointer to a passwd structure. Therefore, if we want to access the

structure’s members at a later time, we have to copy the structure to a

local variable in the program. If not, we just declare a local pointer variable.

Listing 5-3 illustrates how we can use getpwuid() to print the user ID

and username of the user running the program.

*getpwuid_demo.c*

\#include "common_hdrs.h"

\#include \<pwd.h\>

int main(int argc, char \*argv\[\])

{

uid_t userid;

struct passwd \*psswd_struct; /\* To save pointer returned by getpwuid() \*/

/\* Get the real user ID associated with the process, which

is the same as that of the user who runs this command. \*/

userid = getuid();

/\* To get the user name, we retrieve the password structure

from the real user ID using the following function. \*/

psswd_struct = getpwuid(userid);

/\* Print out the user ID with the name, in the same format as the

id command. \*/

printf("uid=%d(%s)\n", userid, psswd_struct-\>pw_name);

return 0;

}

*Listing 5-3: A program that displays the user’s username and user ID*

We compile and build this program using gcc and run it as follows: \$

**gcc -I../include getpwuid_demo.c -o getpwuid_demo** \$

**./getpwuid_demo** uid=500(stewart)

If you do the same on your machine, you’ll see your username and user

ID.

*Accessing All User Entries*

The functions listed in Listing 5-2 have two separate man pages: getpwnam(), getpwnam_r(), getpwuid(), and getpwuid_r() are explained in one

page, and setpwent(), getpwent(), and endpwent() are explained in the second.

These last three functions can be used to iterate through all user entries in the *passwd* file. Their man page explains how this works:

The getpwent() function returns a pointer to a record from the

password database. The first time it’s called, it returns the first

entry; thereafter, it returns successive entries. It returns NULL when there are no more entries or if there’s an error.

The setpwent() rewinds the password database so that the next call

to getpwent() returns the first entry.

The endpwent() function closes the password database.

The man page notes that all three have feature test macro requirements.

To use any of them we need to expose their declarations with the

appropriate \#define macros prior to including the header files. We can either define \_XOPEN_SOURCE with a value of at least 500 or, on systems with version later than *glibc* 2.19, define \_DEFAULT_SOURCE; on systems with older versions of *glibc*, we can instead define \_BSD_SOURCE or \_SVID_SOURCE.

It also notes that neither setpwent() nor endpwent() returns a value and that both always succeed, so we don’t need to check for errors after

calling them; however, because getpwent() can fail, we do have to check for errors after that call.

From their descriptions, it follows that we can first initialize the

iterator with a call to setpwent() and then call getpwent() in a while loop, terminating the loop when its return value is NULL. The program in

Listing 5-4 demonstrates this logic.

*showallusers.c*

\#define \_GNU_SOURCE

\#define \_XOPEN_SOURCE 500

\#include "common_hdrs.h"

\#include \<pwd.h\>

int main(int argc, char \*argv\[\])

{

struct passwd \*psswd_struct; /\* Stores returned record \*/

if ( NULL == setlocale(LC_TIME, "") ) /\* Set the locale. \*/

fatal_error(LOCALE_ERROR,

"setlocale() could not set the given locale");

setpwent(); /\* Initialize the iterator. \*/

errno = 0; /\* Set errno to 0 to detect error from getpwent(). \*/

/\* Repeatedly call getpwent() until it returns NULL. \*/

while ( (psswd_struct = getpwent()) != NULL ) {

/\* Print the pw_name member of the struct. \*/

printf("%s\n", psswd_struct-\>pw_name);

➊ errno = 0;

}

if ( errno != 0 ) {

➋ fatal_error(errno, "getpwent"); endpwent(); /\* Close the passwd database. \*/

return 0;

}

*Listing 5-4: A program that displays all usernames in the password database* First note that the program calls setlocale() to print usernames in a locale-sensitive way, just in case it’s run on a host computer where some user-names use character sets other than US English.

(We discussed locales in Chapter 3. ) Also, the program defines \_XOPEN_SOURCE with a value of 500 to enable the features described in the man page. Finally, note that we repeatedly reset errno to 0 ➊ in order to check its value ➋ after calling getpwent().

We build the executable with: \$ **gcc -Wall -g showallusers.c -**

**I../include -L ../lib -lspl -o showallusers**

The following shows a portion of its output, with most lines deleted

for brevity: \$ **./showallusers** root daemon bin *--snip--* stewart *--*

*snip--* ssd getpwent: No such file or directory

The error message at the very end of the output comes from the

program’s call to fatal_error() ➊.

In “System Call Errors” in Chapter 2, we mentioned that the errno -l command lists all error messages with their symbolic names, numeric

values, and associated message strings. We can run that command, or we can use the -s option to search specifically for this message: \$ **errno -s**

**"No such file or directory"** ENOENT 2 No such file or directory

The man page for getpwent() did not explicitly list this as a return value, which is why we didn’t check for it. It occurs only at the end of the file.

If we want to suppress it, we can modify the preceding if conditional to be (errno != 0 && errno != ENOENT). Aside from this, it seems that the program’s logic can serve as the basis for our implementation of a lastlog command.

Developing a lastlog Program

We’ll design and implement a simple version of the lastlog command.

Initially, it won’t accept any command line options. It will print the last login times of all users of the system.

*Design Considerations*

In the section “Displaying Last Login Information” on page 193, we saw that the *lastlog* file is sparse with large gaps between user records.

Figure 5-5 illustrated a hypothetical *lastlog* file with just a few user records. Because user IDs assigned to users aren’t necessarily

consecutive numbers, we just can’t write a loop such as for ( u =

*lowest_userid*; u \< *highest_userid*; u++ ) // OMITTED: Process lastlog structure for user u.

because a user may not exist for a particular value of the index variable u, and if we try to process a nonexistent record, we’ll be in a file hole. In short, this loop processes every valid record in the file, but it also tries to access nonexistent ones, so it isn’t correct.

We can, however, use the logic from the *showal users.c* program in

Listing 5-4 to iterate over all users and get their user IDs. Specifically, we could use a loop of the following form: setpwent(); while (

(psswd_struct = getpwent()) != NULL ) { u = psswd_struct-\>pw_uid; //

OMITTED: Process lastlog structure for user u. } endpwent();

With this loop, the only records we would access would be those of

actual users, but it also tries to access login records that may not exist.

Some users may never have logged in and therefore would not have a

record in the *lastlog* file. Our algorithm must detect this case. In addition, some user accounts could have been deleted even though there

![](/tmp/audit/iter1/epubregen/system-programming-in-linux/media/index-318_1.jpg)

are valid login records for them in the file, and this loop would not find them.

Another, lesser problem with this approach is that if the *passwd* file has not been managed properly, the entries in the file may not be in

numerically increasing order of user ID. In this case, the successive

reads would bounce back and forth in the *lastlog* file unless we saved the user IDs into an array and sorted them before reading the file. To

demonstrate, the following is a very small fragment of the sequence of user IDs in the *passwd* file of a system I log into frequently:

. .14609,5463,13933,14978,15535,14100,15230,14203,14921,15434,150

50, 14567,15414,14431,15508,6187,14903,14010. .

This list is very unordered, and using these user IDs in the order

getpwent() returns them would cause a lot of long movements of the file offset in the *lastlog* file. Figure 5-6 illustrates the sequence of reads in a hypothetical machine whose password database is very out of order.

*Figure 5-6: The order of reads in the* lastlog *file using the* passwd *structures returned by* *successive calls to* *getpwent()* *on a hypothetical host* If the *lastlog* file spans many disk blocks, the out-of-order reads would be slower than if they were closer together. The problem with

out-of-order reads is a performance issue. The question is whether the time required to store all of the user IDs and sort them before reading any records from the file is greater than the time spent seeking because

the records delivered by getpwent() are not in order. For this program, we won’t sort the records. For a production version, we’d need to study this question further.

We have one other problem. Suppose the highest user ID of all

users who have logged in is 1000. This implies that the *lastlog* file’s highest entry starts at address 1000 × sizeof(struct lastlog). Suppose too that a user in the password database whose user ID is 1200 has never

logged in. When the preceding loop tries to read the record for that

user, which should be at location 1200 × sizeof(struct lastlog) in the file, the program will fail with some type of read error, since that address is beyond the end of the file. We need a way to determine whether the

record we’d like to process is for a user whose user ID is higher than the highest one in the file.

We can solve this problem if we can obtain the size of the *lastlog* file before we start reading. If the file is of size *M* and isn’t corrupted, meaning that it contains only complete lastlog structures, the highest user ID is ( *M* / sizeof(struct lastlog)) – 1.

We can use lseek() to get the size of a file by seeking to the end and saving the returned value of the file offset in a variable: off_t size =

lseek(ll_fd, 0, SEEK_END);

We could also use the stat() system call to get the size of the file, but for this program, we’ll use lseek().

Finally, we need to consider the matter of how time is represented.

The lastlog structure’s time representation is platform dependent, as we discovered in “The lastlog Structure” on page 196. The ll_time member might be one of two different data types, dependent on the macro

condition: \#if \_\_WORDSIZE_TIME64_COMPAT32 int32_t ll_time;

\#else \_\_time_t ll_time; \#endif

The localtime() function, which we’ll call to convert time to broken-

down time, expects a value of type time_t\*. We can’t safely typecast

int32_t\* as an argument to localtime(). For example, if ll_entry is a lastlog struct, writing localtime((time_t\*)&(ll_entry.ll_time)) will fail, because all we’d be doing is casting the pointer type, but the underlying types

might be different.

Instead, we’d have to assign the entry’s time value to a variable of type time_t, as in time_t ll_time = ll_entry.ll_time;

and pass that variable’s address to localtime(). Since we need to do this only if \_\_WORDSIZE_TIME64_COMPAT32 is defined, the code will need to be conditionally compiled based on the value of that macro.

*Program Logic*

Let’s sketch out the program’s logic:

1\. Open the *lastlog* file for reading and handle errors.

2\. Get the size of the *lastlog* file.

3\. Use the size to determine the largest user ID in the *lastlog* file.

4\. Enable localization with a call to setlocale() so that dates and times are locale-sensitive.

5\. Print a header row for the output.

6\. For each entry in the password database:

\(a\) Get the user ID of this entry.

\(b\) Store the username associated with this user ID from the

psswd_struct-\>pw_name member.

\(c\) Check whether the user ID is no greater than the highest

user ID in the file. If it’s greater, treat this as the case of a

user who never logged in by printing a message that the

user never logged in.

\(d\) If the user ID is within the bounds, seek to the start of the

record in the *lastlog* file for that user ID.

\(e\) Read the lastlog structure into a temporary variable, ll_entry.

\(f\) If ll_entry.ll_time is 0, the user never logged in. Print a

message that the user never logged in and skip to the next

record.

\(g\) Either convert the login time stored in ll_entry.ll_time to a

time_t type to pass to localtime(), or if it is already of type

time_t, pass it directly.

(h) Use the broken-down time returned by localtime() in a call to strftime() to get a date/time string lastlog_time with the

default format.

\(i\) Print a line on standard output with the user’s name, the

ll_entry.ll_line, the ll_entry.ll_host, and the login time,

lastlog_time.

Implementing most of the preceding steps is straightforward, so our

next task is to refine them, after which we can write the program. We’ll start with the first step and continue in sequence.

*Writing the Program*

We know how to open the *lastlog* file and handle the potential error: We’ll use the \_PATH_LASTLOG macro defined in *paths.h* as the pathname of the file and let ll_fd store the file descriptor returned by the call to open the file: errno = 0; if ( (ll_fd = open(\_PATH_LASTLOG,

O_RDONLY)) == -1 ) fatal_error(errno, "while opening "

\_PATH_LASTLOG);

We’ll next get the size of a file with the method we described: off_t

ll_file_size = lseek(ll_fd,0, SEEK_END);

Then we’ll get the largest user ID in the file as follows: size_t

ll_struct_size = sizeof(struct lastlog); int highest_uid =

ll_file_size/ll_struct_size - 1;

Given a user ID (uid), to seek to the start of the lastlog structure for that user ID, we simply multiply the user ID by the size of the structure: offset = lseek(ll_fd, ll_struct_size\*uid, SEEK_SET);

All of the pieces are now in place, and we can write the complete

program, which appears in Listing 5-5. To save space, the listing does not contain thorough documentation. A fully documented version is

available in the book’s source code distribution.

*spl_lastlog.c*

\#define \_GNU_SOURCE

\#include "common_hdrs.h"

\#include \<lastlog.h\> /\* For lastlog structure definition \*/

\#include \<paths.h\> /\* For definition of \_PATH_LASTLOG \*/

\#include \<pwd.h\> /\* For password file iterators \*/

\#define MESSAGE_SIZE 512

\#define FORMAT "%c" /\* Default format string \*/

/\* Prints a line for a username who has never logged in \*/

void print_never_logged_in(char \*uname)

{

printf("%-16s %-8.8s %-16s \*\*Never logged in\*\*\n", uname, " ", " ");

}

int main(int argc, char \*argv\[\])

{ struct lastlog ll_entry; /\* To store lastlog record read from file \*/

struct passwd \*psswd_struct; /\* passwd structure from password file \*/

int ll_fd; /\* File descriptor of lastlog file \*/

off_t ll_file_size; /\* Size of lastlog file, in bytes \*/

size_t ll_struct_size; /\* Size in bytes of lastlog structure \*/

size_t num_bytes; /\* Number of bytes read in read() \*/

uid_t uid; /\* User ID of current search \*/

char \*username; /\* Username of current search \*/

int highest_uid; /\* Highest user ID in lastlog file \*/

char lastlog_time\[64\]; /\* Localized date/time string \*/

time_t ll_time; /\* Lastlog time converted to time_t \*/

struct tm \*bdtime; /\* Broken-down time \*/


if ( (ll_fd = open(\_PATH_LASTLOG, O_RDONLY)) == -1 )

fatal_error(errno, "while opening " \_PATH_LASTLOG);

ll_file_size = lseek(ll_fd,0, SEEK_END); /\* Get size of lastlog file. \*/

ll_struct_size = sizeof(struct lastlog); /\* Get size of lastlog struct. \*/

highest_uid = ll_file_size/ll_struct_size - 1;

if ( setlocale(LC_ALL, "") == NULL )

fatal_error(LOCALE_ERROR, "setlocale() could not set

the given locale");

setpwent(); /\* Initialize the passwd file iterator. \*/

printf("Username Port From Last Login\n"); while ( (psswd_struct = getpwent()) != NULL ) {

uid = psswd_struct-\>pw_uid;

username = psswd_struct-\>pw_name;

if ( uid \> highest_uid )

print_never_logged_in(username);

else {

if ( lseek(ll_fd, uid \* ll_struct_size, SEEK_SET) == -1 )

fatal_error(errno, "lseek");


if ( (num_bytes = read(ll_fd, &ll_entry, ll_struct_size)) \<= 0 ) {

if ( 0 != errno ) /\* A read error occurred. \*/

fatal_error(errno, "read");

else { /\* Not a read error - shouldn't happen but continue \*/

error_mssge(-1, "could not read the entry, skipping");

continue;

}

}

else if ( num_bytes != ll_struct_size )

fatal_error(READ_ERROR, "incomplete read of lastlog struct"); if ( 0 == ll_entry.ll_time ) /\* No entry for this user \*/

print_never_logged_in(username);

else {

/\* Convert the lastlog time into broken-down time. \*/

\#if \_\_WORDSIZE_TIME64_COMPAT32

ll_time = ll_entry.ll_time;

bdtime = localtime(&ll_time);

\#else

bdtime = localtime(&(ll_entry.ll_time));

\#endif

/\* The only possible error is EOVERFLOW. \*/

if ( bdtime == NULL )

fatal_error(EOVERFLOW, "localtime");

if ( 0 == strftime(lastlog_time, sizeof(lastlog_time),

FORMAT, bdtime) )

fatal_error(-1, "Conversion to a date-time string failed "

" or produced an empty string\n");

printf("%-16s %-8.8s %-16s %s\n", username,ll_entry.ll_line, ll_entry.ll_host, lastlog_time);

}

}

}

close(ll_fd);

exit(EXIT_SUCCESS);

}

*Listing 5-5: A complete program that prints the last login times for all users with entries in* *the password database* We’ll build the executable and run it to see whether its output matches that of the actual lastlog command shown on page 195. I’ll display the same portions of its output as we displayed there: \$ **./spl_lastlog** *--snip--* sam pts/2

192.168.1.105 Wed 19 Feb 2025 10:01:56 PM EDT lightdm \*\*Never logged in\*\* nm-openvpn \*\*Never logged in\*\* brit pts/2 192.168.1.105 Mon 20 Jan 2025 11:20:50 AM

EDT sshd \*\*Never logged in\*\* *--snip--*

We can manually compare the output of the actual command and our

version of it to see how it differs, running them in separate terminal windows side by side, or we can pipe lastlog’s output to the diff

command, which will output the differences for us: \$ **lastlog \| diff -**

**\<(./spl_lastlog)** 41c41 \< sam pts/2 192.168.1.105 Wed Feb 19

22:01:56 -0400 2025 --- \> sam pts/2 192.168.1.105 Wed 19 Feb 2025

10:01:56 PM EDT 45c45 \< brit pts/2 192.168.1.105 Mon Jan 20

11:20:50 -0400 2025 --- \> brit pts/2 192.168.1.105 Mon 20 Jan 2025

11:20:50 AM EDT

Here, diff is comparing its standard input stream, coming from lastlog, to the \<(./spl_lastlog) pseudofile created by running the spl_lastlog command. The bash notation \<( *command list*) treats the output of *command -*

*list* as a filename. The hyphen tells diff that its first file argument is the standard input stream.

The only differences we find are in the date/time format. We passed

the %c format to strftime(), whereas the Linux implementation passes the format string "%a %b %e %H:%M:%S %z %Y". We can verify this by reading the source code file *lastlog.c*, found in the *shadow-utils* package ( [*https://github.com/shadow-maint/shadow*)](https://github.com/shadow-maint/shadow). Other implementations use still other formats. The differences aren’t very important.

With our implementation, we can also change the locale and see that showlastlog displays the login time in the locale’s format: \$

**LC_TIME=es_ES.utf8 ./spl_lastlog** *--snip--* sam pts/2

192.168.1.105 mié 19 ene 2025 22:01:56 lightdm \*\*Never logged in\*\*

nm-openvpn \*\*Never logged in\*\* brit pts/2 192.168.1.105 lun 20 feb

2025 11:20:50 sshd \*\*Never logged in\*\* *--snip--*

We don’t need to do much testing of this program to see that its output is correct. We also don’t need to be concerned too much about its

performance unless it’s used on systems with a really large number of

users. I leave it as an exercise to determine whether presorting the user IDs will improve performance.

Wrapping up, we chose to implement the lastlog command as a way

to learn more about how to read from arbitrary positions in a file by

seeking to and performing reads at those locations. In the process, we discovered that Unix provides an API for accessing entries in the *passwd* file. That API in effect provides us with an iterator, getpwent(), that returns successive password records.

These represent two different paradigms for file access. To obtain

data from one file, *lastlog*, we have to explicitly move the file offset with lseek() and call read() to retrieve the file’s data. We call this *explicit seeking* *and reading.* For the other file, *passwd*, we didn’t need to move the file offset or read explicitly, but instead used functions from a small API associated with that file to retrieve data. We call this method *API-based* *reading*. The differences between them are:

With explicit seeking and reading, we can control more precisely

how and when the transfers are made than we can by using API-

based reading.

With explicit seeking and reading, the burden is on us to make sure

that we haven’t made mistakes in accessing the file, and if we don’t

design the code well, it may perform poorly.

By using API-based reading, we simplify our programming task

considerably because we use code implemented by the library’s

programmers.

If the API changes, we might have to make changes to our program, which would not be the case if we were to explicitly read

from the file.

Our implementation of spl_lastlog was a hybrid approach.

In the remainder of this chapter, we’ll explore other system

databases stored in world-readable files that have APIs for accessing

their records.

Developing a last Command

In our search for commands that could display last login times (see

“Displaying Last Login Information” beginning on page 193), we came across a command named last. There we learned that it extracts

information from a file named *wtmp*. We’re now going to develop an implementation of that command, along the way learning about the

*wtmp* file, the structure of its data, and the various issues related to login records in general. Let’s start by reading the man page for last, which begins with: LAST(1) User Commands LAST(1) NAME last, lastb -

show a listing of last logged in users SYNOPSIS last \[options\]

\[username. .\] \[tty. .\] lastb \[options\] \[username. .\] \[tty. .\]

DESCRIPTION last searches back through the /var/log/wtmp file (or

the file designated by the -f option) and displays a list of all users logged in (and out) since that file was created. *--snip--*

The page also describes a lastb command, but when we read further, we

discover that lastb only displays what it calls *bad login attempts*, meaning those that failed, and only users with superuser privilege can run it.

It’s important to observe that last searches *backward* in the *wtmp* file, not forward. The most recent entries are listed first. If we run last

without any options on a computer that has multiple active user

accounts, we’ll see output such as: *--snip--* l.fishburne pts/1

69.114.124.124 Fri Feb 28 19:19 still logged in v.gallo pts/21

104.162.60.115 Fri Feb 28 18:57 - 21:26 (02:29) s.okonedo pts/16

173.52.89.136 Fri Feb 28 18:53 gone - no logout ➊ m.sheen pts/14

172.58.231.252 Fri Feb 28 18:29 - 02:53 (08:24) csguest tty3 tty3 Fri

Feb 28 18:27 - 19:53 (01:36) s.buscemi pts/14 146.95.73.100 Fri Feb 28

18:26 - 18:27 (00:01) ➋ m.farrow pts/9 151.202.41.80 Fri Feb 28 18:11

\- 19:40 (1+01:29) reboot system boot 5.15.0-57-generi Thu Feb 27

13:56 still running *--snip--* wtmp begins Wed Jan 1 08:11:55 2025

The final line of output is the date of the first entry recorded in the database used by last.

If we run last -x, we get more system-related events, such as runlevel (to lvl 5) 5.15.0-71-generi Sat May 13 13:06 - 13:16 (00:10) reboot

system boot 5.15.0-71-generi Sat May 13 13:06 - 13:16 (00:10)

shutdown system down 5.15.0-71-generi Sat May 13 10:52 - 13:06

(02:13)

Neither the man page nor the Info page describes the individual fields of output, so let’s go through what those fields contain. The default

output is a sequence of lines, each containing information about either a user login or some type of system activity.

The first (leftmost) field is either a username or a description of a

system event, such as reboot. For user logins, the next field is an

indication of how the user was connected to the system. This can be

through a pseudoterminal (for example, pts/21) or through a virtual

console or the desktop environment (for example, tty3). For user logins, this field is also called the *line* (which is what we called it when we developed the spl_lastlog program). For system events, this field is a description of the event, such as system boot. A runlevel event is a change in the runlevel of the system. *Runlevels* essentially define the services available to ordinary users. The lowest user runlevel gives the user a terminal interface and no desktop, for example.

The next field indicates from where the user logged in, either the

remote host’s internet address or sometimes its fully qualified internet name or, for system events, the name of the kernel.

The next fields are, for user logins, the times at which the user

logged in and then logged out followed by the total time of that session in the format ( *hours*: *minutes*). The width of a line would be too long if last displayed both the start time and end time of a login session in the

full date/time format, such as: . . Fri Feb 28 18:29:22 2025 - Sat Mar 01

15:53:31 2025 . .

Instead, it omits the seconds in both times and displays only the hour and minute of the ending time: . . Fri Feb 28 18:29 2025 - 15:53 . .

The nuance is that a login session can end on a day after the one in

which it began at a time possibly earlier in the day than the login time, so that the end time is a smaller time value than the start time, such as Fri Feb 28 18:29 - 02:53 ➊. That second number by itself doesn’t tell us that the time was the following day. It could be two, three, or more days later. The session length tells us this information. It can include a count of days and will look like (1+01:29) ➋, meaning one day, one hour, and 29

minutes. We need to look at the session length to know on which day

the end time occurred.

If the session is still active, instead of a time value, the field contains the text still logged in. On rare occasions, and the previous output is such an occasion, instead of the still logged in message, the last

command reports gone - no logout. This is the result of last’s detecting corrupted information about a user, such as a change during a session in the user’s username or user ID, or a user who was not logged out

automatically when the system was rebooted or shut down. For system

events, this field might contain status information such as still running or crash.

It is from this field that you can see that the more recent entries

precede the older ones in the output.

Unix has a few other, similar commands for listing information

about logins. One is the who command. Its man page states that it

displays information about users who are currently logged in. It’s useful on systems in which most people log in remotely and you’re interested

in knowing whether certain users are logged in. If we run who, we see

output such as: c.deneuve pts/2 2025-02-01 00:14 (151.202.41.80)

s.aghdashloo pts/1 2025-02-01 00:20 (73.48.77.155) k.russell pts/1

2025-02-01 09:39 (165.155.132.86) c.rains pts/2 2025-02-01 10:10

(146.111.116.2)

Here, each line represents a currently active login session. The first column is the username; the second is the device special file of the user’s terminal; the third is the time at which that user logged in on that

terminal; and the last is the source of the login, either the hostname if it’s known or its internet address. For example, k.russell was logged in on terminal line pts/1, the session started at 9:39 on February 1, 2025, and the login was initiated from a device with internet address

165.155.132.86. Unlike last, who does not show anything about past logins.

*Login Records*

To learn more about login records, we first look at the NOTES, FILES, and SEE ALSO sections of last’s man page. For last, NOTES are mostly for system administrators, and we can ignore them. The FILES section mentions two files: */var/log/wtmp* and */var/log/wtmpb*. The SEE ALSO section suggests reading the wtmp(5) man page. We’ll read that page to learn about the

files and data structures related to the command, hoping that they’ll

contain what we need to write the program. The wtmp(5) man page

begins with: UTMP(5) Linux Programmer's Manual UTMP(5) NAME

utmp, wtmp - login records SYNOPSIS \#include \<utmp.h\>

DESCRIPTION The utmp file allows one to discover information

about who is currently using the system. There may be more users

currently using the system, because not all programs use utmp logging.

Warning: utmp must not be writable by the user class "other", because many system programs (foolishly) depend on its integrity. . *--snip--*

The file is a sequence of utmp structures, declared as follows in

\<utmp.h\> (note that this is only one of several definitions around; details depend on the version of libc): *--snip--*

We observe first that utmp and wtmp share a man page and that both *wtmp* and *utmp* are files containing sequences of structures. The warning on the page is directed at system administrators—they should not set the

*utmp* file’s permissions too weakly because it makes the system vulnerable to attack. The page then describes the content and format of the *utmp* file, which stores information about logins in a sequence of utmp structures. The *wtmp* file is also a sequence of utmp structures, but they’re processed in a slightly different way, which we’ll cover shortly.

The utmp structure is declared in the *utmp.h* header file. The parenthetical note at the end is important; it tells us that this man page describes just one possible definition of the utmp structure, which may be different from that used by other Unix systems. If we design a program based on this definition, it may not run on other Unix systems.

Whenever we see this type of warning, we should read the CONFORMING TO

section of the man page. There, we learn that POSIX.1 doesn’t specify a utmp structure, instead defining a utmpx structure, whose declaration is exposed by including the *utmpx.h* header file. We need to read about the differences and make a decision. If our program is designed to use the utmpx structure, it will be portable to POSIX-compliant systems, but if it is based on the utmp structure, it may not be.

HISTORICAL BACKGROUND ON UTMP AND

WTMP

The *utmp* and *wtmp* files have been a part of many Unix systems since its beginnings. Initially there was a single definition of a utmp structure and a set of functions for accessing and modifying it, in

essence a mini-API, which we’ll call the *traditional* *utmp* *API*. This original API had several disadvantages, so as Unix evolved and

diverged, different systems created alternative definitions, and

System V and its derivatives introduced a utmpx structure and API.

The *x* was added to the name of the structure as well as files

containing them so that there were two parallel systems of files

and data definitions. Eventually, POSIX made the utmpx API part of

the standard. This standard included functions for accessing and

modifying the structure, which we’ll call the *utmpx* *API*. Linux resolved the discrepancies by providing both the traditional utmp

and the utmpx APIs for accessing the contents of these files. On

Linux systems, these two APIs return exactly the same

information.

We’ll start by exploring the utmp structure, because that was the first one historically and also because the utmpx structure was derived from it.

The remainder of this discussion is specific to Linux.

*The utmp Structure*

The man page description of the utmp structure begins with the

following macros: \#define EMPTY 0 /\* Record does not contain valid

info (formerly known as UT_UNKNOWN on Linux) \*/ \#define

RUN_LVL 1 /\* Change in system run-level \*/ \#define BOOT_TIME 2

/\* Time of system boot \*/ \#define NEW_TIME 3 /\* Time after system

clock changed \*/ \#define OLD_TIME 4 /\* Time before system clock

changed \*/ \#define INIT_PROCESS 5 /\* Process spawned by init(1) \*/

\#define LOGIN_PROCESS 6 /\* Session leader of user login \*/ \#define

USER_PROCESS 7 /\* Normal process \*/ \#define DEAD_PROCESS 8

/\* Terminated process \*/ \#define ACCOUNTING 9 /\* Not

implemented \*/ \#define UT_LINESIZE 32 \#define UT_NAMESIZE

32 \#define UT_HOSTSIZE 256

The first 10 are the possible values of the ut_type member of the

structure, which defines the type of entry it represents, because Unix systems typically record events besides logins in the file. (We’ll explain this shortly in “Logins, Logouts, and the utmp and wtmp Files” on page

220. ) The next three are macros for the sizes, in bytes, of three members of the structure that are strings. After these, we see the type of the ut_exit member of the structure: struct exit_status { /\* Type for ut_exit, below \*/ short int e_termination; /\* Process termination status \*/ short int e_exit; /\* Process exit status \*/ };

Finally, we see the declaration of the utmp struct itself: struct utmp {

short ut_type; /\* Type of record \*/ pid_t ut_pid; /\* PID of login process

\*/ char ut_line\[UT_LINESIZE\]; /\* Device name of tty - "/dev/" \*/ char ut_id\[4\]; /\* Terminal name suffix \*/ char ut_user\[UT_NAMESIZE\]; /\*

Username \*/ char ut_host\[UT_HOSTSIZE\]; /\* Hostname for remote

login, or kernel version for run-level messages \*/ struct exit_status

ut_exit; /\* Exit status of a process marked as DEAD_PROCESS \*/ /\*

The ut_session and ut_tv fields must be the same size when compiled

32- and 64-bit. This allows data files and shared memory to be shared

between 32- and 64-bit applications. \*/ ➊ \#if \_\_WORDSIZE == 64 && defined \_\_WORDSIZE_COMPAT32 int32_t ut_session; /\* Session ID

(getsid(2)), used for windowing \*/ struct { int32_t tv_sec; /\* Seconds \*/

int32_t tv_usec; /\* Microseconds \*/ } ut_tv; /\* Time entry was made \*/

\#else long ut_session; /\* Session ID \*/ struct timeval ut_tv; /\* Time

entry was made \*/ \#endif int32_t ut_addr_v6\[4\]; /\* Internet address of remote host; IPv4 address uses just ut_addr_v6\[0\] \*/ char \_\_unused\[20\];

/\* Reserved for future use \*/ };

Before digging into the details of this data structure, let’s get a sense of the content and purpose of its important members:

**ut_type** Indicates the type of the entry—whether it’s a login entry, a boot entry, a shutdown entry, and so on

**ut_pid** Stores the process ID of the process that created the entry, which for login entries is the user’s login process

**ut_line** Stores the name of the terminal device of the login, such as *pts/1*, which is called the *line*

**ut_id** A string that’s unique to each entry, serving as an identifier for that entry

**ut_tv** Records the time that the record was created (see “Logins, Logouts, and the utmp and wtmp Files” on page 220 for more details)

**ut_user** For logins, contains the username, and for other types of entries, stores other identifying information

**ut_host** Stores the name of the remote host from which the

connection was made

Some of the details warrant more explanation. The conditional

macro ➊preceding the declaration of the ut_tv member has the same

meaning as the one we saw in “The lastlog Structure” on page 196 in the definition of the struct lastlog. The preceding comment explains why it’s there, and a comment in the NOTES section explains further. It ensures that if the machine is a 64-bit machine that allows 32-bit applications to

run, ut_session is 4 bytes (int32_t) and ut_tv is 8 bytes (two int32_t members) for all applications. If it’s a 32-bit machine, all applications see these same sizes for these members. If it’s a 64-bit host not allowing 32-bit applications to run, these members are larger, since the struct timeval will be 16 bytes, and a long is 8 bytes. We’ll have to use a feature test macro, as we did in Listing 5-5, in order to access the ut_session and ut_tv members in our final program.

The man page then describes how the entries in the utmp file are

created and updated by various processes when you log in and log out,

which we’ll discuss soon. It also reiterates the following warning: The file format is machine dependent, so it is recommended that it be

processed only on the machine architecture where it was created.

The fact that this warning appears twice on the page is not to be

overlooked. It implies that we should expect our program to run

correctly only on the architecture on which we compile it.

The man page doesn’t list any functions specifically tied to the utmp

structure definition, but in the SEE ALSO section, it does reference various library functions such as getutent() and getutmp() from Section 3 of the man pages. The page for getutent() has a warning that this function, as well as all others sharing its page, are obsolete in non-Linux systems and that POSIX.1 instead defines a corresponding set of functions with an x in their names, such as getutxent() instead of getutent(). These functions are just aliases for their counterparts without the x, so we’re not going to look at the functions in the Linux utmp API. Instead, we’ll study and use the Linux utmpx API in order to make our programs more portable.

*The utmpx API*

Let’s find the POSIX.1 specification of the utmpx API with this man page search: \$ **apropos utmpx** getutmp (3) - copy utmp structure to utmpx, and vice versa getutmpx (3) - copy utmp structure to utmpx, and vice

versa sessreg (1) - manage utmpx/wtmpx entries for non-init clients

utmpx (5) - login records utmpx.h (7posix) - user accounting database

definitions utmpxname (3) - access utmp file entries

The utmpx.h man page is a POSIX specification of the API. It shows that the POSIX.1 utmpx structure has only six members: char ut_user\[\] /\*

User login name \*/ char ut_id\[\] /\* Unspecified initialization process identifier \*/ char ut_line\[\] /\* Device name \*/ pid_t ut_pid /\* Process ID

\*/ short ut_type /\* Type of entry \*/ struct timeval ut_tv /\* Time entry was made \*/

Even though POSIX.1 requires fewer members, the Linux utmp man

page tells us that “Linux defines the utmpx structure to be the same as the utmp structure.” In Linux, both structures contain the 10 members

defined in the man page. If our programs reference the non-POSIX

members, they may not run correctly on non-Linux systems.

The functions shown in the POSIX.1 utmpx.h man page are the

following: void endutxent(void); struct utmpx \*getutxent(void); struct utmpx \*getutxid(const struct utmpx \*); struct utmpx \*getutxline(const

struct utmpx \*); struct utmpx \*pututxline(const struct utmpx \*); void

setutxent(void);

They’re declared in the *utmpx.h* header file, which our programs will need to include.

*Logins, Logouts, and the utmp and wtmp Files*

Both the *utmp* and *wtmp* files are updated when a user logs in and logs out, but they serve different purposes and are processed in different

ways. In order to write any program that uses their data, we need to

understand how both files are processed.

The *utmp* file stores information about who is currently logged in, but it’s also used to record events such as boots, reboots, and changes in the operating system’s runlevel. In contrast, the *wtmp* file is an audit file that records not just current logins but also logouts, as well as boots, reboots, and the same other events as *utmp* does.

When a user logs in, a record for that login is created in both the

*utmp* and *wtmp* files. The contents of that record depend on how the user logged in: directly from the machine’s GUI desktop, such as the

GNOME Desktop Manager (GDM) on a Linux machine, remotely via

a network protocol such as SSH, through an XTERM window, and so

on. Following is a superficial description of the sequence of actions that take place when a user logs in:

When a Unix system is booted, after the kernel performs all initializations, enables interrupts, and all other startup actions, it creates the first user-level process, whose process ID is 1. This

process was traditionally named init, but in Linux it’s now named

systemd. We’ll call it init here since it is still referred to in the

documentation by this name. This init process is the ancestor of all

processes in a UNIX system: All processes ever created are directly

or indirectly created by it. It monitors the activities of all processes and also manages what takes place when the computer is shut

down.

The init process uses information about available terminal devices

on the system, such as consoles, modems, network ports, and so on,

to create, for each device, a process that will listen for activity on that device. These devices are called *lines*. Some of the listening processes have names like getty, mingetty, and so on. The name *getty* is short for “get tty.”

TTYS

The term *tty* is short for “teletype.” A *teletype* is the precursor to the modern computer terminal. Teletype machines came

into existence as early as 1906, but it wasn’t until around 1930

that their design stabilized. Teletype machines were

essentially typewriters that converted the typed characters

into electronic codes that could be transmitted across

electrical wires. Modern computer terminals inherit many of

their characteristics from teletype machines.

Each getty process configures the terminal device, displays a

prompt such as login:, and waits for the user to enter a username

and password. Simplifying the rest of what takes place, once the

login is authenticated, an entry is created in the *utmp* and *wtmp* files for that login.

Some systems use other means of authenticating logins, such as pluggable authentication modules (PAM), for this purpose. PAM is a

library of dynamically configurable authentication routines that can be selected at runtime to do various authentication tasks, not just logins.

When a system uses PAM, different software creates the login entries.

Similarly, the handling of network logins is different. These are

usually derived from the BSD network login mechanism. Network

logins don’t use physical terminals, so there’s no way to know in advance how many terminals must be initialized. In addition, the connection

between the terminal and the computer is a network service, such as

SSH or SFTP.

With network logins, init creates a process that will listen for the

incoming network requests for logins. For example, if the system

supports logging in through SSH, then init creates a process named

sshd, the SSH daemon, which in turn creates a new process for each

remote login. These new processes will in turn create a pseudoterminal driver, which then spawns the login process that does everything

described previously, including creating the *utmp* and *wtmp* entries, but again with slightly different content.

To summarize, there are different paths to the creation of these

login records in the two files, and these paths as well as the contents of the record depend on the login method. Regardless of how the login

takes place, for each login, the ut_type of the record is set to USER_PROCESS

in both the *utmp* and the *wtmp* files, and the ut_user member is set to the user’s username.

When a user logs out, changes are made to both the *utmp* and *wtmp* files, and those changes depend on which processes handled the login

entries. The changes made to the *utmp* file are different from the changes made to the *wtmp* file. In the *utmp* file, the login record of the user who is logging out is essentially erased. However, in the *wtmp* file, the process that updates the file appends a new record to it and doesn’t modify the user’s login record. The content of that record also depends upon on which form of login took place initially, whether through the

console, over a network, and so on.

It would be a lot easier to understand if we could display the contents of these binary files. If we had a program that could display their raw contents converted to human-readable form, we’d also be able to debug our implementation of last when we start testing it. In

addition, it’s a good warm-up exercise for us to write this program.

Since both files are sequences of utmpx structures, we’ll design the

program, which we’ll name spl_utmpdump, so that by default it displays the *utmp* file but with the optional command line argument wtmp, displays the *wtmp* file, as in \$ **./spl_utmpdump** \# Display the utmp file.

or:

\$ **./spl_utmpdump wtmp** \# Display the wtmp file.

The second form will always display the current *wtmp* file. This approach won’t allow us to display older *wtmp* files such as

*/var/log/wtmp.1*. Printing the raw contents of a file in a human-readable format is commonly called *dumping* the file.

*A Program to Show the utmp and wtmp Files*

To start, since we’ll be writing a few programs that require the *utmpx* header file, we’ll append the line \#include \<utmpx.h\>

to the *sys_hdrs.h* header file that we defined in Chapter 3. We’ll develop the program from the bottom up, starting with the functions that print various pieces of information.

First, we’ll write a function, print_ut_type(), partially shown in Listing

5-6, for converting the integer ut_type field to a string such as "USER

PROCESS" for the symbolic constant that the integer represents.

print_ut_type()

void print_ut_type(int t)

{

switch ( t ) {

case RUN_LVL: printf("RUN_LVL "); break;

case BOOT_TIME: printf("BOOT_TIME "); break;

*--snip--*

case DEAD_PROCESS: printf("DEAD_PROCESS "); break;

case ACCOUNTING: printf("ACCOUNTING "); break;

}

}

*Listing 5-6: A function that prints the string associated with each* *ut_type* *value* We make the width of the field large enough to display the longest strings and pad the shorter ones with spaces on the right.

Next, we write a relatively simple function, print_one_rec(), that will display the fields of a single utmpx structure. The only challenges are in formatting field widths and using the feature test macro that ensures

that it compiles correctly for 32-bit and 64-bit architectures, with and without 32-bit application support. We’ll pick a field width of nine

characters for the username. Many systems allow much longer

usernames, so we may want to change this. Listing 5-7 contains the complete function.

print_one_rec()

void print_one_rec(struct utmpx \*utbufp)

{

struct tm \*bdtime;

char timestring\[64\];

print_rec_type(utbufp-\>ut_type);

printf("%-6d ", utbufp-\>ut_pid); /\* Process id \*/

printf("%-8.8s ", utbufp-\>ut_user); /\* User name \*/

printf("%-8.8s ", utbufp-\>ut_id); /\* utmp id \*/

printf("%-8.8s ", utbufp-\>ut_line); /\* Line \*/

➊ \#ifdef SHOW_EXIT

printf("%-3d ", utbufp-\>ut_exit.e_exit);

printf("%-3d ", utbufp-\>ut_exit.e_termination);

\#endif

if ( utbufp-\>ut_host\[0\] != '\0' )

printf(" %-18s", utbufp-\>ut_host); /\* Host \*/

else

printf(" %-18s", " "); ➋ \#if \_\_WORDSIZE_TIME64_COMPAT32

time_t utmp_time = utbufp-\>ut_tv.tv_sec;

bdtime = localtime(&utmp_time);

\#else

bdtime = localtime(&(utbufp-\>ut_tv.tv_sec));

\#endif

if ( bdtime == NULL )

fatal_error(EOVERFLOW, "localtime");

if ( 0 == strftime(timestring, sizeof(timestring),"%c", bdtime) ) fatal_error(-1, "Conversion to a date-time string failed "

" or produced an empty string\n");

printf("%s\n", timestring);

}

*Listing 5-7: A function to print a single* *utmpx* *record* The code uses the printf() format specifier %-8.8s for the username field. In %-8.8s, the - means left justify, and the 8.8s means use exactly eight characters. If a string is smaller, it’s padded on the left; if larger, it’s truncated on the right. We also conditionally compile ➊ the code that displays the ut_exit status to reduce the width of the output when it’s too long to display.

If we compile this program using \$ **gcc -DSHOW_EXIT**

**spl_utmpdump.c** . .

the exit status fields will be part of the output.

If instead we compile with \$ **gcc spl_utmpdump.c** . .

they’ll be omitted.

The feature test macro ➋ is just like the one we used in the

spl_lastlog program. If the program is compiled on a 64-bit machine that can run 32-bit applications, it converts the time to a time_t value through assignment to a variable of type time_t and then passes this variable’s address to localtime(). Otherwise, it passes the address of the struct timeval’s tv_sec member directly. Also, notice that we continue to use the strftime() function for converting broken-down time to a string

representation in a locale-sensitive way.

Next is a little function that prints the header row for the output,

which is also conditionally compiled to include or exclude the exit status heading: print_header_row() /\* print_header_row prints a heading for

the output. \*/ void print_header_row() {

printf("%-14s%-7s%-9s%-9s%-9s", "TYPE", "PID", "USER", "ID",

"LINE"); \#ifdef SHOW_EXIT printf("%-9s", "STATUS"); \#else printf(" "); \#endif printf("%-19s%-16s\n", "HOST", "TIME"); }

Field widths are hardcoded into it. If they need to be tweaked later, it would be better to pass them into the function as parameters, using the printf() feature that allows field widths to be passed as arguments, as in: printf("%-\*s", size, str) /\* str will be printed left-justified in a field of width size. \*/

We’re ready to design the main program, which will use the utmpx

API for reading the utmpx records rather than the kernel’s read() system call. Its outline is:

1\. Check whether the user passed wtmp as an argument.

2\. If so, call utmpxname(WTMPX_FILE) to open the *wtmp* file.

3\. Otherwise, call utmpxname(UTMPX_FILE) to open the *utmp* file.

4\. Print a header row using print_header_row().

5\. Initialize reading from the file with setutxent(), and set errno to 0.

6\. While utmpx_entry = getutxent() is successful, call print_one_rec(utmpx \_entry).

7\. Check whether the loop exited because the end of the file was

reached or because errno was set, and handle the error in this case.

8\. Call endutxent() to close the file.

Listing 5-8 contains the complete program with the previously defined helper functions omitted to save space.

*spl_utmpdump.c*

\#define \_GNU_SOURCE

\#include "common_hdrs.h"

void print_header_row()

{

// OMITTED: Body of function

}

void print_rec_type(int t)

{

// OMITTED: Body of function

}

void print_one_rec(struct utmpx \*utbufp)

{

// OMITTED: Body of function

} int main(int argc, char \*argv\[\])

{

struct utmpx \*utmp_entry; /\* For returned pointer from getutxent \*/

if ( (argc \> 1) && (strcmp(argv\[1\], "wtmp") == 0) ) {

if ( -1 == utmpxname(WTMPX_FILE) )

fatal_error(errno, "utmpname()");

}

else if ( -1 == utmpxname(UTMPX_FILE) )

fatal_error(errno, "utmpname()");

print_header_row();

setutxent();


while( (utmp_entry = getutxent()) != NULL )

print_one_rec(utmp_entry);

if ( 0 != errno )

fatal_error(errno, "getutxent()");

endutxent();

return 0;

}

*Listing 5-8: A program that dumps the* utmp/wtmp *file in a human-readable format* We’ll build the showutmp executable defining SHOW_EXIT

\$ **gcc -DSHOW_EXIT spl_utmpdump.c -I../include -L ../lib -lspl -o spl_utmpdump** and run it on our *wtmp* file to see what we can observe from the output.

In the first run, we discover that both fields of the exit status of all records are zeros. To reduce the width of this output, we rebuild showutmp without defining SHOW_EXIT and run it again, which results in the

following output: \$ **./spl_utmpdump wtmp** TYPE PID USER ID LINE

HOST TIME RUN_LVL 53 runlevel \~~ ~ 5.15.0-71-generic Tue Feb

25 08:11:55 2025 INIT_PROCESS 1993 tty1 tty1 Tue Feb 25 08:11:55

2025 LOGIN_PROCESS 1993 LOGIN tty1LOGI tty1 Tue Feb 25

08:11:55 2025 USER_PROCESS 2297 stewart :0 tty7 :0 Tue Feb 25

08:13:03 2025 USER_PROCESS 6988 stewart ts/0stew pts/0 :0 Tue

Feb 25 08:33:37 2025 DEAD_PROCESS 6965 stewart ts/0stew pts/0

Tue Feb 25 10:50:08 2025 DEAD_PROCESS 0 stewart :0 tty7 :0 Tue

Feb 25 10:52:10 2025 RUN_LVL 0 shutdown \~~ ~ 5.15.0-71-generic

Tue Feb 25 10:52:21 2025 BOOT_TIME 0 reboot \~~ ~ 5.15.0-71-

generic Tue Feb 25 13:06:09 2025 RUN_LVL 53 runlevel \~~ ~ 5.15.0-

71-generic Tue Feb 25 13:06:32 2025 INIT_PROCESS 1967 tty1 tty1

Tue Feb 25 13:06:32 2025 LOGIN_PROCESS 1967 LOGIN

tty1LOGI tty1 Tue Feb 25 13:06:32 2025 USER_PROCESS 2327

stewart :0 tty7 :0 Tue Feb 25 13:08:27 2025 DEAD_PROCESS 0

stewart :0 tty7 :0 Tue Feb 25 13:16:30 2025 USER_PROCESS 7210

jl.trint ts/1mero pts/1 24.46.119.86 Sat Mar 1 09:16:43 2025

USER_PROCESS 7342 r.griffi ts/2njia pts/2 146.95.38.217 Sat Mar 1

10:13:57 2025 USER_PROCESS 7348 b.pepper ts/4meli pts/4

24.90.66.208 Sat Mar 1 10:16:08 2025 USER_PROCESS 7367 m.grace

ts/5harm pts/5 148.74.161.63 Sat Mar 1 10:16:21 2025

USER_PROCESS 7389 m.richar ts/6weig pts/6 67.245.64.80 Sat Mar 1

10:16:42 2025 DEAD_PROCESS 0 pts/5 Sat Mar 1 10:22:28 2025

DEAD_PROCESS 0 pts/6 Sat Mar 1 10:46:29 2025 *--snip--*

Notice that the program prints all of the fields correctly in suitable column widths. Also, observe that the file stores records other than user login and logout events. Our focus here isn’t on those records, but on the USER_PROCESS and DEAD_PROCESS records.

In the very first USER_PROCESS record, the line is tty7 and the ID is :0.

This corresponds to a login on the computer’s desktop. GDM assigns

lines of the form ttyx, where x is a number, to these logins. The ID is assigned the value :0, which refers to the computer’s actual screen

display. When I logged out on that day, a logout entry for that same line was written to the file: DEAD_PROCESS 0 stewart :0 tty7 :0 Tue Feb

25 10:52:10 2025

The username field was not erased. The same is true for the login on

pts/0: when I logged out, as shown in that logout record:

USER_PROCESS 6988 stewart ts/0stew pts/0 :0 Tue Feb 25 08:33:37

2025 DEAD_PROCESS 6965 stewart ts/0stew pts/0 Tue Feb 25

10:50:08 2025

On the other hand, the logout records for all of the other logins on

lines whose names are of the form pts/x have had their usernames

erased. This difference is exactly what we discussed in “Logins, Logouts, and the utmp and wtmp Files.” The man page for utmp and wtmp states

only that “the wtmp file records all logins and logouts. Its format is exactly like utmp except that a NULL username indicates a logout on the associated terminal.” The converse is not true. The entry for a logout on a terminal does not necessarily have a NULL username.

*Analysis of the wtmp File*

Our next goal is to use our observations about the *wtmp* file to develop an algorithm for the last command. To start, let’s ignore the effect of system events on what it displays, concentrating exclusively on user

logins and logouts. The command has to find, for each user login

record, the matching user logout record.

We’ll consider an abstract version of the file, in which we remove all information not relevant to this problem, including the PID, ID, HOST, TIME, and the exit status fields of each record. We’ll also remove the records that are not either user logins or logouts. We’re left with a file such as: USER_PROCESS stewart tty7 USER_PROCESS stewart pts/0

DEAD_PROCESS stewart pts/0 DEAD_PROCESS stewart tty7

USER_PROCESS stewart tty7 DEAD_PROCESS stewart tty7

USER_PROCESS jl.trint pts/1 USER_PROCESS r.griffi pts/2

USER_PROCESS b.pepper pts/4 USER_PROCESS m.grace pts/5

USER_PROCESS m.richar pts/6 DEAD_PROCESS pts/5

DEAD_PROCESS pts/6 DEAD_PROCESS pts/4 DEAD_PROCESS

pts/1 DEAD_PROCESS pts/2

For every USER_PROCESS entry, if that user has logged out, there’s a unique DEAD_PROCESS entry with the same terminal line. Terminal lines are unique

—no two users can be logged in at the same time on the same line—and

this implies that if we know the line on which a user logged in, we can find the logout record by searching for a DEAD_PROCESS record with the same line that occurs most recently in time after that login.

We can think of this problem in an even more abstract way. Suppose we represent a user login on a line with a unique left bracket. Since the keyboard doesn’t have an unlimited supply of different types of left

brackets, I’ll use a notation consisting of a left square bracket symbol subscripted with a unique integer, such as \[1 or \[2, to represent a unique left bracket type. The matching logout record will be a right square

bracket indexed with the same number, \]1 or \]2, respectively. A sequence of logins and logouts can then be viewed as a string of these brackets with the following constraints:

For every right bracket \] *x*, there is a matching left bracket \[ *x* to the left of it in the string.

There are no two occurrences of a left bracket \[ *x* without an

intervening occurrence of its matching right bracket \] *x*.

There are no two occurrences of a right bracket \] *x* without an

intervening occurrence of its matching left bracket \[ *x*.

For every left bracket \[ *x*, the leftmost matching right bracket \] *x* that occurs to the right of that left bracket is the matching right bracket for that left bracket. If no such right bracket exists, it implies that the user whose login is represented by that left bracket has not yet

logged out.

If we use the number following the pts/ as the subscript of the

bracket and *a* for the subscript of the tty7 line, then our data would be represented by the string: \[ *a* \[0 \]0 \] *a* \[ *a* \] *a* \[1 \[2 \[4 \[5 \[6 \]5 \]6 \]4 \]1 \]2

This abstraction of the *wtmp* data can help us to solve the problem of finding logouts that match logins. It’s like searching a string of brackets.

The complication is that the last command searches backward

through the file, printing the most recent login sessions first. In essence, it travels back in time as it processes the *wtmp* file, because at any given step, the record it has just read has a timestamp that is older than all of the ones it’s read before it. By reading the entries in reverse order, it sees

newer entries before older ones. Our algorithm needs to do the same, making it a bit harder to understand.

As we process this string in right-to-left order, in effect, we’re going back in time. When we see a right square bracket, for example, we know that it should be the matching bracket for some left square bracket that we’ve yet to see, representing an event that took place earlier in time.

We don’t know when we’ll see it, meaning how far to the left it’ll be.

Therefore, we have to squirrel this bracket away in a safe place, such as in a linked list, and move on.

We’ll solve this problem by creating an initially empty, doubly

linked list, which makes deletions easier. For the sake of precision, let’s name it saved_ut_recs. The idea will be to search the string in right-to-left order, starting from the rightmost entry, marching backward in time

toward the beginning. When we find a right bracket, we push it onto

the front of saved_ut_recs. When we find a left bracket, we search the saved_ut_recs list starting at its first node for the first occurrence of its matching right bracket. If we find it, we record the login and logout

times that it represents and delete the right bracket from the list. If we don’t find it, the user whose logout it represents is still logged in.

Notice that we can’t use a stack to solve this problem because the

brackets can be interleaved, as our sample data showed. We’d have to

pop items off of the stack until we found the correct one and then push back the ones that we removed.

We haven’t yet taken into consideration the effect of the records

related to runlevel changes, boots, reboots, and shutdowns. When the

machine is shut down or rebooted, under normal circumstances, any

logged-in users are logged out automatically. The result is that struct utmpx entries of type DEAD_PROCESS are appended to the file for all of these logouts. Therefore, we need to identify shutdown and reboot records.

Shutdown records are those that satisfy the following equalities:

ut_type == RUN_LVL ut_user == "shutdown" ut_line == "~"

Boots and reboots are those that satisfy these equalities: ut_type ==

BOOT_TIME ut_user == "reboot" ut_line == "~"

Although there are other types of runlevel change records, we’ll ignore them because they don’t have an effect on user logins or logouts.

If, as we’re reading records backward in the file, we come across a

record that represents either a boot, reboot, or shutdown, and if there are any remaining DEAD_PROCESS records in the saved_ut_recs list, they cannot be matching logouts for logins that we have yet to find; this is because any logins that we haven’t found yet must have occurred prior

to this boot/reboot/shutdown, which means those users would have

been logged out prior to that event, not after it. Therefore, when we

find such a record, we’ll erase all entries from the saved_ut_recs list. That’s their only effect on the behavior of our version of last, which we’ll name spl_last.

*Designing the spl_last Program*

We begin by outlining the design of our program, which will accept a

single option, -x. If this option is given on the command line, our

program’s output will include the system shutdown events and runlevel

changes. Otherwise, it will display only user logins, logouts, and reboots, just like the actual last command. Our initial version won’t attempt to be efficient; it will read only one utmpx record at a time, even though this takes more time. After we’ve written this version, we’ll consider some changes that would make it more efficient.

These are the initializations that the program will need to perform:

1\. Set up option handling by checking whether the -x option was

supplied. If so, set a flag show_sys_events to TRUE, and if not, set it to FALSE.

2\. Open the *wtmp* file. If this fails, exit with a suitable error message; otherwise, store the returned file descriptor into fd_wtmp.

3\. Set the locale by calling setlocale(LC_TIME, ""). If it fails, display an error message and exit.

4\. Read the first entry from the file and save the time in that entry’s ut_tv.tv_sec field into time_t start_time to display as the final line of output. If the read fails, display an error message and exit. The

code snippet should be: errno = 0; if ( read(fd_utmp, &utmp_entry, utsize) != utsize ) fatal_error(errno, "read"); start_time =

utmp_entry.ut_tv.tv_sec;

5\. Create an initially empty list of saved utmpx records, saved_ut_recs.

6\. Initialize a time_t variable named last_shutdown_time to 0. This

variable will be updated whenever a shutdown event is found in the

file. The value 0 indicates that no shutdown record has been found

yet.

After the initializations, the program will enter its main processing

loop in which, for every utmpx record in the file, starting with the last (most recent) record, it will process that record. Let’s assume for now that we’ve written a function with the prototype int get_prev_utrec(int fd, struct utmpx \*ut, int \*finished);

which, when called the first time, retrieves the last utmpx record in the open file with descriptor fd and stores it into \*ut, not modifying the

\*finished parameter, and when called all subsequent times, gets the

record preceding the last one read, unless it has already read the first record in the file, in which case it sets \*finished to TRUE.

The main loop is then of the form: int done = FALSE; while ( !done

) { if ( get_prev_utrec(fd_utmp, &utmp_entry, &done) ) { //

OMITTED: Process the utmp_entry. else /\* get_prev_utrec() did not

read successfully. \*/ if ( !done ) fatal_error(2, " read failed"); }

When get_prev_utrec() reads the first entry in the file, it returns TRUE, but when it tries to read again, it returns FALSE and sets done to TRUE.

Let’s outline the steps for processing each successfully read

utmp_entry. Remember that we’re travelling back in time with each

iteration of the while loop.

The first step is to determine the type of utmp_entry. For most

records, we can determine the type from the ut_type field, but as we

noted previously, shutdowns are those records for which ut_type ==

RUN_LVL, ut_user == "shutdown", and ut_line== "~". If these conditions are true, the program must set the utmp_entry.ut_type field to SHUTDOWN_TIME, the

utmp_entry.ut_line to "system down", and the utmp_entry.ut_user to "shutdown"

before continuing.

The remaining processing is contingent on the value of

utmp_entry.ut_type. The following list describes what the program should do for each of its possible values:

**DEAD_PROCESS** If utmp_entry.ut_line is not NULL, insert utmp_entry onto the front of the saved_ut_recs list; otherwise, don’t insert it, since it doesn’t correspond to any user session.

**USER_PROCESS** Search the saved_ut_recs list for a record whose ut_line is the same as that in utmp_entry. If it’s found, print a line of output for this login record in which the start time is utmp_entry.ut_tv.tv_sec and the end time is the ut_tv.tv_sec member of the record found in the list.

Also compute the total login time and print it. Finally, delete the

saved record from the saved_ut_recs list. If no matching record is

found, this user login does not have a matching logout. If

last_shutdown_time \> 0, print a line of output with the end time "gone - no logout". If last_shutdown_time == 0, the user is still logged in, so print a line of output with end time "still logged in". In either case, the printed start time is utmp_entry.ut_tv.tv_sec.

**BOOT_TIME** Store the boot time into a variable last_boot_time and erase the saved_ut_recs list. Print a line of output whose ut_line field is "system boot" and whose start time is utmp_entry.ut_tv.tv_sec. If last_shutdown \_time

== 0, the system has not been shut down since this boot entry was

recorded in the file, so the printed end time of this output line should be "still running". Otherwise, the end time should be the current value of last_shutdown_time, and the total time should be the time difference last_shutdown_time - utmp_entry.ut_tv.tv_sec.

**SHUTDOWN_TIME** Save the ut_tv.tv_sec in this record into the last_shutdown \_time variable, because for this shutdown, we don’t yet know when the

most recent preceding reboot took place, and we’ll need it when we

find that reboot entry, so that when we print the line for that reboot entry, we’ll have its end time. We also need to print the end time for this shutdown. The end time of a shutdown event is the time after

the shutdown when the system is next rebooted. In other words, the duration of a shutdown event is the time during which the machine is

not running. The start time in the output line for a shutdown is when

it was shut down, and its end time is when it was rebooted afterward.

That reboot has already been read, and its reboot time was stored

into the variable last_boot_time. Therefore, we print a line of output whose start time is utmp_entry.t_tv.tv_sec and whose end time is

last_boot_time, print the total time, and erase the saved_ut_recs list, since any saved records in that list cannot match any logins that took place earlier in time than this shutdown event.

When the main loop ends, the program has to clean up a bit and

print a final line of output. Cleanup involves freeing dynamically

allocated memory in the saved_ut_recs linked list and closing the fd_utmp file descriptor. The final output line that our program should print

should be the same as what the real last command prints, which is of the form wtmp begins Thu 01 Jan 1970 12:00:00 AM

or something similar based on the user’s locale settings. (In Chapter 3,

we learned how to do this.) The following code fragment will work:

struct tm bd_start_time; char wtmp_start_str\[128\]; start_time =

localtime(&start_time); if ( 0 == strftime(wtmp_start_str,

sizeof(wtmp_start_str), "%a %b %d %H:%M:%S %Y", bd_start_time)

) fatal_error(BAD_FORMAT_ERROR, "Conversion to a date-time

string failed or produced " " an empty string\n"); printf("\nwtmp begins %s\n", wtmp_start_str);

An extra newline character precedes the output string so that a blank

line appears before the message, just like the real last command’s

output.

Support Functions

We still have to implement a few more functions for our program. One

of these is the function that reads the file in backward order, whose

prototype we defined earlier: int get_prev_utrec(int fd, struct utmpx \*ut, int \*finished);

We also need a function that can compute the total time of a single session, whether it’s a login, reboot, or shutdown; convert that time to a number of seconds, minutes, hours, and so on; and format it as a string like the one printed by last.

Its prototype will be: void format_time_diff(time_t start_time,

time_t end_time, char \*time_diff_str);

It will compute the total number of seconds in end_time - start_time and store its formatted string representation in time_diff_str.

We need a printing function as well. When processing utmpx records,

the program needs to print a line of output for that record with a

specific start and end time. We’ll consolidate this printing into a

function with the prototype void print_one_line(struct utmpx \*ut,

time_t end_time);

which will print a line of output representing the utmpx record ut for a session that starts at time ut.ut_tv.tv_sec and ends at time end_time.

Finally, the program needs some doubly linked list processing

support. The doubly linked list definition will be: typedef struct { struct utmpx ut; struct utmplist \*next; struct utmplist \*prev; } utmplist;

utmplist \*saved_ut_recs = NULL; /\* An initially empty list \*/

We’ll use three functions for list-related actions: a function to save a utmpx record into the list, one that deletes one from the list, and one that erases the entire list. Their prototypes are: void save_ut_to_list(struct utmpx \*ut, utlist \*\*list); void delete_utnode(utlist \*utptr, utlist \*\*list); void erase_utlist(utlist \*\*list);

We’ll start with get_prev_utrec(). We can’t use the utmpx API for

reading records from the list because it retrieves them in a forward

direction, whereas our function has to get them in the opposite

direction.

The first time the function is called, it has to position the file offset at the last record in the file. For all other times, the file offset has to point to the record preceding the record it previously read. Since it

needs to do something different in the first call from what it does in subsequent calls, it needs to *remember* which call it’s in. For this purpose,

we’ll use a static local Boolean variable is_first, initially TRUE, to indicate whether it’s in the first call.

Our function also has to be aware of when it’s being called to read

the first record in the file, at offset zero, so that it doesn’t seek to a negative file offset, which causes lseek() to fail. It could do this by getting the position of the file offset before it reads, with the call: current_offset = lseek(fd,0, SEEK_CUR);

If current_offset == 0, this is the first record, so it should set finished to TRUE

to indicate that it should not be called again. The disadvantage of this solution is that it makes an extra call to lseek() every time it’s called. We can avoid this by maintaining a second static local variable, saved_offset, which would save the current value of the file offset prior to the read. It would decrease it in each call by the size of the utmpx structure.

The last problem is how to reposition the file offset to read the

previous record each time. Figure 5-7 illustrates this.

![](/tmp/audit/iter1/epubregen/system-programming-in-linux/media/index-352_1.jpg)

*Figure 5-7: Where the file offset has to be repositioned after a read when reading backward* *in the file*

After the read() system call reads the *n* th record of the file, the file offset is pointing to the first byte in the file after that record. This position is 2\*sizeof(struct utmpx) bytes past where it has to be in order to read the preceding record. If we’ve saved the file offset into saved_offset before reading, then we just have to decrease saved_offset by sizeof(struct utmpx) bytes for it to be ready for the next read. All of this logic is incorporated into the function, presented in Listing 5-9.

get_prev_utrec()

int get_prev_utrec(int fd, struct utmpx \*ut, BOOL \*finished)

{

static off_t saved_offset; /\* Where this call is about to read \*/

static BOOL is_first = TRUE; /\* Whether this is first time called \*/

size_t utsize = sizeof(struct utmpx); /\* Size of utmpx struct \*/

ssize_t nbytes_read; /\* Number of bytes read \*/

/\* Check if this is the first time it is called. If so, move the file

offset to the last record in the file and save it in saved_offset. \*/

if ( is_first ) {


/\* Move to utsize bytes before end of file. \*/

saved_offset = lseek(fd, -utsize, SEEK_END);

if ( -1 == saved_offset ) {

error_mssge(errno,

"error trying to move offset to last rec of file");

return FALSE;

}

is_first = FALSE; /\* Turn off flag. \*/

}

\*finished = FALSE; /\* Assume we're not done yet. \*/

if ( saved_offset \< 0 ) {

\*finished = TRUE;/\* saved_offset \< 0 implies we've read entire file.\*/

return FALSE; /\* Return 0 to indicate no read took place. \*/

}

/\* File offset is at the correct place to read. \*/


nbytes_read = read(fd, ut, utsize);

if ( -1 == nbytes_read ) {

/\* read() error occurred; do not exit - let main() do that. \*/

error_mssge(errno, "read");

return FALSE;

}

else if ( nbytes_read \< utsize ) {

/\* Full utmpx struct not read; do not exit - let main() do that. \*/

error_mssge(READ_ERROR, "less than full record read");

return FALSE;

}

else { /\* Successful read of utmpx record \*/

saved_offset = saved_offset - utsize; /\* Reposition saved_offset. \*/

if ( saved_offset \>= 0 ) {

/\* Seek to preceding record to set up next read. \*/


if ( -1 == lseek(fd, - (2\*utsize), SEEK_CUR) )

fatal_error(errno, "lseek()");

}

return TRUE;

}

}

*Listing 5-9: The* *get_prev_utrec()* *function, which reads through the* wtmp *file backward* The beginning of the function checks whether it’s the first time it’s called and positions the file offset to the last record in the file. After that, it checks whether the saved offset is negative and, if so, it sets finished = TRUE and returns to end processing. If it makes it past this point, it reads the record and performs error handling if need be. If all goes well, it decrements saved \_offset by the size of the record, and if not negative, it moves the file offset to the new position, setting up the next read.

Let’s turn to the next function, format_time_diff(). Given the starting and ending times in seconds, it computes their difference and creates a formatted string representing that difference. It is shown in Listing 5-

10.

format_time_diff()

void format_time_diff(time_t start_time, time_t end_time, char \*time_diff_str)

{

time_t secs = end_time - start_time;

int minutes = (secs / 60) % 60;

int hours = (secs / 3600) % 24;

int days = secs / 86400;

if ( days \> 0 )

sprintf(time_diff_str, "(%d+%02d:%02d)", days, hours, minutes); else

sprintf(time_diff_str, "(%02d:%02d)", hours, minutes);

}

*Listing 5-10: The* *format_time_diff()* *function* From the time difference, which is in seconds, it does a bit of arithmetic to calculate the equivalent time quantity in seconds, minutes, hours, and days. If the number of days is zero, it formats it one way, and if greater than zero, another, to be consistent with how the actual last command behaves.

The third support function is print_one_line(), shown in Listing 5-11.

print_one_line()

void print_one_line(struct utmpx \*ut, time_t end_time)

{

time_t utrec_time;

struct tm \*bd_end_time;

struct tm \*bd_ut_time;

char formatted_login\[MAXLEN\]; /\* Formatted login date \*/

char formatted_logout\[MAXLEN\]; /\* Formatted logout date \*/

char duration\[MAXLEN\]; /\* Session length \*/

char \*start_date_fmt = "%a %b %d %H:%M";

char \*end_date_fmt = "%H:%M";

utrec_time = (ut-\>ut_tv).tv_sec; /\* Get login time in seconds. \*/

/\* If the end time is 0 or -1, print the appropriate string

instead of a time. \*/

if ( ut-\>ut_type == BOOT_TIME && end_time == 0 )

sprintf(duration, "still running"); else if ( ut-\>ut_type == USER_PROCESS

&& end_time == 0 )

sprintf(duration, "still logged in");

else if ( ut-\>ut_type == USER_PROCESS && end_time == -1 )

sprintf(duration, "gone - no logout");

else /\* Calculate and format duration of the session. \*/

format_time_diff(utrec_time, end_time, duration);

/\* Convert login time to broken-down time. \*/

bd_ut_time = localtime(&utrec_time);

if ( bd_ut_time == NULL )

fatal_error(errno, "localtime");

if ( 0 == strftime(formatted_login, sizeof(formatted_login), start_date_fmt, bd_ut_time) )

fatal_error(BAD_FORMAT_ERROR,

"Conversion to a date-time string failed or produced "

" an empty string\n");

/\* Convert end time to broken-down time. \*/

bd_end_time = localtime(&end_time);

if ( bd_end_time == NULL )

fatal_error(errno, "localtime");

if ( 0 == strftime(formatted_logout, sizeof(formatted_logout),

end_date_fmt, bd_end_time) )

fatal_error(BAD_FORMAT_ERROR,

"Conversion to a date-time string failed or produced "

" an empty string\n");

/\* Add terminating NULL to host name, otherwise it will be too long. \*/

ut-\>ut_host\[sizeof(ut-\>ut_host)-1\] = '\0';

/\* Print the whole line. \*/

printf("%-8.8s %-12.12s %-18s %s - %s %s\n", ut-\>ut_user, ut-\>ut_line, ut-\>ut_host, formatted_login, formatted_logout, duration);

}

*Listing 5-11: The* *print_one_line()* *function* The function prints a single line to standard output in the same format as the actual last command. The inline comments explain its steps.

The next three listings contain the linked list functions. The first of these adds the given utmpx record to the given list: save_ut_to_list() void save_ut_to_list(struct utmpx \*ut, utlist \*\*list) { utlist\* utmp_node_ptr; /\*

Allocate a new list node. \*/ errno = 0; if ( NULL == (utmp_node_ptr =

(utlist\*) malloc(sizeof(utlist))) ) fatal_error(errno, "malloc"); /\* Copy the utmpx record into the new node. \*/ memcpy(&(utmp_node_ptr-\>ut), ut, sizeof(struct utmpx)); /\* Attach the node to the front of the list. \*/

utmp_node_ptr-\>next = \*list; utmp_node_ptr-\>prev = NULL; if (

NULL != \*list ) (\*list)-\>prev = utmp_node_ptr; (\*list) = utmp_node_ptr;

}

The next function removes the node pointed to by p from the given list and frees the memory allocated for that node: delete_utnode() void delete_utnode(utlist \*p, utlist \*\*list) { if ( NULL != p-\>next ) p-\>next-

\>prev = p-\>prev; if ( NULL != p-\>prev ) p-\>prev-\>next = p-\>next; else

\*list = p-\>next; free(p); }

The third function is used to delete the entire list, freeing all of the memory allocated to its nodes: erase_utlist() void erase_utlist(utlist

\*\*list) { utlist \*ptr = \*list; utlist \*next; while ( NULL != ptr ) { next = ptr-

\>next; free(ptr); ptr = next; } \*list = NULL; }

Notice that the parameter is a doubly indirect pointer. We need this

because the list head itself, saved_ut_recs, is modified by the call. If it weren’t doubly indirect, the call erase_utlist(saved_ut_list) would remove its nodes but on return, saved_ut_recs would not be NULL, and the program would then have a dangerous dangling pointer.

We’re ready to assemble the program. To save space here, since

we’ve already seen the support functions, they’re omitted from Listing

5-12. I also omit option processing and lengthy comments. The complete program is in the book’s source code distribution.

*spl_last.c*

\#define \_GNU_SOURCE

\#include "common_hdrs.h"

\#ifndef SHUTDOWN_TIME /\*If SHUTDOWN_TIME record type not defined, define it.\*/

\#define SHUTDOWN_TIME 32 /\* Give it a value larger than all other types. \*/

\#endif

typedef struct utmp_list { /\* Type of the linked list of utmpx records \*/

struct utmpx ut;

struct utmp_list \*next;

struct utmp_list \*prev;

} utlist;

int get_prev_utrec(int fd, struct utmpx \*ut, BOOL \*finished);

void format_time_diff(time_t start_time, time_t end_time, char \*time_diff_str); void print_one_line(struct utmpx \*ut, time_t end_time);

void save_ut_to_list(struct utmpx \*ut, utlist \*\*list); void delete_utnode(utlist \*p, utlist \*\*list);

void erase_utlist(utlist \*\*list);

int main(int argc, char \*argv\[\])

{

struct utmpx utmp_entry; /\* Read info into here. \*/

size_t utsize = sizeof(struct utmpx); /\* Size of utmpx record \*/

int fd_utmp; /\* Read from this descriptor. \*/

time_t last_boot_time; /\* Time of last boot or reboot \*/

time_t last_shutdown_time = 0; /\* Time of last shutdown \*/

time_t start_time; /\* When wtmp processing started \*/

struct tm \*bd_start_time; /\* Broken-down time representation\*/

char wtmp_start_str\[MAXLEN\]; /\* String to store start time \*/

utlist \*saved_ut_recs = NULL; /\* An initially empty list \*/

char options\[\] = ":x"; /\* getopt string \*/

int show_sys_events = FALSE; /\* Flag to indicate -x found \*/

char usage_msg\[MAXLEN\]; /\* For error messages \*/

BOOL done = FALSE; /\* Flag to stop utmp loop \*/

BOOL found = FALSE; /\* Flag to indicate match found \*/

char ch;

utlist \*p, \*next;

if ( (fd_utmp = open(WTMPX_FILE, O_RDONLY)) == -1 )

fatal_error(errno, "while opening " WTMPX_FILE); // OMITTED: Option parsing

if ( NULL == setlocale(LC_TIME, "") ) /\* Set the locale. \*/

fatal_error(LOCALE_ERROR, "Could not set the given locale");

/\* Read the first struct in the file to get the time of first entry. \*/


if ( read(fd_utmp, &utmp_entry, utsize) != utsize )

fatal_error(errno, "read");

start_time = utmp_entry.ut_tv.tv_sec;

while ( !done ) {


if ( get_prev_utrec(fd_utmp, &utmp_entry, &done) ) {

if ( (strncmp(utmp_entry.ut_line, "~", 1) == 0) &&

(strncmp(utmp_entry.ut_user, "shutdown", 8) == 0) ) {

utmp_entry.ut_type = SHUTDOWN_TIME;

sprintf(utmp_entry.ut_line, "system down");

}

switch ( utmp_entry.ut_type ) {

case BOOT_TIME:

strcpy(utmp_entry.ut_line, "system boot");

print_one_line(&utmp_entry, last_shutdown_time);

last_boot_time = utmp_entry.ut_tv.tv_sec;

if ( saved_ut_recs != NULL )

erase_utlist(&saved_ut_recs);

break;

case RUN_LVL: /\* Not handled \*/

break;

case SHUTDOWN_TIME:

last_shutdown_time = utmp_entry.ut_tv.tv_sec;

if ( show_sys_events )

print_one_line(&utmp_entry, last_boot_time);

if ( saved_ut_recs != NULL )

erase_utlist(&saved_ut_recs);

break;

case USER_PROCESS:

found = 0;

p = saved_ut_recs; /\* Start at beginning. \*/

while ( NULL != p ) {

next = p-\>next;

if ( 0 == (strncmp(p-\>ut.ut_line, utmp_entry.ut_line,

sizeof(utmp_entry.ut_line))) ) {

print_one_line(&utmp_entry, p-\>ut.ut_tv.tv_sec);

found = 1;

delete_utnode(p, &saved_ut_recs);

}

p = next;

} if ( !found ) {

if ( last_shutdown_time \> 0 )

print_one_line(&utmp_entry, (time_t) -1);

else

print_one_line(&utmp_entry, (time_t) 0);

}

break;

case DEAD_PROCESS:

if ( utmp_entry.ut_line\[0\] == 0 )

continue; /\* There is no line in the entry, so skip it. \*/

else

save_ut_to_list(&utmp_entry, &saved_ut_recs);

break;

case OLD_TIME: /\* Not handled \*/

case NEW_TIME: /\* Not handled \*/

case INIT_PROCESS: /\* Not handled \*/

case LOGIN_PROCESS: /\* Not handled \*/

break;

} /\* End of switch \*/

}

else /\* get_prev_utrec() did not read correctly. \*/

if ( !done )

fatal_error(2, " read failed");

}

erase_utlist(&saved_ut_recs);

close(fd_utmp);

bd_start_time = localtime(&start_time); /\* Convert to broken-down time. \*/

if ( 0 == strftime(wtmp_start_str, sizeof(wtmp_start_str),

"%a %b %d %H:%M:%S %Y", bd_start_time) )

fatal_error(BAD_FORMAT_ERROR, "Conversion to a date-time "

"string failed or produced an empty string\n");

printf("\nwtmp begins %s\n", wtmp_start_str);

return 0;

}

*Listing 5-12: An implementation of the* *last* *command, with stubs for the previously defined* *support functions* The main() function consolidates the logic we discussed previously. When it sees DEAD_PROCESS records, it inserts them into the list, provided that their ut_line field is nonempty. When it sees USER_PROCESS records, it searches the list from the beginning for a record whose ut_line matches, deletes it from the list, and prints a line on output. If it doesn’t find a matching record, either the user is still logged in or was never logged out properly. It checks which occurred (last_shutdown_time \> 0) and prints accordingly. When it sees a SHUTDOWN_TIME or a BOOT_TIME record, it erases the list of saved records after printing a line of output.

Here’s a sample of the program run without options: \$ **./spl_last** *-*

*-snip--* o.isaac pts/3 100.2.79.16 Thu Jul 03 22:35 - 22:49 (00:13) w.housto pts/0 104.162.60.115 Thu Jul 03 10:45 - 23:24 (12:38)

szhang44 pts/1 104.162.60.115 Wed Jul 02 18:47 - 15:53 (5+21:05)

d.moore pts/3 71.249.97.95 Wed Jul 02 12:15 - 12:41 (00:26) d.moore

pts/0 104.162.60.115 Wed Jul 02 11:16 - 00:38 (13:22) s.morton pts/0

49.43.217.131 Wed Jul 02 02:07 - 04:59 (02:52) s.morton pts/3

49.43.217.131 Tue Jul 01 22:44 - 00:57 (02:12) o.isaac pts/1

104.162.60.115 Tue Jul 01 17:05 - 18:47 (1+01:42) d.hopper pts/0

104.162.60.115 Tue Jul 01 10:40 - 00:14 (13:33) wtmp begins Sat Jul 01

00:27:35 2023

This machine is almost never rebooted since it serves as a gateway for an internal network, so there are no reboot entries, but once a month its *wtmp* file is cleared, which is why the file begins on the first of the month.

Here’s a run on a different host with the -x option: sweiss pts/1

146.95.214.131 Wed Jul 16 12:50 - 13:02 (00:12) sweiss pts/1

146.95.214.131 Wed Jul 16 12:44 - 12:45 (00:01) *--snip--* n.rapace pts/0 146.95.214.131 Sat Feb 01 00:47 - 00:49 (00:02) a.george pts/0

146.95.214.131 Fri Jan 31 14:46 - 17:07 (02:21) p.liant pts/0

146.95.214.131 Sat Jan 25 20:15 - 20:19 (00:04) w.beatty pts/0

146.95.214.131 Mon Jan 20 09:39 - 09:40 (00:00) root pts/0

146.95.78.229 Sun Jan 19 12:49 - 12:50 (00:00) root pts/0 146.95.78.229

Sat Jan 18 16:11 - 16:11 (00:00) csguest tty2 tty2 Fri Jan 10 13:42 -

13:42 (00:00) csguest tty2 tty2 Fri Jan 10 13:30 - 13:42 (00:11) reboot system boot 5.15.0-57-generic Fri Jan 10 13:30 - 19:00 still run. .

shutdown system down 5.15.0-57-generic Fri Jan 10 13:30 - 13:30

(00:00) reboot system boot 5.15.0-57-generic Fri Jan 10 13:27 - 13:30

(00:02) shutdown system down 5.15.0-43-generic Fri Jan 10 13:27 -

13:27 (00:00) csguest tty3 tty3 Fri Jan 10 13:22 - 13:22 (00:00) wtmp

begins Fri Jan 10 13:15:47 2023

This output shows that the host had a lot of system activity on a single day. It also shows that someone logged into it on a console as a guest on that same day, perhaps in order to reboot the machine.

*User Space Buffering of Input*

Our implementation reads one utmpx record at a time, which is not

efficient, as we explained in Chapter 4. The implementation of the actual last command reads much larger chunks of the file at a time, but as a result its logic is more complex. Because our primary objective in this chapter was to learn how to manipulate file offsets without making the problems overly complex, we didn’t attempt to add user buffering to the programs.

Before we leave this chapter though, we should explore user space

buffering of input. The kernel buffers its reads and writes, as we

discussed earlier, but our programs can also explicitly buffer input.

Suppose that, instead of reading one record at a time, our program reads many records at a time. If a record is *N* bytes and the kernel reads 4096

bytes at a time from the disk, we can reduce the number of system calls our program makes by reading the largest number of records that fit

into a 4096-byte block, or *M* = ⌊4096 / *N*⌋ records each time. The program’s performance would improve, but we’d have to solve a few

new problems.

The records would have to be stored into an array in our program’s

local memory, and we would need functions to get and remove the next

record of the array and reload the array when it was empty. Since we’re reading backward in the file, we’d have to read the records in backward order from the array. In other words, if we read *M* records at a time from the file into an array declared as struct utmpx utrecs\[M\], we’d have to retrieve them from the array in the order utrecs\[M-1\], utrecs\[M-2\], utrecs\[M-3\], . . . , utrecs\[0\]. The logic for processing records does not change, and the logic for reading backward is similar to that of the get_prev_utrec() function, except that instead of moving the file offset with lseek(), we’d use an integer variable that points to the next index in the array from which to retrieve a record. When that variable reaches 0, the program

would have to reload the array from the file.

Let’s formalize an interface that we could use for user-buffered input from the *wtmp* file. It needs just a few functions: \#define NRECS 16

\#define UTSIZE (sizeof(struct utmpx)) /\* Open the wtmp file specified

by filename, obtaining a file descriptor, and if successful, allocate storage

for a buffer \*utbuf of size NRECS\*UTSIZE (large enough to store NRECS utmpx structures). Return the file descriptor if successful, -1 on failure. \*/ int init_wtmp(char \*filename, struct utmpx \*\*utbuf); /\* Return a pointer to the next utmpx structure to process from the utbuf buffer at index next_ut, decrementing next_ut. \*/ struct utmpx

\*get_next_utrec(struct utmpx \*utbuf, int \*next_ut); /\* Try to read the next NRECS utmpx structures from fd_utmp into the buffer utbuf

starting at the beginnning of the buffer. Return the number actually

read, or -1 if reading failed. \*/ int load_buf(int fd_utmp, struct utmpx

\*utbuf); /\* Free all memory used by the buffer utbuf and close the file descriptor fd_wtmp. \*/ void wtmp_finalize(int fd_wtmp, struct utmpx

\*\*utbuf);

The program would call init_wtmp() to open the file and allocate an array that can hold NRECS utmpx structures. If this is successful, it would call load \_buf() to read up to NRECS records from the file, starting NRECS\*UTSIZE bytes before the end of the file, into the buffer. Subsequent calls to load_buf() would read that many bytes from the position NRECS\*UTSIZE bytes before the previous call.

When the program reaches the beginning of the file, reloading may

load fewer than NRECS records. It needs to check the return value of this call so that it knows where in the buffer to get the next utmpx record. Of course, if the return value is 0, it means there’s nothing left to read.

Each time the program is ready to process the next utmpx record, it

calls get_next_utrec(). It starts at the highest index in the array containing a valid record, which would be the return value of load_buf() minus one, and works downward. The function decrements this index. When it

becomes -1, the program needs to reload the buffer. When loading

returns 0, the file’s contents have been read completely and the program should call wtmp_finalize(). Implementing the complete program is left as an exercise.

Summary

Reading and updating files in Unix may sometimes require moving the

file offset around in the file. The lseek() system call allows us to

reposition this offset so that read and write operations start at specific offsets in the file. Being able to move this offset well beyond the end of a file and write data at that position gives us the ability to create *file* *holes*, gaps in the file containing no data. The possibility that files may contain file holes implies that the actual disk usage of a file may be different from the size reported by commands such as ls.

Unix systems maintain records of user logins and logouts, as well as

various system events such as boots, reboots, changes in runlevel, and shutdowns. The standard set of utilities in Unix typically contains

commands that allow us to query these types of records. These include

who, lastlog, last, and others. The files that store these records are generally world readable, so that any user can look up who’s logged in currently, the last time that a particular user logged in, and so on. Most of these records are in binary format and must be read using system

calls such as read() or library functions that can read binary data. They reside in files such as *lastlog*, *utmp*, and *wtmp*. We can access data from the *utmp* and *wtmp* files by using a POSIX API that does not require making system calls to read directly.

Most data associated with users contains the user ID of the user, not

the username. The *passwd* file contains an entry for every user that associates the username to a user ID, and Unix provides functions for

retrieving entries from this file either by supplying a user ID, getpwuid(), or by supplying a username, getpwnam().

In the chapter, we developed a few programs to learn how to work

with system files and move the file offsets around. In particular, we

implemented simple versions of the lastlog and last commands, as well

as a command that dumps the contents of any file based on utmp records, which we named showutmp.

Exercises

1\. Rewrite the *spl_lastlog.c* program so that it accepts a -u *user1 user2*

*...* option such that, instead of printing the last login information for all users, it prints the information for the listed users. You can limit the number of arguments to 16 for simplicity.

2. Rewrite the *spl_lastlog.c* program so that it accepts a -t option (t for

“terse”) that suppresses output for users who never logged in and

just displays actual logins.

3\. Rewrite the *spl_utmpdump.c* program to use the kernel’s read() system call for reading the utmp records.

4\. Write an implementation of the spl_last program with options that

limit the range of dates for which it will output data. Specifically,

give it two options, -s *start_time* and -e *end_time*, so that it only shows events that take place *after* start time and *before* end time.

5\. Write an implementation of the last program that uses user-

buffering of input, as described in “User Space Buffering of Input”

on page 242. Experiment with different sizes of buffers. To do this, make the buffer size a command option -b *nrecs*, where *nrecs* is the number of records to read each time.

6\. The implementation of spl_lastlog might be improved by storing

all user IDs returned by getpwent(), sorting them, and then accessing

the *lastlog* file. Write a version of this program based on this strategy. Then, time both versions on the same input files multiple

times to compare their running times. If you have access to some

Linux systems with many users, run the two versions on them to

see which is faster.