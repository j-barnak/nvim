# Kernel initialization process

You will find here a couple of posts which describe the full cycle of kernel initialization from its first step after the kernel has been decompressed to the start of the first process run by the kernel itself.

*Note* That there will not be a description of the all kernel initialization steps. Here will be only generic kernel part, without interrupts handling, ACPI, and many other parts. All parts which I have missed, will be described in other chapters.

* [First steps after kernel decompression](009%20Initialization%20-%20First%20steps%20in%20the%20kernel.md) - describes first steps in the kernel.
* [Early interrupt and exception handling](010%20Initialization%20-%20Early%20interrupts%20handler.md) - describes early interrupts initialization and early page fault handler.
* [Last preparations before the kernel entry point](011%20Initialization%20-%20Last%20preparations%20before%20the%20kernel%20entry%20point.md) - describes the last preparations before the call of the `start_kernel`.
* [Kernel entry point](012%20Initialization%20-%20Kernel%20entry%20point.md) - describes first steps in the kernel generic code.
* [Continue of architecture-specific initializations](013%20Initialization%20-%20Continue%20architecture-specific%20boot-time%20initializations.md) - describes architecture-specific initialization.
* [Architecture-specific initializations, again...](014%20Initialization%20-%20Architecture-specific%20initializations%2C%20again....md) - describes continue of the architecture-specific initialization process.
* [The End of the architecture-specific initializations, almost...](015%20Initialization%20-%20End%20of%20the%20architecture-specific%20initializations%2C%20almost....md) - describes the end of the `setup_arch` related stuff.
* [Scheduler initialization](016%20Initialization%20-%20Scheduler%20initialization.md) - describes preparation before scheduler initialization and initialization of it.
* [RCU initialization](017%20Initialization%20-%20RCU%20initialization.md) - describes the initialization of the [RCU](http://en.wikipedia.org/wiki/Read-copy-update).
* [End of the initialization](018%20Initialization%20-%20End%20of%20initialization.md) - the last part about Linux kernel initialization.
