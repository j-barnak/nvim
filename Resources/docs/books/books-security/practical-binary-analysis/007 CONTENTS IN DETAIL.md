## CONTENTS IN DETAIL

**FOREWORD by Herbert Bos**

**PREFACE**

**ACKNOWLEDGMENTS**

**INTRODUCTION**

What Is Binary Analysis, and Why Do You Need It?

What Makes Binary Analysis Challenging?

Who Should Read This Book?

What’s in This Book?

How to Use This Book

Instruction Set Architecture

Assembly Syntax

Binary Format and Development Platform

Code Samples and Virtual Machine

Exercises

**PART I: BINARY FORMATS**

**1**  
**ANATOMY OF A BINARY**

1.1 The C Compilation Process

1.1.1 The Preprocessing Phase

1.1.2 The Compilation Phase

1.1.3 The Assembly Phase

1.1.4 The Linking Phase

1.2 Symbols and Stripped Binaries

1.2.1 Viewing Symbolic Information

1.2.2 Another Binary Turns to the Dark Side: Stripping a Binary

1.3 Disassembling a Binary

1.3.1 Looking Inside an Object File

1.3.2 Examining a Complete Binary Executable

1.4 Loading and Executing a Binary

1.5 Summary

Exercises

**2**  
**THE ELF FORMAT**

2.1 The Executable Header

2.1.1 The e_ident Array

2.1.2 The e_type, e_machine, and e_version Fields

2.1.3 The e_entry Field

2.1.4 The e_phoff and e_shoff Fields

2.1.5 The e_flags Field

2.1.6 The e_ehsize Field

2.1.7 The e\_\*entsize and e\_\*num Fields

2.1.8 The e_shstrndx Field

2.2 Section Headers

2.2.1 The sh_name Field

2.2.2 The sh_type Field

2.2.3 The sh_flags Field

2.2.4 The sh_addr, sh_offset, and sh_size Fields

2.2.5 The sh_link Field

2.2.6 The sh_info Field

2.2.7 The sh_addralign Field

2.2.8 The sh_entsize Field

2.3 Sections

2.3.1 The .init and .fini Sections

2.3.2 The .text Section

2.3.3 The .bss, .data, and .rodata Sections

2.3.4 Lazy Binding and the .plt, .got, and .got.plt Sections

2.3.5 The .rel.\* and .rela.\* Sections

2.3.6 The .dynamic Section

2.3.7 The .init_array and .fini_array Sections

2.3.8 The .shstrtab, .symtab, .strtab, .dynsym, and .dynstr Sections

2.4 Program Headers

2.4.1 The p_type Field

2.4.2 The p_flags Field

2.4.3 The p_offset, p_vaddr, p_paddr, p_filesz, and p_memsz Fields

2.4.4 The p_align Field

2.5 Summary

Exercises

**3**  
**THE PE FORMAT: A BRIEF INTRODUCTION**

3.1 The MS-DOS Header and MS-DOS Stub

3.2 The PE Signature, File Header, and Optional Header

3.2.1 The PE Signature

3.2.2 The PE File Header

3.2.3 The PE Optional Header

3.3 The Section Header Table

3.4 Sections

3.4.1 The .edata and .idata Sections

3.4.2 Padding in PE Code Sections

3.5 Summary

Exercises

**4**  
**BUILDING A BINARY LOADER USING LIBBFD**

4.1 What Is libbfd?

4.2 A Simple Binary-Loading Interface

4.2.1 The Binary Class

4.2.2 The Section Class

4.2.3 The Symbol Class

4.3 Implementing the Binary Loader

4.3.1 Initializing libbfd and Opening a Binary

4.3.2 Parsing Basic Binary Properties

4.3.3 Loading Symbols

4.3.4 Loading Sections

4.4 Testing the Binary Loader

4.5 Summary

Exercises

**PART II: BINARY ANALYSIS FUNDAMENTALS**

**5**  
**BASIC BINARY ANALYSIS IN LINUX**

5.1 Resolving Identity Crises Using file

5.2 Using ldd to Explore Dependencies

5.3 Viewing File Contents with xxd

5.4 Parsing the Extracted ELF with readelf

5.5 Parsing Symbols with nm

5.6 Looking for Hints with strings

5.7 Tracing System Calls and Library Calls with strace and ltrace

5.8 Examining Instruction-Level Behavior Using objdump

5.9 Dumping a Dynamic String Buffer Using gdb

5.10 Summary

Exercise

