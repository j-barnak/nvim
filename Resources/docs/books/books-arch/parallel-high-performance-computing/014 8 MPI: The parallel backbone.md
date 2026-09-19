# 8 MPI: The parallel backbone

***8 MPI: The parallel backbone***

This chapter covers

- Sending messages from one process to another
- Performing common communication patterns with collective MPI calls
- Linking meshes on separate processes with communication exchanges
- Creating custom MPI data types and using MPI Cartesian topology functions
- Writing applications with hybrid MPI plus OpenMP

The importance of the Message Passing Interface (MPI) standard is that it allows a program to access additional compute nodes and, thus, run larger and larger problems by adding more nodes to the simulation. The name message passing refers to the ability to easily send messages from one process to another. MPI is ubiquitous in the field of high-performance computing. Across many scientific fields, the use of supercomputers entails an MPI implementation.

MPI was launched as an open standard in 1994 and, within months, became the dominant parallel computing library-based language. Since 1994, the use of MPI has led to scientific breakthroughs from physics to machine learning to self-driving cars! Several implementations of MPI are now in widespread use. MPICH from Argonne National Laboratories and OpenMPI are two of the most common. Hardware vendors often have customized versions of one of these two implementations for their platforms. The MPI standard, now up to version 3.1 as of 2015, continues to evolve and change.

In this chapter, we’ll show you how to implement MPI in your application. We’ll start with a simple MPI program and then progress to a more complicated example of how to link together separate computational meshes on separate processes through communicating boundary information. We’ll touch on some advanced techniques that are important for well-written MPI programs, such as building custom MPI data types and the use of MPI Cartesian topology functions. Last, we’ll introduce combining MPI with OpenMP (MPI plus OpenMPI) and vectorization to get multiple levels of parallelism.

> > > **NOTE** We encourage you to follow along with the examples for this chapter at <https://github.com/EssentialsofParallelComputing/Chapter8>.

***8.1 The basics for an MPI program***

In this section, we will cover the basics that are needed for a minimal MPI program. Some of these basic requirements are specified by the MPI standard, while others are provided by convention by most MPI implementations. The basic structure and operation of MPI has stayed remarkably consistent since the first standard.

To begin, MPI is a completely library-based language. It does not require a special compiler or accommodations from the operating system. All MPI programs have a basic structure and process as figure 8.1 shows. MPI always begins with an `MPI_Init` call right at the start of the program and an `MPI_Finalize` at the program’s exit. This is in contrast to OpenMP, as discussed in chapter 7, which needs no special startup and shutdown commands and just places parallel directives around key loops.

**Figure 8.1 The MPI approach is library-based. Just compile, linking in the MPI library, and launch with a special parallel startup program.**

Once you write an MPI parallel program, it is compiled with an include file and library. Then it is executed with a special startup program that establishes the parallel processes across nodes and within the node.

***8.1.1 Basic MPI function calls for every MPI program***

The basic MPI function calls include `MPI_Init` and `MPI_Finalize`. The call to `MPI_Init` should be right after program startup, and the arguments from the `main` routine must be passed to the initialization call. Typical calls look like the following and may or may not use the `return` variable:

> `iret = MPI_Init(&argc, &argv);`  
> `iret = MPI_Finalize();`

Most programs will need the number of processes and the process rank within the group that can communicate, called a communicator. One of the main functions of MPI is to start up remote processes and lash these up so messages can be sent between the processes. The default communicator is `MPI_COMM_WORLD`, which is set up at the beginning of every parallel job by `MPI_Init`. Let’s take a moment to look at a few definitions:

- Process—An independent unit of computation that has ownership of a portion of memory and control over resources in user space.

- Rank—A unique, portable identifier to distinguish the individual process within the set of processes. Normally this would be an integer within the set of integers from zero to one less than the number of processes.

The calls to get these important variables are

> `iret = MPI_Comm_rank(MPI_COMM_WORLD, &rank);`  
> `iret = MPI_Comm_size(MPI_COMM_WORLD, &nprocs);`

***8.1.2 Compiler wrappers for simpler MPI programs***

Although MPI is a library, we can treat it like a compiler through the use of the MPI compiler wrappers. This makes the building of MPI applications easier because you don’t need to know which libraries are required and where the libraries are located. These are especially convenient for small MPI applications. There are compiler wrappers for each programming language:

- `mpicc—Wrapper` for C code

- `mpicxx—Wrapper` for C++ (also can be `mpiCC` or `mpic++`)

- `mpifort—Wrapper` for Fortran (also can be `mpif77` or `mpif90`)

Using these wrappers is optional. If you are not using the compiler wrappers, they can still be valuable for identifying the compile flags necessary for building your application. The `mpicc` command has options that output this information. You can find these options for your MPI with `man` `mpicc`. For the two most popular MPI implementations, we list the command-line options for `mpicc`, `mpicxx`, and `mpifort` here.

- For OpenMPI, use these command options:

- `—showme`

- `—showme:compile`

- `—showme:link`

- For MPICH, use these command options:

- `-show`

- `-compile_info`

- `-link_info`

***8.1.3 Using parallel startup commands***

The startup of the parallel processes for MPI is a complex operation that is handled by a special command. At first, this command was often `mpirun`. But with the release of the MPI 2.0 standard in 1997, the startup command was recommended to be `mpiexec`, to try and provide more portability. Yet this attempt at standardization was not completely successful, and today there are several names used for the startup command:

- `mpirun -n <nprocs>`

- `mpiexec -n <nprocs>`

- `aprun`

- `srun`

Most MPI startup commands take the option `-n` for the number of processes, but others might take `-np`. With the complexity of recent computer node architectures, the startup commands have a myriad of options for affinity, placement, and environment (some of which we will discuss in chapter 14). These options vary with each MPI implementation and even with each release of their MPI libraries. The simplicity of the options available from the original startup commands has morphed into a confusing morass of options that have not yet stabilized. Fortunately, for the beginning MPI user, most of these options can be ignored, but they are important for advanced use and tuning.

***8.1.4 Minimum working example of an MPI program***

Now that we have learned all the basic components, we can combine them into the minimum working example that listing 8.1 shows: we start the parallel job and print out the rank and number of processes from each process. In the call to get the rank and size, we use the `MPI_COMM_WORLD` variable that is the group of all the MPI processes and is predefined in the MPI header file. Note that the displayed output can be in any order; the MPI program leaves it up to the operating system for when and how the output is displayed.

**Listing 8.1 MPI minimum working example**

> `MinWorkExampleMPI.c`  
> `1 #include <mpi.h>                               `❶  
> `2 #include <stdio.h>`  
> `3 int main(int argc, char **argv)`  
> `4 {`  
> `5    MPI_Init(&argc, &argv);                     `❷  
> `6`  
> `7    int rank, nprocs;`  
> `8    MPI_Comm_rank(MPI_COMM_WORLD, &rank);       `❸  
> `9    MPI_Comm_size(MPI_COMM_WORLD, &nprocs);     `❹  
> `10`  
> `11    printf("Rank %d of %d\n", rank, nprocs);`  
> `12`  
> `13    MPI_Finalize();                             `❺  
> `14    return 0;`  
> `15 }`

❶ Include file for MPI functions and variables

❷ Initializes after program start, including program arguments

❸ Gets the rank number of the process

❹ Gets the number of ranks in the program determined by the mpirun command

❺ Finalizes MPI to synchronize ranks and then exits

Listing 8.2 defines a simple makefile to build this example using the MPI compiler wrappers. In this case, we use the `mpicc` wrapper to supply the location of the mpi.h include file and the MPI library.

**Listing 8.2 Simple makefile using MPI compiler wrappers**

> `MinWorkExample/Makefile.simple`  
>   
> `default:        MinWorkExampleMPI`  
> `all:    MinWorkExampleMPI`  
>   
> `MinWorkExampleMPI: MinWorkExampleMPI.c Makefile`  
> `        mpicc MinWorkExampleMPI.c  -o MinWorkExampleMPI`  
>   
> `clean:`  
> `        rm -f MinWorkExampleMPI MinWorkExampleMPI.o`

For more elaborate builds on a variety of systems, you might prefer CMake. The following listing shows the CMakeLists.txt file for this program.

**Listing 8.3 The CMakeLists.txt for building with CMake**

> `MinWorkExample/CMakeLists.txt`  
> `cmake_minimum_required(VERSION 2.8)`  
>   
> `project(MinWorkExampleMPI)`  
>   
> `# Require MPI for this project:`  
> `find_package(MPI REQUIRED)                            `❶  
>   
> `add_executable(MinWorkExampleMPI MinWorkExampleMPI.c)`  
>   
> `target_include_directories(MinWorkExampleMPI          `❷  
> `   PRIVATE ${MPI_C_INCLUDE_PATH})                     `❷  
> `target_compile_options(MinWorkExampleMPI              `❷  
> `   PRIVATE ${MPI_C_COMPILE_FLAGS})                    `❷  
> `target_link_libraries(MinWorkExampleMPI               `❷  
> `   ${MPI_C_LIBRARIES} ${MPI_C_LINK_FLAGS})            `❷  
>   
> `# Add a test:`  
> `enable_testing()`  
> `add_test(MPITest ${MPIEXEC} ${MPIEXEC_NUMPROC_FLAG}   `❸  
> `   ${MPIEXEC_MAX_NUMPROCS}                            `❸  
> `   ${MPIEXEC_PREFLAGS}                                `❸  
> `   ${CMAKE_CURRENT_BINARY_DIR}/MinWorkExampleMPI      `❸  
> `   ${MPIEXEC_POSTFLAGS})                              `❸  
>   
> `# Cleanup`  
> `add_custom_target(distclean COMMAND rm -rf CMakeCache.txt CMakeFiles`  
> `                  Makefile cmake_install.cmake CTestTestfile.cmake Testing)`

❶ Calls a special module to find MPI and sets variables

❷ Modifies the compile flags

❸ Creates a portable MPI test

Now using the CMake build system, let’s configure, build, and then run the test with these commands:

> `cmake .`  
> `make`  
> `make test`

The write operation from the `printf` command displays output in any order. Finally, to clean up after the run, use these commands:

> `make clean`  
> `make distclean`

***8.2 The send and receive commands for process-to-process communication***

The core of the message-passing approach is to send a message from point-to-point or, perhaps more precisely, process-to-process. The whole point of parallel processing is to coordinate work. To do this, you need to send messages either for control or work distribution. We’ll show you how these messages are composed and properly sent. There are many variants of the point-to-point routines; we’ll cover those that are recommended to use in most situations.

Figure 8.2 shows the components of a message. There must be a mailbox at either end of the system. The size of the mailbox is important. The sending side knows the size of the message, but the receiving side does not. To make sure there is a place for the message to be stored, it is usually better to post the receive first. This avoids delaying the message by the receiving process having to allocate a temporary space to store the message until a receive is posted and it can copy it to the right location. For an analogy, if the receive (mailbox) is not posted (not there), the postman has to hangout until someone puts one up. Posting the receive first avoids the possibility of insufficient memory space on the receiving end to allocate a temporary buffer to store the message.

**Figure 8.2 A message in MPI is always composed of a pointer to memory, a count, and a type. The envelope has an address composed of a rank, a tag, and a communication group along with an internal MPI context.**

The message itself is always composed of a triplet at both ends: a pointer to a memory buffer, a count, and a type. The type sent and type received can be different types and counts. The rationale for using types and counts is that it allows the conversion of types between the processes at the source and at the destination. This permits a message to be converted to a different form at the receiving end. In a heterogeneous environment, this might mean converting lower-endian to big-endian, a low-level difference in the byte order of data stored on different hardware vendors. Also, the receive size can be greater than the amount sent. This permits the receiver to query how much data is sent so it can properly handle the message. But the receiving size cannot be smaller than the sending size because it would cause a write past the end of the buffer.

The envelope also is composed of a triplet. It defines who the message is from, who it is sent to, and a message identifier to keep from getting multiple messages confused. The triplet consists of the rank, tag, and communication group. The rank is for the specified communication group. The tag helps the programmer and MPI distinguish which message goes to which receive. In MPI, the tag is a convenience. It can be set to `MPI_ANY_TAG` if an explicit tag number is not desired. MPI uses a context created internally within the library to separate the messages correctly. Both the communicator and the tag must match for a message to complete.

> > > **NOTE** One of the strengths of the message-passing approach is the memory model. Each process has clear ownership of its data plus the control and synchronization over when the data changes. You can be guaranteed that some other process cannot change your memory while your back is turned.

Now let’s try an MPI program with a simple send/receive. We have to send data on one process and receive data on another. There are different ways that we could issue these calls on a couple of processes (figure 8.3). Some of the combinations of basic blocking send and receives are not safe and can hang, such as the two combinations on the left of figure 8.3. The third combination requires careful programming with conditionals. The method to the far right is one of several safe methods to schedule communications by using non-blocking sends and receives. These are also called asynchronous or immediate calls, which explains the I character preceding the `send` and `receive` keywords (the case shown on the far right of the figure).

**Figure 8.3 The ordering of blocking send and receives is tricky to do correctly. It is much safer and faster to use the non-blocking or immediate forms of the send and receive operations and then wait for completion.**

The most basic MPI send and receive is `MPI_Send` and `MPI_Recv`. The basic send and receive functions have the following prototypes:

> `MPI_Send(void *data, int count, MPI_Datatype datatype, int dest, int tag,`  
> `         MPI_COMM comm)`  
> `MPI_Recv(void *data, int count, MPI_Datatype datatype, int source, int tag,`  
> `         MPI_COMM comm, MPI_Status *status)`

Now let’s go through each of the four cases in figure 8.3 to understand why some hang and some work fine. We’ll begin with the `MPI_Send` and `MPI_Receive` that were shown in the previous function prototypes and in the left-most example in the figure. Both of these routines are blocking. Blocking means that these do not return until a specific condition is fulfilled. In the case of these two calls, the condition for return is that the buffer is safe to use again. On the send, the buffer must have been read and is no longer needed. On the receive, the buffer must be filled. If both processes in a communication are blocking, a situation known as a hang can occur. A hang occurs when one or more processes are waiting on an event that can never occur.

> **Example: A blocking send/receive program that hangs**

> This example highlights a common problem in parallel programming. You must always be on guard to avoid a situation that might hang (deadlock). In the following listing, we look at how this might occur so that we can avoid it.

> **A simple send/receive example in MPI (always hangs)**

