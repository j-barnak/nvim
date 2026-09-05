## Chapter 12

 

Hash Tables and Bloom Filters

 

We conclude with an incredibly useful and ubiquitous data structure known as a hash table (or hash map). Hash tables, like heaps and search trees, maintain an evolving set of objects associated with keys (and possibly lots of other data). Unlike heaps and search trees, they maintain no ordering information whatsoever. The raison d’être of a hash table is to facilitate super-fast searches, which are also called lookups in this context. A hash table can tell you what’s there and what’s not, and can do it really, really quickly (much faster than a heap or search tree). As usual, we’ll start with the

supported operations (Section 12.1) before proceeding to applications

(Section 12.2) and some optional implementation details (Sections 12.3

and 12.4). Sections 12.5 and 12.6 cover bloom filters, close cousins of hash tables that use less space at the expense of occasional errors.

 

12.1 Supported Operations

The raison d’être of a hash table is to keep track of an evolving set of objects with keys while supporting fast lookups (by key), so that it’s easy to check what’s there and what’s not. For example, if your company manages an ecommerce site, you might use one hash table to keep track of employees (perhaps with names as keys), another one to store past transactions (with transaction IDs as keys), and a third to remember the visitors to your site (with IP addresses as keys).

Conceptually, you can think of a hash table as an array. One thing

that arrays are good for is immediate random access. Wondering what’s in position number 17 of an array? Just access that position directly, in constant time. Want to change the contents in position 23? Again, easy in constant time.

Suppose you want a data structure for remembering your friends’

phone numbers. If you’re lucky, all your friends had unusually unimag-

151

152 Hash Tables and Bloom Filters

 

inative parents who named their kids after positive integers, say be-tween 1 and 10000. In this case, you can store phone numbers in a length-10000 array (which is not that big). If your best friend is named 173, store their phone number in position 173 of the array. To forget about your ex-friend 548, overwrite position 548 with a default value. This array-based solution works well, even if your friends change over time—the space requirements are modest and insertions, deletions, and lookups run in constant time.

Probably your friends have more interesting but less convenient names, like Alice, Bob, Carol, and so on. Can we still use an array-based solution? In principle, you could maintain an array with entries indexed by every possible name you might ever see (with at most, say, 25 letters). To look up Alice’s phone number, you can then look

in the “Alice” position of the array (Figure 12.1).

 

55 99-5-9 5 9 55 99-5 -9

null -4 -2 null +1 15 12

+1

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-165_1.jpg)

 

” ” ” b” **.** **.** **.** **.** **.** **.** **.** **.** **.** **.** **.** **.** **.** aa icf ice “Bo “Al “Aa “Al

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-165_2.jpg)

Figure 12.1: In principle, you could store your friends’ phone numbers in an array indexed by strings with at most 25 characters.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-165_3.jpg)

 

Quiz 12.1

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-165_4.jpg)

How many length-25 character strings are there? (Choose the strongest true statement.)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-165_5.jpg)

a\) More than the number of hairs on your head.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-165_6.jpg)

b\) More than the number of Web pages in existence.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-165_7.jpg)

c\) More than the total amount of storage available on

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-165_8.jpg)

Earth (in bits).

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-165_9.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-165_10.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-165_11.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-165_12.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-165_13.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-165_14.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-165_15.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-165_16.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-165_17.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-165_18.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-165_19.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-165_20.jpg)

12.1 Supported Operations 153

 

d\) More than the number of atoms in the universe.

(See Section 12.1.1 for the solution and discussion.)

The point of Quiz 12.1 is that the array needed for this solution is WAY TOO BIG. Is there an alternative data structure that replicates all the functionality of an array, with constant-time insertions, deletions, and lookups, and that also uses space proportional to the number of objects stored? A hash table is exactly such a data structure.

Hash Tables: Supported Operations

Lookup (a.k.a. Search): for a key k, return a pointer to an object in the hash table with key k (or report that no such object exists).

Insert: given a new object x, add x to the hash table.

Delete: for a key k, delete an object with key k from the hash table, if one exists.

 

In a hash table, all these operations typically run in constant

time—matching the naive array-based solution—under a couple of

assumptions that generally hold in practice (described in Section 12.3). A hash table uses space linear in the number of objects stored. This is radically less than the space required by the naive array-based solution, which is proportional to the number of all-imaginable objects that might ever need to be stored. The scorecard reads:

 

Operation Typical running time

Lookup ⇤ O (1)

Insert O(1)

Delete ⇤ O (1)

Table 12.1: Hash tables: supported operations and their typical running times. The asterisk (\*) indicates that the running time bound holds if and only if the hash table is implemented properly (with a good hash function and an appropriate table size) and the data is non-pathological;

see Section 12.3 for details.

154 Hash Tables and Bloom Filters

 

Summarizing, hash tables don’t support many operations, but what they do, they do really, really well. Whenever lookups constitute a significant amount of your program’s work, a light bulb should go off in your head—the program calls out for a hash table!

When to Use a Hash Table

If your application requires fast lookups with a dynamically changing set of objects, the hash table is usually the data structure of choice.

 

12.1.1 Solution to Quiz 12.1

Correct answer: (c). The point of this quiz is to have fun thinking about some really big numbers, rather than to identify the correct answer per se. Let’s assume that there are 26 choices for a character— ignoring punctuation, upper vs. lower case, etc. Then, there are 25 26

25-letter strings, which has order of magnitude roughly 35 10. (There are also the strings with 24 letters or less, but these are dwarfed by the length-25 strings.) The number of hairs on a person’s head is typically around 5 10. The indexed Web has several billion pages, but the actual number of Web pages is probably around one trillion ( 12 10). The total amount of storage on Earth is hard to estimate but, at least in 2018, is surely no more than a yottabyte ( 24 10 bytes, or roughly 25 10 bits). Meanwhile, the number of atoms in the known universe is estimated to be around 80 10.

 

12.2 Applications

It’s pretty amazing how many different applications boil down to repeated lookups and hence call out for a hash table. Back in the 1950s, researchers building the first compilers needed a symbol table, meaning a good data structure for keeping track of a program’s variable and function names. Hash tables were invented for exactly this type of application. For a more modern example, imagine that a network router is tasked with blocking data packets from certain IP addresses, perhaps belonging to spammers. Every time a new data packet arrives, the router must look up whether the source IP address is in the blacklist. If so, it drops the packet; otherwise, it forwards 12.2 Applications 155

 

the packet toward its destination. Again, these repeated lookups are right in the wheelhouse of hash tables.

 

12.2.1 Application: De-duplication

De-duplication is a canonical application of hash tables. Suppose you’re processing a massive amount of data that’s arriving one piece at a time, as a stream. For example:

• You’re making a single pass over a huge file stored on disk, like

all the transactions of a major retail company from the past year.

• You’re crawling the Web and processing billions of Web pages.

• You’re tracking data packets passing through a network router

at a torrential rate.

• You’re watching the visitors to your Web site.

In the de-duplication problem, your responsibility is to ignore du-plicates and keep track only of the distinct keys seen so far. For example, you may be interested in the number of distinct IP addresses that have accessed your Web site, in addition to the total number of visits. Hash tables provide a simple solution to the de-duplication problem.

De-duplication with a Hash Table

When a new object x with key k arrives:

1\. Use Lookup to check if the hash table already con-

tains an object with key k.

2\. If not, use Insert to put x in the hash table.

 

After processing the data, the hash table contains exactly one object

per key represented in the data stream. 1

1 With most hash table implementations, it’s possible to iterate through the

stored objects, in some arbitrary order, in linear time. This enables further processing of the objects after the duplicates have been removed.

156 Hash Tables and Bloom Filters

 

12.2.2 Application: The 2-SUM Problem

Our next example is more academic, but it illustrates how repeated lookups can show up in surprising places. The example is about the 2-SUM problem.

Problem: 2-SUM

Input: An unsorted array A of n integers, and a target integer t.

Goal: Determine whether or not there are two numbers x, y

in A 2 satisfying x + y = t .

 

The 2-SUM problem can be solved by brute-force search—by trying all possibilities for x and y and checking if any of them work. Because there are n choices for each of x and y, this is a quadratic-time ( 2 ⇥ ( n)) algorithm.

We can do better. The first key observation is that, for each choice of x, only one choice for y could possibly work (namely, t x). So why not look specifically for this y?

