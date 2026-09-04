{#stencilvalue}

# StencilValue

```cpp
#include <StencilMode.hpp>
```

```cpp
struct StencilValue
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/StencilMode.hpp:74

Stencil value type (also used as a mask)

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `unsigned int` | [`value`](#value-2)  | The stored stencil value. |

---

{#value-2}

### value

```cpp
unsigned int value {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/StencilMode.hpp:99

The stored stencil value.

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`StencilValue`](#stencilvalue-1)  | Construct a stencil value from a signed integer. |
|  | [`StencilValue`](#stencilvalue-2)  | Construct a stencil value from an unsigned integer. |
|  | [`StencilValue`](#stencilvalue-3)  | Disable construction from any other type. |

---

{#stencilvalue-1}

### StencilValue

```cpp
StencilValue(int theValue)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/StencilMode.hpp:82

Construct a stencil value from a signed integer.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `theValue` | `int` | Signed integer value to use |

---

{#stencilvalue-2}

### StencilValue

```cpp
StencilValue(unsigned int theValue)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/StencilMode.hpp:90

Construct a stencil value from an unsigned integer.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `theValue` | `unsigned int` | Unsigned integer value to use |

---

{#stencilvalue-3}

### StencilValue

```cpp
template<typename T> StencilValue(T) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/StencilMode.hpp:97

Disable construction from any other type.

