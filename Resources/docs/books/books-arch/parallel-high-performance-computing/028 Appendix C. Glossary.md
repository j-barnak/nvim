# Appendix C. Glossary

***Appendix C. Glossary***

3DNow! An AMD vector instruction set that first supported single-precision operations.

Affinity Assigning a preference for the placement of a process, rank, or thread to a particular hardware component. This is also called pinning or binding.

Algorithmic complexity A measure of the number of operations that it would take to complete an algorithm. Algorithmic complexity is a property of the algorithm and is a measure of the amount of work or operations in a procedure.

Aliasing Where pointers point to overlapping regions of memory. In this situation, the compiler cannot tell if it is the same memory, and in these instances, it would be unsafe to generate vectorized code or other optimizations.

Anti-flow dependency A variable within the loop is written after being read, known as a write-after-read (WAR).

Arithmetic intensity The number of floating-point operations (flops) relative to the memory loads (data) that your application or kernel (loop) performs. The arithmetic intensity is an important measure to understand the limiting characteristics of an application.

Asymptotic notation An expression that specifies the limiting bound on performance. Basically, does the run time grow linearly or worse with the size of a problem? The notation uses various forms of O, such as O(n), O(n log₂n) or O(n²). The O can be thought of as “order” as in “scales on an order of.”

Asynchronous This call is non-blocking and only initiates an operation.

Auto-vectorization The vectorization of the source code by the compiler for standard C, C++, or Fortran language source code.

AVX Advanced Vector Extensions (AVX) is a 256-bit vector hardware unit and instruction set.

AVX2 An improvement to AVX hardware to support fused multiply adds (FMA).

AVX512 Extends the AVX hardware to 512-bit vector widths.

Bandwidth The best rate at which data can be moved through a given path in the system. This can refer to memory, disk, or network throughput.

Binary data format The machine representation of the data that is used by the processor and stored in main memory. Usually this term refers to the data format staying in binary form when it is written out to the hard disk.

Blocking An operation that does not complete until a specific condition is fulfilled.

Branch miss The cost encountered when the predicted branch in an `if` statement is incorrect.

Bucket A storage location holding a collection of values. Hashing techniques are used to store the values for keys in a bucket because there might be multiple values for that location.

Cache A faster block of memory that is used to reduce the cost of accessing the slower main memory by storing blocks of data or instructions that might be needed.

Cache eviction The removal of blocks of data, called cache lines, from one of the various levels of the cache hierarchy.

Cache line The block of data loaded into cache when memory is accessed.

Cache misses Occur when the processor tries to access a memory address and it is not in the cache. The system then has to retrieve the data from main memory at a cost of 100s of cycles of time.

Cache thrashing A condition where one memory load evicts another and then the original data is needed again, causing loading, eviction, and reloading of data.

Cache update storms On a multiprocessor system, when one processor modifies data that is in another processor's cache, the data has to be reloaded on those other processors.

Call stack The list of called subroutines that has to be unwound by a return at the end of the subroutine where it jumps back to the previous calling routine.

Capacity misses The misses that are caused by the limited size of the cache.

Catastrophic cancellation The subtraction of two almost equal numbers, causing the result to have only a few significant digits.

Centralized version control system A version control system implemented as a single centralized system.

Checkpoint/Restart The periodic writing out of the state of an application followed by the starting up of the application in a later job.

Checkpointing The practice of periodically storing the state of a calculation to disk so that the calculation can be restarted due to system failures or finite length run times in a batch system. See checkpoint/restart.

Clock cycle The small intervals of time between operations in the computer based on the clock frequency of the system.

Cluster A small group of distributed memory nodes connected by a commodity network.

Coalesced memory loads The combination of separate memory loads from groups of threads into a single cache-line load.

Coarse-grained parallelism A type of parallelism where the processor operates on large blocks of code with infrequent synchronization.

Code coverage A metric of how many lines of the source code are executed and, therefore, “covered” by running a test suite. It is usually expressed as a percentage of the source lines of code.

Coherency misses Cache updates needed to synchronize the caches between multiprocessors when data is written to one processor’s cache that is also held in another processor’s cache.

Cold cache A cache that does not have any of the data to be operated on in cache from a previous operation when the current operation begins.

Collisions (hash) When more than one key wants to store its value in the same bucket.

Commit tests A test suite that is run prior to committing any code to the repository.

