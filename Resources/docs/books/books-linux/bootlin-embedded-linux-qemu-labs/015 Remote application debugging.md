**Remote application debugging**

*Objective: Use* strace *and* ltrace *to diagnose program issues. Use* gdbserver *and a cross-debugger to remotely debug an embedded application* **Setup**

Go to the \$HOME/embedded-linux-qemu-labs/debugging directory. Create an nfsroot directory.

**Debugging setup**

Because of issues in *gdb* and *ltrace* in the musl version that we are using in our toolchain, we will use a different toolchain in this lab, based on *glibc*.

As *glibc* has more complete features than lighter libraries, it looks like a good idea to do your application debugging work with a *glibc* toolchain first, and then switch to lighter libraries once your application and software stack is production ready.

As done in the *Buildroot* lab, clone once again the Buildroot *Git* repository, and checkout the tag corresponding to the latest 2023.02.\<n\> release (Long Term Support), which we have tested for this lab.

Then, in the menuconfig interface, configure the target architecture as done previously but configure the toolchain and target packages differently:

• In Toolchain:

**–** Toolchain type: External toolchain

**–** Toolchain: Bootlin toolchains

**–** Toolchain origin: Toolchain to be downloaded and installed

**–** Bootlin toolchain variant: armv7-eabihf glibc stable 2022.08-1

**–** Select Copy gdb server to the Target

• Target packages

**–** Debugging, profiling and benchmark

∗ Select ltrace

∗ Select strace

Now, build your root filesystem.

Go back to the \$HOME/embedded-linux-qemu-labs/debugging directory and extract the buildroot/output/

images/rootfs.tar archive in the nfsroot directory.

Add this directory to the /etc/exports file and run sudo exportfs -r.

Boot your ARM board over NFS on this new filesystem, using the same kernel as before.

**Using strace**

Now, go to the \$HOME/embedded-linux-qemu-labs/debugging directory.

strace allows to trace all the system calls made by a process: opening, reading and writing files, starting other processes, accessing time, etc. When something goes wrong in your application, strace is an invaluable tool to see what it actually does, even when you don’t have the source code.

