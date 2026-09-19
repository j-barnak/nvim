# 14 Affinity: Truce with the kernel

***14 Affinity: Truce with the kernel***

This chapter covers

- Why affinity is an important concern for modern CPUs
- Controlling affinity for your parallel applications
- Fine-tuning performance with process placement

We first encountered affinity in section 8.6.2 on the MPI (Message Passing Interface), where we defined it and briefly showed how to handle it. We repeat the definition here and also define process placement.

- Affinity—Assigns a preference for the scheduling of a process, rank or thread to a particular hardware component. This is also called pinning or binding.

- Placement—Assigns a process or thread to a hardware location.

We’ll go into more depth about affinity, placement, and the order of threads or ranks in this chapter. Concerns about affinity are recent phenomena. In the past, with just a few processor cores per CPU, there wasn’t that much to gain. As the number of processors grows and the architecture of a compute node gets more complicated, affinity has become more and more important. Still, the gains are relatively modest; perhaps the biggest benefit is in reducing the variation in performance from run to run and getting better on-node scaling. Occasionally, controlling affinity can avoid truly disastrous scheduling decisions by the kernel with respect to the characteristics of your application.

The decision of where to place a process or a thread is handled by the operating system kernel. Kernel scheduling has a rich history and is key to the development of multitasking, multi-user operating systems. It is due to these capabilities that you can fire up a spreadsheet, temporarily switch to a word processor, and then handle an important email. However, the scheduling algorithms developed for the general user are not always suitable for parallel computing. We can launch four processes for a four processor core system, but the operating system schedules those four processes any way it wants. It could place all four processes on the same processor, or it could spread them out across the four processors. Generally the kernel does something reasonable, but it can interrupt one of the parallel processes to perform a system function, causing all the other processes to idle and wait.

In chapter 1, figures 1.20 and 1.21, we showed question marks about where the processes get placed because we have no control over the placement of processors or threads on processors. At least until now. Recent releases of MPI, OpenMP, and batch schedulers have started to offer features to control placement and affinity. Although there is a lot of change in the options in some of the interfaces, things seem to be settling down with recent releases. However, you are advised to check the documentation for the releases that you use for any differences.

***14.1 Why is affinity important?***

Unlike most common desktop applications, parallel processes need to be scheduled together. This is referred to as gang scheduling.

> > > **DEFINITION** Gang scheduling is a kernel scheduling algorithm that activates a group of processes at the same time.

Because parallel processes generally synchronize periodically during a run, scheduling a single thread that ends up waiting on another process that is not active has no benefit. The kernel scheduling algorithm has no information that a process is dependent on another’s operation. This is true for MPI, OpenMP threads, and GPU kernels as well. The best approach for getting gang scheduling is to only allocate as many processes as there are processors and bind those processes to the processors. We cannot forget that the kernel and system processes need somewhere to run. Some advanced techniques reserve a processor just for system processes.

It is not enough to keep every parallel process active and scheduled. We also need to keep processes scheduled on the same Non-Uniform Memory Access (NUMA) domain to minimize memory access costs. With OpenMP, we typically go to a lot of trouble to “first touch” data arrays on the processor where the data is used (see section 7.1.1). If the kernel then moves your process to another NUMA domain, your efforts are all for naught. We saw in section 7.3.1 that the penalty for memory access in the wrong NUMA domain can typically be a factor of two or more. It is a top priority for our processes to stay on the same memory domain.

Typically, a NUMA domain is aligned with the sockets on a node. If we can tell a process to schedule an affinity on the same socket, we’ll always get the same, optimal memory access time for main memory. The need for NUMA region affinity, however, is dependent on your CPU architecture. Personal computing systems often have only one NUMA region, while large HPC systems often have far more processing cores per node with two CPU sockets and two or more NUMA regions.

While tying affinity to a NUMA domain optimizes our access time to main memory, we still can have less than optimal performance due to poor cache usage. A process fills the L1 and L2 cache with the memory that it needs. But then, if it gets swapped out to another processor on the same NUMA domain with a different L1 and L2 cache, cache performance suffers. The caches then need to be filled again. If you reuse data a lot, this causes a performance loss. For MPI, we want to lock processes or ranks to a processor. But with OpenMP, this causes all the threads to be launched on the same processor because the affinity is inherited by the spawned threads. With OpenMP, we want to have affinity for each thread to its processor.

Some processors also have a new feature called hyperthreads. Hyperthreads add another layer of complexity to the process placement considerations. First we need to define hyperthreading and what it is.

> > > **DEFINITION** Hyperthreading, an Intel technology, makes a single processor appear to be two virtual processors to the operating system through sharing of hardware resources between two threads.

Hyperthreads share a single physical core and its cache system. Because the cache is shared, there isn’t as much penalty for movement between hyperthreads. But it also means that each virtual core has half the cache as a real physical core if the processes do not have any data in common. For our memory-bound applications, halving the cache can be a serious blow. Thus, the effectiveness of these virtual cores is mixed. Many HPC systems turn them off because some programs slow down with hyperthreads. Not all hyperthreads are equal either on the hardware or operating system level, so don’t assume that if you didn’t see a benefit on a previous implementation, you won’t on your current system. If we use hyperthreads, we’ll want the process placement to be close by so that the shared cache benefits both virtual processors.

***14.2 Discovering your architecture***

In order to leverage affinity for better performance, we need to know the details of our hardware architecture. The variety of hardware architectures makes this difficult; Intel alone has over a thousand CPU models. In this section, we introduce how to understand your architecture. This is a requirement before you can use affinity to exploit it.

You can get the best view of your architecture with the lstopo utility. We first saw lstopo in section 3.2.1 with the output for a Mac laptop in figure 3.2. The laptop is a simple architecture with four physical processing cores which, with hyperthreading enabled, appears as eight virtual cores to the operating systems. We can also see in figure 3.2 that the L1 and L2 caches are private to the physical core, and the L3 cache is shared across all of the processors. We also note that there is just one NUMA domain. Now let’s take a look at a more complicated CPU. Figure 14.1 shows the architecture for an Intel Skylake Gold CPU.

**Figure 14.1 The Intel Skylake Gold architecture with two NUMA domains and 88 processing cores reveals the complexity of higher-end compute nodes.**

The gray boxes in figure 14.1, each labeled core and containing two light rectangles labled PU for processing unit, are physical cores. Each of these gray boxes has two boxes inside that are the virtual processors created by hyperthreads. The L1 and L2 caches are private to each physical processor, while the L3 cache is shared across the NUMA domain. We also can see that the network and other peripherals at the right of the figure are closer to the first NUMA domain. We can get some information on most Linux or Unix systems with the `lscpu` command (figure 14.2).

**Figure 14.2 Output from** **`lscpu`** **command for the Intel Skylake Gold processor.**

The output from `lscpu` confirms that there are two threads per core and two NUMA domains. The processor numbering seems a little odd, but by having the first 22 processors on the first NUMA node and then skipping to include the next 22 processors on the second node, we leave the hyperthreads to be numbered last. Remember that the NUMA utilities definition of a node is different than our definition, where it is a separate, distributed memory system.

So what is the strategy for affinity and process placement for this architecture? Well, it depends on the application. Each application has different scaling and threading performance needs that must be considered. We will want to watch that we keep processes in their NUMA domains to get the optimal bandwidth to main memory.

***14.3 Thread affinity with OpenMP***

Thread affinity is vital when optimizing applications with OpenMP. Tying a thread to the location of the memory it uses is important to achieve good memory latency and bandwidth. We go to great effort to do first touch to get memory placed close to the thread as we discussed in section 7.1.1. If the threads are moving around to different processors, we lose all the benefits we should get from our extra effort.

With OpenMP v4.0, the affinity controls for OpenMP were expanded to include the `close`, `spread`, and `primary` keywords, in addition to the existing `true` or `false` options. Also added were three options for the OMP_PLACES environment variable, `sockets`, `cores`, and `threads`. In summary, we now have these affinity and placement controls:

- OMP_PLACES = `[sockets|cores|threads]` or an explicit list of places

- OMP_PROC_BIND = `[close|spread|primary]` or `[true|false]`

OMP_PLACES puts limits on where the threads can be scheduled. There is actually one option that is not listed: the `node`. It is the default and allows each thread to be scheduled anywhere in the “place.” With more than one thread on the default place of the node, the possibility exists that the scheduler will move the threads or have collisions with two or more threads scheduled for one virtual processor. One sensible approach is not to have more threads than the quantity of the specified place. Perhaps the better rule is to specify a place that has a quantity greater than the desired number of threads. We’ll show how that works in an example later in this section.

