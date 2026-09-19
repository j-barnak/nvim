# 11 Directive-based GPU programming

***11 Directive-based GPU programming***

This chapter covers

- Selecting the best directive-based language for your GPU
- Using directives or pragmas to port your code to GPUs or other accelerator devices
- Optimizing the performance of your GPU application

There has been a scramble to establish standards for directive-based languages for programming for GPUs. The pre-eminent directive-based language, OpenMP, released in 1997, was the natural candidate to look to as an easier way to program GPUs. At that time, OpenMP was playing catchup and mainly focused on new CPU capabilities. To address GPU accessibility, in 2011, a small group of compiler vendors, (Cray, PGI and CAPS) along with NVIDIA as the GPU vendor, joined to release the OpenACC standard, providing a simpler pathway to GPU programming. Similar to what you saw in chapter 7 for OpenMP, OpenACC also uses pragmas. In this case, OpenACC pragmas direct the compiler to generate GPU code. A couple of years later, the OpenMP Architecture Review Board (ARB) added their own pragma support for GPUs to the OpenMP standard.

We’ll work through some basic examples in OpenACC and OpenMP to give you an idea of how they work. We suggest that you try out the examples on your target system to see what compilers are available and their current status.

> > > **NOTE** As always, we encourage you to follow along with the examples for this chapter at <https://github.com/EssentialsofParallelComputing/Chapter11>.

Many programmers find themselves “on the fence” in regard to which directive-based language—OpenACC or OpenMP—they should use. Often, the choice is clear once you find out what is available on your system of choice. Keep in mind that the biggest hurdle to overcome is simply to start. If you later decide to switch GPU languages, the preliminary work will still prove valuable as the core concepts transcend the language. We hope that by seeing how little effort is required to generate GPU code using pragmas and directives, you will be encouraged to try it on some of your code. You may even experience a modest speedup with just a little effort.

> **The history of OpenMP and OpenACC**

> The development of OpenMP and OpenACC standards is mostly a friendly competition; some members of the OpenACC committee are also on the OpenMP committee. Implementations are still emerging, led by efforts at Lawrence Livermore National Laboratory, IBM, and GCC. Attempts have been made to merge the two approaches, but they continue to co-exist and will probably do so for the foreseeable future.

> OpenMP is gaining steam and is believed to be the stronger long-term path, but for now, OpenACC has the more mature implementations and broader support by compilers. The following figure shows the full history of the standard’s releases. Note that version 4.0 of the OpenMP standard is the first one to support GPU and accelerators.

>   

> **Release dates of GPU pragma-based languages**

***11.1 Process to apply directives and pragmas for a GPU implementation***

Directive or pragma-based annotations to C, C++, or Fortran applications provide one of the more attractive pathways to access the compute power of GPUs. Much like the OpenMP threading model covered in chapter 7, you can add just a few lines to your application and the compiler generates code that can run on the GPU or the CPU. As first covered in chapters 6 and 7, pragmas are preprocessor statements in C and C++ that give the compiler special instructions. These take the form

> `#pragma acc <directive> [clause]`  
> `#pragma omp <directive> [clause]`

Directives in the form of special comments provide the corresponding capability for Fortran code. The directives start with the comment character, followed by either the `acc` or `omp` keyword to identify these as directives for OpenACC and OpenMP, respectively.

> `!$acc <directive> [clause]`  
> `!$omp <directive> [clause]`

The same general steps are used for implementing OpenACC and OpenMP in applications. Figure 11.1 shows these steps and we’ll detail them in the following sections.

**Figure 11.1 Steps to implement a GPU port with the pragma-based languages. Offloading the work to a GPU causes data transfers that slow down the application until the data movement is reduced.**

We summarize the three steps that we will use to convert a code to run on the GPU with either OpenACC or OpenMP as follows:

1.  Move the computationally intensive work to the GPU. This forces data transfers between the CPU and GPU that will slow down the code, but the work has to be moved first.

2.  Reduce the data movement between the CPU and GPU. Move allocations to the GPU if the data is only used there.

3.  Tune the size of the workgroup, number of workgroups, and other kernel parameters to improve kernel performance.

At this point, you will have an application running much faster on the GPU. Further optimizations are possible to improve performance, although these tend to be more specific for each application.

***11.2 OpenACC: The easiest way to run on your GPU***

We’ll start with getting a simple application running with OpenACC. We do this to show the basic details of getting things working. Then we’ll work on how to optimize the application once it is running. As might be expected with a pragma-based approach, there is a large payoff for a small effort. But first, you have to work through the initial slowdown of the code. Don’t despair! It is normal to encounter an initial slowdown on your journey to faster computations on a GPU.

