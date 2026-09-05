## **Chapter 5 – UEFI Runtime** 

 

Adding manpower to a late software project makes it later.

—Brook’s Law

 

This chapter describes the fundamental services that are made available in an UEFI-

compliant system. The services are defined by interface functions that may be used by code running in the UEFI environment. Such code may include protocols that man-

age device access or extend platform capabilities. In this chapter, the runtime services will be the focus of discussion. These runtime services are functions that are available

both during UEFI operation and when the OS has been launched and running.

 

During boot, system resources are owned by the firmware and are controlled through a variety of system services that expose callable APIs. In UEFI there are two primary

types of services:

■ Boot Services – Functions that are available prior to the launching of the boot

target (such as the OS), and prior to the calling of the ExitBootServices()

function.

■ Runtime Services – Functions that are available both during the boot phase prior

to the launching of the boot target and after the boot target is executing.

 

Figure 5.1 illustrates the phases of boot operation that a platform evolves through.

 

**Exposed**

 

**Vectpr** **Reset** **Runtime** **Interface** **OS-Absent** **App** **CPU** **Init** **Transient OS** **Chipset** **Device,** **Environment** **Init** **Bus, or** **Service** **Board** **Transient OS** **Init** **Driver** **Boot Loader**

 

**Boot Manager** **OS-Present** **App**

 

**Boot Loader** **Final OS** **?** **Final OS**

**Environment**

**Boot Services API Availability**

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-84_1.png)

**Runtime Services API Availability**

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-84_2.png)

**Reset** **Early** **Launch** **Transient** **Run Time** **After** **Vector** **Platform** **EFI** **System Load** **(RT)** **Life**

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-84_3.png)

**Initialization** **Infrastructure** **(TSL)** **(AL)**

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-84_4.png)

**Power on** **\[ . . Platform initialization . . \]** **\[ . . . . OS boot . . . . \]** **Shutdown**

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-84_5.png)

 

**Figure 5.1:** Phases of Boot Operation

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-84_6.png)

 

DOI 10.1515/9781501505690-007

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-84_7.png)

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-84_8.png)

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-84_9.png)

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-84_10.png)

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-84_11.png)

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-84_12.png)

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-84_13.png)

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-84_14.png)

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-84_15.png)

**66** \| Chapter 5 – UEFI Runtime

 

In Figure 5.1, it is clearly evident that the two previously mentioned forms of services (Boot Services and Runtime Services) are available during the early launch of the

UEFI infrastructure and only the runtime services are available after the remainder of

the firmware stack has relinquished control to an OS loader. Once an OS loader has loaded enough of its own environment to take control of the system’s continued op-eration it can then terminate the boot services with a call to ExitBootSer-

vices().

In principle, the ExitBootServices() call is intended for use by the operat-

ing system to indicate that its loader is ready to assume control of the platform and

all platform resource management. Thus, boot services are available up to this point to assist the OS loader in preparing to boot the operating system. Once the OS loader takes control of the system and completes the operating system boot process, only

runtime services may be called. Code other than the OS loader, however, may or may not choose to call ExitBootServices(). This choice may in part depend upon

whether or not such code is designed to make continued use of UEFI boot services or

the boot services environment.

 

**Isn’t There Only One Kind of Memory?**

 

When UEFI memory is allocated, it is “typed” according to certain classifications which designate the general purpose of a particular memory type. For instance, one

might choose to allocate a buffer as an EfiRuntimeServicesData buffer if it was desired that a buffer containing some data remained available into the runtime

phase of platform operations. When allocated memory, one might think “Why not

allocate everything as a runtime memory type ‘just in case’?” Such activity is hazard-ous because when the platform transitions from Boot Services phase into Runtime phase, all of the buffers which might have been allocated as runtime as now frozen

and unavailable to the OS. Since there is an implicit assumption that items which request runtime-enabled memory know what they are doing, one can imagine a pro-

liferation of memory leaks if we simply assumed a single type of memory usage. With this situation in mind, UEFI establishes a certain set of memory types with certain

expected usage associated with each.

Isn’t There Only One Kind of Memory? \| **67**

 

**Table 5.1:** UEFI Memory Types and Usage Prior to ExitBootServices()

 

**Mnemonic Description**

 

