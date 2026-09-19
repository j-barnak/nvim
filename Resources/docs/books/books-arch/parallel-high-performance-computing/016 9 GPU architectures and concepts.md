# 9 GPU architectures and concepts

***9 GPU architectures and concepts***

This chapter covers

- Understanding the GPU hardware and connected components
- Estimating the theoretical performance of your GPU
- Measuring the performance of your GPU
- Different application uses for effectively using a GPU

Why do we care about graphics processing units (GPUs) for high-performance computing? GPUs provide a massive source of parallel operations that can greatly exceed that which is available on the more conventional CPU architecture. To exploit their capabilities, it is essential that we understand GPU architectures. Though GPUs have often been used for graphical processing, GPUs are also used for general-purpose parallel computing. This chapter provides an overview of the hardware on a GPU-accelerated platform.

What systems today are GPU accelerated? Virtually every computing system provides the powerful graphics capabilities expected by today’s users. These GPUs range from small components of the main CPU to large peripheral cards taking up a large part of space in a desktop case. HPC systems are increasingly coming equipped with multiple GPUs. On occasion, even personal computers used for simulation or gaming can sometimes connect two GPUs for higher graphics performance. In this chapter, we present a conceptual model that identifies key hardware components of a GPU accelerated system. Figure 9.1 shows these components.

**Figure 9.1 Block diagram of GPU-accelerated system using a dedicated GPU. The CPU and GPU each have their own memory. The CPU and GPU communicate over a PCI bus.**

Due to inconsistent terminology in the community, there is added complexity in understanding GPUs. We will use the terminology established by the OpenCL standard because it was agreed to by multiple GPU vendors. We will also note alternate terminology that is in common use, such as that used by NVIDIA. Let’s look at a few definitions before continuing our discussion:

- CPU—The main processor that is installed in the socket of the motherboard.

- CPU RAM—The “memory sticks” or dual in-line memory modules (DIMMs) containing Dynamic Random-Access Memory (DRAM) that are inserted into the memory slots in the motherboard.

- GPU—A large peripheral card installed in a Peripheral Component Interconnect Express (PCIe) slot on the motherboard.

- GPU RAM—Memory modules on the GPU peripheral card for exclusive use of the GPU.

- PCI bus—The wiring that connects the peripheral cards to the other components on the motherboard.

We’ll introduce each component in a GPU-accelerated system and show how to calculate the theoretical performance for each. We’ll then examine their actual performance with small micro-benchmark applications. This will help to establish how some hardware components can cause bottlenecks that prevent you from accelerating an application with GPUs. Armed with this information, we’ll conclude the chapter with a discussion of the types of applications that benefit most from GPU acceleration and what your goals should be to see performance gains when porting an application to run on GPUs. For this chapter, you’ll find the source code at <https://github.com/EssentialsofParallelComputing/Chapter9>.

***9.1 The CPU-GPU system as an accelerated computational platform***

GPUs are everywhere. They can be found in cell phones, tablets, personal computers, consumer-grade workstations, gaming consoles, high performance computing centers, and cloud computing platforms. GPUs provide additional compute power on most modern hardware and accelerate many operations you may not even be aware of. As the name suggests, GPUs were designed for graphics-related computations. Consequently, GPU design focuses on processing large blocks of data (triangles or polygons) in parallel, which is a requirement for graphics applications. Compared to CPUs that can handle tens of parallel threads or processes in a clock cycle, GPUs are capable of processing thousands of parallel threads simultaneously. Because of this design, GPUs offer a considerably higher theoretical peak performance that can potentially reduce the time to solution and the energy footprint of an application.

Computational scientists, always on the lookout for computational horsepower, were attracted to using GPUs to perform more general-purpose computing tasks. Because GPUs were designed for graphics, the languages originally developed to program them, like OpenGL, focused on graphics operations. To implement algorithms on GPUs, programmers had to reframe their algorithms in terms of these operations, which was time-consuming and error-prone. Extending the use of the graphics processor to non-graphics workloads became known as general-purpose graphics processing unit (GPGPU) computing.

The continued interest and success of GPGPU computing led to the introduction of a flurry of GPGPU languages. The first to gain wide adoption was the Compute Unified Device Architecture (CUDA) programming language for NVIDIA GPUs, which was first introduced in 2007. The dominant open standard GPGPU computing language is the Open Computing Language (OpenCL), developed by a group of vendors led by Apple and released in 2009. We’ll cover both CUDA and OpenCL in chapter 12.

Despite the continual introduction of GPGPU languages, or maybe because of it, many computational scientists have found the original, native, GPGPU languages difficult to use. As a result, higher-level approaches using directive-based APIs gained a large following and spurred corresponding development efforts by vendors. We’ll cover examples of directive-based languages like OpenACC and OpenMP (with the new target directive) in chapter 11. For now, we summarize the new directive-based GPGPU languages, OpenACC and OpenMP, as an unqualified success. These languages and APIs have allowed programmers to focus more on developing their applications, rather than expressing their algorithm in terms of graphics operations. The end result has often been tremendous speedups in scientific and data science applications.

GPUs are best described as accelerators, long used in the computing world. First let’s define what we mean by an accelerator.

> > > **DEFINITION** An accelerator (hardware) is a special-purpose device that supplements the main general-purpose CPU in speeding up certain operations.

A classic example of an accelerator is the original PC that came with the 8088 CPU. It had the option and a socket for the 8087 coprocessor that would do floating-point operations in hardware rather than software. Today, the most common hardware accelerator is the graphics processor, which can be either a separate hardware component or integrated on the main processor. The distinction of being called an accelerator is that it is a special-purpose rather than a general-purpose device, but that difference is not always clear-cut. A GPU is an additional hardware component that can perform operations alongside a CPU. GPUs come in two flavors:

- Integrated GPUs—A graphics processor engine that is contained on the CPU

- Dedicated GPUs—A GPU contained on a separate peripheral card

Integrated GPUs are built directly into the CPU chip. Integrated GPUs share RAM resources with the CPU. Dedicated GPUs are attached to the motherboard via a Peripheral Component Interconnect (PCI) slot. The PCI slot is a physical component that allows data to be transmitted between the CPU and GPU. It is commonly referred to as the PCI bus.

***9.1.1 Integrated GPUs: An underused option on commodity-based systems***

Intel® has long included an integrated GPU with their CPUs for the budget market. They fully expected that users wanting real performance would buy a discrete GPU. The Intel integrated GPUs have historically been relatively weak in comparison to AMD’s (Advanced Micro Devices, Inc.) integrated version. This has recently changed with Intel claiming that the integrated graphics on their Ice Lake processor are on a par with AMD integrated GPUs.

The AMD integrated GPUs are called Accelerated Processing Units (APUs). These are a tightly coupled combination of the CPU and a GPU. The source of the GPU design originally came from the AMD purchase of the ATI graphics card company in 2006. In the AMD APU, the CPU and GPU share the same processor memory. These GPUs are smaller than a discrete GPU, but still (proportionally) give GPU graphics (and compute) performance. The real target for AMD for APUs is to provide a more cost-effective, but performant system for the mass market. The shared memory is also attractive because it eliminates the data transfer over the PCI bus, which is often a serious performance bottleneck.

The ubiquitous nature of the integrated GPU is important. For us, it means that now many commodity desktops and laptops have the ability to accelerate computations. The goal on these systems is a relatively modest performance boost and, perhaps, to reduce the energy cost or to improve battery life. But for extreme performance, the discrete GPUs are still the undisputed performance champions.

***9.1.2 Dedicated GPUs: The workhorse option***

In this chapter, we will focus primarily on GPU accelerated platforms with dedicated GPUs, also called discrete GPUs. Dedicated GPUs generally offer more compute power than integrated GPUs. Additionally, these GPUs can be isolated to execute general-purpose computing tasks. Figure 9.1 conceptually illustrated a CPU-GPU system with a dedicated GPU. A CPU has access to its own memory space (CPU RAM) and is connected to a GPU via a PCI bus. It is able to send data and instructions over the PCI bus for the GPU to work with. The GPU has its own memory space, separate from the CPU memory space.

In order for work to be executed on the GPU, at some point, data must be transferred from the CPU to the GPU. When the work is complete, and the results are going to be written to file, the GPU must send data back to the CPU. The instructions the GPU must execute are also sent from CPU to GPU. Each one of these transactions is mediated by the PCI bus. Although we won’t discuss how to make these actions happen in this chapter, we’ll discuss the hardware performance limitations of the PCI bus. Due to these limitations, a poorly designed GPU application can potentially have worse performance than that with CPU-only code. We’ll also discuss the internal architecture of the GPU and the performance of the GPU with regards to memory and floating-point operations.

