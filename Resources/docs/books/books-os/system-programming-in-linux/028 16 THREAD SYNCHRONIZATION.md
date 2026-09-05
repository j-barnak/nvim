16 THREAD SYNCHRONIZATION

Multithreaded programs can take advantage of the fact that the threads share global memory in the heap and data segments. It’s easy to be

lulled into thinking that they’re relatively easy to design and write

because it’s so easy to share that data in memory. However,

multithreaded programs require us to have a different mindset during

their design and development than sequential programs do because this

sharing of data comes at a cost. Specifically, we have to be ever mindful of the consequent race conditions and synchronization issues tied to this benefit. To solve these problems, we need tools for controlling access to shared objects. The *Pthreads* library contains an assortment of tools for this purpose, such as mutexes, condition variables, barriers, and read-write locks.

In this chapter, we explore the use of these tools for solving some

synchronization problems. We begin with an overview of how to

evaluate a multithreaded program. After that we’ll look at specific tools from the *Pthreads* API, starting with mutexes, then condition variables, barriers, and read-write locks. Along the way, we’ll write multithreaded versions of a few programs from previous chapters such as the producer-consumer program from Chapter 14. We’ll also develop a few new programs. Although some of the algorithms we’re studying are parallel, the intention in this chapter is not to explore theoretical concepts about

concurrent programming; still, here and there I toss in a few concepts to clarify a more relevant point.

Correctness and Performance Considerations

One of the primary reasons for multithreading a program is to improve

its performance. Before we dive into the details of the collection of

synchronization tools provided by *Pthreads*, let’s make sure we have a means of deciding whether a program performs well.

All programs have functional requirements, those that determine

whether their output is correct. Most programs also have performance

requirements, such as how long they run or how much memory they

consume. Multithreaded programs have additional functional and

performance requirements. A multithreaded program has to be

functionally correct regardless of the timing of execution of its threads.

If it fails sometimes due to how its threads are scheduled, it isn’t correct.

This is an example of a safety property, a concept defined by Leslie

