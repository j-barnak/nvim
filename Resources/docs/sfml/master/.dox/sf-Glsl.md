{#glsl}

# Glsl

Namespace with GLSL types.

The `[sf::Glsl](#glsl)` namespace contains types that match their equivalents in GLSL, the OpenGL shading language. These types are exclusively used by the `[sf::Shader](sf-Shader.md#shader-1)` class.

Types that already exist in SFML, such as `[sf::Vector2](sf-Vector2.md#vector2)<T>` and `[sf::Vector3](sf-Vector3.md#vector3)<T>`, are reused as type aliases, so you can use the types in this namespace as well as the original ones. Others are newly defined, such as `[Glsl::Vec4](#vec4)` or `[Glsl::Mat3](#mat3)`. Their actual type is an implementation detail and should not be used.

All vector types support a default constructor that initializes every component to zero, in addition to a constructor with one parameter for each component. The components are stored in member variables called x, y, z, and w.

All matrix types support a constructor with a `float*` parameter that points to a float array of the appropriate size (that is, 9 in a 3x3 matrix, 16 in a 4x4 matrix). Furthermore, they can be converted from `[sf::Transform](sf-Transform.md#transform-1)` objects.

**See also**: `[sf::Shader](sf-Shader.md#shader-1)`

## Typedefs

| Return | Name | Description |
|--------|------|-------------|
| [`Vector2`](sf-Vector2.md#vector2)< float > | [`Vec2`](#vec2)  | 2D float vector (`vec2` in GLSL) |
| [`Vector2`](sf-Vector2.md#vector2)< int > | [`Ivec2`](#ivec2)  | 2D int vector (`ivec2` in GLSL) |
| [`Vector2`](sf-Vector2.md#vector2)< bool > | [`Bvec2`](#bvec2)  | 2D bool vector (`bvec2` in GLSL) |
| [`Vector3`](sf-Vector3.md#vector3)< float > | [`Vec3`](#vec3)  | 3D float vector (`vec3` in GLSL) |
| [`Vector3`](sf-Vector3.md#vector3)< int > | [`Ivec3`](#ivec3)  | 3D int vector (`ivec3` in GLSL) |
| [`Vector3`](sf-Vector3.md#vector3)< bool > | [`Bvec3`](#bvec3)  | 3D bool vector (`bvec3` in GLSL) |
| [`priv::Vector4`](sf-priv-Vector4.md#vector4)< float > | [`Vec4`](#vec4)  |  |
| [`priv::Vector4`](sf-priv-Vector4.md#vector4)< int > | [`Ivec4`](#ivec4)  |  |
| [`priv::Vector4`](sf-priv-Vector4.md#vector4)< bool > | [`Bvec4`](#bvec4)  |  |
| [`priv::Matrix`](sf-priv-Matrix.md#matrix)< 3, 3 > | [`Mat3`](#mat3)  |  |
| [`priv::Matrix`](sf-priv-Matrix.md#matrix)< 4, 4 > | [`Mat4`](#mat4)  |  |

---

{#vec2}

### Vec2

```cpp
using Vec2 = Vector2< float >
```

Type: [`Vector2`](sf-Vector2.md#vector2)< float >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glsl.hpp:61

2D float vector (`vec2` in GLSL)

---

{#ivec2}

### Ivec2

```cpp
using Ivec2 = Vector2< int >
```

Type: [`Vector2`](sf-Vector2.md#vector2)< int >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glsl.hpp:67

2D int vector (`ivec2` in GLSL)

---

{#bvec2}

### Bvec2

```cpp
using Bvec2 = Vector2< bool >
```

Type: [`Vector2`](sf-Vector2.md#vector2)< bool >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glsl.hpp:73

2D bool vector (`bvec2` in GLSL)

---

{#vec3}

### Vec3

```cpp
using Vec3 = Vector3< float >
```

Type: [`Vector3`](sf-Vector3.md#vector3)< float >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glsl.hpp:79

3D float vector (`vec3` in GLSL)

---

{#ivec3}

### Ivec3

```cpp
using Ivec3 = Vector3< int >
```

Type: [`Vector3`](sf-Vector3.md#vector3)< int >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glsl.hpp:85

3D int vector (`ivec3` in GLSL)

---

{#bvec3}

### Bvec3

```cpp
using Bvec3 = Vector3< bool >
```

Type: [`Vector3`](sf-Vector3.md#vector3)< bool >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glsl.hpp:91

3D bool vector (`bvec3` in GLSL)

---

{#vec4}

### Vec4

```cpp
using Vec4 = priv::Vector4< float >
```

Type: [`priv::Vector4`](sf-priv-Vector4.md#vector4)< float >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glsl.hpp:182

---

{#ivec4}

### Ivec4

```cpp
using Ivec4 = priv::Vector4< int >
```

Type: [`priv::Vector4`](sf-priv-Vector4.md#vector4)< int >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glsl.hpp:183

---

{#bvec4}

### Bvec4

```cpp
using Bvec4 = priv::Vector4< bool >
```

Type: [`priv::Vector4`](sf-priv-Vector4.md#vector4)< bool >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glsl.hpp:184

---

{#mat3}

### Mat3

```cpp
using Mat3 = priv::Matrix< 3, 3 >
```

Type: [`priv::Matrix`](sf-priv-Matrix.md#matrix)< 3, 3 >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glsl.hpp:185

---

{#mat4}

### Mat4

```cpp
using Mat4 = priv::Matrix< 4, 4 >
```

Type: [`priv::Matrix`](sf-priv-Matrix.md#matrix)< 4, 4 >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glsl.hpp:186