The OMP_PROC_BIND environment variable has five possible settings, but these have some overlap in meaning. The `close`, `spread`, and `primary` settings are specialized versions of `true`.

> > > **NOTE** We also note that `primary` replaces the deprecated `master` keyword as of the OpenMP v5.1 standard. You may continue to encounter the old usage as compilers implement the new standard.

With the `false` setting, the kernel scheduler is free to move threads around. The `true` setting tells the kernel not to move the thread once it gets scheduled. But it can be scheduled anywhere within the place constraint and can vary from run to run. The `primary` setting is a special case that schedules threads on the main processor. The `close` setting schedules the threads close together and `spread` distributes the threads. The choice of which of these two settings to use has some subtle implications that you will see in the example for this section.

> > > **NOTE** You can also set the placement with a detailed list. This is a more advanced use case that we won’t go over here. The detailed list can give more fine-tuned control, but it is less portable to a different CPU type.

The OpenMP environment variables set the affinity and placement for the whole program. You can also set the affinity for individual loops through the addition of a clause on the `parallel` directive. The clause has this syntax:

> `proc_bind([primary|close|spread])`

The following example shows these affinity controls in operation on our simple vector addition program from section 7.3.1. The affinity-reporting routines can also be added to your code to see the impact there.

> **Example: Vector addition with all possible settings of** **`OMP_PLACES`** **and** **`OMP_PROC_BIND`**

> For this example, we set every combination of OpenMP affinity and placement environment variables. We first modify the vector add from section 7.3.1 to call a routine that reports placement of threads shown in the following listing.

> **Modified vecadd_opt3.c for affinity study**

> `OpenMP/vecadd_opt3.c`  
> `1 #include <stdio.h>`  
> `2 #include <time.h>`  
> `3 #include "timer.h"`  
> `4 #include "omp.h"`  
> `5 #include "place_report_omp.h"`  
> `6`  
> `7 // large enough to force into main memory`  
> `8 #define ARRAY_SIZE 80000000`  
> `9 static double a[ARRAY_SIZE], b[ARRAY_SIZE], c[ARRAY_SIZE];`  
> `10`  
> `11 void vector_add(double *c, double *a, double *b, int n);`  
> `12`  
> `13 int main(int argc, char *argv[]){`  
> `14 #ifdef VERBOSE                     `❶  
> `15    place_report_omp();             `❷  
> `16 #endif`  
> `17    struct timespec tstart;`  
> `18    double time_sum = 0.0;`  
> `19 #pragma omp parallel`  
> `20    {`  
> `21 #pragma omp for`  
> `22       for (int i=0; i<ARRAY_SIZE; i++) {`  
> `23          a[i] = 1.0;`  
> `24          b[i] = 2.0;`  
> `25       }`  
> `26`  
> `27 #pragma omp masked`  
> `28       cpu_timer_start(&tstart);`  
> `29       vector_add(c, a, b, ARRAY_SIZE);`  
> `30 #pragma omp masked`  
> `31       time_sum += cpu_timer_stop(tstart);`  
> `32    } // end of omp parallel`  
> `33`  
> `34    printf("Runtime is %lf msecs\n", time_sum);`  
> `35 }`  
> `36`  
> `37 void vector_add(double *c, double *a, double *b, int n)`  
> `38 {`  
> `39 #pragma omp for`  
> `40    for (int i=0; i < n; i++){`  
> `41       c[i] = a[i] + b[i];`  
> `42    }`  
> `43 }`

> ❶ Define to enable reporting

> ❷ Call to placement report

> The main work is done in the `place_report_omp` subroutine. We use an `ifdef` around the call to easily turn the reporting on and off. So now let’s take a look at the reporting routine in the next listing.

> **Reporting place settings in OpenMP**

> `OpenMP/place_report_omp.c`  
> `41 void place_report_omp(void)`  
> `42 {`  
> `43    #pragma omp parallel`  
> `44    {`  
> `45       if (omp_get_thread_num() == 0){`  
> `46          printf("Running with %d thread(s)\n",      `❶  
> `                   omp_get_num_threads());             `❶  
> `47          int bind_policy = omp_get_proc_bind();     `❷  
> `48          switch (bind_policy)`  
> `49          {`  
> `50             case omp_proc_bind_false:`  
> `51                printf("  proc_bind is false\n");`  
> `52                break;`  
> `53             case omp_proc_bind_true:`  
> `54                printf("  proc_bind is true\n");`  
> `55                break;`  
> `56             case omp_proc_bind_master:`  
> `57                printf("  proc_bind is master\n");`  
> `58                break;`  
> `59             case omp_proc_bind_close:`  
> `60                printf("  proc_bind is close\n");`  
> `61                break;`  
> `62             case omp_proc_bind_spread:`  
> `63                printf("  proc_bind is spread\n");`  
> `64          }`  
> `65          printf("  proc_num_places is %d\n",        `❸  
> `                   omp_get_num_places());              `❸  
> `66       }`  
> `67    }`  
> `68`  
> `69    int socket_global[144];`  
> `70    char clbuf_global[144][7 * CPU_SETSIZE];`  
> `71`  
> `72    #pragma omp parallel`  
> `73    {`  
> `74       int thread = omp_get_thread_num();`  
> `75       cpu_set_t coremask;`  
> `76       char clbuf[7 * CPU_SETSIZE];`  
> `77       memset(clbuf, 0, sizeof(clbuf));`  
> `78       sched_getaffinity(0, sizeof(coremask),        `❹  
> `                           &coremask);                 `❹  
> `79       cpuset_to_cstr(&coremask, clbuf);             `❺  
> `80       strcpy(clbuf_global[thread],clbuf);`  
> `81       socket_global[omp_get_thread_num()] =         `❻  
> `            omp_get_place_num();                       `❻  
> `82       #pragma omp barrier`  
> `83       #pragma omp master`  
> `84       for (int i=0; i<omp_get_num_threads(); i++){`  
> `85          printf("Hello from thread %d: (core affinity = %s)"`  
> `               " OpenMP socket is %d\n",`  
> `86             i, clbuf_global[i], socket_global[i]);`  
> `87       }`  
> `88    }`  
> `89 }`

> ❶ Reports number of threads

> ❷ Queries and reports OMP_PROC_BIND setting

> ❸ Queries and reports overall thread placement restrictions

> ❹ Gets the affinity bit mask

> ❺ Converts the bit mask to something we can print

> ❻ Gets the actual place number to print

> The CPU affinity bit mask needs to be converted to a more understandable format for printing out. The next listing shows that routine.

> **Routine to convert CPU bit mask to a C string**

> `OpenMP/place_report_omp.c`  
> `12 static char *cpuset_to_cstr(cpu_set_t *mask, char *str)`  
> `13 {`  
> `14   char *ptr = str;`  
> `15   int i, j, entry_made = 0;`  
> `16   for (i = 0; i < CPU_SETSIZE; i++) {`  
> `17     if (CPU_ISSET(i, mask)) {`  
> `18       int run = 0;`  
> `19       entry_made = 1;`  
> `20       for (j = i + 1; j < CPU_SETSIZE; j++) {`  
> `21         if (CPU_ISSET(j, mask)) run++;`  
> `22         else break;`  
> `23       }`  
> `24       if (!run)`  
> `25         sprintf(ptr, "%d,", i);`  
> `26       else if (run == 1) {`  
> `27         sprintf(ptr, "%d,%d,", i, i + 1);`  
> `28         i++;`  
> `29       } else {`  
> `30         sprintf(ptr, "%d-%d,", i, i + run);`  
> `31         i += run;`  
> `32       }`  
> `33       while (*ptr != 0) ptr++;`  
> `34     }`  
> `35   }`  
> `36   ptr -= entry_made;`  
> `37   *ptr = 0;`  
> `38   return(str);`  
> `39 }`

In the placement reporting routine, we query the OpenMP settings, report those, then show the placement and affinity for each thread. To try it out, compile the code with the verbose setting and run it with 44 threads or whatever number of threads makes sense on your system, and no special environment variable settings. The example code is at <https://github.com/EssentialsofParallelComputing/Chapter14.git> in the OpenMP subdirectory.

> **Example: Querying the OpenMP settings for the placement reporting routine**

> To query the OpenMP settings, report them, then show the placement and affinity for each thread, the steps are

> `mkdir build && cd build`  
> `cmake -DCMAKE_VERBOSE=on ..`  
> `make`  
> `export OMP_NUM_THREADS=44`  
> `./vecadd_opt3`

