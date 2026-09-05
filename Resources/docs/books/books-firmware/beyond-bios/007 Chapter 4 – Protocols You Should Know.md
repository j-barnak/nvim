## **Chapter 4 – Protocols You Should Know** 

 

 

Common sense ain’t common.

—Will Rogers

 

This chapter describes protocols that everyone who is working with the Unified Exten-

sible Firmware Interface (UEFI), whether creating device drivers, UEFI pre-OS applica-tions, or platform firmware, should know. The protocols are illustrated by a few exam-

ples, beginning with the most common exercise from any programming text, namely “Hello world.” The test application listed here is the simplest possible application that

can be written. It does not depend upon any UEFI Library functions, so the UEFI Li-brary is not linked into the executable that is generated. This test application uses the

*SystemTable* that is passed into the entry point to get access to the UEFI console devices. The console output device is used to display a message using the Out-

putString() function of the SIMPLE_TEXT_OUTPUT_INTERFACE protocol, and the application waits for a keystroke from the user on the console input device

using the WaitForEvent() service with the *WaitForKey* event in the SIM-PLE_INPUT_INTERFACE protocol. Once a key is pressed, the application exits.

 

/\*++

 

Module Name:

helloworld.c

 

Abstract:

This is a simple module to display behavior of a basic UEFI application.

 

Author:

Waldo

 

Revision History

--\*/

 

\#include "efi.h"

 

EFI_STATUS

InitializeHelloApplication (

IN EFI_HANDLE ImageHandle,

IN EFI_SYSTEM_TABLE \*SystemTable

)

{

UINTN Index;

 

DOI 10.1515/9781501505690-006

**54** \| Chapter 4 – Protocols You Should Know

 

//

// Send a message to the ConsoleOut device.

//

 

SystemTable-\>ConOut-\>OutputString (

SystemTable-\>ConOut,

L"Hello application started\n\r");

 

//

// Wait for the user to press a key.

//

 

SystemTable-\>ConOut-\>OutputString (

SystemTable-\>ConOut,

L"\n\r\n\r\n\rHit any key to exit\n\r");

 

SystemTable-\>BootServices-\>WaitForEvent (

1,

&(SystemTable-\>ConIn-\>WaitForKey),

&Index);

 

SystemTable-\>ConOut-\>OutputString (

SystemTable-\>ConOut,L"\n\r\n\r");

 

//

// Exit the application.

//

 

return EFI_SUCCESS;

}

 

To execute an UEFI application, type the program’s name at the UEFI Shell command line. The following examples show how to run the test application described above

from the UEFI Shell. The application waits for the user to press a key before returning

to the UEFI Shell prompt. It is assumed that hello.efi is in the search path of the UEFI Shell environment.

 

**Example**

Shell\> hello

 

Hello application started

 

Hit any key to exit this image

EFI OS Loaders \| **55**

 

**EFI OS Loaders**

 

This section discusses the special considerations that are required when writing an OS loader. An *OS loader* is a special type of UEFI application responsible for transi-

tioning a system from a firmware environment into an OS environment. To accom-

plish this task, several important steps must be taken: 1. The OS loader must determine from where it was loaded. This determination al-

lows an OS loader to retrieve additional files from the same location.

2\. The OS loader must determine where in the system the OS exists. Typically, the

OS resides on a partition of a hard drive. However, the partition where the OS

exists may not use a file system that is recognized by the UEFI environment. In

this case, the OS loader can only access the partition as a block device using only

block I/O operations. The OS loader will then be required to implement or load

the file system driver to access files on the OS partition.

3\. The OS loader must build a memory map of the physical memory resources so

that the OS kernel can know what memory to manage. Some of the physical

memory in the system must remain untouched by the OS kernel, so the OS loader

must use the UEFI APIs to retrieve the system’s current memory map.

4\. An OS has the option of storing boot paths and boot options in nonvolatile stor-

age in the form of environment variables. The OS loader may need to use some of

the environment variables that are stored in nonvolatile storage. In addition, the

OS loader may be required to pass some of the environment variables to the OS

kernel.

5. The next step is to call ExitBootServices(). This call can be done from ei-

ther the OS loader or from the OS kernel. Special care must be taken to guarantee

that the most current memory map has been retrieved prior to making this call.

Once ExitBootServices() had been called, no more UEFI Boot Services

calls can be made. At some point, either just prior to calling Exit-

