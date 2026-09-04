{#clipboard}

# Clipboard

Give access to the system clipboard.

`[sf::Clipboard](#clipboard)` provides an interface for getting and setting the contents of the system clipboard.

It is important to note that due to limitations on some operating systems, setting the clipboard contents is only guaranteed to work if there is currently an open window for which events are being handled.

Usage example: 
```cpp
// get the clipboard content as a string
sf::String string = sf::Clipboard::getString();

// or use it in the event loop
while (const std::optional event = window.pollEvent())
{
    if (event->is<sf::Event::Closed>())
        window.close();

    if (const auto* keyPressed = event->getIf<sf::Event::KeyPressed>())
    {
        // Using Ctrl + V to paste a string into SFML
        if (keyPressed->control && keyPressed->code == sf::Keyboard::Key::V)
            string = sf::Clipboard::getString();

        // Using Ctrl + C to copy a string out of SFML
        if (keyPressed->control && keyPressed->code == sf::Keyboard::Key::C)
            sf::Clipboard::setString("Hello World!");
    }
}
```

**See also**: `[sf::String](sf-String.md#string)`, `[sf::Event](sf-Event.md#event)`

## Functions

| Return | Name | Description |
|--------|------|-------------|
| [`SFML_WINDOW_API`](api.md#sfml_window_api)[`String`](sf-String.md#string) | [`getString`](#getstring) `nodiscard` | Get the content of the clipboard as string data. |
| [`SFML_WINDOW_API`](api.md#sfml_window_api) void | [`setString`](#setstring)  | Set the content of the clipboard as string data. |

---

{#getstring}

### getString

`nodiscard`

```cpp
[[nodiscard]] SFML_WINDOW_APIString getString()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Clipboard.hpp:53

Get the content of the clipboard as string data.

This function returns the content of the clipboard as a string. If the clipboard does not contain string it returns an empty `[sf::String](sf-String.md#string)` object.

#### Returns
[Clipboard](#clipboard) contents as `[sf::String](sf-String.md#string)` object

---

{#setstring}

### setString

```cpp
SFML_WINDOW_API void setString(const String & text)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Clipboard.hpp:70

Set the content of the clipboard as string data.

This function sets the content of the clipboard as a string.

:::warning
Due to limitations on some operating systems, setting the clipboard contents is only guaranteed to work if there is currently an open window for which events are being handled.

:::

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `text` | const [`String`](sf-String.md#string) & | `[sf::String](sf-String.md#string)` containing the data to be sent to the clipboard |

