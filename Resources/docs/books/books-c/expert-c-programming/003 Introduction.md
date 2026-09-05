**Introduction**

*C code. C code run. Run code run…please!*

—Barbara Ling

*All C programs do the same thing: look at a character and do nothing with it.*

—Peter Weinberger

Have you ever noticed that there are plenty of C books with suggestive names like *C Traps and* *Pitfalls*, or *The C Puzzle Book*, or *Obfuscated C and Other Mysteries*, but other programming languages don't have books like that? There's a very good reason for this!

C programming is a craft that takes years to perfect. A reasonably sharp person can learn the basics of C quite quickly. But it takes much longer to master the nuances of the language and to write enough programs, and enough different programs, to become an expert. In natural language terms, this is the difference between being able to order a cup of coffee in Paris, and (on the Metro) being able to tell a native Parisienne where to get off. This book is an advanced text on the ANSI C programming language. It is intended for people who are already writing C programs, and who want to quickly pick up some of the insights and techniques of experts.

Expert programmers build up a tool kit of techniques over the years; a grab-bag of idioms, code fragments, and deft skills. These are acquired slowly over time, learned from looking over the shoulders of more experienced colleagues, either directly or while maintaining code written by others.

Other lessons in C are self-taught. Almost every beginning C programmer independently rediscovers the mistake of writing:

if (i=3)

instead of:

if (i==3)

Once experienced, this painful error (doing an assignment where comparison was intended) is rarely repeated. Some programmers have developed the habit of writing the literal first, like this: if (3==i). Then, if an equal sign is accidentally left out, the compiler will complain about an

"attempted assignment to literal." This won't protect you when comparing two variables, but every little bit helps.

![Image 2](media/index-3_1.png)

![Image 3](media/index-3_2.png)

**The \$20 Million Bug**

In Spring 1993, in the Operating System development group at SunSoft, we had a "priority one" bug report come in describing a problem in the asynchronous I/O library. The bug was holding up the sale of \$20 million worth of hardware to a customer who specifically needed the library functionality, so we were extremely motivated to find it. After some intensive debugging sessions, the problem was finally traced to a statement that read :

x==2;

It was a typo for what was intended to be an assignment statement. The programmer 's finger had bounced on the "equals" key, accidentally pressing it twice instead of once. The statement as written compared x to 2, generated true or false, and discarded the result .

C is enough of an expression language that the compiler did not complain about a statement which evaluated an expression, had no side-effects, and simply threw away the result. We didn't know whether to bless our good fortune at locating the problem, or cry with frustration at such a common typing error causing such an expensive problem. Some versions of the lint program would have detected this problem, but it's all too easy to avoid the automatic use of this essential tool.

This book gathers together many other salutary stories. It records the wisdom of many experienced programmers, to save the reader from having to rediscover everything independently. It acts as a guide for territory that, while broadly familiar, still has some unexplored corners. There are extended discussions of major topics like declarations and arrays/pointers, along with a great many hints and mnemonics. The terminology of ANSI C is used throughout, along with translations into ordinary English where needed.

**Programming Challenge**

OR

**Handy Heuristic**

**Sample Box**

Along the way, we have **Programming Challenges** outlined in boxes like this one.

These are suggestions for programs that you should write.

There are also **Handy Heuristics** in boxes of their own.

These are ideas, rules-of-thumb, or guidelines that work in practice. You can adopt them as your own. Or you can ignore them if you already have your own guidelines that you like better.

**Convention**

One convention that we have is to use the names of fruits and vegetables for variables (only in small code fragments, not in any real program, of course):

char pear\[40\];

double peach;

int mango = 13;

long melon = 2001;

This makes it easy to tell what's a C reserved word, and what's a name the programmer supplied.

Some people say that you can't compare apples and oranges, but why not—they are both hand-held round edible things that grow on trees. Once you get used to it, the fruit loops really seem to help.

There is one other convention—sometimes we repeat a key point to emphasize it. In addition, we sometimes repeat a key point to emphasize it.

Like a gourmet recipe book, *Expert C Programming* has a collection of tasty morsels ready for the reader to sample. Each chapter is divided into related but self-contained sections; it's equally easy to read the book serially from start to finish, or to dip into it at random and review an individual topic at length. The technical details are sprinkled with many true stories of how C programming works in practice. Humor is an important technique for mastering new material, so each chapter ends with a

