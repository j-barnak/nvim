# 10 GPU programming model

***10 GPU programming model***

This chapter covers

- Developing a general GPU programming model
- Understanding how it maps to different vendors’ hardware
- Learning what details of the programming model influence performance
- Mapping the programming model to different GPU programming languages

In this chapter, we will develop an abstract model of how work is performed on GPUs. This programming model fits a variety of GPU devices from different vendors and across the models from each vendor. It is also a simpler model than what occurs on the real hardware, capturing just the essential aspects required to develop an application. Fortunately, various GPUs have a lot of similarities in structure. This is a natural result of the demands of high-performance graphics applications.

The choice of data structures and algorithms has a long-range impact on the performance and ease of programming for the GPU. With a good mental model of the GPU, you can plan how data structures and algorithms map to the parallelism of the GPU. Especially for GPUs, our primary job as application developers is to expose as much parallelism as we can. With thousands of threads to harness, we need to fundamentally change the work so that there are a lot of small tasks to distribute across the threads. In a GPU language, as in any other parallel programming language, there are several components that must exist. These are a way to

- Express the computational loops in a parallel form for the GPU (see section 10.2)

- Move data between the host CPU and the GPU compute device (see section 10.2.4)

- Coordinate between threads that are needed for a reduction (see section 10.4)

Look for how these three components are accomplished in each GPU programming language. In some languages, you directly control some aspects, and in others, you rely on the compiler or template programming to implement the needed operations. While the operation of a GPU might seem mysterious, these operations are not all that different from what is necessary on a CPU for parallel code. We have to write loops that are safe for fine-grained parallelism, sometimes called `do concurrent` for Fortran or `forall` or `foreach` in C/C++. We have to think about data movement between nodes, processes, and the processor. We also have to have special mechanisms for reductions.

For native GPU computation languages like CUDA and OpenCL, the programming model is exposed as part of the language. These GPU languages are covered in chapter 12. In that chapter, you’ll explicitly manage many aspects of parallelization for the GPU in your program. But with our programming model, you will be better prepared to make important programming decisions for better performance and scaling across a wide range of GPU hardware.

If you are using a higher-level programming language, such as the pragma-based GPU languages covered in chapter 11, do you really need to understand all the details of the GPU programming model? Even with pragmas, it is still helpful to understand how the work gets distributed. When you use a pragma, you are trying to steer the compiler and library to do the right thing. In some ways, this is harder than writing the program directly.

The goal of this chapter is to help you develop your application design for the GPU. This is mostly independent of the programming language for the GPU. There are questions you should answer up front. How will you organize your work and what kind of performance can be expected? Or the more basic question of whether your application should even be ported to the GPU or would it be better off staying with the CPU? GPUs, with their promise of an order-of-magnitude performance gains and lower energy use, are a compelling platform. But these are not a panacea for every application and use case. Let’s dive into the details of the GPU’s programming model and see what it can do for you.

> > > **NOTE** We encourage you to follow along with the examples for this chapter at <https://github.com/EssentialsofParallelComputing/Chapter10>.

***10.1 GPU programming abstractions: A common framework***

The GPU programming abstractions are possible for a reason. The basic characteristics, which we explore in more detail in a bit, include the following. Then we’ll take a quick look at some basic terminology for GPU parallelism.

- Graphics operations have massive parallelism

- Operations cannot be coordinated among tasks

***10.1.1 Massive parallelism***

Abstractions are based on what is necessary for high-performance graphics with GPUs. GPU workflows have some special characteristics that help to drive the commonality in the GPU-processing techniques. For a high frame rate and high-quality graphics, there are lots of pixels, triangles, and polygons to process and display.

Because of the large amounts of data, GPUs have massive parallelism. The operations on the data are generally identical, so GPUs use similar techniques to apply a single instruction to multiple data items to gain another level of efficiency. Figure 10.1 shows the common programming abstractions across various vendors and GPU models. These can be summarized as three or four basic techniques.

**Figure 10.1 Our mental model for GPU parallelization contains the common programming abstractions across most GPU hardware.**

We start with the computational domain and iteratively break up the work with the following components. We’ll discuss each of these subdivisions of work in sections 10.1.4 through 10.1.8:

- Data decomposition

- Chunk-sized work for processing with some shared, local memory

- Operating on multiple data items with a single instruction

- Vectorization (on some GPUs)

One thing to note from these GPU parallel abstractions is that there are fundamentally three, or maybe four, different levels of parallelization that you can apply to a computational loop. In the original graphics use case, there is not much of a need to go beyond two or three dimensions and the corresponding number of parallelization levels. If your algorithm has more dimensions or levels, you must combine some computational loops to fully parallelize your problem.

***10.1.2 Inability to coordinate among tasks***

Graphics workloads do not require much coordination within the operations. But as we will see in later sections, there are algorithms such as reductions that require coordination. We will have to develop complicated schemes to handle these situations.

***10.1.3 Terminology for GPU parallelism***

The terminology for components of the GPU parallelism varies across vendors, adding a degree of confusion when reading programming documentation or articles. To help with cross-referencing the use of various terms, we summarize the official terms from each vendor in table 10.1.

**Table 10.1 Programming abstractions and associated terminology for GPUs**