> `Send_Recv/SendRecv1.c`  
> `1 #include <mpi.h>`  
> `2 #include <stdio.h>`  
> `3 #include <stdlib.h>`  
> `4 int main(int argc, char **argv)`  
> `5 {`  
> `6    MPI_Init(&argc, &argv);`  
> `7`  
> `8    int count = 10;`  
> `9    double xsend[count], xrecv[count];`  
> `10    for (int i=0; i<count; i++){`  
> `11       xsend[i] = (double)i;`  
> `12    }`  
> `13`  
> `14    int rank, nprocs;`  
> `15    MPI_Comm_rank(MPI_COMM_WORLD, &rank);`  
> `16    MPI_Comm_size(MPI_COMM_WORLD, &nprocs);`  
> `17    if (nprocs%2 == 1){`  
> `18       if (rank == 0){`  
> `19          printf("Must be called with an even number of processes\n");`  
> `20       }`  
> `21       exit(1);`  
> `22    }`  
> `23`  
> `24    int tag = rank/2;                              `❶  
> `25    int partner_rank = (rank/2)*2 + (rank+1)%2;    `❷  
> `26    MPI_Comm comm = MPI_COMM_WORLD;`  
> `27`  
> `28    MPI_Recv(xrecv, count, MPI_DOUBLE,             `❸  
> `               partner_rank, tag, comm,              `❸  
> `               MPI_STATUS_IGNORE);                   `❸  
> `29    MPI_Send(xsend, count, MPI_DOUBLE,             `❹  
> `               partner_rank, tag, comm);             `❹  
> `30`  
> `31    if (rank == 0) printf("SendRecv successfully completed\n");`  
> `32`  
> `33    MPI_Finalize();`  
> `34    return 0;`  
> `35 }`

> ❶ Integer division pairs up the tags for the send and receive partners.

> ❷ Partner rank is the opposite member of the pair.

> ❸ Receives are posted first.

> ❹ Sends are done after the receives.

> The tag and rank of the communication partner are calculated through integer and modulo arithmetic that pairs up the tags for each send and receive and gets the rank of the other member of the pair. Then the receives are posted for every process with its partner. These are blocking receives that do not complete (return) until the buffer is filled. Because the send is not called until after the receives complete, the program hangs. Note that we wrote the send and receive calls without `if` statements (conditionals) based on rank. Conditionals are the source of many bugs in parallel code, so these are generally good to avoid.

Let’s try reversing the order of the sends and receives. We list the changed lines in the following listing from the original listing in the previous example.

**Listing 8.4 A simple send/receive example in MPI (sometimes fails)**

> `Send_Recv/SendRecv2.c`  
> `28    MPI_Send(xsend, count, MPI_DOUBLE,    `❶  
> `               partner_rank, tag, comm);    `❶  
> `29    MPI_Recv(xrecv, count, MPI_DOUBLE,    `❷  
> `               partner_rank, tag, comm,     `❷  
> `               MPI_STATUS_IGNORE);          `❷

❶ First calls send operation

❷ Then calls receive operation after send completes

So does this one fail? Well, it depends. The send call returns after the use of the send data buffer is complete. Most MPI implementations will copy the data into preallocated buffers on the sender or receiver if the size is small enough. In this case, the send completes and the receive is called. If the message is large, the send waits for the receive call to allocate a buffer to put the message into before returning. But the receive never gets called, so the program hangs. We could alternate the posting of sends and receives by ranks so that hangs do not occur. We have to use a conditional for this variant as the following listing shows.

**Listing 8.5 Send/receive with alternating sends and receives by rank**

> `Send_Recv/SendRecv3.c`  
> `28    if (rank%2 == 0) {                                                `❶  
> `29       MPI_Send(xsend, count, MPI_DOUBLE, partner_rank, tag, comm);`  
> `30       MPI_Recv(xrecv, count, MPI_DOUBLE, partner_rank, tag, comm,`  
> `                  MPI_STATUS_IGNORE);`  
> `31    } else {                                                          `❷  
> `32       MPI_Recv(xrecv, count, MPI_DOUBLE, partner_rank, tag, comm,`  
> `                  MPI_STATUS_IGNORE);`  
> `33       MPI_Send(xsend, count, MPI_DOUBLE, partner_rank, tag, comm);`  
> `34    }`

❶ Even ranks post the send first.

❷ Odd ranks do the receive first.

But this is complicated to get right in more complex communication and requires careful use of conditionals. A better way to implement this is by using the `MPI_Sendrecv` call as the next listing shows. By using this call, you hand-off the responsibility for correctly executing the communication to the MPI library. This is a pretty good deal for the programmer.

**Listing 8.6 Send/receive with the** **`MPI_Sendrecv`** **call**

> `Send_Recv/SendRecv4.c`  
> `28    MPI_Sendrecv(xsend, count, MPI_DOUBLE,   `❶  
> `                   partner_rank, tag,          `❶  
> `29                 xrecv, count, MPI_DOUBLE,   `❶  
> `                   partner_rank, tag, comm,    `❶  
> `                   MPI_STATUS_IGNORE);         `❶

❶ A combined send/receive call replaces the individual MPI_Send and MPI_Recv.

The `MPI_Sendrecv` call is a good example of the advantages of using the collective communication calls that we’ll present in section 8.3. It is good practice to use the collective communication calls when possible because these delegate responsibility for avoiding hangs and deadlocks, as well as the responsibility for good performance to the MPI library.

As an alternative to the blocking communication calls in previous examples, we look at using the `MPI_Isend` and `MPI_Irecv` in listing 8.7. These are called immediate (I) versions because these return immediately. This is often referred to as asynchronous or non-blocking calls. Asynchronous means that the call initiates the operation but does not wait for the completion of the work.

**Listing 8.7 A simple send/receive example using** **`Isend`** **and** **`Irecv`**

> `Send_Recv/SendRecv5.c`  
> `27    MPI_Request requests[2] =`  
> `         {MPI_REQUEST_NULL, MPI_REQUEST_NULL};          `❶  
> `28`  
> `29    MPI_Irecv(xrecv, count, MPI_DOUBLE,               `❷  
> `                partner_rank, tag, comm,                `❷  
> `                &requests[0]);                          `❷  
> `30    MPI_Isend(xsend, count, MPI_DOUBLE,               `❸  
> `                partner_rank, tag, comm,                `❸  
> `                &requests[1]);                          `❸  
> `31    MPI_Waitall(2, requests, MPI_STATUSES_IGNORE);    `❹

❶ Defines an array of requests and sets to null so these are defined when tested for completion

❷ The Irecv is posted first.

❸ The Isend is then called after the Irecv completes.

❹ Calls a Waitall to wait for the send and receive to complete

Each process waits at the `MPI_Waitall` on line 31 of the listing for message completion. You should also see a measurable improvement in program performance by reducing the number of places that block from every send and receive call to just the single `MPI_Waitall`. But you must be careful not to modify the send buffer or access the receive buffer until the operation completes. There are other combinations that work. Let’s look at the following listing, which uses one possibility.

**Listing 8.8 A mixed immediate and blocking send/receive example**

> `Send_Recv/SendRecv6.c`  
> `27    MPI_Request request;`  
> `28`  
> `29    MPI_Isend(xsend, count, MPI_DOUBLE,    `❶  
> `                partner_rank, tag, comm,     `❶  
> `                &request);                   `❶  
> `30    MPI_Recv(xrecv, count, MPI_DOUBLE,     `❷  
> `               partner_rank, tag, comm,      `❷  
> `               MPI_STATUS_IGNORE);           `❷  
> `31    MPI_Request_free(&request);            `❸

❶ Posts the send with an MPI_Isend so that it returns

❷ Calls the blocking receive. This process can continue as soon as it returns.

❸ Frees the request handle to avoid a memory leak

We start the communication with an asynchronous send and then block with a blocking receive. Once the blocking receive completes, this process can continue even if the send has not completed. You still must free the request handle with an `MPI_Request_free` or as a side-effect of a call to `MPI_Wait` or an `MPI_Test` to avoid a memory leak. You can also call the `MPI_Request_free` immediately after the `MPI_Isend`.

Other variants of send/receive might be useful in special situations. The modes are indicated by a one- or two-letter prefix, similar to that seen in the immediate variant, as listed here:

- `B` (buffered)

- `S` (synchronous)

- `R` (ready)

- `IB` (immediate buffered)

- `IS` (immediate synchronous)

- `IR` (immediate ready)

The list of predefined MPI data types for C is extensive; the data types map to nearly all the types in the C language. MPI also has types corresponding to Fortran data types. We list just the most common ones for C:

- `MPI_CHAR` (a 1-byte C character type)

- `MPI_INT` (a 4-byte integer type)

- `MPI_FLOAT` (a 4-byte real type)

- `MPI_DOUBLE` (an 8-byte real type)

- `MPI_PACKED` (a generic byte-sized data type, usually used for mixed data types)

- `MPI_BYTE` (a generic byte-sized data type)

The `MPI_PACKED` and `MPI_BYTE` are special types and match any other type. `MPI_BYTE` indicates an untyped value and the count specifies the number of bytes. It bypasses any data conversion operations in heterogeneous data communications. `MPI_PACKED` is used with the `MPI_PACK` routine as the ghost exchange example in section 8.4.3 shows. You can also define your own data type to use in these calls. This is also demonstrated in the ghost exchange example. There are also many communication completion testing routines, which include

> `int MPI_Test(MPI_Request *request, int *flag, MPI_Status *status)`  
> `int MPI_Testany(int count, MPI_Request requests[], int *index, int *flag,`  
> `                MPI_Status *status)`  
> `int MPI_Testall(int count, MPI_Request requests[], int *flag,`  
> `                MPI_Status statuses[])`  
> `int MPI_Testsome(int incount, MPI_Request requests[], int *outcount,`  
> `                 int indices[], MPI_Status statuses[])`  
> `int MPI_Wait(MPI_Request *request, MPI_Status *status)`  
> `int MPI_Waitany(int count, MPI_Request requests[], int *index,`  
> `                MPI_Status *status)`  
> `int MPI_Waitall(int count, MPI_Request requests[], MPI_Status statuses[])`  
> `int MPI_Waitsome(int incount, MPI_Request requests[], int *outcount,`  
> `                 int indices[], MPI_Status statuses[])`  
> `int MPI_Probe(int source, int tag, MPI_Comm comm, MPI_Status *status)`

There are additional variants of the `MPI_Probe` that are not listed here. `MPI_Waitall` is shown in several examples in this chapter. The other routines are useful in more specialized situations. The name of the routines gives a good idea of the capabilities that these provide.

***8.3 Collective communication: A powerful component of MPI***

In this section, we’ll look at the rich set of collective communication calls in MPI. Collective communications operate on a group of processes contained in an MPI communicator. To operate on a partial set of processes, you can create your own MPI communicator for a subset of `MPI_COMM_WORLD` such as every other process. Then you can use your communicator in place of `MPI_COMM_WORLD` in collective communication calls. Most of the collective communication routines operate on data. Figure 8.4 gives a visual idea of what each collective operation does.

**Figure 8.4 The data movement of the most common MPI collective routines provide important functions for parallel programs. Additional variants** **`MPI_Scatterv`,** **`MPI_Gatherv`, and** **`MPI_Allgatherv`** **allow a variable amount of data to be sent or received from the processes. Not shown are some additional routines such as the** **`MPI_Alltoall`** **and similar functions.**

We’ll present examples of how to use the most commonly used collective operations as these might be applied in an application. The first example (in section 8.3.1) shows how you might use the barrier. It is the only collective routine that does not operate on data. Then we’ll show some examples with the broadcast (section 8.3.2), reduction (section 8.3.3), and finally, scatter/gather operations (sections 8.3.4 and 8.3.5). MPI also has a variety of all-to-all routines. But these are costly and rarely used, so we won’t cover those here. These collective operations all operate on a group of processes represented by a communication group. All members of a communication group must call the collective or your program will hang.

***8.3.1 Using a barrier to synchronize timers***

The simplest collective communication call is `MPI_Barrier`. It is used to synchronize all of the processes in an MPI communicator. In most programs, it should not be necessary, but it is often used for debugging and for synchronizing timers. Let’s look at how `MPI_Barrier` could be used to synchronize timers in the following listing. We also use the `MPI_Wtime` function to get the current time.

**Listing 8.9 Using** **`MPI_Barrier`** **to synchronize a timer in an MPI program**

> `SynchronizedTimer/SynchronizedTimer1.c`  
> `1 #include <mpi.h>`  
> `2 #include <unistd.h>`  
> `3 #include <stdio.h>`  
> `4 int main(int argc, char *argv[])`  
> `5 {`  
> `6    double start_time, main_time;`  
> `7`  
> `8    MPI_Init(&argc, &argv);`  
> `9    int rank;`  
> `10    MPI_Comm_rank(MPI_COMM_WORLD, &rank);`  
> `11   `  
> `12    MPI_Barrier(MPI_COMM_WORLD);                           `❶  
> `13    start_time = MPI_Wtime();                              `❷  
> `14`  
> `15    sleep(30);                                             `❸  
> `16`  
> `17    MPI_Barrier(MPI_COMM_WORLD);                           `❹  
> `18    main_time = MPI_Wtime() - start_time;                  `❺  
> `19    if (rank == 0) printf("Time for work is %lf seconds\n", main_time);`  
> `20`  
> `21    MPI_Finalize();`  
> `22    return 0;`  
> `23 }`

❶ Synchronizes all the processes so these start at about the same time

❷ Gets the starting value of the timer using the MPI_Wtime routine

❸ Represents work being done

❹ Synchronizes the processes to get the longest time taken

❺ Gets the timer value and subtracts the starting value to get the elapsed time

The barrier is inserted before starting the timer and then just before stopping the timer. This forces the timers on all of the processes to start at about the same time. By inserting the barrier before stopping the timer, we get the maximum time across all of the processes. Sometimes using a synchronized timer gives a less confusing measure of time, but in others, an unsynchronized timer is better.

> > > **NOTE** Synchronized timers and barriers should not be used in production runs; these can cause serious slowdowns in an application.

***8.3.2 Using the broadcast to handle small file input***

The broadcast sends data from one processor to all of the others. This operation is shown in figure 8.4 in the upper left. One of the uses of the broadcast, `MPI_Bcast`, is to send values read from an input file to all other processes. If every process tries to open a file at large process counts, it can take minutes to complete the file open. This is because file systems are inherently serial and one of the slower components of a computer system. For these reasons, for small file input, it is a good practice to only open and read a file from a single process. The following listing shows the way to do this.

**Listing 8.10 Using** **`MPI_Bcast`** **to handle small file input**

> `FileRead/FileRead.c`  
> `1 #include <stdio.h>`  
> `2 #include <string.h>`  
> `3 #include <stdlib.h>`  
> `4 #include <mpi.h>`  
> `5 int main(int argc, char *argv[])`  
> `6 {`  
> `7    int rank, input_size;`  
> `8    char *input_string, *line;`  
> `9    FILE *fin;`  
> `10`  
> `11    MPI_Init(&argc, &argv);`  
> `12    MPI_Comm_rank(MPI_COMM_WORLD, &rank);`  
> `13`  
> `14    if (rank == 0){`  
> `15       fin = fopen("file.in", "r");`  
> `16       fseek(fin, 0, SEEK_END);                                    `❶  
> `17       input_size = ftell(fin);                                    `❶  
> `18       fseek(fin, 0, SEEK_SET);                                    `❷  
> `19       input_string = (char *)malloc((input_size+1)*sizeof(char));`  
> `20       fread(input_string, 1, input_size, fin);                    `❸  
> `21       input_string[input_size] = '\0';                            `❹  
> `22    }`  
> `23`  
> `24    MPI_Bcast(&input_size, 1, MPI_INT, 0,                          `❺  
> `                MPI_COMM_WORLD);                                     `❺  
> `25    if (rank != 0)                                                 `❻  
> `         input_string =                                              `❻  
> `            (char *)malloc((input_size+1)*                           `❻  
> `                           sizeof(char));                            `❻  
> `26    MPI_Bcast(input_string, input_size,                            `❼  
> `                MPI_CHAR, 0, MPI_COMM_WORLD);                        `❼  
> `27`  
> `28    if (rank == 0) fclose(fin);`  
> `29`  
> `30    line = strtok(input_string,"\n");`  
> `31    while (line != NULL){`  
> `32       printf("%d:input string is %s\n",rank,line);`  
> `33       line = strtok(NULL,"\n");`  
> `34    }`  
> `35    free(input_string);`  
> `36`  
> `37    MPI_Finalize();`  
> `38    return 0;`  
> `39 }`

