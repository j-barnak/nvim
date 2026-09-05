## **Chapter 13 – Pre-EFI Initialization (PEI)** 

 

Small is Beautiful

—E.F. Schumacher

 

The UEFI Platform Initialization (PI) pre-EFI initialization (PEI) phase of execution

has two primary roles in a platform’s life: determine the source of the restart and pro-vide a minimum amount of permanent memory for the ensuing DXE phase. Words

such as small and minimal are often used to describe PEI code because of hardware resource constraints that limit the programming environment. Specifically, the Pre-

EFI Initialization (PEI) phase provides a standardized method of loading and invok-ing specific initial configuration routines for the processor, chipset, and system

board. The PEI phase occurs after the Security (SEC) phase. The primary purpose of code operating in this phase is to initialize enough of the system to allow instantiation

of the Driver Execution Environment (DXE) phase. At a minimum, the PEI phase is responsible for determining the system boot path and initializing and describing a

minimum amount of system RAM and firmware volume(s) that contain the DXE Foun-dation and DXE Architectural Protocols. As an application of Occam’s razor to the

system design, the minimum amount of activity should be orchestrated and located in this phase of execution; no more, no less.

 

**Scope**

 

The PEI phase is responsible for initializing enough of the system to provide a stable base for subsequent phases. It is also responsible for detecting and recovering from

corruption of the firmware storage space and providing the restart reason (boot-mode).

Today’s PC generally starts execution in a very primitive state, from the perspec-tive of the boot firmware, such as BIOS or the UEFI PI. Processors might need updates

to their internal microcode; the chipset (the chips that provide the interface between processors and the other major components of the system) require considerable ini-

tialization; and RAM requires sizing, location, and other initialization. The PEI phase is responsible for initializing these basic subsystems. The PEI phase is intended to

provide a simple infrastructure by which a limited set of tasks can easily be accom-plished to transition to the more advanced DXE phase. The PEI phase is intended to

be responsible for only a very small subset of tasks that are required to boot the plat-form; in other words, it should perform only the minimal tasks that are required to

start DXE. As improvements in the hardware occur, some of these tasks may migrate out of the PEI phase of execution.

 

DOI 10.1515/9781501505690-015

**210** \| Chapter 13 – Pre-EFI Initialization (PEI)

 

**Rationale**

 

The design for PEI is essentially a miniature version of DXE that addresses many of the same issues. The PEI phase consists of several parts:

■ A PEI Foundation

■ One or more Pre-EFI Initialization Modules (PEIMs)

 

The goal is for the PEI Foundation to remain relatively constant for a particular pro-

cessor architecture and to support add-in modules from various vendors for particu-lar processors, chipsets, platforms, and other components. These modules usually

cannot be coded without some interaction between one another and, even if they could, it would be inefficient to do so.

 

PEI is unlike DXE in that DXE assumes that reasonable amounts of permanent system

RAM are present and available for use. PEI instead assumes that only a limited amount of temporary RAM exists and that it could be reconfigured for other uses dur-

ing the PEI phase after permanent system RAM has been initialized. As such, PEI does not have the rich feature set that DXE does. The following are the most obvious exam-

ples of this difference:

■ DXE has a rich database of loaded images and protocols bound to those images.

■ PEI lacks a rich module hierarchy such as the DXE driver model.

 

**Overview**

 

The PEI phase consists of some Foundation code and specialized drivers known as

PEIMs that customize the PEI phase operations to the platform. It is the responsibility of the Foundation code to dispatch the plug-ins in a sequenced order and provide

basic services. The PEIMs are analogous to DXE drivers and generally correspond to the components being initialized. It is expected that common practice will be that the

vendor of the component will provide the PEIM, possibly in source form so the cus-tomer can quickly debug integration problems.

The implementation of the PEI phase is more dependent on the processor archi-tecture than any other UEFI PI phase. In particular, the more resources that the pro-

cessor provides at its initial or near initial state, the richer the PEI environment will be. As such, several parts of the following discussion note requirements for the archi-

tecture but are otherwise left less completely defined because they are specific to the processor architecture.

PEI can be viewed from both temporal and spatial perspectives. Figure 13.1 pro-vides the overall UEFI PI boot phase. The spatial view of PEI can be found in Figure

13.2. This picture describes the layering of the UEFI PI components. This figure has often been referred to as the “H”. PEI compromises the lower half of the “H”. The

Rationale \| **211**

 

temporal perspective entails “when” the PEI foundation and its associated modules execute. Figure 13.3 highlights the portions of Figure 13.1 that include PEI.

 

Exposed

 