2-SUM (Attempt \#1)

Input: array A of n integers and a target integer t. Output: “yes” if A\[i\] + A\[j\] = t for some

i, j 2 {1, 2, 3, . . . , n}, “no” otherwise.

for i = 1 to n do

y := t A\[i\]

if A contains y then // linear search

return “yes”

return “no”

 

Does this help? The for loop has n iterations and it takes linear time to search for an integer in an unsorted array, so this would seem to be

2 There are two slightly different versions of the problem, depending on whether or not x and y are required to be distinct. We’ll allow x = y; the other case is similar (as you should check).

12.2 Applications 157

 

another quadratic-time algorithm. But remember, sorting is a for-free primitive. Why not use it, so that all the searches can take advantage of a sorted array?

2-SUM (Sorted Array Solution)

Input: array A of n integers and a target integer t. Output: “yes” if A\[i\] + A\[j\] = t for some

i, j 2 {1, 2, 3, . . . , n}, “no” otherwise.

sort A // using a sorting subroutine for i = 1 to n do

y := t A\[i\]

if A contains y then // binary search

return “yes”

return “no”

 

Quiz 12.2

What’s the running time of an educated implementation of the sorted array-based algorithm for the 2-SUM problem?

a\) ⇥(n)

b\) ⇥(n log n)

c\) 1.5 ⇥ ( n)

d\) 2 ⇥ ( n)

(See Section 12.2.4 for the solution and discussion.)

 

The sorted array-based solution to 2-SUM is a big improvement

over brute-force search, and it showcases the elegant power of the algorithmic tools from Part 1. But we can do even better. The final insight is that this algorithm needed a sorted array only inasmuch as it needed to search it quickly. Because most of the work boils down to repeated lookups, a light bulb should go off in your head: A sorted array is overkill, and what this algorithm really calls out for is a hash table!

158 Hash Tables and Bloom Filters

 

2-SUM (Hash Table Solution)

Input: array A of n integers and a target integer t. Output: “yes” if A\[i\] + A\[j\] = t for some

i, j 2 {1, 2, 3, . . . , n}, “no” otherwise.

H := empty hash table for i = 1 to n do

Insert A\[i\] into H

for i = 1 to n do

y := t A\[i\]

if H contains y then // using Lookup

return “yes”

return “no”

 

Assuming a good hash table implementation and non-pathological data, the Insert and Lookup operations typically run in constant time. In this case, the hash table-based solution to the 2-SUM problem runs in linear time. Because any correct algorithm must look at every number in A at least once, this is the best-possible running time (up to constant factors).

12.2.3 Application: Searching Huge State Spaces

Hash tables are all about speeding up search. One application domain in which search is ubiquitous is game-playing, and more generally in planning problems. Think, for example, of a chess-playing program exploring the ramifications of different moves. Sequences of moves can be viewed as paths in a huge directed graph, where vertices correspond to states of the game (positions of all the pieces and whose turn it is), and edges correspond to moves (from one state to another). The size of this graph is astronomical (more than 100 10 vertices), so there’s no hope of writing it down explicitly and applying any of our graph

search algorithms from Chapter 8. A more tractable alternative is to run a graph search algorithm like breadth-first search, starting from the current state, and explore the short-term consequences of different moves until reaching a time limit. To learn as much as possible, it’s important to avoid exploring a vertex more than once, and so the search algorithm must keep track of which vertices it has already \*12.3 Implementation: High-Level Ideas 159

 

visited. As in our de-duplication application, this task is ready-made for a hash table. When the search algorithm reaches a vertex, it looks it up in a hash table. If the vertex is already there, the algorithm skips it and backtracks; otherwise, it inserts the vertex into the hash

table and proceeds with its exploration.3,4

12.2.4 Solution to Quiz 12.2

Correct answer: (b). The first step can be implemented in

O(n log n) time using MergeSort (described in Part 1) or HeapSort

(Section 10.3.1).5 Each of the n for loop iterations can be implemented in O(log n) time via binary search. Adding everything up gives the final running time bound of O(n log n).

 

\*12.3 Implementation: High-Level Ideas

This section covers the most important high-level ideas in a hash table implementation: hash functions (which map keys to positions in an array), collisions (different keys that map to the same position), and

the most common collision-resolution strategies. Section 12.4 offers more detailed advice about implementing a hash table.

12.3.1 Two Straightforward Solutions

A hash table stores a set S of keys (and associated data), drawn from a universe U of all possible keys. For example, 32 U might be all 2

possible IPv4 addresses, all possible strings of length at most 25, all possible chess board states, and so on. The set S could be the IP addresses that actually visited a Web page in the last 24 hours, the actual names of your friends, or the chess board states that your

3 In game-playing applications, the most popular graph search algorithm is

called A⇤ (“A star”) search. The A⇤ search algorithm is a goal-oriented general-

ization of Dijkstra’s algorithm (Chapter 9), which adds to the Dijkstra score (9.1) of an edge (v, w) a heuristic estimate of the cost required to travel from w to a “goal vertex.” For example, if you’re computing driving directions from a given origin to a given destination t, the heuristic estimate could be the straight-line distance from w to t.

4 Take a moment to think about modern technology and speculate where else

hash tables are used. It shouldn’t take long to come up with some good guesses!

5 No faster implementation is possible, at least with a comparison-based sorting

algorithm (see footnote 10 in Chapter 10).

160 Hash Tables and Bloom Filters

 

program explored in the last five seconds. In most applications of hash tables, the size of U is astronomical but the size of the subset S is manageable.

One conceptually straightforward way to implement the Lookup, Insert , and Delete operations is to keep track of objects in a big array, with one entry for every possible key in U . If U is a small set like all three-character strings (to keep track of airports by their three-letter codes, say), this array-based solution is a good one, with all operations running in constant time. In the many applications in which U is extremely large, this solution is absurd and unimplementable; we can realistically consider only data structures requiring space proportional to \|S\| (rather than to \|U \|).

A second straightforward solution is to store objects in a linked list. The good news is that the space this solution uses is proportional to \|S\|. The bad news is that the running times of Lookup and Delete also scale linearly with \|S\|—far worse than the constant-time operations that the array-based solution supports. The point of a hash table is to achieve the best of both worlds—space proportional

to \|S\| and constant-time operations (Table 12.2).

 

Data Structure Space Typical Running Time of Lookup

Array ⇥(\|U \|) ⇥(1)

Linked List ⇥(\|S\|) ⇥(\|S\|)

Hash Table ⇤ ⇥ ( \| S \| ) ⇥ (1)

Table 12.2: Hash tables combine the best features of arrays and linked lists, with space linear in the number of objects stored and constant-time operations. The asterisk (\*) indicates that the running time bound holds if and only if the hash table is implemented properly and the data is non-pathological.

 

12.3.2 Hash Functions

To achieve the best of both worlds, a hash table mimics the straight-forward array-based solution, but with the array length n proportional

to \|S 6 \| rather than \| U \| . For now, you can think of n as roughly 2\|S\|.

6 But wait; isn’t the set S changing over time? Yes it is, but it’s not hard to periodically resize the array so that its length remains proportional to the current

size of S; see also Section 12.4.2.

\*12.3 Implementation: High-Level Ideas 161

 

A hash function performs the translation from what we really

care about—our friends’ names, chess board states, etc.—to positions in the hash table. Formally, a hash function is a function from the

set U of all possible keys to the set of array positions (Figure 12.2). Positions are usually numbered from 0 in a hash table, so the set of array positions is {0, 1, 2, . . . , n 1}.

Hash Functions

A hash function h : U ! {0, 1, 2, . . . , n 1} assigns every key from the universe U to a position in an array of length n.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-174_1.jpg)

 

h 0

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-174_2.jpg)

1

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-174_3.jpg)

**.**

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-174_4.jpg)

 

U **.**

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-174_5.jpg)

**.**

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-174_6.jpg)

**.**

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-174_7.jpg)

**.**

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-174_8.jpg)

 

*n-1*

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-174_9.jpg)

 

Figure 12.2: A hash function maps every possible key in the universe U to a position in {0, 1, 2, . . . , n 1}. When \|U\| \> n, two different keys must be mapped to the same position.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-174_10.jpg)

 

A hash function tells you where to start searching for an object.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-174_11.jpg)

