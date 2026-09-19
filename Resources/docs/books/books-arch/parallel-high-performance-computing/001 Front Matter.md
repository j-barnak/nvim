# Front Matter

** **

** **

**Parallel and High Performance Computing**

** **

**ROBERT ROBEY AND YULIANA ZAMORA**

** **

** **

To comment go to [liveBook](https://livebook.manning.com/#!/book/parallel-and-high-performance-computing/discussion)

** **

** **

**Manning**

**Shelter Island**

** **

For more information on this and other Manning titles go to

[www.manning.com](https://www.manning.com/)

** **

**Copyright**

For online information and ordering of these  and other Manning books, please visit [www.manning.com](https://www.manning.com/). The publisher offers discounts on these books when ordered in quantity.

For more information, please contact

Special Sales Department

Manning Publications Co.

20 Baldwin Road

PO Box 761

Shelter Island, NY 11964

Email: orders@manning.com

**©2021 by Manning Publications Co. All rights reserved.**

No part of this publication may be reproduced, stored in a retrieval system, or transmitted, in any form or by means electronic, mechanical, photocopying, or otherwise, without prior written permission of the publisher.

Many of the designations used by manufacturers and sellers to distinguish their products are claimed as trademarks. Where those designations appear in the book, and Manning Publications was aware of a trademark claim, the designations have been printed in initial caps or all caps.

♾ Recognizing the importance of preserving what has been written, it is Manning’s policy to have the books we publish printed on acid-free paper, and we exert our best efforts to that end. Recognizing also our responsibility to conserve the resources of our planet, Manning books are printed on paper that is at least 15 percent recycled and processed without the use of elemental chlorine.

  

[TABLE]

  

|                                 |                            |
|---------------------------------|----------------------------|
| Development editor:             | Marina Michaels            |
| Technical development editor:   | Christopher Haupt          |
| Review editor:                  | Aleksandar Dragosavljevic´ |
| Production editor:              | Deirdre S. Hiam            |
| Copy editor:                    | Frances Buran              |
| Proofreader:                    | Jason Everett              |
| Technical proofreader:          | Tuan A. Tran               |
| Typesetter:                     | Dennis Dalinnik            |
| Cover designer:                 | Marija Tudor               |

ISBN: 9781617296468

***Dedication***

To my wife, Peggy, who has supported not only my journey in high performance computing, but also that of our son Jon and daughter Rachel. Scientific programming is far from her medical expertise, but she has accompanied me and made it our journey. To my son, Jon, and daughter, Rachel, who have rekindled the flame and for your promising future.

—Bob Robey

 

To my husband Rick, who supported me the entire way, thank you for taking the early shifts and letting me work into the night. You never let me give up on myself. To my parents and in-laws, thank you for all your help and support. And to my son, Derek, for being one of my biggest inspirations; you are the reason I leap instead of jump.

—Yulie Zamora

***contents***

> [***preface***](#filepos123053)

> [***acknowledgments***](#filepos136471)

> [***about this book***](#filepos141446)

> [***about the authors***](#filepos158773)

[**Part 1 Introduction to parallel computing**](#filepos163158)

> ** [***1 Why parallel computing?***](#filepos168055)

> > > > [1.1 Why should you learn about parallel computing?](#filepos176364)

> > > > > > > > [1.1.1 What are the potential benefits of parallel computing?](#filepos181871)

> > > > > > > > [1.1.2 Parallel computing cautions](#filepos190922)

> > > > [1.2 The fundamental laws of parallel computing](#filepos192295)

> > > > > > > > [1.2.1 The limit to parallel computing: Amdahl’s Law](#filepos192804)

> > > > > > > > [1.2.2 Breaking through the parallel limit: Gustafson-Barsis’s Law](#filepos194606)

> > > > [1.3 How does parallel computing work?](#filepos199761)

> > > > > > > > [1.3.1 Walking through a sample application](#filepos203681)

> > > > > > > > [1.3.2 A hardware model for today’s heterogeneous parallel systems](#filepos215590)

> > > > > > > > [1.3.3 The application/software model for today’s heterogeneous parallel systems](#filepos225580)

> > > > [1.4 Categorizing parallel approaches](#filepos235918)

> > > > [1.5 Parallel strategies](#filepos238432)

> > > > [1.6 Parallel speedup versus comparative speedups: Two different measures](#filepos240230)

> > > > [1.7 What will you learn in this book?](#filepos244853)

> > > > > > > > [Additional reading](#filepos247488)

> > > > > > > > [Exercises](#filepos248002)

> ** [***2 Planning for parallelization***](#filepos251689)

> > > > [2.1 Approaching a new project: The preparation](#filepos256269)

> > > > > > > > [2.1.1 Version control: Creating a safety vault for your parallel code](#filepos259326)

> > > > > > > > [2.1.2 Test suites: The first step to creating a robust, reliable application](#filepos304667)

> > > > > > > > [2.1.3 Finding and fixing memory issues](#filepos266710)

> > > > > > > > [2.1.4 Improving code portability](#filepos311116)

> > > > [2.2 Profiling: Probing the gap between system capabilities and application performance](#filepos314170)

> > > > [2.3 Planning: A foundation for success](#filepos315983)

> > > > > > > > [2.3.1 Exploring with benchmarks and mini-apps](#filepos317095)

> > > > > > > > [2.3.2 Design of the core data structures and code modularity](#filepos319941)

> > > > > > > > [2.3.3 Algorithms: Redesign for parallel](#filepos320877)

> > > > [2.4 Implementation: Where it all happens](#filepos323475)

> > > > [2.5 Commit: Wrapping it up with quality](#filepos326451)

> > > > [2.6 Further explorations](#filepos328613)

> > > > > > > > [2.6.1 Additional reading](#filepos328988)

> > > > > > > > [2.6.2 Exercises](#filepos330567)

> ** [***3 Performance limits and profiling***](#filepos334124)

> > > > [3.1 Know your application’s potential performance limits](#filepos335681)

> > > > [3.2 Determine your hardware capabilities: Benchmarking](#filepos345232)

> > > > > > > > [3.2.1 Tools for gathering system characteristics](#filepos346803)

> > > > > > > > [3.2.2 Calculating theoretical maximum flops](#filepos352399)

> > > > > > > > [3.2.3 The memory hierarchy and theoretical memory bandwidth](#filepos355157)

> > > > > > > > [3.2.4 Empirical measurement of bandwidth and flops](#filepos358851)

> > > > > > > > [3.2.5 Calculating the machine balance between flops and bandwidth](#filepos368843)

> > > > [3.3 Characterizing your application: Profiling](#filepos370401)

> > > > > > > > [3.3.1 Profiling tools](#filepos371924)

> > > > > > > > [3.3.2 Empirical measurement of processor clock frequency and energy consumption](#filepos395309)

> > > > > > > > [3.3.3 Tracking memory during run time](#filepos399311)

> > > > [3.4 Further explorations](#filepos401179)

> > > > > > > > [3.4.1 Additional reading](#filepos401522)

> > > > > > > > [3.4.2 Exercises](#filepos402410)

> ** [***4 Data design and performance models***](#filepos406648)

> > > > [4.1 Performance data structures: Data-oriented design](#filepos412311)

> > > > > > > > [4.1.1 Multidimensional arrays](#filepos418527)

> > > > > > > > [4.1.2 Array of Structures (AoS) versus Structures of Arrays (SoA)](#filepos435302)

> > > > > > > > [4.1.3 Array of Structures of Arrays (AoSoA)](#filepos455054)

> > > > [4.2 Three Cs of cache misses: Compulsory, capacity, conflict](#filepos459976)

> > > > [4.3 Simple performance models: A case study](#filepos470117)

> > > > > > > > [4.3.1 Full matrix data representations](#filepos480146)

> > > > > > > > [4.3.2 Compressed sparse storage representations](#filepos489041)

> > > > [4.4 Advanced performance models](#filepos503358)

> > > > [4.5 Network messages](#filepos515272)

> > > > [4.6 Further explorations](#filepos520085)

> > > > > > > > [4.6.1 Additional reading](#filepos520598)

> > > > > > > > [4.6.2 Exercises](#filepos523118)

> ** [***5 Parallel algorithms and patterns***](#filepos525641)

> > > > [5.1 Algorithm analysis for parallel computing applications](#filepos527869)

> > > > [5.2 Performance models versus algorithmic complexity](#filepos532407)

> > > > [5.3 Parallel algorithms: What are they?](#filepos549921)

> > > > [5.4 What is a hash function?](#filepos554520)

> > > > [5.5 Spatial hashing: A highly-parallel algorithm](#filepos558583)

> > > > > > > > [5.5.1 Using perfect hashing for spatial mesh operations](#filepos566197)

> > > > > > > > [5.5.2 Using compact hashing for spatial mesh operations](#filepos619206)

> > > > [5.6 Prefix sum (scan) pattern and its importance in parallel computing](#filepos647765)

> > > > > > > > [5.6.1 Step-efficient parallel scan operation](#filepos650456)

> > > > > > > > [5.6.2 Work-efficient parallel scan operation](#filepos651944)

> > > > > > > > [5.6.3 Parallel scan operations for large arrays](#filepos654476)

> > > > [5.7 Parallel global sum: Addressing the problem of associativity](#filepos656940)

> > > > [5.8 Future of parallel algorithm research](#filepos685739)

> > > > [5.9 Further explorations](#filepos687953)

> > > > > > > > [5.9.1 Additional reading](#filepos688446)

> > > > > > > > [5.9.2 Exercises](#filepos692095)

[**Part 2 CPU: The parallel workhorse**](#filepos695389)

> ** [***6 Vectorization: FLOPs for free***](#filepos701711)

> > > > [6.1 Vectorization and single instruction, multiple data (SIMD) overview](#filepos704032)

> > > > [6.2 Hardware trends for vectorization](#filepos709298)

> > > > [6.3 Vectorization methods](#filepos713234)

> > > > > > > > [6.3.1 Optimized libraries provide performance for little effort](#filepos714073)

> > > > > > > > [6.3.2 Auto-vectorization: The easy way to vectorization speedup (most of the time)](#filepos715843)

> > > > > > > > [6.3.3 Teaching the compiler through hints: Pragmas and directives](#filepos730739)

> > > > > > > > [6.3.4 Crappy loops, we got them: Use vector intrinsics](#filepos755206)

> > > > > > > > [6.3.5 Not for the faint of heart: Using assembler code for vectorization](#filepos785251)

> > > > [6.4 Programming style for better vectorization](#filepos789840)

> > > > [6.5 Compiler flags relevant for vectorization for various compilers](#filepos794874)

> > > > [6.6 OpenMP SIMD directives for better portability](#filepos821186)

> > > > [6.7 Further explorations](#filepos829447)

> > > > > > > > [6.7.1 Additional reading](#filepos829969)

> > > > > > > > [6.7.2 Exercises](#filepos831074)

> ** [***7 OpenMP that performs***](#filepos834291)

> > > > [7.1 OpenMP introduction](#filepos837023)

> > > > > > > > [7.1.1 OpenMP concepts](#filepos839214)

> > > > > > > > [7.1.2 A simple OpenMP program](#filepos852478)

> > > > [7.2 Typical OpenMP use cases: Loop-level, high-level, and MPI plus OpenMP](#filepos874940)

> > > > > > > > [7.2.1 Loop-level OpenMP for quick parallelization](#filepos875962)

> > > > > > > > [7.2.2 High-level OpenMP for better parallel performance](#filepos877823)

> > > > > > > > [7.2.3 MPI plus OpenMP for extreme scalability](#filepos879411)

> > > > [7.3 Examples of standard loop-level OpenMP](#filepos881157)

> > > > > > > > [7.3.1 Loop level OpenMP: Vector addition example](#filepos884184)

> > > > > > > > [7.3.2 Stream triad example](#filepos896958)

> > > > > > > > [7.3.3 Loop level OpenMP: Stencil example](#filepos901620)

> > > > > > > > [7.3.4 Performance of loop-level examples](#filepos907668)

> > > > > > > > [7.3.5 Reduction example of a global sum using OpenMP threading](#filepos912519)

> > > > > > > > [7.3.6 Potential loop-level OpenMP issues](#filepos915178)

> > > > [7.4 Variable scope importance for correctness in OpenMP](#filepos917760)

> > > > [7.5 Function-level OpenMP: Making a whole function thread parallel](#filepos923359)

> > > > [7.6 Improving parallel scalability with high-level OpenMP](#filepos934208)

> > > > > > > > [7.6.1 How to implement high-level OpenMP](#filepos935663)

> > > > > > > > [7.6.2 Example of implementing high-level OpenMP](#filepos942961)

> > > > [7.7 Hybrid threading and vectorization with OpenMP](#filepos957708)

> > > > [7.8 Advanced examples using OpenMP](#filepos967195)

> > > > > > > > [7.8.1 Stencil example with a separate pass for the x and y directions](#filepos968220)

> > > > > > > > [7.8.2 Kahan summation implementation with OpenMP threading](#filepos995992)

> > > > > > > > [7.8.3 Threaded implementation of the prefix scan algorithm](#filepos988961)

> > > > [7.9 Threading tools essential for robust implementations](#filepos1004399)

> > > > > > > > [7.9.1 Using Allinea/ARM MAP to get a quick high-level profile of your application](#filepos1006412)

> > > > > > > > [7.9.2 Finding your thread race conditions with Intel® Inspector](#filepos1007595)

> > > > [7.10 Example of a task-based support algorithm](#filepos1009802)

> > > > [7.11 Further explorations](#filepos1016367)

> > > > > > > > [7.11.1 Additional reading](#filepos1017235)

> > > > > > > > [7.11.2 Exercises](#filepos1019620)

> [***8 MPI: The parallel backbone***](#filepos1025052)

> > > > [8.1 The basics for an MPI program](#filepos1028120)

> > > > > > > > [8.1.1 Basic MPI function calls for every MPI program](#filepos1029719)

> > > > > > > > [8.1.2 Compiler wrappers for simpler MPI programs](#filepos1031759)

> > > > > > > > [8.1.3 Using parallel startup commands](#filepos1034247)

> > > > > > > > [8.1.4 Minimum working example of an MPI program](#filepos1036077)

> > > > [8.2 The send and receive commands for process-to-process communication](#filepos1044141)

> > > > [8.3 Collective communication: A powerful component of MPI](#filepos1071315)

> > > > > > > > [8.3.1 Using a barrier to synchronize timers](#filepos1073711)

> > > > > > > > [8.3.2 Using the broadcast to handle small file input](#filepos1077876)

> > > > > > > > [8.3.3 Using a reduction to get a single value from across all processes](#filepos1085161)

> > > > > > > > [8.3.4 Using gather to put order in debug printouts](#filepos1105072)

> > > > > > > > [8.3.5 Using scatter and gather to send data out to processes for work](#filepos1110052)

> > > > [8.4 Data parallel examples](#filepos1120738)

> > > > > > > > [8.4.1 Stream triad to measure bandwidth on the node](#filepos1121309)

> > > > > > > > [8.4.2 Ghost cell exchanges in a two-dimensional (2D) mesh](#filepos1126391)

> > > > > > > > [8.4.3 Ghost cell exchanges in a three-dimensional (3D) stencil calculation](#filepos1173728)

> > > > [8.5 Advanced MPI functionality to simplify code and enable optimizations](#filepos1180148)

> > > > > > > > [8.5.1 Using custom MPI data types for performance and code simplification](#filepos1181239)

> > > > > > > > [8.5.2 Cartesian topology support in MPI](#filepos1213100)

> > > > > > > > [8.5.3 Performance tests of ghost cell exchange variants](#filepos1249237)

> > > > [8.6 Hybrid MPI plus OpenMP for extreme scalability](#filepos1253516)

> > > > > > > > [8.6.1 The benefits of hybrid MPI plus OpenMP](#filepos1254553)

> > > > > > > > [8.6.2 MPI plus OpenMP example](#filepos1257908)

> > > > [8.7 Further explorations](#filepos1266744)

> > > > > > > > [8.7.1 Additional reading](#filepos1269418)

> > > > > > > > [8.7.2 Exercises](#filepos1270477)

[**Part 3 GPUs: Built to accelerate**](#filepos1273424)

> ** [***9 GPU architectures and concepts***](#filepos1281985)

> > > > [9.1 The CPU-GPU system as an accelerated computational platform](#filepos1286557)

> > > > > > > > [9.1.1 Integrated GPUs: An underused option on commodity-based systems](#filepos1291529)

> > > > > > > > [9.1.2 Dedicated GPUs: The workhorse option](#filepos1293335)

> > > > [9.2 The GPU and the thread engine](#filepos1294935)

> > > > > > > > [9.2.1 The compute unit is the streaming multiprocessor (or subslice)](#filepos1305966)

> > > > > > > > [9.2.2 Processing elements are the individual processors](#filepos1306398)

> > > > > > > > [9.2.3 Multiple data operations by each processing element](#filepos1307496)

> > > > > > > > [9.2.4 Calculating the peak theoretical flops for some leading GPUs](#filepos1308002)

> > > > [9.3 Characteristics of GPU memory spaces](#filepos1322269)

> > > > > > > > [9.3.1 Calculating theoretical peak memory bandwidth](#filepos1324698)

> > > > > > > > [9.3.2 Measuring the GPU stream benchmark](#filepos1333293)

> > > > > > > > [9.3.3 Roofline performance model for GPUs](#filepos1337335)

> > > > > > > > [9.3.4 Using the mixbench performance tool to choose the best GPU for a workload](#filepos1340912)

> > > > [9.4 The PCI bus: CPU to GPU data transfer overhead](#filepos1346482)

> > > > > > > > [9.4.1 Theoretical bandwidth of the PCI bus](#filepos1348160)

> > > > > > > > [9.4.2 A benchmark application for PCI bandwidth](#filepos1360268)

> > > > [9.5 Multi-GPU platforms and MPI](#filepos1373971)

> > > > > > > > [9.5.1 Optimizing the data movement between GPUs across the network](#filepos1375714)

> > > > > > > > [9.5.2 A higher performance alternative to the PCI bus](#filepos1378412)

> > > > [9.6 Potential benefits of GPU-accelerated platforms](#filepos1379209)

> > > > > > > > [9.6.1 Reducing time-to-solution](#filepos1380015)

> > > > > > > > [9.6.2 Reducing energy use with GPUs](#filepos1385830)

> > > > > > > > [9.6.3 Reduction in cloud computing costs with GPUs](#filepos1404561)

> > > > [9.7 When to use GPUs](#filepos1405821)

> > > > [9.8 Further explorations](#filepos1407781)

> > > > > > > > [9.8.1 Additional reading](#filepos1408250)

> > > > > > > > [9.8.2 Exercises](#filepos1409972)

> ** [***10 GPU programming model***](#filepos1415839)

> > > > [10.1 GPU programming abstractions: A common framework](#filepos1421155)

> > > > > > > > [10.1.1 Massive parallelism](#filepos1421874)

> > > > > > > > [10.1.2 Inability to coordinate among tasks](#filepos1424363)

> > > > > > > > [10.1.3 Terminology for GPU parallelism](#filepos1424801)

> > > > > > > > [10.1.4 Data decomposition into independent units of work: An NDRange or grid](#filepos1430500)

> > > > > > > > [10.1.5 Work groups provide a right-sized chunk of work](#filepos1444136)

> > > > > > > > [10.1.6 Subgroups, warps, or wavefronts execute in lockstep](#filepos1446488)

> > > > > > > > [10.1.7 Work item: The basic unit of operation](#filepos1448649)

> > > > > > > > [10.1.8 SIMD or vector hardware](#filepos1449799)

> > > > [10.2 The code structure for the GPU programming model](#filepos1450886)

> > > > > > > > [10.2.1 “Me” programming: The concept of a parallel kernel](#filepos1452926)

> > > > > > > > [10.2.2 Thread indices: Mapping the local tile to the global world](#filepos1461697)

> > > > > > > > [10.2.3 Index sets](#filepos1461697)

> > > > > > > > [10.2.4 How to address memory resources in your GPU programming model](#filepos1464263)

> > > > [10.3 Optimizing GPU resource usage](#filepos1469085)

> > > > > > > > [10.3.1 How many registers does my kernel use?](#filepos1474528)

> > > > > > > > [10.3.2 Occupancy: Making more work available for work group scheduling](#filepos1476278)

> > > > [10.4 Reduction pattern requires synchronization across work groups](#filepos1479660)

> > > > [10.5 Asynchronous computing through queues (streams)](#filepos1482863)

> > > > [10.6 Developing a plan to parallelize an application for GPUs](#filepos1485959)

> > > > > > > > [10.6.1 Case 1: 3D atmospheric simulation](#filepos1486368)

> > > > > > > > [10.6.2 Case 2: Unstructured mesh application](#filepos1490156)

> > > > [10.7 Further explorations](#filepos1491938)

> > > > > > > > [10.7.1 Additional reading](#filepos1495255)

> > > > > > > > [10.7.2 Exercises](#filepos1497980)

> ** [***11 Directive-based GPU programming***](#filepos1501072)

> > > > [11.1 Process to apply directives and pragmas for a GPU implementation](#filepos1505230)

> > > > [11.2 OpenACC: The easiest way to run on your GPU](#filepos1508259)

> > > > > > > > [11.2.1 Compiling OpenACC code](#filepos1511515)

> > > > > > > > [11.2.2 Parallel compute regions in OpenACC for accelerating computations](#filepos1518919)

> > > > > > > > [11.2.3 Using directives to reduce data movement between the CPU and the GPU](#filepos1541087)

> > > > > > > > [11.2.4 Optimizing the GPU kernels](#filepos1558790)

> > > > > > > > [11.2.5 Summary of performance results for the stream triad](#filepos1579589)

> > > > > > > > [11.2.6 Advanced OpenACC techniques](#filepos1583337)

> > > > [11.3 OpenMP: The heavyweight champ enters the world of accelerators](#filepos1592346)

> > > > > > > > [11.3.1 Compiling OpenMP code](#filepos1594355)

> > > > > > > > [11.3.2 Generating parallel work on the GPU with OpenMP](#filepos1600110)

> > > > > > > > [11.3.3 Creating data regions to control data movement to the GPU with OpenMP](#filepos1613371)

> > > > > > > > [11.3.4 Optimizing OpenMP for GPUs](#filepos1629773)

> > > > > > > > [11.3.5 Advanced OpenMP for GPUs](#filepos1651983)

> > > > [11.4 Further explorations](#filepos1666918)

> > > > > > > > [11.4.1 Additional reading](#filepos1667613)

> > > > > > > > [11.4.2 Exercises](#filepos1671665)

> ** [***12 GPU languages: Getting down to basics***](#filepos1675299)

> > > > [12.1 Features of a native GPU programming language](#filepos1681748)

> > > > [12.2 CUDA and HIP GPU languages: The low-level performance option](#filepos1685943)

> > > > > > > > [12.2.1 Writing and building your first CUDA application](#filepos1687265)

> > > > > > > > [12.2.2 A reduction kernel in CUDA: Life gets complicated](#filepos1725810)

> > > > > > > > [12.2.3 Hipifying the CUDA code](#filepos1749107)

> > > > [12.3 OpenCL for a portable open source GPU language](#filepos1763124)

> > > > > > > > [12.3.1 Writing and building your first OpenCL application](#filepos1767585)

> > > > > > > > [12.3.2 Reductions in OpenCL](#filepos1800842)

> > > > [12.4 SYCL: An experimental C++ implementation goes mainstream](#filepos1814006)

> > > > [12.5 Higher-level languages for performance portability](#filepos1830263)

> > > > > > > > [12.5.1 Kokkos: A performance portability ecosystem](#filepos1831518)

> > > > > > > > [12.5.2 RAJA for a more adaptable performance portability layer](#filepos1845507)

> > > > [12.6 Further explorations](#filepos1852276)

> > > > > > > > [12.6.1 Additional reading](#filepos1852821)

> > > > > > > > [12.6.2 Exercises](#filepos1856151)

> ** [***13 GPU profiling and tools***](#filepos1859080)

> > > > [13.1 An overview of profiling tools](#filepos1860316)

> > > > [13.2 How to select a good workflow](#filepos1864334)

> > > > [13.3 Example problem: Shallow water simulation](#filepos1868998)

> > > > [13.4 A sample of a profiling workflow](#filepos1878056)

> > > > > > > > [13.4.1 Run the shallow water application](#filepos1878793)

> > > > > > > > [13.4.2 Profile the CPU code to develop a plan of action](#filepos1884547)

> > > > > > > > [13.4.3 Add OpenACC compute directives to begin the implementation step](#filepos1889519)

> > > > > > > > [13.4.4 Add data movement directives](#filepos1895688)

> > > > > > > > [13.4.5 Guided analysis can give you some suggested improvements](#filepos1898891)

> > > > > > > > [13.4.6 The NVIDIA Nsight suite of tools can be a powerful development aid](#filepos1902747)

> > > > > > > > [13.4.7 CodeXL for the AMD GPU ecosystem](#filepos1904668)

> > > > [13.5 Don’t get lost in the swamp: Focus on the important metrics](#filepos1905661)

> > > > > > > > [13.5.1 Occupancy: Is there enough work?](#filepos1906371)

> > > > > > > > [13.5.2 Issue efficiency: Are your warps on break too often?](#filepos1907685)

> > > > > > > > [13.5.3 Achieved bandwidth: It always comes down to bandwidth](#filepos1909647)

> > > > [13.6 Containers and virtual machines provide alternate workflows](#filepos1910516)

> > > > > > > > [13.6.1 Docker containers as a workaround](#filepos1911014)

> > > > > > > > [13.6.2 Virtual machines using VirtualBox](#filepos1919706)

> > > > [13.7 Cloud options: A flexible and portable capability](#filepos1928500)

> > > > [13.8 Further explorations](#filepos1930289)

> > > > > > > > [13.8.1 Additional reading](#filepos1931400)

> > > > > > > > [13.8.2 Exercises](#filepos1933962)

[**Part 4 High performance computing ecosystems**](#filepos1936401)

> ** [***14 Affinity: Truce with the kernel***](#filepos1940524)

> > > > [14.1 Why is affinity important?](#filepos1944097)

> > > > [14.2 Discovering your architecture](#filepos1948751)

> > > > [14.3 Thread affinity with OpenMP](#filepos1952075)

> > > > [14.4 Process affinity with MPI](#filepos1976535)

> > > > > > > > [14.4.1 Default process placement with OpenMPI](#filepos1977394)

> > > > > > > > [14.4.2 Taking control: Basic techniques for specifying process placement in OpenMPI](#filepos1979004)

> > > > > > > > [14.4.3 Affinity is more than just process binding: The full picture](#filepos1992239)

> > > > [14.5 Affinity for MPI plus OpenMP](#filepos2000520)

> > > > [14.6 Controlling affinity from the command line](#filepos2017380)

> > > > > > > > [14.6.1 Using hwloc-bind to assign affinity](#filepos2018113)

> > > > > > > > [14.6.2 Using likwid-pin: An affinity tool in the likwid tool suite](#filepos2023216)

> > > > [14.7 The future: Setting and changing affinity at run time](#filepos2029987)

> > > > > > > > [14.7.1 Setting affinities in your executable](#filepos2031392)

> > > > > > > > [14.7.2 Changing your process affinities during run time](#filepos2040828)

> > > > [14.8 Further explorations](#filepos2048674)

> > > > > > > > [14.8.1 Additional reading](#filepos2049201)

> > > > > > > > [14.8.2 Exercises](#filepos2053363)

> [***15 Batch schedulers: Bringing order to chaos***](#filepos2056892)

> > > > [15.1 The chaos of an unmanaged system](#filepos2060274)

> > > > [15.2 How not to be a nuisance when working on a busy cluster](#filepos2062608)

> > > > > > > > [15.2.1 Layout of a batch system for busy clusters](#filepos2063344)

> > > > > > > > [15.2.2 How to be courteous on busy clusters and HPC sites: Common HPC pet peeves](#filepos2064032)

> > > > [15.3 Submitting your first batch script](#filepos2069901)

> > > > [15.4 Automatic restarts for long-running jobs](#filepos2095844)

> > > > [15.5 Specifying dependencies in batch scripts](#filepos2112107)

> > > > [15.6 Further explorations](#filepos2118864)

> > > > > > > > [15.6.1 Additional reading](#filepos2119485)

> > > > > > > > [15.6.2 Exercises](#filepos2121958)

> ** [***16 File operations for a parallel world***](#filepos2124103)

> > > > [16.1 The components of a high-performance filesystem](#filepos2127516)

> > > > [16.2 Standard file operations: A parallel-to-serial interface](#filepos2130945)

> > > > [16.3 MPI file operations (MPI-IO) for a more parallel world](#filepos2135109)

> > > > [16.4 HDF5 is self-describing for better data management](#filepos2172289)

> > > > [16.5 Other parallel file software packages](#filepos2213448)

> > > > [16.6 Parallel filesystem: The hardware interface](#filepos2214558)

> > > > > > > > [16.6.1 Everything you wanted to know about your parallel file setup but didn’t know how to ask](#filepos2216429)

> > > > > > > > [16.6.2 General hints that apply to all filesystems](#filepos2229959)

> > > > > > > > [16.6.3 Hints specific to particular filesystems](#filepos2236996)

> > > > [16.7 Further explorations](#filepos2249488)

> > > > > > > > [16.7.1 Additional reading](#filepos2250409)

> > > > > > > > [16.7.2 Exercises](#filepos2253893)

> ** [***17 Tools and resources for better code***](#filepos2255884)

> > > > [17.1 Version control systems: It all begins here](#filepos2269598)

> > > > > > > > [17.1.1 Distributed version control fits the more mobile world](#filepos2271420)

> > > > > > > > [17.1.2 Centralized version control for simplicity and code security](#filepos2273354)

> > > > [17.2 Timer routines for tracking code performance](#filepos2275507)

> > > > [17.3 Profilers: You can’t improve what you don’t measure](#filepos2280980)

> > > > > > > > [17.3.1 Simple text-based profilers for everyday use](#filepos2284962)

> > > > > > > > [17.3.2 High-level profilers for quickly identifying bottlenecks](#filepos2288417)

> > > > > > > > [17.3.3 Medium-level profilers to guide your application development](#filepos2290321)

> > > > > > > > [17.3.4 Detailed profilers give the gory details of hardware performance](#filepos2297189)

> > > > [17.4 Benchmarks and mini-apps: A window into system performance](#filepos2300260)

> > > > > > > > [17.4.1 Benchmarks measure system performance characteristics](#filepos2300814)

> > > > > > > > [17.4.2 Mini-apps give the application perspective](#filepos2303739)

> > > > [17.5 Detecting (and fixing) memory errors for a robust application](#filepos2313203)

> > > > > > > > [17.5.1 Valgrind Memcheck: The open source standby](#filepos2314873)

> > > > > > > > [17.5.2 Dr. Memory for your memory ailments](#filepos2316325)

> > > > > > > > [17.5.3 Commercial memory tools for demanding applications](#filepos2321761)

> > > > > > > > [17.5.4 Compiler-based memory tools for convenience](#filepos2322340)

> > > > > > > > [17.5.5 Fence-post checkers detect out-of-bounds memory accesses](#filepos2322814)

> > > > > > > > [17.5.6 GPU memory tools for robust GPU applications](#filepos2328725)

> > > > [17.6 Thread checkers for detecting race conditions](#filepos2329836)

> > > > > > > > [17.6.1 Intel® Inspector: A race condition detection tool with a GUI](#filepos2330372)

> > > > > > > > [17.6.2 Archer: A text-based tool for detecting race conditions](#filepos2331562)

> > > > [17.7 Bug-busters: Debuggers to exterminate those bugs](#filepos2335840)

> > > > > > > > [17.7.1 TotalView debugger is widely available at HPC sites](#filepos2336988)

> > > > > > > > [17.7.2 DDT is another debugger widely available at HPC sites](#filepos2340228)

> > > > > > > > [17.7.3 Linux debuggers: Free alternatives for your local development needs](#filepos2338523)

> > > > > > > > [17.7.4 GPU debuggers can help crush those GPU bugs](#filepos2342691)

> > > > [17.8 Profiling those file operations](#filepos2345302)

> > > > [17.9 Package managers: Your personal system administrator](#filepos2353507)

> > > > > > > > [17.9.1 Package managers for macOS](#filepos2354783)

> > > > > > > > [17.9.2 Package managers for Windows](#filepos2355950)

> > > > > > > > [17.9.3 The Spack package manager: A package manager for high performance computing](#filepos2356852)

> > > > [17.10 Modules: Loading specialized toolchains](#filepos2361831)

> > > > > > > > [17.10.1 TCL modules: The original modules system for loading software toolchains](#filepos2371402)

> > > > > > > > [17.10.2 Lmod: A Lua-based alternative Modules implementation](#filepos2372172)

> > > > [17.11 Reflections and exercises](#filepos2372681)

> ** [***appendix A References***](#filepos2376280)

> ** [***appendix B Solutions to exercises***](#filepos2395627)

> ** [***appendix C Glossary***](#filepos2467586)

> ** [***index***](#filepos2503731)

***front matter***
