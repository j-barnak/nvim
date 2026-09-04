## **Chapter 2 – Basic UEFI Architecture** 

 

I believe in standards. Everyone should have one.

—George Morrow

 

The Unified Extensible Firmware Interface (UEFI) describes a programmatic interface

to the platform. The platform includes the motherboard, chipset, central processing unit (CPU), and other components. UEFI allows for pre-operating system (pre-OS)

agents. Pre-OS agents are OS loaders, diagnostics, and other applications that the system needs for applications to execute and interoperate, including UEFI drivers and

applications. UEFI represents a pure interface specification against which the drivers and applications interact, and this chapter highlights some of the architectural as-

pects of the interface. These architectural aspects include a set of objects and inter-faces described by the UEFI Specification.

 

The cornerstones for understanding UEFI applications and drivers are several UEFI

concepts that are defined in the *UEFI 2.6 Specification*. Assuming you are new to UEFI, the following introduction explains a few of the key UEFI concepts in a helpful frame-

work to keep in mind as you study the specification:

■ Objects managed by UEFI-based firmware - used to manage system state, includ-

ing I/O devices, memory, and events

■ The UEFI System Table - the primary data structure with data information tables

and function calls to interface with the systems

■ Handle database and protocols - the means by which callable interfaces are reg-

istered

■ UEFI images - the executable content format by which code is deployed

■ Events - the means by which software can be signaled in response to some other

activity

■ Device paths - a data structure that describes the hardware location of an entity,

such as the bus, spindle, partition, and file name of an UEFI image on a formatted

disk.

 

**Objects Managed by UEFI-based Firmware**

 

Several different types of objects can be managed through the services provided by

UEFI. Some UEFI drivers may need to access environment variables, but most do not. Rarely do UEFI drivers require the use of a monotonic counter, watchdog timer, or

real-time clock. The UEFI System Table is the most important data structure, because it provides access to all UEFI-provided the services and to all the additional data

structures that describe the configuration of the platform.

 

DOI 10.1515/9781501505690-004

**16** \| Chapter 2 – Basic UEFI Architecture

 

**UEFI System Table**

 

The UEFI System Table is the most important data structure in UEFI. A pointer to the UEFI System Table is passed into each driver and application as part of its entry-point

handoff. From this one data structure, an UEFI executable image can gain access to

system configuration information and a rich collection of UEFI services that includes the following:

■ UEFI Boot Services

■ UEFI Runtime Services

■ Protocol services

 

The UEFI Boot Services and UEFI Runtime Services are accessed through the UEFI Boot

Services Table and the UEFI Runtime Services Table, respectively. Both of these tables are data fields in the UEFI System Table. The number and type of services that each

table makes available is fixed for each revision of the UEFI specification. The UEFI Boot Services and UEFI Runtime Services are defined in the *UEFI 2.6 Specification*.

Protocol services are groups of related functions and data fields that are named by a Globally Unique Identifier (GUID), a 16-byte, statistically-unique entity defined

in Appendix A of the *UEFI 2.6 Specification*. Typically, protocol services are used to provide software abstractions for devices such as consoles, disks, and networks, but

they can be used to extend the number of generic services that are available in the platform. Protocols are the mechanism for extending the functionality of UEFI firm-

ware over time. The *UEFI 2.6 Specification* defines over 30 different protocols, and various implementations of UEFI firmware and UEFI drivers may produce additional

protocols to extend the functionality of a platform.

 

**Handle Database**

 

The *handle database* is composed of objects called handles and protocols. *Handles*

are a collection of one or more protocols, and *protocols* are data structures that are named by a GUID. The data structure for a protocol may be empty, may contain data

fields, may contain services, or may contain both services and data fields. During UEFI initialization, the system firmware, UEFI drivers, and UEFI applications create

handles and attach one or more protocols to the handles. Information in the handle database is global and can be accessed by any executable UEFI image.

Handle Database \| **17**

 

The handle database is the central repository for the objects that are maintained by UEFI-based firmware. The handle database is a list of UEFI handles, and each UEFI

handle is identified by a unique handle number that is maintained by the system firm-

ware. A handle number provides a database “key” to an entry in the handle database. Each entry in the handle database is a collection of one or more protocols. The types of protocols, named by a GUID, that are attached to an UEFI handle determine the