Lamport in 1977. A *safety* property is one that means, essentially, *bad* *things don’t happen* [\[22\]](index_split_014.html#p1237).

A multithreaded program also has to have certain liveness

properties, such as being free from deadlock, starvation of one or more threads, and livelock, which occurs when two or more threads

continuously attempt an action that fails. (Think of two people trying to pass each other in a narrow corridor, with each telling the other to go first, but neither ever passing the other.) A *liveness* property, also defined by Lamport \[[22\]](index_split_014.html#p1237), is one that means *good things do happen*.

When we develop any multithreaded program, we need to be

cognizant of these issues and convince ourselves that the program

satisfies both functional and performance requirements.

Mutexes

A *mutex* is one of the tools of the *Pthreads* library that makes it possible to grant mutually exclusive access to critical sections. We discussed

them briefly in Chapter 12 when we examined race conditions among

![](/tmp/audit/iter1/epubregen/system-programming-in-linux/media/index-963_1.jpg)

processes. A mutex is like a software version of a lock—a thread locks it, uses the shared resource, and unlocks it. Its name is a portmanteau of

“mutual exclusion.” A mutex can be held, or *owned*, by only one thread at a time. Like a binary semaphore, the typical use of a mutex is to

surround a critical section of code with calls to lock and then to unlock the mutex, as in the following code:

pthread_mutex_lock(&mutex);

// OMITTED: Critical section code

pthread_mutex_unlock(&mutex);

This is also depicted visually in Figure 16-1.

*Figure 16-1: Calls to lock and unlock a mutex to ensure exclusive access to a critical* *section*

We’ll examine the functions to lock and unlock mutexes shortly.

Mutexes are a low-level form of critical section protection, providing the most rudimentary features. They were intended as the building

blocks of higher-level synchronization methods. Nonetheless, they can

be used in many cases to solve critical section problems. In the

remainder of this section, we’ll explore the fundamentals of working

with them.

NOTE

*A mutex is different from a binary semaphore in one important respect*

*—the only thread al owed to unlock a given mutex is the one that locked* *it, whereas a thread that didn’t decrement a semaphore can increment it.*

*They serve different purposes.*

*Declaring and Initializing a Mutex*

In *Pthreads*, a mutex is declared as an object of type pthread_mutex_t. It has to be initialized before it can be used. A man page search for how to

initialize a mutex (apropos -a mutex initialize) yields a page for

pthread_mutex_init(), but that page has little information and refers us instead to the page for pthread_mutex_destroy(). I’ll summarize what that page states. There are two ways to initialize a mutex:

Statically when it is declared, using the PTHREAD_MUTEX_INITIALIZER

macro:

pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

Dynamically with the pthread_mutex_init() routine:

int pthread_mutex_init(pthread_mutex_t \*mutex,

pthread_mutexattr_t \*attr);

The static initializer initializes a mutex with its default attributes, whereas the pthread_mutex_init() function is given a pointer to a mutex and to a mutex attribute object. It initializes the mutex to have the

attributes of that object. Unlike the static initializer, this also performs error checking when invoked. Passing NULL in the second argument

initializes the mutex with the default attributes and performs error

checking in the process. The call to pthread_mutex_init() can fail for a few different reasons, such as a malformed attributes object or a lack of

sufficient memory, resources, or privileges. It returns an error code if it fails and 0 on success.

Regardless of how it is initialized, a mutex is initially unlocked.

*Locking and Unlocking a Mutex*

There are two functions for locking a mutex, and one for unlocking it: int pthread_mutex_lock(pthread_mutex_t \*mutex);

int pthread_mutex_trylock(pthread_mutex_t \*mutex);

int pthread_mutex_unlock(pthread_mutex_t \*mutex);

Let’s begin with pthread_mutex_lock(). The semantics of this function are a bit complex, in part because there are four different types of mutexes,

called normal, recursive, error-check, and default. The default mutex type is usually the same as the normal mutex; in describing how the

various mutex functions behave, I’ll assume it’s a normal mutex. The

rules describing its semantics are:

If the mutex is not locked, the calling thread succeeds in acquiring

the referenced mutex and becomes its owner. The mutex is in a

locked state as a result and the call returns 0.

If the mutex is in a locked state when a thread tries to lock it, the

calling thread is blocked until the mutex is unlocked.

If a thread tries to lock a mutex that it has already locked, this

results in deadlock.

If a thread attempts to unlock a mutex that it hasn’t locked or a

mutex that is unlocked, undefined behavior results.

If a signal is delivered to a thread that is blocked on a mutex, when

the thread returns from the signal handler, it resumes waiting for

the mutex as if it hadn’t been interrupted.

In short, if several threads try to lock a mutex, only one thread

succeeds in acquiring the lock. The other threads will be in a blocked state until the mutex is unlocked by its owner. Since only one thread

returns successfully from the call to lock the mutex, in code like this pthread_mutex_lock(&mutex);

// OMITTED: Critical section code

pthread_mutex_unlock(&mutex);

only one thread at a time can enter the critical section.

The pthread_mutex_trylock() function behaves similarly to pthread_mutex \_lock() except that it never blocks the calling thread. Specifically, if the mutex is unlocked, the calling thread acquires it and the function

returns 0, and if the mutex is already locked by any thread, the function returns the error value EBUSY. This means that on return from a call to pthread_mutex_trylock(), the code has to check the return value before entering a critical section. We won’t explore this function further.

The pthread_mutex_unlock() function will unlock a mutex if it is called by the owning thread. If there are threads blocked on the mutex object referenced by mutex when pthread_mutex_unlock() is called, resulting in the mutex becoming available, the scheduling policy determines which

thread next acquires the mutex. If the mutex is a normal mutex that used the default initialization, there is no specific thread scheduling policy associated with the mutex, and the kernel scheduler chooses which

thread to unblock. The behavior of this function for non-normal

mutexes is different.

*Destroying a Mutex*

When a mutex is no longer needed, it should be destroyed. The

prototype for pthread_mutex_destroy() is:

int pthread_mutex_destroy(pthread_mutex_t \*mutex);

The function destroys the unlocked mutex object referenced by mutex,

and the mutex object becomes uninitialized. A locked mutex cannot be

destroyed; if a thread attempts to do so, the effect is undefined. The result of referencing the mutex object after it has been destroyed is

undefined. A destroyed mutex object can be reinitialized using

pthread_mutex_init().

*A Program Using a Normal Mutex*

We’ve developed a few programs in previous chapters that had critical

sections, which we protected in a few different ways. For example, in

Chapter 8, we wrote two different progress bar programs: *progress_bar1.c* and *progress \_bar2.c*. In each, we employed a global variable named fraction_completed that kept track of the fraction of work completed by the program on an imaginary job. This variable was

updated by a function named long_running_task() and used inside the

signal handler that refreshed the progress bar. Because the signal

handler could run asynchronously with respect to long_running_task(), the accesses to fraction_completed could be concurrent and subject to race conditions. We prevented them by blocking signals during the update to fraction \_completed inside long_running_task(). Both programs were driven

by signals generated at regular intervals. The first used the alarm() function, which was reset with each expiration in a signal handler. The second used a POSIX timer instead. The second was a bit more complex

than the first because of the steps needed to set up and use the timer.

The *progress_bar1.c* program is a good candidate in which we can integrate the ideas about threads, mutexes, and signal handling that

we’ve just explored, in part because it’s simpler. We’ll create a

multithreaded version of that program, named *threaded_progbar.c*.

Specifically, instead of a single thread executing the long_running_task(), we’ll create multiple threads that do. This models the situation in which multiple threads work together to complete a common task. As a result, though, their mutual updates to fraction_completed are a critical section, which we’ll protect with a single mutex. We’ll also have to change how the SIGALRM signal is handled in this version.

Specifically, we’ll make the following changes:

The main() function will create NUMTHREADS many (four) compute

threads to execute the long_running_task(). We’ll modify long_running

\_task() so that it’s in the correct form to be a thread start function.

The main() function will create a signal mask containing SIGALRM and

the terminating asynchronous signals and call sigprocmask() to block

all of these signals. The threads will inherit this mask. It will also create a single signal-handling thread like the one in

*threaded_upcased.c* (see “A Multithreaded Concurrent Server” in

Chapter 14) that uses sigwait() to synchronously handle all pending signals. (Figure 16-2 depicts the program structure, with four compute threads.)

The simulated delay in the long_running_task() will be proportional to the amount that the thread adds to fraction_completed in its loop

iteration, which is based on a random value. We’ll change how we

generate that value.

We’ll create a logfile into which each thread writes its ID every

time it increases fraction_completed inside its critical section. The

logfile will be a way to check how randomized the updates were.

![](/tmp/audit/iter1/epubregen/system-programming-in-linux/media/index-968_1.jpg)

When it terminates, the program will print the total percentage of

the simulated task that each thread completed.

The program is driven by the steady beat of the refresh_progressbar()

function, which generates the sequence of SIGALRM signals as it refreshes the screen. However, no thread is responding directly to the beat except for sig_thread(), which calls refresh_progressbar() each time the SIGALRM is delivered, as shown in Figure 16-2.

*Figure 16-2: A schematic representation of* threaded_progbar.c *showing four compute* *threads and one signal handling thread*

Let’s look at the pieces of *threaded_progbar.c*. First, it needs a few global variables to simplify the code:

double fraction_completed = 0; /\* Fraction of operation completed \*/

pthread_mutex_t frac_mutex = PTHREAD_MUTEX_INITIALIZER; /\* Shared mutex \*/

double computedby\[NUMTHREADS\]; /\* Fraction computed by each thread \*/

pthread_t t\[NUMTHREADS\]; /\* Thread IDs \*/

typedef struct \_task_data {

int fd; /\* File descriptor for logfile \*/

long id; /\* Program's ID for thread \*/

} thread_data;

The thread_data structure is the data type of the argument passed to the start function for a thread. Since the threads write to the logfile, they get a copy of the file descriptor to the open file description and share the file offset.

The revised long_running_task() is displayed in Listing 16-1.

long_running_task()

void \*long_running_task(void \*arg)

{

double progress_rate = 1.0 / (MIN_SIMULATION_SECS \* NUMTHREADS);

struct timespec differential, rem;

thread_data td = \*(thread_data\*) arg; /\* Extract thread data from arg. \*/

char str\[5\];

sprintf(str, "%ld,", td.id); /\* Thread ID as a string \*/

while ( fraction_completed \< 1.0 ) {

pthread_mutex_lock(&frac_mutex); /\* Lock mutex. \*/

➊ double work = progress_rate \* (1.0 \* random()) / RAND_MAX;

fraction_completed += work; /\* Update is race free. \*/

➋ if ( fraction_completed \> 1.0 ) {

work -= (fraction_completed - 1.0); /\* Reduce work. \*/

fraction_completed = 1.0;

}

write(td.fd, str, strlen(str)); /\* Record in logfile that I ran. \*/

pthread_mutex_unlock(&frac_mutex); /\* Unlock mutex. \*/

dbl_to_timespec(20 \* NUMTHREADS \* work, &differential);

if ( -1 == nanosleep(&differential, &rem))/\* Sleep proportionately. \*/

nanosleep(&rem, NULL);

computedby\[td.id\] += work; /\* Record fraction computed. \*/

}

pthread_exit(EXIT_SUCCESS);

}

*Listing 16-1: The thread start function for the compute threads*

The program uses the mutex to protect all of the instructions in the critical section. The original program used the drand48() function, but it isn’t thread-safe. Its man page notes this, stating that it records “global state information for the random number generator, so they are not

thread-safe.” Because it isn’t thread-safe, we use random() ➊ instead, which is thread-safe.

NOTE

*When writing multithreaded programs, we need to check every library* *function’s man page as we’re working. Al man pages have a section near* *their end named* *ATTRIBUTES* *with a table indicating thread safety.*

The write() to the file is within the critical section not to protect the file offset, but to ensure that the order in which the thread IDs are

written is the same as the order in which they acquired the mutex lock.

If it came after the mutex was unlocked, two threads could write into

the file in an arbitrary order. The file offset is protected from races because the file is opened with the O_APPEND flag in main() (see Chapter

11).

The if statement ➋ makes sure that the work variable is diminished if

the last iteration causes the fraction of work completed to exceed 1.0.

Lastly, the dbl_to_timespec() function is a utility function declared in the common header file *time_utils.h*, which the program includes.

The signal handling thread’s start function, sighandler(), is similar in structure to that of the multithreaded concurrent server,

*threaded_upcased.c*. It’s shown next:

sighandler()

void \*sighandler(void \*data)

{

int sig;

sigset_t mask = \*(sigset_t\*) data;


if ( sigwait(&mask, &sig) != 0 )

fatal_error(errno, "sigwait");

switch ( sig ) {

case SIGALRM:

refresh_progressbar(sig);

break;

default:

erase_progress_bar();

for ( int i = 0; i \< NUMTHREADS; i++ )

pthread_cancel(t\[i\]); /\* Terminate the other threads. \*/

exit(EXIT_FAILURE);

}

}

return data;

}

A pointer to the set of blocked signals for which sigwait() waits

synchronously is passed into the function as its data. If it receives a SIGALRM, sigwait() returns and calls refresh_progressbar(). If it’s any other pending signal, it’s a terminating one, so it erases the progress bar and kills the compute threads explicitly. When it calls exit(), the main() function’s thread exits and the file descriptor is automatically closed.

The last piece of the program that’s different from the original is the main() function, partially shown in Listing 16-2. Most error handling is omitted; the complete program is available in the book’s source code

distribution.

*threaded_progbar.c* main()

\#include "common_hdrs.h"

\#include "time_utils.h"

\#include \<pthread.h\>

*--snip--*

int main(int argc, char \*argv\[\])

{

const struct timespec slight_pause = {2,0};

struct timespec remaining_sleep;

pthread_t sig_thread;

sigset_t mask;

int i, fd;

thread_data td\[NUMTHREADS\]; /\* Thread data structures

for each thread \*/

fd = open("./taskorder", O_WRONLY \| O_TRUNC \| O_CREAT \| O_APPEND, 0644); draw_initial_bar(); /\* Draw the progress bar. \*/

memset(computedby, 0, NUMTHREADS \* sizeof (double));

/\* Block likely asynchronous signals and SIGALRM. \*/

sigemptyset(&mask);

sigaddset(&mask, SIGINT);

// OMITTED: Add other signal to mask.

sigaddset(&mask, SIGALRM);

sigprocmask(SIG_BLOCK, &mask, NULL);

pthread_create(&sig_thread, NULL, sighandler, (void\*) &mask);

alarm(REFRESH_INTERVAL); /\* Arm the alarm. \*/

for ( long j = 0; j \< NUMTHREADS; j++ ) { /\* Create the threads. \*/

td\[j\].fd = fd;

td\[j\].id = j;

pthread_create(&t\[j\], NULL, long_running_task, (void\*) &td\[j\]);

}

for ( i = 0; i \< NUMTHREADS; i++ )

pthread_join(t\[i\], NULL);

close(fd);

if ( -1 == nanosleep(&slight_pause, &remaining_sleep) )

nanosleep(&remaining_sleep, NULL);

alarm(0); /\* Disarm alarm. \*/

erase_progress_bar();

printf("Thread# Percent\n");

for ( i = 0; i \< NUMTHREADS; i++ )

printf("%d %f\n", i, 100 \* computedby\[i\]);

printf("The file ./taskorder has the sequence of thread accesses.\n"); exit(EXIT_SUCCESS);

}

*Listing 16-2: The* *main()* *function of* threaded_progbar.c I built the executable with

\$ **gcc -D_DEFAULT_SOURCE -DNUMTHREADS=4 -o threaded_progbar -L ../lib\\**

**-I../include threaded_progress_bar_mutex_synch.c -lspl -lm -lrt -pthread** and ran it. After displaying the progress bar growing, the output was: \$ **./threaded_progbar**

Thread# Percent

0 26.279767

1 24.309197

2 24.542369

3 24.868667

The file ./taskorder has the sequence of thread accesses.

Repeated runs show that the load is balanced fairly evenly among

the threads. This is due mostly to the way that the random numbers are generated. The *taskorder* file for this run was:

0,1,2,0,3,1,2,1,2,0,3,1,3,0,2,0,2,0,0,1,0,3,1,2,3,0,2,0,1,1,3,0,\\

0,2,1,1,3,1,3,0,2,1,1,3,3,0,1,2,1,3,2,1,3,0,1,0,2,0,1,3,1,2,0,0,\\

3,2,1,2,2,3,1,0,1,2,3,0,1,2,3,1,3,0,0,3,

I wrote an awk script to parse this file to produce the following

statistics for the number of times each thread acquired the mutex:

0 23

1 24

2 18

3 19

As the number of threads increases, contention for the critical section increases, and so does the system overhead. Creating the threads takes time, and each thread is locking and unlocking the mutex, which also

takes time. If you increase the number of threads steadily and run the program under the time command, you’ll see system time steadily

increasing.

MUTEXES: KEEP THEM SHORT AND SWEET

Too much of a good thing is usually not good. A mutex is doing its job if there are usually threads blocked on it. After all, if no thread were ever blocked on a given mutex, then we ought to wonder

whether we need it.

On the other hand, every thread blocked on the mutex is wasting

its valuable time and not getting any work done. If there are many

threads blocked on a mutex, it usually translates to longer running

time since the mutex is, in effect, serializing the executable code. It forces each thread to execute that code in sequence.

In general, you should keep your critical sections as short as

possible and use the fewest number of them possible. Locking and

unlocking mutexes takes time too.

*Other Types of Mutexes*

The type of a mutex is determined by the mutex attribute structure used to initialize it. There are four possible mutex types:

**PTHREAD_MUTEX_NORMAL** The type of mutex we’ve just examined

**PTHREAD_MUTEX_ERRORCHECK** Used during development—instead of

deadlocks when it’s misused, it generates errors

**PTHREAD_MUTEX_RECURSIVE** Can be used whenever a thread needs to lock a mutex more than once, such as locking it within a recursive

function

**PTHREAD_MUTEX_DEFAULT** Usually the same as PTHREAD_MUTEX_NORMAL

The default type is always PTHREAD_MUTEX_DEFAULT. To set the type of a mutex, use

int pthread_mutexattr_settype(pthread_mutexattr_t \*attr, int type);

passing a pointer to a mutexattr_t structure and the type to which it

should be set. Then you can use this mutexattr_t structure to initialize the mutex.

There is no function that, given a mutex, can determine the type of that mutex. The best one can do is to call

int pthread_mutexattr_gettype(const pthread_mutexattr_t \*restrict attr, int \*restrict type);

which retrieves the mutex type from a mutexattr_t structure. But since there is no function that retrieves the mutexattr_t structure of a mutex, if a program needs to retrieve the type of a mutex, it needs to have the

mutexattr\_ structure that was used to initialize the mutex to know the mutex type. This means passing it to the thread’s start function.

When a normal mutex is accessed incorrectly, either undefined

behavior or deadlock results, depending on how the erroneous access

took place. A thread will deadlock if it attempts to relock a mutex that it currently holds. If the mutex type is PTHREAD_MUTEX_ERRORCHECK, then error checking takes place instead of deadlock or undefined behavior.

Specifically, if a thread attempts to relock a mutex that it has already locked, the EDEADLK error is returned, and if a thread attempts to unlock a mutex that it has not locked or a mutex that is unlocked, an error is also returned.

Recursive mutexes, meaning those of type PTHREAD_MUTEX_RECURSIVE, can

be used when threads need to lock a mutex more than once, as in

recursive functions. Basically, the mutex maintains a counter:

When a thread first acquires the lock, the counter is set to 1.

Unlike a normal mutex, when a recursive mutex is relocked, rather

than deadlocking, the call succeeds and the counter is incremented.

A thread can continue to relock the mutex up to some system-

defined number of times.

Each call to unlock the mutex by that same thread that locked it

decrements the counter. When the counter reaches 0, the mutex is

unlocked and can be acquired by another thread.

Until the counter equals 0, all other threads attempting to acquire

the lock will be blocked on calls to pthread_mutex_lock().

A thread attempting to unlock a recursive mutex that another thread has locked is returned an error. A thread attempting to

unlock an unlocked recursive mutex also receives an error.

Listing 16-3 contains an example of a program that creates two threads that use a recursive mutex to synchronize their accesses to a

critical section of a recursive function. The program doesn’t do much; it increments a counter and prints a message when the thread is inside its critical section.

*recursive_mutex_demo.c*

\#define BOUND 4

pthread_mutex_t mutex; /\* Lock for CS \*/

struct timespec sleeptime = {0, 250000000}; /\* 0.25 secs of delay \*/

int count = 0; /\* Shared by threads \*/

void up(long int tid)

{

pthread_mutex_lock(&mutex);

printf("Thread %ld acquired lock in up(); count = %d\n", tid, count); nanosleep(&sleeptime, NULL);

if ( ++count \< BOUND )

up(tid);

else {

count = 0;

printf("Thread %ld returning from up(); count = %d\n", tid, count);

}

pthread_mutex_unlock(&mutex);

}

void \*thread_routine(void \*data)

{

up((long) data);


}

int main(int argc, char \*argv\[\])

{

pthread_t threads\[2\];

pthread_mutexattr_t attr;

pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);

pthread_mutex_init(&mutex, &attr);

for ( int t = 0; t \< 2; t++ ) if ( 0 != pthread_create(&threads\[t\], NULL, thread_routine,

(void \*) t) )

fatal_error(errno, "pthread_create");

for ( int t = 0; t \< 2; t++ ) {

pthread_join(threads\[t\], (void\*\*) NULL);

}

return 0;

}

*Listing 16-3: A program that uses a recursive mutex*

Before you run this program or read further, try to predict its output.

The output will show that when a recursive mutex is locked, it can be

relocked by the same thread without error but cannot be acquired by

another thread. Once a thread calls up(), it continues to call it recursively until count reaches the upper bound. Then it returns from all nested

calls. Only when the first call returns does the other thread run. The output is not displayed here.

Condition Variables

A *condition variable* is a synchronization tool that serves a different purpose from both mutexes and semaphores. It is an object that allows

threads to wait in a blocked state until some condition becomes true.

Using a condition variable requires associating it with two other

entities:

A Boolean condition, usually containing one or more shared

variables

![](/tmp/audit/iter1/epubregen/system-programming-in-linux/media/index-978_1.jpg)

A mutex that serializes the access to the code that tests the Boolean

condition

There are no functions that connect the condition to the condition

variable; it’s the programmer’s job to preserve this association

throughout the code. Although we don’t need to know how a condition

variable is implemented to use it, it’s helpful to realize that it has two internal components:

A queue of threads that are blocked on the condition

A reference to a mutex that is bound to that condition variable

The condition variable can be associated with only a single mutex at any time. I’ll say more about this later. Figure 16-3 depicts the condition variable object.

*Figure 16-3: A schematic representation of a condition variable*

Condition variables are more complex to use than either mutexes or

semaphores, mostly because they’re more powerful. Before we dive into

their details, let’s consider the limitations of mutexes so that we

understand why condition variables are an important tool to have on

hand.

*Why Do We Need Condition Variables?*

A mutex is a low-level lock and unlock mechanism, intended to prevent

simultaneous access to shared variables by more than one thread. It

doesn’t provide a way for one thread to notify another when some

condition has changed its state. There are synchronization problems

that can’t be solved efficiently with only mutexes. Consider a problem in

which there is some condition whose value depends on a shared variable. If that condition must be true for a thread to perform some

