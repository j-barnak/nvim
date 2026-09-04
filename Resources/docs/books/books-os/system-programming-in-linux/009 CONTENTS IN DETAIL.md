CONTENTS IN DETAIL

ACKNOWLEDGMENTS

PREFACE

INTRODUCTION

What Will You Learn from This Book?

How Will This Book Teach You?

Using Open Source Software

Presenting Different Perspectives

Using Example Programs

What Should You Know to Understand This Book?

The Role of C in This Book

Utility Programs

System Requirements

About UNIX, Unix, Linux, and More

Scope, Content, and Organization

Chapter Organization

Online Materials

Conventions and Format

Typographical Conventions

Notation

Example Program Naming Conventions

Dates and Identities

Suggestions and Corrections

1CORE CONCEPTS

What Is System Programming?

The Magic of Input and Output

The Role of the C Library in I/O

System Resources

System Programs Explained

Fundamental Concepts of Unix

The Unix Kernel

Shells and Commands

Users and Groups

Privileged and Nonprivileged Instructions

Environments

Files, Directories, and the Single Directory Hierarchy

Processes

Threads

Online Documentation

Using the Manual Pages

The Pager

The Structure of Man Pages

Searching Through the Man Pages

Unix History and Standards

The Birth of UNIX

Early Branches

The Free Software Foundation and GNU

The Rise of Linux

Many Unixes

Unix and Related Standards

C Standards

Summary

Exercises

2FUNDAMENTALS OF SYSTEM PROGRAMMING

Object Libraries

System Libraries

Static and Shared Libraries

The Advantages of Shared Libraries

Commands to Query a Library’s Contents

Commands to Show the Libraries Linked to a Program

The C Standard Library

System Calls

Wrapper Functions

System Call Execution

Multiple Paths to Kernel Services

Handling Errors from System Calls and Library Functions

System Call Errors

Errors from Library Functions

PortabilityFeature Test Macros

Other Portability Issues

System Limits

Internationalization

Processing the Command Line and Environment

Extracting Command Line Arguments

Accessing the Environment

Reporting Usage Errors

Extracting the Program Name

Extracting Command Line Options

Extracting Numbers from Strings

Summary

Exercises

3TIME, DATES, AND LOCALES

Learning System Programming

Organization of Common Code

Functions for Extracting Numbers

Common Error-Handling Functions

File Organization

Planning Our First System Program

Designing the First Version of spl_date

About Calendar Time in Unix

Broken-Down Time

Calendar Time System Calls

Time Conversion Functions

Designing a Second Version of spl_date

Designing a Third Version of spl_date

The User Interface

Program Logic

Working with Locales

Locale Categories

About Time Zones

The Command-Level Interface to Locales

The Structure of Locales

The Programming Interface to Locales

An Internationalized Version of the spl_date Program

Other Ways to Internationalize Programs

Locale Objects

Summary

Exercises

4BASIC CONCEPTS OF FILE I/O

High-Level vs. Low-Level File I/O

Universal I/O

File Permissions Revisited

Applying the Umask

Setting and Getting Umasks

Propagating Umasks

A Process’s User IDs

The setuid Bit

Input/Output Mechanics

Standard File Descriptors

The Kernel I/O Interface

Opening Files

Closing Files

Reading from Files

Writing to Files

Writing a copy Command

Design of the copy Program

Implementation of the copy Program

Testing of the copy Program

The Universality of the copy Program

Timing Programs

Buffering and Running Time

Summary

Exercises

5FILE I/O AND LOGIN ACCOUNTING

Controlling the Position of I/O Operations

The lseek() System Call

File Holes

Displaying Last Login Information

The lastlog Command

The lastlog File

The lastlog Structure

Usernames, User IDs, and the passwd File

The Password Database

Accessing All User Entries

Developing a lastlog Program

Design Considerations

Program Logic

Writing the Program

Developing a last Command

Login Records

The utmp Structure

The utmpx API

Logins, Logouts, and the utmp and wtmp Files

A Program to Show the utmp and wtmp Files

Analysis of the wtmp File

Designing the spl_last Program

User Space Buffering of Input

Summary

Exercises

6OVERVIEW OF FILESYSTEMS AND FILES

Disks and Disk Partitions

Disk Geometry

Disk Device Drivers

Disk Partitioning

Many, Many Filesystems

Filesystems Supported by Linux

The Ext Filesystems

Filesystem Structure

Partition Layout

Block Group Layout

Performance Considerations

The Kernel’s Filesystem Interface

Creating a New File

Writing Data to a File

The Virtual Filesystem

Exploring the Filesystem API

The stat Command

The stat() System Call

The stat Structure