handle type. An UEFI handle may represent components such as the following: ■ Executable images such as UEFI drivers and UEFI applications

■ Devices such as network controllers and hard drive partitions ■ UEFI services such as UEFI Decompression and the EBC Virtual Machine

 

Figure 2.1 below shows a portion of the handle database. In addition to the handles

and protocols, a list of objects is associated with each protocol. This list is used to track which agents are consuming which protocols. This information is critical to the

operation of UEFI drivers, because this information is what allows UEFI drivers to be safely loaded, started, stopped, and unloaded without any resource conflicts.

 

**First Handle**

 

**Handle** **. . .**

**GUID** **GUID**

**Protocol** **Agent Handle** **Protocol** **Agent Handle** **Interface** **Controller Handle** **Interface** **Controller Handle**

**Attributes** **Attributes**

 

**Agent Handle** **Agent Handle**

**Controller Handle** **Controller Handle**

**Attributes** **Attributes**

 

**Agent Handle**

**Controller Handle**

**Attributes**

 

**Handle** **. . .**

**GUID** **GUID** **GUID**

**Protocol** **Agent Handle** **Protocol** **Protocol** **Interface** **Interface** **Interface** **Controller Handle**

**Attributes**

 

**. . .**

 

**Figure 2.1:** Handle Database

**18** \| Chapter 2 – Basic UEFI Architecture

 

Figure 2.2 shows the different types of handles that can be present in the handle da-tabase and the relationships between the various handle types. All handles reside in

the same handle database and the types of protocols that are associated with each

handle differentiate the handle type. Like file system handles in an operating system context, the handles are unique for the session, but the values can be arbitrary. Also, like the handle returned from an fopen function in a C library, the value does not

necessarily serve a useful purpose in a different process or during a subsequent re-start in the same process. The handle is just a transitory value to manage state.

 

**Handles**

 

**Agent**

**Handles**

 

**Handles** **Image** **Driver** **Driver Image** **Handles** **Handles**

 

**Service**

**Handles**

**Controller Handles**

**Physical** **Virtual**

**Controller** **Controller**

**Handles** **Handles**

 

**Figure 2.2:** Handle Types Handle

 

**Protocols**

 

The extensible nature of UEFI is built, to a large degree, around protocols. UEFI driv-

ers are sometimes confused with UEFI protocols. Although they are closely related, they are distinctly different. A *UEFI driver* is an executable UEFI image that installs a

variety of protocols of various handles to accomplish its job.

A *UEFI protocol* is a block of function pointers and data structures or APIs that

have been defined by a specification. At a minimum, the specification must define a GUID. This number is the protocol’s real name; boot services like LocateProtocol uses

this number to find his protocol in the handle database. The protocol often includes a set of procedures and/or data structures, called the *protocol interface structure*. The

following code sequence is an example of a protocol definition. Notice how it defines two function definitions and one data field.

Protocols \| **19**

 

**Sample GUID**

\#define EFI_COMPONENT_NAME2_PROTOCOL_GUID \\ {0x6a7a5cff, 0xe8d9, 0x4f70, 0xba, 0xda, 0x75, 0xab, 0x30, 0x25, 0xce, 0x14}

 

**Protocol Interface Structure**

typedef struct \_EFI_COMPONENT_NAME2_PROTOCOL { EFI_COMPONENT_NAME_GET_DRIVER_NAME

***GetDriverName;***

EFI_COMPONENT_NAME_GET_CONTROLLER_NAME

***GetControllerName;***

CHAR8

***\*SupportedLanguages;***

} EFI_COMPONENT_NAME2_PROTOCOL;

 

Figure 2.3 shows a single handle and protocol from the handle database that is pro-duced by an UEFI driver. The protocol is composed of a GUID and a protocol interface

structure. Many times, the UEFI driver that produces a protocol interface maintains additional private data fields. The protocol interface structure itself simply contains

pointers to the protocol function. The protocol functions are actually contained within the UEFI driver. An UEFI driver might produce one protocol or many protocols

depending on the driver’s complexity.

 

**First Handle**

 

**Handle** **. . .**

**GUID**

**Protocol Interface** **EFI Driver** **Function Pointer 1**

**GUID 1**

**Function Pointer 2**

