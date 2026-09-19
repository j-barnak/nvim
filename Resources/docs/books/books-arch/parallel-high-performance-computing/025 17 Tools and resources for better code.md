# 17 Tools and resources for better code

***17 Tools and resources for better code***

This chapter covers

- Potential tools for your development toolbelt
- Various resources to guide your application development
- Common tools to work on large computing sites

Why a whole chapter on tools and resources? Though we’ve mentioned tools and resources in previous chapters, this chapter further discusses the wide variety and alternatives available to high-performance computing programmers. From version control systems to debugging, the available capabilities, whether commercial or open source, are essential to enable the rapid iterations of parallel application development. Nonetheless, these tools are not mandatory. Having an understanding of and embedding these into your workflow often yields tremendous benefits, far outweighing the time spent learning how to use them.

Tools are an important piece of the high-performance computing development process. Not every tool works on every system; therefore, availability of alternatives is important. In the previous chapters, we wanted to focus on the process and not get bogged down in the details of how to use every possible tool. We chose to present the simplest, most available tool for each need. We also preferred the command-line and text-based tools over the fancy graphical interface tools because using graphics interfaces over slow networks can be difficult or even impossible. Graphical tools also tend to be more vendor- or system-centric and often change. Despite these drawbacks, we include many of these vendor tools in this chapter because they can greatly improve your code development for high-performance computing applications.

