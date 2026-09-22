# :Docs Books

Every title the `:Docs` → Books menu offers (RISC-V included for completeness;
those 25 sit behind the top-level "RISC-V (manuals)" entry instead). Generated
by `Resources/tools/books_inventory.py` from the `BOOKS` and `WEB_BOOKS` tables
in `lua/config/docs.lua`; the Keep column comes from `books_decisions.tsv`.

Two kinds of book:

- **Chapter books**: an epub/pdf or a markdown repo converted once into numbered
  chapter files under `Resources/docs/books/<module>/<slug>/` (the rust-lang
  mdBooks under `Resources/docs/rust/<repo>/src`). Browsed with fd/find.
- **Web books**: a frozen site or article series, `Resources/docs/<key>/index.tsv`
  (`title<TAB>url` rows) whose pages are `Resources/docs/.webcache/<sha256(url)>.txt`,
  shared between books.

## Chapter books (epub / pdf / markdown repo) — 139

### Rust (`books-rust`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 1 | Rust by Example | mdbook | `rust/rust-by-example` | 198 | keep |
| 2 | Learn Rust With Entirely Too Many Linked Lists | mdbook | `rust/too-many-lists` | 59 | keep |

### Operating Systems (`books-os`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 3 | Writing a Bootloader from Scratch (CMU 15-410) | pdf | `writing-a-bootloader-from-scratch-cmu-15-410` | 13 | keep |

### Compilers (`books-compilers`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 4 | Linkers and Loaders | pdf | `linkers-and-loaders` | 14 |  |
| 5 | Program Analysis (CMU 17-355) | pdf | `program-analysis-cmu` | 17 |  |
| 6 | Static Program Analysis (Moller & Schwartzbach) | pdf | `static-program-analysis` | 16 |  |
| 7 | How To Write Shared Libraries | pdf | `how-to-write-shared-libraries` | 7 |  |
| 8 | Crafting Interpreters | epub | `crafting-interpreters` | 41 |  |
| 9 | Writing a C Compiler | epub | `writing-a-c-compiler` | 35 |  |
| 10 | SSA-based Compiler Design | pdf | `ssa-based-compiler-design` | 33 |  |
| 11 | Talking Compilers with ChatGPT | pdf | `talking-compilers-with-chatgpt` | 27 |  |
| 12 | Introduction to Static Analysis | pdf | `introduction-to-static-analysis` | 18 |  |
| 13 | Modern Compiler Implementation in C | pdf | `modern-compiler-implementation-in-c` | 28 |  |
| 14 | Essentials of Compilation (Python) | pdf | `essentials-of-compilation` | 17 |  |
| 15 | SAT/SMT by Example (Yurichev) | pdf | `sat-smt-by-example` | 29 |  |
| 16 | Engineering a Compiler (Cooper & Torczon) | pdf | `engineering-a-compiler` | 20 |  |

### Containers (`books-container`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 17 | Build Your Own Docker (CodeCrafters) | md | `build-your-own-docker` | 7 | keep — CodeCrafters course |

### Databases (`books-db`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 18 | Build Your Own SQLite (CodeCrafters) | md | `build-your-own-sqlite` | 10 | keep — CodeCrafters course |
| 19 | Database Internals | epub | `database-internals` | 27 |  |
| 20 | Designing Data-Intensive Applications (2e) | epub | `designing-data-intensive-applications-2e` | 25 |  |

