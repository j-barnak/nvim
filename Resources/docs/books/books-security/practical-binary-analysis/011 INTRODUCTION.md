## INTRODUCTION

The vast majority of computer programs are written in high-level languages like C or C++, which computers can’t run directly. Before you can use these programs, you must first compile them into *binary executables* containing machine code that the computer can run. But how do you know that the compiled program has the same semantics as the high-level source? The unnerving answer is that *you don’t*!

There’s a big semantic gap between high-level languages and binary machine code that not many people know how to bridge. Even most programmers have limited knowledge of how their programs really work at the lowest level, and they simply trust that the compiled program is true to their intentions. As a result, many compiler bugs, subtle implementation errors, binary-level backdoors, and malicious parasites can go unnoticed.

To make matters worse, there are countless binary programs and libraries—in industry, at banks, in embedded systems—for which the source code is long lost or proprietary. That means it’s impossible to patch those programs and libraries or assess their security at the source level using conventional methods. This is a real problem even for major software companies, as evidenced by Microsoft’s recent release of a painstakingly handcrafted binary patch for a buffer overflow in its Equation Editor program, which is part of the Microsoft Office suite.^(1)

In this book, you’ll learn how to analyze and even modify programs at the binary level. Whether you’re a hacker, a security researcher, a malware analyst, a programmer, or simply interested, these techniques will give you more control over and insight into the binary programs you create and use every day.

### What Is Binary Analysis, and Why Do You Need It?

*Binary analysis* is the science and art of analyzing the properties of binary computer programs, called *binaries*, and the machine code and data they contain. Briefly put, the goal of all binary analysis is to figure out (and possibly modify) the true properties of binary programs—in other words, what they *really* do as opposed to what we think they should do.

Many people associate binary analysis with reverse engineering and disassembly, and they’re at least partially correct. Disassembly is an important first step in many forms of binary analysis, and reverse engineering is a common application of binary analysis and is often the only way to document the behavior of proprietary software or malware. However, the field of binary analysis encompasses much more than this.

Broadly speaking, you can divide binary analysis techniques into two classes, or a combination of these:

**Static analysis** *Static analysis* techniques reason about a binary without running it. This approach has several advantages: you can potentially analyze the whole binary in one go, and you don’t need a CPU that can run the binary. For instance, you can statically analyze an ARM binary on an x86 machine. The downside is that static analysis has no knowledge of the binary’s runtime state, which can make the analysis very challenging.

**Dynamic analysis** In contrast, *dynamic analysis* runs the binary and analyzes it as it executes. This approach is often simpler than static analysis because you have full knowledge of the entire runtime state, including the values of variables and the outcomes of conditional branches. However, you see only the executed code, so the analysis may miss interesting parts of the program.

Both static and dynamic analyses have their advantages and disadvantages, and you’ll learn techniques from both schools of thought in this book. In addition to passive binary analysis, you’ll also learn *binary instrumentation* techniques that you can use to modify binary programs without needing source. Binary instrumentation relies on analysis techniques like disassembly, and at the same time it can be used to aid binary analysis. Because of this symbiotic relationship between binary analysis and instrumentation techniques, this books covers both.

I already mentioned that you can use binary analysis to document or pentest programs for which you don’t have source. But even if source is available, binary analysis can be useful to find subtle bugs that manifest themselves more clearly at the binary level than at the source level. Many binary analysis techniques are also useful for advanced debugging. This book covers binary analysis techniques that you can use in all these scenarios and more.

### What Makes Binary Analysis Challenging?

Binary analysis is challenging and much more difficult than equivalent analysis at the source code level. In fact, many binary analysis tasks are fundamentally undecidable, meaning that it’s impossible to build an analysis engine for these problems that always returns a correct result! To give you an idea of the challenges to expect, here is a list of some of the things that make binary analysis difficult. Unfortunately, the list is far from exhaustive.

**No symbolic information** When we write source code in a high-level language like C or C++, we give meaningful names to constructs such as variables, functions, and classes. We call these names *symbolic information*, or *symbols* for short. Good naming conventions make the source code much easier to understand, but they have no real relevance at the binary level. As a result, binaries are often stripped of symbols, making it much harder to understand the code.

**No type information** Another feature of high-level programs is that they revolve around variables with well-defined types, such as `int`, `float`, or `string`, as well as more complex data structures like `struct` types. In contrast, at the binary level, types are never explicitly stated, making the purpose and structure of data hard to infer.

**No high-level abstractions** Modern programs are compartmentalized into classes and functions, but compilers throw away these high-level constructs. That means binaries appear as huge blobs of code and data, rather than well-structured programs, and restoring the high-level structure is complex and error-prone.

**Mixed code and data** Binaries can (and do) contain data fragments mixed in with the executable code.^(2) This makes it easy to accidentally interpret data as code, or vice versa, leading to incorrect results.

**Location-dependent code and data** Because binaries are not designed to be modified, even adding a single machine instruction can cause problems as it shifts other code around, invalidating memory addresses and references from elsewhere in the code. As a result, any kind of code or data modification is extremely challenging and prone to breaking the binary.

