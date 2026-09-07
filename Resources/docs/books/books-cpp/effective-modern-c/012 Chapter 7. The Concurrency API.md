**CHAPTER 7**

**The Concurrency API**

One of C++11’s great triumphs is the incorporation of concurrency into the language and library. Programmers familiar with other threading APIs (e.g., pthreads or Windows threads) are sometimes surprised at the comparatively Spartan feature set that C++ offers, but that’s because a great deal of C++’s support for concurrency is in the form of constraints on compiler-writers. The resulting language assurances mean that for the first time in C++’s history, programmers can write multithreaded programs with standard behavior across all platforms. This establishes a solid foundation on which expressive libraries can be built, and the concurrency elements of the Standard Library (tasks, futures, threads, mutexes, condition variables, atomic objects, and more) are merely the beginning of what is sure to become an increasingly rich set of tools for the development of concurrent C++ software.

In the Items that follow, bear in mind that the Standard Library has two templates for futures: std::future and std::shared_future. In many cases, the distinction is not important, so I often simply talk about *futures*, by which I mean both kinds.

**Item 35: Prefer task-based programming to thread-**

**based.**

If you want to run a function doAsyncWork asynchronously, you have two basic choices. You can create a std::thread and run doAsyncWork on it, thus employing a *thread-based* approach:

int doAsyncWork();

**std::thread** t(doAsyncWork);

Or you can pass doAsyncWork to std::async, a strategy known as *task-based*: **241**

auto fut = **std::async**(doAsyncWork); // "fut" for "future"

In such calls, the function object passed to std::async (e.g., doAsyncWork) is considered a *task*.

The task-based approach is typically superior to its thread-based counterpart, and the tiny amount of code we’ve seen already demonstrates some reasons why. Here, doAsyncWork produces a return value, which we can reasonably assume the code invoking doAsyncWork is interested in. With the thread-based invocation, there’s no straightforward way to get access to it. With the task-based approach, it’s easy, because the future returned from std::async offers the get function. The get function is even more important if doAsyncWork emits an exception, because get provides access to that, too. With the thread-based approach, if doAsyncWork throws, the program dies (via a call to std::terminate).

A more fundamental difference between thread-based and task-based programming is the higher level of abstraction that task-based embodies. It frees you from the details of thread management, an observation that reminds me that I need to summarize the three meanings of “thread” in concurrent C++ software:

• *Hardware threads* are the threads that actually perform computation. Contemporary machine architectures offer one or more hardware threads per CPU core.

• *Software threads* (also known as *OS threads* or *system threads*) are the threads that the operating system1 manages across all processes and schedules for execution on hardware threads. It’s typically possible to create more software threads than hardware threads, because when a software thread is blocked (e.g., on I/O or waiting for a mutex or condition variable), throughput can be improved by executing other, unblocked, threads.

• *std::threads* are objects in a C++ process that act as handles to underlying software threads. Some std::thread objects represent “null” handles, i.e., correspond to no software thread, because they’re in a default-constructed state (hence have no function to execute), have been moved from (the moved-to std::thread then acts as the handle to the underlying software thread), have been joined (the function they were to run has finished), or have been detached (the connection between them and their underlying software thread has been severed).

Software threads are a limited resource. If you try to create more than the system can provide, a std::system_error exception is thrown. This is true even if the function you want to run can’t throw. For example, even if doAsyncWork is noexcept, 1 Assuming you have one. Some embedded systems don’t.


int doAsyncWork() **noexcept**; // see Item 14 for noexcept this statement could result in an exception:

std::thread t(doAsyncWork); // throws if no more

// threads are available

Well-written software must somehow deal with this possibility, but how? One approach is to run doAsyncWork on the current thread, but that could lead to unbalanced loads and, if the current thread is a GUI thread, responsiveness issues. Another option is to wait for some existing software threads to complete and then try to create a new std::thread again, but it’s possible that the existing threads are waiting for an action that doAsyncWork is supposed to perform (e.g., produce a result or notify a condition variable).

Even if you don’t run out of threads, you can have trouble with *oversubscription*.

That’s when there are more ready-to-run (i.e., unblocked) software threads than hardware threads. When that happens, the thread scheduler (typically part of the OS) time-slices the software threads on the hardware. When one thread’s time-slice is finished and another’s begins, a context switch is performed. Such context switches increase the overall thread management overhead of the system, and they can be particularly costly when the hardware thread on which a software thread is scheduled is on a different core than was the case for the software thread during its last time-slice.

In that case, (1) the CPU caches are typically cold for that software thread (i.e., they contain little data and few instructions useful to it) and (2) the running of the “new”

software thread on that core “pollutes” the CPU caches for “old” threads that had been running on that core and are likely to be scheduled to run there again.

Avoiding oversubscription is difficult, because the optimal ratio of software to hardware threads depends on how often the software threads are runnable, and that can change dynamically, e.g., when a program goes from an I/O-heavy region to a computation-heavy region. The best ratio of software to hardware threads is also dependent on the cost of context switches and how effectively the software threads use the CPU caches. Furthermore, the number of hardware threads and the details of the CPU caches (e.g., how large they are and their relative speeds) depend on the machine architecture, so even if you tune your application to avoid oversubscription (while still keeping the hardware busy) on one platform, there’s no guarantee that your solution will work well on other kinds of machines.

Your life will be easier if you dump these problems on somebody else, and using std::async does exactly that:

auto fut = **std::async**(doAsyncWork); // onus of thread mgmt is

// on implementer of

// the Standard Library


This call shifts the thread management responsibility to the implementer of the C++

Standard Library. For example, the likelihood of receiving an out-of-threads exception is significantly reduced, because this call will probably never yield one. “How can that be?” you might wonder. “If I ask for more software threads than the system can provide, why does it matter whether I do it by creating std::threads or by calling std::async?” It matters, because std::async, when called in this form (i.e., with the default launch policy—see Item 36), doesn’t guarantee that it will create a new software thread. Rather, it permits the scheduler to arrange for the specified function (in this example, doAsyncWork) to be run on the thread requesting doAsyncWork’s result (i.e., on the thread calling get or wait on fut), and reasonable schedulers take advantage of that freedom if the system is oversubscribed or is out of threads.

If you pulled this “run it on the thread needing the result” trick yourself, I remarked that it could lead to load-balancing issues, and those issues don’t go away simply because it’s std::async and the runtime scheduler that confront them instead of you. When it comes to load balancing, however, the runtime scheduler is likely to have a more comprehensive picture of what’s happening on the machine than you do, because it manages the threads from all processes, not just the one your code is running in.

With std::async, responsiveness on a GUI thread can still be problematic, because the scheduler has no way of knowing which of your threads has tight responsiveness requirements. In that case, you’ll want to pass the std::launch::async launch policy to std::async. That will ensure that the function you want to run really executes on a different thread (see Item 36).

State-of-the-art thread schedulers employ system-wide thread pools to avoid oversubscription, and they improve load balancing across hardware cores through work-stealing algorithms. The C++ Standard does not require the use of thread pools or work-stealing, and, to be honest, there are some technical aspects of the C++11 concurrency specification that make it more difficult to employ them than we’d like.

Nevertheless, some vendors take advantage of this technology in their Standard Library implementations, and it’s reasonable to expect that progress will continue in this area. If you take a task-based approach to your concurrent programming, you automatically reap the benefits of such technology as it becomes more widespread. If, on the other hand, you program directly with std::threads, you assume the burden of dealing with thread exhaustion, oversubscription, and load balancing yourself, not to mention how your solutions to these problems mesh with the solutions implemented in programs running in other processes on the same machine.

Compared to thread-based programming, a task-based design spares you the travails of manual thread management, and it provides a natural way to examine the results of asynchronously executed functions (i.e., return values or exceptions). Nevertheless, there are some situations where using threads directly may be appropriate. They include:

• **You need access to the API of the underlying threading implementation**. The C++ concurrency API is typically implemented using a lower-level platform-specific API, usually pthreads or Windows’ Threads. Those APIs are currently richer than what C++ offers. (For example, C++ has no notion of thread priorities or affinities.) To provide access to the API of the underlying threading implementation, std::thread objects typically offer the native_handle member function. There is no counterpart to this functionality for std::futures (i.e., for what std::async returns).

• **You need to and are able to optimize thread usage for your application**. This could be the case, for example, if you’re developing server software with a known execution profile that will be deployed as the only significant process on a machine with fixed hardware characteristics.

• **You need to implement threading technology beyond the C++ concurrency** **API**, e.g., thread pools on platforms where your C++ implementations don’t offer them.

These are uncommon cases, however. Most of the time, you should choose task-based designs instead of programming with threads.

**Things to Remember**

• The std::thread API offers no direct way to get return values from asynchronously run functions, and if those functions throw, the program is terminated.

• Thread-based programming calls for manual management of thread exhaustion, oversubscription, load balancing, and adaptation to new platforms.

• Task-based programming via std::async with the default launch policy handles most of these issues for you.

**Item 36: Specify std::launch::async if**

**asynchronicity is essential.**

When you call std::async to execute a function (or other callable object), you’re generally intending to run the function asynchronously. But that’s not necessarily what you’re asking std::async to do. You’re really requesting that the function be run in accord with a std::async *launch policy*. There are two standard policies, each

represented by an enumerator in the std::launch scoped enum. (See Item 10 for information on scoped enums.) Assuming a function f is passed to std::async for execution,

• **The std::launch::async launch policy** means that f must be run asynchronously, i.e., on a different thread.

• **The std::launch::deferred launch policy** means that f may run only when get or wait is called on the future returned by std::async.2 That is, f’s execution is *deferred* until such a call is made. When get or wait is invoked, f will execute synchronously, i.e., the caller will block until f finishes running. If neither get nor wait is called, f will never run.

Perhaps surprisingly, std::async’s default launch policy—the one it uses if you don’t expressly specify one—is neither of these. Rather, it’s these or-ed together. The following two calls have exactly the same meaning:

auto fut1 = std::async(f); // run f using

// default launch

// policy

auto fut2 = std::async(**std::launch::async \|** // run f either

**std::launch::deferred**, // async or

f); // deferred

The default policy thus permits f to be run either asynchronously or synchronously.

As Item 35 points out, this flexibility permits std::async and the thread-management components of the Standard Library to assume responsibility for thread creation and destruction, avoidance of oversubscription, and load balancing. That’s among the things that make concurrent programming with std::async so convenient.

But using std::async with the default launch policy has some interesting implications. Given a thread t executing this statement,

auto fut = std::async(f); // run f using default launch policy

2 This is a simplification. What matters isn’t the future on which get or wait is invoked, it’s the shared state to which the future refers. (Item 38 discusses the relationship between futures and shared states.) Because std::futures support moving and can also be used to construct std::shared_futures, and because std::shared_futures can be copied, the future object referring to the shared state arising from the call to std::async to which f was passed is likely to be different from the one returned by std::async. That’s a mouthful, however, so it’s common to fudge the truth and simply talk about invoking get or wait on the future returned from std::async.


• **It’s not possible to predict whether f will run concurrently with t**, because f might be scheduled to run deferred.

• **It’s not possible to predict whether f runs on a thread different from the** **thread invoking get or wait on fut.** If that thread is t, the implication is that it’s not possible to predict whether f runs on a thread different from t.

• **It may not be possible to predict whether f runs at all**, because it may not be possible to guarantee that get or wait will be called on fut along every path through the program.

The default launch policy’s scheduling flexibility often mixes poorly with the use of thread_local variables, because it means that if f reads or writes such *thread-local* *storage* (TLS), it’s not possible to predict which thread’s variables will be accessed: auto fut = std::async(f); // TLS for f *possibly* for

// independent thread, but

// *possibly* for thread

// invoking get or wait on fut

It also affects wait-based loops using timeouts, because calling wait_for or wait_until on a task (see Item 35) that’s deferred yields the value

std::launch::deferred. This means that the following loop, which looks like it should eventually terminate, may, in reality, run forever:

using namespace std::literals; // for C++14 duration

// suffixes; see Item 34

void f() // f sleeps for 1 second,

{ // then returns

std::this_thread::sleep_for(1s);

}

auto fut = std::async(f); // run f asynchronously

// ( *conceptually*)

while (fut. **wait_for**(100ms) != // loop until f has

**std::future_status::ready**) // finished running...

{ // *which may never happen!*

…

}


If f runs concurrently with the thread calling std::async (i.e., if the launch policy chosen for f is std::launch::async), there’s no problem here (assuming f eventually finishes), but if f is deferred, fut.wait_for will always return std:: future_status::deferred. That will never be equal to std::future_status:: ready, so the loop will never terminate.

This kind of bug is easy to overlook during development and unit testing, because it may manifest itself only under heavy loads. Those are the conditions that push the machine towards oversubscription or thread exhaustion, and that’s when a task may be most likely to be deferred. After all, if the hardware isn’t threatened by oversubscription or thread exhaustion, there’s no reason for the runtime system not to schedule the task for concurrent execution.

The fix is simple: just check the future corresponding to the std::async call to see whether the task is deferred, and, if so, avoid entering the timeout-based loop.

Unfortunately, there’s no direct way to ask a future whether its task is deferred.

Instead, you have to call a timeout-based function—a function such as wait_for. In this case, you don’t really want to wait for anything, you just want to see if the return value is std::future_status::deferred, so stifle your mild disbelief at the necessary circumlocution and call wait_for with a zero timeout:

auto fut = std::async(f); // as above

**if (fut.wait_for(0s) ==** // if task is

**std::future_status::deferred)** // deferred...

**{**

// ...use wait or get on fut

… // to call f synchronously

**} else {** // task isn't deferred

while (fut.wait_for(100ms) != // infinite loop not

std::future_status::ready) { // possible (assuming

// f finishes)

… // task is neither deferred nor ready,

// so do concurrent work until it's ready

}

… // fut is ready

**}**


The upshot of these various considerations is that using std::async with the default launch policy for a task is fine as long as the following conditions are fulfilled:

• The task need not run concurrently with the thread calling get or wait.

• It doesn’t matter which thread’s thread_local variables are read or written.

• Either there’s a guarantee that get or wait will be called on the future returned by std::async or it’s acceptable that the task may never execute.

• Code using wait_for or wait_until takes the possibility of deferred status into account.

If any of these conditions fails to hold, you probably want to guarantee that std::async will schedule the task for truly asynchronous execution. The way to do that is to pass std::launch::async as the first argument when you make the call: auto fut = std::async(**std::launch::async**, f); // launch f

// asynchronously

In fact, having a function that acts like std::async, but that automatically uses std::launch::async as the launch policy, is a convenient tool to have around, so it’s nice that it’s easy to write. Here’s the C++11 version:

template\<typename F, typename... Ts\>

inline

std::future\<typename std::result_of\<F(Ts...)\>::type\>

**reallyAsync**(F&& f, Ts&&... params) // return future

{ // for asynchronous

return std::async(**std::launch::async**, // call to f(params...)

std::forward\<F\>(f),

std::forward\<Ts\>(params)...);

}

This function receives a callable object f and zero or more parameters params and perfect-forwards them (see Item 25) to std::async, passing std::launch::async as the launch policy. Like std::async, it returns a std::future for the result of invoking f on params. Determining the type of that result is easy, because the type trait std::result_of gives it to you. (See Item 9 for general information on type traits.)

reallyAsync is used just like std::async:

auto fut = **reallyAsync**(f); // run f asynchronously;

// throw if std::async

// would throw


In C++14, the ability to deduce reallyAsync’s return type streamlines the function declaration:

template\<typename F, typename... Ts\>

inline

**auto** // C++14

reallyAsync(F&& f, Ts&&... params)

{

return std::async(std::launch::async,

std::forward\<F\>(f),

std::forward\<Ts\>(params)...);

}

