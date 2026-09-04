{#texture-2}

# Texture

```cpp
#include <Texture.hpp>
```

```cpp
class Texture
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:55

> **Inherits:** [`GlResource`](sf-GlResource.md#glresource)

[Image](sf-Image.md#image) living on the graphics card that can be used for drawing.

`[sf::Texture](#texture-2)` stores pixels that can be drawn, with a sprite for example. A texture lives in the graphics card memory, therefore it is very fast to draw a texture to a render target, or copy a render target to a texture (the graphics card can access both directly).

Being stored in the graphics card memory has some drawbacks. A texture cannot be manipulated as freely as a `[sf::Image](sf-Image.md#image)`, you need to prepare the pixels first and then upload them to the texture in a single operation (see `[Texture::update](#update-3)`).

`[sf::Texture](#texture-2)` makes it easy to convert from/to `[sf::Image](sf-Image.md#image)`, but keep in mind that these calls require transfers between the graphics card and the central memory, therefore they are slow operations.

A texture can be loaded from an image, but also directly from a file/memory/stream. The necessary shortcuts are defined so that you don't need an image first for the most common cases. However, if you want to perform some modifications on the pixels before creating the final texture, you can load your file to a `[sf::Image](sf-Image.md#image)`, do whatever you need with the pixels, and then call `[Texture](#texture-2)(const [Image](sf-Image.md#image)&)`.

Since they live in the graphics card memory, the pixels of a texture cannot be accessed without a slow copy first. And they cannot be accessed individually. Therefore, if you need to read the texture's pixels (like for pixel-perfect collisions), it is recommended to store the collision information separately, for example in an array of booleans.

Like `[sf::Image](sf-Image.md#image)`, `[sf::Texture](#texture-2)` can handle a unique internal representation of pixels, which is RGBA 32 bits. This means that a pixel must be composed of 8 bit red, green, blue and alpha channels &ndash; just like a `[sf::Color](sf-Color.md#color)`.

When providing texture data from an image file or memory, it can either be stored in a linear color space or an sRGB color space. Most digital images account for gamma correction already, so they would need to be "uncorrected" back to linear color space before being processed by the hardware. The hardware can automatically convert it from the sRGB color space to a linear color space when it gets sampled. When the rendered image gets output to the final framebuffer, it gets converted back to sRGB.

This option is only useful in conjunction with an sRGB capable framebuffer. This can be requested during window creation.

Usage example: 
```cpp
// This example shows the most common use of sf::Texture:
// drawing a sprite

// Load a texture from a file
const sf::Texture texture("texture.png");

// Assign it to a sprite
sf::Sprite sprite(texture);

// Draw the textured sprite
window.draw(sprite);
```

```cpp
// This example shows another common use of sf::Texture:
// streaming real-time data, like video frames

// Create an empty texture
sf::Texture texture({640, 480});

// Create a sprite that will display the texture
sf::Sprite sprite(texture);

while (...) // the main loop
{
    ...

    // update the texture
    std::uint8_t* pixels = ...; // get a fresh chunk of pixels (the next frame of a movie, for example)
    texture.update(pixels);

    // draw it
    window.draw(sprite);

    ...
}
```

Like `[sf::Shader](sf-Shader.md#shader-1)` that can be used as a raw OpenGL shader, `[sf::Texture](#texture-2)` can also be used directly as a raw texture for custom OpenGL geometry. 
```cpp
sf::Texture::bind(&texture);
... render OpenGL geometry ...
sf::Texture::bind(nullptr);
```

**See also**: `[sf::Sprite](sf-Sprite.md#sprite)`, `[sf::Image](sf-Image.md#image)`, `[sf::RenderTexture](sf-RenderTexture.md#rendertexture)`

## List of all members

| Name | Kind | Owner |
|------|------|-------|
| [`Text`](#text-4) | `friend` | Declared here |
| [`RenderTexture`](#rendertexture-6) | `friend` | Declared here |
| [`RenderTarget`](#rendertarget-6) | `friend` | Declared here |
| [`Texture`](#texture-3) | `function` | Declared here |
| [`~Texture`](#texture-4) | `function` | Declared here |
| [`Texture`](#texture-5) | `function` | Declared here |
| [`operator=`](#operator-76) | `function` | Declared here |
| [`Texture`](#texture-6) | `function` | Declared here |
| [`operator=`](#operator-77) | `function` | Declared here |
| [`Texture`](#texture-7) | `function` | Declared here |
| [`Texture`](#texture-8) | `function` | Declared here |
| [`Texture`](#texture-9) | `function` | Declared here |
| [`Texture`](#texture-10) | `function` | Declared here |
| [`Texture`](#texture-11) | `function` | Declared here |
| [`Texture`](#texture-12) | `function` | Declared here |
| [`Texture`](#texture-13) | `function` | Declared here |
| [`Texture`](#texture-14) | `function` | Declared here |
| [`Texture`](#texture-15) | `function` | Declared here |
| [`resize`](#resize-3) | `function` | Declared here |
| [`loadFromFile`](#loadfromfile-5) | `function` | Declared here |
| [`loadFromMemory`](#loadfrommemory-5) | `function` | Declared here |
| [`loadFromStream`](#loadfromstream-5) | `function` | Declared here |
| [`loadFromImage`](#loadfromimage) | `function` | Declared here |
| [`getSize`](#getsize-10) | `function` | Declared here |
| [`copyToImage`](#copytoimage) | `function` | Declared here |
| [`update`](#update-3) | `function` | Declared here |
| [`update`](#update-4) | `function` | Declared here |
| [`update`](#update-5) | `function` | Declared here |
| [`update`](#update-6) | `function` | Declared here |
| [`update`](#update-7) | `function` | Declared here |
| [`update`](#update-8) | `function` | Declared here |
| [`update`](#update-9) | `function` | Declared here |
| [`update`](#update-10) | `function` | Declared here |
| [`setSmooth`](#setsmooth-2) | `function` | Declared here |
| [`isSmooth`](#issmooth-2) | `function` | Declared here |
| [`isSrgb`](#issrgb-3) | `function` | Declared here |
| [`setRepeated`](#setrepeated-1) | `function` | Declared here |
| [`isRepeated`](#isrepeated-1) | `function` | Declared here |
| [`generateMipmap`](#generatemipmap-1) | `function` | Declared here |
| [`swap`](#swap) | `function` | Declared here |
| [`getNativeHandle`](#getnativehandle-3) | `function` | Declared here |
| [`bind`](#bind-2) | `function` | Declared here |
| [`getMaximumSize`](#getmaximumsize) | `function` | Declared here |
| [`m_size`](#m_size-4) | `variable` | Declared here |
| [`m_actualSize`](#m_actualsize) | `variable` | Declared here |
| [`m_texture`](#m_texture-3) | `variable` | Declared here |
| [`m_isSmooth`](#m_issmooth-1) | `variable` | Declared here |
| [`m_sRgb`](#m_srgb) | `variable` | Declared here |
| [`m_isRepeated`](#m_isrepeated) | `variable` | Declared here |
| [`m_pixelsFlipped`](#m_pixelsflipped) | `variable` | Declared here |
| [`m_fboAttachment`](#m_fboattachment) | `variable` | Declared here |
| [`m_hasMipmap`](#m_hasmipmap) | `variable` | Declared here |
| [`m_cacheId`](#m_cacheid) | `variable` | Declared here |
| [`invalidateMipmap`](#invalidatemipmap) | `function` | Declared here |
| [`getValidSize`](#getvalidsize) | `function` | Declared here |
| [`GlResource`](sf-GlResource.md#glresource-1) | `function` | Inherited from [`GlResource`](sf-GlResource.md#glresource) |
| [`m_sharedContext`](sf-GlResource.md#m_sharedcontext) | `variable` | Inherited from [`GlResource`](sf-GlResource.md#glresource) |

## Inherited from [`GlResource`](sf-GlResource.md#glresource)

| Kind | Name | Description |
|------|------|-------------|
| `function` | [`GlResource`](sf-GlResource.md#glresource-1)  | Default constructor. |
| `variable` | [`m_sharedContext`](sf-GlResource.md#m_sharedcontext)  | Shared context used to link all contexts together for resource sharing. |

## Friends

| Name | Description |
|------|-------------|
| [`Text`](#text-4)  |  |
| [`RenderTexture`](#rendertexture-6)  |  |
| [`RenderTarget`](#rendertarget-6)  |  |

---

{#text-4}

### Text

```cpp
friend class Text
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:715

---

{#rendertexture-6}

### RenderTexture

```cpp
friend class RenderTexture
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:716

---

{#rendertarget-6}

### RenderTarget

```cpp
friend class RenderTarget
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:717

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`Texture`](#texture-3)  | Default constructor. |
|  | [`~Texture`](#texture-4)  | Destructor. |
|  | [`Texture`](#texture-5)  | Copy constructor. |
| [`Texture`](#texture-2) & | [`operator=`](#operator-76)  | Copy assignment operator. |
|  | [`Texture`](#texture-6) `noexcept` | Move constructor. |
| [`Texture`](#texture-2) & | [`operator=`](#operator-77) `noexcept` | Move assignment operator. |
|  | [`Texture`](#texture-7) `explicit` | Construct the texture from a file on disk. |
|  | [`Texture`](#texture-8)  | Construct the texture from a sub-rectangle of a file on disk. |
|  | [`Texture`](#texture-9)  | Construct the texture from a file in memory. |
|  | [`Texture`](#texture-10)  | Construct the texture from a sub-rectangle of a file in memory. |
|  | [`Texture`](#texture-11) `explicit` | Construct the texture from a custom stream. |
|  | [`Texture`](#texture-12)  | Construct the texture from a sub-rectangle of a custom stream. |
|  | [`Texture`](#texture-13) `explicit` | Construct the texture from an image. |
|  | [`Texture`](#texture-14)  | Construct the texture from a sub-rectangle of an image. |
|  | [`Texture`](#texture-15) `explicit` | Construct the texture with a given size. |
| `bool` | [`resize`](#resize-3) `nodiscard` | Resize the texture. |
| `bool` | [`loadFromFile`](#loadfromfile-5) `nodiscard` | Load the texture from a file on disk. |
| `bool` | [`loadFromMemory`](#loadfrommemory-5) `nodiscard` | Load the texture from a file in memory. |
| `bool` | [`loadFromStream`](#loadfromstream-5) `nodiscard` | Load the texture from a custom stream. |
| `bool` | [`loadFromImage`](#loadfromimage) `nodiscard` | Load the texture from an image. |
| [`Vector2u`](sf.md#vector2u) | [`getSize`](#getsize-10) `const` `nodiscard` | Return the size of the texture. |
| [`Image`](sf-Image.md#image) | [`copyToImage`](#copytoimage) `const` `nodiscard` | Copy the texture pixels to an image. |
| `void` | [`update`](#update-3)  | Update the whole texture from an array of pixels. |
| `void` | [`update`](#update-4)  | Update a part of the texture from an array of pixels. |
| `void` | [`update`](#update-5)  | Update a part of this texture from another texture. |
| `void` | [`update`](#update-6)  | Update a part of this texture from another texture. |
| `void` | [`update`](#update-7)  | Update the texture from an image. |
| `void` | [`update`](#update-8)  | Update a part of the texture from an image. |
| `void` | [`update`](#update-9)  | Update the texture from the contents of a window. |
| `void` | [`update`](#update-10)  | Update a part of the texture from the contents of a window. |
| `void` | [`setSmooth`](#setsmooth-2)  | Enable or disable the smooth filter. |
| `bool` | [`isSmooth`](#issmooth-2) `const` `nodiscard` | Tell whether the smooth filter is enabled or not. |
| `bool` | [`isSrgb`](#issrgb-3) `const` `nodiscard` | Tell whether the texture source is converted from sRGB or not. |
| `void` | [`setRepeated`](#setrepeated-1)  | Enable or disable repeating. |
| `bool` | [`isRepeated`](#isrepeated-1) `const` `nodiscard` | Tell whether the texture is repeated or not. |
| `bool` | [`generateMipmap`](#generatemipmap-1) `nodiscard` | Generate a mipmap using the current texture data. |
| `void` | [`swap`](#swap) `noexcept` | Swap the contents of this texture with those of another. |
| `unsigned int` | [`getNativeHandle`](#getnativehandle-3) `const` `nodiscard` | Get the underlying OpenGL handle of the texture. |

---

{#texture-3}

### Texture

```cpp
Texture()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:66

Default constructor.

Creates a texture with width 0 and height 0.

**See also**: `[resize](#resize-3)`

---

{#texture-4}

### ~Texture

```cpp
~Texture()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:72

Destructor.

---

{#texture-5}

### Texture

```cpp
Texture(const Texture & copy)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:80

Copy constructor.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `copy` | const [`Texture`](#texture-2) & | instance to copy |

---

{#operator-76}

### operator=

```cpp
Texture & operator=(const Texture &)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:86

Copy assignment operator.

---

{#texture-6}

### Texture

`noexcept`

```cpp
Texture(Texture &&) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:92

Move constructor.

---

{#operator-77}

### operator=

`noexcept`

```cpp
Texture & operator=(Texture &&) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:98

Move assignment operator.

---

{#texture-7}

### Texture

`explicit`

```cpp
explicit Texture(const std::filesystem::path & filename, bool sRgb = false)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:114

Construct the texture from a file on disk.

The maximum size for a texture depends on the graphics driver and can be retrieved with the getMaximumSize function.

**See also**: `[loadFromFile](#loadfromfile-5)`, `[loadFromMemory](#loadfrommemory-5)`, `[loadFromStream](#loadfromstream-5)`, `[loadFromImage](#loadfromimage)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `filename` | `const std::filesystem::path &` | Path of the image file to load |
| `sRgb` | `bool` | `true` to enable sRGB conversion, `false` to disable it |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if loading was unsuccessful |

---

{#texture-8}

### Texture

```cpp
Texture(const std::filesystem::path & filename, bool sRgb, const IntRect & area)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:137

Construct the texture from a sub-rectangle of a file on disk.

The `area` argument can be used to load only a sub-rectangle of the whole image. If you want the entire image then leave the default value (which is an empty `[IntRect](sf.md#intrect)`). If the `area` rectangle crosses the bounds of the image, it is adjusted to fit the image size.

The maximum size for a texture depends on the graphics driver and can be retrieved with the `getMaximumSize` function.

**See also**: `[loadFromFile](#loadfromfile-5)`, `[loadFromMemory](#loadfrommemory-5)`, `[loadFromStream](#loadfromstream-5)`, `[loadFromImage](#loadfromimage)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `filename` | `const std::filesystem::path &` | Path of the image file to load |
| `sRgb` | `bool` | `true` to enable sRGB conversion, `false` to disable it |
| `area` | const [`IntRect`](sf.md#intrect) & | Area of the image to load |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if loading was unsuccessful |

---

{#texture-9}

### Texture

```cpp
Texture(const void * data, std::size_t size, bool sRgb = false)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:154

Construct the texture from a file in memory.

The maximum size for a texture depends on the graphics driver and can be retrieved with the `getMaximumSize` function.

**See also**: `[loadFromFile](#loadfromfile-5)`, `[loadFromMemory](#loadfrommemory-5)`, `[loadFromStream](#loadfromstream-5)`, `[loadFromImage](#loadfromimage)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `const void *` | Pointer to the file data in memory |
| `size` | `std::size_t` | Size of the data to load, in bytes |
| `sRgb` | `bool` | `true` to enable sRGB conversion, `false` to disable it |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if loading was unsuccessful |

---

{#texture-10}

### Texture

```cpp
Texture(const void * data, std::size_t size, bool sRgb, const IntRect & area)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:178

Construct the texture from a sub-rectangle of a file in memory.

The `area` argument can be used to load only a sub-rectangle of the whole image. If you want the entire image then leave the default value (which is an empty `[IntRect](sf.md#intrect)`). If the `area` rectangle crosses the bounds of the image, it is adjusted to fit the image size.

The maximum size for a texture depends on the graphics driver and can be retrieved with the `getMaximumSize` function.

**See also**: `[loadFromFile](#loadfromfile-5)`, `[loadFromMemory](#loadfrommemory-5)`, `[loadFromStream](#loadfromstream-5)`, `[loadFromImage](#loadfromimage)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `const void *` | Pointer to the file data in memory |
| `size` | `std::size_t` | Size of the data to load, in bytes |
| `sRgb` | `bool` | `true` to enable sRGB conversion, `false` to disable it |
| `area` | const [`IntRect`](sf.md#intrect) & | Area of the image to load |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if loading was unsuccessful |

---

{#texture-11}

### Texture

`explicit`

```cpp
explicit Texture(InputStream & stream, bool sRgb = false)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:194

Construct the texture from a custom stream.

The maximum size for a texture depends on the graphics driver and can be retrieved with the `getMaximumSize` function.

**See also**: `[loadFromFile](#loadfromfile-5)`, `[loadFromMemory](#loadfrommemory-5)`, `[loadFromStream](#loadfromstream-5)`, `[loadFromImage](#loadfromimage)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `stream` | [`InputStream`](sf-InputStream.md#inputstream) & | Source stream to read from |
| `sRgb` | `bool` | `true` to enable sRGB conversion, `false` to disable it |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if loading was unsuccessful |

---

{#texture-12}

### Texture

```cpp
Texture(InputStream & stream, bool sRgb, const IntRect & area)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:217

Construct the texture from a sub-rectangle of a custom stream.

The `area` argument can be used to load only a sub-rectangle of the whole image. If you want the entire image then leave the default value (which is an empty `[IntRect](sf.md#intrect)`). If the `area` rectangle crosses the bounds of the image, it is adjusted to fit the image size.

The maximum size for a texture depends on the graphics driver and can be retrieved with the `getMaximumSize` function.

**See also**: `[loadFromFile](#loadfromfile-5)`, `[loadFromMemory](#loadfrommemory-5)`, `[loadFromStream](#loadfromstream-5)`, `[loadFromImage](#loadfromimage)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `stream` | [`InputStream`](sf-InputStream.md#inputstream) & | Source stream to read from |
| `sRgb` | `bool` | `true` to enable sRGB conversion, `false` to disable it |
| `area` | const [`IntRect`](sf.md#intrect) & | Area of the image to load |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if loading was unsuccessful |

---

{#texture-13}

### Texture

`explicit`

```cpp
explicit Texture(const Image & image, bool sRgb = false)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:233

Construct the texture from an image.

The maximum size for a texture depends on the graphics driver and can be retrieved with the `getMaximumSize` function.

**See also**: `[loadFromFile](#loadfromfile-5)`, `[loadFromMemory](#loadfrommemory-5)`, `[loadFromStream](#loadfromstream-5)`, `[loadFromImage](#loadfromimage)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `image` | const [`Image`](sf-Image.md#image) & | [Image](sf-Image.md#image) to load into the texture |
| `sRgb` | `bool` | `true` to enable sRGB conversion, `false` to disable it |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if loading was unsuccessful |

---

{#texture-14}

### Texture

```cpp
Texture(const Image & image, bool sRgb, const IntRect & area)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:255

Construct the texture from a sub-rectangle of an image.

The `area` argument is used to load only a sub-rectangle of the whole image. If the `area` rectangle crosses the bounds of the image, it is adjusted to fit the image size.

The maximum size for a texture depends on the graphics driver and can be retrieved with the `getMaximumSize` function.

**See also**: `[loadFromFile](#loadfromfile-5)`, `[loadFromMemory](#loadfrommemory-5)`, `[loadFromStream](#loadfromstream-5)`, `[loadFromImage](#loadfromimage)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `image` | const [`Image`](sf-Image.md#image) & | [Image](sf-Image.md#image) to load into the texture |
| `sRgb` | `bool` | `true` to enable sRGB conversion, `false` to disable it |
| `area` | const [`IntRect`](sf.md#intrect) & | Area of the image to load |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if loading was unsuccessful |

---

{#texture-15}

### Texture

`explicit`

```cpp
explicit Texture(Vector2u size, bool sRgb = false)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:266

Construct the texture with a given size.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `size` | [`Vector2u`](sf.md#vector2u) | Width and height of the texture |
| `sRgb` | `bool` | `true` to enable sRGB conversion, `false` to disable it |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if construction was unsuccessful |

---

{#resize-3}

### resize

`nodiscard`

```cpp
[[nodiscard]] bool resize(Vector2u size, bool sRgb = false)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:279

Resize the texture.

If this function fails, the texture is left unchanged.

#### Returns
`true` if resizing was successful, `false` if it failed

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `size` | [`Vector2u`](sf.md#vector2u) | Width and height of the texture |
| `sRgb` | `bool` | `true` to enable sRGB conversion, `false` to disable it |

---

{#loadfromfile-5}

### loadFromFile

`nodiscard`

```cpp
[[nodiscard]] bool loadFromFile(const std::filesystem::path & filename, bool sRgb = false, const IntRect & area = {})
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:304

Load the texture from a file on disk.

The `area` argument can be used to load only a sub-rectangle of the whole image. If you want the entire image then leave the default value (which is an empty `[IntRect](sf.md#intrect)`). If the `area` rectangle crosses the bounds of the image, it is adjusted to fit the image size.

The maximum size for a texture depends on the graphics driver and can be retrieved with the `getMaximumSize` function.

If this function fails, the texture is left unchanged.

#### Returns
`true` if loading was successful, `false` if it failed

**See also**: `[loadFromMemory](#loadfrommemory-5)`, `[loadFromStream](#loadfromstream-5)`, `[loadFromImage](#loadfromimage)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `filename` | `const std::filesystem::path &` | Path of the image file to load |
| `sRgb` | `bool` | `true` to enable sRGB conversion, `false` to disable it |
| `area` | const [`IntRect`](sf.md#intrect) & | Area of the image to load |

---

{#loadfrommemory-5}

### loadFromMemory

`nodiscard`

```cpp
[[nodiscard]] bool loadFromMemory(const void * data, std::size_t size, bool sRgb = false, const IntRect & area = {})
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:330

Load the texture from a file in memory.

The `area` argument can be used to load only a sub-rectangle of the whole image. If you want the entire image then leave the default value (which is an empty `[IntRect](sf.md#intrect)`). If the `area` rectangle crosses the bounds of the image, it is adjusted to fit the image size.

The maximum size for a texture depends on the graphics driver and can be retrieved with the `getMaximumSize` function.

If this function fails, the texture is left unchanged.

#### Returns
`true` if loading was successful, `false` if it failed

**See also**: `[loadFromFile](#loadfromfile-5)`, `[loadFromStream](#loadfromstream-5)`, `[loadFromImage](#loadfromimage)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `const void *` | Pointer to the file data in memory |
| `size` | `std::size_t` | Size of the data to load, in bytes |
| `sRgb` | `bool` | `true` to enable sRGB conversion, `false` to disable it |
| `area` | const [`IntRect`](sf.md#intrect) & | Area of the image to load |

---

{#loadfromstream-5}

### loadFromStream

`nodiscard`

```cpp
[[nodiscard]] bool loadFromStream(InputStream & stream, bool sRgb = false, const IntRect & area = {})
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:355

Load the texture from a custom stream.

The `area` argument can be used to load only a sub-rectangle of the whole image. If you want the entire image then leave the default value (which is an empty `[IntRect](sf.md#intrect)`). If the `area` rectangle crosses the bounds of the image, it is adjusted to fit the image size.

The maximum size for a texture depends on the graphics driver and can be retrieved with the `getMaximumSize` function.

If this function fails, the texture is left unchanged.

#### Returns
`true` if loading was successful, `false` if it failed

**See also**: `[loadFromFile](#loadfromfile-5)`, `[loadFromMemory](#loadfrommemory-5)`, `[loadFromImage](#loadfromimage)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `stream` | [`InputStream`](sf-InputStream.md#inputstream) & | Source stream to read from |
| `sRgb` | `bool` | `true` to enable sRGB conversion, `false` to disable it |
| `area` | const [`IntRect`](sf.md#intrect) & | Area of the image to load |

---

{#loadfromimage}

### loadFromImage

`nodiscard`

```cpp
[[nodiscard]] bool loadFromImage(const Image & image, bool sRgb = false, const IntRect & area = {})
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:380

Load the texture from an image.

The `area` argument can be used to load only a sub-rectangle of the whole image. If you want the entire image then leave the default value (which is an empty `[IntRect](sf.md#intrect)`). If the `area` rectangle crosses the bounds of the image, it is adjusted to fit the image size.

The maximum size for a texture depends on the graphics driver and can be retrieved with the `getMaximumSize` function.

If this function fails, the texture is left unchanged.

#### Returns
`true` if loading was successful, `false` if it failed

**See also**: `[loadFromFile](#loadfromfile-5)`, `[loadFromMemory](#loadfrommemory-5)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `image` | const [`Image`](sf-Image.md#image) & | [Image](sf-Image.md#image) to load into the texture |
| `sRgb` | `bool` | `true` to enable sRGB conversion, `false` to disable it |
| `area` | const [`IntRect`](sf.md#intrect) & | Area of the image to load |

---

{#getsize-10}

### getSize

`const` `nodiscard`

```cpp
[[nodiscard]] Vector2u getSize() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:388

Return the size of the texture.

#### Returns
Size in pixels

---

{#copytoimage}

### copyToImage

`const` `nodiscard`

```cpp
[[nodiscard]] Image copyToImage() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:403

Copy the texture pixels to an image.

This function performs a slow operation that downloads the texture's pixels from the graphics card and copies them to a new image, potentially applying transformations to pixels if necessary (texture may be padded or flipped).

#### Returns
[Image](sf-Image.md#image) containing the texture's pixels

**See also**: `[loadFromImage](#loadfromimage)`

---

{#update-3}

### update

```cpp
void update(const std::uint8_t * pixels)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:421

Update the whole texture from an array of pixels.

The pixel array is assumed to have the same size as the `area` rectangle, and to contain 32-bits RGBA pixels.

No additional check is performed on the size of the pixel array. Passing invalid arguments will lead to an undefined behavior.

This function does nothing if `pixels` is `nullptr` or if the texture was not previously created.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `pixels` | `const std::uint8_t *` | Array of pixels to copy to the texture |

---

{#update-4}

### update

```cpp
void update(const std::uint8_t * pixels, Vector2u size, Vector2u dest)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:441

Update a part of the texture from an array of pixels.

The size of the pixel array must match the `size` argument, and it must contain 32-bits RGBA pixels.

No additional check is performed on the size of the pixel array or the bounds of the area to update. Passing invalid arguments will lead to an undefined behavior.

This function does nothing if `pixels` is null or if the texture was not previously created.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `pixels` | `const std::uint8_t *` | Array of pixels to copy to the texture |
| `size` | [`Vector2u`](sf.md#vector2u) | Width and height of the pixel region contained in `pixels` |
| `dest` | [`Vector2u`](sf.md#vector2u) | Coordinates of the destination position |

---

{#update-5}

### update

```cpp
void update(const Texture & texture)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:462

Update a part of this texture from another texture.

Although the source texture can be smaller than this texture, this function is usually used for updating the whole texture. The other overload, which has an additional destination argument, is more convenient for updating a sub-area of this texture.

No additional check is performed on the size of the passed texture. Passing a texture bigger than this texture will lead to an undefined behavior.

This function does nothing if either texture was not previously created.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `texture` | const [`Texture`](#texture-2) & | Source texture to copy to this texture |

---

{#update-6}

### update

```cpp
void update(const Texture & texture, Vector2u dest)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:478

Update a part of this texture from another texture.

No additional check is performed on the size of the texture. Passing an invalid combination of texture size and destination will lead to an undefined behavior.

This function does nothing if either texture was not previously created.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `texture` | const [`Texture`](#texture-2) & | Source texture to copy to this texture |
| `dest` | [`Vector2u`](sf.md#vector2u) | Coordinates of the destination position |

---

{#update-7}

### update

```cpp
void update(const Image & image)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:499

Update the texture from an image.

Although the source image can be smaller than the texture, this function is usually used for updating the whole texture. The other overload, which has an additional destination argument, is more convenient for updating a sub-area of the texture.

No additional check is performed on the size of the image. Passing an image bigger than the texture will lead to an undefined behavior.

This function does nothing if the texture was not previously created.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `image` | const [`Image`](sf-Image.md#image) & | [Image](sf-Image.md#image) to copy to the texture |

---

{#update-8}

### update

```cpp
void update(const Image & image, Vector2u dest)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:515

Update a part of the texture from an image.

No additional check is performed on the size of the image. Passing an invalid combination of image size and destination will lead to an undefined behavior.

This function does nothing if the texture was not previously created.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `image` | const [`Image`](sf-Image.md#image) & | [Image](sf-Image.md#image) to copy to the texture |
| `dest` | [`Vector2u`](sf.md#vector2u) | Coordinates of the destination position |

---

{#update-9}

### update

```cpp
void update(const Window & window)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:536

Update the texture from the contents of a window.

Although the source window can be smaller than the texture, this function is usually used for updating the whole texture. The other overload, which has an additional destination argument, is more convenient for updating a sub-area of the texture.

No additional check is performed on the size of the window. Passing a window bigger than the texture will lead to an undefined behavior.

This function does nothing if either the texture or the window was not previously created.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `window` | const [`Window`](sf-Window.md#window) & | [Window](sf-Window.md#window) to copy to the texture |

---

{#update-10}

### update

```cpp
void update(const Window & window, Vector2u dest)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:552

Update a part of the texture from the contents of a window.

No additional check is performed on the size of the window. Passing an invalid combination of window size and destination will lead to an undefined behavior.

This function does nothing if either the texture or the window was not previously created.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `window` | const [`Window`](sf-Window.md#window) & | [Window](sf-Window.md#window) to copy to the texture |
| `dest` | [`Vector2u`](sf.md#vector2u) | Coordinates of the destination position |

---

{#setsmooth-2}

### setSmooth

```cpp
void setSmooth(bool smooth)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:568

Enable or disable the smooth filter.

When the filter is activated, the texture appears smoother so that pixels are less noticeable. However if you want the texture to look exactly the same as its source file, you should leave it disabled. The smooth filter is disabled by default.

**See also**: `[isSmooth](#issmooth-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `smooth` | `bool` | `true` to enable smoothing, `false` to disable it |

---

{#issmooth-2}

### isSmooth

`const` `nodiscard`

```cpp
[[nodiscard]] bool isSmooth() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:578

Tell whether the smooth filter is enabled or not.

#### Returns
`true` if smoothing is enabled, `false` if it is disabled

**See also**: `[setSmooth](#setsmooth-2)`

---

{#issrgb-3}

### isSrgb

`const` `nodiscard`

```cpp
[[nodiscard]] bool isSrgb() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:588

Tell whether the texture source is converted from sRGB or not.

#### Returns
`true` if the texture source is converted from sRGB, `false` if not

**See also**: `setSrgb`

---

{#setrepeated-1}

### setRepeated

```cpp
void setRepeated(bool repeated)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:612

Enable or disable repeating.

Repeating is involved when using texture coordinates outside the texture rectangle [0, 0, width, height]. In this case, if repeat mode is enabled, the whole texture will be repeated as many times as needed to reach the coordinate (for example, if the X texture coordinate is 3 * width, the texture will be repeated 3 times). If repeat mode is disabled, the "extra space" will instead be filled with border pixels. Warning: on very old graphics cards, white pixels may appear when the texture is repeated. With such cards, repeat mode can be used reliably only if the texture has power-of-two dimensions (such as 256x128). Repeating is disabled by default.

**See also**: `[isRepeated](#isrepeated-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `repeated` | `bool` | `true` to repeat the texture, `false` to disable repeating |

---

{#isrepeated-1}

### isRepeated

`const` `nodiscard`

```cpp
[[nodiscard]] bool isRepeated() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:622

Tell whether the texture is repeated or not.

#### Returns
`true` if repeat mode is enabled, `false` if it is disabled

**See also**: `[setRepeated](#setrepeated-1)`

---

{#generatemipmap-1}

### generateMipmap

`nodiscard`

```cpp
[[nodiscard]] bool generateMipmap()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:647

Generate a mipmap using the current texture data.

Mipmaps are pre-computed chains of optimized textures. Each level of texture in a mipmap is generated by halving each of the previous level's dimensions. This is done until the final level has the size of 1x1. The textures generated in this process may make use of more advanced filters which might improve the visual quality of textures when they are applied to objects much smaller than they are. This is known as minification. Because fewer texels (texture elements) have to be sampled from when heavily minified, usage of mipmaps can also improve rendering performance in certain scenarios.

Mipmap generation relies on the necessary OpenGL extension being available. If it is unavailable or generation fails due to another reason, this function will return `false`. Mipmap data is only valid from the time it is generated until the next time the base level image is modified, at which point this function will have to be called again to regenerate it.

#### Returns
`true` if mipmap generation was successful, `false` if unsuccessful

---

{#swap}

### swap

`noexcept`

```cpp
void swap(Texture & right) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:655

Swap the contents of this texture with those of another.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `right` | [`Texture`](#texture-2) & | Instance to swap with |

---

{#getnativehandle-3}

### getNativeHandle

`const` `nodiscard`

```cpp
[[nodiscard]] unsigned int getNativeHandle() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:667

Get the underlying OpenGL handle of the texture.

You shouldn't need to use this function, unless you have very specific stuff to implement that SFML doesn't support, or implement a temporary workaround until a bug is fixed.

#### Returns
OpenGL handle of the texture or 0 if not yet created

## Public Static Methods

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`bind`](#bind-2) `static` | Bind a texture for rendering. |
| `unsigned int` | [`getMaximumSize`](#getmaximumsize) `static` `nodiscard` | Get the maximum texture size allowed. |

---

{#bind-2}

### bind

`static`

```cpp
static void bind(const Texture * texture, CoordinateType coordinateType = CoordinateType::Normalized)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:700

Bind a texture for rendering.

This function is not part of the graphics API, it mustn't be used when drawing SFML entities. It must be used only if you mix `[sf::Texture](#texture-2)` with OpenGL code.

```cpp
sf::Texture t1, t2;
...
sf::Texture::bind(&t1);
// draw OpenGL stuff that use t1...
sf::Texture::bind(&t2);
// draw OpenGL stuff that use t2...
sf::Texture::bind(nullptr);
// draw OpenGL stuff that use no texture...
```

The `coordinateType` argument controls how texture coordinates will be interpreted. If Normalized (the default), they must be in range [0 .. 1], which is the default way of handling texture coordinates with OpenGL. If Pixels, they must be given in pixels (range [0 .. size]). This mode is used internally by the graphics classes of SFML, it makes the definition of texture coordinates more intuitive for the high-level API, users don't need to compute normalized values.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `texture` | const [`Texture`](#texture-2) * | Pointer to the texture to bind, can be null to use no texture |
| `coordinateType` | [`CoordinateType`](CoordinateType.md#coordinatetype) | Type of texture coordinates to use |

---

{#getmaximumsize}

### getMaximumSize

`static` `nodiscard`

```cpp
[[nodiscard]] static unsigned int getMaximumSize()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:712

Get the maximum texture size allowed.

This maximum size is defined by the graphics driver. You can expect a value of 512 pixels for low-end graphics card, and up to 8192 pixels or more for newer hardware.

#### Returns
Maximum size allowed for textures, in pixels

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`Vector2u`](sf.md#vector2u) | [`m_size`](#m_size-4)  | Public texture size. |
| [`Vector2u`](sf.md#vector2u) | [`m_actualSize`](#m_actualsize)  | Actual texture size (can be greater than public size because of padding) |
| `unsigned int` | [`m_texture`](#m_texture-3)  | Internal texture identifier. |
| `bool` | [`m_isSmooth`](#m_issmooth-1)  | Status of the smooth filter. |
| `bool` | [`m_sRgb`](#m_srgb)  | Should the texture source be converted from sRGB? |
| `bool` | [`m_isRepeated`](#m_isrepeated)  | Is the texture in repeat mode? |
| `bool` | [`m_pixelsFlipped`](#m_pixelsflipped)  | To work around the inconsistency in Y orientation. |
| `bool` | [`m_fboAttachment`](#m_fboattachment)  | Is this texture owned by a framebuffer object? |
| `bool` | [`m_hasMipmap`](#m_hasmipmap)  | Has the mipmap been generated? |
| `std::uint64_t` | [`m_cacheId`](#m_cacheid)  | Unique number that identifies the texture to the render target's cache. |

---

{#m_size-4}

### m_size

```cpp
Vector2u m_size
```

Type: [`Vector2u`](sf.md#vector2u)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:746

Public texture size.

---

{#m_actualsize}

### m_actualSize

```cpp
Vector2u m_actualSize
```

Type: [`Vector2u`](sf.md#vector2u)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:747

Actual texture size (can be greater than public size because of padding)

---

{#m_texture-3}

### m_texture

```cpp
unsigned int m_texture {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:748

Internal texture identifier.

---

{#m_issmooth-1}

### m_isSmooth

```cpp
bool m_isSmooth {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:749

Status of the smooth filter.

---

{#m_srgb}

### m_sRgb

```cpp
bool m_sRgb {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:750

Should the texture source be converted from sRGB?

---

{#m_isrepeated}

### m_isRepeated

```cpp
bool m_isRepeated {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:751

Is the texture in repeat mode?

---

{#m_pixelsflipped}

### m_pixelsFlipped

```cpp
bool m_pixelsFlipped {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:752

To work around the inconsistency in Y orientation.

---

{#m_fboattachment}

### m_fboAttachment

```cpp
bool m_fboAttachment {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:753

Is this texture owned by a framebuffer object?

---

{#m_hasmipmap}

### m_hasMipmap

```cpp
bool m_hasMipmap {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:754

Has the mipmap been generated?

---

{#m_cacheid}

### m_cacheId

```cpp
std::uint64_t m_cacheId
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:755

Unique number that identifies the texture to the render target's cache.

## Private Methods

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`invalidateMipmap`](#invalidatemipmap)  | Invalidate the mipmap if one exists. |

---

{#invalidatemipmap}

### invalidateMipmap

```cpp
void invalidateMipmap()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:741

Invalidate the mipmap if one exists.

This also resets the texture's minifying function. This function is mainly for internal use by [RenderTexture](sf-RenderTexture.md#rendertexture).

## Private Static Methods

| Return | Name | Description |
|--------|------|-------------|
| `unsigned int` | [`getValidSize`](#getvalidsize) `static` `nodiscard` | Get a valid image size according to hardware support. |

---

{#getvalidsize}

### getValidSize

`static` `nodiscard`

```cpp
[[nodiscard]] static unsigned int getValidSize(unsigned int size)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Texture.hpp:732

Get a valid image size according to hardware support.

This function checks whether the graphics driver supports non power of two sizes or not, and adjusts the size accordingly. The returned size is greater than or equal to the original size.

#### Returns
Valid nearest size (greater than or equal to specified size)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `size` | `unsigned int` | size to convert |

