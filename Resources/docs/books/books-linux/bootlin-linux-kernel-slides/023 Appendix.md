![](/tmp/audit/iter1/epubregen/bootlin-linux-kernel-slides/media/index-451_1.jpg)

Backup slides

 

Backup slides

 

© Copyright 2004-2025, Bootlin. embedded Linux and kernel engineering Creative Commons BY-SA 3.0 license.

Corrections, suggestions, contributions and translations are welcome!

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 1/16

Backup slides

 

mmap

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 2/16 mmap

 

▶ Possibility to have parts of the virtual address space of a program mapped to the

contents of a file

▶ Particularly useful when the file is a device file ▶ Allows to access device I/O memory and ports without having to go through

(expensive) read, write or ioctl calls

▶ One can access to current mapped files by two means:

*•* /proc/\<pid\>/maps

*•* pmap \<pid\>

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 3/16 /proc/\<pid\>/maps

 

start-end perm offset major:minor inode mapped file name

...

7f4516d04000-7f4516d06000 rw-s 1152a2000 00:05 8406 /dev/dri/card0 7f4516d07000-7f4516d0b000 rw-s 120f9e000 00:05 8406 /dev/dri/card0 ...

7f4518728000-7f451874f000 r-xp 00000000 08:01 268909 /lib/x86_64-linux-gnu/libexpat.so.1.5.2 7f451874f000-7f451894f000 ---p 00027000 08:01 268909 /lib/x86_64-linux-gnu/libexpat.so.1.5.2 7f451894f000-7f4518951000 r--p 00027000 08:01 268909 /lib/x86_64-linux-gnu/libexpat.so.1.5.2 7f4518951000-7f4518952000 rw-p 00029000 08:01 268909 /lib/x86_64-linux-gnu/libexpat.so.1.5.2 ...

7f451da4f000-7f451dc3f000 r-xp 00000000 08:01 1549 /usr/bin/Xorg 7f451de3e000-7f451de41000 r--p 001ef000 08:01 1549 /usr/bin/Xorg 7f451de41000-7f451de4c000 rw-p 001f2000 08:01 1549 /usr/bin/Xorg ...

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 4/16 mmap overview

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 5/16 How to Implement mmap - User space

 

▶ Open the device file

▶ Call the mmap system call (see man mmap for details):

void \* mmap(

void \*start, /\* Often 0, preferred starting address \*/ size_t length, /\* Length of the mapped area \*/ int prot, /\* Permissions: read, write, execute \*/ int flags, /\* Options: shared mapping, private copy... \*/ int fd, /\* Open file descriptor \*/ off_t offset /\* Offset in the file \*/

);

▶ You get a virtual address you can write to or read from.

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 6/16 How to Implement mmap - Kernel space

 

▶ Character driver: implement an mmap file operation and add it to the driver file

operations:

int (\*mmap) (

struct file \*, /\* Open file structure \*/ struct vm_area_struct \* /\* Kernel VMA structure \*/

);

▶ Initialize the mapping.

