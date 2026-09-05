**Chapter 1. C Through the Mists of Time**

*C is quirky, flawed, and an enormous success.*

—Dennis Ritchie

the prehistory of C…the golden rule for compiler-writers… early experiences with C…the standard I/O library and C preprocessor…K&R C…the present day: ANSI C…it's nice, but is it standard?…the structure of the ANSI C standard…reading the ANSI C standard for fun, pleasure, and profit…how quiet is a "quiet change"?…some light relief—the implementation-defined effects of pragmas **The Prehistory of C**

The story of C begins, paradoxically, with a failure. In 1969 the great Multics project—a joint venture between General Electric, MIT, and Bell Laboratories to build an operating system—was clearly in trouble. It was not only failing to deliver the promised fast and convenient on-line system, it was failing to deliver anything usable at all. Though the development team eventually got Multics creaking into action, they had fallen into the same tarpit that caught IBM with OS/360. They were trying to create an operating system that was much too big and to do it on hardware that was much too small.

![Image 6](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-8_1.png)

Multics is a treasure house of solved engineering problems, but it also paved the way for C to show that small is beautiful.

As the disenchanted Bell Labs staff withdrew from the Multics project, they looked around for other tasks. One researcher, Ken Thompson, was keen to work on another operating system, and made several proposals (all declined) to Bell management. While waiting on official approval, Thompson and co-worker Dennis Ritchie amused themselves porting Thompson's "Space Travel" software to a little-used PDP-7. Space Travel simulated the major bodies of the solar system, and displayed them on a graphics screen along with a space craft that could be piloted and landed on the various planets. At the same time, Thompson worked intensively on providing the PDP-7 with the rudiments of a new operating system, much simpler and lighter-weight than Multics. Everything was written in assembler language. Brian Kernighan coined the name "UNIX" in 1970, paro-dying the lessons now learned from Multics on what not to do. Figure 1-1 charts early C, UNIX, and associated hardware.

***Figure 1-1. Early C, UNIX, and Associated Hardware***

In this potential chicken-and-egg situation, UNIX definitely came well before C (and it's also why UNIX system time is measured in seconds since January 1, 1970—that's when time began). However, this is the story not of poultry, but of programming. Writing in assembler proved awkward; it took longer to code data structures, and it was harder to debug and understand. Thompson wanted the advantages of a high-level implementation language, but without the PL/I \[1\] performance and complexity problems that he had seen on Multics. After a brief and unsuccessful flirtation with Fortran, Thompson created the language B by simplifying the research language BCPL \[2\] so its interpreter would fit in the PDP-7's 8K word memory. B was never really successful; the hardware memory limits only provided room for an interpreter, not a compiler. The resulting slow performance prevented B from being used for systems programming of UNIX itself.

\[1\] The difficulties involved in learning, using, and implementing PL/I led one programmer to pen this verse: IBM had a PL/I / Its syntax worse than JOSS / And everywhere this language went / It was a total loss.

JOSS was an earlier language, also not noted for simplicity.

\[2\] "BCPL: A Tool for Compiler Writing and System Programming," Martin Richards, Proc. AFIPS Spring Joint Computer Conference, 34 (1969), pp. 557-566. BCPL is not an acronym for the "Before C Programming

![Image 7](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-9_1.png)

Language", though the name *is* a happy coincidence. It is the "Basic Combined Programming Lan-guage"—

"basic" in the sense of "no frills"—and it was developed by a combined effort of researchers at London University and Cambridge University in England. A BCPL implementation was available on Multics.

**Software Dogma**

**The Golden Rule of Compiler-Writers:**

*Performance Is (almost) Everything.*

Performance is almost everything in a compiler. There are other concerns: meaningful error messages, good documentation, and product support. These factors pale in comparison with the importance users place on raw speed. Compiler performance has two aspects: runtime performance (how fast the code runs) and compile time performance (how long it takes to generate code). Runtime performance usually dominates, except in development and student environments.

