## **Chapter 17 – Manageability** 

 

I came, I saw, I conquered

—Julius Caesar

 

RAS is a critical requirement for enterprise class servers, which includes high availa-

bility server platforms. System uptime is measured against the goal of “five nines,” which represents 99.999 percent availability. One of the key aims of manageability

software is to help achieve this goal, by implementing functions like dynamic error detection, correction, hardware failure prediction, and the taking of corrective ac-

tions like replacing or turning off failing components before the failure actually hap-pens. In addition, other noncritical manageability functions enable IT personal to re-

motely manage a system by performing such operations as remote power up/down, diagnostics, and inventory management. Manageability software can be part of the

inline system software (the SMI handler in BIOS and OS) or inline OS user-level appli-cation software running on the local processor or on a remote system.

This chapter describes the enhanced Intel® architecture platform dynamic error handling framework, a system-level error management infrastructure that is now an

integral part of most industry standard server class operating systems. In addition to the above framework, different remote manageability standards are introduced, by

comparing and contrasting various aspects and their interoperability at a platform level in achieving the five nines goal.

 

**Overall Management Framework**

 

A robust reporting of platform errors to the OS and a remote management of the plat-form are considered fundamental building blocks that enable OS-level decision mak-

ing for various error types and possible actions by remote IT personnel upon notifica-tion of the associated events. The framework encompasses a collection of com-

ponents internal to the OS, platform chipset fabric, and more specifically an en-hanced firmware interface for communicating hardware error information between

the OS and the platform.

By standardizing the interfaces and error reporting through which hardware er-

rors are presented to, configured for, signaled to, and reported through the frame-work, the management software would be presented with a myriad of opportunities.

The two categories of error/event types that need active management in a platform are illustrated in Figure 17.1 and can be enumerated as *in-band* and *out-of-band mech-*

*anisms*.

 

DOI 10.1515/9781501505690-019

**270** \| Chapter 17 – Manageability

 

**Local Manageability Application** **Local Manageability Application** **Remote Manageability Application Remote Manageability Application**

 

**WS** **WS****-****-****MAN** **MAN**

 

**WHEA** **WHEA** **Operating System Operating System**

 

**EFI** **IPMI** **EFI** **AMT** **AMT** **IPMI**

 

**In** **In****-****Band Errors** **Band Errors** **Out** **Out****-****of** **of****-****Band Errors** **Band Errors**

 

**Standard IA Platform HW** **Standard IA Platform HW** **Manageability HW** **Manageability HW**

 

**Figure 17.1:** Manageability Domains

 

The various classes of manageability implementations handing these two classes of errors/events are as follows:

■ Traditional UEFI/BIOS power-on self tests/diagnostics (POST)

■ 1 UEFI/BIOS based dynamic error functions coupled with SMI/PMI for dynamic er-

ror management

■ Server baseboard management controllers (BMC) Out-Of-Band (OOB) Intelligent

Platform Management Interface (IPMI) implementations ■ Client/Mobile Intel® Active Management Technology (Intel AMT) OOB imple-

mentations

■ OS based dynamic error management

 

Dynamic in-band errors like 1xECC, 2xECC on memory or PCIe† corrected/uncorrected

impact the running system and its uptime attribute in the near to immediate future depending on the severity, while out-of-band errors due to peripheral system compo-nents like fan failure, thermal trips, intrusion detection, and so on are not fatal. While

in-band errors need immediate system attention and error handling to maintain the

uptime, most out-of-band errors would need the attention of manageability software for deferred handling. However, over a period of time both categories of errors/ events, if not handled properly, will impact the system uptime.

 

\|\|

**1** SMI: System Management Interrupt of x86 processor; PMI: Platform Management Interrupt of Ita-nium® processor

Overall Management Framework \| **271**

 

**Dynamic In-Band**

 

In-Band error management is typically handled by software that is part of the stand-

ard system software stack consisting of system BIOS (SMI/PMI), operating system, device drivers/ACPI control methods, and user mode manageability applications run-ning on the target system. The key technologies that are covered in this context are as

follows:

■ Standardized UEFI error format

■ Various platform error detection, reporting, and handling mechanisms ■ Windows Hardware Error Architecture (WHEA) as an example that leverages

UEFI standards.

 

**Out-of-Band**

 

Out-of-band error management is handled by out-of-band firmware such as, for ex-

ample, firmware running on BMCs conforming to IPMI standards. The key technolo-gies that are covered in this space are:

■ IPMI

■ Intel AMT

■ DMTF and DASH as they relate to IPMI and Intel AMT

 

IPMI is prevalent on server class platforms through the use of an industry standard management framework or protocol like WS-MAN. The following section focuses

more on the in-band error domain and the most recent advancements, followed by out-of-band error management technology domain(s) and a way to bridge the two in

a seamless way at the target platform level: servers, desktop client, mobile, and so on.

