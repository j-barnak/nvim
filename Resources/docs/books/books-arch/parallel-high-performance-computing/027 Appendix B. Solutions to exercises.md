# Appendix B. Solutions to exercises

***Appendix B. Solutions to exercises***

***B.1 Chapter 1: Why parallel computing?***

1.  What are some other examples of parallel operations in your daily life? How would you classify your example? What does the parallel design appear to optimize for? Can you compute a parallel speedup for this example?

    Answer: Examples of parallel operations in daily life include multi-lane highways, class registration queues, and mail delivery. There are many others.

2.  For your desktop, laptop, or cellphone, what is the theoretical parallel processing power of your system in comparison to its serial processing power? What kinds of parallel hardware are present in it?

    Answer: It can be hard to penetrate the marketing and hype and find the real specifications. Most devices, including handheld, have multi-core processors and at least an integrated graphics processor. Desktops and laptops have some vector capabilities except for very old hardware.

3.  Which parallel strategies do you see in the store checkout example in figure 1.1? Are there some present parallel strategies that are not shown? How about in your examples from exercise 1?

    Answer: Multiple instruction, multiple data (MIMD), distributed data, pipeline parallelism, and out-of-order execution with specialized queues.

4.  You have an image-processing application that needs to process 1,000 images daily, which are 4 mebibytes (MiB, 220 or 1,048,576 bytes) each in size. It takes 10 min in serial to process each image. Your cluster is composed of multi-core nodes with 16 cores and a total of 16 gibibytes (GiB, 230 bytes, or 1024 mebibytes) of main memory storage per node. (Note that we use the proper binary terms, MiB and GiB, rather than MB and GB, which are the metric terms for 10⁶ and 10⁹ bytes, respectively.)

    1.  What parallel processing design best handles this workload?

    2.  Now customer demand increases by 10x. Does your design handle this? What changes would you have to make?

    Answer: Threading on a single compute node along with vectorization. 4MiB × 1000 = 4 Gb. But to process 16 images at a time, only 64 MiB is needed, well under 1 GiB on each node (workstation) of the cluster. The time would be 10 min × 1000 or 167 min in serial and 10.4 min on 16 cores in parallel. Vectorization could reduce this to under 5 min. A demand increase of 10x would make this 100 min. This may be Ok, but it might also be time to think about message passing or distributed computing.

5.  An Intel Xeon E5-4660 processor has a thermal design power of 130 W; this is the average power consumption rate when all 16 cores are used. Nvidia’s Tesla V100 GPU and AMD’s MI25 Radeon GPU have a thermal design power of 300 W. Suppose you port your software to use one of these GPUs. How much faster should your application run on the GPU to be considered more energy efficient than your 16-core CPU application?

> > > Answer: 300 W / 130 W. It needs to have a 2.3x speedup to be more energy efficient.

***B.2 Chapter 2: Planning for parallelism***

1.  You have a wave height simulation application that you developed during graduate school. It is a serial application and because it was only planned to be the basis for your dissertation, you didn’t incorporate any software engineering techniques. Now you plan to use it as the starting point for an available tool that many researchers can use. You have three other developers on your team. What would you include in your project plan for this?

    Answer: The preparation steps would include

    - Establishing a version control system with Git

    - Creating a set of tests with known results

    - Running memory correctness tools on the tests in the test suite

    - Profiling the hardware and your application

    - Creating a plan for the next step in your agile management strategy

2.  Create a test using CTest

    Answer: To create a test using CTest, because CTest detects any error status from a command, a test can be made from a build instruction. Sometimes installing the CTest files will strip the executable bit from the permissions and cause the test to fail with no clear error message. To avoid this, we can add a test to detect if the CTest script is executable. In the following code, the `$0` is the CTest script with the full path so that it works for out-of-tree builds.

    - In CMakeLists.txt, add

    > `enable_testing()`  
    >   
    > `add_test(NAME make WORKING_DIRECTORY ${CMAKE_BINARY_DIRECTORY}`  
    > `            COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/build.ctest)`

    - Add the build.ctest file with

    > `#!/bin/sh`  
    > `if [ -x $0 ]`  
    > `then`  
    > `   echo "PASSED - is executable"`  
    > `else`  
    > `   echo "Failed - ctest script is not executable"`  
    > `   exit -1`  
    > `fi`

3.  Fix the memory errors in listing 2.2

    Answer: You can fix the memory errors in listing 2.2 by changing or adding the following lines:

    > `  4    int ipos=0, ival;`  
    > `  7    for (int i = 0; i<10; i++){ iarray[i] = ipos; }`  
    > `  8    for (int i = 0; i<10; i++){`  
    > `11    free(iarray);`

4.  Run valgrind on a small application of your choice

    Answer: On your own

***B.3 Chapter 3: Performance limits and profiling***

1.  Calculate the theoretical performance of a system of your choice. Include the peak flops, memory bandwidth, and machine balance in your calculation.

    Answer: On your own

