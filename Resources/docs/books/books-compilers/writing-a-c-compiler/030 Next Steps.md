# `NEXT STEPS`

![](media/a26394c5fd9047c0974071f62d6ff4719089a6da.jpg)

The world of programming languages is wide, and there’s a lot more for you to explore. Extending your compiler on your own is a great way to keep learning about the topics you’re most interested in.

I’ll leave you with a few ideas to get you started.

## `Add Some Missing Features`

The most obvious next step is to implement the major parts of C that this book didn’t cover. If you already have a list of features you’re particularly excited to add, start with those. Then, if you want to keep going, pick a real-world C program—think something small, not the Linux kernel—and build out your compiler until it can compile that program successfully. You can choose another program and repeat this process until you’re satisfied with how much of the language you’ve implemented. Make sure to add new language features one at a time, testing each one thoroughly before moving on to the next one.

## `Handle Undefined Behavior Safely`

We’ve seen that C compilers can deal with undefined behavior however they like. But just because you *can* do something doesn’t mean you *should*. There are huge benefits to dealing with undefined behavior in a clean, predictable way: it makes C programs more secure, easier to debug, and less terrifying in general. For example, you could guarantee that signed integer overflow always wraps around (this is what the `-fwrapv` compiler option does). Or you could have the program raise an error and exit when it encounters undefined behavior; Clang and GCC both have a feature called UndefinedBehaviorSanitizer that supports this sort of error handling (*<https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html>*).

Think about a few examples of undefined behavior that we discussed in this book. How do you think your compiler should handle them? How would that impact any optimizations you’ve implemented? Some types of undefined behavior are tricky to detect, but others aren’t too difficult to deal with; choose one that seems manageable and see if you can handle it cleanly.

## `Write More TACKY Optimizations`

Chapter 19 covered just a few of the IR optimizations you’d find in a production compiler. If you like, you can implement more on your own. Do some research on common compiler optimizations and pick the ones that sound most interesting. If you go this route, you may want to convert your TACKY code into *static single assignment (SSA) form*, where every variable is defined exactly once. SSA form is widely used in real-world compilers, including Clang and GCC, because it makes many optimizations easier to implement.

## `Support Another Target Architecture`

Most production compilers have several different backends to support different target architectures.

You can use the same strategy, converting TACKY into different assembly code depending on which system you’re targeting. If you use a Windows or ARM system and needed a virtualization or emulation layer to complete this project, a new backend would let you compile code that runs natively on your machine.

If you add support for Windows, you’ll be able to reuse most of your existing code generation pass. Only the ABI will be different. Adding an ARM backend is a more ambitious project; you’ll need to learn a completely new instruction set.

## `Contribute to an Open Source Programming Language Project`

Improving your own compiler is a great way to learn, but consider branching out and working on other projects too. Many widely used compilers are open source and welcome new contributors. The same goes for a whole range of related projects, like interpreters, linters, and static analysis tools. Pick one that you like, and find out how to get involved. This is a great way to put your new skills to work and maybe even make your favorite programming language a little faster, safer, more usable, or easier to learn.

## `That’s a Wrap!`

I hope this book has laid the foundation for you to keep building compilers and programming languages. I also hope it’s changed your perspective on the programming languages you use day to day. You’ll now be better able to appreciate the care, effort, and ingenuity that went into creating those languages, and when things go wrong, you won’t be afraid to dig into the language internals to figure out what’s really happening. Compilers will stop seeming like magic and start to look like something much more interesting: ordinary software.