EfiReservedMemoryType Not used.

 

EfiLoaderCode The code portions of a loaded application. (Note that UEFI

OS loaders are UEFI applications.)

 

EfiLoaderData The data portions of a loaded application and the default

data allocation type used by an application to allocate pool

memory.

 

EfiBootServicesCode The code portions of a loaded Boot Services Driver.

 

EfiBootServicesData The data portions of a loaded Boot Serves Driver, and the

default data allocation type used by a Boot Services Driver

to allocate pool memory.

 

EfiRuntimeServicesCode The code portions of a loaded Runtime Services Driver.

 

EfiRuntimeServicesData The data portions of a loaded Runtime Services Driver and

the default data allocation type used by a Runtime Services

Driver to allocate pool memory.

 

EfiConventionalMemory Free (unallocated) memory.

 

EfiUnusableMemory Memory in which errors have been detected.

 

EfiACPIReclaimMemory Memory that holds the ACPI tables.

 

EfiACPIMemoryNVS Address space reserved for use by the firmware.

 

EfiMemoryMappedIO Used by system firmware to request that a memory-mapped

IO region be mapped by the OS to a virtual address so it can

be accessed by UEFI runtime services.

 

EfiMemoryMappedIOPortSpace System memory-mapped IO region that is used to translate

memory cycles to IO cycles by the processor.

 

EfiPalCode Address space reserved by the firmware for code that is part

of the processor.

 

Table 5.1 lists memory types and their corresponding usage prior to launching a boot

target (such as an OS). The memory types that would be used by most runtime drivers would be those with the keyword “runtime” in them.

However, to better illustrate how these memory types are used in the runtime phase of the platform evolution, Table 5.2 illustrates how these UEFI Memory types

are used after the OS loader has called ExitBootServices() to indicate the tran-sition from the pre-boot, to the runtime phase of operations.

**68** \| Chapter 5 – UEFI Runtime

 

**Table 5.2:**UEFI Memory Types and Usage after ExitBootServices()

 

**Mnemonic Description**

 

EfiReservedMemoryType Not used.

 

EfiLoaderCode The Loader and/or OS may use this memory as they see fit.

Note: the OS loader that called Exit-BootServices() is utilizing one or more Efi-LoaderCode ranges.

 

EfiLoaderData The Loader and/or OS may use this memory as they see fit.

Note: the OS loader that called Exit-BootServices() is utilizing one or more Efi-LoaderData ranges.

 

EfiBootServicesCode Memory available for general use.

 

EfiBootServicesData Memory available for general use.

 

EfiRuntimeServicesCode The memory in this range is to be preserved by the loader

and OS in the working and ACPI S1–S3 states.

 

EfiRuntimeServicesData The memory in this range is to be preserved by the loader

and OS in the working and ACPI S1–S3 states.

 

EfiConventionalMemory Memory available for general use.

 

EfiUnusableMemory Memory that contains errors and is not to be used.

 

EfiACPIReclaimMemory This memory is to be preserved by the loader and OS until

ACPI is enabled. Once ACPI is enabled, the memory in this

range is available for general use.

 

EfiACPIMemoryNVS This memory is to be preserved by the loader and OS in the

working and ACPI S1–S3 states.

 

EfiMemoryMappedIO This memory is not used by the OS. All system memory-

mapped IO information should come from ACPI tables.

 

EfiMemoryMappedIOPortSpace This memory is not used by the OS. All system memory-

mapped IO port space information should come from ACPI

tables.

 

EfiPalCode This memory is to be preserved by the loader and OS in the

working and ACPI S1–S3 states. This memory may also

have other attributes that are defined by the processor im-

plementation.

 

In Table 5.2, one can see how the runtime memory types are preserved, and the

BootServices type of memory is available for the OS to reclaim as its own.

How Are Runtime Services Exposed? \| **69**

 

**How Are Runtime Services Exposed?**

 

In UEFI, firmware services are exposed through a set of UEFI protocol definitions, a series of function pointers in some special purpose service tables, and finally in the

UEFI configuration table. Of these mechanisms that are used to expose firmware

APIs, only the following two are persistent into the runtime phase of computer oper-ations.

■ Runtime Services Table - The UEFI Runtime Services Table contains pointers to

