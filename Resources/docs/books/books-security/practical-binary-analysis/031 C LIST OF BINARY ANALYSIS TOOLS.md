## C LIST OF BINARY ANALYSIS TOOLS

In Chapter 6, I used IDA Pro for the recursive disassembly examples and `objdump` for linear disassembly, but you may prefer different tools. This appendix lists popular disassemblers and binary analysis tools you may find useful, including interactive disassemblers for reverse engineering and disassembly APIs and debuggers capable of execution tracing.

### C.1 Disassemblers

**IDA Pro** (Windows, Linux, macOS; *[www.hex-rays.com](http://www.hex-rays.com)*)

This is the de facto industry-standard recursive disassembler. It’s interactive and includes Python and IDC scripting APIs and a decompiler. It’s one of the best disassemblers out there but also one of the most expensive (\$700 for the most basic version). An older version (v7) is available for free, though it supports x86-64 only and doesn’t include the decompiler.

**Hopper** (Linux, macOS; *[www.hopperapp.com](http://www.hopperapp.com)*)

This is a simpler and cheaper alternative to IDA Pro. It shares many of IDA’s features, including Python scripting and decompilation, albeit less fully developed.

**ODA** (Any platform; *[onlinedisassembler.com](http://onlinedisassembler.com)*)

The Online Disassembler is a free, lightweight, online recursive disassembler that’s great for quick experiments. You can upload binaries or enter bytes into a console.

**Binary Ninja** (Windows, Linux, macOS; *binary.ninja*)

A promising newcomer, Binary Ninja offers an interactive recursive disassembler that supports multiple architectures as well as extensive scripting support for C, C++, and Python. Decompilation functionality is a planned feature. Binary Ninja is not free, but the personal edition is relatively cheap for a fully featured reversing platform at \$149. There’s also a limited demo version available.

**Relyze** (Windows; *[www.relyze.com](http://www.relyze.com)*)

Relyze is an interactive recursive disassembler that offers binary diffing functionality and scripting support in Ruby. It’s commercial but cheaper than IDA Pro.

**Medusa** (Windows, Linux; *[github.com/wisk/medusa/](http://github.com/wisk/medusa/)*)

Medusa is an interactive, multi-architecture, recursive disassembler with Python scripting functionality. In contrast to most comparable disassemblers, it’s completely free and open source.

**radare** (Windows, Linux, macOS; *[www.radare.org](http://www.radare.org)* )

This is an extremely versatile command line–oriented reverse engineering framework. It’s a bit different from other disassemblers in that it’s structured as a set of tools rather than as a single coherent interface. The ability to arbitrarily combine these tools from the command line makes radare flexible. It offers both linear and recursive disassembly modes and can be used interactively as well as fully scripted. It’s aimed at reverse engineering, forensics, and hacking. This tool set is free and open source.

**objdump** (Linux, macOS; *[www.gnu.org/software/binutils/](http://www.gnu.org/software/binutils/)*)

This is the well-known linear disassembler used in this book. It’s free and open source. The GNU version is part of GNU binutils and comes prepackaged for all Linux distributions. It’s also available for macOS (and Windows, if you install Cygwin^(1)).

### C.2 Debuggers

**gdb** (Linux; *[www.gnu.org/software/gdb/](http://www.gnu.org/software/gdb/)*)

The GNU Debugger is the standard debugger on Linux systems and is meant primarily for interactive debugging. It also supports remote debugging. While you can also trace execution with `gdb`, Chapter 9 shows that other tools, such as Pin, are better suited for doing this automatically.

**OllyDbg** (Windows; *[www.ollydbg.de](http://www.ollydbg.de)*)

This is a versatile debugger for Windows with built-in functionality for execution tracing and advanced features for unpacking obfuscated binaries. It’s free but not open source. While there’s no direct scripting functionality, there is an interface for developing plugins.

**windbg** (Windows; *<https://docs.microsoft.com/en-us/windows-hardware/drivers/debugger/debugger-download-tools>*) This is a Windows debugger distributed by Microsoft that can debug user and kernel mode code, as well as analyze crash dumps.

**Bochs** (Windows, Linux, macOS; *<http://bochs.sourceforge.net>*)

This is a portable PC emulator that runs on most platforms and that you can also use for debugging the emulated code. Bochs is open source and distributed under the GNU LGPL.

### C.3 Disassembly Frameworks

**Capstone** (Windows, Linux, macOS; *[www.capstone-engine.org](http://www.capstone-engine.org)* )

Capstone is not a stand-alone disassembler but rather a free, open source disassembly engine with which you can build your own disassembly tools. It offers a lightweight, multi-architecture API and has bindings in C/C++, Python, Ruby, Lua, and many more languages. The API allows detailed inspection of the properties of disassembled instructions, which is useful if you’re building custom tools. Chapter 8 is entirely devoted to building custom disassembly tools with Capstone.

**distorm3** (Windows, Linux, macOS; *[github.com/gdabah/distorm/](http://github.com/gdabah/distorm/)*)

This is an open source disassembly API for x86 code, aiming at fast disassembly. It offers bindings in several languages, including C, Ruby, and Python.

**udis86** (Linux, macOS; *[github.com/vmt/udis86/](http://github.com/vmt/udis86/)*)

This is a simple, clean, minimalistic, open source, and well-documented disassembly library for x86 code, which you can use to build your own disassembly tools in C.

### C.4 Binary Analysis Frameworks

**angr** (Windows, Linux, macOS; *angr.io*)

Angr is a Python-oriented reverse engineering platform that is used as an API for building your own binary analysis tools. It offers many advanced features, including backward slicing and symbolic execution (discussed in Chapter 12). It’s foremost a research platform, but it’s under active development and has fairly good (and improving) documentation. Angr is free and open source.

**Pin** (Windows, Linux, macOS; *[www.intel.com/software/pintool/](http://www.intel.com/software/pintool/)*)

Pin is a dynamic binary instrumentation engine that allows you to build your own tools that add or modify a binary’s behavior at runtime. (See Chapter 9 for more on dynamic binary instrumentation.) Pin is free but not open source. It’s developed by Intel and only supports Intel CPU architectures, including x86.

**Dyninst** (Windows, Linux; *[www.dyninst.org](http://www.dyninst.org)* )

Like Pin, Dyninst is a dynamic binary instrumentation API, though you can also use it for disassembly. Free and open source, Dyninst is more research oriented than Pin.

**Unicorn** (Windows, Linux, macOS; *[www.unicorn-engine.org](http://www.unicorn-engine.org)* )

Unicorn is a lightweight CPU emulator that supports multiple platforms and architectures, including ARM, MIPS, and x86. Maintained by the Capstone authors, Unicorn has bindings in many languages including C and Python. Unicorn is not a disassembler but a framework for building emulation-based analysis tools.

**libdft** (Linux; *[www.cs.columbia.edu/~vpk/research/libdft/](http://www.cs.columbia.edu/~vpk/research/libdft/)*)

This is a free, open source dynamic taint analysis library used for all the taint analysis examples in Chapter 11. Designed to be fast and easy to use, `libdft` comes in two variants that support byte-granularity shadow memory with either one or eight taint colors.

**Triton** (Windows, Linux, macOS; *[triton.quarkslab.com](http://triton.quarkslab.com)*)

Triton is a dynamic binary analysis framework that supports symbolic execution and taint analysis, among other things. You can see its symbolic execution capabilities in action in Chapter 13. Triton is both free and open source.