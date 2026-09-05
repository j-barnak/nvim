The misc subsystem

 

The misc subsystem

 

© Copyright 2004-2025, Bootlin. embedded Linux and kernel engineering Creative Commons BY-SA 3.0 license.

Corrections, suggestions, contributions and translations are welcome!

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 298/436 Why a *misc* subsystem?

 

▶ The kernel offers a large number of **frameworks** covering a wide range of device

types: input, network, video, audio, etc.

*•* These frameworks allow to factorize common functionality between drivers and offer

a consistent API to user space applications.

▶ However, there are some devices that **really do not fit in any of the existing**

**frameworks**.

*•* Highly customized devices implemented in a FPGA, or other weird devices for which

implementing a complete framework is not useful.

▶ The drivers for such devices could be implemented directly as raw *character*

*drivers* (with [cdev_init()](https://elixir.bootlin.com/linux/latest/ident/cdev_init) and [cdev_add()](https://elixir.bootlin.com/linux/latest/ident/cdev_add)). ▶ But there is a subsystem that makes this work a little bit easier: the **misc**

**subsystem**.

*•* It is really only a **thin layer** above the *character driver* API. *•* Another advantage is that devices are integrated in the Device Model (device files

appearing in *devtmpfs*, which you don’t have with raw character devices).

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 299/436 Misc subsystem diagram

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 300/436 Misc subsystem API (1/2)

 

▶ The misc subsystem API mainly provides two functions, to register and unregister

**a single** *misc device*:

*•* int misc_register(struct miscdevice \* misc); *•* void misc_deregister(struct miscdevice \*misc);

▶ A *misc device* is described by a [struct miscdevice](https://elixir.bootlin.com/linux/latest/ident/miscdevice) structure:

struct miscdevice {

int minor;

const char \*name;

const struct file_operations \*fops; struct list_head list;

struct device \*parent;

struct device \*this_device; const char \*nodename;

umode_t mode;

};

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 301/436 Misc subsystem API (2/2)

 

The main fields to be filled in [struct miscdevice](https://elixir.bootlin.com/linux/latest/ident/miscdevice) are:

▶ minor, the minor number for the device, or [MISC_DYNAMIC_MINOR](https://elixir.bootlin.com/linux/latest/ident/MISC_DYNAMIC_MINOR) to get a minor

number automatically assigned.

▶ name, name of the device, which will be used to create the device node if

*devtmpfs* is used.

▶ fops, pointer to the same [struct file_operations](https://elixir.bootlin.com/linux/latest/ident/file_operations) structure that is used for

raw character drivers, describing which functions implement the *read*, *write*, *ioctl*,

etc. operations.

▶ parent, pointer to the struct device of the underlying “physical” device

(platform device, I2C device, etc.)

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 302/436 User space API for misc devices

 

▶ *misc devices* are regular character devices ▶ The operations they support in user space depends on the operations the kernel

driver implements:

*•* The open() and close() system calls to open/close the device. *•* The read() and write() system calls to read/write to/from the device. *•* The ioctl() system call to call some driver-specific operations.

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 303/436

Practical lab - Output-only serial port driver

 

▶ Extend the driver started in the previous lab by

![](media/index-318_1.png)

registering it into the *misc* subsystem.

![](media/index-318_2.png)

▶ Implement serial output functionality through

the *misc* subsystem.

▶ Test serial output using user space applications.

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 304/436

![](media/index-319_1.jpg)