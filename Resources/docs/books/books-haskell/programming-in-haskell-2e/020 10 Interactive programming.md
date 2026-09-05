## **10**

## Interactive programming

In this chapter we show how Haskell can be used to write interactive programs. We start by explaining the problem of handling interaction in a pure language, present the solution that is adopted in Haskell, introduce a range of primitives and derived functions for interactive programming, and conclude by developing three interactive games: hangman, nim and life.

### **10.1The problem**

In the early days of computing, most programs were *batch programs* that were run in isolation from their users, to maximise the amount of time the computer was performing useful work. For example, a compiler is a batch program that takes a high-level program as its input, silently performs a large number of operations, and then produces a low-level program as its output.

In part I of the book, we showed how Haskell can be used to write batch programs. In Haskell such programs, and more generally all programs, are modelled as *pure functions* that take all their inputs as explicit arguments, and produce all their outputs as explicit results, as depicted below:

![image](/tmp/audit/iter1/epubregen/programming-in-haskell-2e/media/Images/Chapter_10_image_1_9.png)

For example, a compiler such as GHC may be modelled as a function of type Prog -\> Code that transforms a high-level program into low-level code.

In the modern era of computing, most programs are now *interactive programs* that are run as an ongoing dialogue with their users, to provide increased flexibility and functionality. For example, an interpreter is an interactive program that allows expressions to be entered using the keyboard, and immediately displays the result of evaluating such expressions on the screen:

![image](/tmp/audit/iter1/epubregen/programming-in-haskell-2e/media/Images/Chapter_10_image_2_14.png)

How can such programs be modelled as pure functions? At first sight, this may seem impossible, because interactive programs by their very nature require the *side effects* of taking additional inputs and producing additional outputs while the program is running. For example, how can an interpreter such as GHCi be viewed as a pure function from arguments to results?

Over the years many approaches to the problem of combining the use of pure functions with the need for side effects have been developed. In the remainder of this chapter we present the solution that is used in Haskell, which is based upon a new type together with a small number of primitive operations. As we shall see in later chapters, the underlying approach is not specific to interaction, but can also be used to program with other forms of effects.

### **10.2The solution**

In Haskell, an interactive program is viewed as a pure function that takes the current *state of the world* as its argument, and produces a modified world as its result, in which the modified world reflects any side effects that were performed by the program during its execution. Hence, given a suitable type World whose values represent states of the world, the notion of an interactive program can be represented by a function of type World -\> World, which we abbreviate as IO (short for input/output) using the following type declaration:

``` haskell
type IO = World -> World
```

In general, however, an interactive program may return a result value in addition to performing side effects. For example, a program for reading a character from the keyboard may return the character that was read. For this reason, we generalise our type for interactive programs to also return a result value, with the type of such values being a parameter of the IO type:

``` haskell
type IO a = World -> (a,World)
```

Expressions of type IO a are called *actions*. For example, IO Char is the type of actions that return a character, while IO () is the type of actions that return the empty tuple () as a dummy result value. Actions of the latter type can be thought of as purely side-effecting actions that return no result value, and are often useful in interactive programming. For example, the countdown program in chapter 9 used a top-level definition main of type IO ().

In addition to returning a result value, interactive programs may also require argument values. However, there is no need to generalise the IO type further to take account of this, because this behaviour can already be achieved by exploiting currying. For example, an interactive program that takes a character and returns an integer would have type Char -\> IO Int, which abbreviates the curried function type Char -\> World -\> (Int,World).

At this point the reader may, quite reasonably, be concerned about the feasibility of passing around the entire state of the world when programming with actions! Of course, this isn’t possible, and in reality the type IO a is provided as a primitive in Haskell, rather than being represented as a function type. However, the above explanation is useful for understanding how actions can be viewed as pure functions, and the implementation of actions in Haskell is consistent with this view. For the remainder of this chapter, we will consider IO a as a built-in type whose implementation details are hidden:

``` haskell
data IO a = ...
```

### **10.3Basic actions**

