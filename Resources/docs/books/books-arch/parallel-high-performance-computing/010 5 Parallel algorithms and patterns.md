# 5 Parallel algorithms and patterns

***5 Parallel algorithms and patterns***

This chapter covers

- What parallel algorithms and patterns are and their importance
- How to compare the performance of different algorithms
- What distinguishes parallel algorithms from other algorithms

Algorithms are at the core of computational science. Along with data structures, covered in the previous chapter, algorithms form the basis of all computational applications. For this reason, it is important to give careful thought to the key algorithms in your code. To begin, let’s define what we mean by parallel algorithms and parallel patterns.

- A parallel algorithm is a well-defined, step-by-step computational procedure that emphasizes concurrency to solve a problem. Examples of algorithms include sorting, searching, optimization, and matrix operations.

- A parallel pattern is a concurrent, separable fragment of code that occurs in diverse scenarios with some frequency. By themselves, these code fragments generally do not solve complete problems of interest. Some examples include reductions, prefix scans, and ghost cell updates.

We will show the reduction in section 5.7, the prefix scan in section 5.6, and ghost cell updates in section 8.4.2. In one context, a parallel procedure can be considered an algorithm, and in another, it can be a pattern. The real difference is whether it is accomplishing the main goal or just part of a larger context. Recognizing patterns that are “parallel friendly” is important to prepare for later parallelization efforts.

***5.1 Algorithm analysis for parallel computing applications***

The development of parallel algorithms is a young field. Even the terminology and techniques to analyze parallel algorithms are still stuck in the serial world. One of the more traditional ways to evaluate algorithms is by looking at their algorithmic complexity. Our definition of algorithmic complexity follows.

> > > **DEFINITION** Algorithmic complexity is a measure of the number of operations that it would take to complete an algorithm. Algorithmic complexity is a property of the algorithm and is a measure of the amount of work or operations in the procedure.

Complexity is usually expressed in asymptotic notation. Asymptotic notation is a type of expression that specifies the limiting bounds of performance. Basically, the notation identifies whether the run time grows linearly or whether it progresses at a more accelerated rate with the problem’s size. The notation uses various forms of the letter O, such as O(N ), O(N log N ) or O(N ²). N is the size of a long array such as the number of cells, particles, or elements. The combination of O() and N refers to how the cost of the algorithm scales as the size N of the array grows. The O can be thought of as “order” as in “scales on the order of.” Generally, a simple loop over N items will be O(N ), a double-nested loop will be O(N ²), and a tree-based algorithm will be O(N log N ). By convention, the leading constants are dropped. The most commonly used asymptotic notations are

- Big O—This is the worst case limit of an algorithm’s performance. Examples are a doubly nested `for` loop for a large array of size N, which would be O(N ²) complexity.

- Big Ω (Big Omega)—The best case performance of an algorithm.

- Big Θ (Big Theta)—The average case performance of an algorithm.

Traditional analysis of algorithms uses algorithmic complexity, computational complexity, and time complexity interchangeably. We will define the terms a bit differently to help us evaluate algorithms on today’s parallel computing hardware. Time doesn’t scale with the amount of work and neither does the computational effort or cost. We thus make the following adjustments to the definitions for computational complexity and time complexity:

- Computational complexity (also called step complexity) is the number of steps that are needed to complete an algorithm. This complexity measurement is an attribute of the implementation and the type of hardware that is used for the calculation. It includes the amount of parallelism that is possible. If you’re using a vector or multi-core computer, a step (cycle) can be four or more floating-point operations. Can you use these additional operations to reduce the number of steps?

- Time complexity takes into account the actual cost of an operation on a typical modern computing system. The largest adjustment for time is to consider the cost of memory loads and the caching of data.

We’ll use complexity analysis for some of our algorithm comparisons, such as the prefix sum algorithms in section 5.5. But for applied computer scientists, the asymptotic complexity of an algorithm is somewhat one-dimensional and of limited use. It only tells us the cost of an algorithm in the limit as it grows larger. In an applied setting, we need a more complete model of an algorithm. We’ll see why in the next section.

***5.2 Performance models versus algorithmic complexity***

We first introduced performance models in chapter 4 to analyze the relative performance of different data structures. In a performance model, we build a much more complete description of the performance of an algorithm than in algorithmic complexity analysis. The biggest difference is that we don’t hide the constant multiplier in front of the algorithm. But there is also a difference in the terms such as log N for scaling. The actual count of operations is from a binary tree and should be log2 N.

In traditional algorithmic complexity analysis, the difference between the two logarithmic terms is a constant that gets absorbed into the constant multiplier. In common world problems, these constants could matter and don’t cancel out; therefore, we need to use a performance model to differentiate between different approaches of a similar algorithm. To further understand the benefits of using performance models, let’s start with an example from everyday life.

> **Example**

> You are one of the organizers of a conference with 100 participants. You want to hand out registration packets to each participant. Here are some algorithms that you can use:

1.  Have all 100 participants form a line as you search through 100 folders to find the packet to hand to each participant in turn. The worst case is that you will have to look through all 100 folders. On average, you will look through 50. If there is no packet, you have to look through all 100.

2.  Presort the packets alphabetically prior to registration. Now you can use a bisection search to find each folder.

Returning to the first algorithm in the example, let’s assume for simplicity’s sake that the folders remain after the packets are handed out to a participant, such that the number of folders stays constant at the original number. There are N participants and N folders, creating a doubly nested loop. The computation is of order N ² operations, or O(N ²) in Big O asymptotic notation for the worst case. If the folders decreased each time, the computation would be (N + N - 1 + N - 2 . . .) or an O(N ²) algorithm. The second algorithm can exploit the sorted order of the folders with a bisection search so the algorithm can be done for the worst case in O(NlogN ) operations.

Asymptotic complexity tells us how the algorithm performs as we reach large sizes, such as one million participants. But we won’t ever have one million participants. We will have a finite size of 100 participants. For finite sizes, a more complete picture of the algorithmic performance is needed.

To illustrate this, we apply a performance model to one of the most basic computer algorithms to see how it might give us more insight. We’ll use a time-based model where we include the real hardware costs rather than an operation-based count. In this example, we look at a bisection search, also known as a binary search. It is one of the most common computer algorithms and numerical optimization techniques. Conventional asymptotic analysis says that the binary search is much faster than a linear search. We’ll show that accounting for how real computers function, the increase in speed is not as much as might be expected. This analysis also helps to explain the table lookup results in section 5.5.1.

> **Example: Bisection search versus linear search**

> The bisection search algorithm can be used to find the correct entry in a sorted array of 256 integer elements. This algorithm takes the midpoint, bisecting the remaining possible range in a recursive manner. In a performance model, a bisection search would have log2 256 steps or 8, while a linear search would have a worst case of 256 steps and an average of 128. If we count cache line loads for a 4-byte integer array, the linear search would only be 16 cache line loads for the worst case and 8 on average. The binary search would require 4 cache line loads for the worst case and about 4 for the average case. It is imperative to highlight that this linear search would only be two times slower than a binary search, instead of the 16 times slower that we might expect.

> In this analysis, we assume any operation on data in the cache is essentially free (actually a couple of cycles), while a cache line load is on the order of about 100 cycles. We just count the cache line loads and ignore the comparison operations. For our time-based performance model, we would say the cost of the linear search is (n / 16) / 2 = 8 and the bisection search is log2(n / 16) = 4.

> How the cache behaves changes the result by a large amount for these short array lengths. The bisection search is still faster, but not by as much as the simpler analysis would have us expect.

Though asymptotic complexity is used to understand performance as an algorithm scales, it does not provide an equation for absolute performance. For a given problem, linear search, which scales linearly, might outperform a bisection search, which scales logarithmically. This is especially true when you parallelize the algorithm as it is much simpler to scale a linearly scaled algorithm than a logarithmically scaled algorithm. In addition, the computer is designed to linearly walk through an array and prefetch data, which can speedup performance a little more. Finally, the specific problem can have the item occurring at the beginning of the array, where a bisection search performs much worse than a linear search.

As an example of other parallel considerations, let’s look at the implementation of the search on 32 threads of a multi-core CPU or a GPU. The set of threads must wait for the slowest to complete during each operation. The bisection search always takes 4 cache loads. The linear search varies in the number of cache lines required for each thread. The worst case controls how long the operation takes, making the cost closer to 16 cache lines than the average of 8 cache lines.

So you ask, how does this work in practice? Let’s look at the two variations of the table lookup code described in the example. You can test the following algorithms on your system with the perfect hash code included in the accompanying source code for this chapter at <https://github.com/EssentialsofParallelComputing/Chapter5>. First, the following listing shows the linear search algorithm version of the table lookup code.

**Listing 5.1 Linear search algorithm in a table lookup**

> `PerfectHash/table.c`  
>   
> `268 double *interpolate_bruteforce(int isize, int xstride,`  
> `       int d_axis_size, int t_axis_size, double *d_axis, double *t_axis,`  
> `269    double *dens_array, double *temp_array, double *data)`  
> `270 {`  
> `271   int i;`  
> `272`  
> `273   double *value_array=(double *)malloc(isize*sizeof(double));`  
> `274`  
> `275   for (i = 0; i<isize; i++){`  
> `276     int tt, dd;`  
> `277`  
> `276     int tt, dd;`  
> `277`  
> `278     for (tt=0; tt<t_axis_size-2 &&              `❶  
> `             temp_array[i] > t_axis[tt+1]; tt++);   `❶  
> `279     for (dd=0; dd<d_axis_size-2 &&              `❶  
> `             dens_array[i] > d_axis[dd+1]; dd++);   `❶  
> `280`  
> `281     double xf = (dens_array[i]-d_axis[dd])/     `❷  
> `                    (d_axis[dd+1]-d_axis[dd]);      `❷  
> `282     double yf = (temp_array[i]-t_axis[tt])/     `❷  
> `                    (t_axis[tt+1]-t_axis[tt]);      `❷  
> `283     value_array[i] =`  
> `                 xf *     yf *data(dd+1,tt+1)       `❷  
> `284       + (1.0-xf)*     yf *data(dd,  tt+1)       `❷  
> `285       +      xf *(1.0-yf)*data(dd+1,tt)         `❷  
> `286       + (1.0-xf)*(1.0-yf)*data(dd,  tt);        `❷  
> `287`  
> `288   }`  
> `289`  
> `290   return(value_array);`  
> `291 }`

❶ Specifies a linear search from 0 to axis_size

❷ Interpolation

The linear search of the two axes is done in lines 278 and 279. The coding is simple and straightforward, resulting in a cache-friendly implementation. Now let’s look at the bisection search in the following listing.

**Listing 5.2 Bisection search algorithm in a table lookup**