BootServices() or just after, the OS loader will transfer control to the OS

kernel.

6. Finally, after ExitBootServices() has been called, the UEFI Boot Services

calls are no longer available. This lack of availability means that once an OS ker-

nel has taken control of the system, the OS kernel may only call UEFI Runtime

Services.

 

A complete listing of a sample application for an OS loader can be found below. The code fragments in the following sections do not perform any error checking. Also, the OS loader sample application makes use of several UEFI Library functions to simplify

the implementation.

The output shown below starts by printing out the device path and the file path

of the OS loader itself. It also shows where in memory the OS loader resides and how

many bytes it is using. Next, it loads the file OSKERNEL.BIN into memory. The file **56** \| Chapter 4 – Protocols You Should Know

 

OSKERNEL.BIN is retrieved from the same directory as the image of the OS loader sample of Figure 4.1.

 

**OPERATING SYSTEM**

 

**Legacy OS LOADER** **EFI OS LOADER** **EFI API** **EFI API** **EFI API**

 

**Framework** **Me** **RUNTIME** **Ti** **Boot** **EFI 1.10 or** **SERVICES** **mo** **Compatibility** **EFI BOOT SERVICES** **EFI**

![](/tmp/audit/iter1/epubregen/beyond-bios/media/index-75_1.png)

 

**(OTHER)** **ry** **m** **Devices** **Framework** **Driver** **er** **Driver** **Protocols +** **Drivers** **Handlers**

**SMBIOS**

**ACPI** **PLATFORM SPECIFIC FIRMWARE**

**INTERFACES**

 

**REQUIRED** **OTHER** **FROM** **PLATFORM HARDWARE** **EFI SYSTEM** **OS PARTITION** **Motherboard** **PARTITION** **Option** **Option** **SPECS** **ROM/FLASH** **Option** **EFI 1.10** **ROM** **ROM** **Drivers** **EFI 1.10** **ROM** **Drivers** **EFI 1.10** **EFI OS** **Drivers** **Loader**

 

**Figure 4.1:** EFI Loader in System Diagram

 

The next section of the output shows the first block of several block devices. The first one is the first block of the floppy drive with a FAT12 file system. The second one is

the Master Boot Record (MBR) from the hard drive. The third one is the first block of a large FAT32 partition on the same hard drive, and the fourth one is the first block of a

smaller FAT16 partition on the same hard drive.

The final step shows the pointers to all the system configuration tables, the sys-

tem’s current memory map, and a list of all the system’s environment variables. The very last step shown is the OS loader calling ExitBootServices().

 

**Device Path and Image Information of the OS Loader**

 

The following code fragment shows the steps that are required to get the device path and file path to the OS loader itself. The first call to HandleProtocol() gets

the LOADED_IMAGE_PROTOCOL interface from the *ImageHandle* that was passed into the OS loader application. The second call to HandleProtocol() gets

the DEVICE_PATH_PROTOCOL interface to the device handle of the OS loader im-age. These two calls transmit the device path of the OS loader image, the file path,

and other image information to the OS loader itself.

Accessing Files in the Device Path of the OS Loader \| **57**

 

BS-\>HandleProtocol(

ImageHandle,

&LoadedImageProtocol,

LoadedImage

);

 

BS-\>HandleProtocol(

LoadedImage-\>DeviceHandle,

&DevicePathProtocol,

&DevicePath

);

 

Print (

L"Image device : %s\n",

DevicePathToStr (DevicePath)

);

 

Print (

L"Image file : %s\n",

DevicePathToStr (LoadedImage-\>FilePath)

);

 

Print (

L"Image Base : %X\n",

LoadedImage-\>ImageBase

);

 

Print (

L"Image Size : %X\n",

LoadedImage-\>ImageSize

);

 

**Accessing Files in the Device Path of the OS Loader**

 

The previous section shows how to retrieve the device path and the image path of the OS loader image. The following code fragment shows how to use this information to

open another file called OSKERNEL.BIN that resides in the same directory as the OS loader itself. The first step is to use HandleProtocol() to get the FILE_SYS-

TEM_PROTOCOL interface to the device handle retrieved in the previous section.

Then, the disk volume can be opened so file access calls can be made. The end result is that the variable *CurDir* is a file handle to the same partition in which the OS loader resides.

**58** \| Chapter 4 – Protocols You Should Know

 