The other domain of management for client and mobile system is through the In-

tel AMT feature, which allows IT to better discover, heal, and protect their networked client and desktop computing assets using built-in platform capabilities and popular

third-party management and security applications. Intel AMT today is primarily based on the out-of-band implementations as explained above and allows access to

information on a central repository stored in the platform nonvolatile memory (NVM).

 

**Distributed Management Task Force (DMTF)**

 

The DMTF is an industry organization that is leading the development, adoption, and

promotion of interoperable management initiatives and standards. Further details on this will be covered later in this chapter.

**272** \| Chapter 17 – Manageability

 

**UEFI Error Format Standardization**

 

In this section, we delve into the first level details of the in-band errors and their han-dling based on the UEFI standard.

On most platforms, standard higher level system software like shrink-wrap oper-

ating systems directly log available in-band system dynamic error information from the processor and chipset architectural error registers to a nonvolatile storage. These errors are signaled at system runtime through various event notification mechanisms

like machine check exception on Intel® architecture processors (example: int-18) or NMI, system management interrupt (SMI) or standard interrupts like ACPI defined

SCI. The challenge is and always has been to get non-architectural information from the platform, which is typically not visible to a standard OS, but to the system-specific

firmware only. Partial platform error information from the architectural sources (such as Machine Check Bank machine specific registers (MSR) as in x86 processor or as

returned by the processor firmware PAL on Itanium®) alone is not sufficient for de-tailed and meaningful error analysis or corrective action. Moreover, neither the OS

nor other third party manageability software has knowledge about how to deal with raw information from the platform, or how to parse and interpret it for meaningful

error recovery or manageability healing actions.

The Figure 17.2 illustrates a typical dynamic error handling on most platforms

with shrink-wrap OS implementations, for two different error-handling components of notification/signaling and logging. In this model, a component of the OS kernel

directly logged the error information from the processor architectural registers, while platform firmware logged non-architectural error information to a nonvolatile storage

for its private usage, with no way to communicate this back to the OS and vice versa. Both the platform events (SMI) and processor events (MCE) are decoupled from each

other.

UEFI Error Format Standardization \| **273**

 

**OS Error Handling Components**

 

**Machine Check**

**Exception**

 

**OS Legacy**

**Interface (MCE)**

 

**Native OS** **SMI** **MSR**

**Access** **Firmware**

 

**Processor** **Platform**

 

**Figure 17.2:** Traditional OS Error Reporting Stack

 

To make the system error reporting solution complete, the manageability software will have to be provided with the following:

■ Processor error logs

■ Implementation-specific hardware error logs, such as from platform chipset

■ Industry Standard Architecture hardware error logs, such as PCIe Advance Error

Reporting registers (AER)

■ System event logs (SELs) as logged by BMC-IPMI implementations

 

As can be seen in Figure 17.3, there is a coordination challenge between different sys-tem software components managing errors for different platform hardware functions.

Some of the error events (such as interrupts, for example) managed by platform enti-ties not visible to the OS may eventually get propagated to the OS level, but with no

associated information. Therefore, an OS is also expected to handle an assortment of hardware error events from several different sources, with limited information and

knowledge of their control path, configuration, signaling, error log information, and so on. This creates synchronization challenges across the platform software compo-

nents when accessing the error resources, especially when they are shared between firmware and OS, such as in the case of I/O devices like PCI or PCIe. For example when

the OS does receive a platform-specific error event/interrupt like NMI, it would have no clue about what caused it and how to deal with it.

**274** \| Chapter 17 – Manageability

 

**F/W Controlled Logging-Settings**

Error Detection Enable

**F/W Error Logs (H/W)**

CSRs:

H/W

 - Corrected errors

Writes

 - Uncorrected errors

 

S/W CSR Reads

Err Detection Mux

0

 

**Platform Errors** **F/W Controlled Signaling-Settings**

SMI Enable **No information** **Firmware/BIOS S/W**

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-293_1.png)

MCERR En **Operating System**

**S/W**

 

MCERR

SMI Interrupt

Err Signal Mux

0

 

**Configurable Platform Hardware**

 

**Figure 17.3:** Traditional OS Error Reporting Stack

 

Based on this state of OS error handling and the identified needs for future enhance-

ments, a new architecture framework has been defined. This framework is based on the top-down approach, with the OS usage model driving various lower level system

component behaviors and interfaces.

Error management includes two different components, namely error notifica-

tion/signaling and error logging/reporting, for all system errors. The fundamental component of this architecture is a model for error management, which includes an

architected platform firmware interface to the OS. This interface was defined to facil-itate the platform to provide error information to the OS in a standardized format. This

firmware-based enhanced error reporting will coexist with legacy OS implementa-tions, which are based on direct OS access to the architected processor hardware error

control and status registers, such as the processor machine check (MC) Banks.

The architected interface also gives the OS an ability to discover the platform’s

