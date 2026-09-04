{#keypressed}

# KeyPressed

```cpp
#include <Event.hpp>
```

```cpp
struct KeyPressed
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:100

Key pressed event subtype.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`Keyboard::Key`](Key.md#key) | [`code`](#code)  | Code of the key that has been pressed. |
| [`Keyboard::Scancode`](Scan.md#scan) | [`scancode`](#scancode)  | Physical code of the key that has been pressed. |
| `bool` | [`alt`](#alt)  | Is the Alt key pressed? |
| `bool` | [`control`](#control)  | Is the Control key pressed? |
| `bool` | [`shift`](#shift)  | Is the Shift key pressed? |
| `bool` | [`system`](#system)  | Is the System key pressed? |
| `bool` | [`capsLock`](#capslock)  | Is the CapsLock key toggled? |
| `bool` | [`numLock`](#numlock)  | Is the NumLock key toggled? |
| `bool` | [`scrollLock`](#scrolllock)  | Is the ScrollLock key toggled? (Not supported on macOS) |

---

{#code}

### code

```cpp
Keyboard::Key code {}
```

Type: [`Keyboard::Key`](Key.md#key)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:102

Code of the key that has been pressed.

---

{#scancode}

### scancode

```cpp
Keyboard::Scancode scancode {}
```

Type: [`Keyboard::Scancode`](Scan.md#scan)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:103

Physical code of the key that has been pressed.

---

{#alt}

### alt

```cpp
bool alt {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:104

Is the Alt key pressed?

---

{#control}

### control

```cpp
bool control {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:105

Is the Control key pressed?

---

{#shift}

### shift

```cpp
bool shift {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:106

Is the Shift key pressed?

---

{#system}

### system

```cpp
bool system {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:107

Is the System key pressed?

---

{#capslock}

### capsLock

```cpp
bool capsLock {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:108

Is the CapsLock key toggled?

---

{#numlock}

### numLock

```cpp
bool numLock {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:109

Is the NumLock key toggled?

---

{#scrolllock}

### scrollLock

```cpp
bool scrollLock {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:110

Is the ScrollLock key toggled? (Not supported on macOS)