**Verifier** Interface **OS-Absent** **Pre** Platform

**App**

 

**ver** **Chipset** **Device,** **Environment** **Init** **Bus, or** **Service** **Board** **Transient OS** **Init** **Driver** **Boot Loader** **ify** **Init** **Transient OS** **CPU**

 

**EFI Driver** **Boot** **OS-Present** **Dispatcher** **Manager** **App**

 

**Services** **Intrinsic** **Final OS** **Final OS** **?** **Boot Loader** **Environment** ***security***

 

**Security** **Pre EFI** **Driver** **Boot** **Transient** **Run Time** **After**

**(SEC)** **Initialization** **Execution** **Dev** **System Load** **(RT)** **Life**

**(PEI)** **Environment** **Select** **(TSL)** **(AL)**

**(DXE)** **(BDS)**

**Power on** **\[ . . Platform initialization . . \]** **\[ . . . . OS boot . . . . \]** **Shutdown**

 

**Figure 13.1:** Overall Boot Flow

 

**Chipset/Processor** **OEM, ISV &**

**Function EFI Driver** **Intel BU EFI Driver**

**specs** **specs**

 

**A** **Dr** **Dr** **EF** **EF** **iv** **iv** **er** **I** **er** **EF** **EF** **EF****I**

 

**rc** **I D** **I D** **I D** **riv** **riv****riv** **hit** **Dr** **er** **er****er** **Dr** **ec** **EF** **EF** **EF** **iv** **• • •** **EF** **EF** **iv** **EF** **I Dr** **I Dr** **er** **I** **I Dr** **tu** **er** **I** **I Dr** **re** **iv** **iv** **iv****iv** **er** **er** **er****er** **S** **pe** **cif** **ic** **Dr** **Dr** **Dr** **EF** **EF** **EF** **atio** **iv** **iv** **iv** **er** **I** **er** **I** **er** **I** **n**

 

**Driver Execution Environment (DXE) Spec**

 

**Pre-EFI Initialization (PEI) Spec**

 

**CPU Module Spec(s)** **CS Module Spec(s)**

 

**Legend**

**API**

 

**Figure 13.2:** System Components **212** \| Chapter 13 – Pre-EFI Initialization (PEI)

 

**Chipset/Processor** **OEM, ISV &**

**Function DXE Driver** **Intel BU EFI Driver**

**specs** **specs**

 

**A** **Dr** **DX** **Dr** Exposed **EFI** **iv** **DX** **DE** **EFI** **iv** Platform **E** **er** **Pre** Interface **XE** **er** **E Dr** **DX** **Verifier** **OS-Absent** **EFI** **Dr** **App** **rc** **DX** **Dri** **Dr** **CPU** **DX** **iv** **iv** **Dr** **EFI** **CSM** **hit** **Init** **EDr** **E Dr** **iv** **er** **ve** **• • •** **er** **iv** **er** **E** **ify** **r** **Dr** **iv** **er** **Transient OS** **iv** **ver** **ect** **iv** **Chipset** **Environment** **er** **er** **er** **Init** **Device,** **Bus, or** **Dr** **Dr** **DX** **Dr** **ure** **Service** **DX** **EFI** **Board Init** **Driver** **iv** **iv** **iv** **Transient OS** **er** **E** **er** **E** **Boot Loader** **er** **S** **pecifi** **EFI Driver** **OS-Present** **Dispatcher** **Boot Manager** **App** **Driver Execution Environment (DXE)**

**cati** **Spec** **Intrinsic Services** **Final OS Boot** **Final OS** **?** **Loader** **Environment**

 

**on** **Pre-EFI Initialization (PEI)** ***security*** **Spec**

**CPU Module** **CS Module** **Security** **Pre EFI** **Driver Execution** **Boot Dev** **Transient** **Run Time** **After** **(SEC)** **Initialization** **Environment (DXE)** **Select** **System Load** **(RT)** **Life** **(PEI)** **(BDS)** **(TSL)** **(AL)**

**Spec(s)** **Spec(s)**

**Power on** **\[ . . Platform initialization . . \]** **\[ . . . . OS boot . . . . \]** **Shutdown**

 

**Figure 13.3:** Portion of the Overall Boot Flow and Components for PEI

 

**Phase Prerequisites**

 

The following sections describe the prerequisites necessary for the successful com-

pletion of the PEI phase.

 

**Temporary RAM**

 

The PEI Foundation requires that the SEC phase initialize a minimum amount of

scratch pad RAM that can be used by the PEI phase as a data store until system memory has been fully initialized. This scratch pad RAM should have access proper-