BS-\>HandleProtocol(

LoadedImage-\>DeviceHandle,

&FileSystemProtocol,

&Vol

);

 

Vol-\>OpenVolume (

Vol,

&RootFs

);

 

CurDir = RootFs;

 

The next step is to build a file path to OSKERNEL.BIN that exists in the same direc-tory as the OS loader image. Once the path is built, the file handle *CurDir* can be

used to call Open(), Close(), Read(), and Write() on the OSKERNEL.BIN file. The following code fragment builds a file path, opens the file, reads it into an

allocated buffer, and closes the file.

 

StrCpy(FileName,DevicePathToStr(LoadedImage-\>FilePath));

for(i=StrLen(FileName);i\>=0 && FileName\[i\]!='\\';i--);

 

FileName\[i\] = 0;

 

StrCat(FileName,L"\\OSKERNEL.BIN");

CurDir-\>Open (CurDir, &FileHandle, FileName, EFI_FILE_MODE_READ, 0);

Size = 0x00100000;

BS-\>AllocatePool(EfiLoaderData, Size, &OsKernelBuffer);

 

FileHandle-\>Read(FileHandle, &Size,

OsKernelBuffer);

 

FileHandle-\>Close(FileHandle);

 

**Finding the OS Partition**

 

The UEFI sample environment materializes a BLOCK_IO_PROTOCOL instance for every partition that is found in a system. An OS loader can search for OS partitions by looking at all the BLOCK_IO devices. The following code fragment uses LibLo-

cateHandle() to get a list of BLOCK_IO device handles. These handles are then

Finding the OS Partition \| **59**

 

used to retrieve the first block from each one of these BLOCK_IO devices. The HandleProtocol() API is used to get the DEVICE_PATH_PROTOCOL and

BLOCK_IO_PROTOCOL instances for each of the BLOCK_IO devices. The variable

*BlkIo* is a handle to the BLOCK_IO device using the BLOCK_IO_PROTOCOL in-terface. At this point, a ReaddBlocks() call can be used to read the first block of a device. The sample OS loader just dumps the contents of the block to the display. A

real OS loader would have to test each block read to see if it is a recognized partition. If a recognized partition is found, then the OS loader can implement a simple file sys-

tem driver using the UEFI API ReadBlocks() function to load additional data from

that partition.

 

NoHandles = 0;

 

HandleBuffer = NULL;

LibLocateHandle(ByProtocol, &BlockIoProtocol, NULL, &NoHandles, &HandleBuffer);

