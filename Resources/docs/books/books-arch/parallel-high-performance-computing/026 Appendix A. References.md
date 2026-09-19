# Appendix A. References

***Appendix A. References***

We have already provided a list of additional resources at the end of each chapter that we suggest for learning more about topics covered in the chapter. In each chapter, we placed the materials that we think would be most valuable to most readers. The references in this appendix are for those interested in the source materials that were used in developing the book. The citations are partially to give credit to the original authors of research and technical reports. These are also important for those conducting more in-depth research on a particular topic.

***A.1 Chapter 1: Why parallel computing?***

- Amdahl, Gene M. “Validity of the single processor approach to achieving large scale computing capabilities.” Proceedings of the April 18-20, 1967, Spring Joint Computer Conference. (1967):483-48. <https://doi.org/10.1145/1465482.1465560>.

- Flynn, Michael J. “Some Computer Organizations and Their Effectiveness.” In IEEE Transactions on Computers, Vol. C-21, no. 9 (September, 1972): 948-960.

- Gustafson, John L. “Reevaluating Amdahl’s Law.” In Communications of the ACM, Vol. 31, no. 5 (May, 1988):532-533. <http://doi.acm.org/10.1145/42411.42415>.

- Horowitz, M., Labonte, F., and Rupp, K., et al. “Microprocessor Trend Data.” Accessed February 20, 2021. [https://github.com/karlrupp/microprocess or-trend-data](https://github.com/karlrupp/microprocessor-trend-data).

***A.2 Chapter 2: Planning for parallelism***

- CMake. <https://cmake.org/>.

***A.3 Chapter 3: Performance limits and profiling***

Tools

- Empirical Roofline Toolkit (ERT). [https://bitbucket.org/berkeleylab/cs-roof line-toolkit](https://bitbucket.org/berkeleylab/cs-roofline-toolkit).

- 4Intel® Advisor. <https://software.intel.com/en-us/advisor>.

- likwid. <https://github.com/RRZE-HPC/likwid>.

- STREAM download. <https://github.com/jeffhammond/Stream.git>.

- Valgrind. <http://valgrind.org/>.

Articles

- McCalpin, J. D. “STREAM: Sustainable Memory Bandwidth in High Performance Computers.” Accessed February 20, 2021. <https://www.cs.virginia.edu/stream/>.

- Peise, Elmar. “Performance Modeling and Prediction for Dense Linear Algebra.” arXiv:1706.01341 (June, 2017). Preprint: <https://arxiv.org/abs/1706.01341>.

- Williams, S. W., D. Patterson, et. al. “The Roofline Model: A pedagogical tool for auto-tuning kernels on multicore architectures.” In Hot Chips, A Symposium on High Performance Chips, Vol. HC20 (August 10, 2008).

***A.4 Chapter 4: Data design and performance models***

Resources

- Data-oriented design. <https://github.com/dbartolini/data-oriented-design>.

Articles and books

- Bird, R. “Performance Study of Array of Structs of Arrays.” Los Alamos National Lab (LANL). Paper in preparation.

- Garimella, Rao, and Robert W. Robey. “A Comparative Study of Multi-material Data Structures for Computational Physics Applications,” no. LA-UR-16-23889. Los Alamos National Lab (LANL) (January, 2017).

- Hennessy, John L., and David A. Patterson. Computer architecture: A Quantitative Approach. 5th ed. San Francisco, CA, USA: Morgan Kaufmann, 2011.

- Hofmann, Johannes, Jan Eitzinger, and Dietmar Fey. “Execution-Cache-Memory Performance Model: Introduction and Validation.” arXiv:1509.03118 (March, 2017). Preprint: <https://arxiv.org/abs/1509.03118>.

- Hollman, David, Bryce Lelbach, H. Carter Edwards, et al. “mdspan in C++: A Case Study in the Integration of Performance Portable Features into International Language Standards.” IEEE/ACM International Workshop on Performance, Portability and Productivity in HPC (P3HPC) (November, 2019):60-70.

- Treibig, Jan, and Georg Hager. “Introducing a performance model for bandwidth-limited loop kernels.” International Conference on Parallel Processing and Applied Mathematics (May, 2009):615-624.

***A.5 Chapter 5: Parallel algorithms and patterns***

- Ahrens, Peter, Hong Diep Nguyen, and James Demmel. “Efficient Reproducible Floating Point Summation and BLAS.” In EECS Department, University of California, Berkeley, Techical Report, No. UCB/EECS-2015-229 (December, 2015).

- Alcantara, Dan A., Andrei Sharf, Fatemeh Abbasinejad, et al. “Real-time parallel hashing on the GPU.” In ACM Transactions on Graphics (TOG), Vol. 28, no. 5 (December, 2009):154.

- Anderson, Alyssa. “Achieving Numerical Reproducibility in the Parallelized Floating Point Dot Product.” (April, 2014). [https://digitalcommons.csbsju.edu/hon ors_theses/30/](https://digitalcommons.csbsju.edu/honors_theses/30/).

- Blelloch, Guy E. “Scans as primitive parallel operations.” In IEEE Transactions on computers, Vol. 38, no. 11 (November, 1989):1526-1538.

- Blelloch, Guy E. Vector models for data-parallel computing. Cambridge, MA, USA: The MIT Press, 1990.

- Chapp, Dylan, Travis Johnston, and Michela Taufer. “On the Need for Reproducible Numerical Accuracy through Intelligent Runtime Selection of Reduction Algorithms at the Extreme Scale.” 2015 IEEE International Conference on Cluster Computing (October, 2015):166-175.

- Cleveland, Mathew A., Thomas A. Brunner, et al. “Obtaining identical results with double precision global accuracy on different numbers of processors in parallel particle Monte Carlo simulations.” In Journal of Computational Physics, Vol. 251 (October, 2013):223-236.

- Harris, Mark, Shubhabrata Sengupta, and John D. Owens. “Parallel Prefix Sum (Scan) with CUDA.” In GPU Gems 3, no. 39 (April, 2007):851-876.

- Lessley, Brenton. “Data-Parallel Hashing Techniques for GPU Architectures.” In Eurographics Conference on Visualization (EuroVis), Vol. 37, no. 3 (July, 2018).

***A.6 Chapter 8: MPI: The parallel backbone***

- Hoefler, Torsten, and Jesper Larsson Traff. “Sparse collective operations for MPI.” 2009 IEEE International Symposium on Parallel & Distributed Processing (July, 2009):18.

- Thakur, Rajeev, and William Gropp. “Test suite for evaluating performance of multithreaded MPI communication.” In Parallel Computing, Vol. 35, no. 12 (December, 2009):608-617.

***A.7 Chapter 9: GPU architectures and concepts***

- Yang, Charlene, Thorsten Kurth, and Samuel Williams. “Hierarchical Roofline analysis for GPUs: Accelerating performance optimization for the NERSC-9 Perlmutter system.” In Concurrency and Computation: Practice and Experience (November, 2019). <https://doi.org/10.1002/cpe.5547>.

***A.8 Chapter 10: GPU programming model***

- CUDA Toolkit Documentation. “Compute Capabilities.” CUDA C++ Programming Guide, v11.2.1 (NVIDIA Corporation, 2021). <https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#compute-capabilities>.

***A.9 Chapter 12: GPU languages: Getting down to basics***

- Harris, Mark. “Optimizing Parallel Reduction in CUDA.” (NVIDIA Corporation). <https://developer.download.nvidia.com/assets/cuda/files/reduction.pdf>.

***A.10 Chapter 13: GPU profiling and tools***

- BBC News. “Indonesia tsunami: How a volcano can be the trigger.” BBC Global News Ltd (December, 2018). [http://mng.bz/y92d.](http://mng.bz/y92d)

***A.11 Chapter 14: Affinity: Truce with the kernel***

- Broquedis, François, Jérôme Clet-Ortega, et al. “hwloc: A Generic Framework for Managing Hardware Affinities in HPC Applications.” Proceedings of the 18th Euromicro International Conference on Parallel, Distributed and Network-based Processing (PDP2010). IEEE Computer Society Press (February, 2010):180-186. <https://ieeexplore.ieee.org/document/5452445>.

- Hewlett Packard Enterprise, Original process placement program, xthi.c. CLE User Application Placement Guide (CLE 5.2.UP04) S-2496, pg 87. [http://mng.bz/MgWB.](http://mng.bz/MgWB)

- “OpenMP Application Programming Interface,” v5.0. OpenMP Architecture Review Board (November, 2018). <https://www.openmp.org/wp-content/uploads/OpenMP-API-Specification-5.0.pdf>.

- Samuel K. Gutiérrez, “Adaptive Parallelism for Coupled, Multithreaded Message-Passing Programs.” (December, 2018). <https://www.cs.unm.edu/~samuel/publications/2018/skgutierrez-dissertation.pdf>.

- Samuel K. Gutiérrez, Davis, Kei, et al. “Accommodating Thread-Level Heterogeneity in Coupled Parallel Applications.” Proceedings of the IEEE International Parallel and Distributed Processing Symposium (May, 2017). <https://github.com/lanl/libquo/blob/master/docs/publications/quo-ipdps17.pdf>.

- Squyres, Jeff. “Process Placement.” (September, 2014). Accessed February 20, 2021. <https://github.com/open-mpi/ompi/wiki/ProcessPlacement>.

- Treibig, J., G. Hager and G. Wellein. “LIKWID: A lightweight performance-oriented tool suite for x86 multicore environments.” arXiv:1004.4431 (June, 2010). Preprint: <http://arxiv.org/abs/1004.4431>.

***A.12 Chapter 16: File operations for a parallel world***

Tools

- BeeGFS (The leading parallel file system).<https://www.beegfs.io/c/>.

- Lustre®. OpenSFS and EOFS. <http://lustre.org>.

- The OrangeFS Project. <http://www.orangefs.org>.

- Panasas PanFS Parallel File System. [https://www.panasas.com/panfs-architec ture/panfs/](https://www.panasas.com/panfs-architecture/panfs/).

Articles and books

- Gropp, William. “Lecture 33: More on MPI I/O Best practices for parallel IO and MPI-IO hints.” Accessed February 20, 2021. <http://wgropp.cs.illinois.edu/courses/cs598-s15/lectures/lecture33.pdf>.

- Mendez, Sandra, Sebastian Lührs, et al. “Best Practice Guide—Parallel I/O.” Accessed February 20, 2021. <https://prace-ri.eu/wp-content/uploads/Best-Practice-Guide_Parallel-IO.pdf>.

- Thakur, Rajeev, Ewing Lusk, and William Gropp. Users guide for ROMIO: A high-performance, portable MPI-IO implementation. ANL/MCS-TM-234. Artonne, IL, USA: Argonne National Laboratory (October, 1997).

- Thakur, Rajeev, William Gropp, and Ewing Lusk. “Data sieving and collective I/O in ROMIO.” Proceedings. Frontiers’ 99. Seventh Symposium on the Frontiers of Massively Parallel Computation (February, 1999):182-189.

***A.13 Chapter 17: Tools and resources for better code***

- Stepanov, Evgeniy, and Konstantin Serebryany. “MemorySanitizer: fast detector of uninitialized memory use in C++.” 2015 IEEE/ACM International Symposium on Code Generation and Optimization (CGO) (February, 2015):46-55.