Often the most difficult step is getting a working OpenACC compiler toolchain. Several solid OpenACC compilers are available. The most notable of the available compilers are listed as follows:[1](#filepos1674934)

- PGI—This is a commercial compiler, but note that PGI has a community edition for a free download.

- GCC—Versions 7 and 8 implement most of the OpenACC 2.0a specification. Version 9 implements most of the OpenACC 2.5 specification. The OpenACC development branch in GCC is working on OpenACC 2.6, featuring further improvements and optimizations.

- Cray—Another commercial compiler; it is only available on Cray systems. Cray has announced that they will no longer support OpenACC in their new LLVM-based C/C++ compiler as of version 9.0. A “classic” version of the compiler that supports OpenACC continues to be available.

For these examples, we’ll use the PGI compiler (version 19.7) and CUDA (version 10.1). The PGI compiler is the most mature option among the more readily available compilers. The GCC compiler is another option but be sure to use the most recent version available. The Cray compiler is a great option if you have access to their system.

> > > **NOTE** What if you don’t have a suitable GPU? You can still try the examples by running the code on your CPU with the OpenACC generated kernels. Performance will be different, but the basic code should be the same.

With the PGI compiler, you can first get information on your system with the `pgaccelinfo` command. It also lets you know if your system and environment are in working order. After running the command, the output should look something like what is shown in figure 11.2.

**Figure 11.2 Output from the** **`pgaccelinfo`** **command shows the type of GPU and its characteristics.**

***11.2.1 Compiling OpenACC code***

Listing 11.1 shows some excerpts from OpenACC makefiles. CMake provides the FindOpenACC.cmake module called in line 18 in the listing. The full CMakeLists.txt file is included in the supplemental source code for the chapter in the OpenACC/StreamTriad directory at <https://github.com/EssentialsofParallelComputing/Chapter11>. We set some flags for compiler feedback and for the compiler to be less conservative about potential aliasing. Both a CMake file and a simple makefile are provided in the subdirectory.

**Listing 11.1 Excerpts from OpenACC makefiles**

> `OpenACC/StreamTriad/CMakeLists.txt`  
> `8 if (NOT CMAKE_OPENACC_VERBOSE)`  
> `9     set(CMAKE_OPENACC_VERBOSE true)`  
> `10 endif (NOT CMAKE_OPENACC_VERBOSE)`  
> `11`  
> `12 if (CMAKE_C_COMPILER_ID MATCHES "PGI")`  
> `13     set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -alias=ansi")`  
> `14 elseif (CMAKE_C_COMPILER_ID MATCHES "GNU")`  
> `15     set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fstrict-aliasing")`  
> `16 endif (CMAKE_C_COMPILER_ID MATCHES "PGI")`  
> `17`  
> `18 find_package(OpenACC)                                          `❶  
> `19`  
> `20 if (CMAKE_C_COMPILER_ID MATCHES "PGI")`  
> `21     set(OpenACC_C_VERBOSE "${OpenACC_C_VERBOSE} -Minfo=accel")`  
> `22 elseif (CMAKE_C_COMPILER_ID MATCHES "GNU")`  
> `23    set(OpenACC_C_VERBOSE`  
> `          "${OpenACC_C_VERBOSE} -fopt-info-optimized-omp")`  
> `24 endif (CMAKE_C_COMPILER_ID MATCHES "PGI")`  
> `25`  
> `26 if (CMAKE_OPENACC_VERBOSE)                                     `❷  
> `27   set(OpenACC_C_FLAGS`  
> `       "${OpenACC_C_FLAGS} ${OpenACC_C_VERBOSE}")                 `❷  
> `28 endif (CMAKE_OPENACC_VERBOSE)                                  `❷  
> `29`  
> `    < ... skipping first target ... >`  
> `33 # Adds build target of stream_triad with source code files`  
> `34 add_executable(StreamTriad_par1 StreamTriad_par1.c timer.c timer.h)`  
> `35 set_source_files_properties(StreamTriad_par1.c PROPERTIES COMPILE_FLAGS`  
> `     "${OpenACC_C_FLAGS}")                                        `❸  
> `36 set_target_properties(StreamTriad_par1 PROPERTIES LINK_FLAGS`  
> `     "${OpenACC_C_FLAGS}")                                        `❸

❶ CMake module sets compiler flags for OpenACC

❷ Adds compiler feedback for accelerator directives

❸ Adds OpenACC flags to compile and link stream triad source

The simple makefiles can also be used for building the example codes by copying or linking these over to a Makefile by using either of these commands:

> `ln -s Makefile.simple.pgi Makefile`  
> `cp Makefile.simple.pgi Makefile`

From the makefiles for the PGI and GCC compilers, we show the suggested flags for OpenACC:

> `Makefile.simple.pgi`  
> `6 CFLAGS:= -g -O3 -c99 -alias=ansi -Mpreprocess -acc -Mcuda -Minfo=accel`  
> `7`  
> `8 %.o: %.c`  
> `9   ${CC} ${CFLAGS} -c $^`  
> `10`  
> `11 StreamTriad: StreamTriad.o timer.o`  
> `12   ${CC} ${CFLAGS} $^ -o StreamTriad`  
>   
> `Makefile.simple.gcc`  
> `6 CFLAGS:= -g -O3 -std=gnu99 -fstrict-aliasing -fopenacc \`  
> `                              -fopt-info-optimized-omp`  
> `7`  
> `8 %.o: %.c`  
> `9   ${CC} ${CFLAGS} -c $^`  
> `10`  
> `11 StreamTriad: StreamTriad.o timer.o`  
> `12   ${CC} ${CFLAGS} $^ -o StreamTriad`

For PGI, the flags to enable OpenACC compilation for GCC are `-acc -Mcuda`. The `Minfo=accel` flag tells the compiler to provide feedback on accelerator directives. We also include the `-alias=ansi` flag to tell the compiler to be less concerned about pointer aliasing so that it can more freely generate parallel kernels. It is still a good idea to include the `restrict` attribute on arguments in your source code to tell the compiler that variables do not point to overlapping regions of memory. We also include a flag in both makefiles to set the C 1999 standard so that we can define loop index variables in a loop for clearer scoping. The `-fopenacc` flag turns on the parsing of the OpenACC directives for GCC. The `-fopt-info-optimized-omp` flag tells the compiler to provide feedback for code generation for the accelerator.

For the Cray compiler, OpenACC is on by default. You can use the compiler option `-hnoacc` if you need to turn it off. And the OpenACC compilers must define the `_OPENACC` macro. The macro is particularly important because OpenACC is still in the process of being implemented by many compilers. You can use it to tell what version of OpenACC your compiler supports and to implement conditional compilations for newer features by comparing against the compiler macro `_OPENACC == yyyymm`, where the version dates are

- Version 1.0: 201111

- Version 2.0: 201306

- Version 2.5: 201510

- Version 2.6: 201711

- Version 2.7: 201811

- Version 3.0: 201911

***11.2.2 Parallel compute regions in OpenACC for accelerating computations***

There are two different options for declaring an accelerated block of code for computations. The first is the `kernels` pragma that gives the compiler freedom to auto-parallelize the code block. This code block can include larger sections of code with several loops. The second is the `parallel loop` pragma that tells the compiler to generate code for the GPU or other accelerator device. We’ll go over examples of each approach.

***USING THE KERNELS PRAGMA TO GET AUTO-PARALLELIZATION FROM THE COMPILER***

The `kernels` pragma allows auto-parallelization of a code block by the compiler. It is often used first to get feedback from the compiler on a section of code. We’ll cover the formal syntax for the `kernels` pragma, including its optional clauses. Then we’ll look at the stream triad example we used in all of our programming chapters and apply the `kernels` pragma. First, we’ll list the specification for the `kernels` pragma from the OpenACC 2.6 standard:

> `#pragma acc kernels [ data clause | kernel optimization | async clause |`  
> `                      conditional ]`

where

> `   data clauses - [ copy | copyin | copyout | create | no_create |`  
> `                    present | deviceptr | attach | default(none|present) ]`  
> `   kernel optimization - [ num_gangs | num_workers | vector_length |`  
> `                           device_type | self ]`  
> `   async clauses - [ async | wait ]`  
> `   conditional - [ if ]`

We’ll discuss the data clauses in more detail in section 11.2.3, although you can also use the data clauses in the `kernel` pragma if these only apply to a single loop. We’ll cover the kernel optimizations in section 11.2.4. And we’ll briefly mention the async and conditional clauses in section 11.2.5.

We first start by specifying where we want the work to be parallelized by adding `#pragma acc kernels` around the targeted blocks of code. The `kernels` pragma applies to the code block following the directive or for the code in the next listing, the `for` loop.

**Listing 11.2 Adding the** **`kernels`** **pragma**

> `OpenACC/StreamTriad/StreamTriad_kern1.c`  
> `1 #include <stdio.h>`  
> `2 #include <stdlib.h>`  
> `3 #include "timer.h"`  
> `4`  
> `5 int main(int argc, char *argv[]){`  
> `6`  
> `7    int nsize = 20000000, ntimes=16;`  
> `8    double* a = malloc(nsize * sizeof(double));`  
> `9    double* b = malloc(nsize * sizeof(double));`  
> `10    double* c = malloc(nsize * sizeof(double));`  
> `11`  
> `12    struct timespec tstart;`  
> `13    // initializing data and arrays`  
> `14    double scalar = 3.0, time_sum = 0.0;`  
> `15 #pragma acc kernels                   `❶  
> `16    for (int i=0; i<nsize; i++) {      `❷  
> `17       a[i] = 1.0;                     `❷  
> `18       b[i] = 2.0;                     `❷  
> `19    }                                  `❷  
> `20      `  
> `21    for (int k=0; k<ntimes; k++){`  
> `22       cpu_timer_start(&tstart);`  
> `23       // stream triad loop`  
> `24 #pragma acc kernels                   `❶  
> `25       for (int i=0; i<nsize; i++){    `❷  
> `26          c[i] = a[i] + scalar*b[i];   `❷  
> `27       }                               `❷  
> `28       time_sum += cpu_timer_stop(tstart);`  
> `29    }  `  
> `30`  
> `31    printf("Average runtime for stream triad loop is %lf msecs\n",`  
> `             time_sum/ntimes);`  
> `32`  
> `33    free(a);`  
> `34    free(b);`  
> `35    free(c);`  
> `36`  
> `37    return(0);`  
> `38 }`

❶ Inserts OpenACC kernels pragma

❷ Code block for kernels pragma

The following output shows the feedback from the PGI compiler:

> `main:`  
> `     15, Generating implicit copyout(b[:20000000],a[:20000000])`  
> `         [if not already present]`  
> `     16, Loop is parallelizable`  
> `         Generating Tesla code`  
> `         16, #pragma acc loop gang, vector(128)`  
> `             /* blockIdx.x threadIdx.x */`  
> `     16, Complex loop carried dependence of a-> prevents parallelization`  
> `         Loop carried dependence of b-> prevents parallelization`  
> `     24, Generating implicit copyout(c[:20000000]) [if not already present]`  
> `         Generating implicit copyin(b[:20000000],a[:20000000])`  
> `         [if not already present]`  
> `     `**`25, Complex loop carried dependence of a->,b-> prevents`**  
> **`         parallelization`**  
> **`         Loop carried dependence of c-> prevents parallelization`**  
> **`         Loop carried backward dependence of c-> prevents vectorization`**  
> `         Accelerator serial kernel generated`  
> `         Generating Tesla code`  
> `         25, #pragma acc loop seq`  
> `     25, Complex loop carried dependence of b-> prevents parallelization`  
> `         Loop carried backward dependence of c-> prevents vectorization`

What isn’t clear in this listing is that OpenACC treats each `for` loop as if it has a `#pragma acc loop auto` in front of it. We have left the decision to the compiler to decide whether it could parallelize the loop. The output in bold indicates that the compiler doesn’t think it can. The compiler is telling us it needs help. The simplest fix is to add a `restrict` attribute to lines 8-10 in listing 11.2.

> ` 8    double* restrict a = malloc(nsize * sizeof(double));`  
> `9    double* restrict b = malloc(nsize * sizeof(double));`  
> `10    double* restrict c = malloc(nsize * sizeof(double));`

Our second choice for a fix to help the compiler is to change the directive to tell the compiler it is Ok to generate parallel GPU code. The problem is the default `loop` directive (`loop auto`), which we mentioned earlier. Here is the specification from the OpenACC 2.6 standard:

> `#pragma acc loop [ auto | independent | seq | collapse | gang | worker |`  
> `                   vector | tile | device_type | private | reduction ]`

We cover many of these clauses in later sections. For now, we’ll focus on the first three: `auto`, `independent`, and `seq`.

- `auto` lets the compiler do the analysis.

- `seq`, short for sequential, says to generate a sequential version.

- `independent` asserts that the loop can and should be parallelized.

Changing the clause from `auto` to `independent` tells the compiler to parallelize the loop:

> `15 #pragma acc kernels loop independent`  
> `   <Skipping unchanged code>`  
> `24 #pragma acc kernels loop independent`

Note that we have combined the two constructs in these directives. You can combine valid individual clauses into a single directive, if you like. Now the output shows that the loop is parallelized:

> `main:`  
> `     `**`15, Generating implicit copyout(a[:20000000],b[:20000000])`**  
> **`         [if not already present]`**  
> `     16, Loop is parallelizable`  
> `         Generating Tesla code`  
> `         16, #pragma acc loop gang, vector(128)`  
> `             /* blockIdx.x threadIdx.x */`  
> **`     24, Generating implicit copyout(c[:20000000]) [if not already present]`**  
> **`         Generating implicit copyin(b[:20000000],a[:20000000])`**  
> **`         [if not already present]`**  
> `     25, Loop is parallelizable`  
> `         Generating Tesla code`  
> `         25, #pragma acc loop gang, vector(128)`  
> `             /* blockIdx.x threadIdx.x */`

The important thing to note in this output is the feedback about data transfers (in bold). We’ll discuss how to address this feedback in section 11.2.3.

***TRY THE PARALLEL LOOP PRAGMA FOR MORE CONTROL OVER PARALLELIZATION***

Next we’ll cover how to use the `parallel loop` pragma. This is the technique we recommend that you use in your application. It is more consistent with the form used in other parallel languages such as OpenMP. It also generates more consistent and portable performance across compilers. Not all compilers can be counted on to perform an adequate job of analysis required by the `kernels` directive.

The `parallel loop` pragma is actually two separate directives. The first is the `parallel` directive that opens a parallel region. The second is the `loop` pragma that distributes the work across the parallel work elements. We’ll look at the `parallel` pragma first. The `parallel` pragma takes the same clauses as the `kernel` directive. In the following example, we bolded the additional clauses for the `kernel` directive:

> `#pragma acc parallel [ clause ]`  
> `   data clauses - [ `**`reduction`**` | `**`private`**` | `**`firstprivate`**` | copy |`  
> `                     copyin | copyout | create | no_create | present |`  
> `                     deviceptr | attach | default(none|present) ]`  
> `   kernel optimization - [ num_gangs | num_workers |`  
> `                            vector_length | device_type | self ]`  
> `   async clauses - [ async | wait ]`  
> `   conditional - [ if ]`

The clauses for the `loop` construct were mentioned earlier in the kernels section. The important thing to note is that the default for the `loop` construct in a parallel region is `independent` rather than `auto`. Again, as in the `kernels` directive, the combined `parallel loop` construct can take any clause that the individual directives can. With this explanation of the `parallel loop` construct, we move on to how it is added to the stream triad example as shown in the following listing.

**Listing 11.3 Adding a** **`parallel loop`** **pragma**

> `OpenACC/StreamTriad/StreamTriad_par1.c`  
> `12    struct timespec tstart;`  
> `13    // initializing data and arrays`  
> `14    double scalar = 3.0, time_sum = 0.0;`  
> `15 #pragma acc parallel loop                 `❶  
> `16    for (int i=0; i<nsize; i++) {`  
> `17       a[i] = 1.0;`  
> `18       b[i] = 2.0;`  
> `19    }`  
> `20`  
> `21    for (int k=0; k<ntimes; k++){`  
> `22       cpu_timer_start(&tstart);`  
> `23       // stream triad loop`  
> `24 #pragma acc parallel loop                 `❶  
> `25       for (int i=0; i<nsize; i++){`  
> `26          c[i] = a[i] + scalar*b[i];`  
> `27       }`  
> `28       time_sum += cpu_timer_stop(tstart);`  
> `29    }`

❶ Inserts the parallel loop combined construct

The output from the PGI compiler is

> `main:`  
> `     15, Generating Tesla code`  
> `         16, #pragma acc loop gang, vector(128)`  
> `             /* blockIdx.x threadIdx.x */`  
> **`     15, Generating implicit copyout(a[:20000000],b[:20000000])`**  
> **`         [if not already present]`**  
> `     24, Generating Tesla code`  
> `         25, #pragma acc loop gang, vector(128)`  
> `             /* blockIdx.x threadIdx.x */`  
> **`     24, Generating implicit copyout(c[:20000000]) [if not already present]`**  
> **`         Generating implicit copyin(b[:20000000],a[:20000000])`**  
> **`         [if not already present]`**

Even without the `restrict` attribute, the loop is parallelized because the default for the `loop` directive is the `independent` clause. This is different than the default for the `kernels` directive that we saw previously. Still, we recommend that you use the `restrict` attribute in your code to help the compiler generate the best code.

The output is similar to that from the previous `kernels` directive. At this point, the performance of the code will likely have slowed down due to the data movement we have shown in bold in this compiler output. Not to worry; we will speed it back up in the next step.

Before we move on to addressing the data movement, we’ll take a quick look at reductions and the `serial` construct. Listing 11.4 shows the mass sum example first introduced in section 6.3.3. The mass sum is a simple reduction operation. Instead of the OpenMP SIMD vectorization pragma, we placed an OpenACC `parallel loop` pragma with the `reduction` clause before the loop. The syntax of the reduction is familiar because it is the same as was used by the threaded OpenMP standard.

**Listing 11.4 Adding a** **`reduction`** **clause**

> `OpenACC/mass_sum/mass_sum.c`  
> `1 #include "mass_sum.h"`  
> `2 #define REAL_CELL 1`  
> `3`  
> `4 double mass_sum(int ncells, int* restrict celltype,`  
> `5                 double* restrict H, double* restrict dx,`  
> `                   double* restrict dy){`  
> `6    double summer = 0.0;`  
> `7 #pragma acc parallel loop reduction(+:summer)    `❶  
> `8    for (int ic=0; ic<ncells ; ic++) {`  
> `9       if (celltype[ic] == REAL_CELL) {`  
> `10          summer += H[ic]*dx[ic]*dy[ic];`  
> `11       }`  
> `12    }`  
> `13    return(summer);`  
> `14 }`

❶ Adds a reduction clause to a parallel loop construct

There are other operators that you can use in a `reduction` clause. These include `*`, `max`, `min`, `&`, `|`, `&&`, and `||`. For OpenACC versions up to 2.6, the variable or list of variables separated by commas are limited to scalars and not arrays. But OpenACC version 2.7 lets you use arrays and composite variables in the reduction clause.

The last construct we’ll cover in this section is the one for serial work. Some loops cannot be done in parallel. Rather than exit the parallel region, we stay within it and tell the compiler to just do this one part in serial. This is done with the `serial` directive:

> `#pragma acc serial`

Blocks of this code with the `serial` directive are executed by one gang of one worker with a vector length of one. Now, let’s turn our attention to addressing the data movement feedback.

***11.2.3 Using directives to reduce data movement between the CPU and the GPU***

This section returns to a theme we have seen throughout this book. Data movement is more important than flops. Although we have sped up the computations by moving these to the GPU, the overall run time has slowed because of the cost of data movement. Addressing the excessive data movement will start yielding an overall speedup. To do this, we add the `data` construct to our code. In the OpenACC standard, v2.6, the specification for the `data` construct is as follows:

> `#pragma acc data [ copy | copyin | copyout | create | no_create | present |`  
> `                   deviceptr | attach | default(none|present) ]`

You will also see references to clauses like `present_or_copy` or the shorthand `pcopy` that check for the presence of the data before making the copy. These are no longer necessary, though they are retained for backward compatibility. The standard clauses have incorporated this behavior beginning with version 2.5 of the OpenACC standard.

Many of the `data` clauses take an argument that lists the data to be copied or otherwise manipulated. The range specification for the array needs to be given to the compiler. An example of this is

> `#pragma acc data copy(x[0:nsize])`

The range specification is subtly different for C/C++ and Fortran. In C/C++, the first argument in the specification is the start index, and the second is the length. In Fortran, the first argument is the start index, and the second argument is the end index.

There are two varieties of data regions. The first is the structured data region from the original OpenACC version 1.0 standard. The second, a dynamic data region, was introduced in version 2.0 of OpenACC. We’ll look at the structured data region first.

***STRUCTURED DATA REGION FOR SIMPLE BLOCKS OF CODE***

The structured data region is delimited by a code block. This can be a natural code block formed by a loop or a region of code contained within a set of curly braces. In Fortran, the region is marked with a starting directive and ends with an ending directive. Listing 11.5 shows an example of a structured data region that starts with the directive on line 16 and is delimited by the opening brace on line 17 and the ending brace on line 37. We have included a comment on the ending brace in the code to help identify the block of code that the brace ends.

**Listing 11.5 Structured data block pragma**

> `OpenACC/StreamTriad/StreamTriad_par2.c`  
> `16 #pragma acc data create(a[0:nsize],\                                 `❶  
> `                           b[0:nsize],c[0:nsize])                       `❶  
> `17    {                                                                 `❷  
> `18`  
> `19 #pragma acc parallel loop present(a[0:nsize],\                       `❸  
> `                                     b[0:nsize])                        `❸  
> `20       for (int i=0; i<nsize; i++) {`  
> `21          a[i] = 1.0;`  
> `22          b[i] = 2.0;`  
> `23       }`  
> `24`  
> `25       for (int k=0; k<ntimes; k++){`  
> `26          cpu_timer_start(&tstart);`  
> `27          // stream triad loop`  
> `28 #pragma acc parallel loop present(a[0:nsize],\                       `❸  
> `                          b[0:nsize],c[0:nsize])                        `❸  
> `29          for (int i=0; i<nsize; i++){`  
> `30             c[i] = a[i] + scalar*b[i];`  
> `31          }`  
> `32          time_sum += cpu_timer_stop(tstart);`  
> `33       }`  
> `34`  
> `35       printf("Average runtime for stream triad loop is %lf msecs\n",`  
> `                time_sum/ntimes);`  
> `36`  
> `37    } //#pragma end acc data block(a[0:nsize],b[0:nsize],c[0:nsize])  `❹

❶ The data directive defines the structured data region.

❷ Starts the data region

❸ The present directive tells the compiler that a copy is not needed.

❹ Closing brace marks the end of the data region

The structured data region specifies that the three arrays are to be created at the start of the data region. These will be destroyed at the end of the data region. The two parallel loops use the `present` clause to avoid data copies for the compute regions.

***DYNAMIC DATA REGION FOR A MORE FLEXIBLE DATA SCOPING***

The structured data region, originally used by OpenACC, where memory is allocated and then there are some loops, does not work with more complicated programs. In particular, memory allocations in object-oriented code occur when an object is created. How do you put a data region around something with this kind of program structure?

To address this problem, OpenACC v2.0 added dynamic (also called unstructured) data regions. This dynamic data region construct was specifically created for more complex data management scenarios, such as constructors and destructors in C++. Rather than using scoping braces to define the data region, the pragma has an `enter` and an `exit` clause:

> `#pragma acc enter data`  
> `#pragma acc exit data`

For the `exit data` directive, there is an additional `delete` clause that we can use. This use of the `enter/exit data` directive is best done where allocations and deallocations occur. The `enter data` directive should be placed just after an allocation, and the `exit data` directive should be inserted just before the deallocation. This more naturally follows the existing data scope of variables in an application. Once you want higher performance than what can be achieved from the loop-level strategy, these dynamic data regions become important. With the larger scope of the dynamic data regions, there is a need for an additional directive to update data:

> `#pragma acc update [self(x) | device(x)]`

The `device` argument specifies that the data on the device is to be updated. The `self` argument says to update the local data, which is usually the host version of the data.

Let’s look at an example using a dynamic `data` pragma in listing 11.6. The `enter data` directive is placed after the allocation at line 12. The `exit data` directive at line 35 is inserted before the deallocations. We suggest using dynamic data regions in preference to structured data regions in almost all but the simplest code.

**Listing 11.6 Creating dynamic data regions**

> `OpenACC/StreamTriad/StreamTriad_par3.c`  
> `8    double* restrict a = malloc(nsize * sizeof(double));`  
> `9    double* restrict b = malloc(nsize * sizeof(double));`  
> `10    double* restrict c = malloc(nsize * sizeof(double));`  
> `11`  
> `12 #pragma acc enter data create(a[0:nsize],\    `❶  
> `                      b[0:nsize],c[0:nsize])     `❶  
> `13`  
> `14    struct timespec tstart;`  
> `15    // initializing data and arrays`  
> `16    double scalar = 3.0, time_sum = 0.0;`  
> `17 #pragma acc parallel loop present(a[0:nsize],b[0:nsize])`  
> `18    for (int i=0; i<nsize; i++) {`  
> `19       a[i] = 1.0;`  
> `20       b[i] = 2.0;`  
> `21    }`  
> `22`  
> `23    for (int k=0; k<ntimes; k++){`  
> `24       cpu_timer_start(&tstart);`  
> `25       // stream triad loop`  
> `26 #pragma acc parallel loop present(a[0:nsize],b[0:nsize],c[0:nsize])`  
> `27       for (int i=0; i<nsize; i++){`  
> `28          c[i] = a[i] + scalar*b[i];`  
> `29       }`  
> `30       time_sum += cpu_timer_stop(tstart);`  
> `31    }`  
> `32`  
> `33    printf("Average runtime for stream triad loop is %lf msecs\n",`  
> `             time_sum/ntimes);`  
> `34`  
> `35 #pragma acc exit data delete(a[0:nsize],\.   `❷  
> `                     b[0:nsize],c[0:nsize])     `❷  
> `36`  
> `37    free(a);`  
> `38    free(b);`  
> `39    free(c);`

❶ Starts the dynamic data region after memory allocation

❷ Ends the dynamic data region before memory deallocation

If you paid close attention to the previous listing, you will have noticed that the arrays `a`, `b`, and `c` are allocated on both the host and the device, but are only used on the device. In listing 11.7, we show one way to fix this by using the `acc_malloc` routine and then putting the `deviceptr` clause on the compute regions.

**Listing 11.7 Allocating data only on the device**

> `OpenACC/StreamTriad/StreamTriad_par4.c`  
> `1 #include <stdio.h>`  
> `2 #include <openacc.h>`  
> `3 #include "timer.h"`  
> `4`  
> `5 int main(int argc, char *argv[]){`  
> `6`  
> `7    int nsize = 20000000, ntimes=16`  
> `8    double* restrict a_d =                        `❶  
> `         acc_malloc(nsize * sizeof(double));        `❶  
> `9    double* restrict b_d =                        `❶  
> `         acc_malloc(nsize * sizeof(double));        `❶  
> `10    double* restrict c_d =                        `❶  
> `         acc_malloc(nsize * sizeof(double));        `❶  
> `11`  
> `12    struct timespec tstart;`  
> `13    // initializing data and arrays`  
> `14    const double scalar = 3.0;`  
> `15    double time_sum = 0.0;`  
> `16 #pragma acc parallel loop deviceptr(a_d, b_d)    `❷  
> `17    for (int i=0; i<nsize; i++) {`  
> `18       a_d[i] = 1.0;`  
> `19       b_d[i] = 2.0;`  
> `20    }`  
> `21`  
> `22    for (int k=0; k<ntimes; k++){`  
> `23       cpu_timer_start(&tstart);`  
> `24       // stream triad loop`  
> `25 #pragma acc parallel loop deviceptr(a_d, b_d,    `❷  
> `                                       c_d)         `❷  
> `26       for (int i=0; i<nsize; i++){`  
> `27          c_d[i] = a_d[i] + scalar*b_d[i];`  
> `28       }`  
> `29       time_sum += cpu_timer_stop(tstart);`  
> `30    }`  
> `31`  
> `32    printf("Average runtime for stream triad loop is %lf msecs\n",`  
> `             time_sum/ntimes);`  
> `33`  
> `34    acc_free(a_d);                                `❸  
> `35    acc_free(b_d);                                `❸  
> `36    acc_free(c_d);                                `❸  
> `37`  
> `38    return(0);`  
> `39 }`

❶ Allocates memory on the device. \_d indicates a device pointer.

❷ The deviceptr clause tells the compiler that memory is already on the device.

❸ Deallocates memory on the device

The output from the PGI compiler is now much shorter as shown here:

> `16 Generating Tesla code`  
> `17 #pragma acc loop gang, vector(128) /* blockIdx.x threadIdx.x */`  
> `25 Generating Tesla code`  
> `26 #pragma acc loop gang, vector(128) /* blockIdx.x threadIdx.x */`

The data movement is eliminated and memory requirements on the host reduced. We still have some output giving feedback on the generated kernel that we will look at in section 11.2.4. This example (listing 11.7) works for 1D arrays. For 2D arrays, the `deviceptr` clause does not take a descriptor argument, so the kernel has to be changed to do its own 2D indexing in a 1D array.

When referencing data regions, you have available a rich set of data directives and data movement clauses that you can use to reduce unnecessary data movement. Still, there are more clauses and OpenACC functions that we have not covered that can be useful in specialized situations.

***11.2.4 Optimizing the GPU kernels***

Generally, you will have greater impact getting more kernels running on the GPU and reducing the data movement than optimizing the GPU kernels themselves. The OpenACC compiler does a good job at producing the kernels, and the potential gains from further optimizations will be small. Occasionally, you can help the compiler to improve the performance of key kernels enough for that to be worth some effort.

In this section, we’ll go over the general strategies for these optimizations. First we’ll go over the terminology used in the OpenACC standard. As figure 11.3 shows, OpenACC defines abstract levels of parallelism that apply over multiple hardware devices.

**Figure 11.3 The hierarchy of the levels in OpenACC: gangs, workers, and vectors**

OpenACC defines these levels of parallelism:

- Gang—An independent work block that shares resources. A gang can also synchronize within the group but not across the groups. For GPUs, gangs can be mapped to CUDA thread blocks or OpenCL work groups.

- Workers—A warp in CUDA or work items within a work group in OpenCL.

- Vector—A SIMD vector on the CPU and a SIMT work group or warp on the GPU with contiguous memory references.

Some examples of setting the level of a particular loop directive follow:

> `#pragma acc parallel loop vector`  
> `#pragma acc parallel loop gang`  
> `#pragma acc parallel loop gang vector`

The outer loop must be a `gang` loop, and the inner loop should be a `vector` loop. A `worker` loop can appear in between. A sequential (`seq`) loop can appear at any level.

For most current GPUs, the vector length should be set to multiples of 32, so it is an integer multiple of the warp size. It should be no larger than the maximum threads per block, which is commonly around 1,024 on current GPUs (see the output from the `pgaccelinfo` command in figure 11.2). For the examples here, the PGI compiler sets the vector length to a reasonable value of 128. The value can be changed for a loop with the `vector_length(x)` directive.

In what scenario should you change the `vector_length` setting? If the inner loop of contiguous data is less than 128, part of the vector will go unused. In this case, reducing this value can be helpful. Another option would be to collapse a couple of the inner loops to get a longer vector as we will discuss shortly.

You can modify the `worker` setting with the `num_workers` clause. For the examples in this chapter, however, it is not used. Even so, it can be useful to increase it when shortening the vector length or for an additional level of parallelization. If your code needs to synchronize within the parallel work group, you should use the worker level, but OpenACC does not provide a user with a synchronization directive. The worker level also shares resources such as cache and local memory.

The rest of the parallelization is done with gangs, which are the asynchronous parallel level. Lots of gangs are important on GPUs to hide latency and for high occupancy. Generally, the compiler sets this to a large number, so there is no need for the user to override it. There is a `num_gangs` clause available in the remote chance you may need to do this.

Many of these settings will only be appropriate for a particular piece of hardware. The `device_type(type)` before a clause restricts it to the specified device type. The `device type` setting stays active until the next `device type` clause is encountered. For example

> `1 #pragma acc parallel loop gang \`  
> `2     device_type(acc_device_nvidia) vector_length(256) \`  
> `3     device_type(acc_device_radeon) vector_length(64)`  
> `4 for (int j=0; j<jmax; j++){`  
> `5       #pragma acc loop vector`  
> `6       for (int i=0; i<imax; i++){`  
> `7           <work>`  
> `8       }`  
> `9 }`

For a list of valid device types, look at the openacc.h header file for PGI v19.7. Note that there is no `acc_device_radeon` in the lines from the openacc.h header file previously shown, so the PGI compiler does not support the AMD Radeon™ device. This means we need a C preprocessor `ifdef` around line 3 in the previous sample code to keep the PGI compiler from complaining.

> `Excerpt from openacc.h file for PGI`  
> `27 typedef enum{`  
> `28     acc_device_none          = 0,`  
> `29     acc_device_default       = 1,`  
> `30     acc_device_host          = 2,`  
> `31     acc_device_not_host      = 3,`  
> `32     acc_device_nvidia        = 4,`  
> `33     acc_device_pgi_opencl    = 7,`  
> `34     acc_device_nvidia_opencl = 8,`  
> `35     acc_device_opencl        = 9,`  
> `36     acc_device_current       = 10`  
> `37     } acc_device_t;`

The syntax for the `kernels` directive is slightly different, with the parallel type applied to each `loop` directive individually and taking the `int` argument directly:

> `#pragma acc kernels loop gang`  
> `for (int j=0; j<jmax; j++){`  
> `      #pragma acc loop vector(64)`  
> `      for (int i=0; i<imax; i++){`  
> `          <work>`  
> `      }`  
> `}`

Loops can be combined with the `collapse(n)` clause. This is especially useful if there are two small inner loops contiguously striding through data. Combining these allows you to use a longer vector length. The loops must be tightly nested.

> > > **DEFINITION** Two or more loops that have no extra statements between the `for` or `do` statements or between the end of the loops are tightly-nested loops.

An example of combining two loops in order to use a long vector is

> `#pragma acc parallel loop collapse(2) vector(32)`  
> `for (int j=0; j<8; j++){`  
> `      for (int i=0; i<4; i++){`  
> `          <work>`  
> `      }`  
> `}`

OpenACC v2.0 added a `tile` clause that you can use for optimization. You can either specify the tile size or use asterisks to let the compiler choose:

> `#pragma acc parallel loop tile(*,*)`  
> `for (int j=0; j<jmax; j++){`  
> `      for (int i=0; i<imax; i++){`  
> `          <work>`  
> `      }`  
> `}`

Now it is time to try out the various kernel optimizations. The stream triad example did not show any real benefits from our optimization attempts, so we will work with the stencil example used in many of the previous chapters.

The associated code for the stencil example for this chapter goes through the same first two steps of moving the computational loops to the GPU and then reducing the data movement. The stencil code also requires one additional change. On the CPU, we swap pointers at the end of the loop. On the GPU, in lines 45-50, we have to copy the new data back to the original array. The following listing takes up the stencil code example with these steps completed.

**Listing 11.8 Stencil example with compute loops on the GPU and data motion optimized**

> `OpenACC/Stencil/Stencil_par3.c`  
> `17 #pragma acc enter data create( \                   `❶  
> `         x[0:jmax][0:imax], xnew[0:jmax][0:imax])     `❶  
> `18`  
> `19 #pragma acc parallel loop present( \               `❷  
> `         x[0:jmax][0:imax], xnew[0:jmax][0:imax])     `❷  
> `20    for (int j = 0; j < jmax; j++){`  
> `21       for (int i = 0; i < imax; i++){`  
> `22          xnew[j][i] = 0.0;`  
> `23          x[j][i]    = 5.0;`  
> `24       }`  
> `25    }`  
> `26`  
> `27 #pragma acc parallel loop present( \               `❷  
> `         x[0:jmax][0:imax], xnew[0:jmax][0:imax])     `❷  
> `28    for (int j = jmax/2 - 5; j < jmax/2 + 5; j++){`  
> `29       for (int i = imax/2 - 5; i < imax/2 -1; i++){`  
> `30          x[j][i] = 400.0;`  
> `31       }`  
> `32    }`  
> `33`  
> `34    for (int iter = 0; iter < niter; iter+=nburst){`  
> `35`  
> `36       for (int ib = 0; ib < nburst; ib++){`  
> `37          cpu_timer_start(&tstart_cpu);`  
> `38 #pragma acc parallel loop present( \               `❷  
> `         x[0:jmax][0:imax], xnew[0:jmax][0:imax])     `❷  
> `39          for (int j = 1; j < jmax-1; j++){`  
> `40             for (int i = 1; i < imax-1; i++){`  
> `41                xnew[j][i]=(x[j][i]+x[j][i-1]+x[j][i+1]+`  
> `                                      x[j-1][i]+x[j+1][i])/5.0;`  
> `42             }`  
> `43          }`  
> `44`  
> `45 #pragma acc parallel loop present( \               `❷  
> `         x[0:jmax][0:imax], xnew[0:jmax][0:imax])     `❷  
> `46          for (int j = 0; j < jmax; j++){`  
> `47             for (int i = 0; i < imax; i++){`  
> `48                x[j][i] = xnew[j][i];`  
> `49             }`  
> `50          }`  
> `51          cpu_time += cpu_timer_stop(tstart_cpu);`  
> `52       }`  
> `53`  
> `54       printf("Iter %d\n",iter+nburst);`  
> `55    }`  
> `56 `  
> `57 #pragma acc exit data delete( \                    `❶  
> `         x[0:jmax][0:imax], xnew[0:jmax][0:imax])     `❶

❶ Dynamic data region directives

❷ Compute region directives

First, note that we are using the dynamic data region directives, so there are no braces wrapping the data region as we would see with the structured data region. The dynamic region begins the data region when it encounters the `enter` directive and ends when it reaches an `exit` directive, no matter what path occurs between the two directives. In this case, it is a straight line of execution from the `enter` to the `exit` directive. We’ll add the `collapse` clause to the parallel loop to reduce the overhead for the two loops. The following listing shows this change.

**Listing 11.9 Stencil example with a** **`collapse`** **clause**

> `OpenACC/Stencil/Stencil_par4.c`  
> `36       for (int ib = 0; ib < nburst; ib++){`  
> `37          cpu_timer_start(&tstart_cpu);`  
> `38 #pragma acc parallel loop collapse(2)\                    `❶  
> `39      present(x[0:jmax][0:imax], xnew[0:jmax][0:imax])`  
> `40          for (int j = 1; j < jmax-1; j++){`  
> `41             for (int i = 1; i < imax-1; i++){`  
> `42                xnew[j][i]=(x[j][i]+x[j][i-1]+x[j][i+1]+`  
> `                                      x[j-1][i]+x[j+1][i])/5.0;`  
> `43             }`  
> `44          }`  
> `45 #pragma acc parallel loop collapse(2)\`  
> `46      present(x[0:jmax][0:imax], xnew[0:jmax][0:imax])`  
> `47          for (int j = 0; j < jmax; j++){`  
> `48             for (int i = 0; i < imax; i++){`  
> `49                x[j][i] = xnew[j][i];`  
> `50             }`  
> `51          }`  
> `52          cpu_time += cpu_timer_stop(tstart_cpu);`  
> `53`  
> `54       }`

❶ Adds the collapse clause to the parallel loop directive

We can also try using the `tile` clause. We start out by letting the compiler determine the tile size as shown in lines 41 and 48 in the following listing.

**Listing 11.10 Stencil example with a** **`tile`** **clause**

> `OpenACC/Stencil/Stencil_par5.c`  
> `39       for (int ib = 0; ib < nburst; ib++){`  
> `40          cpu_timer_start(&tstart_cpu);`  
> `41 #pragma acc parallel loop tile(*,*) \                 `❶  
> `42     present(x[0:jmax][0:imax], xnew[0:jmax][0:imax])`  
> `43          for (int j = 1; j < jmax-1; j++){`  
> `44             for (int i = 1; i < imax-1; i++){`  
> `45                xnew[j][i]=(x[j][i]+x[j][i-1]+x[j][i+1]+`  
> `                                      x[j-1][i]+x[j+1][i])/5.0;`  
> `46             }`  
> `47          }`  
> `48 #pragma acc parallel loop tile(*,*) \`  
> `49     present(x[0:jmax][0:imax], xnew[0:jmax][0:imax])`  
> `50          for (int j = 0; j < jmax; j++){`  
> `51             for (int i = 0; i < imax; i++){`  
> `52                x[j][i] = xnew[j][i];`  
> `53             }`  
> `54          }`  
> `55          cpu_time += cpu_timer_stop(tstart_cpu);`  
> `56`  
> `57       }`

❶ Adds the tile clause to the parallel loop directive

The change in the run times from these optimizations is small relative to the improvement seen from the initial OpenACC implementation. Table 11.1 shows the results for the NVIDIA V100 GPU with the PGI compiler v19.7.

**Table 11.1 Run times for the OpenACC stencil kernel optimizations**

| ** **                           | **OpenACC stencil kernel run time (secs)** |
|---------------------------------|--------------------------------------------|
| Serial CPU code                 | 5.237                                      |
| Adding compute and data regions | 0.818                                      |
| Adding `collapse(2)` clause     | 0.802                                      |
| Adding `tile(*,*)` clause       | 0.806                                      |

We tried changing the vector length to 64 or 256 and different tile sizes, but didn’t see any improvement in the run times. More complex code can find more benefit from kernel optimizations, but note that any specialization of parameters such as vector length impacts portability by compilers for different architectures.

Another target for optimization is to implement a pointer swap at the end of the loop. The pointer swap is used in the original CPU code as a fast way to get data back to the original array. The copy of the data back to the original array doubles the run time on the GPU. The difficulty in pragma-based languages is that the pointer swap in a parallel region requires swapping both the host and the device pointers at the same time.

***11.2.5 Summary of performance results for the stream triad***

The run-time performance during the conversion to the GPU shows the typical pattern. Moving the computational kernels over to the GPU results in a slow down by about a factor of 3 as shown by the kernel 2 and parallel 1 implementations in table 11.2. In the kernel 1 case, the computational loop fails to parallelize. Running sequentially on the GPU, it was even slower. Once the data movement was reduced in kernel 3 and parallel 2-4, the run times showed a 67x speedup. The particular type of data region didn’t matter so much for performance, but might be important to enable ports of additional loops in more complex codes.

**Table 11.2 Run times from OpenACC stream triad kernel optimizations**

| ** **                                     | **OpenACC stream triad kernel run time (ms)** |
|-------------------------------------------|-----------------------------------------------|
| Serial CPU code                           | 39.6                                          |
| Kernel 1. Fails to parallelize loop       | 1771                                          |
| Kernel 2. Adds compute region             | 118.5                                         |
| Kernel 3. Adds dynamic data region        | 0.590                                         |
| Parallel 1. Adds compute region           | 118.8                                         |
| Parallel 2. Adds structured data region   | 0.589                                         |
| Parallel 3. Adds dynamic data region      | 0.590                                         |
| Parallel 4. Allocates data only on device | 0.586                                         |

***11.2.6 Advanced OpenACC techniques***

Many other features in OpenACC are available to handle more complex code. We’ll cover these briefly so you know what capabilities are available.

***HANDLING FUNCTIONS WITH THE OPENACC ROUTINE DIRECTIVE***

OpenACC v1.0 required functions for use in kernels to be inlined. Version 2.0 added the `routine` directive with two different versions to make calling routines simpler. The two versions are

> `#pragma acc routine [gang | worker | vector | seq | bind | no_host |`  
> `                     device_type]`  
> `#pragma acc routine(name)  [gang | worker | vector | seq | bind | no_host |`  
> `                            device_type]`

In C and C++, the `routine` directive should appear immediately before a function prototype or definition. The named version can appear anywhere before the function is defined or used. The Fortran version should include the `!#acc routine` directive within the function body itself or in the interface body.

***AVOIDING RACE CONDITIONS WITH OPENACC ATOMICS***

Many threaded routines have a shared variable that has to be updated by multiple threads. This programming construct is both a common performance bottleneck and a potential race condition. To handle this situation, OpenACC v2 provides atomics to allow only one thread to access a storage location at a time. The syntax and valid clauses for the atomic directive are

> `#pragma acc atomic [read | write | update | capture]`

If you don’t specify a clause, the default is an `update`. An example of the use of the `atomic` clause is

> `#pragma acc atomic`  
> `cnt++;`

***ASYNCHRONOUS OPERATIONS IN OPENACC***

Overlapping OpenACC operations can help improve performance. The proper term for overlapping operations is asynchronous. OpenACC provides these asynchronous operations with the `async` and `wait` clauses and directives. The `async` clause is added to a work or data directive with an optional integer argument:

> `#pragma acc parallel loop async([<integer>])`

The `wait` can be either a directive or a clause added to a work or data directive. The following pseudo-code in listing 11.11 shows how you can use this to launch the calculations on the x-faces and y-faces of a computational mesh and then wait for the results to update the cell values for the next iteration.

**Listing 11.11 Async** **`wait`** **example in OpenACC**

> `for (int n = 0; n < ntimes; ) {`  
> `   #pragma acc parallel loop async`  
> `      <x face pass>`  
> `   #pragma acc parallel loop async`  
> `      <y face pass>`  
> `   #pragma acc wait`  
> `   #pragma acc parallel loop`  
> `      <Update cell values from face fluxes>`  
> `}`

***UNIFIED MEMORY TO AVOID MANAGING DATA MOVEMENT***

Although unified memory is not currently part of the OpenACC standard, there are experimental developments with having the system manage memory movement. Such an experimental implementation of unified memory is available in CUDA and the PGI OpenACC compiler. Using the `-ta=tesla:managed` flag with the PGI compiler and recent NVIDIA GPUs, you can try out their unified memory implementation. While the coding is simplified, the performance impacts are still not known and will change as the compilers mature.

***INTEROPERABILITY WITH CUDA LIBRARIES OR KERNELS***

OpenACC provides several directives and functions to make it possible to interoperate with CUDA libraries. In calling libraries, it is necessary to tell the compiler to use the device pointers instead of host data. The `host_data` directive can be used for this purpose:

> `#pragma acc host_data use_device(x, y)`  
> `cublasDaxpy(n, 2.0, x, 1, y, 1);`

We showed a similar example when we allocated memory using `acc_malloc` in listing 11.7. With `acc_malloc` or `cudaMalloc`, the pointer returned is already on the device. For this case, we used the `deviceptr` clause to pass the pointer to the data region.

One of the most common mistakes in programming GPUs in any language is confusing a device pointer and a host pointer. Try finding 86 Pike Place, San Francisco, when it is really 86 Pike Place, Seattle. The device pointer points to a different physical block of memory on the GPU hardware.

Figure 11.4 shows the three different operations we have covered to help you understand the differences. In the first case, the `malloc` routine returns a host pointer. The `present` clause converts this to a device pointer for the device kernel. In the second case, where we allocate memory on the device with `acc_malloc` or `cudaMalloc`, we are given a device pointer. We use the `deviceptr` clause to send it to the GPU without any changes. In the last case, we don’t have a pointer on the host at all. We have to use the `host_data use_device(var)` directive to retrieve the device pointer to the host. This is done so that we have a pointer to send back to the device in the argument list for the device function.

**Figure 11.4 Is it a device pointer or a host pointer? One points to the GPU memory and the other to the CPU memory, respectively. OpenACC keeps a map between arrays in the two address spaces and provides routines for retrieving each.**

It is good practice to append a `_h` or `_d` to pointers to clarify their valid context. In our examples, all pointers and arrays are assumed to be on the host except for those ending with `_d`, which is for any device pointer.

***MANAGING MULTIPLE DEVICES IN OPENACC***

Many current HPC systems already have multiple GPUs. We can also foresee that we will get nodes with different accelerators. The ability to manage which device we are using becomes more and more important. OpenACC gives us this capability through the following functions:

- `int acc_get_num_devices(acc_device_t)`

- `acc_set_device_type() / acc_get_device_type()`

- `acc_set_device_num() / acc_get_device_num()`

We have now covered as much of OpenACC as we can in a dozen pages. The skills we’ve shown you are enough to get you started on an implementation. There is a lot more functionality available in the OpenACC standard, but much of it is for more complex situations or low-level interfaces that are not necessary for entry-level applications.

***11.3 OpenMP: The heavyweight champ enters the world of accelerators***

The OpenMP accelerator capability is an exciting addition to the traditional threading model. In this section, we show you how to get started with these directives. We’ll use the same examples as we did for the OpenACC section 11.2. By the end of this section, you should have some idea of how the two similar languages compare and which might be the better choice for your application.

Where do OpenMP’s accelerator directives stand in comparison to OpenACC? The OpenMP implementations are notably less mature at this point, though rapidly improving. The currently available implementations for GPUs are as follows:

- Cray was first with an OpenMP implementation targeting NVIDIA GPUs in 2015. Cray now supports OpenMP v4.5.

- IBM fully supports OpenMP v4.5 on Power 9 processor and NVIDIA GPUs.

- Clang v7.0+ supports OpenMP v4.5 offloads to NVIDIA GPUs.

- GCC v6+ can offload to AMD GPUs; v7+ can offload to NVIDIA GPUs.

The two most mature implementations, Cray and IBM, are available only on their respective systems. Unfortunately, not everyone has access to systems from these vendors, but there are more widely available compilers. Two of these compilers, Clang and GCC, are in the throes of development with marginal versions available now. Look out for new developments with these compilers. The examples in this section use the IBM® XL 16 compiler and CUDA v10.

***11.3.1 Compiling OpenMP code***

We start with how to set up a build environment and compile an OpenMP code. CMake has an OpenMP module, but it does not have explicit support for the OpenMP accelerator directives. We include an OpenMPAccel module that calls the regular OpenMP module and adds the flags needed for the accelerator. It also checks the OpenMP version that is supported, and if it is not v4.0 or newer, it generates an error. This CMake module is included with the source code for the chapter.

Listing 11.12 shows excerpts from the main CMakeLists.txt file in this chapter. Feedback from most of the OpenMP compilers is weak right now, so setting the `-DCMAKE_OPENMPACCEL` flag for CMake will only have minimal benefit. We’ll leverage other tools in these examples to fill in the gap.

**Listing 11.12 Excerpts from an OpenMPaccel makefile**

> `OpenMP/StreamTriad/CMakeLists.txt`  
> `10 if (NOT CMAKE_OPENMPACCEL_VERBOSE)`  
> `11     set(CMAKE_OPENMPACCEL_VERBOSE true)`  
> `12 endif (NOT CMAKE_OPENMPACCEL_VERBOSE)`  
> `13`  
> `14 if (CMAKE_C_COMPILER_ID MATCHES "GNU")`  
> `15     set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fstrict-aliasing")`  
> `16 elseif (CMAKE_C_COMPILER_ID MATCHES "Clang")`  
> `17     set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fstrict-aliasing")`  
> `18 elseif (CMAKE_C_COMPILER_ID MATCHES "XL")`  
> `19     set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -qalias=ansi")`  
> `20 elseif (CMAKE_C_COMPILER_ID MATCHES "Cray")`  
> `21     set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -h restrict=a")`  
> `22 endif (CMAKE_C_COMPILER_ID MATCHES "GNU")`  
> `23`  
> `24 find_package(OpenMPAccel)                                         `❶  
> `25`  
> `26 if (CMAKE_C_COMPILER_ID MATCHES "XL")`  
> `27     set(OpenMPAccel_C_FLAGS                                       `❷  
> `         "${OpenMPAccel_C_FLAGS} -qreport")                          `❷  
> `28 elseif (CMAKE_C_COMPILER_ID MATCHES "GNU")`  
> `29     set(OpenMPAccel_C_FLAGS`  
> `         "${OpenMPAccel_C_FLAGS} -fopt-info-omp")                    `❷  
> `30 endif (CMAKE_C_COMPILER_ID MATCHES "XL")`  
> `31`  
> `32 if (CMAKE_OPENMPACCEL_VERBOSE)`  
> `33     set(OpenACC_C_FLAGS "${OpenACC_C_FLAGS} ${OpenACC_C_VERBOSE}")`  
> `34 endif (CMAKE_OPENMPACCEL_VERBOSE)`  
> `35`  
> `36 # Adds build target of stream_triad_par1 with source code files`  
> `37 add_executable(StreamTriad_par1 StreamTriad_par1.c timer.c timer.h)`  
> `38 set_target_properties(StreamTriad_par1 PROPERTIES`  
> `                         COMPILE_FLAGS ${OpenMPAccel_C_FLAGS})       `❸  
> `39 set_target_properties(StreamTriad_par1 PROPERTIES`  
> `                         LINK_FLAGS "${OpenMPAccel_C_FLAGS}")        `❸

❶ CMake module sets compiler flags for OpenMP accelerator devices.

❷ Adds compiler feedback for accelerator directives

❸ Adds OpenMP accelerator flags for compiling and linking of stream triad

The simple makefile can also be used for building the example codes by copying or linking these over to `Makefile` with either of the following:

> `ln -s Makefile.simple.xl Makefile`  
> `cp Makefile.simple.xl Makefile`

The following code snippet shows the suggested flags for the OpenMP accelerator directives in the simple makefiles for the IBM XL and GCC compilers:

> `Makefile.simple.xl`  
> `6 CFLAGS:=-qthreaded -g -O3 -std=gnu99 -qalias=ansi -qhot -qsmp=omp \`  
> `           -qoffload -qreport`  
> `7`  
> `8 %.o: %.c`  
> `9   ${CC} ${CFLAGS} -c $^`  
> `10`  
> `11 StreamTriad: StreamTriad.o timer.o`  
> `12   ${CC} ${CFLAGS} $^ -o StreamTriad`  
>   
> `Makefile.simple.gcc`  
> `6 CFLAGS:= -g -O3 -std=gnu99 -fstrict-aliasing \`  
> `7          -fopenmp -foffload=nvptx-none -foffload=-lm -fopt-info-omp`  
> `8`  
> `9 %.o: %.c`  
> `10   ${CC} ${CFLAGS} -c $^`  
> `11`  
> `12 StreamTriad: StreamTriad.o timer.o`  
> `13   ${CC} ${CFLAGS} $^ -o StreamTriad`

***11.3.2 Generating parallel work on the GPU with OpenMP***

Now we need to generate parallel work on the GPU. The OpenMP device parallel abstractions are more complicated than we saw with OpenACC. But this can also provide more flexibility in scheduling work in the future. For now, you should preface each loop with this directive:

> `#pragma omp target teams distribute parallel for simd`

This is a long, confusing directive. Let’s go over each of the parts as illustrated in figure 11.5. The first three clauses specify hardware resources:

- `target` gets onto the device

- `teams` creates a league of teams

- `distribute` spreads work out to teams

**Figure 11.5 The** **`target`,** **`teams`, and** **`distribute`** **directives enable more hardware resources. The** **`parallel for simd`** **directive spreads out the work within each workgroup.**

The remaining three are the parallel work clauses. All three clauses are necessary for portability. This is because the implementations by compilers spread out the work in different manners.

- `parallel` replicates work on each thread

- `for` spreads work out within each team

- `simd` spreads work out to threads (GCC)

For kernels with three nested loops, one way you can spread out the work is with the following:

> `k loop: #pragma omp target teams distribute`  
> `j loop: #pragma omp parallel for`  
> `i loop: #pragma omp simd`

Each OpenMP compiler can spread out the work differently, thus requiring some variants of this scheme. The `simd` loop should be the inner loop across contiguous memory locations. Some simplification of this complexity is being introduced with the `loop` clause in OpenMP v5.0 as we will present in section 11.3.5. You can also add clauses to this directive:

> `private, firstprivate, lastprivate, shared, reduction, collapse,`  
> `         dist_schedule`

Many of these clauses are familiar from OpenACC and behave the same way. One of the major differences from OpenACC is the default way that data is handled when entering a parallel work region. OpenACC compilers generally move all necessary arrays to the device. For OpenMP, there are two possibilities:

- Scalars and statically allocated arrays are moved onto the device by default before execution.

- Data allocated on the heap needs to be explicitly copied to and from the device.

Let’s look at a simple example of adding a parallel work directive in listing 11.13. We use statically allocated arrays that behave as if they are allocated on the stack; although, because of the large size, the actual memory might be allocated by the compiler on the heap.

**Listing 11.13 Adding OpenMP pragmas to parallelize work on the GPU**

> `OpenMP/StreamTriad/StreamTriad_par1.c`  
> `6 int main(int argc, char *argv[]){`  
> `7`  
> `8    int nsize = 20000000, ntimes=16;`  
> `9    double a[nsize];                  `❶  
> `10    double b[nsize];                  `❶  
> `11    double c[nsize];                  `❶  
> `12`  
> `13    struct timespec tstart;`  
> `14    // initializing data and arrays`  
> `15    double scalar = 3.0, time_sum = 0.0;`  
> `16 #pragma omp target teams distribute parallel for simd`  
> `17    for (int i=0; i<nsize; i++) {`  
> `18       a[i] = 1.0;`  
> `19       b[i] = 2.0;`  
> `20    }`  
> `21`  
> `22    for (int k=0; k<ntimes; k++){`  
> `23       cpu_timer_start(&tstart);`  
> `24       // stream triad loop`  
> `25 #pragma omp target teams distribute parallel for simd`  
> `26       for (int i=0; i<nsize; i++){`  
> `27          c[i] = a[i] + scalar*b[i];`  
> `28       }`  
> `29       time_sum += cpu_timer_stop(tstart);`  
> `30    }`  
> `31`  
> `32    printf("Average runtime for stream triad loop is %lf secs\n",`  
> `             time_sum/ntimes);`

❶ Allocating static arrays on the host

The feedback from the IBM XL compiler shows that the two kernels are offloaded to the GPU, but no other information is proffered. GCC gives no feedback at all. The IBM XL output is

> `"" 1586-672 (I) GPU OpenMP Runtime elided for offloaded kernel`  
> `                '__xl_main_l15_OL_1'`  
> `"" 1586-672 (I) GPU OpenMP Runtime elided for offloaded kernel`  
> `                '__xl_main_l23_OL_2'`

To get some information on what the IBM XL compiler has done, we’ll use the NVIDIA profiler:

> `nvprof ./StreamTriad_par1`

The first part of the output is

From this output, we now know that there is a memory copy from the host to the device (`HtoD` in the output) and then back from the device to the host (`DtoH` in the output). The `nvprof` output from GCC is similar but without line numbers. More detail about the order in which the operations occur can be obtained with the following:

> `nvprof --print-gpu-trace ./StreamTriad_par1`

Most programs are not written with statically allocated arrays. Let’s take a look at a more commonly found case where the arrays are dynamically allocated as the following listing shows.

**Listing 11.14 Parallel work directive with arrays dynamically allocated**

> `OpenMP/StreamTriad/StreamTriad_par2.c`  
> `9    double* restrict a =`  
> `         malloc(nsize * sizeof(double));      `❶  
> `10    double* restrict b =`  
> `         malloc(nsize * sizeof(double));      `❶  
> `11    double* restrict c =`  
> `         malloc(nsize * sizeof(double));      `❶  
> `12`  
> `13    struct timespec tstart;`  
> `14    // initializing data and arrays`  
> `15    double scalar = 3.0, time_sum = 0.0;`  
> `16 #pragma omp target teams distribute \      `❷  
> `               parallel for simd \            `❷  
> `17             map(a[0:nsize], b[0:nsize],`  
> `                   c[0:nsize])                `❷  
> `18    for (int i=0; i<nsize; i++) {`  
> `19       a[i] = 1.0;`  
> `20       b[i] = 2.0;`  
> `21    }`  
> `22`  
> `23    for (int k=0; k<ntimes; k++){`  
> `24       cpu_timer_start(&tstart);`  
> `25       // stream triad loop`  
> `26 #pragma omp target teams distribute \      `❷  
> `               parallel for simd \            `❷  
> `27             map(a[0:nsize], b[0:nsize],`  
> `                   c[0:nsize])                `❷  
> `28       for (int i=0; i<nsize; i++){`  
> `29          c[i] = a[i] + scalar*b[i];`  
> `30       }`  
> `31       time_sum += cpu_timer_stop(tstart);`  
> `32    }`  
> `33`  
> `34    printf("Average runtime for stream triad loop is %lf secs\n",`  
> `             time_sum/ntimes);`  
> `35`  
> `36    free(a);`  
> `37    free(b);`  
> `38    free(c);`

❶ Dynamically allocated memory

❷ Parallel work directive for heap allocated memory

Note that lines 16 and 26 have added the `map` clause. If you try the directive without this clause, although it compiles fine with the IBM XLC compiler, at run time you’ll get this message:

> `1587-164 Encountered a zero-length array section that points to memory starting at address 0x200020000010. Because this memory is not currently mapped on the target device 0, a NULL pointer will be passed to the device.`  
> `1587-175 The underlying GPU runtime reported the following error "an illegal memory access was encountered".`  
> `1587-163 Error encountered while attempting to execute on the target device 0.  The program will stop.`

The GCC compiler, however, both compiles and runs fine without the `map` directive. Thus, the GCC compiler moves heap allocated memory over to the device while IBM XLC does not. For portability, we should include the `map` clause in our application code.

OpenMP also has the `reduction` clause for the parallel work-region directives. The syntax is similar to that for the threaded OpenMP work directives and OpenACC. An example of the directive is as follows:

> `#pragma omp teams distribute parallel for simd reduction(+:sum)`

***11.3.3 Creating data regions to control data movement to the GPU with OpenMP***

Now that we have the work moved over to the GPU, we can add data regions to manage the data movement to and from the GPU. The data movement directives in OpenMP are similar to those in OpenACC with both a structured and dynamic version. The form of the directive is

> `#pragma omp target data [ map() | use_device_ptr() ]`

The work directives are wrapped in the structured data region as listing 11.15 shows. The data is copied over to the GPU, if not already there. The data is then maintained there until the end of the block (at line 35) and copied back. This greatly reduces the data transfers for every parallel work loop and should result in a net speedup in the overall application run time.

**Listing 11.15 Adding OpenMP pragmas to create a structured data region on the GPU**

> `OpenMP/StreamTriad/StreamTriad_par3.c`  
> `17 #pragma omp target data map(to:a[0:nsize], \    `❶  
> `                      b[0:nsize], c[0:nsize])      `❶  
> `18    {                                            `❶  
> `19 #pragma omp target teams distribute \           `❷  
> `               parallel for simd                   `❷  
> `20       for (int i=0; i<nsize; i++) {`  
> `21          a[i] = 1.0;`  
> `22          b[i] = 2.0;`  
> `23       }`  
> `24`  
> `25       for (int k=0; k<ntimes; k++){`  
> `26          cpu_timer_start(&tstart);`  
> `27          // stream triad loop`  
> `28 #pragma omp target teams distribute \           `❷  
> `               parallel for simd                   `❷  
> `29          for (int i=0; i<nsize; i++){`  
> `30             c[i] = a[i] + scalar*b[i];`  
> `31          }`  
> `32          time_sum += cpu_timer_stop(tstart);`  
> `33       }`  
> `34`  
> `35    }                                            `❶

❶ Structured data region directive

❷ Work region directive

Structured data regions cannot handle more general-programming patterns. Both OpenACC and OpenMP (version 4.5) added dynamic data regions, often referred to as unstructured data regions. The form for the directive has `enter` and `exit` clauses with a map modifier to specify the data transfer operation (such as the defaults `to` and `from`):

> `#pragma omp target enter data map([alloc | to]:array[[start]:[length]])`  
> `#pragma omp target exit data map([from | release | delete]:`  
> `                                  array[[start]:[length]])`

In listing 11.16, we convert the `omp target data` directive to `omp target enter data` directive (line 13). The scope of the data on the GPU concludes when it encounters an `omp target exit data` directive (line 36). The effect of these directives is the same as the structured data region in listing 11.15. But the dynamic data region can be used in more complex data management scenarios like constructors and destructors in C++.

**Listing 11.16 Using a dynamic OpenMP data region**

> `OpenMP/StreamTriad/StreamTriad_par4.c`  
> `13 #pragma omp target enter data \                  `❶  
> `      map(to:a[0:nsize], b[0:nsize], c[0:nsize])    `❶  
> `14`  
> `15    struct timespec tstart;`  
> `16    // initializing data and arrays`  
> `17    double scalar = 3.0, time_sum = 0.0;`  
> `18 #pragma omp target teams distribute \            `❷  
> `               parallel for simd                    `❷  
> `19    for (int i=0; i<nsize; i++) {`  
> `20       a[i] = 1.0;`  
> `21       b[i] = 2.0;`  
> `22    }`  
> `23`  
> `24    for (int k=0; k<ntimes; k++){`  
> `25       cpu_timer_start(&tstart);`  
> `26       // stream triad loop`  
> `27 #pragma omp target teams distribute \            `❷  
> `               parallel for simd                    `❷  
> `28       for (int i=0; i<nsize; i++){`  
> `29          c[i] = a[i] + scalar*b[i];`  
> `30       }`  
> `31       time_sum += cpu_timer_stop(tstart);`  
> `32    }`  
> `33`  
> `34    printf("Average runtime for stream triad loop is %lf msecs\n",`  
> `             time_sum/ntimes);`  
> `35`  
> `36 #pragma omp target exit data \                   `❸  
> `     map(from:a[0:nsize], b[0:nsize], c[0:nsize])   `❸

❶ Starts dynamic data region directive

❷ Work region directive

❸ Ends dynamic data region directive

We can further optimize the data transfers by allocating on the device and deleting the arrays on exit from the data region, thereby eliminating another data transfer. When transfers are needed to move data back and forth from the CPU and the GPU, you can use the `omp target update` directive. The syntax for the directive is

> `#pragma omp target update [to | from] (array[start:length])`

We should also recognize that in this example the CPU never uses the array memory. For memory that only exists on the GPU, we can allocate it there and then tell the parallel work regions that it is already there. There are a couple of ways we can do this. One is to use an OpenMP function call to allocate and free memory on the device. These calls look like the following and require the inclusion of the OpenMP header file:

> `#include <omp.h>`  
> `double *a = omp_target_alloc(nsize*sizeof(double), omp_get_default_device());`  
> `omp_target_free(a, omp_get_default_device());`

We could also use the CUDA memory allocation routines. We need to include the CUDA run-time header file to use these routines:

> `#include <cuda_runtime.h>`  
> `cudaMalloc((void *)&a,nsize*sizeof(double));`  
> `cudaFree(a);`

On the parallel work directives, we then need to add another clause to pass the device pointers to the kernels on the device:

> `#pragma omp target teams distribute parallel for is_device_ptr(a)`

Putting this all together, we end up with the changes to the code shown in the following listing.

**Listing 11.17 Creating arrays only on the GPU**

> `OpenMP/StreamTriad/StreamTriad_par6.c`  
> `11    double *a = omp_target_alloc(nsize*sizeof(double),`  
> `                  omp_get_default_device());`  
> `12    double *b = omp_target_alloc(nsize*sizeof(double),`  
> `                  omp_get_default_device());`  
> `13    double *c = omp_target_alloc(nsize*sizeof(double),`  
> `                  omp_get_default_device());`  
> `14`  
> `15    struct timespec tstart;`  
> `16    // initializing data and arrays`  
> `17    double scalar = 3.0, time_sum = 0.0;`  
> `18 #pragma omp target teams distribute`  
> `               parallel for simd is_device_ptr(a, b, c)`  
> `19    for (int i=0; i<nsize; i++) {`  
> `20       a[i] = 1.0;`  
> `21       b[i] = 2.0;`  
> `22    }`  
> `23`  
> `24    for (int k=0; k<ntimes; k++){`  
> `25       cpu_timer_start(&tstart);`  
> `26       // stream triad loop`  
> `27 #pragma omp target teams distribute \`  
> `               parallel for simd is_device_ptr(a, b, c)`  
> `28       for (int i=0; i<nsize; i++){`  
> `29          c[i] = a[i] + scalar*b[i];`  
> `30       }`  
> `31       time_sum += cpu_timer_stop(tstart);`  
> `32    }`  
> `33`  
> `34    printf("Average runtime for stream triad loop is %lf msecs\n",`  
> `             time_sum/ntimes);`  
> `35`  
> `36    omp_target_free(a, omp_get_default_device());`  
> `37    omp_target_free(b, omp_get_default_device());`  
> `38    omp_target_free(c, omp_get_default_device());`

OpenMP has another way to allocate data on the device. This method uses the `omp declare target` directive as shown in listing 11.18. We first declare the pointers to the array on lines 10-12 and then allocate these on the device with the following block of code (lines 14-19). A similar block is used on lines 42-47 for freeing the data on the device.

**Listing 11.18 Using** **`omp declare`** **to create arrays only on the GPU**

> `OpenMP/StreamTriad/StreamTriad_par8.c`  
> `10 #pragma omp declare target                 `❶  
> `11    double *a, *b, *c;                      `❶  
> `12 #pragma omp end declare target             `❶  
> `13`  
> `14 #pragma omp target                         `❷  
> `15    {                                       `❷  
> `16        a = malloc(nsize* sizeof(double);   `❷  
> `17        b = malloc(nsize* sizeof(double);   `❷  
> `18        c = malloc(nsize* sizeof(double);   `❷  
> `19    }                                       `❷  
> `     < unchanged code>`  
> `42 #pragma omp target                         `❸  
> `43    {                                       `❸  
> `44        free(a);                            `❸  
> `45        free(b);                            `❸  
> `46        free(c);                            `❸  
> `47    }                                       `❸

