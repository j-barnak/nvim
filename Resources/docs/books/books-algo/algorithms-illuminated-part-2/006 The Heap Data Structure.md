## Chapter 10

 

The Heap Data Structure

 

The remaining three chapters of this book are about three of the most important and ubiquitous data structures out there—heaps, search trees, and hash tables. The goals are to learn the operations that these data structures support (along with their running times), to develop through example applications your intuition about which data structures are useful for which sorts of problems, and optionally, to

learn a bit about how they are implemented under the hood. 1 We begin with heaps, a data structure that facilitates fast minimum or maximum computations.

 

10.1 Data Structures: An Overview

10.1.1 Choosing the Right Data Structure

Data structures are used in almost every major piece of software, so knowing when and how to use them is an essential skill for the serious programmer. The raison d’être of a data structure is to organize data so you can access it quickly and usefully. You’ve already seen a few examples. The queue data structure, used in our linear-time

implementation of breadth-first search (Section 8.2), sequentially organizes data so that removing an object from the front or adding an object to the back takes constant time. The stack data structure, which was crucial in our iterative implementation of depth-first search

(Section 8.4), lets you remove an object from or add an object to the front in constant time.

There are many more data structures out there—in this book series,

we’ll see heaps, binary search trees, hash tables, bloom filters, and (in

1 Some programmers reserve the phrase data structure for a concrete imple-

mentation, and refer to the list of supported operations as an abstract data type.

 

95

96 The Heap Data Structure

 

Part 3) union-find. Why such a bewildering laundry list? Because different data structures support different sets of operations, making them well-suited for different types of programming tasks. For example, breadth- and depth-first search have different needs, necessitating two different data structures. Our fast implementation of Dijkstra’s

shortest-path algorithm (in Section 10.4) has still different needs, requiring the more sophisticated heap data structure.

What are the pros and cons of different data structures, and how should you choose which one to use in a program? In general, the more operations a data structure supports, the slower the operations and the greater the space overhead. The following quote, widely attributed to Albert Einstein, is germane:

“Make things as simple as possible, but not simpler.”

When implementing a program, it’s important that you think carefully about exactly which operations you’ll use over and over again. For example, do you care only about tracking which objects are stored in a data structure, or do you also want them ordered in a specific way? Once you understand your program’s needs, you can follow the principle of parsimony and choose a data structure that supports all the desired operations and no superfluous ones.

Principle of Parsimony

Choose the simplest data structure that supports all the operations required by your application.

 

10.1.2 Taking It to the Next Level

What are your current and desired levels of expertise in data struc-tures?

Level 0: “What’s a data structure?”

Level 0 is total ignorance—someone who has never heard of a data structure and is unaware that cleverly organizing your data can dramatically improve a program’s running time.

10.2 Supported Operations 97

 

Level 1: “I hear good things about hash tables.”

Level 1 is cocktail party-level awareness—at this level, you could

at least have a conversation about basic data structures.2 You have heard of several basic structures like search trees and hash tables, and are perhaps aware of some of their supported operations, but would be shaky trying to use them in a program or a technical interview.

Level 2: “This problem calls out for a heap.”

With level 2, we’re starting to get somewhere. This is someone

who has solid literacy about basic data structures, is comfortable using them as a client in their own programs, and has a good sense of which data structures are appropriate for which types of programming tasks.

Level 3: “I use only data structures that I wrote myself.”

Level 3, the most advanced level, is for hardcore programmers

and computer scientists who are not content to merely use existing data structure implementations as a client. At this level, you have a detailed understanding of the guts of basic data structures, and exactly how they are implemented.

The biggest marginal empowerment comes from reaching level 2.

Most programmers will, at some point, need to be educated clients of basic data structures like heaps, search trees, and hash tables. The

primary goal of Chapters 10–12 is to bring you up to this level with these data structures, with a focus on the operations they support and their canonical applications. All these data structures are readily available in the standard libraries of most modern programming languages, waiting to be deftly deployed in your own programs.

Advanced programmers do sometimes need to implement a cus-

tomized version of one of these data structures from scratch. Each

of Chapters 10–12 includes at least one advanced section on typical implementations of these data structures. These sections are for those of you wanting to up your game to level 3.

2 Speaking, as always, about sufficiently nerdy cocktail parties! 98 The Heap Data Structure

 

10.2 Supported Operations

A heap is a data structure that keeps track of an evolving set of objects with keys and can quickly identify the object with the smallest

key. 3 For example, objects might correspond to employee records, with keys equal to their identification numbers. They might be the edges of a graph, with keys corresponding to edge lengths. Or they could correspond to events scheduled for the future, with each key

indicating the time at which the event will occur.4

10.2.1 Insert and Extract-Min

The most important things to remember about any data structure are the operations it supports and the time required for each. The two most important operations supported by heaps are the Insert

and 5 ExtractMin operations.

Heaps: Basic Operations

Insert : given a heap H and a new object x, add x to H.

ExtractMin: given a heap H, remove and return from H an object with the smallest key (or a pointer to it).

 

For example, if you invoke Insert four times to add objects with keys 12, 7, 29, and 15 to an empty heap, the ExtractMin operation will return the object with key 7. Keys need not be distinct; if there is more than one object in a heap with the smallest key, the ExtractMin operation returns an arbitrary such object.

It would be easy to support only the Insert operation, by re-peatedly tacking on new objects to the end of an array or linked list (in constant time). The catch is that ExtractMin would require a linear-time exhaustive search through all the objects. It’s also clear how to support only ExtractMin—sort the initial set of n objects by key once and for all up front (using O(n log n) preprocessing time),

3 Not to be confused with heap memory, the part of a program’s memory

reserved for dynamic allocation. 4 Keys are often numerical but can belong to any totally ordered set—what

matters is that for every pair of non-equal keys, one is less than the other. 5 Data structures supporting these operations are also called priority queues. 10.2 Supported Operations 99

 

and then successive calls to ExtractMin peel off objects from the beginning of the sorted list one by one (each in constant time). Here the catch is that any straightforward implementation of Insert re-quires linear time (as you should check). The trick is to design a data structure that enables both operations to run super-quickly. This is exactly the raison d’être of heaps.

Standard implementations of heaps, like the one outlined in Sec-

tion 10.5, provide the following guarantee.

Theorem 10.1 (Running Time of Basic Heap Operations) In a heap with n objects, the Insert and ExtractMin operations run in O(log n) time.

As a bonus, in typical implementations, the constant hidden by the big-O notation is very small, and there is almost no extra space overhead.

There’s also a heap variant that supports the Insert and Ex-

tractMax operations in O(log n) time, where n is the number of objects. One way to implement this variant is to switch the direction

of all the inequalities in the implementation in Section 10.5. A second way is to use a standard heap but negate the keys of objects before inserting them (which effectively transforms ExtractMin into Ex-tractMax). Neither variant of a heap supports both ExtractMin and ExtractMax simultaneously in O(log n) time—you have to

pick which one you want.6

10.2.2 Additional Operations

Heaps can also support a number of less essential operations.

Heaps: Extra Operations