error management capabilities and a way to configure it for the chosen usage model with the help of standardized error objects. This enables the OS to make the overall

system error handling policy management decisions through appropriate system con-figuration and settings.

UEFI Error Format Standardization \| **275**

 

To facilitate abstracted error signaling and reporting for most common platform in-band errors, namely those emanating from the processor and chipset, a new

UEFI/ACPI Error Interface extension was defined with the following goals:

■ Achieve error reporting abstraction for architectural and non-architectural plat-

form functional hardware

■ An access mechanism for storage/retrieval of error records to the platform NVM,

for manageability software use

■ Allowing freedom of platform implementation, including firmware based prepro-

cessing of errors

■ Allow discovery of platform error sources, its capabilities and configurability

through firmware assist

■ Standardized error log formats for key hardware

 

Figure 17.4 illustrates various components with UEFI extensions to satisfy the above

goals.

 

**Manageability** **OS Error Handling Components**

**Software**

 

**Machine Check**

**Exception**

 

**Industry Standard Technology Interface (API)**

 

**Interface** **UEFI** **IPMI** **SMI** **Error** **AMT** **Handler** **Firmware**

 

**Processor** **Platform**

 

**Figure 17.4:** OS Error Reporting Stack with UEFI Standardization

 

Non-Goals: The UEFI specification did not cover the following: ■ Details of the platform hardware design or signal routing ■ OS or other system software error handling implementations or error handling

policies

■ Usage model of this interface

■ Standardized error log formats for all hardware **276** \| Chapter 17 – Manageability

 

**UEFI Error Format Overview**

 

The error interface consists of a set of OS runtime APIs implemented by system firm-

ware accessed through UEFI or a SMI runtime interface mechanisms. These standard-ized APIs will provide the following capabilities:

■ Error reporting to OS through *standardized* error log formats as defined by other

specifications

■ The ability to store OS and OEM specific records to the platform nonvolatile stor-

age in a *standardized* way and manage these records based on an implementa-

tion-specific usage model

■ Ability to discover platform implementation capabilities and their configuration

through *standardized* platform specific capability record representation

 

This specification only covers the runtime API details. It is based on coordination be-

tween different system stack components through architected interfaces and flows. It requires cooperation between system hardware, firmware, and software components.

The platform nonvolatile storage services are the minimum required features for this error model.

 

**Error Record Types**

 

The API provides services to support different predefined record types. Each record type being acessed is identified by an architected unique Record ID, which is man-

aged by the interface. These Record IDs will remain constant across all implementa-tions, allowing different software implementations to interoperate in a seamless way.

Record types can include GUIDs representing records belonging to different catego-ries as follows:

1\. *Notification Types.* Standard GUIDs as defined in the common error record format

for each of the error record types, which are associated with information returned

for different event notification types (examples: NMI, MCE, and so on). 2. *Creator Identifier*. This can correspond to the CreatorID GUID as specified in the

common error record format or other additional vendor defined GUID. 3. *Error Capability*. This is a GUID as defined by the platform vendor for platform

implemented error feature capability discovery and configuration record types.

 

**Error Notification Type**

Error notification type records are based on notification types that are associated with

standard event signaling/interrupts, each of which is identified by an architecturally assigned GUID and are defined below:

■ Corrected Machine Check (CMC)

Windows Hardware Error Architecture and the Role of UEFI \| **277**

 

■ Corrected Platform Error (CPE)

■ Machine Check Exception (MCE)

■ PCI Express error notification (PCIe)

■ Initilization (INIT)

■ Non-Maskable Interrupt (NMI)

■ Boot

■ DMAr

 

Recently enhancements to the UEFI includes ARM64 processor and platform specific error notification types with the associated error records & section as follows:

■ Synchronous External Abort (SEA)

■ Asynchronous Error Interrupt (SEI)

■ Platform Error Interrupt (PEI)

 

**Creator Identifier**

Creator ID record types are associated with event notification types, but the actual

creator of the error record can be one of the system software entities. This creator ID is a GUID value pre-assigned by the system software vendor. This value may be over-

written in the error record by subsequent owners of the record than the actual crea-tors, if it is manipulated. The standard creator IDs defined are as follows:

■ Platform Firmware as defined by the firmware vendor ■ OS vendor

■ OEM

 

An OS saved record to the platform nonvolatile storage will have an ID created by the OS, while platform-generated records will have a firmware creator ID. The creator ID

has to be specified during retrival of the error record from platform storage. Other system software vendors (OS or OEM) must define a valid GUID.

 

**Error Capability**

The error capability record type is associated with platform error capability reporting

and configuration. Error capability is reserved for discovering platform capabilities and its configuration.

For further details on the APIs to get/set/clear error records from the non-volatile storage on the platform through UEFI, refer to the UEFI 2.3 or above specification.

 

**Windows Hardware Error Architecture and the Role of UEFI**

 

