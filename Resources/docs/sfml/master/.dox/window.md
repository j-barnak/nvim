{#windowmodule}

# Window module

Provides OpenGL-based windows, and abstractions for events and input handling.

## Classes

| Name | Description |
|------|-------------|
| [`Context`](sf-Context.md#context) | Class holding a valid drawing context. |
| [`ContextSettings`](sf-ContextSettings.md#contextsettings) | Structure defining the settings of the OpenGL context attached to a window. |
| [`Cursor`](sf-Cursor.md#cursor) | [Cursor](sf-Cursor.md#cursor) defines the appearance of a system cursor. |
| [`Event`](sf-Event.md#event) | Defines a system event and its parameters. |
| [`GlResource`](sf-GlResource.md#glresource) | Base class for classes that require an OpenGL context. |
| [`VideoMode`](sf-VideoMode.md#videomode) | [VideoMode](sf-VideoMode.md#videomode) defines a video mode (size, bpp) |
| [`Window`](sf-Window.md#window) | [Window](sf-Window.md#window) that serves as a target for OpenGL rendering. |
| [`WindowBase`](sf-WindowBase.md#windowbase-2) | [Window](sf-Window.md#window) that serves as a base for other windows. |

## Enumerations

| Name | Description |
|------|-------------|
| [`State`](#state)  | Enumeration of the window states. |

---

{#state}

### State

```cpp
enum State
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowEnums.hpp:59

Enumeration of the window states.

| Value | Description |
|-------|-------------|
| `Windowed` | Floating window. |
| `Fullscreen` | Fullscreen window. |