"light relief" section containing an amusing C story or piece of software folklore to give the reader a change of pace.

Readers can use this book as a source of ideas, as a collection of C tips and idioms, or simply to learn more about ANSI C, from an experienced compiler writer. In sum, this book has a collection of useful ideas to help you master the fine art of ANSI C. It gathers all the information, hints, and guidelines together in one place and presents them for your enjoyment. So grab the back of an envelope, pull out your lucky coding pencil, settle back at a comfy terminal, and let the fun begin!

**Some Light Relief—Tuning File Systems**

Some aspects of C and UNIX are occasionally quite lighthearted. There's nothing wrong with well-placed whimsy. The IBM/Motorola/Apple PowerPC architecture has an E.I.E.I.O. instruction \[1\] that stands for "Enforce In-order Execution of I/O". In a similar spirit, there is a UNIX command,

![Image 4](media/index-5_1.png)

tunefs, that sophisticated system administrators use to change the dynamic parameters of a filesystem and improve the block layout on disk.

\[1\] Probably designed by some old farmer named McDonald.

The on-line manual pages of the original tunefs, like all Berkeley commands, ended with a "Bugs"

section. In this case, it read:

Bugs:

This program should work on mounted and active file systems,

but it doesn't. Because the superblock is not kept in the

buffer cache, the program will only take effect if it is run

on dismounted file systems; if run on the root file system,

the system must be rebooted. You can tune a file system, but

you can't tune a fish.

Even better, the word-processor source had a comment in it, threatening anyone who removed that last phrase! It said:

Take this out and a UNIX Demon will dog your steps from now

until the time_t's wrap around.

When Sun, along with the rest of the world, changed to SVr4 UNIX, we lost this gem. The SVr4

manpages don't have a "Bugs" section—they renamed it "Notes" (does that fool anyone?). The "tuna fish" phrase disappeared, and the guilty party is probably being dogged by a UNIX demon to this day.

Preferably lpd.

**Programming Challenge**

**Computer Dating**

When will the time_t's wrap around?

Write a program to find out.

1\. Look at the definition of time_t. This is in file /usr/include/time.h.

2\. Code a program to place the highest value into a variable of type time_t, then pass it to ctime() to convert it into an ASCII string. Print the string. Note that ctime has nothing to do with the language C, it just means "convert time."

![Image 5](media/index-6_1.png)

For how many years into the future does the anonymous technical writer who removed the comment have to worry about being dogged by a UNIX daemon? Amend your program to find out.

1\. Obtain the current time by calling time().

2\. Call difftime() to obtain the number of seconds between now and the highest value of time_t.

3\. Format that value into years, months, weeks, days, hours, and minutes. Print it.

Is it longer than your expected lifetime?

**Programming Solution**

**Computer Dating**

The results of this exercise will vary between PCs and UNIX systems, and will depend on the way time_t is stored. On Sun systems, this is just a typedef for long. Our first attempted solution is

\#include \<stdio.h\>

\#include \<time.h\>

int main() {

time_t biggest = 0x7FFFFFFF;

printf("biggest = %s \n", ctime(&biggest) );

return 0;

}

This gives a result of:

biggest = Mon Jan 18 19:14:07 2038

However, this is not the correct answer! The function ctime() converts its argument into *local* time, which will vary from Coordinated Universal Time (also known as Greenwich Mean Time), depending on where you are on the globe. California, where this book was written, is eight hours behind London, and several years ahead.

We should really use the gmtime() function to obtain the largest UTC time value. This function doesn't return a printable string, so we call asctime()to get this. Putting it all

together, our revised program is

\#include \<stdio.h\>

\#include \<time.h\>

int main() {

time_t biggest = 0x7FFFFFFF;

printf("biggest = %s \n", asctime(gmtime(&biggest)) ); return 0;

}

This gives a result of:

biggest = Tue Jan 19 03:14:07 2038

There! Squeezed another eight hours out of it!

But we're *still* not done. If you use the locale for New Zealand, you can get 13 more hours, assuming they use daylight savings time in the year 2038. They are on DST in January because they are in the southern hemisphere. New Zealand, because of its easternmost position with respect to time zones, holds the unhappy distinction of being the first country to encounter bugs triggered by particular dates.

Even simple-looking things can sometimes have a surprising twist in software. And anyone who thinks programming dates is easy to get right the first time probably hasn't done much of it.