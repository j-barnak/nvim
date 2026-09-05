## **Chapter 11 – Boot Device Selection** 

 

I just invent, then wait until man comes around to needing what I invented.

—R. Buckminster Fuller

 

UEFI has over time evolved a very basic paradigm for establishing a firmware policy

engine. The concept was developed from the concept of a single boot manager whose sole purpose was exercising the policy established by some architecturally defined

global NVRAM variables. As the firmware design evolved, and several distinct boot phases such as SEC, PEI, DXE, BDS, Runtime, and Afterlife were defined, the BDS

(Boot Device Selection) phase became a distinct boot manager-like phase. In this chapter, the architectural components that steer the policy of the boot manager are

reviewed. This content forms the architectural basis for what eventually became the BDS phase.

In fact, the differences between what is known as the boot manager in earlier firmware designs and what is known as the BDS in PI-based solutions is easy to illus-

trate. Figure 11.1 shows the software flow in an early firmware design environment, and Figure 11.2 shows one that is PI-compatible.

 

**Exposed**

 

**Vectpr** **Interface** **OS-Absent** **Reset** **Runtime**

**App**

**CPU**

**Init**

**Chipset** **Device,** **Transient OS**

**Init** **Bus, or** **Environment**

**Board** **Service** **Transient OS** **Init** **Driver** **Boot Loader**

 

**Boot Manager** **OS-Present** **App**

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-202_1.png)

 

**Boot Loader** **Final OS** **?** **Final OS**

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-202_2.png)

**Environment**

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-202_3.png)

**Boot Services API Availability**

**Runtime Services API Availability**

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-202_4.png)

**Reset** **Early** **Launch** **Transient** **Run Time** **After** **Vector** **Platform** **EFI** **System Load** **(RT)** **Life**

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-202_5.png)

**Initialization** **Infrastructure** **(TSL)** **(AL)**

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-202_6.png)

**Power on** **\[ . . Platform initialization . . \]** **\[ . . . . OS boot . . . . \]** **Shutdown**

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-202_7.png)

 

**Figure 11.1:** Earlier Firmware Designs with a Boot Manager Component

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-202_8.png)

 

DOI 10.1515/9781501505690-013

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-202_9.png)

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-202_10.png)

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-202_11.png)

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-202_12.png)

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-202_13.png)

**184** \| Chapter 11 – Boot Device Selection

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-203_1.png)

 

**Figure 11.2:** PI-based Solution with a BDS Component

 

As you can see from comparing the two figures, there is much overlap. The BDS phase subsumes the direction described in this chapter and is further explained in Chapter 8.

The UEFI boot manager is a firmware policy engine that can be configured by modifying architecturally defined global NVRAM variables. The boot manager at-

tempts to load UEFI drivers and UEFI applications (including UEFI OS boot loaders) in an order defined by the global NVRAM variables. The platform firmware must use

the boot order specified in the global NVRAM variables for normal boot. The platform firmware may add extra boot options or remove invalid boot options from the boot

order list.

The platform firmware may also implement value-added features in the boot

manager if an exceptional condition is discovered in the firmware boot process. One example of a value-added feature would be not loading an UEFI driver if booting

failed the first time the driver was loaded. Another example would be booting to an OEM-defined diagnostic environment if a critical error was discovered during the boot

process.

 

The boot sequence for UEFI consists of the following: ■ The platform firmware reads the boot order list from a globally defined NVRAM

variable. The boot order list defines a list of NVRAM variables that contain infor-

mation about what is to be booted. Each NVRAM variable defines a Unicode name

for the boot option that can be displayed to a user.

Firmware Boot Manager \| **185**

 

■ The variable also contains a pointer to the hardware device and to a file on that

hardware device that contains the UEFI image to be loaded.

■ The variable might also contain paths to the OS partition and directory along with

other configuration-specific directories.

 

The NVRAM can also contain load options that are passed directly to the UEFI image.

