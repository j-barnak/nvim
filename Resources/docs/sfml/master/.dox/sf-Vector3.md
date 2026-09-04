{#vector3}

# Vector3

```cpp
#include <Vector3.hpp>
```

```cpp
template<typename T>
class Vector3
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector3.hpp:40

Utility template class for manipulating 3-dimensional vectors.

`[sf::Vector3](#vector3)` is a simple class that defines a mathematical vector with three coordinates (x, y and z). It can be used to represent anything that has three dimensions: a size, a point, a velocity, etc.

The template parameter T is the type of the coordinates. It can be any type that supports arithmetic operations (+, -, /, *) and comparisons (==, !=), for example int or float. Note that some operations are only meaningful for vectors where T is a floating point type (e.g. float or double), often because results cannot be represented accurately with integers. The method documentation mentions "(floating-point)" in those cases.

You generally don't have to care about the templated form (`[sf::Vector3](#vector3)<T>`), the most common specializations have special type aliases: 

* `[sf::Vector3](#vector3)<float>` is `[sf::Vector3f](sf.md#vector3f)`
* `[sf::Vector3](#vector3)<int>` is `[sf::Vector3i](sf.md#vector3i)`

The `[sf::Vector3](#vector3)` class has a small and simple interface, its x, y and z members can be accessed directly (there are no accessors like `setX()`, `getX()`).

Usage example: 
```cpp
sf::Vector3f v(16.5f, 24.f, -3.2f);
v.x = 18.2f;
float y = v.y;

sf::Vector3f w = v * 5.f;
sf::Vector3f u;
u = v + w;

float s = v.dot(w);
sf::Vector3f t = v.cross(w);

bool different = (v != u);
```

Note: for 2-dimensional vectors, see `[sf::Vector2](sf-Vector2.md#vector2)`.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `T` | [`x`](#x-1)  | X coordinate of the vector. |
| `T` | [`y`](#y-1)  | Y coordinate of the vector. |
| `T` | [`z`](#z)  | Z coordinate of the vector. |

---

{#x-1}

### x

```cpp
T x {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector3.hpp:130

X coordinate of the vector.

---

{#y-1}

### y

```cpp
T y {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector3.hpp:131

Y coordinate of the vector.

---

{#z}

### z

```cpp
T z {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector3.hpp:132

Z coordinate of the vector.

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
| `constexpr` | [`Vector3`](#vector3-1) `constexpr` | Default constructor. |
| `constexpr` | [`Vector3`](#vector3-2) `constexpr` | Construct the vector from its coordinates. |
| `constexpr` | [`operator Vector3< U >`](#operatorvector3u) `const` `explicit` `constexpr` | Converts the vector to another type of vector. |
| `T` | [`length`](#length-2) `const` `nodiscard` | Length of the vector ***(floating-point)***. |
| `T` | [`lengthSquared`](#lengthsquared-1) `const` `nodiscard` `constexpr` | Square of vector's length. |
| [`Vector3`](#vector3) | [`normalized`](#normalized-1) `const` `nodiscard` | Vector with same direction but length 1 ***(floating-point)***. |
| `T` | [`dot`](#dot-1) `const` `nodiscard` `constexpr` | Dot product of two 3D vectors. |
| [`Vector3`](#vector3) | [`cross`](#cross-1) `const` `nodiscard` `constexpr` | Cross product of two 3D vectors. |
| [`Vector3`](#vector3) | [`componentWiseMul`](#componentwisemul-1) `const` `nodiscard` `constexpr` | Component-wise multiplication of `*this` and `rhs`. |
| [`Vector3`](#vector3) | [`componentWiseDiv`](#componentwisediv-1) `const` `nodiscard` `constexpr` | Component-wise division of `*this` and `rhs`. |

---

{#vector3-1}

### Vector3

`constexpr`

```cpp
constexpr constexpr Vector3() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector3.hpp:49

Default constructor.

Creates a `Vector3(0, 0, 0)`.

---

{#vector3-2}

### Vector3

`constexpr`

```cpp
constexpr constexpr Vector3(T x, T y, T z)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector3.hpp:59

Construct the vector from its coordinates.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `x` | `T` | X coordinate |
| `y` | `T` | Y coordinate |
| `z` | `T` | Z coordinate |

---

{#operatorvector3u}

### operator Vector3< U >

`const` `explicit` `constexpr`

```cpp
template<typename U> constexpr explicit constexpr operator Vector3< U >() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector3.hpp:66

Converts the vector to another type of vector.

---

{#length-2}

### length

`const` `nodiscard`

```cpp
[[nodiscard]] T length() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector3.hpp:74

Length of the vector ***(floating-point)***.

If you are not interested in the actual length, but only in comparisons, consider using `[lengthSquared()](#lengthsquared-1)`.

---

{#lengthsquared-1}

### lengthSquared

`const` `nodiscard` `constexpr`

```cpp
[[nodiscard]] constexpr T lengthSquared() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector3.hpp:82

Square of vector's length.

Suitable for comparisons, more efficient than `[length()](#length-2)`.

---

{#normalized-1}

### normalized

`const` `nodiscard`

```cpp
[[nodiscard]] Vector3 normalized() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector3.hpp:90

Vector with same direction but length 1 ***(floating-point)***.

#### Preconditions
`*this` is no zero vector.

---

{#dot-1}

### dot

`const` `nodiscard` `constexpr`

```cpp
[[nodiscard]] constexpr T dot(const Vector3 & rhs) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector3.hpp:96

Dot product of two 3D vectors.

---

{#cross-1}

### cross

`const` `nodiscard` `constexpr`

```cpp
[[nodiscard]] constexpr Vector3 cross(const Vector3 & rhs) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector3.hpp:102

Cross product of two 3D vectors.

---

{#componentwisemul-1}

### componentWiseMul

`const` `nodiscard` `constexpr`

```cpp
[[nodiscard]] constexpr Vector3 componentWiseMul(const Vector3 & rhs) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector3.hpp:113

Component-wise multiplication of `*this` and `rhs`.

Computes `(lhs.x*rhs.x, lhs.y*rhs.y, lhs.z*rhs.z)`.

Scaling is the most common use case for component-wise multiplication/division. This operation is also known as the Hadamard or Schur product.

---

{#componentwisediv-1}

### componentWiseDiv

`const` `nodiscard` `constexpr`

```cpp
[[nodiscard]] constexpr Vector3 componentWiseDiv(const Vector3 & rhs) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Vector3.hpp:125

Component-wise division of `*this` and `rhs`.

Computes `(lhs.x/rhs.x, lhs.y/rhs.y, lhs.z/rhs.z)`.

Scaling is the most common use case for component-wise multiplication/division.

#### Preconditions
Neither component of `rhs` is zero.