| **OpenCL**                    | **CUDA**              | **HIP** | **AMD GPU (HC compiler)** | **C++ AMP** | **CPU**                                               |
|-------------------------------|-----------------------|---------|---------------------------|-------------|-------------------------------------------------------|
| NDRange (N-dimensional range) | grid                  | grid    | extent                    | extent      | Standard loop bounds or index sets with loop blocking |
| Work Group                    | block or thread block | block   | tile                      | tile        | loop block                                            |
| Subgroup or Wavefront         | warp                  | warp    | wavefront                 | N/A         | SIMD length                                           |
| Work Item                     | thread                | thread  | thread                    | thread      | thread                                                |

OpenCL is the open standard for GPU programming, so we use it as the base terminology. OpenCL runs on all of the GPU hardware and many other devices such as CPUs and even more exotic hardware such as field-programmable gate arrays (FPGAs) and other embedded devices. CUDA, the NVIDIA proprietary language for their GPUs, is the most widely used language for GPU computation and, thus, used in a great fraction of the documentation on programming GPUs. HIP (Heterogeneous-Computing Interface for Portability) is a portable derivative of CUDA developed by AMD for their GPUs. It uses similar terminology as CUDA. The native AMD Heterogeneous Compute (HC) Compiler and the C++ AMP language from Microsoft use a lot of the same terms. (C++ AMP is in maintenance mode and not under active development as of this writing.) When trying to get portable performance, it’s also important to consider the corresponding features and terms for the CPU as shown in the last column in table 10.1.

***10.1.4 Data decomposition into independent units of work: An NDRange or grid***

The technique of data decomposition is at the heart of how GPUs obtain performance. GPUs break up the problem into many smaller blocks of data. Then they break it up again, and again.

GPUs must draw a lot of triangles and polygons to generate high frame rates. These operations are completely independent from each other. For this reason, the top-level data decomposition for computational work on a GPU also generates independent and asynchronous work.

With lots of work to do, GPUs hide latency (stalls for memory loads) by switching to another work group that is ready to compute. Figure 10.2 shows a case where only four subgroups (warps or wavefronts) can be scheduled due to resource limitations. When the subgroups hit a memory read and stall, execution switches to other subgroups. The execution switch, also called a context switch, is hiding latency with computation rather than with a deep cache hierarchy. If you only have a single instruction stream on a single piece of data, a GPU will be slow because it has no way to hide the latency. But if you have lots of data to operate on, it’s incredibly fast.

**Figure 10.2 The GPU subgroup (warp) scheduler switches to other subgroups to cover memory reads and instruction stalls. Multiple work groups allow work to be done even when a work group is being synchronized.**

Table 10.2 shows the device limitations for the current NVIDIA and AMD schedulers. For these devices, we want a high number of candidate work groups and subgroups to keep the processing elements busy.

**Table 10.2 GPU subgroup (warp or wavefront) scheduler limitations**

| ** **                                             | **NVIDIA Volta and Ampere** | **AMD MI50** |
|---------------------------------------------------|-----------------------------|--------------|
| Active number of subgroups per compute unit       | 64                          | 40           |
| Active number of work groups per compute unit     | 32                          | 40           |
| Selected subgroups for execution per compute unit | 4                           | 4            |
| Subgroup (warp or wavefront) size                 | 32                          | 64           |

Data movement and, in particular, moving data up and down the cache hierarchy, is a substantial part of the energy cost for a processor. Therefore, the reduction in the need for a deep cache hierarchy has some significant benefits. There is a large reduction in the energy usage. Also, a lot of precious silicon space is freed on the processor. This space can then be filled with more arithmetic logic units (ALUs).

We show the data decomposition operation in figure 10.3, where a 2D computational domain is split into smaller 2D blocks of data. In OpenCL, this is called an NDRange, short for N-dimensional range (the CUDA term, a grid, is a little more palatable). The NDRange in this case is a 3×3 set of tiles of size 8×8. The data decomposition process breaks up the global computational domain, G_(y) by G_(x), into smaller blocks or tiles of size T_(y) by T_(x).

**Figure 10.3 Breaking up the computational domain into small, independent work units**

Let’s work through an example to see what this step accomplishes.

> **Example: Data decomposition of a 1024×1024 2D computational domain**

> If we set a tile size of 16x8, the data decomposition will be as follows:

> NT_(x) = G_(x)/T_(x) = 1024/16 = 64

> NT_(y) = G_(y)/T_(y) = 1024/8 = 128

> NT = 64 × 128 = 8,192 tiles

> This first level of the data decomposition begins to break up the dataset into a large number of smaller blocks or tiles. The GPUs make some assumptions of the

> characteristics of the work groups created by this data decomposition. These assumptions are that the work groups

- Are completely independent and asynchronous

- Have access to global and constant memory

> Each work group that is created is an independent unit of work. This means that each of these work groups can be operated on in any order, providing a level of parallelism to spread out across the many compute units on a GPU. These are the same properties that we attributed to fine-grained parallelism in section 7.3.6. The same changes to loops for independent iterations for OpenMP and vectorization also enable GPU parallelism.

Table 10.3 shows examples of how this data decomposition might occur for 1D-, 2D-, and 3D-computational domains. The fastest changing tile dimension, T_(x), should be a multiple of the cache line length, memory bus width, or subgroup (wavefront or warp) size for best performance. The number of tiles, NT, overall and in each dimension, results in a lot of work groups (tiles) to distribute across the GPU compute engines and processing elements.

**Table 10.3 Data decomposition of the computational domain into tiles or blocks**

