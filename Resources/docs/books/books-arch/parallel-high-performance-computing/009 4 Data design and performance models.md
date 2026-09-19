# 4 Data design and performance models

***4 Data design and performance models***

This chapter covers

- Why real applications struggle to achieve performance
- Addressing kernels and loops that significantly underperform
- Choosing data structures for your application
- Assessing different programming approaches before writing code
- Understanding how the cache hierarchy delivers data to the processor

This chapter has two topics that are intimately coupled: (1) the introduction of performance models increasingly dominated by data movement and, thus, necessarily (2) the underlying design and structure of data. Although it may seem secondary to performance, the data structure and its design are critical. This must be determined in advance because it dictates the entire form of the algorithms, code, and later, the parallel implementation.

The choice of data structures and, thereby, the data layout often determines the performance that you can achieve and in ways that are not always obvious when the design decisions are made. Thinking about the data layout and its performance impacts is at the core of a new and growing programming approach called data-oriented design. This approach considers the patterns of how data will be used in the program and proactively designs around it. Data-oriented design gives us a data-centric view of the world, which is also consistent with our focus on memory bandwidth rather than floating-point operations (flops). In summary, for performance, our approach is to think about

- Data rather than code

- Memory bandwidth rather than flops

- Cache line instead of individual data elements

- Operations prioritized on data already in cache

Simple performance models based on the data structures and the algorithms that naturally follow can roughly predict performance. A performance model is a simplified representation of how a computer system executes the operations in a kernel of code. We use simplified models because reasoning about the full complexity of the computer operation is difficult and obscures the key aspects we need to think about for performance. These simplified models should capture the computer’s operational aspects that are most important for performance. Also, every computer system varies in the details of its operation. Because we want our application to run on a wide range of systems, we need a model that abstracts a general view of the operations that all systems have in common.

A model helps us to understand the current functioning of our kernel performance. It helps build expectations for the performance and how it might improve with changes to the code. Changes to the code can be a lot of work, and we’ll want to know what the result should be before embarking on the effort. It also helps us to focus on the critical factors and resources for our application’s performance.

A performance model is not limited to flops, and indeed, we will focus on the data and memory aspects. In addition to flops and memory operations, integer operations, instructions and instruction types can be important and should be counted. But the limits associated with these additional considerations usually track memory performance and can be treated as a small reduction in the performance from that limit.

The first part of the chapter looks at simple data structures and how these impact performance. Next, we’ll introduce performance models to use for quickly making design decisions. These performance models are then put to use in a case study to look at more complicated data structures for compressed, sparse multi-material arrays to assess which data structure is likely to perform well. The impact of these decisions on data structures often shows up much later in the project when changes are far more difficult. The last portion of this chapter focuses on advanced programming models; it introduces the more complex models that are appropriate for deeper dives into performance issues or understanding how computer hardware and its design influences performance. Let’s dig into what this means when looking at your code and performance issues.

> > > **NOTE** We encourage you to follow along with the examples for this chapter at <https://github.com/EssentialsofParallelComputing/Chapter4>.

***4.1 Performance data structures: Data-oriented design***

Our goal is to design data structures that lead to good performance. We’ll start with a way to allocate multidimensional arrays and then move on to more complex data structures. To achieve this goal requires

- Understanding how data is laid out in the computer

- How data is loaded into cache lines and then the CPU

- How data layout impacts performance

- The increasing importance of data movement to performance in today’s computers

In most modern programming languages, data is grouped in structures of one kind or another. For example, the use of data structures in C or classes in object-oriented programming (also called OOP) bring related items together for the convenience of organizing the source code. The members of the class are gathered together with the methods that operate on it. While the philosophy of object-oriented programming offers a lot of value from a programmer’s perspective, it completely ignores how the CPU operates. Object-oriented programming results in frequent method calls with few lines of code in between (figure 4.1).

For method invocation, the class must first be brought into the cache. Next the data is brought into cache and then adjacent elements of the class. This is convenient when you are operating on one object. But for applications with intensive computations, there are large numbers of each item. For these situations, we don’t want to invoke a method on one item at a time with each invocation requiring the transversal of a deep call stack. These lead to instruction cache misses, poor data cache usage, branching, and lots of function call overhead.

C++ methods make it much easier to write concise code, but nearly every line is a method invocation as figure 4.1 illustrates. In numerical simulation code, the `Draw_Line` call would more than likely be a complex mathematical expression. But even here, if the `Draw_Line` function is inlined into the source code, there will be no jumps into functions for the C code. Inlining is where the compiler copies the source from a subroutine into the location where it is used rather than making a call to it. The compiler can only inline for simple, short routines, however. But object-oriented code has method calls that won’t inline because of complexity and deep call stacks. This causes instruction cache misses and other performance issues. If we are only drawing one window, the loss in performance is offset by the simpler programming. If we are going to draw a million windows, we can’t afford the performance hit.

**Figure 4.1 Object-oriented languages have deep call stacks with lots of method calls (shown on the left), while procedural languages have long sequences of operations at one level of the call stack.**

So let’s flip this around and design our data structures for performance rather than programming convenience. Object-oriented programming and other modern programming styles are powerful but introduce many performance traps. At CppCon in 2014, Mike Acton’s presentation, “Data-oriented design and C++,” summarized work from the gaming industry that identified why modern programming styles impede performance. Advocates of the data-oriented design programming style address this issue by creating a programming style that focuses squarely on performance. This approach is coined data-oriented design, which focuses on the best data layout for the CPU and the cache. This style has much in common with the techniques long used by high-performance computing (HPC) developers. In HPC, data-oriented design is the norm; it follows naturally from the way people wrote programs in Fortran. So, what does data-oriented design look like? It

- Operates on arrays, not individual data items, avoiding the call overhead and the instruction and data cache misses

- Prefers arrays rather than structures for better cache usage in more situations

- Inlines subroutines rather than transversing a deep call hierarchy

- Controls memory allocation, avoiding undirected reallocation behind the scenes

- Uses contiguous array-based linked lists to avoid the standard linked list implementations used in C and C++, which jump all over memory with poor data locality and cache usage

As we move into parallelization in the next chapters, we’ll note that our experience shows that large data structures or classes also cause problems with shared memory parallelization and vectorization. In shared memory programming, we need to be able to mark variables as private to a thread or as global across all threads. But currently, all the items in the data structure have the same attribute. The problem is particularly acute during incremental introduction of OpenMP parallelization. When implementing vectorization, we want long arrays of homogeneous data, while classes usually group heterogeneous data. This complicates things.

***4.1.1 Multidimensional arrays***

In this section, we’ll cover the ubiquitous multidimensional array data structure in scientific computing. Our goal will be to understand

- How to lay out multidimensional arrays in memory

- How to access the arrays to avoid performance problems

- How to call numerical libraries that are in Fortran from a C program

Handling multidimensional arrays is the most common problem with regard to performance. The first two subfigures in figure 4.2 show the conventional C and Fortran data layouts.

**Figure 4.2 Conventional C ordering is row major while Fortran ordering is column major. Switching either the Fortran or C index order makes these compatible. Note that convention has Fortran array indices starting at 1 while C starts at 0. Also, C convention numbers the elements from 0 to 15 in contiguous order.**

The C data order is referred to as row major, where data across the row varies faster than data in the column. This means that row data is contiguous in memory. In contrast, the Fortran data layout is column major, where the column data varies fastest. Practically, as programmers, we must remember which index should be in the inner loop to leverage the contiguous memory in each situation (figure 4.3).

**Figure 4.3 For C, the important thing to remember is that the last index varies fastest and should be the inner loop of a nested loop. For Fortran, the first index varies fastest and should be the inner loop of a nested loop.**

Beyond the differences in data ordering between languages, there is a further issue that must be considered. Is the memory for the whole 2D array contiguous? Fortran doesn’t guarantee that the memory is contiguous unless you use the `CONTIGUOUS` attribute on the array as this example shows:

> `real, allocatable, contiguous :: x(:,:)`

In practice, using the contiguous attribute is not as critical as it might seem. All popular Fortran compilers allocate contiguous memory for arrays with or without this attribute. The possible exceptions are padding for cache performance or passing an array through a subroutine interface with a slice operator. A slice operator is a construct in Fortran that allows you to refer to a subset of an array as in the example of a copy of a row of a 2D array to a 1D array with the syntax `y(:)= x(1,:)`. Slice operators can also be used in a subroutine call; for example,