> Running this on the Intel Skylake-Gold with GCC 9.3 gives the following output.

>   

> **The output shows the affinity and placement report with no environment variables set. The threads are allowed to run on any processor from 0 to 87.**

> The core affinity allows the thread to run on any of the 88 virtual cores.

Let’s see what happens when we place the threads on hardware cores and set the affinity binding to `close`.

> `export OMP_PLACES=cores`  
> `export OMP_PROC_BIND=close`  
> `./vecadd_opt3`

The output with this affinity and placement settings is shown in Figure 14.3.

**Figure 14.3 Affinity and placement report for** **`OMP_PLACES=cores`** **and** **`OMP_PROC_BIND=close`. Each thread can run on two possible virtual cores. These two processors belong to a single hardware core due to hyperthreading.**

Wow! We can actually control the kernel! The threads are now pinned to the two virtual cores belonging to a single hardware core. The run time of 0.0166 ms is the last number in the output. This run time is a substantial improvement over the 0.0221 ms in the previous run for a 25% reduction in the computation time. You can experiment with various environment variable settings and see how the threads are placed on the node.

We are going to automate the exploration of all the settings and how they scale with different numbers of threads. We’ll turn off the verbose option to reduce the output that we have to deal with. Only the run time will print. Remove the previous build and rebuild the code as follows:

> `mkdir build && cd build`  
> `cmake ..`  
> `make`

We then run the script in the following listing to get the performance for all cases.

**Listing 14.1 Script to automate exploring all settings**

> `OpenMP/run.sh`  
> `1 #!/bin/sh`  
> `2`  
> `3 calc_avg_stddev()                           `❶  
> `4 {`  
> `5    #echo "Runtime is $1"`  
> `6    awk '{`  
> `7      sum = 0.0; sum2 = 0.0       # Initialize to zero`  
> `8      for (n=1; n <= NF; n++) {   # Process each value on the line`  
> `9        sum += $n;                # Running sum of values`  
> `10        sum2 += $n * $n           # Running sum of squares`  
> `11      }`  
> `12      print " Number of trials=" NF ",    avg=" sum/NF ", \`  
> `              std dev=" sqrt((sum2 - (sum*sum)/NF)/NF);`  
> `13        }' <<< $1`  
> `14 }`  
> `15`  
> `16 conduct_tests()                             `❷  
> `17 {`  
> `18    echo ""`  
> `` 19    echo -n `printenv |grep OMP_` ${exec_string} ``  
> `20    foo=""`  
> `21    for index in {1..10}                     `❸  
> `22    do`  
> `` 23       time_result=`${exec_string}` ``  
> `24       time_val[$index]=${time_result}`  
> `25       foo="$foo ${time_result}"`  
> `26    done`  
> `27    calc_avg_stddev "${foo}"`  
> `28 }`  
> `29`  
> `30 exec_string="./vecadd_opt3 "`  
> `31`  
> `32 conduct_tests`  
> `33`  
> `34 THREAD_COUNT="88 44 22 16 8 4 2 1"`  
> `35`  
> `36 for my_thread_count in ${THREAD_COUNT}    `❹  
> `37 do`  
> `38    unset OMP_PLACES`  
> `39    unset OMP_PROC_BIND`  
> `40    export OMP_NUM_THREADS=${my_thread_count}`  
> `41`  
> `42    conduct_tests`  
> `43`  
> `44    PLACES_LIST="threads cores sockets"`  
> `45    BIND_LIST="true false close spread primary"`  
> `46`  
> `47    for my_place in ${PLACES_LIST}         `❺  
> `48    do`  
> `49       for my_bind in ${BIND_LIST}         `❻  
> `50       do`  
> `51          export OMP_NUM_THREADS=${my_thread_count}`  
> `52          export OMP_PLACES=${my_place}`  
> `53          export OMP_PROC_BIND=${my_bind}`  
> `54`  
> `55          conduct_tests`  
> `56       done`  
> `57    done`  
> `58 done`

❶ Calculates average and standard deviation

❷ Does the test

❸ Repeats ten times to get statistics

❹ Loops over number of threads

❺ Loops over place settings

❻ Loops over affinity settings

Due to space, we show only a few of the results in figure 14.4. All of the values are the speedup from a single thread with no affinity or placement settings.

**Figure 14.4 OpenMP affinity and placement settings of** **`OMP_PROC_BIND=spread`** **boosts the parallel scaling by 50%. The lines are for various numbers of threads for a particular setting and are ordered roughly from high to low in the legend.**

The first thing to note from figure 14.4 in our analysis is that the program is generally the fastest for all settings with only 44 threads. Overall, hyperthreading does not help. The exception is the `close` setting for threads because until we have more than 44 threads with this setting, there are no processes on the second socket. With threads only on the first socket, it limits the total memory bandwidth that can be obtained. At the full 88 threads, the `close` setting for threads gives the best performance, although by only a little bit. The `close` setting, in general, shows the same limited memory bandwidth effect due to only having threads on the first socket. You can also see that at larger process counts with process binding, the performance is higher than without process binding.

Some key points to take away from this analysis

- Hyperthreading does not help with simple memory-bound kernels, but it also doesn’t hurt.

- For memory-bandwidth-limited kernels on multiple sockets (NUMA domains), get both sockets busy.

We don’t show the results for setting OMP_PROC_BIND to `primary` because it forces all the threads to be on the same processor and slows the program by as much as a factor of two. We also don’t show setting OMP_PLACES to `sockets` because it has lower performance than those shown.

***14.4 Process affinity with MPI***

There are also benefits to applying affinity with MPI applications as discussed in section 14.2. It helps to get full memory bandwidth and cache performance by keeping the processes from being migrated to different processor cores by the operating system kernel. We will discuss affinity with OpenMPI because it has the most publicly available tools for affinity and process placement. Other MPI implementations like MPICH must be compiled with SLURM support enabled, which isn’t as applicable to personal machines. We will discuss the command-line tools that can be used in more general situations in section 14.6. For now, let’s move onward with our exploration of affinity in OpenMPI!

***14.4.1 Default process placement with OpenMPI***

Rather than leaving process placement to the kernel scheduler, OpenMPI specifies a default placement and affinity. The default settings for OpenMPI vary depending on the number of processes. These are

- Processes \<= 2 (bind to core)

- Processes \> 2 (bind to socket)

- Processes \> processors (bind to none)

Some HPC centers might set other defaults such as always binding to cores. This binding policy may make sense for most MPI jobs but can cause problems with applications using both OpenMP threading and MPI. The threads will all be bound to a single processor, serializing the threads.

Recent versions of OpenMPI have extensive support for process placement and affinity. Using these tools, you usually get a performance gain. The gain depends upon how the process scheduler in the operating system is optimizing placement. Most schedulers are tuned for general computing, such as word processing and spreadsheets, but not parallel applications. Coaxing the scheduler to “do the right thing” potentially yields a benefit of 5-10%, but it can be a lot more.

***14.4.2 Taking control: Basic techniques for specifying process placement in OpenMPI***

For most use cases, it is sufficient to use simple controls to place processes and to bind these to hardware components. These controls are supplied to the `mpirun` command as options. Let’s start with looking at distributing processes equally across a multi-node job. It is easiest to demonstrate this with an example.

> **Example: Distributing processes equally across multi-node jobs**

> We have an application that we want to run on 32 MPI ranks, but it is a memory-hungry application that needs half a terabyte of memory. A single node doesn’t have enough memory, so how do we manage this?

> If we look at the system details, each node has two sockets filled with Intel Broadwell (E52695) CPUs. Each CPU has 18 hardware cores that, with hyperthreading, gives us 36 virtual processors per socket. Each node has 128 GiB of memory.

- From the `lscpu` command

> `NUMA node0 CPU(s):     0-17,36-53`  
> `NUMA node1 CPU(s):     18-35,54-71`

- From the /proc/meminfo file

> `MemTotal:       131728700 kB`

> For this example, we use our placement reporting tool for MPI applications. The two parts of the code are shown in the following listings.

> **Main MPI affinity code**

> `MPI/MPIAffinity.c`  
> `1 #include <mpi.h>`  
> `2 #include <stdio.h>`  
> `3 #include "place_report_mpi.h"`  
> `4 int main(int argc, char **argv)`  
> `5 {`  
> `6    MPI_Init(&argc, &argv);`  
> `7`  
> `8    place_report_mpi();      `❶  
> `9`  
> `10    MPI_Finalize();`  
> `11    return 0;`  
> `12 }`

