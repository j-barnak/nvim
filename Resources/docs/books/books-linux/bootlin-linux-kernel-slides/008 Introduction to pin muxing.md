![](media/index-166_1.jpg)

Introduction to pin muxing

 

Introduction to pin

 

muxing

 

© Copyright 2004-2025, Bootlin. embedded Linux and kernel engineering Creative Commons BY-SA 3.0 license.

Corrections, suggestions, contributions and translations are welcome!

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 152/436 What is pin muxing?

 

▶ Modern SoCs (System on Chip) include more and more hardware blocks, many of

which need to interface with the outside world using *pins*. ▶ However, the physical size of the chips remains small, and therefore the number of

available pins is limited.

▶ For this reason, not all of the internal hardware block features can be exposed on

the pins simultaneously.

▶ The pins are **multiplexed**: they expose either the functionality of hardware block

A **or** the functionality of hardware block B. ▶ This *multiplexing* is usually software configurable.

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 153/436 Pin muxing diagram

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 154/436 Pin muxing in the Linux kernel

 

▶ Since Linux 3.2, a pinctrl subsystem has been added.

▶ This subsystem, located in [drivers/pinctrl/](https://elixir.bootlin.com/linux/latest/source/drivers/pinctrl/) provides a generic subsystem to

handle pin muxing. It offers:

*•* A pin muxing driver interface, to implement the system-on-chip specific drivers that

configure the muxing.

*•* A pin muxing consumer interface, for device drivers.

▶ Most *pinctrl* drivers provide a Device Tree binding, and the pin muxing must be

described in the Device Tree.

*•* The exact Device Tree binding depends on each driver. Each binding is defined in

[Documentation/devicetree/bindings/pinctrl](https://kernel.org/doc/Documentation/devicetree/bindings/pinctrl).

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 155/436 pinctrl subsystem diagram

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 156/436 Device Tree properties for consumer devices

 

The devices that require certains pins to be muxed will use the pinctrl-\<x\> and pinctrl-names Device Tree properties.

▶ The pinctrl-0, pinctrl-1, pinctrl-\<x\> properties link to a pin configuration

for a given state of the device.

▶ The pinctrl-names property associates a name to each state. The name

default is special, and is automatically selected by a device driver, without

having to make an explicit *pinctrl* function call.

▶ See [Documentation/devicetree/bindings/pinctrl/pinctrl-bindings.txt](https://kernel.org/doc/Documentation/devicetree/bindings/pinctrl/pinctrl-bindings.txt) for

details.

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 157/436

Device Tree properties for consumer devices - Examples

 

i2c0: i2c@f8014000 {

i2c0: i2c@11000 {

```cpp
...

...
```

pinctrl-names = "default", "gpio";

pinctrl-0 = \<&pmx_twsi0\>;

pinctrl-0 = \<&pinctrl_i2c0\>;

pinctrl-names = "default";

pinctrl-1 = \<&pinctrl_i2c0_gpio\>;

```cpp
...

...
```

};

};

Most common case [(arch/arm/boot/dts/](https://elixir.bootlin.com/linux/latest/source/arch/arm/boot/dts/marvell/kirkwood.dtsi)

Case with multiple pin states [(arch/arm/](https://elixir.bootlin.com/linux/latest/source/arch/arm/boot/dts/microchip/sama5d4.dtsi)

[marvell/kirkwood.dtsi](https://elixir.bootlin.com/linux/latest/source/arch/arm/boot/dts/marvell/kirkwood.dtsi)) [boot/dts/microchip/sama5d4.dtsi)](https://elixir.bootlin.com/linux/latest/source/arch/arm/boot/dts/microchip/sama5d4.dtsi)

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 158/436 Defining pinctrl configurations

 

▶ The different *pinctrl configurations* must be defined as child nodes of the main

*pinctrl device* (which controls the muxing of pins). ▶ The configurations may be defined at:

*•* the SoC level (.dtsi file), for pin configurations that are often shared between

multiple boards

*•* at the board level (.dts file) for configurations that are board specific.

▶ The pinctrl-\<x\> property of the consumer device points to the pin configuration

it needs through a DT *phandle*.

▶ The description of the configurations is specific to each *pinctrl driver*. See

[Documentation/devicetree/bindings/pinctrl](https://kernel.org/doc/Documentation/devicetree/bindings/pinctrl) for the pinctrl bindings.

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 159/436 Example on OMAP/AM33xx

 

/\* Excerpt from am335x-bone-common.dts \*/

&am33xx_pinmux {

...

▶ i2c2_pins: pinmux_i2c2_pins { On OMAP/AM33xx, the pinctrl-single pinctrl-single,pins = \< AM33XX_PADCONF(AM335X_PIN_UART1_CTSN, PIN_INPUT_PULLUP, MUX_MODE3)

driver is used. It is common between multiple /\* uart1_ctsn.i2c2_sda \*/

SoCs and simply allows to configure pins by AM33XX_PADCONF(AM335X_PIN_UART1_RTSN, PIN_INPUT_PULLUP, MUX_MODE3)

/\* uart1_rtsn.i2c2_scl \*/

writing a value to a register. \>;

*•* };

In each pin configuration, a }; pinctrl-single,pins value gives a list &i2c2 { of pinctrl-names = "default"; *(register, value)* pairs needed to pinctrl-0 = \<&i2c2_pins\>;

configure the pins. status = "okay";

▶ clock-frequency = \<400000\>; To know the correct values, one must use the ...

SoC and board datasheets. pressure@76 {

compatible = "bosch,bmp280"; reg = \<0x76\>;

};

};

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 160/436 Example on the Allwinner A20 SoC

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 161/436

Practical lab - Setup pinmuxing to enable I2C communication

 

▶ Configure the pinmuxing for the I2C bus used

![](media/index-176_1.png)

to communicate with the Nunchuk

![](media/index-176_2.png)

▶ Validate that the I2C communication works

with user space tools.

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 162/436