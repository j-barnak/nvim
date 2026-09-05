**Kernel - Cross-compiling**

*Objective: Learn how to cross-compile a kernel for an ARM target platform.*

After this lab, you will be able to:

• Checkout a stable version of the Linux kernel

• Set up a cross-compiling environment

• Cross compile the kernel for the QEMU ARM Versatile Express for Cortex-A9

• Use U-Boot to download the kernel

• Check that the kernel you compiled starts the system

**Setup**

Stay in the \$HOME/embedded-linux-qemu-labs/kernel directory.

**Choose a particular stable version of Linux**

We will use linux-6.1.x, which this lab was tested with.

First, let’s get the list of branches we have available:

cd linux

git branch -a

As we will do our labs with the Linux 6.1, the remote branch we are interested in is remotes/stable/linux-6.1.y.

First, execute the following command to check which version you currently have: make kernelversion

You can also open the Makefile and look at the beginning of it to check this information.

Now, let’s create a local branch starting from that remote branch: git checkout stable/linux-6.1.y

Check the version again using the make kernelversion command to make sure you now have a 6.1.x version.

**Cross-compiling environment setup**

To cross-compile Linux, you need to have a cross-compiling toolchain. We will use the cross-compiling toolchain that we previously produced, so we just need to make it available in the PATH: \$ export PATH=\$HOME/x-tools/arm-training-linux-musleabihf/bin:\$PATH

Also, don’t forget to either:

• Define the value of the ARCH and CROSS_COMPILE variables in your environment (using export)

• **Or** specify them on the command line at every invocation of make, i.e.: make ARCH=... CROSS_COMPILE=

... \<target\>

© 2004-2025 [Bootlin,](https://bootlin.com) CC BY-SA license 15

Embedded Linux System Development

**Linux kernel configuration**

By running make help, look for the proper Makefile target to configure the kernel for your processor.

In course case, use the configuration for the ARM Vexpress boards (vexpress_defconfig).

So, apply this configuration, and then run make menuconfig.

• Disable [CONFIG_GCC_PLUGINS](https://elixir.bootlin.com/linux/latest/K/ident/CONFIG_GCC_PLUGINS) if it is set. This will skip building special *gcc* plugins, which would require extra dependencies for the build.

Also start make menuconfig to add [CONFIG_DEVTMPFS_MOUNT](https://elixir.bootlin.com/linux/latest/K/ident/CONFIG_DEVTMPFS_MOUNT) to your configuration.

**Cross compiling**

You’re now ready to cross-compile your kernel. Simply run:

\$ make

and wait a while for the kernel to compile. Don’t forget to use make -j\<n\> if you have multiple cores on your machine!

Look at the kernel build output to see which file contains the kernel image.

Also look in the Device Tree Source directory to see which .dtb files got compiled. Find which .dtb file corresponds to your board.

**Load and boot the kernel using U-Boot**

As we are going to boot the Linux kernel from U-Boot, we need to set the bootargs environment corresponding to the Linux kernel command line:

=\> setenv bootargs console=ttyAMA0

=\> saveenv

We will use TFTP to load the kernel image on the board:

• On your workstation, copy the zImage and DTB (vexpress-v2p-ca9.dtb) to the directory exposed by the TFTP server.

• On the target (in the U-Boot prompt), load zImage from TFTP into RAM:

=\> tftp 0x61000000 zImage

• Now, also load the DTB file into RAM:

=\> tftp 0x62000000 vexpress-v2p-ca9.dtb

• Boot the kernel with its device tree:

=\> bootz 0x61000000 - 0x62000000

You should see Linux boot and finally panicking. This is expected: we haven’t provided a working root filesystem for our device yet.

You can now automate all this every time the board is booted or reset. Reset the board, and customize bootcmd:

=\> setenv bootcmd 'tftp 0x61000000 zImage; tftp 0x62000000 vexpress-v2p-ca9.dtb; bootz 0x61000000 - 0x62000000'

=\> saveenv

Restart the board to make sure that booting the kernel is now automated.

16

© 2004-2025 [Bootlin](https://bootlin.com), CC BY-SA license

Embedded Linux System Development