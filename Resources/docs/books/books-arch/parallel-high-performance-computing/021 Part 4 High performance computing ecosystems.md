# Part 4 High performance computing ecosystems

***Part 4 High performance computing ecosystems***

With today’s high performance computing (HPC) systems, it is not enough for you to just learn parallel programming languages. You also need to understand many aspects of the ecosystem including the following:

- Placing and scheduling your processes for better performance

- Requesting and scheduling resources using an HPC batch system

- Writing and reading data in parallel on parallel file systems

- Making full use of the tools and resources to analyze performance and assist software development

These are just some of the important topics that surround the core parallel programming languages; forming a complementary set of capabilities we call the HPC ecosystem.

Our computing systems are exponentially growing in both complexity and the number of cores. Many of the considerations in HPC are also becoming important for high-end workstations. With so many processor cores, we need to control the placement and scheduling of processes within a node, a practice that is loosely called process affinity and done in conjunction with the OS kernel. As the number of cores on processors grows, the tools for controlling process affinity are quickly being developed to help with new concerns about process placement. We’ll cover some of the techniques that are available for assigning process affinity in chapter 14.

Sophisticated resource management systems have become ubiquitous due to the growth in complexity of computing resources. These “batch systems” form a queue of requests for the resources and allocate these out, according to a priority system called a fair share algorithm. When you first get on an HPC system, the batch system can be confusing. Without knowing how to use a scheduler, you cannot deploy your applications on these large machines. This is why we think it’s essential to go over the basics of using the most common batch systems in chapter 15.

We also don’t just write out files the same way on HPC systems; we write these out in parallel to special filesystem hardware that can stripe the file writes across multiple disks simultaneously. For exploiting the power of these parallel filesystems, you need to learn about some of the software used for parallel file operations. In chapter 16, we show you how to use MPI-IO and HDF5, which are a couple of the more common parallel file software libraries. With data sets growing ever larger, the potential uses of parallel file software is expanding far outside the traditional HPC applications.

Chapter 17 covers a broad range of important tools and resources for the HPC application developer. You might find profilers of great value in helping your application performance. There is a wide range of profilers for different use cases and hardware such as GPUs. There are also tools that help with the software development process. These tools allow you to produce correct, robust applications. Additionally, many application developers can discover specialized approaches for their application from the wide variety of sample applications.

The capabilities of the HPC ecosystem are becoming more important as the complexity and scale of our computing platforms grow. The knowledge of how to use these capabilities has often been neglected. We hope that by covering these often overlooked aspects of high-performance computing in these four chapters, you will be able to get more productive use from your computing hardware.
