# 16 File operations for a parallel world

***16 File operations for a parallel world***

This chapter covers

- Modifying a parallel application for standard file operations
- Writing out data using parallel file operations with MPI-IO and HDF5
- Tuning parallel file operations for different parallel filesystems

Filesystems create a streamlined workflow of retrieving, storing, and updating data. For any computing work, the product is the output, whether it be data, graphics, or statistics. This includes final results but also intermediate output for graphics, checkpointing, and analysis. Checkpointing is a special need on large HPC systems with long-running calculations that might span days, weeks, or months.

> > > **DEFINITION** Checkpointing is the practice of periodically storing the state of a calculation to disk so that the calculation can be restarted in the event of system failures or because of finite length run times in a batch system

When processing data for highly parallel applications, there needs to be a safe and performant way of reading and storing data at run time. Therein lies the need to understand file operations in a parallel world. Some of the concerns you should keep in mind are correctness, reducing duplicate output, and performance.

It is important to be aware that the scaling of the performance of filesystems has not kept up with the rest of the computing hardware. We are scaling calculations up to billions of cells or particles, which is putting severe demands on the filesystems. With the advent of machine learning and data science, many more applications need big data that requires large files sets and complex workflows with intermediate file storage.

Adding an understanding of file operations to your HPC toolset is becoming more and more important. In this chapter, we introduce how to modify file operations for a parallel application so that you are writing out data efficiently and making the best use of the available hardware. Though this topic may not be heavily covered in many parallel tutorials, we think it’s a baseline essential for today’s parallel applications. You will learn how to speed up the file-writing operation by orders of magnitude while maintaining correctness. We will also look at the different software and hardware that are typically used for large HPC systems. We will use the example of writing out the data from the domain decomposition of a regular grid with halo cells using different parallel file software. We encourage you to follow along with the examples for this chapter at <https://github.com/EssentialsOfParallelComputing/Chapter16.git>.

***16.1 The components of a high-performance filesystem***

We first review what hardware comprises a high-performance filesystem. Traditionally, file operations store data to a hard disk with a mechanical mechanism that writes a series of bits to a magnetic substrate. Like many other parts of HPC systems, the storage hardware has become more complex with deeper hierarchies of hardware and different performance characteristics. This evolution of storage hardware is similar to the deepening of the cache hierarchy for processors as these increased in performance. The storage hierarchy also helps to cover the large disparity in bandwidth at the processor level, compared to mechanical disk storage. This is because it is much harder to reduce the size of mechanical components than electrical circuits. The introduction of solid-state drives (SSDs) and other solid-state devices has helped to provide a way around the scaling of physical spinning disks.

Let’s first specify what might comprise an HPC storage system as illustrated in figure 16.1. Typical storage hardware components include the following:

- Spinning disk—Electro-mechanical device where data is stored in an electro-magnetic layer through the movement of a mechanical recording head.

- SSD—A solid-state drive (SSD) is a solid-state memory device that can replace a mechanical disk.

- Burst buffer—Intermediate storage hardware layer composed of NVRAM and SSD components. It is positioned between the compute hardware and the main disk storage resources.

- Tape—A magnetic tape with auto-loading cartridges.

The storage schematic in figure 16.1 illustrates the storage hierarchy between the compute system and the storage system. Burst buffers are inserted in between the compute hardware and the main disk storage to cover the increasing gap in performance. Burst buffers can either be placed on each node or on the IO nodes and shared via a network with the other compute nodes.

**Figure 16.1 Schematic showing positioning of burst buffer hardware in between the compute resources and disk storage. Burst buffers can either be node-local or shared among nodes via a network.**

With the rapid development of solid-state storage technology, the burst buffer designs will continue to evolve in the near future. Besides helping with the gap in latency and bandwidth performance, new storage designs are increasingly driven by the need to reduce power requirements as systems grow in size. A magnetic tape has traditionally been used for long-term storage, but some designs have even looked at a “dark disk,” where spinning disks are used but turned off when not needed.

***16.2 Standard file operations: A parallel-to-serial interface***

Let’s first take a look at standard file operations. For our parallel applications, the conventional file-handling interface is still a serial operation. It is not practical to have a hard disk for every processor. Even a file per process is only viable in limited situations and at small scale. The result is that for every file operation, we go from parallel to serial. A file operation needs to be treated as a reduction (or expansion for reads) in the number of processes, requiring special handling for parallel applications. You can handle this parallelism with some simple modifications to standard file input and output (IO).

A large portion of the modifications for parallel applications is at the file-operation interface. We should first review our prior examples that involved file operations. For an example of file input, section 8.3.2 shows how to read in data on one process and then broadcast it to other processes. In section 8.3.4, we used an MPI gather operation so that output from processes is written out in a deterministic order.

(Pro tip) To avoid later complications, the first step you should take in parallelizing an application is to go through the code and insert an `if (rank == 0)` in front of every input and output statement. While going through the code, you should identify which file operations need additional treatment. These operations include the following (illustrated in figure 16.2).

- Opening files on only one process and then broadcasting the data to other processes

- Distributing data that needs to be partitioned across processes with a scatter operation

- Ensuring that output should come from only one process

- Collecting the distributed data with a gather operation before it is output

**Figure 16.2 Modifications for a parallel application to work with a standard filesystem. All file operations are done from rank 0.**

A common inefficiency is to open a file on every process; you can imagine it being equivalent to a dozen people trying to open a door at the same time. While your program might not crash, it causes problems at scale (imagine 1,000 people opening that same door). There’s a lot of contention for the file metadata and the lock for correctness that it causes, which can take minutes at larger process counts. We can avoid this contention by opening the file on just one process. By adding parallel communication calls at each of the transition points from serial to parallel and parallel to serial, we can make modest parallel applications work using standard files. This is sufficient for the vast majority of parallel applications.

As our applications grow in size, we can no longer easily gather or scatter the data to a single process. Our biggest limitation is memory; we don’t have enough memory resources on a single process to bring the data from thousands of other processes down to just one. Thus, we have to have a different, more scalable approach to file operations. That is the subject of the next two sections on MPI file operations, called MPI-IO, and Hierarchical Data Format v5 (HDF5). In these sections, we show how these two libraries permit a parallel application to treat file operations in a parallel manner. There are other parallel file libraries that we will mention in section 16.5.

***16.3 MPI file operations (MPI-IO) for a more parallel world***

The best way to learn MPI-IO is to see how it is used in a realistic scenario. We’ll take a look at the example of writing out a regular mesh that has been distributed across processors with halo cells using MPI-IO. Through this example, you will become familiar with the basic structure that occurs with MPI-IO and some of its more common function calls.

The first parallel file operations were added to MPI in the MPI-2 standard in the late 1990s. The first widely available implementation of the MPI file operations, ROMIO, was led by Rajeev Thakur at Argonne National Laboratory (ANL). ROMIO can be used with any MPI implementation. Most MPI distributions include ROMIO as a standard part of their software release. MPI-IO has a lot of functions, all beginning with the prefix `MPI_File`. In this section, we will cover just a subset of the most commonly used operations (see table 16.1).

There are different ways to use MPI-IO. We are interested in the highly parallel version, the collective form that has the processes work together to write to their section of the file. In order to do this, we’ll utilize the ability to create a new MPI data type that was first introduced in section 8.5.1.

The MPI-IO library has both a shared file pointer across all processes and independent file pointers for each process. Using the shared pointer causes a lock to be applied for each process and serializes the file operations. To avoid the locks, we use the independent file pointers for better performance.

File operations are broken down into collective and non-collective operations. Collective operations use the MPI collective communication calls, and all members of the communicator must make the call or it will hang. Non-collective calls are serial operations that are invoked separately for every process. Table 16.1 shows some general-purpose operations and the respective commands for each.

**Table 16.1 MPI general file routines**

**Command**

**Description**

`MPI_File_open`

Collective file open

`MPI_File_seek`

Moves individual file pointers to this location in file

`MPI_File_set_size`

Allocates the file space specified

`MPI_File_close`

Collective file close

`MPI_File_set_info`

Communicates hints to the MPI-IO library for more optimized MPI operations

The file open and close operations are self-explanatory. The seek operation moves the individual file pointer to the specified location for each process. You can use `MPI_ File_set_info` to communicate both general- and vendor-specific hints. There is also an `MPI_File_delete`, but it is a non-collective call. In this case, we mean a non-collective call to be a serial call: every process deletes the file. For C and C++ programs, the `remove` function works just as well. Calling `MPI_File_set_size` with the expected size of your file can be more efficient than the file being incrementally increased in size with each write.

We’ll start by looking at the independent file operations for the read and write operations. When each process operates on its independent file pointer, it’s known as an independent file operation. Independent file operations are useful for writing out replicated data across processes. For this common data, you can write it out from a single rank with the routines in table 16.2.

**Table 16.2 MPI independent file routines**

**Command**

**Description**

`MPI_File_read`

Each process reads from its current file pointer position.

`MPI_File_write`

Each process writes to its current file pointer position.

`MPI_File_read_at`

Moves the file pointer to the specified location and reads the data

`MPI_File_write_at`

Moves the file pointer to the specified location and writes the data

