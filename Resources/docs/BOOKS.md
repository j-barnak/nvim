# :Docs Books

Every title the `:Docs` → Books menu offers (RISC-V included for completeness;
those 25 sit behind the top-level "RISC-V (manuals)" entry instead). Generated
by `Resources/tools/books_inventory.py` from the `BOOKS` and `WEB_BOOKS` tables
in `lua/config/docs.lua`; the Keep column comes from `books_decisions.tsv`.

Two kinds of book:

- **Chapter books**: an epub/pdf or a markdown repo converted once into numbered
  chapter files under `Resources/docs/books/<module>/<slug>/` (the four rust-lang
  mdBooks under `Resources/docs/rust/<repo>/src`). Browsed with fd/find.
- **Web books**: a frozen site or article series, `Resources/docs/<key>/index.tsv`
  (`title<TAB>url` rows) whose pages are `Resources/docs/.webcache/<sha256(url)>.txt`,
  shared between books.

## Chapter books (epub / pdf / markdown repo) — 179

### C (`books-c`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 1 | Expert C Programming | epub | `expert-c-programming` | 16 |  |
| 2 | Modern C (Gustedt) | pdf | `modern-c` | 27 |  |
| 3 | Effective C (Seacord) | pdf | `effective-c` | 18 |  |
| 4 | Managing Projects with GNU Make (3e) | pdf | `managing-projects-with-gnu-make` | 27 |  |

### C++ (`books-cpp`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 5 | Modern C++ Design (Alexandrescu) | pdf | `modern-cpp-design` | 17 |  |
| 6 | Beautiful C++ (30 Core Guidelines) | pdf | `beautiful-c-30-core-guidelines` | 40 |  |
| 7 | C++ Concurrency in Action | pdf | `c-concurrency-in-action` | 18 |  |
| 8 | C++ Move Semantics (The Complete Guide) | pdf | `c-move-semantics-the-complete-guide` | 22 |  |
| 9 | C++ Initialization Story | epub | `c-initialization-story` | 22 |  |
| 10 | C++ Templates: The Complete Guide (2e) | pdf | `c-templates-the-complete-guide-2e` | 41 |  |
| 11 | Effective Modern C++ | epub | `effective-modern-c` | 15 |  |
| 12 | Elements of Programming | pdf | `elements-of-programming` | 20 |  |
| 13 | API Design for C++ (Reddy) | pdf | `api-design-for-cpp` | 26 |  |
| 14 | Professional CMake (Scott) | pdf | `professional-cmake` | 44 |  |

### Rust (`books-rust`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 15 | Rust Under the Hood (Ahluwalia) | pdf | `rust-under-the-hood` | 27 |  |
| 16 | Command-Line Rust | epub | `command-line-rust` | 22 |  |
| 17 | Programming Rust (2e) | epub | `programming-rust-2e` | 30 |  |
| 18 | Rust in Action | epub | `rust-in-action` | 22 |  |
| 19 | Rust for Rustaceans (Gjengset) | pdf | `rust-for-rustaceans` | 18 |  |
| 20 | The Rust Programming Language (the book) | mdbook | `rust/book` | 112 |  |
| 21 | The Rustonomicon (unsafe Rust) | mdbook | `rust/nomicon` | 64 |  |
| 22 | Rust by Example | mdbook | `rust/rust-by-example` | 198 |  |
| 23 | Learn Rust With Entirely Too Many Linked Lists | mdbook | `rust/too-many-lists` | 59 |  |
| 24 | Zero to Production in Rust | pdf | `zero-to-production-in-rust` | 14 |  |

### Assembly (`books-asm`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 25 | Modern x86 Assembly Language Programming | pdf | `modern-x86-assembly-language-programming` | 22 |  |
| 26 | The Art of ARM Assembly, Volume 1 | pdf | `the-art-of-arm-assembly-volume-1` | 29 |  |
| 27 | DisARMing Code | pdf | `disarming-code` | 17 |  |
| 28 | Blue Fox: Arm Assembly Internals and Reverse Engineering | pdf | `blue-fox-arm-assembly-internals` | 17 |  |
| 29 | Professional Assembly Language (Blum) | pdf | `professional-assembly-language` | 20 |  |