| ** **                      | **1D**    | **Small 2D** | **Large 2D** | **3D**          |
|----------------------------|-----------|--------------|--------------|-----------------|
| Global size                | 1,048,576 | 1024 × 1024  | 1024 × 1024  | 128 × 128 × 128 |
| T_(z) × T_(y) × T_(x)      | 128       | 8 × 8        | 8 × 16       | 4 × 4 × 8       |
| Tile size                  | 128       | 64           | 128          | 128             |
| NT_(z) × NT_(y) × NT_(x)   | 8,192     | 128 × 128    | 128 × 64     | 32 × 32 × 16    |
| NT (number of work groups) | 8,192     | 16,384       | 8,192        | 16,384          |

For algorithms that need neighbor information, the optimum tile size for memory accesses needs to be balanced against getting the minimum surface area for the tile (figure 10.4). Neighbor data must be loaded more than once for adjacent tiles, which makes this an important consideration.

**Figure 10.4 Each work group needs to load neighbor data from the dashed rectangle, resulting in duplicate loads in the shaded regions where more duplicate loads will be needed for the case on the left. This must be balanced against optimum contiguous data loads in the x-direction.**

***10.1.5 Work groups provide a right-sized chunk of work***

The work group spreads out the work across the threads on a compute unit. Each GPU model has a maximum size specified for the hardware. OpenCL reports this as `CL_DEVICE_MAX_WORK_GROUP_SIZE` in its device query. PGI reports it as `Maximum Threads per Block` in the output from its `pgaccelinfo` command (see figure 11.3). The maximum size for a work group is usually between 256 and 1,024. This is just the maximum. For computation, work group sizes are typically much smaller, so that there are more memory resources per work item or thread.

The work group is subdivided into subgroups or warps (figure 10.5). A subgroup is the set of threads that execute in lockstep. For NVIDIA, the warp size is 32 threads. For AMD it is called a wavefront, and the size is usually 64 work items. The work group size must be a multiple of the subgroup size.

**Figure 10.5 A multi-dimensional work group is linearized onto a 1D strip where it is broken up into subgroups of 32 or 64 work items. For performance reasons, work groups should be multiples of the subgroup size.**

The typical characteristics of work groups on GPUs are that they

- Cycle through processing each subgroup

- Have local memory (shared memory) and other resources shared within the group

- Can synchronize within a work group or a subgroup

Local memory provides fast access and can be used as a sort of programmable cache or scratchpad memory. If the same data is needed by more than one thread in a work group, performance can generally be improved by loading it into the local memory at the start of the kernel.

***10.1.6 Subgroups, warps, or wavefronts execute in lockstep***

To further optimize the graphics operations, GPUs recognize that the same operations can be performed on many data elements. GPUs are therefore optimized by working on sets of data with a single instruction rather than with separate instructions for each. This reduces the number of instructions that need to be handled. This technique on the CPU is called single instruction, multiple data (SIMD). All GPUs emulate this with a group of threads where it is called single instruction, multi-thread (SIMT). See section 1.4 for the original discussion of SIMD and SIMT.

Because SIMT simulates SIMD operations, it is not necessarily constrained the same way as are SIMD operations by the underlying vector hardware. Current SIMT operations are executed in lockstep, with every thread in the subgroup executing all paths through branching if any one thread must go through a branch (figure 10.6). This is similar to how a SIMD operation is done with a mask. But because the SIMT operation is emulated, this could be relaxed with more flexibility in the instruction pipeline, where more than one instruction could be supported.

**Figure 10.6 The shaded rectangles show the executed statements by threads and lanes. SIMD and SIMT operations execute all the statements in lockstep with masks for those that are false. Large blocks of conditionals can cause branch divergence problems for GPUs.**

Small sections of conditionals for GPUs do not have a significant impact on overall performance. But if some threads take thousands of cycles longer than others, there’s a serious issue. If threads are grouped such that all the long branches are in the same subgroup (wavefront), there will be little or no thread divergence.

***10.1.7 Work item: The basic unit of operation***

The basic unit of operation is called a work item in OpenCL. This work item can be mapped to a thread or to a processing core, depending on the hardware implementation. In CUDA, it is simply called a thread because that is how it is mapped in NVIDIA GPUs. Calling it a thread is mixing the programming model with how it is implemented in the hardware, but it is a little clearer to the programmer.

A work item can invoke another level of parallelism on GPUs with vector hardware units as figure 10.7 shows. This model of operation also maps to the CPU where a thread can execute a vector operation.

**Figure 10.7 Each work item on an AMD or Intel GPU may be able to do a SIMD or Vector operation. This maps well over to the vector unit on a CPU as well.**

***10.1.8 SIMD or vector hardware***

Some GPUs also have vector hardware units and can do SIMD (vector) operations in addition to SIMT operations. In the graphics world, the vector units process spatial or color models. The use in scientific computation is more complicated and not necessarily portable between GPU hardware. The vector operation is done per work item, increasing the resource utilization for the kernel. But often there are additional vector registers to compensate for the additional work. Effective utilization of the vector units can provide a significant boost to performance when done well.

Vector operations are exposed in the OpenCL language and AMD languages. Because the CUDA hardware does not have vector units, the same level of support is not present in CUDA languages. Still, OpenCL code with vector operations will run on CUDA hardware, so it can be emulated in the CUDA hardware.

***10.2 The code structure for the GPU programming model***

Now we can begin to look at the code structure for the GPU that incorporates the programming model. For convenience and generality, we call the CPU the host and we use the term device to refer to the GPU.

The GPU programming model splits the loop body from the array range or index set that is applied to the function. The loop body creates the GPU kernel. The index set and arguments will be used on the host to make the kernel call. Figure 10.8 shows the transformation from a standard loop to the body of the GPU kernel. This example uses OpenCL syntax. But the CUDA kernel is similar, replacing the `get_global_id` call with

