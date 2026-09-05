## **2**

## First steps

In this chapter we take our first proper steps with Haskell. We start by introducing the GHC system and the standard prelude, then explain the notation for function application, develop our first Haskell script, and conclude by discussing a number of syntactic conventions concerning scripts.

### **2.1Glasgow Haskell Compiler**

As we saw in the previous chapter, small Haskell programs can be executed by hand. In practice, however, we usually require a system that can execute programs automatically. In this book we use the *Glasgow Haskell Compiler*, a state-of-the-art, open source implementation of Haskell.

The system has two main components: a batch compiler called GHC, and an interactive interpreter called GHCi. We will primarily use the interpreter in this book, as its interactive nature makes it well suited for teaching and prototyping purposes, and its performance is sufficient for most of our applications. However, if greater performance or a stand-alone executable version of a Haskell program is required, the compiler itself can be used. For example, we will use the compiler in extended programming examples in chapters 9 and 11.

### **2.2Installing and starting**

The Glasgow Haskell Compiler is freely available for a range of operating systems from the Haskell home page, <http://www.haskell.org>. For first time users we recommend downloading the *Haskell Platform*, which provides a convenient means to install the system and a collection of commonly used libraries. More advanced users may prefer to install the system and libraries manually.

Once installed, the interactive GHCi system can be started from the terminal command prompt, such as \$, by simply typing ghci:

``` haskell
$ ghci
```

All being well, a welcome message will then be displayed:

``` haskell
GHCi, version A.B.C: http://www.haskell.org/ghc/ :? for help Prelude>
```

The GHCi prompt \> indicates that the system is now waiting for the user to enter an expression to be evaluated. For example, it can be used as a calculator to evaluate simple numeric expressions:

``` haskell
> 2+3*4
14


> (2+3)*4
20


> sqrt (3^2 + 4^2)
5.0
```

Following normal mathematical convention, in Haskell exponentiation is assumed to have higher priority than multiplication and division, which in turn have higher priority than addition and subtraction. For example, 2\*3^4 means 2\*(3^4), while 2+3\*4 means 2+(3\*4). Moreover, exponentiation associates (or brackets) to the right, while the other four main arithmetic operators associate to the left. For example, 2^3^4 means 2^(3^4), while 2-3+4 means (2-3)+4. In practice, however, it is often clearer to use explicit parentheses in such expressions, rather than relying on the above rules.

### **2.3Standard prelude**

Haskell comes with a large number of built-in functions, which are defined in a library file called the *standard prelude*. In addition to familiar numeric functions such as + and \*, the prelude also provides a range of useful functions that operate on lists. In Haskell, the elements of a list are enclosed in square parentheses and are separated by commas, as in \[1,2,3,4,5\]. Some of the most commonly used library functions on lists are illustrated below.

- Select the first element of a non-empty list:

  \> head \[1,2,3,4,5\]  
  1

- Remove the first element from a non-empty list:

  \> tail \[1,2,3,4,5\]  
  \[2,3,4,5\]

- Select the nth element of list (counting from zero):

  \> \[1,2,3,4,5\] !! 2  
  3

- Select the first n elements of a list:

  \> take 3 \[1,2,3,4,5\]  
  \[1,2,3\]

- Remove the first n elements from a list:

  \> drop 3 \[1,2,3,4,5\]  
  \[4,5\]

- Calculate the length of a list:

  \> length \[1,2,3,4,5\]  
  5

- Calculate the sum of a list of numbers:

  \> sum \[1,2,3,4,5\]  
  15

- Calculate the product of a list of numbers:

  \> product \[1,2,3,4,5\]  
  120

- Append two lists:

  \> \[1,2,3\] ++ \[4,5\]  
  \[1,2,3,4,5\]

- Reverse a list:

  \> reverse \[1,2,3,4,5\]  
  \[5,4,3,2,1\]

As a useful reference guide, appendix B presents some of the most commonly used definitions from the standard prelude.

### **2.4Function application**

In mathematics, the application of a function to its arguments is usually denoted by enclosing the arguments in parentheses, while the multiplication of two values is often denoted silently, by writing the two values next to one another. For example, in mathematics the expression

*f*(*a, b*) + *c d*

means apply the function *f* to two arguments *a* and *b*, and add the result to the product of *c* and *d*. Reflecting its central status in the language, function application in Haskell is denoted silently using spacing, while the multiplication of two values is denoted explicitly using the operator \*. For example, the expression above would be written in Haskell as follows:

``` haskell
f a b + c*d
```

Moreover, function application has higher priority than all other operators in the language. For example, f a + b means (f a) + b rather than f (a + b). The following table gives a few further examples to illustrate the differences between function application in mathematics and in Haskell:

![image](/tmp/audit/iter1/epubregen/programming-in-haskell-2e/media/Images/Chapter_2_image_4_13.png)

Note that parentheses are still required in the Haskell expression f (g x) above, because f g x on its own would be interpreted as the application of the function f to two arguments g and x, whereas the intention is that f is applied to one argument, namely the result of applying the function g to an argument x. A similar remark holds for the expression f x (g y).

### **2.5Haskell scripts**

As well as the functions provided in the standard prelude, it is also possible to define new functions. New functions are defined in a *script*, a text file comprising a sequence of definitions. By convention, Haskell scripts usually have a .hs suffix on their filename to differentiate them from other kinds of files. This is not mandatory, but is useful for identification purposes.

