/\*NOTREACHED\*/

}

main () {

signal(SIGINT, handler);

if (setjmp(buf)) {

printf("back in main\n");

return 0;

}else

printf("first time through\n");

loop:

/\* spin here, waiting for ctrl-c \*/

goto loop;

}

Note: signal handlers are not supposed to call library functions (except under restricted circumstances stated in the standard). If the signal is raised during the

"first time" printf, then the printf in the signal handler, coming in the middle of all this, may get confused. We cheat here, because interactive I/O is the best way to see what's going on. Don't cheat in real world code, OK?

Running this program results in this output:

% a.out

first time through

^C now got a SIGINT signal

back in main

This program uses setjmp/longjmp and signal handling, so that on receiving a control-C

(passed to a UNIX process as a SIGINT signal) the program restarts, rather than quits.

**Chapter 8. Why Programmers Can't Tell Halloween from Christmas Day** *Are you fed up with the slow speed of your workstation? Would you like to run your programs twice as* *fast?*

*Here's how to do it in UNIX. Just follow these three easy steps:* 1. *Design and code a high-performance UNIX vm kernel. Be careful! Your* *algorithm needs to run twice as fast as the present one to see the full 100%*

*speed-up.*

2\. *Put your code in a file called* /kernel/unix.c

3\. *Issue the command*

4\.

cc -O4 -o /kernel/unix /kernel/unix.c

*and reboot your machine.*

*It's as simple as that. And remember, Beethoven wrote his first symphony in C.*

—A.P.L. Byteswap's *Big Book of Tuning Tips and Rugby Songs* the Potrzebie system of weights and measures…making a glyph from bit patter ns…types changed while you wait…prototype painfulness…read a character without newline…implementing a finite state machine in C…program the simple cases first…how and why to cast…some light relief—the inter national obfuscated C competition

**The Potrzebie System of Weights and Measures**

Of course, when Picasso made the comment about computers being uninteresting, we know that he was really seeking to advance a discourse in which it was the rôle of artists to challenge the establishment, ask questions, or at least see that the correct serving of fries accompanied each order.

How appropriate, therefore, that this chapter opens with the old question among computer folk that asks why programmers can't tell Halloween from Christmas Day. Before we provide the punchline, we should say a few words about the work of world-class computer scientist Donald Knuth. Professor Knuth, who has taught at Stanford University for many years, wrote the massive and definitive reference work, *The Art of Computer Programming*, \[1\] and designed the TeX typesetting system.

\[1\] Professor Knuth later identified his long-standing colleague Art Evans as the *Art* in *The Art* *of Computer Programming* book title. Back in 1967, when the series of volumes started to appear, Knuth gave a semi-nar at Carnegie Tech. Knuth remarked that he was glad to see his old friend Art Evans in the audience since he had named his series of books after him.

Everyone groaned in appreciation once they grasped the awful pun, and Art was more amazed than anyone.

Later, when Knuth won the ACM's Turing Award, he ensured that the pun entered the official record by mentioning Art again in his Turing Award Lecture. You can read it in *Communications of the ACM*, vol. 17, no. 12, p. 668. Art claims that "it hasn't affected my life much at all."

A little-known fact is that Professor Knuth's first publication was not in a prestigious peer-reviewed scientific journal, but in a much more popular gazette. "The Potrzebie System of Weights and Measures" by Donald Knuth appeared in *MAD Magazine*, issue number 33, in June 1957. The article, by the very same Donald Knuth who later became known as an eminent computer scientist, parodied the then-novel metric system of weights and measures. Most of Knuth's subsequent papers have tended to be more conventional. We think that's a shame, and look for a return to roots. The basis of all measurements in the Potrzebie system is the thickness of *MAD Magazine*'s issue number 26.

Knuth's article was a consistent application of metric-decaded prefixes using units that were more familiar to *MAD* readers, such as *potrzebies, whatmeworrys*, and *axolotls*. For many of *MAD*'s readers it was a gentle introduction to the concepts of the metric system. People in the U.S. just weren't familiar with *kilo*, *centi*, and other prefixes, so Knuth's Potrzebie paved the way for a greater understanding. Had the Potrzebie system actually been adopted, perhaps the later American experiment with the metric system would have been more successful.

Like the Potrzebie system, the joke about programmers' confusion over Halloween and Christmas Day depends on inside knowledge of numbering systems. The reason that programmers can't tell Halloween from Christmas Day is because 31 in octal (base eight) equals 25 in decimal (base ten).

More succinctly, OCT 31 equals DEC 25!

When I wrote to Professor Knuth asking his permission to tell the story, and including a draft copy of the chapter, he not only agreed, he marked numerous proofreading improvements on the text, and pointed out that programmers can't distinguish NOV 27 from the other two dates, either.

This chapter presents a selection of C idioms that similarly depend on inside knowledge of programming. Some of the examples here are useful tips to try, while others are cau-tionary tales of trouble spots to avoid. We start off with a delightful way to make icons self-documenting.

**Making a Glyph from Bit Patterns**

An icon, or a glyph, is a small graphic for a bit-mapped screen. A single bit represents each pixel in the image. If the bit is set, then the pixel is "on"; if the bit is clear, then the pixel is "off". So a series of integer values encodes the image. Tools like Iconedit are used to draw the picture, and they output an ASCII file of integers that can be included in a windowing program. One problem has been that the icon appears in a program as just a bunch of hex numbers. A typical 16-by-16 black and white glyph might look like this in C:

static unsigned short stopwatch\[\] = {

0x07C6,

0x1FF7,

0x383B,

0x600C,

0x600C,

0xC006,

0xC006,

0xDF06,

0xC106,

0xC106,

0x610C,

0x610C,

0x3838,

0x1FF0,

0x07C0,

0x0000

};

As you can see, the C literals don't provide any clue about how the image actually looks. Here is a breathtakingly elegant set of \#defines that allow the programmer to build the literals so that they look like the glyph on the screen.

\#define X )\*2+1

\#define \_ )\*2

\#define s ((((((((((((((((0 /\* For building glyphs 16 bits

wide \*/

They enable you to create the hex patterns for icons, glyphs, etc., by drawing a picture of the image you want! What could be better for making a program self-documenting? Using these defines, the example is transformed into:

static unsigned short stopwatch\[\] =