❶ Declares target creates a pointer on the device

❷ Allocates data on the device

❸ Frees device data

As we have seen, there are a lot of different options for data management for the GPU. We now have covered the most common data region directives and clauses in OpenMP. Recent additions to the OpenMP standard handle more complicated data structures and data transfers.

***11.3.4 Optimizing OpenMP for GPUs***

Let’s switch to a stencil example for the kernel optimization like we did for OpenACC. There are a few things you can try for speeding up individual kernels, but for the most part, it is best to let the compiler do the optimization for portability reasons. The core part of the stencil kernel with the OpenMP data and work regions in the following listing is the starting point for the optimization work.

**Listing 11.19 Initial OpenMP version of stencil**

> `OpenMP/Stencil/Stencil_par2.c`  
> `15    double** restrict x    = malloc2D(jmax, imax);`  
> `16    double** restrict xnew = malloc2D(jmax, imax);`  
> `17`  
> `18 #pragma omp target enter data \                   `❶  
> `      map(to:x[0:jmax][0:imax], \                    `❶  
> `             xnew[0:jmax][0:imax])                   `❶  
> `19`  
> `20 #pragma omp target teams                          `❷  
> `21    {                                              `❷  
> `22 #pragma omp distribute parallel for simd          `❷  
> `23       for (int j = 0; j < jmax; j++){`  
> `24          for (int i = 0; i < imax; i++){`  
> `25             xnew[j][i] = 0.0;`  
> `26             x[j][i]    = 5.0;`  
> `27          }`  
> `28       }`  
> `29`  
> `30 #pragma omp distribute parallel for simd          `❷  
> `31       for (int j = jmax/2 - 5; j < jmax/2 + 5; j++){`  
> `32          for (int i = imax/2 - 5; i < imax/2 -1; i++){`  
> `33             x[j][i] = 400.0;`  
> `34          }`  
> `35       }`  
> `36    } // omp target teams                          `❷  
> `37`  
> `38    for (int iter = 0; iter < niter; iter+=nburst){`  
> `39`  
> `40       for (int ib = 0; ib < nburst; ib++){`  
> `41          cpu_timer_start(&tstart_cpu);`  
> `42 #pragma omp target teams distribute \            `❷  
> `               parallel for simd                    `❷  
> `43          for (int j = 1; j < jmax-1; j++){       `❸  
> `44             for (int i = 1; i < imax-1; i++){    `❸  
> `45                xnew[j][i]=(x[j][i]+              `❸  
> `                     x[j][i-1]+x[j][i+1]+           `❸  
> `                     x[j-1][i]+x[j+1][i])/5.0;      `❸  
> `46             }                                    `❸  
> `47          }                                       `❸  
> `48`  
> `49 #pragma omp target teams distribute \            `❷  
> `               parallel for simd                    `❷  
> `50          for (int j = 0; j < jmax; j++){         `❹  
> `51             for (int i = 0; i < imax; i++){      `❹  
> `52                x[j][i] = xnew[j][i];             `❹  
> `53             }                                    `❹  
> `54          }                                       `❹  
> `55          cpu_time += cpu_timer_stop(tstart_cpu);`  
> `56`  
> `57       }`  
> `58`  
> `59       printf("Iter %d\n",iter+nburst);`  
> `60    }`  
> `61`  
> `62 #pragma omp target exit data \                   `❺  
> `      map(from:x[0:jmax][0:imax], \                 `❺  
> `               xnew[0:jmax][0:imax])                `❺  
> `63`  
> `64    free(x);`  
> `65    free(xnew);`

