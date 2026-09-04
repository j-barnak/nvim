{#matrix}

# Matrix

```cpp
template<std::size_t Columns, std::size_t Rows>
struct Matrix
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glsl.inl:67

[Matrix](#matrix) type, used to set uniforms in GLSL.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::array< float, Columns *Rows >` | [`array`](#array)  | Array holding matrix data. |

---

{#array}

### array

```cpp
std::array< float, Columns *Rows > array {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glsl.inl:96

Array holding matrix data.

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`Matrix`](#matrix-1) `inline` `explicit` | Construct from raw data. |
|  | [`Matrix`](#matrix-2) `inline` | Construct implicitly from SFML transform. |

---

{#matrix-1}

### Matrix

`inline` `explicit`

```cpp
inline explicit Matrix(const float * pointer)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glsl.inl:77

Construct from raw data.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `pointer` | `const float *` | Points to the beginning of an array that has the size of the matrix. The elements are copied to the instance. |

---

{#matrix-2}

### Matrix

`inline`

```cpp
inline Matrix(const Transform & transform)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glsl.inl:91

Construct implicitly from SFML transform.

This constructor is only supported for 3x3 and 4x4 matrices.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `transform` | const [`Transform`](sf-Transform.md#transform-1) & | Object containing a transform. |

