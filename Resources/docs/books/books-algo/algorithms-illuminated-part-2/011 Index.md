## Index

 

\|x \| (absolute value), 196 binary search, 127, 133

n (binomial coefficient), 7 birthday paradox, 162, 172

dxe (ceiling), 174 2 blazingly fast, vii, viii, 18

bxc (floor), 115 bloom filter

\|S \| (set size), 4 Insert, 179, 182

 

adjacency matrix, 8–10 input size, 11 heuristic assumptions, 185 vs. adjacency matrix, 10 in network routers, 181 operation running times, 179 applications, 10 raison d’être, 178 input size, 12 scorecard, 180 sparse representation, 12 space-accuracy trade-o ff , 179, vs. adjacency lists, 10 183, 188–189, 191 arc, see edge (of a graph), directed supported operations, 178– asymptotic notation, 5, 193–199 179 acknowledgments, xi has false positives, 179, 183 adjacency lists, 7–8 has no false negatives, 183 in graph search, 27 heuristic analysis, 185–189 abstract data type, 95 applications, 180–181 Lookup , 179, 183

 

big-omega notation, 197 when to use, 180 Bloom, Burton H., 178 big-theta notation, 198 bow tie, see Web graph in seven words, 193 big-O notation, 194–195 vs. hash tables, 178–180 as a sweet spot, 193

Augmented-BFS breadth-first search, 22, 24–30 , 31 correctness, 30

Bacon number, 16, 31 example, 27–29

Bacon, Kevin, 16 for computing connected

base case, 85 components, 34–37

BFS, see breadth-first search for computing shortest paths,

BFS , 27 31–33

big-O notation, 194–195 layers, 25, 34

examples, 195–197 pseudocode, 27

big-omega notation, 197 running time analysis, 30

big-theta notation, 198 Broder, Andrei, 67

203

204 Index

 

broken clock, 83 correctness, 44

example, 40

C++, 130 for computing connected

can we do better?, 90 components, 44

cf., 44 for computing strongly con-

chess, 158 nected components, 56

clustering, 36 for topological sorting, 49–52

cocktail party, ix, 97, 172 iterative implementation, 42

coin flipping, 175 recursive implementation, 43

collision, see hash function, colli- running time analysis, 44

sion design patterns, ix

connected components DFS, see depth-first search

applications, 36–37 DFS (Iterative Version), 42

definition, 34 DFS (Recursive Version), 43

example, 38 DFS-SCC, 63

in directed graphs, see DFS-Topo, 50

strongly connected dictionary, see hash table

components Dijkstra, 80

linear-time computation, 37– Dijkstra (heap-based), 108, 111

39 Dijkstra’s shortest-path algorithm

number of, 40 correctness, 86–89

Cormen, Thomas H., 145 Dijkstra score, 81

corollary, 21 example, 82

Coursera, x for computing minimum bot-

Crosby, Scott A., 169 tleneck paths, 93, 124

cryptography, 177 greedy selection rule, 81

heap-based implementation,

DAG, see directed acyclic graph 105–112

data structure in undirected graphs, 78

bloom filter, see bloom filter pseudocode, 80

expertise levels, 96 pseudocode (heap-based),

hash table, see hash table 108, 111 heap, see heap reconstructing shortest paths,

principle of parsimony, 96 82

queue, 26, 95 running time analysis, 89

raison d’être, 95 running time analysis (heap-

scorecards, see scorecards based), 111 search tree, see search tree straightforward implementa-

stack, 42, 95 tion, 89

vs. abstract data type, 95 with negative edge lengths,

de-duplication, 155 84

decomposition blueprint, 175 Dijkstra, Edsger W., 76

degree (of a vertex), 13 directed acyclic graph, 47

depth-first search, 23, 40–44 has a source vertex, 47 Index 205

 

has a topological ordering, 47– input size, 3

49 notation, 2, 4

discussion forum, xi path, 6, 19, 34

dist, see shortest paths, distance radius, 72

distance, see shortest paths, dis- representations, 7–11

tance sparse, 5

Draper, Don, 16 tree, 6

Easley, David, 69 Web, undirected, 2

 

