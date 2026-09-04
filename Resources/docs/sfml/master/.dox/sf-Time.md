{#time}

# Time

```cpp
#include <Time.hpp>
```

```cpp
class Time
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Time.hpp:41

Represents a time value.

`[sf::Time](#time)` encapsulates a time value in a flexible way. It allows to define a time value either as a number of seconds, milliseconds or microseconds. It also works the other way round: you can read a time value as either a number of seconds, milliseconds or microseconds. It even interoperates with the `<chrono>` header. You can construct an `[sf::Time](#time)` from a `chrono::duration` and read any `[sf::Time](#time)` as a chrono::duration.

By using such a flexible interface, the API doesn't impose any fixed type or resolution for time values, and let the user choose its own favorite representation.

[Time](#time) values support the usual mathematical operations: you can add or subtract two times, multiply or divide a time by a number, compare two times, etc.

Since they represent a time span and not an absolute time value, times can also be negative.

Usage example: 
```cpp
sf::Time t1 = sf::seconds(0.1f);
std::int32_t milli = t1.asMilliseconds(); // 100

sf::Time t2 = sf::milliseconds(30);
std::int64_t micro = t2.asMicroseconds(); // 30'000

sf::Time t3 = sf::microseconds(-800'000);
float sec = t3.asSeconds(); // -0.8

sf::Time t4 = std::chrono::milliseconds(250);
std::chrono::microseconds micro2 = t4.toDuration(); // 250'000us
```

```cpp
void update(sf::Time elapsed)
{
   position += speed * elapsed.asSeconds();
}

update(sf::milliseconds(100));
```

**See also**: `[sf::Clock](sf-Clock.md#clock)`

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
| `constexpr` | [`Time`](#time-1) `constexpr` | Default constructor. |
| `constexpr` | [`Time`](#time-2) `constexpr` | Construct from `std::chrono::duration` |
| `float` | [`asSeconds`](#asseconds) `const` `nodiscard` `constexpr` | Return the time value as a number of seconds. |
| `std::int32_t` | [`asMilliseconds`](#asmilliseconds) `const` `nodiscard` `constexpr` | Return the time value as a number of milliseconds. |
| `std::int64_t` | [`asMicroseconds`](#asmicroseconds) `const` `nodiscard` `constexpr` | Return the time value as a number of microseconds. |
| `std::chrono::microseconds` | [`toDuration`](#toduration) `const` `nodiscard` `constexpr` | Return the time value as a `std::chrono::duration` |
| `constexpr` | [`operator std::chrono::duration< Rep, Period >`](#operatorstd-chrono-durationrepperiod) `const` `constexpr` | Implicit conversion to `std::chrono::duration` |

---

{#time-1}

### Time

`constexpr`

```cpp
constexpr constexpr Time() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Time.hpp:50

Default constructor.

Sets the time value to zero.

---

{#time-2}

### Time

`constexpr`

```cpp
template<typename Rep, typename Period> constexpr constexpr Time(const std::chrono::duration< Rep, Period > & duration)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Time.hpp:57

Construct from `std::chrono::duration`

---

{#asseconds}

### asSeconds

`const` `nodiscard` `constexpr`

```cpp
[[nodiscard]] constexpr float asSeconds() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Time.hpp:67

Return the time value as a number of seconds.

#### Returns
[Time](#time) in seconds

**See also**: `[asMilliseconds](#asmilliseconds)`, `[asMicroseconds](#asmicroseconds)`

---

{#asmilliseconds}

### asMilliseconds

`const` `nodiscard` `constexpr`

```cpp
[[nodiscard]] constexpr std::int32_t asMilliseconds() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Time.hpp:77

Return the time value as a number of milliseconds.

#### Returns
[Time](#time) in milliseconds

**See also**: `[asSeconds](#asseconds)`, `[asMicroseconds](#asmicroseconds)`

---

{#asmicroseconds}

### asMicroseconds

`const` `nodiscard` `constexpr`

```cpp
[[nodiscard]] constexpr std::int64_t asMicroseconds() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Time.hpp:87

Return the time value as a number of microseconds.

#### Returns
[Time](#time) in microseconds

**See also**: `[asSeconds](#asseconds)`, `[asMilliseconds](#asmilliseconds)`

---

{#toduration}

### toDuration

`const` `nodiscard` `constexpr`

```cpp
[[nodiscard]] constexpr std::chrono::microseconds toDuration() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Time.hpp:95

Return the time value as a `std::chrono::duration`

#### Returns
[Time](#time) in microseconds

---

{#operatorstd-chrono-durationrepperiod}

### operator std::chrono::duration< Rep, Period >

`const` `constexpr`

```cpp
template<typename Rep, typename Period> constexpr constexpr operator std::chrono::duration< Rep, Period >() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Time.hpp:104

Implicit conversion to `std::chrono::duration`

#### Returns
Duration in microseconds

## Public Static Attributes

| Return | Name | Description |
|--------|------|-------------|
| const [`Time`](#time) | [`Zero`](#zero-1) `static` `constexpr` | Predefined "zero" time value. |

---

{#zero-1}

### Zero

`static` `constexpr`

```cpp
const Time Zero
```

Type: const [`Time`](#time)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Time.hpp:110

Predefined "zero" time value.

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::chrono::microseconds` | [`m_microseconds`](#m_microseconds)  | [Time](#time) value stored as microseconds. |

---

{#m_microseconds}

### m_microseconds

```cpp
std::chrono::microseconds m_microseconds {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Time.hpp:116

[Time](#time) value stored as microseconds.