### Operating Systems (`books-os`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 30 | TCP/IP Illustrated, Volume 1 (Fall & Stevens, 2e) | pdf | `tcp-ip-illustrated-vol-1` | 22 |  |
| 31 | Distributed Systems (Tanenbaum & van Steen, 4e) | pdf | `distributed-systems` | 14 |  |
| 32 | Operating Systems: Design and Implementation (Tanenbaum, 3e) | pdf | `operating-systems-design-and-implementation` | 9 |  |
| 33 | The Design and Implementation of the FreeBSD OS | pdf | `the-design-and-implementation-of-the-freebsd-operating-system` | 19 |  |
| 34 | An Introduction to Computer Networks (Dordal) | pdf | `an-introduction-to-computer-networks` | 28 |  |
| 35 | Writing a Bootloader from Scratch (CMU 15-410) | pdf | `writing-a-bootloader-from-scratch-cmu-15-410` | 13 |  |
| 36 | Operating Systems: Three Easy Pieces | pdf | `operating-systems-three-easy-pieces` | 62 |  |
| 37 | xv6 (x86) | epub | `xv6-x86` | 12 |  |
| 38 | Advanced Programming in the UNIX Environment | pdf | `advanced-programming-in-the-unix-environment` | 31 |  |
| 39 | System Programming in Linux | epub | `system-programming-in-linux` | 36 |  |
| 40 | Unix Network Programming | pdf | `unix-network-programming` | 43 |  |
| 41 | Programming with POSIX Threads | pdf | `programming-with-posix-threads` | 12 |  |
| 42 | The Little Book of Semaphores | pdf | `the-little-book-of-semaphores` | 13 |  |
| 43 | Is Parallel Programming Hard, And, If So, What Can You Do About It? | pdf | `is-parallel-programming-hard` | 31 |  |

### Compilers (`books-compilers`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 44 | Linkers and Loaders | pdf | `linkers-and-loaders` | 14 |  |
| 45 | Program Analysis (CMU 17-355) | pdf | `program-analysis-cmu` | 17 |  |
| 46 | Static Program Analysis (Moller & Schwartzbach) | pdf | `static-program-analysis` | 16 |  |
| 47 | How To Write Shared Libraries | pdf | `how-to-write-shared-libraries` | 7 |  |
| 48 | Crafting Interpreters | epub | `crafting-interpreters` | 41 |  |
| 49 | Writing a C Compiler | epub | `writing-a-c-compiler` | 35 |  |
| 50 | SSA-based Compiler Design | pdf | `ssa-based-compiler-design` | 33 |  |
| 51 | Talking Compilers with ChatGPT | pdf | `talking-compilers-with-chatgpt` | 27 |  |
| 52 | Introduction to Static Analysis | pdf | `introduction-to-static-analysis` | 18 |  |
| 53 | Modern Compiler Implementation in C | pdf | `modern-compiler-implementation-in-c` | 28 |  |
| 54 | Essentials of Compilation (Python) | pdf | `essentials-of-compilation` | 17 |  |
| 55 | SAT/SMT by Example (Yurichev) | pdf | `sat-smt-by-example` | 29 |  |
| 56 | Engineering a Compiler (Cooper & Torczon) | pdf | `engineering-a-compiler` | 20 |  |

### Containers (`books-container`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 57 | Build Your Own Docker (CodeCrafters) | md | `build-your-own-docker` | 7 | keep — CodeCrafters course |

### Databases (`books-db`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 58 | Build Your Own SQLite (CodeCrafters) | md | `build-your-own-sqlite` | 10 | keep — CodeCrafters course |
| 59 | Database Internals | epub | `database-internals` | 27 |  |
| 60 | Designing Data-Intensive Applications (2e) | epub | `designing-data-intensive-applications-2e` | 25 |  |

