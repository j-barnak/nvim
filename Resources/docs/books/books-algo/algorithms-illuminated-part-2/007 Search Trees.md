## Chapter 11

 

Search Trees

 

A search tree, like a heap, is a data structure for storing an evolving set of objects associated with keys (and possibly lots of other data). It maintains a total ordering over the stored objects, and can support a richer set of operations than a heap, at the expense of increased space and, for some operations, somewhat slower running times. We’ll start with the “what” (that is, supported operations) before proceeding to the “why” (applications) and the “how” (optional implementation details).

 

11.1 Sorted Arrays

A good way to think about a search tree is as a dynamic version of a sorted array—it can do everything a sorted array can do, while also accommodating fast insertions and deletions.

11.1.1 Sorted Arrays: Supported Operations

You can do a lot of things with a sorted array.

Sorted Arrays: Supported Operations

Search: for a key k, return a pointer to an object in the data structure with key k (or report that no such object exists).

Min (Max): return a pointer to the object in the data structure with the smallest (respectively, largest) key.

Predecessor (Successor): given a pointer to an object in the data structure, return a pointer to the object with

 

126

11.1 Sorted Arrays 127

 

the next-smallest (respectively, next-largest) key. If the given object has the minimum (respectively, maximum) key, report “none.”

OutputSorted: output the objects in the data structure one by one in order of their keys.

Select: given a number i, between 1 and the number of objects, return a pointer to the object in the data structure with the ith-smallest key.

Rank: given a key k, return the number of objects in the data structure with key at most k.

Let’s review how to implement each of these operations, with the

following running example:

 

3 6 10 11 17 23 30 36

 

• The Search operation uses binary search: First check if the

object in the middle position of the array has the desired key. If so, return it. If not, recurse either on the left half (if the middle object’s key is too large) or on the right half (if it’s too

small). 1 For example, to search the array above for the key 8, binary search will: examine the fourth object (with key 11); recurse on the left half (the objects with keys 3, 6, and 10); check the second object (with key 6); recurse on the right half of the remaining array (the object with key 10); conclude that the rightful position for an object with key 8 would be between the second and third objects; and report “none.” As each recursive call cuts the array size by a factor of 2, there are at most log n 2 recursive calls, where n is the length of the array. Because each recursive call does a constant amount of work, the operation runs in O(log n) time.

1 Readers of at least a certain age should be reminded of searching for a phone

number in a phone book. If you haven’t walked through the code of this algorithm before, look it up in your favorite introductory programming book or tutorial. 128 Search Trees

 

• Min and Max are easy to implement in O(1) time: Return a

pointer to the first or last object in the array, respectively.

• To implement Predecessor or Successor, use the Search

operation to recover the position of the given object in the sorted array, and return the object in the previous or next position, respectively. These operations are as fast as Search—running in O(log n) time, where n is the length of the array.

• OutputSorted The operation is trivial to implement in linear

time with a sorted array: Perform a single front-to-back pass over the array, outputting each object in turn.

• Select is easy to implement in constant time: Given an index i,

return the object in the ith position of the array.

• The Rank operation, which is like an inverse of Select, can be

implemented along the same lines as Search: If binary search finds an object with key k in the ith position of the array, or if it discovers that k is in between the keys of the objects in the

i 2 th and ( i + 1) th positions, the correct answer is i .

Summarizing, here’s the final scorecard for sorted arrays:

 

Operation Running time

Search O(log n)

Min O(1)

Max O(1)

Predecessor O(log n)

Successor O(log n)

OutputSorted O(n)

Select O(1)

Rank O(log n)

Table 11.1: Sorted arrays: supported operations and their running times, where n denotes the current number of objects stored in the array.

 

2 This description assumes, for simplicity, that there are no duplicate keys. What changes are necessary to accommodate multiple objects with the same key? 11.2 Search Trees: Supported Operations 129

 

11.1.2 Unsupported Operations

Could you really ask for anything more? With a static data set that does not change over time, this is an impressive list of supported operations. Many real-world applications are dynamic, however, with the set of relevant objects evolving over time. For example, employees come and go, and the data structure that stores their records should stay up to date. For this reason, we also care about insertions and deletions.

Sorted Arrays: Unsupported Operations

Insert: given a new object x, add x to the data structure.

Delete: for a key k, delete an object with key k from the

data structure, if one exists.3

 

These two operations aren’t impossible to implement with a sorted array, but they’re painfully slow—inserting or deleting an element while maintaining the sorted array property requires linear time in the worst case. Is there an alternative data structure that replicates all the functionality of a sorted array, while matching the logarithmic-time performance of a heap for the Insert and Delete operations?

 

