# 15 Batch schedulers:Bringing order to chaos

***15 Batch schedulers:Bringing order to chaos***

This chapter covers

- The role of batch schedulers in high performance computing
- Submitting a job to a batch scheduler
- Linking job submissions for long runs or more complex workflows

Most high performance computing systems use batch schedulers to schedule the running of applications. We’ll give you a brief idea why in the first section of this chapter. Because schedulers are ubiquitous on high-end systems, you should have at least a basic understanding of them to be able to run jobs at high-performance computing centers and even smaller clusters. We’ll cover the purpose and usage of the batch schedulers. We won’t go into how to set up and manage them (that’s a whole other beast). Set up and management is a topic for system administrators and we are just lowly system users.

What if you don’t have access to a system with a batch scheduler? We don’t recommend installing a batch scheduler just to try out these examples. Rather, count your blessings and keep the information in this chapter handy for when the need arises. If your demand for computational resources grows and you begin using a larger multi-user cluster, you can come back to this chapter.

There are many different batch schedulers, and each installation has its own unique customizations. We’ll discuss two batch schedulers that are freely available: the Portable Batch System (PBS) and the Simple Linux Utility for Resource Management (Slurm). There are variants of each of these, including commercially supported versions.

The PBS scheduler originated at NASA in 1991 and was released as open source under the name OpenPBS in 1998. Subsequently, commercial versions, PBS Professional by Altair and PBS/TORQUE by Adaptive Computing Enterprises, were forked off as separate versions. Freely available versions are still available and in common use on smaller clusters. Larger high performance computing sites tend to have similar versions but with a support contract.

The Slurm scheduler originated at Lawrence Livermore National Laboratory in 2002 as a simple resource manager for Linux clusters. It later was spun off into various derivative versions such as the SchedMD version.

Schedulers can also be customized with plugins or add-ins that provide additional functionality, support for special workloads, and improved scheduling algorithms. You’ll also find a number of strictly commercial batch schedulers, but their functionality is similar to those presented here. The basic concepts of each scheduler implementation are much the same, and often, many details vary from site to site. Portability of batch scripts can still be a bit of a challenge and require some customization for each system.

***15.1 The chaos of an unmanaged system***

You just got your latest cluster up for your group and the software is running. Soon, you’ll have a dozen of your colleagues logging in and launching jobs. Ka-Boom—you have multiple parallel jobs on compute nodes colliding with each other, slowing these down, and sometimes, causing some jobs to crash. Palpable tension is in the air and tempers are short.

As high performance computing systems grow in size and number of users, it becomes necessary to add some management to the system to bring order to chaos and get the most performance from the hardware. Installation of a batch scheduler can save the day (figure 15.1). User jobs can be run, and the exclusive use of the hardware as a resource becomes a reality. However, the use of a batch system is not a panacea. While this type of software offers much to the users of the cluster or high performance computing system, batch schedulers require significant system administration time and the establishment of different queues and policies. With good policies, you can obtain privately allocated compute nodes for your exclusive use for a fixed block of time.

**Figure 15.1 Batch systems are like the supermarket checkout queueing system for a computer cluster. These help to make better use of the resources and bring more efficiency to your jobs.**

The order provided by the system management software is absolutely essential for achieving performance on your parallel applications. The historical work on batch schedulers in Beowulf clusters (mentioned in section 15.6.1) gives a good perspective on the importance of schedulers. In the late 1990s, Beowulf clusters emerged as a widespread movement to build computing clusters out of commodity computers. The Beowulf community soon realized that it was not enough to have a collection of computing hardware; it was necessary to have some software control and management to make it a productive resource.

***15.2 How not to be a nuisance when working on a busy cluster***

Busy clusters have lots of users and lots of work. A batch system is often implemented to manage the workload and get the most out of the system. These clusters are a different environment than a standalone, single-user workstation. When working on these busy clusters, it is essential to know how to effectively use the system while being considerate of other users. We’ll give you some of the stated and unstated social rules so as to not become a pariah on the busy cluster. But first, let’s consider how these typical systems are set up.

***15.2.1 Layout of a batch system for busy clusters***

Most clusters have some nodes set aside to be front ends. These front-end nodes are also called login nodes because that is where you will be when you log in to the system. The rest of the system is then set up as back-end nodes that are controlled and allocated by the batch system. These back-end nodes are organized into one or more queues. Each queue has a set of policies for things like the size of jobs (such as the number of processors or memory) and how long these jobs can run.