ties similar to normal system RAM—through memory cycles on the front side bus, for example. After system memory is fully initialized, the temporary RAM may be recon-

figured for other uses. Typical provision for the temporary RAM is an architectural mode of the processor’s internal caches.

 

**Boot Firmware Volume**

 

The Boot Firmware Volume (BFV) contains the PEI Foundation and PEIMs. It must appear in the memory address space of the system without prior firmware interven-

tion and typically contains the reset vector for the processor architecture.

The contents of the BFV follow the format of the UEFI PI flash file system. The PEI

Foundation follows the UEFI PI flash file system format to find PEIMs in the BFV. A platform-specific PEIM may inform the PEI Foundation of the location of other firm-

ware volumes in the system, which allows the PEI Foundation to find PEIMs in other

Concepts \| **213**

 

firmware volumes. The PEI Foundation and PEIMs are named by unique IDs in the UEFI PI flash file system.

The PEI Foundation and some PEIMs required for recovery must either be locked

into a non-updateable BFV or be able to be updated using a fault-tolerant mechanism. The UEFI PI flash file system provides error recovery; if the system halts at any point, either the old (pre-update) PEIM(s) or the newly updated PEIM(s) are entirely valid

and the PEI Foundation can determine which is valid.

 

**Security Primitives**

 

The SEC phase provides an interface to the PEI Foundation to perform verification

operations. To continue the root of trust, the PEI Foundation will use this mechanism to validate various PEIMs.

 

**Concepts**

 

The following sections describe the concepts in the PEI phase design.

 

**PEI Foundation**

 

The PEI Foundation is a single binary executable that is compiled to function with

each processor architecture. It performs two main functions:

■ Dispatching PEIMs

■ Providing a set of common core services used by PEIMs

 

The PEI Dispatcher’s job is to transfer control to the PEIMs in an orderly manner. The common core services are provided through a service table referred to as the PEI Ser-

vices Table. These services do the following:

n Assist in PEIM-to-PEIM communication.

■ Abstract management of the temporary RAM.

■ Provide common functions to assist the PEIMs in the following:

– Finding other files in the FFS

– Reporting status codes

– Preparing the handoff state for the next phase of the UEFI PI

 

When the SEC phase is complete, SEC invokes the PEI Foundation and provides the PEI Foundation with several parameters:

■ The location and size of the BFV so that the PEI Foundation knows where to look

for the initial set of PEIMs.

**214** \| Chapter 13 – Pre-EFI Initialization (PEI)

 

■ A minimum amount of temporary RAM that the PEI phase can use ■ A verification service callback to allow the PEI Foundation to verify that PEIMs

that it discovers are authenticated to run before the PEI Foundation dispatches

them

 

The PEI Foundation assists PEIMs in communicating with each other. The PEI Foun-

dation maintains a database of registered interfaces for the PEIMs, as shown in Figure 13.4. These interfaces are called PEIM-to-PEIM Interfaces (PPIs). The PEI Foundation

provides the interfaces to allow PEIMs to register PPIs and to be notified (called back) when another PEIM installs a PPI.

 

**GUID Pointer** PPI Descriptor Ptr A

 

**PPI Pointer** PPI Descriptor Ptr B **PPI Descriptor** **Flags**

PPI Descriptor Ptr C1

 

**PPI** PPI Descriptor Ptr D

PPI Descriptor Ptr C2

NULL

 

**GUID**

**Example Foundation Database**

 

**Figure 13.4:** How a PPI Is Registered

 

The PEI Dispatcher consists of a single phase. It is during this phase that the PEI Foun-

dation examines each file in the firmware volumes that contain files of type PEIM. It examines the dependency expression (depex) within each firmware file to decide if a

PEIM can run. A dependency expression is code associated with each driver that de-scribes the dependencies that must be satisfied for that driver to run. The binary en-

coding of dependency expressions for PEIMs is the same as that of dependency ex-pressions associated with a DXE driver.

 

**Pre-EFI Initialization Modules (PEIMs)**

 

Pre-EFI Initialization Modules (PEIMs) are executable binaries that encapsulate pro-cessor, chipset, device, or other platform-specific functionality. PEIMs may provide

interface(s) that allow other PEIMs or the PEI Foundation to communicate with the PEIM or the hardware for which the PEIM abstracts. PEIMs are separately built binary

modules that typically reside in ROM and are therefore uncompressed. A small subset

Concepts \| **215**

 

of PEIMs exist that may run from RAM for performance reasons. These PEIMs reside in ROM in a compressed format. PEIMs that reside in ROM are execute-in-place mod-

