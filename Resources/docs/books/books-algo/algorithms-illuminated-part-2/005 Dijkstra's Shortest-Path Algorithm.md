## Chapter 9

 

Dijkstra’s Shortest-Path Algorithm

 

We’ve arrived at another one of computer science’s greatest hits:

Dijkstra’s shortest-path algorithm.1 This algorithm works in any directed graph with nonnegative edge lengths, and it computes the lengths of shortest paths from a starting vertex to all other vertices.

After formally defining the problem (Section 9.1), we describe the

algorithm (Section 9.2), its proof of correctness (Section 9.3), and a

straightforward implementation (Section 9.4). In the next chapter, we’ll see a blazingly fast implementation of the algorithm that takes advantage of the heap data structure.

 

9.1 The Single-Source Shortest Path Problem

9.1.1 Problem Definition

Dijkstra’s algorithm solves the 2 single-source shortest path problem .

 

Problem: Single-Source Shortest Paths

Input: A directed graph G = (V, E), a starting vertex s 2 V , and a nonnegative length \`e for each edge e 2 E.

Output: dist(s, v) for every vertex v 2 V .

 

1 Discovered by Edsger W. Dijkstra in 1956 (“in about twenty minutes,” he said in an interview many years later). Several other researchers independently discovered similar algorithms in the late 1950s.

2 The term “source” in the name of the problem refers to the given starting vertex. We’ve already used the term “source vertex” to mean a vertex of a

directed graph with no incoming edges (Section 8.5.2). To stay consistent with

our terminology in Chapter 8, we’ll stick with “starting vertex.”

76

9.1 The Single-Source Shortest Path Problem 77

 

Recall that the notation dist(s, v) denotes the length of a shortest path from s to v. (If there is no path at all from s to v, then dist(s, v) is +1.) By the length of a path, we mean the sum of the lengths of its edges. For instance, in a graph in which every edge has length 1, the length of a path is just the number of edges in it. A shortest path from a vertex v to a vertex w is one with minimum length (among all v-w paths).

For example, if the graph represents a road network and the

length of each edge represents the expected travel time from one end to the other, the single-source shortest path problem is the problem of computing driving times from an origin (the starting vertex) to all possible destinations.

 

Quiz 9.1

Consider the following input to the single-source shortest path problem, with starting vertex s and with each edge labeled with its length:

### *v* 

1 6

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-90_1.jpg)

*s* 2 *t*

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-90_2.jpg)

4 3

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-90_3.jpg)

*w*

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-90_4.jpg)

 

What are the shortest-path distances to s, v, w, and t, respectively?

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-90_5.jpg)

a\) 0, 1, 2, 3

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-90_6.jpg)

b\) 0, 1, 3, 6

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-90_7.jpg)

c\) 0, 1, 4, 6

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-90_8.jpg)

d\) 0, 1, 4, 7

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-90_9.jpg)

(See Section 9.1.4 for the solution and discussion.)

78 Dijkstra’s Shortest-Path Algorithm

 

9.1.2 Some Assumptions

For concreteness, we assume throughout this chapter that the in-put graph is directed. Dijkstra’s algorithm applies equally well to undirected graphs after small cosmetic changes (as you should check).

Our other assumption is significant. The problem statement al-ready spells it out: We assume that the length of every edge is nonneg-ative. In many applications, like computing driving directions, edge lengths are automatically nonnegative (barring a time machine) and there’s nothing to worry about. But remember that paths in a graph can represent abstract sequences of decisions. For example, perhaps you want to compute a profitable sequence of financial transactions that involves both buying and selling. This problem corresponds to finding a shortest path in a graph with edge lengths that are both positive and negative. You should not use Dijkstra’s algorithm in

applications with negative edge lengths; see also Section 9.3.1.3

 

9.1.3 Why Not Breadth-First Search?

We saw in Section 8.2 that one of the killer applications of breadth-first search is computing shortest-path distances from a starting vertex. Why do we need another shortest-path algorithm?

Remember that breadth-first search computes the minimum num-ber of edges in a path from the starting vertex to every other vertex. This is the special case of the single-source shortest path problem in

which every edge has length 1. We saw in Quiz 9.1 that, with general nonnegative edge lengths, a shortest path need not be a path with the fewest number of edges. Many applications of shortest paths, such as computing driving directions or a sequence of financial transactions, inevitably involve edges with different lengths.

But wait, you say; is the general problem really so different from this special case? Can’t we just think of an edge with a longer length \` as a path of \` edges that each have length 1?:

3 1 1 1

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-91_1.jpg)

*v* *w* *v* *w*

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-91_2.jpg)

 

3 In Part 3 we’ll learn about efficient algorithms for the more general single-source shortest path problem in which negative edge lengths are allowed, including the famous Bellman-Ford algorithm.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-91_3.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-91_4.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-91_5.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-91_6.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-91_7.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-91_8.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-91_9.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-91_10.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-91_11.jpg)

9.1 The Single-Source Shortest Path Problem 79

 

Indeed, there’s no fundamental difference between an edge with a positive integral length \` and a path of \` length-1 edges. In principle, you can solve the single-source shortest path problem by expanding edges into paths of length-1 edges and applying breadth-first search to the expanded graph.

This is an example of a reduction from one problem to another—in

this case, from the single-source shortest path problem with positive integer edge lengths to the special case of the problem in which every edge has length 1.

The major problem with this reduction is that it blows up the size

of the graph. The blowup is not too bad if all the edge lengths are small integers, but this is not always the case in applications. The length of an edge could even be much bigger than the number of vertices and edges in the original graph! Breadth-first search would run in time linear in the size of the expanded graph, but this is not necessarily close to linear time in the size of the original graph. Dijkstra’s algorithm can be viewed as a slick simulation of breadth-first search on the expanded graph, while working only with the original input graph and running in near-linear time.

 

On Reductions

A problem A reduces to a problem B if an algorithm that solves B can be easily translated into one that solves A. For example, the problem of computing the median element of an array reduces to the problem of

sorting the array. Reductions are one of the most im-

portant concepts in the study of algorithms and their

limitations, and they can also have great practical

utility.

You should always be on the lookout for reductions.

Whenever you encounter a seemingly new problem,

always ask: Is the problem a disguised version of one

you already know how to solve? Alternatively, can

you reduce the general version of the problem to a

special case?

80 Dijkstra’s Shortest-Path Algorithm

 

9.1.4 Solution to Quiz 9.1

Correct answer: (b). No prizes for guessing that the shortest-path distance from s to itself is 0 and from s to v is 1. Vertex w is more interesting. One s-w path is the direct edge (s, w), which has length 4. But using more edges can decrease the total length: The path s ! v ! w has length only 1 + 2 = 3 and is the shortest s-w path. Similarly, each of the two-hop paths from s to t has length 7, while the zigzag path has length only 1 + 2 + 3 = 6.

 

9.2 Dijkstra’s Algorithm

9.2.1 Pseudocode

The high-level structure of Dijkstra’s algorithm resembles that of our

graph search algorithms.4 Each iteration of its main loop processes one new vertex. The algorithm’s sophistication lies in its clever rule for selecting which vertex to process next: the not-yet-processed vertex that appears to be closest to the starting vertex. The following elegant pseudocode makes this idea precise.

Dijkstra

Input: directed graph G = (V, E) in adjacency-list

representation, a vertex s 2 V , a length \`e 0 for each e 2 E.

Postcondition: for every vertex v, the value len(v)

equals the true shortest-path distance dist(s, v).

// Initialization

1 X := {s}

2 len(s) := 0, len(v) := + 1 for every v 6= s

// Main loop

3 while there is an edge (v, w) with v 2 X, w 62 X do 4 ⇤ ⇤ ( v , w) := such an edge minimizing len(v) + \`vw 5 ⇤ add w to X

6 ⇤ ⇤ len ( w ) := len ( v) + \` ⇤ ⇤ v w

 

4 When all the edges have length 1, it’s equivalent to breadth-first search (as you should check).

9.2 Dijkstra’s Algorithm 81

 

The set X contains the vertices that the algorithm has already dealt with. Initially, X contains only the starting vertex (and, of course, len(s) = 0), and the set grows like a mold until it covers all the vertices reachable from s. The algorithm assigns a finite value to the len-value of a vertex at the same time it adds the vertex to X. Each iteration of the main loop augments X by one new vertex, the head of some

edge (v, w) crossing from X to V X (Figure 9.1). (If there is no such edge, the algorithm halts, with len(v) = + 1 for all v 62 X.) There can be many such edges; the Dijkstra algorithm chooses one ⇤ ⇤ ( v , w)

that minimizes the Dijkstra score, which is defined as

len(v) + \`vw. (9.1)

Note that Dijkstra scores are defined on the edges—a vertex w / 2 X may be the head of many different edges crossing from X to V X,

and these edges will typically have different Dijkstra scores.

processed not-yet-processed

 

### X 

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-94_1.jpg)

*s* V-X

candidates

for (v\*,w\*)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-94_2.jpg)

 

the frontier

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-94_3.jpg)

Figure 9.1: Every iteration of Dijkstra’s algorithm processes one new vertex, the head of an edge crossing from X to V X.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-94_4.jpg)

 

You can associate the Dijkstra score for an edge (v, w) with v 2 X

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-94_5.jpg)

and w / 2 X with the hypothesis that the shortest path from s to w consists of a shortest path from s to v (which hopefully has length len(v) ) with the edge (v, w) (which has length \`vw) tacked on at the end. Thus, the Dijkstra algorithm chooses to add the as-yet-unprocessed vertex that appears closest to s, according to the already-computed shortest-path distances and the lengths of the edges crossing 82 Dijkstra’s Shortest-Path Algorithm

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-94_6.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-94_7.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-94_8.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-94_9.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-94_10.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-94_11.jpg)

 

from X to V X. While adding ⇤ w to X, the algorithm assigns len ⇤ ( w) to its hypothesized shortest-path distance from s, which is the Dijkstra score ⇤ ⇤ ⇤ len ( v ) + \` v ⇤ w ⇤ of the edge ( v , w ). The magic of

Dijkstra’s algorithm, formalized in Theorem 9.1 below, is that this hypothesis is guaranteed to be correct, even if the algorithm has thus

far looked at only a tiny fraction of the graph.5

 

9.2.2 An Example

Let’s try out the Dijkstra algorithm on the example from Quiz 9.1:

### *v* 

1 6

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-95_1.jpg)

*s* 2 *t*

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-95_2.jpg)

4 3

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-95_3.jpg)

*w*

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-95_4.jpg)

 

Initially, the set X contains only s, and len(s) = 0. In the first iteration of the main loop, there are two edges crossing from X to ⇤ V X (and hence eligible to play the role of ⇤ ( v , w )), the edges (s, v)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-95_5.jpg)

and (s, w). The Dijkstra scores (defined in (9.1)) for these two edges are len(s) + \`sv = 0 + 1 = 1 and len(s) + \`sw = 0 + 4 = 4. Because the former edge has the lower score, its head v is added to X, and len(v) is assigned to the Dijkstra score of the edge (s, v), which is 1. In the second iteration, with X = {s, v}, there are three edges to consider for the role of ⇤ ⇤ ( v , w): (s, w), (v, w), and (v, t). Their Dijkstra scores are 0 + 4 = 4, 1 + 2 = 3, and 1 + 6 = 7. Because (v, w) has the lowest Dijkstra score, w gets sucked into X and len(w) is assigned the value 3 ( v, w)’s Dijkstra score). We already know which vertex gets added to X in the final iteration (the only not-yet-processed vertex t), but we still need to determine the edge that leads to its addition (to compute len(t)). As (v, t) and (w, t) have Dijkstra scores

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-95_6.jpg)

5 To compute the shortest paths themselves (and not just their lengths), associate a pointer ⇤ predecessor ( v ) with each vertex v 2 V . When an edge ⇤ ( v , w)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-95_7.jpg)

is chosen in an iteration of the main while loop (lines 4–6), assign predecessor ⇤ ( w)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-95_8.jpg)

to ⇤ v, the vertex responsible for ⇤ w’s selection. After the algorithm concludes, to reconstruct a shortest path from s to a vertex v, follow the predecessor pointers backward from v until you reach s.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-95_9.jpg)

\*9.3 Why Is Dijkstra’s Algorithm Correct? 83

 

1 + 6 = 7 and 3 + 3 = 6, respectively, len(t) is set to the lower score of 6. The set X now contains all the vertices, so no edges cross from X to V X and the algorithm halts. The values len(s) = 0, len(v) = 1, len(w) = 3, and len(t) = 6 match the true shortest-path distances

that we identified in Quiz 9.1.

Of course, the fact that an algorithm works correctly on a spe-

cific example does 6 not imply that it is correct in general! In fact, the Dijkstra algorithm need not compute the correct shortest-path

distances when edges can have negative lengths (Section 9.3.1). You should be initially skeptical of the Dijkstra algorithm and demand a proof that, at least in graphs with nonnegative edge lengths, it correctly solves the single-source shortest path problem.

 

\*9.3 Why Is Dijkstra’s Algorithm Correct?

9.3.1 A Bogus Reduction

You might be wondering why it matters whether or not edges have negative edge lengths. Can’t we just force all the edge lengths to be nonnegative by adding a big number to every edge’s length?

This is a great question—you should always be on the lookout

for reductions to problems you already know how to solve. Alas, you cannot reduce the single-source shortest path problem with general edge lengths to the special case of nonnegative edge lengths in this way. The problem is that different paths from one vertex to another might not have the same number of edges. If we add some number to the length of each edge, then the lengths of different paths can increase by different amounts, and a shortest path in the new graph might be different than in the original graph. Here’s a simple example:

### *v* 

1 -5

*s* -2 *t*

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-96_1.jpg)

 

There are two paths from s to t: the direct path (which has length 2)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-96_2.jpg)

and the two-hop path s ! v ! t (which has length 1 + ( 5) = 4).

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-96_3.jpg)

6 Even a broken analog clock is correct two times a day. . . 84 Dijkstra’s Shortest-Path Algorithm

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-96_4.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-96_5.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-96_6.jpg)

 

The latter has the smaller (that is, more negative) length, and is the shortest s-t path.

To force the graph to have nonnegative edge lengths, we could add 5 to every edge’s length:

### *v* 

6 0

*s* 3 *t*

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-97_1.jpg)

 

The shortest path from s to t has switched, and is now the direct s-t edge (which has length 3, better than the alternative of 6). Running a shortest-path algorithm on the transformed graph would not produce a correct answer for the original graph.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-97_2.jpg)

9.3.2 A Bad Example for the Dijkstra Algorithm

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-97_3.jpg)

What happens if we try running the Dijkstra algorithm directly on a graph with some negative edge lengths, like the graph above? As always, initially X = {s} and len(s) = 0, all of which is fine. In the first iteration of the main loop, however, the algorithm computes the Dijkstra scores of the edges (s, v) and (s, t), which are len(s) + \`sv = 0 + 1 = 1 and len(s) + \`st = 0 + ( 2) = 2. The latter edge has the smaller score, and so the algorithm adds the vertex t to X and assigns len(t) to the score -2. As we already noted, the actual shortest path from s to t (the path s ! v ! t) has length 4. We conclude that the Dijkstra algorithm need not compute the correct shortest-path distances in the presence of negative edge lengths.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-97_4.jpg)

9.3.3 Correctness with Nonnegative Edge Lengths

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-97_5.jpg)

Proofs of correctness can feel pretty pedantic. That’s why I often gloss over them for the algorithms for which students tend to have strong and accurate intuition. Dijkstra’s algorithm is different. First, the fact that it doesn’t work on extremely simple graphs with negative

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-97_6.jpg)

edge lengths (Section 9.3.1) should make you nervous. Second, the

Dijkstra score (9.1) might seem mysterious or even arbitrary—why is it so important? Because of these doubts, and because it is such a fundamental algorithm, we’ll take the time to carefully prove its correctness (in graphs with nonnegative edge lengths).

\*9.3 Why Is Dijkstra’s Algorithm Correct? 85

 

Theorem 9.1 (Correctness of Dijkstra) For every directed graph G = (V, E), every starting vertex s, and every choice of nonneg-ative edge lengths, at the conclusion of Dijkstra, len(v) = dist(s, v) for every vertex v 2 V .

 

Induction Detour

The plan is to justify the shortest-path distances computed by the Dijkstra algorithm one by one, by induction on the number of itera-tions of its main loop. Recall that proofs by induction follow a fairly rigid template, with the goal of establishing that an assertion P (k)

holds for every positive integer k. In the proof of Theorem 9.1, we will define P (k) as the statement: “for the kth vertex v added to the set X in Dijkstra, len(v) = dist(s, v).”

Analogous to a recursive algorithm, a proof by induction has

two parts: a base case and an inductive step. The base case proves directly that P (1) is true. In the inductive step, you as-sume that P(1), . . . , P (k 1) are all true—this is called the inductive hypothesis—and use this assumption to prove that P (k) is conse-quently true as well. If you prove both the base case and the inductive step, then P (k) is indeed true for every positive integer k. P (1) is true by the base case, and applying the inductive step over and over again shows that P (k) is true for arbitrarily large values of k.

On Reading Proofs

Mathematical arguments derive conclusions from as-

sumptions. When reading a proof, always make sure

you understand how each of the assumptions is used

in the argument, and why the argument would break

down in the absence of each assumption.

With this in mind, watch carefully for the role

played in the proof of Theorem 9.1 by the two key

assumptions: that edge lengths are nonnegative, and

that the algorithm always chooses the edge with the

smallest Dijkstra score. Any purported proof of The-

orem 9.1 that fails to use both assumptions is auto-

matically flawed.

86 Dijkstra’s Shortest-Path Algorithm

 

Proof of Theorem 9.1

We proceed by induction, with P(k) the assertion that the Dijkstra algorithm correctly computes the shortest-path distance of the kth vertex added to the set X. For the base case (k = 1), we know that the first vertex added to X is the starting vertex s. The Dijkstra algorithm assigns 0 to len(s). Because every edge has a nonnegative length, the shortest path from s to itself is the empty path, with length 0. Thus, len(s) = 0 = dist(s, s), which proves P(1).

For the inductive step, choose k \> 1 and assume that P(1), . . . , P (k 1) are all true—that len(v) = dist(s, v) for the first ⇤ k 1 vertices v added by Dijkstra to X . Let w denote the kth vertex added to ⇤ X , and let ⇤ ( v , w) denote the edge chosen in the corresponding iteration (necessarily with ⇤ v already in X). The al-gorithm assigns ⇤ len ( w) to the Dijkstra score of this edge, which is len ⇤ ( v) + \` ⇤ ⇤ v w. We’re hoping that this value is the same as the true shortest-path distance ⇤ dist ( s, w), but is it?

We argue in two parts that it is. First, let’s prove that the true distance ⇤ dist ( s, w) can only be less than the algorithm’s speculation len ⇤ ⇤ ⇤ ⇤ ( w ) , with dist ( s, w )  len ( w ) . Because v was already in X when the edge ⇤ ⇤ ( v , w) was chosen, it was one of the first k 1 vertices added to X. By the inductive hypothesis, the Dijkstra algorithm correctly computed ⇤ v’s shortest-path distance: ⇤ ⇤ len ( v ) = dist ( s, v). In particular, there is a path P from s to ⇤ v with length exactly ⇤ len ( v).

Tacking the edge ⇤ ⇤ ⇤ ( v , w ) on at the end of P produces a path P

from ⇤ s to ⇤ w with length ⇤ len ( v ) + \` v ⇤ w ⇤ = len ( w) (Figure 9.2). The length of a shortest s-⇤ w path is no longer than that of the candidate path ⇤ ⇤ P , so ⇤ dist ( s, w ) is at most len ( w).

shortest s-v\* path P

(length *len(v**\***)*)

*v**\**

*l* *v\*w\**

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-99_1.jpg)

*s* *w**\**

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-99_2.jpg)

s-w\* path P\* (length *len(v**\***)+l**v\*w\**)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-99_3.jpg)

Figure 9.2: Tacking the edge ⇤ ⇤ ⇤ ( v , w ) on at the end of a shortest s-v path ⇤ P produces an s- ⇤ w path P with length len(v) + \`v⇤w⇤ . \*9.3 Why Is Dijkstra’s Algorithm Correct? 87

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-99_4.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-99_5.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-99_6.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-99_7.jpg)

 

Now for the reverse inequality, stating that ⇤ ⇤ dist ( s, w ) len ( w)

(and so ⇤ ⇤ len ( w ) = dist ( s, w), as desired). In other words, let’s show

that the path ⇤ P in Figure 9.2 really is a shortest s-⇤ w path—that the length of every competing ⇤ s-⇤ w path is at least len ( w).

Fix a competing s-⇤ w path 0 P. We know very little about 0 P.

However, we do know that it originates at s and ends at ⇤ w, and that ⇤ s but not w belonged to the set X at the beginning of this iteration. Because it starts in X and ends outside X, the path 0 P

crosses the frontier between X and V X at least once (Figure 9.3); let 0 ( y, z ) denote the first edge of P that crosses the frontier (with

y 7 2 X and z / 2 X ).

processed not-yet-processed

 

### X 

*y* *z*

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-100_1.jpg)

*s* V-X

 

*w**\**

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-100_2.jpg)

 

the frontier

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-100_3.jpg)

Figure 9.3: Every ⇤ s-w path crosses at least once from X to V X .

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-100_4.jpg)

 

To argue that the length of 0 ⇤ P is at least len ( w), we consider its

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-100_5.jpg)

three pieces separately: the initial part of 0 P that travels from s to y, the edge ⇤ ( y, z ) , and the final part that travels from z to w. The first part can’t be shorter than a shortest path from s to y, so its length is at least dist(s, y). The length of the edge (y, z) is \`yz. We don’t know much about the final part of the path, which ambles among vertices that the algorithm hasn’t looked at yet. But we do know—because all edge lengths are nonnegative!—that its total length is at least zero:

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-100_6.jpg)

7 ⇤ No worries if y = s or z = w—the argument works fine, as you should check. 88 Dijkstra’s Shortest-Path Algorithm

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-100_7.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-100_8.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-100_9.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-100_10.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-100_11.jpg)

 

length ≥ 0

length ≥ *dist(s,y) = len(y)*

 

*w**\**

*y* *z*

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-101_1.jpg)

*s*

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-101_2.jpg)

length = *l**yz*

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-101_3.jpg)

 

total length ≥ *len(s,y) + l* ≥ *len(s,v**\***) + l* *= len(w**\***)* *yz* *v\*w\**

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-101_4.jpg)

Combining our length lower bounds for the three parts of 0 P, we have

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-101_5.jpg)

 

length of P 0 dist(s, y) + \`yz + 0 . (9.2) \|{z} \| {z } \|{z} ⇤ z-w subpath s-y subpath edge ( y, z )

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-101_6.jpg)

The last order of business is to connect our length lower bound

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-101_7.jpg)

in (9.2) to the Dijkstra scores that guide the algorithm’s decisions. Because y 2 X, it was one of the first k 1 vertices added to X, and the inductive hypothesis implies that the algorithm correctly computed its shortest-path distance: dist(s, y) = len(y). Thus, the

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-101_8.jpg)

inequality (9.2) translates to

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-101_9.jpg)

length of P 0 len(y) + \`yz . (9.3)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-101_10.jpg)

\| {z }

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-101_11.jpg)

Dijkstra score of edge (y, z)

The right-hand side is exactly the Dijkstra score of the edge (y, z). Because the algorithm always chooses the edge with the smallest Dijkstra score, and because it chose ⇤ ⇤ ( v , w) over (y, z) in this iteration, the former has an even smaller Dijkstra score: ⇤ len ( v) + \` ⇤ ⇤ v w 

len(y) + \`yz. Plugging this inequality into (9.3) gives us what we want:

length of 0 ⇤ ⇤ P len ( v ) + \` v ⇤ w ⇤ = len ( w).

\| {z }

Dijkstra score of edge ⇤ ⇤ ( v , w)

This completes the second part of the inductive step, and we conclude that len(v) = dist(s, v) for every vertex v that ever gets added to the set X.

For the final nail in the coffin, consider a vertex v that was never added to X. When the algorithm finished, len(v) = +1 and no edges 9.4 Implementation and Running Time 89

 

crossed from X to V X. This means no path exists from s to v in the input graph—such a path would have to cross the frontier at some point—and, hence, dist(s, v) = + 1 as well. We conclude that the algorithm halts with len(v) = dist(s, v) for every vertex v, whether or not v was ever added to X. This completes the proof! QE D

 

9.4 Implementation and Running Time

Dijkstra’s shortest-path algorithm is reminiscent of our linear-time

graph search algorithms in Chapter 8. A key reason why breadth-

and depth-first search run in linear time (Theorems 8.2 and 8.5) is that they spend only a constant amount of time deciding which vertex to explore next (by removing the vertex from the front of a queue or stack). Alarmingly, every iteration of Dijkstra’s algorithm must identify the edge crossing the frontier with the smallest Dijkstra score. Can we still implement the algorithm in linear time?

Quiz 9.2

Which of the following running times best describes a straightforward implementation of Dijkstra’s algorithm for graphs in adjacency-list representation? As usual, n and m denote the number of vertices and edges, respectively, of the input graph.

a\) O(m + n)

b\) O(m log n)

c\) 2 O ( n)

d\) O(mn)

(See below for the solution and discussion.)

 

Correct answer: (d). A straightforward implementation keeps

track of which vertices are in X by associating a Boolean variable with each vertex. Each iteration, it performs an exhaustive search through all the edges, computes the Dijkstra score for each edge with tail in X and head outside X (in constant time per edge), and returns the crossing edge with the smallest score (or correctly identifies that 90 Dijkstra’s Shortest-Path Algorithm

 

no crossing edges exist). After at most n 1 iterations, the Dijkstra algorithm runs out of new vertices to add to its set X. Because the number of iterations is O(n) and each takes time O(m), the overall running time is O(mn).

Proposition 9.2 (Dijkstra Running Time (Straightforward)) For every directed graph G = (V, E), every starting vertex s, and every choice of nonnegative edge lengths, the straightforward implementation of Dijkstra runs in O(mn) time, where m = \|E\| and n = \|V \|.

The running time of the straightforward implementation is good but not great. It would work fine for graphs in which the number of vertices is in the hundreds or low thousands, but would choke on significantly larger graphs. Can we do better? The holy grail in algorithm design is a linear-time algorithm (or close to it), and this is what we want for the single-source shortest path problem. Such an algorithm could process graphs with millions of vertices on a commodity laptop.

We don’t need a better algorithm to achieve a near-linear-time solution to the problem, just a better implementation of Dijkstra’s algorithm. Data structures (queues and stacks) played a crucial role in our linear-time implementations of breadth- and depth-first search; analogously, Dijkstra’s algorithm can be implemented in near-linear time with the assistance of the right data structure to facilitate the repeated minimum computations in its main loop. This data structure is called a heap, and it is the subject of the next chapter.

The Upshot

P In the single-source shortest path problem, the

input consists of a graph, a starting vertex, and

a length for each edge. The goal is to compute

the length of a shortest path from the starting

vertex to every other vertex.

P Dijkstra’s algorithm processes vertices one by

one, always choosing the not-yet-processed ver-

tex that appears to be closest to the starting

vertex.

Problems 91

 

P An inductive argument proves that Dijkstra’s al-

gorithm correctly solves the single-source short-

est path problem whenever the input graph has

only nonnegative edge lengths.

P Dijkstra’s algorithm need not correctly solve the

single-source shortest path problem when some

edges of the input graph have negative lengths.

P A straightforward implementation of Dijkstra’s

algorithm runs in O(mn) time, where m and n denote the number of edges and vertices of the

input graph, respectively.

 

Test Your Understanding

Problem 9.1 Consider a directed graph G with distinct and non-negative edge lengths. Let s be a starting vertex and t a destination vertex, and assume that G has at least one s-t path. Which of the following statements are true? (Choose all that apply.)

a\) The shortest (meaning minimum-length) s-t path might have

as many as n 1 edges, where n is the number of vertices.

b\) There is a shortest s-t path with no repeated vertices (that is,

with no loops).

c\) The shortest s-t path must include the minimum-length edge

of G.

d\) The shortest s-t path must exclude the maximum-length edge

of G.

Problem 9.2 (S) Consider a directed graph G with a starting ver-tex s, a destination t, and nonnegative edge lengths. Under what conditions is the shortest s-t path guaranteed to be unique?

a\) When all edge lengths are distinct positive integers.

b\) When all edge lengths are distinct powers of 2.

92 Dijkstra’s Shortest-Path Algorithm

 

c\) When all edge lengths are distinct positive integers and the

graph G contains no directed cycles.

d\) None of the other options are correct.

Problem 9.3 (S) Consider a directed graph G with nonnegative edge lengths and two distinct vertices, s and t. Let P denote a shortest path from s to t. If we add 10 to the length of every edge in the graph, then: (Choose all that apply.)

a\) P definitely remains a shortest s-t path.

b\) P definitely does not remain a shortest s-t path.

c\) P might or might not remain a shortest s-t path (depending on

the graph).

d\) If P has only one edge, then P definitely remains a shortest s-t

path.

Problem 9.4 Consider a directed graph G and a starting vertex s with the following properties: no edges enter the starting vertex s; edges that leave s have arbitrary (possibly negative) lengths; and all other edge lengths are nonnegative. Does Dijkstra’s algorithm correctly solve the single-source shortest path problem in this case? (Choose all that apply.)

a\) Yes, for all such inputs.

b\) Never, for no such inputs.

c\) Maybe, maybe not (depending on the specific choice of G, s,

and edge lengths).

d\) Only if we add the assumption that G contains no directed

cycles with negative total length.

Problem 9.5 Consider a directed graph G and a starting vertex s. Suppose G has some negative edge lengths but no negative cycles, meaning G does not have a directed cycle in which the sum of its edge lengths is negative. Suppose you run Dijkstra’s algorithm on this input. Which of the following statements are true? (Choose all that apply.)

Problems 93

 

a\) Dijkstra’s algorithm might loop forever.

b\) It’s impossible to run Dijkstra’s algorithm on a graph with

negative edge lengths.

c\) Dijkstra’s algorithm always halts, but in some cases the shortest-

path distances it computes will not all be correct.

d\) Dijkstra’s algorithm always halts, and in some cases the shortest-

path distances it computes will all be correct.

 

Problem 9.6 Continuing the previous problem, suppose now that the input graph G does contain a negative cycle, and also a path from the starting vertex s to this cycle. Suppose you run Dijkstra’s algorithm on this input. Which of the following statements are true? (Choose all that apply.)

 

a\) Dijkstra’s algorithm might loop forever.

b\) It’s impossible to run Dijkstra’s algorithm on a graph with a

negative cycle.

c\) Dijkstra’s algorithm always halts, but in some cases the shortest-

path distances it computes will not all be correct.

d\) Dijkstra’s algorithm always halts, and in some cases the shortest-

path distances it computes will all be correct.

 

Challenge Problems

Problem 9.7 (S) Consider a directed graph G = (V, E) with non-negative edge lengths and a starting vertex s. Define the bottleneck of a path to be the maximum length of one of its edges (as opposed to the sum of the lengths of its edges). Show how to modify Dijkstra’s algorithm to compute, for each vertex v 2 V , the smallest bottleneck of any s-v path. Your algorithm should run in O(mn) time, where m and n denote the number of edges and vertices, respectively. 94 Dijkstra’s Shortest-Path Algorithm

 

Programming Problems

Problem 9.8 Implement in your favorite programming language the

Dijkstra algorithm from Section 9.2, and use it to solve the single-source shortest path problem in different directed graphs. With the straightforward implementation in this chapter, what’s the size of the largest problem you can solve in five minutes or less? (See

[www.algorithmsilluminated.org](http://www.algorithmsilluminated.org) for test cases and challenge data sets.)