***15.2.2 How to be courteous on busy clusters and HPC sites: Common HPC pet peeves***

For interactive work

- Check the load on your front end with the `top` command and move to a lightly loaded front-end node. There is usually more than one front-end node with numbers such as fe01, fe02, and fe03.

- Watch for heavy file-transfer jobs on the front end. Some sites have special queues for these types of jobs. If you get a node that has heavy file usage, you may find that your compiles or other jobs might take much longer than usual even if the load does not appear to be high.

- Some sites want you to compile on the back end and others on the front end. Check the policies on your cluster.

- Don’t tie up nodes with batch interactive sessions and then go off to attend a meeting for several hours.

- Rather than get a second batch interactive session, export an X terminal or shell from your first session.

- For light work, look for queues for shared usage that allow over-subscription.

- Many sites have special queues for debugging. Use these when you need to debug, but don’t abuse these debug queues.

For big jobs

- Big parallel jobs should be run on the back-end nodes through the batch system queues.

- Keep the number of jobs in the queue small: don’t monopolize the queues.

- Try to run your big jobs during non-work hours so other users can get interactive nodes for their work.

For storage

- Store large files in the appropriate place. Most sites have large parallel file systems, scratch, project, or work directories for output from calculations.

- Move files to long-term storage for your site.

- Know the purging policies for file storage. Large sites will purge files in some of the scratch directories on a periodic basis.

- Clean up your files regularly and keep file systems below 90% full. File system performance drops off as file systems become full.

> > > **NOTE** Don’t be afraid to send private messages to users who are causing problems, but be courteous. They may not realize that their work is bringing many workflows to a standstill.

Further cluster wisdom includes the following:

- Heavy usage of the front-end nodes can cause instabilities and crashes. These instabilities affect the whole system as jobs can no longer be scheduled for the back-end nodes.

- Often projects get resource allocations that are used for prioritizing jobs using a “fair-share” scheduling algorithm. In these cases, you may need to submit an application for the resources that you need for your project.

- Each site can set policies that implement rules, but these cannot cover every situation. You should follow the spirit of the rules as well as the actual implementation. In other words, don’t game the system. It is not an inanimate object but rather your fellow users. They are also trying to get work done.

- Rather than gaming the system, you should optimize your code and your file storage. The savings will allow you to get more work done and will let others get their work done on the cluster as well.

- Submitting several hundred jobs into a queue when only a few can run at a time is inconsiderate. We generally submit a maximum of ten or so at a time and then submit additional jobs when each of those completes. There are many ways of doing this through shell scripts or even the batch dependency techniques (discussed later in this chapter).

- For jobs that require run times much longer than the maximum batch time allowed, you should implement checkpointing (section 15.4). Checkpointing catches batch termination signals or uses wall clock timings to get the most effective use of the whole batch time. A subsequent job then starts where the last one stopped.

***15.3 Submitting your first batch script***

In this section, we’ll go through the process of submitting your first batch script. Batch systems require a different way of thinking. Instead of just launching a job whenever you want, you have to think about organizing your work. Planning results in better use of resources even before your jobs get submitted. How do you use these batch systems? As figure 15.2 shows, there are two basic system modes.

Most of the commands used in one mode can also be used in the other. Let’s work through a couple of examples to see how these modes function. We’ll work with the Slurm batch scheduler in this first set of examples. We’ll start with an interactive example and modify the example into a batch file form.

The interactive command-line mode is generally used for program development, testing, or short jobs. For submitting longer production jobs, it is more common to use a batch file to submit a batch job. The batch file allows the user to run applications overnight or unattended. Batch scripts can even be written to automatically restart jobs if there is some catastrophic system event. We’ll show the translation in syntax from the command-line option to a batch script. But first we need to go over the basic structure of a batch script.

**Figure 15.2 Batch systems are typically used in either an interactive mode or a batch usage model.**

> **Example: Interactive command line**

> Let’s start on the front end of the cluster, where everybody logs in. Now we want two compute nodes (`-N 2`) with a total of 32 processors (`-n 32`) for an hour (`-t 1:00:00`). Notice the difference in capitalization for number of nodes (N) and number of processors (n). Also, you can limit your run to specified minutes, although many systems have a minimum and maximum run-time policy. Some systems even have minimums and maximums for the number of compute nodes you use. The `salloc` command for this specific request would be

