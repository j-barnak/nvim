## Appendix C

 

Quick Review of Asymptotic Notation

 

This appendix reviews asymptotic notation, especially big-O nota-tion. If you’re seeing this material for the first time, you proba-bly want to supplement this appendix with a more thorough treat-ment, such as Chapter 2 of Part 1 or the corresponding videos at

[www.algorithmsilluminated.org.](http://www.algorithmsilluminated.org) If you have seen it before, don’t feel compelled to read this appendix from front to back—dip in as needed wherever you need a refresher.

 

C.1 The Gist

Asymptotic notation identifies a sweet spot of granularity for reasoning about algorithms and data structures. It is coarse enough to suppress all the details you want to ignore—details that depend on the choice of architecture, the choice of programming language, the choice of compiler, and so on. On the other hand, it’s precise enough to make useful comparisons between different high-level algorithmic approaches to solving a problem, especially on larger inputs (the inputs that require algorithmic ingenuity).

A good seven-word summary of asymptotic notation is:

Asymptotic Notation in Seven Words

 

suppress constant factors and lower-order terms \| {z } \| {z } irrelevant for large inputs too system-dependent

 

The most important concept in asymptotic notation is big-O nota-

tion. Intuitively, saying that something is O(f(n)) for a function f (n) means that f (n) is what you’re left with after suppressing constant factors and lower-order terms. For example, if g(n) = 6n log n + 6n 2,

193

194 Quick Review of Asymptotic Notation

 

then g 1 ( n ) = O ( n log n ) . Big-O notation buckets algorithms and data structure operations into groups according to their asymptotic worst-case running times, such as linear-time (O(n)) or logarithmic-time (O(log n)) algorithms and operations.

 

C.2 Big-O Notation

Big-O notation concerns functions T (n) defined on the positive integers n = 1, 2, . . .. For us, T (n) will almost always denote a bound on the worst-case running time of an algorithm or data structure operation, as a function of the size n of the input.

Big-O Notation (English Version)

T (n) = O(f (n)) if and only if T (n) is eventually bounded above by a constant multiple of f (n).

 

Here is the corresponding mathematical definition of big-O nota-tion, the definition you should use in formal proofs.

Big-O Notation (Mathematical Version)

T (n) = O(f (n)) if and only if there exist positive constants c and n0 such that

T (n)  c · f (n) (C.1)

for all n n0.

 

The constant c quantifies the “constant multiple” and the constant n0

quantifies “eventually.” For example, in Figure C.1, the constant c corresponds to 3, while n0 corresponds to the crossover point between the functions T (n) and c · f (n).

A Word of Caution

When we say that c and n0 are constants, we mean they cannot depend on n. For example, in

 

1 When ignoring constant factors, we don’t need to specify the base of the logarithm. (Different logarithmic functions differ only by a constant factor.) C.3 Examples 195

 

*c*

 

3 ⋅ *f* (*n*)

*T* (*n* )

 

*f* (*n*)

![](media/index-208_1.jpg)

 

*n* → ∞ *n*0

![](media/index-208_2.jpg)

Figure C.1: A picture illustrating when T(n) = O(f (n)). The constant c quantifies the “constant multiple” of f (n), and the constant n0 quantifies “eventually.”

![](media/index-208_3.jpg)

 

Figure C.1, c and n0 were fixed numbers (like 3

![](media/index-208_4.jpg)

or 1000), and we then considered the inequality (C.1)

![](media/index-208_5.jpg)

as n grows arbitrarily large (looking rightward on the graph toward infinity). If you ever find yourself saying

![](media/index-208_6.jpg)

“take n0 = n” or “take c = log n 2” in an alleged big-O proof, you need to start over with choices of c and n0 that are independent of n.

![](media/index-208_7.jpg)

 

C.3 Examples

![](media/index-208_8.jpg)

We claim that if T (n) is a polynomial with some degree k, then T k ( n ) = O ( n) . Thus, big-O notation really is suppressing constant factors and lower-order terms.

Proposition C.1 Suppose

T k ( n ) = a n + · · · a n + a , k 1 0

where k 0 is a nonnegative integer and the ai’s are real numbers (positive or negative). Then k T ( n ) = O ( n). 196 Quick Review of Asymptotic Notation

 

Proof: Proving a big-O statement boils down to reverse engineering appropriate values for the constants c and n0. Here, to keep things easy to follow, we’ll pull values for these constants out of a hat: n0 = 1

and c 2 equal to the sum of absolute values of the coe ffi cients:

c = \|ak\| + · · · + \|a1\| + \|a0\|.

Both these numbers are independent of n. We now must show that these choices of constants satisfy the definition, meaning that T (n)  c k · n for all n n = 1.

0

To verify this inequality, fix a positive integer n n0 = 1. We need a sequence of upper bounds on T (n), culminating in an upper bound of k c · n. First let’s apply the definition of T (n):

T k ( n ) = a n + · · · + a n + a . k 1 0

If we take the absolute value of each coefficient ai on the right-hand side, the expression only becomes larger. (\|ai\| can only be bigger than i i a i , and because n is positive, \| a i \| n can only be bigger than i a i n .) This means that

T k ( n )  \| a \| n + · · · + \|a \|n + \|a \|. k 1 0

Now that the coefficients are nonnegative, we can use a similar trick to turn the different powers of n into a common power of n. As n 1, k n

is only bigger than i n for every i 2 {0, 1, 2, . . . , k}. Because \|ai\| is nonnegative, k i \| a i \| n is only bigger than \| a i \| n. This means that

T k k k k ( n )  \| a k 1 \| n + · · · + \| a \| n + \| a 0 n \| = ( \| a k 1 \| + · · · + \| a \| + \| a 0 ) \| · n.

\| {z }

=c

This inequality holds for every n n0 = 1, which is exactly what we wanted to prove. QE D

We can also use the definition of big-O notation to argue that one function is not big-O of another function.

Proposition C.2 If 10n T ( n ) = 2, then n T ( n ) is not O (2).

2 Recall that the absolute value \|x\| of a real number x equals x when x 0,

and x when x  0. In particular, \|x\| is always nonnegative. C.4 Big-Omega and Big-Theta Notation 197

 

Proof: The usual way to prove that one function is not big-O of another is by contradiction. So, assume the opposite of the statement in the proposition, that n T ( n ) is, in fact, O (2). By the definition of big-O notation, there are positive constants c and n0 such that

210n n  c · 2

for all n n n 0 . As 2 is a positive number, we can cancel it from both sides of this inequality to derive

2 9n  c

for all n n0. But this inequality is patently false: The right-hand side is a fixed constant (independent of n), while the left-hand side goes to infinity as n grows large. This shows that our assumption that n 10n T ( n ) = O (2 ) cannot be correct, and we can conclude that 2 is not n O (2). QE D

 

C.4 Big-Omega and Big-Theta Notation

Big-O notation is by far the most important and ubiquitous concept for discussing the asymptotic running times of algorithms and data structure operations. A couple of its close relatives, the big-omega and big-theta notations, are also worth knowing. If big-O is analogous to “less than or equal to ( ),” then big-omega and big-theta are analogous to “greater than or equal to ( ),” and “equal to (=),” respectively.

The formal definition of big-omega notation parallels that of big-O

notation. In English, we say that one function T (n) is big-omega of another function f (n) if and only if T (n) is eventually bounded below by a constant multiple of f(n). In this case, we write T (n) = ⌦(f(n)). As before, we use two constants c and n0 to quantify “constant multiple” and “eventually.”

Big-Omega Notation

T (n) = ⌦(f(n)) if and only if there exist positive constants c and n0 such that

T (n) c · f (n)

for all n n0.

198 Quick Review of Asymptotic Notation

 

Big-theta notation, or simply theta notation, is analogous to “equal to.” Saying that T (n) = ⇥(f (n)) simply means that both T (n) = ⌦(f(n)) and T (n) = O(f (n)). Equivalently, T (n) is eventually sand-wiched between two different constant multiples of f (n).

Big-Theta Notation

T (n) = ⇥(f(n)) if and only if there exist positive constants c1 , c2, and n0 such that

c1 · f (n)  T(n)  c2 · f(n)

for all n n0.

 

A Word of Caution

Because algorithm designers are so focused on running

time guarantees (which are upper bounds), they tend

to use big-O notation even when big-theta notation

would be more accurate; for example, stating the

running time of an algorithm as O(n) even when it’s clearly ⇥(n).

 

The next quiz checks your understanding of big-O, big-omega, and big-theta notation.

Quiz C.1

Let 1 2 T ( n ) = n + 3n. Which of the following statements 2

are true? (Choose all that apply.)

a\) T (n) = O(n)

b\) T (n) = ⌦(n)

c\) 2 T ( n ) = ⇥ ( n)

d\) 3 T ( n ) = O ( n)

C.4 Big-Omega and Big-Theta Notation 199

 

(See below for the solution and discussion.)

Correct answers: (b),(c),(d). The final three responses are all correct, and hopefully the intuition for why is clear. T (n) is a quadratic function. The linear term 3n doesn’t matter for large n, so we should expect that 2 T ( n ) = ⇥ ( n) (answer (c)). This automatically implies that 2 T ( n ) = ⌦ ( n) and hence T (n) = ⌦(n) also (answer (b)). Similarly, 2) implies that 2 T ( n ) = ⇥ ( n T ( n ) = O ( n ) and hence also T 3 ( n ) = O ( n) (answer (d)). Proving these statements formally boils down to exhibiting appropriate constants to satisfy the definitions.

 

For example, taking 1 n 0 = 1 and c = proves (b). Taking n0 = 1 and 2 1 c = 4 proves (d). Combining these constants ( n 0 = 1 , c 1 = , c 2 = 4 ) 2 proves (c). A proof by contradiction, in the spirit of Proposition C.2, shows that (a) is not a correct answer.