for(i=0;i\<NoHandles;i++) {

BS-\>HandleProtocol (

HandleBuffer\[i\],

&DevicePathProtocol,

&DevicePath

);

BS-\>HandleProtocol (

HandleBuffer\[i\],

&BlockIoProtocol,

&BlkIo

);

Block = AllocatePool (BlkIo-\>BlockSize);

 

MediaId = BlkIo-\>MediaId;

BlkIo-\>ReadBlocks(

BlkIo,

MediaId,

(EFI_LBA)0,

BlkIo-\>BlockSize,

Block

);

Print(

L"\nBlock \#0 of device

%s\n",DevicePathToStr(DevicePath));

DumpHex(0,0,BlkIo-\>BlockSize,Block);

 

}

**60** \| Chapter 4 – Protocols You Should Know

 

**Getting the Current System Configuration**

 

The system configuration is available through the *SystemTable* data structure that is passed into the OS loader. The operating system loader is an UEFI application that

is responsible for bridging the gap between the platform firmware and the operating

system runtime. The System Table informs the loader of many things: the services available from the platform firmware (such as block and console services for loading the OS kernel binary from media and interacting with the user prior to the OS drivers

are loaded, respectively) and access to industry standard tables like ACPI, SMBIOS, and so on. Five tables are available, and their structure and contents are described in

the appropriate specifications.

 

LibGetSystemConfigurationTable(

&AcpiTableGuid,&AcpiTable

);

LibGetSystemConfigurationTable(

&SMBIOSTableGuid,&SMBIOSTable

);

LibGetSystemConfigurationTable(

&SalSystemTableGuid,&SalSystemTable

);

LibGetSystemConfigurationTable(

&MpsTableGuid,&MpsTable

);

 

Print(

L" ACPI Table is at address :

%X\n",AcpiTable

);

 

Print(

L" SMBIOS Table is at address :

%X\n",SMBIOSTable

);

Print(

L" Sal System Table is at address :

%X\n",SalSystemTable

);

 

Print(

L" MPS Table is at address :

%X\n",MpsTable

);

Getting the Current Memory Map \| **61**

 

**Getting the Current Memory Map**

 

One UEFI Library function can retrieve the memory map maintained by the UEFI en-vironment. While the loader is running, the memory has been managed by the plat-

form firmware. It has allocated memory for both firmware usage (boot services

memory) and other memory that needs to persist into the OS runtime (runtime memory). Until the loader passes final control to the OS kernel and invokes Exit-BootServices() , the UEFI platform firmware manages the allocation of memory.

The means by which the OS loader and other UEFI applications can ascertain the al-location of memory is via the memory map services. The following code fragment

shows the use of this function to ascertain the memory map, and it displays the con-

tents of the memory map. An OS loader must pay special attention to the *MapKey* parameter. Every time that the UEFI environment modifies the memory map that it maintains, the *MapKey* is incremented. An OS loader needs to pass the current

memory map to the OS kernel. Depending on what functions the OS loader calls be-tween the time the memory map is retrieved and the time that Exit-

BootServices() is called, the memory map may be modified. In general, the OS

loader should retrieve the memory map just before calling ExitBootServices(). If ExitBootServices() fails because the *MapKey* does not match, then the OS loader must get a new copy of the memory map and try again.

 

MemoryMap = LibMemoryMap(

&NoEntries,

&MapKey,

&DescriptorSize,

&DescriptorVersion

);

 

Print(

L"Memory Descriptor List:\n\n"

);

 

Print(

L" Type Start Address End Address

Attributes \n"

);

Print(

L" ========== ================

================ ================\n");

 

MemoryMapEntry = MemoryMap;

 

for(i=0;i\<NoEntries;i++) {

Print(L" %s %lX %lX %lX\n", **62** \| Chapter 4 – Protocols You Should Know

 

OsLoaderMemoryTypeDesc\[MemoryMapEntry-

\>Type\],

MemoryMapEntry-\>PhysicalStart,

MemoryMapEntry-\>PhysicalStart +

LShiftU64(

MemoryMapEntry-\>NumberOfPages,

PAGE_SHIFT)-1,

MemoryMapEntry-\>Attribute

);

MemoryMapEntry = NextMemoryDescriptor(

MemoryMapEntry,

DescriptorSize

);

}

 

**Getting Environment Variables**

 

The following code fragment shows how to extract all the environment variables maintained by the UEFI environment. It uses the GetNextVariableName() API

to walk the entire list.

 

VariableName\[0\] = 0x0000;

 

VendorGuid = NullGuid;

 

Print(

L"GUID Variable

Name

Value\n");

Print(

L"===================================

====================

========\n");

do {

VariableNameSize = 256;

Status = RT-\>GetNextVariableName(

&VariableNameSize,

VariableName,

&VendorGuid

);

if (Status == EFI_SUCCESS) {

VariableValue = LibGetVariable(

VariableName,

&VendorGuid

);

Summary \| **63**

 

Print(

L"%.-35g %.-20s

%X\n",&VendorGuid,VariableName,VariableValue

);

}

} while (Status == EFI_SUCCESS);

 

**Transitioning to an OS Kernel**

 

A single call to ExitBootServices() terminates all the UEFI Boot Services that

the UEFI environment provides. From that point on, only the UEFI Runtime Services may be used. Once this call is made, the OS loader needs to prepare for the transition

to the OS kernel. It is assumed that the OS kernel has full control of the system and that only a few firmware functions are required by the OS kernel. These functions are

the UEFI Runtime Services. The OS loader must pass the *SystemTable* to the OS kernel so that the OS kernel can make the Runtime Services calls. The exact mecha-

nism that is used to transition from the OS loader to the OS kernel is implementation-dependent. It is important to note that the OS loader could transition to the OS kernel

prior to calling ExitBootServices(). In this case, the OS kernel would be re-sponsible for calling ExitBootServices() before taking full control of the sys-

tem.

 

**Summary**

 

This chapter has provided an overview of some common protocols and their demon-

stration via a sample operating system loader application. Given that UEFI has been primarily designed as an operating system loader environment, this is a key chapter

for demonstrating the usage and capability of the UEFI service set.

**64** \| Chapter 4 – Protocols You Should Know