all of the runtime services. All elements in the UEFI Runtime Services Table are

prototypes of function pointers that are valid after the operating system has taken

control of the platform with a call to ExitBootServices().

■ UEFI Configuration Table - The UEFI Configuration Table contains a set of

GUID/pointer pairs. The number of entries in this table can easily grow over time.

That is why a GUID is used to identify the configuration table type. This table may

contain at most one instance of each table type.

 

The runtime services that are exposed in the UEFI Runtime Services Table at mini-mum define the core required runtime API capabilities of an UEFI-compliant plat-

form. These functions include services that expose time, virtual memory, and variable services at a minimum.

The information exposed through the UEFI Configuration Table is going to vary widely between platform implementations. One key thing to note, however, is that

the GUID associated with the GUID/pointer pair defines how one interprets the data to which the pointer is pointing. The content to which the pointer is pointed could be

a function/API, a table of data, or practically anything else. Some examples of the type of information that can be exposed through this table are SMBIOS, ACPI, and

MPS tables, as well as function prototypes for an UNDI-compliant network card. Fig-ure 5.2 is an example diagram of the interactions between the UEFI Configuration Ta-

ble and an example function prototype.

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-88_1.png)

 

**Figure 5.2:** Interactions between the UEFI Configuration Table and a Function Prototype

**70** \| Chapter 5 – UEFI Runtime

 

**Time Services**

 

This section describes the core UEFI definitions for time-related functions that are specifically needed by operating systems at runtime to access underlying hardware

that manages time information and services. The purpose of these interfaces is to pro-

vide runtime consumers of these services an abstraction for hardware time devices, thereby relieving the need to access legacy hardware devices directly. The functions listed in Table 5.3 reside in the UEFI Runtime Services table.

 

**Table 5.3:** Time-based Functions in the UEFI Runtime Services Table

 

**Name Type** **Description**

 

GetTime Runtime Returns the current time and date, and the time-keeping capa-

bilities of the platform.

 

SetTime Runtime Sets the current local time and date information.

 

GetWakeupTime Runtime Returns the current wakeup alarm clock setting.

 

SetWakeupTime Runtime Sets the system wakeup alarm clock time.

 

**Why Abstract Time?**

 

For a variety of reasons one might choose to abstract the access to the platform RealTime Clock (RTC). First, very poor standard mechanisms (if any) exist to access

the platform’s RTC. A variety of legacy interrupts might serve some purposes, but typ-ically might not abstract sufficient information to be particularly useful. If a user

wanted to talk to the RTC directly, the user would not typically know how to with the exception of using some of the standard IBM CMOS directives. Ultimately, how one

might gain access to this fundamental piece of information (“What time is it?”) could change over time. With that in mind, one needed the platform to provide a set of ab-

stractions so that the caller would not have to worry about the vagaries of varying programming some RTC to acquire time information or to depend on some poorly

documented and completely nonstandard set of legacy interrupts to abstract this same data.

 

**Get Time**

 

Even though this function is called “GetTime”, it is intended to return the current time as well as the date information along with the capabilities of the current underlying

Time Services \| **71**

 

time-based hardware. This service is not intended to provide highly accurate timings beyond certain described levels. During the Boot Services phase of platform initiali-

zation, there are other means by which to do accurate time stall measurements (for

example, see the Stall() boot services function in the UEFI specification).

Even though Figure 5.3 shows the smallest granularity of time measurement in nanoseconds, this is by no means intended as an indication of the accuracy of the

time measurement of which the function is capable. The only thing that is guaranteed by the call to this function is that it returns a time that was valid during the call to the

function. This guarantee is more understandable when one thinks about the pro-cessing time for the call to traverse various levels of code between the caller and the

service function actually talking to the hardware device and this data then being passed back to the caller. Since this is a call initiated during the runtime phase of

platform operations, the highly accurate timers that are needed for small granularity timing events would be provided by alternate (likely OS-based) solutions.

 

//\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*

//EFI_TIME

//\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*

// This represents the current time information