❶ OpenMP data region

❷ Parallel work directive

❸ Stencil kernel

❹ Replaces swap with copy from new back to original

❺ OpenMP data region

Simply adding a single work directive for the 2D loop and the data construct is not enough to get the work efficiently generated for the GPU for version 16 of the IBM XL compiler. The run time is nearly twice as long as the serial version (see table 11.4 at the end of this section). You can use `nvprof` to find where the time is being spent. Here’s the output:

The first line shows that the third kernel is taking up more than 50% of the run time. The copy back to the original array is taking an additional 48% of the run time. It’s the kernel code and not the data transfer that is causing the problem! To correct this, the first thing to try is to collapse the two nested loops into a single parallel construct. The changes for this include adding the `collapse` clause along with the number of loops to collapse on the work directives. This is shown on lines 22, 30, 42, and 49 in the next listing.

**Listing 11.20 Using** **`collapse`** **for optimization**

> `OpenMP/Stencil/Stencil_par3.c`  
> `20 #pragma omp target teams`  
> `21    {`  
> `22 #pragma omp distribute parallel \                `❶  
> `               for simd collapse(2)                 `❶  
> `23       for (int j = 0; j < jmax; j++){`  
> `24          for (int i = 0; i < imax; i++){`  
> `25             xnew[j][i] = 0.0;`  
> `26             x[j][i]    = 5.0;`  
> `27          }`  
> `28       }`  
> `29`  
> `30 #pragma omp distribute parallel \                `❶  
> `               for simd collapse(2)                 `❶  
> `31       for (int j = jmax/2 - 5; j < jmax/2 + 5; j++){`  
> `32          for (int i = imax/2 - 5; i < imax/2 -1; i++){`  
> `33             x[j][i] = 400.0;`  
> `34          }`  
> `35       }`  
> `36    }`  
> `37`  
> `38    for (int iter = 0; iter < niter; iter+=nburst){`  
> `39`  
> `40       for (int ib = 0; ib < nburst; ib++){`  
> `41          cpu_timer_start(&tstart_cpu);`  
> `42 #pragma omp target teams distribute \            `❶  
> `               parallel for simd collapse(2)        `❶  
> `43          for (int j = 1; j < jmax-1; j++){`  
> `44             for (int i = 1; i < imax-1; i++){`  
> `45                xnew[j][i]=(x[j][i]+x[j][i-1]+x[j][i+1]+`  
> `                                      x[j-1][i]+x[j+1][i])/5.0;`  
> `46             }`  
> `47          }`  
> `48`  
> `49 #pragma omp target teams distribute \            `❶  
> `               parallel for simd collapse(2)        `❶  
> `50          for (int j = 0; j < jmax; j++){`  
> `51             for (int i = 0; i < imax; i++){`  
> `52                x[j][i] = xnew[j][i];`  
> `53             }`  
> `54          }`  
> `55          cpu_time += cpu_timer_stop(tstart_cpu);`  
> `56`  
> `57       }`  
> `58`  
> `59       printf("Iter %d\n",iter+nburst);`  
> `60    }`