action, the thread has to repeatedly test the value of the condition while it holds the mutex that protects that shared variable. This repeated

testing loop wastes CPU cycles.

To make this concrete, let’s reconsider the producer-consumer

problem. In Chapter 12, we wrote a solution to this problem using POSIX shared memory and semaphores. It was designed to work with

any positive number of producer and consumer processes. Let’s try to

use a mutex instead of semaphores to solve this problem.

Assume that the global shared variables are as follows:

pthread_mutex_t buf_mutex = PTHREAD_MUTEX_INITIALIZER;

size_t count = 0; /\* Number of filled buffers \*/

int front = 0; /\* Index where consumer gets next item \*/

int rear = 0; /\* Index where producer puts next item \*/

int buf\[BUF_SIZE\]; /\* Capacity of buffer \*/

The producer’s main loop is of the form


pthread_mutex_lock(&buf_mutex);

if ( count \< BUF_SIZE ) {

// Generate next data item and store in data.

buf\[rear\] = data;

rear = (rear + 1) % BUF_SIZE;

count++;

}


}

and the consumer’s is of the form:


pthread_mutex_lock(&buf_mutex);

if ( count \> 0 ) { data = buf\[front\];

front = (front + 1) % BUF_SIZE;

count--;

// Consume data.

}


}

This code is correct in that it prevents race conditions on the buffer accesses and the updates to count; the problem is its performance.

Suppose that the buffer is empty because the producer hasn’t produced

any data for a while. In each iteration of its loop, the consumer will lock the mutex, test whether there’s anything in the buffer to consume (count

\> 0), and unlock the mutex. It will repeat this over and over, locking, testing, and unlocking until data is available. It would be more efficient if it could just block itself until data was available. This is where

condition variables can be used.

*The Typical Steps for Using Condition Variables*

A condition variable allows a thread that has acquired a mutex but

subsequently discovered that some condition is false to relinquish the mutex and block itself in the condition variable’s internal queue, all in a single atomic step. The thread then remains blocked in that queue until some other thread, detecting that this condition became true, signals the condition variable, which wakes up one of the waiting threads. The

programmer can associate the condition variable with any Boolean

condition.

For example, suppose a condition variable named bufspace_available

corresponds to there being at least one empty buffer in the buffer pool shared by producer and consumer threads. The condition might be

associated with the Boolean expression count \< BUF_SIZE, in this case. Then the producer’s main loop would consist of the following sequence of

actions:

1\. Generate data to store into the buffer.

2\. Try to acquire and lock a mutex, buf_mutex.

3\. If the buffer is full (count == BUF_SIZE), *atomical y* release the mutex and wait on bufspace_available’s queue.

4. When bufspace_available is signaled because the buffer has space available (count \< BUF_SIZE):

\(a\) Reacquire the buf_mutex lock.

\(b\) Insert the data into the buffer and increment the count.

\(c\) Unlock buf_mutex.

\(d\) Signal the consumer that there is data in the buffer.

The consumer would have symmetric code.

It’s time to look at the *Pthreads* API related to condition variables.

*Declaring and Initializing a Condition Variable*

A condition variable is declared to be of type pthread_cond_t. Condition variable initialization is similar to mutex initialization. There are two ways to initialize a condition variable:

Statically when it is declared, using the PTHREAD_COND_INITIALIZER

macro, as in:

pthread_cond_t condvar = PTHREAD_COND_INITIALIZER;

Dynamically with the pthread_cond_init() function, whose prototype

is:

int pthread_cond_init(pthread_cond_t \*restrict cond,

const pthread_condattr_t \*restrict attr);

This function is given the addresses of a condition variable and a

condition attribute structure and initializes the condition variable

to have the properties of that structure. If the attr argument is NULL, the condition is given the default attributes. Attempting to initialize an already initialized condition variable results in undefined

behavior.

The call

pthread_cond_init(&condvar, NULL);

is equivalent to the static method except that error checking is performed. On success, pthread_cond_init() returns 0; otherwise, it returns an error code.

*Waiting on a Condition Variable*

A thread can call one of two functions to wait on a condition variable: an untimed wait and a timed wait. Their prototypes are:

int pthread_cond_wait(pthread_cond_t \*restrict cond,

pthread_mutex_t \*restrict mutex);

int pthread_cond_timedwait(pthread_cond_t \*restrict cond,

pthread_mutex_t \*restrict mutex,

const struct timespec \*restrict abstime);

Before a thread calls either of these functions, it must have locked the mutex referred to by the second argument; otherwise, the effect of the call is undefined. Calling either function causes the following two

actions to take place atomically:

1\. The mutex is released from the thread.

2\. The thread is blocked on the condition variable cond.

The function is atomic in the sense that it guarantees that the calling thread will be blocked on the condition variable regardless of any

actions by any other threads between the time it releases the mutex and is moved onto the condition variable’s queue.

In the case of the untimed pthread_cond_wait(), the calling thread

remains blocked in this call until some other thread signals cond using either of the two signaling functions about to be described in “Signaling a Condition Variable.” If there are multiple threads in the condition

variable’s queue, it may not be the one to be awakened when the

condition is next signaled.

When a thread returns from pthread_cond_wait(), the mutex is locked

and owned by the now-unblocked thread.

In the case of pthread_cond_timedwait(), the calling thread remains blocked in this call until either some other thread signals cond or the absolute time specified by abstime is passed. If the time specified by abstime is passed before a thread signals the condition variable, the call returns with the error ETIMEDOUT; otherwise, it returns 0.

ONE MUTEX PER CONDITION VARIABLE

If a condition variable is already associated with a mutex because

one or more threads called one of the wait functions on it and are

still in its queue, an attempt by any other thread to wait on this

condition variable with a different mutex will fail. In other words,

calling pthread_cond_wait(&cond, &mutex) creates a dynamic binding between cond and mutex that remains in effect as long as at least one

thread is blocked on cond.

*Signaling a Condition Variable*

A thread can send a signal on a condition variable with one of two

different functions, whose prototypes are:

int pthread_cond_broadcast(pthread_cond_t \*cond);

int pthread_cond_signal(pthread_cond_t \*cond);

Both of these functions unblock threads that are blocked on a condition variable. The difference is that pthread_cond_signal() unblocks one of the threads that are blocked on the condition variable, whereas

pthread_cond_broadcast() unblocks all threads blocked on it. The man page notes that although any thread can call these functions, regardless of whether or not it currently owns the mutex associated with the

condition variable, if predictable scheduling of the threads is required, the calling thread should own the mutex associated with the condition

variable when it makes the call.

The pthread_cond_signal() is intended to unblock a single thread, but implementations of this function may unintentionally wake up more

than one thread if more than one are waiting. These unintended wake-

ups are called *spurious wake-ups*. They can happen because of the way that the calls are implemented. POSIX.1-2024 explicitly documents that spurious wake-ups may occur: “Correcting this problem would

unnecessarily reduce the degree of concurrency in this basic building

block for all higher-level synchronization operations.”

Because of spurious wake-ups, the fact that a thread returns from a

wait on a condition variable does not imply anything about the truth of the condition associated with this condition variable. Therefore, calls to wait on condition variables should be inside a loop, not in a simple if statement. For example, the producer code from earlier should be coded as:

// Generate data item to store into the buffer.

pthread_mutex_lock(&buffer_mutex);

while ( count == BUF_SIZE )

pthread_cond_wait(&bufspace_available, &buf_mutex);

// Add data item to buffer.


pthread_cond_signal(&data_available);

It is, in general, safer to code with a loop rather than an if statement, because if you made a logic error elsewhere in your code and it’s

possible that a thread can be signaled even though the associated

condition isn’t true, then having the wait occur inside a loop prevents the thread from being woken up erroneously, since it will reacquire the mutex, return from the call, retest the loop condition, and block again.

When multiple threads blocked on a condition variable are all

unblocked by a broadcast, the order in which they are unblocked

depends upon the scheduling policy. When they become unblocked,

they reacquire the mutex associated with the condition variable.

Therefore, the order in which they reacquire the mutex is dependent on the scheduling policy.

Condition variables have no record of how many signals have been received at any given time. Therefore, if a thread, say thread1, signals a condition cond before another thread, thread2, calls pthread_cond_wait() on cond, then thread2 will still wait on cond because the signal will have been lost—signals are not saved. Only a signal that arrives after a thread has called one of the wait functions can wake up that calling thread.

The man page clarifies the sense in which pthread_cond_wait() is

atomic: When a thread, thread1, calls pthread_cond_wait(), the mutex is unlocked and thread1 is blocked on the condition variable. It is possible for another thread, say thread2, to acquire the mutex after thread1 has released it but *before* it is blocked. If thread2, or any other thread for that matter, signals this condition variable after this mutex has been acquired by another thread, then thread1 will respond to the signal as if it had taken place after it had been blocked. This means that it will be

unblocked immediately and reacquire the mutex and the call will return.

*Destroying a Condition Variable*

When a condition variable is no longer needed, it should be removed

with pthread_cond_destroy(), whose prototype is:

int pthread_cond_destroy(pthread_cond_t \*cond);

This function destroys the given condition variable cond, after which it becomes, in effect, uninitialized. A thread can destroy an initialized condition variable only if no threads are currently blocked on it.

Attempting to destroy a condition variable upon which other threads

are currently blocked results in undefined behavior.

*Condition Attributes*

Condition variables have just two attributes: the process-shared

attribute and the clock attribute. The former allows the condition

variable to be accessed by a process other than the one in which it was created, provided that a memory mapping has made this possible. The

clock attribute is used to select which clock should be used by the

pthread_cond_timedwait() function. The condition variable attribute API consists of the following functions:

int pthread_condattr_init(pthread_condattr_t \*attr);

int pthread_condattr_destroy(pthread_condattr_t \*attr);

int pthread_condattr_getclock(const pthread_condattr_t \*restrict attr, clockid_t \*restrict clock_id);

int pthread_condattr_setclock(pthread_condattr_t \*attr, clockid_t clock_id); int pthread_condattr_getpshared(const pthread_condattr_t \*restrict attr, int \*restrict pshared);

int pthread_condattr_setpshared(pthread_condattr_t \*attr, int pshared); They’re described by their respective man pages.

*A Multithreaded Multiple Producer, Multiple Consumer Program*

We’ll use condition variables together with mutexes to create a multiple producer, multiple consumer program in which the producers and

consumers are threads. We can base the design of the producer on the

initial logic that I proposed in “The Typical Steps for Using Condition Variables” on page 753. The design of the consumer will be symmetric.

To simplify the program and reduce the amount of code, I’ve made

the following design decisions:

The data that producers “produce” will be integers.

Each producer produces the same fixed number of items and then

terminates.

Each producer and consumer will have a program-given internal

ID; the data produced by each producer will be derived from that

ID and the fixed number of items in such a way that no two

producers generate the same value.

Consumers will run as long as there are active producers and exit

when none are left.

The program will need the following file-scoped macros, constants,

and variables:

\#define MAX_ITEMS 20 /\* Default for MaxItems (below) \*/

\#define BUFFER_SIZE 16 /\* Fixed buffer capacity \*/

pthread_mutex_t buf_mutex = PTHREAD_MUTEX_INITIALIZER;

pthread_mutex_t prodcount_mutex = PTHREAD_MUTEX_INITIALIZER;

pthread_mutex_t conscount_mutex = PTHREAD_MUTEX_INITIALIZER;

pthread_cond_t space_available = PTHREAD_COND_INITIALIZER;

pthread_cond_t data_available = PTHREAD_COND_INITIALIZER;

int producer_count; /\* Number of current active producers \*/

int consumer_count; /\* Number of current active consumers \*/

int MaxItems = MAX_ITEMS; /\* Number of items each producer generates \*/

int front = 0; /\* Index of next read from buffer \*/

int rear = 0; /\* Index of next write into buffer \*/

int buffer\[BUFFER_SIZE\]; /\* Buffer for storing data \*/

int buf_count; /\* Number of items currently in buffer \*/

The condition variable space_available will be associated with the

condition in which the buffer is not full, and data_available will be

associated with the condition in which the buffer had data that hasn’t been consumed. The buf_mutex will control access to the shared buffer

and the index variables that producers and consumers update to access

the elements of that buffer. I’ll explain the need for the other two mutex variables, prodcount_mutex and conscount_mutex, shortly.

The producers will call add_buffer() to add a new item to the buffer

queue, and consumers will call get_buffer() to retrieve the item in the front of the buffer queue. The two functions are shown next:

void add_buffer(long data)

{

buffer\[rear\] = data;

rear = (rear + 1) % BUFFER_SIZE;

buf_count++;

}

int get_buffer()

{

long v = buffer\[front\];

front = (front + 1) % BUFFER_SIZE;

buf_count--;

return v;

}

These functions are called within critical sections protected by buf_mutex.

Producer Code

