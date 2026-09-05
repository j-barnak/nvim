# Preface

Rust is a language for systems programming.

This bears some explanation these days, as systems programming is unfamiliar to most working programmers. Yet it underlies everything we do.

You close your laptop. The operating system detects this, suspends all the running programs, turns off the screen, and puts the computer to sleep. Later, you open the laptop: the screen and other components are powered up again, and each program is able to pick up where it left off. We take this for granted. But systems programmers wrote a lot of code to make that happen.

Systems programming is for:

- Operating systems

- Device drivers of all kinds

- Filesystems

- Databases

- Code that runs in very cheap devices, or devices that must be extremely reliable

- Cryptography

- Media codecs (software for reading and writing audio, video, and image files)

- Media processing (for example, speech recognition or photo editing software)

- Memory management (for example, implementing a garbage collector)

- Text rendering (the conversion of text and fonts into pixels)

- Implementing higher-level programming languages (like JavaScript and Python)

- Networking

- Virtualization and software containers



- Scientific simulations

- Games

In short, systems programming is *resource-constrained* programming. It is programming when every byte and every CPU cycle counts.

The amount of systems code involved in supporting a basic app is staggering.

This book will not teach you systems programming. In fact, this book covers many details of memory management that might seem unnecessarily abstruse at first, if you haven’t already done some systems programming on your own. But if you are a seasoned systems programmer, you’ll find that Rust is something exceptional: a new tool that eliminates major, well-understood problems that have plagued a whole industry for decades.

# Who Should Read This Book

If you’re already a systems programmer and you’re ready for an alternative to C++, this book is for you. If you’re an experienced developer in any programming language, whether that’s C#, Java, Python, JavaScript, or something else, this book is for you too.

However, you don’t just need to learn Rust. To get the most out of the language, you also need to gain some experience with systems programming. We recommend reading this book while also implementing some systems programming side projects in Rust. Build something you’ve never built before, something that takes advantage of Rust’s speed, concurrency, and safety. The list of topics at the beginning of this preface should give you some ideas.

# Why We Wrote This Book

We set out to write the book we wished we had when we started learning Rust. Our goal was to tackle the big, new concepts in Rust up front and head-on, presenting them clearly and in depth so as to minimize learning by trial and error.

# Navigating This Book

The first two chapters of this book introduce Rust and provide a brief tour before we move on to the fundamental data types in Chapter 3. Chapters 4 and 5 address the core concepts of ownership and references. We recommend reading these first five chapters through in order.

Chapters 6 through 10 cover the basics of the language: expressions (Chapter 6), error handling (Chapter 7), crates and modules (Chapter 8), structs (Chapter 9), and enums and patterns (Chapter 10). It’s all right to skim a little here, but don’t skip the chapter on error handling. Trust us.

Chapter 11 covers traits and generics, the last two big concepts you need to know. Traits are like interfaces in Java or C#. They’re also the main way Rust supports integrating your types into the language itself. Chapter 12 shows how traits support operator overloading, and Chapter 13 covers many more utility traits.

Understanding traits and generics unlocks the rest of the book. Closures and iterators, two key power tools that you won’t want to miss, are covered in Chapters 14 and 15, respectively. You can read the remaining chapters in any order, or just dip into them as needed. They cover the rest of the language: collections (Chapter 16), strings and text (Chapter 17), input and output (Chapter 18), concurrency (Chapter 19), asynchronous programming (Chapter 20), macros (Chapter 21), unsafe code (Chapter 22), and calling functions in other languages (Chapter 23).

# Conventions Used in This Book

The following typographical conventions are used in this book:

*Italic*  
Indicates new terms, URLs, email addresses, filenames, and file extensions.

`Constant width`  
Used for program listings, as well as within paragraphs to refer to program elements such as variable or function names, databases, data types, environment variables, statements, and keywords.

**`Constant width bold`**  
Shows commands or other text that should be typed literally by the user.

*`Constant width italic`*  
Shows text that should be replaced with user-supplied values or by values determined by context.

###### Note

This icon signifies a general note.

# Using Code Examples