**6**  
**DISASSEMBLY AND BINARY ANALYSIS FUNDAMENTALS**

6.1 Static Disassembly

6.1.1 Linear Disassembly

6.1.2 Recursive Disassembly

6.2 Dynamic Disassembly

6.2.1 Example: Tracing a Binary Execution with gdb

6.2.2 Code Coverage Strategies

6.3 Structuring Disassembled Code and Data

6.3.1 Structuring Code

6.3.2 Structuring Data

6.3.3 Decompilation

6.3.4 Intermediate Representations

6.4 Fundamental Analysis Methods

6.4.1 Binary Analysis Properties

6.4.2 Control-Flow Analysis

6.4.3 Data-Flow Analysis

6.5 Effects of Compiler Settings on Disassembly

6.6 Summary

Exercises

**7**  
**SIMPLE CODE INJECTION TECHNIQUES FOR ELF**

7.1 Bare-Metal Binary Modification Using Hex Editing

7.1.1 Observing an Off-by-One Bug in Action

7.1.2 Fixing the Off-by-One Bug

7.2 Modifying Shared Library Behavior Using LD_PRELOAD

7.2.1 A Heap Overflow Vulnerability

7.2.2 Detecting the Heap Overflow

7.3 Injecting a Code Section

7.3.1 Injecting an ELF Section: A High-Level Overview

7.3.2 Using elfinject to Inject an ELF Section

7.4 Calling Injected Code

7.4.1 Entry Point Modification

7.4.2 Hijacking Constructors and Destructors

7.4.3 Hijacking GOT Entries

7.4.4 Hijacking PLT Entries

7.4.5 Redirecting Direct and Indirect Calls

7.5 Summary

Exercises

**PART III: ADVANCED BINARY ANALYSIS**

**8**  
**CUSTOMIZING DISASSEMBLY**

8.1 Why Write a Custom Disassembly Pass?

8.1.1 A Case for Custom Disassembly: Obfuscated Code

8.1.2 Other Reasons to Write a Custom Disassembler

8.2 Introduction to Capstone

8.2.1 Installing Capstone

8.2.2 Linear Disassembly with Capstone

8.2.3 Exploring the Capstone C API

8.2.4 Recursive Disassembly with Capstone

8.3 Implementing a ROP Gadget Scanner

8.3.1 Introduction to Return-Oriented Programming

8.3.2 Finding ROP Gadgets

8.4 Summary

Exercises

**9**  
**BINARY INSTRUMENTATION**

9.1 What Is Binary Instrumentation?

9.1.1 Binary Instrumentation APIs

9.1.2 Static vs. Dynamic Binary Instrumentation

9.2 Static Binary Instrumentation

9.2.1 The int 3 Approach

9.2.2 The Trampoline Approach

9.3 Dynamic Binary Instrumentation

9.3.1 Architecture of a DBI System

9.3.2 Introduction to Pin

9.4 Profiling with Pin

9.4.1 The Profiler’s Data Structures and Setup Code

9.4.2 Parsing Function Symbols

9.4.3 Instrumenting Basic Blocks

9.4.4 Instrumenting Control Flow Instructions

9.4.5 Counting Instructions, Control Transfers, and Syscalls

9.4.6 Testing the Profiler

9.5 Automatic Binary Unpacking with Pin

9.5.1 Introduction to Executable Packers

9.5.2 The Unpacker’s Data Structures and Setup Code

9.5.3 Instrumenting Memory Writes

9.5.4 Instrumenting Control-Flow Instructions

9.5.5 Tracking Memory Writes

9.5.6 Detecting the Original Entry Point and Dumping the Unpacked Binary

9.5.7 Testing the Unpacker

9.6 Summary

Exercises

**10**  
**PRINCIPLES OF DYNAMIC TAINT ANALYSIS**

10.1 What Is DTA?

10.2 DTA in Three Steps: Taint Sources, Taint Sinks, and Taint Propagation

10.2.1 Defining Taint Sources

10.2.2 Defining Taint Sinks

10.2.3 Tracking Taint Propagation

10.3 Using DTA to Detect the Heartbleed Bug

10.3.1 A Brief Overview of the Heartbleed Vulnerability

10.3.2 Detecting Heartbleed Through Tainting

10.4 DTA Design Factors: Taint Granularity, Taint Colors, and Taint Policies

10.4.1 Taint Granularity

10.4.2 Taint Colors

10.4.3 Taint Propagation Policies

10.4.4 Overtainting and Undertainting

