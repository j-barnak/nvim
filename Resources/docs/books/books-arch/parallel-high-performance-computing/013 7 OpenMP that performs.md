# 7 OpenMP that performs

***7 OpenMP that performs***

This chapter covers

- Planning and designing a correct and performant OpenMP program
- Writing loop-level OpenMP for modest parallelism
- Detecting correctness problems and improving robustness
- Fixing performance issues with OpenMP
- Writing scalable OpenMP for high performance

As many-core architectures grow in size and popularity, the details of thread-level parallelism become a critical factor in software performance. In this chapter, we first introduce the basics of Open Multi-Processing (OpenMP), a shared memory programming standard, and why it’s important to have a fundamental understanding of how OpenMP functions. We will look at sample problems ranging in difficulty from a simple common “Hello World” example to a complex split-direction stencil implementation with OpenMP parallelization. We will thoroughly analyze the interaction between OpenMP directives and the underlying OS kernel, as well as the memory hierarchy and hardware features. Finally, we will investigate a promising high-level approach to OpenMP programming for future extreme-scale applications. We show that high-level OpenMP is efficient for algorithms containing many short loops of computational work.

When compared to more standard-threading approaches, the high-level OpenMP paradigm leads to a reduction in thread overhead costs, synchronization waits, cache thrashing, and memory usage. Given these advantages, it is essential that the modern parallel computing programmer (you) knows both shared and distributed memory programming paradigms. We discuss the distributed memory programming paradigm in chapter 8 on the Message Passing Interface (MPI).

