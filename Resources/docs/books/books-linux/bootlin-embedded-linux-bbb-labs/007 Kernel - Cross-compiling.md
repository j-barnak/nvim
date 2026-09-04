**Kernel - Cross-compiling**

 

 

*Objective: Learn how to cross-compile a kernel for an ARM target platform.*

 

After this lab, you will be able to:

• Checkout a stable version of the Linux kernel

• Set up a cross-compiling environment

• Cross compile the kernel for the BeagleBone Black

• Use U-Boot to download the kernel

• Check that the kernel you compiled starts the system

**Setup**

Stay in the \$HOME/embedded-linux-bbb-labs/kernel directory.

**Choose a particular stable version of Linux**

We will use linux-6.6.x, which corresponds to an LTS release, and which this lab was tested with.

First, let’s get the list of branches we have available:

cd linux

git branch -a

As we will do our labs with the Linux 6.6, the remote branch we are interested in is remotes/stable/linux-6.6.y.

First, execute the following command to check which version you currently have:

make kernelversion

You can also open the Makefile and look at the beginning of it to check this information.

Now, let’s create a local branch starting from that remote branch:

git checkout stable/linux-6.6.y

Check the version again using the make kernelversion command to make sure you now have a 6.6.x version.

**Cross-compiling environment setup**

To cross-compile Linux, you need to have a cross-compiling toolchain. We will use the cross-compiling toolchain that we previously produced, so we just need to make it available in the PATH:

\$ export PATH=\$HOME/x-tools/arm-training-linux-musleabihf/bin:\$PATH

Also, don’t forget to either:

• Define the value of the ARCH and CROSS_COMPILE variables in your environment (using export)

• **Or** specify them on the command line at every invocation of make, i.e.: make ARCH=... CROSS_COMPILE=

... \<target\>

16 © 2004-2025 [Bootlin](https://bootlin.com), CC BY-SA license **Linux kernel configuration**

By running make help, look for the proper Makefile target to configure the kernel for your processor.

In our case look for a configuration for boards in the OMAP2 and later family which the AM335x found in the BeagleBone belongs to.

So, apply this configuration, and then run make menuconfig.

• Disable [CONFIG_GCC_PLUGINS](https://elixir.bootlin.com/linux/latest/K/ident/CONFIG_GCC_PLUGINS) if it is set. This will skip building special *gcc* plugins, which would require

extra dependencies for the build.

• Add options to support USB host and networking over USB device:

**–** [CONFIG_USB=y](https://elixir.bootlin.com/linux/latest/K/ident/CONFIG_USB)

**–** [CONFIG_USB_GADGET=y](https://elixir.bootlin.com/linux/latest/K/ident/CONFIG_USB_GADGET)

**–** [CONFIG_USB_MUSB_HDRC=y](https://elixir.bootlin.com/linux/latest/K/ident/CONFIG_USB_MUSB_HDRC) *Driver for the USB OTG controller*

**–** [CONFIG_USB_MUSB_DSPS=y](https://elixir.bootlin.com/linux/latest/K/ident/CONFIG_USB_MUSB_DSPS)

**–** [CONFIG_USB_MUSB_DUAL_ROLE=y](https://elixir.bootlin.com/linux/latest/K/ident/CONFIG_USB_MUSB_DUAL_ROLE) *Use the USB OTG both in host and device (gadget) modes. This*

*will be needed later to use the board’s USB host port.*

**–** Check the dependencies of [CONFIG_AM335X_PHY_USB](https://elixir.bootlin.com/linux/latest/K/ident/CONFIG_AM335X_PHY_USB) and find the way to set [CONFIG_AM335X_PHY\_](https://elixir.bootlin.com/linux/latest/K/ident/CONFIG_AM335X_PHY_USB)

[USB=y](https://elixir.bootlin.com/linux/latest/K/ident/CONFIG_AM335X_PHY_USB)

**–** Find the ”USB Gadget precomposed configurations” menu and set it to *static* instead of *module*

so that [CONFIG_USB_ETH=y](https://elixir.bootlin.com/linux/latest/K/ident/CONFIG_USB_ETH)

• Also compile your kernel with [CONFIG_INPUT_EVDEV=y,](https://elixir.bootlin.com/linux/latest/K/ident/CONFIG_INPUT_EVDEV) to have the same default setting as in our labs

with the STM32MP1 boards.

**Cross compiling**

You’re now ready to cross-compile your kernel. Simply run:

\$ make

and wait a while for the kernel to compile. Don’t forget to use make -j\<n\> if you have multiple cores on your machine!

Look at the kernel build output to see which file contains the kernel image.

Also look in the Device Tree Source directory to see which .dtb files got compiled. Find which .dtb file corresponds to your board.

For the BeagleBone Black, its am335x-boneblack.dtb, and for the BeagleBone Black Wireless, its am335x-boneblack-wireless.dtb.

**Load and boot the kernel using U-Boot**

As we are going to boot the Linux kernel from U-Boot, we need to set the bootargs environment corresponding to the Linux kernel command line:

=\> setenv bootargs console=ttyS0,115200n8

=\> saveenv

We will use TFTP to load the kernel image on the board:

• On your workstation, copy the zImage and DTB (am335x-boneblack.dtb) to the directory exposed by

the TFTP server.

• On the target (in the U-Boot prompt), load zImage from TFTP into RAM:

 

© 2004-2025 [Bootlin,](https://bootlin.com) CC BY-SA license 17

=\> tftp 0x81000000 zImage

• Now, also load the DTB file into RAM:

=\> tftp 0x82000000 am335x-boneblack.dtb

• Boot the kernel with its device tree:

=\> bootz 0x81000000 - 0x82000000

You should see Linux boot and finally panicking. This is expected: we haven’t provided a working root filesystem for our device yet.

You can now automate all this every time the board is booted or reset. Reset the board, and customize bootcmd:

=\> setenv bootcmd 'tftp 0x81000000 zImage; tftp 0x82000000 am335x-boneblack.dtb; bootz

0x81000000 - 0x82000000'

=\> saveenv

**Known issue**: with at least U-Boot 2023.04 and 2024.04 and with USB networking, there is an issue running two tftp commands in a row in bootcmd. To work around this issue before we get a chance to fix it upstream, insert sleep 0.1 between the two tftp commands and everything will work as expected.

Restart the board to make sure that booting the kernel is now automated.

 

18 © 2004-2025 [Bootlin](https://bootlin.com), CC BY-SA license