> ❶ Inserts placement reporting call after MPI_Init

> We need to insert the call to our placement reporting subroutine after MPI is initialized. You can easily add this to your MPI application as well. Now let’s look at the reporting subroutine in the next listing.

> **MPI placement reporting tool**

> `MPI/place_report_mpi.c`  
> `40 void place_report_mpi(void)`  
> `41 {`  
> `42   int rank;`  
> `43   cpu_set_t coremask;`  
> `44   char clbuf[7 * CPU_SETSIZE], hnbuf[64];`  
> `45`  
> `46   memset(clbuf, 0, sizeof(clbuf));`  
> `47   memset(hnbuf, 0, sizeof(hnbuf));`  
> `48`  
> `49   MPI_Comm_rank(MPI_COMM_WORLD, &rank);`  
> `50`  
> `51   gethostname(hnbuf, sizeof(hnbuf));          `❶  
> `52   sched_getaffinity(0, sizeof(coremask),      `❷  
> `                       &coremask);               `❷  
> `53   cpuset_to_cstr(&coremask, clbuf);           `❸  
> `54   printf("Hello from rank %d, on %s. (core affinity = %s)\n",`  
> `55           rank, hnbuf, clbuf);`  
> `56 }`

> ❶ Gets our node name

> ❷ Gets the affinity setting of our process

> ❸ Same cpuset_to_cstr routine from the vector addition listing in section 14.3

For our first run of our application, we simply ask mpirun to launch 32 processes:

> `mpirun -n 32 ./MPIAffinity | sort -n -k 4`

We then have to sort the output by the data in the fourth column because the order of output by processes is random (done by the command `sort -n -k 4`). The output for this command with our placement report routine is shown in figure 14.5.

**Figure 14.5 For** **`mpirun -n 32`, all of our processes are on the cn328 node. The affinity is set to the NUMA region (socket).**

From the output in figure 14.5, we see that all the ranks were launched on node cn328. Referring to the default affinity settings for OpenMPI at the start of this section, for more than two ranks the affinity is set to bind to the socket. The output from the `lscpu` command shows our first NUMA region contains the virtual processing cores 0-17, 36-53. NUMA regions are usually aligned with each socket. In our output, we see that the core affinity equals 0-17, 36-53, confirming that the affinity was set to the socket.

Because our real application memory requirements are larger than the 128 GiB on the node, it fails when allocating memory. We thus need to find a way to spread out the processes. For this, we add another option, `—npernode <#>` or `-N <#>`, which tells MPI how many ranks to put on each node. We need to have four nodes to get enough memory for our problem, so we want eight processes per node.

> `mpirun -n 32 --npernode 8 ./MPIAffinity | sort -n -k 4`

Figure 14.6 shows our placement report.

**Figure 14.6 The MPI processes are spread out across the four nodes, cn328 through 331. The affinity is still tied to the NUMA region.**

From the output in figure 14.6, we can see that we are running on four nodes. We should now have enough memory to run our application. Alternatively, we could specify how many ranks per socket with `—npersocket`. We have two sockets per node, so we want four ranks per socket, thus:

> `mpirun -n 32 --npersocket 4 ./MPIAffinity | sort -n -k 4`

Figure 14.7 shows the output from the placement per socket.

**Figure 14.7 With the placement set to four processes per socket, the order of the ranks changes. Now the four adjacent ranks are on the same NUMA region.**

The placement report in figure 14.7 shows that the order of the ranks places adjacent ranks on the same NUMA domain instead of alternating the ranks between NUMA domains. That might be better if ranks are communicating with nearest neighbors.

So far, we have only worked on the placement of processes. Now let’s try to see what we can do about the affinity and binding of the MPI processes. For this, we add the `—bind-to [socket | numa | core | hwthread]` option to mpirun:

> `mpirun -n 32 --npersocket 4 --bind-to core ./MPIAffinity | sort -n -k 4`

We can see how this changes the affinity for the processes in the placement report in figure 14.8.

**Figure 14.8 The affinity from binding to a core changes the affinity for the processes to a hardware core. Each hardware core represents two virtual cores because of hyperthreading. We get two locations for each process.**

The placement results in figure 14.8 show that the process affinity is now restricted more than it was previously. There are two virtual cores that each process can schedule to run on. These two virtual cores belong to one hardware core, thus showing that the core binding option refers to a hardware core. Only four of the 18 processor cores on each socket are used. This is what we want so that there is more memory for each MPI rank. Let’s try binding the process to the hyperthreads instead of to the core by using the `hwthread` option. This should force the scheduler to place processes on one, and only one, virtual core.

> `mpirun -n 32 --npersocket 4 --bind-to hwthread ./MPIAffinity | sort -n -k 4`

Again, we use our placement report program to visualize the placement with the output shown in figure 14.9.

**Figure 14.9 The process placement from the** **`hwthread`** **option limits where the processes can run to only one location.**

Our last processor layout finally restricts where each process can run to a single location as shown in figure 14.9. That seems like a good result. But wait. Take a closer look. The first two ranks are placed on the pair of hyperthreads (0 and 36) of a single hardware core. This is not a good idea. That means the two ranks are sharing the cache and hardware components of that hardware core instead of having their own full complement of resources.

The `mpirun` command in OpenMPI also has a built-in option to report bindings. It is convenient for small problems, but the amount of output for nodes with a lot of processors and MPI ranks is hard to handle. Adding `—report-bindings` to the `mpirun` command used for figure 14.9 produces the output shown in figure 14.10.

**Figure 14.10 Placement report from the** **`—report-bindings`** **option to mpirun shows where ranks are bound with the letter B.**

The visual layout is a little easier to quickly understand, and there is a lot of information packed into the output. Each line indicates a rank in `MPI_COMM_WORLD (MCW)`. The symbols between the forward slashes on the right side indicate the binding location for that process. The set of two dots between the forward slash symbols shows that there are two hyperthreads per core. The two sets of brackets delineate the two sockets on the node.

With the examples we explored in this section, you should be getting an idea of how to control placement and affinity. You should also have some tools to check that you are getting the placement and process bindings you expect.

***14.4.3 Affinity is more than just process binding: The full picture***

Now we will explore the full picture of affinity for parallel computing. We will use this as a way of introducing the advanced options offered in OpenMPI for even more control.

The concept of affinity is born out of how the operating system sees things. At the level of the operating system, you can set where each process is allowed to run. On Linux, this is done through either the `taskset` or the `numactl` commands. These commands, and similar utilities on other operating systems, emerged as the complexity of the CPU grew so that you could provide more information to the scheduler in the operating system. The directions might be taken as hints or requirements by the scheduler. Using these commands, you can pin a server process to a particular processor to be closer to a particular hardware component or to gain faster response. This focus on affinity alone is enough when dealing with a single process.

For parallel programming, there are additional considerations. We have a set of processes that we need to consider. Lets say we have 16 processors and we are running a four rank MPI job. Where do we put the ranks? Do we put these across the sockets, on all the sockets, pack them close together, or spread them out? Do we place certain ranks next to each other (ranks 1 and 2 together or ranks 1 and 4 together)? To be able to answer these questions, we need to address the following:

- Mapping (the placement of processes)

- Order of ranks (which ranks are close together)

- Binding (affinity or tying a process to a location or locations)

We’ll go over each in turn, along with how OpenMPI allows you to control these things.

***MAPPING PROCESSES TO PROCESSORS OR OTHER LOCATIONS***

When thinking about a parallel application, we have a set of processes and a set of processors. How do we map the processes to the processors? In the example used throughout section 14.4.2, we wanted to spread the processes over four nodes so that every process has more memory than it would if it were on a single node. The more general form for mapping processes in OpenMPI is `-mapby hwresource`, where the argument `hwresource` is any of a large number of hardware components. The most common include the following:

> `--map-by [slot | hwthread | core | socket | numa | node]`

With the `—map-by` option to the `mpirun` command, the processes are distributed in a round-robin fashion across this hardware resource. The default for the option is `socket`. Most of these hardware locations are self-explanatory except for `slot`. Slots are the list of possible locations for processes from the environment, the scheduler, or a host file. This form of the `—map-by` option is still limited in its meaning and, therefore, its effect.

A more general form uses an option called `ppr` or processes per resource, where `n` is the number of processes. Instead of a round-robin mapping by resource, you can specify a block of processes per hardware resource:

> `--map-by ppr:n:hwresource`

Or, more explicitly

> `--map-by ppr:n:[slot | hwthread | core | socket | numa | node]`

