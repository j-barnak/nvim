Chapter 11  
Making Sets

In this chapter, we will look at various naive and sophisticated data structures for storing sets. We will look at their theoretical performance characteristics and time them against one another on various sorts of data to learn about their performance in practice. Along the way, we will learn about some of OCaml’s more advanced modular abstraction mechanisms. For each set representation, we will give the following five functions:

 

- `set_of_list `which builds a set from a list (which may contain duplicates). The empty set is built with `set_of_list []`;
- `list_of_set `which returns, in no particular order, a list of the elements in the set;
- `insert `which inserts a given element into the set, if it is not already present;
- `size `which returns the number of elements in the set; and
- `member `which tests if an element is present in the set.

Simple lists

Figure 11.1 exhibits these five functions by representing sets using the built-in list type. They are largely trivial, save for `set_of_list `which works by repeated insertion into the existing set.

------------------------------------------------------------------------

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00200.jpg)

 

> Figure 11.1:

------------------------------------------------------------------------

These functions are not terribly efficient. The `member`, `size`, and `insert `functions take time proportional to the size of the set. The `set_of_list `function is worse: it takes time proportional to the square of the size of the set, since it uses `insert `for each element on a growing list. The only bright spot is `list_of_set `which (of course) runs in constant time.

We have not hidden the type of the sets – they may be manipulated by the caller as plain lists – and so the abstraction is not safe or complete. Here is an interface as a `.mli `file, abstracting the real type of the set to just α t .

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00222.jpg)

Here is the corresponding `.ml `file with the implementation:

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00253.jpg)

Recall that, by hiding the implementation behind an interface, we can swap implementations at will, making them more efficient, or fixing bugs.

Since we wish to build several of these set implementations, and benchmark them, it is a good time to look at OCaml’s syntax for putting several modules in a single source file. Figure 11.2 exhibits a piece of OCaml which corresponds to our `.ml `and `.mli `file all in one place:

------------------------------------------------------------------------

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00283.jpg)

 

> Figure 11.2:

------------------------------------------------------------------------

The general syntactic form is:

`module `module name `:`  
`  sig`  
`    `contents of .mli file  
`  end`  
`=`  
`  struct`  
`    `contents of .ml file  
`  end`

When this code is pasted into the top level, or loaded in some other way, a new module SetList is available, with functions like `SetList.size `available through the given interface.

Since all our different implementations of sets will share the same interface as SetList, we will split this module definition up using the `module type `syntax to define the signature, and the `include `keyword to use that signature for our module:

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00012.jpg)

Thus, we have avoided duplication of the interface. Each new set representation will just need an implementation.

Performance

Each use of the set data type is different – sometimes there is an initial phase of insertions, followed by millions of membership tests with no insertions. Sometimes insertions and membership tests are equally likely. Some functions may not be required at all. We shall consider two benchmarks for insertion:

 

- the insertion of the integers 1…50000 in a randomized order; and
- the insertion, in order, of the 50000 integers 1…50000.

Then, we will, for each of these “ordered” and “unordered” cases:

 

- perform 50000 membership tests in the range of numbers 1…100000, so that half are present and half not;
- calculate the number of elements in the set;
- calculate the size of the set.

Here are the results:

![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00042.jpg)

The big difference is in the time for the membership tests, due to the balance or lack of balance in the tree, as expected. When we introduce more ways of storing sets, we will do the same tests, and compare the results.

Binary Search Trees

A binary search tree is a binary tree with the property that all elements in the left sub-tree of each node are smaller than it, and all elements in the right sub-tree are larger. If the tree is reasonably well balanced, we can reach any element in time proportional to the logarithm of the number of elements in the set.

Just like the representation of sets, there are multiple representations of sets, depending upon the order of insertion of the elements. Here are the trees corresponding to the insertion orders 123, 132, 213, 231, 312, 321:

![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00070.jpg)

We can see that when the items in the set are added in numerical or reverse-numerical order, this data structure is equivalent to, and has no better performance, than a simple list. The data type is the usual one for binary trees:

`type 'a t = Lf | Br of 'a t * 'a * 'a t`

The SetTree module is shown in Figure 11.3.

------------------------------------------------------------------------

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00241.jpg)

 

> Figure 11.3:

------------------------------------------------------------------------

When the tree is balanced `insert `and `member `run in logarithmic time. The `size `function runs in linear time, since it must visit every node irrespective of the balance. The same is true of `list_of_set`. When unbalanced, `insert `and `member `take linear time. We can extend our table now:

![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00048.jpg)

Notice that, in the unordered case, performance is dramatically increased for insertion and membership, by about two hundred times. However, if the elements are inserted in order, the unbalanced tree actually takes longer to build than its equivalent list. Finding all the elements as a list also takes a huge amount of time in the ordered insertion case.

Balanced trees

We have seen that binary search trees are only useful if they are reasonably close to balanced. In recent decades, several data structures have been developed which try to keep a binary tree “reasonably balanced”, such that operations remain efficient. “Red-Black trees” are one such commonly used and interesting data structure. Red-Black trees were invented by Rudolf Bayer, and the functional formulation presented here is due to Chris Okasaki in his landmark book “Purely Functional Data Structures” (Cambridge University Press, 1998).