***9.2 The GPU and the thread engine***

For those of us who have done thread programming over the years on a CPU, the graphics processor is like the ideal thread engine. The components of this thread engine are

- A seemingly infinite number of threads

- Zero time cost for switching or starting threads

- Latency hiding of memory accesses through automatic switching between work groups

Let’s look at the hardware architecture of a GPU to get an idea of how it performs this magic. To show a conceptual model of a GPU, we abstract the common elements from different GPU vendors and even between design variations from the same vendor. We must remind you that there are hardware variations that are not captured by these abstract models. Adding to this plethora of terminology currently in use, it is not surprising that it is difficult for a newcomer to the field to understand GPU hardware and programming languages. Still, this terminology is relatively sane compared to the graphics world with vertex shaders, texture mapping units, and fragment generators. Table 9.1 summarizes the rough equivalence of terminology, but beware that because the hardware architectures are not exactly the same, the correspondence in terminology varies depending on the context and user.

**Table 9.1 Hardware terminology: A rough translation**

| **Host**                         | **OpenCL**              | **AMD GPU**             | **NVIDIA/CUDA**               | **Intel Gen11**      |
|----------------------------------|-------------------------|-------------------------|-------------------------------|----------------------|
| CPU                              | Compute device          | GPU                     | GPU                           | GPU                  |
| Multiprocessor                   | Compute unit (CU)       | Compute unit (CU)       | Streaming multiprocessor (SM) | Subslice             |
| Processing core (Core for short) | Processing element (PE) | Processing element (PE) | Compute cores or CUDA cores   | Execution units (EU) |
| Thread                           | Work Item               | Work Item               | Thread                        |                      |
| Vector or SIMD                   | Vector                  | Vector                  | Emulated with SIMT warp       | SIMD                 |

The last row in table 9.1 shows the hardware layer that implements a single instruction on multiple data, commonly referred to as SIMD. Strictly speaking, the NVIDIA hardware does not have vector hardware, or SIMD, but emulates this through a collection of threads in what it calls a warp in a single instruction, multi-thread (SIMT) model. You may want to refer back to our initial discussion of parallel categories in section 1.4 to refresh your memory on these different approaches. Other GPUs can also perform SIMT operations on what OpenCL and AMD call subgroups, which are equivalent to the NVIDIA warps. We’ll discuss this more in chapter 10, which explicitly looks at GPU programming models. This chapter, however, will focus on the GPU hardware, its architecture, and concepts.

Often, GPUs also have hardware blocks of replication, some of which are listed in table 9.2, to simplify the scaling of their hardware designs to more units. These units of replication are a manufacturing convenience, but often show up in the specification lists and discussions.

**Table 9.2 GPU hardware replication units by vendor**

| **AMD**            | **NVIDIA/CUDA**             | **Intel Gen11** |
|--------------------|-----------------------------|-----------------|
| Shader Engine (SE) | Graphics processing cluster | Slice           |

Figure 9.2 depicts a simplified block diagram of a single node system with a single multiprocessor CPU and two GPUs. A single node can have a wide variety of configurations, composed of one or more multiprocessor CPUs with an integrated GPU, and from one to six discrete GPUs. In OpenCL nomenclature, each GPU is a compute device. But compute devices can also be CPUs in OpenCL.

> > > **DEFINITION** A compute device in OpenCL is any computational hardware that can perform computation and supports OpenCL. This can include GPUs, CPUs, or even more exotic hardware such as embedded processors or field-programmable gate arrays (FPGAs).

**Figure 9.2 A simplified block diagram of a GPU system showing two compute devices, each having separate GPU, GPU memory, and multiple compute units (CUs). The NVIDIA CUDA terminology refers to CUs as streaming multiprocessors (SMs).**

The simplified diagram in figure 9.2 is our model for describing the components of a GPU and is also useful when understanding how a GPU processes data. A GPU is composed of

- GPU RAM (also known as global memory)

- Workload distributor

- Compute units (CUs) (SMs in CUDA)

CUs have their own internal architecture, often referred to as the microarchitecture. Instructions and data received from the CPU are processed by the workload distributor. The distributor coordinates instruction execution and data movement onto and off of the CUs. The achievable performance of a GPU depends on

- Global memory bandwidth

- Compute unit bandwidth

- The number of CUs

In this section, we’ll explore each of the components for our model of a GPU. With each component, we will also discuss models for theoretical peak bandwidth. Additionally, we’ll show how to use micro-benchmark tools to measure actual performance of components.

***9.2.1 The compute unit is the streaming multiprocessor (or subslice)***

A GPU compute device has multiple CUs. (CU, compute unit, is the term agreed to by the community for the OpenCL standard.) NVIDIA calls them streaming multiprocessors (SMs), and Intel refers to them as subslices.

***9.2.2 Processing elements are the individual processors***

Each CU contains multiple graphics processors called processing elements (PEs) in OpenCL, or CUDA cores (or Compute Cores) as NVIDIA calls them. Intel refers to them as execution units (EUs), and the graphics community calls them shader processors.

Figure 9.3 shows a simplified conceptual diagram of a PE. These processors are not equivalent to a CPU processor; they are simpler designs, needing to perform graphics operations. But the operations needed for graphics include nearly all the arithmetic operations that a programmer uses on a regular processor.

**Figure 9.3 Simplified block diagram of a compute unit (CU) with a large number of processing elements (PEs).**

***9.2.3 Multiple data operations by each processing element***

Within each PE, it might be possible to perform an operation on more than one data item. Depending on the details of the GPU microprocessor architecture and the GPU vendor, these are referred to as SIMT, SIMD, or vector operations. A similar type of functionality can be provided by ganging PEs together.

***9.2.4 Calculating the peak theoretical flops for some leading GPUs***

With an understanding of the GPU hardware, we can now calculate the peak theoretical flops for some recent GPUs. These include the NVIDIA V100, AMD Vega 20, AMD Arcturus, and the integrated Gen11 GPU on the Intel Ice Lake CPU. Table 9.3 lists the specifications for these GPUs. We’ll use these specifications to calculate the theoretical performance of each device. Then, knowing the theoretical performance, you can make comparisons on how each performs. This can help you with purchasing decisions or with estimating how much faster or slower another GPU might be with your calculations. Hardware specifications for many GPU cards can be found at TechPowerUp: <https://www.techpowerup.com/gpu-specs/>.

For NVIDIA and AMD, the GPUs targeted to the HPC market have the hardware cores to perform one double-precision operation for every two single-precision operations. This relative flop capability can be expressed as a ratio of 1:2, where double precision is 1:2 of single precision on top-end GPUs. The importance of this ratio is that it tells you that you can roughly double your performance by reducing your precision requirements from double precision to single. For many GPUs, half precision has a ratio of 2:1 to single precision or double the flop capability. The Intel integrated GPU has 1:4 double precision relative to single precision, and some commodity GPUs have 1:8 ratios of double precision to single precision. GPUs with these lower ratios of double precision are targeted at the graphics market or for machine learning. To get these ratios, take the FP64 row and divide by the FP32 row.

**Table 9.3 Specifications for recent discrete GPUs from NVIDIA, AMD, and an integrated Intel GPU**

| **GPU**                 | **NVIDIA V100 (Volta)** | **NVIDIA A100 (Ampere)** | **AMD Vega 20 (MI50)**         | **AMD Arcturus (MI100)**       | **Intel Gen11 Integrated** |
|-------------------------|-------------------------|--------------------------|--------------------------------|--------------------------------|----------------------------|
| Compute units (CUs)     | 80                      | 108                      | 60                             | 120                            | 8                          |
| FP32 cores/CU           | 64                      | 64                       | 64                             | 64                             | 64                         |
| FP64 cores/CU           | 32                      | 32                       | 32                             | 32                             |                            |
| GPU clock nominal/boost | 1290/1530 MHz           | 1410 MHz                 | 1200/1746 MHz                  | 1000/1502 MHz                  | 400/1000 MHz               |
| Subgroup or warp size   | 32                      | 32                       | 64                             | 64                             |                            |
| Memory clock            | 876 MHz                 | 1215 MHz                 | 1000 MHz                       | 1200 MHz                       | Shared memory              |
| Memory type             | HBM2 (32 GB)            | HBM2(40 GB)              | HBM2                           | HBM2 (32 GB)                   | LPDDR4X-3733               |
| Memory data width       | 4096 bits               | 5120 bits                | 4096 bits                      | 4096 bits                      | 384 bits                   |
| Memory bus type         | NVLink or PCIe 3.0x16   | NVLink or PCIe Gen 4     | Infinity Fabric or PCIe 4.0x16 | Infinity Fabric or PCIe 4.0x16 | Shared memory              |
| Design Power            | 300 watts               | 400 watts                | 300 watts                      | 300 watts                      | 28 watts                   |