11.2 Search Trees: Supported Operations

The raison d’être of a search tree is to support all the operations that a sorted array supports, plus insertions and deletions. All the operations except OutputSorted run in O(log n) time, where n is the number of objects in the search tree. The OutputSorted operation runs in O(n) time, and this is as good as it gets (since it must output n objects).

Here’s the scorecard for search trees, with a comparison to sorted

arrays:

3 The eagle-eyed reader may have noticed that this specification of the Delete

operation (which takes a key as input) is different from the one for heaps (which takes a pointer to an object as input). This is because heaps do not support fast search. In a sorted array (as well as in search trees and hash tables), it’s easy to recover a pointer to an object given its key (via Search). 130 Search Trees

 

Operation Sorted Array Balanced Search Tree

Search O(log n) O(log n)

Min O(1) O(log n) Max O(1) O(log n)

Predecessor O(log n) O(log n)

Successor O(log n) O(log n)

OutputSorted O(n) O(n)

Select O(1) O(log n)

Rank O(log n) O(log n)

Insert O(n) O(log n)

Delete O(n) O(log n)

Table 11.2: Balanced search trees vs. sorted arrays: supported operations and their running times, where n denotes the current number of objects stored in the data structure.

 

An important caveat: The running times in Table 11.2 are achieved by a balanced search tree, which is a more sophisticated version of the

standard binary search tree described in Section 11.3. These running

times are 4 not guaranteed by an unbalanced search tree.

When to Use a Balanced Search Tree

If your application requires maintaining an ordered represen-tation of a dynamically changing set of objects, the balanced

search tree (or a data structure based on one5) is usually

the data structure of choice.6

 

4 A preview of Sections 11.3 and 11.4: In general, search tree operations run in time proportional to the height of the tree, meaning the longest path from the tree’s root to one of its leaves. In a binary tree with n nodes, the height can be anywhere from ⇡ log n 1 2 (if the tree is perfectly balanced) to n (if the nodes form a single chain). Balanced search trees do a modest amount of extra work to ensure that the height is always O(log n); this height guarantee then leads to the

running time bounds in Table 11.2.

5 For example, the TreeMap class in Java and the map class template in the

C++ Standard Template Library are built on top of balanced search trees. 6 One good place to see balanced search trees in the wild is in the Linux kernel. For example, they are used to manage the scheduling of processes, and to keep track of the virtual memory footprint of each process.

\*11.3 Implementation Details 131

 

Remember the principle of parsimony: Choose the simplest data structure that supports all the operations required by your application. If you need to maintain only an ordered representation of a static data set (with no insertions or deletions), use a sorted array instead of a balanced search tree; the latter would be overkill. If your data set is dynamic but you care only about fast minimum (or maximum) operations, use a heap instead of a balanced search tree. These simpler data structures do less than a balanced search tree, but what they do, they do better—faster (by a constant or logarithmic factor) and

with less space (by a constant factor).7

 

\*11.3 Implementation Details

This section provides a high-level description of a typical implementa-

tion of a (not necessarily balanced) binary search tree. Section 11.4 touches on some of the extra ideas needed for balanced search trees.

11.3.1 The Search Tree Property

In a binary search tree, every node corresponds to an object (with a key) and has three pointers associated with it: a parent pointer, a left child pointer, and a right child pointer. Any of these pointers can be null, indicating the absence of a parent or child. The left subtree of a node x comprises the nodes reachable from x via its left child pointer, and similarly for the right subtree. The defining search tree property

is:8

The Search Tree Property

1\. For every object x, objects in x’s left subtree have

keys smaller than that of x.

2\. For every object x, objects in x’s right subtree have

keys larger than that of x 9 .

 

7 Chapter 12 covers hash tables, which do still less; but what they do, they do

even better (constant time, for all practical purposes). 8 We refer to nodes and the corresponding objects interchangeably.

9 This assumes no two objects have the same key. To accommodate duplicate

keys, change the “smaller than” in the first condition to “smaller than or equal to.” 132 Search Trees

 

The search tree property imposes a requirement for every node of a search tree, not just for the root:

 

toward the root

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-145_1.jpg)

### *x* 

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-145_2.jpg)

 

all keys all keys

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-145_3.jpg)

\< x \> x

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-145_4.jpg)

 

For example, here’s a search tree containing objects with the keys {1, 2, 3, 4, 5}, and a table listing the destinations of the three pointers at each node:

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-145_5.jpg)

root 3 Node Parent Left Right

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-145_6.jpg)

1 3 null 2

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-145_7.jpg)

1 2 1 null null 5

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-145_8.jpg)

3 null 1 5 4 5 null null

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-145_9.jpg)