The platform firmware has no knowledge of what is contained in the load options. The load options are set by higher level software when it writes to a global NVRAM

variable to set the platform firmware boot policy. This information could be used to define the location of the OS kernel if it was different than the location of the UEFI OS

loader.

 

**Firmware Boot Manager**

 

The boot manager is a component in the UEFI firmware that determines which UEFI

drivers and UEFI applications should be explicitly loaded and when. Once the UEFI firmware is initialized, it passes control to the boot manager. The boot manager is

then responsible for determining what to load and any interactions with the user that may be required to make such a decision. Much of the behavior of the boot manager

is left up to the firmware developer to decide, and details of boot manager implemen-tation are outside the scope of this specification. Likely implementation options

might include any console interface concerning boot, integrated platform manage-ment of boot selections, possible knowledge of other internal applications or recovery

drivers that may be integrated into the system through the boot manager.

Programmatic interaction with the boot manager is accomplished through glob-

ally defined variables. On initialization, the boot manager reads the values that com-prise all of the published load options among the UEFI environment variables. By us-

ing the SetVariable() function the data that contain these environment variables can be modified.

Each load option entry resides in a Boot#### variable or a Driver#### vari-

able where the \#### is replaced by a unique option number in printable hexadecimal representation using the digits 0–9, and the uppercase versions of the characters A– F (0000–FFFF). The \#### must always be four digits, so small numbers must use

leading zeros. The load options are then logically ordered by an array of option num-bers listed in the desired order. There are two such option ordering lists. The first is

DriverOrder that orders the Driver#### load option variables into their load

order. The second is BootOrder that orders the Boot#### load options variables into their load order.

For example, to add a new boot option, a new Boot#### variable would be

added. Then the option number of the new Boot#### variable would be added to the BootOrder ordered list and the BootOrder variable would be rewritten. To **186** \| Chapter 11 – Boot Device Selection

 

change boot option on an existing Boot####, only the Boot#### variable would need to be rewritten. A similar operation would be done to add, remove, or modify

the driver load list.

If the boot via Boot#### returns with a status of EFI_SUCCESS the boot man-ager stops processing the BootOrder variable and presents a boot manager menu to the user. If a boot via Boot#### returns a status other than EFI_SUCCESS, the

boot has failed and the next Boot#### in the BootOrder variable will be tried until all possibilities are exhausted.

The boot manager may perform automatic maintenance of the database varia-

bles. For example, it may remove unreferenced load option variables, any unpar-seable or unloadable load option variables, and rewrite any ordered list to remove any load options that do not have corresponding load option variables. In addition,

the boot manager may automatically update any ordered list to place any of its own load options where it desires. The boot manager can also, based on its platform-spe-

cific behavior, provide for manual maintenance operations as well. Examples include choosing the order of any or all load options, activating or deactivating load options,

and so on.

The boot manager is required to process the Driver load option entries before the

Boot load option entries. The boot manager is also required to initiate a boot if the boot option specified by the BootNext variable as the first boot option on the next

boot, and only on the next boot. The boot manager removes the BootNext variable

before transferring control to the BootNext boot option. If the boot from the Boot-Next boot option fails, the boot sequence continues utilizing the BootOrder vari-able. If the boot from the BootNext boot option succeeds by returning EFI_SUC-

CESS, the boot manager will not continue to boot utilizing the BootOrder variable.

The boot manager must call LoadImage(), which supports at least SIM-

PLE_FILE_PROTOCOL and LOAD_FILE_PROTOCOL for resolving load options. If LoadImage() succeeds, the boot manager must enable the watchdog timer for 5 minutes by using the SetWatchdogTimer() boot service prior to calling

StartImage(). If a boot option returns control to the boot manager, the boot man-ager must disable the watchdog timer with an additional call to the SetWatchdog-

Timer() boot service.

If the boot image is not loaded via LoadImage(), the boot manager is required to check for a default application to boot. Searching for a default application to boot happens on both removable and fixed media types. This search occurs when the de-

