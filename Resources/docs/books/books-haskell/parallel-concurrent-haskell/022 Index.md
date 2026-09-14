## Index

### A note on the digital index

A link in an index entry is displayed as the section title in which that entry appears. Because some sections have multiple index markers, it is not unusual for an entry to have several links to the same section. Clicking on any link will take you directly to the place in the text in which the marker appears.

### Symbols

! operator  
in Accelerate, Arrays and Indices  

in Repa, Arrays, Shapes, and Indices  

indexing arrays with, Indexing Arrays  

\$ operator (infix operator), MVar as a Container for Shared State  

\$! operator, MVar as a Container for Shared State  

-02 optimization option, Example: Computing Shortest Paths  

```cpp
-A (RTS option), RTS Options to Tweak

-C (RTS option), RTS Options to Tweak
```

-ddump-cc option, Debugging the CUDA Backend  

-dverbose option, Debugging the CUDA Backend  

-fllvm optimization option, Example: Computing Shortest Paths  

```cpp
-I (RTS option), RTS Options to Tweak

-k (RTS option), Thread Creation and MVar Operations

-N(RTS option), RTS Options to Tweak

-qa (RTS option), RTS Options to Tweak

-s (RTS option), Example: Parallelizing a Sudoku Solver
```

-threaded option, Parallelizing the Program  

/quit::, A Chat Server  

:. constructor, Arrays, Shapes, and Indices, Arrays and Indices  

\>-\> operator, Example: Shortest Paths  

### A

Accelerate, GPU Programming with Accelerate–Zipping Two Arrays  
Arrays class, Running a Simple Accelerate Computation  

arrays in, Arrays and Indices–Arrays and Indices  

conditionals, working with, Example: A Mandelbrot Set Generator–Example: A Mandelbrot Set Generator  

constant function, Constants  

creating arrays, Creating Arrays Inside Acc–Creating Arrays Inside Acc  

debugging, Debugging the CUDA Backend  

Elt class, Running a Simple Accelerate Computation  

GPUs, programming with, GPU Programming with Accelerate–GPU Programming with Accelerate  

implementing Floyd-Warshall algorithm, Example: Shortest Paths–Debugging the CUDA Backend  

indices in, Arrays and Indices–Arrays and Indices  

Mandelbrot set generator in, Example: A Mandelbrot Set Generator–Example: A Mandelbrot Set Generator  

programs, executing, Running a Simple Accelerate Computation–Running a Simple Accelerate Computation  

Shape class, Running a Simple Accelerate Computation  

type classes in, Running a Simple Accelerate Computation  

accept operation, for multiclient servers, A Trivial Server  

addition, in Accelerate, Example: A Mandelbrot Set Generator  

addToPointSum function, Example: The K-Means Problem  

adjacency matrix  
algorithms run over, Example: Shortest Paths in a Graph  

defined, Example: Computing Shortest Paths  

foldS function with, Folding and Shape-Polymorphism  

Amdahls law, Example: Parallelizing a Sudoku Solver  

Applicative type class, Example: Shortest Paths in a Graph  

arrays  
delayed, Operations on Arrays–Operations on Arrays  

large-scale, Data Parallel Programming with Repa  

manifest, Operations on Arrays  

nested, Arrays and Indices  

unboxed, Operations on Arrays  

Arrays class (Accelerate), Running a Simple Accelerate Computation  

arrays in Accelerate, Arrays and Indices–Arrays and Indices  
creating, Creating Arrays Inside Acc–Creating Arrays Inside Acc  

indexing, Indexing Arrays  

of dimensionality one, Arrays and Indices  

of dimensionality zero, Arrays and Indices  

of tuples, working with, Example: A Mandelbrot Set Generator–Example: A Mandelbrot Set Generator  

passing inputs as, Example: Shortest Paths  

scalar, Scalar Arrays  

zipping, Zipping Two Arrays  

zipWith function, Zipping Two Arrays  

arrays in Repa, Arrays, Shapes, and Indices–Operations on Arrays  
folding, Folding and Shape-Polymorphism–Folding and Shape-Polymorphism  

operations on, Operations on Arrays–Operations on Arrays  

shape-polymorphism, Folding and Shape-Polymorphism–Folding and Shape-Polymorphism  

assign function  
in K-Means problem, Example: The K-Means Problem  

parallelizing, Parallelizing K-Means  

associativity (foldP), Folding and Shape-Polymorphism  

Async API, How to Achieve Parallelism with Concurrency  
automatically canceled with thread death, Avoiding Thread Leakage  

avoiding thread leakage with, Avoiding Thread Leakage  

cancellation of, mask and forkIO  

for asynchronous actions, Overlapping Input/Output  

implementing with STM, Async Revisited–Async Revisited  

to implement programs, Parallel Version  

Async computations, errors inside, Parallel Version  

asynchronous actions, wait function for, Overlapping Input/Output  

asynchronous cancellation, Cancellation and Timeouts  

asynchronous exceptions, Cancellation and Timeouts–Asynchronous Exceptions: Discussion  
bracket function, The bracket Operation  

cancellations, Asynchronous Exceptions–Asynchronous Exceptions  

catching, Catching Asynchronous Exceptions–Catching Asynchronous Exceptions  

channel safety, Asynchronous Exception Safety for Channels–Asynchronous Exception Safety for Channels  

defined, Asynchronous Exceptions  

foreign out-calls and, Asynchronous Exceptions and Foreign Calls–Asynchronous Exceptions and Foreign Calls  

forkIO function, mask and forkIO–mask and forkIO, Asynchronous Exceptions: Discussion  

in STM, Asynchronous Exception Safety  

mask function, mask and forkIO–mask and forkIO, Asynchronous Exceptions: Discussion  

masking, Masking Asynchronous Exceptions–Masking Asynchronous Exceptions, Setting Up a New Client  

timeouts and, Timeouts–Timeouts  

asynchronous I/O, Overlapping Input/Output–Merging  
exceptions, handling, Error Handling with Async–Error Handling with Async  

exceptions, throwing, Exceptions in Haskell–Exceptions in Haskell  

merging, Merging–Merging  

MVar and, Overlapping Input/Output–Overlapping Input/Output  

atomic blocks, as language construct, Software Transactional Memory  

atomicModifyIORef, Limiting the Number of Threads with a Semaphore, Shared Concurrent Data Structures  

### B

backtracking, Example: A Conference Timetable  

bandwith, saving with distributed servers, A Distributed Chat Server  

bang-pattern, Limiting the Number of Threads with a Semaphore  

Binary class, Defining a Message Type–Defining a Message Type  

binary package, Defining a Message Type–Defining a Message Type  

BlockedIndefinitelyOnMVar exception, Communication: MVars, Detecting Deadlock  

blocking  
and interruptible operations, Masking Asynchronous Exceptions  

by throwTo, Timeouts  

in STM, Blocking, What Can We Not Do with STM?, Performance  

in takeMVar operation, Detecting Deadlock  

with bracket function, The bracket Operation  

with orElse operator, Merging with STM  

BlockReason data type, Inspecting the Status of a Thread  

bottlenecks, in parallel programs, Limiting the Number of Threads with a Semaphore  

bound threads, Threads and Foreign Out-Calls  
foreign in-calls as, Threads and Foreign In-Calls  

main threads as, Threads and Foreign Out-Calls  

bounded channels, Bounded Channels–Bounded Channels  

bracket function, The bracket Operation  
and conditional functions, Setting Up a New Client  

and exceptions, Asynchronous Exceptions  

defined with mask, The bracket Operation  

finally function, Exceptions in Haskell  

for asynchronous exception safety, Asynchronous Exceptions: Discussion  

for canceling an async, Avoiding Thread Leakage  

broadcast channels, Design Three: Use a Broadcast Chan, Recap  

browsers, interrupting several activiites with, Cancellation and Timeouts  

buffer size, with parBuffer, Parallelizing Lazy Streams with parBuffer  

### C

C, threading models in, Concurrency and the Foreign Function Interface  

callbacks  
concurrency vs., Terminology: Parallelism and Concurrency  

GUI, Threads and Foreign In-Calls  

calls  
foreign, Performance and Analysis  

nesting, The Par Monad Compared to Strategies, Masking Asynchronous Exceptions, Parallel Version  

recursive, Example: Shortest Paths in a Graph, Adding Parallelism, Catching Asynchronous Exceptions  

cancel, Asynchronous Exceptions  

catch function, Exceptions in Haskell, Catching Asynchronous Exceptions  
infix use of, Exceptions in Haskell  

catchSTM, Asynchronous Exception Safety  

centroids  
computing, Example: The K-Means Problem  

defined, Example: The K-Means Problem  

Chan, MVar as a Building Block: Unbounded Channels–MVar as a Building Block: Unbounded Channels  
merging events into single, Merging with STM  

TChan vs., Implementing Channels with STM  