> `call write_data_row(x(1,:))`

Some research compilers handle this by simply modifying the stride between data elements in the dope vector for the array. In Fortran, the dope vector is the metadata for the array containing the start location, length of the array, and the stride between elements for each dimension. Dope in this context is from “give me the dope (info)” on someone or something (in this case, the array). Figure 4.4 illustrates the concepts of a dope vector, the slice operator, and stride. The idea is that by modifying the stride in the dope vector from 1 to 4, the data is then traversed as a row rather than a column. But in practice, production Fortran compilers usually make a copy of the data and pass it into the subroutine to avoid breaking code that is expecting contiguous data. This also means that you should avoid using the slice operator in calling Fortran subroutines because of the hidden copy and its resulting performance cost.

**Figure 4.4 Different views of a Fortran array created by modifying the dope vector, a set of metadata describing the start, stride, and length in each dimension. The slice operator returns a section of a Fortran array with all of the elements in the dimension with the colon (:). More complicated sections can be created, such as the lower four elements with A(1:2,1:2), where the upper and lower bounds are specified with the colon.**

C has its own issues with contiguous memory for a 2D array. This is due to the conventional way of dynamically allocating a 2D array in C as shown in the following listing.

**Listing 4.1 Conventional way of allocating a 2D array in C**

> ` 8 double **x =`  
> `      (double **)malloc(jmax*sizeof(double *));    `❶  
> `9`  
> `10 for (j=0; j<jmax; j++){`  
> `11    x[j] =`  
> `         (double *)malloc(imax*sizeof(double));    `❷  
> `12 }`  
> `13`  
> `14 // computation`  
> `15`  
> `16 for (j=0; j<jmax; j++){`  
> `17    free(x[j]);                                  `❸  
> `18 }`  
> `19 free(x);                                        `❸

❶ Allocates a column of pointers of type pointer to double

❷ Allocates each row of data

❸ Deallocates memory

This listing uses `1+jmax` allocations, and each allocation can come from a different place in the heap. With larger-sized 2D arrays, the layout of the data in memory has only a small impact on cache efficiency. The bigger problem is that the use of noncontiguous arrays is severely limited; it’s impossible to pass these to Fortran, write those in a block to a file, and then pass these to a GPU or to another processor. Instead, each of these operations needs to be done row by row. Fortunately, there is an easy way to allocate a contiguous block of memory for C arrays. Why isn’t it standard practice? It’s because everyone learns the conventional method as in listing 4.1 and doesn’t think about it. The following listing shows how to allocate a contiguous block of memory for a 2D array.

**Listing 4.2 Allocating a contiguous 2D array in C**

> ` 8 double **x =`  
> `9    (double **)malloc(jmax*sizeof(double *));       `❶  
> `10`  
> `11 x[0] = (void *)malloc(jmax*imax*sizeof(double));   `❷  
> `12`  
> `13 for (int j = 1; j < jmax; j++) {`  
> `14    x[j] = x[j-1] + imax;                           `❸  
> `15 }`  
> `16`  
> `17 // computation`  
> `18`  
> `19 free(x[0]);                                        `❹  
> `20 free(x);                                           `❹

❶ Allocates a block of memory for the row pointers

❷ Allocates a block of memory for the 2D array

❸ Assigns the memory location to point to the data block for each row pointer

❹ Deallocates memory

This method not only gives you a contiguous memory block, but it also only takes two memory allocations! We can optimize this even further by bundling the row pointers into the memory block at the start of the contiguous memory allocation on line 11 of listing 4.2, thereby combining the two memory allocations into one (figure 4.5).

**Figure 4.5 A contiguous block of memory becomes a 2D array in C.**

The following listing shows the implementation of a single contiguous memory allocation for a 2D array in malloc2D.c.

**Listing 4.3 Single contiguous memory allocation for a 2D array**

> `malloc2D.c`  
>   
> `1 #include <stdlib.h>`  
> `2 #include "malloc2D.h"`  
> `3`  
> `4 double **malloc2D(int jmax, int imax)`  
> `5 {`  
> `6    double **x = (double **)malloc(jmax*sizeof(double *) +`  
> `7                 jmax*imax*sizeof(double));      `❶  
> `8`  
> `9    x[0] = (double *)x + jmax;                   `❷  
> `10`  
> `11    for (int j = 1; j < jmax; j++) {`  
> `12       x[j] = x[j-1] + imax;                     `❸  
> `13    }`  
> `14`  
> `15    return(x);`  
> `16 }`  
>   
> `malloc2D.h`  
>   
> `1 #ifndef MALLOC2D_H`  
> `2 #define MALLOC2D_H`  
> `3 double **malloc2D(int jmax, int imax);`  
> `4 #endif`

❶ Allocates a block of memory for the row pointers and the 2D array

❷ Assigns the start of the memory block for the 2D array after the row pointers

❸ Assigns the memory location to point to the data block for each row pointer

Now we have only one memory block, including the row pointer array. This should improve memory allocation and cache efficiency. The array can also be indexed as a 1D or a 2D array as shown in listing 4.4. The 1D array reduces the integer address calculation and is easier to vectorize or thread (when we come to that in chapters 6 and 7). The listing also shows a manual 2D index calculation into a 1D array.

**Listing 4.4 1D and 2D access of contiguous 2D array**

> `calc2d.c`  
>   
> `1 #include "malloc2D.h"`  
> `2`  
> `3 int main(int argc, char *argv[])`  
> `4 {`  
> `5    int i, j;`  
> `6    int imax=100, jmax=100;`  
> `7`  
> `8    double **x = (double **)malloc2D(jmax,imax);`  
> `9`  
> `10    double *x1d=x[0];                 `❶  
> `11    for (i = 0; i< imax*jmax; i++){   `❶  
> `12       x1d[i] = 0.0;                  `❶  
> `13    }                                 `❶  
> `14`  
> `15    for (j = 0; j< jmax; j++){        `❷  
> `16       for (i = 0; i< imax; i++){     `❷  
> `17          x[j][i] = 0.0;              `❷  
> `18       }                              `❷  
> `19    }                                 `❷  
> `20`  
> `21    for (j = 0; j< jmax; j++){        `❸  
> `22       for (i = 0; i< imax; i++){     `❸  
> `23          x1d[i + imax * j] = 0.0;    `❸  
> `24       }                              `❸  
> `25    }                                 `❸  
> `26 }`

❶ 1D access of the contiguous 2D array

❷ 2D access of the contiguous 2D array

❸ Manual 2D index calculation for a 1D array

Fortran programmers take for granted the first-class treatment of multidimensional arrays in the language. Although C and C++ have been around for decades, these still do not have a native multidimensional array built into the language. There are proposals to the C++ standard to add native multidimensional array support for the 2023 revision (see the Hollman, et al. reference in appendix A). Until then, the multidimensional array memory allocation covered in listing 4.4 is essential.

***4.1.2 Array of Structures (AoS) versus Structures of Arrays (SoA)***

In this section, we’ll cover the implications of structures and classes on data layout. Our goals are to understand

- The different ways structures can be laid out in memory

- How to access arrays to avoid performance problems

There are two different ways to organize related data into data collections. These are the Array of Structures (AoS), where the data is collected into a single unit at the lowest level and then an array is made of the structure, or the Structure of Arrays (SoA), where each data array is at the lowest level and then a structure is made of the arrays. A third way, which is a hybrid of these two data structures, is the Array of Structures of Arrays (AoSoA). We will discuss this hybrid data structure in section 4.1.3.

One common example of an AoS is the color values used to draw graphic objects. The following listing shows the red, green, blue (RGB) color system structure in C.

**Listing 4.5 Array of Structures (AoS) in C**

> `1 struct RGB {`  
> `2    int R;                           `❶  
> `3    int G;                           `❶  
> `4    int B;                           `❶  
> `5 };`  
> `6 struct RGB polygon_color[1000];     `❷

❶ Defines a scalar color value

❷ Defines an Array of Structures (AoS)

Listing 4.5 shows an AoS where the data is laid out in memory (figure 4.6). In the figure, note the blank space at bytes 12, 28, and 44 where the compiler inserts padding to get the memory alignment on a 64-bit boundary (128 bits or 16 bytes). A 64-byte cache line holds four values of the structure. Then in line 6, we create the `polygon_color` array composed of 1,000 of the `RGB` data structure type. This data layout is reasonable because, generally, the RGB values are used together to draw each polygon.

