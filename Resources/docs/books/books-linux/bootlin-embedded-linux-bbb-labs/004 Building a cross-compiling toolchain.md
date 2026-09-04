**Building a cross-compiling toolchain**

 

 

*Objective: Learn how to compile your own cross-compiling toolchain for the* *musl C library*

 

After this lab, you will be able to:

• Configure the *crosstool-ng* tool

• Execute *crosstool-ng* and build up your own cross-compiling toolchain

**Setup**

Go to the \$HOME/embedded-linux-bbb-labs/toolchain directory.

For this lab, you need a system or VM with a least 4 GB of RAM.

**Install needed packages**

Install the packages needed for this lab:

\$ sudo apt install build-essential git autoconf bison flex texinfo help2man gawk libtool-bin \\

libncurses5-dev unzip

**Getting Crosstool-ng**

Let’s download the sources of Crosstool-ng, through its git source repository, and switch to a commit that we have tested:

\$ git clone https://github.com/crosstool-ng/crosstool-ng \$ cd crosstool-ng/

\$ git checkout crosstool-ng-1.26.0

**Building and installing Crosstool-ng**

As we are not building Crosstool-ng from a release archive but from a git repository, we first need to generate a configure script and more generally all the generated files that are shipped in the source archive for a release:

\$ ./bootstrap

 

We can then either install Crosstool-ng globally on the system, or keep it locally in its download direc-

tory. We’ll choose the latter solution. As documented at [https://crosstool-ng.github.io/docs/install/](https://crosstool-ng.github.io/docs/install/#hackers-way)

[\#hackers-way ,](https://crosstool-ng.github.io/docs/install/#hackers-way) do:

\$ ./configure --enable-local

\$ make

 

Then you can get Crosstool-ng help by running

\$ ./ct-ng help

 

© 2004-2025 [Bootlin,](https://bootlin.com) CC BY-SA license 5 **Configure the toolchain to produce**

A single installation of Crosstool-ng allows to produce as many toolchains as you want, for different archi-tectures, with different C libraries and different versions of the various components.

Crosstool-ng comes with a set of ready-made configuration files for various typical setups: Crosstool-ng calls them *samples*. They can be listed by using ./ct-ng list-samples.

We will load the Cortex A8 sample. Load it with the ./ct-ng command.

Then, to refine the configuration, let’s run the menuconfig interface:

\$ ./ct-ng menuconfig

In Path and misc options:

• If not set yet, enable Try features marked as EXPERIMENTAL

• In some distributions, wget2 is used instead of wget. Since wget2 doesn’t support the passive-ftp option,

you may need to remove the--passive-ftp flags from the DOWNLOAD_WGET_OPTIONS

In Target options:

• Set Use specific FPU (ARCH_FPU) to vfpv3.

• Set Floating point to hardware (FPU).

In Toolchain options:

• Set Tuple's vendor string (TARGET_VENDOR) to training.

• Set Tuple's alias (TARGET_ALIAS) to arm-linux. This way, we will be able to use the compiler with

arm-linux-gcc, a shorter name that the name based on complete toolchain tuple.

In Operating System:

• Set Version of linux to the closest, but older version to 6.6. It’s important that the kernel headers

used in the toolchain are not more recent than the kernel that will run on the board (v6.6).

In C-library:

• If not set yet, set C library to musl (LIBC_MUSL)

• Keep the default version that is proposed

In C compiler:

• Set Version of gcc to 13.2.0.

• Make sure that C++ (CC_LANG_CXX) is enabled

In Debug facilities:

• Remove all options here. Some debugging tools can be provided in the toolchain, but they can also be

built by filesystem building tools.

Explore the different other available options by traveling through the menus and looking at the help for some of the options. Don’t hesitate to ask your trainer for details on the available options. However, remember that we tested the labs with the configuration described above. You might waste time with unexpected issues if you customize the toolchain configuration.

**Produce the toolchain**

Nothing is simpler:

6 © 2004-2025 [Bootlin](https://bootlin.com), CC BY-SA license \$ ./ct-ng build

The toolchain will be installed by default in \$HOME/x-tools/. That’s something you could have changed in Crosstool-ng’s configuration.

And wait!

**Testing the toolchain**

You can now test your toolchain by adding \$HOME/x-tools/arm-training-linux-musleabihf/bin/ to your PATH environment variable and compiling the simple hello.c program in your main lab directory with arm-linux-gcc:

\$ arm-linux-gcc -o hello hello.c

You can use the file command on your binary to make sure it has correctly been compiled for the ARM architecture.

Did you know that you can still execute this binary from your x86 host? To do this, install the QEMU user emulator, which just emulates target instruction sets, not an entire system with devices:

\$ sudo apt install qemu-user

Now, try to run QEMU ARM user emulator:

\$ qemu-arm hello

qemu-arm: Could not open '/lib/ld-musl-armhf.so.1': No such file or directory

What’s happening is that qemu-arm is missing the shared library loader (compiled for ARM) that this binary relies on. Let’s find it in our newly compiled toolchain:

\$ find ~/x-tools -name ld-musl-armhf.so.1

/home/tux/x-tools/arm-training-linux-musleabihf/arm-training-linux-musleabihf/sysroot/lib/ ld-musl-armhf.so.1

We can now use the-L option of qemu-arm to let it know where shared libraries are:

\$ qemu-arm -L ~/x-tools/arm-training-linux-musleabihf/arm-training-linux-musleabihf/sysroot \\

hello

Hello world!

**Cleaning up**

*Do this only if you have limited storage space. In case you made a mistake in the toolchain configuration, you may need to run Crosstool-ng again, keeping generated files would save a significant amount of time.*

To save about 9 GB of storage space, do a ./ct-ng clean in the Crosstool-NG source directory. This will remove the source code of the different toolchain components, as well as all the generated files that are now useless since the toolchain has been installed in \$HOME/x-tools.

 

© 2004-2025 [Bootlin,](https://bootlin.com) CC BY-SA license 7