In our earlier examples, we used the simpler option of `—npernode 8`. In this more general form, it would be shorthand for

> `--map-by ppr:8:node`

If the level of control from the previous options to `mpirun` is not sufficient, you can specify a list of processor numbers to map with the `—cpu-list <logical processor numbers>` option, where the processor numbers are a list that corresponds to the list from `lstopo` or `lscpu`. This option also binds the processes to the logical (virtual) processor at the same time.

***ORDERING OF MPI RANKS***

Another thing you might want to control is the ordering of your MPI ranks. You may want adjacent MPI ranks to be close to each other in physical processor space if they communicate a lot with each other. This reduces the cost of the communication between these ranks. Usually, it is sufficient to control this with the block size of the distribution during mapping, but you can get additional control with the `—rank-by` option:

> `--rank-by ppr:n:[slot | hwthread | core | socket | numa | node]`

An even more general option is to use a rank file:

> `--rankfile <filename>`

While you can fine-tune the placement of your MPI ranks with these commands and perhaps gain a couple of percent in performance, it is difficult to come up with the optimum formula.

***BINDING PROCESSES TO HARDWARE COMPONENTS***

The last piece to control is affinity itself. Affinity is the process of binding the process to the hardware resource. The option is similar to the previous ones:

> `--bind-to [slot | hwthread | core | socket | numa | node]`

The default setting of `core` is sufficient for most MPI applications (without the `—bind-to` option the default is `socket` for greater than two processes as mentioned in section 14.4.1). But there are cases where that affinity setting causes problems.

As we saw in the example for figure 14.8, the affinity is set to the two hyperthreads on the hardware core. We might want to try `—map-to core—bind-to hwthread` to distribute the processes across the cores but bind each process more tightly to a single hyperthread. The performance difference from such fine-tuning is probably small. The greater problem comes when we try to implement a hybrid MPI and OpenMP application. It is important to realize that child processes inherit the affinity settings of their parent. If we use the options of `npersocket 4—bind-to core` and then launch two threads, we have two locations for the threads to run (two hyperthreads per core), so we are Ok. If we launch four threads, these will share only two logical processor locations and performance will be limited.

We saw earlier in this section that there are a lot of options for controlling process, placement, and affinity. Indeed, there are too many combinations to even fully explore as we did in section 14.3 for OpenMP. In most cases, we should be satisfied with getting reasonable settings that reflect the needs of our applications.

***14.5 Affinity for MPI plus OpenMP***

Our goal in this section is to understand how to set affinity for hybrid MPI and OpenMP applications. Getting affinity right for these hybrid situations can be tricky. For this exploration, we’ve created a hybrid stream triad example with MPI and OpenMP. We have also modified the placement report used throughout this chapter to output information for hybrid MPI and OpenMP applications. The following listing shows the modified subroutine, `place_report_ mpi_omp.c`.

**Listing 14.2 MPI and OpenMP placement reporting tool hybrid stream triad**

> `StreamTriad/place_report_mpi_omp.c`  
> `41 void place_report_mpi_omp(void)`  
> `42 {`  
> `43    int rank;`  
> `44    MPI_Comm_rank(MPI_COMM_WORLD, &rank);`  
> `45`  
> `46    int socket_global[144];`  
> `47    char clbuf_global[144][7 * CPU_SETSIZE];`  
> `48`  
> `49    #pragma omp parallel`  
> `50    {`  
> `51       if (omp_get_thread_num() == 0 && rank == 0){`  
> `52          printf("Running with %d thread(s)\n",omp_get_num_threads());`  
> `53          int bind_policy = omp_get_proc_bind();`  
> `54          switch (bind_policy)`  
> `55          {`  
> `56             case omp_proc_bind_false:`  
> `57                printf("  proc_bind is false\n");`  
> `58                break;`  
> `59             case omp_proc_bind_true:`  
> `60                printf("  proc_bind is true\n");`  
> `61                break;`  
> `62             case omp_proc_bind_master:`  
> `63                printf("  proc_bind is master\n");`  
> `64                break;`  
> `65             case omp_proc_bind_close:`  
> `66                printf("  proc_bind is close\n");`  
> `67                break;`  
> `68             case omp_proc_bind_spread:`  
> `69                printf("  proc_bind is spread\n");`  
> `70          }`  
> `71          printf("  proc_num_places is %d\n",omp_get_num_places());`  
> `72       }`  
> `73`  
> `74       int thread = omp_get_thread_num();`  
> `75       cpu_set_t coremask;`  
> `76       char clbuf[7 * CPU_SETSIZE], hnbuf[64];`  
> `77       memset(clbuf, 0, sizeof(clbuf));`  
> `78       memset(hnbuf, 0, sizeof(hnbuf));`  
> `79       gethostname(hnbuf, sizeof(hnbuf));`  
> `80       sched_getaffinity(0, sizeof(coremask), &coremask);`  
> `81       cpuset_to_cstr(&coremask, clbuf);`  
> `82       strcpy(clbuf_global[thread],clbuf);`  
> `83       socket_global[omp_get_thread_num()] = omp_get_place_num();`  
> `84       #pragma omp barrier`  
> `85       #pragma omp master`  
> `86       for (int i=0; i<omp_get_num_threads(); i++){`  
> `87          printf("Hello from rank %02d,"            `❶  
> `                   " thread %02d, on %s."             `❶  
> `88                 " (core affinity = %2s)"           `❶  
> `                   " OpenMP socket is %2d\n",         `❶  
> `89                  rank, i, hnbuf,                   `❶  
> `                    clbuf_global[i],                  `❶  
> `                    socket_global[i]);                `❶  
> `90       }`  
> `91    }`  
> `92 }`

❶ Merges OpenMP and the MPI affinity report

We start this example by compiling the stream triad application. The stream triad code is at <https://github.com/EssentialsofParallelComputing/Chapter14> in the StreamTriad directory. Compile the code with

> `mkdir build && cd build`  
> `./cmake -DCMAKE_VERBOSE=1 ..`  
> `make`

We ran this code on our Skylake Gold processor with 44 hardware processors and two hyperthreads each. We placed the two OpenMP threads on the hyperthreads and then an MPI rank on each hardware core. The following commands accomplish this layout:

> `export OMP_NUM_THREADS=2`  
> `mpirun -n 44 --map-by socket ./StreamTriad`

The stream triad code has a call to our placement report from listing 14.2. Figure 14.11 shows the output.

**Figure 14.11 The MPI ranks are placed in a round-robin fashion across the sockets with two slots to accommodate the two OpenMP threads. The placement is restricted to a NUMA domain to keep memory close to the threads. The processes are not bound tightly to any particular virtual core, and the scheduler can move these around freely within the NUMA domain.**

As the output in figure 14.11 shows, we succeeded in getting the ranks distributed across the NUMA domains in a round-robin manner, keeping the two threads together. This should give us good bandwidth from main memory. The affinity constraints are only sufficient to keep the processes within the NUMA domain and let the scheduler move the processes around as they wish. The scheduler can place thread 0 on any of 44 different virtual processors, including 0-21 or 44-65. The numbering can be confusing; 0 and 44 are two hyperthreads on the same physical core.

Now let’s try to obtain more affinity constraints. For this, we need to use the form `-mapby ppr:N:socket:PE=N`. This command gives us the ability to spread out the processes with a specified spacing and specify how many MPI ranks to place on each socket. It is hard to unbundle the complexity of the option.

Let’s start with the `ppr:N:socket` part. We want half of our MPI ranks on each socket. This should be 22 MPI ranks per socket or `ppr:22:socket`. The last part determines how many processors we want between the placement of processes. We want two threads for each MPI rank, so we want two virtual processors in each block. The specification is for hardware cores. It is important to know that each hardware core contains two virtual processors. Therefore, you only need one hardware core (`PE=1`). We then pin the threads to a hardware thread. For rank 0, we should get the first hardware core with the virtual processors 0 and 44. That gives us the following commands:

> `export OMP_NUM_THREADS=2`  
> `export OMP_PROC_BIND=true`  
> `mpirun -n 44 --map-by ppr:22:socket:PE=1 ./StreamTriad`

Whew! That was complicated. Did we get it right? Well, let’s check the output from the command as shown in figure 14.12.

**Figure 14.12 The process and thread affinity are now constrained to a logical core, and the two OpenMP threads per rank are located on the hyperthread pairs (`0`** **and** **`44`** **in the figure). The ranks are packed close in order to reduce communication costs for more complicated programs. The MPI ranks are pinned to hardware cores and the thread affinity is to the hyperthread.**

