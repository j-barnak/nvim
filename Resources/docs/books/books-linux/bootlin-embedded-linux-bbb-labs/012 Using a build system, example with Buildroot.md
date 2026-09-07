**Using a build system, example with Buil-**





**droot**



*Objectives: discover how a build system is used and how it works, with the* *example of the Buildroot build system. Build a full Linux system, including* *the Linux kernel.*



**Goals**

Compared to the previous lab, we are going to build a more elaborate system, still containing *alsa-utils* (and of course its *alsa-lib* dependency), but this time using Buildroot, an automated build system.

The automated build system will also allow us to add more packages and play real audio on our system,

thanks to the *Music Player Daemon (mpd)* (<https://www.musicpd.org/> and its *mpc* client.

As in a real project, we will also build the Linux kernel from Buildroot, and install the kernel modules in the root filesystem.

**Setup**

Go to the \$HOME/embedded-linux-bbb-labs/buildroot directory.

**Get Buildroot and explore the source code**

The official Buildroot website is available at [https://buildroot.org/.](https://buildroot.org/) Clone the *Git* repository:

git clone https://gitlab.com/buildroot.org/buildroot.git cd buildroot

Now checkout the tag corresponding to the latest 2024.02.\<n\> release (Long Term Support), which we have tested for this lab.

Several subdirectories or files are visible, the most important ones are:

• boot contains the Makefiles and configuration items related to the compilation of common bootloaders

(GRUB, U-Boot, Barebox, etc.)

• board contains board specific configurations and root filesystem overlays.

• configs contains a set of predefined configurations, similar to the concept of defconfig in the kernel.

• docs contains the documentation for Buildroot.

• fs contains the code used to generate the various root filesystem image formats

• linux contains the Makefile and configuration items related to the compilation of the Linux kernel

• Makefile is the main Makefile that we will use to use Buildroot: everything works through Makefiles

in Buildroot;

• package is a directory that contains all the Makefiles, patches and configuration items to compile

the user space applications and libraries of your embedded Linux system. Have a look at various subdirectories and see what they contain;

• system contains the root filesystem skeleton and the *device tables* used when a static /dev is used;


• toolchain contains the Makefiles, patches and configuration items to generate the cross-compiling

toolchain.

**Board specific configuration**

As we will want Buildroot to build a kernel with a custom configuration, and our custom patch, so let’s add our own subdirectory under board:

mkdir -p board/bootlin/training

Then, copy your kernel configuration and kernel patch:

cp ../../kernel/linux/.config board/bootlin/training/linux.config cp ../../kernel/linux/0001-Custom-DTS-for-Bootlin-lab.patch \\

board/bootlin/training/

We will configure Buildroot to use this kernel configuration.

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

**–** Target Architecture Variant: cortex-A8

**–** Target ABI: EABIhf

**–** Floating point strategy: VFPv3-D16

• Toolchain

**–** Toolchain type: External toolchain

**–** Toolchain: Custom toolchain

**–** Toolchain path: use the toolchain you built: /home/\<user\>/x-tools/arm-training-linux-

musleabihf (replace \<user\> by your actual user name)

**–** External toolchain gcc version: 13.x

**–** External toolchain kernel headers series: 6.4.x

**–** External toolchain C library: musl (experimental)

**–** We must tell Buildroot about our toolchain configuration, so select Toolchain has SSP support?

and Toolchain has C++ support?. Buildroot will check these parameters anyway.


• Kernel

**–** Enable Linux Kernel

**–** Set Kernel version to Custom version

**–** Set Kernel version to your kernel version. You can use make kernelversion to get it from the

Linux kernel source tree.

**–** Set Custom kernel patches to board/bootlin/training/0001-Custom-DTS-for-Bootlin-lab.patch

**–** Set Kernel configuration to Using a custom (def)config file)

**–** Set Configuration file path to board/bootlin/training/linux.config

**–** Select Build a Device Tree Blob (DTB)

**–** Set In-tree Device Tree Source file names to ti/omap/am335x-boneblack-custom

• Target packages

**–** Keep BusyBox (default version) and keep the BusyBox configuration proposed by Buildroot;

**–** Audio and video applications

∗ Select alsa-utils, and in the submenu:

· Only keep speaker-test

∗ Select mpd, and in the submenu:

· Keep only alsa, vorbis and tcp sockets

∗ Select mpd-mpc.

**–** Hardware handling

∗ Select evtest

This userspace application allows to test events from input devices. This way, we will be able to test the Nunchuk by getting details about which buttons were pressed.

• Filesystem images

**–** Select tar the root filesystem

Exit the menuconfig interface. Your configuration has now been saved to the .config file.

**Generate the embedded Linux system**

Just run:

\$ make

Buildroot will first create a small environment with the external toolchain, then download, extract, configure, compile and install each component of the embedded system.

All the compilation has taken place in the output/ subdirectory. Let’s explore its contents:

• build, is the directory in which each component built by Buildroot is extracted, and where the build

actually takes place

• host, is the directory where Buildroot installs some components for the host. As Buildroot doesn’t

want to depend on too many things installed in the developer machines, it installs some tools needed to compile the packages for the target. In our case it installed *pkg-config* (since the version of the host may be ancient) and tools to generate the root filesystem image (*genext2fs*, *makedevs*, *fakeroot*).


• images, which contains the final images produced by Buildroot. In our case it contains a tarball of the

filesystem, called rootfs.tar, plus the compressed kernel and Device Tree binary. Depending on the configuration, there could also a bootloader binary or a full SD card image.

• staging, which contains the “build” space of the target system. All the target libraries, with headers

and documentation. It also contains the system headers and the C library, which in our case have been copied from the cross-compiling toolchain.

• target, is the target root filesystem. All applications and libraries, usually stripped, are installed in

this directory. However, it cannot be used directly as the root filesystem, as all the device files are missing: it is not possible to create them without being root, and Buildroot has a policy of not running anything as root.

**Run the generated system**

Go back to the \$HOME/embedded-linux-bbb-labs/buildroot/ directory. Create a new nfsroot directory that is going to hold our system, exported over NFS. Go into this directory, and untar the rootfs using:

\$ tar xvf ../buildroot/output/images/rootfs.tar

Add our nfsroot directory to the list of directories exported by NFS in /etc/exports.

Also update the kernel and Device Tree binaries used by your board, from the ones compiled by Buildroot in output/images/.

Boot the board, and log in (root account, no password).

You should now reach a shell.

**Loading the USB audio module**

You can check that no kernel module is loaded yet. Try to load the snd_usb_audio module from the command line.

This should work. Check that Buildroot has deployed the modules for your kernel in /lib/modules.

Let’s automate this now!

Look at the /etc/inittab file generated by Buildroot (ask your instructor if you have any questions), and at the contents of the /etc/init.d/ directory, in particular of the rcS file.

You can see that rcS executes or sources all the /etc/init.d/S??\* files. We can add our own which will load the toplevel modules that we need.

Let’s do this by creating an *overlay directory*, typically under our board specific directory, that Buildroot will add after building the root filesystem:

mkdir -p board/bootlin/training/rootfs-overlay/

Then add a custom startup script, by adding an etc/init.d/S03modprobe executable file to the overlay directory, with the below contents:

\#!/bin/sh

modprobe snd-usb-audio

Then, go back to Buildroot’s configuration interface:

• System configuration

**–** Set Root filesystem overlay directories to board/bootlin/training/rootfs-overlay

Build your image again. This should be quick as Buildroot doesn’t need to recompile anything. It will just apply the root filesystem overlay.

Update your nfsroot directory, reboot the board and check that the snd_usb_audio module is loaded as expected.

You can run speaker-test to check that audio indeed works.

**Testing music playback with mpd and mpc**

The next thing we want to do is play real sound samples with the *Music Player Daemon (MPD)*. So, let’s

add music files 10 for MPD to play:

mkdir -p board/bootlin/training/rootfs-overlay/var/lib/mpd/music cp ../data/music/\* board/bootlin/training/rootfs-overlay/var/lib/mpd/music

Update your root filesystem. Thanks to NFS, you don’t need to restart your system.

Using the ps command, check that the mpd server was started by the system, as implemented by the /etc/ init.d/S95mpd script.

If that’s the case, you are now ready to run mpc client commands to control music playback. First, let’s make mpd process the newly added music files. Run this command on the target:

\# mpc update

You should see the files getting indexed, by displaying the contents of the /var/log/mpd.log file:

Jan 01 00:04 : exception: Failed to open '/var/lib/mpd/state': No such file or directory Jan 01 00:15 : update: added /2-arpent.ogg

Jan 01 00:15 : update: added /6-le-baguette.ogg

Jan 01 00:15 : update: added /4-land-of-pirates.ogg

Jan 01 00:15 : update: added /3-chronos.ogg

Jan 01 00:15 : update: added /1-sample.ogg

Jan 01 00:15 : update: added /7-fireworks.ogg

Jan 01 00:15 : update: added /5-ukulele-song.ogg

You can also check the list of available files:

\# mpc listall

1-sample.ogg

2-arpent.ogg

5-ukulele-song.ogg

3-chronos.ogg

7-fireworks.ogg

6-le-baguette.ogg

4-land-of-pirates.ogg

To play files, you first need to create a playlist. Let’s create a playlist by adding all music files to it:

\# mpc add /

You should now be able to start playing the songs in the playlist:

\# mpc play

Here are a few further commands for controlling playback:

• mpc volume +5: increase the volume by 5%

• mpc volume -5: reduce the volume by 5%

10 For the most part, these are public domain music files, except a small sample file... See the README.txt file in the directory

containing the files.


• mpc prev: switch to the previous song in the playlist.

• mpc next: switch to the next song in the playlist.

• mpc toggle: toggle between pause and playback modes.

If you find that changing the volume is not available, you can add a custom configuration for MPD, as the standard one provided by Buildroot doesn’t support allowing to change the audio playback volume with all sound cards we have tested. We will simply add this file to our overlay:

cp ../data/mpd.conf board/bootlin/training/rootfs-overlay/etc/

Run Buildroot again and update your root filesystem. Here again, you don’t need to reboot. It’s sufficient to restart MPD to make it read the new configuration file:

\# /etc/init.d/S95mpd restart

You can now make sure that modifying the volume works.

Later, we will compile and debug a custom MPD client application.

**Analyzing dependencies**

It’s always useful to understand the dependencies drawn by the packages we build.

First we need to install a *Graphviz*:

\$ sudo apt install graphviz

Now, let’s use Buildroot’s target to generate a dependency graph:

\$ make graph-depends

We can now study the dependency graph:

\$ evince output/graphs/graph-depends.pdf

In particular, you can see that adding MPD and its client required to compile *Meson* for the host, and in turn, *Python 3* for the host too. This substantially contributed to the build time.

**Adding a Buildroot package**

We would also like to build our Nunchuk external module with Buildroot. Fortunately, Buildroot has a kernel-module infrastructure to build kernel modules.

First, create a nunchuk-driver subdirectory under package in Buildroot sources.

The first thing is to create a package/nunchuk-driver/Config.in file for Buildroot’s configuration:

config BR2_PACKAGE_NUNCHUK_DRIVER

bool "nunchuk-driver"

depends on BR2_LINUX_KERNEL

help

Linux Kernel module for the I2C Nunchuk.

Then add a line to package/Config.in to include this file, for example right before the line including package/ nvidia-driver/Config.in, so that the alphabetic order of configuration options is kept.

Then, the next and last thing you need to do is create package/nunchuk-driver/nunchuk-driver.mk describ-ing how to build the package:

NUNCHUK_DRIVER_VERSION = 1.0

NUNCHUK_DRIVER_SITE = \$(HOME)/embedded-linux-bbb-labs/hardware/data/nunchuk

NUNCHUK_DRIVER_SITE_METHOD = local

NUNCHUK_DRIVER_LICENSE = GPL-2.0

\$(eval \$(kernel-module))

\$(eval \$(generic-package))

Then, configure Buildroot to build your package, run Buildroot and update your root filesystem.

Can you load the nunchuk module now? If everything’s fine, add a line to /etc/init.d/S03modprobe for this driver, and update your root filesystem once again.

**Testing the Nunchuk**

Now that we have the nunchuk driver loaded and that Buildroot compiled evtest for the target, thanks to Buildroot, we can now test the input events coming from the Nunchuk.

\# evtest

No device specified, trying to scan all of /dev/input/event\* Available devices:

/dev/input/event0: pmic_onkey

/dev/input/event1: Logitech Inc. Logitech USB Headset H340 Consumer Control /dev/input/event2: Logitech Inc. Logitech USB Headset H340 /dev/input/event3: Wii Nunchuk

Select the device event number \[0-3\]:

Enter the number corresponding to the Nunchuk device.

You can now press the Nunchuk buttons, use the joypad, and see which input events are emitted.

By the way, you can also test which input events are exposed by the driver for your audio headset (if any), which doesn’t mean that they physically exist.

**Commit your changes**

As we are going to reuse our Buildroot changes in the next labs, let’s commit them into a branch:

git checkout -b bootlin-labs

git add board/bootlin/ package/nunchuk-driver/ package/Config.in git commit -as -m "Bootlin lab changes"

**Going further**

*If you finish your lab before the others*

• For more music playing fun, you can install the ario or *cantata* MPD client on your host machine

( sudo apt install ario, sudo apt install cantata), configure it to connect to the IP address of your target system with the default port, and you will also be able to control playback from your host machine.