As a result of these challenges, we often have to live with imprecise analysis results in practice. An important part of binary analysis is coming up with creative ways to build usable tools despite analysis errors!

### Who Should Read This Book?

This book’s target audience includes security engineers, academic security researchers, hackers and pentesters, reverse engineers, malware analysts, and computer science students interested in binary analysis. But really, I’ve tried to make this book accessible for anyone interested in binary analysis.

That said, because this book covers advanced topics, some prior knowledge of programming and computer systems is required. To get the most out of this book, you should have the following:

• A reasonable level of comfort programming in C and C++.

• A basic working knowledge of operating system internals (what a process is, what virtual memory is, and so on).

• Knowledge of how to use a Linux shell (preferably `bash`).

• A working knowledge of x86/x86-64 assembly. If you don’t know any assembly yet, make sure to read Appendix A first!

If you’ve never programmed before or you don’t like delving into the low-level details of computer systems, this book is probably not for you.

### What’s in This Book?

The primary goal of this book is to make you a well-rounded binary analyst who’s familiar with all the major topics in the field, including both basic topics and advanced topics like binary instrumentation, taint analysis, and symbolic execution. This book does *not* presume to be a comprehensive resource, as the binary analysis field and tools change so quickly that a comprehensive book would likely be outdated within a year. Instead, the goal is to make you knowledgeable enough on all important topics so that you’re well prepared to learn more independently.

Similarly, this book doesn’t dive into all the intricacies of reverse engineering x86 and x86-64 code (though Appendix A covers the basics) or analyzing malware on those platforms. There are many dedicated books on those subjects already, and it makes no sense to duplicate their contents here. For a list of books dedicated to manual reverse engineering and malware analysis, refer to Appendix D.

This book is divided into four parts.

**Part I: Binary Formats** introduces you to binary formats, which are crucial to understanding the rest of this book. If you’re already familiar with the ELF and PE binary formats and `libbfd`, you can safely skip one or more chapters in this part.

**Chapter 1: Anatomy of a Binary** provides a general introduction to the anatomy of binary programs.

**Chapter 2: The ELF Format** introduces you to the ELF binary format used on Linux.

**Chapter 3: The PE Format: A Brief Introduction** contains a brief introduction on PE, the binary format used on Windows.

**Chapter 4: Building a Binary Loader Using libbfd** shows you how to parse binaries with `libbfd` and builds a binary loader used in the rest of this book.

**Part II: Binary Analysis Fundamentals** contains fundamental binary analysis techniques.

**Chapter 5: Basic Binary Analysis in Linux** introduces you to basic binary analysis tools for Linux.

**Chapter 6: Disassembly and Binary Analysis Fundamentals** covers basic disassembly techniques and fundamental analysis patterns.

**Chapter 7: Simple Code Injection Techniques for ELF** is your first taste of how to modify ELF binaries with techniques like parasitic code injection and hex editing.

**Part III: Advanced Binary Analysis** is all about advanced binary analysis techniques.

**Chapter 8: Customizing Disassembly** shows you how to build your own custom disassembly tools with Capstone.

**Chapter 9: Binary Instrumentation** is about modifying binaries with Pin, a full-fledged binary instrumentation platform.

**Chapter 10: Principles of Dynamic Taint Analysis** introduces you to the principles of *dynamic taint analysis*, a state-of-the-art binary analysis technique that allows you to track data flows in programs.

**Chapter 11: Practical Dynamic Taint Analysis with libdft** teaches you to build your own dynamic taint analysis tools with `libdft`.

**Chapter 12: Principles of Symbolic Execution** is dedicated to *symbolic execution*, another advanced technique with which you can automatically reason about complex program properties.

**Chapter 13: Practical Symbolic Execution with Triton** shows you how to build practical symbolic execution tools with Triton.

**Part IV: Appendixes** includes resources that you may find useful.

**Appendix A: A Crash Course on x86 Assembly** contains a brief introduction to x86 assembly language for those readers not yet familiar with it.

**Appendix B: Implementing PT_NOTE Overwriting Using libelf** provides implementation details on the `elfinject` tool used in Chapter 7 and serves as an introduction to `libelf`.

**Appendix C: List of Binary Analysis Tools** contains a list of binary analysis tools you can use.

**Appendix D: Further Reading** contains a list of references, articles, and books related to the topics discussed in this book.

### How to Use This Book

To help you get the most out of this book, let’s briefly go over the conventions with respect to code examples, assembly syntax, and development platform.

#### *Instruction Set Architecture*

While you can generalize many techniques in this book to other architectures, I’ll focus the practical examples on the Intel x86 *Instruction Set Architecture (ISA)* and its 64-bit version x86-64 (x64 for short). I’ll refer to both the x86 and x64 ISA simply as “x86 ISA.” Typically, the examples will deal with x64 code unless specified otherwise.

The x86 ISA is interesting because it’s incredibly common both in the consumer market, especially in desktop and laptop computers, and in binary analysis research (in part because of its popularity in end user machines). As a result, many binary analysis frameworks are targeted at x86.

