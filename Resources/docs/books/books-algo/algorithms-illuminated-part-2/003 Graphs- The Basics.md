## Chapter 7

 

Graphs: The Basics

 

This short chapter explains what graphs are, what they are good for, and the most common ways to represent them in a computer program. The next two chapters cover a number of famous and useful algorithms for reasoning about graphs.

 

7.1 Some Vocabulary

When you hear the word “graph,” you probably think about an x-axis,

a y-axis, and so on (Figure 7.1(a)). To an algorithms person, a graph can also mean a representation of the relationships between pairs of

objects (Figure 7.1(b)).

40

f(n)=n

f(n)=log n

35

30

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-14_1.jpg)

25

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-14_2.jpg)

f(n) 20

15

10

5

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-14_3.jpg)

0

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-14_4.jpg)

0 5 10 15 20 25 30 35 40

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-14_5.jpg)

n

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-14_6.jpg)

(a) A graph (to most of the world) (b) A graph (in algorithms)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-14_7.jpg)

Figure 7.1: In algorithms, a graph is a representation of a set of objects (such as people) and the pairwise relationships between them (such as friendships).

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-14_8.jpg)

 

The second type of graph has two ingredients—the objects being

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-14_9.jpg)

represented, and their pairwise relationships. The former are called

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-14_10.jpg)

1

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-14_11.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-14_12.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-14_13.jpg)

2 Graphs: The Basics

 

the 1 vertices (singular: vertex) or the nodes of the graph. The pairwise relationships translate to the edges of the graph. We usually denote the vertex and edge sets of a graph by V and E, respectively, and sometimes write G = (V, E) to mean the graph G with vertices V and edges E.

There are two flavors of graphs, directed and undirected. Both types are important and ubiquitous in applications, so you should know about both of them. In an undirected graph, each edge corresponds to an unordered pair {v, w} of vertices, which are called the endpoints of

the edge (Figure 7.2(a)). In an undirected graph, there is no difference between an edge (v, w) and an edge (w, v). In a directed graph, each edge (v, w) is an ordered pair, with the edge traveling from the first

vertex v 2 (called the tail ) to the second w (the head ); see Figure 7.2(b).

 

*v* *v*

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-15_1.jpg)

 

*s* *s* *t* *t*

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-15_2.jpg)

 

*w* *w*

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-15_3.jpg)

(a) An undirected graph (b) A directed graph

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-15_4.jpg)

Figure 7.2: Graphs with four vertices and five edges. The edges of undirected and directed graphs are unordered and ordered vertex pairs, respectively.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-15_5.jpg)

 

7.2 A Few Applications

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-15_6.jpg)

Graphs are a fundamental concept, and they show up all the time in computer science, biology, sociology, economics, and so on. Here are a few of the countless examples.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-15_7.jpg)

1 Having two names for the same thing can be annoying, but both terms are in widespread use and you should be familiar with them. For the most part, we’ll stick with “vertices” throughout this book series.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-15_8.jpg)

2 Directed edges are sometimes called arcs, but we won’t use this terminology in this book series.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-15_9.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-15_10.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-15_11.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-15_12.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-15_13.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-15_14.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-15_15.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-15_16.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-15_17.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-15_18.jpg)

7.3 Measuring the Size of a Graph 3

 

Road networks. When your smartphone’s software computes driv-ing directions, it searches through a graph that represents the road network, with vertices corresponding to intersections and edges corre-sponding to individual road segments.

The World Wide Web. The Web can be modeled as a directed graph, with the vertices corresponding to individual Web pages, and the edges corresponding to hyperlinks, directed from the page con-taining the hyperlink to the destination page.

Social networks. A social network can be represented as a graph whose vertices correspond to individuals and edges to some type of relationship. For example, an edge could indicate a friendship between its endpoints, or that one of its endpoints is a follower of the other. Among the currently popular social networks, which ones are most naturally modeled as an undirected graph, and which ones as a directed graph? (There are interesting examples of both.)

Precedence constraints. Graphs are also useful in problems that lack an obvious network structure. For example, imagine that you have to complete a bunch of tasks, subject to precedence constraints— perhaps you’re a first-year university student, planning which courses to take and in which order. One way to tackle this problem is to