> `gid = blockIdx.x *blockDim.x + threadIdx.x`

**Figure 10.8 Correspondence between standard loop and the GPU kernel code structure**

In the next four sections, we look separately at how the loop body becomes the parallel kernel and how to tie it back to the index set on the host. Let’s break this down into four steps:

1.  Extract the parallel kernel

2.  Map from the local data tile to global data

3.  Calculate data decomposition on the host into blocks of data

4.  Allocate any required memory

***10.2.1 “Me” programming: The concept of a parallel kernel***

GPU programming is the perfect language for the “Me” generation. In the kernel, everything is relative to yourself. Take for example

> `c[i] = a[i] + scalar*b[i];`

In this expression, there is no information about the extent of the loop. This could be a loop where `i`, the global `i` index, covers a range from 0 to 1,000 or just the single value 22. Each data item knows what needs to be done to itself and itself only. This is truly a “Me” programming model, where I care only about myself. What is so powerful about this is that the operations on each data element become completely independent. Let’s look at the more complicated example of the stencil operator. Although we have two indices, both `i` and `j`, and some of the references are to adjacent data values, this line of code is still fully defined once we determine the values of `i` and `j`.

> `xnew[j][i] = (x[j][i] + x[j][i-1] + x[j][i+1] + x[j-1][i] + x[j+1][i])/5.0;`

The separation of the loop body and the index set can be done in C++ with either functors or lambda expressions. In C++, lambda expressions have been around since the C++ 11 standard. Lambdas are used as a way for compilers to provide portability for single-source code to either CPUs or GPUs. Listing 10.1 shows the C++ lambda.

> > > **DEFINITION** Lambda expressions are unnamed, local functions that can be assigned to a variable and used locally or passed to a routine.

**Listing 10.1 C++ lambda for the stream triad**

> `lambda.cc`  
> `1 int main() {`  
> `2     const int N = 100;`  
> `3     double a[N], b[N], c[N];`  
> `4     double scalar = 0.5;`  
> `5`  
> `6     // c, a, and b are all valid scope pointers on the device or host`  
> `7`  
> `8     // We assign the loop body to the example_lambda variable`  
> `9     auto example_lambda = [&] (int i) {                       `❶  
> `10         c[i] = a[i] + scalar * b[i];                          `❷  
> `11     };`  
> `12`  
> `13     for (int i = 0; i < N; i++)                               `❸  
> `14     {`  
> `15         example_lambda(i);                                    `❹  
> `16     }`  
> `17 }`

❶ Lambda variable

❷ Lambda body

❸ Arguments or index set for lambda

❹ Invokes lambda

The lambda expression is composed of four main components:

- Lambda body—The function to be executed by the call. In this case, the body is

> `c[i] = a[i] + scalar * b[i];.`

- Arguments—The argument `(int i)` used in the later call to the lambda expression.

- Capture closure—The list of variables in the function body that are defined externally and how these are passed to the routine, specified by `[&]` in listing 10.1. The `&` indicates that the variable is referred to by reference and an `=` sign says to copy it by value. A single `&` sets the default to variables by reference. We can more fully specify the variables with the capture specification of `[&c`, `&a`, `&b`, `&scalar]`.

- Invocation—The `for` loop in lines 13 to 16 in listing 10.1 invokes the lambda over the specified array values.

Lambda expressions form the basis for more naturally generating code for GPUs in emerging C++ languages like SYCL, Kokkos, and Raja. We will briefly cover SYCL in chapter 12 as a higher-level C++ language (originally built on top of OpenCL). Kokkos from Sandia National Laboratories (SNL) and Raja, originating at Lawrence Livermore National Laboratory (LLNL), are two higher-level languages developed to simplify the writing of portable scientific applications for the broad array of today’s computing hardware. We’ll introduce Kokkos and Raja in chapter 12 as well.

***10.2.2 Thread indices: Mapping the local tile to the global world***

The key to how the kernel can compose its local operation is that, as a product of the data decomposition, we provide each work group with some information about where it is in the local and global domains. In OpenCL, you can get the following information:

- Dimension—Gets the number of dimensions, either 1D, 2D, or 3D, for this kernel from the kernel invocation

- Global information—Global index in each dimension, which corresponds to a local work unit, or the global size in each dimension, which is the size of the global computational domain in each dimension

- Local (tile) information—The local size in each dimension, which corresponds to the tile size in this dimension, or the local index in each dimension, which corresponds to the tile index in this dimension

- Group information—The number of groups in each dimension, which corresponds to the number of groups in this dimension, or the group index in each dimension, which corresponds to the group index in this dimension

Similar information is available in CUDA, but the global index must be calculated from the local thread index plus the block (tile) information:

> `gid = blockIdx.x *blockDim.x + threadIdx.x; `

Figure 10.9 presents the indexing for the work group (block or tile) for OpenCL and CUDA. The function call for OpenCL is first, followed by the variable defined by CUDA. All of this indexing support is automatically done for you by the data decomposition for the GPU, greatly simplifying the handling of the mapping from the global space to the tile.

**Figure 10.9 Mapping of the index of individual work item to global index space. The OpenCL call is given first, followed by the variable defined in CUDA.**

***10.2.3 Index sets***

The size of the indices for each work group should be identical. This is done by padding the global computational domain out to a multiple of the local work group size. We can do this with some integer arithmetic to get one extra work group and a padded global work size. The following example shows an approach using basic integer operations and then a second with the C `ceil` intrinsic function.