10.4.5 Control Dependencies

10.4.6 Shadow Memory

10.5 Summary

Exercise

**11**  
**PRACTICAL DYNAMIC TAINT ANALYSIS WITH LIBDFT**

11.1 Introducing libdft

11.1.1 Internals of libdft

11.1.2 Taint Policy

11.2 Using DTA to Detect Remote Control-Hijacking

11.2.1 Checking Taint Information

11.2.2 Taint Sources: Tainting Received Bytes

11.2.3 Taint Sinks: Checking execve Arguments

11.2.4 Detecting a Control-Flow Hijacking Attempt

11.3 Circumventing DTA with Implicit Flows

11.4 A DTA-Based Data Exfiltration Detector

11.4.1 Taint Sources: Tracking Taint for Open Files

11.4.2 Taint Sinks: Monitoring Network Sends for Data Exfiltration

11.4.3 Detecting a Data Exfiltration Attempt

11.5 Summary

Exercise

**12**  
**PRINCIPLES OF SYMBOLIC EXECUTION**

12.1 An Overview of Symbolic Execution

12.1.1 Symbolic vs. Concrete Execution

12.1.2 Variants and Limitations of Symbolic Execution

12.1.3 Increasing the Scalability of Symbolic Execution

12.2 Constraint Solving with Z3

12.2.1 Proving Reachability of an Instruction

12.2.2 Proving Unreachability of an Instruction

12.2.3 Proving Validity of a Formula

12.2.4 Simplifying Expressions

12.2.5 Modeling Constraints for Machine Code with Bitvectors

12.2.6 Solving an Opaque Predicate Over Bitvectors

12.3 Summary

Exercises

**13**  
**PRACTICAL SYMBOLIC EXECUTION WITH TRITON**

13.1 Introduction to Triton

13.2 Maintaining Symbolic State with Abstract Syntax Trees

13.3 Backward Slicing with Triton

13.3.1 Triton Header Files and Configuring Triton

13.3.2 The Symbolic Configuration File

13.3.3 Emulating Instructions

13.3.4 Setting Triton’s Architecture

13.3.5 Computing the Backward Slice

13.4 Using Triton to Increase Code Coverage

13.4.1 Creating Symbolic Variables

13.4.2 Finding a Model for a New Path

13.4.3 Testing the Code Coverage Tool

13.5 Automatically Exploiting a Vulnerability

13.5.1 The Vulnerable Program

13.5.2 Finding the Address of the Vulnerable Call Site

13.5.3 Building the Exploit Generator

13.5.4 Getting a Root Shell

13.6 Summary

Exercise

**PART IV: APPENDIXES**

**A**  
**A CRASH COURSE ON X86 ASSEMBLY**

A.1 Layout of an Assembly Program

A.1.1 Assembly Instructions, Directives, Labels, and Comments

A.1.2 Separation Between Code and Data

A.1.3 AT&T vs. Intel Syntax

A.2 Structure of an x86 Instruction

A.2.1 Assembly-Level Representation of x86 Instructions

A.2.2 Machine-Level Structure of x86 Instructions

A.2.3 Register Operands

A.2.4 Memory Operands

A.2.5 Immediates

A.3 Common x86 Instructions

A.3.1 Comparing Operands and Setting Status Flags

A.3.2 Implementing System Calls

A.3.3 Implementing Conditional Jumps

A.3.4 Loading Memory Addresses

A.4 Common Code Constructs in Assembly

A.4.1 The Stack

A.4.2 Function Calls and Function Frames

A.4.3 Conditional Branches

A.4.4 Loops

**B**  
**IMPLEMENTING PT_NOTE OVERWRITING USING LIBELF**

B.1 Required Headers

B.2 Data Structures Used in elfinject

B.3 Initializing libelf

B.4 Getting the Executable Header

B.5 Finding the PT_NOTE Segment

B.6 Injecting the Code Bytes

B.7 Aligning the Load Address for the Injected Section

B.8 Overwriting the .note.ABI-tag Section Header

B.9 Setting the Name of the Injected Section

B.10 Overwriting the PT_NOTE Program Header

B.11 Modifying the Entry Point

**C**  
**LIST OF BINARY ANALYSIS TOOLS**

C.1 Disassemblers

C.2 Debuggers

C.3 Disassembly Frameworks

C.4 Binary Analysis Frameworks

**D**  
**FURTHER READING**

D.1 Standards and References

D.2 Papers and Articles

D.3 Books

**INDEX**