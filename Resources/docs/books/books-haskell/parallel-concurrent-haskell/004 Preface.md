## Preface

As one of the developers of the Glasgow Haskell Compiler (GHC) for almost 15 years, I have seen Haskell grow from a niche research language into a rich and thriving ecosystem. I spent a lot of that time working on GHC’s support for parallelism and concurrency. One of the first things I did to GHC in 1997 was to rewrite its runtime system, and a key decision we made at that time was to build concurrency right into the core of the system rather than making it an optional extra or an add-on library. I like to think this decision was founded upon shrewd foresight, but in reality it had as much to do with the fact that we found a way to reduce the overhead of concurrency to near zero (previously it had been on the order of 2%; we’ve always been performance-obsessed). Nevertheless, having concurrency be non-optional meant that it was always a first-class part of the implementation, and I’m sure that this decision was instrumental in bringing about GHC’s solid and lightning-fast concurrency support.

Haskell has a long tradition of being associated with parallelism. To name just a few of the projects, there was the pH variant of Haskell derived from the Id language, which was designed for parallelism, the GUM system for running parallel Haskell programs on multiple machines in a cluster, and the GRiP system: a complete computer architecture designed for running parallel functional programs. All of these happened well before the current multicore revolution, and the problem was that this was the time when Moore’s law was still giving us ever-faster computers. Parallelism was difficult to achieve, and didn’t seem worth the effort when ordinary computers were getting exponentially faster.

Around 2004, we decided to build a parallel implementation of the GHC runtime system for running on shared memory multiprocessors, something that had not been done before. This was just before the multicore revolution. Multiprocessor machines were fairly common, but multicores were still around the corner. Again, I’d like to think the decision to tackle parallelism at this point was enlightened foresight, but it had more to do with the fact that building a shared-memory parallel implementation was an interesting research problem and sounded like fun. Haskell’s purity was essential—it meant that we could avoid some of the overheads of locking in the runtime system and garbage collector, which in turn meant that we could reduce the overhead of using parallelism to a low-single-digit percentage. Nevertheless, it took more research, a rewrite of the scheduler, and a new parallel garbage collector before the implementation was really usable and able to speed up a wide range of programs. The paper I presented at the International Conference on Functional Programming (ICFP) in 2009 marked the turning point from an interesting prototype into a usable tool.

All of this research and implementation was great fun, but good-quality resources for teaching programmers how to use parallelism and concurrency in Haskell were conspicuously absent. Over the last couple of years, I was fortunate to have had the opportunity to teach two summer school courses on parallel and concurrent programming in Haskell: one at the Central European Functional Programming (CEFP) 2011 summer school in Budapest, and the other the CEA/EDF/INRIA 2012 Summer School at Cadarache in the south of France. In preparing the materials for these courses, I had an excuse to write some in-depth tutorial matter for the first time, and to start collecting good illustrative examples. After the 2012 summer school I had about 100 pages of tutorial, and thanks to prodding from one or two people (see the Acknowledgments), I decided to turn it into a book. At the time, I thought I was about 50% done, but in fact it was probably closer to 25%. There’s a lot to say! I hope you enjoy the results.

## Audience