> `frontend> salloc -N 2 -n 32 -t 1:00:00`

> The `salloc` command allocates and logs into two compute nodes. Note that the following command prompt changes to indicate that we are a on different system. The specific prompt is highly dependent on your system and environment settings. Once we have two nodes, we can launch our parallel application with:

> `computenode22> mpirun -n 32 ./my_parallel_app`

> This example shows starting up a parallel job with mpirun. As mentioned in section 8.1.3, the command to start a parallel job might be different on your system. When we are done, we just exit:

> `computenode22> exit`

> **Example: Batch file syntax**

> The job attributes are specified with the following syntax:

> `#SBATCH <option>`

> The file also contains the commands to execute, such as the mpirun command:

> `mpirun -n 32 ./my_parallel_app`

> The batch file is then submitted with the `sbatch` command:

> `sbatch < my_batch_job or sbatch my_batch_job`

> You can specify the options either on the interactive command line or with the SBATCH keyword. There is both a long-form option and a short-form syntax. For example, `time=1:00:00` is the long form and `-t=1:00:00` is the short form.

We show some of the more common options for Slurm in table 15.1.

**Table 15.1 Slurm command options**

| **Option**               | **Function**                                     | **Example**      |
|--------------------------|--------------------------------------------------|------------------|
| `[—time|-t]=hr:min:sec`  | Requests a maximum run time                      | `-t=8:00:00`     |
| `[—nodes|-N]=#`          | Requests a number of nodes                       | `—nodes=2`       |
| `[—ntasks|-n]=nprocs`    | Requests a number of processors                  | `-n=8`           |
| `[—job-name|-J]=name`    | Names your job                                   | `-J=job22`       |
| `[--output|-o]=filename` | Writes standard output to the specified filename | `-o=run.out`     |
| `[—error|-e]=filename`   | Writes error output to the specified filename    | `-e=run.err`     |
| `[—exclusive]`           | Specifies the exclusive use of nodes             | `—exclusive`     |
| `[—oversubscribe|-s]`    | Indicates the oversubscribe resources            | `—oversubscribe` |

Let’s go ahead and put this all together into our first full Slurm batch script as the following listing shows. This example is included with the associated code for the book at <https://github.com/EssentialsofParallelComputing/Chapter15>. As always, we encourage you to follow along with the examples for this chapter.

**Listing 15.1 Slurm batch script for a parallel job**

> ` 1 #!/bin/sh`  
> `2 #SBATCH -N 1                 `❶  
> `3 #SBATCH -n 4                 `❷  
> `5 #SBATCH -t 01:00:00          `❸  
> `6`  
> `7 # Do not place bash commands before the last SBATCH directive`  
> `8 # Behavior can be unreliable`  
> `9`  
> `10 mpirun -n 4 ./testapp &> run.out`

❶ Specifies one compute node

❷ Indicates four processors

❸ Runs job one hour

The `-N` on line 2 can alternatively be specified with `—nodes`. The `-N` has a different meaning in other batch schedulers and MPI implementations, leading to incorrect values and errors. You should be on the lookout for inconsistencies in syntax for the set of batch systems and MPIs that you use. We then submit this job with `sbatch < first_ slurm_batch_job`. We’ll get the equivalent of the batch job in an interactive job with

> `frontend> salloc -N 1 -n 4 -t 01:00:00`  
> `computenode22> mpirun -n 4 ./testapp`  
> `computenode22> exit`

> > > **NOTE** The options are the same in both the batch file and on the command line.

We need to make a special mention of the `exclusive` and `oversubscribe` options. One of the major reasons for using a batch system is to get exclusive use of the resource for more efficient application performance. Nearly every major computing center sets the default behavior to exclusive use of the resource. But the configuration may set one partition to be shared for particular use cases. You can use these command options, `exclusive` and `oversubscribe`, for the `sbatch` and `srun` commands to request a different behavior than the system configuration. However, you cannot override the shared configuration setting for a partition.

Most large computing systems are composed of many nodes with identical characteristics. It is, however, increasingly common to have systems with a variety of node types. Slurm provides commands that can request nodes with special characteristics. For example, you can use `—mem=<#>` to get large memory nodes with the requested size in MB. There are many other special requests that can be made through the batch system. A batch script for the PBS batch scheduler is similar, but with a different syntax. Some of the most common PBS options are shown in table 15.2.

