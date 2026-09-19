# Part 2 CPU: The parallel workhorse

***Part 2 CPU: The parallel workhorse***

Today, every developer should understand the growing parallelism available within modern CPU processors. Unlocking the untapped performance of CPUs is a critical skill for parallel and high performance computing applications. To show how to take advantage of CPU parallelism, we cover

- Using vector hardware

- Using threads for parallel work across multi-core processors

- Coordinating work on multiple CPUs and multi-core processors with message passing

The CPU’s parallel capabilities need to be at the core of your parallel strategy. Because it’s the central workhorse, the CPU controls all the memory allocations, memory movement, and communication. The application developer’s knowledge and skill are the most important factors for fully using the CPU’s parallelism. CPU optimization is not automatically done by some magic compiler. Commonly, many of the parallel resources on the CPU go untapped by applications. We can break down the available CPU parallelism into three components in increasing order of effort. These are

- Vectorization—Exploits the specialized hardware that can do more than one operation at a time

- Multi-core and threading—Spreads out work across the many processing cores in today’s CPUs

- Distributed memory—Harnesses multiple nodes into a single, cooperative computing application

Thus, we begin with vectorization. Vectorization is a highly underused capability with notable gains when implemented. Though compilers can do some vectorization, compilers don’t do enough. The limitations are especially noticeable for complicated code. Compilers are just not there yet. Although compilers are improving, there is not sufficient funding or manpower for this to happen quickly. Consequently, the application programmer has to help in a variety of ways. Unfortunately, there is little documentation on vectorization. In chapter 6, we present an introduction to the arcane knowledge of getting more from vectorization for your application.

With the explosion in processing cores on each CPU, the need and knowledge for exploiting on-node parallelism is growing rapidly. Two common CPU resources for this include threading and shared memory. There are dozens of different threading systems and shared memory approaches. In chapter 7, we present a guide to using OpenMP, the most commonly used threading package for high performance computing.

The dominant language for parallelism across nodes, and even within nodes, is the open source standard, the Message Passing Interface (MPI). The MPI standard grew out of a consolidation of many message-passing libraries from the early days of parallel programming. MPI is a well-designed language that has withstood the test of time and changes to hardware architectures. It has also adapted with new features and improvements that have been incorporated into its implementations. Still, most application programmers just use the most basic features of the language. In chapter 8, we give an introduction to the basics of MPI, as well as some advanced features that can be useful in many scientific and big data applications.

The key to getting high performance on the CPU is to pay attention to memory bandwidth, supplying the data to parallel engines. Good parallel performance begins with good serial performance (and an understanding of the topics presented in the first five chapters of this book). CPUs provide the most general parallelism for the widest variety of applications. From modest parallelism through extreme scale, the CPU often delivers the goods. The CPU is also where you must begin your journey into the parallel world. Even in solutions that use accelerators, the CPU remains an essential component in the system.

Up until now, the solution to increasing performance was to add more compute power in the form of physically adding more nodes to your cluster or high performance computer. The parallel and high performance computing community has gone as far as it can with that approach and is beginning to hit power and energy consumption limits. Additionally, the number of nodes and processors cannot continue to grow without running into the limitations of scaling applications. In response to this, we must turn to other avenues to improve performance. Within the processing node, there are a lot of underutilized parallel hardware capabilities. As we first mentioned in section 1.1, parallelism within the node will continue to grow.

Even with continuing limitations of compute power and other looming thresholds, key insights and knowledge of lesser-known tools can unlock substantial performance. Through this book and your studies, we can help tackle these challenges. In the end, your skills and knowledge are important commodities for unlocking the promises of parallel performance.

The examples that accompany the three chapters in part 2 of this book are at [https://github.com/EssentialsofParallelComputing,](https://github.com/EssentialsofParallelComputing) with a separate repository for each chapter. Docker container builds for each chapter should install and work well on any operating system. The container builds for the first two chapters in this part (chapters 6 and 7) use a graphical interface to allow the use of performance and correctness tools.
