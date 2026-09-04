{#transientcontextlock}

# TransientContextLock

```cpp
#include <GlResource.hpp>
```

```cpp
class TransientContextLock
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/GlResource.hpp:74

RAII helper class to temporarily lock an available context for use.

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`TransientContextLock`](#transientcontextlock-1)  | Default constructor. |
|  | [`~TransientContextLock`](#transientcontextlock-2)  | Destructor. |
|  | [`TransientContextLock`](#transientcontextlock-3)  | Deleted copy constructor. |
| [`TransientContextLock`](#transientcontextlock) & | [`operator=`](#operator-21)  | Deleted copy assignment. |

---

{#transientcontextlock-1}

### TransientContextLock

```cpp
TransientContextLock()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/GlResource.hpp:81

Default constructor.

---

{#transientcontextlock-2}

### ~TransientContextLock

```cpp
~TransientContextLock()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/GlResource.hpp:87

Destructor.

---

{#transientcontextlock-3}

### TransientContextLock

```cpp
TransientContextLock(const TransientContextLock &) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/GlResource.hpp:93

Deleted copy constructor.

---

{#operator-21}

### operator=

```cpp
TransientContextLock & operator=(const TransientContextLock &) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/GlResource.hpp:99

Deleted copy assignment.

