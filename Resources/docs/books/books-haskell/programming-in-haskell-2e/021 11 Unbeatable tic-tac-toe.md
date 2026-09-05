## **11**

## Unbeatable tic-tac-toe

In this chapter we illustrate the concepts introduced so far by developing an interactive program that plays the game of tic-tac-toe. We start by implementing a version that allows two human players to compete against each other, and then develop a computer player that uses game trees and the minimax algorithm to ensure that it is unbeatable, that is, always wins or draws.

### **11.1Introduction**

Tic-tac-toe, also known as noughts and crosses, is a game that is traditionally played on a 3 × 3 grid, which is initially empty:

![image](/tmp/audit/iter1/epubregen/programming-in-haskell-2e/media/Images/Chapter_11_image_1_10.png)

Two players, ![image](/tmp/audit/iter1/epubregen/programming-in-haskell-2e/media/Images/Chapter_11_image_1_11.png) and ×, then take it in turn to place their mark in a blank space in the grid. The winner is the first player to place three of their marks in a horizontal, vertical, or diagonal line. For example, the grid below has three ×’s in the bottom row, and hence × is the winner:

![image](/tmp/audit/iter1/epubregen/programming-in-haskell-2e/media/Images/Chapter_11_image_1_12.png)

If the grid becomes fully occupied without either player having won, then the game ends in a draw, as in the following example:

![image](/tmp/audit/iter1/epubregen/programming-in-haskell-2e/media/Images/Chapter_11_image_1_13.png)

By playing in a perfect manner, that is, always making the best possible move at each turn, a player can always force a draw, independent of whether they go first or second in the game. In the remainder of this chapter we show how to implement a perfect tic-tac-toe player in Haskell.

### **11.2Basic declarations**

We begin by importing standard libraries that provide functions on characters, lists and input/output actions that will be used in our implementation:

``` haskell
import Data.Char
import Data.List
import System.IO
```

Rather than assuming that the tic-tac-toe grid has a fixed size of 3 × 3, we allow the size to be changed to any integer value greater than zero:

``` haskell
size :: Int
size = 3
```

We represent a grid as a list of lists of player values, with the assumption that the each of the inner lists, and the outer list, all have length size:

``` haskell
type Grid = [[Player]]
```

In turn, a player value is either O, B or X, where the extra value B represents a blank space that has not yet been occupied:

``` haskell
```

For example, the winning grid from the previous section can be represented by \[\[B,O,O\],\[O,X,O\],\[X,X,X\]\] :: Grid. The deriving clause above ensures that player values support the standard equality and ordering operators, and can be displayed on the screen. Recall that the ordering on constructors is determined by their position in the data declaration, hence we have O \< B \< X, which will be important when we consider the minimax algorithm.

The next player to move is given simply by swapping between O and X, with the case for the blank value B being included for completeness even though the function should never be applied to this value:

``` haskell
next :: Player -> Player
next O = X
next B = B
next X = O
```

### **11.3Grid utilities**

We make use of a number of utilities on tic-tac-toe grids. First of all, we define the empty grid by replicating the blank player value to create an empty row, and then replicating this row to create an empty grid:

``` haskell
empty :: Grid
empty = replicate size (replicate size B)
```

Conversely, a grid is full if all of its player values are non-blank:

``` haskell
full :: Grid -> Bool
full = all (/= B) . concat
```

The idea of applying concat to flatten a grid into a single list prior to processing its player values, as in the above definition, will be used in a number of other functions that we define. For example, we can decide whose turn it is by comparing the number of O’s and X’s in a flattened grid:

``` haskell
turn :: Grid -> Player
turn g = if os <= xs then O else X
where
os = length (filter (== O) ps)
xs = length (filter (== X) ps)
ps = concat g
```

Note that turn empty = O means that we are assuming player O goes first, which in our final implementation will be the human player.

We now turn our attention to deciding if the game has been won, that is, if a player has a complete line in any row, column, or either diagonal in the grid. Using local definitions to improve readability, this idea can be translated directly into a function that decides if a player wins in a grid:

``` haskell
```

The function transpose :: \[\[a\]\] -\> \[\[a\]\] used above is provided in the library Data.List, and takes a grid that is represented as a list of rows and reflects it about the main diagonal that runs from top-left to bottom-right, so that the columns become rows and vice-versa. For example:

``` haskell
> transpose [[1,2,3],[4,5,6],[7,8,9]]
[[1,4,7],[2,5,8],[3,6,9]]
```

In turn, the function diag returns the main diagonal of a grid:

``` haskell
diag :: Grid -> [Player]
diag g = [g !! n !! n | n <- [0..size-1]]
```

The other diagonal, from top-right to bottom-left, can then be obtained by first reversing each row in the grid, as in the definition of wins above. Finally, we can now define a function that decides if either player has won:

``` haskell
won :: Grid -> Bool
won g = wins O g || wins X g
```

### **11.4Displaying a grid**

For the purposes of displaying a tic-tac-toe grid on the screen, we seek to define a function with the following example behaviour:

``` haskell
```

This behaviour can readily be achieved using function composition:

``` haskell
putGrid :: Grid -> IO ()
putGrid =
putStrLn . unlines . concat . interleave bar . map showRow
where bar = [replicate ((size*4)-1) ’-’]
```

That is, we convert each row to a list of strings using showRow, insert a horizontal bar between each row using interleave, flatten the resulting nested list structure using concat, join all the strings together with a newline character at the each of each line using the library function unlines :: \[String\] -\> String, and finally, display the resulting string on the screen using putStrLn.

In turn, the function showRow converts a row to a list of strings, with a vertical bar of length three between each entry in the row:

``` haskell
```

The library function foldr1 used above behaves in a similar manner to foldr but can only be applied to non-empty lists, while zipWith behaves in the same way as zip but applies a given function to each pair of values in the resulting list. For example, showRow \[O,B,X\] returns the following list:

``` haskell
```

The two remaining functions simply convert a player value to a list of strings, and interleave a value between each element in a list:

``` haskell
```

### **11.5Making a move**

To identify where a player wishes to make a move during the game, we index each position in the grid by a natural number, starting from zero in the top-left corner and proceeding along each row in turn:

![image](/tmp/audit/iter1/epubregen/programming-in-haskell-2e/media/Images/Chapter_11_image_5_31.png)

Attempting to make a move at a particular index is valid if the index is within the appropriate range, and the position is currently blank:

``` haskell
valid :: Grid -> Int -> Bool
valid g i = 0 <= i && i < size^2 && concat g !! i == B
```

We now define a function that applies a move to a grid. In order to take account of the possibility that a move may be invalid, we return a list of grids as the result, with the convention that a singleton list denotes success in applying the move, and the empty list denotes failure:

``` haskell
move:: Grid -> Int -> Player -> [Grid]
move g i p =
if valid g i then [chop size (xs ++ [p] ++ ys)] else []
where (xs,B:ys) = splitAt i (concat g)
```

That is, if the move is valid we split the list of player values in the grid at the index where the move is being made, replace the blank player value with the given player, and then reform the grid once again. The library function splitAt breaks a list into two parts at a given index, and the auxiliary function chop breaks a list into maximal segments of a given length:

``` haskell
chop :: Int -> [a] -> [[a]]
chop n [] = []
chop n xs = take n xs : chop n (drop n xs)
```

### **11.6Reading a number**

To read a grid index from a human player, we define a function getNat that displays a prompt and reads a natural number from the keyboard. It is defined in a similar manner to the function getDigit for the nim game in chapter 10, except that it reads a natural number rather than a single digit:

``` haskell
```

The function isDigit :: Char -\> Bool used above is provided in the library Data.Char, and decides if a character is a numeric digit.

### **11.7Human vs human**

We now have the necessary machinery to implement tic-tac-toe for two human players. We define an action that implements the game using two mutually recursive functions that take the current grid and player as arguments:

``` haskell
tictactoe :: IO ()
tictactoe = run empty O
```

The first function simply displays the grid and invokes the second:

``` haskell
run :: Grid -> Player -> IO ()
run g p = do cls
goto (1,1)
putGrid g
run’ g p
```

(The screen utilities cls and goto were defined for the game of life in chapter 10.) In turn, the second function uses a series of guards to decide if the game is finished, and if not prompts the player for a move. If the move is invalid we display an error message and reprompt the player, otherwise we invoke the first function with the updated board and the next player:

``` haskell
```

The auxiliary function prompt is defined as follows:

``` haskell
prompt :: Player -> String
prompt p = "Player " ++ show p ++ ", enter your move: "
```

You may like to try the game out with a friend now! As with all the extended examples, the code is available from the website for the book.

### **11.8Game trees**

We now show how to develop a computer player for tic-tac-toe, based on the use of *game trees*. The basic idea is to build a tree structure that captures all possible ways in which the game can proceed from the current grid, and then use this tree to decide on the best next move to make.

By way of example, suppose that we are given the following tic-tac-toe grid, and it is player O’s turn to make a move:

![image](/tmp/audit/iter1/epubregen/programming-in-haskell-2e/media/Images/Chapter_11_image_8_7.png)

The player can place their mark in any of the three remaining blank spaces at positions 1, 2 and 8, giving three possible next grids:

![image](/tmp/audit/iter1/epubregen/programming-in-haskell-2e/media/Images/Chapter_11_image_8_8.png)

Now it is X’s turn to move, and we repeat the same process for each of these three grids, stopping when there is a winner or the grid is full. In this manner, we can produce the following game tree from the starting grid:

![image](/tmp/audit/iter1/epubregen/programming-in-haskell-2e/media/Images/Chapter_11_image_8_9.png)

For this example, we can see that player X wins if the game proceeds down the left or right spine of the tree, and player O wins otherwise. Hence, the game tree shows that the best next move for player O is the middle of the three possible moves at the top of the tree, as this guarantees a win for O, whereas either of the other two possible next moves can result in a win for X.

A suitable type for representing such trees can be declared as follows:

``` haskell
```

That is, a tree of a given type is a node that comprises a value of this type and a list of subtrees. There are three further points to note about this declaration. First of all, it is not specific to tic-tac-toe grids, but permits any type of values to be stored in the nodes; this will be important when we consider the minimax algorithm, which labels each grid in the game tree with additional information. Secondly, there is no constructor for leaves, because a node with an empty list of subtrees can play this role; this avoids having two possible representations for leaves, which could complicate the definition of functions on trees. And finally, the deriving clause ensures that trees can be displayed on the screen.

Using the above tree type, it is straightforward to define a function that builds a game tree from a given starting grid and player. We simply use the starting grid as the value for the root node, and then recursively build a game tree for each grid that results from the current player making a valid move, with the next player then being used to continue the process:

``` haskell
gametree :: Grid -> Player -> Tree Grid
gametree g p = Node g [gametree g’ (next p) | g’ <- moves g p]
```

In turn, the function moves that returns the list of valid moves is defined by first checking if the game is finished, in which case we return the empty list of grids, which serves to stop the recursion in gametree. Otherwise, we return all grids that result from making a move in a blank space:

``` haskell
```

### **11.9Pruning the tree**

As one may imagine, game trees can potentially become very large. For this reason, it is sometimes necessary to prune game trees to a particular depth, in order to limit the amount of time and memory that it takes to build the tree. To this end, we define a function that prunes a tree to a given depth:

``` haskell
prune :: Int -> Tree a -> Tree a
prune 0 (Node x _)= Node x []
prune n (Node x ts) = Node x [prune (n-1) t | t <- ts]
```

For example, prune 5 (gametree empty O) produces a game tree of maximum depth five starting from the empty grid with player O making the first move. Note that under lazy evaluation, only as much of the tree as required by the prune function will actually be produced. That is, grids beyond depth five in this example will never be generated by gametree.

We also define a constant that specifies the maximum depth of the game tree. On a modern machine it is feasible to generate the entire tree for a 3 × 3 grid, so we set the default depth to the maximum value required for grids of this size. For larger grids, it may be necessary to reduce this value.

``` haskell
depth :: Int
depth = 9
```

### **11.10Minimax algorithm**

Once we have produced a game tree, the *minimax algorithm* can then be used to determine the best next move. The algorithm starts by labelling every node in the tree with a player value in the following manner:

- Leaves (nodes with no subtrees) are labelled with the winning player at this point if there is one, and the blank player otherwise;
- Other nodes (with subtrees) are labelled with the *minimum* or *maximum* of the player labels from the child nodes one level down, depending on whose turn it is to move at this point: on player O’s turn we take the minimum of the child labels, and on X’s turn we take the maximum.