❶ Adds collapse clause

The run time is now faster than the CPU (see table 11.3), though not as fast as the version generated by the PGI OpenACC compiler (table 11.1). We expect that as the IBM XL compiler improves, this should get better. Let’s try another approach of splitting the parallel work directives across the two loops as shown in the following listing.

**Listing 11.21 Splitting work directives for optimization**

> `OpenMP/Stencil/Stencil_par4.c`  
> `20 #pragma omp target teams`  
> `21    {`  
> `22 #pragma omp distribute                         `❶  
> `23       for (int j = 0; j < jmax; j++){`  
> `24 #pragma omp parallel for simd                  `❶  
> `25          for (int i = 0; i < imax; i++){`  
> `26             xnew[j][i] = 0.0;`  
> `27             x[j][i]    = 5.0;`  
> `28          }`  
> `29       }`  
> `30`  
> `31 #pragma omp distribute                         `❶  
> `32       for (int j = jmax/2 - 5; j < jmax/2 + 5; j++){`  
> `33 #pragma omp parallel for simd                  `❶  
> `34          for (int i = imax/2 - 5; i < imax/2 -1; i++){`  
> `35             x[j][i] = 400.0;`  
> `36          }`  
> `37       }`  
> `38    }`  
> `39`  
> `40    for (int iter = 0; iter < niter; iter+=nburst){`  
> `41`  
> `42       for (int ib = 0; ib < nburst; ib++){`  
> `43          cpu_timer_start(&tstart_cpu);`  
> `44 #pragma omp target teams distribute            `❶  
> `45          for (int j = 1; j < jmax-1; j++){`  
> `46 #pragma omp parallel for simd                  `❶  
> `47             for (int i = 1; i < imax-1; i++){`  
> `48                xnew[j][i]=(x[j][i]+x[j][i-1]+x[j][i+1]+`  
> `                                      x[j-1][i]+x[j+1][i])/5.0;`  
> `49             }`  
> `50          }`  
> `51`  
> `52 #pragma omp target teams distribute            `❶  
> `53          for (int j = 0; j < jmax; j++){`  
> `54 #pragma omp parallel for simd                  `❶  
> `55             for (int i = 0; i < imax; i++){`  
> `56                x[j][i] = xnew[j][i];`  
> `57             }`  
> `58          }`  
> `59          cpu_time += cpu_timer_stop(tstart_cpu);`  
> `60`  
> `61       }`  
> `62`  
> `63       printf("Iter %d\n",iter+nburst);`  
> `64    }`