From the output in figure 14.12, we have the threads locked down where we want them. We also have the MPI rank pinned to the hardware core. You can verify this by unsetting the OMP_PROC_BIND environment variable (`unset OMP_PROC_BIND`) and the output (figure 14.13) confirms that the rank is bound to two logical processors, composing a single hardware core.

**Figure 14.13 Output without** **`OMP_PROC_BIND=true`** **shows that the MPI ranks are pinned to hardware cores.**

We’ve worked through one case and were able to get the affinity settings the way we wanted. But now you want to know if we can run more than two OpenMP threads and how the program performs. Let’s take a look at a set of commands that test any number of threads that divides into the number of processors evenly. The following listing shows the key scripting commands.

**Listing 14.3 Setting affinity for hybrid MPI and OpenMP**

> `Extracted from StreamTriad/run.sh`  
> `  1 #!/bin/sh`  
> ``   2 LOGICAL_PES_AVAILABLE=`lscpu |\                    ``❶  
> ``      grep '^CPU(s):' |cut -d':' -f 2`                  ``❶  
> ``   3 SOCKETS_AVAILABLE=`lscpu |\                        ``❶  
> ``      grep '^Socket(s):' |cut -d':' -f 2`               ``❶  
> ``   4 THREADS_PER_CORE=`lscpu |\                         ``❶  
> ``      grep '^Thread(s) per core:' |cut -d':' -f 2`      ``❶  
> `  5 POST_PROCESS="|& grep -e Average -e mpirun |sort -n -k 4"`  
> `  6 THREAD_LIST_FULL="2 4 11 22 44"`  
> `  7 THREAD_LIST_SHORT="2 11 22"`  
> `  8`  
> `  9 unset OMP_PLACES`  
> `10 unset OMP_CPU_BIND`  
> `11 unset OMP_NUM_THREADS`  
> `12`  
> `     < ... basic tests not shown ... >`  
> `21`  
> `22 export OMP_PROC_BIND=true                         `❷  
> ` `  
> `     < ... first loop block not shown ... >`  
>   
> `37 for num_threads in ${THREAD_LIST_FULL}`  
> `38 do`  
> `39    export OMP_NUM_THREADS=${num_threads}}         `❷  
> `40   `  
> `41    HW_PES_PER_PROCESS=$((${OMP_NUM_THREADS}/`  
> `                    ${THREADS_PER_CORE}))             `❸  
> `42    MPI_RANKS=$((${LOGICAL_PES_AVAILABLE}/ \       `❸  
> `                    ${OMP_NUM_THREADS}))              `❸  
> `43    PES_PER_SOCKET=$((${MPI_RANKS}/\               `❸  
> `                         ${SOCKETS_AVAILABLE}))       `❸  
> `44   `  
> `45    RUN_STRING="mpirun -n ${MPI_RANKS} \           `❹  
> `         --map-by ppr:${PES_PER_SOCKET}:socket:PE=${HW_PES_PER_PROCESS} \`  
> `         ./StreamTriad ${POST_PROCESS}"`  
> `46    echo ${RUN_STRING}`  
> `47    eval ${RUN_STRING}`  
> `48 done`  
>   
> `      < ... additional loop blocks ... >`

❶ Gets hardware characteristics

❷ Sets OMP environment variables

❸ Calculates needed values

❹ Fills the mpirun command

To make the script portable, we grab the hardware characteristics using the `lscpu` command. We then set the desired OpenMP environment parameters. We could set OMP_PROC_BIND to `true`, `close`, or `spread` with the same result for this case, where all the slots are filled. Then we calculate the variables needed for the `mpirun` command and launch the job.

In the full stream triad example in listing 14.2, we tested a combination of thread sizes and MPI ranks that divide evenly into 88 processes. We followed that with 44 total processes where we skip the hyperthreads because we didn’t really get any better performance with them (section 14.3). The performance results are pretty constant over the set of tests. That is because all that is being measured is the bandwidth from main memory. There is little work being done and no MPI communication. The benefits of hybrid MPI and OpenMP are limited in this situation. Where we would expect to see benefits is in much larger simulations where substituting an OpenMP thread for a MPI rank would

- Reduce the MPI buffer memory requirements

- Create larger domains that consolidate and reduce ghost cell regions

- Reduce contention for processors on a node for a single network interface

- Access vector units and other processor components that are not fully utilized

***14.6 Controlling affinity from the command line***

There are also general ways to control affinity from the command line. The command-line tools can help in situations where your MPI or special parallel application doesn’t have built-in options to control affinity. These tools can also help with general-purpose applications by binding these close to important hardware components such as graphics cards, network ports, and storage devices. In this section, we cover two command-line options: the hwloc and likwid suite of tools. These tools are developed with high-performance computing in mind.

***14.6.1 Using hwloc-bind to assign affinity***

The hwloc project was developed by INRIA, the French National Institute for Research in Computer Science and Automation. A subproject of the OpenMPI project, hwloc implements the OpenMPI placement and affinity capabilities that we saw in sections 14.4 and 14.5. The hwloc package is also a standalone package with command-line tools. Because there are many hwloc tools, as an introduction, we’ll just look at a couple of these. We’ll use hwloc-calc to get a list of hardware cores and hwloc-bind to bind these.

Using hwloc-bind is simple. Just prefix the application with `hwloc-bind` and then add the hardware location where you want it to bind. For our application, we’ll use the `lstopo` command. The `lstopo` command is also part of the hwloc tools. Here is our one-liner to launch the job on all the hardware cores and bind the processes to the cores:

> `` for core in `hwloc-calc --intersect core --sep " " all`; do hwloc-bind \ ``  
> `    core:${core} lstopo --no-io --pid 0 & done`

The `—intersect core` option only uses hardware cores. The `—sep " "` says to separate the numbers in the output with spaces instead of commas. The result of this command on our usual Skylake Gold processor launches 44 lstopo graphic windows, each looking similar to that in figure 14.14. Each window has the bound locations highlighted in green.

**Figure 14.14 The lstopo image shows the bound location in green (shaded core) at the lower left. This shows that process 22 is bound to the 22nd and 66th virtual cores, which are hyperthreads for a single physical core.**

We could use a similar command to launch two processes on the first core of each socket. For example

> `` for socket in `hwloc-calc --intersect socket \ ``  
> ``     --sep " " all`; do hwloc-bind \ ``  
> `    socket:${socket}.core:0 lstopo --no-io --pid 0 & done`

The following listing shows how we can build a general-purpose `mpirun` command with binding.

**Listing 14.4 Using hwloc-bind to bind processes**

> `MPI/mpirun_distrib.sh`  
> `1 #!/bin/sh`  
> `2 PROC_LIST=$1`  
> `3 EXEC_NAME=$2`  
> `4 OUTPUT="mpirun "                                `❶  
> `5 for core in ${PROC_LIST}`  
> `6 do`  
> `7     OUTPUT="$OUTPUT -np 1"\                     `❷  
> `              " hwloc-bind core:${core}"\          `❷  
> `              " ${EXEC_NAME} :"                    `❷  
> `8 done`  
> `` 9 OUTPUT=`echo ${OUTPUT} | sed -e 's/:$/\n/'`      ``❸  
> `10 eval ${OUTPUT}`

❶ Initializes this string with mpirun

❷ Appends another MPI rank launch with binding

❸ Strips last colon and substitutes a new line

Now we can launch our MPI affinity application from section 14.4 on the first core of each socket with this command:

> `./mpirun_distrib.sh "1 22" ./MPIAffinity`

This mpirun_distrib script builds the following command and executes it:

> `mpirun -np 1 hwloc-bind core:1 ./MPIAffinity : -np 1 hwloc-bind core:22`  
> `  ./MPIAffinity`

***14.6.2 Using likwid-pin: An affinity tool in the likwid tool suite***

The likwid-pin tool is one of the many great tools from the likwid (“Like I Knew What I’m Doing”) team at the University of Erlangen. We saw our first likwid tool, likwid-perfctr in section 3.3.1. The likwid tools in this section are command-line tools to set affinity. We’ll look at variants of the tool for OpenMP threads, MPI, and hybrid MPI plus OpenMP applications. The basic syntax for selecting processor sets in likwid uses these options:

- Default (physical numbering)

- `N` (node-level numbering)

- `S` (socket-level numbering)

- `C` (last level cache numbering)

- `M` (NUMA memory domain numbering)

