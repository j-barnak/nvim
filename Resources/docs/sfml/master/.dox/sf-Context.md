{#context}

# Context

```cpp
#include <Context.hpp>
```

```cpp
class Context
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Context.hpp:57

> **Inherits:** [`GlResource`](sf-GlResource.md#glresource)

Class holding a valid drawing context.

If you need to make OpenGL calls without having an active window (like in a thread), you can use an instance of this class to get a valid context.

Having a valid context is necessary for *every* OpenGL call.

Note that a context is only active in its current thread, if you create a new thread it will have no valid context by default.

To use a `[sf::Context](#context)` instance, just construct it and let it live as long as you need a valid context. No explicit activation is needed, all it has to do is to exist. Its destructor will take care of deactivating and freeing all the attached resources.

Usage example: 
```cpp
void threadFunction(void*)
{
   sf::Context context;
   // from now on, you have a valid context

   // you can make OpenGL calls
   glClear(GL_DEPTH_BUFFER_BIT);
}
// the context is automatically deactivated and destroyed
// by the sf::Context destructor
```

## List of all members

| Name | Kind | Owner |
|------|------|-------|
| [`Context`](#context-1) | `function` | Declared here |
| [`~Context`](#context-2) | `function` | Declared here |
| [`Context`](#context-3) | `function` | Declared here |
| [`operator=`](#operator-17) | `function` | Declared here |
| [`Context`](#context-4) | `function` | Declared here |
| [`operator=`](#operator-18) | `function` | Declared here |
| [`setActive`](#setactive) | `function` | Declared here |
| [`getSettings`](#getsettings) | `function` | Declared here |
| [`Context`](#context-5) | `function` | Declared here |
| [`isExtensionAvailable`](#isextensionavailable) | `function` | Declared here |
| [`getFunction`](#getfunction) | `function` | Declared here |
| [`getActiveContext`](#getactivecontext) | `function` | Declared here |
| [`getActiveContextId`](#getactivecontextid) | `function` | Declared here |
| [`m_context`](#m_context) | `variable` | Declared here |
| [`GlResource`](sf-GlResource.md#glresource-1) | `function` | Inherited from [`GlResource`](sf-GlResource.md#glresource) |
| [`m_sharedContext`](sf-GlResource.md#m_sharedcontext) | `variable` | Inherited from [`GlResource`](sf-GlResource.md#glresource) |

## Inherited from [`GlResource`](sf-GlResource.md#glresource)

| Kind | Name | Description |
|------|------|-------------|
| `function` | [`GlResource`](sf-GlResource.md#glresource-1)  | Default constructor. |
| `variable` | [`m_sharedContext`](sf-GlResource.md#m_sharedcontext)  | Shared context used to link all contexts together for resource sharing. |

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`Context`](#context-1)  | Default constructor. |
|  | [`~Context`](#context-2)  | Destructor. |
|  | [`Context`](#context-3)  | Deleted copy constructor. |
| [`Context`](#context) & | [`operator=`](#operator-17)  | Deleted copy assignment. |
|  | [`Context`](#context-4) `noexcept` | Move constructor. |
| [`Context`](#context) & | [`operator=`](#operator-18) `noexcept` | Move assignment. |
| `bool` | [`setActive`](#setactive) `nodiscard` | Activate or deactivate explicitly the context. |
| const [`ContextSettings`](sf-ContextSettings.md#contextsettings) & | [`getSettings`](#getsettings) `const` `nodiscard` | Get the settings of the context. |
|  | [`Context`](#context-5)  | Construct a in-memory context. |

---

{#context-1}

### Context

```cpp
Context()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Context.hpp:66

Default constructor.

The constructor creates and activates the context

---

{#context-2}

### ~Context

```cpp
~Context()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Context.hpp:74

Destructor.

The destructor deactivates and destroys the context

---

{#context-3}

### Context

```cpp
Context(const Context &) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Context.hpp:80

Deleted copy constructor.

---

{#operator-17}

### operator=

```cpp
Context & operator=(const Context &) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Context.hpp:86

Deleted copy assignment.

---

{#context-4}

### Context

`noexcept`

```cpp
Context(Context && context) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Context.hpp:92

Move constructor.

---

{#operator-18}

### operator=

`noexcept`

```cpp
Context & operator=(Context && context) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Context.hpp:98

Move assignment.

---

{#setactive}

### setActive

`nodiscard`

```cpp
[[nodiscard]] bool setActive(bool active)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Context.hpp:108

Activate or deactivate explicitly the context.

#### Returns
`true` on success, `false` on failure

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `active` | `bool` | `true` to activate, `false` to deactivate |

---

{#getsettings}

### getSettings

`const` `nodiscard`

```cpp
[[nodiscard]] const ContextSettings & getSettings() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Context.hpp:120

Get the settings of the context.

Note that these settings may be different than the ones passed to the constructor; they are indeed adjusted if the original settings are not directly supported by the system.

#### Returns
Structure containing the settings

---

{#context-5}

### Context

```cpp
Context(const ContextSettings & settings, Vector2u size)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Context.hpp:178

Construct a in-memory context.

This constructor is for internal use, you don't need to bother with it.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `settings` | const [`ContextSettings`](sf-ContextSettings.md#contextsettings) & | Creation parameters |
| `size` | [`Vector2u`](sf.md#vector2u) | Back buffer size |

## Public Static Methods

| Return | Name | Description |
|--------|------|-------------|
| `bool` | [`isExtensionAvailable`](#isextensionavailable) `static` `nodiscard` | Check whether a given OpenGL extension is available. |
| [`GlFunctionPointer`](sf.md#glfunctionpointer) | [`getFunction`](#getfunction) `static` `nodiscard` | Get the address of an OpenGL function. |
| const [`Context`](#context) * | [`getActiveContext`](#getactivecontext) `static` `nodiscard` | Get the currently active context. |
| `std::uint64_t` | [`getActiveContextId`](#getactivecontextid) `static` `nodiscard` | Get the currently active context's ID. |

---

{#isextensionavailable}

### isExtensionAvailable

`static` `nodiscard`

```cpp
[[nodiscard]] static bool isExtensionAvailable(std::string_view name)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Context.hpp:130

Check whether a given OpenGL extension is available.

#### Returns
`true` if available, `false` if unavailable

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `std::string_view` | Name of the extension to check for |

---

{#getfunction}

### getFunction

`static` `nodiscard`

```cpp
[[nodiscard]] static GlFunctionPointer getFunction(const char * name)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Context.hpp:143

Get the address of an OpenGL function.

On Windows when not using OpenGL ES, a context must be active for this function to succeed.

#### Returns
Address of the OpenGL function, `nullptr` on failure

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const char *` | Name of the function to get the address of |

---

{#getactivecontext}

### getActiveContext

`static` `nodiscard`

```cpp
[[nodiscard]] static const Context * getActiveContext()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Context.hpp:155

Get the currently active context.

This function will only return `[sf::Context](#context)` objects. Contexts created e.g. by RenderTargets or for internal use will not be returned by this function.

#### Returns
The currently active context or `nullptr` if none is active

---

{#getactivecontextid}

### getActiveContextId

`static` `nodiscard`

```cpp
[[nodiscard]] static std::uint64_t getActiveContextId()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Context.hpp:166

Get the currently active context's ID.

The context ID is used to identify contexts when managing unshareable OpenGL resources.

#### Returns
The active context's ID or 0 if no context is currently active

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::unique_ptr< priv::GlContext >` | [`m_context`](#m_context)  | Internal OpenGL context. |

---

{#m_context}

### m_context

```cpp
std::unique_ptr< priv::GlContext > m_context
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Context.hpp:184

Internal OpenGL context.

