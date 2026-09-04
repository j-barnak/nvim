Hints for Questions

1  
Unravelling “Fold”

1

What must the accumulator start at? What operation must we perform each time? Consider the `sum `function from the text as a starting point.

2

We need to ignore each element, just incrementing an accumulator when we see each one. The final value of the accumulator will then be the length of the list. What is the initial accumulator?

3

A good way to deal with the fact that an empty list has no last element would be to return an option type.

4

These sorts of folds producing lists have an accumulator which is a list type – you might start at the empty list.

5

The type will be the same as for `List.mem`. How do we keep track of whether or not we have seen a matching element? What is the initial accumulator?

6

This will involve a string accumulator and the string concatenation operator. How to we ensure there is not an excess space before or after the sentence?

7

The built-in `max `operator returns the larger of two values.

8

You can use the Standard Library function `Unix.gettimeofday `to help time the functions.

2  
Being Lazy

1

This is very similar to `lseq `in the text.

2

Construct by analogy to the same function on ordinary lists. Remember one needs to force evaluation to get at the tail.

3

How do we know when we have reached the end of the input list and must start again? What do we do if the input list is empty?

4

Consider the definition of fibonacci numbers. Split into a function which builds the lazy list given two numbers, and the construction of the list itself.

5

The type of the function will be α lazylist → α lazylist × α lazylist. You will need to force the evaluation of the tail of the input list twice to yield the heads of the two output lists, and then work out how to produce the tails.

6

Write a function which builds the alphabetic string from a number. Then, some of the generic lazy list handling functions from the text can be used to build the lazy list itself.

3  
Named Tuples with Records

1

What is a reference really?

2

Look at the functions `Unix.time `and `Unix.localtime`. You will need to deal with conversion of day-of-week and month from integers to strings yourself, but this is not difficult.

4

Records types can be parametrized, just like other data types.

5

See the documentation for a) `Gc.stat `and b) `Gc.set `and `Gc.get`.

4  
Generalized Input/Output

1

A simple modification of `input_of_string`.

2

Use a Buffer.t to accumulate the characters.

3

The new field will have type unit → char option.

4

The new field will have type unit → int. For `input_of_channel `and `input_of_string`, use exception handling to return the special value. Consider giving the special value -1 a name.

5

Check for a newline character on each `input_char`, raising `End_of_file`. Can you use `input_string `with the new channel you have created to return the user input?

6

The Buffer module already contains ideal functions for this.

5  
Streams of Bits

1

What is the test for being able to read a whole byte at a time? What do we do if the condition is met? If it is not?

2

Just replace the integer functions with ones from the Int32 module.

3

What is the test for being able to write a whole byte at a time? What do we do if the condition is met? If it is not?

4

Just replace the integer functions with ones from the Int32 module.

5

Try adding a `rewind `method to your `output `type, which goes back one byte. Now extend `output_of_string` appropriately.

6  
Compressing Data

1

Use list processing functions over a list of integers representing the data. For testing purposes, re-use our `int_list_of_string `and `string_of_int_list `functions.

2

Carefully define a suitable data type for the tree – the data will all be at the fringes of the tree, since no code is a prefix of another. Write a function to add a code to the tree. Now, repeated insertion can be used to build the whole tree.

4

We can re-use the `read_up_to `function, building up two histograms – one for white runs and one for black runs.

7  
Labelled and Optional  
Arguments

1

Consider what happens if α is int.

2

Perhaps define one or more new types.

3

Consider which functions have two or more arguments of the same type. We can add labels to those arguments only and wrap the function up.

4

We can use an optional argument for the accumulator.

8  
Formatted Printing

1

Consider `Printf.bprintf `as a way to accumulate the parts. What is special about the last element? What if there is no last element?

2

There is a format specifier for hexadecimal numbers. Consider what happens with very small character codes.

9  
Searching for Things

1

The `at `function from the chapter may be re-used here, in both parts of the question.

2

Start by writing a function which gives the length of the longest prefix of a pattern at the beginning of a list. Now wrap it in another which works through the whole list.

3

The expression `Unix.gettimeofday () `gives a floating-point number representing the current time.

4

Add a case to the inner match. It must manually check the next letter in the pattern matches the next letter in the string (if it exists).

5

This does not require altering the search code itself – one can just preprocess the pattern and string. There is a function `String.uppercase `in the Standard Library.

10  
Finding Permutations

1

What is the base case? For the main case, first calculate the combinations of the tail by recursion. What can you do now?

2

You can build this from functions we have already written.

3

What is the base case? You will need to keep a counter to make sure we only generate lists of the given length.

4

Consider using the `swap `function we defined in the main text.

5

Instead of using indices for the “first” and “last”, use the values themselves. Pull the list representing the old permutation apart, and rearrange it until you have the next.

11  
Making Sets

1

In the documentation for the Gc module, you will find the function `Gc.counters `and a description of how to calculate the total amount of memory allocated since the program began.

2

Add a `union `function to the signature, with the type α t → α t → α t and then a `union `function to the struct for each set representation.

3

You can include the given code inside the structure of the new module. Now, you can set the type t to be equal to S.t, the type of these new sets.

4

Alter the type first. The changes to each function then follow relatively easily.

12  
Playing Games

1

We already have code to find the number of X wins. What are the conditions for a game being drawn?

2

It is only necessary to alter the type tree and the function `next_moves`, and only a little. Now we need a function to extract the part of the tree which begins with O in the centre slot. Once we have this, simple modifications of our functions for counting wins and draws will do the job.

3

There is no need to worry about the order of the numbers in the square – the tree will have the same essential characteristics regardless.

13  
Representing Documents

3

A structure built from nested dictionaries would be suitable.

4

Consider everywhere a dictionary entry might appear. The function or functions will be recursive, following the general pattern of the data structure.

14  
Writing Documents

1

Removing the space at the end is simple. How can we detect if we are about to output the first item, and thus do not want a space?

2

Remember to alter the `/Size `entry, and to change `/Indirect `entries as required to reflect the new structure.

3

For the content stream in the “Hello, World!” file, one long row is sufficient. However, when encoding other example content streams, consult the PDF specification to ensure the file is still valid. To test, open in your favourite PDF reader.

15  
Pretty Pictures

1

We need to generate a set of points on the circle, and then they can be built into a path with `Move`, `Line`, and `Close`. This path can then be used with `Fill `to build the final page content.

2

First write a function to generate a path for a pseudo-random circle using a function we have previously written. Now `FillColour `and `Fill `can be added for each one, and the final list of operators produced.

3

We add `FillColourRGB `and `StrokeColourRGB `items to the data type and its associated functions. Then we can substitute them into the previous answer.

16  
Adding Text

1

You need to alter `typeset_line_at`, `clean_lines`, and `downfrom `once you have defined the new values.

2

Try just adding eight space characters after each new line in `lines_inner`.

3

If there are n characters, we must insert n - 1 pieces of space between them, each of equal size.

4

To make the construction of the multipage document simpler, consider choosing carefully the order (and hence numbering) of the objects in the file.