To set the affinity, use this syntax: `-c <N,S,C,M>:[n1,n2,n3-n4]`. To get a list of the numbering schemes, use the command `likwid-pin -p`. Understanding how `likwid-pin` works is best gained from examples and experimentation.

***PINNING OPENMP THREADS WITH LIKWID-PIN***

This example shows how to use likwid-pin with OpenMP applications:

> `export OMP_NUM_THREADS=44`  
> `export OMP_PROC_BIND=spread`  
> `export OMP_PLACES=threads`  
> `./vecadd_opt3`

To get this same pinning result with likwid-pin for OpenMP applications, we use the socket (`S`) option. In the following, we distribute 22 threads on each socket, where the two pin sets are separated and concatenated with the @ symbol:

> `likwid-pin -c S0:0-21@S1:0-21 ./vecadd_opt3`

The OMP environment variables are not necessary when using likwid-pin and are mostly ignored. The number of threads is determined from the pin set lists. For this command, it is 44. We ran the vecadd example from section 14.3, configured with the `-DCMAKE_VERBOSE` option to get our placement report as figure 14.15 shows.

**Figure 14.15 The likwid-pin output is at the top of the screen, followed by our placement report output. The output shows that the threads are pinned to the 44 physical cores.**

Our placement report shows that the OMP environment variables are not set and that OpenMP has not placed and pinned the threads in the OpenMP sockets. And yet, we get the same placement and pinning from the likwid-pin tool with the same performance results. We have just confirmed that the OMP environment variables are not necessary with likwid-pin as we claimed in the previous paragraph. One thing to note is that if you set the OMP_NUM_THREADS environment variable to something other than the number of threads in the pin sets, the likwid tool distributes the threads from the `OMP_NUM_THREADS` variable across the processors specified in the pin sets. When there are more threads than processors, the tool wraps the thread placement around on the available processors.

***PINNING MPI RANKS WITH LIKWID-MPIRUN***

The likwid pinning functionality for MPI applications is included in the likwid-mpirun tool. You can use this tool as a substitute for mpirun in most MPI implementations. Let’s look at the MPIAffinity example from section 14.4.

> **Example: Pinning MPI ranks with likwid-mpirun**

> Run the MPIAffinity example on 44 ranks and use the `likwid-mpirun` command to pin the ranks to the hardware cores. By default, likwid-mpirun pins the ranks to the cores, so we need to use the `likwid-mpirun` command to get what we usually want without any additional options:

> `likwid-mpirun -n 44 ./MPIAffinity |sort -n -k 4`

Figure 14.16 shows the output from our placement report for this example.

**Figure 14.16 The placement report for likwid-mpirun shows that each rank is pinned to cores in numeric order.**

That was easy! As figure 14.16 shows, likwid-mpirun pins the ranks to the hardware cores. Let’s move on to an example where we have to provide some options to the command.

> **Example: Options for pinning MPI ranks with likwid-mpirun**

> We start with the basic command:

> `likwid-mpirun -n 22  ./MPIAffinity |sort -n -k 4`

> The ranks are distributed across the first 22 hardware cores on socket 0 and none on socket 1. We showed earlier that you need to distribute the processes across both sockets to get the full bandwidth from main memory. Adding the `-nperdomain` option lets us specify how many sockets per NUMA domain and the S:11 pin set gets the right numbers for 11 ranks on the socket. The command now looks like

> `likwid-mpirun -n 22 -nperdomain S:11  ./MPIAffinity |sort -n -k 4`

***14.7 The future: Setting and changing affinity at run time***

What if the user didn’t need to worry about affinity? It is challenging to get users to use the complicated invocations to properly place and pin processes. It might make more sense in many cases to embed the pinning logic into the executable. One way to do this would be to query information about the hardware and set the affinity appropriately. Few applications have yet undertaken this approach, but we expect to see more that do in the future.

Some applications not only set their affinity at run time but also modify the affinity to adapt to changing characteristics during run time! This innovative technique was developed by Sam Gutiérrez of Los Alamos National Laboratory in his QUO library. Perhaps you have an application that uses all MPI ranks on a node, but it calls a library that uses a combination of MPI ranks and OpenMP threads. The QUO library provides a simple interface built on top of hwloc to set proper affinities. It can then push the settings onto a stack, quiesce the processors, and set a new binding policy. We’ll look at examples of initiating process binding within your application and changing it during run time in the following sections.

***14.7.1 Setting affinities in your executable***

Setting your process placement and affinities in your application means that you no longer have to deal with complicated mpirun commands or portability between MPI implementations. Here we use the QUO library to implement this binding to all the cores on a Skylake Gold processor. The open source QUO library is available at <https://github.com/LANL/libquo.git>. First, we build the executable in the Quo directory and run the application with the number of hardware cores on your system:

> `make autobind`  
> `mpirun -n 44 ./autobind`

The source code for autobind is shown in listing 14.5. The program has the following steps. Our placement reporting routine is called before and afterward to show the process bindings.

1.  Initialize QUO

2.  Set affinities to the hardware cores

3.  Distribute the processes and bind these to the cores

4.  Return to the initial affinities

**Listing 14.5 Using QUO to bind processes from your executable**

> `Quo/autobind.c`  
> `31 int main(int argc, char **argv)`  
> `32 {`  
> `33     int ncores, nnoderanks, noderank, rank, nranks;`  
> `34     int work_member = 0, max_members_per_res = 2, nres = 0;`  
> `35     QUO_context qcontext;`  
> `36`  
> `37     MPI_Init(&argc, &argv);`  
> `38     QUO_create(&qcontext, MPI_COMM_WORLD);       `❶  
> `39     MPI_Comm_size(MPI_COMM_WORLD, &nranks);`  
> `40     MPI_Comm_rank(MPI_COMM_WORLD, &rank);`  
> `41     QUO_id(qcontext, &noderank);                 `❷  
> `42     QUO_nqids(qcontext, &nnoderanks);            `❷  
> `43     QUO_ncores(qcontext, &ncores);               `❷  
> `44`  
> `45     QUO_obj_type_t tres = QUO_OBJ_NUMANODE;      `❷  
> `46     QUO_nnumanodes(qcontext, &nres);             `❷  
> `47     if (nres == 0) {                             `❷  
> `48         QUO_nsockets(qcontext, &nres);           `❷  
> `49         tres = QUO_OBJ_SOCKET;                   `❷  
> `50     }                                            `❷  
> `51`  
> `52     if ( check_errors(ncores, nnoderanks, noderank, nranks, nres) )`  
> `53         return(-1);`  
> `54`  
> `55     if (rank == 0)`  
> `56         printf("\nDefault binding for MPI processes\n\n");`  
> `57     place_report_mpi();                          `❸  
> `58`  
> `59     SyncIt();`  
> `60     QUO_bind_push(qcontext,                      `❹  
> `                     QUO_BIND_PUSH_PROVIDED,        `❹  
> `61                   QUO_OBJ_CORE, noderank);       `❹  
> `62     SyncIt();`  
> `63`  
> `64     QUO_auto_distrib(qcontext, tres,             `❺  
> `                        max_members_per_res,        `❺  
> `65                      &work_member);              `❺  
> `66     if (rank == 0)`  
> `67         printf("\nProcesses should be pinned to the hw cores\n\n");`  
> `68     place_report_mpi();                          `❻  
> `69`  
> `70     SyncIt();`  
> `71     QUO_bind_pop(qcontext);                      `❼  
> `72     SyncIt();`  
> `73`  
> `74     QUO_free(qcontext);`  
> `75     MPI_Finalize();`  
> `76     return(0);`  
> `77 }`

❶ Initializes QUO context

❷ Gets system information

❸ Reports default bindings

❹ Sets new bindings to core

❺ Distributes and binds MPI ranks

❻ Reports new bindings

❼ Pops off the bindings and returns to initial settings

We need to be careful to synchronize processes as we change the bindings. To ensure that, in the following listing, we use an MPI barrier and a micro sleep call in the `SyncIt` routine.

**Listing 14.6** **`SyncIt`** **subroutine**

> `Quo/autobind.c`  
> `23 void SyncIt(void)`  
> `24 {`  
> `25     int rank;`  
> `26     MPI_Comm_rank(MPI_COMM_WORLD, &rank);`  
> `27     MPI_Barrier(MPI_COMM_WORLD);          `❶  
> `28     usleep(rank * 1000);                  `❷  
> `29 }`

❶ Standard MPI barrier

❷ Additional micro sleep

The output from the autobind application (figure 14.17) clearly shows the bindings changed from sockets to the hardware cores.

**Figure 14.17 The output from the autobind demo shows cores initially bound to sockets, but afterwards, these are bound to hardware cores.**

