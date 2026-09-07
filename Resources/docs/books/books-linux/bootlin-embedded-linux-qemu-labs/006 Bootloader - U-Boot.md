**Bootloader - U-Boot**

*Objectives: Compile and install the U-Boot bootloader, use basic U-Boot commands, set up TFTP communication with the development workstation.*

**Setup**

Go to the \$HOME/embedded-linux-qemu-labs/bootloader directory.

Install the qemu-system-arm package. In this lab and in the following ones, we will use a QEMU emulated ARM Vexpress Cortex A9 board.

**Configuring and building U-Boot**

Download U-Boot:

\$ git clone https://gitlab.denx.de/u-boot/u-boot

\$ cd u-boot

\$ git checkout v2023.01

Now configure U-Boot to support the ARM Vexpress Cortex A9 board (vexpress_ca9x4_defconfig).

Get an understanding of U-Boot’s configuration and compilation steps by reading the README file, and specifically the *Building the Software* section.

Basically, you need to specify the cross-compiler prefix (the part before gcc in the cross-compiler executable name):

\$ export CROSS_COMPILE=arm-linux-

Now that you have a valid initial configuration, run make menuconfig to further edit your bootloader features:

• In the Environment submenu, we will configure U-Boot so that it stores its environment inside a file called uboot.env in a FAT filesystem on an MMC/SD card, as our emulated machine won’t have flash storage:

**–** Unset Environment in flash memory ([CONFIG_ENV_IS_IN_FLASH](https://elixir.bootlin.com/u-boot/latest/K/ident/CONFIG_ENV_IS_IN_FLASH))

**–** Set Environment is in a FAT filesystem [(CONFIG_ENV_IS_IN_FAT)](https://elixir.bootlin.com/u-boot/latest/K/ident/CONFIG_ENV_IS_IN_FAT)

**–** Set Name of the block device for the environment ([CONFIG_ENV_FAT_INTERFACE](https://elixir.bootlin.com/u-boot/latest/K/ident/CONFIG_ENV_FAT_INTERFACE)): mmc

**–** Device and partition for where to store the environment in FAT ([CONFIG_ENV_FAT_DEVICE\_](https://elixir.bootlin.com/u-boot/latest/K/ident/CONFIG_ENV_FAT_DEVICE_AND_PART)

[AND_PART](https://elixir.bootlin.com/u-boot/latest/K/ident/CONFIG_ENV_FAT_DEVICE_AND_PART)): 0:1

The above two settings correspond to the arguments of the fatload command.

• Also add support for the editenv ([CONFIG_CMD_EDITENV](https://elixir.bootlin.com/u-boot/latest/K/ident/CONFIG_CMD_EDITENV)) and bootd (which can be abbreviated as boot,

[CONFIG_CMD_BOOTD](https://elixir.bootlin.com/u-boot/latest/K/ident/CONFIG_CMD_BOOTD)) that are not present in the default configuration for our board.

Install the following packages which should be needed to compile U-Boot for your board: \$ sudo apt install libssl-dev device-tree-compiler swig \\

python3-dev python3-setuptools

Finally, run

8



make

which will build U-Boot 2.

This generates several binaries, including u-boot and u-boot.bin.

**Testing U-Boot**

Still in U-Boot sources, test that U-Boot works:

\$ qemu-system-arm -M vexpress-a9 -m 128M -nographic -kernel u-boot

• -M: emulated machine

• -m: amount of memory in the emulated machine

• -kernel: allows to load the binary directly in the emulated machine and run the machine with it. This way, you don’t need a first stage bootloader. Of course, you don’t have this with real hardware.

Press a key before the end of the timeout, to access the U-Boot prompt.

You can then type the help command, and explore the few commands available.

Note: to exit QEMU, type \[Ctrl\]\[a\] followed by \[h\] to see available commands. One of them is \[Ctrl\]\[a\]

followed by \[x\], which allows to exit the emulator.

**SD card setup**

Go back to the main bootloader directory.

We now need to add an SD card image to the QEMU virtual machine, in particular to get a way to store U-Boot’s environment.

In later labs, we will also use such storage for other purposes (to store the kernel and device tree, root filesystem and other filesystems).

The commands that we are going to use will be further explained during the *Block filesystems* lectures.

First, using the dd command, create a 1 GB file filled with zeros, called sd.img: \$ dd if=/dev/zero of=sd.img bs=1M count=1024

This will be used by QEMU as an SD card disk image

Now, let’s use the cfdisk command to create the partitions that we are going to use: \$ cfdisk sd.img

If cfdisk asks you to Select a label type, choose dos, as we don’t really need a gpt partition table for our labs.

In the cfdisk interface, create three primary partitions, starting from the beginning, with the following properties:

• One partition, 64MB big, with the FAT16 partition type. Mark this partition as bootable.

• One partition, 8 MB big3, that will be used for the root filesystem. Due to the geometry of the device, the partition might be larger than 8 MB, but it does not matter. Keep the Linux type for the partition.

• One partition, that fills the rest of the SD card image, that will be used for the data filesystem. Here also, keep the Linux type for the partition.

2You can speed up the compiling by using the -jX option with make, where X is the number of parallel jobs used for compiling.

Twice the number of CPU cores is a good value.

3For the needs of our system, the partition could even be much smaller, and 1 MB would be enough. However, with the 8

GB SD cards that we use in our labs, 8 MB will be the smallest partition that cfdisk will allow you to create.



Press Write when you are done.

We will now use the *loop* driver4 to emulate block devices from this image and its partitions: \$ sudo losetup -f --show --partscan sd.img

• -f: finds a free loop device

• --show: shows the loop device that it used

• --partscan: scans the loop device for partitions and creates additional /dev/loop\<x\>p\<y\> block devices.

Also run sudo dmesg to confirm that 3 partitions were detected for the loop device selected by losetup:

\[62778.965018\] loop13: detected capacity change from 0 to 2097152

\[62778.966862\] loop13: p1 p2 p3

Last but not least, format the first partition as FAT16 with a boot label: \$ sudo mkfs.vfat -F 16 -n boot /dev/loop\<x\>p1

The other partitions will be formated later.

Now, you can release the loop device:

\$ sudo losetup -d /dev/loop\<x\>

**Testing U-Boot’s environment**

Start QEMU again, but this time with the emulated SD card (you can type the command in a single line): \$ qemu-system-arm -M vexpress-a9 -m 128M -nographic \\

-kernel u-boot/u-boot \\

-sd sd.img

Now, in the U-Boot prompt, make sure that you can set and store an environment variable: \$ setenv foo bar

\$ saveenv

Type reset which reboots the board, and then check that the foo variable is still set: \$ printenv foo

**Setup networking between QEMU and the host**

To load a kernel in the next lab, we will setup networking between the QEMU emulated machine and the host.

To do so, create a qemu-myifup script that will bring up a network interface between QEMU and the host.

Here are its contents:

\#!/bin/sh

/sbin/ip a add 192.168.0.1/24 dev \$1

/sbin/ip link set \$1 up

If necessary, modify the above network address range so that it doesn’t collide with the one of the main company network.

Of course, make this script executable:

4Once again, this will be properly be explained during our *Block filesystems* lectures.

10



\$ chmod +x qemu-myifup

As you can see, the host side will have the 192.168.0.1 IP address. We will use 192.168.0.100 for the target side. Of course, use a different IP address range if this conflicts with your local network.

Then, you will need root privileges to run QEMU this time, because of the need to bring up the network interface:

\$ sudo qemu-system-arm -M vexpress-a9 -m 128M -nographic \\

-kernel u-boot/u-boot \\

-sd sd.img \\

-net tap,script=./qemu-myifup -net nic

Note the new net options:

• -net tap: creates a software network interface on the host side

• -net nic: adds a network device to the emulated machine

On the host machine, using the ip a command, check that there is now a tap0 network interface with the expected IP address.

On the U-Boot command line, you will have to configure the environment variables for networking:

=\> setenv ipaddr 192.168.0.100

=\> setenv serverip 192.168.0.1

To make these settings permanent, save the environment:

=\> saveenv

You can now test the connection to the host:

=\> ping 192.168.0.1

It should finish by:

host 192.168.0.1 is alive

**Setting up the TFTP server**

Let’s install a TFTP server on your development workstation: sudo apt install tftpd-hpa

Back in U-Boot, run bdinfo, which will allow you to find out that RAM starts at 0x60000000. Therefore, we will use the 0x61000000 address to test *tftp*.

To test the TFTP connection, put a small text file in the directory exported through TFTP on your development workstation. Then, from U-Boot, do:

\$ tftp 0x61000000 textfile.txt

The tftp command should have downloaded the textfile.txt file from your development workstation into the board’s memory at location 0x61000000.

You can verify that the download was successful by dumping the contents of the memory:

=\> md 0x61000000



**Rescue binary**

If you have trouble generating binaries that work properly, or later make a mistake that causes you to lose your bootloader binary, you will find a working version under data/ in the current lab directory.

12