2.  Download the Roofline Toolkit from [https://bitbucket.org/berkeleylab/cs-roof line-toolkit.git](https://bitbucket.org/berkeleylab/cs-roofline-toolkit.git) and measure the actual performance of your selected system.

    Answer: On your own

3.  With the Roofline Toolkit, start with one processor and incrementally add optimization and parallelization, recording how much improvement you get at each step.

    Answer: On your own

4.  Download the STREAM benchmark from <https://www.cs.virginia.edu/stream/> and measure the memory bandwidth of your selected system.

    Answer: On your own

5.  Pick one of the publicly available benchmarks or mini-apps listed in section 17.4 and generate a call graph using KCachegrind.

    Answer: On your own

6.  Pick one of the publicly available benchmarks or mini-apps listed in section 17.4 and measure its arithmetic intensity with either Intel Advisor or the likwid tools.

    Answer: On your own

7.  Using the performance tools presented in this chapter, determine the average processor frequency and energy consumption for a small application.

    Answer: On your own

8.  Using some of the tools from section 2.3.3, determine how much memory an application uses.

    Answer: On your own

***B.4 Chapter 4: Data design and performance models***

1.  Write a 2D contiguous memory allocator for a lower-left triangular matrix.

    Answer: Listing B.4.1 shows the code to allocate a lower-left triangular array. Assume array indexing is C, with the lower left element at `[0][0]`. Also, the matrix must be a square matrix. We use the same code as in listing 4.3 but with the length of `imax` reduced by 1 for each row. Note that the number of elements in the triangular array can be calculated by `jmax*(imax+1)/2`.

    **Listing B.4.1 Triangular matrix allocation**

    > `ExerciseB.4.1/malloc2Dtri.c`  
    > `1 #include <stdlib.h>`  
    > `2 #include "malloc2Dtri.h"`  
    > `3`  
    > `4 double **malloc2Dtri(int jmax, int imax)`  
    > `5 {`  
    > `6    double **x =                                 `❶  
    > `        (double **)malloc(jmax*sizeof(double *) +  `❶  
    > `7      jmax*(imax+1)/2*sizeof(double));           `❶  
    > `8`  
    > `9    x[0] = (double *)(x + jmax);                 `❷  
    > `10`  
    > `11    for (int j = 1; j < jmax; j++, imax--) {     `❸  
    > `12      x[j] = x[j-1] + imax;                      `❹  
    > `13    }`  
    > `14`  
    > `15    return(x);`  
    > `16 }`

    ❶ First allocate a block of memory for the row pointers and the 2D array

    ❷ Now assign the start of the block of memory for the 2D array after the row pointers

    ❸ Reduce imax by 1 each iteration

    ❹ Last, assign the memory location to point to for each row pointer

2.  Write a 2D allocator for C that lays out the memory the same way as Fortran.

    Answer: Let’s assume that we want to address the array as `x(j,i)` in Fortran. The array will be addressed as `x[i][j]` in C. If we create a macro `#define x(j,i) x[i-1][j-1]`, then the code could use the Fortran array notation. The 2D memory allocator from listing 4.3 can be used by interchanging `i` and `j` and `imax` and `jmax`. The following listing shows the resulting code.

    **Listing B.4.2 Triangular matrix allocation**

    > `Exercise4.2/malloc2Dfort.c`  
    > `1 #include <stdlib.h>`  
    > `2 #include "malloc2Dfort.h"`  
    > `3`  
    > `4 double **malloc2Dfort(int jmax, int imax)`  
    > `5 {`  
    > `6    double **x =                                   `❶  
    > `        (double **)malloc(imax*sizeof(double *) +    `❶  
    > `7      imax*jmax*sizeof(double));                   `❶  
    > `8`  
    > `9    x[0] = (double *)(x + imax);                   `❷  
    > `10`  
    > `11    for (int i = 1; i < imax; i++) {`  
    > `12       x[i] = x[i-1] + jmax;                       `❸  
    > `13    }`  
    > `14`  
    > `15    return(x);`  
    > `16 }`

    ❶ First allocate a block of memory for the column pointers and the 2D array

    ❷ Now assign the start of the block of memory for the 2D array after the column pointers

    ❸ Last, assign the memory location to point to for each column pointer

3.  Design a macro for an Array of Structure of Arrays (AoSoA) for the RGB color model in section 4.1.

    Answer: We want to retrieve the data with the normal array index and color name:

    > `#define VV = 4`  
    > `#define color(i,C) AOSOA[(i)/VV].C[(i)%4-1]`  
    > `color(50,B)`

4.  Modify the code for the cell-centric full matrix data structure to not use a conditional and estimate its performance.

    Answer: The following figure shows the code with the `if` statement removed. From this modified code, the performance model counts look like the following:

    Memops = 2 \* N_(c) N_(m) + 2 \* N_(c) = 102 M Memops

    1: for all cells, C, up to N_(c) do

    2: ave ← 0.0

    3: for all material IDs, m, up to N_(m) do

    4: ave ← ave + ρ\[C\]\[m\] ∗ f \[C\]\[m\] \# 2N_(c) N_(m) loads (ρ, f )

                                                      # 2N_(c) N_(m) flops (+, ∗)

    5: end for

    6: ρ_(ave)\[C\] ← ave/V\[C\] \# N_(c) stores (ρ_(ave)), N_(c) loads (V)

    \# N_(c) flops (/)

    7: end for

    **Performance Model = 61.0 ms. This performance estimate is slightly faster than the version with the** **`if`** **statement.**

5.  How would an AVX-512 vector unit change the ECM model for the stream triad?

Answer: The performance analysis with the ECM model in section 4.4 uses an AVX-256 vector unit that could process all the needed floating-point operations in 1 cycle. The AVX-512 would still need 1 cycle but would only have half of its vector units busy and could do twice the work if it were present. Because the compute operation time, T_(OL), remains at 1 cycle, the performance would not change at all.

***B.5 Chapter 5: Parallel algorithms and patterns***

1.  A cloud collision model in an ash plume is invoked for particles within a 1 mm distance. Write pseudocode for a spatial hash implementation. What complexity order is this operation?

    Answer: The pseudocode for the collision operation is as follows:

    > `    1. Bin particles into 1 mm spatial bins`  
    > `    2. For each bin`  
    > `    3.    For each particle, i, in the bin`  
    > `    4.       For all other particles, j, in this bin or adjacent bins`  
    > `    5.          if  |P`_(`i`)` - P`_(`j`)`| < 1 mm`  
    > `    6.              compute collision`

    The operation is O(N²) in the local region, but as the mesh grows larger, the distance between the particles does not have to be computed for larger regions, thus, the operation approaches O(N ).

2.  How are spatial hashes used by the postal service?

    Answer: Zip codes. The hashing function encodes the state and region in the first three digits with the remaining two encoding first the large towns and then alphabetical order for the rest.

3.  Big data uses a map-reduce algorithm for efficient processing of large data sets. How is it different than the hashing concepts presented here?

    Answer: Although developed for different problem domains and scales, the map operation in the map-reduce algorithm is a hash. So these both do a hashing step followed by a second local operation. The spatial hash has a concept of a distance relationship between bins, whereas the map-reduce intrinsically does not.

4.  A wave simulation code uses an AMR mesh to better refine the shoreline. The simulation requirements are to record the wave heights versus time for specified locations where buoys and shore facilities are located. Because the cells are constantly being refined, how could you implement this?

    Answer: Create a perfect spatial hash with the bin size the same as the smallest cell and store the cell index in the bins underlying the cell. Calculate the bin for each station and get the cell index from the bin.

***B.6 Chapter 6: Vectorization: FLOPs for free***

1.  Experiment with auto-vectorizing loops from the multimaterial code in section 4.3 (<https://github.com/LANL/MultiMatTest.git>). Add the vectorization and loop report flags and see what your compiler tells you.

    Answer: On your own

2.  Add OpenMP SIMD pragmas to help the compiler vectorize loops to the loop you selected in the first exercise.

    Answer: On your own

3.  For one of the vector intrinsic examples, change the vector length from four double precision values to an eight-wide vector width. Check the source code for this chapter for examples of working code for eight-wide implementations.

    Answer: In kahan_fog_vector.cpp, change `4s` to `8s` and change `Vec4d` to `Vec8d`. Add `mprefer-vector-width=512 -DMAX_VECTOR_SIZE=512` to `CXXFLAGS`. The changed code and Makefile are included in the source code for this chapter.

4.  If you are on an older CPU, does your program from exercise 3 successfully run? What is the performance impact?

    Answer: For Intel 256-bit vector units, the Intel intrinsics do not work and must be commented out. The GCC and Fog versions still work, however. The timing results from a 2017 Mac laptop show the superiority of Agner Fog’s vector class library with the eight-wide vectors producing better results than the four-wide. In contrast, the GCC implementation for the eight-wide vector is slower than the four-wide version. Here's the output:

    > `SETTINGS INFO -- ncells 1073741824 log 30`  
    > `Initializing mesh with Leblanc problem, high values first`  
    > `  relative diff  runtime    Description`  
    > `    8.423e-09    1.461642   Serial sum`  
    > `            0    3.283697   Kahan sum with double double accumulator`  
    > `4 wide vectors serial sum`  
    > `   -3.356e-09    0.408654   Serial sum (OpenMP SIMD pragma)`  
    > `   -3.356e-09    0.407457   Intel vector intrinsics Serial sum`  
    > `   -3.356e-09    0.402928   GCC vector intrinsics Serial sum`  
    > `   -3.356e-09    0.406626   Fog C++ vector class Serial sum`  
    > `4 wide vectors Kahan sum`  
    > `            0    0.872013   Intel Vector intrinsics Kahan sum`  
    > `            0    0.873640   GCC vector extensions Kahan sum`  
    > `            0    0.872774   Fog C++ vector class Kahan sum`  
    > `8 wide vector serial sum`  
    > `   -1.986e-09    1.467707   8 wide GCC vector intrinsic Serial sum`  
    > `   -1.986e-09    0.586075   8 wide Fog C++ vector class Serial sum`  
    > `8 wide vector Kahan sum`  
    > `   -1.388e-16    1.914804   8 wide GCC vector extensions Kahan sum`  
    > `   -1.388e-16    0.545128   8 wide Fog C++ vector class Kahan sum`  
    > `   -1.388e-16    `**`0.687497   Agner C++ vector class Kahan sum`**

***B.7 Chapter 7: OpenMP that performs***

1.  Convert the vector add example in listing 7.8 into a high-level OpenMP following the steps in section 7.2.2.

    Answer: Converting to high-level OpenMP, we end up with the code shown in the following listing with just a single pragma to open the parallel region.

    **Listing B.7.1 High-level OpenMP**

    > `ExerciseB.7.1/vecadd.c`  
    > `11 int main(int argc, char *argv[]){`  
    > `12    #pragma omp parallel`  
    > `13    {`  
    > `14       double time_sum;`  
    > `15       struct timespec tstart;`  
    > `16       int thread_id = omp_get_thread_num();`  
    > `17       int nthreads  = omp_get_num_threads();`  
    > `18       if (thread_id == 0){`  
    > `19          printf("Running with %d thread(s)\n",nthreads);`  
    > `20       }`  
    > `21       int tbegin = ARRAY_SIZE * ( thread_id     ) / nthreads;`  
    > `22       int tend   = ARRAY_SIZE * ( thread_id + 1 ) / nthreads;`  
    > `23`  
    > `24       for (int i=tbegin; i<tend; i++) {`  
    > `25          a[i] = 1.0;`  
    > `26          b[i] = 2.0;`  
    > `27       }`  
    > `28`  
    > `29       if (thread_id == 0) cpu_timer_start(&tstart);`  
    > `30       vector_add(c, a, b, ARRAY_SIZE);`  
    > `31       if (thread_id == 0) {`  
    > `32          time_sum += cpu_timer_stop(tstart);`  
    > `33          printf("Runtime is %lf msecs\n", time_sum);`  
    > `34       }`  
    > `35    }`  
    > `36 }`  
    > `37`  
    > `38 void vector_add(double *c, double *a, double *b, int n)`  
    > `39 {`  
    > `40    int thread_id = omp_get_thread_num();`  
    > `41    int nthreads = omp_get_num_threads();`  
    > `42    int tbegin = n * ( thread_id     ) / nthreads;`  
    > `43    int tend   = n * ( thread_id + 1 ) / nthreads;`  
    > `44    for (int i=tbegin; i < tend; i++){`  
    > `45       c[i] = a[i] + b[i];`  
    > `46    }`  
    > `47 }`

2.  Write a routine to get the maximum value in an array. Add an OpenMP pragma to add thread parallelism to the routine

    Answer: The reduction routine uses the `reduction(max:xmax)` clause as the following listing shows.

    **Listing B.7.2 OpenMP max reduction**

    > `ExerciseB.7.2/max_reduction.c`  
    > `1 #include <float.h>`  
    > `2 double array_max(double* restrict var, int ncells)`  
    > `3 {`  
    > `4    double xmax = DBL_MIN;`  
    > `5    #pragma omp parallel for reduction(max:xmax)`  
    > `6    for (int i = 0; i < ncells; i++){`  
    > `7       if (var[i] > xmax) xmax = var[i];`  
    > `8    }`  
    > `9 }`

3.  Write a high-level OpenMP version of the reduction in the previous exercise.

    Answer: In high-level OpenMP, we manually divide up the data. The data decomposition is done in lines 6-9 in listing B.7.3. Thread `0` allocates the `xmax_thread` shared data array on line 13. Lines 18-22 find the maximum value for each thread and store the result in the `xmax_thread` array. Then, on lines 26-30, one thread finds the maximum across all the threads.

    **Listing B.7.3 High-level OpenMP**

    > `ExerciseB.7.3/max_reduction.c`  
    > `1 #include <stdlib.h>`  
    > `2 #include <float.h>`  
    > `3 #include <omp.h>`  
    > `4 double array_max(double* restrict var, int ncells)`  
    > `5 {`  
    > `6    int nthreads = omp_get_num_threads();`  
    > `7    int thread_id = omp_get_thread_num();`  
    > `8    int tbegin = ncells * ( thread_id     ) / nthreads;`  
    > `9    int tend   = ncells * ( thread_id + 1 ) / nthreads;`  
    > `10    static double xmax;`  
    > `11    static double *xmax_thread;`  
    > `12    if (thread_id == 0){`  
    > `13       xmax_thread = malloc(nthreads*sizeof(double));`  
    > `14       xmax = DBL_MIN;`  
    > `15    }`  
    > `16 #pragma omp barrier`  
    > `17`  
    > `18    double xmax_thread_private = DBL_MIN;`  
    > `19    for (int i = tbegin; i < tend; i++){`  
    > `20       if (var[i] > xmax_thread_private) xmax_thread_private = var[i];`  
    > `21    }`  
    > `22    xmax_thread[thread_id] = xmax_thread_private;`  
    > `23`  
    > `24 #pragma omp barrier`  
    > `25`  
    > `26    if (thread_id == 0){`  
    > `27       for (int tid=0; tid < nthreads; tid++){`  
    > `28          if (xmax_thread[tid] > xmax) xmax = xmax_thread[tid];`  
    > `29       }`  
    > `30    }`  
    > `31`  
    > `32 #pragma omp barrier`  
    > `33`  
    > `34    if (thread_id == 0){`  
    > `35       free(xmax_thread);`  
    > `36    }`  
    > `37    return(xmax);`  
    > `38 }`

***B.8 Chapter 8: MPI: The parallel backbone***

1.  Why can’t we just block on receives as was done in the send/receive in the ghost exchange using the pack or array buffer methods in listings 8.20 and 8.21, respectively?

    Answer: The version using the pack or array buffers schedules the send, but returns before the data is copied or sent. The standard for the `MPI_Isend` says, “The sender should not modify any part of the send buffer after a nonblocking send operation is called, until the send completes.” The pack and array versions deallocate the buffers after the communication. So these versions might delete the buffers before these are copied, causing the program to crash. To be safe, the status of the send must be checked before the buffer is deleted.

2.  Is it safe to block on receives as shown in listing 8.8 in the vector type version of the ghost exchange? What are the advantages if we only block on receives?

    Answer: The vector version sends the data from the original arrays instead of making a copy. This is safer than the versions that allocate a buffer, which will be deallocated. If we only block on receives, the communication can be faster.

3.  Modify the ghost cell exchange vector type example in listing 8.21 to use blocking receives instead of a `waitall`. Is it faster? Does it always work?

    Answer: Even with the vector version of the ghost cell exchange, we have to be careful that we do not modify the buffers that are still in the process of being sent. The odds of this happening can be small when we are not sending corners. But it still can occur. To be absolutely safe, we need to check for completion of the sends before changing the arrays.

4.  Try replacing the explicit tags in one of the ghost exchange routines with `MPI_ANY_TAG`. Does it work? Is it any faster? What advantage do you see in using explicit tags?

    Answer: Using `MPI_ANY_TAG` for the tag argument works fine. It can be slightly faster though it is unlikely that it will be significant enough to be measurable. Using explicit tags adds another check that the right message is being received.

5.  Remove the barriers in the synchronized timers in one of the ghost exchange examples. Run the code with the original synchronized timers and the unsynchronized timers.

    Answer: Removing the barriers in the timers should give better performance and allow the processes to operate more independently (asynchronous). It can be more difficult to understand the timing measurements though.

6.  Add the timer statistics from listing 8.11 to the stream triad bandwidth measurement code in listing 8.17.

    Answer: On your own

7.  Apply the steps to convert high-level OpenMP to the hybrid MPI plus OpenMP example in the code that accompanies the chapter (HybridMPIPlusOpenMP directory). Experiment with the vectorization, number of threads, and MPI ranks on your platform.

    Answer: On your own

***B.9 Chapter 9: GPU architectures and concepts***

1.  Table 9.7 shows the achievable performance for a 1 flop/load application. Look up the current prices for the GPUs available on the market and fill in the last two columns to get the flop per dollar for each GPU. Which looks like the best value? If turnaround time for your application runtime is the most important criteria, which GPU would be best to purchase?

    **Table B.1 Achievable performance for a 1 flop/load application with various GPUs**

    [TABLE]

    Answer: On your own

2.  Measure the stream bandwidth of your GPU or another selected GPU. How does it compare to the ones presented in the chapter?

    Answer: On your own

3.  Use the likwid performance tool to get the CPU power requirements for the CloverLeaf application on a system where you have access to the power hardware counters.

    Answer: On your own

***B.10 Chapter 10: GPU programming model***

1.  You have an image classification application that will take 5 ms to transfer each file to the GPU, 5 ms to process and 5 ms to bring back. On the CPU, the processing takes 100 ms per image. There are one million images to process. You have 16 processing cores on the CPU. Would a GPU system do the work faster?

    Answer:

    Time on a CPU—100 ms × 1,000,000/16 /1,000 = 6,250 s

    Time on a GPU—(5 ms + 5 ms + 5 ms) × 1,000,000/1,000 = 15,000 s

    The GPU system would not be faster. It would take about 2.5 times as long.

2.  The transfer time for the GPU in problem 1 is based on a third generation PCI bus. If you can get a Gen4 PCI bus, how does that change the design? A Gen 5 PCI bus? For image classification, you shouldn’t need to bring back a modified image. How does that change the calculation?

    Answer: A fourth-generation PCI bus is twice as fast as a third-generation PCI bus.

    (2.5 ms + 5 ms + 2.5 ms) × 1,000,000/1,000 = 10,000 s

    A fifth-generation PCI bus would be four times as fast as the original third-generation PCI bus.

    (1.25 ms + 5 ms + 1.25 ms) × 1,000,000/1,000 = 7,500 s

    If we don’t have to transfer the results back, we are now just as fast on the GPU as on the CPU.

    (1.25 ms + 5 ms) × 1,000,000/1,000 = 6,250 s

3.  For your discrete GPU (or NVIDIA GeForce GTX 1060, if none), what size 3D application could you run? Assume 4 double-precision variables per cell and a usage limit of half the GPU memory so you have room for temporary arrays. How does this change if you use single precision?

    Answer: An NVIDIA GeForce GTX 1060 has a memory size of 6 GiB. It has GDDR5 with a 192-bit wide bus and 8GHz memory clock.

    (6 GiB/2/4 doubles/8bytes × 10243)1/3 = 465 × 465 × 465 3D mesh

    For single precision

    (6 GiB/2/4floats/4bytes × 10243)1/3 = 586 × 586 × 586 3D mesh

    If we are dividing up our computational domain into this 3D mesh, this is a 25% improvement in resolution.

***B.11 Chapter 11: Directive-based GPU programming***

1.  Find what compilers are available for your local GPU system. Are both OpenACC and OpenMP compilers available? If not, do you have access to any systems that would allow you to try out these pragma-based languages?

    Answer: On your own

2.  Run the stream triad examples from the OpenACC/StreamTriad and/or the OpenMP/StreamTriad directories on your local GPU development system. You’ll find these directories at <https://github.com/EssentialsofParallelComputing/Chapter11>.

    Answer: On your own

3.  Compare your results from exercise 2 to BabelStream results at <https://uob-hpc.github.io/BabelStream/results/>. For the stream triad, the bytes moved are `3 * nsize * sizeof(datatype)`.

    Answer: From the performance results in the chapter for the NVIDIA V100 GPU

    3 × 20,000,000 × 8 bytes/.586 ms) × (1000 ms/s) / (1,000,000,000 bytes/GB) = 819 GB/s

    This is about 50% greater than the peak shown for the BabelStream benchmark for the NVIDIA P100 GPU.

4.  Modify the OpenMP data region mapping in listing 11.16 to reflect the actual use of the arrays in the kernels.

    Answer: The arrays are only used on the GPU, so these can be allocated there and deleted at the end. Therefore, the changes are

    > `13 #pragma omp target enter data map(`**`alloc`**`:a[0:nsize], b[0:nsize],`  
    > `                                           c[0:nsize])`  
    > `36 #pragma omp target exit data map(`**`delete`**`:a[0:nsize], b[0:nsize],`  
    > `                                           c[0:nsize])`

    The full listing of this change is in Stream_par7.c in the examples for the chapter.

5.  Implement the mass sum example from listing 11.4 in OpenMP.

    Answer: We just need to change the one pragma as the following listing shows.

    **Listing B.11.5 GPU version of OpenMP**

    > `ExerciseB.11.5/mass_sum.c`  
    > `1 #include "mass_sum.h"`  
    > `2 #define REAL_CELL 1`  
    > `3`  
    > `4 double mass_sum(int ncells, int* restrict celltype,`  
    > `5        double* restrict H, double* restrict dx, double* restrict dy){`  
    > `6    double summer = 0.0;`  
    > `7 #pragma omp target teams distribute \`  
    > `               parallel for simd reduction(+:summer)`  
    > `8    for (int ic=0; ic<ncells ; ic++) {`  
    > `9       if (celltype[ic] == REAL_CELL) {`  
    > `10          summer += H[ic]*dx[ic]*dy[ic];`  
    > `11       }`  
    > `12    }`  
    > `13    return(summer);`  
    > `14 }`

6.  For x and y arrays of size 20,000,000, find the maximum radius for the arrays using both OpenMP and OpenACC. Initialize the arrays with double-precision values that linearly increase from 1.0 to 2.0e7 for the x array and decrease from 2.0e7 to 1.0 for the y array.

    Answer: The following listing shows a possible implementation of finding the maximum radius using OpenACC.

    **Listing B.11.6 OpenACC version of Max Radius**

    > `ExerciseB.11.6/MaxRadius.c or Chapter11/OpenACC/MaxRadius/MaxRadius.c`  
    > `1 #include <stdio.h>`  
    > `2 #include <math.h>`  
    > `3 #include <openacc.h>`  
    > `4`  
    > `5 int main(int argc, char *argv[]){`  
    > `6    int ncells = 20000000;`  
    > `7    double* restrict x = acc_malloc(ncells * sizeof(double));`  
    > `8    double* restrict y = acc_malloc(ncells * sizeof(double));`  
    > `9`  
    > `10    double MaxRadius = -1.0e30;`  
    > `11 #pragma acc parallel deviceptr(x, y)`  
    > `12    {`  
    > `13 #pragma acc loop`  
    > `14       for (int ic=0; ic<ncells; ic++) {`  
    > `15          x[ic] = (double)(ic+1);`  
    > `16          y[ic] = (double)(ncells-ic);`  
    > `17       }`  
    > `18`  
    > `19 #pragma acc loop reduction(max:MaxRadius)`  
    > `20       for (int ic=0; ic<ncells ; ic++) {`  
    > `21          double radius = sqrt(x[ic]*x[ic] + y[ic]*y[ic]);`  
    > `22          if (radius > MaxRadius) MaxRadius = radius;`  
    > `23       }`  
    > `24    }`  
    > `25    printf("Maximum Radius is %lf\n",MaxRadius);`  
    > `26`  
    > `27    acc_free(x);`  
    > `28    acc_free(y);`  
    > `29 }`

