{#keyreleased}

# KeyReleased

```cpp
#include <Event.hpp>
```

```cpp
struct KeyReleased
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:117

Key released event subtype.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`Keyboard::Key`](Key.md#key) | [`code`](#code-1)  | Code of the key that has been released. |
| [`Keyboard::Scancode`](Scan.md#scan) | [`scancode`](#scancode-1)  | Physical code of the key that has been released. |
| `bool` | [`alt`](#alt-1)  | Is the Alt key pressed? |
| `bool` | [`control`](#control-1)  | Is the Control key pressed? |
| `bool` | [`shift`](#shift-1)  | Is the Shift key pressed? |
| `bool` | [`system`](#system-1)  | Is the System key pressed? |
| `bool` | [`capsLock`](#capslock-1)  | Is the CapsLock key toggled? |
| `bool` | [`numLock`](#numlock-1)  | Is the NumLock key toggled? |
| `bool` | [`scrollLock`](#scrolllock-1)  | Is the ScrollLock key toggled? (Not supported on macOS) |

---

{#code-1}

### code

```cpp
Keyboard::Key code {}
```

Type: [`Keyboard::Key`](Key.md#key)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:119

Code of the key that has been released.

---

{#scancode-1}

### scancode

```cpp
Keyboard::Scancode scancode {}
```

Type: [`Keyboard::Scancode`](Scan.md#scan)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:120

Physical code of the key that has been released.

---

{#alt-1}

### alt

```cpp
bool alt {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:121

Is the Alt key pressed?

---

{#control-1}

### control

```cpp
bool control {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:122

Is the Control key pressed?

---

{#shift-1}

### shift

```cpp
bool shift {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:123

Is the Shift key pressed?

---

{#system-1}

### system

```cpp
bool system {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:124

Is the System key pressed?

---

{#capslock-1}

### capsLock

```cpp
bool capsLock {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:125

Is the CapsLock key toggled?

---

{#numlock-1}

### numLock

```cpp
bool numLock {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:126

Is the NumLock key toggled?

---

{#scrolllock-1}

### scrollLock

```cpp
bool scrollLock {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:127

Is the ScrollLock key toggled? (Not supported on macOS)