ules that may consist of either position-independent code or position-dependent code

with relocation information.

 

**PEI Services**

 

The PEI Foundation establishes a system table named the PEI Services Table that is

visible to all PEIMs in the system. A PEI service is defined as a function, command, or other capability that is manifested by the PEI Foundation when that service’s initial-ization requirements are met. Because the PEI phase has no permanent memory avail-

able until nearly the end of the phase, the range of services created during the PEI phase cannot be as rich as those created during later phases. Because the location of

the PEI Foundation and its temporary RAM is not known at build time, a pointer to the PEI Services Table is passed into each PEIM’s entry point and also to part of each

PPI. The PEI Foundation provides the following classes of services: ■ *PPI Services:* Manages PPIs to facilitate inter-module calls between PEIMs. Inter-

faces are installed and tracked on a database maintained in temporary RAM. ■ *Boot Mode Services:* Manages the boot mode (S3, S5, normal boot, diagnostics,

and so on) of the system.

■ *HOB Services:* Creates data structures called Hand-Off Blocks (HOBs) that are

used to pass information to the next phase of the UEFI PI. ■ *Firmware Volume Services:* Scans the FFS in firmware volumes to find PEIMs and

other firmware files in the flash device.

■ *PEI Memory Services:* Provides a collection of memory management services for

use both before and after permanent memory has been discovered. ■ *Status Code Services:* Common progress and error code reporting services, that is,

port 080h or a serial port for simple text output for debug. ■ *Reset Services:* Provides a common means by which to initiate a restart of the sys-

tem.

 

**PEIM-to-PEIM Interfaces (PPIs)**

 

PEIMs may invoke other PEIMs through interfaces named PEIM-to-PEIM Interfaces

(PPIs). The interfaces themselves are named using Globally Unique Identifiers (GUIDs) to allow the independent development of modules and their defined inter-

faces without naming collision. A GUID is a 128-bit value used to differentiate services and structures in the boot services. The PPIs are defined as structures that may con-

tain functions, data, or a combination of the two. PEIMs must register their PPIs with the PEI Foundation, which manages a database of registered PPIs. A PEIM that wants **216** \| Chapter 13 – Pre-EFI Initialization (PEI)

 

to use a specific PPI can then query the PEI Foundation to find the interface it needs. The two types of PPIs are:

■ Services

■ Notifications

 

PPI services allow a PEIM to provide functions or data for another PEIM to use. PPI

notifications allow a PEIM to register for a callback when another PPI is registered with the PEI Foundation.

 

**Simple Heap**

 

The PEI Foundation uses temporary RAM to provide a simple heap store before per-manent system memory is installed. PEIMs may request allocations from the heap,

but no mechanism exists to free memory from the heap. Once permanent memory is installed, the heap is relocated to permanent system memory, but the PEI Foundation

does not fix up existing data within the heap. Therefore, a PEIM cannot store pointers in the heap when the target is other data within the heap, such as linked lists.

 

**Hand-Off Blocks (HOBs)**

 

Hand-Off Blocks (HOBs) are the architectural mechanism for passing system state in-formation from the PEI phase to the DXE phase in the UEFI PI architecture. A HOB is

simply a data structure (cell) in memory that contains a header and data section. The header definition is common for all HOBs and allows any code using this definition

to know two items:

■ The format of the data section

■ The total size of the HOB

 

HOBs are allocated sequentially in the memory that is available to PEIMs after perma-nent memory has been installed. A series of core services facilitate This sequential list

of HOBs in memory is referred to as the *HOB list.* This first HOB in the HOB list must be the Phase Handoff Information Table (PHIT) HOB that describes the physical

memory used by the PEI phase and the boot mode discovered during the PEI phase, as illustrated in Figure 13.5.

Operation \| **217**

 

**Memory** **System** **System** **System** **System** **System** **System** **I/O** **MMIO** **Firmware** **Firmware** **System** **DXE** **Memory** **Memory** **Memory** **Memory** **Memory** **Resources** **Resources** **Devices** **Volumes** **Memory** **Drivers**

**HOB List**

 

**PHIT** **System** **DXE** **Memory** **HOB** **HOB** **HOB** **HOB** **. . .** **HOB** **Drivers** **HOB**

 

**Figure 13.5:** The HOB List

 

Only PEI components are allowed to make additions or changes to HOBs. Once the HOB list is passed into DXE, it is effectively read-only for DXE components. The ram-

ifications of a read-only HOB list for DXE is that handoff information, such as boot mode, must be handled in a unique fashion; if DXE were to engender a recovery con-