Based on the logic described in that earlier section, the producer

thread’s start function should look like Listing 16-4.

producer()

void \*producer(void \*data)

{

int i = 0;

long tid = (long) data;

while ( ++i \<= MaxItems ) {

pthread_mutex_lock(&buf_mutex);

while ( BUFFER_SIZE == buf_count )

pthread_cond_wait(&space_available, &buf_mutex);

add_buffer(tid \* (MaxItems) + i);

pthread_cond_signal(&data_available);


}

*--snip--*

}

*Listing 16-4: The producer thread start function*

Each producer locks the mutex and then checks the buffer full

condition. If it’s full (BUFFER_SIZE == buf_count), it blocks itself on the space_available condition variable. The call to pthread_cond_wait() is in a while loop because of possible spurious wake-ups, discussed earlier.

When space becomes available, a consumer thread will signal this

condition variable, and some producer will wake up and proceed to the

next instruction. The scheduling algorithm ensures that no producer

will wait indefinitely in the condition variable queue.

In each iteration, the producer adds the number tid \* MaxItems + i to the buffer. This implies that the producer with an ID tid adds the

numbers tid \* MaxItems + 1, tid \* MaxItems + 2, . . . , tid \* MaxItems + MaxItems, which equals (tid + 1) \* MaxItems, guaranteeing that the numbers each

generates are unique to it. For example, if MaxItems = 10, producer *p* generates 10 *p* + 1, 10 *p* + 2, 10 *p* +3, . . . , 10( *p* + 1).

After adding the data to the buffer, a producer signals the

data_available condition variable to wake up any consumers that were

blocked waiting for some data to arrive in the buffer. It releases the mutex and repeats these steps until it has produced MaxItems data

elements.

When the producer has exited its loop, it prints a message and

decrements the count of active producers. Since all producers can

modify this count, this code is protected by locking the prodcount_mutex.

This is the code that was snipped from the start function shown in

Listing 16-4:

printf("Producer %ld is exiting\n", tid);

pthread_mutex_lock(&prodcount_mutex);

producer_count--;

if ( producer_count == 0 )

while ( consumer_count \> 0 )

pthread_cond_signal(&data_available);

pthread_mutex_unlock(&prodcount_mutex);


The very last producer to exit needs to make sure that no consumers are left waiting for more data. It checks whether consumer_count \> 0. If so, it signals data_available for each consumer. There is no harm in sending too many signals, because consumers, like producers, wait inside a while

loop.

Consumer Code

The consumer design is almost symmetric to that of the producer. It has to be different because a consumer thread cannot let itself be in a

situation in which it’s waiting for data but all of the producers have

exited. Therefore, its main loop checks this possibility, as shown in

Listing 16-5.

consumer()

void \*consumer(void \*data)

{

long tid = (long) data;


pthread_mutex_lock(&buf_mutex);

while ( 0 == buf_count ) {

if ( producer_count \> 0 ) /\* Any producers left? \*/

pthread_cond_wait(&data_available,&buf_mutex);

else { /\* No producers left, so clean up and exit. \*/


printf("Consumer %ld exiting because all producers left.\n", tid);

pthread_mutex_lock(&conscount_mutex);

consumer_count--;

pthread_mutex_unlock(&conscount_mutex);


}

}

long v = get_buffer(); /\* If we reach here, data's available. \*/

printf("Consumer %ld received %ld from buffer; buffer size = %d\n", tid, v, buf_count);

pthread_cond_signal(&space_available);


}


}

*Listing 16-5: The consumer thread start function*

When a consumer finds that buf_count is 0, it blocks itself on the

condition variable data_available. When it wakes up, it retrieves data from the buffer, prints a message, signals the space_available condition variable in case any producers are blocked in it, and unlocks the mutex.

The main program does very little. Since we might want to

experiment with the numbers of producers and consumers, as well as the

amount of data, it should have command line options to control for these. Therefore, the program’s synopsis is

pthread_prod_cons \[-p *num* \] \[-c *num* \] \[-m *num*\]

in which the supplied numbers should be non-negative. The -p controls

the number of producers (default = 1), the -c the number of consumers

(default = 1), and the -m the total number of items generated by each

producer (default = 20).

The main program is shown in Listing 16-6, with the option-parsing code and some error handling removed. The complete program,

*pthread_prod \_cons.c*, is available in the book’s source code distribution.

*pthread_prodcons.c* main()

int main(int argc, char \*argv\[\])

{

long i; /\* Thread data \*/

int numConsumers = 1; /\* Defaults \*/

int numProducers = 1;

pthread_t \*producer_thread; /\* Dynamically allocated thread ID arrays \*/

pthread_t \*consumer_thread;

// OMITTED: Option parsing

producer_thread = (pthread_t\*) calloc(numProducers, sizeof(pthread_t)); consumer_thread = (pthread_t\*) calloc(numConsumers, sizeof(pthread_t)); producer_count = numProducers;

consumer_count = numConsumers;

if ( producer_thread == NULL \|\| consumer_thread == NULL )

fatal_error(errno, "calloc");

buf_count = 0;

/\* Create consumers first so that signals from producers aren't lost. \*/

for ( i = 0; i \< numConsumers; i++ )

pthread_create(&consumer_thread\[i\], NULL, consumer, (void\*) i);

for ( i = 0; i \< numProducers; i++ )

pthread_create(&producer_thread\[i\], NULL, producer, (void\*) i);

/\* Wait for all child threads. \*/

for ( i = 0; i \< numProducers; i++ )

pthread_join(producer_thread\[i\], NULL);

for ( i = 0; i \< numConsumers; i++ )

pthread_join(consumer_thread\[i\], NULL);

free(producer_thread); /\* Clean up. \*/

free(consumer_thread);

exit(EXIT_SUCCESS);

}

*Listing 16-6: The main program for* pthread_prodcons.c

We can run this with any numbers of producer and consumer

threads. The output is designed so that we can check whether it’s

working as we expect. In particular, each time that a consumer thread

retrieves an item, it writes a message to standard output. What must be true is that the number of messages equals the total number of

producers times the maximum number of items per producer. For

example:

\$ **./pthread_prod_cons -m 100 -p8 -c4**

Consumer 0 received 1 from buffer; buffer size = 9

Consumer 0 received 2 from buffer; buffer size = 8

*--snip--*

Consumer 1 received 700 from buffer; buffer size = 1

Producer 5 is exiting

Consumer 1 received 600 from buffer; buffer size = 0

Consumer 0 exiting because all producers left.

Consumer 1 exiting because all producers left.

Consumer 2 exiting because all producers left.

Consumer 3 exiting because all producers left.

The order in which consumers receive and print data is not controlled, but if the program is working correctly, the last lines of output will be those of exiting consumers.

Barrier Synchronization

In some applications, the individual threads need to periodically wait for all of the threads to reach a synchronization point before any of them proceed. This is common in multithreaded programs in which large

numbers of threads have divided up a large dataset and each has

computed some partial results, but all need the partial results of the other threads before they proceed. Programs that divide a computation

into stages have to work this way. For example, the threads in a

multithreaded version of the Floyd–Warshall algorithm for computing

shortest paths in a finite graph need to synchronize this way. A more

entertaining example is a multithreaded version of Conway’s *Game of* *Life*.

The *Game of Life* simulates the growth of a colony of organisms over time. Imagine a finite, two-dimensional grid in which each cell

represents an organism. Time advances in discrete time steps, *t* 0, *t* 1, *t* 2, ad infinitum. Whether or not an organism survives in cell ( *i*, *j*) at time *tk*+1 depends on how many organisms are living in the adjacent

surrounding cells at time *tk*. Whether or not an organism is born into an empty cell ( *i*, *j*) is also determined by the state of the adjacent cells at the given time. The exact rules aren’t relevant.

A simple multithreaded simulation of the progression of states of the

grid is to create a unique thread to simulate each individual cell and to create two grids, A and B, of the same dimensions. The initial state of the population is assigned to grid A. At each time step *tk*, the thread responsible for cell ( *i*, *j*) would perform the following tasks: 1. For cell A\[ *i*, *j*\], examine the states of each of its eight neighboring cells A\[ *m*, *n*\] and set the value of B\[ *i*, *j*\] accordingly.

2\. When all other cells have finished their step 1, copy B\[ *i*, *j*\] to A\[ *i*, *j*\], and repeat steps 1 and 2.

Notice that this solution requires that each cell wait for all other cells to reach the same point in the code. This could be achieved with a

combination of mutexes and condition variables. Let’s see how we could implement this.

The main program would initialize the value of a counter variable (count) to 0. Assuming there are N threads, each would execute a loop of the form:

loop forever {

update_cell(i,j);

pthread_mutex_lock(&update_mutex);

count++;

if ( count \< N )

pthread_cond_wait(&all_threads_ready, &update_mutex);

/\* count reached N, so all threads proceed. \*/

pthread_cond_broadcast(&all_threads_ready);

count--;

pthread_mutex_unlock(&update_mutex);

pthread_mutex_lock(&count_mutex);

if ( count \> 0 )

pthread_cond_wait(&all_threads_at_start, &count_mutex);

pthread_cond_broadcast(&all_threads_at_start);

pthread_mutex_unlock(&count_mutex);

}

Essentially, after each thread updates its cell, it tries to acquire a mutex named update_mutex. The cell that acquires the mutex increments count

and then waits on a condition variable, all_threads_ready, associated with the predicate count \< N. As it releases update_mutex, the next thread does the same and so on until all but one thread has been blocked on the

condition variable. Eventually, the last thread acquires the mutex,

increments count and, finding count == N, issues a broadcast on the

condition variable all_threads_ready, which unblocks all of the waiting threads, one by one.

One by one, each thread then decrements count inside the region of

code locked by update_mutex. If each were allowed to cycle back to the top of the loop, this code would not work, because one thread could quickly speed around and increment count so that it equaled N again even though the others had not even started their updates. Instead, no thread is

allowed to go back to the top of the loop until count reaches 0. This is achieved by using a second condition variable, all_threads_at_start. All

![](/tmp/audit/iter1/epubregen/system-programming-in-linux/media/index-995_1.jpg)

threads will block on this condition except the one that sets the value of count to 0 when it decrements it. When that happens, every thread is

unblocked and they all start this cycle all over again. This is visualized in

Figure 16-4.

*Figure 16-4: A conceptualization of a barrier synchronization point showing what time each* *thread reached it and that they all resume at the same time when the last thread arrives at* *it*

This does work, roughly, but it adds so much serial code to the

parallel algorithm that it defeats the purpose of using multiple threads in the first place! It ignores the possibility of spurious wake-ups and would be even more complex if these were taken into account.

Fortunately, there is a simpler solution: The *Pthreads* library has a barrier synchronization primitive that solves this synchronization

problem efficiently and elegantly.

A *barrier synchronization point* is an instruction in a program at which the executing thread must wait until all participating threads have

reached that same point. If you’ve ever been in a group of people being taken on a guided tour of a facility or an institution of some kind, then

you might have experienced this type of synchronization. The guide will wait for all members of the group to reach a certain point, and only then will they allow the group to move to the next set of locations.

*Pthreads Barriers*

The *Pthreads* implementation of a barrier lets the programmer initialize the barrier to the number of threads that must reach the barrier in order for it to be opened. There are only three functions in the *Pthreads* API specifically related to barriers: one to initialize a barrier, one to destroy one, and a third to wait on one.

A barrier is declared as a variable of type pthread_barrier_t. The

function to initialize a barrier has the prototype:

int pthread_barrier_init(pthread_barrier_t \*restrict barrier,

const pthread_barrierattr_t \*restrict attr,

unsigned count);

It’s given the address of a barrier; the address of a barrier attribute structure, which may be NULL to use the default attributes; and a positive value count. The count argument specifies the number of threads that

must reach the barrier before any of them successfully return from the call. If the function succeeds, it returns 0. The function results are undefined if a thread attempts to initialize an existing barrier on which one or more threads are waiting.

A thread calls

int pthread_barrier_wait(pthread_barrier_t \*barrier);

to wait at the barrier given by the argument. When the number of

threads that have called pthread_barrier_wait() on a given barrier equals the count with which it was initialized, all threads waiting on the barrier return from the call. The constant PTHREAD_BARRIER_SERIAL_THREAD is returned to exactly one of these threads and 0 is returned to each of the

remaining threads. There is no particular rule for which thread receives the special return value. At this point, the barrier is reset to the state it had as a result of the most recent call to pthread_barrier_init().

Some programs may not need to take advantage of the fact that a single thread received the value PTHREAD_BARRIER_SERIAL_THREAD, but others may find it useful, particularly if exactly one thread has to perform a task when the barrier has been reached. A thread can check for errors when

it returns from waiting at a barrier with

retval = pthread_barrier_wait(&barrier);

if ( PTHREAD_BARRIER_SERIAL_THREAD != retval && 0 != retval )