In addition, the complexity of the x86 ISA allows you to learn about some binary analysis challenges that don’t occur on simpler architectures. The x86 architecture has a long history of backward compatibility (dating back to 1978), leading to a very dense instruction set, in the sense that the vast majority of possible byte values represent a valid opcode. This exacerbates the code versus data problem, making it less obvious to disassemblers that they’ve mistakenly interpreted data as code. Moreover, the instruction set is variable length and allows unaligned memory accesses for all valid word sizes. Thus, x86 allows unique complex binary constructs, such as (partially) overlapping and misaligned instructions. In other words, once you’ve learned to deal with an instruction set as complex as x86, other instruction sets (such as ARM) will come naturally!

#### *Assembly Syntax*

As explained in Appendix A, there are two popular syntax formats used to represent x86 machine instructions: *Intel syntax* and *AT&T syntax*. Here, I’ll use Intel syntax because it’s less verbose. In Intel syntax, moving a constant into the `edi` register looks like this:

```
mov     edi,0x6
```

Note that the destination operand (`edi`) comes first. If you’re unsure about the differences between AT&T and Intel syntax, refer to Appendix A for an outline of the major characteristics of each style.

#### *Binary Format and Development Platform*

I’ve developed all of the code samples that accompany this book on Ubuntu Linux, all in C/C++ except for a small number of samples written in Python. This is because many popular binary analysis libraries are targeted mainly at Linux and have convenient C/C++ or Python APIs. However, all of the techniques and most of the libraries and tools used in this book also apply to Windows, so if Windows is your platform of choice, you should have little trouble transferring what you’ve learned to it. In terms of binary format, this book focuses mainly on ELF binaries, the default on Linux platforms, though many of the tools also support Windows PE binaries.

#### *Code Samples and Virtual Machine*

Each chapter in this book comes with several code samples, and there’s a preconfigured virtual machine (VM) that accompanies this book and includes all of the samples. The VM runs the popular Linux distribution Ubuntu 16.04 and has all of the discussed open source binary analysis tools installed. You can use the VM to experiment with the code samples and solve the exercises at the end of each chapter. The VM is available on the book’s website, which you’ll find at *<https://practicalbinaryanalysis.com>* or *<https://nostarch.com/binaryanalysis/>*.

On the book’s website, you’ll also find an archive containing just the source code for the samples and exercises. You can download this if you don’t want to download the entire VM, but do keep in mind that some of the required binary analysis frameworks require complex setup that you’ll have to do on your own if you opt not to use the VM.

To use the VM, you will need virtualization software. The VM is meant to be used with VirtualBox, which you can download for free from *<https://www.virtualbox.org/>*. VirtualBox is available for all popular operating systems, including Windows, Linux, and macOS.

After installing VirtualBox, simply run it, navigate to the **File** → **Import Appliance** option, and select the virtual machine you downloaded from the book’s website. After it’s been added, start it up by clicking the green arrow marked **Start** in the main VirtualBox window. After the VM is done booting, you can log in using “binary” as the username and password. Then, open a terminal using the keyboard shortcut CTRL-ALT-T, and you’ll be ready to follow along with the book.

In the directory *~/code*, you’ll find one subdirectory per chapter, which contains all code samples and other relevant files for that chapter. For instance, you’ll find all code for Chapter 1 in the directory *~/code/chapter1*. There’s also a directory called *~/code/inc* that contains common code used by programs in multiple chapters. I use the *.cc* extension for C++ source files, *.c* for plain C files, *.h* for header files, and *.py* for Python scripts.

To build all the example programs for a given chapter, simply open a terminal, navigate to the directory for the chapter, and then execute the `make` command to build everything in the directory. This works in all cases except those where I explicitly mention other commands to build an example.

Most of the important code samples are discussed in detail in their corresponding chapters. If a code listing discussed in the book is available as a source file on the VM, its filename is shown before the listing, as follows.

***filename.c***

```
int
main(int argc, char *argv[])
{
  return 0;
}
```

This listing caption indicates that you’ll find the code shown in the listing in the file *filename.c*. Unless otherwise noted, you’ll find the file under its listed filename in the directory for the chapter in which the example appears. You’ll also encounter listings with captions that aren’t filenames, meaning that these are just examples used in the book without a corresponding copy on the VM. Short code listings that don’t have a copy on the VM may not have captions, such as in the assembly syntax example shown earlier.

Listings that show shell commands and their output use the `$` symbol to indicate the command prompt, and they use bold font to indicate lines containing user input. These lines are commands that you can try on the virtual machine, while subsequent lines that are not prefixed with a prompt or printed in bold represent command output. For instance, here’s an overview of the *~/code* directory on the VM:

```
$ cd ~/code && ls
chapter1 chapter2   chapter3  chapter4  chapter5  chapter6  chapter7
chapter8 chapter9   chapter10 chapter11 chapter12 chapter13 inc
```

Note that I’ll sometimes edit command output to improve readability, so the output you see on the VM may differ slightly.

#### *Exercises*

At the end of each chapter, you’ll find a few exercises and challenges to consolidate the skills you learned in that chapter. Some of the exercises should be relatively straightforward to solve using the skills you learned in the chapter, while others may require more effort and some independent research.