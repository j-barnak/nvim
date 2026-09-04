{#angle}

# Angle

```cpp
#include <Angle.hpp>
```

```cpp
class Angle
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Angle.hpp:34

Represents an angle value.

`[sf::Angle](#angle)` encapsulates an angle value in a flexible way. It allows for defining an angle value either as a number of degrees or radians. It also works the other way around. You can read an angle value as either a number of degrees or radians.

By using such a flexible interface, the API doesn't impose any fixed type or unit for angle values and lets the user choose their own preferred representation.

[Angle](#angle) values support the usual mathematical operations. You can add or subtract two angles, multiply or divide an angle by a number, compare two angles, etc.

Usage example: 
```cpp
sf::Angle a1  = sf::degrees(90);
float radians = a1.asRadians(); // 1.5708f

sf::Angle a2 = sf::radians(3.141592654f);
float degrees = a2.asDegrees(); // 180.0f

using namespace sf::Literals;
sf::Angle a3 = 10_deg;   // 10 degrees
sf::Angle a4 = 1.5_deg;  // 1.5 degrees
sf::Angle a5 = 1_rad;    // 1 radians
sf::Angle a6 = 3.14_rad; // 3.14 radians
```

## Friends

| Name | Description |
|------|-------------|
| [`degrees`](#degrees) `constexpr` | Construct an angle value from a number of degrees. |
| [`radians`](#radians) `constexpr` | Construct an angle value from a number of radians. |

---

{#degrees}

### degrees

`constexpr`

```cpp
friend constexpr Angle degrees(float angle)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Angle.hpp:138

Construct an angle value from a number of degrees.

#### Returns
[Angle](#angle) value constructed from the number of degrees

**See also**: `[radians](#radians)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `angle` | `float` | Number of degrees |

---

{#radians}

### radians

`constexpr`

```cpp
friend constexpr Angle radians(float angle)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Angle.hpp:139

Construct an angle value from a number of radians.

#### Returns
[Angle](#angle) value constructed from the number of radians

**See also**: `[degrees](#degrees)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `angle` | `float` | Number of radians |

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
| `constexpr` | [`Angle`](#angle-1) `constexpr` | Default constructor. |
| `float` | [`asDegrees`](#asdegrees) `const` `nodiscard` `constexpr` | Return the angle's value in degrees. |
| `float` | [`asRadians`](#asradians) `const` `nodiscard` `constexpr` | Return the angle's value in radians. |
| [`Angle`](#angle) | [`wrapSigned`](#wrapsigned) `const` `nodiscard` `constexpr` | Wrap to a range such that -180° <= angle < 180° |
| [`Angle`](#angle) | [`wrapUnsigned`](#wrapunsigned) `const` `nodiscard` `constexpr` | Wrap to a range such that 0° <= angle < 360° |

---

{#angle-1}

### Angle

`constexpr`

```cpp
constexpr constexpr Angle() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Angle.hpp:43

Default constructor.

Sets the angle value to zero.

---

{#asdegrees}

### asDegrees

`const` `nodiscard` `constexpr`

```cpp
[[nodiscard]] constexpr float asDegrees() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Angle.hpp:53

Return the angle's value in degrees.

#### Returns
[Angle](#angle) in degrees

**See also**: `[asRadians](#asradians)`

---

{#asradians}

### asRadians

`const` `nodiscard` `constexpr`

```cpp
[[nodiscard]] constexpr float asRadians() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Angle.hpp:63

Return the angle's value in radians.

#### Returns
[Angle](#angle) in radians

**See also**: `[asDegrees](#asdegrees)`

---

{#wrapsigned}

### wrapSigned

`const` `nodiscard` `constexpr`

```cpp
[[nodiscard]] constexpr Angle wrapSigned() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Angle.hpp:96

Wrap to a range such that -180° <= angle < 180°

Similar to a modulo operation, this returns a copy of the angle constrained to the range [-180°, 180°) == [-Pi, Pi). The resulting angle represents a rotation which is equivalent to `*this`.

The name "signed" originates from the similarity to signed integers: 
|signed|unsigned
--------- | --------- | ---------
char|[-128, 128)|[0, 256)
[Angle](#angle)|[-180°, 180°)|[0°, 360°)

#### Returns
Signed angle, wrapped to [-180°, 180°)

**See also**: `[wrapUnsigned](#wrapunsigned)`

---

{#wrapunsigned}

### wrapUnsigned

`const` `nodiscard` `constexpr`

```cpp
[[nodiscard]] constexpr Angle wrapUnsigned() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Angle.hpp:129

Wrap to a range such that 0° <= angle < 360°

Similar to a modulo operation, this returns a copy of the angle constrained to the range [0°, 360°) == [0, Tau) == [0, 2*Pi). The resulting angle represents a rotation which is equivalent to `*this`.

The name "unsigned" originates from the similarity to unsigned integers: 
|signed|unsigned
--------- | --------- | ---------
char|[-128, 128)|[0, 256)
[Angle](#angle)|[-180°, 180°)|[0°, 360°)

#### Returns
Unsigned angle, wrapped to [0°, 360°)

**See also**: `[wrapSigned](#wrapsigned)`

## Public Static Attributes

| Return | Name | Description |
|--------|------|-------------|
| const [`Angle`](#angle) | [`Zero`](#zero) `static` `constexpr` | Predefined 0 degree angle value. |

---

{#zero}

### Zero

`static` `constexpr`

```cpp
const Angle Zero
```

Type: const [`Angle`](#angle)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Angle.hpp:135

Predefined 0 degree angle value.

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `float` | [`m_radians`](#m_radians)  | [Angle](#angle) value stored as radians. |

---

{#m_radians}

### m_radians

```cpp
float m_radians {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Angle.hpp:155

[Angle](#angle) value stored as radians.

## Private Methods

| Return | Name | Description |
|--------|------|-------------|
| `constexpr` | [`Angle`](#angle-2) `explicit` `constexpr` | Construct from a number of radians. |

---

{#angle-2}

### Angle

`explicit` `constexpr`

```cpp
constexpr explicit constexpr Angle(float radians)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Angle.hpp:150

Construct from a number of radians.

This function is internal. To construct angle values, use `[sf::radians](sf.md#radians-1)` or `[sf::degrees](sf.md#degrees-1)` instead.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `radians` | `float` | [Angle](#angle) in radians |