dition, it would not update the boot mode but instead would implement the action using a special type of reset call. The HOB list contains system state data at the time

of PEI-to-DXE handoff and does not represent the current system state during DXE. DXE components should use services that are defined for DXE to get the current sys-

tem state instead of parsing the HOB list.

As a guideline, it is expected that HOBs passed between PEI and DXE will follow

a one producer–to–one consumer model. In other words, a PEIM will produce a HOB in PEI, and a DXE Driver will consume that HOB and pass information associated with

that HOB to other DXE components that need the information. The methods that the DXE Driver uses to provide that information to other DXE components should follow

mechanisms defined by the DXE architecture.

 

**Operation**

 

PEI phase operation consists of invoking the PEI Foundation, dispatching all PEIMs

in an orderly manner, and discovering and invoking the next phase, as illustrated in Figure 13.6. During PEI Foundation initialization, the PEI Foundation initializes the

internal data areas and functions that are needed to provide the common PEI services to PEIMs. During PEIM dispatch, the PEI Dispatcher traverses the firmware volume(s)

and discovers PEIMs according to the flash file system definition. The PEI Dispatcher then dispatches PEIMs if the following criteria are met:

■ The PEIM has not already been invoked. ■ The PEIM file is correctly formatted.

■ The PEIM is trustworthy.

■ The PEIM’s dependency requirements have been met.

 

After dispatching a PEIM, the PEI Dispatcher continues traversing the firmware vol-

ume(s) until either all discovered PEIMs have been invoked or no more PEIMs can be invoked because the requirements listed above cannot be met for any PEIMs. Once **218** \| Chapter 13 – Pre-EFI Initialization (PEI)

 

this condition has been reached, the PEI Dispatcher’s job is complete and it invokes an architectural PPI for starting the next phase of the UEFI PI, the DXE Initial Program

Load (IPL) PPI.

 

SEC

Memory

 

PEI Core Services BFV PPI Map FV(s) Core Boot Mode R/O F Me Handoff Block Status T-RAM

 

Initialization W or D m

Core ata Code ba V y Se

 

Dispatcher se System rv ol Memory ic s es

 

Entry Entry Entry Entry Entry

 

PPI(s) DXE PPI(s) PPI(s) PPI(s)

IPL

PEIM PEIM PEIM PEIM PEIM

 

**Figure 13.6:** PEI Boot Flow

 

**Dependency Expressions**

 

The sequencing of PEIMs is determined by evaluating a *dependency expression* asso-ciated with each PEIM. This Boolean expression describes the requirements that are

necessary for that PEIM to run, which imposes a weak ordering on the PEIMs. Within this weak ordering, the PEIMs may be initialized in any order. The GUIDs of PPIs and

the GUIDs of file names are referenced in the dependency expression. The depend-ency expression is a representative syntax of operations that can be performed on a

plurality of dependencies to determine whether the PEIM can be run. The PEI Foun-dation evaluates this dependency expression against an internal database of run

PEIMs and registered PPIs. Operations that may be performed on dependencies are the logical operators AND, OR, and NOT and the sequencing operators BEFORE and

AFTER.

Operation \| **219**

 

**Verification/Authentication**

 

The PEI Foundation is stateless with respect to security. Instead, security decisions

are assigned to platform-specific components. The two components of interest that abstract security include the Security PPI and a Verification PPI. The purpose of the Verification PPI is to check the authentication status of a given PEIM. The mechanism

used therein may include digital signature verification, a simple checksum, or some other OEM-specific mechanism. The result of this verification is returned to the PEI

Foundation, which in turn conveys the result to the Security PPI. The Security PPI decides whether to defer execution of the PEIM or to let the execution occur. In addi-

tion, the Security PPI provider may choose to generate an attestation log entry of the dispatched PEIM or provide some other security exception.

 

**PEIM Execution**

 

PEIMs run to completion when invoked by the PEI Foundation. Each PEIM is invoked only once and must perform its job with that invocation and install other PPIs to allow

other PEIMs to call it as necessary. PEIMs may also register for a notification callback if it is necessary for the PEIM to get control again after another PEIM has run.

 

**Memory Discovery**

 

Memory discovery is an important architectural event during the PEI phase. When a PEIM has successfully discovered, initialized, and tested a contiguous range of sys-

tem RAM, it reports this RAM to the PEI Foundation. When that PEIM exits, the PEI Foundation migrates PEI usage of the temporary RAM to real system RAM, which in-

volves the following two tasks:

■ The PEI Foundation must switch PEI stack usage from temporary RAM to perma-

nent system memory.

