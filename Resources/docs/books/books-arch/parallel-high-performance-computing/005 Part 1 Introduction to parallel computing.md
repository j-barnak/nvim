# Part 1 Introduction to parallel computing

***Part 1 Introduction to parallel computing***

The first part of this book covers topics of general importance to parallel computing. These topics include

- Understanding the resources in a parallel computer

- Estimating the performance and speedup of applications

- Looking at software engineering needs particular to parallel computing

- Considering choices for data structures

- Selecting algorithms that perform and parallelize well

While these topics should be considered first by a parallel programmer, these will not have the same importance to all readers of this book. For the parallel application developer, all of the chapters in this part address upfront concerns for a successful project. A project needs to select the right hardware, the right type of parallelism, and the right kind of expectations. You should determine the appropriate data structures and algorithms before starting your parallelization efforts; it’s much harder to change these later.

Even if you are a parallel application developer, you may not need the full depth of material discussed. Those desiring only modest parallelism or serving a particular role on a team of developers might find a cursory understanding of the content sufficient. If you just want to explore parallel computing, we suggest reading chapter 1 and chapter 5, then skimming the others to get the terminology that is used in discussing parallel computing.

We include chapter 2 for those who may not have a software engineering background or for those who just need a refresher. If you are new to all of the details of CPU hardware, then you may need to read chapter 3 in small increments. An understanding of the current computing hardware and your application is important in extracting performance, but it doesn’t have to come all at once. Be sure to return to chapter 3 when you are ready to purchase your next computing system so you can cut through all the marketing claims to what is really important for your application.

The discussion of data design and performance modeling in chapter 4 can be challenging because it requires an understanding of hardware details, their performance, and compilers to fully appreciate. Although it’s an important topic due to the impact the cache and compiler optimizations have on performance, it’s not necessary for writing a simple parallel program.

We encourage you to follow along with the accompanying examples for the book. You should spend some time exploring the many examples that are available in these software repositories at <https://github.com/EssentialsOfParallelComputing>.

The examples are organized by chapter and include detailed information for setup on various hardware and operating systems. For helping to deal with portability issues, there are sample container builds for Ubuntu distributions in Docker. There are also instructions for setting up a virtual machine through VirtualBox. If you have a need for setting your own system up, you may want to read the section on Docker and virtual machines in chapter 13. But containers and virtual machines come with restricted environments that are not easy to work around.

Our work is ongoing for the container builds and other system environment setups to work properly for the many possible system configurations. Getting the system software installed correctly, especially the GPU driver and associated software, is the most challenging part of the journey. The wide variety of operating systems, hardware including graphics processing units (GPUs), and the often overlooked quality of installation software makes this a difficult task. One alternative is to use a cluster where the software is already installed. Still, it is helpful at some point to get some software installed on your laptop or desktop for a more convenient development resource. Now it is time to turn the page and enter the world of parallel computing. It is a world of nearly unlimited performance and potential.
