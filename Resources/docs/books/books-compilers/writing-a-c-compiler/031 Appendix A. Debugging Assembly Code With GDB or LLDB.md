## `A` `DEBUGGING ASSEMBLY CODE WITH GDB OR LLDB`

![](/tmp/audit/iter1/epubregen/writing-a-c-compiler/media/a26394c5fd9047c0974071f62d6ff4719089a6da.jpg)

At some point, your compiler is going to generate assembly code that doesn’t behave correctly, and you’ll need to figure out why. When that happens, a command line debugger is indispensable for understanding what’s going wrong. A debugger lets you pause a running program, step through it one instruction at a time, and examine the program state at different points. You can use either GDB (the GNU debugger) or LLDB (the debugger from the LLVM Project) to debug the assembly code your compiler generates. I recommend using GDB if you’re on Linux and LLDB if you’re on macOS (I think GDB has a slightly nicer UI for working with assembly, but getting it to run on macOS can be a challenge).

This appendix is a brief guide to debugging assembly programs with GDB or LLDB. It introduces the basics that you’ll need to know if you’ve never used a debugger before. It also covers the most important commands and options that you’ll need to use to work with assembly code in particular, which may be new to you even if you’re comfortable using these tools to debug source code. I’ve included separate walk-throughs for the two debuggers; even though they have very similar functionality, the details of many commands are different. Follow the walk-through for whichever debugger you’re using.

Before you get started, you should be familiar with the basics of assembly code covered in Chapters 1 and 2. A few aspects of assembly from later chapters will also come up, but you can gloss over those if you haven’t gotten to them yet.

## `The Program`

We’ll use the assembly program in Listing A-1 as a running example.

        .data
        .align 4
    ❶ integer:
        .long 100
        .align 8
    ❷ dbl:
        .double 3.5
        .text
        .globl main
    ❸ main:
        pushq   %rbp
        movq    %rsp, %rbp
        subq    $16, %rsp
        # call a function
     ❹ callq   f
     ❺ # put some stuff in registers
        movl    $0x87654321, %eax
        movsd   dbl(%rip), %xmm0
        # put some stuff on the stack
        movl    $0xdeadbeef, -4(%rbp)
        movl    $0, -8(%rbp)
        movl    $-1, -12(%rbp)
        movl    $0xfeedface, -16(%rbp)
     ❻ # initialize loop counter
        movl    $25, %ecx
    .L_loop_start:
        # decrement counter
        subl    $1, %ecx
        cmpl    $0, %ecx
        # jump back to start of loop
        jne     .L_loop_start
        # return 0
        movl    $0, %eax
        movq    %rbp, %rsp
        popq    %rbp
        ret
        .text
        .globl  f
    f:
        movl    $1, %eax
        ret
        .section .note.GNU-stack,"",@progbits

`Listing A-1: A pointless assembly program`

This program doesn’t do anything useful; it just gives us the opportunity to try out the most important features of the debuggers. It includes a couple of static variables for us to inspect: `integer` ❶ and `dbl` ❷. In `main` ❸, it first calls a very small function, `f`, so we can practice stepping into and out of function calls ❹, then moves some data into registers and onto the stack so we can practice examining the state of the program ❺. It ends with a loop that decrements ECX on every iteration, stopping once it reaches 0 ❻. We’ll use this loop to practice setting conditional breakpoints.

Download this program from *<https://norasandler.com/book/#appendix-a>*, then save it as *hello_debugger.s*. There are two different versions of this file for Linux and macOS, so make sure to pick the right one for your operating system.

Once you’ve saved the file, assemble and link it and confirm that it runs:

    $ gcc hello_debugger.s -o hello_debugger
    $ ./hello_debugger

On macOS, include the `-g` option when you assemble and link the file:

    $ gcc -g hello_debugger.s -o hello_debugger

The `-g` option generates extra debug information. Make sure to include it when assembling and linking your own compiler’s assembly output for debugging too.

Now you can start the walk-through. If you’re using GDB, follow the walk-through in the next section. If you’re using LLDB, skip to “Debugging with LLDB” on page 687.

## `Debugging with GDB`

Run this command to start up GDB:

    $ gdb hello_debugger
    --snip--
    (gdb)

This sets `hello_debugger` as the executable to debug but doesn’t actually execute it. Before we start running this executable, let’s configure the UI to make working with assembly code easier.

### `Configuring the GDB UI`

During a GDB session, you can open up different text windows that display different information about the running program. For our purposes, the most important of these is the *assembly window*, which displays the assembly code as we step through it. The *register window* is also useful; by default, it shows the current contents of every general-purpose register.

The `layout` command controls which windows are visible. Let’s open up the assembly and register windows:

    (gdb) layout asm
    (gdb) layout reg

You should now see three windows in your terminal: the register window, the assembly window, and the command window with the `(gdb)` prompt. It should look similar to Figure A-1.

![](/tmp/audit/iter1/epubregen/writing-a-c-compiler/media/3db878f081b128a4740edee5e42d47908571a9e2.jpg)

`Figure A-1: A GDB session with the assembly and register windows open ``Description`

The register window won’t display any information until you start the program.

You can scroll in whichever window is currently in focus. Use the `focus` command to change the in-focus window:

    (gdb) focus cmd
    (gdb) focus asm
    (gdb) focus regs

### `Starting and Stopping the Program`

Next, we’ll set a *breakpoint*—a location where the debugger will pause the program—and run the program up to that breakpoint. If we start the program without setting a breakpoint first, it will run all the way through without stopping, which isn’t very useful.

The command `break <``function name>` sets a breakpoint at the start of a function. Let’s set a breakpoint at the entrance to `main`:

    (gdb) break main
    Breakpoint 1 at 0x112d