vice path of the boot image listed in any boot option points directly to a SIM-PLE_FILE_SYSTEM device and does not specify the exact file to load. The file discov-

ery method is explained in the section “Default Behavior for Boot Option Variables” later in this chapter. The default media boot case of a protocol other than SIM-

PLE_FILE_SYSTEM is handled by the LOAD_FILE_PROTOCOL for the target device path and does not need to be handled by the boot manager.

Firmware Boot Manager \| **187**

 

The boot manager must also support booting from a short-form device path that starts with the first element being a hard drive media device path. The boot manager

must use the GUID or signature and partition number in the hard drive device path to

match it to a device in the system. If the drive supports the GPT partitioning scheme the GUID in the hard drive media device path is compared with the UniqueParti-tionGuid field of the GUID Partition Entry. If the drive supports the PC-AT MBR

scheme the signature in the hard drive media device path is compared with the UniqueMBRSignature in the Legacy Master Boot Record. If a signature match is made,

then the partition number must also be matched. The hard drive device path can be appended to the matching hardware device path and normal boot behavior can then

be used. If more than one device matches the hard drive device path, the boot man-ager picks one arbitrarily. Thus, the operating system must ensure the uniqueness of

the signatures on hard drives to guarantee deterministic boot behavior.

 

Each load option variable contains an EFI_LOAD_OPTION descriptor that is a byte-packed buffer of variable-length fields. Since some of the fields are of variable length,

an EFI_LOAD_OPTION cannot be described as a standard C data structure. Instead, the fields are listed here in the order that they appear in an EFI_LOAD_OPTION de-

scriptor:

■ UINT32 Attributes;

UINT16 FilePathListLength;

CHAR16 Description\[\];

EFI_DEVICE_PATH FilePathList\[\];

UINT8 OptionalData\[\];

 

■ *Attributes* - The attributes for this load option entry. All unused bits must be zero

and are reserved by the UEFI specification for future growth. See “Related Defini-

tions.”

■ *FilePathListLength* - Length in bytes of the FilePathList. OptionalData starts at off-

set sizeof(UINT32) + sizeof(UINT16) + StrSize(Description) + FilePathListLength

of the EFI_LOAD_OPTION descriptor.

■ *Description* - The user readable description for the load option. This field ends

with a Null Unicode character.

■ *FilePathList* - A packed array of UEFI device paths. The first element of the array

is an UEFI device path that describes the device and location of the Image for this

load option. The FilePathList\[0\] is specific to the device type. Other device paths

may optionally exist in the FilePathList, but their usage is OSV specific. Each el-

ement in the array is variable length, and ends at the device path end structure.

Because the size of Description is arbitrary, this data structure is not guaranteed

to be aligned on a natural boundary. This data structure may have to be copied

to an aligned natural boundary before it is used.

**188** \| Chapter 11 – Boot Device Selection

 

■ *OptionalData* - The remaining bytes in the load option descriptor are a binary data

buffer that is passed to the loaded image. If the field is zero bytes long, a Null

pointer is passed to the loaded image. The number of bytes in OptionalData can

be computed by subtracting the starting offset of OptionalData from total size in

bytes of the EFI_LOAD_OPTION.

 

**Related Definitions**

 

The load option attributes are defined by the values below.

//

// Attributes

//

\#define LOAD_OPTION_ACTIVE 0x00000001 \#define LOAD_OPTION_FORCE_RECONNECT 0x00000002

 

Calling SetVariable() creates a load option. The size of the load option is the

same as the size of the DataSize argument to the SetVariable() call that cre-

ated the variable. When creating a new load option, all undefined attribute bits must be written as zero. When updating a load option, all undefined attribute bits must be preserved. If a load option is not marked as LOAD_OPTION_ACTIVE, the boot man-

ager will not automatically load the option. This provides an easy way to disable or enable load options without needing to delete and reload them. If any Driver####