{

s \_ \_ \_ \_ \_ X X X X X \_ \_ \_ X X \_ ,

s \_ \_ \_ X X X X X X X X X \_ X X X ,

s \_ \_ X X X \_ \_ \_ \_ \_ X X X \_ X X ,

s \_ X X \_ \_ \_ \_ \_ \_ \_ \_ \_ X X \_ \_ ,

s \_ X X \_ \_ \_ \_ \_ \_ \_ \_ \_ X X \_ \_ ,

s X X \_ \_ \_ \_ \_ \_ \_ \_ \_ \_ \_ X X \_ ,

s X X \_ \_ \_ \_ \_ \_ \_ \_ \_ \_ \_ X X \_ ,

s X X \_ X X X X X \_ \_ \_ \_ \_ X X \_ ,

s X X \_ \_ \_ \_ \_ X \_ \_ \_ \_ \_ X X \_ ,

s X X \_ \_ \_ \_ \_ X \_ \_ \_ \_ \_ X X \_ ,

s \_ X X \_ \_ \_ \_ X \_ \_ \_ \_ X X \_ \_ ,

s \_ X X \_ \_ \_ \_ X \_ \_ \_ \_ X X \_ \_ ,

s \_ \_ X X X \_ \_ \_ \_ \_ X X X \_ \_ \_ ,

s \_ \_ \_ X X X X X X X X X \_ \_ \_ \_ ,

s \_ \_ \_ \_ \_ X X X X X \_ \_ \_ \_ \_ \_ ,

s \_ \_ \_ \_ \_ \_ \_ \_ \_ \_ \_ \_ \_ \_ \_ \_

};

certainly quite a bit more meaningful than the equivalent literal values. Standard C has octal, decimal, and hexadecimal constants, but not binary constants, which would otherwise be a simpler way of picturing the pattern.

If you hold the book at the right angle and squint at the page, you might even have a chance of guessing that this is the little stopwatch "cursor busy" glyph used on popular window systems. We got this tip from the Usenet comp.lang.c newsgroup some years ago.

Don't forget to undefine the macros after your pictures; you don't want them mysteriously interfering with later code.

**Types Changed While You Wait**

We saw in Chapter 1 the type conversions that occur when operators are supplied operands of different types. These are known as the "usual arithmetic conversions", and they govern conversions between two different types to a common type, which is usually also the result type.

Type conversions in C are much more widespread than is generally realized. They can also occur in any expression that involves a type smaller than int or double. Take the following code, for example:

printf(" %d ", sizeof 'A' );

The code prints out the size of the type that holds a character literal. Surely this will be the size of a character, and hence "1"? Try running the code. You will see you actually get "4" (or whatever size int is on your system). Character literals have type int and they get there by following the rules for promotion from type char. This is too briefly covered in K&R 1, on page 39 where it says:

Every char in an expression is converted into an int.…Notice that all float's in an expression are converted to double.…Since a function argument is an expression, type conversions also take place when arguments are passed to functions: in particular, char and short become int, float becomes double.

— *The C Programming Language,* first edition

The feature is known as *type promotion*. When it happens to integer types it's called "integral promotion". The concept of automatic type promotion carried over to ANSI C, although it was watered down in places. The ANSI C standard has this to say about it: In executing the fragment

char c1, c2;

/\* ... \*/

c1 = c1 + c2;

the "integral promotions" require that the abstract machine promote the value of each variable to int size and then add the two ints and truncate the sum. Provided the addition of two chars can be done without creating an overflow exception, the actual execution need only produce the same result, possibly omitting the promotions.

Similarly, in the fragment

float f1, f2;

double d;

/\* ... \*/

f1=f2\*d;

the multiplication may be executed using single-precision arithmetic if the implementation can ascertain that the result would be the same as if it were executed using double-precision arithmetic (for example, if d were replaced by the constant 2.0, which has type double).

— *ANSI C Standard*, Section 5.1.2.3

Table 8-1 provides a list of all the usual type promotions. These occur in every expression, not just in expressions involving operators and mixed-type operands.

***Table 8-1. Type Promotions in C***

**Original Type**

**Usually Promoted To**

char

int

bit-field

int

enum

int

unsigned char

int

short

int

unsigned short

int

![Image 98](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-178_1.png)

float

double

array *of anything*

pointer *to anything*

The integral promotions are: char, short int and bit-field types (and signed or unsigned versions of these), and enumeration types, will be promoted to int if they can be represented as such.

Otherwise they are promoted to unsigned int. ANSI C says that the promotion doesn't have to be done if the compiler can guarantee that the same result occurs without it—this usually means a literal operand.

**Software Dogma**

**Alert! Really Important Point—Arguments Are Promoted Too!**

An additional place where implicit type conversion occurs is in argument passing. Under K&R C, since a function argument is an expression, type promotion takes place there, too.

In ANSI C, arguments are not promoted if a prototype is used; otherwise, they are. Widened arguments are trimmed down to their declared size in the called function.

This is why the single printf() format string "%d" works for all the different types, short, char, or int. Whichever of these you passed, an int was actually put on the stack (or in a register, or whatever) and can be dealt with uniformly in printf \[1\], or any callee at the other end. You can see this in effect if you use printf to output a type longer than int such as long long on Sun's. Unless you use the long long format specifier

%lld, you will not get the correct value. This is because in the absence of further information, printf assumes it is dealing with an int.

\[1\] Even if a prototype is in scope for printf(), note that its prototype ends with an ellipsis: int printf(const char \*format, ...);

This means it is a function that takes variable arguments. No information about the parameters (other than the first one) is given, and the usual argument promotions always take place.

Type conversion in C is far more widespread than in other languages, which usually restrict themselves to making operands of different types match. C does this too, but also boosts matching types that are smaller than the canonical forms of int or double. There are three important points to note about implicit type conversions:

• It's a kludge in the language, dating from a desire to simplify the earliest compilers.

Converting all operands to a uniform size greatly simplified code generation. Parameters pushed on the stack were all the same length, so the runtime system only needed to know the number of parameters, and not their sizes. Doing all floating-point calculations at double

precision meant that the PDP-11 could just be set in "double" mode and left to crank away, without keeping track of the precision.

• You can do a lot of C programming without ever becoming aware of the default type promotions. And many C programmers do.

• You can't call yourself an expert C programmer unless you know this stuff. It gains particular importance in the context of prototypes, described in the next section.

**Prototype Painfulness**

The purpose of ANSI C function prototypes is to make C a more reliable language. Prototypes are intended to reduce a common (and hard-to-find) class of errors, namely a mismatch between formal and actual parameter types.

This is accomplished by a new form of function declaration that includes the parameter declarations.

The function definition is also changed in a similar way, to match the declaration. The compiler can thus check use against declaration. As a reminder, the old and new forms of declaration and definition are shown in Table 8-2.

***Table 8-2. K&R C Function Declarations Compared with ANSI C Prototypes***

**K&R C**

**ANSI C**

Declaration:

Prototype:

int foo();

int foo(int a, int b);

or

int foo(int, int );

Definition:

Definition:

int foo(a,b)

int foo(int a, int b)

int a;

{

int b;

...

{

}

...

}