■ The PEI Foundation must migrate the simple heap allocated by PEIMs (including

HOBs) to real system RAM.

 

Once this process is complete, the PEI Foundation installs an architectural PPI to no-tify any interested PEIMs that real system memory has been installed. This notifica-

tion allows PEIMs that ran before memory was installed to be called back so that they can complete necessary tasks—such as building HOBs for the next phase of DXE—in

real system memory.

**220** \| Chapter 13 – Pre-EFI Initialization (PEI)

 

**Intel® Itanium® Processor MP Considerations**

 

This section gives special consideration to the PEI phase operation in Intel Itanium

processor family multiprocessor (MP) systems. In Itanium-based systems, all of the processors in the system start up simultaneously and execute the PAL initialization code that is provided by the processor vendor. Then all the processors call into the

UEFI PI start-up code with a request for recovery check. The start-up code allocates different chunks of temporary memory for each of the active processors and sets up

stack and backing store pointers in the allocated temporary memory. The temporary memory could be a part of the processor cache (cache as RAM), which can be config-

ured by invoking a PAL call. The start-up code then starts dispatching PEIMs on each of these processors. One of the early PEIMs that runs in MP mode is the PEIM that

selects one of the processors as the boot-strap processor (BSP) for running the PEIM stage of the booting.

This BSP continues to run PEIMs until it finds permanent memory and installs the memory with the PEI Foundation. Then the BSP wakes up all the processors to deter-

mine their health and PAL compatibility status. If none of these checks warrants a recovery of the firmware, the processors are returned to the PAL for more processor

initialization and a normal boot.

The UEFI PI start-up code also gets triggered in an Itanium-based system when-

ever an INIT or a Machine Check Architecture (MCA) event occurs in the system. Un-der such conditions, the PAL code outputs status codes and a buffer called the *mini-*

*mum state buffer.* A UEFI PI-specific data pointer that points to the INIT and MCA code data area is attached to this minimum state buffer, which contains details of the code

to be executed upon INIT and MCA events. The buffer also holds some important var-iables needed by the start-up code to make decisions during these special hardware

events.

 

**Recovery**

 

Recovery is the process of reconstituting a system’s firmware devices when they have

become corrupted. The corruption can be caused by various mechanisms. Most firm-ware volumes on nonvolatile storage devices are managed as blocks. If the system

loses power while a block or semantically bound blocks are being updated, the stor-age might become invalid. On the other hand, the device might become corrupted by

an errant program or by errant hardware. Assuming PEI lives in a fault-tolerant block, it can support a recovery mode dispatch.

A PEIM or the PEI Foundation itself can discover the need to do recovery. A PEIM can check a “force recovery” jumper, for example, to detect a need for recovery. The

PEI Foundation might discover that a particular PEIM does not validate correctly or that an entire firmware volume has become corrupted.

Operation \| **221**

 

The concept behind recovery is that enough of the system firmware is preserved so that the system can boot to a point that it can read a copy of the data that was lost

from chosen peripherals and then reprogram the firmware volume with that data.

Preservation of the recovery firmware is a function of the way the firmware vol-ume store is managed. In the UEFI PI flash file system, PEIMs required for recovery are marked as such. The firmware volume store architecture must then preserve

marked items, either by making them unalterable (possibly with hardware support) or protect them using a fault-tolerant update process.

Until recovery mode has been discovered, the PEI Dispatcher proceeds as normal. If the PEI Dispatcher encounters PEIMs that have been corrupted (for example, by

receiving an incorrect hash value), it must change the boot mode to recovery. Once set to recovery, other PEIMs must not change it to one of the other states. After the PEI

Dispatcher has discovered that the system is in recovery mode, it will restart itself, dispatching only those PEIMs that are required for recovery. It is also possible for a

PEIM to detect a catastrophic condition or to be a forced-recovery detect PEIM and to inform the PEI Dispatcher that it needs to proceed with a recovery dispatch. The re-

covery dispatch is completed when a PEIM finds a recovery firmware volume on a recovery media and the DXE Foundation is started from that firmware volume. Drivers

within that DXE firmware volume can perform the recovery process.

 

**S3 Resume**

 

The PEI phase on S3 resume (save-to-RAM resume) differs in several fundamental

ways from the PEI phase on a normal boot. The differences are as follows: ■ The memory subsection is restored to its pre-sleep state rather than initialized.

■ System memory owned by the OS is not used by either the PEI Foundation or the

PEIMs.

■ The DXE phase is not dispatched on a resume because it would corrupt memory. ■ The PEIM that would normally dispatch the DXE phase instead uses a special