We now introduce three basic IO actions that are provided in Haskell. First of all, the action getChar reads a character from the keyboard, echoes it to the screen, and returns the character as its result value.

``` haskell
getChar :: IO Char
getChar = ...
```

(The actual definition for getChar is built into the GHC system.) If there are no characters waiting to be read from the keyboard, getChar waits until one is typed. The dual action, putChar c, writes the character c to the screen, and returns no result value, represented by the empty tuple:

``` haskell
putChar :: Char -> IO ()
putChar c = ...
```

Our final basic action is return v, which simply returns the result value v without performing any interaction with the user:

``` haskell
return :: a -> IO a
return v = ...
```

The function return provides a bridge from pure expressions without side effects to impure actions with side effects. Crucially, there is no bridge back — once we are impure we are impure for ever, with no possibility for redemption! As a result, we may suspect that impurity quickly permeates entire programs, but in practice this is usually not the case. For most Haskell programs, the vast majority of functions do not involve interaction, with this being handled by a relatively small number of interactive functions at the outermost level.

### **10.4Sequencing**

In Haskell, a sequence of IO actions can be combined into a single composite action using the do notation, whose typical form is as follows:

``` haskell
do v1 <- a1
v2 <- a2
.
.
.
vn <- an
return (f v1 v2 ... vn)
```

Such expressions have a simple operational reading: first perform the action a1 and call its result value v1; then perform the action a2 and call its result value v2; ...; then perform the action an and call its result value vn; and finally, apply the function f to combine all the results into a single value, which is then returned as the result value from the expression as a whole.

There are three further points to note about the do notation. First of all, the layout rule applies, in the sense that each action in the sequence must begin in precisely the same column, as illustrated above. Secondly, as with list comprehensions, the expressions vi \<- ai are called *generators*, because they generate values for the variables vi. And finally, if the result value produced by a generator vi \<- ai is not required, the generator can be abbreviated simply by ai, which has the same meaning as writing \_ \<- ai.

For example, an action that reads three characters, discards the second, and returns the first and third as a pair can now be defined as follows:

``` haskell
act :: IO (Char,Char)
act = do x <- getChar
getChar
y <- getChar
return (x,y)
```

Note that omitting the use of return in this example would give rise to a type error, because (x,y) is an expression of type (Char,Char), whereas in the above context we require an action of type IO (Char,Char).

### **10.5Derived primitives**

Using the three basic actions together with sequencing, we can now define a number of other useful action primitives that are provided in the standard prelude. First of all, we define an action getLine that reads a string of characters from the keyboard, terminated by the newline character ’\n’:

``` haskell
```

Note the use of recursion to read the rest of the string once the first character has been read. Dually, we define primitives putStr and putStrLn that write a string to the screen, and in the latter case also move to a new line:

``` haskell
```

For example, using these primitives we can now define an action that prompts for a string to be entered from the keyboard, and displays its length:

``` haskell
```

For example:

``` haskell
> strlen
Enter a string: Haskell
The string has 7 characters
```

### **10.6Hangman**

In the remainder of this chapter we present three extended programming examples, of increasing complexity. Our first example illustrates the basics of IO programming using a variant of the game *hangman*. At the start of the game, one player secretly enters a word. Another player then tries to deduce the word via a series of guesses. For each guess, we indicate which letters in the secret word occur in the guess, and the game ends when the guess is correct.

We implement the hangman game in a top-down manner, starting with a top-level action that prompts the first player to enter a secret word, and then asks the second player to try and guess it:

``` haskell
hangman :: IO ()
hangman = do putStrLn "Think of a word:"
word <- sgetLine
putStrLn "Try to guess it:"
play word
```

It now remains to complete the definitions for sgetLine and play. First of all, the action sgetLine reads a string of characters from the keyboard in a similar manner to the basic action getLine, except that it echoes each character as a dash symbol ’-’ in order to keep the string secret:

``` haskell
```

In turn, the action getCh used in this definition reads a single character from the keyboard without echoing it to the screen, and is defined by using the primitive hSetEcho from the library System.IO to turn input echoing off prior to reading the character, and back on again afterwards:

``` haskell
getCh :: IO Char
getCh = do hSetEcho stdin False
x <- getChar
hSetEcho stdin True
return x
```

(The primitive hSetEcho can be made available by including the declaration import System.IO at the start of a script.) We now return to the function play, which implements the main game loop by repeatedly prompting the second player to enter a guess until it equals the secret word:

``` haskell
```

In the case when the guess is not correct, we use a list comprehension to indicate which letters in the secret word occur anywhere in the guess:

``` haskell
match :: String -> String -> String
match xs ys = [if elem x ys then x else ’-’ | x <- xs]
```

The game is now complete, and can be tried out. For example, here is how the game might proceed if the secret word was nottingham:

``` haskell
> hangman
Think of a word:
----------
Try to guess it:
? glasgow
-o----g-a-
? utrecht
--tt---h--
? gothenburg
nott-ngh--
? nottingham
You got it!!
```

### **10.7Nim**

For our second example we consider a variant of the *game of nim*, played on a board comprising five numbered rows of stars, initially set up as follows:

![image](/tmp/audit/iter1/epubregen/programming-in-haskell-2e/media/Images/Chapter_10_image_7_37.png)

Two players then take it in turn to remove one or more stars from the end of a single row. The winner is the player who makes the board empty, that is, who removes the final star or stars from the board. To contrast with the top-down development of the hangman game in the previous section, we implement nim in a bottom-up manner, starting by defining a series of utility functions, which are then used to implement the game itself.

##### Game utilities

For simplicity, we represent the player number (1 or 2) as an integer, and use the following function to give the next player:

``` haskell
next :: Int -> Int
next 1 = 2
next 2 = 1
```

In turn, we represent the board as a list comprising the number of stars that remain on each row, with the initial board given by the list \[5,4,3,2,1\], and the game being finished when all rows have no stars left:

``` haskell
type Board = [Int]
initial :: Board
initial = [5,4,3,2,1]
finished :: Board -> Bool
finished = all (== 0)
```

A move in the game is specified by a row number and the number of stars to be removed, and is valid if the row contains at least this many stars:

``` haskell
valid :: Board -> Int -> Int -> Bool
valid board row num = board !! (row-1) >= num
```

(Recall that list indexing starts from zero, hence the use of subtraction above.) For example, valid initial 1 3 returns True, because the first row on the initial board contains at least three stars, whereas valid initial 4 3 returns False, because the fourth row contains fewer than three stars. A valid move can then be applied to a board to give an new board by using a list comprehension to update the number of stars that remain in each row:

``` haskell
move :: Board -> Int -> Int -> Board
move board row num = [update r n | (r,n) <- zip [1..] board]
where update r n = if r == row then n-num else n
```

For example, move initial 1 3 returns the new board \[2,4,3,2,1\] in which three stars have been removed from the first row.

##### IO utilities

We begin by defining a function that displays a row of the board on the screen, given the row number and the number of stars remaining:

``` haskell
```

Recall that the library function replicate produces a list with a given number of identical elements. For example, we have:

``` haskell
> putRow 1 5
1: * * * * *
```

In turn, putRow can then be used to display the board. For simplicity, we assume that the board always contains precisely five rows:

``` haskell
```

For example:

``` haskell
> putBoard initial
1: * * * * *
2: * * * *
3: * * *
4: * *
5: *
```

We also define a utility function getDigit that displays a prompt and reads a single character from the keyboard. If the character is a digit, the corresponding integer is returned as the result value, otherwise an error message is displayed and the user is reprompted to enter a digit:

``` haskell
```

(The function digitToInt :: Char -\> Int converts a digit to an integer, and can be made available by writing import Data.Char at the start of a script.) Finally, we define an action that moves onto a new line:

``` haskell
newline :: IO ()
newline = putChar ’\n’
```

##### Game of nim

Using the above utility functions, we can now implement the main game loop, which takes the current board and player number as arguments:

``` haskell
```

That is, we first display the board, and then check if the game is finished. If so, we display the other player as the winner, as they were the one who made the board empty. Otherwise we prompt the current player for the move they wish to make. If the move is valid, we update the board accordingly and then continue the game with the next player, otherwise we display an error message and reprompt the current player to enter a valid move.