The peak theoretical flops can be calculated by taking the clock rate times the number of processors times the number of floating-point operations per cycle. The flops per cycle accounts for the fused-multiply add (FMA), which does two operations in one cycle.

Peak Theoretical Flops (GFlops/s)

= Clock rate MHZ × Compute Units × Processing units

× Flops/cycle

> **Example: Peak theoretical flop for some leading GPUs**

> Theoretical Peak Flops for NVIDIA V100:

- 2 × 1530 × 80 × 64 /10^6 = 15.6 TFlops (single precision)

- 2 × 1530 × 80 × 32 /10^6 = 7.8 TFlops (double precision)

> Theoretical Peak Flops for NVIDIA Ampere:

- 2 × 1410 × 108 × 64 /10^6 = 19.5 TFlops (single precision)

- 2 × 1410 × 108 x× 32 /10^6 = 9.7 TFlops (double precision)

> Theoretical Peak Flops for AMD Vega 20 (MI50):

- 2 × 1746 × 60 × 64 /10^6 = 13.4 TFlops (single precision)

- 2 × 1746 × 60 × 32 /10^6 = 6.7 TFlops (double precision)

> Theoretical Peak Flops for AMD Arcturus (MI100):

- 2 × 1502 × 120 × 64 /10^6 = 23.1 TFlops (single precision)

- 2 × 1502 × 120 × 32 /10^6 = 11.5 TFlops (double precision)

> Theoretical Peak Flops for Intel Integrated Gen 11 on Ice Lake:

- 2 × 1000 × 64 × 8 /10^6 = 1.0 TFlops (single precision)

Both the NVIDIA V100 and the AMD Vega 20 give impressive floating-point peak performance. The Ampere shows some additional improvement in floating-point performance, but it is the memory performance that promises greater increases. The MI100 from AMD shows a bigger jump in floating-point performance. The Intel integrated GPU is also quite impressive given that it is limited by the available silicon space and lower nominal design power of a CPU. With Intel developing plans for discrete graphics cards for several market segments, expect to see even more GPU options in the future.

***9.3 Characteristics of GPU memory spaces***

A typical GPU has different types of memory. Using the right memory space can make a big impact on performance. Figure 9.4 shows these memories as a conceptual diagram. It helps to see the physical locations of each level of memory to understand how it should behave. Although a vendor can put the GPU memory wherever they want, it must behave as shown in this diagram.

**Figure 9.4 Rectangles show each component of the GPU and the memory that is at each hardware level. The host writes and reads the global and constant memory. Each of the CUs can read and write from the global memory and read from the constant memory.**

The list of the GPU memory types and their properties are as follows.

- Private memory (register memory)—Immediately accessible by a single PE and only by that PE.

- Local memory—Accessible to a single CU and all of the PEs on that CU. Local memory can be split between a scratchpad that can be used as a programmable cache and, by some vendors, a traditional cache on GPUs. Local memory is around 64-96 KB in size.

- Constant memory—Read-only memory accessible and shared across all of the CUs.

- Global memory—Memory that’s located on the GPU and accessible by all of the CUs.

One of the factors that makes GPUs fast is that they use specialized global memory (RAM), which provides higher bandwidth, whereas current CPUs use DDR4 memory and are just now moving to DDR5. GPUs use a special version called GDDR5 that gives higher performance. The latest GPUs are now moving to High-Bandwidth Memory (HBM2) that provides even higher bandwidth. Besides increasing bandwidth, HBM also reduces power consumption.

***9.3.1 Calculating theoretical peak memory bandwidth***

You can calculate the theoretical peak memory bandwidth for a GPU from the memory clock rate on the GPU and the width of the memory transactions in bits. Table 9.4 shows some of the higher values for each memory type. We also need to multiply by a factor of two for the double data rate, which retrieves memory at both the top of the cycle and at the bottom. Some DDR memory can even do more transactions per cycle. Table 9.4 also shows some of the transaction multipliers for different kinds of graphics memory.

**Table 9.4 Specifications for common GPU memory types**

| **Graphics Memory Type** | **Memory Clock (MHz)** | **Memory Transactions (GT/s)** | **Memory Bus Width (bits)** | **Transaction Multiplier** | **Theoretical Bandwidth (GB/s)** |
|--------------------------|------------------------|--------------------------------|-----------------------------|----------------------------|----------------------------------|
| GDDR3                    | 1000                   | 2.0                            | 256                         | 2                          | 64                               |
| GDDR4                    | 1126                   | 2.2                            | 256                         | 2                          | 70                               |
| GDDR5                    | 2000                   | 8.0                            | 256                         | 4                          | 256                              |
| GDDR5X                   | 1375                   | 11.0                           | 384                         | 8                          | 528                              |
| GDDR6                    | 2000                   | 16.0                           | 384                         | 8                          | 768                              |
| HBM1                     | 500                    | 1000.0                         | 4096                        | 2                          | 512                              |
| HBM2                     | 1000                   | 2000.0                         | 4096                        | 2                          | 1000                             |

Calculating the theoretical memory bandwidth takes the memory clock rate times the number of transactions per cycle and then multiplies by the number of bits retrieved on each transaction:

Theoretical Bandwidth = Memory Clock Rate (GHz) × Memory bus (bits) × (1 byte/8 bits) × transaction multiplier

Some specification sheets give the memory transaction rate in Gbps rather than the memory clock frequency. This rate is the transactions per cycle times the clock rate. Given this specification, the bandwidth equation becomes

Theoretical Bandwidth = Memory Transaction Rate(Gbps) × Memory bus (bits) × (1 byte/8 bits)

> **Example: Theoretical bandwidth calculations**

- For the NVIDIA V100 that operates at 876 MHz and uses HBM2 memory:

> Theoretical Bandwidth = 0.876 × 4096 × 1/8 × 2 = 897 GB/s

- For the AMD Radeon Vega20 (MI50) GPU that operates at 1000 MHz:

> Theoretical Bandwidth = 1.000 × 4096 × 1/8 × 2 = 1024 GB/s

***9.3.2 Measuring the GPU stream benchmark***

Because most of our applications scale with memory bandwidth, the STREAM Benchmark that measures memory bandwidth is one of the most important micro-benchmarks. We first used the STREAM Benchmark to measure the bandwidth on CPUs in section 3.2.4. The benchmark process is similar for the GPUs, but we need to rewrite the stream kernels in GPU languages. Fortunately, this has been done by Tom Deakin at the University of Bristol for a variety of GPU languages and hardware in his Babel STREAM code.

The Babel STREAM Benchmark code measures the bandwidth of a variety of hardware with different programming languages. We use it here to measure the bandwidth of an NVIDIA GPU using CUDA. Also available are versions in OpenCL, HIP, OpenACC, Kokkos, Raja, SYCL, and OpenMP with GPU targets. These are all different languages that can be used for GPU hardware like NVIDIA, AMD, and Intel GPUs.

> **Exercise: Measuring bandwidth using the Babel STREAM Benchmark**

> The steps to using the stream benchmark for CUDA on an NVIDIA GPU are

1.  Clone the Babel STREAM Benchmark with

    > `git clone git@github.com:UoB-HPC/BabelStream.git`

2.  Then type

    > `make -f CUDA.make`  
    > `./cuda-stream`

> The results for an NVIDIA V100 GPU are

> `Function    MBytes/sec  Min (sec)   Max         Average   `  
> `Copy        800995.012  0.00067     0.00067     0.00067   `  
> `Mul         796501.837  0.00067     0.00068     0.00068   `  
> `Add         838993.641  0.00096     0.00097     0.00096   `  
> `Triad       840731.427  0.00096     0.00097     0.00096   `  
> `Dot         866071.690  0.00062     0.00063     0.00063`

> The process is similar for the AMD GPU:

1.  Edit the OpenCL.make file and add the paths to your OpenCL header files and libraries.

2.  Then type

    > `make -f OpenCL.make`  
    > `./ocl-stream`

> For the AMD Vega 20, the GPU bandwidth is slightly lower than the NVIDIA GPU.

> `Using OpenCL device gfx906+sram-ecc`  
> `Function    MBytes/sec  Min (sec)   Max         Average    `  
> `Copy        764889.965  0.00070     0.00077     0.00072    `  
> `Mul         764182.281  0.00070     0.00076     0.00072    `  
> `Add         764059.386  0.00105     0.00134     0.00109    `  
> `Triad       763349.620  0.00105     0.00110     0.00108    `  
> `Dot         670205.644  0.00080     0.00088     0.00083     `

***9.3.3 Roofline performance model for GPUs***

