# Linternals: The User Virtual Address Space

March 20, 2022

[\#linux](https://sam4k.com/tags/linux/)

[\#kernel](https://sam4k.com/tags/kernel/)

[\#memory](https://sam4k.com/tags/memory/)



Ready to get dive back into some Linternals? I hope so! So to recap, [last time](https://sam4k.com/linternals-virtual-memory-part-1/), we covered some virtual memory fundamentals including:

- Virtual vs physical memory
- The virtual address space
- The VM split (user and kernel virtual address spaces)

This time we’re going to zoom in and focus on the two parts of the virtual memory split, taking a look at the user and kernel virtual address spaces.

Hopefully, after that, we’ll have a good idea of how - and why - our Linux system uses virtual memory. At which point we’ll take a look at how this is all implemented behind the scenes, examining some kernel and hardware specifics!

## Contents

- [0x04 User Virtual Address Space](https://sam4k.com/linternals-virtual-memory-0x02/#0x04-user-virtual-address-space)
  - [Userspace Mappings](https://sam4k.com/linternals-virtual-memory-0x02/#userspace-mappings)
  - [The Setup](https://sam4k.com/linternals-virtual-memory-0x02/#the-setup)
    - brk()
    - mmap()
    - mprotect()
    - execve()
  - [Threads](https://sam4k.com/linternals-virtual-memory-0x02/#threads)
  - [ASLR](https://sam4k.com/linternals-virtual-memory-0x02/#aslr)
  - [Wrapping Up In UVAS](https://sam4k.com/linternals-virtual-memory-0x02/#wrapping-up-in-uvas)
- [Next Time!](https://sam4k.com/linternals-virtual-memory-0x02/#next-time)

## 0x04 User Virtual Address Space

Alrighty then, first things first, let’s actually take a look at what a typical process actually uses the user virtual address space (UVAS) for. Luckily, I don’t have to whip up a diagram for this, as we can use the `/proc` filesystem!

❓

procfs is a virtual filesystem that is created at boot. It acts as an interface to internal data structures in the kernel. It can be used to obtain information about the system and to change certain kernel parameters at runtime (sysctl). \[1\]

Inside procfs, you can inspect running processes by PID. For example, the file `/proc/854/maps` will contain information about the mappings for process with PID 854.

To make life easier, there’s a handy link, `/proc/self/`, which will point to the process currently reading the file - pretty neat! Beyond `maps`, there’s all sorts of information we can learn from procfs; check `man procfs` for more info.

------------------------------------------------------------------------

1.  <https://www.kernel.org/doc/html/latest/filesystems/proc.html>

### Userspace Mappings

Back on topic! Let’s use the procfs to take a closer look at what our UVAS is being used for. From the man page, we learn the `maps` procfs file contains “the currently mapped memory regions and their access permissions"m for a process.

We’ll touch more on the implementation later, but for now it’s worth remembering that the virtual address space is **vast** and largely empty. If a process needs to use some memory, either to load the contents of a file or to store data, it will ask the kernel to map that memory appropriately. Now that virtual address is actually pointing to something.

Using the `self` link we talked about earlier, and the `maps` file, we can use `cat` to output the details of it’s own memory mappings:

``` console
$ cat /proc/self/maps 
5577277d1000-5577277d3000 r--p 00000000 00:19 868257                     /usr/bin/cat
5577277d3000-5577277d8000 r-xp 00002000 00:19 868257                     /usr/bin/cat
5577277d8000-5577277db000 r--p 00007000 00:19 868257                     /usr/bin/cat
5577277db000-5577277dc000 r--p 00009000 00:19 868257                     /usr/bin/cat
5577277dc000-5577277dd000 rw-p 0000a000 00:19 868257                     /usr/bin/cat
557728bca000-557728beb000 rw-p 00000000 00:00 0                          [heap]
7fc863779000-7fc863a63000 r--p 00000000 00:19 2289972                    /usr/lib/locale/locale-archive
7fc863a63000-7fc863a66000 rw-p 00000000 00:00 0 
7fc863a66000-7fc863a92000 r--p 00000000 00:19 2289282                    /usr/lib/libc.so.6
7fc863a92000-7fc863c08000 r-xp 0002c000 00:19 2289282                    /usr/lib/libc.so.6
7fc863c08000-7fc863c5c000 r--p 001a2000 00:19 2289282                    /usr/lib/libc.so.6
7fc863c5c000-7fc863c5d000 ---p 001f6000 00:19 2289282                    /usr/lib/libc.so.6
7fc863c5d000-7fc863c60000 r--p 001f6000 00:19 2289282                    /usr/lib/libc.so.6
7fc863c60000-7fc863c63000 rw-p 001f9000 00:19 2289282                    /usr/lib/libc.so.6
7fc863c63000-7fc863c72000 rw-p 00000000 00:00 0 
7fc863c7e000-7fc863ca0000 rw-p 00000000 00:00 0 
7fc863ca0000-7fc863ca2000 r--p 00000000 00:19 2289273                    /usr/lib/ld-linux-x86-64.so.2
7fc863ca2000-7fc863cc9000 r-xp 00002000 00:19 2289273                    /usr/lib/ld-linux-x86-64.so.2
7fc863cc9000-7fc863cd4000 r--p 00029000 00:19 2289273                    /usr/lib/ld-linux-x86-64.so.2
7fc863cd5000-7fc863cd7000 r--p 00034000 00:19 2289273                    /usr/lib/ld-linux-x86-64.so.2
7fc863cd7000-7fc863cd9000 rw-p 00036000 00:19 2289273                    /usr/lib/ld-linux-x86-64.so.2
7ffddc9a0000-7ffddc9c1000 rw-p 00000000 00:00 0                          [stack]
7ffddc9f4000-7ffddc9f8000 r--p 00000000 00:00 0                          [vvar]
7ffddc9f8000-7ffddc9fa000 r-xp 00000000 00:00 0                          [vdso]
ffffffffff600000-ffffffffff601000 --xp 00000000 00:00 0                  [vsyscall]
```

Sweet! Well, there’s a lot to unpack here, though some of it should look familiar. Consulting `man procfs` we can see the columns are as follows:

`(virtual) address,   perms,   offset,   dev,   inode,   pathname`

If we recall from last time, on a typical x86_64 setup like mine, the most significant 16 bits (MSB 16) of userspace virtual addresses are 0 and 1 for kernel virtual addresses.

This means we can normally spot kernel addresses at a glance as they begin `0xffff....` while userspace addresses begin with `0x0000...` and are as a result typically shorter.

Anyway, before we scroll too far away from the code block (oops), let’s unpack some of these lines of output shall we?

- **Lines 2-6**: here we can see the mappings for the binary being run, found at `/usr/bin/cat`. Why is there multiple mappings for one binary file? Typically programs are made up of multiple sections, with differing perms. The .text section where the code is? We’ll want that readable & executable. Some portions of data, like our static consts want to be read only (.rodata), while mutable data wants to be readable and writable (.data) \[1\]
- **Line 7:** procfs uses the pseudo-path `[heap]` to describe the mapping for the heap (no surprise there); a dynamic memory pool
- **Lines 8,10-15:** next up we can see several shared libraries being mapped into memory, for the program to use. We can see locale information and libc; again these may be split up into multiple mappings as touched on a moment ago \[2\]
- **Lines 9,16,17:** these weird mappings with no pathname, are called **anonymous mappings** and are not backed by any file. This is essentially a blank memory region that a userspace process can use at it’s discretion. Examples of anonymous mappings include both the stack and the heap \[3\]
- **Lines 18-22:** `ld.so` is the dynamic linker that is invoked anytime we run a dynamically linked program (a quick check of `file /usr/bin/cat` will confirm this is indeed a dynamically linked program!)
- **Line 23:** another pseudo-path, `[stack]` is the mapping for our process’s stack space
- **Line 25:** The “virtual dynamic shared object” (or vDSO) is a small shared library exported by the kernel to accelerate the execution of certain system calls that do not necessarily have to run in kernel space \[5\]
- **Line 24:** The `vvar` is a special page mapped into memory in order to store a “mirror” of kernel variables required by the virtual syscalls exported by the kernel
- **Line 26:** The `vsyscall` mapping is actually defunct; it was a legacy mapping that actually provided an executable mapping of kernel code for specific syscalls that didn’t require elevated privileges and hence the whole user  -\> kernel mode context switch. Suffice to say it’s defunct now, and calls to vsyscall table still work for compatible, but now actually trap and act as a normal syscall \[6\]

And just like that we’ve pieced together the various userspace (and some kernel stuff) mappings for an everyday program like `cat`! Pretty neat. In addition we’ve dived into some of the tools the kernel provides us to examine this information.

------------------------------------------------------------------------

1.  For more information on the different sections of our binary, we can cross-reference the `offset` information we get from `/proc/self/maps` with the ELF section headers using `objdump -h /usr/bin/cat`
2.  `ldd` lets us print the shared libraries required by a program, we can explore this more by checking out `ldd /usr/bin/cat`, though for reasons out of scope for this talk, it won’t look identically to our `maps` output
3.  If we want to get ahead of ourselves, `man 2 mmap` \[4\] describes the system call userspace programs use to ask the kernel to map regions of memory
4.  The `2` in `man 2 mmap` says we want to look at man section 2, for syscalls, and not section 3 for lib functions. `man -k mmap` lets us search all the sections for references to `mmap`
5.  [Implementing virtual system calls @ LWN](https://lwn.net/Articles/615809/)
6.  As expected, we can see the vsycall adress is located within the kernel half of the virtual address space, by the leading `0xffff...`

### The Setup

I think I’m going to cover kernel and hardware side of things in coming sections, but I think it’s worth touching on how we go from running `cat /proc/self/maps` to the memory mapping we saw above.



In the last part we mentioned that system calls act as the fundamental interface between userspace applications and the kernel. If an unprivileged userspace process needs to do a privileged action (e.g. map some memory), it can use the syscall interface to ask the kernel to carry out this action on it’s behalf \[1\].

Now that we know what’s being mapped, let’s have a closer look on how, by revisiting `strace`. `strace` simply traces the system calls and signals made by a program. As we know memory mapping is handled by the kernel and system calls are how programs get the kernel to do this, `strace` seems like a good bet!

``` console
$ strace cat /proc/self/maps
execve("/usr/bin/cat", ["cat", "/proc/self/maps"], 0x7fff3a014fd8 /* 61 vars */) = 0
brk(NULL)                               = 0x5622ee613000
arch_prctl(0x3001 /* ARCH_??? */, 0x7ffe5d536650) = -1 EINVAL (Invalid argument)
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
newfstatat(3, "", {st_mode=S_IFREG|0644, st_size=185283, ...}, AT_EMPTY_PATH) = 0
mmap(NULL, 185283, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7fa129bcd000
close(3)                                = 0
openat(AT_FDCWD, "/usr/lib/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\320\324\2\0\0\0\0\0"..., 832) = 832
pread64(3, "\6\0\0\0\4\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0"..., 784, 64) = 784
pread64(3, "\4\0\0\0@\0\0\0\5\0\0\0GNU\0\2\0\0\300\4\0\0\0\3\0\0\0\0\0\0\0"..., 80, 848) = 80
pread64(3, "\4\0\0\0\24\0\0\0\3\0\0\0GNU\0\205vn\235\204X\261n\234|\346\340|q,\2"..., 68, 928) = 68
newfstatat(3, "", {st_mode=S_IFREG|0755, st_size=2463384, ...}, AT_EMPTY_PATH) = 0
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa129bcb000
pread64(3, "\6\0\0\0\4\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0"..., 784, 64) = 784
mmap(NULL, 2136752, PROT_READ, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7fa1299c1000
mprotect(0x7fa1299ed000, 1880064, PROT_NONE) = 0
mmap(0x7fa1299ed000, 1531904, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2c000) = 0x7fa1299ed000
mmap(0x7fa129b63000, 344064, PROT_READ, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1a2000) = 0x7fa129b63000
mmap(0x7fa129bb8000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1f6000) = 0x7fa129bb8000
mmap(0x7fa129bbe000, 51888, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fa129bbe000
close(3)                                = 0
mmap(NULL, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa1299be000
arch_prctl(ARCH_SET_FS, 0x7fa1299be740) = 0
set_tid_address(0x7fa1299bea10)         = 28003
set_robust_list(0x7fa1299bea20, 24)     = 0
rseq(0x7fa1299bf0e0, 0x20, 0, 0x53053053) = 0
mprotect(0x7fa129bb8000, 12288, PROT_READ) = 0
mprotect(0x5622ec6d3000, 4096, PROT_READ) = 0
mprotect(0x7fa129c30000, 8192, PROT_READ) = 0
prlimit64(0, RLIMIT_STACK, NULL, {rlim_cur=8192*1024, rlim_max=RLIM64_INFINITY}) = 0
munmap(0x7fa129bcd000, 185283)          = 0
getrandom("\x62\xf6\x2b\x64\xd3\x81\xee\x98", 8, GRND_NONBLOCK) = 8
brk(NULL)                               = 0x5622ee613000
brk(0x5622ee634000)                     = 0x5622ee634000
openat(AT_FDCWD, "/usr/lib/locale/locale-archive", O_RDONLY|O_CLOEXEC) = 3
newfstatat(3, "", {st_mode=S_IFREG|0644, st_size=3053472, ...}, AT_EMPTY_PATH) = 0
mmap(NULL, 3053472, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7fa1296d4000
close(3)                                = 0
newfstatat(1, "", {st_mode=S_IFCHR|0600, st_rdev=makedev(0x88, 0x1), ...}, AT_EMPTY_PATH) = 0
openat(AT_FDCWD, "/proc/self/maps", O_RDONLY) = 3
newfstatat(3, "", {st_mode=S_IFREG|0444, st_size=0, ...}, AT_EMPTY_PATH) = 0
fadvise64(3, 0, 0, POSIX_FADV_SEQUENTIAL) = 0
mmap(NULL, 139264, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa129bd9000
read(3, "5622ec6c9000-5622ec6cb000 r--p 0"..., 131072) = 2153
write(1, "5622ec6c9000-5622ec6cb000 r--p 0"..., 21535622ec6c9000-5622ec6cb000 r--p 00000000 00:19 868257                     /usr/bin/cat
5622ec6cb000-5622ec6d0000 r-xp 00002000 00:19 868257                     /usr/bin/cat
5622ec6d0000-5622ec6d3000 r--p 00007000 00:19 868257                     /usr/bin/cat
5622ec6d3000-5622ec6d4000 r--p 00009000 00:19 868257                     /usr/bin/cat
5622ec6d4000-5622ec6d5000 rw-p 0000a000 00:19 868257                     /usr/bin/cat
5622ee613000-5622ee634000 rw-p 00000000 00:00 0                          [heap]
7fa1296d4000-7fa1299be000 r--p 00000000 00:19 2289972                    /usr/lib/locale/locale-archive
7fa1299be000-7fa1299c1000 rw-p 00000000 00:00 0 
7fa1299c1000-7fa1299ed000 r--p 00000000 00:19 2289282                    /usr/lib/libc.so.6
7fa1299ed000-7fa129b63000 r-xp 0002c000 00:19 2289282                    /usr/lib/libc.so.6
7fa129b63000-7fa129bb7000 r--p 001a2000 00:19 2289282                    /usr/lib/libc.so.6
7fa129bb7000-7fa129bb8000 ---p 001f6000 00:19 2289282                    /usr/lib/libc.so.6
7fa129bb8000-7fa129bbb000 r--p 001f6000 00:19 2289282                    /usr/lib/libc.so.6
7fa129bbb000-7fa129bbe000 rw-p 001f9000 00:19 2289282                    /usr/lib/libc.so.6
7fa129bbe000-7fa129bcd000 rw-p 00000000 00:00 0 
7fa129bd9000-7fa129bfb000 rw-p 00000000 00:00 0 
7fa129bfb000-7fa129bfd000 r--p 00000000 00:19 2289273                    /usr/lib/ld-linux-x86-64.so.2
7fa129bfd000-7fa129c24000 r-xp 00002000 00:19 2289273                    /usr/lib/ld-linux-x86-64.so.2
7fa129c24000-7fa129c2f000 r--p 00029000 00:19 2289273                    /usr/lib/ld-linux-x86-64.so.2
7fa129c30000-7fa129c32000 r--p 00034000 00:19 2289273                    /usr/lib/ld-linux-x86-64.so.2
7fa129c32000-7fa129c34000 rw-p 00036000 00:19 2289273                    /usr/lib/ld-linux-x86-64.so.2
7ffe5d517000-7ffe5d538000 rw-p 00000000 00:00 0                          [stack]
7ffe5d5c7000-7ffe5d5cb000 r--p 00000000 00:00 0                          [vvar]
7ffe5d5cb000-7ffe5d5cd000 r-xp 00000000 00:00 0                          [vdso]
ffffffffff600000-ffffffffff601000 --xp 00000000 00:00 0                  [vsyscall]
) = 2153
read(3, "", 131072)                     = 0
munmap(0x7fa129bd9000, 139264)          = 0
close(3)                                = 0
close(1)                                = 0
close(2)                                = 0
exit_group(0)                           = ?
+++ exited with 0 +++
```

As we mentioned last time, there’s **a lot going on here** for a program we expect to just be doing the equivalent of `read(/proc/self/maps)` and `write(stdout`. In fact, on **line 47** & **48** we can see just that happening. So what’s up with the rest?

I’m thinking it might be out-of-scope for this post to do a line-by-line breakdown (maybe a more specific post about ELFs and processes and stuff?), but let’s highlight some of the main syscalls used for setting up our memory mapping:

#### brk()

The `brk()` syscall is used to adjust the location of the “program break”, which defines the end of the process’s data segment (aka end of the heap).

❓

`void *brk(void *addr);`

`brk(NULL)` makes no adjustment, so returns the current program break. We can see this on **line 3**, which is likely called during initialisation to figure out where the current heap ends, for memory management libs like malloc.

Later on **line 37** we can see another call to `brk()`, asking to extend the program break to `0x5622ee634000`. If we take a look at the `maps` output on **line 53**, we can in fact see the heap does end at `0x5622ee634000` now! Sweet :)

#### mmap()

This is the big gun, responsible for the fabled “mappings” we’ve been yapping on about. The `mmap()` syscall is used to create memory mappings (and `munmap()` for unmapping them). For more info on args and more, don’t forget to console `man 2 mmap`.

❓

`void *mmap(void *addr, size_t length, int prot, int flags, int fd, off_t offset);`

Remember, we can use `mmap()` to either map a file or device to virtual memory or simply to allocate a black region of memory to a virtual address:

- On **line 10** we `openat()` our libc, identified by file descriptor 3. Then in **lines 18-22** we can see we make a series of `mmap()`’s with the fd arg set to 3; we can then cross-reference the permissions (e.g. `PROT_READ|PROT_WRITE`) and return addresses with the libc mappings we can see in our `maps` output on **lines 56-61**
- Conversely we can see some anonymous mappings, where the fd is set to `-1` and `mmap()` is passed the flag `MAP_ANONYMOUS`,  like  **line 46** \[2\]

#### mprotect()

If  `mmap()` is the big gun, then `mprotect()` is the syscall used set the protections for a mapped region of memory (yeah, I couldn’t think of an analogy okay).  Typically these protections may be any combination of read, write and execute access flags.

❓

`int mprotect(void *addr, size_t len, int prot);`

While we can include protection flags via the `prot`  arg for `mmap()`, `mprotect()` allows us to set page granular access flags which we can update with each call, without having to map new regions of memory each time.

#### execve()

Some of you might have noticed that while we can see regions being mapped for locale-archive, libc; what happened to `/usr/bin/cat` itself? Again, trying to keep within scope of virtual memory, this setup is handled by the initial `execve()` system call on **line 1**.

❓

`int execve(const char *pathname, char *const argv[], char *const envp[]);`

When a new processes is forked (created), execve() then “executes the program referred to by `pathname`” \[3\]. This initial call to `execve()` parses our ELF file `/usr/bin/cat` and initialises the necessary segments (e.g. text, stack, heap and  data).

It’s worth noting that when a process is created, it is done via `fork()`, which creates a new process by duplicating the calling process. However, `execve()` will create a new and empty virtual address space for the application at `pathname`.

------------------------------------------------------------------------

1.  A deep dive on syscalls is out of scope for this talk, but I might touch on it down the line. In the meantime, `man` pages are your friend, try `man syscalls` :)  
2.  Honestly, without digging some more not 100% sure what these are being used for, though likely for something by the shared libs - exercise for the reader? :P
3.  Surprise, surprise this is from `man 2 execve`!

### Threads

So, we’ve talked a lot about how are usermode processes live in happy isolation within the sandboxed virtual address spaces. Is this ***always*** the case? Nope, and one reason is threads.

Threads are essentially light-weight processes and represent a flow of execution within an application. The reason they’re “light-weight processes” is that when threads are created, instead of using `fork()` they use a similar system call, `clone()`.

`clone()` is also used to create a process, but allows more control over what resources are shared between the caller and callee. As a result, in Linux, threads ***share*** the same virtual address space and mappings but have separate heap & stack mappings.

### ASLR

Some of you eager enough to run these commands multiple times may have noticed that the addresses for your mappings change each time you run `cat`, what gives?



Without deviating too off-topic, this is actually normal! It’d be more concerning if nothing changed, as this is the result of a mitigation called ASLR: Address Space Layout Randomisation \[1\].

ASLR does exactly what it says on the tin, randomising by default the virtual addresses that the stack, heap and shared libraries are mapped to each time the program is run. This helps mitigate exploitation techniques that rely on knowing where stuff is in memory!

Modern compilers are also able to compile code as “position independent” \[2\], which tl;dr means we can also randomise the virtual address of the executable code as well! Pretty neat :)

Of course, I’d be remiss if I didn’t mention there’s a procfs file to check whether ASLR is currently enabled: `cat /proc/sys/kernel/randomize_va_space` \[3\]

------------------------------------------------------------------------

1.  <https://en.wikipedia.org/wiki/Address_space_layout_randomization>
2.  [https://en.wikipedia.org/wiki/Position-independent_code](https://en.wikipedia.org/wiki/Position-independent_code#:~:text=In%20computing,%20position-independent%20code,regardless%20of%20its%20absolute%20address)
3.  <https://linux-audit.com/linux-aslr-and-kernelrandomize_va_space-setting/>

### Wrapping Up In UVAS



And there we have it! Hopefully this has provided a high level overview of the user virtual address space, we’ve covered:

- That the virtual address space is split up into two sections, the lower half being the unprivileged user virtual address space (UVAS)
- Userspace is limited in what it can do, but can ask the kernel to perform privileged actions on its behalf via the system call interface
- We looked at what a typical application, `cat`, uses the UVAS for: loading and mapping the code and data into memory, allocating memory for the heap and stack as well as mapping in library files such as libc and locale information
- Next we took a brief look at the system calls that userspace applications can use to get the kernel to setup their virtual address space

## Next Time!

Can you believe I planned to wrap everything up in this post? Of course I did, whoops! Suffice to say, we still have a lot to cover in an indeterminate number of posts!

Coming up we’ll context switch and take a closer look at what goes in in the kernel virtual address space and how it’s mapped. After that, we’ll get technical as we figure out how all this is implemented via the kernel and hardware features.

Thanks for reading!

exit(0);
