Linux device and driver model

 

Linux device and driver

 

model

 

© Copyright 2004-2025, Bootlin. embedded Linux and kernel engineering Creative Commons BY-SA 3.0 license.

Corrections, suggestions, contributions and translations are welcome!

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 163/436

Linux device and driver model

 

Introduction

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 164/436 The need for a device model?

 

▶ The Linux kernel runs on a wide range of architectures and hardware platforms,

and therefore needs to **maximize the reusability** of code between platforms. ▶ For example, we want the same *USB device driver* to be usable on a x86 PC, or

an ARM platform, even though the USB controllers used on these platforms are

different.

▶ This requires a clean organization of the code, with the *device drivers* separated

from the *controller drivers*, the hardware description separated from the drivers

themselves, etc.

▶ This is what the Linux kernel **Device Model** allows, in addition to other

advantages covered in this section.

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 165/436

Kernel and device drivers

 

In Linux, a driver is always interfacing with:

▶ a **framework** that allows the driver to expose the

hardware features in a generic way.

▶ a **bus infrastructure**, part of the device model, to

detect/communicate with the hardware.

This section focuses on the *bus infrastructure*, while *kernel frameworks* are covered later in this training.

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 166/436 Device model data structures

 

▶ The *device model* is organized around three main data structures:

*•* The [struct bus_type](https://elixir.bootlin.com/linux/latest/ident/bus_type) structure, which represents one type of bus (USB, PCI, I2C,

etc.)