leaves 2 4 5 3 4 null

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-145_10.jpg)

(a) Search tree (b) Pointers

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-145_11.jpg)

Figure 11.1: A search tree and its corresponding parent and child pointers.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-145_12.jpg)

 

Binary search trees and heaps differ in several ways. Heaps can be thought of as trees, but they are implemented as arrays, with no explicit pointers between objects. A search tree explicitly stores three pointers per object, and hence uses more space (by a constant factor). Heaps don’t need explicit pointers because they always correspond to full binary trees, while binary search trees can have an arbitrary structure.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-145_13.jpg)

Search trees have a different purpose than heaps. For this reason, the search tree property is incomparable to the heap property. Heaps \*11.3 Implementation Details 133

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-145_14.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-145_15.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-145_16.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-145_17.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-145_18.jpg)

 

are optimized for fast minimum computations, and the heap property— that a child’s key is only bigger than its parent’s key—makes the minimum-key object easy to find (it’s the root). Search trees are optimized for—wait for it—search, and the search tree property is defined accordingly. For example, if you are searching for an object with the key 23 in a search tree and the root’s key is 17, you know that the object can reside only in the root’s right subtree, and can discard the objects in the left subtree from further consideration. This should remind you of binary search, as befits a data structure whose raison d’être is to simulate a dynamically changing sorted array.

11.3.2 The Height of a Search Tree

Many different search trees exist for a given set of keys. Here’s a second search tree containing objects with the keys {1, 2, 3, 4, 5}:

5

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-146_1.jpg)

4

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-146_2.jpg)

3

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-146_3.jpg)

2

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-146_4.jpg)

1

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-146_5.jpg)

Both conditions in the search tree property hold, the second one vacuously (as there are no non-empty right subtrees).

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-146_6.jpg)

The height of a tree is defined as the length of a longest path from

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-146_7.jpg)

its root to a leaf.10 Different search trees containing identical sets of objects can have different heights, as in our first two examples (which have heights 2 and 4, respectively). In general, a binary search tree containing n objects can have a height anywhere from

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-146_8.jpg)

 

perfectly balanced binary tree ⇡ log n n 1. 2 to \| {z } \| {z } chain, as above (worst-case scenario) (best-case scenario)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-146_9.jpg)

The rest of this section outlines how to implement all the operations

of a binary search tree in time proportional to the tree’s height (save

10 Also known as the depth of the tree.

134 Search Trees

 

OutputSorted , which runs in time linear in n). For the refinements of binary search trees that are guaranteed to have height O(log n) (see

Section 11.4), this leads to the logarithmic running times reported in

the scorecard in Table 11.2.

11.3.3 Implementing Search in O(height) Time

Let’s begin with the Search operation:

for a key k, return a pointer to an object in the data structure with key k (or report that no such object exists).

The search tree property tells you exactly where to look for an object with key k. If k is less than (respectively, greater than) the root’s key, such an object must reside in the root’s left subtree (respectively, right tree). To search, follow your nose: Start at the root and repeatedly go left or right (as appropriate) until you find the desired object (a successful search) or encounter a null pointer (an unsuccessful search).

For example, suppose we search for an object with key 2 in our first binary search tree:

3

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-147_1.jpg)

 

1 5

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-147_2.jpg)

 

2 4

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-147_3.jpg)

 

Because the root’s key (3) is too big, the first step traverses the left child pointer. Because the next node’s key is too small (1), the second step traverses the right child pointer, arriving at the desired object. If we search for an object with key 6, the search traverses the root’s right child pointer (as the root’s key is too small). Because the next node’s key (5) is also too small, the search tries to follow another right child pointer, encounters a null pointer, and halts the search (unsuccessfully).

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-147_4.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-147_5.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-147_6.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-147_7.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-147_8.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-147_9.jpg)

\*11.3 Implementation Details 135

 

Search

1\. Start at the root node.

2\. Repeatedly traverse left and right child pointers, as

appropriate (left if k is less than the current node’s key, right if k is bigger).

3\. Return a pointer to an object with key k (if found) or

“none” (upon reaching a null pointer).

 

The running time is proportional to the number of pointers followed, which is at most the height of the search tree (plus 1, if you count the final null pointer of an unsuccessful search).

11.3.4 Implementing Min and Max in O(height) Time

The search tree property makes it easy to implement the Min and Max operations.

Min (Max): return a pointer to the object in the data structure with the smallest (respectively, largest) key.

Keys in the left subtree of the root can only be smaller than the root’s key, and keys in the right subtree can only be larger. If the left subtree is empty, the root must be the minimum. Otherwise, the minimum of the left subtree is also the minimum of the entire tree. This suggests following the root’s left child pointer and repeating the process.