**Figure 4.6 Layout in memory of an RGB color model in an Array of Structures (AoS).**

The SoA is an alternative data layout. The following listing shows the C code for this.

**Listing 4.6 Structure of Arrays (SoA) in C**

> ` 1 struct RGB {`  
> `2    int *R;                    `❶  
> `3    int *G;                    `❶  
> `4    int *B;                    `❶  
> `5 };`  
> `6 struct RGB polygon_color;     `❷  
> `7`  
> `8 polygon_color.R = (int *)malloc(1000*sizeof(int));`  
> `9 polygon_color.G = (int *)malloc(1000*sizeof(int));`  
> `10 polygon_color.B = (int *)malloc(1000*sizeof(int));`  
> `11`  
> `12 free(polygon_color.R);`  
> `13 free(polygon_color.G);`  
> `14 free(polygon_color.B);`

❶ Defines an integer array of a color value

❷ Defines a Structure of Arrays (SoA)

The memory layout has all 1,000 `R` values in contiguous memory. The `G` and `B` color values could follow the `R` values in memory, but these can also be elsewhere in the heap, depending on where the memory allocator finds space. The heap is a separate region of memory that is used to allocate dynamic memory with the `malloc` routine or the `new` operator. We can also use the contiguous memory allocator (listing 4.3) to force the memory to be located together.

Our concern here is performance. Each of these data structures is equally reasonable to use from the programmer’s perspective, but the important questions are how does the data structure appear to the CPU and how does it affect performance. Let’s look at the performance of these data structures in a couple of different scenarios.

***ARRAY OF STRUCTURES (AOS) PERFORMANCE ASSESSMENT***

In our color example, assume that when the data is read, all three components for a point are accessed but not a single `R`, `G`, or `B` value, so the AoS representation works well. And for graphics operations, this data layout is commonly used.

> > > **NOTE** If the compiler adds padding, it increases the number of memory loads by 25% for the AoS representation, but not all compilers insert this padding. Still it is worth considering for those compilers that do.

If only one of the `RGB` values is accessed in a loop, the cache usage would be poor because the loop skips over unneeded values. When this access pattern is vectorized by the compiler, it would need to use a less efficient gather/scatter operation.

***STRUCTURE OF ARRAYS (SOA) PERFORMANCE ASSESSMENT***

For the SoA layout, the `RGB` values have separate cache lines (figure 4.7). Thus, for small data sizes where all three `RGB` values are needed, there’s good cache usage. But as the arrays grow larger and more arrays are presented, the cache system struggles, causing performance to suffer. In these cases, the interactions of the data and the cache become too complicated to fully predict the performance.

**Figure 4.7 In the Structure of Arrays (SoA) data layout, the pointers are adjacent in memory, pointing to separate contiguous arrays for each color.**

Another data layout and access pattern that is often encountered is the use of variables as 3D spatial coordinates in a computational application. The following listing shows the typical C structure definition for this.

**Listing 4.7 Spatial coordinates in a C Array of Structures (AoS)**

> `1 struct point {`  
> `2    double x, y, z;            `❶  
> `3 };`  
> `4 struct point cell[1000];      `❷  
> `5 double radius[1000];`  
> `6 double density[1000];`  
> `7 double density_gradient[1000];`

❶ Defines the spatial coordinate of point

❷ Defines an array of point locations

One use of this data structure is to calculate the distance from the origin (radius) as follows:

> `10 for (int i=0; i < 1000; i++){`  
> `11    radius[i] = sqrt(cell[i].x*cell[i].x + cell[i].y*cell[i].y + cell[i].z*cell[i].z);`  
> `12 }`

The values of `x`, `y`, and `z` are brought in together in one cache line and written out to the radius variable in a second cache line. The cache usage for this case is reasonable. But in a second plausible case, a computational loop might use the `x` location to calculate a gradient in density in the x-direction like this:

> `20 for (int i=1; i < 1000; i++){`  
> `21   density_gradient[i] = (density[i] - density[i-1])/`  
> `                           (cell[i].x - cell[i-1].x);`  
> `22 }`

Now the cache access for `x` skips over the `y` and `z` data so that only one-third (or even one-quarter if padded) of the data in the cache is used. Thus, the optimal data layout depends entirely on usage and the particular data access patterns.

In mixed use cases, which are likely to appear in real applications, sometimes the structure variables are used together and sometimes not. Generally, the AoS layout performs better overall on CPUs, while the SoA layout performs better on GPUs. In reported results, there is enough variability that it is worth testing for a particular usage pattern. In the density gradient case, the following listing shows the SoA code.

**Listing 4.8 Spatial coordinate Structure of Arrays (SoA)**

> ` 1 struct point{`  
> `2      double *x, *y, *z;                         `❶  
> `3 };`  
> `4 struct point cell;                              `❷  
> `5 cell.x = (double *)malloc(1000*sizeof(double));`  
> `6 cell.y = (double *)malloc(1000*sizeof(double));`  
> `7 cell.z = (double *)malloc(1000*sizeof(double));`  
> `8 double *radius = (double *)malloc(1000*sizeof(double));`  
> `9 double *density = (double *)malloc(1000*sizeof(double));`  
> `10 double *density_gradient = (double *)malloc(1000*sizeof(double));`  
> `11 // ... initialize data`  
> `12`  
> `13 for (int i=0; i < 1000; i++){                   `❸  
> `14    radius[i] = sqrt(cell.x[i]*cell.x[i] +`  
> `                       cell.y[i]*cell.y[i] +`  
> `                       cell.z[i]*cell.z[i]);`  
> `15 }`  
> `16`  
> `17 for (int i=1; i < 1000; i++){                   `❹  
> `18    density_gradient[i] = (density[i] - density[i-1])/`  
> `                            (cell.x[i] - cell.x[i-1]);`  
> `19 }`  
> `20`  
> `21 free(cell.x);`  
> `22 free(cell.y);`  
> `23 free(cell.z);`  
> `24 free(radius);`  
> `25 free(density);`  
> `26 free(density_gradient);`

❶ Defines arrays of spatial locations

❷ Defines structure of cell spatial locations

❸ This loop uses contiguous values of arrays.

❹ This loop uses contiguous values of arrays.

With this data layout, each variable is brought in on a separate cache line, and cache usage will be good for both kernels. But as the number of required data members get sufficiently larger, the cache has difficulty efficiently handling the multitude of memory streams. In a C++ object-oriented implementation, you should be wary of other pitfalls. The next listing presents a cell class with the cell spatial coordinate and the radius as its data components and a method to calculate the radius from `x`, `y`, and `z`.

**Listing 4.9 Spatial coordinate class example with C++**

> ` 1 class Cell{`  
> `2       double x;`  
> `3       double y;`  
> `4       double z;`  
> `5       double radius;`  
> `6    public:`  
> `7       void calc_radius() {`  
> `              radius = sqrt(x*x + y*y + z*z);     `❶  
> `         }`  
> `8       void big_calc();`  
> `9 }`  
> `10`  
> `11 Cell my_cells[1000];                           `❷  
> `12`  
> `13 for (int i = 0; i < 1000; i++){`  
> `14    my_cells[i].calc_radius();`  
> `15 }`  
> `16`  
> `17 void Cell::big_calc(){`  
> `18    radius = sqrt(x*x + y*y + z*z);`  
> `19    // ... lots more code, preventing in-lining`  
> `20 }`

❶ Invokes radius function for each cell

❷ Defines an array of objects as an array of structs

Running this code results in a couple of instruction cache misses and overhead from subroutine calls for each cell. Instruction cache misses occur when the sequence of instructions jumps and the next instruction is not in the instruction cache. There are two level 1 caches: one for the program data and the second for the processor’s instructions. Subroutine calls require the additional overhead to push the arguments onto the stack before the call and an instruction jump. Once in the routine, the arguments need to be popped off the stack and then, at the end of the routine, there is another instruction jump. In this case, the code is simple enough that the compiler can inline the routine to avoid these costs. But in more complex cases, such as with a `big_calc` routine, it cannot. Additionally, the cache line pulls in `x`, `y`, `z`, and the radius. The cache helps speed up the load of the position coordinates that actually need to be read. But the radius, which needs to be written, is also in the cache line. If different processors are writing the values for the radius, this could invalidate the cache lines and require other processors to reload the data into their caches.

