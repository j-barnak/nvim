Chapter 3  
Named Tuples with Records

Tuples can be used to combine a fixed number of elements of same or differing types. However, once we have more than two or three items, remembering the order can be difficult, especially if the types of the items are the same. Records remedy this, allowing us to name each item. Due to this naming, they have several other useful properties which distinguish them from tuples. Let us define a simple type for cartesian coordinates in two dimensions:

`type point = {x : float; y : float}`

Records are like tuples with labels. We write them between braces `{ }`. Each element of the record (called a field) has a name and a type, and the fields are separated with semicolons. We can construct a value of this type using the same syntax, but with the equals sign in place of the colons:

`let p = {x = 4.5; y = 6.0}`

We can add another field to the record, a label for the point:

`type point = {x : float; y : float; label : string}`

We can parametrize it just like a list or variant data type:

`type 'a point =`  
`{x : float; y : float; label : string; content : 'a}`

So now we can have values of type int point and string point and so on. We can define one directly:

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00059.jpg)

Notice that frequently we write something like `x = x `in a record definition, as in `make_point `here. This can be shortened to just `x`, and by doing so for all the arguments in `make_point `we obtain this simpler definition:

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00066.jpg)

Having built record values, we now need to know how to extract the individual parts. We can use the dot notation, writing record.field like so:

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00069.jpg)

Alternatively, we can use record syntax in patterns, here in the argument itself:

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00075.jpg)

Notice we only had to include in the pattern the parts of the record we intended to use. This can, optionally, be made more explicit by adding the wildcard `_ `to the pattern:

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00079.jpg)

Finally, we can use the shorthand record form in patterns too:

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00084.jpg)

Where we need a copy of a record with just one or more fields changed, we can use the `with` keyword:

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00089.jpg)

Again, the shortened form can help:

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00094.jpg)

Here is a function to reflect a point about the line x = y:

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00099.jpg)

Mutable records

Individual fields of a record can be made mutable (their value may be changed – literally mutated), by use of the `mutable `keyword:

`type 'a point = {x : float; y : float; label : string;mutable content : 'a}`

In fact, OCaml’s reference type is just a record with a single, mutable field:

`        OCaml`  
  
`# let x = ref 0;;`  
`- : int ref = { contents = 0 }`

Here, the type ref is defined by `type 'a ref = {mutable contents : 'a} `and the constructor function `ref `is of type α → α ref. The value of a mutable field can be updated using the `<- `symbol like this:

`        OCaml`  
  
`# type 'a point = {x : float; y : float; label : string; mutable content : 'a};;`  
`type 'a point = {`  
`  x : float;`  
`  y : float;`  
`  label : string;`  
`  mutable content : 'a;`  
`}`  
  
`# let p = {x = 4.5; y = 6.0; label = "P"; content = [1; 3; 1]};;`  
`val p : int list point = {x = 4.5; y = 6.; label = "P"; content = [1; 3; 1]}`  
  
`# p.content <- [1];;`  
`- : unit = ()`  
  
`# p;;`  
`- : int list point = {x = 4.5; y = 6.; label = "P"; content = [1]}`  

Such records should be used with care, like any mutable feature, especially if they are likely to be used as part of a larger data structure.

Questions

 

1.  Show how to update a reference without using the `:= `operator.
2.  Using functions from the “Time Functions” section of the documentation to the Unix module, write a program which, when run, returns a string containing the time and date, for example `"It` `is 2:45 on Wednesday 8 January 2014"`.
3.  What is the difference between `type t = {x : int ref} `and `type t = {mutable x : int}`? What are the advantages and disadvantages of each?
4.  Define a record of six items a...f where a and b have the same type as one another, c and d have the same type as one another and e and f have the same type as one another.
5.  Records are used in the module Gc which controls OCaml’s garbage collector (a garbage collector is a system which automatically reclaims space the program has finished with as the program is running). Use the data structures and functions in the Gc module to write programs which:
     

    1.  write a summary of the state of the garbage collector to a text file; and
    2.  alter the verbosity of the garbage collector as defined in the `control `record.