If you choose a hash function h with h("Alice") = 17—in which case, we say that the string “Alice” hashes to 17—then position 17 of the array is the place to start looking for Alice’s phone number. Similarly, position 17 is the first place to try inserting Alice’s phone number into the hash table.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-174_12.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-174_13.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-174_14.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-174_15.jpg)

162 Hash Tables and Bloom Filters

 

12.3.3 Collisions Are Inevitable

You may have noticed a serious issue: What if two different keys (like “Alice” and “Bob”) hash to the same position (like 23)? If you’re looking for Alice’s phone number but find Bob’s in position 23 of the array, how do you know whether or not Alice’s number is also in the hash table? If you’re trying to insert Alice’s phone number into position 23 but the position is already occupied, where do you put it?

When a hash function h maps two different keys k1 and k2 to the same position (that is, when h(k1) = h(k2)), it’s called a colli-sion.

Collisions

Two keys k1 and k2 from U collide under the hash function h if h(k1) = h(k2).

 

Collisions cause confusion about where an object resides in the hash table, and we’d like to minimize them as much as possible. Why not design a super-smart hash function with no collisions whatsoever? Because collisions are inevitable. The reason is the Pigeonhole Prin-ciple, the intuitively obvious fact that, for every positive integer n, no matter how you stuff n + 1 pigeons into n holes, there will be a hole with at least two pigeons. Thus whenever the number n of array positions (the holes) is less than the size of the universe U (the pigeons), every hash function (assignment of pigeons to holes)—no

matter how clever—suffers from at least one collision (Figure 12.2). In

most applications of hash tables, including those in Section 12.2, \|U \| is much, much bigger than n.

Collisions are even more inevitable than the Pigeonhole Principle argument suggests. The reason is the birthday paradox, the subject of the next quiz.

Quiz 12.3

Consider n people with random birthdays, with each of the 366 days of the year equally likely. (Assume all n people were born in a leap year.) How large does n need to be before there is at least a 50% chance that two people have the same birthday?

\*12.3 Implementation: High-Level Ideas 163

 

a\) 23

b\) 57

c\) 184

d\) 367

(See Section 12.3.7 for the solution and discussion.)

What does the birthday paradox have to do with hashing? Imagine

a hash function that assigns each key independently and uniformly at random to a position in {0, 1, 2, . . . , n 1}. This is not a practically

viable hash function (see Quiz 12.5), but such random functions are the gold standard to which we compare practical hash functions (see

Section 12.3.6). The birthday paradox implies that, even for the

gold standard, we’re likely to start seeing collisions in a hash table p of size n once a small constant times n objects have been inserted. For example, when n = 10, 000, the insertion of 200 objects is likely to cause at least one collision—even though at least 98% of the array positions are completely unused!

12.3.4 Collision Resolution: Chaining

With collisions an inevitable fact of life, a hash table needs some method for resolving them. This section and the next describe the two dominant approaches, separate chaining (or simply chaining) and open addressing. Both approaches lead to implementations in which insertions and lookups typically run in constant time, assuming the hash table size and hash function are chosen appropriately and the

data is non-pathological (cf., Table 12.1).

Buckets and Lists

Chaining is easy to implement and think about. The key idea is to

default to the linked-list-based solution (Section 12.3.1) to handle

multiple objects mapped to the same array position (Figure 12.3). With chaining, the positions of the array are often called buckets, as each can contain multiple objects. The Lookup, Insert, and Delete operations then reduce to one hash function evaluation (to determine the correct bucket) and the corresponding linked list operation.

164 Hash Tables and Bloom Filters

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-177_1.jpg)

 

0 “Carol”

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-177_2.jpg)

 

1 null

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-177_3.jpg)

 

2 “Daniel” “Bob”

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-177_4.jpg)

 

3 “Alice”

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-177_5.jpg)

 

Figure 12.3: A hash table with collisions resolved by chaining, with four buckets and four objects. The strings “Bob” and “Daniel” collide in the third bucket (bucket 2). Only the keys are shown, and not the associated data (like phone numbers).

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-177_6.jpg)

 

Chaining

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-177_7.jpg)

1\. Keep a linked list in each bucket of the hash table.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-177_8.jpg)

2\. To Lookup/Insert/Delete an object with key k,

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-177_9.jpg)

perform Lookup/Insert Delete on the linked list in the bucket A\[h(k)\], where h denotes the hash function and A the hash table’s array.

 

Performance of Chaining

Provided h can be evaluated in constant time, the Insert operation also takes constant time—the new object can be inserted immediately at the front of the list. Lookup and Delete must search through the list stored in A\[h(k)\], which takes time proportional to the list’s length. To achieve constant-time lookups in a hash table with chaining, the buckets’ lists must stay short—ideally, with length at most a small constant.

List lengths (and lookup times) degrade if the hash table becomes heavily populated. For example, if 100n objects are stored in a \*12.3 Implementation: High-Level Ideas 165

 

hash table with array length n, a typical bucket has 100 objects to sift through. Lookup times can also degrade with a poorly chosen hash function that causes lots of collisions. For example, in the extreme case in which all the objects collide and wind up in the same

bucket, lookups can take time linear in the data set size. Section 12.4 elaborates on how to manage the size of a hash table and choose an appropriate hash function to achieve the running time bounds stated

in Table 12.1.

12.3.5 Collision Resolution: Open Addressing

The second popular method for resolving collisions is open addressing. Open addressing is much easier to implement and understand when the hash table must support only Insert and Lookup (and not

Delete 7 ); we’ll focus on this case.

With open addressing, each position of the array stores 0 or 1

objects, rather than a list. (For this to make sense, the size \|S\| of the data set cannot exceed the size n of the hash table.) Collisions create an immediate quandary for the Insert operation: Where do we put an object with key k if a different object is already stored in the position A\[h(k)\]?

Probe Sequences

The idea is to associate each key k with a probe sequence of positions, not just a single position. The first number of the sequence indicates the position to consider first; the second the next position to con-sider when the first is already occupied; and so on. The object is stored in the first unoccupied position of its key’s probe sequence (see

Figure 12.4).

Open Addressing

1\. Insert: Given an object with key k, iterate through

the probe sequence associated with k, storing the object in the first empty position found.

 

7 Plenty of hash table applications don’t require the Delete operation, includ-

ing the three applications in Section 12.2.

166 Hash Tables and Bloom Filters

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-179_1.jpg)

 

“Carol”

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-179_2.jpg)

null

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-179_3.jpg)

null

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-179_4.jpg)

“Alice”

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-179_5.jpg)

“Daniel”

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-179_6.jpg)

null

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-179_7.jpg)

null

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-179_8.jpg)

“Bob”

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-179_9.jpg)

null

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-179_10.jpg)

 

Figure 12.4: An insertion into a hash table with collisions resolved by open addressing. The first entry of the probe sequence for “Daniel” collides with “Alice,” and the second with “Bob,” but the third entry is an unoccupied position.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-179_11.jpg)

 

2\. Lookup: Given a key k, iterate through the probe

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-179_12.jpg)

sequence associated with k until encountering the de-sired object (in which case, return it) or an empty

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-179_13.jpg)

position (in which case, report “none”).8

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-179_14.jpg)

 

Linear Probing

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-179_15.jpg)

There are several ways to use one or more hash functions to define a probe sequence. The simplest is linear probing. This method uses one hash function h, and defines the probe sequence for a key k as h(k), followed by h(k) + 1, followed by h(k) + 2, and so on (wrapping around to the beginning upon reaching the last position). That is, the hash

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-179_16.jpg)

8 If you encounter an empty position i, you can be confident that no object with key k is in the hash table. Such an object would have been stored either at position i or at an earlier position in k’s probe sequence. \*12.3 Implementation: High-Level Ideas 167

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-179_17.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-179_18.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-179_19.jpg)

 

function indicates the starting position for an insertion or lookup, and the operation scans to the right until it finds the desired object or an empty position.

Double Hashing

A more sophisticated method is double hashing, which uses two hash

functions. 9 The first tells you the first position of the probe sequence, and the second indicates the offset for subsequent positions. For example, if h1(k) = 17 and h2(k) = 23, the first place to look for an object with key k is position 17; failing that, position 40; failing that, position 63; failing that, position 86; and so on. For a different key 0 k, the probe sequence could look quite different. For example, if h 0 0 1 ( k ) = 42 and h 2 ( k) = 27, the probe sequence would be 42, followed by 69, followed by 96, followed by 123, and so on.