#### My first script

When developing a Haskell script, it is useful to keep two windows open, one running an editor for the script, and the other running GHCi. As an example, suppose that we start a text editor and type in the following two function definitions, and save the script to a file called test.hs:

``` haskell
double x = x + x


quadruple x = double (double x)
```

In turn, suppose that we leave the editor open, and in another window start up the GHCi system and instruct it to load the new script:

``` haskell
$ ghci test.hs
```

Now both the standard prelude and the script test.hs are loaded, and functions from both can be freely used. For example:

``` haskell
> quadruple 10
40


> take (double 2) [1,2,3,4,5]
[1,2,3,4]
```

Now suppose that we leave GHCi open, return to the editor, add the following two function definitions to those already typed in, and resave the file:

``` haskell
factorial n = product [1..n]


average ns = sum ns ‘div‘ length ns
```

We could also have defined average ns = div (sum ns) (length ns), but writing div between its two arguments is more natural. In general, any function with two arguments can be written between its arguments by enclosing the name of the function in single back quotes ‘ ‘.

GHCi does not automatically reload scripts when they are modified, so a reload command must be executed before the new definitions can be used:

``` haskell
> :reload


> factorial 10
3628800


> average [1,2,3,4,5]
3
```

For reference, the table in figure 2.1 summarises the meaning of some of the most commonly used GHCi commands. Note that any command can be abbreviated by its first character. For example, :load can be abbreviated by :l. The command :set editor is used to set the text editor that is used by the system. For example, if you wish to use vim you would enter :set editor vim. The command :type is explained in more detail in the next chapter.

![image](/tmp/audit/iter1/epubregen/programming-in-haskell-2e/media/Images/Chapter_2_image_6_15.png)

**Figure 2.1** Useful GHCi commands

#### Naming requirements

When defining a new function, the names of the function and its arguments must begin with a lower-case letter, but can then be followed by zero or more letters (both lower- and upper-case), digits, underscores, and forward single quotes. For example, the following are all valid names:

myFunfun1arg_2x’

The following list of *keywords* have a special meaning in the language, and cannot be used as the names of functions or their arguments:

![image](/tmp/audit/iter1/epubregen/programming-in-haskell-2e/media/Images/Chapter_2_image_6_16.png)

By convention, list arguments in Haskell usually have the suffix s on their name to indicate that they may contain multiple values. For example, a list of numbers might be named ns, a list of arbitrary values might be named xs, and a list of lists of characters might be named css.

#### The layout rule

Within a script, each definition at the same level must begin in precisely the same column. This *layout rule* makes it possible to determine the grouping of definitions from their indentation. For example, in the script

``` haskell
a = b + c
where
b = 1
c = 2
d = a * 2
```

it is clear from the indentation that b and c are local definitions for use within the body of a. If desired, such grouping can be made explicit by enclosing a sequence of definitions in curly parentheses and separating each definition by a semi-colon. For example, the above script could also be written as

``` haskell
a = b + c
where
{b = 1;
c = 2};
d = a * 2
```

or even be combined into a single line:

``` haskell
a = b + c where {b = 1; c = 2}; d = a * 2
```

In general, however, it is usually preferable to rely on the layout rule to determine the grouping of definitions, rather than using explicit syntax.

#### Tabs

Tab characters can cause problems in scripts, because layout is significant but different text editors interpret tabs in different ways. For this reason, it is recommended to avoid using tabs when indenting definitions, and the GHC system issues a warning message if they are used. If you do wish to use tabs in your scripts, it is best to configure your editor to automatically convert them to spaces. Haskell assumes that tab stops are 8 characters wide.

#### Comments

In addition to new definitions, scripts can also contain comments that will be ignored by the compiler. Haskell supports two kinds of comments, called *ordinary* and *nested*. Ordinary comments begin with the symbol -- and extend to the end of the current line, as in the following examples:

``` haskell
-- Factorial of a positive integer:
factorial n = product [1..n]


-- Average of a list of integers:
average ns = sum ns ‘div‘ length ns
```

Nested comments begin and end with the symbols {- and -}, may span multiple lines, and may be nested in the sense that comments can contain other comments. Nested comments are particularly useful for temporarily removing sections of definitions from a script, as in the following example:

``` haskell
{–
double x = x + x


quadruple x = double (double x)
–}
```

### **2.6Chapter remarks**

In addition to the GHC system, <http://www.haskell.org> contains a wide range of other useful resources concerning Haskell, including community activities, language documentation, and news items.

### **2.7Exercises**

1.Work through the examples from this chapter using GHCi.

2.Parenthesise the following numeric expressions:

``` haskell
2^3*4


2*3+4*5


2+3*4^5
```

3.The script below contains three syntactic errors. Correct these errors and then check that your script works properly using GHCi.

``` haskell
N = a ’div’ length xs
where
a = 10
xs = [1,2,3,4,5]
```

4.The library function last selects the last element of a non-empty list; for example, last \[1,2,3,4,5\] = 5. Show how the function last could be defined in terms of the other library functions introduced in this chapter. Can you think of another possible definition?

5.The library function init removes the last element from a non-empty list; for example, init \[1,2,3,4,5\] = \[1,2,3,4\]. Show how init could similarly be defined in two different ways.

Solutions to exercises 2–4 are given in appendix A.