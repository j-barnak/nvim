{#renderstates}

# RenderStates

```cpp
#include <RenderStates.hpp>
```

```cpp
class RenderStates
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderStates.hpp:47

Define the states used for drawing to a `[RenderTarget](sf-RenderTarget.md#rendertarget-1)`

There are six global states that can be applied to the drawn objects: 

* the blend mode: how pixels of the object are blended with the background 
* the stencil mode: how pixels of the object interact with the stencil buffer 
* the transform: how the object is positioned/rotated/scaled 
* the texture coordinate type: how texture coordinates are interpreted 
* the texture: what image is mapped to the object 
* the shader: what custom effect is applied to the object

High-level objects such as sprites or text force some of these states when they are drawn. For example, a sprite will set its own texture, so that you don't have to care about it when drawing the sprite.

The transform is a special case: sprites, texts and shapes (and it's a good idea to do it with your own drawable classes too) combine their transform with the one that is passed in the [RenderStates](#renderstates) structure. So that you can use a "global" transform on top of each object's transform.

Most objects, especially high-level drawables, can be drawn directly without defining render states explicitly &ndash; the default set of states is ok in most cases. 
```cpp
window.draw(sprite);
```

If you want to use a single specific render state, for example a shader, you can pass it directly to the Draw function: `[sf::RenderStates](#renderstates)` has an implicit one-argument constructor for each state. 
```cpp
window.draw(sprite, shader);
```

When you're inside the Draw function of a drawable object (inherited from `[sf::Drawable](sf-Drawable.md#drawable)`), you can either pass the render states unmodified, or change some of them. For example, a transformable object will combine the current transform with its own transform. A sprite will set its texture. Etc.

**See also**: `[sf::RenderTarget](sf-RenderTarget.md#rendertarget-1)`, `[sf::Drawable](sf-Drawable.md#drawable)`

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`BlendMode`](sf-BlendMode.md#blendmode) | [`blendMode`](#blendmode-4)  | Blending mode. |
| [`StencilMode`](sf-StencilMode.md#stencilmode-1) | [`stencilMode`](#stencilmode)  | Stencil mode. |
| [`Transform`](sf-Transform.md#transform-1) | [`transform`](#transform)  | [Transform](sf-Transform.md#transform-1). |
| [`CoordinateType`](CoordinateType.md#coordinatetype) | [`coordinateType`](#coordinatetype-1)  | [Texture](sf-Texture.md#texture-2) coordinate type. |
| const [`Texture`](sf-Texture.md#texture-2) * | [`texture`](#texture-1)  | [Texture](sf-Texture.md#texture-2). |
| const [`Shader`](sf-Shader.md#shader-1) * | [`shader`](#shader)  | [Shader](sf-Shader.md#shader-1). |

---

{#blendmode-4}

### blendMode

```cpp
BlendMode blendMode {BlendAlpha}
```

Type: [`BlendMode`](sf-BlendMode.md#blendmode)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderStates.hpp:131

Blending mode.

---

{#stencilmode}

### stencilMode

```cpp
StencilMode stencilMode
```

Type: [`StencilMode`](sf-StencilMode.md#stencilmode-1)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderStates.hpp:132

Stencil mode.

---

{#transform}

### transform

```cpp
Transform transform
```

Type: [`Transform`](sf-Transform.md#transform-1)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderStates.hpp:133

[Transform](sf-Transform.md#transform-1).

---

{#coordinatetype-1}

### coordinateType

```cpp
CoordinateType coordinateType {CoordinateType::Pixels}
```

Type: [`CoordinateType`](CoordinateType.md#coordinatetype)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderStates.hpp:134

[Texture](sf-Texture.md#texture-2) coordinate type.

---

{#texture-1}

### texture

```cpp
const Texture * texture {}
```

Type: const [`Texture`](sf-Texture.md#texture-2) *

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderStates.hpp:135

[Texture](sf-Texture.md#texture-2).

---

{#shader}

### shader

```cpp
const Shader * shader {}
```

Type: const [`Shader`](sf-Shader.md#shader-1) *

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderStates.hpp:136

[Shader](sf-Shader.md#shader-1).

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`RenderStates`](#renderstates-1)  | Default constructor. |
|  | [`RenderStates`](#renderstates-2)  | Construct a default set of render states with a custom blend mode. |
|  | [`RenderStates`](#renderstates-3)  | Construct a default set of render states with a custom stencil mode. |
|  | [`RenderStates`](#renderstates-4)  | Construct a default set of render states with a custom transform. |
|  | [`RenderStates`](#renderstates-5)  | Construct a default set of render states with a custom texture. |
|  | [`RenderStates`](#renderstates-6)  | Construct a default set of render states with a custom shader. |
|  | [`RenderStates`](#renderstates-7)  | Construct a set of render states with all its attributes. |

---

{#renderstates-1}

### RenderStates

```cpp
RenderStates() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderStates.hpp:62

Default constructor.

Constructing a default set of render states is equivalent to using `[sf::RenderStates::Default](#default)`. The default set defines: 

* the `BlendAlpha` blend mode 
* the default `[StencilMode](sf-StencilMode.md#stencilmode-1)` (no stencil) 
* the identity transform 
* a `nullptr` texture 
* a `nullptr` shader

---

{#renderstates-2}

### RenderStates

```cpp
RenderStates(const BlendMode & theBlendMode)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderStates.hpp:70

Construct a default set of render states with a custom blend mode.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `theBlendMode` | const [`BlendMode`](sf-BlendMode.md#blendmode) & | Blend mode to use |

---

{#renderstates-3}

### RenderStates

```cpp
RenderStates(const StencilMode & theStencilMode)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderStates.hpp:78

Construct a default set of render states with a custom stencil mode.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `theStencilMode` | const [`StencilMode`](sf-StencilMode.md#stencilmode-1) & | Stencil mode to use |

---

{#renderstates-4}

### RenderStates

```cpp
RenderStates(const Transform & theTransform)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderStates.hpp:86

Construct a default set of render states with a custom transform.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `theTransform` | const [`Transform`](sf-Transform.md#transform-1) & | [Transform](sf-Transform.md#transform-1) to use |

---

{#renderstates-5}

### RenderStates

```cpp
RenderStates(const Texture * theTexture)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderStates.hpp:94

Construct a default set of render states with a custom texture.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `theTexture` | const [`Texture`](sf-Texture.md#texture-2) * | [Texture](sf-Texture.md#texture-2) to use |

---

{#renderstates-6}

### RenderStates

```cpp
RenderStates(const Shader * theShader)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderStates.hpp:102

Construct a default set of render states with a custom shader.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `theShader` | const [`Shader`](sf-Shader.md#shader-1) * | [Shader](sf-Shader.md#shader-1) to use |

---

{#renderstates-7}

### RenderStates

```cpp
RenderStates(const BlendMode & theBlendMode, const StencilMode & theStencilMode, const Transform & theTransform, CoordinateType theCoordinateType, const Texture * theTexture, const Shader * theShader)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderStates.hpp:115

Construct a set of render states with all its attributes.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `theBlendMode` | const [`BlendMode`](sf-BlendMode.md#blendmode) & | Blend mode to use |
| `theStencilMode` | const [`StencilMode`](sf-StencilMode.md#stencilmode-1) & | Stencil mode to use |
| `theTransform` | const [`Transform`](sf-Transform.md#transform-1) & | [Transform](sf-Transform.md#transform-1) to use |
| `theCoordinateType` | [`CoordinateType`](CoordinateType.md#coordinatetype) | [Texture](sf-Texture.md#texture-2) coordinate type to use |
| `theTexture` | const [`Texture`](sf-Texture.md#texture-2) * | [Texture](sf-Texture.md#texture-2) to use |
| `theShader` | const [`Shader`](sf-Shader.md#shader-1) * | [Shader](sf-Shader.md#shader-1) to use |

## Public Static Attributes

| Return | Name | Description |
|--------|------|-------------|
| const [`RenderStates`](#renderstates) | [`Default`](#default) `static` | Special instance holding the default render states. |

---

{#default}

### Default

`static`

```cpp
const RenderStates Default
```

Type: const [`RenderStates`](#renderstates)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderStates.hpp:126

Special instance holding the default render states.

