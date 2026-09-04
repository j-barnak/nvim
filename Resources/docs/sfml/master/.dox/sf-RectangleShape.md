{#rectangleshape}

# RectangleShape

```cpp
#include <RectangleShape.hpp>
```

```cpp
class RectangleShape
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RectangleShape.hpp:45

> **Inherits:** [`Shape`](sf-Shape.md#shape)

Specialized shape representing a rectangle.

This class inherits all the functions of `[sf::Transformable](sf-Transformable.md#transformable)` (position, rotation, scale, bounds, ...) as well as the functions of `[sf::Shape](sf-Shape.md#shape)` (outline, color, texture, ...).

Usage example: 
```cpp
sf::RectangleShape rectangle;
rectangle.setSize(sf::Vector2f(100, 50));
rectangle.setOutlineColor(sf::Color::Red);
rectangle.setOutlineThickness(5);
rectangle.setPosition({10, 20});
...
window.draw(rectangle);
```

**See also**: `[sf::Shape](sf-Shape.md#shape)`, `[sf::CircleShape](sf-CircleShape.md#circleshape)`, `[sf::ConvexShape](sf-ConvexShape.md#convexshape)`

## List of all members

| Name | Kind | Owner |
|------|------|-------|
| [`RectangleShape`](#rectangleshape-1) | `function` | Declared here |
| [`setSize`](#setsize-1) | `function` | Declared here |
| [`getSize`](#getsize-6) | `function` | Declared here |
| [`getPointCount`](#getpointcount-2) | `function` | Declared here |
| [`getPoint`](#getpoint-2) | `function` | Declared here |
| [`getGeometricCenter`](#getgeometriccenter-1) | `function` | Declared here |
| [`m_size`](#m_size-3) | `variable` | Declared here |
| [`setTexture`](sf-Shape.md#settexture) | `function` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`setTextureRect`](sf-Shape.md#settexturerect) | `function` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`setFillColor`](sf-Shape.md#setfillcolor) | `function` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`setOutlineColor`](sf-Shape.md#setoutlinecolor) | `function` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`setOutlineThickness`](sf-Shape.md#setoutlinethickness) | `function` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`setMiterLimit`](sf-Shape.md#setmiterlimit) | `function` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`getTexture`](sf-Shape.md#gettexture-2) | `function` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`getTextureRect`](sf-Shape.md#gettexturerect) | `function` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`getFillColor`](sf-Shape.md#getfillcolor) | `function` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`getOutlineColor`](sf-Shape.md#getoutlinecolor) | `function` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`getOutlineThickness`](sf-Shape.md#getoutlinethickness) | `function` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`getMiterLimit`](sf-Shape.md#getmiterlimit) | `function` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`getPointCount`](sf-Shape.md#getpointcount-3) | `function` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`getPoint`](sf-Shape.md#getpoint-3) | `function` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`getGeometricCenter`](sf-Shape.md#getgeometriccenter-2) | `function` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`getLocalBounds`](sf-Shape.md#getlocalbounds) | `function` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`getGlobalBounds`](sf-Shape.md#getglobalbounds) | `function` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`update`](sf-Shape.md#update-2) | `function` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`m_texture`](sf-Shape.md#m_texture-1) | `variable` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`m_textureRect`](sf-Shape.md#m_texturerect) | `variable` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`m_fillColor`](sf-Shape.md#m_fillcolor) | `variable` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`m_outlineColor`](sf-Shape.md#m_outlinecolor) | `variable` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`m_outlineThickness`](sf-Shape.md#m_outlinethickness) | `variable` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`m_miterLimit`](sf-Shape.md#m_miterlimit) | `variable` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`m_vertices`](sf-Shape.md#m_vertices) | `variable` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`m_outlineVertices`](sf-Shape.md#m_outlinevertices) | `variable` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`m_insideBounds`](sf-Shape.md#m_insidebounds) | `variable` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`m_bounds`](sf-Shape.md#m_bounds) | `variable` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`draw`](sf-Shape.md#draw-5) | `function` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`updateFillColors`](sf-Shape.md#updatefillcolors) | `function` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`updateTexCoords`](sf-Shape.md#updatetexcoords) | `function` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`updateOutline`](sf-Shape.md#updateoutline) | `function` | Inherited from [`Shape`](sf-Shape.md#shape) |
| [`updateOutlineColors`](sf-Shape.md#updateoutlinecolors) | `function` | Inherited from [`Shape`](sf-Shape.md#shape) |
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

## Inherited from [`Shape`](sf-Shape.md#shape)

| Kind | Name | Description |
|------|------|-------------|
| `function` | [`setTexture`](sf-Shape.md#settexture)  | Change the source texture of the shape. |
| `function` | [`setTextureRect`](sf-Shape.md#settexturerect)  | Set the sub-rectangle of the texture that the shape will display. |
| `function` | [`setFillColor`](sf-Shape.md#setfillcolor)  | Set the fill color of the shape. |
| `function` | [`setOutlineColor`](sf-Shape.md#setoutlinecolor)  | Set the outline color of the shape. |
| `function` | [`setOutlineThickness`](sf-Shape.md#setoutlinethickness)  | Set the thickness of the shape's outline. |
| `function` | [`setMiterLimit`](sf-Shape.md#setmiterlimit)  | Set the limit on the ratio between miter length and outline thickness. |
| `function` | [`getTexture`](sf-Shape.md#gettexture-2) `const` `nodiscard` | Get the source texture of the shape. |
| `function` | [`getTextureRect`](sf-Shape.md#gettexturerect) `const` `nodiscard` | Get the sub-rectangle of the texture displayed by the shape. |
| `function` | [`getFillColor`](sf-Shape.md#getfillcolor) `const` `nodiscard` | Get the fill color of the shape. |
| `function` | [`getOutlineColor`](sf-Shape.md#getoutlinecolor) `const` `nodiscard` | Get the outline color of the shape. |
| `function` | [`getOutlineThickness`](sf-Shape.md#getoutlinethickness) `const` `nodiscard` | Get the outline thickness of the shape. |
| `function` | [`getMiterLimit`](sf-Shape.md#getmiterlimit) `const` `nodiscard` | Get the limit on the ratio between miter length and outline thickness. |
| `function` | [`getPointCount`](sf-Shape.md#getpointcount-3) `virtual` `const` `nodiscard` | Get the total number of points of the shape. |
| `function` | [`getPoint`](sf-Shape.md#getpoint-3) `virtual` `const` `nodiscard` | Get a point of the shape. |
| `function` | [`getGeometricCenter`](sf-Shape.md#getgeometriccenter-2) `virtual` `const` `nodiscard` | Get the geometric center of the shape. |
| `function` | [`getLocalBounds`](sf-Shape.md#getlocalbounds) `const` `nodiscard` | Get the local bounding rectangle of the entity. |
| `function` | [`getGlobalBounds`](sf-Shape.md#getglobalbounds) `const` `nodiscard` | Get the global (non-minimal) bounding rectangle of the entity. |
| `function` | [`update`](sf-Shape.md#update-2)  | Recompute the internal geometry of the shape. |
| `variable` | [`m_texture`](sf-Shape.md#m_texture-1)  | [Texture](sf-Texture.md#texture-2) of the shape. |
| `variable` | [`m_textureRect`](sf-Shape.md#m_texturerect)  | Rectangle defining the area of the source texture to display. |
| `variable` | [`m_fillColor`](sf-Shape.md#m_fillcolor)  | Fill color. |
| `variable` | [`m_outlineColor`](sf-Shape.md#m_outlinecolor)  | Outline color. |
| `variable` | [`m_outlineThickness`](sf-Shape.md#m_outlinethickness)  | Thickness of the shape's outline. |
| `variable` | [`m_miterLimit`](sf-Shape.md#m_miterlimit)  | Limit on the ratio between miter length and outline thickness. |
| `variable` | [`m_vertices`](sf-Shape.md#m_vertices)  | [Vertex](sf-Vertex.md#vertex) array containing the fill geometry. |
| `variable` | [`m_outlineVertices`](sf-Shape.md#m_outlinevertices)  | [Vertex](sf-Vertex.md#vertex) array containing the outline geometry. |
| `variable` | [`m_insideBounds`](sf-Shape.md#m_insidebounds)  | Bounding rectangle of the inside (fill) |
| `variable` | [`m_bounds`](sf-Shape.md#m_bounds)  | Bounding rectangle of the whole shape (outline + fill) |
| `function` | [`draw`](sf-Shape.md#draw-5) `virtual` `const` `override` | Draw the shape to a render target. |
| `function` | [`updateFillColors`](sf-Shape.md#updatefillcolors)  | Update the fill vertices' color. |
| `function` | [`updateTexCoords`](sf-Shape.md#updatetexcoords)  | Update the fill vertices' texture coordinates. |
| `function` | [`updateOutline`](sf-Shape.md#updateoutline)  | Update the outline vertices' position. |
| `function` | [`updateOutlineColors`](sf-Shape.md#updateoutlinecolors)  | Update the outline vertices' color. |

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
|  | [`RectangleShape`](#rectangleshape-1) `explicit` | Default constructor. |
| `void` | [`setSize`](#setsize-1)  | Set the size of the rectangle. |
| [`Vector2f`](sf.md#vector2f) | [`getSize`](#getsize-6) `const` `nodiscard` | Get the size of the rectangle. |
| `std::size_t` | [`getPointCount`](#getpointcount-2) `virtual` `const` `nodiscard` `override` | Get the number of points defining the shape. |
| [`Vector2f`](sf.md#vector2f) | [`getPoint`](#getpoint-2) `virtual` `const` `nodiscard` `override` | Get a point of the rectangle. |
| [`Vector2f`](sf.md#vector2f) | [`getGeometricCenter`](#getgeometriccenter-1) `virtual` `const` `nodiscard` `override` | Get the geometric center of the rectangle. |

---

{#rectangleshape-1}

### RectangleShape

`explicit`

```cpp
explicit RectangleShape(Vector2f size = {})
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RectangleShape.hpp:54

Default constructor.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `size` | [`Vector2f`](sf.md#vector2f) | Size of the rectangle |

---

{#setsize-1}

### setSize

```cpp
void setSize(Vector2f size)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RectangleShape.hpp:64

Set the size of the rectangle.

**See also**: `[getSize](#getsize-6)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `size` | [`Vector2f`](sf.md#vector2f) | New size of the rectangle |

---

{#getsize-6}

### getSize

`const` `nodiscard`

```cpp
[[nodiscard]] Vector2f getSize() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RectangleShape.hpp:74

Get the size of the rectangle.

#### Returns
Size of the rectangle

**See also**: `[setSize](#setsize-1)`

---

{#getpointcount-2}

### getPointCount

`virtual` `const` `nodiscard` `override`

```cpp
[[nodiscard]] virtual std::size_t getPointCount() const override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RectangleShape.hpp:83

Get the number of points defining the shape.

#### Returns
Number of points of the shape. For rectangle shapes, this number is always 4.

#### Reimplements

- [`getPointCount`](sf-Shape.md#getpointcount-3)

---

{#getpoint-2}

### getPoint

`virtual` `const` `nodiscard` `override`

```cpp
[[nodiscard]] virtual Vector2f getPoint(std::size_t index) const override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RectangleShape.hpp:98

Get a point of the rectangle.

The returned point is in local coordinates, that is, the shape's transforms (position, rotation, scale) are not taken into account. The result is undefined if `index` is out of the valid range.

#### Returns
`index`-th point of the shape

#### Reimplements

- [`getPoint`](sf-Shape.md#getpoint-3)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `index` | `std::size_t` | Index of the point to get, in range [0 .. 3] |

---

{#getgeometriccenter-1}

### getGeometricCenter

`virtual` `const` `nodiscard` `override`

```cpp
[[nodiscard]] virtual Vector2f getGeometricCenter() const override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RectangleShape.hpp:110

Get the geometric center of the rectangle.

The returned point is in local coordinates, that is, the shape's transforms (position, rotation, scale) are not taken into account.

#### Returns
The geometric center of the shape

#### Reimplements

- [`getGeometricCenter`](sf-Shape.md#getgeometriccenter-2)

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`Vector2f`](sf.md#vector2f) | [`m_size`](#m_size-3)  | Size of the rectangle. |

---

{#m_size-3}

### m_size

```cpp
Vector2f m_size
```

Type: [`Vector2f`](sf.md#vector2f)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RectangleShape.hpp:116

Size of the rectangle.