> `PerfectHash/table.c`  
>   
> `293 double *interpolate_bisection(int isize, int xstride,`  
> `       int d_axis_size, int t_axis_size, double *d_axis, double *t_axis,`  
> `294    double *dens_array, double *temp_array, double *data)`  
> `295 {`  
> `296   int i;`  
> `297`  
> `298   double *value_array=(double *)malloc(isize*sizeof(double));`  
> `299`  
> `300   for (i = 0; i<isize; i++){`  
> `301     int tt = bisection(t_axis, t_axis_size-2,      `❶  
> `                           temp_array[i]);             `❶  
> `302     int dd = bisection(d_axis, d_axis_size-2,      `❶  
> `                           dens_array[i]);             `❶  
> `303`  
> `304     double xfrac = (dens_array[i]-d_axis[dd])/     `❷  
> `                       (d_axis[dd+1]-d_axis[dd]);      `❷  
> `305     double yfrac = (temp_array[i]-t_axis[tt])/     `❷  
> `                       (t_axis[tt+1]-t_axis[tt]);      `❷  
> `306     value_array[i] =`  
> `                xfrac *     yfrac *data(dd+1,tt+1)     `❷  
> `307      + (1.0-xfrac)*     yfrac *data(dd,  tt+1)     `❷  
> `308      +      xfrac *(1.0-yfrac)*data(dd+1,tt)       `❷  
> `309      + (1.0-xfrac)*(1.0-yfrac)*data(dd,  tt);      `❷  
> `310   }`  
> `311`  
> `312   return(value_array);`  
> `313 }`  
> `314`  
> `315 int bisection(double *axis, int axis_size, double value)`  
> `316 {`  
> `317   int ibot = 0;                                    `❸  
> `318   int itop = axis_size+1;                          `❸  
> `319`  
> `320   while (itop - ibot > 1){                         `❸  
> `321     int imid = (itop + ibot) /2;                   `❸  
> `322     if ( value >= axis[imid] )                     `❸  
> `323       ibot = imid;                                 `❸  
> `324     else                                           `❸  
> `325       itop = imid;                                 `❸  
> `326   }                                                `❸  
> `327   return(ibot);`  
> `328 }`

❶ Bisection calls

❷ Interpolation

❸ Bisection algorithm

The bisection code is slightly longer than the linear search (listing 5.1), but it should have less operational complexity. We’ll look at other table search algorithms in section 5.5.1 and show their relative performance in figure 5.8.

Spoiler: the bisection search is not much faster than the linear search as you might expect, even accounting for the cost of the interpolation. Although this is the case, this analysis shows the linear search is not as slow as you might expect either.

***5.3 Parallel algorithms: What are they?***

Now let’s take another example from everyday life to introduce some ideas for parallel algorithms. This first example demonstrates how an algorithmic approach that is comparison-free and less synchronous can be easier to implement and can perform better for highly parallel hardware. We discuss additional examples in the following sections that highlight spatial locality, reproducibility, and other important attributes for parallelism and then summarize all of the ideas in section 5.8 at the end of the chapter.

> **Example: Comparison sort versus hash sort**

> You want to sort the 100 participants in the auditorium from the previous example. First, you try a comparison sort.

1.  Sort a room by having each person compare their last name to their neighbor in their row and move left if their last name is earlier in alphabetical sequence and right if later.

2.  Continue for up to N steps, where N is the number of people in the room.

> For GPUs, a workgroup cannot communicate with another workgroup. Let’s assume each row in the auditorium is a workgroup. When you reach the end of the row, it is like you have reached the limit of the GPU workgroup, and you have to exit the kernel to do a comparison with the next row. Having to exit the kernel means that it takes multiple kernel invocations, adding to coding complexity and to run time. There will be more on how a GPU functions in chapters 9 and 10.

> Now, let’s look at a different sorting algorithm: the hash sort. The best way to understand a hash sort is through the following example. We’ll go into more detail on the elements of a hash function in section 5.4.

1.  Place a sign for each letter at the front of the room.

2.  Each person goes to the table with the first letter of their last name.

3.  For letters with large numbers of participants, repeat for the second letter in the last name. For small numbers of participants, do any simple sort, including the one described previously.

> The first sort is a comparison sort using a bubble sort algorithm, which generally performs poorly. The bubble sort steps through a list, compares adjacent elements, and swaps these if they are in an incorrect order. The algorithm goes repeatedly through the list until the list is sorted. The best comparison sort has an algorithmic complexity limit of O(N log N). The hash sort breaks this barrier because it doesn’t

> use comparisons. On average, the hash sort is an Θ(1) operation for each participant and Θ(N) for all participants. The faster performance is significant; more importantly, the operations for each participant are completely independent. Having the operations completely independent makes the algorithm easy to parallelize, even on less synchronous GPU architectures.

> Combining this all together, we can use the hash sort to put the participants and folders in alphabetical order and add parallelism by having multiple lines divide up by the alphabet at the registration table. The two hash sorts will be Θ(N) and in parallel will be Θ(N/P) where P is the number of processors. For 16 processors and 100 participants, the parallel speedup from the serial, brute-force method is 1002/(100/16) = 1,600x. We recognize that the hash design is similar to what we see in well-organized conferences or school registration lines.

***5.4 What is a hash function?***

In this section, we will discuss the importance of a hash function. Hashing techniques originated in the 1950s and 60s, but have been slow to be adapted to many application areas. Specifically, we will go through what constitutes a perfect hash, spatial hashing, perfect spatial hashing, along with all the promising use cases.

A hash function maps from a key to a value, much like a dictionary uses a word as the lookup key to its definition. In figure 5.1, the word Romero is the key that is hashed to look up the value, which in this case is the moniker or username. Unlike a physical dictionary, a computer needs at least 26 possible storage locations times the maximum length of the dictionary key. So for a computer, it is absolutely necessary to encode the key into a shorter form called a hash. The term hash or hashing refers to “chopping up” the key into a shorter form to use as an index to store the value. The location for storing the collection of values for a specific key is called a bucket or bin. There are many different ways to generate a hash from a key; the best approaches are generally problem-specific.

**Figure 5.1 Hash table to lookup a computer moniker by last name. In ASCII, R is 82 and O is 79. We can then calculate the first hash key with 82 - 64 + 26 + 79 - 4 = 59. The value stored in the hash table is the username, sometimes called a moniker.**

A perfect hash is one where there is one entry in each bucket at most. Perfect hashes are simple to handle, but can take more memory. A minimal perfect hash is just one entry in each bucket and with no empty buckets. It takes longer to calculate minimal perfect hashes, but for example, for fixed sets of programming keywords, the extra time is worth it. For most of the hashes we’ll discuss here, the hashes will be created on the fly, queried, and thrown away, so a faster creation time is more important than memory size. Where a perfect hash is not feasible or takes too much memory, a compact hash can be employed. A compact hash compresses the hash so that it requires less storage memory. As always, there are tradeoffs in programming complexity, run time, and required memory among the different hashing methods.

The load factor is the fraction of the hash that is filled. It is computed by n/k, where n is the number of entries in the hash table and k is the number of buckets. Compact hashes still work at load factors of .8 to .9, but the efficiency drops off after that due to collisions. Collisions occur when more than one key wants to store its value in the same bucket. It is important to have a good hash function that distributes keys more uniformly, avoiding the clustering of entries, thereby allowing higher load factors. With a compact hash, both the key and the value are stored so that on retrieval, the key can be checked to see if it is the right entry.

In the previous examples, we used the first letter of the last name as a simple hash key. While effective, there are certainly flaws with using the first letter. One is that the number of last names starting with each letter in the alphabet is not evenly distributed, leading to unequal numbers of entries in each bucket. We could instead use the integer representation of the string, which produces a hash for the first four letters of the name. But the character set gives only 52 possible values for the 256 storage locations for each byte, leading to only a fraction of possible integer keys. A special hash function that expects only characters would need far fewer storage locations.

***5.5 Spatial hashing: A highly-parallel algorithm***

Our discussion in chapter 1 used a uniform-sized, regular grid from the Krakatau example in figure 1.9. For this discussion on parallel algorithms and spatial hashing, we need to use more complex computational meshes. In scientific simulations, more complex meshes define with more detail the areas that we are interested in. In big data, specifically image analysis and categorization, these more complex meshes are not widely adopted. Yet the technique would have great value there; when a cell in the image has mixed characteristics, just split the cell.

The biggest impediment to using more complex meshes is that coding becomes more complicated and we must incorporate new computational techniques. For complex meshes, it is a greater challenge to find methods that work and scale well on parallel architectures. In this section, we’ll show you how you can handle some of the common spatial operations with highly parallel algorithms.

> **Example: Krakatau wave simulation**

> Your team is working on their wave application and decides they need more resolution for the simulation in some areas at the wave front and at the shoreline as shown in figure 1.9. They don’t, however, need fine resolution in other parts of the grid. The team decides to take a look at adaptive mesh refinement (AMR), where they can put finer mesh resolution in areas that need it.

Cell-based adaptive mesh refinement (AMR) belongs to a class of unstructured mesh techniques that no longer have the simplicity of a structured grid to locate data. In cell-based AMR (figure 5.2), the cell data arrays are one-dimensional, and the data can be in any order. The mesh locations are carried along in additional arrays that have the size and location information for each cell. Thus, there is some structure to the grid, but the data is completely unstructured. Taking this further into unstructured territory, a fully-unstructured mesh could have cells of triangles, polyhedra, or other complex shapes. This allows the cells to “fit” the boundaries between land and ocean, but at the cost of more complex numerical operations. Because many of the same parallel algorithms for unstructured data apply to both, we’ll work mostly with the cell-based AMR example.

**Figure 5.2 A cell-based AMR mesh for a wave simulation from the CLAMR mini-app. The black squares are the cells and the variously-shaded squares represent the height of a wave radiating outward from the upper right corner.**