Performance of Open Addressing

With chaining, the running time of a lookup is governed by the lengths of buckets’ lists; with open addressing, it’s the typical number of probes required to find either an empty slot or the sought-after object. It’s harder to understand hash table performance with open addressing than with chaining, but it should be intuitively clear that performance suffers as the hash table gets increasingly full—if very few slots are empty, it will usually take a probe sequence a long time to find one—or when a poor choice of hash function causes lots of

collisions (see also Quiz 12.4). With an appropriate hash table size and hash function, open addressing achieves the running time bounds

stated in Table 12.1 for the Insert and Lookup operations; see

Section 12.4 for additional details.

12.3.6 What Makes for a Good Hash Function?

No matter which collision-resolution strategy we employ, hash table performance degrades with the number of collisions. How can we choose a hash function so that there aren’t too many collisions?

9 There are several quick-and-dirty ways to define two hash functions from a

single hash function h. For example, if keys are nonnegative integers represented in binary, define h1 and h2 from h by tacking on a new digit (either ‘0’ or ‘1’) to the end of the given key k: h1(k) = h(2k) and h2 (k) = h(2k + 1). 168 Hash Tables and Bloom Filters

 

Bad Hash Functions

There are a zillion different ways to define a hash function, and the choice matters. For example, what happens to hash table performance with a dumbest-possible choice of a hash function?

 

Quiz 12.4

Consider a hash table with length n 1, and let h be the hash function with h(k) = 0 for every key k 2 U . Suppose a data set S is inserted into the hash table, with \|S\|  n. What is the typical running time of subsequent Lookup operations?

a\) ⇥(1) with chaining, ⇥(1) with open addressing.

b\) ⇥(1) with chaining, ⇥(\|S\|) with open addressing.

c\) ⇥(\|S\|) with chaining, ⇥(1) with open addressing.

d\) ⇥(\|S\|) with chaining, ⇥(\|S\|) with open addressing.

(See Section 12.3.7 for the solution and discussion.)

 

Pathological Data Sets and Hash Function Kryptonite

None of us would ever implement the dumb hash function in Quiz 12.4. Instead, we’d work hard to design a smart hash function guaranteed to cause few collisions, or better yet to look up such a function in a book like this one. Unfortunately, I can’t tell you such a function. My excuse? Every hash function, no matter how smart, has its own kryp-tonite, in the form of a huge data set for which all objects collide and

with hash table performance deteriorating as in Quiz 12.4.

 

Pathological Data Sets

For every hash function h : U ! {0, 1, 2, . . . , n 1}, there exists a set S of keys of size \|U \|/n such that h(k1) = h(k2)

for every k 10 1 , k 2 2 S .

\*12.3 Implementation: High-Level Ideas 169

 

This may sound crazy, but it’s just a generalization of our Pigeonhole

Principle argument from Section 12.3.3. Fix an arbitrarily smart hash function h. If h perfectly partitions the keys in U among the n positions, then each position would have exactly \|U \|/n keys assigned to it; otherwise, even more than \|U \|/n keys are assigned to the same position. (For example, if \|U \| = 200 and n = 25, then h must assign at least eight different keys to the same position.) In any case, there is a position i 2 {0, 1, 2, . . . , n 1} to which h assigns at least \|U \|/n distinct keys. If the keys in a data set S happen to be all those assigned to this position i, then all the objects in the data set collide.

The data set S above is “pathological” in that it was constructed

with the sole purpose of foiling the chosen hash function. Why should we care about such an artificial data set? The main reason is that it explains the asterisks in our running time bounds for hash table

operations in Tables 12.1 and 12.2. Unlike most of the algorithms and data structures we’ve seen so far, there is no hope for a running time guarantee that holds with absolutely no assumptions about the input. The best we can hope for is a guarantee that applies to all “non-pathological” data sets, meaning data sets defined independently

of the chosen hash function. 11

The good news is that, with a well-crafted hash function, there’s

usually no need to worry about pathological data sets in practice. Security applications constitute an important exception to this rule,

however.12

Random Hash Functions

Pathological data sets show that no one hash function is guaranteed to have a small number of collisions for every data set. The best

10 In most applications of hash tables, \|U \| is way bigger than n, in which case a

data set of size \|U \|/n is huge! 11 It is also possible to consider randomized solutions, in the spirit of the randomized QuickSort algorithm in Chapter 5 of Part 1. This approach, called universal hashing, guarantees that for every data set, a random choice of a hash function from a small class of functions typically causes few collisions. For details

and examples, see the bonus videos at [www.algorithmsilluminated.org](http://www.algorithmsilluminated.org)[.](http://www.algorithmsilluminated.org)

12 An interesting case study is described in the paper “Denial of Service via Algorithmic Complexity Attacks,” by Scott A. Crosby and Dan S. Wallach (Pro-ceedings of the 12th USENIX Security Symposium, 2003). Crosby and Wallach showed how to bring a hash table-based network intrusion system to its knees through the clever construction of a pathological data set.

170 Hash Tables and Bloom Filters

 

we can hope for is a hash function that has few collisions for all

“non-pathological” data sets.13

An extreme approach to decorrelating the choice of hash function and the data set is to choose a random function, meaning a function h where, for each key k 2 U , the value of h(k) is chosen independently and uniformly at random from the array positions {0, 1, 2, . . . , n 1}.

The function h is chosen once and for all when the hash table is initially created. Intuitively, we’d expect such a random function to typically spread out the objects of a data set S roughly evenly across the n positions, provided S is defined independently of h. As long as n is roughly equal to \|S\|, this would result in a manageable number of collisions.

Quiz 12.5

Why is it impractical to use a completely random choice of a hash function? (Choose all that apply.)

a\) Actually, it is practical.

b\) It is not deterministic.

c\) It would take too much space to store.

d\) It would take too much time to evaluate.

(See Section 12.3.7 for the solution and discussion.)

 

Good Hash Functions

A “good” hash function is one that enjoys the benefits of a random function without suffering from either of its drawbacks.

Hash Function Desiderata

1\. Cheap to evaluate, ideally in O(1) time.

2\. Easy to store, ideally with O(1) memory.

 

13 The dumb hash function in Quiz 12.4 leads to terrible performance for every

data set, pathological or otherwise.

\*12.3 Implementation: High-Level Ideas 171

 

3\. Mimics a random function by spreading non-

pathological data sets roughly evenly across the posi-

tions of the hash table.

 

What Does a Good Hash Function Look Like?

While a detailed description of state-of-the-art hash functions is out-side the scope of this book, you might be hungry for something more concrete than the desiderata above.

For example, consider keys that are integers between 0 and some

large number M 14 . A natural first stab at a hash function is to take a key’s value modulo the number n of buckets:

h(k) = k mod n,

where k mod n is the result of repeatedly subtracting n from k until the result is an integer between 0 and n 1.

The good news is that this function is cheap to evaluate and

requires no storage (beyond remembering n 15 ). The bad news is that many real-world sets of keys are not uniformly distributed in their least significant bits. For example, if n = 1000 and all the keys have the same last three digits (base 10)—perhaps salaries at a company that are all multiples of 1000, or prices of cars that all end in “999”— then all the keys are hashed to the same position. Using only the most significant bits can cause similar problems—think, for example, about the country and area codes of phone numbers.

The next idea is to scramble a key before applying the modulus

operation:

h(k) = (ak + b) mod n,

where a and b are integers in {1, 2, . . . , n 1}. This function is again cheap to compute and easy to store (just remember a, b, and n). For well-chosen a, b, and n, this function is probably good enough to use in a quick-and-dirty prototype. For mission-critical code, however, it’s often essential to use more sophisticated hash functions, which

are discussed further in Section 12.4.3.

14 To apply this idea to non-numerical data like strings, it’s necessary to first convert the data to integers. For example, in Java, the hashCode method

implements such a conversion. 15 There are much faster ways to compute k mod n than repeated subtraction! 172 Hash Tables and Bloom Filters

 

To conclude, the two most important things to know about hash function design are:

 

Take-Aways

1\. Experts have invented hash functions that are cheap

to evaluate and easy to store, and that behave like

random functions for all practical purposes.

2\. Designing such a hash function is extremely tricky;

