**Tiny embedded system with BusyBox**





*Objective: making a tiny yet full featured embedded system*



After this lab, you will:

• be able to configure and build a Linux kernel that boots on a directory on your workstation, shared

through the network by NFS.

• be able to create and configure a minimalistic root filesystem from scratch (ex nihilo, out of nothing,

entirely hand made...) for your target board.

• understand how small and simple an embedded Linux system can be.

• be able to install BusyBox on this filesystem.

• be able to create a simple startup script based on /sbin/init.

• be able to set up a simple web interface for the target.

**Lab implementation**

While (s)he develops a root filesystem for a device, a developer needs to make frequent changes to the filesystem contents, like modifying scripts or adding newly compiled programs.

It isn’t practical at all to reflash the root filesystem on the target every time a change is made. Fortunately, it is possible to set up networking between the development workstation and the target. Then, workstation files can be accessed by the target through the network, using NFS.

Unless you test a boot sequence, you no longer need to reboot the target to test the impact of script or application updates.



**Setup**

Go to the \$HOME/embedded-linux-bbb-labs/tinysystem/ directory.

**Kernel configuration**

We will re-use the kernel sources from our previous lab, in \$HOME/embedded-linux-bbb-labs/kernel/.

In the kernel configuration built in the previous lab, verify that you have all options needed for booting the