**. . .** **Function 1**

**Private Data**

**Access**

 

**Function 2** **Device or** **Services** **Produced by** **other EFI**

**Drivers**

**. . .**

 

**GUID 2**

**. . .**

 

**. . .**

 

**. . .**

 

**Figure 2.3:** Construction of a Protocol **20** \| Chapter 2 – Basic UEFI Architecture

 

Not all protocols are defined in the *UEFI 2.6 Specification*. The EFI Developer Kit II (EDKII) includes many protocols that are not part of the *UEFI 2.6 Specification*. This

project can be found at http://www.tianocore.org. These protocols provide the wider

range of functionality that might be needed in any particular implementation, but they are not defined in the *UEFI 2.6 Specification* because they do not present an ex-ternal interface that is required to support booting an OS or writing an UEFI driver.

The creation of new protocols is how UEFI-based systems can be extended over time as new devices, buses, and technologies are introduced. For example, some protocols

that are in the *EDK II* but not in the *UEFI 2.6 Specification* are*:* ■ Varstore – interface to abstract storage of UEFI persistent binary objects

■ ConIn – service to provide a character console input ■ ConOut – service to provide a character console output

■ StdErr – service to provide a character console output for error messaging ■ PrimaryConIn – the console input with primary view

■ VgaMiniPort – a service that provides Video Graphics Array output ■ UsbAtapi – a service to abstract block access on USB bus

 

The UEFI Application Toolkit also contains a number of UEFI protocols that may be

found on some platforms, such as:

■ PPP Daemon – Point-to-Point Protocol driver

■ Ramdisk – file system instance on a Random Access Memory buffer ■ TCP/IP – Transmission Control Protocol / Internet Protocol

■ The Trusted Computing Group interface and platform specification, such as:

– EFI TCG Protocol – interaction with a Trusted Platform Module (TPM).

 

The OS loader and drivers should not depend on these types of protocols because they

are not guaranteed to be present in every UEFI-compliant system. OS loaders and drivers should depend only on protocols that are defined in the *UEFI 2.6 Specification*

and protocols that are required by platform design guides such as *Design Implemen-tation Guide for 64-bit Server*.

The extensible nature of UEFI allows the developers of each platform to design and add special protocols. Using these protocols, they can expand the capabilities of

UEFI and provide access to proprietary devices and interfaces in congruity with the rest of the UEFI architecture.

Because a protocol is “named” by a GUID, no other protocols should have that same identification number. Care must be taken when creating a new protocol to de-

fine a new GUID for it. UEFI fundamentally assumes that a specific GUID exposes a specific protocol interface. Cutting and pasting an existing GUID or hand-modifying

an existing GUID creates the opportunity for a duplicate GUID to be introduced. A system containing a duplicate GUID inadvertently could find the new protocol and

think that it is another protocol, crashing the system as a result. For these types of bugs, finding the root cause is also very difficult. The GUID allows for naming APIs

Protocols \| **21**

 

without having to worry about namespace collision. In systems such as PC/AT BIOS, services were added as an enumeration. For example, the venerable Int15h inter-

face would pass the service type in AX. Since no central repository or specification

managed the evolution of Int15h services, several vendors defined similar service numbers, thus making interoperability with operating systems and pre-OS applica-tions difficult. Through the judicious use of GUIDs to name APIs and an association

to develop the specification, UEFI balances the need for API evolution with interop-erability.

 

**Working with Protocols**

 

Any UEFI code can operate with protocols during boot time. However, after Exit-BootServices() is called, the handle database is no longer available. Several

UEFI boot time services work with UEFI protocols.

 

**Multiple Protocol Instances**

 

A handle may have many protocols attached to it. However, it may have only one

protocol of each type. In other words, a handle may not have more than one instance

of the exact same protocol. Otherwise, it would make requests for a particular proto-col on a handle nondeterministic.

However, drivers may create multiple instances of a particular protocol and at-

tach each instance to a different handle. The PCI I/O Protocol fits this scenario, where the PCI bus driver installs a PCI I/O Protocol instance for each PCI device. Each in-

stance of the PCI I/O Protocol is configured with data values that are unique to that PCI device, including the location and size of the UEFI Option ROM (OpROM) image.

