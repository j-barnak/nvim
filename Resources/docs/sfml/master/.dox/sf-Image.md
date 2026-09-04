{#image}

# Image

```cpp
#include <Image.hpp>
```

```cpp
class Image
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Image.hpp:54

Class for loading, manipulating and saving images.

`[sf::Image](#image)` is an abstraction to manipulate images as bi-dimensional arrays of pixels. The class provides functions to load, read, write and save pixels, as well as many other useful functions.

`[sf::Image](#image)` can handle a unique internal representation of pixels, which is RGBA 32 bits. This means that a pixel must be composed of 8 bit red, green, blue and alpha channels &ndash; just like a `[sf::Color](sf-Color.md#color)`. All the functions that return an array of pixels follow this rule, and all parameters that you pass to `[sf::Image](#image)` functions (such as `loadFromMemory`) must use this representation as well.

A `[sf::Image](#image)` can be copied, but it is a heavy resource and if possible you should always use [const] references to pass or return them to avoid useless copies.

Usage example: 
```cpp
// Load an image file from a file
const sf::Image background("background.jpg");

// Create a 20x20 image filled with black color
sf::Image image({20, 20}, sf::Color::Black);

// Copy background on image at position (10, 10)
if (!image.copy(background, {10, 10}))
    return -1;

// Make the top-left pixel transparent
sf::Color color = image.getPixel({0, 0});
color.a = 0;
image.setPixel({0, 0}, color);

// Save the image to a file
if (!image.saveToFile("result.png"))
    return -1;
```

**See also**: `[sf::Texture](sf-Texture.md#texture-2)`

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`Image`](#image-1)  | Default constructor. |
|  | [`Image`](#image-2) `explicit` | Construct the image and fill it with a unique color. |
|  | [`Image`](#image-3)  | Construct the image from an array of pixels. |
|  | [`Image`](#image-4) `explicit` | Construct the image from a file on disk. |
|  | [`Image`](#image-5)  | Construct the image from a file in memory. |
|  | [`Image`](#image-6) `explicit` | Construct the image from a custom stream. |
| `void` | [`resize`](#resize)  | Resize the image and fill it with a unique color. |
| `void` | [`resize`](#resize-1)  | Resize the image from an array of pixels. |
| `bool` | [`loadFromFile`](#loadfromfile-1) `nodiscard` | Load the image from a file on disk. |
| `bool` | [`loadFromMemory`](#loadfrommemory-1) `nodiscard` | Load the image from a file in memory. |
| `bool` | [`loadFromStream`](#loadfromstream-1) `nodiscard` | Load the image from a custom stream. |
| `bool` | [`saveToFile`](#savetofile-1) `const` `nodiscard` | Save the image to a file on disk. |
| `std::optional< std::vector< std::uint8_t > >` | [`saveToMemory`](#savetomemory) `const` `nodiscard` | Save the image to a buffer in memory. |
| [`Vector2u`](sf.md#vector2u) | [`getSize`](#getsize-5) `const` `nodiscard` | Return the size (width and height) of the image. |
| `void` | [`createMaskFromColor`](#createmaskfromcolor)  | Create a transparency mask from a specified color-key. |
| `bool` | [`copy`](#copy) `nodiscard` | Copy pixels from another image onto this one. |
| `void` | [`setPixel`](#setpixel)  | Change the color of a pixel. |
| [`Color`](sf-Color.md#color) | [`getPixel`](#getpixel) `const` `nodiscard` | Get the color of a pixel. |
| `const std::uint8_t *` | [`getPixelsPtr`](#getpixelsptr) `const` `nodiscard` | Get a read-only pointer to the array of pixels. |
| `void` | [`flipHorizontally`](#fliphorizontally)  | Flip the image horizontally (left <-> right) |
| `void` | [`flipVertically`](#flipvertically)  | Flip the image vertically (top <-> bottom) |

---

{#image-1}

### Image

```cpp
Image() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Image.hpp:65

Default constructor.

Constructs an image with width 0 and height 0.

**See also**: `[resize](#resize)`

---

{#image-2}

### Image

`explicit`

```cpp
explicit Image(Vector2u size, Color color = Color::Black)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Image.hpp:74

Construct the image and fill it with a unique color.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `size` | [`Vector2u`](sf.md#vector2u) | Width and height of the image |
| `color` | [`Color`](sf-Color.md#color) | Fill color |

---

{#image-3}

### Image

```cpp
Image(Vector2u size, const std::uint8_t * pixels)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Image.hpp:87

Construct the image from an array of pixels.

The pixel array is assumed to contain 32-bits RGBA pixels, and have the given `size`. If not, this is an undefined behavior. If `pixels` is `nullptr`, an empty image is created.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `size` | [`Vector2u`](sf.md#vector2u) | Width and height of the image |
| `pixels` | `const std::uint8_t *` | Array of pixels to copy to the image |

---

{#image-4}

### Image

`explicit`

```cpp
explicit Image(const std::filesystem::path & filename)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Image.hpp:103

Construct the image from a file on disk.

The supported image formats are bmp, png, tga, jpg, gif, psd, hdr, pic and pnm. Some format options are not supported, like jpeg with arithmetic coding or ASCII pnm.

**See also**: `[loadFromFile](#loadfromfile-1)`, `[loadFromMemory](#loadfrommemory-1)`, `[loadFromStream](#loadfromstream-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `filename` | `const std::filesystem::path &` | Path of the image file to load |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if loading was unsuccessful |

---

{#image-5}

### Image

```cpp
Image(const void * data, std::size_t size)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Image.hpp:120

Construct the image from a file in memory.

The supported image formats are bmp, png, tga, jpg, gif, psd, hdr, pic and pnm. Some format options are not supported, like jpeg with arithmetic coding or ASCII pnm.

**See also**: `[loadFromFile](#loadfromfile-1)`, `[loadFromMemory](#loadfrommemory-1)`, `[loadFromStream](#loadfromstream-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `const void *` | Pointer to the file data in memory |
| `size` | `std::size_t` | Size of the data to load, in bytes |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if loading was unsuccessful |

---

{#image-6}

### Image

`explicit`

```cpp
explicit Image(InputStream & stream)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Image.hpp:136

Construct the image from a custom stream.

The supported image formats are bmp, png, tga, jpg, gif, psd, hdr, pic and pnm. Some format options are not supported, like jpeg with arithmetic coding or ASCII pnm.

**See also**: `[loadFromFile](#loadfromfile-1)`, `[loadFromMemory](#loadfrommemory-1)`, `[loadFromStream](#loadfromstream-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `stream` | [`InputStream`](sf-InputStream.md#inputstream) & | Source stream to read from |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if loading was unsuccessful |

---

{#resize}

### resize

```cpp
void resize(Vector2u size, Color color = Color::Black)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Image.hpp:145

Resize the image and fill it with a unique color.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `size` | [`Vector2u`](sf.md#vector2u) | Width and height of the image |
| `color` | [`Color`](sf-Color.md#color) | Fill color |

---

{#resize-1}

### resize

```cpp
void resize(Vector2u size, const std::uint8_t * pixels)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Image.hpp:158

Resize the image from an array of pixels.

The pixel array is assumed to contain 32-bits RGBA pixels, and have the given `size`. If not, this is an undefined behavior. If `pixels` is `nullptr`, an empty image is created.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `size` | [`Vector2u`](sf.md#vector2u) | Width and height of the image |
| `pixels` | `const std::uint8_t *` | Array of pixels to copy to the image |

---

{#loadfromfile-1}

### loadFromFile

`nodiscard`

```cpp
[[nodiscard]] bool loadFromFile(const std::filesystem::path & filename)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Image.hpp:175

Load the image from a file on disk.

The supported image formats are bmp, png, tga, jpg, gif, psd, hdr, pic and pnm. Some format options are not supported, like jpeg with arithmetic coding or ASCII pnm. If this function fails, the image is left unchanged.

#### Returns
`true` if loading was successful

**See also**: `[loadFromMemory](#loadfrommemory-1)`, `[loadFromStream](#loadfromstream-1)`, `[saveToFile](#savetofile-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `filename` | `const std::filesystem::path &` | Path of the image file to load |

---

{#loadfrommemory-1}

### loadFromMemory

`nodiscard`

```cpp
[[nodiscard]] bool loadFromMemory(const void * data, std::size_t size)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Image.hpp:193

Load the image from a file in memory.

The supported image formats are bmp, png, tga, jpg, gif, psd, hdr, pic and pnm. Some format options are not supported, like jpeg with arithmetic coding or ASCII pnm. If this function fails, the image is left unchanged.

#### Returns
`true` if loading was successful

**See also**: `[loadFromFile](#loadfromfile-1)`, `[loadFromStream](#loadfromstream-1)`, `[saveToMemory](#savetomemory)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `const void *` | Pointer to the file data in memory |
| `size` | `std::size_t` | Size of the data to load, in bytes |

---

{#loadfromstream-1}

### loadFromStream

`nodiscard`

```cpp
[[nodiscard]] bool loadFromStream(InputStream & stream)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Image.hpp:210

Load the image from a custom stream.

The supported image formats are bmp, png, tga, jpg, gif, psd, hdr, pic and pnm. Some format options are not supported, like jpeg with arithmetic coding or ASCII pnm. If this function fails, the image is left unchanged.

#### Returns
`true` if loading was successful

**See also**: `[loadFromFile](#loadfromfile-1)`, `[loadFromMemory](#loadfrommemory-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `stream` | [`InputStream`](sf-InputStream.md#inputstream) & | Source stream to read from |

---

{#savetofile-1}

### saveToFile

`const` `nodiscard`

```cpp
[[nodiscard]] bool saveToFile(const std::filesystem::path & filename) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Image.hpp:227

Save the image to a file on disk.

The format of the image is automatically deduced from the extension. The supported image formats are bmp, png, tga and jpg. The destination file is overwritten if it already exists. This function fails if the image is empty.

#### Returns
`true` if saving was successful

**See also**: `[saveToMemory](#savetomemory)`, `[loadFromFile](#loadfromfile-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `filename` | `const std::filesystem::path &` | Path of the file to save |

---

{#savetomemory}

### saveToMemory

`const` `nodiscard`

```cpp
[[nodiscard]] std::optional< std::vector< std::uint8_t > > saveToMemory(std::string_view format) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Image.hpp:245

Save the image to a buffer in memory.

The format of the image must be specified. The supported image formats are bmp, png, tga and jpg. This function fails if the image is empty, or if the format was invalid.

#### Returns
Buffer with encoded data if saving was successful, otherwise `std::nullopt`

**See also**: `[saveToFile](#savetofile-1)`, `[loadFromMemory](#loadfrommemory-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `format` | `std::string_view` | Encoding format to use |

---

{#getsize-5}

### getSize

`const` `nodiscard`

```cpp
[[nodiscard]] Vector2u getSize() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Image.hpp:253

Return the size (width and height) of the image.

#### Returns
Size of the image, in pixels

---

{#createmaskfromcolor}

### createMaskFromColor

```cpp
void createMaskFromColor(Color color, std::uint8_t alpha = 0)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Image.hpp:266

Create a transparency mask from a specified color-key.

This function sets the alpha value of every pixel matching the given color to `alpha` (0 by default), so that they become transparent.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `color` | [`Color`](sf-Color.md#color) | [Color](sf-Color.md#color) to make transparent |
| `alpha` | `std::uint8_t` | Alpha value to assign to transparent pixels |

---

{#copy}

### copy

`nodiscard`

```cpp
[[nodiscard]] bool copy(const Image & source, Vector2u dest, const IntRect & sourceRect = {}, bool applyAlpha = false)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Image.hpp:300

Copy pixels from another image onto this one.

This function does a slow pixel copy and should not be used intensively. It can be used to prepare a complex static image from several others, but if you need this kind of feature in real-time you'd better use `[sf::RenderTexture](sf-RenderTexture.md#rendertexture)`.

If `sourceRect` is empty, the whole image is copied. If `applyAlpha` is set to `true`, alpha blending is applied from the source pixels to the destination pixels using the **over** operator. If it is `false`, the source pixels are copied unchanged with their alpha value.

See [https://en.wikipedia.org/wiki/Alpha_compositing](https://en.wikipedia.org/wiki/Alpha_compositing) for details on the **over** operator.

Note that this function can fail if either image is invalid (i.e. zero-sized width or height), or if `sourceRect` is not within the boundaries of the `source` parameter, or if the destination area is out of the boundaries of this image.

On failure, the destination image is left unchanged.

#### Returns
`true` if the operation was successful, `false` otherwise

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `source` | const [`Image`](#image) & | Source image to copy |
| `dest` | [`Vector2u`](sf.md#vector2u) | Coordinates of the destination position |
| `sourceRect` | const [`IntRect`](sf.md#intrect) & | Sub-rectangle of the source image to copy |
| `applyAlpha` | `bool` | Should the copy take into account the source transparency? |

---

{#setpixel}

### setPixel

```cpp
void setPixel(Vector2u coords, Color color)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Image.hpp:315

Change the color of a pixel.

This function doesn't check the validity of the pixel coordinates, using out-of-range values will result in an undefined behavior.

**See also**: `[getPixel](#getpixel)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `coords` | [`Vector2u`](sf.md#vector2u) | Coordinates of pixel to change |
| `color` | [`Color`](sf-Color.md#color) | New color of the pixel |

---

{#getpixel}

### getPixel

`const` `nodiscard`

```cpp
[[nodiscard]] Color getPixel(Vector2u coords) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Image.hpp:331

Get the color of a pixel.

This function doesn't check the validity of the pixel coordinates, using out-of-range values will result in an undefined behavior.

#### Returns
[Color](sf-Color.md#color) of the pixel at given coordinates

**See also**: `[setPixel](#setpixel)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `coords` | [`Vector2u`](sf.md#vector2u) | Coordinates of pixel to change |

---

{#getpixelsptr}

### getPixelsPtr

`const` `nodiscard`

```cpp
[[nodiscard]] const std::uint8_t * getPixelsPtr() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Image.hpp:346

Get a read-only pointer to the array of pixels.

The returned value points to an array of RGBA pixels made of 8 bit integer components. The size of the array is `width * height * 4 ([getSize()](#getsize-5).x * [getSize()](#getsize-5).y * 4)`. Warning: the returned pointer may become invalid if you modify the image, so you should never store it for too long. If the image is empty, a null pointer is returned.

#### Returns
Read-only pointer to the array of pixels

---

{#fliphorizontally}

### flipHorizontally

```cpp
void flipHorizontally()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Image.hpp:352

Flip the image horizontally (left <-> right)

---

{#flipvertically}

### flipVertically

```cpp
void flipVertically()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Image.hpp:358

Flip the image vertically (top <-> bottom)

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`Vector2u`](sf.md#vector2u) | [`m_size`](#m_size-2)  | [Image](#image) size. |
| `std::vector< std::uint8_t >` | [`m_pixels`](#m_pixels)  | Pixels of the image. |

---

{#m_size-2}

### m_size

```cpp
Vector2u m_size
```

Type: [`Vector2u`](sf.md#vector2u)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Image.hpp:364

[Image](#image) size.

---

{#m_pixels}

### m_pixels

```cpp
std::vector< std::uint8_t > m_pixels
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Image.hpp:365

Pixels of the image.