edge (of a graph), 2 graph search see Web graph directed, 2 A⇤, 159 length, 76 applications, 15–18 parallel, 4, 9 breadth-first search,

 

Egoyan, Atom, 16 weighted, 9 depth-first search, see depth-first search Einstein, Albert, 96 for planning, 17 undirected, 2 breadth-first search see

 

endpoints (of an edge), 2 generic algorithm, 19–24 equivalence class, 35 in game playing, 159 equivalence relation, 35 problem definition, 18 Erdös number, 16 greatest hits, ix Erdös, Paul, 16

 

Firth, Colin, 16 Hamm, Jon, 16 hash function for-free primitive, 18 and the birthday paradox,

Gabow, Harold N., 124 163

GenericSearch, 19 bad, 168

Google, 11 collision, 162

googol, 158 collisions are inevitable, 162,

graph, 1 168

adjacency lists, 7–8, 11 cryptographic, 177

adjacency matrix, 8–10, 12 definition, 160

applications, 2–3 desiderata, 170

co-authorship, 16 don’t design your own, 176

complete, 6, 34 example, 171

connected, 4 good, 170

connected components, see how to choose, 176

connected components kryptonite, 168

cycle, 46 multiple, 167, 182

dense, 5 pathological data set, 168–

diameter, 71 169

directed, 2 random, 170, 185

directed acyclic, see directed state-of-the-art, 176–177

acyclic graph universal, 169 206 Index

 

hash map, see hash table with linear probing, 166–167,

hash table 175, 177

Delete, 153, 164 with open addressing, 165–

Insert, 153, 164, 166 167, 177

Lookup , 153, 164, 166 head (of an edge), 2

advice, 173 heap (data structure)

applications, 154–159 DecreaseKey, 111

as an array, 151, 160 Delete, 100, 125

bucket, 163 ExtractMax, 99

collision-resolution strategies, ExtractMin, 98, 119

177–178 FindMin, 99

for de-duplication, 155 Heapify, 99

for searching a huge state Insert, 98, 115

space, 158 applications, 101–105

for the 2-SUM problem, 156– as a tree, 112

158 as an array, 114

hash function, see hash func- bubble/heapify/sift (up or

tion down), 118, 121, 125

heuristic analysis, 175 for an event manager, 103

in compilers, 154 for median maintenance, 104,

in network routers, 154 150

in security applications, 169 for sorting, 102

iteration, 155 for speeding up Dijkstra’s al-

load, 174 gorithm, 105–112

load vs. performance, 176 heap property, 112

non-pathological data set, keys, 98

169 operation running times, 99,

operation running times, 153 100

performance of chaining, 164– parent-child formulas, 115

165, 174–175 raison d’être, 99

performance of open address- scorecard, 100

ing, 167, 175 supported operations, 98–100

probe sequence, 165 vs. search trees, 131–133

raison d’être, 151 when to use, 100

resizing to manage load, 176 heap (memory), 98

scorecard, 153, 160, 175 HeapSort, 102–103

space usage, 153

supported operations, 153 i.e., 13

vs. arrays, 160 independence (in probability), 185

vs. bloom filters, 178 induction, see proofs, by induc-

vs. linked lists, 160 tion

when to use, 154 inductive hypothesis, 85

with chaining, 163–165, 177 inductive step, 85

with double hashing, 167, 175 interview questions, ix Index 207

 

invariant, 105 Pigeonhole Principle, 162, 169

planning (as graph search), 17

Java, 130, 171 principle of parsimony, 96

 

Kleinberg, Jon, 69 programming, x, 20 Knuth, Donald E., 175 programming problems, xi Kosaraju , 62 proofs, x key, 98 probability, 175 priority queue, see heap

 

Kosaraju’s algorithm by contradiction, 24 correctness, 65 by induction, 85 example, 63 on reading, 85 from 30,000 feet, 57 proposition, 21 implementation, 62, 75 pseudocode, 20 pseudocode, 62

 

Kosaraju, S. Rao, 57 running time analysis, 65 QE D (q.e.d.), 24 why the reversed graph?, 58– queue, 26, 95 61 quizzes, x