### Linux / Drivers (`books-linux`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 21 | BPF Performance Tools (Gregg) | pdf | `bpf-performance-tools` | 24 |  |
| 22 | Systems Performance (Gregg, 2e) | pdf | `systems-performance` | 25 |  |
| 23 | Performance Analysis and Tuning on Modern CPUs (2e) | pdf | `performance-analysis-and-tuning-on-modern-cpus` | 21 |  |
| 24 | Learning eBPF | pdf | `learning-ebpf` | 14 |  |
| 25 | The Linux Programming Interface | pdf | `the-linux-programming-interface` | 74 |  |
| 26 | eBPF Developer Tutorial (eunomia) | md | `ebpf-developer-tutorial` | 68 |  |
| 27 | Linux Insides (0xAX) | md | `linux-insides` | 79 | keep |
| 28 | Linux Device Driver Development (Madieu) | epub | `linux-device-driver-development-madieu` | 26 |  |
| 29 | Linux Device Drivers, 3rd Edition | epub | `linux-device-drivers-3rd-edition` | 26 |  |
| 30 | The Linux Memory Manager | epub | `the-linux-memory-manager` | 21 |  |
| 31 | Bootlin: Embedded Linux (BBB labs) | epub | `bootlin-embedded-linux-bbb-labs` | 14 |  |
| 32 | Bootlin: Linux Kernel (slides) | epub | `bootlin-linux-kernel-slides` | 23 |  |
| 33 | Bootlin: Embedded Linux (QEMU labs) | epub | `bootlin-embedded-linux-qemu-labs` | 15 |  |
| 34 | UNIX and Linux System Administration Handbook (Nemeth et al.) | pdf | `unix-and-linux-system-administration-handbook` | 42 |  |
| 35 | Linux Kernel Debugging (Billimoria) | pdf | `linux-kernel-debugging` | 18 |  |
| 36 | Linux Kernel Programming (Billimoria, 2e) | pdf | `linux-kernel-programming` | 16 |  |
| 37 | Linux Kernel Programming Part 2: Char Device Drivers (Billimoria) | pdf | `linux-kernel-programming-part-2` | 12 |  |

### Algorithms (`books-algo`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 38 | Algorithms Illuminated, Part 2 | epub | `algorithms-illuminated-part-2` | 11 |  |
| 39 | The Algorithm Design Manual | pdf | `the-algorithm-design-manual` | 28 |  |
| 40 | Introduction to Algorithms (CLRS, 3e) | pdf | `introduction-to-algorithms-clrs` | 39 |  |
| 41 | Open Data Structures (Morin, Python edition) | pdf | `open-data-structures` | 19 |  |

### Security (`books-security`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 42 | Gray Hat Hacking (6th ed) | pdf | `gray-hat-hacking-6e` | 18 |  |
| 43 | The Art of Mac Malware, Vol. 1 (Wardle) | pdf | `the-art-of-mac-malware` | 18 |  |
| 44 | The Art of Mac Malware, Vol. 2 (Wardle) | pdf | `the-art-of-mac-malware-vol2` | 21 |  |
| 45 | Rootkits and Bootkits (Matrosov et al.) | pdf | `rootkits` | 26 |  |
| 46 | File System Forensic Analysis (Carrier) | pdf | `file-system-forensic-analysis` | 25 |  |
| 47 | From Day Zero to Zero Day | pdf | `from-day-zero-to-zero-day` | 18 |  |
| 48 | Android Security Internals (Elenkov) | pdf | `android-security-internals` | 17 |  |
| 49 | The Art of Memory Forensics | pdf | `the-art-of-memory-forensics` | 38 |  |
| 50 | Attacking Network Protocols (Forshaw) | pdf | `attacking-network-protocols` | 14 |  |
| 51 | Practical Binary Analysis | epub | `practical-binary-analysis` | 37 |  |
| 52 | Linternals + Kernel Exploitation (sam4k) | md | `linternals-sam4k` | 12 | keep |
| 53 | Nightmare: Binary Exploitation Course | md | `nightmare-binary-exploitation` | 136 | keep |
| 54 | Heap Exploitation (Dhaval Kapil) | md | `heap-exploitation-dhaval-kapil` | 22 | keep |
| 55 | ir0nstone: Binary Exploitation Notes | md | `ir0nstone-binary-exploitation` | 121 | keep |
| 56 | Serious Cryptography (2e) | epub | `serious-cryptography-2e` | 30 |  |
| 57 | An Introduction to Mathematical Cryptography | pdf | `an-introduction-to-mathematical-cryptography` | 13 |  |
| 58 | The Joy of Cryptography (Rosulek) | pdf | `the-joy-of-cryptography` | 18 |  |
| 59 | Cryptography Engineering (Ferguson, Schneier, Kohno) | pdf | `cryptography-engineering` | 34 |  |
| 60 | Fuzzing Against the Machine | pdf | `fuzzing-against-the-machine` | 18 |  |
| 61 | Secure Coding in C and C++ (2e) | pdf | `secure-coding-in-c-and-cpp` | 14 |  |
| 62 | Reverse Engineering for Beginners (Yurichev) | pdf | `reverse-engineering-for-beginners` | 55 |  |
| 63 | The Art of Software Security Assessment | pdf | `the-art-of-software-security-assessment` | 22 |  |
| 64 | Surreptitious Software: Obfuscation, Watermarking, and Tamperproofing | pdf | `surreptitious-software` | 15 |  |
| 65 | Microcontroller Exploits (Goodspeed) | pdf | `microcontroller-exploits` | 29 |  |
| 66 | Reversing: Secrets of Reverse Engineering (Eilam) | pdf | `reversing-secrets-of-reverse-engineering` | 16 |  |
| 67 | A Practical Guide to TPM 2.0 (Arthur, Challener, Goldman) | pdf | `practical-guide-to-tpm-2` | 26 |  |