Also, each driver can install customized versions of the same protocol as long as they do not use the same handle. For example, each UEFI driver installs the Compo-

nent Name Protocol on its driver image handle, yet when the EFI_COMPO-NENT_NAME2_PROTOCOL.GetDriverName() function is called, each handle

returns the unique name of the driver that owns that image handle. The EFI_COM-

PONENT_NAME2_PROTOCOL.GetDriverName() function on the USB bus driver handle returns “USB bus driver” for the English language, but on the PXE driver handle it returns “PXE base code driver.”

 

**Tag GUID**

 

A protocol may be nothing more than a GUID. In such cases, the GUID is called a *tag GUID*. Such protocols can serve useful purposes such as marking a device handle as **22** \| Chapter 2 – Basic UEFI Architecture

 

special in some way or allowing other UEFI images to easily find the device handle by querying the system for the device handles with that protocol GUID attached. The *ED-*

*KII* uses the HOT_PLUG_DEVICE_GUID in this way to mark device handles that rep-

resent devices from a hot-plug bus such as USB.

 

**UEFI Images**

 

All UEFI images contain a PE/COFF header that defines the format of the executable code as required by the *Microsoft Portable Executable and Common Object File Format*

*Specification* (Microsoft 2008). The target for this code can be an IA-32 processor, an Itanium® processor, x64, ARM, or a processor agnostic, generic EFI Byte Code (EBC).

The header defines the processor type and the image type. Presently there are three processor types and the following three image types defined:

■ UEFI applications – images that have their memory and state reclaimed upon

exit.

■ UEFI Boot Service drivers – images that have their memory and state preserved

throughout the pre-operating system flow. Their memory is reclaimed upon in-

vocation of ExitBootServices() by the OS loader.

■ UEFI Runtime drivers – images whose memory and state persist throughout the

evolution of the machine. These images coexist with and can be invoked by an

UEFI-aware operating system.

 

The value of the UEFI Image format is that various parties can create binary executables

that interoperate. For example, the operating system loader for Microsoft Windows† and

Linux for an UEFI-aware OS build is simply an UEFI application. In addition, third par-ties can create UEFI drivers to abstract their particular hardware, such as a networking interface host bus adapter (HBA) or other devices. UEFI images are loaded and relocated

into memory with the Boot Service gBS-\>LoadImage(). Several supported storage locations for UEFI images are available, including the following:

■ Expansion ROMs on a PCI card

■ System ROM or system flash ■ A media device such as a hard disk, floppy, CD-ROM, or DVD ■ A LAN boot server

 

In general, UEFI images are not compiled and linked at a specific address. Instead,

the UEFI image contains relocation fix-ups so the UEFI image can be placed anywhere

in system memory. The Boot Service gBS-\>LoadImage() does the following: ■ Allocates memory for the image being loaded ■ Automatically applies the relocation fix-ups to the image

■ Creates a new image handle in the handle database, which installs an instance of

the EFI_LOADED_IMAGE_PROTOCOL

UEFI Images \| **23**

 

This instance of the EFI_LOADED_IMAGE_PROTOCOL contains information about the UEFI image that was loaded. Because this information is published in the handle

database, it is available to all UEFI components.

After an UEFI image is loaded with gBS-\>LoadImage(), it can be started with a call to gBS-\>StartImage(). The header for an UEFI image contains the address of the entry point that is called by gBS-\>StartImage(). The entry point always

receives the following two parameters:

■ The image handle of the UEFI image being started

■ A pointer to the UEFI System Table

 

These two items allow the UEFI image to do the following: ■ Access all of the UEFI services that are available in the platform.

■ Retrieve information about where the UEFI image was loaded from and where in

memory the image was placed.

 

The operations that the UEFI image performs in its entry point vary depending on the

type of UEFI image. Figure 2.4 shows the various UEFI image types and the relation-ships between the different levels of images.

 

**EFI Images**

 

**Drivers**

**Service Drivers**

**EFI Driver Model Drivers**

**Initializing**

**Drivers**

 

**Root Bridge** **Bus** **Hybrid** **Device** **Drivers** **Drivers** **Drivers** **Drivers**

**EFI 1.02**

**Drivers**

 

**Applications**

**OS Loaders**

 

**Figure 2.4:** Image Types and Their Relationship to One Another