apply the topological sorting algorithm described in Section 8.5 to the following directed graph: there is one vertex for each course that your major requires, with an edge directed from course A to course B whenever A is a prerequisite for B.

 

7.3 Measuring the Size of a Graph

In this book, like in Part 1, we’ll analyze the running time of different algorithms as a function of the input size. When the input is a single array, as for a sorting algorithm, there is an obvious way to define the “input size,” as the array’s length. When the input involves a graph, we must specify exactly how the graph is represented and what we mean by its “size.”

7.3.1 The Number of Edges in a Graph

Two parameters control a graph’s size—the number of vertices and the number of edges. Here is the most common notation for these 4 Graphs: The Basics

 

quantities.

Notation for Graphs

For a graph G = (V, E) with vertex set V and edge set E:

• n = \|V \| denotes the number of vertices.

• m 3 = \| E \| denotes the number of edges.

 

The next quiz asks you to think about how the number m of edges in an undirected graph can depend on the number n of vertices. For this question, we’ll assume that there’s at most one undirected edge between each pair of vertices—no “parallel edges” are allowed. We’ll also assume that the graph is “connected.” We’ll define this concept

formally in Section 8.3; intuitively, it means that the graph is “in one piece,” with no way to break it into two parts without any edges

crossing between the parts. The graphs in Figures 7.1(b) and 7.2(a)

are connected, while the graph in Figure 7.3 is not.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-17_1.jpg)

 

Figure 7.3: An undirected graph that is not connected.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-17_2.jpg)

 

Quiz 7.1

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-17_3.jpg)

Consider an undirected graph with n vertices and no parallel edges. Assume that the graph is connected, meaning “in one piece.” What are the minimum and maximum numbers of edges, respectively, that the graph could have?

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-17_4.jpg)

 

3 For a finite set S, \|S\| denotes the number of elements in S. 7.3 Measuring the Size of a Graph 5

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-17_5.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-17_6.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-17_7.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-17_8.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-17_9.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-17_10.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-17_11.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-17_12.jpg)

 

a\) n(n 1) n 1 and

2

b\) 2 n 1 and n

c\) n and n 2

d\) n n and n

(See Section 7.3.3 for the solution and discussion.)

 

7.3.2 Sparse vs. Dense Graphs

Now that Quiz 7.1 has you thinking about how the number of edges of a graph can vary with the number of vertices, we can discuss the distinction between sparse and dense graphs. The difference is important because some data structures and algorithms are better suited for sparse graphs, and others for dense graphs.

Let’s translate the solution to Quiz 7.1 into asymptotic notation.4

First, if an undirected graph with n vertices is connected, the number

of edges m 5 is at least linear in n (that is, m = ⌦ ( n ) ). Second, if

the graph has no parallel edges, then 2 6 m = O ( n ) . We conclude that the number of edges in a connected undirected graph with no parallel edges is somewhere between linear and quadratic in the number of vertices.

Informally, a graph is sparse if the number of edges is relatively

close to linear in the number of vertices, and dense if this number is closer to quadratic in the number of vertices. For example, graphs with n vertices and O(n log n) edges are usually considered sparse, while those with 2 ⌦ ( n/ log n) edges are considered dense. “Partially dense” graphs, like those with 3/2 ⇡ n edges, may be considered either sparse or dense, depending on the specific application.

 

7.3.3 Solution to Quiz 7.1

Correct answer: (a). In a connected undirected graph with n vertices and no parallel edges, the number m of edges is at least n 1

4 See Appendix C for a review of big-O, big-Omega, and big-Theta notation. 5 If the graph need not be connected, there could be as few as zero edges. 6 If parallel edges are allowed, a graph with at least two vertices can have an

arbitrarily large number of edges.

6 Graphs: The Basics

 

and at most n(n 1)/2. To see why the lower bound is correct, consider a graph G = (V, E). As a thought experiment, imagine building up G one edge at a time, starting from the graph with vertices V and no edges. Initially, before any edges are added, each of the n vertices is completely isolated, so the graph trivially has n distinct “pieces.” Adding an edge (v, w) has the effect of fusing the

piece containing v with the piece containing w (Figure 7.4). Thus,

each edge addition decreases the number of pieces by at most 1.7 To get down to a single piece from n pieces, you need to add at least n 1