For example, applying the algorithm to the game tree from the previous section results in the following tree of player labels:

![image](/tmp/audit/iter1/epubregen/programming-in-haskell-2e/media/Images/Chapter_11_image_10_16.png)

For example, the leftmost leaf in the tree is labelled X because player X has won at this point, while the root node is labelled O because it is player O’s turn at this point and hence we take the minimum of the child labels X, O and X, which under the ordering O \< B \< X is given by the value O.

Using a series of guards to determine the label, the minimax algorithm can be translated directly into a function that labels a game tree, where the local definition ts’ applies the algorithm recursively to each subtree of a node, and ps selects the top labels from the resulting trees:

``` haskell
```

Once the game tree has been labelled in this manner, the best next move under the minimax algorithm is given by moving to any grid with the same label as the root node. Hence for our example tree, the best move is given by the second of the three possible moves from the initial grid, because this leads to a grid with the same label as the root node, namely player O. This is the best move at this point because it guarantees a win for player O, whereas either of the two other possible moves could lead to a win for player X.

Putting all the components together, we can now define a function that returns the best next move for a given tic-tac-toe grid and player:

``` haskell
```

That is, we first build the game tree up to the specified depth, then apply the minimax algorithm to label the tree, and finally select a grid whose player label is the same as that of the root node. There is always at least one ‘best move’, because selecting the minimum or maximum value from a non-empty (finite) list always results in a value that occurs in the list. If there is more than one best move, the above definition simply selects the first of these.

### **11.11Human vs computer**

It is now straightforward to modify our earlier tic-tac-toe program so that the computer takes on the role of one of the players. As with the countdown program in chapter 9, we use the GHC compiler to increase performance, and define the program using a top-level action called main:

``` haskell
main :: IO ()
main = do hSetBuffering stdout NoBufferingplay empty O
```

The function hSetBuffering is provided in the library System.IO, and is used above to turn output buffering off, which is by default turned on in GHC. As previously, the game itself is implemented using two mutually recursive functions, except that player X is now the computer player:

``` haskell
```

The operator \$! used in the definition of the function play’ forces evaluation of the best move for the computer player prior to the function play being invoked again, without which there may be a delay between clearing the screen and displaying the grid in play while the best move was then calculated under lazy evaluation. Controlling evaluation order in this manner is discussed further in chapter 15 when we consider lazy evaluation in more detail.

Finally, if all the definitions are placed into a file called tictactoe.hs, we can then compile the program and run the game:

``` haskell
$ ghc -O2 tictactoe.hs
[1 of 1] Compiling Main
Linking tictactoe ...
$ ./tictactoe

Player O, enter your move:
```

On a reasonable modern machine, the computer should take around one second to make its first move, with subsequent moves becoming progressively faster as the size of the game tree reduces. Note that because the computer always chooses the first move from the list of best moves, it may not always take the quickest route to a win, but it is guaranteed to be unbeatable!

### **11.12Chapter remarks**

For tic-tac-toe grids of size 3 × 3, it is feasible to generate the entire game tree. For larger grids, in addition to limiting the maximum depth of the tree, it may also be useful to reduce the size of the tree using *alpha-beta pruning* \[16\], which avoids generating parts of the game tree that have no possibility of leading to the best next move under the minimax algorithm.

### **11.13Exercises**

1.Using the function gametree, verify that there are 549,946 nodes in the complete game tree for a 3×3 tic-tac-toe game starting from the empty grid, and that the maximum depth of this tree is 9.

2.Our tic-tac-toe program always chooses the first move from the list of best moves. Modify the final program to choose a random move from the list of best moves, using the function randomRIO :: (Int,Int) -\> IO Int from System.Random to generate a random integer in the given range.

3.Alternatively, modify the final program to choose a move that attempts to take the quickest route to a win, by calculating the depths of resulting game trees and selecting a move that results in a tree with the smallest depth.

4.Modify the final program to:

a.let the user decide if they wish to play first or second;

b.allow the length of a winning line to also be changed;

c.generate the game tree once, rather than for each move;

d.reduce the size of game tree using alpha-beta pruning.

Solutions to exercises 1 and 2 are given in appendix A.