*•* Can be done in most cases with the [remap_pfn_range()](https://elixir.bootlin.com/linux/latest/ident/remap_pfn_range) function, which takes care

of most of the job.

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 7/16 remap_pfn_range()

 

▶ *pfn*: page frame number

▶ The most significant bits of the page address (without the bits corresponding to

the page size).

\#include \<linux/mm.h\>

 

int remap_pfn_range(

struct vm_area_struct \*, /\* VMA struct \*/

unsigned long virt_addr, /\* Starting user

\* virtual address \*/

unsigned long pfn, /\* pfn of the starting

\* physical address \*/

unsigned long size, /\* Mapping size \*/

pgprot_t prot /\* Page permissions \*/ );

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 8/16 Simple mmap implementation

 

static int acme_mmap

(struct file \* file, struct vm_area_struct \*vma)

{

size = vma-\>vm_end - vma-\>vm_start;

 

if (size \> ACME_SIZE)

return-EINVAL;

 

if (remap_pfn_range(vma,

vma-\>vm_start,

ACME_PHYS \>\> PAGE_SHIFT,

size,

vma-\>vm_page_prot))

return-EAGAIN;

 

return 0;

}

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 9/16 devmem2

 

▶ [https://bootlin.com/pub/mirror/devmem2.c,](https://bootlin.com/pub/mirror/devmem2.c) by Jan-Derk Bakker ▶ Very useful tool to directly peek (read) or poke (write) I/O addresses mapped in

physical address space from a shell command line!

*•* Very useful for early interaction experiments with a device, without having to code

and compile a driver.

*•* Uses mmap to /dev/mem.

*•* Examples (b: byte, h: half, w: word)

devmem2 0x000c0004 h (reading) devmem2 0x000c0008 w 0xffffffff (writing)

*•* devmem is now available in BusyBox, making it even easier to use.

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 10/16 mmap summary

 

▶ The device driver is loaded. It defines an mmap file operation. ▶ A user space process calls the mmap system call. ▶ The mmap file operation is called.

▶ It initializes the mapping using the device physical address. ▶ The process gets a starting address to read from and write to (depending on

permissions).

▶ The MMU automatically takes care of converting the process virtual addresses

into physical ones.

▶ Direct access to the hardware without any expensive read or write system calls

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 11/16

Backup slides

 

Useful general-purpose kernel APIs

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 12/16 Memory/string utilities

 

▶ In [include/linux/string.h](https://elixir.bootlin.com/linux/latest/source/include/linux/string.h)

*•* Memory-related: [memset()](https://elixir.bootlin.com/linux/latest/ident/memset), [memcpy()](https://elixir.bootlin.com/linux/latest/ident/memcpy), [memmove()](https://elixir.bootlin.com/linux/latest/ident/memmove)[,](https://elixir.bootlin.com/linux/latest/ident/memmove) [memscan()](https://elixir.bootlin.com/linux/latest/ident/memscan), [memcmp()](https://elixir.bootlin.com/linux/latest/ident/memcmp)[,](https://elixir.bootlin.com/linux/latest/ident/memcmp) [memchr()](https://elixir.bootlin.com/linux/latest/ident/memchr)

*•* String-related: [strcpy()](https://elixir.bootlin.com/linux/latest/ident/strcpy), [strcat()](https://elixir.bootlin.com/linux/latest/ident/strcat), [strcmp()](https://elixir.bootlin.com/linux/latest/ident/strcmp), [strchr()](https://elixir.bootlin.com/linux/latest/ident/strchr), [strrchr()](https://elixir.bootlin.com/linux/latest/ident/strrchr), [strlen()](https://elixir.bootlin.com/linux/latest/ident/strlen)

and variants

*•* Allocate and copy a string: [kstrdup()](https://elixir.bootlin.com/linux/latest/ident/kstrdup)[,](https://elixir.bootlin.com/linux/latest/ident/kstrdup) [kstrndup()](https://elixir.bootlin.com/linux/latest/ident/kstrndup)

*•* Allocate and copy a memory area: [kmemdup()](https://elixir.bootlin.com/linux/latest/ident/kmemdup)

▶ In [include/linux/kernel.h](https://elixir.bootlin.com/linux/latest/source/include/linux/kernel.h)

*•* String to int conversion: [simple_strtoul()](https://elixir.bootlin.com/linux/latest/ident/simple_strtoul), [simple_strtol()](https://elixir.bootlin.com/linux/latest/ident/simple_strtol)[,](https://elixir.bootlin.com/linux/latest/ident/simple_strtol)

[simple_strtoull(),](https://elixir.bootlin.com/linux/latest/ident/simple_strtoull) [simple_strtoll()](https://elixir.bootlin.com/linux/latest/ident/simple_strtoll)

*•* Other string functions: [sprintf()](https://elixir.bootlin.com/linux/latest/ident/sprintf), [sscanf()](https://elixir.bootlin.com/linux/latest/ident/sscanf)

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 13/16

Linked lists

 

▶ Convenient linked-list facility in [include/linux/list.h](https://elixir.bootlin.com/linux/latest/source/include/linux/list.h)

*•* Used in thousands of places in the kernel

▶ Add a [struct list_head](https://elixir.bootlin.com/linux/latest/ident/list_head) member to the structure whose instances will be part of

the linked list. It is usually named node when each instance needs to only be part

of a single list.

▶ Define the list with the [LIST_HEAD()](https://elixir.bootlin.com/linux/latest/ident/LIST_HEAD) macro for a global list, or define a

[struct list_head](https://elixir.bootlin.com/linux/latest/ident/list_head) element and initialize it with [INIT_LIST_HEAD()](https://elixir.bootlin.com/linux/latest/ident/INIT_LIST_HEAD) for lists

embedded in a structure.

▶ Then use the list\_\*() API to manipulate the list

*•* Add elements: [list_add()](https://elixir.bootlin.com/linux/latest/ident/list_add)[,](https://elixir.bootlin.com/linux/latest/ident/list_add) [list_add_tail()](https://elixir.bootlin.com/linux/latest/ident/list_add_tail)

*•* Remove, move or replace elements: [list_del()](https://elixir.bootlin.com/linux/latest/ident/list_del), [list_move()](https://elixir.bootlin.com/linux/latest/ident/list_move)[,](https://elixir.bootlin.com/linux/latest/ident/list_move) [list_move_tail()](https://elixir.bootlin.com/linux/latest/ident/list_move_tail),

[list_replace()](https://elixir.bootlin.com/linux/latest/ident/list_replace)

*•* Test the list: [list_empty()](https://elixir.bootlin.com/linux/latest/ident/list_empty)

*•* Iterate over the list: list_for_each\_\*() family of macros

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 14/16 Linked lists examples 1/2

 

From [include/soc/at91/atmel_tcb.h](https://elixir.bootlin.com/linux/latest/source/include/soc/at91/atmel_tcb.h) /\*

\* Definition of a list element, with a \* struct list_head member

\*/

struct atmel_tc

{

/\* some members \*/

struct list_head node;

};

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 15/16

Linked lists examples 2/2

 

From [drivers/misc/atmel_tclib.c](https://elixir.bootlin.com/linux/latest/source/drivers/misc/atmel_tclib.c)

/\* Define the global list \*/

static LIST_HEAD(tc_list);

static int \_\_init tc_probe(struct platform_device \*pdev) {

struct atmel_tc \*tc;

tc = kzalloc(sizeof(struct atmel_tc), GFP_KERNEL);

/\* Add an element to the list \*/

list_add_tail(&tc-\>node, &tc_list);

}

struct atmel_tc \*atmel_tc_alloc(unsigned block, const char \*name) {

struct atmel_tc \*tc;

/\* Iterate over the list elements \*/

list_for_each_entry(tc, &tc_list, node) {

/\* Do something with tc \*/

}

\[...\]

}

 

- Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com 16/16