# 12 GPU languages: Getting down to basics

***12 GPU languages: Getting down to basics***

This chapter covers

- Understanding the current landscape of native GPU languages
- Creating simple GPU programs in each language
- Tackling more complex multi-kernel operations
- Porting between various GPU languages

This chapter covers lower-level languages for GPUs. We call these native languages because they directly reflect features of the target GPU hardware. We cover two of these languages, CUDA and OpenCL, that are widely used. We also cover HIP, a new variant for AMD GPUs. In contrast to the pragma-based implementation, these GPU languages have a smaller reliance on the compiler. You should use these languages for more fine-tuned control of your program’s performance. How are these languages different than those presented in chapter 11? Our distinction is that these languages have grown up from the characteristics of the GPU and CPU hardware, while the OpenACC and OpenMP languages started with high-level abstractions and rely on a compiler to map those to different hardware.

The set of native GPU languages, CUDA, OpenCL, and HIP, requires a separate source to be created for the GPU kernel. The separate source code is often similar to the CPU code. The challenges of having two different sources to maintain is a major difficulty. If the native GPU language only supports one type of hardware, then there can be even more source variants to maintain if you want to run on more than one vendor’s GPU. Some applications have implemented their algorithms in multiple GPU languages and CPU languages. Thus, you can understand the critical need for more portable GPU programming languages.

Thankfully, portability is getting more attention with some of the newer GPU languages. OpenCL was the first open-standard language to run on a variety of GPU hardware and even CPUs. After an initial splash, OpenCL has not gotten as widespread an acceptance as originally hoped for. Another language, HIP, is designed by AMD as a more portable version of CUDA, which generates code for AMD’s GPUs. As part of AMD’s portability initiative, support for GPUs from other vendors is included.

The difference between these native languages and higher-level languages is blurring as new languages are introduced. The SYCL language, originally a C++ layer on top of OpenCL, is typical of these newer, more portable languages. Along with the Kokkos and RAJA languages, SYCL supports a single source for both CPU and GPU. We’ll touch on these languages at the end of the chapter. Figure 12.1 shows the current picture of the interoperability for the GPU languages that we cover in this chapter.

**Figure 12.1 The interoperability map for the GPU languages shows an increasingly complex situation. Four GPU languages are shown at the top with the various hardware devices at the bottom. The arrows show the code generation pathways from the languages to the hardware. The dashed lines are for hardware that is still in development.**

The focus on language interoperability is gaining traction as more diversity of GPUs appears in the largest HPC installations. The top Department of Energy HPC systems, Sierra and Summit, are provisioned with NVIDIA GPUs. In 2021, Argonne’s Aurora system with Intel GPUs and Oak Ridge’s Frontier system with AMD GPUs will be added to the list of Department of Energy HPC systems. With the introduction of the Aurora system, SYCL has emerged from near obscurity to become a major player with multiple implementations. SYCL was originally developed to provide a more natural C++ layer on top of OpenCL. The reason for the sudden emergence of SYCL was its adoption by Intel as part of the OneAPI programming model for Intel GPUs on the Aurora system. Because of SYCL’s new-found importance, we cover SYCL in section 12.4. A similar growth in interest in other languages and libraries that provide portability across the GPU landscape is also prevalent.

We end the chapter with a brief look at a couple of these performance portability systems, Kokkos and RAJA, that were created to ease the difficulty of running on a wide range of hardware, from CPUs to GPUs. These work at a slightly higher level of abstraction, but promise a single source that will run everywhere. Their development has resulted from a major Department of Energy effort to support the porting of large scientific applications to newer hardware. The aim of RAJA and Kokkos is a one-time rewrite to create a single-source code base that is portable and maintainable through a time of great change in hardware design.

Last, we want to provide guidance on how to approach this chapter. We cover a lot of different languages in a short space. The proliferation of languages reflects the lack of cooperation among language developers at this point in time, as developers chase their immediate goals and hardware concerns. Rather than treat these languages as different languages, think of them as slightly different dialects of one or two languages. We recommend that you seek to learn a couple of these languages and appreciate the differences and similarities with the others. We will be comparing and contrasting the languages to help you see that they are not all that different once you get over the particular syntax of each and their quirks. We do expect that the languages will merge to a more common form because the current situation is not sustainable. We already see the beginnings of that with the push for more language portability driven by the needs of large applications.

***12.1 Features of a native GPU programming language***

A GPU programming language must have several basic features. It is helpful to understand what these features are so that you can recognize these in each GPU language. We summarize the necessary GPU language features here.

- Detecting the accelerator device—The language must provide a detection of the accelerator devices and a way to choose between those devices. Some languages give more control over the selection of devices than others. Even for a language such as CUDA, which just looks for an NVIDIA GPU, there must be a way to handle multiple GPUs on a node.

- Support for writing device kernels—The language must provide a way to generate the low-level instructions for GPUs or other accelerators. GPUs provide nearly identical basic operations as CPUs, so the kernel language should not be dramatically different. Rather than invent a new language, the most straightforward way is to leverage current programming languages and compilers to generate the new instruction set. GPU languages have done this by adopting a particular version of the C or C++ language as a basis for their system. CUDA originally was based on the C programming language but now is based on C++ and has some support for the Standard Template Library (STL). OpenCL is based on the C99 standard and has released a new specification with C++ support.

> > > The language design also needs to address whether to have the host and design source code in the same file or in different files. Either way, the compiler must distinguish between the host and design sources and must provide a way to generate the instruction set for the different hardware. The compiler must even decide when to generate the instruction set. For example, OpenCL waits for the device to be selected and then generates the instruction set with a just-in-time (JIT) compiler approach.

- Mechanism to call device kernels from the host—Ok, now we have the device code, but we also have to have a way of calling the code from the host. The syntax for performing this operation varies the most across the various languages. But the mechanism is only slightly more complicated than a standard subroutine call.

- Memory handling—The language must have support for memory allocations, deallocations, and moving data back and forth from the host to the device. The most straightforward way for this is to have a subroutine call for each of these operations. But another way is through the compiler detecting when to move the data and doing it for you behind the scenes. As this is such a major part of GPU programming, innovation continues to occur on the hardware and software side for this functionality.

- Synchronization—A mechanism must be provided to specify the synchronization requirements between the CPU and the GPU. Synchronization operations must also be provided within kernels.

- Streams—A complete GPU language allows the scheduling of asynchronous streams of operations along with the explicit dependencies between the kernels and the memory transfer operations.

This is not such a scary list. For the most part, native GPU languages do not look so different than current CPU code. Also recognizing these commonalities among native GPU language functionality helps you to become comfortable moving from one language to another.

***12.2 CUDA and HIP GPU languages: The low-level performance option***

We will begin with a look at two of the low level GPU languages, CUDA and HIP. These are two of the most common languages for programming GPUs.

Compute Unified Device Architecture (CUDA) is a proprietary language from NVIDIA that only runs on their GPUs. First released in 2008, it is currently the dominant native programming language for GPUs. With a decade of development, CUDA has a rich set of features and performance enhancements. The CUDA language closely reflects the architecture of the NVIDIA GPU. It does not purport to be a general accelerator language. Still, the concepts of most accelerators are similar enough for the CUDA language design to be applicable.

The AMD (formerly ATI) GPUs have had a series of short-lived programming languages. These have finally settled on a CUDA look-a-like that can be generated by “HIPifying” CUDA code with their HIP compiler. This is part of the ROCm suite of tools that provide extensive portability between GPU languages, including the OpenCL language for GPUs (and CPUs) discussed in section 12.3.

***12.2.1 Writing and building your first CUDA application***

We’ll start with how to build and compile a simple CUDA application that runs on a GPU. We’ll use the stream triad example we have used throughout the book that implements a loop for this calculation: `C = A + scalar * B`. The CUDA compiler splits the regular C++ code to pass to the underlying C++ compiler. It then compiles the remaining CUDA code. Code from these two paths is linked together into a single executable.