Now let’s start the program:

    (gdb) run
    Starting program: /home/ubuntu/hello_debugger

    ❶ Breakpoint 1, 0x000055555555512d in main ()

The output of this command tells us that the program has hit the breakpoint we just set ❶. Notice that the current instruction is highlighted in the assembly window and the current values of the general-purpose registers are displayed in the register window, as shown in Figure A-2.

![](/tmp/audit/iter1/epubregen/writing-a-c-compiler/media/729b96fd6a5a2e4dff4780af00cec29603957b4a.jpg)

`Figure A-2: A GDB session when the program is stopped at a breakpoint ``Description`

Once a program is paused, there are a few commands you can use to move it forward:

`continue` resumes the program and runs until we hit another breakpoint or exit.

`finish` resumes the program and pauses again when we return from the current function.

`stepi` executes the next instruction, then pauses. It steps into `call` instructions, pausing at the first instruction in the callee. The command `stepi` `<n>` will execute *n* instructions.

`nexti` executes the next instruction, then pauses. It steps over `call` instructions, pausing at the next instruction after `call` in the current function. The command `nexti` `<n>` will execute *n* instructions.

Most GDB instructions can be abbreviated to one or two letters: you can type `c` instead of `continue`, `b` instead of `break`, `si` instead of `stepi`, and so on. Table A-1 on page 687 gives full and shortened versions of all the commands we discuss.

> `WARNING`

*While the nexti and stepi commands step through assembly instructions, the next and step commands step through lines in the original source file. Since we don’t have any information about the original source file, entering one of these commands will run the program until the end of the current function. These commands are abbreviated to n and s, respectively, so it’s easy to run them by accident when you meant to use nexti or stepi.*

Let’s try out our new commands. First, we’ll execute two instructions, which should take us into the call to `f`:

    (gdb) stepi 2
    0x0000555555555176 in ❶ f ()

We can see from the command output ❶ and from the highlighted instruction in the assembly window that we’re stopped in `f` instead of `main`. Next, we’ll return from `f`:

    (gdb) finish
    Run till exit from #0  0x0000555555555176 in f ()
    0x0000555555555136 in main ()

We’re now back in `main`, at the instruction right after `callq`. Let’s continue:

    (gdb) continue
    Continuing.
    [Inferior 1 (process 82326) exited normally]

Since we didn’t hit any more breakpoints, the program ran until it exited. To keep debugging it, we’ll have to restart it:

    (gdb) run
    Starting program: /home/ubuntu/hello_debugger

    Breakpoint 1, 0x000055555555512d in main ()

Now we’re paused at the start of `main` again. We’ll step forward two instructions one more time, but this time we’ll use `nexti` to step over `f` instead of stepping into it:

    (gdb) nexti 2
    0x0000555555555136 in main ()

This puts us back at the instruction right after `callq`.

#### `Setting Breakpoints by Address`

In addition to setting breakpoints on functions, you can break on specific machine instructions. Let’s set a breakpoint on the instruction `movl 0xdeadbeef, -4(%rbp)`. First, we’ll find this instruction in the assembly window. It should look something like this:

        ❶ 0x555555555143 ❷ <main+26>        movl    0xdeadbeef, -4(%rbp)

The instruction’s address in memory is at the beginning of the line ❶, followed by the byte offset of that address from the start of the function ❷. The exact address may be different on your machine, but the offset should be the same. To set this breakpoint, you can type either

    (gdb) break *main+26

or

    (gdb) break *MEMORY_ADDRESS

where `MEMORY_ADDRESS` is the address you found in the assembly window. The `*` symbol tells GDB that we’re specifying an exact address rather than a function name.

#### `Managing Breakpoints`

Let’s list all the breakpoints we’ve set:

    (gdb) info break
    Num     Type           Disp Enb Address            What
    1       breakpoint     keep y   0x000055555555512d <main+4>
            breakpoint already hit 1 time
    2       breakpoint     keep y   0x0000555555555143 <main+26>

Every breakpoint has a unique number, which you can refer to if you need to delete, disable, or modify it. Let’s delete breakpoint 1:

    (gdb) delete 1

Next, we’ll look at a couple of different ways to examine the program’s state.

### `Printing Expressions`

You can print out expressions with the command `print/``<format> <expr>`, where:

`<format>` is a one-letter format specifier. You can use most of the same format specifiers you’d use in `printf`: `x` to display a value as a hexadecimal integer, `d` to display it as a signed integer, and so on.

`<expr>` is an arbitrary expression. This expression can refer to registers, memory addresses, and symbols in the running program. It can also include C operations like arithmetic, pointer dereferencing, and cast expressions.

Let’s try some examples. Right now, the program should be paused at the instruction `movl 0x87654321, %eax`. We’ll step through this instruction, then print out the value of EAX in a few different formats:

    (gdb) stepi
    --snip--
    (gdb) print $eax
    $1 = ❶ -2023406815
    (gdb) print/x $eax
    $2 = ❷ 0x87654321
    (gdb) print/u $eax
    $3 = ❸ 2271560481

By default, GDB formats the values in general-purpose registers as signed integers ❶. Here, we also display the value in EAX in hexadecimal ❷ and as an unsigned integer ❸. The symbols `$1`, `$2`, and so on are *convenience variables*, which GDB automatically generates to store the result of each expression.

You can find the full list of format specifiers in the documentation for the `x` command, which we’ll talk more about in a moment:

    (gdb) help x
    --snip--
    Format letters are o(octal), x(hex), d(decimal), u(unsigned decimal),
      t(binary), f(float), a(address), i(instruction), c(char), s(string)
      and z(hex, zero padded on the left).
    --snip--