pthread_exit((void\*) retval);

which will force a thread to exit if it did not get one of the nonerror values. The return value can be retrieved by another thread that calls pthread_join() for this thread.

A barrier is destroyed using

int pthread_barrier_destroy(pthread_barrier_t \*barrier);

which destroys the barrier and releases any resources used by it. The

effect of any subsequent use of the barrier is undefined until the barrier is reinitialized by another call to pthread_barrier_init(). The results are undefined if pthread_barrier_destroy() is called when any thread is blocked on the barrier or if this function is called with an uninitialized barrier.

*A Program Using Barrier Synchronization*

Some accounting and system administrative commands need to

compute the sums of various system statistics. For example, system

monitors compute and display the amount of virtual memory currently

used by all processes, as well as other sums, such as the total number of bytes received over a network interface, and commands such as vmstat

and iostat report accumulated amounts of other resource consumption.

When the amount of data is large enough, the computations performed

by these types of programs can be sped up by multithreading them.

As exercise in multithreading with barrier synchronization, we’ll

develop a program, vmem_usage (short for “virtual memory usage”), that displays on standard output the total amount of virtual memory in KB

used by all processes at the time that it’s run. Writing this program will integrate the work we did in Chapter 10 in our implementation of a

simplified ps command and the work in Chapter 7 in directory scanning with the ideas from this chapter about multithreading and

synchronization barriers. In addition, we’ll develop an algorithm for this program that will have much broader application than this one

particular command. We can make the number of threads an argument

to the program so that we can see the effect on performance easily, by running it with different numbers.

Design Strategies

The sequential algorithm for adding *N* numbers in a linear array of length *N* performs *N* – 1 additions. When *N* is very large, we can divide the work up among a number of threads. Let’s consider the possible

ways that the threads can cooperate in computing the total, the goal

being to minimize running time. Assume in the following that *p* is the number of threads. The possible choices include:

Declare a global variable named total. Every time that a thread

needs to add one of its elements to total, it locks a mutex, adds the

element to it, and unlocks the mutex. This is a poor idea because no

two threads will be able to add their values at the same time,

effectively serializing the summation, and the multithreaded

program would take even longer than the sequential one because of

all of the mutex operations!

Assign each thread approximately *N/p* consecutive array elements.

Each thread computes a partial sum of these elements and then

adds its partial sum to total. Each thread would therefore perform

about *N/p* – 1 additions to compute its partial sum, all concurrently with the other threads. Each thread would add its partial sum to

total by locking a mutex, updating total, and unlocking the mutex.

This serializes the updates to total and greatly improves the

running time. In the worst case, it could require *p* additions, performed in sequence, to get the final value of total.

Assign each thread approximately *N/p* consecutive array elements as just described, but when a thread finishes, it waits at a barrier

until all threads have finished. When all threads reach the barrier,

they can add their partial sums together with a divide-and-conquer strategy in such a way that the partial sums can be added together

in about log2 *p* steps.

The last choice is the best. Let’s assume that the program creates an

array named partial_sum of length *p*. Thread *t* stores its partial sum in partial \_sum\[t\]. Somehow the threads need to add the elements in this

array using a divide-and-conquer algorithm.

Parallel Reduction

When a mathematical expression such as 1 + 2 + 3 + 4 is replaced by its value, 10, we say that it’s been *reduced*. In mathematics, *reduction* is the rewriting of an expression into a simpler form. Binary arithmetic

operators such as addition, multiplication, and maximum are associative, which means that

*a* + ( *b* + *c*) = ( *a* + *b*) + *c*

and:

max( *a*, max( *b*, *c*)) = max(max( *a*, *b*), *c*) Operations with this property are amenable to parallelization because

the operations can be applied in any order in parallel. An algorithm that performs a reduction such as this is called a *paral el reduction algorithm*.

We can add the elements of an array of size *p* in parallel with a divide-and-conquer algorithm as follows. Let’s assume initially that *p* is a power of 2, say *p* = 2 *m*. We’ll also assume that each thread has a unique ID in the interval \[0, *p* – 1\].

1\. The set of thread IDs is divided into a lower half and an upper

half. Every thread *t* in the lower half has a *mate* in the upper half defined to be *t* + *p*/2. Correspondingly we’ll say *t* is the mate of *t* +

*p*/2. If *p* = 16, for example, then set of all mates is (0,8), (1,9), . . . , (7,15).

2. Each thread waits at a synchronization barrier until all threads have reached it.

3\. Each thread in the lower half adds its mate’s value to its own.

4\. Since all values in the upper half have been added to

corresponding values in the lower half, the upper half isn’t needed

any more, and the algorithm repeats but with the lower half

treated as the entire array. In other words, the lower half is divided in a lower half of itself and an upper half of itself (by setting *p* =

*p*/2). If *p* was originally 16, it is now 8 and the mates are (0,4), (1,5), (2,6), and (3,7). If the size of the set is greater than 1, go back to step 2.

5\. When the set size is 1, the thread with ID 0 contains the total.

Figure 16-5 illustrates the flow of data for an array A of size 16. An arrow from element A\[ *k*\] to element A\[ *j*\] represents adding of A\[ *k*\] to A\[ *j*\].

![](/tmp/audit/iter1/epubregen/system-programming-in-linux/media/index-1001_1.jpg)

*Figure 16-5: The four stages of parallel reduction of an array with a size of 16 by 16*

*threads*

This algorithm takes *O*(log( *p*)) steps when *p* is a power of 2. When *p* is not a power of 2, it has to do a bit more work, because there will be an unmated array element in the last position of the array. In this case, the thread with ID 0 just adds its value to its own in addition to adding its mate’s value. The entire running time for the summation is on the order of *O*(( *N*/ *p*) + log( *p*)).

The reduction algorithm executed in parallel by each thread is

shown in Listing 16-7.

label={lst:sum-reduction}\]

/\* Executing thread's ID is tid. \*/

while ( p \> 1 ) {

pthread_barrier_wait(&barrier);/\* Wait for all threads to reach barrier.\*/

if ( p % 2 == 1 && tid == 0 ) /\* If thread\[0\] and p is odd number, ➊ partial_sum\[0\] += partial_sum\[p-1\]; add last element to 0th. \*/

p = p / 2; /\* Iterate over lower half next time. \*/

if ( tid \< p ) /\* If I'm in lower half, get mate's value. \*/

partial_sum\[tid\] = partial_sum\[tid\] + partial_sum\[tid+p\];

}

*Listing 16-7: The parallel sum reduction algorithm*

The thread that owns element 0 of the array adds the last element of the array ➊ to element 0 if *p* is odd. Since this divides the array in half each time, after ⌈ *log* 2( *p*)⌉ iterations, it stops.

Program Design

The program consists of two separate stages. The first stage collects the data that will be summed, namely the total virtual memory size of each process. The second stage is the summation of that data. By separating out the two tasks, we can replace the first stage easily enough so that, instead of adding virtual memory sizes, it can add any other data, as long as it stores it in an array of the same type. The virtual memory size that the program will use is the value from the */proc\[pid\]/stat* file’s 23rd field, which the documentation states is the process’s virtual memory size.

The same value is available in the */proc\[pid\]/status* file, measured in KB, on the line labeled VmSize:.

The program will declare the following data and types in file scope:

\#define MAX_LINE 512 /\* Size of buffers allocated for input \*/

long \*partial_sum; /\* Array of partial sums of data \*/

long \*vmsizes; /\* Dynamically allocated array of data \*/

pthread_barrier_t barrier; /\* Barrier for threads to synchronize \*/

/\* Data structure passed to each thread start function \*/

typedef struct \_task_data

{

int first; /\* Index of first element for thread \*/

int last; /\* Index of last element for thread \*/

int task_id; /\* Thread's program ID \*/

int num_threads; /\* Total number of threads \*/

long \*data; /\* Copy of pointer to array of data \*/

} task_data;

The program will use the following functions:

/\* Extract the 23rd field from the buffer and store into vsize. \*/

void extract_vmsize_from_buffer(char \*buf, long int \*vsize);

/\* Gets the virtual memory size in /proc/\[pid\]/stat and stores in vmdata\[i\] \*/

void get_vmsize(const struct dirent \*direntp, int i, long \*vmdata);

/\* Creates an array containing the virtual memory sizes of all processes, returning the size in \*n. Program must free array. \*/

void get_all_vmsizes(long \*\*array, long \*n);

/\* Thread start function. Adds the elements of thread_data-\>data. \*/

void \*sum_reduce(void \*thread_data);

/\* Compute the sum of values\[0\]...values\[size-1\] with num_threads threads. \*/

long compute_sum(long \*values, int size, int num_threads);

Let’s look at the program in top-down order, starting with main(). To

save space, the main program is displayed without most error handling

in Listing 16-8.

*vmem_usage.c* main()

int main(int argc, char \*argv\[\])

{

long array_size; /\* Number of processes, and thus array size \*/

long sum; /\* Total in kbytes \*/

int retval; /\* Return from call to get command line arg \*/

int num_threads; /\* Number of threads this program will use \*/ if ( argc \< 2 ) /\* If no argument, use just one thread. \*/

num_threads = 1;

retval = get_int(argv\[1\], NON_NEG_ONLY, &num_threads, NULL); if ( 0 \>= num_threads )

fatal_error(-1, "Negative number of threads");

/\* Get the virtual memory sizes of all processes; store in vmsizes. \*/

➊ get_all_vmsizes(&vmsizes, &array_size);

/\* Call a function that computes the sum, passing the

array of data, its length, and the number of threads. \*/

sum = compute_sum(vmsizes, array_size, num_threads);

printf("%10ld KB\n", sum);

free (vmsizes);

return 0;

}

*Listing 16-8: The main program for* vmem_usage.c

The function that gets the virtual memory sizes, get_all_vmsizes(), ➊

is based on the printallprocs() function used in the *spl_ps.c* program from

Chapter 10. The difference between them is that, rather than calling readdir() repeatedly, this uses the scandir() function to populate an array of pointers to dirent structures, with a structure for each subdirectory within */proc* that represents a process. It is shown in Listing 16-9. We can easily modify this program so that it outputs the totals for a

different set of process metrics.

get_all_vmsizes()

void get_all_vmsizes(long \*\*array, long \*n)

{

struct dirent \*\*namelist;

long i = 0;

errno = 0;

if ( ((\*n) = scandir("/proc", &namelist, numeric_dir_filter, NULL)) \< 0 ) fatal_error(errno, "scandir");

if ( NULL == (\*array = (long\*) calloc((\*n), sizeof(long))) )

fatal_error(errno, "malloc");

while ( i \< (\*n) - 1 ) {

➊ get_vmsize(namelist\[i\], i, \*array);

free(namelist\[i\]);

i++;

}

free(namelist);

}

*Listing 16-9: The function that fills an array with the virtual memory sizes of all active* *processes*

It uses a filtering function (numeric_dir_filter()) that limits namelist to contain only pointers to dirent structures of directories whose names are numeric. The filter function is not shown here. (See Chapter 7 to review filter functions or read the scandir(3) man page.) The call to get_vmsize() ➊ opens the *stat* file in the directory pointed to by namelist\[i\], parses the line in that file to get the virtual memory size of that process, and copies its value into array\[i\].

Its code, without any error handling, is displayed in Listing 16-10.

get_vmsize()

void get_vmsize(const struct dirent \*direntp, int i, long \*vmdata)

{

char pathname\[PATH_MAX\]; /\* Pathname to file to open \*/

size_t len = MAX_LINE; /\* Length of line getline() returned \*/

FILE \*fp; /\* File stream to read \*/

char \*buf; /\* To store line from file \*/

long vsize; /\* Virtual memory size in bytes \*/

buf = calloc(MAX_LINE, 1); /\* Allocate buffer for getline(). \*/

memset(pathname, '\0', PATH_MAX); /\* Zero memory for path name. \*/

sprintf(pathname, "/proc/%s/stat", direntp-\>d_name);

fp = fopen(pathname, "r"); /\* Open file. \*/

getline(&buf, &len, fp ); /\* Read the line. \*/

extract_vmsize_from_buffer(buf, &vsize); /\* Parse line in buf. \*/

vmdata\[i\] = vsize/1024; /\* Express in KB. \*/

free(buf);

}

*Listing 16-10: The function that gets the virtual memory size of a single process whose* *directory pointer is passed to it*

The extract_vmsize_from_buffer() function extracts the 23rd field in the *stat* file, which contains the virtual memory size in bytes. The program

converts it to KB before storing it into the array. This function is not shown here. We could also get this same value from the *status* file in that directory, but the algorithm would have to read and parse more lines,

similar to the *ancestors.c* program from Chapter 10. This solution is faster.

The remaining part of the program is the function that computes