We introduced the roofline performance model for CPUs in section 3.2.4. This model accounts for both memory bandwidth and flop performance limits of the system. It is similarly useful for GPUs to understand their performance limits.

> **Exercise: Measuring bandwidth using the Empirical Roofline Toolkit**

> For this exercise, you will need access to an NVIDIA and/or an AMD GPU. A similar process can be used for other GPUs.

1.  Get the roofline toolkit with

    > `git clone https:/ /bitbucket.org/berkeleylab/cs-roofline-toolkit.git`

2.  Then type

    > `cd cs-roofline-toolkit/Empirical_Roofline_Tool-1.1.0`  
    > `cp Config/config.voltar.uoregon.edu Config/config.V100_gpu`

3.  Edit these settings in Config/config.V100_gpu

    > `ERT_RESULTS Results.V100_gpu`  
    > `ERT_PRECISION FP64`  
    > `ERT_NUM_EXPERIMENTS 5`

4.  Run

    > `tests ./ert Config/config.V100_gpu`

5.  View the Results.config.V100_gpu/Run.001/roofline.ps file

    > `cp Config/config.odinson-ocl-fp64.01 Config/config.Vega20_gpu`

6.  Edit these settings in Config/config.Vega20_gpu

    > `ERT_RESULTS Results.Vega20_gpu`  
    > `ERT_CFLAGS  -O3 -x c++ -std=c++11 -Wno-deprecated-declarations`  
    > `            -I<path to OpenCL headers>`  
    > `ERT_LDLIBS  -L<path to OpenCL libraries> -lOpenCL`

7.  Run

    > `tests ./ert Config/config.Vega20_gpu`

8.  View the output in Results.config.Vega20_gpu/Run.001/roofline.ps

Figure 9.5 shows the results of the roofline benchmarks for both the NVIDIA V100 and the AMD Vega20 GPUs.

**Figure 9.5 Roofline plots for NVIDIA V100 and AMD Vega 20 showing the bandwidth and flop limits for the two GPUs.**

***9.3.4 Using the mixbench performance tool to choose the best GPU for a workload***

There are many GPU options for cloud services and in the HPC server market. Is there a way to figure out the best value GPU for your application? We’ll look at a performance model that can help you select the best GPU for your workload.

By changing the independent variable in the roofline plot from arithmetic intensity to the memory bandwidth, the performance limits of an application relative to each GPU device are highlighted. The mixbench tool was developed to draw out the differences between the performance of different GPU devices. This information is really no different than that shown in the roofline model, but visually it has a different impact. Let’s go through an exercise using the mixbench tool to show what you can learn.

> **Exercise: Getting both the peak flop rate and bandwidth using the mixbench tool**

1.  Get the mixbench code

    > `git clone https:/ /github.com/ekondis/mixbench.git`

2.  Check for CUDA or OpenCL and install if necessary.

    > `cd mixbench; edit Makefile`

3.  Fix the path to the CUDA and/or OpenCL installations.

4.  Set the executables to build. You can override the path to the CUDA installation with

    > `make CUDA_INSTALL_PATH=<path>`

5.  Run either of the following:

    > `./mixbench-cuda-ro`  
    > `./mixbench-ocl-ro`

The results of the benchmark are plotted as the compute rate in GFlops/sec with respect to the memory bandwidth in GB/sec (figure 9.6). Basically, the benchmark results in a horizontal line at the peak flop rate and a vertical dropoff at the memory bandwidth limit. The maximum of each of these values is taken and used to plot the single point at the upper right that captures both the peak flop and peak bandwidth capabilities of the GPU device.

**Figure 9.6 The data output from a run of mixbench on a V100 (shown as a line plot). The maximum bandwidth and floating-point rate is found and used to plot the V100 performance point in the upper right of the plot.**

We can run the mixbench tool for a variety of GPU devices and get their peak performance characteristics. GPU devices designed for the HPC market have a high double-precision floating-point capability, and GPUs for other markets like graphics and machine learning focus on single-precision hardware.

We can plot each GPU device in figure 9.7 along with a line representing the arithmetic or operational intensity of an application. Most typical applications are around a 1 flop/load intensity. At the other extreme, matrix multiplication has an arithmetic intensity of 65 flops/load. We show a sloped line for both of these types of applications in figure 9.7. If the GPU point is above the application line, we draw a vertical line down to the application line to find what the achievable application performance will be. For a device to the right and lower than the application line, we use a horizontal line to find the performance limit.

**Figure 9.7 A collection of performance points for GPU devices (shown on the plot on the right) along with the application arithmetic intensity (shown as straight lines). Values above the line indicate that the application is memory-bound and below the line indicates it is compute-bound.**

What the plot makes clear is the match in the GPU device characteristics relative to the application requirements. For the typical application that has a 1 flop/load arithmetic intensity, GPUs like the GeForce GTX 1080Ti, built for the graphics market, are a good match. The V100 GPU is more suited for the Linpack benchmark used for the TOP500 ranking of large computing systems because it’s basically composed of matrix multiplications. GPUs like the V100 are specialized hardware specifically built for the HPC market and command a high price premium. For some applications with lower arithmetic intensity, the commodity GPUs designed for the graphics market can be a better value.

***9.4 The PCI bus: CPU to GPU data transfer overhead***

The PCI bus shown in figure 9.1 is needed to transfer data from the CPU to the GPU and back. The cost of the data transfer can be a significant limitation on the performance of operations moved to the GPU. It is often critical to limit the amount of data that gets transferred back and forth to get any speedup from the GPU.

The current version of the PCI bus is called PCI Express (PCIe). It has been revised several times in generations from 1.0 to 6.0 as of this writing. You should know which generation of the PCIe bus you have in your system to understand its performance limitation. In this section, we show two methods for estimating the bandwidth of a PCI bus:

- A back-of-the-envelope theoretical peak performance model

- A micro-benchmark application

The theoretical peak performance model is useful for quickly estimating what you might expect on a new system. The model has the benefit that you don’t need to run any applications on the system. This is useful when you are just starting a project and would like to quickly estimate by hand the possible performance bottlenecks. In addition, the benchmark example shows that the peak bandwidth you can reach depends on how you make use of the hardware.

***9.4.1 Theoretical bandwidth of the PCI bus***

On dedicated GPU platforms, all data communication between the GPU and CPU occurs over the PCI bus. Because of this, it is a critical hardware component that can heavily influence the overall performance of your application. In this section, we go over the key features and descriptors of a PCI bus that you need to be aware of in order to calculate the theoretical PCI bus bandwidth. Knowing how to calculate this number on the fly is useful for estimating possible performance limitations when porting your application to GPUs.

The PCI bus is a physical component that attaches dedicated GPUs to the CPU and other devices. It allows for communication between the CPU and GPU. Communication occurs over multiple PCIe lanes. We’ll start by presenting a formula for the theoretical bandwidth, and then explain each term.

Theoretical Bandwidth (GB/s) = Lanes × TransferRate (GT/s) × OverheadFactor(Gb/GT) × byte/8 bits

The theoretical bandwidth is measured in units of gigabytes per second (GB/s). It is calculated by multiplying the number of lanes and the maximum transfer rate for each lane and then converting from bits to bytes. The conversion is left in the formula because the transfer rates are usually reported in GigaTransfers per second (GT/s). The overhead factor is due to an encoding scheme used to ensure data integrity, reducing the effective transfer rate. For generation 1.0 devices, the encoding scheme had a cost of 20%, so the overhead factor would be 100%-20% or 80%. From generation 3.0 onward, the encoding scheme overhead drops to just 1.54%, so the achieved bandwidth becomes essentially the same as the transfer rate. Let’s now dive into each of the terms in the bandwidth equation.

***PCIE LANES***

The number of lanes of a PCI bus can be found by looking through manufacturer specifications, or you can use a number of tools available on Linux platforms. Keep in mind that some of these tools might require root privileges. If you do not have these privileges, it is best to consult your system administrator to find out this information. Nonetheless, we will present two options for determining the number of PCIe lanes.

A common utility available on Linux systems is lspci. This utility lists all the components attached to the motherboard. We can use the grep regular expression tool to filter out only the PCI bridge. The following command shows you the vendor information and the device name with the number of PCIe lanes. For this example, `(x16)` in the output indicates that there are 16 lanes.

> `$ lspci -vmm | grep "PCI bridge" -A2`  
> `Class:     PCI bridge`  
> `Vendor:    Intel Corporation`  
> `Device:    Sky Lake PCIe Controller (x16)`

Alternatively, the `dmidecode` command provides similar information:

> `$ dmidecode | grep "PCI"`  
> `PCI is supported`  
> `Type: x16 PCI Express`