This version makes it crystal clear that reallyAsync does nothing but invoke std::async with the std::launch::async launch policy.

**Things to Remember**

• The default launch policy for std::async permits both asynchronous and synchronous task execution.

• This flexibility leads to uncertainty when accessing thread_locals, implies that the task may never execute, and affects program logic for timeout-based wait calls.

• Specify std::launch::async if asynchronous task execution is essential.

**Item 37: Make std::threads unjoinable on all paths.**

Every std::thread object is in one of two states: *joinable* or *unjoinable*. A joinable std::thread corresponds to an underlying asynchronous thread of execution that is or could be running. A std::thread corresponding to an underlying thread that’s blocked or waiting to be scheduled is joinable, for example. std::thread objects corresponding to underlying threads that have run to completion are also considered joinable.

An unjoinable std::thread is what you’d expect: a std::thread that’s not joinable.

Unjoinable std::thread objects include:

• **Default-constructed std::threads**. Such std::threads have no function to execute, hence don’t correspond to an underlying thread of execution.


• **std::thread objects that have been moved from**. The result of a move is that the underlying thread of execution a std::thread used to correspond to (if any) now corresponds to a different std::thread.

• **std::threads that have been joined**. After a join, the std::thread object no longer corresponds to the underlying thread of execution that has finished running.

• **std::threads that have been detached**. A detach severs the connection between a std::thread object and the underlying thread of execution it corresponds to.

One reason a std::thread’s joinability is important is that if the destructor for a joinable thread is invoked, execution of the program is terminated. For example, suppose we have a function doWork that takes a filtering function, filter, and a maximum value, maxVal, as parameters. doWork checks to make sure that all conditions necessary for its computation are satisfied, then performs the computation with all the values between 0 and maxVal that pass the filter. If it’s time-consuming to do the filtering and it’s also time-consuming to determine whether doWork’s conditions are satisfied, it would be reasonable to do those two things concurrently.

Our preference would be to employ a task-based design for this (see Item 35), but

let’s assume we’d like to set the priority of the thread doing the filtering. Item 35

explains that that requires use of the thread’s native handle, and that’s accessible only through the std::thread API; the task-based API (i.e., futures) doesn’t provide it.

Our approach will therefore be based on threads, not tasks.

We could come up with code like this:

constexpr auto tenMillion = 10000000; // see Item 15

// for constexpr

bool doWork(std::function\<bool(int)\> filter, // returns whether

int maxVal = tenMillion) // computation was

{ // performed; see

// Item 2 for

// std::function

std::vector\<int\> goodVals; // values that

// satisfy filter

std::thread t(\[&filter, maxVal, &goodVals\] // populate

{ // goodVals

for (auto i = 0; i \<= maxVal; ++i)

{ if (filter(i)) goodVals.push_back(i); }


});

auto nh = t.native_handle(); // use t's native

… // handle to set

// t's priority

if ( *conditionsAreSatisfied()*) {

t.join(); // let t finish

*performComputation(goodVals)*;

return true; // computation was

} // performed

return false; // computation was

} // not performed

Before I explain why this code is problematic, I’ll remark that tenMillion’s initializing value can be made more readable in C++14 by taking advantage of C++14’s ability to use an apostrophe as a digit separator:

constexpr auto tenMillion = 10**'** 000**'** 000; // C++14

I’ll also remark that setting t’s priority after it has started running is a bit like closing the proverbial barn door after the equally proverbial horse has bolted. A better design would be to start t in a suspended state (thus making it possible to adjust its priority before it does any computation), but I don’t want to distract you with that code. If

you’re more distracted by the code’s absence, turn to Item 39, because it shows how

to start threads suspended.

But back to doWork. If *conditionsAreSatisfied()* returns true, all is well, but if it returns false or throws an exception, the std::thread object t will be joinable when its destructor is called at the end of doWork. That would cause program execution to be terminated.

You might wonder why the std::thread destructor behaves this way. It’s because the two other obvious options are arguably worse. They are:

• **An implicit join**. In this case, a std::thread’s destructor would wait for its underlying asynchronous thread of execution to complete. That sounds reasonable, but it could lead to performance anomalies that would be difficult to track down. For example, it would be counterintuitive that doWork would wait for its filter to be applied to all values if *conditionsAreSatisfied()* had already returned false.

• **An implicit detach**. In this case, a std::thread’s destructor would sever the connection between the std::thread object and its underlying thread of execution. The underlying thread would continue to run. This sounds no less reasonable than the join approach, but the debugging problems it can lead to are worse. In doWork, for example, goodVals is a local variable that is captured by reference. It’s also modified inside the lambda (via the call to push_back). Suppose, then, that while the lambda is running asynchronously, *conditionsAreSa* *tisfied()* returns false. In that case, doWork would return, and its local variables (including goodVals) would be destroyed. Its stack frame would be popped, and execution of its thread would continue at doWork’s call site.

Statements following that call site would, at some point, make additional function calls, and at least one such call would probably end up using some or all of the memory that had once been occupied by the doWork stack frame. Let’s call such a function f. While f was running, the lambda that doWork initiated would still be running asynchronously. That lambda could call push_back on the stack memory that used to be goodVals but that is now somewhere inside f’s stack frame. Such a call would modify the memory that used to be goodVals, and that means that from f’s perspective, the content of memory in its stack frame could spontaneously change! Imagine the fun you’d have debugging *that*.

The Standardization Committee decided that the consequences of destroying a joinable thread were sufficiently dire that they essentially banned it (by specifying that destruction of a joinable thread causes program termination).

This puts the onus on you to ensure that if you use a std::thread object, it’s made unjoinable on every path out of the scope in which it’s defined. But covering every path can be complicated. It includes flowing off the end of the scope as well as jump-ing out via a return, continue, break, goto or exception. That can be a lot of paths.

Any time you want to perform some action along every path out of a block, the normal approach is to put that action in the destructor of a local object. Such objects are known as *RAII objects*, and the classes they come from are known as *RAII classes*.

( *RAII* itself stands for “Resource Acquisition Is Initialization,” although the crux of the technique is destruction, not initialization). RAII classes are common in the Standard Library. Examples include the STL containers (each container’s destructor destroys the container’s contents and releases its memory), the standard smart point‐

ers (Items 18–20 explain that std::unique_ptr’s destructor invokes its deleter on the object it points to, and the destructors in std::shared_ptr and std::weak_ptr decrement reference counts), std::fstream objects (their destructors close the files they correspond to), and many more. And yet there is no standard RAII class for std::thread objects, perhaps because the Standardization Committee, having rejected both join and detach as default options, simply didn’t know what such a class should do.


Fortunately, it’s not difficult to write one yourself. For example, the following class allows callers to specify whether join or detach should be called when a Threa dRAII object (an RAII object for a std::thread) is destroyed:

class ThreadRAII {

public:

enum class DtorAction { join, detach }; // see Item 10 for

// enum class info

ThreadRAII(std::thread&& t, DtorAction a) // in dtor, take

: action(a), t(std::move(t)) {} // action a on t

~ThreadRAII()

{ // see below for

if (t.joinable()) { // joinability test

if (action == DtorAction::join) {

t.join();

} else {

t.detach();

}

}

}

std::thread& get() { return t; } // see below

private:

DtorAction action;

std::thread t;

};

I hope this code is largely self-explanatory, but the following points may be helpful:

• The constructor accepts only std::thread rvalues, because we want to move the passed-in std::thread into the ThreadRAII object. (Recall that std::thread objects aren’t copyable.)

• The parameter order in the constructor is designed to be intuitive to callers (specifying the std::thread first and the destructor action second makes more sense than vice versa), but the member initialization list is designed to match the order of the data members’ declarations. That order puts the std::thread object last. In this class, the order makes no difference, but in general, it’s possible for the initialization of one data member to depend on another, and because std::thread objects may start running a function immediately after they are

initialized, it’s a good habit to declare them last in a class. That guarantees that at the time they are constructed, all the data members that precede them have already been initialized and can therefore be safely accessed by the asynchronously running thread that corresponds to the std::thread data member.

