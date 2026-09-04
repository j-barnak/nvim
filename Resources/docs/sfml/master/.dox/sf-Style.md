{#style-1}

# Style

## Enumerations

| Name | Description |
|------|-------------|
| [``](#unknown-1)  | Enumeration of the window styles. |

---

{#unknown-1}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowEnums.hpp:42

Enumeration of the window styles.

Note: On Unix systems, not specifying Close if Titlebar and/or Resize are specified will prevent the window manager from closing the window including using user-defined hotkeys.

| Value | Description |
|-------|-------------|
| `None` | No border / title bar (this flag and all others are mutually exclusive) |
| `Titlebar` | Title bar + fixed border. |
| `Resize` | Title bar + resizable border + maximize button. |
| `Close` | Title bar + close button (see note) |
| `Default` | Default window style. |
