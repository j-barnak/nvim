{#color}

# Color

```cpp
#include <Color.hpp>
```

```cpp
class Color
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Color.hpp:39

Utility class for manipulating RGBA colors.

`[sf::Color](#color)` is a simple color class composed of 4 components: 

* Red 
* Green 
* Blue 
* Alpha (opacity)

Each component is a public member, an unsigned integer in the range [0, 255]. Thus, colors can be constructed and manipulated very easily:

```cpp
sf::Color color(255, 0, 0); // red
color.r = 0;                // make it black
color.b = 128;              // make it dark blue
```

The fourth component of colors, named "alpha", represents the opacity of the color. A color with an alpha value of 255 will be fully opaque, while an alpha value of 0 will make a color fully transparent, whatever the value of the other components is.

The most common colors are already defined as static variables: 
```cpp
sf::Color black       = sf::Color::Black;
sf::Color white       = sf::Color::White;
sf::Color red         = sf::Color::Red;
sf::Color green       = sf::Color::Green;
sf::Color blue        = sf::Color::Blue;
sf::Color yellow      = sf::Color::Yellow;
sf::Color magenta     = sf::Color::Magenta;
sf::Color cyan        = sf::Color::Cyan;
sf::Color transparent = sf::Color::Transparent;
```

Colors can also be added and modulated (multiplied) using the overloaded operators + and *.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::uint8_t` | [`r`](#r)  | Red component. |
| `std::uint8_t` | [`g`](#g)  | Green component. |
| `std::uint8_t` | [`b`](#b)  | Blue component. |
| `std::uint8_t` | [`a`](#a)  | Alpha (opacity) component. |

---

{#r}

### r

```cpp
std::uint8_t r {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Color.hpp:96

Red component.

---

{#g}

### g

```cpp
std::uint8_t g {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Color.hpp:97

Green component.

---

{#b}

### b

```cpp
std::uint8_t b {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Color.hpp:98

Blue component.

---

{#a}

### a

```cpp
std::uint8_t a {255}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Color.hpp:99

Alpha (opacity) component.

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
| `constexpr` | [`Color`](#color-1) `constexpr` | Default constructor. |
| `constexpr` | [`Color`](#color-2) `constexpr` | Construct the color from its 4 RGBA components. |
| `constexpr` | [`Color`](#color-3) `explicit` `constexpr` | Construct the color from 32-bit unsigned integer. |
| `std::uint32_t` | [`toInteger`](#tointeger-1) `const` `nodiscard` `constexpr` | Retrieve the color as a 32-bit unsigned integer. |

---

{#color-1}

### Color

`constexpr`

```cpp
constexpr constexpr Color() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Color.hpp:49

Default constructor.

Constructs an opaque black color. It is equivalent to `[sf::Color(0, 0, 0, 255)](#color)`.

---

{#color-2}

### Color

`constexpr`

```cpp
constexpr constexpr Color(std::uint8_t red, std::uint8_t green, std::uint8_t blue, std::uint8_t alpha = 255)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Color.hpp:60

Construct the color from its 4 RGBA components.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `red` | `std::uint8_t` | Red component (in the range [0, 255]) |
| `green` | `std::uint8_t` | Green component (in the range [0, 255]) |
| `blue` | `std::uint8_t` | Blue component (in the range [0, 255]) |
| `alpha` | `std::uint8_t` | Alpha (opacity) component (in the range [0, 255]) |

---

{#color-3}

### Color

`explicit` `constexpr`

```cpp
constexpr explicit constexpr Color(std::uint32_t color)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Color.hpp:68

Construct the color from 32-bit unsigned integer.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `color` | `std::uint32_t` | Number containing the RGBA components (in that order) |

---

{#tointeger-1}

### toInteger

`const` `nodiscard` `constexpr`

```cpp
[[nodiscard]] constexpr std::uint32_t toInteger() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Color.hpp:76

Retrieve the color as a 32-bit unsigned integer.

#### Returns
[Color](#color) represented as a 32-bit unsigned integer

## Public Static Attributes

| Return | Name | Description |
|--------|------|-------------|
| const [`Color`](#color) | [`Black`](#black) `static` `constexpr` | Black predefined color. |
| const [`Color`](#color) | [`White`](#white) `static` `constexpr` | White predefined color. |
| const [`Color`](#color) | [`Red`](#red) `static` `constexpr` | Red predefined color. |
| const [`Color`](#color) | [`Green`](#green) `static` `constexpr` | Green predefined color. |
| const [`Color`](#color) | [`Blue`](#blue) `static` `constexpr` | Blue predefined color. |
| const [`Color`](#color) | [`Yellow`](#yellow) `static` `constexpr` | Yellow predefined color. |
| const [`Color`](#color) | [`Magenta`](#magenta) `static` `constexpr` | Magenta predefined color. |
| const [`Color`](#color) | [`Cyan`](#cyan) `static` `constexpr` | Cyan predefined color. |
| const [`Color`](#color) | [`Transparent`](#transparent) `static` `constexpr` | Transparent (black) predefined color. |

---

{#black}

### Black

`static` `constexpr`

```cpp
const Color Black
```

Type: const [`Color`](#color)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Color.hpp:82

Black predefined color.

---

{#white}

### White

`static` `constexpr`

```cpp
const Color White
```

Type: const [`Color`](#color)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Color.hpp:83

White predefined color.

---

{#red}

### Red

`static` `constexpr`

```cpp
const Color Red
```

Type: const [`Color`](#color)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Color.hpp:84

Red predefined color.

---

{#green}

### Green

`static` `constexpr`

```cpp
const Color Green
```

Type: const [`Color`](#color)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Color.hpp:85

Green predefined color.

---

{#blue}

### Blue

`static` `constexpr`

```cpp
const Color Blue
```

Type: const [`Color`](#color)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Color.hpp:86

Blue predefined color.

---

{#yellow}

### Yellow

`static` `constexpr`

```cpp
const Color Yellow
```

Type: const [`Color`](#color)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Color.hpp:87

Yellow predefined color.

---

{#magenta}

### Magenta

`static` `constexpr`

```cpp
const Color Magenta
```

Type: const [`Color`](#color)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Color.hpp:88

Magenta predefined color.

---

{#cyan}

### Cyan

`static` `constexpr`

```cpp
const Color Cyan
```

Type: const [`Color`](#color)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Color.hpp:89

Cyan predefined color.

---

{#transparent}

### Transparent

`static` `constexpr`

```cpp
const Color Transparent
```

Type: const [`Color`](#color)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Color.hpp:90

Transparent (black) predefined color.