Compact hash A hash that is compressed into a smaller memory size. A compact hash must have a way to handle collisions.

Comparative speedups Short for comparative performance speedups between architectures. This is the relative performance between two hardware architectures, often based on a single node or a fixed power envelope.

Compressed sparse data structures A space-efficient way to represent a data space that is sparse. The most notable example is the Compressed Sparse Row (CSR) format used for sparse matrices.

Compulsory misses Cache misses are those that are necessary to bring in the data when it is first encountered.

Computational complexity The number of steps needed to complete an algorithm. This complexity measure is an attribute of the implementation and the type of hardware that is being used for the calculation.

Computational kernel A section of the application that is both computationally intensive and conceptually self-contained.

Computational mesh A collection of cells or elements that covers the simulation region.

Compute device (OpenCL) Any computational hardware that can perform computation and supports OpenCL is a compute device. This can include GPUs, CPUs, or even more exotic hardware such as embedded processors or FPGAs.

Concurrency The operation of parts of a program in any order with the same result. Concurrency was originally developed to support concurrent computing or timesharing by interleaving computing on a limited set of resources.

Conflict misses (cache) Misses caused by the loading of another block of memory into a cache line that is still needed by the CPU.

Contiguous memory Memory that is composed of an uninterrupted sequence of bytes.

Continuous integration An automatic testing process that is invoked with every commit to the repository.

Core Core or computational core is the basic element of the system that does the mathematical and logical operations.

CPU The discrete processing device (the central processing unit) composed of one or more computational cores that is placed on the socket of a circuit board to provide the main computational operations.

Data parallel A type of parallelism where the data is partitioned among the processors or threads and operated on in parallel.

Dedicated GPU A GPU on a separate peripheral card. Also known as a discrete GPU.

Dereferencing An operation where the memory address is obtained from the pointer reference so that the cache line is for the memory data instead of for the pointer.

Descriptive directives and clauses These directives give the compiler information about the following loop construct and give the compiler some freedom to generate the most efficient implementation.

Direct-mapped cache A cache for which a memory address has only one location in the cache where it can be loaded. This can lead to conflicts and evictions if another block of memory also maps to this location. See N-way set associative cache for a type of cache that avoids this problem.

Directive An instruction to a Fortran compiler to help it interpret the source code. The form of the instruction is a comment line starting with `!$`.

Discretization The process of breaking up a computational domain into smaller cells or elements, forming a computational mesh. Calculations are then performed on each cell or element.

Distributed array An array that is partitioned and split across the processors. For example, an array containing 100 values might be divided up across four processors with 25 values on each processor.

Distributed computing Applications and loosely coupled workflows that span multiple computers and use communication across the network to coordinate the work. Examples of distributed computing applications include searches via browsers on the internet and multiple clients interacting with a database on a server.

Distributed memory More than one block of memory, each existing in its own address space and control.

Distributed version control system A version control system that allows multiple repository databases rather than a single centralized system.

Domain-boundary halos Halo cells used for imposing a specific set of boundary conditions

Dope vector The metadata for an array in Fortran composed of the start, stride, and length for each dimension. The meaning is from the slang “give me the dope on” or information on someone or something.

DRAM Dynamic Random Access Memory. This memory needs to have its state refreshed frequently and the data it stores is lost when the power is turned off.

Dynamic range The range of the working set of real numbers in a problem.

Eviction See cache eviction.

Fine-grained parallelism A type of parallelism where computational loops or other small blocks of code are operated on by multiple processors or threads and may need frequent synchronization.

First touch The first touch of an array causes the memory to be allocated. It is allocated near to the thread location where the touch occurs. Prior to the first touch, the memory only exists as an entry in virtual memory. The physical memory that corresponds to the virtual memory is created when it is first accessed.

Flow dependency A variable within the loop is read after being written, known as a read-after-write (RAW).

FLOPs Floating-point operations such as addition, subtraction, and multiplication on single- or double-precision data types.

Flynn’s Taxonomy A categorization of computer architectures based on whether the data and instructions are either single or multiple.

Gather memory operation Memory loaded into a cache line or vector unit from non-contiguous memory locations.

Generation (PCIe) The PCI Special Interest Group (PCI SIG) is a group representing industry partners that establishes a PCI Express Specification, commonly referred to as generation or gen for short.

