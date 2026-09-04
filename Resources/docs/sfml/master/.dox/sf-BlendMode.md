{#blendmode}

# BlendMode

```cpp
#include <BlendMode.hpp>
```

```cpp
class BlendMode
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/BlendMode.hpp:40

Blending modes for drawing.

`[sf::BlendMode](#blendmode)` is a class that represents a blend mode. A blend mode determines how the colors of an object you draw are mixed with the colors that are already in the buffer.

The class is composed of 6 components, each of which has its own public member variable: 

* Color Source [Factor](Factor.md#factor) ([colorSrcFactor](#colorsrcfactor)) 
* Color Destination [Factor](Factor.md#factor) ([colorDstFactor](#colordstfactor)) 
* Color Blend [Equation](Equation.md#equation) ([colorEquation](#colorequation)) 
* Alpha Source [Factor](Factor.md#factor) ([alphaSrcFactor](#alphasrcfactor)) 
* Alpha Destination [Factor](Factor.md#factor) ([alphaDstFactor](#alphadstfactor)) 
* Alpha Blend [Equation](Equation.md#equation) ([alphaEquation](#alphaequation))

The source factor specifies how the pixel you are drawing contributes to the final color. The destination factor specifies how the pixel already drawn in the buffer contributes to the final color.

The color channels RGB (red, green, blue; simply referred to as color) and A (alpha; the transparency) can be treated separately. This separation can be useful for specific blend modes, but most often you won't need it and will simply treat the color as a single unit.

The blend factors and equations correspond to their OpenGL equivalents. In general, the color of the resulting pixel is calculated according to the following formula (`src` is the color of the source pixel, `dst` the color of the destination pixel, the other variables correspond to the public members, with the equations being + or - operators): 
```cpp
dst.rgb = colorSrcFactor * src.rgb (colorEquation) colorDstFactor * dst.rgb
dst.a   = alphaSrcFactor * src.a   (alphaEquation) alphaDstFactor * dst.a
```
 All factors and colors are represented as floating point numbers between 0 and 1. Where necessary, the result is clamped to fit in that range.

The most common blending modes are defined as constants in the sf namespace:

```cpp
sf::BlendMode alphaBlending          = sf::BlendAlpha;
sf::BlendMode additiveBlending       = sf::BlendAdd;
sf::BlendMode multiplicativeBlending = sf::BlendMultiply;
sf::BlendMode noBlending             = sf::BlendNone;
```

In SFML, a blend mode can be specified every time you draw a `[sf::Drawable](sf-Drawable.md#drawable)` object to a render target. It is part of the `[sf::RenderStates](sf-RenderStates.md#renderstates)` compound that is passed to the member function `[sf::RenderTarget::draw()](sf-RenderTarget.md#draw-1)`.

**See also**: `[sf::RenderStates](sf-RenderStates.md#renderstates)`, `[sf::RenderTarget](sf-RenderTarget.md#rendertarget-1)`

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`Factor`](Factor.md#factor) | [`colorSrcFactor`](#colorsrcfactor)  | Source blending factor for the color channels. |
| [`Factor`](Factor.md#factor) | [`colorDstFactor`](#colordstfactor)  | Destination blending factor for the color channels. |
| [`Equation`](Equation.md#equation) | [`colorEquation`](#colorequation)  | Blending equation for the color channels. |
| [`Factor`](Factor.md#factor) | [`alphaSrcFactor`](#alphasrcfactor)  | Source blending factor for the alpha channel. |
| [`Factor`](Factor.md#factor) | [`alphaDstFactor`](#alphadstfactor)  | Destination blending factor for the alpha channel. |
| [`Equation`](Equation.md#equation) | [`alphaEquation`](#alphaequation)  | Blending equation for the alpha channel. |

---

{#colorsrcfactor}

### colorSrcFactor

```cpp
Factor colorSrcFactor {BlendMode::Factor::SrcAlpha}
```

Type: [`Factor`](Factor.md#factor)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/BlendMode.hpp:119

Source blending factor for the color channels.

---

{#colordstfactor}

### colorDstFactor

```cpp
Factor colorDstFactor {BlendMode::Factor::OneMinusSrcAlpha}
```

Type: [`Factor`](Factor.md#factor)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/BlendMode.hpp:120

Destination blending factor for the color channels.

---

{#colorequation}

### colorEquation

```cpp
Equation colorEquation {BlendMode::Equation::Add}
```

Type: [`Equation`](Equation.md#equation)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/BlendMode.hpp:121

Blending equation for the color channels.

---

{#alphasrcfactor}

### alphaSrcFactor

```cpp
Factor alphaSrcFactor {BlendMode::Factor::One}
```

Type: [`Factor`](Factor.md#factor)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/BlendMode.hpp:122

Source blending factor for the alpha channel.

---

{#alphadstfactor}

### alphaDstFactor

```cpp
Factor alphaDstFactor {BlendMode::Factor::OneMinusSrcAlpha}
```

Type: [`Factor`](Factor.md#factor)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/BlendMode.hpp:123

Destination blending factor for the alpha channel.

---

{#alphaequation}

### alphaEquation

```cpp
Equation alphaEquation {BlendMode::Equation::Add}
```

Type: [`Equation`](Equation.md#equation)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/BlendMode.hpp:124

Blending equation for the alpha channel.

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`BlendMode`](#blendmode-1)  | Default constructor. |
|  | [`BlendMode`](#blendmode-2)  | Construct the blend mode given the factors and equation. |
|  | [`BlendMode`](#blendmode-3)  | Construct the blend mode given the factors and equation. |

---

{#blendmode-1}

### BlendMode

```cpp
BlendMode() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/BlendMode.hpp:83

Default constructor.

Constructs a blending mode that does alpha blending.

---

{#blendmode-2}

### BlendMode

```cpp
BlendMode(Factor sourceFactor, Factor destinationFactor, Equation blendEquation = Equation::Add)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/BlendMode.hpp:96

Construct the blend mode given the factors and equation.

This constructor uses the same factors and equation for both color and alpha components. It also defaults to the Add equation.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `sourceFactor` | [`Factor`](Factor.md#factor) | Specifies how to compute the source factor for the color and alpha channels. |
| `destinationFactor` | [`Factor`](Factor.md#factor) | Specifies how to compute the destination factor for the color and alpha channels. |
| `blendEquation` | [`Equation`](Equation.md#equation) | Specifies how to combine the source and destination colors and alpha. |

---

{#blendmode-3}

### BlendMode

```cpp
BlendMode(Factor colorSourceFactor, Factor colorDestinationFactor, Equation colorBlendEquation, Factor alphaSourceFactor, Factor alphaDestinationFactor, Equation alphaBlendEquation)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/BlendMode.hpp:109

Construct the blend mode given the factors and equation.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `colorSourceFactor` | [`Factor`](Factor.md#factor) | Specifies how to compute the source factor for the color channels. |
| `colorDestinationFactor` | [`Factor`](Factor.md#factor) | Specifies how to compute the destination factor for the color channels. |
| `colorBlendEquation` | [`Equation`](Equation.md#equation) | Specifies how to combine the source and destination colors. |
| `alphaSourceFactor` | [`Factor`](Factor.md#factor) | Specifies how to compute the source factor. |
| `alphaDestinationFactor` | [`Factor`](Factor.md#factor) | Specifies how to compute the destination factor. |
| `alphaBlendEquation` | [`Equation`](Equation.md#equation) | Specifies how to combine the source and destination alphas. |

## Public Types

| Name | Description |
|------|-------------|
| [`Factor`](#factor)  | Enumeration of the blending factors. |
| [`Equation`](#equation)  | Enumeration of the blending equations. |

---

{#factor}

### Factor

```cpp
enum Factor
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/BlendMode.hpp:48

Enumeration of the blending factors.

The factors are mapped directly to their OpenGL equivalents, specified by glBlendFunc() or glBlendFuncSeparate().

| Value | Description |
|-------|-------------|
| `Zero` | (0, 0, 0, 0) |
| `One` | (1, 1, 1, 1) |
| `SrcColor` | (src.r, src.g, src.b, src.a) |
| `OneMinusSrcColor` | (1, 1, 1, 1) - (src.r, src.g, src.b, src.a) |
| `DstColor` | (dst.r, dst.g, dst.b, dst.a) |
| `OneMinusDstColor` | (1, 1, 1, 1) - (dst.r, dst.g, dst.b, dst.a) |
| `SrcAlpha` | (src.a, src.a, src.a, src.a) |
| `OneMinusSrcAlpha` | (1, 1, 1, 1) - (src.a, src.a, src.a, src.a) |
| `DstAlpha` | (dst.a, dst.a, dst.a, dst.a) |
| `OneMinusDstAlpha` | (1, 1, 1, 1) - (dst.a, dst.a, dst.a, dst.a) |

---

{#equation}

### Equation

```cpp
enum Equation
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/BlendMode.hpp:68

Enumeration of the blending equations.

The equations are mapped directly to their OpenGL equivalents, specified by glBlendEquation() or glBlendEquationSeparate().

| Value | Description |
|-------|-------------|
| `Add` | Pixel = Src * SrcFactor + Dst * DstFactor. |
| `Subtract` | Pixel = Src * SrcFactor - Dst * DstFactor. |
| `ReverseSubtract` | Pixel = Dst * DstFactor - Src * SrcFactor. |
| `Min` | Pixel = min(Dst, Src) |
| `Max` | Pixel = max(Dst, Src) |