> `global_work_sizex = ((global_sizex + local_work_sizex - 1)/`  
> `                      local_work_sizex) * local_work_sizex`

> **Example: Calculating work group sizes**

> This code uses the arguments for the kernel invocation to get uniform work group sizes.

> `int global_sizex = 1000;`  
> `int local_work_sizex = 128;`  
> `int global_work_sizex = ((global_sizex + local_work_sizex - 1)/`  
> `                          local_work_sizex) * local_work_sizex = 1024;`  
> `int number_work_groupsx = (global_sizex + local_work_sizex - 1)/`  
> `                           local_work_sizex = 8`  
> `// or, alternatively`  
> `int global_work_sizex = ceil(global_sizex/local_work_sizex) *`  
> `                             local_work_sizex = 1024;`  
> `int number_work_groupsx = ceil(global_sizex/local_work_sizex) = 8;`

> To avoid reading past the end of the array, we should test the global index in each kernel and skip the read if it is past the end of the array with something like

> `if (gidx > global_sizex) return;`

> > > **NOTE** Avoiding out-of-bound reads and writes is important in GPU kernels because they lead to random kernel crashes with no error message or output.

***10.2.4 How to address memory resources in your GPU programming model***

Memory is still the most important concern impacting your application programming plan. Fortunately, there is a lot of memory on today’s GPUs. Both the NVIDIA V100 and AMD Radeon Instinct MI50 GPUs support 32 GB of RAM. Compared to well-provisioned HPC CPU nodes with 128 GB of memory, a GPU compute node with 4-6 GPUs has the same memory. There is as much memory on GPU compute nodes as on CPUs. Therefore, we can use the same memory allocation strategy as we have for the CPU and not have to transfer data back and forth due to limited GPU memory.

Memory allocation for the GPU has to be done on the CPU. Often, memory is allocated for both the CPU and the GPU at the same time and then data is transferred between them. But if possible, you should allocate memory only for the GPU. This avoids expensive memory transfers back and forth from the CPU and frees up memory on the CPU. Algorithms that use a dynamic memory allocation present a problem for the GPU and need to be converted to a static memory algorithm, with the memory size known ahead of time. The latest GPUs do a good job of coalescing irregular or shuffled memory accesses into single, coherent cache-line loads when possible.

> > > **DEFINITION** Coalesced memory loads are the combination of separate memory loads from groups of threads into a single cache-line load.

On the GPU, the memory coalescing is done at the hardware level in the memory controller. The performance gains from these coalesced loads are substantial. But also important is that a lot of the optimizations from earlier GPU programming guides are no longer necessary, significantly reducing the GPU programming effort.

You can get some additional speedup from using local (shared) memory for data that is used more than once. This optimization used to be important for performance, but the better cache on GPUs is making the speedup less significant. There are a couple of strategies on how to use the local memory, depending on whether you can predict the size of the local memory required. Figure 10.10 shows the regular grid approach on the left and the irregular grid for unstructured and adaptive mesh refinement on the right. The regular grid has four abutting tiles with overlapping halo regions. The adaptive mesh refinement shows only four cells; a typical GPU application would load 128 or 256 cells and then bring in the required neighbor cells around the periphery.

**Figure 10.10 For stencils on regular grids, load all the data into local memory and then use local memory for the computation. The inner solid rectangle is the computational tile. The outer dashed rectangle encloses the neighboring data needed for the calculation. You can use cooperative loads to load the data in the outer rectangle into the local memory for each work group. Because irregular grids have an unpredictable size, load only the computed region into local memory and use registers for each thread for the rest.**

The processes for the two cases are

- Threads need the same memory loads as adjacent threads. A good example of this is the stencil operation we use throughout the book. Thread `i` needs the `i-1` and `i+1` values, which means that multiple threads will need the same values. The best approach for this situation is to do cooperative memory loads. Copying the memory values from global memory to local (shared) memory results in a significant speedup.

- An irregular mesh has an unpredictable number of neighbors, making it difficult to load into local memory. One way to handle this is to copy the part of the mesh to be computed into local memory. Then load the neighbor data into registers for each thread.

These are not the only ways to utilize the memory resources on the GPU. It is important to think through the issues with regard to the limited resources and the potential performance benefits for your particular application.

***10.3 Optimizing GPU resource usage***

The key to good GPU programming is to manage the limited resources available for executing kernels. Let’s look at a few of the more important resource limitations in table 10.4. Exceeding the available resources can lead to significant decreases in performance. The NVIDIA compute capability 7.0 is for the V100 chip. The newer Ampere A100 chip uses a compute capability of 8.0 with nearly identical resource limits.

**Table 10.4 Some resource limitations on current GPUs**

| **Resource limit**                   | **NVIDIA compute capability 7.0** | **AMD Vega 20 (MI50)** |
|--------------------------------------|-----------------------------------|------------------------|
| Maximum threads per work group       | 1024                              | 256                    |
| Maximum threads per compute unit     | 2048                              |                        |
| Maximum work groups per compute unit | 32                                | 16                     |
| Local memory per compute unit        | 96 KB                             | 64 KB                  |
| Register file size per compute unit  | 64K                               | 256 KB vector          |
| Maximum 32-bit registers per thread  | 255                               |                        |

The most important control available to the GPU programmer is the work group size. At first, it would seem that using the maximum number of threads per work group would be desirable. But for computational kernels, the complexity of computational kernels in comparison to graphics kernels means that there are a lot of demands on compute resources. This is known colloquially as memory pressure or register pressure. Reducing the work group size gives each work group more resources to work with. It also gives more work groups for context switching, which we discussed in section 10.1.1. The key to getting good GPU performance is finding the right balance of work group size and resources.

