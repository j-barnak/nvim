Chapter 4  
Generalized Input/Output

In Pervasives, OCaml’s default always-opened module, a number of functions are defined over input and output channels – representing both files in the file system and special ones such as standard output. However, it is often useful to have a more general abstraction of input and output over, for example, strings and arrays, as well as files and channels.

In this chapter, we shall develop such an abstraction, giving input and output types which work with OCaml channels and strings. It can be extended to work over other data structures, and to have more complete functionality – some of the questions at the end of the chapter involve such extensions.

A type for inputs

The fundamental operations on an input, once it has been created, will be:

 

- finding the current position;
- setting the current position;
- reading a character, at the same time advancing the position;
- finding the length of an input.

We need a way to group them together, and to refer to them easily. A record is ideal:

`type input =`  
`     {pos_in : unit -> int;`  
`      seek_in : int -> unit;`  
`      input_char : unit -> char;`  
`      in_channel_length : int}`

Now we can build an input from an OCaml in_channel easily (we have re-used some of the standard OCaml names):

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00104.jpg)

Notice that the original channel is now hidden inside the input – the functions `pos_in `and `input_char `instead simply take the unit `() `as their input. Let us assure ourselves that this structure also works for abstracting over strings:

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00107.jpg)

We allocate a local reference, `pos`, to hold the current position. It cannot be accessed directly, only manipulated through the exposed record of functions. The `pos_in `and `in_channel_length `functions are simple. The `seek_in `function needs to check that the position is positive, but we allow it to be beyond the end, for compatibility with OCaml channels. The `input_char `function checks it is not trying to read beyond the end of the string, then reads a character, advances the position, and returns the character.

Notice we use the same exception scheme as OCaml does in its own channels – raising `End_of_file `if a read is attempted beyond the last character.

Example: reading words

We should like to write a program which can extract the words from a given input, such as a string or a file. For example, given the string

`"There were four of them; more than before."`

we wish to produce

`["there"; "were"; "four"; "of"; "them"; "more"; "than"; "before"]`

removing spaces, punctuation and making the words lower case. First, let us define a function to rewind the input by one character (useful when we have read a character and decided we do not wish to consume it), and another, a predicate to determine if a character is considered a non-letter, and thus may be skipped:

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00113.jpg)

Now, we can write a function `skip_characters `to skip any punctuation from the current point. It may raise `End_of_file`, of course. Then, we have the function `collect_characters `which, given a fresh Buffer.t and an input which has been processed by `skip_characters`, returns the string containing the next sequence of interesting characters, or raises `End_of_file `if we are at the end of the input.

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00119.jpg)

Finally, we can write `read_word `which finds the next word, if there is one. Then `read_words `collects them all in a list, and turns them in to lower case using the Standard Library function `String.lowercase`. These functions form Figure 4.1. For example:

------------------------------------------------------------------------

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00124.jpg)

 

> Figure 4.1:

------------------------------------------------------------------------

`# read_words (input_of_string "There were four of them; more than before.");;`  
`- : string list = ["there"; "were"; "four"; "of"; "them"; "more"; "than"; "before"]`

A type for outputs

What do we need for a generic output? We must have an `output_char `function to write a single character, at least. It is also useful to have an `out_channel_length `function so we know how many characters have been written. We will not allow seeking back and forth like with our input type for the sake of simplicity. Figure 4.2 shows the output type, and functions to build outputs from channels and strings.

------------------------------------------------------------------------

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00127.jpg)

 

> Figure 4.2:

------------------------------------------------------------------------

Note that whilst we have unified the interface for writing to strings and channels, they remain different things: the string has limited length, and if the length is not all used it will contain junk at the end. Let us use these functions to build a function which writes a list of integers to any output:

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00132.jpg)

Note that `o.output_char `has an appropriate type for use with standard functions such as `String.iter`. We can test with an output built from standard output:

`# output_int_list (output_of_channel stdout) [1; 2; 3; 4; 5];;`  
`[1; 2; 3; 4; 5 ]`  
`- : unit = ()`

Can you find a way to suppress the extraneous space before the `] `character?

Questions

 

1.  Write a function to build an input from an array of characters.
2.  Write a function `input_string `of type input → int → string which returns the given number of characters from the input as a string, or fewer if the input has ended.
3.  Extend the input type to include a function `input_char_opt `which returns a value of type char option, with `None `signalling end of file. Extend the functions `input_of_channel `and `input_of_string `appropriately.
4.  Extend the input type with a function `input_byte `which returns an integer representing the next byte, or the special value -1 at end of file. Comment on the usefulness of this compared with `input_char_opt `and `input_char`.
5.  Write an input type which raises `End_of_file `if it reaches a new line (a `'\n' `character). Use this to build a program which reads a line from standard input.
6.  Write a function to build an output from a Buffer.t. Show how this can be used to retrieve a final string after output is finished.