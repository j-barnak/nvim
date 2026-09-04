**Training setup**

 

 

*Download files and directories used in practical labs*

 

**Install lab data**

For the different labs in this course, your instructor has prepared a set of data (kernel images, kernel config-urations, root filesystems and more). Download and extract its tarball from a terminal:

\$ cd

\$ wget https://bootlin.com/doc/training/embedded-linux-bbb/embedded-linux-bbb-labs.tar.xz \$ tar xvf embedded-linux-bbb-labs.tar.xz

Lab data are now available in an embedded-linux-bbb-labs directory in your home directory. This directory contains directories and files used in the various practical labs. It will also be used as working space, in particular to keep generated files separate when needed.

**Update your distribution**

To avoid any issue installing packages during the practical labs, you should apply the latest updates to the packages in your distro:

\$ sudo apt update

\$ sudo apt dist-upgrade

You are now ready to start the real practical labs!

**Install extra packages**

Feel free to install other packages you may need for your development environment. In particular, we recommend to install your favorite text editor and configure it to your taste. The favorite text editors of embedded Linux developers are of course *Vim* and *Emacs*, but there are also plenty of other possibilities,

such as Visual Studio Code1, *GEdit*, *Qt Creator*, *CodeBlocks*, *Geany*, etc.

It is worth mentioning that by default, Ubuntu comes with a very limited version of the vi editor. So if you would like to use vi, we recommend to use the more featureful version by installing the vim package.

**More guidelines**

Can be useful throughout any of the labs

• Read instructions and tips carefully. Lots of people make mistakes or waste time because they missed

an explanation or a guideline.

• Always read error messages carefully, in particular the first one which is issued. Some people stumble

on very simple errors just because they specified a wrong file path and didn’t pay enough attention to the corresponding error message.

• Never stay stuck with a strange problem more than 5 minutes. Show your problem to your colleagues

or to the instructor.

• You should only use the root user for operations that require super-user privileges, such as: mounting

a file system, loading a kernel module, changing file ownership, configuring the network. Most regular tasks (such as downloading, extracting sources, compiling...) can be done as a regular user.

1 This tool from Microsoft is Open Source! To try it on Ubuntu: sudo snap install code --classic

© 2004-2025 [Bootlin,](https://bootlin.com) CC BY-SA license 3

• If you ran commands from a root shell by mistake, your regular user may no longer be able to handle

the corresponding generated files. In this case, use the chown -R command to give the new files back to your regular user.

Example: \$ sudo chown -R myuser.myuser linux/

 

4 © 2004-2025 [Bootlin](https://bootlin.com), CC BY-SA license