**24** \| Chapter 2 – Basic UEFI Architecture

 

**Table 2.1:** Description of Image Types

 

**Type of Image** **Description**

 

Application A UEFI image of type EFI_IMAGE_SUBSYSTEM_EFI_APPLICA-

TION. This image is executed and automatically unloaded when the image exits or returns from its entry point.

 

OS loader A special type of application that normally does not return or exit. Instead, it

calls the UEFI Boot Service gBS-\>ExitBootServices() to transfer control of the platform from the firmware to an operating system.

 

Driver A UEFI image of type EFI_IMAGE_SUBSYSTEM_BOOT_SER-

VICE_DRIVER or EFI_IMAGE_SUBSYS-TEM_RUNTIME_DRIVER. If this image returns EFI_SUCCESS, then the image is not unloaded. If the image returns an error code other than EFI_SUCCESS, then the image is automatically unloaded from system memory. The ability to stay resident in system memory is what differentiates a driver from an application. Because drivers can stay resident in memory, they can provide services to other drivers, applications, or an operating system. Only the services produced by runtime drivers are allowed to persist past gBS-\>ExitBootServices().

 

Service driver A driver that produces one or more protocols on one or more new service han-

dles and returns EFI_SUCESS from its entry point.

 

Initializing driver A driver that does not create any handles and does not add any protocols to

the handle database. Instead, this type of driver performs some initialization operations and returns an error code so the driver is unloaded from system memory.

 

Root bridge driver A driver that creates one or more physical controller handles that contain a

Device Path Protocol and a protocol that is a software abstraction for the I/O services provided by a root bus produced by a core chipset. The most common root bridge driver is one that creates handles for the PCI root bridges in the platform that support the Device Path Protocol and the PCI Root Bridge I/O Protocol.

 

EFI 1.02 driver A driver that follows the *EFI 1.02 Specification*. This type of driver does not use

the UEFI Driver Model. These types of drivers are not discussed in detail in this document. Instead, this document presents recommendations on converting EFI 1.02 drivers to drivers that follow the UEFI Driver Model.

 

UEFI Driver Model A driver that follows the UEFI Driver Model that is described in detail in the

driver *UEFI 2.6 Specification*. This type of driver is fundamentally different from ser-

vice drivers, initializing drivers, root bridge drivers, and EFI 1.02 drivers be-cause a driver that follows the UEFI Driver Model is not allowed to touch hard-ware or produce device-related services in the driver entry point. Instead, the driver entry point of a driver that follows the UEFI Driver Model is allowed only

UEFI Images \| **25**

 

**Type of Image** **Description**

 

to register a set of services that allow the driver to be started and stopped at a later point in the system initialization process.

 

Device driver A driver that follows the UEFI Driver Model. This type of driver produces one or

more driver handles or driver image handles by installing one or more in-stances of the Driver Binding Protocol into the handle database. This type of driver does not create any child handles when the Start() service of the Driver Binding Protocol is called. Instead, it only adds additional I/O protocols to existing controller handles.

 

Bus driver A driver that follows the UEFI Driver Model. This type of driver produces one or

more driver handles or driver image handles by installing one or more in-stances of the Driver Binding Protocol in the handle database. This type of driver creates new child handles when the Start() service of the Driver Binding Protocol is called. It also adds I/O protocols to these newly created child handles.

 

Hybrid driver A driver that follows the UEFI Driver Model and shares characteristics with

both device drivers and bus drivers. This distinction means that the Start() service of the Driver Binding Protocol will add I/O protocols to ex-isting handles and it will create child handles.

 

**Applications**

 

A UEFI application starts execution at its entry point, then continues execution until

it reaches a return from its entry point or it calls the Exit() boot service function. When done, the image is unloaded from memory. Some examples of common UEFI

applications include the UEFI shell, UEFI shell commands, flash utilities, and diag-nostic utilities. It is perfectly acceptable to invoke UEFI applications from inside other

UEFI applications.

 

**OS Loader**

 

A special type of UEFI application, called an *OS boot loader*, calls the Exit-

BootServices() function when the OS loader has set up enough of the OS infra-structure to be ready to assume ownership of the system resources. At Exit-

BootServices() , the UEFI core frees all of its boot time services and drivers, leaving only the run-time services and drivers.

