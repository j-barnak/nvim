{#view}

# View

```cpp
#include <View.hpp>
```

```cpp
class View
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/View.hpp:45

2D camera that defines what region is shown on screen

`[sf::View](#view)` defines a camera in the 2D scene. This is a very powerful concept: you can scroll, rotate or zoom the entire scene without altering the way that your drawable objects are drawn.

A view is composed of a source rectangle, which defines what part of the 2D scene is shown, and a target viewport, which defines where the contents of the source rectangle will be displayed on the render target (window or texture).

The viewport allows to map the scene to a custom part of the render target, and can be used for split-screen or for displaying a minimap, for example. If the source rectangle doesn't have the same size as the viewport, its contents will be stretched to fit in.

The scissor rectangle allows for specifying regions of the render target to which modifications can be made by draw and clear operations. Only pixels that are within the region will be able to be modified. Pixels outside of the region will not be modified by draw or clear operations.

Certain effects can be created by either using the viewport or scissor rectangle. While the results appear identical, there can be times where one method should be preferred over the other. Viewport transformations are applied during the vertex processing stage of the graphics pipeline, before the primitives are rasterized into fragments for fragment processing. Since viewport processing has to be performed and cannot be disabled, effects that are performed using the viewport transform are basically free performance-wise. Scissor testing is performed in the per-sample processing stage of the graphics pipeline, after fragment processing has been performed. Because per-sample processing is performed at the last stage of the pipeline, fragments that are discarded at this stage will cause the highest waste of GPU resources compared to any method that would have discarded vertices or fragments earlier in the pipeline. There are situations in which scissor testing has to be used to control whether fragments are discarded or not. An example of such a situation is when performing the viewport transform on vertices is necessary but a subset of the generated fragments should not have an effect on the stencil buffer or blend with the color buffer.

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`View`](#view-1)  | Default constructor. |
|  | [`View`](#view-2) `explicit` | Construct the view from a rectangle. |
|  | [`View`](#view-3)  | Construct the view from its center and size. |
| `void` | [`setCenter`](#setcenter)  | Set the center of the view. |
| `void` | [`setSize`](#setsize-2)  | Set the size of the view. |
| `void` | [`setRotation`](#setrotation-1)  | Set the orientation of the view. |
| `void` | [`setViewport`](#setviewport)  | Set the target viewport. |
| `void` | [`setScissor`](#setscissor)  | Set the target scissor rectangle. |
| [`Vector2f`](sf.md#vector2f) | [`getCenter`](#getcenter-1) `const` `nodiscard` | Get the center of the view. |
| [`Vector2f`](sf.md#vector2f) | [`getSize`](#getsize-11) `const` `nodiscard` | Get the size of the view. |
| [`Angle`](sf-Angle.md#angle) | [`getRotation`](#getrotation-1) `const` `nodiscard` | Get the current orientation of the view. |
| const [`FloatRect`](sf.md#floatrect) & | [`getViewport`](#getviewport-1) `const` `nodiscard` | Get the target viewport rectangle of the view. |
| const [`FloatRect`](sf.md#floatrect) & | [`getScissor`](#getscissor-1) `const` `nodiscard` | Get the scissor rectangle of the view. |
| `void` | [`move`](#move-1)  | Move the view relative to its current position. |
| `void` | [`rotate`](#rotate-3)  | Rotate the view relative to its current orientation. |
| `void` | [`zoom`](#zoom)  | Resize the view rectangle relative to its current size. |
| const [`Transform`](sf-Transform.md#transform-1) & | [`getTransform`](#gettransform-1) `const` `nodiscard` | Get the projection transform of the view. |
| const [`Transform`](sf-Transform.md#transform-1) & | [`getInverseTransform`](#getinversetransform-1) `const` `nodiscard` | Get the inverse projection transform of the view. |

---

{#view-1}

### View

```cpp
View() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/View.hpp:54

Default constructor.

This constructor creates a default view of (0, 0, 1000, 1000)

---

{#view-2}

### View

`explicit`

```cpp
explicit View(const FloatRect & rectangle)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/View.hpp:62

Construct the view from a rectangle.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `rectangle` | const [`FloatRect`](sf.md#floatrect) & | Rectangle defining the zone to display |

---

{#view-3}

### View

```cpp
View(Vector2f center, Vector2f size)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/View.hpp:71

Construct the view from its center and size.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `center` | [`Vector2f`](sf.md#vector2f) | Center of the zone to display |
| `size` | [`Vector2f`](sf.md#vector2f) | Size of zone to display |

---

{#setcenter}

### setCenter

```cpp
void setCenter(Vector2f center)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/View.hpp:81

Set the center of the view.

**See also**: `[setSize](#setsize-2)`, `[getCenter](#getcenter-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `center` | [`Vector2f`](sf.md#vector2f) | New center |

---

{#setsize-2}

### setSize

```cpp
void setSize(Vector2f size)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/View.hpp:91

Set the size of the view.

**See also**: `[setCenter](#setcenter)`, `[getCenter](#getcenter-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `size` | [`Vector2f`](sf.md#vector2f) | New size |

---

{#setrotation-1}

### setRotation

```cpp
void setRotation(Angle angle)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/View.hpp:103

Set the orientation of the view.

The default rotation of a view is 0 degree.

**See also**: `[getRotation](#getrotation-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `angle` | [`Angle`](sf-Angle.md#angle) | New angle |

---

{#setviewport}

### setViewport

```cpp
void setViewport(const FloatRect & viewport)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/View.hpp:120

Set the target viewport.

The viewport is the rectangle into which the contents of the view are displayed, expressed as a factor (between 0 and 1) of the size of the [RenderTarget](sf-RenderTarget.md#rendertarget-1) to which the view is applied. For example, a view which takes the left side of the target would be defined with `view.setViewport([sf::FloatRect](sf.md#floatrect)({0.f, 0.f}, {0.5f, 1.f}))`. By default, a view has a viewport which covers the entire target.

**See also**: `[getViewport](#getviewport-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `viewport` | const [`FloatRect`](sf.md#floatrect) & | New viewport rectangle |

---

{#setscissor}

### setScissor

```cpp
void setScissor(const FloatRect & scissor)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/View.hpp:144

Set the target scissor rectangle.

The scissor rectangle, expressed as a factor (between 0 and 1) of the [RenderTarget](sf-RenderTarget.md#rendertarget-1), specifies the region of the [RenderTarget](sf-RenderTarget.md#rendertarget-1) whose pixels are able to be modified by draw or clear operations. Any pixels which lie outside of the scissor rectangle will not be modified by draw or clear operations. For example, a scissor rectangle which only allows modifications to the right side of the target would be defined with `view.setScissor([sf::FloatRect](sf.md#floatrect)({0.5f, 0.f}, {0.5f, 1.f}))`. By default, a view has a scissor rectangle which allows modifications to the entire target. This is equivalent to disabling the scissor test entirely. Passing the default scissor rectangle to this function will also disable scissor testing.

**See also**: `[getScissor](#getscissor-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `scissor` | const [`FloatRect`](sf.md#floatrect) & | New scissor rectangle |

---

{#getcenter-1}

### getCenter

`const` `nodiscard`

```cpp
[[nodiscard]] Vector2f getCenter() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/View.hpp:154

Get the center of the view.

#### Returns
Center of the view

**See also**: `[getSize](#getsize-11)`, `[setCenter](#setcenter)`

---

{#getsize-11}

### getSize

`const` `nodiscard`

```cpp
[[nodiscard]] Vector2f getSize() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/View.hpp:164

Get the size of the view.

#### Returns
Size of the view

**See also**: `[getCenter](#getcenter-1)`, `[setSize](#setsize-2)`

---

{#getrotation-1}

### getRotation

`const` `nodiscard`

```cpp
[[nodiscard]] Angle getRotation() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/View.hpp:174

Get the current orientation of the view.

#### Returns
Rotation angle of the view

**See also**: `[setRotation](#setrotation-1)`

---

{#getviewport-1}

### getViewport

`const` `nodiscard`

```cpp
[[nodiscard]] const FloatRect & getViewport() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/View.hpp:184

Get the target viewport rectangle of the view.

#### Returns
Viewport rectangle, expressed as a factor of the target size

**See also**: `[setViewport](#setviewport)`

---

{#getscissor-1}

### getScissor

`const` `nodiscard`

```cpp
[[nodiscard]] const FloatRect & getScissor() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/View.hpp:194

Get the scissor rectangle of the view.

#### Returns
Scissor rectangle, expressed as a factor of the target size

**See also**: `[setScissor](#setscissor)`

---

{#move-1}

### move

```cpp
void move(Vector2f offset)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/View.hpp:204

Move the view relative to its current position.

**See also**: `[setCenter](#setcenter)`, `[rotate](#rotate-3)`, `[zoom](#zoom)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `offset` | [`Vector2f`](sf.md#vector2f) | Move offset |

---

{#rotate-3}

### rotate

```cpp
void rotate(Angle angle)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/View.hpp:214

Rotate the view relative to its current orientation.

**See also**: `[setRotation](#setrotation-1)`, `[move](#move-1)`, `[zoom](#zoom)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `angle` | [`Angle`](sf-Angle.md#angle) | [Angle](sf-Angle.md#angle) to rotate |

---

{#zoom}

### zoom

```cpp
void zoom(float factor)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/View.hpp:231

Resize the view rectangle relative to its current size.

Resizing the view simulates a zoom, as the zone displayed on screen grows or shrinks. *factor* is a multiplier: 

* 1 keeps the size unchanged 
* > 1 makes the view bigger (objects appear smaller) 
* < 1 makes the view smaller (objects appear bigger)
**See also**: `[setSize](#setsize-2)`, `[move](#move-1)`, `[rotate](#rotate-3)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `factor` | `float` | Zoom factor to apply |

---

{#gettransform-1}

### getTransform

`const` `nodiscard`

```cpp
[[nodiscard]] const Transform & getTransform() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/View.hpp:243

Get the projection transform of the view.

This function is meant for internal use only.

#### Returns
Projection transform defining the view

**See also**: `[getInverseTransform](#getinversetransform-1)`

---

{#getinversetransform-1}

### getInverseTransform

`const` `nodiscard`

```cpp
[[nodiscard]] const Transform & getInverseTransform() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/View.hpp:255

Get the inverse projection transform of the view.

This function is meant for internal use only.

#### Returns
Inverse of the projection transform defining the view

**See also**: `[getTransform](#gettransform-1)`

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`Vector2f`](sf.md#vector2f) | [`m_center`](#m_center)  | Center of the view, in scene coordinates. |
| [`Vector2f`](sf.md#vector2f) | [`m_size`](#m_size-6)  | Size of the view, in scene coordinates. |
| [`Angle`](sf-Angle.md#angle) | [`m_rotation`](#m_rotation-1)  | [Angle](sf-Angle.md#angle) of rotation of the view rectangle. |
| [`FloatRect`](sf.md#floatrect) | [`m_viewport`](#m_viewport)  | Viewport rectangle, expressed as a factor of the render-target's size. |
| [`FloatRect`](sf.md#floatrect) | [`m_scissor`](#m_scissor)  | Scissor rectangle, expressed as a factor of the render-target's size. |
| [`Transform`](sf-Transform.md#transform-1) | [`m_transform`](#m_transform-1)  | Precomputed projection transform corresponding to the view. |
| [`Transform`](sf-Transform.md#transform-1) | [`m_inverseTransform`](#m_inversetransform-1)  | Precomputed inverse projection transform corresponding to the view. |
| `bool` | [`m_transformUpdated`](#m_transformupdated)  | Internal state telling if the transform needs to be updated. |
| `bool` | [`m_invTransformUpdated`](#m_invtransformupdated)  | Internal state telling if the inverse transform needs to be updated. |

---

{#m_center}

### m_center

```cpp
Vector2f m_center {500, 500}
```

Type: [`Vector2f`](sf.md#vector2f)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/View.hpp:261

Center of the view, in scene coordinates.

---

{#m_size-6}

### m_size

```cpp
Vector2f m_size {1000, 1000}
```

Type: [`Vector2f`](sf.md#vector2f)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/View.hpp:262

Size of the view, in scene coordinates.

---

{#m_rotation-1}

### m_rotation

```cpp
Angle m_rotation
```

Type: [`Angle`](sf-Angle.md#angle)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/View.hpp:263

[Angle](sf-Angle.md#angle) of rotation of the view rectangle.

---

{#m_viewport}

### m_viewport

```cpp
FloatRect m_viewport {{0, 0}, {1, 1}}
```

Type: [`FloatRect`](sf.md#floatrect)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/View.hpp:264

Viewport rectangle, expressed as a factor of the render-target's size.

---

{#m_scissor}

### m_scissor

```cpp
FloatRect m_scissor {{0, 0}, {1, 1}}
```

Type: [`FloatRect`](sf.md#floatrect)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/View.hpp:265

Scissor rectangle, expressed as a factor of the render-target's size.

---

{#m_transform-1}

### m_transform

```cpp
Transform m_transform
```

Type: [`Transform`](sf-Transform.md#transform-1)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/View.hpp:266

Precomputed projection transform corresponding to the view.

---

{#m_inversetransform-1}

### m_inverseTransform

```cpp
Transform m_inverseTransform
```

Type: [`Transform`](sf-Transform.md#transform-1)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/View.hpp:267

Precomputed inverse projection transform corresponding to the view.

---

{#m_transformupdated}

### m_transformUpdated

```cpp
bool m_transformUpdated {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/View.hpp:268

Internal state telling if the transform needs to be updated.

---

{#m_invtransformupdated}

### m_invTransformUpdated

```cpp
bool m_invTransformUpdated {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/View.hpp:269

Internal state telling if the inverse transform needs to be updated.