❶ Splits work over two loop levels

The timing from the IBM XL compiler for the split parallel work directives is similar to the `collapse` clause. Table 11.3 shows the results of our experiments with kernel optimizations.

**Table 11.3 Run times from OpenMP stencil kernel optimizations**

| ** **                           | **Open MP stencil kernel run time (secs)** |
|---------------------------------|--------------------------------------------|
| Serial CPU code                 | 5.497                                      |
| Adding work directive           | 19.01                                      |
| Adding compute and data regions | 18.97                                      |
| Adding `collapse(2)` clause     | 3.035                                      |
| Splitting parallel directives   | 2.50                                       |

We also look at the run time results for the stream triad example from the IBM XL compiler v16 on a Power 9 processor with an NVIDIA V100 GPU in table 11.4. The performance on the CPU is different because, in one case, we used an Intel Skylake processor and, in this case, we are using a Power 9 processor. But it is encouraging to see that the performance of the stream kernel with OpenMP on the V100 GPU is essentially the same as that for the PGI OpenACC compiler in table 11.2.

**Table 11.4 Run times from OpenMP stream triad kernel optimizations**

| ** **                                      | **OpenMP stream triad kernel run time (ms)** |
|--------------------------------------------|----------------------------------------------|
| Serial CPU code                            | 15.9                                         |
| Parallel 1. Compute region added           | 85.7                                         |
| Parallel 3. Structured data region added   | 0.585                                        |
| Parallel 4. Dynamic data region added      | 0.584                                        |
| Parallel 8. Allocating data only on device | 0.584                                        |

