Embedded Linux System Development

**Accessing Hardware Devices**

*Objective: learn how to access hardware devices.*

**Goals**

Now that we have access to a command line shell thanks to a working root filesystem, we can now explore existing devices.

**Important:** *The manipulations in this lab are limited because we’re working with an emulated platform, not* *with real hardware. It would be best to get your hands on the hardware platforms we support. Our instructions* *for such platforms really cover practising with internal and external hardware devices.*

**Setup**

Go to the \$HOME/embedded-linux-qemu-labs/hardware directory, which provides useful files for this lab.

However, we will go on booting the system through NFS, using the root filesystem built by the previous lab.

**Exploring /dev**

Start by exploring /dev on your target system. Here are a few noteworthy device files that you will see:

• *Terminal devices*: devices starting with tty. Terminals are user interfaces taking text as input and producing text as output, and are typically used by interactive shells. In particular, you will find console which matches the device specified through console= in the kernel command line. You will also find the ttyAMA0 device file.

• *Pseudo-terminal devices*: devices starting with pty, used when you connect through SSH for example.

Those are virtual devices, but there are so many in /dev that we wanted to give a description here.

• MMC device(s) and partitions: devices starting with mmcblk. You should here recognize the MMC

device(s) on your system and the associated partitions.

Don’t hesitate to explore /dev on your workstation too and ask any questions to your instructor.

**Exploring /sys**

The next thing you can explore is the *Sysfs* filesystem.

A good place to start is /sys/class, which exposes devices classified by the kernel frameworks which manage them.

For example, go to /sys/class/net, and you will see all the networking interfaces on your system, whether they are internal, external or virtual ones.

Find which subdirectory corresponds to the network connection to your host system, and then check device properties such as:

• speed: will show you whether this is a gigabit or hundred megabit interface.

• address: will show the device MAC address. No need to get it from a complex command!

• statistics/rx_bytes will show you how many bytes were received on this interface.

Don’t hesitate to look for further interesting properties by yourself!

You can also check whether /sys/class/thermal exists and is not empty on your system. That’s the thermal framework, and it allows to access temperature measures from the thermal sensors on your system.

22

© 2004-2025 [Bootlin](https://bootlin.com), CC BY-SA license

Embedded Linux System Development

Next, you can now explore all the buses (virtual or physical) available on your system, by checking the contents of /sys/bus.

In particular, go to /sys/bus/mmc/devices to see all the MMC devices on your system. Go inside the directory for the first device and check several files (for example):

• serial: the serial number for your device.

• preferred_erase_size: the preferred erase block for your device. It’s recommended that partitions start at multiples of this size.

• name: the product name for your device. You could display it in a user interface or log file, for example.

• date: apparently the manufacturing date for the device.

Don’t hesitate to spend more time exploring /sys on your system and asking questions to your instructor.

That’s all for now!

© 2004-2025 [Bootlin,](https://bootlin.com) CC BY-SA license 23