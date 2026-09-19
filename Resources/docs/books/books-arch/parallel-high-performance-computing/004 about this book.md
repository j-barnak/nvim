# about this book

***about this book***

One of the most important tasks for an explorer is to draw a map for those who follow. This is especially true for those of us pushing the boundaries of science and technology. Our goal in this book is to provide a roadmap for those just starting to learn about parallel and high performance computing and for those who want to broaden their knowledge of the field. High performance computing is a rapidly changing field, where languages and technologies are constantly in flux. For this reason, we’ll focus on the fundamentals that stay steady over time. For the computer languages for CPUs and GPUs, we stress the common patterns across the many languages, so that you can quickly select the most appropriate language for your current task.

***Who should read this book***

This book is targeted at both upper division undergraduate parallel computing classes and as state-of-the-art literature for computing professionals. If you are interested in performance, whether it be run time, scale, or power, this book will give you the tools to improve your application and outperform your competition. With processors reaching the limits of scale, heat, and power, we cannot count on the next generation computer to speed up our applications. Increasingly, highly skilled and knowledgeable programmers are critical for getting maximum performance from today’s applications.

In this book, we hope to get across key ideas true for today’s high performance computing hardware. These are the basic truths of programming for performance. These themes underlie the entire book.

> > > > In high performance computing, it is not how fast you write the code, it is how fast the code you write runs.

This one thought sums up what it means to write applications for high performance computing. For most other applications, the focus is on how fast you can write an application. Today, computer languages are typically designed to promote quicker programming rather than better performing code. Although this programming approach has long infused high performing computing applications, it has not been widely documented or described. In chapter 4, we discuss this different focus in a programming methodology that has recently been coined as data-oriented design.

> > > > It is all about memory: how much you use and how often you load it.

Even when you know that available memory and memory operations are almost always the limiting factor in performance, we still tend to spend a lot of time thinking about floating-point operations. With most current computing hardware capable of 50 floating-point operations for every memory load, floating-point operations are a secondary concern. In almost every chapter, we use our implementation of the STREAM benchmark, a memory performance test, to verify that we are getting reasonable performance from the hardware and programming language.

> > > > If you load one value, you get eight or sixteen.

It’s like buying eggs. You can’t get just one. Memory loads are done by cache lines of 512 bits. For a double-precision value of 8 bytes, eight values will be loaded whether you want them or not. Plan your program to use more than one value, and preferably eight contiguous values, for best performance. And while you are at it, use the rest of the eggs.

> > > > If there are any flaws in your code, parallelization will expose them.

Code quality requires more attention in high performance computing than a comparable serial application. This applies to before beginning parallelization, during parallelization, and after parallelization. With parallelization, you are more likely to trigger a flaw in your program and will also find debugging more challenging, especially at large scale. We introduce the techniques for improving software quality in chapter 2, then throughout the chapters we mention important tools, and finally, in chapter 17, we list other tools that can prove valuable.

These key themes transcend hardware types applying equally to all CPUs and GPUs. These exist because of the current physical constraints imposed on the hardware.

***How this book is organized: A roadmap***

This book does not expect that you have any knowledge of parallel programming. It does expect that readers are proficient programmers, preferably in a compiled, high performance computing language such as C, C++, or Fortran. It is also expected that readers have some knowledge of computing terminology, operating system basics, and networking. Readers should also be able to find their way around their computer, including installing software and light system administration tasks.

The knowledge of computing hardware is perhaps the most important requirement for readers. We recommend opening up your computer, looking at each component, and getting an understanding of its physical characteristics. If you cannot open up your computer, see the photos of a typical desktop system at the end of appendix C. For example, look at the bottom of the CPU in figure C.2 and at the forest of pins going into the chip. Can you fit any more pins there? Now you can see why there is a physical limit to how much data can be transferred to the CPU from other parts of the system. Flip back to these photos and the glossary in appendix A when you need to have a better understanding of the computing hardware or computing terminology.

We have divided this book into four parts that comprise the world of high performance computing. These are

- Part 1: Introduction to parallel computing (chapters 1-5)

- Part 2: Central processing unit (CPU) technologies (chapters 6-8)