> > > **DEFINITION** Memory pressure is the effect of the computational kernel resource needs on the performance of GPU kernels. Register pressure is a similar term, referring to demands on registers in the kernel.

A full analysis of the resource requirements of a particular kernel and the resources available on the GPU requires an involved analysis. We’ll give examples of a couple of these types of deep dives. In the next two sections, we look at

- How many registers a kernel uses

- How busy the multi-processors are kept, which is called occupancy

***10.3.1 How many registers does my kernel use?***

You can find out how many registers your code uses by adding the `-Xptxas="-v"` flag to the `nvcc` compile command. In OpenCL for NVIDIA GPUs, use the `-cl-nv-verbose` flag for the OpenCL compile line to get a similar output.

> **Example: Getting the register usage for your kernel on an NVIDIA GPU**

> First, we build BabelStream with the extra compiler flags:

> `git clone git@github.com:UoB-HPC/BabelStream.git`  
> `cd BabelStream`  
> `export EXTRA_FLAGS='-Xptxas="-v"'`  
> `make -f CUDA.make`

> The output from the NVIDIA compiler shows the register usage for the stream triad:

> `ptxas info    : Used 14 registers, 4096 bytes smem, 380 bytes cmem[0]`  
> `ptxas info    : Compiling entry function '_Z12triad_kernelIfEvPT_PKS0_S3_'`  
> `                for 'sm_70'    `  
> `ptxas info    : Function properties for _Z12triad_kernelIfEvPT_PKS0_S3_`  
> `    0 bytes stack frame, 0 bytes spill stores, 0 bytes spill loads`

> In this simple kernel, we use 14 registers out of the 255 available on the NVIDIA GPU.

***10.3.2 Occupancy: Making more work available for work group scheduling***

We have discussed the importance of latency and context switching for good performance on the GPU. The benefit in “right-sized” work groups is that more work groups can be in flight at one time. For the GPU, this is important because when progress on a work group stalls due to memory latency, it needs to have other work groups that it can execute to hide the latency. To set the proper work group size, we need a measure of some sort. On GPUs, the measure used for analyzing work groups is called occupancy. Occupancy is a measure of how busy the compute units are during the calculation. The measure is complicated because it is dependent on a lot of factors, such as the memory required and the registers used. The precise definition is

Occupancy = Number of Active Threads/Maximum Number of Threads Per Compute Unit

Because the number of threads per subgroup is fixed, an equivalent definition is based on subgroups, also known as wavefronts or warps:

Occupancy = Number of Active Subgroups/Maximum Number of Subgroups Per Compute Unit

The number of active subgroups or threads is determined by the work group or thread resource that is exhausted first. Often this is the number of registers or local memory that is needed by a work group, preventing another work group from starting. We need a tool such as the CUDA Occupancy Calculator (presented in the following example) to do this well. NVIDIA programming guides focus a lot of attention on maximizing occupancy. While important, there just need to be enough work groups to switch between to hide latency and stalls.

> **Example: CUDA Occupancy Calculator**

1.  Download CUDA Occupancy Calculator spreadsheet from

    > <https://docs.nvidia.com/cuda/cuda-occupancy-calculator/index.html>

2.  Enter the register count output from NVCC compiler (section 10.3.1) and work group size (1,024).

> The following figure shows the results for the Occupancy Calculator. There are also plots on the spreadsheet for varying block size, register count, and local memory usage (not shown).

>   

> **Output from CUDA Occupancy Calculator for the stream triad showing the resource usage for the kernel. The third block from the top shows the occupancy measures.**

***10.4 Reduction pattern requires synchronization across work groups***

Up to now, the computational loops we have looked at over cells, particles, points, and other computational elements could be handled by the approach in figure 10.8, where the `for` loops are stripped from the computational body to create a GPU kernel. Making this transformation is quick and easy and can be applied to the vast majority of loops in a scientific application. But there are other situations where the code conversion to the GPU is exceedingly difficult. We’ll look at algorithms that require a more sophisticated approach. Take for example, the single line of Fortran code using array syntax:

> `xmax = sum(x(:))`

It looks so simple in Fortran, but it’s far more complicated on the GPU. The source of the difficulty is that we cannot do cooperative work or comparisons across work groups. The only way to accomplish this is to exit the kernel. Figure 10.11 illustrates the general strategy that deals with this situation.

**Figure 10.11 The reduction pattern on the GPU requires two kernels to synchronize multiple work groups. We exit the first kernel, represented by the rectangle, and then start another one the size of a single work group to allow thread cooperation for the final pass.**

For ease of illustration, figure 10.11 shows an array 32 elements long. The typical array for this method would be hundreds of thousands or even millions of elements long so that it is much larger than the size of a work group. In the first step, we find the sum of each work group and store it in a scratch array the length of the number of work groups or blocks. The first pass reduces the size of the array by the size of our work group, which could be 512 or 1,024. At this point, we cannot communicate between work groups, so we exit the kernel and start a new kernel with just one work group. The remaining data might be greater than the work group size of 512 or 1,024, so we loop through the scratch array, summing up the values into each work item. We can communicate between the work items in the work group, so we can do a reduction to a single global value, summing along the way.