Prior to the UEFI common error format standardization, most of the operating systems supported several unrelated mechanisms for reporting hardware errors. The ability to **278** \| Chapter 17 – Manageability

 

determine the root cause of hardware errors was hindered by the limited amount of error information logged in the OS system event log. These mechanisms provided lit-

tle support for error recovery and graceful handing of uncorrected errors.

The fundamental basis for this architecture is the reporting of platform error log information to the OS in a standardized format, so that it is made available to man-ageability software. In addition, a standard access mechanism to this error infor-

mation through UEFI and ACPI has also been defined, both for Itanium and x86 plat-forms as a runtime UEFI API Get/Set Variable. This enabled all OS implementations

such as Windows, Linux, HP-UX and platform BIOS implementations to conform to one standard for easier coordination and synchronization during an error condition.

This is the fundamental building block that has enabled interoperability across dif-ferent manageability software, written either by the OS vendors, BIOS vendors, or

third party application vendors by allowing them to understand and speak the same language to communicate error source discovery, configuration, and data format rep-

resentation.

The Windows Hardware Error Architecture (WHEA), introduced with Windows

Vista, extends the previous hardware error reporting mechanisms and brings them together as components of a coherent hardware error infrastructure. WHEA takes ad-

vantage of the additional hardware error information available in today’s hardware devices and integrates much more closely with the system firmware, namely the UEFI

standardized error formats.

 

WHEA can be summarized in a nutshell as:

■ UEFI Standardized Common error record format

— Management applications benefit

— Pre-boot and out-of-band applications

— Architecturally defined for processor, memory, PCIe, and so on. ■ Error source discovery

— Fine-grained control of error sources ■ Common error handling flow

— All hardware errors processed by same code path ■ Hardware error abstractions became operating system first-class citizens

— Enables error source management ■ Firmware first error model

— Some errors may be handled in firmware before the OS is given control, like

errata management and error containment

 

As a result, WHEA provides the following benefits:

■ Allows for more extensive error data to be made available in a standard error rec-

ord format for determining the root cause of hardware errors.

■ Provides mechanisms for recovering from hardware errors to avoid bugchecking

the system when a hardware error is nonfatal.

Windows Hardware Error Architecture and the Role of UEFI \| **279**

 

■ Supports user-mode error management applications and enables advanced com-

puter health monitoring by reporting hardware errors via Event Tracing for Win-

dows (ETW) and by providing an API for error management and control.

■ Is extensible, so that as hardware vendors add new and better hardware error

reporting mechanisms to their devices, WHEA allows the operating system to

gracefully accommodate the new mechanisms.

 

The UEFI standard has now defined error log formats for the most common platform

components like processor, memory, PCIe, and so on, in addition to error source based discovery and configuration through ACPI tables. These error formats provide

a higher level of abstraction. It is beyond the scope of this book to get into the details, but an overview of error log format is illustrated in Figure 17.5. Each of the error events

is associated with a record, consisting of multiple error sections, where the sections conforms to standard platform error types like processor, memory, PCIe, and so on,

identified by a pre-assigned GUID. The definition of the format is scalable and allows for the support of other nonstandard OEM-specific formats, including the IPMI SEL

event section.

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-298_1.png)

 

**Provided by:** **Provided by:** **Provided by:** **Provided by:**

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-298_2.png)

 

Management/Reporting Applications **Microsoft** **Microsoft** **Microsoft** **Microsoft**

 

**ISV/IHV** **ISV/IHV** **ISV/IHV** **ISV/IHV**

 

**WMI Management Interface** **WMI Management Interface** **ETW Error Notifications** **ETW Error Notifications** **Code Gen** **Code Gen** **Code Gen** **Code Gen**

 

Kernel

 

HAL PCI.SYS LLHEH LLHEH

 

Platform-Specific Hardware Error Driver

Plug-in

 

Hardware/Firmware (UEFI/ACPI)

 

**Figure 17.5:** WHEA Overview

 

The layout of the UEFI standardized error record format used by WHEA is illustrated

in Figure 17.6.

**280** \| Chapter 17 – Manageability

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-299_1.png)

 

**Figure 17.6:** UEFI Standard Error Record Format

 

Some of the standard error sources and global controls covered by WHEA/UEFI are as described in Table 17.1.

 

**Table 17.1:** Standard Error Sources and Global Controls Covered by WHEA/UEFI

 

Error Sources System Interrupts and Exceptions: NMI, MCE, MCA, CMCI, PCIe, CPEI, SCI,

INTx, BOOT

 

Standard Error For- Processor, Platform Memory, PCIe, PCI/PCI-X Bus, PCI Component mats

 

It is beyond the scope of this chapter to go into the details of the dynamic error han-

dling flow. However, Figure 17.7 provides an overview of the error handling involving the firmware and OS components.

Technology Intercepts: UEFI, IPMI, Intel® AMT, WS-MAN \| **281**

 