### Architecture (`books-arch`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 68 | Parallel and High Performance Computing (Robey, Zamora) | md | `parallel-high-performance-computing` | 29 |  |
| 69 | Hardware and Software Support for Virtualization | pdf | `hardware-software-support-virtualization` | 14 |  |
| 70 | Computer Architecture: A Quantitative Approach (H&P) | pdf | `computer-architecture-a-quantitative-approach` | 23 |  |
| 71 | Computer Organization and Design (P&H) | pdf | `computer-organization-and-design` | 15 |  |
| 72 | Modern Processor Design (Shen & Lipasti) | pdf | `modern-processor-design` | 14 |  |
| 73 | The Garbage Collection Handbook | pdf | `the-garbage-collection-handbook` | 26 |  |
| 74 | A Primer on Memory Consistency and Cache Coherence | pdf | `a-primer-on-memory-consistency-and-cache-coherence` | 15 |  |
| 75 | Shared-Memory Synchronization | pdf | `shared-memory-synchronization` | 12 |  |
| 76 | The Art of Multiprocessor Programming | pdf | `the-art-of-multiprocessor-programming` | 24 |  |
| 77 | What Every Programmer Should Know About Memory | pdf | `what-every-programmer-should-know-about-memory` | 8 |  |
| 78 | Hacker's Delight (2nd Edition) | pdf | `hackers-delight` | 27 |  |
| 79 | Optimizing Software in C++ (Agner Fog) | pdf | `optimizing-software-in-cpp-agner-fog` | 20 |  |
| 80 | Optimizing Subroutines in Assembly (Agner Fog) | pdf | `optimizing-subroutines-in-assembly-agner-fog` | 20 |  |
| 81 | The Microarchitecture of Intel, AMD, and VIA CPUs (Agner Fog) | pdf | `microarchitecture-of-cpus-agner-fog` | 31 |  |
| 82 | Instruction Tables (Agner Fog) | pdf | `instruction-tables-agner-fog` | 43 |  |
| 83 | Calling Conventions (Agner Fog) | pdf | `calling-conventions-agner-fog` | 18 |  |
| 84 | Computer Systems: A Programmer's Perspective (CSAPP, 3e) | pdf | `computer-systems-programmers-perspective` | 20 |  |
| 85 | Digital Design and Computer Architecture (Harris, 2e) | pdf | `digital-design-and-computer-architecture` | 12 |  |
| 86 | x86 Instruction Set Architecture (Shanley) | pdf | `x86-isa-shanley` | 40 |  |