Ghost cells A set of cells that contain adjacent processor(s) data for use on the local processor so that the processor can operate in large blocks without issuing communication calls.

Global sum issue The difference in a global sum in a parallel calculation compared to a serial or run on a different number of processors.

GNU Compiler Collection (GCC) An open-source, publically available compiler suite, including C, C++, Fortran, and many other languages.

GNU's Not Unix (GNU) A free, Unix-like operating system.

Graphical user interface (GUI) An interface composed of visual elements and interactive components that can be manipulated with a mouse or other advanced input devices.

Graphics processing unit (GPU) or general-purpose graphics processing unit (GPGPU), integrated or discrete (external)A device whose primary purpose is drawing graphics to the computer monitor. It is composed of many streaming multiprocessors and its own RAM memory, capable of executing tens of thousands of threads in one clock cycle.

HAL A small rogue computer that precedes IBM in lexicographic order. HAL is a fictional computer in Arthur C. Clarke's 2001: A Space Odyssey. HAL goes rogue because it interprets its instructions differently than intended, with deadly consequences. HAL is just one letter off from IBM. HAL’s lesson is to be careful with your programming; you never know what the results might be.

Halo cells Any set of cells surrounding a computational mesh domain.

Hang When one or more processors is waiting on an event that can never occur.

Hash or hashing A computer data structure that maps a key to a value.

Hash load factor The number of filled buckets divided by the total number of buckets in the hash.

Hash sparsity The amount of empty space in a hash.

Heap A region of memory for the program that is used to provide dynamic memory for the program. The `malloc` routines and the `new` operator get memory from this region. The second region of memory is stack memory.

High Performance Computing (HPC) Computing that focuses on extreme performance. The computing hardware is generally more tightly coupled. The term High Performance Computing has mostly replaced the older nomenclature of supercomputing.

Hyperthreading An Intel technology that makes a single processor appear to be two virtual processors to the operating system through sharing of hardware resources between two threads.

Inline (routines) Rather than make a function call, compilers insert the code at the call point to avoid call overhead. This only works for smaller routines and for simpler code.

Interconnects The connections between compute nodes, also called a network. Generally the term refers to higher performance networks that tightly couple the operations on a parallel computing system. Many of these interconnects are vendor proprietary and include specialized topologies such as fat-tree, switches, torus, and dragonfly designs.

Inter-process communication (IPC) Communication between processes on a computer node. The various techniques to communicate between processes form the backbone of client/server mechanisms in distributed computing.

Instruction cache The storage of instructions in fast memory close to the processor. Instructions can be for memory movement, or integer or floating-point operations. The data that is operated on has its own separate data cache.

Integrated GPU A graphics processor engine that is contained on the CPU.

Lambda expressions An unnamed, local function that can be assigned to a variable and used locally or passed to a routine.

Lanes (vector lanes) Pathways for data in a vector operation. For a 256-bit vector unit operating on double-precision values, there are four lanes allowing four simultaneous operations with one instruction in one clock cycle.

Latency The time required for the first byte or word of data to be transferred (see also memory latency).

Load factor (hash) The fraction of a hash that is filled with entries.

Machine balance The ratio of flops to memory loads that a computer system can perform.

Main memory Also called DRAM or RAM, it is the large block of memory for the compute node.

Memory latency The time it takes to retrieve the first byte of memory from a level of the memory hierarchy.

Memory leaks Allocating memory and never freeing it. Malloc replacement tools are good at catching and reporting memory leaks.

Memory overwrites Writing to memory that is not owned by a variable in the program.

Memory paging In multi-user, multi-application operating systems, the process of moving memory pages temporarily out to disk so that another process can take place.

Memory pressure The effect of the computational kernel resource needs on performance of GPU kernels. Register pressure is a similar term, referring to demands on registers in the kernel.

Method invocation In object-oriented programming, the call to a piece of code within the object that operates on data in the object. These small pieces of code are called methods and the call to these is termed an invocation.

MIMD Multiple instruction, multiple data is a component of Flynn’s Taxonomy represented by a multi-core system.

Minimal perfect hash A hash with one and only one entry in each bucket.

MISD Multiple instruction, single data is a component of Flynn’s Taxonomy describing a redundant computer for high reliability or a parallel pipeline parallelism.

MMX Earliest x86 vector instruction set released by Intel.

Motherboard The main system board of a computer.

Multi-core A CPU that contains more than one computational core.

