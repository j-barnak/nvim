# So You Wanna Find Bugs In The Kernel (slides)

      So You Wan n a
Find Bugs In The Linux Kernel?




                           Sam Page, #TyphoonCon23
About Me

    Sam (@sam4k1)

    Background in VR and exploit dev

    I like Linux, security, games & food
What’s The Plan?

    Cover the state of kernel VR in 2024

    Explore the kernel attack surface for targets

    Dive into approaches and workflow for actually finding bugs
The State of Kernel VR Today
State of Kernel VR | What’s The Appeal?

    Lots of users (1.6+ billion)

    The kernel has ultimate control over the device

    Broad, open source attack surface with a history of bugs




                                                               Source(s): Statista
State of Kernel VR | The Challenges

    Continuous hardening efforts, technology improvements
         150+ hardening options over the last 20 years[4]
         Goal posts for finding + exploiting kernel vulns constantly shifting
         Attempts to reduce availability of generic techniques

    Increased awareness + vested interests in security
         Continual fuzzing, bounty programs etc.

    Culminates in increasing complexity to “weaponize” a vulnerability
State of Kernel VR | So Where Are The Bugs?!

    How do we track what bugs are found where?
State of Kernel VR | So Where Are The Bugs?!

    How do we track what bugs are found where?
         Not all CVEs are created equal[1][10]
State of Kernel VR | So Where Are The Bugs?!

    How do we track what bugs are found where?
         Not all CVEs are created equal[1]
         Neither are all kernel commits[2][11][12]
State of Kernel VR | So Where Are The Bugs?!

    How do we track what bugs are found where?
         Not all CVEs are created equal[1]
         Neither are all kernel commits[2]
         What about common 3rd parties/vendors?
         And ofc then there’s the 0days…

    Android Security Bulletin?
         Monthly list of impactful kernel vulns, incl upstream + vendors
State of Kernel VR | So Where Are The Bugs?!




                                               Source(s): Android Security Bulletin
State of Kernel VR | So Where Are The Bugs?!




                                               Source(s): Android Security Bulletin
Picking A Kernel Target
Picking A Kernel Target | Some Context




                                  Source(s): Attacking the Qualcomm Adreno GPU by Ben Hawkes [3]
Picking A Kernel Target | Defining The Attack Surface

    What’s our goal? Define scope/target (E.g. Ubuntu 22.04.3 LTS)
         E.g. specific device, bug bounty, vibes

    We want to consider:
         The kernel version (and arch) we’re interested in
         The typical kernel configuration
         Additional distro/vendor surface that might be present
         The surface exposed to an unprivileged user/our chosen context
         Reliability, privesc vs crash etc.
Picking A Kernel Target | Kconfig & Narrowing Down Attack Surface

    Mitigations: FORTIFY_SOURCE, CFI, stack protector, heap hardening etc.[4]
         Consider probabilistic vs deterministic mitigations

    Attack Surface: SELinux, Seccomp, unpriv namespaces etc.

    Exploitation Techniques: FUSE, STATIC_USERMODEHELPER, generally
    reducing kernel surface (e.g. less gadgets, heap feng shui objects) etc.
Picking A Kernel Target | Target Considerations

    Explore target history: past bugs, commits, recent features?

    Maturity and complexity: is it a tiny module that’s been around forever?

    Syzkaller coverage: has it been fuzzed into oblivion already?
Okay, How About Finding Bugs?
Kernel Auditing | An Overview

    Understand the tools and techniques available to us

    Use the knowledge gained so far to inform our approach
         Bug classes, complexity, areas of interest etc.
         It’s an iterative process of trial and error!

    Remember this stuff is HARD (right???)
Kernel Auditing | Code Auditing

    Take the time to understand what the code is trying to do
          Continually ask questions, be curious!
          Object lifetimes, locking, userspace interactions, state etc.
          New features, complex interactions with other subystems etc.

    Factor in all of the context we’ve built up so far
          Are we expecting low hanging fruit or complex bugs?
          Are there bug classes that we should avoid completely?

    Don’t neglect tooling, workflow & documentation
Kernel Auditing | Fuzzing with Syzkaller

    syzkaller is an unsupervised coverage-guided kernel fuzzer[5]

    syzbot continuously fuzzes main Linux kernel branches[6]

    We can use the understanding developed to extend its coverage




                                     Source(s): https://github.com/google/syzkaller/blob/master/docs/internals.md
