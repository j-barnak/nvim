*about this book*

*Rust in Action* is primarily intended for people who may have explored Rust’s free material online, but who then have asked themselves, “What’s next?” This book contains dozens of examples that are interesting and can be extended as creativity and time allow. Those examples allow the book’s 12 chapters to cover a productive subset of Rust and many of the ecosystem’s most important third-party libraries.

The code examples emphasize accessiblity to beginners over elegant, idiomatic Rust. If you are already a knowledgeable Rust programmer, you may find yourself disagreeing with some style decisions in the examples. I hope that you will tolerate this for the sake of learners.

*Rust in Action* is not intended as a comprehensive reference text book. There are parts of the languages and standard library that have been omitted. Typically, these are highly specialized and deserve specific treatment. Instead, this book aims to provide readers with enough basic knowledge and confidence to learn specialized topics when necessary. *Rust in Action* is also unique from the point of view of systems programming books as almost every example works on Microsoft Windows.

***Who should read this book***

Anyone who is interested in Rust, who learns by applying practical examples, or who is intimidated by the fact that Rust is a systems programming language will enjoy *Rust in* *Action*. Readers with prior programming experience will benefit most as some computer programming concepts are assumed.

**xix**

**xx**

ABOUT THIS BOOK

***How this book is organized: A roadmap***

*Rust in Action* has two parts. The first introduces Rust’s syntax and some of its distinctive characteristics. The second part applies the knowledge gained in part one to several projects. In each chapter, one or two new Rust concepts are introduced. That said, part 1 provides a quick-fire introduction to Rust:

■

Chapter 1, “Introducing Rust,” explains why Rust exists and how to get started programming with it.

■

Chapter 2, “Language foundations,” provides a solid base of Rust syntax. Examples include a Mandelbrot set renderer and a grep clone.

■

Chapter 3, “Compound data types,” explains how to compose Rust data types and its error-handling facilities.

■

Chapter 4, “Lifetimes, ownership, and borrowing,” discusses the mechanisms for ensuring that accessing data is always valid.

Part 2 applies Rust to introductory systems programming areas:

■

Chapter 5, “Data in Depth,” covers how information is represented in digital computers with a special emphasis on how numbers are approximated. Examples include a bespoke number format and a CPU emulator.

■

Chapter 6, “Memory,” explains the terms references, pointers, virtual memory, stack, and heap. Examples include a memory scanner and a generative art project.

■

Chapter 7, “Files and storage,” explains the process for storing data structures into storage devices. Examples include a hex dump clone and a working database.

■

Chapter 8, “Networking,” provides an explanation of how computers communicate by reimplementing HTTP multiple times, stripping away a layer of abstraction each time.

■

Chapter 9, “Time and timekeeping,” explores the process for keeping track of time within a digital computer. Examples include a working NTP client.

■

Chapter 10, “Processes, threads, and containers,” explains processes, threads, and related abstractions. Examples include a turtle graphics application and a parallel parser.

■

Chapter 11, “Kernel,” describes the role of the operating system and how computers boot up. Examples include compiling your own bootloader and an operating system kernel.

■

Chapter 12, “Signals, interrupts, and exceptions,” explains how the external world communicates with the CPU and operating systems.

The book is intended to be read linearly. Latter chapters assume knowledge taught in earlier ones. However, projects from each chapter are standalone. Therefore, you are welcome to jump backward and forward if there are topics that you would like to cover.

ABOUT THIS BOOK

**xxi**

***About the code***

The code examples in *Rust in Action* are written with the 2018 edition of Rust and have been tested with Windows and Ubuntu Linux. No special software is required outside of a working Rust installation. Installation instructions are provided in chapter 2.

This book contains many examples of source code both in numbered listings and inline with normal text. In both cases, source code is formatted in a fixed-width font, like this, to separate it from ordinary text. Sometimes code is also in **bold** to highlight code that has changed from the previous steps in the chapter, such as when a new feature is added to an existing line of code.

In many cases, the original source code has been reformatted; we’ve added line breaks and reworked indentation to accommodate the available page space in the book. In rare cases, even this was not enough, and listings include line-continuation markers (➥). Additionally, comments in the source code have often been removed from the listings when the code is described in the text. Code annotations accompany many of the listings, highlighting important concepts.

***liveBook discussion forum***

Purchase of *Rust in Action* includes free access to a private web forum run by Manning Publications where you can make comments about the book, ask technical questions, and receive help from the author and from other users:

■

To access the forum, go to [https://livebook.manning.com/book/rust-in-action/](https://livebook.manning.com/book/rust-in-action/welcome/v-16/)

[welcome/v-16/](https://livebook.manning.com/book/rust-in-action/welcome/v-16/).

■

You can also learn more about Manning’s forums and the rules of conduct at this location: <https://livebook.manning.com/#!/discussion>.

Manning’s commitment to our readers is to provide a venue where a meaningful dia-logue between individual readers and between readers and the author can take place.

It is not a commitment to any specific amount of participation on the part of the author, whose contribution to the forum remains voluntary (and unpaid). We suggest you try asking the author some challenging questions lest his interest stray! The forum and the archives of previous discussions will be accessible from the publisher’s website as long as the book is in print.

***Other online resources***

Tim can be found on social media as @timClicks. His primary channels are Twitter ([https://twitter.com/timclicks),](https://twitter.com/timclicks) YouTube [(https://youtube.com/c/timclicks),](https://youtube.com/c/timclicks) and Twitch ([https://twitch.tv/timclicks).](https://twitch.tv/timclicks) You are also welcome to join his Discord server at

<https://discord.gg/vZBX2bDa7W>.