You should write out distributed data with collective operations (table 16.3). When processes operate collectively on the file, it’s known as a collective file operation. The write and read functions are similar to the independent file operations but with an `_all` appended to the function name. To make the best use of the collective operations, we need to create complex MPI data types. The `MPI_File_set_view` function is used to set the data layout in the file.

**Table 16.3 MPI collective file routines**

**Command**

**Description**

`MPI_File_set_view`

View of file visible to each process. Sets file pointers to zero.

`MPI_File_read_all`

All processes collectively read from their current, independent file pointer.

`MPI_File_write_all`

All processes collectively write from their current, independent file pointer.

`MPI_File_read_at_all`

All processes move to specified file location and read the data.

`MPI_File_write_at_all`

All processes move to specified file location and write the data.

For this example, we’ll break up the code into four blocks. (The full code for this example is included with the code for the chapter.) To begin, we must start with the creation of an MPI data type for the memory layout of the data and another for the file layout; these are referred to as memspace and filespace, respectively. Figure 16.3 shows these data types for a smaller 4×4 version of our example. For simplicity, we only show four processes, each with a 4×4 grid surrounded by a one cell halo. The halo depth size in the figure is ng, short for number of ghost cells.

**Figure 16.3 The 4x4 blocks of data from each process written without the halo cells to contiguous sections of the output file. The top row is the memory layout on the process, referred to as the memspace. The middle row is the memory in the file with the halo cells stripped off, referred to as the filespace. The memory in the file is actually linear, so it takes the form in the last row.**

The first block of code in listing 16.1 shows the creation of these two data types. This only needs to be done once at the start of the program. The data types should then be freed at the end of the program in the finalize routine.

**Listing 16.1 Setting up MPI-IO dataspace types**

> `MPI_IO_Examples/mpi_io_block2d/mpi_io_file_ops.c`  
> `10 void mpi_io_file_init(int ng, int ndims, int *global_sizes,`  
> `11     int *global_subsizes, int *global_starts, MPI_Datatype *memspace,`  
> `       MPI_Datatype *filespace){`  
> `12   // create data descriptors on disk and in memory`  
> `13`  
> `14   // Global view of entire 2D domain -- collates decomposed subarrays`  
> `15   MPI_Type_create_subarray(ndims,                                     `❶  
> `       global_sizes, global_subsizes,                                    `❶  
> `16     global_starts, MPI_ORDER_C, MPI_DOUBLE,                           `❶  
> `       filespace);                                                       `❶  
> `17   MPI_Type_commit(filespace);                                         `❷  
> `18`  
> `19   // Local 2D subarray structure -- strips ghost cells on node`  
> `20   int ny = global_subsizes[0], nx = global_subsizes[1];`  
> `21   int local_sizes[]    = {ny+2*ng,   nx+2*ng};`  
> `22   int local_subsizes[] = {ny,        nx};`  
> `23   int local_starts[]   = {ng,        ng};`  
> `24`  
> `25   MPI_Type_create_subarray(ndim, local_sizes,                         `❸  
> `        local_subsizes, local_starts,                                    `❸  
> `26      MPI_ORDER_C, MPI_DOUBLE, memspace);                              `❸  
> `27   MPI_Type_commit(memspace);                                          `❹  
> `28 }`  
> `29`  
> `30 void mpi_io_file_finalize(MPI_Datatype *memspace,`  
> `        MPI_Datatype *filespace){`  
> `31   MPI_Type_free(memspace);                                            `❺  
> `32   MPI_Type_free(filespace);                                           `❺  
> `33 }`

❶ Creates the data type for the file data layout

❷ Commits the file data type

❸ Creates the data type for the memory data layout

❹ Commits the memory data type

❺ Frees the data types

In this first step, we created the two data types from figure 16.1. Now we need to write these data types out to the file. There are four steps to the writing process as shown in listing 16.2:

1.  Create the file

2.  Set the file view

3.  Write out each array with collective call

4.  Close the file

**Listing 16.2 Writing an MPI-IO file**

> `MPI_IO_Examples/mpi_io_block2d/mpi_io_file_ops.c`  
> `35 void write_mpi_io_file(const char *filename, double **data,`  
> `36     int data_size, MPI_Datatype memspace, MPI_Datatype filespace,`  
> `       MPI_Comm mpi_io_comm){`  
> `37   MPI_File file_handle = create_mpi_io_file(          `❶  
> `38     filename, mpi_io_comm, (long long)data_size);     `❶  
> `39`  
> `40   MPI_File_set_view(file_handle, file_offset,         `❷  
> `41     MPI_DOUBLE, filespace, "native",                  `❷  
> `            MPI_INFO_NULL);                              `❷  
> `42   MPI_File_write_all(file_handle,                     `❸  
> `       &(data[0][0]), 1, memspace,                       `❸  
> `       MPI_STATUS_IGNORE);                               `❸  
> `43   file_offset += data_size;`  
> `44`  
> `45   MPI_File_close(&file_handle);                       `❹  
> `46   file_offset = 0;`  
> `47 }`  
> `48`  
> `49 MPI_File create_mpi_io_file(const char *filename, MPI_Comm mpi_io_comm,`  
> `50         long long file_size){`  
> `51   int file_mode = MPI_MODE_WRONLY | MPI_MODE_CREATE |`  
> `                     MPI_MODE_UNIQUE_OPEN;`  
> `52`  
> `53   MPI_Info mpi_info = MPI_INFO_NULL;  // For MPI IO hints`  
> `54   MPI_Info_create(&mpi_info);`  
> `55   MPI_Info_set(mpi_info,                              `❺  
> `       "collective_buffering", "1");                     `❺  
> `56   MPI_Info_set(mpi_info,                              `❻  
> `       "striping_factor", "8");                          `❻  
> `57   MPI_Info_set(mpi_info,                              `❻  
> `        "striping_unit", "4194304");                     `❻  
> `58`  
> `59   MPI_File file_handle = NULL;`  
> `60   MPI_File_open(mpi_io_comm, filename, file_mode, mpi_info,`  
> `                   &file_handle);`  
> `61   if (file_size > 0)                                  `❼  
> `       MPI_File_set_size(file_handle, file_size);        `❼  
> `62   file_offset = 0;`  
> `63   return file_handle;`  
> `64 }`

❶ Creates the file

❷ Sets file view

❸ Writes out arrays

❹ Closes the file

❺ Communicates hints for collective operation

❻ Communicates hints for striping on Lustre filesystem

❼ Preallocates file space for better performance

There are a few optimizations that can be provided during the open with hints in an `MPI_Info` object (line 53). A hint could be that the file operations should be done using collective operations, `collective_buffering`, as on line 55. Or a hint can be one that’s filesystem specific to stripe across eight hard disks, `striping_factor = 8`, as on line 56. We will discuss hints more in section 16.6.1.

We can also preallocate the file space, as shown on line 61, so that it doesn’t have to be increased during the writes. Reading the file has the same four steps as the writing process listed previously and is shown in the following listing.

**Listing 16.3 Reading an MPI-IO file**

> `MPI_IO_Examples/mpi_io_block2d/mpi_io_file_ops.c`  
> `66 void read_mpi_io_file(const char *filename, double **data, int data_size,`  
> `67     MPI_Datatype memspace, MPI_Datatype filespace, MPI_Comm mpi_io_comm){`  
> `68   MPI_File file_handle = open_mpi_io_file(      `❶  
> `        filename, mpi_io_comm);                    `❶  
> `69`  
> `70   MPI_File_set_view(file_handle, file_offset,   `❷  
> `71      MPI_DOUBLE, filespace, "native",           `❷  
> `        MPI_INFO_NULL);                            `❷  
> `72   MPI_File_read_all(file_handle,                `❸  
> `        &(data[0][0]), 1, memspace,                `❸  
> `        MPI_STATUS_IGNORE);                        `❸  
> `73   file_offset += data_size;`  
> `74`  
> `75   MPI_File_close(&file_handle);                 `❹  
> `76   file_offset = 0;`  
> `77 }`  
> `78`  
> `79 MPI_File open_mpi_io_file(const char *filename, MPI_Comm mpi_io_comm){`  
> `80   int file_mode = MPI_MODE_RDONLY | MPI_MODE_UNIQUE_OPEN;`  
> `81`  
> `82   MPI_Info mpi_info = MPI_INFO_NULL; // For MPI IO hints`  
> `83   MPI_Info_create(&mpi_info);`  
> `84   MPI_Info_set(mpi_info, "collective_buffering", "1");`  
> `85`  
> `86   MPI_File file_handle = NULL;`  
> `87   MPI_File_open(mpi_io_comm, filename, file_mode, mpi_info,`  
> `                   &file_handle);`  
> `88   return file_handle;`  
> `89 }`

❶ Opens the file

❷ Sets file view

❸ Collective read of arrays

❹ Closes the file

The read operation requires fewer hints and settings than the write operation. This is because some of the settings for a read are determined from the file. So far, these MPI-IO file operations have been written in a general form that can be called for any problem. Now let’s take a look at the main application code in the following listing that sets up the calls.

**Listing 16.4 Main application code**