Uncorrected/Corrected

Hardware Error Event

 

OS Logs Errors &

Running OS

Continues

Processing Options:

1. Error Collection

from platform

2. Error Correction No Error Event

Attempt (ex: Memory Valid Error Event

Migration, Mirroring Error Interrupt Handler Polling Poll for Corrected 4. Error Recovery Invoked

Attempt Errors in Hardware or

3. Predictive Failure Firmware

Analysis

4. Messaging to

Management

Console

5. Other OEM actions Errors Found Handler OS Error

 

Hardware Access

Firmware API Error Logging?

Policy Enabled

Interface Enabled

 

Through Direct

Firmware Error

Architectural

Handler Interface

Register Access

Yes

OS Error

Handling

Successful

 

No

 

Reboot

 

**Figure 17. 7:** Generic Error Handling Flow

 

**Technology Intercepts: UEFI, IPMI, Intel® AMT, WS-MAN**

 

The following sections delve into various other management technologies that relate to UEFI and how these all can interoperate.

 

**Intelligent Platform Management Interface (IPMI)**

 

IPMI is a hardware level interface specification that is “management software neu-tral” providing monitoring and control functions for server platforms, that can be exposed through standard management software interfaces such as DMI, WMI,

CIM, SNMP, and HPI. IPMI defines common, abstracted, message-based interfaces **282** \| Chapter 17 – Manageability

 

between diverse hardware devices and the CPU. IPMI also defines common sensors for describing the characteristics of such devices, which are used to monitor out-of-

band functions like fan/heat sink failures, and intrusion detection. Each platform

vendor offers differentiation through their own platform hardware implementation to support IPMI, typically implemented with an embedded baseboard microcontrol-ler (BMC) and the associated firmware with a set of event sensors, as shown in Fig-

ure 17.8.

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-301_1.png)

 

**Figure 17.8:** Typical IPMI Platform Implementation

 

IPMI has defined a set of standard sensors, which would monitor different platform

functions and generate events and report them through the system event log interface (SEL) as 16-byte error log entries. Each of the sensors in turn is associated with Senor

Data Record (SDR), which describes the properties of the sensor, to let the managea-bility software discover its capability, configurability and controllability and the error

record associated with it. A set of predefined controls for use by manageability soft-ware is also defined by the IPMI specification, in addition to other OEM-defined con-trols through SDR. The standard sensors along with the standard controls do allow a

level of standardization for managing these out-of-band errors. Some of the standard

sensor and global controls are captured below in Table 17.2.

Technology Intercepts: UEFI, IPMI, Intel® AMT, WS-MAN \| **283**

 

**Table 17.2:** IPMI Standard Sensor and Global Controls

 

Sensors Temp, Voltage, Current, Processor, Physical Security, Platform Security, Proces-

sor, Power Supply, Power Unit, Cooling, Memory, Drive Slot, BIOS POST, Watch Dog, System Event, Critical Interrupt, Button/Switch, Add in Card, Chassis, Chip-set, FRU, Cable, System Reboot, Boot Error, OS Boot, OS Crash, ACPI Power State, LAN, Platform Alert, Battery, Session Audit

 

Global Control Cold Reset, Warm Reset, Set ACPI State

 

**Intel® Active Management Technology (Intel AMT)**

 

Intel AMT can be viewed as an orthogonal solution to IPMI and was originally devel-oped with capabilities for client system manageability by IT personnel in mind, as

opposed to server manageability. However, Intel AMT is making its way into the em-bedded and network appliance market segments like point of sale terminals, print

imaging, and digital signage. Intel AMT is a hardware- and firmware-based solution connected to the system’s auxiliary power plane, providing IT administrators with

“any platform state” access. Figure 17.9 provides an illustration of Intel AMT’s archi-tecture. Intel AMT enables secure, remote management of systems through unique

built-in capabilities, including:

■ OOB management that provides a direct connection to the Intel AMT subsystem,

either through the operating system’s network connection or via its TCP/IP firm-

ware stack.

■ Nonvolatile memory that stores hardware and software information, so IT staff

can discover assets even when end-user systems are powered off, using the OOB

channel.

■ System defense featuring inbound and outbound filters, combined with presence

detection of critical software agents, protects against malware attacks, and so on.

 

The most recent versions of the Intel AMT are DASH-compliant and facilitate interop-erability with remote management consoles that are DASH-compliant.

**284** \| Chapter 17 – Manageability

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-303_1.png)

 

**Figure 17.9:** Intel® AMT Architecture Stack

 

Intel AMT offering includes Manageability Engine hardware with the associated firm-

ware, which is integrated onto silicon as building blocks such as IOH or PCH. Intel AMT allows users to remotely perform power functions, launch a serial over LAN ses-

sion to access a system's BIOS and enable IDE-Redirect to boot a system from a floppy, image, or CD/DVD device installed within the central monitor. Some of the key ser-