you should leave it to experts if at all possible.

 

12.3.7 Solutions to Quizzes 12.3—12.5

Solution to Quiz 12.3

Correct answer: (a). Believe it or not, all you need is 23 people in a room before it’s as likely to have two with the same birthday as

not.16 You can do (or look up) the appropriate probability calculation, or convince yourself of this with some simple simulations.

With 367 people, there would be a 100% chance of two people with the same birthday (by the Pigeonhole Principle). But already with 57 people, the probability is roughly 99%. And with 184? 99.99. . . %, with a large number of nines.

Most people find the answer counterintuitive; this is why the

example is known as the “birthday paradox.” 17 More generally, on

a planet with k days each year, the chance of duplicate birthdays p 18 hits 50% with ⇥ ( k ) people.

16 A good party trick at not-so-nerdy cocktail parties with at least, say, 35

people.

17 “Paradox” is a misnomer here; there’s no logical inconsistency, just another

illustration of how most people’s brains are not wired to have good intuition about probability.

18 The reason is that n people represent not just n opportunities for duplicate

birthdays, but n 2 ⇡ different opportunities (one for each pair of people). n

Two people have the same birthday with probability 2 2 , and you expect to start 1

seeing collisions once the number of collision opportunities is roughly k k (when

p

n = ⇥( k)).

\*12.4 Further Implementation Details 173

 

Solution to Quiz 12.4

Correct answer: (d). If collisions are resolved with chaining, the hash function h hashes every object in S to the same bucket: bucket 0. The hash table devolves into the simple linked-list solution, with ⇥(\|S\|) time required for Lookup.

For the case of open addressing, assume that the hash table uses

linear probing. (The story is the same for more complicated strategies like double hashing.) The lucky first object of \|S\| will be assigned to position 0 of the array, the next object to position 1, and so on. The Lookup operation devolves to a linear search through the first \|S\| positions of an unsorted array, which requires ⇥( \|S\|) time.

Solution to Quiz 12.5

Correct answers: (c),(d). A random function from U to {0, 1, 2, . . . , n 1} is effectively a lookup table of length \|U \| with log n 2 bits per entry. When the universe is large (as in most appli-cations), writing down or evaluating such a function is out of the question.

We could try defining the hash function on a need-to-know basis,

assigning a random value to h(k) the first time the key k is encountered. But then evaluating h(k) requires first checking whether it has already been defined. This boils down to a lookup for k, which is the problem we’re supposed to be solving!

 

\*12.4 Further Implementation Details

This section is for readers who want to implement a custom hash table from scratch. There’s no silver bullet in hash table design, so I can only offer high-level guidance. The most important lessons are: (i) manage your hash table’s load; (ii) use a well-tested modern hash function; and (iii) test several competing implementations to determine the best one for your particular application.

12.4.1 Load vs. Performance

The performance of a hash table degrades as its population increases: with chaining, buckets’ lists grow longer; with open addressing, it gets harder to locate an empty slot.

174 Hash Tables and Bloom Filters

 

The Load of a Hash Table

We measure the population of a hash table via its load:

 

load of a hash table . (12.1) n = number of objects stored array length

For example, in a hash table with chaining, the load is the average population in one of the table’s buckets.

Quiz 12.6

Which hash table strategy is feasible for loads larger than 1?

a\) Both chaining and open addressing.

b\) Neither chaining nor open addressing.

c\) Only chaining.

d\) Only open addressing.

(See Section 12.4.5 for the solution and discussion.)

 

Idealized Performance with Chaining

In a hash table with chaining, the running time of a Lookup or Delete operation scales with the lengths of buckets’ lists. In the best-case scenario, the hash function spreads the objects perfectly evenly across the buckets. With a load of ↵, this idealized scenario re-

sults in at most d↵ 19 e objects per bucket. The Lookup and Delete operations then take only O( d↵e) time, and so are constant-time op-

erations provided 20 ↵ = O (1) . Since good hash functions spread most data sets roughly evenly across buckets, this best-case performance is approximately matched by practical chaining-based hash table im-

19 The notation dxe denotes the “ceiling” function, which rounds its argument

up to the nearest integer.

20 We bother to write O(d↵e) instead of O(↵) only to handle the case where ↵

is close to 0. The running time of every operation is always ⌦(1), no matter how small ↵ is—if nothing else, there is one hash function evaluation to be accounted for. Alternatively, we could write O(1 + ↵) in place of O(d↵e). \*12.4 Further Implementation Details 175

 

plementations (with a good hash function and with non-pathological

data).21

 

Idealized Performance with Open Addressing

In a hash table with open addressing, the running time of a Lookup or Insert operation scales with the number of probes required to locate an empty slot (or the sought-after object). When the hash table’s load is ↵, an ↵ fraction of its slots are full and the remaining 1 ↵ fraction are empty. In the best-case scenario, each probe is uncorrelated with the hash table’s contents and has a 1 ↵ chance of locating an empty slot. In this idealized scenario, the expected number

of probes required is 1 22 . If ↵ is bounded away from 1—like 70%, 1 ↵

for example—the idealized running time of all operations is O(1). This best-case performance is approximately matched by practical hash tables implemented with double hashing or other sophisticated probe sequences. With linear probing, objects tend to clump together in consecutive slots, resulting in slower operation times: roughly 1 2 , (1 ↵ )

even in the idealized case.23 O This is still(1) time provided ↵ is significantly less than 100%.

21 Here’s a more mathematical argument for readers who remember basic probability. A good hash function mimics a random function, so let’s go ahead and assume that the hash function h independently assigns each key to one of

the n buckets uniformly at random. (See Section 12.6.1 for further discussion of this heuristic assumption.) Suppose that all objects’ keys are distinct, and that the key k is mapped to position i by h. Under our assumption, for every other key 0 k represented in the hash table, the probability that h also maps 0 k to the position i is 1/n. In total over the \|S\| keys in the data set S, the expected number of keys that share k’s bucket is \|S \|/n, a quantity known also as the load ↵. (Technically, this follows from linearity of expectation and the “decomposition blueprint” described in Section 5.5 of Part 1.) The expected running time of a

Lookup for an object with key k is therefore O( d↵e). 22 This is like a coin-flipping experiment: if a coin has probability p of coming up “heads,” what is the average number of flips required to see your first “heads?” (For us, p = 1 ↵.) As discussed in Section 6.2 of Part 1—or search Wikipedia

for “geometric random variable”—the answer is 1 p . 23 This highly non-obvious result was first derived by Donald E. Knuth, the father of the analysis of algorithms. It made quite an impression on him: “I first formulated the following derivation in 1962. . . Ever since that day, the analysis of algorithms has in fact been one of the major themes in my life.” (Donald E. Knuth,

The Art of Computer Programming, Volume 3 (2nd edition), Addison-Wesley, 1998,

page 536.)

176 Hash Tables and Bloom Filters

 

Collision-Resolution Strategy Idealized Running Time of Lookup

 

Double hashing Chaining O (d↵e) ⇣ ⌘ 1 O 1 ↵ ⇣ ⌘ Linear probing 1 O 2 (1 ↵ )

Table 12.3: Idealized performance of a hash table as a function of its

load 24 ↵ and its collision-resolution strategy.

 

12.4.2 Managing the Load of Your Hash Table

Insertions and deletions change the numerator in (12.1), and a hash table implementation should update the denominator to keep pace. A good rule of thumb is to periodically resize the hash table’s array so that the table’s load stays below 70% (or perhaps even less, depending on the application and your collision-resolution strategy). Then, with a well-chosen hash function and non-pathological data, all of the most common collision-resolution strategies typically lead to constant-time hash table operations.

The simplest way to implement array resizing is to keep track of the table’s load and, whenever it reaches 70%, to double the number n of buckets. All the objects are then rehashed into the new, larger hash table (which now has load 35%). Optionally, if a sequence of deletions brings the load down far enough, the array can be downsized accordingly to save space (with all remaining objects rehashed into the smaller table). Such resizes can be time-consuming, but in most applications they are infrequent.

12.4.3 Choosing Your Hash Function

Designing good hash functions is a difficult and dark art. It’s easy to propose reasonable-looking hash functions that end up being subtly flawed, leading to poor hash table performance. For this reason, I advise against designing your own hash functions from scratch. Fortunately, a number of clever programmers have devised an array