Notice that a K&R function declaration differs from an ANSI C function declaration (prototype), and a K&R function definition differs from an ANSI C function definition. You express "no parameters"

in ANSI C as int foo(void); so even this case looks different from classic C.

However, ANSI C didn't and couldn't insist on the use of prototypes exclusively, because that would have destroyed upward compatibility for billions of lines of existing pre-ANSI code. The standard does stipulate that the use of function declarators with empty parentheses (i.e., without specifying argument types) is officially declared obsolescent, and support for it may be withdrawn from future

![Image 99](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-180_1.png)

![Image 100](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-180_2.png)

![Image 101](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-180_3.png)

![Image 102](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-180_4.png)

versions of the standard. For the foreseeable future both styles will coexist, because of the volume of pre-ANSI code. So, if prototypes are "a good thing," should we use them everywhere, and go back and add prototypes to existing code when we conduct maintenance on it? Emphatically not!

Function prototypes not only change the syntax of the language; they also introduce a subtle (and arguably undesirable) difference into the semantics. As we know from the previous section, under K&R, if you passed anything shorter than an int to a function it actually got an int, and floats were expanded to doubles. The values are automatically trimmed back to the corresponding narrower types in the body of the called function, if they are declared that way there.

At this point, you might be wondering, why bother expanding them at all, only to shrink them back? It was originally done to simplify the compiler—everything became a standard size. With just a few types it especially simplified argument passing, especially in very old K&R C where you couldn't pass structs as arguments. There were exactly three types: int, double, and pointer. All arguments became a standard size, and the callee would narrow them if necessary.

In contrast, if you use a function prototype, the default argument promotions do not occur. If you prototype something as a char, a char actually gets passed. If you use the new-style function definition (where argument types are given in the parentheses following the function name), then the compiler generates code on the assumption that the parameters are exactly as declared, without the default type widening.

**Where Prototypes Break Down**

There are four cases to consider here:

1\. **K&R function declaration, and K&R function definition** call works ok, promoted types are passed

2\. **ANSI C declaration (prototype), and ANSI C definition**

call works ok, actual types are passed

3\. **ANSI C declaration (prototype), and K&R function definition** Failure if you use a narrow type! Call passes actual

types, function expects promoted types.

4\. **4. K&R function declaration, and ANSI C definition**

Failure if you use a narrow type! Call passes promoted

types, function expects actual types.

So if you add a prototype for a K&R C definition including a short, the prototype will cause a short to be passed, but the definition will expect an int, so it will retrieve junk from whatever happens to be adjacent to the parameter. You can force cases 3 and 4 to work by writing the prototype to use the widened type. This will detract from portability and confuse maintenance programmers. The examples below show the two cases that fail.

file 1

/\* old style definition, but has prototype \*/

olddef (d,i)

float d;

char i;

{

printf("olddef: float= %f, char =%x \n", d, i);

}

/\* new style definition, but no prototype \*/

newdef (float d, char i)

{

printf("newdef: float= %f, char =%x \n", d, i);

}

file 2:

/\* old style definition, but has prototype \*/

int olddef (float d, char i);

main() {

float d=10.0;

char j=3;

olddef(d, j);

/\* new style definition, but no prototype \*/

newdef (d, j);

}

Expected output:

olddef: float= 10.0, char =3

newdef: float= 10.0, char =3

Actual output:

olddef: float= 524288.000000, char =4

newdef: float= 2.562500, char =0

![Image 103](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-182_1.png)

Note that if you put the functions in the same file where they are called (file 2, here), the behavior changes. The compiler will detect the mismatch of olddef() because it now sees the prototype and K&R definition together. If you place the definition of newdef() before it is called, the compiler will silently do the right thing because the definition acts as a prototype, providing consistency. If you place the definition after the call, the compiler should complain about the mismatch. Since C++

requires prototypes, you may be tempted to add them willy-nilly if using a C++ compiler to brute-force some antique K&R C code.

**Programming Challenge**

**How to Fake Out Prototypes**

Try a few examples to clarify the issues here. Create the following function in a file of its own:

void banana_peel(char a, short b, float c) {

printf("char = %c, short =%d, float = %f \n",

a,b,c);

}

In a separate file, create a main program that calls banana_peel().

1\. Try calling it with and without a prototype, and with a prototype that doesn't match the definition.

2\. In each case, predict what will happen before trying it. Check your prediction by writing a union that allows you to store a value of one type, and retrieve another of a different size.

3\. Does changing the order of the parameters (in the declaration and the definition) affect how the values are perceived in the called function? Account for this. How many of the error cases does your compiler catch?

Earlier we mentioned that prototypes allow the compiler to check use against declaration. Even if you don't mix'n'match old style with new style, the convention is not foolproof, as there is no guarantee that a prototype actually matches the corresponding definition. In practice we guard against this by putting the prototype into a header file and including the header in the function declaration file. The compiler sees them both at once and will detect a mismatch. Woe betide the programmer who doesn't do this!

**Handy Heuristic**

![Image 104](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-183_1.png)

**Don't Mix Old and New Styles in Function Declaration and Definition** Never mix the old and new styles of function declaration and definition. If the function has a K&R-style declaration in the header file, then use K&R syntax in the definition.

int foo(); int foo(a,b) int a; int b; { /\* ... \*/ }

If the function has an ANSI C prototype, use ANSI C-style syntax in the definition.

int foo(int a, int b); int foo(int a, int b) { /\* ...

\*/ }

It would have been possible to create a foolproof mechanism for checking function calls across multiple files. Special magic would be used (as it currently is) on functions like printf that take a variable number of arguments. This could even have been applied to the existing syntax. All that would be needed is a constraint in the standard specifying that each call to a function must be consistent with name, number, and type of parameters and return type in the function definition. The

"prior art" was there, as this is done for the Ada language. It could be done in C too, with an additional pre-linker pass. Big hint: use lint.

In practice, the ANSI C committee members were quite cautious about extending C—arguably too cautious. The Rationale shows how they agonized over whether or not they could remove the existing six-character case-insensitive limitation on the significance of external names. In the end, they decided they couldn't remove this restriction, somewhat feebly in the view of some language experts. Maybe the ANSI C committee should have bitten the bullet on this as well, and stipulated a complete solution even if it needs a pre-linker pass, instead of adopting a cockamamie partial solution from C++ with its own conventions, syntax, semantics, and limitations.

**Getting a Char Without a Carriage Return**

One of the first questions that MS-DOS programmers ask on encountering a UNIX system is, "How do I read characters from the terminal without requiring the user to hit RETURN?" Terminal input in UNIX is "cooked" by default, meaning that the raw input is first processed so that line-editing characters (backspace, delete, and so on) can be used, and these keys take effect without being passed through to the running program. Usually this is a desirable convenience, but it does mean that a read won't get the data until the user presses RETURN to signify that the line is finished. Input is effectively line-by-line, whereas some applications need to see each character as each individual key is pressed.