Hardware Save Table to restore fundamental hardware back to a boot configura-

tion. After restoring the hardware, the PEIM passes control to the OS-supplied

resume vector.

■ The DXE and later phases during a normal boot save enough information in the

UEFI PI reserved memory or a firmware volume area for hardware to be restored

to a state that the OS can use to restore devices. This saved information is located

in the Hardware Save Table.

**222** \| Chapter 13 – Pre-EFI Initialization (PEI)

 

**The “Terse Executable” and Cache-as-RAM**

 

The flash storage where the PEI modules and core execute has several constraints.

The first is that the amount of flash allocated for PEI is limited. This stems both from the economics of system board design and from the fact that the PEI phase supports critical operations, such as crisis recovery and early memory initialization. These ro-

bustness requirements mean that many systems have two instances of PEI: a backup and/or truly read-only one that never changes and may only be used for recovery and

a security root-of-trust, and a second PEI block used for normal boots that is the dual of the former one. Also, the execute-in-place (XIP) nature of code-fetches from flash

means that PEI is not as performant as DXE modules that are loaded into host memory. In order to minimize the amount of space occupied by the PEI firmware vol-

ume (FV), the Terse Executable (TE) image format was designed. The TE image format is a strict subset of the Portable Executable/Common File Format (PE/COFF) image

used by UEFI applications, UEFI drivers, and DXE drivers.

The advantages of having TE as a subset of PE include the ability to use standard,

available tools, such as linkers, which can be used during the development process. Only during the final phases of the FV image creation does the tool chain need to

convert the PE image into a TE. This similarity extends to the headers and the reloca-tion records. In order to have an in-situ agent, such as a debugger nub, distinguish

between the PE and TE images, the signature field has been slightly modified. For the PE, the signature is “MZ” for Mark Zbikowski, the designer of the Microsoft DOS† im-

age format, the origin of the PE/COFF image. For the TE image, the signature is “VZ”, as found at the end of Volume 1 of the UEFI PI specification:

 

\#define EFI_TE_IMAGE_HEADER_SIGNATURE 0x5A56 // “VZ”

This one character difference allows for sharing of debug scripts and code that only need to distinguish between the PE and TE via this one character of the signature

field. Although the development and design team eschewed use of proper names in code or the resultant binaries, the “VZ” and “Vincent Zimmer” association appeared

harmless, especially given the interoperability advantages.

In addition to the TE image, the “temporary memory” used during PEI is another

innovation on Intel architecture platforms. Recall that the goal of PEI is to provide a basic system fabric initialization and some subset of memory that will be available

throughout DXE, UEFI, and the operating system runtime. In order to program a mod-ern CPU, memory controller, and interconnect, thousands of lines of C code may be

required. In the spirit of using standard tools to write this code, though, some memory store prior to the permanent Dynamic RAM (DRAM) needed to be found.

Other approaches to this challenge in the past include the Coreboot use of the read-only-memory C compiler (romcc), or a compiler that uses processor registers as

the “temporary memory.” This approach has proven difficult to maintain and entails

Operation \| **223**

 

a custom compiler. The other approach is to have dedicated memory on the platform immediately available after reset. Given the economics of modern systems and the

transitory usage of this store, the use of discrete memory as a scratchpad has proven

difficult to provide in anything other than the high-end system or extremely low-end, nontraditional systems. The approach taken for the bulk of Intel architecture systems is to use the processor cache as a memory store, or cache-as-RAM (CAR). Although

the initialization sequence is unique per architecture instance (for example, Ita-nium® versus Core2® versus Core i7®), the end result is some directly addressable

memory after exiting the SEC phase and entering PEI. As a result, PEIMs and a PEI core can be written in C using commonly available C compilers, such as Microsoft

cl.exe in Visual Studio† and the GNU C compiler (GCC) available in the open source community. The UEFI Developer Kit, such as the PEI core in the Module Development

Environment (MDE) module package at www.tianocore.org provides such as example of a generic PEI Core source collection.

 

**Example System**

 

All of the concepts regarding PEI can be synthesized when reviewing a specific plat-form. The following list represents an 865 system with all of the associated system

components. This same system is also shown in Figure 13.7, which includes the actual silicon components. Figure 13.8 provides an idealized version of this same system.

The components in the latter figure have corresponding PEIMs to abstract both the initialization of and services by the components. For each of these components, one

to several PEI Modules can be delivered that abstract the specific component’s behav-ior. An example of these components can include:

■ Pentium® 4 processor PEIM: Initialization and CPU I/O service ■ PCI Configuration PEIM: PCI Configuration PPI