The performance of OpenMP with the IBM XL compiler is good on a simple 1D test problem but could be improved for the 2D stencil case. The focus thus far has been on correctly implementing the OpenMP standard for device offloading. We expect that performance will improve with each compiler release and with more compiler vendors offering OpenMP device offloading support.

***11.3.5 Advanced OpenMP for GPUs***

OpenMP has many additional advanced capabilities. OpenMP is also changing based on the experience with the early implementations on GPUs and as hardware continues to evolve. We’ll cover just a few of the advanced directives and clauses that are important for

- Fine-tuning kernels

- Handling various important programming constructs (functions, scans, and shared access to variables)

- Asynchronous operations that overlap data movement and computation

- Controlling memory placement

- Handling complex data structures

- Simplifying work directives

***CONTROLLING THE GPU KERNEL PARAMETERS IMPLEMENTED BY THE OPENMP COMPILER***

We start by looking at clauses that can be used to fine-tune kernel performance. We can add these clauses to directives to modify the kernels that the compiler generates for the GPU:

- `num_teams` defines the number of teams generated by the `teams` directive.

- `thread_limit` adds the number of threads used by each team.

- `schedule` or `schedule(static,1)` specifies that the work items are distributed in a round-robin manner rather than in a block. This can help with memory load coalescing on the GPU.