For example, in the search trees we considered earlier:

5

3 4

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-148_1.jpg)

3

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-148_2.jpg)

1 5

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-148_3.jpg)

2

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-148_4.jpg)

minimum

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-148_5.jpg)

2 4 1 minimum

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-148_6.jpg)

repeatedly following left child pointers leads to the object with the minimum key.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-148_7.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-148_8.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-148_9.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-148_10.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-148_11.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-148_12.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-148_13.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-148_14.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-148_15.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-148_16.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-148_17.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-148_18.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-148_19.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-148_20.jpg)

136 Search Trees

 

Min (Max)

1\. Start at the root node.

2\. Traverse left child pointers (right child pointers) as

long as possible, until encountering a null pointer.

3\. Return a pointer to the last object visited.

 

The running time is proportional to the number of pointers followed, which is O(height).

 

11.3.5 Implementing Predecessor in O(height) Time

Next is the Predecessor operation; the implementation of the Successor operation is analogous.

 

Predecessor : given a pointer to an object in the data structure, return a pointer to the object with the next-

smallest key. (If the object has the minimum key, report

“none.”)

 

Given an object x, where could x’s predecessor reside? Not in x’s right subtree, where all the keys are larger than x’s key (by the search tree property). Our running example

 

3

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-149_1.jpg)

 

1 5

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-149_2.jpg)

 

2 4

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-149_3.jpg)

 

illustrates two cases. The predecessor might appear in the left subtree (as for the nodes with keys 3 and 5), or it could be an ancestor farther up in the tree (as for the nodes with keys 2 and 4).

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-149_4.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-149_5.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-149_6.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-149_7.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-149_8.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-149_9.jpg)

\*11.3 Implementation Details 137

 

The general pattern is: If an object x’s left subtree is non-empty,

this subtree’s maximum element is x 11 ’s predecessor; otherwise, x’s predecessor is the closest ancestor of x that has a smaller key than x. Equivalently, tracing parent pointers upward from x, it is the desti-

nation of the first left turn.12 For example, in the search tree above, tracing parent pointers upward from the node with key 4 first takes a right turn (leading to a node with the bigger key 5) and then takes a left turn, arriving at the correct predecessor (3). If x has an empty left subtree and no left turns above it, then it is the minimum in the search tree and has no predecessor (like the node with key 1 in the search tree above).

Predecessor

1\. If x’s left subtree is non-empty, return the result of

Max applied to this subtree.

2\. Otherwise, traverse parent pointers upward toward

the root. If the traversal visits consecutive nodes y and z with y a right child of z, return a pointer to z.

3\. Otherwise, report “none.”

 

The running time is proportional to the number of pointers followed, which in all cases is O(height).

11.3.6 Implementing OutputSorted in O(n) Time

Recall the OutputSorted operation:

OutputSorted : output the objects in the data structure one by one in order of their keys.

A lazy way to implement this operation is to first use the Min opera-tion to output the object with the minimum key, and then repeatedly

11 Among the keys less than x’s, the ones in x’s left subtree are the closest to x (as you should check). Among the keys in this subtree, the maximum is the closest

to x. 12 Right turns can lead only to nodes with larger keys, which cannot be x’s predecessor. The search tree property also implies that neither more distant ancestors nor non-ancestors can be x’s predecessor (as you should check). 138 Search Trees

 

invoke the Successor operation to output the rest of the objects in order. A better method is to use what’s called an in-order traversal of the search tree, which recursively processes the root’s left subtree, then the root, and then the root’s right subtree. This idea meshes perfectly with the search tree property, which implies that Output-Sorted should first output the objects in the root’s left subtree in order, followed by the object at the root, followed by the objects in the root’s right subtree in order.

 

OutputSorted

1\. Recursively call OutputSorted on the root’s left

subtree.

2\. Output the object at the root.

3\. Recursively call OutputSorted on the root’s right

subtree.

 

For a tree containing n objects, the operation performs n recursive calls (one initiated at each node) and does a constant amount of work in each, for a total running time of O(n).

 

11.3.7 Implementing Insert in O(height) Time

None of the operations discussed so far modify the given search tree, so they run no risk of screwing up the crucial search tree property. Our next two operations—Insert and Delete—make changes to the tree, and must take care to preserve the search tree property.

 

Insert : given a new object x, add x to the data structure.

 

The Insert operation piggybacks on Search. An unsuccessful search for an object with key k locates where such an object would have appeared. This is the appropriate place to stick a new object with key k (rewiring the old null pointer). In our running example, the correct location for a new object with key 6 is the spot where our unsuccessful search concluded:

\*11.3 Implementation Details 139

 