24 For more details on how the performance of different collision-resolution

strategies varies with the hash table load, see the bonus videos at [www.](http://www.algorithmsilluminated.org)

[algorithmsilluminated.org.](http://www.algorithmsilluminated.org)

\*12.4 Further Implementation Details 177

 

of well-tested and publicly available hash functions that you can use in your own work.

Which hash function should you use? Ask ten programmers this

question, and you’ll get at least eleven different answers. Because different hash functions fare better on different data distributions, you should compare the performance of several state-of-the-art hash functions in your particular application and runtime environment. As of this writing (in 2018), hash functions that are good starting points for further exploration include FarmHash, MurmurHash3, SpookyHash and MD5. These are all non-cryptographic hash functions, and are not designed to protect against adversarial attacks like that of Crosby

and Wallach (see footnote 12). 25 Cryptographic hash functions are more complicated and slower to evaluate than their non-cryptographic

counterparts, but they do protect against such attacks. 26 A good starting point here is the hash function SHA-1 and its newer relatives like SHA-256.

12.4.4 Choosing Your Collision-Resolution Strategy

For collision resolution, is it better to use chaining or open addressing? With open addressing, is it better to use linear probing, double hashing, or something else? As usual, when I present you with multiple solutions to a problem, the answer is “it depends.” For example, chaining takes more space than open addressing (to store the pointers in the linked lists), so the latter might be preferable when space is a first-order concern. Deletions are more complicated with open addressing than with chaining, so chaining might be preferable in applications with lots of deletions.

Comparing linear probing with more complicated open addressing

implementations like double hashing is also tricky. Linear probing results in bigger clumps of consecutive objects in the hash table and therefore more probes than more sophisticated approaches; however, this cost can be offset by its friendly interactions with the runtime

25 MD5 was originally designed to be a cryptographic hash function, but it is no longer considered secure.

26 All hash functions, even cryptographic ones, have pathological data sets

(Section 12.3.6). Cryptographic hash functions have the special property that it’s computationally infeasible to reverse engineer a pathological data set, in the same sense that it’s computationally infeasible to factor large integers and break the RSA public-key cryptosystem.

178 Hash Tables and Bloom Filters

 

environment’s memory hierarchy. As with the choice of a hash function, for mission-critical code, there’s no substitute for coding up multiple competing implementations and seeing which works best for your application.

12.4.5 Solution to Quiz 12.6

Correct answer: (c). Because hash tables with open addressing store at most one object per array position, they can never have a load larger than 1. Once the load is 1, it’s not possible to insert any more objects.

An arbitrary number of objects can be inserted into a hash table with chaining, although performance degrades as more are inserted. For example, if the load is 100, the average length of a bucket’s list is also 100.

 

12.5 Bloom Filters: The Basics

Bloom filters 27 are close cousins of hash tables. They are ridiculously space-efficient but, in exchange, they occasionally make errors. This section covers what bloom filters are good for and how they are

implemented, while Section 12.6 maps out the trade-off curve between a filter’s space usage and its frequency of errors.

12.5.1 Supported Operations

The raison d’être of a bloom filter is essentially the same as that of a hash table: super-fast insertions and lookups, so that you can quickly remember what you’ve seen and what you haven’t. Why should we bother with another data structure with the same set of operations? Because bloom filters are preferable to hash tables in applications in which space is at a premium and the occasional error is not a dealbreaker.

Like hash tables with open addressing, bloom filters are much easier to implement and understand when they support only Insert and Lookup (and no Delete). We’ll focus on this case.

27 Named after their inventor; see the paper “Space/Time Trade-offs in Hash

Coding with Allowable Errors,” by Burton H. Bloom (Communications of the ACM, 1970).

12.5 Bloom Filters: The Basics 179

 

Bloom Filters: Supported Operations

Lookup: for a key k, return “yes” if k has been previously inserted into the bloom filter and “no” otherwise.

Insert: add a new key k to the bloom filter.

 

Bloom filters are very space-efficient; in a typical use case, they might require only 8 bits per insertion. This is pretty incredible, as 8 bits are nowhere near enough to remember even a 32-bit key or a pointer to an object! This is the reason why the Lookup operation in a bloom filter returns only a “yes”/”no” answer, whereas in a hash table the operation returns a pointer to the sought-after object (if found). This is also why the Insert operation now takes only a key, rather than (a pointer to) an object.

Bloom filters can make mistakes, in contrast to all the other data

structures we’ve studied. There are two different kinds of mistakes: false negatives, in which Lookup returns “false” even though the queried key was inserted previously; and false positives, in which Lookup returns “true” even though the queried key was never in-

serted in the past. We’ll see in Section 12.5.3 that basic bloom filters never suffer from false negatives, but they can have “phantom ele-

ments” in the form of false positives. Section 12.6 shows that the frequency of false positives can be controlled by tuning the space usage appropriately. A typical bloom filter implementation might have an error rate of around 1% or 0.1%.

The running times of both the Insert and Lookup operations

are as fast as those in a hash table. Even better, these operations are guaranteed to run in constant time, independent of the bloom filter

implementation and the data set.28 The implementation and data set do affect the filter’s error rate, however.

Summarizing the advantages and disadvantages of bloom filters

over hash tables:

Bloom Filters Vs. Hash Tables

1\. Pro: More space efficient.

 

28 Provided hash function evaluations take constant time and that a constant number of bits is used per inserted key.

180 Hash Tables and Bloom Filters

 

2\. Pro: Guaranteed constant-time operations for every

data set.

3\. Con: Can’t store pointers to objects.

4\. Con: Deletions are complicated, relative to a hash

table with chaining.

5\. Con: Non-zero false positive probability.

The scorecard for the basic bloom filter reads:

Operation Running time

Lookup † O (1)

Insert O(1)

Table 12.4: Basic bloom filters: supported operations and their running times. The dagger ( †) indicates that the Lookup operation suffers from a controllable but non-zero probability of false positives.

 

Bloom filters should be used in place of hash tables in applications in which their advantages matter and their disadvantages are not dealbreakers.

When to Use a Bloom Filter

If your application requires fast lookups with a dynamically changing set of objects, space is at a premium, and a small number of false positives can be tolerated, the bloom filter is usually the data structure of choice.

 

12.5.2 Applications

Next are three applications with repeated lookups where it can be important to save space and where false positives are not a dealbreaker.

Spell checkers. Back in the 1970s, bloom filters were used to implement spell checkers. In a preprocessing step, every word in a dictionary was inserted into a bloom filter. Spell-checking a document boiled down to one Lookup operation per word in the document, flagging any words for which the operation returned “no.”

12.5 Bloom Filters: The Basics 181

 

In this application, a false positive corresponds to an illegal word

that the spell checker inadvertently accepts. Such errors are not ideal. Space was at a premium in the early 1970s, however, so at that time it was a win to use bloom filters.

Forbidden passwords. An old application that remains relevant today is keeping track of forbidden passwords—passwords that are too common or too easy to guess. Initially, all forbidden passwords are inserted into a bloom filter; additional forbidden passwords can be inserted later, as needed. When a user tries to set or reset their password, the system looks up the proposed password in the bloom filter. If the Lookup returns “yes,” the user is asked to try again with a different password. Here, a false positive translates to a strong password that the system rejects. Provided the error rate is not too large, say at most 1% or 0.1%, this is not a big deal. Once in a while, some user will need one extra attempt to find a password acceptable to the system.

Internet routers. Many of today’s killer applications of bloom filters take place in the core of the Internet, where data packets pass through routers at a torrential rate. There are many reasons why a router might want to quickly recall what it has seen in the past. For example, the router might want to look up the source IP address of a packet in a list of blocked IP addresses, keep track of the contents of a cache to avoid spurious cache lookups, or maintain statistics helpful for identifying a denial-of-service attack. The rate of packet arrivals demands super-fast lookups, and limited router memory puts space at a premium. These applications are right in the wheelhouse of a bloom filter.

 

12.5.3 Implementation

Looking under the hood of a bloom filter reveals an elegant implemen-tation. The data structure maintains an n-bit string, or equivalently a length-n array A in which each entry is either 0 or 1. (All en-tries are initialized to 0.) The structure also uses m hash functions h1, h2, . . . , hm , each mapping the universe U of all possible keys to the set {0, 1, 2, . . . , n 1} of array positions. The parameter m is proportional to the number of bits that the bloom filter uses per 182 Hash Tables and Bloom Filters

 

insertion, and is typically a small constant (like 5). 29

Every time a key is inserted into a bloom filter, each of the m hash functions plants a flag by setting the corresponding bit of the array A to 1.

Bloom Filter: Insert (given key k)

for i = 1 to m do

A\[h i(k)\] := 1

 

For example, if m = 3 and h1(k) = 23, h2(k) = 17, and h3(k) = 5, inserting k causes the 5th, 17th, and 23rd bits of the array to be set

to 1 (Figure 12.5).

 

1

 

h 3(k)

k h (k) 2

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-195_1.jpg)

h (k) 1 1

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-195_2.jpg)