- Part 3: Graphics processing unit (GPU) technologies (chapters 9-13

- Part 4: High performance computing (HPC) ecosystems (chapters 14-17)

The order of topics is oriented towards someone tackling a high performance computing project. For example, for an application project, the software engineering topics in chapter 2 are necessary before starting a project. Once the software engineering is in place, the next decisions are the data structures and algorithms. Then come the implementations for the CPU and GPU. Finally, the application is adapted for the parallel file system and other unique characteristics of a high performance computing system.

On the other hand, some of our readers are more interested in gaining fundamental skills in parallel programming and might want to go directly into the MPI or OpenMP chapters. But don’t stop there. Today, there is so much more to parallel computing. From GPUs that can speed up your application another order of magnitude to tools that can improve your code quality or point out sections of code to optimize—the potential gains are only limited by your time and expertise.

If you are using this book for a class on parallel computing, the scope of the material is sufficient for at least two semesters. You might think of the book as a buffet of materials that can be individualized to the audience. By selecting the topics to cover, you can customize it for your own course objectives. Here is a possible sequence of material:

- Chapter 1 provides an introduction to parallel computing

- Chapter 3 approaches measuring hardware and application performance

- Sections 4.1-4.2 describe the data-oriented design concept of programming, multi-dimensional arrays, and cache basics

- Chapter 7 covers OpenMP (Open Multi-Processing) to get on-node parallelism

- Chapter 8 covers MPI (Message Passing Interface) to get distributed parallelism across multiple nodes

- Sections 14.1-14.5 introduce affinity and process placement concepts

- Chapters 9 and 10 describe GPU hardware and programming models

- Sections 11.1-11.2 focus on OpenACC to get applications running on the GPU

You can add topics such as algorithms, vectorization, parallel file handling, or more GPU languages to this list. Or you can remove a topic so that you can spend more time on the remaining topics. There still are additional chapters to tempt students to continue to explore the world of parallel computing on their own.

***About the code***

You cannot learn parallel computing without actually writing code and running it. For this purpose, we provide a large set of examples that accompanies the book. The examples are freely available at <https://github.com/EssentialsOfParallelComputing>. You can download these examples either as a complete set or individually by chapter.

With the scope of the examples, hardware, and software, there will inevitably be flaws and errors in the accompanying examples. If you find something that is in error or just not complete, we encourage contributions to the examples. We have already merged in some change requests from readers, which were greatly appreciated. Additionally, the source code repository will be the best place to look for corrections and source code discussions.

***Software/hardware requirements***

Perhaps the biggest challenge in parallel and high performance computing is the wide range of hardware and software that is involved. In the past, these specialized systems were only available at specific sites. Recently, the hardware and software has become more democratized and widely available even at the desktop or laptop level. This is a substantial shift that can make software for high performance computing much easier to develop. However, the setup of the hardware and software environment is the most difficult part of the task. If you have access to a parallel computing cluster where these are already set up, we encourage you to take advantage of it. Eventually, you may want to set up your own system. The examples are easiest to use on a Linux or Unix system, but should also work on Windows and the MacOS in many cases with some additional effort. We have provided alternatives with Docker container templates and VirtualBox setup scripts when you find that the example doesn’t run on your system.

The GPU exercises require GPUs from the different vendors, including NVIDIA, AMD Radeon, and Intel. Anyone who has struggled to get GPU graphics drivers installed on their system will not be surprised that these present the greatest difficulty in setting up your local system for the examples. Some of the GPU languages also can work on the CPU, allowing the development of code on a local system for hardware that you do not have. You may also find that debugging on the CPU is easier. But to see the actual performance, you will have to have the actual GPU hardware.

Other examples requiring special installation include the batch system and the parallel file examples. A batch system requires more than a single laptop or workstation to set it up to look like a real installation. Similarly, the parallel file examples work best with a specialized filesystem like Lustre, though the basic examples will work on a laptop or workstation.

***liveBook discussion forum***

Purchase of Parallel and High Performance Computing includes free access to a private web forum run by Manning Publications where you can make comments about the book, ask technical questions, and receive help from the authors and from other users. To access the forum, go to <https://livebook.manning.com/#!/book/parallel-and-high-performance-computing/discussion>. You can also learn more about Manning’s forums and the rules of conduct at <https://livebook.manning.com/#!/discussion>. Manning’s commitment to our readers is to provide a venue where a meaningful dialogue between individual readers and between readers and the authors can take place. It is not a commitment to any specific amount of participation on the part of the authors, whose contribution to the forum remains voluntary (and unpaid). We suggest you try asking the authors some challenging questions lest their interest stray! The forum and the archives of previous discussions will be accessible from the publisher’s website as long as the book is in print.

***Other online resources***

Manning Publications also provides an online discussion forum called livebook for each book. Our site is at <https://livebook.manning.com/book/parallel-and-high-performance-computing>. This is a good place to add comments or expand on the materials in the chapters.

***About the cover illustration***

The figure on the cover of Parallel and High Performance Computing is captioned “M’de de brosses à Vienne,” or  “Seller of brushes in Vienna.” The illustration is taken from a collection of dress costumes from various countries by Jacques Grasset de Saint-Sauveur (1757-1810), titled Costumes de Différents Pays, published in France in 1797. Each illustration is finely drawn and colored by hand. The rich variety of Grasset de Saint-Sauveur’s collection reminds us vividly of how culturally apart the world’s towns and regions were just 200 years ago. Isolated from each other, people spoke different dialects and languages. In the streets or in the countryside, it was easy to identify where they lived and what their trade or station in life was just by their dress.

The way we dress has changed since then and the diversity by region, so rich at the time, has faded away. It is now hard to tell apart the inhabitants of different continents, let alone different towns, regions, or countries. Perhaps we have traded cultural diversity for a more varied personal life—certainly for a more varied and fast-paced technological life.

At a time when it is hard to tell one computer book from another, Manning celebrates the inventiveness and initiative of the computer business with book covers based on the rich diversity of regional life of two centuries ago, brought back to life by Grasset de Saint-Sauveur’s pictures.

***about the authors***

Robert (Bob) Robey is a technical staff scientist in the Computational Physics Division at Los Alamos National Laboratory and an adjunct researcher at the University of New Mexico. He is a founder of the Parallel Computing Summer Research Internships started in 2016. He is a member of the NSF/IEEE-TCPP Curriculum Initiative on Parallel and Distributed Computing. Bob is a board member of the New Mexico Supercomputing Challenge, a high school and middle school educational program in its 30th year. He has mentored hundreds of students over the years and has twice been recognized as a Los Alamos Distinguished Student Mentor. Bob co-taught a parallel computing class at University of New Mexico and has given guest lectures at other universities.

Bob began his scientific career by operating explosive-driven and compressible gas-driven shock tubes at the University of New Mexico. This includes the largest explosively-driven shock tube in the world at 20 feet in diameter and over 800 feet long. He conducted hundreds of experiments with explosions and shock waves. To support his experimental work, Bob has written several compressible fluid dynamics codes since the early 1990s and has authored many articles in international journals and publications. Full 3D simulations were a rarity at the time, stressing compute resources to the limit. The search for more compute resources led to his involvement in high performance computing research.

Bob worked 12 years at the University of New Mexico conducting experiments, writing, and running compressible fluid dynamics simulations, and started a high performance computing center. He was a lead proposal writer and brought tens of millions of dollars of research grants to the university. Since 1998, he has held a position at the Los Alamos National Laboratory. While there, he contributed to large multi-physics codes running on a variety of the latest hardware.

Bob is a world-class kayaker with first descents down previously unrun rivers in Mexico and New Mexico. He is also a mountaineer with ascents of peaks on three continents up to over 18,000 feet in elevation. He is a leader in the co-ed Los Alamos Venture crew and helps out with multi-day trips down western rivers.

Bob is a graduate of Texas A&M University with a Masters in Business Administration and a Bachelors degree in Mechanical Engineering. He has taken graduate coursework at University of New Mexico in the Mathematics Department.

Yuliana (Yulie) Zamora is completing her PhD in Computer Science at the University of Chicago. Yulie is a 2017 fellow at the CERES Center of Unstoppable Computing at the University of Chicago and a National Physical Science Consortium (NPSC) graduate fellow.

Yulie has worked at the Los Alamos National Laboratory and interned at Argonne National Laboratory. At Los Alamos National Laboratory, she optimized the Higrad Firetec code used for simulating wildland fires and other atmospheric physics for some of the top high performance computing systems. At Argonne National Laboratory, she worked at the intersection of high performance computing and machine learning. She has worked on projects ranging from performance prediction on NVIDIA GPUs to machine learning surrogate models for scientific applications.

Yulie developed and taught an Introduction to Computer Science course for incoming University of Chicago students. She incorporated many of the basic concepts of parallel computing fundamentals into the material. The course was so successful, she was asked to teach it again and again. Wanting to gain more teaching experience, she volunteered for a teaching assistant position for an Advanced Distributed Systems course at the University of Chicago.

Yulie’s Bachelors degree is in Civil Engineering from Cornell University. She finished her Masters of Computer Science from University of Chicago and will soon complete her PhD in Computer Science, also from the University of Chicago.
