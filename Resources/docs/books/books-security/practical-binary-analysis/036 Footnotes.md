## Footnotes

### Introduction

1.*<https://0patch.blogspot.nl/2017/11/did-microsoft-just-manually-patch-their.html>*

2.Some compilers do this more often than others. Visual Studio is especially notorious in terms of mixing code and data.

### Chapter 1

1. There are also languages such as Python and JavaScript in which programs are *interpreted* on the fly rather than compiled as a whole. Sometimes parts of interpreted code are compiled *just in time (JIT)*, as the program executes. This produces binary code in memory, which you can analyze using the techniques discussed in this book. Since analyzing interpreted languages requires language-specific specialized steps, I won’t go into detail on this process.

2. Note that `gcc` optimized the call to `printf` by replacing it with `puts`.

3. There are also position-independent (relocatable) executables, but these show up in `file` as shared objects rather than relocatable files. You can tell them apart from ordinary shared libraries because they have an entry point address.

4. Further reading on LTO is included in Appendix D.

5. In case you’re wondering, the DWARF acronym doesn’t really mean anything. The name was chosen simply because it goes nicely with “ELF” (at least when you’re thinking of mythological creatures).

6. If you’re interested, there are some references about DWARF and PDB in Appendix D.

7. In modern operating systems, where many programs may run at once, each program has its own virtual address space, isolated from the virtual address space of other programs. All memory accesses by user mode applications use *virtual memory addresses (VMAs)* instead of physical addresses. The operating system may move parts of a program’s virtual memory into or out of physical memory as needed, allowing many programs to transparently share a relatively small physical memory space.

### Chapter 2

1. You can find the ELF specification at *<http://refspecs.linuxbase.org/elf/elf.pdf>*, and you can find a description of the differences between 32-bit and 64-bit ELF files at *<https://uclibc.org/docs/elf-64-gen.pdf>*.

2. Note that when analyzing malware, it’s not safe to rely on the contents of the `sh_name` field because the malware may use intentionally misleading section names.

3. You can find an overview and description of all standard ELF sections in the ELF specification at *<http://refspecs.linuxbase.org/elf/elf.pdf>*.

4. In the bash shell, this can be done using the command `export LD_BIND_NOW=1`.

5. The difference is that `.got.plt` is runtime-writable, while `.got` is not if you enable a defense against GOT overwriting attacks called RELRO (relocations read-only). To enable RELRO, you use the `ld` option `-z relro`. RELRO places GOT entries that must be runtime-writable for lazy binding in `.got.plt`, and all others in the read-only `.got` section.

6. You may have noticed another executable section in the `readelf` output, called `.plt.got`. This is an alternative PLT that uses read-only `.got` entries instead of `.got.plt` entries. It’s used if you enable the `ld` option `-z now` at compile time, telling `ld` that you want to use “now binding.” This has the same effect as `LD_BIND_NOW=1`, but by informing `ld` at compile time, you allow it to place GOT entries in `.got` for enhanced security and use 8-byte `.plt.got` entries instead of larger 16-byte `.plt` entries.

### Chapter 3

1. MZ stands for “Mark Zbikowski,” who designed the original MS-DOS executable format.

2. The `int3` padding bytes sometimes serve a dual purpose related to Visual Studio’s compilation option `/hotpatch`, which allows you to dynamically patch code at runtime. When `/hotpatch` is enabled, Visual Studio inserts 5 `int3` bytes before every function, as well as a 2-byte “do nothing” instruction (usually `mov edi, edi`) at the function entry point. To “hot patch” a function, you overwrite the 5 `int3` bytes with a long `jmp` to a patched version of the function and then overwrite the 2-byte do-nothing instruction with a relative jump to that long jump. This has the effect of redirecting the function entry point to the patched function.

### Chapter 4

1. Originally, the BFD acronym stood for “big fucking deal,” which was a response to Richard Stallman’s skepticism regarding the feasibility of implementing such a library. The backronym “binary file descriptor” was proposed later.

2. If you’d rather implement your binary analysis tools in Python, you can find an unofficial Python wrapper for the BFD interface at *<https://github.com/Groundworkstech/pybfd/>*.

### Chapter 5

1. And dangerous! It’s so easy to accidentally overwrite crucial files with `dd` that the letters *dd* have often been said to stand for *destroy disk*. Needless to say, use this command with caution.

2. RC4 is a widely used stream cipher, noted for its simplicity and speed. If you’re interested, you can find more details about it at *<https://en.wikipedia.org/wiki/RC4>*. Note that RC4 is now considered broken and should not be used in any new real-world projects!

3. Remember from Chapter 1 that `objdump` is a simple disassembler that comes with most Linux distributions.

### Chapter 6