Chapter 13 introduces the XMM registers, which hold floating-point values. The next instruction in our program, `movsd dbl(%rip), %xmm0`, copies the value `3.5` from the static `dbl` variable into XMM0.

Let’s step through this instruction, then inspect XMM0:

    (gdb) stepi
    --snip--
    (gdb) print $xmm0
    $4 = {v4_float = {0, 2.1875, 0, 0}, v2_double = {3.5, 0}, v16_int8 = {0, 0, 0, 0,
    0, 0, 12, 64, 0, 0, 0, 0, 0, 0, 0, 0}, v8_int16 = {0, 0, 0, 16396, 0, 0, 0, 0},
    v4_int32 = {0, 1074528256, 0, 0}, v2_int64 = {4615063718147915776, 0}, uint128 =
    4615063718147915776}

GDB is showing us lots of different views of the same data: `v4_float` displays this register’s contents as an array of four 32-bit floats, `v2_double` displays it as an array of 64-bit doubles, and so on. Since we’ll use XMM registers only to store individual doubles, you can always examine them with a command like this:

    (gdb) print $xmm0.v2_double[0]
    $5 = 3.5

This prints out the value in the register’s lower 64 bits, interpreted as a double.

In addition to registers, we can print out the values of objects in the symbol table. Let’s inspect the two static variables in this program, `integer` and `dbl`:

    (gdb) print (long) integer
    $6 = 100
    (gdb) print (double) dbl
    $7 = 3.5

Since GDB doesn’t have any information about these objects’ types, we have to cast them to the correct type explicitly.

Let’s look at a few examples of more complex expressions. Aside from the fact that they refer directly to hardware registers, these expressions all use ordinary C syntax.

We can perform basic arithmetic:

    (gdb) print/x $eax + 0x10
    $8 = 0x87654331

We can call functions that are defined in the current program or the standard library. Here, we call `f`, which returns `1`:

    (gdb) print (int) f()
    $9 = 1

We can also dereference pointers. Let’s execute the next instruction, `movl 0xdeadbeef, -4(%rbp)`, then inspect the value at `-4(%rbp)`:

    (gdb) stepi
    --snip--
    (gdb) print/x *(int *)($rbp - 4)
    $10 = 0xdeadbeef

First, we calculate the memory address we want to inspect, `$rbp - 4`. Then, we cast this address to the correct pointer type, `(int *)`. Finally, we dereference it with the dereference operator, `*`. This produces an integer, which we print out in hexadecimal with the `/x` specifier.

Next, we’ll look at a more flexible way to inspect values in memory.

### `Examining Memory`

We can examine memory with the command `x/<``n><format><unit> <expr>`, where:

`<n>` is the number of units of memory to display (given the unit size specified by `<unit>`).

`<format>` specifies how to format each unit. These are the same format specifiers we used in the `print` command.

`<unit>` is a one-letter specifier for the size of a unit: `b` for a byte, `h` for a 2-byte halfword, `w` for a 4-byte word, or `g` for an 8-byte “giant” word.

`<expr>` is an arbitrary expression that evaluates to some valid memory address. These are the same kinds of expressions we can use in the `print` command.

Let’s use the `x` command to inspect the integer at `-4(%rbp)`:

    (gdb) x/1xw ($rbp - 4)
    ❶ 0x7fffffffe2ac: ❷ 0xdeadbeef

This command tells GDB to print out one 4-byte word in hexadecimal. The output includes both the memory address ❶ and the value at that address ❷.

The next three instructions in Listing A-1 store three more integers on the stack:

        movl    $0, -8(%rbp)
        movl    $-1, -12(%rbp)
        movl    $0xfeedface, -16(%rbp)

We’ll use the commands in Listing A-2 to step through these instructions, then print out the whole stack frame.

    (gdb) stepi 3
    (gdb) x/6xw $rsp
    0x7fffffffe2a0: ❶ 0xfeedface      0xffffffff     0x00000000     ❷ 0xdeadbeef
    0x7fffffffe2b0: ❸ 0x00000000      0x00000000

`Listing A-2: Stepping forward three instructions, then printing out the current stack frame`

The command `x/6xw $rsp` tells GDB to print out six 4-byte words, starting at the address in RSP. We print out six words because the stack frame for this particular function is 24 bytes. At the start of `main`, we saved the old value of RBP onto the stack. That’s 8 bytes. Then, we allocated another 16 bytes with the command `subq $16, %rsp`. Keep in mind that RSP always holds the address of the top of the stack, which is the *lowest* stack address.

This command displays the four integers we saved to the stack, with `0xfeedface` at the top ❶ and `0xdeadbeef` at the bottom ❷, followed by the old value of RBP ❸. On some systems, this value will be 0 because we’re in the outermost stack frame; on others, it will be a valid memory address.

The saved value of RBP is at the bottom of the current stack frame. Right after it, on top of the *caller’s* stack frame, we’ll find the caller’s return address—that is, the address we’ll jump to when we return from `main`. (We covered this in detail when we implemented function calls in Chapter 9.) Let’s inspect this return address:

    (gdb) x/4ag $rsp
    0x7fffffffe2a0: 0xfffffffffeedface      0xdeadbeef00000000
    0x7fffffffe2b0: 0x0     ❶ 0x7ffff7dee083 <__libc_start_main+243>

This command will print out four 8-byte “giant” words, starting with the value at the address in RSP. The `a` specifier tells GDB to format these values as memory addresses; this means it will print each address in hexadecimal and, if possible, print out its offset from the nearest symbol in the program. Because function and static variable names are defined in the symbol table, GDB can display the relative offsets of assembly instructions and static data. It won’t display relative offsets of stack addresses, heap addresses, or invalid addresses, because they would be completely meaningless.

