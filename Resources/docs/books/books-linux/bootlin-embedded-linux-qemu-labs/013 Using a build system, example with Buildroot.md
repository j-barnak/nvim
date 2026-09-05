**Using a build system, example with Buil-**

**droot**

*Objectives: discover how a build system is used and how it works, with the* *example of the Buildroot build system. Build a full Linux system, including* *the Linux kernel.*

**Goals**

Compared to the previous lab, we are going to build a more elaborate system, still containing *alsa-utils* (and of course its *alsa-lib* dependency), but this time using Buildroot, an automated build system.

The automated build system will also allow us to add more packages and play real audio on our system, thanks to the *Music Player Daemon (mpd)* (<https://www.musicpd.org/> and its *mpc* client.

As in a real project, we will also build the Linux kernel from Buildroot, and install the kernel modules in the root filesystem.

*Important note: because of the current sound playing issues mentioned before, this lab will be less exhaustive* *compared to our instructions on real hardware. You should be able to run the commands in the QEMU*

*emulated machine though, proving that the tools were built correctly. So, we will build tools like mpd and* *mpc, but won’t test them because of the absence of sound.*

**Setup**

Go to the \$HOME/embedded-linux-qemu-labs/buildroot directory.

**Get Buildroot and explore the source code**

The official Buildroot website is available at [https://buildroot.org/.](https://buildroot.org/) Clone the *Git* repository: git clone https://git.buildroot.net/buildroot

cd buildroot

Now checkout the tag corresponding to the latest 2023.02.\<n\> release (Long Term Support), which we have tested for this lab.

Several subdirectories or files are visible, the most important ones are:

• boot contains the Makefiles and configuration items related to the compilation of common bootloaders (GRUB, U-Boot, Barebox, etc.)

• board contains board specific configurations and root filesystem overlays.

• configs contains a set of predefined configurations, similar to the concept of defconfig in the kernel.

• docs contains the documentation for Buildroot.

• fs contains the code used to generate the various root filesystem image formats

• linux contains the Makefile and configuration items related to the compilation of the Linux kernel

• Makefile is the main Makefile that we will use to use Buildroot: everything works through Makefiles in Buildroot;

36

© 2004-2025 [Bootlin](https://bootlin.com), CC BY-SA license

Embedded Linux System Development

• package is a directory that contains all the Makefiles, patches and configuration items to compile the user space applications and libraries of your embedded Linux system. Have a look at various subdirectories and see what they contain;

• system contains the root filesystem skeleton and the *device tables* used when a static /dev is used;

• toolchain contains the Makefiles, patches and configuration items to generate the cross-compiling toolchain.

**Configure Buildroot**

In our case, we would like to:

• Generate an embedded Linux system for ARM;

• Use an already existing external toolchain instead of having Buildroot generating one for us;

• Compile the Linux kernel and deploy its modules in the root filesystem;

• Integrate *BusyBox*, *alsa-utils*, *mpd*, *mpc* and *evtest* in our embedded Linux system;

• Integrate the target filesystem into a tarball

To run the configuration utility of Buildroot, simply run:

\$ make menuconfig

Set the following options. Don’t hesitate to press the Help button whenever you need more details about a given option:

• Target options

**–** Target Architecture: ARM (little endian)

**–** Target Architecture Variant: cortex-A9

**–** Enable NEON SIMD extension support: Enabled

**–** Enable VFP extension support: Enabled

**–** Target ABI: EABIhf

**–** Floating point strategy: VFPv3-D16

• Toolchain

**–** Toolchain type: External toolchain

**–** Toolchain: Custom toolchain

**–** Toolchain path: use the toolchain you built: /home/\<user\>/x-tools/arm-training-linux-musleabihf (replace \<user\> by your actual user name)

**–** External toolchain gcc version: 12.x

**–** External toolchain kernel headers series: 6.1.x or later

**–** External toolchain C library: musl (experimental)

**–** We must tell Buildroot about our toolchain configuration, so select Toolchain has SSP support?

and Toolchain has C++ support?. Buildroot will check these parameters anyway.

• Kernel

**–** Enable Linux Kernel

**–** Set Kernel version to Latest version (6.1)

**–** Set Kernel configuration to Using an in-tree defconfig file

© 2004-2025 [Bootlin,](https://bootlin.com) CC BY-SA license 37

Embedded Linux System Development

**–** Set Defconfig name to vexpress

**–** Select Build a Device Tree Blob (DTB)

**–** Set In-tree Device Tree Source file names to vexpress-v2p-ca9

• Target packages

**–** Keep BusyBox (default version) and keep the BusyBox configuration proposed by Buildroot;

**–** Audio and video applications

∗ Select alsa-utils, and in the submenu:

· Select alsamixer. You will be able to test this application too, and that will also pull the ncurses library, which we will also use in the next lab.

· Select speaker-test

∗ Select mpd, and in the submenu:

· Keep only alsa, vorbis and tcp sockets

∗ Select mpd-mpc.

• Filesystem images

**–** Select tar the root filesystem

Exit the menuconfig interface. Your configuration has now been saved to the .config file.

**Generate the embedded Linux system**

Just run:

\$ make

Buildroot will first create a small environment with the external toolchain, then download, extract, configure, compile and install each component of the embedded system.

All the compilation has taken place in the output/ subdirectory. Let’s explore its contents:

• build, is the directory in which each component built by Buildroot is extracted, and where the build actually takes place

• host, is the directory where Buildroot installs some components for the host. As Buildroot doesn’t want to depend on too many things installed in the developer machines, it installs some tools needed to compile the packages for the target. In our case it installed *pkg-config* (since the version of the host may be ancient) and tools to generate the root filesystem image ( *genext2fs*, *makedevs*, *fakeroot*).

• images, which contains the final images produced by Buildroot. In our case it contains a tarball of the filesystem, called rootfs.tar, plus the compressed kernel and Device Tree binary. Depending on the configuration, there could also a bootloader binary or a full SD card image.

• staging, which contains the “build” space of the target system. All the target libraries, with headers and documentation. It also contains the system headers and the C library, which in our case have been copied from the cross-compiling toolchain.

• target, is the target root filesystem. All applications and libraries, usually stripped, are installed in this directory. However, it cannot be used directly as the root filesystem, as all the device files are missing: it is not possible to create them without being root, and Buildroot has a policy of not running anything as root.

38

© 2004-2025 [Bootlin](https://bootlin.com), CC BY-SA license

Embedded Linux System Development

**Run the generated system**

Go back to the \$HOME/embedded-linux-qemu-labs/buildroot/ directory. Create a new nfsroot directory that is going to hold our system, exported over NFS. Go into this directory, and untar the rootfs using: \$ tar xvf ../buildroot/output/images/rootfs.tar

Add our nfsroot directory to the list of directories exported by NFS in /etc/exports.

Also update the kernel and Device Tree binaries used by your board, from the ones compiled by Buildroot in output/images/.

Boot the board, and log in (root account, no password).

You should now reach a shell.

Even though we have no sound at the moment, you can run speaker-test to check that this application works. You can also test the alsamixer command too.

By running the ps command, you may also check whether the mpd server was started on your system. However, as said earlier, we won’t try to test it as we currently have no sound in QEMU on Ubuntu 22.04.

**Analyzing dependencies**

It’s always useful to understand the dependencies drawn by the packages we build.

First we need to install a *Graphviz*:

\$ sudo apt install graphviz

Now, let’s use Buildroot’s target to generate a dependency graph: \$ make graph-depends

We can now study the dependency graph:

\$ evince output/graphs/graph-depends.pdf

In particular, you can see that adding MPD and its client required to compile *Meson* for the host, and in turn, *Python 3* for the host too. This substantially contributed to the build time.

© 2004-2025 [Bootlin,](https://bootlin.com) CC BY-SA license 39

Embedded Linux System Development