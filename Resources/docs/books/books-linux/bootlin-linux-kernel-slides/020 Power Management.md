![](media/index-422_1.jpg)

Power Management

 

Power Management

 

© Copyright 2004-2025, Bootlin. embedded Linux and kernel engineering Creative Commons BY-SA 3.0 license.

Corrections, suggestions, contributions and translations are welcome!

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 408/436 PM building blocks

 

▶ Several power management *building blocks*

*•* Clock framework

*•* Suspend and resume

*•* CPUidle

*•* Runtime power management

*•* Power domains

*•* Frequency and voltage scaling

▶ Independent *building blocks* that can be improved gradually during development

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 409/436 Clock framework (1)

 

▶ Generic framework to manage clocks used by devices in the system ▶ Allows to reference count clock users and to shutdown the unused clocks to save

power

▶ Simple API described in [include/linux/clk.h.](https://elixir.bootlin.com/linux/latest/source/include/linux/clk.h)

*•* [clk_get()](https://elixir.bootlin.com/linux/latest/ident/clk_get) to lookup and obtain a reference to a clock producer

*•* [clk_put()](https://elixir.bootlin.com/linux/latest/ident/clk_put) to free the clock source

*•* [clk_prepare_enable()](https://elixir.bootlin.com/linux/latest/ident/clk_prepare_enable) to inform the system when the clock source should be

running

*•* [clk_disable_unprepare()](https://elixir.bootlin.com/linux/latest/ident/clk_disable_unprepare) to inform the system when the clock source is no longer

required.

*•* [clk_get_rate()](https://elixir.bootlin.com/linux/latest/ident/clk_get_rate) to obtain the current clock rate (in Hz) for a clock source

*•* [clk_set_rate()](https://elixir.bootlin.com/linux/latest/ident/clk_set_rate) to set the current clock rate (in Hz) of a clock source

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 410/436 Clock framework (2)

 

The common clock framework

▶ Allows to declare the available clocks and their association to devices in the

Device Tree

▶ Provides a *debugfs* representation of the clock tree

▶ Is implemented in [drivers/clk/](https://elixir.bootlin.com/linux/latest/source/drivers/clk/)

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 411/436 Diagram overview of the common clock framework

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 412/436 Clock framework (3)

 

The interface of the CCF divided into two halves:

▶ Common Clock Framework core

*•* Common definition of [struct clk](https://elixir.bootlin.com/linux/latest/ident/clk)

*•* Common implementation of the clk.h API (defined in [drivers/clk/clk.c](https://elixir.bootlin.com/linux/latest/source/drivers/clk/clk.c)[)](https://elixir.bootlin.com/linux/latest/source/drivers/clk/clk.c)

*•* [struct clk_ops](https://elixir.bootlin.com/linux/latest/ident/clk_ops)[:](https://elixir.bootlin.com/linux/latest/ident/clk_ops) operations invoked by the clk API implementation *•* Not supposed to be modified when adding a new driver

▶ Hardware-specific

*•* Callbacks registered with [struct clk_ops](https://elixir.bootlin.com/linux/latest/ident/clk_ops) and the corresponding hardware-specific

structures

*•* Has to be written for each new hardware clock

*•* Example: [drivers/clk/mvebu/clk-cpu.c](https://elixir.bootlin.com/linux/latest/source/drivers/clk/mvebu/clk-cpu.c)

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 413/436 Clock framework (4)

 

Hardware clock operations: device tree

▶ The **device tree** is the **mandatory way** to declare a clock and to get its

resources, as for any other driver using DT we have to:

*•* **Parse** the device tree to **setup** the clock: the resources but also the properties are

retrieved.

*•* Declare the **compatible** clocks and associate each to an **initialization** function

using [CLK_OF_DECLARE()](https://elixir.bootlin.com/linux/latest/ident/CLK_OF_DECLARE)

*•* Example: [arch/arm/boot/dts/marvell/armada-xp.dtsi](https://elixir.bootlin.com/linux/latest/source/arch/arm/boot/dts/marvell/armada-xp.dtsi) and

[drivers/clk/mvebu/armada-xp.c](https://elixir.bootlin.com/linux/latest/source/drivers/clk/mvebu/armada-xp.c)

See our presentation about the Clock Framework for more details:

<https://bootlin.com/pub/conferences/2013/elce/common-clock-framework-how-to-use-it/>

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 414/436 Suspend and resume (to / from RAM)

 

▶ Infrastructure in the kernel to support suspend and resume ▶ System on Chip hooks

*•* Define operations (at least valid() and enter()) [struct platform_suspend_ops](https://elixir.bootlin.com/linux/latest/ident/platform_suspend_ops)

structure. See the documentation for this structure for details about possible operations and the way they are used.

*•* Registered using the [suspend_set_ops()](https://elixir.bootlin.com/linux/latest/ident/suspend_set_ops) function

*•* See [arch/arm/mach-at91/pm.c](https://elixir.bootlin.com/linux/latest/source/arch/arm/mach-at91/pm.c)

▶ Device driver hooks

*•* pm operations (suspend() and resume() hooks) in the [struct device_driver](https://elixir.bootlin.com/linux/latest/ident/device_driver) as a

[struct dev_pm_ops](https://elixir.bootlin.com/linux/latest/ident/dev_pm_ops) structure in [(](https://elixir.bootlin.com/linux/latest/ident/platform_driver)[struct platform_driver](https://elixir.bootlin.com/linux/latest/ident/platform_driver)[,](https://elixir.bootlin.com/linux/latest/ident/platform_driver) [struct usb_driver](https://elixir.bootlin.com/linux/latest/ident/usb_driver), etc.)

*•* See [drivers/net/ethernet/cadence/macb_main.c](https://elixir.bootlin.com/linux/latest/source/drivers/net/ethernet/cadence/macb_main.c)

▶ *Hibernate to disk* is based on suspend to RAM, copying the RAM contents (after

a simulated suspend) to a swap partition.

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 415/436

Triggering suspend / hibernate

 

▶ [struct suspend_ops](https://elixir.bootlin.com/linux/latest/ident/suspend_ops) functions are called by the [enter_state()](https://elixir.bootlin.com/linux/latest/ident/enter_state) function.

[enter_state()](https://elixir.bootlin.com/linux/latest/ident/enter_state) also takes care of executing the suspend and resume functions for

your devices.

▶ Read [kernel/power/suspend.c](https://elixir.bootlin.com/linux/latest/source/kernel/power/suspend.c)

▶ The execution of this function can be triggered from user space:

*•* echo mem \> /sys/power/state (suspend to RAM) *•* echo disk \> /sys/power/state (hibernate to disk)

▶ Systemd can also manage suspend and hibernate for you, and offers

customizations

*•* systemctl suspend or systemctl hibernate.

*•* See [https://www.man7.org/linux/man-pages/man8/systemd-](https://www.man7.org/linux/man-pages/man8/systemd-suspend.service.8.html)

[suspend.service.8.html](https://www.man7.org/linux/man-pages/man8/systemd-suspend.service.8.html)

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 416/436 Saving power in the idle loop

 

▶ The idle loop is what you run when there’s nothing left to run in the system.

▶ [arch_cpu_idle()](https://elixir.bootlin.com/linux/latest/ident/arch_cpu_idle) implemented in all architectures in

arch/\<arch\>/kernel/process.c

▶ Example: [arch/arm/kernel/process.c](https://elixir.bootlin.com/linux/latest/source/arch/arm/kernel/process.c) ▶ The CPU can run power saving HLT instructions, enter NAP mode, and even

disable the timers (tickless systems).

▶ See also <https://en.wikipedia.org/wiki/Idle_loop>

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 417/436 Managing idle

 

Adding support for multiple idle levels

▶ Modern CPUs have several sleep states offering different power savings with

associated wake up latencies

▶ The *dynamic tick* feature allows to remove the periodic timer tick to save power,

and to know when the next event is scheduled, for smarter sleeps. ▶ CPUidle infrastructure to change sleep states

*•* Platform-specific driver defining sleep states and transition operations *•* Platform-independent governors *•* Available in particular for x86/ACPI and most ARM SoCs

*•* See [admin-guide/pm/cpuidle](https://www.kernel.org/doc/html/latest/admin-guide/pm/cpuidle.html) in kernel documentation.

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 418/436 PowerTOP

 

<https://en.wikipedia.org/wiki/PowerTOP>

▶ With dynamic ticks, allows to fix parts of kernel code and applications that wake

up the system too often.

▶ PowerTOP allows to track the worst offenders ▶ Now available on ARM cpus implementing CPUidle ▶ Also gives you useful hints for reducing power. ▶ Try it on your x86 laptop:

sudo powertop

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 419/436 Runtime power management

 

▶ Managing per-device idle, each device being managed by its device driver

independently from others.

▶ According to the kernel configuration interface: *Enable functionality allowing I/O*

*devices to be put into energy-saving (low power) states at run time (or*

*autosuspended) after a specified period of inactivity and woken up in response to*

*a hardware-generated wake-up event or a driver’s request.* ▶ New hooks must be added to the drivers: runtime_suspend(),

runtime_resume(), runtime_idle() in the [struct dev_pm_ops](https://elixir.bootlin.com/linux/latest/ident/dev_pm_ops) structure in

[struct device_driver.](https://elixir.bootlin.com/linux/latest/ident/device_driver)

▶ API and details on [power/runtime_pm](https://www.kernel.org/doc/html/latest/power/runtime_pm.html)

▶ See [drivers/net/ethernet/cadence/macb_main.c](https://elixir.bootlin.com/linux/latest/source/drivers/net/ethernet/cadence/macb_main.c) again.

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 420/436 Generic PM Domains (genpd)

 

▶ Generic infrastructure to implement power domains based on Device Tree

descriptions, allowing to group devices by the physical power domain they belong

to. This sits at the same level as bus type for calling PM hooks. ▶ All the devices in the same PD get the same state at the same time. ▶ Specifications and examples available at

[Documentation/devicetree/bindings/power/power_domain.txt](https://kernel.org/doc/Documentation/devicetree/bindings/power/power_domain.txt)

▶ Driver example: [drivers/soc/rockchip/pm_domains.c](https://elixir.bootlin.com/linux/latest/source/drivers/soc/rockchip/pm_domains.c)

( [rockchip_pd_power_on(),](https://elixir.bootlin.com/linux/latest/ident/rockchip_pd_power_on) [rockchip_pd_power_off()](https://elixir.bootlin.com/linux/latest/ident/rockchip_pd_power_off)[,](https://elixir.bootlin.com/linux/latest/ident/rockchip_pd_power_off)

[rockchip_pm_add_one_domain()](https://elixir.bootlin.com/linux/latest/ident/rockchip_pm_add_one_domain)...)

▶ DT example: look for [rockchip,px30-power-controller](https://elixir.bootlin.com/linux/latest/B/ident/rockchip%2Cpx30-power-controller)

([arch/arm64/boot/dts/rockchip/px30.dtsi)](https://elixir.bootlin.com/linux/latest/source/arch/arm64/boot/dts/rockchip/px30.dtsi) and find PD definitions and

corresponding devices.

▶ See Kevin Hilman’s talk at Kernel Recipes 2017:

<https://youtu.be/SctfvoskABM>

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 421/436

Frequency and voltage scaling (1)

 

Frequency and voltage scaling possible through the cpufreq kernel infrastructure.

▶ Generic infrastructure: [drivers/cpufreq/cpufreq.c](https://elixir.bootlin.com/linux/latest/source/drivers/cpufreq/cpufreq.c) and

[include/linux/cpufreq.h](https://elixir.bootlin.com/linux/latest/source/include/linux/cpufreq.h)

▶ Generic governors, responsible for deciding frequency and voltage transitions

*•* performance: maximum frequency *•* powersave: minimum frequency *•* ondemand: measures CPU consumption to adjust frequency *•* conservative: often better than ondemand. Only increases frequency gradually

when the CPU gets loaded.

*•* schedutil: Tightly integrated with the scheduler, making per-policy decisions, RT

tasks running at full speed.

*•* userspace: leaves the decision to a user space daemon.

▶ This infrastructure can be controlled from

/sys/devices/system/cpu/cpu\<n\>/cpufreq/

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 422/436 Frequency and voltage scaling (2)

 

▶ CPU frequency drivers are in [drivers/cpufreq/](https://elixir.bootlin.com/linux/latest/source/drivers/cpufreq/). Example:

[drivers/cpufreq/omap-cpufreq.c](https://elixir.bootlin.com/linux/latest/source/drivers/cpufreq/omap-cpufreq.c)

▶ Must implement the operations of the cpufreq_driver structure and register

them using [cpufreq_register_driver()](https://elixir.bootlin.com/linux/latest/ident/cpufreq_register_driver)

*•* init() for initialization

*•* exit() for cleanup

*•* verify() to verify the user-chosen policy *•* setpolicy() or target() to actually perform the frequency change

▶ See documentation in [cpu-freq/](https://www.kernel.org/doc/html/latest/cpu-freq/) for useful explanations

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 423/436 Regulator framework

 

▶ Modern embedded platforms have hardware responsible for voltage and current

regulation

▶ The regulator framework allows to take advantage of this hardware to save power

when parts of the system are unused

*•* A consumer interface for device drivers (i.e. users) *•* Regulator driver interface for regulator drivers *•* Machine interface for board configuration *•* sysfs interface for user space

▶ See [power/regulator/](https://www.kernel.org/doc/html/latest/power/regulator/) in kernel documentation.

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 424/436 BSP work for a new board

 

In case you just need to create a BSP for your board, and your CPU already has full PM support, you should just need to:

▶ Create clock definitions and bind your devices to them. ▶ Implement PM handlers (suspend, resume) in the drivers for your board specific

devices.

▶ Implement runtime PM handlers in your drivers. ▶ Implement board specific power management if needed (mainly battery

management)

▶ Implement regulator framework hooks for your board if needed. ▶ Attach on-board devices to PM domains if needed ▶ All other parts of the PM infrastructure should be already there: suspend /

resume, cpuidle, cpu frequency and voltage scaling, PM domains.

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 425/436

Useful resources

 

▶ [power/](https://www.kernel.org/doc/html/latest/power/) in kernel documentation.

*•* Will give you many useful details.

▶ Introduction to kernel power management, Kevin Hilman (Kernel Recipes 2015)

*•* <https://www.youtube.com/watch?v=juJJZORgVwI>

▶ Linux Power Management Features, Their Relationships and Interactions —

Théo Lebrun (Embedded Linux Conference Europe 2024)

*•* <https://www.youtube.com/watch?v=_jb6U40ZCZk>

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 426/436