### Linux / Drivers (`books-linux`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 61 | BPF Performance Tools (Gregg) | pdf | `bpf-performance-tools` | 24 |  |
| 62 | Systems Performance (Gregg, 2e) | pdf | `systems-performance` | 25 |  |
| 63 | Performance Analysis and Tuning on Modern CPUs (2e) | pdf | `performance-analysis-and-tuning-on-modern-cpus` | 21 |  |
| 64 | Learning eBPF | pdf | `learning-ebpf` | 14 |  |
| 65 | The Linux Programming Interface | pdf | `the-linux-programming-interface` | 74 |  |
| 66 | eBPF Developer Tutorial (eunomia) | md | `ebpf-developer-tutorial` | 68 |  |
| 67 | Linux Insides (0xAX) | md | `linux-insides` | 79 | keep |
| 68 | Linux Device Driver Development (Madieu) | epub | `linux-device-driver-development-madieu` | 26 |  |
| 69 | Linux Device Drivers, 3rd Edition | epub | `linux-device-drivers-3rd-edition` | 26 |  |
| 70 | The Linux Memory Manager | epub | `the-linux-memory-manager` | 21 |  |
| 71 | Bootlin: Embedded Linux (BBB labs) | epub | `bootlin-embedded-linux-bbb-labs` | 14 |  |
| 72 | Bootlin: Linux Kernel (slides) | epub | `bootlin-linux-kernel-slides` | 23 |  |
| 73 | Bootlin: Embedded Linux (QEMU labs) | epub | `bootlin-embedded-linux-qemu-labs` | 15 |  |
| 74 | UNIX and Linux System Administration Handbook (Nemeth et al.) | pdf | `unix-and-linux-system-administration-handbook` | 42 |  |
| 75 | Linux Kernel Debugging (Billimoria) | pdf | `linux-kernel-debugging` | 18 |  |
| 76 | Linux Kernel Programming (Billimoria, 2e) | pdf | `linux-kernel-programming` | 16 |  |
| 77 | Linux Kernel Programming Part 2: Char Device Drivers (Billimoria) | pdf | `linux-kernel-programming-part-2` | 12 |  |

### Algorithms (`books-algo`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 78 | Algorithms Illuminated, Part 2 | epub | `algorithms-illuminated-part-2` | 11 |  |
| 79 | The Algorithm Design Manual | pdf | `the-algorithm-design-manual` | 28 |  |
| 80 | Introduction to Algorithms (CLRS, 3e) | pdf | `introduction-to-algorithms-clrs` | 39 |  |
| 81 | Open Data Structures (Morin, Python edition) | pdf | `open-data-structures` | 19 |  |

### Security (`books-security`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 82 | Gray Hat Hacking (6th ed) | pdf | `gray-hat-hacking-6e` | 18 |  |
| 83 | The Art of Mac Malware, Vol. 1 (Wardle) | pdf | `the-art-of-mac-malware` | 18 |  |
| 84 | The Art of Mac Malware, Vol. 2 (Wardle) | pdf | `the-art-of-mac-malware-vol2` | 21 |  |
| 85 | Rootkits and Bootkits (Matrosov et al.) | pdf | `rootkits` | 26 |  |
| 86 | File System Forensic Analysis (Carrier) | pdf | `file-system-forensic-analysis` | 25 |  |
| 87 | From Day Zero to Zero Day | pdf | `from-day-zero-to-zero-day` | 18 |  |
| 88 | Android Security Internals (Elenkov) | pdf | `android-security-internals` | 17 |  |
| 89 | The Art of Memory Forensics | pdf | `the-art-of-memory-forensics` | 38 |  |
| 90 | Attacking Network Protocols (Forshaw) | pdf | `attacking-network-protocols` | 14 |  |
| 91 | Practical Binary Analysis | epub | `practical-binary-analysis` | 37 |  |
| 92 | Linternals + Kernel Exploitation (sam4k) | md | `linternals-sam4k` | 12 | keep |
| 93 | Nightmare: Binary Exploitation Course | md | `nightmare-binary-exploitation` | 136 | keep |
| 94 | Heap Exploitation (Dhaval Kapil) | md | `heap-exploitation-dhaval-kapil` | 22 | keep |
| 95 | ir0nstone: Binary Exploitation Notes | md | `ir0nstone-binary-exploitation` | 121 | keep |
| 96 | Serious Cryptography (2e) | epub | `serious-cryptography-2e` | 30 |  |
| 97 | An Introduction to Mathematical Cryptography | pdf | `an-introduction-to-mathematical-cryptography` | 13 |  |
| 98 | The Joy of Cryptography (Rosulek) | pdf | `the-joy-of-cryptography` | 18 |  |
| 99 | Cryptography Engineering (Ferguson, Schneier, Kohno) | pdf | `cryptography-engineering` | 34 |  |
| 100 | Fuzzing Against the Machine | pdf | `fuzzing-against-the-machine` | 18 |  |
| 101 | Secure Coding in C and C++ (2e) | pdf | `secure-coding-in-c-and-cpp` | 14 |  |
| 102 | Reverse Engineering for Beginners (Yurichev) | pdf | `reverse-engineering-for-beginners` | 55 |  |
| 103 | The Art of Software Security Assessment | pdf | `the-art-of-software-security-assessment` | 22 |  |
| 104 | Surreptitious Software: Obfuscation, Watermarking, and Tamperproofing | pdf | `surreptitious-software` | 15 |  |
| 105 | Microcontroller Exploits (Goodspeed) | pdf | `microcontroller-exploits` | 29 |  |
| 106 | Reversing: Secrets of Reverse Engineering (Eilam) | pdf | `reversing-secrets-of-reverse-engineering` | 16 |  |
| 107 | A Practical Guide to TPM 2.0 (Arthur, Challener, Goldman) | pdf | `practical-guide-to-tpm-2` | 26 |  |