***B.12 Chapter 12: GPU languages: Getting down to basics***

1.  Change the host memory allocation in the CUDA stream triad example to use pinned memory (listings 12.1-12.6). Did you get a performance improvement?

    Answer: To get pinned memory, replace `malloc` in the host-side memory allocation with `cudaHostMalloc` and the free memory with `cudaFreeHost` as listing B.12.1 shows. In the listing, we only display the lines that need to be changed. Compare the performance to the code from chapter12 in CUDA/StreamTriad directory. The data transfer time should be at least a factor of two times faster with pinned memory.

    **Listing B.12.1 Pinned memory version of stream triad**

    > `ExerciseB.12.1/StreamTriad.cu`  
    > `31    // allocate host memory and initialize`  
    > `32    double *a, *b, *c;`  
    > `33    cudaMallocHost(&a,stream_array_size*sizeof(double));`  
    > `34    cudaMallocHost(&b,stream_array_size*sizeof(double));`  
    > `35    cudaMallocHost(&c,stream_array_size*sizeof(double));`  
    > `       < ... steam triad code ... >`  
    > `86    cudaFreeHost(a);`  
    > `87    cudaFreeHost(b);`  
    > `88    cudaFreeHost(c);`

2.  For the sum reduction example, try an array size of 18,000 elements all initialized to their index value. Run the CUDA code and then the version in SumReductionRevealed. You may want to adjust the amount of information printed.

    Answer: On your own

