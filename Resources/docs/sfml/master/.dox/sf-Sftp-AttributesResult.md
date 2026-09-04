{#attributesresult}

# AttributesResult

```cpp
#include <Sftp.hpp>
```

```cpp
class AttributesResult
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:242

> **Inherits:** [`Result`](sf-Sftp-Result.md#result)

[Result](sf-Sftp-Result.md#result) of an operation returning attributes.

## List of all members

| Name | Kind | Owner |
|------|------|-------|
| [`AttributesResult`](#attributesresult-1) | `function` | Declared here |
| [`getAttributes`](#getattributes-1) | `function` | Declared here |
| [`m_attributes`](#m_attributes) | `variable` | Declared here |
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
|  | [`AttributesResult`](#attributesresult-1)  | Constructor. |
| const [`Attributes`](sf-Sftp-Attributes.md#attributes) & | [`getAttributes`](#getattributes-1) `const` `nodiscard` | Get the attributes. |

---

{#attributesresult-1}

### AttributesResult

```cpp
AttributesResult(const Result & result, Attributes attributes)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:252

Constructor.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `result` | const [`Result`](sf-Sftp-Result.md#result) & | [Result](sf-Sftp-Result.md#result) |
| `attributes` | [`Attributes`](sf-Sftp-Attributes.md#attributes) | [Attributes](sf-Sftp-Attributes.md#attributes) |

---

{#getattributes-1}

### getAttributes

`const` `nodiscard`

```cpp
[[nodiscard]] const Attributes & getAttributes() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:260

Get the attributes.

#### Returns
The attributes

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`Attributes`](sf-Sftp-Attributes.md#attributes) | [`m_attributes`](#m_attributes)  | The contained attributes. |

---

{#m_attributes}

### m_attributes

```cpp
Attributes m_attributes
```

Type: [`Attributes`](sf-Sftp-Attributes.md#attributes)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:266

The contained attributes.