channel abstraction, An Alternative Channel Implementation  

channels  
adding elements to, MVar as a Building Block: Unbounded Channels  

asynchronous exceptions and, Asynchronous Exception Safety for Channels–Asynchronous Exception Safety for Channels  

broadcast, Design Three: Use a Broadcast Chan  

ClientInput events carried by, Design Two: One Chan Per Server Thread  

constructing new, MVar as a Building Block: Unbounded Channels  

duplicate, MVar as a Building Block: Unbounded Channels  

empty, MVar as a Building Block: Unbounded Channels, MVar as a Building Block: Unbounded Channels  

implementing, MVar as a Simple Channel: A Logging Service–MVar as a Simple Channel: A Logging Service, Implementing Channels with STM–Asynchronous Exception Safety  

one-place, Communication: MVars–Communication: MVars  

pushing values on end of, MVar as a Building Block: Unbounded Channels  

read and write pointers of, MVar as a Building Block: Unbounded Channels  

removing values from, MVar as a Building Block: Unbounded Channels  

typed channels vs., Handling Failure  

typed, in distributed programming, Typed Channels–Merging Channels  

unbounded, MVar as a Building Block: Unbounded Channels–MVar as a Building Block: Unbounded Channels  

chat server  
architecture, Architecture  

client data in, Client Data  

implementing, A Chat Server–Recap  

running client threads in, Running the Client  

server data, Server Data  

setting up new clients in, Setting Up a New Client  

checkAddClient function, Setting Up a New Client  

checkValue operation, Asynchronous Exception Safety  

chunking  
and parallelizing, Example: Parallelizing a Sudoku Solver  

in K-Means problem, Performance and Analysis  

number of chunks and runtime, Granularity–Granularity  

with granularity problems, Limiting the Number of Threads with a Semaphore  

client data, in chat server, Client Data  

client input events  
and server architecture, Architecture  

carrying of, by channels, Design Two: One Chan Per Server Thread  

on broadcast channels, Design Three: Use a Broadcast Chan  

client threads, in chat server, Running the Client  

clients, local vs. remote in distributed systems, Data Types  

clientSendChan, Client Data  

Closure, The Master Process  

Cluster (type)  
from PointSum, Example: The K-Means Problem  

in Lloyds algorithm, Example: The K-Means Problem  

representation of, Example: The K-Means Problem  

clusters, partitioning data points into, Example: The K-Means Problem–Performance and Analysis  

Command constructor, Client Data  

command function, The Implementation  

command-line parameters, Limiting the Number of Threads with a Semaphore  

communication  
between distributed processes, Distributed Programming  

between server and client, A Trivial Server  

of threads, Communication: MVars–Communication: MVars  

compilers  
deadlock detection by, Detecting Deadlock  

for functional language, Example: A Parallel Type Inferencer  

complex numbers  
addition of, Example: A Mandelbrot Set Generator  

multiplication of, Example: A Mandelbrot Set Generator  

composability, of STM operations, Running Example: Managing Windows  

composable atomicity, Summary  

composable blocking, Summary  

composite operations (in STM), Composition of Blocking Operations  

compute-bound program, Example: Searching for Files  

computeP function, Parallelizing the Program, Parallelizing the Program–Parallelizing the Program  

computeS function  
and building of adjacency matrix, Example: Computing Shortest Paths  

and delayed arrays, Operations on Arrays  

computeP vs., Parallelizing the Program–Parallelizing the Program, Parallelizing the Program  

concurrency, Terminology: Parallelism and Concurrency–Terminology: Parallelism and Concurrency, Basic Concurrency: Threads and MVars–Fairness, Higher-Level Concurrency Abstractions–Summary: The Async API  
channels, implementing, MVar as a Simple Channel: A Logging Service–MVar as a Simple Channel: A Logging Service  

CPU usage and, Fairness–Fairness  

data structures, shared, Shared Concurrent Data Structures–Shared Concurrent Data Structures  

deadlock, detecting, Detecting Deadlock–Detecting Deadlock  

debugging, Debugging Concurrent Programs–Event Logging and ThreadScope  

fairness of, Fairness–Fairness  

FFI and, Concurrency and the Foreign Function Interface  

Functor instances and, Adding a Functor Instance–Adding a Functor Instance  

MVars, Communication: MVars–MVar as a Building Block: Unbounded Channels  

parallelism, achieving with, How to Achieve Parallelism with Concurrency–How to Achieve Parallelism with Concurrency  

race operation, Timeouts Using race–Timeouts Using race  

shared state, MVar as a Container for Shared State–MVar as a Container for Shared State  

symmetric combinators, Symmetric Concurrency Combinators–Timeouts Using race  

thread leakage, Avoiding Thread Leakage–Avoiding Thread Leakage  

timeouts, Timeouts Using race–Timeouts Using race  

tuning, Tuning Concurrent (and Parallel) Programs–RTS Options to Tweak  

unbounded channels, MVar as a Building Block: Unbounded Channels–MVar as a Building Block: Unbounded Channels  

concurrent search, of multiple subdirectories, Parallel Version  

concurrent web servers, Introduction  

concurrently function, Symmetric Concurrency Combinators  

conditional operations, in Accelerate, Example: A Mandelbrot Set Generator  

constant function (Accelerate), Constants  

constraint satisfaction problems, Example: A Conference Timetable–Adding Parallelism  
parallel skeletons and, Adding Parallelism–Adding Parallelism  

constructors  
:., Arrays, Shapes, and Indices, Arrays and Indices  

Fork, Rate-Limiting the Producer  

MaskedInterruptible, Masking Asynchronous Exceptions  

MaskedUninterruptible, Masking Asynchronous Exceptions  

Message, MVar as a Simple Channel: A Logging Service  

Stop, MVar as a Simple Channel: A Logging Service  

TNil, Implementing Channels with STM  

Unmasked, Masking Asynchronous Exceptions  

Z, Arrays, Shapes, and Indices  

contention, MVar and, Limiting the Number of Threads with a Semaphore  

context-switch performance, efficiency of, Thread Creation and MVar Operations  

Control.Deepseq module, Deepseq–Deepseq  

converted sparks, Example: Parallelizing a Sudoku Solver  

cost model of STM, Performance  

CPUs, GPUs vs., GPU Programming with Accelerate  

Ctrl+C, A Trivial Server  

CUDA language, GPU Programming with Accelerate  
debugging, Debugging the CUDA Backend  

support in Accelerate for, Running on the GPU  

### D

data dependencies, Dataflow Parallelism: The Par Monad  

data parallelism  
defined, Pipeline Parallelism  

pipeline parallelism vs., Limitations of Pipeline Parallelism  

data structure(s)  
evaluating compuations with, Lazy Evaluation and Weak Head Normal Form  

invariants of, Asynchronous Exception Safety for Channels  

MVar as building blocks for, Communication: MVars, MVar as a Building Block: Unbounded Channels–MVar as a Building Block: Unbounded Channels  

MVar wrappers for, MVar as a Container for Shared State  

representing channel contents, An Alternative Channel Implementation  

shared concurrent, Shared Concurrent Data Structures–Shared Concurrent Data Structures  

to store logs, Performance  

dataflow, Dataflow Parallelism: The Par Monad–The Par Monad Compared to Strategies  
and constraint satisfaction problems, Example: A Conference Timetable–Adding Parallelism  

and Floyd-Warshall algorithm, Example: Shortest Paths in a Graph–Example: Shortest Paths in a Graph  

pipleline paralellism and, Pipeline Parallelism–Limitations of Pipeline Parallelism  

type inference engines, Example: A Parallel Type Inferencer–Example: A Parallel Type Inferencer  

dataflow graphs, Dataflow Parallelism: The Par Monad  

deadlock  
and empty channels, MVar as a Building Block: Unbounded Channels  

caused by writeTBQueue, Bounded Channels  

error codes vs., Error Handling with Async  

mutual, Detecting Deadlock  

deadlock detection, Detecting Deadlock–Detecting Deadlock  
and MVar, Communication: MVars  

of mutual deadlock, Detecting Deadlock  

death, thread, Higher-Level Concurrency Abstractions, Avoiding Thread Leakage  

debugging  
Accelerate programs, Debugging the CUDA Backend  

concurrent programs, Debugging Concurrent Programs–Event Logging and ThreadScope  

CUDA, Debugging the CUDA Backend  

deadlock, detecting, Detecting Deadlock–Detecting Deadlock  

event logging, Event Logging and ThreadScope–Event Logging and ThreadScope  

monitor function, Handling Failure  

thread status, inspecting, Inspecting the Status of a Thread–Inspecting the Status of a Thread  

ThreadScope, Event Logging and ThreadScope–Event Logging and ThreadScope  

with getMaskingState function, Masking Asynchronous Exceptions  

withMonitor function, Handling Failure  

decrypt function, Pipeline Parallelism  