Complicated! The code to perform this operation on the GPU takes dozens of lines of code and two kernels to do the same operation that we can do in one line for the CPU. We’ll see more of the actual code for a reduction in chapter 12 when we cover CUDA and OpenCL programming. The performance that is obtained on the GPU is faster than the CPU, but it takes a lot of programming work. And we’ll start to see that one of the characteristics of GPUs is that synchronization and comparisons are hard to do.

***10.5 Asynchronous computing through queues (streams)***

We are going to see how we can more fully utilize a GPU by overlapping data transfer and computation. Two data transfers can occur at the same time as a computation on a GPU.

The basic nature of work on GPUs is asynchronous. Work is queued up on the GPU and, usually, only gets executed when a result or synchronization is requested. Figure 10.12 shows a typical set of commands sent to a GPU for a computation.

**Figure 10.12 Work scheduled on a GPU in the default queue only gets completed when the wait for completion is requested. We scheduled the copy of a graphical image (a picture) to be copied to the GPU. Then we scheduled a mathematical operation on the data to modify it. We also scheduled a third operation to bring it back. None of these operations has to start until we demand the wait for completion.**

We can also schedule work in multiple queues that are independent and asynchronous. The use of multiple queues as illustrated in figure 10.13 exposes the potential for overlapping data transfer and computation. Most of the GPU languages support some form of asynchronous work queues. In OpenCL the commands are queued, and in CUDA, the operations are placed in streams. While the potential for parallelism is created, whether it actually happens is dependent on the hardware capabilities and coding details.

**Figure 10.13 Staging work for three images in parallel queues**

If we have a GPU capable of simultaneously performing these operations,

- Copying data from host to device

- Kernel computation(s)

- Copying data from device to host

then the work that is set up in three separate queues in figure 10.13 can overlap computation and communication as figure 10.14 shows.

**Figure 10.14 Overlapping computation and data transfers reduce the time for three images from 75 ms to 45 ms. This is possible because the GPU can do a computation, a data transfer from the host to the device, and another one from the device to the host simultaneously.**

***10.6 Developing a plan to parallelize an application for GPUs***

Now we’ll move on to using our understanding of the GPU programming model to develop a strategy for parallelization of our application. We’ll use a couple of application examples to demonstrate the process.

***10.6.1 Case 1: 3D atmospheric simulation***

Your application is an atmospheric simulation ranging from 1024x1024x1024 to 8192x8192x8192 in size with x as the vertical dimension, y as the horizontal, and z as the depth. Let’s look at the options you might consider:

- Option 1: Distribute data in a 1D fashion across the z-dimension (depth).

> > > For GPUs, we need tens of thousands of work groups for effective parallelism. From the GPU specification (table 9.3), we have 60-80 compute units of 32 double-precision arithmetic units for about 2,000 simultaneous arithmetic pathways. In addition, we need more work groups for latency hiding via context switching. Distributing data across the z-dimension gets us 1,024 to 8,192 work groups, which is low for a GPU parallelism.

> > > Let’s look at the resources needed for each work group. The minimum dimensions would be a 1024x1024 plane, plus any required neighbor data in ghost cells. We’ll assume one ghost cell in both directions. We would therefore need 1024 × 1024 × 3 × 8 bytes or 24 MiB of local data. Looking at table 10.4, GPUs have 64-96 KiB of local data, so we would not be able to preload data into local memory for faster processing.

- Option 2: Distribute data in 2D vertical columns across y- and z-dimensions.

> > > Distributing across two dimensions would give us over a million potential work groups, so we would have enough independent work groups for the GPU. For each work group, we would have 1,024 to 8,192 cells. We have our own cell plus 4 neighbors for 1024 × 5 × 8 = 40 KiB minimum of required local memory. For larger problems and with more than one variable per cell, we would not have enough local memory.

- Option 3: Distribute data in 3D cubes across x-, y-, and z-dimensions.

> > > Using the template from table 10.3, for each work group, let’s try using a 4x4x8 cell tile. With neighbors, this is 6 × 6 × 10 × 8 bytes for 2.8 KiB minimum of required local memory. We could have more variables per cell and can experiment with making the tile size a little larger.

> > > Total memory requirements for the 1024x1024x1024 cell tile × 8 bytes is 8 GiB. This is a large problem. GPUs have as much as 32 GiB of RAM, so the problem would possibly fit on one GPU. Larger size problems would require potentially up to 512 GPUs. So we should plan for distributed memory parallelism using MPI as well.

Let’s compare this to the CPU where these design decisions would have different outcomes. We might have work to spread across 44 processes, each with fewer resource restrictions. While the 3D approach could work, the 1D and 2D will also be feasible. Now let’s contrast that to an unstructured mesh where the data is all contained in 1D arrays.

***10.6.2 Case 2: Unstructured mesh application***

In this case, your application is a 3D unstructured mesh using tetrahedral or polygonal cells that range from 1 to 10 million cells. But the data is a 1D list of polygons with data such as x, y, and z that contains the spatial location. In this case, there’s only one option: 1D data distribution.

Because the data is unstructured and contained in 1D arrays, the choices are simpler. We distribute the data in 1D with a tile size of 128. This gives us from 8,000 to 80,000 work groups, providing plenty of work for the GPU to switch between and hide latency. The memory requirements are 128 × 8 byte double-precision value = 1 KB, allowing space for multiple data values per cell.

We will also need space for some integer mapping and neighbor arrays to provide the connectivity between the cells. Neighbor data is loaded into registers for each thread so that we don’t have to worry about the impact on local memory and possibly blowing past the memory limit. The largest size mesh at 10 million cells requires 80 MB, plus space for face, neighbor, and mapping arrays. These connectivity arrays can increase the memory usage significantly, but there should be plenty of memory on a single GPU to run computations on even the largest size meshes.