the array totals. The compute_sum() function encapsulates all of this logic, creating the threads and calling the thread start function, sum_reduce(), shown next in Listing 16-11. The compute_sum() function follows after that.

sum_reduce()

void \*sum_reduce(void \*thread_data)

{

task_data \*t_data; /\* Thread data passed to each thread \*/

int tid; /\* Thread internal ID \*/

int half; /\* Half the size of the partial_sums array \*/

int retval;

t_data = (task_data\*) thread_data; /\* Cast argument pointer. \*/ tid =

t_data-\>task_id; /\* Get thread ID. \*/

/\* Compute thread tid's partial sum sequentially: \*/

partial_sum\[tid\] = 0;

for ( int k = t_data-\>first; k \<= t_data-\>last; k++ )

partial_sum\[tid\] += t_data-\>data\[k\];

/\* Start the parallel reduction. Divide the array in half. \*/

half = t_data-\>num_threads;

while ( half \> 1 ) { /\* Repeat until sum is in partial_sum\[0\]. \*/

➊ retval = pthread_barrier_wait(&barrier);

if ( PTHREAD_BARRIER_SERIAL_THREAD != retval && 0 != retval )

pthread_exit((void\*) 0);

if ( half % 2 == 1 && tid == 0 )

partial_sum\[0\] += partial_sum\[half-1\];

half = half/2; /\* Reduce array size. \*/

if ( tid \< half ) /\* If I am lower half mate, add mate to me. \*/

partial_sum\[tid\] += partial_sum\[tid+half\];

}

pthread_exit((void\*) 0);

}

*Listing 16-11: The thread start function, in which each thread computes a partial sum of its* *share of the array and then participates in a parallel reduction*

This is where the barrier is used. No thread can advance past the barrier ➊ until all threads have reached this same place in the algorithm.

This thread start function is called by compute_sum(), which is

displayed in part in Listing 16-12. Some error handling is removed.

compute_sum()

long compute_sum(long \*values, int size, int num_threads)

{

int t;

pthread_t \*threads;

task_data \*thread_data;

long sum;

pthread_attr_init(&attr);

pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);

/\* Allocate the array of threads, task_data structures, data, and sums. \*/

threads = calloc(num_threads, sizeof(pthread_t));

thread_data = calloc(num_threads, sizeof(task_data));

partial_sum = calloc(num_threads, sizeof(double));

// OMITTED: Check for errors.

/\* Initialize a barrier with a count equal to the number of threads. \*/

pthread_barrier_init(&barrier, NULL, num_threads); for ( t = 0; t \<

num_threads; t++ ) {

thread_data\[t\].first = (t \* size)/num_threads;

thread_data\[t\].last = ((t + 1) \* size)/num_threads - 1;

thread_data\[t\].task_id = t;

thread_data\[t\].num_threads = num_threads;

thread_data\[t\].data = values;

pthread_create(&threads\[t\], NULL, sum_reduce, (void\*) &thread_data\[t\]);

}

for ( t = 0; t \< num_threads; t++ ) /\* Join all threads. \*/

pthread_join(threads\[t\], (void\*\*) NULL);

pthread_barrier_destroy(&barrier);

sum = partial_sum\[0\];

// OMITTED: Free all dynamically allocated memory.

return(sum);

}

*Listing 16-12: The function that sets up all threads and thread data for execution and then* *creates the threads and joins them*

The complete program, *vmem_usage.c*, is available in the book’s source code distribution. A few runs of it with varying numbers of

threads, run under the bash time command, show that there isn’t a

significant change in running time as the number of threads increases, but if that number is too large, the running time gets much worse

because of the overhead of creating the threads. Here are a few runs to illustrate:

\$ **time ./vmem_usage 1**

345082208 KB

real 0m0.011s

user 0m0.005s

sys

0m0.006s

\$ **time ./vmem_usage 4**

345082208 KB

real 0m0.011s

user 0m0.006s

sys

0m0.004s

\$ **time ./vmem_usage 64**

345082208 KB

real 0m0.015s

user 0m0.010s

sys 0m0.015s

This particular example doesn’t show the benefits of multithreading in terms of runtime because the amount of data is small. I leave it as an exercise to replace the get_all_vmsizes() function with one that creates extremely large arrays of arbitrary data, just to see the effect on

performance of increasing the number of threads.

Read-Write Locks

A mutex is a simple synchronization tool; it has just two states, locked and unlocked, and only one thread can lock it at a time. In some

applications, a more sophisticated tool is needed. For instance, consider a multithreaded program that maintains a large dataset in which a single thread updates the dataset occasionally but multiple threads read it

frequently. In this case:

Reading threads should be allowed simultaneous access to the

database.

Writing threads must have exclusive access to the database when

they write to it because during a write operation, the data might be

in an unstable state.

This is a form of *categorical mutual exclusion*, which is a type of mutual exclusion based on the category of a process: A thread in the reader

category being in a critical section does not exclude other threads in that same category, but the presence of a thread in the writer category in the critical section excludes threads from all categories.

It would be convenient if there were some mechanism that would

allow this type of synchronization control. Searching for the keywords *reader* and *writer* in the man pages comes up empty, but the following search is successful:

\$ **apropos -s2,3 -a read write pthread**

pthread_rwlock_destroy (3posix) - destroy and initialize a read-write lock...

pthread_rwlock_rdlock (3posix) - lock a read-write lock object for reading

*--snip--*

The POSIX threads API provides a tool called a *read-write lock*. Multiple readers can lock a read-write lock without blocking each other yet block writers from accessing it. If a single writer acquires the lock, it obtains exclusive access to it; any thread, whether a reader or a writer, will be blocked if it attempts to acquire the lock while the writer holds it.

This property of read-write locks allows for a higher degree of

concurrency than a mutex. Unlike mutexes, they have three possible

states:

Locked in read mode

Locked in write mode

Unlocked

For simplicity, I may sometimes call a read-write lock that’s

currently locked for reading a *read lock* and one that’s currently locked for writing a *write lock*. Multiple threads can hold a read-write lock in read mode, but only a single thread can hold a read-write lock in write mode. In effect, read locks can be shared, but write locks are exclusive; they’re held by one thread at a time. This same effect could be achieved, although with significant overhead, with a combination of condition

variables and mutexes; the *Pthreads* read-write lock API simplifies programming for us.

*Read-Write Lock API Overview*

Let’s begin with a big picture of the read-write lock API. Because of

their complexity, there are more functions for locking and unlocking

read-write locks than for simple mutexes. The prototypes for the

functions are listed by category here. A thread wishing to acquire a

read-write lock for reading uses a different set of functions than one that wants to write. We’ll examine their semantics afterward.

Initializing and Destroying Read-Write Locks

Like the other POSIX synchronization primitives, there are static and dynamic ways to initialize a read-write lock and a single function to

destroy one:

int pthread_rwlock_init(pthread_rwlock_t \*restrict rwlock,

const pthread_rwlockattr_t \*restrict attr);

pthread_rwlock_t rwlock = PTHREAD_RWLOCK_INITIALIZER;

int pthread_rwlock_destroy(pthread_rwlock_t \*rwlock);

The initializer macro PTHREAD_RWLOCK_INITIALIZER is equivalent to calling pthread \_rwlock_init() with a NULL second argument.

Locking for Reading

Like locking a mutex, there are three ways to lock a read-write lock for reading:

int pthread_rwlock_rdlock(pthread_rwlock_t \*rwlock);

int pthread_rwlock_tryrdlock(pthread_rwlock_t \*rwlock);

int pthread_rwlock_timedrdlock(pthread_rwlock_t \*restrict rwlock,

const struct timespec \*restrict abstime);

The pthread_rwlock_tryrdlock and pthread_rwlock_timedrdlock versions are similar to the corresponding locking functions of a mutex.

Locking for Writing

There are also three different functions that will lock a read-write lock for writing, with analogous meanings:

int pthread_rwlock_wrlock(pthread_rwlock_t \*rwlock);

int pthread_rwlock_trywrlock(pthread_rwlock_t \*rwlock);

int pthread_rwlock_timedwrlock(pthread_rwlock_t \*restrict rwlock,

const struct timespec \*restrict abstime);

Notice the structure of these function names. The suffix of the function name, such as \_wrlock, indicates the mode of the lock. The read versions have the suffix \_rdlock.

Unlocking

There’s but a single function to unlock a read-write lock: int pthread_rwlock_unlock(pthread_rwlock_t \*rwlock);

This unlocks the lock regardless of whether it was held for reading or writing.

Working with Attributes

Although these locks don’t have many attributes that we’re likely to set, the functions that do so follow:

int pthread_rwlockattr_init(pthread_rwlockattr_t \*attr);

int pthread_rwlockattr_destroy(pthread_rwlockattr_t \*attr);

int pthread_rwlockattr_getpshared(const pthread_rwlockattr_t

\*restrict attr, int \*restrict pshared);

int pthread_rwlockattr_setpshared(pthread_rwlockattr_t \*attr, int pshared); The process-shared attribute is not required to be implemented by a

POSIX-compliant system, and there are no others that can be modified.

Therefore, most of the time, we can accept the default attributes.

*Use and Semantics of Read-Write Locks*

I find it helpful to think about read-write locks as if they were keys to physical locks on the door of a room. The room is the code that the

read-write lock protects. If the read-write lock is not currently held by any thread and a writing thread acquires it, it enters the room and locks the door so that no other thread can enter. On the other hand, if the

read-write lock is not currently held by any thread and a reading thread acquires it, then it enters the room and leaves a guard at the door. If an arriving thread wants to write, the guard makes it wait in a line outside of the door until the reader leaves the room, or possibly later. All

arriving writers will wait in this line while the reader is in the room. If an arriving thread wants to read, whether or not it’s let into the room depends on the guard. The guard’s decision depends on how *Pthreads* is configured.

![](/tmp/audit/iter1/epubregen/system-programming-in-linux/media/index-1013_1.jpg)

Some systems support a *Pthreads* configuration option known as

*Thread Execution Scheduling,* or *TES*. This option allows the programmer to control how threads are scheduled. If your system has functions to

control thread scheduling, such as pthread_getschedparam(), then *TES* is enabled. If the system doesn’t support this option and there’s a reader in the room with writers standing in line waiting to enter, when a reader arrives at the door, it is up to the implementation to decide whether the reader can enter immediately or must wait outside along with the

writers.

If *TES* is supported, then the decision is based on the scheduling policy that’s in force. If either SCHED_FIFO, SCHED_RR (round-robin), or SCHED_SPORADIC scheduling is in force, then an arriving reader will stand in line behind higher or equal priority writers (and any readers whose

priorities are higher than the arriving reader’s). Figure 16-6 illustrates two possible scenarios when a reader arrives. If writers are queued up, the question is whether readers can enter or whether they wait. If

readers can enter, writers can starve. If they wait, then a reader queue forms as well, and the next thread to acquire the lock is based on a

scheduling decision.

*Figure 16-6: Two scenarios when writers are waiting for the read-write-lock while readers are*

*“in the room” and readers arrive*

These decisions about which threads must wait when threads are

blocked on a lock can lead to unfair scheduling and even starvation. A discussion of this topic is outside of the scope of this book. Several of