***DETERMINING THE MAXIMUM TRANSFER RATE***

The maximum transfer rates for each lane in a PCIe bus can directly be determined by its design generation. Generation is a specification for the required performance of the hardware, much like 4G is an industry standard for cell-phones. The PCI Special Interest Group (PCI SIG) represents industry partners and establishes a PCIe specification that is commonly referred to as generation or gen for short. Table 9.5 shows the maximum transfer rate per PCI lanes and direction.

**Table 9.5 PCI Express (PCIe) specifications by generation**

| **PCIe Generation** | **Maximum Transfer Rate (bi-directional)** | **Encoding Overhead** | **Overhead factor(100%-encoding overhead)** | **Theoretical Bandwidth16 lanes - GB/s** |
|---------------------|--------------------------------------------|-----------------------|---------------------------------------------|------------------------------------------|
| Gen1                | 2.5 GT/s                                   | 20%                   | 80%                                         | 4                                        |
| Gen2                | 5.0 GT/s                                   | 20%                   | 80%                                         | 8                                        |
| Gen3                | 8.0 GT/s                                   | 1.54%                 | 98.46%                                      | 15.75                                    |
| Gen4                | 16.0 GT/s                                  | 1.54%                 | 98.46%                                      | 31.5                                     |
| Gen5 (2019)         | 32.0 GT/s                                  | 1.54%                 | 98.46%                                      | 63                                       |
| Gen6 (2021)         | 64.0 GT/s                                  | 1.54%                 | 98.46%                                      | 126                                      |

If you don’t know the generation of your PCIe bus, you can use lspci to get this information. In all of the information output by lspci, we are looking for the link capacity for the PCI bus. In this output, link capacity is abbreviated `LnkCap`:

> `$ sudo lspci -vvv | grep -E 'PCI|LnkCap'`  
> `Output:`  
>   
> `00:01.0 PCI bridge:`  
> `        Intel Corporation Sky Lake PCIe Controller (x16) (rev 07)`  
> `LnkCap: Port #2, Speed 8GT/s, Width x16, ASPM L0s L1, Exit Latency L0s`

Now that we know the maximum transfer rate from this output, we can use this in the bandwidth formula. It’s also helpful to know that this speed can also be aligned with the generation. In this case, the output indicates that we are working with a Gen3 PCIe system.

> > > **NOTE** On some systems, the output from lspci and other system utilities may not give much information. The output is system specific and just reports the identification from each device. If you are unable to determine the characteristics from these utilities, your fallback might be to use the PCI benchmark code given in section 9.4.2 to determine the capabilities of your system.

***OVERHEAD RATES***

Transmitting data across the PCI bus requires additional overhead. Generation 1 and 2 standards stipulate that 10 bytes are transmitted for every 8 bytes of useful data. Starting with generation 3, the transfer transmits 130 bytes for every 128 bytes of data. The overhead factor is the ratio of the number of usable bytes over the total bytes transmitted (table 9.5).

***REFERENCE DATA FOR PCIE THEORETICAL PEAK BANDWIDTH***

Now that we have all of the necessary information, let’s estimate the theoretical bandwidth through an example, using output shown in the previous sections.

> **Example: Estimating the theoretical bandwidth**

> We have identified that we have a Gen3 PCIe system with 16 lanes. Gen3 systems have a maximum transfer rate of 8.0 GT/s and an overhead factor of 0.985. With 16 lanes, the theoretical bandwidth is 15.75 GB/s as shown here.

> Theoretical Bandwidth (GB/s)

> = 16 lanes × 8.0 GT/s × 0.985 (Gb/GT) × byte/8 bits

> = 15.75 GB/s

***9.4.2 A benchmark application for PCI bandwidth***

The equation for the theoretical PCI bandwidth gives the expected best peak bandwidth. In other words, this is the highest possible bandwidth that an application can achieve for a given platform. In practice, the achieved bandwidth can depend on a number of factors, including the OS, system drivers, other hardware components on the compute node, GPU programming API, and the size of the data block sent across the PCI bus. On most systems you have access to, it is likely that all but the last two choices are out of your control to modify. When developing your application, you are in control of the programming API and the size of the data blocks that are transmitted across the PCI bus.

With this in mind, we are left with the question how does the data block size influence the achieved bandwidth? This type of question is typically answered with a micro-benchmark. A micro-benchmark is a small program that is meant to exercise a single process or piece of hardware that a larger application will use. Micro-benchmarks help provide some indication of system performance.

In our situation, we want to devise a micro-benchmark that copies data from the CPU to the GPU and vice-versa. Because the data copy is expected to happen in microseconds to tens of microseconds, we will measure the time it takes to complete the data copy 1,000 times. This time will then be divided by 1,000 to obtain the average time to copy data between the CPU and GPU.

We will do a step-by-step walk through using a benchmark application to measure PCI bandwidth. Listing 9.1 shows the code that copies data from the host to the GPU. Writing in the CUDA GPU programming language will be covered in chapter 10, but the basic operation is clear from the function names. In listing 9.1, we take in the size of a flat 1-D array as input that we want to copy from CPU (host) to the GPU (device).

> > > **NOTE** This code is available in the PCI_Bandwidth_Benchmark subdirectory at <https://github.com/EssentialsofParallelComputing/Chapter9>.

**Listing 9.1 Copying data from CPU host to GPU device**

> `PCI_Bandwidth_Benchmark.c`  
> `35 void Host_to_Device_Pinned( int N, double *copy_time )`  
> `36 {`  
> `37    float *x_host, *x_device;`  
> `38    struct timespec tstart;`  
> `39`  
> `40    cudaError_t status = cudaMallocHost((void**)&x_host, N*sizeof(float));`❶  
> `41    if (status != cudaSuccess)`  
> `42          printf("Error allocating pinned host memory\n");`  
> `43    cudaMalloc((void **)&x_device, N*sizeof(float));                      `❷  
> `44   `  
> `45    cpu_timer_start(&tstart);`  
> `46    for(int i = 1; i <= 1000; i++ ){`  
> `47       cudaMemcpy(x_device, x_host, N*sizeof(float),`  
> `         cudaMemcpyHostToDevice);                                           `❸  
> `48    }`  
> `49    cudaDeviceSynchronize();                                              `❹  
> `50   `  
> `51    *copy_time = cpu_timer_stop(tstart)/1000.0;`  
> `52   `  
> `53    cudaFreeHost( x_host );                                               `❺  
> `54    cudaFree( x_device );                                                 `❺  
> `55 } `

❶ Allocates pinned host memory for an array on the CPU

❷ Allocates memory for an array on the GPU

❸ Copies memory to the GPU

❹ Synchronizes the GPU so that the work completes

❺ Frees the arrays

In listing 9.1, the first step is to allocate memory for both the host and device copy. The routine on line 40 in this listing uses `cudaMallocHost` to allocate pinned memory on the host for faster data transfer. For the routine that uses regular pageable memory, the standard `malloc` and `free` calls are used. The `cudaMemcpy` routine transfers the data from the CPU host to the GPU. The `cudaDeviceSynchronize` call waits until the copy is complete. Before the loop, where we repeat the host to device copy, we capture the start time. We then execute the host-to-device copy 1,000 times and capture the current time again. The average time for copying from host to device is then calculated by dividing by 1,000. To keep things neat, we free the space held by the host and device arrays.

With the knowledge of the time it takes to transfer an array of size N from host to device, we can now call this routine multiple times, changing N each time. However, we’re more interested in estimating the achieved bandwidth.

Recall that the bandwidth is the number of transmitted bytes per unit time. At the moment, we know the number of array elements and the time it takes to copy the array between the CPU and GPU. The number of bytes transmitted depends on the type of data stored in the array. For example, in an array of size N containing floats (4 bytes), the amount of data copied between CPU and GPU is 4N. If 4N bytes are transferred in time T, the achieved bandwidth is

B = 4N/T

This allows us to build a dataset showing the achieved bandwidth as a function of N. The subroutine in the following listing requires that the maximum array size is specified and then returns the bandwidth measured for each experiment.

**Listing 9.2 Calling a CPU to GPU memory transfer for different array sizes**

> `PCI_Bandwidth_Benchmark.c`  
> `81 void H2D_Pinned_Experiments(double **bandwidth, int n_experiments,`  
> `         int max_array_size){`  
> `82    long long array_size;`  
> `83    double copy_time;`  
> `84`  
> `85    for(int j=0; j<n_experiments; j++){                                  `❶  
> `86       array_size = 1;`  
> `87       for(int i=0; i<max_array_size; i++ ){                             `❷  
> `88`  
> `89          Host_to_Device_Pinned( array_size, &copy_time );               `❸  
> `90`  
> `91          double byte_size=4.0*array_size;                               `❹  
> `92          bandwidth[j][i] = byte_size/(copy_time*1024.0*1024.0*1024.0);  `❹  
> `93`  
> `94          array_size = array_size*2;                                     `❷  
> `95       }`  
> `96    }`  
> `97 }`