Resources such as a wide variety of benchmark applications, are valuable because applications don’t come in just one flavor. For these specialized application domains, we need more appropriate benchmarks and mini-apps that explore the best approach for algorithm development and the right programming pattern for each architecture. We strongly recommend that you learn from these resources rather than reinventing the techniques from scratch. For most of the tools, we give brief instructions on installation and where to find some documentation. We also provide more detail in the companion code for this chapter at [https://github.com/EssentialsofParallelComputing/ Chapter17](https://github.com/EssentialsofParallelComputing/Chapter17).

We are strongly vendor-agnostic and stress portability as well. Although we cover a lot of tools, it just isn’t possible to go into detail on all of them. In addition, the rate of change for these tools exceeds that of the rest of the high-performance computing ecosystem. History has shown that the support for good tool development is fickle. Thus, the tools come and go and change ownership more quickly than documentation can be updated.

For a quick reference, table 17.1 provides a summary of the tools we cover in this chapter. These are shown in their corresponding categories to help you find the best tools for your needs. We included a wide variety of tools because there may be only one that works on a particular hardware or operating system or may have specialized capabilities. We have chosen to give more details on some of the simpler, more useful and commonly used tools in the following sections of this chapter as indicated in the table.

**Table 17.1 Summary of tools covered in this chapter**

[TABLE]

***17.1 Version control systems: It all begins here***

Version control for software is one of the most basic of software engineering practices and critically important when developing parallel applications. We covered the role of version control in parallel application development in section 2.1.1. Here, we go into more detail on the various version control systems and their characteristics. Version control systems can be broken down into two major categories, distributed and centralized, as figure 17.1 shows.

**Figure 17.1 Selecting a type of version control is dependent on your work pattern. Centralized version control is for when everyone is at a location with access to a single server. Distributed version control gives you a full copy of your repository on your laptop and desktop and allows you to go worldwide and mobile.**

In a centralized version control system there is just one central repository. This requires a connection to the repository site to do any operations on the repository. In a distributed version control system, various commands, such as `clone`, create a duplicate (remote) version of the repository and a checkout of the source. You can commit your changes to your local version of the repository while traveling, then push or merge the changes into the main repository at a later time. No wonder distributed version control systems have gained popularity in recent years. That said, these also come with another layer of complexity.

***17.1.1 Distributed version control fits the more mobile world***

Many code teams are scattered across the globe or on the move all the time. For them, a distributed version control system makes the most sense. The two most common freely-available distributed version control systems are Git and Mercurial. There are several other smaller distributed version control systems as well. All of these implementations support a variety of developer workflows.

Despite claims to be easy to learn, these are complex tools to fully understand and use properly. It would take a full book to cover each of these. Fortunately, there are many web tutorials and books that cover their use. A good starting point for Git resources is the Git SCM site: <https://git-scm.com>.

Mercurial is a bit simpler and has a cleaner design than Git. Additionally, the Mercurial website has a lot of tutorials to get you started.

- Mercurial at <https://www.mercurial-scm.org/wiki/Mercurial>

- Bryan O’Sullivan, Mercurial: The Definitive Guide (O’Reilly Media, 2009), [http:// hgbook.red-bean.com](http://hgbook.red-bean.com)

There are also some commercially distributed version control systems. Perforce and ClearCase are the best known. With these products, you can get more support, which might be important for your organization.

***17.1.2 Centralized version control for simplicity and code security***

While there are many centralized version control systems that have been developed over a long history of software configuration management, the two most commonly used today are Concurrent Versions System (CVS) and Subversion (SVN). Both are a bit dated these days as interest has shifted towards distributed version control. If used in the proper way for a centralized repository, however, these are both effective and much simpler to use.

Centralized version control also provides better security for proprietary codes by having only one place where the repository needs to be protected. For this reason, centralized version control is still popular in the corporate environment, where limiting access to the source code history is of paramount importance. CVS has a simple branching operation that works well. There is documentation at the CVS website and a widely available book:

- CVS (Free Software Foundation, Inc., 1998) at <https://www.nongnu.org/cvs/>

- Per Cederqvist, Version Management with CVS (Network Theory Ltd, December, 2002), available at various sites online and in print

Subversion was developed as a replacement for CVS. Although in many respects, it is an improvement over CVS, the branching function is a bit weaker than that in CVS. There is a good book on Subversion and development is ongoing:

Ben Collins-Sussman, Brian W. Fitzpatrick, and C. Michael Pilato, Version Control with Subversion (Apache Software Foundation, 2002), <http://svnbook.red-bean.com>

***17.2 Timer routines for tracking code performance***

It is helpful to put internal timers into your application to track performance as you work on it. We show a representative timing routine in listings 17.1 and 17.2 that you can use in C, C++, and Fortran with a Fortran wrapper routine. This routine uses the `clock_gettime` routine with a `CLOCK_MONOTONIC` type to avoid problems with clock time adjustments.

**Listing 17.1 Timer header file**

> `timer.h`  
> `1 #ifndef TIMER_H`  
> `2 #define TIMER_H`  
> `3 #include <time.h>`  
> `4`  
> `5 void cpu_timer_start1(struct timespec *tstart_cpu);`  
> `6 double cpu_timer_stop1(struct timespec tstart_cpu);`  
> `7 #endif`

**Listing 17.2 Timer source file**

> `timer.c`  
> `1 #include <time.h>`  
> `2 #include "timer.h"`  
> `3`  
> `4 void cpu_timer_start1(struct timespec *tstart_cpu)`  
> `5 {`  
> `6    clock_gettime(CLOCK_MONOTONIC, tstart_cpu);             `❶  
> `7 }`  
> `8 double cpu_timer_stop1(struct timespec tstart_cpu)`  
> `9 {`  
> `10    struct timespec tstop_cpu, tresult;`  
> `11    clock_gettime(CLOCK_MONOTONIC, &tstop_cpu);             `❶  
> `12    tresult.tv_sec = tstop_cpu.tv_sec - tstart_cpu.tv_sec;`  
> `13    tresult.tv_nsec = tstop_cpu.tv_nsec - tstart_cpu.tv_nsec;`  
> `14    double result = (double)tresult.tv_sec +`  
> `                      (double)tresult.tv_nsec*1.0e-9;`  
> `15`  
> `16    return(result);`  
> `17 }`

❶ Calls clock_gettime requesting a monotonic clock

There are other timer implementations that you can use if you need an alternative routine. Portability is one reason you may want another implementation. The `clock _gettime` routine has been supported on the macOS since Sierra 10.12, which has helped with some of the portability issues.

***ALTERNATIVE TIMER IMPLEMENTATIONS***

If you are using C++ with 2011 standards, you can use the high resolution clock, `std::chrono::high_resolution_clock`. Here we show a list of alternative timers you can use with portability across C, C++, and Fortran.

- `clock_gettime` with the `CLOCK_MONOTONIC` type

- `clock_gettime` with the `CLOCK_REALTIME` type

- `gettimeofday`

- `getrusage`

- `host_get_clock_service` for MacOS

- `clock std:chrono_high_resolution_clock` (C++ high resolution, C++ 2011 standard)

> **Example: Experiment with timers**

> Use the code at <https://github.com/EssentialsofParallelComputing/Chapter17> in the timers directory. In that directory, run the following commands:

> `mkdir build && cd build`  
> `cmake ..`  
> `make`  
> `./runit.sh`

> This example builds the various timer implementations and runs them. This example gives you some ideas for alternate options if the default version does not work or doesn’t behave well on your system.

The `clock_gettime` function has two versions. Although the `CLOCK_MONOTONIC` is preferred, it’s not a required type for Portable Operating System Interface (POSIX), the standard for portability across operating systems. In the timers directory of the examples that accompany this chapter, we include a version with the `CLOCK_REALTIME` timer type. The `gettimeofday` and `getrusage` functions are widely portable and might work on systems where `clock_gettime` does not.

***17.3 Profilers: You can’t improve what you don’t measure***

A profiler is a programmer tool that measures some aspect of the performance of an application. We covered profiling earlier in sections 2.2 and 3.3 as a key part of the application development process and introduced a couple of the simpler profiling tools. In this section, we’ll cover some of the alternative profiling tools that you might consider for your application development and introduce you to how to use some more of the simpler profilers. Profilers are important tools in developing parallel applications when:

- You want to work on a section of code that has the most impact in improving the performance of your application. This section of code is often referred to as the bottleneck.

- You want to measure your performance improvement on various architectures. After all, we are all about performance in high performance computing applications.

Profilers come in a variety of shapes and sizes. We’ll break down our discussion into categories that reflect their broad characteristics. It is important to use a tool from the appropriate category. It is not advisable to use a heavy-weight profiling tool when all you want is to find the biggest bottleneck. The wrong tool will bury you in an avalanche of information that will leave you digging yourself out for hours or days. Save the heavy-weight tools when you really need to dive down into the low-level details of your application. We suggest starting with simple profilers and working up to the detailed profilers when needed. Our categories of profilers follow this simple-to-complex hierarchy with some subjective judgment where each profiling tool falls in the list.

**Table 17.2 Categories of profiling tools (simple to complex)**

|                             |                                                                                                           |
|-----------------------------|-----------------------------------------------------------------------------------------------------------|
| Simple text-based profilers | Returns a short text-based summary of performance                                                         |
| High-level profilers        | A top-down profiler that highlights the routines needing improvement, often in a graphical user interface |
| Medium-level profilers      | Profilers that give a manageable amount of performance data                                               |
| Detailed profilers          | Bury me with data, please                                                                                 |

High-level is not indicative of high-detail; these tools give the 25,000 ft picture of an application’s performance. We find ourselves returning to the simpler profiling tools, such as the simple text-based and high-level profilers because these are quick to use and don’t take up most of the day.

***17.3.1 Simple text-based profilers for everyday use***

Simple text-based profilers like LIKWID, gprof, gperftools, timemory, and Open\|SpeedShop are easy to incorporate into your daily application development workflow. These provide a quick insight on performance.

The likwid (Like I Knew What I’m Doing) suite of tools was first introduced in section 3.3.1 and also used in chapters 4, 6, and 9. We used it extensively because of its simplicity. There is ample documentation at the likwid website:

likwid performance tools at <https://hpc.fau.de/research/tools/likwid/>

The venerable gprof tool has been a mainstay for profiling applications on Linux for many years. We used it in section 13.4.2 for a quick profile of our application. Gprof uses a sampling approach to measure where the application is spending its time. It is a command-line tool that is enabled by adding `-pg` when compiling and linking your application. Then, when your application runs, it produces a file called gmon.out at completion. The command-line gprof utility then displays the performance data as text output. Gprof comes with most Linux systems and is part of the GCC and Clang/LLVM compilers. Gprof is relatively dated, but is readily available and simple to use. The gprof documentation is fairly simple and is widely available at the following site:

GNU Binutils documentation from The Free Software Foundation at [https:// sourceware.org/binutils/docs/gprof/index.html](https://sourceware.org/binutils/docs/gprof/index.html)

The gperftools suite (originally Google Performance Tools) is a newer profiling tool similar in functionality to gprof. The suite of tools also comes with TCMalloc, a fast malloc for applications that use threads. It also throws in a memory leak detector and a heap profiler. The gperftools CPU profiler has a website that has a short introduction to the tool:

Gperftools (Google) at <https://gperftools.github.io/gperftools/cpuprofile.html>

The timemory tool from the National Energy Research Scientific Computing Center (NERSC) is a simple tool built on top of many other performance measurement interfaces. The simplest tool in this suite, timem, is a replacement for the Linux `time` command, which can also output additional information such as the memory used and the number of bytes read and written. Notably, it has an option to automatically generate a roofline plot. The tool has extensive use information at its documentation website:

timemory documentation at <https://timemory.readthedocs.io>

Open\|SpeedShop has a command-line option and Python interface that might make it a possible substitute for these simple tools. It is a more powerful tool, which we’ll discuss in section 17.3.4.

***17.3.2 High-level profilers for quickly identifying bottlenecks***

High-level tools are the best choice for a quick overview of the performance of your application. These tools distinguish themselves by focusing on identifying the high-cost parts of your code and giving a robust graphics-based overview of application performance. Unlike the simple profilers, you must often step out of your workflow and start a graphics application in order to use these high-level profilers.

We first talked about Cachegrind in section 3.3.1. Cachegrind specializes in showing you the high-cost paths through your code, enabling you to focus on the performance critical parts. It has a simple graphical user interface that is easy to understand.

Cachegrind, a cache and branch-prediction profiler (Valgrind™ Developers) at <https://valgrind.org/docs/manual/cg-manual.html>

Another good high-level profiler is the Arm MAP profiler, previously named Allinia Map or Forge Map. MAP is a commercial tool and its parent firm has changed a few times. It utilizes a graphic user interface that gives more detail than KCachegrind, but still focuses on the most salient details. The MAP tool has a companion tool, the DDT debugger, that comes in the Arm Forge suite of high-performance computing tools. We’ll discuss the DDT debugger later in the chapter in section 17.7.2. There is extensive documentation, tutorials, webinars, and a user guide at the ARM website:

Arm MAP (Arm Forge) at <http://mng.bz/n2x2>

***17.3.3 Medium-level profilers to guide your application development***

Medium-level profilers are often used when trying to fine-tune optimizations. Many of the graphical user interface tools designed to guide your application development fall into this category. These include Intel® Advisor, VTune, CrayPat, AMD μProf, NVIDIA Visual Profiler, and CodeXL (formerly a Radeon tool and now part of the GPUOpen initiative). We start with the more general and popular tools for CPUs and then work into the specialized tools for GPUs.

Intel® Advisor is targeted at guiding the use of vectorization with Intel compilers. It shows which loops are vectorized and suggests changes to vectorize others. While it is especially useful for vectorizing code, it is also good for general profiling. Advisor is a proprietary tool, but recently has been made freely available for many users. You can install Intel Advisor using the Ubuntu package manager. You need to add the Intel package and then use `apt-get` to install the version with OneAPI.

> `wget -q https:/ /apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2023.PUB`  
> `apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS-2023.PUB`  
> `rm -f GPG-PUB-KEY-INTEL-SW-PRODUCTS-2023.PUB`  
> `echo "deb https:/ /apt.repos.intel.com/oneapi all main" >>`  
> `    /etc/apt/sources.list.d/oneAPI.list`  
> `echo "deb [trusted=yes arch=amd64] https:/ /repositories.intel.com/graphics/ubuntu bionic`  
> `    main" >> /etc/apt/sources.list.d/intel-graphics.list`  
> `apt-get update`  
> `apt-get install intel-oneapi-advisor`

Complete instructions on installing the Intel OneAPI software from its package repository can be found at <http://mng.bz/veO4>.

Intel® VTune is a general-purpose optimization tool that helps to identify bottlenecks and potential improvements. It is also another proprietary tool that’s freely available. VTune can be installed with `apt-get` from the OneAPI suite.

> `wget -q https:/ /apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2023.PUB`  
> `apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS-2023.PUB`  
> `rm -f GPG-PUB-KEY-INTEL-SW-PRODUCTS-2023.PUB`  
> `echo "deb https:/ /apt.repos.intel.com/oneapi all main" >>`  
> `    /etc/apt/sources.list.d/oneAPI.list`  
> `echo "deb [trusted=yes arch=amd64] https:/ /repositories.intel.com/graphics/ubuntu bionic`  
> `    main" >> /etc/apt/sources.list.d/intel-graphics.list`  
> `apt-get update`  
> `apt-get install intel-oneapi-vtune`

The CrayPat tool is a proprietary tool that is only available on Cray Operating Systems. It is an excellent command-line tool that gives simple feedback on optimization of loops and threading. If you are working on one of the many high-performance computing sites that use the Cray Operating System, this tool may be worth investigating. Unfortunately, it is not available elsewhere.

AMD μProf is the profiling tool from AMD for their CPUs and APUs. Accelerated Processing Unit (APU) is the AMD term for a CPU with an integrated GPU that was first introduced when AMD bought out ATI, manufacturer of the Radeon GPU. The integrated unit is more tightly coupled than a typical integrated GPU and is part of the Heterogeneous System Architecture concept from AMD. You can install the AMD μProf tool with package installers on Ubuntu or Red Hat Enterprise Linux. The download requires a manual acceptance of the EULA. To install AMD μProf, follow these steps:

1.  Go to <https://developer.amd.com/amd-uprof/>

2.  Scroll down to the bottom of the page and select the appropriate file

3.  Accept the EULA to start the download with the package manager

> `Ubuntu: dpkg --install amduprof_x.y-z_amd64.deb`  
> `RHEL: yum install amduprof-x.y-z.x86_64.rpm `

More details on installation are given in the user guide, which is available at the AMD developer website: [https://developer.amd.com/wordpress/media/2013/12/User\_ Guide.pdf](https://developer.amd.com/wordpress/media/2013/12/User_Guide.pdf).

NVIDIA Visual Profiler is part of the CUDA software suite. It is being incorporated into the NVIDIA® Nsight suite of tools. We covered this tool in section 13.4.3. The NVIDIA tools can be installed on the Ubuntu Linux distribution with the following commands:

> `wget -q https:/ /developer.download.nvidia.com/`  
> `   compute/cuda/repos/ubuntu1804/x86_64/cuda-repo-ubuntu1804_10.2.89-1_amd64.deb`  
> `dpkg -i cuda-repo-ubuntu1804_10.2.89-1_amd64.deb`  
> `apt-key adv --fetch-keys https:/ /developer.download.nvidia.com/`  
> `   compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub`  
> `apt-get update`  
> `apt-get install cuda-nvprof-10-2 cuda-nsight-systems-10-2 cuda-nsight-compute-10-2`

CodeXL is the GPUOpen code development workbench with profiling support for Radeon GPUs. It is part of the GPUOpen open source initiative begun by AMD. The CodeXL tool combines both debugger and profiler functionality. The CPU profiling has been moved to the AMD μProf tool so that the CodeXL tool could be moved to an open source status. Follow the instructions to install CodeXL on Ubuntu or RedHat Linux distributions.

> `wget https:/ /github.com/GPUOpen-Archive/ `  
> `          CodeXL/releases/download/v2.6/codexl-2.6-302.x86_64.rpm`  
> `RHEL or CentOS: rpm -Uvh --nodeps codexl-2.6-302.x86-64.rpm`  
> `Ubuntu: apt-get install rpm`  
> `        rpm -Uvh --nodeps codexl-2.6-302.x86-64.rpm`

***17.3.4 Detailed profilers give the gory details of hardware performance***

There are several tools that produce detailed application profiling. If you need to extract every bit of performance from your application, you should learn to use at least one of these tools. The challenge with these tools is that they produce so much information, it can be time-consuming to understand and use the results. You will also need to have some hardware architecture expertise to really make sense of the profiling data. The tools from this category should be used after you have gotten what you can out of the simpler profiling tools. The detailed profilers that we cover in this section are HPCToolkit, Open\|SpeedShop, and TAU.

HPCToolkit is a powerful, detailed profiler developed as an open source project by Rice University. HPCToolkit uses hardware performance counters to measure performance and presents the data using graphical user interfaces. The development for extreme scale on the latest high-performance computing systems is sponsored by the Department of Energy (DOE) Exascale Computing Project. Its hpcviewer GUI shows performance data from a code perspective while the hpctraceviewer presents a time trace of the code execution. More information and detailed user guides are available at the HPCToolkit website. HPCToolkit can be installed with the Spack package manager with `spack install hpctoolkit`.

HPCToolkit at <http://hpctoolkit.org>

Open\|SpeedShop is another profiler that can produce detailed program profiles. It has both a graphical user interface and a command-line interface. The Open\|SpeedShop tool runs on all the latest high-performance computing systems as a result of DOE funding. It has support for MPI, OpenMP, and CUDA. Open\|Speedshop is open source and can be freely downloaded. Their website has detailed user guides and tutorials. Open\|Speedshop can be installed with the Spack package manager with `spack install openspeedshop`.

Open\|Speedshop at <https://openspeedshop.org>

TAU is a profiling tool developed primarily at the University of Oregon. This freely available tool has a graphical user interface that is easy to use. TAU is used on many of the largest high-performance computing applications and systems. There is extensive documentation on using TAU at the tool’s website. TAU can be installed with the Spack package manager with `spack install tau`.

Performance Research Lab (University of Oregon) at [http://www.cs.uoregon.edu/ research/tau/home.php](http://www.cs.uoregon.edu/research/tau/home.php)

***17.4 Benchmarks and mini-apps: A window into system performance***

We noted the value of benchmarks and mini-apps for assessing the performance of your applications in chapter 3. Benchmarks are more appropriate for measuring the performance of a system. Mini-apps are more focused on application areas and how best to implement the algorithms for various architectures, but the difference between these can be blurred at times.

***17.4.1 Benchmarks measure system performance characteristics***

The following is a list of benchmarks that can be useful measures for your potential system performance. We have extensively used the STREAM Benchmark in our performance studies, but there may be more appropriate benchmarks for your application. For example, if your application loads a single data value from scattered memory locations, the Random benchmark would be the most appropriate.

- Linpack at <http://www.netlib.org/benchmark/hpl/>—Used for the Top 500 High Performance Computers list.

- STREAM at <https://www.cs.virginia.edu/stream/ref.html>—A benchmark for memory bandwidth. You can find a version in the Git repository at [https:// github.com/jeffhammond/STREAM.git](https://github.com/jeffhammond/STREAM.git).

- Random at <http://icl.cs.utk.edu/projectsfiles/hpcc/RandomAccess/>—A benchmark for random memory access performance.

- NAS Parallel Benchmarks at <http://www.nas.nasa.gov/publications/npb.html>—NASA benchmarks, first released in 1991, include some of the most heavily used benchmarks for research.

- HPCG at <http://www.hpcg-benchmark.org/software/>—New conjugate gradient benchmark developed as an alternative to Linpack. HPCG gives a more realistic performance benchmark for current algorithms and computers.

- HPC Challenge Benchmark at <http://icl.cs.utk.edu/hpcc/>—A composite benchmark.

- Parallel Research Kernels at <https://github.com/ParRes/Kernels>—Various small kernels from typical scientific simulation codes and in several parallel implementations.

***17.4.2 Mini-apps give the application perspective***

Applications have had to make many adaptations for new architectures. With the use of mini-apps, you can highlight the performance of a simple application type on a target system. This section presents a list of mini-apps developed by the Department of Energy (DOE) laboratories, which might be a valuable reference implementation for your application.

The DOE laboratories have been tasked with the development of exascale computers, which provide the leading edge of high-performance computing. These laboratories have created mini-apps and proxy applications for hardware designers and application developers to experiment with how to get the most out of these exascale systems. Each of these mini-apps has a different purpose. Some reflect the performance of a large application, while others are meant for algorithmic exploration. To begin, let’s define a couple of terms to help us categorize the mini-apps.

- Proxy mini-app—An extract or smaller form of a larger application that captures its performance characteristics. Proxies are useful to hardware vendors in a co-design process as a smaller application that they can use in the hardware design process.

- Research mini-app—A simpler form of a computational approach that is useful for researchers to explore alternative algorithms and methods for improved performance and new architectures.

The categorization of mini-apps is not perfect. Each author of a mini-app has their own reason for their creation, which often doesn’t fit into neat categories.

***EXASCALE PROJECT PROXY APPS: A CROSS-SECTION OF SAMPLE APPLICATIONS***

The DOE has developed some sample applications for use in benchmarking systems, performance experiments, and algorithm development. Many of these have been organized by the DOE Exascale Computing Project at [https://proxyapps.exascaleproj ect.org/](https://proxyapps.exascaleproject.org/).

- AMG—Algebraic multi-grid example

- ExaMiniMD—Proxy application for particle and molecular dynamics codes

- Laghos—Unstructured, compressible shock hydrodynamics

- MACSio—Scalable I/O tests

- miniAMR—Block-based adaptive mesh refinement mini-app

- miniQMC—Quantum Monte Carlo mini-app

- NEKbone—Incompressible Navier-Stokes solver using spectral elements

- PICSARlite—Electromagnetic particle-in-cell

- SW4lite—3D seismic modeling kernels

- SWFFT—Fast Fourier transform

- Thornado-mini—Finite element, moment-based radiation transport

- XSBench—Kernel from a Monte Carlo neutronics app

The Exascale Project proxy applications are selected from the many proxy applications developed by national laboratories. In the following sections, we list other proxy and mini-applications developed by various national laboratories for scientific applications that are important to the mission for their research laboratory. These applications are made available to the public and hardware developers as part of the national codesign strategy. The codesign process is where hardware developers and application developers work closely together in a feedback loop that iterates the features of these exascale systems.

Often, the applications that these mini-apps mirror tend to be proprietary and, therefore, cannot be shared outside the corresponding laboratory. With the release of some of these mini-apps, we recognize that current applications are more complex and stress the hardware in different ways than the simple kernels previously available.

***LAWRENCE LIVERMORE NATIONAL LABORATORY PROXIES***

Lawrence Livermore National Laboratory has been one of the leading proponents of proxy development. Their LULESH proxy is one of the most heavily studied by vendors and academic researchers. Some of the Lawrence Livermore National Laboratory proxies include

- LULESH—Explicit Lagrangian shock hydrodynamics on an unstructured mesh representation

- Kripke—Sweep-based deterministic transport

- Quicksilver—Monte Carlo particle transport

For more detail on the Lawrence Livermore National Laboratory proxies, see their website at <https://computing.llnl.gov/projects/co-design/proxy-apps>.

***LOS ALAMOS NATIONAL LABORATORY PROXY APPLICATIONS***

Los Alamos National Laboratory also has many interesting proxy applications. Some of the more popular are listed here.

- CLAMR—Cell-based adaptive mesh refinement mini-app

- NuT—Monte Carlo proxy for neutrino transport

- Pennant—Unstructured mesh hydrodynamics mini-app

- SNAP—SN (Discrete Ordinates) application proxy

For more detail on the Los Alamos National Laboratory proxies, see their website at <https://www.lanl.gov/projects/codesign/proxy-apps/lanl/index.php>.

***SANDIA NATIONAL LABORATORIES MANTEVO SUITE OF MINI-APPS***

Sandia National Laboratories has put together a branded mini-app suite called Mantevo, which includes their mini-apps and a few from other organizations such as the United Kingdom’s Atomic Weapons Establishment (AWE). Here is list of their mini-apps:

- CloverLeaf—Cartesian grid compressible fluids hydrocode mini-app

- CoMD—Molecular dynamics mini-app

- EpetraBenchmarkTest—Dense math-solver kernels

- MiniAero—Unstructured compressible Navier-Stokes

- miniFE—Proxy application for unstructured implicit finite element codes

- miniGhost—Proxy application for ghost cell updates

- miniSMAC2D—Body-fitted incompressible Navier-Stokes solver

- miniXyce—Circuit simulation mini-app

- TeaLeaf—Proxy application for unstructured implicit finite element codes

More information on the Mantevo min-app suite is available at [https://mantevo .github.io](https://mantevo.github.io).

***17.5 Detecting (and fixing) memory errors for a robust application***

For robust applications, you need a tool to detect and report memory errors. In this section, we discuss the capabilities and the pros and cons of a number of tools that detect and report memory errors. The memory errors that occur in applications can be broken down into these categories:

- Out-of-bound errors—Attempting to access memory beyond the array bounds. Fence-post checkers and some compilers can catch these errors.

- Memory leaks—Allocating memory and never freeing it. Malloc replacement tools are good at catching and reporting memory leaks.

- Uninitialized memory—Memory that is used before it is set. Because memory is not set before its use, it has whatever value is in memory from previous use. The result is that the behavior of the application can vary from run to run. This type of error is difficult to find, and tools specifically designed to catch these are essential.

Only a few tools handle all of these categories of memory errors. Most of the tools handle the first two categories to some degree. Uninitialized memory checks are an important check and supported by just a few tools. We’ll cover those tools first.

***17.5.1 Valgrind Memcheck: The open source standby***

Valgrind checks uninitialized memory with its default Memcheck tool. We first presented Valgrind for this purpose in section 2.1.3. Valgrind is a good choice both because it is open source and freely available and because it is one of the best tools at detecting memory errors in all three categories.

It’s best to use Valgrind with the GCC compiler. The GCC team uses it for their development, and as a result cleaned up their generated code so that a suppression file for false positives is not needed for their serial applications. For parallel applications, you can also suppress the false positives detected by Valgrind with OpenMPI by using a suppression file provided by the OpenMPI package. For example

> `mpirun -n 4 valgrind \`  
> `   --suppressions=$MPI_DIR/share/openmpi/openmpi-valgrind.supp <my_app>`

There are only a few command-line options, and the Valgrind tool often suggests which options to use in its report. For more information on the usage, see the Valgrind website (<https://valgrind.org>).

***17.5.2 Dr. Memory for your memory ailments***

Yes, really, that’s its name. Dr. Memory is a similar tool to Valgrind but newer and faster. Like Valgrind, Dr. Memory detects memory errors and problems within your program. It is an open source project, freely available across a variety of chip architectures and operating systems.

There are many other tools besides Dr. Memory in this suite of run-time tools. Because Dr. Memory is a relatively simple tool, we’ll present a quick example of how to use it. Let’s first set up Dr. Memory for use.

> **Example: Using Dr. Memory to detect memory errors**

> Go to <https://github.com/DynamoRIO/drmemory/wiki/Downloads> and download the latest version for Linux:

> `tar -xzvf DrMemory-Linux-2.3.0-1.tar.gz`

> Then add it to your path with

> `export PATH=${HOME}/DrMemory-Linux-2.3.0-1/bin64:$PATH`

We’ll try out Dr. Memory on the example in the repository at [https://github.com/ EssentialsofParallelComputing/Chapter17](https://github.com/EssentialsofParallelComputing/Chapter17). The following listing is a copy of the code from listing 4.1 of chapter 4. The code is just a fragment to check that the syntax correctly compiles.

**Listing 17.3 DrMemory test example**

> `DrMemory/memoryexample.c`  
> `1 #include <stdlib.h>`  
> `2`  
> `3 int main(int argc, char *argv[])`  
> `4 {`  
> `5   int j, imax, jmax;`  
> `6`  
> `7   // first allocate a column of pointers of type pointer to double`  
> `8   double **x = (double **)                                         `❶  
> `        malloc(jmax * sizeof(double *));                              `❶  
> `9`  
> `10   // now allocate each row of data`  
> `11   for (j=0; j<jmax; j++){                                          `❷  
> `12      x[j] = (double *)malloc(imax * sizeof(double));`  
> `13   }`  
> `14 }`

❶ Uninitialized memory read of variable jmax

❷ Memory leak for variable x

Running this example takes just a few commands. Retrieve the code from the supplemental examples for the chapter and build it:

> `git clone --recursive \`  
> `    https:/ /github.com/EssentialsofParallelComputing/Chapter17`  
> `cd DrMemory`  
> `make`

Now run the example by executing `drmemory`, followed by two dashes and then the name of the executable: `drmemory— memoryexample`. Figure 17.2 shows the report that Dr. Memory produces.

**Figure 17.2 Report from Dr. Memory shows that an uninitialized read at line 11 and a memory leak for memory allocated at line 8.**

Dr. Memory correctly flags that `jmax` was not initialized when used on line 11. It also shows a leak on line 12. To fix these, we initialize `jmax` and then free each `x[j]` pointer and the `x` array, then try again with `drmemory— memoryexample`. Figure 17.3 shows the report.

**Figure 17.3 This Dr. Memory report shows that the uninitialized memory error and the leak are fixed.**

The report from Dr. Memory in figure 17.3 shows no errors after our fix. Note that Dr. Memory does not flag that `imax` is uninitialized. For more information on Dr. Memory for Windows, Linux, and Mac, see <https://drmemory.org>.

***17.5.3 Commercial memory tools for demanding applications***

Purify and Insure++ are commercial tools that detect memory errors, including some form of uninitialized memory check. TotalView includes a memory checker in its most recent versions. If you have a demanding application that requires extreme quality code, and you are looking for vendor support for your memory checking tool, one of these commercial tools may be a good choice.

***17.5.4 Compiler-based memory tools for convenience***

Many compilers are incorporating memory tools into their products. The LLVM compiler has a set of tools that includes memory checker functionality. This includes MemorySanitizer, AddressSanitizer, and ThreadSanitizer. GCC includes the mtrace component which detects memory leaks.

***17.5.5 Fence-post checkers detect out-of-bounds memory accesses***

Several tools place blocks of memory before and after memory allocations to detect out-of-bounds memory accesses and to also track memory leaks. These types of memory checkers are referred to as fence-post memory checkers. These are fairly simple tools to implement and are usually provided as a library. Additionally, these tools are portable and easy to add to a regular regression testing system.

Here we discuss dmalloc in detail and how to use a fence-post memory checker. Electric Fence and Memwatch are two other packages that provide fence-post memory checks and have an analogous use model, but dmalloc is the best known fence-post memory checker. It replaces the malloc library with a version that provides memory checking.

> **Example: Setting up dmalloc**

> To download and install dmalloc, run the following code:

> `wget https:/ /dmalloc.com/releases/dmalloc-5.5.2.tgz`  
> `tar -xzvf dmalloc-5.5.2.tgz`  
> `cd dmalloc-5.5.2/`  
> `./configure --prefix=${HOME}/dmalloc`  
> `make`  
> `make install`

> To add dmalloc to your executable path, on the command line or in your environment setup file, set your `PATH` variable:

> `export PATH=${PATH}:${HOME}/dmalloc/bin`

> Set the `DMALLOC_OPTIONS` variable. The backticks execute the command and set the variable.

> `` export `dmalloc -l logfile -i 100 low` ``

> The DMALLOC_OPTIONS variable should now be set in your environment. It may look something like this:

> `DMALLOC_OPTIONS=debug=0x4e48503,inter=100,log=logfile`

> We need to add these changes to the makefile to link in the dmalloc library and include the header file:

> `CFLAGS = -g -std=c99 -I${HOME}/dmalloc/include -DDMALLOC \`  
> `         -DDMALLOC_FUNC_CHECK`  
> `LDLIBS=-L${HOME}/dmalloc/lib -ldmalloc`

For our source code in the following listing, we added the dmalloc header file with an `include` directive on line 3 so that we get line numbers in our report.

**Listing 17.4 Dmalloc example code**

> `Dmalloc/mallocexample.c`  
> `1 #include <stdlib.h>`  
> `2 #ifdef DMALLOC`  
> `3 #include "dmalloc.h"                        `❶  
> `4 #endif`  
> `5`  
> `6 int main(int argc, char *argv[])`  
> `7 {`  
> `8    int imax=10, jmax=12;`  
> `9`  
> `10    // first allocate a block of memory for the row pointers`  
> `11    double *x = (double *)malloc(imax*sizeof(double *));`  
> `12`  
> `13    // now initialize the x array to zero`  
> `14    for (int i = 0; i < jmax; i++) {         `❷  
> `15       x[i] = 0.0;                           `❷  
> `16    }`  
> `17    free(x);`  
> `18    return(0);`  
> `19 }`

❶ Includes the dmalloc header file

❷ Writes past the end of the x array

We’ve included an out-of-bounds access on the `x` array on lines 14 and 15. Now we can build our executable and run it:

> `make`  
> `./mallocexample`

But the output to the terminal reports a failure:

> `debug-malloc library: dumping program, fatal error`  
> `   Error: failed OVER picket-fence magic-number check (err 27)`  
> `Abort trap: 6`

Let’s get more information about the problem from the log file shown in figure 17.4.

**Figure 17.4 The dmalloc log file shows an out-of-bounds memory access at line 11.**

Dmalloc has detected the out-of-bounds access. Great! You can find more information on dmalloc at its website (<https://dmalloc.com>).

***17.5.6 GPU memory tools for robust GPU applications***

GPU vendors are developing memory tools for detecting memory errors for applications running on their hardware. NVIDIA has released a corresponding tool, and other GPU vendors are sure to follow. The NVIDIA CUDA-MEMCHECK tool checks for out-of-bounds memory references, data race detections, synchronization usage errors, and uninitialized memory. The tool can be run as a standalone command:

> `cuda-memcheck [--tool memcheck|racecheck|initcheck|synccheck] <app_name> `

Documentation on the tool usage is available on the NVIDIA website:

CUDA-MEMCHECK, CUDA Toolkit Documentation at [https://docs.nvidia.com/ cuda/cuda-memcheck/index.html](https://docs.nvidia.com/cuda/cuda-memcheck/index.html)

***17.6 Thread checkers for detecting race conditions***

Tools to detect thread race conditions (also called data hazards) are critical in developing OpenMP applications. It is impossible to develop robust OpenMP applications without a race detection tool. Yet, there are few tools that can detect race conditions. Two tools that are effective are Intel Inspector and Archer, which we discuss next.

***17.6.1 Intel® Inspector: A race condition detection tool with a GUI***

Intel® Inspector is a tool with a graphical user interface that is effective at detecting race conditions in OpenMP code. We discussed Intel Inspector earlier in section 7.9. Though Inspector is an Intel proprietary tool, it is now freely available. On Ubuntu, it can be installed from the OneAPI suite from Intel:

> `wget -q https:/ /apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2023.PUB`  
> `apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS-2023.PUB`  
> `rm -f GPG-PUB-KEY-INTEL-SW-PRODUCTS-2023.PUB`  
> `echo "deb https:/ /apt.repos.intel.com/oneapi all main" >>`  
> `    /etc/apt/sources.list.d/oneAPI.list`  
> `echo "deb [trusted=yes arch=amd64] https:/ /repositories.intel.com/graphics/ubuntu bionic`  
> `    main" >> /etc/apt/sources.list.d/intel-graphics.list`  
> `apt-get install intel-oneapi-inspector`

***17.6.2 Archer: A text-based tool for detecting race conditions***

Archer is an open source tool built on LLVM’s ThreadSanitizer (TSan) and adapted for detecting thread race conditions in OpenMP. Using the Archer tool is basically just replacing the compiler command with `clang-archer` and linking in the Archer library with `-larcher`. Archer outputs its report as text.

You can manually install Archer with the LLVM compiler, or install with the Spack package manager using `spack install archer`. We have included some build scripts with the accompanying examples at [https://github.com/EssentialsofParallelComputing/ Chapter17](https://github.com/EssentialsofParallelComputing/Chapter17) for installation. Once the Archer tool is installed, you can build our example in the Archer subdirectory of the examples. In the example, we use one of the stencil codes from section 7.3.3. We then modify the CMake build system by changing the compiler command to `clang-archer` and by adding the Archer libraries to the link command as the following listing shows.

**Listing 17.5 Archer example code**

> `Archer/CMakeLists.txt`  
> `1 cmake_minimum_required (VERSION 3.0)`  
> `2 project (stencil)`  
> `3`  
> `4 set (CC clang-archer)                                                   `❶  
> `5`  
> `6 set (CMAKE_C_STANDARD 99)`  
> `7`  
> `8 set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -O3")`  
> `9`  
> `10 find_package(OpenMP)`  
> `11`  
> `12 # Adds build target of stencil with source code files`  
> `13 add_executable(stencil stencil.c timer.c timer.h malloc2D.c malloc2D.h)`  
> `14 set_target_properties(stencil PROPERTIES`  
> `     COMPILE_FLAGS ${OpenMP_C_FLAGS})`  
> `15 set_target_properties(stencil PROPERTIES LINK_FLAGS "${OpenMP_C_FLAGS}`  
> `         -L${HOME}/archer/lib -larcher")                                   `❷

❶ Sets the compiler command to clang-archer

❷ Adds the archer libraries to LINK_FLAGS

Compile the code and run it is as before:

> `mkdir build && cd build`  
> `cmake ..`  
> `make`  
> `./stencil`

We get the Archer tool output mixed in with the normal output as figure 17.5 shows.

**Figure 17.5 Output from the Archer data race detection tool**

There are some reports of race conditions reported at startup that appear to be false positives, but no additional messages during the run. For more information, check out the following documentation:

- “Archer PRUNERS: Providing Reproducibility for Uncovering Non-deterministic Errors in Runs on Supercomputers” (2017), <https://pruners.github.io/archer/>

- Archer repository at <https://github.com/PRUNERS/archer>

***17.7 Bug-busters: Debuggers to exterminate those bugs***

You spend much of your application development time fixing bugs. This is especially true in parallel application development. Any tool that helps with this process is vitally important. Parallel programmers also need additional capabilities targeted at dealing with multiple processes and threads.

The debuggers used for large parallel applications at high performance computing sites generally include a couple of commercial offerings. This includes the powerful and easy-to-use TotalView and Arm DDT debuggers. But most code development is initially done on laptops, desktops, and local clusters outside of large centers, so you may not have access to a commercial debugger on these smaller systems. The non-commercial debuggers available for smaller clusters, desktops, and laptops are more limited in parallel programming features and harder to use. In this section, we begin with a discussion of the commercial debuggers.

***17.7.1 TotalView debugger is widely available at HPC sites***

TotalView has extensive support for leading high performance computing systems, including MPI and OpenMP threading. TotalView has some support for debugging NVIDIA GPUs using CUDA. It uses a graphical user interface and is easy to navigate; it also has a great depth of features that take some exploration. TotalView is generally invoked by prefixing the command line with `totalview`. The `-a` flag indicates that the rest of the arguments are to be passed to the application:

> `totalview mpirun -a -n 4 <my_application>`

Lawrence Livermore National Laboratory has a good tutorial on Totalview. Detailed information is available at the TotalView websites:

- TotalView (Lawrence Livermore National Laboratory) at [https://computing .llnl.gov/tutorials/totalview/](https://computing.llnl.gov/tutorials/totalview/)

- TotalView (Perforce) at <https://totalview.io>

***17.7.2 DDT is another debugger widely available at HPC sites***

The ARM DDT debugger is another popular commercial debugger used at high performance computing sites. It has extensive support for MPI and OpenMP. It also has some support for debugging CUDA code. The DDT debugger uses a graphical user interface that is very intuitive. In addition, DDT has support for remote debugging. In this case, the graphical client interface is run on your local system, and the application that is being debugged is remotely launched on the high performance computing system. To start a debug session with DDT, just prepend `ddt` to your command line:

> `ddt <my_application>`

The Texas Advanced Computing Center has a good introduction to DDT. There is also more information at the DDT websites:

- ARM DDT Debugger tutorials (TACC, Texas Advanced Computing Center) at <https://portal.tacc.utexas.edu/tutorials/ddt>

- ARM DDT (ARM Forge) at [https://www.arm.com/products/development-tools/ server-and-hpc/forge/ddt](https://www.arm.com/products/development-tools/server-and-hpc/forge/ddt)

***17.7.3 Linux debuggers: Free alternatives for your local development needs***

The standard Linux debugger, GDB, is ubiquitous on Linux platforms. Its command-line interface requires some work to learn. For a serial executable, GDB runs with the command

> `gdb <my_application>`

GDB does not have built-in parallel MPI support. You may be able to debug parallel jobs by launching multiple GDB sessions with the `mpirun` command. The xterms cannot be launched in all environments, so this is not a fool-proof technique.

> `mpirun -np 4 xterm -e gdb ./<my_application>`

Many higher-level user interfaces are built on top of GDB. The simplest of these is cgdb, which is a curses-based interface that has a strong similarity to the vi editor. The curses interface is a character-based windows system. It has the advantage of better network performance characteristics than a full-fledged, bit-mapped graphical user interface. cgdb is widely available along with its documentation here:

cgdb, the curses debugger, at <https://cgdb.github.io>

A full graphical user interface to GDB is available in the DataDisplayDebugger, known as DDD. The DDD debugger website gives more information on DDD and other similar debuggers:

DDD, the DataDisplayDebugger, at <https://www.gnu.org/software/ddd/>

Neither cgdb nor DDD includes explicit parallel support. Other higher-level user interfaces such as the Eclipse IDE provide a parallel debugger interface on top of the GDB debugger. The Eclipse IDE is available for a wide range of languages and provides the foundation for programming tools for CPUs and GPUs.

Desktop IDEs (Eclipse Foundation) at <https://www.eclipse.org/ide/>

***17.7.4 GPU debuggers can help crush those GPU bugs***

The availability of debuggers for the development of GPU code is a critical game changer. The development of GPU code has been seriously hampered by the difficulty of debugging on GPUs. The GPU debugging tools discussed in this section are still immature, but any capability is sorely needed. These GPU debuggers heavily leverage the open source tools such as GDB and DDD introduced in the previous section.

***CUDA-GDB: A DEBUGGER FOR THE NVIDIA GPUS***

CUDA has a command-line debugger based on GDB called CUDA-GDB. There is also a version of CUDA-GDB with a graphical user interface in NVIDIA’s Nsight™ Eclipse tool as part of their CUDA toolkit. CUDA-GDB has also been integrated into DDD and Emacs. To use CUDA-GDB with DDD, launch DDD using `ddd—debugger cuda-gdb`. You’ll find the CUDA-GDB documentation at <https://docs.nvidia.com/cuda/cuda-gdb/>.

***ROCGDB: A DEBUGGER FOR THE RADEON GPUS***

The AMD ROCm debugger, part of the Radeon Open Compute initiative, is based on the GDB debugger but with initial support for the AMD GPUs. The ROCm website has documentation on ROCgdb, but it is largely the same as the GDB debugger.

- The site for the AMD ROCm debugger is at [https://rocmdocs.amd.com/en/ latest/ROCm_Tools/ROCgdb.html](https://rocmdocs.amd.com/en/latest/ROCm_Tools/ROCgdb.html).

- The ROCm website is <https://rocmdocs.amd.com>.

- Check for updates for the ROCm debugger in the ROCgdb User Guide at [https://github.com/RadeonOpenCompute/ROCm/blob/master/Debugging %20with%20ROCGDB%20User%20Guide%20v4.1.pdf](https://github.com/RadeonOpenCompute/ROCm/blob/master/Debugging%20with%20ROCGDB%20User%20Guide%20v4.1.pdf).

***17.8 Profiling those file operations***

Filesystem performance is often an afterthought with high performance computing application development. In today’s world of big data, and with filesystem performance lagging other parts of the computing system, filesystem performance is a growing issue. The necessary tools for measuring filesystem performance are scarce. The Darshan tool was developed to fill this gap. Darshan, an HPC I/O characterization tool, specializes at profiling an application’s use of the filesystem. Since its release, Darshan has achieved widespread use at high performance computing centers.

> **Example: Installing the Darshan tool**

> In this example, you install the Darshan tool into your home directory. You may want to build the run-time tools on your compute cluster and the analysis tools on another system such as your laptop. The analysis tools require portions of a LaTex distribution and some simple graphics utilities that might not be on the computer cluster. If you run into problems with missing utilities, the DockerFile with accompanying examples at <https://github.com/EssentialsofParallelComputing/Chapter17.git> lists all the packages necessary for running the analysis tools. To begin, download and unpack the Darshan distribution:

> `wget ftp:/ /ftp.mcs.anl.gov/pub/darshan/releases/darshan-3.2.1.tar.gz`  
> `tar -xvf darshan-3.2.1.tar.gz`

> Load or install your MPI package. If it is not installed in the standard location, set the paths with the following `export` commands:

> `export CFLAGS=-I<MPI_INCLUDE_PATH>`  
> `export LDFLAGS=-L<MPI_LIB_PATH>`

> Build the Darshan run-time tools:

> `cd darshan-3.2.1/darshan-runtime`  
> `./configure --prefix=${HOME}/darshan --with-log-path=${HOME}/darshan-logs`  
> `            --with-jobid-env=SLURM_JOB_ID --enable-mpiio-mod`  
> `make`  
> `make install`

> Now build the Darshan analysis tools:

> `cd ../darshan-util`  
> `./configure --prefix=${HOME}/darshan`  
> `make`  
> `make install`

> Then set the path to the Darshan executables:

> `export PATH=${PATH}:${HOME}/darshan/bin`

> Run the Darshan script to set up the date directories in the Darshan log directory:

> `darshan-mk-log-dirs.pl`

> Add the Darshan libraries to your build using your `LINK_FLAGS`. You can get the proper flags by executing the `darshan-config` utility with the `—dyn-ld-flags option`:

> `darshan-config --dyn-ld-flags`

> In the CMake build system, we can capture the output from the command and use it to set our `DARSHAN_LINK_FLAGS` variable:

> `execute_process(COMMAND darshan-config --dyn-ld-flags`  
> `           OUTPUT_STRIP_TRAILING_WHITESPACE`  
> `           OUTPUT_VARIABLE DARSHAN_LINK_FLAGS)`

> Then we add the `DARSHAN_LINK_FLAGS` to the `LINK_FLAGS` variable:

> `set_target_properties(mpi_io_block2d PROPERTIES LINK_FLAGS`  
> `          "${MPI_C_LINK_FLAGS} ${DARSHAN_LINK_FLAGS}")`

We made these changes to the CMakeLists.txt file in the MPI_IO_Examples/mpi_io\_ block2d directory at <https://github.com/EssentialsofParallelComputing/Chapter17.git>. This is the same MPI-IO example we presented in section 16.3 but with a larger 1000x1000 mesh and with the verification code commented out. Now you can build and run the executable as before:

> `mkdir build && cd build`  
> `cmake ..`  
> `make`  
> `mpirun -n 4 mpi_io_block2d`

You should find the Darshan logs organized by date in your ~/darshan-logs subdirectories.

> **Example: Using the Darshan analysis tool**

> You can run the Darshan analysis tool on the generated Darshan log file:

> `darshan-job-summary.pl <darshan log file>`

> You’ll find the output will have the same file name as the log file, but with a .pdf extension added. You can look at the output with your favorite PDF viewer.

The Darshan analysis tool outputs a few pages of text and graphics information on the file operations in your application in portable document format (PDF). We show a part of the output in figure 17.6.

**Figure 17.6 The graphs are part of the output from the Darshan I/O characterization tool. Both the standard IO (POSIX) and MPI-IO are shown. From the graph on the upper right, we can confirm that MPI-IO used collective rather than independent operations.**

We built the run-time tool with support for both POSIX and MPI-IO profiling. POSIX, an acronym for Portable Operating System Interface, is the standard for portability for a wide range of system-level functions such as regular filesystem operations. For our modified test, we turned off all of the verification and other standard IO operations so that we can focus on the MPI-IO parts of the code. We also made the arrays larger. This test was done on the NFS filesystem that is used for our home directory. In the figure, we can see that we did both an MPI-IO write and read and that the write is slightly slower than the read. We can also see that the cost of the MPI metadata operations is much higher. The writing of file metadata records information about where the file is located, its permissions, and its access times. By its nature, writing metadata is a serial operation.

Darshan also has some support for profiling HDF5 file operations. You can get more information on the Darshan HPC I/O characterization tool at the project website:

<https://www.mcs.anl.gov/research/projects/darshan/>

***17.9 Package managers: Your personal system administrator***

Package managers have become critical tools for simplifying software package installation on a variety of systems. These tools first appeared on Linux systems with the Red Hat package manager to manage software installation, but these have since become widespread in many operating systems. Using package managers to install tools and device drivers can greatly simplify the installation process and keep your system more stable and up-to-date.

Linux operating systems heavily rely on the use of package management. You should use your Linux package system to install software whenever possible. Unfortunately, not all software packages, and particularly vendor device drivers, are set up for installing with package managers. Without the use of a package manager, software installation is more difficult and error-prone. Most high performance computing software packages for Linux are distributed as Debian (.deb) or as Red Hat Package Manager (.rpm) package formats. These package formats can be installed on most Linux distributions.

***17.9.1 Package managers for macOS***

For the Mac operating system (macOS), the two major package managers are Homebrew and MacPorts. In general, both are good choices for installing software packages. Because macOS is a derivative of the Berkeley Software Distribution (BSD) Unix, many open source tools are available. But with recent changes to macOS to improve security, some tools have dropped support for the latest releases for the platform. And with recent changes to the Mac hardware, there may be significant changes to package management. More information on Homebrew and MacPorts is available at their respective websites:

- Homebrew at <https://brew.sh>

- MacPorts at <https://www.macports.org>

***17.9.2 Package managers for Windows***

The heavily proprietary Windows operating system has long been a mixed bag for software installation and support. Some software has been well supported and other software not at all. Things are changing at Microsoft as it embraces the open source movement. Windows is just now coming to the party with its new Windows Subsytem Linux (WSL). WSL sets up a Linux environment within a shell and should permit most Linux software to work without changes. A recent announcement that WSL would support transparent access to the GPU has generated excitement in the high performance community. Of course, the main targets are gaming and other mass-market applications, but we’ll be happy to ride the coattails if possible.

***17.9.3 The Spack package manager: A package manager for high performance computing***

So far, we have discussed package managers focused around specific computing platforms. The challenges of a tool for high performance computing are much greater than those for traditional package managers because of the larger number of operating systems, hardware, and compilers that need to be simultaneously supported. It took until 2013, when Todd Gamblin at Lawrence Livermore National Laboratory released the Spack package manager, to address these issues. One of this book’s authors contributed a couple of packages to the Spack list when there were fewer than a dozen packages in the whole system. Now there are over 4,000 supported packages and many of these are unique to the high performance computing community.

> **Example: Quick-start guide to Spack**

> To install Spack, type

> `git clone https:/ /github.com/spack/spack.git`

> Then add to your environment the path and setup script. You can add these to your ./bash_profile or ./bashrc file so that you will have Spack ready to go at anytime.

> `export SPACK_ROOT=/path/to/spack`  
> `source $SPACK_ROOT/share/spack/setup-env.sh`

> To configure Spack, first set up Spack for your compilers:

> `spack compiler find`

> If the compiler is loaded from a module, add the load to the Spack compiler configuration

> `spack config edit compilers `

> or edit

> `~/.spack/linux/compiler.yaml`

> You may want to add some of the system packages that already exist to the default configuration so these don’t get built. To do this, use your favorite editor and edit

> `~/.spack/linux/packages.yaml`

You’ll find many Spack commands. Table 17.3 provides a few to get you started.

**Table 17.3 Using Spack**

**Command**

**Description**

`spack list`

Lists available packages

`spack install <package_name>`

Installs the requested package

`spack find`

Lists the packages that have already been built

`spack load <package_name>`

Loads the package into your environment

Spack has extensive documentation and an active development community. Check their site for up-to-date information: <https://spack.readthedocs.io>.

***17.10 Modules: Loading specialized toolchains***

The realities of software development on large computing sites are that these sites have to simultaneously support multiple environments. Because of this, you can load different versions of the GCC and MPI for testing. You might be able to load these different development toolchains, but the software modules do not come with the extensive testing that is done with most vendor distributions.

> > > **WARNING** Errors with toolchain software installed from the Modules package can occur. The advantages for high performance applications, however, are largely worth the potential difficulties.

Now let’s look at the typical commands you might use with a toolchain system installed with the Modules package as table 17.4 shows.

**Table 17.4 Toolchain module commands: Quick start**

Command

**Description**

`module avail`

Lists modules available on the system

`module list`

Lists modules that are loaded into your current environment

`module purge`

Unloads all modules and restores the environment to before modules loaded

`module show <module_name>`

Shows what changes will be done to your environment

`module unload <module_name>`

Unloads the module and removes changes to the environment

`module swap <module_name> <module_name>`

Replaces one module package with another

Because the `module show` command displays the actions executed by the module, let’s look at a couple of examples for the GCC compiler suite and for CUDA.

> **Example: module show gcc/9.3.0**

> `/opt/modulefiles/centos7/gcc/9.3.0:`  
> `module-whatis      This loads the GCC 9.3.0 environment.`  
> `prepend-path     PATH /projects/opt/x86_64/gcc/9.3.0/bin`  
> `prepend-path     LD_LIBRARY_PATH`  
> `    /opt/x86_64/gcc/9.3.0/lib64:/opt/x86_64/gcc/9.3.0/lib`  
> `prepend-path     MANPATH /opt/x86_64/gcc/9.3.0/share/man`  
> `setenv     CC gcc`  
> `setenv     CXX g++`  
> `setenv     CPP cpp`  
> `setenv     FC gfortran`  
> `setenv     F77 gfortran`  
> `setenv     F90 gfortran`  
> `conflict     gcc`

> In this example, the GCC v9.3.0 module adds the GCC 9.3.0 directory to the path with `prepend-path` and to the environment with the LD_LIBRARY_PATH setting. It also sets some environment variables with `setenv` to direct which compiler to use.

> **Example: module show cuda/10.2**

> `/opt/modulefiles/centos7/cuda/10.2:`  
> `conflict    cuda`  
> `module-whatis     load NVIDIA CUDA 10.2 environment`  
> `module-whatis     Modifies: PATH, LD_LIBRARY_PATH`  
> `module-whatis     IMPORTANT: the OpenCL libraries are`  
> `    installed by the NVIDIA driver, not this module`  
> `setenv     CUDA_PATH /opt/centos7/cuda/10.2`  
> `setenv     CUDADIR /opt/centos7/cuda/10.2`  
> `setenv     CUDA_INSTALL_PATH /opt/centos7/cuda/10.2`  
> `setenv     CUDA_LIB /opt/centos7/cuda/10.2/lib64`  
> `setenv     CUDA_INCLUDE /opt/centos7/cuda/10.2/include`  
> `setenv     CUDA_BIN /opt/centos7/cuda/10.2/bin`  
> `prepend-path     PATH /opt/centos7/cuda/10.2/bin`  
> `prepend-path     LD_LIBRARY_PATH /opt/centos7/cuda/10.2/lib64`  
> `setenv     OPENCL_LIBS /opt/centos7/cuda/10.2/lib64`  
> `setenv     OPENCL_INCLUDE /opt/centos7/cuda/10.2/include`  
> `setenv     CUDA_SDK /opt/centos7/cuda/10.2/samples `

> This CUDA module example sets paths, include directories, and library locations. It also sets the paths for the NVIDIA OpenCL implementation.

As you can see from the examples of these Modules commands, the modules are simply setting some environment variables. This is why Modules is not foolproof. Here are some important hints for using Modules that we learned the hard way. We begin with the following:

- Consistency is important. Set the same modules for compiling and running your code. If the path to the library changes, your code may crash or give you the wrong results.

- Automate as much as possible. If you neglect to do so, your first build (or run) will fail before you realize you forgot to load your modules.

Also, there are different approaches to loading module files. Each is filled with advantages and disadvantages. These approaches are

- Shell startup scripts

- Interactive at command line

- Batch submission scripts

Use interactive shell startup scripts, not batch startup scripts (e.g., load Modules in a .login file instead of a .cshrc). Parallel jobs propagate their environment to remote nodes. If you load Modules in the wrong shell startup script, your remote nodes can have different modules than your head node. This could have unexpected consequences.

Use `module purge` in batch scripts before loading Modules. If you have Modules loaded, the module load can fail because of a conflict, potentially causing your program to fail. (Note that it is unreliable to use `module purge` on Cray systems.)

Set run paths in program builds. Embedding run paths in your executable through the `rpaths` link option or other build mechanisms, helps to make your application less sensitive to changing Modules environments and paths. The disadvantage is that your application may not run on another system if the compilers are not in the same location. Note that this technique does not help with getting the wrong version of a program such as mpirun from your PATH variable.

Load specific versions of compilers (e.g., GCC v9.3.0 rather than just GCC). Often a particular compiler version is set as default, but this will change at some point, breaking your application or build. Also, defaults are not going to be the same on all systems.

There are two major software packages that implement basic Modules commands. The first is called module, often called TCL modules, and the second is Lmod. We discuss these in the following sections.

***17.10.1 TCL modules: The original modules system for loading software toolchains***

Yeah, this is confusing. The Modules package created the category that now more or less uses the same name—module. In 1991, John Furlani at Sun Microsystems created module and then released it as open source software. The module tool is written in the Tool Command Language, better known as TCL. It has proven to be an essential component at major computing centers. The module document is at [https://modules .readthedocs.io/en/stable/module.html](https://modules.readthedocs.io/en/stable/module.html).

***17.10.2 Lmod: A Lua-based alternative Modules implementation***

Lmod is a Lua-based Modules system that dynamically sets up a user’s environment. It is a newer implementation of the environment modules concept. The lmod documentation is at <https://lmod.readthedocs.io/en/latest>.

***17.11 Reflections and exercises***

We wish we had the time and space to go through in better detail how to use each of these tools. Unfortunately, it would take another book (even several books) to explore the world of tools for high performance computing.

We have gone through some of the simpler tools, presenting both their power and usefulness. Just like you shouldn’t judge a book by its cover, don’t judge a tool by the fancy interface. Instead, you should look at what the tool does and how easy it is to use. Our experience has been that fancy user interfaces, instead of functionality, often become the goal. In addition, tools should be simple. We have grown weary of facing another 600-page quick start guide to just learn the next tool. Yes, the tool might be great and do wondrous things, but an application developer has a lot of other things to master as well. The best tools can be picked up and made useful in a couple of hours.

Now we turn some of the effort over to you to try these tools, and hopefully, you will find some that will expand your developer’s toolset. The addition of just a couple of tools makes you a better and more effective programmer. Here are a few exercises to get you started.

1.  Run the Dr. Memory tool on one of your small codes or one of the codes from the exercises in this book.

2.  Compile one of your codes with the dmalloc library. Run your code and view the results.

3.  Try inserting a thread race condition into the example code in section 17.6.2 and see how Archer reports the problem.

4.  Try the profiling exercise in section 17.8 on your filesystem. If you have more than one filesystem, try it on each. Then change the size of the array in the example to 2000x2000. How does it change the filesystem performance results?

5.  Install one of the tools using the Spack package manager.

***Summary***

- Better software development practices start with version control. Creating a solid software development environment results in faster and better code development.

- Use timers and profilers to measure the performance of your applications. Measuring performance is the first step towards improving application performance.

- Explore the various mini-apps to see programming examples relevant to your application area. Learning from these examples will help you avoid reinventing the methods and improve your application.

- Use tools that help with detecting problems in your application. This improves your program quality and robustness.