Finally, the game of nim itself can then be implemented simply by invoking the game loop with the initial board and player number:

``` haskell
nim :: IO ()
nim = play initial 1
```

We conclude with two further remarks about our implementation of nim. First of all, note that because Haskell is a pure language, we needed to supply the game state, which in this case comprises the current board and player number, as explicit arguments to the play function. And secondly, note the separation between the pure parts of our implementation, in the form of the utility functions on players and boards, from the impure parts that involve input/output. It is good practice to try and maintain this kind of separation in Haskell programs, to minimise and localise the use of side effects.

### **10.8Life**

Our third and final interactive programming example concerns the *game of life*. The game models a simple evolutionary system based on cells, and is played on a two-dimensional board. Each square on the board is either empty, or contains a single living cell, as illustrated in the following example:

![image](/tmp/audit/iter1/epubregen/programming-in-haskell-2e/media/Images/Chapter_10_image_11_13.png)

Each internal square on the board has eight immediate neighbours:

![image](/tmp/audit/iter1/epubregen/programming-in-haskell-2e/media/Images/Chapter_10_image_11_14.png)

For uniformity, each external square on the board is also viewed as having eight neighbours, by assuming that the board wraps around from top-to-bottom and from left-to-right. That is, we can think of the board as really being a torus, the surface of a three-dimensional doughnut shaped object.

Given an initial configuration of the board, the next *generation* of the board is given by simultaneously applying the following rules to all squares:

- a living cell survives if it has precisely two or three neighbouring squares that contain living cells, and
- an empty square gives birth to a living cell if it has precisely three neighbours that contain living cells, and remains empty otherwise.

For example, applying these rules to the above board gives:

![image](/tmp/audit/iter1/epubregen/programming-in-haskell-2e/media/Images/Chapter_10_image_12_22.png)

By repeating this procedure with the new board, an infinite sequence of generations can be produced. By careful design of the initial configuration, many interesting patterns of behaviour can be observed in such sequences. For example, the above arrangement of cells is called a *glider*, and over successive generations will move diagonally down the board. Despite its simplicity, the game of life is in fact computationally complete, in the sense that any computational process can be simulated within it by means of a suitable encoding. In the remainder of this section we show how the game of life can be implemented in Haskell.

##### Screen utilities

We begin with some useful output utilities concerning the screen on which the game will be played. First of all, we define an action that clears the screen, which can be achieved by displaying the appropriate control characters:

``` haskell
cls :: IO ()
cls = putStr "\ESC[2J"
```

By convention, the position of each character on the screen is given by a pair (x,y) of positive integers, with (1,1) being the top-left corner. We represent such coordinate positions using the following type:

``` haskell
type Pos = (Int,Int)
```

We can then define a function that displays a string at a given position by using control characters to move the cursor to this position:

``` haskell
```

##### Game of life

For simplicity, we assumed that the board size for nim was fixed. For increased flexibility, we allow the board size for life to be modified, by means of two integer values that specify the size of the board in squares:

``` haskell
width :: Int
width = 10
height :: Int
height = 10
```

We represent a board as a list of the (x,y) positions at which there is a living cell, using the same coordinate convention as the screen:

``` haskell
type Board = [Pos]
```

For example, the initial example board above would be represented by:

``` haskell
glider :: Board
glider = [(4,2),(2,3),(4,3),(3,4),(4,4)]
```

Using this representation of the board, it is easy to display the living cells on the screen, and to decide if a given position is alive or empty:

``` haskell
showcells :: Board -> IO ()
showcells b = sequence_ [writeat p "O" | p <- b]
isAlive :: Board -> Pos -> Bool
isAlive b p = elem p b
isEmpty :: Board -> Pos -> Bool
isEmpty b p = not (isAlive b p)
```

(The library function sequence\_ :: \[IO a\] -\> IO () performs a list of actions in sequence, discarding their result values and returning no result.) Next, we define a function that returns the neighbours of a position:

``` haskell
```

The auxiliary function wrap takes account of the wrapping around at the edges of the board, by subtracting one from each component of the given position, taking the remainder when divided by the width and height of the board, and then adding one to each component again:

``` haskell
```

Using function composition, we can now define a function that calculates the number of live neighbours for a given position by producing the list of its neighbours, retaining those that are alive, and counting their number:

``` haskell
liveneighbs :: Board -> Pos -> Int
liveneighbs b = length . filter (isAlive b) . neighbs
```

Using this function, it is then straightforward to produce the list of living positions in a board that have precisely two or three living neighbours, and hence survive to the next generation of the game:

``` haskell
survivors :: Board -> [Pos]
survivors b = [p | p <- b, elem (liveneighbs b p) [2,3]]
```

In turn, the list of empty positions in a board that have precisely three living neighbours, and hence give birth to a new cell, can be produced as follows:

``` haskell
```

However, this definition considers every position on the board. A more refined approach, which may be more efficient for larger boards, is to only consider the neighbours of living cells, because only such cells can give rise to new births. Using this approach, the function births can be rewritten as follows:

``` haskell
```

The auxiliary function rmdups removes duplicates from a list, and is used above to ensure that each potential new cell is only considered once:

``` haskell
rmdups :: Eq a => [a] -> [a]
rmdups []= []
rmdups (x:xs) = x : rmdups (filter (/= x) xs)
```

The next generation of a board can now be produced simply by appending the list of survivors and the list of new births:

``` haskell
nextgen :: Board -> Board
nextgen b = survivors b ++ births b
```

Finally, we define a function life that implements the game of life itself, by clearing the screen, showing the living cells in the current board, waiting for a moment, and then continuing with the next generation:

``` haskell
life :: Board -> IO ()
life b = do cls
showcells b
wait 500000
life (nextgen b)
```

The function wait is used to slow down the game to a reasonable speed, and can be implemented by performing a given number of dummy actions:

``` haskell
wait :: Int -> IO ()
wait n = sequence_ [return () | _ <- [1..n]]
```

For fun, you might like to try out the life function with the glider example, and experiment with some patterns of your own. Note also that most of the definitions used to implement the game of life are pure functions, with only a small number of top-level definitions involving input/output. Moreover, the definitions that do have such side effects are clearly distinguishable from those that do not, through the presence of IO in their types.

### **10.9Chapter remarks**

The use of the IO type to perform other forms of side effects, including reading and writing from files, is discussed in the Haskell Report \[4\], and a formal meaning for this type is given in \[15\]. For specialised applications, a bridge back from impure actions to pure expressions is in fact available via the function unsafePerformIO :: IO a -\> a in the library System.IO.Unsafe. However, as suggested by the naming, this function is unsafe and should not be used in normal Haskell programs as it compromises the purity of the language.

### **10.10Exercises**

1.Redefine putStr :: String -\> IO () using a list comprehension and the library function sequence\_ :: \[IO a\] -\> IO ().

2.Using recursion, define a version of putBoard :: Board -\> IO () that displays nim boards of any size, rather than being specific to boards with just five rows of stars. Hint: first define an auxiliary function that takes the current row number as an additional argument.

3.In a similar manner to the first exercise, redefine the generalised version of putBoard using a list comprehension and sequence\_.

4.Define an action adder :: IO () that reads a given number of integers from the keyboard, one per line, and displays their sum. For example:

``` haskell
> adder
How many numbers? 5
1
3
5
7
9
The total is 25
```

Hint: start by defining an auxiliary function that takes the current total and how many numbers remain to be read as arguments. You will also likely need to use the library functions read and show.

5.Redefine adder using the function sequence :: \[IO a\] -\> IO \[a\] that performs a list of actions and returns a list of the resulting values.

6.Using getCh, define an action readLine :: IO String that behaves in the same way as getLine, except that it also permits the delete key to be used to remove characters. Hint: the delete character is ’\DEL’, and the control character for moving the cursor back one space is ’\b’.

Solutions to exercises 1–3 are given in appendix A.