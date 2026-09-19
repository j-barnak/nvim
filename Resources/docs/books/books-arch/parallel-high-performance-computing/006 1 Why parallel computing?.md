# 1 Why parallel computing?

***1 Why parallel computing?***

This chapter covers

- What parallel computing is and why it’s growing in importance
- Where parallelism exists in modern hardware
- Why the amount of application parallelism is important
- Software approaches to exploit parallelism

In today’s world, you’ll find many challenges requiring extensive and efficient use of computing resources. Most of the applications requiring performance traditionally are in the scientific domain. But artificial intelligence (AI) and machine learning applications are projected to become the predominant users of large-scale computing. Some examples of these applications include

- Modeling megafires to assist fire crews and to help the public

- Modeling tsunamis and storm surges from hurricanes (see chapter 13 for a simple tsunami model)

- Voice recognition for computer interfaces

- Modeling virus spread and vaccine development

- Modeling climatic conditions over decades and centuries

- Image recognition for driverless car technology

- Equipping emergency crews with running simulations of hazards such as flooding

- Reducing power consumption for mobile devices

With the techniques covered in this book, you will be able to handle larger problems and datasets, while also running simulations ten, a hundred, or even a thousand times faster. Typical applications leave much of the compute capability of today’s computers untapped. Parallel computing is the key to unlocking the potential of your computer resources. So what is parallel computing and how can you use it to supercharge your applications?

Parallel computing is the execution of many operations at a single instance in time. Fully exploiting parallel computing does not happen automatically. It requires some effort from the programmer. First, you must identify and expose the potential for parallelism in an application. Potential parallelism, or concurrency, means that you certify that it is safe to conduct operations in any order as the system resources become available. And, with parallel computing, there is an additional requirement: these operations must occur at the same time. For this to happen, you must also properly leverage the resources to execute these operations simultaneously.

Parallel computing introduces new concerns that are not present in a serial world. We need to change our thought processes to adapt to the additional complexities of parallel execution, but with practice, this becomes second nature. This book begins your discovery in how to access the power of parallel computing.

Life presents numerous examples of parallel processing, and these instances often become the basis for computing strategies. Figure 1.1 shows a supermarket checkout line, where the goal is to have customers quickly pay for the items they want to purchase. This can be done by employing multiple cashiers to process, or check out, the customers one at a time. In this case, the skilled cashiers can more quickly execute the checkout process so customers leave faster. Another strategy is to employ many self-checkout stations and allow customers to execute the process on their own. This strategy requires fewer human resources from the supermarket and can open more lanes to process customers. Customers may not be able to check themselves out as efficiently as a trained cashier, but perhaps more customers can check out quickly due to increased parallelism resulting in shorter lines.

We solve computational problems by developing algorithms: a set of steps to achieve a desired result. In the supermarket analogy, the process of checking out is the algorithm. In this case, it includes unloading items from a basket, scanning the items to obtain a price, and paying for the items. This algorithm is sequential (or serial); it must follow this order. If there are hundreds of customers that need to execute this task, the algorithm for checking out many customers contains a parallelism that can be taken advantage of. Theoretically, there is no dependency between any two customers going through the checkout process. By using multiple checkout lines or self-checkout stations, supermarkets expose parallelism, thereby increasing the rate at which customers buy goods and leave the store. Each choice in how we implement this parallelism results in different costs and benefits.

**Figure 1.1 Everyday parallelism in supermarket checkout queues. The checkout cashiers (with caps) process their queue of customers (with baskets). On the left, one cashier processes four self-checkout lanes simultaneously. On the right, one cashier is required for each checkout lane. Each option impacts the supermarket’s costs and checkout rates.**

> > > **DEFINITION** Parallel computing is the practice of identifying and exposing parallelism in algorithms, expressing this in our software, and understanding the costs, benefits, and limitations of the chosen implementation.

In the end, parallel computing is about performance. This includes more than just speed, but also the size of the problem and energy efficiency. Our goal in this book is to give you an understanding of the breadth of the current parallel computing field and familiarize you with enough of the most commonly used languages, techniques, and tools so that you can tackle a parallel computing project with confidence. Important decisions about how to incorporate parallelism are often made at the outset of a project. A reasoned design is an important step toward success. Avoiding the design step can lead to problems much later. It is equally important to keep expectations realistic and to know both the available resources and the nature of the project.

Another goal of this chapter is to introduce the terminology used in parallel computing. One way to do that is to point you to the glossary in appendix C for a quick reference on terminology as you read this book. Because this field and the technology has grown incrementally, the use of many of the terms by those in the parallel community is oftentimes sloppy and imprecise. With the increased complexity of the hardware and of parallelism within applications, it’s important that we establish a clear, unambiguous use of terminology from the start.

Welcome to the world of parallel computing! As you delve deeper, the techniques and approaches become more natural, and you’ll find its power captivating. Problems that you never thought to attempt become commonplace.

***1.1 Why should you learn about parallel computing?***

The future is parallel. The increase in serial performance has plateaued as processor designs have hit the limits of miniaturization, clock frequency, power, and even heat. Figure 1.2 shows the trends in clock frequency (the rate at which an instruction can be executed), power consumption, the number of computational cores (or cores for short), and hardware performance over time for commodity processors.