**Table 15.2 PBS command options**

| **Option**                                      | **Function**                                              | **Example**          |
|-------------------------------------------------|-----------------------------------------------------------|----------------------|
| `-l [nodes|walltime|cput|mem |ncpus|ppn|procs]` | Catch-all for parallel requirements                       | `-l nodes=2,procs=4` |
| `-N <name>`                                     | Names the job                                             | `-N job22`           |
| `-o <filename>`                                 | Writes standard output to the specified filename          | `-o run.out`         |
| `-e <filename>`                                 | Writes error output to the specified filename             | `-e run.err`         |
| `-q <queue>`                                    | Queues for job submission (queue names are site specific) | `-q standard`        |
| `-j`                                            | Joins standard and error output                           | `-j -o run.out`      |

The `-l` option is a catch-all that is used for a variety of options. Let’s put together the equivalent PBS batch script for the same job as in listing 15.1. The following listing shows the PBS script.

**Listing 15.2 PBS batch script for a parallel job**

> ` 1 #!/bin/sh`  
> `2 #PBS -l nodes=1               `❶  
> `3 #PBS -l procs=4               `❶  
> `5 #PBS -l walltime=01:00:00     `❶  
> `6`  
> `7 # Do not place bash commands before the last PBS directive`  
> `8 # Behavior can be unreliable`  
> `9`  
> `10 mpirun -n 4 ./testapp &> run.out`

❶ PBS keywords and syntax

For PBS, we submit the job with `qsub < first_pbs_batch_job`. To get an interactive allocation in PBS, we use the `-I` option to `qsub`:

> `frontend> qsub -I -l nodes=1,procs=4,walltime=01:00:00`  
> `computenode22> mpirun -n 4 ./testapp &> run.out`  
> `computenode22> exit`

You may need to specify a queue or other site-specific information for these examples. Many sites have different queues for long, short, large, and other specialized situations. Consult the local site documentation for these important details.

We’ve seen a couple of batch scheduler commands in the previous discussion. To effectively use the system, you will need more commands, found below. These batch scheduler commands check on the status of your job, get information on the system resources, and cancel jobs. We summarize the most common commands for both the Slurm and PBS schedulers next.

> **Slurm reference guide**

- `salloc [—nodes|-N]=N [-ntasks|-n]=N` allocates nodes for a batch job:

> `frontend> salloc -N 1 -n 32`

- `sbatch` submits a batch job to the batch scheduler (see examples earlier in this section).

- `scancel` cancels a job either running or waiting in queue:

> `frontend> scancel <SLURM_JOB_ID>`

- `sinfo` provides information on the status of the system controlled by the batch scheduler:

> `frontend> sinfo`  
> `PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST`  
> `standard*    up    4:00:00      1  drain n02`  
> `standard*    up    4:00:00      5   resv n[03-07]`  
> `standard*    up    4:00:00      2  alloc n[08-09]`  
> `standard*    up    4:00:00      1   idle n01`  
> `debug        up    1:00:00      1   idle n10`

- `squeue` shows the jobs in the queue and their status (such as running or waiting to run). Most common usage is `squeue -u <username>` for just your own user jobs or `squeue` for all jobs.

> `frontend> squeue`  
> `JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)`  
> `35456  standard    sim_2      jrr PD       0:00      1 (Resources)`  
> `35455  standard    sim_1      jrr  R    2:26:54      1 n08`

- `srun [—nodes|-N]=N [—ntasks|-n]=N <exec>`, a replacement for mpirun, contains additional capabilities for placement and binding. If the affinity plugin is enabled, these additional options are available:

> `—sockets-per-node=S`  
> `—cores-per-socket=C`  
> `—threads-per-core=T`  
> `—ntasks-per-core=n`  
> `—ntasks-per-socket=n`  
> `—cpu-bind=[threads|cores|sockets]`  
> `—exclusive`  
> `—share`

> For example

> `frontend> srun -N 1 -n 16 --cpu-bind=cores my_exec`

- `scontrol` views or modifies Slurm components:

> `frontend> scontrol show job <SLURM_JOB_ID>`  
> `JobID=35456 JobName=sim2`  
> `  UserID=jrr <...and much more...>`