> `MPI_IO_Examples/mpi_io_block2d/mpi_io_block2d.c`  
> `  9 int main(int argc, char *argv[])`  
> `10 {`  
> `11   MPI_Init(&argc, &argv);`  
> `12`  
> `13   int rank, nprocs;`  
> `14   MPI_Comm_rank(MPI_COMM_WORLD, &rank);`  
> `15   MPI_Comm_size(MPI_COMM_WORLD, &nprocs);`  
> `16`  
> `17   // for multiple files, subdivide communicator and`  
> `      //    set colors for each set`  
> `18   MPI_Comm mpi_io_comm = MPI_COMM_NULL;`  
> `19   int nfiles = 1;`  
> `20   float ranks_per_file = (float)nprocs/(float)nfiles;`  
> `21   int color = (int)((float)rank/ranks_per_file);`  
> `22   MPI_Comm_split(MPI_COMM_WORLD, color, rank, &mpi_io_comm);`  
> `23   int nprocs_color, rank_color;`  
> `24   MPI_Comm_size(mpi_io_comm, &nprocs_color);`  
> `25   MPI_Comm_rank(mpi_io_comm, &rank_color);`  
> `26   int row_color = 1, col_color = rank_color;`  
> `27   MPI_Comm mpi_row_comm, mpi_col_comm;`  
> `28   MPI_Comm_split(mpi_io_comm, row_color, rank_color, &mpi_row_comm);`  
> `29   MPI_Comm_split(mpi_io_comm, col_color, rank_color, &mpi_col_comm);`  
> `30`  
> `31   // set the dimensions of our data array and the number of ghost cells`  
> `32   int ndim = 2, ng = 2, ny = 10, nx = 10;`  
> `33   int global_subsizes[] = {ny, nx};`  
> `34`  
> `35   int ny_offset = 0, nx_offset = 0;`  
> `36   MPI_Exscan(&nx, &nx_offset, 1, MPI_INT, MPI_SUM, mpi_row_comm);`  
> `37   MPI_Exscan(&ny, &ny_offset, 1, MPI_INT, MPI_SUM, mpi_col_comm);`  
> `38   int global_offsets[] = {ny_offset, nx_offset};`  
> `39`  
> `40   int ny_global, nx_global;`  
> `41   MPI_Allreduce(&nx, &nx_global, 1, MPI_INT, MPI_SUM, mpi_row_comm);`  
> `42   MPI_Allreduce(&ny, &ny_global, 1, MPI_INT, MPI_SUM, mpi_col_comm);`  
> `43   int global_sizes[] = {ny_global, nx_global};`  
> `44   int data_size = ny_global*nx_global;`  
> `45`  
> `46   double **data = (double **)malloc2D(ny+2*ng, nx+2*ng);`  
> `47   double **data_restore = (double **)malloc2D(ny+2*ng, nx+2*ng);`  
> `     < ... skipping data initialization ... >`  
> `54`  
> `55   MPI_Datatype memspace = MPI_DATATYPE_NULL,`  
> `                   filespace = MPI_DATATYPE_NULL;`  
> `56   mpi_io_file_init(ng, global_sizes,                       `❶  
> `          global_subsizes, global_offsets,                     `❶  
> `57       &memspace, &filespace);                              `❶  
> `58`  
> `59   char filename[30];`  
> `60   if (ncolors > 1) {`  
> `61     sprintf(filename,"example_%02d.data",color);`  
> `62   } else {`  
> `63     sprintf(filename,"example.data");`  
> `64   }`  
> `65`  
> `66   // Do the computation and write out a sequence of files`  
> `67   write_mpi_io_file(filename, data,                        `❷  
> `         data_size, memspace, filespace,                       `❷  
> `         mpi_io_comm);                                         `❷  
> `68   // Read back the data for verifying the file operations`  
> `69   read_mpi_io_file(filename, data_restore,                 `❸  
> `70      data_size, memspace, filespace,                       `❸  
> `         mpi_io_comm);                                         `❸  
> `71  `  
> `72   mpi_io_file_finalize(&memspace, &filespace);             `❹  
> `73  `  
> `   < ... skipping verification code ... >`  
> `105  `  
> `106   free(data);`  
> `107   free(data_restore);`  
> `108  `  
> `109   MPI_Comm_free(&mpi_io_comm);`  
> `110   MPI_Comm_free(&mpi_row_comm);`  
> `111   MPI_Comm_free(&mpi_col_comm);`  
> `112   MPI_Finalize();`  
> `113   return 0;`  
> `114 }`

❶ Initializes and sets up the data types

❷ Writes out the data

❸ Reads the data

❹ Closes the file and frees the data types

This setup takes a little explanation. This code supports the ability to write out more than one MPI data file. This is commonly called NxM file writes where N processes write out M files and where M is greater than one but much smaller than the number of processes (figure 16.4). The reason for this technique is that at larger problem sizes, writing to a single file does not always scale well.

**Figure 16.4 At large sizes, the processes can be broken up into communication groups by colors so they write out to separate files. The ranks of the subgroups are in the same order as the ranks in the original communicator.**

We can break up the processes into groups by colors as shown in figure 16.4. In lines 1722 in listing 16.4, we set up a new communicator based on M colors, where M is the number of files. The number of files is set on line 19 and our color is computed on lines 20 and 21. We use a floating-point type for `ranks_per_file` to handle an uneven division of the ranks. We then get our new rank within our color. Each communication group on the right side of figure 16.4 has 4,096 processes or ranks. The order of the ranks is the same as in the global communication group. If there is more than one file, the filenames include a color number on lines 59-64. This code currently only sets one color and only writes one file as shown on the left side of figure 16.4, but it is written to support more files.

We also need to know where the starting x and y values are for each process. For data decompositions that have the same number of rows and columns for each process, the calculation only needs to know the location of the process in the global set. But when the number of rows and columns varies across processes, we need to sum all the sizes below our position. As we have previously discussed in section 5.6, this operation is a common parallel pattern called a scan. To do this calculation, in lines 22-34 we create communicators for each row and column. These perform an exclusive scan operation to get the starting location of x and y for each process. In this code, we only partition the data in the x-coordinate direction to keep it a little simpler. The global and process sizes in the array `subsizes` are set in lines 27-44. This includes the data offsets calculated using the exclusive scans.

Now that we have all the necessary information about the data decomposition, we can call our `mpi_io_file_init` subroutine on line 52 to set up the MPI data types for the memory and filesystem layout. This only has to be done once, at startup. We are then free to call our subroutines for writes, `write_mpi_io_file`, and reads, `read_mpi_ io_file`, on lines 63 and 65. We can call these as many times as needed during the run. In our example code, we then verify the data read in, compare it to the original data, and print an error if it occurs. Finally, we open the file on a single process and use a standard C binary read to show how the data is laid out in the file. This is done by reading each value from the file in sequential order and printing it out.

Now to compile and run the example. The build is a standard CMake build, and we’ll run it on four processors.

> `mkdir build && cd build`  
> `cmake ..`  
> `make`  
> `mpirun -n 4 ./mpi_io_block2d`

Figure 16.5 shows the output from a standard C binary read for the 10×10 grid on each processor.

**Figure 16.5 Output from a small binary read code for the MPI-IO shows what the file contains. With MPI-IO, we had to write a small utility to check the file contents.**

***16.4 HDF5 is self-describing for better data management***

With traditional data file formats, the data is meaningless without the code that is used to write and read the file. The Hierarchical Data Format (HDF), version 5, takes a different approach. HDF5 provides a self-describing parallel data format. HDF5 is called self-describing because the name and characteristics are stored in the file with the data. In HDF5, with the description of the data contained in the file, you no longer need the source code and can read the data by just querying the file. HDF5 also has a rich set of command-line utilities (such as h5ls and h5dump) that you can use to query the contents of a file. You will find that the utilities are useful when checking that your files are properly written.

We want to write data in binary format because of speed and precision. But because it is in binary format, it is difficult to check if the data is correctly written. If we read the data back in, the problem could be in the reading process as well. A utility that can query the file provides a way to check the write operation separately from the read. In figure 16.4 in the previous section on MPI-IO, we needed a small program to read the contents of the file. For HDF5, it is unnecessary because the utility is already provided. In figure 16.6 (shown later in this section), we used the h5dump command-line utility to look at the contents. You can avoid the need to write code for many common operations by using the already existing HDF5 utilities.

The parallel HDF5 code is implemented by using MPI-IO. Because it is built on MPI-IO, the structure of HDF5 is similar. Although similar, the terminology and individual function calls are different enough to cause some difficulty. We’ll cover the functions that are needed to write a similar parallel file-handling routine as we did for MPI-IO. The HDF5 library is divided into lower-level functionality groupings. These functional groups are conveniently distinguished by prefixes for all of the calls in the group. The first group is the obligatory file handling operations (table 16.4) that collectively handle file open and close operations.

**Table 16.4 HDF5 collective file routines**

**Command**

**Description**

`H5Fcreate`

Collective file open that will create the file if it doesn’t exist

`H5Fopen`

Collective file open of a file that already exists

`H5Fclose`

Collective file close

