**Filesystems - Block file systems**





*Objective: configure and boot an embedded Linux system relying on block* *storage*



After this lab, you will be able to:

• Produce file system images.

• Configure the kernel to use these file systems

• Use the tmpfs file system to store temporary files

• Load the kernel and DTB from a FAT partition

**Goals**

After doing the *A tiny embedded system* lab, we are going to copy the filesystem contents to the SD card. The storage will be split into several partitions, and your board will boot on an root filesystem on this SD card, without using NFS anymore.

**Setup**

Throughout this lab, we will continue to use the root filesystem we have created in the \$HOME/embedded-linux-bbb-labs/tinysystem/nfsroot directory, which we will progressively adapt to use block filesystems.

**Filesystem support in the kernel**

Recompile your kernel with support for SquashFS and ext49.

Update your kernel image in the boot partition.

Boot your board with this new kernel and on the NFS filesystem you used in this previous lab.

Now, check the contents of /proc/filesystems. You should see that ext4 and SquashFS are now supported.

**Add partitions to the SD card**

Plug the SD card in your workstation.

Using cfdisk /dev/mmcblk0, add two partitions, starting from the beginning of the remaining space, with the following properties:

• A second primary partition, 8 MB big, for the root filesystem

• A third primary partition, that fills the rest of the SD card, that will be used for the data filesystem

Save and exit when you are done.

**Data partition on the SD card**

Using the mkfs.ext4 create a journaled file system on the third partition of the SD card:

\$ sudo mkfs.ext4 -L data -E nodiscard /dev/mmcblk0p3

•-L assigns a volume name to the partition

9 Basic configuration options for these filesystems will be sufficient. No need for things like extended attributes.


•-E nodiscard disables bad block discarding. While this should be a useful option for cards with bad

blocks, skipping this step saves long minutes in SD cards.

Now, mount this new partition and move the contents of the /www/upload/files directory (in your target root filesystem) into it. The goal is to use the data partition of the SD card as the storage for the uploaded images.

Insert the SD card in your board and boot. You should see the partitions in /proc/partitions.

Mount this data partition on /www/upload/files.

Once this works, modify the startup scripts in your root filesystem to do it automatically at boot time.

Reboot your target system and with the mount command, check that /www/upload/files is now a mount point for the last SD card partition. Also make sure that you can still upload new images, and that these images are listed in the web interface.

**Adding a tmpfs partition for log files**

For the moment, the upload script was storing its log file in /www/upload/files/upload.log. To avoid seeing this log file in the directory containing uploaded files, let’s store it in /var/log instead.

Add the /var/log/ directory to your root filesystem and modify the startup scripts to mount a tmpfs filesystem on this directory. You can test your tmpfs mount command line on the system before adding it to the startup script, in order to be sure that it works properly.

Modify the www/cgi-bin/upload.cfg configuration file to store the log file in /var/log/upload.log. You will lose your log file each time you reboot your system, but that’s OK in our system. That’s what tmpfs is for: temporary data that you don’t need to keep across system reboots.

Reboot your system and check that it works as expected.

**Making a SquashFS image**

We are going to store the root filesystem in a SquashFS filesystem in the second partition of the SD card.

In order to create SquashFS images on your host, you need to install the squashfs-tools package. Now create a SquashFS image of your NFS root directory.

Finally, using the dd command, copy the file system image to the second partition of the SD card.

**Booting on the SquashFS partition**

In the U-boot shell, configure the kernel command line to use the second partition of the SD card as the root file system. Also add the rootwait boot argument, to wait for the SD card to be properly initialized before trying to mount the root filesystem. Since the SD cards are detected asynchronously by the kernel, the kernel might try to mount the root filesystem too early without rootwait.

Check that your system still works.

**Loading the kernel and DTB from the SD card**

In order to let the kernel boot on the board autonomously, we can copy the kernel image and DTB in the boot partition we created previously.

Insert the SD card in your PC, it will get auto-mounted. Copy the kernel and device tree to the boot partition.

Insert the SD card back in the board and reset it. You should now be able to load the DTB and kernel image from the SD card and boot with:

=\> load mmc 0:1 0x81000000 zImage

=\> load mmc 0:1 0x82000000 am335x-boneblack-custom.dtb



=\> bootz 0x81000000 - 0x82000000

You are now ready to modify bootcmd to boot the board from SD card. But first, save the settings for booting from tftp:

=\> setenv bootcmdtftp \${bootcmd}

This will be useful to switch back to tftp booting mode later in the labs.

Finally, using editenv bootcmd, adjust bootcmd so that the board starts using the kernel from the SD card.

Now, reset the board to check that it boots in the same way from the SD card.

Now, the whole system (bootloader, kernel and filesystems) is stored on the SD card. That’s very useful for product demos, for example. You can switch demos by switching SD cards, and the system depends on nothing else. In particular, no networking is necessary.