### Architecture (`books-arch`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 108 | Parallel and High Performance Computing (Robey, Zamora) | md | `parallel-high-performance-computing` | 29 |  |
| 109 | Hardware and Software Support for Virtualization | pdf | `hardware-software-support-virtualization` | 14 |  |
| 110 | Computer Architecture: A Quantitative Approach (H&P) | pdf | `computer-architecture-a-quantitative-approach` | 23 |  |
| 111 | Computer Organization and Design (P&H) | pdf | `computer-organization-and-design` | 15 |  |
| 112 | Modern Processor Design (Shen & Lipasti) | pdf | `modern-processor-design` | 14 |  |
| 113 | The Garbage Collection Handbook | pdf | `the-garbage-collection-handbook` | 26 |  |
| 114 | A Primer on Memory Consistency and Cache Coherence | pdf | `a-primer-on-memory-consistency-and-cache-coherence` | 15 |  |
| 115 | Shared-Memory Synchronization | pdf | `shared-memory-synchronization` | 12 |  |
| 116 | The Art of Multiprocessor Programming | pdf | `the-art-of-multiprocessor-programming` | 24 |  |
| 117 | What Every Programmer Should Know About Memory | pdf | `what-every-programmer-should-know-about-memory` | 8 |  |
| 118 | Hacker's Delight (2nd Edition) | pdf | `hackers-delight` | 27 |  |
| 119 | Optimizing Software in C++ (Agner Fog) | pdf | `optimizing-software-in-cpp-agner-fog` | 20 |  |
| 120 | Optimizing Subroutines in Assembly (Agner Fog) | pdf | `optimizing-subroutines-in-assembly-agner-fog` | 20 |  |
| 121 | The Microarchitecture of Intel, AMD, and VIA CPUs (Agner Fog) | pdf | `microarchitecture-of-cpus-agner-fog` | 31 |  |
| 122 | Instruction Tables (Agner Fog) | pdf | `instruction-tables-agner-fog` | 43 |  |
| 123 | Calling Conventions (Agner Fog) | pdf | `calling-conventions-agner-fog` | 18 |  |
| 124 | Computer Systems: A Programmer's Perspective (CSAPP, 3e) | pdf | `computer-systems-programmers-perspective` | 20 |  |
| 125 | Digital Design and Computer Architecture (Harris, 2e) | pdf | `digital-design-and-computer-architecture` | 12 |  |
| 126 | x86 Instruction Set Architecture (Shanley) | pdf | `x86-isa-shanley` | 40 |  |

