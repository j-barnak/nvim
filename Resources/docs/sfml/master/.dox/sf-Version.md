{#version-1}

# Version

```cpp
#include <Version.hpp>
```

```cpp
struct Version
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Version.hpp:39

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `const std::int8_t` | [`major`](#major)  | SFML major version. |
| `const std::int8_t` | [`minor`](#minor)  | SFML minor version. |
| `const std::int8_t` | [`patch`](#patch)  | SFML patch version. |
| `const bool` | [`isRelease`](#isrelease)  | `true` if this is a release version, `false` if this is a development version |
| `const std::string_view` | [`string`](#string-15)  | [String](sf-String.md#string) representation of the SFML version, e.g. 3.1.0 or 3.1.0-dev. |

---

{#major}

### major

```cpp
const std::int8_t major
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Version.hpp:41

SFML major version.

---

{#minor}

### minor

```cpp
const std::int8_t minor
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Version.hpp:42

SFML minor version.

---

{#patch}

### patch

```cpp
const std::int8_t patch
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Version.hpp:43

SFML patch version.

---

{#isrelease}

### isRelease

```cpp
const bool isRelease
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Version.hpp:44

`true` if this is a release version, `false` if this is a development version

---

{#string-15}

### string

```cpp
const std::string_view string
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Version.hpp:45

[String](sf-String.md#string) representation of the SFML version, e.g. 3.1.0 or 3.1.0-dev.