**Figure 1.2 Single thread performance, CPU clock frequency (MHz), CPU power consumption (watts), and the number of CPU cores from 1970 to 2018. The parallel computing era begins about 2005, when the core count in CPU chips begins to rise, while the clock frequency and power consumption plateaus, yet performance steadily increases (Horowitz et al. and Rupp,** [**https://github.com/karlrupp/microprocessor-trend-data**](https://github.com/karlrupp/microprocessor-trend-data)**).**

In 2005, the number of cores abruptly increased from a single core to multiple cores. At the same time, clock frequency and power consumption flattened out. Theoretical performance steadily increased because performance is proportional to the product of clock frequency and the number of cores. This shift towards increasing the core count rather than the clock speed indicates that achieving the most ideal performance of a central processing unit (CPU) is only available through parallel computing.

Modern consumer-grade computing hardware comes equipped with multiple central processing units (CPUs) and/or graphics processing units (GPUs) that process multiple instruction sets simultaneously. These smaller systems often rival the computing power of supercomputers of two decades ago. Making full use of compute resources (on laptops, workstations, smart phones, and so forth) requires you, the programmer, to have a working knowledge of the tools available for writing parallel applications. You must also understand the hardware features that boost parallelism.

Because there are many different parallel hardware features, this presents new complexities to the programmer. One of these features is hyperthreading, introduced by Intel. Having two instruction queues interleaving work to the hardware logic units allows a single physical core to appear as two cores to the operating system (OS). Vector processors are another hardware feature that began appearing in commodity processors in about 2000. These execute multiple instructions at once. The width in bits of the vector processor (also called a vector unit) specifies the number of instructions to execute simultaneously. Thus, a 256 bit-wide vector unit can execute four 64-bit (doubles) or eight 32-bit (single-precision) instructions at one time.

> **Example**

> Let’s take a 16-core CPU with hyperthreading and a 256 bit-wide vector unit, commonly found in home desktops. A serial program using a single core and no vectorization only uses 0.8% of the theoretical processing capability of this processor! The calculation is

> 16 cores × 2 hyperthreads × (256 bit-wide vector unit)/(64-bit double) = 128-way parallelism

> where 1 serial path/128 parallel paths = .008 or 0.8%. The following figure shows that this is a small fraction of the total CPU processing power.

>   

> **A serial application only accesses 0.8% of the processing power of a 16-core CPU.**

> Calculating theoretical and realistic expectations for serial and parallel performance as shown in this example is an important skill. We’ll discuss this in more depth in chapter 3.

Some improvement in software development tools has helped to add parallelism to our toolkits, and currently, the research community is doing more, but it is still a long way from addressing the performance gap. This puts a lot of the burden on us, the software developers, to get the most from a new generation of processors.

Unfortunately, software developers have lagged in adapting to this fundamental change in computing power. Further, transitioning current applications to make use of modern parallel architectures can be daunting due to the explosion of new programming languages and application programming interfaces (APIs). But a good working knowledge of your application, an ability to see and expose parallelism, and a solid understanding of the tools available can result in substantial benefits. Exactly what kind of benefits would applications see? Let’s take a closer look.

***1.1.1 What are the potential benefits of parallel computing?***

Parallel computing can reduce your time to solution, increase the energy efficiency in your application, and enable you to tackle larger problems on currently existing hardware. Today, parallel computing no longer is the sole domain of the largest computing systems. The technology is now present in everyone’s desktop or laptop, and even on handheld devices. This makes it possible for every software developer to create parallel software on their local systems, thereby greatly expanding the opportunity for new applications.

Cutting edge research from both industry and academia reveals new areas for parallel computing as interest broadens from scientific computing into machine learning, big data, computer graphics, and consumer applications. The emergence of new technologies such as self-driving cars, computer vision, voice recognition, and AI requires large computational capabilities both within the consumer device and in the development sphere, where massive training datasets must be consumed and processed. And in scientific computing, which has long been the exclusive domain of parallel computing, there are also new, exciting possibilities. The proliferation of remote sensors and handheld devices that can feed data into larger, more realistic computations to better inform decision-making around natural and man-made disasters allows for more extensive data.

It must be remembered that parallel computing itself is not the goal. Rather, the goals are what results from parallel computing: reducing run time, performing larger calculations, or decreasing energy consumption.

***FASTER RUN TIME WITH MORE COMPUTE CORES***

Reduction of an application’s run time, or the speedup, is often thought to be the primary goal of parallel computing. Indeed, this is usually its biggest impact. Parallel computing can speed up intensive calculations, multimedia processing, and big data operations, whether your applications take days or even weeks to process or the results are needed in real-time now.

In the past, the programmer would spend greater efforts on serial optimization to squeeze out a few percentage improvements. Now, there is the potential for orders of magnitude of improvement with multiple avenues to choose from. This creates a new problem in exploring the possible parallel paradigms—more opportunities than programming manpower. But, a thorough knowledge of your application and an awareness of parallelism opportunities can lead you down a clearer path towards reducing your application’s run time.

***LARGER PROBLEM SIZES WITH MORE COMPUTE NODES***

By exposing parallelism in your application, you can scale up your problem’s size to dimensions that were out of reach with a serial application. This is because the amount of compute resources dictates what can be done, and exposing parallelism permits you to operate on larger resources, presenting opportunities that were never considered before. The larger sizes are enabled by greater amounts of main memory, disk storage, bandwidth over networks and to disk, and CPUs. In analogy with the supermarket as mentioned earlier, exposing parallelism is equivalent to employing more cashiers or opening more self-checkout lanes to handle a larger and growing number of customers.

***ENERGY EFFICIENCY BY DOING MORE WITH LESS***

One of the new impact areas of parallel computing is energy efficiency. With the emergence of parallel resources in handheld devices, parallelism can speed up applications. This allows the device to return to sleep mode sooner and permits the use of slower, but more parallel processors that consume less power. Thus, moving heavy-weight multimedia applications to run on GPUs can have a more dramatic effect on energy efficiency while also resulting in vastly improved performance. The net result of employing parallelism reduces power consumption and extends battery life, which is a strong competitive advantage in this market niche.

Another area where energy efficiency is important is with remote sensors, network devices, and operational field-deployed devices, such as remote weather stations. Often, without large power supplies, these devices must be able to function in small packages with few resources. Parallelism expands what can be done on these devices and offloads the work from the central computing system in a growing trend that is called edge compute. Moving the computation to the very edge of the network enables processing at the source of the data, condensing it into a smaller result set that can be more easily sent over the network.

Accurately calculating the energy costs of an application is challenging without direct measurements of power usage. However, you can estimate the cost by multiplying the manufacturer’s thermal design power by the application’s run time and the number of processors used. Thermal design power is the rate at which energy is expended under typical operational loads. The energy consumption for your application can be estimated using the formula

P = (N Processors) × (R Watts/Processors) × (T hours)

where P is the energy consumption, N is the number of processors, R is the thermal design power, and T is the application run time.

> **Example**

> Intel’s 16-core Xeon E5-4660 processor has a thermal design power of 120 W. Suppose that your application uses 20 of these processors for 24 hours to run to completion. The estimated energy usage for your application is

> P = (20 Processors) × (120 W/Processors) × (24 hours) = 57.60 kWhrs

> In general, GPUs have a higher thermal design power than modern CPUs, but can potentially reduce run time or require only a few GPUs to obtain the same result. The same formula can be used as before, where N is now seen as the number of GPUs.

> **Example**

> Suppose that you’ve ported your application to a multi-GPU platform. You can now run your application on four NVIDIA Tesla V100 GPUs in 24 hrs! NVIDIA’s Tesla V100 GPU has a maximum thermal design power of 300 W. The estimated energy usage for your application is

> P = (4 GPUs) × (300 W/GPUs) × (24 hrs) = 28.80 kWhrs

> In this example, the GPU accelerated application runs at half the energy cost as the CPU-only version. Note that, in this case, even though the time to solution remains the same, the energy expense is cut in half!

Achieving a reduction in energy cost through accelerator devices like GPUs requires that the application has sufficient parallelism that can be exposed. This permits the efficient use of the resources on the device.

***PARALLEL COMPUTING CAN REDUCE COSTS***

Actual monetary cost is becoming a more visible concern for software developer teams, software users, and researchers alike. As the size of applications and systems grows, we need to perform a cost-benefit analysis on the resources available. For example, with the next large High Performance Computing (HPC) systems, the power costs are projected to be three times the cost of the hardware acquisition.

Usage costs have also promoted cloud computing as an alternative, which is being increasingly adopted across academia, start-ups, and industries. In general, cloud providers bill by the type and quantity of resources used and the amount of time spent using these. Although GPUs are generally more expensive than CPUs per unit time, some applications can leverage GPU accelerators such that there are sufficient reductions in run time relative to the CPU expense to yield lower costs.

***1.1.2 Parallel computing cautions***

Parallel computing is not a panacea. Many applications are neither large enough or require enough run time to need parallel computing. Some may not even have enough inherent parallelism to exploit. Also, transitioning applications to leverage multi-core and many-core (GPU) hardware requires a dedicated effort that can temporarily shift attention away from direct research or product goals. The investment of time and effort must first be deemed worthwhile. It is always more important that the application runs and generates the desired result before making it fast and scaling it up to larger problems.

We strongly recommend that you start your parallel computing project with a plan. It’s important to know what options are available for accelerating the application, then select the most appropriate for your project. After that, it is crucial to have a reasonable estimate of the effort involved and the potential payoffs (in terms of dollar cost, energy consumption, time to solution, and other metrics that can be important). In this chapter, we begin to give you the knowledge and skills to make decisions on parallel computing projects up front.

***1.2 The fundamental laws of parallel computing***

In serial computing, all operations speed up as the clock frequency increases. In contrast, with parallel computing, we need to give some thought and modify our applications to fully exploit parallel hardware. Why is the amount of parallelism important? To understand this, let’s take a look at the parallel computing laws.

***1.2.1 The limit to parallel computing: Amdahl’s Law***

We need a way to calculate the potential speedup of a calculation based on the amount of the code that is parallel. This can be done using Amdahl’s Law, proposed by Gene Amdahl in 1967. This law describes the speedup of a fixed-size problem as the processors increase. The following equation shows this, where P is the parallel fraction of the code, S is the serial fraction, which means that P + S = 1, and N is the number of processors:

Amdahl’s Law highlights that no matter how fast we make the parallel part of the code, we will always be limited by the serial portion. Figure 1.3 visualizes this limitation. This scaling of a fixed-size problem is referred to as strong scaling.

**Figure 1.3 Speedup for a fixed-size problem according to Amdahl’s Law is shown as a function of the number of processors. Lines show ideal speedup when 100% of an algorithm is parallelized, and for 90%, 75%, and 50%. Amdahl’s Law states that speedup is limited by the fractions of code that remain serial.**

> > > **DEFINITION** Strong scaling represents the time to solution with respect to the number of processors for a fixed total size.

***1.2.2 Breaking through the parallel limit: Gustafson-Barsis’s Law***

Gustafson and Barsis pointed out in 1988 that parallel code runs should increase the size of the problem as more processors are added. This can give us an alternate way to calculate the potential speedup of our application. If the size of the problem grows proportionally to the number of processors, the speedup is now expressed as

SpeedUp(N ) = N - S \* (N - 1)

where N is the number of processors, and S is the serial fraction as before. The result is that a larger problem can be solved in the same time by using more processors. This provides additional opportunities to exploit parallelism. Indeed, growing the size of the problem with the number of processors makes sense because the application user wants to benefit from more than just the power of the additional processor and wants to use the additional memory. The run-time scaling for this scenario, shown in figure 1.4, is called weak scaling.

**Figure 1.4 Speedup for when the size of a problem grows with the number of available processors according to Gustafson-Barsis’s Law is shown as a function of the number of processors. Lines show ideal speedup when 100% of an algorithm is parallelized, and for 90%, 75%, and 50%.**

> > > **DEFINITION** Weak scaling represents the time to solution with respect to the number of processors for a fixed-sized problem per processor.

Figure 1.5 shows the difference between strong and weak scaling in a visual representation. The weak scaling argument that the mesh size should stay constant on each processor makes good use of the resources of the additional processor. The strong scaling perspective is primarily concerned with speedup of the calculation. In practice, both strong scaling and weak scaling are important because these address different user scenarios.

**Figure 1.5 Strong scaling keeps the same overall size of a problem and splits it across additional processors. In weak scaling, the size of the mesh stays the same for each processor and the total size increases.**

The term scalability is often used to refer to whether more parallelism can be added in either the hardware or the software and whether there is an overall limit to how much improvement can occur. While the traditional focus is on the run-time scaling, we will make the argument that memory scaling is often more important.

Figure 1.6 shows an application with limited memory scalability. A replicated array (R) is a dataset that is duplicated across all the processors. A distributed array (D) is partitioned and split across the processors. For example, in a game simulation, 100 characters can be distributed across 4 processors with 25 characters on each processor. But the map of the game board might be copied to every processor. In figure 1.6, the replicated array is duplicated across the mesh. Because this figure is for weak scaling, the problem size grows as the number of processors increases. For 4 processors, the array is 4 times as large on each processor. As the number of processors and the size of the problem grows, soon there is not enough memory on a processor for the job to run. Limited run-time scaling means the job runs slowly; limited memory scaling means the job can’t run at all. It is also the case that if the application’s memory can be distributed, the run time usually scales as well. The reverse, however, is not necessarily true.

**Figure 1.6 Distributed arrays stay the same size as the problem and number of processors doubles (weak scaling). But replicated (copied) arrays need all the data on each processor, and memory grows rapidly with the number of processors. Even if the run time weakly scales (stays constant), the memory requirements limit scalability.**

One view of a computationally intensive job is that every byte of memory gets touched in every cycle of processing, and run time is a function of memory size. Reducing memory size will necessarily reduce run time. The initial focus in parallelism should thus be to reduce the memory size as the number of processors grows.

***1.3 How does parallel computing work?***

Parallel computing requires combining an understanding of hardware, software, and parallelism to develop an application. It is more than just message passing or threading. Current hardware and software give many different options to bring parallelization to your application. Some of these options can be combined to yield even greater efficiency and speedup.

It is important to have an understanding of the parallelization in your application and the way different hardware components allow you to expose it. Further, developers need to recognize that between your source code and the hardware, your application must traverse additional layers, including a compiler and an OS (figure 1.7).

**Figure 1.7 Parallelization is expressed in an application software layer that gets mapped to the computer hardware through the compiler and the OS.**

As a developer, you are responsible for the application software layer, which includes your source code. In the source code, you make choices about the programming language and parallel software interfaces you use to leverage the underlying hardware. Additionally, you decide how to break up your work into parallel units. A compiler is designed to translate your source code into a form the hardware can execute. With these instructions at hand, an OS manages executing these on the computer hardware.

We will show you with an example how to introduce parallelization to an algorithm through a prototype application. This process takes place in the application software layer but requires an understanding of computer hardware. For now, we’ll refrain from discussing the choice in compiler and OS. We will incrementally add each layer of parallelization so that you can see how this works. With each parallel strategy, we will explain how the available hardware influences the choices that are made. The purpose in doing this is to demonstrate how hardware features influence the parallel strategies. We categorize the parallel approaches a developer can take into

- Process-based parallelization

- Thread-based parallelization

- Vectorization

- Stream processing

Following the example, we will introduce a model to help you think about modern hardware. This model breaks down modern compute hardware into individual components and the variety of compute devices. A simplified view of memory is included in this chapter. A more detailed look at the memory hierarchy is presented in chapters 3 and 4. Finally, we will discuss in more detail the application and software layers.

As mentioned, we categorize the parallel approaches a developer can take into process-based parallelization, thread-based parallelization, vectorization, and stream processing. Parallelization based on individual processes with their own memory spaces can be distributed memory on different nodes of a computer or within a node. Stream processing is generally associated with GPUs. The model for modern hardware and application software will help you better understand how to plan to port your application to current parallel hardware.

***1.3.1 Walking through a sample application***

For this introduction to parallelization, we will look at a data parallel approach. This is one of the most common parallel computing application strategies. We’ll perform the computation on a spatial mesh composed of a regular two-dimensional (2D) grid of rectangular elements or cells. The steps (summarized here and described in detail later) to create the spatial mesh and prepare for the calculation are

1.  Discretize (break up) the problem into smaller cells or elements

2.  Define a computational kernel (operation) to conduct on each element of the mesh

3.  Add the following layers of parallelization on CPUs and GPUs to perform the calculation:

    - Vectorization—Work on more than one unit of data at a time

    - Threads—Deploy more than one compute pathway to engage more processing cores

    - Processes—Separate program instances to spread out the calculation into separate memory spaces

    - Off-loading the calculation to GPUs—Send the data to the graphics processor to calculate

We start with a 2D problem domain of a region of space. For purposes of illustration, we will use a 2D image of the Krakatau volcano (figure 1.8) as our example. The goal of our calculation could be to model the volcanic plume, the resulting tsunami, or the early detection of a volcanic eruption using machine learning. For all of these options, calculation speed is critical if we want real-time results to inform our decisions.

**Figure 1.8 An example 2D spatial domain for a numerical simulation. Numerical simulations typically involve stencil operations (see figure 1.11) or large matrix-vector systems. These types of operations are often used in fluids modeling to yield predictions of tsunami arrival times, weather forecasts, smoke plume spreading, and other processes necessary for informed decisions.**

***STEP 1: DISCRETIZE THE PROBLEM INTO SMALLER CELLS OR ELEMENTS***

For any detailed calculation, we must first break up the domain of the problem into smaller pieces (figure 1.9), a process that is called discretization. In image processing, this is often just the pixels in a bitmap image. For a computational domain, these are called cells or elements. The collection of cells or elements form a computational mesh that covers the spatial region for the simulation. Data values for each cell might be integers, floats, or doubles.

**Figure 1.9 The domain is discretized into cells. For each cell in the computational domain, properties such as wave height, fluid velocity, or smoke density are solved for according to physical laws. Ultimately, a stencil operation or a matrix-vector system represents this discrete scheme.**

***STEP 2: DEFINE A COMPUTATIONAL KERNEL, OR OPERATION, TO CONDUCT ON EACH ELEMENT OF THE MESH***

The calculations on this discretized data are often some form of a stencil operation, so-called because it involves a pattern of adjacent cells to calculate the new value for each cell. This can be an average (a blur operation, which blurs the image or makes it fuzzier), a gradient (edge-detection, which sharpens the edges in the image), or another more complex operation associated with solving physical systems described by partial differential equations (PDEs). Figure 1.10 shows a stencil operation as a five-point stencil that performs a blur operation by using a weighted average of the stencil values.

**Figure 1.10 A five-point stencil operator as a cross pattern on the computational mesh. The data marked by the stencil are read in the operation and stored in the center cell. This pattern is repeated for every cell. The blur operator, one of the simpler stencil operators, is a weighted sum of the five points marked with the large dots and updates a value at the central point of the stencil. This type of operation is done for smoothing operations or wave propagation numerical simulations.**

But what are these partial differential equations? Let’s go back to our example and imagine this time it is a color image composed of separate red, green, and blue arrays to make an RGB color model. The term “partial” here means that there is more than one variable and that we are separating out the change of red with space and time from that of green and blue. Then we carry out the blur operator separately on each of these colors.

There is one more requirement: we need to apply a rate of change with time and space. In other words, the red would spread at one rate and green and blue at others. This could be to produce a special effect on an image, or it can describe how real colors bleed and merge in a photographic image during development. In the scientific world, instead of red, green, and blue, we might have mass and x and y velocity. With the addition of a little more physics, we might have the motion of a wave or an ash plume.

***STEP 3: VECTORIZATION TO WORK ON MORE THAN ONE UNIT OF DATA AT A TIME***

We start introducing parallelization by looking at vectorization. What is vectorization? Some processors have the ability to operate on more than one piece of data at a time; a capability referred to as vector operations. The shaded blocks in figure 1.11 illustrate how multiple data values are operated on simultaneously in a vector unit in a processor with one instruction in one clock cycle.

**Figure 1.11 A special vector operation is conducted on four doubles. This operation can be executed in a single clock cycle with little additional energy costs to the serial operation.**

***STEP 4: THREADS TO DEPLOY MORE THAN ONE COMPUTE PATHWAY TO ENGAGE MORE PROCESSING CORES***

Because most CPUs today have at least four processing cores, we use threading to operate the cores simultaneously across four rows at a time. Figure 1.12 shows this process.

**Figure 1.12 Four threads process four rows of vector units simultaneously.**

***STEP 5: PROCESSES TO SPREAD OUT THE CALCULATION TO SEPARATE MEMORY SPACES***

We can further split the work between processors on two desktops, often called nodes in parallel processing. When the work is split across nodes, the memory spaces for each node are distinct and separate. This is indicated by putting a gap between the rows as in figure 1.13.

**Figure 1.13 This algorithm can be parallelized further by distributing the 4×4 blocks among distinct processes. Each process uses four threads, each handling a four-node-wide vector unit in a single clock cycle. Additional white space in the figure illustrates the process boundaries.**

Even for this fairly modest hardware scenario, there is a potential speedup of 32x. This is shown by the following:

2 desktops (nodes) × 4 cores × (256 bit-wide vector unit)/(64-bit double) = 32x potential speedup

If we look at a high-end cluster with 16 nodes, 36 cores per node, and a 512-bit vector processor, the potential theoretical speedup is 4,608 times faster than a serial process:

16 nodes × 36 cores × (512 bit-wide vector unit)/(64-bit double) = 4,608x potential speedup

***STEP 6: OFF-LOADING THE CALCULATION TO GPUS***

The GPU is another hardware resource for supercharging parallelization. With GPUs, we can harness lots of streaming multiprocessors for work. For example, figure 1.14 shows how the work can be split up separately into 8x8 tiles. Using the hardware specifications for the NVIDIA Volta GPU, these tiles can be operated on by 32 double-precision cores spread out over 84 streaming multiprocessors, giving us a total of 2,688 double-precision cores that work simultaneously. If we have one GPU per node in a 16-node cluster, each with a 2,688 double-precision streaming multiprocessor, this is a 43,008-way parallelization from 16 GPUs.

**Figure 1.14 On a GPU, the vector length is much larger than on a CPU. Here, 8×8 tiles are distributed across GPU work groups.**

These are impressive numbers, but at this point, we must temper expectations by acknowledging that actual speedup falls far short of this full potential. Our challenge now becomes organizing such extreme and disparate layers of parallelization to obtain as much speedup as possible.

For this high-level application walk-through, we left out a lot of important details, which we will cover in later chapters. But even this nominal level of detail highlights some of the strategies for exposing parallelization of an algorithm. To be able to develop similar strategies for other problems, an understanding of modern hardware and software is necessary. We now dive deeper into the current hardware and software models. These conceptual models are simplified representations of the diverse real-world hardware to avoid complexity and maintain generality over quickly evolving systems.

***1.3.2 A hardware model for today’s heterogeneous parallel systems***

To build a basic understanding of how parallel computing works, we’ll explain the components in today’s hardware. To begin, Dynamic Random Access Memory, called DRAM, stores information or data. A computational core, or core for short, performs arithmetic operations (add, subtract, multiply, divide), evaluates logical statements, and loads and stores data from DRAM. When an operation is performed on data, the instructions and data are loaded from memory onto the core, operated on, and stored back into memory. Modern CPUs, often called processors, are outfitted with many cores capable of executing these operations in parallel. It is also becoming common to find systems outfitted with accelerator hardware, like GPUs. GPUs are equipped with thousands of cores and a memory space that is separate from the CPU’s DRAM.

A combination of a processor (or two), DRAM, and an accelerator compose a compute node, which can be referred to in the context of a single home desktop or a “rack” in a supercomputer. Compute nodes can be connected to each other with one or more networks, sometimes called an interconnect. Conceptually, a node runs a single instance of the OS that manages and controls all of the hardware resources. As hardware is becoming more complex and heterogeneous, we’ll start with simplified models of the system’s components so that each is more obvious.

***DISTRIBUTED MEMORY ARCHITECTURE: A CROSS-NODE PARALLEL METHOD***

One of the first and most scalable approaches to parallel computing is the distributed memory cluster (figure 1.15). Each CPU has its own local memory composed of DRAM and is connected to other CPUs by a communication network. Good scalability of distributed memory clusters arises from its seemingly limitless ability to incorporate more nodes.

**Figure 1.15 The distributed memory architecture links nodes composed of separate memory spaces. These nodes can be workstations or racks.**

This architecture also provides some memory locality by dividing the total addressable memory into smaller subspaces for each node, which makes accessing memory off-node clearly different than on-node. This forces the programmer to explicitly access different memory regions. The disadvantage of this is that the programmer must manage the partitioning of the memory spaces at the outset of the application.

***SHARED MEMORY ARCHITECTURE: AN ON-NODE PARALLEL METHOD***

An alternative approach connects the two CPUs directly to the same shared memory (figure 1.16). The strength of this approach is that the processors share the same address space, which simplifies programming. But this introduces potential memory conflicts, resulting in correctness and performance issues. Synchronizing memory access and values between CPUs or the processing cores on a multi-core CPU is complicated and expensive.

**Figure 1.16 The shared memory architecture provides parallelization within a node.**

The addition of more CPUs and processing cores does not increase the amount of memory available to the application. This and the synchronization costs limit the scalability of the shared memory architecture.

***VECTOR UNITS: MULTIPLE OPERATIONS WITH ONE INSTRUCTION***

Why not just increase the clock frequency for the processor to get greater throughput as done in the past? The biggest limitation in increasing CPU clock frequencies is that it requires more power and produces more heat. Whether it is an HPC supercomputing center with limits on installed power lines or your cell phone with limited battery capacity, devices today all have power limitations. This problem is called the power wall.

Rather than increasing the clock frequency, why not do more than one operation per cycle? This is the idea behind the resurgence of vectorization on many processors. It takes only a little more energy to do multiple operations in a vector unit, compared to a single operation (more formally called a scalar operation). With vectorization, we can process more data in a single clock cycle than with a serial process. There is little change to the power requirements for multiple operations (versus just one), and a reduction in execution time can lead to a decrease in energy consumption for an application. Much like a four-lane freeway that allows four cars to move simultaneously in comparison to a single lane road, the vector operation gives greater processing throughput. Indeed, the four pathways through the vector unit, shown in different shadings in figure 1.17, are commonly called lanes of a vector operation.

Most CPUs and GPUs have some capability for vectorization or equivalent operations. The amount of data processed in one clock cycle, the vector length, depends on the size of the vector units on the processor. Currently, the most commonly available vector length is 256-bits. If the discretized data are 64-bit doubles, then we can do four floating-point operations simultaneously as a vector operation. As figure 1.17 illustrates, vector hardware units load one block of data at a time, perform a single operation on the data simultaneously, and then store the result.

**Figure 1.17 Vector processing example with four array elements operated on simultaneously**

***ACCELERATOR DEVICE: A SPECIAL-PURPOSE ADD-ON PROCESSOR***

An accelerator device is a discrete piece of hardware designed for executing specific tasks at a fast rate. The most common accelerator device is the GPU. When used for computation, this device is sometimes referred to as a general-purpose graphics processing unit (GPGPU). The GPU contains many small processing cores, called streaming multiprocessors (SMs). Although simpler than a CPU core, SMs provide a massive amount of processing power. Usually, you’ll find a small integrated GPU on the CPU.

Most modern computers also have a separate, discrete GPU connected to the CPU by the Peripheral Component Interface (PCI) bus (figure 1.18). This bus introduces a communication cost for data and instructions, but the discrete card is often more powerful than an integrated unit. In high-end systems, for example, NVIDIA uses NVLink and AMD Radeon uses their Infinity Fabric to reduce data communication costs, but this cost still is substantial. We will discuss the interesting GPU architecture more in chapters 9-12.

**Figure 1.18 GPUs come in two varieties: integrated and discrete. Discrete or dedicated GPUs typically have a large number of streaming multiprocessors and their own DRAM. Accessing data on a discrete GPU requires communication over a PCI bus.**

***GENERAL HETEROGENEOUS PARALLEL ARCHITECTURE MODEL***

Now let’s combine all of these different hardware architectures into one model (figure 1.19). Two nodes, each with two CPUs, share the same DRAM memory. Each CPU is a dual-core processor with an integrated GPU. A discrete GPU on the PCI bus also attaches to one of the CPUs. Though the CPUs share main memory, these are commonly in different Non-Uniform Memory Access (NUMA) regions. This means that accessing the second CPU’s memory is more expensive than getting at it’s own memory.

**Figure 1.19 A general heterogeneous parallel architecture model consisting of two nodes connected by a network. Each node has a multi-core CPU with an integrated and discrete GPU and some memory (DRAM). Modern compute hardware normally has some arrangement of these components.**

Throughout this hardware discussion, we have presented a simplified model of the memory hierarchy, showing just DRAM or main memory. We’ve shown a cache in the combined model (figure 1.19), but no detail on its composition or how it functions. We reserve our discussion of the complexities of memory management, including multiple levels of cache, for chapter 3. In this section, we simply presented a model for today’s hardware to help you identify the available components so that you can select the parallel strategy best suited for your application and hardware choices.

***1.3.3 The application/software model for today’s heterogeneous parallel systems***

The software model for parallel computing is necessarily motivated by the underlying hardware but is nonetheless distinct from it. The OS provides the interface between the two. Parallel operations do not spring to life on their own; rather, source code must indicate how to parallelize work by spawning processes or threads; offloading data, work, and instructions to a compute device; or operating on blocks of data at a time. The programmer must first expose the parallelization, determine the best technique to operate in parallel, and then explicitly direct its operation in a safe, correct, and efficient manner. The following methods are the most common techniques for parallelization, then we’ll go through each of these in detail:

- Process-based parallelization—Message passing

- Thread-based parallelization—Shared data via memory

- Vectorization—Multiple operations with one instruction

- Stream processing—Through specialized processors

***PROCESS-BASED PARALLELIZATION: MESSAGE PASSING***

The message passing approach was developed for distributed memory architectures, which uses explicit messages to move data between processes. In this model, your application spawns separate processes, called ranks in message passing, with their own memory space and instruction pipeline (figure 1.20). The figure also shows that the processes are handed to the OS for placement on the processors. The application lives in the part of the diagram marked as user space, where the user has permissions to operate. The part beneath is kernel space, which is protected from dangerous operations by the user.

**Figure 1.20 The message passing library spawns processes. The OS places the processes on the cores of two nodes. The question marks indicate that the OS controls the placement of the processes and can move these during run time as indicated by the dashed arrows. The OS also allocates memory for each process from the node’s main memory.**

Keep in mind that processors—CPUs—have multiple processing cores that are not equivalent to the processes. Processes are an OS concept, and processors are a hardware component. For however many processes the application spawns, these are scheduled by the OS to the processing cores. You can actually run eight processes on your quad-core laptop and these will just swap in and out of the processing cores. For this reason, mechanisms have been developed to tell the OS how to place processes and whether to “bind” the process to a processing core. Controlling binding is discussed in more detail in chapter 14.

To move data between processes, you’ll need to program explicit messages into the application. These messages can be sent over a network or via shared memory. The many message-passing libraries coalesced into the Message Passing Interface (MPI) standard in 1992. Since then, MPI has taken over this niche and is present in almost all parallel applications that scale beyond a single node. And, yes, you’ll also find many different implementations of MPI libraries as well.

> **Distributed computing versus parallel computing**

> Some parallel applications use a lower-level approach to parallelization, called distributed computing. We define distributed computing as a set of loosely-coupled processes that cooperate via OS-level calls. While distributed computing is a subset of parallel computing, the distinction is important. Examples of distributed computing applications include peer-to-peer networks, the World Wide Web, and internet mail. The Search for Extraterrestial Intelligence (SETI@home) is just one example of many scientific distributed computing applications.

> The location of each process is usually on a separate node and is created through the OS using something like a remote procedure call (RPC) or a network protocol. The processes then exchange information through the passing of messages between the processes by inter-process communication (IPC), of which there are several varieties. Simple parallel applications often use a distributed computing approach, but often through a higher-level language such as Python and specialized parallel modules or libraries.

***THREAD-BASED PARALLELIZATION: SHARED DATA VIA MEMORY***

The thread-based approach to parallelization spawns separate instruction pointers within the same process (figure 1.21). As a result, you can easily share portions of the process memory between threads. But this comes with correctness and performance pitfalls. The programmer is left to determine which sections of the instruction set and data are independent and can support threading. These considerations are discussed in more detail in chapter 7, where we will look at OpenMP, one of the leading threading systems. OpenMP provides the capability to spawn threads and divide up the work among the threads.

**Figure 1.21 The application process in a thread-based approach to parallelization spawns threads. The threads are restricted to the node’s domain. The question marks show that the OS decides where to place the threads. Some memory is shared between threads.**

There are many varieties of threading approaches, ranging from heavy to light-weight and managed by either the user space or the OS. While threading systems are limited to scaling within a single node, these are an attractive option for modest speedup. The memory limitations of the single node, however, have larger implications for the application.

***VECTORIZATION: MULTIPLE OPERATIONS WITH ONE INSTRUCTION***

Vectorizing an application can be far more cost-effective than expanding compute resources at an HPC center, and this method might be absolutely necessary on portable devices like cell phones. When vectorizing, work is done in blocks of 2-16 data items at a time. The more formal term for this operation classification is single instruction, multiple data (SIMD). The term SIMD is used a lot when talking about vectorization. SIMD is just one category of parallel architectures that will be discussed later in section 1.4.

Invoking vectorization from a user’s application is most often done through source code pragmas or through compiler analysis. Pragmas and directives are hints given to the compiler to guide how to parallelize or vectorize a section of code. Both pragmas and compiler analysis are highly dependent on the compiler capabilities (figure 1.22). Here we are dependent on the compiler, where the previous parallel mechanisms were dependent on the OS. Also, without explicit compiler flags, the generated code is for the least powerful processor and vector length, significantly reducing the effectiveness of the vectorization. There are mechanisms where the compiler can be by-passed, but these require much more programming effort and are not portable.

**Figure 1.22 Vector instructions in source code returning different performance levels from compilers**

***STREAM PROCESSING THROUGH SPECIALIZED PROCESSORS***

Stream processing is a dataflow concept, where a stream of data is processed by a simpler special-purpose processor. Long used in embedded computing, the technique was adapted for rendering large sets of geometric objects for computer displays in a specialized processor, the GPU. These GPUs were filled with a broad set of arithmetic operations and multiple SMs to process geometric data in parallel. Scientific programmers soon found ways to adapt stream processing to large sets of simulation data such as cells, expanding the role of the GPU to a GPGPU.

In figure 1.23, the data and kernel are shown offloaded over the PCI bus to the GPU for computation. GPUs are still limited in functionality in comparison to CPUs, but where the specialized functionality can be used, these provide extraordinary compute capability at a lower power requirement. Other specialized processors also fit this category, though we focus on the GPU for our discussions.

**Figure 1.23 In the stream processing approach, data and compute kernel are offloaded to the GPU and its streaming multiprocessors. Processed data, or output, transfers back to the CPU for file IO or other work.**

***1.4 Categorizing parallel approaches***

If you read more about parallel computing, you will encounter acronyms such as SIMD (single instruction, multiple data) and MIMD (multiple instruction, multiple data). These terms refer to categories of computer architectures proposed by Michael Flynn in 1966 in what has become known as Flynn’s Taxonomy. These classes help to view potential parallelization in architectures in different ways. The categorization is based on breaking up instructions and data into either serial or multiple operations (figure 1.24). Be aware that though the taxonomy is useful, some architectures and algorithms do not fit neatly within a category. The usefulness comes from recognizing patterns in categories such as SIMD that have potential difficulties with conditionals. This is because each data item might want to be in a different block of code, but the threads have to execute the same instruction.

**Figure 1.24 Flynn’s Taxonomy categorizes different parallel architectures. A serial architecture is single data, single instruction (SISD). Two categories only have partial parallelization in that either the instructions or data are parallel, but the other is serial.**

In the case where there is more than one instruction sequence, the category is called multiple instruction, single data (MISD). This is not a common architecture; the best example is a redundant computation on the same data. This is used in highly fault-tolerant approaches such as spacecraft controllers. Because spacecraft are in high radiation environments, these often run two copies of each calculation and compare the output of the two.

Vectorization is a prime example of SIMD in which the same instruction is performed across multiple data. A variant of SIMD is single instruction, multi-thread (SIMT), which is commonly used to describe GPU work groups.

The final category has parallelization in both instructions and data and is referred to as MIMD. This category describes multi-core parallel architectures that comprise the majority of large parallel systems.

***1.5 Parallel strategies***

So far in our initial example in section 1.3.1, we looked at data parallelization for cells or pixels. But data parallelization can also be used for particles and other data objects. Data parallelization is the most common approach and often the simplest. Essentially, each process executes the same program but operates on a unique subset of data as illustrated in the upper right of figure 1.25. The data parallel approach has the advantage that it scales well as the problem size and number of processors grow.

**Figure 1.25 Various task and data parallel strategies, including main-worker, pipeline or bucket-brigade and data parallelism**

Another approach is task parallelism. This includes the main controller with worker threads, pipeline, or bucket-brigade strategies also shown in figure 1.25. The pipeline approach is used in superscalar processors where address and integer calculations are done with a separate logic unit rather than the floating-point processer, allowing these calculations to be done in parallel. The bucket-brigade uses each processor to operate on and transform the data in a sequence of operations. In the main-worker approach, one processor schedules and distributes the tasks for all the workers, and each worker checks for the next work item as it returns the previous completed task. It is also possible to combine different parallel strategies to expose a greater degree of parallelism.

***1.6 Parallel speedup versus comparative speedups: Two different measures***

We will present a lot of comparative performance numbers and speedups throughout this book. Often the term speedup is used to compare two different run times with little explanation or context to fully understand what it means. Speedup is a general term that is used in many contexts such as quantifying the effects of optimization, for example. To clarify the difference between the two major categories of parallel performance numbers, we’ll define two different terms.

- Parallel speedup—We should really call this serial-to-parallel speedup. The speedup is relative to a baseline serial run on a standard platform, usually a single CPU. The parallel speedup can be due to running on a GPU or with OpenMP or MPI on all the cores on the node of a computer system.

- Comparative speedup—We should really call this comparative speedup between architectures. This is usually a performance comparison between two parallel implementations or other comparison between reasonably constrained sets of hardware. For example, it may be between a parallel MPI implementation on all the cores of the node of a computer versus the GPU(s) on a node.

These two categories of performance comparisons represent two different goals. The first is to understand how much speedup can be obtained through adding a particular type of parallelism. It is not a fair comparison between architectures, however. It is about parallel speedup. For example, comparing a GPU run time to a serial CPU run is not a fair comparison between a multi-core CPU and the GPU. Comparative speedups between architectures are more appropriate when trying to compare a multi-core CPU to the performance of one or more GPUs on a node.

In recent years, some have normalized the two architectures so that relative performance is compared for similar power or energy requirements rather than an arbitrary node. Still, there are so many different architectures and possible combinations that any performance numbers to justify a conclusion can be obtained. You can pick a fast GPU and a slow CPU or a quad-core CPU versus a 16-core processor. We are therefore suggesting you add the following terms in parenthesis to performance comparisons to help give these more context:

- Add (Best 2016) to each term. For example, parallel speedup (Best 2016) and comparative speedup (Best 2016) would indicate that the comparison is between the best hardware released in a particular year (2016 in this example), where you might compare a high-end GPU to a high-end CPU.

- Add (Common 2016) or (2016) if the two architectures were released in 2016 but are not the highest-end hardware. This might be relevant to developers and users who have more mainstream parts than that found in the top-end systems.

- Add (Mac 2016) if the GPU and the CPU were released in a 2016 Mac laptop or desktop, or something similar for other brands with fixed components over a period of time (2016 in this example). Performance comparisons of this type are valuable to users of a commonly available system.

- Add (GPU 2016:CPU 2013) to show that there is a possible mismatch in the hardware release year (2016 versus 2013 in this example) of the components being compared.

- No qualifications added to comparison numbers. Who knows what the numbers mean?

Because of the explosion in CPU and GPU models, performance numbers will necessarily be more of a comparison between apples and oranges rather than a well-defined metric. But for more formal settings, we should at least indicate the nature of the comparison so that others have a better idea of the meaning of the numbers and to be more fair to the hardware vendors.

***1.7 What will you learn in this book?***

This book is written with the application code developer in mind and no previous knowledge of parallel computing is assumed. You should simply have a desire to improve the performance and scalability of your application. The application areas include scientific computing, machine learning, and analysis of big data on systems ranging from a desktop to the largest supercomputers.

To fully benefit from this book, readers should be proficient programmers, preferably with a compiled, HPC language such as C, C++, or Fortran. We also assume a rudimentary knowledge of hardware architectures. In addition, readers should be comfortable with computer technology terms such as bits, bytes, ops, cache, RAM, etc. It is also helpful to have a basic understanding of the functions of an OS and how it manages and interfaces with the hardware components. After reading this book, some of the skills you will gain include

- Determining when message passing (MPI) is more appropriate than threading (OpenMP) and vice-versa

- Estimating how much speedup is possible with vectorization

- Discerning which sections of your application have the most potential for speedup

- Deciding when it might be beneficial to leverage a GPU to accelerate your application

- Establishing what is the peak potential performance for your application

- Estimating the energy cost for your application

Even after this first chapter, you should feel comfortable with the different approaches to parallel programming. We suggest that you work through the exercises in each chapter to help you integrate the many concepts that we present. If you are beginning to feel a little overwhelmed by the complexity of the current parallel architectures, you are not alone. It’s challenging to grasp all the possibilities. We’ll break it down, piece-by-piece, in the following chapters to make it easier for you.

***1.7.1 Additional reading***

A good basic introduction to parallel computing can be found on the Lawrence Livermore National Laboratory website:

Blaise Barney, “Introduction to Parallel Computing.” [https://computing.llnl.gov/ tutorials/parallel_comp/](https://computing.llnl.gov/tutorials/parallel_comp/).

***1.7.2 Exercises***

1.  What are some other examples of parallel operations in your daily life? How would you classify your example? What does the parallel design appear to optimize for? Can you compute a parallel speedup for this example?

2.  For your desktop, laptop, or cell phone, what is the theoretical parallel processing power of your system in comparison to its serial processing power? What kinds of parallel hardware are present in it?

3.  Which parallel strategies do you see in the store checkout example in figure 1.1? Are there some present parallel strategies that are not shown? How about in your examples from exercise 1?

4.  You have an image-processing application that needs to process 1,000 images daily, which are 4 mebibytes (MiB, 220 or 1,048,576 bytes) each in size. It takes 10 min in serial to process each image. Your cluster is composed of multi-core nodes with 16 cores and a total of 16 gibibytes (GiB, 230 bytes, or 1024 mebibytes) of main memory storage per node. (Note that we use the proper binary terms, MiB and GiB, rather than MB and GB, which are the metric terms for 106 and 109 bytes, respectively.)

    1.  What parallel processing design best handles this workload?

    2.  Now customer demand increases by 10x. Does your design handle this? What changes would you have to make?

5.  An Intel Xeon E5-4660 processor has a thermal design power of 130 W; this is the average power consumption rate when all 16 cores are used. NVIDIA’s Tesla V100 GPU and AMD’s MI25 Radeon GPU have a thermal design power of 300 W. Suppose you port your software to use one of these GPUs. How much faster should your application run on the GPU to be considered more energy efficient than your 16-core CPU application?

***Summary***

- Because this is an era where most of the compute capabilities of hardware are only accessible through parallelism, programmers should be well versed in the techniques used to exploit parallelism.

- Applications must have parallel work. The most important job of a parallel programmer is to expose more parallelism.

- Improvements to hardware are nearly all-enhancing parallel components. Relying on increasing serial performance will not result in future speedup. The key to increasing application performance will all be in the parallel realm.

- A variety of parallel software languages are emerging to help access the hardware capabilities. Programmers should know which are suitable for different situations.
