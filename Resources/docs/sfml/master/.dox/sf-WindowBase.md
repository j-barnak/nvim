{#windowbase-2}

# WindowBase

```cpp
#include <WindowBase.hpp>
```

```cpp
class WindowBase
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:62

> **Subclassed by:** [`Window`](sf-Window.md#window)

[Window](sf-Window.md#window) that serves as a base for other windows.

`[sf::WindowBase](#windowbase-2)` serves as the base class for all Windows.

A `[sf::WindowBase](#windowbase-2)` can create its own new window, or be embedded into an already existing control using the `create(handle)` function.

The `[sf::WindowBase](#windowbase-2)` class provides a simple interface for manipulating the window: move, resize, show/hide, control mouse cursor, etc. It also provides event handling through its `[pollEvent()](#pollevent)` and `[waitEvent()](#waitevent)` functions.

Usage example: 
```cpp
// Declare and create a new window
sf::WindowBase window(sf::VideoMode({800, 600}), "SFML window");

// The main loop - ends as soon as the window is closed
while (window.isOpen())
{
   // Event processing
   while (const std::optional event = window.pollEvent())
   {
       // Request for closing the window
       if (event->is<sf::Event::Closed>())
           window.close();
   }

   // Do things with the window here...
}
```

## Friends

| Name | Description |
|------|-------------|
| [`Window`](#window-8)  |  |

---

{#window-8}

### Window

```cpp
friend class Window
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:586

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`WindowBase`](#windowbase-3)  | Default constructor. |
|  | [`WindowBase`](#windowbase-4)  | Construct a new window. |
|  | [`WindowBase`](#windowbase-5)  | Construct a new window. |
|  | [`WindowBase`](#windowbase-6) `explicit` | Construct the window from an existing control. |
|  | [`~WindowBase`](#windowbase-7) `virtual` | Destructor. |
|  | [`WindowBase`](#windowbase-8)  | Deleted copy constructor. |
| [`WindowBase`](#windowbase-2) & | [`operator=`](#operator-24)  | Deleted copy assignment. |
|  | [`WindowBase`](#windowbase-9) `noexcept` | Move constructor. |
| [`WindowBase`](#windowbase-2) & | [`operator=`](#operator-25) `noexcept` | Move assignment. |
| `void` | [`create`](#create-6) `virtual` | Create (or recreate) the window. |
| `void` | [`create`](#create-7) `virtual` | Create (or recreate) the window. |
| `void` | [`create`](#create-8) `virtual` | Create (or recreate) the window from an existing control. |
| `void` | [`close`](#close-3) `virtual` | Close the window and destroy all the attached resources. |
| `bool` | [`isOpen`](#isopen) `const` `nodiscard` | Tell whether or not the window is open. |
| std::optional< [`Event`](sf-Event.md#event) > | [`pollEvent`](#pollevent) `nodiscard` | Pop the next event from the front of the FIFO event queue, if any, and return it. |
| std::optional< [`Event`](sf-Event.md#event) > | [`waitEvent`](#waitevent) `nodiscard` | Wait for an event and return it. |
| `void` | [`handleEvents`](#handleevents)  | Handle all pending events. |
| [`Vector2i`](sf.md#vector2i) | [`getPosition`](#getposition-2) `const` `nodiscard` | Get the position of the window. |
| `void` | [`setPosition`](#setposition-2)  | Change the position of the window on screen. |
| [`Vector2u`](sf.md#vector2u) | [`getSize`](#getsize-4) `const` `nodiscard` | Get the size of the rendering region of the window. |
| `void` | [`setSize`](#setsize)  | Change the size of the rendering region of the window. |
| `void` | [`setMinimumSize`](#setminimumsize)  | Set the minimum window rendering region size. |
| `void` | [`setMaximumSize`](#setmaximumsize)  | Set the maximum window rendering region size. |
| `void` | [`setTitle`](#settitle)  | Change the title of the window. |
| `void` | [`setIcon`](#seticon)  | Change the window's icon. |
| `void` | [`setVisible`](#setvisible)  | Show or hide the window. |
| `void` | [`setMouseCursorVisible`](#setmousecursorvisible)  | Show or hide the mouse cursor. |
| `void` | [`setMouseCursorGrabbed`](#setmousecursorgrabbed)  | Grab or release the mouse cursor. |
| `void` | [`setMouseCursor`](#setmousecursor)  | Set the displayed cursor to a native system cursor. |
| `void` | [`setKeyRepeatEnabled`](#setkeyrepeatenabled)  | Enable or disable automatic key-repeat. |
| `void` | [`setJoystickThreshold`](#setjoystickthreshold)  | Change the joystick threshold. |
| `void` | [`requestFocus`](#requestfocus)  | Request the current window to be made the active foreground window. |
| `bool` | [`hasFocus`](#hasfocus) `const` `nodiscard` | Check whether the window has the input focus. |
| `WindowHandle` | [`getNativeHandle`](#getnativehandle) `const` `nodiscard` | Get the OS-specific handle of the window. |
| `bool` | [`createVulkanSurface`](#createvulkansurface) `nodiscard` | Create a [Vulkan](sf-Vulkan.md#vulkan) rendering surface. |

---

{#windowbase-3}

### WindowBase

```cpp
WindowBase()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:72

Default constructor.

This constructor doesn't actually create the window, use the other constructors or call `[create()](#create-6)` to do so.

---

{#windowbase-4}

### WindowBase

```cpp
WindowBase(VideoMode mode, const String & title, std::uint32_t style = Style::Default, State state = State::Windowed)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:90

Construct a new window.

This constructor creates the window with the size and pixel depth defined in `mode`. An optional style can be passed to customize the look and behavior of the window (borders, title bar, resizable, closable, ...). An optional state can be provided. If `state` is `[State::Fullscreen](window.md#group__window_1gga504e2cd8fc6a852463f8d049db1151e5a0829ea6734059d66e6bf87096b215dc1)`, then `mode` must be a valid video mode.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mode` | [`VideoMode`](sf-VideoMode.md#videomode) | Video mode to use (defines the width, height and depth of the rendering area of the window) |
| `title` | const [`String`](sf-String.md#string) & | Title of the window |
| `style` | `std::uint32_t` | Window style, a bitwise OR combination of `[sf::Style](sf-Style.md#style-1)` enumerators |
| `state` | [`State`](State.md#state) | Window state |

---

{#windowbase-5}

### WindowBase

```cpp
WindowBase(VideoMode mode, const String & title, State state)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:103

Construct a new window.

This constructor creates the window with the size and pixel depth defined in `mode`.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mode` | [`VideoMode`](sf-VideoMode.md#videomode) | Video mode to use (defines the width, height and depth of the rendering area of the window) |
| `title` | const [`String`](sf-String.md#string) & | Title of the window |
| `state` | [`State`](State.md#state) | Window state |

---

{#windowbase-6}

### WindowBase

`explicit`

```cpp
explicit WindowBase(WindowHandle handle)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:111

Construct the window from an existing control.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `handle` | `WindowHandle` | Platform-specific handle of the control |

---

{#windowbase-7}

### ~WindowBase

`virtual`

```cpp
virtual ~WindowBase()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:119

Destructor.

Closes the window and frees all the resources attached to it.

---

{#windowbase-8}

### WindowBase

```cpp
WindowBase(const WindowBase &) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:125

Deleted copy constructor.

---

{#operator-24}

### operator=

```cpp
WindowBase & operator=(const WindowBase &) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:131

Deleted copy assignment.

---

{#windowbase-9}

### WindowBase

`noexcept`

```cpp
WindowBase(WindowBase &&) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:137

Move constructor.

---

{#operator-25}

### operator=

`noexcept`

```cpp
WindowBase & operator=(WindowBase &&) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:143

Move assignment.

---

{#create-6}

### create

`virtual`

```cpp
virtual void create(VideoMode mode, const String & title, std::uint32_t style = Style::Default, State state = State::Windowed)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:158

Create (or recreate) the window.

If the window was already created, it closes it first. If `state` is `[State::Fullscreen](window.md#group__window_1gga504e2cd8fc6a852463f8d049db1151e5a0829ea6734059d66e6bf87096b215dc1)`, then `mode` must be a valid video mode.

#### Reimplemented by

- [`create`](sf-Window.md#create)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mode` | [`VideoMode`](sf-VideoMode.md#videomode) | Video mode to use (defines the width, height and depth of the rendering area of the window) |
| `title` | const [`String`](sf-String.md#string) & | Title of the window |
| `style` | `std::uint32_t` | Window style, a bitwise OR combination of `[sf::Style](sf-Style.md#style-1)` enumerators |
| `state` | [`State`](State.md#state) | Window state |

---

{#create-7}

### create

`virtual`

```cpp
virtual void create(VideoMode mode, const String & title, State state)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:172

Create (or recreate) the window.

If the window was already created, it closes it first. If `state` is `[State::Fullscreen](window.md#group__window_1gga504e2cd8fc6a852463f8d049db1151e5a0829ea6734059d66e6bf87096b215dc1)`, then `mode` must be a valid video mode.

#### Reimplemented by

- [`create`](sf-Window.md#create-2)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mode` | [`VideoMode`](sf-VideoMode.md#videomode) | Video mode to use (defines the width, height and depth of the rendering area of the window) |
| `title` | const [`String`](sf-String.md#string) & | Title of the window |
| `state` | [`State`](State.md#state) | Window state |

---

{#create-8}

### create

`virtual`

```cpp
virtual void create(WindowHandle handle)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:180

Create (or recreate) the window from an existing control.

#### Reimplemented by

- [`create`](sf-Window.md#create-4)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `handle` | `WindowHandle` | Platform-specific handle of the control |

---

{#close-3}

### close

`virtual`

```cpp
virtual void close()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:192

Close the window and destroy all the attached resources.

After calling this function, the `[sf::Window](sf-Window.md#window)` instance remains valid and you can call `[create()](#create-6)` to recreate the window. All other functions such as `[pollEvent()](#pollevent)` or `display()` will still work (i.e. you don't have to test `[isOpen()](#isopen)` every time), and will have no effect on closed windows.

#### Reimplemented by

- [`close`](sf-Window.md#close-2)

---

{#isopen}

### isOpen

`const` `nodiscard`

```cpp
[[nodiscard]] bool isOpen() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:204

Tell whether or not the window is open.

This function returns whether or not the window exists. Note that a hidden window (`setVisible(false)`) is open (therefore this function would return `true`).

#### Returns
`true` if the window is open, `false` if it has been closed

---

{#pollevent}

### pollEvent

`nodiscard`

```cpp
[[nodiscard]] std::optional< Event > pollEvent()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:226

Pop the next event from the front of the FIFO event queue, if any, and return it.

This function is not blocking: if there's no pending event then it will return a `std::nullopt`. Note that more than one event may be present in the event queue, thus you should always call this function in a loop to make sure that you process every pending event. 
```cpp
while (const std::optional event = window.pollEvent())
{
   // process event...
}
```

#### Returns
The event, otherwise `std::nullopt` if no events are pending

**See also**: `[waitEvent](#waitevent)`, `[handleEvents](#handleevents)`

---

{#waitevent}

### waitEvent

`nodiscard`

```cpp
[[nodiscard]] std::optional< Event > waitEvent(Time timeout = Time::Zero)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:252

Wait for an event and return it.

This function is blocking: if there's no pending event then it will wait until an event is received or until the provided timeout elapses. Only if an error or a timeout occurs the returned event will be `std::nullopt`. This function is typically used when you have a thread that is dedicated to events handling: you want to make this thread sleep as long as no new event is received. 
```cpp
while (const std::optional event = window.waitEvent())
{
   // process event...
}
```

#### Returns
The event, otherwise `std::nullopt` on timeout or if window was closed

**See also**: `[pollEvent](#pollevent)`, `[handleEvents](#handleevents)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `timeout` | [`Time`](sf-Time.md#time) | Maximum time to wait (`[Time::Zero](sf-Time.md#zero-1)` for infinite) |

---

{#handleevents}

### handleEvents

```cpp
template<typename... Handlers> void handleEvents(Handlers &&... handlers)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:330

Handle all pending events.

This function is not blocking: if there's no pending event then it will return without calling any of the handlers.

This function can take a variadic list of event handlers that each take a concrete event type as a single parameter. The event handlers can be any kind of callable object that has an `operator()` defined for a specific event type. Additionally a generic callable can also be provided that will be invoked for every event type. If both types of callables are provided, the callables taking concrete event types will be preferred over the generic callable by overload resolution. Generic callables can be used to customize handler dispatching based on the deduced type of the event and other information available at compile time.

Examples of callables:

* Lambda expressions: `[&](const [sf::Event::KeyPressed](sf-Event-KeyPressed.md#keypressed)) { ... }`
* Free functions: `void handler(const [sf::Event::KeyPressed](sf-Event-KeyPressed.md#keypressed)&) { ... }`

```cpp
// Only provide handlers for concrete event types
window.handleEvents(
    [&](const sf::Event::Closed&) { /* handle event */ },
    [&](const sf::Event::KeyPressed& keyPress) { /* handle event */ }
);
```

```cpp
// Provide a generic event handler
window.handleEvents(
    [&](const auto& event)
    {
        if constexpr (std::is_same_v<std::decay_t<decltype(event)>, sf::Event::Closed>)
        {
            // Handle Closed
            handleClosed();
        }
        else if constexpr (std::is_same_v<std::decay_t<decltype(event)>, sf::Event::KeyPressed>)
        {
            // Handle KeyPressed
            handleKeyPressed(event);
        }
        else
        {
            // Handle non-KeyPressed
            handleOtherEvents(event);
        }
    }
);
```

```cpp
// Provide handlers for concrete types and fall back to generic handler
window.handleEvents(
    [&](const sf::Event::Closed&) { /* handle event */ },
    [&](const sf::Event::KeyPressed& keyPress) { /* handle event */ },
    [&](const auto& event) { /* handle all other events */ }
);
```

Calling member functions is supported through lambda expressions. 
```cpp
// Provide a generic event handler
window.handleEvents(
    [this](const auto& event) { handle(event); }
);
```

**See also**: `[waitEvent](#waitevent)`, `[pollEvent](#pollevent)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `handlers` | `Handlers &&...` | A variadic list of callables that take a specific event as their only parameter |

---

{#getposition-2}

### getPosition

`const` `nodiscard`

```cpp
[[nodiscard]] Vector2i getPosition() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:340

Get the position of the window.

#### Returns
Position of the window, in pixels

**See also**: `[setPosition](#setposition-2)`

---

{#setposition-2}

### setPosition

```cpp
void setPosition(Vector2i position)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:354

Change the position of the window on screen.

This function only works for top-level windows (i.e. it will be ignored for windows created from the handle of a child window/control).

**See also**: `[getPosition](#getposition-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `position` | [`Vector2i`](sf.md#vector2i) | New position, in pixels |

---

{#getsize-4}

### getSize

`const` `nodiscard`

```cpp
[[nodiscard]] Vector2u getSize() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:367

Get the size of the rendering region of the window.

The size doesn't include the titlebar and borders of the window.

#### Returns
Size in pixels

**See also**: `[setSize](#setsize)`

---

{#setsize}

### setSize

```cpp
void setSize(Vector2u size)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:377

Change the size of the rendering region of the window.

**See also**: `[getSize](#getsize-4)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `size` | [`Vector2u`](sf.md#vector2u) | New size, in pixels |

---

{#setminimumsize}

### setMinimumSize

```cpp
void setMinimumSize(const std::optional< Vector2u > & minimumSize)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:387

Set the minimum window rendering region size.

Pass `std::nullopt` to unset the minimum size

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `minimumSize` | const std::optional< [`Vector2u`](sf.md#vector2u) > & | New minimum size, in pixels |

---

{#setmaximumsize}

### setMaximumSize

```cpp
void setMaximumSize(const std::optional< Vector2u > & maximumSize)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:397

Set the maximum window rendering region size.

Pass `std::nullopt` to unset the maximum size

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `maximumSize` | const std::optional< [`Vector2u`](sf.md#vector2u) > & | New maximum size, in pixels |

---

{#settitle}

### setTitle

```cpp
void setTitle(const String & title)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:407

Change the title of the window.

**See also**: `[setIcon](#seticon)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `title` | const [`String`](sf-String.md#string) & | New title |

---

{#seticon}

### setIcon

```cpp
void setIcon(Vector2u size, const std::uint8_t * pixels)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:425

Change the window's icon.

`pixels` must be an array of `size` pixels in 32-bits RGBA format.

The OS default icon is used by default.

**See also**: `[setTitle](#settitle)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `size` | [`Vector2u`](sf.md#vector2u) | Icon's width and height, in pixels |
| `pixels` | `const std::uint8_t *` | Pointer to the array of pixels in memory. The pixels are copied, so you need not keep the source alive after calling this function. |

---

{#setvisible}

### setVisible

```cpp
void setVisible(bool visible)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:435

Show or hide the window.

The window is shown by default.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `visible` | `bool` | `true` to show the window, `false` to hide it |

---

{#setmousecursorvisible}

### setMouseCursorVisible

```cpp
void setMouseCursorVisible(bool visible)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:448

Show or hide the mouse cursor.

The mouse cursor is visible by default.

:::warning
On Windows, this function needs to be called from the thread that created the window.

:::

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `visible` | `bool` | `true` to show the mouse cursor, `false` to hide it |

---

{#setmousecursorgrabbed}

### setMouseCursorGrabbed

```cpp
void setMouseCursorGrabbed(bool grabbed)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:461

Grab or release the mouse cursor.

If set, grabs the mouse cursor inside this window's client area so it may no longer be moved outside its bounds. Note that grabbing is only active while the window has focus.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `grabbed` | `bool` | `true` to enable, `false` to disable |

---

{#setmousecursor}

### setMouseCursor

```cpp
void setMouseCursor(const Cursor & cursor)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:479

Set the displayed cursor to a native system cursor.

Upon window creation, the arrow cursor is used by default.

:::warning
The cursor must not be destroyed while in use by the window.

:::

:::warning
Features related to [Cursor](sf-Cursor.md#cursor) are not supported on iOS and Android.

:::

**See also**: `[sf::Cursor::createFromSystem](sf-Cursor.md#createfromsystem)`, `[sf::Cursor::createFromPixels](sf-Cursor.md#createfrompixels)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `cursor` | const [`Cursor`](sf-Cursor.md#cursor) & | Native system cursor type to display |

---

{#setkeyrepeatenabled}

### setKeyRepeatEnabled

```cpp
void setKeyRepeatEnabled(bool enabled)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:493

Enable or disable automatic key-repeat.

If key repeat is enabled, you will receive repeated KeyPressed events while keeping a key pressed. If it is disabled, you will only get a single event when the key is pressed.

Key repeat is enabled by default.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `enabled` | `bool` | `true` to enable, `false` to disable |

---

{#setjoystickthreshold}

### setJoystickThreshold

```cpp
void setJoystickThreshold(float threshold)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:506

Change the joystick threshold.

The joystick threshold is the value below which no JoystickMoved event will be generated.

The threshold value is 0.1 by default.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `threshold` | `float` | New threshold, in the range [0, 100] |

---

{#requestfocus}

### requestFocus

```cpp
void requestFocus()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:522

Request the current window to be made the active foreground window.

At any given time, only one window may have the input focus to receive input events such as keystrokes or mouse events. If a window requests focus, it only hints to the operating system, that it would like to be focused. The operating system is free to deny the request. This is not to be confused with `setActive()`.

**See also**: `[hasFocus](#hasfocus)`

---

{#hasfocus}

### hasFocus

`const` `nodiscard`

```cpp
[[nodiscard]] bool hasFocus() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:535

Check whether the window has the input focus.

At any given time, only one window may have the input focus to receive input events such as keystrokes or most mouse events.

#### Returns
`true` if window has focus, `false` otherwise 

**See also**: `[requestFocus](#requestfocus)`

---

{#getnativehandle}

### getNativeHandle

`const` `nodiscard`

```cpp
[[nodiscard]] WindowHandle getNativeHandle() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:549

Get the OS-specific handle of the window.

The type of the returned handle is `sf::WindowHandle`, which is a type alias to the handle type defined by the OS. You shouldn't need to use this function, unless you have very specific stuff to implement that SFML doesn't support, or implement a temporary workaround until a bug is fixed.

#### Returns
System handle of the window

---

{#createvulkansurface}

### createVulkanSurface

`nodiscard`

```cpp
[[nodiscard]] bool createVulkanSurface(const VkInstance & instance, VkSurfaceKHR & surface, const VkAllocationCallbacks * allocator = nullptr)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:561

Create a [Vulkan](sf-Vulkan.md#vulkan) rendering surface.

#### Returns
`true` if surface creation was successful, `false` otherwise

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `instance` | const [`VkInstance`](api.md#vkinstance) & | [Vulkan](sf-Vulkan.md#vulkan) instance |
| `surface` | [`VkSurfaceKHR`](api.md#vksurfacekhr) & | Created surface |
| `allocator` | `const VkAllocationCallbacks *` | Allocator to use |

## Protected Methods

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`onCreate`](#oncreate) `virtual` | Function called after the window has been created. |
| `void` | [`onResize`](#onresize) `virtual` | Function called after the window has been resized. |

---

{#oncreate}

### onCreate

`virtual`

```cpp
virtual void onCreate()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:574

Function called after the window has been created.

This function is called so that derived classes can perform their own specific initialization as soon as the window is created.

#### Reimplemented by

- [`onCreate`](sf-RenderWindow.md#oncreate-1)

---

{#onresize}

### onResize

`virtual`

```cpp
virtual void onResize()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:583

Function called after the window has been resized.

This function is called so that derived classes can perform custom actions when the size of the window changes.

#### Reimplemented by

- [`onResize`](sf-RenderWindow.md#onresize-1)

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::unique_ptr< priv::WindowImpl >` | [`m_impl`](#m_impl-5)  | Platform-specific implementation of the window. |
| [`Vector2u`](sf.md#vector2u) | [`m_size`](#m_size-1)  | Current size of the window. |

---

{#m_impl-5}

### m_impl

```cpp
std::unique_ptr< priv::WindowImpl > m_impl
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:611

Platform-specific implementation of the window.

---

{#m_size-1}

### m_size

```cpp
Vector2u m_size
```

Type: [`Vector2u`](sf.md#vector2u)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:612

Current size of the window.

## Private Methods

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`filterEvent`](#filterevent)  | Processes an event before it is sent to the user. |
| `void` | [`initialize`](#initialize-3)  | Perform some common internal initializations. |

---

{#filterevent}

### filterEvent

```cpp
void filterEvent(const Event & event)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:600

Processes an event before it is sent to the user.

This function is called every time an event is received from the internal window (through `pollEvent` or `waitEvent`). It filters out unwanted events, and performs whatever internal stuff the window needs before the event is returned to the user.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `event` | const [`Event`](sf-Event.md#event) & | [Event](sf-Event.md#event) to filter |

---

{#initialize-3}

### initialize

```cpp
void initialize()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.hpp:606

Perform some common internal initializations.