deeply-embedded domain-specific languages, Overview  

DeepSeq (Control module), Deepseq–Deepseq  

degrees of evaluation, Deepseq  

delayed arrays  
computeS function and, Operations on Arrays  

defined, Operations on Arrays  

from fromFunction operation, Operations on Arrays  

indexing, Operations on Arrays  

depth threshold  
for divide-and-conquer algorithms, Limiting the Number of Threads with a Semaphore  

for tree-shaped parallelism, Adding Parallelism  

DeriveGeneric extension (Binary class), Defining a Message Type  

Desktops  
for displays, Running Example: Managing Windows  

MVars for, Running Example: Managing Windows  

deterministic parallel programming, Terminology: Parallelism and Concurrency–Terminology: Parallelism and Concurrency  

DevIL library, Example: Image Rotation–Summary  

Dining Philosophers problem, Running Example: Managing Windows, Bounded Channels  

Direct scheduler (monad-par library), Using Different Schedulers  

distributed fault-tolerant key-value store, Exercise: A Distributed Key-Value Store  

distributed programming, Distributed Programming–Exercise: A Distributed Key-Value Store  
clients, local vs. remote, Data Types  

failures, handling, Handling Failure–The Philosophy of Distributed Failure  

implementing, A First Example: Pings–Summing Up the Ping Example  

main function and, The main Function–The main Function  

master process for, The Master Process–The Master Process  

multi-node, Multi-Node Ping–Running on Multiple Machines  

ping example, A First Example: Pings–Summing Up the Ping Example  

server process for, The Ping Server Process–The Ping Server Process  

server, implementing, A Distributed Chat Server–Failure and Adding/Removing Nodes  

typed channels and, Typed Channels–Merging Channels  

distributed servers, implementing, A Distributed Chat Server–Failure and Adding/Removing Nodes  
broadcasting messages, Broadcasting–Broadcasting  

data types for, Data Types–Data Types  

failures, handling, Failure and Adding/Removing Nodes–Failure and Adding/Removing Nodes  

handling distribution, Distribution–Distribution  

messages, sending, Sending Messages  

nodes, adding/removing, Failure and Adding/Removing Nodes–Failure and Adding/Removing Nodes  

testing, Testing the Server  

distributed-process framework, Distributed Programming–Exercise: A Distributed Key-Value Store  
packages in, The Distributed-Process Family of Packages–The Distributed-Process Family of Packages  

parallelism vs., Distributed Concurrency or Parallelism?  

Process monad, Processes and the Process Monad  

usage, A First Example: Pings–Summing Up the Ping Example  

distributed-process-simplelocalnet package, The main Function  

divide-and-conquer algorithms  
defined, Example: A Conference Timetable  

depth threshold for, Limiting the Number of Threads with a Semaphore  

doesDirectoryExist, How to Achieve Parallelism with Concurrency–How to Achieve Parallelism with Concurrency  

duds (sparks), Example: Parallelizing a Sudoku Solver  

dupChan operation, MVar as a Building Block: Unbounded Channels  

duplicate channels, creating, MVar as a Building Block: Unbounded Channels  

dynamic partitioning, Example: Parallelizing a Sudoku Solver  

### E

effectful code, Terminology: Parallelism and Concurrency  

effects, interleaving of, Basic Concurrency: Threads and MVars  

efficiency  
of concurrency operations, Thread Creation and MVar Operations–Thread Creation and MVar Operations  

of context-switch performance, Thread Creation and MVar Operations  

elapsed time, Example: Parallelizing a Sudoku Solver  

Elt class (Accelerate), Running a Simple Accelerate Computation  

empty channels, MVar as a Building Block: Unbounded Channels, MVar as a Building Block: Unbounded Channels  

encrypt function, Pipeline Parallelism  

enumFromN operation, Creating Arrays Inside Acc  

enumFromStepN operation, Creating Arrays Inside Acc  

Env data type, Example: A Parallel Type Inferencer  

environment, in programming language, Example: A Parallel Type Inferencer  

Erlang (programming language), The Philosophy of Distributed Failure  

error codes, deadlocking vs., Error Handling with Async  

error handling  
and ParIO, The ParIO monad  

and propagating exceptions, Error Handling with Async  

in concurrent programming, Overlapping Input/Output  

ErrorCall, Exceptions in Haskell  

Eval computation, Evaluation Strategies  

Eval monad, The Eval Monad, rpar, and rseq  
rpar operation, The Eval Monad, rpar, and rseq  

rseq operation, The Eval Monad, rpar, and rseq  

Strategy function in, Evaluation Strategies  

evalList Strategy, A Strategy for Evaluating a List in Parallel–A Strategy for Evaluating a List in Parallel  

evalPair Strategy, Parameterized Strategies  

evaluation(s)  
degrees of, Deepseq  

in Haskell, Lazy Evaluation and Weak Head Normal Form  

lazy, Lazy Evaluation and Weak Head Normal Form–Lazy Evaluation and Weak Head Normal Form, MVar as a Container for Shared State, Shared Concurrent Data Structures  

sequential, The Eval Monad, rpar, and rseq  

event loops  
concurrency vs., Terminology: Parallelism and Concurrency  

web server implementations with, A Trivial Server  

eventlog file, Event Logging and ThreadScope–Event Logging and ThreadScope  

Exception data type, Exceptions in Haskell  

exception handlers  
and asynchronous exceptions, Catching Asynchronous Exceptions  

hidden inside try, Catching Asynchronous Exceptions  

higher-level combinators as, Exceptions in Haskell  

installing, for Async, Avoiding Thread Leakage  

tail-calling of, Catching Asynchronous Exceptions  

exception handling  
and forkFinally, mask and forkIO  

by forkIO function, Inspecting the Status of a Thread  

in asynchronous I/O, Error Handling with Async–Error Handling with Async  

Exception type class, Exceptions in Haskell  

exceptions  
and thread status, Inspecting the Status of a Thread  

BlockedIndefinitelyOnMVar, Communication: MVars, Detecting Deadlock  

catch function for, Exceptions in Haskell  

catching, Exceptions in Haskell, Exceptions in Haskell  

in STM, Asynchronous Exception Safety  

propagating, with error-handling code, Error Handling with Async  

re-throwing, Exceptions in Haskell  

ThreadKilled, Asynchronous Exceptions  

throwing, Exceptions in Haskell–Exceptions in Haskell  

with timeouts, Timeouts Using race  

expect function, The Ping Server Process, Typed Channels  

extent operation for shapes, Arrays, Shapes, and Indices  

### F

F representation type (Repa), Example: Image Rotation  

fairness, Fairness–Fairness  
in MVar, What Can We Not Do with STM?  

in TMVar implementation, What Can We Not Do with STM?  

policy, Basic Concurrency: Threads and MVars  

FFI (foreign function interface), Concurrency and the Foreign Function Interface  
foreign in-calls, Threads and Foreign In-Calls  

threads and, Threads and Foreign Out-Calls–Threads and Foreign Out-Calls  

fib function, Dataflow Parallelism: The Par Monad  

FIFO order, What Can We Not Do with STM?  

filesystem-searching program (example), Example: Searching for Files, The ParIO monad  

fill operation, Creating Arrays Inside Acc  

finally function  
and exceptions, Asynchronous Exceptions  

as bracket function, Exceptions in Haskell  

find function  
and NBSem, Limiting the Number of Threads with a Semaphore  

as recursive, How to Achieve Parallelism with Concurrency–How to Achieve Parallelism with Concurrency  

in ParIO monad, The ParIO monad  

to create new Async, Parallel Version  

findpar  
findseq vs., Performance and Scaling  

NBSem vs., Limiting the Number of Threads with a Semaphore  

findseq, Performance and Scaling  

fixed division, of work, Example: Parallelizing a Sudoku Solver  

fizzled sparks, Example: Parallelizing a Sudoku Solver  

floating-point addition, Folding and Shape-Polymorphism  

Floyd-Warshall algorithm, Example: Shortest Paths in a Graph–Example: Shortest Paths in a Graph  
Accelerate, implementing in, Example: Shortest Paths–Debugging the CUDA Backend  

over dense graphs, Example: Computing Shortest Paths  

pseudocode definition of, Example: Computing Shortest Paths  

Repa, using over dense graphs, Example: Computing Shortest Paths–Parallelizing the Program  

fmap operation, Adding a Functor Instance  

folding, of concurrently function over a list, Symmetric Concurrency Combinators  

foldl function, Example: Shortest Paths in a Graph  

foldP, folding in parallel with, Folding and Shape-Polymorphism  

folds  
over arrays, Folding and Shape-Polymorphism–Folding and Shape-Polymorphism  

parallelized, Example: Shortest Paths in a Graph  

foldS function, Folding and Shape-Polymorphism  

force function, Example: Parallelizing a Sudoku Solver  