There are many features of C++ that make programming easier. These should generally be used at a higher level in the code, using the simpler procedural style of C and Fortran where performance counts. In the previous listing, the radius calculation can be done as an array instead of as a single scalar element. The class pointer can be dereferenced once at the start of the routine to avoid repeated dereferencing and possible instruction cache misses. Dereferencing is an operation where the memory address is obtained from the pointer reference so that the cache line is dedicated to the memory data instead of the pointer. Simple hash tables can also use a structure to group the key and value together as the following listing shows.

**Listing 4.10 Hash Array of Structures (AoS)**

> `1 struct hash_type {`  
> `2    int key;`  
> `3    int value;`  
> `4 };`  
> `5 struct hash_type hash[1000];`

The problem with this code is that it reads multiple keys until it finds one that matches and then reads the value for that key. But the key and value are brought into a single cache line, and the value ignored until the match occurs. It is better to have the key as one array and the value as another to facilitate a faster search through the keys as shown in the next listing.

**Listing 4.11 Hash Structure of Arrays (SoA)**

> `1 struct hash_type {`  
> `2    int *key;`  
> `3    int *value;`  
> `4 } hash;`  
> `5 hash.key   = (int *)malloc(1000*sizeof(int));`  
> `6 hash.value = (int *)malloc(1000*sizeof(int));`

As a final example, take a physics state structure that contains density, 3D momentum, and total energy. The following listing shows this structure.

**Listing 4.12 Physics state Array of Structures (AoS)**

> `1 struct phys_state {`  
> `2    double density;`  
> `3    double momentum[3];`  
> `4    double TotEnergy;`  
> `5 };`

When processing only density, the next four values in cache go unused. Again, it is better to have this as an SoA.

***4.1.3 Array of Structures of Arrays (AoSoA)***

There are cases where hybrid groupings of structures and arrays are effective. The Array of Structures of Arrays (AoSoA) can be used to “tile” the data into vector lengths. Let’s introduce the notation `A[len/4]S[3]A[4]` to represent this layout. `A[4]` is an array of four data elements and is the inner, contiguous block of data. `S[3]` represents the next level of the data structure of three fields. The combination of `S[3]A[4]` gives the data layout that figure 4.8 shows.

**Figure 4.8 An Array of Structures of Arrays (AoSoA) is used with the last array length, matching the vector length of the hardware for a vector length of four.**

We need to repeat the block of 12 data values `A[len/4]` times to get all the data. If we replace the `4` with a variable, we get

> `A[len/V]S[3]A[V], where V=4`

In C or Fortran, respectively, the array could be dimensioned as

> `var[len/V][3][V], var(1:V,1:3,1:len/V)`

In C++, this would be implemented naturally as the following listing shows.

**Listing 4.13 RGB Array of Structures of Arrays (AoSoA)**

> ` 1 const int V=4;                       `❶  
> `2 struct SoA_type{`  
> `3    int R[V], G[V], B[V];`  
> `4 };`  
> `5`  
> `6 int main(int argc, char *argv[])`  
> `7 {`  
> `8    int len=1000;`  
> `9    struct SoA_type AoSoA[len/V];     `❷  
> `10`  
> `11    for (int j=0; j<len/V; j++){      `❸  
> `12       for (int i=0; i<V; i++){       `❹  
> `13          AoSoA[j].R[i] = 0;`  
> `14          AoSoA[j].G[i] = 0;`  
> `15          AoSoA[j].B[i] = 0;`  
> `16       }`  
> `17    }`  
> `18 }`

❶ Sets vector length

❷ Divides the array length by vector length

❸ Loops over array length

❹ Loops over vector length, which should vectorize

By varying `V` to match the hardware vector length or the GPU work group size, we create a portable data abstraction. In addition, by defining `V=1` or `V=len`, we recover the AoS and SoA data structures, respectively. This data layout then becomes a way to adapt for the hardware and the program’s data use patterns.

There are many details to address about the implementation of this data structure to minimize indexing costs and decide whether to pad the array for performance. The AoSoA data layout has some of the properties of both the AoS and SoA data structures so the performance is generally close to the better of the two as shown in a study by Robert Bird from Los Alamos National Laboratory (figure 4.9).

**Figure 4.9 Performance of the Array of Structures of Arrays (AoSoA) generally matches the best of the AoS and SoA performances. The 1, 8 and NP array length in the x-axis legend is the value for the last array in AoSoA. These values mean that the first set reduces to an AOS, the last set reduces to an SoA, and the middle set has a second array length of 8 to match the vector length of the processor.**

***4.2 Three Cs of cache misses: Compulsory, capacity, conflict***

Cache efficiency dominates the performance of intensive computations. As long as the data is cached, the computation proceeds quickly. When the data is not cached, a cache miss occurs. The processor then has to pause and wait for the data to be loaded. The cost of a cache miss is on the order of 100 to 400 cycles; 100s of flops can be done in the same time! For performance, we must minimize cache misses. But minimizing cache misses requires an understanding of how data moves from main memory to the CPU. This is done with a simple performance model that separates cache misses into three C’s: compulsory, capacity, and conflict. First we must understand how the cache works.

When data is loaded, it is loaded in blocks, called cache lines, that are typically 64 bytes long. These are then inserted into a cache location based on its address in memory. In a direct-mapped cache, there is only one location to load data into the cache. This is important when two arrays get mapped to the same location. With a direct-mapped cache, only one array can be cached at a time. To avoid this, most processors have an N-way set associative cache that provides N locations into which data are loaded. With regular, predictable memory accesses of large arrays, it is possible to prefetch data. That is, you can issue an instruction to preload data before it is needed so that it’s already in the cache. This can be done either in hardware or in software by the compiler.

Eviction is the removal of a cache line from one or more cache levels. This can be caused by the load of a cache line at the same location (cache conflict) or the limited size of the cache (capacity miss). A store operation by an assignment in the loop causes a write allocate in cache, where a new cache line is created and modified. This cache line is evicted (stored) to main memory, although it may not happen immediately. There are various write policies used that affect the details of write operations. The three C’s of caches are a simple approach to understanding the source of the cache misses that dominate run-time performance for intensive computations.

- Compulsory—Cache misses that are necessary to bring in the data when it is first encountered.

- Capacity—Cache misses that are caused by a limited cache size, which evicts data from the cache to free up space for new cache line loads.

- Conflict—When data is loaded at the same location in the cache. If two or more data items are needed at the same time but are mapped to the same cache line, both data items must be loaded repeatedly for each data element access.

When cache misses occur due to capacity or conflict evictions followed by reloads of the cache lines, this is sometimes referred to as cache thrashing, which can lead to poor performance. From these definitions, we can easily calculate a few characteristics of a kernel and at least get an idea of the expected performance. For this, we will use the blur operator kernel from figure 1.10.

Listing 4.14 shows the stencil.c kernel. We also use the 2D contiguous memory allocation routine in malloc2D.c from section 4.1.1. The timer code is not shown here but is in the online source code. Included are timers and calls to the likwid (“Like I Knew What I’m Doing”) profiler. Between iterations, there is a write to a large array to flush the cache so that there is no relevant data in it that can distort the results.

**Listing 4.14 Stencil kernel for the Krakatau blur operator**

> `stencil.c`

If we have a perfectly effective cache, once the data is loaded into memory, it is kept there. Of course, this is far from reality in most cases. But with this model, we can calculate the following:

- Total memory used = 2000 × 2000 × (5 references + 1 store) × 8 bytes = 192 MB

- Compulsory memory loaded and stored = 2002 × 2002 × 8 bytes × 2 arrays = 64.1 MB

- Arithmetic intensity = 5 flops × 2000 × 2000 / 64.1 Mbytes = .312 flops/byte or 2.5 flops/word

The program is then compiled with the likwid library and run on a Skylake 6152 processor with the following command:

> `likwid-perfctr -C 0 -g MEM_DP -m ./stencil`

The result that we need is at the end of the performance table printed at the conclusion of the run:

> `+-----------------------------------+------------+`  
> `|  ...                              |            |`  
> `|             DP MFLOP/s            |  3923.4952 |`  
> `|           AVX DP MFLOP/s          |  3923.4891 |`  
> `|  ...                              |            |`  
> `|       Operational intensity       |     0.247  |`  
> `+-----------------------------------+------------+`

The performance data for the stencil kernel is presented as a roofline plot using a Python script (available in the online materials) and shown in figure 4.10. The roofline plot, as introduced in section 3.2.4, shows the hardware limits of the maximum floating-point operations and the maximum bandwidth as a function of arithmetic intensity.

**Figure 4.10 The roofline plot of the stencil kernel for the Krakatau example in chapter 1 shows the compulsory upper bound to the right of the measured performance.**

This roofline plot shows the compulsory data limit to the right side of the measured arithmetic intensity of 0.247 (shown with a large dot in figure 4.10). The kernel cannot do better than the compulsory limit if it has a cold cache. A cold cache is one that does not have any relevant data in it from whatever operations were being done before entering the kernel. The distance between the large dot and the compulsory limit gives us an idea of how effective the cache is in this kernel. The kernel in this case is simple, and the capacity and conflict cache loads are only about 15% greater than the compulsory cache loads. Thus, there is not much room for improvement for the kernel performance. The distance between the large dot and the DRAM roofline is because this is a serial kernel with vectorization, while the rooflines are parallel with OpenMP. Thus, there is a potential to improve performance by adding parallelism.

Because this is a log-log plot, differences are greater than they might appear. Looking closely, the possible improvement from parallelism is nearly an order of magnitude. Improving cache usage can be accomplished by using other values in the cache line or reusing data multiple times while it is in the cache. These are two different cases, referred to as either spatial locality or temporal locality:

- Spatial locality refers to data with nearby locations in memory that are often referenced close together.

- Temporal locality refers to recently referenced data that is likely to be referenced again in the near future.

For the stencil kernel (listing 4.14), when the value of `x[1][1]` is brought into cache, `x[1][2]` is also brought into cache. This is spatial locality. In the next iteration of the loop to calculate `x[1][2]`, `x[1][1]` is needed. It should still be in the cache and gets reused as a case of temporal locality.

A fourth C is often added to the three C’s mentioned earlier that will become important in later chapters. This is called coherency.

> > > **DEFINITION** Coherency applies to those cache updates needed to synchronize the cache between multiprocessors when data that is written to one processor’s cache is also held in another processor’s cache.

The cache updates required to maintain coherency can sometimes lead to heavy traffic on the memory bus and are sometimes referred to as cache update storms. These cache update storms can lead to slowdowns in performance rather than speedups when additional processors are added to a parallel job.

***4.3 Simple performance models: A case study***

This section looks at an example of using simple performance models to make informed decisions on what data structure to use for multi-material calculations in a physics application. It uses a real case study to show the effects of:

- Simple performance models for a real programming design question

- Compressed sparse data structures to stretch your computational resources

Some segments of computational science have long used compressed sparse matrix representations. Most notable is the Compressed Sparse Row (CSR) format used for sparse matrices since the mid 1960s with great results. For the compressed sparse data structure evaluated in this case study, the memory savings are greater than 95%, and the run time approaches 90% faster than the simple 2D array design. The simple performance models used predicted the performance within a 20-30% error of actual measured performance (see Fogerty, Mattineau, et al., in the section on additional reading later in this chapter). But there is a cost to using this compressed scheme—programmer effort. We want to use the compressed sparse data structure where its benefits outweigh the costs. Making this decision is where the simple performance model really shows its usefulness.

> **Example: Modeling the Krakatau ash plume**

> Your team is considering the modeling of the ash plume in the example from chapter 1. They realize that the ash materials in the plume may eventually number in the 10s or even up to 100, yet these materials do not need to be in every cell. Could a compressed sparse representation be useful for this situation?

Simple performance models are useful to the application developer when addressing more complex programming problems than just a doubly-nested loop over a 2D array. The goal of these models is to get a rough assessment of performance through simple counts of operations in a characteristic kernel to make decisions on programming alternatives. Simple performance models are slightly more complicated than the three C’s model. The basic process is to count and note the following:

- Memory loads and stores (memops)

- Floating-point operations (flops)

- Contiguous versus non-contiguous memory loads

- Presence of branches

- Small loops

We’ll count memory loads and stores (collectively referred to as memops) and flops, but we’ll also note whether the memory loads are contiguous and if there are branches that might affect the performance. We’ll also use empirical data such as stream bandwidth and generalized operation counts to transform the counts into performance estimates. If the memory loads are not contiguous, only 1 out of 8 values in the cache line are used, so we divide the stream bandwidth by up to 8 for those cases.

For the serial part of this study, we’ll use the hardware performance of a MacBook Pro with 6 MB L3 cache. The processor frequency (v) is 2.7 GHz. The measured stream bandwidth is 13,375 MB/s using the technique introduced in section 3.2.4 with the stream benchmark code.

In algorithms with branching, if we take the branch almost all the time, the branch cost is low. When the branch taken is infrequent, we add a branch prediction cost (B_(c)) and possibly a missed prefetch cost (P_(c)). A simple model of the branch predictor uses the most frequent case in the last few iterations as the likely path. This lowers the cost if there is some clustering in branch paths due to data locality. The branch penalty (B _(p)) becomes N_(b)B _(f)(B_(c) + P_(c))/v. For typical architectures, the branch prediction cost (B_(c)) is about 16 cycles and the missing prefetch cost (P_(c) ) is empirically determined to be about 112 cycles. N_(b) is the number of times the branch is encountered and B_(f) is the branch miss frequency. Loop overhead for small loops of unknown length are also assigned a cost (L_(c) ) to account for branching and control. The loop cost is estimated at about 20 cycles per exit. The loop penalty (L_(p)) becomes L_(c) /v.

We will use simple performance models in a design study looking at possible multi-material data structures for physics simulations. The purpose of this design study is to determine which data structures would give the best performance before writing any code. In the past, the choice was made on subjective judgement rather than an objective basis. The particular case that is being examined is the sparse case, where there are many materials in the computational mesh but only one or few materials in any computational cell. We’ll reference the small sample mesh with four materials in figure 4.11 in the discussion of possible data layouts. Three of the cells have only a single material, whereas cell 7 has four materials.

**Figure 4.11 A 3×3 computational mesh shows that cell 7 contains four materials.**

The data structure is only half the story. We also need to evaluate the data layout in a couple of representative kernels by

1.  Computing `pavg[C]`, the average density of materials in cells of a mesh

2.  Evaluating `p[C][m]`, the pressure in each material contained in each cell using the ideal gas law: p(p,t) = nrt/v

Both of these computations have an arithmetic intensity of 1 flop per word or lower. We also expect that these kernels will be bandwidth limited. We’ll use two large data sets to test the performance of the kernels. Both are 50 material (N_(m)), 1 million cell problems (N_(c)) with four state arrays (N_(v)). The state arrays are density (p), temperature (t), pressure (p), and volume fraction (V_(f)). The two data sets are

- Geometric Shapes Problem—A mesh initialized from nested rectangles of materials (figure 4.12). The mesh is a regular rectangular grid. With the materials in separate rectangles rather than scattered, most cells only have one or two materials. The result is that there are 95% pure cells (P_(f)) and 5% mixed cells (M_(f) ). This mesh has some data locality so the branch prediction miss (B_(p)) is roughly estimated to be 0.7.

**Figure 4.12 Fifty nested half rectangles used to initialize mesh for the geometric shapes test case**

- Randomly Initialized Problem—A randomly initialized mesh with 80% pure cells and 20% mixed cells. Because there is little data locality, the branch prediction miss (B _(p)) is estimated to be 1.0.

In the performance analysis in sections 4.3.1 and 4.3.2, there are two major design considerations: data layout and loop order. We refer to the data layout as either cell- or material-centric, depending on the larger organizing factor in the data. The data layout factor has the large stride in the data order. We refer to the loop access pattern as either cell- or material-dominant to indicate which is the outer loop. The best situation occurs when the data layout is consistent with the loop access pattern. There is no perfect solution; one of the kernels prefers one layout and the second kernel prefers the other.

***4.3.1 Full matrix data representations***

The simplest data structure is a full matrix storage representation. This assumes that every material is in every cell. These full matrix representations are similar to the 2D arrays discussed in the previous section.