3.  Convert the CUDA reduction example to HIP by hipifying it.

    Answer: On your own

4.  For the SYCL example in listing 12.20, initialize the `a` and `b` arrays on the GPU device.

    Answer: The following listing shows a version with the `a` and `b` arrays initialized on the GPU.

    **Listing B.12.4 Initializing arrays** **`a`** **and** **`b`** **in SYCL**

    > `14    // host data`  
    > `15    vector<double> a(nsize);`  
    > `16    vector<double> b(nsize);`  
    > `17    vector<double> c(nsize);`  
    > `18`  
    > `19    t1 = chrono::high_resolution_clock::now();`  
    > `20`  
    > `21    Sycl::queue Queue(sycl::cpu_selector{});`  
    > `22`  
    > `23    const double scalar = 3.0;`  
    > `24`  
    > `25    Sycl::buffer<double,1> dev_a { a.data(), Sycl::range<1>(a.size()) };`  
    > `26    Sycl::buffer<double,1> dev_b { b.data(), Sycl::range<1>(b.size()) };`  
    > `27    Sycl::buffer<double,1> dev_c { c.data(), Sycl::range<1>(c.size()) };`  
    > `28`  
    > `29    `**`Queue.submit([&](sycl::handler& CommandGroup) {`  
    > `30`  
    > `31       auto a =`  
    > `            dev_a.get_access<Sycl::access::mode::write>(CommandGroup);`  
    > `32       auto b =`  
    > `            dev_b.get_access<Sycl::access::mode::write>(CommandGroup);`  
    > `33       auto c =`  
    > `            dev_c.get_access<Sycl::access::mode::write>(CommandGroup);`  
    > `34`  
    > `35       CommandGroup.parallel_for<class StreamTriad>(`  
    > `             Sycl::range<1>{nsize}, [=] (Sycl::id<1> it) {`  
    > `36           a[it] =  1.0;`  
    > `37           b[it] =  2.0;`  
    > `38           c[it] = -1.0;`  
    > `39       });`  
    > `40    });`  
    > `41    Queue.wait();`**  
    > `42`  
    > `43    Queue.submit([&](sycl::handler& CommandGroup) {`  
    > `44`  
    > `45       auto a = dev_a.get_access<Sycl::access::mode::read>(CommandGroup);`  
    > `46       auto b = dev_b.get_access<Sycl::access::mode::read>(CommandGroup);`  
    > `47       auto c =`  
    > `            dev_c.get_access<Sycl::access::mode::write>(CommandGroup);`  
    > `48`  
    > `49       CommandGroup.parallel_for<class StreamTriad>(`  
    > `             Sycl::range<1>{nsize}, [=] (Sycl::id<1> it) {`  
    > `50           c[it] = a[it] + scalar * b[it];`  
    > `51       });`  
    > `52    });`  
    > `53    Queue.wait();`  
    > `54`  
    > `55    t2 = chrono::high_resolution_clock::now();`