The first line of output includes the four integers we saved onto the stack, now displayed as two 8-byte values instead of four 4-byte values. The null pointer `0x0` on the next line is the saved value of RBP. None of these three 8-byte values are valid addresses, so GDB can’t display their offsets from symbols. The next value on the stack is the return address ❶. GDB tells us that this is the address of an instruction in `_libc_start_main`, the standard library function responsible for calling `main` and cleaning up after it exits.

The `a` specifier makes it easy to spot return addresses and pointers to static variables. This is particularly useful if your program’s stack frame is corrupted; finding each stack frame’s return address can help you get your bearings.

### `Setting Conditional Breakpoints`

To wrap up this walk-through, we’ll look at how to set *conditional breakpoints*. The program will pause at a conditional breakpoint only if the associated condition is true. This condition can be an arbitrary expression; GDB will consider it false if it evaluates to 0 and true otherwise.

Let’s set a breakpoint on the `jne` instruction at the end of the last loop iteration in `hello_debugger`. First, we need to find this instruction in the assembly window. It should be 65 bytes after the start of the function:

        0x55555555516a <main+65>        jne    0x555555555164 <main+59>

We’ll set a conditional breakpoint to pause on this instruction if ECX is 0:

    (gdb) break *main+65 if $ecx == 0

Since this loop repeats until ECX is 0, the condition `$ecx` `==` `0` will be true only on the last iteration. Let’s continue until this breakpoint, then verify that the condition is true:

    (gdb) c
    Continuing.

    Breakpoint 3, 0x000055555555516a in main ()
    (gdb) print $ecx
    $11 = 0

So far, so good. If you get a different value for ECX, check whether you set the breakpoint correctly:

    (gdb) info break
    --snip--
    3       breakpoint     keep y   0x000055555555516a ❶ <main+65>
            stop only if ❷ $ecx == 0

Make sure that your breakpoint is at the location `main+65` ❶ and that it includes the condition `$ecx` `==` `0` ❷. If your breakpoint looks different, you might have mistyped something; delete it and try again.

We should be on the last loop iteration, so let’s step forward one instruction and make sure that the jump isn’t taken:

    (gdb) stepi

Usually, `jne` will jump back to the start of the loop, but on the last iteration it moves forward to the next instruction.

### `Getting Help`

To learn about commands and options that we didn’t cover here, see the GDB documentation at *<https://sourceware.org/gdb/current/onlinedocs/gdb/index.html>*. As you saw earlier, you can also type `help` at the prompt to learn more about any GDB command. For example, to see the documentation for the `run` command, type:

    (gdb) help run
    Start debugged program.
    You may specify arguments to give it.
    --snip--

Table A-1 summarizes the commands and options we covered, including full and abbreviated forms for each command (except `x`, which can’t be abbreviated any further). Both forms take the same arguments.

`Table A-1:` `A Summary of GDB Commands`

| `Command`                            | `Description`                                                                                            |
|--------------------------------------|----------------------------------------------------------------------------------------------------------|
| `run`                                | `Start the program.`                                                                                     |
| `r`                                  |                                                                                                          |
| `continue`                           | `Resume the program.`                                                                                    |
| `c`                                  |                                                                                                          |
| `finish`                             | `Resume the program and continue until the current function exits.`                                      |
| `fin`                                |                                                                                                          |
| stepi \[ \<n\> \]                    | Execute one instruction (or n instructions), stepping into function calls.                               |
| `si`                                 |                                                                                                          |
| nexti \[ \<n\> \]                    | Execute one instruction (or n instructions), stepping over function calls.                               |
| `ni`                                 |                                                                                                          |
| break \<loc\> \[if \<cond\> \]       | Set a breakpoint at \<loc\> (conditional on \<cond\> , if provided).                                     |
| `b`                                  |                                                                                                          |
| `info break`                         | List all breakpoints. (Other info subcommands display other information.)                                |
| `i b`                                |                                                                                                          |
| delete \[ \<id\> \]                  | Delete all breakpoints (or the breakpoint specified by \<id\> ).                                         |
| `d`                                  |                                                                                                          |
| print/\< format\> \<expr\>           | Evaluate \<expr\> and display the result according to format specifier \<format\> .                      |
| `p`                                  |                                                                                                          |
| x/ \<n\>\<format\>\<unit\> \< addr\> | Print out memory starting at \<addr\> in n chunks of size \<unit\> , formatted according to \<format\> . |
| layout \<window\>                    | Open \<window\> .                                                                                        |
| `la`                                 |                                                                                                          |
| focus \<window\>                     | Change focus to \<window\> .                                                                             |
| `fs`                                 |                                                                                                          |
| help \<cmd\>                         | Display help text about \<cmd\> .                                                                        |
| `h`                                  |                                                                                                          |

Now you’re ready to start debugging with GDB!

## `Debugging with LLDB`

Run this command to start up LLDB:

    $ lldb hello_debugger
    (lldb) target create "hello_debugger"
    Current executable set to 'hello_debugger' (x86_64).
    (lldb)

This will set `hello_debugger` as the executable to debug but won’t execute it yet. If prompted, enter your username and password to give LLDB permission to control `hello_debugger`.

### `Starting and Stopping the Program`

Next, we’ll set a *breakpoint*—a location where the debugger will pause the program—and run the program up to that breakpoint. If we start the program without setting a breakpoint first, it will run all the way through without stopping, which isn’t very useful.