***FULL MATRIX CELL-CENTRIC STORAGE***

For the small problem in figure 4.11 (the 3x3 computational mesh), figure 4.13 shows the cell-centric data layout. The data order follows the C language convention with the materials stored contiguously for each cell. In other words, the programming representation is `variable[C][m]` with `m` varying fastest. In the figure, the shaded elements are mixed materials in a cell. Pure cells just have a 1.0 entry. The elements with dashes indicate that none of that material is in the cell and is therefore given a zero in this representation. In this simple example, about half of the entries have zeros, but in the bigger problem, the number of entries that are zero will be greater than 95%. The number of non-zero entries is referred to as the filled fraction (F _(f) ), and for our design scenario is typically less than 5%. Thus, if a compressed sparse storage scheme is used, the memory savings will be greater than 95%, even accounting for the additional storage overhead of the more complex data structures.

**Figure 4.13 The cell-centric, full matrix data structure with materials stored contiguously for each cell**

The full matrix data approach has the advantage that it is simpler and, thus, easier to parallelize and optimize. The memory savings is substantial enough that it is probably worth using the compressed sparse data structure. But what are the performance implications of the method? We can guess that having more memory for data potentially increases the memory bandwidth and makes the full matrix representation slower. But what if we test for the volume fraction and, if it is zero, we skip the mixed material access? Figure 4.14 shows how we tested this approach, where the pseudo-code for the cell-dominant loop is shown along with the counts for each operation to the left of the line of code. The cell-dominant loop structure has the cell index in the outer loop, which matches with the cell index as the first index in the cell-centric data structure.

**Figure 4.14 Modified cell-dominant algorithm to compute average density of cells using the full matrix storage**