3 3

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-152_1.jpg)

1 5 1 5

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-152_2.jpg)

 

2 4 2 4 6

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-152_3.jpg)

 

What if there is already an object with key k in the tree? If you want to avoid duplicate keys, the insertion can be ignored. Otherwise, the search follows the left child of the existing object with key k, pushing onward until a null pointer is encountered.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-152_4.jpg)

Insert

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-152_5.jpg)

1\. Start at the root node.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-152_6.jpg)

2\. Repeatedly traverse left and right child pointers, as

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-152_7.jpg)

appropriate (left if k is at most the current node’s key, right if it’s bigger), until a null pointer is encountered.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-152_8.jpg)

3\. Replace the null pointer with one to the new object.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-152_9.jpg)

Set the new node’s parent pointer to its parent, and

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-152_10.jpg)

its child pointers to null.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-152_11.jpg)

 

The operation preserves the search tree property because it places

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-152_12.jpg)

the new object where it should have been.13 The running time is the same as for Search, which is O(height).

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-152_13.jpg)

11.3.8 Implementing Delete in O(height) Time

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-152_14.jpg)

In most data structures, the Delete operation is the toughest one to get right. Search trees are no exception.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-152_15.jpg)

Delete : for a key k, delete an object with key k from the search tree, if one exists.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-152_16.jpg)

13 More formally, let x denote the newly inserted object and consider an existing object y. If x is not a member of the subtree rooted at y, then it cannot interfere with the search tree property at y. If it is a member of the subtree rooted at y, then y was one of the nodes visited during the unsuccessful search for x. The keys of x and y were explicitly compared in this search, with x placed in y’s left subtree if and only if its key is no larger than y’s. 140 Search Trees

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-152_17.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-152_18.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-152_19.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-152_20.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-152_21.jpg)

 

The main challenge is to repair a tree after a node removal so that the search tree property is restored.

The first step is to invoke Search to locate an object x with key k. (If there is no such object, Delete has nothing to do.) There are three cases, depending on whether x has 0, 1, or 2 children. If x is a leaf, it can be deleted without harm. For example, if we delete the node with key 2 from our favorite search tree:

3 3

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_1.jpg)

 

1 5 1 5

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_2.jpg)

 

delete 2 4 4

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_3.jpg)

 

For every remaining node y, the nodes in y’s subtrees are the same as before, except possibly with x removed; the search tree property continues to hold.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_4.jpg)

When x has one child y, we can splice it out. Deleting x leaves y without a parent and x’s old parent z without one of its children. The

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_5.jpg)

obvious fix is to let y 14 assume x ’s previous position (as z ’s child).

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_6.jpg)

For example, if we delete the node with key 5 from our favorite search tree:

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_7.jpg)

3 3

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_8.jpg)

 

1 delete 5 1 4

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_9.jpg)

 

2 4 2

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_10.jpg)

 

By the same reasoning as in the first case, the search property is preserved.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_11.jpg)

The hard case is when x has two children. Deleting x leaves two nodes without a parent, and it’s not clear where to put them. In our running example, it’s not obvious how to repair the tree after deleting its root.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_12.jpg)

14 Insert your favorite nerdy Shakespeare joke here. . . \*11.3 Implementation Details 141

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_13.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_14.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_15.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_16.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_17.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_18.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_19.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_20.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_21.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_22.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_23.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_24.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_25.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_26.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_27.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_28.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_29.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_30.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_31.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_32.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_33.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_34.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_35.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-153_36.jpg)

 

The key trick is to reduce the hard case to one of the easy ones.

First, use the Predecessor operation to compute the predecessor y

of 15 x . Because x has two children, its predecessor is the object in its

(non-empty!) left subtree with the maximum key (see Section 11.3.5). Since the maximum is computed by following right child pointers as

long as possible (see Section 11.3.4), y cannot have a right child; it might or might not have a left child.

Here’s a crazy idea: Swap x and y! In our running example, with

the root node acting as x:

delete 3 2

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_1.jpg)

1 5 1 5

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_2.jpg)

 

predecessor 2 4 3 4

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_3.jpg)

 

This crazy idea looks like a bad one, as we’ve now violated the search tree property (with the node with key 3 in the left subtree of the node with key 2). But every violation of the search tree property

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_4.jpg)

involves the node x 16 , which we’re going to delete anyway. Because x now occupies y’s previous position, it no longer has a right child. Deleting x from its new position falls into one of the two easy cases: We delete it if it also has no left child, and splice it out if it does have a left child. Either way, with x out of the picture, the search tree property is restored. Back to our running example:

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_5.jpg)

2 2

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_6.jpg)

 