- `simdlen` specifies the vector length or threads for the workgroup.

These clauses can be useful in special situations, but in general, it is better to leave the parameters for the compiler to optimize.

***DECLARING AN OPENMP DEVICE FUNCTION***

When we call a function within a parallel region on the device, we need a way to tell the compiler it should also be on the device. This is done by adding a `declare target` directive to the function. The syntax is similar to that for variable declarations. Here is an example:

> `#pragma omp declare target`  
> `int my_compute(<args>){`  
> `   <work>`  
> `}`

***NEW SCAN REDUCTION TYPE***

We discussed the importance of the scan algorithm in section 5.6, where we also saw the complexity of implementing this algorithm on the GPU. This is a ubiquitous operation in parallel computing and complicated to write, so the addition of this type is helpful. The `scan` type will be available in version 5.0 of OpenMP.

> `int run_sum = 0;`  
> `#pragma omp parallel for simd reduction(inscan,+: run_sum)`  
> `for (int i = 0; i < n; ++i) {`  
> `   run_sum += ncells[i];`  
> `   #pragma omp scan exclusive(run_sum)`  
> `   cell_start[i] = run_sum;`  
> `   #pragma omp scan inclusive(run_sum)`  
> `   cell_end[i] = run_sum;`  
> `} `

***PREVENTING RACE CONDITIONS WITH OPENMP ATOMIC***

It is normal in an algorithm that several threads access a common variable. It is often a bottleneck in the performance of routines. Atomics have provided this functionality in various compilers and thread implementations. OpenMP also provides an `atomic` directive. An example of the use of the directive is

> `#pragma omp atomic`  
> `   i++;`

***OPENMP’S VERSION OF ASYNCHRONOUS OPERATIONS***

In section 10.5, we discussed the value of overlapping data transfer and computation through asynchronous operations. OpenMP also provides its version of these operations.

You create asynchronous device operations using the `nowait` clause on either a data or work directive. You can then use a `depend` clause to specify that a new operation cannot start until the previous operation is complete. These operations can be chained to form a sequence of operations. We can use a simple `taskwait` directive to wait for completion of all tasks:

> `#pragma omp taskwait`

***ACCESSING SPECIAL MEMORY SPACES***

Memory bandwidth is often one of the most important performance limits. With pragma-based languages, it has not always been possible to control the placement of memory and the resulting memory bandwidth. The addition of features to give the programmer more control over this has been one of the more eagerly anticipated additions to OpenMP. With OpenMP 5.0, you will be able to target special memory spaces such as shared memory and high-bandwidth memory. The capability is through a new `allocator` clause modifier. The `allocate` clause takes an optional modifier as follows:

> `allocate([allocator:] list)`

You can use the following pair of functions to directly allocate and free memory:

> `omp_alloc(size_t size, omp_allocator_t *allocator)`  
> `omp_free(void *ptr, const omp_allocator_t *allocator)`

The OpenMP 5.0 standard specifies some predefined memory spaces for allocators as this table shows.

| **Memory space**                                  | **Memory type description**           |
|---------------------------------------------------|---------------------------------------|
| `omp_default_mem_alloc/omp_default_mem_space`     | Default system storage space          |
| `omp_large_cap_mem_alloc/omp_large_cap_mem_space` | Large-capacity storage space          |
| `omp_const_mem_alloc/omp_const_mem_space`         | Storage for constant, unchanging data |
| `omp_high_bw_mem_alloc/omp_high_bw_mem_space`     | High bandwidth memory                 |
| `omp_low_lat_mem_alloc/omp_low_lat_mem_space`     | Storage with low latency              |

A set of functions is available to define new memory allocators. The two main routines are

> `omp_init_allocator`  
> `omp_destroy_allocator`

These allocators take one of the predefined space arguments and allocator traits such as whether it should be pinned, aligned, private, nearby, or many others. Implementations of this capability are still under development. This functionality will be of increasing importance with new architectures, where there are special memory types with different latency and bandwidth performance characteristics.

***DEEP COPY SUPPORT FOR TRANSFERRING COMPLEX DATA STRUCTURES***

OpenMP 5.0 also adds a `declare mapper` construct that can do deep copies. Deep copies not only duplicate a data structure with pointers but also the data referred to by the pointers. Programs with complex data structures and classes have struggled with the difficulty of porting to GPUs. The ability to do deep copies greatly simplifies these implementations.

***SIMPLIFYING WORK DISTRIBUTION WITH THE NEW LOOP DIRECTIVE***

The OpenMP 5.0 standard introduces more flexible work directives. One of these is the `loop` directive that is simpler and closer to the functionality in OpenACC. The `loop` directive takes the place of `distribute parallel for simd`. With the `loop` directive, you are telling the compiler that the loop iterations can be executed concurrently, but you leave the actual implementation to the compiler. The following listing shows an example of using this directive in the stencil kernel.

**Listing 11.22 Using the new** **`loop`** **directive in OpenMP 5.0**

> `47 #pragma omp target teams                     `❶  
> `48 #pragma omp loop                             `❷  
> `49          for (int j = 1; j < jmax-1; j++){`  
> `50 #pragma omp loop                             `❷  
> `51             for (int i = 1; i < imax-1; i++){`  
> `52                xnew[j][i]=(x[j][i]+x[j][i-1]+x[j][i+1]+`  
> `                                      x[j-1][i]+x[j+1][i])/5.0;`  
> `53             }`  
> `54          }`

❶ Launches work on the GPU with multiple teams

❷ The loop parallelized as independent work

The `loop` clause is really a `loop independent` or `concurrent` clause that tells the compiler that iterations of the loop have no dependencies. The `loop` clause gives the compiler information or a descriptive clause rather than telling the compiler what to do, which is a prescriptive clause. Most compilers have not implemented this new feature, so we continue to work with the prescriptive clauses in the earlier examples in this chapter. If you’re not familiar with these concepts, here’s a definition of each:

- Prescriptive directives and clauses—Directives from the programmer that tell the compiler specifically what to do.

- Descriptive directives and clauses—Directives that give the compiler information about the following loop construct; also gives the compiler some freedom to generate the most efficient implementation.

OpenMP has traditionally used prescriptive clauses in its specifications. This reduces the variation between implementations and improves portability. But in the case of GPUs, it has led to the long, complex directives with subtle differentiation on whether synchronization is possible between threads and other hardware-specific features.

The descriptive approach is closer to the OpenACC philosophy and is not so burdened with the details of the hardware. This gives the compiler both the freedom and responsibility of how to properly and effectively generate code for the targeted hardware. Note that this is not only a significant shift for OpenMP, but an important one. If OpenMP continues to try and go down the path of prescriptive directives, as hardware complexity continues to grow, the OpenMP language will grow too complicated and the portability of codes will be reduced.

***11.4 Further explorations***

Both OpenACC and OpenMP are large languages with many directives, clauses, modifiers, and functions. Beyond the core functionality of these languages, there are few examples and sparse documentation. Indeed, many of the lesser used parts may not work in all compilers. You should test new functionality in a small example before adding it to a large application. To learn more about these languages, refer to the additional reading materials that follow. Also, be sure and get some hands-on experience with the exercises in section 11.4.2.

***11.4.1 Additional reading***

Because the OpenACC and OpenMP languages are still evolving, the best sources for additional materials are at the respective websites: <https://openacc.org> and [https:// openmp.org](https://openmp.org). Each site lists additional resources, including tutorials and presentations at leading HPC conferences.

***OPENACC RESOURCES AND REFERENCES***

OpenACC has been out a little longer than OpenMP and has more books and documentation. The starting place for the language is the OpenACC standard. At 150 pages, version 3.0 of the standard is very readable and relevant to the end user. It can be found on the openacc.org website. The following URL provides a link to The OpenACC Application Programming Interface, v3.0 (November, 2018):

[https://www.openacc.org/sites/default/files/inline-images/Specification/ OpenACC.3.0.pdf.](https://www.openacc.org/sites/default/files/inline-images/Specification/OpenACC.3.0.pdf)

The OpenACC site also has a document on programming and best practices. It is not linked to a particular version of the standard, but has not been updated since 2015. You’ll find OpenACC-standard.org’s OpenACC Programming and Best Practices Guide (June, 2015) here:

[https://www.openacc.org/sites/default/files/inline-files/OpenACC_Programming\_ Guide_0.pdf](https://www.openacc.org/sites/default/files/inline-files/OpenACC_Programming_Guide_0.pdf).

The leading book for OpenACC is

Sunita Chandrasekaran and Guido Juckeland, OpenACC for Programmers: Concepts and Strategies (Addison-Wesley Professional, 2017).

***OPENMP RESOURCES AND REFERENCES***

Most of the books and guides to OpenMP predate device offloading capabilities, but the language specification thoroughly describes the OpenMP device offloading directives. At over 600 pages, it is more of a reference than a user’s guide. Still, it is the go-to document for details on the features of the language.[2](#filepos1675272)

OpenMP Architecture Review Board, OpenMP Application Programming Interface, Vol. 5.0 (November, 2018) at [https://www.openmp.org/wp-content/uploads/Open MP-API-Specification-5.0.pdf](https://www.openmp.org/wp-content/uploads/OpenMP-API-Specification-5.0.pdf).

A companion to the specification is the example guide. This guide gives short examples of how each feature should work, but not complete application-level cases:

OpenMP Architecture Review Board, OpenMP Application Programming Interface: Examples, Vol. 5.0 (November, 2019) at [https://www.openmp.org/wp-content/uploads/ openmp-examples-5.0.0.pdf](https://www.openmp.org/wp-content/uploads/openmp-examples-5.0.0.pdf).

With OpenMP still seeing significant changes and compilers still working on implementing v5.0 features, it is not surprising that there are few books that discuss the device offloading features. Ruud van der Pas and others recently completed a book that covers the new features of OpenMP up through v4.5.

Ruud Van der Pas, Eric Stotzer, and Christian Terboven, Using OpenMP—The Next Step: Affinity, Accelerators, Tasking, and SIMD (MIT Press, 2017).

***11.4.2 Exercises***

1.  Find what compilers are available for your local GPU system. Are both OpenACC and OpenMP compilers available? If not, do you have access to any systems that would allow you to try out these pragma-based languages?

2.  Run the stream triad examples from the OpenACC/StreamTriad and/or the OpenMP/StreamTriad directories on your local GPU development system. You’ll find these directories at [https://github.com/EssentialsofParallelComputing/ Chapter11](https://github.com/EssentialsofParallelComputing/Chapter11).

3.  Compare your results from exercise 2 to the BabelStream results at [https:// uob-hpc.github.io/BabelStream/results/](https://uob-hpc.github.io/BabelStream/results/). For the stream triad, the bytes moved are `3 * nsize * sizeof(datatype)`.

4.  Modify the OpenMP data region mapping in listing 11.16 to reflect the actual use of the arrays in the kernels.

5.  Implement the mass sum example from listing 11.4 in OpenMP.

6.  For x and y arrays of size 20,000,000, find the maximum radius for the arrays using both OpenMP and OpenACC. Initialize the arrays with double-precision values that linearly increase from 1.0 to 2.0e7 for the x array and decrease from 2.0e7 to 1.0 for the y array.

***Summary***

- Pragma-based languages are the easiest way to port to the GPU. Using these gives you the quickest result with the least effort.

- The porting process is to move work to the GPU and then manage the data movement. This gets as much work as possible on the GPU while minimizing expensive data movement.

- The kernel optimization comes last and should mostly be left to the compiler. This produces the most portable and future-proof code.

- Track the latest developments of the pragma-based language and compilers. These compilers are still under rapid development and should continue improving.

------------------------------------------------------------------------

^(**1.**) One of the original OpenACC compilers, CAPS, went out of business in 2016 and is no longer available.

^(**2.**) To get a relative comparison for the complexity of these pragma-based languages, the final draft of the C18 standard for the C language is just over 500 pages.