5.  Convert the two initialization loops in the Raja example in listing 12.24 to the `Raja:forall` syntax. Try running the example with CUDA.

    Answer: The initialization loop needs the changes shown in the following listing. Then the stream triad code is built and run the same way as in section 12.5.2.

    **Listing B.12.5 Adding Raja to the initialization loop of stream triad**

    > `ExerciseB.12.5/StreamTriad.cc`  
    > `19 RAJA::forall<RAJA::omp_parallel_for_exec>(RAJA::RangeSegment(0,`  
    > `       nsize), [=] (int i) {`  
    > `20   a[i] = 1.0;`  
    > `21   b[i] = 2.0;`  
    > `22 });`

    With these changes, the run time compared to the original version in section 12.5.2 drops from around 6.59 ms to 1.67 ms.

***B.13 Chapter 13: GPU profiling and tools***

1.  Run nvprof on the STREAM Triad example. You might try the CUDA version from chapter 12 or the OpenACC version from chapter 11. What workflow did you use for your hardware resources? If you don’t have access to an NVIDIA GPU, can you use another profiling tool?

    Answer: On your own

2.  Generate a trace from nvprof and import it into NVVP. Where is the run time spent? What could you do to optimize it?

    Answer: On your own

3.  Download a prebuilt Docker container from the appropriate vendor for your system. Start up the container and run one of the examples from chapter 11 or 12.

    Answer: On your own