Next, we need to define new memory types. These are used to specify the portions of data to write and their layout. In HDF5, these memory types are called dataspaces. The dataspace operations in table 16.5 include ways to extract patterns from a multidimensional array. You can find information on the many additional routines in the further reading section at the end of the chapter (16.7.1).

**Table 16.5 HDF5 dataspace routines**

**Command**

**Description**

`H5Screate_simple`

Creates a multidimensional array type

`H5Sselect_hyperslab`

Creates a hyperslab region type of parts of a multidimensional array

`H5Sclose`

Releases a dataspace

There are other dataspace operations, including point-based operations, that we haven’t covered here. Now we need to apply these dataspaces to a set of multidimensional arrays (table 16.6). In HDF5, a multidimensional array is called a dataset, which is generally a multidimensional array or some other form of data within the application.

**Table 16.6 HDF5 dataset routines**

**Command**

**Description**

`H5Dcreate2`

Creates the space for a dataset in the file

`H5Dopen2`

Opens an existing dataset as described within the file

`H5Dclose`

Closes the dataset within the file

`H5Dwrite`

Writes a dataset to the file using `filespace` and `memspace`

`H5Dread`

Reads a dataset from the file using `filespace` and `memspace`

There is only one operation group left that we need. This group, called property lists, gives you a way to modify or supply hints to operations as table 16.7 shows. We can use property lists for setting attributes to use collective operations with reads or writes. Property lists can also be used to pass hints to the underlying MPI-IO library.

**Table 16.7 HDF5 property list routines**

**Command**

**Description**

`H5Pcreate`

Creates a property list

`H5Pclose`

Frees a property list

`H5Pset_dxpl_mpio`

Sets the data transfer property list

`H5Pset_coll_metadata_write`

Sets the collective metadata writes for all processes in a group

`H5Pset_fapl_mpio`

Stores the MPI-IO properties to the file-access property list

`H5Pset_all_coll_metadata_ops`

Sets the parallel metadata read operations in the file access property list

Let’s move on to an example. We start this HDF5 example with the code to create the file and the memory dataspaces. The following listing shows this process. All the arguments to HDF5 are bolded in the listing.

**Listing 16.5 Setting up HDF5 dataspace types**

> `HDF5Examples/hdf5block2d/hdf5_file_ops.c`  
> `11 void hdf5_file_init(int ng, int ndims, int ny_global, int nx_global,`  
> `12     int ny, int nx, int ny_offset, int nx_offset, MPI_Comm mpi_hdf5_comm,`  
> `13     hid_t *memspace, hid_t *filespace){`  
> `14   // create data descriptors on disk and in memory`  
> `15   *filespace = create_hdf5_filespace(ndims,                `❶  
> `        ny_global, nx_global, ny, nx,                         `❶  
> `16      ny_offset, nx_offset, mpi_hdf5_comm);                 `❶  
> `17   *memspace  =`  
> `          create_hdf5_memspace(ndims ny, nx, ng);             `❷  
> `18 }`  
> `19`  
> `20 hid_t create_hdf5_filespace(int ndims, int ny_global, int nx_global,`  
> `21     int ny, int nx, int ny_offset, int nx_offset,`  
> `       MPI_Comm mpi_hdf5_comm){`  
> `22   // create the dataspace for data stored on disk`  
> `     //    using the hyperslab call`  
> `23   hsize_t `**`dims[] = {ny_global, nx_global};`**  
> `24`  
> `25   `**`hid_t filespace = H5Screate_simple(ndims,`**`                `❸  
> `                      `` `**`dims, NULL);`**`                           `❸  
> `26`  
> `27   // determine the offset into the filespace for the current process`  
> `28   hsize_t  `**`start[] = {ny_offset, nx_offset};`**  
> `29   hsize_t `**`stride[] = {1,         1};`**  
> `30   hsize_t  `**`count[] = {ny,        nx};`**  
> `31`  
> `32   `**`H5Sselect_hyperslab(filespace, H5S_SELECT_SET,`**`           `❹  
> `33                 `**`start, stride, count, NULL);`**`               `❹  
> `34   return filespace;`  
> `35 }`  
> `36`  
> `37 hid_t create_hdf5_memspace(int ndims, int ny, int nx, int ng) {`  
> `38   // create a memory space in memory using the hyperslab call`  
> `39   hsize_t `**`dims[] = {ny+2*ng, nx+2*ng};`**  
> `40`  
> `41   `**`hid_t memspace = H5Screate_simple(ndims, dims, NULL);`**`    `❺  
> `42`  
> `43   // select the real data out of the array`  
> `44   hsize_t  `**`start[] = {ng,   ng};`**  
> `45   hsize_t `**`stride[] = {1,    1};`**  
> `46   hsize_t  `**`count[] = {ny,   nx};`**  
> `47`  
> `48   `**`H5Sselect_hyperslab(memspace, H5S_SELECT_SET,`**`            `❻  
> `49                       `**`start, stride, count, NULL);`**`         `❻  
> `50   return memspace;`  
> `51 }`  
> `52`  
> `53 void hdf5_file_finalize(hid_t *memspace, hid_t *filespace){`  
> `54   H5Sclose(*memspace);`  
> `55   *memspace = H5S_NULL;`  
> `56   H5Sclose(*filespace);`  
> `57   *filespace = H5S_NULL;`  
> `58 }`

❶ Creates the file dataspace

❷ Creates the memory dataspace

❸ Creates the filespace object

❹ Selects the filespace hyperslab

❺ Creates the memspace object

❻ Creates the memspace hyperslab

In listing 16.5, we used the same pattern when creating the two dataspaces: create the data object, set the data size arguments, and then select a rectangular region of the array. First, we created the global array space with the `H5Screate_simple` call. For the file dataspace, we set the dimensions to the global array size of `nx_global` and `ny_global` on line 23 and then used those sizes on line 25 to create the dataspace. We then selected a region of the file dataspace for each processor with the `H5Sselect _hyperslab` calls on lines 32 and 48. A similar process is then done for the memory dataspace.

Now that we have the dataspaces, the process of writing out the data into the file is straightforward. We open the file, create the dataset, and write it. If there are more datasets, we continue to write these out, and when finished, we close the file. The following listing shows how this is done.

**Listing 16.6 Writing to an HDF5 file**

> `HDF5Examples/hdf5block2d/hdf5_file_ops.c`  
> `60 void write_hdf5_file(const char *filename, double **data1,`  
> `61     hid_t memspace, hid_t filespace, MPI_Comm mpi_hdf5_comm) {`  
> `62   hid_t file_identifier = create_hdf5_file(                          `❶  
> `        filename, mpi_hdf5_comm);                                        `❶  
> `63`  
> `64   // Create property list for collective dataset write.`  
> `65   hid_t xfer_plist = H5Pcreate(H5P_DATASET_XFER);`  
> `66   H5Pset_dxpl_mpio(xfer_plist, H5FD_MPIO_COLLECTIVE);`  
> `67`  
> `68   hid_t dataset1 = create_hdf5_dataset(                              `❷  
> `         file_identifier, filespace);                                    `❷  
> `69   //hid_t dataset2 = create_hdf5_dataset(file_identifier, filespace);`  
> `70`  
> `71   // write the data to disk using both the memory space`  
> `      //   and the data space.`  
> `72   H5Dwrite(dataset1, H5T_IEEE_F64LE,                                 `❸  
> `         memspace, filespace, xfer_plist,                                `❸  
> `73      &(data1[0][0]));                                                `❸  
> `74   //H5Dwrite(dataset2, H5T_IEEE_F64LE,`  
> `      //       memspace, filespace, xfer_plist,`  
> `75   //       &(data2[0][0]));`  
> `76`  
> `77   H5Dclose(dataset1);`  
> `78   //H5Dclose(dataset2);`  
> `79`  
> `80   H5Pclose(xfer_plist);`  
> `81`  
> `82   H5Fclose(file_identifier);                                         `❹  
> `83 }`  
> `84`  
> `85 hid_t create_hdf5_file(const char *filename, MPI_Comm mpi_hdf5_comm){`  
> `86   hid_t file_creation_plist = H5P_DEFAULT;                           `❺  
> `87   // set the file access template for parallel IO access`  
> `88   hid_t file_access_plist   = H5P_DEFAULT;                           `❻  
> `89   file_access_plist = H5Pcreate(H5P_FILE_ACCESS);`  
> `90`  
> `91   // set collective mode for metadata writes`  
> `92   H5Pset_coll_metadata_write(file_access_plist, true);`  
> `93`  
> `94   MPI_Info mpi_info = MPI_INFO_NULL;                                 `❼  
> `95   MPI_Info_create(&mpi_info);`  
> `96   MPI_Info_set(mpi_info, "striping_factor", "8");`  
> `97   MPI_Info_set(mpi_info, "striping_unit", "4194304");`  
> `98`  
> `99   // tell the HDF5 library that we want to use MPI-IO to do the writing`  
> `100   H5Pset_fapl_mpio(file_access_plist, mpi_hdf5_comm, mpi_info);`  
> `101`  
> `102   // Open the file collectively`  
> `103   // H5F_ACC_TRUNC - overwrite existing file.`  
> `      //    H5F_ACC_EXCL - no overwrite`  
> `104   // 3rd argument is file creation property list. Using default here`  
> `105   // 4th argument is the file access property list identifier`  
> `106   hid_t file_identifier = H5Fcreate(filename,                        `❽  
> `107      H5F_ACC_TRUNC, file_creation_plist,                             `❽  
> `         file_access_plist);                                             `❽  
> `108`  
> `109   // release the file access template`  
> `110   H5Pclose(file_access_plist);`  
> `111   MPI_Info_free(&mpi_info);`  
> `112`  
> `113   return file_identifier;`  
> `114 }`  
> `115`  
> `116 hid_t create_hdf5_dataset(hid_t file_identifier, hid_t filespace){`  
> `117   // create the dataset`  
> `118   hid_t link_creation_plist    = H5P_DEFAULT;                        `❾  
> `119   hid_t dataset_creation_plist = H5P_DEFAULT;                        `❿  
> `120   hid_t dataset_access_plist   = H5P_DEFAULT;                        `⓫  
> `121   hid_t dataset = H5Dcreate2(                                        `⓬  
> `122     file_identifier,          // Arg 1: file identifier`  
> `123     "data array",             // Arg 2: dataset name`  
> `124     H5T_IEEE_F64LE,           // Arg 3: datatype identifier`  
> `125     filespace,                // Arg 4: filespace identifier`  
> `126     link_creation_plist,      // Arg 5: link creation property list`  
> `127     dataset_creation_plist,   // Arg 6: dataset creation property list`  
> `128     dataset_access_plist);    // Arg 7: dataset access property list`  
> `129`  
> `130   return dataset;`  
> `131 }`