> The following table lists some environment variables in Slurm that can be useful in your batch scripts.

>   

> **PBS reference guide**

- `qsub` submits a batch job, where

- - \-`I` is an interactive job

  - The batch equivalent for this command is `#PBS` interactive=true.

  - `-W block=true` waits until job completion

  - The batch equivalent is `#PBS block=true`.

  - `qdel` deletes a batch job: `frontend> qdel <job ID>`

  - `qsig` sends a signal to the batch job: `frontend> qsig 23 56`

  - `qstat` shows the status of batch jobs

> `frontend> qstat or qstat -u jrr`  
> `                                                Req’d  Elap`  
> `JobID    User   Queue Jobname Sess NDS  TSK Mem Time S Time`  
> `-------- ------ ----- ------- ---- ---- --- --- ---- - ----`  
> `56.base  jrr    standard sim2 --   --     l  -- 0:30 R 0:02`

- `qmsg` sends a message to a batch job:

> `frontend> qmsg “message to standard error” 56`

> The following table lists some environment variables in PBS that can be useful in your batch scripts.

>   

***15.4 Automatic restarts for long-running jobs***

Most high-performance computing sites limit the maximum time that a job can run. So how do you run longer jobs? The typical approach is for applications to periodically write out their state into files and then a follow-on job is submitted that reads the file and starts at that point in the run. This process, as illustrated in figure 15.3, is referred to as checkpointing and restarting.

**Figure 15.3 A checkpoint file that saves the state of the calculation is written out to disk at the conclusion of a batch job and then the next batch job reads the file and restarts the calculation where the previous job left off.**

The checkpointing process is useful for dealing with a limited time for a batch job and for handling system crashes or other job interruptions. You might restart your jobs manually for a small number of cases, but as the number of restarts gets larger, it becomes a real burden. If this is the case, you should add the capability to automate the process. It takes a fair amount of effort to do this and requires changes to your application and more sophisticated batch scripts. We show a skeleton application where we have done this.

First, the batch script needs to signal your application that it is reaching the end of its allocated time. Then the script needs to resubmit itself recursively until your job reaches completion. The following listing shows such a script for Slurm.

**Listing 15.3 Batch script to automatically restart**