load option is marked as LOAD_OPTION_FORCE_RECONNECT, then all of the UEFI

drivers in the system will be disconnected and reconnected after the last Driver#### load option is processed. This allows an UEFI driver loaded with a Driver#### load option to override an UEFI driver that was loaded prior to the ex-

ecution of the UEFI Boot Manager.

 

**Globally-Defined Variables**

 

This section defines a set of variables that have architecturally defined meanings. In

addition to the defined data content, each such variable has an architecturally de-

fined attribute that indicates when the data variable may be accessed. The variables with an attribute of NV are nonvolatile. This means that their values are persistent across resets and power cycles. The value of any environment variable that does not

have this attribute will be lost when power is removed from the system and the state of firmware reserved memory is not otherwise preserved. The variables with an attrib-

ute of BS are only available before ExitBootServices() is called. This means

that these environment variables can only be retrieved or modified in the preboot en-vironment. They are not visible to an operating system. Environment variables with Globally-Defined Variables \| **189**

 

an attribute of RT are available before and after ExitBootServices() is called. Environment variables of this type can be retrieved and modified in the preboot envi-

ronment, and from an operating system. All architecturally defined variables use the

EFI_GLOBAL_VARIABLE VendorGuid:

 

\#define EFI_GLOBAL_VARIABLE \\

{8BE4DF61-93CA-11d2-AA0D-00E098032B8C}

 

To prevent name collisions with possible future globally defined variables, other in-

ternal firmware data variables that are not defined here must be saved with a unique VendorGuid other than EFI_GLOBAL_VARIABLE. Table 11.1 lists the global variables.

 

**Table 11. 1:** Global Variables

 

**Variable Name** **Attribute Description**

 

LangCodes BS, RT The language codes that the firmware supports.

 

Lang NV, BS, RT The language code that the system is configured for.

 

Timeout NV, BS, RT The firmwares boot manager’s timeout, in seconds,

before initiating the default boot selection.

 

ConIn NV, BS, RT The device path of the default input console.

 

ConOut NV, BS, RT The device path of the default output console.

 

ErrOut NV, BS, RT The device path of the default error output device.

 

ConInDev BS, RT The device path of all possible console input devices.

 

ConOutDev BS, RT The device path of all possible console output de-

vices.

 

ErrOutDev BS, RT The device path of all possible error output devices.

 

Boot#### NV, BS, RT A boot load option, where \#### is a printed hex

value. No 0x or h is included in the hex value.

 

BootOrder NV, BS, RT The ordered boot option load list.

 

BootNext NV, BS, RT The boot option for the next boot only.

 

BootCurrent BS, RT The boot option that was selected for the current boot.

 

Driver#### NV, BS, RT A driver load option, where \#### is a printed hex

value.

 

DriverOrder NV, BS, RT The ordered driver load option list.

**190** \| Chapter 11 – Boot Device Selection

 

The LangCodes variable contains an array of 3-character (8-bit ASCII characters) ISO-639-2 language codes that the firmware can support. At initialization time the

firmware computes the supported languages and creates this data variable. Since the

firmware creates this value on each initialization, its contents are not stored in non-volatile memory. This value is considered read-only.

The Lang variable contains the 3-character (8-bit ASCII characters) ISO-639-2

language code for which the machine has been configured. This value may be changed to any value supported by LangCodes; however, the change does not take

effect until the next boot. If the language code is set to an unsupported value, the

firmware chooses a supported default at initialization and sets Lang to a supported value.

The Timeout variable contains a binary UINT16 (unsigned 16-bit value) that

supplies the number of seconds that the firmware waits before initiating the original default boot selection. A value of 0 indicates that the default boot selection is to be

initiated immediately on boot. If the value is not present, or contains the value of 0xFFFF, then firmware waits for user input before booting. This means the default

boot selection is not automatically started by the firmware.

The ConIn, ConOut, and ErrOut variables each contain an EFI_DE-