Kumar, Ravi, 67 Raghavan, Prabhakar, 67

 

Leighton, F. Thomson, x reduction, 79, 83 Leiserson, Charles E., 145 Rivest, Ronald L., 145 lemma, 21 Lehman, Eric, x recursion, 43 Rajagopalan, Sridhar, 67

 

length SCC, see strongly connected com-of a path, 77 ponents of an edge, 76 scorecards, 12, 100, 128, 129, 153, linearity of expectation, 175 160, 175, 180 Linux kernel, 130 search tree

 

Maghoul, Farzin, 67 Delete, 129, 139, 144 Insert , 129, 138, 144 mathematical background, x Max , 126, 135 median, 104 Min , 126, 135 Meyer, Albert R., x OutputSorted , 127, 137

network Predecessor , 127, 136

movie, 16 Rank, 127, 142

physical, 16 Search , 126, 134

road, 2 Select , 127, 142–144

social, 3 Successor , 127, 136

node, 2-3, 145 see vertex (of a graph)

null pointer, 131 applications, 130

augmented, 142, 144

pathological data set, 168–169 AVL, 145

paying the piper, 109, 144 B, 145 208 Index

 

balanced, 130, 144–148 sorting, 101–103

height, 133 stack (data structure), 42, 95

in-order traversal, 138 pop, 42

operation running times, 130 push, 42

pointers, 131 stack (memory), 44

raison d’être, 129 Stanford Lagunita, x

red-black, 145, 146 starred sections, viii, 54

rotation, 146–148 Stata, Raymie, 67

scorecard, 129 Stein, Clifford, 145

search tree property, 131 strongly connected components

splay, 145 and the 2SAT problem, 74

supported operations, 129 definition, 54

vs. heaps, 131–133 giant, 68

vs. sorted arrays, 126, 131 in a reversed graph, 61, 66

when to use, 130 linear-time computation, see

Sedgewick, Robert, 146 Kosaraju’s algorithm

SelectionSort, 101 meta-graph of, 55

separate chaining, see hash table, sink, 58

with chaining source, 59

Sharir, Micha, 57 topological ordering of, 55, 60

shortest paths via depth-first search, 54, 56

and Bacon numbers, 17 Sudoku, 17

bottleneck, 93, 124

distance, 30, 77 tail (of an edge), 2

nonnegative edge lengths, 78 Tarjan, Robert E., 54, 124

problem definition, 31, 76 task scheduling, 3, 45, 46

via breadth-first search, 31– test cases, xi

33, 78 theorem, 21

via Dijkstra’s algorithm, see Tomkins, Andrew, 67

Dijkstra’s shortest-path topological ordering

algorithm definition, 45

with negative edge lengths, existence in directed acyclic

78, 83 graphs, 47–49

with unit edge lengths, 31, 79 non-existence, 46

single-source shortest path prob- topological sorting, 44–52

lem, 76 example, 50

six degrees of separation, 69 linear-time computation, 51

small world property, 69 problem definition, 49

solutions, xi, 200–202 pseudocode, 49

sorted array TopoSort, 49

scorecard, 128 correctness, 52

supported operations, 126 in non-acyclic graphs, 53, 58

unsupported operations, 129 run backward, 63

vs. search trees, 131 running time analysis, 52

Index 209

 

tree, 6

binary, 112

chain, 133

depth, 133

full, 112

height, 130, 133

root, 112

search, see search tree

2SAT, 74

2-SUM, 156–158, 192

UCC , 37

correctness, 39

running time analysis, 39

upshot, viii

vertex (of a graph), 1

degree, 13

reachable, 19

sink, 47

source, 47, 76

starting, 76

videos, x

bonus, 146, 169, 176

Wallach, Dan S., 169

Wayne, Kevin, 146

Web graph, 3, 66–69

as a sparse graph, 10

bow tie, 68

connectivity, 69

giant component, 68

size, 10, 68, 154

whack-a-mole, 115

why bother?, viii

Wiener, Janet, 67

World Wide Web, see Web graph

yottabyte, 154

YouTube, x