Many compiler optimizations cause longer compilation times but make run times much shorter. Other optimizations (such as dead code elimination, or omitting runtime checks) speed up both compile time and run time, as well as reducing memory use. The downside of aggressive optimization is the risk that invalid results may not be flagged. Optimizers are very careful only to do safe transformations, but programmers can trigger bad results by writing invalid code (e.g., referencing outside an array's bounds because they "know" that the desired variable is adjacent).

This is why performance is *almost* but not quite everything—if you don't get accurate results, then it's immaterial how fast you get them. Compiler-writers usually provide compiler options so each programmer can choose the desired optimizations. B's lack of success, until Dennis Ritchie created a high-performance compiled version called "New B,"

illustrates the golden rule for compiler-writers.

B simplified BCPL by omitting some features (such as nested procedures and some loop-ing constructs) and carried forward the idea that array references should "decompose" into pointer-plus-offset references. B also retained the typelessness of BCPL; the only operand was a machine word.

Thompson conceived the ++ and -- operators and added them to the B compiler on the PDP-7. The popular and captivating belief that they're in C because the PDP-11 featured corresponding auto-increment/decrement addressing modes is wrong! Auto increment and decrement predate the PDP-11

hardware, though it is true that the C statement to copy a character in a string:

\*p++ = \*s++;

can be compiled particularly efficiently into the PDP-11 code:

movb (r0)+,(r1)+

leading some people to wrongly conclude that the former was created especially for the latter.

A typeless language proved to be unworkable when development switched in 1970 to the newly introduced PDP-11. This processor featured hardware support for datatypes of several different sizes, and the B language had no way to express this. Performance was also a problem, leading Thompson to reimplement the OS in PDP-11 assembler rather than B. Dennis Ritchie capitalized on the more powerful PDP-11 to create "New B," which solved both problems, multiple datatypes, and performance. "New B"—the name quickly evolved to "C"—was compiled rather than interpreted, and it introduced a type system, with each variable described in advance of use.

**Early Experiences with C**

The type system was added primarily to help the compiler-writer distinguish floats, doubles, and characters from words on the new PDP-11 hardware. This contrasts with languages like Pascal, where the purpose of the type system is to protect the programmer by restricting the valid operations on a data item. With its different philosophy, C rejects strong typing and permits the programmer to make assignments between objects of different types if desired. The type system was almost an afterthought, never rigorously evaluated or extensively tested for usability. To this day, many C programmers believe that "strong typing" just means pounding extra hard on the keyboard.

Many other features, besides the type system, were put in C for the C compiler-writer's benefit (and why not, since C compiler-writers were the chief customers for the first few years). Features of C that seem to have evolved with the compiler-writer in mind are:

• **Arrays start at 0 rather than 1.** Most people start counting at 1, rather than zero. Compiler-writers start with zero because we're used to thinking in terms of offsets. This is sometimes tough on non-compiler-writers; although a\[100\] appears in the definition of an array, you'd better not store any data at a\[100\], since a\[0\] to a\[99\] is the extent of the array.

• **The fundamental C types map directly onto underlying hardware.** There is no built-in complex-number type, as in Fortran, for example. The compiler-writer does not have to invest any effort in supporting semantics that are not directly provided by the hardware. C didn't support floating-point numbers until the underlying hardware provided it.

• **The auto keyword is apparently useless.** It is only meaningful to a compiler-writer making an entry in a symbol table—it says *this storage is automatically allocated on entering* *the block* (as opposed to global static allocation, or dynamic allocation on the heap). Auto is irrelevant to other programmers, since you get it by default.

• **Array names in expressions "decay" into pointers.** It simplifies things to treat arrays as pointers. We don't need a complicated mechanism to treat them as a composite object, or suffer the inefficiency of copying everything when passing them to a function. But don't make the mistake of thinking arrays and pointers are always equivalent; more about this in Chapter 4.

• **Floating-point expressions were expanded to double-length-precision everywhere.**

Although this is no longer true in ANSI C, originally real number constants were always doubles, and float variables were always converted to double in all expressions. The reason, though we've never seen it appear in print, had to do with PDP-11 floating-point hardware.

First, conversion from float to double on a PDP-11 or a VAX is really cheap: just append an extra word of zeros. To convert back, just ignore the second word. Then understand that some PDP-11 floating-point hardware had a mode bit, so it would do either all single-precision or all double-precision arithmetic, but to switch between the two you had to change modes.

Since most early UNIX programs weren't floating-point-intensive, it was easier to put the box in double-precision mode and leave it there than for the compiler-writer to try to keep track of it!

• **No nested functions (functions contained inside other functions).** This simplifies the compiler and slightly speeds up the runtime organization of C programs. The exact mechanism is described in Chapter 6, "Poetry in Motion: Runtime Data Structures."

• **The register keyword.** This keyword gave the compiler-writer a clue about what variables the programmer thought were "hot" (frequently referenced), and hence could usefully be kept in registers. It turns out to be a mistake. You get better code if the compiler does the work of allocating registers for individual uses of a variable, rather than reserving them for its entire lifetime at declaration. Having a register keyword simplifies the compiler by transferring this burden to the programmer.

There were plenty of other C features invented for the convenience of the C compiler-writer, too. Of itself this is not necessarily a bad thing; it greatly simplified the language, and by shunning complicated semantics (e.g., generics or tasking in Ada; string handling in PL/I; templates or multiple inheritance in C++) it made C much easier to learn and to implement, and gave faster performance.

Unlike most other programming languages, C had a lengthy evolution and grew through many intermediate shapes before reaching its present form. It has evolved through years of practical use into a language that is tried and tested. The first C compiler appeared circa 1972, over 20 years ago now.

As the underlying UNIX system grew in popularity, so C was carried with it. Its emphasis on low-level operations that were directly supported by the hardware brought speed and portability, in turn helping to spread UNIX in a benign cycle.

**The Standard I/O Library and C Preprocessor**

The functionality left out of the C compiler had to show up somewhere; in C's case it appears at runtime, either in application code or in the runtime library. In many other languages, the compiler plants code to call runtime support implicitly, so the programmer does not need to worry about it, but almost all the routines in the C library must be explicitly called. In C (when needed) the programmer must, for example, manage dynamic memory use, program variable-size arrays, test array bounds, and carry out range checks for him or herself.

Similarly, I/O was originally not defined within C; instead it was provided by library routines, which in practice have become a standardized facility. The portable I/O library was written by Mike Lesk \[3\]

and first appeared around 1972 on all three existing hardware platforms. Practical experience showed that performance wasn't up to expectations, so the library was tuned and slimmed down to become the standard I/O library.

\[3\] It was Michael who later expressed the hilariously ironic rule of thumb that "designing the system so that the manual will be as short as possible minimizes learning effort." (Datamation, November 1981, p.146).

Several comments come to mind, of which "Bwaa ha ha!" is probably the one that minimizes learning effort.

The C preprocessor, also added about this time at the suggestion of Alan Snyder, fulfilled three main purposes:

• String replacement, of the form "change all *foo* to *baz*", often to provide a symbolic name for a constant.

![Image 8](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-12_1.png)

• Source file inclusion (as pioneered in BCPL). Common declarations could be separated out into a header file, and made available to a range of source files. Though the ".h" convention was adopted for the extension of header files, unhappily no convention arose for relating the header file to the object library that contained the corresponding code.

• Expansion of general code templates. Unlike a function, the same macro argument can take different types on successive calls (macro actual arguments are just slotted unchanged into the output). This feature was added later than the first two, and sits a little awkwardly on C.

White space makes a big difference to this kind of macro expansion.

\#define a(y) a_expanded(y)

a(x);

expands into:

a_expanded(x);

However,

\#define a (y) a_expanded (y)

a(x);

is transformed into:

\(y\) a_expanded (y)(x);

Not even close to being the same thing. The macro processor could conceivably use curly braces like the rest of C to indicate tokens grouped in a block, but it does not.

There's no extensive discussion of the C preprocessor here; this reflects the view that the only appropriate use of the preprocessor is for macros that don't require extensive discussion. C++ takes this a step further, introducing several conventions designed to make the preprocessor completely unnecessary.

**Software Dogma**

**C Is Not Algol**

Writing the UNIX Version 7 shell (command interpreter) at Bell Labs in the late 1970's, Steve Bourne decided to use the C preprocessor to make C a little more like Algol-68.

Earlier at Cambridge University in England, Steve had written an Algol-68 compiler, and found it easier to debug code that had explicit "end statement" cues, such as if ... fi or case ... esac. Steve thought it wasn't easy enough to tell by looking at a " }"

what it matches. Accordingly, he set up many preprocessor definitions:

\#define STRING char \*

\#define IF if(

\#define THEN ){

\#define ELSE } else {

\#define FI ;}

\#define WHILE while (

\#define DO ){

\#define OD ;}

\#define INT int

\#define BEGIN {

\#define END }

This enabled him to code the shell using code like this:

INT compare(s1, s2)

STRING s1;

STRING s2;

BEGIN

WHILE \*s1++ == \*s2

DO IF \*s2++ == 0

THEN return(0);

FI

OD

return(\*--s1 - \*s2);

END

Now let's look at that again, in C this time:

int compare(s1, s2)

char \* s1, \*s2;

{

while (\*s1++ == \*s2) {

if (\*s2++ == 0) return (0);

}

return (\*--s1 - \*s2);

}

This Algol-68 dialect achieved legendary status as the Bourne shell permeated far beyond Bell Labs, and it vexed some C programmers. They complained that the dialect made it much harder for other people to maintain the code. The BSD 4.3 Bourne shell (kept in

/bin/sh) is written in the Algol subset to this day!

I've got a special reason to grouse about the Bourne shell—it's my desk that the bugs reported against it land on! Then I assign them to Sam! And we do see our share of bugs:

![Image 9](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-14_1.png)

![Image 10](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-14_2.png)

the shell doesn't use malloc, but rather does its own heap storage management using sbrk.

Maintenance on software like this too often introduces a new bug for every two it solves.

Steve explained that the custom memory allocator was done for efficiency in string-handling, and that he never expected anyone except himself to see the code.

The Bournegol C dialect actually inspired The International Obfuscated C Code Competition, a whimsical contest in which programmers try to outdo each other in inventing mysterious and confusing programs (more about this competition later).

Macro use is best confined to naming literal constants, and providing shorthand for a few well-chosen constructs. Define the macro name all in capitals so that, in use, it's instantly clear it's not a function call. Shun any use of the C preprocessor that modifies the underlying language so that it's no longer C.

**K&R C**

By the mid 1970's the language was recognizably the C we know and love today. Further refinements took place, mostly tidying up details (like allowing functions to return structure values) or extending the basic types to match new hardware (like adding the keywords unsigned and long). In 1978

Steve Johnson wrote *pcc*, the portable C compiler. The source was made available outside Bell Labs, and it was very widely ported, forming a common basis for an entire generation of C compilers. The evolutionary path up to the present day is shown in Figure 1-2.

***Figure 1-2. Later C***

**Software Dogma**

**An Unusual Bug**

One feature C inherited from Algol-68 was the assignment operator. This allows a repeated operand to be written once only instead of twice, giving a clue to the code generator that operand addressing can be similarly thrifty. An example of this is writing b+=3 as an abbreviation for b=b+3. Assignment operators were originally written with assignment first, not the operator, like this: b=+3. A quirk in B's lexical analyzer made it simpler to

implement as = *op* rather than *op*= as it is today. This form was confusing, as it was too easy to mix up

b=-3; /\* subtract 3 from b \*/

and

b= -3; /\* assign -3 to b \*/

The feature was therefore changed to its present ordering. As part of the change, the code formatter indent was modified to recognize the obsolete form of assignment operator and swap it round to operator assignment. This was very bad judgement indeed; no formatter should ever change anything except the white space in a program. Unhappily, two things happened. The programmer introduced a bug, in that almost anything (that wasn't a variable) that appeared after an assignment was swapped in position.

If you were "lucky" it would be something that would cause a syntax error, like epsilon=.0001;

being swapped into

epsilon.=0001;

But a source statement like

valve=!open; /\* valve is set to logical negation of open

\*/

would be silently transmogrified into

valve!=open; /\* valve is compared for inequality to open

\*/

which compiled fine, but did not change the value of valve.

The second thing that happened was that the bug lurked undetected. It was easy to work around by inserting a space after the assignment, so as the obsolete form of assignment operator declined in use, people just forgot that indent had been kludged up to "improve" it.

The indent bug persisted in some implementations up until the mid-1980's. Highly pernicious!

In 1978 the classic C bible, *The C Programming Language,* was published. By popular accla-mation, honoring authors Brian Kernighan and Dennis Ritchie, the name "K&R C" was applied to this version of the language. The publisher estimated that about a thousand copies would be sold; to date (1994) the figure is over one and a half million (see Figure 1-3). C is one of the most successful programming languages of the last two decades, perhaps the most successful. But as the language spread, the temptation to diverge into dialects grew.

***Figure 1-3. Like Elvis, C is Everywhere***

![Image 11](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-16_1.png)

**The Present Day: ANSI C**

By the early 1980's, C had become widely used throughout the industry, but with many different implementations and changes. The discovery by PC implementors of C's advantages over BASIC

provided a fresh boost. Microsoft had an implementation for the IBM PC which introduced new keywords (far, near, etc.) to help pointers to cope with the irregular architecture of the Intel 80x86

chip. As many other non-pcc-based implementations arose, C threatened to go the way of BASIC and evolve into an ever-diverging family of loosely related languages.

It was clear that a formal language standard was needed. Fortunately, there was much precedent in this area—all successful programming languages are eventually standardized. However, the problem with standards manuals is that they only make sense if you already know what they mean. If people write them in English, the more precise they try to be, the longer, duller and more obscure they become. If they write them using mathematical notation to define the language, the manuals become inaccessible to too many people.

Over the years, the manuals that define programming language standards have become longer, but no easier to understand. The Algol-60 Reference Definition was only 18 pages long for a language of comparable complexity to C; Pascal was described in 35 pages. Kernighan and Ritchie took 40 pages for their original report on C; while this left several holes, it was adequate for many implementors.

ANSI C is defined in a fat manual over 200 pages long. This book is, in part, a description of practical use that lightens and expands on the occasionally opaque text in the ANSI Standard document.

In 1983 a C working group formed under the auspices of the American National Standards Institute.

Most of the process revolved around identifying common features, but there were also changes and significant new features introduced. The far and near keywords were argued over at great length, but ultimately did not make it into the mildly UNIX-centric ANSI standard. Even though there are more than 50 million PC's out there, and it is by far the most widely used platform for C implementors, it was (rightly in our view) felt undesirable to mutate the language to cope with the limitations of one specific architecture.

**Handy Heuristic**

![Image 12](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-17_1.png)

![Image 13](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-17_2.png)

**Which Version of C to Use?**

At this point, anyone learning or using C should be working with ANSI C, not K&R C.

The language standard draft was finally adopted by ANSI in December 1989. The international standards organization ISO then adopted the ANSI C standard (unhappily removing the very useful

"Rationale" section and making trivial—but very annoy-ing—formatting and paragraph numbering changes). ISO, as an international body, is technically the senior organization, so early in 1990 ANSI readopted ISO C (again exclud-ing the Rationale) back in place of its own version. In principle, therefore, we should say that the C standard adopted by ANSI is ISO C, and we should refer to the language as ISO C. The Rationale is a useful text that greatly helps in understanding the standard, and it's published as a separate document. \[4\]

\[4\] The ANSI C Rationale (only) is available for free by anonymous ftp from the site ftp.uu.net, in directory

/doc/standards/ansi/X3.159-1989/.

(If you're not familiar with anonymous ftp, run, don't walk, to your nearest bookstore and buy a book on Internet, before you become \<insert lame driving metaphor of choice\> on the Information Highway.) The Rationale has also been published as a book, *ANSI C Rationale*, New Jersey, Silicon Press, 1990. The ANSI C standard itself is not available by ftp anywhere because ANSI derives an important part of its rev-enue from the sale of printed standards.

**Handy Heuristic**

**Where to Get a Copy of the C Standard**

The official name of the standard for C is: ISO/IEC 9899-1990. ISO/IEC is the International Organization for Standardization International Electrotechnical Commission. The standards bodies sell it for around \$130.00. In the U.S. you can get a copy of the standard by writing to:

American National Standards Institute

11 West 42nd Street

New York, NY 10036

Tel. (212) 642-4900

Outside the U.S. you can get a copy by writing to: ISO Sales

Case postale 56

CH-1211 Genève 20

Switzerland

Be sure to specify the English language edition.

Another source is to purchase the book *The Annotated ANSI C Standard* by Herbert Schildt, (New York, Osborne McGraw-Hill, 1993). This contains a photographically reduced, but complete, copy of the standard. Two other advantages of the Schildt book are that at \$39.95

it is less than one-third the price charged by the standards bodies, and it is available from your local bookstore which, unlike ANSI or ISO, has probably heard of the twentieth century, and will take phone orders using credit cards.

In practice, the term "ANSI C" was widely used even before there was an ISO Working Group 14

dedicated to C. It is also appropriate, because the ISO working group left the technical development of the initial standard in the hands of ANSI committee X3J11. Toward the end, ISO WG14 and X3J11

collaborated to resolve technical issues and to ensure that the resulting standard was acceptable to both groups. In fact, there was a year's delay at the end, caused by amending the draft standard to cover international issues such as wide characters and locales.

It remains ANSI C to anyone who has been following it for a few years. Having arrived at this good thing, everyone wanted to endorse the C standard. ANSI C is also a European standard (CEN 29899) and an X/Open standard. ANSI C was adopted as a Federal Information Processing Standard, FIPS

160, issued by the National Institute of Standards and Technology in March 1991, and updated on August 24, 1992. Work on C continues—there is talk of adding a complex number type to C.

**It's Nice, but Is It Standard?**

*Save a tree—disband an ISO working group today.*

—Anonymous

The ANSI C standard is unique in several interesting ways. It defines the following terms, describing characteristics of an implementation. A knowledge of these terms will aid in understanding what is and isn't acceptable in the language. The first two are concerned with unportable code; the next two deal with bad code; and the last two are about portable code.

**Unportable Code:**

*implementation-defined*— The compiler-writer chooses what happens, and has to document it.

Example: whether the sign bit is propagated, when shifting an int right.

*unspecified*— The behavior for something correct, on which the standard does not impose any requirements.

Example: the order of argument evaluation.

![Image 14](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-19_1.png)

![Image 15](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-19_2.png)

![Image 16](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-19_3.png)

**Bad Code:**

*undefined*— The behavior for something incorrect, on which the standard does not impose any requirements. Anything is allowed to happen, from nothing, to a warning message to program termination, to CPU meltdown, to launching nuclear missiles (assuming you have the correct hardware option installed).

Example: what happens when a signed integer overflows.

*a constraint*— This is a restriction or requirement that must be obeyed. If you don't, your program behavior becomes *undefined* in the sense above. Now here's an amazing thing: it's easy to tell if something is a constraint or not, because each topic in the standard has a subparagraph labelled

"Constraints" that lists them all. Now here's an even more amazing thing: the standard specifies \[5\] that compilers only have to produce error messages for violations of syntax and constraints! This means that any semantic rule that's not in a constraints subsection can be broken, and since the behavior is *undefined,* the compiler is free to do anything and doesn't even have to warn you about it!

\[5\] In paragraph 5.1.1.3, "Diagnostics", if you must know. Being a language standard, it doesn't say something simple like *you've got to flag at least one error in an incorrect program*. It says something grander that looks like it was drawn up by a team of corporate lawyers being paid by the word, namely, *a conforming* *implementation shall* \[\*\] *produce at least one diagnostic message (identified in an implementation-dependent* *manner) for every translation unit that contains a violation of any syntax rule or constraint. Diagnostic* *messages need not be produced in other circumstances.*

\[\*\] Useful rule from Brian Scearce \[ \] —if you hear a programmer say "shall" he or she is quoting from a standard.

\[

\] Inventor of the nested footnote.

Example: the operands of the % operator must have integral type. So using a non-integral type with %

must cause a diagnostic.

Example of a rule that is not a constraint: all identifiers declared in the C standard header files are reserved for the implementation, so you may not declare a function called malloc() because a standard header file already has a function of that name. But since this is not a constraint, the rule can be broken, and the compiler doesn't have to warn you! More about this in the section on

"interpositioning" in Chapter 5.

**Software Dogma**

**Undefined Behavior Causes CPU Meltdown in IBM PC's!**

The suggestion of undefined software behavior causing CPU meltdown isn't as farfetched as it first appears.

The original IBM PC monitor operated at a horizontal scan rate provided by the video controller chip. The flyback transformer (the gadget that produces the high voltage needed to accelerate the electrons to light up the phosphors on the monitor) relied on this being a reasonable frequency. However, it was possible, in software, to set the video chip scan rate to zero, thus feeding a constant voltage into the primary side of the transformer. It then acted as a resistor, and dissipated its power as heat rather than transforming it up onto the screen. This burned the monitor out in seconds. Voilà: undefined software behavior causes system meltdown!

**Portable Code:**

*strictly-conforming*— A *strictly-conforming* program is one that:

• only uses *specified* features.

• doesn't exceed any implementation-defined limit.

• has no output that depends on *implementation-defined*, *unspecified,* or *undefined* features.

This was intended to describe maximally portable programs, which will always produce the identical output whatever they are run on. In fact, it is not a very interesting class because it is so small compared to the universe of conforming programs. For example, the following program is not strictly conforming:

\#include \<limits.h\>

\#include \<stdio.h\>

int main() { (void) printf("biggest int is %d", INT_MAX); return 0;}

/\* not strictly conforming: implementation-defined output! \*/

For the rest of this book, we usually don't try to make the example programs be strictly conforming. It clutters up the text, and makes it harder to see the specific point under discussion. Program portability is valuable, so you should always put the necessary casts, return values, and so on in your real-world code.

*conforming*— A conforming program can depend on the nonportable features of an implementation.

So a program is *conforming* with respect to a specific implementation, and the same program may be nonconforming using a different compiler. It can have extensions, but not extensions that alter the behavior of a strictly-conforming program. This rule is not a constraint, however, so don't expect the compiler to warn you about violations that render your program nonconforming!

The program example above is conforming.

**Translation Limits**

The ANSI C standard actually specifies lower limits on the sizes of programs that must successfully translate. These are specified in paragraph 5.2.4.1. Most languages say how many characters can be in a dataname, and some languages stipulate what limit is acceptable for the maximum number of array dimensions. But specifying lower bounds on the sizes of various other features is unusual, not to say

unique in a programming language standard. Members of the standardization committee have commented that it was meant to guide the choice of minimum acceptable sizes.

Every ANSI C compiler is required to support at least:

• 31 parameters in a function definition

• 31 arguments in a function call

• 509 characters in a source line

• 32 levels of nested parentheses in an expression

• The maximum value of long int can't be any less than 2,147,483,647, (i.e., long integers are at least 32 bits).

and so on. Furthermore, a conforming compiler must compile and execute a program in which all of the limits are tested at once. A surprising thing is that these "required" limits are not actually constraints—so a compiler can choke on them without issuing an error message.

Compiler limits are usually a "quality of implementation" issue; their inclusion in ANSI C is an implicit acknowledgment that it will be easier to port code if definite expectations for some capacities are set for all implementations. Of course, a really good implementation won't have any preset limits, just those imposed by external factors like available memory or disk. This can be done by using linked lists, or dynamically expanding the size of tables when necessary (a technique explained in Chapter 10).

**The Structure of the ANSI C Standard**

It's instructive to make a quick diversion into the provenance and content of the ANSI C standard. The ANSI C standard has four main sections:

**Section 4:** **An introduction** and definition of terminology (5 pages).

**Section 5:** **Environment** (13 pages). This covers the system that surrounds and supports C, including what happens on program start-up, on termination, and with signals and floating-point operations.

Translator lower limits and character set information are also given.

**Section 6:** **The C language** (78 pages) This part of the standard is based on Dennis Ritchie's classic

"The C Reference Manual" which appeared in several publications, including Appendix A of *The C*

*Programming Language*. If you compare the Standard and the Appendix, you can see most headings are the same, and in the same order. The topics in the standard have a more rigid format, however, that looks like Figure 1-4 (empty subparagraphs are simply omitted).

***Figure 1-4. How a Paragraph in the ANSI C Standard Looks***

![Image 17](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-22_1.png)

The original Appendix is only 40 pages, while this section of the standard is twice as long.

**Section 7:** **The C runtime library** (81 pages). This is a list of the library calls that a conforming implementation must provide—the standard services and routines to carry out essential or helpful functions. The ANSI C standard's section 7 on the C runtime library is based on the /usr/group 1984

standard, with the UNIX-specific parts removed. "/usr/group" started life as an international user group for UNIX. In 1989 it was renamed "UniForum", and is now a nonprofit trade association dedicated to the promotion of the UNIX operating system.

UniForum's success in defining UNIX from a behavioral perspective encouraged many related initiatives, including the X/Open portability guides (version 4, XPG/4 came out in October 1992), IEEE POSIX 1003, the System V Interface Definition, and the ANSI C libraries. Everyone coordinated with the ANSI C working group to ensure that all their draft standards were mutually consistent. Thank heaven.

The ANSI C standard also features some useful appendices:

**Appendix F:** **Common warning messages.** Some popular situations for which diagnostic messages are not required, but when it is usually helpful to generate them nonetheless.

**Appendix G:** **Portability issues.** Some general advice on portability, collected into one place from throughout the standard. It includes information on behavior that is unspecified, undefined, and implementation-defined.

![Image 18](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-23_1.png)

![Image 19](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-23_2.png)

**Software Dogma**

**Standards Are Set in Concrete, Even the Mistakes**

Just because it's written down in an international standard doesn't mean that it's complete, consistent, or even correct. The IEEE POSIX 1003.1-1988 standard (it's an OS standard that defines UNIX-like behavior) has this fun contradiction:

"\[A pathname\] ... consists of at most PATH_MAX bytes, including the terminating null character."—section 2.3

"PATH_MAX is the maximum number of bytes in a pathname (not a string length; count excludes a terminating null)."—section 2.9.5

So PATH_MAX bytes both *includes* and *does not include* the terminating null!

An interpretation was requested, and the answer came back (IEEE Std 1003.1-1988/INT, 1992 Edition, Interpretation number: 15, p. 36) that it was an inconsistency and both can be right (which is pretty strange, since the whole point is that both *can't* be right).

The problem arose because a change at the draft stage wasn't propagated to all occurrences of the wording. The standards process is formal and rigid, so it cannot be fixed until an update is approved by a balloting group.

This kind of error also appears in the C standard in the very first footnote, which refers to the accompanying Rationale document. In fact, the Rationale no longer accompanies the C

Standard—it was deleted when ownership of the standard moved to ISO.

**Handy Heuristic**

**Differences between K&R C and ANSI C**

Rest assured that if you know K&R C, then you already know 90% of ANSI C. The differences between ANSI C and K&R C fall into four broad categories, listed below in order of importance:

1\. The first category contains things that are new, very different, and important. The only feature in this class is the prototype—writing the parameter types as part of

![Image 20](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-24_1.png)

the function declaration. Prototypes make it easy for a compiler to check function use with definition.

2\. The second category is new keywords. Several keywords were officially added: enum for enumerated types (first seen in late versions of pcc), const, volatile, signed, void, along with their associated semantics. The never-used entry keyword that found its way into C, apparently by oversight, has been retired.

3\. The third category is that of "quiet changes"—some feature that still compiles, but now has a slightly different meaning. There are many of these, but they are mostly not very important, and can be ignored until you push the boundaries and actually stumble across one of them. For example, now that the preprocessing rules are more tightly defined, there's a new rule that adjacent string literals are concatenated.

4\. The final category is everything else, including things that were argued over interminably while the language was being standardized, but that you will almost certainly never encounter in practice, for example, token-pasting or trigraphs.

(Trigraphs are a way to use three characters to express a single character that a particularly inadequate computer might not have in its character set. Just as the digraph \t represents "tab", so the trigraph ??\< represents "open curly brace".) The most important new feature was "prototypes", adopted from C++. Prototypes are an extension of function declarations so that not just the name and return type are known, but also all the parameter types, allowing the compiler to check for consistency between parameter use and declaration.

"Prototype" is not a very descriptive term for "a function name with all its arguments"; it would have been more meaningful to call it a "function signature", or a "function specification" as Ada does.

**Software Dogma**

**The Protocol of Prototypes**

The purpose of prototypes is to include some information on parameter types (rather than merely giving the function name and return value type) when we make a forward declaration of a function. The compiler can thus check the types of arguments in a function call against the way the parameters were defined. In K&R C, this check was deferred till link time or, more usually, omitted entirely. Instead of

char \* strcpy();

declarations in header files now look like this:

char \* strcpy(char \*dst, const char \*src);

You can also omit the names of the parameters, leaving only the types:

char \* strcpy(char \* , const char \* );

Don't omit the parameter names. Although the compiler doesn't check these, they often convey extra semantic information to the programmer. Similarly, the definition of the function has changed from

char \* strcpy(dst, src)

char \*dst, \*src;

{ ... }

to

char \* strcpy(char \*dst, const char \*src) /\* note no

semi-colon! \*/

{ ... }

Instead of being ended with a semicolon, the function header is now directly followed by a single compound statement comprising the body of the function.

Prototype everything new you write and ensure the prototype is in scope for every call.

Don't go back to prototype your old K&R code, unless you take into account the default type promotions—more about this in Chapter 8.

Having all these different terms for the same thing can be a little mystifying. It's rather like the way drugs have at least three names: the chemical name, the manufacturer 's brand name, and the street name.

**Reading the ANSI C Standard for Fun, Pleasure, and Profit**

Sometimes it takes considerable concentration to read the ANSI C Standard and obtain an answer from it. A sales engineer sent the following piece of code into the compiler group at Sun as a test case.

1 foo(const char \*\*p) { }

2

3 main(int argc, char \*\*argv)

4{

5 foo(argv);

6}

If you try compiling it, you'll notice that the compiler issues a warning message, saying: line 5: warning: argument is incompatible with prototype

The submitter of the code wanted to know why the warning message was generated, and what part of the ANSI C Standard mandated this. After all, he reasoned,

argument char \*s matches parameter const char \*p This is seen throughout all library string functions.

So doesn't argument char \*\*argv match parameter const char \*\*p ?

The answer is no, it does not. It took a little while to answer this question, and it's educational in more than one sense, to see the process of obtaining the answer. The analysis was carried out by one of Sun's "language lawyers," \[6\] and it runs like this:

\[6\] *The New Hacker's Dictionary* defines a language lawyer as "a person who will show you the five sentences scattered through a 200-plus-page manual that together imply the answer to your question 'if only you had thought to look there.'" Yep! That's exactly what happened in this case.

The Constraints portion of Section 6.3.2.2 of the ANSI C Standard includes the phrase: Each argument shall have a type such that its value may be assigned to an object with the unqualified version of the type of its corresponding parameter.

This says that argument passing is supposed to behave like assignment.

Thus, a diagnostic message must be produced unless an object of type const char \*\* may be assigned a value of type char \*\*.To find out whether this assignment is legal, flip to the section on simple assignment, Section 6.3.16.1, which includes the following constraint: One of the following shall hold:…

• Both operands are pointers to qualified or unqualified versions of compatible types, and the type pointed to by the left has all the qualifiers of the type pointed to by the right.

It is this condition that makes a call with a char \* argument corresponding to a const char \*

parameter legal (as seen throughout the string routines in the C library). This is legal because in the code

char \* cp;

const char \*ccp;

ccp = cp;

• The left operand is a pointer to "char qualified by const".

• The right operand is a pointer to "char" unqualified.

• The type char is a compatible type with char, and the type pointed to by the left operand has all the qualifiers of the type pointed to by the right operand (none), plus one of its own (const).

Note that the assignment cannot be made the other way around. Try it if you don't believe me.

cp = ccp; /\* results in a compilation warning \*/

![Image 21](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-27_1.png)

Does Section 6.3.16.1 also make a call with a char \*\* argument corresponding to a const char \*\* parameter legal? It does not.

The Examples portion of Section 6.1.2.5 states:

The type designated "const float \*" is not a qualified type—its type is "pointer to const-qualified float"

and is a pointer to a qualified type.

Analogously, const char \*\* denotes a pointer to an unqualified type. Its type is a pointer to a pointer to a qualified type.

Since the types char \*\* and const char \*\* are both pointers to unqualified types that are not the same type, they are not compatible types. Therefore, a call with an argument of type char

\*\* corresponding to a parameter of type const char \*\* is not allowed. Therefore, the constraint given in Section 6.3.2.2 is violated, and a diagnostic message must be produced.

This is a subtle point to grasp. Another way of looking at it is to note that:

• the left operand has type FOO2—a pointer to FOO, where FOO is an unqualified pointer to a character qualified by the const qualifier, and

• the right operand has type BAZ2—a pointer to BAZ, where BAZ is an unqualified pointer to a character with no qualifiers.

FOO and BAZ are compatible types, but FOO2 and BAZ2 differ other than in qualifica-tion of the thing *immediately* pointed to and are therefore not compatible types; therefore the left and right operands are unqualified pointers to types that are not compatible. Compatibility of pointer types is not transitive. Therefore, the assignment or function call is not permitted. However, note that the restriction serves mainly to annoy and confuse users. The assignment is currently allowed in C++

translators based on cfront (though that might change).

**Handy Heuristic**

**Const Isn't**

The keyword const doesn't turn a variable into a constant! A symbol with the const qualifier merely means that the symbol cannot be used for assignment. This makes the value re ad -onl y *through that symbol*; it does not prevent the value from being modified through some other means internal (or even external) to the program. It is pretty much useful only for qualifying a pointer parameter, to indicate that this function will not change the data that argument points to, but other functions may. This is perhaps the most common use of const in C and C++.

A const can be used for data, like so:

const int limit = 10;

and it acts somewhat as in other languages. When you add pointers into the equation, things get a little rough:

const int \* limitp = &limit;

int i=27;

limitp = &i;

This says that limitp is a pointer to a constant integer. The pointer cannot be used to change the integer; however, the pointer itself can be given a different value at any time. It will then point to a different location and dereferencing it will yield a different value!

The combination of const and \* is usually only used to simulate call-by-value for array parameters. It says, "I am giving you a pointer to this thing, but you may not change it."

This idiom is similar to the most frequent use of void \*. Although that could theoretically be used in any number of circumstances, it's usually restricted to converting pointers from one type to another.

Analogously, you can take the address of a constant variable, and, well, perhaps I had better not put ideas into people's heads. As Ken Thompson pointed out, "The const keyword only confuses library interfaces with the hope of catching some rare errors." In retrospect, the const keyword would have been better named readonly.

True, this whole area in the standard appears to have been rendered into English from Urdu via Danish by translators who had only a passing familiarity with any of these tongues, but the standards committee was having such a good time that it seemed a pity to ruin their fun by asking for some simpler, clearer rules.

We felt that a lot of people would have questions in the future, and not all of them would want to follow the process of reasoning shown above. So we changed the Sun ANSI C compiler to print out more information about what it found incompatible. The full message now says: Line 6: warning: argument \#1 is incompatible with prototype:

prototype: pointer to pointer to const char : "barf.c", line 1

argument : pointer to pointer to char

Even if a programmer doesn't understand *why*, he or she will now know *what* is incompatible.

**How Quiet is a "Quiet Change"?**

Not all the changes in the standard stick out as much as prototypes. ANSI C made a number of other changes, usually aimed at making the language more reliable. For instance, the "usual arithmetic

conversions" changed between ye olde originale K&R C and ANSI C. Thus, where Kernighan and Ritchie say something like:

Section 6.6 Arithmetic Conversions

A great many operators cause conversions and yield result types in a similar way. This pattern will be called the "usual arithmetic conversions."

First, any operands of type char or short are converted to int, and any of type float are converted to double. Then if either operand is double, the other is converted to double and that is the type of the result. Otherwise, if either operand is long, the other is converted to long and that is the type of the result. Otherwise, if either operand is unsigned, the other is converted to unsigned and that is the type of the result. Otherwise, both operands must be int, and that is the type of the result.

The ANSI C manual has closed the loopholes by rewriting this as: Section 6.2.1.1 Characters and Integers (the integral promotions) A char, a short int, or an int bit-field, or their signed or unsigned varieties, or an enumeration type, may be used in an expression wherever an int or unsigned int may be used. If an int can represent all the values of the original type, the value is converted to an int; otherwise it is converted to an unsigned int. These are called the integral promotions.

Section 6.2.1.5 Usual Arithmetic Conversions

Many binary operators that expect operands of arithmetic type cause conversions and yield result types in a similar way. The purpose is to yield a common type, which is also the type of the result.

This pattern is called the "usual arithmetic conversions."

First, if either operand has type long double, the other operand is converted to long double. Otherwise, if either operand has type double, the other operand is converted to double. Otherwise, if either operand has type float, the other operand is converted to float. Otherwise the integral promotions

\[refer to section 6.2.1.1 for the integral promotions\] are performed on both operands. Then the following rules are applied.

If either operand has type unsigned long int, the other operand is converted to unsigned long int.

Otherwise, if one operand has type long int and the other has type unsigned int, if a long int can represent all values of an unsigned int the operand of type unsigned int is converted to long int; if a long int cannot represent all the values of an unsigned int, both operands are converted to unsigned long int. Otherwise, if either operand has type long int, the other operand is converted to long int.

Otherwise, if either operand has type unsigned int, the other operand is converted to unsigned int.

Otherwise, both operands have type int.

The values of floating operands and of the results of floating expressions may be represented in greater precision and range than that required by the type; the types are not changed thereby.

In English (complete with loopholes and lack of precision), the ANSI C version would mean something like:

Operands with different types get converted when you do arithmetic. Everything is converted to the type of the floatiest, longest operand, signed if possible without losing bits.

![Image 22](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-30_1.png)

The *unsigned preserving* approach (K&R C) says that when an unsigned type mixes with an int or smaller signed type, the result is an unsigned type. This is a simple rule, independent of hardware, but, as in the example below, it does sometimes force a negative result to lose its sign!

The *value preserving* approach (ANSI C) says that when you mix integral operand types like this, the result type is signed or unsigned depending on the relative sizes of the operand types.

The following program fragment will print a different message under ANSI and pre-ANSI compilers: main() {

if ( -1 \< (unsigned char) 1 )

printf("-1 is less than (unsigned char) 1: ANSI

semantics ");

else

printf("-1 NOT less than (unsigned char) 1: K&R

semantics ");

}

Depending on whether you compile it under K&R or ANSI C, the expression will be evaluated differently. The same bitpatterns are compared, but interpreted as either a negative number, or as an unsigned and hence positive number.

**Software Dogma**

**A Subtle Bug**

Even though the rules were changed, subtle bugs can and do still occur. In this example, the variable d is one less than the index needed, so the code copes with it. But the if statement did not evaluate to true. Why, and what, is the bug?

int array\[\] = { 23, 34, 12, 17, 204, 99, 16 };

\#define TOTAL_ELEMENTS (sizeof(array) /

sizeof(array\[0\]))

main()

{

int d= -1, x;

/\* ... \*/

if (d \<= TOTAL_ELEMENTS-2)

x = array\[d+1\];

/\* ... \*/

![Image 23](/tmp/audit/iter1/epubregen/expert-c-programming/media/index-31_1.png)

}

The defined variable TOTAL_ELEMENTS has type unsigned int (because the return type of sizeof is "unsigned"). The test is comparing a signed int with an unsigned int quantity. So d is promoted to unsigned int. Interpreting -1 as an unsigned int yields a big positive number, making the clause false. This bug occurs under ANSI C, and under K&R C if sizeof() had an unsigned return type in a given implementation. It can be fixed by putting an int cast immediately before the TOTAL_ELEMENTS:

if (d \<= (int) TOTAL_ELEMENTS - 2)

**Handy Heuristic**

**Advice on Unsigned Types**

Avoid unnecessary complexity by minimizing your use of unsigned types. Specifically, don't use an unsigned type to represent a quantity just because it will never be negative (e.g., "age" or "national_debt").

Use a signed type like int and you won't have to worry about boundary cases in the detailed rules for promoting mixed types.

Only use unsigned types for bitfields or binary masks. Use casts in expressions, to make all the operands signed or unsigned, so the compiler does not have to choose the result type.

If this sounds a little tricky or surprising, it is! Work through the example using the rules on the previous page.

Finally, just so that we don't see this code appear as a bad example in a future edition of *The Elements* *of Programming Style* \[7\], we'd better explain that we used

\[7\] *The Elements of Programming Style*, Kernighan (yes, that Kernighan) and Plauger, New York, McGraw-Hill, 1978. A thundering good read, credible plot, great little book—buy it, read it, live it!

\#define TOTAL_ELEMENTS (sizeof(array) / sizeof(array\[0\]))

instead of

\#define TOTAL_ELEMENTS (sizeof(array) / sizeof(int))

because the former allows the base type of the array to change (from, say, int to char) without needing a change to the \#define, too.

The Sun ANSI C compiler team felt that moving from "unsigned preserving" to "value preserving"

was a totally unnecessary change to C's semantics that would surprise and dismay anyone who encountered it unexpectedly. So, under the "principle of least astonishment," the Sun compiler recognizes and compiles ANSI C features, unless the feature would give a different result under K&R

C. If this is the case, the compiler issues a warning and uses the K&R interpretation by default. In situations like the one above, the programmer should use a cast to tell the compiler what the final desired type is. Strict ANSI semantics are available on a Sun workstation running Solaris 2.x by using the compiler option -Xc.

There are plenty of other updates to K&R C in ANSI C, including a few more so-called "quiet changes" where code compiles under both but has a different meaning. Based on the usual programmer reaction when they are discovered, these really should be called "very noisy changes indeed". In general, the ANSI committee tried to change the language as little as possible, consistent with revising some of the things that undeniably needed improvement.

But that's enough background on the ANSI C family tree. After a little light relief in the following section, proceed to the next chapter and get started on code!

**Some Light Relief—The Implementation-Defined Effects of**

**Pragmas . . .**

The Free Software Foundation is a unique organization founded by ace MIT hacker Richard Stallman.

By the way, we use "hacker" in the old benevolent sense of "gifted programmer;" the term has been debased by the media, so outsiders use it to mean "evil genius." Like the adjective *bad*, "hacker" now has two opposing meanings, and you have to figure it out from the context.

Stallman's Free Software Foundation was founded on the philosophy that software should be free and freely available to all. FSF's charter is "to eliminate restrictions on copying, redistribution, understanding and modification of computer programs" and their ambition is to create a public-domain implementation of UNIX called GNU (it stands for "GNU's Not UNIX." Yes, really.) Many computer science graduate students and others agree with the GNU philosophy, and have worked on software products that FSF packages and distributes for free. This pool of skilled labor donating their talent has resulted in some good software. One of FSF's best products is the GNU C

compiler family. gcc is a robust, aggressive optimizing compiler, available for many hardware platforms and sometimes better than the manufacturer's compiler. Using gcc would not be appropriate for all projects; there are questions of maintenance and future product continuity. There are other tools needed besides a compiler, and the GNU debugger was unable to operate on shared libraries for a long time. GNU C has also occasionally been a little, shall we say, giddy in development.

When the ANSI C standard was under development, the pragma directive was introduced.

Borrowed from Ada, \#pragma is used to convey hints to the compiler, such as the desire to expand a particular function in-line or suppress range checks. Not previously seen in C, pragma met with some initial resistance from a gcc implementor, who took the "implementation-defined" effect very literally—in gcc version 1.34, the use of pragma causes the compiler to stop compiling and launch a computer game instead! The gcc manual contained the following:

The "#pragma" command is specified in the ANSI standard to have an arbitrary implementation-defined effect. In the GNU C preprocessor, "#pragma" first attempts to run the game "rogue"; if that fails, it tries to run the game "hack"; if that fails, it tries to run GNU Emacs displaying the Tower of Hanoi; if that fails, it reports a fatal error. In any case, preprocessing does not continue.

—Manual for version 1.34 of the GNU C compiler

And the corresponding source code in the preprocessor part of the compiler was:

/\*

\* the behavior of the \#pragma directive is implementation

defined.

\* this implementation defines it as follows.

\*/

do_pragma ()

{

close (0);

if (open ("/dev/tty", O_RDONLY, 0666) != 0)

goto nope;

close (1);

if (open ("/dev/tty", O_WRONLY, 0666) != 1)

goto nope;

execl ("/usr/games/hack", "#pragma", 0);

execl ("/usr/games/rogue", "#pragma", 0);

execl ("/usr/new/emacs", "-f", "hanoi", "9", "-kill", 0); execl ("/usr/local/emacs", "-f", "hanoi", "9", "-kill", 0); nope:

fatal ("You are in a maze of twisty compiler features, all different");

}

Especially droll is the fact that the description in the user manual is wrong, in that the code shows that

"hack" is tried before "rogue".