Let’s set a breakpoint at the entrance to `main`:

    (lldb) break set -n main
    Breakpoint 1: where = hello_debugger`main, address = 0x0000000100003f65

Note that `main` may be at a different memory address on your machine. The `break set` command creates a new breakpoint; the `-n` option specifies the name of the function where we want to break. We’ll look at other ways to set breakpoints in a moment.

Now let’s run the program:

    (lldb) run
    Process 6750 launched: '/Users/me/hello_debugger' (x86_64)
    Process 6750 stopped
    * thread #1, queue = 'com.apple.main-thread', ❶ stop reason = breakpoint 1.1
        frame #0: 0x0000000100003f65 hello_debugger`main
    ❷ hello_debugger`main:
    ❸ ->  0x100003f65 <+0>: pushq  %rbp
        0x100003f66 <+1>: movq   %rsp, %rbp
        0x100003f69 <+4>: subq   $0x10, %rsp
        0x100003f6d <+8>: callq  0x100003fb2               ; f
    Target 0: (hello_debugger) stopped.
    (lldb)

The `stop reason` ❶ tells us that the program has hit the breakpoint we just set. LLDB also helpfully tells us that we’re stopped in the `main` function in `hello_debugger` ❷ and prints out the next few assembly instructions ❸.

Once a program is paused, there are a few commands we can use to keep executing it:

`continue` resumes the program and runs until we hit another breakpoint or exit.

`finish` resumes the program and pauses again when we return from the current function.

`stepi` executes the next instruction, then pauses. It steps into `call` instructions, pausing at the first instruction in the callee. The command `stepi -c` `<n>` steps through *n* instructions.

`nexti` executes the next instruction, then pauses. It steps over `call` instructions, pausing at the next instruction after `call` in the current function. The command `nexti -c` `<n>` steps through *n* instructions.

Most LLDB commands have several aliases. For example, `continue` is a shortcut for `process continue`, and it can be shortened even further to the one-letter command `c`. See Table A-2 on page 697 for full and abbreviated versions of all the commands we cover.

Let’s try out these new commands. First, we’ll execute four instructions, which should take us into the call to `f`:

    (lldb) stepi -c 4
    --snip--
    ❶ hello_debugger`f:
    ->  0x100003fb2 <+0>: movl   $0x1, %eax
    --snip--

We can see from the command output that we’re stopped in `f` instead of `main` ❶. Now we’ll return from `f`:

    (lldb) finish
    --snip--
    ->  0x100003f72 <+13>: movl   $0x87654321, %eax         ; imm = 0x87654321
    --snip--

This puts us back in `main`, at the instruction right after `callq`. Let’s continue:

    (lldb) continue
    Process 6750 resuming
    Process 6750 exited with status = 0 (0x00000000)

Since we didn’t hit any more breakpoints, the program ran until it exited. To keep debugging it, we have to restart it:

    (lldb) run

Now we’re paused at the start of `main` again. Once again, we’ll move forward four instructions, but this time we’ll use `nexti` to step over `f` instead of stepping into it:

    (lldb) nexti -c 4
    --snip--
    ->  0x100003f72 <+13>: movl   $0x87654321, %eax         ; imm = 0x87654321
    --snip--

This puts us back at the instruction right after `callq`.

#### `Setting Breakpoints by Address`

In addition to setting breakpoints on functions, you can break on specific machine instructions. Let’s set a breakpoint on the instruction `movl 0xdeadbeef, -4(%rbp)`. First, we need to find this instruction’s address. Luckily, LLDB has already given us this information. The output from the last command should look something like this:

    ->  0x100003f72 <+13>: movl   $0x87654321, %eax         ; imm = 0x87654321
        0x100003f77 <+18>: movsd  0x181(%rip), %xmm0        ; dbl, xmm0 = mem[0],zero
      ❶ 0x100003f7f ❷ <+26>: movl   $0xdeadbeef, -0x4(%rbp)   ; imm = 0xDEADBEEF
        0x100003f86 <+33>: movl   $0x0, -0x8(%rbp)

This shows the next few instructions, including the one we want to break on. We can see that instruction’s memory address ❶ and the byte offset of that address from the start of the function ❷. The exact address may be different on your machine, but the offset should be the same. To set this breakpoint, type

    (lldb) break set -a MEMORY_ADDRESS

where `MEMORY_ADDRESS` is the instruction’s address on your machine. The `-a` option indicates that we’re specifying an address rather than a function name. We can also use more complex expressions to specify instruction addresses. Here’s another way to set a breakpoint on the same instruction:

    (lldb) break set -a '(void()) main + 26'

First, we cast `main` to a function type so that LLDB can use it in address calculations. (It doesn’t matter which function type we cast it to.) Then, we add a 26-byte offset to get the address of the `movl` instruction we want to break on. Since this address expression includes spaces and special characters, we have to wrap the whole thing in quotes.

In a minute, we’ll see how to disassemble the whole function and see every instruction’s address. First, let’s look at a couple of other useful commands for managing breakpoints.

#### `Managing Breakpoints`