This feature is essential for many kinds of software and is trivial on a PC. The C libraries there support this, often with a function called kbhit(), which indicates if a character is waiting to be read.

![Image 105](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-184_1.png)

The C compilers from Microsoft and Borland provide getch() (or getche() to echo the character) to get input character-by-character without waiting for the whole line.

People often wonder why ANSI C didn't define a standard function to get a character if a key has been pressed. Without a standard function every system has a different method, and program portability is lost. The argument against providing kbhit() as part of the standard is that it is mostly useful for games software, and there are many other terminal I/O features that are not standardized. In addition, you don't want to promise a standard library function that some OS's will find difficult to provide. The argument for providing it is that it is mostly useful for games software, and that games writers don't need the myriad of other terminal I/O features that could be standardized. Whichever view you hold, it's true that X3J11 missed an opportunity to reinforce C as the language of choice for a generation of student programmers writing games on UNIX.

**Handy Heuristic**

**The Boss Key**

Games software is more important than generally thought. Microsoft realizes this, and thoughtfully provides all their new games software with a "boss key". You hit the boss key when you notice in the corner of your eye that your manager is sneaking up on you. It causes the game to instantly disappear, so when the boss strides over to your terminal, it looks like you were working. We're still looking for the boss key that will collapse MS-Windows to reveal a proper window system underneath…

On UNIX, there's a hard way and an easy way to get character-by-character input. The easy way is to let the stty program do the work. Although it is an indirect means of getting what you want, it's trivial to program.

\#include \<stdio.h\>

main()

{

int c;

/\* The terminal driver is in its ordinary line-at-a-time mode

\*/

system("stty raw");

/\* Now the terminal driver is in character-at-a-time mode \*/

c = getchar();

system("stty cooked");

/\* The terminal driver is back in line-at-a-time mode \*/

![Image 106](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-185_1.png)

}

That last line—system("stty cooked");—is necessary because the terminal characteristics persist after the program finishes. If a program sets the terminal into a funny mode, it will stay in a funny mode. This is quite unlike, say, setting an environment variable, which disappears when the process does.

Raw I/O achieves a blocking read—if no character is available, the process waits there until one comes in. If you need a nonblocking read, you can use the ioctl() (I/O control) system call. It provides a fine level of control over terminal characteristics, and can tell you if a key has been pressed under SVr4. This code uses an ioctl to only do a read if there is a character waiting to be read. This type of I/O is known as *polling*, as you continually ask the device for its opinion on whether it has a character to give you yet.

\#include \<sys/filio.h\>

int kbhit()

{

int i;

ioctl(0, FIONREAD, &i);

return i; /\* return a count of chars available to read \*/

}

main()

{

int i = 0;

intc='';

system("stty raw -echo");

printf("enter 'q' to quit \n");

for (;c!='q';i++) {

if (kbhit()) {

c=getchar();

printf("\n got %c, on iteration %d",c, i);

}

}

system("stty cooked echo");

}

**Handy Heuristic**

**Check errno After Library Calls**

Whenever you're using system calls (like ioctl()), it's a good idea to check the global

variable errno that is part of ANSI standard C.

If a library or system call encounters problems, it will set errno to indicate the cause of the problem. However, the value of errno is only valid if there was a problem—the call will have some way of indicating this (usually by its return code).

A typical use might be:

errno=0;