VICE_PATH descriptor that defines the default device to use on boot. Changes to these values do not take effect until the next boot. If the firmware cannot resolve the device

path, it is allowed to automatically replace the value(s) as needed to provide a console for the system.

The ConInDev, ConOutDev, and ErrOutDev variables each contain an EFI_DEVICE_PATH descriptor that defines all the possible default devices to use on

boot. These variables are volatile, and are set dynamically on every boot. ConIn, ConOut, and ErrOut are always proper subsets of ConInDev, ConOutDev, and

ErrOutDev.

Each Boot#### variable contains an EFI_LOAD_OPTION. Each Boot#### var-iable is the name “Boot” appended with a unique four-digit hexadecimal number. For example, Boot0001, Boot0002, Boot0A02, and so on.

The BootOrder variable contains an array of UINT16s that make up an ordered list of the Boot#### options. The first element in the array is the value for the first

logical boot option, the second element is the value for the second logical boot option,

and so on. The BootOrder order list is used by the firmware’s boot manager as the default boot order.

The BootNext variable is a single UINT16 that defines the Boot#### option

that is to be tried first on the next boot. After the BootNext boot option is tried the normal BootOrder list is used. To prevent loops, the boot manager deletes this var-

iable before transferring control to the preselected boot option.

The BootCurrent variable is a single UINT16 that defines the Boot#### op-tion that was selected on the current boot.

Boot Mechanisms \| **191**

 

Each Driver#### variable contains an EFI_LOAD_OPTION. Each load option variable is appended with a unique number, for example Driver0001,

Driver0002, and so on.

The DriverOrder variable contains an array of unsigned 16-bit values that make up an ordered list of the Driver#### variable. The first element in the array is the value for the first logical driver load option, the second element is the value for

the second logical driver load option, and so on. The DriverOrder list is used by the firmware’s boot manager as the default load order for UEFI drivers that it should

explicitly load.

 

**Default Behavior for Boot Option Variables**

 

The default state of globally defined variables is firmware vendor specific. However, the boot options require a standard default behavior in the exceptional case that valid boot options are not present on a platform. The default behavior must be invoked any

time the BootOrder variable does not exist or only points to nonexistent boot op-tions.

If no valid boot options exist, the boot manager enumerates all removable UEFI

media devices followed by all fixed UEFI media devices. The order within each group is undefined. These new default boot options are not saved to nonvolatile storage. The boot manager then attempts to boot from each boot option. If the device supports

the SIMPLE_FILE_SYSTEM protocol, then the removable media boot behavior (see the section “Removable Media Boot Behavior”) is executed. Otherwise the firmware at-

tempts to boot the device via the LOAD_FILE protocol.

It is expected that this default boot will load an operating system or a mainte-

nance utility. If this is an operating system setup program it is then responsible for setting the requisite environment variables for subsequent boots. The platform firm-

ware may also decide to recover or set to a known set of boot options.

 

**Boot Mechanisms**

 

UEFI can boot from a device using the SIMPLE_FILE_SYSTEM protocol or the

LOAD_FILE protocol. A device that supports the SIMPLE_FILE_SYSTEM protocol

must materialize a file system protocol for that device to be bootable. If a device does not support a complete file system, it may produce a LOAD_FILE protocol that allows it to create an image directly. The boot manager will attempt to boot using the SIM-

PLE_FILE_SYSTEM protocol first. If that fails, then the LOAD_FILE protocol will be used.

**192** \| Chapter 11 – Boot Device Selection

 

**Boot via Simple File Protocol**

 

When booting via the SIMPLE_FILE_SYSTEM protocol, the FilePath parameter will start

with a device path that points to the device that “speaks” the SIMPLE_FILE_SYSTEM protocol. The next part of the FilePath will point to the file name, including subdirecto-ries that contain the bootable image. If the file name is a null device path, the file name

must be discovered on the media using the rules defined for removable media devices with ambiguous file names (see the section "Removable Media Boot Behavior").