edges. There are plenty of connected graphs that have n vertices and

only n 1 edges—these are called trees (Figure 7.5).

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_1.jpg)

 

newly added edge

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_2.jpg)

Figure 7.4: Adding a new edge fuses the pieces containing its endpoints into a single piece. In this example, the number of different pieces drops from three to two.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_3.jpg)

 

(a) A path on four vertices (b) A star on four vertices

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_4.jpg)

Figure 7.5: Two connected undirected graphs with four vertices and three edges.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_5.jpg)

 

The maximum number of edges in a graph with no parallel edges is achieved by the complete graph, with every possible edge present.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_6.jpg)

7 If both endpoints of the edge are already in the same piece, the number of pieces doesn’t decrease at all.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_7.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_8.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_9.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_10.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_11.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_12.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_13.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_14.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_15.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_16.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_17.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_18.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_19.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_20.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_21.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_22.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_23.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_24.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_25.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_26.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_27.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_28.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_29.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_30.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-19_31.jpg)

7.4 Representing a Graph 7

 

Because there are n n( 1) n = pairs of vertices in an n-vertex graph, 2 2 this is also the maximum number of edges. For example, when n = 4,

the maximum number of edges is 4 8 = 6 (Figure 7.6). 2

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-20_1.jpg)

 

Figure 7.6: The complete graph on four vertices has 4 = 6 edges. 2

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-20_2.jpg)

 

7.4 Representing a Graph

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-20_3.jpg)

There is more than one way to encode a graph for use in an algorithm. In this book series, we’ll work primarily with the “adjacency list”

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-20_4.jpg)

representation of a graph (Section 7.4.1), but you should also be

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-20_5.jpg)

aware of the “adjacency matrix” representation (Section 7.4.2).

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-20_6.jpg)

7.4.1 Adjacency Lists

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-20_7.jpg)

The adjacency list representation of graphs is the dominant one that we’ll use in this book series.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-20_8.jpg)

Ingredients for Adjacency Lists

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-20_9.jpg)

1\. An array containing the graph’s vertices.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-20_10.jpg)

2\. An array containing the graph’s edges.

3\. For each edge, a pointer to each of its two endpoints.

4\. For each vertex, a pointer to each of the incident edges.

8 n is pronounced “n choose 2,” and is also sometimes referred to as a

“binomial coe 2fficient.” To see why the number of ways to choose an unordered pair of distinct objects from a set of n(n 1) n objects is , think about choosing the first object (from the 2 n options) and then a second, distinct object (from the n 1

remaining options). The n(n 1) resulting outcomes produce each pair (x, y) of objects twice (once with x first and y second, once with y first and x second), so there must be n(n 1) pairs in all.

2

8 Graphs: The Basics

 

The adjacency list representation boils down to two arrays (or linked lists, if you prefer): one for keeping track of the vertices, and one for the edges. These two arrays cross-reference each other in the natural way, with each edge associated with pointers to its endpoints and each vertex with pointers to the edges for which it is an endpoint.

For a directed graph, each edge keeps track of which endpoint is the tail and which endpoint is the head. Each vertex v maintains two arrays of pointers, one for the outgoing edges (for which v is the tail) and one for the incoming edges (for which v is the head).

What are the memory requirements of the adjacency list represen-tation?

Quiz 7.2

How much space does the adjacency list representation of a graph require, as a function of the number n of vertices and the number m of edges?

a\) ⇥(n)

b\) ⇥(m)

c\) ⇥(m + n)

d\) 2 ⇥ ( n)

(See Section 7.4.4 for the solution and discussion.)

 

7.4.2 The Adjacency Matrix

Consider an undirected graph G = (V, E) with n vertices and no parallel edges, and label its vertices 1, 2, 3, . . . , n. The adjacency matrix representation of G is a square n ⇥ n matrix A—equivalently, a two-dimensional array—with only zeroes and ones as entries. Each entry Aij is defined as

⇢ 1 if edge (i, j) belongs to E

Aij = 0 otherwise.

Thus, an adjacency matrix maintains one bit for each pair of vertices,

which keeps track of whether or not the edge is present (Figure 7.7). 7.4 Representing a Graph 9

 

1 0 1 2 3 41

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-22_1.jpg)

 

2 B C 1 1 0 1 0 0

