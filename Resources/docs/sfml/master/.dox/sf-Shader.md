{#shader-1}

# Shader

```cpp
#include <Shader.hpp>
```

```cpp
class Shader
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:53

> **Inherits:** [`GlResource`](sf-GlResource.md#glresource)

[Shader](#shader-1) class (vertex, geometry and fragment)

Shaders are programs written using a specific language, executed directly by the graphics card and allowing to apply real-time operations to the rendered entities.

There are three kinds of shaders: 

* Vertex shaders, that process vertices 
* Geometry shaders, that process primitives 
* Fragment (pixel) shaders, that process pixels

A `[sf::Shader](#shader-1)` can be composed of either a vertex shader alone, a geometry shader alone, a fragment shader alone, or any combination of them. (see the variants of the load functions).

Shaders are written in GLSL, which is a C-like language dedicated to OpenGL shaders. You'll probably need to learn its basics before writing your own shaders for SFML.

Like any C/C++ program, a GLSL shader has its own variables called *uniforms* that you can set from your C++ application. `[sf::Shader](#shader-1)` handles different types of uniforms: 

* scalars: `float`, `int`, `bool`
* vectors (2, 3 or 4 components) 
* matrices (3x3 or 4x4) 
* samplers (textures)

Some SFML-specific types can be converted: 

* `[sf::Color](sf-Color.md#color)` as a 4D vector (`vec4`) 
* `[sf::Transform](sf-Transform.md#transform-1)` as matrices (`mat3` or `mat4`)

Every uniform variable in a shader can be set through one of the `[setUniform()](#setuniform)` or `[setUniformArray()](#setuniformarray)` overloads. For example, if you have a shader with the following uniforms: 
```cpp
uniform float offset;
uniform vec3 point;
uniform vec4 color;
uniform mat4 matrix;
uniform sampler2D overlay;
uniform sampler2D current;
```
 You can set their values from C++ code as follows, using the types defined in the `[sf::Glsl](sf-Glsl.md#glsl)` namespace: 
```cpp
shader.setUniform("offset", 2.f);
shader.setUniform("point", sf::Vector3f(0.5f, 0.8f, 0.3f));
shader.setUniform("color", sf::Glsl::Vec4(color));          // color is a sf::Color
shader.setUniform("matrix", sf::Glsl::Mat4(transform));     // transform is a sf::Transform
shader.setUniform("overlay", texture);                      // texture is a sf::Texture
shader.setUniform("current", sf::Shader::CurrentTexture);
```

The special `[Shader::CurrentTexture](#currenttexture)` argument maps the given `sampler2D` uniform to the current texture of the object being drawn (which cannot be known in advance).

To apply a shader to a drawable, you must pass it as an additional parameter to the `[RenderWindow::draw](sf-RenderTarget.md#draw-1)` function: 
```cpp
window.draw(sprite, &shader);
```

... which is in fact just a shortcut for this: 
```cpp
sf::RenderStates states;
states.shader = &shader;
window.draw(sprite, states);
```

In the code above we pass a pointer to the shader, because it may be null (which means "no shader").

Shaders can be used on any drawable, but some combinations are not interesting. For example, using a vertex shader on a `[sf::Sprite](sf-Sprite.md#sprite)` is limited because there are only 4 vertices, the sprite would have to be subdivided in order to apply wave effects. Another bad example is a fragment shader with `[sf::Text](sf-Text.md#text-1)`: the texture of the text is not the actual text that you see on screen, it is a big texture containing all the characters of the font in an arbitrary order; thus, texture lookups on pixels other than the current one may not give you the expected result.

Shaders can also be used to apply global post-effects to the current contents of the target. This can be done in two different ways: 

* draw everything to a `[sf::RenderTexture](sf-RenderTexture.md#rendertexture)`, then draw it to the main target using the shader 
* draw everything directly to the main target, then use `[sf::Texture::update](sf-Texture.md#update-3)([Window](sf-Window.md#window)&)` to copy its contents to a texture and draw it to the main target using the shader

The first technique is more optimized because it doesn't involve retrieving the target's pixels to system memory, but the second one doesn't impact the rendering process and can be easily inserted anywhere without impacting all the code.

Like `[sf::Texture](sf-Texture.md#texture-2)` that can be used as a raw OpenGL texture, `[sf::Shader](#shader-1)` can also be used directly as a raw shader for custom OpenGL geometry. 
```cpp
sf::Shader::bind(&shader);
... render OpenGL geometry ...
sf::Shader::bind(nullptr);
```

**See also**: `[sf::Glsl](sf-Glsl.md#glsl)`

## List of all members

| Name | Kind | Owner |
|------|------|-------|
| [`Shader`](#shader-2) | `function` | Declared here |
| [`~Shader`](#shader-3) | `function` | Declared here |
| [`Shader`](#shader-4) | `function` | Declared here |
| [`operator=`](#operator-74) | `function` | Declared here |
| [`Shader`](#shader-5) | `function` | Declared here |
| [`operator=`](#operator-75) | `function` | Declared here |
| [`Shader`](#shader-6) | `function` | Declared here |
| [`Shader`](#shader-7) | `function` | Declared here |
| [`Shader`](#shader-8) | `function` | Declared here |
| [`Shader`](#shader-9) | `function` | Declared here |
| [`Shader`](#shader-10) | `function` | Declared here |
| [`Shader`](#shader-11) | `function` | Declared here |
| [`Shader`](#shader-12) | `function` | Declared here |
| [`Shader`](#shader-13) | `function` | Declared here |
| [`Shader`](#shader-14) | `function` | Declared here |
| [`loadFromFile`](#loadfromfile-2) | `function` | Declared here |
| [`loadFromFile`](#loadfromfile-3) | `function` | Declared here |
| [`loadFromFile`](#loadfromfile-4) | `function` | Declared here |
| [`loadFromMemory`](#loadfrommemory-2) | `function` | Declared here |
| [`loadFromMemory`](#loadfrommemory-3) | `function` | Declared here |
| [`loadFromMemory`](#loadfrommemory-4) | `function` | Declared here |
| [`loadFromStream`](#loadfromstream-2) | `function` | Declared here |
| [`loadFromStream`](#loadfromstream-3) | `function` | Declared here |
| [`loadFromStream`](#loadfromstream-4) | `function` | Declared here |
| [`setUniform`](#setuniform) | `function` | Declared here |
| [`setUniform`](#setuniform-1) | `function` | Declared here |
| [`setUniform`](#setuniform-2) | `function` | Declared here |
| [`setUniform`](#setuniform-3) | `function` | Declared here |
| [`setUniform`](#setuniform-4) | `function` | Declared here |
| [`setUniform`](#setuniform-5) | `function` | Declared here |
| [`setUniform`](#setuniform-6) | `function` | Declared here |
| [`setUniform`](#setuniform-7) | `function` | Declared here |
| [`setUniform`](#setuniform-8) | `function` | Declared here |
| [`setUniform`](#setuniform-9) | `function` | Declared here |
| [`setUniform`](#setuniform-10) | `function` | Declared here |
| [`setUniform`](#setuniform-11) | `function` | Declared here |
| [`setUniform`](#setuniform-12) | `function` | Declared here |
| [`setUniform`](#setuniform-13) | `function` | Declared here |
| [`setUniform`](#setuniform-14) | `function` | Declared here |
| [`setUniform`](#setuniform-15) | `function` | Declared here |
| [`setUniform`](#setuniform-16) | `function` | Declared here |
| [`setUniformArray`](#setuniformarray) | `function` | Declared here |
| [`setUniformArray`](#setuniformarray-1) | `function` | Declared here |
| [`setUniformArray`](#setuniformarray-2) | `function` | Declared here |
| [`setUniformArray`](#setuniformarray-3) | `function` | Declared here |
| [`setUniformArray`](#setuniformarray-4) | `function` | Declared here |
| [`setUniformArray`](#setuniformarray-5) | `function` | Declared here |
| [`getNativeHandle`](#getnativehandle-2) | `function` | Declared here |
| [`CurrentTexture`](#currenttexture) | `variable` | Declared here |
| [`bind`](#bind-1) | `function` | Declared here |
| [`isAvailable`](#isavailable-3) | `function` | Declared here |
| [`isGeometryAvailable`](#isgeometryavailable) | `function` | Declared here |
| [`Type`](Type.md#type-7) | `enum` | Declared here |
| [`m_shaderProgram`](#m_shaderprogram) | `variable` | Declared here |
| [`m_currentTexture`](#m_currenttexture) | `variable` | Declared here |
| [`m_textures`](#m_textures) | `variable` | Declared here |
| [`m_uniforms`](#m_uniforms) | `variable` | Declared here |
| [`compile`](#compile) | `function` | Declared here |
| [`bindTextures`](#bindtextures) | `function` | Declared here |
| [`getUniformLocation`](#getuniformlocation) | `function` | Declared here |
| [`GlResource`](sf-GlResource.md#glresource-1) | `function` | Inherited from [`GlResource`](sf-GlResource.md#glresource) |
| [`m_sharedContext`](sf-GlResource.md#m_sharedcontext) | `variable` | Inherited from [`GlResource`](sf-GlResource.md#glresource) |

## Inherited from [`GlResource`](sf-GlResource.md#glresource)

| Kind | Name | Description |
|------|------|-------------|
| `function` | [`GlResource`](sf-GlResource.md#glresource-1)  | Default constructor. |
| `variable` | [`m_sharedContext`](sf-GlResource.md#m_sharedcontext)  | Shared context used to link all contexts together for resource sharing. |

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`Shader`](#shader-2)  | Default constructor. |
|  | [`~Shader`](#shader-3)  | Destructor. |
|  | [`Shader`](#shader-4)  | Deleted copy constructor. |
| [`Shader`](#shader-1) & | [`operator=`](#operator-74)  | Deleted copy assignment. |
|  | [`Shader`](#shader-5) `noexcept` | Move constructor. |
| [`Shader`](#shader-1) & | [`operator=`](#operator-75) `noexcept` | Move assignment. |
|  | [`Shader`](#shader-6)  | Construct from a shader file. |
|  | [`Shader`](#shader-7)  | Construct from vertex and fragment shader files. |
|  | [`Shader`](#shader-8)  | Construct from vertex, geometry and fragment shader files. |
|  | [`Shader`](#shader-9)  | Construct from shader in memory. |
|  | [`Shader`](#shader-10)  | Construct from vertex and fragment shaders in memory. |
|  | [`Shader`](#shader-11)  | Construct from vertex, geometry and fragment shaders in memory. |
|  | [`Shader`](#shader-12)  | Construct from a shader stream. |
|  | [`Shader`](#shader-13)  | Construct from vertex and fragment shader streams. |
|  | [`Shader`](#shader-14)  | Construct from vertex, geometry and fragment shader streams. |
| `bool` | [`loadFromFile`](#loadfromfile-2) `nodiscard` | Load the vertex, geometry or fragment shader from a file. |
| `bool` | [`loadFromFile`](#loadfromfile-3) `nodiscard` | Load both the vertex and fragment shaders from files. |
| `bool` | [`loadFromFile`](#loadfromfile-4) `nodiscard` | Load the vertex, geometry and fragment shaders from files. |
| `bool` | [`loadFromMemory`](#loadfrommemory-2) `nodiscard` | Load the vertex, geometry or fragment shader from a source code in memory. |
| `bool` | [`loadFromMemory`](#loadfrommemory-3) `nodiscard` | Load both the vertex and fragment shaders from source codes in memory. |
| `bool` | [`loadFromMemory`](#loadfrommemory-4) `nodiscard` | Load the vertex, geometry and fragment shaders from source codes in memory. |
| `bool` | [`loadFromStream`](#loadfromstream-2) `nodiscard` | Load the vertex, geometry or fragment shader from a custom stream. |
| `bool` | [`loadFromStream`](#loadfromstream-3) `nodiscard` | Load both the vertex and fragment shaders from custom streams. |
| `bool` | [`loadFromStream`](#loadfromstream-4) `nodiscard` | Load the vertex, geometry and fragment shaders from custom streams. |
| `void` | [`setUniform`](#setuniform)  | Specify value for `float` uniform. |
| `void` | [`setUniform`](#setuniform-1)  | Specify value for `vec2` uniform. |
| `void` | [`setUniform`](#setuniform-2)  | Specify value for `vec3` uniform. |
| `void` | [`setUniform`](#setuniform-3)  | Specify value for `vec4` uniform. |
| `void` | [`setUniform`](#setuniform-4)  | Specify value for `int` uniform. |
| `void` | [`setUniform`](#setuniform-5)  | Specify value for `ivec2` uniform. |
| `void` | [`setUniform`](#setuniform-6)  | Specify value for `ivec3` uniform. |
| `void` | [`setUniform`](#setuniform-7)  | Specify value for `ivec4` uniform. |
| `void` | [`setUniform`](#setuniform-8)  | Specify value for `bool` uniform. |
| `void` | [`setUniform`](#setuniform-9)  | Specify value for `bvec2` uniform. |
| `void` | [`setUniform`](#setuniform-10)  | Specify value for `bvec3` uniform. |
| `void` | [`setUniform`](#setuniform-11)  | Specify value for `bvec4` uniform. |
| `void` | [`setUniform`](#setuniform-12)  | Specify value for `mat3` matrix. |
| `void` | [`setUniform`](#setuniform-13)  | Specify value for `mat4` matrix. |
| `void` | [`setUniform`](#setuniform-14)  | Specify a texture as `sampler2D` uniform. |
| `void` | [`setUniform`](#setuniform-15)  | Disallow setting from a temporary texture. |
| `void` | [`setUniform`](#setuniform-16)  | Specify current texture as `sampler2D` uniform. |
| `void` | [`setUniformArray`](#setuniformarray)  | Specify values for `float`[] array uniform. |
| `void` | [`setUniformArray`](#setuniformarray-1)  | Specify values for `vec2`[] array uniform. |
| `void` | [`setUniformArray`](#setuniformarray-2)  | Specify values for `vec3`[] array uniform. |
| `void` | [`setUniformArray`](#setuniformarray-3)  | Specify values for `vec4`[] array uniform. |
| `void` | [`setUniformArray`](#setuniformarray-4)  | Specify values for `mat3`[] array uniform. |
| `void` | [`setUniformArray`](#setuniformarray-5)  | Specify values for `mat4`[] array uniform. |
| `unsigned int` | [`getNativeHandle`](#getnativehandle-2) `const` `nodiscard` | Get the underlying OpenGL handle of the shader. |

---

{#shader-2}

### Shader

```cpp
Shader() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:96

Default constructor.

This constructor creates an empty shader.

Binding an empty shader has the same effect as not binding any shader.

---

{#shader-3}

### ~Shader

```cpp
~Shader()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:102

Destructor.

---

{#shader-4}

### Shader

```cpp
Shader(const Shader &) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:108

Deleted copy constructor.

---

{#operator-74}

### operator=

```cpp
Shader & operator=(const Shader &) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:114

Deleted copy assignment.

---

{#shader-5}

### Shader

`noexcept`

```cpp
Shader(Shader && source) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:120

Move constructor.

---

{#operator-75}

### operator=

`noexcept`

```cpp
Shader & operator=(Shader && right) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:126

Move assignment.

---

{#shader-6}

### Shader

```cpp
Shader(const std::filesystem::path & filename, Type type)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:147

Construct from a shader file.

This constructor loads a single shader, vertex, geometry or fragment, identified by the second argument. The source must be a text file containing a valid shader in GLSL language. GLSL is a C-like language dedicated to OpenGL shaders; you'll probably need to read a good documentation for it before writing your own shaders.

**See also**: `[loadFromFile](#loadfromfile-2)`, `[loadFromMemory](#loadfrommemory-2)`, `[loadFromStream](#loadfromstream-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `filename` | `const std::filesystem::path &` | Path of the vertex, geometry or fragment shader file to load |
| `type` | [`Type`](Type.md#type-7) | [Type](Type.md#type-7) of shader (vertex, geometry or fragment) |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if loading was unsuccessful |

---

{#shader-7}

### Shader

```cpp
Shader(const std::filesystem::path & vertexShaderFilename, const std::filesystem::path & fragmentShaderFilename)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:168

Construct from vertex and fragment shader files.

This constructor loads both the vertex and the fragment shaders. If one of them fails to load, the shader is left empty (the valid shader is unloaded). The sources must be text files containing valid shaders in GLSL language. GLSL is a C-like language dedicated to OpenGL shaders; you'll probably need to read a good documentation for it before writing your own shaders.

**See also**: `[loadFromFile](#loadfromfile-2)`, `[loadFromMemory](#loadfrommemory-2)`, `[loadFromStream](#loadfromstream-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vertexShaderFilename` | `const std::filesystem::path &` | Path of the vertex shader file to load |
| `fragmentShaderFilename` | `const std::filesystem::path &` | Path of the fragment shader file to load |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if loading was unsuccessful |

---

{#shader-8}

### Shader

```cpp
Shader(const std::filesystem::path & vertexShaderFilename, const std::filesystem::path & geometryShaderFilename, const std::filesystem::path & fragmentShaderFilename)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:190

Construct from vertex, geometry and fragment shader files.

This constructor loads the vertex, geometry and fragment shaders. If one of them fails to load, the shader is left empty (the valid shader is unloaded). The sources must be text files containing valid shaders in GLSL language. GLSL is a C-like language dedicated to OpenGL shaders; you'll probably need to read a good documentation for it before writing your own shaders.

**See also**: `[loadFromFile](#loadfromfile-2)`, `[loadFromMemory](#loadfrommemory-2)`, `[loadFromStream](#loadfromstream-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vertexShaderFilename` | `const std::filesystem::path &` | Path of the vertex shader file to load |
| `geometryShaderFilename` | `const std::filesystem::path &` | Path of the geometry shader file to load |
| `fragmentShaderFilename` | `const std::filesystem::path &` | Path of the fragment shader file to load |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if loading was unsuccessful |

---

{#shader-9}

### Shader

```cpp
Shader(std::string_view shader, Type type)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:212

Construct from shader in memory.

This constructor loads a single shader, vertex, geometry or fragment, identified by the second argument. The source code must be a valid shader in GLSL language. GLSL is a C-like language dedicated to OpenGL shaders; you'll probably need to read a good documentation for it before writing your own shaders.

**See also**: `[loadFromFile](#loadfromfile-2)`, `[loadFromMemory](#loadfrommemory-2)`, `[loadFromStream](#loadfromstream-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `shader` | `std::string_view` | [String](sf-String.md#string) containing the source code of the shader |
| `type` | [`Type`](Type.md#type-7) | [Type](Type.md#type-7) of shader (vertex, geometry or fragment) |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if loading was unsuccessful |

---

{#shader-10}

### Shader

```cpp
Shader(std::string_view vertexShader, std::string_view fragmentShader)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:233

Construct from vertex and fragment shaders in memory.

This constructor loads both the vertex and the fragment shaders. If one of them fails to load, the shader is left empty (the valid shader is unloaded). The sources must be valid shaders in GLSL language. GLSL is a C-like language dedicated to OpenGL shaders; you'll probably need to read a good documentation for it before writing your own shaders.

**See also**: `[loadFromFile](#loadfromfile-2)`, `[loadFromMemory](#loadfrommemory-2)`, `[loadFromStream](#loadfromstream-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vertexShader` | `std::string_view` | [String](sf-String.md#string) containing the source code of the vertex shader |
| `fragmentShader` | `std::string_view` | [String](sf-String.md#string) containing the source code of the fragment shader |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if loading was unsuccessful |

---

{#shader-11}

### Shader

```cpp
Shader(std::string_view vertexShader, std::string_view geometryShader, std::string_view fragmentShader)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:255

Construct from vertex, geometry and fragment shaders in memory.

This constructor loads the vertex, geometry and fragment shaders. If one of them fails to load, the shader is left empty (the valid shader is unloaded). The sources must be valid shaders in GLSL language. GLSL is a C-like language dedicated to OpenGL shaders; you'll probably need to read a good documentation for it before writing your own shaders.

**See also**: `[loadFromFile](#loadfromfile-2)`, `[loadFromMemory](#loadfrommemory-2)`, `[loadFromStream](#loadfromstream-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vertexShader` | `std::string_view` | [String](sf-String.md#string) containing the source code of the vertex shader |
| `geometryShader` | `std::string_view` | [String](sf-String.md#string) containing the source code of the geometry shader |
| `fragmentShader` | `std::string_view` | [String](sf-String.md#string) containing the source code of the fragment shader |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if loading was unsuccessful |

---

{#shader-12}

### Shader

```cpp
Shader(InputStream & stream, Type type)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:275

Construct from a shader stream.

This constructor loads a single shader, vertex, geometry or fragment, identified by the second argument. The source code must be a valid shader in GLSL language. GLSL is a C-like language dedicated to OpenGL shaders; you'll probably need to read a good documentation for it before writing your own shaders.

**See also**: `[loadFromFile](#loadfromfile-2)`, `[loadFromMemory](#loadfrommemory-2)`, `[loadFromStream](#loadfromstream-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `stream` | [`InputStream`](sf-InputStream.md#inputstream) & | Source stream to read from |
| `type` | [`Type`](Type.md#type-7) | [Type](Type.md#type-7) of shader (vertex, geometry or fragment) |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if loading was unsuccessful |

---

{#shader-13}

### Shader

```cpp
Shader(InputStream & vertexShaderStream, InputStream & fragmentShaderStream)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:296

Construct from vertex and fragment shader streams.

This constructor loads both the vertex and the fragment shaders. If one of them fails to load, the shader is left empty (the valid shader is unloaded). The source codes must be valid shaders in GLSL language. GLSL is a C-like language dedicated to OpenGL shaders; you'll probably need to read a good documentation for it before writing your own shaders.

**See also**: `[loadFromFile](#loadfromfile-2)`, `[loadFromMemory](#loadfrommemory-2)`, `[loadFromStream](#loadfromstream-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vertexShaderStream` | [`InputStream`](sf-InputStream.md#inputstream) & | Source stream to read the vertex shader from |
| `fragmentShaderStream` | [`InputStream`](sf-InputStream.md#inputstream) & | Source stream to read the fragment shader from |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if loading was unsuccessful |

---

{#shader-14}

### Shader

```cpp
Shader(InputStream & vertexShaderStream, InputStream & geometryShaderStream, InputStream & fragmentShaderStream)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:318

Construct from vertex, geometry and fragment shader streams.

This constructor loads the vertex, geometry and fragment shaders. If one of them fails to load, the shader is left empty (the valid shader is unloaded). The source codes must be valid shaders in GLSL language. GLSL is a C-like language dedicated to OpenGL shaders; you'll probably need to read a good documentation for it before writing your own shaders.

**See also**: `[loadFromFile](#loadfromfile-2)`, `[loadFromMemory](#loadfrommemory-2)`, `[loadFromStream](#loadfromstream-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vertexShaderStream` | [`InputStream`](sf-InputStream.md#inputstream) & | Source stream to read the vertex shader from |
| `geometryShaderStream` | [`InputStream`](sf-InputStream.md#inputstream) & | Source stream to read the geometry shader from |
| `fragmentShaderStream` | [`InputStream`](sf-InputStream.md#inputstream) & | Source stream to read the fragment shader from |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if loading was unsuccessful |

---

{#loadfromfile-2}

### loadFromFile

`nodiscard`

```cpp
[[nodiscard]] bool loadFromFile(const std::filesystem::path & filename, Type type)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:339

Load the vertex, geometry or fragment shader from a file.

This function loads a single shader, vertex, geometry or fragment, identified by the second argument. The source must be a text file containing a valid shader in GLSL language. GLSL is a C-like language dedicated to OpenGL shaders; you'll probably need to read a good documentation for it before writing your own shaders.

#### Returns
`true` if loading succeeded, `false` if it failed

**See also**: `[loadFromMemory](#loadfrommemory-2)`, `[loadFromStream](#loadfromstream-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `filename` | `const std::filesystem::path &` | Path of the vertex, geometry or fragment shader file to load |
| `type` | [`Type`](Type.md#type-7) | [Type](Type.md#type-7) of shader (vertex, geometry or fragment) |

---

{#loadfromfile-3}

### loadFromFile

`nodiscard`

```cpp
[[nodiscard]] bool loadFromFile(const std::filesystem::path & vertexShaderFilename, const std::filesystem::path & fragmentShaderFilename)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:360

Load both the vertex and fragment shaders from files.

This function loads both the vertex and the fragment shaders. If one of them fails to load, the shader is left empty (the valid shader is unloaded). The sources must be text files containing valid shaders in GLSL language. GLSL is a C-like language dedicated to OpenGL shaders; you'll probably need to read a good documentation for it before writing your own shaders.

#### Returns
`true` if loading succeeded, `false` if it failed

**See also**: `[loadFromMemory](#loadfrommemory-2)`, `[loadFromStream](#loadfromstream-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vertexShaderFilename` | `const std::filesystem::path &` | Path of the vertex shader file to load |
| `fragmentShaderFilename` | `const std::filesystem::path &` | Path of the fragment shader file to load |

---

{#loadfromfile-4}

### loadFromFile

`nodiscard`

```cpp
[[nodiscard]] bool loadFromFile(const std::filesystem::path & vertexShaderFilename, const std::filesystem::path & geometryShaderFilename, const std::filesystem::path & fragmentShaderFilename)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:383

Load the vertex, geometry and fragment shaders from files.

This function loads the vertex, geometry and fragment shaders. If one of them fails to load, the shader is left empty (the valid shader is unloaded). The sources must be text files containing valid shaders in GLSL language. GLSL is a C-like language dedicated to OpenGL shaders; you'll probably need to read a good documentation for it before writing your own shaders.

#### Returns
`true` if loading succeeded, `false` if it failed

**See also**: `[loadFromMemory](#loadfrommemory-2)`, `[loadFromStream](#loadfromstream-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vertexShaderFilename` | `const std::filesystem::path &` | Path of the vertex shader file to load |
| `geometryShaderFilename` | `const std::filesystem::path &` | Path of the geometry shader file to load |
| `fragmentShaderFilename` | `const std::filesystem::path &` | Path of the fragment shader file to load |

---

{#loadfrommemory-2}

### loadFromMemory

`nodiscard`

```cpp
[[nodiscard]] bool loadFromMemory(std::string_view shader, Type type)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:405

Load the vertex, geometry or fragment shader from a source code in memory.

This function loads a single shader, vertex, geometry or fragment, identified by the second argument. The source code must be a valid shader in GLSL language. GLSL is a C-like language dedicated to OpenGL shaders; you'll probably need to read a good documentation for it before writing your own shaders.

#### Returns
`true` if loading succeeded, `false` if it failed

**See also**: `[loadFromFile](#loadfromfile-2)`, `[loadFromStream](#loadfromstream-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `shader` | `std::string_view` | [String](sf-String.md#string) containing the source code of the shader |
| `type` | [`Type`](Type.md#type-7) | [Type](Type.md#type-7) of shader (vertex, geometry or fragment) |

---

{#loadfrommemory-3}

### loadFromMemory

`nodiscard`

```cpp
[[nodiscard]] bool loadFromMemory(std::string_view vertexShader, std::string_view fragmentShader)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:426

Load both the vertex and fragment shaders from source codes in memory.

This function loads both the vertex and the fragment shaders. If one of them fails to load, the shader is left empty (the valid shader is unloaded). The sources must be valid shaders in GLSL language. GLSL is a C-like language dedicated to OpenGL shaders; you'll probably need to read a good documentation for it before writing your own shaders.

#### Returns
`true` if loading succeeded, `false` if it failed

**See also**: `[loadFromFile](#loadfromfile-2)`, `[loadFromStream](#loadfromstream-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vertexShader` | `std::string_view` | [String](sf-String.md#string) containing the source code of the vertex shader |
| `fragmentShader` | `std::string_view` | [String](sf-String.md#string) containing the source code of the fragment shader |

---

{#loadfrommemory-4}

### loadFromMemory

`nodiscard`

```cpp
[[nodiscard]] bool loadFromMemory(std::string_view vertexShader, std::string_view geometryShader, std::string_view fragmentShader)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:448

Load the vertex, geometry and fragment shaders from source codes in memory.

This function loads the vertex, geometry and fragment shaders. If one of them fails to load, the shader is left empty (the valid shader is unloaded). The sources must be valid shaders in GLSL language. GLSL is a C-like language dedicated to OpenGL shaders; you'll probably need to read a good documentation for it before writing your own shaders.

#### Returns
`true` if loading succeeded, `false` if it failed

**See also**: `[loadFromFile](#loadfromfile-2)`, `[loadFromStream](#loadfromstream-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vertexShader` | `std::string_view` | [String](sf-String.md#string) containing the source code of the vertex shader |
| `geometryShader` | `std::string_view` | [String](sf-String.md#string) containing the source code of the geometry shader |
| `fragmentShader` | `std::string_view` | [String](sf-String.md#string) containing the source code of the fragment shader |

---

{#loadfromstream-2}

### loadFromStream

`nodiscard`

```cpp
[[nodiscard]] bool loadFromStream(InputStream & stream, Type type)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:470

Load the vertex, geometry or fragment shader from a custom stream.

This function loads a single shader, vertex, geometry or fragment, identified by the second argument. The source code must be a valid shader in GLSL language. GLSL is a C-like language dedicated to OpenGL shaders; you'll probably need to read a good documentation for it before writing your own shaders.

#### Returns
`true` if loading succeeded, `false` if it failed

**See also**: `[loadFromFile](#loadfromfile-2)`, `[loadFromMemory](#loadfrommemory-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `stream` | [`InputStream`](sf-InputStream.md#inputstream) & | Source stream to read from |
| `type` | [`Type`](Type.md#type-7) | [Type](Type.md#type-7) of shader (vertex, geometry or fragment) |

---

{#loadfromstream-3}

### loadFromStream

`nodiscard`

```cpp
[[nodiscard]] bool loadFromStream(InputStream & vertexShaderStream, InputStream & fragmentShaderStream)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:491

Load both the vertex and fragment shaders from custom streams.

This function loads both the vertex and the fragment shaders. If one of them fails to load, the shader is left empty (the valid shader is unloaded). The source codes must be valid shaders in GLSL language. GLSL is a C-like language dedicated to OpenGL shaders; you'll probably need to read a good documentation for it before writing your own shaders.

#### Returns
`true` if loading succeeded, `false` if it failed

**See also**: `[loadFromFile](#loadfromfile-2)`, `[loadFromMemory](#loadfrommemory-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vertexShaderStream` | [`InputStream`](sf-InputStream.md#inputstream) & | Source stream to read the vertex shader from |
| `fragmentShaderStream` | [`InputStream`](sf-InputStream.md#inputstream) & | Source stream to read the fragment shader from |

---

{#loadfromstream-4}

### loadFromStream

`nodiscard`

```cpp
[[nodiscard]] bool loadFromStream(InputStream & vertexShaderStream, InputStream & geometryShaderStream, InputStream & fragmentShaderStream)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:513

Load the vertex, geometry and fragment shaders from custom streams.

This function loads the vertex, geometry and fragment shaders. If one of them fails to load, the shader is left empty (the valid shader is unloaded). The source codes must be valid shaders in GLSL language. GLSL is a C-like language dedicated to OpenGL shaders; you'll probably need to read a good documentation for it before writing your own shaders.

#### Returns
`true` if loading succeeded, `false` if it failed

**See also**: `[loadFromFile](#loadfromfile-2)`, `[loadFromMemory](#loadfrommemory-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vertexShaderStream` | [`InputStream`](sf-InputStream.md#inputstream) & | Source stream to read the vertex shader from |
| `geometryShaderStream` | [`InputStream`](sf-InputStream.md#inputstream) & | Source stream to read the geometry shader from |
| `fragmentShaderStream` | [`InputStream`](sf-InputStream.md#inputstream) & | Source stream to read the fragment shader from |

---

{#setuniform}

### setUniform

```cpp
void setUniform(const std::string & name, float x)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:524

Specify value for `float` uniform.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const std::string &` | Name of the uniform variable in GLSL |
| `x` | `float` | Value of the float scalar |

---

{#setuniform-1}

### setUniform

```cpp
void setUniform(const std::string & name, Glsl::Vec2 vector)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:533

Specify value for `vec2` uniform.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const std::string &` | Name of the uniform variable in GLSL |
| `vector` | [`Glsl::Vec2`](sf-Glsl.md#vec2) | Value of the vec2 vector |

---

{#setuniform-2}

### setUniform

```cpp
void setUniform(const std::string & name, const Glsl::Vec3 & vector)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:542

Specify value for `vec3` uniform.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const std::string &` | Name of the uniform variable in GLSL |
| `vector` | const [`Glsl::Vec3`](sf-Glsl.md#vec3) & | Value of the vec3 vector |

---

{#setuniform-3}

### setUniform

```cpp
void setUniform(const std::string & name, const Glsl::Vec4 & vector)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:560

Specify value for `vec4` uniform.

This overload can also be called with `[sf::Color](sf-Color.md#color)` objects that are converted to `[sf::Glsl::Vec4](sf-Glsl.md#vec4)`.

It is important to note that the components of the color are normalized before being passed to the shader. Therefore, they are converted from range [0 .. 255] to range [0 .. 1]. For example, a `[sf::Color(255, 127, 0, 255)](sf-Color.md#color)` will be transformed to a `vec4(1.0, 0.5, 0.0, 1.0)` in the shader.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const std::string &` | Name of the uniform variable in GLSL |
| `vector` | const [`Glsl::Vec4`](sf-Glsl.md#vec4) & | Value of the vec4 vector |

---

{#setuniform-4}

### setUniform

```cpp
void setUniform(const std::string & name, int x)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:569

Specify value for `int` uniform.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const std::string &` | Name of the uniform variable in GLSL |
| `x` | `int` | Value of the int scalar |

---

{#setuniform-5}

### setUniform

```cpp
void setUniform(const std::string & name, Glsl::Ivec2 vector)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:578

Specify value for `ivec2` uniform.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const std::string &` | Name of the uniform variable in GLSL |
| `vector` | [`Glsl::Ivec2`](sf-Glsl.md#ivec2) | Value of the ivec2 vector |

---

{#setuniform-6}

### setUniform

```cpp
void setUniform(const std::string & name, const Glsl::Ivec3 & vector)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:587

Specify value for `ivec3` uniform.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const std::string &` | Name of the uniform variable in GLSL |
| `vector` | const [`Glsl::Ivec3`](sf-Glsl.md#ivec3) & | Value of the ivec3 vector |

---

{#setuniform-7}

### setUniform

```cpp
void setUniform(const std::string & name, const Glsl::Ivec4 & vector)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:604

Specify value for `ivec4` uniform.

This overload can also be called with `[sf::Color](sf-Color.md#color)` objects that are converted to `[sf::Glsl::Ivec4](sf-Glsl.md#ivec4)`.

If color conversions are used, the ivec4 uniform in GLSL will hold the same values as the original `[sf::Color](sf-Color.md#color)` instance. For example, `[sf::Color(255, 127, 0, 255)](sf-Color.md#color)` is mapped to `ivec4(255, 127, 0, 255)`.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const std::string &` | Name of the uniform variable in GLSL |
| `vector` | const [`Glsl::Ivec4`](sf-Glsl.md#ivec4) & | Value of the ivec4 vector |

---

{#setuniform-8}

### setUniform

```cpp
void setUniform(const std::string & name, bool x)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:613

Specify value for `bool` uniform.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const std::string &` | Name of the uniform variable in GLSL |
| `x` | `bool` | Value of the bool scalar |

---

{#setuniform-9}

### setUniform

```cpp
void setUniform(const std::string & name, Glsl::Bvec2 vector)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:622

Specify value for `bvec2` uniform.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const std::string &` | Name of the uniform variable in GLSL |
| `vector` | [`Glsl::Bvec2`](sf-Glsl.md#bvec2) | Value of the bvec2 vector |

---

{#setuniform-10}

### setUniform

```cpp
void setUniform(const std::string & name, const Glsl::Bvec3 & vector)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:631

Specify value for `bvec3` uniform.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const std::string &` | Name of the uniform variable in GLSL |
| `vector` | const [`Glsl::Bvec3`](sf-Glsl.md#bvec3) & | Value of the bvec3 vector |

---

{#setuniform-11}

### setUniform

```cpp
void setUniform(const std::string & name, const Glsl::Bvec4 & vector)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:640

Specify value for `bvec4` uniform.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const std::string &` | Name of the uniform variable in GLSL |
| `vector` | const [`Glsl::Bvec4`](sf-Glsl.md#bvec4) & | Value of the bvec4 vector |

---

{#setuniform-12}

### setUniform

```cpp
void setUniform(const std::string & name, const Glsl::Mat3 & matrix)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:649

Specify value for `mat3` matrix.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const std::string &` | Name of the uniform variable in GLSL |
| `matrix` | const [`Glsl::Mat3`](sf-Glsl.md#mat3) & | Value of the mat3 matrix |

---

{#setuniform-13}

### setUniform

```cpp
void setUniform(const std::string & name, const Glsl::Mat4 & matrix)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:658

Specify value for `mat4` matrix.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const std::string &` | Name of the uniform variable in GLSL |
| `matrix` | const [`Glsl::Mat4`](sf-Glsl.md#mat4) & | Value of the mat4 matrix |

---

{#setuniform-14}

### setUniform

```cpp
void setUniform(const std::string & name, const Texture & texture)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:690

Specify a texture as `sampler2D` uniform.

*name* is the name of the variable to change in the shader. The corresponding parameter in the shader must be a 2D texture (`sampler2D` GLSL type).

Example: 
```cpp
uniform sampler2D the_texture; // this is the variable in the shader
```

```cpp
sf::Texture texture;
...
shader.setUniform("the_texture", texture);
```
 It is important to note that `texture` must remain alive as long as the shader uses it, no copy is made internally.

To use the texture of the object being drawn, which cannot be known in advance, you can pass the special value `[sf::Shader::CurrentTexture](#currenttexture)`: 
```cpp
shader.setUniform("the_texture", sf::Shader::CurrentTexture).
```

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const std::string &` | Name of the texture in the shader |
| `texture` | const [`Texture`](sf-Texture.md#texture-2) & | [Texture](sf-Texture.md#texture-2) to assign |

---

{#setuniform-15}

### setUniform

```cpp
void setUniform(const std::string & name, const Texture && texture) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:696

Disallow setting from a temporary texture.

---

{#setuniform-16}

### setUniform

```cpp
void setUniform(const std::string & name, CurrentTextureType)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:719

Specify current texture as `sampler2D` uniform.

This overload maps a shader texture variable to the texture of the object being drawn, which cannot be known in advance. The second argument must be `[sf::Shader::CurrentTexture](#currenttexture)`. The corresponding parameter in the shader must be a 2D texture (`sampler2D` GLSL type).

Example: 
```cpp
uniform sampler2D current; // this is the variable in the shader
```

```cpp
shader.setUniform("current", sf::Shader::CurrentTexture);
```

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const std::string &` | Name of the texture in the shader |

---

{#setuniformarray}

### setUniformArray

```cpp
void setUniformArray(const std::string & name, const float * scalarArray, std::size_t length)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:729

Specify values for `float`[] array uniform.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const std::string &` | Name of the uniform variable in GLSL |
| `scalarArray` | `const float *` | pointer to array of `float` values |
| `length` | `std::size_t` | Number of elements in the array |

---

{#setuniformarray-1}

### setUniformArray

```cpp
void setUniformArray(const std::string & name, const Glsl::Vec2 * vectorArray, std::size_t length)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:739

Specify values for `vec2`[] array uniform.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const std::string &` | Name of the uniform variable in GLSL |
| `vectorArray` | const [`Glsl::Vec2`](sf-Glsl.md#vec2) * | pointer to array of `vec2` values |
| `length` | `std::size_t` | Number of elements in the array |

---

{#setuniformarray-2}

### setUniformArray

```cpp
void setUniformArray(const std::string & name, const Glsl::Vec3 * vectorArray, std::size_t length)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:749

Specify values for `vec3`[] array uniform.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const std::string &` | Name of the uniform variable in GLSL |
| `vectorArray` | const [`Glsl::Vec3`](sf-Glsl.md#vec3) * | pointer to array of `vec3` values |
| `length` | `std::size_t` | Number of elements in the array |

---

{#setuniformarray-3}

### setUniformArray

```cpp
void setUniformArray(const std::string & name, const Glsl::Vec4 * vectorArray, std::size_t length)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:759

Specify values for `vec4`[] array uniform.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const std::string &` | Name of the uniform variable in GLSL |
| `vectorArray` | const [`Glsl::Vec4`](sf-Glsl.md#vec4) * | pointer to array of `vec4` values |
| `length` | `std::size_t` | Number of elements in the array |

---

{#setuniformarray-4}

### setUniformArray

```cpp
void setUniformArray(const std::string & name, const Glsl::Mat3 * matrixArray, std::size_t length)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:769

Specify values for `mat3`[] array uniform.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const std::string &` | Name of the uniform variable in GLSL |
| `matrixArray` | const [`Glsl::Mat3`](sf-Glsl.md#mat3) * | pointer to array of `mat3` values |
| `length` | `std::size_t` | Number of elements in the array |

---

{#setuniformarray-5}

### setUniformArray

```cpp
void setUniformArray(const std::string & name, const Glsl::Mat4 * matrixArray, std::size_t length)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:779

Specify values for `mat4`[] array uniform.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const std::string &` | Name of the uniform variable in GLSL |
| `matrixArray` | const [`Glsl::Mat4`](sf-Glsl.md#mat4) * | pointer to array of `mat4` values |
| `length` | `std::size_t` | Number of elements in the array |

---

{#getnativehandle-2}

### getNativeHandle

`const` `nodiscard`

```cpp
[[nodiscard]] unsigned int getNativeHandle() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:791

Get the underlying OpenGL handle of the shader.

You shouldn't need to use this function, unless you have very specific stuff to implement that SFML doesn't support, or implement a temporary workaround until a bug is fixed.

#### Returns
OpenGL handle of the shader or 0 if not yet loaded

## Public Static Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`CurrentTextureType`](sf-Shader-CurrentTextureType.md#currenttexturetype) | [`CurrentTexture`](#currenttexture) `static` | Represents the texture of the object being drawn. |

---

{#currenttexture}

### CurrentTexture

`static`

```cpp
CurrentTextureType CurrentTexture
```

Type: [`CurrentTextureType`](sf-Shader-CurrentTextureType.md#currenttexturetype)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:85

Represents the texture of the object being drawn.

**See also**: `[setUniform](#setuniform)(const std::string&, [CurrentTextureType](sf-Shader-CurrentTextureType.md#currenttexturetype))`

## Public Static Methods

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`bind`](#bind-1) `static` | Bind a shader for rendering. |
| `bool` | [`isAvailable`](#isavailable-3) `static` `nodiscard` | Tell whether or not the system supports shaders. |
| `bool` | [`isGeometryAvailable`](#isgeometryavailable) `static` `nodiscard` | Tell whether or not the system supports geometry shaders. |

---

{#bind-1}

### bind

`static`

```cpp
static void bind(const Shader * shader)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:814

Bind a shader for rendering.

This function is not part of the graphics API, it mustn't be used when drawing SFML entities. It must be used only if you mix `[sf::Shader](#shader-1)` with OpenGL code.

```cpp
sf::Shader s1, s2;
...
sf::Shader::bind(&s1);
// draw OpenGL stuff that use s1...
sf::Shader::bind(&s2);
// draw OpenGL stuff that use s2...
sf::Shader::bind(nullptr);
// draw OpenGL stuff that use no shader...
```

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `shader` | const [`Shader`](#shader-1) * | [Shader](#shader-1) to bind, can be null to use no shader |

---

{#isavailable-3}

### isAvailable

`static` `nodiscard`

```cpp
[[nodiscard]] static bool isAvailable()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:826

Tell whether or not the system supports shaders.

This function should always be called before using the shader features. If it returns `false`, then any attempt to use `[sf::Shader](#shader-1)` will fail.

#### Returns
`true` if shaders are supported, `false` otherwise

---

{#isgeometryavailable}

### isGeometryAvailable

`static` `nodiscard`

```cpp
[[nodiscard]] static bool isGeometryAvailable()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:845

Tell whether or not the system supports geometry shaders.

This function should always be called before using the geometry shader features. If it returns `false`, then any attempt to use `[sf::Shader](#shader-1)` geometry shader features will fail.

This function can only return `true` if [isAvailable()](#isavailable-3) would also return `true`, since shaders in general have to be supported in order for geometry shaders to be supported as well.

Note: The first call to this function, whether by your code or SFML will result in a context switch.

#### Returns
`true` if geometry shaders are supported, `false` otherwise

## Public Types

| Name | Description |
|------|-------------|
| [`Type`](#type-7)  | Types of shaders. |

---

{#type-7}

### Type

```cpp
enum Type
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:60

Types of shaders.

| Value | Description |
|-------|-------------|
| `Vertex` | Vertex shader |
| `Geometry` | Geometry shader. |
| `Fragment` | Fragment (pixel) shader. |
## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `unsigned int` | [`m_shaderProgram`](#m_shaderprogram)  | OpenGL identifier for the program. |
| `int` | [`m_currentTexture`](#m_currenttexture)  | Location of the current texture in the shader. |
| `TextureTable` | [`m_textures`](#m_textures)  | [Texture](sf-Texture.md#texture-2) variables in the shader, mapped to their location. |
| `UniformTable` | [`m_uniforms`](#m_uniforms)  | Parameters location cache. |

---

{#m_shaderprogram}

### m_shaderProgram

```cpp
unsigned int m_shaderProgram {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:902

OpenGL identifier for the program.

---

{#m_currenttexture}

### m_currentTexture

```cpp
int m_currentTexture {-1}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:903

Location of the current texture in the shader.

---

{#m_textures}

### m_textures

```cpp
TextureTable m_textures
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:904

[Texture](sf-Texture.md#texture-2) variables in the shader, mapped to their location.

---

{#m_uniforms}

### m_uniforms

```cpp
UniformTable m_uniforms
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:905

Parameters location cache.

## Private Methods

| Return | Name | Description |
|--------|------|-------------|
| `bool` | [`compile`](#compile) `nodiscard` | Compile the shader(s) and create the program. |
| `void` | [`bindTextures`](#bindtextures) `const` | Bind all the textures used by the shader. |
| `int` | [`getUniformLocation`](#getuniformlocation)  | Get the location ID of a shader uniform. |

---

{#compile}

### compile

`nodiscard`

```cpp
[[nodiscard]] bool compile(std::string_view vertexShaderCode, std::string_view geometryShaderCode, std::string_view fragmentShaderCode)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:861

Compile the shader(s) and create the program.

If one of the arguments is a null pointer, the corresponding shader is not created.

#### Returns
`true` on success, `false` if any error happened

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vertexShaderCode` | `std::string_view` | Source code of the vertex shader |
| `geometryShaderCode` | `std::string_view` | Source code of the geometry shader |
| `fragmentShaderCode` | `std::string_view` | Source code of the fragment shader |

---

{#bindtextures}

### bindTextures

`const`

```cpp
void bindTextures() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:872

Bind all the textures used by the shader.

This function each texture to a different unit, and updates the corresponding variables in the shader accordingly.

---

{#getuniformlocation}

### getUniformLocation

```cpp
int getUniformLocation(const std::string & name)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Shader.hpp:882

Get the location ID of a shader uniform.

#### Returns
Location ID of the uniform, or -1 if not found

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const std::string &` | Name of the uniform variable to search |

