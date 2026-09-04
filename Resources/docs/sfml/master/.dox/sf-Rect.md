{#rect}

# Rect

```cpp
#include <Rect.hpp>
```

```cpp
template<typename T>
class Rect
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Rect.hpp:42

Utility class for manipulating 2D axis aligned rectangles.

A rectangle is defined by its top-left corner and its size. It is a very simple class defined for convenience, so its member variables (position and size) are public and can be accessed directly, just like the vector classes (`[Vector2](sf-Vector2.md#vector2)` and `[Vector3](sf-Vector3.md#vector3)`).

To keep things simple, `[sf::Rect](#rect)` doesn't define functions to emulate the properties that are not directly members (such as right, bottom, etc.), it rather only provides intersection functions.

`[sf::Rect](#rect)` uses the usual rules for its boundaries: 

* The left and top edges are included in the rectangle's area 
* The right and bottom edges are excluded from the rectangle's area

This means that `[sf::IntRect](sf.md#intrect)({0, 0}, {1, 1})` and `[sf::IntRect](sf.md#intrect)({1, 1}, {1, 1})` don't intersect.

`[sf::Rect](#rect)` is a template and may be used with any numeric type, but for simplicity type aliases for the instantiations used by SFML are given: 

* `[sf::Rect](#rect)<int>` is `[sf::IntRect](sf.md#intrect)`
* `[sf::Rect](#rect)<float>` is `[sf::FloatRect](sf.md#floatrect)`

So that you don't have to care about the template syntax.

Usage example: 
```cpp
// Define a rectangle, located at (0, 0) with a size of 20x5
sf::IntRect r1({0, 0}, {20, 5});

// Define another rectangle, located at (4, 2) with a size of 18x10
sf::Vector2i position(4, 2);
sf::Vector2i size(18, 10);
sf::IntRect r2(position, size);

// Test intersections with the point (3, 1)
bool b1 = r1.contains({3, 1}); // true
bool b2 = r2.contains({3, 1}); // false

// Test the intersection between r1 and r2
std::optional<sf::IntRect> result = r1.findIntersection(r2);
// result.has_value() == true
// result.value() == sf::IntRect({4, 2}, {16, 3})
```

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`Vector2`](sf-Vector2.md#vector2)< T > | [`position`](#position-8)  | Position of the top-left corner of the rectangle. |
| [`Vector2`](sf-Vector2.md#vector2)< T > | [`size`](#size-4)  | Size of the rectangle. |

---

{#position-8}

### position

```cpp
Vector2< T > position {}
```

Type: [`Vector2`](sf-Vector2.md#vector2)< T >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Rect.hpp:111

Position of the top-left corner of the rectangle.

---

{#size-4}

### size

```cpp
Vector2< T > size {}
```

Type: [`Vector2`](sf-Vector2.md#vector2)< T >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Rect.hpp:112

Size of the rectangle.

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
| `constexpr` | [`Rect`](#rect-1) `constexpr` | Default constructor. |
| `constexpr` | [`Rect`](#rect-2) `constexpr` | Construct the rectangle from position and size. |
| `constexpr` | [`operator Rect< U >`](#operatorrectu) `const` `explicit` `constexpr` | Converts the rectangle to another type of rectangle. |
| `bool` | [`contains`](#contains) `const` `nodiscard` `constexpr` | Check if a point is inside the rectangle's area. |
| std::optional< [`Rect`](#rect)< T > > | [`findIntersection`](#findintersection) `const` `nodiscard` `constexpr` | Check the intersection between two rectangles. |
| [`Vector2`](sf-Vector2.md#vector2)< T > | [`getCenter`](#getcenter) `const` `nodiscard` `constexpr` | Get the position of the center of the rectangle. |

---

{#rect-1}

### Rect

`constexpr`

```cpp
constexpr constexpr Rect() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Rect.hpp:52

Default constructor.

Creates an empty rectangle (it is equivalent to calling `[Rect](#rect)({0, 0}, {0, 0})`).

---

{#rect-2}

### Rect

`constexpr`

```cpp
constexpr constexpr Rect(Vector2< T > position, Vector2< T > size)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Rect.hpp:64

Construct the rectangle from position and size.

Be careful, the last parameter is the size, not the bottom-right corner!

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `position` | [`Vector2`](sf-Vector2.md#vector2)< T > | Position of the top-left corner of the rectangle |
| `size` | [`Vector2`](sf-Vector2.md#vector2)< T > | Size of the rectangle |

---

{#operatorrectu}

### operator Rect< U >

`const` `explicit` `constexpr`

```cpp
template<typename U> constexpr explicit constexpr operator Rect< U >() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Rect.hpp:71

Converts the rectangle to another type of rectangle.

---

{#contains}

### contains

`const` `nodiscard` `constexpr`

```cpp
[[nodiscard]] constexpr bool contains(Vector2< T > point) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Rect.hpp:86

Check if a point is inside the rectangle's area.

This check is non-inclusive. If the point lies on the edge of the rectangle, this function will return `false`.

#### Returns
`true` if the point is inside, `false` otherwise

**See also**: `[findIntersection](#findintersection)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `point` | [`Vector2`](sf-Vector2.md#vector2)< T > | Point to test |

---

{#findintersection}

### findIntersection

`const` `nodiscard` `constexpr`

```cpp
[[nodiscard]] constexpr std::optional< Rect< T > > findIntersection(const Rect< T > & rectangle) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Rect.hpp:98

Check the intersection between two rectangles.

#### Returns
Intersection rectangle if intersecting, `std::nullopt` otherwise

**See also**: `[contains](#contains)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `rectangle` | const [`Rect`](#rect)< T > & | Rectangle to test |

---

{#getcenter}

### getCenter

`const` `nodiscard` `constexpr`

```cpp
[[nodiscard]] constexpr Vector2< T > getCenter() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Rect.hpp:106

Get the position of the center of the rectangle.

#### Returns
Center of rectangle