For best results, we will need to provide some locality for the unstructured data by using a data-partitioning library or by using a space-filling curve that keeps cells close to each other in the array that are close to each other spatially.

***10.7 Further explorations***

While the basic contours of the GPU programming model have stabilized, there are still a lot of changes occurring. In particular, the resources available for the kernels have slowly increased as the target uses broaden from 2D to 3D graphics and physics simulations for more realistic games. Markets such as scientific computing and machine learning are also becoming more important. For both these markets, custom GPU hardware has been developed: double precision for scientific computing and tensor cores for machine learning.

In our presentation, we’ve mostly discussed discrete GPUs. But there are also integrated GPUs as first discussed in section 9.1.1. The Accelerated Processing Unit (APU) is an AMD product offering. Both AMD’s APU and Intel’s integrated GPUs offer some advantages in reducing the memory transfer costs because these are no longer on the PCI bus. This is offset by the reduction in the silicon area for GPU transistors and a lower power envelope. Still, this capability has been underappreciated since it appeared. The primary development focus has been on the big discrete GPUs that are in the top-end HPC systems. But the same GPU programming languages and tools work equally as well with integrated GPUs. The critical limitation on developing new, accelerated applications is the widespread knowledge on how to program and exploit these devices.

Other mass-market devices such as Android tablets and cell phones have programmable GPUs with the OpenCL language. Some resources for these include

- Download OpenCL-Z and OpenCL-X benchmark applications from Google Play to see if your device supports OpenCL. Drivers may also be available from hardware vendors.

- Compubench (<https://compubench.com>) has performance results for some mobile devices that use OpenCL or CUDA.

- Intel has a nice site on programming with OpenCL for Android at [https://soft ware.intel.com/en-us/android/articles/opencl-basic-sample-for-android-os](https://software.intel.com/en-us/android/articles/opencl-basic-sample-for-android-os).

In recent years, GPU hardware and software have added support for other types of programming models, such as task-based approaches (see figure 1.25) and graph algorithms. These alternative programming models have long been an interest in parallel programming, but have struggled with efficiency and scale. There are critical applications, such as sparse matrix solvers, that cannot easily be implemented without further advances in these areas. But the fundamental question is whether enough parallelism can be exposed (revealed to the hardware) to utilize the massive parallel architecture of the GPUs. Only time will tell.

***10.7.1 Additional reading***

NVIDIA has long supported research into GPU programming. The CUDA C programming and best practices guides (available at <https://docs.nvidia.com/cuda>) are worth reading. Other resources include

- The GPU Gems series (<https://developer.nvidia.com/gpugems>) is an older set of papers that still contains a lot of relevant materials.

- AMD also has a lot of GPU programming materials at their GPUOpen site at

> > > <https://gpuopen.com/compute-product/rocm/>

> > > and at the ROCm site

> > > <https://rocm.github.io/documentation.html>

- AMD provides one of the better tables comparing terminology of different GPU programming languages available at <https://rocm.github.io/languages.html>.

Despite having about 65% of the GPU market (mostly integrated GPUs), Intel® is just beginning to be a serious player in GPU computation. They have announced a new discrete graphics board and will be the GPU vendor for the Aurora system at Argonne National Laboratory (to be delivered in 2022). The Aurora system is the first exascale system ever produced and has 6x the performance of the current top system in the world. The GPU is based on the Intel® Iris® Xe architecture, code named “Ponte Vecchio.” With much fanfare, Intel has released its oneAPI programming initiative. The oneAPI toolkit comes with the Intel GPU driver, compilers, and tools. Go to [https:// software.intel.com/oneapi](https://software.intel.com/oneapi) for more information and downloads.

***10.7.2 Exercises***

1.  You have an image classification application that will take 5 ms to transfer each file to the GPU, 5 ms to process, and 5 ms to bring back. On the CPU, the processing takes 100 ms per image. There are one million images to process. You have 16 processing cores on the CPU. Would a GPU system do the work faster?

2.  The transfer time for the GPU in problem 1 is based on a third generation PCI bus. If you can get a Gen4 PCI bus, how does that change the design? A Gen5 PCI bus? For image classification, you shouldn’t need to bring back a modified image. How does that change the calculation?

3.  For your discrete GPU (or NVIDIA GeForce GTX 1060, if none), what size 3D application could you run? Assume 4 double-precision variables per cell and a usage limit of half the GPU memory so you have room for temporary arrays. How does this change if you use single precision?

***Summary***

- Parallelism on the GPU needs to be in the thousands of independent work items because there are thousands of independent arithmetic units. The CPU only needs parallelism in the tens of independent work items to distribute work across the processing cores. Thus, for the GPU, it is important to expose more parallelism in our applications to keep the processing units busy.

- Different GPU vendors have similar programming models driven by the needs of high-frame-rate graphics. Because of this, a general approach can be developed that is applicable across many different GPUs.

- The GPU programming model is particularly well suited for data parallelism with large sets of computational data but can be difficult for some tasks with a lot of coordination, such as reductions. The result is that many highly parallel loops port easily, but there are some that take a lot of effort.

- The separation of a computational loop into a loop body and the loop control, or index set, is a powerful concept for GPU programming. The loop body becomes the GPU kernel, and the CPU does the memory allocation, and invokes the kernel.

- Asynchronous work queues can overlap communication and computation. This can help to improve the utilization rate of the GPU.
