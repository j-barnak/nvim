{#vector2}

# Vector2

```cpp
#include <Vector2.hpp>
```

```cpp
template<typename T>
class Vector2
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector2.hpp:43

Class template for manipulating 2-dimensional vectors.

`[sf::Vector2](#vector2)` is a simple class that defines a mathematical vector with two coordinates (x and y). It can be used to represent anything that has two dimensions: a size, a point, a velocity, a scale, etc.

The API provides basic arithmetic (addition, subtraction, scale), as well as more advanced geometric operations, such as dot/cross products, length and angle computations, projections, rotations, etc.

The template parameter T is the type of the coordinates. It can be any type that supports arithmetic operations (+, -, /, *) and comparisons (==, !=), for example int or float. Note that some operations are only meaningful for vectors where T is a floating point type (e.g. float or double), often because results cannot be represented accurately with integers. The method documentation mentions "(floating-point)" in those cases.

You generally don't have to care about the templated form (`[sf::Vector2](#vector2)<T>`), the most common specializations have special type aliases: 

* `[sf::Vector2](#vector2)<float>` is `[sf::Vector2f](sf.md#vector2f)`
* `[sf::Vector2](#vector2)<int>` is `[sf::Vector2i](sf.md#vector2i)`
* `[sf::Vector2](#vector2)<unsigned int>` is `[sf::Vector2u](sf.md#vector2u)`

The `[sf::Vector2](#vector2)` class has a simple interface, its x and y members can be accessed directly (there are no accessors like setX(), getX()).

Usage example: 
```cpp
sf::Vector2f v(16.5f, 24.f);
v.x = 18.2f;
float y = v.y;

sf::Vector2f w = v * 5.f;
sf::Vector2f u;
u = v + w;

float s = v.dot(w);

bool different = (v != u);
```

Note: for 3-dimensional vectors, see `[sf::Vector3](sf-Vector3.md#vector3)`.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `T` | [`x`](#x)  | X coordinate of the vector. |
| `T` | [`y`](#y)  | Y coordinate of the vector. |

---

{#x}

### x

```cpp
T x {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector2.hpp:206

X coordinate of the vector.

---

{#y}

### y

```cpp
T y {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector2.hpp:207

Y coordinate of the vector.

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
| `constexpr` | [`Vector2`](#vector2-1) `constexpr` | Default constructor. |
| `constexpr` | [`Vector2`](#vector2-2) `constexpr` | Construct the vector from cartesian coordinates. |
| `constexpr` | [`operator Vector2< U >`](#operatorvector2u) `const` `explicit` `constexpr` | Converts the vector to another type of vector. |
|  | [`Vector2`](#vector2-3)  | Construct the vector from polar coordinates ***(floating-point)*** |
| `T` | [`length`](#length-1) `const` `nodiscard` | Length of the vector ***(floating-point)***. |
| `T` | [`lengthSquared`](#lengthsquared) `const` `nodiscard` `constexpr` | Square of vector's length. |
| [`Vector2`](#vector2) | [`normalized`](#normalized) `const` `nodiscard` | Vector with same direction but length 1 ***(floating-point)***. |
| [`Angle`](sf-Angle.md#angle) | [`angleTo`](#angleto) `const` `nodiscard` | Signed angle from `*this` to `rhs`***(floating-point)***. |
| [`Angle`](sf-Angle.md#angle) | [`angle`](#angle-3) `const` `nodiscard` | Signed angle from +X or (1,0) vector ***(floating-point)***. |
| [`Vector2`](#vector2) | [`rotatedBy`](#rotatedby) `const` `nodiscard` | Rotate by angle `phi`***(floating-point)***. |
| [`Vector2`](#vector2) | [`projectedOnto`](#projectedonto) `const` `nodiscard` `constexpr` | Projection of this vector onto `axis`***(floating-point)***. |
| [`Vector2`](#vector2) | [`perpendicular`](#perpendicular) `const` `nodiscard` `constexpr` | Returns a perpendicular vector. |
| `T` | [`dot`](#dot) `const` `nodiscard` `constexpr` | Dot product of two 2D vectors. |
| `T` | [`cross`](#cross) `const` `nodiscard` `constexpr` | Z component of the cross product of two 2D vectors. |
| [`Vector2`](#vector2) | [`componentWiseMul`](#componentwisemul) `const` `nodiscard` `constexpr` | Component-wise multiplication of `*this` and `rhs`. |
| [`Vector2`](#vector2) | [`componentWiseDiv`](#componentwisediv) `const` `nodiscard` `constexpr` | Component-wise division of `*this` and `rhs`. |

---

{#vector2-1}

### Vector2

`constexpr`

```cpp
constexpr constexpr Vector2() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector2.hpp:52

Default constructor.

Creates a `Vector2(0, 0)`.

---

{#vector2-2}

### Vector2

`constexpr`

```cpp
constexpr constexpr Vector2(T x, T y)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector2.hpp:61

Construct the vector from cartesian coordinates.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `x` | `T` | X coordinate |
| `y` | `T` | Y coordinate |

---

{#operatorvector2u}

### operator Vector2< U >

`const` `explicit` `constexpr`

```cpp
template<typename U> constexpr explicit constexpr operator Vector2< U >() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector2.hpp:68

Converts the vector to another type of vector.

---

{#vector2-3}

### Vector2

```cpp
Vector2(T r, Angle phi)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector2.hpp:84

Construct the vector from polar coordinates ***(floating-point)***

Note that this constructor is lossy: calling `[length()](#length-1)` and `[angle()](#angle-3)` may return values different to those provided in this constructor.

In particular, these transforms can be applied:

* `Vector2(r, phi) == [Vector2](#vector2)(-r, phi + 180_deg)`
* `Vector2(r, phi) == [Vector2](#vector2)(r, phi + n * 360_deg)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `r` | `T` | Length of vector (can be negative) |
| `phi` | [`Angle`](sf-Angle.md#angle) | [Angle](sf-Angle.md#angle) from X axis |

---

{#length-1}

### length

`const` `nodiscard`

```cpp
[[nodiscard]] T length() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector2.hpp:92

Length of the vector ***(floating-point)***.

If you are not interested in the actual length, but only in comparisons, consider using `[lengthSquared()](#lengthsquared)`.

---

{#lengthsquared}

### lengthSquared

`const` `nodiscard` `constexpr`

```cpp
[[nodiscard]] constexpr T lengthSquared() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector2.hpp:100

Square of vector's length.

Suitable for comparisons, more efficient than `[length()](#length-1)`.

---

{#normalized}

### normalized

`const` `nodiscard`

```cpp
[[nodiscard]] Vector2 normalized() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector2.hpp:108

Vector with same direction but length 1 ***(floating-point)***.

#### Preconditions
`*this` is no zero vector.

---

{#angleto}

### angleTo

`const` `nodiscard`

```cpp
[[nodiscard]] Angle angleTo(Vector2 rhs) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector2.hpp:119

Signed angle from `*this` to `rhs`***(floating-point)***.

#### Returns
The smallest angle which rotates `*this` in positive or negative direction, until it has the same direction as `rhs`. The result has a sign and lies in the range [-180, 180) degrees. 

#### Preconditions
Neither `*this` nor `rhs` is a zero vector.

---

{#angle-3}

### angle

`const` `nodiscard`

```cpp
[[nodiscard]] Angle angle() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector2.hpp:130

Signed angle from +X or (1,0) vector ***(floating-point)***.

For example, the vector (1,0) corresponds to 0 degrees, (0,1) corresponds to 90 degrees.

#### Returns
[Angle](sf-Angle.md#angle) in the range [-180, 180) degrees. 

#### Preconditions
This vector is no zero vector.

---

{#rotatedby}

### rotatedBy

`const` `nodiscard`

```cpp
[[nodiscard]] Vector2 rotatedBy(Angle phi) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector2.hpp:141

Rotate by angle `phi`***(floating-point)***.

Returns a vector with same length but different direction.

In SFML's default coordinate system with +X right and +Y down, this amounts to a clockwise rotation by `phi`.

---

{#projectedonto}

### projectedOnto

`const` `nodiscard` `constexpr`

```cpp
[[nodiscard]] constexpr Vector2 projectedOnto(Vector2 axis) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector2.hpp:150

Projection of this vector onto `axis`***(floating-point)***.

#### Preconditions
`axis` must not have length zero.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `axis` | [`Vector2`](#vector2) | Vector being projected onto. Need not be normalized. |

---

{#perpendicular}

### perpendicular

`const` `nodiscard` `constexpr`

```cpp
[[nodiscard]] constexpr Vector2 perpendicular() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector2.hpp:162

Returns a perpendicular vector.

Returns `*this` rotated by +90 degrees; (x,y) becomes (-y,x). For example, the vector (1,0) is transformed to (0,1).

In SFML's default coordinate system with +X right and +Y down, this amounts to a clockwise rotation.

---

{#dot}

### dot

`const` `nodiscard` `constexpr`

```cpp
[[nodiscard]] constexpr T dot(Vector2 rhs) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector2.hpp:168

Dot product of two 2D vectors.

---

{#cross}

### cross

`const` `nodiscard` `constexpr`

```cpp
[[nodiscard]] constexpr T cross(Vector2 rhs) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector2.hpp:177

Z component of the cross product of two 2D vectors.

Treats the operands as 3D vectors, computes their cross product and returns the result's Z component (X and Y components are always zero).

---

{#componentwisemul}

### componentWiseMul

`const` `nodiscard` `constexpr`

```cpp
[[nodiscard]] constexpr Vector2 componentWiseMul(Vector2 rhs) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector2.hpp:188

Component-wise multiplication of `*this` and `rhs`.

Computes `(lhs.x*rhs.x, lhs.y*rhs.y)`.

Scaling is the most common use case for component-wise multiplication/division. This operation is also known as the Hadamard or Schur product.

---

{#componentwisediv}

### componentWiseDiv

`const` `nodiscard` `constexpr`

```cpp
[[nodiscard]] constexpr Vector2 componentWiseDiv(Vector2 rhs) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector2.hpp:200

Component-wise division of `*this` and `rhs`.

Computes `(lhs.x/rhs.x, lhs.y/rhs.y)`.

Scaling is the most common use case for component-wise multiplication/division.

#### Preconditions
Neither component of `rhs` is zero.