You will need a working knowledge of Haskell, which is not covered in this book. For that, a good place to start is an introductory book such as [*Real World Haskell*](http://shop.oreilly.com/product/9780596514983.do) (O’Reilly), *Programming in Haskell* (Cambridge University Press), *Learn You a Haskell for Great Good!* (No Starch Press), or *Haskell: The Craft of Functional Programming* (Addison-Wesley).

## How to Read This Book

The main goal of the book is to get you programming competently with Parallel and Concurrent Haskell. However, as you probably know by now, learning about programming is not something you can do by reading a book alone. This is why the book is deliberately practical: There are lots of examples that you can run, play with, and extend. Some of the chapters have suggestions for exercises you can try out to get familiar with the topics covered in that chapter, and I strongly recommend that you either try a few of these, or code up some of your own ideas.

As we explore the topics in the book, I won’t shy away from pointing out pitfalls and parts of the system that aren’t perfect. Haskell has been evolving for over 20 years but is moving faster today than at any point in the past. So we’ll encounter inconsistencies and parts that are less polished than others. Some of the topics covered by the book are very recent developments: Chapters 4, 5, 6, and pass:\[14 cover frameworks that were developed in the last few years.

The book consists of two mostly independent parts: Part I and Part II. You should feel free to start with either part, or to flip between them (i.e., read them concurrently!). There is only one dependency between the two parts: Chapter 13 will make more sense if you have read Part I first, and in particular before reading The ParIO monad, you should have read Chapter 4.

While the two parts are mostly independent from each other, the chapters should be read sequentially within each part. This isn’t a reference book; it contains running examples and themes that are developed across multiple chapters.

## Conventions Used in This Book

The following typographical conventions are used in this book:

 *Italic*  
Used for emphasis, new terms, URLs, Unix commands and utilities, and file and directory names.

 `Constant width`  
Indicates variables, functions, types, parameters, objects, and other programming constructs.

### Tip

This icon signifies a tip, suggestion, or a general note.

### Caution

This icon indicates a trap or pitfall to watch out for, typically something that isn’t immediately obvious.

Code samples look like this:

*timetable1.hs*

```
search :: ( partial -> Maybe solution )   -- ①
       -> ( partial -> [ partial ] )
       -> partial
       -> [solution]
```

The heading gives the filename of the source file containing the code snippet, which may be found in the sample code; see Sample Code for how to obtain the sample code. When there are multiple snippets quoted from the same file, usually only the first will have the filename heading.

①  
There will often be commentary referring to individual lines in the code snippet, which look like this.

Commands that you type into the shell look like this:

```
$ ./logger
hello
bye
logger: stop
```

The `$` character is the prompt, the command follows it, and the rest of the lines are the output generated by the command.

GHCi sessions look like this:

```
> extent arr
(Z :. 3) :. 5
> rank (extent arr)
2
> size (extent arr)
15
```

I often set GHCi’s prompt to the character `>` followed by a space, because GHCi’s default prompt gets overly long when several modules are imported. You can do the same using this command in GHCi:

```
Prelude> :set prompt "> "
>
```

## Using Sample Code

The sample code that accompanies the book is available online; see Sample Code for details on how to get it and build it. For information on your rights to use, modify, and redistribute the sample code, see the file *LICENSE* in the sample code distribution.

## Safari® Books Online

### Note

[Safari Books Online](http://my.safaribooksonline.com/?portal=oreilly) is an on-demand digital library that delivers expert [content](http://www.safaribooksonline.com/content) in both book and video form from the world’s leading authors in technology and business.

Technology professionals, software developers, web designers, and business and creative professionals use Safari Books Online as their primary resource for research, problem solving, learning, and certification training.

Safari Books Online offers a range of [product mixes](http://www.safaribooksonline.com/subscriptions) and pricing programs for [organizations](http://www.safaribooksonline.com/organizations-teams), [government agencies](http://www.safaribooksonline.com/government), and [individuals](http://www.safaribooksonline.com/individuals). Subscribers have access to thousands of books, training videos, and prepublication manuscripts in one fully searchable database from publishers like O’Reilly Media, Prentice Hall Professional, Addison-Wesley Professional, Microsoft Press, Sams, Que, Peachpit Press, Focal Press, Cisco Press, John Wiley & Sons, Syngress, Morgan Kaufmann, IBM Redbooks, Packt, Adobe Press, FT Press, Apress, Manning, New Riders, McGraw-Hill, Jones & Bartlett, Course Technology, and dozens [more](http://www.safaribooksonline.com/publishers). For more information about Safari Books Online, please visit us [online](http://www.safaribooksonline.com/).

## How to Contact Us

Please address comments and questions concerning this book to the publisher:

|                                               |
|-----------------------------------------------|
| O’Reilly Media, Inc.                          |
| 1005 Gravenstein Highway North                |
| Sebastopol, CA 95472                          |
| 800-998-9938 (in the United States or Canada) |
| 707-829-0515 (international or local)         |
| 707-829-0104 (fax)                            |

We have a web page for this book, where we list errata, examples, and any additional information. You can access this page at [http://oreil.ly/parallel-concurrent-prog-haskell](http://oreil.ly/parallel-concurrent-prog-haskell).

To comment or ask technical questions about this book, send email to <bookquestions@oreilly.com>.

For more information about our books, courses, conferences, and news, see our website at [http://www.oreilly.com](http://www.oreilly.com).

Find us on Facebook: [http://facebook.com/oreilly](http://facebook.com/oreilly)

Follow us on Twitter: [http://twitter.com/oreillymedia](http://twitter.com/oreillymedia)

Watch us on YouTube: [http://www.youtube.com/oreillymedia](http://www.youtube.com/oreillymedia)

## Acknowledgments

For several months I have had a head full of Parallel and Concurrent Haskell without much room for anything else, so firstly and most importantly I would like to thank my wife for her encouragement, patience, and above all, cake, during this project.

Secondly, all of this work owes a lot to Simon Peyton Jones, who has led the GHC project since its inception and has always been my richest source of inspiration. Simon’s relentless enthusiasm and technical insight have been a constant driving force behind GHC.

Thanks to Mary Sheeran and Andres Löh (among others), who persuaded me to turn my tutorial notes into this book, and thanks to the organizers of the CEFP and CEA/EDF/INRIA summer schools for inviting me to give the courses that provided the impetus to get started, and to the students who attended those courses for being my guinea pigs.

Many thanks to my editor, Andy Oram, and the other folks at O’Reilly who helped this book become a reality.

The following people have helped with the book in some way, either by reviewing early drafts, sending me suggestions, commenting on the online chapters, writing some code that I borrowed (with attribution, I hope), writing a paper or blog post from which I took ideas, or something else (if I’ve forgotten you, I’m sorry): Joey Adams, Lennart Augustsson, Tuncer Ayaz, Jost Berthold, Manuel Chakravarty, Duncan Coutts, Andrew Cowie, Iavor Diatchki, Chris Dornan, Sigbjorn Finne, Kevin Hammonad, Tim Harris, John Hughes, Mikolaj Konarski, Erik Kow, Chris Kuklewicz, John Launchbury, Roman Leshchinskiy, Ben Lippmeier, Andres Löh, Hans-Wolfgang Loidl, Ian Lynagh, Trevor L. McDonell, Takayuki Muranushi, Ryan Newton, Mary Sheeran, Wren ng Thornton, Bryan O’Sullivan, Ross Paterson, Thomas Schilling, Michael Snoyman, Simon Thomson, Johan Tibell, Phil Trinder, Bas Van Dijk, Phil Wadler, Daniel Winograd-Cort, Nicolas Wu, and Edward Yang.

Finally, thanks to the Haskell community for being one of the most friendly, inclusive, helpful, and stimulating online open source communities I’ve come across. We have a lot to be proud of, folks; keep it up.