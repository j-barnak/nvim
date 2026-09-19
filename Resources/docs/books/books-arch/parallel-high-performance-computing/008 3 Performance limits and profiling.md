# 3 Performance limits and profiling

***3 Performance limits and profiling***

This chapter covers

- Understanding the limiting aspect of application performance
- Evaluating performance for the limiting hardware components
- Measuring the current performance of your application

Programmer resources are scarce. You need to target these resources so that they have the most impact. How do you do this if you don’t know the performance characteristics of your application and the hardware you plan to run on? That is what this chapter means to address. By measuring the performance of your hardware and your application, you can determine where it’s most effective to spend your development time.

> > > **NOTE** We encourage you to follow along with the exercises for this chapter. The exercises can be found at [https://github.com/EssentialsofParallel Computing/Chapter3](https://github.com/EssentialsofParallelComputing/Chapter3).

***3.1 Know your application’s potential performance limits***

Computational scientists still consider floating-point operations (flops) as the primary performance limit. While this might have been true years ago, the reality is that flops seldom limit performance in modern architectures. But limits can be for bandwidth or for latency. Bandwidth is the best rate at which data can be moved through a given path in the system. For bandwidth to be the limit, the code should use a streaming approach, where the memory usually needs to be contiguous and all the values used. When a streaming approach is not possible, latency is the more appropriate limit. Latency is the time required for the first byte or word of data to be transferred. The following shows some of the possible hardware performance limits:

- Flops (floating-point operations)

- Ops (operations) that include all types of computer instructions

- Memory bandwidth

- Memory latency

- Instruction queue (instruction cache)

- Networks

- Disk

We can break down all of these limitations into two major categories: speeds and feeds. Speeds are how fast operations can be done. It includes all types of computer operations. But to be able to do the operations, you must get the data there. This is where feeds come in. Feeds include the memory bandwidth through the cache hierarchy, as well as network and disk bandwidth. For applications that cannot get streaming behavior, the latency of memory, network and disk feed are more important. Latency times can be orders of magnitude slower than those for bandwidth. One of the biggest factors in whether applications are controlled by latency limits or streaming bandwidths is the quality of the programming. Organizing your data so that it can be consumed in a streaming pattern can yield dramatic speedups.

The relative performance of different hardware components is shown in figure 3.1. Let’s use the 1 word loaded per cycle and 1 flop per cycle marked by the large dot as our starting point. Most scalar arithmetic operations like addition, subtraction, and multiplication, can be done in 1 cycle. The division operation can take longer at 3-5 cycles. In some arithmetic mixes, 2 flops/cycle are possible with the fused multiply-add instruction. The number of arithmetic operations that can be done increases further with vector units and multi-core processors. Hardware advances, mostly through parallelism, greatly increase the flops/cycle.

**Figure 3.1 Feeds and speeds shown on a roofline plot. The conventional scalar CPU is close to the 1 word loaded per cycle and 1 flop per cycle indicated by the shaded circle. The multipliers for the increase in flops are due to the fused multiply-add instruction, vectorization, multiple cores, and hyperthreads. The relative speeds of memory movement are also shown. We’ll discuss the roofline plot more in section 3.2.4.**

Looking at the sloped memory limits, we see that the performance increase through a deeper hierarchy of caches means that memory accesses can only match the speedup of operations if the data is contained in the L1 cache, typically about 32 KiB. But if we only have that much data, we wouldn’t be so worried about the time it takes. We really want to operate on large amounts of data that can only be contained in main memory (DRAM) or even on the disk or network. The net result is that the floating-point capabilities of processors have increased far faster than memory bandwidth. This has led to many machine balances of the order of 50 flops capability for every 8-byte word loaded. To understand this impact on applications, we measure its arithmetic intensity.

- Arithmetic intensity—In an application, measures the number of flops executed per memory operations, where memory operations can be either in bytes or words (a word is 8 bytes for a double and 4 bytes for a single-precision value).

- Machine balance—Indicates for computing hardware the total number of flops that can be executed divided by the memory bandwidth.

Most applications have an arithmetic intensity close to 1 flop per word loaded, but there are also applications that have a higher arithmetic intensity. The classic example of a high arithmetic intensity application uses a dense matrix solver to solve a system of equations. The use of these solvers used to be much more common in applications than is true today. The Linpack benchmark uses the kernel from this operation to represent this class of applications. The arithmetic intensity for this benchmark is reported by Peise to be 62.5 flops/word (see reference in appendix A, Peise, 2017, pg. 201). This is sufficient for most systems to max out the floating-point capability. The heavy use of the Linpack benchmark for the top 500 ranking of the largest computing systems has become a leading reason for current machine designs that target a high flop-to-memory load ratio.

For many applications, even achieving the memory bandwidth limit can be difficult. Some understanding of the memory hierarchy and architecture is necessary to understand memory bandwidth. Multiple caches between memory and the CPU help hide the slower main memory (figure 3.5 in section 3.2.3) in the memory hierarchy. Data is transported up the memory hierarchy in chunks called cache lines. If memory is not accessed in a contiguous, predictable fashion, the full memory bandwidth is not achieved. Merely accessing data in columns for a 2D data structure that is stored in row order will stride across memory by the row length. This can result in as little as one value being used out of each cache line. A rough estimate of the memory bandwidth from this data access pattern is 1/8th of the stream bandwidth (1 out of every 8 cache values used). This can be generalized for other cases where more cache usage occurs by defining a non-contiguous bandwidth (B _(nc)) in terms of the percentage of cache used (U _(cache)) and the empirical bandwidth (B _(E)):

B_(nc) = U_(cache) × B _(E) = Average Percentage of Cache Used × Empirical Bandwidth

There are other possible performance limits. The instruction cache may not be able to load instructions fast enough to keep a processor core busy. Integer operations are also a more frequent limiter than commonly assumed, especially with higher dimensional arrays where the index calculations become more complex.

For applications that require significant network or disk operations (such as big data, distributed computing, or message passing), network and disk hardware limits can be the most serious concern. To get an idea of the magnitude of these device performance limitations, consider the rule of thumb that for the time taken for the first byte transferred over a high performance computer network, you can do over 1,000 flops on a single processor core. Standard mechanical disk systems are orders of magnitude slower for the first byte, which has led to the highly asynchronous, buffered operation of today’s filesystems and to the introduction of solid-state storage devices.

> **Example**

> Your image detection application has to process a lot of data. Right now it comes in over the network and is stored to disk for processing. Your team reviews the performance limits and decides to try and eliminate the storage to disk as an unnecessary intermediate operation. One of your team members suggests that you can do additional floating-point operations almost for free so the team should consider a more sophisticated algorithm. But you think that the limiting aspect of the wave simulation code is memory bandwidth. You add a task to the project plan to measure the performance and confirm your hunch.

***3.2 Determine your hardware capabilities: Benchmarking***

Once you have prepared your application and your test suites, you can begin characterizing the hardware that you are targeting for production runs. To do this, you need to develop a conceptual model for the hardware that allows you to understand its performance. Performance can be characterized by a number of metrics:

- The rate at which floating-point operations can be executed (FLOPs/s)

- The rate at which data can be moved between various levels of memory (GB/s)

- The rate at which energy is used by your application (Watts)

The conceptual models allow you to estimate the theoretical peak performance of various components of the compute hardware. The metrics you work with in these models, and those you aim to optimize, depend on what you and your team value in your application. To complement this conceptual model, you can also make empirical measurements on your target hardware. The empirical measurements are made with micro-benchmark applications. One example of a micro-benchmark is the STREAM Benchmark that is used for bandwidth-limited cases.

***3.2.1 Tools for gathering system characteristics***

In determining hardware performance, we use a mixture of theoretical and empirical measurements. Although complementary, the theoretical value provides an upper bound to performance, and the empirical measurement confirms what can be achieved in a simplified kernel in close to actual operating conditions.

It is surprisingly difficult to get hardware performance specifications. The explosion of processor models and the focus of marketing and media reviews for the broader public often obscure the technical details. Good resources for such include

- For Intel processors, <https://ark.intel.com>

- For AMD processors, <https://www.amd.com/en/products/specifications/processors>

One of the best tools for understanding the hardware you run is the lstopo program. It is bundled with the hwloc package that comes with nearly every MPI distribution. This command outputs a graphical view of the hardware on your system. Figure 3.2 shows the output for a Mac laptop. The output can be graphical or text-based. To get the picture in figure 3.2 currently requires a custom installation of hwloc and the cairo packages to enable the X11 interface. The text version works with the standard package manager installs. Linux and Unix versions of hwloc usually work as long as you can display an X11 window. A new command, `netloc, is being added to the hwloc package to display the network connections.`

**Figure 3.2 Hardware topology for a Mac laptop using the** **`lstopo`** **command**

To install cairo v1.16.0

1.  Download cairo from <https://www.cairographics.org/releases/>

2.  Configure it with the following commands:

> `./configure --with-x --prefix=/usr/local`  
> `make`  
> `make install`

To install hwloc v2.1.0a1-git

1.  Clone the hwloc package from Git: <https://github.com/open-mpi/hwloc.git>

2.  Configure it with the following commands:

> `./configure --prefix=/usr/local`  
> `make`  
> `make install`

Some other commands for probing hardware details are `lscpu` on Linux systems, `wmic` on Windows, and `sysctl` or `system_profiler` on Mac. The Linux `lscpu` command outputs a consolidated report of the information from the /proc/cpuinfo file. You can see the full information for every logical core by viewing /proc/cpuinfo directly. The information from the `lscpu` command and the /proc/cpuinfo file helps to determine the number of processors, the processor model, the cache sizes, and the clock frequency for the system. The flags contain important information on the vector instruction set for the chip. In figure 3.3, we see that the AVX2 and various forms of the SSE vector instruction set are available. We’ll discuss vector instruction sets more in chapter 6.

**Figure 3.3 Output from** **`lscpu`** **for a Linux desktop that shows a 4-core i5-6500 CPU @ 3.2 GHz with AVX2 instructions**

Obtaining information on the devices on the PCI bus can be helpful, particularly for identifying the number and type of the graphics processor. The `lspci` command reports all the devices (figure 3.4). From the output in the figure, we can see that there is one GPU and that it is an NVIDIA GeForce GTX 960.

**Figure 3.4 Output from the** **`lspci`** **command from a Linux desktop that shows an NVIDIA GeForce GTX 960 GPU.**

***3.2.2 Calculating theoretical maximum flops***

Let’s run through the numbers for a mid-2017 MacBook Pro laptop with an Intel Core i7-7920HQ processor. This is a 4-core processor running at a nominal frequency of 3.1 GHz with hyperthreading. With its turbo boost feature, it can run at 3.7 GHz when using four processors and up to 4.1 GHz when using a single processor. The theoretical maximum flops (F _(T)) can be calculated with

F _(T) = C _(v) × f _(c) × I_(c) = Virtual Cores × Clock Rate × Flops/Cycle

The number of cores includes the effects of hyperthreads that make the physical cores (C _(h)) appear to be a greater number of virtual or logical cores (C _(v)). Here we have two hyperthreads that make the virtual number of processors appear to be eight. The clock rate is the turbo boost rate when all the processors are engaged. For the processor, it is 3.7 GHz. Finally, the flops per cycle, or more generally instructions per cycle (I_(c)), includes the number of simultaneous operations that can be executed by the vector unit.

To determine the number of operations that can be performed, we take the vector width (VW) and divide by the word size in bits (W_(bits)). We also include the fused multiply-add (FMA) instruction as another factor of two operations per cycle. We refer to this as fused operations (F_(ops)) in the equation. For this specific processor, we get

I_(c) = VW/W_(bits) × F_(ops) = (256-bit Vector Unit/64 bits) × (2 FMA) = 8 Flops/Cycle

C _(v) = C _(h) × HT = (4 Hardware Cores × 2 Hyperthreads)

F _(T) = (8 Virtual Cores) × (3.7 GHz) × (8 Flops/Cycle) = 236.8 GFlops/s

***3.2.3 The memory hierarchy and theoretical memory bandwidth***

For most large computational problems, we can assume that there are large arrays that need to be loaded from main memory through the cache hierarchy (figure 3.5). The memory hierarchy has grown deeper over the years with the addition of more levels of cache to compensate for the increase in processing speed relative to the main memory access times.

**Figure 3.5 Memory hierarchy and access times. Memory is loaded into cache lines and stored at each level of the cache system for reuse.**

We can calculate the theoretical memory bandwidth of the main memory using the memory chips specifications. The general formula is

B_(T) = MTR × M_(c) × T_(w) × N_(s) = Data Transfer Rate × Memory Channels × Bytes Per Access × Sockets

Processors are installed in a socket on the motherboard. The motherboard is the main system board of the computer, and the socket is the location where the processor is inserted. Most motherboards are single-socket, where only one processor can be installed. Dual-socket motherboards are more common in high-performance computing systems. Two processors can be installed in a dual-socket motherboard, giving us more processing cores and more memory bandwidth.

The data or memory transfer rate (MTR) is usually given in millions of transfers per sec (MT/s). The double data rate (DDR) memory performs transfers at the top and bottom of the cycle for two transactions per cycle. This means that the memory bus clock rate is half of the transfer rate in MHz. The memory transfer width (T_(w)) is 64 bits and because there are 8 bits/byte, 8 bytes are transferred. There are two memory channels (M_(c)) on most desktop and laptop architectures. If you install memory in both memory channels, you will get better bandwidth, but this means you cannot simply buy another DRAM module and insert it. You will have to replace all the modules with larger modules.

For the 2017 MacBook Pro with LPDDR3-2133 memory and for two channels, the theoretical memory bandwidth (B_(T)) can be calculated from the memory transfer rate (MTR) of 2133 MT/s, the number of channels (M_(c)), and the number of sockets on the motherboard:

B_(T) = 2133 MT/s × 2 channels × 8 bytes × 1 socket = 34,128 MiB/s or 34.1 GiB/s

The achievable memory bandwidth is lower than the theoretical bandwidth due to the effects of the rest of the memory hierarchy. You’ll find complex theoretical models for estimating the effects of the memory hierarchy, but that is beyond what we want to consider in our simplified processor model. For this, we will turn to empirical measurements of bandwidth at the CPU.

***3.2.4 Empirical measurement of bandwidth and flops***

The empirical bandwidth is the measurement of the fastest rate that memory can be loaded from main memory into the processor. If a single byte of memory is requested, it takes 1 cycle to retrieve it from a CPU register. If it is not in the CPU register, it comes from the L1 cache. If it is not in the L1 cache, the L1 cache loads it from L2 and so on to main memory. If it goes all the way to main memory, for a single byte of memory, it can take around 400 clock cycles. This time required for the first byte of data from each level of memory is called the memory latency. Once the value is in a higher cache level, it can be retrieved faster until it gets evicted from that level of the cache. If all memory has to be loaded a byte at a time, this would be painfully slow. So when a byte of memory is loaded, a whole chunk of data (called a cache line) is loaded at the same time. If nearby values are subsequently accessed, these are then already in the higher cache levels.

The cache lines, cache sizes, and number of cache levels are sized to try to provide as much of the theoretical bandwidth of the main memory as possible. If we load contiguous data as fast as possible to make the best use of the caches, we get the CPU’s maximum possible data transfer rate. This maximum data transfer rate is called the memory bandwidth. To determine the memory bandwidth, we can measure the time for reading and writing a large array. From the following empirical measurements, the measured bandwidth is about 22 GiB/s. This measured bandwidth is what we’ll use in the simple performance models in the next chapter.

Two different methods are used for measuring the bandwidth: the STREAM Benchmark and the roofline model measured by the Empirical Roofline Toolkit. The STREAM Benchmark was created by John McCalpin around 1995 to support his argument that memory bandwidth is far more important than the peak floating-point capability. In comparison, the roofline model (see the figure in the sidebar entitled “Measuring bandwidth using the empirical Roofline Toolkit” and the discussion later in this section) integrates both the memory bandwidth limit and the peak flop rate into a single plot with regions that show each performance limit. The Empirical Roofline Toolkit was created by Lawrence Berkeley National Laboratory to measure and plot the roofline model.

The STREAM Benchmark measures the time to read and write a large array. For this, there are four variants, depending on the operations performed on the data by the CPU as it is being read: the copy, scale, add, and triad measurements. The copy does no floating-point work, the scale and add do one arithmetic operation, and the triad does two. These each give a slightly different measure of the maximum rate that data can be expected to be loaded from main memory when each data value is only used once. In this regime, the flop rate is limited by how fast memory can be loaded.

The following exercise shows how to use the STREAM Benchmark to measure bandwidth on a given CPU.

> **Exercise: Measuring bandwidth using the STREAM Benchmark**

> Jeff Hammond, a scientist at Intel, put the McCalpin STREAM Benchmark code into a Git repository for more convenience. We use his version in this example. To access the code

1.  Clone the image at <https://github.com/jeffhammond/STREAM.git>

2.  Edit the makefile and change the compile line to

> `-O3 -march=native -fstrict-aliasing -ftree-vectorize -fopenmp     -DSTREAM_ARRAY_SIZE=80000000 -DNTIMES=20`  
> `make ./stream_c.exe`

> Here are the results for the 2017 Mac Laptop:

> `Function    Best Rate MB/s  Avg time     Min time     Max time`  
> `Copy:           22086.5     0.060570     0.057954     0.062090`  
> `Scale:          16156.6     0.081041     0.079225     0.082322`  
> `Add:            16646.0     0.116622     0.115343     0.117515`  
> `Triad:          16605.8     0.117036     0.115622     0.118004`

> We can select the best bandwidth from one of the four measurements as our empirical value of maximum bandwidth.

If a calculation can reuse the data in cache, much higher flop rates are possible. If we assume that all data being operated on is in a CPU register or maybe the L1 cache, then the maximum flop rate is determined by the CPU’s clock frequency and how many flops it can do per cycle. This is the theoretical maximum flop rate calculated in the preceding example.

Now we can put these two together to create a plot of the roofline model. The roofline model has a vertical axis of flops per second and a horizontal axis of arithmetic intensity. For high arithmetic intensity, where there are a lot of flops compared to the data loaded, the theoretical maximum flop rate is the limit. This produces a horizontal line on the plot at the maximum flop rate. As the arithmetic intensity decreases, the time for the memory loads starts to dominate, and we no longer can reach the maximum theoretical flops. This then creates the sloped roof in the roofline model, where the achievable flop rate slopes down as the arithmetic intensity drops. The horizontal line on the right of the plot and the sloped line on the left produce the characteristic shape reminiscent of a roofline and what has become known as the roofline model or plot. You can determine the roofline plot for a CPU or even a GPU as shown in the following exercise.

> **Exercise: Measuring bandwidth using the empirical Roofline Toolkit**

> To prepare for this exercise, install either OpenMPI or MPICH to get a working MPI. Install gnuplot v4.2 and Python v3.0. On Macs, download the GCC compiler to replace the default compiler. These installs can be done using a package manager (brew on Mac and apt or synaptic on Ubuntu Linux).

1.  Clone the Roofline Toolkit from Git:

    > `git clone https://bitbucket.org/berkeleylab/cs-roofline-toolkit.git`

2.  Then type

    > `cd cs-roofline-toolkit/Empirical_Roofline_Tool-1.1.0`  
    > `cp Config/config.madonna.lbl.gov.01 Config/MacLaptop2017`

3.  Edit Config/MacLaptop2017. (The following figure shows the file for a 2017 Mac laptop.)

4.  Run `tests ./ert Config/MacLaptop2017.`

5.  View the Results.MacLaptop2017/Run.001/roofline.ps file.

>   

> **Config/MacLaptop2017**

> The following figure shows the roofline for the 2017 Mac laptop. The empirical measurement of the maximum flops is a little higher than we calculated analytically. This is probably due to a higher clock frequency for a short period of time. Trying different configuration parameters like turning off vectorization or running one process can help to determine whether you have the right hardware specifications. The sloped lines are the bandwidth limits at different arithmetic intensities. Because these are determined empirically, the labels for each slope might not be correct and extra lines may be present.

> From these two empirical measurements, we get a similar maximum bandwidth through the cache hierarchy of around 22 MB/s or about 65% of the theoretical bandwidth at the DRAM chips (22 GiB/s / 34.1 GiB/s).

>   

> **Roofline for 2017 Mac Laptop shows the maximum FLOPs as a horizontal line, and the maximum bandwidth from various cache and memory levels as sloped lines.**

***3.2.5 Calculating the machine balance between flops and bandwidth***

Now we can determine the machine balance. The machine balance is the flops divided by the memory bandwidth. We can calculate both a theoretical machine balance (MB_(T)) and an empirical machine balance (MB_(E)) like so:

MB_(T) = F_(T) / B_(T) = 236.8 GFlops/s / 34.1 GiB/s × (8 bytes/word) = 56 Flops/word

MB_(E) = F_(E) / B_(E) = 264.4 GFlops/s / 22 GiB/s × (8 bytes/word) = 96 Flops/word

In the roofline figure in the previous section, the machine balance is the intersection of the DRAM bandwidth line with the horizontal flop limit line. We see that intersection is just above 10 Flops/Byte. Multiplying by 8 would give a machine balance above 80 Flops/word. We get a few different estimates of the machine balance from these different methods, but the conclusion for most applications is that we are in the bandwidth-bound regime.

***3.3 Characterizing your application: Profiling***

Now that you have some sense of what performance you can get with the hardware, you need to determine what are the performance characteristics of your application. Additionally, you should develop an understanding of how different subroutines and functions depend on each other.

> **Example: Profiling the Krakatu tsunami wave simulation**

> You decide to profile your wave simulation application to see where the time is spent and decide how to parallelize and speed up the code. Some high-fidelity simulations can take days to run, so your team wants to understand how parallelization with OpenMP and vectorization might improve the performance. You decide to study a similar mini-app, CloverLeaf, that solves the compressible fluid dynamics equations. These equations are just slightly more complicated than the ones in your wave simulation application. CloverLeaf has versions in several parallel languages. For this profiling study, your team wants to compare the serial version to the parallel version with OpenMP and vectorization. Understanding CloverLeaf performance gives you a good frame of reference for the second step of profiling your serial wave simulation code.

***3.3.1 Profiling tools***

We’ll focus on profiling tools that produce a high-level view and that also provide additional information or context. There are a lot of profiling tools, but many produce more information than can be absorbed. As time permits, you may want to explore the other profiling tools listed in section 17.3. We’ll also present a mix of freely available tools and commercial tools so that you have options depending on your available resources.

It is important to remember your goal here is to isolate where it is best to spend your time parallelizing your application. The goal is not to understand every last detail of your current performance. It is easy to make the mistake of either not using these tools at all or getting lost in the tools and the data those produce.

***USING CALL GRAPHS FOR HOT-SPOT AND DEPENDENCY ANALYSIS***

We’ll start with tools that highlight hot spots and graphically display how each subroutine relates to others within code. Hot spots are kernels that occupy the largest amount of time during execution. Additionally, a call graph is a diagram that shows which routines call other routines. We can merge these two sets of information for an even more powerful combination as we will see in the next exercise.

A number of tools can generate call graphs, including valgrind’s cachegrind tool. Cachegrind’s call graphs highlight both hot spots and display subroutine dependencies. This type of graph is useful for planning development activities to avoid merge conflicts. A common strategy is to segregate tasks among the team so that work done by each team member takes place in a single call stack. The following exercise shows how to produce a call graph with the Valgrind tool suite and Callgrind. Another tool in the Valgrind suite, either KCacheGrind or QCacheGrind, then displays the results. The only difference is that one uses X11 graphics and the other uses Qt graphics.

> **Exercise: Call graph using cachegrind**

> For this exercise, the first step is to generate a call graph file using the Callgrind tool and then visualize it with KCacheGrind.

1.  Install Valgrind and KcacheGrind or QCacheGrind using a package manager

2.  Download the CloverLeaf miniapp from <https://github.com/UK-MAC/CloverLeaf>

    > `git clone --recursive https://github.com/UK-MAC/CloverLeaf.git`

3.  Build the serial version of CloverLeaf

    > `cd CloverLeaf/CloverLeaf_Serial`  
    > `make COMPILER=GNU IEEE=1 C_OPTIONS="-g -fno-tree-vectorize" \`  
    > `              OPTIONS="-g -fno-tree-vectorize"`

4.  Run Valgrind with the Callgrind tool

    > `cp InputDecks/clover_bm256_short.in clover.in`  
    > `edit clover.in and change cycles from 87 to 10`  
    > `valgrind --tool=callgrind -v ./clover_leaf`

5.  Start QCacheGrind with the command `qcachegrind`

6.  Load a specific callgrind.out.XXX file into the QCacheGrind GUI

7.  Right click Call Graph and change the image settings

> The following figure shows the CloverLeaf call graph. Each box in the call graph shows the name of the kernel and the percentage of time consumed by the kernel at each level of the call stack. A call stack is the chain of routines that call the present location in the code. As each routine calls a subroutine, it pushes its address onto the stack. At the end of the routine, the program simply pops the address off the stack as it returns to the prior calling routine. Each of the other “leaves” of the tree have their own call stacks. The call stack describes the hierarchy of data sources for the values in the “leaf” routine with the variables being passed down through the call chain. Timings can be either exclusive, where each routine excludes the timing of the routines it calls, or inclusive, where it includes the timing of all the routines below. The timings shown in the figure in the sidebar entitled “Measuring bandwidth using the empirical Roofline Toolkit” are inclusive with each level containing the levels below and summing up to 100% at the main routine.

> In the figure, the call hierarchy is shown for the most expensive routines, along with the number of times called and the percentage of run time. We can see from this that the majority of the run time is in the `advection` routines that move materials and energy from one cell to another. We need to focus our efforts there. The call graph is also helpful in tracing the path through the source code to follow.

>   

> **Call graph for CloverLeaf from KCacheGrind shows the largest contributors to run time.**

Another useful profiling tool is Intel® Advisor. This is a commercial tool with helpful features for getting the most performance from your application. Intel Advisor is part of the Parallel Studio package that also bundles the Intel compilers, Intel Inspector, and VTune. There are options for a student, educator, open source developer and trial licenses at <https://software.intel.com/en-us/qualify-for-free-software/student>. These Intel tools have also been released for free in the OneAPI package at [https:// software.intel.com/en-us/oneapi](https://software.intel.com/en-us/oneapi). Recently, Intel Advisor has added a profiling feature incorporating the roofline model. Let’s take a look at it in operation.

> **Exercise: Intel® Advisor**

> This exercise shows how to generate the roofline for the CloverLeaf mini-app, a regular grid compressible fluid dynamics (CFD) hydrocode.

1.  Build the OpenMP version of CloverLeaf:

    > `git clone --recursive https://github.com/UK-MAC/CloverLeaf.git`  
    > `cd CloverLeaf/CloverLeaf_OpenMP`  
    > `make COMPILER=INTEL IEEE=1 C_OPTIONS="-g -xHost" OPTIONS="-g -xHost"`

    > or

    > `make COMPILER=GNU IEEE=1 C_OPTIONS="-g -march=native" \`  
    > `       OPTIONS="g -march=native"`

2.  Run the application in the Intel Advisor tool:

    > `cp InputDecks/clover_bm256_short.in clover.in`  
    > `advixe-gui`

3.  Set the executable to clover_leaf in the CloverLeaf_OpenMP directory. The working directory can be set to the application directory or CloverLeaf_OpenMP.

    1.  For the GUI operation, select the Start Survey Analysis pull-down menu and choose Start Roofline Analysis

    2.  On the command line, type the following:

    > `advixe-cl --collect roofline --project-dir ./advixe_proj -- ./clover_leaf`

4.  Start the GUI and click the folder icon to load the run data.

5.  To view the results, click Survey and Roofline, then click on the far left side of the top panel of performance results (where it says roofline in vertical text).

> The following figure shows the summary statistics for the Intel Advisor profiler. It reports an arithmetic intensity of approximately .11 FLOPS/byte or .88 FLOPS/word. The floating-point computational rate is 36 GFLOPS/s.

>   

> **Summary output from Intel Advisor reporting an arithmetic intensity of 0.11 FLOPS/byte.**

> The next figure shows the roofline plot from Intel Advisor for the CloverLeaf mini-app. The performance of various kernels is shown as points relative to the roofline performance of the Skylake processor. The size and color of the points indicate the percentage of overall time for each of the kernels. Even at a glance, it is clear that the algorithm is bandwidth limited and far to the left of the compute-bound region. Because this mini-app uses double precision, multiply the arithmetic intensity of .01 by 8 to get an arithmetic intensity well below 1 flop/word. The machine balance is the intersection of the double-precision FMA peak and the DRAM bandwidth.

>   

> **Roofline from Intel® Advisor for Cloverleaf (clover_bm256_short.in) on a Skylake Gold_6152 processor**

> In this plot, the machine balance is above 10 flops/byte or, multiplying by 8, greater than 80 flops/word, where the word size is a double. The sections of code that are most important for performance are identified by the names associated with each dot. The routines that have the most potential for improvement can be determined by how far these are below the bandwidth limit. We also can see that it would be helpful to improve the arithmetic intensity in the kernels.

We can also use the freely available likwid tool suite to get an arithmetic intensity. Likwid is an acronym for “Like I Knew What I’m Doing” and is authored by Treibig, Hager, and Wellein at the University of Erlangen-Nuremberg. It is a command-line tool that only runs on Linux and utilizes the machine-specific registers (MSR). The MSR module must be enabled with `modprobe msr`. The tool uses hardware counters to measure and report various information from the system, including run time, clock frequency, energy and power usage, and memory read and write statistics.

> **Exercise: likwid perfctr**

1.  Install likwid from package manager or with the following commands:

    > `git clone https://github.com/RRZE-HPC/likwid.git`  
    > `cd likwid`  
    > `edit config.mk`  
    > `make`  
    > `make install`

2.  Enable MSR with `sudo modprobe msr`

3.  Run `likwid-perfctr -C 0-87 -g MEM_DP ./clover_leaf`

> > > > (In the output, there’s also min and max columns. These have been removed to save space.)

>       

> `Computation Rate = (22163.8134+4*4777.5260) = 41274 MFLOPs/sec = 41.3 GFLOPs/sec`  
> `Arithmetic Intensity = 41274/123319.9692 = .33 FLOPs/byte`  
> `Operational Intensity = .3608 FLOPs/byte`  
>   
> `For a serial run:`  
> `Computation Rate = 2.97 GFLOPS/sec`  
> `Operational intensity = 0.2574 FLOPS/byte`  
> `Energy = 212747.7787 Joules`  
> `Energy DRAM = 49518.7395 Joules`

We can also use the output from likwid to calculate the energy reduction for CloverLeaf due to running in parallel.

> **Exercise: Calculate the energy savings for parallel run relative to serial**

> Energy reduction is (212747.7787 - 151590.4909) / 212747.7787 = 28.7 %.

> DRAM energy reduction is (49518.7395 - 37986.9191) / 49518.7395 = 23.2 %.

***INSTRUMENT SPECIFIC SECTIONS OF CODE WITH LIKWID-PERFCTR MARKERS***

Markers can be used in likwid to get performance for one or multiple sections of code. This capability will be used in the next chapter in section 4.2.

1.  Compile the code with `-DLIKWID_PERFMON -I<PATH_TO_LIKWID>/include`

2.  Link with `-L<PATH_TO_LIKWID>/lib` and `-llikwid`

3.  Insert the lines from listing 3.1 into your code

**Listing 3.1 Inserting markers into code to instrument specific sections of code**

> `LIKWID_MARKER_INIT;                 `❶  
> `LIKWID_MARKER_THREADINIT;`  
> `LIKWID_MARKER_REGISTER("Compute")   `❷  
>   
> `LIKWID_MARKER_START("Compute");`  
> `// ...  Your code to measure`  
> `LIKWID_MARKER_STOP("Compute");`  
> `LIKWID_MARKER_CLOSE;                `❶

❶ A single threaded region

❷ Requires daemon with suid (root) permissions

***GENERATING YOUR OWN ROOFLINE PLOTS***

Charlene Yang, NERSC, has created and released a Python script for generating a roofline plot. This is extremely convenient for generating a high-quality, custom graphic with data from your explorations. For these examples, you may want to install the anaconda3 package. It contains the matplotlib library and Jupyter notebook support. Use the following code to customize a roofline plot using Python and matplotlib:

> `git clone https://github.com/cyanguwa/nersc-roofline.git`  
> `cd nersc-roofline/Plotting`  
> `modify data.txt`  
> `python plot_roofline.py data.txt`

We’ll use modified versions of this plotting script in a couple of exercises. In this first one, we embedded parts of the roofline plotting script into a Jupyter notebook. Jupyter notebooks (<https://jupyter.org/install.html>) allow you to intersperse Markdown documentation with Python code for an interactive experience. We use this to dynamically calculate the theoretical hardware performance and then create a roofline plot of your arithmetic intensity and performance.

> **Exercise: Plotting script embedded in a Jupyter notebook**

> Install Python3 using a package manager. Then use the Python installer, pip, to install NumPy, SciPy, matplotlib, and Jupyter:

> `brew install python3`  
> `pip install numpy scipy matplotlib jupyter`

> Run the Jupyter notebook:

1.  Download the Jupyter notebook at [https://github.com/EssentialsofParallelComputing/ Chapter3](https://github.com/EssentialsofParallelComputing/Chapter3)

2.  Open the Jupyter notebook HardwarePlatformCharacterization.ipynb

3.  In HardwarePlatformCharacterization.ipynb, change the settings for the hardware in the first section for your platform of interest as shown in the following figure:

>   

> Once you change the hardware settings, you are ready to run the calculations for the theoretical hardware characteristics. Run all cells in the notebook and look for calculations in the next part of the notebook as shown in the next figure.

>   

> The next notebook section contains the measured performance data you want to plot on the roofline plot. Enter this data from performance measurements. We use the data collected using the likwid performance counters for a serial run of CloverLeaf and one with OpenMP and vectorization.

>   

> Now the notebook starts the code to plot the roofline using matplotlib. Shown here is the first half of the plotting script. You can change the plot extent, scales, labels, and other settings.

>   

> The plotting script then finds the “elbows” where the lines intersect to plot only the relative segments. It also works out the location and orientation of the text to be placed on the plot.

>  

>   

Plotting this arithmetic intensity and computation rate gives the result in figure 3.6. Both the serial and the parallel runs are plotted on the roofline. The parallel run is about 15 times faster and with slightly higher operational (arithmetic) intensity.

**Figure 3.6 Overall performance of Clover Leaf on a Skylake Gold processor**

There are a couple more tools that can measure arithmetic intensity. The Intel® Software Development Emulator (SDE) package ([https://software.intel.com/en-us/ articles/intel-software-development-emulator](https://software.intel.com/en-us/articles/intel-software-development-emulator)) generates lots of information that can be used to calculate arithmetic intensity. The Intel® Vtune™ performance tool (part of the Parallel Studio package) can also be used to gather performance information.

When we compare the results from Intel Advisor and likwid, there is a difference in the arithmetic intensity. There are many different ways to count operations, counting the whole cache line when loaded or just the data used. Similarly, the counters can count the entire vector width and not just the part that is used. Some tools count just floating-point operations, whereas others count different types of operations (such as integer) as well.

***3.3.2 Empirical measurement of processor clock frequency and energy consumption***

Recent processors have a lot of hardware performance counters and control capabilities. These include processor frequency, temperature, power, and many others. New software applications and libraries are emerging to make accessing this information easier. These applications ease the programming difficulty, but these may also help work around the need for elevated permissions so that the data is more accessible to normal users. This is a welcome development because programmers cannot optimize what they cannot see.

With the aggressive management of processor frequency, processors seldom are at their nominal frequency setting. The clock frequency is reduced when processors are at idle and increased to a turbo-boost mode when busy. Two easy interactive commands to see the behavior of the processor frequency are

> `watch -n 1 "lscpu | grep MHz"`  
> `watch -n 1 "grep MHz /proc/cpuinfo"`

The likwid tool suite also has a command-line tool, likwid-powermeter, to look at processor frequencies and power statistics. The likwid-perfctr tool also reports some of these statistics in a summary report. Another handy little app is the Intel® Power Gadget, with versions for the Mac and Windows and a more limited one for Linux. It graphs frequency, power, temperature, and utilization.

The CLAMR mini-app (<http://www.github.com/LANL/CLAMR.git>) is developing a small library, PowerStats, that will track energy and frequency from within an application and report it at the end of the run. Currently, PowerStats works on the Mac, using the Intel Power Gadget library interface. A similar capability is being developed for Linux systems. The application code needs to add just a few calls as shown in the following listing.

**Listing 3.2 PowerStats code to track energy and frequency**

> `powerstats_init();        `❶  
> `powerstats_sample();      `❷  
> `powerstats_finalize();    `❸

❶ Declare once at start up

❷ Declare periodically during calculation (for example, every 100 iterations) or for different phases

❸ Declare once at program end

When run, the following table is printed:

> `Processor      Energy(mWh) =   94.47181`  
> `IA             Energy(mWh) =   70.07562`  
> `DRAM           Energy(mWh) =    3.09289`  
> `Processor      Power (W)   =   71.07833`  
> `IA             Power (W)   =   54.73608`  
> `DRAM           Power (W)   =    2.32194`  
> `Average Frequency          = 3721.19422`  
> `Average Temperature (C)    =   94.78369`  
> `Time Expended (secs)       =   12.13246`

***3.3.3 Tracking memory during run time***

Memory usage is also another aspect of performance that isn’t easily visible to the programmer. You can use the same sort of interactive command for processor frequency as in the previous listing, but for memory statistics instead. First, get your process ID from the `top` or the `ps` command. Then use one of the following commands to track memory usage:

> `watch -n 1 "grep VmRSS /proc/<pid>/status"`  
> `watch -n 1 "ps <pid>"`  
> `top -s 1 -p <pid>`

To integrate this into your program, perhaps to see what happens with memory in different phases, the MemSTATS library in CLAMR provides four different memory-tracking calls:

> `long long memstats_memused()`  
> `long long memstats_mempeak()`  
> `long long memstats_memfree()`  
> `long long memstats_memtotal()`

Insert these calls into your program to return the current memory statistics at the point of the call. MemSTATS is a single C source and header file, so it should be easy to integrate into your program. To get the source, go to [http://github.com/LANL/ CLAMR/](http://github.com/LANL/CLAMR/) and look in the MemSTATS directory. It is also available at [https://github .com/EssentialsofParallelComputing/Chapter3](https://github.com/EssentialsofParallelComputing/Chapter3) in the code samples.

***3.4 Further explorations***

This chapter only brushes the surface of what all these tools can do. For more information, explore the following resources in the additional reading section and try some of the exercises.

***3.4.1 Additional reading***

You can find more information and data on the STREAM Benchmark here:

John McCalpin. 1995. “STREAM: Sustainable Memory Bandwidth in High Performance Computers.” <https://www.cs.virginia.edu/stream/>.

The roofline model originated at Lawrence Berkeley National Laboratory. Their website has many resources exploring its use:

“Roofline Performance Model.” [https://crd.lbl.gov/departments/computer-science/ PAR/research/roofline/](https://crd.lbl.gov/departments/computer-science/PAR/research/roofline/).

***3.4.2 Exercises***

1.  Calculate the theoretical performance of a system of your choice. Include the peak flops, memory bandwidth, and machine balance in your calculation.

2.  Download the Roofline Toolkit from [https://bitbucket.org/berkeleylab/ cs-roofline-toolkit.git](https://bitbucket.org/berkeleylab/cs-roofline-toolkit.git) and measure the actual performance of your selected system.

3.  With the Roofline Toolkit, start with one processor and incrementally add optimization and parallelization, recording how much improvement you get at each step.

4.  Download the STREAM Benchmark from <https://www.cs.virginia.edu/stream/> and measure the memory bandwidth of your selected system.

5.  Pick one of the publicly available benchmarks or mini-apps listed in section 17.1 and generate a call graph using KCacheGrind.

6.  Pick one of the publicly available Benchmarks or mini-apps listed in section 17.1 and measure its arithmetic intensity with either Intel Advisor or the likwid tools.

7.  Using the performance tools presented in this chapter, determine the average processor frequency and energy consumption for a small application.

8.  Using some of the tools from section 3.3.3, determine how much memory an application uses.

This chapter has covered a lot of ground with many necessary details for a parallel project plan. Estimating performance capabilities and using tools to extract information on hardware characteristics and application performance give solid, concrete data points to populate the plan. The proper use of these tools and skills can help build a foundation for a successful parallel project.

***Summary***

- There are several possible performance limitations for an application. These range from the peak number of floating-point operations (flops) to memory bandwidth and hard disk reads and writes.

- Applications on current computing systems are generally more limited by memory bandwidth than flops. Although identified two decades ago, it has become even more true than projected at that time. But computational scientists have been slow to adapt their thinking to this new reality.

- You can use profiling tools to measure your application performance and to determine where to focus optimization and parallelization work. This chapter shows examples using Intel® Advisor, Valgrind, Callgrind, and likwid, but there are many other tools including Intel® VTune, Open\|Speedshop (O\|SS), HPC Toolkit, or Allinea/ARM MAP. (A more complete list is given in section 17.3.) However, the most valuable tools are those that provide actionable information rather than quantity.

- You can use hardware performance utilities and apps to determine energy consumption, processor frequency, memory usage, and much more. By making these performance attributes more visible, it becomes easier to optimize for these considerations.