### RISC-V (`books-riscv`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 87 | The RISC-V Instruction Set Manual | pdf | `the-risc-v-instruction-set-manual` | 43 |  |
| 88 | RISC-V SBI (Supervisor Binary Interface) | pdf | `riscv-sbi` | 25 |  |
| 89 | RISC-V Advanced Interrupt Architecture (AIA) | pdf | `riscv-aia` | 9 |  |
| 90 | RISC-V PLIC (Platform-Level Interrupt Controller) | pdf | `riscv-plic` | 10 |  |
| 91 | RISC-V Fast Interrupts (CLIC) | pdf | `riscv-fast-interrupt` | 7 |  |
| 92 | RISC-V IOMMU | pdf | `riscv-iommu` | 11 |  |
| 93 | RISC-V Debug Specification | pdf | `riscv-debug` | 11 |  |
| 94 | RISC-V Processor Trace (E-Trace) | pdf | `riscv-trace` | 15 |  |
| 95 | RISC-V Supervisor Domains (Smmtt) | pdf | `riscv-smmtt` | 9 |  |
| 96 | RISC-V Platform Security Model | pdf | `riscv-security-model` | 7 |  |
| 97 | RISC-V Control-Flow Integrity (CFI) | pdf | `riscv-cfi` | 9 |  |
| 98 | RISC-V CHERI | pdf | `riscv-cheri` | 26 |  |
| 99 | RISC-V UEFI Protocol | pdf | `riscv-uefi` | 9 |  |
| 100 | RISC-V Boot and Runtime Services (BRS) | pdf | `riscv-brs` | 10 |  |
| 101 | RISC-V ACPI FFH | pdf | `riscv-acpi-ffh` | 6 |  |
| 102 | RISC-V Platform Management Interface (RPMI) | pdf | `riscv-rpmi` | 7 |  |
| 103 | RISC-V Server Platform | pdf | `riscv-server-platform` | 6 |  |
| 104 | RISC-V Server SoC | pdf | `riscv-server-soc` | 8 |  |
| 105 | RISC-V Profiles | pdf | `riscv-profiles-spec` | 6 |  |
| 106 | RISC-V ELF psABI (Calling Convention) | pdf | `riscv-psabi` | 16 |  |
| 107 | RISC-V Assembly Programmer's Manual | pdf | `riscv-asm-manual` | 31 |  |
| 108 | RISC-V C API | pdf | `riscv-c-api` | 6 |  |
| 109 | RISC-V Cryptography Extensions | pdf | `riscv-crypto` | 8 |  |
| 110 | RISC-V Semihosting | pdf | `riscv-semihosting` | 9 |  |
| 111 | RISC-V Glossary | pdf | `riscv-glossary` | 7 |  |

### Hardware (`books-hardware`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 112 | Getting Started with FPGAs (Merrick) | pdf | `getting-started-with-fpgas` | 17 |  |
| 113 | Retrocomputing with Clash | pdf | `retrocomputing-with-clash` | 22 |  |

### Firmware (`books-firmware`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 114 | Mastering STM32 (Noviello) | pdf | `mastering-stm32` | 34 |  |
| 115 | Beyond BIOS | epub | `beyond-bios` | 23 |  |
| 116 | Embedded Systems: Introduction to Arm Cortex-M Microcontrollers (Valvano) | pdf | `embedded-systems-arm-cortex-m-valvano` | 18 |  |
| 117 | Embedded Systems with ARM Cortex-M (Assembly and C, Zhu) | pdf | `embedded-systems-arm-cortex-m-zhu` | 36 |  |
| 118 | The Definitive Guide to ARM Cortex-M0 and Cortex-M0+ (Yiu) | pdf | `arm-cortex-m0-definitive-guide` | 35 |  |
| 119 | Programming Embedded Systems (Barr, Massa) | pdf | `programming-embedded-systems` | 24 |  |
| 120 | Making Embedded Systems (Elecia White, 2e) | pdf | `making-embedded-systems` | 17 |  |

### Windows (`books-windows`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 121 | Windows Internals, Part 1 (7e) | pdf | `windows-internals-part-1` | 10 |  |
| 122 | Windows Internals, Part 2 (7e) | pdf | `windows-internals-part-2` | 9 |  |
| 123 | Windows Kernel Programming (2e) | pdf | `windows-kernel-programming-2e` | 11 |  |