2 B 0 1 1C 3 B C 0

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-22_2.jpg)

@ 1 0 1A

4 0 1 1 0

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-22_3.jpg)

3 4

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-22_4.jpg)

(a) A graph. . . (b) . . . and its adjacency matrix

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-22_5.jpg)

Figure 7.7: The adjacency matrix of a graph maintains one bit for each vertex pair, indicating whether or not there is an edge connecting the two vertices.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-22_6.jpg)

 

It’s easy to add bells and whistles to the adjacency matrix repre-

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-22_7.jpg)

sentation of a graph:

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-22_8.jpg)

• Parallel edges. If a graph can have multiple edges with the same

pair of endpoints, then Aij can be defined as the number of edges with endpoints i and j.

• Weighted graphs. Similarly, if each edge (i, j) has a weight wij —

perhaps representing a cost or a distance—then each entry Aij stores wij.

• Directed graphs. For a directed graph G, each entry Aij of the

adjacency matrix is defined as

⇢ 1 if edge (i, j) belongs to E

A ij = 0 otherwise,

where “edge (i, j)” now refers to the edge directed from i to j. Every undirected graph has a symmetric adjacency matrix, while a directed graph usually has an asymmetric adjacency matrix.

What are the memory requirements of an adjacency matrix?

10 Graphs: The Basics

 

Quiz 7.3

How much space does the adjacency matrix of a graph require, as a function of the number n of vertices and the number m of edges?

a\) ⇥(n)

b\) ⇥(m)

c\) ⇥(m + n)

d\) 2 ⇥ ( n)

(See Section 7.4.4 for the solution and discussion.)

 

7.4.3 Comparing the Representations

Confronted with two different ways to represent a graph, you’re probably wondering: Which is better? The answer, as it so often is with such questions, is “it depends.” First, it depends on the density of your graph—on how the number m of edges compares to the number n

of vertices. The moral of Quizzes 7.2 and 7.3 is that the adjacency matrix is an efficient way to encode a dense graph but is wasteful for a sparse graph. Second, it depends on which operations you want to support. On both counts, adjacency lists make more sense for the algorithms and applications described in this book series.

Most of our graph algorithms will involve exploring a graph. Ad-jacency lists are perfect for graph exploration—you arrive at a vertex, and the adjacency list immediately indicates your options for the next

step.9 Adjacency matrices do have their applications, but we won’t

see them in this book series. 10

Much of the modern-day interest in fast graph primitives is moti-vated by massive sparse networks. Consider, for example, the Web

graph (Section 7.2), where vertices correspond to Web pages and directed edges to hyperlinks. It’s hard to get an exact measurement of

9 If you had access to only the adjacency matrix of a graph, how long would it take you to figure out which edges are incident to a given vertex?

10 For example, you can count the number of common neighbors of each pair of

vertices in one fell swoop by squaring the graph’s adjacency matrix.

7.4 Representing a Graph 11

 

the size of this graph, but a conservative lower bound on the number of vertices is 10 billion, or 10 10. Storing and reading through an array of this length already requires significant computational resources, but it is well within the limits of what modern computers can do. The size of the adjacency matrix of this graph, however, is proportional to 100 quintillion ( 20 10). This is way too big to store or process with today’s technology. But the Web graph is sparse—the average num-ber of outgoing edges from a vertex is well under 100. The memory requirements of the adjacency list representation of the Web graph are therefore proportional to 12 10 (a trillion). This may be too big for your laptop, but it’s within the capabilities of state-of-the-art

data-processing systems.11

 

7.4.4 Solutions to Quizzes 7.2–7.3

Solution to Quiz 7.2

Correct answer: (c). The adjacency list representation requires space linear in the size of the graph (meaning the number of vertices

plus the number of edges), which is ideal. 12 Seeing this is a little tricky. Let’s step through the four ingredients one by one. The vertex and edge arrays have lengths n and m, respectively, and so require ⇥(n) and ⇥(m) space. The third ingredient associates two pointers with each edge (one for each endpoint). These 2m pointers contribute an additional ⇥(m) to the space requirement.

The fourth ingredient might make you nervous. After all, each

