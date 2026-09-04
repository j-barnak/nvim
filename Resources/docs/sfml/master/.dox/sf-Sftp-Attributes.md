{#attributes}

# Attributes

```cpp
#include <Sftp.hpp>
```

```cpp
struct Attributes
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:226

File or directory attributes.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::filesystem::path` | [`path`](#path)  | Path to the entry. |
| `std::optional< std::filesystem::file_type >` | [`type`](#type-4)  | Type of the entry. |
| `std::optional< std::uint64_t >` | [`size`](#size-2)  | Size of the entry. |
| `std::optional< std::filesystem::perms >` | [`permissions`](#permissions)  | Permissions. |
| `std::optional< std::uint64_t >` | [`userId`](#userid)  | Owner user ID. |
| `std::optional< std::uint64_t >` | [`groupId`](#groupid)  | Group ID. |
| `std::optional< std::filesystem::file_time_type >` | [`accessTime`](#accesstime)  | Last access time. |
| `std::optional< std::filesystem::file_time_type >` | [`modificationTime`](#modificationtime)  | Last modification time. |

---

{#path}

### path

```cpp
std::filesystem::path path
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:228

Path to the entry.

---

{#type-4}

### type

```cpp
std::optional< std::filesystem::file_type > type
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:229

Type of the entry.

---

{#size-2}

### size

```cpp
std::optional< std::uint64_t > size
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:230

Size of the entry.

---

{#permissions}

### permissions

```cpp
std::optional< std::filesystem::perms > permissions
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:231

Permissions.

---

{#userid}

### userId

```cpp
std::optional< std::uint64_t > userId
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:232

Owner user ID.

---

{#groupid}

### groupId

```cpp
std::optional< std::uint64_t > groupId
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:233

Group ID.

---

{#accesstime}

### accessTime

```cpp
std::optional< std::filesystem::file_time_type > accessTime
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:234

Last access time.

---

{#modificationtime}

### modificationTime

```cpp
std::optional< std::filesystem::file_time_type > modificationTime
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:235

Last modification time.

