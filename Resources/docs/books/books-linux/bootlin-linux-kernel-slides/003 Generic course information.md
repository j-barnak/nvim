Generic course information

 

Generic course

 

information

 

© Copyright 2004-2025, Bootlin. embedded Linux and kernel engineering Creative Commons BY-SA 3.0 license.

Corrections, suggestions, contributions and translations are welcome!

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 9/436 Supported hardware

 

BeagleBone Black or BeagleBone Black Wireless, from [BeagleBoard.org](https://beagleboard.org) ▶ Texas Instruments AM335x (ARM Cortex-A8 CPU) ▶ SoC with 3D acceleration, additional processors (PRUs) and lots of

![](/tmp/audit/iter1/epubregen/bootlin-linux-kernel-slides/media/index-10_1.png)

peripherals.

![](/tmp/audit/iter1/epubregen/bootlin-linux-kernel-slides/media/index-10_2.png)

▶ 512 MB of RAM

▶ 4 GB of on-board eMMC storage

▶ USB host and USB device, microSD, micro HDMI ▶ WiFi and Bluetooth (wireless version), otherwise Ethernet ▶ 2 x 46 pins headers, with access to many expansion buses (I2C, SPI, UART

and more)

▶ A huge number of expansion boards, called *capes*. See

<https://elinux.org/Beagleboard:BeagleBone_Capes>.

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 10/436 Labs proposed on another platform

![](/tmp/audit/iter1/epubregen/bootlin-linux-kernel-slides/media/index-11_1.png)

 

You can also run the labs of this course on the Beagleplay board.

![](/tmp/audit/iter1/epubregen/bootlin-linux-kernel-slides/media/index-11_2.png)

 

Lab instructions are available at

[https://bootlin.com/doc/training/linux-kernel-](https://bootlin.com/doc/training/linux-kernel-beagleplay/)

[beagleplay/](https://bootlin.com/doc/training/linux-kernel-beagleplay/)

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 11/436

Shopping list: hardware for this course

![](/tmp/audit/iter1/epubregen/bootlin-linux-kernel-slides/media/index-12_1.jpg)

 

▶ BeagleBone Black or BeagleBone Black Wireless - Multiple distributors:

See <https://www.beagleboard.org/boards>.

▶ 1 USB Serial Cable - 3.3 V - Female ends (for serial console) ▶ 2 Nintendo Nunchuk with UEXT connector

![](/tmp/audit/iter1/epubregen/bootlin-linux-kernel-slides/media/index-12_2.jpg)

▶ 3 Breadboard jumper wires - Male ends (to connect the Nunchuk) ▶ 4 USB Serial Cable - 3.3 V - Male ends (for serial labs, two if possible) ▶ Note that both USB serial cables are the same.

![](/tmp/audit/iter1/epubregen/bootlin-linux-kernel-slides/media/index-12_3.jpg)

Only the gender of their connector changes.

1

<https://www.olimex.com/Products/Components/Cables/USB-Serial-Cable/USB-SERIAL-F/>

2

<https://www.olimex.com/Products/Modules/Sensors/MOD-WII/MOD-Wii-UEXT-NUNCHUCK/>

3

![](/tmp/audit/iter1/epubregen/bootlin-linux-kernel-slides/media/index-12_4.jpg)

<https://www.olimex.com/Products/Breadboarding/JUMPER-WIRES/JW-110x10/>

4

<https://www.olimex.com/Products/Components/Cables/USB-Serial-Cable/USB-SERIAL-M/>

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 12/436 Training quiz and certificate

 

▶ You have been given a quiz to test your knowledge on the topics covered by the

course. That’s not too late to take it if you haven’t done it yet! ▶ At the end of the course, we will submit this quiz to you again. That time, you

will see the correct answers.

▶ It allows Bootlin to assess your progress thanks to the course. That’s also a kind

of challenge, to look for clues throughout the lectures and labs / demos, as all the

answers are in the course!

▶ Another reason is that we only give training certificates to people who achieve at

least a 50% score in the final quiz **and** who attended all the sessions.

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 13/436

Participate!

 

During the lectures...

▶ Don’t hesitate to ask questions. Other people in the audience may have similar

questions too.

▶ Don’t hesitate to share your experience too, for example to compare Linux with

other operating systems you know.

▶ Your point of view is most valuable, because it can be similar to your colleagues’

and different from the trainer’s.

▶ In on-line sessions

*•* Please always keep your camera on! *•* Also make sure your name is properly filled. *•* You can also use the ”Raise your hand” button when you wish to ask a question but

don’t want to interrupt.

▶ All this helps the trainer to engage with participants, see when something needs

clarifying and make the session more interactive, enjoyable and useful for everyone.

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 14/436 Collaborate!

![](/tmp/audit/iter1/epubregen/bootlin-linux-kernel-slides/media/index-15_1.png)

 

As in the Free Software and Open Source community, collaboration between participants is valuable in this training session:

▶ Use the dedicated Matrix channel for this session to add

questions.

▶ If your session offers practical labs, you can also report issues,

share screenshots and command output there.

▶ Don’t hesitate to share your own answers and to help others

especially when the trainer is unavailable.

▶ The Matrix channel is also a good place to ask questions outside

of training hours, and after the course is over.

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 15/436

Practical lab - Training Setup

![](/tmp/audit/iter1/epubregen/bootlin-linux-kernel-slides/media/index-16_1.png)

 

Prepare your lab environment

![](/tmp/audit/iter1/epubregen/bootlin-linux-kernel-slides/media/index-16_2.png)

▶ Download and extract the lab archive

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 16/436

![](/tmp/audit/iter1/epubregen/bootlin-linux-kernel-slides/media/index-17_1.jpg)