❶ Calls the subroutine to create the file

❷ Calls the subroutine to create the dataset

❸ Writes the dataset

❹ Closes the objects and the data file

❺ Creates file creation property list

❻ Creates file access property

❼ Creates MPI IO hints

❽ HDF5 routine creates the file.

❾ Creates the link creation property list

❿ Creates the dataset creation property list

⓫ Creates the dataset access property list

⓬ HDF5 routine creates the dataset.

In listing 16.6, the main `write_hdf5_file` routine uses the `filespace` dataspace that we created in listing 16.5. We then wrote out the dataset with the `H5Dwrite` routine on line 72, using both the `memspace` and `filespace` dataspaces. We also created and passed in a property list to tell HDF5 to use collective MPI-IO routines. Finally, on line 82, we closed the file. We also closed the property list and dataset on previous lines to avoid memory leaks. For the routine to create the file, we finally call `H5Fcreate` on line 106, but we need several lines to set up the hints. We wrapped the property list setup for the collective write and the MPI-IO hints along with the call and put these into a separate routine. We also took the same approach with the HDF5 call on line 121 for creating the dataset so we could detail the different property lists that you can use.

The routine to read the HDF5 data file, shown in the following listing, has the same basic pattern as the earlier write operation. The biggest difference between this listing and listing 16.6 is that there are fewer hints and attributes needed.

**Listing 16.7 Reading an HDF5 file**

> `HDF5Examples/hdf5block2d/hdf5_file_ops.c`  
> `135 void read_hdf5_file(const char *filename, double **data1,`  
> `136     hid_t memspace, hid_t filespace, MPI_Comm mpi_hdf5_comm) {`  
> `137   hid_t file_identifier =                                         `❶  
> `         open_hdf5_file(filename, mpi_hdf5_comm);                     `❶  
> `138`  
> `139   // Create property list for collective dataset write.`  
> `140   hid_t xfer_plist = H5Pcreate(H5P_DATASET_XFER);`  
> `141   H5Pset_dxpl_mpio(xfer_plist, H5FD_MPIO_COLLECTIVE);`  
> `142`  
> `143   hid_t dataset1 =`  
> `            open_hdf5_dataset(file_identifier);                       `❷  
> `144   // read the data from disk using both the memory space`  
> `      //    and the data space.`  
> `145   H5Dread(dataset1, H5T_IEEE_F64LE, memspace,                     `❸  
> `146      filespace, H5P_DEFAULT, &(data1[0][0]));                     `❸  
> `147   H5Dclose(dataset1);`  
> `148`  
> `149   H5Pclose(xfer_plist);`  
> `150`  
> `151   H5Fclose(file_identifier);                                      `❹  
> `152 }`  
> `153`  
> `154 hid_t open_hdf5_file(const char *filename, MPI_Comm mpi_hdf5_comm){`  
> `155   // set the file access template for parallel IO access`  
> `156   hid_t file_access_plist = H5P_DEFAULT;   // File access property list`  
> `157   file_access_plist = H5Pcreate(H5P_FILE_ACCESS);`  
> `158`  
> `159   // set collective mode for metadata reads (ops)`  
> `160   H5Pset_all_coll_metadata_ops(file_access_plist, true);`  
> `161`  
> `162   // tell the HDF5 library that we want to use MPI-IO to do the reading`  
> `163   H5Pset_fapl_mpio(file_access_plist, mpi_hdf5_comm, MPI_INFO_NULL);`  
> `164`  
> `165   // Open the file collectively`  
> `166   // H5F_ACC_RDONLY - sets access to read or write`  
> `      //    on open of an existing file.`  
> `167   // 3rd argument is the file access property list identifier`  
> `168   hid_t file_identifier = H5Fopen(filename,                       `❺  
> `         H5F_ACC_RDONLY, file_access_plist);                          `❺  
> `169`  
> `170   // release the file access template`  
> `171   H5Pclose(file_access_plist);`  
> `172`  
> `173   return file_identifier;`  
> `174 }`  
> `175`  
> `176 hid_t open_hdf5_dataset(hid_t file_identifier){`  
> `177   // open the dataset`  
> `178   hid_t dataset_access_plist = H5P_DEFAULT;                       `❻  
> `179   hid_t dataset = H5Dopen2(                                       `❼  
> `180     file_identifier,        // Arg 1: file identifier`  
> `181     "data array",           // Arg 2: dataset name to match for read`  
> `182     dataset_access_plist);  // Arg 3: dataset access property list`  
> `183`  
> `184   return dataset;`  
> `185 }`

❶ Calls the subroutine to open the file

❷ Calls the subroutine to create the dataset

❸ Reads the dataset

❹ Closes the objects and the data file

❺ HDF5 routine opens the file.

❻ Creates dataset access property list

❼ HDF5 routine creates the dataset.

Because the file already exists, we use an open call on line 168 in listing 16.7 to specify read-only mode. (Using read-only mode allows additional optimizations.) The accessed file already has some attributes that were specified during the write. Some of these attributes do not need to be specified in the read. The HDF5 listings so far might comprise a general-purpose library within an application. The next listing shows the calls that would be placed at different points in the main application.

**Listing 16.8 Main application file**

> `HDF5Examples/hdf5block2d/hdf5block2d.c`  
> `52   hid_t memspace = H5S_NULL, filespace = H5S_NULL;`  
> `53   hdf5_file_init(ng, ndims, ny_global,                     `❶  
> `         nx_global, ny, nx, ny_offset, nx_offset,              `❶  
> `54      mpi_hdf5_comm, &memspace, &filespace);                `❶  
> `55`  
> `56   char filename[30];`  
> `57   if (ncolors > 1) {`  
> `58     sprintf(filename,"example_%02d.hdf5",color);`  
> `59   } else {`  
> `60     sprintf(filename,"example.hdf5");`  
> `61   }`  
> `62`  
> `63   // Do the computation and write out a sequence of files`  
> `64   write_hdf5_file(filename, data, memspace,                `❷  
> `                      filespace, mpi_hdf5_comm);               `❷  
> `65   // Read back the data for verifying the file operations`  
> `66   read_hdf5_file(filename, data_restore,                   `❸  
> `           memspace, filespace, mpi_hdf5_comm);                `❸  
> `67`  
> `68   hdf5_file_finalize(&memspace, &filespace);               `❹

❶ Sets up the memory and file dataspaces

❷ Writes the HDF5 data file

❸ Reads in the data from the HDF5 data file

❹ Frees the dataspace objects

In listing 16.8, the initialization operation to set up the dataspaces on line 53 can be done once, at the start of your program. Then you might write out the data in your program at periodic intervals for graphics and checkpointing. The read would then typically be done when restarting from a checkpoint at the start of a run. Lastly, the finalize call should be done at the end of the program before terminating the calculation. Now to compile and run the example. The build is a standard CMake build. We’ll run it on four processors:

> `mkdir build && cd build`  
> `cmake ..`  
> `make`  
> `mpirun -n 4 ./hdf5block2d`

In a single install, the HDF5 package can be either installed as a parallel or as a serial version but not both. A common problem is to link the wrong version into your application. We added some special code to the CMake build system to preferentially select a parallel version as the next listing shows. The program then fails if the HDF5 version is not parallel so that we don’t get an error during the build.

**Listing 16.9 Checking for a parallel HDF5 package**