❶ Gets the file size to allocate an input buffer

❷ Resets the file pointer to the start of file

❸ Reads entire file

❹ Null terminating input buffer

❺ Broadcasts size of input buffer

❻ Allocates input buffer on other processes

❼ Broadcasts input buffer

It is better to broadcast larger chunks of data than it is to broadcast many small individual values. We therefore broadcast the entire file. To do this, we need to first broadcast the size so that every process can allocate an input buffer and then broadcast the data. The file read and broadcasts are done from rank 0, generally referred to as the main process.

`MPI_Bcast` takes a pointer for the first argument, so when sending a scalar variable, we send the reference by using the ampersand (&) operator to get the address of the variable. Then comes the count and the type to fully define the data to be sent. The next argument specifies the originating process. It is 0 in both of these calls because that is the rank where the data resides. All other processes in the `MPI_COMM_WORLD` communication then receive the data. This technique is for small input files. For larger file input or output, there are ways to conduct parallel file operations. The complex world of parallel input and output is discussed in chapter 16.

***8.3.3 Using a reduction to get a single value from across all processes***

The reduction pattern, discussed in section 5.7, is one of the most important parallel computing patterns. The reduction operation is shown in figure 8.4 in the upper middle. An example of the reduction in Fortran array syntax is `xsum` = `sum(x(:))`, where the Fortran `sum` intrinsic sums the `x` array and puts it in the scalar variable `xsum`. The MPI reduction calls take an array or multi-dimensional array and combine the values into a scalar result. There are many operations that can be done during the reduction. The most common are

- `MPI_MAX` (maximum value in an array)

- `MPI_MIN` (minimum value in an array)

- `MPI_SUM` (sum of an array)

- `MPI_MINLOC` (index of minimum value)

- `MPI_MAXLOC` (index of maximum value)

The following listing shows how we can use `MPI_Reduce` to get the minimum, maximum, and average of a variable from every process.

**Listing 8.11 Using reductions to get min, max, and avg timer results**

> `SynchronizedTimer/SynchronizedTimer2.c`  
> `1 #include <mpi.h>`  
> `2 #include <unistd.h>`  
> `3 #include <stdio.h>`  
> `4 int main(int argc, char *argv[])`  
> `5 {`  
> `6    double start_time, main_time, min_time, max_time, avg_time;`  
> `7`  
> `8    MPI_Init(&argc, &argv);`  
> `9    int rank, nprocs;`  
> `10    MPI_Comm_rank(MPI_COMM_WORLD, &rank);`  
> `11    MPI_Comm_size(MPI_COMM_WORLD, &nprocs);`  
> `12`  
> `13    MPI_Barrier(MPI_COMM_WORLD);                  `❶  
> `14    start_time = MPI_Wtime();                     `❶  
> `15`  
> `16    sleep(30);                                    `❷  
> `17`  
> `18    main_time = MPI_Wtime() - start_time;         `❸  
> `19    MPI_Reduce(&main_time, &max_time, 1,          `❹  
> `         MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);   `❹  
> `20    MPI_Reduce(&main_time, &min_time, 1,          `❹  
> `         MPI_DOUBLE, MPI_MIN, 0,MPI_COMM_WORLD);    `❹  
> `21    MPI_Reduce(&main_time, &avg_time, 1,          `❹  
> `         MPI_DOUBLE, MPI_SUM, 0,MPI_COMM_WORLD);    `❹  
> `22    if (rank == 0)`  
> `         printf("Time for work is Min: %lf  Max: %lf  Avg:  %lf seconds\n",`  
> `23              min_time, max_time, avg_time/nprocs);`  
> `24`  
> `25    MPI_Finalize();`  
> `26    return 0;`  
> `27 }`

❶ Synchronizes all the processes so these start at about the same time

❷ Represents work being done

❸ Gets the timer value and subtracts the starting value to get the elapsed time

❹ Uses reduction calls to compute the max, min, and average time

The reduction result, the maximum in this case, is stored on rank 0 (argument 6 in the `MPI_Reduce` call), which in this case is the main process. If we wanted to just print it out on the main process, this would be appropriate. But if we wanted all of the processes to have the value, we would use the `MPI_Allreduce` routine.

You can also define your own operator. We’ll use the example of the Kahan enhanced-precision summation we have been working with and first introduced in section 5.7. The challenge in a distributed memory parallel environment is to carry the Kahan summation across process ranks. We start by looking at the main program in the following listing before looking at two other parts of the program in listings 8.13 and 8.14.

**Listing 8.12 An MPI version of the Kahan summation**

> `GlobalSums/globalsums.c`  
> `57 int main(int argc, char *argv[])`  
> `58 {`  
> `59    MPI_Init(&argc, &argv);`  
> `60    int rank, nprocs;`  
> `61    MPI_Comm_rank(MPI_COMM_WORLD, &rank);`  
> `62    MPI_Comm_size(MPI_COMM_WORLD, &nprocs);`  
> `63`  
> `64    init_kahan_sum();                            `❶  
> `65`  
> `66    if (rank == 0) printf("MPI Kahan tests\n");`  
> `67`  
> `68    for (int pow_of_two = 8; pow_of_two < 31; pow_of_two++){`  
> `69       long ncells = (long)pow((double)2,(double)pow_of_two);`  
> `70`  
> `71       int nsize;`  
> `72       double accurate_sum;`  
> `73       double *local_energy =                    `❷  
> `           init_energy(ncells, &nsize,             `❷  
> `           &accurate_sum);                         `❷  
> `74`  
> `75       struct timespec cpu_timer;`  
> `76       cpu_timer_start(&cpu_timer);`  
> `77`  
> `78       double test_sum =                         `❸  
> `           global_kahan_sum(nsize, local_energy);  `❸  
> `79`  
> `80       double cpu_time = cpu_timer_stop(cpu_timer);`  
> `81`  
> `82       if (rank == 0){`  
> `83          double sum_diff = test_sum-accurate_sum;`  
> `84          printf("ncells %ld log %d acc sum %-17.16lg sum %-17.16lg ",`  
> `85                 ncells,(int)log2((double)ncells),accurate_sum,test_sum);`  
> `86          printf("diff %10.4lg relative diff %10.4lg runtime %lf\n",`  
> `87                 sum_diff,sum_diff/accurate_sum, cpu_time);`  
> `88       }`  
> `89      `  
> `90       free(local_energy);`  
> `91    }`  
> `92   `  
> `93    MPI_Type_free(&EPSUM_TWO_DOUBLES);           `❹  
> `94    MPI_Op_free(&KAHAN_SUM);                     `❹  
> `95    MPI_Finalize();`  
> `96    return 0;`  
> `97 }`

❶ Initializes the new MPI data type and creates a new operator

❷ Gets a distributed array to work with

❸ Calculates the Kahan summation of the energy array across all processes

❹ Frees the custom data type and operator

The `main` program shows that the new MPI data type is created once at the start of the program and freed at the end, before `MPI_Finalize`. The call to perform the global Kahan summation is done multiple times within the loop, where the data size is increased by powers of two. Now let’s look at the next listing to see what needs to be done to initialize the new data type and operator.

**Listing 8.13 Initializing new MPI data type and operator for Kahan summation**

> `GlobalSums/globalsums.c`  
> `14 struct esum_type{                                   `❶  
> `15    double sum;                                      `❶  
> `16    double correction;                               `❶  
> `17 };                                                  `❶  
> `18`  
> `19 MPI_Datatype EPSUM_TWO_DOUBLES;                     `❷  
> `20 MPI_Op KAHAN_SUM;                                   `❸  
> `21`  
> `22 void kahan_sum(struct esum_type * in,`  
> `                  struct esum_type * inout, int *len,`  
> `23     MPI_Datatype *EPSUM_TWO_DOUBLES)                `❹  
> `24 {`  
> `25    double corrected_next_term, new_sum;`  
> `26    corrected_next_term = in->sum + (in->correction + inout->correction);`  
> `27    new_sum = inout->sum + corrected_next_term;`  
> `28    inout->correction = corrected_next_term - (new_sum - inout->sum);`  
> `29    inout->sum = new_sum;`  
> `30 }`  
> `31`  
> `32 void init_kahan_sum(void){`  
> `33    MPI_Type_contiguous(2, MPI_DOUBLE,               `❺  
> `                          &EPSUM_TWO_DOUBLES);         `❺  
> `34    MPI_Type_commit(&EPSUM_TWO_DOUBLES);             `❺  
> `35`  
> `36    int commutative = 1;                             `❻  
> `37    MPI_Op_create((MPI_User_function *)kahan_sum,    `❻  
> `                    commutative, &KAHAN_SUM);          `❻  
> `38 }`

❶ Defines an esum_type structure to hold the sum and correction term

❷ Declares a new MPI data type composed of two doubles

❸ Declares a new Kahan summation operator

❹ Defines a function for the new operator using a predefined signature

❺ Creates the type and commits it

❻ Creates the new operator and commits it

We first create the new data type, `EPSUM_TWO_DOUBLES`, by combining two of the basic `MPI_DOUBLE` data type in line 33. We have to declare the type outside the routine at line 19 so that it is available to use by the summation routine. To create the new operator, we first write the function to use as the operator in lines 22-30. We then use `esum_type` to pass both double values in and back out. We also need to pass in the length and the data type that it will operate on as the new `EPSUM_TWO_DOUBLES` type.

In the process of creating a Kahan sum reduction operator, we showed you how to create a new MPI data type and a new MPI reduction operator. Now let’s move on to actually calculating the global sum of the array across MPI ranks as the following listing shows.

**Listing 8.14 Performing an MPI Kahan summation**

> `GlobalSums/globalsums.c`  
> `40 double global_kahan_sum(int nsize, double *local_energy){`  
> `41    struct esum_type local, global;`  
> `42    local.sum = 0.0;                                                   `❶  
> `43    local.correction = 0.0;                                            `❶  
> `44`  
> `45    for (long i = 0; i < nsize; i++) {                                 `❷  
> `46       double corrected_next_term =                                    `❷  
> `            local_energy[i] + local.correction;                          `❷  
> `47       double new_sum =                                                `❷  
> `            local.sum + local.correction;                                `❷  
> `48       local.correction = corrected_next_term -                        `❷  
> `                           (new_sum - local.sum);                        `❷  
> `49       local.sum = new_sum;                                            `❷  
> `50    }                                                                  `❷  
> `51`  
> `52    MPI_Allreduce(&local, &global, 1, EPSUM_TWO_DOUBLES, KAHAN_SUM,    `❸  
> `                    MPI_COMM_WORLD);`  
> `53`  
> `54    return global.sum;`  
> `55 }`

❶ Initializes both members of the esum_type to zero

❷ Performs the on-process Kahan summation

❸ Performs the reduction with the new KAHAN_SUM operator

Calculating the global Kahan summation is relatively easy now. We can do the local Kahan sum as shown in section 5.7. But we have to add `MPI_Allreduce` at line 52 to get the global result. Here, we defined the allreduce operation to end with the result on all processors as shown in figure 8.4 in the upper right.

***8.3.4 Using gather to put order in debug printouts***

A gather operation can be described as a collate operation, where data from all processors is brought together and stacked into a single array as shown in figure 8.4 in the lower center. You can use this collective communication call to bring order to the output to the console from your program. By now, you should have noticed that the output printed from multiple ranks of an MPI program comes out in random order, producing a jumbled, confusing mess. Let’s look at a better way to handle this so that the only output is from the main process. By printing the output from only the main process, the order will be correct. The next listing shows a sample program that gets data from all of the processes and prints it out in a nice, orderly output.

**Listing 8.15 Using a gather to print debug messages**

> `DebugPrintout/DebugPrintout.c`  
> `1 #include <stdio.h>`  
> `2 #include <time.h>`  
> `3 #include <unistd.h>`  
> `4 #include <mpi.h>`  
> `5 #include "timer.h"`  
> `6 int main(int argc, char *argv[])`  
> `7 {`  
> `8    int rank, nprocs;`  
> `9    double total_time;`  
> `10    struct timespec tstart_time;`  
> `11`  
> `12    MPI_Init(&argc, &argv);`  
> `13    MPI_Comm_rank(MPI_COMM_WORLD, &rank);`  
> `14    MPI_Comm_size(MPI_COMM_WORLD, &nprocs);`  
> `15`  
> `16    cpu_timer_start(&tstart_time);`  
> `17    sleep(30);                                    `❶  
> `18    total_time += cpu_timer_stop(tstart_time);`  
> `19`  
> `20    double times[nprocs];                         `❷  
> `21    MPI_Gather(&total_time, 1, MPI_DOUBLE,        `❸  
> `         times, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD);  `❸  
> `22    if (rank == 0) {                              `❹  
> `23       for (int i=0; i<nprocs; i++){              `❺  
> `24          printf("%d:Work took %lf secs\n",       `❻  
> `                   i, times[i]);                    `❻  
> `25       }`  
> `26    }`  
> `27`  
> `28    MPI_Finalize();`  
> `29    return 0;`  
> `30 }`

❶ Gets unique values on each process for our example

❷ Needs an array to collect all the times

❸ Uses a gather to bring all the values to process zero

❹ Only prints on the main process

❺ Loops over the processes for the print

❻ Prints the time for each process

`MPI_Gather` takes the standard triplet describing the data source. We need to use the ampersand to get the address of the scalar variable `total_time`. The destination is also a triplet with the destination array of `times`. An array is already an address, so no ampersand is needed. The gather is done to process 0 of the MPI world communication group. From there, it requires a loop to print the time for each process. We prepend every line with a number in the format \#: so that it is clear which process the output refers to.

***8.3.5 Using scatter and gather to send data out to processes for work***

The scatter operation, shown in figure 8.4 in the lower left, is the opposite of the gather operation. For this operation, the data is sent from one process to all the others in the communication group. The most common use for a scattering operation is in the parallel strategy distributing data arrays out to other processes for work. This is provided by the `MPI_Scatter` and `MPI_Scatterv` routines. The following listing shows the implementation.

**Listing 8.16 Using scatter to distribute data and gather to bring it back**