❶ Repeats the experiments a few times

❷ Doubles the array size with each iteration

❸ Calls CPU to GPU memory test and timing

❹ Calculates bandwidth

Here, we loop over array sizes, and for each array size, we obtain the average host-to-device copy time. The bandwidth is then calculated by the number of bytes copied divided by the time it takes to copy. The array contains floats, which have four bytes for each array element. Now, let’s walk through an example that shows how you can use the micro-benchmark application to characterize the performance of your PCI Bus.

***PERFORMANCE OF A GEN3 X16 ON A LAPTOP***

We ran the PCI bandwidth benchmark application on a GPU accelerated laptop. On this system, the `lspci` command shows that it is equipped with a Gen3 x16 PCI bus:

> `$ sudo lspci -vvv | grep -E 'PCI|LnkCap'`  
> `00:01.0 PCI bridge: Intel Corporation Sky Lake PCIe Controller (x16)`  
> `                    (rev 07)`  
> `            LnkCap: Port #2, Speed 8GT/s, Width x16, ASPM L0s L1,`  
> `                    Exit Latency L0s`

For this system, the theoretical peak bandwidth of the PCI Bus is 15.8 GB/s. Figure 9.8 shows a plot of the achieved bandwidth in our micro-benchmark application (curved lines) compared to the theoretical peak bandwidth (horizontal dashed lines). The shaded region around the achieved bandwidth indicates the +/- 1 standard deviation in bandwidth.

**Figure 9.8 A theoretical peak bandwidth (horizontal lines) and an empirically measured bandwidth from the micro-benchmark application are shown for a Gen3 x16 PCIe system. The figure also shows results for both pinned and pageable memory.**

First, notice that when small chunks of data are sent across the PCI bus, the achieved bandwidth is low. Beyond array sizes of 107 bytes, the achieved bandwidth approaches a maximum around 11.6 GB/s. Note also that the bandwidth with pinned memory is much higher than pageable memory, and pageable memory has a much wider variation of performance results for each memory size. It is helpful to know what pinned and pageable memory are to understand the reason for this difference.

- Pinned memory—Memory that cannot be paged from RAM and, thus, can be directly sent to the GPU without first making a copy

- Pageable memory—Standard memory allocations that can be paged out to disk

Allocating pinned memory reduces the memory available to other processes because the OS kernel can no longer make the memory page out to disk so other processes can use it. Pinned memory is allocated from the standard DRAM memory for the processor. The allocation process takes a little bit longer than a regular allocation. When using pageable memory, it must be copied into a pinned memory location before it can be sent. The pinned memory prevents it from being paged out to disk while the memory is being transferred. The example in this section shows that larger data transfers between the CPU and GPU can result in higher achieved bandwidth. Further, on this system, the maximum achieved bandwidth only reaches about 72% of the theoretical peak performance.

***9.5 Multi-GPU platforms and MPI***

Now that we’ve introduced the basic components of a GPU-accelerated platform, we’ll discuss more exotic configurations that you might encounter. These exotic configurations come from the introduction of multiple GPUs. Some platforms offer multiple GPUs per node, connected to one or more CPUs. Others offer connections to multiple compute nodes over network hardware.

On the types of multi-GPU platforms (figure 9.9), it is usually necessary to use an MPI+GPU approach to parallelism. For data parallelism, each MPI rank is assigned to one of the GPUs. Let’s look at a couple of possibilities:

- Single MPI rank drives each GPU

- Multiple MPI ranks multiplex their work on a GPU

**Figure 9.9 Here we illustrate a multi-GPU platform. A single compute node can have multiple GPUs and multiple processors. There can also be multiple nodes connected across a network.**

Some of the early GPU software and hardware did not handle multiplexing efficiently, resulting in poor performance. With many of the performance problems fixed in the latest software, it is becoming increasingly attractive to multiplex MPI ranks onto the GPUs.

***9.5.1 Optimizing the data movement between GPUs across the network***

To use multiple GPUs, we have to send data from one GPU to another. Before we can discuss the optimization, we need to describe the standard data transfer process.

1.  Copy the data from the GPU to the host processor

    1.  Move the data across the PCI bus to the processor

    2.  Store the data in CPU DRAM memory

2.  Send the data in an MPI message to another processor

    1.  Stage the data from CPU memory to the processor

    2.  Move the data across the PCI bus to the network interface card (NIC)

    3.  Store the data from the processor to CPU memory

3.  Copy the data from the second processor to the second GPU

    1.  Load the data from CPU memory to the processor

    2.  Send the data across the PCI bus to the GPU

As figure 9.10 shows, this is a lot of data movement and will be a major limitation to application performance.

In an NVIDIA GPUDirect®, CUDA adds the capability to send the data in a message. AMD has a similar capability called DirectGMA for GPU-to-GPU in OpenCL. The pointer to the data still has to be transferred, but the message itself gets sent over the PCI bus directly from one GPU to another GPU, thereby reducing the memory movement.

**Figure 9.10 On the top is the standard data movement for sending data from a GPU to other GPUs. On the bottom, the data movement bypasses the CPU when moving data from one GPU to another.**

***9.5.2 A higher performance alternative to the PCI bus***

There is little argument that the PCI bus is a major limitation for compute nodes with multi-GPUs. While this is mostly a concern for large applications, it also impacts heavy workloads such as in machine learning on smaller clusters. NVIDIA introduced NVLink® to replace GPU-to-GPU and GPU-to-CPU connections with their Volta line of P100 and V100 GPUs. With NVLink 2.0, the data transfer rates can reach 300 GB/sec. The new GPUs and CPUs from AMD incorporate Infinity Fabric to speed up data transfers. And Intel has been accelerating data transfers between CPUs and memory for some years.

***9.6 Potential benefits of GPU-accelerated platforms***

When is porting to GPUs worth it? At this point you’ve seen the theoretical peak performance for modern GPUs and how this compares to CPUs. Compare the roofline plot for the GPU in figure 9.5 to the CPU roofline plot in section 3.2.4 for both the floating-point calculation and the memory bandwidth limits. In practice, many applications do not reach these peak performance values. However, with the ceilings raised for GPUs, there is potential to outperform CPU architectures relative to a few metrics. These include the time to execute your application, energy consumption, cloud computing costs, and scalability.

***9.6.1 Reducing time-to-solution***

Suppose you have an existing code that runs on CPUs. You’ve spent a lot of time putting OpenMP or MPI into the code so that you can use all of the cores on the CPU. You feel like the code is well tuned, but a friend has told you that you might benefit more by porting your code to GPUs. You have more than 10,000 lines of code in your application, and you know that it will take considerable effort to get your code running on GPUs. At this point, you’re interested in the prospect of running on GPUs because you like learning new things and you trust your friend’s insights. Now, you have to make the case to your colleagues and your boss.

The important measure for your application is to reduce the time-to-solution for jobs that run days at a stretch. The best way to get across the impact of a reduction in time-to-solution is to look at an example. We’ll use the Cloverleaf application as a proxy for this study.

> **Example: Considering an upgrade to your current workhorse system**

> Here are the steps to gather the performance of Cloverleaf on the base system. We use an Intel Ivybridge system (E5-2650 v2 @ 2.60GHz) with 16 physical cores. On average your application runs for about 500,000 cycles. You can get an estimate of the run time for a short sample run with these steps:

1.  Clone Cloverleaf.git with

    > `git clone --recursive git@github.com:UK-MAC/CloverLeaf.git CloverLeaf`

