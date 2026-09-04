{#listingresult}

# ListingResult

```cpp
#include <Sftp.hpp>
```

```cpp
class ListingResult
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:273

> **Inherits:** [`Result`](sf-Sftp-Result.md#result)

[Result](sf-Sftp-Result.md#result) of an operation returning a directory listing.

## List of all members

| Name | Kind | Owner |
|------|------|-------|
| [`ListingResult`](#listingresult-1) | `function` | Declared here |
| [`getListing`](#getlisting-1) | `function` | Declared here |
| [`m_listing`](#m_listing-1) | `variable` | Declared here |
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
|  | [`ListingResult`](#listingresult-1)  | Constructor. |
| const std::vector< [`Attributes`](sf-Sftp-Attributes.md#attributes) > & | [`getListing`](#getlisting-1) `const` `nodiscard` | Get the directory listing. |

---

{#listingresult-1}

### ListingResult

```cpp
ListingResult(const Result & result, std::vector< Attributes > listing)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:283

Constructor.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `result` | const [`Result`](sf-Sftp-Result.md#result) & | [Result](sf-Sftp-Result.md#result) |
| `listing` | std::vector< [`Attributes`](sf-Sftp-Attributes.md#attributes) > | Directory listing |

---

{#getlisting-1}

### getListing

`const` `nodiscard`

```cpp
[[nodiscard]] const std::vector< Attributes > & getListing() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:291

Get the directory listing.

#### Returns
The directory listing

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| std::vector< [`Attributes`](sf-Sftp-Attributes.md#attributes) > | [`m_listing`](#m_listing-1)  | The contained directory listing. |

---

{#m_listing-1}

### m_listing

```cpp
std::vector< Attributes > m_listing
```

Type: std::vector< [`Attributes`](sf-Sftp-Attributes.md#attributes) >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:297

The contained directory listing.