the operating systems books mentioned in the bibliography examine these issues [\[37\]](index_split_014.html#p1239) [\[42\]](index_split_014.html#p1239) \[[39\]](index_split_014.html#p1239). At the very least, you should be aware that if the implementation gives arriving readers precedence over waiting

writers when a reader has the lock, then a steady stream of readers could prevent a writer from ever writing. This isn’t good.

Usually, a writer has something important to do, such as updating

data, and it should be given priority over readers. This is why the *TES*

option supports this type of scheduling and why some implementations

always give waiting writers priority over waiting readers. However, it’s also possible that a stream of writers will starve all of the readers, so if for some reason, there must be multiple writers, the code itself must

ensure that they do not starve the readers by using mutexes and

condition variables to prevent starvation.

To lock a read-write lock for reading, a thread calls

pthread_rwlock_rdlock(). Whether or not it acquires the lock is based on the rules just described. If you don’t want the thread to block in those cases where it might, the thread should call pthread_rwlock_tryrdlock() instead, which returns the error value EBUSY whenever it would block.

The pthread_rwlock_timedrdlock() function is like the

pthread_rwlock_rdlock() function, except that if the lock cannot be acquired without blocking, the wait is terminated when the specified timeout

expires. The timeout expires when the absolute time specified by the

abstime parameter passes, as measured by the real time clock

(CLOCK_REALTIME), or if the absolute time specified by abstime has already been passed at the time of the call. Notice that the time specification isn’t an interval; it is absolute time (see Chapter 9). The function doesn’t fail if the lock can be acquired immediately, and the validity of the

abstime parameter isn’t checked if the lock can be acquired immediately.

The differences between pthread_rwlock_timedwrlock(), pthread_rwlock

\_tryrwlock(), and pthread_rwlock_wrlock() are analogous.

As for unlocking, there is only one function to unlock. It doesn’t

matter whether the thread holds the lock for reading or writing; it calls pthread_rwlock \_unlock() in either case.

*Further Details About Pthreads Read-Write Locks*

This section answers some more subtle, advanced questions about read-write locks in *Pthreads*.

If the calling thread already holds a read lock on the read-write

lock, another read lock can be successfully acquired by the calling

thread. If more than one read lock is successfully acquired by a

thread on a read-write lock, that thread is required to successfully

call pthread_rwlock_unlock() a matching number of times. In this sense, it’s similar to a recursive mutex.

Some implementations of *Pthreads* will allow a thread that already holds a write lock on a read-write lock to acquire another write

lock on that same lock. In these implementations, if more than one

write lock is successfully acquired by a thread on a read-write lock,

that thread is required to successfully call pthread_rwlock_unlock() a matching number of times. In other implementations, the attempt

to acquire a second write lock on that same read-write lock will

cause deadlock.

If while either of pthread_rwlock_wrlock() or pthread_rwlock_rdlock() is waiting for the shared read lock, the read-write lock is destroyed,

then the EDESTROYED error is returned.

If a signal is delivered to the thread while it’s waiting for the lock for either reading or writing, if a signal handler is registered for

this signal, it runs, and the thread resumes waiting.

If a thread terminates while holding a write lock, the attempt by

another thread to acquire a shared read or exclusive write lock will

not succeed. In this case, the attempt to acquire the lock does not

return and will deadlock. If a thread terminates while holding a

read lock, the system automatically releases the read lock.

If a thread calls pthread_rwlock_wrlock() and currently owns the read-

write lock for writing or reading, the call will either deadlock or

fail, returning the error code EDEADLK.

In an implementation in which a thread can hold multiple read and

write locks on the same read-write lock, if a thread calls pthread

\_rwlock_unlock() while holding one or more shared read locks and one or more exclusive write locks, the exclusive write locks are

unlocked first. If more than one outstanding exclusive write lock

was held by the thread, a matching number of successful calls to

pthread_rwlock_unlock() must be completed before all write locks are

unlocked. At that time, subsequent calls to pthread_rwlock_unlock() will unlock the shared read locks.

As you can see, these locks have complex semantics that can have

significant impact on the order in which threads access the shared data.

Programming with them requires care. We’ll develop an example

program that demonstrates a basic application of them.

READ-WRITE LOCKS IN THE LINUX KERNEL

The kernel doesn’t employ the locks and synchronization tools

available in user space, but it has an extensive set of locking

mechanisms that fall into three categories:

Sleeping locks Suspend the calling thread if the lock is

unavailable

CPU local locks Based on preemption and interrupt

disabling; not suitable for inter-CPU concurrency control.

Spinning locks Based on try-repeat loops and disabling

preemption

The sleeping locks include, among other types of locks, two types

of read-write locks: rw_semaphores and percpu_rw_semaphores.

An *rw_semaphore* is a multiple-reader, single-writer lock

mechanism. A *percpu_rw_semaphore* is a read-write semaphore that is optimized for locking for reading. The spinning locks include

rwlock_t, which is a multiple-reader, single-writer lock mechanism.

The kernel makes extensive use of read-write locking in areas

ranging from managing memory maps, to updating lists of processes waiting for I/O, to managing network interfaces.

*Read-Write Lock Example*

Many system resources, such as the system time or the password

database, are modified only occasionally but read from very frequently.

When a thread has to modify the resource, it has to do so exclusively

because the changes can involve several nonatomic operations. For

instance, when the Linux kernel needs to add or remove a process from

a linked list, there’s a window of time during which the pointers have been changed but don’t yet point to valid locations. A thread that tries to traverse this list during the update would dereference an invalid

pointer. As another example, *glibc* supports message catalogs that allow applications to display messages in the language of a user’s locale. A thread or process that needs to update a message in the catalog might

have to change several lines of text. If another thread reads that message translation in the midst of an update, it will receive a corrupted

translation or, even worse, an invalid memory address.

Because we can’t, or shouldn’t, modify actual system databases, our

program simulates an update to a user dataset instead. The program

creates a few kinds of threads: reader threads, writer threads, a signal-handling thread, and, if enabled, a monitor thread. The program

requirements include the following:

The dataset consists of an array of short strings of fixed maximum

length, read from a file specified on the command line.

To simplify the program, the only way to terminate all threads is by

entering a terminating key combination such as CTRL-C or by

sending a terminating signal such as SIGTERM.

The number of reader threads is independent of the number of

writer threads, but there should be more readers than writers.

A writer thread changes one or more data strings in a single write

operation.

Each reader thread is assigned a range of lines in the data array that it reads.

A writer thread doesn’t write output on the terminal, but when it

modifies the array, it will attach its unique, program-based ID and

the time of modification to the modified lines as a form of audit.

A reader thread reads its assigned entries from the array and writes

them, along with their metadata, to its standard output.

A writer thread will only write periodically, at fixed time intervals, sleeping in between write operations.

This last requirement will allow us to measure the performance of our

program, because writers will wake up at fixed intervals and try to

acquire the read-write lock immediately. If we use a high-precision

timer to schedule their wake-ups, then we can compare the timestamp

in the dataset to the time that the timer expired. The difference in time is the delay caused by being locked out. Our solution should keep this time as small as possible.

The challenge in using read-write locks is preventing starvation of

both readers and writers. It would be a simple design if it didn’t prevent starvation. Fortunately, *glibc* provides a nonportable extension to the *Pthreads* library, the pthread_rwlockattr_setkind_np() function, that lets a program modify the lock attributes to prevent writer starvation,

provided that no reader acquires the lock recursively. However, if the number of writers is too large, readers can starve, so the key is to enable this feature only when the number of writers is not too large. The man page has all of the details.

To give all threads a fair chance at the lock, the program should be

designed like a horse race—no thread can start until they’re all in the figurative starting gate. Therefore, it will use a synchronization barrier at the start of each reader and writer start function to ensure that no thread enters its main loop until all threads have at least been created.

Without the barrier, the threads that are created first in the main

program will always get the lock first, and if these are writers, the

readers might starve.

Writing this program has two purposes. One is to get some practice using the read-write lock. The other is to create a tool to explore the effects of the numbers of readers and writers and preferences on access to the critical section of code. To this end, it has a few ancillary features: It will have command line options to specify the number of readers

(-r *nreaders*), the number of writers (-w *nwriters*), the number of nanoseconds that readers spend outside of their reading code

section (-s *nanosecs*), and whether or not to give writers starvation prevention (-R turns it off).

It creates a logfile named *rwlockdemo.log* in the current working directory. Every time any thread acquires or releases a lock, it

writes to that file.

When a writer writes its ID into the data array, it negates it. This

way, writer entries are easy to recognize because their IDs on

output are negative numbers.

When a reader process reads an entry, it will write that entry to

standard output, preceded by its program ID. Sample output could

be:

Read by 7: -9

2670.176026554 \[ 116\] spruce

In this output, 7 is the reader’s ID, 9 is the ID of the writer who last modified line 116 in the dataset, and the timestamp in seconds is

2670.176026554. The string spruce is the actual data.

Setting the compile time symbol MONITOR will add code to the

executable that writes additional information about the lock to the

logfile.

We’ll look at various fragments of the program, named

*pthread_rwlock \_demo.c*, which is available in the book’s source code distribution in its entirety. To save space here, some code won’t be

displayed. Let’s start with the global types, constants, and variable

declarations:

\#define NUM_READERS 8 /\* Default number of readers \*/

\#define NUM_WRITERS 2 /\* Default number of writers \*/

\#define LINESIZE 64 /\* Maximum length of string \*/

\#define MAX_ARRAYSIZE 1024 /\* Maximum array size \*/

/\* The data structure representing a single item in the shared array \*/

typedef struct \_data {

int wrid; /\* Writer ID, negated \*/

struct timespec wrtime; /\* Time of last modification \*/

char text\[LINESIZE\]; /\* Actual text data \*/

} item;

typedef struct \_task_data

{

int first; /\* Index of first element for thread \*/

int last; /\* Index of last element for thread \*/

int task_id; /\* Thread's program ID \*/

int num_threads; /\* Total number of threads \*/

item \*data; /\* Pointer to array of data \*/

} reader_task_data; /\* Only readers need this structure. \*/

item \*shared_data; /\* Dynamically-allocated data array \*/

int arraysize; /\* Actual size of the array \*/

pthread_rwlock_t rwlock; /\* The reader/writer lock \*/

pthread_barrier_t barrier; /\* Barrier to improve fairness \*/

FILE \*logfp; /\* FILE stream for logfile \*/

int rdrsleep_ns = 200000; /\* Nanosecs in reader delay time \*/

\#ifdef MONITOR pthread_mutex_t counter_mutex; /\* Used by the monitor code \*/

int num_threads_in_lock; /\* For the monitor code \*/

\#endif

Although I included the conditionally compiled monitor variable

declarations here, I won’t show the monitor code in the next few

listings.

The readers execute the start function shown in Listing 16-13.

reader()

void \*reader(void \*data)

{

int retval;

reader_task_data \*t_data = (reader_task_data\*) data;

int t = t_data-\>task_id;

struct timespec sleeptime = {0,rdrsleep_ns};

struct timespec rem = sleeptime;

retval = pthread_barrier_wait(&barrier); /\* Wait for all threads. \*/

if ( PTHREAD_BARRIER_SERIAL_THREAD != retval && 0 != retval )

fatal_error(retval, "pthread_barrier_wait");


➊ if ( 0 != (retval = pthread_rwlock_rdlock(&rwlock)) )

fatal_error( retval, "pthread_rwlock_rdlock");

// OMITTED: Lock print mutex (if you want all lines together).

for ( int k = t_data-\>first; k \<= t_data-\>last; k++ )

printf("Read by %2d: %3d\t%6lu.%-12lu \[%4d\] %s", t,

t_data-\>data\[k\].wrid,

t_data-\>data\[k\].wrtime.tv_sec,

t_data-\>data\[k\].wrtime.tv_nsec,

k,

t_data-\>data\[k\].text);

fflush(stdout);

// OMITTED: Unlock print mutex (if it was locked before the loop).

fprintf(logfp, "Reader %d got the read lock\n", t);

fflush(logfp);

➋ if ( 0 != (retval = pthread_rwlock_unlock(&rwlock)) )

fatal_error( retval, "pthread_rwlock_unlock");

fprintf(logfp, "Reader %d released the read lock\n", t);

fflush(logfp);

nanosleep(&sleeptime, &rem);

}


}

*Listing 16-13: The start function executed by all reader threads*

Most of the loop is enclosed in the calls to lock the read-write lock for reading ➊ and unlock it ➋ .

If we wanted all of a reader’s output to be printed together, we could enclose the print loop with mutex locking. The printf() function is

thread-safe—it locks the output stream until it returns—so that the

output lines will be preserved intact. As written, the output lines from different reader threads may be intermingled, but since each line shows which reader wrote it, it doesn’t matter.

Let’s look at the writer start function, which is shown in Listing 16-

14.

writer()

void \*writer(void \*data)

{

int retval; /\* Return values from function calls \*/

int t = (int) (long) data; /\* Thread's program ID \*/

struct timespec dt = {1,0}; /\* Sleep time for clock_nanosleep \*/

struct timespec curtime; /\* Time of modification \*/

retval = pthread_barrier_wait(&barrier); /\* Wait for all threads. \*/

if ( PTHREAD_BARRIER_SERIAL_THREAD != retval && 0 != retval )

fatal_error(retval, "pthread_barrier_wait");


➊ if ( 0 != (retval = pthread_rwlock_wrlock(&rwlock)) )

fatal_error(retval, "pthread_rwlock_wrlock");

➋ clock_gettime(CLOCK_MONOTONIC, &curtime);

for ( int i = 0; i \< arraysize; i++ ) {

➌ if ( random() \> RAND_MAX/2 ) {

shared_data\[i\].wrid = -t;

shared_data\[i\].wrtime = curtime;

}

}

fprintf(logfp, "Writer %d got the write lock\n", t);

fflush(logfp);

if ( 0 != (retval = pthread_rwlock_unlock(&rwlock)) )

fatal_error(retval, "pthread_rwlock_unlock");

fprintf(logfp, "Writer %d released the write lock\n", t);

fflush(logfp);

clock_nanosleep(CLOCK_MONOTONIC, 0, &dt, NULL);

}


}

*Listing 16-14: The start function executed by all writer threads*

The writer threads also wait at the barrier before entering their loop.

Inside the loop, they immediately try to acquire a write lock on the

read-write lock ➊. As soon as they acquire it, they get the current time ➋ and make a pass across the entire array, modifying a random number

➌ of entries. On average, each writer will modify half of the entries each time it writes.