Network The connections between compute nodes over which data flows.

Node A basic building block of a compute cluster with its own memory and a network to communicate with other compute nodes and to run a single image of an operating system.

Non-Uniform Memory Access (NUMA) On some computing nodes, blocks of memory are closer to some processors than others. This situation is called Non-Uniform Memory Access (NUMA). Often this is the case when a node has two CPU sockets with each socket having its own memory. The access to the other block of memory typically takes twice the time as its own memory.

N-way set associative cache A cache that allows N locations for a memory address to be mapped into the cache. This reduces the conflicts and evictions associated with direct-mapped cache.

Object-based filesystem A system that is organized based on objects rather than based on files in a folder. An object-based filesystem requires a database or metadata to store all the information describing the object.

Operations (OPs) Operations can be integer, floating-point, or logic.

Out-of-bounds (memory access) Attempting to access memory beyond the array bounds. Fence-post checkers and some compilers can catch these errors.

Output dependency A variable is written to more than once in the loop.

Pageable memory Standard memory allocations that can be paged out to disk. See pinned memory for an alternative type that cannot be paged out.

Parallel algorithm A well-defined, step-by-step computational procedure that emphasizes concurrency to solve a problem.

Parallel computing Computing that operates on more than one thing at a time.

Parallel pattern A common, independent, concurrent component of code that occurs in diverse scenarios with some frequency. By themselves, these components generally do not solve complete problems of interest.

Parallel speedup Performance of a parallel implementation relative to a baseline serial run.

Parallelism The operation of parts of a program across a set of resources at the same time.

Pattern rule A specification to the make utility that gives a general rule on how to convert any file with one suffix pattern to a file with another suffix pattern.

PCI bus Peripheral Component Interconnect bus is the main data pathway between components on the system board, including the CPU, main memory, and the communication network.

Peel loop A loop to execute for misaligned data so that the main loop would then have aligned data. Often the peel loop is conditionally executed at run time if the data is discovered to be misaligned.

Perfect hash A hash where there are no collisions; there is at most one entry in each bucket.

Perfectly nested loops Loops that only have statements in the innermost loop. That means that there are no extraneous statements before or after each loop block.

Performance model A simplified representation of how the operations in a program can be converted into an estimate of the code’s run time.

Pinned memory Memory that cannot be paged out from RAM. It is especially useful for memory transfers because it can be directly sent without making a copy.

POSIX standard The Portable Operating System Interface (POSIX) standard is an IEEE standard for Unix and Unix-like operating systems to facilitate portability. The standard specifies the basic operations that should be provided by the OS.

Pragma An instruction to a C or C++ compiler to help it interpret the source code. The form of the instruction is a preprocessor statement starting with `#pragma`.

Prescriptive directives and clauses These are directives from the programmer that tell the compiler specifically what to do.

Private variable (OpenMP) In the context of OpenMP, a private variable is local and only visible to its thread.

Process An independent unit of computation that has ownership of a portion of memory and control over resources in user space.

Processing core or (simply) core The most basic unit capable of performing arithmetic and logical operations.

Profilers A programming tool that measures the performance of an application.

Profiling The run-time measurement of some aspects of application performance; most commonly, the time it takes to execute parts of a program.

Race conditions A situation where multiple outcomes are possible and the result is dependent on the timing of the contributors.

Random access memory (RAM) Main system memory where any needed data can be retrieved without having to read sequentially through the data.

Reduction operation Any operation where a multidimensional array from 1 to N dimensions is reduced to a least one dimension smaller and often to a scalar value.

Register pressure Register pressure refers to the effect of register needs on the performance of GPU kernels.

Regression tests Test suites that are run at periodic intervals such as nightly or weekly.

Relaxed memory model The value of the variables in main memory or caches of all the processors are not updated immediately.

Remainder loop A loop that executes after the main loop to handle a partial set of data that is too small for a full vector length.

Remote procedure call (RPC) A call to the system to execute another command.

Replicated array A dataset that is duplicated across all the processors.

Scalar operation An operation on a single value or one element of an array.

Scatter memory operation Store from a cache line or vector unit to non-contiguous memory locations.

Shared memory A block of memory that is accessible and modifiable by multiple processes or threads of execution. The block of memory is from the programmer’s perspective.

Shared variable (OpenMP) In the context of OpenMP, a shared variable is visible and modifiable by any thread.

