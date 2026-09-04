{#vector4}

# Vector4

```cpp
template<typename T>
struct Vector4
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glsl.inl:104

4D vector type, used to set uniforms in GLSL

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `T` | [`x`](#x-2)  | 1st component (X) of the 4D vector |
| `T` | [`y`](#y-2)  | 2nd component (Y) of the 4D vector |
| `T` | [`z`](#z-1)  | 3rd component (Z) of the 4D vector |
| `T` | [`w`](#w)  | 4th component (W) of the 4D vector |

---

{#x-2}

### x

```cpp
T x {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glsl.inl:153

1st component (X) of the 4D vector

---

{#y-2}

### y

```cpp
T y {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glsl.inl:154

2nd component (Y) of the 4D vector

---

{#z-1}

### z

```cpp
T z {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glsl.inl:155

3rd component (Z) of the 4D vector

---

{#w}

### w

```cpp
T w {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glsl.inl:156

4th component (W) of the 4D vector

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
| `constexpr` | [`Vector4`](#vector4-1) `constexpr` | Default constructor, creates a zero vector. |
| `constexpr` | [`Vector4`](#vector4-2) `inline` `constexpr` | Construct from 4 vector components. |
| `constexpr` | [`operator Vector4< U >`](#operatorvector4u) `const` `inline` `explicit` `constexpr` | Converts the vector to another type of vector. |
| `constexpr` | [`Vector4`](#vector4-3) `constexpr` | Construct vector implicitly from color. |
| `constexpr` | [`Vector4`](#vector4-4) `constexpr` |  |
| `constexpr` | [`Vector4`](#vector4-5) `constexpr` |  |

---

{#vector4-1}

### Vector4

`constexpr`

```cpp
constexpr constexpr Vector4() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glsl.inl:110

Default constructor, creates a zero vector.

---

{#vector4-2}

### Vector4

`inline` `constexpr`

```cpp
constexpr inline constexpr Vector4(T x, T y, T z, T w)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glsl.inl:125

Construct from 4 vector components.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `x` | `T` | Component of the 4D vector |
| `y` | `T` | Component of the 4D vector |
| `z` | `T` | Component of the 4D vector |
| `w` | `T` | Component of the 4D vector |

---

{#operatorvector4u}

### operator Vector4< U >

`const` `inline` `explicit` `constexpr`

```cpp
template<typename U> constexpr inline explicit constexpr operator Vector4< U >() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glsl.inl:137

Converts the vector to another type of vector.

---

{#vector4-3}

### Vector4

`constexpr`

```cpp
constexpr constexpr Vector4(Color color)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glsl.inl:151

Construct vector implicitly from color.

Vector is normalized to [0, 1] for floats, and left as-is for ints. Not defined for other template arguments.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `color` | [`Color`](sf-Color.md#color) | [Color](sf-Color.md#color) instance |

---

{#vector4-4}

### Vector4

`constexpr`

```cpp
constexpr constexpr Vector4(Color color)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glsl.inl:162

---

{#vector4-5}

### Vector4

`constexpr`

```cpp
constexpr constexpr Vector4(Color color)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glsl.inl:173

