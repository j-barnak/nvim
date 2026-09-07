# Linternals: The (Modern) Boot Process \[0x01\]

September 26, 2021

[\#linux](https://sam4k.com/tags/linux/)

[\#kernel](https://sam4k.com/tags/kernel/)



What more appropriate way to kick off a series on Linux internals than figuring out how we actually get those internals running in the first place? This post is going to cover the process that takes us from pressing a power button, to a fully usable Linux operating system.  

As I mentioned in the introduction post for this series, I’m going to focus primarily on modern technologies and implementations where possible. So for this post I’ll be covering how UEFI reads our hard drive’s GPT to figure out how to find our Linux kernel. Once the kernels loaded in memory and ready to go, we look at how it uses systemd to get the operating system up and running in a usable state for us.



Confused? Don’t worry, hopefully by the end of the post you’ll be able to understand that last part, otherwise I need to rethink this whole series thing. Anyway, without further ado let’s jump over to where the magic begins.

**Disclaimer**: as I mentioned in my Linternals introduction, this series aims to strike a middle ground between curious Linux users and system programmers; so as a result of not diving super low, I may miss some nuances of particular hardware/implementations or otherwise generalise more complex topics.

## Contents

- [0x00 GPT](https://sam4k.com/linternals-the-modern-boot-process-part-1/#0x00-gpt)
  - [LBA?](https://sam4k.com/linternals-the-modern-boot-process-part-1/#lba)
  - [A Whistle-stop Tour](https://sam4k.com/linternals-the-modern-boot-process-part-1/#a-whistle-stop-tour)
    - Protective MBR
    - Primary GPT Header
    - Partition Entries
    - Partitions
    - Secondary GPT
    - More GPT Resources
- [0x01 Push The Button!](https://sam4k.com/linternals-the-modern-boot-process-part-1/#0x01-push-the-button)
- [0x02 UEFI](https://sam4k.com/linternals-the-modern-boot-process-part-1/#0x02-uefi)
  - [The ESP](https://sam4k.com/linternals-the-modern-boot-process-part-1/#the-esp)
  - [CSM](https://sam4k.com/linternals-the-modern-boot-process-part-1/#csm)
- [Next Time](https://sam4k.com/linternals-the-modern-boot-process-part-1/#0x03-optional-bootloader)

## 0x00 GPT

Okay, before we actually turn our computer on lets have a look at how all our data, like the operating system we want to run, is stored on a storage device (e.g. an SSD or HDD).

The GUID Partition Table (GPT) scheme is a standard for formatting storage devices using, who’d have thought it, globally unique identifiers (GUIDs). It was designed to improve upon its more limited predecessor, the Master Boot Record (MBR).

```
 LBA +----------------------+ <- Disk Sart
 000 | Protective MBR       |             
     +----------------------+ <-          
 001 | Primary GPT Header   |  |          
     +----------------------+  | Primary  
 002 | Entry 1 | 2 | 3 | 4  |  | GPT      
     +----------------------+  |          
 003 | Entries 5 |...| 128  |  |          
     +----------------------+ <-          
 034 | Partition 1          |             
     +----------------------+             
  X  | Partition ...        |             
     +----------------------+ <-          
 X+1 | Entry 1 | 2 | 3 | 4  |  |          
     +----------------------+  |          
 X+2 | Entries 5 | ... |128 |  | Secondary
     +----------------------+  | GPT      
X+34 | Secondary GPT Header |  |          
     +----------------------+ <- Disk End 
```

### LBA?

Before we have a brief look at what this diagram actually means, let me quickly explain what LBA actually means. In days of old physical blocks memory on hard disks were addressed using the cylinder-head-sector (CHS) scheme, nowadays the newer Logical Block Addressing (LBA) is more commonly used.

The tl;dr is that LBA is a simple linear addressing scheme which abstracts away from the physical details of the storage device; like the whole cylinder, head, sector stuff. This means the operating system (and our diagram above) simply needs to know that blocks of memory in our storage are located by an index; such that the logical block address of the first block is 0, the second is 1 and so on.

On the topic of “blocks of memory” and layout schemes, Linux uses 512 bytes for its logical block size. So `LBA0` is a 512-byte block and the “Primary GPT” (we’ll worry about that means in a second) above spans 33 blocks so is `33*512=16896` bytes large.

### A Whistle-stop Tour

Now that we know that LBA is just indexing blocks of memory in our disk, we can begin to briefly go over what the rest of that gibberish means. MBR? Entries?? Paritions?!

#### Protective MBR

“What’s the deal with this “Protective MBR”, I thought GPT replaced that?” I hear you ask, and that’s an astute observation! Well, as part of the GPT scheme the first LBA of the disk - `LBA0` - is reserved for backwards compatibility with programs that are expecting an MBR.

However, this is not backwards compatibility in the traditional sense, and mainly a protection mechanism in order to prevent programs that don’t know about GPT from thinking the disk is unformatted and corrupt and potentially overwriting parts of our disk. As a result, the protective MBR basically defines the entire disk as one partition and sets the “System ID” of the partition as `0xEE` which denotes a GPT disk.

As a result, older programs at the very least will see a single partition of an unknown type, without free space and generally shouldn’t touch it. And yes, that means the old MBR scheme fit into a single 512 byte logical block!



#### Primary GPT Header

Now that we’ve mitigated against any accidental formatting at the hands of MBR zealots, we have the “Primary GPT” and first up is `LBA1`, the Primary GPT Header. The header block contains various metadata about the disk and GPT scheme, including the range of usable logical blocks as well as number and size of partition entries.

#### Partition Entries

The partition entries span `LBA2-LBA33` which each block containing 4 entries, making it `512/4=128` bytes per partition entry. Unsurprisingly, each entry represents a possible partition and if present contains the metadata necessary to define it: type GUID, unique GUID, start LBA, end LBA, name, attribute flags etc.

#### Partitions

These are the areas of storage defined by our partition entries previously and where our actual operating system and user data is going to be found. Not much else to say!

#### Secondary GPT

The Secondary GPT can be found out the end of the disk and is essentially just a duplicate of the Primary GPT for added redundancy in case the Primary gets corrupted.  

#### More GPT Resources

1.  <http://ntfs.com/guid-part-table.htm>

## 0x01 Push The Button!



So now we know *how* stuff is stored on our disk, let’s figure our what to do with the stuff on it and how that let’s me play Crusader Kings III. The first step? Pushing that power button of course!

I know I said I was going to avoid digging too deep into the nitty-gritty with this series, but I think it’s worth briefly touching on what’s going on under-the-hood here rather than *thematic cut to UEFI*; that said feel free to skip this section for the theatrical cut.

Okay let’s do this. So, we’ve just hit the power button, what now? Well I’m no engineer but as far as I understand, pressing that button causes a momentary short circuit in the motherboard which is enough for it send a signal over to the Power Supply Unit (PSU).

Upon receiving the signal, the PSU provides electricity to the computer. The motherboard should then receive the power good signal and starts the CPU. The CPU then does some initialisation and the important part is that it loads up a pre-configured start address, `0xfffffff0`, which is where it expects to find the first instruction. This typically contains a `jmp` instruction (called the reset vector) which takes you to the BIOS/UEFI entry point.

### Fancy a deeper dive?

1.  <https://0xax.gitbooks.io/linux-insides/content/Booting/linux-bootstrap-1.html>

## 0x02 UEFI



Before we dive into the technicals, let’s clear up a couple of naming ambiguities:

> Unified Extensible Firmware Interface (UEFI) is a specification for a software program that connects a computer’s firmware to its operating system (OS).[\[1\]](https://whatis.techtarget.com/definition/Unified-Extensible-Firmware-Interface-UEFI#:~:text=Unified%20Extensible%20Firmware%20Interface%20(UEFI)%20is%20a%20specification%20for%20a,its%20operating%20system%20(OS).&text=Like%20BIOS%2C%20UEFI%20is%20installed,runs%20when%20booting%20a%20computer.)

UEFI is the successor of BIOS, although as many people still erroneously refer to UEFI as BIOS, the old BIOS is often referred to as Legacy BIOS; so things can get a bit confusing when people are referring to the BIOS - do they mean UEFI or legacy?!

Upon executing, UEFI will begin initialising and checking hardware; this includes things like peripherals allowing for mouse use in the boot menu, wild! Next it checks the special EFI variables stored in nonvolatile RAM (NVRAM). These store configurations that can be set by the OS or the user. You can access these with root perms via the command `efibootmgr -v`:

``` console
[sam@opulence ~]$ efibootmgr -v
BootCurrent: 0008
Timeout: 2 seconds
BootOrder: 0000,0001,0002,0003,0004,0005,0006
Boot0000* EndeavourOS
                        HD(1,
                           GPT,
                           xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx,
                           0x1000,
                           0x100000
                        )/File(\EFI\ENDEAVOUROS\GRUBX64.EFI)
...
Boot0004* UEFI:CD/DVD Drive     BBS(129,,0x0)
Boot0005* UEFI:Removable Device BBS(130,,0x0)
Boot0006* UEFI:Network Device   BBS(131,,0x0)
```

So we can see here that among other uses, the EFI variables determine the order in which the boot manager will attempt to load UEFI drivers and applications.

After loading up these variables, UEFI will begin to try and load each of the active entries listed, in the order defined by `BootOrder`. `Boot0000` defines a typical UEFI native boot entry and tells UEFI:

1.  Exactly where to look via the `EFI_DEVICE_PATH_PROTOCOL`. This is the `HD(1,GPT,xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx,0x1000,0x100000)` bit.
2.  What file to load. This is the `File(\EFI\ENDEAVOUROS\GRUBX64.EFI)` bit and as the name suggests is the GRUB bootloader for my EndeavourOS install.

Armed with this information, UEFI will now go ahead and look for the EFI System Partition (ESP) on the specified storage device, mount it and launch that file. Given just a disk, UEFI is able to find the ESP via the GPT entries we mentioned earlier, where “ESP” is one of the possible attributes a partition can have.

One of the key improvements of UEFI is that it is capable of reading the FAT12, FAT16 and FAT32 file systems. So typically the ESP will be formatted as FAT32, allowing UEFI to read the partition and locate our `ENDEAVOUROS\GRUBX64.EFI` file and launch it.

### The ESP

While we’re on the topic of the ESP, it’s worth mentioning the flexibility of this partition. Usually sized around 300-500MB, the ESP can contain the bootloaders for multiple OS’s and will have corresponding EFI vars in NVRAM. So you’re ESP could look something like this[\[2\]](https://wiki.mageia.org/en/About_EFI_UEFI):

```
/boot/efi/EFI
├── boot
│ ├── bootx64.efi [Default bootloader]
│ └── bootx64.OEM [Backup of same as delivered]
│
├── EndeavourOS
│ └── grubx64.efi
|
├── Ubuntu
│ └── grubx64.efi
```

### CSM

One finally feature worth touching on is the Compatibility Support Module (CSM) in UEFI, which essentially provides Legacy BIOS compatibility via emulating a BIOS environment. This is an example where you’re GPTs “Protective MBR” would come in handy.

#### Refs & Extras

1.  [https://whatis.techtarget.com/definition/Unified-Extensible-Firmware-Interface-UEFI](https://whatis.techtarget.com/definition/Unified-Extensible-Firmware-Interface-UEFI#:~:text=Unified%20Extensible%20Firmware%20Interface%20(UEFI)%20is%20a%20specification%20for%20a,its%20operating%20system%20(OS).&text=Like%20BIOS%2C%20UEFI%20is%20installed,runs%20when%20booting%20a%20computer)
2.  <https://wiki.mageia.org/en/About_EFI_UEFI>
3.  <https://www.happyassassin.net/posts/2014/01/25/uefi-boot-how-does-that-actually-work-then/>

## 0x03 Optional Bootloader



It looks like I severely underestimated the length of this post, (we’re already 1700 words!), so to make this a bit more manageable I’m going to split this into two posts.

The next post, part 2, will cover the following section:

- 0x03 Optional Bootloader (surprise, surprise!)
- 0x04 The Kernel
- 0x05 Systemd (yikes)

exit(0);