> `ScatterGather/ScatterGather.c`  
> `1 #include <stdio.h>`  
> `2 #include <stdlib.h>`  
> `3 #include <mpi.h>`  
> `4 int main(int argc, char *argv[])`  
> `5 {`  
> `6    int rank, nprocs, ncells = 100000;`  
> `7`  
> `8    MPI_Init(&argc, &argv);`  
> `9    MPI_Comm comm = MPI_COMM_WORLD;`  
> `10    MPI_Comm_rank(comm, &rank);`  
> `11    MPI_Comm_size(comm, &nprocs);`  
> `12`  
> `13    long ibegin = ncells *(rank  )/nprocs;         `❶  
> `14    long iend   = ncells *(rank+1)/nprocs;         `❶  
> `15    int  nsize  = (int)(iend-ibegin);              `❶  
> `16`  
> `17    double *a_global, *a_test;`  
> `18    if (rank == 0) {`  
> `19       a_global = (double *)                       `❷  
> `            malloc(ncells*sizeof(double));           `❷  
> `20       for (int i=0; i<ncells; i++) {              `❷  
> `21          a_global[i] = (double)i;                 `❷  
> `22       }                                           `❷  
> `23    }`  
> `24`  
> `25    int nsizes[nprocs], offsets[nprocs];           `❸  
> `26    MPI_Allgather(&nsize, 1, MPI_INT, nsizes,      `❸  
> `                    1, MPI_INT, comm);               `❸  
> `27    offsets[0] = 0;                                `❸  
> `28    for (int i = 1; i<nprocs; i++){                `❸  
> `29       offsets[i] = offsets[i-1] + nsizes[i-1];    `❸  
> `30    }                                              `❸  
> `31`  
> `32    double *a = (double *)                         `❹  
> `         malloc(nsize*sizeof(double));               `❹  
> `33    MPI_Scatterv(a_global, nsizes, offsets,        `❹  
> `34       MPI_DOUBLE, a, nsize, MPI_DOUBLE, 0, comm); `❹  
> `35`  
> `36    for (int i=0; i<nsize; i++){                   `❺  
> `37       a[i] += 1.0;                                `❺  
> `38    }                                              `❺  
> `39`  
> `40    if (rank == 0) {`  
> `41       a_test = (double *)                         `❻  
> `            malloc(ncells*sizeof(double));           `❻  
> `42    }`  
> `43`  
> `44    MPI_Gatherv(a, nsize, MPI_DOUBLE,              `❻  
> `45                a_test, nsizes, offsets,           `❻  
> `                  MPI_DOUBLE, 0, comm);              `❻  
> `46`  
> `47    if (rank == 0){`  
> `48       int ierror = 0;`  
> `49       for (int i=0; i<ncells; i++){`  
> `50          if (a_test[i] != a_global[i] + 1.0) {`  
> `51             printf("Error: index %d a_test %lf a_global %lf\n",`  
> `52                    i,a_test[i],a_global[i]);`  
> `53             ierror++;`  
> `54          }`  
> `55       }`  
> `56       printf("Report: Correct results %d errors %d\n",`  
> `                ncells-ierror,ierror);`  
> `57    }`  
> `58`  
> `59    free(a);`  
> `60    if (rank == 0) {`  
> `61       free(a_global);`  
> `62       free(a_test);`  
> `63    }`  
> `64`  
> `65    MPI_Finalize();`  
> `66    return 0;`  
> `67 }`

❶ Computes the size of the array on every process

❷ Sets up data on the main process

❸ Gets the sizes and offsets into global arrays for communication

❹ Distributes the data onto the other processes

❺ Does the computation

❻ Returns array data to the main process, perhaps for output

We first need to calculate the size of the data on each process. The desired distribution is to be as equal as possible. A simple way to calculate the size is shown in lines 13-15, using simple integer arithmetic. Now we need the global array, but we only need it on the main process. So we allocate and set it up on this process in lines 18-23. In order to distribute or gather the data, the sizes and offsets for all processes must be known. We see the typical calculation for this in lines 25-30. The actual scatter is done with an `MPI_Scatterv` on lines 32-34. The data source is described with the arguments `buffer`, `counts`, `offsets`, and the data type. The destination is handled with the standard triplet. Then the source rank that will send the data is specified as rank 0. Finally, the last argument is `comm`, the communication group that will receive the data.

`MPI_Gatherv` does the opposite operation, as shown in figure 8.4. We only need the global array on the main process, and so it is only allocated there on lines 40-42. The arguments to `MPI_Gatherv` start with the description of the source with the standard triplet. Then the destination is described with the same four arguments as were used in the scatter. The destination rank is the next argument, followed by the communication group.

It should be noted that the sizes and offsets used in the `MPI_Gatherv` call are all of integer type. This limits the size of the data that can be handled. There was an attempt to change the data type to the long data type so larger data sizes could be handled in version 3 of the MPI standard. It was not approved because it would break too many applications. Stay tuned for the addition of new calls that provide support for a long integer type in one of the next MPI standards.

***8.4 Data parallel examples***

The data parallel strategy, defined in section 1.5, is the most common approach in parallel applications. We’ll look at a few examples of this approach in this section. First, we’ll look at a simple case of the stream triad where no communication is necessary. Then we’ll look at the more typical ghost cell exchange techniques used to link together the subdivided domains distributed to each process.

***8.4.1 Stream triad to measure bandwidth on the node***

The STREAM Triad is a bandwidth testing benchmark code introduced in section 3.2.4. This version uses MPI to get more processes working on the node and, possibly, on multiple nodes. The purpose of having more processes is to see what the maximum bandwidth is for the node when all processors are used. This gives a target bandwidth to aim for with more complicated applications. As listing 8.17 shows, the code is simple because no communication between ranks is required. The timing is only reported on the main process. You can run this first on one processor and then on all the processors on your node. Do you get the full parallel speedup that you would expect from the increase in processors? How much does the system memory bandwidth limit your speedup?

**Listing 8.17 The MPI version of the STREAM Triad**

> `StreamTriad/StreamTriad.c`  
> `  1 #include <stdio.h>`  
> `  2 #include <stdlib.h>`  
> `  3 #include <time.h>`  
> `  4 #include <mpi.h>`  
> `  5 #include "timer.h"`  
> `  6`  
> `  7 #define NTIMES 16`  
> `  8 #define STREAM_ARRAY_SIZE 80000000        `❶  
> `  9`  
> `10 int main(int argc, char *argv[]){`  
> `11`  
> `12    MPI_Init(&argc, &argv);`  
> `13`  
> `14    int nprocs, rank;`  
> `15    MPI_Comm_size(MPI_COMM_WORLD, &nprocs);`  
> `16    MPI_Comm_rank(MPI_COMM_WORLD, &rank);`  
> `17    int ibegin = STREAM_ARRAY_SIZE *(rank  )/nprocs;`  
> `18    int iend   = STREAM_ARRAY_SIZE *(rank+1)/nprocs;`  
> `19    int nsize = iend-ibegin;`  
> `20    double *a = malloc(nsize * sizeof(double));`  
> `21    double *b = malloc(nsize * sizeof(double));`  
> `22    double *c = malloc(nsize * sizeof(double));`  
> `23`  
> `24    struct timespec tstart;`  
> `25    double scalar = 3.0, time_sum = 0.0;   `❷  
> `26    for (int i=0; i<nsize; i++) {          `❷  
> `27       a[i] = 1.0;                         `❷  
> `28       b[i] = 2.0;                         `❷  
> `29    }                                      `❷  
> `30`  
> `31    for (int k=0; k<NTIMES; k++){`  
> `32       cpu_timer_start(&tstart);`  
> `33       for (int i=0; i<nsize; i++){        `❸  
> `34          c[i] = a[i] + scalar*b[i];       `❸  
> `35       }                                   `❸  
> `36       time_sum += cpu_timer_stop(tstart);`  
> `37       c[1]=c[2];                          `❹  
> `38    }`  
> `39`  
> `40    free(a);`  
> `41    free(b);`  
> `42    free(c);`  
> `43`  
> `44    if (rank == 0)`  
> `          printf("Average runtime is %lf msecs\n", time_sum/NTIMES);`  
> `45    MPI_Finalize();`  
> `46    return(0);`  
> `47 }`

❶ Large enough to force into main memory

❷ Initializes data and arrays

❸ The stream triad loop

❹ Keeps the compiler from optimizing out the loop

***8.4.2 Ghost cell exchanges in a two-dimensional (2D) mesh***

Ghost cells are the mechanism that we use to link the meshes on adjacent processors. These are used to cache values from adjacent processors so that fewer communications are needed. The ghost cell technique is the single most important method for enabling distributed memory parallelism in MPI.

Let’s talk a little bit about the terminology of halos and ghost cells. Even before the age of parallel processing, a region of cells surrounding the mesh was often used to implement boundary conditions. These boundary conditions could be reflective, inflow, outflow, or periodic. For efficiency, programmers wanted to avoid `if` statements in the main computational loop. To do this, they added cells surrounding the mesh and set those to appropriate values before the main computational loop. These cells had the appearance of a halo, so the name stuck. Halo cells are any set of cells surrounding a computational mesh regardless of their purpose. A domain-boundary halo is then halo cells used for imposing a specific set of boundary conditions.

Once applications were parallelized, a similar outer region of cells was added to hold values from the neighboring meshes. These cells are not real cells but only exist as an aid to reduce communication costs. Because these are not real, these were soon given the name ghost cells. The real data for a ghost cell is on the adjacent processor and the local copy is just a ghost value. The ghost cells also look like halos and are also referred to as halo cells. Ghost cell updates or exchanges refer to the updating of the ghost cells and are only needed for parallel, multi-process runs when you need updates of real values from adjacent processes.

The boundary conditions need to be done for both serial and parallel runs. Confusion exists because these operations are often referred to as halo updates, although it’s unclear exactly what is meant. In our terminology, halo updates refers to both the domain boundary updates and ghost cell updates. For optimizing MPI communication, we only need to look at the ghost cell updates or exchanges and put aside the boundary conditions calculations for the present.

Let’s now look at how to set up ghost cells for the borders of the local mesh on each process and perform the communication between the subdomains. By using ghost cells, the needed communications are grouped into a fewer number of communications than if a single communication is done every time a cell’s value is needed from another process. This is the most common technique to make the data parallel approach perform well. In the implementations of the ghost cell updates, we’ll demonstrate the use of the `MPI_Pack` routine and load a communication buffer with a simple cell-by-cell array assignment. In later sections, we’ll also see how to do the same communication with MPI data types, using the MPI topology calls for setup and communication.