typedef struct {

UINT16 ***Year*****;** // 1998 -- 20XX

UINT8 ***Month*****;** // 1 -- 12

UINT8 ***Day*****;** // 1 -- 31

UINT8 ***Hour*****;** // 0 -- 23

UINT8 ***Minute*****;** // 0 -- 59

UINT8 ***Second*****;** // 0 -- 59

UINT8 ***Pad1*****;**

UINT32 ***Nanosecond*****;** // 0 -- 999,999,999

INT16 ***TimeZone*****;** // -1440 to 1440 or 2047

UINT8 ***Daylight*****;**

UINT8 ***Pad2*****;** } EFI_TIME;

 

Figure 5.3 Example Time Definition

 

**Set Time**

 

This function provides the ability to set the current time and date information on the

platform.

**72** \| Chapter 5 – UEFI Runtime

 

**Get Wakeup Time**

 

This function provides the abstraction for obtaining the alarm clock settings for the

platform. This is often used to determine if a platform has been set for being woken up, and if so, at what time it should be woken up.

 

**Set Wakeup Time**

 

Setting a system wakeup alarm causes the system to wake up or power on at the set time. When the alarm fires, the alarm signal is latched until acknowledged by calling SetWakeupTime() to disable the alarm. If the alarm fires before the system is put

into a sleeping or off state, since the alarm signal is latched the system will immedi-ately wake up.

 

**Virtual Memory Services**

 

This section contains function definitions for the virtual memory support that may be

optionally used by an operating system at runtime. If an operating system chooses to make UEFI runtime service calls in a virtual addressing mode instead of the flat phys-ical mode, then the operating system must use the services in this section to switch

the UEFI runtime services from flat physical addressing to virtual addressing. Table 5.4 lists the virtual memory services functions that UEFI provides.

 

**Table 5.4:** Virtual Memory Services

 

**Name Type** **Description**

 

SetVirtualAddressMap Runtime Used by an OS loader to convert from physical address-

ing to virtual addressing.

 

ConvertPointer Runtime Used by UEFI components to convert internal pointers

when switching to virtual addressing.

 

By using these functions, the platform provides a mechanism by which components that will exist during the runtime phase of operations can adjust their own data ref-

erences to the new virtual addresses that the runtime caller has supplied. This makes it possible for the underlying firmware component(s) to adjust from a physical ad-

dress mode to virtual address mode entity.

This conversion applies to all functions in the runtime services table as well as

the pointers in the UEFI System Table. However, this is not necessarily the case for the UEFI Configuration Table. In the UEFI Configuration Table, one is dealing with

Virtual Memory Services \| **73**

 

GUID/pointer pairs, and since the pointers are all physical to start with in the firm-ware, one might think that the pointers are converted during the transition to the

runtime phase of platform operations, right? In this particular case, you would be

wrong.

The GUID portion of the GUID/pointer pair defines the state of the pointer itself. In theory, one might have a particular GUID that during runtime has a virtual address

pointer paired with it, but the next GUID’ in the table might very well be a physical pointer. This is because the UEFI Configuration Table can often be used to advertise

certain pieces of information and the consumer of this information might have reason for interpreting the pointer as a physical pointer even though the OS has converted

all other pertinent data to virtual addresses. In addition, the UEFI Configuration Table often might be pointing to a runtime enabled function prototype. In most cases, the

pointers for this function would be converted, while other items that might be pointed at by the UEFI Configuration Table (Data Tables, for instance) might have no reason

to have any data be converted.

 

**Set Virtual Address Map**

 

By calling this service, the agent that is the owner of the system’s memory map (the

component that called ExitBootServices()) can change the runtime address-

ing mode of the underlying UEFI firmware from physical to virtual. The inputs of course are the new virtual memory map which shows an array of memory descriptors that have mapping information for all runtime memory ranges.

When this service is called, all runtime-enabled agents will in turn be called through a notification event triggered by the SetVirtualAddressMap() function.

 

**ConvertPointer**

 

The ConvertPointer function is used by an UEFI component during the Set-VirtualAddressMap() operation. When the platform has passed control to an

OS loader and it in turn calls SetVirtualAddressMap(), a function is called in

most runtime drivers that responds to the virtual address change event that is trig-gered. This function uses the ConvertPointer service to convert the current physical pointer to an appropriate virtual address pointer. All pointers that the component has

allocated should be updated using this mechanism.

**74** \| Chapter 5 – UEFI Runtime

 

**Variable Services**

 

