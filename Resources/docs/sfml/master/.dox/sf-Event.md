{#event}

# Event

```cpp
#include <Event.hpp>
```

```cpp
class Event
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:47

Defines a system event and its parameters.

`[sf::Event](#event)` holds all the information about a system event that just happened. Events are retrieved using the `[sf::Window::pollEvent](sf-WindowBase.md#pollevent)` and `[sf::Window::waitEvent](sf-WindowBase.md#waitevent)` functions.

A `[sf::Event](#event)` instance contains the subtype of the event (mouse moved, key pressed, window closed, ...) as well as the details about this particular event. Each event corresponds to a different subtype struct which contains the data required to process that event.

[Event](#event) subtypes are event types belonging to `[sf::Event](#event)`, such as `[sf::Event::Closed](sf-Event-Closed.md#closed)` or `[sf::Event::MouseMoved](sf-Event-MouseMoved.md#mousemoved)`.

The way to access the current active event subtype is via `[sf::Event::getIf](#getif)`. This member function returns the address of the event subtype struct if the event subtype matches the active event, otherwise it returns `nullptr`.

`[sf::Event::is](#is)` is used to check the active event subtype without actually reading any of the corresponding event data.

```cpp
while (const std::optional event = window.pollEvent())
{
    // Window closed or escape key pressed: exit
    if (event->is<sf::Event::Closed>() ||
        (event->is<sf::Event::KeyPressed>() &&
         event->getIf<sf::Event::KeyPressed>()->code == sf::Keyboard::Key::Escape))
        window.close();

    // The window was resized
    if (const auto* resized = event->getIf<sf::Event::Resized>())
        doSomethingWithTheNewSize(resized->size);

    // etc ...
}
```

## Friends

| Name | Description |
|------|-------------|
| [`WindowBase`](#windowbase-1)  |  |

---

{#windowbase-1}

### WindowBase

```cpp
friend class WindowBase
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:415

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`Event`](#event-1)  | Construct from a given `[sf::Event](#event)` subtype. |
| `bool` | [`is`](#is) `const` `nodiscard` | Check current event subtype. |
| `TEventSubtype *` | [`getIf`](#getif) `nodiscard` | Attempt to get specified event subtype. |
| `const TEventSubtype *` | [`getIf`](#getif-1) `const` `nodiscard` | Attempt to get specified event subtype. |
| `decltype(auto)` | [`visit`](#visit)  | Apply a visitor to the event. |
| `decltype(auto)` | [`visit`](#visit-1) `const` | Apply a visitor to the event. |

---

{#event-1}

### Event

```cpp
template<typename TEventSubtype> Event(const TEventSubtype & eventSubtype)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:317

Construct from a given `[sf::Event](#event)` subtype.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `eventSubtype` | `const TEventSubtype &` | [Event](#event) subtype instance used to construct the event |

---

{#is}

### is

`const` `nodiscard`

```cpp
template<typename TEventSubtype> [[nodiscard]] bool is() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:328

Check current event subtype.

#### Returns
`true` if the current event subtype matches given template parameter

---

{#getif}

### getIf

`nodiscard`

```cpp
template<typename TEventSubtype> [[nodiscard]] TEventSubtype * getIf()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:339

Attempt to get specified event subtype.

#### Returns
Address of current event subtype, otherwise `nullptr`

---

{#getif-1}

### getIf

`const` `nodiscard`

```cpp
template<typename TEventSubtype> [[nodiscard]] const TEventSubtype * getIf() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:350

Attempt to get specified event subtype.

#### Returns
Address of current event subtype, otherwise `nullptr`

---

{#visit}

### visit

```cpp
template<typename Visitor> decltype(auto) visit(Visitor && visitor)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:361

Apply a visitor to the event.

#### Returns
The result of applying the visitor to the event

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `visitor` | `Visitor &&` | The visitor to apply |

---

{#visit-1}

### visit

`const`

```cpp
template<typename Visitor> decltype(auto) visit(Visitor && visitor) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:372

Apply a visitor to the event.

#### Returns
The result of applying the visitor to the event

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `visitor` | `Visitor &&` | The visitor to apply |

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| std::variant< [`Closed`](sf-Event-Closed.md#closed), [`Resized`](sf-Event-Resized.md#resized), [`FocusLost`](sf-Event-FocusLost.md#focuslost), [`FocusGained`](sf-Event-FocusGained.md#focusgained), [`TextEntered`](sf-Event-TextEntered.md#textentered), [`KeyPressed`](sf-Event-KeyPressed.md#keypressed), [`KeyReleased`](sf-Event-KeyReleased.md#keyreleased), [`MouseWheelScrolled`](sf-Event-MouseWheelScrolled.md#mousewheelscrolled), [`MouseButtonPressed`](sf-Event-MouseButtonPressed.md#mousebuttonpressed), [`MouseButtonReleased`](sf-Event-MouseButtonReleased.md#mousebuttonreleased), [`MouseMoved`](sf-Event-MouseMoved.md#mousemoved), [`MouseMovedRaw`](sf-Event-MouseMovedRaw.md#mousemovedraw), [`MouseEntered`](sf-Event-MouseEntered.md#mouseentered), [`MouseLeft`](sf-Event-MouseLeft.md#mouseleft), [`JoystickButtonPressed`](sf-Event-JoystickButtonPressed.md#joystickbuttonpressed), [`JoystickButtonReleased`](sf-Event-JoystickButtonReleased.md#joystickbuttonreleased), [`JoystickMoved`](sf-Event-JoystickMoved.md#joystickmoved), [`JoystickConnected`](sf-Event-JoystickConnected.md#joystickconnected), [`JoystickDisconnected`](sf-Event-JoystickDisconnected.md#joystickdisconnected), [`TouchBegan`](sf-Event-TouchBegan.md#touchbegan), [`TouchMoved`](sf-Event-TouchMoved.md#touchmoved), [`TouchEnded`](sf-Event-TouchEnded.md#touchended), [`SensorChanged`](sf-Event-SensorChanged.md#sensorchanged) > | [`m_data`](#m_data-1)  | [Event](#event) data. |

---

{#m_data-1}

### m_data

```cpp
std::variant< Closed, Resized, FocusLost, FocusGained, TextEntered, KeyPressed, KeyReleased, MouseWheelScrolled, MouseButtonPressed, MouseButtonReleased, MouseMoved, MouseMovedRaw, MouseEntered, MouseLeft, JoystickButtonPressed, JoystickButtonReleased, JoystickMoved, JoystickConnected, JoystickDisconnected, TouchBegan, TouchMoved, TouchEnded, SensorChanged > m_data
```

Type: std::variant< [`Closed`](sf-Event-Closed.md#closed), [`Resized`](sf-Event-Resized.md#resized), [`FocusLost`](sf-Event-FocusLost.md#focuslost), [`FocusGained`](sf-Event-FocusGained.md#focusgained), [`TextEntered`](sf-Event-TextEntered.md#textentered), [`KeyPressed`](sf-Event-KeyPressed.md#keypressed), [`KeyReleased`](sf-Event-KeyReleased.md#keyreleased), [`MouseWheelScrolled`](sf-Event-MouseWheelScrolled.md#mousewheelscrolled), [`MouseButtonPressed`](sf-Event-MouseButtonPressed.md#mousebuttonpressed), [`MouseButtonReleased`](sf-Event-MouseButtonReleased.md#mousebuttonreleased), [`MouseMoved`](sf-Event-MouseMoved.md#mousemoved), [`MouseMovedRaw`](sf-Event-MouseMovedRaw.md#mousemovedraw), [`MouseEntered`](sf-Event-MouseEntered.md#mouseentered), [`MouseLeft`](sf-Event-MouseLeft.md#mouseleft), [`JoystickButtonPressed`](sf-Event-JoystickButtonPressed.md#joystickbuttonpressed), [`JoystickButtonReleased`](sf-Event-JoystickButtonReleased.md#joystickbuttonreleased), [`JoystickMoved`](sf-Event-JoystickMoved.md#joystickmoved), [`JoystickConnected`](sf-Event-JoystickConnected.md#joystickconnected), [`JoystickDisconnected`](sf-Event-JoystickDisconnected.md#joystickdisconnected), [`TouchBegan`](sf-Event-TouchBegan.md#touchbegan), [`TouchMoved`](sf-Event-TouchMoved.md#touchmoved), [`TouchEnded`](sf-Event-TouchEnded.md#touchended), [`SensorChanged`](sf-Event-SensorChanged.md#sensorchanged) >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:401

[Event](#event) data.

## Private Static Attributes

| Return | Name | Description |
|--------|------|-------------|
| `bool` | [`isEventSubtype`](#iseventsubtype) `static` `constexpr` |  |
| `bool` | [`isEventHandler`](#iseventhandler) `static` `constexpr` |  |

---

{#iseventsubtype}

### isEventSubtype

`static` `constexpr`

```cpp
bool isEventSubtype = isInParameterPack<T>(decltype (&m_data)(nullptr))
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:413

---

{#iseventhandler}

### isEventHandler

`static` `constexpr`

```cpp
bool isEventHandler = isInvocableWithEventSubtype<Handler>(decltype (&m_data)(nullptr))
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:424

## Private Static Methods

| Return | Name | Description |
|--------|------|-------------|
| `bool` | [`isInParameterPack`](#isinparameterpack) `static` `inline` `nodiscard` `constexpr` |  |
| `bool` | [`isInvocableWithEventSubtype`](#isinvocablewitheventsubtype) `static` `inline` `nodiscard` `constexpr` |  |

---

{#isinparameterpack}

### isInParameterPack

`static` `inline` `nodiscard` `constexpr`

```cpp
template<typename T, typename... Ts> [[nodiscard]] constexpr static inline bool isInParameterPack(const std::variant< Ts... > *)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:407

---

{#isinvocablewitheventsubtype}

### isInvocableWithEventSubtype

`static` `inline` `nodiscard` `constexpr`

```cpp
template<typename Handler, typename... Ts> [[nodiscard]] constexpr static inline bool isInvocableWithEventSubtype(const std::variant< Ts... > *)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:418