### RISC-V (`books-riscv`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 127 | The RISC-V Instruction Set Manual | pdf | `the-risc-v-instruction-set-manual` | 43 |  |
| 128 | RISC-V SBI (Supervisor Binary Interface) | pdf | `riscv-sbi` | 25 |  |
| 129 | RISC-V Advanced Interrupt Architecture (AIA) | pdf | `riscv-aia` | 9 |  |
| 130 | RISC-V PLIC (Platform-Level Interrupt Controller) | pdf | `riscv-plic` | 10 |  |
| 131 | RISC-V Fast Interrupts (CLIC) | pdf | `riscv-fast-interrupt` | 7 |  |
| 132 | RISC-V IOMMU | pdf | `riscv-iommu` | 11 |  |
| 133 | RISC-V Debug Specification | pdf | `riscv-debug` | 11 |  |
| 134 | RISC-V Processor Trace (E-Trace) | pdf | `riscv-trace` | 15 |  |
| 135 | RISC-V Supervisor Domains (Smmtt) | pdf | `riscv-smmtt` | 9 |  |
| 136 | RISC-V Platform Security Model | pdf | `riscv-security-model` | 7 |  |
| 137 | RISC-V Control-Flow Integrity (CFI) | pdf | `riscv-cfi` | 9 |  |
| 138 | RISC-V CHERI | pdf | `riscv-cheri` | 26 |  |
| 139 | RISC-V UEFI Protocol | pdf | `riscv-uefi` | 9 |  |
| 140 | RISC-V Boot and Runtime Services (BRS) | pdf | `riscv-brs` | 10 |  |
| 141 | RISC-V ACPI FFH | pdf | `riscv-acpi-ffh` | 6 |  |
| 142 | RISC-V Platform Management Interface (RPMI) | pdf | `riscv-rpmi` | 7 |  |
| 143 | RISC-V Server Platform | pdf | `riscv-server-platform` | 6 |  |
| 144 | RISC-V Server SoC | pdf | `riscv-server-soc` | 8 |  |
| 145 | RISC-V Profiles | pdf | `riscv-profiles-spec` | 6 |  |
| 146 | RISC-V ELF psABI (Calling Convention) | pdf | `riscv-psabi` | 16 |  |
| 147 | RISC-V Assembly Programmer's Manual | pdf | `riscv-asm-manual` | 31 |  |
| 148 | RISC-V C API | pdf | `riscv-c-api` | 6 |  |
| 149 | RISC-V Cryptography Extensions | pdf | `riscv-crypto` | 8 |  |
| 150 | RISC-V Semihosting | pdf | `riscv-semihosting` | 9 |  |
| 151 | RISC-V Glossary | pdf | `riscv-glossary` | 7 |  |

### Hardware (`books-hardware`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 152 | Getting Started with FPGAs (Merrick) | pdf | `getting-started-with-fpgas` | 17 |  |
| 153 | Retrocomputing with Clash | pdf | `retrocomputing-with-clash` | 22 |  |

### Firmware (`books-firmware`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 154 | Mastering STM32 (Noviello) | pdf | `mastering-stm32` | 34 |  |
| 155 | Beyond BIOS | epub | `beyond-bios` | 23 |  |
| 156 | Embedded Systems: Introduction to Arm Cortex-M Microcontrollers (Valvano) | pdf | `embedded-systems-arm-cortex-m-valvano` | 18 |  |
| 157 | Embedded Systems with ARM Cortex-M (Assembly and C, Zhu) | pdf | `embedded-systems-arm-cortex-m-zhu` | 36 |  |
| 158 | The Definitive Guide to ARM Cortex-M0 and Cortex-M0+ (Yiu) | pdf | `arm-cortex-m0-definitive-guide` | 35 |  |
| 159 | Programming Embedded Systems (Barr, Massa) | pdf | `programming-embedded-systems` | 24 |  |
| 160 | Making Embedded Systems (Elecia White, 2e) | pdf | `making-embedded-systems` | 17 |  |

### Windows (`books-windows`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 161 | Windows Internals, Part 1 (7e) | pdf | `windows-internals-part-1` | 10 |  |
| 162 | Windows Internals, Part 2 (7e) | pdf | `windows-internals-part-2` | 9 |  |
| 163 | Windows Kernel Programming (2e) | pdf | `windows-kernel-programming-2e` | 11 |  |

### Haskell (`books-haskell`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 164 | Haskell Programming from First Principles | pdf | `haskell-programming-from-first-principles` | 33 |  |
| 165 | Programming in Haskell (2e) | epub | `programming-in-haskell-2e` | 31 |  |
| 166 | Algorithm Design with Haskell (Bird, Gibbons) | pdf | `algorithm-design-with-haskell` | 27 |  |
| 167 | Parallel and Concurrent Programming in Haskell (Marlow) | epub | `parallel-concurrent-haskell` | 26 |  |