> > > **NOTE** You’ll find the accompanying source code for this chapter at [https:// github.com/EssentialsofParallelComputing/Chapter7](https://github.com/EssentialsofParallelComputing/Chapter7).

***7.1 OpenMP introduction***

OpenMP is one of the most widely supported open standards for threads and shared-memory parallel programming. In this section, we will explain the standard, ease of use, expected gains, difficulties, and the memory models.

The version of OpenMP that you see today took some time to develop and is still evolving. The origin of OpenMP began when several hardware vendors introduced their implementations in the early 1990s. A failed attempt was made in 1994 to standardize these implementations in the ANSI X3H5 draft standard. It was not until the introduction of wide-scale, multi-core systems in the late ’90s that a re-emergence of the OpenMP approach was spurred, leading to the first OpenMP standard in 1997.

Today, OpenMP provides a standard and portable API for writing shared-memory parallel programs using threads; it’s known to be easy to use, allowing for fast implementation, and requires only a small increase in code, normally seen in the context of pragmas or directives. A pragma (C/C++) or directive (Fortran) indicates to the compiler where to initiate OpenMP threads. These terms, pragma and directive, are often used interchangeably. Pragmas are preprocessor statements in C and C++. Directives are written as comments in Fortran in order for the program to retain the standard language syntax when OpenMP is not used. Although using OpenMP requires a compiler that supports it, most compilers come standard with that support.

OpenMP makes parallelization achievable for a beginner, thus allowing for an easy and fun introduction to scaling an application beyond one core. With the easy use of OpenMP pragmas and directives, a block of code can be quickly executed in parallel. In figure 7.1, you can see a conceptual view of the effort required and the performance obtained for OpenMP and MPI (discussed in chapter 8). Using OpenMP will often be the first exciting step into scaling an application.

***7.1.1 OpenMP concepts***

Although it is easy to achieve modest parallelism with OpenMP, thorough optimization can be a challenge. The source of the difficulty is the relaxed memory model that permits thread race conditions to exist. By relaxed, we mean that the value of the variables in main memory are not updated immediately. It would be too expensive to do so for every change in variables. Because of the delay in the updates, minor timing differences between memory operations by each thread on shared variables have the potential to cause different results from run-to-run. Let’s look at some definitions:

- Relaxed memory model—The value of the variables in main memory or caches of all the processors are not updated immediately.

- Race condition—A situation where multiple outcomes are possible, and the result is dependent on the timing of the contributors.

**Figure 7.1 Conceptual visualization of the programming effort required to improve performance using either MPI or OpenMP**

OpenMP was initially used to parallelize highly regular loops using threads on shared memory multiprocessors. Within a threaded parallel construct, each variable can be either shared or private. The terms shared and private have a particular meaning for OpenMP. Here are their definitions:

- Private variable—In the context of OpenMP, a private variable is local and only visible to its thread.

- Shared variable—In the context of OpenMP, a shared variable is visible and modifiable by any thread.

Truly understanding these terms requires a fundamental view of how memory is managed for a threaded application. As figure 7.2 shows, each thread has a private memory in its stack and shares memory in the heap.

**Figure 7.2 The threaded memory model helps with understanding which variables are shared and which are private. Each thread, shown by the squiggly lines, has its own instruction pointer, stack pointer, and stack memory but shares the heap and static memory data.**

OpenMP directives specify work sharing but say nothing about the memory or data location. As a programmer, you must understand the implicit rules for the memory scope of variables. The OS kernel can use several techniques to manage memory for OpenMP and threading. The most common technique is the first touch concept, where memory is allocated nearest to the thread where it is first touched. We define work sharing and first touch as

- Work sharing—To split the work across a number of threads or processes.

- First touch—The first touch of an array causes the memory to be allocated. The memory is allocated near the thread location where the touch occurs. Prior to the first touch, the memory only exists as an entry in a virtual memory table. The physical memory that corresponds to the virtual memory is created when it is first accessed.

The reason that first touch is important is that on many high-end, high-performance computing nodes, there are multiple memory regions. When there are multiple memory regions, there is often Non-Uniform Memory Access (NUMA) from a CPU and its processes to different portions of memory, adding an important consideration for optimizing code performance.

> > > **DEFINITION** On some computing nodes, blocks of memory are closer to some processors than others. This situation is called Non-Uniform Memory Access (NUMA). This is often the case when a node has two CPU sockets with each socket having its own memory. A processor’s access to memory in the other NUMA domain typically takes twice the time (penalty) as it does to access its own memory.

Moreover, because OpenMP has a relaxed memory model, an OpenMP barrier or flush operation is required for the memory view of a thread to be communicated to other threads. A flush operation guarantees that a value moves between two threads, preventing race conditions. An OpenMP barrier flushes all the locally modified values and synchronizes the threads. How this updating of the values is done is a complicated operation in the hardware and operating system.

On a shared-memory, multi-core system, the modified values in cache must be flushed to the main memory and updated. Newer CPUs use specialized hardware to determine what actually changed, so the cache in dozens of cores only updates if necessary. But it is still an expensive operation and forces threads to stall while waiting for updates. In many ways, it is a similar kind of operation to what you need to do when you want to remove a thumb drive from your computer; you have to tell the operating system to flush all the thumb drive caches and then wait. Codes that use frequent barriers and flushes combined with smaller parallel regions often have excessive synchronization leading to poor performance.

OpenMP addresses a single node, not multiple nodes with distributed memory architectures. Thus, its memory scalability is limited to the memory on the node. For parallel applications that have larger memory requirements, OpenMP needs to be used in conjunction with a distributed-memory parallel technique. We discuss the most common of these, the MPI standard, in chapter 8.

Table 7.1 shows some common OpenMP concepts, terminology, and directives. We will demonstrate the use of these in the rest of the chapter.

**Table 7.1 Roadmap of OpenMP topics in this chapter**

[TABLE]

***7.1.2 A simple OpenMP program***

Now we’ll show you how to apply each of the OpenMP concepts and directives. In this section, you will learn how to create a region of code with multiple threads using the OpenMP parallel pragma on a traditional “Hello World” problem distributed among threads. You will see how easy it is to use OpenMP and, potentially, to achieve performance gains. There are several ways to control how many threads you have in the parallel region. These are

- Default—The default is usually the maximum number of threads for the node, but it can be different, depending on the compiler and if MPI ranks exist.

- Environment variable—Set the size with the OMP_NUM_THREADS environment variable; for example

> > > > `export OMP_NUM_THREADS=16`

- Function call—Call the OpenMP function `omp_set_threads`, for example

> > > > `omp_set_threads(16)`

- Pragma—For example, `#pragma` `omp` `parallel` `num_threads(16)`

The simple example in listings 7.1 through 7.6 shows how to get your thread ID and the number of threads. Listing 7.1 shows our first attempt at writing a Hello World program.

**Listing 7.1 A simple hello OpenMP program that prints** **`Hello`** **`OpenMP`**

> `HelloOpenMP/HelloOpenMP.c`  
> `1 #include <stdio.h>`  
> `2 #include <omp.h>                          `❶  
> `3`  
> `4 int main(int argc, char *argv[]){`  
> `5    int nthreads, thread_id;`  
> `6    nthreads = omp_get_num_threads();      `❷  
> `7    thread_id = omp_get_thread_num();      `❷  
> `8    printf("Goodbye slow serial world and Hello OpenMP");`  
> `9    printf("I have %d thread(s) and my thread id is %d\n",nthreads,thread_id);`  
> `10 }`

❶ Includes OpenMP header file for the OpenMP function calls (mandatory)

❷ Function calls to get the number of threads and the thread ID

To compile with GCC

> `gcc -fopenmp -o HelloOpenMP HelloOpenMP.c`

where `-fopen` is the compiler flag to turn on OpenMP.

Next, we’ll set the number of threads for the program to use by setting an environment variable. We could also use the function call `omp_set_num_threads()` or just let OpenMP pick the number of threads based on the hardware that we are running on. To set the number of threads, use this command to set the environment variable:

> `export OMP_NUM_THREADS=4`

Now, run your executable with ./HelloOpenMP, we get

> `Goodbye slow serial world and Hello OpenMP!`  
> `  I have 1 thread(s) and my thread id is 0`

Not quite what we wanted; there is only one thread. We have to add a parallel region to get multiple threads. Listing 7.2 shows how to add the parallel region.

> > > **NOTE** In listings throughout the chapter, you’ll see the annotations `>>` `Spawn` `threads` `>>` and `Implied` `Barrier` `Implied` `Barrier.` These are visual cues to show where threads are spawned and where barriers are inserted by the compiler. In later listings, we'll use the same annotations for `Explicit` `Barrier` `Explicit` `Barrier` where we have inserted a barrier directive.

**Listing 7.2 Adding a parallel region to Hello OpenMP**

> `HelloOpenMP/HelloOpenMP_fix1.c`  
> `1 #include <stdio.h>`  
> `2 #include <omp.h>`  
> `3`  
> `4 int main(int argc, char *argv[]){`  
> `5   int nthreads, thread_id;`  
> `6   #pragma omp parallel >> Spawn threads >>     `❶  
> `7   {`  
> `8      nthreads = omp_get_num_threads();`  
> `9      thread_id = omp_get_thread_num();`  
> `10      printf("Goodbye slow serial world and Hello OpenMP!\n");`  
> `11      printf("  I have %d thread(s) and my thread id is %d\n",nthreads,thread_id);`  
> `12   } Implied Barrier      Implied Barrier`  
> `13}`

❶ Adds the parallel region

With these changes, we get the following output:

> `Goodbye slow serial world and Hello OpenMP!`  
> `  I have 4 thread(s) and my thread id is 3`  
> `Goodbye slow serial world and Hello OpenMP!`  
> `  I have 4 thread(s) and my thread id is 3`  
> `Goodbye slow serial world and Hello OpenMP!`  
> `Goodbye slow serial world and Hello OpenMP!`  
> `  I have 4 thread(s) and my thread id is 3`  
> `  I have 4 thread(s) and my thread id is 3`

As you can see, all of the threads report that they are thread number 3. This is because `nthreads` and `thread_id` are shared variables. The value that is assigned at run time to these variables is the one written by the last thread to execute the instruction. This is a typical race condition as figure 7.3 illustrates. It is a common issue in threaded programs of any type.

**Figure 7.3 Variables in the previous example are defined before the parallel region, thus these are shared variables in the heap. Each thread writes to these, and the final value is determined by which one writes last. The shading represents progression through time with writes at different clock cycles by various threads in a non-deterministic fashion. This situation and similar situations are called race conditions because the results can vary from run to run.**

Also note that the order of the printout is random, depending on the order of the writes from each processor and how they get flushed to the standard output device. To get the right thread numbers, we define the `thread_id` variable in the loop so that the scope of the variable becomes private to the thread as the following listing shows.

**Listing 7.3 Defining variables where these are used in Hello OpenMP**

> `HelloOpenMP/HelloOpenMP_fix2.c`  
> `1 #include <stdio.h>`  
> `2 #include <omp.h>`  
> `3`  
> `4 int main(int argc, char *argv[]){`  
> `5    #pragma omp parallel >> Spawn threads >>`  
> `6    {`  
> `7       int nthreads = omp_get_num_threads();    `❶  
> `8       int thread_id = omp_get_thread_num();    `❶  
> `9       printf("Goodbye slow serial world and Hello OpenMP!\n");`  
> `10       printf("  I have %d thread(s) and my thread id is %d\n",nthreads,thread_id);`  
> `11    } Implied Barrier      Implied Barrier`  
> `12 }`

❶ Definition of nthreads and thread_id moved into the parallel region.

And we get

> `Goodbye slow serial world and Hello OpenMP!`  
> `Goodbye slow serial world and Hello OpenMP!`  
> `  I have 4 thread(s) and my thread id is 2       `❶  
> `Goodbye slow serial world and Hello OpenMP!`  
> `  I have 4 thread(s) and my thread id is 3       `❶  
> `Goodbye slow serial world and Hello OpenMP!`  
> `  I have 4 thread(s) and my thread id is 0       `❶  
> `  I have 4 thread(s) and my thread id is 1       `❶

❶ Now we get a different thread ID for each thread.

Say we really didn’t want every thread printing out. Let’s minimize the output and put the print statement in a single OpenMP clause as the following listing shows, so only one thread writes output.

**Listing 7.4 Adding a single pragma to print output for Hello OpenMP**

> `HelloOpenMP/HelloOpenMP_fix3.c`  
> `1 #include <stdio.h>`  
> `2 #include <omp.h>`  
> `3`  
> `4 int main(int argc, char *argv[]){`  
> `5    #pragma omp parallel >> Spawn threads >>`  
> `6    {`  
> `7       int nthreads = omp_get_num_threads();              `❶  
> `8       int thread_id = omp_get_thread_num();              `❶  
> `9       #pragma omp single                                 `❷  
> `10       {                                                  `❷  
> `11          printf("Number of threads is %d\n",nthreads);   `❷  
> `12          printf("My thread id %d\n",thread_id);          `❷  
> `13       } Implied Barrier      Implied Barrier             `❷  
> `14    } Implied Barrier      Implied Barrier`  
> `15 }`

❶ Variables defined in a parallel region are private.

❷ Places output statements into an OpenMP single pragma block

And the output is now:

> `Goodbye slow serial world and Hello OpenMP!`  
> `  I have 4 thread(s) and my thread id is 2`

The thread ID is a different value on each run. Here, we really wanted the thread that prints out to be the first thread, so we change the OpenMP clause in the next listing to use `masked` instead of `single`.

**Listing 7.5 Changing a single pragma to a** **`masked`** **pragma in Hello OpenMP**

> `HelloOpenMP/HelloOpenMP_fix4.c`  
> `1 #include <stdio.h>`  
> `2 #include <omp.h>`  
> `3`  
> `4 int main(int argc, char *argv[]){`  
> `5    #pragma omp parallel >> Spawn threads >>`  
> `6    {`  
> `7       int nthreads = omp_get_num_threads();`  
> `8       int thread_id = omp_get_thread_num();`  
> `9       #pragma omp masked                         `❶  
> `10       {`  
> `11          printf("Goodbye slow serial world and Hello OpenMP!\n");`  
> `12          printf("  I have %d thread(s) and my thread id is %d\n",nthreads,thread_id);`  
> `13       }`  
> `14    } Implied Barrier      Implied Barrier`  
> `15 }`

❶ Adds directive to run only on main thread

Running this code now returns what we were first trying to do:

> `Goodbye slow serial world and Hello OpenMP!`  
> `  I have 4 thread(s) and my thread id is 0`

We can make this operation even more concise and use fewer pragmas as we show in listing 7.6. The first print statement does not need to be in the parallel region. Also, we can limit the second printout to thread zero by simply using a conditional on the thread number. The implied barrier is from the `omp` `parallel` pragma.

**Listing 7.6 Reducing the number of pragmas in Hello OpenMP**

> `HelloOpenMP/HelloOpenMP_fix5.c`  
> `1 #include <stdio.h>`  
> `2 #include <omp.h>`  
> `3`  
> `4 int main(int argc, char *argv[]){`  
> `5    printf("Goodbye slow serial world and Hello OpenMP!\n");     `❶  
> `6    #pragma omp parallel >> Spawn threads >>                     `❷  
> `7    if (omp_get_thread_num() == 0) {                             `❸  
> `8       printf("  I have %d thread(s) and my thread id is %d\n",`  
> `             omp_get_num_threads(), omp_get_thread_num());`  
> `9    }`  
> `10    Implied Barrier      Implied Barrier`  
> `11 }`

❶ Moves print statement out of parallel region

❷ Pragma applies to next statement or a scoping block delimited by curly braces.

❸ Replaces OpenMP masked pragma with conditional for thread zero

We have learned a few important things from this example:

- Variables that are defined outside a parallel region are by default shared in the parallel region.

- We should always strive to have the smallest program scope for a variable that is still correct. By defining the variable in the loop, the compiler can better understand our intent and handle it correctly.

- Using the `masked` clause is more restrictive than the `single` clause because it requires thread 0 to execute the code block. The `masked` clause also does not have an implicit barrier at the end.

- We need to watch out for possible race conditions between the operations of different threads.

OpenMP is continuously updating and releasing new versions. Before using an OpenMP implementation, you should know the version and the features that are supported. OpenMP started with the ability to harness threads across a single node. New capabilities, such as vectorization, and offloading tasks to accelerators, such as GPUs, have been added to the OpenMP standard. The following table shows some of the major features added in the last decade.

|                    |                                                                                                                                                              |
|--------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Version 3.0 (2008) | Introduction of task parallelism, and improvements to loop parallelism. These improvements to loop parallelism include loop collapse and nested parallelism. |
| Version 3.1 (2011) | Adds reduction `min` and `max` operators to C and C++ (other operators already in C and C++; `min` and `max` already in Fortran) and thread binding control  |
| Version 4.0 (2013) | Adds OpenMP SIMD (vectorization) directive, target directive for offloading to GPUs and other accelerator devices, and thread affinity control               |
| Version 4.5 (2015) | Substantial improvements to accelerator device support for GPUs                                                                                              |
| Version 5.0 (2018) | Further improvements to accelerator device support                                                                                                           |

One thing to note is that to deal with the substantial changes in hardware that are occurring, the pace of changes to OpenMP has increased since 2011. While the changes in version 3.0 and 3.1 dealt mostly with the standard CPU threading model, since then the changes in versions 4.0, 4.5, and 5.0 have mostly dealt with other forms of hardware parallelism, such as accelerators and vectorization.

***7.2 Typical OpenMP use cases: Loop-level, high-level, and MPI plus OpenMP***

OpenMP has three specific use-case scenarios to meet the needs of three different types of users. The first decision you need to make is which scenario is appropriate for your situation. The strategy and techniques vary for each of these cases: loop-level OpenMP, high-level OpenMP, and OpenMP to enhance MPI implementations. In the following sections, we will elaborate on each of these, when to use them and why, and how to use them. Figure 7.4 shows the recommended material to be carefully read for each of the use cases.

**Figure 7.4 The recommended reading for each of the scenarios depends on the use case for your application.**

***7.2.1 Loop-level OpenMP for quick parallelization***

A standard use case for loop-level OpenMP is when your application only needs a modest speedup and has plenty of memory resources. By this we mean that its requirements can be satisfied by the memory on a single hardware node. In this use case, it might be sufficient to use loop-level OpenMP. The following list summarizes the application characteristics of loop-level OpenMP:

- Modest parallelism

- Has plenty of memory resources (low memory requirements)

- Expensive part of calculation is in just a few `for` or `do` loops

We use loop-level OpenMP in these cases because it takes little effort and can be done quickly. With separate `parallel` `for` pragmas, the issue of thread race conditions is reduced. By placing OpenMP `parallel` `for` pragmas or `parallel` `do` directives before key loops, the parallelism of the loop can be easily achieved. Even when the end goal is a more efficient implementation, this loop-level approach is often the first step when introducing thread parallelism to an application.

> > > **NOTE** If your use case requires only modest speedup, go to section 7.3 for examples of this approach.

***7.2.2 High-level OpenMP for better parallel performance***

Next we discuss a different scenario, high-level OpenMP, where higher performance is desired. Our high-level OpenMP design has a radical difference from the strategies for standard loop-level OpenMP. Standard OpenMP starts from the bottom-up and applies the parallelism constructs at the loop level. Our high-level OpenMP approach takes a whole system view to the design with a top-down approach that addresses the memory system, the system kernel, and the hardware. The OpenMP language does not change, but the method of its use does. The end result is that we eliminate many of the thread startup costs and the costs of synchronization that hobble the scalability of loop-level OpenMP.

If you need to extract every last bit of performance out of your application, then high-level OpenMP is for you. Begin by learning loop-level OpenMP in section 7.3 as a starting point for your application. Then you will need to gain a deeper understanding of OpenMP variable scope from sections 7.4 and 7.5. Finally, dive into section 7.6 for a look at how the diametrically opposite approach of high-level OpenMP from the loop-level approach results in better performance. In that section, we’ll look at the implementation model and a step-by-step method to reach the desired structure. This is followed by detailed examples of implementations for high-level OpenMP.

***7.2.3 MPI plus OpenMP for extreme scalability***

We can also use OpenMP to supplement distributed memory parallelism (as discussed in chapter 8). The basic idea of using OpenMP on a small subset of processes adds another level of parallel implementation that helps for extreme scaling. This could be within the node, or better yet, the set of processors that uniformly share quick access to shared memory, commonly referred to as a Non-Uniform Memory Access (NUMA) region.

We first discussed NUMA regions in OpenMP concepts in section 7.1.1 as an additional consideration for performance optimization. By using threading only within one memory region where all memory accesses have the same cost, some of the complexity and performance traps of OpenMP are avoided. In a more modest hybrid implementation, OpenMP can be used to harness the two-to-four hyperthreads for each processor. We’ll discuss this scenario, the hybrid MPI + OpenMP, in chapter 8 after describing the basics of MPI.

For the OpenMP skills needed for this hybrid approach with small thread counts, it is sufficient to learn the loop-level OpenMP techniques in section 7.3. Then move incrementally to a more efficient and scalable OpenMP implementation, which allows more and more threads to replace MPI ranks. This requires at least some of the steps on the path to high-level OpenMP as presented in section 7.6. Now that you know what sections are important for your application’s use case, let’s jump into the details of how to make each strategy work.

***7.3 Examples of standard loop-level OpenMP***

In this section, we will look at examples of loop-level parallelization. The loop-level use case was introduced in section 7.2.1; here we will show you the implementation details. Let’s begin.

Parallel regions are initiated by inserting pragmas around blocks of code that can be divided among independent threads (e.g., `do` loops, `for` loops). OpenMP relies on the OS kernel for its memory handling. This reliance for memory handling can often be an important factor that limits OpenMP from reaching its peak potential. We’ll look at why this happens. Each variable within a parallel construct can be either shared or private. Moreover, OpenMP has a relaxed memory model. Each thread has a temporary view of memory so that it doesn’t have the cost of storing memory with every operation. When the temporary view finally must be reconciled with main memory, an OpenMP barrier or flush operation is required to synchronize memory. Each of these synchronizations comes with a cost, due to the time that it takes to perform the flush, but also because it requires fast threads to wait for slower ones to complete. An understanding of how OpenMP functions can reduce these performance bottlenecks.

Performance is not the only concern for an OpenMP programmer. You should also watch for correctness issues caused by thread race conditions. Threads might progress at different speeds on the processors and, in combination with the relaxed memory synchronization, serious errors can suddenly occur in even well-tested code. Careful programming and the use of specialized tools as discussed in section 7.9.2 is essential for robust OpenMP applications.

In this section, we’ll take a look at a few loop-level OpenMP examples to get an idea of how it is used in practice. The source code that accompanies the chapter has more variants of each example. We strongly encourage you to experiment with each of these on the architecture and compiler that you commonly work with. We ran each of the examples on a Skylake Gold 6152 dual socket system, as well as a 2017 Mac laptop. Threads are allocated by cores, and thread binding is enabled using the following OpenMP environment variables to reduce the performance variation of runs:

> `export OMP_PLACES=cores`  
> `export OMP_CPU_BIND=true`

We’ll explore thread placement and binding more in chapter 14. For now, to help you get experience with loop-level OpenMP, we’ll present three different examples: vector addition, stream triad, and a stencil code. We’ll show the parallel speedup of the three examples after the last example in section 7.3.4.

***7.3.1 Loop level OpenMP: Vector addition example***

In the vector addition example (listing 7.7), you can see the interaction between the three components: OpenMP work-sharing directives, implied variable scope, and memory placement by the operating system. These three components are necessary for OpenMP program correctness and performance.

**Listing 7.7 Vector add with a simple loop-level OpenMP pragma**

> `VecAdd/vecadd_opt1.c`  
> `1 #include <stdio.h>`  
> `2 #include <time.h>`  
> `3 #include <omp.h>`  
> `4 #include "timer.h"`  
> `5`  
> `6 #define ARRAY_SIZE 80000000                                `❶  
> `7 static double a[ARRAY_SIZE], b[ARRAY_SIZE], c[ARRAY_SIZE];`  
> `8`  
> `9 void vector_add(double *c, double *a, double *b, int n);`  
> `10`  
> `11 int main(int argc, char *argv[]){`  
> `12    #pragma omp parallel >> Spawn threads >>`  
> `13       if (omp_get_thread_num() == 0)`  
> `14          printf("Running with %d thread(s)\n",omp_get_num_threads());`  
> `      Implied Barrier      Implied Barrier`  
> `15`  
> `16    struct timespec tstart;`  
> `17    double time_sum = 0.0;`  
> `18    for (int i=0; i<ARRAY_SIZE; i++) {                      `❷  
> `19       a[i] = 1.0;                                          `❷  
> `20       b[i] = 2.0;                                          `❷  
> `21    }                                                       `❷  
> `22`  
> `23    cpu_timer_start(&tstart);`  
> `24    vector_add(c, a, b, ARRAY_SIZE);`  
> `25    time_sum += cpu_timer_stop(tstart);`  
> `26`  
> `27    printf("Runtime is %lf msecs\n", time_sum);`  
> `28 }`  
> `29`  
> `30 void vector_add(double *c, double *a, double *b, int n)`  
> `31 {`  
> `32    #pragma omp parallel for >> Spawn threads >>            `❸  
> `33    for (int i=0; i < n; i++){                              `❹  
> `34       c[i] = a[i] + b[i];                                  `❹  
> `35    }                                                       `❹  
> `      Implied Barrier      Implied Barrier`  
> `36 }`

❶ Array is large enough to force into main memory.

❷ Initialization loop

❸ Single-combined OpenMP parallel for pragma

❹ Vector add loop

This particular implementation style produces modest parallel performance on a single node. Take note, this implementation could be better. All the array memory is first touched by the main thread during the initialization prior to the main loop as shown on the left in figure 7.5. This can cause the memory to be located in a different memory region, where the memory access time is greater for some of the threads.

**Figure 7.5 Adding a single OpenMP pragma on the main vector add computation loop (on the left) results in the** **`a`** **and** **`b`** **arrays being touched first by the main thread; the data is allocated near thread zero. The** **`c`** **array is first touched during the computation loop and, therefore, the memory for the** **`c`** **array is close to each thread. On the right, adding an OpenMP pragma on the initialization loop results in the memory for the** **`a`** **and** **`b`** **arrays being placed near the thread where the work is done.**

Now, to improve the OpenMP performance, we insert pragmas in the initialization loops as listing 7.8 shows. The loops are distributed in the same static threading partition, so the threads that touch the memory in the initialization loop will have the memory located near to them by the operating system (shown on the right side of figure 7.5).

**Listing 7.8 Vector add with first touch**

> `VecAdd/vecadd_opt2.c`  
> `11 int main(int argc, char *argv[]){`  
> `12    #pragma omp parallel >> Spawn threads >>`  
> `13       if (omp_get_thread_num() == 0)`  
> `14          printf("Running with %d thread(s)\n",omp_get_num_threads());`  
> `      Implied Barrier      Implied Barrier`  
> `15`  
> `16    struct timespec tstart;`  
> `17    double time_sum = 0.0;`  
> `18    #pragma omp parallel for >> Spawn threads >>     `❶  
> `19    for (int i=0; i<ARRAY_SIZE; i++) {               `❷  
> `20       a[i] = 1.0;                                   `❷  
> `21       b[i] = 2.0;                                   `❷  
> `22    }                                                `❷  
> `      Implied Barrier      Implied Barrier`  
> `23`  
> `24    cpu_timer_start(&tstart);`  
> `25    vector_add(c, a, b, ARRAY_SIZE);`  
> `26    time_sum += cpu_timer_stop(tstart);`  
> `27`  
> `28    printf("Runtime is %lf msecs\n", time_sum);`  
> `29 }`  
> `30`  
> `31 void vector_add(double *c, double *a, double *b, int n)`  
> `32 {`  
> `33    #pragma omp parallel for  >> Spawn threads >>    `❸  
> `34    for (int i=0; i < n; i++){                       `❹  
> `35       c[i] = a[i] + b[i];                           `❹  
> `36    }                                                `❹  
> `      Implied Barrier      Implied Barrier`  
> `37 }`

❶ Initialization in a “parallel for” pragma so first touch gets memory in the proper location

❷ Initializes the a and b arrays

❸ OpenMP for pragma to distribute work for vector add loop across threads

❹ Vector add loop

The threads in the second NUMA region no longer have a slower memory access time. This improves the memory bandwidth for the threads in the second NUMA region and also improves the load balance across the threads. First touch is an OS policy that was mentioned earlier in section 7.1.1. Good first touch implementations may often gain a 10 to 20% performance improvement. For evidence that this is the case, see table 7.2 in section 7.3.4 for the performance improvement on these examples.

If NUMA is enabled in the BIOS, the Skylake Gold 6152 CPU has a factor of about two decrease in performance when accessing remote memory. As with most tunable parameters, the configuration of individual systems can vary. To see your configuration, you can use the `numactl` and `numastat` commands for Linux. You may have to install the numactl-libs or numactl-devel packages for these commands.

Figure 7.6 shows the output for the Skylake Gold test platform. The node distances listed at the end of the output roughly capture the cost of accessing memory on a remote node. You can think of this as the relative number of hops to get to memory. Here the memory access cost is a little over a factor of two (21 versus 10). Note that sometimes two NUMA region systems are listed with a cost of 20 versus 10 as a default configuration instead of their real costs.

**Figure 7.6 Output from the** **`numactl`** **and** **`numastat`** **commands. The distance between memory regions is highlighted. Note that the NUMA utilities use the term “node” differently than we have defined it. In their terminology, each NUMA region is a node. We reserve the node terminology for a separate distributed memory system such as another desktop or tray in a rack-mounted system.**

The NUMA configuration information can tell you what is important to optimize. If you only have one NUMA region, or the difference in memory access costs is small, you may not need to worry as much about first touch optimizations. If the system is configured for interleaved memory accesses to the NUMA regions, optimizing for the faster local memory accesses will not help. In the absence of specific information or when trying to optimize in general for larger HPC systems, you should use first touch optimizations to get local, faster memory accesses.

***7.3.2 Stream triad example***

The following listing shows another similar example for the stream triad benchmark. This example runs multiple iterations of the kernel to get an average performance.

**Listing 7.9 Loop-level OpenMP threading of the stream triad**

> `StreamTriad/stream_triad_opt2.c`  
> `1 #include <stdio.h>`  
> `2 #include <time.h>`  
> `3 #include <omp.h>`  
> `4 #include "timer.h"`  
> `5`  
> `6 #define NTIMES 16`  
> `7 #define STREAM_ARRAY_SIZE 80000000                 `❶  
> `8 static double a[STREAM_ARRAY_SIZE], b[STREAM_ARRAY_SIZE], c[STREAM_ARRAY_SIZE];`  
> `9`  
> `10 int main(int argc, char *argv[]){`  
> `11    #pragma omp parallel >> Spawn threads >>`  
> `12       if (omp_get_thread_num() == 0)`  
> `13          printf("Running with %d thread(s)\n",omp_get_num_threads());`  
> `      Implied Barrier      Implied Barrier`  
> `14`  
> `15    struct timeval tstart;`  
> `16    double scalar = 3.0, time_sum = 0.0;            `❷  
> `17    #pragma omp parallel for >> Spawn threads >>`  
> `18    for (int i=0; i<STREAM_ARRAY_SIZE; i++) {       `❷  
> `19       a[i] = 1.0;                                  `❷  
> `20       b[i] = 2.0;                                  `❷  
> `21    }                                               `❷  
> `      Implied Barrier      Implied Barrier`  
> `22`  
> `23    for (int k=0; k<NTIMES; k++){`  
> `24       cpu_timer_start(&tstart);`  
> `25       #pragma omp parallel for >> Spawn threads >>`  
> `26       for (int i=0; i<STREAM_ARRAY_SIZE; i++){     `❸  
> `27          c[i] = a[i] + scalar*b[i];                `❸  
> `28       }                                            `❸  
> `         Implied Barrier      Implied Barrier`  
> `29       time_sum += cpu_timer_stop(tstart);`  
> `30       c[1]=c[2];                                   `❹  
> `31    }`  
> `32`  
> `33    printf("Average runtime is %lf msecs\n", time_sum/NTIMES);`  
> `34 }`

❶ Large enough to force into main memory

❷ Initializes data and arrays

❸ Stream triad loop

❹ Keeps the compiler from optimizing the loop

Again, we just need one pragma to implement the OpenMP threaded computation at line 25. A second pragma inserted at line 17 further improves performance because of the better memory placement obtained by a proper first touch technique.

***7.3.3 Loop level OpenMP: Stencil example***

The third example of loop-level OpenMP is the stencil operation first introduced in chapter 1 (figure 1.10). This stencil operator adds the surrounding neighbors and takes an average for the new value of the cell. Listing 7.10 has more complex memory read access patterns and, as we optimize the routine, it shows us the effect of threads accessing memory written by other threads. In this first loop-level OpenMP implementation, each `parallel` `for` block is synchronized by default, which prevents potential race conditions. In later, more optimized versions of the stencil, we’ll add explicit synchronization directives.

**Listing 7.10 Loop-level OpenMP threading in the stencil example with first touch**

> `Stencil/stencil_opt2.c`  
> `1 #include <stdio.h>`  
> `2 #include <stdlib.h>`  
> `3 #include <time.h>`  
> `4 #include <omp.h>`  
> `5`  
> `6 #include "malloc2D.h"`  
> `7 #include "timer.h"`  
> `8`  
> `9 #define SWAP_PTR(xnew,xold,xtmp) (xtmp=xnew, xnew=xold, xold=xtmp)`  
> `10`  
> `11 int main(int argc, char *argv[])`  
> `12 {`  
> `13    #pragma omp parallel >> Spawn threads >>`  
> `14    #pragma omp masked`  
> `15       printf("Running with %d thread(s)\n",omp_get_num_threads());`  
> `      Implied Barrier      Implied Barrier`  
> `16`  
> `17    struct timeval tstart_init, tstart_flush, tstart_stencil, tstart_total;`  
> `18    double init_time, flush_time, stencil_time, total_time;`  
> `19    int imax=2002, jmax = 2002;`  
> `20    double** xtmp;`  
> `21    double** x = malloc2D(jmax, imax);`  
> `22    double** xnew = malloc2D(jmax, imax);`  
> `23    int *flush = (int *)malloc(jmax*imax*sizeof(int)*4);`  
> `24`  
> `25    cpu_timer_start(&tstart_total);`  
> `26    cpu_timer_start(&tstart_init);`  
> `27    #pragma omp parallel for >> Spawn threads >>       `❶  
> `28    for (int j = 0; j < jmax; j++){`  
> `29       for (int i = 0; i < imax; i++){`  
> `30          xnew[j][i] = 0.0;`  
> `31          x[j][i] = 5.0;`  
> `32       }  `  
> `33    } Implied Barrier      Implied Barrier`  
> `34`  
> `35    #pragma omp parallel for >> Spawn threads >>       `❶  
> `36    for (int j = jmax/2 - 5; j < jmax/2 + 5; j++){`  
> `37       for (int i = imax/2 - 5; i < imax/2 -1; i++){`  
> `38          x[j][i] = 400.0;`  
> `39       }  `  
> `40    } Implied Barrier      Implied Barrier`  
> `41    init_time += cpu_timer_stop(tstart_init);`  
> `42`  
> `43    for (int iter = 0; iter < 10000; iter++){`  
> `44       cpu_timer_start(&tstart_flush);`  
> `45       #pragma omp parallel for >> Spawn threads >>    `❷  
> `46       for (int l = 1; l < jmax*imax*4; l++){`  
> `47           flush[l] = 1.0;`  
> `48       } Implied Barrier      Implied Barrier `  
> `49       flush_time += cpu_timer_stop(tstart_flush);`  
> `50       cpu_timer_start(&tstart_stencil);`  
> `51       #pragma omp parallel for >> Spawn threads >>    `❷  
> `52       for (int j = 1; j < jmax-1; j++){`  
> `53          for (int i = 1; i < imax-1; i++){`  
> `54             xnew[j][i]=(x[j][i] + x[j][i-1] + x[j][i+1] +`  
> `                                     x[j-1][i] + x[j+1][i])/5.0;`  
> `55          }  `  
> `56       } Implied Barrier      Implied Barrier `  
> `57       stencil_time += cpu_timer_stop(tstart_stencil);`  
> `58`  
> `59       SWAP_PTR(xnew, x, xtmp);`  
> `60       if (iter%1000 == 0) printf("Iter %d\n",iter);`  
> `61    }  `  
> `62    total_time += cpu_timer_stop(tstart_total);`  
> `63`  
> `64    printf("Timing: init %f flush %f stencil %f total %f\n",`  
> `65           init_time,flush_time,stencil_time,total_time);`  
> `66`  
> `67    free(x);`  
> `68    free(xnew);`  
> `69    free(flush);`  
> `70 }`

❶ Initializes with OpenMP pragma for first-touch memory allocation

❷ Inserts parallel for pragma to thread loop

For this example, we inserted a flush loop at line 46 to empty the cache of the `x` and `xnew` arrays. This is to mimic the performance where a code does not have the variables in cache from a prior operation. The case without data in cache is termed a cold cache, and when the data is in cache it is called a warm cache. Both cold and warm caches are valid cases to analyze for different use-case scenarios. Simply, both cases are possible in a real application, and it may be difficult to even know which will happen without a deep analysis.

***7.3.4 Performance of loop-level examples***

Let’s review the performance of the earlier examples in this section. As seen in listings 7.8, 7.9, and 7.10, introducing loop-level OpenMP requires few changes to the source code. As table 7.2 demonstrates, the performance improvement is on the order of 10x faster. This is a pretty good performance return for the effort required. But for a system with 88 threads, the achieved parallel efficiency is modest, at about 19% as calculated below, giving us some room for improvement. To calculate the speedup, we first take the serial run time divided by the parallel run time like this:

Stencil speedup = (serial run-time)/(parallel run-time) = 17.0 times faster

If we get perfect speedup on 88 threads, it would be 88. We take the actual speedup and divide by the ideal speedup of 88 to calculate the parallel efficiency:

Stencil parallel efficiency = (stencil speedup)/(ideal speedup) = 17 / 88 = 19%

Parallel efficiency is much better at smaller thread counts; at four threads, parallel efficiency is at 85%. The effect of getting memory allocated close to the thread is small, but significant. In the timings in table 7.2, the first optimization, simple loop-level OpenMP, has just OpenMP `parallel` `for` pragmas on the computation loops. The second optimization with first touch adds the OpenMP `parallel` `for` pragmas for the initialization loops. Table 7.2 summarizes the performance improvements for simple OpenMP with the addition of a first touch optimization. The timings used `OMP_ PLACES=cores` and `OMP_CPU_BIND=true`.

**Table 7.2 Shown are the run times in msecs. The speedup on a Skylake Gold 6152 dual socket node with the GCC version 8.2 compiler is a factor of ten on 88 threads. Adding an OpenMP pragma on the initialization to get proper first-touch memory allocation returns an additional speedup.**

| ** **        | **Serial** | **Simple loop-level OpenMP** | **Adding first touch** |
|--------------|------------|------------------------------|------------------------|
| Vector Add   | 0.253      | 0.0301                       | 0.0175                 |
| Stream Triad | 0.164      | 0.0203                       | 0.0131                 |
| Stencil      | 62.56      | 3.686                        | 3.311                  |

Profiling the stencil application threaded with OpenMP, we observe that 10-15% of the run time is consumed by OpenMP overhead, consisting of thread waits and thread startup costs. We can reduce the OpenMP overhead by adopting a high-level OpenMP design as we’ll discuss in section 7.6.

***7.3.5 Reduction example of a global sum using OpenMP threading***

Another common type of loop is a reduction. Reductions are a common pattern in parallel programming that were introduced in section 5.7. Reductions are any operation that starts with an array and calculates a scalar result. In OpenMP, this can also be handled easily in the loop-level pragma with the addition of a `reduction` clause as the following listing shows.

**Listing 7.11 Global sum with OpenMP threading**

> `GlobalSums/serial_sum_novec.c`  
> `1 double do_sum_novec(double* restrict var, long ncells)`  
> `2 {`  
> `3    double sum = 0.0;                          `❶  
> `4    #pragma omp parallel for reduction(+:sum)  `❷  
> `5    for (long i = 0; i < ncells; i++){         `❶  
> `6       sum += var[i];                          `❶  
> `7    }                                          `❶  
> `8`  
> `9    return(sum);`  
> `10 }`

❶ Global sum reduction code

❷ OpenMP parallel for loop with reduction clause

The reduction operation computes a local sum on each thread and then sums all the threads together. The reduction variable, `sum`, is initialized to the appropriate value for the operation. In the code in listing 7.11, the reduction variable is initialized to zero. The initialization of the `sum` variable to zero on line 3 is still needed for proper operation when we don’t use OpenMP.

***7.3.6 Potential loop-level OpenMP issues***

Loop-level OpenMP can be applied to most, but not all loops. The loop must have a canonical form so that the OpenMP compiler can apply the work-sharing operation. The canonical form is the traditional, straightforward loop implementation that is first learned by programmers. The requirements are that

- The loop index variable must be an integer.

- The loop index cannot be modified in the loop.

- The loop must have standard exit conditions.

- The loop iterations must be countable.

- The loop must not have any loop-carried dependencies.

You can test the last requirement by reversing the order of the loop or by changing the order of the loop operations. If the answer changes, the loop has loop-carried dependencies. There are similar restrictions on loop-carried dependencies for vectorization on the CPU and threading implementations on the GPU. The similarities of this loop-carried dependency requirement have been described as fine-grained parallelization versus the coarse-grained structure used in a distributed-memory, message-passing approach. Here are some definitions:

- Fine-grained parallelization—A type of parallelism where computational loops or other small blocks of code are operated on by multiple processors or threads and may need frequent synchronization.

- Coarse-grained parallelization—A type of parallelism where the processor operates on large blocks of code with infrequent synchronization.

Many programming languages have proposed a modified loop-type that tells the compiler that loop-level parallelism is allowed to be applied in some form. For now, supplying a pragma or directive before the loop supplies this information.

***7.4 Variable scope importance for correctness in OpenMP***

To convert an application or routine to high-level OpenMP, you need to understand variable scope. The OpenMP specifications are vague on many scoping details. Figure 7.7 shows the scoping rules for compilers. Generally, a variable on the stack is considered private, and those that are placed in the heap are shared (figure 7.2). For high-level OpenMP, the most important case is how to manage scope in a called routine in a parallel region.

**Figure 7.7 Summary of thread scoping rules for OpenMP applications**

When determining the scope of variables, you should put more focus on variables on the left-hand side of an expression. The scope for variables that are being written to is more important to get correct. Note that private variables are undefined at entry and after the exit of a parallel region as listing 7.12 shows. The `firstprivate` and `lastprivate` clauses can modify this behavior in special cases. If a variable is private, we should see it set before it is used in the parallel block and not used after the parallel region. If a variable is intended to be private, it is best to declare the variable within the loop because a locally declared variable has exactly the same behavior as a private OpenMP variable. Long story short, declaring the variable within the loop eliminates any confusion on what the behavior should be. It does not exist before the loop or afterward, so incorrect uses are not possible.

**Listing 7.12 Private variable entering the OpenMP parallel block**

> `1    double x;                                                `❶  
> `2    #pragma omp parallel for private(x) >> Spawn threads >>  `❷  
> `3    for (int i=0; i < n; i++){`  
> `4       x = 1.0                                               `❸  
> `5       double y = x*2.0;                                     `❹  
> `6    } Implied Barrier      Implied Barrier`  
> `7`  
> `8    double z = x;                                            `❺

❶ Variable declared outside parallel for block.

❷ Private clause on parallel for block

❸ X will not be defined, so it must be set first.

❹ Declared private variable within loop is better style.

❺ X is not defined here.

On the directive in line 4 in listing 7.11, we added a reduction clause to note the special treatment needed for the `sum` variable. On line 2 of listing 7.12, we showed the `private` directive. There are other clauses that can be used on the parallel directive and other program blocks, for example:

- `shared(var,var)`

- `private(var,var)`

- `firstprivate(var,var)`

- `lastprivate(var,` `var)`

- `reduction([+,min,max]:<var,var>)`

- `*threadprivate` (a special directive used in a thread-parallel function)

We highly recommend using tools such as Intel® Inspector and Allinea/ARM MAP to develop more efficient code and to implement high-level OpenMP. We discuss some of these tools in section 7.9. Becoming familiar with a variety of essential tools is necessary before beginning the implementation of high-level OpenMP. After running your application through these tools, a better understanding of the application allows for a smoother transition to the implementation of high-level OpenMP.

***7.5 Function-level OpenMP: Making a whole function thread parallel***

We will introduce the concept of high-level OpenMP in section 7.6. But before we attempt high-level OpenMP, it is necessary to see how the loop-level implementations can be expanded to cover larger sections of code. The purpose for expanding the loop-level implementation is to lower the overhead and increase parallel efficiency. When expanding the parallel region, it eventually covers an entire subroutine. Once we convert the whole function into an OpenMP parallel region, OpenMP provides far less control over the thread scope of the variables. The clauses for a parallel region no longer help as there is no place to add scoping clauses. So how do we control variable scope?

While the defaults for variable scope in functions usually work well, there are cases where they don’t. The only OpenMP pragma control for functions is the `threadprivate` directive that makes a declared variable private. Most variables in a function are on the stack and are already private. If there is an array dynamically allocated in the routine, the pointer it is assigned to is a local variable on the stack, which means it is private and different for every thread. We want this array to be shared, but there is no directive for that. Using the specific compiler scoping rules from figure 7.7, we add a `save` attribute to the pointer declaration in Fortran, making the compiler put the variable in the heap and, thus, sharing the variable among the threads. In C, the variable can be declared static or made file scope. The following listing shows some examples of the thread scope of variables for Fortran, and listing 7.14 shows examples for C and C++.

**Listing 7.13 Function-level variable scope in Fortran**

> ` 4 subroutine function_level_OpenMP(n, y)`  
> `5    integer :: n`  
> `6    `**`real :: y(n)`**`                             `❶  
> `7`  
> `8    `**`real, allocatable :: x(:)`**`                `❷  
> `9    `**`real x1`**`                                  `❸  
> `10    `**`real :: x2 = 0.0`**`                         `❹  
> `11    `**`real, save :: x3`**`                         `❺  
> `12    `**`real, save, allocatable :: z`**`             `❻  
> `13`  
> `14    `**`if (thread_id .eq. 0) allocate(x(100)) `**` `` `❼  
> `15`  
> `16 !  lots of code                                                                                                                     `  
> `17                                                                                                                                     `  
> `18    if (thread_id .eq. 0) deallocate(x)                                                                                              `  
> `19 end subroutine function_level_OpenMP`

❶ Pointer for array y and its array elements that are private

❷ Pointer for allocatable array x that is private

❸ Variable x1 is on the stack, so it is private.

❹ Variable x2 is shared in Fortran 90.

❺ Variable x3 is placed on the heap, so it is shared.

❻ Pointer for z array is on the heap and is shared.

❼ The x array memory is shared, but the pointer to x is private.

The pointer for array `y` on line 6 is the scope of the variable at the location of the subroutine. In this case, it is in a parallel region, making it private. Both the pointer for `x` and the variable `x1` are private. The scope of variable `x2` on line 10 is more complicated. It is shared in Fortran 90 and private in Fortran 77. Initialized variables in Fortran 90 are on the heap and are only initialized (to zero in this case) on their first occurrence! The variables `x3` and `z` on lines 11 and 12 are shared because these are in the heap. The memory allocated for `x` on line 14 is on the heap and shared, but the pointer is private, which results in memory only accessible on thread zero.

**Listing 7.14 Function-level variable scope in C/C++**

> ` 5 void function_level_OpenMP(int n, double *y)                        `❶  
> `6 {`  
> `7    `**`double *x;`**`                                                       `❷  
> `8    `**`static double *x1;`**`                                               `❸  
> `9`  
> `10    int thread_id;`  
> `11 #pragma omp parallel`  
> `12    thread_id = omp_get_thread_num();`  
> `13`  
> `14    if (thread_id == 0) `**`x = (double *)malloc(100*sizeof(double));`**`    `❹  
> `15    if (thread_id == 0) `**`x1 = (double *)malloc(100*sizeof(double));`**`   `❺  
> `16`  
> `17 // lots of code`  
> `18    if (thread_id ==0) free(x);`  
> `19    if (thread_id ==0) free(x1);`  
> `20 }`

❶ The pointer to array y is private.

❷ The pointer to array x is private.

❸ The pointer to array x1 is shared.

❹ Memory for the x array is shared.

❺ Memory for the x1 array is shared.

The pointer to array `y` in the argument list on line 5 is on the stack. It has the scope of the variable at the calling location. In a parallel region, the pointer to `y` is private. The memory for the `x` array is on the heap and shared, but the pointer is private, so the memory is only accessible from thread zero. Memory for the `x1` array is on the heap and shared, and the pointer is shared so the memory is accessible and shared across all the threads.

You need to be always on guard for unexpected effects of variable declarations and definitions that impact the thread scope. For example, initializing a local variable with a value in a Fortran 90 subroutine automatically gives the variable the `save` attribute and the variable is now shared.[2](#filepos1024623) We recommend explicitly adding the `save` attribute to the declaration to avoid any issues or confusion.

***7.6 Improving parallel scalability with high-level OpenMP***

Why use high-level OpenMP? The central high-level OpenMP strategy is to improve on standard loop-level parallelism by minimizing fork/join overhead and memory latency. Reduction of thread wait times is often seen as another major motivating factor of high-level OpenMP implementations. By explicitly dividing the work among the threads, threads are no longer implicitly waiting on other threads and can therefore go on to the next part of the calculation. This allows explicit control of the synchronization point. In figure 7.8, unlike the typical fork-join model of standard OpenMP, high-level OpenMP keeps the threads dormant but alive, thus reducing overhead tremendously.

**Figure 7.8 Visualization of high-level OpenMP threading. Threads are spawned once and left dormant when not needed. Thread bounds are specified manually and synchronization is minimized.**

In this section, we’ll review the explicit steps needed to implement high-level OpenMP. Then we’ll show you how to go from a loop-level implementation to a high-level implementation.

***7.6.1 How to implement high-level OpenMP***

Implementation of high-level OpenMP is often more time-consuming because it requires the use of advanced tools and extensive testing. Implementing high-level OpenMP can also be difficult as it is more prone to race conditions than the standard loop-level implementation. Additionally, it is often not apparent how to get from the starting point (loop-level implementation) to the ending point (high-level implementation).

The common use for the more tedious high-level open implementation would be when you want more efficiency and want to get rid of thread spawning and synchronization costs. For more information on high-level OpenMP, see section 7.11. You can implement efficient high-level OpenMP by having a good understanding of the memory bounds of all loops in your application, enabling the use of profiling tools, and methodically working through the following steps. We suggest and show an implementation strategy that is incremental, methodical, and can provide a successful, smooth transition to a high-level OpenMP implementation. Steps to a high-level OpenMP implementation include

- Base implementation—Implement loop-level OpenMP

- Step 1: Reduce thread start up—Merge the parallel regions and join all the loop-level parallel constructs into larger parallel regions

- Step 2: Synchronization—Add `nowait` clauses to `for` loops, where synchronization is not needed, and calculate and manually partition the loops across the threads, which allows for removal of barriers and required synchronization.

- Step 3: Optimize—Make arrays and variables private to each thread when possible.

- Step 4: Code correctness—Check thoroughly for race conditions (after every step).

Figures 7.9 and 7.10 show the pseudocode corresponding to the previous four steps, starting with a typical loop-level implementation using `omp` `parallel` `do` pragmas and transitioning to more efficient high-level parallelism.

**Figure 7.9 High-level OpenMP starts with a loop-level OpenMP implementation and merges parallel regions together to reduce the cost of thread spawning. We use the animal images to represent where the changes are made and the relative speed of the actual implementation. The conventional loop level OpenMP shown with the turtle is faster, but there is overhead with each** **`parallel`** **`do`** **that limits speedup. The dog represents the relative gain in speed from merging parallel regions.**

**Figure 7.10 The next steps for high-level OpenMP add** **`nowait`** **clauses to** **`do`** **or** **`for`** **loops, which reduce synchronization costs. Then we calculate the loop bounds ourselves and explicitly use these in the loops to avoid even more synchronization. Here, the cheetah and the hawk identify the changes made in both implementations. The hawk (on the right) is faster than the cheetah (on the left) as the overhead of the OpenMP is reduced.**

In our steps to a high-level OpenMP implementation, the thread start-up time is reduced in the first step of high-level OpenMP. The entire code is placed in a single parallel region in order to minimize the overhead of forking and joining. In high-level OpenMP, threads are generated by the `parallel` directive once, at the beginning of the execution of the program. Unused threads do not die but remain dormant when running through a serial portion. To guarantee this, the serial portion is executed by the main thread, enabling few to no changes in the serial portion of the code. Once the program finishes running through the serial portion or starts a parallel region again, the same threads forked at the beginning of the program are invoked or reused.

Step 2 addresses the synchronization added to every `for` loop in OpenMP by default. The easiest way to reduce synchronization cost is to add `nowait` clauses to all loops where it is possible, while maintaining correctness. A further step is to explicitly divide the work among threads. The typical code for explicitly dividing the work for C is shown here. (The Fortran equivalent accounting for arrays starting at 1 is shown in figure 7.10.)

> `tbegin = N *  threadID   /nthreads`  
> `tend   = N * (threadID+1)/nthreads`

The impact of the manual partitioning of the arrays is that it reduces cache thrashing and race conditions by not allowing threads to share the same space in memory.

Step 3, optimization, means that we explicitly state whether certain variables are shared or private. By giving the threads a specific space in memory, the compiler (and programmer) can forgo guessing about the state of the variables. This can be done by applying the variable scoping rules from figure 7.7. Furthermore, compilers cannot properly parallelize loops that include complex loop-carried dependencies and loops that are not in canonical form. High-level OpenMP helps the compiler by being more explicit about the thread scoping of variables, thus allowing complex loops to be parallelized. This leads into the last part of this step for the high-level OpenMP approach. Arrays will be partitioned across the threads. Explicit partitioning of the arrays guarantees that a thread only touches memory assigned to it and allows us to start fixing memory locality issues.

And in the last step, code correctness, it is important to use the tools listed in section 7.9 to detect and fix race conditions. In the next section, we will show you the process of implementing the steps we described. The programs found in the GitHub source for this chapter will prove to be useful in following along with the stepwise process.

***7.6.2 Example of implementing high-level OpenMP***

You can complete a full implementation of high-level OpenMP in a series of steps. You should first look at where the bottleneck(s) of the code are in your application, in addition to finding the most compute-intensive loop in the code. You can then find the innermost level loop of the code and add the standard loop-based OpenMP directives. The scoping of the variables in the most intensive loops and inner loops needs to be understood, referring to figure 7.7 for guidance.

In step 1, you should focus on reducing the thread start-up costs. This is done in listing 7.15 by merging parallel regions to include the entire iteration loop in a single parallel region. We start slowly moving the OpenMP directives outward, expanding the parallel region. The original OpenMP pragmas on lines 49 and 57 can be merged into one parallel region between lines 44 to 70. The extent of the parallel region is defined by the curly braces on lines 45 and 70 thus only starting the parallel region once instead of 10,000 times.

**Listing 7.15 Merging parallel regions into a single parallel region**

> `HighLevelOpenMP_stencil/stencil_opt4.c`  
> `44 #pragma omp parallel >> Spawn threads >>           `❶  
> `45 {`  
> `46    int thread_id = omp_get_thread_num();`  
> `47    for (int iter = 0; iter < 10000; iter++){`  
> `48       if (thread_id ==0) cpu_timer_start(&tstart_flush);`  
> `49       #pragma omp for nowait                       `❷  
> `50       for (int l = 1; l < jmax*imax*4; l++){`  
> `51          flush[l] = 1.0;`  
> `52       }`  
> `53       if (thread_id == 0){`  
> `54          flush_time += cpu_timer_stop(tstart_flush);`  
> `55          cpu_timer_start(&tstart_stencil);`  
> `56       }`  
> `57       #pragma omp for >> Spawn threads >>          `❸  
> `58       for (int j = 1; j < jmax-1; j++){`  
> `59          for (int i = 1; i < imax-1; i++){`  
> `60             xnew[j][i]=(x[j][i] + x[j][i-1] + x[j][i+1] + x[j-1][i] + x[j+1][i])/5.0;`  
> `61          }`  
> `62       } Implied Barrier      Implied Barrier`  
> `63       if (thread_id == 0){`  
> `64          stencil_time += cpu_timer_stop(tstart_stencil);`  
> `65`  
> `66          SWAP_PTR(xnew, x, xtmp);`  
> `67          if (iter%1000 == 0) printf("Iter %d\n",iter);`  
> `68       }`  
> `69    }`  
> `70 } // end omp parallel`  
> `   Implied Barrier      Implied Barrier`

❶ Single OpenMP parallel region

❷ OpenMP for pragma with no synchronization barrier at end of loop

❸ Second OpenMP for pragma

Portions of the code that are required to be run in serial are placed in control of the main thread, allowing for the parallel region to be expanded across large portions of the code that encompass both serial and parallel regions. With each step, use the tools discussed in section 7.9 to make sure that the application still runs correctly.

In the second part of the implementation, you begin the transition to high-level OpenMP by carrying the main OpenMP parallel loop to the beginning of the program. After that, you can move on to calculating upper and lower loop bounds. Listing 7.16 (and the online examples in stencil_opt5.c and stencil_opt6.c) shows how you calculate the upper and lower bounds specific to the parallel region. Remember, arrays start at different points depending on language: Fortran starts at 1 and C starts at 0. Loops with the same upper and lower bound can use the same thread without having to recalculate the bounds.

> > > **NOTE** You must be careful to insert barriers in required locations to prevent race conditions. Much care also needs to be taken when placing these pragmas as too many could become detrimental to the overall performance of the application.

**Listing 7.16 Precalculating loop lower and upper bounds**

> `HighLevelOpenMP_stencil/stencil_opt6.c`  
> `29 #pragma omp parallel >> Spawn threads >>`  
> `30 {`  
> `31    int thread_id = omp_get_thread_num();`  
> `32    int nthreads = omp_get_num_threads();`  
> `33`  
> `34    int jltb = 1 + (jmax-2) * ( thread_id     ) / nthreads;     `❶  
> `35    int jutb = 1 + (jmax-2) * ( thread_id + 1 ) / nthreads;     `❶  
> `36`  
> `37    int ifltb = (jmax*imax*4) * ( thread_id     ) / nthreads;   `❶  
> `38    int ifutb = (jmax*imax*4) * ( thread_id + 1 ) / nthreads;   `❶  
> `39`  
> `40    int jltb0 = jltb;                                           `❶  
> `41    if (thread_id == 0) jltb0--;                                `❶  
> `42    int jutb0 = jutb;                                           `❶  
> `43    if (thread_id == nthreads-1) jutb0++;                       `❶  
> `44`  
> `45    int kmin = MAX(jmax/2-5,jltb);                              `❶  
> `46    int kmax = MIN(jmax/2+5,jutb);                              `❶  
> `47`  
> `48    if (thread_id == 0) cpu_timer_start(&tstart_init);          `❷  
> `49    for (int j = jltb0; j < jutb0; j++){                        `❸  
> `50       for (int i = 0; i < imax; i++){`  
> `51          xnew[j][i] = 0.0;`  
> `52          x[j][i] = 5.0;`  
> `53       }`  
> `54    }`  
> `55`  
> `56    for (int j = kmin; j < kmax; j++){                          `❸  
> `57       for (int i = imax/2 - 5; i < imax/2 -1; i++){`  
> `58          x[j][i] = 400.0;`  
> `59       }`  
> `60    }`  
> `61    #pragma omp barrier                                         `❹  
> `      Explicit Barrier      Explicit Barrier`  
> `62    if (thread_id == 0) init_time += cpu_timer_stop(tstart_init);`  
> `63`  
> `64    for (int iter = 0; iter < 10000; iter++){`  
> `65       if (thread_id == 0) cpu_timer_start(&tstart_flush);      `❷  
> `66       for (int l = ifltb; l < ifutb; l++){`  
> `67          flush[l] = 1.0;`  
> `68       }`  
> `69       if (thread_id == 0){                                     `❷  
> `70          flush_time += cpu_timer_stop(tstart_flush);           `❷  
> `71          cpu_timer_start(&tstart_stencil);                     `❷  
> `72       }                                                        `❷  
> `73       for (int j = jltb; j < jutb; j++){                       `❸  
> `74          for (int i = 1; i < imax-1; i++){`  
> `75             xnew[j][i]=( x[j][i] + x[j][i-1] + x[j][i+1] + x[j-1][i] + x[j+1][i] )/5.0;`  
> `76          }`  
> `77       }`  
> `78       #pragma omp barrier                                      `❹  
> `         Explicit Barrier      Explicit Barrier`  
> `79       if (thread_id == 0){                                     `❷  
> `80          stencil_time += cpu_timer_stop(tstart_stencil);       `❷  
> `81`  
> `82          SWAP_PTR(xnew, x, xtmp);                              `❷  
> `83          if (iter%1000 == 0) printf("Iter %d\n",iter);         `❷  
> `84       }                                                        `❷  
> `85       #pragma omp barrier                                      `❹  
> `         Explicit Barrier      Explicit Barrier`  
> `86    }`  
> `87 } // end omp parallel`  
> `    Implied Barrier      Implied Barrier`

❶ Computes loop bounds

❷ Uses thread ID instead of OpenMP masked pragma to eliminate synchronization

❸ Uses manually calculated loop bounds

❹ Barrier to synchronize with other threads

To obtain a correct answer, it is crucial to start from the innermost loop and have an understanding of which variables need to stay private or become shared among the threads. As you start enlarging the parallel region, serial portions of the code will be placed into a masked region. This region has one thread that does all the work, while the other threads remain alive but dormant. Zero or only a few changes are required when placing serial portions of the code into a main thread. Once the program finishes running through the serial region or gets into a parallel region, the past dormant threads start working again to parallelize the current loop.

For the final step, comparing results for steps along the way to a high-level OpenMP implementation, in listings 7.14 and 7.15 and the provided online stencil examples, you can see that the number of pragmas is greatly reduced while also yielding better performance (figure 7.11).

**Figure 7.11 Optimizing the OpenMP pragmas both reduces the number of pragmas required and improves the performance of the stencil kernel.**

***7.7 Hybrid threading and vectorization with OpenMP***

In this section, we will combine topics from chapter 6 with what you have learned in this chapter. This combination yields to better parallelization and utilizes the vector processor. The OpenMP threaded loop can be combined with the vectorized loop by adding the `simd` clause to the `parallel` `for` as in `#pragma` `omp` `parallel` `for` `simd`. The following listing shows this for the stream triad.

**Listing 7.17 Loop-level OpenMP threading and vectorization of the stream triad**

> `StreamTriad/stream_triad_opt3.c`  
> `1 #include <stdio.h>`  
> `2 #include <time.h>`  
> `3 #include <omp.h>`  
> `4 #include "timer.h"`  
> `5`  
> `6 #define NTIMES 16`  
> `7 #define STREAM_ARRAY_SIZE 80000000                       `❶  
> `8 static double a[STREAM_ARRAY_SIZE], b[STREAM_ARRAY_SIZE], c[STREAM_ARRAY_SIZE];`  
> `9`  
> `10 int main(int argc, char *argv[]){`  
> `11    #pragma omp parallel >> Spawn threads >>`  
> `12       if (omp_get_thread_num() == 0)`  
> `13          printf("Running with %d thread(s)\n",omp_get_num_threads());`  
> `       Implied Barrier      Implied Barrier`  
> `14`  
> `15    struct timeval tstart;`  
> `16    double scalar = 3.0, time_sum = 0.0;                  `❷  
> `17    #pragma omp parallel for simd >> Spawn threads >>`  
> `18    for (int i=0; i<STREAM_ARRAY_SIZE; i++) {             `❷  
> `19       a[i] = 1.0;                                        `❷  
> `20       b[i] = 2.0;                                        `❷  
> `21    }                                                     `❷  
> `      Implied Barrier      Implied Barrier`  
> `22    for (int k=0; k<NTIMES; k++){`  
> `23       cpu_timer_start(&tstart);`  
> `24       #pragma omp parallel for simd >> Spawn threads >>`  
> `25       for (int i=0; i<STREAM_ARRAY_SIZE; i++){           `❸  
> `26          c[i] = a[i] + scalar*b[i];                      `❸  
> `27       }                                                  `❸  
> `         Implied Barrier      Implied Barrier`  
> `28       time_sum += cpu_timer_stop(tstart);`  
> `29       c[1]=c[2];                                         `❹  
> `30    }`  
> `31`  
> `32    printf("Average runtime is %lf msecs\n", time_sum/NTIMES);`  
> `33}`

❶ Large enough to force into main memory

❷ Initializes data and arrays

❸ Stream triad loop

❹ Keeps the compiler from optimizing out the loop

The hybrid implementation of the stencil example with both threading and vectorization puts the `for` pragma on the outer loop and the `simd` pragma on the inner loop as the following listing shows. Both the threaded and the vectorized loops work best with loops over large arrays as would usually be the case for the stencil example.

**Listing 7.18 Stencil example with both threading and vectorization**

> `HybridOpenMP_stencil/stencil_hybrid.c`  
> `26 #pragma omp parallel >> Spawn threads >>`  
> `27 {`  
> `28    int thread_id = omp_get_thread_num();`  
> `29    if (thread_id == 0) cpu_timer_start(&tstart_init);`  
> `30    #pragma omp for`  
> `31    for (int j = 0; j < jmax; j++){`  
> `32       #ifdef OMP_SIMD`  
> `33       #pragma omp simd                 `❶  
> `34       #endif`  
> `35       for (int i = 0; i < imax; i++){`  
> `36          xnew[j][i] = 0.0;`  
> `37          x[j][i] = 5.0;`  
> `38       }`  
> `39    } Implied Barrier      Implied Barrier`  
> `40`  
> `41    #pragma omp for`  
> `42    for (int j = jmax/2 - 5; j < jmax/2 + 5; j++){`  
> `43       for (int i = imax/2 - 5; i < imax/2 -1; i++){`  
> `44          x[j][i] = 400.0;`  
> `45       }`  
> `46    } Implied Barrier      Implied Barrier`  
> `47    if (thread_id == 0) init_time += cpu_timer_stop(tstart_init);`  
> `48`  
> `49    for (int iter = 0; iter < 10000; iter++){`  
> `50       if (thread_id ==0) cpu_timer_start(&tstart_flush);`  
> `51       #ifdef OMP_SIMD`  
> `52       #pragma omp for simd nowait      `❷  
> `53       #else`  
> `54       #pragma omp for nowait`  
> `55       #endif`  
> `56       for (int l = 1; l < jmax*imax*10; l++){`  
> `57          flush[l] = 1.0;`  
> `58       }`  
> `59       if (thread_id == 0){`  
> `60          flush_time += cpu_timer_stop(tstart_flush);`  
> `61          cpu_timer_start(&tstart_stencil);`  
> `62       }`  
> `63       #pragma omp for`  
> `64       for (int j = 1; j < jmax-1; j++){`  
> `65          #ifdef OMP_SIMD`  
> `66          #pragma omp simd              `❶  
> `67          #endif`  
> `68          for (int i = 1; i < imax-1; i++){`  
> `69             xnew[j][i]=(x[j][i] + x[j][i-1] + x[j][i+1] +`  
> `                                     x[j-1][i] + x[j+1][i])/5.0;`  
> `70          }`  
> `71       } Implied Barrier      Implied Barrier`  
> `72       if (thread_id == 0){`  
> `73          stencil_time += cpu_timer_stop(tstart_stencil);`  
> `74`  
> `75          SWAP_PTR(xnew, x, xtmp);`  
> `76          if (iter%1000 == 0) printf("Iter %d\n",iter);`  
> `77       }`  
> `78       #pragma omp barrier`  
> `79    }`  
> `80 } // end omp parallel`  
> `   Implied Barrier      Implied Barrier `

❶ Adds OpenMP SIMD pragma for inner loops

❷ Adds additional OpenMP SIMD pragma to for pragma on single loop

For the GCC compiler, the results with and without vectorization show a significant speedup with vectorization:

> `4 threads, GCC 8.2 compiler, Skylake Gold 6152`  
> `Threads only:      Timing init 0.006630 flush 17.110755 stencil 17.374676 total 34.499799`  
> `Threads & vectors: Timing init 0.004374 flush 17.498293 stencil 13.943251 total 31.454906`

***7.8 Advanced examples using OpenMP***

The examples shown so far have been simple loops over a set of data with relatively few complications. In this section, we show you how to handle three advanced examples that require more effort:

- Split-direction, two-step stencil—Advanced handling for thread scoping of variables

- Kahan summation—A more complex reduction loop

- Prefix scan—Explicitly handling partitioning work among threads

The examples in this section reveal the various ways to handle more difficult situations and give you a deeper understanding of OpenMP.

***7.8.1 Stencil example with a separate pass for the x and y directions***

Here we will look at the potential difficulties that arise when implementing OpenMP for a split-direction, two-step stencil operator where a separate pass is made for each spatial direction. Stencils are building-blocks for numerical scientific applications and used to calculate dynamic solutions to partial differential equations.

In a two-step stencil, where values are calculated on the faces, data arrays have different data-sharing requirements. Figure 7.12 represents such a stencil with 2D-face data arrays. Furthermore, it is common that one of the dimensions of these 2D arrays needs to be shared among all the threads or processes. The x-face data is simpler to deal with because it is aligned with the thread data decomposition, but we don’t need the full x-face array on every thread. The y-face data has a different problem because the data is across threads, necessitating sharing of the y-face 2D array. High-level OpenMP allows for a quick privatization of the dimension needed. Figure 7.12 shows how certain dimensions of a matrix can be kept either private, shared, or both.

The first touch principle of most kernels (defined in section 7.1.1) says that memory will most likely be local to the thread (except at the edges between threads on page boundaries). We can improve the memory locality by making the array sections completely private to the thread where possible, such as the x-face data. Due to the increasing number of processors, increasing the data locality is essential in minimizing the increasing speed gap between processors and memory. The following listing shows a serial implementation to begin with.

**Figure 7.12 The x face of a stencil aligned with the threads needs private storage for each thread. The pointer should be on the stack, and each thread should have a different pointer. The y face needs to share the data, so we define one pointer in the static data region where both threads can access it.**

**Listing 7.19 Split-direction stencil operator**

> `SplitStencil/SplitStencil.c`  
> `58 void SplitStencil(double **a, int imax, int jmax)`  
> `59 {`  
> `60    double** xface = malloc2D(jmax, imax);                    `❶  
> `61    double** yface = malloc2D(jmax, imax);                    `❶  
> `62    for (int j = 1; j < jmax-1; j++){                         `❷  
> `63       for (int i = 0; i < imax-1; i++){                      `❷  
> `64          xface[j][i] = (a[j][i+1]+a[j][i])/2.0;              `❷  
> `65       }                                                      `❷  
> `66    }                                                         `❷  
> `67    for (int j = 0; j < jmax-1; j++){                         `❸  
> `68       for (int i = 1; i < imax-1; i++){                      `❸  
> `69          yface[j][i] = (a[j+1][i]+a[j][i])/2.0;              `❸  
> `70       }                                                      `❸  
> `71    }                                                         `❸  
> `72    for (int j = 1; j < jmax-1; j++){                         `❹  
> `73       for (int i = 1; i < imax-1; i++){                      `❹  
> `74          a[j][i] = (a[j][i]+xface[j][i]+xface[j][i-1]+`  
> `75                             yface[j][i]+yface[j-1][i])/5.0;  `❹  
> `76       }                                                      `❹  
> `77    }                                                         `❹  
> `78    free(xface);`  
> `79    free(yface);`  
> `80 }`

❶ Calculates values on x and y faces of cells

❷ x-face calculation requires only adjacent cells in the x direction.

❸ y-face calculation requires adjacent cells in the y direction.

❹ Adds in contributions from all the faces of the cell

When using OpenMP with the stencil operator, you must determine whether the memory for each thread needs to be private or shared. In listing 7.18 (previously), the memory for the x-direction can be all private, allowing for faster calculations. In the y-direction (figure 7.12), the stencil requires access to the adjacent thread’s data; therefore, this data must be shared among the threads. This leads us to the implementation shown in the following listing.

**Listing 7.20 Split-direction stencil operator with OpenMP**

> `SplitStencil/SplitStencil_opt1.c`  
> `86 void SplitStencil(double **a, int imax, int jmax)`  
> `87 {`  
> `88    int thread_id = omp_get_thread_num();`  
> `89    int nthreads = omp_get_num_threads();`  
> `90`  
> `91    int jltb = 1 + (jmax-2) * ( thread_id     ) / nthreads;          `❶  
> `92    int jutb = 1 + (jmax-2) * ( thread_id + 1 ) / nthreads;          `❶  
> `93`  
> `94    int jfltb = jltb;                                                `❷  
> `95    int jfutb = jutb;                                                `❷  
> `96    if (thread_id == 0) jfltb--;                                     `❷  
> `97`  
> `98    double** xface = (double **)malloc2D(jutb-jltb, imax-1);         `❸  
> `99    static double** yface;                                           `❹  
> `100    if (thread_id == 0) yface = (double **)malloc2D(jmax+2, imax);   `❺  
> `101 #pragma omp barrier                                                 `❻  
> `       Explicit Barrier      Explicit Barrier`  
> `102    for (int j = jltb; j < jutb; j++){                               `❼  
> `103       for (int i = 0; i < imax-1; i++){                             `❼  
> `104          xface[j-jltb][i] = (a[j][i+1]+a[j][i])/2.0;                `❼  
> `105       }                                                             `❼  
> `106    }                                                                `❼  
> `107    for (int j = jfltb; j < jfutb; j++){                             `❽  
> `108       for (int i = 1; i < imax-1; i++){                             `❽  
> `109          yface[j][i] = (a[j+1][i]+a[j][i])/2.0;                     `❽  
> `110       }                                                             `❽  
> `111    }                                                                `❽  
> `112 #pragma omp barrier                                                 `❾  
> `       Explicit Barrier      Explicit Barrier`  
> `113    for (int j = jltb; j < jutb; j++){                               `❿  
> `114       for (int i = 1; i < imax-1; i++){                             `❿  
> `115          a[j][i] = (a[j][i]+xface[j-jltb][i]+xface[j-jltb][i-1]+    `❿  
> `116                             yface[j][i]+yface[j-1][i])/5.0;         `❿  
> `117       }                                                             `❿  
> `118    }                                                                `❿  
> `119    free(xface);                                                     `⓫  
> `120 #pragma omp barrier                                                 `⓬  
> `       Explicit Barrier      Explicit Barrier`  
> `121    if (thread_id == 0) free(yface);                                 `⓭  
> `122 }`

❶ Manually calculates distribution of data across threads

❷ The y faces have one less data value to distribute.

❸ Allocates a private portion of the x-face data for each thread

❹ Declares the y-face data pointer as static so it has shared scope.

❺ Allocates one version of the y-face array to be shared across threads

❻ Inserts an OpenMP barrier so that all threads have the allocated memory

❼ Does the local x-face calculation on each thread

❽ The y-face calculation has a j+1 and thus needs a shared array.

❾ We need an OpenMP synchronization because the next loop uses an adjacent thread work.

❿ Combines the work from the previous x-face and y-face loops into a new cell value

⓫ Frees local x-face array for each thread

⓬ A barrier ensures all threads are done with the shared y-face array.

⓭ Frees the y-face array on only one processor

To define the memory on the stack as shown in the x-direction, we need a pointer to a pointer to a double (`double` `**xface`) so that the pointer is on the stack and private to each thread. Then we allocate the memory using a custom 2D `malloc` call at line 98 in listing 7.20. We only need enough memory for each thread, so we compute the thread bounds in lines 91 and 92 and use these in the 2D `malloc` call. The memory is allocated from the heap and can be shared, but each thread only has its own pointer; therefore, each thread can’t access the other threads’ memory.

Rather than allocating memory from the heap, we could have used the automatic allocation, such as `double` `xface[3][6]`, where the memory is automatically allocated on the stack. The compiler automatically sees this declaration and pushes the memory space onto the stack. In cases where the arrays are large, the compiler might move the memory requirement to the heap. Each compiler has a different threshold on deciding whether to place memory on the heap or on the stack. If the compiler moves the memory to the heap, only one thread has the pointer to this location. In effect, it is private, even though it is in shared memory space.

For the y-faces, we define a static pointer to a pointer (`static` `double` `**yface`), where all threads can access the same pointer. In this case, only one thread needs to do this memory allocation, and all remaining threads can access this pointer and the memory itself. For this example, you can use figure 7.7 to see the different options of making the memory shared. In this case, you would go to the Parallel Region -\> C Routine and pick one of the file scope variables, `extern` or `static`, to make the pointer shared among the threads. It is easy to get something wrong such as in the variable scope, the memory allocation, or the synchronization. For example, what happens if we just define a regular `double` `**yfaces` pointer. Now each thread has its own private pointer and only one of these gets memory allocated. The pointer for the second thread would not point to anything, generating an error when it is used.

Figure 7.13 shows the performance for running the threaded version of the code on the Skylake Gold processor. For a small number of threads, we get a super-linear speedup before falling off at above eight threads. Super-linear speedup happens on occasion because the cache performance improves as the data is partitioned across threads or processors.

**Figure 7.13 The threaded version of the split stencil has a super-linear speedup for two to eight threads.**

> > > **DEFINITION** Super-linear speedup is performance that’s better than the ideal scaling curve for strong scaling. This can happen because the smaller array sizes fit into a higher level of the cache, resulting in better cache performance.

***7.8.2 Kahan summation implementation with OpenMP threading***

For the enhanced-precision Kahan summation algorithm, introduced in section 5.7, we cannot use a pragma to get the compiler to generate a multi-threaded implementation because of the loop-carried dependencies. Therefore, we’ll follow a similar algorithm as we used in the vectorized implementation in section 6.3.4. We first sum up the values on each thread in the first phase of the calculation. Then we sum the values across the threads to get the final sum as the following listing shows.

**Listing 7.21 An OpenMP implementation of the Kahan summation**

> `GlobalSums/kahan_sum.c`  
> `1 #include <stdlib.h>`  
> `2 #include <omp.h>`  
> `3`  
> `4 double do_kahan_sum(double* restrict var, long ncells)`  
> `5 {`  
> `6    struct esum_type{`  
> `7       double sum;`  
> `8       double correction;`  
> `9    };`  
> `10`  
> `11    int nthreads = 1;                                         `❶  
> `12    int thread_id   = 0;                                      `❶  
> `13 #ifdef _OPENMP`  
> `14    nthreads = omp_get_num_threads();`  
> `15    thread_id = omp_get_thread_num();`  
> `16 #endif`  
> `17`  
> `18    struct esum_type local;`  
> `19    local.sum = 0.0;`  
> `20    local.correction = 0.0;`  
> `21`  
> `22    int tbegin = ncells * ( thread_id     ) / nthreads;       `❷  
> `23    int tend   = ncells * ( thread_id + 1 ) / nthreads;       `❷  
> `24`  
> `25    for (long i = tbegin; i < tend; i++) {`  
> `26       double corrected_next_term = var[i] + local.correction;`  
> `27       double new_sum             = local.sum + local.correction;`  
> `28       local.correction   = corrected_next_term - (new_sum - local.sum);`  
> `29       local.sum          = new_sum;`  
> `30    }`  
> `31`  
> `32    static struct esum_type *thread;                          `❸  
> `33    static double sum;                                        `❸  
> `34`  
> `35 #ifdef _OPENMP                                               `❹  
> `36 #pragma omp masked`  
> `37    thread = malloc(nthreads*sizeof(struct esum_type));       `❺  
> `38 #pragma omp barrier`  
> `      Explicit Barrier      Explicit Barrier`  
> `39`  
> `40    thread[thread_id].sum = local.sum;                        `❻  
> `41    thread[thread_id].correction = local.correction;          `❻  
> `42`  
> `43 #pragma omp barrier                                          `❼  
> `      Explicit Barrier      Explicit Barrier`  
> `44`  
> `45    static struct esum_type global;`  
> `46 #pragma omp masked                                           `❽  
> `47    {`  
> `48       global.sum = 0.0;`  
> `49       global.correction = 0.0;`  
> `50       for ( int i = 0 ; i < nthreads ; i ++ ) {`  
> `51          double corrected_next_term = thread[i].sum +`  
> `52                 thread[i].correction + global.correction;`  
> `53          double new_sum    = global.sum + global.correction;`  
> `54          global.correction = corrected_next_term -`  
> `                              (new_sum - global.sum);`  
> `55          global.sum = new_sum;`  
> `56    }`  
> `57`  
> `58       sum = global.sum + global.correction;`  
> `59       free(thread);`  
> `60    } // end omp masked`  
> `61 #pragma omp barrier`  
> `      Explicit Barrier      Explicit Barrier`  
> `62 #else`  
> `63    sum = local.sum + local.correction;`  
> `64 #endif`  
> `65`  
> `66    return(sum);`  
> `67 }`

❶ Gets the total number of threads and thread_id

❷ Computes the range for which this thread is responsible

❸ Puts the variables in shared memory

❹ Defines the compiler variable \_OPENMP when using OpenMP

❺ Allocates one thread in shared memory

❻ Stores the summation of each thread in array

❼ Waits until all threads get here and then sums across threads

❽ Uses a single thread to compute the beginning offset for each thread

***7.8.3 Threaded implementation of the prefix scan algorithm***

In this section, we look at the threaded implementation of the prefix scan operation. The prefix scan operation, introduced in section 5.6, is important for algorithms with irregular data. This is because a count to determine the starting location for ranks or threads allows the rest of the calculation to be done in parallel. As discussed in that section, the prefix scan can also be done in parallel, yielding another parallelization benefit. The implementation process has three phases:

- All threads—Calculates a prefix scan for each thread’s portion of the data

- Single thread—Calculates the starting offset for each thread’s data

- All threads—Applies the new thread offset across all the data for each thread

The implementation in listing 7.22 works for a serial application and when called from within an OpenMP parallel region. This has the benefit that you can use the code in the listing for both serial and threaded cases, reducing the code duplication for this operation.

**Listing 7.22 An OpenMP implementation of the prefix scan**

> `PrefixScan/PrefixScan.c`  
> `1 void PrefixScan (int *input, int *output, int length)`  
> `2 { `  
> `3    int nthreads = 1;                                     `❶  
> `4    int thread_id   = 0;                                  `❶  
> `5 #ifdef _OPENMP`  
> `6    nthreads = omp_get_num_threads();                     `❶  
> `7    thread_id = omp_get_thread_num();                     `❶  
> `8 #endif`  
> `9  `  
> `10    int tbegin = length * ( thread_id     ) / nthreads;   `❷  
> `11    int tend   = length * ( thread_id + 1 ) / nthreads;   `❷  
> `12  `  
> `13    if ( tbegin < tend ) {                                `❸  
> `14        output[tbegin] = 0;                               `❹  
> `15        for ( int i = tbegin + 1 ; i < tend ; i++ ) {     `❹  
> `16           output[i] = output[i-1] + input[i-1];          `❹  
> `17        }`  
> `18    }`  
> `19    if (nthreads == 1) return;                            `❺  
> `20  `  
> `21 #ifdef _OPENMP`  
> `22 #pragma omp barrier                                      `❻  
> `      Explicit Barrier      Explicit Barrier`  
> `23  `  
> `24    if (thread_id == 0) {                                 `❼  
> `25       for ( int i = 1 ; i < nthreads ; i ++ ) {`  
> `26          int ibegin = length * ( i - 1 ) / nthreads;`  
> `27          int iend   = length * ( i     ) / nthreads;`  
> `28     `  
> `29          if ( ibegin < iend )`  
> `30             output[iend] = output[ibegin] + input[iend-1];`  
> `31     `  
> `32          if ( ibegin < iend - 1 )`  
> `33             output[iend] += output[iend-1];`  
> `34       }`  
> `35    }`  
> `36 #pragma omp barrier                                      `❽  
> `      Explicit Barrier      Explicit Barrier`  
> `37`  
> `38 #pragma omp simd                                         `❾  
> `39    for ( int i = tbegin + 1 ; i < tend ; i++ ) {         `❿  
> `40       output[i] += output[tbegin];                       `❿  
> `41    }                                                     `❿  
> `42 #endif`  
> `43}`

❶ Gets the total number of threads and thread_id

❷ Computes the range for which this thread is responsible

❸ Only performs this operation if there is a positive number of entries.

❹ Does an exclusive scan for each thread

❺ For multiple threads only, do the adjustment to prefix scan for the beginning value for each thread

❻ Waits until all threads get here

❼ Uses the main thread to compute the beginning offset for each thread

❽ Ends calculation on main thread with barrier

❾ Starts all threads again

❿ Applies the offset to the range for this thread

This algorithm should theoretically scale as

> `Parallel_timer = 2 * serial_time/nthreads`

The performance on the Skylake Gold 6152 architecture peaks at about 44 threads, 9.4 times faster than the serial version.

***7.9 Threading tools essential for robust implementations***

Developing a robust OpenMP implementation is difficult without using specialized tools for detecting thread race conditions and performance bottlenecks. The use of tools becomes much more important as you try to get a higher performance OpenMP implementation. There are both commercial and openly available tools. The typical tool list when integrating advanced implementations of OpenMP in your application includes:

- Valgrind—A memory tool introduced in section 2.1.3. It also works with OpenMP and helps in finding uninitialized memory or out-of-bounds accesses in threads.

- Call graph—The cachegrind tool produces a call graph and a profile of your application. A call graph determines which functions call other functions to clearly show the call hierarchy and code path. An example of the cachegrind tool was presented in section 3.3.1.

- Allinea/ARM Map—A high-level profiler to get an overall cost of thread starts and barriers (for OpenMP apps).

- Intel® Inspector—To detect thread race conditions (for OpenMP apps).

We described the first two tools in earlier chapters; they can be referred to there. In this section, we will discuss the last two tools as these relate more to an OpenMP application. These tools are needed to profile the bottlenecks and understand where they lie within your application and, thus, are essential in knowing where to best start changing your code in an efficient manner.

***7.9.1 Using Allinea/ARM MAP to get a quick high-level profile of your application***

One of the better tools to get a high-level application profile is Allinea/ARM MAP. Figure 7.14 shows a simplified view of its interface. For an OpenMP application, it shows the cost for thread starts and waits, highlights the application’s bottlenecks, and shows the usage of memory CPU floating point utilization. The profiler makes it easy to compare the gains made before and after code changes. Allinea/ARM MAP excels at producing a quick, high-level view of your application, but there are many other profilers that can be used. Some of these are reviewed in section 17.3.

**Figure 7.14 These are results from Allinea/ARM MAP showing the majority of the compute time on the highlighted line of code. We often use indicators like this to show us the location of bottlenecks.**

***7.9.2 Finding your thread race conditions with Intel® Inspector***

It is essential to find and eliminate thread race conditions in an OpenMP implementation to produce a robust, production-quality application. For this purpose, tools are essential because it is impossible for even the best programmer to catch all the thread race conditions. As the application begins to scale, memory errors occur more frequently and can cause an application to break. Catching these memory errors early on saves time and energy on future runs.

There are not many tools that are effective at finding thread race conditions. We show the use of one of these tools, the Intel® Inspector, to detect and pinpoint the location of these race conditions. Having tools to understand thread race conditions in memory is also useful when scaling to larger thread counts. Figure 7.15 provides a sample screenshot of Intel® Inspector.

**Figure 7.15 Intel® Inspector report showing detection of thread race conditions. Here the items listed as Data race under the Type heading on the panel to the upper left show all the places where there is currently a race condition.**

Before changes in the initial application are made, it is critical to complete regression testing. Ensuring correctness is crucial to the successful implementation of OpenMP threading. A correct OpenMP code cannot be implemented unless an application or a whole subroutine is in its proper working state. This also requires that the section of code that is being threaded with OpenMP must also be exercised in a regression test. Without being able to do regression testing, it becomes difficult to make steady progress. In summary, these tools, along with regression testing, create a better understanding of the dependencies, efficiency, and correctness in most applications.

***7.10 Example of a task-based support algorithm***

The task-based parallel strategy was first introduced in chapter 1 and illustrated in figure 1.25. Using a task-based approach, you can divide work into separate tasks that can then be parceled out to individual processes. Many algorithms are more naturally expressed in terms of a task-based approach. OpenMP has supported this type of approach since its version 3.0. In the subsequent standard releases, there have been further improvements to the task-based model. In this section we’ll show you a simple task-based algorithm to illustrate the techniques in OpenMP.

One of the approaches to a reproducible global sum is to sum up the values in a pairwise manner. The normal array approach requires the allocation of a working array and some complicated indexing logic. Using a task-based approach as in figure 7.16 avoids the need for a working array by recursively splitting the data in half in the downward sweep, until an array length of 1 is reached, and then summing up the pairs in the upward sweep.

**Figure 7.16 The task-based implementation recursively splits the array into half on the downward sweep. Once an array size of 1 occurs, the task sums pairs of data in the upward sweep.**

Listing 7.23 shows the code for the task-based approach. The spawning of the task needs to be done in a parallel region but by only one thread, leading to the nested blocks of pragmas in lines 8 to 14.

**Listing 7.23 A pair-wise summation using OpenMP tasks**

> `PairwiseSumByTask/PairwiseSumByTask.c`  
> `1 #include <omp.h>`  
> `2`  
> `3 double PairwiseSumBySubtask(double* restrict var, long nstart, long nend);`  
> `4`  
> `5 double PairwiseSumByTask(double* restrict var, long ncells)`  
> `6 {`  
> `7    double sum;`  
> `8    #pragma omp parallel >> Spawn threads >>                 `❶  
> `9    {`  
> `10       #pragma omp masked                                    `❷  
> `11       {`  
> `12          sum = PairwiseSumBySubtask(var, 0, ncells);        `❷  
> `13       }`  
> `14    } Implied Barrier      Implied Barrier`  
> `15    return(sum);`  
> `16 }`  
> `17`  
> `18 double PairwiseSumBySubtask(double* restrict var, long nstart, long nend)`  
> `19 {`  
> `20    long nsize = nend - nstart;`  
> `21    long nmid = nsize/2;                                     `❸  
> `22    double x,y;`  
> `23    if (nsize == 1){                                         `❹  
> `24       return(var[nstart]);                                  `❹  
> `25    }`  
> `26`  
> `27    #pragma omp task shared(x) mergeable final(nsize > 10)   `❺  
> `28    x = PairwiseSumBySubtask(var, nstart, nstart + nmid);    `❺  
> `29    #pragma omp task shared(y) mergeable final(nsize > 10)   `❺  
> `30    y = PairwiseSumBySubtask(var, nend - nmid, nend);        `❺  
> `31    #pragma omp taskwait                                     `❻  
> `32`  
> `33    return(x+y);                                             `❼  
> `34 }`

❶ Launches parallel region

❷ Starts main task on one thread

❸ Subdivides the array into two parts

❹ Initializes sum at leaf with single value from array

❺ Launches a pair of subtasks with half of the data for each

❻ Waits for two tasks to complete

❼ Sums the values from the two subtasks and returns to the calling thread

Getting good performance with a task-based algorithm takes a lot more tuning to prevent too many threads from being spawned and to keep granularity of the tasks reasonable. For some algorithms, task-based algorithms are a much more appropriate parallel strategy.

***7.11 Further explorations***

There are many materials on traditional thread-based OpenMP programming. With nearly every compiler supporting OpenMP, the best learning approach is to simply start adding OpenMP directives to your code. There are many training opportunities covering OpenMP, including the annual Supercomputing Conference held in November. For information, see [https://sc21.supercomputing.org/](https://sc19.supercomputing.org/). For those who are even more interested in OpenMP, there is an International Workshop on OpenMP held every year that covers the latest developments. For information, see [http://www .iwomp.org/](http://www.iwomp.org/).

***7.11.1 Additional reading***

Barbara Chapman is one of the leading writers and authorities on OpenMP. Her book is the standard reference for OpenMP programming, especially for the threading implementation in OpenMP as of 2008:

Barbara Chapman, Gabriele Jost, and Ruud Van Der Pas, Using OpenMP: portable shared memory parallel programming, vol. 10 (MIT Press, 2008).

There are many researchers working on developing more efficient techniques of implementing OpenMP, which has come to be called high-level OpenMP. Here is a link to slides going into more detail on high-level OpenMP:

Yuliana Zamora, “Effective OpenMP Implementations on Intel’s Knights Landing,” Los Alamos National Laboratory Technical Report LA-UR-16-26774, 2016. Available at: [https://www.osti.gov/biblio/1565920-effective-openmp-implementations-in tel-knights-landing.](https://www.osti.gov/biblio/1565920-effective-openmp-implementations-intel-knights-landing)

A good textbook on OpenMP and MPI is one written by Peter Pacheco. It has some good examples of OpenMP code:

Peter Pacheco, An introduction to parallel programming (Elsevier, 2011).

Blaise Barney at Lawrence Livermore National Laboratory has authored a well-written OpenMP reference that’s also available online:

Blaise Barney, OpenMP Tutorial, <https://computing.llnl.gov/tutorials/openMP/>

The OpenMP Architecture Review Board (ARB) maintains a website that is the authoritative location for all things OpenMP, from specifications to presentations and tutorials:

OpenMP Architecture Review Board, OpenMP, [https://www.openmp.org.](https://www.openmp.org)

For a deeper discussion on the difficulties with threading:

Edward A Lee, “The problem with threads.” Computer 39, no. 5 (2006): 33-42.

**7.11.2 Exercises**

1.  Convert the vector add example in listing 7.8 into a high-level OpenMP following the steps in section 7.2.2.

2.  Write a routine to get the maximum value in an array. Add an OpenMP pragma to add thread parallelism to the routine.

3.  Write a high-level OpenMP version of the reduction in the previous exercise.

We covered a substantial amount of material in this chapter. This solid foundation will help you in developing an effective OpenMP application.

**Summary**

- Loop-level implementations of OpenMP can be quick and easy to create.

- An efficient implementation of OpenMP can achieve promising application speed-up.

- Good first-touch implementations can often gain a 10-20% performance improvement.

- Understanding variable scope across threads is important in getting OpenMP code to work.

- High-level OpenMP can boost performance on current and upcoming many-core architectures.

- Threading and debugging tools are essential when implementing more complex versions of OpenMP.

- Some of the style guidelines that are suggested in this chapter include

- - Declaring variables where these are used so that they automatically become private, which is generally correct.

  - Modifying declarations to get the right threading scope for variables rather than using an extensive list in private and public clauses.

  - Avoiding the `critical` clause or other locking constructs where possible. Performance is generally impacted heavily by these constructs.

  - Reducing synchronization by adding `nowait` clauses to `for` loops and limiting the use of `#pragma` `omp` `barrier` to only where necessary.

  - Merging small parallel regions into fewer, larger parallel regions to reduce OpenMP overhead.

------------------------------------------------------------------------

^(**1.**) `#pragma` `omp` `masked` was `#pragma` `omp` `master`. With the release of OpenMP standard v 5.1 in Nov. 2020, the term “master” was changed to “masked” to address concerns that it is offensive to many in the technical community. We are strong advocates of inclusion and, thus, use the new syntax throughout this chapter. Readers are warned that compilers may take some time to implement the change. Note that the examples that accompany the chapter will use the older syntax until most compilers are updated.

^(**2.**) This is not the case under the Fortran 77 standard! But even with Fortran 77, some compilers such as the DEC Fortran compiler mandate that every variable in a routine have the `save` attribute, causing obscure bugs and portability problems. Knowing this, we could make sure we are compiling with the Fortran 90 standard and potentially fix the private scoping issue by initializing the array pointer, which causes it to be moved to the heap, making the variable shared.