Writers don’t actually modify the text string. It isn’t necessary for

this program. Besides, not modifying it makes it easier to do a bit of post-mortem analysis in the output file. They add their negated ID to

the entry and modify its timestamp.

After they release the lock, they sleep for 1 second. If they acquire

the lock immediately after waking up, the next modifications will be

close to one second after the preceding ones. If a writer is delayed, the timestamps will show how much it was delayed. By greping through the

output, we can see the lines that each thread modified and the times it did so.

The main program calls an auxiliary function, load_data(), to load the lines from a text file into the array. That function, shown in Listing 16-

15, ensures that lines are limited to the maximum allowed size, truncating them if necessary, and that the array length is not exceeded.

load_data()

int load_data(char \*pathname, int maxsize, item \*array)

{

FILE \*fp;

int i = 0;

char \*buffer = NULL;

size_t len = 0;

if ( (fp = fopen(pathname, "r")) == NULL ) fatal_error(errno, "fopen");

while ( (i \< maxsize) && (-1 != getline(&buffer, &len, fp)) ) {

if ( len \< LINESIZE )

strncpy(array\[i\].text, buffer, len);

else {

strncpy(array\[i\].text, buffer, LINESIZE - 1);

array\[i\].text\[LINESIZE-1\] = '\0';

}

array\[i\].wrid = 0;

array\[i\].wrtime.tv_sec = 0;

array\[i\].wrtime.tv_nsec = 0;

i++;

}

free(buffer);

return i;

}

*Listing 16-15: The function that loads the data from a text file into the array shared by the* *readers and writers*

The last piece is the main program. Excerpts of it are displayed in

Listing 16-16. Some code has been removed, as indicated in the listing, and some error handling has been omitted as well.

*pthread_rwlock_demo.c* main()

int main(int argc, char \*argv\[\])

{

int retval;

int nreaders = NUM_READERS;

int nwriters = NUM_WRITERS;

long int t; unsigned int num_threads;

pthread_t \*threads;

pthread_t sig_thread; /\* Thread ID for signal-handling thread \*/

sigset_t mask; /\* Signal mask of blocked signals \*/

pthread_attr_t attr; /\* Attribute structure for threads \*/

reader_task_data \*thread_data;

BOOL reader_preference = FALSE;

char ch;

// OMITTED: Option-parsing, usage handling, blocking asynchronous signals

/\* Set the attribute structure to create a detached thread. \*/

pthread_attr_init(&attr);

pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);

pthread_attr_setstacksize (&attr, 65536);

/\* Create one thread to handle asynchronous terminating signals. \*/

pthread_create(&sig_thread, &attr, sighandler, (void\*) &mask); pthread_rwlockattr_t rwlock_attributes;

pthread_rwlockattr_init(&rwlock_attributes);

/\* The following nonportable function alters thread priorities when

readers and writers are both waiting on a rwlock. \*/

➊ if ( nwriters \> 1 ) {

if ( reader_preference ) /\* By default, this is FALSE. \*/

pthread_rwlockattr_setkind_np(&rwlock_attributes,

PTHREAD_RWLOCK_PREFER_READER_NP);

else

pthread_rwlockattr_setkind_np(&rwlock_attributes,

PTHREAD_RWLOCK_PREFER_WRITER_NONRECURSIVE_NP);

}

pthread_rwlock_init(&rwlock, &rwlock_attributes);

num_threads = nreaders + nwriters;

arraysize = MAX_ARRAYSIZE;

/\* Allocate memory for shared array and read data from file into it. \*/

if ( NULL == (shared_data = (item\*) calloc(arraysize, sizeof(item))) ) fatal_error(errno, "calloc");

arraysize = load_data(argv\[optind\], arraysize, shared_data);

logfp = fopen("rwlockdemo.log", "w");

thread_data = calloc(nreaders, sizeof(reader_task_data));

threads = calloc(num_threads, sizeof(pthread_t));

/\* Initialize the barrier. \*/

if ( 0 != (retval = pthread_barrier_init(&barrier, NULL, num_threads)) )

fatal_error(retval, "pthread_barrier_init"); for ( t = 0; t \< nreaders; t++ ) { /\* Set up task data for readers. \*/

thread_data\[t\].first = (t \* arraysize)/nreaders;

thread_data\[t\].last = ((t + 1) \* arraysize)/nreaders - 1;

thread_data\[t\].task_id = t;

thread_data\[t\].num_threads = nreaders;

thread_data\[t\].data = shared_data;

}

for ( t = 0; t \< nreaders; t++ ) /\* Create and run readers. \*/

pthread_create(&threads\[t\], &attr, reader, &thread_data\[t\]); for ( t = nreaders ; t \< num_threads; t++ ) /\* Create and run writers. \*/

pthread_create(&threads\[t\], NULL, writer, (void\*) t);

for ( t = 0; t \< num_threads; t++ ) /\* Join all threads. \*/

pthread_join(threads\[t\], NULL);

exit(EXIT_SUCCESS);

}

*Listing 16-16: The main program for* pthread_rwlock_demo.c

The main() function basically sets everything up for its threads. The

signal handling thread is run to wait for asynchronous terminating

signals and clean up if any are delivered. If the user didn’t provide the -R

option for the run ➊, reader_preference is turned off and the attribute structure for the read-write lock will be given the

PTHREAD_RWLOCK_PREFER_WRITER_NONRECURSIVE_NP attribute, which prevents writer starvation. The reader threads are created first. The writer threads are created in the second loop and given IDs with the integers starting with nreaders, up to num_threads - 1.

The program design lets us run it with changing numbers of reader

and writer threads. The expected usage is:

**./pthread_rwlock_demo \[-r *nreaders*** **-w *nwriters*** **-s *readersleep*** **-R\] *datafile***

It’s best to redirect standard output into a file when we run the

program. This way, we can analyze the file to see whether writers were

able to perform their updates without much delay. The logfile will show the order in which each thread acquired and released the lock. I’ll run the program with an input file consisting of the names of trees found in public places on the streets of New York City, which is part of an open dataset. It has 133 names:

\$ **./pthread_rwlock_demo -r12 -w3 treenames \> run1**

**^C**

Looking at the contents of *run1*, we’ll see lines like the following: Read by 2: 0 0.0 \[ 32\] cockspur hawthorn

Read by 1: 0 0.0 \[ 20\] black pine

Read by 1: 0 0.0 \[ 21\] black walnut

Read by 9: -14 3765.998855807 \[ 99\] sawtooth oak

Read by 7: -13 3765.998929951 \[ 77\] northern red oak

Read by 9: -13 3765.998929951 \[ 100\] scarlet oak

Read by 7: -14 3765.998855807 \[ 78\] Norway maple

Read by 10: -14 3765.998855807 \[ 110\] silver maple

This shows that initially some readers read entries not yet modified (the metadata is zeros) but that different readers start to read modified

entries. The -13 and -14 indicate that writers 13 and 14 modified these entries. If we search for all lines containing scarlet oak, as in

\$ **grep 'scarlet oak' run1**

Read by 9: -13 3765.998929951 \[ 100\] scarlet oak

Read by 9: -13 3766.999128456 \[ 100\] scarlet oak

Read by 9: -13 3767.999340177 \[ 100\] scarlet oak

Read by 9: -12 3768.999343937 \[ 100\] scarlet oak

Read by 9: -12 3769.999540417 \[ 100\] scarlet oak

*--snip--*

we see that reader 9 always reads this entry and that two different

writers modified it. The writes take place a little more than one second apart. The difference is on the order of 0.2 milliseconds, which is partly caused by the writers not acquiring the lock immediately.

The *rwlockdemo.log* file contains lines such as

Reader 4 got the read lock

Reader 4 released the read lock

Reader 3 got the read lock

Reader 3 released the read lock

Writer 13 got the write lock

Writer 13 released the write lock

Writer 12 got the write lock

Writer 12 released the write lock

Writer 14 got the write lock

Writer 14 released the write lock

Reader 8 got the read lock

*--snip--*

showing the order in which the threads accessed the file. This can be

used to corroborate the output.

Summary

This chapter explored an assortment of programming tools provided by

the *Pthreads* API for synchronizing threads and preventing race conditions.

A mutex is essentially a binary software lock. One thread at a time

can lock it, and only that thread can unlock it. When multiple threads try to lock it at the same time, all but one is blocked until it is unlocked.

A condition variable is a more complex object. The intended purpose of it is for a thread that has acquired a mutex but can’t continue because some condition is false to atomically release the mutex and put itself on a queue of threads blocked on that variable. Another thread can signal the condition variable to indicate that the condition is true, and a single thread is then removed from its queue and can proceed.

A synchronization barrier is a function that programs can use to

prevent any thread from advancing until all threads are at the barrier, like the gate at the start of a race. We looked at read-write locks as well.

These can be held by multiple readers at a time, but if a writer wants to lock it, no other thread can lock it until the writer releases it. These

locks are a challenge to use because it’s not hard for some programs to cause all readers to starve or cause all writers to starve.

The chapter did not cover all possible *Pthreads* functions and

synchronization tools. It omitted an exploration of spin-locks, real-time threads, and thread scheduling. It did not cover thread keys and thread-specific data. The man pages and the POSIX specification have more

details about these topics.

Exercises

1\. Modify *vmem_usage.c* so that it can report on the total of other process statistics besides virtual memory size. Specifically, it should accept the following command line options and associated

meanings:

**-u** Total user mode CPU time

**-k** Total kernel mode time

**-r** Total of resident set sizes as a number of pages

Without options, it reports on virtual memory size. If more than

one option is present, it reports on each, one metric per line, in any order, with a label indicating the metric, such as User mode CPU time:.

2\. Modify the function get_all_vmsizes() in *vmem_usage.c* so that it creates multiple threads to construct the array of per-process

virtual memory sizes. It should pick a number of threads no greater

than the minimum of the number of processors and the number of

active processes. Read the man page for get_nprocs(3) and/or

sysconf() to learn how to get the processor count.

3\. A *thread-shared semaphore* is one that can be used only by the threads of the same multithreaded program. Implement a thread-shared semaphore using nothing but *Pthreads* mutexes and

condition variables. A program must make such a semaphore

accessible to all threads by making it a global variable or putting it on the heap. Use the following structure definition:

typedef struct {

pthread_mutex_t lock;

pthread_cond_t cond;

int value; /\* Semaphore value (\>= 0) \*/

BOOL avail; /\* True if initialized and not destroyed \*/

} \_sem_t;

\(a\) Write implementations of the following semaphore

operations that act on objects of type \_sem_t:

/\* sem_init() initializes \*sem with initial value and makes it

available. \*/

void sem_init(\_sem_t \*sem, int init_value);

/\* sem_destroy() releases \*sem resources, making \*sem

unavailable. \*/

void sem_destroy(\_sem_t \*sem);

/\* sem_wait() implements a semaphore wait() on \*sem.

Returns 0 on success, else nonzero. \*/

int sem_wait(\_sem_t \*sem);

/\* sem_post() implements a semaphore post() on \*sem.

Returns 0 on success, else nonzero. \*/

int sem_post(\_sem_t \*sem);

Your solution does not have to guarantee any particular

scheduling of threads that are woken up by a post

operation, and it does not have to handle the possibility of

threads being cancelled during a semaphore operation.

\(b\) Modify *pthread_prodcons.c*, the multithreaded producer-

consumer program from this chapter, so that it uses your

semaphore operations instead of mutexes and condition

variables.

4\. Is there a set of command line options for the pthread_rwlock_demo

program that will starve readers or starve writers? Try changing

the numbers of readers and writers to see if you can cause either

class to starve or perhaps “near starve,” where the threads of that class almost never acquire the lock. Try changing the time that

readers sleep (with the -s option). With a fixed number of readers

and writers, is there a threshold value for the reader sleep time

below which writers starve? You can analyze the logfile with tools

such as grep and wc to determine with ease how often both readers

and writers acquired the lock.

5\. The Linux kernel has a reader-writer consistency mechanism of

type seqcount_t with lockless readers (read-only retry loops) and no

writer starvation. It’s intended to protect updates to rarely updated

data like the system clock. It is designed for a single writer and

multiple readers. The idea is simple in principle: The sequence

counter is either even or odd at any time. Initially it is 0. When the writer wants to write, it adds 1, writes, and subtracts 1. When a

reader wants to read, it repeatedly loops, checking whether the

counter is even or odd. It reads only when the counter is even. If

the sequence count has changed between the start and the end of

the read, the reader must retry. You can read more about it in the

kernel documentation, in the repository file

*Documentation/locking/seqlock.rst*.

Write a small program with a number of reader threads and a

single writer that uses this method to allow the readers to read an

integer variable that gets updated by the writer at random times.

![](/tmp/audit/iter1/epubregen/system-programming-in-linux/media/index-1032_1.jpg)