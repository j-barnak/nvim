{#transform-1}

# Transform

```cpp
#include <Transform.hpp>
```

```cpp
class Transform
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transform.hpp:47

3x3 transform matrix

A `[sf::Transform](#transform-1)` specifies how to translate, rotate, scale, shear, project, whatever things. In mathematical terms, it defines how to transform a coordinate system into another.

For example, if you apply a rotation transform to a sprite, the result will be a rotated sprite. And anything that is transformed by this rotation transform will be rotated the same way, according to its initial position.

Transforms are typically used for drawing. But they can also be used for any computation that requires to transform points between the local and global coordinate systems of an entity (like collision detection).

Example: 
```cpp
// define a translation transform
sf::Transform translation;
translation.translate(20, 50);

// define a rotation transform
sf::Transform rotation;
rotation.rotate(45);

// combine them
sf::Transform transform = translation * rotation;

// use the result to transform stuff...
sf::Vector2f point = transform.transformPoint({10, 20});
sf::FloatRect rect = transform.transformRect(sf::FloatRect({0, 0}, {10, 100}));
```

**See also**: `[sf::Transformable](sf-Transformable.md#transformable)`, `[sf::RenderStates](sf-RenderStates.md#renderstates)`

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
| `constexpr` | [`Transform`](#transform-2) `constexpr` | Default constructor. |
| `constexpr` | [`Transform`](#transform-3) `constexpr` | Construct a transform from a 3x3 matrix. |
| `const float *` | [`getMatrix`](#getmatrix) `const` `nodiscard` `constexpr` | Return the transform as a 4x4 matrix. |
| [`Transform`](#transform-1) | [`getInverse`](#getinverse) `const` `nodiscard` `constexpr` | Return the inverse of the transform. |
| [`Vector2f`](sf.md#vector2f) | [`transformPoint`](#transformpoint) `const` `nodiscard` `constexpr` | [Transform](#transform-1) a 2D point. |
| [`FloatRect`](sf.md#floatrect) | [`transformRect`](#transformrect) `const` `nodiscard` `constexpr` | [Transform](#transform-1) a rectangle. |
| [`Transform`](#transform-1) & | [`combine`](#combine) `constexpr` | Combine the current transform with another one. |
| [`Transform`](#transform-1) & | [`translate`](#translate) `constexpr` | Combine the current transform with a translation. |
| [`SFML_GRAPHICS_API`](api.md#sfml_graphics_api)[`Transform`](#transform-1) & | [`rotate`](#rotate)  | Combine the current transform with a rotation. |
| [`SFML_GRAPHICS_API`](api.md#sfml_graphics_api)[`Transform`](#transform-1) & | [`rotate`](#rotate-1)  | Combine the current transform with a rotation. |
| [`Transform`](#transform-1) & | [`scale`](#scale) `constexpr` | Combine the current transform with a scaling. |
| [`Transform`](#transform-1) & | [`scale`](#scale-1) `constexpr` | Combine the current transform with a scaling. |

---

{#transform-2}

### Transform

`constexpr`

```cpp
constexpr constexpr Transform() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transform.hpp:56

Default constructor.

Creates an identity transform (a transform that does nothing).

---

{#transform-3}

### Transform

`constexpr`

```cpp
constexpr constexpr Transform(float a00, float a01, float a02, float a10, float a11, float a12, float a20, float a21, float a22)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transform.hpp:72

Construct a transform from a 3x3 matrix.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `a00` | `float` | Element (0, 0) of the matrix |
| `a01` | `float` | Element (0, 1) of the matrix |
| `a02` | `float` | Element (0, 2) of the matrix |
| `a10` | `float` | Element (1, 0) of the matrix |
| `a11` | `float` | Element (1, 1) of the matrix |
| `a12` | `float` | Element (1, 2) of the matrix |
| `a20` | `float` | Element (2, 0) of the matrix |
| `a21` | `float` | Element (2, 1) of the matrix |
| `a22` | `float` | Element (2, 2) of the matrix |

---

{#getmatrix}

### getMatrix

`const` `nodiscard` `constexpr`

```cpp
[[nodiscard]] constexpr const float * getMatrix() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transform.hpp:89

Return the transform as a 4x4 matrix.

This function returns a pointer to an array of 16 floats containing the transform elements as a 4x4 matrix, which is directly compatible with OpenGL functions.

```cpp
sf::Transform transform = ...;
glLoadMatrixf(transform.getMatrix());
```

#### Returns
Pointer to a 4x4 matrix

---

{#getinverse}

### getInverse

`const` `nodiscard` `constexpr`

```cpp
[[nodiscard]] constexpr Transform getInverse() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transform.hpp:100

Return the inverse of the transform.

If the inverse cannot be computed, an identity transform is returned.

#### Returns
A new transform which is the inverse of self

---

{#transformpoint}

### transformPoint

`const` `nodiscard` `constexpr`

```cpp
[[nodiscard]] constexpr Vector2f transformPoint(Vector2f point) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transform.hpp:116

[Transform](#transform-1) a 2D point.

These two statements are equivalent: 
```cpp
sf::Vector2f transformedPoint = matrix.transformPoint(point);
sf::Vector2f transformedPoint = matrix * point;
```

#### Returns
Transformed point

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `point` | [`Vector2f`](sf.md#vector2f) | Point to transform |

---

{#transformrect}

### transformRect

`const` `nodiscard` `constexpr`

```cpp
[[nodiscard]] constexpr FloatRect transformRect(const FloatRect & rectangle) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transform.hpp:132

[Transform](#transform-1) a rectangle.

Since SFML doesn't provide support for oriented rectangles, the result of this function is always an axis-aligned rectangle. Which means that if the transform contains a rotation, the bounding rectangle of the transformed rectangle is returned.

#### Returns
Transformed rectangle

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `rectangle` | const [`FloatRect`](sf.md#floatrect) & | Rectangle to transform |

---

{#combine}

### combine

`constexpr`

```cpp
constexpr Transform & combine(const Transform & transform)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transform.hpp:152

Combine the current transform with another one.

The result is a transform that is equivalent to applying `transform` followed by `*this`. Mathematically, it is equivalent to a matrix multiplication `(*this) * transform`.

These two statements are equivalent: 
```cpp
left.combine(right);
left *= right;
```

#### Returns
Reference to `*this`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `transform` | const [`Transform`](#transform-1) & | [Transform](#transform-1) to combine with this transform |

---

{#translate}

### translate

`constexpr`

```cpp
constexpr Transform & translate(Vector2f offset)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transform.hpp:171

Combine the current transform with a translation.

This function returns a reference to `*this`, so that calls can be chained. 
```cpp
sf::Transform transform;
transform.translate(sf::Vector2f(100, 200)).rotate(sf::degrees(45));
```

#### Returns
Reference to `*this`

**See also**: `[rotate](#rotate)`, `[scale](#scale)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `offset` | [`Vector2f`](sf.md#vector2f) | Translation offset to apply |

---

{#rotate}

### rotate

```cpp
SFML_GRAPHICS_APITransform & rotate(Angle angle)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transform.hpp:190

Combine the current transform with a rotation.

This function returns a reference to `*this`, so that calls can be chained. 
```cpp
sf::Transform transform;
transform.rotate(sf::degrees(90)).translate(50, 20);
```

#### Returns
Reference to `*this`

**See also**: `[translate](#translate)`, `[scale](#scale)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `angle` | [`Angle`](sf-Angle.md#angle) | Rotation angle |

---

{#rotate-1}

### rotate

```cpp
SFML_GRAPHICS_APITransform & rotate(Angle angle, Vector2f center)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transform.hpp:215

Combine the current transform with a rotation.

The center of rotation is provided for convenience as a second argument, so that you can build rotations around arbitrary points more easily (and efficiently) than the usual `translate(-center).rotate(angle).translate(center)`.

This function returns a reference to `*this`, so that calls can be chained. 
```cpp
sf::Transform transform;
transform.rotate(sf::degrees(90), sf::Vector2f(8, 3)).translate(sf::Vector2f(50, 20));
```

#### Returns
Reference to `*this`

**See also**: `[translate](#translate)`, `[scale](#scale)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `angle` | [`Angle`](sf-Angle.md#angle) | Rotation angle |
| `center` | [`Vector2f`](sf.md#vector2f) | Center of rotation |

---

{#scale}

### scale

`constexpr`

```cpp
constexpr Transform & scale(Vector2f factors)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transform.hpp:234

Combine the current transform with a scaling.

This function returns a reference to `*this`, so that calls can be chained. 
```cpp
sf::Transform transform;
transform.scale(sf::Vector2f(2, 1)).rotate(sf::degrees(45));
```

#### Returns
Reference to `*this`

**See also**: `[translate](#translate)`, `[rotate](#rotate)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `factors` | [`Vector2f`](sf.md#vector2f) | Scaling factors |

---

{#scale-1}

### scale

`constexpr`

```cpp
constexpr Transform & scale(Vector2f factors, Vector2f center)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transform.hpp:259

Combine the current transform with a scaling.

The center of scaling is provided for convenience as a second argument, so that you can build scaling around arbitrary points more easily (and efficiently) than the usual `translate(-center).scale(factors).translate(center)`.

This function returns a reference to `*this`, so that calls can be chained. 
```cpp
sf::Transform transform;
transform.scale(sf::Vector2f(2, 1), sf::Vector2f(8, 3)).rotate(45);
```

#### Returns
Reference to `*this`

**See also**: `[translate](#translate)`, `[rotate](#rotate)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `factors` | [`Vector2f`](sf.md#vector2f) | Scaling factors |
| `center` | [`Vector2f`](sf.md#vector2f) | Center of scaling |

## Public Static Attributes

| Return | Name | Description |
|--------|------|-------------|
| const [`Transform`](#transform-1) | [`Identity`](#identity) `static` `constexpr` | The identity transform (does nothing) |

---

{#identity}

### Identity

`static` `constexpr`

```cpp
const Transform Identity
```

Type: const [`Transform`](#transform-1)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transform.hpp:265

The identity transform (does nothing)

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::array< float, 16 >` | [`m_matrix`](#m_matrix)  | 4x4 matrix defining the transformation |

---

{#m_matrix}

### m_matrix

```cpp
std::array< float, 16 > m_matrix {1.f, 0.f, 0.f, 0.f,
                                   0.f, 1.f, 0.f, 0.f,
                                   0.f, 0.f, 1.f, 0.f,
                                   0.f, 0.f, 0.f, 1.f}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transform.hpp:272

4x4 matrix defining the transformation