2.  Then enter these commands

    > `cd CloverLeaf_MPI`  
    > `make COMPILER=INTEL`  
    > `sed -e ‘1,$s/end_step=2955/end_step=500/’ InputDecks/clover_bm64.in\`  
    > `         >clover.in`  
    > `mpirun -n 16 --bind-to core ./clover_leaf`

> The run time for 500 cycles is 615.1 secs or 1.23 secs per cycle. This gives you a run time of 171 hours or 7 days and 3 hours.

Now let’s get the run time for a couple of possible replacement platforms.

> **Example CPU replacement: Skylake Gold 6152 with 2.10GHz with 36 physical cores**

> The only difference for this run is that we increase the 16 processors to 36 for `mpirun` with this command:

> `mpirun -n 36 --bind-to core ./clover_leaf`

> The run time for the Skylake system is 273.3 secs or 0.55 secs per cycle. This would give a run time for the typical application problem of 76.4 hours or 3 days and 4 hours.

Not bad! Less than half the time as before. You are about ready to purchase this system but then think that maybe you should check out those GPUs that you have been hearing about.

> **Example GPU replacement: V100**

> CloverLeaf has a CUDA version that runs on the V100. You measure the performance with the following steps:

1.  Clone Cloverleaf.git with

    > `git clone --recursive git@github.com:UK-MAC/CloverLeaf.git CloverLeaf`

2.  Then type

    > `cd CloverLeaf_CUDA`

3.  Add the CUDA architecture flags for Volta to the makefile to the current list of CODE_GEN architectures:

    > `CODE_GEN_VOLTA=-arch=sm_70`

4.  Add the path to CUDA library CUDART, if necessary:

    > `make COMPILER=GNU NV_ARCH=VOLTA`  
    > `sed -e ‘1,$s/end_step=2955/end_step=500/’ clover_bm64.in >clover.in`

> Whoa! The run is so fast you don’t even have time to get a cup of coffee. But there it is: 59.3 secs! This is 0.12 secs per cycle or, for the full test problem size, a sweet 16.5 hours. Compared to the Skylake system, this is 4.6 times faster, and 10.4 times faster than the original Ivy Bridge system. Just imagine how much more work you could get done with an overnight turnaround instead of days!

Is this typical of the performance gains with GPUs? Performance gains for applications span a wide range, but these results are not unusual.

***9.6.2 Reducing energy use with GPUs***

Energy costs are becoming increasingly important for parallel applications. Where once the energy consumption of computers was not a concern, now the energy costs of running the computers, storage disks, and cooling system are fast approaching the same levels as the hardware purchase costs over the lifetime of the computing system.

In the race to Exascale computing, one of the biggest challenges is keeping the power requirements for the Exascale system to around 20 MW. For comparison, this is about enough power to supply 13,000 homes. There simply isn’t enough installed power in data centers to go much beyond that. At the other end of the spectrum, smart phones, tablets, and laptops run on batteries with a limited amount of available energy (between charges). On these devices, it can be beneficial to focus on reducing energy costs for a computation to stretch out the battery life. Fortunately, aggressive efforts to reduce energy usage have kept the rate of an increase in power demands reasonable.

Accurately calculating the energy costs of an application is challenging without direct measurements of power usage. However, you can get a higher bound on the cost by multiplying the manufacturer’s thermal design power (TDP) by the run time of the application and the number of processors used. TDP is the rate at which energy is expended under typical operational loads. The energy consumption for your application can be estimated using the formula

Energy = (N Processors) × (RWatts/Processor) × (T hours)

where Energy is the energy consumption, N is the number of processors, R is the TDP, and T is the application’s run time. Let’s compare a GPU-based system to a roughly equivalent CPU system (table 9.6). We’ll assume our application is memory bound, so we’ll calculate the costs and energy consumption for a 10 TB/sec system.

**Table 9.6 Designing a 10 TB/s bandwidth GPU and CPU system.**

| ** **            | **NVIDIA V100**           | **Intel CPU Skylake Gold 6152** |
|------------------|---------------------------|---------------------------------|
| Number           | 12 GPUs                   | 45 processors (CPUs)            |
| Bandwidth        | 12 × 850 GB/s = 10.2 TB/s | 45 × 224 GB/s = 10.1 TB/s       |
| Cost             | 12 × \$11,000 = \$132,000 | 45 × \$3,800 = \$171,000        |
| Power            | 300 watt per GPU          | 140 watt per CPU                |
| Energy for 1 day | 86.4 kWhrs                | 151.2 kWhrs                     |

To calculate the energy costs for one day, we take the specifications from table 9.6 and calculate the nominal energy costs.

> **Example: TDP for Intel’s 22 core Xeon Gold 6152 Processor**

> Intel’s 22 core Xeon Gold 6152 Processor has a TDP of 140 W. Suppose that your application uses 15 of these processors for 24 hours to run to completion. The estimated energy usage for your application is

> Energy = (45 Processors) × (140 W/Processors) × (24 hrs) = 151.2 kWhrs

> This is a significant amount of energy! Your energy consumption for this calculation is enough to power seven homes for the same 24 hours.

In general, GPUs have a higher TDP than CPUs (300 watts vs. 140 watts from table 9.6) so they consume energy at a higher rate. But GPUs can potentially reduce run time or require only a few to run your calculation. The same formula can be used as before, where N is now seen as the number of GPUs.

> **Example: TDP for a multi-GPU platform**

> Suppose that you’ve ported your application to a multi-GPU platform. You can now run your application on four NVIDIA Tesla V100 GPUs in 24 hrs. NVIDIA’s Tesla V100 GPU has a maximum TDP of 300 W. The estimated energy usage for your application is

> Energy = (12 GPUs) × (300 W/GPUs) × (24 hrs) = 86.4 kWhrs

> In this example, the GPU accelerated application runs at a much lower energy cost compared to the CPU-only version. Note that in this case, even though the time to solution remains the same, the energy expense is cut by about 40%! We also see a 20% reduction in initial hardware costs, but we haven’t accounted for the host CPU expense for the GPUs.

Now we can see there is great potential for a GPU system, but the nominal values that we used might be quite a ways from reality. We could further refine this estimate by getting measured performance and energy draws for our algorithm.

Achieving a reduction in energy cost through GPU accelerator devices requires that the application expose sufficient parallelism and that the device’s resources are efficiently utilized. In the hypothetical example, we were able to reduce the energy usage in half when running on 12 GPUs for the same amount of time it takes to execute on 45 fully subscribed CPU processors. The formula for energy consumption also suggests other strategies for reducing energy costs. We’ll discuss these strategies in a bit, but it’s important to note that, in general, a GPU consumes more energy than a CPU per unit time. We’ll start by examining the energy consumption between a single CPU processor and a single GPU.

> **Example: Monitoring GPU power consumption over application lifetime**

> Let’s go back to the CloverLeaf problem that we ran earlier on the V100 GPU. We used the nvidia-smi (NVIDIA System Management Interface) tool to collect performance metrics for the run, including power and GPU utilization. To do this, we ran the following command before running our application:

> `nvidia-smi dmon -i 0 --select pumct -c 65 --options DT\`  
> `  --filename gpu_monitoring.log &`

> The following table shows the options for the nvidia-smi command.

>   

> The shortened data output to the file looks like

> `Time      pwr gtemp mtemp   sm  mem enc dec    fb bar1 mclk pclk rxpci txpci`  
> `HH:MM:SS    W     C     C    %    %   %   %    MB   MB  MHz  MHz  MB/s  MB/s`  
> `21:36:47   64    43    41   24   28   0   0     0    0  877 1530     0     0`  
> `21:36:48  176    44    44   96  100   0   0 11181    0  877 1530     0     0`  
> `21:36:49  174    45    45  100  100   0   0 11181    0  877 1530     0     0`  
> `... `

Listing 9.3 shows how to plot the power and utilization for the V100 GPU.

**Listing 9.3 Plotting the power and utilization data from nvidia-smi**

> `power_plot.py`  
> `1 import matplotlib.pyplot as plt`  
> `2 import numpy as np`  
> `3 import re`  
> `4 from scipy.integrate import simps`  
> `5`  
> `6 fig, ax1 = plt.subplots()`  
> `7`  
> `8 gpu_power = []`  
> `9 gpu_time = []`  
> `10 sm_utilization = []`  
> `11`  
> `12 # Collect the data from the file, ignore empty lines`  
> `13 data = open('gpu_monitoring.log', 'r')`  
> `14`  
> `15 count = 0`  
> `16 energy = 0.0`  
> `17 nominal_energy = 0.0`  
> `18`  
> `19 for line in data:`  
> `20     if re.match('^ 2019',line):`  
> `21         line = line.rstrip("\n")`  
> `22         dummy, dummy, dummy, gpu_power_in, dummy, dummy,  sm_utilization_in, dummy,`  
> `             dummy, dummy, dummy, dummy, dummy, dummy, dummy, dummy = line.split()`  
> `23         if (float(sm_utilization_in) > 80):`  
> `24           gpu_power.append(float(gpu_power_in))`  
> `25           sm_utilization.append(float(sm_utilization_in))`  
> `26           gpu_time.append(count)`  
> `27           count = count + 1`  
> `28           energy = energy + float(gpu_power_in)*1.0              `❶  
> `29           nominal_energy = nominal_energy + float(300.0)*1.0     `❷  
> `30`  
> `31 print(energy, "watts-secs", simps(gpu_power, gpu_time))          `❸  
> `32 print(nominal_energy, "watts-secs", "  ratio ",energy/nominal_energy*100.0)                                 `❹  
> `33`  
> `34 ax1.plot(gpu_time, gpu_power, "o", linestyle='-', color='red')`  
> `35 ax1.fill_between(gpu_time, gpu_power, color='orange')`  
> `36 ax1.set_xlabel('Time (secs)',fontsize=16)`  
> `37 ax1.set_ylabel('Power Consumption (watts)',fontsize=16, color='red')`  
> `38 #ax1.set_title('GPU Power Consumption from nvidia-smi')`  
> `39`  
> `40 ax2 = ax1.twinx()  # instantiate a second axes that shares the same x-axis`  
> `41`  
> `42 ax2.plot(gpu_time, sm_utilization, "o", linestyle='-', color='green')`  
> `43 ax2.set_ylabel('GPU Utilization (%)',fontsize=16, color='green')`  
> `44`  
> `45 fig.tight_layout()`  
> `56 plt.savefig("power.pdf")`  
> `57 plt.savefig("power.svg")`  
> `58 plt.savefig("power.png", dpi=600)`  
> `59`  
> `60 plt.show()`