system using a root filesystem mounted over NFS. Also check that [CONFIG_DEVTMPFS_MOUNT](https://elixir.bootlin.com/linux/latest/K/ident/CONFIG_DEVTMPFS_MOUNT) is enabled (we will explain it later in this lab). If necessary, rebuild your kernel.

**Setting up the NFS server**

Create a nfsroot directory in the current lab directory. This nfsroot directory will be used to store the contents of our new root filesystem.

Install the NFS server by installing the nfs-kernel-server package if you don’t have it yet. Once installed, edit the /etc/exports file as root to add the following line, assuming that the IP address of your board will be 192.168.0.100:

/home/\<user\>/embedded-linux-bbb-labs/tinysystem/nfsroot 192.168.0.100(rw,no_root_squash, no_subtree_check)

Of course, replace \<user\> by your actual user name.

Make sure that the path and the options are on the same line. Also make sure that there is no space between the IP address and the NFS options, otherwise default options will be used for this IP address, causing your root filesystem to be read-only.

Then, make the NFS server use the new configuration:

\$ sudo exportfs -r

**Booting the system**

First, boot the board to the U-Boot prompt. Before booting the kernel, we need to tell it that the root filesystem should be mounted over NFS, by setting some kernel parameters.

So add settings to the bootargs environment variable, **in just 1 line**:

=\> setenv bootargs \${bootargs} root=/dev/nfs ip=192.168.0.100:::::usb0

g_ether.dev_addr=f8:dc:7a:00:00:02 g_ether.host_addr=f8:dc:7a:00:00:01

nfsroot=192.168.0.1:/home/\<user\>/embedded-linux-bbb-labs/tinysystem/nfsroot,nfsvers=3,tcp rw

Once again, replace \<user\> by your actual user name.

Of course, you need to adapt the IP addresses to your exact network setup. Save the environment variables (with saveenv).

Now, boot your system. The kernel should be able to mount the root filesystem over NFS:

VFS: Mounted root (nfs filesystem) on device 0:16.

If the kernel fails to mount the NFS filesystem, look carefully at the error messages in the console. If this doesn’t give any clue, you can also have a look at the NFS server logs in /var/log/syslog.

However, at this stage, the kernel should stop because of the below issue:

\[ 7.476715\] devtmpfs: error mounting -2

This happens because the kernel is trying to mount the *devtmpfs* filesystem in /dev/ in the root filesystem. This virtual filesystem contains device files (such as ttyS0) for all the devices known to the kernel, and with

[CONFIG_DEVTMPFS_MOUNT](https://elixir.bootlin.com/linux/latest/K/ident/CONFIG_DEVTMPFS_MOUNT), our kernel tries to automatically mount *devtmpfs* on /dev.

To address this, just create a dev directory under nfsroot and reboot.

Now, the kernel should complain for the last time, saying that it can’t find an init application:

Kernel panic - not syncing: No working init found. Try passing init= option to kernel. See Linux Documentation/admin-guide/init.rst for guidance.

Obviously, our root filesystem being mostly empty, there isn’t such an application yet. In the next paragraph, you will add BusyBox to your root filesystem and finally make it usable.

**Root filesystem with BusyBox**

Download the sources of the latest BusyBox 1.37.x release:

git clone https://git.busybox.net/busybox

cd busybox/

git checkout 1_37_stable

Now, configure BusyBox with the configuration file provided in the data/ directory (remember that the BusyBox configuration file is .config in the BusyBox sources).

Then, you can use \$ make menuconfig to further customize the BusyBox configuration. At least, keep the setting that builds a static BusyBox. Compiling BusyBox statically in the first place makes it easy to set up the system, because there are no dependencies on libraries. Later on, we will set up shared libraries and recompile BusyBox.

If you are running on a distribution that uses GCC \>= 14.x, you will face an issue when trying to run make menuconfig, caused by a bug in Busybox, unfixed as of Busybox 1.37.0. You can fix this issue by applying an additional patch to the Busybox source:

git am \$HOME/embedded-linux-bbb-labs/tinysystem/data/\\

0001-menuconfig-GCC-failing-saying-ncurses-is-not-found.patch

Build BusyBox using the toolchain that you used to build the kernel.

Going back to the BusyBox configuration interface, check the installation directory for BusyBox6. Set it to the path to your nfsroot directory.

Now run \$ make install to install BusyBox in this directory.

Try to boot your new system on the board. You should now reach a command line prompt, allowing you to execute the commands of your choice.

**Virtual filesystems**

Run the \$ ps command. You can see that it complains that the /proc directory does not exist. The ps command and other process-related commands use the proc virtual filesystem to get their information from the kernel.

From the Linux command line in the target, create the proc, sys and etc directories in your root filesystem.

Now mount the proc virtual filesystem. Now that /proc is available, test again the ps command.

Note that you can also now halt your target in a clean way with the halt command, thanks to proc being

mounted7.

**System configuration and startup**

The first user space program that gets executed by the kernel is /sbin/init and its configuration file is /etc/inittab.

In the BusyBox sources, read details about /etc/inittab in the [examples/inittab](https://elixir.bootlin.com/busybox/latest/source/examples/inittab) file.

Then, create a /etc/inittab file and a /etc/init.d/rcS startup script declared in /etc/inittab. In this startup script, mount the /proc and /sys filesystems.

Any issue after doing this?

6 Settings -\> Install Options -\> Destination path for 'make install' You will find this setting in.

7 halt can find the list of mounted filesystems in /proc/mounts, and unmount each of them in a clean way before shutting

down.

**Starting the shell in a proper terminal**

Before the shell prompt, you probably noticed the below warning message:

/bin/sh: can't access tty; job control turned off

This happens because the shell specified in the /etc/inittab file in started by default in /dev/console:

::askfirst:/bin/sh

When nothing is specified before the leading ::, /dev/console is used. However, while this device is fine for a simple shell, it is not elaborate enough to support things such as job control (\[Ctrl\]\[c\] and \[Ctrl\]\[z\]), allowing to interrupt and suspend jobs.

So, to get rid of the warning message, we need init to run /bin/sh in a real terminal device:

ttyS0::askfirst:/bin/sh

Reboot the system and the message will be gone!

**Switching to shared libraries**

Take the hello.c program supplied in the lab data directory. Cross-compile it for ARM, dynamically-linked

with the libraries 8, and run it on the target.

You will first encounter a very misleading not found error, which is not because the hello executable is not found, but because something else was not found while trying to execute this executable.

You can find it by running file hello on the host:

hello: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV),

dynamically linked, interpreter /lib/ld-musl-armhf.so.1, not stripped

So, what’s missing is the /lib/ld-musl-armhf.so.1 executable, which is the dynamic linker required to execute any program compiled with shared libraries. Using the find command, look for this file in the toolchain install directory, and copy it to the lib/ directory on the target.

Then, running the executable again and see that the loader executes and finds out which shared libraries are missing.

In our case with the Musl C library, the dynamic linker also contains the C library, so the program should execute fine, as no further shared libraries are required.

If you still get the same error message, just try again a few seconds later. Such a delay can be needed because the NFS client can take a little time (at most 30-60 seconds) before seeing the changes made on the NFS server.

Now that the small test program works, we are going to recompile BusyBox without the static compilation option, so that BusyBox takes advantage of the shared libraries that are now present on the target.

Before doing that, measure the size of the busybox executable.

Then, build BusyBox with shared libraries, and install it again on the target filesystem. Make sure that the system still boots and see how much smaller the busybox executable got.

**Implement a web interface for your device**

Replicate data/www/ to the /www directory in your target root filesystem.

Now, run the BusyBox http server from the target command line:

=\> /usr/sbin/httpd -h /www/

8 Invoke your cross-compiler in the same way you did during the toolchain lab

It will automatically background itself.

If you use a proxy, configure your host browser so that it doesn’t go through the proxy to connect to the target IP address, or simply disable proxy usage. Now, test that your web interface works well by opening http://192.168.0.100/index.html on the host.

See how the dynamic pages are implemented. Very simple, isn’t it?

Finish by adding the command that starts the web server to your startup script, so that it is always started on your target.

**Going further**

If you have time before the others complete their labs...



**Initramfs booting**

Configure your kernel to include the contents of the nfsroot directory as an initramfs.

Before doing this, you will need to create an init link in the toplevel directory to sbin/init, because the kernel will try to execute /init.

You will also need to mount *devtmpfs* from the rcS script, it cannot be mounted automatically by the kernel when you’re booting from an initramfs.

Note: you won’t need to modify your root= setting in the kernel command line. It will just be ignored if you have an initramfs.

When this works, go back to booting the system through NFS. This will be much more convenient in the next labs.


