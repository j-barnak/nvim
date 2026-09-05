**Filesystems - Block file systems**

*Objective: configure and boot an embedded Linux system relying on block* *storage*

After this lab, you will be able to:

• Produce file system images.

• Configure the kernel to use these file systems

• Use the tmpfs file system to store temporary files

• Load the kernel and DTB from a FAT partition

**Goals**

After doing the *A tiny embedded system* lab, we are going to copy the filesystem contents to the emulated SD card. The storage will be split into several partitions, and your QEMU emulated board will be booted from this SD card, without using NFS anymore.

**Setup**

Throughout this lab, we will continue to use the root filesystem we have created in the \$HOME/embedded-linux-qemu-labs/tinysystem/nfsroot directory, which we will progressively adapt to use block filesystems.

**Filesystem support in the kernel**

Recompile your kernel with support for SquashFS and ext48.

Update your kernel image on the tftp server. We will only later copy the kernel to our FAT partition.

Boot your board with this new kernel and on the NFS filesystem you used in this previous lab.

Now, check the contents of /proc/filesystems. You should see that ext4 and SquashFS are now supported.

**Format the third partition**

We are going to format the third partition of the SD card image with the ext4 filesystem, so that it can contain uploaded images.

Setup the loop device again:

\$ sudo losetup -f --show --partscan sd.img

And then format the third partition:

\$ sudo mkfs.ext4 -L data /dev/loop\<x\>p3

Now, mount this new partition on a directory on your host (you could create the /mnt/data directory, for example) and move the contents of the /www/upload/files directory (in your target root filesystem) into it.

The goal is to use the third partition of the SD card as the storage for the uploaded images.

You can now unmount the partition and free the loop device:

8Basic configuration options for these filesystems will be sufficient. No need for things like extended attributes.

24

© 2004-2025 [Bootlin](https://bootlin.com), CC BY-SA license

Embedded Linux System Development

\$ sudo umount /mnt/data

\$ sudo losetup -d /dev/loop\<x\>

Now, restart QEMU and from the Linux command line and mount this third partition on /www/upload/files.

Once this works, modify the startup scripts in your root filesystem to do it automatically at boot time.

Reboot your target system again and with the mount command, check that /www/upload/files is now a mount point for the third SD card partition. Also make sure that you can still upload new images, and that these images are listed in the web interface.

**Adding a tmpfs partition for log files**

For the moment, the upload script was storing its log file in /www/upload/files/upload.log. To avoid seeing this log file in the directory containing uploaded files, let’s store it in /var/log instead.

Add the /var/log/ directory to your root filesystem and modify the startup scripts to mount a tmpfs filesystem on this directory. You can test your tmpfs mount command line on the system before adding it to the startup script, in order to be sure that it works properly.

Modify the www/cgi-bin/upload.cfg configuration file to store the log file in /var/log/upload.log. You will lose your log file each time you reboot your system, but that’s OK in our system. That’s what tmpfs is for: temporary data that you don’t need to keep across system reboots.

Reboot your system and check that it works as expected.

**Making a SquashFS image**

We are going to store the root filesystem in a SquashFS filesystem in the second partition of the SD card.

In order to create SquashFS images on your host, you need to install the squashfs-tools package. Now create a SquashFS image of your NFS root directory.

Setup the loop device again, and using the dd command, copy the file system image to the second partition in the SD card image. Release the loop device.

**Booting on the SquashFS partition**

In the U-boot shell, configure the kernel command line to use the second partition of the SD card as the root file system. Also add the rootwait boot argument, to wait for the SD card to be properly initialized before trying to mount the root filesystem. Since the SD cards are detected asynchronously by the kernel, the kernel might try to mount the root filesystem too early without rootwait.

Check that your system still works. Congratulations if it does!

**Store the kernel image and DTB on the SD card**

Setup the loop device again, and mount the FAT partition in the SD card image (for example on /mnt/boot).

Then copy the kernel image and Device Tree to it.

Unmount the FAT partition and release the loop device.

You now need to adjust the bootcmd of U-Boot so that it loads the kernel and DTB from the SD card instead of loading them from the network.

In U-boot, you can load a file from a FAT filesystem using a command like

=\> fatload mmc 0:1 0x61000000 filename

Which will load the file named filename from the first partition of the device handled by the first MMC

controller to the system memory at the address 0x61000000.

Type =\> reset in U-Boot to reboot the board and make sure that your system still boots fine.

© 2004-2025 [Bootlin,](https://bootlin.com) CC BY-SA license 25

Embedded Linux System Development