• ThreadRAII offers a get function to provide access to the underlying

std::thread object. This is analogous to the get functions offered by the standard smart pointer classes that give access to their underlying raw pointers. Providing get avoids the need for ThreadRAII to replicate the full std::thread interface, and it also means that ThreadRAII objects can be used in contexts where std::thread objects are required.

• Before the ThreadRAII destructor invokes a member function on the

std::thread object t, it checks to make sure that t is joinable. This is necessary, because invoking join or detach on an unjoinable thread yields undefined behavior. It’s possible that a client constructed a std::thread, created a ThreadRAII object from it, used get to acquire access to t, and then did a move from t or called join or detach on it. Each of those actions would render t unjoinable.

If you’re worried that in this code,

if (**t.joinable()**) {

if (action == DtorAction::join) {

**t.join();**

} else {

**t.detach();**

}

}

a race exists, because between execution of t.joinable() and invocation of join or detach, another thread could render t unjoinable, your intuition is commendable, but your fears are unfounded. A std::thread object can change state from joinable to unjoinable only through a member function call, e.g., join, detach, or a move operation. At the time a ThreadRAII object’s destructor is invoked, no other thread should be making member function calls on that object.

If there are simultaneous calls, there is certainly a race, but it isn’t inside the destructor, it’s in the client code that is trying to invoke two member functions (the destructor and something else) on one object at the same time. In general, simultaneous member function calls on a single object are safe only if all are to const member functions (see Item 16).

Employing ThreadRAII in our doWork example would look like this:


bool doWork(std::function\<bool(int)\> filter, // as before int maxVal = tenMillion)

{

std::vector\<int\> goodVals; // as before

**ThreadRAII t(** // use RAII object

std::thread(\[&filter, maxVal, &goodVals\]

{

for (auto i = 0; i \<= maxVal; ++i)

{ if (filter(i)) goodVals.push_back(i); }

})**,**

**ThreadRAII::DtorAction::join** // RAII action

**);**

auto nh = t**.get()**.native_handle();

…

if ( *conditionsAreSatisfied()*) {

t**.get()**.join();

*performComputation(goodVals)*;

return true;

}

return false;

}

In this case, we’ve chosen to do a join on the asynchronously running thread in the ThreadRAII destructor, because, as we saw earlier, doing a detach could lead to some truly nightmarish debugging. We also saw earlier that doing a join could lead to performance anomalies (that, to be frank, could also be unpleasant to debug), but given a choice between undefined behavior (which detach would get us), program termination (which use of a raw std::thread would yield), or performance anomalies, performance anomalies seems like the best of a bad lot.

Alas, Item 39 demonstrates that using ThreadRAII to perform a join on std::thread destruction can sometimes lead not just to a performance anomaly, but to a hung program. The “proper” solution to these kinds of problems would be to communicate to the asynchronously running lambda that we no longer need its work and that it should return early, but there’s no support in C++11 for *interruptible*

*threads*. They can be implemented by hand, but that’s a topic beyond the scope of this book.3

Item 17 explains that because ThreadRAII declares a destructor, there will be no compiler-generated move operations, but there is no reason ThreadRAII objects shouldn’t be movable. If compilers were to generate these functions, the functions would do the right thing, so explicitly requesting their creation isappropriate: class ThreadRAII {

public:

enum class DtorAction { join, detach }; // as before

ThreadRAII(std::thread&& t, DtorAction a) // as before

: action(a), t(std::move(t)) {}

~ThreadRAII()

{

… // as before

}

**ThreadRAII(ThreadRAII&&) = default;** // support **ThreadRAII& operator=(ThreadRAII&&) = default;** // moving std::thread& get() { return t; } // as before

private: // as before

DtorAction action;

std::thread t;

};

**Things to Remember**

• Make std::threads unjoinable on all paths.

• join-on-destruction can lead to difficult-to-debug performance anomalies.

• detach-on-destruction can lead to difficult-to-debug undefined behavior.

• Declare std::thread objects last in lists of data members.

3 You’ll find a nice treatment in Anthony Williams’ *C++ Concurrency in Action* (Manning Publications, 2012), section 9.2.


![](media/index-276_1.jpg)

![](media/index-276_2.png)

![](media/index-276_3.jpg)

![](media/index-276_4.png)

**Item 38: Be aware of varying thread handle destructor**

**behavior.**

Item 37 explains that a joinable std::thread corresponds to an underlying system

thread of execution. A future for a non-deferred task (see Item 36) has a similar relationship to a system thread. As such, both std::thread objects and future objects can be thought of as *handles* to system threads.

From this perspective, it’s interesting that std::threads and futures have such dif‐

ferent behaviors in their destructors. As noted in Item 37, destruction of a joinable std::thread terminates your program, because the two obvious alternatives—an implicit join and an implicit detach—were considered worse choices. Yet the destructor for a future sometimes behaves as if it did an implicit join, sometimes as if it did an implicit detach, and sometimes neither. It never causes program termination. This thread handle behavioral bouillabaisse deserves closer examination.

We’ll begin with the observation that a future is one end of a communications channel through which a callee transmits a result to a caller.4 The callee (usually running asynchronously) writes the result of its computation into the communications channel (typically via a std::promise object), and the caller reads that result using a future. You can think of it as follows, where the dashed arrow shows the flow of information from callee to caller:

future

std::promise

Caller

Callee

(typically)

But where is the callee’s result stored? The callee could finish before the caller invokes get on a corresponding future, so the result can’t be stored in the callee’s std::promise. That object, being local to the callee, would be destroyed when the callee finished.

The result can’t be stored in the caller’s future, either, because (among other reasons) a std::future may be used to create a std::shared_future (thus transferring ownership of the callee’s result from the std::future to the std::shared_future), which may then be copied many times after the original std::future is destroyed.

Given that not all result types can be copied (i.e., move-only types) and that the result 4 Item 39 explains that the kind of communications channel associated with a future can be employed for other purposes. For this Item, however, we’ll consider only its use as a mechanism for a callee to convey its result to a caller.


![](media/index-277_1.jpg)

![](media/index-277_2.png)

![](media/index-277_3.jpg)

![](media/index-277_4.png)

![](media/index-277_5.jpg)

![](media/index-277_6.png)

must live at least as long as the last future referring to it, which of the potentially many futures corresponding to the callee should be the one to contain its result?

Because neither objects associated with the callee nor objects associated with the caller are suitable places to store the callee’s result, it’s stored in a location outside both. This location is known as the *shared state*. The shared state is typically represented by a heap-based object, but its type, interface, and implementation are not specified by the Standard. Standard Library authors are free to implement shared states in any way they like.

We can envision the relationship among the callee, the caller, and the shared state as follows, where dashed arrows once again represent the flow of information: Shared State

future

std::promise

Caller

Callee’s

Result

Callee

(typically)

The existence of the shared state is important, because the behavior of a future’s destructor—the topic of this Item—is determined by the shared state associated with the future. In particular,

• **The destructor for the last future referring to a shared state for a non-deferred task launched via std::async blocks** until the task completes. In essence, the destructor for such a future does an implicit join on the thread on which the asynchronously executing task is running.

• **The destructor for all other futures simply destroys the future object**. For asynchronously running tasks, this is akin to an implicit detach on the underlying thread. For deferred tasks for which this is the final future, it means that the deferred task will never run.

These rules sound more complicated than they are. What we’re really dealing with is a simple “normal” behavior and one lone exception to it. The normal behavior is that a future’s destructor destroys the future object. That’s it. It doesn’t join with anything, it doesn’t detach from anything, it doesn’t run anything. It just destroys the future’s data members. (Well, actually, it does one more thing. It decrements the reference count inside the shared state that’s manipulated by both the futures referring to it and the callee’s std::promise. This reference count makes it possible for the library to know when the shared state can be destroyed. For general information

about reference counting, see Item 19.)

The exception to this normal behavior arises only for a future for which all of the following apply:


• **It refers to a shared state that was created due to a call to std::async**.

• **The task’s launch policy is std::launch::async** (see Item 36), either because that was chosen by the runtime system or because it was specified in the call to std::async.

• **The future is the last future referring to the shared state**. For std::futures, this will always be the case. For std::shared_futures, if other std::shared\_

futures refer to the same shared state as the future being destroyed, the future being destroyed follows the normal behavior (i.e., it simply destroys its data members).

Only when all of these conditions are fulfilled does a future’s destructor exhibit special behavior, and that behavior is to block until the asynchronously running task completes. Practically speaking, this amounts to an implicit join with the thread running the std::async-created task.

It’s common to hear this exception to normal future destructor behavior summarized as “Futures from std::async block in their destructors.” To a first approximation, that’s correct, but sometimes you need more than a first approximation. Now you know the truth in all its glory and wonder.

Your wonder may take a different form. It may be of the “I wonder why there’s a special rule for shared states for non-deferred tasks that are launched by std::async”

variety. It’s a reasonable question. From what I can tell, the Standardization Committee wanted to avoid the problems associated with an implicit detach (see Item 37),

but they didn’t want to adopt as radical a policy as mandatory program termination (as they did for joinable std::threads—again, see Item 37), so they compromised on an implicit join. The decision was not without controversy, and there was serious talk about abandoning this behavior for C++14. In the end, no change was made, so the behavior of destructors for futures is consistent in C++11 and C++14.

The API for futures offers no way to determine whether a future refers to a shared state arising from a call to std::async, so given an arbitrary future object, it’s not possible to know whether it will block in its destructor waiting for an asynchronously running task to finish. This has some interesting implications:

// this container *might* block in its dtor, because one or more

// contained futures could refer to a shared state for a non-

// deferred task launched via std::async

std::vector\< **std::future\<void\>** \> futs; // see Item 39 for info

// on std::future\<void\>

class Widget { // Widget objects *might*

public: // block in their dtors


…

private:

**std::shared_future\<double\>** fut;

};

Of course, if you have a way of knowing that a given future *does not* satisfy the conditions that trigger the special destructor behavior (e.g., due to program logic), you’re assured that that future won’t block in its destructor. For example, only shared states arising from calls to std::async qualify for the special behavior, but there are other ways that shared states get created. One is the use of std::packaged_task. A std::packaged_task object prepares a function (or other callable object) for asynchronous execution by wrapping it such that its result is put into a shared state. A future referring to that shared state can then be obtained via std::packaged_task’s get_future function:

int calcValue(); // func to run

std::packaged_task\<int()\> // wrap calcValue so it

pt(calcValue); // can run asynchronously

auto fut = pt.get_future(); // get future for pt

At this point, we know that the future fut doesn’t refer to a shared state created by a call to std::async, so its destructor will behave normally.

Once created, the std::packaged_task pt can be run on a thread. (It could be run via a call to std::async, too, but if you want to run a task using std::async, there’s little reason to create a std::packaged_task, because std::async does everything std::packaged_task does before it schedules the task for execution.)

std::packaged_tasks aren’t copyable, so when pt is passed to the std::thread constructor, it must be cast to an rvalue (via std::move—see Item 23):

std::thread t(std::move(pt)); // run pt on t

This example lends some insight into the normal behavior for future destructors, but it’s easier to see if the statements are put together inside a block:

{ // begin block

std::packaged_task\<int()\>

pt(calcValue);

auto fut = pt.get_future();


std::thread t(std::move(pt));

**…** // see below

} // end block

The most interesting code here is the “…” that follows creation of the std::thread object t and precedes the end of the block. What makes it interesting is what can happen to t inside the “…” region. There are three basic possibilities:

• **Nothing happens to t**. In this case, t will be joinable at the end of the scope.

That will cause the program to be terminated (see Item 37).

• **A join is done on t**. In this case, there would be no need for fut to block in its destructor, because the join is already present in the calling code.

• **A detach is done on t**. In this case, there would be no need for fut to detach in its destructor, because the calling code already does that.

In other words, when you have a future corresponding to a shared state that arose due to a std::packaged_task, there’s usually no need to adopt a special destruction policy, because the decision among termination, joining, or detaching will be made in the code that manipulates the std::thread on which the std::packaged_task is typically run.

**Things to Remember**

• Future destructors normally just destroy the future’s data members.

• The final future referring to a shared state for a non-deferred task launched via std::async blocks until the task completes.

**Item 39: Consider void futures for one-shot event**

**communication.**

Sometimes it’s useful for a task to tell a second, asynchronously running task that a particular event has occurred, because the second task can’t proceed until the event has taken place. Perhaps a data structure has been initialized, a stage of computation has been completed, or a significant sensor value has been detected. When that’s the case, what’s the best way for this kind of inter-thread communication to take place?

An obvious approach is to use a condition variable ( *condvar*). If we call the task that detects the condition the *detecting task* and the task reacting to the condition the

*reacting task*, the strategy is simple: the reacting task waits on a condition variable, and the detecting thread notifies that condvar when the event occurs. Given std::condition_variable cv; // condvar for event

std::mutex m; // mutex for use with cv

the code in the detecting task is as simple as simple can be:

… // detect event

**cv.notify_one()**; // tell reacting task

If there were multiple reacting tasks to be notified, it would be appropriate to replace notify_one with notify_all, but for now, we’ll assume there’s only one reacting task.

The code for the reacting task is a bit more complicated, because before calling wait on the condvar, it must lock a mutex through a std::unique_lock object. (Locking a mutex before waiting on a condition variable is typical for threading libraries. The need to lock the mutex through a std::unique_lock object is simply part of the C++11 API.) Here’s the conceptual approach:

… // prepare to react

{ // open critical section

std::unique_lock\<std::mutex\> lk(m); // lock mutex

**cv.wait(lk)**; // wait for notify;

// *this isn't correct!*

… // react to event

// (m is locked)

} // close crit. section;

// unlock m via lk's dtor

… // continue reacting

// (m now unlocked)

The first issue with this approach is what’s sometimes termed a *code smell*: even if the code works, something doesn’t seem quite right. In this case, the odor emanates from the need to use a mutex. Mutexes are used to control access to shared data, but it’s entirely possible that the detecting and reacting tasks have no need for such media-tion. For example, the detecting task might be responsible for initializing a global data structure, then turning it over to the reacting task for use. If the detecting task

never accesses the data structure after initializing it, and if the reacting task never accesses it before the detecting task indicates that it’s ready, the two tasks will stay out of each other’s way through program logic. There will be no need for a mutex. The fact that the condvar approach requires one leaves behind the unsettling aroma of suspect design.

Even if you look past that, there are two other problems you should definitely pay attention to:

• **If the detecting task notifies the condvar before the reacting task waits, the** **reacting task will hang**. In order for notification of a condvar to wake another task, the other task must be waiting on that condvar. If the detecting task happens to execute the notification before the reacting task executes the wait, the reacting task will miss the notification, and it will wait forever.

• **The wait statement fails to account for spurious wakeups**. A fact of life in threading APIs (in many languages—not just C++) is that code waiting on a condition variable may be awakened even if the condvar wasn’t notified. Such awakenings are known as *spurious wakeups*. Proper code deals with them by confirming that the condition being waited for has truly occurred, and it does this as its first action after waking. The C++ condvar API makes this exceptionally easy, because it permits a lambda (or other function object) that tests for the waited-for condition to be passed to wait. That is, the wait call in the reacting task could be written like this:

cv.wait(lk,

\[\]{ **return** ***whether the event has occurred*****;** }); Taking advantage of this capability requires that the reacting task be able to determine whether the condition it’s waiting for is true. But in the scenario we’ve been considering, the condition it’s waiting for is the occurrence of an event that the detecting thread is responsible for recognizing. The reacting thread may have no way of determining whether the event it’s waiting for has taken place. That’s why it’s waiting on a condition variable!

There are many situations where having tasks communicate using a condvar is a good fit for the problem at hand, but this doesn’t seem to be one of them.

For many developers, the next trick in their bag is a shared boolean flag. The flag is initially false. When the detecting thread recognizes the event it’s looking for, it sets the flag:

std::atomic\<bool\> flag(false); // shared flag; see

// Item 40 for std::atomic

… // detect event


**flag = true;** // tell reacting task For its part, the reacting thread simply polls the flag. When it sees that the flag is set, it knows that the event it’s been waiting for has occurred:

… // prepare to react

**while (!flag);** // wait for event

… // react to event

This approach suffers from none of the drawbacks of the condvar-based design.

There’s no need for a mutex, no problem if the detecting task sets the flag before the reacting task starts polling, and nothing akin to a spurious wakeup. Good, good, good.

Less good is the cost of polling in the reacting task. During the time the task is waiting for the flag to be set, the task is essentially blocked, yet it’s still running. As such, it occupies a hardware thread that another task might be able to make use of, it incurs the cost of a context switch each time it starts or completes its time-slice, and it could keep a core running that might otherwise be shut down to save power. A truly blocked task would do none of these things. That’s an advantage of the condvar-based approach, because a task in a wait call is truly blocked.

It’s common to combine the condvar and flag-based designs. A flag indicates whether the event of interest has occurred, but access to the flag is synchronized by a mutex.

Because the mutex prevents concurrent access to the flag, there is, as Item 40

explains, no need for the flag to be std::atomic; a simple bool will do. The detecting task would then look like this:

std::condition_variable cv; // as before

std::mutex m;

**bool** flag(false); // not std::atomic

… // detect event

**{**

**std::lock_guard\<std::mutex\> g(m);** // lock m via g's ctor flag = true; // tell reacting task

// (part 1)

**}** // unlock m via g's dtor


cv.notify_one(); // tell reacting task

// (part 2)

And here’s the reacting task:

… // prepare to react

{ // as before

std::unique_lock\<std::mutex\> lk(m); // as before

**cv.wait(lk, \[\] { return flag; })**; // use lambda to avoid

// spurious wakeups

… // react to event

// (m is locked)

}

… // continue reacting

// (m now unlocked)

This approach avoids the problems we’ve discussed. It works regardless of whether the reacting task waits before the detecting task notifies, it works in the presence of spurious wakeups, and it doesn’t require polling. Yet an odor remains, because the detecting task communicates with the reacting task in a very curious fashion. Notifying the condition variable tells the reacting task that the event it’s been waiting for has probably occurred, but the reacting task must check the flag to be sure. Setting the flag tells the reacting task that the event has definitely occurred, but the detecting task still has to notify the condition variable so that the reacting task will awaken and check the flag. The approach works, but it doesn’t seem terribly clean.

An alternative is to avoid condition variables, mutexes, and flags by having the reacting task wait on a future that’s set by the detecting task. This may seem like an odd idea. After all, Item 38 explains that a future represents the receiving end of a communications channel from a callee to a (typically asynchronous) caller, and here there’s no callee-caller relationship between the detecting and reacting tasks. However, Item 38 also notes that a communications channel whose transmitting end is a std::promise and whose receiving end is a future can be used for more than just callee-caller communication. Such a communications channel can be used in any situation where you need to transmit information from one place in your program to another. In this case, we’ll use it to transmit information from the detecting task to the reacting task, and the information we’ll convey will be that the event of interest has taken place.

The design is simple. The detecting task has a std::promise object (i.e., the writing end of the communications channel), and the reacting task has a corresponding

future. When the detecting task sees that the event it’s looking for has occurred, it *sets* the std::promise (i.e., writes into the communications channel). Meanwhile, the reacting task waits on its future. That wait blocks the reacting task until the std::promise has been set.

Now, both std::promise and futures (i.e., std::future and std::shared_future) are templates that require a type parameter. That parameter indicates the type of data to be transmitted through the communications channel. In our case, however, there’s no data to be conveyed. The only thing of interest to the reacting task is that its future has been set. What we need for the std::promise and future templates is a type that indicates that no data is to be conveyed across the communications channel. That type is void. The detecting task will thus use a std::promise\<void\>, and the reacting task a std::future\<void\> or std::shared_future\<void\>. The detecting task will set its std::promise\<void\> when the event of interest occurs, and the reacting task will wait on its future. Even though the reacting task won’t receive any data from the detecting task, the communications channel will permit the reacting task to know when the detecting task has “written” its void data by calling set_value on its std::promise.

So given

std::promise\<void\> p; // promise for

// communications channel

the detecting task’s code is trivial,

… // detect event

**p.set_value();** // tell reacting task

and the reacting task’s code is equally simple:

… // prepare to react

**p.get_future().wait();** // wait on future

// corresponding to p

… // react to event

Like the approach using a flag, this design requires no mutex, works regardless of whether the detecting task sets its std::promise before the reacting task waits, and is immune to spurious wakeups. (Only condition variables are susceptible to that problem.) Like the condvar-based approach, the reacting task is truly blocked after making the wait call, so it consumes no system resources while waiting. Perfect, right?


Not exactly. Sure, a future-based approach skirts those shoals, but there are other

hazards to worry about. For example, Item 38 explains that between a std::promise and a future is a shared state, and shared states are typically dynamically allocated.

You should therefore assume that this design incurs the cost of heap-based allocation and deallocation.

Perhaps more importantly, a std::promise may be set only once. The communications channel between a std::promise and a future is a *one-shot* mechanism: it can’t be used repeatedly. This is a notable difference from the condvar- and flag-based designs, both of which can be used to communicate multiple times. (A condvar can be repeatedly notified, and a flag can always be cleared and set again.) The one-shot restriction isn’t as limiting as you might think. Suppose you’d like to create a system thread in a suspended state. That is, you’d like to get all the overhead associated with thread creation out of the way so that when you’re ready to execute something on the thread, the normal thread-creation latency will be avoided. Or you might want to create a suspended thread so that you could configure it before letting it run. Such configuration might include things like setting its priority or core affinity. The C++ concurrency API offers no way to do those things, but std::thread objects offer the native_handle member function, the result of which is intended to give you access to the platform’s underlying threading API (usually POSIX threads or Windows threads). The lower-level API often makes it possible to configure thread characteristics such as priority and affinity.

Assuming you want to suspend a thread only once (after creation, but before it’s running its thread function), a design using a void future is a reasonable choice. Here’s the essence of the technique:

**std::promise\<void\> p;**

void react(); // func for reacting task

void detect() // func for detecting task

{

std::thread t(\[\] // create thread

{

**p.get_future().wait();** // suspend t until

react(); // future is set

});

… // here, t is suspended

// prior to call to react

**p.set_value();** // unsuspend t (and thus

// call react)


… // do additional work t.join(); // make t unjoinable

} // (see Item 37)

Because it’s important that t become unjoinable on all paths out of detect, use of an RAII class like Item 37’s ThreadRAII seems like it would be advisable. Code like this comes to mind:

void detect()

{

**ThreadRAII tr(** // use RAII object

std::thread(\[\]

{

p.get_future().wait();

react();

})**,**

**ThreadRAII::DtorAction::join** // *risky! (see below)*

**);**

… // thread inside tr

// is suspended here

p.set_value(); // unsuspend thread

// inside tr

…

}

This looks safer than it is. The problem is that if in the first “…” region (the one with the “thread inside tr is suspended here” comment), an exception is emitted, set_value will never be called on p. That means that the call to wait inside the lambda will never return. That, in turn, means that the thread running the lambda will never finish, and that’s a problem, because the RAII object tr has been configured to perform a join on that thread in tr’s destructor. In other words, if an exception is emitted from the first “…” region of code, this function will hang, because tr’s destructor will never complete.

There are ways to address this problem, but I’ll leave them in the form of the hallowed exercise for the reader.5 Here, I’d like to show how the original code (i.e., not using ThreadRAII) can be extended to suspend and then unsuspend not just one 5 [A reasonable place to begin researching the matter is my 24 December 2013 blog post at *The View From Aris‐*](http://scottmeyers.blogspot.com/)

[*teia*,](http://scottmeyers.blogspot.com/) [“ThreadRAII + Thread Suspension = Trouble?”](http://scottmeyers.blogspot.com/2013/12/threadraii-thread-suspension-trouble.html)


reacting task, but many. It’s a simple generalization, because the key is to use std::shared_futures instead of a std::future in the react code. Once you know that the std::future’s share member function transfers ownership of its shared state to the std::shared_future object produced by share, the code nearly writes itself. The only subtlety is that each reacting thread needs its own copy of the std::shared_future that refers to the shared state, so the std::shared_future obtained from share is captured by value by the lambdas running on the reacting threads:

std::promise\<void\> p; // as before

void detect() // now for multiple

{ // reacting tasks

auto sf = p.get_future()**.share()**; // sf's type is

// std::shared_future\<void\>

std::vector\<std::thread\> vt; // container for

// reacting threads

for (int i = 0; i \< threadsToRun; ++i) {

vt.emplace_back(\[**sf**\]{ sf.wait(); // wait on local

react(); }); // copy of sf; see

} // Item 42 for info

// on emplace_back

… // *detect hangs if*

// *this "…" code throws!*

p.set_value(); // unsuspend all threads

…

for (auto& t : vt) { // make all threads

t.join(); // unjoinable; see Item 2

} // for info on "auto&"

}

The fact that a design using futures can achieve this effect is noteworthy, and that’s why you should consider it for one-shot event communication.


**Things to Remember**

• For simple event communication, condvar-based designs require a superfluous mutex, impose constraints on the relative progress of detecting and reacting tasks, and require reacting tasks to verify that the event has taken place.

• Designs employing a flag avoid those problems, but are based on polling, not blocking.

• A condvar and flag can be used together, but the resulting communications mechanism is somewhat stilted.

• Using std::promises and futures dodges these issues, but the approach uses heap memory for shared states, and it’s limited to one-shot communication.

**Item 40: Use std::atomic for concurrency, volatile**

**for special memory.**

Poor volatile. So misunderstood. It shouldn’t even be in this chapter, because it has nothing to do with concurrent programming. But in other programming languages (e.g., Java and C#), it is useful for such programming, and even in C++, some compilers have imbued volatile with semantics that render it applicable to concurrent software (but only when compiled with those compilers). It’s thus worthwhile to discuss volatile in a chapter on concurrency if for no other reason than to dispel the confusion surrounding it.

The C++ feature that programmers sometimes confuse volatile with—the feature that definitely does belong in this chapter—is the std::atomic template. Instantiations of this template (e.g., std::atomic\<int\>, std::atomic\<bool\>, std::atomic\<Widget\*\>, etc.) offer operations that are guaranteed to be seen as atomic by other threads. Once a std::atomic object has been constructed, operations on it behave as if they were inside a mutex-protected critical section, but the operations are generally implemented using special machine instructions that are more efficient than would be the case if a mutex were employed.

Consider this code using std::atomic:

**std::atomic\<int\>** ai(0); // initialize ai to 0

ai = 10; // atomically set ai to 10

std::cout \<\< ai; // atomically read ai's value

++ai; // atomically increment ai to 11


--ai; // atomically decrement ai to 10

During execution of these statements, other threads reading ai may see only values of 0, 10, or 11. No other values are possible (assuming, of course, that this is the only thread modifying ai).

Two aspects of this example are worth noting. First, in the “std::cout \<\< ai;” statement, the fact that ai is a std::atomic guarantees only that the read of ai is atomic.

There is no guarantee that the entire statement proceeds atomically. Between the time ai’s value is read and operator\<\< is invoked to write it to the standard output, another thread may have modified ai’s value. That has no effect on the behavior of the statement, because operator\<\< for ints uses a by-value parameter for the int to output (the outputted value will therefore be the one that was read from ai), but it’s important to understand that what’s atomic in that statement is nothing more than the read of ai.

The second noteworthy aspect of the example is the behavior of the last two statements—the increment and decrement of ai. These are each read-modify-write (RMW) operations, yet they execute atomically. This is one of the nicest characteristics of the std::atomic types: once a std::atomic object has been constructed, all member functions on it, including those comprising RMW operations, are guaranteed to be seen by other threads as atomic.

In contrast, the corresponding code using volatile guarantees virtually nothing in a multithreaded context:

**volatile** int vi(0); // initialize vi to 0

vi = 10; // set vi to 10

std::cout \<\< vi; // read vi's value

++vi; // increment vi to 11

--vi; // decrement vi to 10

During execution of this code, if other threads are reading the value of vi, they may see anything, e.g, -12, 68, 4090727—anything! Such code would have undefined behavior, because these statements modify vi, so if other threads are reading vi at the same time, there are simultaneous readers and writers of memory that’s neither std::atomic nor protected by a mutex, and that’s the definition of a data race.


As a concrete example of how the behavior of std::atomics and volatiles can differ in a multithreaded program, consider a simple counter of each type that’s incremented by multiple threads. We’ll initialize each to 0:

std::atomic\<int\> ac(0); // "atomic counter"

volatile int vc(0); // "volatile counter"

We’ll then increment each counter one time in two simultaneously running threads:

/\*----- Thread 1 ----- \*/ /\*------- Thread 2 ------- \*/

++ac; ++ac;

++vc; ++vc;

When both threads have finished, ac’s value (i.e., the value of the std::atomic) must be 2, because each increment occurs as an indivisible operation. vc’s value, on the other hand, need not be 2, because its increments may not occur atomically. Each increment consists of reading vc’s value, incrementing the value that was read, and writing the result back into vc. But these three operations are not guaranteed to proceed atomically for volatile objects, so it’s possible that the component parts of the two increments of vc are interleaved as follows:

1\. Thread 1 reads vc’s value, which is 0.

2\. Thread 2 reads vc’s value, which is still 0.

3\. Thread 1 increments the 0 it read to 1, then writes that value into vc.

4\. Thread 2 increments the 0 it read to 1, then writes that value into vc.

vc’s final value is therefore 1, even though it was incremented twice.

This is not the only possible outcome. vc’s final value is, in general, not predictable, because vc is involved in a data race, and the Standard’s decree that data races cause undefined behavior means that compilers may generate code to do literally anything.

Compilers don’t use this leeway to be malicious, of course. Rather, they perform optimizations that would be valid in programs without data races, and these optimizations yield unexpected and unpredictable behavior in programs where races are present.

The use of RMW operations isn’t the only situation where std::atomics comprise a concurrency success story and volatiles suffer failure. Suppose one task computes an important value needed by a second task. When the first task has computed the

value, it must communicate this to the second task. Item 39 explains that one way for the first task to communicate the availability of the desired value to the second task is

by using a std::atomic\<bool\>. Code in the task computing the value would look something like this:

**std::atomic\<bool\>** valAvailable(false);

auto imptValue = computeImportantValue(); // compute value

valAvailable = true; // tell other task

// it's available

As humans reading this code, we know it’s crucial that the assignment to imptValue take place before the assignment to valAvailable, but all compilers see is a pair of assignments to independent variables. As a general rule, compilers are permitted to reorder such unrelated assignments. That is, given this sequence of assignments (where a, b, x, and y correspond to independent variables),

a = b;

x = y;

compilers may generally reorder them as follows:

x = y;

a = b;

Even if compilers don’t reorder them, the underlying hardware might do it (or might make it seem to other cores as if it had), because that can sometimes make the code run faster.

However, the use of std::atomics imposes restrictions on how code can be reordered, and one such restriction is that no code that, in the source code, precedes a write of a std::atomic variable may take place (or appear to other cores to take place) afterwards.6 That means that in our code,

auto imptValue = computeImportantValue(); // compute value

valAvailable = true; // tell other task

// it's available

not only must compilers retain the order of the assignments to imptValue and valAvailable, they must generate code that ensures that the underlying hardware 6 This is true only for std::atomics using *sequential consistency*, which is both the default and the only consistency model for std::atomic objects that use the syntax shown in this book. C++11 also supports consistency models with more flexible code-reordering rules. Such *weak* (aka *relaxed*) models make it possible to create software that runs faster on some hardware architectures, but the use of such models yields software that is *much* more difficult to get right, to understand, and to maintain. Subtle errors in code using relaxed atomics is not uncommon, even for experts, so you should stick to sequential consistency if at all possible.


does, too. As a result, declaring valAvailable as std::atomic ensures that our critical ordering requirement—imptValue must be seen by all threads to change no later than valAvailable does—is maintained.

Declaring valAvailable as volatile doesn’t impose the same code reordering restrictions:

**volatile** bool valAvailable(false);

auto imptValue = computeImportantValue();

valAvailable = true; // other threads might see this assignment

// before the one to imptValue!

Here, compilers might flip the order of the assignments to imptValue and valAvail able, and even if they don’t, they might fail to generate machine code that would prevent the underlying hardware from making it possible for code on other cores to see valAvailable change before imptValue.

These two issues—no guarantee of operation atomicity and insufficient restrictions on code reordering—explain why volatile’s not useful for concurrent programming, but it doesn’t explain what it is useful for. In a nutshell, it’s for telling compilers that they’re dealing with memory that doesn’t behave normally.

“Normal” memory has the characteristic that if you write a value to a memory location, the value remains there until something overwrites it. So if I have a normal int, int x;

and a compiler sees the following sequence of operations on it,

auto y = x; // read x

y = x; // read x again

the compiler can optimize the generated code by eliminating the assignment to y, because it’s redundant with y’s initialization.

Normal memory also has the characteristic that if you write a value to a memory location, never read it, and then write to that memory location again, the first write can be eliminated, because it was never used. So given these two adjacent statements, x = 10; // write x

x = 20; // write x again

compilers can eliminate the first one. That means that if we have this in the source code,

auto y = x; // read x

y = x; // read x again


x = 10; // write x

x = 20; // write x again

compilers can treat it as if it had been written like this:

auto y = x; // read x

x = 20; // write x

Lest you wonder who’d write code that performs these kinds of redundant reads and superfluous writes (technically known as *redundant loads* and *dead stores*), the answer is that humans don’t write it directly—at least we hope they don’t. However, after compilers take reasonable-looking source code and perform template instantiation, inlining, and various common kinds of reordering optimizations, it’s not uncommon for the result to have redundant loads and dead stores that compilers can get rid of.

Such optimizations are valid only if memory behaves normally. “Special” memory doesn’t. Probably the most common kind of special memory is memory used for *memory-mapped I/O*. Locations in such memory actually communicate with periph-erals, e.g., external sensors or displays, printers, network ports, etc. rather than reading or writing normal memory (i.e., RAM). In such a context, consider again the code with seemingly redundant reads:

auto y = x; // read x

y = x; // read x again

If x corresponds to, say, the value reported by a temperature sensor, the second read of x is not redundant, because the temperature may have changed between the first and second reads.

It’s a similar situation for seemingly superfluous writes. In this code, for example, x = 10; // write x

x = 20; // write x again

if x corresponds to the control port for a radio transmitter, it could be that the code is issuing commands to the radio, and the value 10 corresponds to a different command from the value 20. Optimizing out the first assignment would change the sequence of commands sent to the radio.

volatile is the way we tell compilers that we’re dealing with special memory. Its meaning to compilers is “Don’t perform any optimizations on operations on this memory.” So if x corresponds to special memory, it’d be declared volatile: **volatile** int x;

Consider the effect that has on our original code sequence:


auto y = x; // read x

y = x; // read x again ( *can't be optimized away*) x = 10; // write x ( *can't be optimized away*)

x = 20; // write x again

This is precisely what we want if x is memory-mapped (or has been mapped to a memory location shared across processes, etc.).

Pop quiz! In that last piece of code, what is y’s type: int or volatile int?7

The fact that seemingly redundant loads and dead stores must be preserved when dealing with special memory explains, by the way, why std::atomics are unsuitable for this kind of work. Compilers are permitted to eliminate such redundant operations on std::atomics. The code isn’t written quite the same way it is for vola tiles, but if we overlook that for a moment and focus on what compilers are permitted to do, we can say that, conceptually, compilers may take this, **std::atomic\<** int**\>** x;

auto y = x; // *conceptually* read x (see below)

y = x; // *conceptually* read x again (see below)

x = 10; // write x

x = 20; // write x again

and optimize it to this:

auto y = x; // *conceptually* read x (see below)

x = 20; // write x

For special memory, this is clearly unacceptable behavior.

Now, as it happens, neither of these two statements will compile when x is std::atomic:

auto y = x; // error!

y = x; // error!

That’s because the copy operations for std::atomic are deleted (see Item 11). And with good reason. Consider what would happen if the initialization of y with x com-7 y’s type is auto-deduced, so it uses the rules described in Item 2. Those rules dictate that for the declaration of non-reference non-pointer types (which is the case for y), const and volatile qualifiers are dropped. y’s type is therefore simply int. This means that redundant reads of and writes to y can be eliminated. In the example, compilers must perform both the initialization of and the assignment to y, because x is volatile, so the second read of x might yield a different value from the first one.


piled. Because x is std::atomic, y’s type would be deduced to be std::atomic, too

(see Item 2). I remarked earlier that one of the best things about std::atomics is that all their operations are atomic, but in order for the copy construction of y from x to be atomic, compilers would have to generate code to read x and write y in a single atomic operation. Hardware generally can’t do that, so copy construction isn’t supported for std::atomic types. Copy assignment is deleted for the same reason, which is why the assignment from x to y won’t compile. (The move operations aren’t explicitly declared in std::atomic, so, per the rules for compiler-generated special

functions described in Item 17, std::atomic offers neither move construction nor move assignment.)

It’s possible to get the value of x into y, but it requires use of std::atomic’s member functions load and store. The load member function reads a std::atomic’s value atomically, while the store member function writes it atomically. To initialize y with x, followed by putting x’s value in y, the code must be written like this: std::atomic\<int\> y(**x.load()**); // read x

**y.store(x.load())**; // read x again

This compiles, but the fact that reading x (via x.load()) is a separate function call from initializing or storing to y makes clear that there is no reason to expect either statement as a whole to execute as a single atomic operation.

Given that code, compilers could “optimize” it by storing x’s value in a register instead of reading it twice:

***register*** = x.load(); // read x into register std::atomic\<int\> y( ***register***); // init y with register value y.store( ***register***); // store register value into y The result, as you can see, reads from x only once, and that’s the kind of optimization that must be avoided when dealing with special memory. (The optimization isn’t permitted for volatile variables.)

The situation should thus be clear:

• std::atomic is useful for concurrent programming, but not for accessing special memory.

• volatile is useful for accessing special memory, but not for concurrent programming.


Because std::atomic and volatile serve different purposes, they can even be used together:

**volatile std::atomic\<int\>** vai; // operations on vai are

// atomic and can't be

// optimized away

This could be useful if vai corresponded to a memory-mapped I/O location that was concurrently accessed by multiple threads.

As a final note, some developers prefer to use std::atomic’s load and store member functions even when they’re not required, because it makes explicit in the source code that the variables involved aren’t “normal.” Emphasizing that fact isn’t unreasonable. Accessing a std::atomic is typically much slower than accessing a non-std::atomic, and we’ve already seen that the use of std::atomics prevents compilers from performing certain kinds of code reorderings that would otherwise be permitted. Calling out loads and stores of std::atomics can therefore help identify potential scalability chokepoints. From a correctness perspective, *not* seeing a call to store on a variable meant to communicate information to other threads (e.g., a flag indicating the availability of data) could mean that the variable wasn’t declared std::atomic when it should have been.

This is largely a style issue, however, and as such is quite different from the choice between std::atomic and volatile.

**Things to Remember**

• std::atomic is for data accessed from multiple threads without using

mutexes. It’s a tool for writing concurrent software.

• volatile is for memory where reads and writes should not be optimized away. It’s a tool for working with special memory.