FindMin: given a heap H, return an object with the small-est key (or a pointer to it).

Heapify : given objects x1, . . . , xn, create a heap containing them.

 

6 If you want both, you can use one heap of each type (see also Section 10.3.3),

or upgrade to a balanced binary search tree (see Chapter 11).

100 The Heap Data Structure

 

Delete: given a heap H and a pointer to an object x in H, delete x from H.

You could simulate a FindMin operation by invoking Extract-Min and then applying Insert to the result (in O(log n) time, by

Theorem 10.1), but a typical heap implementation can avoid this circuitous solution and support FindMin directly in O(1) time. You could implement Heapify by inserting the n objects one by one

into an empty heap (in O(n log n) total time, by Theorem 10.1), but there’s a slick way to add n objects to an empty heap in a batch in total time O(n). Finally, heaps can also support deletions of arbitrary objects—not just an object with the smallest key—in O(log n) time

(see also Programming Project 10.8).

 

Theorem 10.2 (Running Time of Extra Heap Operations) In a heap with n objects, the FindMin, Heapify, and Delete operations run in O(1), O(n), and O(log n) time, respectively.

Summarizing, here’s the final scorecard for heaps:

 

Operation Running time

Insert O(log n)

ExtractMin O(log n)

FindMin O(1) Heapify O(n)

Delete O(log n)

Table 10.1: Heaps: supported operations and their running times, where n denotes the current number of objects stored in the heap.

 

When to Use a Heap

If your application requires fast minimum (or maximum) computations on a dynamically changing set of objects, the heap is usually the data structure of choice.

10.3 Applications 101

 

10.3 Applications

The next order of business is to walk through several example appli-cations and develop a feel for what heaps are good for. The common theme of these applications is the replacement of minimum compu-tations, naively implemented using (linear-time) exhaustive search, with a sequence of (logarithmic-time) ExtractMin operations from a heap. Whenever you see an algorithm or program with lots of brute-force minimum or maximum computations, a light bulb should go off in your head: This calls out for a heap!

10.3.1 Application: Sorting

For our first application, let’s return to the mother of all computational problems, sorting.

Problem: Sorting

Input: An array of n numbers, in arbitrary order.

Output: An array of the same numbers, sorted from small-est to largest.

 

For example, given the input array

 

5 4 1 8 7 2 6 3

 

the desired output array is

 

1 2 3 4 5 6 7 8

 

Perhaps the simplest sorting algorithm is SelectionSort. This

algorithm performs a linear scan through the input array to identify the minimum element, swaps it with the first element in the array, does a second scan over the remaining n 1 elements to identify and swap into the second position the second-smallest element, and so on. Each scan takes time proportional to the number of remaining 102 The Heap Data Structure

 

elements, so the overall running time is P n 7 2 ⇥ ( i ) = ⇥ ( n ) i =1 . Because each iteration of SelectionSort computes a minimum element using exhaustive search, it calls out for a heap! The idea is simple: Insert all the elements in the input array into a heap, and populate the output array from left to right with successively extracted minimum elements. The first extraction produces the smallest element; the second the smallest remaining element (the second-smallest overall); and so on.

 

HeapSort

Input: array A of n distinct integers. Output: array B with the same integers, sorted from

smallest to largest.

H := empty heap

for i = 1 to n do

Insert A\[i\] into H

for i = 1 to n do

B \[i\] := ExtractMin from H

 

Quiz 10.1

What’s the running time of HeapSort, as a function of the length n of the input array?

a\) O(n)

b\) O(n log n)

c\) 2 O ( n)

d\) 2 O ( n log n)

(See below for the solution and discussion.)

 

7 n 2 P The sum i i n n =1 is at most (it has n terms, each at most ) and at least

n2/4 (it has n/2 terms that are all at least n/2). 10.3 Applications 103

 

Correct answer: (b). The work done by HeapSort boils down

to 2 8 n operations on a heap containing at most n objects. Because

Theorem 10.1 guarantees that every heap operation requires O(log n) time, the overall running time is O(n log n).

Theorem 10.3 (Running Time of HeapSort) For every input ar-ray of length n 1, the running time of HeapSort is O(n log n).

Let’s take a step back and appreciate what just happened. We

started with the least imaginative sorting algorithm possible, the quadratic-time SelectionSort algorithm. We recognized the pat-tern of repeated minimum computations, swapped in a heap data structure, and—boom!—out popped an O(n log n)-time sorting algo-

rithm.9 This is a great running time for a sorting algorithm—it’s even optimal, up to constant factors, among comparison-based sorting

algorithms.10 A neat byproduct of this observation is a proof that there’s no comparison-based way to implement both the Insert and ExtractMin operations in better-than-logarithmic time: such a solution would yield a better-than-O(n log n)-time comparison-based sorting algorithm, and we know this is impossible.

10.3.2 Application: Event Manager

Our second application, while a bit obvious, is both canonical and practical. Imagine you’ve been tasked with writing software that performs a simulation of the physical world. For example, perhaps you’re contributing to a basketball video game. For the simulation,

8 An even better implementation would replace the first loop with a single

Heapify operation, which runs in O(n) time. The second loop still requires O(n log n) time, however.

9 For clarity we described HeapSort using separate input and output arrays,

but it can be implemented in place, with almost no additional memory. This in-place implementation is a super-practical algorithm, and is almost as fast as QuickSort in most applications.

10 Recall from Section 5.6 of Part 1 that a comparison-based sorting algo-rithm accesses the input array only via comparisons between pairs of elements, and never directly accesses the value of an element. “General-purpose” sorting algorithms, which make no assumptions about the elements to be sorted, are necessarily comparison-based. Examples include SelectionSort, InsertionSort, HeapSort, and QuickSort. Non-examples include BucketSort, CountingSort, and RadixSort. Theorem 5.5 from Part 1 shows that no comparison-based sorting algorithm has a worst-case asymptotic running time better than ⇥(n log n). 104 The Heap Data Structure

 

you must keep track of different events and when they should occur— the event that a player shoots the ball at a particular angle and velocity, that the ball consequently hits the back of the rim, that two players vie for the rebound at the same time, that one of these players commits an over-the-back foul on the other, and so on.

A simulation must repeatedly identify what happens next. This boils down to repeated minimum computations on the set of scheduled event times, so a light bulb should go off in your head: The problem calls out for a heap! If events are stored in a heap, with keys equal to their scheduled times, the ExtractMin operation hands you the next event on a silver platter, in logarithmic time. New events can be inserted into the heap as they arise (again, in logarithmic time).

 

10.3.3 Application: Median Maintenance

For a less obvious application of heaps, let’s consider the median maintenance problem. You are presented with a sequence of numbers, one by one; assume for simplicity that they are distinct. Each time you receive a new number, your responsibility is to reply with the

median element of all the numbers you’ve seen thus far.11 Thus, after seeing the first 11 numbers, you should reply with the sixth-smallest one you’ve seen; after 12, the sixth- or seventh-smallest; after 13, the seventh-smallest; and so on.