To follow along with this example, you might first need to install the CUDA software.[1](#filepos1858816) Each release of CUDA works with a limited range of compiler versions. As of CUDA v10.2, GCC compilers up through v8 are supported. If you are working with multiple parallel languages and packages, this constantly-battling-the-compiler-version issue is perhaps one of the most frustrating things about CUDA. But on a positive note, you can use much of your regular toolchain and build systems with just the version constraints and a few special additions.

We’ll show three different approaches starting with a simple makefile and then a couple of different ways of using CMake. We encourage you to follow along with the examples for this chapter at [https://github.com/EssentialsofParallelComputing/ Chapter12](https://github.com/EssentialsofParallelComputing/Chapter12).

You can select this simple makefile for CUDA by copying or linking it to Makefile, the default filename for make. The following listing shows the makefile itself.

1.  To link to the file, type `ln -s Makefile.simple Makefile`

2.  Build the application with `make`

3.  Run the application with `./StreamTriad`

**Listing 12.1 A simple CUDA makefile**

> `CUDA/StreamTriad/Makefile.simple`  
> `1 all: StreamTriad`  
> `2`  
> `3 NVCC = nvcc                                  `❶  
> `4 #NVCC_FLAGS = -arch=sm_30                    `❷  
> `5 #CUDA_LIB = <path>                           `❷  
> `` 6 CUDA_LIB=`which nvcc | sed -e 's!/bin/nvcc!!'`/lib ``  
> `` 7 CUDA_LIB64=`which nvcc | sed -e 's!/bin/nvcc!!'`/lib64 ``  
> `8`  
> `9 %.o : %.cu                                   `❸  
> `10   ${NVCC} ${NVCC_FLAGS} -c $< -o $@          `❸  
> `11`  
> `12 StreamTriad: StreamTriad.o timer.o`  
> `13   ${CXX} -o $@ $^ -L${CUDA_LIB} -lcudart     `❹  
> `14`  
> `15 clean:`  
> `16   rm -rf StreamTriad *.o`

❶ Specifies NVIDIA CUDA compiler

❷ You may need to set library path and GPU architecture type here.

❸ Implicit rule to compile CUDA source files

❹ Link line for CUDA applications

The key addition is a pattern rule on lines 9-10, which converts a file with a .cu suffix into an object file. We use the NVIDIA NVCC compiler for this operation. We then need to add the CUDA runtime library, CUDART, to the link line. You can use lines 4 and 5 to specify a particular NVIDIA GPU architecture and a special path to the CUDA libraries.

> > > **DEFINITION** A pattern rule is a specification to the make utility that provides a general rule on how to convert any file with one suffix pattern to a file with another suffix pattern.

CUDA has extensive support in the CMake build system. Next, we cover both the old-style support and the new modern CMake approach that’s recently emerged. We show the old-style method in listing 12.2. It has the advantage of more portability for systems with older CMake versions and the automatic detection of the NVIDIA GPU architecture. This latter feature of detecting the hardware device is such a convenience that the old-style CMake is the recommended approach at present. To use this build system, link the CMakeLists_old.txt to CMakeLists.txt:

> `ln -s CMakeLists_old.txt CMakeLists.txt`  
> `mkdir build && cd build`  
> `cmake ..`  
> `make`

**Listing 12.2 Old style CUDA CMake file**

> `CUDA/StreamTriad/CMakeLists_old.txt`  
> `1 cmake_minimum_required (VERSION 2.8)                `❶  
> `2 project (StreamTriad)`  
> `3`  
> `4 find_package(CUDA REQUIRED)                         `❷  
> `5`  
> `6 set (CMAKE_CXX_STANDARD 11)`  
> `7 set (CMAKE_CUDA_STANDARD 11)`  
> `8`  
> `9 # sets CMAKE_{C,CXX}_FLAGS from CUDA compile flags.`  
> `   # Includes DEBUG and RELEASE`  
> `10 set (CUDA_PROPAGATE_HOST_FLAGS ON) # default is on`  
> `11 set (CUDA_SEPARABLE_COMPILATION ON)                 `❸  
> `12`  
> `13 if (CMAKE_VERSION VERSION_GREATER "3.9.0")`  
> `14    cuda_select_nvcc_arch_flags(ARCH_FLAGS)          `❹  
> `15 endif()`  
> `16`  
> `17 set (CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS}             `❺  
> `        -O3 ${ARCH_FLAGS})                             `❺  
> `18`  
> `19 # Adds build target of StreamTriad with source code files`  
> `20 cuda_add_executable(StreamTriad                     `❻  
> `      StreamTriad.cu timer.c timer.h)                  `❻  
> `21`  
> `22 if (APPLE)`  
> `23    set_property(TARGET StreamTriad PROPERTY BUILD_RPATH`  
> `        ${CMAKE_CUDA_IMPLICIT_LINK_DIRECTORIES})`  
> `24 endif (APPLE)`  
> `25`  
> `26 # Cleanup`  
> `27 add_custom_target(distclean COMMAND rm -rf CMakeCache.txt CMakeFiles`  
> `28                   Makefile cmake_install.cmake`  
> `                     StreamTriad.dSYM ipo_out.optrpt)`  
> `29`  
> `30 # Adds a make clean_cuda_depends target`  
> `   #    -- invoke with "make clean_cuda_depends"`  
> `31 CUDA_BUILD_CLEAN_TARGET()`

❶ You need a minimum of CMake v2.8 for CUDA support.

❷ Traditional CMake module sets compiler flags.

❸ Set to “on” for calling functions in other compile units (default off)

❹ Detects and sets proper architecture flag for current NVIDIA GPU

❺ Sets the compiler flags for the NVIDIA compiler

❻ Sets the proper build and link flags for a CUDA executable

Much of the CMake build system is standard. The separable compilation attribute on line 11 is suggested for a more robust build system for general development. You can then turn it off at a later stage to save a few registers in the CUDA kernels to get a small optimization in the generated code. The CUDA defaults are for performance, not for a more general, robust build. The automatic detection of the NVIDIA GPU architecture on line 14 is a significant convenience that keeps you from having to manually modify your makefile.

With version 3.0, CMake is undergoing a fairly major revision to its structure to what they call “modern” CMake. The key attributes of this style are a more integrated system and a per target application of attributes. Nowhere is it more apparent than in its support of CUDA. Let’s take a look at the listing 12.3 to see how to use it. To use this build system for the modern, new style CMake support for CUDA, link the CMakeLists_new.txt to CMakeLists.txt:

> `ln -s CMakeLists_new.txt CMakeLists.txt`  
> `mkdir build && cd build`  
> `cmake ..`  
> `make`

**Listing 12.3 New style (modern) CUDA CMake file**

> `CUDA/StreamTriad/CMakeLists_new.txt`  
> `  1 cmake_minimum_required (VERSION 3.8)           `❶  
> `2 project (StreamTriad)`  
> `3`  
> `4 enable_language(CXX CUDA)                       `❷  
> `5`  
> `6 set (CMAKE_CXX_STANDARD 11)`  
> `7 set (CMAKE_CUDA_STANDARD 11)`  
> `8`  
> `9 #set (ARCH_FLAGS -arch=sm_30)                   `❸  
> `10 set (CMAKE_CUDA_FLAGS ${CMAKE_CUDA_FLAGS};      `❹  
> `        "-O3 ${ARCH_FLAGS}")                       `❹  
> `11`  
> `12 # Adds build target of StreamTriad with source code files`  
> `13 add_executable(StreamTriad StreamTriad.cu timer.c timer.h)`  
> `14`  
> `15 set_target_properties(StreamTriad PROPERTIES    `❺  
> `      CUDA_SEPARABLE_COMPILATION ON)               `❺  
> `16`  
> `17 if (APPLE)`  
> `18     set_property(TARGET StreamTriad PROPERTY BUILD_RPATH`  
> `          ${CMAKE_CUDA_IMPLICIT_LINK_DIRECTORIES})`  
> `19 endif(APPLE)`  
> `20`  
> `21 # Cleanup`  
> `22 add_custom_target(distclean COMMAND rm -rf CMakeCache.txt CMakeFiles`  
> `23                   Makefile cmake_install.cmake`  
> `                     StreamTriad.dSYM ipo_out.optrpt)`

❶ Requires CMake v3.8

❷ Enabes CUDA as the language

❸ Manually sets the CUDA architecture

❹ Sets the compile flags for CUDA

❺ Sets the separable compilation flag

The first thing to note with this modern CMake approach is how much simpler it is than the old style. The key is the enabling of the CUDA as the language in line 4. From then on, little additional work needs to be done.

We can set the flags to compile for a specific GPU architecture as shown in lines 9-10. However, we don’t have an automatic way to detect the architecture yet with the modern CMake style. Without an architecture flag, the compiler generates code and optimizes for the sm_30 GPU device. The sm_30 generated code runs on any device from Kepler K40 or newer, but it will not be optimized for the latest architectures. You can also specify multiple architectures in one compiler. Compiles will be slower, and the generated executable will be larger.

We can also set the separable compilation attribute for CUDA, but in a different syntax in which it applies to the specific target. The optimization flag on line 10, `-O3`, is only sent to the host compiler for the regular C++ code. The default optimization level for CUDA code is `-O3` and seldom needs to be modified.

Overall, the process of building a CUDA program is easy and getting easier. Expect changes to the build to continue, however. Clang is adding native support for compiling CUDA code to give you another option besides the NVIDIA compiler. Now let’s move on to the source code. We’ll begin with the kernel for the GPU in the following listing.

**Listing 12.4 CUDA version of stream triad: The kernel**

> `CUDA/StreamTriad/StreamTriad.cu`  
> `2 __global__ void StreamTriad(`  
> `3                const int n,`  
> `4                const double scalar,`  
> `5                const double *a,`  
> `6                const double *b,`  
> `7                      double *c)`  
> `8 {`  
> `9    int i = blockIdx.x*blockDim.x+threadIdx.x;    `❶  
> `10`  
> `11    // Protect from going out-of-bounds`  
> `12    if (i >= n) return;                           `❷  
> `13`  
> `14    c[i] = a[i] + scalar*b[i];                    `❸  
> `15 }`

❶ Gets cell index

❷ Protects from going out-of-bounds

❸ stream triad body

As is typical with GPU kernels, we strip the `for` loop from the computational block. This leaves the loop body on line 14. We need to add the conditional at line 12 to prevent accessing out-of-bounds data. Without this protection, kernels can randomly crash without a message. And then, in line 9, we get the global index from the block and thread variables set by the CUDA run time. Adding the `__global__` attribute to the subroutine tells the compiler that this is a GPU kernel that will be called from the host. Meanwhile on the host side, we have to set up the memory and make the kernel call. The following listing shows this process.

**Listing 12.5 CUDA version of stream triad: Set up and tear down**

> `CUDA/StreamTriad/StreamTriad.cu`  
> `31    // allocate host memory and initialize`  
> `32    double *a = (double *)malloc(                   `❶  
> `                  stream_array_size*sizeof(double));  `❶  
> `33    double *b = (double *)malloc(                   `❶  
> `                  stream_array_size*sizeof(double));  `❶  
> `34    double *c = (double *)malloc(                   `❶  
> `                  stream_array_size*sizeof(double));  `❶  
> `35`  
> `36    for (int i=0; i<stream_array_size; i++) {`  
> `37       a[i] = 1.0;                                  `❷  
> `38       b[i] = 2.0;                                  `❷  
> `39    }`  
> `40`  
> `41    // allocate device memory. suffix of _d indicates a device pointer`  
> `42    double *a_d, *b_d, *c_d;`  
> `43    cudaMalloc(&a_d, stream_array_size*             `❸  
> `                       sizeof(double));               `❸  
> `44    cudaMalloc(&b_d, stream_array_size*             `❸  
> `                       sizeof(double));               `❸  
> `45    cudaMalloc(&c_d, stream_array_size*             `❸  
> `                       sizeof(double));               `❸  
> `46`  
> `47    // setting block size and padding total grid size`  
> `      //    to get even block sizes`  
> `48    int blocksize = 512;                            `❹  
> `49    int gridsize =                                  `❹  
> `         (stream_array_size + blocksize - 1)/         `❹  
> `          blocksize;                                  `❹  
> `50`  
> `       < ... timing loop ... code shown below in listing 12.6 >`  
>   
> `78    printf("Average runtime is %lf msecs data transfer is %lf msecs\n",`  
> `79            tkernel_sum/NTIMES, (ttotal_sum - tkernel_sum)/NTIMES);`  
> `80`  
> `81    cudaFree(a_d);                                  `❺  
> `82    cudaFree(b_d);                                  `❺  
> `83    cudaFree(c_d);                                  `❺  
> `84`  
> `85    free(a);                                        `❻  
> `86    free(b);                                        `❻  
> `87    free(c);                                        `❻  
> `88 }`

❶ Allocates host memory

❷ Initializes arrays

❸ Allocates device memory

❹ Sets block size and calculates number of blocks

❺ Frees device memory

❻ Frees host memory

First, we allocate memory on the host and initialize it on lines 31-39. We also need a corresponding memory space on the GPU to hold the arrays while the GPU is operating on those. For that, we use the `cudaMalloc` routine on lines 43-45. Now we come to some interesting lines (from 47-49) that are needed solely for the GPU. The block size is the size of the workgroup on the GPU. This is known by the tile size, block size, or workgroup size, depending on the GPU programming language being used (see table 10.1). The next line that calculates the grid size is characteristic of GPU code. We won’t always have an array size that is an even integer multiple of the block size. So, we need to have an integer that is equal to or greater than the fractional number of blocks. Let’s work through an example to understand what is being done.

> **Example: Calculating block size for the GPU**

> On line 3 in the following listing, we calculate the fractional number of blocks. For this example with an array size of 1,000, it is 1.95 blocks. Rather than truncate this to 1, which is what would happen with the default application of integer arithmetic, we need to round up to 2. If we just calculated array size divided by the block size, we would get integer truncation. So we have to cast each of these to a floating-point value to get floating-point division. We actually only need to cast one of the values, and the C/C++ standard requires the compiler to promote the other items. But in our programming conventions, a type conversion must be explicitly called for or it is a programming error. Compilers often don’t flag these cases, but they can mask unintended situations.

> The C `ceil` function used on lines 4 and 5 in the listing rounds up to the next integer value equal to or greater than the floating-point number. We can get the same result with integer arithmetic by adding one less than the block size and then performing integer division with truncation as is done on line 6. We choose to use this version because the integer form does not require any floating-point operations and should be faster.

> `1 int stream_array_size = 1000`  
> `2 int blocksize = 512`  
> `3 float frac_blocks = (float)stream_array_size/(float)blocksize;`  
> `>>>frac_blocks = 1.95`  
> `4 int nblocks = ceil(frac_blocks);`  
> `>>> nblocks = 2`

> or

> `5 int nblocks = ceil((float)stream_array_size/(float)blocksize);`

> or

> `6 int nblocks = (stream_array_size + blocksize - 1)/blocksize;`

Now all the blocks but the last one have 512 values. The last block will be size 512, but will contain only 488 data items. The out-of-bounds check on line 12 of listing 12.4 keeps us from getting in trouble with this partially filled block. The last few lines in listing 12.5 free the device pointers and the host pointers. You must be careful to use `cudaFree` for the device pointers and the C library function, `free`, for host pointers.

All we have left is to copy memory to the GPU, call the GPU kernel, and copy the memory back. We do this in a timing loop (in listing 12.6) that can be executed multiple times to get a better measurement. Sometimes the first call to a GPU will be slower due to initialization costs. We can amortize it by running several iterations. If this is not sufficient, you can also throw away the timing from the first iteration.

**Listing 12.6 CUDA version of stream triad: Kernel call and timing loop**

> `CUDA/StreamTriad/StreamTriad.cu`  
> `51 for (int k=0; k<NTIMES; k++){`  
> `52    cpu_timer_start(&ttotal);`  
> `53    cudaMemcpy(a_d, a, stream_array_size*           `❶  
> `         sizeof(double), cudaMemcpyHostToDevice);     `❶  
> `54    cudaMemcpy(b_d, b, stream_array_size*           `❶  
> `         sizeof(double), cudaMemcpyHostToDevice);     `❶  
> `55    // cuda memcopy to device returns after buffer available`  
> `56    cudaDeviceSynchronize();                        `❷  
> `57`  
> `58    cpu_timer_start(&tkernel);`  
> `59    StreamTriad<<<gridsize, blocksize>>>            `❸  
> `         (stream_array_size, scalar, a_d, b_d, c_d);  `❸  
> `60    cudaDeviceSynchronize();                        `❹  
> `61    tkernel_sum += cpu_timer_stop(tkernel);`  
> `62`  
> `63    // cuda memcpy from device to host blocks for completion`  
> `      //   so no need for synchronize`  
> `64    cudaMemcpy(c, c_d, stream_array_size*           `❺  
> `         sizeof(double), cudaMemcpyDeviceToHost);     `❺  
> `65    ttotal_sum += cpu_timer_stop(ttotal);`  
> `66    // check results and print errors if found.`  
> `      //    limit to only 10 errors per iteration`  
> `67    for (int i=0, icount=0; i<stream_array_size && icount < 10; i++){`  
> `68       if (c[i] != 1.0 + 3.0*2.0) {`  
> `69          printf("Error with result c[%d]=%lf on iter %d\n",i,c[i],k);`  
> `70          icount++;`  
> `71       } // if not correct, print error`  
> `72    } // result checking loop`  
> `73 } // timing for loop`

❶ Copies array data from host to device

❷ Synchronizes to get accurate timing for kernel only

❸ Launches StreamTriad kernel

❹ Forces completion to get timing

❺ Copies array data back from device to host

The pattern in the timing loop is composed of the following steps:

1.  Copy data to the GPU (lines 53-54)

2.  Call the GPU kernel to operate on the arrays (line 59)

3.  Copy the data back (line 64)

We add some synchronization and timer calls to get an accurate measurement of the GPU kernel. At the end of the loop, we then put in a check for the correctness of the result. Once this goes into production, we can remove the timing, synchronization, and the error check. The call to the GPU kernel can easily be spotted by the triple chevrons, or angle brackets. If we ignore the chevrons and the variables contained within these, the line has a typical C subroutine call syntax:

> `StreamTriad(stream_array_size, scalar, a_d, b_d, c_d);`

The values within the parentheses are the arguments to be passed to the GPU kernel. For example

> `<<<gridsize, blocksize>>>`

So what are the arguments contained within the chevrons? These are the arguments to the CUDA compiler on how to break up the problem into blocks for the GPU. Earlier, on lines 48 to 49 of listing 12.2, we set the block size and calculated the number of blocks, or grid size, to contain all the data in the array. The arguments in this case are 1D. We can also have 2D or 3D arrays by declaring and setting these arguments as follows for an NxN matrix.

> `dim3 blocksize(16,16); dim3 blocksize(8,8,8);`  
> `dim3 gridsize( (N + blocksize.x - 1)/blocksize.x,`  
> `               (N + blocksize.y - 1)/blocksize.y );`

We can speed up the memory transfers by eliminating a data copy. This is possible through a deeper understanding of how the operating system functions. Memory that is transferred over the network must be in a fixed location that cannot be moved during the operation. Normal memory allocations are placed into pageable memory, or memory that can be moved on demand. The memory transfer must first move the data into pinned memory, or memory that cannot be moved. We first saw the use of pinned memory in section 9.4.2 when benchmarking memory movement over the PCI bus. We can eliminate a memory copy by allocating our arrays in pinned memory rather than pageable memory. Figure 9.8 shows the difference in performance that we might obtain. Now, how do we make this happen?

CUDA gives us a function call, `cudaHostMalloc`, that does this for us. It is a straight-up replacement for the regular system `malloc` routines, with a slight change in arguments, where the pointer is returned as an argument as shown:

> `double *x_host = (double *)malloc(stream_array_size*sizeof(double));`  
> `cudaMallocHost((void**)&x_host, stream_array_size*sizeof(double));`

Is there a downside to using pinned memory? Well, if you do use a lot of pinned memory, there is no place to swap in another application. Swapping out the memory for one application and bringing in another is a huge convenience for users. This process is called memory paging.

> > > **DEFINITION** Memory paging in multi-user, multi-application operating systems is the process of moving memory pages temporarily out to disk so that another process can take place.

Memory paging is an important advance in operating systems to make it seem like you have more memory than you really do. For example, it allows you to temporarily start up Excel while working on Word and not have to close down your original application. It does this by writing your data out to disk and then reading it back when you return to Word. But this operation is expensive, so in high performance computing, we avoid memory paging because of the severe performance penalty that it incurs. Some heterogeneous computing systems with both a CPU and a GPU are implementing unified memory.

> > > **DEFINITION** Unified memory is memory that has the appearance of being a single address space for both the CPU and the GPU.

By now, you have seen that the handling of separate memory spaces on the CPU and the GPU introduces much of the complexity of writing GPU code. With unified memory, the GPU runtime system handles this for you. There may still be two separate arrays, but the data is moved automatically. On integrated GPUs, there is the possibility that memory does not have to be moved at all. Still, it is advisable to write your programs with explicit memory copies so that your programs are portable to systems without unified memory. The memory copy is skipped if it is not needed on the architecture.

***12.2.2 A reduction kernel in CUDA: Life gets complicated***

When we need cooperation among GPU threads, things get complicated with lower-level, native GPU languages. We’ll look at a simple summation example to see how we can deal with this. The example requires two separate CUDA kernels and is shown in listings 12.7-12.10. The following listing shows the first pass, where we sum up the values within a thread block and store the result back out to the reduction scratch array, `redscratch`.

**Listing 12.7 First pass of a sum reduction operation**

> `CUDA/SumReduction/SumReduction.cu (four parts)`  
> `23 __global__ void reduce_sum_stage1of2(`  
> `24                  const int      isize,      // 0  Total number of cells.`  
> `25                        double  *array,      // 1`  
> `26                        double  *blocksum,   // 2`  
> `27                        double  *redscratch) // 3`  
> `28 {`  
> `29     extern __shared__ double spad[];               `❶  
> `30     const unsigned int giX  = blockIdx.x*blockDim.x+threadIdx.x;`  
> `31     const unsigned int tiX  = threadIdx.x;`  
> `32`  
> `33     const unsigned int group_id = blockIdx.x;`  
> `34`  
> `35     spad[tiX] = 0.0;                               `❷  
> `36     if (giX < isize) {                             `❷  
> `37       spad[tiX] = array[giX];                      `❷  
> `38     }                                              `❷  
> `39`  
> `40     __syncthreads();                               `❸  
> `41`  
> `42     reduction_sum_within_block(spad);              `❹  
> `43`  
> `44     //  Write the local value back to an array`  
> `       //     the size of the number of groups`  
> `45     if (tiX == 0){                                 `❺  
> `46       redscratch[group_id] = spad[0];              `❺  
> `47       (*blocksum) = spad[0];`  
> `48     }`  
> `49 }`

❶ Scratchpad array in CUDA shared memory

❷ Loads memory into scratchpad array

❸ Synchronizes threads before using scratchpad data

❹ Sets reduction within thread block

❺ One thread stores result for block.

We start out the first pass by having all of the threads store their data into a scratchpad array in CUDA shared memory (lines 35-38). All the threads in the block can access this shared memory. Shared memory can be accessed in one or two processor cycles instead of the hundreds required for main GPU memory. You can think of shared memory as a programmable cache or as scratchpad memory. To make sure all the threads have completed the store, we use a synchronization call on line 40.

Because the reduction sum within the block is going to be used in both reduction passes, we put the code in a device subroutine and call it on line 42. A device subroutine is a subroutine that is to be called from another device subroutine rather than from the host. After the subroutine, the resulting sum is stored back out into a smaller scratch array that we read in during the second phase. We also store the result on line 47 in case the second pass can be skipped. Because we cannot access the values in other thread blocks, we have to complete the operation in a second pass in another kernel. In this first pass, we have reduced the length of the data by our block size.

Let’s move on to look at the common device code that we mentioned in the first pass. We will need a sum reduction for the CUDA thread block in both passes, so we write it as a general device routine. The code shown in the following listing can also be easily modified for other reduction operators and only needs small changes for HIP and OpenCL.

**Listing 12.8 Common sum reduction device kernel**

> `CUDA/SumReduction/SumReduction.cu (four parts)`  
> `1 #define MIN_REDUCE_SYNC_SIZE warpSize                   `❶  
> `2`  
> `3 __device__ void reduction_sum_within_block(double  *spad)`  
> `4 { `  
> `5    const unsigned int tiX  = threadIdx.x;`  
> `6    const unsigned int ntX  = blockDim.x;`  
> `7   `  
> `8    for (int offset = ntX >> 1; offset > MIN_REDUCE_SYNC_SIZE;`  
> `           offset >>= 1) {`  
> `9       if (tiX < offset) {                               `❷  
> `10          spad[tiX] = spad[tiX] + spad[tiX+offset];`  
> `11       }`  
> `12       __syncthreads();                                  `❸  
> `13    }`  
> `14    if (tiX < MIN_REDUCE_SYNC_SIZE) {`  
> `15       for (int offset = MIN_REDUCE_SYNC_SIZE; offset > 1; offset >>= 1) {`  
> `16          spad[tiX] = spad[tiX] + spad[tiX+offset];`  
> `17          __syncthreads();                               `❸  
> `18       }`  
> `19       spad[tiX] = spad[tiX] + spad[tiX+1];`  
> `20    }`  
> `21 }`

❶ CUDA defines warpSize to be 32

❷ Only use threads needed when greater than the warp size

❸ Synchronizes between every level of the pass

The common device routine that will be called from both passes is defined on line 3. It does a sum reduction within the thread block. The `__device__` attribute before the routine indicates that it will be called from a GPU kernel. The basic concept of the routine is a pair-wise reduction tree in O(log n) operations as figure 12.2 shows. The basic reduction tree from the figure is represented by the code on lines 15-18. We implement some minor modifications when the working set is larger than the warp size on lines 8-13 and for the final pass level on line 19 to avoid unnecessary synchronization.

**Figure 12.2 Pair-wise reduction tree for a warp that sums up values in log n steps.**

The same pair-wise reduction concept is used for the full-thread block that can be up to 1,024 on most GPU devices, though 128 to 256 is more commonly used. But what do you do if your array size is greater than 1,024? We add a second pass that uses just a single thread block as the following listing shows.

**Listing 12.9 Second pass for reduction operation**

> `CUDA/SumReduction/SumReduction.cu (four parts)`  
> `51 __global__ void reduce_sum_stage2of2(`  
> `52                  const int    isize,`  
> `53                        double *total_sum,`  
> `54                        double *redscratch)`  
> `55 { `  
> `56    extern __shared__ double spad[];`  
> `57    const unsigned int tiX  = threadIdx.x;`  
> `58    const unsigned int ntX  = blockDim.x;`  
> `59   `  
> `60    int giX = tiX;`  
> `61   `  
> `62    spad[tiX] = 0.0;`  
> `63   `  
> `64    // load the sum from reduction scratch, redscratch`  
> `65    if (tiX < isize) spad[tiX] = redscratch[giX];      `❶  
> `66   `  
> `67    for (giX += ntX; giX < isize; giX += ntX) {        `❷  
> `68       spad[tiX] += redscratch[giX];                   `❷  
> `69    }                                                  `❷  
> `70    `  
> `71    __syncthreads();                                   `❸  
> `72   `  
> `73    reduction_sum_within_block(spad);                  `❹  
> `74   `  
> `75    if (tiX == 0) {`  
> `76      (*total_sum) = spad[0];                          `❺  
> `77    }`  
> `78 }`

❶ Loads values into scratchpad array

❷ Loops by thread block-size increments to get all the data

❸ Synchronizes when scratchpad array is filled

❹ Calls our common block reduction routine

❺ One thread sets the total sum for return.

To avoid more than two kernels for larger arrays, we use one thread block and loop on lines 67-69 to read and sum any additional data into the shared scratchpad. We use a single thread block because we can synchronize within it, avoiding the need for another kernel call. If we are using thread block sizes of 128 and have a one million element array, the loop will sum in about 60 values into each location in shared memory (1000000/1282). The array size is reduced by 128 in the first pass and then we sum into a scratchpad that is size 128, giving us the division by 128 squared. If we use larger block sizes, such as 1,024, we could reduce the loop from 60 iterations to a single read. Now we just call the same common thread block reduction that we used before. The result will be the first value in the scratchpad array. The last part of this is to set up and call these two kernels from the host. We’ll see how this is done in the following listing.

**Listing 12.10 Host code for CUDA reduction**

> `CUDA/SumReduction/SumReduction.cu (four parts)`  
> `100 size_t blocksize = 128;                           `❶  
> `101 size_t blocksizebytes = blocksize*                `❶  
> `                            sizeof(double);           `❶  
> `102 size_t global_work_size = ((nsize + blocksize - 1) /blocksize) *`  
> `                              blocksize;`  
> `103 size_t gridsize = global_work_size/blocksize;     `❶  
> `104`  
> `105 double *dev_x, *dev_total_sum, *dev_redscratch;`  
> `106 cudaMalloc(&dev_x, nsize*sizeof(double));         `❷  
> `107 cudaMalloc(&dev_total_sum, 1*sizeof(double));     `❷  
> `108 cudaMalloc(&dev_redscratch,                       `❷  
> `               gridsize*sizeof(double));              `❷  
> `109`  
> `110 cudaMemcpy(dev_x, x, nsize*sizeof(double),        `❸  
> `               cudaMemcpyHostToDevice);               `❸  
> `111`  
> `112 reduce_sum_stage1of2                              `❹  
> `          <<<gridsize, blocksize, blocksizebytes>>>   `❹  
> `          (nsize, dev_x, dev_total_sum,               `❹  
> `           dev_redscratch);                           `❹  
> `113`  
> `114 if (gridsize > 1) {`  
> `115    reduce_sum_stage2of2                           `❺  
> `          <<<1, blocksize, blocksizebytes>>>          `❺  
> `          (nsize, dev_total_sum, dev_redscratch);     `❺  
> `116 }`  
> `117`  
> `118 double total_sum;`  
> `119 cudaMemcpy(&total_sum, dev_total_sum, 1*sizeof(double),`  
> `               cudaMemcpyDeviceToHost);`  
> `120 printf("Result -- total sum %lf \n",total_sum);`  
> `121`  
> `122 cudaFree(dev_redscratch);`  
> `123 cudaFree(dev_total_sum);`  
> `124 cudaFree(dev_x);`

❶ Calculates the block and grid sizes for the CUDA kernels

❷ Allocates device memory for the kernel

❸ Copies the array to the GPU device

❹ Calls the first pass of the reduction kernel

❺ If needed, calls the second pass

The host code first calculates the sizes for the kernel calls on lines 100-103. We then have to allocate the memory for the device arrays. For this operation, we need a scratch array where we can store the sums for each block from the first kernel. We allocate it on line 108 to be the grid size because that is the number of blocks that we have. We also need a shared memory scratchpad array that is the size of the block size. We calculate this size on line 101 and pass it into the kernel on lines 112 and 115 as the third parameter to the chevron operator. The third parameter is an optional parameter; this is the first time that we have seen it used. Take a look back at listing 12.9 (line 56) and listing 12.7 (line 29) to see where the corresponding code for the scratchpad is handled on the GPU device.

Trying to follow all the convoluted loops can be difficult. So we have created a version of the code that does the same loops on the CPU and prints its values as it goes along. It is in the CUDA/SumReductionRevealed directory at

<https://github.com/EssentialsofParallelComputing/Chapter12>

We don’t have room to show all the code here, but you might find it useful to explore and print the values as it executes. We show an edited version of the output in the following example.

> **Example: CUDA/SumReductionRevealed**

> `Calling first pass with gridsize 2 blocksize 128 blocksizebytes 1024`  
>   
> `SYNCTHREADS after all values are in shared memory block`  
> `Data count is 200`  
> `====== ITREE_LEVEL 1 offset 64 ntX is 128 MIN_REDUCE_SYNC_SIZE 32 ====`  
> `Data count is reduced to 128`  
> `Sync threads when larger than warp`  
> `====== ITREE_LEVEL 2 offset 32 ntX is 128 MIN_REDUCE_SYNC_SIZE 32 ====`  
> `Sync threads when smaller than warp`  
> `Data count is reduced to 64`  
> `====== ITREE_LEVEL 3 offset 16 ntX is 128 MIN_REDUCE_SYNC_SIZE 32 ====`  
> `Sync threads when smaller than warp`  
> `Data count is reduced to 32`  
> `====== ITREE_LEVEL 4 offset 8 ntX is 128 MIN_REDUCE_SYNC_SIZE 32 ====`  
> `Sync threads when smaller than warp`  
> `Data count is reduced to 16`  
> `====== ITREE_LEVEL 5 offset 4 ntX is 128 MIN_REDUCE_SYNC_SIZE 32 ====`  
> `Sync threads when smaller than warp`  
> `Data count is reduced to 8`  
> `====== ITREE_LEVEL 6 offset 2 ntX is 128 MIN_REDUCE_SYNC_SIZE 32 ====`  
> `Sync threads when smaller than warp`  
> `Data count is reduced to 4`  
> `====== ITREE_LEVEL 7 offset 1 ntX is 128 MIN_REDUCE_SYNC_SIZE 32 ====`  
> `Data count is reduced to 2`  
>   
> `Finished reduction sum within thread block`  
>   
> `End of first pass`  
>   
> `Synchronization in second pass after loading data`  
> `Data count is reduced to 2`  
>   
> `====== ITREE_LEVEL 8 offset 1 ntX is 128 MIN_REDUCE_SYNC_SIZE 32 ====`  
> `Data count is reduced to 1`  
>   
> `Finished reduction sum within thread block`  
> `Synchronization in second pass after reduction sum`  
> `Result -- total sum 19900 `

> This example is for an array that is 200 integers long with each element initialized to its index value. We suggest that you follow along with the source code and figure 12.1 to understand what is happening. The start and end of the first pass and the second pass are printed. We can see the data count being reduced by a factor of two until there are only two left at the end of the first pass. The second pass quickly reduces this to a single value containing the summation.

We have shown this thread block reduction as a general introduction to kernels that require thread cooperation. You can see how complicated this is, especially compared to the single line needed for the intrinsic call in Fortran. In the process, we also gained a lot of speedup over the CPU and kept the data on the GPU for this operation. This algorithm can be further optimized, but you can also consider using some library services such as CUDA UnBound (CUB), Thrust, or other GPU libraries.

***12.2.3 Hipifying the CUDA code***

CUDA code only runs on NVIDIA GPUs. But AMD has implemented a similar GPU language and named it the Heterogeneous Interface for Portability (HIP). It is part of the Radeon Open Compute platform (ROCm) suite of tools from AMD. If you program in the HIP language, you can call the hipcc compiler that uses NVCC on NVIDIA platforms and HCC on AMD GPUs.

To try these examples, you may need to install the ROCm suite of software and tools. The install process frequently changes, so check for the latest instructions. There are some instructions that accompany the examples as well.

> **Example: Simple makefile for HIPifying a CUDA code**

> There are two versions of the makefile. One uses `hipify-perl` and the other uses `hipify-clang`. The `hipify-perl` is a simple Perl script. For more syntax-aware translation, you can try the `hipify-clang`. In either case, for more complex programs, you might need to manually complete the last modifications. We’ll use the Perl version, so lets’s start by linking Makefile.perl, shown in the following listing, to Makefile:

> `ln -s Makefile.perl Makefile`  
> `make`

> **A simple makefile for HIP**

> `HIP/StreamTriad/Makefile.perl`  
> `1 all: StreamTriad`  
> `2`  
> `3 CXX = hipcc             `❶  
> `4`  
> `5 %.cc : %.cu              `❷  
> `6   hipify-perl $^ > $@    `❷  
> `7`  
> `8 StreamTriad: StreamTriad.o timer.o`  
> `9   ${CXX} -o $@ $^`  
> `10`  
> `11 clean:`  
> `12   rm -rf StreamTriad *.o StreamTriad.cc`

> ❶ Sets the C++ compiler to hipcc

> ❷ Converts the CUDA code to HIP code

> The only real addition to the standard makefile is changing the compiler to hipcc and adding a pattern rule for converting the CUDA source code into HIP source code. We could just do the code conversion by manually invoking the hipify-perl script and then use the HIP version for both CUDA and AMD GPUs.

There is also good support for HIP in CMake, and HIP support has been available since version 2.8.3 of CMake. A typical CMakeLists file for HIP is shown in the following listing.

**Listing 12.11 Building A HIP program with CMake**

> `HIP/StreamTriad/CMakeLists.txt`  
> `1 cmake_minimum_required (VERSION 2.8.3)                         `❶  
> `2 project (StreamTriad)`  
> `3`  
> `6 if(NOT DEFINED HIP_PATH)                                       `❷  
> `7     if(NOT DEFINED ENV{HIP_PATH})`  
> `8         set(HIP_PATH "/opt/rocm/hip" CACHE PATH "Path to HIP install")`  
> `9     else()`  
> `10         set(HIP_PATH $ENV{HIP_PATH} CACHE PATH "Path to HIP install")`  
> `11     endif()`  
> `12 endif()`  
> `13 set(CMAKE_MODULE_PATH "${HIP_PATH}/cmake" ${CMAKE_MODULE_PATH})`  
> `14`  
> `15 find_package(HIP REQUIRED)                                     `❸  
> `16 if(HIP_FOUND)`  
> `17     message(STATUS "Found HIP: " ${HIP_VERSION})`  
> `20 endif()`  
> `21`  
> `22 set(CMAKE_CXX_COMPILER ${HIP_HIPCC_EXECUTABLE})                `❹  
> `23 set(MY_HIPCC_OPTIONS )`  
> `24 set(MY_HCC_OPTIONS )`  
> `25 set(MY_NVCC_OPTIONS )`  
> `26`  
> `27 # Adds build target of StreamTriad with source code files`  
> `28 HIP_ADD_EXECUTABLE(StreamTriad StreamTriad.cc                  `❺  
> `                      timer.c timer.h)                            `❺  
> `29 target_include_directories(StreamTriad PRIVATE ${HIP_PATH}/include)`  
> `30 target_link_directories(StreamTriad PRIVATE ${HIP_PATH}/lib)`  
> `31 target_link_libraries(StreamTriad hip_hcc)`  
> `32`  
> `33 # Cleanup`  
> `34 add_custom_target(distclean COMMAND rm -rf CMakeCache.txt CMakeFiles *.o`  
> `35     Makefile cmake_install.cmake StreamTriad.dSYM ipo_out.optrpt)`

❶ Minimum version of CMake for HIP is 2.8.3

❷ Sets a path to the HIP installation

❸ Finds HIP using the path

❹ Sets the C++ compiler to hipcc

❺ Adds the executable, includes, and libraries

In the listing, we first try to set different path options for where the HIP install might be located and then call `find_package` for HIP on line 15. We then set the C++ compiler to `hipcc` on line 22. The `HIP_ADD_EXECUTABLE` command adds the build of our executable, and we round out the listing with settings for the HIP header files and libraries (lines 28-31). Now let’s turn our attention to the HIP source in listing 12.12. We highlight the changes from the CUDA version of the source code given in listings 12.5-12.6.

**Listing 12.12 The HIP differences for the stream triad**

> `HIP/StreamTriad/StreamTriad.c`  
> `1 #include "hip/hip_runtime.h"                       `❶  
> `       < . . . skipping . . . >`  
> `36    // allocate device memory. suffix of _d indicates a device pointer`  
> `37    double *a_d, *b_d, *c_d;`  
> `38    hipMalloc(&a_d, stream_array_size*              `❷  
> `                sizeof(double));                      `❷  
> `39    hipMalloc(&b_d, stream_array_size*              `❷  
> `                sizeof(double));                      `❷  
> `40    hipMalloc(&c_d, stream_array_size*              `❷  
> `                sizeof(double));                      `❷  
> `       < . . . skipping . . . >`  
> `46    for (int k=0; k<NTIMES; k++){`  
> `47       cpu_timer_start(&ttotal);`  
> `48       // copying array data from host to device`  
> `49       hipMemcpy(a_d, a, stream_array_size*`  
> `           sizeof(double), hipMemcpyHostToDevice);    `❸  
> `50       hipMemcpy(b_d, b, stream_array_size*`  
> `           sizeof(double), hipMemcpyHostToDevice);    `❸  
> `51       // cuda memcopy to device returns after buffer available,`  
> `52       // so synchronize to get accurate timing for kernel only`  
> `53       hipDeviceSynchronize();                      `❹  
> `54`  
> `55       cpu_timer_start(&tkernel);`  
> `56       // launch stream triad kernel`  
> `57       hipLaunchKernelGGL(StreamTriad,              `❺  
> `           dim3(gridsize), dim3(blocksize), 0, 0,     `❺  
> `           stream_array_size, scalar, a_d, b_d,       `❺  
> `                                             c_d);    `❺  
> `58       // need to force completion to get timing`  
> `59       hipDeviceSynchronize();                      `❹  
> `60       tkernel_sum += cpu_timer_stop(tkernel);`  
> `61`  
> `62       // cuda memcpy from device to host blocks for completion`  
> `         // so no need for synchronize`  
> `63       hipMemcpy(c, c_d, stream_array_size*         `❸  
> `           sizeof(double), hipMemcpyDeviceToHost);    `❸  
> `       < . . . skipping . . . >`  
> `72    }`  
> `       < . . . skipping . . . >`  
> `75`  
> `76    hipFree(a_d);                                   `❻  
> `77    hipFree(b_d);                                   `❻  
> `78    hipFree(c_d);                                   `❻

❶ We need to include the HIP run-time header.

❷ cudaMalloc becomes hipMalloc.

❸ cudaMemcpy becomes hipMemcpy.

❹ cudaDeviceSynchronize becomes hipDeviceSynchronize.

❺ hipLaunchKernel is a more traditional syntax than the CUDA kernel launch.

❻ hipFree replaces cudaFree.

To convert from CUDA source to HIP source, we replace all occurrences of `cuda` in the source with `hip`. The only more significant change is to the kernel launch call, where HIP uses a more traditional syntax than the triple chevron used in CUDA. Oddly enough, the greatest changes are to use the correct terminology in the variable naming for the two languages.

***12.3 OpenCL for a portable open source GPU language***

With the overwhelming need for portable GPU code, a new GPU programming language, OpenCL, emerged in 2008. OpenCL is an open standard GPU language that can run on both NVIDIA and AMD/ATI graphic cards, as well as many other hardware devices. The OpenCL standard effort was led by Apple with many other organizations involved. One of the nice things about OpenCL is that you can use virtually any C or even C++ compiler for the host code. For the GPU device code, OpenCL initially was based on a subset of C99. Recently, the 2.1 and 2.2 versions of OpenCL added C++ 14 support, but implementations are still not available.

The OpenCL release took off with a lot of initial excitement. Finally, here was a way to write portable GPU code. For example, GIMP announced that it would support OpenCL as a way for GPU acceleration to be made available on many hardware platforms. The reality has been less compelling. Many feel that OpenCL is too low-level and verbose for widespread acceptance. It may even be that its eventual role is as the low-level portability layer for higher level languages. But its value as a portable language across a diverse set of hardware devices has been demonstrated by its acceptance within the embedded device community for field-programmable gate arrays (FPGAs). One of the reasons OpenCL is thought to be verbose is that the device selection is more complicated (and powerful). You have to detect and select the device you will run on. This can amount to a hundred lines of code just to get started.

Nearly everyone who uses OpenCL writes a library to handle the low-level concerns. We are no exception. Our library is called EZCL. Nearly every OpenCL call is wrapped with at least a light layer to handle the error conditions. Device detection, compiling code, and error handling consume a lot of lines of code.

We’ll use an abbreviated version of our EZCL library, called EZCL_Lite, in our examples so that you can see the actual OpenCL calls. The EZCL_Lite routines are used to select the device and set it up for the application, then compile the device code and handle the errors. The code for these operations is too long to show here, so look at the examples in the OpenCL directory at [https://github.com/Essentialsof ParallelComputing/Chapter12](https://github.com/EssentialsofParallelComputing/Chapter12). The full EZCL library is also available in the directory. The EZCL routines give detailed errors with calls and on which line in the source code that it occurs.

Before you start out trying the OpenCL code, check to see if you have the proper setup and devices. For this, you can use the `clinfo` command.

> **Example: Getting information about the OpenCL installation**

> Run the OpenCL info command:

> `clinfo`

> If you get the following output, OpenCL is not set up or you do not have an appropriate OpenCL device:

> `Number of platforms    0`

> If you don’t have the `clinfo` command, try installing it with the appropriate command for your system. For Ubuntu, it is

> `sudo apt install clinfo`

> The examples that go along with the chapter include some brief hints for installation of OpenCL, but check for the latest information for your system. OpenCL has an extension that provides a detailed model for how each device should set up its driver in its Installable Client Driver (ICD) specification. This permits multiple OpenCL platforms and drivers to be available for an application.

***12.3.1 Writing and building your first OpenCL application***

The changes to a standard makefile to incorporate OpenCL are not too complicated. The typical changes are shown in listing 12.13. To use the simple makefile for OpenCL, type

> `ln -s Makefile.simple Makefile`

Then build the application with `make` and run the application with ./StreamTriad.

**Listing 12.13 OpenCL simple makefile**

> `OpenCL/StreamTriad/Makefile.simple`  
> `1 all: StreamTriad`  
> `2`  
> `3 #CFLAGS = -DDEVICE_DETECT_DEBUG=1     `❶  
> `4 #OPENCL_LIB = -L<path>`  
> `5`  
> `6 %.inc : %.cl                          `❷  
> `7   ./embed_source.pl $^ > $@           `❷  
> `8`  
> `9 StreamTriad.o: StreamTriad.c StreamTriad_kernel.inc`  
> `10`  
> `11 StreamTriad: StreamTriad.o timer.o ezclsmall.o`  
> `12   ${CC} -o $@ $^ ${OPENCL_LIB} -lOpenCL`  
> `13`  
> `14 clean:`  
> `15   rm -rf StreamTriad *.o StreamTriad_kernel.inc`

❶ Turns on device detection verbosity

❷ Pattern rule embeds the OpenCL source

The makefile includes a way to set the `DEVICE_DETECT_DEBUG` flag to print out detailed information on the GPU devices available. This flag turns on more verbosity in the ezcl_lite.c source code. It can be helpful for fixing problems with device detection or getting the wrong device. There is also the addition of a pattern rule on line 6 that embeds the OpenCL source into the program for use at run time. This Perl script converts the source into a comment and as a dependency on line 9. It will be included in the StreamTriad.c file with an `include` statement.

The embed_source.pl utility is one that we developed to link the OpenCL source directly into the executable. (See the chapter examples for the source to this utility.) The common way for OpenCL code to function is to have a separate source file that must be located at run time, which is then compiled once the device is known. Using a separate file creates problems with it not being able to be found or getting the wrong version of the file. We strongly recommend embedding the source into the executable to avoid these problems. We can also use CMake support for OpenCL in our build system as the following listing shows.

**Listing 12.14 OpenCL CMake file**

> `OpenCL/StreamTriad/CMakeLists.txt`  
> `1 cmake_minimum_required (VERSION 3.1)                                      `❶  
> `2 project (StreamTriad)`  
> `3`  
> `4 if (DEVICE_DETECT_DEBUG)                                                  `❷  
> `5    add_definitions(-DDEVICE_DETECT_DEBUG=1)                               `❷  
> `6 endif (DEVICE_DETECT_DEBUG)                                               `❷  
> `7`  
> `8 find_package(OpenCL REQUIRED)                                             `❶  
> `9 set(HAVE_CL_DOUBLE ON CACHE BOOL                                          `❸  
> `       "Have OpenCL Double")                                                 `❸  
> `10 set(NO_CL_DOUBLE OFF)                                                     `❸  
> `11 include_directories(${OpenCL_INCLUDE_DIRS})`  
> `12`  
> `13 # Adds build target of StreamTriad with source code files`  
> `14 add_executable(StreamTriad StreamTriad.c ezclsmall.c ezclsmall.h`  
> `                  timer.c timer.h)`  
> `15 target_link_libraries(StreamTriad ${OpenCL_LIBRARIES})`  
> `16 add_dependencies(StreamTriad StreamTriad_kernel_source)`  
> `17`  
> `18 ########### embed source target ##############                            `❹  
> `19 add_custom_command(OUTPUT                                                 `❹  
> `${CMAKE_CURRENT_BINARY_DIR}/StreamTriad_kernel.inc                          `❹  
> `20   COMMAND ${CMAKE_SOURCE_DIR}/embed_source.pl                             `❹  
> `     ${CMAKE_SOURCE_DIR}/StreamTriad_kernel.cl                               `❹  
> `     > StreamTriad_kernel.inc                                                `❹  
> `21         DEPENDS StreamTriad_kernel.cl ${CMAKE_SOURCE_DIR}/embed_source.pl)`❹  
> `22 add_custom_target(`  
> `          StreamTriad_kernel_source ALL DEPENDS                              `❹  
> `     ${CMAKE_CURRENT_BINARY_DIR}/`  
> `          StreamTriad_kernel.inc)                                            `❹  
> `23`  
> `24 # Cleanup`  
> `25 add_custom_target(distclean COMMAND rm -rf CMakeCache.txt CMakeFiles`  
> `26                   Makefile cmake_install.cmake StreamTriad.dSYM`  
> `                     ipo_out.optrpt)`  
> `27`  
> `28 SET_DIRECTORY_PROPERTIES(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES`  
> `                            "StreamTriad_kernel.inc")`

❶ CMake added OpenCL support with version 3.1.

❷ Turns on device detection verbosity

❸ Flags set CL_DOUBLE support

❹ Custom command embeds OpenCL source into executable

OpenCL support in CMake was added at version 3.1. We added this version requirement at the top of the CMakelists.txt file on line 1. There are a few other special things to note. For this example, we used the `-DDEVICE_DETECT_DEBUG=1` option to the CMake command to turn on the verbosity for the device detection. Also, we included a way to turn on and off support for OpenCL double precision. We used this in the EZCL_Lite code to set the just-in-time (JIT) compile flag for the OpenCL device code. Last, we added a custom command in lines 19-22 for embedding the OpenCL device source into the executable. The source code for the OpenCL kernel is in a separate file called StreamTriad_kernel.cl as shown in the following listing.

**Listing 12.15 OpenCL kernel**

> `OpenCL/StreamTriad/StreamTriad_kernel.cl`  
> `1 // OpenCL kernel version of stream triad`  
> `2 __kernel void StreamTriad(               `❶  
> `3                const int n,`  
> `4                const double scalar,`  
> `5       __global const double *a,`  
> `6       __global const double *b,`  
> `7       __global       double *c)`  
> `8 {`  
> `9    int i = get_global_id(0);             `❷  
> `10`  
> `11    // Protect from going out-of-bounds`  
> `12    if (i >= n) return;`  
> `13`  
> `14    c[i] = a[i] + scalar*b[i];`  
> `15 }`

❶ \_\_kernel attribute indicates this is called from the host.

❷ Gets the thread index

Compare this kernel code to the kernel code for CUDA in listing 12.4. The OpenCL code is nearly identical except that `__kernel` replaces `__global__` on the subroutine declaration, the `__global` attribute is added to the pointer arguments, and there’s a different way of getting the thread index. Also, the CUDA kernel code is in the same .cu file as the source for the host, while the OpenCL code is in a separate .cl file. We could have separated out the CUDA code into its own .cu file and put the host code in a standard C++ source file. This would be similar to the structure we use for our OpenCL application.

> > > **NOTE** So many of the differences between the kernel codes for CUDA and OpenCL are superficial.

So how different is the OpenCL host-side code from the CUDA version? Let’s take a look at the OpenCl version in listing 12.16 and compare it to the code in listing 12.5. There are two versions of the OpenCL stream triad: StreamTriad_simple.c without error checking and StreamTriad.c with error checking. The error checking adds a lot of lines of code that initially just get in the way of understanding what is going on.

**Listing 12.16 OpenCL version of stream triad: Set up and tear down**

> `OpenCL/StreamTriad/StreamTriad_simple.c`  
> `5 #include "StreamTriad_kernel.inc"`  
> `6 #ifdef __APPLE_CC__                                                      `❶  
> `7 #include <OpenCL/OpenCL.h>                                               `❶  
> `8 #else                                                                    `❶  
> `9 #include <CL/cl.h>                                                       `❶  
> `10 #endif                                                                   `❶  
> `11 #include "ezcl_lite.h"                                                   `❷  
> `     < . . . skipping code . . . >`  
> `32    cl_command_queue command_queue;`  
> `33    cl_context context;`  
> `34    iret = ezcl_devtype_init(                                             `❸  
> `             CL_DEVICE_TYPE_GPU, &command_queue,                            `❸  
> `             &context);                                                     `❸  
> `35    const char *defines = NULL;`  
> `36    cl_program program  =                                                 `❹  
> `         ezcl_create_program_wsource(context,                               `❹  
> `         defines, StreamTriad_kernel_source);                               `❹  
> `37    cl_kernel kernel_StreamTriad =                                        `❺  
> `         clCreateKernel(program, "StreamTriad",                             `❺  
> `         &iret);                                                            `❺  
> `38`  
> `39    // allocate device memory. suffix of _d indicates a device pointer`  
> `40    size_t nsize = stream_array_size*sizeof(double);`  
> `41    cl_mem a_d = clCreateBuffer(context,                                  `❻  
> `         CL_MEM_READ_WRITE, nsize, NULL, &iret);                            `❻  
> `42    cl_mem b_d = clCreateBuffer(context,                                  `❻  
> `         CL_MEM_READ_WRITE, nsize, NULL, &iret);                            `❻  
> `43    cl_mem c_d = clCreateBuffer(context,                                  `❻  
> `         CL_MEM_READ_WRITE, nsize, NULL, &iret);                            `❻  
> `44`  
> `45    // setting work group size and padding`  
> `      //    to get even number of workgroups`  
> `46    size_t local_work_size = 512;                                         `❼  
> `47    size_t global_work_size = ( (stream_array_size + local_work_size - 1) `❼  
> `           /local_work_size ) * local_work_size;                            `❼  
> `     < . . . skipping code . . . >`  
> `74    clReleaseMemObject(a_d);                                              `❻  
> `75    clReleaseMemObject(b_d);                                              `❻  
> `76    clReleaseMemObject(c_d);                                              `❻  
> `77`  
> `78    clReleaseKernel(kernel_StreamTriad);                                  `❽  
> `79    clReleaseCommandQueue(command_queue);                                 `❽  
> `80    clReleaseContext(context);                                            `❽  
> `81    clReleaseProgram(program);                                            `❽

❶ Apple has to be different.

❷ Our EZCL_Lite support library

❸ Gets the GPU device

❹ Creates the program from the source

❺ Compiles the StreamTriad kernel in the source

❻ Handles array memory

❼ Work group size calculation is similar to CUDA.

❽ Cleans up kernel and device-related objects

At the start of the program, we encounter some real differences at lines 34-37, where we have to find our GPU device and compile our device code. This is done for us behind the scenes in CUDA. Two of the lines of OpenCL code call our EZCL_Lite routines to detect the device and to create the program object. We made these calls because the amount of code required for these functions is too long to show here. The source for these routines is hundreds of lines long, though much of it is error checking.

> > > **NOTE** The source is available with the chapter examples in the OpenCL/ StreamTriad directory at [https://github.com/EssentialsofParallelComputing/ Chapter12](https://github.com/EssentialsofParallelComputing/Chapter12). Some of the error checking code has been left out of the short version, StreamTriad_simple.c, but it is in the long version of the code in the file StreamTriad.c.

The rest of the set up and tear down code follows the same pattern that we saw in the CUDA code, with a little more cleanup required, again related to the device and program source handling. Now, how does the section of code that calls the OpenCL kernel in the timing loop in listing 12.16 compare to the CUDA code from listing 12.6?

**Listing 12.17 OpenCL version of stream triad: Kernel call and timing loop**

> `OpenCL/StreamTriad/StreamTriad_simple.c`  
> `49    for (int k=0; k<NTIMES; k++){`  
> `50       cpu_timer_start(&ttotal);`  
> `51       // copying array data from host to device`  
> `52       iret=clEnqueueWriteBuffer(command_queue,    `❶  
> `             a_d, CL_FALSE, 0, nsize, &a[0],         `❶  
> `             0, NULL, NULL);                         `❶  
> `53       iret=clEnqueueWriteBuffer(command_queue,    `❶  
> `             b_d, CL_TRUE, 0, nsize, &b[0],          `❶  
> `             0, NULL, NULL);                         `❶  
> `54`  
> `55       cpu_timer_start(&tkernel);`  
> `56       // set stream triad kernel arguments`  
> `57       iret=clSetKernelArg(kernel_StreamTriad,     `❷  
> `             0, sizeof(cl_int),                      `❷  
> `             (void *)&stream_array_size);            `❷  
> `58       iret=clSetKernelArg(kernel_StreamTriad,     `❷  
> `             1, sizeof(cl_double),                   `❷  
> `             (void *)&scalar);                       `❷  
> `59       iret=clSetKernelArg(kernel_StreamTriad,     `❷  
> `             2, sizeof(cl_mem), (void *)&a_d);       `❷  
> `60       iret=clSetKernelArg(kernel_StreamTriad,     `❷  
> `             3, sizeof(cl_mem), (void *)&b_d);       `❷  
> `61       iret=clSetKernelArg(kernel_StreamTriad,     `❷  
> `             4, sizeof(cl_mem), (void *)&c_d);       `❷  
> `62       // call stream triad kernel`  
> `63       clEnqueueNDRangeKernel(command_queue,       `❸  
> `             kernel_StreamTriad, 1, NULL,            `❸  
> `             &global_work_size, &local_work_size,    `❸  
> `             0, NULL, NULL);                         `❸  
> `64       // need to force completion to get timing`  
> `65       clEnqueueBarrier(command_queue);`  
> `66       tkernel_sum += cpu_timer_stop(tkernel);`  
> `67`  
> `68       iret=clEnqueueReadBuffer(command_queue,     `❹  
> `             c_d, CL_TRUE, 0, nsize, c,              `❹  
> `             0, NULL, NULL);                         `❹  
> `69       ttotal_sum += cpu_timer_stop(ttotal);`  
> `70    }`

❶ Memory movement calls

❷ Sets kernel arguments

❸ Calls the kernel

❹ Synchronization barrier

What is happening on lines 57-61? OpenCL requires a separate call for every kernel argument. If we check the return code from each, it is even more lines. This is a lot more verbose than the single line 53 in listing 12.6 in the CUDA version. But there is a direct correspondence between the two versions. OpenCL is just more verbose in describing the operations to pass the arguments. Except for the device detection and program compilation, the programs are similar in their operations. The biggest difference is the syntax used in the two languages.

In listing 12.18, we show a rough call sequence for the device detection and the create program calls. What makes these routines long is the error checking and the handling required for special cases. For these two functions, it is important to have good error handling. We need the compiler report for an error in our source code or if it got the wrong GPU device.

**Listing 12.18 OpenCL support library ezcl_lite**

> `OpenCL/StreamTriad/ezcl_lite.c`  
> `/* init and finish routine */`  
> `cl_int ezcl_devtype_init(cl_device_type device_type,`  
> `   cl_command_queue *command_queue, cl_context *context);`  
> `clGetPlatformIDs -- first to get number of platforms and allocate`  
> `clGetPlatformIDs -- now get platforms`  
> `Loop on number of platforms and`  
> `   clGetDeviceIDs -- once to get number of devices and allocate`  
> `   clGetDeviceIDs -- get devices`  
> `   check for double precision support -- clGetDeviceInfo`  
> `End loop`  
> `clCreateContext`  
> `clCreateCommandQueue`  
>   
> `/* kernel and program routines */`  
> `cl_program ezcl_create_program_wsource(cl_context context,`  
> `    const char *defines, const char *source);`  
> `       clCreateProgramWithSource`  
> `       set a compile string (hardware specific options)`  
> `       clBuildProgram`  
> `       Check for error, if found`  
> `          clGetProgramBuildInfo`  
> `          and printout compile report`  
> `       End error handling `

We conclude this presentation on OpenCL with a nod to the many language interfaces that have been created for it. There are a C++, Python, Perl, and Java versions. In each of these languages, a higher-level interface has been created that hides some of the details in the C version of OpenCL. And, we highly recommend the use of our EZCL library or one of the many other middleware libraries for OpenCL.

There has been an unofficial C++ version available since OpenCL v1.2. The implementation is just a thin layer on top of the C version of OpenCL. Despite failure to get approval by the standards committee, it is completely usable by developers. It is available at <https://github.com/KhronosGroup/OpenCL-CLHPP>. The formal approval of C++ in OpenCL has only recently occurred, but we are still waiting on implementations.

***12.3.2 Reductions in OpenCL***

The sum reduction in OpenCL is similar to that in CUDA. Rather than step through the code, we’ll just look at the differences in the kernel source. Shown first in figure 12.3 is the side-by-side difference of the `sum_within_block`, the common routine by both kernels.

**Figure 12.3 Comparison of OpenCL and CUDA reduction kernels: sum_within_block**

The difference in this device kernel called by another kernel begins with the attributes on the declaration. CUDA requires a `__device__`attribute on the declaration, while OpenCL does not. For the arguments, passing in the scratchpad array requires a `__local` attribute that CUDA does not need. The next difference is the syntax for getting the local thread index and block (tile) size (figure 12.3 on lines 5 and 6). The synchronization calls are also different. At the top of the routine, a warp size is defined by a macro to help with portability between NVIDIA and AMD GPUs. CUDA defines this as a warp-size variable. For OpenCL, it is passed in with a compiler define. We also change the terminology from block to tile in the actual code to stay consistent with each language’s terminology.

The next routine is the first of two kernel passes, called stage1of 2, in figure 12.4. This kernel is called from the host. The `__global__` attribute for CUDA becomes `__kernel` for OpenCL. We also have to add the `__global` attribute to the pointer arguments for OpenCL.

**Figure 12.4 Comparison for the first of two kernel passes for the OpenCL and CUDA reduction kernels**

The next difference is an important one to take note of. In CUDA, we declare the scratchpad in shared memory as an `extern __shared__` variable in the body of the kernel. On the host side, the size of this shared memory space is given as a number of bytes in the optional third argument in the triple chevron brackets. OpenCL does this differently. It is passed as the last argument in the argument list with the `__local` attribute. On the host side, the memory is specified in the set argument call for the fourth kernel argument:

> `clSetKernelArg(reduce_sum_1of2, 4,`  
> `               local_work_size*sizeof(cl_double), NULL);`

The size is the third argument in the call. The rest of the changes are in the syntax to set the thread parameters and the synchronization call. The last part of the comparison is the second pass of the sum reduction kernel in figure 12.5.

**Figure 12.5 Comparison of the second pass for the reduction sum**

We’ve already seen all of the change patterns in the second kernel. We still have the differences in the declaration of the kernel and the arguments. The local scratch array also has the same differences as the kernel for the first pass. The thread parameters and the synchronization also have the same expected differences.

Looking back at the three comparisons in figures 12.3-5, it is what we didn’t have to note that becomes apparent. The bodies of the kernels are essentially the same. The only difference is the syntax for the synchronization call. The host side code for the sum reduction in OpenCL is shown in the following listing.

**Listing 12.19 Host code for the OpenCL sum reduction**

> `OpenCL/SumReduction/SumReduction.c`  
> `20 cl_context context;`  
> `21 cl_command_queue command_queue;`  
> `22 ezcl_devtype_init(CL_DEVICE_TYPE_GPU, &command_queue, &context);`  
> `23`  
> `24 const char *defines = NULL;`  
> `25 cl_program program = ezcl_create_program_wsource(context, defines,`  
> `      SumReduction_kernel_source);`  
> `26 cl_kernel reduce_sum_1of2=clCreateKernel(          `❶  
> `      program, "reduce_sum_stage1of2_cl", &iret);     `❶  
> `27 cl_kernel reduce_sum_2of2=clCreateKernel(          `❶  
> `      program, "reduce_sum_stage2of2_cl", &iret);     `❶  
> `28`  
> `29 struct timespec tstart_cpu;`  
> `30 cpu_timer_start(&tstart_cpu);`  
> `31`  
> `32 size_t local_work_size = 128;`  
> `33 size_t global_work_size = ((nsize + local_work_size - 1)`  
> `     /local_work_size) * local_work_size;`  
> `34 size_t nblocks     = global_work_size/local_work_size;`  
> `35`  
> `36 cl_mem dev_x = clCreateBuffer(context, CL_MEM_READ_WRITE,`  
> `      nsize*sizeof(double), NULL, &iret);`  
> `37 cl_mem dev_total_sum = clCreateBuffer(context, CL_MEM_READ_WRITE,`  
> `      1*sizeof(double), NULL, &iret);`  
> `38 cl_mem dev_redscratch = clCreateBuffer(context, CL_MEM_READ_WRITE,`  
> `      nblocks*sizeof(double), NULL, &iret);`  
> `39`  
> `40 clEnqueueWriteBuffer(command_queue, dev_x, CL_TRUE, 0,`  
> `      nsize*sizeof(cl_double), &x[0], 0, NULL, NULL);`  
> `41`  
> `42 clSetKernelArg(reduce_sum_1of2, 0,                  `❷  
> `      sizeof(cl_int), (void *)&nsize);                 `❷  
> `43 clSetKernelArg(reduce_sum_1of2, 1,                  `❷  
> `      sizeof(cl_mem), (void *)&dev_x);                 `❷  
> `44 clSetKernelArg(reduce_sum_1of2, 2,                  `❷  
> `      sizeof(cl_mem), (void *)&dev_total_sum);         `❷  
> `45 clSetKernelArg(reduce_sum_1of2, 3,                  `❷  
> `      sizeof(cl_mem), (void *)&dev_redscratch);        `❷  
> `46 clSetKernelArg(reduce_sum_1of2, 4,                  `❷  
> `      local_work_size*sizeof(cl_double), NULL);        `❷  
> `47   `  
> `48 clEnqueueNDRangeKernel(command_queue,               `❷  
> `      reduce_sum_1of2, 1, NULL, &global_work_size,     `❷  
> `      &local_work_size, 0, NULL, NULL);                `❷  
> `49   `  
> `50 if (nblocks > 1) {                                  `❸  
> `51    clSetKernelArg(reduce_sum_2of2, 0,               `❹  
> `         sizeof(cl_int), (void *)&nblocks);            `❹  
> `52    clSetKernelArg(reduce_sum_2of2, 1,               `❹  
> `         sizeof(cl_mem), (void *)&dev_total_sum);      `❹  
> `53    clSetKernelArg(reduce_sum_2of2, 2,               `❹  
> `         sizeof(cl_mem), (void *)&dev_redscratch);     `❹  
> `54    clSetKernelArg(reduce_sum_2of2, 3,               `❹  
> `         local_work_size*sizeof(cl_double), NULL);     `❹  
> `55      `  
> `56    clEnqueueNDRangeKernel(command_queue,            `❹  
> `         reduce_sum_2of2, 1, NULL, &local_work_size,   `❹  
> `         &local_work_size, 0, NULL, NULL);             `❹  
> `57 } `  
> `58   `  
> `59 double total_sum;`  
> `60   `  
> `61 iret=clEnqueueReadBuffer(command_queue, dev_total_sum, CL_TRUE, 0,`  
> `      1*sizeof(cl_double), &total_sum, 0, NULL, NULL);`  
> `62   `  
> `63 printf("Result -- total sum %lf \n",total_sum);`  
> `64   `  
> `65 clReleaseMemObject(dev_x);`  
> `66 clReleaseMemObject(dev_redscratch);`  
> `67 clReleaseMemObject(dev_total_sum);`  
> `68`  
> `69 clReleaseKernel(reduce_sum_1of2);`  
> `70 clReleaseKernel(reduce_sum_2of2);`  
> `71 clReleaseCommandQueue(command_queue);`  
> `72 clReleaseContext(context);`  
> `73 clReleaseProgram(program);`

❶ Two kernels to create from a single source

❷ Calls first reduction pass

❸ If second pass needed ...

❹ ... calls second reduction pass

The call to the first kernel pass creates a local scratchpad array on line 46. The intermediate results are stored back into the `redscratch` array created on line 38. If there is more than one block, a second pass is needed. The `redscratch` array is passed back in to complete the reduction. Note that the kernel parameters in arguments 5 and 6 are set to `local_work_size` or a single work group. This is so a synchronization can be done across all the remaining data and another pass will not be needed.

***12.4 SYCL: An experimental C++ implementation goes mainstream***

SYCL started out in 2014 as an experimental C++ implementation on top of OpenCL. The goal of the developers creating SYCL is a more natural extension of the C++ language than the add-on feeling of OpenCL with the C language. It is being developed as a cross-platform abstraction layer that leverages the portability and efficiency of OpenCL. Its experimental language focus changed suddenly when Intel chose it as one of their major language pathways for the announced Department of Energy Aurora HPC system. The Aurora system will use the new Intel discrete GPUs that are under development. Intel has proposed some additions to the SYCL standard that they have prototyped in their Data Parallel C++ (DPCPP) compiler in their oneAPI open programming system.

You can get introduced to SYCL in several ways. Some of these even avoid having to install the software or having the right hardware. You might first try out the following cloud-based systems:

- Interactive SYCL provides a tutorial on the tech.io website at [https://tech.io/ playgrounds/48226/introduction-to-sycl/introduction-to-sycl-2](https://tech.io/playgrounds/48226/introduction-to-sycl/introduction-to-sycl-2).

- Intel provides a cloud version of oneAPI and DPCPP at [https://software.intel .com/en-us/oneapi](https://software.intel.com/en-us/oneapi). You must register to use.

You can also download and install versions of SYCL from these sites:

- The ComputeCPP community edition at [https://developer.codeplay.com /products/computecpp/ce/home/](https://developer.codeplay.com/products/computecpp/ce/home/). You must register to download.

- The Intel DPCPP compiler at [https://github.com/intel/llvm/blob/sycl/sycl/ doc/GetStartedGuide.md](https://github.com/intel/llvm/blob/sycl/sycl/doc/GetStartedGuide.md)

- Intel also provides Docker file setup instructions at [https://github.com/intel/ oneapi-containers/blob/master/images/docker/basekit-devel-ubuntu18.04/ Dockerfile](https://github.com/intel/oneapi-containers/blob/master/images/docker/basekit-devel-ubuntu18.04/Dockerfile)

We’ll work with Intel’s DPCPP version of SYCL. There are instructions to set up a VirtualBox installation of oneAPI with the examples that accompany this chapter in the README.virtualbox at <https://github.com/EssentialsofParallelComputing/Chapter12>. You should be able to run VirtualBox on nearly any operating system. Let’s start off with a simple makefile for the DPCPP compiler as the following listing shows.

**Listing 12.20 Simple makefile for DPCPP version of SYCL**

> `DPCPP/StreamTriad/Makefile`  
> `1 CXX = dpcpp                         `❶  
> `2 CXXFLAGS = -std=c++17 -fsycl -O3    `❷  
> `3`  
> `4 all: StreamTriad`  
> `5`  
> `6 StreamTriad: StreamTriad.o timer.o`  
> `7   $(CXX) $(CXXFLAGS) $^ -o $@`  
> `8`  
> `9 clean:`  
> `10   -rm -f StreamTriad.o StreamTriad`

❶ Specifies dpcpp as the C++ compiler

❷ Adds the SYCL option to the C++ flags

Setting the C++ compiler to the Intel dpcpp compiler takes care of the paths, libraries, and include files. The only other requirement is to set some flags for the C++ compiler. The following listing shows the SYCL source for our example.

**Listing 12.21 Stream triad example for DPCPP version of SYCL**

> `DPCPP/StreamTriad/StreamTriad.cc`  
> `1 #include <chrono>`  
> `2 #include "CL/sycl.hpp"                          `❶  
> `3`  
> `4 namespace Sycl = cl::sycl;                      `❷  
> `5 using namespace std;`  
> `6`  
> `7 int main(int argc, char * argv[])`  
> `8 {`  
> `9     chrono::high_resolution_clock::time_point t1, t2;`  
> `10`  
> `11     size_t nsize = 10000;`  
> `12     cout << "StreamTriad with " << nsize << " elements" << endl;`  
> `13`  
> `14     // host data`  
> `15     vector<double> a(nsize,1.0);                `❸  
> `16     vector<double> b(nsize,2.0);                `❸  
> `17     vector<double> c(nsize,-1.0);               `❸  
> `18`  
> `19     t1 = chrono::high_resolution_clock::now();`  
> `20`  
> `21     Sycl::queue Queue(Sycl::cpu_selector{});    `❹  
> `22`  
> `23     const double scalar = 3.0;`  
> `24`  
> `25     Sycl::buffer<double,1> dev_a { a.data(),    `❺  
> `          Sycl::range<1>(a.size()) };              `❺  
> `26     Sycl::buffer<double,1> dev_b { b.data(),    `❺  
> `          Sycl::range<1>(b.size()) };              `❺  
> `27     Sycl::buffer<double,1> dev_c { c.data(),    `❺  
> `          Sycl::range<1>(c.size()) };              `❺  
> `28`  
> `29     Queue.submit([&](Sycl::handler&`  
> `             CommandGroup) {                       `❻  
> `30`  
> `31        auto a = dev_a.get_access<Sycl::         `❼  
> `             access::mode::read>(CommandGroup);    `❼  
> `32        auto b = dev_b.get_access<Sycl::         `❼  
> `             access::mode::read>(CommandGroup);    `❼  
> `33        auto c = dev_c.get_access<Sycl::         `❼  
> `             access::mode::write>(CommandGroup);   `❼  
> `34`  
> `35        CommandGroup.parallel_for<class          `❽  
> `              StreamTriad>(Sycl::range<1>{nsize},  `❽  
> `              [=] (Sycl::id<1> it){                `❽  
> `36            c[it] = a[it] + scalar * b[it];`  
> `37        });`  
> `38     });`  
> `39     Queue.wait();                               `❾  
> `40`  
> `41     t2 = chrono::high_resolution_clock::now();`  
> `42`  
> `       double time1 = chrono::duration_cast<`  
> `                      chrono::duration<double> >(t2 - t1).count();`  
> `43     cout << "Runtime is  " << time1*1000.0 << " msecs " << endl;`  
> `44 }`

❶ Includes the SYCL header file

❷ Uses the SYCL namespace

❸ Initializes the host side vectors to constants

❹ Sets up the device for CPU

❺ Allocates the device buffer and sets to the host buffer

❻ Lambda for queue submission

❼ Gets access to device arrays

❽ Lambda for parallel for kernel

❾ Waits for completion

The first `Sycl` function selects a device and creates a queue to work on it. We ask for a CPU, though this code would also work for GPUs with unified memory.

> `Sycl::queue Queue(sycl::cpu_selector{});`

We select a CPU for maximum portability so that the code runs on most systems. To make this code work on GPUs without unified memory, we would need to add explicit copies of data from one memory space to another. The default selector preferentially finds a GPU, but falls back to a CPU. If we want to only select a GPU or CPU, we could also specify other selectors such as

> `Sycl::queue Queue(sycl::default_selector{}); // uses the default device`  
> `Sycl::queue Queue(sycl::gpu_selector{});     // finds a GPU device`  
> `Sycl::queue Queue(sycl::cpu_selector{});     // finds a CPU device`  
> `Sycl::queue Queue(sycl::host_selector{});    // runs on the host (CPU)`

The last option means that it will run on the host as if there were no SYCL or OpenCL code. The setup of the device and queue is far simpler than what we did in OpenCL. Now we need to set up device buffers with the SYCL buffer:

> `Sycl::buffer<double,1> dev_a { a.data(), Sycl::range<1>(a.size()) };`

The first argument to the buffer is a data type, and the second is the dimensionality of the data. Then we give it the variable name, `dev_a`. The first argument to the variable is the host data array to use for initializing the device array, and the second is the index set to use. In this case, we specify a 1D range from 0 to the size of the `a` variable. On line 29, we encounter the first lambda to create a command group handler for the queue:

> `Queue.submit([&](Sycl::handler& CommandGroup)`

We introduced lambdas in section 10.2.1. The lambda capture clause, `[&]`, specifies capturing outside variables used in the routine by reference. For this lambda, the capture gets `nsize`, `scalar`, `dev_a`, `dev_b`, and `dev_c` for use in the lambda. We could specify it with just the single capture setting of by reference, `[&]`, or with the following form, where we specify each variable that will be captured. Good programming practice would prefer the latter, but the lists can get long.

> `Queue.submit([&nsize, &scalar, &dev_a, &dev_b, &dev_c]`  
> `    (Sycl::handler& CommandGroup)`

In the body of the lambda, we get access to the device arrays and rename them for use within the device routine. This is equivalent to a list of arguments for the command group handler. We then create the first task for the command group, a `parallel_for`. The `parallel_for` also is defined with a lambda.

> `CommandGroup.parallel_for<class StreamTriad>(Sycl::range<1>{nsize},[=]`  
> `                                            (Sycl::id<1> it)`

The name of the lambda is `StreamTriad`. We then tell it that we will operate over a 1D range that goes from 0 to nsize. The capture clause, `[=]`, captures the `a`, `b`, and `c` variables by value. Determining whether to capture by reference or value is tricky. But if the code gets pushed to the GPU, the original reference may be out of scope and no longer valid. We last create a 1D index variable, `it`, to iterate over the range.

***12.5 Higher-level languages for performance portability***

By now, you are seeing that the differences between CPU and GPU kernels are not all that big. So why not generate each of them using C++ polymorphism and templates? Well, that is exactly what a couple of libraries developed by Department of Energy research laboratories have done. These projects were started to tackle the porting of many of their codes to new hardware architectures. The Kokkos system was created by Sandia National Laboratories and has gained a wide following. Lawrence Livermore National Laboratory has a similar project by the name of RAJA. Both of these projects have already succeeded in their goal of a single-source, multiplatform capability.

These two languages have similarities in a lot of respects to the SYCL language that you saw in section 12.4. Indeed, they have borrowed concepts from each other as they strive for performance portability. Each of them provides libraries that are fairly light layers on top of lower-level parallel programming languages. We’ll take a short look at each of them.

***12.5.1 Kokkos: A performance portability ecosystem***

Kokkos is a well-designed abstraction layer for languages such as OpenMP and CUDA. It has been in development since 2011. Kokkos has the following named execution spaces. These are enabled in the Kokkos build with the corresponding flag to CMake (or the option to build with Spack). Some of these are better developed than others.

| **Kokkos execution spaces** | **CMake/Spack-enabled flags**               |
|-----------------------------|---------------------------------------------|
| `Kokkos::Serial`            | `-DKokkos_ENABLE_SERIAL=On` (default is on) |
| `Kokkos::Threads`           | `-DKokkos_ENABLE_PTHREAD=On`                |
| `Kokkos::OpenMP`            | `-DKokkos_ENABLE_OPENMP=On`                 |
| `Kokkos::Cuda`              | `-DKokkos_ENABLE_CUDA=On`                   |
| `Kokkos::HPX`               | `-DKokkos_ENABLE_HPX=On`                    |
| `Kokkos::ROCm`              | `-DKokkos_ENABLE_ROCm=On`                   |

> **Exercise: Stream triad in Kokkos**

> For this exercise, we built Kokkos with the OpenMP backend and then built and ran the stream triad example. To start:

> `git clone https://github.com/kokkos/kokkos`  
> `mkdir build && cd build`  
> `cmake ../kokkos -DKokkos_ENABLE_OPENMP=On`

> Then go to the stream triad source directory for Kokkos and do an out-of-tree build with CMake:

> `mkdir build && cd build`  
> `export Kokkos_DIR=${HOME}/Kokkos/lib/cmake/Kokkos`  
> `cmake ..`  
> `make`  
> `export OMP_PROC_BIND=true`  
> `export OMP_PLACES=threads`

> The Kokkos build with CMake has been streamlined so that it is easy as the following listing. The `Kokkos_DIR` variable needs to be set to the location of the CMake configuration file for Kokkos.

**Listing 12.22 Kokkos CMake file**

> `Kokkos/StreamTriad/CMakeLists.txt`  
> `1 cmake_minimum_required (VERSION 3.10)`  
> `2 project (StreamTriad)`  
> `3`  
> `4 find_package(Kokkos REQUIRED)                         `❶  
> `5`  
> `6 add_executable(StreamTriad StreamTriad.cc)`  
> `7 target_link_libraries(StreamTriad Kokkos::kokkos)     `❷

❶ Finds Kokkos and sets the flags

❷ Adds dependencies and flags to build

Adding the CUDA option to the Kokkos build generates a version that runs on NVIDIA GPUs. There are many other platforms and languages that Kokkos can handle and more are being developed all the time.

The Kokkos stream triad example in listing 12.23 has some similarities to SYCL in that it uses C++ lambdas to encapsulate functions for either the CPU or GPU. Kokkos also supports functors for this mechanism, but lambdas are less verbose to use in practice.

**Listing 12.23 Kokkos stream triad example**

> `Kokkos/StreamTriad/StreamTriad.cc`  
> `1 #include <Kokkos_Core.hpp>                      `❶  
> `2`  
> `3 using namespace std;`  
> `4`  
> `5 int main (int argc, char *argv[])`  
> `6 {`  
> `7    Kokkos::initialize(argc, argv);{             `❷  
> `8`  
> `9       Kokkos::Timer timer;`  
> `10       double time1;`  
> `11`  
> `12       double scalar = 3.0;`  
> `13       size_t nsize = 1000000;`  
> `14       Kokkos::View<double *> a( "a", nsize);    `❸  
> `15       Kokkos::View<double *> b( "b", nsize);    `❸  
> `16       Kokkos::View<double *> c( "c", nsize);    `❸  
> `17      `  
> `18       cout << "StreamTriad with " << nsize << " elements" << endl;`  
> `19`  
> `20       Kokkos::parallel_for(nsize,               `❹  
> `               KOKKOS_LAMBDA (int i) {             `❹  
> `21          a[i] = 1.0;                            `❹  
> `22       });                                       `❹  
> `23       Kokkos::parallel_for(nsize,               `❹  
> `               KOKKOS_LAMBDA (int i) {             `❹  
> `24          b[i] = 2.0;                            `❹  
> `25       });                                       `❹  
> `26`  
> `27       timer.reset();`  
> `28`  
> `29       Kokkos::parallel_for(nsize,               `❹  
> `               KOKKOS_LAMBDA (const int i) {       `❹  
> `30          c[i] = a[i] + scalar * b[i];           `❹  
> `31       });                                       `❹  
> `32`  
> `33       time1 = timer.seconds();`  
> `34`  
> `35       icount = 0;`  
> `36       for (int i=0; i<nsize && icount < 10; i++){`  
> `37          if (c[i] != 1.0 + 3.0*2.0) {`  
> `38             cout << "Error with result c[" << i << "]=" << c[i] << endl;`  
> `39             icount++;`  
> `40          }`  
> `41       }`  
> `42`  
> `43       if (icount == 0)`  
> `            cout << "Program completed without error." << endl;`  
> `44       cout << "Runtime is  " << time1*1000.0 << " msecs " << endl;`  
> `45`  
> `46    }`  
> `47    Kokkos::finalize();                         `❺  
> `48    return 0;`  
> `49 }`

❶ Includes the appropriate Kokkos header

❷ Initializes Kokkos

❸ Declares arrays with Kokkos::View

❹ Kokkos parallel_for lambdas for CPU or GPU

❺ Finalizes Kokkos

The Kokkos program starts with `Kokkos::initialize` and `Kokkos::finalize`. These commands start up those things that are needed for the execution space, such as threads. Kokkos is unique in that it encapsulates flexible multi-dimensional array allocations as data views that can be switched depending on the target architecture. In other words, you can use a different data order for CPU versus GPU. We use `Kokkos::View` on lines 14-16, though this is only for 1D arrays. The real value comes with multidimensional arrays. The general syntax for `Kokkos::View` is

> `View < double *** , Layout , MemorySpace > name (...);`

Memory spaces are an option for the template, but have a default appropriate for the execution space. Some memory spaces are

- `HostSpace`

- `CudaSpace`

- `CudaUVMSpace`

The layout can be specified, although it has a default appropriate for the memory space:

- For `LayoutLeft`, the leftmost index is stride 1 (default for `CudaSpace`)

- For `LayoutRight`, the rightmost index is stride 1 (default for `HostSpace`)

The kernels are specified using a lambda syntax on one of three data parallel patterns:

- `parallel_for`

- `parallel_reduce`

- `parallel_scan`

On lines 20, 23, and 29 in listing 12.23, we used the `parallel_for` pattern. The `KOKKOS_LAMBDA` macro replaces the `[=]` or `[&]` capture syntax. Kokkos takes care of specifying this for you and does it in a much more readable form.

***12.5.2 RAJA for a more adaptable performance portability layer***

The RAJA performance portability layer has the goal of achieving portability with a minimum of disruptions to existing Lawrence Livermore National Laboratory codes. In many ways, it is simpler and easier to adopt than other comparable systems. RAJA can be built with support for the following:

- \-`DENABLE_OPENMP=On` (default on)

- \-`DENABLE_TARGET_OPENMP=On` (default Off)

- \-`DENABLE_CUDA=On` (default Off)

- \-`DENABLE_TBB=On` (default Off)

RAJA also has good support for CMake as the following listing shows.

**Listing 12.24 Raja CMake file**

> `Raja/StreamTriad/CMakeLists.txt`  
> `1 cmake_minimum_required (VERSION 3.0)`  
> `2 project (StreamTriad)`  
> `3`  
> `4 find_package(Raja REQUIRED)`  
> `5 find_package(OpenMP REQUIRED)`  
> `6`  
> `7 add_executable(StreamTriad StreamTriad.cc)`  
> `8 target_link_libraries(StreamTriad PUBLIC RAJA)`  
> `9 set_target_properties(StreamTriad PROPERTIES`  
> `                         COMPILE_FLAGS ${OpenMP_CXX_FLAGS})`  
> `10 set_target_properties(StreamTriad PROPERTIES`  
> `                         LINK_FLAGS "${OpenMP_CXX_FLAGS}")`

The RAJA version of the stream triad takes only a few changes as the following listing shows. RAJA also heavily leverages lambdas to provide their portability to CPUs and GPUs.

**Listing 12.25 Raja stream triad example**

> `Raja/StreamTriad/StreamTriad.cc`  
> `1 #include <chrono>`  
> `2 #include "RAJA/RAJA.hpp"                        `❶  
> `3`  
> `4 using namespace std;`  
> `5`  
> `6 int main(int RAJA_UNUSED_ARG(argc), char **RAJA_UNUSED_ARG(argv[]))`  
> `7 {`  
> `8    chrono::high_resolution_clock::time_point t1, t2;`  
> `9    cout << "Running Raja Stream Triad\n";`  
> `10`  
> `11    const int nsize = 1000000;`  
> `12`  
> `13 // Allocate and initialize vector data.`  
> `14    double scalar = 3.0;`  
> `15    double* a = new double[nsize];`  
> `16    double* b = new double[nsize];`  
> `17    double* c = new double[nsize];`  
> `18`  
> `19    for (int i = 0; i < nsize; i++) {`  
> `20      a[i] = 1.0;`  
> `21      b[i] = 2.0;`  
> `22    }`  
> `23`  
> `24    t1 = chrono::high_resolution_clock::now();`  
> `25`  
> `26    RAJA::forall<RAJA::omp_parallel_for_exec>(   `❷  
> `        RAJA::RangeSegment(0,nsize),[=](int i){    `❷  
> `27      c[i] = a[i] + scalar * b[i];               `❷  
> `28    });                                          `❷  
> `29`  
> `30    t2 = chrono::high_resolution_clock::now();`  
> `31`  
> `    < ... error checking ... >`  
> `42    double time1 = chrono::duration_cast<`  
> `                     chrono::duration<double> >(t2 - t1).count();`  
> `43    cout << "Runtime is  " << time1*1000.0 << " msecs " << endl;`  
> `44 }`

❶ Includes Raja headers

❷ Raja forall using C++ lambda

The required changes for RAJA are to include the RAJA header file on line 2 and to change the computation loop to a `Raja::forall`. You can see that the RAJA developers provide a low-entry threshold to gaining performance portability. To run the RAJA test, we included a script that builds and installs RAJA as the following listing shows. The script then goes on to build the stream triad code with RAJA and runs it.

**Listing 12.26 Integrated build and run script for Raja stream triad**

> `Raja/StreamTriad/Setup_Raja.sh`  
> `1 #!/bin/sh`  
> `` 2 export INSTALL_DIR=`pwd`/build/Raja ``  
> `3 export Raja_DIR=${INSTALL_DIR}/share/raja/cmake    `❶  
> `4`  
> `5 mkdir -p build/Raja_tmp && cd build/Raja_tmp`  
> `6 cmake ../../Raja_build -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}`  
> `7 make -j 8 install && cd .. && rm -rf Raja_tmp`  
> `8`  
> `9 cmake .. && make && ./StreamTriad                  `❷

❶ Raja_DIR points to Raja CMake tool.

❷ Builds the stream triad code and runs it

We covered a lot of different programming languages in this chapter. Think of these as dialects of a common language rather than completely different ones.

***12.6 Further explorations***

We have only begun to scratch the surface with all of these native GPU languages and performance portability systems. Even with the initial functionality shown, you can begin to implement some real application codes. If you’re serious about using any of these in your applications, we strongly recommend availing yourself of the many additional resources for the language of your choice.

***12.6.1 Additional reading***

As the dominant GPU language for many years, there are many materials on CUDA programming. Perhaps the first place to go is the NVIDIA Developer’s website at <https://developer.nvidia.com/cuda-zone>. There you’ll find extensive guides on installing and using CUDA.

- The book by Kirk and Hwu has been one of the go-to references on NVIDIA GPU programming:

> > > David B. Kirk and W. Hwu Wen-Mei, Programming massively parallel processors: a hands-on approach (Morgan Kaufmann, 2016).

- AMD (<https://rocm.github.io>) has created a website that covers all aspects of their ROCm ecosystem.

- If you want to really learn more about OpenCL, we highly recommend the book by Matthew Scarpino:

> > > Matthew Scarpino, OpenCL in action: how to accelerate graphics and computations (Manning, 2011).

- A good source of additional information on OpenCL is <https://www.iwocl.org>, sponsored by the International Workshop on OpenCL (IWOCL). They also host an international conference annually. SYCLcon is also hosted through the same site.

- Khronos is the open standards body for OpenCL, SYCL, and related software. They host the language specifications, forums, and resource lists:

> > > Khronos Group, <https://www.khronos.org/opencl/> and [https://www.khronos .org/sycl/.](https://www.khronos.org/sycl/)

- For documentation and training materials on Kokkos, see their GitHub repository. Besides downloading the Kokkos software, you’ll also find a companion repository (<https://github.com/kokkos/kokkos-tutorials>) for the tutorials they give around the country.

- The RAJA team (<https://raja.readthedocs.io>) has extensive documentation at their website.

***12.6.2 Exercises***

1.  Change the host memory allocation in the CUDA stream triad example to use pinned memory (listings 12.1-12.6). Did you get a performance improvement?

2.  For the sum reduction example, try an array size of 18,000 elements all initialized to their index value. Run the CUDA code and then the version in SumReductionRevealed. You may want to adjust the amount of information printed.

3.  Convert the CUDA reduction example to HIP by hipifying it.

4.  For the SYCL example in listing 12.20, initialize the `a` and `b` arrays on the GPU device.

5.  Convert the two initialization loops in the RAJA example in listing 12.24 to the `Raja:forall` syntax. Try running the example with CUDA.

***Summary***

- Use straightforward modifications from the original CPU code for most kernels. This makes the writing of kernels simpler and easier to maintain.

- Careful design of cooperation and comparison in GPU kernels can yield good performance. The key to approaching these operations is breaking down the algorithm into steps and understanding the performance properties of the GPU.

- Think about portability from the start. You will avoid having to create more code versions every time you want to run your application on another hardware platform.

- Consider the single-source performance portability languages. If you need to run on a variety of hardware, these can be worth the initial difficulty in code development.

------------------------------------------------------------------------

^(**1.**) See the CUDA installation guide for details (<https://docs.nvidia.com/cuda/cuda-installation-guide-linux/>).