Variables are defined as key/value pairs that consist of identifying information, at-tributes, and some quantity of data. Variables are intended for use as a means to store

data that is passed between the UEFI environment implemented in the platform and

UEFI OS loaders and other applications that run in the UEFI environment.

Although the implementation of variable storage is not specifically defined for a given platform, variables must be able to persist across reboots of the platform. This

implies that the UEFI implementation on a platform must arrange it so that variables passed in for storage are retained and available for use each time the system boots, at

least until they are explicitly deleted or overwritten. Provision of this type of nonvol-atile storage may be very limited on some platforms, so variables should be used spar-

ingly in cases where other means of communicating information cannot be used. Ta-ble 5.5 lists the variable services functions that UEFI provides.

 

**Table 5.5:** Variable Services

 

**Name Type** **Description**

 

GetVariable Runtime Returns the value of a variable.

 

GetNextVariableName Runtime Enumerates the current variable names.

 

SetVariable Runtime Sets the value of a variable.

 

**GetVariable**

 

This function returns the value of a given UEFI variable. Since a fully qualified UEFI variable name is composed of both a human-readable text value paired with a GUID,

a vendor can create and manage its own variables without the risk of name conflicts by using its own unique GUID value. For instance, one can easily have three variables

named “Setup” that are wholly unique assuming that each of these “Setup” variables has a different numeric GUID value.

One of the key items to note in the definition of an UEFI variable is that each one has some attributes associated with it. These attributes are treated as a bit field, which

implies that none, any, or all of the bits can be activated at any given time. In the case of UEFI variables, however, there are three defined attribute bits to be aware of:

■ Nonvolatile – a variable that has this attribute activated is defined to be persis-

tent across platform resets. It should also be noted that the explicit absence of

this bit being activated indicates that the variable is volatile, and is therefore a

Variable Services \| **75**

 

temporary variable that will be absent once the system resets or the variable is

deleted.

■ BootService – a variable that has this attribute activate provides read/write ac-

cess to it during the BootService phase of the platform evolution. This simply

means that once the platform enters the runtime phase, the data will no longer

be able to be set through the SetVariable service.

■ Runtime – a variable that has this attribute activated must also have the

BootService attribute activated. With this, the variable is accessible during all

phases of the platform evolution.

 

**GetNextVariableName**

 

Since the UEFI variable repository is very similar in concept to a file system, the ability

to parse the repository is provided by the GetNextVariableName service. This service enumerates the current variable names in the platform, and with each subsequent

call to the service the previous results can be passed into the interface, and on output the interface returns the next variable name data. Once the entire list of variables has

been returned, a subsequent call into the service providing the previous “last” varia-ble name will provide the equivalent of a “Not Found” error.

It should be noted that this service is affected by the phase of platform operations. Variables that do not have the runtime attribute activated are allocated typically from

some type of BootServices memory. Since this is the case, once Exit-BootServices() is performed to signify the transition into the runtime phase,

these variables will no longer show up in the search list that GetNextVariableName provides.

One other behavior that should be noted is that one might conceive that if a vari-able has the ability to be named the same human-readable name (such as “Setup”)

and the only thing that differs is the GUID, one could seed the search mechanism for this service by walking a common GUID-based list of variables. This is not the case.

The usage of this service is typically initiated with a call that starts with a pointer to a Null Unicode string as the human-readable name; the GUID is ignored. Instead, the

entire list of variables must be retrieved, and the caller may act as a filter if you choose to have it do so.

 

**SetVariable**

 

UEFI variables are often used to provide a means by which to save platform-based context information. For instance, when the platform initializes the I/O infrastructure

and has probed for all known console output devices, it will likely construct a

**76** \| Chapter 5 – UEFI Runtime

 

ConOutDev global variable. These global variables have a unique purpose in the plat-form since they have a specific architectural role to play with a specific purpose. Table

5.6 shows some of the defined global variables.

 

**Table 5.6:**Global Variables

 

**Variable Name** **Attribute Description**

 

LangCodes BS, RT The language codes that the firmware supports. This

value is deprecated.

 

Lang NV, BS, RT The language code that the system is configured for.

This value is deprecated.

 

Timeout NV, BS, RT The firmware boot manager’s timeout, in seconds, be-

