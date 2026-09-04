{#pathresult}

# PathResult

```cpp
#include <Sftp.hpp>
```

```cpp
class PathResult
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:195

> **Inherits:** [`Result`](sf-Sftp-Result.md#result)

[Result](sf-Sftp-Result.md#result) of an operation returning a path.

## List of all members

| Name | Kind | Owner |
|------|------|-------|
| [`PathResult`](#pathresult-1) | `function` | Declared here |
| [`getPath`](#getpath) | `function` | Declared here |
| [`m_path`](#m_path) | `variable` | Declared here |
| [`Result`](sf-Sftp-Result.md#result-1) | `function` | Inherited from [`Result`](sf-Sftp-Result.md#result) |
| [`isOk`](sf-Sftp-Result.md#isok-1) | `function` | Inherited from [`Result`](sf-Sftp-Result.md#result) |
| [`getValue`](sf-Sftp-Result.md#getvalue-1) | `function` | Inherited from [`Result`](sf-Sftp-Result.md#result) |
| [`getMessage`](sf-Sftp-Result.md#getmessage-1) | `function` | Inherited from [`Result`](sf-Sftp-Result.md#result) |
| [`Value`](Value.md#value-1) | `enum` | Inherited from [`Result`](sf-Sftp-Result.md#result) |
| [`m_value`](sf-Sftp-Result.md#m_value) | `variable` | Inherited from [`Result`](sf-Sftp-Result.md#result) |
| [`m_message`](sf-Sftp-Result.md#m_message-1) | `variable` | Inherited from [`Result`](sf-Sftp-Result.md#result) |

## Inherited from [`Result`](sf-Sftp-Result.md#result)

| Kind | Name | Description |
|------|------|-------------|
| `function` | [`Result`](sf-Sftp-Result.md#result-1) `explicit` | Constructor. |
| `function` | [`isOk`](sf-Sftp-Result.md#isok-1) `const` `nodiscard` | Check if the result is a success. |
| `function` | [`getValue`](sf-Sftp-Result.md#getvalue-1) `const` `nodiscard` | Get the result value. |
| `function` | [`getMessage`](sf-Sftp-Result.md#getmessage-1) `const` `nodiscard` | Get the result message. |
| `enum` | [`Value`](Value.md#value-1)  | [Result](sf-Sftp-Result.md#result) values. |
| `variable` | [`m_value`](sf-Sftp-Result.md#m_value)  | The contained value. |
| `variable` | [`m_message`](sf-Sftp-Result.md#m_message-1)  | The contained message. |

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`PathResult`](#pathresult-1)  | Constructor. |
| `const std::filesystem::path &` | [`getPath`](#getpath) `const` `nodiscard` | Get the path. |

---

{#pathresult-1}

### PathResult

```cpp
PathResult(const Result & result, std::filesystem::path path)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:205

Constructor.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `result` | const [`Result`](sf-Sftp-Result.md#result) & | [Result](sf-Sftp-Result.md#result) |
| `path` | `std::filesystem::path` | Path |

---

{#getpath}

### getPath

`const` `nodiscard`

```cpp
[[nodiscard]] const std::filesystem::path & getPath() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:213

Get the path.

#### Returns
The path

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::filesystem::path` | [`m_path`](#m_path)  | The contained path. |

---

{#m_path}

### m_path

```cpp
std::filesystem::path m_path
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:219

The contained path.

