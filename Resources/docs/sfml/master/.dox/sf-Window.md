{#window}

# Window

```cpp
#include <Window.hpp>
```

```cpp
class Window
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Window.hpp:55

> **Inherits:** [`WindowBase`](sf-WindowBase.md#windowbase-2), [`GlResource`](sf-GlResource.md#glresource)
> **Subclassed by:** [`RenderWindow`](sf-RenderWindow.md#renderwindow)

[Window](#window) that serves as a target for OpenGL rendering.

`[sf::Window](#window)` is the main class of the [Window](#window) module. It defines an OS window that is able to receive an OpenGL rendering.

A `[sf::Window](#window)` can create its own new window, or be embedded into an already existing control using the `create(handle)` function. This can be useful for embedding an OpenGL rendering area into a view which is part of a bigger GUI with existing windows, controls, etc. It can also serve as embedding an OpenGL rendering area into a window created by another (probably richer) GUI library like Qt or wxWidgets.

The `[sf::Window](#window)` class provides a simple interface for manipulating the window: move, resize, show/hide, control mouse cursor, etc. It also provides event handling through its `[pollEvent()](sf-WindowBase.md#pollevent)` and `[waitEvent()](sf-WindowBase.md#waitevent)` functions.

Note that OpenGL experts can pass their own parameters (anti-aliasing level, bits for the depth and stencil buffers, etc.) to the OpenGL context attached to the window, with the `[sf::ContextSettings](sf-ContextSettings.md#contextsettings)` structure which is passed as an optional argument when creating the window.

On dual-graphics systems consisting of a low-power integrated GPU and a powerful discrete GPU, the driver picks which GPU will run an SFML application. In order to inform the driver that an SFML application can benefit from being run on the more powerful discrete GPU, `#SFML_DEFINE_DISCRETE_GPU_PREFERENCE` can be placed in a source file that is compiled and linked into the final application. The macro should be placed outside of any scopes in the global namespace.

Usage example: 
```cpp
// Declare and create a new window
sf::Window window(sf::VideoMode({800, 600}), "SFML window");

// Limit the framerate to 60 frames per second (this step is optional)
window.setFramerateLimit(60);

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

   // Activate the window for OpenGL rendering
   window.setActive();

   // OpenGL drawing commands go here...

   // End the current frame and display its contents on screen
   window.display();
}
```

## List of all members

| Name | Kind | Owner |
|------|------|-------|
| [`Window`](#window-1) | `function` | Declared here |
| [`Window`](#window-2) | `function` | Declared here |
| [`Window`](#window-3) | `function` | Declared here |
| [`Window`](#window-4) | `function` | Declared here |
| [`~Window`](#window-5) | `function` | Declared here |
| [`Window`](#window-6) | `function` | Declared here |
| [`operator=`](#operator-22) | `function` | Declared here |
| [`Window`](#window-7) | `function` | Declared here |
| [`operator=`](#operator-23) | `function` | Declared here |
| [`create`](#create) | `function` | Declared here |
| [`create`](#create-1) | `function` | Declared here |
| [`create`](#create-2) | `function` | Declared here |
| [`create`](#create-3) | `function` | Declared here |
| [`create`](#create-4) | `function` | Declared here |
| [`create`](#create-5) | `function` | Declared here |
| [`close`](#close-2) | `function` | Declared here |
| [`getSettings`](#getsettings-1) | `function` | Declared here |
| [`setVerticalSyncEnabled`](#setverticalsyncenabled) | `function` | Declared here |
| [`setFramerateLimit`](#setframeratelimit) | `function` | Declared here |
| [`setActive`](#setactive-1) | `function` | Declared here |
| [`display`](#display) | `function` | Declared here |
| [`m_context`](#m_context-1) | `variable` | Declared here |
| [`m_clock`](#m_clock) | `variable` | Declared here |
| [`m_frameTimeLimit`](#m_frametimelimit) | `variable` | Declared here |
| [`initialize`](#initialize-2) | `function` | Declared here |
| [`Window`](sf-WindowBase.md#window-8) | `friend` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`WindowBase`](sf-WindowBase.md#windowbase-3) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`WindowBase`](sf-WindowBase.md#windowbase-4) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`WindowBase`](sf-WindowBase.md#windowbase-5) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`WindowBase`](sf-WindowBase.md#windowbase-6) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`~WindowBase`](sf-WindowBase.md#windowbase-7) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`WindowBase`](sf-WindowBase.md#windowbase-8) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`operator=`](sf-WindowBase.md#operator-24) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`WindowBase`](sf-WindowBase.md#windowbase-9) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`operator=`](sf-WindowBase.md#operator-25) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`create`](sf-WindowBase.md#create-6) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`create`](sf-WindowBase.md#create-7) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`create`](sf-WindowBase.md#create-8) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`close`](sf-WindowBase.md#close-3) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`isOpen`](sf-WindowBase.md#isopen) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`pollEvent`](sf-WindowBase.md#pollevent) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`waitEvent`](sf-WindowBase.md#waitevent) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`handleEvents`](sf-WindowBase.md#handleevents) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`getPosition`](sf-WindowBase.md#getposition-2) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`setPosition`](sf-WindowBase.md#setposition-2) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`getSize`](sf-WindowBase.md#getsize-4) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`setSize`](sf-WindowBase.md#setsize) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`setMinimumSize`](sf-WindowBase.md#setminimumsize) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`setMaximumSize`](sf-WindowBase.md#setmaximumsize) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`setTitle`](sf-WindowBase.md#settitle) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`setIcon`](sf-WindowBase.md#seticon) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`setVisible`](sf-WindowBase.md#setvisible) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`setMouseCursorVisible`](sf-WindowBase.md#setmousecursorvisible) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`setMouseCursorGrabbed`](sf-WindowBase.md#setmousecursorgrabbed) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`setMouseCursor`](sf-WindowBase.md#setmousecursor) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`setKeyRepeatEnabled`](sf-WindowBase.md#setkeyrepeatenabled) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`setJoystickThreshold`](sf-WindowBase.md#setjoystickthreshold) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`requestFocus`](sf-WindowBase.md#requestfocus) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`hasFocus`](sf-WindowBase.md#hasfocus) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`getNativeHandle`](sf-WindowBase.md#getnativehandle) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`createVulkanSurface`](sf-WindowBase.md#createvulkansurface) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`onCreate`](sf-WindowBase.md#oncreate) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`onResize`](sf-WindowBase.md#onresize) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`m_impl`](sf-WindowBase.md#m_impl-5) | `variable` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`m_size`](sf-WindowBase.md#m_size-1) | `variable` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`filterEvent`](sf-WindowBase.md#filterevent) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`initialize`](sf-WindowBase.md#initialize-3) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`GlResource`](sf-GlResource.md#glresource-1) | `function` | Inherited from [`GlResource`](sf-GlResource.md#glresource) |
| [`m_sharedContext`](sf-GlResource.md#m_sharedcontext) | `variable` | Inherited from [`GlResource`](sf-GlResource.md#glresource) |

## Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2)

| Kind | Name | Description |
|------|------|-------------|
| `friend` | [`Window`](sf-WindowBase.md#window-8)  |  |
| `function` | [`WindowBase`](sf-WindowBase.md#windowbase-3)  | Default constructor. |
| `function` | [`WindowBase`](sf-WindowBase.md#windowbase-4)  | Construct a new window. |
| `function` | [`WindowBase`](sf-WindowBase.md#windowbase-5)  | Construct a new window. |
| `function` | [`WindowBase`](sf-WindowBase.md#windowbase-6) `explicit` | Construct the window from an existing control. |
| `function` | [`~WindowBase`](sf-WindowBase.md#windowbase-7) `virtual` | Destructor. |
| `function` | [`WindowBase`](sf-WindowBase.md#windowbase-8)  | Deleted copy constructor. |
| `function` | [`operator=`](sf-WindowBase.md#operator-24)  | Deleted copy assignment. |
| `function` | [`WindowBase`](sf-WindowBase.md#windowbase-9) `noexcept` | Move constructor. |
| `function` | [`operator=`](sf-WindowBase.md#operator-25) `noexcept` | Move assignment. |
| `function` | [`create`](sf-WindowBase.md#create-6) `virtual` | Create (or recreate) the window. |
| `function` | [`create`](sf-WindowBase.md#create-7) `virtual` | Create (or recreate) the window. |
| `function` | [`create`](sf-WindowBase.md#create-8) `virtual` | Create (or recreate) the window from an existing control. |
| `function` | [`close`](sf-WindowBase.md#close-3) `virtual` | Close the window and destroy all the attached resources. |
| `function` | [`isOpen`](sf-WindowBase.md#isopen) `const` `nodiscard` | Tell whether or not the window is open. |
| `function` | [`pollEvent`](sf-WindowBase.md#pollevent) `nodiscard` | Pop the next event from the front of the FIFO event queue, if any, and return it. |
| `function` | [`waitEvent`](sf-WindowBase.md#waitevent) `nodiscard` | Wait for an event and return it. |
| `function` | [`handleEvents`](sf-WindowBase.md#handleevents)  | Handle all pending events. |
| `function` | [`getPosition`](sf-WindowBase.md#getposition-2) `const` `nodiscard` | Get the position of the window. |
| `function` | [`setPosition`](sf-WindowBase.md#setposition-2)  | Change the position of the window on screen. |
| `function` | [`getSize`](sf-WindowBase.md#getsize-4) `const` `nodiscard` | Get the size of the rendering region of the window. |
| `function` | [`setSize`](sf-WindowBase.md#setsize)  | Change the size of the rendering region of the window. |
| `function` | [`setMinimumSize`](sf-WindowBase.md#setminimumsize)  | Set the minimum window rendering region size. |
| `function` | [`setMaximumSize`](sf-WindowBase.md#setmaximumsize)  | Set the maximum window rendering region size. |
| `function` | [`setTitle`](sf-WindowBase.md#settitle)  | Change the title of the window. |
| `function` | [`setIcon`](sf-WindowBase.md#seticon)  | Change the window's icon. |
| `function` | [`setVisible`](sf-WindowBase.md#setvisible)  | Show or hide the window. |
| `function` | [`setMouseCursorVisible`](sf-WindowBase.md#setmousecursorvisible)  | Show or hide the mouse cursor. |
| `function` | [`setMouseCursorGrabbed`](sf-WindowBase.md#setmousecursorgrabbed)  | Grab or release the mouse cursor. |
| `function` | [`setMouseCursor`](sf-WindowBase.md#setmousecursor)  | Set the displayed cursor to a native system cursor. |
| `function` | [`setKeyRepeatEnabled`](sf-WindowBase.md#setkeyrepeatenabled)  | Enable or disable automatic key-repeat. |
| `function` | [`setJoystickThreshold`](sf-WindowBase.md#setjoystickthreshold)  | Change the joystick threshold. |
| `function` | [`requestFocus`](sf-WindowBase.md#requestfocus)  | Request the current window to be made the active foreground window. |
| `function` | [`hasFocus`](sf-WindowBase.md#hasfocus) `const` `nodiscard` | Check whether the window has the input focus. |
| `function` | [`getNativeHandle`](sf-WindowBase.md#getnativehandle) `const` `nodiscard` | Get the OS-specific handle of the window. |
| `function` | [`createVulkanSurface`](sf-WindowBase.md#createvulkansurface) `nodiscard` | Create a [Vulkan](sf-Vulkan.md#vulkan) rendering surface. |
| `function` | [`onCreate`](sf-WindowBase.md#oncreate) `virtual` | Function called after the window has been created. |
| `function` | [`onResize`](sf-WindowBase.md#onresize) `virtual` | Function called after the window has been resized. |
| `variable` | [`m_impl`](sf-WindowBase.md#m_impl-5)  | Platform-specific implementation of the window. |
| `variable` | [`m_size`](sf-WindowBase.md#m_size-1)  | Current size of the window. |
| `function` | [`filterEvent`](sf-WindowBase.md#filterevent)  | Processes an event before it is sent to the user. |
| `function` | [`initialize`](sf-WindowBase.md#initialize-3)  | Perform some common internal initializations. |

## Inherited from [`GlResource`](sf-GlResource.md#glresource)

| Kind | Name | Description |
|------|------|-------------|
| `function` | [`GlResource`](sf-GlResource.md#glresource-1)  | Default constructor. |
| `variable` | [`m_sharedContext`](sf-GlResource.md#m_sharedcontext)  | Shared context used to link all contexts together for resource sharing. |

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`Window`](#window-1)  | Default constructor. |
|  | [`Window`](#window-2)  | Construct a new window. |
|  | [`Window`](#window-3)  | Construct a new window. |
|  | [`Window`](#window-4) `explicit` | Construct the window from an existing control. |
|  | [`~Window`](#window-5) `override` | Destructor. |
|  | [`Window`](#window-6)  | Deleted copy constructor. |
| [`Window`](#window) & | [`operator=`](#operator-22)  | Deleted copy assignment. |
|  | [`Window`](#window-7) `noexcept` | Move constructor. |
| [`Window`](#window) & | [`operator=`](#operator-23) `noexcept` | Move assignment. |
| `void` | [`create`](#create) `virtual` `override` | Create (or recreate) the window. |
| `void` | [`create`](#create-1) `virtual` | Create (or recreate) the window. |
| `void` | [`create`](#create-2) `virtual` `override` | Create (or recreate) the window. |
| `void` | [`create`](#create-3) `virtual` | Create (or recreate) the window. |
| `void` | [`create`](#create-4) `virtual` `override` | Create (or recreate) the window from an existing control. |
| `void` | [`create`](#create-5) `virtual` | Create (or recreate) the window from an existing control. |
| `void` | [`close`](#close-2) `virtual` `override` | Close the window and destroy all the attached resources. |
| const [`ContextSettings`](sf-ContextSettings.md#contextsettings) & | [`getSettings`](#getsettings-1) `const` `nodiscard` | Get the settings of the OpenGL context of the window. |
| `void` | [`setVerticalSyncEnabled`](#setverticalsyncenabled)  | Enable or disable vertical synchronization. |
| `void` | [`setFramerateLimit`](#setframeratelimit)  | Limit the framerate to a maximum fixed frequency. |
| `bool` | [`setActive`](#setactive-1) `const` `nodiscard` | Activate or deactivate the window as the current target for OpenGL rendering. |
| `void` | [`display`](#display)  | Display on screen what has been rendered to the window so far. |

---

{#window-1}

### Window

```cpp
Window()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Window.hpp:65

Default constructor.

This constructor doesn't actually create the window, use the other constructors or call `[create()](#create)` to do so.

---

{#window-2}

### Window

```cpp
Window(VideoMode mode, const String & title, std::uint32_t style = Style::Default, State state = State::Windowed, const ContextSettings & settings = {})
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Window.hpp:88

Construct a new window.

This constructor creates the window with the size and pixel depth defined in `mode`. An optional style can be passed to customize the look and behavior of the window (borders, title bar, resizable, closable, ...). An optional state can be provided. If `state` is `[State::Fullscreen](window.md#group__window_1gga504e2cd8fc6a852463f8d049db1151e5a0829ea6734059d66e6bf87096b215dc1)`, then `mode` must be a valid video mode.

The last parameter is an optional structure specifying advanced OpenGL context settings such as anti-aliasing, depth-buffer bits, etc.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mode` | [`VideoMode`](sf-VideoMode.md#videomode) | Video mode to use (defines the width, height and depth of the rendering area of the window) |
| `title` | const [`String`](sf-String.md#string) & | Title of the window |
| `style` | `std::uint32_t` | Window style, a bitwise OR combination of `[sf::Style](sf-Style.md#style-1)` enumerators |
| `state` | [`State`](State.md#state) | Window state |
| `settings` | const [`ContextSettings`](sf-ContextSettings.md#contextsettings) & | Additional settings for the underlying OpenGL context |

---

{#window-3}

### Window

```cpp
Window(VideoMode mode, const String & title, State state, const ContextSettings & settings = {})
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Window.hpp:111

Construct a new window.

This constructor creates the window with the size and pixel depth defined in `mode`. If `state` is `[State::Fullscreen](window.md#group__window_1gga504e2cd8fc6a852463f8d049db1151e5a0829ea6734059d66e6bf87096b215dc1)`, then `mode` must be a valid video mode.

The last parameter is an optional structure specifying advanced OpenGL context settings such as anti-aliasing, depth-buffer bits, etc.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mode` | [`VideoMode`](sf-VideoMode.md#videomode) | Video mode to use (defines the width, height and depth of the rendering area of the window) |
| `title` | const [`String`](sf-String.md#string) & | Title of the window |
| `state` | [`State`](State.md#state) | Window state |
| `settings` | const [`ContextSettings`](sf-ContextSettings.md#contextsettings) & | Additional settings for the underlying OpenGL context |

---

{#window-4}

### Window

`explicit`

```cpp
explicit Window(WindowHandle handle, const ContextSettings & settings = {})
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Window.hpp:127

Construct the window from an existing control.

Use this constructor if you want to create an OpenGL rendering area into an already existing control.

The second parameter is an optional structure specifying advanced OpenGL context settings such as anti-aliasing, depth-buffer bits, etc.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `handle` | `WindowHandle` | Platform-specific handle of the control |
| `settings` | const [`ContextSettings`](sf-ContextSettings.md#contextsettings) & | Additional settings for the underlying OpenGL context |

---

{#window-5}

### ~Window

`override`

```cpp
~Window() override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Window.hpp:135

Destructor.

Closes the window and frees all the resources attached to it.

---

{#window-6}

### Window

```cpp
Window(const Window &) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Window.hpp:141

Deleted copy constructor.

---

{#operator-22}

### operator=

```cpp
Window & operator=(const Window &) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Window.hpp:147

Deleted copy assignment.

---

{#window-7}

### Window

`noexcept`

```cpp
Window(Window &&) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Window.hpp:153

Move constructor.

---

{#operator-23}

### operator=

`noexcept`

```cpp
Window & operator=(Window &&) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Window.hpp:159

Move assignment.

---

{#create}

### create

`virtual` `override`

```cpp
virtual void create(VideoMode mode, const String & title, std::uint32_t style = Style::Default, State state = State::Windowed) override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Window.hpp:174

Create (or recreate) the window.

If the window was already created, it closes it first. If `state` is `[State::Fullscreen](window.md#group__window_1gga504e2cd8fc6a852463f8d049db1151e5a0829ea6734059d66e6bf87096b215dc1)`, then `mode` must be a valid video mode.

#### Reimplements

- [`create`](sf-WindowBase.md#create-6)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mode` | [`VideoMode`](sf-VideoMode.md#videomode) | Video mode to use (defines the width, height and depth of the rendering area of the window) |
| `title` | const [`String`](sf-String.md#string) & | Title of the window |
| `style` | `std::uint32_t` | Window style, a bitwise OR combination of `[sf::Style](sf-Style.md#style-1)` enumerators |
| `state` | [`State`](State.md#state) | Window state |

---

{#create-1}

### create

`virtual`

```cpp
virtual void create(VideoMode mode, const String & title, std::uint32_t style, State state, const ContextSettings & settings)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Window.hpp:193

Create (or recreate) the window.

If the window was already created, it closes it first. If `state` is `[State::Fullscreen](window.md#group__window_1gga504e2cd8fc6a852463f8d049db1151e5a0829ea6734059d66e6bf87096b215dc1)`, then `mode` must be a valid video mode.

The last parameter is a structure specifying advanced OpenGL context settings such as anti-aliasing, depth-buffer bits, etc.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mode` | [`VideoMode`](sf-VideoMode.md#videomode) | Video mode to use (defines the width, height and depth of the rendering area of the window) |
| `title` | const [`String`](sf-String.md#string) & | Title of the window |
| `style` | `std::uint32_t` | Window style, a bitwise OR combination of `[sf::Style](sf-Style.md#style-1)` enumerators |
| `state` | [`State`](State.md#state) | Window state |
| `settings` | const [`ContextSettings`](sf-ContextSettings.md#contextsettings) & | Additional settings for the underlying OpenGL context |

---

{#create-2}

### create

`virtual` `override`

```cpp
virtual void create(VideoMode mode, const String & title, State state) override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Window.hpp:207

Create (or recreate) the window.

If the window was already created, it closes it first. If `state` is `[State::Fullscreen](window.md#group__window_1gga504e2cd8fc6a852463f8d049db1151e5a0829ea6734059d66e6bf87096b215dc1)`, then `mode` must be a valid video mode.

#### Reimplements

- [`create`](sf-WindowBase.md#create-7)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mode` | [`VideoMode`](sf-VideoMode.md#videomode) | Video mode to use (defines the width, height and depth of the rendering area of the window) |
| `title` | const [`String`](sf-String.md#string) & | Title of the window |
| `state` | [`State`](State.md#state) | Window state |

---

{#create-3}

### create

`virtual`

```cpp
virtual void create(VideoMode mode, const String & title, State state, const ContextSettings & settings)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Window.hpp:225

Create (or recreate) the window.

If the window was already created, it closes it first. If `state` is `[State::Fullscreen](window.md#group__window_1gga504e2cd8fc6a852463f8d049db1151e5a0829ea6734059d66e6bf87096b215dc1)`, then `mode` must be a valid video mode.

The last parameter is a structure specifying advanced OpenGL context settings such as anti-aliasing, depth-buffer bits, etc.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mode` | [`VideoMode`](sf-VideoMode.md#videomode) | Video mode to use (defines the width, height and depth of the rendering area of the window) |
| `title` | const [`String`](sf-String.md#string) & | Title of the window |
| `state` | [`State`](State.md#state) | Window state |
| `settings` | const [`ContextSettings`](sf-ContextSettings.md#contextsettings) & | Additional settings for the underlying OpenGL context |

---

{#create-4}

### create

`virtual` `override`

```cpp
virtual void create(WindowHandle handle) override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Window.hpp:237

Create (or recreate) the window from an existing control.

Use this function if you want to create an OpenGL rendering area into an already existing control. If the window was already created, it closes it first.

#### Reimplements

- [`create`](sf-WindowBase.md#create-8)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `handle` | `WindowHandle` | Platform-specific handle of the control |

---

{#create-5}

### create

`virtual`

```cpp
virtual void create(WindowHandle handle, const ContextSettings & settings)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Window.hpp:254

Create (or recreate) the window from an existing control.

Use this function if you want to create an OpenGL rendering area into an already existing control. If the window was already created, it closes it first.

The second parameter is an optional structure specifying advanced OpenGL context settings such as anti-aliasing, depth-buffer bits, etc.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `handle` | `WindowHandle` | Platform-specific handle of the control |
| `settings` | const [`ContextSettings`](sf-ContextSettings.md#contextsettings) & | Additional settings for the underlying OpenGL context |

---

{#close-2}

### close

`virtual` `override`

```cpp
virtual void close() override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Window.hpp:266

Close the window and destroy all the attached resources.

After calling this function, the `[sf::Window](#window)` instance remains valid and you can call `[create()](#create)` to recreate the window. All other functions such as `[pollEvent()](sf-WindowBase.md#pollevent)` or `[display()](#display)` will still work (i.e. you don't have to test `[isOpen()](sf-WindowBase.md#isopen)` every time), and will have no effect on closed windows.

#### Reimplements

- [`close`](sf-WindowBase.md#close-3)

---

{#getsettings-1}

### getSettings

`const` `nodiscard`

```cpp
[[nodiscard]] const ContextSettings & getSettings() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Window.hpp:279

Get the settings of the OpenGL context of the window.

Note that these settings may be different from what was passed to the constructor or the `[create()](#create)` function, if one or more settings were not supported. In this case, SFML chose the closest match.

#### Returns
Structure containing the OpenGL context settings

---

{#setverticalsyncenabled}

### setVerticalSyncEnabled

```cpp
void setVerticalSyncEnabled(bool enabled)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Window.hpp:294

Enable or disable vertical synchronization.

Activating vertical synchronization will limit the number of frames displayed to the refresh rate of the monitor. This can avoid some visual artifacts, and limit the framerate to a good value (but not constant across different computers).

Vertical synchronization is disabled by default.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `enabled` | `bool` | `true` to enable v-sync, `false` to deactivate it |

---

{#setframeratelimit}

### setFramerateLimit

```cpp
void setFramerateLimit(unsigned int limit)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Window.hpp:311

Limit the framerate to a maximum fixed frequency.

If a limit is set, the window will use a small delay after each call to `[display()](#display)` to ensure that the current frame lasted long enough to match the framerate limit. SFML will try to match the given limit as much as it can, but since it internally uses `[sf::sleep](system.md#sleep)`, whose precision depends on the underlying OS, the results may be a little imprecise as well (for example, you can get 65 FPS when requesting 60).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `limit` | `unsigned int` | Framerate limit, in frames per seconds (use 0 to disable limit) |

---

{#setactive-1}

### setActive

`const` `nodiscard`

```cpp
[[nodiscard]] bool setActive(bool active = true) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Window.hpp:329

Activate or deactivate the window as the current target for OpenGL rendering.

A window is active only on the current thread, if you want to make it active on another thread you have to deactivate it on the previous thread first if it was active. Only one window can be active on a thread at a time, thus the window previously active (if any) automatically gets deactivated. This is not to be confused with `[requestFocus()](sf-WindowBase.md#requestfocus)`.

#### Returns
`true` if operation was successful, `false` otherwise

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `active` | `bool` | `true` to activate, `false` to deactivate |

---

{#display}

### display

```cpp
void display()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Window.hpp:339

Display on screen what has been rendered to the window so far.

This function is typically called after all OpenGL rendering has been done for the current frame, in order to show it on screen.

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::unique_ptr< priv::GlContext >` | [`m_context`](#m_context-1)  | Platform-specific implementation of the OpenGL context. |
| [`Clock`](sf-Clock.md#clock) | [`m_clock`](#m_clock)  | [Clock](sf-Clock.md#clock) for measuring the elapsed time between frames. |
| [`Time`](sf-Time.md#time) | [`m_frameTimeLimit`](#m_frametimelimit)  | Current framerate limit. |

---

{#m_context-1}

### m_context

```cpp
std::unique_ptr< priv::GlContext > m_context
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Window.hpp:351

Platform-specific implementation of the OpenGL context.

---

{#m_clock}

### m_clock

```cpp
Clock m_clock
```

Type: [`Clock`](sf-Clock.md#clock)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Window.hpp:352

[Clock](sf-Clock.md#clock) for measuring the elapsed time between frames.

---

{#m_frametimelimit}

### m_frameTimeLimit

```cpp
Time m_frameTimeLimit
```

Type: [`Time`](sf-Time.md#time)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Window.hpp:353

Current framerate limit.

## Private Methods

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`initialize`](#initialize-2)  | Perform some common internal initializations. |

---

{#initialize-2}

### initialize

```cpp
void initialize()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Window.hpp:346

Perform some common internal initializations.