A Red-Black tree is an ordinary binary tree with one addition: each node is either Red or Black. Leaf nodes are considered Black. The balance is ensured by every operation which alters the tree (in our case, just `insert`) so that the following remains true:

 

- the children of each Red node are Black; and
- each path from root to leaf contains an equal number of Black nodes.

These two rules, together, ensure that the tree is reasonably balanced – the longest path from root to leaf (Black, Red, Black, Red … Black) is no more than twice as long as the shortest path (Black, Black, Black … Black). Thus, the maximum depth of a Red-Black tree is proportional to the logarithm of the number of elements in the set. Here is an example valid Red-Black tree, with 3 black nodes in each path:

![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00182.jpg)

Here are the types for representing a Red-Black tree – we have just added a new colour field to each branch of the tree:

`type colour = R | B`  
  
`type 'a t = Lf | Br of colour * 'a t * 'a * 'a t`

The `list_of_set`, `size`, and `member `functions are simple to alter: they just ignore the colour field. The `insert` function, however, must be modified to preserve the Red-Black properties.

As with ordinary binary search trees, the new node added by `insert `will be in place of a leaf node. We colour it Red, to make sure that the invariant that no path can have a differing number of black nodes in it is not broken. However, this may break the other invariant (that no Red node has a Red parent). It turns out that, by considering the parent and grandparent of the newly-inserted node, performing a simple operation, and possibly continuing this process upward, we can restore this invariant, and efficiently. The following diagrams, à la Okasaki, illustrate the process:

![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00022.jpg)

In each case, the nodes x,y,z and the sub-trees α,β,γ,δ remain in the same order, so the binary tree invariant is preserved. Pattern matching is particularly elegant here, since all but one of our cases have the same result:

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00163.jpg)

Now, we can write the insertion function itself:

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00004.jpg)

Note that we wrap it in a function to set the root of the tree to Black – balancing will not do this, since the root has no parent or grandparent to compare with, and so we may otherwise end up with a red root with a red child. The full module is shown in Figure 11.4.

------------------------------------------------------------------------

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00269.jpg)

 

> Figure 11.4:

------------------------------------------------------------------------

Since we have guaranteed that the tree will be reasonably balanced, there is no need for tail recursive functions, even for huge sets. The effect of balanced trees on performance is clear, and there appears to be little or no slow-down from the more complex Red-Black data structure:

![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00285.jpg)

Hash Tables

A hash table is a data structure designed to provide very fast insertion of and access to data in sets and maps. It holds a set of buckets 0...n. When we insert a value into the set, it is processed via a hash function which allocates it to a bucket, in such a manner that there should be a roughly uniform distribution of values among the buckets. When we need to test membership for an item, the same hash function is applied, and we need only search in one bucket. If the hash function works well and the number of buckets is appropriate, lookup is in constant time regardless of how many items are in the set.

For example, if the hash function is x-→x mod 23 and the data to be inserted is 34, 2, 67, 3, 4, 84, 1467, 7432, 48, 1 then the buckets would be 11, 2, 21, 3, 4, 15, 18, 3, 1, 1. The membership test for 67 now consists of applying the hash function, and then searching in bucket 21 to see if 67 is there.

The OCaml Standard Library provides a hash table implementation in the module Hashtbl. To build a hash table for a set, we use a hash table which maps from α to unit, of type (α, unit) Hashtbl.t. It is simple to build an implementation matching our signature, using the functions `Hashtbl.mem`, `Hashtbl.add`, `Hashtbl.create`, and `Hashtbl.iter`, as shown in Figure 11.5.

------------------------------------------------------------------------

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00175.jpg)

 

> Figure 11.5:

------------------------------------------------------------------------

The disadvantage is that hash tables are mutable data structures, and so operations like `insert `mutate the structure. The result of `insert`, then, alters the set rather than creating a new set. This means that whilst the SetType interface is technically satisfied, our intended abstraction is actually broken. Such is mutability. The performance on our benchmarks, however, is clear:

![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00265.jpg)

The benchmarking programs may be found in the online resources.

Questions

 

1.  Compare our set representations with regard to the amount of memory required to create and store them. You can use the functions from the Gc module in OCaml’s Standard Library to find out how many words of memory have been allocated before and after allocating a large set in each set representation.

2.  Write functions (naive if necessary) to perform the “union” operation on sets in each representation. The union of two sets is the set of elements present in one or the other or both of them. After the operation, both inputs should still be available as sets.

3.  OCaml has a built-in Set module. It uses advanced module syntax not discussed here, but you can build a module for manipulating sets of integers like this:

    `module S = Set.Make (struct type t = int let compare = compare end)`

    This new module S provides, amongst others, a type t for sets, and `add`, `elements`, `mem`, `empty`, and `cardinal `functions, whose definitions you can find in the OCaml manual. Use these functions to build a set module with a similar interface to ours. Comment on its speed for our examples.

4.  We can save memory in the definition of Red-Black trees by having two different `Br `nodes, one for Red and one for Black, instead of storing the colour. Implement this. How much memory is saved? How much extra complexity is there in the source code?