The counts are summarized from the line notes (beginning with \#) in figure 4.14 as:

memops = N_(c)(N_(m) + 2F _(f) N_(m) + 2) = 54.1 Mmemops

flops = N_(c)(2F _(f) N_(m) + 1) = 3.1 Mflops

N_(c) = 1e6; N_(m) = 50; F_(f) = .021

If we look at flops, we would conclude that we have been efficient and the performance would be great. But this algorithm is clearly going to be dominated by memory bandwidth. For estimating memory bandwidth performance, we need to factor in the branch prediction miss. Because the branch is taken so infrequently, the probability of a branch prediction miss is high. The geometric shapes problem has some locality, so the miss rate is estimated to be 0.7. Putting this all together, we get the following for our performance model (PM):

PM = N_(c)(N_(m) + F _(f) N_(m) + 2) \* 8/Stream + B _(p) F _(f) N_(c) N_(m) = 67.2 ms

B _(f) = 0.7; B _(c) = 16; P_(c) = 16; υ = 2.7

The cost of the branch prediction miss makes the run time high; higher than if we just skipped the conditional and added in zeros. Longer loops would amortize the penalty cost, but clearly a conditional that is rarely taken is not the best scenario for performance. We could also insert a prefetch operation before the conditional to force loading the data in case the branch is taken. But this would increase the memops so the actual performance improvement would be small. It would also increase the traffic on the memory bus, causing congestion that would trigger other problems, especially when adding thread parallelism.

***FULL MATRIX MATERIAL-CENTRIC STORAGE***

Now let’s take a look at the material-centric data structure (figure 4.15). The C notation for this is `variable[m][C]` with the rightmost index of `C` (or cells) varying fastest. In the figure, the dashes indicate elements that are filled with zeros. Many of the characteristics of this data structure are similar to the cell-centric full matrix data representation, but with the indices of the storage flipped.

**Figure 4.15 The material-centric full matrix data structure stores cells contiguously for each material. The array indexing in C would be** **`density[m][C]`** **with the cell index contiguous. The cells with dashes are filled with zeros.**

The algorithm for computing the average density of each of the cells can be done with contiguous memory loads and a little thought. The natural way to implement this algorithm is to have the outer loop over the cells, initialize it to zero there, and divide by the volume at the end. But this strides over the data in a non-contiguous fashion. We want to loop over cells in the inner loop, requiring separate loops before and after the main loop. Figure 4.16 shows the algorithm along with annotations for memops and flops.

**Figure 4.16 Material-dominant algorithm to compute average density of cells using full matrix storage**

Collecting all the annotations for operations, we get

memops = 4N_(c)(N_(m) + 1) = 204 Mmemops

flops = 2N_(c)N_(m) + N_(c) = 101 Mflops

This kernel is bandwidth limited, so the performance model is

PM = 4N_(c)(N_(m) + 1) \* 8/Stream = 122 ms

The performance of this kernel is half of what the cell-centric data structure achieved. But this computational kernel favors the cell-centric data layout, and the situation is reversed for the pressure calculation.

***4.3.2 Compressed sparse storage representations***

Now we’ll discuss the advantages and limitations of a couple of compressed storage representations. The compressed sparse storage data layouts clearly save memory, but the design for both cell- and material-centric layouts takes some thought.

***CELL-CENTRIC COMPRESSED SPARSE STORAGE***

The standard approach is a linked list of materials for each cell. But linked lists are generally short and jump all over memory. The solution is to put the linked list into a contiguous array with the link pointing to the start of the material entries. The next cell will have its materials follow right afterwards. Thus, during normal traversal of the cells and materials, these will be accessed in contiguous order. Figure 4.17 shows the cell-centric data storage scheme. The values for pure cells are kept in cell state arrays. In the figure, 1.0 is the volume fraction of the pure cells, but it can also be the pure cell values for density, temperature, and pressure. The second array is the number of materials in the mixed cell. A -1 indicates that it is a pure cell. Then the material linked list index, imaterial, is in the third array. If it is less than 1, the absolute value of the entry is the index into the mixed data storage arrays. If it is 1 or greater, then it is the index into the compressed pure cell arrays.

**Figure 4.17 The mixed material arrays for the cell-centric data structure use a linked list implemented in a contiguous array. The different shading at the bottom indicates the materials that belong to a particular cell and match the shading used in figure 4.13.**

Mixed data storage arrays are basically a linked list implemented in a standard array so that the data is contiguous for good cache performance. The mixed data starts with an array called `nextfrac`, which points to the next material for that cell. This enables the addition of new materials in the cell by adding these to the end of the array. Figure 4.17 shows this with the mixed material list for cell 4, where the arrow shows the third material to be added at the end. The `frac2cell` array is a backward mapping to the cell that contains the material. The third array, `material`, contains the material number for the entry. These are the arrays that provide the navigation around the compressed sparse data structure. The fourth array is the set of state arrays for each material in each cell with the volume fraction (V_(f)), density (ρ), temperature (t) and pressure (p).

The mixed material arrays keep extra memory at the end of the array to quickly add new material entries on the fly. Removing the data link and setting it to zero deletes the materials. To give better cache performance, the arrays are periodically reordered back into contiguous memory.

Figure 4.18 shows the algorithm for the calculation of the average density for each cell for the compressed sparse data layout. We first retrieve the material index, `imaterial`, to see if this is a cell with mixed materials by testing if it is zero or less. If it is a pure cell, we do nothing because we already have the density in the cell array. If it is a mixed material cell, we enter a loop to sum up the density multiplied by the volume fraction for each of the materials. We test for the end condition of the index becoming negative and use the `nextfrac` array to get the next entry. Once we reach the end of the list, we calculate the cell’s density (ρ). To the right side of the lines of code are the annotations for the operational costs.

**Figure 4.18 Cell-dominant algorithm to compute average cell density using compact storage**

To the right of the lines of code are the annotations for the operational costs. For this analysis, we will have 4-byte integer loads, so we convert memops to membytes. Collecting the counts, we obtain

membytes = (4 + 2M _(f) \* 8)N_(c) + (2 \* 8 + 4)= 6.74 Mbytes

flops = 2M _(L) + M _(f) N_(c) = .24 Mflops

M_(f) = .04895; M _(L) = 97970

Again, this algorithm is memory bandwidth limited. The estimated run time from the performance model is a 98% reduction from the full cell-centric matrix.

PM = membytes/Stream + L_(p)M _(f) N_(c) = .87 ms

L_(p) = 20/2.7e6; M _(f) = .04895

***MATERIAL-CENTRIC COMPRESSED SPARSE STORAGE***

The material-centric compressed sparse data structure subdivides everything into separate materials. Returning to the small test problem in figure 4.9, we see that there are six cells with material 1: 0, 1, 3, 4, 6, and 7 (shown in figure 4.19 in subset 1). There are two mappings in the subset: one from mesh to subset, `mesh2subset`, and one from the subset back to the mesh, `subset2mesh`. The list in the subset to mesh has the indices of the six cells. The mesh array contains -1 for each cell that does not have the material and numbers the ones that do sequentially to map to the subset. The `nmats` array at the top of figure 4.19 has the number of materials contained in each cell. The volume fraction (V_(f) ), and density (ρ) arrays on the right side of the figure have values for each cell in that material. The C nomenclature for this would be `Vf[imat][icell]` and `p[imat][icell]`. Because there are relatively few materials with long lists of cells, we can use regular 2D array allocations rather than forcing these to be contiguous. To operate on this data structure, we mostly work with each material subset in sequence.

**Figure 4.19 The material-centric compressed sparse data layout is organized around materials. For each material, there is a variable-length array with a list of the cells that contain the material. The shading corresponds to the shading in figure 4.15. The illustration maps between the full mesh and subsets and the volume fraction and density variables for each subset.**

**Figure 4.20 Material-dominant algorithm computes the average density of cells using the material-centric compact storage scheme.**

The material-dominant algorithm in figure 4.20 for the compressed sparse algorithm looks like the algorithm in figure 4.13 with the addition of the retrieval of the pointers in lines 5, 6, and 8. But the loads and flops in the inner loop are only done for the material subset of the mesh rather than the full mesh. This provides considerable savings in flops and memops. Collecting all the counts, we get

membytes = 5 \* 8 \* F _(f) N_(m)N_(c) + 4 \* 8 \* N_(c) + (8 + 4) \* N_(m) = 74 Mbytes

flops = (2F _(f) N_(m) + 1)N_(c) = 3.1 Mflops

The performance model shows more than a 95% reduction in estimated run time from the material-centric full matrix data structure:

PM = membytes/Stream = 5.5 ms

Table 4.1 summarizes the results for these four data structures. The difference between the estimated and measured run time is remarkably small. This shows that even rough counts of memory loads can be a good predictor of performance.

**Table 4.1 The sparse data structures are faster and use less memory than the full 2D matrices.**

|                                    | **Memory load (MBs)** | **Flops** | **Estimated run time** | **Measured run time** |
|------------------------------------|-----------------------|-----------|------------------------|-----------------------|
| Cell-centric full                  | 424                   | 3.1       | 67.2                   | 108                   |
| Material-centric full              | 1632                  | 101       | 122                    | 164                   |
| Cell-centric compressed sparse     | 6.74                  | .24       | .87                    | 1.4                   |
| Material-centric compressed sparse | 74                    | 3.1       | 5.5                    | 9.6                   |

The advantage of the compressed sparse representations is dramatic, with savings in both memory and performance. Because the kernel we analyzed was more suited for the cell-centric data structures, the cell-centric compressed sparse data structure is clearly the best performer both in memory and run time. If we look at the other kernel that shows the material-centric data layout, the results are slightly in favor of the material-centric data structures. But the big takeaway is that either of the compressed sparse representations is a vast improvement over the full matrix representations.

While this case study focused on multi-material data representations, there are many diverse applications with sparse data that can benefit from the addition of a compressed sparse data structure. A quick performance analysis similar to the one done in this section can determine whether the benefits are worth the additional effort in these applications.

***4.4 Advanced performance models***

There are more advanced performance models that better capture aspects of the computer hardware. We will briefly cover these advanced models to understand what these offer and the possible lessons to be learned. The details of the performance analysis are not as important as the takeaways.

In this chapter, we focused primarily on bandwidth-limited kernels because these represent the performance limitations of most applications. We counted the bytes loaded and stored by the kernel and estimated the time required for this data movement based on the stream benchmark or roofline model (chapter 3). By now, you should realize that the unit of operation for computer hardware is not really bytes or words but cache lines, and we can improve the performance models by counting the cache lines that need to be loaded and stored. At the same time, we can estimate how much of the cache line is used.

The stream benchmark is actually composed of four individual kernels: the copy, scale, add, and triad kernels. So why the variation in the bandwidth (16156.6-22086.5 MB/s) among these kernels as seen in the STREAM Benchmark exercise in 3.2.4? It was implied then that the cause was the difference in arithmetic intensity among the kernels shown in the table in section 3.2.4. This is only partly true. The small difference in arithmetic operations is really a pretty minor influence as long as we are in the bandwidth-limited regime. The correlation with the arithmetic operations is also not high. Why does the scale operation have the lowest bandwidth? The real culprits are the details in the cache hierarchy of the system. The cache system is not like a pipe with water flowing steadily through it as might be implied by the stream benchmark. It is more like a bucket brigade ferrying data up the cache levels with varying numbers of buckets and sizes as figure 4.21 shows. This is exactly what the Execution Cache Memory (ECM) model developed by Treibig and Hager tries to capture. Although it requires knowledge of the hardware architecture, it can predict the performance extremely well for streaming kernels. Movement between levels can be limited by the number of operations (µops), called micro-ops, that can be performed in a single cycle. The ECM model works in terms of cache lines and cycles, modeling the movement between the different cache levels.

**Figure 4.21 The movement of data between cache levels is a series of discrete operations, more like a bucket brigade than a flow through a pipe. The details of the hardware and how many loads can be issued at each level and in each direction largely impact the efficiency of loading data through the cache hierarchy.**

Let’s just take a quick look at the ECM model for the stream triad (`A[i] = B[i] + s*C[i]`) to see how this model works (figure 4.22). This calculation must be done for the specific kernel and hardware. We’ll use a Haswell EP system for the hardware for this analysis. We start at the computational core with the equation T_(core) = max(T_(nOL),T_(OL)), where T is time in cycles. T_(OL) is generally the arithmetic operations that overlap the data transfer time, and T_(nOL) is the non-overlapping data transfer time.

**Figure 4.22 The Execution Cache Memory (ECM) model for the Haswell processor provides a detailed timing for the data transfer of the stream triad computation between cache levels. If the data is in main memory, the time it takes to get the data to the CPU is the sum of the transfer times between each cache level or 21.7 + 8 + 5 + 3 = 37.7 cycles. The floating-point operations only take 3 cycles, so the memory loads are the limiting aspect for the stream triad.**

For the stream triad, we have a cache line of multiply-add operations. If this is done with a scalar operation, it takes 8 cycles to complete. But we can do this with the new Advanced Vector Extensions (AVX) instructions. The Haswell chip has two fused multiply-add (FMA) AVX 256-bit vector units. Each of these units processes four double-precision values. There are eight values in a cache line, so two FMA AVX vector units can process this in one cycle. T_(nOL) is the data transfer time. We need to load cache lines for B and C, and we need to load and store a cache line for A. This takes 3 cycles for the Haswell chip because of a limitation of the address generation units (AGUs).

Moving the four cache lines from L2 to L1 at 64 bytes/cycle takes 4 cycles. But the use of `A[i]` is a store operation. A store generally requires a special load called a write-allocate, where the memory space is allocated in the virtual data manager, and the cache line created at the necessary cache levels. Then the data is modified and evicted (stored) from the cache. This can only operate at 32 bytes/cycle at this level of cache, resulting in an additional cycle or a total of 5 cycles. From L3-L2, the data transfer is 32 bytes/cycle, so it takes 8 cycles. And finally, using the measured bandwidth of 27.1 GB/s, the number of cycles to move the cache lines from main memory is about 21.7 cycles. ECM uses this special notation to summarize these numbers:

{T_(OL) \|\| T_(nOL) \| T_(L1L2) \| T_(L2L3) \| T_(L3Mem)} = {1 \|\| 3 \| 5 \| 8 \| 21.7} cycles

The T_(core) is shown by the T_(OL) \|\| T_(nOL) in the notation. These are essentially the times (in cycles) to move between each level, with a special case for the T_(core), where some of the operations on the computational core can overlap some of the data transfer operations from L1 to the registers. Then the model predicts the number of cycles it would take to load from each level of the cache by summing the data transfer time, including the non-overlapping data transfers from L1 to registers. The max of the T_(OL) and the data transfer time is then used as the predicted time:

T_(ECM) = max(T_(nOL) + T_(data), T_(OL))

This special ECM notation shows the resulting prediction for each cache level:

{3⎤8⎤16⎤37.7} cycles

This notation says that the kernel takes 3 cycles when it operates out of the L1 cache, 8 out of L2 cache, 16 out of L3, and 37.7 cycles when the data has to be retrieved from main memory.

What can be learned from this example is that bumping up against a discrete hardware limit on a particular chip with a particular kernel can force another cycle or two at one of the transfers between cache levels, causing slower performance. A slightly different version of the processor might not have the same problem. For example, later versions of Intel chips add another AGU, which changes the L1-register cycles from 3 to 2.

This example also demonstrates that the vector units have value for both arithmetic operations and data movement. The vector load, also known as a quad-load operation, is not new. Much of the focus in the discussion on vector processors is on the arithmetic operations. But for bandwidth-limited kernels, it is likely that the vector memory operations are more important. An analysis by Stengel, et al. using the ECM model shows that the AVX vector instructions can give a two times performance improvement over loops that the compiler naively schedules. This is perhaps because the compiler does not have enough information available. More recent vector units also implement a gather/scatter memory load operation where the data loaded into the vector unit does not have to be in contiguous memory locations (gather) and the store from the vector to memory does not have to be contiguous memory locations (scatter).

> > > **NOTE** This new gather/scatter memory load feature is welcomed as many real numerical simulation codes need it to perform well. But there are still performance issues with the current gather/scatter implementation and more improvement is needed.

We can also analyze the performance of the cache hierarchy with the streaming store. The streaming store bypasses the cache system and writes directly to main memory. There is an option in most compilers to use streaming stores, and some invoke it as an optimization on their own. Its effect is to reduce the number of cache lines being moved between levels of the cache hierarchy, reducing congestion and the slower eviction operation between levels of the cache. Now that you have seen the effect of the cache-line movement, you should be able to appreciate its value.

The ECM model is used to evaluate and optimize stencil kernels by several researchers. Stencil kernels are streaming operations and can be analyzed with these techniques. It gets a little messy to keep track of all the cache lines and hardware characteristics without making mistakes, so performance counting tools can help. We’ll refer you to a couple of references listed in appendix A for further information on these.

The advanced models are great for understanding the performance of relatively simple streaming kernels. Streaming kernels are those that load data in a nearly optimal way to effectively use the cache hierarchy. But kernels in scientific and HPC applications are often complex with conditionals, imperfectly nested loops, reductions, and loop-carried dependencies. In addition, compilers can transform the high-level language to assembler operations in unexpected ways, which complicate the analysis. There are usually a lot of kernels and loops to deal with as well. It is not feasible to analyze these complex kernels without specialized tools, so we try to develop general ideas from the simple kernels that we can apply to the more complex ones.

***4.5 Network messages***

We can extend our data transfer models for use in analyzing the computer network. A simple network performance model between nodes of a cluster or an HPC system is

Time (ms) = latency (µsecs) + bytes_moved (MBytes) /(bandwidth (GB/s) (with unit conversions)

Note that this is a network bandwidth rather than the memory bandwidth we have been using. There is an HPC benchmark site for latency and bandwidth at

<http://icl.cs.utk.edu/hpcc/hpcc_results_lat_band.cgi>

We can use the network micro-benchmarks from the HPC benchmark site to get typical latency and bandwidth numbers. We’ll use 5 µsecs for the latency and 1 GB/s for the bandwidth. This gives us the plot shown in figure 4.23. For larger messages, we can estimate about 1 s for every MB transferred. But the vast majority of messages are small. We look at two different communication examples, first a larger message and then a smaller one, to understand the importance of latency and bandwidth in each.

**Figure 4.23 Typical network transfer time as a function of the size of the message gives us a rule of thumb: 1 MB takes 1 s (second), 1 KB takes 1 ms (millisecond), or 1 byte takes 1 microsec.**

> **Example: Ghost cell communication**

> Let’s take a 1000×1000 mesh. We need to communicate the outside cells of our processor as shown in the following figure to the adjacent processor so that it can complete its calculation. The extra cells placed on the outside of the mesh for the processor are called ghost cells.

> 1000 elements in outside cells \* 8 bytes = 8 KB

> Communication time = 5 µsecs + 8 ms

>   

> **Outer cell data is exchanged with adjacent processors so that the stencil calculation is operating on current values. The dashed cells are called ghost cells because these hold duplicated data from another processor. The arrows only show the data exchange for every other cell for clarity.**

> **Example: Sum number of cells across processors**

> We need to transfer the number of cells to the adjacent processor to sum and then return the sum. There are two communications of a 4-byte integer.

> Communication time = (5 µsecs + 4 µsecs) \* 2 = 18 µsecs

> In this case, the latency is significant in the overall time taken for the transmission of the message.

The last sum example is a reduction operation in computer science lingo. An array of cell counts across the processors is reduced into a single value. More generally, a reduction operation is any operation where a multidimensional array from 1 to N dimensions is reduced to at least one dimension smaller and often to a scalar value. These are common operations in parallel computing and involve cooperation among the processors to complete. Also, the reduction sum in the last example can be performed in pair-wise fashion in a tree-like pattern with the number of communication hops being log₂N, where N is the number of ranks (processors). When the number of processors reaches into the thousands, the time for the operation grows larger. Perhaps more importantly, all of the processors have to synchronize at the operation, leading to many of those waiting for the other processors to get to the reduction call.

There are more complex models for network messages that might be useful for specific network hardware. But the details of network hardware vary enough that these may not shed much light on the general behavior across all possible hardware.

***4.6 Further explorations***

Here are some resources for exploring the topics in this chapter, including data-oriented design, data structures, and performance models. Most application developers find the additional materials on data-oriented design to be interesting. Many applications can exploit sparsity, and we can learn how from the case study on compressed sparse data structures.

***4.6.1 Additional reading***

The following two references give good descriptions of the data-oriented design approach developed in the gaming community for building performance into program design. The second reference also gives the location of the video of Acton’s presentation at CppCon.

- Noel Llopis, “Data-oriented design (or why you might be shooting yourself in the foot with OOP)” (Dec, 2009). Accessed February 21, 2021. [http://gamesfromwithin .com/data-oriented-design](http://gamesfromwithin.com/data-oriented-design).

- Mike Acton and Insomniac Games, “Data-oriented design and C++.” Presentation at CppCon (September, 2014):

- Powerpoint at <https://github.com/CppCon/CppCon2014>

- Video at <https://www.youtube.com/watch?v=rX0ItVEVjHc>

The following reference is good for going into more detail on the case study of compressed sparse data structures using simple performance models. You’ll also find measured performance results on multi-core and GPUs:

Shane Fogerty, Matt Martineau, et al., “A comparative study of multi-material data structures for computational physics applications.” In Computers & Mathematics with Applications Vol. 78, no. 2 (July, 2019): 565-581. The source code is available at <https://github.com/LANL/MultiMatTest>.

The following paper introduces the shorthand notation used for the Execution Cache Model:

Holger Stengel, Jan Treibig, et al., “Quantifying performance bottlenecks of stencil computations using the execution-cache-memory model.” In Proceedings of the 29th ACM on International Conference on Supercomputing (ACM, 2015): 207-216.

***4.6.2 Exercises***

1.  Write a 2D contiguous memory allocator for a lower-left triangular matrix.

2.  Write a 2D allocator for C that lays out memory the same way as Fortran.

3.  Design a macro for an Array of Structures of Arrays (AoSoA) for the RGB color model in section 4.1.

4.  Modify the code for the cell-centric full matrix data structure to not use a conditional and estimate its performance.

5.  How would an AVX-512 vector unit change the ECM model for the stream triad?

***Summary***

- Data structures are at the foundation of application design and often dictate performance and the resulting implementation of parallel code. It is worth a little additional effort to develop a good design for the data layout.

- You can use the concepts of data-oriented design to develop higher performing applications.

- There are ways to write contiguous memory allocators for multidimensional arrays or special situations to minimize memory usage and improve performance.

- You can use compressed storage structures to reduce your application’s memory usage while also improving performance.

- Simple performance models based on counting loads and stores can predict the performance of many basic kernels.

- More complex performance models shed light on the performance of the cache hierarchy with respect to low-level details in the hardware architecture.
