{#drgn_elf_file}

# drgn_elf_file

```cpp
#include <elf_file.h>
```

```cpp
struct drgn_elf_file
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:60

An ELF file used by a [drgn_module](drgn_module.md#drgn_module).

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_module`](drgn_module.md#drgn_module) * | [`module`](#module-1)  | [Module](Module.md#module-3) using this file. |
| `char *` | [`path`](#path-2)  | Filesystem path to this file. |
| `char *` | [`image`](#image)  | Memory image backing [elf](#elf). |
| `int` | [`fd`](#fd)  | File descriptor backing [elf](#elf). |
| `bool` | [`is_loadable`](#is_loadable)  | Whether the file is loadable. |
| `bool` | [`is_relocatable`](#is_relocatable)  | Whether the file is relocatable. |
| `bool` | [`needs_relocation`](#needs_relocation)  | Whether the file still need to have relocations applied. |
| `bool` | [`is_vmlinux`](#is_vmlinux)  | Whether the file is a Linux kernel image (`vmlinux`). |
| `Elf *` | [`elf`](#elf)  | libelf handle. |
| `Dwarf *` | [`_dwarf`](#_dwarf)  | libdw handle. |
| struct [`drgn_platform`](drgn_platform.md#drgn_platform) | [`platform`](#platform-1)  | [Platform](Platform.md#platform-2) of this file. |
| `Elf_Scn *` | [`scns`](#scns)  | Important ELF sections. |
| `Elf_Data *` | [`scn_data`](#scn_data)  | Data cached for important ELF sections. |
| `Elf_Data *` | [`alt_debug_info_data`](#alt_debug_info_data)  | If the file has a debugaltlink file, the debugaltlink file's `.debug_info` section data. |
| `Elf_Data *` | [`alt_debug_str_data`](#alt_debug_str_data)  | If the file has a debugaltlink file, the debugaltlink file's `.debug_str` section data. |
| [`unsigned`](api.md#unsigned) long * | [`gnu_compressed_sections`](#gnu_compressed_sections)  | Bitmap of GNU-compressed sections, or `NULL` if there are none. |
| [`unsigned`](api.md#unsigned) long * | [`sections_with_address`](#sections_with_address)  | For relocatable files, a bitmap of which sections have their address set. |

---

{#module-1}

### module

```cpp
struct drgn_module * module
```

Type: struct [`drgn_module`](drgn_module.md#drgn_module) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:62

[Module](Module.md#module-3) using this file.

---

{#path-2}

### path

```cpp
char * path
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:64

Filesystem path to this file.

---

{#image}

### image

```cpp
char * image
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:70

Memory image backing [elf](#elf).

`NULL` if not backed by a memory image.

---

{#fd}

### fd

```cpp
int fd
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:76

File descriptor backing [elf](#elf).

-1 if not backed by a file.

---

{#is_loadable}

### is_loadable

```cpp
bool is_loadable
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:78

Whether the file is loadable.

---

{#is_relocatable}

### is_relocatable

```cpp
bool is_relocatable
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:80

Whether the file is relocatable.

---

{#needs_relocation}

### needs_relocation

```cpp
bool needs_relocation
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:82

Whether the file still need to have relocations applied.

---

{#is_vmlinux}

### is_vmlinux

```cpp
bool is_vmlinux
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:84

Whether the file is a Linux kernel image (`vmlinux`).

---

{#elf}

### elf

```cpp
Elf * elf
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:86

libelf handle.

---

{#_dwarf}

### _dwarf

```cpp
Dwarf * _dwarf
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:95

libdw handle.

`NULL` if not yet created.

Don't access this directly. Get it with [drgn_elf_file_get_dwarf()](ElfFile.md#drgn_elf_file_get_dwarf) instead.

---

{#platform-1}

### platform

```cpp
struct drgn_platform platform
```

Type: struct [`drgn_platform`](drgn_platform.md#drgn_platform)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:105

[Platform](Platform.md#platform-2) of this file.

This should take precedence over drgn_program::platform when parsing this file. Note that there are some cases where it doesn't make sense for the program and file platforms to differ (e.g., stack unwinding), in which case the file should be ignored if its platform doesn't match the program's.

---

{#scns}

### scns

```cpp
Elf_Scn * scns[DRGN_SECTION_INDEX_NUM]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:107

Important ELF sections.

---

{#scn_data}

### scn_data

```cpp
Elf_Data * scn_data[DRGN_SECTION_INDEX_NUM_DATA]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:109

Data cached for important ELF sections.

---

{#alt_debug_info_data}

### alt_debug_info_data

```cpp
Elf_Data * alt_debug_info_data
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:114

If the file has a debugaltlink file, the debugaltlink file's `.debug_info` section data.

---

{#alt_debug_str_data}

### alt_debug_str_data

```cpp
Elf_Data * alt_debug_str_data
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:119

If the file has a debugaltlink file, the debugaltlink file's `.debug_str` section data.

---

{#gnu_compressed_sections}

### gnu_compressed_sections

```cpp
unsigned long * gnu_compressed_sections
```

Type: [`unsigned`](api.md#unsigned) long *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:121

Bitmap of GNU-compressed sections, or `NULL` if there are none.

---

{#sections_with_address}

### sections_with_address

```cpp
unsigned long * sections_with_address
```

Type: [`unsigned`](api.md#unsigned) long *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:126

For relocatable files, a bitmap of which sections have their address set.