SIMD Single instruction, multiple data is a component of Flynn’s Taxonomy describing a parallelism such as that found in vectorization, where a single instruction is applied across multiple data items.

SIMT Single instruction, multiple thread is a variant of SIMD, where multiple threads operate concurrently on multiple data.

SISD Single instruction, single data is a component of Flynn’s Taxonomy that describes a traditional serial architecture.

Socket The location where a processor is inserted on a motherboard. Motherboards normally are either single or dual socket, allowing one or two processors to be installed, respectively.

Source code repository Storage for source code that tracks changes and can be shared between a project’s code developers.

Spatial locality Data with nearby locations in memory that are often referenced close together.

SSE Streaming SIMD Extensions, a vector hardware and instruction set released by Intel that first supported floating-point operations.

SSE2 An improved SSE instruction set that supports double-precision operations.

Stack memory Memory within a subroutine is often created by pushing the objects onto the stack after the stack pointer. These are usually small memory objects that exist for only the duration of the routine and disappear at the end of the routine when the instruction pointer jumps back to the previous location.

Streaming kernels Blocks of computational code that load data in a nearly optimal way to effectively use the cache hierarchy.

Streaming multiprocessor (SM) Usually used to describe the multiprocessors of a GPU that are designed for streaming operations. These are tightly-coupled, symmetric processors (SMP) that have a single instruction stream operating on multiple threads.

Streaming store A store of a value directly to main memory, bypassing the cache hierarchy.

Stride (arrays) Distance between indexed elements in an array. In C, in the x dimension, the data is contiguous or a stride of 1. In the y dimension, the data has a stride of the length of the row.

Super-linear speedup Performance that is better than the ideal strong scaling curve. This can happen because the smaller array sizes fit into a higher level of cache, resulting in better cache performance.

Symmetric processors (SMP) All cores of the multicore processor operate in unison in a single-instruction, multiple-thread (SIMT) fashion.

Task Work that is divided into separate pieces and parceled out to individual processes or threads.

Task parallel A form of parallelism where processors or threads work on separate tasks.

Temporal locality Recently referenced data that is likely to be referenced in the near future.

Test-driven development (TDD) A process of code development where the tests are created first.

Test suite A set of problems that exercise parts of an application to guarantee that parts of the code are still working.

Thread A separate instruction pathway through a process created by having more than one instruction pointer.

Tightly-nested loops Two or more loops that have no extra statements between the `for` or `do` statements or the end of the loops.

Time complexity Time complexity takes into account the actual cost of an operation on a typical modern computing system. The largest adjustment for time is to consider the cost of memory loads and caching of data.

Translation lookaside buffer (TLB) The table of entries to translate virtual memory addresses to physical memory. The limited size of the table means that only recently used page locations are held in memory, and a TLB miss occurs if it is not present, incurring a significant performance hit.

Unified memory Memory that has the appearance of being a single address space for both the CPU and the GPU.

Unit testing Testing of each individual component of a program.

Uninitialized memory Memory that is used before its values are set.

User space The scope of control of operations for a program such that it is isolated from the purview of the operating system.

Validated results Results of a calculation that are compared favorably to experimental or real-world data.

Vector (SIMD) instruction set The set of instructions that extend the regular scalar processor instructions to utilize the vector processor.

Vector lane A pathway through a vector operation on vector registers for a single data element much like a lane on a multi-lane freeway.

Vector length The number of operations done in a single cycle by a vector unit.

Vector operation An operation on two or more elements of an array with a single operation or instruction being supplied to the processor.

Vector width The width of the vector unit, usually expressed in bits.

Vectorization The process of grouping operations together so more than one can be done at a time.

Version Control System A database that tracks the changes to your source code, simplifies the merging of multiple developers, and provides a way to roll back changes.

Warm cache When a cache has data to be operated on in the cache from a previous operation as the current operation begins.

Warp An alternate term for a thread workgroup.

Word (size) The size of the basic type being used. For single precision, this is four bytes and for double, it is eight bytes.

Workgroup A group of threads operating together with a single instruction queue.

**Figure C.1 Desktop motherboard with Intel CPU and discrete NVIDIA GPU**

**Figure C.2 Intel CPU installed in socket and underside with CPU data pins. The data transfer to the CPU is limited by the number of pins that can be physically fit onto the surface of the CPU.**