Supplemental material (code examples, exercises, etc.) is available for download at [*https://github.com/ProgrammingRust*](https://github.com/ProgrammingRust).

This book is here to help you get your job done. In general, if example code is offered with this book, you may use it in your programs and documentation. You do not need to contact us for permission unless you’re reproducing a significant portion of the code. For example, writing a program that uses several chunks of code from this book does not require permission. Selling or distributing examples from O’Reilly books does require permission. Answering a question by citing this book and quoting example code does not require permission. Incorporating a significant amount of example code from this book into your product’s documentation does require permission.

We appreciate, but do not require, attribution. An attribution usually includes the title, author, publisher, and ISBN. For example: “*Programming Rust, Second Edition* by Jim Blandy, Jason Orendorff, and Leonora F. S. Tindall (O’Reilly). Copyright 2021 Jim Blandy, Leonora F. S. Tindall, and Jason Orendorff, 978-1-492-05259-3.”

If you feel your use of code examples falls outside fair use or the permission given above, feel free to contact us at [*permissions@oreilly.com*](mailto:permissions@oreilly.com).

# O’Reilly Online Learning

###### Note

For more than 40 years, [*O’Reilly Media*](http://oreilly.com) has provided technology and business training, knowledge, and insight to help companies succeed.

Our unique network of experts and innovators share their knowledge and expertise through books, articles, conferences, and our online learning platform. O’Reilly’s online learning platform gives you on-demand access to live training courses, in-depth learning paths, interactive coding environments, and a vast collection of text and video from O’Reilly and 200+ other publishers. For more information, please visit [*http://oreilly.com*](http://www.oreilly.com).

# How to Contact Us

Please address comments and questions concerning this book to the publisher:

- O’Reilly Media, Inc.
- 1005 Gravenstein Highway North
- Sebastopol, CA 95472
- 800-998-9938 (in the United States or Canada)
- 707-829-0515 (international or local)
- 707-829-0104 (fax)

We have a web page for this book, where we list errata, examples, and any additional information. You can access this page at [*https://oreil.ly/programming-rust-2e*](https://oreil.ly/programming-rust-2e).

Email [*bookquestions@oreilly.com*](mailto:bookquestions@oreilly.com) to comment or ask technical questions about this book.

Visit [*http://www.oreilly.com*](http://www.oreilly.com) for more information about our books and courses.

Find us on Facebook: [*http://facebook.com/oreilly*](http://facebook.com/oreilly)

Follow us on Twitter: [*http://twitter.com/oreillymedia*](http://twitter.com/oreillymedia)

Watch us on YouTube: [*http://youtube.com/oreillymedia*](http://youtube.com/oreillymedia)

# Acknowledgments

The book you are holding has benefited greatly from the attention of our official technical reviewers: Brian Anderson, Matt Brubeck, J. David Eisenberg, Ryan Levick, Jack Moffitt, Carol Nichols, and Erik Nordin; and our translators: Hidemoto Nakada (中田 秀基) (Japanese), Mr. Songfeng Li (Simplified Chinese), and Adam Bochenek and Krzysztof Sawka (Polish).

Many other unofficial reviewers read early drafts and provided invaluable feedback. We would like to thank Eddy Bruel, Nick Fitzgerald, Graydon Hoare, Michael Kelly, Jeffrey Lim, Jakob Olesen, Gian-Carlo Pascutto, Larry Rabinowitz, Jaroslav Šnajdr, Joe Walker, and Yoshua Wuyts for their thoughtful comments. Jeff Walden and Nicolas Pierron were especially generous with their time, reviewing almost the entire book. Like any programming venture, a programming book thrives on quality bug reports. Thank you.

Mozilla was extremely accommodating of Jim’s and Jason’s work on this project, even though it fell outside our official responsibilities and competed with them for our attention. We are grateful to Jim’s and Jason’s managers: Dave Camp, Naveed Ihsanullah, Tom Tromey, and Joe Walker, for their support. They take a long view of what Mozilla is about; we hope these results justify the faith they placed in us.

We would also like to express our appreciation for everyone at O’Reilly who helped bring this project to fruition, especially our astonishingly patient editors Jeff Bleiel and Brian MacDonald, and our acquisitions editor Zan McQuade.

Most of all, our heartfelt thanks to our families for their unwavering love, enthusiasm, and patience.