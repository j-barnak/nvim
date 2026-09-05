Chapter 15  
Pretty Pictures

We have not yet explained the structure of the code which put “Hello, World!” on the page. Here it is again:

`1 0 0 1 50 770 cm BT /F0 36 Tf (Hello, World!) Tj ET`

It is a list of operator-operand sequences. Each sequence consists of zero or more operands and one operator. The sequences in our example are:

![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00166.jpg)

In this chapter we will introduce a few simple operators for drawing lines and filling shapes (in the next chapter we discuss adding text and build a basic typesetter). Here are the operators we will be using to start with:

![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00194.jpg)

Here is a data type, which forms part of the new Pdfpage module, which encodes these operators. We will extend it with new operators when required.

`type t =`  
`    Move of float * float`  
`  | Line of float * float`  
`  | Close`  
`  | Stroke`  
`  | Fill`  
`  | FillColour of float`  
`  | StrokeColour of float`

In order to put these into the PDF document, we will need to convert each set of operands and operator to a string. This is simple:

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00284.jpg)

Now we can put them together into a single string by using functions from the Buffer module, putting a space character after each.

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00248.jpg)

Here is a very simple example – we move to (100, 100), make three lines and close the path. Then we use the `Fill `operator. Coordinates in PDF have the origin at the bottom left of the page.

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00279.jpg)

Our page looks like this:

![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00007.jpg)

Not all sequences of operators are valid, and our data type makes no checks to ensure our list is correct. This could be solved by building a higher-level data type which would then be flattened down to a list of Pdfpage.t elements. In our examples, and in the questions at the end of the chapter, it is sufficient to stick to the pattern above – one `Move`, one or more `Line`s, a `Close `(if filling), and a `Fill `or `Stroke`.

As an example, we will build a function to make a single line, and use it to build a function which, given the page dimensions, draws a page of graph paper. First, a function to build a single line from (x,y) to (x1,y1):

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00035.jpg)

Now, a function to return a set of equally spaced floating-point values from 0…n given a step:

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00067.jpg)

Note that we have been careful to avoid repeated addition of floating-point values – this can accumulate errors. We can build all the lines:

> ![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00080.jpg)

Here is the result of `graph_string 595.28 841.89 10. `on a page of A4 paper:

![](/tmp/audit/iter1/epubregen/more-ocaml-algorithms-methods-and-diversions/media/images/00072.jpg)

Questions

 

1.  Write a function which, given a centre point and radius, returns a list of `Move`, `Line`, and `Close` elements which represent a circle. Use a number of lines appropriate to the size of the circle.
2.  Use the function from the previous question to write a program which outputs a page covered in pseudo-random sized and filled grey circles.
3.  The sequences `red green blue ``rg `and `red green blue ``RG `are the colour analogues to the sequences `grey ``g `and `grey ``G`. Add them to our data type, and redo the circles program to use colour.
4.  The sequence `width ``w `sets the line width. Add this to our data type and use it to draw a single large unfilled circle over the centre of the page.
5.  The operator `W `in place of a stroke or paint operator is used to set up a clipping path. Add this to our data type. Turn your big circle into a clipping path for the random circles pattern, so you now have circles within a circle.