> `HDF5Examples/hdf5block2d/CMakeLists.txt`  
> `14 set(HDF5_PREFER_PARALLEL true)`  
> `15 find_package(HDF5 1.10.1 REQUIRED)`  
> `16 if (NOT HDF5_IS_PARALLEL)`  
> `17     message(FATAL_ERROR " -- HDF5 version is not parallel.")`  
> `18 endif (NOT HDF5_IS_PARALLEL)`

The example code does a verification test to check that the data read back from the file is the same as the data that we started with. We can also use the h5dump utility to print the data in the file. You can use the following command to look at your data file. Figure 16.6 shows the output from the command.

> `h5dump -y example.hdf5`

**Figure 16.6 Using the h5dump command-line utility shows what is contained in the HDF5 file without having to write any code.**

***16.5 Other parallel file software packages***

In this section, we briefly cover a couple of the more common parallel file software packages: PnetCDF and Adios. PnetCDF, short for Parallel Network Common Data Form, is another self-describing data format that is popular in the Earth Systems community and among organizations funded by the National Science Foundation (NSF). While originally a completely separate software source, the parallel version is built on top of HDF5 and MPI-IO. The decision of whether to use PnetCDF or HDF5 is strongly influenced by your community. Because the files generated by your application are often used by others, using the same data standard is important.

ADIOS, or the Adaptable Input/Output System, is also a self-describing data format from Oak Ridge National Laboratory (ORNL). ADIOS has its own native binary format, but it can also use HDF5, MPI-IO, and other file-storage software.

***16.6 Parallel filesystem: The hardware interface***

With increasing data demands, more complex filesystems become necessary. In this section, we will introduce these parallel filesystems. A parallel filesystem can greatly speed up file writes and reads by spreading out the operations across several hard disks with multiple file writers or readers. While we now have some parallelism at the filesystem, it is not a simple situation. There is still a mismatch between the application parallelism and the parallelism provided by the filesystem. Because of this, the management of the parallel operations is complex and highly dependent on the hardware configurations and application demands. To deal with the complexity, many of the parallel filesystems use an object-based file structure. Object-based filesystems are a natural fit for these challenges. But the performance and robustness of the parallel filesystem is often limited by the metadata describing the locations of the file data.

> > > **DEFINITION** Object-based filesystem is a system that’s organized based on objects rather than on files in a folder. An object-based filesystem requires a database or metadata to store all the information describing the object.

The writing of parallel file operations is highly intertwined with the parallel filesystem software. This requires the knowledge of which parallel filesystem is being used and the settings available for that installation and filesystem. Tuning your parallel file software can sometimes yield significant performance gains.

***16.6.1 Everything you wanted to know about your parallel file setup but didn’t know how to ask***

As you get into the interaction of the parallel file operations with the filesystem, it is helpful to see more information about the parallel library settings. The settings can be set differently for each installation. You can also get some high-level statistics that can help with debugging performance issues.

Most MPI-IO libraries are one of two implementations, either ROMIO, which is distributed with MPICH and many system vendor implementations, or OMPIO, which is the default on newer versions of OpenMPI. Let’s first go over how to get information from OpenMPI’s OMPIO plugin or how to switch back to using ROMIO. To extract information on OpenMPI’s OMPIO settings, use the following commands:

- `—mca io [ompio|romio]`

- Specifies the IO plugin, either OMPIO or ROMIO. Older releases use ROMIO as the default plugin, while OMPIO is the default on newer releases.

- `ompi_info—param <component> <plugin>—level <int>`

- Displays information on the local OpenMPI configuration for that plugin.

- `—mca io_ompio_verbose_info_parsing 1`

- Shows the hints parsed from a program's `MPI_Info_set` calls.

First, you can get the names of the IO plugins with the `ompi_info` command. We just want the IO component plugins, so we filter the output for these:

> `ompi_info |grep "MCA io:"`  
> `MCA io: romio321 (MCA v2.1.0, API v2.0.0, Component v4.0.3)`  
> `MCA io: ompio (MCA v2.1.0, API v2.0.0, Component v4.0.3)`

Then you can get the individual settings available for each plugin. Using the `ompi_info` command, we get the following abbreviated output:

> `ompi_info --param io ompio --level 9 | grep ": parameter"`  
>   
> `MCA io ompio: parameter "io_ompio_priority" (current value: "30" ...`  
> `MCA io ompio: parameter "io_ompio_delete_priority" (current value: "30" ...`  
> `MCA io ompio: parameter "io_ompio_record_file_offset_info" (current value: "0" ...`  
> `MCA io ompio: parameter "io_ompio_coll_timing_info" (current value: "1" ...`  
> `MCA io ompio: parameter "io_ompio_cycle_buffer_size" (current value: "536870912" ...`  
> `MCA io ompio: parameter "io_ompio_bytes_per_agg" (current value: "33554432" ...`  
> `MCA io ompio: parameter "io_ompio_num_aggregators" (current value: "-1" ...`  
> `MCA io ompio: parameter "io_ompio_grouping_option" (current value: "5" ...`  
> `MCA io ompio: parameter "io_ompio_max_aggregators_ratio" (current value: "8" ...`  
> `MCA io ompio: parameter "io_ompio_aggregators_cutoff_threshold" (current value: "3" ...`  
> `MCA io ompio: parameter "io_ompio_overwrite_amode" (current value: "1" ...`  
> `MCA io ompio: parameter "io_ompio_verbose_info_parsing" (current value: "0"`  
> `...`

You can also verify how the `MPI_Info_set` calls are interpreted by the MPI-IO library with the following run-time option. This can be a good way to check that your code is correctly written for your filesystem and parallel file operation libraries.

> `mpirun --mca io_ompio_verbose_info_parsing 1 -n 4 ./mpi_io_block2d`  
> `File: example.data info: collective_buffering value true enforcing using individual fcoll component`  
> `< ... repeated three more times ... >`

For the ROMIO parallel file software included with MPICH, we have different mechanisms to query the software installation. Cray adds some additional environment variables for their implementations of ROMIO. We’ll list some of these and then see examples that use these.

- ROMIO recognizes the following hint:

- - `ROMIO_PRINT_HINTS=1`

- Cray provides these additional environment variables:

- - `MPICH_MPIIO_HINTS_DISPLAY=1`

  - `MPICH_MPIIO_STATS=1`

  - `MPICH_MPIIO_TIMERS=1`

The following shows the output when using `ROMIO_PRINT_HINTS`:

> `export ROMIO_PRINT_HINTS=1; mpirun -n 4 ./mpi_io_block2d`  
> `key = cb_buffer_size            value = 16777216 `  
> `key = romio_cb_read             value = automatic`  
> `key = romio_cb_write            value = automatic`  
> `key = cb_nodes                  value = 1        `  
> `key = romio_no_indep_rw         value = false    `  
> `key = romio_cb_pfr              value = disable  `  
> `key = romio_cb_fr_types         value = aar      `  
> `key = romio_cb_fr_alignment     value = 1        `  
> `key = romio_cb_ds_threshold     value = 0        `  
> `key = romio_cb_alltoall         value = automatic`  
> `key = ind_rd_buffer_size        value = 4194304  `  
> `key = ind_wr_buffer_size        value = 524288   `  
> `key = romio_ds_read             value = automatic`  
> `key = romio_ds_write            value = automatic`  
> `key = striping_unit             value = 4194304  `  
> `key = cb_config_list            value = *:1      `  
> `key = romio_filesystem_type     value = NFS:     `  
> `key = romio_aggregator_list     value = 0        `  
> `key = cb_buffer_size            value = 16777216 `  
> `key = romio_cb_read             value = automatic`  
> `key = romio_cb_write            value = automatic`  
> `key = cb_nodes                  value = 1        `  
> `key = romio_no_indep_rw         value = false    `  
> `key = romio_cb_pfr              value = disable  `  
> `key = romio_cb_fr_types         value = aar      `  
> `key = romio_cb_fr_alignment     value = 1        `  
> `key = romio_cb_ds_threshold     value = 0        `  
> `key = romio_cb_alltoall         value = automatic`  
> `key = ind_rd_buffer_size        value = 4194304  `  
> `key = ind_wr_buffer_size        value = 524288   `  
> `key = romio_ds_read             value = automatic`  
> `key = romio_ds_write            value = automatic`  
> `key = cb_config_list            value = *:1      `  
> `key = romio_filesystem_type     value = NFS:     `  
> `key = romio_aggregator_list     value = 0`  
>   
> `export MPICH_MPIIO_HINTS_DISPLAY=1; srun -n 4 ./mpi_io_block2d`  
> `PE 0: MPICH MPIIO environment settings:`  
> `PE 0:   MPICH_MPIIO_HINTS_DISPLAY                 = 1`  
> `PE 0:   MPICH_MPIIO_HINTS                         = NULL`  
> `PE 0:   MPICH_MPIIO_ABORT_ON_RW_ERROR             = disable`  
> `PE 0:   MPICH_MPIIO_CB_ALIGN                      = 2`  
> `PE 0:   MPICH_MPIIO_DVS_MAXNODES                  = -1`  
> `PE 0:   MPICH_MPIIO_AGGREGATOR_PLACEMENT_DISPLAY  = 0`  
> `PE 0:   MPICH_MPIIO_AGGREGATOR_PLACEMENT_STRIDE   = -1`  
> `PE 0:   MPICH_MPIIO_MAX_NUM_IRECV                 = 50`  
> `PE 0:   MPICH_MPIIO_MAX_NUM_ISEND                 = 50`  
> `PE 0:   MPICH_MPIIO_MAX_SIZE_ISEND                = 10485760`  
> `PE 0: MPICH MPIIO statistics environment settings:`  
> `PE 0:   MPICH_MPIIO_STATS                         = 0`  
> `PE 0:   MPICH_MPIIO_TIMERS                        = 0`  
> `PE 0:   MPICH_MPIIO_WRITE_EXIT_BARRIER            = 1`  
> `MPIIO WARNING: DVS stripe width of 8 was requested but DVS set it to 1`  
> `See MPICH_MPIIO_DVS_MAXNODES in the intro_mpi man page.`  
> `PE 0: MPIIO hints for example.data:`  
> `          cb_buffer_size           = 16777216`  
> `          romio_cb_read            = automatic`  
> `          romio_cb_write           = automatic`  
> `          cb_nodes                 = 1`  
> `          cb_align                 = 2`  
> `          romio_no_indep_rw        = false`  
> `          romio_cb_pfr             = disable`  
> `          romio_cb_fr_types        = aar`  
> `          romio_cb_fr_alignment    = 1`  
> `          romio_cb_ds_threshold    = 0`  
> `          romio_cb_alltoall        = automatic`  
> `          ind_rd_buffer_size       = 4194304`  
> `          ind_wr_buffer_size       = 524288`  
> `          romio_ds_read            = disable`  
> `          romio_ds_write           = automatic`  
> `          striping_factor          = 1`  
> `          striping_unit            = 4194304`  
> `          direct_io                = false`  
> `          aggregator_placement_stride = -1`  
> `          abort_on_rw_error        = disable`  
> `          cb_config_list           = *:*`  
> `          romio_filesystem_type    = CRAY ADIO:`  
>   
> `export MPICH_MPIIO_STATS=1; srun -n 4 ./mpi_io_block2d`  
> `+--------------------------------------------------------+`  
> `| MPIIO write access patterns for example.data`  
> `|   independent writes      = 0`  
> `|   collective writes       = 4`  
> `|   independent writers     = 0`  
> `|   aggregators             = 1`  
> `|   stripe count            = 1`  
> `|   stripe size             = 4194304`  
> `|   system writes           = 2`  
> `|   stripe sized writes     = 0`  
> `|   aggregators active      = 4,0,0,0 (1, <= 1, > 1, 1)`  
> `|   total bytes for writes  = 3600`  
> `|   ave system write size   = 1800`  
> `|   read-modify-write count = 0`  
> `|   read-modify-write bytes = 0`  
> `|   number of write gaps    = 0`  
> `|   ave write gap size      = NA`  
> `| See "Optimizing MPI I/O on Cray XE Systems" S-0013-20 for explanations.`  
> `+--------------------------------------------------------+`  
> `+--------------------------------------------------------+`  
> `| MPIIO read access patterns for example.data`  
> `|   independent reads       = 0`  
> `|   collective reads        = 4`  
> `|   independent readers     = 0`  
> `|   aggregators             = 1`  
> `|   stripe count            = 1`  
> `|   stripe size             = 524288`  
> `|   system reads            = 1`  
> `|   stripe sized reads      = 0`  
> `|   total bytes for reads   = 3200`  
> `|   ave system read size    = 3200`  
> `|   number of read gaps     = 0`  
> `|   ave read gap size       = NA`  
> `| See "Optimizing MPI I/O on Cray XE Systems" S-0013-20 for explanations.`  
> `+--------------------------------------------------------+`

***16.6.2 General hints that apply to all filesystems***

It is sometimes useful to give some hints about the type of file operations you will use in your application. You can modify the parallel file settings with environment variables, a hints file, or at run time with `MPI_Info_set`. This provides the appropriate method for handling different scenarios if you don’t have access to the program source to add the `MPI_Info_set` command. To set parallel file options in this case, use the following commands:

- Cray MPICH

> > > > `MPICH_MPIIO_HINTS=”*:<key>=<value>:<key>=<value>`

> > > For example

> > > > `export MPICH_MPIIO_HINTS=\`  
> > > > `   ”*:striping_factor=8:striping_unit=4194304”`

- ROMIO

> > > > `ROMIO_HINTS=<filename> `

> > > For example: `ROMIO_HINTS=romio-hints`

> > > where the romio-hints file includes

> > > > `striping_factor 8      // file is broken into 8 parts and`  
> > > > `                       // is written in parallel to 8 disks`  
> > > > `striping_unit 4194304  // the size in bytes of each`  
> > > > `                       // block to be written`

- OpenMPI OMPI

> > > > `OMPI_MCA_<param_name> <value> `

> > > For example: `export OMPI_MCA_io_ompio_verbose_info_parsing=1`

The OpenMPI mca run-time option as an argument to the mpirun command is

> `mpirun—mca io_ompio_verbose_info_parsing 1 -n 4 <exec>`

The default location of the OpenMPI file is in \$HOME/.openmpi/mca-params.conf or it can be set with the following:

> `--tune <filename>`  
> `mpirun --tune mca-params.conf -n 2 <exec>`

The most important hint that you can set is whether to use collective operations or data sieving. We’ll first look at the collective operations and then the data sieving operations.

Collective operations harness MPI collective communication calls and use a two-phase I/O approach that collects the data for aggregators that then write or read from your file. Use the following commands for collective I/O:

- ROMIO and OMPIO

- - `cb_buffer_size=integer` specifies the buffer size in bytes for a two-phase collective I/O. It should be a multiple of the page size.

  - `cb_nodes=integer` sets the maximum number of aggregators.

- ROMIO only

- - `romio_cb_read=[enable|automatic|disable]` specifies when to use collective buffering for reads.

  - `romio_cb_write=[enable|automatic|disable]` specifies when to use collective buffering for writes.

  - `cb_config_list=*:<integer>` sets the number of aggregators per node.

  - `romio_no_indep_rw=[true|false]` specifies whether to use any independent I/O. If none are allowed, no file operations (including file open) will be done on non-aggregator nodes.

- OMPIO only

- - `collective_buffering=[true|false]` uses collective operations when writing from a parallel job to the filesystem.

Data sieving does a single read (or write), spanning a file block and then parcels out the data to the individual process reads. This avoids a lot of smaller reads and the contention between file readers that might occur. Use the following commands for data sieving with ROMIO:

- `romio_ds_read=[enable|automatic|disable]`

- `romio_ds_write=[enable|automatic|disable]`

- `ind_rd_buffer_size=integer` (bytes for read buffer)

- `ind_wr_buffer_size=integer` (bytes for write buffer)

***16.6.3 Hints specific to particular filesystems***

Some hints only apply to a particular filesystem, such as Lustre or GPFS. We can detect the filesystem type from within our program and set the appropriate hints for the filesystem. The fs_detect.c program in the examples does this. This program uses the `statfs` command as the next listing shows and you can find it in the examples directory for this chapter.

**Listing 16.10 Filesystem detection program**

> `MPI_IO_Examples/mpi_io_block2d/fs_detect.c`  
> `1 #include <stdio.h>`  
> `2 #ifdef __APPLE_CC__`  
> `3 #include <sys/mount.h>`  
> `4 #else`  
> `5 #include <sys/statfs.h>`  
> `6 #endif`  
> `7 // Filesystem types are listed in the system`  
> `   //   include directory in linux/magic.h`  
> `8 // You will need to add any additional`  
> `   //   parallel filesystem magic codes`  
> `9 #define LUSTRE_MAGIC1     0x858458f6              `❶  
> `10 #define LUSTRE_MAGIC2     0xbd00bd0               `❶  
> `11 #define GPFS_SUPER_MAGIC  0x47504653              `❶  
> `12 #define PVFS2_SUPER_MAGIC 0x20030528              `❶  
> `13 #define PAN_KERNEL_FS_CLIENT_SUPER_MAGIC  \       `❶  
> `                             0xAAD7AAEA              `❶  
> `14`  
> `15 int main(int argc, char *argv[])`  
> `16 {`  
> `17   struct statfs buf;`  
> `18   statfs("./fs_detect", &buf);                    `❷  
> `19   printf("File system type is %lx\n",buf.f_type);`  
> `20 }`

❶ Magic numbers for parallel filesystem type

❷ Gets filesystem type

We included the magic number for some of the parallel filesystems in this listing. When using this for other applications, replace the filename on line 18 with an appropriate filename for the directory where your files are written. Build the fs_detect program and then run the following command to get the filesystem type:

> `mkdir build && cd build`  
> `cmake ..`  
> `make`  
> `` grep `./fs_detect | cut -f 4 -d' '` /usr/include/linux/magic.h ../fs_detect.c ``

Now we are ready for the filesystem-specific hints. We don’t list all the possible hints. You can get the current list by using the commands previously shown.

***LUSTRE FILESYSTEM: THE MOST COMMON FILESYSTEM IN HIGH PERFORMANCE COMPUTING CENTERS***