> `AutomaticRestarts/batch_restart.sh`  
> `1 #!/bin/sh`  
> `    < ... usage notes ... >`  
> `13 #SBATCH -N 1`  
> `14 #SBATCH -n 4`  
> `15 #SBATCH --signal=23@160                            `❶  
> `16 #SBATCH -t 00:08:00`  
> `17`  
> `18 # Do not place bash commands before the last SBATCH directive`  
> `19 # Behavior can be unreliable`  
> `20`  
> `21 NUM_CPUS=${SLURM_NTASKS}`  
> `22 OUTPUT_FILE=run.out`  
> `23 EXEC_NAME=./testapp`  
> `24 MAX_RESTARTS=4                                    `❷  
> `25`  
> `26 if [ -z ${COUNT} ]; then                          `❸  
> `27    export COUNT=0                                 `❸  
> `28 fi`  
> `29`  
> `30 ((COUNT++))                                       `❸  
> `31 echo "Restart COUNT is ${COUNT}"                  `❸  
> `32`  
> `33 if [ ! -e DONE ]; then                            `❹  
> `34    if [ -e RESTART ]; then                        `❺  
> `35       echo "=== Restarting ${EXEC_NAME} ===" \          `  
> `               >> ${OUTPUT_FILE}`  
> `` 36       cycle=`cat RESTART`                          ``❻  
> `37       rm -f RESTART`  
> `38    else`  
> `39       echo "=== Starting problem ==="  \`  
> `               >> ${OUTPUT_FILE}`  
> `40       cycle=""`  
> `41    fi`  
> `42`  
> `43    mpirun -n ${NUM_CPUS} ${EXEC_NAME} \           `❼  
> `             ${cycle} &>> ${OUTPUT_FILE}             `❼  
> `44    STATUS=$?`  
> `45    echo "Finished mpirun"  \`  
> `               >> ${OUTPUT_FILE}`  
> `46`  
> `47    if [ ${COUNT} -ge ${MAX_RESTARTS} ]; then      `❽  
> `48       echo "=== Reached maximum number of restarts ===" \`  
> `               >> ${OUTPUT_FILE}`  
> `49       date > DONE`  
> `50    fi`  
> `51`  
> `52    if [ ${STATUS} = "0" -a ! -e DONE ]; then`  
> `53       echo "=== Submitting restart script ==="  \`  
> `               >> ${OUTPUT_FILE}`  
> `54       sbatch <batch_restart.sh                    `❾  
> `55    fi`  
> `56 fi`

❶ Sends application a signal 23 (SIGURG) 160 s before termination

❷ Maximum number of script submissions

❸ Counts the number of submissions

❹ Checks for DONE file

❺ Checks for RESTART file

❻ Gets the iteration number for the command line

❼ Invokes MPI job with command-line arguments

❽ Exits if reached maximum restarts

❾ Submits next batch job

This script has a lot of moving parts. Much of this is to avoid a runaway situation where more batch jobs are submitted than needed. The script also requires cooperation with the application. This cooperation includes these tasks:

- The batch system sends a signal and the application catches it.

- The application writes out to a file named DONE when complete.

- The application writes out the iteration number to a file named RESTART.

- The application writes out a checkpoint file and reads it on restart.

The signal number might need to vary depending on what the batch system and MPI already use. We also caution you not to put shell commands before any of the Slurm commands. While the script might seem to work, we found that the signals did not function properly; therefore, order does matter and you won’t always get an obvious failure. Listing 15.4 shows a skeleton of an application code in C to demonstrate the automatic restart functionality.

> > > **NOTE** The example codes at <https://github.com/EssentialsofParallelComputing/Chapter15> also contain a Fortran example of an automatic restart.

**Listing 15.4 Sample application for testing**

> `AutomaticRestarts/testapp.c`  
> `1 #include <unistd.h>`  
> `2 #include <time.h>`  
> `3 #include <stdio.h>`  
> `4 #include <stdlib.h>`  
> `5 #include <signal.h>`  
> `6 #include <mpi.h>`  
> `7`  
> `8 static int batch_terminate_signal = 0;                         `❶  
> `9 void batch_timeout(int signum){                                `❷  
> `10    printf("Batch Timeout : %d\n",signum);`  
> `11    batch_terminate_signal = 1;                                 `❷  
> `12    return;`  
> `13 }`  
> `14`  
> `15 int main(int argc, char *argv[])`  
> `16 {`  
> `17    MPI_Init(&argc, &argv);`  
> `18    char checkpoint_name[50];`  
> `19    int mype, itstart = 1;`  
> `20    MPI_Comm_rank(MPI_COMM_WORLD, &mype);`  
> `21`  
> `22    if (argc >=2) itstart = atoi(argv[1]);`  
> `            // < ... read restart file ... >                      `❸  
> `24`  
> `25    if (mype ==0) signal(23, batch_timeout);                    `❹  
> `26`  
> `27    for (int it=itstart; it < 10000; it++){`  
> `28       sleep(1);                                                `❺  
> `29`  
> `30       if ( it%60 == 0 ) {`  
> `            // < ... write out checkpoint file ... >              `❻  
> `40       }`  
> `41       int terminate_sig = batch_terminate_signal;`  
> `42       MPI_Bcast(&terminate_sig, 1, MPI_INT, 0, MPI_COMM_WORLD);`  
> `43       if ( terminate_sig ) {`  
> `            // < ... write out RESTART and                        `❼  
> `             //   special checkpoint file ... >                   `❼  
> `54          MPI_Finalize();`  
> `55          exit(0);`  
> `56       }`  
> `57`  
> `58    }`  
> `59`  
> `            // < ... write out DONE file ... >                    `❽  
> `67    MPI_Finalize();`  
> `68    return(0);`  
> `69 }`

❶ Global variable for batch signal

❷ Callback function sets the global variable

❸ If a restart, reads the checkpoint file

❹ Sets the callback function for signal 23

❺ Stands in for computational work

❻ Writes out checkpoint every 60 iterations

❼ Writes out special checkpoint file and a file named RESTART

❽ Writes out DONE file when application meets completion criteria

This may appear to be a short and simple code, but there is a lot packed into these lines. A real application would need hundreds of lines to fully implement checkpointing and restart, completion criteria, and input handling. We also caution that developers need to carefully check their code to prevent runaway conditions. The signal timing also needs to be tuned for how long it takes to catch the signal, complete the iterations, and write out the restart file. For our little skeleton for an automatic restart application, we start the submission with