1

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-195_3.jpg)

 

Figure 12.5: Inserting a new key k into a bloom filter sets the bits in positions h1(k), . . . , hm(k) to 1.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-195_4.jpg)

 

29 Sections 12.3.6 and 12.4.3 provide guidance for choosing one hash function.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-195_5.jpg)

Footnote 9 describes a quick-and-dirty way of deriving two hash functions from one; the same idea can be used to derive m hash functions from one. An alternative approach, inspired by double hashing, is to use two hash functions h 0 and h to

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-195_6.jpg)

define h1 , h2, . . . , hm via the formula 0 h i ( k ) = ( h ( k ) + ( i 1) · h(k)) mod n. \*12.6 Bloom Filters: Heuristic Analysis 183

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-195_7.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-195_8.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-195_9.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-195_10.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-195_11.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-195_12.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-195_13.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-195_14.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-195_15.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-195_16.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-195_17.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-195_18.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-195_19.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-195_20.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-195_21.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-195_22.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-195_23.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-195_24.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-195_25.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-195_26.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-195_27.jpg)

 

In the Lookup operation, a bloom filter looks for the footprint

that would have been left by k’s insertion.

Bloom Filter: Lookup (given key k)

for i = 1 to m do

if A\[hi(k)\] = 0 then

return “no”

return “yes”

 

We can now see why bloom filters can’t suffer from false negatives.

When a key k is inserted, the relevant m bits are set to 1. Over the bloom filter’s lifetime, bits can change from 0 to 1 but never the reverse. Thus, these m bits remain 1 forevermore. Every subsequent Lookup for k is guaranteed to return the correct answer “yes.”

We can also see how false positives arise. Suppose that m = 3 and

the four keys k1, k2, k3, k4 have the following hash values:

Key Value of h1 Value of h2 Value of h3

k1 23 17 5 k2 5 48 12 k3 37 8 17 k4 32 23 2

Suppose we insert k2, k3, and k4 into the bloom filter (Figure 12.6). These three insertions cause a total of nine bits to be set to 1, including the three bits in k1’s footprint (5, 17, and 23). At this point, the bloom filter can no longer distinguish whether or not k1 has been inserted. Even if k1 was never inserted into the filter, a Lookup for it will return “yes,” which is a false positive.

Intuitively, as we make the bloom filter size n bigger, the number

of overlaps between the footprints of different keys should decrease, in turn leading to fewer false positives. But the first-order goal of a bloom filter is to save on space. Is there a sweet spot where both n and the frequency of false positives are small simultaneously? The answer is not obvious and requires some mathematical analysis, undertaken

in the next section.30

30 Spoiler alert: The answer is yes. For example, using 8 bits per key typically leads to a false positive probability of roughly 2% (assuming well-crafted hash functions and a non-pathological data set).

184 Hash Tables and Bloom Filters

1

h3(k4) 1

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_1.jpg)

 

k 1 4 h 2 (k 4 ) h 1 (k 4 )

h 1 (k )

3 1 h (k )

2 3

k h k h3(k3) 2 (k 1 ) 3

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_2.jpg)

1

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_3.jpg)

h 1(k1) h1(k3) 1

1

h1(k2) 1

h3(k2)

1

k h (k 2 22)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_4.jpg)

1

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_5.jpg)

 

Figure 12.6: False positives: A bloom filter can contain the footprint of a key k1 even if k1 was never inserted.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_6.jpg)

 

\*12.6 Bloom Filters: Heuristic Analysis

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_7.jpg)

The goal of this section is to understand the quantitative trade-off between the space consumption and the frequency of false positives of a bloom filter. That is, how rapidly does the frequency of false positives of a bloom filter decrease as a function of its array length?

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_8.jpg)

If a bloom filter uses a length-n bit array and stores (the footprints of) a set S of keys, the per-key storage in bits is

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_9.jpg)

n

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_10.jpg)

b = .

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_11.jpg)

\|S\|

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_12.jpg)

We’re interested in the case in which b is smaller than the number of bits needed to explicitly store a key or a pointer to an object (which is typically 32 or more). For example, b could be 8 or 16.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_13.jpg)

12.6.1 Heuristic Assumptions

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_14.jpg)

The relationship between the per-key storage b and the frequency of false positives is not easy to guess, and working it out requires \*12.6 Bloom Filters: Heuristic Analysis 185

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_15.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_16.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_17.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_18.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_19.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_20.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_21.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_22.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_23.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_24.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_25.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_26.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_27.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_28.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_29.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_30.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_31.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_32.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_33.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_34.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_35.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-197_36.jpg)

 

some probability calculations. To understand them, all you need to remember from probability theory is:

The probability that two independent events both occur

equals the product of their individual probabilities.

For example, the probability that two independent tosses of a fair

6-sided die are “4” followed by an odd number is 1 3 1 31 = . 6 · 6 12

To greatly simplify the calculations, we’ll make two unjustified

assumptions—the same ones we used in passing in our heuristic

analyses of hash table performance (Section 12.4.1).

Unjustified Assumptions

1\. For every key k 2 U in the data set and hash func-

tion hi of the bloom filter, hi(k) is uniformly dis-tributed, with each of the n array positions equally likely.

2\. All of the hi (k)’s, ranging over all keys k 2 U and

hash functions h1, h2, . . . , hm, are independent random variables.

 

The first assumption says that, for each key k, each hash function hi, and each array position q 2 {0, 1, 2, . . . , n 1}, the probability that hi(k) = q is exactly 1 . The second assumption implies that the n

probability that hi(k1) = q and also hj (k2) = r is the product of the individual probabilities, also known as 1 2 . n

Both assumptions would be legitimate if we randomly chose each

of the bloom filter’s hash functions independently from the set of all

possible hash functions, as in Section 12.3.6. Completely random

hash functions are unimplementable (recall Quiz 12.5), so in practice a fixed, “random-like” function is used. This means that in reality, our heuristic assumptions are false. With fixed hash functions, every value hi(k) is completely determined, with no randomness whatsoever. This is why we call the analysis “heuristic.”

31 For more background on probability theory, see Appendix B of Part 1 or

the Wikibook on discrete probability [(](https://en.wikibooks.org/wiki/High_School_Mathematics_Extensions/Discrete_Probability)[https://en.wikibooks.org/wiki/High\_](https://en.wikibooks.org/wiki/High_School_Mathematics_Extensions/Discrete_Probability)

[School_Mathematics_Extensions/Discrete_Probability).](https://en.wikibooks.org/wiki/High_School_Mathematics_Extensions/Discrete_Probability) 186 Hash Tables and Bloom Filters

 

On Heuristic Analyses

What possible use is a mathematical analysis based

on false premises? Ideally, the conclusion of the anal-

ysis remains valid in practical situations even though

the heuristic assumptions are not satisfied. For bloom

filters, the hope is that, provided the data is non-

pathological and well-crafted “random-like” hash func-

tions are used, the frequency of false positives behaves

as if the hash functions were completely random.

You should always be suspicious of a heuristic

analysis, and be sure to test its conclusions with a

concrete implementation. Happily, empirical studies

demonstrate that the frequency of false positives in

bloom filters in practice is comparable to the predic-

tion of our heuristic analysis.

 

12.6.2 The Fraction of Bits Set to 1

We begin with a preliminary calculation.

 

Quiz 12.7

Suppose a data set S is inserted into a bloom filter that uses m hash functions and a length-n bit array. Under our heuristic assumptions, what is the probability that the array’s first bit is set to 1?

a\) 1 S\| \| n

b\) 1 S\| \| 1 n

c\) 1 m \| \| S 1 n