if (ioctl(0, FIONREAD, &i)\<0) {

if (errno==EBADF) printf("errno: bad file number");

if (errno==EINVAL) printf("errno: invalid

argument");}

You can get as fancy as you like, and encapsulate the checking in a single function that is called after each system call while you are debugging your program. This really helps a lot in isolating the errors. The library call perror() will print out an error message when you know you have one.

If you're interested in single-character I/O like this, you're often also interested in doing other display control, and the curses library provides various portable routines for both. Curses (think "cursor") is a library of screen management calls, with implementations on all popular platforms. Rewriting the main function above to use curses instead of stty gives:

\#include \<curses.h\>

/\* uses curses library, and the kbhit() function defined above

\*/

main()

{

int c=' ', i=0;

initscr(); /\* initialize curses functions \*/

cbreak();

noecho(); /\* do not echo pressed character \*/

mvprintw(0, 0, "Press 'q' to quit\n");

refresh();

while (c!='q')

if (kbhit()) {

c = getch(); /\* won't block, as we know a character is

waiting \*/

mvprintw(1, 0, "got char '%c' on iteration %d \n",c, ++i); refresh();

}

nocbreak();

![Image 107](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-187_1.png)

echo();

endwin(); /\* finish curses \*/

}

Compile this with cc foo.c -lcurses. Notice how much neater the output is when run under curses. There's a Nutshell book titled *UNIX Curses Explained* (which is not at all the book of programmer swear words most people think it is when they pick it up) that describes curses well. The curses library only offers character-based screen control func-tions. It's a lower common denominator than software written using specific bit-mapped graphics windowing libraries, but the curses software is far more portable.

Finally, there is a non-polling read in which the operating system will send your process a signal each time it has some input ready.

If a program uses interrupt-driven I/O, when it is not handling input it can be doing other processing in the main function. This is a very efficient use of resources if input is sporadic and there is much processing to be done. Interrupt-driven programs are much more complex and difficult to get working, but the paradigm enables a process to make productive use of time otherwise spent waiting for input.

The use of threads diminishes the need to use interrupt-driven I/O techniques.

**Programming Challenge**

**Write an Interrupt-Driven Input Routine on Your System**

Interrupt-driven input is a breeze on MS-DOS. The system provides such spartan services that it is easy to brush them aside and pluck characters direct from the I/O port. Under SVr4, you will need to do the following:

1\. Create a signal handler routine that will be invoked to read a character when the OS sends a signal that one is ready. The signal to catch is SIGPOLL.

2\. The signal handler should read a character, and also reset itself as the handler for this signal each time it is invoked. Have it echo the character it just read, and quit if it was a 'q'. Note: this is just for teaching purposes. In practice the results are usually undefined if you call any standard library function from within a signal handler.

3\. Make an ioctl() call to inform the OS that you require a signal to be sent every time input comes in on the standard input. Look at the manpages for streamio. You will need a command of I_SETSIG and an argument of S_RDNORM.

4\. Once the signal handler has been set up, the program can do something else until input comes in. Have it increment a counter. Print the value of the

counter in the handler routine.

Every time a character is sent from the keyboard, the SIGPOLL signal will be sent to the process. The signal handler will read the character, and reset itself to be the handler.

**Implementing a Finite State Machine in C**

A finite state machine is a mathematical concept that can be very useful when embodied in a program.

It's a protocol for progressing through a limited ("finite") number of subroutines ("states"), each of which does some processing and then chooses the next state, usually based on the next piece of input.

A finite state machine (FSM) can be used as the control structure of a program. FSMs are well-suited to programs that loop over several different alternative actions based on input. A coin-operated vending machine is a good candidate for an FSM. It will have states like "accept coin", "select item",

"deliver item", and "make change". The inputs will be coins, and the outputs will be the items for sale.

The basic idea is to have a table that holds all the possible states, and lists the actions to do when you enter each state. The last action is to calculate (often by a further table lookup based on the state you are in and the next input token) what state to enter next. You start in a state known as the "initial state." Along the way, your transition table might tell you to enter an error state, signifying an unexpected or erroneous input. You continue to make state transitions until you arrive at the end state.

There are several ways to express an FSM in C, but most of them are based on an array of pointers to functions. An array of pointers to functions can be declared like this: void ( \*state\[MAX_STATES\] )();

If you know the function names, you can initialize the array like so: extern int a(), b(), c(), d();

int (\*state\[\])() = { a, b, c, d };

A function can be called through a pointer in the array like this: (\*state\[i\])();

The functions must all take the same arguments and have the same return value (unless you make the array element a union…). Pointers to functions are funny. Notice, too, how the pointer can be dropped, so our call can equally be made as

state\[i\]();

or even

(\*\*\*\*\*\*state\[i\])();

![Image 108](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-189_1.png)

This is an unfortunate quirk popularized with ANSI C: calls to a function and calls to a function through a pointer (or any level of pointer indirection) can use the same syntax. There's a corresponding quirk applying to arrays. It further undermines the flawed "declaration looks like use"

philosophy.

**Programming Challenge**

**Write an FSM Program**

Implement the C declaration analyzer from Chapter 3 as a finite state machine.

1\. Review the "decoder ring" diagram, Figure 3-3 on page 76. This is a simple state machine diagram! Program it this way, perhaps by modifying the cdecl program you wrote back in Chapter 3. (You *did* write it, didn't you?) 2. First, write the code to control progress from state to state. Make each action routine simply print out the fact that it has been invoked. Debug this fully.

3\. Add the code to process and decode the input declaration.

The decoder ring is a simple state machine; most of the state transitions are in serial order regardless of the input. This means that you don't have to create a *table* of transitions matching state/input to get the next state. You can have a simple variable (of type pointer-to-function). In each state, one of the things you will do is assign the next state. In the main loop, the program will call the function pointed at, and so on until the end function or an error state is reached.

How does the FSM-based program compare with the non-FSM version in terms of ease of coding and debugging? In terms of ease of adding a different action, or modifying the order in which actions occur?

If you want to get fancier, you can have the state function return a pointer to a generic successor function, which you cast to the appropriate type. Then you don't need a global variable. If you want to get less fancy, you can use a switch statement as a poor man's state machine, by assigning to the control variable and putting the switch inside a loop. One final point on FSMs. If your state functions seem to need a variety of arguments, consider using an argument count and an array of pointers to strings, just as the main routine does. The familiar int argc, char \*argv\[\] mechanism is very general and can be borrowed with equal success for functions that you define.

**Software Is Harder than Hardware!**

Did you ever notice that software and hardware are named the wrong way round—software is easier to change, but harder in all other respects? Because software is so difficult to develop and get right, as programmers we need to find ways to make it as easy as possible. One way to do that (and it applies to

![Image 109](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-190_1.png)

![Image 110](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-190_2.png)

all languages, not just C) is to code for debuggability. When you write the program, provide the debugging hooks.

**Handy Heuristic**

**Debugging Hooks**

Did you know that most debuggers allow you to make function calls from the debugger command line? This can be very useful if you have complicated data structures. Write and compile a function to traverse the data structure and print it out. The function won't be called anywhere in the code, but it will be part of the executable. It is a "debugger hook."

When you debug the code and you're stopped at a breakpoint you can easily check the integrity of your data structures by manually issuing a call to your print routine. Obvious once it's pointed out to you; not obvious if you've never seen it before.

We already hinted at coding for debuggability in the previous section, where we suggested coding an FSM in two distinct phases: first do the state transitions, and only when they are working provide the actions. Don't confuse incremental development with "debugging code into existence"—a technique common among junior programmers, and those writing under too-strict time deadlines. Debugging code into existence means writing a fast slapdash first attempt, and then getting it working by successive refinements over a period of weeks by changing parts that don't work. Meanwhile, anyone who relies on that system component can pull their hair out. "Sendmail" and "make" are two well known programs that are pretty widely regarded as originally being debugged into existence. That's why their command languages are so poorly thought out and difficult to learn. It's not just you—

everyone finds them troublesome.

Coding for debuggability means breaking the system down into parts, and getting the program structure working first. Only when you have got the basic program working should you code the complicated refinements, the performance tweaks, and the algorithm optimizations.

**Handy Heuristic**

**Hash with Panache**

Hashing is a way to speed up access to an element in a table of data. Instead of searching

the table serially, you get a jumpstart to the likeliest element to contain your value.

This is achieved by loading the table carefully, and not in serial order. What you do instead is apply some kind of transformation (known as a hashing function) on a data value from an element to be stored. The hashing function will yield a value in the range 0…tablesize-1, and that becomes the index where you try to store that record.

If the slot is already taken, search forward from that point in the table for the next empty slot.

Alternatively, you can set up a linked list hanging off that element, and simply add it to the end (either end, by the way). Or you can even hang a second hash table off the element.

When you look up a data item, you don't need to start searching entries from element zero.

Instead, again hash the value you want to locate, and start looking from that point in the table.

Hashing is a tried and tested table lookup optimization, and it's used everywhere in systems software: in databases, operating systems, and compilers.

If I were stranded on a desert island and could only take one data structure with me, it would be the hash table.

A colleague had to write a program that at one point stored filenames and information about each file.

The data was stored in a table of structs, and he decided to use hash lookup. Here's where the coding for debuggability came in. He didn't try to get every part of the program working in one swell foop.

He got it working for the simplest case first, by making the hash function always return the constant zero. The function looked like this:

/\* hash_file: Placeholder for more sophisticated future

routine \*/

int hash_filename (char \*s)

{

return 0;

}

The code that called it looked like this:

/\*

\* find_file: Locate a previously created file descriptor or

\* make a new one if necessary.

\*/

file find_filename (char \*s)

{

int hash_value = hash_filename(s);

file f;

for (f = file_hash_table\[hash_value\]; f != NIL;f=f-\>flink) {

![Image 111](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-192_1.png)

if (strcmp(f-\>fname, s) == SAME) {

return f;

}

}

/\* file not found, so make a new one: \*/

f = allocate_file(s);

f-\>flink = file_hash_table\[hash_value\];

file_hash_table\[hash_value\] = f;

return f;

}

The effect was as though a hash table was not used; all the elements would be stored in a linked list off element zero. This made it simple to debug, because you didn't have to calculate where anything really should be. The ace programmer was able to quickly get the rest of the code working because he did not have to worry about the interaction with hashing. When he was satisfied that the main routines worked perfectly, he took some performance measurements, and decided to activate the hash function.

This was a two-line change in a single function. Here's the current version involving, as he put it,

"brain, pain, and gain".

int hash_filename (char \*s)

{

int length = strlen(s);

return (length+4\*(s\[0\]+4\*s\[length/2\])) % FILE_HASH;

}

Sometimes taking the time to break a programming problem into smaller parts is the fastest way of solving it.

**Programming Challenge**

**Write a Hash Program**

Type in the fragment of code above, and supply enough of the missing types, data, and code to get it running as a program. Then (horrors!) debug it into existence.

**How and Why to Cast**

The term "cast" has been applied since the dawn of C to mean both "type conversion" and "type disambiguation." If you say something like

(float) 3

it's a type conversion and the actual bits change. If you say

(float) 3.0

it's a type disambiguation, and the compiler can plant the correct bits in the first place. Some people say that casts are so-named because they help something broken to limp along.

It is easy to cast something to an elementary type: write the name of the new type (for example, int) in brackets before the expression you wish to cast. It is not quite so obvious how to cast to a more complicated type. Say you have a pointer to a void that you know actually contains a function pointer.

How do you do the typecast and call the function all in one statement?

Even complicated casts can be written following this three-step process.

1\. Look at the declaration of the object to which you wish to assign the casted result.

2\. Remove the identifier (and any storage class specifiers like extern), and enclose what remains in parentheses.

3\. Write the resulting text immediately to the left of the object you wish to cast.

As a practical example, programmers frequently discover that they need to cast to use the qsort() library routine. The routine takes four parameters, one of which is a pointer to a comparison routine.

Qsort is declared as

void qsort(void \*base, size_t nel, size_t width,

int (\*compar) (const void \*, const void \*));

When you call qsort() you will provide a pointer to your favorite comparison routine as argument compar. Your comparison routine will take an actual type rather than void \* arguments, so will likely look somewhat like this:

int intcompare(const int \*i, const int \*j)

{

return(\*i - \*j);

}

This does not exactly match what qsort expects for argument compar() so a cast is required. \[2\] Let's assume we have an array a of ten integers to sort. Following the three step cast process outlined above, we can see that the call will look like

\[2\] If you have a perverse and unpopular computer that makes the size of a pointer vary according to the type it points to, then you will have to do the cast in your comparison routine, rather than the call. Try to move to a better designed architecture as soon as possible.

qsort(

a,

10,

sizeof(int),

(int (\*)(const void \*, const void \*)) intcompare

);

As an impractical example, you can create a pointer to, for example printf(), with extern int printf(const char\*,...);

void \*f = (void\*)printf;

You can then call printf through a properly-cast pointer, in this manner: (\*(int(\*)(const char\*,...))f)("Bite my shorts. Also my chars and ints\n");

**Some Light Relief—The Inter national Obfuscated C Code Competition** *The C language combines all the power of assembly language with all the ease-of-use of assembly* *language.*

—Ancient Peasant Proverb

It's possible to abuse any programming language. Most good programmers can write programs that are so intense, it hurts your eyes just to look at them. Code that you can proudly show to programmers in the next office, and challenge them to figure out what it does. Code that, six months after writing it, *you* can't figure out what it does. You can write these kinds of programs in any language; it just seems to be easier with C.

The International Obfuscated C Code Competition (IOCCC) is an annual contest run since 1984 over USENET by Landon Curt Noll and Larry Bassel. It started when Landon looked at the source for the Bourne shell and decided, "Nah! It's just too outré." He began to wonder how far you could go if you actively tried to make C code look confusing, rather than just achieving this as an accidental side effect.

The competition has become an annual tradition. Entries are accepted in Winter, judging takes place over the Spring, and the winners are announced at the Summer Usenix conference. There are usually about ten categories of winner: "strangest abuse of the rules," "most creative source layout," "best one-liner," and so on. The overall "best of show" winner is whoever produces the most unreadable, and bizarre (but working) C program.

The IOCCC is a lot of fun, and can extend your knowledge in surprising ways, whether you enter or merely analyze the prize-winning code afterward. For example, in 1987, David Korn of Bell Labs submitted this winning entry:

main() { printf(&unix\["\021%six\012\0"\],(unix)\["have"\]+"fun"-

0x60);}

![Image 112](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-195_1.png)

What does *that* print? (Hint: it's not "have fun"!) David wrote the eponymous Korn shell, which is widely regarded as much cleaner than the version 7 /bin/sh, so presumably the IOCCC also acts as a safety valve for the happy hacker.

A 1988 winner was an obfuscated version of cdecl, submitted by programmer Gopi Reddy. Recall that we needed about 150 lines to program this unobfuscated. The obfuscated code is less than a dozen lines

\#include\<stdio.h\>

\#include\<ctype.h\>

\#define w printf

\#define p while

\#define t(s) (W=T(s))

char\*X,\*B,\*L,I\[99\];M,W,V;D(){W==9?(w("\`%.\*s' is

",V,X),t(0)):W==40?

(t(0),D(),t(41)):W==42?(t(0),D(),w("ptr to ")):0;p(W==40?(t(0), w("func returning "),t(41)):W==91?(t(0)==32?(w("array\[0..%d\]

of ",

atoi(X)-1),t(0)):w("array of "),t(93)):0);}main(){p(w("input:

"),

B=gets(I))if(t(0)==9)L=X,M=V,t(0),D(),w("%.\*s.\n\n",M,L);}T(s)

{if(!s\|\|s==W)

{p(\*B==9\|\|\*B==32)B++;X=B;V=0;if(W=isalpha(\*B)?9:isdigit(\*B)?32

:\*B++)

if(W\<33)p(isalnum(\*B))B++,V++;}return W;}

This kind of obfuscation, using excessive ? and , operators, is a little vieux chapeau now, but at the time it was novel and the program's conciseness is certainly astonishing. Figur-ing out how it works is left as an exercise for the reader. (Ha! I've always wanted to say that.) To get you started, there are two subroutines, T(), which lexes the next token and says whether it is an identifier, number, etc., and D(), which does the parsing. Try unscrambling it by running it through the preprocessor and formatting it. Then turn all the ? expressions into if statements. Iterate until readable.

The final obfuscated C example is a BASIC interpreter, submitted by University of London graduate student Diomidis Spinellis and written in about 1,500 characters! It was accompanied by an instruction manual that explained how to use the interpreter, and provided a sample BASIC program.

**Software Dogma**

**DDS-BASIC Interpreter (Version 1.00)**

**Immediate commands:**

*RUN*

LIST

NEW

BYE

OLD *filename*

SAVE *filename*

**Program commands:**

variable names A to Z

variables initialized to 0 on RUN

FOR var = exp TO exp

NEXT variable

GOSUB exp

RETURN

GOTO exp

IF exp THEN exp

INPUT variable

PRINT string

PRINT exp

var = exp

REM any text

END

**Expressions (ranked by precedence):**

bracketed expressions

number (leading 0 for octal, 0x for hex, else decimal), variable Unary -

\* /

\+ -

= \<\>

\> \<

\<= \>=

\* and + are also used for boolean AND and boolean OR

boolean expressions evaluate to 0 for false and 1 for true

**Editing:**

Line editor using line re-entry.

A line number with nothing following it deletes the line.

**Input format**:

Free format positioning of tokens on the line.

No space is allowed before the line number.

Exactly one space is needed between the OLD or SAVE command and the filename.

ALL INPUT MUST BE UPPERCASE.

**Limits:**

Line numbers:

1–10000

Line length:

999 characters

FOR nesting:

26

GOSUB: 999

levels

Program: Dynamically

allocated

Expressions:

-32768–32767 for 16-bit machines,

-2147483648–2147483647 for 32-bit machines

**Error checking / error reports:**

No error checking is performed.

The message "core dumped" signifies a syntax or semantic error.

**Hosting environment:**

ANSI C, traditional K&R C

ASCII or EBCDIC character set

48 Kbytes memory

The sample BASIC program provided was the old lunar lander game: 10 REM Lunar Lander

20 REM By Diomidis Spinellis

30 PRINT "You are on the Lunar Lander about to leave the

spacecraft."

60 GOSUB 4000

70 GOSUB 1000

80 GOSUB 2000

90 GOSUB 3000

100 H=H-V

110 V=((V+G)\*10-U\*2)/10

120 F=F-U

130 IFH\>0THEN 80

135 H = 0

140 GOSUB 2000

150 IFV\>5THEN 200

160 PRINT "Congratulations! This was a very good landing."

170 GOSUB 5000

180 GOTO 10

200 PRINT "You have crashed."

210 GOTO 170

1000 REM Initialise

1010 V = 70

1020 F = 500

1030 H = 1000

1040 G = 2

1050 RETURN

2000 REM Print values

2010 PRINT " Meter readings"

2015 PRINT " --------------"

2020 PRINT "Fuel (gal):"

2030 PRINT F

2040 GOSUB 2100 + 100 \* (H \<\> 0)

2050 PRINT V

2060 PRINT "Height (m):"

2070 PRINT H

2080 RETURN

2100 PRINT "Landing velocity (m/sec):"

2110 RETURN

2200 PRINT "Velocity (m/sec):"

2210 RETURN

3000 REM User input

3005 IFF=0THEN 3070

3010 PRINT "How much fuel will you use?"

3020 INPUT U

3025 IFU\<0THEN 3090

3030 IF U \<= F THEN 3060

3040 PRINT "Sorry, you have not got that much fuel!"

3050 GOTO 3010

3060 RETURN

3070 U = 0

3080 RETURN

3090 PRINT "No cheating please! Fuel must be \>= 0."

3100 GOTO 3010

4000 REM Detachment

4005 PRINT "Ready for detachment"

4007 PRINT "-- COUNTDOWN --"

4010 FORI=1TO11

4020 PRINT 11 - I

4025 GOSUB 4500

4030 NEXT I

4035 PRINT "You have left the spacecraft."

4037 PRINT "Try to land with velocity less than 5 m/sec."

4040 RETURN

4500 REM Delay

4510 FORJ=1TO500

4520 NEXT J

4530 RETURN

5000 PRINT "Do you want to play again? (0 = no,1=yes)"

5010 INPUT Y

5020 IFY=0THEN 5040

5030 RETURN

5040 PRINT "Have a nice day."

If you type this into a file called LANDER.BAS, you can compile and run it with these commands in the BASIC interpreter:

OLD LANDER.BAS

RUN

The obfuscated BASIC interpreter itself looks like this:

\#define O(b,f,u,s,c,a) \\

b(){into=f();switch(\*p++){Xu:\_osb();Xc:\_oab();default:p--;\_o;}}

\#define t(e,d,\_,C)X e:f=fopen(B+d,\_);C;fclose(f)

\#define U(y,z) while(p=Q(s,y))\*p++=z,\*p=' '

\#define N for(i=0;i\<11\*R;i++)m\[i\]&&

\#define I "%d %s\n",i,m\[i\]

\#define X ;break;case

\#define \_ return

\#define R 999

typedef char\*A;int\*C,E\[R\],L\[R\],M\[R\],P\[R\],l,i,j;char

B\[R\],F\[2\];A m\[12\*R\],malloc

(),p,q,x,y,z,s,d,f,fopen();A Q(s,o)A

s,o;{for(x=s;\*x;x++){for(y=x,z=o;\*z&&\*y==

\*z;y++)z++;if(z\>o&&!\*z)\_ x;}\_

0;}main(){m\[11\*R\]="E";while(puts("Ok"),gets(B)

)switch(\*B){X'R':C=E;l=1;for(i=0;i\<R;P\[i++\]=0);while(l){while(

!(s=m\[l\]))l++;if

(!Q(s,"\\")){U("\<\>",'#');U("\<=",'\$');U("\>=",'!');}d=B;while(\*F

=\*s){\*s=='"'&&j

++;if(j&1\|\|!Q(" \t",F))\*d++=\*s;s++;}\*d--

=j=0;if(B\[1\]!='=')switch(\*B){X'E':l=-1

X'R':B\[2\]!='M'&&(l=\*--

C)X'I':B\[1\]=='N'?gets(p=B),P\[\*d\]=S():(\*(q=Q(B,"TH"))=0,p

=B+2,S()&&(p=q+4,l=S()-

1))X'P':B\[5\]=='"'?\*d=0,puts(B+6):(p=B+5,printf("%d\n",S

()))X'G':p=B+4,B\[2\]=='S'&&(\*C++=l,p++),l=S()-1

X'F':\*(q=Q(B,"TO"))=0;p=B+5;P\[i

=B\[3\]\]=S();p=q+2;M\[i\]=S();L\[i\]=l

X'N':++P\[\*d\]\<=M\[\*d\]&&(l=L\[\*d\]);}else p=B+2,P\[

\*B\]=S();l++;}X'L':N printf(I)X'N':N free(m\[i\]),m\[i\]=0 X'B':\_ 0

t('S',5,"w",N

![Image 113](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-200_1.png)

fprintf(f,I))t('O',4,"r",while(fgets(B,R,f))(\*Q(B,"\n")=0,G())

)X 0:default:G()

;}\_ 0;}G(){l=atoi(B);m\[l\]&&free(m\[l\]);(p=Q(B,"

"))?strcpy(m\[l\]=malloc(strlen(p

)),p+1):(m\[l\]=0,0);}O(S,J,'=',==,'#',!=)O(J,K,'\<',\<,'\>',\>)O(K, V,'\$',\<=,'!',\>=)

O(V,W,'+',+,'-',-)O(W,Y,'\*',\*,'/',/)Y(){int o;\_\*p=='-'?p++,-

Y():\*p\>='0'&&\*p\<=

'9'?strtol(p,&p,0):\*p=='('?p++,o=S(),p++,o:P\[\*p++\];}

Watch for the difference between the letter "l" and the digit "1" when you type this in! If it's on the left-hand side of an assignment, it must be the letter "l".

This is an incredible program, and it's well worth reverse-engineering it to remove the obfuscation and see how it works. If this fires your imagination, you'll be pleased to hear that you too can enter the IOCCC. Just read the comp.lang.c newsgroup on Usenet and follow the instructions posted there in late Autumn. Be warned that the winners are among the best programmers in the world, and they're doing their worst.

**Programming Solution**

**Type Promotion Mix-Up in Prototypes**

main() {

union {

double d;

float f;

}u;

u.d = 10.0;

printf(" put in a double, pull out a float f= %f

\n", u.f);

u.f=10.0;

printf(" put in a float, pull out a double d= %f

\n", u.d);

}

%a.out

put in a double, pull out a float f= 2.562500

put in a float, pull out a double d= 524288.000000

![Image 114](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-201_1.png)

**Programming Solution**

**Asynchronous I/O**

The code below causes an SVr4-based OS to send an interrupt for each character entered on the standard input.

\#include \<errno.h\>

\#include \<signal.h\>

\#include \<stdio.h\>

\#include \<stropts.h\>

\#include \<sys/types.h\>

\#include \<sys/conf.h\>

int iteration=0;

char crlf \[\]={0xd,0xa, 0};

void handler(int s)

{

int c=getchar(); /\* read a character \*/

printf("got char %c, at count %d

%s",c,iteration,crlf);

if (c=='q') {

system("stty sane");

exit(0);

}

}

main()

{

sigset(SIGPOLL, handler); /\* set up the handler \*/

system("stty raw -echo");

ioctl(0, I_SETSIG, S_RDNORM); /\* ask for interrupt

driven input \*/

for(;;iteration++);

/\* can do other stuff here \*/

}

Use sigset() instead of signal() and you won't have to re-register the signal handler each

![Image 115](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-202_1.png)

time. Sample output is:

% a.out

got char a, at count 1887525

got char b, at count 5979648

got char c, at count 7299030

got char d, at count 9802103

got char e, at count 11060214

got char q, at count 14551814

**Programming Solution**

**cdecl as an FSM**

\#include \<stdio.h\>

\#include \<string.h\>

\#include \<ctype.h\>

\#define MAXTOKENS 100

\#define MAXTOKENLEN 64

enum type_tag { IDENTIFIER, QUALIFIER, TYPE };

struct token {

char type;

char string\[MAXTOKENLEN\];

};

int top = -1;

/\* holds all the tokens before first identifier \*/

struct token stack\[MAXTOKENS\];

/\* holds the token just read \*/

struct token this;

\#define pop stack\[top--\]

\#define push(s) stack\[++top\]=s

enum type_tag

classify_string(void)

/\* figure out the identifier type \*/

{

char \*s = this.string;

if (!strcmp(s, "const")) {

strcpy(s, "read-only");

return QUALIFIER;

}

if (!strcmp(s, "volatile")) return QUALIFIER;

if (!strcmp(s, "void")) return TYPE;

if (!strcmp(s, "char")) return TYPE;

if (!strcmp(s, "signed")) return TYPE;

if (!strcmp(s, "unsigned")) return TYPE;

if (!strcmp(s, "short")) return TYPE;

if (!strcmp(s, "int")) return TYPE;

if (!strcmp(s, "long")) return TYPE;

if (!strcmp(s, "float")) return TYPE;

if (!strcmp(s, "double")) return TYPE;

if (!strcmp(s, "struct")) return TYPE;

if (!strcmp(s, "union")) return TYPE;

if (!strcmp(s, "enum")) return TYPE;

return IDENTIFIER;

}

void gettoken(void)

{ /\* read next token into "this" \*/

char \*p = this.string;

/\* read past any spaces \*/

while ((\*p = getchar()) == ' ');

if (isalnum(\*p)) {

/\* it starts with A-Z,1-9 read in identifier \*/

while (isalnum(\*++p = getchar()));

ungetc(\*p, stdin);

\*p = '\0';

this.type = classify_string();

return;

}

this.string\[1\] = '\0';

this.type = \*p;

return;

}

void initialize(),

get_array(), get_params(), get_lparen(),

get_ptr_part(), get_type();

void (\*nextstate)(void) = initialize;

int main()

/\* Cdecl written as a finite state machine \*/

{

/\* transition through the states, until the pointer

is null \*/

while (nextstate != NULL)

(\*nextstate)();

return 0;

}

void initialize()

{

gettoken();

while (this.type != IDENTIFIER) {

push(this);

gettoken();

}

printf("%s is ", this.string);

gettoken();

nextstate = get_array;

}

void get_array()

{

nextstate = get_params;

while (this.type == '\[') {

printf("array ");

gettoken();/\* a number or '\]' \*/

if (isdigit(this.string\[0\])) {

printf("0..%d ", atoi(this.string) - 1);

gettoken();/\* read the '\]' \*/

}

gettoken();/\* read next past the '\]' \*/

printf("of ");

nextstate = get_lparen;

}

}

void get_params()

{

nextstate = get_lparen;

if (this.type == '(') {

while (this.type != ')') {

gettoken();

}

gettoken();

printf("function returning ");

}

}

void get_lparen()

{

nextstate = get_ptr_part;

if (top \>= 0) {

if (stack\[top\].type == '(') {

pop;

gettoken();/\* read past ')' \*/

nextstate = get_array;

}

}

}

void get_ptr_part()

{

nextstate = get_type;

if (stack\[top\].type == '\*') {

printf("pointer to ");

pop;

nextstate = get_lparen;

} else if (stack\[top\].type == QUALIFIER) {

printf("%s ", pop.string);

nextstate = get_lparen;

}

}

void get_type()

{

nextstate = NULL;

/\* process tokens that we stacked while reading to

identifier \*/

while (top \>= 0) {

printf("%s ", pop.string);

}

printf("\n");

}