The format of the file system specified by UEFI is contained in the UEFI specifica-tion. While the firmware must produce a SIMPLE_FILE_SYSTEM protocol that under-

stands the UEFI file system, any file system can be abstracted with the SIM-PLE_FILE_SYSTEM protocol interface.

 

**Removable Media Boot Behavior**

On a removable media device, it is not possible for the FilePath to contain a file name including subdirectories. The FilePath is stored in nonvolatile memory in the platform

and cannot possibly be kept in sync with a media that can change at any time. A FilePath for a removable media device will point to a device that “speaks” the SIM-

PLE_FILE_SYSTEM protocol. The FilePath will not contain a file name or subdirectories.

The system firmware will attempt to boot from a removable media FilePath by

adding a default file name in the form \EFI\BOOT\BOOT{*machine type short-**name*}.EFI. Where *machine type short-name* defines a PE32+ image format architec-

ture. Each file only contains one UEFI image type, and a system may support booting from one or more images types. Table 11.2 lists the UEFI image types.

 

**Table 11.2:** UEFI Image Types

 

**Architecture** **File name convention** **PE Executable machine type\***

 

IA-32 BOOTIA32.EFI 0x14c

 

x64 BOOTx64.EFI 0x8664

 

Itanium® architecture BOOTIA64.EFI 0x200

 

ARM† architecture BOOTARM.EFI 0x01c2

 

Note: The PE Executable machine type is contained in the machine field of the COFF

file header as defined in the Microsoft Portable Executable and Common Object File Format Specification, Revision 6.0.

A media may support multiple architectures by simply having a \EFI\BOOT\\ BOOT{*machine type short-name*}.EFI file of each possible machine type. Boot Mechanisms \| **193**

 

**Non-removable Media Boot Behavior**

On a non-removable media device, it is possible for the FilePath to contain a file name

including subdirectories. The FilePath will be used for the boot target and the plat-

form will launch the target according to normal system policy.

The platform policy will leverage the BOOT#### variables referenced by the BootOrder variable in the system. These BOOT#### variables are the ones which con-

tain the FilePath data for the boot target and are what typically are used for the boot process to occur.

 

**Boot via LOAD_FILE Protocol**

 

When booting via the LOAD_FILE protocol, the FilePath is a device path that points to a device that “speaks” the LOAD_FILE protocol. The image is loaded directly from

the device that supports the LOAD_FILE protocol. The remainder of the FilePath con-tains information that is specific to the device. UEFI firmware passes this device-spe-

cific data to the loaded image, but does not use it to load the image. If the remainder of the FilePath is a null device path it is the loaded image's responsibility to imple-

ment a policy to find the correct boot device.

The LOAD_FILE protocol is used for devices that do not directly support file sys-

tems. Network devices commonly boot in this model where the image is materialized without the need of a file system.

 

**Network Booting**

Network booting is described by the Preboot eXecution Environment (PXE) BIOS Sup-port Specification that is part of the Wired for Management Baseline specification.

PXE specifies UDP, DHCP, and TFTP network protocols that a booting platform can use to interact with an intelligent system load server. UEFI defines special interfaces

that are used to implement PXE. These interfaces are contained in the PXE_BASE_CODE protocol defined in the UEFI specification.

 

**Future Boot Media**

Since UEFI defines an abstraction between the platform and the operating system and

its loader it should be possible to add new types of boot media as technology evolves. The OS loader will not necessarily have to change to support new types of boot. The

implementation of the UEFI platform services may change, but the interface will re-main constant. The operating system will require a driver to support the new type of

boot media so that it can make the transition from UEFI boot services to operating system control of the boot media.

**194** \| Chapter 11 – Boot Device Selection

 

**Summary**

 

In conclusion, this chapter indicates the mechanism by which a UEFI compliant sys-tem determines what the boot target(s) is and in what order such execution would

occur. This methodology also provides a cooperative mechanism that is highly exten-

sible and that third parties (such as an OS vendor) can use for their own installation and execution.