foreign calls, Performance and Analysis  

foreign in-calls, Threads and Foreign In-Calls  

foreign out-calls  
asynchronous exceptions and, Asynchronous Exceptions and Foreign Calls–Asynchronous Exceptions and Foreign Calls  

threads and, Threads and Foreign Out-Calls–Threads and Foreign Out-Calls  

fork(s), Rate-Limiting the Producer  
achieving parallelism with, How to Achieve Parallelism with Concurrency  

defined, Pipeline Parallelism  

in Par computations, Dataflow Parallelism: The Par Monad  

number of, How to Achieve Parallelism with Concurrency  

producing lists with, Rate-Limiting the Producer  

forkFinally function, mask and forkIO, A Trivial Server  

forkIO function, mask and forkIO–mask and forkIO, Asynchronous Exceptions: Discussion  
defined, Basic Concurrency: Threads and MVars  

exception handling by, Inspecting the Status of a Thread  

Process monad and, Data Types  

variant of, mask and forkIO  

forkOS, Threads and Foreign Out-Calls, Threads and Foreign Out-Calls  

freeVars function, Example: A Parallel Type Inferencer  

fromFunction operation, Example: Computing Shortest Paths  
delayed arrays from, Operations on Arrays  

fromListUnboxed function, Arrays, Shapes, and Indices  
building arrays in Accelerate with, Arrays and Indices  

functional language, compiler for, Example: A Parallel Type Inferencer  

Functor instances, Adding a Functor Instance–Adding a Functor Instance  

fusion (in Repa), Operations on Arrays  

### G

garbage collector  
closing of Handle by, A Trivial Server  

heap objects and, Detecting Deadlock  

garbage-collected (GCd) sparks, Example: Parallelizing a Sudoku Solver, GC’d Sparks and Speculative Parallelism  

generate function  
in Accelerate, Creating Arrays Inside Acc  

in Timetable example, Example: A Conference Timetable  

get operation, Dataflow Parallelism: The Par Monad  

getDirectoryContents, How to Achieve Parallelism with Concurrency–How to Achieve Parallelism with Concurrency  

getMaskingState function, Masking Asynchronous Exceptions  

getNumCapabilities, Limiting the Number of Threads with a Semaphore  

getSelfNode function, The Master Process  

getWindows, Blocking Until Something Changes  

GHC Users Guide, Tools and Resources  

ghc-events program, displaying raw event streams with, Event Logging and ThreadScope  

global locks, Performance  

GPUs (graphics processing units)  
Accelerate without, Overview  

CPUs vs., GPU Programming with Accelerate  

programming with Accelerate, GPU Programming with Accelerate–GPU Programming with Accelerate  

running programs on, Running on the GPU–Running on the GPU  

granularity  
Eval and finer, The Par Monad Compared to Strategies  

in parallelizing maps, Example: Shortest Paths in a Graph  

larger, Par and, The Par Monad Compared to Strategies  

of K-Means problem, Granularity–Granularity  

problems from parallelizing, Example: A Parallel Type Inferencer  

problems with, Limiting the Number of Threads with a Semaphore  

when adding parallelism, Adding Parallelism  

GUI callback, Threads and Foreign In-Calls  

GUI libraries, calling foreign functions by, Threads and Foreign Out-Calls  

### H

Hackage  
documentation on, Tools and Resources  

libraries on, Introduction  

Handle  
closing of, A Trivial Server  

for communication of server and client, A Trivial Server  

interleaving messages to, Design One: One Giant Lock  

handle function, catching exceptions with, Exceptions in Haskell  

handleJust, Timeouts  

handleMessage function, Running the Client  

Haskell  
2010 standard, exceptions in, Exceptions in Haskell  

98 standard, exceptions in, Exceptions in Haskell  

as lazy language, Lazy Evaluation and Weak Head Normal Form  

web server implementations in, A Trivial Server  

Haskell Platform  
components of, Tools and Resources  

library documentation, Tools and Resources  

Hoogle, Tools and Resources  

HTTP library, Asynchronous Exceptions  

hyperthreaded cores, RTS Options to Tweak  

### I

I/O, Overlapping Input/Output–Merging  

I/O manager thread, A Trivial Server  

I/O-bound program, Example: Searching for Files  

identity property, The Identity Property–The Identity Property  

IL monad, Example: Image Rotation  

IList data type  
defined, Pipeline Parallelism  

long chain in, Rate-Limiting the Producer  

image processing, parallel array operations for, Introduction  

image rotation, Example: Image Rotation–Example: Image Rotation  

immutable data structures, MVar wrappers for, MVar as a Container for Shared State  

imperative languages  
and code modifying state, Cancellation and Timeouts  

locks in, MVar as a Container for Shared State  

implicit masks, Catching Asynchronous Exceptions  

inconsistent state  
data left in, Masking Asynchronous Exceptions  

of data, after cancellation, Cancellation and Timeouts  

indexArray operation, Arrays and Indices  

indexing  
arrays, in Accelerate, Arrays and Indices, Indexing Arrays  

delayed arrays, Operations on Arrays  

inferBind, Example: A Parallel Type Inferencer  

inferTop, Example: A Parallel Type Inferencer  

infix application (\$ operator), MVar as a Container for Shared State  

initLogger function, MVar as a Simple Channel: A Logging Service  

INLINE pragmas (Repa), Example: Image Rotation–Summary  

insert operation, MVar as a Container for Shared State  

interleaving messages, Design One: One Giant Lock  

interleaving of effects, Basic Concurrency: Threads and MVars  

interpreter (Accelerate), GPU Programming with Accelerate  

interruptible operations, Masking Asynchronous Exceptions–Masking Asynchronous Exceptions  

interruption, mask and forkIO–mask and forkIO, Asynchronous Exceptions: Discussion  

IntMap function, Example: Shortest Paths in a Graph  

IO action  
in ParIO, The ParIO monad  

in STM, What Can We Not Do with STM?  

IO monad  
cancellation in, Cancellation and Timeouts  

catching exceptions in, Exceptions in Haskell  

Process monad vs., Processes and the Process Monad  

safety of code for, Asynchronous Exceptions: Discussion  

STM monad performed in, Running Example: Managing Windows  

IOException data type, building and inspecting, Exceptions in Haskell  

IORef  
for concurrent shared data structures, Shared Concurrent Data Structures  

to store semaphore values, Limiting the Number of Threads with a Semaphore  

isEmptyTChan, More Operations Are Possible  

IVar type  
for Par computations, Dataflow Parallelism: The Par Monad  

returned from runPar, Limitations of Pipeline Parallelism  

to produce new graph, Example: Shortest Paths in a Graph  

### J

join function, Running the Client  

### K

K-Means problem, Example: The K-Means Problem–Granularity  
granularity of, Granularity–Granularity  

parallelizing, Parallelizing K-Means–Parallelizing K-Means  

performance/analysis of, Performance and Analysis–Performance and Analysis  

spark activitiy, visualizing, Visualizing Spark Activity–Visualizing Spark Activity  

kernels (Accelerate), Example: Shortest Paths  

kmeans_seq function, Example: The K-Means Problem, Parallelizing K-Means  

kmeans_strat function, Parallelizing K-Means  

### L

labelThread function, Event Logging and ThreadScope, Event Logging and ThreadScope  

large-scale arrays, parallelizing, Data Parallel Programming with Repa  

layout of an array, Arrays, Shapes, and Indices  

lazy data structures  
and Strategies, Dataflow Parallelism: The Par Monad  

parallel skeletons vs., Adding Parallelism  

lazy evaluation, Lazy Evaluation and Weak Head Normal Form–Lazy Evaluation and Weak Head Normal Form  
and MVar, MVar as a Container for Shared State  

defined, Lazy Evaluation and Weak Head Normal Form  

with shared data structures, Shared Concurrent Data Structures  

lazy streams, parallelizing, Parallelizing Lazy Streams with parBuffer–Parallelizing Lazy Streams with parBuffer  

length function, list evaluation with, Lazy Evaluation and Weak Head Normal Form  

less defined (term), The Identity Property  

let it crash philosophy, The Philosophy of Distributed Failure  

libraries  
DevIL, Example: Image Rotation–Summary  

GUI, Threads and Foreign Out-Calls  

HTTP, Asynchronous Exceptions  

monad-par, Using Different Schedulers  

on Hackage, Introduction  

lift function, Creating Arrays Inside Acc, Example: A Mandelbrot Set Generator  

liftIO, The ParIO monad, Processes and the Process Monad  

line buffering mode (server), A Trivial Server  

lists  
length function for, Lazy Evaluation and Weak Head Normal Form  

parallel evaluation of, A Strategy for Evaluating a List in Parallel–A Strategy for Evaluating a List in Parallel  

Lloyds algorithm, Example: The K-Means Problem, Example: The K-Means Problem  