### OCaml (`books-ocaml`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 168 | More OCaml: Algorithms, Methods, and Diversions | epub | `more-ocaml-algorithms-methods-and-diversions` | 28 |  |
| 169 | Learn Programming with OCaml | pdf | `learn-programming-with-ocaml` | 16 |  |

### Python (`books-python`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 170 | Fluent Python (2nd Edition) | pdf | `fluent-python` | 33 |  |
| 171 | Python Crash Course | pdf | `python-crash-course` | 31 |  |
| 172 | Dead Simple Python | pdf | `dead-simple-python` | 33 |  |

### Java (`books-java`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 173 | Java Concurrency in Practice | pdf | `java-concurrency-in-practice` | 24 |  |

### JavaScript (`books-js`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 174 | Eloquent JavaScript (4th Edition) | pdf | `eloquent-javascript-4e` | 24 |  |
| 175 | Learning TypeScript (Goldberg) | pdf | `learning-typescript` | 24 |  |

### Graphics (`books-graphics`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 176 | OpenGL SuperBible | pdf | `opengl-superbible` | 26 |  |

### Version Control (`books-vcs`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 177 | Build Your Own Git (CodeCrafters) | md | `build-your-own-git` | 8 | keep — CodeCrafters course |
| 178 | Building Git | pdf | `building-git` | 41 |  |

### Debugging (`books-debugging`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 179 | Building a Debugger | pdf | `building-a-debugger` | 27 |  |

## Frozen web books (`WEB_BOOKS`) — 82