vices provided through Intel AMT are as shown in Table 17.3.

 

**Table 17.3:** Key Services Provided through Intel® AMT

 

Services Security Administration Interface, Network Administration Interface, Hardware

Asset Interface, Remote Control Interface, Storage Interface, Event Manage-ment Interface, Storage Administration Interface, Redirection Interface, Local Agent Presence Interface, Circuit Breaker Interface, Network Time Interface, General Info. Interface, Firmware Update Interface

 

Global Control Cold Reset, Warm Reset, Power Up and Down, Set Power/ACPI State, Change

ACL, Retrieve Hardware/Software Inventory, Firmware Update, Set Clock, Set Firewall Configuration, Configure Platform Events for Alert and Logging

 

Like IPMI, one of the key interfaces of Intel AMT is event management, which allows configuring hardware and software events to generate alerts and to send them to a

remote console and/or log them locally.

Technology Intercepts: UEFI, IPMI, Intel® AMT, WS-MAN \| **285**

 

**Web Services Management Protocol (WS-MAN)**

 

The growth and success of enterprise businesses hinges heavily on the ability to con-

trol costs while expanding IT resources. WS-Management addresses the cost and complexity of IT management by providing a common way for systems to access and exchange management information across the entire IT infrastructure. By using Web

services to manage IT systems, deployments that support WS-Management will ena-ble IT managers to remotely access devices on their networks—everything from sili-

con components and handheld devices to PCs, servers, and large-scale data centers. WS-Management is an open standard defining a SOAP-based protocol for the man-

agement of remote systems, as illustrated in Figure 17.10.

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-304_1.png)

 

**Figure 17.10:** WS-MAN Management Build Blocks Overview

 

All desktop, mobile, and server implementations that are compliant with DASH and support WS-MAN can be remotely managed over the same infrastructure like the

management console applications.

 

**Other Industry Initiatives**

 

The Distributed Management Task Force, Inc. (DMTF) is the industry organization

leading the development, adoption, and promotion of interoperable management in-

**286** \| Chapter 17 – Manageability

 

itiatives and standards. DMTF management technologies include the Common Diag-nostic Model (CDM) initiative, the Desktop Management Interface (DMI), the System

Management BIOS (SMBIOS), the Systems Management Architecture for Server Hard-

ware (SMASH) initiative, Web-Based Enterprise Management (WBEM)—including protocols such as CIM-XML and Web Services for Management (WS-Management)— which are all based on the Common Information Model (CIM). Information about the

DMTF technologies and activities can be found at www.dmtf.org.

 

**The UEFI/IPMI/Intel® AMT/WS-MAN Bridge**

 

This part of the analysis brings out the way these different management technologies

and interfaces can be bridged together, either with the already available hooks in

them or with some yet-to-be-defined extensions, as illustrated in Figure 17.11.

The previous section discussed the UEFI industry standard specification covering the common error formats for in-band errors and how manageability software run-

ning on top of the OS can take immediate corrective action through the abstracted interface. However, the common event log format for out-of-band errors is not cov-

ered by UEFI, but is left to the individual platform vendors to implement through ei-ther IPMI or Intel AMT interfaces.

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-305_1.png)

 

**Figure 17.11:** Management Build Blocks Linking IPMI, HPI, UEFI, and WHEA

The UEFI/IPMI/Intel® AMT/WS-MAN Bridge \| **287**

 

**IPMI Error Records to UEFI**

 

UEFI can act as a conduit for all the SEL event log information for out-of-band errors

logged by IPMI and provide it to UEFI, encapsulated as a UEFI standardized OEM-specific error format to the OS. This requires a private platform-specific interface be-tween UEFI and the IPMI firmware layers for exchange of this information. It is also

possible for the UEFI to extend and define yet another error format for IPMI SEL logs identified with a new GUID. This way, an OS or manageability application would be

able to get complete platform errors for in-band and out-of-band errors in a standard-ized format through one single UEFI-based interface. UEFI can intercept the IPMI sen-

sor events through the firmware first model as defined by Microsoft WHEA and pro-vide the SEL logs to the OS. This type of extension can be modeled along the Itanium

Processor Machine Check Architecture specification for IPMI error logging and is an area of opportunity of future standardization effort.

 

**UEFI Error Records to IPMI**

 

The IPMI has already defined standard event sensors like Processor, Memory, System Event, Chipset and Platform Alert. It is also possible to define a new UEFI or WHEA

sensor type for IPMI and channel the UEFI defined standard error formatted infor-mation over to IPMI, encapsulated as OEM-specific data of a variable size. IPMI SEL

log size is currently defined to be 16-bytes and hence would require a change in IPMI specification to support variable size SEL log size. This way, a remote or local man-

ageability application would be able to get complete in-band and out-of-band error information through one single IPMI.

 