***B.14 Chapter 14: Affinity: Truce with the kernel***

1.  Generate a visual image of a couple of different hardware architectures. Discover the hardware characteristics for these devices.

    Answer: Use the lstopo tool to generate an image of your architecture.

2.  For your hardware, run the test suite using the script in listing 14.4. What do you discover about how to best use your system?

    Answer: On your own

3.  Change the program used in the vector addition (vecadd_opt3.c) example in section 14.3 to include more floating-point operations. Take the kernel and change the operations in the loop to the Pythagorean formula:

    > `c[i] = sqrt(a[i] * a[i] + b[i] * b[i]);`

    How do your results and conclusions about the best placement and bindings change? Do you see benefit from hyperthreads now (if you have those)?

    Answer: On your own

4.  For the MPI example in section 14.4, include the vector add kernel and generate a scaling graph for the kernel. Then replace the kernel with the Pythagorean formula used in exercise 3.

    Answer: On your own

5.  Replace the kernel with the Pythagorean formula used in exercise 3.

    Answer: On your own

6.  Combine the vector add and Pythagorean formula in the following routine (either in a single loop or two separate loops) to get more data reuse:

    > `c[i] = a[i] + b[i];`  
    > `d[i] = sqrt(a[i]*a[i] + b[i]*b[i]);`

    How does this change the results of the placement and binding study?

    Answer: On your own

