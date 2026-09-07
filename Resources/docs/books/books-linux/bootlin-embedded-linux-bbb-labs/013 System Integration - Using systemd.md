**System Integration - Using systemd**





*Objectives: Get familiar with the* systemd *init system.*



**Goals**

Compared to the previous lab, we go on increasing the complexity of the system, this time by using the *systemd* init system, and by taking advantage of it to add a few extra features, in particular ones that will be useful for debugging in the next lab.

**Setup**

Since *systemd* requires the GNU C library, we are going to make a new Buildroot build in a new working directory, and using a different cross-compiling toolchain.

So, create the \$HOME/embedded-linux-bbb-labs/integration directory and go inside it.

Make a new clone of Buildroot from the existing local Git repository, and checkout our bootlin-labs branch:

git clone \$HOME/embedded-linux-bbb-labs/buildroot/buildroot cd buildroot

git checkout bootlin-labs

In addition, in the next lab, we’re going to use the *perf* debugging utility which is provided within the Linux kernel source code, and unfortunately, the current stable v6.12.x have a regression that prevents from building *perf* correct. To address this, we need to apply a Linux kernel patch, so let’s copy this patch to board/bootlin/training/, alongside our already existing Linux kernel patch:

cp ../data/0002-Revert-perf-tools-Create-source-symlink-in-perf-obje.patch board/bootlin/\\

training

In one of the next steps, we’re going to tell Buildroot apply this patch when it will build the Linux kernel.

**Root filesystem overlay**

Remove etc/init.d/ from the root filesystem overlay. It was adapted to *BusyBox init*, not to *systemd*:

rm -r board/bootlin/training/rootfs-overlay/etc/init.d/

**Buildroot configuration**

Configure Buildroot as follows:

• Target options

**–** Select the same architecture and CPU settings as in the previous lab.

• Toolchain

**–** Toolchain type: External toolchain

**–** Toolchain: Bootlin toolchains

This time, we will use a Bootlin ready-made toolchain for *glibc*, as this is necessary for using *systemd*.

**–** Toolchain origin: Toolchain to be downloaded and installed


**–** Bootlin toolchain variant: armv7-eabihf glibc bleeding-edge

**–** Select Copy gdb server to the Target

• System configuration

**–** Init system: systemd

**–** Root filesystem overlay directories: board/bootlin/training/rootfs-overlay

• Kernel

**–** Enable Linux Kernel

**–** Set Kernel version to Custom version

**–** Set Kernel version to your kernel version. You can use make kernelversion to get it from the

Linux kernel source tree.

**–** Set Custom kernel patches to board/bootlin/training/0001-Custom-DTS-for-Bootlin-lab.patch

board/bootlin/training/0002-Revert-perf-tools-Create-source-symlink-in-perf-obje.patch

**–** Set Kernel configuration to Using a custom (def)config file)

**–** Set Configuration file path to board/bootlin/training/linux.config

**–** Select Build a Device Tree Blob (DTB)

**–** Set In-tree Device Tree Source file names to ti/omap/am335x-boneblack-custom

• Target packages

**–** Audio and video applications

∗ We won’t need alsa-utils this time.

∗ Select mpd, and in the submenu:

· Keep only alsa, vorbis and tcp sockets

∗ Select mpd-mpc.

**–** Hardware handling

∗ Select nunchuk driver

**–** Networking applications

∗ Select dropbear, a lightweight SSH server used instead of OpenSSH in most embedded devices.

You don’t need to enable client support (building an SSH client).

• Filesystem images

**–** Select tar the root filesystem

**Build and test the new system**

Now build the full system.

Once the build is over, generate the dependency graph again and find out the new dependencies introduced by using *systemd*.

To test the new system, create a new nfsroot directory, extract the new root filesystem into it, and boot your board on it through NFS.

You should see the system booting through *systemd*, with all the *systemd* targets and system services starting one by one, with a total boot time which looks slower than before. That’s because the system configuration is more complex, but also more versatile, being ready to run more complex services and applications.

You can ask *systemd* to show you the various services which were started:

\# systemctl status

You can also check all the mounted filesystems and be impressed:

\# mount

**Inspecting the system**

On the target, look at the contents of /lib/systemd. You will see the implementation of most *systemd* targets and services.