AMR techniques can be broken down into patch, block, and cell-based approaches. The patch and block methods use various size patches or fixed-size blocks that can at least partially exploit the regular structure of these groups of cells. Cell-based AMR has truly unstructured data that can be in any order. A shallow-water, cell-based AMR mini-app, CLAMR (<https://github.com/lanl/CLAMR.git>), was developed by Davis, Nicholaeff, and Trujillo while they were summer students in 2011 at Los Alamos National Laboratory. They wanted to see if cell-based AMR applications could run on GPUs. In the process, they found breakthrough parallel algorithms that also made CPU implementations run faster. The most important of these was a spatial hash.

Spatial hashing is a technique where the key is based on spatial information. The hashing algorithm retains the same average algorithmic complexity of Θ(1) operations for each lookup. All spatial queries can be performed with a spatial hash; many are much faster than alternative methods. The basic principle is to map objects onto a grid of buckets arranged in a regular pattern.

A spatial hash is shown in the center of figure 5.3. The sizing of the buckets is selected based on the characteristic size of the objects to map. For a cell-based AMR mesh, the minimum cell size is used. For particles or objects, as shown on the right in the figure, the cell size is based on the interaction distance. This choice means that only the cells immediately adjacent need to be queried for interaction or collision calculations. Collision calculations are one of the great application areas for spatial hashes, not only in scientific computing for smooth particle hydrodynamics, molecular dynamics, and astrophysics, but also in gaming engines and computer graphics. There are many situations where we can exploit spatial locality to reduce computational costs.

**Figure 5.3 Computational meshes, particles, and objects mapped onto a spatial hash. The polyhedra of the unstructured mesh and the rectangular cells of the cell-based adaptive refinement mesh can be mapped to a spatial hash for spatial operations. Particles and geometric objects can also benefit from being mapped to a spatial hash to provide information about their spatial locality so that only nearby items need to be considered.**

Both the AMR and the unstructured mesh on the left in the figure are referred to as differential discretized data because the cells are smaller where the gradients are steeper to better resolve the physical phenomena. But these have a limit to how much smaller the cells can get. The limit keeps the bucket sizes from getting too small. Both meshes store their cell indices in all the underlying buckets of the spatial hash. For the particles and geometric objects, the particle indices and object identifiers are stored in the buckets. This provides a form of locality that keeps the computational cost from increasing as the problem size increases. For example, if the problem domain is increased on the left and top, the interaction calculation in the lower right of the spatial hash stays the same. The algorithmic complexity thus stays Θ(N ) for the particle calculations instead of growing to Θ(N ²). The following listing shows the pseudo code for the interaction loop, which is over nearby locations for the inner loop instead of having to search through all the particles.

**Listing 5.3 Particle interaction pseudo-code**

> `1 forall particles, ip, in NParticles{`  
> `2    forall particles, jp, in Adjacent_Buckets{`  
> `3       if (distance between particles < interaction_distance){`  
> `4          perform collision or interaction calculation`  
> `5       }`  
> `6    }`  
> `7 }`

***5.5.1 Using perfect hashing for spatial mesh operations***

We’ll first look at perfect hashing to focus on the use of hashing rather than the mechanics internal to hashing. These methods all rely on being able to guarantee that there will be only one entry in each bucket, avoiding the issues of handling collisions where a bucket might have more than one data entry. For perfect hashing, we’ll investigate the four most important spatial operations:

- Neighbor finding—Locating the one or two neighbors on each side of a cell

- Remapping—Mapping another AMR mesh onto a current AMR mesh

- Table lookup—Locating the intervals in the 2D table to perform the interpolation

- Sorting—A 1D or 2D sort of the cell data

All of the source code for the examples for the four operations in 1D and 2D is available at <https://github.com/lanl/PerfectHash.git> under an open source license. The source is also linked into the examples for this chapter. The perfect hash code uses CMake and tests for the availability of OpenCL. If you do not have OpenCL capability, the code detects that and will not compile the OpenCL implementations. The rest of the cases on the CPU will still run.

***NEIGHBOR FINDING USING A SPATIAL PERFECT HASH***

Neighbor finding is one of the most important spatial operations. In scientific computing, the material moved out of one cell has to move into the adjacent cell. We need to know which cell to move to in order to compute the amount of material and move it. In image analysis, the characteristics of the adjacent cell can give important information on the composition of the current cell.

The rules for the AMR mesh in CLAMR are that there can be only a single-level jump in refinement across a face of a cell. Also, the neighbor list of each cell on each side is just one of the neighbor cells, and the choice is to be the lower cell or the cell to the left of each pair as figure 5.4 shows. The second of the pair is found by using the neighbor list of the first cell; for example, `ntop[nleft[ic]]`. The problem then becomes setting up the neighbor arrays for every cell.

**Figure 5.4 The left neighbor is the lower cell of the two to the left, and the bottom neighbor is the cell to the left of the two below. Similarly, the right neighbor is the lower cell of the two to the right, and the top neighbor is to the left of the two cells above.**

What are the possible algorithms for finding neighbors? The naive way is to search all the other cells for the cell that is adjacent. This can be done by looking at the i, j, and level variables in each cell. The naive algorithm is O(N ²). It performs well with small numbers of cells, but the run-time complexity grows large quickly. Some common alternative algorithms are tree-based, such as the k-D tree and quadtree algorithms (octree in three dimensions). These are comparison-based algorithms that scale as O(N log N ), which are defined later. The code for the 2D neighbor calculation, including the k-D tree, brute force, CPU, and GPU hash implementations is available at <https://github.com/lanl/PerfectHash.git>, along with the other spatial perfect hash applications discussed later in this chapter.

The k-D tree splits the mesh into two equal halves in the x-dimension and then two equal halves in the y-dimension, repeating until it finds the object. The algorithm to build the k-D tree is O(N log N ), and each search is also O(N log N ).

The quadtree has four children for each parent, one for each quadrant. This exactly maps to the subdivision of the cell-based AMR mesh. A full quadtree starts from the top, or root, with one cell and subdivides to the finest level of the AMR mesh. A “truncated” quadtree starts from the coarsest level of the mesh and has a quadtree for each coarse cell to map down to the finest level. The quadtree algorithm is a comparison-based algorithm: O(N log N ).

The limitation of just one level jump across a face is called a graded mesh. In cell-based AMR, graded meshes are common, but other quadtree applications such as n -body applications in astrophysics result in much larger jumps in the quadtree data structure. The one-level jump in refinement allows us to improve the algorithm design for finding neighbors. We can start our search at the leaf that represents our cell and, at most, we only have to go up two levels of the tree to find our neighbor. For searching for a near neighbor of similar size, the search should start at the leaves and use a quadtree. For searches for large irregular objects, the k-D tree should be used and the search should start from the root of the tree. Proper use of tree-based search algorithms can provide a viable implementation on CPUs, but the comparisons and tree construction present difficulties on GPUs, where comparisons beyond the work group cannot be done easily.

This sets the stage for the design of a spatial hash to perform the neighbor finding operation. We can guarantee that there are no collisions in our spatial hash by making the buckets in the hash the size of the finest cells in the AMR mesh. The algorithm then becomes

- Allocate a spatial hash the size of the finest level of the cell-based AMR mesh

- For each cell in the AMR mesh, write the cell number to the hash buckets underlying the cell

- Compute the index for a finer cell one cell outside the current cell on each side

- Read the value placed in the hash bucket at that location

For the mesh shown in figure 5.5, the write phase is followed by a read phase to look up the index of the right neighbor cell.

**Figure 5.5 Finding the right neighbor of cell 21 using a spatial perfect hash**

This algorithm is well suited to GPUs and is shown in listing 5.5. The first implementation took less than a day to port from the CPU to the GPU. The original k-D tree would take weeks or months to implement on the GPU. The algorithmic complexity also breaks the O(log N ) threshold and is, on average, Θ(N) for N cells.

This first implementation of the perfect hash neighbor calculation was an order of magnitude faster on the CPU than the k-D tree method, and an additional order of magnitude faster on the GPU than a single core of a CPU for a total of 3,157x speedup (figure 5.6). The algorithm performance study was done on an NVIDIA V100 GPU and a Skylake Gold 5118 CPU with a nominal clock frequency of 2.30 GHz. All the results in this chapter used this architecture as well. The CPU core and GPU architecture are the best available around 2018, giving a Best(2018) parallel speedup comparison (see section 1.6 for speedup notation). But it isn’t an architecture comparison between the CPU and the GPU. If the 24 virtual cores on this CPU were utilized, the CPU would also see a considerable parallel speedup.

**Figure 5.6 The algorithm and parallel speedup total 3,157x. The new algorithm enables the parallel speedup on the GPU.**

How hard is it to write the code for this kind of performance? Let’s take a look at the code for the hash table in listing 5.4 for the CPU. The input to the routine are the 1D arrays, `i`, `j`, and `level`, where `level` is the refinement level, and `i` and `j` are the row and column of the cell in the mesh at that cell’s refinement level. The whole listing is about a dozen lines.

**Listing 5.4 Writing out a spatial hash table for the CPU**

> `neigh2d.c from PerfectHash`  
> `452 int *levtable = (int *)malloc(levmx+1);      `❶  
> `453 for (int lev=0; lev<levmx+1; lev++)          `❶  
> `       levtable[lev] = (int)pow(2,lev);          `❶  
> `454`  
> `455 int jmaxsize = mesh_size*levtable[levmx];    `❷  
> `456 int imaxsize = mesh_size*levtable[levmx];    `❷  
> `457 int **hash = (int **)genmatrix(jmaxsize,     `❸  
> `                 imaxsize, sizeof(int));         `❸  
> `458`  
> `459 for(int ic=0; ic<ncells; ic++){              `❹  
> `460    int lev = level[ic];`  
> `461    for (int jj=j[ic]*levtable[levmx-lev];`  
> `            jj<(j[ic]+1)*levtable[levmx-lev]; jj++) {`  
> `462       for (int ii=i[ic]*levtable[levmx-lev];`  
> `               ii<(i[ic]+1)*levtable[levmx-lev]; ii++) {`  
> `463          hash[jj][ii] = ic;`  
> `464       }`  
> `465    }`  
> `466 }`

❶ Constructs a table of powers of two (1, 2, 4, ...)

❷ Sets the number of rows and columns at the finest level

❸ Allocates the hash table

❹ Maps cells to hash table

The loops at lines 459, 461, and 462 reference the 1D arrays `i`, `j`, and `level`; `level` is the refinement level where `0` is the coarse level and `1` to `levmax` are the levels of refinement. The arrays `i` and `j` are the row and column of the cell in the mesh at that cell’s refinement level.

Listing 5.5 shows the code for writing out the spatial hash in OpenCL for the GPU, which is similar to listing 5.4. Although we haven’t covered OpenCL yet, the simplicity of the GPU code is clear, even without understanding all the details. Let’s do a brief comparison to get a sense of how code has to change for the GPU. We define a macro to handle the 2D indexing and to make the code look more like the CPU version. Then the biggest difference is that there is no cell loop. This is typical of GPU code, where the outer loops are removed and are instead handled by the kernel launch. The cell index is provided for each thread by a call to the `get_global_id` intrinsic. There will be more on this example and writing OpenCL code, in general, in chapter 12.

**Listing 5.5 Writing out a spatial hash table on the GPU in OpenCL**

> `neigh2d_kern.cl from PerfectHash`  
> `77 #define hashval(j,i) hash[(j)*imaxsize+(i)]`  
> `78`  
> `79 __kernel void hash_setup_kern(`  
> `80       const uint isize,`  
> `81       const uint mesh_size,`  
> `82       const uint levmx,`  
> `83       __global const int  *levtable,        `❶  
> `84       __global const int  *i,               `❶  
> `85       __global const int  *j,               `❶  
> `86       __global const int  *level,           `❶  
> `87       __global int  *hash`  
> `88       ) {`  
> `89`  
> `90    const uint ic = get_global_id(0);        `❷  
> `91    if (ic >= isize) return;                 `❸  
> `92`  
> `93    int imaxsize = mesh_size*levtable[levmx];`  
> `94    int lev = level[ic];`  
> `95    int ii = i[ic];`  
> `96    int jj = j[ic];`  
> `97    int levdiff = levmx - lev;`  
> `98`  
> `99    int iimin =  ii   *levtable[levdiff];    `❹  
> `100    int iimax = (ii+1)*levtable[levdiff];    `❹  
> `101    int jjmin =  jj   *levtable[levdiff];    `❹  
> `102    int jjmax = (jj+1)*levtable[levdiff];    `❹  
> `103`  
> `104    for (   int jjj = jjmin; jjj < jjmax; jjj++) {`  
> `105       for (int iii = iimin; iii < iimax; iii++) {`  
> `106          hashval(jjj, iii) = ic;            `❺  
> `107       }  `  
> `108    }  `  
> `109 }`

❶ Passes in the table of powers of 2 along with i, j, and level

❷ The loop across the cells is implied by the GPU kernel; each thread is a cell.

❸ The return is important to avoid reading past end of the arrays.

❹ Computes the bounds of the underlying hash buckets to set

❺ Sets the hash table value to the thread ID (the cell number)

The code for retrieving the neighbor indexes is also simple as shown in listing 5.6, with just a loop across the cells and a read of the hash table at where the neighbor location would be on the finest level of the mesh. You can find the locations of the neighbors by incrementing the row or column by one cell in the direction needed. For the left or bottom neighbor, the increment is 1, while for the right or top neighbor, the increment is the full width of the mesh in the x-direction or `imaxsize`.

**Listing 5.6 Finding neighbors from a spatial hash table on the CPU**

> `neigh2d.c from PerfectHash`  
> `472 for (int ic=0; ic<ncells; ic++){`  
> `473   int ii = i[ic];`  
> `474   int jj = j[ic];`  
> `475   int lev = level[ic];`  
> `476   int levmult = levtable[levmx-lev];`  
> `477   int nlftval =`  
> `         hash[     jj   *levmult              ]      `❶  
> `             [MAX( ii   *levmult-1,0         )];     `❶  
> `478   int nrhtval =`  
> `         hash[     jj   *levmult              ]      `❶  
> `             [MIN((ii+1)*levmult,  imaxsize-1)];     `❶  
> `480   int nbotval =`  
> `         hash[MAX( jj   *levmult-1,0)         ]      `❶  
> `             [      ii   *levmult             ];     `❶  
> `481   int ntopval =`  
> `         hash[MIN((jj+1)*levmult,  jmaxsize-1)]      `❶  
> `             [      ii   *levmult             ];     `❶  
> `482   neigh2d[ic].left  = nlftval;                   `❷  
> `483   neigh2d[ic].right = nrhtval;                   `❷  
> `484   neigh2d[ic].bot   = nbotval;                   `❷  
> `485   neigh2d[ic].top   = ntopval;                   `❷  
> `486}`

❶ Calculates the neighbor cell location for the query, using a max/min to keep it in bounds

❷ Assigns the neighbor value for output arrays

For the GPU, we again remove the loop for the cells and replace it with a `get_ global_id` call as shown in the following listing.

**Listing 5.7 Finding neighbors from a spatial hash table on the GPU in OpenCL**

> `neigh2d_kern.cl from PerfectHash`  
> `113 #define hashval(j,i) hash[(j)*imaxsize+(i)]`  
> `114`  
> `115 __kernel void calc_neighbor2d_kern(`  
> `116       const int isize,`  
> `117       const uint mesh_size,`  
> `118       const int levmx,`  
> `119       __global const int *levtable,`  
> `120       __global const int *i,`  
> `121       __global const int *j,`  
> `122       __global const int *level,`  
> `123       __global const int *hash,`  
> `124       __global struct neighbor2d *neigh2d`  
> `125       ) {`  
> `126`  
> `127    const uint ic  = get_global_id(0);    `❶  
> `128    if (ic >= isize) return;`  
> `129`  
> `130    int imaxsize = mesh_size*levtable[levmx];`  
> `131    int jmaxsize = mesh_size*levtable[levmx];`  
> `132`  
> `133    int ii = i[ic];                       `❷  
> `134    int jj = j[ic];`  
> `135    int lev = level[ic];`  
> `136   int levmult = levtable[levmx-lev];`  
> `137`  
> `138    int nlftval = hashval(     jj   *levmult              ,`  
> `                             max( ii   *levmult-1,0         ));`  
> `139    int nrhtval = hashval(     jj   *levmult              ,`  
> `                             min((ii+1)*levmult,  imaxsize-1));`  
> `140    int nbotval = hashval(max( jj   *levmult-1,0)         ,`  
> `                                  ii   *levmult              ); `  
> `141    int ntopval = hashval(min((jj+1)*levmult,  jmaxsize-1),`  
> `                                  ii   *levmult              ); `  
> `142    neigh2d[ic].left   = nlftval;`  
> `143    neigh2d[ic].right  = nrhtval;`  
> `144    neigh2d[ic].bottom = nbotval;`  
> `145    neigh2d[ic].top    = ntopval;`  
> `146 }`

❶ Gets the cell ID for the thread

❷ The rest of code is similar to the CPU version.

Compare the simplicity of this code to the k-D tree code for the CPU, which is a thousand lines long!

***REMAP CALCULATIONS USING A SPATIAL PERFECT HASH***

Another important numerical mesh operation is a remap from one mesh to another. Fast remaps can permit different physics to be performed on meshes optimized for their individual needs.

In this case, we will look at remapping the values from one cell-based AMR mesh to another cell-based AMR mesh. Mesh remaps can also involve unstructured meshes or particle-based simulations, but the techniques are more complicated. The setup phase is identical to the neighbor case, where the cell index for every cell is written to the spatial hash. In this case, the spatial hash is created for the source mesh. Then the read phase, shown in listing 5.8, queries the spatial hash for the cell numbers underlying each cell of the target mesh and sums up the values from the source mesh into the target mesh after adjusting for the size difference of the cells. For this demonstration, we have simplified the source code from the example at [https://github.com/Essentials ofParallelComputing/Chapter5.git](https://github.com/EssentialsofParallelComputing/Chapter5.git).

**Listing 5.8 The read phase of the remapping of a value on the CPU**

> `remap2.c from PerfectHash`  
> `211 for(int jc = 0; jc < ncells_target; jc++) {`  
> `212    int ii = mesh_target.i[jc];                `❶  
> `213    int jj = mesh_target.j[jc];                `❶  
> `214    int lev = mesh_target.level[jc];           `❶  
> `215    int lev_mod = two_to_the(levmx - lev);`  
> `216    double value_sum = 0.0;`  
> `217    for(int jjj = jj*lev_mod;                  `❷  
> `               jjj < (jj+1)*lev_mod; jjj++) {     `❷  
> `218       for(int iii = ii*lev_mod;               `❷  
> `                  iii < (ii+1)*lev_mod; iii++) {  `❷  
> `219          int ic = hash_table[jjj*i_max+iii];`  
> `220          value_sum += value_source[ic] /      `❸  
> `                (double)four_to_the(              `❸  
> `                   levmx-mesh_source.level[ic]    `❸  
> `                );                                `❸  
> `221       }`  
> `222    }`  
> `223    value_remap[jc] += value_sum;`  
> `224 }`

❶ Gets the location of the target mesh cell

❷ Queries the spatial hash for source mesh cells

❸ Sums the values from the source mesh, adjusting for relative cell sizes

Figure 5.7 shows the performance improvement from the remap using the spatial perfect hash. There is a speedup due to the algorithm and then an additional parallel speedup running on the GPU for a total speedup of over 1,000 times faster. The parallel speedup on the GPU is made possible by the ease of the algorithm implementation on the GPU. Good parallel speedup should also be possible on the multi-core processor as well.

**Figure 5.7 The speedup of the remap algorithm due to the change of the algorithm from a k-D tree to a hash on a single core of the CPU and then ported to the GPU for a parallel speedup.**

***TABLE LOOKUPS USING A SPATIAL PERFECT HASH***

The operation of looking up values from tabular data presents a different kind of locality that can be exploited by a spatial hash. You can use hashing for searching for the intervals on both axes for the interpolation. For this example, we used a 51x23 lookup table of equation-of-state values. The two axes are density and temperature, with an equal spacing used between values on each axis. We will use n for the length of the axis and N for the number of table lookups that are to be performed. We used three algorithms in this study:

- The first is a linear search (brute force) starting at the first column and row. The brute force should be an O(n) algorithm for each data query or for all N, O(N \* n), where n is the number of columns or rows, respectively, for each axis.

- The second is a bisection search that looks at the midpoint value of the possible range and recursively narrows the location for the interval. The bisection search should be an O(log n) algorithm for each data query.

- Finally, we used a hash to do an O(1) lookup of the interval for each axis. We measured the performance of the hash on both a single core of a CPU and a GPU. The test code searches for the interval on both axes and a simple interpolation of the data values from the table to get the result.

Figure 5.8 shows the performance results for the different algorithms. The results have some surprises. The bisection search is no faster than the brute force (linear search) despite being an O(N log n) algorithm instead of an O(N \*n) algorithm. This seems to be contrary to the simple performance model, which indicates that the speedup should be 4 -5x for the search on each axis. With the interpolation, we’d still expect around a 2x improvement. But there is a simple explanation, which you might guess from our discussions in section 5.2.

**Figure 5.8 The algorithms used for table lookup show a large speedup for the hash algorithm on the GPU.**

The search for the interval on each axis requires, at most, only two cache loads on one axis and four on the other for the linear search! The bisection would need the same number of cache loads. By considering cache loads, we would expect no difference in performance. The hash algorithm could directly go to the correct interval, but it would still need a cache load. The reduction in cache loads would be about a factor of 3x. The additional improvement is probably due to the reduction in the conditionals for the hash algorithm. The observed performance is in line with the expectations once we include the effect of the cache hierarchy.

Porting the algorithm to the GPU is a bit more involved and shows what performance enhancements are possible in the process. To understand what was done, let’s first look at the hash implementation on the CPU in listing 5.9. The code loops over all of the 16 million values, finding the intervals on each axis, and then interpolates the data in the table to get the resulting value. By using the hashing technique, we can find the interval locations by using a simple arithmetic expression with no conditionals.

**Listing 5.9 The table interpolation code for the CPU**

> `table.c from PerfectHash`  
> `272 double dens_incr =`  
> `       (d_axis[50]-d_axis[0])/50.0;               `❶  
> `273 double temp_incr =`  
> `       (t_axis[22]-t_axis[0])/22.0;               `❶  
> `274`  
> `275 for (int i = 0; i<isize; i++){`  
> `276    int tt = (temp[i]-t_axis[0])/temp_incr;    `❷  
> `277    int dd = (dens[i]-d_axis[0])/dens_incr;    `❷  
> `278`  
> `279    double xf = (dens[i]-d_axis[dd])/          `❷  
> `280                (d_axis[dd+1]-d_axis[dd]);     `❷  
> `281    double yf = (temp[i]-t_axis[tt])/          `❷  
> `282                (t_axis[tt+1]-t_axis[tt]);     `❷  
> `283    value_array[i] =     `  
> `                xf *     yf *data(dd+1,tt+1)      `❸  
> `284      + (1.0-xf)*     yf *data(dd,  tt+1)      `❸  
> `285      +      xf *(1.0-yf)*data(dd+1,tt)        `❸  
> `286      + (1.0-xf)*(1.0-yf)*data(dd,  tt);       `❸  
> `287 }`

❶ Computes a constant increment for each axis data lookup

❷ Determines the interval for interpolation and the fraction in the interval

❸ Bi-linear interpolation to fill the value_array with the results

We could simply port this to the GPU as was done in the earlier cases by removing the `for` loop and replacing it with a call to `get_global_id`. But the GPU has a small local memory cache that is shared by each work group, which can hold about 4,000 double-precision values. We have 1,173 values in the table and 51+23 axis values. These can fit in the local memory cache that can be accessed quickly and shared among all the threads in the workgroup. The code in listing 5.10 shows how this is done. The first part of the code cooperatively loads the data values into local memory using all of the threads. A synchronization is then required to guarantee that all the data is loaded before moving on to the interpolation kernel. The remaining code looks much the same as the code for the CPU in listing 5.9.

**Listing 5.10 The table interpolation code in OpenCL for the GPU**

> `table_kern.cl from PerfectHash`  
> `45 #define dataval(x,y) data[(x)+((y)*xstride)]`  
> `46`  
> `47 __kernel void interpolate_kernel(`  
> `48    const uint isize,`  
> `49    const uint xaxis_size,`  
> `50    const uint yaxis_size,`  
> `51    const uint dsize,`  
> `52    __global const double *xaxis_buffer,`  
> `53    __global const double *yaxis_buffer,`  
> `54    __global const double *data_buffer,`  
> `55    __local        double *xaxis,`  
> `56    __local        double *yaxis,`  
> `57    __local        double *data,`  
> `58    __global const double *x_array,`  
> `59    __global const double *y_array,`  
> `60    __global       double *value`  
> `61    )`  
> `62 {`  
> `63    const uint tid = get_local_id(0);`  
> `64    const uint wgs = get_local_size(0);`  
> `65    const uint gid = get_global_id(0);`  
> `66`  
> `67    if (tid < xaxis_size)`  
> `          xaxis[tid]=xaxis_buffer[tid];             `❶  
> `68    if (tid < yaxis_size)`  
> `          yaxis[tid]=yaxis_buffer[tid];             `❶  
> `69`  
> `70    for (uint wid = tid; wid<d_size; wid+=wgs){   `❷  
> `71       data[wid] = data_buffer[wid];              `❷  
> `72    }                                             `❷  
> `73`  
> `74    barrier(CLK_LOCAL_MEM_FENCE);                 `❸  
> `75   `  
> `76    double x_incr = (xaxis[50]-xaxis[0])/50.0;    `❹  
> `77    double y_incr = (yaxis[22]-yaxis[0])/22.0;    `❹  
> `78  `  
> `79    int xstride = 51;`  
> `80`  
> `81    if (gid < isize) {`  
> `82       double xdata = x_array[gid];               `❺  
> `83       double ydata = y_array[gid];               `❺  
> `84`  
> `85       int is = (int)((xdata-xaxis[0])/x_incr);   `❻  
> `86       int js = (int)((ydata-yaxis[0])/y_incr);   `❻  
> `87       double xf = (xdata-xaxis[is])/             `❻  
> `                        (xaxis[is+1]-xaxis[is]);    `❻  
> `88       double yf = (ydata-yaxis[js])/             `❻  
> `                        (yaxis[js+1]-yaxis[js]);    `❻  
> `89   `  
> `90       value[gid] =`  
> `                 xf *     yf *dataval(is+1,js+1)    `❼  
> `91        + (1.0-xf)*     yf *dataval(is,  js+1)    `❼  
> `92        +      xf *(1.0-yf)*dataval(is+1,js)      `❼  
> `93        + (1.0-xf)*(1.0-yf)*dataval(is,  js);     `❼  
> `94    }`  
> `95 }`

❶ Loads the axis data values

❷ Loads the data table

❸ Needs to synchronize before table queries

❹ Computes a constant increment for each axis data lookup

❺ Loads the next data value

❻ Determines the interval for interpolation and the fraction in the interval

❼ Bi-linear interpolation

The performance result for the GPU hash code shows the impact of this optimization with a larger speedup than from the single core CPU performance for the other kernels.

***SORTING MESH DATA USING A SPATIAL PERFECT HASH***

The sort operation is one of the most studied algorithms and forms the basis for many other operations. In this section, we look at the special case of sorting spatial data. You can use a spatial sort to find the nearest neighbors, eliminate duplicates, simplify range finding, graphics output, and a host of other operations.

For simplicity, we’ll work with 1D data with a minimum cell size of 2.0. All cells must be a power of two larger than the minimum cell size. The test case allows up to four levels of coarsening, in addition to the minimum cell size for the following possibilities: 2.0, 4.0, 8.0, 16.0, and 32.0. Cell sizes are randomly generated, and the cells randomly ordered. The sort is performed with a quicksort and then with a hash sort on the CPU and the GPU. The calculation for the spatial hash sort exploits the information about the 1D data. We know the minimum and maximum value for X and the minimum cell size. With this information, we can calculate a bucket index that guarantees a perfect hash with

where b _(k) is the bucket to place the entry, X _(i) is the x coordinate for the cell, X_(min) is the minimum value of X, and Δ_(min) is the minimum distance between any two adjacent values of X.

We can demonstrate the hash sort operation (figure 5.9). The minimum difference between values is 2.0, so the bucket size of 2 guarantees that there are no collisions. The minimum value is 0, so the bucket location can be calculated with B_(i) = X _(i) /Δ_(min) = X _(i) /2.0. We could store either the value or the index in the hash table. For example, 8, the first key, could be stored in bucket 4, or the original index location of 0 could also be stored. If the value is stored, we retrieve the 8 with `hash[4]`. If the index is stored, then we retrieve the value with `keys[hash[4]]`. Storing the index location is a little slower in this case, but it is more general. It can also be used to reorder all the arrays in a mesh. In the test case for the performance study, we use the method of storing the index.

**Figure 5.9 Sorting using a spatial perfect hash. This method stores the value in the hash with a bucket, but it could also store the index location of the value in the original array. Note that the bucket size of 2 with a range of 0 to 24 is indicated by the small numbers on the left of the hash table.**

The spatial hash sort algorithm is Θ(N ), while the quicksort is Θ(N log N ). But the spatial hash sort is more specialized to the problem at hand and can temporarily take more memory. The remaining questions are how difficult is this algorithm to write and how does it perform? The following listing shows the code for the write phase of the spatial hash implementation.

**Listing 5.11 The spatial hash sort on the CPU**

> `sort.c from PerfectHash`  
> `283 uint hash_size =`  
> `       (uint)((max_val - min_val)/min_diff);           `❶  
> `284 hash = (int*)malloc(hash_size*sizeof(int));        `❶  
> `285 memset(hash, -1, hash_size*sizeof(int));           `❷  
> `286`  
> `287 for(uint i = 0; i < length; i++) {`  
> `288     hash[(int)((arr[i]-min_val)/min_diff)] = i;    `❸  
> `289 }`  
> `290   `  
> `291 int count=0;                                       `❹  
> `292 for(uint i = 0; i < hash_size; i++) {              `❹  
> `293     if(hash[i] >= 0) {                             `❹  
> `294         sorted[count] = arr[hash[i]];              `❹  
> `295         count++;                                   `❹  
> `296     }                                              `❹  
> `297 }                                                  `❹  
> `298   `  
> `299 free(hash);`

❶ Creates a hash table with buckets of size min_diff

❷ Sets all the elements of hash array to -1

❸ Places the index of current array element into hash according to where the arr value goes

❹ Sweeps through hash and puts set values in a sorted array

Note that the code in the listing is barely more than a dozen lines. Compare this to a quicksort code that is five times as long and far more complicated.

Figure 5.10 shows the performance of the spatial sort on both a single core of the CPU and the GPU. As we shall see, the parallel implementation on the CPU and GPU takes some effort for good performance. The read phase of the algorithm needs a well implemented prefix sum so that the retrieval of the sorted values can be done in parallel. The prefix sum is an important pattern for many algorithms; we’ll discuss it further in section 5.6.

The GPU implementation for this example uses a well implemented prefix sum, and the performance of the spatial hash sort is excellent as a result. In earlier tests with an array size of two million, this GPU sort was 3x faster than the fastest general GPU sort, and the serial CPU version was 4x faster than the standard quicksort. With current CPU architectures and a larger array size of 16 million, our spatial hash sort is shown to be nearly 6x faster (figure 5.10). It is remarkable that our sort written in two or three months is much faster than the current fastest reference sorts on the CPU and GPU, especially since the reference sorts are the results of decades of research and the effort of many researchers!

**Figure 5.10 Our spatial hash sort shows a speedup on a single core of the CPU and a further parallel speedup on the GPU. Our sort is 6x faster than the current fastest sort.**

***5.5.2 Using compact hashing for spatial mesh operations***

We are not done yet with exploring hashing methods. The algorithms in the perfect hashing section can be greatly improved. In the previous section, we explored using compact hashes for the neighbor finding and the remap operations. The key observations are that we don’t need to write to every spatial hash bin, and we can improve the algorithms by handling collisions. This thereby allows the spatial hashes to be compressed and use less memory. This gives us more options on algorithm choice with different memory requirements and run times.

***NEIGHBOR FINDING WITH WRITE OPTIMIZATIONS AND COMPACT HASHING***

The previous simple perfect hash algorithm for finding neighbors performs well for small numbers of mesh refinement levels in an AMR mesh. But when there are six or more levels of refinement, a coarse cell writes to 64 hash buckets, and a fine cell only has to write to one, leading to a load imbalance and a problem with thread divergence for parallel implementations.

Thread divergence is when the amount of work for each thread varies and the threads end up waiting for the slowest. We can improve the perfect hash algorithm further with the optimizations shown in figure 5.11. The first optimization is realizing that the neighbor queries only sample the outer hash buckets of a cell, so there is no need to write to the interior. Further analysis shows that only the corners or midpoints of the cell’s representation in the hash will be queried, reducing the needed writes even further. In the figure, the example shown to the far right of the sequence further optimizes the writes to only one per cell and does multiple reads where the entry exists for a finer, same size, or coarser neighbor cell. This last technique requires initializing the hash table to a sentinel value such as -1 to indicate no entry.

**Figure 5.11 Optimizing the neighbor-finding calculation using the perfect spatial hash by reducing the number of writes and reads**

But now that less data is written to the hash, we have a lot of empty space, or sparsity, and can compress the hash table to as low as 1.25x times the number of entries, greatly reducing the memory requirements of the algorithm. The inverse of the size multiplier is known as the hash load factor and is defined as the number of filled hash table entries divided by the hash table size. For a 1.25 size multiplier, the hash load factor is 0.8. We typically use a much smaller load factor, typically around 0.333 or a size multiplier of 3. This is because in parallel processing, we want to avoid one processor being slower than the others. Hash sparsity represents the empty space in the hash. Sparsity indicates the opportunity for compression.

Figure 5.12 shows the process of creating a compact hash. Because of the compression to a compact hash, two entries try to store their value in bucket 1. The second entry sees that there is already a value there, so it looks for the next open slot in a technique called open addressing. In open addressing, we look for the next open slot in the hash table and store the value in that slot. There are other hashing methods than open addressing, but these often require the ability to allocate memory during an operation. Allocating memory is more difficult on the GPU, so we stick with open addressing where collisions are resolved by finding alternate storage locations within the already allocated hash table.

**Figure 5.12 This sequence from left to right shows the storing of spatial data in a perfect spatial hash, compressing it into a smaller hash and then, where there is a collision, looking for the next available empty slot to store it.**

In open addressing, there are a few choices that we can use as the trial for the next open slot. These are

- Linear probing—Where the next entry is just the next bucket in sequence until an open bucket is found

- Quadratic probing—Where the increment is squared so that the attempted buckets are +1, +4, +9, and so forth from the original location

- Double hashing—Where a second hashing function is used to jump to a deterministic, but pseudo-random distance from the first trial location

The reason for the more complex choices for the next trial is to avoid clustering of values in part of the hash table, leading to longer store and query sequences. We use the quadratic probing method because the first couple of tries are in the cache, which leads to better performance. Once a slot is found, both the key and the value are stored. When reading the hash table, the stored key is compared to the read key, and if they aren’t the same, then the read tries the next slot in the table.

We could make a performance estimate of the improvement of these optimizations by counting the number of writes and reads. But we need to adjust these write and read numbers to account for the number of cache lines and not just the raw number of values. Also, the code with the optimizations has more conditionals. Thus, the run-time improvement is modest and only better for higher levels of mesh refinement. The parallel code on the GPU shows more benefit because the thread divergence is reduced.

Figure 5.13 shows the measured performance results for the different hash table optimizations for a sample AMR mesh that has a relatively modest sparsity factor of 30. The code is available at <https://github.com/lanl/CompactHash.git>. The last performance numbers shown in figure 5.13 for both the CPU and GPU are for compact hash runs. The cost of the compact hash is offset by not having as much memory to initialize to the sentinel value of -1. The effect is that the compact hash has a competitive performance compared to the perfect hashing methods. With more sparsity in the hash table than the 30x compression factor in this test case, the compact hash can even be faster than the perfect hash methods. Cell-based AMR methods in general should have at least a 10x compression and can often exceed 100x.

**Figure 5.13 The optimized versions shown for the CPU and GPU correspond to the methods shown in figure 5.11. Compact is the CPU compact, and G Comp is the GPU compact for the last method in each set. The compact method is faster than the original perfect hash, requiring considerably less memory. At higher levels of refinement, the methods that reduce the number of writes show some performance benefit as well.**

These hashing methods have been implemented in the CLAMR mini-app. The code switches between a perfect hash algorithm for low levels of sparsity and the compact hash when there is a lot of empty space in the hash.

***FACE NEIGHBOR FINDING FOR UNSTRUCTURED MESHES***

So far, we haven’t discussed algorithms for unstructured meshes because it’s hard to guarantee that a perfect hash can easily be created for these. The most practical methods require a way to handle collisions and, thus, compact hashing techniques. Let’s explore one case where the use of a hash is fairly straightforward. Finding the neighbor face for a polygonal mesh can be an expensive search procedure. Many unstructured codes store the neighbor map because it is so expensive. The technique we show next is so fast that the neighbor map can be calculated on the fly.

> **Example: Finding the face neighbor for an unstructured mesh**

> The following figure presents a small part of an unstructured mesh with polygonal cells. One of the computational challenges for this type of mesh is to find the connectivity map for each face of the polygons. A brute force search of every other element

> seems reasonable for small numbers of polygons, but for larger numbers of cells, this can soon take minutes or hours. A k-D tree search reduces the time, but is there an even faster way? Let’s try a hash-based method instead. We overlay the figure on top of the hash table to the right of the figure. The algorithm is as follows:

- We place a dot for the center of each face in the hash bucket where it falls.

- Every cell writes its cell number into the bin at the center of each face. If the face is to the left and up from the center, it writes its index to the first of two places in the bin; otherwise, it writes to the second place.

- Every cell checks for each face to see if there is a number in the other bucket. If there is, it is the neighbor cell. If not, it is an external face with no neighbor.

> We have found our neighbors in a single write and single read!

>   

> **Finding the neighbor for each face of each cell using a spatial hash. Each face writes to one of two bins in the spatial hash. If the face is towards the left and up from center, it writes to the first bin. If towards the right and down, it writes to the second. In the read pass, it looks to see if the other bin has been filled and if it is, that cell number is its neighbor. (Graphic and algorithm courtesy of Rachel Robey.)**

The proper size of the hash table is difficult to specify. The best solution is to pick a reasonable size based on the number of faces or the minimum face length and then handle collisions if these occur.

***REMAPS WITH WRITE OPTIMIZATIONS AND COMPACT HASHING***

Another operation, the remap, is a little more difficult to optimize and set up for a compact hash because the perfect hash approach reads all the underlying cells. First, we have to come up with a way that doesn’t require every hash bucket to be filled.

**Figure 5.14 A single write, multiple read implementation of a spatial hash remap. The first query is where a cell of the same size from the input mesh would write, and then if no value is found, the next query looks for where a cell at the next coarser level would write.**

We write the cell indices for each cell to the lower left corner of the underlying hash. Then, during the read, if a value is not found or the level of the cell in the input mesh is not correct, we look for where a cell in the input mesh would write if it were at the next coarser level. Figure 5.14 shows this approach, where cell 1 in the output mesh queries the hash location (0,2) and finds a -1, so it then looks for where the next coarser cell would be at (0,0) and finds the cell index of 1. The density of cell 1 in the output mesh is then set to the density of cell 1 in the input mesh. For cell 9 in the output mesh, it looks in the hash at (4,4) and finds an input cell index of 3. It then looks up the level of cell 3 in the input mesh, and because the input mesh cell level is finer, it must also query hash locations (6,4) to get the cell index of 9 and location (4,6), which returns cell index 4 and location (6,6) to get cell index of 7. The first two cell indices are at the same level, so these do not need to go any further. The cell index of 7 is at a finer level, so we must recursively descend into that location to find cell indices of 8, 5, and 6. Listing 5.12 shows the code.

**Listing 5.12 The setup phase for the single-write spatial hash remap on the CPU**

> `singlewrite_remap.cc and meshgen.cc from CompactHashRemap/AMR_remap`  
> `47 #define two_to_the(ishift)    (1u <<(ishift) )                  `❶  
> `48`  
> `49 typedef struct {                                                `❷  
> `50    uint ncells;                                                 `❸  
> `51    uint ibasesize;                                              `❹  
> `52    uint levmax;                                                 `❺  
> `53    uint *dist;                                                  `❻  
> `54    uint *i;`  
> `55    uint *j;`  
> `56    uint *level;`  
> `57    double *values;`  
> `58 } cell_list;`  
> `59`  
> `60 cell_list icells, ocells;                                       `❼  
> `61`  
>   
> `<... lots of code to create mesh ...>                               `❼  
>   
> `120 size_t hash_size = icells.ibasesize*two_to_the(icells.levmax)*`  
> `121                    icells.ibasesize*two_to_the(icells.levmax);`  
> `122 int *hash = (int *) malloc(hash_size *                          `❽  
> `                               sizeof(int));                        `❽  
> `123 uint i_max = icells.ibasesize*two_to_the(icells.levmax);`

❶ Defines 2n power function as the shift operator for speed

❷ Structure to hold characteristics of a mesh

❸ Number of cells in the mesh

❹ Number of coarse cells across the x-dimension

❺ Number of refinement levels in addition to the base mesh

❻ Distribution of cells across levels of refinement

❼ Sets up input and output meshes

❽ Allocates the hash table for a perfect hash

Before the write, a perfect hash table is allocated and initialized to the sentinel value of -1 (figure 5.10). Then the cell indices from the input mesh are written to the hash (listing 5.13). The code is available at [https://github.com/lanl/CompactHashRemap .git](https://github.com/lanl/CompactHashRemap.git) in the file AMR_remap/singlewrite_remap.cc, along with variants for using a compact hash table and OpenMP. The OpenCL version for the GPU is in AMR_remap/ h_remap_kern.cl.

**Listing 5.13 The write phase for the single-write spatial hash remap on the CPU**

> `AMR_remap/singlewrite_remap.cc from CompactHashRemap`  
> `127 for (uint i = 0; i < icells.ncells; i++) {       `❶  
> `128     uint lev_mod =                               `❷  
> `           two_to_the(icells.levmax -                `❷  
> `                      icells.level[i]);              `❷  
> `129     hash[((icells.j[i] * lev_mod) * i_max)       `❸  
> `            + (icells.i[i] * lev_mod)] = i;          `❸  
> `130 }`

❶ The actual read part of the hash write is just four lines.

❷ The multiplier to convert between mesh levels

❸ Computes the index for the 1D hash table

The code for the read phase (listing 5.14) has an interesting structure. The first part is basically split into two cases: the cell at the same location in the input mesh is the same level or coarser or it is a set of finer cells. In the first case, we loop up the levels until we find the right level and set the value in the output mesh to the value in the input mesh. If it is finer, we recurse down the levels, summing up the values as we go.

**Listing 5.14 The read phase for the single-write spatial hash remap on the CPU**

> `AMR_remap/singlewrite_remap.cc from CompactHashRemap`  
> `132 for (uint i = 0; i < ocells.ncells; i++) {`  
> `133     uint io = ocells.i[i];`  
> `134     uint jo = ocells.j[i];`  
> `135     uint lev = ocells.level[i];`  
> `136`  
> `137     uint lev_mod = two_to_the(ocells.levmax - lev);`  
> `138     uint ii = io*lev_mod;`  
> `139     uint ji = jo*lev_mod;`  
> `140`  
> `141     uint key = ji*i_max + ii;`  
> `142     int probe = hash[key];`  
> `144`  
> `145     if (lev > ocells.levmax){lev = ocells.levmax;}`  
> `146`  
> `147     while(probe < 0 && lev > 0) {                          `❶  
> `148         lev--;`  
> `149         uint lev_diff = ocells.levmax - lev;`  
> `150         ii >>= lev_diff;`  
> `151         ii <<= lev_diff;`  
> `152         ji >>= lev_diff;`  
> `153         ji <<= lev_diff;`  
> `154         key = ji*i_max + ii;`  
> `155         probe = hash[key];`  
> `156     }`  
> `157     if (lev >= icells.level[probe]) {`  
> `158         ocells.values[i] = icells.values[probe];           `❷  
> `159     } else {`  
> `160         ocells.values[i] =                                 `❸  
> `               avg_sub_cells(icells, ji, ii,                   `❸  
> `                             lev, hash);                       `❸  
> `161     }`  
> `162 }`  
> `163 double avg_sub_cells (cell_list icells, uint ji, uint ii,`  
> `           uint level, int *hash) {`  
> `164     uint key, i_max, jump;`  
> `165     double sum = 0.0;`  
> `166     i_max = icells.ibasesize*two_to_the(icells.levmax);`  
> `167     jump = two_to_the(icells.levmax - level - 1);`  
> `168   `  
> `169     for (int j = 0; j < 2; j++) {`  
> `170         for (int i = 0; i < 2; i++) {`  
> `171             key = ((ji + (j*jump)) * i_max) + (ii + (i*jump));`  
> `172             int ic = hash[key];`  
> `173             if (icells.level[ic] == (level + 1)) {`  
> `174                 sum += icells.values[ic];                  `❹  
> `175             } else {`  
> `176                 sum += avg_sub_cells(icells, ji + (j*jump),`  
> `                    ii + (i*jump), level+1, hash);             `❺  
> `177             }`  
> `178         }`  
> `179     }`  
> `180 `  
> `181     return sum/4.0;`  
> `182 }`

❶ If a sentinel value is found, continues to coarser levels

❷ Because this is at the same level or coarser, sets the value of the found cell ID in the input mesh

❸ For finer cells, recursively descends and sums the contributors

❹ Accumulates to the new value

❺ Recursively descends again

Ok, this seems fine for the CPU, but how is it going to work on the GPU? Supposedly, recursion is not supported on the GPU. There doesn’t seem to be any easy way to write this without recursion. But we tested it on the GPU and found that it works. It runs fine on all of the GPUs that we tried for the limited number of levels of refinement that will be used in any practical mesh. Evidently, a limited amount of recursion works on a GPU! We then implemented compact hash versions of this approach and these show good performance.

***HIERARCHICAL HASH TECHNIQUE FOR THE REMAP OPERATION***

Another innovative approach to using hashing for a remap operation involves a hierarchical set of hashes and a “breadcrumb” technique. A breadcrumb trail of sentinel values has the benefit that we do not need to initialize the hash tables to a sentinel value at the start (figure 5.15).

**Figure 5.15 A hierarchical hash table with a separate hash for each level. When a write is done in one of the finer levels, a sentinel value is placed in each level above to form a “breadcrumb” trail to inform queries that there is data at finer levels.**

The first step is to allocate a hash table for each level of the mesh. Then the cell indices are written to the appropriate level hash and recurse upward through the coarser hashes, leaving a sentinel value so that queries know there are values in the finer-level hash tables. Looking at figure 5.15 for cell 9 in the input mesh, we see that

- The cell index is written to the mid-level hash table, then a sentinel value is written to the hash bins in the coarser hash table.

- The read operation for cell 9 first goes to the coarsest level of the hash table, where it finds a sentinel value of -1. It now knows that it must go to the finer levels.

- It finds three cells at the mid-level hash table and another sentinel value to tell the read operation to recursively descend to the finest level, where it finds four more values to add to the summation.

- The other queries are all found in the coarsest hash table, and the values assigned to the output mesh.

Each of the hash tables can be either a perfect hash or a compact hash. The method has a recursive structure, similar to the previous technique. It also runs fine on GPUs.

***5.6 Prefix sum (scan) pattern and its importance in parallel computing***

The prefix sum was a critical element of making the hash sort work in parallel in section 5.5.1. The prefix sum operation, also known as a scan, is a common operation in computations with irregular sizes. Many computations with irregular sizes need to know where to start writing to be able to operate in parallel. A simple example is where each processor has a different number of particles. To be able to write to the output array or access data on other processors or threads, each processor needs to know the relationship of the local indices to the global indices. In the prefix sum, the output array, y, is a running sum of all of the numbers previous to it in the original array:

The prefix sum can either be an inclusive scan, where the current value is included, or an exclusive scan, where it isn’t included. The previous equation is for an exclusive scan. Figure 5.16 shows both an exclusive and an inclusive scan. The exclusive scan is the starting index for the global array, while the inclusive scan is the ending index for each process or thread.

**Figure 5.16 The array x gives the number of particles in each cell. The exclusive and inclusive scan of an array gives the starting and ending address in the global data set.**

The following listing shows the standard serial code for the scan operation.

**Listing 5.15 The serial inclusive scan operation**

> `1 y[0] = x[0];`  
> `2 for (int i=1; i<n; i++){`  
> `3    y[i] = y[i-1] + x[i];`  
> `4 }`

Once the scan operation is complete, each process is free to perform its operation in parallel because the process knows where to put its result. The scan operation itself, though, appears to be intrinsically serial. Each iteration is dependent on the previous. But there are effective ways to parallelize it. We’ll look at a step-efficient, a work-efficient, and a large array algorithm in this section.

***5.6.1 Step-efficient parallel scan operation***

A step-efficient algorithm uses the fewest number of steps. But this might not be the fewest number of operations because a different number of operations is possible with each step. This was discussed earlier when defining computational complexity in section 5.1.

The prefix sum operation can be made parallel with a tree-based reduction pattern as figure 5.17 shows. Rather than waiting for the previous element to sum up its values, each element sums its value and the preceding value. Then it does the same operation, but with the value two elements over, four elements over, and so on. The end result is an inclusive scan; during the operation all of the processes have been busy.

**Figure 5.17 The step-efficient inclusive scan uses O(log₂n) steps to compute a prefix sum in parallel.**

Now we have a parallel prefix that operates in just log2n steps, but the amount of work increases from the serial algorithm. Can we design a parallel algorithm that has the same amount of work?

***5.6.2 Work-efficient parallel scan operation***

A work-efficient algorithm uses the least number of operations. This might not be the fewest number of steps because a different number of operations is possible with each step. The choice of a work-efficient or a step-efficient algorithm is dependent on the number of parallel processes that can exist.

The work-efficient parallel scan operation uses two sweeps through the arrays. The first sweep is called an upsweep, though it is more of a right sweep. It is shown in figure 5.18 from top to bottom, rather than the traditional bottom to top for easier comparison to the step-efficient algorithm.

**Figure 5.18 The upsweep phase of the work-efficient scan shown from top to bottom, which has far fewer operations than the step-efficient scan. Essentially, every other value is left unmodified.**

The second phase, known as the downsweep phase, is more of a left sweep. It starts by setting the last value to zero and then does another tree-based sweep (figure 5.19) to get the final result. The amount of work is reduced significantly, but with the requirement of more steps.

**Figure 5.19 The downsweep phase of the work-efficient exclusive scan operation has far fewer operations than the step-efficient scan.**

When shown this way, the work-efficient scan has an interesting pattern, with a right sweep starting with half the threads and decreasing until only one is operating. Then it begins a sweep back to the left with one thread at the start and finishing with all threads busy. The additional steps allow the earlier calculations to be reused so that the total operations are only O(N ).

These two parallel prefix sum algorithms give us a couple of different options on how to incorporate parallelism in this essential operation. But both of these are limited to the number of threads available in a workgroup on the GPU or the number of processors on a CPU.

***5.6.3 Parallel scan operations for large arrays***

For larger arrays, we also need an algorithm that is parallel. Figure 5.20 shows such an algorithm using three kernels for the GPU. The first kernel starts with a reduction sum on each workgroup and stores the result in a temporary array that is smaller than the original large array by the number of threads in the workgroup. On the GPU, the number of threads in a workgroup is typically as high as 1,024. The second kernel then loops across the temporary array performing a scan on each work group-sized block. This results in the temporary array now holding the offsets for each work group. A third kernel is then invoked to perform the scan operation on work group-sized chunks of the original array, and an offset calculated for each thread at this level.

**Figure 5.20 The large array scan proceeds in three stages and as three kernels for the GPU. The first stage does a reduction sum to an intermediate array. The second stage does a scan to create the offsets for the work groups. Then the third phase scans the original array and applies the work group offsets to get the scan results for each element of the array.**

Because the parallel prefix sum is so important in operations like sorts, it is heavily optimized for GPU architectures. We don’t go into that level of detail in this book. Instead, we suggest that application developers use libraries or freely available implementations for their work. For the parallel prefix scan available for CUDA, you’ll find implementations such as the CUDA Data Parallel Primitives Library (CUDPP), available at <https://github.com/cudpp/cudpp>. For OpenCL, we suggest either the implementation from its parallel primitives library, CLPP, or the scan implementation from our hash-sorting code available in the sort_kern.cl file at [https://github.com/LANL/ PerfectHash.git](https://github.com/LANL/PerfectHash.git). We’ll present a version of the prefix scan for OpenMP in chapter 7.

***5.7 Parallel global sum: Addressing the problem of associativity***

Not all parallel algorithms are about speeding up calculations. The global sum is a prime example of such a case. Parallel computing has been plagued since the earliest days with the non-reproducibility of sums across processors. In this section, we show one example of an algorithm that improves the reproducibility of a parallel calculation so that it gets nearer to the results of the original serial calculation.

Changing the order of additions changes the answer in finite-precision arithmetic. This is problematic because a parallel calculation changes the order of the additions. The problem is due to finite-precision arithmetic not being associative. And the problem gets worse as the problem size gets larger because the addition of the last value becomes a smaller and smaller part of the overall sum. Eventually the addition of the last value might not change the sum at all. There is even a worse case for additions of finite-precision values when adding two values that are almost identical, but of different signs. This subtraction of one value from another when these are nearly the same causes a catastrophic cancellation. The result is only a few significant digits with noise filling the rest.

> **Example: Catastrophic cancellation**

> The subtraction of two nearly similar values will have a result with only a small number of significant figures. Put the following code in a file called catastrophic.py and run the program with `python catastrophic.py`.

> **Catastrophic cancellation in a short Python code**

> `x = 12.15692174374373 - 12.15692174374372`  
> `print x         `❶

> ❶ Returns 1.06581410364e-14

The result in the example has only a couple of significant digits left! And where do the rest of the digits in the printed value come from? The problem in parallel computing is that instead of the sum being a linear addition of the values in the array, on two processors the sum is a linear sum of half of the array and then the two partial sums added at the end. The change in the order causes the global sum to be different. The difference can be small, but now the question is whether the parallelization of the code has been done properly. Exacerbating the problem is that all of the new parallelization techniques and hardware, such as vectorization and threads, also cause this problem. The pattern for this global sum operation is called a reduction.

> > > **DEFINITION** A reduction is an operation where an array of one or more dimensions is reduced to at least one dimension less and often to a scalar value.

This operation is one of the most common in parallel computing and is often a concern for performance, and in this case, correctness. An example of this is calculating the total mass or energy in a problem. This takes a global array of the mass in each cell and results in a single scalar value.

As with all computer calculations, the results of the global sum reduction are not exact. In serial calculations, this does not pose a serious problem because we always get the same inexact result. In parallel, we most likely get a more accurate result with more correct significant digits, but it is different than the serial result. This is known as the global sum issue. Anytime the results between the serial and parallel versions were slightly different, the cause was attributed to this problem. But often, when time was taken to dig more deeply into the code, the problem turned out to be a subtle parallel programming error such as failing to update the ghost cells between processors. Ghost cells are cells that hold the adjacent processor values needed by the local processor, and if they are not updated, the slightly older values cause a small error compared to the serial run.

For years, I thought, like other parallel programmers, that the only solution was to sort the data into a fixed order and sum it up in a serial operation. But because this was too expensive, we just lived with the problem. In about 2010, several parallel programmers, including myself, realized that we were looking at the problem wrong. It is not solely an order problem, but also a precision problem. In real number arithmetic, addition is associative! So adding precision is also a way to solve the problem and at a far lower cost than sorting the data.

To gain a better understanding of the problem and how to solve it, let’s take a look at a problem from compressible fluid dynamics called the Leblanc problem, also known as “the shock tube from hell.” In the Leblanc problem, a high pressure region is separated from a low pressure region by a diaphragm that is removed at time zero. It is a challenging problem because of the strong shock that results. But the feature we are most interested in is the large dynamic range in both the density and energy variables. We’ll use the energy variable with a high value at 1.0e-1 and a low value of 1.0e-10. The dynamic range is the range of the working set of real numbers, or in this case, the ratio of the maximum and the minimum values. The dynamic range is nine orders of magnitude, which means that when adding the small value to the large value for double-precision, floating-point numbers with about 16 significant digits, in reality, we only have about 7 significant digits in the result.

Let’s look at a problem size of 134,217,728 on a single processor with half the values at the high energy state and the other half at the low energy state. These two regions are separated by a diaphragm at the beginning of the problem. The problem size is large for a single processor, but for a parallel computation, it is relatively small. If the high energy values are summed first, the next single low value that is added will have few significant digits to contribute. Reversing the order of the sum so that the low energy values are summed first makes the small values of near equal size in their sum, and by the time the high energy value is added, there will be more significant digits, thus a more accurate sum. This gives us a possible sorting-based solution. Just sort the values in order from the lowest magnitude to the highest and you will get a more accurate sum. There are several solutions for addressing the global sum that are much more tractable than the sorting technique. The list of possible techniques presented here includes

- Long-double data type

- Pairwise summation

- Kahan summation

- Knuth summation

- Quad-precision summation

You can try the various methods in the exercises that accompany the chapter at <https://github.com/EssentialsOfParallelComputing/Chapter5.git>. The original study looked at parallel OpenMP implementations and truncation techniques that we won’t go into here.

The easiest solution is to use the long-double data type on a x86 architecture. On this architecture, a long-double is implemented as an 80-bit floating-point number in hardware giving an extra 16-bits of precision. Unfortunately, this is not a portable technique. The long double on some architectures and compilers is only 64-bits, and on others it’s 128-bits and implemented in software. Some compilers also force rounding between operations to maintain consistency with other architectures. Check your compiler documentation carefully on how it implements a long-double when using this technique. The code shown in the next listing is simply a regular sum with the data type of the accumulator set to long double.

**Listing 5.16 Long-double data type sum on x86 architectures**

> `GlobalSums/do_ldsum.c`  
> `1 double do_ldsum(double *var, long ncells)`  
> `2 {`  
> `3    long double ldsum = 0.0;`  
> `4    for (long i = 0; i < ncells; i++){`  
> `5       ldsum += (long double)var[i];     `❶  
> `6    }`  
> `7    double dsum = ldsum;                 `❷  
> `8    return(dsum);                        `❸  
> `9 }`

❶ var is an array of doubles, while the accumulator is a long double.

❷ The return type of the function can also be long double and the value of ldsum returned.

❸ Returns a double

At line 8 in the listing, a double is returned to stay consistent with the concept of a higher precision accumulator returning the same data type as the array. We see how this performs later, but first let’s cover the other methods for addressing the global sum.

The pairwise summation is a surprisingly simple solution to the global sum problem, especially within a single processor. The code is relatively straightforward as the following listing shows but requires an additional array half the size of the original.

**Listing 5.17 Pairwise summation on processor**

> `GlobalSums/do_pair_sum.c`  
> `4 double do_pair_sum(double *var, long ncells)`  
> `5 {`  
> `6    double *pwsum =`  
> `       (double *)malloc(ncells/2*sizeof(double));  `❶  
> `7`  
> `8    long nmax = ncells/2;`  
> `9    for (long i = 0; i<nmax; i++){               `❷  
> `10       pwsum[i] = var[i*2]+var[i*2+1];           `❷  
> `11    }                                            `❷  
> `12`  
> `13    for (long j = 1; j<log2(ncells); j++){       `❸  
> `14       nmax /= 2;                                `❸  
> `15       for (long i = 0; i<nmax; i++){            `❸  
> `16          pwsum[i] = pwsum[i*2]+pwsum[i*2+1];    `❸  
> `17       }                                         `❸  
> `18    }                                            `❸  
> `19    double dsum = pwsum[0];                      `❹  
> `20    free(pwsum);                                 `❺  
> `21    return(dsum);`  
> `22 }`

❶ Needs temporary space to do the pairwise recursive sums

❷ Adds the initial pairwise sum into new array

❸ Recursively sums the remaining log2 steps, reducing array size by two for each step

❹ Assigns the result to a scalar value for return

❺ Frees temporary space

The simplicity of the pairwise summation becomes a little more complicated when working across processors. If the algorithm remains true to its basic structure, a communication may be needed at each step of the recursive sum.

Next is the Kahan summation. The Kahan summation is the most practical method of the possible global sum methods. It uses an additional double variable to carry the remainder of the operation, in effect doubling the effective precision. The technique was developed by William Kahan in 1965 (Kahan later became one of the key contributors to the early IEEE floating-point standards). The Kahan summation is most appropriate for a running summation when the accumulator is the larger of two values. The following listing shows this technique.

**Listing 5.18 Kahan summation**

> `GlobalSums/do_kahan_sum.c`  
> `1 double do_kahan_sum(double *var, long ncells)`  
> `2 {`  
> `3    struct esum_type{                                   `❶  
> `4       double sum;                                      `❶  
> `5       double correction;                               `❶  
> `6    };                                                  `❶  
> `7`  
> `8    double corrected_next_term, new_sum;`  
> `9    struct esum_type local;`  
> `10`  
> `11    local.sum = 0.0;`  
> `12    local.correction = 0.0;`  
> `13    for (long i = 0; i < ncells; i++) {`  
> `14       corrected_next_term = var[i] + local.correction;`  
> `15       new_sum          = local.sum + local.correction;`  
> `16       local.correction = corrected_next_term -         `❷  
> `                            (new_sum - local.sum);        `❷  
> `17       local.sum        = new_sum;`  
> `18    }`  
> `19`  
> `20   double dsum = local.sum + local.correction;          `❸  
> `21   return(dsum);                                        `❸  
> `22 }`

❶ Declares a double-double data type

❷ Computes the remainder to carry to the next iteration

❸ Returns the double-precision result

The Kahan summation takes about four floating-point operations instead of one. But the data can be kept in registers or the L1 cache, making the operation less expensive than we might initially expect. Vectorized implementations can make the operation cost the same as the standard summation. This is an example where we use the excess floating-point capability of the processor to get a better answer.

We’ll look at a vector implementation of the Kahan sum in section 6.3.4. Some new numerical methods are attempting a similar approach, using the excess floating-point capability of current processors. These view the current machine balance of 50 flops per data load as an opportunity and implement higher-order methods that require more floating-point operations to exploit the unused floating-point resource because it is essentially free.

The Knuth summation method handles additions where either term can be larger. The technique was developed by Donald Knuth in 1969. It collects the error for both terms at a cost of seven floating-point operations as the following listing shows.

**Listing 5.19 Knuth summation**

> `GlobalSums/do_knuth_sum.c`  
> `1 double do_knuth_sum(double *var, long ncells)`  
> `2 {`  
> `3    struct esum_type{                             `❶  
> `4       double sum;                                `❶  
> `5       double correction;                         `❶  
> `6    };                                            `❶  
> `7`  
> `8   double u, v, upt, up, vpp;`  
> `9   struct esum_type local;`  
> `10`  
> `11   local.sum = 0.0;`  
> `12   local.correction = 0.0;`  
> `13   for (long i = 0; i < ncells; i++) {`  
> `14      u = local.sum;`  
> `15      v = var[i] + local.correction;`  
> `16      upt = u + v;`  
> `17      up = upt - v;                               `❷  
> `18      vpp = upt - up;                             `❷  
> `19      local.sum = upt;`  
> `20      local.correction = (u - up) + (v - vpp);    `❸  
> `21   }`  
> `22`  
> `23   double dsum = local.sum + local.correction;    `❹  
> `24   return(dsum);                                  `❹  
> `25 }`

❶ Defines a double-double data type

❷ Carries the values for each term

❸ Combined into one correction

❹ Returns the double-precision result

The last technique, the quad-precision sum, has the advantage of simplicity in coding, but because the quad-precision types are almost always done in software, it is expensive. Portability is also something to beware of as not all compilers have implemented the quad-precision type. The following listing presents this code.

**Listing 5.20 Quad precision global sum**

> `GlobalSums/do_qdsum.c`  
> `1 double do_qdsum(double *var, long ncells)`  
> `2 {`  
> `3    __float128 qdsum = 0.0;               `❶  
> `4    for (long i = 0; i < ncells; i++){`  
> `5       qdsum += (__float128)var[i];       `❷  
> `6    }`  
> `7    double dsum =qdsum;`  
> `8    return(dsum);`  
> `9 }`

❶ Quad precision data type

❷ Casts the input value from array to quad precision

Now on to the assessment of how these different approaches work. Because half the values are 1.0e-1 and the other half are 1.0e-10, we can get an accurate answer to compare against by multiplying instead of adding:

> `accurate_answer = ncells/2 * 1.0e-1 + ncells/2 * 1.0e-10`

Table 5.1 shows the results of comparing the global sum values actually obtained versus the accurate answer and measuring the run time. We essentially get nine digits of accuracy with a regular summation of doubles. The long double on a system with an 80-bit floating-point representation improves it somewhat, but doesn’t completely eliminate the error. The pairwise, Kahan and Knuth summations all reduce the error to zero with a modest increase in run time. A vectorized implementation of the Kahan and Knuth summation (shown in section 6.3.4) eliminates the increase in run time. Even so, when considering cross-processor communications and the cost of MPI calls, the increase in run time is insignificant.

**Table 5.1 Precision and run-time results for various global sum techniques**

| **Method**         | **Error** | **Run time** |
|--------------------|-----------|--------------|
| Double             | -1.99e-09 | 0.116        |
| Long double        | -1.31e-13 | 0.118        |
| Pairwise summation | 0.0       | 0.402        |
| Kahan summation    | 0.0       | 0.406        |
| Knuth summation    | 0.0       | 0.704        |
| Quad double        | 5.55e-17  | 3.010        |

Now that we understand the behavior of the global sum techniques on a processor, we can consider the problem when the arrays are distributed across multiple processors. We need some understanding of MPI to tackle this problem, so we will show how to do this in section 8.3.3, after learning the basics of MPI.

***5.8 Future of parallel algorithm research***

We have seen some of the characteristics of parallel algorithms including those suitable for extremely parallel architectures. Let’s summarize these so that we can look for them in other situations:

- Locality—Often-used term in describing good algorithms but without any definition. It can have multiple meanings. Here are a couple:

- - Locality for cache—Keeps the values that will be used together close together so that cache utilization is improved.

  - Locality for operations—Avoids operating on all the data when not all is needed. The spatial hash for particle interactions is a classic example that keeps an algorithm’s complexity O(N ) instead of O(N ²).

- Asynchronous—Avoids coordination between threads that can cause synchronization.

- Fewer conditionals—Besides the additional performance hit from conditional logic, thread divergence can be a problem on some architectures.

- Reproducibility—Often a highly parallel technique violates the lack of associativity of finite-precision arithmetic. Enhanced-precision techniques can help counter this issue.

- Higher arithmetic intensity—Current architectures have added floating-point capability faster than memory bandwidth. Algorithms that increase arithmetic intensity can make good use of parallelism such as the vector operations.

***5.9 Further explorations***

The development of parallel algorithms is still a young field of research, and there are many new algorithms to be discovered. But there are also many known techniques that have not been widely disseminated or used. Particularly challenging is that the algorithms are often in wildly different fields of computer or computational science.

***5.9.1 Additional reading***

For more on algorithms, we recommend a popular textbook:

Thomas Cormen, et al., Introduction to Algorithms, 3rd ed (MIT Press, 2009).

For more information on patterns and algorithms, here are two good books for further reading:

- Michael McCool, Arch D. Robison, and James Reinders, Structured Parallel Programming: Patterns for Efficient Computation (Morgan Kaufmann, 2012).

- Timothy G. Mattson, Beverly A. Sanders, and Berna L. Massingill, Patterns for Parallel Programming (Addison-Wesley, 2004).

The concepts of spatial hashing have been developed by some of my students ranging from high school level through graduate students. The section on perfect hashing in the following resource draws from work by Rachel Robey and David Nicholaeff. David also implemented spatial hashing in the CLAMR mini-app.

Rachel N. Robey, David Nicholaeff, and Robert W. Robey, “Hash-based algorithms for discretized data,” SIAM Journal on Scientific Computing 35, no. 4 (2013): C346-C368.

The ideas for parallel compact hashing for neighbor finding came from Rebecka Tumblin, Peter Ahrens, and Sara Hartse. These were built from the methods to reduce the writes and reads developed by David Nicholaeff.

Rebecka Tumblin, Peter Ahrens, et al., “Parallel compact hash algorithms for computational meshes,” SIAM Journal on Scientific Computing 37, no. 1 (2015): C31-C53.

Developing optimized methods for the remap operation was much more challenging. Gerald Collom and Colin Redman tackled the problem and came up with some really innovative techniques and implementations on the GPU and in OpenMP. This chapter only touches on some of these. There are far more ideas in their paper:

Gerald Collom, Colin Redman, and Robert W. Robey, “Fast Mesh-to-Mesh Remaps Using Hash Algorithms,” SIAM Journal on Scientific Computing 40, no. 4 (2018): C450-C476.

I first developed the concept of enhanced-precision global sums in about 2010. Jonathan Robey implemented the technique in his Sapient hydrocode and Rob Aulwes, Los Alamos National Laboratory, helped develop the theoretical foundations. The following two references give more details on the method:

- Robert W. Robey, Jonathan M. Robey, and Rob Aulwes, “In search of numerical consistency in parallel programming,” Parallel Computing 37, no. 4-5 (2011): 217-229.

- Robert W. Robey, “Computational Reproducibility in Production Physics Applications,” Numerical Reproducibility at Exascale Workshop (NRE2015), International Conference for High Performance Computing, Networking, Storage and Analysis, 2015. Available at [https://github.com/lanl/ExascaleDocs/blob/master/ ComputationalReproducibilityNRE2015.pdf](https://github.com/lanl/ExascaleDocs/blob/master/ComputationalReproducibilityNRE2015.pdf)

***5.9.2 Exercises***

1.  A cloud collision model in an ash plume is invoked for particles within a 1 mm distance. Write pseudocode for a spatial hash implementation. What complexity order is this operation?

2.  How are spatial hashes used by the postal service?

3.  Big data uses a map-reduce algorithm for efficient processing of large data sets. How is it different than the hashing concepts presented here?

4.  A wave simulation code uses an AMR mesh to better refine the shoreline. The simulation requirements are to record the wave heights versus time for specified locations where buoys and shore facilities are located. Because the cells are constantly being refined, how could you implement this?

***Summary***

- Algorithms and patterns are one of the foundations of computational applications. Selecting algorithms that have low computational complexity and lend themselves to parallelization is important when first developing an application.

- A comparison-based algorithm has a lower complexity limit of O(N log N ). Non-comparison algorithms can break this lower algorithmic limit.

- Hashing is a non-comparison technique that has been used in spatial hashing to achieve Θ(N ) complexity for spatial operations.

- For any spatial operation, there is a spatial hashing algorithm that scales as O(N ). In this chapter, we provide examples of techniques that can be used in many scenarios.

- Certain patterns have been shown to be adaptable to parallelism and the asynchronous nature of GPUs. The prefix scan and hashing techniques are two such patterns. The prefix scan is important for parallelizing irregular-sized arrays. Hashing is a non-comparison, asynchronous algorithm that is highly scalable.

- Reproducibility is an important attribute in developing robust production applications. This is especially important for reproducible global sums and for dealing with finite-precision arithmetic operations that are not associative.

- Enhanced precision is a new technique that restores associativity, allowing reordering of operations, and thus, more parallelism.
