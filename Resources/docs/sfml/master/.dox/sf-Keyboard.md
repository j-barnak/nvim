{#keyboard}

# Keyboard

Give access to the real-time state of the keyboard.

`[sf::Keyboard](#keyboard)` provides an interface to the state of the keyboard.

This namespace allows users to query the keyboard state at any time and directly, without having to deal with a window and its events. Compared to the `KeyPressed` and `KeyReleased` events, `[sf::Keyboard](#keyboard)` can retrieve the state of a key at any time (you don't need to store and update a boolean on your side in order to know if a key is pressed or released), and you always get the real state of the keyboard, even if keys are pressed or released when your window is out of focus and no event is triggered.

Usage example: 
```cpp
if (sf::Keyboard::isKeyPressed(sf::Keyboard::Key::Left))
{
    // move left...
}
else if (sf::Keyboard::isKeyPressed(sf::Keyboard::Key::Right))
{
    // move right...
}
else if (sf::Keyboard::isKeyPressed(sf::Keyboard::Key::Escape))
{
    // quit...
}
else if (sf::Keyboard::isKeyPressed(sf::Keyboard::Scan::Grave))
{
    // open in-game command line (if it's not already open)
}
```

**See also**: `[sf::Joystick](sf-Joystick.md#joystick)`, `[sf::Mouse](sf-Mouse.md#mouse)`, `[sf::Touch](sf-Touch.md#touch)`

## Enumerations

| Name | Description |
|------|-------------|
| [`Key`](#key)  | [Key](Key.md#key) codes. |
| [`Scan`](#scan)  | Scancodes. |

---

{#key}

### Key

```cpp
enum Key
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Keyboard.hpp:51

[Key](Key.md#key) codes.

The enumerators refer to the "localized" key; i.e. depending on the layout set by the operating system, a key can be mapped to `Y` or `Z`.

| Value | Description |
|-------|-------------|
| `Unknown` | Unhandled key. |
| `A` | The A key. |
| `B` | The B key. |
| `C` | The C key. |
| `D` | The D key. |
| `E` | The E key. |
| `F` | The F key. |
| `G` | The G key. |
| `H` | The H key. |
| `I` | The I key. |
| `J` | The J key. |
| `K` | The K key. |
| `L` | The L key. |
| `M` | The M key. |
| `N` | The N key. |
| `O` | The O key. |
| `P` | The P key. |
| `Q` | The Q key. |
| `R` | The R key. |
| `S` | The S key. |
| `T` | The T key. |
| `U` | The U key. |
| `V` | The V key. |
| `W` | The W key. |
| `X` | The X key. |
| `Y` | The Y key. |
| `Z` | The Z key. |
| `Num0` | The 0 key. |
| `Num1` | The 1 key. |
| `Num2` | The 2 key. |
| `Num3` | The 3 key. |
| `Num4` | The 4 key. |
| `Num5` | The 5 key. |
| `Num6` | The 6 key. |
| `Num7` | The 7 key. |
| `Num8` | The 8 key. |
| `Num9` | The 9 key. |
| `Escape` | The Escape key. |
| `LControl` | The left Control key. |
| `LShift` | The left Shift key. |
| `LAlt` | The left Alt key. |
| `LSystem` | The left OS specific key: window (Windows and Linux), apple (macOS), ... |
| `RControl` | The right Control key. |
| `RShift` | The right Shift key. |
| `RAlt` | The right Alt key. |
| `RSystem` | The right OS specific key: window (Windows and Linux), apple (macOS), ... |
| `Menu` | The Menu key. |
| `LBracket` | The [ key. |
| `RBracket` | The ] key. |
| `Semicolon` | The ; key. |
| `Comma` | The , key. |
| `Period` | The . key. |
| `Apostrophe` | The ' key. |
| `Slash` | The / key. |
| `Backslash` | The \ key. |
| `Grave` | The ` key. |
| `Equal` | The = key. |
| `Hyphen` | The - key (hyphen) |
| `Space` | The Space key. |
| `Enter` | The Enter/Return keys. |
| `Backspace` | The Backspace key. |
| `Tab` | The Tabulation key. |
| `PageUp` | The Page up key. |
| `PageDown` | The Page down key. |
| `End` | The End key. |
| `Home` | The Home key. |
| `Insert` | The Insert key. |
| `Delete` | The Delete key. |
| `Add` | The + key. |
| `Subtract` | The - key (minus, usually from numpad) |
| `Multiply` | The * key. |
| `Divide` | The / key. |
| `Left` | Left arrow. |
| `Right` | Right arrow. |
| `Up` | Up arrow. |
| `Down` | Down arrow. |
| `Numpad0` | The numpad 0 key. |
| `Numpad1` | The numpad 1 key. |
| `Numpad2` | The numpad 2 key. |
| `Numpad3` | The numpad 3 key. |
| `Numpad4` | The numpad 4 key. |
| `Numpad5` | The numpad 5 key. |
| `Numpad6` | The numpad 6 key. |
| `Numpad7` | The numpad 7 key. |
| `Numpad8` | The numpad 8 key. |
| `Numpad9` | The numpad 9 key. |
| `F1` | The F1 key. |
| `F2` | The F2 key. |
| `F3` | The F3 key. |
| `F4` | The F4 key. |
| `F5` | The F5 key. |
| `F6` | The F6 key. |
| `F7` | The F7 key. |
| `F8` | The F8 key. |
| `F9` | The F9 key. |
| `F10` | The F10 key. |
| `F11` | The F11 key. |
| `F12` | The F12 key. |
| `F13` | The F13 key. |
| `F14` | The F14 key. |
| `F15` | The F15 key. |
| `Pause` | The Pause key. |

---

{#scan}

### Scan

```cpp
enum Scan
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Keyboard.hpp:172

Scancodes.

The enumerators are bound to a physical key and do not depend on the keyboard layout used by the operating system. Usually, the AT-101 keyboard can be used as reference for the physical position of the keys.

| Value | Description |
|-------|-------------|
| `Unknown` | Represents any scancode not present in this enum. |
| `A` | [Keyboard](#keyboard) a and A key. |
| `B` | [Keyboard](#keyboard) b and B key. |
| `C` | [Keyboard](#keyboard) c and C key. |
| `D` | [Keyboard](#keyboard) d and D key. |
| `E` | [Keyboard](#keyboard) e and E key. |
| `F` | [Keyboard](#keyboard) f and F key. |
| `G` | [Keyboard](#keyboard) g and G key. |
| `H` | [Keyboard](#keyboard) h and H key. |
| `I` | [Keyboard](#keyboard) i and I key. |
| `J` | [Keyboard](#keyboard) j and J key. |
| `K` | [Keyboard](#keyboard) k and K key. |
| `L` | [Keyboard](#keyboard) l and L key. |
| `M` | [Keyboard](#keyboard) m and M key. |
| `N` | [Keyboard](#keyboard) n and N key. |
| `O` | [Keyboard](#keyboard) o and O key. |
| `P` | [Keyboard](#keyboard) p and P key. |
| `Q` | [Keyboard](#keyboard) q and Q key. |
| `R` | [Keyboard](#keyboard) r and R key. |
| `S` | [Keyboard](#keyboard) s and S key. |
| `T` | [Keyboard](#keyboard) t and T key. |
| `U` | [Keyboard](#keyboard) u and U key. |
| `V` | [Keyboard](#keyboard) v and V key. |
| `W` | [Keyboard](#keyboard) w and W key. |
| `X` | [Keyboard](#keyboard) x and X key. |
| `Y` | [Keyboard](#keyboard) y and Y key. |
| `Z` | [Keyboard](#keyboard) z and Z key. |
| `Num1` | [Keyboard](#keyboard) 1 and ! key. |
| `Num2` | [Keyboard](#keyboard) 2 and @ key. |
| `Num3` | [Keyboard](#keyboard) 3 and # key. |
| `Num4` | [Keyboard](#keyboard) 4 and $ key. |
| `Num5` | [Keyboard](#keyboard) 5 and % key. |
| `Num6` | [Keyboard](#keyboard) 6 and ^ key. |
| `Num7` | [Keyboard](#keyboard) 7 and & key. |
| `Num8` | [Keyboard](#keyboard) 8 and * key. |
| `Num9` | [Keyboard](#keyboard) 9 and ) key. |
| `Num0` | [Keyboard](#keyboard) 0 and ) key. |
| `Enter` | [Keyboard](#keyboard) Enter/Return key. |
| `Escape` | [Keyboard](#keyboard) Escape key. |
| `Backspace` | [Keyboard](#keyboard) Backspace key. |
| `Tab` | [Keyboard](#keyboard) Tab key. |
| `Space` | [Keyboard](#keyboard) Space key. |
| `Hyphen` | [Keyboard](#keyboard) - and _ key. |
| `Equal` | [Keyboard](#keyboard) = and +. |
| `LBracket` | [Keyboard](#keyboard) [ and { key. |
| `RBracket` | [Keyboard](#keyboard) ] and } key. |
| `Backslash` | [Keyboard](#keyboard) \ and | key OR various keys for Non-US keyboards. |
| `Semicolon` | [Keyboard](#keyboard) ; and : key. |
| `Apostrophe` | [Keyboard](#keyboard) ' and " key. |
| `Grave` | [Keyboard](#keyboard) ` and ~ key. |
| `Comma` | [Keyboard](#keyboard) , and < key. |
| `Period` | [Keyboard](#keyboard) . and > key. |
| `Slash` | [Keyboard](#keyboard) / and ? key. |
| `F1` | [Keyboard](#keyboard) F1 key. |
| `F2` | [Keyboard](#keyboard) F2 key. |
| `F3` | [Keyboard](#keyboard) F3 key. |
| `F4` | [Keyboard](#keyboard) F4 key. |
| `F5` | [Keyboard](#keyboard) F5 key. |
| `F6` | [Keyboard](#keyboard) F6 key. |
| `F7` | [Keyboard](#keyboard) F7 key. |
| `F8` | [Keyboard](#keyboard) F8 key. |
| `F9` | [Keyboard](#keyboard) F9 key. |
| `F10` | [Keyboard](#keyboard) F10 key. |
| `F11` | [Keyboard](#keyboard) F11 key. |
| `F12` | [Keyboard](#keyboard) F12 key. |
| `F13` | [Keyboard](#keyboard) F13 key. |
| `F14` | [Keyboard](#keyboard) F14 key. |
| `F15` | [Keyboard](#keyboard) F15 key. |
| `F16` | [Keyboard](#keyboard) F16 key. |
| `F17` | [Keyboard](#keyboard) F17 key. |
| `F18` | [Keyboard](#keyboard) F18 key. |
| `F19` | [Keyboard](#keyboard) F19 key. |
| `F20` | [Keyboard](#keyboard) F20 key. |
| `F21` | [Keyboard](#keyboard) F21 key. |
| `F22` | [Keyboard](#keyboard) F22 key. |
| `F23` | [Keyboard](#keyboard) F23 key. |
| `F24` | [Keyboard](#keyboard) F24 key. |
| `CapsLock` | [Keyboard](#keyboard) Caps Lock key. |
| `PrintScreen` | [Keyboard](#keyboard) Print Screen key. |
| `ScrollLock` | [Keyboard](#keyboard) Scroll Lock key. |
| `Pause` | [Keyboard](#keyboard) Pause key. |
| `Insert` | [Keyboard](#keyboard) Insert key. |
| `Home` | [Keyboard](#keyboard) Home key. |
| `PageUp` | [Keyboard](#keyboard) Page Up key. |
| `Delete` | [Keyboard](#keyboard) Delete Forward key. |
| `End` | [Keyboard](#keyboard) End key. |
| `PageDown` | [Keyboard](#keyboard) Page Down key. |
| `Right` | [Keyboard](#keyboard) Right Arrow key. |
| `Left` | [Keyboard](#keyboard) Left Arrow key. |
| `Down` | [Keyboard](#keyboard) Down Arrow key. |
| `Up` | [Keyboard](#keyboard) Up Arrow key. |
| `NumLock` | Keypad Num Lock and Clear key. |
| `NumpadDivide` | Keypad / key. |
| `NumpadMultiply` | Keypad * key. |
| `NumpadMinus` | Keypad - key. |
| `NumpadPlus` | Keypad + key. |
| `NumpadEqual` | keypad = key |
| `NumpadEnter` | Keypad Enter/Return key. |
| `NumpadDecimal` | Keypad . and Delete key. |
| `Numpad1` | Keypad 1 and End key. |
| `Numpad2` | Keypad 2 and Down Arrow key. |
| `Numpad3` | Keypad 3 and Page Down key. |
| `Numpad4` | Keypad 4 and Left Arrow key. |
| `Numpad5` | Keypad 5 key. |
| `Numpad6` | Keypad 6 and Right Arrow key. |
| `Numpad7` | Keypad 7 and Home key. |
| `Numpad8` | Keypad 8 and Up Arrow key. |
| `Numpad9` | Keypad 9 and Page Up key. |
| `Numpad0` | Keypad 0 and Insert key. |
| `NonUsBackslash` | [Keyboard](#keyboard) Non-US \ and | key. |
| `Application` | [Keyboard](#keyboard) Application key. |
| `Execute` | [Keyboard](#keyboard) Execute key. |
| `ModeChange` | [Keyboard](#keyboard) Mode Change key. |
| `Help` | [Keyboard](#keyboard) Help key. |
| `Menu` | [Keyboard](#keyboard) Menu key. |
| `Select` | [Keyboard](#keyboard) Select key. |
| `Redo` | [Keyboard](#keyboard) Redo key. |
| `Undo` | [Keyboard](#keyboard) Undo key. |
| `Cut` | [Keyboard](#keyboard) Cut key. |
| `Copy` | [Keyboard](#keyboard) Copy key. |
| `Paste` | [Keyboard](#keyboard) Paste key. |
| `VolumeMute` | [Keyboard](#keyboard) Volume Mute key. |
| `VolumeUp` | [Keyboard](#keyboard) Volume Up key. |
| `VolumeDown` | [Keyboard](#keyboard) Volume Down key. |
| `MediaPlayPause` | [Keyboard](#keyboard) Media Play Pause key. |
| `MediaStop` | [Keyboard](#keyboard) Media Stop key. |
| `MediaNextTrack` | [Keyboard](#keyboard) Media Next Track key. |
| `MediaPreviousTrack` | [Keyboard](#keyboard) Media Previous Track key. |
| `LControl` | [Keyboard](#keyboard) Left Control key. |
| `LShift` | [Keyboard](#keyboard) Left Shift key. |
| `LAlt` | [Keyboard](#keyboard) Left Alt key. |
| `LSystem` | [Keyboard](#keyboard) Left System key. |
| `RControl` | [Keyboard](#keyboard) Right Control key. |
| `RShift` | [Keyboard](#keyboard) Right Shift key. |
| `RAlt` | [Keyboard](#keyboard) Right Alt key. |
| `RSystem` | [Keyboard](#keyboard) Right System key. |
| `Back` | [Keyboard](#keyboard) Back key. |
| `Forward` | [Keyboard](#keyboard) Forward key. |
| `Refresh` | [Keyboard](#keyboard) Refresh key. |
| `Stop` | [Keyboard](#keyboard) Stop key. |
| `Search` | [Keyboard](#keyboard) Search key. |
| `Favorites` | [Keyboard](#keyboard) Favorites key. |
| `HomePage` | [Keyboard](#keyboard) Home Page key. |
| `LaunchApplication1` | [Keyboard](#keyboard) Launch Application 1 key. |
| `LaunchApplication2` | [Keyboard](#keyboard) Launch Application 2 key. |
| `LaunchMail` | [Keyboard](#keyboard) Launch Mail key. |
| `LaunchMediaSelect` | [Keyboard](#keyboard) Launch Media Select key. |
## Typedefs

| Return | Name | Description |
|--------|------|-------------|
| [`Scan`](Scan.md#scan) | [`Scancode`](#scancode-2)  |  |

---

{#scancode-2}

### Scancode

```cpp
using Scancode = Scan
```

Type: [`Scan`](Scan.md#scan)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Keyboard.hpp:329

## Functions

| Return | Name | Description |
|--------|------|-------------|
| [`SFML_WINDOW_API`](api.md#sfml_window_api) bool | [`isKeyPressed`](#iskeypressed) `nodiscard` | Check if a key is pressed. |
| [`SFML_WINDOW_API`](api.md#sfml_window_api) bool | [`isKeyPressed`](#iskeypressed-1) `nodiscard` | Check if a key is pressed. |
| [`SFML_WINDOW_API`](api.md#sfml_window_api)[`Key`](Key.md#key) | [`localize`](#localize) `nodiscard` | Localize a physical key to a logical one. |
| [`SFML_WINDOW_API`](api.md#sfml_window_api)[`Scancode`](Scan.md#scan) | [`delocalize`](#delocalize) `nodiscard` | Identify the physical key corresponding to a logical one. |
| [`SFML_WINDOW_API`](api.md#sfml_window_api)[`String`](sf-String.md#string) | [`getDescription`](#getdescription) `nodiscard` | Provide a string representation for a given scancode. |
| [`SFML_WINDOW_API`](api.md#sfml_window_api) void | [`setVirtualKeyboardVisible`](#setvirtualkeyboardvisible)  | Show or hide the virtual keyboard. |

---

{#iskeypressed}

### isKeyPressed

`nodiscard`

```cpp
[[nodiscard]] SFML_WINDOW_API bool isKeyPressed(Key key)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Keyboard.hpp:349

Check if a key is pressed.

:::warning
On macOS you're required to grant input monitoring access for your application in order for `isKeyPressed` to work.

:::

#### Returns
`true` if the key is pressed, `false` otherwise

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | [`Key`](Key.md#key) | [Key](Key.md#key) to check |

---

{#iskeypressed-1}

### isKeyPressed

`nodiscard`

```cpp
[[nodiscard]] SFML_WINDOW_API bool isKeyPressed(Scancode code)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Keyboard.hpp:362

Check if a key is pressed.

:::warning
On macOS you're required to grant input monitoring access for your application in order for `isKeyPressed` to work.

:::

#### Returns
`true` if the physical key is pressed, `false` otherwise

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `code` | [`Scancode`](Scan.md#scan) | [Scancode](#scancode-2) to check |

---

{#localize}

### localize

`nodiscard`

```cpp
[[nodiscard]] SFML_WINDOW_APIKey localize(Scancode code)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Keyboard.hpp:377

Localize a physical key to a logical one.

#### Returns
The key corresponding to the scancode under the current keyboard layout used by the operating system, or `[sf::Keyboard::Key::Unknown](#namespacesf_1_1Keyboard_1acb4cacd7cc5802dec45724cf3314a142a88183b946cc5f0e8c96b2e66e1c74a7e)` when the scancode cannot be mapped to a [Key](Key.md#key).

**See also**: `[delocalize](#delocalize)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `code` | [`Scancode`](Scan.md#scan) | [Scancode](#scancode-2) to localize |

---

{#delocalize}

### delocalize

`nodiscard`

```cpp
[[nodiscard]] SFML_WINDOW_APIScancode delocalize(Key key)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Keyboard.hpp:392

Identify the physical key corresponding to a logical one.

#### Returns
The scancode corresponding to the key under the current keyboard layout used by the operating system, or `[sf::Keyboard::Scan::Unknown](#namespacesf_1_1Keyboard_1aed978288ff367518d29cfe0c9e3b295fa88183b946cc5f0e8c96b2e66e1c74a7e)` when the key cannot be mapped to a `[sf::Keyboard::Scancode](#scancode-2)`.

**See also**: `[localize](#localize)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | [`Key`](Key.md#key) | [Key](Key.md#key) to "delocalize" |

---

{#getdescription}

### getDescription

`nodiscard`

```cpp
[[nodiscard]] SFML_WINDOW_APIString getDescription(Scancode code)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Keyboard.hpp:415

Provide a string representation for a given scancode.

The returned string is a short, non-technical description of the key represented with the given scancode. Most effectively used in user interfaces, as the description for the key takes the users keyboard layout into consideration.

:::warning
The result is OS-dependent: for example, `[sf::Keyboard::Scan::LSystem](#namespacesf_1_1Keyboard_1aed978288ff367518d29cfe0c9e3b295fafc2ae39512975c67ebe724fecc528d9d)` is "Left Meta" on Linux, "Left Windows" on Windows and "Left Command" on macOS.

:::

The current keyboard layout set by the operating system is used to interpret the scancode: for example, `[sf::Keyboard::Key::Semicolon](#namespacesf_1_1Keyboard_1acb4cacd7cc5802dec45724cf3314a142a9806fa37a3ecd39bf637c203aa011ed0)` is mapped to ";" for layout and to "é" for others.

#### Returns
The localized description of the code

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `code` | [`Scancode`](Scan.md#scan) | [Scancode](#scancode-2) to check |

---

{#setvirtualkeyboardvisible}

### setVirtualKeyboardVisible

```cpp
SFML_WINDOW_API void setVirtualKeyboardVisible(bool visible)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Keyboard.hpp:430

Show or hide the virtual keyboard.

:::warning
The virtual keyboard is not supported on all systems. It will typically be implemented on mobile OSes (Android, iOS) but not on desktop OSes (Windows, Linux, ...).

:::

If the virtual keyboard is not available, this function does nothing.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `visible` | `bool` | `true` to show, `false` to hide |

## Variables

| Return | Name | Description |
|--------|------|-------------|
| `unsigned int` | [`KeyCount`](#keycount) `constexpr` | The total number of keyboard keys, ignoring `[Key::Unknown](#namespacesf_1_1Keyboard_1acb4cacd7cc5802dec45724cf3314a142a88183b946cc5f0e8c96b2e66e1c74a7e)` |
| `unsigned int` | [`ScancodeCount`](#scancodecount) `constexpr` | The total number of scancodes, ignoring `[Scan::Unknown](#namespacesf_1_1Keyboard_1aed978288ff367518d29cfe0c9e3b295fa88183b946cc5f0e8c96b2e66e1c74a7e)` |

---

{#keycount}

### KeyCount

`constexpr`

```cpp
unsigned int KeyCount {static_cast<unsigned int>(Key::Pause) + 1}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Keyboard.hpp:162

The total number of keyboard keys, ignoring `[Key::Unknown](#namespacesf_1_1Keyboard_1acb4cacd7cc5802dec45724cf3314a142a88183b946cc5f0e8c96b2e66e1c74a7e)`

---

{#scancodecount}

### ScancodeCount

`constexpr`

```cpp
unsigned int ScancodeCount {static_cast<unsigned int>(Scan::LaunchMediaSelect) + 1}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Keyboard.hpp:336

The total number of scancodes, ignoring `[Scan::Unknown](#namespacesf_1_1Keyboard_1aed978288ff367518d29cfe0c9e3b295fa88183b946cc5f0e8c96b2e66e1c74a7e)`