**Intel® AMT and IPMI**

 

These two interfaces, which were defined with different usage models in mind, do have an overlap in functionality. Intel AMT defines an entire hardware and firmware

framework for client system management, while IPMI only defined the firmware in-terface without any hardware support for server system manageability. IPMI can be

implemented on the hardware needed for Intel AMT if the ME hardware becomes a standard feature on all Intel solutions or chipsets.

**288** \| Chapter 17 – Manageability

 

**Future Work**

 

Table 17.4 shows the four areas of potential work for standardization that offers inter-

esting possibilities:

■ Bridge over the Intel AMT/IPMI functionality over to the UEFI-OS error reporting ■ Bridge over of the OS-UEFI error management over to the Intel AMT/IPMI func-

tionality

■ Manageability application leveraging from WS-MAN or other similar abstracted

interfaces with a unified error reporting and management for the entire platform,

either obtained through the OS or Intel AMT/IPMI

 

**Table 17.4:** Manageability and error management standards and possible future work.

 

Error Management Feature UEFI/WHEA IPMI AMT WS-MAN

 

Bridging Over Possibilities IPMI/AMT AMT IPMI UEFI/WHEA

 

**Configuration Namespace**

 

The UEFI platform configuration infrastructure has been designed to facilitate the ex-traction of meaningful configuration data whether manually or via a programmatic

(script-based) mechanism. By discerning meaning from what might otherwise be opaque data objects, the UEFI platform configuration infrastructure makes it possible

to manage the configuration of both motherboard-specific as well as add-in device configuration settings.

 

**Associating meaning with a question**

To achieve programmatic configuration each configuration-related IFR op-code must be capable of being associated with some kind of meaning (e.g. “Set iSCSI Initiator

Name”).

Below is an illustration that depicts an EFI_IFR_QUESTION_HEADER. Each con-

figuration-related IFR op-code is preceded with such a header, and the 3rd byte in the structure is highlighted because it becomes the lynchpin upon which meaning can be

associated to the op-code.

Configuration Namespace \| **289**

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-308_1.png)

 

**Figure 17.12:** Sample IFR Op-code encoding

 

**Prompt Token and a new language**

Given that for every configurable registered item in the HII Database (see EFI_HII_DA-TABASE_PROTOCOL) there will at least exist a set of IFR forms and a corresponding

set of strings. Think of the IFR forms as a web page, each of which is represented by an IFR op-code. These pairs of op-codes and strings are sufficient to contain all the

metadata required for a browser or a programmatic component (e.g. driver, script, etc.) to render a UI or configure a component in the platform.

Since another inherent feature of the UEFI configuration infrastructure is localiza-tion, each of the IFR op-codes make references to their related strings via a Token ab-

straction. This allows a reference to a string (e.g. Token \#22) to be language agnostic.

Within the HII database, multiple sets of strings can be registered such that any

given component might support one or more languages. These languages typically are associated with user-oriented translations such as Chinese, English, Spanish, etc.

Given this inherent capability to associate op-codes with strings, it should also be mentioned that for a registered HII component (handle), each of the Prompt Token

numbers are required to be unique if they are to be correctly managed or script-ena-bled. To be clear, this doesn’t mean that each Prompt Token must be globally unique

across the entire HII database, it must be unique within the scope of the HII handle being referenced.

There is a concept introduced in 29.2.11.2 (Working with a UEFI Configuration Language) that speaks of a language that isn’t intended to be displayed or user visi-

ble. This is a key concept that allows data to be seamlessly introduced into the HII database content without perturbing the general flow or design of any existing IFR.

Below is an illustration which demonstrates the use of the x-UEFI-ns language. It is defined as the platform configuration language used by this specification and the

keyword namespace further defined in this registry.

In the example, we have an English (as spoken in the US) string, a Spanish (as

spoken in Mexico) string, and a UEFI platform configuration string. The latter string’s value is “iSCSIInitiatorName” and this keyword is an example of what would be the interoperability used to manage and extract meaning from the configuration

metadata in the platform.

**290** \| Chapter 17 – Manageability

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-309_1.png)

 

**Figure 17.13**

 

For example, a utility (or administrator) may query the platform to determine if a plat-form has exposed “iSCSIInitiatorName” within the configuration data. Normally,

there would be no programmatic way of determining whether this platform contained this data object by simply examining the op-codes. However, with a namespace defi-

nition in place, a program can do the following to solve this issue: 1. Collect a list of all of the HII handles maintained by the HII database.

2\. For each of the registered HII database entries, look to see if any strings are reg-

istered within the x-UEFI-ns language name.

a\. If so, look for a string match of “iSCSIInitiatorName” in any of the strings for

a particular HII handle

i\. If none are found, go to the next HII handle and execute 2a again. ii. If there are no more HII handles, then this platform doesn’t currently ex-

pose “iSCSIInitiatorName” as a programmatically manageable object.