of the n vertices can participate in as many as n 1 edges—one per other vertex—seemingly leading to a bound of 2 ⇥ ( n). This quadratic bound would be accurate in a very dense graph, but is overkill in sparser graphs. The key insight is: For every vertex!edge pointer in the fourth ingredient, there is a corresponding edge!vertex pointer in the third ingredient. If the edge e is incident to the vertex v, then e has a pointer to its endpoint v, and, conversely, v has a pointer to the incident edge e. We conclude that the pointers in the third and fourth ingredients are in one-to-one correspondence, and so they require

11 For example, the essence of Google’s original PageRank algorithm for mea-suring Web page importance relied on efficient search in the Web graph.

12 Caveat: The leading constant factor here is larger than that for the adjacency matrix by an order of magnitude.

12 Graphs: The Basics

 

exactly the same amount of space, namely ⇥(m). The final scorecard is:

vertex array ⇥(n) edge array ⇥(m) pointers from edges to endpoints ⇥(m)

\+ pointers from vertices to incident edges ⇥(m)

total ⇥(m + n).

The bound of ⇥(m + n) applies whether or not the graph is connected,

and whether or not it has parallel edges. 13

Solution to Quiz 7.3

Correct answer: (d). The straightforward way to store an adjacency matrix is as an 2 n ⇥ n two-dimensional array of bits. This uses ⇥ ( n)

space, albeit with a small hidden constant. For a dense graph, in which the number of edges is itself close to quadratic in n, the adjacency matrix requires space close to linear in the size of the graph. For sparse graphs, however, in which the number of edges is closer to

linear in n 14 , the adjacency matrix representation is highly wasteful.

The Upshot

P A graph is a representation of the pairwise rela-

tionships between objects, such as friendships

in a social network, hyperlinks between Web

pages, or dependencies between tasks.

P A graph comprises a set of vertices and a set

of edges. Edges are unordered in undirected

graphs and ordered in directed graphs.

P A graph is sparse if the number of edges m is

close to linear in the number of vertices n, and dense if m is close to quadratic in n.

13 If the graph is connected, then m n 1 (by Quiz 7.1), and we could

write ⇥(m) in place of ⇥(m + n). 14 This waste can be reduced by using tricks for storing and manipulating sparse matrices, meaning matrices with lots of zeroes. For instance, Matlab and Python’s SciPy package both support sparse matrix representations.

Problems 13

 

P The adjacency list representation of a graph

maintains vertex and edge arrays, cross-

referencing each other in the natural way, and

requires space linear in the total number of ver-

tices and edges.

P The adjacency matrix representation of a graph

maintains one bit per pair of vertices to keep

track of which edges are present, and requires

space quadratic in the number of vertices.

P The adjacency list representation is the pre-

ferred one for sparse graphs, and for applications

that involve graph exploration.

 

Test Your Understanding

Problem 7.1 (S) Let G = (V, E) be an undirected graph. By the degree of a vertex v 2 V , we mean the number of edges in E that

are incident to v 15 (i.e., that have v as an endpoint). For each of the following conditions on the graph G, is the condition satisfied only by dense graphs, only by sparse graphs, or by both some sparse and some dense graphs? As usual, n = \|V \| denotes the number of vertices. Assume that n is large (say, at least 10,000).

a\) At least one vertex of G has degree at most 10.

b\) Every vertex of G has degree at most 10.

c\) At least one vertex of G has degree n 1.

d\) Every vertex of G has degree n 1.

Problem 7.2 (S) Consider an undirected graph G = (V, E) that is represented as an adjacency matrix. Given a vertex v 2 V , how many operations are required to identify the edges incident to v? (Let k denote the number of such edges. As usual, n and m denote the number of vertices and edges, respectively.)

15 The abbreviation “i.e.” stands for id est, and means “that is.” 14 Graphs: The Basics

 

a\) ⇥(1)

b\) ⇥(k)

c\) ⇥(n)

d\) ⇥(m)

Problem 7.3 Consider a directed graph G = (V, E) represented with adjacency lists, with each vertex storing an array of its outgoing edges (but not its incoming edges). Given a vertex v 2 V , how many operations are required to identify the incoming edges of v? (Let k denote the number of such edges. As usual, n and m denote the number of vertices and edges, respectively).

a\) ⇥(1)

b\) ⇥(k)

c\) ⇥(n)

d\) ⇥(m)