1 5 1 5

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_7.jpg)

 

delete 4 3 4

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_8.jpg)

 

15 The successor also works fine, if you prefer.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_9.jpg)

16 For every node z other than y, the only possible new node in z’s subtree is x. Meanwhile y, as x’s immediate predecessor in the sorted ordering of all keys, has a key larger than those in x’s old left subtree and greater than those in x’s old right subtree. Thus, the search tree condition holds for y in its new position, except with respect to x.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_10.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_11.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_12.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_13.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_14.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_15.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_16.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_17.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_18.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_19.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_20.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_21.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_22.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_23.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_24.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_25.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_26.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_27.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_28.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_29.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_30.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_31.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_32.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_33.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_34.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_35.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_36.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_37.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_38.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-154_39.jpg)

142 Search Trees

 

Delete

1\. Use Search to locate an object x with key k. (If no

such object exists, halt.)

2\. If x has no children, delete x by setting the appropriate

child pointer of x’s parent to null. (If x was the root, the new tree is empty.)

3\. If x has one child, splice x out by rewiring the appro-

priate child pointer of x’s parent to x’s child, and the parent pointer of x’s child to x’s parent. (If x was the root, its child becomes the new root.)

4\. Otherwise, swap x with the object in its left subtree

that has the biggest key, and delete x from its new position (where it has at most one child).

 

The operation performs a constant amount of work in addition to one Search and one Predecessor operation, so it runs in O(height) time.

 

11.3.9 Augmented Search Trees for Select

Finally, the Select operation:

 

Select : given a number i, between 1 and the number of objects, return a pointer to the object in the data structure

with the ith-smallest key.

 

To get Select to run quickly, we’ll augment the search tree by having each node keep track of information about the structure of the tree

itself 17 , and not just about an object. Search trees can be augmented in many ways; here, we’ll store at each node x an integer size(x) indicating the number of nodes in the subtree rooted at x (including x itself). In our running example

17 This idea can also be used to implement the Rank operation in O(height)

time (as you should check).

\*11.3 Implementation Details 143

 

*size(3)=5* 3

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-156_1.jpg)

 

1 *size(1)=2* *size(5)=2* 5

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-156_2.jpg)

 

*size(2)=1* 2 4 *size(4)=1*

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-156_3.jpg)

 

we have size(1) = 2, size(2) = 1, size(3) = 5, size(4) = 1, and size(5) = 2.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-156_4.jpg)

 

Quiz 11.1

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-156_5.jpg)

Suppose the node x in a search tree has children y and z. What is the relationship between size(x), size(y), and size(z)?

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-156_6.jpg)

a\) size(x) = max{size(y), size(z)} + 1

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-156_7.jpg)

b\) size(x) = size(y) + size(z)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-156_8.jpg)

c\) size(x) = size(y) + size(z) + 1

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-156_9.jpg)

d\) There is no general relationship.

(See Section 11.3.10 for the solution and discussion.)

 

How is this additional information helpful? Imagine you’re looking

for the object with the 17th-smallest key (i.e., i = 17) in a search tree with 100 objects. Starting at the root, you can compute in constant time the sizes of its left and right subtrees. By the search tree property, every key in the left subtree is less than those at the root and in the right subtree. If the population of the left subtree is 25, these are the 25 smallest keys in the tree, including the 17th-smallest key. If its population is only 12, the right subtree contains all but the 13 smallest keys, and the 17th-smallest key is the 4th-smallest among its 87 keys. Either way, we can call Select recursively to locate the desired object.

144 Search Trees

 

Select

1\. Start at the root and let j be the size of its left subtree.

(If it has no left child pointer, then j = 0.)

2\. If i = j + 1, return a pointer to the root.

3\. If i \< j + 1, recursively compute the ith-smallest key

in the left subtree.

4\. If i \> j + 1, recursively compute the (i j 1)th

smallest key in the right subtree.18

 

Because each node of the search tree stores the size of its subtree, each recursive call performs only a constant amount of work. Each recursive call proceeds further downward in the tree, so the total amount of work is O(height).

Paying the piper. We still have to pay the piper. We’ve added and exploited metadata to the search tree, and every operation that modifies the tree must take care to keep this information up to date, in addition to preserving the search tree property. You should think through how to re-implement the Insert and Delete operations, still running in O(height) time, so that all the subtree sizes remain

accurate.19

 

11.3.10 Solution to Quiz 11.1

Correct answer: (c). Every node in the subtree rooted at x is either x itself, or a node in x’s left subtree, or a node in x’s right subtree. We therefore have

 

size(x) = size(y) + size(z) + 1 . \|{z} \| {z } \| {z } x

nodes in left subtree nodes in right subtree

 