locking, of servers, with MVar, Design One: One Giant Lock  

locks  
difficulty in programming with, Introduction  

in imperative languages, MVar as a Container for Shared State  

LogCommand data type, MVar as a Simple Channel: A Logging Service  

Logger data type, MVar as a Simple Channel: A Logging Service  

logging services, MVar as a Simple Channel: A Logging Service–MVar as a Simple Channel: A Logging Service  

logMessage operation, MVar as a Simple Channel: A Logging Service  

logStop operation, MVar as a Simple Channel: A Logging Service  

lookup function, MVar as a Container for Shared State  

lost wakeups, Blocking Until Something Changes  

### M

main function and program termination, A Simple Example: Reminders  

main threads  
as bound threads, Threads and Foreign Out-Calls  

deadlocking of, Detecting Deadlock  

makeNewClusters function, Example: The K-Means Problem  

Mandelbrot set generator, Example: A Mandelbrot Set Generator  

manifest arrays, Operations on Arrays  

map function  
and lazy data structure, Lazy Evaluation and Weak Head Normal Form  

in Accelerate, Running a Simple Accelerate Computation  

in Repa, Operations on Arrays–Operations on Arrays  

mapM function, Overlapping Input/Output  

mapWithKey function, Example: Shortest Paths in a Graph  

mask function, Masking Asynchronous Exceptions, Catching Asynchronous Exceptions, mask and forkIO–mask and forkIO, Asynchronous Exceptions: Discussion  

MaskedInterruptible constructor, Masking Asynchronous Exceptions  

MaskedUninterruptible constructor, Masking Asynchronous Exceptions  

masking asynchronous exceptions, Masking Asynchronous Exceptions–Masking Asynchronous Exceptions  

masking state, mask and forkIO  

mask\_, Asynchronous Exception Safety for Channels  

master function (distributed servers), Distribution  

master nodes in distributed programming, Running with Multiple Nodes on One Machine  

memory  
and unbounded channels, Bounded Channels  

overhead for threads, Thread Creation and MVar Operations  

required by parallelisms, Performance and Scaling  

mergePortsBiased function, Merging Channels  

mergePortsRR function, Merging Channels  

merging  
typed channels, Merging Channels–Merging Channels  

with MVar, Merging–Merging  

with STM, Merging with STM–Merging with STM  

Message constructor, for LogCommand data type, MVar as a Simple Channel: A Logging Service  

mkStaticClosure function, The Master Process–The Master Process  

modifyMVar, Masking Asynchronous Exceptions  
built-in safety of, Asynchronous Exceptions: Discussion  

implementing, Masking Asynchronous Exceptions  

variant of, Asynchronous Exception Safety for Channels  

modular programs  
concurrency of, Terminology: Parallelism and Concurrency  

creating, Parallel Programming Using Threads  

monad-par library, schedules and, Using Different Schedulers  

MonadIO monad, Processes and the Process Monad  

monads, computeP and, Parallelizing the Program–Parallelizing the Program  

monitor function, Handling Failure  

moveWindow  
concurrent call to, Running Example: Managing Windows  

implemented with STM, Running Example: Managing Windows  

moveWindowSTM, Running Example: Managing Windows  

multi-node programming, Multi-Node Ping–Running on Multiple Machines  
on multiple machines, Running on Multiple Machines  

on one machine, Running with Multiple Nodes on One Machine–Running with Multiple Nodes on One Machine  

multicast channels, building, MVar as a Building Block: Unbounded Channels  

multiclient servers, main function for, A Trivial Server  

multiple cores  
and concurrency, How to Achieve Parallelism with Concurrency  

NBSem run on, Limiting the Number of Threads with a Semaphore  

multiple writers, for one-place channels, Bounded Channels  

multiplication (in Accelerate), Example: A Mandelbrot Set Generator–Example: A Mandelbrot Set Generator  

mutable containers, for shared data structures, Shared Concurrent Data Structures  

mutable state, shared, Communication: MVars, MVar as a Container for Shared State–MVar as a Container for Shared State  

mutual deadlock, Detecting Deadlock  

MVar, Communication: MVars–MVar as a Building Block: Unbounded Channels  
and merging, Merging  

asynchronous I/O and, Overlapping Input/Output–Overlapping Input/Output  

creating unbounded channels with, MVar as a Building Block: Unbounded Channels–MVar as a Building Block: Unbounded Channels  

implemented with STM, Blocking  

implementing channels with, MVar as a Simple Channel: A Logging Service–MVar as a Simple Channel: A Logging Service  

implementing NBSem with, Limiting the Number of Threads with a Semaphore  

merging asynchronous I/O with, Merging–Merging  

merging events into single, Merging with STM  

performance compared with STM, What Can We Not Do with STM?  

protocol for operations with, Masking Asynchronous Exceptions  

shared state container, MVar as a Container for Shared State–MVar as a Container for Shared State  

STM vs., Implementing Channels with STM, An Alternative Channel Implementation–An Alternative Channel Implementation  

### N

N command, Extending the Simple Server with State, Design Four: Use STM  

NBSem, Limiting the Number of Threads with a Semaphore  

nested arrays, Accelerate and, Arrays and Indices  

nested timeouts, Timeouts  

nesting calls, Masking Asynchronous Exceptions  
of withAsync, Parallel Version  

to runPar, The Par Monad Compared to Strategies  

network-transport-tcp package, The Distributed-Process Family of Packages  

newClient function, Client Data  

newEmptyMVar operation, Communication: MVars  

newEmptyTMVarIO, Async Revisited  

newfactor function, The Implementation  

newUnique, Timeouts  

NFData  
in Deepseq, Deepseq  

NodeId, The Master Process  

nonblocking semaphores, Limiting the Number of Threads with a Semaphore  

normal form  
defined, Lazy Evaluation and Weak Head Normal Form  

in Deepseq, Deepseq  

Notice constructor, Client Data  

NVidia, GPU Programming with Accelerate  

### O

one-place channels  
bounded channels vs., Bounded Channels  

MVar as, Communication: MVars–Communication: MVars  

onException function, Exceptions in Haskell  

OpenCL language, GPU Programming with Accelerate  

OpenGL, Threads and Foreign Out-Calls  

operations, on Arrays, Operations on Arrays–Operations on Arrays  

optimization, Tuning Concurrent (and Parallel) Programs  

optimization options, Example: Computing Shortest Paths  

ordering  
detecting violations of, Running Example: Managing Windows  

imposed on MVars, Running Example: Managing Windows  

orElse function, Symmetric Concurrency Combinators, The Implementation  

orElse operation, Merging with STM  

overflowed sparks, Example: Parallelizing a Sudoku Solver  

overhead  
and runPar function, Example: Shortest Paths in a Graph  

for threads, Thread Creation and MVar Operations  

of atomicModifyIORef, Limiting the Number of Threads with a Semaphore  

### P

packages, installing, Sample Code  

Par monad, Dataflow Parallelism: The Par Monad–Adding Parallelism  
and parallelizing large-scale arrays, Data Parallel Programming with Repa  

constraint satisfaction problems, solving with, Example: A Conference Timetable–Adding Parallelism  

Floyd-Warshall algorithm, parallelizing, Example: Shortest Paths in a Graph–Example: Shortest Paths in a Graph  

force as default in, Example: Parallelizing a Sudoku Solver  

implemented as library, Using Different Schedulers  

ParIO vs., The ParIO monad  

pipleline paralellism and, Pipeline Parallelism–Limitations of Pipeline Parallelism  

schedulers available in, Using Different Schedulers  

Strategies vs., The Par Monad Compared to Strategies–The Par Monad Compared to Strategies  

parallel programs  
defined, Terminology: Parallelism and Concurrency  

tuning, Tuning Concurrent (and Parallel) Programs–RTS Options to Tweak  

parallelism, Terminology: Parallelism and Concurrency–Terminology: Parallelism and Concurrency, Basic Parallelism: The Eval Monad–Deepseq, Parallel Programming Using Threads–The ParIO monad  
achieving with concurrency, How to Achieve Parallelism with Concurrency–How to Achieve Parallelism with Concurrency  

Deepseq, Deepseq–Deepseq  

distributed-process framework vs., Distributed Concurrency or Parallelism?  

Eval monad, The Eval Monad, rpar, and rseq  

garbage collected sparks, GC’d Sparks and Speculative Parallelism–GC’d Sparks and Speculative Parallelism  

implementing, Parallel Version–Parallel Version  

K-Means example, Example: The K-Means Problem–Granularity  

lazy evaluation, Lazy Evaluation and Weak Head Normal Form–Lazy Evaluation and Weak Head Normal Form  

ParIO monad and, The ParIO monad–The ParIO monad  

performance, Performance and Scaling–Performance and Scaling  

rpar operation, The Eval Monad, rpar, and rseq  

rseq operation, The Eval Monad, rpar, and rseq  