Let’s list all the breakpoints we’ve set:

    (lldb) break list
    Current breakpoints:
    1: name = 'main', locations = 1, resolved = 1, hit count = 1
      1.1: where = hello_debugger`main, address = 0x0000000100003f65, resolved, hit count = 1

    2: address = hello_debugger[0x0000000100003f7f], locations = 1, resolved = 1, hit count = 0
      2.1: where = hello_debugger`main + 26, address = 0x0000000100003f7f, resolved, hit count = 0

    3: address = hello_debugger[0x0000000100003f7f], locations = 1, resolved = 1, hit count = 0
      3.1: where = hello_debugger`main + 26, address = 0x0000000100003f7f, resolved, hit count = 0

Every breakpoint has a unique number, which you can refer to if you need to delete, disable, or modify it. In the last section, we set breakpoints 2 and 3 at the same location, `main+26`. Let’s delete one of them:

     (lldb) break delete 3

Next, we’ll look at how to display all the assembly instructions in a function, along with their addresses.

### `Displaying Assembly Code`

The command `disassemble -n` `<function name>` tells LLDB to print out all the assembly instructions in a function. Let’s try this out on `main`:

    (lldb) disassemble -n main
        0x100003f65 <+0>:  pushq  %rbp
        0x100003f66 <+1>:  movq   %rsp, %rbp
        0x100003f69 <+4>:  subq   $0x10, %rsp
        0x100003f6d <+8>:  callq  0x100003fb2               ; f
    ->  0x100003f72 <+13>: movl   $0x87654321, %eax         ; imm = 0x87654321
        0x100003f77 <+18>: movsd  0x181(%rip), %xmm0        ; dbl, xmm0 = mem[0],zero
        0x100003f7f <+26>: movl   $0xdeadbeef, -0x4(%rbp)   ; imm = 0xDEADBEEF
        0x100003f86 <+33>: movl   $0x0, -0x8(%rbp)
        0x100003f8d <+40>: movl   $0xffffffff, -0xc(%rbp)   ; imm = 0xFFFFFFFF
        0x100003f94 <+47>: movl   $0xfeedface, -0x10(%rbp)  ; imm = 0xFEEDFACE
        0x100003f9b <+54>: movl   $0x19, %ecx
        0x100003fa0 <+59>: subl   $0x1, %ecx
        0x100003fa3 <+62>: cmpl   $0x0, %ecx
        0x100003fa6 <+65>: jne    0x100003fa0               ; <+59>
        0x100003fa8 <+67>: movl   $0x0, %eax
        0x100003fad <+72>: movq   %rbp, %rsp
        0x100003fb0 <+75>: popq   %rbp
        0x100003fb1 <+76>: retq
    (lldb)

The `->` symbol points to the current instruction. We can also print out a fixed number of instructions, starting at a specific address. Let’s disassemble five instructions, starting with the third instruction in `main`. In the disassembled code shown here, this instruction’s address is `0x100003f69`; it might have a different address on your machine. The `-s` option specifies the address where LLDB should start disassembling, and `-c` specifies how many instructions to display, so we’ll disassemble these five instructions with the following command:

    (lldb) disassemble -s 0x100003f69 -c 5
    hello_debug`main:
        0x100003f69 <+4>:  subq   $0x10, %rsp
        0x100003f6d <+8>:  callq  0x100003fb2               ; f
    ->  0x100003f72 <+13>: movl   $0x87654321, %eax         ; imm = 0x87654321
        0x100003f77 <+18>: movsd  0x181(%rip), %xmm0        ; dbl, xmm0 = mem[0],zero
        0x100003f7f <+26>: movl   $0xdeadbeef, -0x4(%rbp)   ; imm = 0xDEADBEEF

Finally, we can use the `--pc` option to start disassembling at the current instruction:

    (lldb) disassemble --pc -c 3
    ->  0x100003f72 <+13>: movl   $0x87654321, %eax         ; imm = 0x87654321
        0x100003f77 <+18>: movsd  0x181(%rip), %xmm0        ; dbl, xmm0 = mem[0],zero
        0x100003f7f <+26>: movl   $0xdeadbeef, -0x4(%rbp)   ; imm = 0xDEADBEEF

This command displays three instructions, starting with the current instruction. We can use the `-c` option when we specify a starting address with `-s` or `--pc` but not when we disassemble a whole function with `-n`.

### `Printing Expressions`

You can evaluate expressions with the command `exp -f` `<format>` `--` `<expr>`, where:

`<format>` is a format specifier that tells LLDB how to display the result of the expression.

`<expr>` is an arbitrary expression. This expression can refer to registers, memory addresses, and symbols in the running program. It can also include C operations like arithmetic, pointer dereferencing, and cast expressions.

Let’s try some examples. Right now, the program should be paused at the instruction `movl 0x87654321, %eax`. We’ll step through this instruction, then print out the value of EAX in a few different formats:

    (lldb) stepi
    --snip--
    ->  0x100003f77 <+18>: movsd  0x181(%rip), %xmm0        ; dbl, xmm0 = mem[0],zero
    --snip--
    (lldb) exp -- $eax
    (unsigned int) $0 = ❶ 2271560481
    (lldb) exp -f x -- $eax
    (unsigned int) $1 = ❷ 0x87654321
    (lldb) exp -f d -- $eax
    (unsigned int) $2 = ❸ -2023406815

By default, LLDB formats the values in general-purpose registers as unsigned integers ❶. Here, we also display the value of EAX in hexadecimal ❷ and as a signed integer ❸. (For a full list of formats, use the `help format` command.) The symbols `$0`, `$1`, and so on are *convenience variables*, which LLDB automatically generates to store the result of each expression.

Chapter 13 introduces the XMM registers, which hold floating-point values. The next instruction in our program, `movsd dbl(%rip), %xmm0`, copies the value `3.5` from the static `dbl` variable into XMM0. Let’s step through this instruction, then inspect XMM0. We’ll use the `float64[]` format, which displays the register’s contents as an array of two doubles:

    (lldb) stepi
    --snip--
    ->  0x100003f7f <+26>: movl   $0xdeadbeef, -0x4(%rbp)   ; imm = 0
    --snip--
    (lldb) exp -f float64[] -- $xmm0
    (unsigned char __attribute__((ext_vector_type(16)))) $3 = ( ❶ 3.5, 0)

The first array element corresponds to the register’s lower 64 bits ❶, which we updated with the `movsd` instruction. The second element corresponds to the register’s upper 64 bits, which we can ignore.

