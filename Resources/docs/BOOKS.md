# :Docs Books

Every title the `:Docs` → Books menu offers. Generated
by `Resources/tools/books_inventory.py` from the `BOOKS` and `WEB_BOOKS` tables
in `lua/config/docs.lua`; the Keep column comes from `books_decisions.tsv`.

Two kinds of book:

- **Chapter books**: an epub/pdf or a markdown repo converted once into numbered
  chapter files under `Resources/docs/books/<module>/<slug>/` (the rust-lang
  mdBooks under `Resources/docs/rust/<repo>/src`). Browsed with fd/find.
- **Web books**: a frozen site or article series, `Resources/docs/<key>/index.tsv`
  (`title<TAB>url` rows) whose pages are `Resources/docs/.webcache/<sha256(url)>.txt`,
  shared between books.

## Chapter books (epub / pdf / markdown repo) — 27

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
| 4 | SAT/SMT by Example (Yurichev) | pdf | `sat-smt-by-example` | 29 | keep |

### Containers (`books-container`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 5 | Build Your Own Docker (CodeCrafters) | md | `build-your-own-docker` | 7 | keep — CodeCrafters course |

### Databases (`books-db`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 6 | Build Your Own SQLite (CodeCrafters) | md | `build-your-own-sqlite` | 10 | keep — CodeCrafters course |

### Linux / Drivers (`books-linux`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 7 | Linux Insides (0xAX) | md | `linux-insides` | 79 | keep |

### Security (`books-security`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 8 | Linternals + Kernel Exploitation (sam4k) | md | `linternals-sam4k` | 12 | keep |
| 9 | Nightmare: Binary Exploitation Course | md | `nightmare-binary-exploitation` | 136 | keep |
| 10 | Heap Exploitation (Dhaval Kapil) | md | `heap-exploitation-dhaval-kapil` | 22 | keep |
| 11 | ir0nstone: Binary Exploitation Notes | md | `ir0nstone-binary-exploitation` | 121 | keep |

### Haskell (`books-haskell`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 12 | Haskell Programming from First Principles | pdf | `haskell-programming-from-first-principles` | 33 |  |
| 13 | Programming in Haskell (2e) | epub | `programming-in-haskell-2e` | 31 |  |
| 14 | Algorithm Design with Haskell (Bird, Gibbons) | pdf | `algorithm-design-with-haskell` | 27 |  |
| 15 | Parallel and Concurrent Programming in Haskell (Marlow) | epub | `parallel-concurrent-haskell` | 26 |  |

### OCaml (`books-ocaml`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 16 | More OCaml: Algorithms, Methods, and Diversions | epub | `more-ocaml-algorithms-methods-and-diversions` | 28 |  |
| 17 | Learn Programming with OCaml | pdf | `learn-programming-with-ocaml` | 16 |  |

### Python (`books-python`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 18 | Fluent Python (2nd Edition) | pdf | `fluent-python` | 33 |  |
| 19 | Python Crash Course | pdf | `python-crash-course` | 31 |  |
| 20 | Dead Simple Python | pdf | `dead-simple-python` | 33 |  |

### Java (`books-java`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 21 | Java Concurrency in Practice | pdf | `java-concurrency-in-practice` | 24 |  |

### JavaScript (`books-js`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 22 | Eloquent JavaScript (4th Edition) | pdf | `eloquent-javascript-4e` | 24 |  |
| 23 | Learning TypeScript (Goldberg) | pdf | `learning-typescript` | 24 |  |

### Graphics (`books-graphics`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 24 | OpenGL SuperBible | pdf | `opengl-superbible` | 26 |  |

### Version Control (`books-vcs`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 25 | Build Your Own Git (CodeCrafters) | md | `build-your-own-git` | 8 | keep — CodeCrafters course |
| 26 | Building Git | pdf | `building-git` | 41 |  |

### Debugging (`books-debugging`)

| # | Title | Fmt | Slug | Chapters | Keep? |
|---|---|---|---|---|---|
| 27 | Building a Debugger | pdf | `building-a-debugger` | 27 |  |

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