scaling, Performance and Scaling–Performance and Scaling  

sequential vs., Sequential Version–Sequential Version  

speculative, GC’d Sparks and Speculative Parallelism–GC’d Sparks and Speculative Parallelism  

threads, limiting number of, Limiting the Number of Threads with a Semaphore–Limiting the Number of Threads with a Semaphore  

weak head normal form, Lazy Evaluation and Weak Head Normal Form–Lazy Evaluation and Weak Head Normal Form  

parameterized strategies, Parameterized Strategies–Parameterized Strategies  

parBuffer, Parallelizing Lazy Streams with parBuffer–Parallelizing Lazy Streams with parBuffer  

parent threads, Symmetric Concurrency Combinators  

ParIO monad, Limitations of Pipeline Parallelism, The ParIO monad–The ParIO monad  

parList function  
as parameterized Strategy, A Strategy for Evaluating a List in Parallel  

defining, A Strategy for Evaluating a List in Parallel–A Strategy for Evaluating a List in Parallel  

with chunking, Chunking Strategies–Chunking Strategies  

parList Strategy, A Strategy for Evaluating a List in Parallel  
parallelizing lazy streams with, Parallelizing Lazy Streams with parBuffer–Parallelizing Lazy Streams with parBuffer  

parMap function, Example: Parallelizing a Sudoku Solver–Example: Parallelizing a Sudoku Solver  
as parallel skeleton, Adding Parallelism  

expression of, with Strategies, A Strategy for Evaluating a List in Parallel  

parMapM function, Dataflow Parallelism: The Par Monad  

parPair Strategy  
evalPair Strategy vs., Parameterized Strategies  

evaluating components of a pair with, Parameterized Strategies  

parameterized Strategy vs., Parameterized Strategies  

parsearch function, Adding Parallelism  

parSteps_strat function, Parallelizing K-Means  

partitioning  
dynamic, Example: Parallelizing a Sudoku Solver  

static, Example: Parallelizing a Sudoku Solver  

peer discovery, The Distributed-Process Family of Packages  

performance monitoring, program, Thread Creation and MVar Operations–Thread Creation and MVar Operations  

phone book example, MVar as a Container for Shared State–MVar as a Container for Shared State  

ping example, A First Example: Pings–Summing Up the Ping Example  

pipeline operator, Example: Shortest Paths  

pipelining, Terminology: Parallelism and Concurrency  

pipleline paralellism, Pipeline Parallelism–Limitations of Pipeline Parallelism  
limitations of, Limitations of Pipeline Parallelism  

rate-limiting, Rate-Limiting the Producer–Rate-Limiting the Producer  

```cpp
Point (type), Example: The K-Means Problem, Example: The K-Means Problem

PointSum (type)
```
Cluster from, Example: The K-Means Problem  

constructing, Example: The K-Means Problem  

in Lloyds algorithm, Example: The K-Means Problem  

PolyType, Example: A Parallel Type Inferencer  

POSIX, Threads and Foreign Out-Calls  

```cpp
Prelude functions (in Repa), Data Parallel Programming with Repa

Process API (Control.Distributed), A First Example: Pings
```

Process monad, Processes and the Process Monad, Data Types  

ProcessID, Processes and the Process Monad  

ProcessMonitorNotification message, Handling Failure  

program analysis problems, parallelism for, Example: A Parallel Type Inferencer  

proxies, for forkIO threads, Data Types  

put function, Dataflow Parallelism: The Par Monad  
strictness of, Dataflow Parallelism: The Par Monad  

putMVar operation, Communication: MVars  
and fairness, What Can We Not Do with STM?  

and mutable states, Communication: MVars  

implementing, Blocking  

interruptibility of, Asynchronous Exception Safety for Channels  

putStrLn calls  
and stdout Handle, Event Logging and ThreadScope  

debugging with, Event Logging and ThreadScope  

put\_ operation, Dataflow Parallelism: The Par Monad  

### R

r0 Strategy, Parameterized Strategies  

race function  
for chat server, Recap  

for trees of threads, Symmetric Concurrency Combinators  

timeouts with, Timeouts Using race–Timeouts Using race  

rank operation, Arrays, Shapes, and Indices  

rdeepseq, Parameterized Strategies–Parameterized Strategies  

read function, The Ping Server Process  

```cpp
read function (POSIX), Threads and Foreign Out-Calls

read pointer (channel), MVar as a Building Block: Unbounded Channels
```

readChan operations  
concurrent, MVar as a Building Block: Unbounded Channels  

definition of, Asynchronous Exception Safety for Channels  

readEitherTChan, Composition of Blocking Operations  

readImage operation, Example: Image Rotation  

readMVar, Asynchronous Exception Safety for Channels  

readName function, Setting Up a New Client  

receive function, The Implementation  

```cpp
receiveChannel (typed channels), Typed Channels

ReceivePort (typed channels), Typed Channels, Typed Channels
```

record wildcard pattern, Client Data  

RecordWildCards extension, Client Data  

releaseNBSem, Limiting the Number of Threads with a Semaphore  

reminders, timed, A Simple Example: Reminders  

remotable, declaring functions as, The Master Process  

removeClient function, Setting Up a New Client  

render function, Blocking Until Something Changes  

rendering thread  
blocked by window, Running Example: Managing Windows  

implementing, Blocking Until Something Changes  

Repa, Data Parallel Programming with Repa–Summary  
arrays, Arrays, Shapes, and Indices–Operations on Arrays  

DevIL library and, Example: Image Rotation–Summary  

Floyd-Warshall algorithm and, Example: Computing Shortest Paths–Parallelizing the Program  

folding arrays in, Folding and Shape-Polymorphism–Folding and Shape-Polymorphism  

image manipulation in, Example: Image Rotation–Summary  

indices, Arrays, Shapes, and Indices–Arrays, Shapes, and Indices  

parallelizing programs with, Parallelizing the Program–Parallelizing the Program  

running programs on GPU vs., Running on the GPU  

shape-polymorphism of arrays, Folding and Shape-Polymorphism–Folding and Shape-Polymorphism  

shapes, Arrays, Shapes, and Indices–Arrays, Shapes, and Indices  

representation type (of Repa arrays)  
and Accelerate, Arrays and Indices  

defined, Arrays, Shapes, and Indices  

restore function, Masking Asynchronous Exceptions  

retry operation, Blocking  
defined, Blocking  

in readTChan, Implementing Channels with STM  

performance of, Performance  

to block on arbitrary conditions, Blocking Until Something Changes  

rnf (Deepseq), Deepseq  

roll back, Running Example: Managing Windows  

roots, Detecting Deadlock  

rotate function, Example: Image Rotation–Example: Image Rotation  

rotating points, about the origin, Example: Image Rotation  

round-robin scheduler, Fairness  

rpar operation, The Eval Monad, rpar, and rseq  
and speculative parallelism, The Par Monad Compared to Strategies  

and Strategy, Evaluation Strategies  

as a Strategy, Parameterized Strategies–Parameterized Strategies  

rparWith Strategy, Parameterized Strategies, GC’d Sparks and Speculative Parallelism  

rseq operation (Eval monad), The Eval Monad, rpar, and rseq  
and Strategy, Evaluation Strategies  

runClient function, Running the Client  

runEval operation, The Eval Monad, rpar, and rseq, The Par Monad Compared to Strategies  

runIL function, Example: Image Rotation  

runPar function  
and lazy streams, Limitations of Pipeline Parallelism  

and ParIO, The ParIO monad  

avoiding multiple calls of, The Par Monad Compared to Strategies  

overhead of, Example: Shortest Paths in a Graph  

returning IVar from, Dataflow Parallelism: The Par Monad  

runtime system, options for tuning, RTS Options to Tweak–RTS Options to Tweak  

### S

scalar arrays, Folding and Shape-Polymorphism, Scalar Arrays  

schedulers (Par monad), Using Different Schedulers  

search functions, Adding Parallelism  

search pattern  
as higher-order function, Adding Parallelism  

tree-shaped, Example: A Conference Timetable  

search skeleton, Adding Parallelism  

selects function, Example: A Conference Timetable  

semaphores  
limiting number of threads with, Limiting the Number of Threads with a Semaphore–Limiting the Number of Threads with a Semaphore  

nonblocking, Limiting the Number of Threads with a Semaphore  

storing semaphore values, Limiting the Number of Threads with a Semaphore  

```cpp
sendChannel (typed channels), Typed Channels

SendPort (typed channels), Typed Channels
```

seq function  
forcing evaluation with, Lazy Evaluation and Weak Head Normal Form–Lazy Evaluation and Weak Head Normal Form  

weak head normal form evaluation in, Lazy Evaluation and Weak Head Normal Form  

sequential algorithms, Limiting the Number of Threads with a Semaphore  

sequential evaluation, The Eval Monad, rpar, and rseq  

Serializable, Typed Channels  