In addition to registers, we can print out the values of objects in the symbol table. Let’s inspect the two static variables in this program, `integer` and `dbl`:

    (lldb) exp -f d -- integer
    (void *) $4 = 100
    (lldb) exp -f f -- dbl
    (void *) $5 = 3.5

Now let’s look at a few examples of more complex expressions. We can perform basic arithmetic:

    (lldb) exp -f x -- $eax + 0x10
    (unsigned int) $6 = 0x87654331

We can call functions from the current program or the standard library. Here we call `f`, which returns `1`:

    (lldb) exp -- (int) f()
    (int) $7 = 1

We can also dereference pointers. Let’s execute the next instruction, `movl 0xdeadbeef, -4(%rbp)`, then inspect the value at `-4(%rbp)`:

    (lldb) stepi
    --snip--
    ->  0x100003f86 <+33>: movl   $0x0, -0x8(%rbp)
    --snip--
    (lldb) exp -f x -- *(int *)($rbp - 4)
    (int) $8 = 0xdeadbeef

First, we calculate the memory address we want to inspect, `$rbp - 4`. Then, we cast this address to the correct pointer type, `(int *)`. Finally, we dereference it with the dereference operator, `*`. This produces an integer, which we print out in hexadecimal with the option `-f x`.

Next, we’ll look at a more flexible way to inspect values in memory.

### `Examining Memory`

We can examine memory with the `memory read` command. Like `exp`, it takes an arbitrary expression, which must evaluate to a valid memory address. This gives us another way to inspect the integer at `-4(%rbp)`:

    (lldb) memory read -f x -s 4 -c 1 '$rbp - 4'
    0x3040bb93c: 0xdeadbeef

The `-f x` option says to print the output in hexadecimal; `-s 4` says to interpret the contents of memory as a sequence of 4-byte values; and `-c 1` says to print just one of those values. In other words, this command prints out the single 4-byte integer at `$rbp - 4`, formatted as hexadecimal. We have to wrap the expression `$rbp - 4` in quotes because it contains spaces.

The next three instructions in Listing A-1 store three more integers on the stack:

        movl    $0, -8(%rbp)
        movl    $-1, -12(%rbp)
        movl    $0xfeedface, -16(%rbp)

Let’s step through these instructions, then print out the whole stack frame. We’ll tell LLDB to print out six 4-byte words, starting at the address in RSP. We’ll use the option `-l 1` to print out each word on a separate line:

    (lldb) stepi -c 3
    --snip--
    ->  0x100003f9b <+54>: movl   $0x19, %ecx
    --snip--
    (lldb) memory read -f x -s 4 -c 6 -l 1 $rsp
    0x3040bb930: ❶ 0xfeedface
    0x3040bb934: 0xffffffff
    0x3040bb938: 0x00000000
    0x3040bb93c: 0xdeadbeef
    0x3040bb940: ❷ 0x040bba50
    0x3040bb944: 0x00000003

We print out six words because the stack is 24 bytes in this particular function. At the start of `main`, we saved the old value of RBP onto the stack. That’s 8 bytes. Then, we allocated another 16 bytes with the command `subq $16, %rsp`. Keep in mind that RSP always holds the address of the top of the stack, which is the *lowest* stack address.

This command shows us the four integers we saved to the stack, with `0xfeedface` at the top ❶ and the old value of RBP at the bottom ❷. Since the value at ❷ is really an 8-byte address, we can read it more easily if we group the stack into 8-byte values:

    (lldb) memory read -f x -s 8 -c 3 -l 1 $rsp
    0x3040bb930: 0xfffffffffeedface
    0x3040bb938: 0xdeadbeef00000000
    0x3040bb940: ❶ 0x00000003040bba50

Now it’s clear that the bottom 8 bytes on the stack hold a single memory address ❶.

Just below the saved value of RBP, on top of the caller’s stack frame, we’d expect to find the caller’s return address—that is, the address we’ll jump to when we return from `main`. (We cover this in detail when we implement function calls in Chapter 9.) Let’s inspect this address:

    (lldb) memory read -f A -s 8 -c 4 -l 1 $rsp
    0x3040bb930: 0xfffffffffeedface
    0x3040bb938: 0xdeadbeef00000000
    0x3040bb940: 0x00000003040bba50
    0x3040bb948: ❶ 0x0000000200012310 dyld`start + 2432

This command is almost identical to the previous one, except that we use the option `-c 4` to print out four values instead of three and the option `-f A` to format each value as a memory address. The `A` format specifier tells LLDB to print each address in hexadecimal and, if possible, print out its offset from the nearest symbol in the program. Because function and static variable names are defined in the symbol table, LLDB can display the relative offsets of assembly instructions and static data. It won’t display relative offsets of stack addresses, heap addresses, or invalid addresses, because they would be completely meaningless.

The first three lines of output are the same as before. The first two values aren’t valid memory addresses and the third is a stack address, so LLDB can’t display their offsets from symbols. The next value on the stack is the return address ❶. The label `` dyld`start `` tells us this is the address of an instruction in the `start` function in the `dyld` shared library. (The `start` function is responsible for calling `main` and cleaning up after it exits; `dyld` is the dynamic linker.)

The `-f A` option makes it easy to spot return addresses and pointers to static variables. This is particularly useful if your program’s stack frame is corrupted; finding each stack frame’s return address can help you get your bearings.

### `Setting Conditional Breakpoints`

To wrap up this walk-through, we’ll look at how to set *conditional breakpoints*. The program will pause at a conditional breakpoint only if the associated condition is true. This condition can be an arbitrary expression; LLDB will consider it false if it evaluates to 0 and true otherwise.