1. To maximize code coverage, recursive disassemblers typically assume that the bytes directly after a `call` instruction must also be disassembled since they are the most likely target of an eventual `ret`. Additionally, disassemblers assume that both edges of a conditional jump target valid instructions. Both of these assumptions may be violated in rare cases, such as in deliberately obfuscated binaries.

2. Decompilation tries to translate disassembled code into a high-level language, such as (pseudo-)C.

3. Typically, switch detection heuristics work by looking for jump instructions that compute their target address by taking a fixed base memory address and adding an input-dependent offset to it. The idea is that the base address points to the start of a jump table, and the offset decides which index from the table to use based on the switch input. The table (which is located in one of the binary’s data or code sections) is then scanned for valid jump destinations, thus resolving all the different cases that the jump may target.

4. *<http://www.ollydbg.de/>*

5. *<http://lcamtuf.coredump.cx/afl/>*

6. You can also mix concrete and emulated symbolic execution; I’ll get to that in Chapter 12.

7. When a function F₁ ends with a call to another function F₂, this is a *tail call*. Tail calls are often optimized by compilers. Instead of using a `call` instruction to call F₂, the compiler uses a `jmp`. This way, when F₂ ends, it can return directly to the caller of F₁. This means that F₁ never needs to explicitly return, saving the need for one `ret` instruction. Because a regular `jmp` is used, tail calls prevent function detectors from easily recognizing F₂ as a function.

8. A prototype tool is available at *<https://www.vusec.net/projects/function-detection/>*.

9. Unless there are instructions that compute the address of the function in a deliberately obfuscated way, such as in malicious programs.

10. Research on automatic data structure detection typically uses dynamic analysis to infer the data types of objects in memory based on the way they’re accessed in the code. You can find further reading here: *<https://www.isoc.org/isoc/conferences/ndss/11/pdf/5_1.pdf>*.

11. Both the decompiler and the company that develops IDA are called Hex-Rays.

12. *<http://www.valgrind.org/>*

13. *<https://github.com/trailofbits/mcsema/>*

14. This example was generated with PyVex: *<https://github.com/angr/pyvex>*. The VEX language itself is documented in the header file *<https://github.com/angr/vex/blob/dev/pub/libvex_ir.h>*.

15. These terms are borrowed from the world of compiler theory.

16. I won’t go into details on these techniques in this book since you won’t need them. However, if you’re interested, the book *Compilers: Principles, Techniques & Tools* (Addison-Wesley, 2014) by Aho et al. deals with the topic in depth.

17. *<http://angr.io/>*

18. ASLR randomizes the runtime locations of code and data to make these harder for attackers to find and abuse.

### Chapter 7

1. You can look this up in the Intel manual or a reference like *<http://ref.x86asm.net>*.

2. Because the section header table is at the end of the binary, you could easily add a new entry to it without having to relocate anything. However, since you’re overwriting a program header anyway, you may as well overwrite the headers for the sections contained in that segment, too.

3. Sometimes it doesn’t exist, for instance, if the binary is compiled with a compiler other than `gcc`. When using a version of `gcc` older than v4.7, the `.init_array` and `.fini_array` sections may instead be called `.ctors` and `.dtors`, respectively.

### Chapter 8

1. If you’re still not convinced, download some crackme programs with overlapping instructions from a site like *crackmes.cf* and try reversing them!

2. Obfuscators often try to confuse static disassemblers by including bogus code paths that are not actually reachable at runtime. They do this by constructing branches around predicates that are either always true or always false, without this being obvious to the disassembler. Such *opaque predicates* are typically built around number-theoretical identities or pointer-aliasing problems.

3. *<http://www.capstone-engine.org/>*

4. To truly generalize the disassembler, you would check the loaded binary’s type using the `arch` and `bits` fields in the `Binary` class provided by the loader. Then select the proper Capstone parameters based on the type. To keep things simple, this example supports only a single hard-coded architecture.

5. More modern incarnations of ROP exploit not only return instructions but also other indirect branches, such as indirect jumps and calls. For our purposes, we’ll consider only traditional ROP gadgets.

6. For simplicity, I’ve ignored the opcodes `0xc2`, `0xca`, and `0xcb`, which correspond to other, less common types of return instructions.

7. In reality, you might also be interested in gadgets that contain indirect calls because they can be used to call library functions like `execve`. While it’s straightforward to extend the gadget finder to also look for such gadgets, I left them out here for simplicity.

### Chapter 9

1. For simplicity, this ignores tail calls, which use `jmp` instructions instead of `call`.

2. This method of defending against control-flow hijacking is called *control-flow integrity (CFI)*. There’s a lot of active research on how to implement CFI efficiently and make the expected target sets as accurate as possible.

