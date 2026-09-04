{#shape}

# Shape

```cpp
#include <Shape.hpp>
```

```cpp
class Shape
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:54

> **Inherits:** [`Drawable`](sf-Drawable.md#drawable), [`Transformable`](sf-Transformable.md#transformable)
> **Subclassed by:** [`CircleShape`](sf-CircleShape.md#circleshape), [`ConvexShape`](sf-ConvexShape.md#convexshape), [`RectangleShape`](sf-RectangleShape.md#rectangleshape)

Base class for textured shapes with outline.

`[sf::Shape](#shape)` is a drawable class that allows to define and display a custom convex shape on a render target. It's only an abstract base, it needs to be specialized for concrete types of shapes (circle, rectangle, convex polygon, star, ...).

In addition to the attributes provided by the specialized shape classes, a shape always has the following attributes: 

* a texture 
* a texture rectangle 
* a fill color 
* an outline color 
* an outline thickness

Each feature is optional, and can be disabled easily: 

* the texture can be null 
* the fill/outline colors can be `[sf::Color::Transparent](sf-Color.md#transparent)`
* the outline thickness can be zero

You can write your own derived shape class, there are only two virtual functions to override: 

* getPointCount must return the number of points of the shape 
* getPoint must return the points of the shape
**See also**: `[sf::RectangleShape](sf-RectangleShape.md#rectangleshape)`, `[sf::CircleShape](sf-CircleShape.md#circleshape)`, `[sf::ConvexShape](sf-ConvexShape.md#convexshape)`, `[sf::Transformable](sf-Transformable.md#transformable)`

## List of all members

| Name | Kind | Owner |
|------|------|-------|
| [`setTexture`](#settexture) | `function` | Declared here |
| [`setTextureRect`](#settexturerect) | `function` | Declared here |
| [`setFillColor`](#setfillcolor) | `function` | Declared here |
| [`setOutlineColor`](#setoutlinecolor) | `function` | Declared here |
| [`setOutlineThickness`](#setoutlinethickness) | `function` | Declared here |
| [`setMiterLimit`](#setmiterlimit) | `function` | Declared here |
| [`getTexture`](#gettexture-2) | `function` | Declared here |
| [`getTextureRect`](#gettexturerect) | `function` | Declared here |
| [`getFillColor`](#getfillcolor) | `function` | Declared here |
| [`getOutlineColor`](#getoutlinecolor) | `function` | Declared here |
| [`getOutlineThickness`](#getoutlinethickness) | `function` | Declared here |
| [`getMiterLimit`](#getmiterlimit) | `function` | Declared here |
| [`getPointCount`](#getpointcount-3) | `function` | Declared here |
| [`getPoint`](#getpoint-3) | `function` | Declared here |
| [`getGeometricCenter`](#getgeometriccenter-2) | `function` | Declared here |
| [`getLocalBounds`](#getlocalbounds) | `function` | Declared here |
| [`getGlobalBounds`](#getglobalbounds) | `function` | Declared here |
| [`update`](#update-2) | `function` | Declared here |
| [`m_texture`](#m_texture-1) | `variable` | Declared here |
| [`m_textureRect`](#m_texturerect) | `variable` | Declared here |
| [`m_fillColor`](#m_fillcolor) | `variable` | Declared here |
| [`m_outlineColor`](#m_outlinecolor) | `variable` | Declared here |
| [`m_outlineThickness`](#m_outlinethickness) | `variable` | Declared here |
| [`m_miterLimit`](#m_miterlimit) | `variable` | Declared here |
| [`m_vertices`](#m_vertices) | `variable` | Declared here |
| [`m_outlineVertices`](#m_outlinevertices) | `variable` | Declared here |
| [`m_insideBounds`](#m_insidebounds) | `variable` | Declared here |
| [`m_bounds`](#m_bounds) | `variable` | Declared here |
| [`draw`](#draw-5) | `function` | Declared here |
| [`updateFillColors`](#updatefillcolors) | `function` | Declared here |
| [`updateTexCoords`](#updatetexcoords) | `function` | Declared here |
| [`updateOutline`](#updateoutline) | `function` | Declared here |
| [`updateOutlineColors`](#updateoutlinecolors) | `function` | Declared here |
| [`RenderTarget`](sf-Drawable.md#rendertarget) | `friend` | Inherited from [`Drawable`](sf-Drawable.md#drawable) |
| [`~Drawable`](sf-Drawable.md#drawable-1) | `function` | Inherited from [`Drawable`](sf-Drawable.md#drawable) |
| [`draw`](sf-Drawable.md#draw) | `function` | Inherited from [`Drawable`](sf-Drawable.md#drawable) |
| [`Transformable`](sf-Transformable.md#transformable-1) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`~Transformable`](sf-Transformable.md#transformable-2) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`setPosition`](sf-Transformable.md#setposition-5) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`setRotation`](sf-Transformable.md#setrotation) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`setScale`](sf-Transformable.md#setscale) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`setOrigin`](sf-Transformable.md#setorigin) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`getPosition`](sf-Transformable.md#getposition-7) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`getRotation`](sf-Transformable.md#getrotation) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`getScale`](sf-Transformable.md#getscale) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`getOrigin`](sf-Transformable.md#getorigin) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`move`](sf-Transformable.md#move) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`rotate`](sf-Transformable.md#rotate-2) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`scale`](sf-Transformable.md#scale-2) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`getTransform`](sf-Transformable.md#gettransform) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`getInverseTransform`](sf-Transformable.md#getinversetransform) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`m_origin`](sf-Transformable.md#m_origin) | `variable` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`m_position`](sf-Transformable.md#m_position) | `variable` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`m_rotation`](sf-Transformable.md#m_rotation) | `variable` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`m_scale`](sf-Transformable.md#m_scale) | `variable` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`m_transform`](sf-Transformable.md#m_transform) | `variable` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`m_inverseTransform`](sf-Transformable.md#m_inversetransform) | `variable` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`m_transformNeedUpdate`](sf-Transformable.md#m_transformneedupdate) | `variable` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`m_inverseTransformNeedUpdate`](sf-Transformable.md#m_inversetransformneedupdate) | `variable` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |

## Inherited from [`Drawable`](sf-Drawable.md#drawable)

| Kind | Name | Description |
|------|------|-------------|
| `friend` | [`RenderTarget`](sf-Drawable.md#rendertarget)  |  |
| `function` | [`~Drawable`](sf-Drawable.md#drawable-1) `virtual` | Virtual destructor. |
| `function` | [`draw`](sf-Drawable.md#draw) `virtual` `const` | Draw the object to a render target. |

## Inherited from [`Transformable`](sf-Transformable.md#transformable)

| Kind | Name | Description |
|------|------|-------------|
| `function` | [`Transformable`](sf-Transformable.md#transformable-1)  | Default constructor. |
| `function` | [`~Transformable`](sf-Transformable.md#transformable-2) `virtual` | Virtual destructor. |
| `function` | [`setPosition`](sf-Transformable.md#setposition-5)  | set the position of the object |
| `function` | [`setRotation`](sf-Transformable.md#setrotation)  | set the orientation of the object |
| `function` | [`setScale`](sf-Transformable.md#setscale)  | set the scale factors of the object |
| `function` | [`setOrigin`](sf-Transformable.md#setorigin)  | set the local origin of the object |
| `function` | [`getPosition`](sf-Transformable.md#getposition-7) `const` `nodiscard` | get the position of the object |
| `function` | [`getRotation`](sf-Transformable.md#getrotation) `const` `nodiscard` | get the orientation of the object |
| `function` | [`getScale`](sf-Transformable.md#getscale) `const` `nodiscard` | get the current scale of the object |
| `function` | [`getOrigin`](sf-Transformable.md#getorigin) `const` `nodiscard` | get the local origin of the object |
| `function` | [`move`](sf-Transformable.md#move)  | Move the object by a given offset. |
| `function` | [`rotate`](sf-Transformable.md#rotate-2)  | Rotate the object. |
| `function` | [`scale`](sf-Transformable.md#scale-2)  | Scale the object. |
| `function` | [`getTransform`](sf-Transformable.md#gettransform) `const` `nodiscard` | get the combined transform of the object |
| `function` | [`getInverseTransform`](sf-Transformable.md#getinversetransform) `const` `nodiscard` | get the inverse of the combined transform of the object |
| `variable` | [`m_origin`](sf-Transformable.md#m_origin)  | Origin of translation/rotation/scaling of the object. |
| `variable` | [`m_position`](sf-Transformable.md#m_position)  | Position of the object in the 2D world. |
| `variable` | [`m_rotation`](sf-Transformable.md#m_rotation)  | Orientation of the object. |
| `variable` | [`m_scale`](sf-Transformable.md#m_scale)  | Scale of the object. |
| `variable` | [`m_transform`](sf-Transformable.md#m_transform)  | Combined transformation of the object. |
| `variable` | [`m_inverseTransform`](sf-Transformable.md#m_inversetransform)  | Combined transformation of the object. |
| `variable` | [`m_transformNeedUpdate`](sf-Transformable.md#m_transformneedupdate)  | Does the transform need to be recomputed? |
| `variable` | [`m_inverseTransformNeedUpdate`](sf-Transformable.md#m_inversetransformneedupdate)  | Does the transform need to be recomputed? |

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`setTexture`](#settexture)  | Change the source texture of the shape. |
| `void` | [`setTextureRect`](#settexturerect)  | Set the sub-rectangle of the texture that the shape will display. |
| `void` | [`setFillColor`](#setfillcolor)  | Set the fill color of the shape. |
| `void` | [`setOutlineColor`](#setoutlinecolor)  | Set the outline color of the shape. |
| `void` | [`setOutlineThickness`](#setoutlinethickness)  | Set the thickness of the shape's outline. |
| `void` | [`setMiterLimit`](#setmiterlimit)  | Set the limit on the ratio between miter length and outline thickness. |
| const [`Texture`](sf-Texture.md#texture-2) * | [`getTexture`](#gettexture-2) `const` `nodiscard` | Get the source texture of the shape. |
| const [`IntRect`](sf.md#intrect) & | [`getTextureRect`](#gettexturerect) `const` `nodiscard` | Get the sub-rectangle of the texture displayed by the shape. |
| [`Color`](sf-Color.md#color) | [`getFillColor`](#getfillcolor) `const` `nodiscard` | Get the fill color of the shape. |
| [`Color`](sf-Color.md#color) | [`getOutlineColor`](#getoutlinecolor) `const` `nodiscard` | Get the outline color of the shape. |
| `float` | [`getOutlineThickness`](#getoutlinethickness) `const` `nodiscard` | Get the outline thickness of the shape. |
| `float` | [`getMiterLimit`](#getmiterlimit) `const` `nodiscard` | Get the limit on the ratio between miter length and outline thickness. |
| `std::size_t` | [`getPointCount`](#getpointcount-3) `virtual` `const` `nodiscard` | Get the total number of points of the shape. |
| [`Vector2f`](sf.md#vector2f) | [`getPoint`](#getpoint-3) `virtual` `const` `nodiscard` | Get a point of the shape. |
| [`Vector2f`](sf.md#vector2f) | [`getGeometricCenter`](#getgeometriccenter-2) `virtual` `const` `nodiscard` | Get the geometric center of the shape. |
| [`FloatRect`](sf.md#floatrect) | [`getLocalBounds`](#getlocalbounds) `const` `nodiscard` | Get the local bounding rectangle of the entity. |
| [`FloatRect`](sf.md#floatrect) | [`getGlobalBounds`](#getglobalbounds) `const` `nodiscard` | Get the global (non-minimal) bounding rectangle of the entity. |

---

{#settexture}

### setTexture

```cpp
void setTexture(const Texture * texture, bool resetRect = false)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:77

Change the source texture of the shape.

The `texture` argument refers to a texture that must exist as long as the shape uses it. Indeed, the shape doesn't store its own copy of the texture, but rather keeps a pointer to the one that you passed to this function. If the source texture is destroyed and the shape tries to use it, the behavior is undefined. `texture` can be a null pointer to disable texturing. If `resetRect` is `true`, the `TextureRect` property of the shape is automatically adjusted to the size of the new texture. If it is `false`, the texture rect is left unchanged.

**See also**: `[getTexture](#gettexture-2)`, `[setTextureRect](#settexturerect)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `texture` | const [`Texture`](sf-Texture.md#texture-2) * | New texture |
| `resetRect` | `bool` | Should the texture rect be reset to the size of the new texture? |

---

{#settexturerect}

### setTextureRect

```cpp
void setTextureRect(const IntRect & rect)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:91

Set the sub-rectangle of the texture that the shape will display.

The texture rect is useful when you don't want to display the whole texture, but rather a part of it. By default, the texture rect covers the entire texture.

**See also**: `[getTextureRect](#gettexturerect)`, `[setTexture](#settexture)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `rect` | const [`IntRect`](sf.md#intrect) & | Rectangle defining the region of the texture to display |

---

{#setfillcolor}

### setFillColor

```cpp
void setFillColor(Color color)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:108

Set the fill color of the shape.

This color is modulated (multiplied) with the shape's texture if any. It can be used to colorize the shape, or change its global opacity. You can use `[sf::Color::Transparent](sf-Color.md#transparent)` to make the inside of the shape transparent, and have the outline alone. By default, the shape's fill color is opaque white.

**See also**: `[getFillColor](#getfillcolor)`, `[setOutlineColor](#setoutlinecolor)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `color` | [`Color`](sf-Color.md#color) | New color of the shape |

---

{#setoutlinecolor}

### setOutlineColor

```cpp
void setOutlineColor(Color color)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:120

Set the outline color of the shape.

By default, the shape's outline color is opaque white.

**See also**: `[getOutlineColor](#getoutlinecolor)`, `[setFillColor](#setfillcolor)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `color` | [`Color`](sf-Color.md#color) | New outline color of the shape |

---

{#setoutlinethickness}

### setOutlineThickness

```cpp
void setOutlineThickness(float thickness)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:135

Set the thickness of the shape's outline.

Note that negative values are allowed (so that the outline expands towards the center of the shape), and using zero disables the outline. By default, the outline thickness is 0.

**See also**: `[getOutlineThickness](#getoutlinethickness)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `thickness` | `float` | New outline thickness |

---

{#setmiterlimit}

### setMiterLimit

```cpp
void setMiterLimit(float miterLimit)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:166

Set the limit on the ratio between miter length and outline thickness.

Outline segments around each shape corner are joined either with a miter or a bevel join.

* A miter join is formed by extending outline segments until they intersect. The distance between the point of intersection and the shape's corner is the miter length.
* A bevel join is formed by connecting outline segments with a straight line perpendicular to the corner's bissector.

The miter limit is used to determine whether ouline segments around a corner are joined with a bevel or a miter. When the ratio between the miter length and outline thickness exceeds the miter limit, a bevel is used instead of a miter.

The miter limit is linked to the maximum inner angle of a corner below which a bevel is used by the following formula:

miterLimit = 1 / sin(angle / 2)

The miter limit must be greater than or equal to 1. By default, the miter limit is 10.

**See also**: [getMiterLimit](#getmiterlimit)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `miterLimit` | `float` | New miter limit |

---

{#gettexture-2}

### getTexture

`const` `nodiscard`

```cpp
[[nodiscard]] const Texture * getTexture() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:180

Get the source texture of the shape.

If the shape has no source texture, a `nullptr` is returned. The returned pointer is const, which means that you can't modify the texture when you retrieve it with this function.

#### Returns
Pointer to the shape's texture

**See also**: `[setTexture](#settexture)`

---

{#gettexturerect}

### getTextureRect

`const` `nodiscard`

```cpp
[[nodiscard]] const IntRect & getTextureRect() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:190

Get the sub-rectangle of the texture displayed by the shape.

#### Returns
[Texture](sf-Texture.md#texture-2) rectangle of the shape

**See also**: `[setTextureRect](#settexturerect)`

---

{#getfillcolor}

### getFillColor

`const` `nodiscard`

```cpp
[[nodiscard]] Color getFillColor() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:200

Get the fill color of the shape.

#### Returns
Fill color of the shape

**See also**: `[setFillColor](#setfillcolor)`

---

{#getoutlinecolor}

### getOutlineColor

`const` `nodiscard`

```cpp
[[nodiscard]] Color getOutlineColor() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:210

Get the outline color of the shape.

#### Returns
Outline color of the shape

**See also**: `[setOutlineColor](#setoutlinecolor)`

---

{#getoutlinethickness}

### getOutlineThickness

`const` `nodiscard`

```cpp
[[nodiscard]] float getOutlineThickness() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:220

Get the outline thickness of the shape.

#### Returns
Outline thickness of the shape

**See also**: `[setOutlineThickness](#setoutlinethickness)`

---

{#getmiterlimit}

### getMiterLimit

`const` `nodiscard`

```cpp
[[nodiscard]] float getMiterLimit() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:230

Get the limit on the ratio between miter length and outline thickness.

#### Returns
Limit on the ratio between miter length and outline thickness

**See also**: [setMiterLimit](#setmiterlimit)

---

{#getpointcount-3}

### getPointCount

`virtual` `const` `nodiscard`

```cpp
[[nodiscard]] virtual std::size_t getPointCount() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:240

Get the total number of points of the shape.

#### Returns
Number of points of the shape

**See also**: `[getPoint](#getpoint-3)`

#### Reimplemented by

- [`getPointCount`](sf-CircleShape.md#getpointcount)
- [`getPointCount`](sf-ConvexShape.md#getpointcount-1)
- [`getPointCount`](sf-RectangleShape.md#getpointcount-2)

---

{#getpoint-3}

### getPoint

`virtual` `const` `nodiscard`

```cpp
[[nodiscard]] virtual Vector2f getPoint(std::size_t index) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:257

Get a point of the shape.

The returned point is in local coordinates, that is, the shape's transforms (position, rotation, scale) are not taken into account. The result is undefined if `index` is out of the valid range.

#### Returns
`index`-th point of the shape

**See also**: `[getPointCount](#getpointcount-3)`

#### Reimplemented by

- [`getPoint`](sf-CircleShape.md#getpoint)
- [`getPoint`](sf-ConvexShape.md#getpoint-1)
- [`getPoint`](sf-RectangleShape.md#getpoint-2)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `index` | `std::size_t` | Index of the point to get, in range [0 .. [getPointCount()](#getpointcount-3) - 1] |

---

{#getgeometriccenter-2}

### getGeometricCenter

`virtual` `const` `nodiscard`

```cpp
[[nodiscard]] virtual Vector2f getGeometricCenter() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:269

Get the geometric center of the shape.

The returned point is in local coordinates, that is, the shape's transforms (position, rotation, scale) are not taken into account.

#### Returns
The geometric center of the shape

#### Reimplemented by

- [`getGeometricCenter`](sf-CircleShape.md#getgeometriccenter)
- [`getGeometricCenter`](sf-RectangleShape.md#getgeometriccenter-1)

---

{#getlocalbounds}

### getLocalBounds

`const` `nodiscard`

```cpp
[[nodiscard]] FloatRect getLocalBounds() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:283

Get the local bounding rectangle of the entity.

The returned rectangle is in local coordinates, which means that it ignores the transformations (translation, rotation, scale, ...) that are applied to the entity. In other words, this function returns the bounds of the entity in the entity's coordinate system.

#### Returns
Local bounding rectangle of the entity

---

{#getglobalbounds}

### getGlobalBounds

`const` `nodiscard`

```cpp
[[nodiscard]] FloatRect getGlobalBounds() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:304

Get the global (non-minimal) bounding rectangle of the entity.

The returned rectangle is in global coordinates, which means that it takes into account the transformations (translation, rotation, scale, ...) that are applied to the entity. In other words, this function returns the bounds of the shape in the global 2D world's coordinate system.

This function does not necessarily return the *minimal* bounding rectangle. It merely ensures that the returned rectangle covers all the vertices (but possibly more). This allows for a fast approximation of the bounds as a first check; you may want to use more precise checks on top of that.

#### Returns
Global bounding rectangle of the entity

## Protected Methods

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`update`](#update-2)  | Recompute the internal geometry of the shape. |

---

{#update-2}

### update

```cpp
void update()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:315

Recompute the internal geometry of the shape.

This function must be called by the derived class every time the shape's points change (i.e. the result of either getPointCount or getPoint is different).

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| const [`Texture`](sf-Texture.md#texture-2) * | [`m_texture`](#m_texture-1)  | [Texture](sf-Texture.md#texture-2) of the shape. |
| [`IntRect`](sf.md#intrect) | [`m_textureRect`](#m_texturerect)  | Rectangle defining the area of the source texture to display. |
| [`Color`](sf-Color.md#color) | [`m_fillColor`](#m_fillcolor)  | Fill color. |
| [`Color`](sf-Color.md#color) | [`m_outlineColor`](#m_outlinecolor)  | Outline color. |
| `float` | [`m_outlineThickness`](#m_outlinethickness)  | Thickness of the shape's outline. |
| `float` | [`m_miterLimit`](#m_miterlimit)  | Limit on the ratio between miter length and outline thickness. |
| [`VertexArray`](sf-VertexArray.md#vertexarray) | [`m_vertices`](#m_vertices)  | [Vertex](sf-Vertex.md#vertex) array containing the fill geometry. |
| [`VertexArray`](sf-VertexArray.md#vertexarray) | [`m_outlineVertices`](#m_outlinevertices)  | [Vertex](sf-Vertex.md#vertex) array containing the outline geometry. |
| [`FloatRect`](sf.md#floatrect) | [`m_insideBounds`](#m_insidebounds)  | Bounding rectangle of the inside (fill) |
| [`FloatRect`](sf.md#floatrect) | [`m_bounds`](#m_bounds)  | Bounding rectangle of the whole shape (outline + fill) |

---

{#m_texture-1}

### m_texture

```cpp
const Texture * m_texture {}
```

Type: const [`Texture`](sf-Texture.md#texture-2) *

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:354

[Texture](sf-Texture.md#texture-2) of the shape.

---

{#m_texturerect}

### m_textureRect

```cpp
IntRect m_textureRect
```

Type: [`IntRect`](sf.md#intrect)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:355

Rectangle defining the area of the source texture to display.

---

{#m_fillcolor}

### m_fillColor

```cpp
Color m_fillColor {Color::White}
```

Type: [`Color`](sf-Color.md#color)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:356

Fill color.

---

{#m_outlinecolor}

### m_outlineColor

```cpp
Color m_outlineColor {Color::White}
```

Type: [`Color`](sf-Color.md#color)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:357

Outline color.

---

{#m_outlinethickness}

### m_outlineThickness

```cpp
float m_outlineThickness {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:358

Thickness of the shape's outline.

---

{#m_miterlimit}

### m_miterLimit

```cpp
float m_miterLimit {10.f}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:359

Limit on the ratio between miter length and outline thickness.

---

{#m_vertices}

### m_vertices

```cpp
VertexArray m_vertices {PrimitiveType::TriangleFan}
```

Type: [`VertexArray`](sf-VertexArray.md#vertexarray)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:360

[Vertex](sf-Vertex.md#vertex) array containing the fill geometry.

---

{#m_outlinevertices}

### m_outlineVertices

```cpp
VertexArray m_outlineVertices {PrimitiveType::TriangleStrip}
```

Type: [`VertexArray`](sf-VertexArray.md#vertexarray)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:361

[Vertex](sf-Vertex.md#vertex) array containing the outline geometry.

---

{#m_insidebounds}

### m_insideBounds

```cpp
FloatRect m_insideBounds
```

Type: [`FloatRect`](sf.md#floatrect)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:362

Bounding rectangle of the inside (fill)

---

{#m_bounds}

### m_bounds

```cpp
FloatRect m_bounds
```

Type: [`FloatRect`](sf.md#floatrect)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:363

Bounding rectangle of the whole shape (outline + fill)

## Private Methods

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`draw`](#draw-5) `virtual` `const` `override` | Draw the shape to a render target. |
| `void` | [`updateFillColors`](#updatefillcolors)  | Update the fill vertices' color. |
| `void` | [`updateTexCoords`](#updatetexcoords)  | Update the fill vertices' texture coordinates. |
| `void` | [`updateOutline`](#updateoutline)  | Update the outline vertices' position. |
| `void` | [`updateOutlineColors`](#updateoutlinecolors)  | Update the outline vertices' color. |

---

{#draw-5}

### draw

`virtual` `const` `override`

```cpp
virtual void draw(RenderTarget & target, RenderStates states) const override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:325

Draw the shape to a render target.

#### Reimplements

- [`draw`](sf-Drawable.md#draw)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `target` | [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) & | Render target to draw to |
| `states` | [`RenderStates`](sf-RenderStates.md#renderstates) | Current render states |

---

{#updatefillcolors}

### updateFillColors

```cpp
void updateFillColors()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:331

Update the fill vertices' color.

---

{#updatetexcoords}

### updateTexCoords

```cpp
void updateTexCoords()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:337

Update the fill vertices' texture coordinates.

---

{#updateoutline}

### updateOutline

```cpp
void updateOutline()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:343

Update the outline vertices' position.

---

{#updateoutlinecolors}

### updateOutlineColors

```cpp
void updateOutlineColors()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shape.hpp:349

Update the outline vertices' color.