One approach to the problem, which should seem like overkill, is to recompute the median from scratch in every iteration. We saw in Chapter 6 of Part 1 how to compute the median of a length-n array in O(n) time, so this solution requires O(i) time in each round i. Alternatively, we could keep the elements seen so far in a sorted array, so that it’s easy to compute the median element in constant time. The drawback is that updating the sorted array when a new number arrives can require linear time. Can we do better?

Using heaps, we can solve the median maintenance problem in just logarithmic time per round. I suggest putting the book down at this point and spending several minutes thinking about how this might be done.

11 Recall that the median of a collection of numbers is its “middle element.” In

an array with odd length 2k 1, the median is the kth order statistic (that is, the kth-smallest element). In an array with even length 2k, both the kth and (k + 1)th order statistics are considered median elements. 10.4 Speeding Up Dijkstra’s Algorithm 105

 

The key idea is to maintain two heaps H1 and H2 while satisfying

two invariants.12 H The first invariant is that1 and H2 are balanced, meaning they each contain the same number of elements (after an even round) or that one contains exactly one more element than the other (after an odd round). The second invariant is that H1 and H2 are ordered, meaning every element in H1 is smaller than every element in H2. For example, if the numbers so far have been 1, 2, 3, 4, 5, then H1 stores 1 and 2 and H2 stores 4 and 5; the median element 3 is allowed to go in either one, as either the maximum element of H1 or the minimum element of H2. If we’ve seen 1, 2, 3, 4, 5, 6, then the first three numbers are in H1 and the second three are in H2; both the maximum element of H1 and the minimum element of H2 are median elements. One twist: H2 will be a standard heap, supporting Insert and ExtractMin, while H1 will be the “max” variant described in

Section 10.2.1, supporting Insert and ExtractMax. This way, we can extract the median element with one heap operation, whether it’s in H1 or H2.

We still must explain how to update H1 and H2 each time a

new element arrives so that they remain balanced and ordered. To figure out where to insert a new element x so that the heaps remain ordered, it’s enough to compute the maximum element y in H1 and

the minimum element z 13 in H 2 . If x is less than y, it has to go in H1; if it’s more than z, it has to go in H2; if it’s in between, it can go in either one. Do H1 and H2 stay balanced even after x is inserted? Yes, except for one case: In an even round 2k, if x is inserted into the bigger heap (with k elements), this heap will contain k + 1 elements

while the other contains only k 1 elements (Figure 10.1(a)). But this imbalance is easy to fix: Extract the maximum or minimum element from H1 or H2, respectively (whichever contains more elements), and

re-insert this element into the other heap (Figure 10.1(b)). The two heaps stay ordered (as you should check) and are now balanced as well. This solution uses a constant number of heap operations each round, for a running time of O(log i) in round i.

 

12 An invariant of an algorithm is a property that is always true at prescribed

points of its execution (like at the end of every loop iteration). 13 This can be done in logarithmic time by extracting and re-inserting these two elements. A better solution is to use the FindMin and FindMax operations,

which run in constant time (see Section 10.2.2).

106 The Heap Data Structure

 

heap *H**1* 6 heap *H**2* heap *H**1* rebalance heap *H**2* insert

3

1 5 5 6 3 1 3

![](media/index-119_1.jpg)

2 4 2 4

![](media/index-119_2.jpg)

(a) Insertion can cause imbalance (b) Rebalancing

![](media/index-119_3.jpg)

Figure 10.1: When inserting a new element causes the heap H2 to have two more elements than H1, the smallest element in H2 is extracted and re-inserted into H1 to restore balance.

![](media/index-119_4.jpg)

 

10.4 Speeding Up Dijkstra’s Algorithm

![](media/index-119_5.jpg)

Our final and most sophisticated application of heaps is a near linear-time implementation of Dijkstra’s algorithm for the single-source

![](media/index-119_6.jpg)

shortest path problem (Chapter 9). This application vividly illustrates the beautiful interplay between the design of algorithms and the design of data structures.

![](media/index-119_7.jpg)

10.4.1 Why Heaps?

![](media/index-119_8.jpg)

We saw in Proposition 9.2 that the straightforward implementation of Dijkstra’s algorithm requires O(mn) time, where m is the number of edges and n is the number of vertices. This is fast enough to process medium-size graphs (with thousands of vertices and edges) but not big graphs (with millions of vertices and edges). Can we do better? Heaps enable a blazingly fast, near-linear-time implementation of Dijkstra’s algorithm.

![](media/index-119_9.jpg)

Theorem 10.4 (Dijkstra Running Time (Heap-Based)) For every directed graph G = (V, E), every starting vertex s, and every choice of nonnegative edge lengths, the heap-based implementation of Dijkstra runs in O((m + n) log n) time, where m = \|E\| and n = \|V \|.

![](media/index-119_10.jpg)

While not quite as fast as our linear-time graph search algorithms, O((m + n) log n) is still a fantastic running time—comparable to our best sorting algorithms, and good enough to qualify as a for-free primitive.

![](media/index-119_11.jpg)

Let’s remember how Dijkstra’s algorithm works (Section 9.2). The algorithm maintains a subset X ✓ V of vertices to which it 10.4 Speeding Up Dijkstra’s Algorithm 107

![](media/index-119_12.jpg)

![](media/index-119_13.jpg)

![](media/index-119_14.jpg)

![](media/index-119_15.jpg)

 