*•* The [struct device_driver](https://elixir.bootlin.com/linux/latest/ident/device_driver) structure, which represents one driver capable of

handling certain devices on a certain bus.

*•* The [struct device](https://elixir.bootlin.com/linux/latest/ident/device) structure, which represents one device connected to a bus

▶ The kernel uses inheritance to create more specialized versions of

[struct device_driver](https://elixir.bootlin.com/linux/latest/ident/device_driver) and [struct device](https://elixir.bootlin.com/linux/latest/ident/device) for each bus subsystem.

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 167/436

Bus drivers

 

▶ The first component of the device model is the bus driver

*•* One bus driver for each type of bus: USB, PCI, SPI, MMC, I2C, etc.

▶ It is responsible for

*•* Registering the bus type [(](https://elixir.bootlin.com/linux/latest/ident/bus_type)[struct bus_type](https://elixir.bootlin.com/linux/latest/ident/bus_type)) *•* Allowing the registration of adapter drivers (USB controllers, I2C adapters, etc.),

able to detect the connected devices (if possible), and providing a communication mechanism with the devices

*•* Allowing the registration of device drivers (USB devices, I2C devices, PCI devices,

etc.), managing the devices

*•* Matching the device drivers against the devices detected by the adapter drivers. *•* Provides an API to implement both adapter drivers and device drivers

*•* Defining driver and device specific structures, eg. [struct usb_driver](https://elixir.bootlin.com/linux/latest/ident/usb_driver) and

[struct usb_interface](https://elixir.bootlin.com/linux/latest/ident/usb_interface)

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 168/436 sysfs

 

▶ The bus, device, drivers, etc. structures are internal to the kernel ▶ The sysfs virtual filesystem offers a mechanism to export such information to

user space

▶ Used for example by udev to provide automatic module loading, firmware loading,

mounting of external media, etc.

▶ sysfs is usually mounted in /sys

*•* /sys/bus/ contains the list of buses *•* /sys/devices/ contains the list of devices *•* /sys/class enumerates devices by the framework they are registered to (net,

input, block...), whatever bus they are connected to. Very useful!

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 169/436

Linux device and driver model

 

Example of the USB bus

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 170/436 Example: USB bus 1/3

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 171/436 Example: USB bus 2/3

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 172/436 Example: USB bus 3/3

 

▶ Core infrastructure (bus driver)

*•* [drivers/usb/core/](https://elixir.bootlin.com/linux/latest/source/drivers/usb/core/)

*•* [struct bus_type](https://elixir.bootlin.com/linux/latest/ident/bus_type) is defined in [drivers/usb/core/driver.c](https://elixir.bootlin.com/linux/latest/source/drivers/usb/core/driver.c) and registered in

[drivers/usb/core/usb.c](https://elixir.bootlin.com/linux/latest/source/drivers/usb/core/usb.c)

▶ Adapter drivers

*•* [drivers/usb/host/](https://elixir.bootlin.com/linux/latest/source/drivers/usb/host/)

*•* For EHCI, UHCI, OHCI, XHCI, and their implementations on various systems

(Microchip, IXP, Xilinx, OMAP, Samsung, PXA, etc.)

▶ Device drivers

*•* Everywhere in the kernel tree, classified by their type (Example: [drivers/net/usb/](https://elixir.bootlin.com/linux/latest/source/drivers/net/usb/)[)](https://elixir.bootlin.com/linux/latest/source/drivers/net/usb/)

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 173/436

Example of device driver

 

▶ To illustrate how drivers are implemented to work with the

device model, we will study the source code of a driver for a

USB network card

*•* It is USB device, so it has to be a USB device driver *•* It exposes a network device, so it has to be a network driver *•* Most drivers rely on a bus infrastructure (here, USB) and

register themselves in a framework (here, network)

▶ We will only look at the device driver side, and not the

adapter driver side

▶ The driver we will look at is [drivers/net/usb/rtl8150.c](https://elixir.bootlin.com/linux/latest/source/drivers/net/usb/rtl8150.c)

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 174/436 Device identifiers

 

▶ Defines the set of devices that this driver can manage, so that the USB core

knows for which devices this driver should be used

▶ The [MODULE_DEVICE_TABLE()](https://elixir.bootlin.com/linux/latest/ident/MODULE_DEVICE_TABLE) macro allows depmod (run by

make modules_install) to extract the relationship between device identifiers and

drivers, so that drivers can be loaded automatically by udev. See

/lib/modules/\$(uname -r)/modules.{alias,usbmap}

 

static struct usb_device_id rtl8150_table\[\] = {

{ USB_DEVICE(VENDOR_ID_REALTEK, PRODUCT_ID_RTL8150) },

{ USB_DEVICE(VENDOR_ID_MELCO, PRODUCT_ID_LUAKTX) },

{ USB_DEVICE(VENDOR_ID_MICRONET, PRODUCT_ID_SP128AR) },

{ USB_DEVICE(VENDOR_ID_LONGSHINE, PRODUCT_ID_LCS8138TX) },

\[...\]

{}

};

MODULE_DEVICE_TABLE(usb, rtl8150_table);

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 175/436

Instantiation of usb_driver

 

▶ [struct usb_driver](https://elixir.bootlin.com/linux/latest/ident/usb_driver) is a structure defined by the USB core. Each USB device

driver must instantiate it, and register itself to the USB core using this structure

▶ This structure inherits from [struct device_driver,](https://elixir.bootlin.com/linux/latest/ident/device_driver) which is defined by the

device model.

static struct usb_driver rtl8150_driver = {

.name = "rtl8150",

.probe = rtl8150_probe,

.disconnect = rtl8150_disconnect,

.id_table = rtl8150_table,

.suspend = rtl8150_suspend,

.resume = rtl8150_resume

};

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 176/436 Driver registration and unregistration

 

▶ When the driver is loaded / unloaded, it must register / unregister itself to / from the

USB core

▶ Done using [usb_register()](https://elixir.bootlin.com/linux/latest/ident/usb_register) and [usb_deregister()](https://elixir.bootlin.com/linux/latest/ident/usb_deregister)[,](https://elixir.bootlin.com/linux/latest/ident/usb_deregister) provided by the USB core.

static int \_\_init usb_rtl8150_init(void)

{

return usb_register(&rtl8150_driver);

}

static void \_\_exit usb_rtl8150_exit(void)

{

usb_deregister(&rtl8150_driver);

}

module_init(usb_rtl8150_init);

module_exit(usb_rtl8150_exit);

▶ All this code is actually replaced by a call to the [module_usb_driver()](https://elixir.bootlin.com/linux/latest/ident/module_usb_driver) macro:

module_usb_driver(rtl8150_driver);

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 177/436

At Initialization

 

▶ The USB adapter driver that corresponds to the USB controller of the system

registers itself to the USB core

▶ The [rtl8150](https://elixir.bootlin.com/linux/latest/ident/rtl8150) USB device driver registers itself to the USB core

 

▶ The USB core now knows the association between the vendor/product IDs of

[rtl8150](https://elixir.bootlin.com/linux/latest/ident/rtl8150) and the [struct usb_driver](https://elixir.bootlin.com/linux/latest/ident/usb_driver) structure of this driver

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 178/436 When a device is detected

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 179/436 Probe method

 

▶ Invoked **for each device** bound to a driver ▶ The probe() method receives as argument a structure describing the device,

usually specialized by the bus infrastructure ([struct pci_dev](https://elixir.bootlin.com/linux/latest/ident/pci_dev),

[struct usb_interface,](https://elixir.bootlin.com/linux/latest/ident/usb_interface) etc.)

▶ This function is responsible for

*•* Initializing the device, mapping I/O memory, registering the interrupt handlers. The

bus infrastructure provides methods to get the addresses, interrupt numbers and other device-specific information.

*•* Registering the device to the proper kernel framework, for example the network

infrastructure.

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 180/436 Example: probe() and disconnect() methods

 

static int rtl8150_probe(struct usb_interface \*intf, static void rtl8150_disconnect(struct usb_interface \*intf)

const struct usb_device_id \*id) {

{ rtl8150_t \*dev = usb_get_intfdata(intf);

rtl8150_t \*dev;

struct net_device \*netdev; usb_set_intfdata(intf, NULL);

if (dev) {

netdev = alloc_etherdev(sizeof(rtl8150_t)); set_bit(RTL8150_UNPLUG, &dev-\>flags); \[...\] tasklet_kill(&dev-\>tl); dev = netdev_priv(netdev); unregister_netdev(dev-\>netdev); tasklet_init(&dev-\>tl, rx_fixup, (unsigned long)dev); unlink_all_urbs(dev); spin_lock_init(&dev-\>rx_pool_lock); free_all_urbs(dev); \[...\] free_skb_pool(dev); netdev-\>netdev_ops = &rtl8150_netdev_ops; if (dev-\>rx_skb) alloc_all_urbs(dev); dev_kfree_skb(dev-\>rx_skb); \[...\] kfree(dev-\>intr_buff); usb_set_intfdata(intf, dev); free_netdev(dev-\>netdev); SET_NETDEV_DEV(netdev, &intf-\>dev); } register_netdev(netdev); } return 0;

}

 

Source: [drivers/net/usb/rtl8150.c](https://elixir.bootlin.com/linux/latest/source/drivers/net/usb/rtl8150.c)

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 181/436

The model is recursive

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 182/436

Linux device and driver model

 

Platform drivers

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 183/436

Platform devices

 

▶ Amongst the non-discoverable devices, a huge family are the devices that are

directly part of a system-on-chip: UART controllers, Ethernet controllers, SPI or

I2C controllers, graphic or audio devices, etc. ▶ In the Linux kernel, a special bus, called the **platform bus** has been created to

handle such devices. Those get controlled through **memory-mapped registers**. ▶ It supports **platform drivers** that handle **platform devices**. ▶ It works like any other bus (USB, PCI), except that devices are enumerated

statically instead of being discovered dynamically.

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 184/436 Implementation of a platform driver (1)

 

The driver implements a [struct platform_driver](https://elixir.bootlin.com/linux/latest/ident/platform_driver) structure (example taken from

[drivers/tty/serial/imx.c,](https://elixir.bootlin.com/linux/latest/source/drivers/tty/serial/imx.c) simplified)

static struct platform_driver serial_imx_driver = {

.probe = serial_imx_probe,

.remove = serial_imx_remove,

.id_table = imx_uart_devtype,

.driver = {

.name = "imx-uart",

.of_match_table = imx_uart_dt_ids,

.pm = &imx_serial_port_pm_ops,

},

};

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 185/436

Implementation of a platform driver (2)

 

... and registers its driver to the platform driver infrastructure

static int \_\_init imx_serial_init(void) {

return platform_driver_register(&serial_imx_driver);

}

static void \_\_exit imx_serial_cleanup(void) {

platform_driver_unregister(&serial_imx_driver);

}

module_init(imx_serial_init);

module_exit(imx_serial_cleanup);

Most drivers actually use the [module_platform_driver()](https://elixir.bootlin.com/linux/latest/ident/module_platform_driver) macro when they do nothing special in init() and exit() functions:

module_platform_driver(serial_imx_driver);

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 186/436 Platform device instantiation

 

▶ As platform devices cannot be detected dynamically, they are defined statically

*•* Legacy way: by direct instantiation of [struct platform_device](https://elixir.bootlin.com/linux/latest/ident/platform_device) structures, as done

on a few old ARM platforms. The device was part of a list, and the list of devices was added to the system during board initialization.

*•* Current way: by parsing an ”external” description, like a *device tree* on most

embedded platforms today, from which [struct platform_device](https://elixir.bootlin.com/linux/latest/ident/platform_device) instances are created.

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 187/436

Using additional hardware resources

 

▶ Regular DT descriptions contain many information. It includes phandles

(pointers) towards additional hardware blocks which cannot be discovered.

*•* I/O register addresses and IRQ lines are available through a [struct resource](https://elixir.bootlin.com/linux/latest/ident/resource) array

associated to each [struct platform_device](https://elixir.bootlin.com/linux/latest/ident/platform_device).

*•* Information relevant to a given subsystem is parsed by that specific subsystem.

Examples are clocks, GPIOs or DMA. A subsystem is responsible for:

instantiating its components,

offering an API to use those objects from device drivers.

*•* Specific properties are directly retrieved by device drivers, through (expensive) DT

lookups.

▶ All these methods allow the same driver to be used with multiple devices

functioning similarly, but with different addresses, IRQs, etc.

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 188/436 Using resources

 

▶ The platform driver has access to the resources provided by the platform bus:

res = platform_get_resource(pdev, IORESOURCE_MEM, 0); base = ioremap(res-\>start, PAGE_SIZE);

sport-\>rxirq = platform_get_irq(pdev, 0);

▶ As well as the various subsystem-provided dependencies through individual APIs:

*•* [clk_get()](https://elixir.bootlin.com/linux/latest/ident/clk_get)

*•* [gpio_request()](https://elixir.bootlin.com/linux/latest/ident/gpio_request)

*•* [dma_request_channel()](https://elixir.bootlin.com/linux/latest/ident/dma_request_channel)

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 189/436

Driver data

▶ In addition to the per-device resources and information, drivers may require

driver-specific information to behave slightly differently when different flavors of

an IP block are driven by the same driver.

▶ A const void \*data pointer can be used to store per-compatible specificities:

static const struct of_device_id marvell_nfc_of_ids\[\] = {

{

.compatible = "marvell,armada-8k-nand-controller", .data = &marvell_armada_8k_nfc_caps,

},

};

▶ Which can be retrieved in the probe with:

/\* Get NAND controller capabilities \*/

if (pdev-\>id_entry) /\* legacy way \*/

nfc-\>caps = (void \*)pdev-\>id_entry-\>driver_data;

else /\* current way \*/

nfc-\>caps = of_device_get_match_data(&pdev-\>dev);

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 190/436

![](/tmp/audit/iter1/epubregen/bootlin-linux-kernel-slides/media/index-205_1.jpg)