serializing data, Defining a Message Type–Defining a Message Type  

server applications, Concurrent Network Servers–Recap  
adding state to, Extending the Simple Server with State–The Implementation  

and thread interruption, Cancellation and Timeouts  

architecture of, Architecture–Architecture  

chat server, implementing, A Chat Server–Recap  

client side, Client Data–Running the Client  

implementing, A Trivial Server–A Trivial Server  

server state, implementing, Extending the Simple Server with State–The Implementation  
broadcast channels, Design Three: Use a Broadcast Chan  

creating new instance, The Server  

one chan per thread, Design Two: One Chan Per Server Thread–Design Two: One Chan Per Server Thread  

with MVar, Design One: One Giant Lock–Design One: One Giant Lock  

with STM, Design Four: Use STM–The Implementation  

server thread, Running the Client  

setNumCapabilities, Limiting the Number of Threads with a Semaphore  

Shape class, Arrays, Shapes, and Indices, Running a Simple Accelerate Computation  

shape-polymorphism of arrays, Folding and Shape-Polymorphism–Folding and Shape-Polymorphism  

shared mutable data structures  
concurrent, Shared Concurrent Data Structures–Shared Concurrent Data Structures  

containers for, Communication: MVars, MVar as a Container for Shared State–MVar as a Container for Shared State  

shared state, MVar as container for, MVar as a Container for Shared State–MVar as a Container for Shared State  

Shortest Paths in a Graph (example), Example: Computing Shortest Paths  
in Accelerate, Example: Shortest Paths  

in Repa, Example: Computing Shortest Paths  

shortestPath, Example: Shortest Paths in a Graph  

Show, as exception, Exceptions in Haskell  

SIMD divergence, Example: A Mandelbrot Set Generator  

simplelocalnet backend, initializing, Failure and Adding/Removing Nodes  

single wake up property, Fairness  

single wake-up property (threads), Fairness  

size operation, for shapes, Arrays, Shapes, and Indices  

skeleton  
to parallelize code, Adding Parallelism  

with strategies and parallelism, The Par Monad Compared to Strategies  

slave nodes in distributed programming, Running with Multiple Nodes on One Machine  

SomeException data type, catching, Exceptions in Haskell  

spark activitiy, visualizing, Visualizing Spark Activity–Visualizing Spark Activity  

spark pool, GC’d Sparks and Speculative Parallelism  

sparks  
defined, Example: Parallelizing a Sudoku Solver  

garbage-collected, GC’d Sparks and Speculative Parallelism–GC’d Sparks and Speculative Parallelism  

in ThreadScope, The Par Monad Compared to Strategies  

sparse graph, algorithms run over, Example: Shortest Paths in a Graph  

spawn function  
in distributed programming, The Distributed-Process Family of Packages, The Master Process  

in Par monad, Dataflow Parallelism: The Par Monad  

speculative parallelism, GC’d Sparks and Speculative Parallelism, The Par Monad Compared to Strategies  

speedups  
and number of work items, Granularity–Granularity  

calculating, Example: Parallelizing a Sudoku Solver  

for parallel type inferencer, Example: A Parallel Type Inferencer  

for parallelization of K-Means, Performance and Analysis–Performance and Analysis  

in NBSem, Limiting the Number of Threads with a Semaphore  

in parallel version, Performance and Scaling  

in pipeline, Pipeline Parallelism  

:sprint command, Lazy Evaluation and Weak Head Normal Form, Lazy Evaluation and Weak Head Normal Form  

sqDistance operation, Example: The K-Means Problem  

ST monad, Parallel Programming Using Threads  

stack overflow, Asynchronous Exceptions: Discussion  

stack size, tuning, Thread Creation and MVar Operations  

static partitioning, Example: Parallelizing a Sudoku Solver  

stdout Handle, Event Logging and ThreadScope  

stencil convolutions, Summary  

step function  
in Accelerate, Example: Shortest Paths  

in K-Means problem, Example: The K-Means Problem  

parallelizing, Parallelizing K-Means  

STM (Software Transactional Memory), Software Transactional Memory  
and high contention, Limiting the Number of Threads with a Semaphore  

blocking, Blocking  

bounded channels, Bounded Channels–Bounded Channels  

channels, implementing with, Implementing Channels with STM–Asynchronous Exception Safety  

defined, Software Transactional Memory  

for chat server, Recap  

limitations of, What Can We Not Do with STM?–What Can We Not Do with STM?  

merging, handling with, Merging with STM–Merging with STM  

MVar vs., An Alternative Channel Implementation–An Alternative Channel Implementation  

performance of, Performance–Performance  

retry operation, Blocking  

server state, implementing with, Design Four: Use STM–The Implementation  

Stop constructor, for LogCommand data type, MVar as a Simple Channel: A Logging Service  

Strategy, Evaluation Strategies–The Identity Property  
evaluating lists in parallel, A Strategy for Evaluating a List in Parallel–A Strategy for Evaluating a List in Parallel  

identity property, The Identity Property–The Identity Property  

parameterized, Parameterized Strategies–Parameterized Strategies  

parBuffer, parallelizing lazy streams with, Parallelizing Lazy Streams with parBuffer–Parallelizing Lazy Streams with parBuffer  

Strategy(-ies)  
and lazy data structures, Dataflow Parallelism: The Par Monad, The Par Monad Compared to Strategies  

and parallelizing large-scale arrays, Data Parallel Programming with Repa  

Par monad vs., The Par Monad Compared to Strategies–The Par Monad Compared to Strategies  

Stream, Pipeline Parallelism  

Stream data type, MVar as a Building Block: Unbounded Channels  

stream elements, Pipeline Parallelism  

streamFold, Pipeline Parallelism, Pipeline Parallelism  

strictness annotations (in Repa), Example: Image Rotation–Summary  

String type, Sequential Version  

String, backslash character in, Example: A Parallel Type Inferencer  

sum function, Lazy Evaluation and Weak Head Normal Form–Lazy Evaluation and Weak Head Normal Form  

sum, of complex numbers, Example: A Mandelbrot Set Generator  

sumAllS function, Folding and Shape-Polymorphism  

super-linear performance, Performance and Scaling  

swap function, Lazy Evaluation and Weak Head Normal Form  

symmetric concurrency combinators, Symmetric Concurrency Combinators–Timeouts Using race  

synchronous channel, What Can We Not Do with STM?  

synchronous exceptions, Asynchronous Exceptions  

### T

tail-calling of exception handlers, Catching Asynchronous Exceptions  

tail-recursive strategies, GC’d Sparks and Speculative Parallelism–GC’d Sparks and Speculative Parallelism  

takeEitherTMVar, Composition of Blocking Operations  

takeMVar operation, Communication: MVars  
and mutable states, Communication: MVars  

deadlock with, Detecting Deadlock  

masking exceptions during, Masking Asynchronous Exceptions  

takeTMVar operation, Blocking  

TChan  
and asynchronous exceptions, Asynchronous Exception Safety  

for chat server, Architecture  

implementing, Implementing Channels with STM  

Tell constructor, Client Data  

terminate function, The Master Process  

termination of programs, A Simple Example: Reminders  

the operation, in Accelerate, Scalar Arrays  

thread death  
automatic cancelling of Async with, Avoiding Thread Leakage  

trees of threads and, Higher-Level Concurrency Abstractions  

thread number, Event Logging and ThreadScope  

thread-local state, APIs with, Threads and Foreign Out-Calls  

threadDelay function, A Simple Example: Reminders  

ThreadId, Asynchronous Exceptions  

threading, A Simple Example: Reminders–A Simple Example: Reminders  
asynchronous exceptions and, Cancellation and Timeouts–Asynchronous Exceptions: Discussion  

avoiding leakage, Avoiding Thread Leakage–Avoiding Thread Leakage  

CPU usage and, Fairness–Fairness  

detecting deadlock, Detecting Deadlock–Detecting Deadlock  

fairness of, Fairness–Fairness  

inspecting thread status, Inspecting the Status of a Thread–Inspecting the Status of a Thread  

merging, Merging–Merging, Merging with STM–Merging with STM  

models for, in C, Concurrency and the Foreign Function Interface  

MVars and, Communication: MVars–MVar as a Building Block: Unbounded Channels  

shared state, MVar as a Container for Shared State–MVar as a Container for Shared State  

ThreadKilled exception, Asynchronous Exceptions  

threads  
additional, used by program, Limiting the Number of Threads with a Semaphore  

and timeout exceptions, Timeouts  

blocked on each other, Running Example: Managing Windows  

blocked, in STM, What Can We Not Do with STM?  

bound, Threads and Foreign Out-Calls  

cancelling, Asynchronous Exceptions  

child, Symmetric Concurrency Combinators, Detecting Deadlock  

communication of, Communication: MVars–Communication: MVars  