**26** \| Chapter 2 – Basic UEFI Architecture

 

**Drivers**

 

UEFI drivers differ from UEFI applications in that the driver stays resident in memory

unless an error is returned from the driver’s entry point. The UEFI core firmware, the boot manager, or other UEFI applications may load drivers.

 

**EFI 1.02 Drivers**

Several types of UEFI drivers exist, having evolved with subsequent levels of the spec-

ification. In EFI 1.02, drivers were constructed without a defined driver model. The *UEFI 2.6 Specification* provides a driver model that replaces the way drivers were built

in EFI 1.02 but that still maintains backward compatibility with EFI 1.02 drivers. EFI 1.02 immediately started the driver inside the entry point. Following this method

meant that the driver searched immediately for supported devices, installed the nec-essary I/O protocols, and started the timers that were needed to poll the devices. How-

ever, this method did not give the system control over the driver loading and connec-tion policies, so the UEFI Driver Model was introduced in Section 10.1 of the *UEFI 2.6*

*Specification* to resolve these issues.

The Floating-Point Software Assist (FPSWA) driver is a common example of an

EFI 1.02 driver; other EFI 1.02 drivers can be found in the EFI Application Toolkit 1.02.12.38. For compatibility, EFI 1.02 drivers can be converted to UEFI 2.6 drivers that

follow the UEFI Driver Model.

 

**Boot Service and Runtime Drivers**

Boot-time drivers are loaded into area of memory that are marked as EfiBootServicesCode, and the drivers allocate their data structures from

memory marked as EfiBootServicesData. These memory types are converted

to available memory after gBS-\>ExitBootServices() is called.

Runtime drivers are loaded in memory marked as EfiRuntimeServices-Code, and they allocate their data structures from memory marked as Efi-

RuntimeServicesData. These types of memory are preserved after gBS-\>Ex-itBootServices() is called, thereby enabling the runtime driver to provide

services to an operating system while the operating system is running. Runtime driv-

ers must publish an alternative calling mechanism, because the UEFI handle data-base does not persist into OS runtime. The most common examples of UEFI runtime drivers are the Floating-Point Software Assist driver (FPSWA.efi) and the network

Universal Network Driver Interface (UNDI) driver. Other than these examples, runtime drivers are not very common. In addition, the implementation and validation

of runtime drivers is much more difficult than boot service drivers because UEFI sup-ports the translation of runtime services and runtime drivers from a physical address-

ing mode to a virtual addressing mode. With this translation, the operating system can make virtual calls to the runtime code. The OS typically runs in virtual mode, so

Events and Task Priority Levels \| **27**

 

it must transition into physical mode to make the call. Transitions into physical mode for modern, multiprocessor operating systems are expensive because they entail

flushing translation look-up blocks (TLB), coordinating all CPUs, and other tasks. As

such, UEFI runtime offers an efficient invocation mechanism because no transition is required.

 

**Events and Task Priority Levels**

 

*Events* are another type of object that is managed through UEFI services. An event can

be created and destroyed, and an event can be either in the waiting state or the sig-naled state. A UEFI image can do any of the following:

■ Create an event.

■ Destroy an event.

■ Check to see if an event is in the signaled state. ■ Wait for an event to be in the signaled state.

■ Request that an event be moved from the waiting state to the signaled state.

 

Because UEFI does not support interrupts, it can present a challenge to driver writers who are accustomed to an interrupt-driven driver model. Instead, UEFI supports polled

drivers. The most common use of events by an UEFI driver is the use of timer events that allow drivers to periodically poll a device. Figure 2.5 shows the different types of events

that are supported in UEFI and the relationships between those events.

 

**Events**

 

**Signal**

**Events**

 

**Address Map** **Set Virtual** **Exit Boot** **Timer** **Events** **Services** **Events** **Periodic** **One-Shot** **Timer** **Timer** **Events** **Events** **Events**

 

**Wait**

**Events**

 

**Figure 2.5:** Event Types and Relationships **28** \| Chapter 2 – Basic UEFI Architecture

 

**Table 2.2:** Description of Event Types

 

**Type of Events** **Description**

 

Wait event An event whose notification function is executed whenever the event is

checked or waited upon.

 

Signal event An event whose notification function is scheduled for execution whenever