has already computed shortest-path distances. In every iteration, it identifies the edge crossing the frontier (with tail in X and head in V X) with the minimum Dijkstra score, where the Dijkstra score of such an edge (v, w) is the (already computed) shortest-path distance len(v) from the starting vertex to v plus the length \`vw of the edge. In other words, every iteration of the main loop does a minimum computation, on the Dijkstra scores of the edges that cross the frontier. The straightforward implementation uses exhaustive search to perform these minimum computations. As speeding up minimum computations from linear time to logarithmic time is the raison d’être of heaps, at this point a light bulb should go off in your head: Dijkstra’s algorithm calls out for a heap!

 

10.4.2 The Plan

What should we store in a heap, and what should their keys be? Your first thought might be to store the edges of the input graph in a heap, with an eye toward replacing the minimum computations (over edges) in the straightforward implementation with calls to ExtractMin. This idea can be made to work, but the slicker and quicker implemen-tation stores vertices in a heap. This might surprise you, as Dijkstra scores are defined for edges and not for vertices. On the flip side, we cared about edges’ Dijkstra scores only inasmuch as they guided us to the vertex to process next. Can we use a heap to cut to the chase and directly compute this vertex?

The concrete plan is to store the as-yet-unprocessed vertices (V

X in the Dijkstra pseudocode) in a heap, while maintaining the following invariant.

Invariant

The key of a vertex w 2 V X is the minimum Dijkstra score of an edge with tail v 2 X and head w, or +1 if no such edge exists.

 

That is, we want the equation

 

key(w) = min len(v) + \`vw (10.1) ( v,w ) 2 E : v 2 X \| {z } Dijkstra score 108 The Heap Data Structure

 

to hold at all times for every w 2 V X, where len(v) denotes the shortest-path distance of v computed in an earlier iteration of the

algorithm (Figure 10.2).

processed not-yet-processed

 

key(*v*) = 3

X score = 7

*v* V-X

score = 3

![](media/index-121_1.jpg)

*s*

![](media/index-121_2.jpg)

score = 5 key(*w*) = 5 *w*

![](media/index-121_3.jpg)

key(*z*) = +∞

![](media/index-121_4.jpg)

*z*

![](media/index-121_5.jpg)

 

Figure 10.2: The key of a vertex w 2 V X is defined as the minimum Dijkstra score of an edge with head w and tail in X.

![](media/index-121_6.jpg)

 

What’s going on? Imagine that we use a two-round knockout tournament to identify the edge (v, w) with v 2 X and w / 2 X with the minimum Dijkstra score. The first round comprises a local tournament for each vertex w 2 V X, where the participants are the edges (v, w) with v 2 X and head w, and the first-round winner is the participant with the smallest Dijkstra score (if any). The first-round winners (at most one per vertex w 2 V X) proceed to the second round, and the final champion is the first-round winner with the lowest Dijkstra score. This champion is the same edge that would be identified by exhaustive search.

![](media/index-121_7.jpg)

The value of the key (10.1) of a vertex w 2 V X is exactly the winning Dijkstra score in the local tournament at w, so our invariant effectively implements all the first-round competitions. Extracting the vertex with the minimum key then implements the second round of the tournament, and returns on a silver platter the next vertex to process, namely the head of the crossing edge with the smallest Dijkstra score. The point is, as long as we maintain our invariant, we can implement each iteration of Dijkstra’s algorithm with a single heap operation.

![](media/index-121_8.jpg)

![](media/index-121_9.jpg)

![](media/index-121_10.jpg)

![](media/index-121_11.jpg)

![](media/index-121_12.jpg)

10.4 Speeding Up Dijkstra’s Algorithm 109

 

The pseudocode looks like this:14

Dijkstra (Heap-Based, Part 1)

Input: directed graph G = (V, E) in adjacency-list

representation, a vertex s 2 V , a length \`e 0 for each e 2 E.

Postcondition: for every vertex v, the value len(v)

equals the true shortest-path distance dist(s, v).

// Initialization

1 X := empty set, H := empty heap 2 key(s) := 0

3 for every v 6= s do

4 key(v) := +1

5 for every v 2 V do

6 Insert v into H // or use Heapify

// Main loop

7 while H is non-empty do 8 ⇤ w := ExtractMin(H) 9 add ⇤ w to X

10 ⇤ ⇤ len ( w ) := key ( w)

// update heap to maintain invariant

11 (to be announced)

 

But how much work is it to maintain the invariant?

10.4.3 Maintaining the Invariant

Now it’s time to pay the piper. We enjoyed the fruits of our invariant, which reduces each minimum computation required by Dijkstra’s algorithm to a single heap operation. In exchange, we must explain how to maintain it without excessive work.

Each iteration of the algorithm moves one vertex v from V X

to X, which changes the frontier (Figure 10.3). Edges from vertices

14 Initializing the set X of processed vertices to the empty set rather than to the

starting vertex leads to cleaner pseudocode (cf., Section 9.2.1). The first iteration of the main loop is guaranteed to extract the starting vertex (do you see why?), which is then the first vertex added to X. 110 The Heap Data Structure

 

in X to v get sucked into X and no longer cross the frontier. More problematically, edges from v to other vertices of V X no longer reside entirely in V X and instead cross from X to V X. Why is

this a problem? Because our invariant (10.1) insists that, for every vertex w 2 V X, w’s key equals the smallest Dijkstra score of a crossing edge ending at w. New crossing edges mean new candidates

for the smallest Dijkstra score, so the right-hand side of (10.1) might decrease for some vertices w. For example, the first time a vertex v with (v, w) 2 E gets sucked into X, this expression drops from +1 to a finite number (namely, len(v) + \`vw).

processed not-yet-processed processed not-yet-processed

 

*s* X *v* X *v* V-X V-X

![](media/index-123_1.jpg)

*s*

![](media/index-123_2.jpg)

*w* *w*

![](media/index-123_3.jpg)

*z* *z*

![](media/index-123_4.jpg)

(a) Before (b) After

![](media/index-123_5.jpg)

Figure 10.3: When a new vertex v is moved from V X to X, edges going out of v can become crossing edges.

![](media/index-123_6.jpg)

 

Every time we extract a vertex ⇤ w from the heap, moving it from V X to X, we might need to decrease the key of some of the vertices remaining in V X to reflect the new crossing edges. Because all the new crossing edges emanate from ⇤ w, we need only iterate through ⇤ w’s list of outgoing edges and check the vertices y 2 V X with an edge ⇤ ( w, y). For each such vertex y, there are two candidates for the first-round winner in y’s local tournament: either it is the same as before, or it is the new entrant ⇤ ( w, y). Thus, the new value of y’s key should be either its old value or the Dijkstra score ⇤ len ( w) + \` ⇤ wy of the new crossing edge, whichever is smaller.

![](media/index-123_7.jpg)

How can we decrease the key of an object in a heap? One easy way

![](media/index-123_8.jpg)

is to remove it, using the Delete operation described in Section 10.2.2,

![](media/index-123_9.jpg)

update its key, and use Insert 15 to add it back into the heap. This

![](media/index-123_10.jpg)

15 Some heap implementations export a DecreaseKey operation, running in 10.4 Speeding Up Dijkstra’s Algorithm 111

![](media/index-123_11.jpg)

![](media/index-123_12.jpg)

![](media/index-123_13.jpg)

![](media/index-123_14.jpg)

![](media/index-123_15.jpg)

![](media/index-123_16.jpg)

![](media/index-123_17.jpg)

![](media/index-123_18.jpg)

![](media/index-123_19.jpg)

![](media/index-123_20.jpg)

![](media/index-123_21.jpg)

![](media/index-123_22.jpg)

![](media/index-123_23.jpg)

![](media/index-123_24.jpg)

 

completes the heap-based implementation of the Dijkstra algorithm.

 

Dijkstra (Heap-Based, Part 2)

// update heap to maintain invariant

12 for every edge ⇤ ( w, y) do 13 Delete y from H 14 ⇤ key ( y ) := min { key ( y ) , len ( w) + \` ⇤ wy } 15 Insert y into H

 

10.4.4 Running Time

Almost all the work performed by the heap-based implementation of Dijkstra consists of heap operations (as you should check). Each of these operations takes O(log n) time, where n is the number of vertices. (The heap never contains more than n 1 objects.)

How many heap operations does the algorithm perform? There

are n 1 operations in each of lines 6 and 8—one per vertex other than the starting vertex s. What about in lines 13 and 15?

Quiz 10.2

How many times does Dijkstra execute lines 13 and 15? Select the smallest bound that applies. (As usual, n and m denote the number of vertices and edges, respectively.)

a\) O(n)

b\) O(m)

c\) 2 O ( n)

d\) O(mn)

(See below for the solution and discussion.)

 

O(log n) time for an n-object heap. In this case, only one heap operation is needed. 112 The Heap Data Structure

 

Correct answer: (b). Lines 13 and 15 may look a little scary. In one iteration of the main loop, these two lines might be performed as many as n 1 times—once per outgoing edge of ⇤ w. There are n 1 iterations, which seems to lead to a quadratic number of heap operations. This bound is accurate for dense graphs, but in general, we can do better. The reason? Let’s assign responsibility for these heap operations to edges rather than vertices. Each edge (v, w) of the graph makes at most one appearance in line 12—when v is first extracted from

the heap and moved from 16 V X to X . Thus, lines 13 and 15 are each performed at most once per edge, for a total of 2m operations, where m is the number of edges.

Quiz 10.2 shows that the heap-based implementation of Dijkstra uses O(m+ n) heap operations, each taking O(log n) time. The overall

running time is O((m+ n) log n), as promised by Theorem 10.4. QE D

 

\*10.5 Implementation Details

Let’s take your understanding of heaps to the next level by describing how you would implement one from scratch. We’ll focus on the two basic operations—Insert and ExtractMin—and how to ensure that both run in logarithmic time.

 

10.5.1 Heaps as Trees

There are two ways to visualize objects in a heap, as a tree (better for pictures and exposition) or as an array (better for an implementation). Let’s start with trees.

A heap can be viewed as a rooted binary tree—where each node has 0, 1, or 2 children—in which every level is as full as possible. When the number of objects stored is one less than a power of 2,

every level is full (Figures 10.4(a) and 10.4(b)). When the number of objects is between two such numbers, the only non-full layer is the

last one, which is populated from left to right (Figure 10.4(c)).17

A heap manages objects associated with keys so that the following heap property holds.

16 If w is extracted before v, the edge (v, w) never makes an appearance.

17 For some reason, computer scientists seem to think that trees grow downward. \*10.5 Implementation Details 113

![](media/index-126_1.jpg)

 

(a) (b) (c)

![](media/index-126_2.jpg)

Figure 10.4: Full binary trees with 7, 15, and 9 nodes.

![](media/index-126_3.jpg)

 

The Heap Property

![](media/index-126_4.jpg)

For every object x, the key of x is less than or equal to the keys of its children.

![](media/index-126_5.jpg)

 

Duplicate keys are allowed. For example, here’s a valid heap containing

![](media/index-126_6.jpg)

nine objects:18

![](media/index-126_7.jpg)

4

![](media/index-126_8.jpg)

 

4 8

![](media/index-126_9.jpg)

 

9 4 12 9

![](media/index-126_10.jpg)

 

11 13

![](media/index-126_11.jpg)

 

For every parent-child pair, the parent’s key is at most that of the

![](media/index-126_12.jpg)

child.19

![](media/index-126_13.jpg)

There’s more than one way to arrange objects so that the heap

![](media/index-126_14.jpg)

property holds. Here’s another heap, with the same set of keys:

![](media/index-126_15.jpg)

18 When we draw a heap, we show only the objects’ keys. Don’t forget that what a heap really stores is objects (or pointers to objects). Each object is associated with a key and possibly lots of other data.

![](media/index-126_16.jpg)

19 Applying the heap property iteratively to an object’s children, its children’s children, and so on shows that the key of each object is less than or equal to those of all of its direct descendants. The example above illustrates that the heap property implies nothing about the relative order of keys in different subtrees—just like in real family trees!

![](media/index-126_17.jpg)

![](media/index-126_18.jpg)

![](media/index-126_19.jpg)

![](media/index-126_20.jpg)

![](media/index-126_21.jpg)

![](media/index-126_22.jpg)

![](media/index-126_23.jpg)

![](media/index-126_24.jpg)

![](media/index-126_25.jpg)

![](media/index-126_26.jpg)

![](media/index-126_27.jpg)

![](media/index-126_28.jpg)

![](media/index-126_29.jpg)

![](media/index-126_30.jpg)

![](media/index-126_31.jpg)

![](media/index-126_32.jpg)

![](media/index-126_33.jpg)

![](media/index-126_34.jpg)

![](media/index-126_35.jpg)

![](media/index-126_36.jpg)

![](media/index-126_37.jpg)

![](media/index-126_38.jpg)

![](media/index-126_39.jpg)

![](media/index-126_40.jpg)

![](media/index-126_41.jpg)

![](media/index-126_42.jpg)

![](media/index-126_43.jpg)

![](media/index-126_44.jpg)

![](media/index-126_45.jpg)

![](media/index-126_46.jpg)

![](media/index-126_47.jpg)

![](media/index-126_48.jpg)

![](media/index-126_49.jpg)

![](media/index-126_50.jpg)

![](media/index-126_51.jpg)

![](media/index-126_52.jpg)

![](media/index-126_53.jpg)

![](media/index-126_54.jpg)

![](media/index-126_55.jpg)

![](media/index-126_56.jpg)

![](media/index-126_57.jpg)

![](media/index-126_58.jpg)

![](media/index-126_59.jpg)

![](media/index-126_60.jpg)

![](media/index-126_61.jpg)

![](media/index-126_62.jpg)

![](media/index-126_63.jpg)

![](media/index-126_64.jpg)

![](media/index-126_65.jpg)

![](media/index-126_66.jpg)

![](media/index-126_67.jpg)

![](media/index-126_68.jpg)

![](media/index-126_69.jpg)

![](media/index-126_70.jpg)

![](media/index-126_71.jpg)

![](media/index-126_72.jpg)

![](media/index-126_73.jpg)

![](media/index-126_74.jpg)

![](media/index-126_75.jpg)

![](media/index-126_76.jpg)

114 The Heap Data Structure

 

4

![](media/index-127_1.jpg)

 

4 4

![](media/index-127_2.jpg)

 

9 11 13 8

![](media/index-127_3.jpg)

 

12 9

![](media/index-127_4.jpg)

 

Both heaps have a “4” at the root, which is also (tied for) the smallest of all the keys. This is not an accident: because keys only decrease as you traverse a heap upward, the root’s key is as small as it gets. This should sound encouraging, given that the raison d’être of a heap is fast minimum computations.

![](media/index-127_5.jpg)

10.5.2 Heaps as Arrays

![](media/index-127_6.jpg)

In our minds we visualize a heap as a tree, but in an implementation we use an array with length equal to the maximum number of objects we expect to store. The first element of the array corresponds to the tree’s root, the next two elements to the next level of the tree (in the

![](media/index-127_7.jpg)

same order), and so on (Figure 10.5).

![](media/index-127_8.jpg)

4 layer 0

![](media/index-127_9.jpg)

4 8 layer 1

![](media/index-127_10.jpg)

layer 2

![](media/index-127_11.jpg)

9 4 12 9

![](media/index-127_12.jpg)

4 4 8 9 4 12 9 11 13

![](media/index-127_13.jpg)

11 layer 0 layer 1 13 layer 3 layer 2 layer 3

![](media/index-127_14.jpg)

(a) Tree representation (b) Array representation

![](media/index-127_15.jpg)

Figure 10.5: Mapping the tree representation of a heap to its array representation.

![](media/index-127_16.jpg)

 

Parent-child relationships in the tree translate nicely to the array

![](media/index-127_17.jpg)

(Table 10.2). Assuming the array positions are labeled 1, 2, . . . , n, where n is the number of objects, the children of the object in position i \*10.5 Implementation Details 115

![](media/index-127_18.jpg)

![](media/index-127_19.jpg)

![](media/index-127_20.jpg)

![](media/index-127_21.jpg)

![](media/index-127_22.jpg)

![](media/index-127_23.jpg)

![](media/index-127_24.jpg)

![](media/index-127_25.jpg)

![](media/index-127_26.jpg)

![](media/index-127_27.jpg)

![](media/index-127_28.jpg)

![](media/index-127_29.jpg)

![](media/index-127_30.jpg)

![](media/index-127_31.jpg)

![](media/index-127_32.jpg)

![](media/index-127_33.jpg)

![](media/index-127_34.jpg)

![](media/index-127_35.jpg)

![](media/index-127_36.jpg)

![](media/index-127_37.jpg)

![](media/index-127_38.jpg)

![](media/index-127_39.jpg)

![](media/index-127_40.jpg)

![](media/index-127_41.jpg)

![](media/index-127_42.jpg)

 

correspond to the objects in positions 2i and 2i + 1 (if any). For

example, in Figure 10.5, the children of the root (in position 1) are the next two objects (in positions 2 and 3), the children of the 8 (in position 3) are the objects in positions 6 and 7, and so on. Going in reverse, for a non-root object (in position i 2), i’s parent is the

object in position 20 b i/ 2 c . For example, in Figure 10.5, the parent of the last object (in position 9) is the object in position b9/2c = 4.

Position of parent bi/2c (provided i 2) Position of left child 2i (provided 2i  n) Position of right child 2i + 1 (provided 2i + 1  n)

Table 10.2: Relationships between the position i 2 {1, 2, 3, . . . , n} of an object in a heap and the positions of its parent, left child, and right child, where n denotes the number of objects in the heap.

 

There are such simple formulas to go from a child to its parent

and back because we use only full binary trees.21 There is no need to explicitly store the tree; consequently, the heap data structure has

minimal space overhead.22

10.5.3 Implementing Insert in O(log n) Time

We’ll illustrate the implementation of both the Insert and Extract-

Min 23 operations by example rather than by pseudocode. The chal-lenge is to both keep the tree full and maintain the heap property after an object is added or removed. We’ll follow the same blueprint for both operations:

1\. Keep the tree full in the most obvious way possible.

2\. Play whack-a-mole to systematically squash any violations of

the heap property.

20 The notation bxc denotes the “floor” function, which rounds its argument down to the nearest integer.

21 As a bonus, in low-level languages it’s possible to multiply or divide by 2 ridiculously quickly, using bit-shifting tricks.

22 By contrast, search trees (Chapter 11) need not be full; they require additional

space to store explicit pointers from each node to its children. 23 We’ll keep drawing heaps as trees, but don’t forget that they’re stored as arrays. When we talk about going from a node to a child or its parent, we mean

by applying the simple index formulas in Table 10.2.

116 The Heap Data Structure

 

Specifically, recall the Insert operation:

given a heap H and a new object x, add x to H.

After x’s addition to H, H should still correspond to a full binary tree (with one more node than before) that satisfies the heap property. The operation should take O(log n) time, where n is the number of objects in the heap.

Let’s start with our running example:

4

![](media/index-129_1.jpg)

 

4 8

![](media/index-129_2.jpg)

 

9 4 12 9

![](media/index-129_3.jpg)

 

11 13

![](media/index-129_4.jpg)

 

When a new object is inserted, the most obvious way to keep the tree full is to tack the new object onto the end of the array, or equivalently to the last level of the tree. (If the last level is already full, the object becomes the first at a new level.) As long as the implementation keeps track of the number n of objects (which is easy to do), this step takes constant time. For example, if we insert an object with key 7 into our running example, we obtain:

![](media/index-129_5.jpg)

4

![](media/index-129_6.jpg)

 

4 8

![](media/index-129_7.jpg)

 

9 4 12 9

![](media/index-129_8.jpg)

 

11 13 7

![](media/index-129_9.jpg)

 

We have a full binary tree, but does the heap property hold? There’s only one place it might fail—the one new parent-child pair (the 4 and \*10.5 Implementation Details 117

![](media/index-129_10.jpg)

![](media/index-129_11.jpg)

![](media/index-129_12.jpg)

![](media/index-129_13.jpg)

![](media/index-129_14.jpg)

![](media/index-129_15.jpg)

![](media/index-129_16.jpg)

![](media/index-129_17.jpg)

![](media/index-129_18.jpg)

![](media/index-129_19.jpg)

![](media/index-129_20.jpg)

![](media/index-129_21.jpg)

![](media/index-129_22.jpg)

![](media/index-129_23.jpg)

![](media/index-129_24.jpg)

![](media/index-129_25.jpg)

![](media/index-129_26.jpg)

![](media/index-129_27.jpg)

![](media/index-129_28.jpg)

![](media/index-129_29.jpg)

![](media/index-129_30.jpg)

![](media/index-129_31.jpg)

![](media/index-129_32.jpg)

![](media/index-129_33.jpg)

![](media/index-129_34.jpg)

![](media/index-129_35.jpg)

![](media/index-129_36.jpg)

 

the 7). In this case we got lucky, and the new pair doesn’t violate the heap property. If our next insertion is an object with key 10, then again we get lucky and immediately obtain a valid heap:

4

![](media/index-130_1.jpg)

 

4 8

![](media/index-130_2.jpg)

 

9 4 12 9

![](media/index-130_3.jpg)

 

11 13 7 10

![](media/index-130_4.jpg)

But suppose we now insert an object with key 5. After tacking it on at the end, our tree is:

![](media/index-130_5.jpg)

4

![](media/index-130_6.jpg)

 

4 8

![](media/index-130_7.jpg)

 

9 4 12 9

![](media/index-130_8.jpg)

heap

![](media/index-130_9.jpg)

violation!

![](media/index-130_10.jpg)

11 13 7 10 5

![](media/index-130_11.jpg)

Now we have a problem: The new parent-child pair (the 12 and the 5) violates the heap property. What can we do about it? We can at least fix the problem locally by swapping the two nodes in the violating pair:

![](media/index-130_12.jpg)

4

![](media/index-130_13.jpg)

 

4 8

![](media/index-130_14.jpg)

heap

![](media/index-130_15.jpg)

violation!

![](media/index-130_16.jpg)

9 4 5 9

![](media/index-130_17.jpg)

 

11 13 7 10 12 118 The Heap Data Structure

![](media/index-130_18.jpg)

![](media/index-130_19.jpg)

![](media/index-130_20.jpg)

![](media/index-130_21.jpg)

![](media/index-130_22.jpg)

![](media/index-130_23.jpg)

![](media/index-130_24.jpg)

![](media/index-130_25.jpg)

![](media/index-130_26.jpg)

![](media/index-130_27.jpg)

![](media/index-130_28.jpg)

![](media/index-130_29.jpg)

![](media/index-130_30.jpg)

![](media/index-130_31.jpg)

![](media/index-130_32.jpg)

![](media/index-130_33.jpg)

![](media/index-130_34.jpg)

![](media/index-130_35.jpg)

![](media/index-130_36.jpg)

![](media/index-130_37.jpg)

![](media/index-130_38.jpg)

![](media/index-130_39.jpg)

![](media/index-130_40.jpg)

![](media/index-130_41.jpg)

![](media/index-130_42.jpg)

![](media/index-130_43.jpg)

![](media/index-130_44.jpg)

![](media/index-130_45.jpg)

![](media/index-130_46.jpg)

![](media/index-130_47.jpg)

![](media/index-130_48.jpg)

![](media/index-130_49.jpg)

![](media/index-130_50.jpg)

![](media/index-130_51.jpg)

![](media/index-130_52.jpg)

![](media/index-130_53.jpg)

![](media/index-130_54.jpg)

![](media/index-130_55.jpg)

![](media/index-130_56.jpg)

![](media/index-130_57.jpg)

![](media/index-130_58.jpg)

![](media/index-130_59.jpg)

![](media/index-130_60.jpg)

![](media/index-130_61.jpg)

![](media/index-130_62.jpg)

![](media/index-130_63.jpg)

![](media/index-130_64.jpg)

![](media/index-130_65.jpg)

![](media/index-130_66.jpg)

![](media/index-130_67.jpg)

![](media/index-130_68.jpg)

![](media/index-130_69.jpg)

 

This fixes the violating parent-child pair. We’re not out of the woods yet, however, as the heap violation has migrated upward to the 8 and the 5. So we do it again, and swap the nodes in the violating pair to obtain:

 

4

![](media/index-131_1.jpg)

 

4 5

![](media/index-131_2.jpg)

 

9 4 8 9

![](media/index-131_3.jpg)

 

11 13 7 10 12

![](media/index-131_4.jpg)

 

This explicitly fixes the violating pair. We’ve seen that such a swap has the potential to push the violation of the heap property upward, but here it doesn’t happen—the 4 and 5 are already in the correct order. You might worry that a swap could also push the violation downward. But this also doesn’t happen—the 8 and 12 are already in the correct order. With the heap property restored, the insertion is complete.

![](media/index-131_5.jpg)

In general, the Insert operation tacks the new object on to the

![](media/index-131_6.jpg)

end of the heap, and repeatedly swaps the nodes of a violating pair.24 At all times, there is at most one violating parent-child pair—the pair

![](media/index-131_7.jpg)

in which the new object is the child.25 Each swap pushes the violating parent-child pair up one level in the tree. This process cannot go on forever—if the new object makes it to the root, it has no parent and there can be no violating parent-child pair.

![](media/index-131_8.jpg)

24 This swapping subroutine goes by a number of names, including Bubble-Up,

![](media/index-131_9.jpg)

Sift-Up, Heapify-Up, and more. 25 At no point are there any heap violations between the new object and its children. It has no children initially, and after a swap its children comprise the node it replaced (which has a larger key, as otherwise we wouldn’t have swapped) and a previous child of that node (which, by the heap property, can have only a still larger key). Every parent-child pair not involving the new object appeared in the original heap, and hence does not violate the heap property. For instance, after two swaps in our example, the 8 and 12 are once again in a parent-child relationship, just like in the original heap.

![](media/index-131_10.jpg)

![](media/index-131_11.jpg)

![](media/index-131_12.jpg)

![](media/index-131_13.jpg)

![](media/index-131_14.jpg)

![](media/index-131_15.jpg)

![](media/index-131_16.jpg)

![](media/index-131_17.jpg)

![](media/index-131_18.jpg)

![](media/index-131_19.jpg)

![](media/index-131_20.jpg)

![](media/index-131_21.jpg)

![](media/index-131_22.jpg)

![](media/index-131_23.jpg)

\*10.5 Implementation Details 119

 

Insert

1\. Stick the new object at the end of the heap and incre-

ment the heap size.

2\. Repeatedly swap the new object with its parent until

the heap property is restored.

 

Because a heap is a full binary tree, it has ⇡ log n 2 levels, where n is the number of objects in the heap. The number of swaps is at most the number of levels, and only a constant amount of work is required per swap. We conclude that the worst-case running time of the Insert operation is O(log n), as desired.

 

10.5.4 Implementing ExtractMin in O(log n) Time

Recall the ExtractMin operation:

given a heap H, remove and return from H an object with the smallest key.

The root of the heap is guaranteed to be such an object. The challenge is to restore the full binary tree and heap properties after ripping out a heap’s root.

We again keep the tree full in the most obvious way possible. Like

Insert in reverse, we know that the last node of the tree must go elsewhere. But where should it go? Because we’re extracting the root anyway, let’s overwrite the old root node with what used to be the last node. For example, starting from the heap

4

![](media/index-132_1.jpg)

 

4 8

![](media/index-132_2.jpg)

 

9 4 12 9

![](media/index-132_3.jpg)

 

11 13

![](media/index-132_4.jpg)

![](media/index-132_5.jpg)

![](media/index-132_6.jpg)

![](media/index-132_7.jpg)

![](media/index-132_8.jpg)

![](media/index-132_9.jpg)

![](media/index-132_10.jpg)

![](media/index-132_11.jpg)

![](media/index-132_12.jpg)

![](media/index-132_13.jpg)

![](media/index-132_14.jpg)

![](media/index-132_15.jpg)

![](media/index-132_16.jpg)

![](media/index-132_17.jpg)

120 The Heap Data Structure

 

the resulting tree looks like

13

![](media/index-133_1.jpg)

heap

![](media/index-133_2.jpg)

4 violations! 8

![](media/index-133_3.jpg)

 

9 4 12 9

![](media/index-133_4.jpg)

 

11

![](media/index-133_5.jpg)

 

The good news is that we’ve restored the full binary tree property. The bad news is that the massive promotion granted to the object with key 13 has created two violating parent-child pairs (the 13 and 4 and the 13 and 8). Do we need two swaps to correct them?

![](media/index-133_6.jpg)

The key idea is to swap the root node with the smaller of its two children:

![](media/index-133_7.jpg)

4

![](media/index-133_8.jpg)

 

13 8

![](media/index-133_9.jpg)

heap

![](media/index-133_10.jpg)

9 violations! 4 12 9

![](media/index-133_11.jpg)

 

11

![](media/index-133_12.jpg)

 

There are no longer any heap violations involving the root—the new root node is smaller than both the node it replaced (that’s why we

![](media/index-133_13.jpg)

swapped) and its other child (as we swapped the smaller child).26 The heap violations migrate downward, again involving the object with key 13 and its two (new) children. So we do it again, and swap the 13 with its smaller child:

![](media/index-133_14.jpg)

26 Swapping the 13 with the 8 would fail to vaccinate the left subtree from heap

![](media/index-133_15.jpg)

violations (with violating pair 8 and 4) while allowing the disease to spread to the right subtree (with violating pairs 13 and 12, and 13 and 9).

![](media/index-133_16.jpg)

![](media/index-133_17.jpg)

![](media/index-133_18.jpg)

![](media/index-133_19.jpg)

![](media/index-133_20.jpg)

![](media/index-133_21.jpg)

![](media/index-133_22.jpg)

![](media/index-133_23.jpg)

![](media/index-133_24.jpg)

![](media/index-133_25.jpg)

![](media/index-133_26.jpg)

![](media/index-133_27.jpg)

![](media/index-133_28.jpg)

![](media/index-133_29.jpg)

![](media/index-133_30.jpg)

![](media/index-133_31.jpg)

![](media/index-133_32.jpg)

![](media/index-133_33.jpg)

![](media/index-133_34.jpg)

\*10.5 Implementation Details 121

 

4

![](media/index-134_1.jpg)

 

4 8

![](media/index-134_2.jpg)

 

9 13 12 9

![](media/index-134_3.jpg)

 

11

![](media/index-134_4.jpg)

 

The heap property is restored at last, and now the extraction is complete.

![](media/index-134_5.jpg)

In general, the ExtractMin operation moves the last object

![](media/index-134_6.jpg)

of a heap to the root node (by overwriting the previous root), and

![](media/index-134_7.jpg)

repeatedly swaps this object with its smaller child.27 At all times, there are at most two violating parent-child pairs—the two pairs in

![](media/index-134_8.jpg)

which the formerly-last object is the parent.28 Because each swap pushes this object down one level in the tree, this process cannot go on forever—it stops once the new object belongs to the last level, if not earlier.

![](media/index-134_9.jpg)

ExtractMin

![](media/index-134_10.jpg)

1\. Overwrite the root with the last object x in the heap,

![](media/index-134_11.jpg)

and decrement the heap size.

![](media/index-134_12.jpg)

2\. Repeatedly swap x with its smaller child until the

![](media/index-134_13.jpg)

heap property is restored.

![](media/index-134_14.jpg)

 

The number of swaps is at most the number of levels, and only a constant amount of work is required per swap. Because there are ⇡ log n 2 levels, we conclude that the worst-case running time of the ExtractMin operation is O(log n), where n is the number of objects in the heap.

![](media/index-134_15.jpg)

27 This swapping subroutine is called, among other things, Bubble-Down.

28 Every parent-child pair not involving this formerly-last object appeared in the original heap, and hence does not violate the heap property. There is also no violation involving this object and its parent—initially it had no parent, and subsequently it is swapped downward with objects that have smaller keys.

122 The Heap Data Structure

 

The Upshot

P There are many different data structures, each

optimized for a different set of operations.

P The principle of parsimony recommends choos-

ing the simplest data structure that supports

all the operations required by your application.

P If your application requires fast minimum (or

maximum) computations on an evolving set of

objects, the heap is usually the data structure

of choice.

P The two most important heap operations, In-

sert and ExtractMin, run in O(log n) time, where n is the number of objects.

P Heaps also support FindMin in O(1) time,

Delete in O(log n) time, and Heapify in O(n) time.

P The HeapSort algorithm uses a heap to sort a

length-n array in O(n log n) time.

P Heaps can be used to implement Dijkstra’s

shortest-path algorithm in O((m + n) log n) time, where m and n denote the number of edges and vertices of the graph, respectively.

P Heaps can be visualized as full binary trees but

are implemented as arrays.

P The heap property states that the key of every

object is less than or equal to the keys of its

children.

P The Insert and ExtractMin operations are

implemented by keeping the tree full in the Problems 123

 

most obvious way possible and systematically

squashing any violations of the heap property.

 

Test Your Understanding

Problem 10.1 (S) Which of the following patterns in a computer program suggests that a heap data structure could provide a significant speed-up? (Check all that apply.)

a\) Repeated lookups.

b\) Repeated minimum computations.

c\) Repeated maximum computations.

d\) None of the other options.

Problem 10.2 Suppose you implement the functionality of a priority queue (that is, Insert and ExtractMin) using an array sorted from largest to smallest. What is the worst-case running time of Insert and ExtractMin, respectively? Assume you have a large enough array to accommodate all your insertions.

a\) ⇥(1) and ⇥(n)

b\) ⇥(n) and ⇥(1)

c\) ⇥(log n) and ⇥(1)

d\) ⇥(n) and ⇥(n)

Problem 10.3 Suppose you implement the functionality of a priority queue (that is, Insert and ExtractMin) using an unsorted array. What is the worst-case running time of Insert and ExtractMin, respectively? Assume you have a large enough array to accommodate all your insertions.

a\) ⇥(1) and ⇥(n)

b\) ⇥(n) and ⇥(1)

c\) ⇥(1) and ⇥(log n)

124 The Heap Data Structure

 

d\) ⇥(n) and ⇥(n)

 

Problem 10.4 (S) You are given a heap with n objects. Which of the following tasks can you solve using O(1) Insert and ExtractMin operations and O(1) additional work? (Choose all that apply.)

 

a\) Find the object stored in the heap with the fifth-smallest key.

b\) Find the object stored in the heap with the maximum key.

c\) Find the object stored in the heap with the median key.

d\) None of the above.

 

Challenge Problems

Problem 10.5 (S) Continuing Problem 9.7, show how to modify the heap-based implementation of Dijkstra’s algorithm to compute, for each vertex v 2 V , the smallest bottleneck of an s-v path. Your algorithm should run in O((m + n) log n) time, where m and n denote the number of edges and vertices, respectively.

 

Problem 10.6 (Difficult.) We can do better. Suppose now the graph is undirected. Give a linear-time (that is, O(m + n)-time) algorithm to compute a minimum-bottleneck path between two given vertices.

\[Hint: A linear-time algorithm from Part 1 will come in handy. In the recursion, aim to cut the input size in half in linear time.\]

 

Problem 10.7 (Difficult.) What if the graph is directed? Can you compute a minimum-bottleneck path between two given vertices in

less than 29 O (( m + n ) log n ) time?

 

29 For a deep dive on this problem, see the paper “Algorithms for Two Bottleneck

Optimization Problems,” by Harold N. Gabow and Robert E. Tarjan (Journal of Algorithms, 1988).

Problems 125

 

Programming Problems

Problem 10.8 Implement in your favorite programming language

the heap-based version of the Dijkstra algorithm from Section 10.4, and use it to solve the single-source shortest path problem in different directed graphs. With this heap-based implementation, what’s the size of the largest problem you can solve in five minutes or less? (See

[www.algorithmsilluminated.org](http://www.algorithmsilluminated.org) for test cases and challenge data sets.)

\Hint: This requires the Delete operation, which may force you to implement a customized heap data structure from scratch. To delete an object from a heap at a given position, follow the high-level approach of Insert and ExtractMin, using Bubble-Up or Bubble-Down as needed to squash violations of the heap property. You will also need to keep track of which vertex is in which position

of your heap, perhaps by using a hash table (Chapter [12).\]