18 The structure of the recursion might remind you of our selection algorithms

in Chapter 6 of Part 1, with the root node playing the role of the pivot element.

19 For example, for the Insert operation, increment the subtree size for every

node on the path between the root and the newly inserted object.

\*11.4 Balanced Search Trees 145

 

\*11.4 Balanced Search Trees

11.4.1 Working Harder for Better Balance

The running time of every binary search tree operation (save Out-putSorted) is proportional to the tree’s height, which can range anywhere from the best-case scenario of ⇡ log n 2 (for a perfectly bal-anced tree) to the worst-case scenario of n 1 (for a chain), where n is the number of objects in the tree. Badly unbalanced search trees really can occur, for example when objects are inserted in sorted or reverse sorted order:

5

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-158_1.jpg)

4

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-158_2.jpg)

3

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-158_3.jpg)

2

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-158_4.jpg)

1

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-158_5.jpg)

 

The difference between a logarithmic and a linear running time is huge, so it’s a win to work a little harder in Insert and Delete—still O(height) time, but with a larger constant factor—to guarantee that the tree’s height is always O(log n).

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-158_6.jpg)

Several different types of balanced search trees guarantee O(log n)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-158_7.jpg)

height and, hence, achieve the operation running times stated in the

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-158_8.jpg)

scorecard in Table 11.2.20 The devil is in the implementation details, and they can get pretty tricky for balanced search trees. Happily, implementations are readily available and it’s unlikely that you’ll ever need to code up your own version from scratch. I encourage readers interested in what’s under the hood of a balanced search tree to check out a textbook treatment or explore the open-source implementations

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-158_9.jpg)

and visualization demos that are freely available online.21 To whet

20 Popular ones include red-black trees, 2-3 trees, AVL trees, splay trees, and B and B+ trees.

21 Standard textbook treatments include Chapter 13 of Introduction to Algo-rithms (Third Edition), by Thomas H. Cormen, Charles E. Leiserson, Ronald L. Rivest, and Clifford Stein (MIT Press, 2009); and Section 3.3 of Algorithms (Fourth Edition), by Robert Sedgewick and Kevin Wayne (Addison-Wesley, 2011). 146 Search Trees

 

your appetite for further study, let’s conclude the chapter with one of the most ubiquitous ideas in balanced search tree implementations.

 

11.4.2 Rotations

All the most common implementations of balanced search trees use rotations, a constant-time operation that performs a modest amount of local rebalancing while preserving the search tree property. For example, we could imagine transforming the chain of five objects above into a more civilized search tree by composing two local rebalancing operations:

5

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-159_1.jpg)

4 4 3

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-159_2.jpg)

rotate rotate 3 5 2

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-159_3.jpg)

3 4

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-159_4.jpg)

2 2 5 1

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-159_5.jpg)

1

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-159_6.jpg)

1

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-159_7.jpg)

 

A rotation takes a parent-child pair and reverses their relationship

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-159_8.jpg)

(Figure 11.2). A right rotation applies when the child y is the left child of its parent x (and so y has a smaller key than x); after the rotation, x is the right child of y. When y is the right child of x, a left rotation makes x the left child of y.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-159_9.jpg)

The search tree property dictates the remaining details. For example, consider a left rotation, with y the right child of x. The search tree property implies that x’s key is less than y’s; that all the

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-159_10.jpg)

keys in x’s left subtree (“A” in Figure 11.2) are less than that of x

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-159_11.jpg)

(and y); that all the keys in y’s right subtree (“C” in Figure 11.2) are greater than that of y (and x); and that all the keys in y’s left subtree

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-159_12.jpg)

(“B” in Figure 11.2) are between those of x and y. After the rotation, y inherits x’s old parent and has x as its new left child. There’s a unique way to put all the pieces back together while preserving the search tree property, so let’s just follow our nose.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-159_13.jpg)

There are three free slots for the subtrees A, B, and C: y’s right child pointer and both child pointers of x. The search tree property

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-159_14.jpg)

See also the bonus videos at [www.algorithmsilluminated.org](http://www.algorithmsilluminated.org) for the basics of red-black trees.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-159_15.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-159_16.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-159_17.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-159_18.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-159_19.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-159_20.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-159_21.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-159_22.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-159_23.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-159_24.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-159_25.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-159_26.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-159_27.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-159_28.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-159_29.jpg)

\*11.4 Balanced Search Trees 147

 

toward the root toward the root

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_1.jpg)

*x* *y*

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_2.jpg)

*y* *x*

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_3.jpg)

all keys C A

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_4.jpg)

\< x

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_5.jpg)

B C A B

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_6.jpg)

