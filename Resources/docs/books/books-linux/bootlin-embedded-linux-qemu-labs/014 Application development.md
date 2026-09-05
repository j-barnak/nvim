**Application development**

*Objective: Compile and run your own ncurses application on the target.*

**Setup**

Go to the \$HOME/embedded-linux-qemu-labs/appdev directory.

**Compile your own application**

We will re-use the system built during the *Buildroot lab* and add to it our own application.

In the lab directory the file app.c contains a very simple *ncurses* application. It is a simple game where you need to reach a target using the arrow keys of your keyboard. We will compile and integrate this simple application to our Linux system.

Buildroot has generated toolchain wrappers in output/host/bin, which make it easier to use the toolchain, since these wrappers pass some mandatory flags (especially the --sysroot *gcc* flag, which tells *gcc* where to look for the headers and libraries).

Let’s add this directory to our PATH:

\$ export PATH=\$HOME/embedded-linux-qemu-labs/buildroot/buildroot/output/host/bin:\$PATH

Let’s try to compile the application:

\$ arm-linux-gcc -o app app.c

It complains about undefined references to some symbols. This is normal, since we didn’t tell the compiler to link with the necessary libraries. So let’s use pkg-config to query the *pkg-config* database about the location of the header files and the list of libraries needed to build an application against *ncurses* 9: \$ arm-linux-gcc -o app app.c \$(pkg-config --libs --cflags ncurses) Our application is now compiled! Copy the generated binary to the NFS root filesystem (in the root/

directory for example), start your system, and run your application!

9Again, output/host/bin has a special pkg-config that automatically knows where to look, so it already knows the right paths to find .pc files and their sysroot.

40

© 2004-2025 [Bootlin](https://bootlin.com), CC BY-SA license

Embedded Linux System Development