© 2004-2025 [Bootlin,](https://bootlin.com) CC BY-SA license 41

Embedded Linux System Development

Update the PATH:

\$ export PATH=\$HOME/embedded-linux-qemu-labs/debugging/buildroot/output/host/bin:\$PATH

With your cross-compiling toolchain compile the data/vista-emulator.c program, copy the resulting binary to the /root directory of the root filesystem and then strip it.

Back to target system, try to run the /root/vista-emulator program. It should hang indefinitely!

Interrupt this program by hitting \[Ctrl\] \[C\].

Now, running this program again through the strace command and understand why it hangs. You can guess it without reading the source code!

Now add what the program was waiting for, and now see your program proceed to another bug, failing with a segmentation fault.

**Using ltrace**

Now run the program through ltrace.

Now you should see what the program does: it tries to consume as much system memory as it can!

Also run the program through ltrace -c, to see what function call statistics this utility can provide.

It’s also interesting to run the program again with strace. You will see that memory allocations translate into mmap() system calls. That’s how you can recognize them when you’re using strace.

**Using gdbserver**

We are now going to use gdbserver to understand why the program segfaults.

Compile vista-emulator.c again with the -g option to include debugging symbols. This time, just keep it on your workstation, as you already have the version without debugging symbols on your target.

Then, on the target side, run vista-emulator under gdbserver. gdbserver will listen on a TCP port for a connection from gdb, and will control the execution of vista-emulator according to the gdb commands:

=\> gdbserver localhost:2345 vista-emulator

On the host side, run arm-linux-gdb (also found in your toolchain): \$ arm-linux-gdb vista-emulator

gdb starts and loads the debugging information from the vista-emulator binary that has been compiled with

-g.

Then, we need to tell where to find our libraries, since they are not present in the default /lib and /usr/lib directories on your workstation. This is done by setting the gdb sysroot variable (on one line): (gdb) set sysroot /home/\<user\>/embedded-linux-qemu-labs/debugging/\\ buildroot/output/staging

Of course, replace \<user\> by your actual user name.

And tell gdb to connect to the remote system:

(gdb) target remote \<target-ip-address\>:2345

Then, use gdb as usual to set breakpoints, look at the source code, run the application step by step, etc.

Graphical versions of gdb, such as ddd can also be used in the same way. In our case, we’ll just start the program and wait for it to hit the segmentation fault:

42

© 2004-2025 [Bootlin](https://bootlin.com), CC BY-SA license

Embedded Linux System Development

(gdb) continue

You could then ask for a backtrace to see where this happened: (gdb) backtrace

This will tell you that the segmentation fault occurred in a function of the C library, called by our program.

This should help you in finding the bug in our application.

**Post mortem analysis**

Following the details in the slides, configure your shell on the target to get a core file dumped when you run vista-emulator again.

Once you have such a file, inspect it with arm-linux-gdb on the target, set the sysroot setting, and then generate a backtrace to see where the program crashed.

This way, you can have information about the crash without running the program through the debugger.

**What to remember**

During this lab, we learned that...

• It’s easy to study the behavior of programs and diagnose issues without even having the source code, thanks to strace and ltrace.

• You can leave a small gdbserver program (about 300 KB) on your target that allows to debug target applications, using a standard gdb debugger on the development host.

• It is fine to strip applications and binaries on the target machine, as long as the programs and libraries with debugging symbols are available on the development host.

• Thanks to core dumps, you can know where a program crashed, without having to reproduce the issue by running the program through the debugger.

© 2004-2025 [Bootlin,](https://bootlin.com) CC BY-SA license 43

# Document Outline

- About this document
- Copying this document
- Training setup
  - Install lab data
  - Update your distribution
  - Install extra packages
  - More guidelines
- Building a cross-compiling toolchain
  - Setup
  - Install needed packages
  - Getting Crosstool-ng
  - Building and installing Crosstool-ng
  - Configure the toolchain to produce
  - Produce the toolchain
  - Testing the toolchain
  - Cleaning up
- Bootloader - U-Boot
  - Setup
  - Configuring and building U-Boot
  - Testing U-Boot
  - SD card setup
  - Testing U-Boot's environment
  - Setup networking between QEMU and the host
  - Setting up the TFTP server
  - Rescue binary
- Fetching Linux kernel sources
  - Setup
  - Cloning the mainline Linux tree
  - Accessing stable releases
- Kernel - Cross-compiling
  - Setup
  - Choose a particular stable version of Linux
  - Cross-compiling environment setup
  - Linux kernel configuration
  - Cross compiling
  - Load and boot the kernel using U-Boot
- Tiny embedded system with BusyBox
  - Lab implementation
  - Setup
  - Kernel configuration
  - Setting up the NFS server
  - Booting the system
  - Root filesystem with BusyBox
  - Virtual filesystems
  - System configuration and startup
  - Starting the shell in a proper terminal
  - Switching to shared libraries
  - Implement a web interface for your device
  - Going further
    - Initramfs booting
- Accessing Hardware Devices
  - Goals
  - Setup
  - Exploring /dev
  - Exploring /sys
- Filesystems - Block file systems
  - Goals
  - Setup
  - Filesystem support in the kernel
  - Format the third partition
  - Adding a tmpfs partition for log files
  - Making a SquashFS image
  - Booting on the SquashFS partition
  - Store the kernel image and DTB on the SD card
- Third party libraries and applications
  - Figuring out library dependencies
  - Preparation
  - Testing
  - alsa-lib
  - Alsa-utils
  - ipcalc
  - Final touch
- Using a build system, example with Buildroot
  - Goals
  - Setup
  - Get Buildroot and explore the source code
  - Configure Buildroot
  - Generate the embedded Linux system
  - Run the generated system
  - Analyzing dependencies
- Application development
  - Setup
  - Compile your own application
- Remote application debugging
  - Setup
  - Debugging setup
  - Using strace
  - Using ltrace
  - Using gdbserver
  - Post mortem analysis
  - What to remember