{#platforms}

# Platforms

[Program](Program.md#program) platforms (i.e., architecture and ABI).

## Enumerations

| Name | Description |
|------|-------------|
| [`drgn_architecture`](#drgn_architecture)  | An instruction set architecture. |
| [`drgn_platform_flags`](#drgn_platform_flags)  | Flags describing a [drgn_platform](drgn_platform.md#drgn_platform). |

---

{#drgn_architecture}

### drgn_architecture

```cpp
enum drgn_architecture
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:416

An instruction set architecture.

| Value | Description |
|-------|-------------|
| `DRGN_ARCH_UNKNOWN` |  |
| `DRGN_ARCH_X86_64` |  |
| `DRGN_ARCH_I386` |  |
| `DRGN_ARCH_AARCH64` |  |
| `DRGN_ARCH_ARM` |  |
| `DRGN_ARCH_PPC64` |  |
| `DRGN_ARCH_RISCV64` |  |
| `DRGN_ARCH_RISCV32` |  |
| `DRGN_ARCH_S390X` |  |
| `DRGN_ARCH_S390` |  |
| `DRGN_ARCH_LOONGARCH64` |  |

---

{#drgn_platform_flags}

### drgn_platform_flags

```cpp
enum drgn_platform_flags
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:431

Flags describing a [drgn_platform](drgn_platform.md#drgn_platform).

| Value | Description |
|-------|-------------|
| `DRGN_PLATFORM_IS_64_BIT` | [Platform](Platform.md#platform-2) is 64-bit. |
| `DRGN_PLATFORM_IS_LITTLE_ENDIAN` | [Platform](Platform.md#platform-2) is little-endian. |
| `DRGN_ALL_PLATFORM_FLAGS` | All valid platform flags. |
| `DRGN_PLATFORM_DEFAULT_FLAGS` | Use the default flags for the architecture. |
## Functions

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_platform_create`](#drgn_platform_create)  | Create a [drgn_platform](drgn_platform.md#drgn_platform). |
| `void` | [`drgn_platform_destroy`](#drgn_platform_destroy)  | Destroy a [drgn_platform](drgn_platform.md#drgn_platform). |
| enum [`drgn_architecture`](drgn_architecture.md#drgn_architecture) | [`drgn_platform_arch`](#drgn_platform_arch)  | Get the instruction set architecture of a [drgn_platform](drgn_platform.md#drgn_platform). |
| enum [`drgn_platform_flags`](drgn_platform_flags.md#drgn_platform_flags) | [`drgn_platform_flags`](#drgn_platform_flags-1)  | Get the flags of a [drgn_platform](drgn_platform.md#drgn_platform). |
| `size_t` | [`drgn_platform_num_registers`](#drgn_platform_num_registers)  | Get the number of [drgn_register](drgn_register.md#drgn_register)'s on a [drgn_platform](drgn_platform.md#drgn_platform). |
| const struct [`drgn_register`](drgn_register.md#drgn_register) * | [`drgn_platform_register`](#drgn_platform_register)  | Get the `n-th`[drgn_register](drgn_register.md#drgn_register) of a [drgn_platform](drgn_platform.md#drgn_platform). |
| const struct [`drgn_register`](drgn_register.md#drgn_register) * | [`drgn_platform_register_by_name`](#drgn_platform_register_by_name)  | Get a [drgn_register](drgn_register.md#drgn_register) in a [drgn_platform](drgn_platform.md#drgn_platform) by its name. |
| `bool` | [`drgn_platform_eq`](#drgn_platform_eq)  | Return whether two platforms are identical. |
| `const char *const *` | [`drgn_register_names`](#drgn_register_names)  | Get the names of a [drgn_register](drgn_register.md#drgn_register). |

---

{#drgn_platform_create}

### drgn_platform_create

```cpp
struct drgn_error * drgn_platform_create(enum drgn_architecture arch, enum drgn_platform_flags flags, struct drgn_platform ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:461

Create a [drgn_platform](drgn_platform.md#drgn_platform).

The returned platform should be destroyed with [drgn_platform_destroy()](#drgn_platform_destroy).

---

{#drgn_platform_destroy}

### drgn_platform_destroy

```cpp
void drgn_platform_destroy(struct drgn_platform * platform)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:466

Destroy a [drgn_platform](drgn_platform.md#drgn_platform).

---

{#drgn_platform_arch}

### drgn_platform_arch

```cpp
enum drgn_architecture drgn_platform_arch(const struct drgn_platform * platform)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:469

Get the instruction set architecture of a [drgn_platform](drgn_platform.md#drgn_platform).

---

{#drgn_platform_flags-1}

### drgn_platform_flags

```cpp
enum drgn_platform_flags drgn_platform_flags(const struct drgn_platform * platform)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:473

Get the flags of a [drgn_platform](drgn_platform.md#drgn_platform).

---

{#drgn_platform_num_registers}

### drgn_platform_num_registers

```cpp
size_t drgn_platform_num_registers(const struct drgn_platform * platform)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:476

Get the number of [drgn_register](drgn_register.md#drgn_register)'s on a [drgn_platform](drgn_platform.md#drgn_platform).

---

{#drgn_platform_register}

### drgn_platform_register

```cpp
const struct drgn_register * drgn_platform_register(const struct drgn_platform * platform, size_t n)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:480

Get the `n-th`[drgn_register](drgn_register.md#drgn_register) of a [drgn_platform](drgn_platform.md#drgn_platform).

---

{#drgn_platform_register_by_name}

### drgn_platform_register_by_name

```cpp
const struct drgn_register * drgn_platform_register_by_name(const struct drgn_platform * platform, const char * name)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:484

Get a [drgn_register](drgn_register.md#drgn_register) in a [drgn_platform](drgn_platform.md#drgn_platform) by its name.

---

{#drgn_platform_eq}

### drgn_platform_eq

```cpp
bool drgn_platform_eq(struct drgn_platform * a, struct drgn_platform * b)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:488

Return whether two platforms are identical.

---

{#drgn_register_names}

### drgn_register_names

```cpp
const char *const * drgn_register_names(const struct drgn_register * reg, size_t * num_names_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:499

Get the names of a [drgn_register](drgn_register.md#drgn_register).

#### Returns
Array of names.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `num_names_ret` | `size_t *` | Returned number of names. |

## Variables

| Return | Name | Description |
|--------|------|-------------|
| const struct [`drgn_platform`](drgn_platform.md#drgn_platform) | [`drgn_host_platform`](#drgn_host_platform)  | [Platform](Platform.md#platform-2) that drgn was compiled for. |

---

{#drgn_host_platform}

### drgn_host_platform

```cpp
const struct drgn_platform drgn_host_platform
```

Type: const struct [`drgn_platform`](drgn_platform.md#drgn_platform)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:491

[Platform](Platform.md#platform-2) that drgn was compiled for.