***14.7.2 Changing your process affinities during run time***

Suppose we have an application with one part that wants to use all MPI ranks and another part that works best with OpenMP threads. To handle this, we need to switch the affinities during run time. This is the scenario that QUO is designed for! The steps for this include

1.  Initialize QUO

2.  Set the process bindings to cores for MPI region

3.  Expand the bindings to the whole node for the OpenMP region

4.  Return to the settings for MPI

Let’s see how this is done with Quo in the following listing.

**Listing 14.7 Dynamic affinity demo switching from MPI to OpenMP**

> `Quo/dynaffinity.c`  
> `45 int main(int argc, char **argv)`  
> `46 {`  
> `47     int rank, noderank, nnoderanks;`  
> `48     int work_member = 0, max_members_per_res = 44;`  
> `49     QUO_context qcontext;`  
> `50`  
> `51     MPI_Init(&argc, &argv);`  
> `52     MPI_Comm_rank(MPI_COMM_WORLD, &rank);`  
> `53     QUO_create(&qcontext, MPI_COMM_WORLD);            `❶  
> `54`  
> `55     node_info_report(qcontext, &noderank, &nnoderanks);`  
> `56`  
> `57     SyncIt();`  
> `58     QUO_bind_push(qcontext,                           `❷  
> `                     QUO_BIND_PUSH_PROVIDED,             `❷  
> `59                   QUO_OBJ_CORE, noderank);            `❷  
> `60     SyncIt();`  
> `61`  
> `62     QUO_auto_distrib(qcontext, QUO_OBJ_SOCKET,        `❸  
> `                        max_members_per_res,             `❸  
> `63                      &work_member);                   `❸  
> `64`  
> `65     place_report_mpi_quo(qcontext);                   `❹  
> `66`  
> `67     /* change binding policies to accommodate OMP threads on node 0 */`  
> `68     bool on_rank_0s_node = rank < nnoderanks;`  
> `69     if (on_rank_0s_node) {`  
> `70         if (rank == 0) {`  
> `71             printf("\nEntering OMP region...\n\n");`  
> `72             // expands the caller's cpuset`  
> `               //    to all available resources on the node.`  
> `73             QUO_bind_push(qcontext,                   `❺  
> `                             QUO_BIND_PUSH_OBJ,          `❺  
> `                             QUO_OBJ_SOCKET, -1);        `❺  
> `74             report_bindings(qcontext, rank);          `❻  
> `75             /* do the OpenMP calculation */`  
> `76             place_report_mpi_omp();                   `❼  
> `77             /* revert to old binding policy */`  
> `78             QUO_bind_pop(qcontext);                   `❽  
> `79         }`  
> `80         /* QUO_barrier because it's cheaper than`  
> `              MPI_Barrier on a node. */`  
> `81         QUO_barrier(qcontext);`  
> `82     }`  
> `83     SyncIt();`  
> `84`  
> `85     // Wrap-up`  
> `86     QUO_free(qcontext);`  
> `87     MPI_Finalize();`  
> `88     return(0);`  
> `89 }`

❶ Initializes QUO context

❷ Sets affinities to hardware cores

❸ Distributes and binds MPI ranks

❹ Reports process affinities for all MPI regions

❺ Sets affinity to whole system

❻ Reports CPU masks for OpenMP region

❼ Reports process affinities for OpenMP region

❽ Pops off bindings and returns to MPI bindings

We can run the dynaffinity application with the number of hardware cores on our system with

> `make dynaffinity`  
> `mpirun -n 44 ./dynaffinity`

We again use our reporting routines to check the process bindings for the MPI region and for OpenMP. Figure 14.18 displays the output.

**Figure 14.18 For the MPI region, the processes are bound to the hardware cores. When we enter the OpenMP region, the affinities are expanded to the whole node.**

The output in figure 14.18 shows that the process bindings changed between the MPI and the OpenMP regions, accomplishing a dynamic modification of the affinities during run time.

***14.8 Further explorations***

The handling of process placement and bindings is relatively new. Watch for presentations in the MPI and OpenMP communities for additional developments in this area. In the next section, we list some of the most current materials on affinity that we recommend for additional reading. We’ll follow the additional reading with some exercises to explore the topic further.

***14.8.1 Additional reading***

The process placement reporting programs used in this chapter for OpenMP, MPI, and MPI plus OpenMP are modified from the xthi.c program used in training for several HPC sites. Here are references to papers and presentations that use it to explore affinities:

- Y. He, B. Cook, et al., “Preparing NERSC users for Cori, a Cray XC40 system with Intel many integrated cores” In Concurrency Computat: Pract Exper., 2018; 30:e4291 (<https://doi.org/10.1002/cpe.4291>).

- Argonne National Laboratory, “Affinity on Theta,” at [https://www.alcf.anl.gov/ support-center/theta/affinity-theta](https://www.alcf.anl.gov/support-center/theta/affinity-theta).

- National Energy Research Scientific Computing Center (NERSC), “Process and Thread Affinity,” at <https://docs.nersc.gov/jobs/affinity/>.

Here’s a good presentation on OpenMP that includes a discussion on affinity and how to handle it:

T. Mattson and H. He, “OpenMP: Beyond the common core,” at [http://mng.bz/ aK47](http://mng.bz/aK47).

We only covered part of the options for the mpirun command in OpenMPI. For exploring more capabilities, see the man page for OpenMPI:

[https://www.open-mpi.org/doc/v4.0/man1/mpirun.1.php.](https://www.open-mpi.org/doc/v4.0/man1/mpirun.1.php)

Portable Hardware Locality (hwloc) is a subproject of The Open MPI Project. It is a standalone package that works equally well with either OpenMPI or MPICH and has become the universal hardware interface for most MPI implementations and many other parallel programming software applications. For further information, see the following references:

- The hwloc project main page <https://www.open-mpi.org/projects/hwloc/>, where you’ll also find some key presentations.

- B. Goglin, “Understanding and managing hardware affinities with Hardware Locality (hwlooc),” High Performance and Embedded Architecture and Compilation (HiPEAC, 2013), <http://mng.bz/gxYV>.

The “Like I Knew What I’m Doing” (likwid) suite of tools is well regarded for its simplicity, usability, and good documentation. Here is a good starting point to investigate these tools further:

University of Erlangen-Nuremberg’s performance monitoring and benchmarking suite, <https://github.com/RRZE-HPC/likwid/wiki>.

This conference presentation about the QUO library gives a more complete overview and the philosophy behind it:

S. Gutiérrez et al., “Accommodating Thread-Level Heterogeneity in Coupled Parallel Applications,” [https://github.com/lanl/libquo/blob/master/docs/slides/gutier rez-ipdps17.pdf](https://github.com/lanl/libquo/blob/master/docs/slides/gutierrez-ipdps17.pdf), 2017 International Parallel and Distributed Processing Symposium (IPDPS17).

***14.8.2 Exercises***

1.  Generate a visual image of a couple of different hardware architectures. Discover the hardware characteristics for these devices.

2.  For your hardware, run the test suite using the script in listing 14.1. What did you discover about how to best use your system?

3.  Change the program used in the vector addition (vecadd_opt3.c) example in section 14.3 to include more floating-point operations. Take the kernel and change the operations in the loop to the Pythagorean formula:

    > `c[i] = sqrt(a[i]*a[i] + b[i]*b[i]);`

    > > How do your results and conclusions about the best placement and bindings change? Do you see any benefit from hyperthreads now (if you have those)?

4.  For the MPI example in section 14.4, include the vector add kernel and generate a scaling graph for the kernel. Then replace the kernel with the Pythagorean formula used in exercise 3.

5.  Combine the vector add and Pythagorean formula in the following routine (either in a single loop or two separate loops) to get more data reuse:

    > `c[i] = a[i] + b[i];`  
    > `d[i] = sqrt(a[i]*a[i] + b[i]*b[i]);`

    > > How does this change the results of the placement and binding study?

6.  Add code to set the placement and affinity within an application from one of the previous exercises.

***Summary***

- There are tools that show your process placement. These tools can also show you the affinity for your processes.

- Use process placement for your parallel applications. This gives you full main memory bandwidth for your application.

- Select a good process ordering for your OpenMP threads or MPI ranks. A good ordering reduces communication costs between processes.

- Use a binding policy for your parallel processes. Binding each process keeps the kernel from moving your process and losing the data it has loaded into cache.

- It is possible to change affinity within your application. This can accommodate code sections that would do better with different process affinities.