d\) 1 m\|S\| 1 1 n

(See Section 12.6.5 for the solution and discussion.)

\*12.6 Bloom Filters: Heuristic Analysis 187

 

There is nothing special about the first bit of the bloom filter. By

symmetry, the answer to Quiz 12.7 is also the probability that the 7th, or the 23rd, or the 42nd bit is set to 1.

12.6.3 The False Positive Probability

The solution to Quiz 12.7 is messy. To clean it up, we can use the fact that x e is a good approximation of 1 + x when x is close to 0, where e ⇡ 2.718 . . . is the base of the natural logarithm. This fact is evident from a plot of the two functions:

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-200_1.jpg)

 

For us, the relevant value of 1 x is x = , which is close to 0 (ignoring n the uninteresting case of tiny n). Thus, among friends, we can use the quantity

1 1/n m \| \| \| S m S \| 1 ( e ) as a proxy for 1 1 . n

We can further simplify the left-hand side to

1 m\|S\|/n m/b e = 1 e ,

\| {z }

estimate of probability that a given bit is 1

where n b = denotes the number of bits used per insertion. \| S \|

Fine, but what about the frequency of false positives? A false pos-

itive occurs for a key k not in S when all the m bits h1(k), . . . , hm(k)

in its footprint are set to 1 by the keys in 32 S . Because the probability

32 For simplicity, we’re assuming that each of the m hash functions hashes k to a different position (as is usually the case). 188 Hash Tables and Bloom Filters

 

that a given bit is 1 is approximately m/b 1 e, the probability that all m of these bits are set to 1 is approximately

⇣ m ⌘m

1 e b . (12.2)

\| {z }

estimate of false positive frequency

We can sanity check this estimate by investigating extreme values of b. As the bloom filter grows arbitrarily large (with b ! 1) and is

increasingly empty, the estimate (12.2) goes to 0, as we would hope (because x e goes to 1 as x goes to 0). Conversely, when b is very small, the estimate of the chance of a false positive is large ( ⇡ 63.2%

when b 33 = m = 1 , for example).

12.6.4 The Punchline

We can use our precise estimate (12.2) of the false positive rate to understand the trade-off between space and accuracy. In addition to

the per-key space b, the estimate in (12.2) depends on m, the number of hash functions that the bloom filter uses. The value of m is under complete control of the bloom filter designer, so why not set it to minimize the estimated frequency of errors? That is, holding b fixed,

we can choose m to minimize (12.2). Calculus can identify the best

choice of m, by setting the derivative of (12.2) with respect to m to 0 and solving for m. You can do the calculations in the privacy of your own home, with the end result being that (ln 2) · b ⇡ 0.693 · b is the optimal choice for m. This is not an integer, so round it up or down to get the ideal number of hash functions. For example, when b = 8, the number of hash functions m should be either 5 or 6.

We can now specialize the error estimate in (12.2) with the optimal choice of m = (ln 2) · b to get the estimate

 

⇣ ✓ ◆ ⌘(ln 2)·b (ln 2) · b 1 ln 2 1 e = . 2

33 In addition to our two heuristic assumptions, this analysis cheated twice.

First, 1/n e isn’t exactly equal to 1 1 n, but it’s close. Second, even with our heuristic assumptions, the values of two different bits of a bloom filter are not independent—knowing that one bit is 1 makes it slightly more likely that a different bit is 0—but they are close. Both cheats are close approximations of reality (given the heuristic assumptions), and it can be verified both mathematically and empirically that they lead to an accurate conclusion.

\*12.6 Bloom Filters: Heuristic Analysis 189

 

This is exactly what we wanted all along—a formula that spits out the expected frequency of false positives as a function of the amount of

space we’re willing to use. 34 The formula is decreasing exponentially with the per-key space b, which is why there is a sweet spot where both the bloom filter size and its frequency of false positives are small simultaneously. For example, with only 8 bits per key stored (b = 8), this estimate is slightly over 2%. What if we take b = 16 (see

Problem 12.3)?

12.6.5 Solution to Quiz 12.7

Correct answer: (d). We can visualize the insertion of the keys in S into the bloom filter as the throwing of darts at a dartboard with n regions, with each dart equally likely to land in each region. Because the bloom filter uses m hash functions, each insertion corresponds to the throwing of m darts, for a total of m\|S\| darts overall. A dart hitting the ith region corresponds to setting the ith bit of the bloom filter to 1.

By the first heuristic assumption, for every k 2 S and i 2

{1, 2, . . . , m} , the probability that a dart hits the first region (that

 

is, that hi(k) = 0) is 1 . Thus, the dart misses the first region (that n 1 is, h i ( k ) is not 0) with the remaining probability 1 . By the sec-n ond heuristic assumption, di ff erent darts are independent. Thus, the probability that every dart misses the first region—that hi(k) 6= 0 for every 1 \| k 2 S and m \| S i 2 { 1 , 2 , . . . , m } —is (1 ). With the remaining n 1 1 m \|S\| (1 ) probability, some dart hits the first region (that is, n

the first bit of the bloom filter is set to 1).

The Upshot

P If your application requires fast lookups on an

evolving set of objects, the hash table is usually

the data structure of choice.

P Hash tables support the Insert and Lookup

operations, and in some cases the Delete oper-

 

34 Equivalently, if you have a target false positive rate of ✏, you should take the per-key space to be at least 1 b ⇡ 1 . 44 log 2 ✏ . As expected, the smaller the target error rate ✏, the larger the space requirements. 190 Hash Tables and Bloom Filters

 

ation. With a well-implemented hash table and

non-pathological data, all operations typically

run in O(1) time.

P A hash table uses a hash function to translate

from objects’ keys to positions in an array.

P Two keys k1, k2 collide under a hash function h

if h(k1) = h(k2). Collisions are inevitable, and a hash table needs a method for resolving them,

such as chaining or open addressing.

P A good hash function is cheap to evaluate and

easy to store, and mimics a random function

by spreading non-pathological data sets roughly

evenly across the positions of the hash table’s

array.

P Experts have published good hash functions

that you can use in your own work.

P A hash table should be resized periodically to

keep its load small (for example, less than 70%).

P For mission-critical code, there’s no substitute

for trying out multiple competing hash table

implementations.

P Bloom filters also support the Insert and

Lookup operations in constant time, and are preferable to hash tables in applications in which

space is at a premium and the occasional false

positive is not a dealbreaker.

 

Test Your Understanding

Problem 12.1 (S) Which of the following is not a property you would expect a well-designed hash function to have?

a\) The hash function should spread out every data set roughly

evenly across its range.

Problems 191

 

b\) The hash function should be easy to compute (constant time or

close to it).

c\) The hash function should be easy to store (constant space or

close to it).

d\) The hash function should spread out most data sets roughly

evenly across its range.

 

Problem 12.2 (S) A good hash function mimics the gold standard of a random function for all practical purposes, so it’s interesting to investigate collisions with a random function. If the locations of two different keys k1, k2 2 U are chosen independently and uniformly at random across n array positions (with all possibilities equally likely), what is the probability that k1 and k2 will collide?

a\) 0

b\) 1 n

c\) 2 n ( n 1)

d\) 1 2 n

Problem 12.3 We interpreted our heuristic analysis of bloom filters

in Section 12.6 by specializing it to the case of 8 bits of space per key inserted into the filter. Suppose we were willing to use twice as much space (16 bits per insertion). What can you say about the corresponding false positive rate, according to our heuristic analysis, assuming that the number m of hash tables is set optimally? (Choose the strongest true statement.)

a\) The false positive rate would be less than 1%.

b\) The false positive rate would be less than 0.1%.

c\) The false positive rate would be less than 0.01%.

d\) The false positive rate would be less than 0.001%.

192 Hash Tables and Bloom Filters

 

Programming Problems

Problem 12.4 Implement in your favorite programming language

the hash table-based solution to the 2-SUM problem in Section 12.2.2. For example, you could generate a list S of one million random integers between 11 11 10 and 10, and count the number of targets t between

10000 and 10000 for which there are distinct x, y 2 S with x + y = t.

You can use existing implementations of hash tables, or you can implement your own from scratch. In the latter case, compare your performance under different collision-resolution strategies, such as

chaining vs. linear probing. (See [www.algorithmsilluminated.org](http://www.algorithmsilluminated.org) for test cases and challenge data sets.)