7.  Add code to set the placement and affinity within the application from one of the previous exercises.

    Answer: On your own

***B.15 Chapter 15: Batch schedulers: Bringing order to chaos***

1.  Try submitting a couple of jobs, one with 32 processors and one with 16 processors. Check to see that these are submitted and whether they are running. Delete the 32 processor job. Check to see that it got deleted.

    Answer: On your own

2.  Modify the automatic restart script so that the first job is a preprocessing step to set up for the computation and the restarts are for running the simulation.

    Answer: To insert a preprocessing step, we need to insert another conditional case as the following listing shows on lines 31-36 and then use the PREPROCESS_DONE file to indicate that the preprocessing has been done.

    **Listing B.15.2a Inserting preprocessing step and then automatically restarting**

    > `ExerciseB.15.2/Preprocess_then_restart.sh`  
    > `1 #!/bin/sh`  
    > `2 #SBATCH -N 1`  
    > `3 #SBATCH -n 4`  
    > `4 #SBATCH --signal=23@160`  
    > `5 #SBATCH -t 00:08:00`  
    > `6`  
    > `7 # Do not place bash commands before the last SBATCH directive`  
    > `8 # Behavior can be unreliable`  
    > `9`  
    > `10 NUM_CPUS=4`  
    > `11 OUTPUT_FILE=run.out`  
    > `12 EXEC_NAME=./testapp`  
    > `13 MAX_RESTARTS=4`  
    > `14`  
    > `15 if [ -z ${COUNT} ]; then`  
    > `16    export COUNT=0`  
    > `17 fi`  
    > `18`  
    > `19 ((COUNT++))`  
    > `20 echo "Restart COUNT is ${COUNT}"`  
    > `21`  
    > `22 if [ ! -e DONE ]; then`  
    > `23    if [ -e RESTART ]; then`  
    > `24       echo "=== Restarting ${EXEC_NAME} ==="            >> ${OUTPUT_FILE}`  
    > `` 25       cycle=`cat RESTART` ``  
    > `26       rm -f RESTART`  
    > `27    elif [ -e PREPROCESS_DONE ]; then`  
    > `28       echo "=== Starting problem ==="                   >> ${OUTPUT_FILE}`  
    > `29       cycle=""`  
    > `30    else`  
    > `31       echo "=== Preprocessing data for problem ==="     >> ${OUTPUT_FILE}`  
    > `32       mpirun -n ${NUM_CPUS} ./preprocess_data          &>> ${OUTPUT_FILE}`  
    > `33       date > PREPROCESS_DONE`  
    > `34       sbatch \                                                          `❶  
    > `            --dependency=afterok:${SLURM_JOB_ID} \                         `❶  
    > `            <preprocess_then_restart.sh                                    `❶  
    > `35       exit`  
    > `36    fi`  
    > `37`  
    > `38    echo "=== Submitting restart script ==="             >> ${OUTPUT_FILE}`  
    > `39    sbatch \                                                             `❷  
    > `         --dependency=afterok:${SLURM_JOB_ID} \                            `❷  
    > `         <preprocess_then_restart.sh                                       `❷  
    > `40`  
    > `41    mpirun -n ${NUM_CPUS} ${EXEC_NAME} ${cycle}         &>> ${OUTPUT_FILE}`  
    > `42    echo "Finished mpirun"                               >> ${OUTPUT_FILE}`  
    > `43`  
    > `44    if [ ${COUNT} -ge ${MAX_RESTARTS} ]; then`  
    > `45       echo "=== Reached maximum number of restarts ===" >> ${OUTPUT_FILE}`  
    > `46       date > DONE`  
    > `47    fi`  
    > `48 fi`

    ❶ Submits first calculation job after preprocess

    ❷ Submits restart job

    Often the preprocessing step needs a different number of processors. In this case, we can use a separate batch script for the preprocessing, shown in the following listing.

    **Listing B.15.2b Smaller preprocessing step and then automatic restart**

    > `ExerciseB.15.2/Preprocess_batch.sh`  
    > `1 #!/bin/sh`  
    > `2 #SBATCH -N 1`  
    > `3 #SBATCH -n 1`  
    > `5 #SBATCH -t 01:00:00`  
    > `6`  
    > `7 sbatch --dependency=afterok:${SLURM_JOB_ID} <batch_restart.sh`  
    > `9`  
    > `10 mpirun -n 4 ./preprocess &> preprocess.out`