❶ Integrates power times time to get energy in watts/s

❷ Gets the energy usage based on nominal power specification

❸ Prints the calculated energy and uses the simps integration function from scipy

❹ Calculates the actual vs. nominal energy usage

Figure 9.11 shows the resulting plot. At the same time, we integrate the area under the curve to get the energy usage. Note that even with the utilization at 100%, the power rate is only about 61% of the nominal GPU power specification. At idle, the GPU power consumption is around 20% of the nominal amount. This shows that the real power usage rate for GPUs is significantly lower than estimates based on nominal specifications. CPUs also are lower than the nominal amount, but probably not by as great a percentage of their nominal rate.

**Figure 9.11 Power consumption for the CloverLeaf problem running on the V100. We integrate under the power curve to get 10.4 kJ for a run that lasted about 60 seconds. The rate of power consumption is about 61% of the nominal power specification for the V100 GPU.**

***WHEN WILL MULTI-GPU PLATFORMS SAVE YOU ENERGY?***

In general, parallel efficiency drops off as you add more CPUs or GPUs (remember Amdahl’s law from section 1.2?), and the cost for a computational job goes up. Sometimes, there are fixed costs (such as storage) associated with the overall run time of a job that are reduced if the job is finished sooner and the data can be transferred or deleted. The usual situation, however, is that you have a suite of jobs to run with a choice of how many processors for each job. The following example highlights the tradeoffs in this situation.

> **Example: Suite of parallel jobs to run**

> You have 100 jobs to run, roughly of the same type and length. You can run the jobs on either 20 processors or 40 processors. At 20 processors, the jobs take 10 hours each. The parallel efficiency in this processor range is about 80%. The cloud cluster you have access to has 200 processors. Let’s look at two scenarios.

> Case 1. Running 10 jobs at a time with 20 processors gives us this solution:

> Total Suite Run Time = 10 hrs × 100/10 = 100 hrs

> Case 2. Run 5 jobs at a time with 40 processors

> Increasing the number of processors to 40 drops the run time to 5 hrs if parallel efficiency is perfect. But it is only 80% efficient, so the run time is 6.25 hrs. How did we get this number? Assume that 20 processors is the base case. For doubling the number of processors, the parallel efficiency formula is

> P_(efficiency) = S/P_(mult) = 80%

> S is the speedup for the problem. The processor multiplier, P_(mult), is a factor 2. Solving for the speedup, we get

> S = 0.8 × P_(mult) = 0.8 × 2 = 1.6

> Now we use the speedup equation to calculate the new time, TN:

> S = T_(base)/T_(new)

> We use T_(base) instead of T_(serial) for this form of the speedup equation. Parallel efficiency often decreases as we add processors, so we want the relationship at this point on the efficiency curve. Solving for T_(new), we get

> T_(new) = T_(base)/S = 10/1.6 = 6.25 hrs

> With this run time for 40 processors, we can now calculate the total suite run time:

> Total Suite Time = 6.25 hrs × 100/5 = 125 hrs

> In summary, the scenario used in case 1 is much faster to accomplish the same amount of work.

This example shows that if we are optimizing the run time for a large suite of jobs, it is often better to use less parallelism. In contrast, if we are more concerned with the turnaround time for a single job, more processors will be better.

***9.6.3 Reduction in cloud computing costs with GPUs***

Cloud computing services from Google and Amazon let you match your workloads to a wide range of compute server types and demands.

- If your application is memory bound, you can use a GPU that has a lower flops-to-loads ratio at a lower cost.

- If you are more concerned with turnaround time, you can add more GPUs or CPUs.

- If your deadlines are less serious, you can use preemptible resources at a considerable reduction in cost.

As the cost of computing is more visible with cloud computing services, optimizing your application’s performance becomes a higher priority. Cloud computing has the advantage of giving you access to a wider variety of hardware than you can have on-site and more options to match the hardware to the workload.

***9.7 When to use GPUs***

GPUs are not general-purpose processors. They are most appropriate when the computation workload is similar to a graphics workload—lots of operations that are identical. There are some areas where GPUs still do not perform well, although with each iteration of the GPU hardware and software, some of these are addressed.

- Lack of parallelism—To paraphrase Spiderman, “With great power comes great need for parallelism.” If you don’t have the parallelism, GPUs can’t do a lot for you. This is the first law of GPGPU programming.

- Irregular memory access—CPUs also struggle with this. The massive parallelism of GPUs brings no benefit to this situation. This is the second law of GPGPU programming.

- Thread divergence—Threads on GPUs all execute on each and every branch. This is a characteristic of SIMD and SIMT architectures (see section 1.4). Small amounts of short branching are fine, but wildly different branch paths do poorly.

- Dynamic memory requirements—Memory allocation is done on the CPU, which severely limits algorithms that require memory sizes determined on the fly.

- Recursive algorithms—GPUs have limited stack memory resources, and suppliers often state that recursion is not supported. However, a limited amount of recursion has been demonstrated to work in the mesh-to-mesh remapping algorithms in section 5.5.2.

***9.8 Further explorations***

GPU architectures continue to evolve with each iteration of hardware design. We suggest that you continue to track the latest developments and innovations. At the outset, GPU architectures were first and foremost for graphics performance. But the market has broadened into machine learning and computation as well.

***9.8.1 Additional reading***

For a much more detailed discussion of STREAM Benchmark performance and how it varies across parallel programming languages, we refer you to the following paper:

T. Deakin, J. Price, et al., “Benchmarking the achievable memory bandwidth of many-core processors across diverse parallel programming models,” GPU-STREAM, v2.0 (2016). Paper presented at Performance Portable Programming models for Manycore or Accelerators (P^3MA) Workshop at ISC High Performance, Frankfurt, Germany.

A good resource on the roofline model for GPUs can be found at Lawrence Berkeley Lab. A good starting point is

Charlene Yang and Samuel Williams, “Performance Analysis of GPU-Accelerated Applications using the Roofline Model,” GPU Technology Conference (2019) available at <https://crd.lbl.gov/assets/Uploads/GTC19-Roofline.pdf>.

In this chapter, we presented a simplified view of the mixbench performance model by assuming simple application performance requirements. The following paper presents a more thorough procedure to account for the complications of real applications:

Elias Konstantinidis and Yiannis Cotronis, “A quantitative roofline model for GPU kernel performance estimation using micro-benchmarks and hardware metric profiling.” Journal of Parallel and Distributed Computing 107 (2017): 37-56.

***9.8.2 Exercises***

1.  Table 9.7 shows the achievable performance for a 1 flop/load application. Look up the current prices for the GPUs available on the market and fill in the last two columns to get the flop per dollar for each GPU. Which looks like the best value? If turnaround time for your application run time is the most important criterion, which GPU would be best to purchase?

    **Table 9.7 Achievable performance for a 1 flop/load application with various GPUs**

    [TABLE]

2.  Measure the stream bandwidth of your GPU or another selected GPU. How does it compare to the ones presented in the chapter?

3.  Use the likwid performance tool to get the CPU power requirements for the CloverLeaf application on a system where you have access to the power hardware counters.

***Summary***

- The CPU-GPU system can provide a powerful boost for many parallel applications. It should be considered for any application with a lot of parallel work.

- The GPU component of the system is in reality a general-purpose parallel accelerator. This means that it should be given the parallel part of the work.

- Data transfer over the PCI bus and memory bandwidth are the most common performance bottlenecks on CPU-GPU systems. Managing the data transfer and memory use is important for good performance.

- You’ll find a wide range of GPUs available for different workloads. Selecting the most suitable model will give the best price to performance ratio.

- GPUs can reduce time-to-solution and energy costs. This can be a prime motivator in porting an application to GPUs.