In particular, check out /lib/systemd/user/ containing some unnecessary targets in our case such as bluetooth.target.

However, check the mpd.service file for our MPD server. This should help you to realize all the options provided by *systemd* to start and control system services, while keeping the system secure and their resources under control.

You won’t be able to match this level of control and security in a ”hand-made” system.

*Note: you may notice that a ”systemd-network-generator” unit fails to start. It is due to systemd failing to parse correctly the* ip *parameter from the kernel commandline. You can circumvent this issue by setting the*

autoconf *field (currently not set at all) of the* ip *parameter to* none*. You can refer to* [*nfsroot*](https://www.kernel.org/doc/Documentation/filesystems/nfs/nfsroot.txt) *documentation to learn more about this option*.

**Understanding automatic module loading with Udev**

Check the currently loaded modules on your system. Surprise: both the Nunchuk and USB audio modules are already loaded. We didn’t have anything to set up and *systemd* automatically loaded the modules associated to connected hardware.

Let’s find out why...

On the target, go to /lib/udev/rules.d. You will find all the standard rules for *Udev*, the part of *systemd* which handles hardware events, takes care of the permissions and ownership of device files, notifies other userspace programs, and among others, load kernel modules.

Open 80-drivers.rules, which is the rule allowing *Udev* to load kernel modules for detected devices. Here is its most important line:

ENV{MODALIAS}=="?\*", RUN{builtin}+="kmod load '\$env{MODALIAS}'"

This is when the modules.alias file comes into play. When a new device is found, the kernel passes a MODALIAS environment variable to *Udev*, containing which bus this happened on and the attributes of the device on this bus. Thanks to the module aliases, the right module gets loaded. We already explained that in the lectures when talking about the output of make modules_install.

Find where the modules.alias file is located and you will find the two lines that allowed to load our snd\_ usb_audio and nunchuk modules:

...

alias usb:v\*p\*d\*dc\*dsc\*dp\*ic01isc01ip\*in\* snd_usb_audio

alias usb:v2B53p0031d\*dc\*dsc\*dp\*ic\*isc\*ip\*in\* snd_usb_audio ...

alias of:N\*T\*Cnintendo,nunchuk nunchuk



For snd_usb_audio, there are many possible matching values, so it’s not straightforward to be sure which matched your particular device.

However, you can find in *sysfs* which MODALIAS was emitted for your device:

\# cd /sys/class/sound/card0/device

\# ls -la

\# cat modalias

usb:v1B3Fp2008d0100dc00dsc00dp00ic01isc01ip00in00

With a bit of patience, you could find the matching line in the modules.alias file.

If you want to see the information sent to *Udev* by the kernel when a new device is plugged in, here are a few debugging commands.

First unplug your device and run:

\# udevadm monitor

Then plug in your headset again. You will find all the events emitted by the kernel, and with the same string (with UDEV instead of KERNEL), the time when *Udev* finished processing each event.

You can also see the MODALIAS values carried by these events:

\# udevadm monitor --env

As far as the Nunchuk is concerned, we cannot easily remove it from the Device Tree and add it back, but it’s easier to find its MODALIAS value:

\# cd /sys/bus/i2c/devices

\# ls -la

Here you will recognize our Nunchuk device through its 0x52 address.

\# cd 1-0052

\# ls -la

\# cat modalias

of:NjoystickT(null)Cnintendo,nunchuk

Here the bus is of, meaning *Open Firmware*, which was the former name of the Device Tree. When an event was emitted by the kernel with this MODALIAS string, the nunchuk module got loaded by *Udev* thanks to the matching alias.

This actually happened when *systemd* ran the *coldplugging* operation: at system startup, it asked the kernel to emit hotplug events for devices already present when the system booted:

\[ OK \] Finished Coldplug All udev Devices.

On non-x86 platforms, that’s typically for devices described in the Device Tree. This way, both *static* and *hotplugged* devices can be handled in the same way, using the same *Udev* rules.

**Testing your system**

Make sure that audio playback still works on your system:

\# mpc update

\# mpc add /

\# mpc play

If it doesn’t, look at the *systemd* logs in your serial console history. *systemd* should let you know about the failing services and the commands to run to get more details.