■ ICH PEIM: ICH initialization and the SMBUS PPI ■ Memory initialization PEIM: Reading SPD through the SMBUS PPI, initialization

of the memory controller, and reporting memory available to the PEI core ■ Platform PEIM: Creation of the flash mode, detection of boot mode

■ DXE IPL: Generic services to launch DXE, invoke S3 or recovery flow

**224** \| Chapter 13 – Pre-EFI Initialization (PEI)

 

**Processor**

 

**AGP Graphics** **AGP** **Front-Side Bus**

**Card**

 

**Video Capture** **DAC Out** **82865** **DDR** **GMCH** **TV Out**

**Hub**

**Interface** **SMBus**

**USB** **PCI Bus** **IDE** **ICH5**

LAN

**PCI Slots**

Audio Codec **AC97**

Modem Codec **LPC I/F** **KBC/** **FWH** **SIO**

 

**Figure 13.7:** Specific System

 

**Intel**

 

**AGP** **Pentium 4** **AGP**

 

**Video** **Bridge** **Modules** **Modules** **Video** **SM Bus** **IDE** **IDE** **South** **PCI** **PCI** **AGP** **North** **Memory** **Memory** **AGP** **Slot** **Slot**

![](media/index-243_1.png)

**USB** **Bridge** **PCI Bus** **Slots** **USB** **Slots**

![](media/index-243_2.png)

 

**LAN** **LPC Bus** **LAN**

![](media/index-243_3.png)

 

**Audio** **Super** **FLASH** **FLASH** **Audio** **I/O**

![](media/index-243_4.png)

 

**Figure 13.8:** Idealization of Actual System

![](media/index-243_5.png)

 

typedef

![](media/index-243_6.png)

EFI_STATUS

![](media/index-243_7.png)

(EFIAPI \*PEI_SMBUS_PPI_EXECUTE_OPERATION) ( IN EFI_PEI_SERVICE \*\*PeiServices, IN struct EFI_PEI_SMBUS_PPI \*This,

![](media/index-243_8.png)

![](media/index-243_9.png)

![](media/index-243_10.png)

![](media/index-243_11.png)

![](media/index-243_12.png)

![](media/index-243_13.png)

![](media/index-243_14.png)

Operation \| **225**

 

IN EFI_SMBUS_DEVICE_ADDRESS SlaveAddress, IN EFI_SMBUS_DEVICE_COMMAND Command, IN EFI_SMBUS_OPERATION Operation, IN BOOLEAN PecCheck, IN OUT UINTN \*Length, IN OUT VOID \*Buffer );

 

typedef struct {

PEI_SMBUS_PPI_EXECUTE_OPERATION Execute; PEI_SMBUS_PPI_ARP_DEVICE ArpDevice; } EFI_PEI_SMBUS_PPI;

 

**Figure 13.9:** Instance of a PPI

 

What is notable about a PPI is that it is like an EFI protocol in that it has member services and/or static data. The PPI is named by a GUID and can have several in-

stances. The SMBUS PPI, for example, could be implemented for SMBUS controllers in the ICH, in another vendor’s integrated Super I/O (SIO), or other component. Figure

13.10 illustrates an instance of an SMBUS PPI for an Intel ICH.

 

\#define SMBUS_R_HD0 0xEFA5

\#define SMBUS_R_HBD 0xEFA7

 

EFI_PEI_SERVICES \*PeiServices; SMBUS_PRIVATE_DATA \*Private;

UINT8 Index, BlockCount \*Length;

UINT8 \*Buffer;

 

BlockCount = Private-\>CpuIo.IoRead8 (

\*PeiServices,Private-\>CpuIo,SMBUS_R_HD0); if (\*Length \< BlockCount) {

return EFI_BUFFER_TOO_SMALL;

} else {

for (Index = 0; Index \< BlockCount; Index++) {

Buffer\[Index\] = Private-\>CpuIo.IoRead8 (

\*PeiServices,Private-

\>CpuIo,SMBUS_R_HBD);

}

}

 

**Figure 13.10:** Code that Supports a PPI Service **226** \| Chapter 13 – Pre-EFI Initialization (PEI)

 

**Summary**

 

This chapter has provided an overview of the PEI phase of the UEFI PI environment. PEI provides a unique combination of software modularity so that various business

interests can provide modules, while at the same time have purpose-built technolo-

gies to support the robustness and resource constraints of such an early phase of ma-chine execution. Aspects of PEI discussed in this chapter include the concept of tem-porary memory, the PEI Core services, PEI relative to other UEFI PI components,

recovery, and some sample PEI modules.