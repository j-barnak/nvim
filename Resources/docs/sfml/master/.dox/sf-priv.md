{#priv}

# priv

## Classes

| Name | Description |
|------|-------------|
| [`Caller`](sf-priv-Caller.md#caller) |  |
| [`Caller< Handler & >`](sf-priv-Caller-Handler.md#callerhandler) |  |
| [`Caller< Return(*)(Argument)>`](sf-priv-Caller-Return-Argument.md#callerreturnargument) |  |
| [`DelayOverloadResolution`](sf-priv-DelayOverloadResolution.md#delayoverloadresolution) |  |
| [`Matrix`](sf-priv-Matrix.md#matrix) | [Matrix](sf-priv-Matrix.md#matrix) type, used to set uniforms in GLSL. |
| [`OverloadSet`](sf-priv-OverloadSet.md#overloadset-1) |  |
| [`Vector4`](sf-priv-Vector4.md#vector4) | 4D vector type, used to set uniforms in GLSL |

## Typedefs

| Return | Name | Description |
|--------|------|-------------|
| `std::conditional_t< std::chrono::high_resolution_clock::is_steady, std::chrono::high_resolution_clock, std::chrono::steady_clock >` | [`ClockImpl`](#clockimpl)  | Chooses a monotonic clock of highest resolution. |

---

{#clockimpl}

### ClockImpl

```cpp
using ClockImpl = std::conditional_t< std::chrono::high_resolution_clock::is_steady, std::chrono::high_resolution_clock, std::chrono::steady_clock >
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Clock.hpp:74

Chooses a monotonic clock of highest resolution.

The `high_resolution_clock` is usually an alias for other clocks: `steady_clock` or `system_clock`, whichever has a higher precision.

`[sf::Clock](sf-Clock.md#clock)`, however, is aimed towards monotonic time measurements and so `system_clock` could never be a choice as its subject to discontinuous jumps in the system time (e.g., if the system administrator manually changes the clock), and by the incremental adjustments performed by `adjtime` and Network [Time](sf-Time.md#time) Protocol. On the other hand, monotonic clocks are unaffected by this behavior.

Note: Linux implementation of a monotonic clock that takes sleep time into account is represented by `CLOCK_BOOTTIME`. Android devices can define the macro: `SFML_ANDROID_USE_SUSPEND_AWARE_CLOCK` to use a separate implementation of that clock, instead.

For more information on Linux clocks visit: [https://linux.die.net/man/2/clock_gettime](https://linux.die.net/man/2/clock_gettime)

## Functions

| Return | Name | Description |
|--------|------|-------------|
| std::unique_ptr< [`SoundFileReader`](sf-SoundFileReader.md#soundfilereader) > | [`createReader`](#createreader)  |  |
| std::unique_ptr< [`SoundFileWriter`](sf-SoundFileWriter.md#soundfilewriter) > | [`createWriter`](#createwriter)  |  |
| [`SFML_GRAPHICS_API`](api.md#sfml_graphics_api) void | [`copyMatrix`](#copymatrix)  | Helper functions to copy `[sf::Transform](sf-Transform.md#transform-1)` to `[sf::Glsl::Mat3](sf-Glsl.md#mat3)/4` |
| [`SFML_GRAPHICS_API`](api.md#sfml_graphics_api) void | [`copyMatrix`](#copymatrix-1)  |  |
| [`SFML_GRAPHICS_API`](api.md#sfml_graphics_api) void | [`copyMatrix`](#copymatrix-2)  | Copy array-based matrix with given number of elements. |
| `float` | [`positiveRemainder`](#positiveremainder) `constexpr` |  |
| `Out` | [`copyBits`](#copybits)  |  |
|  | [`OverloadSet`](#overloadset) `-> OverloadSet< Ts... >` |  |

---

{#createreader}

### createReader

```cpp
template<typename T> std::unique_ptr< SoundFileReader > createReader()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundFileFactory.inl:37

---

{#createwriter}

### createWriter

```cpp
template<typename T> std::unique_ptr< SoundFileWriter > createWriter()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundFileFactory.inl:42

---

{#copymatrix}

### copyMatrix

```cpp
SFML_GRAPHICS_API void copyMatrix(const Transform & source, Matrix< 3, 3 > & dest)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glsl.inl:49

Helper functions to copy `[sf::Transform](sf-Transform.md#transform-1)` to `[sf::Glsl::Mat3](sf-Glsl.md#mat3)/4`

---

{#copymatrix-1}

### copyMatrix

```cpp
SFML_GRAPHICS_API void copyMatrix(const Transform & source, Matrix< 4, 4 > & dest)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glsl.inl:50

---

{#copymatrix-2}

### copyMatrix

```cpp
SFML_GRAPHICS_API void copyMatrix(const float * source, std::size_t elements, float * dest)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glsl.inl:59

Copy array-based matrix with given number of elements.

Indirection to `std::copy()` to avoid inclusion of <algorithm> and MSVC's annoying 4996 warning in header

---

{#positiveremainder}

### positiveRemainder

`constexpr`

```cpp
constexpr float positiveRemainder(float a, float b)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Angle.inl:40

---

{#copybits}

### copyBits

```cpp
template<typename In, typename Out> Out copyBits(In begin, In end, Out output)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Utf.inl:52

---

{#overloadset}

### OverloadSet

`-> OverloadSet< Ts... >`

```cpp
template<typename... Ts> OverloadSet(Ts...) -> OverloadSet< Ts... >
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.inl:48

## Variables

| Return | Name | Description |
|--------|------|-------------|
| `float` | [`pi`](#pi) `constexpr` |  |
| `float` | [`tau`](#tau) `constexpr` |  |

---

{#pi}

### pi

`constexpr`

```cpp
float pi = 3.141592654f
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Angle.inl:37

---

{#tau}

### tau

`constexpr`

```cpp
float tau = pi * 2.f
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Angle.inl:38