Let’s set a breakpoint on the `jne` instruction at the end of the last loop iteration in `hello_debugger`. First, we’ll find this instruction’s address in the disassembled `main` function:

    (lldb) disassemble -n main
        --snip--
      ❶ 0x100003fa6 <+65>:  jne    0x100003fa0               ; <+59>
        --snip--

Here, the address of `jne` is `0x100003fa6` ❶. Now we’ll set a conditional breakpoint to pause on the `jne` instruction if ECX is 0. We can use the `-c` option to specify a condition:

    (lldb) break set -a MEMORY_ADDRESS -c '$ecx == 0'

Since this loop repeats until ECX is 0, the condition `$ecx` `==` `0` will be true only on the last iteration. Let’s continue until the breakpoint, then verify that this condition is true:

    (lldb) continue
    --snip--
    ->  0x100003fa6 <+65>:  jne    0x100003fa0               ; <+59>
    --snip--
    (lldb) exp -- $ecx
    (unsigned int) $9 = 0

If you get a different value for ECX, check whether you set the breakpoint correctly:

    (lldb) break list
    --snip--
    4: address = hello_debugger[0x0000000100003fa6], locations = 1, resolved = 1, hit count = 0
    Condition: $ecx == 0 ❶

      4.1: where = ❷ hello_debugger`main + 65, address = 0x0000000100003fa6, resolved, hit count
     = 0

Make sure that your breakpoint includes the condition `$ecx` `==` `0` ❶ and that it’s at the location `` hello_debugger`main `` `+` `65` ❷. If your breakpoint looks different, you might have mistyped something; delete it and try again.

We should be on the last loop iteration, so let’s step forward one instruction and make sure that the jump isn’t taken:

    (lldb) stepi
    --snip--
    ->  0x100003fa8 <+67>:  movl   $0x0, %eax
    --snip--

Usually, `jne` will jump back to the start of the loop, but on the last iteration it moves forward to the next instruction.

### `Getting Help`

To learn more about the commands and options we didn’t cover here, see the LLDB documentation at *<https://lldb.llvm.org/index.html>*. You can also type `help` at the prompt to learn more about any LLDB command. For example, to see the documentation for the `run` command, type:

    (lldb) help run
         Launch the executable in the debugger
    --snip--

Table A-2 summarizes the commands and options we covered. The version of each command that we used in the walk-through is listed first, followed by a shorter abbreviation (except for `exp`, which isn’t normally shortened further), then the full form when it differs from the one we used. All versions of each command take the same arguments.

`Table A-2:` `A Summary of LLDB Commands`

| `Command`                                                                       | `Description`                                                                                                                                                              |
|---------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `run`                                                                           | `Start the program.`                                                                                                                                                       |
| `r`                                                                             |                                                                                                                                                                            |
| `process launch --`                                                             |                                                                                                                                                                            |
| `continue`                                                                      | `Resume the program.`                                                                                                                                                      |
| `c`                                                                             |                                                                                                                                                                            |
| `process continue`                                                              |                                                                                                                                                                            |
| `finish`                                                                        | `Resume the program and continue until the current function exits.`                                                                                                        |
| `fin`                                                                           |                                                                                                                                                                            |
| `thread step-out`                                                               |                                                                                                                                                                            |
| stepi \[-c \<n\> \]                                                             | Execute one instruction (or n instructions), stepping into function calls.                                                                                                 |
| `si`                                                                            |                                                                                                                                                                            |
| `thread step-inst`                                                              |                                                                                                                                                                            |
| nexti \[-c \<n\> \]                                                             | Execute one instruction (or n instructions), stepping over function calls.                                                                                                 |
| `ni`                                                                            |                                                                                                                                                                            |
| `thread step-inst-over`                                                         |                                                                                                                                                                            |
| break set \[-n \<fun\> \| -a \<addr\> \] \[-c \<cond\> \]                       | Set a breakpoint at start of function \<fun\> or at address \<addr\> (conditional on \<cond\> , if provided).                                                              |
| `br s`                                                                          |                                                                                                                                                                            |
| `breakpoint set`                                                                |                                                                                                                                                                            |
| `break list`                                                                    | `List all breakpoints.`                                                                                                                                                    |
| `br l`                                                                          |                                                                                                                                                                            |
| `breakpoint list`                                                               |                                                                                                                                                                            |
| break delete \[ \<id\> \]                                                       | Delete all breakpoints (or the breakpoint specified by \<id\> ).                                                                                                           |
| `br del`                                                                        |                                                                                                                                                                            |
| `breakpoint delete`                                                             |                                                                                                                                                                            |
| exp -f \<format\> -- \<expr\>                                                   | Evaluate \<expr\> and display the result in format \<format\> .                                                                                                            |
| `expression`                                                                    |                                                                                                                                                                            |
| memory read -f \<format\> -s \<size\> -c \<count\> -l \<num-per-line\> \<addr\> | Print out memory in \<count\> chunks of \<size\> bytes, starting at address \<addr\> . Display \<num -per-line\> chunks on each line in format \<format\> .                |
| `me read`                                                                       |                                                                                                                                                                            |
| disassemble \[-n \<fun\> \| -s \<addr\> -c \<count\> \| --pc -c \<count\> \]    | Disassemble all instructions in function \<fun\> , or \<count\> instructions starting at address \<addr\> , or \<count\> instructions starting at the current instruction. |
| `di`                                                                            |                                                                                                                                                                            |
| help \<cmd\>                                                                    | Display help text about \<cmd\> .                                                                                                                                          |
| `h`                                                                             |                                                                                                                                                                            |

Now you’re ready to start debugging with LLDB!