| # | Title | Key | Entries | Source | Keep? |
|---|---|---|---|---|---|
| 1 | Hypervisor From Scratch | `rayanfam` | 8 | rayanfam.com | keep |
| 2 | Kernel CTF | `kernel-ctf` | 10 | 0x434b.dev, arxiv.org, census-labs.com … | keep |
| 3 | Learn C++ (learncpp.com) | `learncpp` | 356 | learncpp.com | keep |
| 4 | Kernel Internals | `kernel-internals` | 482 | kernel-internals.org | keep |
| 5 | Linux Kernel Labs | `kernel-labs` | 27 | linux-kernel-labs.github.io | keep |
| 6 | Making Our Own Executable Packer | `packer` | 18 | fasterthanli.me | keep |
| 7 | Rust Atomics and Locks | `atomics` | 13 | marabos.nl |  |
| 8 | SLUB | `slub` | 14 | argp.github.io, blogs.oracle.com, dangokyo.wordpress.com … | keep |
| 9 | Snapshot Fuzzer | `snapshot-fuzzer` | 13 | doar-e.github.io, h0mbre.github.io | keep |
| 10 | The Astra Book | `astra` | 7 | 2ourc3.com, lcamtuf.blogspot.com, lcamtuf.coredump.cx … | keep |
| 11 | Linux Kernel Exploitation Dojo | `kernel-exploitation` | 77 | 0x434b.dev, 0xten.gitbook.io, a13xp0p0v.github.io … | keep |
| 12 | LLVM Tutorial (Kaleidoscope + ORC JIT) | `llvm-tutorial` | 15 | llvm.org | keep |
| 13 | Web Browser Engineering | `browser-engineering` | 24 | browser.engineering | keep |
| 14 | LearnOpenGL | `learnopengl` | 72 | learnopengl.com | keep |
| 15 | Hypervisor Development (revers.engineering) | `revers-hypervisor` | 8 | revers.engineering | keep |
| 16 | ELF (Series) | `elf-series` | 6 | intezer.com, lwn.net, nathanotterness.com | keep |
| 17 | glibc malloc | `glibc-malloc` | 3 | azeria-labs.com, sploitfun.wordpress.com | keep |
| 18 | JavaScript Exploitation | `javascript-exploitation` | 12 | jhalon.github.io, madstacks.dev, phrack.org | keep |
| 19 | Bootloader (Articles) | `bootloader-articles` | 9 | 0xc0ffee.netlify.app, en.wikibooks.org, interrupt.memfault.com … | keep |
| 20 | Binary Exploitation Dojo | `binary-exploitation-dojo` | 49 | 0x434b.dev, 4xura.com, axcheron.github.io … | keep |
| 21 | Learn Makefiles | `makefile-tutorial` | 19 | makefiletutorial.com | keep |
| 22 | Advanced Bash-Scripting Guide | `abs` | 140 | tldp.org | keep |
| 23 | Professional C++ (studyplan.dev) | `studyplan-pro-cpp` | 128 | studyplan.dev | keep |
| 24 | Data Structures & Algorithms (studyplan.dev) | `studyplan-dsa` | 69 | studyplan.dev | keep |
| 25 | Learn You a Haskell for Great Good! | `lyah` | 14 | learnyouahaskell.github.io |  |
| 26 | Software Foundations: Logic Foundations | `software-foundations-lf` | 21 | softwarefoundations.cis.upenn.edu | keep |
| 27 | Write You a Haskell (Stephen Diehl) | `write-you-a-haskell` | 10 | smunix.github.io |  |
| 28 | Linux Kernel Module Programming Guide | `lkmpg` | 1 | sysprog21.github.io | keep |
| 29 | High Performance Browser Networking (Grigorik) | `hpbn` | 18 | hpbn.co | keep |
| 30 | OCaml by Example | `ocaml-byexample` | 31 | o1-labs.github.io |  |
| 31 | Beautiful Racket | `beautiful-racket` | 118 | beautifulracket.com |  |
| 32 | Cryptopals Crypto Challenges | `cryptopals` | 57 | cryptopals.com | keep |
| 33 | CryptoHack Courses | `cryptohack` | 64 | cryptohack.org |  |
| 34 | CMU 15-411 Compiler Design | `cmu-15411` | 41 | cs.cmu.edu |  |
| 35 | CMU 15-445 Database Systems | `cmu-15445` | 60 | 15445.courses.cs.cmu.edu |  |
| 36 | MIT 6.5950 Secure Hardware Design | `mit-shd` | 34 | people.csail.mit.edu, shd.mit.edu |  |
| 37 | MIT 6.824 Distributed Systems | `mit-6824` | 43 | pdos.csail.mit.edu |  |
| 38 | Wisconsin CS/ECE 752 Advanced Computer Architecture | `wisc-cs752` | 36 | cs.utah.edu, cs.wisc.edu, pages.cs.wisc.edu … |  |
| 39 | LazyFoo SDL3 Tutorials | `lazyfoo-sdl3` | 21 | lazyfoo.net | keep |
| 40 | QEMU Internals (Airbus Seclab) | `qemu-internals` | 15 | airbus-seclab.github.io | keep |
| 41 | JIT (Series) | `jit-series` | 4 | eli.thegreenplace.net, nullprogram.com | keep |
| 42 | Bochs Documentation | `bochs-docs` | 99 | bochs.sourceforge.io |  |
| 43 | EmuDev (Emulator Development reading list) | `emudev` | 43 | alexaltea.github.io, andrewkelley.me, bheisler.github.io … | keep |
| 44 | The C10K Problem (Kegel) | `c10k` | 1 | kegel.com | keep |
| 45 | BashGuide + Bash FAQ (Greg's Wiki) | `bashguide` | 13 | mywiki.wooledge.org | keep |
| 46 | The Fuzzing Book (fuzzingbook.org) | `fuzzingbook` | 30 | fuzzingbook.org | keep |
| 47 | Fuzzing Made Easy (SRLabs) | `fuzzing-made-easy` | 7 | srlabs.de | keep |
| 48 | Fuzzing BitDefender's AntiVirus Engine (stackbits) | `fuzzing-bitdefender` | 2 | stackbits.eu | keep |
| 49 | AFL++ Under The Hood (ritsec + core.gen.tr) | `afl-under-the-hood` | 17 | blog.ritsec.club, core.gen.tr | keep |
| 50 | Syzkaller Articles (Collabora, xairy, LWN, ...) | `syzkaller-articles` | 9 | collabora.com, lwn.net, slavamoskvin.com … | keep |
| 51 | Namespaces in operation (LWN, Kerrisk) | `namespaces-lwn` | 9 | lwn.net | keep |
| 52 | Control groups (LWN, Neil Brown) | `cgroups-lwn` | 7 | lwn.net | keep |
| 53 | LWN Kernel Index (categorized reference) | `lwn-index` | 5988 | lwn.net | keep |
| 54 | The Modern JavaScript Tutorial (javascript.info) | `javascript-info` | 175 | javascript.info |  |
| 55 | Testing Handbook (Trail of Bits, appsec.guide) | `testing-handbook` | 70 | appsec.guide | keep |
| 56 | LibAFL (Articles) | `fuzzing-101-libafl` | 12 | aflplus.plus, andreafioraldi.github.io, atredis.com … | keep |
| 57 | AFL++ Articles | `aflpp-articles` | 20 | aflplus.plus, airbus-seclab.github.io, appsec.guide … | keep |
| 58 | What The Fuzz (wtf) Articles | `wtf-articles` | 5 | blog.ret2.io, blog.thalium.re, doar-e.github.io … | keep |
| 59 | Awesome Databases (papers + storage) | `awesome-databases` | 28 | bailis.org, cockroachlabs.com, db.in.tum.de … |  |
| 60 | Coding for SSDs (codecapsule) | `coding-for-ssds` | 6 | codecapsule.com | keep |
| 61 | SICP (JavaScript edition) | `sicp-js` | 129 | sourceacademy.org |  |
| 62 | Algorithms (Sedgewick & Wayne, algs4) | `algs4` | 36 | algs4.cs.princeton.edu |  |
| 63 | Ptrace Injection (Articles) | `ptrace-injection` | 2 | akamai.com, blog.xpnsec.com | keep |
| 64 | PCIe (Articles) | `pcie-articles` | 3 | ctf.re, en.wikipedia.org | keep |
| 65 | Perf Wiki | `perf-wiki` | 13 | perfwiki.github.io | keep |
| 66 | Intel PT (Articles) | `intel-pt-articles` | 2 | carteryagemann.com, jauu.net | keep |
| 67 | Perf Ninja (Articles) | `perf-ninja` | 58 | easyperf.net | keep |
| 68 | Game Networking (Articles) | `game-networking` | 6 | gabrielgambetta.com, keithjohnston.wordpress.com, web.archive.org | keep |
| 69 | Android by 8K Sec (Series) | `android-8ksec` | 5 | 8ksec.io | keep |
| 70 | Memory Integrity Enforcement (Series) | `mie-8ksec` | 2 | 8ksec.io | keep |
| 71 | Advanced Frida (Series by 8ksec) | `advanced-frida-8ksec` | 10 | 8ksec.io | keep |
| 72 | ARM64 Reversing and Exploitation (8KSec) | `arm64-exploitation-8ksec` | 10 | 8ksec.io | keep |
| 73 | Page Cache (Series) | `page-cache` | 10 | biriukov.dev | keep |
| 74 | Write Your Own Allocators | `write-your-own-allocators` | 9 | danluu.com, dgtlgrove.com, gingerbill.org … | keep |
| 75 | Exploit Development (Connor McGarr) | `exploit-dev-mcgarr` | 16 | connormcgarr.github.io | keep |
| 76 | Linux Kernel Security (Index) | `linux-kernel-security` | 1083 | 0x434b.dev, 0xkol.github.io, 0xnull007.github.io … | keep |
| 77 | V8 Resources (Index) | `v8-resources` | 263 | abiondo.me, alibabacloud.com, anvbis.au … |  |
| 78 | V8 (Docs) | `v8-docs` | 52 | v8.dev |  |
| 79 | Unicorn Engine (Articles & Tutorial) | `unicorn-articles` | 4 | blog.quarkslab.com, reverse.put.as, sect.iij.ad.jp … | keep |
| 80 | Decompilation (decompilation.wiki + papers) | `decompilation-wiki` | 73 | academic.oup.com, arxiv.org, cs.cornell.edu … | keep |
| 81 | Writing an OS in Rust (Phil Opp) | `writing-an-os-in-rust` | 12 | os.phil-opp.com |  |
| 82 | Algorithms for Modern Hardware (Algorithmica) | `algorithmica-hpc` | 82 | en.algorithmica.org |  |