fore initiating the default boot selection.

 

PlatformLangCodes BS, RT The language codes that the firmware supports.

 

PlatformLang NV, BS, RT The language code that the system is configured for.

 

ConIn NV, BS, RT The device path of the default input console.

 

ConOut NV, BS, RT The device path of the default output console.

 

ErrOut NV, BS, RT The device path of the default error output device.

 

ConInDev BS, RT The device path of all possible console input devices.

 

ConOutDev BS, RT The device path of all possible console output devices.

 

ErrOutDev BS, RT The device path of all possible error output devices.

 

The examples in Table 5.6 show some of the common global variables, their descrip-tions, and their attributes. Some of the noted differences are the presence or absence

of the NV (nonvolatile) attribute. This simply means that the values associated with these variables are not persistent across platform resets and their values are deter-

mined during the initialization phase of platform operations. Unlike variables that are persistent, robust implementations of UEFI enable the setting of volatile variables

in memory-backed store, and do not necessarily have the storage size sensitivities that the other variables have that are stored in a fixed hardware with often very lim-

ited storage capacity.

Software should only use a nonvolatile variable when absolutely necessary. It

should be noted that a variable has no concept of a zero-byte data payload. All varia-bles must contain at least 1 byte of data, since the service definition stipulates that

the means by which you delete a target variable is by calling the SetVariable() service with a zero byte data payload.

Miscellaneous Services \| **77**

 

There are certain rules that should definitely be noted when it comes to the use of the attributes:

■ Attributes are only applied to a variable when the variable is created. If a preex-

isting variable is rewritten with different attributes, the result is indeterminate

and may vary between implementations. The correct method of changing the at-

tributes of a variable is to delete the variable and recreate it with different attrib-

utes.

■ Setting a data variable with no access attributes or a zero size data payload causes

it to be deleted.

■ Runtime access to a data variable implies boot service access.

■ Once ExitBootServices() is performed, data variables that did not have the

runtime access attribute set are no longer visible. This simply enforces the para-

digm that once in runtime phase, variables without the runtime attribute are not

to be read from.

■ Once ExitBootServices() is performed, only variables that have the runtime and

the nonvolatile access attributes set can be set with a call to the SetVariable()

service. In addition, variables that have runtime access but that are not nonvol-

atile are now read-only data variables. The reason for this situation is that once

the platform firmware has handed off control to another agent (such as the OS),

it no longer controls the memory services and cannot further allocate services

that might be backed by memory. Since the SetVariable service typically uses

memory to spill content to store a volatile variable, this capability is no longer

available during the runtime phase of operations.

 

By providing a mechanism for shared data content such as an UEFI variable, the use of variables can be seen as a fairly flexible and highly available mechanism for firm-

ware components to communicate. The variables shown in Table 5.6 are some of the architectural variables that steer the behavior of a platform. In this case aspects of the

platform configuration can be seen in the data reflected by these variables. Another usage of the variable services can be to use the volatile (one must stress volatile, and

not nonvolatile) variable as means by which two disparate components can have a common repository that is independent of a nonvolatile backing store (such as a hard

disk), yet can act as a temporary repository of data such as registry content that is discovered by one agent and retrieved by another. This infrastructure provides for a

lot of flexibility in implementation.

 

**Miscellaneous Services**

 

This section contains the remaining function definitions for runtime services that

were not talked about in previous sections but are required to complete a compliant

**78** \| Chapter 5 – UEFI Runtime

 

implementation of an UEFI environment. The services that are in this section are as listed in Table 5.7.

 

**Table 5.7:** Miscellaneous Services

 

**Name Type** **Description**

 

GetNextHighMonotonicCount Runtime Returns the next high 32 bits of the platform’s

monotonic counter.

 

ResetSystem Runtime Resets the entire platform.

 

UpdateCapsule Runtime Pass capsules to the firmware. The firmware

may process the capsules immediately or re-

turn a value to be passed into Reset-System() that will cause the capsule to be processed by the firmware as part of the reset

process.

 

QueryCapsuleCapabilities Runtime Returns if the capsule can be supported via

UpdateCapsule()

 

**Reset System**

 

This service provides a caller the ability to reset the entire platform including all pro-cessors and devices, and reboots the system. This service provides the ability to stip-