Lustre is the dominant filesystem on the largest high performance computing systems. Originating at Carnegie Mellon University, its primary development and ownership has been passed through Intel, HP, Sun, Oracle, Intel, Whamcloud, and others. In this process, it has passed from commercial to open source and back. Currently it is under the Open Scalable File Systems (OpenSFS) and European Open File Systems (EOFS) banners.

Lustre is built on the concept of object storage with Object Storage Servers (OSSs) and Object Storage Targets (OSTs). When we specify a `striping_factor` of `8` on line 56 of listing 16.2 and line 96 of listing 16.6, we are telling the ROMIO library to use Lustre to break up the writes (and reads) into eight pieces and send them to eight OSTs, effectively writing out the data in eight-way parallelism. The `striping_unit` hint tells ROMIO and Lustre to use 4 MiB stripe sizes. Lustre also has Metadata Servers (MDS) and Metadata Targets (MDT) to store the critical descriptions of where each part of the file is stored. For striping operations, use the following:

- MPICH (ROMIO)

- - `striping_unit=<integer>` sets the stripe size in bytes.

  - `striping_factor=<integer>` sets the number of stripes, where `-1` is automatic.

- OpenMPI (OMPIO)

- - `fs_lustre_stripe_size=<integer>` sets the stripe size in bytes.

  - `fs_lustre_stripe_width=<integer>` sets the number of stripes, where `-1` is automatic.

We can confirm the Lustre parameters for OpenMPI with a command-line query:

> `ompi_info --param fs lustre --level 9`  
> `MCA fs lustre: parameter "fs_lustre_priority" (current value: "20" ...`  
> `MCA fs lustre: parameter "fs_lustre_stripe_size" (current value: "0" ...`  
> `MCA fs lustre: parameter "fs_lustre_stripe_width" (current value: "0" ...`

***GPFS: A FILESYSTEM FROM IBM***

IBM systems have the General Parallel File System (GPFS), also part of their Spectrum Scale product, that offers striping and parallel file operations on their systems. GPFS is an enterprise storage product with the corresponding support infrastructure and services. GPFS stripes across all available devices by default. The MPI hints may not have as much effect on this filesystem, however. For MPICH (ROMIO), use this command to help with large memory writes/reads:

> `IBM_largeblock_io=true`

***DATAWARP: A FILESYSTEM FROM CRAY***

Cray’s DataWarp integrates burst buffer hardware on top of another parallel filesystem, such as their version of Lustre. Taking advantage of burst buffers is still in its infancy, though, but Cray has been a leader in this effort.

***PANASAS®: A COMMERCIAL FILESYSTEM REQUIRING FEWER HINTS FROM USERS***

Panasas® is a commercial parallel filesystem that is composed of object storage and metadata servers. Panasas has also contributed to the extension to the Network File System (NFS) to support parallel operations. Panasas was used in some of the top-ten computing systems at LANL, although it is not so prevalent there today. For MPICH (ROMIO), use these commands to set the strip size and the number of stripes, respectively:

- `panfs_layout_stripe_unit=<integer>`

- `panfs_layout_total_num_comps=<integer>`

***ORANGEFS (PVFS): THE MOST POPULAR OPEN-SOURCE FILESYSTEM***

OrangeFS, previously known as the Parallel Virtual File System (PVFS), is an open source parallel filesystem from Clemson University and Argonne National Laboratory. It is popular on Beowulf clusters. Besides being a scalable parallel filesystem, OrangeFS has been integrated into the Linux kernel. You can use the following commands for MPICH (ROMIO) to set the stripe size (in bytes) and to number the stripes (with -1 being automatic), respectively:

- `striping_unit=<integer>`

- `striping_factor=<integer>`

***BEEGFS: A NEW OPEN SOURCE FILESYSTEM THAT IS GAINING IN POPULARITY***

BeeGFS, formerly FhGFS, was developed at the Fraunhofer Center for High Performance Computing and is freely available. It is popular because of its open source characteristics.

***DISTRIBUTED APPLICATION OBJECT STORAGE (DAOS): SETTING NEW BENCHMARKS FOR PERFORMANCE***

Intel is developing their new, open source DAOS object-storage technology under the Department of Energy (DOE) FastForward program. DAOS ranks first in the 2020 ISC IO500 supercomputing file-speed list (<https://www.vi4io.org>). It’s scheduled to be deployed on the Aurora supercomputer, Argonne National Laboratory’s first exascale computing system, in 2021. DAOS is supported in the ROMIO MPI-IO library, available with MPICH, and is portable to other MPI libraries.

***WEKAIO: A NEWCOMER FROM THE BIG DATA COMMUNITY***

WekaIO is a fully POSIX-compliant filesystem that provides a large shared namespace with highly optimized performance, low latency, and high bandwidth, and uses the latest solid-state hardware components. WekaIO is an attractive filesystem for applications that require large amounts of high-performing data file manipulation and is popular in the big data community. WekaIO took top honors in the 2019 SC IO500 supercomputing file speed list.

***CEPH FILESYSTEM: AN OPEN SOURCE DISTRIBUTED STORAGE SYSTEM***

Ceph originated at Lawrence Livermore National Laboratory. The development is now led by RedHat for a consortium of industrial partners and has been integrated into the Linux kernel.

***NETWORK FILESYSTEM (NFS): THE MOST COMMON NETWORK FILESYSTEM***

NFS is the dominant cluster filesystem for the networks in local organizations. It is not a recommended system for highly parallel file operations, although with the proper settings, it functions correctly.

***16.7 Further explorations***

Much of the current documentation on parallel file operations is in presentations and academic conferences. One of the best conferences is the Parallel Data Systems Workshop (PDSW), held in conjunction with The International Conference for High Performance Computing, Networking, Storage, and Analysis (otherwise known as the yearly Supercomputing Conference).

You can use the micro benchmarks, IOR and mdtest, to check the best performance of a filesystem. The software is documented at [https://ior.readthedocs.io/en/ latest/](https://ior.readthedocs.io/en/latest/) and hosted by LLNL at <https://github.com/hpc/ior>.

***16.7.1 Additional reading***

The addition of the MPI-IO functions to MPI is described in the following text. It remains one of the best descriptions of MPI-IO.

William Gropp, Rajeev Thakur, and Ewing Lusk. Using MPI-2: Advanced Features of the Message Passing Interface (MIT Press, 1999).

There are a couple of good books on writing high performance parallel file operations. We recommend the following:

- Prabhat and Quincey Koziol, editors, High Performance Parallel I/O (Chapman and Hall/CRC, 2014).

- John M. May, Parallel I/O for High Performance Computing (Morgan Kaufmann, 2001).

The HDF Group maintains the authoritative website on HDF5. You can get more information at

The HDF Group, <https://portal.hdfgroup.org/display/HDF5/HDF5>.

NetCDF remains popular within certain HPC application segments. You can get more information on this format at the NetCDF site hosted by Unidata. Unidata is one of the University Corporation for Atmospheric Research (UCAR)’s Community Programs (UCP).

Unidata, <https://www.unidata.ucar.edu/software/netcdf/>.

A parallel version of NetCDF, PnetCDF, was developed by Northwestern University and Argonne National Laboratory independently from Unidata. More information on PnetCDF is at their GitHub documentation site:

Northwestern University and Argonne National Laboratory, [https://parallel-netcdf .github.io](https://parallel-netcdf.github.io).

ADIOS is one of the leading parallel file operations libraries maintained by a team led by Oak Ridge National Laboratory (ORNL). To learn more, see their documentation at the following website:

Oak Ridge National Laboratory, <https://adios2.readthedocs.io/en/latest/index.html>.

Some good presentations on tuning performance for filesystems include

- Philippe Wautelet, “Best practices for parallel IO and MPI-IO hints” (CRNS/ IDRIS, 2015), [http://www.idris.fr/media/docs/docu/idris/idris_patc_hints\_ proj.pdf](http://www.idris.fr/media/docs/docu/idris/idris_patc_hints_proj.pdf).

- George Markomanolis, ORNL Spectrum Scale (GPFS) [https://www.olcf.ornl .gov/wp-content/uploads/2018/12/spectrum_scale_summit_workshop.pdf](https://www.olcf.ornl.gov/wp-content/uploads/2018/12/spectrum_scale_summit_workshop.pdf).

***16.7.2 Exercises***

1.  Check for the hints available on your system using the techniques described in section 16.6.1.

2.  Try the MPI-IO and HDF5 examples on your system with much larger datasets to see what performance you can achieve. Compare that to the IOR micro benchmark for extra credit.

3.  Use the h5ls and h5dump utilities to explore the HDF5 data file created by the HDF5 example.

***Summary***

- There is a proper way to handle standard file operations for parallel applications. The simple techniques introduced in this chapter, where all IO is performed from the first processor, are sufficient for modest parallel applications.

- The use of MPI-IO is an important building block for parallel file operations. MPI-IO can dramatically speed up the writing and reading of files.

- There are advantages of using the self-describing parallel HDF5 software. The HDF5 format can improve how your application manages data while also getting fast file operations.

- There are ways to query and set the hints for the parallel file software and filesystem. This can improve your file writing and reading performance on particular systems.