creating, A Simple Example: Reminders, Thread Creation and MVar Operations–Thread Creation and MVar Operations  

deadlocking of, Detecting Deadlock  

difficulty programming with, Introduction  

FFI and, Threads and Foreign Out-Calls–Threads and Foreign Out-Calls  

for concurrent web servers, Introduction  

foreign in-calls and, Threads and Foreign In-Calls  

foreign out-calls and, Threads and Foreign Out-Calls–Threads and Foreign Out-Calls  

identifying, Event Logging and ThreadScope  

implementing signals between, Blocking Until Something Changes  

interrupting, Cancellation and Timeouts–Asynchronous Exceptions: Discussion  

lightweight, A Trivial Server  

limiting number of, Limiting the Number of Threads with a Semaphore–Limiting the Number of Threads with a Semaphore  

locks for, MVar as a Container for Shared State  

memory overhead for, Thread Creation and MVar Operations  

multi-way communciation between, What Can We Not Do with STM?  

trees of, Higher-Level Concurrency Abstractions, Symmetric Concurrency Combinators  

unresponsive, Cancellation and Timeouts  

wake up property of, Fairness  

threads of control, Terminology: Parallelism and Concurrency  

ThreadScope (tool), Event Logging and ThreadScope–Event Logging and ThreadScope  
and Eval vs. Par monads, The Par Monad Compared to Strategies  

installing, Tools and Resources  

profiling programs with, Example: Parallelizing a Sudoku Solver–Example: Parallelizing a Sudoku Solver  

showing detailed events in, Performance and Analysis  

thread number in, Event Logging and ThreadScope  

visualizing sparks with, Visualizing Spark Activity–Visualizing Spark Activity  

threadStatus function, Inspecting the Status of a Thread–Inspecting the Status of a Thread  

throw function, Exceptions in Haskell  

throwIO function, Exceptions in Haskell  

throwSTM operation, Asynchronous Exception Safety  

throwTo  
and asynchronous exceptions, Timeouts  

and synchronous exceptions, Asynchronous Exceptions  

thunk(s)  
and defined expressions, Lazy Evaluation and Weak Head Normal Form  

creation of, by map function, Lazy Evaluation and Weak Head Normal Form  

defined, Lazy Evaluation and Weak Head Normal Form  

evaluating thunks that refer to other thunks, Lazy Evaluation and Weak Head Normal Form  

unevaluated, Lazy Evaluation and Weak Head Normal Form  

time, wall-clock and elapsed, Example: Parallelizing a Sudoku Solver  

timed reminders, creation of threads in a program with, A Simple Example: Reminders  

timeDownload function, Overlapping Input/Output  

timeit function, Overlapping Input/Output  

timeouts, Timeouts–Timeouts  
behavior of, Timeouts  

implementation of, Timeouts  

nesting, Timeouts  

with race operation, Timeouts Using race–Timeouts Using race  

TimeTable, Example: A Conference Timetable  

TList type, Implementing Channels with STM  

TMVar data type, Blocking–Blocking  
fairness of, What Can We Not Do with STM?  

STM computation vs., Adding a Functor Instance  

toIndex function, Arrays, Shapes, and Indices  

TopEnv, Example: A Parallel Type Inferencer  

TQueue  
Chan vs., An Alternative Channel Implementation  

to build bounded channels, Bounded Channels  

Trace scheduler (monad-par library), Using Different Schedulers  

traceEventIO function, Event Logging and ThreadScope  

transaction, rolled back, Running Example: Managing Windows  

transactional variable, Running Example: Managing Windows  

transport layer packages, The Distributed-Process Family of Packages  

Traversable class, Example: Shortest Paths in a Graph  

traverseWithKey function, Example: Shortest Paths in a Graph  

tree-shaped computations, Limiting the Number of Threads with a Semaphore  

trees of threads, Higher-Level Concurrency Abstractions, Symmetric Concurrency Combinators  

try function  
catching exceptions with, Exceptions in Haskell  

error handling with, Error Handling with Async  

tryAquireNBSem, Limiting the Number of Threads with a Semaphore  

tuning, Tuning Concurrent (and Parallel) Programs–RTS Options to Tweak  
data structures, shared, Shared Concurrent Data Structures–Shared Concurrent Data Structures  

MVar operations, Thread Creation and MVar Operations–Thread Creation and MVar Operations  

RTS options for, RTS Options to Tweak–RTS Options to Tweak  

thread creation, Thread Creation and MVar Operations–Thread Creation and MVar Operations  

tuples, arrays of, Arrays and Indices  

TVar  
defined, Running Example: Managing Windows  

for concurrent shared data structures, Shared Concurrent Data Structures  

locked during commit, Performance  

unbounded number of, Performance  

type inference engines, parallelizing, Example: A Parallel Type Inferencer–Example: A Parallel Type Inferencer  

Typeable  
as exception, Exceptions in Haskell  

enabling automatic derivation for, Exceptions in Haskell  

message types as, Defining a Message Type  

typed channels, Typed Channels–Merging Channels  
merging, Merging Channels–Merging Channels  

untyped channels vs., Handling Failure  

### U

unbounded channels  
bounded channels vs., Bounded Channels  

constructing, MVar as a Building Block: Unbounded Channels–MVar as a Building Block: Unbounded Channels  

Unbox type class, Arrays, Shapes, and Indices  

unboxed arrays, computeS function and, Operations on Arrays  

unevaluated computations, Lazy Evaluation and Weak Head Normal Form  

unGetChan operation, MVar as a Building Block: Unbounded Channels, More Operations Are Possible  

Unicode conversion, Sequential Version  

uninterruptibleMask, Masking Asynchronous Exceptions  

unit operation, in Accelerate, Scalar Arrays  

Unlift class, Creating Arrays Inside Acc  

unlift function, Creating Arrays Inside Acc, Example: A Mandelbrot Set Generator  

Unmasked constructor, Masking Asynchronous Exceptions  

unresponsive threads, deadlocks and, Cancellation and Timeouts  

update function, Example: Shortest Paths in a Graph  

use function, in Accelerate, Running a Simple Accelerate Computation  

user interface, multiple threads with, Cancellation and Timeouts  

user interrupt, asynchronous exceptions and, Asynchronous Exceptions: Discussion  

using function, Evaluation Strategies  
and garbage-collected sparks, GC’d Sparks and Speculative Parallelism  

### W

wait function  
error handling with, Error Handling with Async–Error Handling with Async  

for asynchronous actions, Overlapping Input/Output  

waitAny function, Merging, Async Revisited, Adding a Functor Instance  

waitBoth operation  
and orElse combinator, Symmetric Concurrency Combinators  

and withAsync function, Symmetric Concurrency Combinators  

waitCatch function  
error handling with, Error Handling with Async  

implementing, Asynchronous Exceptions  

waitCatchSTM function, Async Revisited  

waitEither function, Merging, Symmetric Concurrency Combinators  
and symmetric concurrency combinators, Symmetric Concurrency Combinators  

in STM, Async Revisited, Async Revisited  

waitSTM function, Async Revisited  

wall-clock time, elapsed and, Example: Parallelizing a Sudoku Solver  

watch list, in TVars, Performance  

weak head normal form (WHNF), Lazy Evaluation and Weak Head Normal Form–Lazy Evaluation and Weak Head Normal Form  

web browsers, interrupting several activiites with, Cancellation and Timeouts  

web pages, concurrent downloading of, Overlapping Input/Output  

weight function, Floyd-Warshall algorithm and, Example: Shortest Paths in a Graph  

WHNF (weak head normal form), Lazy Evaluation and Weak Head Normal Form–Lazy Evaluation and Weak Head Normal Form  

window manager example, Running Example: Managing Windows–Running Example: Managing Windows  

withAsync function  
and waitBoth operation, Symmetric Concurrency Combinators  

foreign calls with, Asynchronous Exceptions and Foreign Calls–Asynchronous Exceptions and Foreign Calls  

installing exception handlers with, Avoiding Thread Leakage  

nesting calls of, Parallel Version  

withMonitor function, Handling Failure  

withStrategy, parallelizing lazy streams with, Parallelizing Lazy Streams with parBuffer  

work items, number of, Granularity–Granularity  

work pools, Dataflow Parallelism: The Par Monad  

work stealing, Example: Parallelizing a Sudoku Solver, The ParIO monad  

write pointer (channel), MVar as a Building Block: Unbounded Channels  

writeChan operations  
concurrent, MVar as a Building Block: Unbounded Channels  

definition of, Asynchronous Exception Safety for Channels  

writeImage operation, Example: Image Rotation  

writeTBQueue, deadlock caused by, Bounded Channels  

### Y

yields (term), Event Logging and ThreadScope  

### Z

Z constructor, Arrays, Shapes, and Indices  

zeroPoint operation, Example: The K-Means Problem  

zipWith function (Accelerate), Zipping Two Arrays  