Once we implement the ghost cell updates in a data parallel code, most of the needed communication is handled. This isolates the code that provides the parallelism into a small section of the application. This small section of the code is important to optimize for parallel efficiency. Let’s look at some implementations of this functionality, starting with the setup in listing 8.18 and the work done by the stencil loops in listing 8.19. You may want to look at the full code in the GhostExchange/GhostExchange_Pack directory of the example code for the chapter at [https://github.com/ EssentialsOfParallelComputing/Chapter8](https://github.com/EssentialsOfParallelComputing/Chapter8).

**Listing 8.18 Setup for ghost cell exchanges in a 2D mesh**

> `GhostExchange/GhostExchange_Pack/GhostExchange.cc`  
> `30    int imax = 2000, jmax = 2000;                `❶  
> `31    int nprocx = 0, nprocy = 0;                  `❷  
> `32    int nhalo = 2, corners = 0;                  `❸  
> `33    int do_timing;                               `❹  
> `      ....`  
> `40    int xcoord = rank%nprocx;                    `❺  
> `41    int ycoord = rank/nprocx;                    `❺  
> `42`  
> `43    int nleft = (xcoord > 0       ) ?            `❻  
> `                  rank - 1      : MPI_PROC_NULL;   `❻  
> `44    int nrght = (xcoord < nprocx-1) ?            `❻  
> `                  rank + 1      : MPI_PROC_NULL;   `❻  
> `45    int nbot  = (ycoord > 0       ) ?            `❻  
> `                  rank - nprocx : MPI_PROC_NULL;   `❻  
> `46    int ntop  = (ycoord < nprocy-1) ?            `❻  
> `                  rank + nprocx : MPI_PROC_NULL;   `❻  
> `47`  
> `48    int ibegin = imax *(xcoord  )/nprocx;        `❼  
> `49    int iend   = imax *(xcoord+1)/nprocx;        `❼  
> `50    int isize  = iend - ibegin;                  `❼  
> `51    int jbegin = jmax *(ycoord  )/nprocy;        `❼  
> `52    int jend   = jmax *(ycoord+1)/nprocy;        `❼  
> `53    int jsize  = jend - jbegin;                  `❼

❶ Input settings: -i \<imax\> -j \<jmax\> are the sizes of the grid.

❷ -x \<nprocx\> -y \<nprocy\> are the number of processes in x- and y-directions.

❸ -h \<nhalo\> -c is the number of halo cells and -c includes corner cells.

❹ -t do_timing synchronizes timing.

❺ xcoord and ycoord of processes. Row index varies fastest.

❻ Neighbor rank for each process for neighbor communication

❼ Size of computational domain for each process and the global begin and end index

We do memory allocation for the local size plus room for the halos on each process. To make the indexing a little simpler, we offset the memory indexing to start at `-nhalo` and end at `isize+nhalo`. The real cells then are always from 0 to `isize-1`, regardless of the width of the halo.

The following lines show a call to a special `malloc2D` with two additional arguments that offset the array addressing so that the real part of the array is from `0,0` to `jsize,isize`. This is done with some pointer arithmetic that moves the starting location of each pointer.

> `64    double** x    = malloc2D(jsize+2*nhalo, isize+2*nhalo, nhalo, nhalo);`  
> `65    double** xnew = malloc2D(jsize+2*nhalo, isize+2*nhalo, nhalo, nhalo);`

We use the simple stencil calculation from the blur operator introduced in figure 1.10 to provide the work. Many applications have far more complex computations that take much more time. The following listing shows the stencil calculation loops.

**Listing 8.19 Work is done in a stencil iteration loop**

> `GhostExchange/GhostExchange_Pack/GhostExchange.cc`  
> `91   for (int iter = 0; iter < 1000; iter++){       `❶  
> `92      cpu_timer_start(&tstart_stencil);`  
> `93`  
> `94      for (int j = 0; j < jsize; j++){            `❷  
> `95         for (int i = 0; i < isize; i++){         `❷  
> `96           xnew[j][i]=                            `❷  
> `                (x[j][i] + x[j][i-1] + x[j][i+1] +   `❷  
> `                 x[j-1][i] + x[j+1][i])/5.0;         `❷  
> `97         }                                        `❷  
> `98      }                                           `❷  
> `99`  
> `100      SWAP_PTR(xnew, x, xtmp);                    `❸  
> `101`  
> `102      stencil_time += cpu_timer_stop(tstart_stencil);`  
> `103`  
> `104      boundarycondition_update(x, nhalo, jsize,`  
> `          isize, nleft, nrght, nbot, ntop);`  
> `105      ghostcell_update(x, nhalo, corners,         `❹  
> `          jsize, isize, nleft, nrght, nbot, ntop);   `❹  
> `106   }                                              `❶

❶ Iteration loop

❷ Stencil calculation

❸ Pointer swap for old and new x arrays

❹ Ghost cell update call refreshes ghost cells.

Now we can look at the critical ghost cell update code. Figure 8.5 shows the required operation. The width of the ghost cell region can be one, two, or more cells in depth. The corner cells may also be needed for some applications. Four processes (or ranks) each need data from this rank; to the left, right, top, and bottom. Each of these processes requires a separate communication and a separate data buffer. The width of the halo region varies in different applications, as well as whether the corner cells are needed.

Figure 8.5 shows an example of a ghost cell exchange for a 4-by-4 mesh on nine processes with a one-cell-wide halo and the corners included. The outer boundary halos are updated first and then a horizontal data exchange, a synchronization, and the vertical data exchange. If corners are not needed, the horizontal and vertical exchanges can be done at the same time. If the corners are desired, a synchronization is necessary between the horizontal and vertical exchanges.

**Figure 8.5 The corner cell version of the ghost cell update first exchanges data to the left and right (on the top half of the figure), followed by a top and bottom exchange (on the bottom half of the figure). With care, the left and right exchange can be smaller with just the real cells plus the outer boundary cells, although there is no harm in making it the full vertical size of the mesh. The updating of the boundary cells surrounding the mesh is done separately.**

A key observation of the ghost cell data updates is that in C, the row data is contiguous, whereas the column data is separated by a stride that is the size of the row. Sending individual values for the columns is expensive and so we need to group these together somehow.

You can perform the ghost cell update with MPI in several ways. In this first version in listing 8.20, we’ll look at an implementation using the `MPI_Pack` call to pack the column data. The row data is sent with just a standard `MPI_Isend` call. The width of the ghost cell region is specified by the `nhalo` variable, and corners can be requested with the proper input.

**Listing 8.20 Ghost cell update routine for 2D mesh with** **`MPI_Pack`**

> `GhostExchange/GhostExchange_Pack/GhostExchange.cc`  
> `167 void ghostcell_update(double **x, int nhalo,     `❶  
> `       int corners, int jsize, int isize,            `❶  
> `168    int nleft, int nrght, int nbot, int ntop,     `❶  
> `       int do_timing)                                `❶  
> `169 {`  
> `170    if (do_timing) MPI_Barrier(MPI_COMM_WORLD);`  
> `171`  
> `172    struct timespec tstart_ghostcell;`  
> `173    cpu_timer_start(&tstart_ghostcell);`  
> `174`  
> `175    MPI_Request request[4*nhalo];`  
> `176    MPI_Status status[4*nhalo];`  
> `177`  
> `178    int jlow=0, jhgh=jsize;`  
> `179    if (corners) {`  
> `180       if (nbot == MPI_PROC_NULL) jlow = -nhalo;`  
> `181       if (ntop == MPI_PROC_NULL) jhgh = jsize+nhalo;`  
> `182    }`  
> `183    int jnum = jhgh-jlow;`  
> `184    int bufcount = jnum*nhalo;`  
> `185    int bufsize = bufcount*sizeof(double);`  
> `186`  
> `187    double xbuf_left_send[bufcount];`  
> `188    double xbuf_rght_send[bufcount];`  
> `189    double xbuf_rght_recv[bufcount];`  
> `190    double xbuf_left_recv[bufcount];`  
> `191`  
>   
> `192    int position_left;                            `❷  
> `193    int position_right;                           `❷  
> `194    if (nleft != MPI_PROC_NULL){                  `❷  
> `195       position_left = 0;                         `❷  
> `196       for (int j = jlow; j < jhgh; j++){         `❷  
> `197         MPI_Pack(&x[j][0], nhalo, MPI_DOUBLE,    `❷  
> `198           xbuf_left_send, bufsize,               `❷  
> `              &position_left,  MPI_COMM_WORLD);      `❷  
> `199       }                                          `❷  
> `200    }                                             `❷  
> `201`  
> `202    if (nrght != MPI_PROC_NULL){                  `❷  
> `203       position_right = 0;                        `❷  
> `204       for (int j = jlow; j < jhgh; j++){         `❷  
> `205         MPI_Pack(&x[j][isize-nhalo], nhalo,      `❷  
> `              MPI_DOUBLE, xbuf_rght_send,            `❷  
> `206           bufsize, &position_right,              `❷  
> `              MPI_COMM_WORLD);                       `❷  
> `207       }                                          `❷  
> `208    }                                             `❷  
> `209`  
> `210    MPI_Irecv(&xbuf_rght_recv, bufsize,           `❸  
> `                 MPI_PACKED, nrght, 1001,            `❸  
> `211              MPI_COMM_WORLD, &request[0]);       `❸  
> `212    MPI_Isend(&xbuf_left_send, bufsize,           `❸  
> `                 MPI_PACKED, nleft, 1001,            `❸  
> `213              MPI_COMM_WORLD, &request[1]);       `❸  
> `214`  
> `215    MPI_Irecv(&xbuf_left_recv, bufsize,           `❸  
> `                 MPI_PACKED, nleft, 1002,            `❸  
> `216              MPI_COMM_WORLD, &request[2]);       `❸  
> `217    MPI_Isend(&xbuf_rght_send, bufsize,           `❸  
> `                 MPI_PACKED, nrght, 1002,            `❸  
> `218              MPI_COMM_WORLD, &request[3]);       `❸  
> `219    MPI_Waitall(4, request, status);              `❸  
> `220`  
> `221    if (nrght != MPI_PROC_NULL){                  `❹  
> `222       position_right = 0;                        `❹  
> `223       for (int j = jlow; j < jhgh; j++){         `❹  
> `224         MPI_Unpack(xbuf_rght_recv, bufsize,      `❹  
> `              &position_right, &x[j][isize],         `❹  
> `225           nhalo, MPI_DOUBLE, MPI_COMM_WORLD);    `❹  
> `226       }                                          `❹  
> `227    }                                             `❹  
> `228`  
> `229    if (nleft != MPI_PROC_NULL){                  `❹  
> `230       position_left = 0;                         `❹  
> `231       for (int j = jlow; j < jhgh; j++){         `❹  
> `232         MPI_Unpack(xbuf_left_recv, bufsize,      `❹  
> `              &position_left,  &x[j][-nhalo],        `❹  
> `233           nhalo, MPI_DOUBLE, MPI_COMM_WORLD);    `❹  
> `234       }                                          `❹  
> `235    }                                             `❹  
> `236`  
> `237    if (corners) {`  
> `238       bufcount = nhalo*(isize+2*nhalo);`  
> `239       MPI_Irecv(&x[jsize][-nhalo],               `❺  
> `             bufcount, MPI_DOUBLE, ntop, 1001,       `❺  
> `240          MPI_COMM_WORLD, &request[0]);           `❺  
> `241       MPI_Isend(&x[0    ][-nhalo],               `❺  
> `             bufcount, MPI_DOUBLE, nbot, 1001,       `❺  
> `242            MPI_COMM_WORLD, &request[1]);         `❺  
> `243`  
> `244       MPI_Irecv(&x[     -nhalo][-nhalo],         `❺  
> `             bufcount, MPI_DOUBLE, nbot, 1002,       `❺  
> `245          MPI_COMM_WORLD, &request[2]);           `❺  
> `246       MPI_Isend(&x[jsize-nhalo][-nhalo],         `❺  
> `             bufcount, MPI_DOUBLE,ntop, 1002,        `❺  
> `247          MPI_COMM_WORLD, &request[3]);           `❺  
> `248       MPI_Waitall(4, request, status);           `❻  
> `249    } else {`  
> `250       for (int j = 0; j<nhalo; j++){             `❼  
> `251          MPI_Irecv(&x[jsize+j][0],               `❼  
> `               isize, MPI_DOUBLE, ntop, 1001+j*2,    `❼  
> `252            MPI_COMM_WORLD, &request[0+j*4]);     `❼  
> `253          MPI_Isend(&x[0+j    ][0],               `❼  
> `               isize, MPI_DOUBLE, nbot, 1001+j*2,    `❼  
> `254            MPI_COMM_WORLD, &request[1+j*4]);     `❼  
> `255`  
> `256          MPI_Irecv(&x[     -nhalo+j][0],         `❼  
> `               isize, MPI_DOUBLE, nbot, 1002+j*2,    `❼  
> `257            MPI_COMM_WORLD, &request[2+j*4]);     `❼  
> `258          MPI_Isend(&x[jsize-nhalo+j][0],         `❼  
> `               isize, MPI_DOUBLE, ntop, 1002+j*2,    `❼  
> `259            MPI_COMM_WORLD, &request[3+j*4]);     `❼  
> `260       }                                          `❼  
> `261       MPI_Waitall(4*nhalo, request, status);     `❽  
> `262    }`  
> `263`  
> `264    if (do_timing) MPI_Barrier(MPI_COMM_WORLD);`  
> `265`  
> `266    ghostcell_time += cpu_timer_stop(tstart_ghostcell);`  
> `267 }`

❶ The update of the ghost cells from adjacent processes

❷ Packs buffers for ghost cell update for left and right neighbors

❸ Communication for left and right neighbors

❹ Unpacks buffers for left and right neighbors

❺ Ghost cell updates in one contiguous block for bottom and top neighbors

❻ Waits for all communication to complete

❼ Ghost cell updates one row at a time for bottom and top neighbors

❽ Waits for all communication to complete

The `MPI_Pack` call is particularly useful when there are multiple data types that need to be communicated in the ghost update. The values are packed into a type-agnostic buffer and then unpacked on the other side. The neighbor communication in the vertical direction is done with contiguous row data. When there are corners included, a single buffer works well. Without corners, individual halo rows are sent. There are usually only one or two halo cells, so this is a reasonable approach.

Another way to load the buffers for the communication is with an array assignment. Array assignments are a good approach when there is a single, simple data type like the double-precision float type used in this example. The following listing shows the code for replacing the `MPI_Pack` loops with array assignments.

**Listing 8.21 Ghost cell update routine for 2D mesh with array assignments**

> `GhostExchange/GhostExchange_ArrayAssign/GhostExchange.cc`  
> `190    int icount;`  
> `191    if (nleft != MPI_PROC_NULL){                     `❶  
> `192       icount = 0;                                   `❶  
> `193       for (int j = jlow; j < jhgh; j++){            `❶  
> `194          for (int ll = 0; ll < nhalo; ll++){        `❶  
> `195             xbuf_left_send[icount++] = x[j][ll];    `❶  
> `196          }                                          `❶  
> `197       }                                             `❶  
> `198    }                                                `❶  
> `199    if (nrght != MPI_PROC_NULL){                     `❶  
> `200       icount = 0;                                   `❶  
> `201       for (int j = jlow; j < jhgh; j++){            `❶  
> `202          for (int ll = 0; ll < nhalo; ll++){        `❶  
> `203             xbuf_rght_send[icount++] =              `❶  
> `                   x[j][isize-nhalo+ll];                `❶  
> `204          }                                          `❶  
> `205       }                                             `❶  
> `206    }                                                `❶  
> `207`  
> `208    MPI_Irecv(&xbuf_rght_recv, bufcount,             `❷  
> `                 MPI_DOUBLE, nrght, 1001,               `❷  
> `209              MPI_COMM_WORLD, &request[0]);          `❷  
> `210    MPI_Isend(&xbuf_left_send, bufcount,             `❷  
> `                 MPI_DOUBLE, nleft, 1001,               `❷  
> `211              MPI_COMM_WORLD, &request[1]);          `❷  
> `212   `  
> `213    MPI_Irecv(&xbuf_left_recv, bufcount,             `❷  
> `                 MPI_DOUBLE, nleft, 1002,               `❷  
> `214              MPI_COMM_WORLD, &request[2]);          `❷  
> `215    MPI_Isend(&xbuf_rght_send, bufcount,             `❷  
> `                 MPI_DOUBLE, nrght, 1002,               `❷  
> `216              MPI_COMM_WORLD, &request[3]);          `❷  
> `217    MPI_Waitall(4, request, status);                 `❷  
> `218   `  
> `219    if (nrght != MPI_PROC_NULL){                     `❸  
> `220       icount = 0;                                   `❸  
> `221       for (int j = jlow; j < jhgh; j++){            `❸  
> `222          for (int ll = 0; ll < nhalo; ll++){        `❸  
> `223             x[j][isize+ll] =                        `❸  
> `                   xbuf_rght_recv[icount++];            `❸  
> `224          }                                          `❸  
> `225       }                                             `❸  
> `226    }                                                `❸  
> `227    if (nleft != MPI_PROC_NULL){                     `❸  
> `228       icount = 0;                                   `❸  
> `229       for (int j = jlow; j < jhgh; j++){            `❸  
> `230          for (int ll = 0; ll < nhalo; ll++){        `❸  
> `231             x[j][-nhalo+ll] =                       `❸  
> `                   xbuf_left_recv[icount++];            `❸  
> `232          }                                          `❸  
> `233       }                                             `❸  
> `234    }                                                `❸

❶ Fills the send buffers

❷ Performs the communication between left and right neighbors

❸ Copies the receive buffers into the ghost cells

The `MPI_Irecv` and `MPI_Isend` calls now use a count and the `MPI_DOUBLE` data type rather than the generic byte type of `MPI_Pack`. We also need to know the data type for copying data into and out of the communication buffer.

***8.4.3 Ghost cell exchanges in a three-dimensional (3D) stencil calculation***

You can also do a ghost cell exchange for a 3D stencil calculation. We’ll do that in listing 8.22. The setup is a little more complicated, however. The process layout is first calculated as `xcoord`, `ycoord`, and `zcoord` values. Then the neighbors are determined, and the sizes of the data on each processor calculated.

**Listing 8.22 Setup for a 3D mesh**

> `GhostExchange/GhostExchange3D_*/GhostExchange.cc`  
> `63    int xcoord = rank%nprocx;                     `❶  
> `64    int ycoord = rank/nprocx%nprocy;              `❶  
> `65    int zcoord = rank/(nprocx*nprocy);            `❶  
> `66`  
> `67    int nleft = (xcoord > 0       ) ?             `❷  
> `          rank - 1      : MPI_PROC_NULL;             `❷  
> `68    int nrght = (xcoord < nprocx-1) ?             `❷  
> `          rank + 1      : MPI_PROC_NULL;             `❷  
> `69    int nbot  = (ycoord > 0       ) ?             `❷  
> `          rank - nprocx : MPI_PROC_NULL;             `❷  
> `70    int ntop  = (ycoord < nprocy-1) ?             `❷  
> `          rank + nprocx : MPI_PROC_NULL;             `❷  
> `71    int nfrnt = (zcoord > 0       ) ?             `❷  
> `          rank - nprocx * nprocy : MPI_PROC_NULL;    `❷  
> `72    int nback = (zcoord < nprocz-1) ?             `❷  
> `          rank + nprocx * nprocy : MPI_PROC_NULL;    `❷  
> `73`  
> `74    int ibegin = imax *(xcoord  )/nprocx;         `❸  
> `75    int iend   = imax *(xcoord+1)/nprocx;         `❸  
> `76    int isize  = iend - ibegin;                   `❸  
> `77    int jbegin = jmax *(ycoord  )/nprocy;         `❸  
> `78    int jend   = jmax *(ycoord+1)/nprocy;         `❸  
> `79    int jsize  = jend - jbegin;                   `❸  
> `80    int kbegin = kmax *(zcoord  )/nprocz;         `❸  
> `81    int kend   = kmax *(zcoord+1)/nprocz;         `❸  
> `82    int ksize  = kend - kbegin;                   `❸

❶ Sets up the process coordinates

❷ Calculates the neighbor processes for each process

❸ Calculates the beginning and ending index for each process and then the size

The ghost cell update, including the array copies into buffers, communication, and copying out is a couple of hundred lines long and can’t be shown here. Refer to the code examples (<https://github.com/EssentialsofParallelComputing/Chapter8>) that accompany the chapter for the detailed implementation. We’ll show an MPI data type version of the ghost cell update in section 8.5.1.

***8.5 Advanced MPI functionality to simplify code and enable optimizations***

The excellent design of MPI becomes apparent as we see how basic MPI components can be combined into higher-level functionality. We got a taste of this in section 8.3.3, when we created a new double-double type and a new reduction operator. This extensibility gives MPI important capabilities. We’ll look at a couple of these advanced functions that are useful in common data parallel applications. These include

- MPI custom data types—Builds new data types from the basic MPI type building blocks.

- Topology support—A basic Cartesian regular grid topology and a more general graph topology are both available. We’ll just look at the simpler MPI Cartesian functions.

***8.5.1 Using custom MPI data types for performance and code simplification***

MPI has a rich set of functions to create new, custom MPI data types from the basic MPI types. This allows the encapsulation of complex data into a single custom data type that you can use in communication calls. As a result, a single communication call can send or receive many smaller pieces of data as a unit. Here is a list of some of the MPI data type creation functions:

- `MPI_Type_contiguous`—Makes a block of contiguous data into a type.

- `MPI_Type_vector`—Creates a type out of blocks of strided data.

- `MPI_Type_create_subarray`—Creates a rectangular subset of a larger array.

- `MPI_Type_indexed` or `MPI_Type_create_hindexed`—Creates an irregular set of indices described by a set of block lengths and displacements. The `hindexed` version expresses the displacements in bytes instead of a data type for more generality.

- `MPI_Type_create_struct`—Creates a data type encapsulating the data items in a structure in a portable way that accounts for padding by the compiler.

You’ll find a visual illustration to be helpful in understanding some of these data types. Figure 8.6 shows some of the simpler and more commonly used functions including `MPI_Type_` `contiguous`, `MPI_Type_vector`, and `MPI_Type_create_subarray`.

**Figure 8.6 Three MPI custom data types with illustrations of the arguments used in their creation**

Once a data type is described and made into a new data type, it must be initialized before it is used. For this purpose, there are a couple of additional routines to commit and free the types. A type must be committed before use and it must be freed to avoid a memory leak. The routines include

- `MPI_Type_Commit`—Initializes the new custom type with needed memory allocation or other setup

- `MPI_Type_Free`—Frees any memory or data structure entries from the creation of the data type

We can greatly simplify the ghost cell communication by defining a custom MPI data type as was shown in figure 8.6 to represent the column of data and to avoid the `MPI_Pack` calls. By defining an MPI data type, an extra data copy can be avoided. The data can be copied from its regular location straight into the MPI send buffers. Let’s see how this is done in listing 8.23. Listing 8.24 shows the second part of the program.

We first set up the custom data types. We use the `MPI_Type_vector` call for sets of strided array accesses. For the contiguous data for the vertical type when we include corners, we use the `MPI_Type_contiguous` call, and in lines 139 and 140, we free the data type at the end before the `MPI_Finalize`.

**Listing 8.23 Creating a 2D vector data type for the ghost cell update**

> `GhostExchange/GhostExchange_VectorTypes/GhostExchange.cc`  
> `56    int jlow=0, jhgh=jsize;`  
> `57    if (corners) {`  
> `58       if (nbot == MPI_PROC_NULL) jlow = -nhalo;`  
> `59       if (ntop  == MPI_PROC_NULL) jhgh = jsize+nhalo;`  
> `60    } `  
> `61    int jnum = jhgh-jlow;`  
> `62`  
> `63    MPI_Datatype horiz_type;`  
> `64    MPI_Type_vector(jnum, nhalo, isize+2*nhalo,`  
> `                       MPI_DOUBLE, &horiz_type);`  
> `65    MPI_Type_commit(&horiz_type);`  
> `66`  
> `67    MPI_Datatype vert_type;`  
> `68    if (! corners){`  
> `69       MPI_Type_vector(nhalo, isize, isize+2*nhalo,`  
> `                          MPI_DOUBLE, &vert_type);`  
> `70    } else {`  
> `71       MPI_Type_contiguous(nhalo*(isize+2*nhalo),`  
> `                              MPI_DOUBLE, &vert_type);`  
> `72    }`  
> `73    MPI_Type_commit(&vert_type);`  
> `...`  
> `139    MPI_Type_free(&horiz_type);`  
> `140    MPI_Type_free(&vert_type);`

You can then write the `ghostcell_update` more concisely and with better performance using the MPI data types as in the following listing. If we need to update corners, a synchronization is needed between the two communication passes.

**Listing 8.24 2D ghost cell update routine using the vector data type**

> `GhostExchange/GhostExchange_VectorTypes/GhostExchange.cc`  
> `197    int jlow=0, jhgh=jsize, ilow=0, waitcount=8, ib=4;`  
> `198    if (corners) {`  
> `199       if (nbot == MPI_PROC_NULL) jlow = -nhalo;`  
> `200       ilow = -nhalo;`  
> `201       waitcount = 4;`  
> `202       ib = 0;`  
> `203    }`  
> `204`  
> `205    MPI_Request request[waitcount];`  
> `206    MPI_Status status[waitcount];`  
> `207`  
> `208    MPI_Irecv(&x[jlow][isize], 1,        `❶  
> `          horiz_type, nrght, 1001,          `❶  
> `209       MPI_COMM_WORLD, &request[0]);     `❶  
> `210    MPI_Isend(&x[jlow][0],     1,        `❶  
> `          horiz_type, nleft, 1001,          `❶  
> `211       MPI_COMM_WORLD, &request[1]);     `❶  
> `212`  
> `213    MPI_Irecv(&x[jlow][-nhalo],      1,  `❶  
> `          horiz_type, nleft, 1002,          `❶  
> `214       MPI_COMM_WORLD, &request[2]);     `❶  
> `215    MPI_Isend(&x[jlow][isize-nhalo], 1,  `❶  
> `          horiz_type, nrght, 1002,          `❶  
> `216       MPI_COMM_WORLD, &request[3]);     `❶  
> `217`  
> `218    if (corners)                         `❷  
> `          MPI_Waitall(4, request, status);  `❷  
> `219`  
> `220    MPI_Irecv(&x[jsize][ilow],   1,      `❸  
> `          vert_type, ntop, 1003,            `❸  
> `221       MPI_COMM_WORLD, &request[ib+0]);  `❸  
> `222    MPI_Isend(&x[0    ][ilow],   1,      `❸  
> `          vert_type, nbot, 1003,            `❸  
> `223       MPI_COMM_WORLD, &request[ib+1]);  `❸  
> `224`  
> `225    MPI_Irecv(&x[     -nhalo][ilow], 1,  `❸  
> `          vert_type, nbot, 1004,            `❸  
> `226       MPI_COMM_WORLD, &request[ib+2]);  `❸  
> `227    MPI_Isend(&x[jsize-nhalo][ilow], 1,  `❸  
> `          vert_type, ntop, 1004,            `❸  
> `228       MPI_COMM_WORLD, &request[ib+3]);  `❸  
> `229`  
> `230    MPI_Waitall(waitcount, request, status);`

❶ Send left and right using the custom horiz_type MPI data type

❷ Synchronize if corners are sent.

❸ Updates ghost cells on top and bottom

The reason for using MPI data types is usually given as better performance. It does allow MPI implementation to avoid an extra copy in some cases. But from our perspective, the biggest reason for MPI data types is the cleaner, simpler code and fewer opportunities for bugs.

The 3D version using MPI data types is a little more complicated. We use `MPI_ Type_create_subarray` in the following listing to create three custom MPI data types to be used in the communication.

**Listing 8.25 Creating an MPI subarray data type for 3D ghost cells**

> `GhostExchange/GhostExchange3D_VectorTypes/GhostExchange.cc  `  
> `109    int array_sizes[] = {ksize+2*nhalo, jsize+2*nhalo, isize+2*nhalo};`  
> `110    if (corners) {`  
> `111       int subarray_starts[] = {0, 0, 0};         `❶  
> `112       int hsubarray_sizes[] =                    `❶  
> `             {ksize+2*nhalo, jsize+2*nhalo,          `❶  
> `              nhalo};                                `❶  
> `113       MPI_Type_create_subarray(3,                `❶  
> `             array_sizes, hsubarray_sizes,           `❶  
> `114          subarray_starts, MPI_ORDER_C,           `❶  
> `             MPI_DOUBLE, &horiz_type);               `❶  
> `115`  
> `116       int vsubarray_sizes[] =                    `❷  
> `             {ksize+2*nhalo, nhalo,                  `❷  
> `              isize+2*nhalo};                        `❷  
> `117       MPI_Type_create_subarray(3,                `❷  
> `             array_sizes, vsubarray_sizes,           `❷  
> `118          subarray_starts, MPI_ORDER_C,           `❷  
> `             MPI_DOUBLE, &vert_type);                `❷  
> `119`  
> `120       int dsubarray_sizes[] =                    `❸  
> `             {nhalo, jsize+2*nhalo,                  `❸  
> `              isize+2*nhalo};                        `❸  
> `121       MPI_Type_create_subarray(3,                `❸  
> `             array_sizes, dsubarray_sizes,           `❸  
> `122          subarray_starts, MPI_ORDER_C,           `❸  
> `             MPI_DOUBLE, &depth_type);               `❸  
> `123    } else {`  
> `124       int hsubarray_starts[] = {nhalo,nhalo,0};  `❶  
> `125       int hsubarray_sizes[] = {ksize, jsize,     `❶  
> `                                   nhalo};           `❶  
> `126       MPI_Type_create_subarray(3,                `❶  
> `             array_sizes, hsubarray_sizes,           `❶  
> `127          hsubarray_starts, MPI_ORDER_C,          `❶  
> `             MPI_DOUBLE, &horiz_type);               `❶  
> `128`  
> `129       int vsubarray_starts[] = {nhalo, 0,        `❷  
> `                                    nhalo};          `❷  
> `130       int vsubarray_sizes[] = {ksize, nhalo,     `❷  
> `                                   isize};           `❷  
> `131       MPI_Type_create_subarray(3,                `❷  
> `             array_sizes, vsubarray_sizes,           `❷  
> `132          vsubarray_starts, MPI_ORDER_C,          `❷  
> `             MPI_DOUBLE, &vert_type);                `❷  
> `133`  
> `134       int dsubarray_starts[] = {0, nhalo,        `❸  
> `                                    nhalo};          `❸  
> `135       int dsubarray_sizes[] = {nhalo, ksize,     `❸  
> `                                   isize};           `❸  
> `136       MPI_Type_create_subarray(3,                `❸  
> `             array_sizes, dsubarray_sizes,           `❸  
> `137          dsubarray_starts, MPI_ORDER_C,          `❸  
> `             MPI_DOUBLE, &depth_type);               `❸  
> `138    }`  
> `139`  
> `140    MPI_Type_commit(&horiz_type);`  
> `141    MPI_Type_commit(&vert_type);`  
> `142    MPI_Type_commit(&depth_type);`

❶ Creates a horizontal data type using MPI_Type_create_subarray

❷ Creates a vertical data type using MPI_Type_create_subarray

❸ Creates a depth data type using MPI_Type_create_subarray

The following listing shows that the communication routine using these three MPI data types is pretty concise.

**Listing 8.26 The 3D ghost cell update using MPI data types**

> `GhostExchange/GhostExchange3D_VectorTypes/GhostExchange.cc  `  
> `334    int waitcount = 12, ib1 = 4, ib2 = 8;`  
> `335    if (corners) {`  
> `336       waitcount=4;`  
> `337       ib1 = 0, ib2 = 0;`  
> `338    }`  
> `339`  
> `340    MPI_Request request[waitcount*nhalo];`  
> `341    MPI_Status status[waitcount*nhalo];`  
> `342`  
> `343    MPI_Irecv(&x[-nhalo][-nhalo][isize],   1,      `❶  
> `                 horiz_type, nrght, 1001,             `❶  
> `344              MPI_COMM_WORLD, &request[0]);        `❶  
> `345    MPI_Isend(&x[-nhalo][-nhalo][0],       1,      `❶  
> `                 horiz_type, nleft, 1001,             `❶  
> `346              MPI_COMM_WORLD, &request[1]);        `❶  
> `347   `  
> `348    MPI_Irecv(&x[-nhalo][-nhalo][-nhalo],  1,      `❶  
> `                 horiz_type, nleft, 1002,             `❶  
> `349              MPI_COMM_WORLD, &request[2]);        `❶  
> `350    MPI_Isend(&x[-nhalo][-nhalo][isize-1], 1,      `❶  
> `                 horiz_type, nrght, 1002,             `❶  
> `351              MPI_COMM_WORLD, &request[3]);        `❶  
> `352    if (corners)                                   `❷  
> `          MPI_Waitall(4, request, status);            `❷  
> `353  `  
> `354    MPI_Irecv(&x[-nhalo][jsize][-nhalo],   1,      `❸  
> `                 vert_type, ntop, 1003,               `❸  
> `355              MPI_COMM_WORLD, &request[ib1+0]);    `❸  
> `356    MPI_Isend(&x[-nhalo][0][-nhalo],       1,      `❸  
> `                 vert_type, nbot, 1003,               `❸  
> `357              MPI_COMM_WORLD, &request[ib1+1]);    `❸  
> `358   `  
> `359    MPI_Irecv(&x[-nhalo][-nhalo][-nhalo],  1,      `❸  
> `                 vert_type, nbot, 1004,               `❸  
> `360              MPI_COMM_WORLD, &request[ib1+2]);    `❸  
> `361    MPI_Isend(&x[-nhalo][jsize-1][-nhalo], 1,      `❸  
> `                 vert_type, ntop, 1004,               `❸  
> `362              MPI_COMM_WORLD, &request[ib1+3]);    `❸  
> `363    if (corners)                                   `❷  
> `          MPI_Waitall(4, request, status);            `❷  
> `364   `  
> `365    MPI_Irecv(&x[ksize][-nhalo][-nhalo],   1,      `❹  
> `                 depth_type, nback, 1005,             `❹  
> `366              MPI_COMM_WORLD, &request[ib2+0]);    `❹  
> `367    MPI_Isend(&x[0][-nhalo][-nhalo],       1,      `❹  
> `                 depth_type, nfrnt, 1005,             `❹  
> `368              MPI_COMM_WORLD, &request[ib2+1]);    `❹  
> `369   `  
> `370    MPI_Irecv(&x[-nhalo][-nhalo][-nhalo],  1,      `❹  
> `                 depth_type, nfrnt, 1006,             `❹  
> `371              MPI_COMM_WORLD, &request[ib2+2]);    `❹  
> `372    MPI_Isend(&x[ksize-1][-nhalo][-nhalo], 1,      `❹  
> `                 depth_type, nback, 1006,             `❹  
> `373              MPI_COMM_WORLD, &request[ib2+3]);    `❹  
> `374    MPI_Waitall(waitcount, request, status);       `❹

❶ Ghost cell update for the horizontal direction.

❷ Synchronize if corners are needed in the update.

❸ Ghost cell update for the vertical direction.

❹ Ghost cell update for the depth direction.

***8.5.2 Cartesian topology support in MPI***

In this section, we’ll show you how the topology functions in MPI work. The operation is still the ghost exchange shown in figure 8.5, but we can simplify the coding by using Cartesian functions. Not covered are general graph functions for unstructured applications. We’ll start with the setup routines before moving on to the communication routines.

The setup routines need to set the values for the process grid assignments and then to set the neighbors as was done in listings 8.18 and 8.22. As shown in listing 8.24 for 2D and listing 8.25 for 3D, the process sets the `dims` array to the number of processors to use in each dimension. If any of the values in the `dims` array are zero, the `MPI_Dims_create` function calculates some values that will work. Note that the number of processes in each direction does not take into account the mesh size and may not produce good values for long, narrow problems. Consider the case of a mesh that is 8x8x1000 and give it 8 processors; the process grid will be 2x2x2, resulting in a mesh domain of 4x4x500 on each process.

`MPI_Cart_create` takes the resulting `dims` array and an input array, `periodic`, that declares whether a boundary wraps to the opposite side and vice-versa. The last argument is the reorder argument that lets MPI reorder processes. It is zero (false) in this example. Now we have a new communicator that contains information about the topology.

Getting the process grid layout is just a call to `MPI_Cart_coords`. Getting neighbors is done with a call to `MPI_Cart_shift` with the second argument specifying the direction and the third argument the displacement or number of processes in that direction. The output is the ranks of the adjacent processors.

**Listing 8.27 2D Cartesian topology support in MPI**

> `GhostExchange/CartExchange_Neighbor/CartExchange.cc`  
> `43 int dims[2] = {nprocy, nprocx};`  
> `44 int periodic[2]={0,0};`  
> `45 int coords[2];`  
> `46 MPI_Dims_create(nprocs, 2, dims);`  
> `47 MPI_Comm cart_comm;`  
> `48 MPI_Cart_create(MPI_COMM_WORLD, 2, dims, periodic, 0, &cart_comm);`  
> `49 MPI_Cart_coords(cart_comm, rank, 2, coords);`  
> `50`  
> `51 int nleft, nrght, nbot, ntop;`  
> `52 MPI_Cart_shift(cart_comm, 1, 1, &nleft, &nrght);`  
> `53 MPI_Cart_shift(cart_comm, 0, 1, &nbot,  &ntop);`

The 3D Cartesian topology setup is similar but with three dimensions as the following listing shows.

**Listing 8.28 3D Cartesian topology support in MPI**

> `GhostExchange/CartExchange3D_Neighbor/CartExchange.cc`  
> `65 int dims[3] = {nprocz, nprocy, nprocx};`  
> `66 int periods[3]={0,0,0};`  
> `67 int coords[3];`  
> `68 MPI_Dims_create(nprocs, 3, dims);`  
> `69 MPI_Comm cart_comm;`  
> `70 MPI_Cart_create(MPI_COMM_WORLD, 3, dims, periods, 0, &cart_comm);`  
> `71 MPI_Cart_coords(cart_comm, rank, 3, coords);`  
> `72 int xcoord = coords[2];`  
> `73 int ycoord = coords[1];`  
> `74 int zcoord = coords[0];`  
> `75`  
> `76 int nleft, nrght, nbot, ntop, nfrnt, nback;`  
> `77 MPI_Cart_shift(cart_comm, 2, 1, &nleft, &nrght);`  
> `78 MPI_Cart_shift(cart_comm, 1, 1, &nbot,  &ntop);`  
> `79 MPI_Cart_shift(cart_comm, 0, 1, &nfrnt, &nback);`

If we compare this code to the versions in listing 8.19 and 8.23, we see that the topology functions do not save a lot of lines of code or greatly reduce the programming complexity in this relatively simple example for the setup. We can also leverage the Cartesian communicator created in line 70 of listing 8.28 to do the neighbor communication as well. That is where the greatest reduction of lines of code is seen. The MPI function has the following arguments:

> `int MPI_Neighbor_alltoallw(const void *sendbuf,`  
> `                           const int sendcounts[],`  
> `                           const MPI_Aint sdispls[],`  
> `                           const MPI_Datatype sendtypes[],`  
> `                           void *recvbuf,`  
> `                           const int recvcounts[],`  
> `                           const MPI_Aint rdispls[],`  
> `                           const MPI_Datatype recvtypes[],`  
> `                           MPI_Comm comm)`

There are a lot of arguments in the neighbor call, but once we get these all set up, the communication is concise and done in a single statement. We’ll go over all the arguments in detail because these can be difficult to get right.

The neighbor communication call can use either a filled buffer for the sends and receives or do the operation in place. We’ll show the in-place method. The send and receive buffers are the 2D `x` array. We will use an MPI data type to describe the data block, so the counts will be an array with the value of one for all four Cartesian sides for 2D or six sides for 3D. The order of the communication for the sides is bottom, top, left, right for 2D and front, back, bottom, top, left, right for 3D, and is the same for both send and receive types.

The data block is different for each direction: horizontal, vertical, and depth. We use the convention of standard perspective drawings with `x` going to the right, `y` upwards, and `z` (the depth) going back into the page. But within each direction, the data block is the same but with different displacements to the start of the data block. The displacements are in bytes, which is why you will see the offsets multiplied by 8, the data type size of a double-precision value. Now let’s look at how all this gets put into code for the setup of the communication for the 2D case in the following listing.

**Listing 8.29 2D Cartesian neighbor communication setup**

> `GhostExchange/CartExchange_Neighbor/CartExchange.c`  
> `55    int ibegin = imax *(coords[1]  )/dims[1];            `❶  
> `56    int iend   = imax *(coords[1]+1)/dims[1];            `❶  
> `57    int isize  = iend - ibegin;                          `❶  
> `58    int jbegin = jmax *(coords[0]  )/dims[0];            `❶  
> `59    int jend   = jmax *(coords[0]+1)/dims[0];            `❶  
> `60    int jsize  = jend - jbegin;                          `❶  
> `61`  
> `62    int jlow=nhalo, jhgh=jsize+nhalo,                    `❷  
> `          ilow=nhalo, inum = isize;                        `❷  
> `63    if (corners) {                                       `❷  
> `64       int ilow = 0, inum = isize+2*nhalo;               `❷  
> `65       if (nbot == MPI_PROC_NULL) jlow = 0;              `❷  
> `66       if (ntop == MPI_PROC_NULL) jhgh = jsize+2*nhalo;  `❷  
> `67    }                                                    `❷  
> `68    int jnum = jhgh-jlow;                                `❷  
> `69`  
> `70    int array_sizes[] = {jsize+2*nhalo, isize+2*nhalo};`  
> `71`  
> `72    int subarray_sizes_x[] = {jnum, nhalo};              `❸  
> `73    int subarray_horiz_start[] = {jlow, 0};              `❸  
> `74    MPI_Datatype horiz_type;                             `❸  
> `75    MPI_Type_create_subarray (2, array_sizes,            `❸  
> `         subarray_sizes_x, subarray_horiz_start,           `❸  
> `76       MPI_ORDER_C, MPI_DOUBLE, &horiz_type);            `❸  
> `77    MPI_Type_commit(&horiz_type);                        `❸  
> `78   `  
> `79    int subarray_sizes_y[] = {nhalo, inum};              `❹  
> `80    int subarray_vert_start[] = {0, jlow};               `❹  
> `81    MPI_Datatype vert_type;                              `❹  
> `82    MPI_Type_create_subarray (2, array_sizes,            `❹  
> `         subarray_sizes_y, subarray_vert_start,            `❹  
> `83       MPI_ORDER_C, MPI_DOUBLE, &vert_type);             `❹  
> `84    MPI_Type_commit(&vert_type);                         `❹  
> `85   `  
> `86    MPI_Aint sdispls[4] = {`  
> `         nhalo  *(isize+2*nhalo)*8,                        `❺  
> `87       jsize  *(isize+2*nhalo)*8,                        `❼  
> `88       nhalo  *8,                                        `❽  
> `89       isize  *8};                                       `❾  
> `90    MPI_Aint rdispls[4] = {`  
> `         0,                                                `❿  
> `91       (jsize+nhalo)  *(isize+2*nhalo)*8,                `⓫  
> `92       0,                                                `⓬  
> `93       (isize+nhalo)*8};                                 `⓭  
> `94    MPI_Datatype sendtypes[4] = {vert_type,              `⓮  
> `         vert_type, horiz_type, horiz_type};               `⓮  
> `95    MPI_Datatype recvtypes[4] = {vert_type,              `⓯  
> `         vert_type, horiz_type, horiz_type};               `⓯

❶ Calculates the global begin and end indices and the local array size

❷ Includes the corner values if these are requested

❸ Creates the data block to communicate in the horizontal direction using the subarray function

❹ Creates the data block to communicate in the vertical direction using the subarray function

❺ Bottom row is nhalo above start.

❻ Displacements are from bottom left corner of memory block in bytes.

❼ Top row is jsize above start.

❽ Left column is nhalo right of start.

❾ Right column is isize right of start.

❿ Bottom ghost row is 0 above start.

⓫ Top ghost row is jsize+nhalo above start.

⓬ Left ghost column is 0 right of start.

⓭ Right ghost row is jsize+nhalo right of start.

⓮ Send types are ordered bottom, top, left, and right neighbors.

⓯ Receive types are ordered bottom, top, left, and right neighbors.

The setup for the 3D Cartesian neighbor communication uses the MPI data types from listing 8.25. The data types define the block of data to be moved, but we need to define the offset in bytes to the start location of the data block for the send and receive. We also need to define the arrays for the `sendtypes` and `recvtypes` in the proper order as in the next listing.

**Listing 8.30 3D Cartesian neighbor communication setup**

> `GhostExchange/CartExchange3D_Neighbor/CartExchange.c`  
> `154    int xyplane_mult = (jsize+2*nhalo)*(isize+2*nhalo)*8;`  
> `155    int xstride_mult = (isize+2*nhalo)*8;`  
> `156    MPI_Aint sdispls[6] = {`  
> `          nhalo  *xyplane_mult,           `❶❷  
> `157       ksize  *xyplane_mult,           `❸  
> `158       nhalo  *xstride_mult,           `❹  
> `159       jsize  *xstride_mult,           `❺  
> `160       nhalo  *8,                      `❻  
> `161       isize  *8};                     `❼  
> `162    MPI_Aint rdispls[6] = {`  
> `          0,                              `❽  
> `163       (ksize+nhalo)  *xyplane_mult,   `❾  
> `164       0,                              `❿  
> `165       (jsize+nhalo)  *xstride_mult,   `⓫  
> `166       0,                              `⓬  
> `167       (isize+nhalo)*8};               `⓭  
> `168    MPI_Datatype sendtypes[6] = {      `⓮  
> `          depth_type, depth_type,         `⓮  
> `          vert_type, vert_type,           `⓮  
> `          horiz_type, horiz_type};        `⓮  
> `169    MPI_Datatype recvtypes[6] = {      `⓮  
> `          depth_type, depth_type,         `⓮  
> `          vert_type, vert_type,           `⓮  
> `          horiz_type, horiz_type};        `⓮

❶ Front is nhalo behind front.

❷ Displacements are from bottom left corner of memory block in bytes.

❸ Back is ksize behind front.

❹ Bottom row is nhalo above start.

❺ Top row is jsize above start.

❻ Left column is nhalo right of start.

❼ Right column is isize.

❽ Front ghost is 0 from front.

❾ Back ghost is ksize+nhalo behind front.

❿ Bottom ghost row is 0 above start.

⓫ Top ghost row is jsize+nhalo above start.

⓬ Left ghost column is 0 right of start.

⓭ Right ghost row is jsize+nhalo right of start.

⓮ Send and receive types are ordered front, back, bottom, top, left, and right.

The actual communication is done with a single call to the `MPI_Neighbor_alltoallw` as shown in listing 8.31. There is also a second block of code for the corner cases that requires a couple of calls with a synchronization in between to ensure the corners are properly filled. The first call does only the horizontal direction and then waits for completion before doing the vertical direction.

**Listing 8.31 2D Cartesian neighbor communication**

> `GhostExchange/CartExchange_Neighbor/CartExchange.c`  
> `224 if (corners) {`  
> `225    int counts1[4] = {0, 0, 1, 1};     `❶  
> `226    MPI_Neighbor_alltoallw (           `❷  
> `          &x[-nhalo][-nhalo], counts1,    `❷  
> `             sdispls, sendtypes,          `❷  
> `227          &x[-nhalo][-nhalo], counts1, `❷  
> `             rdispls, recvtypes,          `❷  
> `228       cart_comm);                     `❷  
> `229`  
> `230    int counts2[4] = {1, 1, 0, 0};     `❸  
> `231    MPI_Neighbor_alltoallw (           `❸  
> `          &x[-nhalo][-nhalo], counts2,    `❸  
> `             sdispls, sendtypes,          `❹  
> `232       &x[-nhalo][-nhalo], counts2,    `❸  
> `             rdispls, recvtypes,          `❹  
> `233       cart_comm);                     `❹  
> `234 } else {`  
> `235    int counts[4] = {1, 1, 1, 1};      `❺  
> `236    MPI_Neighbor_alltoallw (           `❻  
> `          &x[-nhalo][-nhalo], counts,     `❻  
> `             sdispls, sendtypes,          `❻  
> `237       &x[-nhalo][-nhalo], counts,     `❻  
> `             rdispls, recvtypes,          `❻  
> `238       cart_comm);                     `❻  
> `239 }`

❶ Set counts to 1 for the horizontal direction

❷ Horizontal communication

❸ Sets counts to 1 for the vertical direction

❹ Vertical communication

❺ Sets all the counts to 1 for all the directions

❻ All the neighbor communication is done in one call.

The 3D Cartesian neighbor communication is similar but with the addition of the `z` coordinate (depth). The depth comes first in the counts and types arrays. In the phased communication for corners, the depth comes after horizontal and vertical ghost cell exchanges as the next listing shows.

**Listing 8.32 3D Cartesian neighbor communication**

> `GhostExchange/CartExchange3D_Neighbor/CartExchange.c`  
> `346 if (corners) {`  
> `347    int counts1[6] = {0, 0, 0, 0, 1, 1};      `❶  
> `348    MPI_Neighbor_alltoallw(                   `❶  
> `          &x[-nhalo][-nhalo][-nhalo], counts1,   `❶  
> `             sdispls, sendtypes,                 `❶  
> `349       &x[-nhalo][-nhalo][-nhalo], counts1,   `❶  
> `             rdispls, recvtypes,                 `❶  
> `350       cart_comm);                            `❶  
> `351      `  
> `352    int counts2[6] = {0, 0, 1, 1, 0, 0};      `❷  
> `353    MPI_Neighbor_alltoallw(                   `❷  
> `          &x[-nhalo][-nhalo][-nhalo], counts2,   `❷  
> `             sdispls, sendtypes,                 `❷  
> `354       &x[-nhalo][-nhalo][-nhalo], counts2,   `❷  
> `             rdispls, recvtypes,                 `❷  
> `355       cart_comm);                            `❷  
> `356      `  
> `357    int counts3[6] = {1, 1, 0, 0, 0, 0};      `❸  
> `358    MPI_Neighbor_alltoallw(                   `❸  
> `          &x[-nhalo][-nhalo][-nhalo], counts3,   `❸  
> `             sdispls, sendtypes,                 `❸  
> `359       &x[-nhalo][-nhalo][-nhalo], counts3,   `❸  
> `             rdispls, recvtypes,                 `❸  
> `360       cart_comm);                            `❸  
> `361 } else {`  
> `362    int counts[6] = {1, 1, 1, 1, 1, 1};       `❹  
> `363    MPI_Neighbor_alltoallw(                   `❹  
> `          &x[-nhalo][-nhalo][-nhalo], counts,    `❹  
> `             sdispls, sendtypes,                 `❹  
> `364       &x[-nhalo][-nhalo][-nhalo], counts,    `❹  
> `             rdispls, recvtypes,                 `❹  
> `365       cart_comm);                            `❹  
> `366 }`

❶ Horizontal ghost exchange

❷ Vertical ghost exchange

❸ Depth ghost exchange

❹ All neighbors at once

***8.5.3 Performance tests of ghost cell exchange variants***

Let’s try out these ghost cell exchange variants on a test system. We’ll use two Broadwell nodes (Intel® Xeon® CPU E5-2695 v4 at 2.10GHz) with 72 virtual cores each. We could run this on more compute nodes with different MPI library implementations, halo sizes, mesh sizes, and with higher performance communication interconnects for a more comprehensive view of how each ghost cell exchange variant performs. Here’s the code:

> `mpirun -n 144 --bind-to hwthread ./GhostExchange -x 12 -y 12 -i 20000 \`  
> `       -j 20000 -h 2 -t -c`  
> `mpirun -n 144 --bind-to hwthread ./GhostExchange -x 6 -y 4 -z 6 -i 700 \`  
> `       -j 700 -k 700 -h 2 -t -c`

The options to the GhostExchange program are

- `-x` (processes in the x-direction)

- `-y` (processes in the y-direction)

- `-z` (processes in the z-direction)

- `-i` (mesh size in the i- or x-direction)

- `-j` (mesh size in the j- or y-direction)

- `-k` (mesh size in the k- or z-direction)

- `-h` (width of halo cells, usually 1 or 2)

- `-c` (include the corner cells)

> **Exercise: Ghost cell tests**

> The accompanying source code is set up to run the whole set of ghost cell exchange variations. In the batch.sh file, you can change the halo size and whether you want corners. The file is set up to run all of the test cases 11 times on two Skylake Gold nodes with 144 total processes.

> `cd GhostExchange`  
> `./build.sh`  
> `./batch.sh |& tee results.txt`  
> `./get_stats.sh > stats.out`

> You can then generate plots with the provided scripts. You need the matplotlib library for the Python plotting scripts. The results are for the median run time.

> `python plottimebytype.py`  
> `python plottimeby3Dtype.py`

> The following figure shows the plots for the small test cases. The MPI data type versions appear a little faster even at this small scale, indicating that perhaps a data copy is being avoided. The larger gain for the MPI Cartesian topology calls and MPI data types is that the ghost exchange code is greatly simplified. The use of these more advanced MPI calls does require more setup effort, but this is just done once at startup.

>   

> **The relative performance of 2D and 3D ghost exchanges on two nodes with a total of 144 processes. The MPI data types in the MPI types and CNeighbor are a little faster than the buffer explicitly filled by loops of array assignments. In the 2D ghost exchanges, the pack routines are slower, although in this case, the explicitly filled buffer is faster than the MPI data types.**

***8.6 Hybrid MPI plus OpenMP for extreme scalability***

The combination of two or more parallelization techniques is called a hybrid parallelization, in contrast to all MPI implementations that are also called pure MPI or MPI-everywhere. In this section, we’ll look at Hybrid MPI plus OpenMP, where MPI and OpenMP are used together in an application. This usually amounts to replacing some MPI ranks with OpenMP threads. For larger parallel applications reaching into thousands of processes, replacing MPI ranks with OpenMP threads potentially reduces the total size of the MPI domain and the memory needed for extreme scale. However, the added performance of the thread-level parallelism layer might not always be worth the added complexity and development time. For this reason, hybrid MPI plus OpenMP implementations are normally the domain of extreme applications in both size and performance needs.

***8.6.1 The benefits of hybrid MPI plus OpenMP***

When performance becomes critical enough for the added complexity of hybrid parallelism, there can be several advantages of adding an OpenMP parallel layer to MPI-based code. For example, these advantages might be

- Fewer ghost cells to communicate between nodes

- Lower memory requirements for MPI buffers

- Reduced contention for the NIC

- Reduced size of tree-based communications

- Improved load balancing

- Accessing all hardware components

Spatially-decomposed parallel applications using subdomains with ghost (halo) cells will have fewer total ghost cells per node when you add thread-level parallelism. This leads to a reduction in both memory requirements and communication costs, especially on a many-core architecture like Intel’s Knights Landing (KNL). Using shared-memory parallelism can also improve performance by reducing contention for the network interface card (NIC) by avoiding the unnecessary copying of data used by MPI for on-node messages. Additionally, many MPI algorithms are tree-based, scaling as log_(2n). Reducing the run time by 2n threads decreases the depth of the tree and incrementally improves performance. While the remaining work still has to be done by threads, it impacts performance by allowing less synchronization and communication latency costs. Threads can also be used to improve load balance within a NUMA region or a compute node.

In some cases, a hybrid parallel approach is not only advantageous, but necessary to access the full hardware performance potential. For example, some hardware, and perhaps memory controller functionality, can only be accessed by threads and not processes (MPI ranks). The many-core architectures of Intel’s Knights Corner and Knights Landing architectures have had these concerns. In MPI + X + Y, where X is threading and Y is a GPU language, we often match the ranks to the number of GPUs. OpenMP allows the application to continue to access the other processors for on-CPU work. There are other solutions to this, such as MPI_COMM groups and MPI-shared memory functionality or simply driving the GPU from multiple MPI ranks.

In summary, while it can be attractive to run codes with MPI-everywhere on modern many-core systems, there are concerns about scalability as the number of cores grows. If you are looking for extreme scalability, you will want an efficient implementation of OpenMP in your application. We covered our design of high-level OpenMP that is much more efficient in the previous chapter in sections 7.2.2 and 7.6.

***8.6.2 MPI plus OpenMP example***

The first steps to a hybrid MPI plus OpenMP implementation is to let MPI know what you will be doing. This is done in the `MPI_Init` call right at the beginning of the program. You should replace the `MPI_Init` call with the `MPI_Init_thread` call like this:

> `MPI_Init_thread(&argc, &argv, int thread_model required,`  
> `                int *thread_model_provided);`

The MPI standard defines four thread models. These models give different levels of thread safety with the MPI calls. In increasing order of thread safety:

- `MPI_THREAD_SINGLE`—Only one thread is executed (standard MPI)

- `MPI_THREAD_FUNNELED`—Multithreaded but only the main thread makes MPI calls

- `MPI_THREAD_SERIALIZED`—Multithreaded but only one thread at a time makes MPI calls

- `MPI_THREAD_MULTIPLE`—Multithreaded with multiple threads making MPI calls

Many applications perform communication at the main loop level, and OpenMP threads are applied to key computational loops. For this pattern, `MPI_THREAD_FUNNELED` works just fine.

> > > **NOTE** It’s best to use the lowest level of thread safety that you need. Each higher level imposes a performance penalty because the MPI library has to place mutexes or critical blocks around send and receive queues and other basic parts of MPI.

Now let’s see what changes are needed to our stencil example to add OpenMP threading. We chose the CartExchange_Neighbor example to modify for this exercise. The following listing shows that the first change is to modify the MPI initialization.

**Listing 8.33 MPI initialization for OpenMP threading**

> `HybridMPIPlusOpenMP/CartExchange.cc`  
> `26 int provided;`  
> `27 MPI_Init_thread(&argc, &argv,                    `❶  
> `      MPI_THREAD_FUNNELED, &provided);              `❶  
> `28`  
> `29 int rank, nprocs;`  
> `30 MPI_Comm_rank(MPI_COMM_WORLD, &rank);`  
> `31 MPI_Comm_size(MPI_COMM_WORLD, &nprocs);`  
> `32 if (rank == 0) {`  
> `33    #pragma omp parallel`  
> `34    #pragma omp master`  
> `35       printf("requesting MPI_THREAD_FUNNELED”    `❷  
> `                  " with %d threads\n",             `❷  
> `36              omp_get_num_threads());             `❷  
> `37    if (provided != MPI_THREAD_FUNNELED){         `❸  
> `38       printf("Error: MPI_THREAD_FUNNELED”`  
> `                  " not available. Aborting ...\n");`  
> `39       MPI_Finalize();`  
> `40       exit(0);`  
> `41    }`  
> `42 }`

❶ MPI initialization for OpenMP threading

❷ Prints number of threads to check if what we want

❸ Checks if this MPI supports our requested thread safety level

The mandatory change is using `MPI_Init_thread` instead of `MPI_Init` on line 27. The additional code checks that the requested thread safety level is available and exits if it is not. We also print the number of threads on the main thread of rank zero. Now onto the changes in the computational loop shown in the next listing.

**Listing 8.34 Addition of OpenMP threading and vectorization to computational loops**

> `HybridMPIPlusOpenMP/CartExchange.cc`  
> `157  #pragma omp parallel for              `❶  
> `158  for (int j = 0; j < jsize; j++){`  
> `159     #pragma omp simd                   `❷  
> `160     for (int i = 0; i < isize; i++){`  
> `161        xnew[j][i] = ( x[j][i] + x[j][i-1] + x[j][i+1]`  
> `                                  + x[j-1][i] + x[j+1][i] )/5.0;`  
> `162     }`  
> `163  }`

❶ Adds OpenMP threading for outer loop

❷ Adds SIMD vectorization for inner loop

The changes required to add OpenMP threading are the addition of a single pragma at line 157. As a bonus, we show how to add vectorization for the inner loop with another pragma inserted at line 159.

You can now try running this hybrid MPI plus OpenMP+Vectorization example on your system. But to get good performance, you will need to control the placement of the MPI ranks and the OpenMP threads. This is done by setting affinity, a topic that we will cover in greater depth in chapter 14.

> > > **DEFINITION** Affinity assigns a preference for the scheduliing of a process, rank, or thread to a particular hardware component. This is also called pinning or binding.

Setting the affinity for your ranks and threads becomes more important as the complexity of the node increases and with hybrid parallel applications. In earlier examples, we used `—bind-to core` and `—bind-to hwthread` to improve performance and reduce variability in run-time performance caused by ranks migrating from one core to another. In OpenMP, we used environment variables to set placement and affinities. An example is

> `export OMP_PLACES=cores`  
> `export OMP_CPU_BIND=true`

For now, start with pinning the MPI ranks to sockets so that the threads can spread to other cores as we showed in our ghost cell test example for the Skylake Gold processor. Here’s how:

> `export OMP_NUM_THREADS=22`  
> `mpirun -n 4 --bind-to socket ./CartExchange -x 2 -y 2 -i 20000 -j 20000 \`  
> `-h 2 -t -c`

We run 4 MPI ranks that each spawn 22 threads as specified by the `OMP_NUM_THREADS` environment variable for a total of 88 processes. The `—bind-to socket` option to `mpirun` tells it to bind the processes to the socket where these are placed.

***8.7 Further explorations***

Although we have covered a lot of material in this chapter, there are still many more features that are worth exploring as you get more experience with MPI. Some of the most important are mentioned here and left for your own study.

- Comm groups—MPI has a rich set of functions that create, split, and otherwise manipulate the standard MPI COMM_WORLD communicator into new groupings for specialized operations like communication within a row or task-based subgroups. For some examples of the use of communicator groups, see listing 16.4 in section 16.3. We use communication groups to split the file output into multiple files and break the domain into row and column communicators.

- Unstructured mesh boundary communications—An unstructured mesh needs to exchange boundary data in a similar manner to that covered for a regular, Cartesian mesh. These operations are more complex and not covered here. There are many sparse, graph-based communication libraries that support unstructured mesh applications. One example of such a library is the L7 communication library developed by Richard Barrett now at Sandia National Laboratories. It is included with the CLAMR mini-app; see the l7 subdirectory at [https:// github.com/LANL/CLAMR](https://github.com/LANL/CLAMR).

- Shared memory—The original MPI implementations sent data over the network interface in nearly all cases. As the number of cores grew, MPI developers realized that they could do some of the communication in shared memory. This is done behind the scenes as a communication optimization. Additional shared memory functionality continues to be added with MPI shared memory “windows.” This functionality had some problems at first, but it is becoming mature enough to use in applications.

- One-sided communication—Responding to other programming models, MPI added one-sided communication in the form of `MPI_Puts` and `MPI_Gets`. Contrary to the original MPI message-passing model, where both the sender and receiver have to be active participants, the one-sided model allows just one or the other to conduct the operation.

***8.7.1 Additional reading***

If you want more introductory material on MPI, the text by Peter Pacheco is a classic:

Peter Pacheco, An introduction to parallel programming (Elsevier, 2011).

You can find thorough coverage of MPI authored by members of the original MPI development team:

William Gropp, et al., “Using MPI: portable parallel programming with the message-passing interface,” Vol. 1 (MIT Press, 1999).

For a presentation of MPI plus OpenMP, there is a good lecture from a course by Bill Gropp, one of the developers of the original MPI standard. Here’s the link:

<http://wgropp.cs.illinois.edu/courses/cs598-s16/lectures/lecture36.pdf>

***8.7.2 Exercises***

1.  Why can’t we just block on receives as was done in the send/receive in the ghost exchange using the pack or array buffer methods in listings 8.20 and 8.21, respectively?

2.  Is it safe to block on receives as shown in listing 8.8 in the vector type version of the ghost exchange? What are the advantages if we only block on receives?

3.  Modify the ghost cell exchange vector type example in listing 8.21 to use blocking receives instead of a `waitall`. Is it faster? Does it always work?

4.  Try replacing the explicit tags in one of the ghost exchange routines with `MPI_ ANY_TAG`. Does it work? Is it any faster? What advantage do you see in using explicit tags?

5.  Remove the barriers for the synchronized timers in one of the ghost exchange examples. Run the code with the original synchronized timers and the unsynchronized timers.

6.  Add the timer statistics from listing 8.11 to the stream triad bandwidth measurement code in listing 8.17.

7.  Apply the steps to convert high-level OpenMP to the hybrid MPI plus OpenMP example in the code that accompanies the chapter (HybridMPIPlusOpenMP directory). Experiment with the vectorization, number of threads, and MPI ranks on your platform.

***Summary***

- Use the proper send and receive point-to-point messages. This avoids hangs and gets good performance.

- Use collective communication for common operations. This makes for concise programming, avoids hangs, and improves performance.

- Use ghost exchanges to link together subdomains from various processors. The exchanges make the subdomains act as a single global computational mesh.

- Add more levels of parallelism through combining MPI with OpenMP threads and vectorization. The additional parallelism helps give better performance.