3\. If a match is found, then note the String Token value (e.g. 4).

4\. Proceed to search through that HII handle’s registered IFR forms for a configura-

tion op-code that has a matching Prompt Token value (e.g. 4).

5\. Once discovered, the configuration op-code contains all of the information need-

ed to understand where that iSCSI Initiator Name information is stored.

a\. This allows a program to optionally extract the current settings as well as op-

tionally set the current settings.

 

Even though the above steps are an illustration of what one might have to do to ex-

tract the information necessary to match a Keyword to its associated value, there are

Configuration Namespace \| **291**

 

facilities defined in the EFI_HII_CONFIG_ROUTING_PROTOCOL, and more specifi-cally the ExtractConfig() and RouteConfig() functions to facilitate the getting and set-

ting of keyword values.

 

**Software Layering**

Below is an illustration which shows a common sample implementation’s interaction

between agents within a UEFI-enabled platform. Some implementations may vary on the exact details.

1\. Any application which wants to get or set any of the values abstracted by a key-

word can interact with the API’s that are defined within the UEFI specification. It

would be the responsibility of this application to construct and interpret keyword

strings that are passed or returned from the API’s.

2\. An agent within the system will expose the EFI_CONFIG_KEYWORD_HANDLER\_

PROTOCOL interface with its GetData() and SetData() functions. These services

will interact both with the application that called it and the underlying routing

routines within the system.

3\. The EFI_HII_CONFIG_ROUTING_PROTOCOL is intended to act as a mechanism

by configuration reading or writing directives are proxied to and from the appro-

priate underlying device(s) that have exposed configuration access abstractions. 4. Configurable items in the platform will expose an EFI_HII_CONFIG_ACCESS\_

PROTOCOL interface that allows the setting or retrieving of configuration data. 5. The component in the platform which has exposed configuration access abstrac-

tions.

**292** \| Chapter 17 – Manageability

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-311_1.png)

 

**Figure 17.14**

 

**Namespace Entries**

 

This document establishes the UEFI Platform Configuration language as:

 

**x-UEFI-ns**

The keywords defined in this UEFI Configuration Namespace registry should all be

discoverable within the platform configuration language of “x-UEFI-ns”.

 

**Alternate Storage and Namespaces**

Although this namespace registry deals solely with the keywords associated with the x-UEFI-ns platform configuration namespace, the underlying configuration infra-

structure supports abstractions that encompass alternate x-UEFI-\* namespace us-ages.

 

**x-UEFI-CompanyName**

If a company wanted to expose some additional keywords for their own private use, they must use one of the ID’s referenced in the PNP and ACPI ID Registry.

For example, if Intel wanted to expose some additional settings, they would use: x-UEFI-INTC.

Summary \| **293**

 

**Handling Multi-instance values**

There are some keywords which may support multiple instances. This simply means

that a given defined keyword may be exposed multiple times in the system. Since in-

stance values are exposed as a “:#” (# is a placeholder for a one to four digit decimal number) suffix to the keyword, with the “#” holding the place of an instance value, we typically use that value as a means of directly addressing that keyword. However,

if there are multiple agents in the system exposing a multi-instance keyword, one might see several copies of something like “iSCSIInitiatorName:1” exposed.

Under normal circumstances, an application would interact with the keyword handler protocol to retrieve the keyword it desired via the GetData() function. What

is retrieved would be any instances that match the keyword request.

For instance, when retrieving the iSCSIInitiatorName:1 keyword, the keyword

protocol handler will search for any instances of the keyword and return to the caller what it found.

The illustration below shows an example of the returned keyword string frag-ments based on what the keyword protocol handler discovered.

In the case of iSCSIInitiatorName:1, the illustration shows how multiple control-lers exposed the same keyword and even the same instance values. The response frag-

ments below illustrate how the “PATH=” value would correspond to the device path for a given device and each of those device paths uniquely identify the controller re-

sponding to the request. This gives the caller sufficient information to uniquely adjust a keyword \[via a SetData() call\] by specifying the appropriate device path for the con-

troller in the keyword string.

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-312_1.png)

 

**Figure 17.15**

 

**Summary**

 

In the case of manageability, the UEFI framework will help make platforms more ro-

bust and reliable through remote management interfaces like Intel AMT, and WS-MAN, to meet the RAS goal of five nines. This unified approach would be a win-win **294** \| Chapter 17 – Manageability

 

to all (OEM, IBV, OSV), to deliver a great end user value and experience with a com-plete solution for in-band and out-of-band error and event management.

The net result of the level of abstraction provided by UEFI/WHEA and Intel

AMT/IPMI technologies in security and manageability space will now enable many vendors to develop OS-agnostic unified tools and application software for all embed-ded/client/server platforms. This would allow them to spend their efforts on innova-

tion with a rich set of features at the platform level rather than on developing multiple platform-specific implementations for the same manageability functionality.