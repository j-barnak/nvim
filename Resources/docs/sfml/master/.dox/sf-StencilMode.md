{#stencilmode-1}

# StencilMode

```cpp
#include <StencilMode.hpp>
```

```cpp
class StencilMode
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/StencilMode.hpp:106

Stencil modes for drawing.

`[sf::StencilMode](#stencilmode-1)` is a class that controls stencil testing.

In addition to drawing to the visible portion of a render target, there is the possibility to "draw" to a so-called stencil buffer. The stencil buffer is a special non-visible buffer that can contain a single value per pixel that is drawn. This can be thought of as a fifth value in addition to red, green, blue and alpha values. The maximum value that can be represented depends on what is supported by the system. Typically support for a 8-bit stencil buffer should always be available. This will also have to be requested when creating a render target via the `[sf::ContextSettings](sf-ContextSettings.md#contextsettings)` that is passed during creation. Stencil testing will not work if there is no stencil buffer available in the target that is being drawn to.

Initially, just like with the visible color buffer, the stencil value of each pixel is set to an undefined value. Calling `[sf::RenderTarget::clear](sf-RenderTarget.md#clear-3)` will set each pixel's stencil value to 0. `[sf::RenderTarget::clear](sf-RenderTarget.md#clear-3)` can be called at any time to reset the stencil values back to 0.

When drawing an object, before each pixel of the color buffer is updated with its new color value, the stencil test is performed. During this test 2 values are compared with each other: the reference value that is passed via `[sf::StencilMode](#stencilmode-1)` and the value that is currently in the stencil buffer. The arithmetic comparison that is performed on the 2 values can also be controlled via `[sf::StencilMode](#stencilmode-1)`. Depending on whether the test passes i.e. the comparison yields `true`, the color buffer is updated with its new RGBA value and if set in `[sf::StencilMode](#stencilmode-1)` the stencil buffer is updated accordingly. The new stencil value will be used during stencil testing the next time the pixel is drawn to.

The class is composed of 5 components, each of which has its own public member variable: 

* Stencil Comparison ([stencilComparison](#stencilcomparison)) 
* Stencil Update Operation ([stencilUpdateOperation](#stencilupdateoperation)) 
* Stencil Reference Value ([stencilReference](#stencilreference)) 
* Stencil Mask Value ([stencilMask](#stencilmask)) 
* Stencil Only Update ([stencilOnly](#stencilonly))

The stencil comparison specifies the comparison that is performed between the reference value of the currently active `[sf::StencilMode](#stencilmode-1)` and the value that is currently in the stencil buffer. This comparison determines whether the stencil test passes or fails.

The stencil update operation specifies how the stencil buffer is updated if the stencil test passes. If the stencil test fails, neither the color or stencil buffers will be modified. If incrementing or decrementing the stencil value, the new value will be clamped to the range from 0 to the maximum representable value given the bit width of the stencil buffer e.g. 255 if an 8-bit stencil buffer is being used.

The reference value is used both during the comparison with the current stencil buffer value and as the new value to be written when the operation is set to Replace.

The mask value is used to mask the bits of both the reference value and the value in the stencil buffer during the comparison and when updating. The mask can be used to e.g. segment the stencil value bits into separate regions that are used for different purposes.

In certain situations, it might make sense to only write to the stencil buffer and not the color buffer during a draw. The written stencil buffer value can then be used in subsequent draws as a masking region.

In SFML, a stencil mode can be specified every time you draw a `[sf::Drawable](sf-Drawable.md#drawable)` object to a render target. It is part of the `[sf::RenderStates](sf-RenderStates.md#renderstates)` compound that is passed to the member function `[sf::RenderTarget::draw()](sf-RenderTarget.md#draw-1)`.

Usage example: 
```cpp
// Make sure we create a RenderTarget with a stencil buffer by specifying it via the context settings
sf::RenderWindow window(sf::VideoMode({250, 200}), "Stencil Window", sf::Style::Default, sf::ContextSettings{0, 8});

...

// Left circle
sf::CircleShape left(100.f);
left.setFillColor(sf::Color::Green);
left.setPosition({0, 0});

// Middle circle
sf::CircleShape middle(100.f);
middle.setFillColor(sf::Color::Yellow);
middle.setPosition({25, 0});

// Right circle
sf::CircleShape right(100.f);
right.setFillColor(sf::Color::Red);
right.setPosition({50, 0});

...

// Clear the stencil buffer to 0 at the start of every frame
window.clear(sf::Color::Black, 0);

...

// Draw the middle circle in a stencil-only pass and write the value 1
// to the stencil buffer for every pixel the circle would have affected
window.draw(middle, sf::StencilMode{sf::StencilComparison::Always, sf::StencilUpdateOperation::Replace, 1, 0xFF, true});

// Draw the left and right circles
// Only allow rendering to pixels whose stencil value is not
// equal to 1 i.e. weren't written when drawing the middle circle
window.draw(left, sf::StencilMode{sf::StencilComparison::NotEqual, sf::StencilUpdateOperation::Keep, 1, 0xFF, false});
window.draw(right, sf::StencilMode{sf::StencilComparison::NotEqual, sf::StencilUpdateOperation::Keep, 1, 0xFF, false});
```

**See also**: `[sf::RenderStates](sf-RenderStates.md#renderstates)`, `[sf::RenderTarget](sf-RenderTarget.md#rendertarget-1)`

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`StencilComparison`](StencilComparison.md#stencilcomparison-1) | [`stencilComparison`](#stencilcomparison)  | The comparison we're performing the stencil test with. |
| [`StencilUpdateOperation`](StencilUpdateOperation.md#stencilupdateoperation-1) | [`stencilUpdateOperation`](#stencilupdateoperation)  | The update operation to perform if the stencil test passes. |
| [`StencilValue`](sf-StencilValue.md#stencilvalue) | [`stencilReference`](#stencilreference)  | The reference value we're performing the stencil test with. |
| [`StencilValue`](sf-StencilValue.md#stencilvalue) | [`stencilMask`](#stencilmask)  | The mask to apply to both the reference value and the value in the stencil buffer. |
| `bool` | [`stencilOnly`](#stencilonly)  | Whether we should update the color buffer in addition to the stencil buffer. |

---

{#stencilcomparison}

### stencilComparison

```cpp
StencilComparison stencilComparison {StencilComparison::Always}
```

Type: [`StencilComparison`](StencilComparison.md#stencilcomparison-1)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/StencilMode.hpp:108

The comparison we're performing the stencil test with.

---

{#stencilupdateoperation}

### stencilUpdateOperation

```cpp
StencilUpdateOperation stencilUpdateOperation {
        StencilUpdateOperation::Keep}
```

Type: [`StencilUpdateOperation`](StencilUpdateOperation.md#stencilupdateoperation-1)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/StencilMode.hpp:109

The update operation to perform if the stencil test passes.

---

{#stencilreference}

### stencilReference

```cpp
StencilValue stencilReference {0}
```

Type: [`StencilValue`](sf-StencilValue.md#stencilvalue)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/StencilMode.hpp:111

The reference value we're performing the stencil test with.

---

{#stencilmask}

### stencilMask

```cpp
StencilValue stencilMask {~0u}
```

Type: [`StencilValue`](sf-StencilValue.md#stencilvalue)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/StencilMode.hpp:112

The mask to apply to both the reference value and the value in the stencil buffer.

---

{#stencilonly}

### stencilOnly

```cpp
bool stencilOnly {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/StencilMode.hpp:113

Whether we should update the color buffer in addition to the stencil buffer.