## Removed from Books — 169

(`moved` = still in :Docs, just not under Books any more.)

| Slug / key | Verdict | Note |
|---|---|---|
| `a-primer-on-memory-consistency-and-cache-coherence` | remove | 2026-09-22 pass, chunk 10 |
| `advanced-programming-in-the-unix-environment` | remove | 2026-09-22 pass, chunk 5 |
| `algorithms-illuminated-part-2` | remove | 2026-09-22 pass, chunk 8 |
| `algs4` | remove | 2026-09-22 pass, chunk 2 |
| `an-introduction-to-computer-networks` | remove | 2026-09-22 pass, chunk 5 |
| `an-introduction-to-mathematical-cryptography` | remove | 2026-09-22 pass, chunk 9 |
| `android-security-internals` | remove | 2026-09-22 pass, chunk 8 |
| `api-design-for-cpp` | remove | 2026-09-22 pass, chunk 3 (C / C++ modules dropped) |
| `arm-cortex-m0-definitive-guide` | remove | 2026-09-22 pass, chunk 12 |
| `atomics` | remove | 2026-09-22 pass, chunk 1 |
| `attacking-network-protocols` | remove | 2026-09-22 pass, chunk 8 |
| `awesome-databases` | remove | 2026-09-22 pass, chunk 2 |
| `beautiful-c-30-core-guidelines` | remove | 2026-09-22 pass, chunk 3 (C / C++ modules dropped) |
| `beautiful-racket` | remove | 2026-09-22 pass, chunk 1 |
| `beyond-bios` | remove | 2026-09-22 pass, chunk 12 |
| `blue-fox-arm-assembly-internals` | remove | 2026-09-22 pass, chunk 4 |
| `bochs-docs` | moved | moved out of Books; reached from the top-level Bochs entry |
| `bootlin-embedded-linux-bbb-labs` | remove | 2026-09-22 pass, chunk 7 |
| `bootlin-embedded-linux-qemu-labs` | remove | 2026-09-22 pass, chunk 7 |
| `bootlin-linux-kernel-slides` | remove | 2026-09-22 pass, chunk 7 |
| `bpf-performance-tools` | remove | 2026-09-22 pass, chunk 7 |
| `c-concurrency-in-action` | remove | 2026-09-22 pass, chunk 3 (C / C++ modules dropped) |
| `c-initialization-story` | remove | 2026-09-22 pass, chunk 3 (C / C++ modules dropped) |
| `c-move-semantics-the-complete-guide` | remove | 2026-09-22 pass, chunk 3 (C / C++ modules dropped) |
| `c-templates-the-complete-guide-2e` | remove | 2026-09-22 pass, chunk 3 (C / C++ modules dropped) |
| `calling-conventions-agner-fog` | remove | 2026-09-22 pass, chunk 10 |
| `cmu-15411` | remove | 2026-09-22 pass, chunk 1 |
| `cmu-15445` | remove | 2026-09-22 pass, chunk 1 |
| `command-line-rust` | remove | 2026-09-22 pass, chunk 4 |
| `computer-architecture-a-quantitative-approach` | remove | 2026-09-22 pass, chunk 10 |
| `computer-organization-and-design` | remove | 2026-09-22 pass, chunk 10 |
| `computer-systems-programmers-perspective` | remove | 2026-09-22 pass, chunk 10 |
| `crafting-interpreters` | remove | 2026-09-22 pass, chunk 6 |
| `cryptography-engineering` | remove | 2026-09-22 pass, chunk 9 |
| `cryptohack` | remove | 2026-09-22 pass, chunk 1 |
| `database-internals` | remove | 2026-09-22 pass, chunk 7 |
| `designing-data-intensive-applications-2e` | remove | 2026-09-22 pass, chunk 7 |
| `digital-design-and-computer-architecture` | remove | 2026-09-22 pass, chunk 10 |
| `disarming-code` | remove | 2026-09-22 pass, chunk 4 |
| `distributed-systems` | remove | 2026-09-22 pass, chunk 5 |
| `ebpf-developer-tutorial` | remove | 2026-09-22 pass, chunk 7 |
| `effective-c` | remove | 2026-09-22 pass, chunk 3 (C / C++ modules dropped) |
| `effective-modern-c` | remove | 2026-09-22 pass, chunk 3 (C / C++ modules dropped) |
| `elements-of-programming` | remove | 2026-09-22 pass, chunk 3 (C / C++ modules dropped) |
| `embedded-systems-arm-cortex-m-valvano` | remove | 2026-09-22 pass, chunk 12 |
| `embedded-systems-arm-cortex-m-zhu` | remove | 2026-09-22 pass, chunk 12 |
| `engineering-a-compiler` | remove | 2026-09-22 pass, chunk 6 |
| `essentials-of-compilation` | remove | 2026-09-22 pass, chunk 6 |
| `expert-c-programming` | remove | 2026-09-22 pass, chunk 3 (C / C++ modules dropped) |
| `file-system-forensic-analysis` | remove | 2026-09-22 pass, chunk 8 |
| `from-day-zero-to-zero-day` | remove | 2026-09-22 pass, chunk 8 |
| `fuzzing-against-the-machine` | remove | 2026-09-22 pass, chunk 9 |
| `getting-started-with-fpgas` | remove | 2026-09-22 pass, chunk 12 |
| `gray-hat-hacking-6e` | remove | 2026-09-22 pass, chunk 8 |
| `hackers-delight` | remove | 2026-09-22 pass, chunk 10 |
| `hardware-software-support-virtualization` | remove | 2026-09-22 pass, chunk 10 |
| `how-to-write-shared-libraries` | remove | 2026-09-22 pass, chunk 6 |
| `instruction-tables-agner-fog` | remove | 2026-09-22 pass, chunk 10 |
| `introduction-to-algorithms-clrs` | remove | 2026-09-22 pass, chunk 8 |
| `introduction-to-static-analysis` | remove | 2026-09-22 pass, chunk 6 |
| `is-parallel-programming-hard` | remove | 2026-09-22 pass, chunk 5 |
| `learning-ebpf` | remove | 2026-09-22 pass, chunk 7 |
| `linkers-and-loaders` | remove | 2026-09-22 pass, chunk 6 |
| `linux-device-driver-development-madieu` | remove | 2026-09-22 pass, chunk 7 |
| `linux-device-drivers-3rd-edition` | remove | 2026-09-22 pass, chunk 7 |
| `linux-kernel-debugging` | remove | 2026-09-22 pass, chunk 7 |
| `linux-kernel-programming` | remove | 2026-09-22 pass, chunk 7 |
| `linux-kernel-programming-part-2` | remove | 2026-09-22 pass, chunk 7 |
| `lyah` | remove | 2026-09-22 pass, chunk 1 |
| `making-embedded-systems` | remove | 2026-09-22 pass, chunk 12 |
| `managing-projects-with-gnu-make` | remove | 2026-09-22 pass, chunk 3 (C / C++ modules dropped) |
| `mastering-stm32` | remove | 2026-09-22 pass, chunk 12 |
| `microarchitecture-of-cpus-agner-fog` | remove | 2026-09-22 pass, chunk 10 |
| `microcontroller-exploits` | remove | 2026-09-22 pass, chunk 9 |
| `mit-6824` | remove | 2026-09-22 pass, chunk 1 |
| `mit-shd` | remove | 2026-09-22 pass, chunk 1 |
| `modern-c` | remove | 2026-09-22 pass, chunk 3 (C / C++ modules dropped) |
| `modern-compiler-implementation-in-c` | remove | 2026-09-22 pass, chunk 6 |
| `modern-cpp-design` | remove | 2026-09-22 pass, chunk 3 (C / C++ modules dropped) |
| `modern-processor-design` | remove | 2026-09-22 pass, chunk 10 |
| `modern-x86-assembly-language-programming` | remove | 2026-09-22 pass, chunk 4 |
| `ocaml-byexample` | remove | 2026-09-22 pass, chunk 1 |
| `open-data-structures` | remove | 2026-09-22 pass, chunk 8 |
| `operating-systems-design-and-implementation` | remove | 2026-09-22 pass, chunk 5 |
| `operating-systems-three-easy-pieces` | remove | 2026-09-22 pass, chunk 5 |
| `optimizing-software-in-cpp-agner-fog` | remove | 2026-09-22 pass, chunk 10 |
| `optimizing-subroutines-in-assembly-agner-fog` | remove | 2026-09-22 pass, chunk 10 |
| `parallel-high-performance-computing` | remove | 2026-09-22 pass, chunk 10 |
| `performance-analysis-and-tuning-on-modern-cpus` | remove | 2026-09-22 pass, chunk 7 |
| `practical-binary-analysis` | remove | 2026-09-22 pass, chunk 8 |
| `practical-guide-to-tpm-2` | remove | 2026-09-22 pass, chunk 9 |
| `professional-assembly-language` | remove | 2026-09-22 pass, chunk 4 |
| `professional-cmake` | remove | 2026-09-22 pass, chunk 3 (C / C++ modules dropped) |
| `program-analysis-cmu` | remove | 2026-09-22 pass, chunk 6 |
| `programming-embedded-systems` | remove | 2026-09-22 pass, chunk 12 |
| `programming-rust-2e` | remove | 2026-09-22 pass, chunk 4 |
| `programming-with-posix-threads` | remove | 2026-09-22 pass, chunk 5 |
| `retrocomputing-with-clash` | remove | 2026-09-22 pass, chunk 12 |
| `reverse-engineering-for-beginners` | remove | 2026-09-22 pass, chunk 9 |
| `reversing-secrets-of-reverse-engineering` | remove | 2026-09-22 pass, chunk 9 |
| `riscv-acpi-ffh` | remove | 2026-09-22 pass, chunk 11 |
| `riscv-aia` | remove | 2026-09-22 pass, chunk 11 |
| `riscv-asm-manual` | remove | 2026-09-22 pass, chunk 11 |
| `riscv-brs` | remove | 2026-09-22 pass, chunk 11 |
| `riscv-c-api` | remove | 2026-09-22 pass, chunk 11 |
| `riscv-cfi` | remove | 2026-09-22 pass, chunk 11 |
| `riscv-cheri` | remove | 2026-09-22 pass, chunk 11 |
| `riscv-crypto` | remove | 2026-09-22 pass, chunk 11 |
| `riscv-debug` | remove | 2026-09-22 pass, chunk 11 |
| `riscv-fast-interrupt` | remove | 2026-09-22 pass, chunk 11 |
| `riscv-glossary` | remove | 2026-09-22 pass, chunk 11 |
| `riscv-iommu` | remove | 2026-09-22 pass, chunk 11 |
| `riscv-plic` | remove | 2026-09-22 pass, chunk 11 |
| `riscv-profiles-spec` | remove | 2026-09-22 pass, chunk 11 |
| `riscv-psabi` | remove | 2026-09-22 pass, chunk 11 |
| `riscv-rpmi` | remove | 2026-09-22 pass, chunk 11 |
| `riscv-sbi` | remove | 2026-09-22 pass, chunk 11 |
| `riscv-security-model` | remove | 2026-09-22 pass, chunk 11 |
| `riscv-semihosting` | remove | 2026-09-22 pass, chunk 11 |
| `riscv-server-platform` | remove | 2026-09-22 pass, chunk 11 |
| `riscv-server-soc` | remove | 2026-09-22 pass, chunk 11 |
| `riscv-smmtt` | remove | 2026-09-22 pass, chunk 11 |
| `riscv-trace` | remove | 2026-09-22 pass, chunk 11 |
| `riscv-uefi` | remove | 2026-09-22 pass, chunk 11 |
| `rootkits` | remove | 2026-09-22 pass, chunk 8 |
| `rust-for-rustaceans` | remove | 2026-09-22 pass, chunk 4 |
| `rust-in-action` | remove | 2026-09-22 pass, chunk 4 |
| `rust-under-the-hood` | remove | 2026-09-22 pass, chunk 4 |
| `rust/book` | remove | 2026-09-22 pass, chunk 4 |
| `rust/nomicon` | remove | 2026-09-22 pass, chunk 4 |
| `secure-coding-in-c-and-cpp` | remove | 2026-09-22 pass, chunk 9 |
| `serious-cryptography-2e` | remove | 2026-09-22 pass, chunk 9 |
| `shared-memory-synchronization` | remove | 2026-09-22 pass, chunk 10 |
| `sicp-js` | remove | 2026-09-22 pass, chunk 2 |
| `ssa-based-compiler-design` | remove | 2026-09-22 pass, chunk 6 |
| `static-program-analysis` | remove | 2026-09-22 pass, chunk 6 |
| `surreptitious-software` | remove | 2026-09-22 pass, chunk 9 |
| `system-programming-in-linux` | remove | 2026-09-22 pass, chunk 5 |
| `systems-performance` | remove | 2026-09-22 pass, chunk 7 |
| `talking-compilers-with-chatgpt` | remove | 2026-09-22 pass, chunk 6 |
| `tcp-ip-illustrated-vol-1` | remove | 2026-09-22 pass, chunk 5 |
| `the-algorithm-design-manual` | remove | 2026-09-22 pass, chunk 8 |
| `the-art-of-arm-assembly-volume-1` | remove | 2026-09-22 pass, chunk 4 |
| `the-art-of-mac-malware` | remove | 2026-09-22 pass, chunk 8 |
| `the-art-of-mac-malware-vol2` | remove | 2026-09-22 pass, chunk 8 |
| `the-art-of-memory-forensics` | remove | 2026-09-22 pass, chunk 8 |
| `the-art-of-multiprocessor-programming` | remove | 2026-09-22 pass, chunk 10 |
| `the-art-of-software-security-assessment` | remove | 2026-09-22 pass, chunk 9 |
| `the-design-and-implementation-of-the-freebsd-operating-system` | remove | 2026-09-22 pass, chunk 5 |
| `the-garbage-collection-handbook` | remove | 2026-09-22 pass, chunk 10 |
| `the-joy-of-cryptography` | remove | 2026-09-22 pass, chunk 9 |
| `the-linux-memory-manager` | remove | 2026-09-22 pass, chunk 7 |
| `the-linux-programming-interface` | remove | 2026-09-22 pass, chunk 7 |
| `the-little-book-of-semaphores` | remove | 2026-09-22 pass, chunk 5 |
| `the-risc-v-instruction-set-manual` | remove | 2026-09-22 pass, chunk 11 |
| `unix-and-linux-system-administration-handbook` | remove | 2026-09-22 pass, chunk 7 |
| `unix-network-programming` | remove | 2026-09-22 pass, chunk 5 |
| `v8-docs` | remove | 2026-09-22 pass, chunk 2 |
| `v8-resources` | remove | 2026-09-22 pass, chunk 2 |
| `what-every-programmer-should-know-about-memory` | remove | 2026-09-22 pass, chunk 10 |
| `windows-internals-part-1` | remove | 2026-09-22 pass, chunk 12 |
| `windows-internals-part-2` | remove | 2026-09-22 pass, chunk 12 |
| `windows-kernel-programming-2e` | remove | 2026-09-22 pass, chunk 12 |
| `wisc-cs752` | remove | 2026-09-22 pass, chunk 2 |
| `write-you-a-haskell` | remove | 2026-09-22 pass, chunk 1 |
| `writing-a-c-compiler` | remove | 2026-09-22 pass, chunk 6 |
| `x86-isa-shanley` | remove | 2026-09-22 pass, chunk 10 |
| `xv6-x86` | remove | 2026-09-22 pass, chunk 5 |
| `zero-to-production-in-rust` | remove | 2026-09-22 pass, chunk 4 |