3. Packing is a popular type of obfuscation, as I’ll explain later in this chapter.

4. This is not necessarily true for malicious binaries because they sometimes use tricks to detect the DBI platform and then intentionally exhibit different behavior than they normally would.

5. Some research instrumentation engines, like BIRD, use a hybrid approach that’s based on SBI with a lightweight runtime-monitoring layer that checks for and corrects instrumentation errors.

6. PEBIL is available at *<https://github.com/mlaurenzano/PEBIL/>*, and there’s a corresponding research paper at *<https://www.sdsc.edu/pmac/publications/laurenzano2010pebil.pdf>*.

7. You can find Dyninst and research papers on Dyninst at *<http://www.dyninst.org/>*.

8. You can download Pin and find documentation at <https://software.intel.com/en-us/articles/pin-a-binary-instrumentation-tool-downloads/>.

9. Pin also offers a *probe mode* that instruments all code at once and then runs the application natively instead of relying on the JIT engine. Probe mode is faster than JIT mode, but you can only use a limited subset of the API. Because probe mode only supports instrumentation at function (`RTN`) granularity, which requires symbols, I’ll focus on JIT mode in this chapter. If you’re interested, you can read more about probe mode in Pin’s documentation.

10. The capital *.H* in *pin.H* is a naming convention that indicates it’s a C++ header file, not a standard C header file.

11. The */bin/true* program simply does nothing and then exits successfully.

12. There are also advanced packers that never fully extract the packed binary but continuously extract and repack small parts of the code as needed for the execution. These are out of scope for our purposes.

13. *<https://upx.github.io/>*

14. *<http://www.aspack.com/>*

15. To choose which file to analyze in detail, you’ll normally have to do some preliminary investigation using utilities such as `file`, `strings`, `xxd`, and `objdump` to get an idea of what each file contains.

### Chapter 10

1. In this example, I’ve set `payload` such that Heartbleed will leak exactly enough bytes to reveal the secret key. In reality, an attacker would set it to the maximum value of 65535 to leak as much information as possible.

2. Note that if the second operand were also tainted like the first, then the attacker would have full control of the output.

### Chapter 11

1. *<https://www.cs.columbia.edu/~vpk/research/libdft/libdft-3.1415alpha.tar.gz>*

2. These instruction classes are defined in the original `libdft` paper at *<http://nsl.cs.columbia.edu/papers/2012/libdft.vee12.pdf>*.

3. These are the paths on the VM. They may differ in other Linux distributions.

4. On the VM, you can find it in */home/binary/libdft/pin-2.13-61206-gcc.4.4.7-linux/extras/ xed2-ia32/include/xed-iclass-enum.h*.

### Chapter 12

1. *angr.io*

2. *s2e.systems*

3. *<https://klee.github.io>*

4. For more in-depth reading on SMT, refer to the literature in Appendix D.

5. For example, see *<https://yurichev.com/writings/SAT_SMT_by_example.pdf>*.

### Chapter 13

1. *<https://angr.io/>*

2. *s2e.systems*

3. *<https://klee.github.io/>*

4. To disable building ASTs for nonsymbolic registers and memory locations, you can enable Triton’s `ONLY_ON_SYMBOLIZED` mode, which may improve performance.

5. There are also other variants of `setConcreteMemoryValue` that allow you to set multiple bytes at once, but I won’t use them here. If you’re interested, refer to the Triton documentation at *<https://triton.quarkslab.com/documentation/doxygen/classtriton_1_1API.html>*.

6. More completely, the first six arguments are passed in the `rdi`, `rsi`, `rdx`, `rcx`, `r8`, and `r9` registers, while additional arguments are passed on the stack.

7. Even when called by a nonprivileged user, `setuid root` binaries run with `root` privileges. This allows normal users to run programs that perform privileged operations, such as setting up raw network sockets or changing the */etc/passwd* file.

8. Note that you can achieve a similar effect without restarting the program by using Triton’s snapshot engine. For example, see the password-cracking example shipped with Triton at *~/triton/pin-2.14-71313-gcc.4.4.7-linux/source/tools/Triton/src/examples/pin/inject_model_with \_snapshot.py*.

### Appendix A

1. The stack start address is chosen by the operating system.

2. This is specified in a standard called the System V application binary interface (ABI).

### Appendix B

1. *<ftp://ftp2.uk.freebsd.org/sites/downloads.sourceforge.net/e/el/elftoolchain/Documentation/libelf-by-example/20120308/libelf-by-example.pdf>*

2. Recall from Chapter 2 that index 0 in the section header table is a “dummy” entry.

### Appendix C

1. Cygwin is a free tool suite that provides a Unix-like environment on Windows. It’s available at *<https://www.cygwin.com/>*.