3.  Modify the simple batch script in listing 15.1 for Slurm and 15.2 for PBS to clean up on failure by removing a file called simulation_database.

    Answer: Change the Slurm batch script to check the status of the command and remove the simulation database. There are several different ways to do the cleanup. Here are three. The first two in listings B.15.3a and b use the exit code from the `mpirun` command.

    **Listing B.15.3a OpenACC version of Max Radius**

    > `ExerciseB.15.3/batch_simple_error.sh`  
    > `1 #!/bin/sh`  
    > `2 #SBATCH -N 1`  
    > `3 #SBATCH -n 4`  
    > `5 #SBATCH -t 01:00:00`  
    > `6`  
    > `7 mpirun -n 4 ./testapp &> run.out || \    `❶  
    > `      rm -f simulation_database             `❶

    ❶ The \|\| symbol executes the command for non-zero status values

    **Listing B.15.3b OpenACC version of Max Radius**

    > `ExerciseB.15.3/batch_simple_error.sh`  
    > `1 #!/bin/sh`  
    > `2 #SBATCH -N 1`  
    > `3 #SBATCH -n 4`  
    > `5 #SBATCH -t 01:00:00`  
    > `6`  
    > `7 mpirun -n 4 ./testapp &> run.out`  
    > `8 STATUS=$?`  
    > `9 if [ ${STATUS} != “0” ]; then`  
    > `10    rm -f simulation_database`  
    > `11 fi`

    The third version in listing B.15.3.b uses the status condition of the batch job through a dependency flag to invoke a cleanup job. The types of errors that are handled are different than the first two methods.

    **Listing B.15.3b OpenACC version of Max Radius**

    > `ExerciseB.15.3/batch.sh`  
    > `1 #!/bin/sh`  
    > `2 #SBATCH -N 1`  
    > `3 #SBATCH -n 4`  
    > `5 #SBATCH -t 01:00:00`  
    > `6`  
    > `7 sbatch --dependency=afternotok:${SLURM_JOB_ID} <batch_cleanup.sh`  
    > `9`  
    > `10 mpirun -n 4 ./testapp &> run.out`  
    >   
    > `ExerciseB.15.3/batch_cleanup.sh`  
    > `1 #!/bin/sh`  
    > `2 #SBATCH -N 1`  
    > `3 #SBATCH -n 1`  
    > `5 #SBATCH -t 00:10:00`  
    > `6 rm -f simulation_database`

***B.16 Chapter 16: File operations for a parallel world***

1.  Check for the hints available on your system using the techniques described in section 16.6.1.

    Answer: On your own

2.  Try the MPI-IO and HDF5 examples on your system with much larger datasets to see what performance you can achieve. Compare that to the IOR micro benchmark for extra credit.

    Answer: On your own

3.  Use the h5ls and h5dump utilities to explore the HDF5 data file created by the example.

    Answer: On your own

***B.17 Chapter 17: Tools and resources for better code***

1.  Run the Dr. Memory tool on one of your small codes or one of the codes from the exercises in this book.

    Answer: On your own

2.  Compile one of your codes with the dmalloc library. Run your code and view the results.

    Answer: On your own

3.  Try inserting a thread race condition into the example code in section 17.6.2 and see how Archer reports the problem.

    Answer: On your own

4.  Try the profiling exercise in section 17.8 on your filesystem. If you have more than one filesystem, try it on each one. Then change the size of the array in the example to 2000x2000. How does it change the filesystem performance results?

    Answer: On your own

5.  Install one of the tools using the Spack package manager.

    Answer: On your own