ulate three types of rests:

■ Cold Reset – A call to the ResetSystem() service stipulating a cold reset will cause

a system-wide reset. This sets all circuitry within the system to its initial state.

This type of reset is asynchronous to system operation and operates without re-

gard to cycle boundaries. This is tantamount to a system power cycle. ■ Warm Reset – Calling the ResetSystem() service stipulating a warm reset will also

cause a system-wide initialization. The processors are set to their initiate state,

and pending cycles are not corrupted. This difference should be noted, since

memory is not typically reinitialized and the machine may be rebooting without

having cleared memory that previously existed. There are a lot of examples of

this usage model, and implementations vary on exactly what platforms choose

to do with this type of feature. If the system does not support this reset type, then

a Cold Reset must be performed.

■ Reset Shutdown – Calling the ResetSystem() service stipulating a Reset Shutdown

will cause the system to enter a power state equivalent to the ACPI G2/S5 or G3

states. If the system does not support this reset type, then when the system is re-

booted, it should exhibit the same attributes as having booted from a Cold Reset.

Miscellaneous Services \| **79**

 

**Get Next High Monotonic Count**

 

The platform provides a service to get the platform monotonic counter. The platform’s

monotonic counter is comprised of two 32-bit quantities: the high 32 bits and the low 32 bits. During boot service time the low 32-bit value is volatile: it is reset to zero on every system reset and is increased by 1 on every call to GetNextMonotonicCount().

The high 32-bit value is nonvolatile and will be increased by 1 whenever the system resets or whenever the low 32-bit count overflows.

 

Since the GetNextMonotonicCount() service is available only at boot services time, and if the operating system wishes to extend the platform monotonic counter to runtime, it may do so by utilizing the GetNextHighMonotonicCount() runtime service.

To do this, before calling ExitBootServices() the operating system would call Get-NextMonotonicCount() to obtain the current platform monotonic count. The operat-

ing system would then provide an interface that returns the next count by: ■ Adding 1 to the last count.

■ Before the lower 32 bits of the count overflows, call GetNextHighMonotonic-

Count(). This will increase the high 32 bits of the platform’s nonvolatile portion

of the monotonic count by 1.

 

This function may only be called at runtime.

 

**UpdateCapsule**

 

This runtime function allows a caller to pass information to the firmware. UpdateCap-

sule is commonly used to update the firmware FLASH or for an operating system to have information persist across a system reset. Other usage models such as updating plat-

form configuration are also possible depending on the underlying platform support.

A capsule is simply a contiguous set of data that starts with an EFI_CAP-

SULE_HEADER. The CapsuleGuid field in the header defines the format of the capsule.

The capsule contents are designed to be communicated from an OS-present envi-

ronment to the system firmware. To allow capsules to persist across system reset, a level of indirection is required for the description of a capsule, since the OS primarily

uses virtual memory and the firmware at boot time uses physical memory. This level of abstraction is accomplished via the EFI_CAPSULE_BLOCK_DESCRIPTOR. The

EFI_CAPSULE_BLOCK_DESCRIPTOR allows the OS to allocate contiguous virtual ad-dress space and describe this address space to the firmware as a discontinuous set of

physical address ranges. The firmware is passed both physical and virtual addresses and pointers to describe the capsule so the firmware can process the capsule imme-

diately or defer processing of the capsule until after a system reset.

**80** \| Chapter 5 – UEFI Runtime

 

Depending on the intended consumption, the firmware may process the capsule immediately. If the payload should persist across a system reset, the reset value re-

turned from QueryCapsuleCapabilities must be passed into ResetSystem() and will

cause the capsule to be processed by the firmware as part of the reset process.

 

**QueryCapsuleCapabilities**

 

This runtime function allows a caller to check whether or not a particular capsule can

be supported by the platform prior to sending it to the UpdateCapsule routine. Many of these checks are based on the type of capsule being passed and their associated flag values contained within the capsule header.

 

**Summary**

 

This chapter has introduced some of the basic UEFI runtime capabilities. These are unique in that they are the few aspects of the firmware that will reside in the system

even when the target software (such as the operating system) is running. These are

the functions that can be leveraged any time during the platform’s evolution from pre-OS through the runtime phases.