### Haskell (`books-haskell`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 124 | Haskell Programming from First Principles | pdf | `haskell-programming-from-first-principles` | 33 |  |
| 125 | Programming in Haskell (2e) | epub | `programming-in-haskell-2e` | 31 |  |
| 126 | Algorithm Design with Haskell (Bird, Gibbons) | pdf | `algorithm-design-with-haskell` | 27 |  |
| 127 | Parallel and Concurrent Programming in Haskell (Marlow) | epub | `parallel-concurrent-haskell` | 26 |  |

### OCaml (`books-ocaml`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 128 | More OCaml: Algorithms, Methods, and Diversions | epub | `more-ocaml-algorithms-methods-and-diversions` | 28 |  |
| 129 | Learn Programming with OCaml | pdf | `learn-programming-with-ocaml` | 16 |  |

### Python (`books-python`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 130 | Fluent Python (2nd Edition) | pdf | `fluent-python` | 33 |  |
| 131 | Python Crash Course | pdf | `python-crash-course` | 31 |  |
| 132 | Dead Simple Python | pdf | `dead-simple-python` | 33 |  |

### Java (`books-java`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 133 | Java Concurrency in Practice | pdf | `java-concurrency-in-practice` | 24 |  |

### JavaScript (`books-js`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 134 | Eloquent JavaScript (4th Edition) | pdf | `eloquent-javascript-4e` | 24 |  |
| 135 | Learning TypeScript (Goldberg) | pdf | `learning-typescript` | 24 |  |

### Graphics (`books-graphics`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 136 | OpenGL SuperBible | pdf | `opengl-superbible` | 26 |  |

### Version Control (`books-vcs`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 137 | Build Your Own Git (CodeCrafters) | md | `build-your-own-git` | 8 | keep — CodeCrafters course |
| 138 | Building Git | pdf | `building-git` | 41 |  |

### Debugging (`books-debugging`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 139 | Building a Debugger | pdf | `building-a-debugger` | 27 |  |

## Frozen web books (`WEB_BOOKS`) — 65

