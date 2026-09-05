Chapter 7  
Labelled and Optional Arguments

OCaml allows us to label some or all of the arguments to a function, so as to provide a little documentation, to prevent us from accidently swapping two arguments which have the same type, and to allow partial application of arguments more flexibly. Consider a function to fill in part of an array with an element:

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00215.jpg)

The `fill `function takes four arguments: the array itself, the start position, length of the fill and the element to use to fill. However, since the start and length are both integers, it is easy to get them the wrong way round. This can be remedied by giving those two arguments labels. A label is introduced by a tilde, followed by the label name, a colon and the argument name itself. Consider the functions `fill `and `filled `below. As you can see, we have defined `fill `with labels, which appear in the type as well. In the first `filled `function, we call the `fill `function, citing the labels and giving immediate integers. In the second, we show that it works with other names (as it does, indeed, for any expression). In the third, we show that the labelled arguments may be permuted and rearranged with regard to the other arguments (unlabelled arguments must remain in the correct order relative to one another).

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00234.jpg)

Another change we can make is to use the label for the name of the argument inside the function too. This simplifies the syntax: we can just write `~label`.

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00083.jpg)

You can see that in `filled`, this “punning” works equally well when calling the function, if we happen to have values with the same names. These two facilities need not be used together, of course.

Labels with partial application

Another common use of labelled arguments is to give flexibility when using partial application. Consider the following function:

`let divide x y = x / y`

We can use partial application to write the function which divides ten thousand by each number in a list:

`let f = divide 10000 in [f 100; f 50; f 20]`

This yields `[100; 200; 500]`. But we cannot re-use `divide `to write the function which divides each number in a list by ten – this would involve partially applying the second argument `y `first. The design of the `divide` function has baked in which argument may be partially applied (OCaml lets us partially apply any prefix of the arguments – the first, first and second, first, second and third etc.) For example, we can apply the same function to many lists, using a partially applied `List.map `but we cannot apply many functions to a single list by providing the list to `List.map `instead. In our example, we can label the arguments to our divide function:

`let divide ~x ~y = x / y`

The type of the function reflects this:

`         OCaml  `  
`  `  
`# let divide ~x ~y = x / y;;  `  
`val divide : x:int -> y:int -> int = <fun> `

Now we may apply the arguments in either order:

`         OCaml  `  
`  `  
`# let f = divide ~x:10000 in [f 100; f 50; f 20];;  `  
`- : int list = [100; 200; 500]  `  
`# let f = divide ~y:10000 in [f 100000; f 10000; f 1000];;  `  
`- : int list = [10; 1; 0] `

We can in fact, omit the labels if we are applying arguments in order:

`         OCaml  `  
`  `  
`# let f = divide 10000 in [f 100; f 50; f 20];;  `  
`- : int list = [100; 200; 500] `

Optional arguments

OCaml also allows us to make a labelled argument optional – that is to say, we need not supply it at all. The function which is called without one or more of its arguments can decide what to do. Consider this simple function `split `which returns a list of singleton lists from an input list, for example returning `[[1]; [2];` `[3]] `for the input list `[1; 2; 3]`:

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00152.jpg)

We would like to extend the function to produce sub-lists of a given size, other than the default of 1. We can add a labelled argument and adapt the function, using `take `(which takes a given number of items from the start of a list) and `drop `(which drops a given number of items from the start of a list) from the Util module described on page xiii:

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00157.jpg)

There are two problems, though. Existing code using the function will not compile, and we must always specify the `chunksize `argument, even when it will be 1. This can be remedied by using an optional labelled argument, introduced with a question mark instead of a tilde, and given a default value:

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00160.jpg)

Notice the question mark appears also in the type. Notice also that in the recursive call to `split `we can write `~chunksize `instead of `~chunksize:chunksize `as usual. Now our `split `function can be called with or without this optional argument:

`         OCaml  `  
`  `  
`# split [1; 2; 3];;  `  
`- : int list list = [[1]; [2]; [3]]  `  
`# split ~chunksize:3 [1; 2; 3; 4; 5; 6; 7];;  `  
`- : int list list = [[1; 2; 3]; [4; 5; 6]; [7]] `

In fact, if we do not give a default value to the optional argument in the definition of `split`, we have access to its actual implementation – as a value of the option type, either `None `or `Some`, and we can match on it:

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00165.jpg)

This is primarily useful when there are several optional arguments.

Labels in the Standard Library

The Standard Library contains three labelled versions of other modules: ListLabels, ArrayLabels and StringLabels. For example, we can write:

`         OCaml  `  
`  `  
`# ListLabels.map ~f:(fun x -> x * 2) [1; 2; 3];;  `  
`- : int list = [2; 4; 6] `

If we wish to use the labelled modules by default, the module StdLabels contains these labelled modules under their original names so, by writing “`open StdLabels`”, `List.map`, `Array.blit `etc. will now be labelled:

`         OCaml  `  
`  `  
`# open StdLabels;;  `  
`# List.map ~f:(fun x -> x * 2) [1; 2; 3];;  `  
`- : int list = [2; 4; 6] `

These modules do not label all arguments. Typically they just do so for arguments which are functions, and when there are multiple arguments of the same type which may be confused. For example, `ArrayLabels.sub `of type α array → pos:int → len:int → α array introduces labels to disambiguate the position and length arguments, but does not label in the input array.

Questions

 

1.  The function `ArrayLabels.make `is not labelled, having type int → α → α array. When might this cause confusion? Write a labelled version to correct this problem.

2.  When we wrote our `fill `function with labelled arguments, we wanted to prevent someone mistakenly swapping the start and length values. Can you find a way to do this without labelled or optional arguments?

3.  Build labelled versions of functions from the Buffer module, choosing which functions and arguments to label as appropriate.

4.  Frequently we use an accumulator to make a function tail-recursive, wrapping it up in another function to give the initial value of the accumulator. For example, we might write:

    > ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00168.jpg)

    Use an optional argument to express this as a single function.