The File Mode

The setgid Bit

The sticky Bit

An Example lstat Program

The statx() System Call

The statx Data Structure

Calling statx()

Writing an spl_stat Command

Designing the main() Function

Designing the print_statx() Function

Writing the Auxiliary Functions

Designing an Enhanced spl_stat Command

Writing an spl_statfs Command

The statfs() System Call

The statvfs() Library Function

A Hybrid Solution

Testing spl_statfs

Summary

Exercises

7THE DIRECTORY HIERARCHY

Directory Structure

Processing Directories

The readdir() Library Function

The dirent Structure

Directory Streams

The opendir() Library Function

The closedir() Library Function

A Simple ls Program

Other Functions in the Directory API

The telldir() and seekdir() Library Functions

The scandir() Library Function

Processing the Directory Hierarchy

Mounting File Systems

An Example of Filesystem Mounting

Commands for Finding Mount Points

Duplicate Inode Numbers

Tree Walks

A Recursive Tree Walk Using readdir()

A Recursive Tree Walk Using scandir()

The nftw() Tree Walk Function

Writing a du Command

The fts Tree Traversal Functions

The pwd Command

An Exercise in Constructing a Directory Tree

A Strategy for Implementing the pwd Command

Summary

Exercises

8INTRODUCTION TO SIGNALS

The Role of Signals

A Signal Delivery Example

Sources of Signals

Signal Concepts

The Lifetime of a Signal

Signal Types

Basic Signal Handling

The signal() System Call

The System V signal() Semantics

Sending Signals

Blocking Signals

Signal Sets

The sigprocmask() Function

The sigaction() System Call

The sigaction Structure

Signal Information Passed to the Handler

Effect of sa_flags on Signal Handler Execution

Guidance on Designing Signal Handlers

Summary

Exercises

9TIMERS AND SLEEP FUNCTIONS

Keeping Track of Time

Alarm Clocks and Timers

Sleep Functions and Timers

Time, Clocks, and Timing

Overview

Hardware Clocks and Hardware Timers

The System Clock

High-Resolution Sleep Functions

The nanosleep() System Call

The clock_nanosleep() System Call

Software Timers

The alarm() System Call

A Progress Bar Based on Alarms

Interval Timers

Overview

POSIX Timers

A POSIX Timer-Based Progress Bar

Resource Monitors

Real-Time Signals and Multiple Timers

Summary

Exercises

10

PROCESS FUNDAMENTALS

Processes Revisited

The Process Tree

Process Groups

Sessions

Foreground and Background Processes and Process Groups

Program Files

The Contents of an Executable File

The Executable and Linking Format

The Virtual Memory Layout of a Process

The Text Segment

The Initialized Data Segment

The Uninitialized Data Segment

The Heap

The Stack Segment

A Program That Displays Virtual Memory Locations

The Kernel’s Process Representation

Process Metadata

Overview of the Process Descriptor

The proc Pseudofilesystem

Numbered Directories

The Magic of /proc

Useful Per-Process Files

An ancestors Command

A Simple ps Command

Summary

Exercises

11

PROCESS CREATION AND TERMINATION

The Lifetime of a Process

Creating Processes

The Basics of fork()

The Child’s Memory Image

The Child’s Process Descriptor

Sharing of Open Files

Potential Race Conditions

Process Synchronization with Signals

Other Functions That Create Processes

Terminating Processes

Executing Programs

The execve() System Call

The exec() Library Functions

Waiting for Children

The wait() and waitpid() System Calls

The waitid() System Call

The SIGCHLD Signal and Asynchronous Waiting

Putting It All Together: A Simple Shell

The system() Library Function

Summary

Exercises

12

INTRODUCTION TO INTERPROCESS COMMUNICATION

Why Do We Need IPC?

An Overview of Interprocess Communication

Shared Memory Methods

Data Transfer Methods

Two Different APIs

Summary of the Common IPC Facilities

POSIX Shared Memory

Overview

The Shared Memory API

A Shared Memory Example Program

Pointer Pitfalls in Shared Memory

Race Conditions

Semaphores

Overview

System V Semaphores

POSIX Semaphores

A Shared Memory Producer Consumer Program

POSIX Message Queues

A Simple Message Queue Example

Message Queues and Asynchronous Notification

A Program Receiving Asynchronous Notifications

Summary

Exercises

13

PIPES AND FIFOS

An Overview of Pipes

Pipe Basics

Unnamed Pipes

The Behavior of Read Operations on Pipes

The Behavior of Write Operations on Pipes

A Producer-Consumer Example

A Shell Pipe Simulation

Best Practices Regarding Pipes

The popen() and pclose() Library Functions