> `sbatch < batch_restart.sh `

and get the following output:

> `=== Starting problem ===`  
> `App launch reported: 2 (out of 2) daemons - 0 (out of 4) procs`  
> `60 Checkpoint: Mon May 11 20:06:08 2020`  
> `120 Checkpoint: Mon May 11 20:07:08 2020`  
> `180 Checkpoint: Mon May 11 20:08:08 2020`  
> `240 Checkpoint: Mon May 11 20:09:08 2020`  
> `Batch Timeout : 23`  
> `297 RESTART: Mon May 11 20:10:05 2020`  
> `Finished mpirun`  
> `=== Submitting restart script ===`  
> `=== Restarting ./testapp ===`  
> `App launch reported: 2 (out of 2) daemons - 0 (out of 4) procs`  
> `300 Checkpoint: Mon May 11 20:10:11 2020`  
> `< ... skipping output ... >`  
> `1186 RESTART: Mon May 11 20:25:05 2020`  
> `Finished mpirun`  
> `=== Reached maximum number of restarts === `

From the output, we see that the application writes out periodic checkpoint files every 60 iterations. Because the stand-in for computation work is actually a `sleep` command of 1 s, the checkpoints are 1 min apart. After approximately 300 s, the batch system sends the signal and the test application reports that it was caught. At that point, the script writes out a file named RESTART that contains the iteration number. The script then writes out a message that the restart script was resubmitted. The output also shows the application starting back up. In the output, we skipped showing the additional restarts and just showed the message that the maximum number of restarts has been reached.

***15.5 Specifying dependencies in batch scripts***

Do batch systems have built-in support for sequences of batch jobs? Most have a dependency feature that allows you to specify how one job depends on another. Using this dependency capability, we can get our subsequent jobs submitted earlier in the queue by submitting the next batch job prior to running our application. As figure 15.4 shows, this may give us higher priority for starting up the next batch job, depending on the policies of the site. Regardless, your jobs will be in the queue, and you don’t have to worry about whether the next job will be submitted.

**Figure 15.4 Automatic restart submitted at start of batch job will have more time in queue, which can give your restart job higher priority than one submitted at end of batch job (dependent on local scheduling policies).**

We can make this change to the batch script by adding the dependency clause (on line 33 in the following listing). This batch script is submitted first, before we begin our work, but with a dependency on the completion of this current batch job.

**Listing 15.5 Batch script to submit first to restart script**

