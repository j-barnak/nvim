The input subsystem

 

The input subsystem

 

© Copyright 2004-2025, Bootlin. embedded Linux and kernel engineering Creative Commons BY-SA 3.0 license.

Corrections, suggestions, contributions and translations are welcome!

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 252/436 What is the input subsystem?

 

▶ The input subsystem takes care of all the input events coming from the human

user.

▶ Initially written to support the USB *HID* (Human Interface Device) devices, it

quickly grew up to handle all kinds of inputs (using USB or not): keyboards, mice,

joysticks, touchscreens, etc.

▶ The input subsystem is split in two parts:

*•* **Device drivers**: they talk to the hardware (for example via USB), and provide

events (keystrokes, mouse movements, touchscreen coordinates) to the input core

*•* **Event handlers**: they get events from drivers and pass them where needed via

various interfaces (most of the time through evdev)

▶ In user space it is usually used by the graphic stack such as *X.Org*, *Wayland* or

*Android’s InputManager*.

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 253/436 Input subsystem diagram

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 254/436 Input subsystem overview

 

▶ Kernel option [CONFIG_INPUT](https://elixir.bootlin.com/linux/latest/K/ident/CONFIG_INPUT)

*•* menuconfig INPUT

tristate "Generic input layer (needed for keyboard, mouse, ...)"

▶ Implemented in [drivers/input/](https://elixir.bootlin.com/linux/latest/source/drivers/input/)

*•* [input.c](https://elixir.bootlin.com/linux/latest/source/drivers/input/input.c), [input-polldev.c](https://elixir.bootlin.com/linux/latest/source/drivers/input/input-polldev.c), [evdev.c](https://elixir.bootlin.com/linux/latest/source/drivers/input/evdev.c)[...](https://elixir.bootlin.com/linux/latest/source/drivers/input/evdev.c)

▶ Defines the user/kernel API

*•* [include/uapi/linux/input.h](https://elixir.bootlin.com/linux/latest/source/include/uapi/linux/input.h)

▶ Defines the set of operations an input driver must implement and helper functions

for the drivers

*•* [struct input_dev](https://elixir.bootlin.com/linux/latest/ident/input_dev) for the device driver part

*•* [struct input_handler](https://elixir.bootlin.com/linux/latest/ident/input_handler) for the event handler part

*•* [include/linux/input.h](https://elixir.bootlin.com/linux/latest/source/include/linux/input.h)

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 255/436 Input subsystem API 1/3

 

An *input device* is described by a very long [struct input_dev](https://elixir.bootlin.com/linux/latest/ident/input_dev) structure, an excerpt is: struct input_dev {

const char \*name;

\[...\]

struct input_id id;

\[...\]

unsigned long evbit\[BITS_TO_LONGS(EV_CNT)\];

unsigned long keybit\[BITS_TO_LONGS(KEY_CNT)\];

\[...\]

int (\*getkeycode)(struct input_dev \*dev,

struct input_keymap_entry \*ke);

\[...\]

int (\*open)(struct input_dev \*dev);

\[...\]

int (\*event)(struct input_dev \*dev, unsigned int type,

unsigned int code, int value);

\[...\]

};

Before being used, this structure must be allocated and initialized, typically with: struct input_dev \*devm_input_allocate_device(struct device \*dev);

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 256/436 Input subsystem API 2/3

 

▶ Depending on the type of events that will be generated, the input bit fields evbit

and keybit must be configured: For example, for a button we only generate

[EV_KEY](https://elixir.bootlin.com/linux/latest/ident/EV_KEY) type events, and from these only [BTN_0](https://elixir.bootlin.com/linux/latest/ident/BTN_0) events code:

set_bit(EV_KEY, myinput_dev.evbit);

set_bit(BTN_0, myinput_dev.keybit);

▶ Once the *input device* is allocated and filled, the function to register it is:

int input_register_device(struct input_dev \*);

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 257/436 Input subsystem API 3/3

 

The events are sent by the driver to the event handler using void input_event(struct input_dev \*dev, unsigned int type, unsigned int code, int value)

▶ The event types are documented in [input/event-codes](https://www.kernel.org/doc/html/latest/input/event-codes.html) ▶ An event is composed by one or several input data changes (packet of input data

changes) such as the button state, the relative or absolute position along an axis,

etc..

▶ The input subsystem provides other wrappers such as:

*•* [input_report_key()](https://elixir.bootlin.com/linux/latest/ident/input_report_key)

*•* [input_report_abs()](https://elixir.bootlin.com/linux/latest/ident/input_report_abs)

After submitting potentially multiple events, the *input* core must be notified by calling:

 

void input_sync(struct input_dev \*dev)

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 258/436 Example from drivers/hid/usbhid/usbmouse.c

 

static void usb_mouse_irq(struct urb \*urb)

{

struct usb_mouse \*mouse = urb-\>context; signed char \*data = mouse-\>data;

struct input_dev \*dev = mouse-\>dev;

...

input_report_key(dev, BTN_LEFT, data\[0\] & 0x01); input_report_key(dev, BTN_RIGHT, data\[0\] & 0x02); input_report_key(dev, BTN_MIDDLE, data\[0\] & 0x04); input_report_key(dev, BTN_SIDE, data\[0\] & 0x08); input_report_key(dev, BTN_EXTRA, data\[0\] & 0x10); input_report_rel(dev, REL_X, data\[1\]); input_report_rel(dev, REL_Y, data\[2\]); input_report_rel(dev, REL_WHEEL, data\[3\]); input_sync(dev);

...

}

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 259/436

Polling input devices

 

▶ The input subsystem provides an API to support simple input devices that *do not*

*raise interrupts* but have to be *periodically scanned or polled* to detect changes in

their state.

▶ Setting up polling is done using [input_setup_polling():](https://elixir.bootlin.com/linux/latest/ident/input_setup_polling)

int input_setup_polling(struct input_dev \*dev, void (\*poll_fn)(struct input_dev \*dev)); ▶ poll_fn is the function that will be called periodically.

▶ The polling interval can be set using [input_set_poll_interval()](https://elixir.bootlin.com/linux/latest/ident/input_set_poll_interval) or

[input_set_min_poll_interval()](https://elixir.bootlin.com/linux/latest/ident/input_set_min_poll_interval) and [input_set_max_poll_interval()](https://elixir.bootlin.com/linux/latest/ident/input_set_max_poll_interval)

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 260/436 *evdev* user space interface

 

▶ The main user space interface to *input devices* is the **event interface** ▶ Each *input device* is represented as a /dev/input/event\<X\> character device ▶ A user space application can use blocking and non-blocking reads, but also

select() (to get notified of events) after opening this device.

▶ Each read will return [struct input_event](https://elixir.bootlin.com/linux/latest/ident/input_event) structures of the following format:

struct input_event {

struct timeval time;

unsigned short type;

unsigned short code;

unsigned int value;

};

▶ A very useful application for *input device* testing is evtest, from

<https://cgit.freedesktop.org/evtest/>

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 261/436

Practical lab - Expose the Nunchuk to user space

 

▶ Extend the Nunchuk driver to expose the

![](media/index-276_1.png)

Nunchuk features to user space applications, as an *input* device.

![](media/index-276_2.png)

▶ Test the operation of the Nunchuk using

evtest

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 262/436

![](media/index-277_1.jpg)