FIFOs

Creating Named Pipes in the Shell

Creating FIFOs

Opening FIFOs

Putting It All Together: A Simple FIFO-Based Server-Like

Program

Summary

Exercises

14

CLIENT-SERVER APPLICATIONS AND DAEMONS

Introduction to Client-Server Applications

System Logging Facilities

Daemons

Overview

Converting Processes into Daemons

An Iterative Server

Overview of the Application

The spl_calc Common Header File

The spl_calc Client Program

The spl_calc Server Program

A Concurrent Server

The Concurrent Server Client

The Concurrent Server

Summary

Exercises

15

INTRODUCTION TO THREADS

Background

Threads and Processes

Support in the Kernel

Pros and Cons of Multithreading

Shared Resources and Attributes

Program Design Considerations with Threads

Overview of the Pthreads Library

Thread Management

Creating a Thread

Exiting a Thread

Joining a Thread

Passing Data to Threads

Identifying Threads

Detaching Threads

Canceling a Thread

Setting Thread Stack Size

Signals and Threads

Thread-Directed Signals

Process-Directed Signals

Signal Masks and Dispositions

A Multithreaded Concurrent Server

Summary

Exercises

16

THREAD SYNCHRONIZATION

Correctness and Performance Considerations

Mutexes

Declaring and Initializing a Mutex

Locking and Unlocking a Mutex

Destroying a Mutex

A Program Using a Normal Mutex

Other Types of Mutexes

Condition Variables

Why Do We Need Condition Variables?

The Typical Steps for Using Condition Variables

Declaring and Initializing a Condition Variable

Waiting on a Condition Variable

Signaling a Condition Variable

Destroying a Condition Variable

Condition Attributes

A Multithreaded Multiple Producer, Multiple Consumer

Program

Barrier Synchronization

Pthreads Barriers

A Program Using Barrier Synchronization

Read-Write Locks

Read-Write Lock API Overview

Use and Semantics of Read-Write Locks

Further Details About Pthreads Read-Write Locks

Read-Write Lock Example

Summary

Exercises

17

ALTERNATIVE METHODS OF I/O

Nonblocking I/O

Enabling Nonblocking I/O

A Program to Demonstrate Nonblocking Input

Signal-Driven I/O

Overview

Procedure for Enabling Signal-Driven I/O

Events Causing Signal Generation

Real-Time Signals and Signal-Driven I/O

A Program Using Signal-Driven I/O

POSIX Asynchronous I/O

Overview

The AIO API

Performance Benefits of Asynchronous I/O with Disk Files

An AIO-Based Implementation of spl_cp1.c

Multiplexed I/O

Overview

The select() System Call

An Example Program

Summary

Exercises

18

TERMINALS AND TERMINAL I/O

About Interactive Programs

An Overview of Terminals

An Experiment

An Explanation

Terminal Drivers

Terminal Driver Structure

The Terminal Driver as Seen from the Shell

Categories of Terminal Attributes

The Terminal Driver API

Terminal Switches

Terminal Special Characters

Terminal Attribute Modification

Writing an spl_stty Command

Program Data Structures

The main() Function of spl_stty

Functions That Display Attributes

Functions That Set Attributes

The ioctl() System Call

The Form of an ioctl() Call

Summary

Exercises

19

INTERACTIVE PROGRAMMING AND THE NCURSES

LIBRARY

Canonical and Noncanonical Modes

Canonical Mode

Overview of Noncanonical Modes

The MIN and TIME Parameters

An Interactive Program in Noncanonical Mode

Program Features and Issues

Terminal Control Functions

Global Constants, Types, and Variables

Support Functions

The sprite.c main() Function

Curses and the ncurses Library

History, Standards, and Names

Terminology

Compiling, Building, and Running Curses Programs

Curses Basics

The Curses API

A Program with Tiled Windows

A Curses Version of sprite.c

The top Program

Requirements of a Simplified top Command

Design Considerations

Input Mode and the Cursor

Screen Management

Data Structures

Sorting Functions

Acquiring and Storing the Data

Acquiring Summary Data

Acquiring Per-Process Data

The main() Function

Concluding Thoughts

Summary

Exercises

A

CREATING LIBRARIES

About Libraries

Static vs. Shared Libraries in Unix

Identifying Libraries

Creating a Static Library

Using (Linking to) a Static Library

Creating a Shared Library

Shared Library Names

Steps to Create the Library

Using a Shared Library

B

UNICODE AND UTF-8

Background

Terminology

Unicode

UTF-8

Conversion Example 1

Conversion Example 2

C

DATE AND TIME FORMAT SPECIFIERS

BIBLIOGRAPHY

INDEX