> `Prestart/batch_restart.sh`  
> `1 #!/bin/sh`  
> `    < ... usage notes ... >`  
> `13 #SBATCH -N 1`  
> `14 #SBATCH -n 4`  
> `15 #SBATCH --signal=23@160`  
> `16 #SBATCH -t 00:08:00`  
> `17`  
> `18 # Do not place bash commands before the last SBATCH directive`  
> `19 # Behavior can be unreliable`  
> `20`  
> `21 NUM_CPUS=4`  
> `22 OUTPUT_FILE=run.out`  
> `23 EXEC_NAME=./testapp`  
> `24 MAX_RESTARTS=4`  
> `25`  
> `26 if [ -z ${COUNT} ]; then`  
> `27    export COUNT=0`  
> `28 fi`  
> `29`  
> `30 ((COUNT++))`  
> `31 echo "Restart COUNT is ${COUNT}"`  
> `32`  
> `33 if [ ! -e DONE ]; then`  
> `34    if [ -e RESTART ]; then`  
> `35       echo "=== Restarting ${EXEC_NAME} ==="  \`  
> `               >> ${OUTPUT_FILE}`  
> `` 36       cycle=`cat RESTART` ``  
> `37       rm -f RESTART`  
> `38    else`  
> `39       echo "=== Starting problem ==="  \`  
> `               >> ${OUTPUT_FILE}`  
> `40       cycle=""`  
> `41    fi`  
> `42`  
> `43    echo "=== Submitting restart script ==="  \`  
> `            >> ${OUTPUT_FILE}`  
> `44    sbatch --dependency=afterok:${SLURM_JOB_ID} \`  
> `             <batch_restart.sh                          `❶  
> `45`  
> `46    mpirun -n ${NUM_CPUS} ${EXEC_NAME} ${cycle}  \`  
> `            &>> ${OUTPUT_FILE}`  
> `47    echo "Finished mpirun"   \`  
> `             >> ${OUTPUT_FILE}`  
> `48`  
> `49    if [ ${COUNT} -ge ${MAX_RESTARTS} ]; then`  
> `50       echo "=== Reached maximum number of restarts ===" \`  
> `             >> ${OUTPUT_FILE}`  
> `51       date > DONE`  
> `52    fi`  
> `53 fi`

❶ Submit this batch job first with a dependency on its completion

This listing showed how to use dependencies in your batch scripts for the simple case of a checkpoint/restart, but dependencies are useful for many other situations. More complicated workflows might have pre-processing steps that need to complete before the main work and then a post-processing step afterward. Some more complex workflows need more than a dependency on whether the previous job completed. Fortunately, batch systems provide other types of dependencies between jobs. Table 15.3 shows the various possible options. PBS has similar dependencies for batch jobs that can be specified with `-W depend=<type:job id>`.

**Table 15.3 Dependency options for batch jobs**

| **Dependency option** | **Function**                                                          |
|-----------------------|-----------------------------------------------------------------------|
| `after`               | Job can begin after specified job(s) have started.                    |
| `afterany`            | Job can begin after specified job(s) have terminated with any status. |
| `afternotok`          | Job can begin after specified job(s) have failed.                     |
| `afterok`             | Job can begin after specified job(s) have successfully completed.     |
| `singleton`           | Job can begin after all jobs with same name and user have completed.  |

***15.6 Further explorations***

There are general reference materials for the Slurm and PBS schedulers, but you should also look at the documentation for your site. Many sites have customized setups and added commands and features for their specific needs. If you think you might want to set up a computing cluster with a batch system, you may want to research new initiatives such as OpenHPC and the Rocks Cluster distributions that have recently been released for different HPC computing niches.

***15.6.1 Additional reading***

Both freely available and commercially supported versions of Slurm are available from SchedMD. Not surprisingly, the SchedMD site has a lot of documentation on Slurm. Another good reference site is Lawrence Livermore National Laboratory where Slurm was originally developed.

- SchedMD and Slurm documentation at <https://slurm.schedmd.com>.

- Blaise Barney, “Slurm and Moab,” Lawrence Livermore National Laboratory, <https://computing.llnl.gov/tutorials/moab/>.

The best information on PBS is the PBS User Guide:

Altair Engineering, PBS User Guide, <https://www.altair.com/pdfs/pbsworks/PBSUserGuide2021.1.pdf>.

Though somewhat dated, the following online reference to setting up a Beowulf cluster is a good historical perspective on the emergence of cluster computing and how to set up cluster management, including the PBS batch scheduler:

Edited by William Gropp, Ewing Lusk, Thomas String, Beowulf Cluster Computing with Linux, 2nd ed. (Massachusetts Institute of Technology, 2002, 2003), [http:// etutorials.org/Linux+systems/cluster+computing+with+linux/](http://etutorials.org/Linux+systems/cluster+computing+with+linux/).

Here are some sites with information on current HPC software management systems:

- OpenHPC, [http://www.openhpc.community.](http://www.openhpc.community)

- Rocks Cluster, [http://www.rocksclusters.org.](http://www.rocksclusters.org)

***15.6.2 Exercises***

1.  Try submitting a couple of jobs, one with 32 processors and one with 16 processors. Check to see that these are submitted and whether they are running. Delete the 32 processor job. Check to see that it got deleted.

2.  Modify the automatic restart script so that the first job is a preprocessing step to set up for the computation before the restarts run the simulation.

3.  Modify the simple batch script in listing 15.1 for Slurm and 15.2 for PBS to clean up on failure by removing a file called simulation_database.

***Summary***

- Batch schedulers allocate resources so that you can use a parallel cluster efficiently. It is important to learn how to use these to run on larger, high-performance computing systems.

- There are many commands to query your job and its status. Knowing these commands allows you to better utilize the system.

- You can use automatic restarts and chaining of jobs to run larger simulations and workflows. Adding this capability to your application makes it possible to scale to problems that you would not otherwise be able to do.

- Batch job dependencies give the capability of controlling complex workflows. By using dependencies between multiple jobs, you can stage data, preprocess it for a calculation, or launch a post-processing job.