all keys all keys

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_7.jpg)

between x and y \> y

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_8.jpg)

(a) Before rotation (b) After rotation

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_9.jpg)

Figure 11.2: A left rotation in action.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_10.jpg)

 

forces us to stick the smallest subtree (A) as x’s left child, and the largest subtree (C) as y’s right child. This leaves one slot for subtree B (x’s right child pointer), and fortunately the search tree property works out: All the subtree’s keys are wedged between those of x and y, and the subtree winds up in y’s left subtree (where it needs to be) and x’s right subtree (ditto).

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_11.jpg)

A right rotation is then a left rotation in reverse (Figure 11.3).

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_12.jpg)

 

toward the root

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_13.jpg)

*x* toward the root

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_14.jpg)

*y*

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_15.jpg)

*y*

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_16.jpg)

### *x* 

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_17.jpg)

C

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_18.jpg)

all keys A

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_19.jpg)

\> x

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_20.jpg)

all keys A B C all keys B

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_21.jpg)

\< y between y and x

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_22.jpg)

(a) Before rotation (b) After rotation

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_23.jpg)

Figure 11.3: A right rotation in action.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_24.jpg)

 

Because a rotation merely rewires a few pointers, it can be imple-

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_25.jpg)

mented with a constant number of operations. By construction, it preserves the search tree property.

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_26.jpg)

The operations that modify the search tree—Insert and Delete— 148 Search Trees

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_27.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_28.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_29.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_30.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_31.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_32.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_33.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_34.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_35.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_36.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_37.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_38.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_39.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_40.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_41.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_42.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_43.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_44.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_45.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_46.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_47.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_48.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_49.jpg)

![](/tmp/audit/iter1/epubregen/algorithms-illuminated-part-2/media/index-160_50.jpg)

 

are the ones that must employ rotations. Without rotations, such an operation might render the tree a little more unbalanced. Since a single insertion or deletion can wreak only so much havoc, it should be plausible that a small—constant or perhaps logarithmic—number of rotations can correct any newly created imbalance. This is ex-actly what the aforementioned balanced search tree implementations do. The extra work from rotations adds O(log n) overhead to the Insert and Delete operations, leaving their overall running times at O(log n).

The Upshot

P If your application requires maintaining a to-

tally ordered representation of an evolving set

of objects, the balanced search tree is usually

the data structure of choice.

P Balanced search trees support the operations

Search, Min, Max, Predecessor, Succes-sor, Select, Rank, Insert, and Delete in O(log n) time, where n is the number of objects.

P A binary search tree has one node per object,

each with a parent pointer, a left child pointer,

and a right child pointer.

P The search tree property states that, at every

node x of the tree, the keys in x’s left subtree are smaller than x’s key, and the keys in x’s right subtree are larger than x’s key.

P The height of a search tree is the length of a

longest path from its root to a leaf. A binary

search tree with n objects can have height any-where from ⇡ log n 2 to n 1.

P In a basic binary search tree, all the sup-

ported operations above can be implemented in

O(height) time. (For Select and Rank, after Problems 149

 

augmenting the tree to maintain subtree sizes

at each node.)

P Balanced binary search trees do extra work

in the Insert and Delete operations—still O(height) time, but with a larger constant factor—to guarantee that the tree’s height is

always O(log n).

 

Test Your Understanding

Problem 11.1 (S) Which of the following statements are true? (Check all that apply.)

a\) The height of a binary search tree with n nodes cannot be

smaller than ⇥(log n).

b\) All the operations supported by a binary search tree (except

OutputSorted) run in O(log n) time.

c\) The heap property is a special case of the search tree property.

d\) Balanced binary search trees are always preferable to sorted

arrays.

 

Problem 11.2 You are given a binary tree with n nodes (via a pointer to its root). Each node of the tree has a size field, as in

Section 11.3.9, but these fields have not been filled in yet. How much time is necessary and sufficient to compute the correct value for all the size fields?

a\) ⇥(height)

b\) ⇥(n)

c\) ⇥(n log n)

d\) 2 ⇥ ( n )

150 Search Trees

 

Programming Problems

Problem 11.3 This problem uses the median maintenance problem

from Section 10.3.3 to explore the relative performance of heaps and search trees.

a\) Implement in your favorite programming language the heap-

based solution in Section 10.3.3 to the median maintenance problem.

b\) Implement a solution to the problem that uses a single search

tree and its Insert and Select operations.

Which implementation is faster?

You can use existing implementations of heaps and search

trees, or you can implement your own from scratch. (See [www.](http://www.algorithmsilluminated.org)

[algorithmsilluminated.org](http://www.algorithmsilluminated.org) for test cases and challenge data sets.)