the event goes from the waiting state to the signaled state.

 

Exit Boot Services A special type of signal event that is moved from the waiting state to the

event signaled state when the UEFI Boot Service ExitBootServices()

is called. This call is the point in time when ownership of the platform is transferred from the firmware to an operating system. The event’s notifica-tion function is scheduled for execution when Exit-BootServices() is called.

 

Set Virtual Address A special type of signal event that is moved from the waiting state to the

Map event signaled state when the UEFI Runtime Service SetVirtualAd-

dressMap() is called. This call is the point in time when the operating system is making a request for the runtime components of UEFI to be con-verted from a physical addressing mode to a virtual addressing mode. The operating system provides the map of virtual addresses to use. The event’s notification function is scheduled for execution when SetVirtu-alAddressMap() is called.

 

Timer event A type of signal event that is moved from the waiting state to the signaled

state when at least a specified amount of time has elapsed. Both periodic and one-shot timers are supported. The event’s notification function is scheduled for execution when a specific amount of time has elapsed.

 

Periodic timer event A type of timer event that is moved from the waiting state to the signaled

state at a specified frequency. The event’s notification function is sched-uled for execution when a specific amount of time has elapsed.

 

One-shot timer event A type of timer event that is moved from the waiting state to the signaled

state after the specified timer period has elapsed. The event’s notification function is scheduled for execution when a specific amount of time has elapsed.

 

The following three elements are associated with every event:

■ The Task Priority Level (TPL) of the event ■ A notification function

■ A notification context

 

The notification function for a wait event is executed when the state of the event is checked or when the event is being waited upon. The notification function of a signal

event is executed whenever the event transitions from the waiting state to the signaled

Events and Task Priority Levels \| **29**

 

state. The notification context is passed into the notification function each time the no-tification function is executed. The TPL is the priority at which the notification function

is executed. Table 2.3**:** lists the four TPL levels that are defined today. Additional TPLs

could be added later. An example of a compatible addition to the TPL list could include a series of “Interrupt TPLs” between TPL_NOTIFY and TPL_HIGH_LEVEL in order to provide interrupt-driven I/O support within UEFI.

 

**Table 2.3:** Task Priority Levels Defined in UEFI

 

**Task Priority Level** **Description**

 

TPL_APPLICATION The priority level at which UEFI images are executed.

 

TPL_CALLBACK The priority level for most notification functions.

 

TPL_NOTIFY The priority level at which most I/O operations are per-

formed.

 

TPL_HIGH_LEVEL The priority level for the one timer interrupt supported in

UEFI.

 

TPLs serve the following two purposes:

■ To define the priority in which notification functions are executed

■ To create locks

 

For priority definition, you use this mechanism only when more than one event is in the signaled state at the same time. In these cases, the application executes the noti-

fication function that has been registered with the higher priority first. Also, notifica-tion functions at higher priorities can interrupt the execution of notification functions

executing at a lower priority.

For creating locks, code running in normal context and code in an interrupt context

can access the same data structure because UEFI does support a single-timer inter-rupt. This access can cause problems and unexpected results if the updates to a

shared data structure are not atomic. An UEFI application or UEFI driver that wants to guarantee exclusive access to a shared data structure can temporarily raise the task

priority level to prevent simultaneous access from both normal context and interrupt context. The application can create a lock by temporarily raising the task priority level

to TPL_HIGH_LEVEL. This level blocks even the one-timer interrupt, but you must take care to minimize the amount of time that the system is at TPL_HIGH_LEVEL.

Since all timer-based events are blocked during this time, any driver that requires pe-riodic access to a device is prevented from accessing its device. A TPL is similar to the

IRQL in Microsoft Windows and the SPL in various Unix implementations. A TPL de-scribes a prioritization scheme for access control to resources.

**30** \| Chapter 2 – Basic UEFI Architecture

 

**Summary**

 

This chapter has introduced some of the basic UEFI concepts and object types. These items have included events, protocols, task priority levels, image types, handles,

GUIDs, and service tables. Many of these UEFI concepts, including images and proto-

cols, are used extensively by other firmware technology, including the UEFI Platform Initialization (PI) building blocks, such as the DXE environment. These concepts will be revisited in different guises in subsequent chapters.