| # | Title | Key | Entries | Source | Keep? |
|---|---|---|---|---|---|
| 1 | Hypervisor From Scratch | `rayanfam` | 8 | rayanfam.com | keep |
| 2 | Kernel CTF | `kernel-ctf` | 10 | 0x434b.dev, arxiv.org, census-labs.com … | keep |
| 3 | Learn C++ (learncpp.com) | `learncpp` | 356 | learncpp.com | keep |
| 4 | Kernel Internals | `kernel-internals` | 482 | kernel-internals.org | keep |
| 5 | Linux Kernel Labs | `kernel-labs` | 27 | linux-kernel-labs.github.io | keep |
| 6 | Making Our Own Executable Packer | `packer` | 18 | fasterthanli.me | keep |
| 7 | SLUB | `slub` | 14 | argp.github.io, blogs.oracle.com, dangokyo.wordpress.com … | keep |
| 8 | Snapshot Fuzzer | `snapshot-fuzzer` | 13 | doar-e.github.io, h0mbre.github.io | keep |
| 9 | The Astra Book | `astra` | 7 | 2ourc3.com, lcamtuf.blogspot.com, lcamtuf.coredump.cx … | keep |
| 10 | Linux Kernel Exploitation Dojo | `kernel-exploitation` | 77 | 0x434b.dev, 0xten.gitbook.io, a13xp0p0v.github.io … | keep |
| 11 | LLVM Tutorial (Kaleidoscope + ORC JIT) | `llvm-tutorial` | 15 | llvm.org | keep |
| 12 | Web Browser Engineering | `browser-engineering` | 24 | browser.engineering | keep |
| 13 | LearnOpenGL | `learnopengl` | 72 | learnopengl.com | keep |
| 14 | Hypervisor Development (revers.engineering) | `revers-hypervisor` | 8 | revers.engineering | keep |
| 15 | ELF (Series) | `elf-series` | 6 | intezer.com, lwn.net, nathanotterness.com | keep |
| 16 | glibc malloc | `glibc-malloc` | 3 | azeria-labs.com, sploitfun.wordpress.com | keep |
| 17 | JavaScript Exploitation | `javascript-exploitation` | 12 | jhalon.github.io, madstacks.dev, phrack.org | keep |
| 18 | Bootloader (Articles) | `bootloader-articles` | 9 | 0xc0ffee.netlify.app, en.wikibooks.org, interrupt.memfault.com … | keep |
| 19 | Binary Exploitation Dojo | `binary-exploitation-dojo` | 49 | 0x434b.dev, 4xura.com, axcheron.github.io … | keep |
| 20 | Learn Makefiles | `makefile-tutorial` | 19 | makefiletutorial.com | keep |
| 21 | Advanced Bash-Scripting Guide | `abs` | 140 | tldp.org | keep |
| 22 | Professional C++ (studyplan.dev) | `studyplan-pro-cpp` | 128 | studyplan.dev | keep |
| 23 | Data Structures & Algorithms (studyplan.dev) | `studyplan-dsa` | 69 | studyplan.dev | keep |
| 24 | Software Foundations: Logic Foundations | `software-foundations-lf` | 21 | softwarefoundations.cis.upenn.edu | keep |
| 25 | Linux Kernel Module Programming Guide | `lkmpg` | 1 | sysprog21.github.io | keep |
| 26 | High Performance Browser Networking (Grigorik) | `hpbn` | 18 | hpbn.co | keep |
| 27 | Cryptopals Crypto Challenges | `cryptopals` | 57 | cryptopals.com | keep |
| 28 | LazyFoo SDL3 Tutorials | `lazyfoo-sdl3` | 21 | lazyfoo.net | keep |
| 29 | QEMU Internals (Airbus Seclab) | `qemu-internals` | 15 | airbus-seclab.github.io | keep |
| 30 | JIT (Series) | `jit-series` | 4 | eli.thegreenplace.net, nullprogram.com | keep |
| 31 | EmuDev (Emulator Development reading list) | `emudev` | 43 | alexaltea.github.io, andrewkelley.me, bheisler.github.io … | keep |
| 32 | The C10K Problem (Kegel) | `c10k` | 1 | kegel.com | keep |
| 33 | BashGuide + Bash FAQ (Greg's Wiki) | `bashguide` | 13 | mywiki.wooledge.org | keep |
| 34 | The Fuzzing Book (fuzzingbook.org) | `fuzzingbook` | 30 | fuzzingbook.org | keep |
| 35 | Fuzzing Made Easy (SRLabs) | `fuzzing-made-easy` | 7 | srlabs.de | keep |
| 36 | Fuzzing BitDefender's AntiVirus Engine (stackbits) | `fuzzing-bitdefender` | 2 | stackbits.eu | keep |
| 37 | AFL++ Under The Hood (ritsec + core.gen.tr) | `afl-under-the-hood` | 17 | blog.ritsec.club, core.gen.tr | keep |
| 38 | Syzkaller Articles (Collabora, xairy, LWN, ...) | `syzkaller-articles` | 9 | collabora.com, lwn.net, slavamoskvin.com … | keep |
| 39 | Namespaces in operation (LWN, Kerrisk) | `namespaces-lwn` | 9 | lwn.net | keep |
| 40 | Control groups (LWN, Neil Brown) | `cgroups-lwn` | 7 | lwn.net | keep |
| 41 | LWN Kernel Index (categorized reference) | `lwn-index` | 5988 | lwn.net | keep |
| 42 | The Modern JavaScript Tutorial (javascript.info) | `javascript-info` | 175 | javascript.info | keep |
| 43 | Testing Handbook (Trail of Bits, appsec.guide) | `testing-handbook` | 70 | appsec.guide | keep |
| 44 | LibAFL (Articles) | `fuzzing-101-libafl` | 12 | aflplus.plus, andreafioraldi.github.io, atredis.com … | keep |
| 45 | AFL++ Articles | `aflpp-articles` | 20 | aflplus.plus, airbus-seclab.github.io, appsec.guide … | keep |
| 46 | What The Fuzz (wtf) Articles | `wtf-articles` | 5 | blog.ret2.io, blog.thalium.re, doar-e.github.io … | keep |
| 47 | Coding for SSDs (codecapsule) | `coding-for-ssds` | 6 | codecapsule.com | keep |
| 48 | Ptrace Injection (Articles) | `ptrace-injection` | 2 | akamai.com, blog.xpnsec.com | keep |
| 49 | PCIe (Articles) | `pcie-articles` | 3 | ctf.re, en.wikipedia.org | keep |
| 50 | Perf Wiki | `perf-wiki` | 13 | perfwiki.github.io | keep |
| 51 | Intel PT (Articles) | `intel-pt-articles` | 2 | carteryagemann.com, jauu.net | keep |
| 52 | Perf Ninja (Articles) | `perf-ninja` | 58 | easyperf.net | keep |
| 53 | Game Networking (Articles) | `game-networking` | 6 | gabrielgambetta.com, keithjohnston.wordpress.com, web.archive.org | keep |
| 54 | Android by 8K Sec (Series) | `android-8ksec` | 5 | 8ksec.io | keep |
| 55 | Memory Integrity Enforcement (Series) | `mie-8ksec` | 2 | 8ksec.io | keep |
| 56 | Advanced Frida (Series by 8ksec) | `advanced-frida-8ksec` | 10 | 8ksec.io | keep |
| 57 | ARM64 Reversing and Exploitation (8KSec) | `arm64-exploitation-8ksec` | 10 | 8ksec.io | keep |
| 58 | Page Cache (Series) | `page-cache` | 10 | biriukov.dev | keep |
| 59 | Write Your Own Allocators | `write-your-own-allocators` | 9 | danluu.com, dgtlgrove.com, gingerbill.org … | keep |
| 60 | Exploit Development (Connor McGarr) | `exploit-dev-mcgarr` | 16 | connormcgarr.github.io | keep |
| 61 | Linux Kernel Security (Index) | `linux-kernel-security` | 1083 | 0x434b.dev, 0xkol.github.io, 0xnull007.github.io … | keep |
| 62 | Unicorn Engine (Articles & Tutorial) | `unicorn-articles` | 4 | blog.quarkslab.com, reverse.put.as, sect.iij.ad.jp … | keep |
| 63 | Decompilation (decompilation.wiki + papers) | `decompilation-wiki` | 73 | academic.oup.com, arxiv.org, cs.cornell.edu … | keep |
| 64 | Writing an OS in Rust (Phil Opp) | `writing-an-os-in-rust` | 12 | os.phil-opp.com | keep |
| 65 | Algorithms for Modern Hardware (Algorithmica) | `algorithmica-hpc` | 82 | en.algorithmica.org | keep |

## Removed from Books — 57

(`moved` = still in :Docs, just not under Books any more.)

| Slug / key | Verdict | Note |
|---|---|---|
| `advanced-programming-in-the-unix-environment` | remove | 2026-09-22 pass, chunk 5 |
| `algs4` | remove | 2026-09-22 pass, chunk 2 |
| `an-introduction-to-computer-networks` | remove | 2026-09-22 pass, chunk 5 |
| `api-design-for-cpp` | remove | 2026-09-22 pass, chunk 3 (C / C++ modules dropped) |
| `atomics` | remove | 2026-09-22 pass, chunk 1 |
| `awesome-databases` | remove | 2026-09-22 pass, chunk 2 |
| `beautiful-c-30-core-guidelines` | remove | 2026-09-22 pass, chunk 3 (C / C++ modules dropped) |
| `beautiful-racket` | remove | 2026-09-22 pass, chunk 1 |
| `blue-fox-arm-assembly-internals` | remove | 2026-09-22 pass, chunk 4 |
| `bochs-docs` | moved | moved out of Books; reached from the top-level Bochs entry |
| `c-concurrency-in-action` | remove | 2026-09-22 pass, chunk 3 (C / C++ modules dropped) |
| `c-initialization-story` | remove | 2026-09-22 pass, chunk 3 (C / C++ modules dropped) |
| `c-move-semantics-the-complete-guide` | remove | 2026-09-22 pass, chunk 3 (C / C++ modules dropped) |
| `c-templates-the-complete-guide-2e` | remove | 2026-09-22 pass, chunk 3 (C / C++ modules dropped) |
| `cmu-15411` | remove | 2026-09-22 pass, chunk 1 |
| `cmu-15445` | remove | 2026-09-22 pass, chunk 1 |
| `command-line-rust` | remove | 2026-09-22 pass, chunk 4 |
| `cryptohack` | remove | 2026-09-22 pass, chunk 1 |
| `disarming-code` | remove | 2026-09-22 pass, chunk 4 |
| `distributed-systems` | remove | 2026-09-22 pass, chunk 5 |
| `effective-c` | remove | 2026-09-22 pass, chunk 3 (C / C++ modules dropped) |
| `effective-modern-c` | remove | 2026-09-22 pass, chunk 3 (C / C++ modules dropped) |
| `elements-of-programming` | remove | 2026-09-22 pass, chunk 3 (C / C++ modules dropped) |
| `expert-c-programming` | remove | 2026-09-22 pass, chunk 3 (C / C++ modules dropped) |
| `is-parallel-programming-hard` | remove | 2026-09-22 pass, chunk 5 |
| `lyah` | remove | 2026-09-22 pass, chunk 1 |
| `managing-projects-with-gnu-make` | remove | 2026-09-22 pass, chunk 3 (C / C++ modules dropped) |
| `mit-6824` | remove | 2026-09-22 pass, chunk 1 |
| `mit-shd` | remove | 2026-09-22 pass, chunk 1 |
| `modern-c` | remove | 2026-09-22 pass, chunk 3 (C / C++ modules dropped) |
| `modern-cpp-design` | remove | 2026-09-22 pass, chunk 3 (C / C++ modules dropped) |
| `modern-x86-assembly-language-programming` | remove | 2026-09-22 pass, chunk 4 |
| `ocaml-byexample` | remove | 2026-09-22 pass, chunk 1 |
| `operating-systems-design-and-implementation` | remove | 2026-09-22 pass, chunk 5 |
| `operating-systems-three-easy-pieces` | remove | 2026-09-22 pass, chunk 5 |
| `professional-assembly-language` | remove | 2026-09-22 pass, chunk 4 |
| `professional-cmake` | remove | 2026-09-22 pass, chunk 3 (C / C++ modules dropped) |
| `programming-rust-2e` | remove | 2026-09-22 pass, chunk 4 |
| `programming-with-posix-threads` | remove | 2026-09-22 pass, chunk 5 |
| `rust-for-rustaceans` | remove | 2026-09-22 pass, chunk 4 |
| `rust-in-action` | remove | 2026-09-22 pass, chunk 4 |
| `rust-under-the-hood` | remove | 2026-09-22 pass, chunk 4 |
| `rust/book` | remove | 2026-09-22 pass, chunk 4 |
| `rust/nomicon` | remove | 2026-09-22 pass, chunk 4 |
| `sicp-js` | remove | 2026-09-22 pass, chunk 2 |
| `system-programming-in-linux` | remove | 2026-09-22 pass, chunk 5 |
| `tcp-ip-illustrated-vol-1` | remove | 2026-09-22 pass, chunk 5 |
| `the-art-of-arm-assembly-volume-1` | remove | 2026-09-22 pass, chunk 4 |
| `the-design-and-implementation-of-the-freebsd-operating-system` | remove | 2026-09-22 pass, chunk 5 |
| `the-little-book-of-semaphores` | remove | 2026-09-22 pass, chunk 5 |
| `unix-network-programming` | remove | 2026-09-22 pass, chunk 5 |
| `v8-docs` | remove | 2026-09-22 pass, chunk 2 |
| `v8-resources` | remove | 2026-09-22 pass, chunk 2 |
| `wisc-cs752` | remove | 2026-09-22 pass, chunk 2 |
| `write-you-a-haskell` | remove | 2026-09-22 pass, chunk 1 |
| `xv6-x86` | remove | 2026-09-22 pass, chunk 5 |
| `zero-to-production-in-rust` | remove | 2026-09-22 pass, chunk 4 |
