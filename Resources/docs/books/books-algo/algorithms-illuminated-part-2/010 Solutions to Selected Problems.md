## Solutions to Selected Problems

 

Problem 7.1: Conditions (a) and (c) are satisfied by some sparse graphs (such as a star graph) and some dense graphs (such as a complete graph with one extra edge glued on). Condition (b) is satisfied only by sparse graphs, and condition (d) only by dense graphs.

Problem 7.2: (c) . Scan through the row corresponding to v in the adjacency matrix.

Problem 8.1: All four statements hold: (a) by the UCC algorithm in

Section 8.3; (b) by the Augmented-BFS algorithm in Section 8.2; (c)

by the Kosaraju algorithm in Section 8.6; and (d) by the TopoSort

algorithm in Section 8.5.

Problem 8.2: (c) . 2 ⌦ ( n) time is required because, in the worst case, a correct algorithm must look at each of the 2 n entries of the adjacency matrix at least once. 2 O ( n) time is achievable, for example by constructing the adjacency list representation of the input graph with a single pass over the adjacency matrix (in 2 O ( n) time) and then running DFS with the new representation in 2 O ( m + n ) = O ( n) time.

Problem 8.7: (c) . Computing the “magical ordering” in the first pass of the Kosaraju algorithm requires depth-first search. (See the proof

of Theorem 8.10.) In the second pass, given the magical ordering of the vertices, any instantiation of the GenericSearch algorithm (including BFS) will successfully discover the SCCs in reverse topological order.

Problem 8.8: (a),(b) . The modification in (a) does not change the order in which the algorithm considers vertices in its second pass, and so it remains correct. The modification in (b) is equivalent to running the Kosaraju algorithm on the reversal of the input graph. Because

a graph and its reversal have exactly the same SCCs (Quiz 8.6),

200

Solutions to Selected Problems 201

 

the algorithm remains correct. The modifications in (c) and (d) are equivalent, as in the argument for (a) above, and do not result in a correct algorithm. For a counterexample, revisit our running example

(and especially the discussion on page 59).

Problem 9.2: (b). Two sums of distinct powers of 2 cannot be the same. (Imagine the numbers are written in binary.) For (a) and (c), there are counterexamples with three vertices and three edges.

Problem 9.3: (c),(d) . Statement (d) holds because, when P has only one edge, every path goes up in length by at least as much as P does. This also shows that (b) is false. An example similar to the one

in Section 9.3.1 shows that (a) is false, and it follows that (c) is true.

Problem 9.7: In lines 4 and 6 of the Dijkstra algorithm (page 80), respectively, replace ⇤ len ( v ) + \` vw with max { len ( v ) , \` vw } and len ( v) +

\` ⇤ v ⇤ w ⇤ with max { len ( v), \`v⇤w⇤}.

Problem 10.1: (b),(c). The raison d’être of a heap is to support

fast minimum computations, with HeapSort (Section 10.3.1) being a canonical application. Negating the key of every object turns a heap into a data structure that supports fast maximum computations. Heaps do not generally support fast lookups unless you happen to be looking for the object with the minimum key.

Problem 10.4: (a) . Only the object with the smallest key can be extracted with one heap operation. Calling ExtractMin five successive times returns the object in the heap with the fifth-smallest key. Extracting the object with the median or maximum key would require a linear number of heap operations.

Problem 10.5: In line 14 of the heap-based implementation of

Dijkstra (page 111), replace len ⇤ ⇤ ( w )+ \` ⇤ w y with max { len ( w), \` ⇤ wy }.

Problem 11.1: (a). Statement (a) holds because there are at most i 2 nodes in the ith level of a binary tree, and hence at most 1 + 2 + 4 + · i i+1 + 2  2 nodes in levels 0 through i combined. Accommodating n nodes requires h+1 2 n, where h is the tree height, so h = ⌦(log n). Statement (b) holds for balanced binary search trees but is generally

false for unbalanced binary search trees (see footnote 4 in Chapter 11). 202 Solutions to Selected Problems

 

Statement (c) is false because the heap and search tree properties are

incomparable (see page 132). Statement (d) is false, as a sorted array is preferable to a balanced binary search tree when the set of objects

to be stored is static, with no insertions or deletions (see page 131).

Problem 12.1: (a) . Pathological data sets show that property (a) is

impossible and so cannot be expected (see Section 12.3.6). The other three properties are satisfied by state-of-the-art hash functions.

Problem 12.2: (b) . There are n possibilities for k1’s location and n possibilities for 2 k 2 ’s location, for a total of n outcomes. Of these, k1 and k2 collide in exactly n of them—the outcome in which both are assigned the first position, the outcome in which both are assigned the second position, and so on. Because every outcome is equally likely (with probability 1 1 1 2 each), the probability of a collision is n · 2 = . n n n