Kernel Auditing | Syzbot Dashboard




                                     Source(s): https://syzkaller.appspot.com/linux-6.1
Kernel Auditing | Syzbot Dashboard




                                     Source(s): [8][9]
Kernel Auditing | Modifying Syzkaller

    Broadly speaking, three things to consider:
         Descriptions: describe syscalls, their arguments, possible values and
          any order they need to be called in
Kernel Auditing | Modifying Syzkaller

    Broadly speaking, three things to consider:
         Descriptions: describe syscalls, their arguments, possible values and
          any order they need to be called in
         Pseudo-syscalls: wrappers around syscalls to carry out any additional
          setup or state-tweaking to get desired coverage
         Adding KCOV: subsystem for collecting coverage; may need to add
          remote coverage for code run outside the process context
Kernel Auditing | Code Querying with CodeQL

    CodeQL lets you query code as though it were data[7]

    Need to create a database for the code we want to query

    Can be used to query for vuln patterns, variant analysis etc.

    But also can be used to augment code audit & enumeration

    As well as exploit development! (out of scope for this talk tho :()
Kernel Auditing | CodeQL Example

    Example of query to find kmalloc calls taking 16-bit arguments (easier to
    overflow) for further analysis:




            Source(s): https://www.sentinelone.com/labs/tipc-remote-linux-kernel-heap-overflow-allows-arbitrary-code-execution/
Kernel Auditing | CodeQL Usecases

    Querying for vulnerabilities: variant analysis on bugs found, rule out low
    hanging fruit/easily query-able bug classes to free up audit time etc.

    Enumerate attack surface, highlight areas of interest: what objects are
    allocated, where are they accessed, which are ref counted, have fptrs etc.

    Automate code auditing process: check if certain fields are accessed,
    function is called with certain args, if a certain condition is guarded etc.
Kernel Auditing | A Case Study

    Transparent Inter-Process Communication (TIPC)

    Non-default network protocol (RCE is cool right?)

    Low Syzkaller coverage

    Previous experience with it




                                                        Source(s): https://syzkaller.appspot.com/linux-6.1
Kernel Auditing | A Case Study

    Used understanding gained via code audit
    to determine key interactions which
    lacked coverage and why this was

    Implemented proper message formatting
    and TIPC handshake boilerplate

    discover.c (+29%), link.c (+32%),
    monitor.c (+15%), name_distr.c (+46%),
    node.c (+17%)
Kernel Auditing | A Case Study
Wrapping Up
Wrapping Up

    Ask questions, be curious!

    Pace yourself, (try to) enjoy the process

    Experiment with tools and techniques

    Sometimes there just isn’t a bug! But
    the knowledge + exp carries over

    Feel free to ping me off/online :)
Resources

    https://github.com/google/syzkaller

    https://codeql.github.com

    https://github.com/xairy/linux-kernel-exploitation (great collection of kernel exploitation resources)

    https://pwning.tech/ksmbd-syzkaller/ (good guide on extending syzkaller for ksmbd)
Refs
1) “The bogus CVE problem”, “Supplementing CVEs with !CVEs” by Jake Edge at LWN
2) https://sam4k.com/analysing-linux-kernel-commits/#on-silent-security-fixes
3) https://googleprojectzero.blogspot.com/2020/09/attacking-qualcomm-adreno-gpu.html
4) https://github.com/a13xp0p0v/kernel-hardening-checker
5) https://github.com/google/syzkaller
6) https://github.com/google/syzkaller/blob/master/docs/syzbot.md
7) https://codeql.github.com
8) https://storage.googleapis.com/syzbot-assets/34c45129131f/ci2-linux-6-1-kasan-4078fa63.html#io_uring%2fio_uring.c
9) https://github.com/google/syzkaller/blob/master/docs/coverage.md
10)https://lore.kernel.org/linux-cve-announce/2024052155-raking-onshore-f6f3@gregkh/T/#t
11)https://github.com/torvalds/linux/commit/7395dfacfff65e9938ac0889dafa1ab01e987d15
12)https://github.com/torvalds/linux/commit/080cbb890286cd794f1ee788bbc5463e2deb7c2b

