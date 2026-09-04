{#font}

# Font

```cpp
#include <Font.hpp>
```

```cpp
class Font
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:57

Class for loading and manipulating character fonts.

Fonts can be opened from a file, from memory or from a custom stream, and supports the most common types of fonts. See the openFromFile function for the complete list of supported formats.

Once it is opened, a `[sf::Font](#font)` instance provides three types of information about the font: 

* Global metrics, such as the line spacing 
* Per-glyph metrics, such as bounding box or kerning 
* Pixel representation of glyphs

Fonts alone are not very useful: they hold the font data but cannot make anything useful of it. To do so you need to use the `[sf::Text](sf-Text.md#text-1)` class, which is able to properly output text with several options such as character size, style, color, position, rotation, etc. This separation allows more flexibility and better performances: indeed a `[sf::Font](#font)` is a heavy resource, and any operation on it is slow (often too slow for real-time applications). On the other side, a `[sf::Text](sf-Text.md#text-1)` is a lightweight object which can combine the glyphs data and metrics of a `[sf::Font](#font)` to display any text on a render target. Note that it is also possible to bind several `[sf::Text](sf-Text.md#text-1)` instances to the same `[sf::Font](#font)`.

It is important to note that the `[sf::Text](sf-Text.md#text-1)` instance doesn't copy the font that it uses, it only keeps a reference to it. Thus, a `[sf::Font](#font)` must not be destructed while it is used by a `[sf::Text](sf-Text.md#text-1)` (i.e. never write a function that uses a local `[sf::Font](#font)` instance for creating a text).

Usage example: 
```cpp
// Open a new font
const sf::Font font("arial.ttf");

// Create a text which uses our font
sf::Text text1(font);
text1.setCharacterSize(30);
text1.setStyle(sf::Text::Regular);

// Create another text using the same font, but with different parameters
sf::Text text2(font);
text2.setCharacterSize(50);
text2.setStyle(sf::Text::Italic);
```

Apart from opening font files, and passing them to instances of `[sf::Text](sf-Text.md#text-1)`, you should normally not have to deal directly with this class. However, it may be useful to access the font metrics or rasterized glyphs for advanced usage.

Note that if the font is a bitmap font, it is not scalable, thus not all requested sizes will be available to use. This needs to be taken into consideration when using `[sf::Text](sf-Text.md#text-1)`. If you need to display text of a certain size, make sure the corresponding bitmap font that supports that size is used.

**See also**: `[sf::Text](sf-Text.md#text-1)`

## Friends

| Name | Description |
|------|-------------|
| [`Text`](#text)  |  |

---

{#text}

### Text

```cpp
friend class Text
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:446

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`Font`](#font-1)  | Default constructor. |
|  | [`Font`](#font-2) `explicit` | Construct the font from a file. |
|  | [`Font`](#font-3)  | Construct the font from a file in memory. |
|  | [`Font`](#font-4) `explicit` | Construct the font from a custom stream. |
| `bool` | [`openFromFile`](#openfromfile-3) `nodiscard` | Open the font from a file. |
| `bool` | [`openFromMemory`](#openfrommemory-2) `nodiscard` | Open the font from a file in memory. |
| `bool` | [`openFromStream`](#openfromstream-2) `nodiscard` | Open the font from a custom stream. |
| const [`Info`](sf-Font-Info.md#info-1) & | [`getInfo`](#getinfo) `const` `nodiscard` | Get the font information. |
| const [`Glyph`](sf-Glyph.md#glyph) & | [`getGlyphById`](#getglyphbyid) `const` `nodiscard` | Retrieve a glyph of the font by glyph ID. |
| const [`Glyph`](sf-Glyph.md#glyph) & | [`getGlyph`](#getglyph) `const` `nodiscard` | Retrieve a glyph of the font. |
| `bool` | [`hasGlyph`](#hasglyph) `const` `nodiscard` | Determine if this font has a glyph representing the requested code point. |
| `float` | [`getKerning`](#getkerning) `const` `nodiscard` | Get the kerning offset of two glyphs. |
| `float` | [`getKerning`](#getkerning-1) `const` `nodiscard` | Get the kerning offset of two glyphs. |
| `float` | [`getAscent`](#getascent) `const` `nodiscard` | Get the ascent. |
| `float` | [`getDescent`](#getdescent) `const` `nodiscard` | Get the descent. |
| `float` | [`getLineSpacing`](#getlinespacing) `const` `nodiscard` | Get the line spacing. |
| `float` | [`getUnderlinePosition`](#getunderlineposition) `const` `nodiscard` | Get the position of the underline. |
| `float` | [`getUnderlineThickness`](#getunderlinethickness) `const` `nodiscard` | Get the thickness of the underline. |
| const [`Texture`](sf-Texture.md#texture-2) & | [`getTexture`](#gettexture) `const` `nodiscard` | Retrieve the texture containing the loaded glyphs of a certain size. |
| `void` | [`setSmooth`](#setsmooth)  | Enable or disable the smooth filter. |
| `bool` | [`isSmooth`](#issmooth) `const` `nodiscard` | Tell whether the smooth filter is enabled or not. |

---

{#font-1}

### Font

```cpp
Font() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:78

Default constructor.

Construct an empty font that does not contain any glyphs.

---

{#font-2}

### Font

`explicit`

```cpp
explicit Font(const std::filesystem::path & filename)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:100

Construct the font from a file.

The supported font formats are: TrueType, Type 1, CFF, OpenType, SFNT, X11 PCF, Windows FNT, BDF, PFR and Type 42. Note that this function knows nothing about the standard fonts installed on the user's system, thus you can't load them directly.

:::warning
SFML cannot preload all the font data in this function, so the file has to remain accessible until the `[sf::Font](#font)` object opens a new font or is destroyed.

:::

**See also**: `[openFromFile](#openfromfile-3)`, `[openFromMemory](#openfrommemory-2)`, `[openFromStream](#openfromstream-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `filename` | `const std::filesystem::path &` | Path of the font file to open |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if opening was unsuccessful |

---

{#font-3}

### Font

```cpp
Font(const void * data, std::size_t sizeInBytes)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:121

Construct the font from a file in memory.

The supported font formats are: TrueType, Type 1, CFF, OpenType, SFNT, X11 PCF, Windows FNT, BDF, PFR and Type 42.

:::warning
SFML cannot preload all the font data in this function, so the buffer pointed by `data` has to remain valid until the `[sf::Font](#font)` object opens a new font or is destroyed.

:::

**See also**: `[openFromFile](#openfromfile-3)`, `[openFromMemory](#openfrommemory-2)`, `[openFromStream](#openfromstream-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `const void *` | Pointer to the file data in memory |
| `sizeInBytes` | `std::size_t` | Size of the data to load, in bytes |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if loading was unsuccessful |

---

{#font-4}

### Font

`explicit`

```cpp
explicit Font(InputStream & stream)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:143

Construct the font from a custom stream.

The supported font formats are: TrueType, Type 1, CFF, OpenType, SFNT, X11 PCF, Windows FNT, BDF, PFR and Type 42. Warning: SFML cannot preload all the font data in this function, so the contents of `stream` have to remain valid as long as the font is used.

:::warning
SFML cannot preload all the font data in this function, so the stream has to remain accessible until the `[sf::Font](#font)` object opens a new font or is destroyed.

:::

**See also**: `[openFromFile](#openfromfile-3)`, `[openFromMemory](#openfrommemory-2)`, `[openFromStream](#openfromstream-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `stream` | [`InputStream`](sf-InputStream.md#inputstream) & | Source stream to read from |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if loading was unsuccessful |

---

{#openfromfile-3}

### openFromFile

`nodiscard`

```cpp
[[nodiscard]] bool openFromFile(const std::filesystem::path & filename)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:165

Open the font from a file.

The supported font formats are: TrueType, Type 1, CFF, OpenType, SFNT, X11 PCF, Windows FNT, BDF, PFR and Type 42. Note that this function knows nothing about the standard fonts installed on the user's system, thus you can't load them directly.

:::warning
SFML cannot preload all the font data in this function, so the file has to remain accessible until the `[sf::Font](#font)` object opens a new font or is destroyed.

:::

#### Returns
`true` if opening succeeded, `false` if it failed

**See also**: `[openFromMemory](#openfrommemory-2)`, `[openFromStream](#openfromstream-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `filename` | `const std::filesystem::path &` | Path of the font file to load |

---

{#openfrommemory-2}

### openFromMemory

`nodiscard`

```cpp
[[nodiscard]] bool openFromMemory(const void * data, std::size_t sizeInBytes)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:186

Open the font from a file in memory.

The supported font formats are: TrueType, Type 1, CFF, OpenType, SFNT, X11 PCF, Windows FNT, BDF, PFR and Type 42.

:::warning
SFML cannot preload all the font data in this function, so the buffer pointed by `data` has to remain valid until the `[sf::Font](#font)` object opens a new font or is destroyed.

:::

#### Returns
`true` if opening succeeded, `false` if it failed

**See also**: `[openFromFile](#openfromfile-3)`, `[openFromStream](#openfromstream-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `const void *` | Pointer to the file data in memory |
| `sizeInBytes` | `std::size_t` | Size of the data to load, in bytes |

---

{#openfromstream-2}

### openFromStream

`nodiscard`

```cpp
[[nodiscard]] bool openFromStream(InputStream & stream)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:205

Open the font from a custom stream.

The supported font formats are: TrueType, Type 1, CFF, OpenType, SFNT, X11 PCF, Windows FNT, BDF, PFR and Type 42.

:::warning
SFML cannot preload all the font data in this function, so the stream has to remain accessible until the `[sf::Font](#font)` object opens a new font or is destroyed.

:::

#### Returns
`true` if opening succeeded, `false` if it failed

**See also**: `[openFromFile](#openfromfile-3)`, `[openFromMemory](#openfrommemory-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `stream` | [`InputStream`](sf-InputStream.md#inputstream) & | Source stream to read from |

---

{#getinfo}

### getInfo

`const` `nodiscard`

```cpp
[[nodiscard]] const Info & getInfo() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:213

Get the font information.

#### Returns
A structure that holds the font information

---

{#getglyphbyid}

### getGlyphById

`const` `nodiscard`

```cpp
[[nodiscard]] const Glyph & getGlyphById(std::uint32_t id, unsigned int characterSize, bool bold, float outlineThickness = 0) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:236

Retrieve a glyph of the font by glyph ID.

If the font is a bitmap font, not all character sizes might be available. If the glyph is not available at the requested size, an empty glyph is returned.

This function is only useful for getting the glyphs returned in the data from calling `shape`.

Be aware that using a negative value for the outline thickness will cause distorted rendering.

#### Returns
The glyph corresponding to `id` and `characterSize`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | `std::uint32_t` | ID of the glyph to get |
| `characterSize` | `unsigned int` | Reference character size |
| `bold` | `bool` | Retrieve the bold version or the regular one? |
| `outlineThickness` | `float` | Thickness of outline (when != 0 the glyph will not be filled) |

---

{#getglyph}

### getGlyph

`const` `nodiscard`

```cpp
[[nodiscard]] const Glyph & getGlyph(char32_t codePoint, unsigned int characterSize, bool bold, float outlineThickness = 0) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:263

Retrieve a glyph of the font.

If the font is a bitmap font, not all character sizes might be available. If the glyph is not available at the requested size, an empty glyph is returned.

You may want to use `hasGlyph` to determine if the glyph exists before requesting it. If the glyph does not exist, a font specific default is returned.

Be aware that using a negative value for the outline thickness will cause distorted rendering.

#### Returns
The glyph corresponding to `codePoint` and `characterSize`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `codePoint` | `char32_t` | Unicode code point of the character to get |
| `characterSize` | `unsigned int` | Reference character size |
| `bold` | `bool` | Retrieve the bold version or the regular one? |
| `outlineThickness` | `float` | Thickness of outline (when != 0 the glyph will not be filled) |

---

{#hasglyph}

### hasGlyph

`const` `nodiscard`

```cpp
[[nodiscard]] bool hasGlyph(char32_t codePoint) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:281

Determine if this font has a glyph representing the requested code point.

Most fonts only include a very limited selection of glyphs from specific Unicode subsets, like Latin, Cyrillic, or Asian characters.

While code points without representation will return a font specific default character, it might be useful to verify whether specific code points are included to determine whether a font is suited to display text in a specific language.

#### Returns
`true` if the codepoint has a glyph representation, `false` otherwise

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `codePoint` | `char32_t` | Unicode code point to check |

---

{#getkerning}

### getKerning

`const` `nodiscard`

```cpp
[[nodiscard]] float getKerning(std::uint32_t first, std::uint32_t second, unsigned int characterSize, bool bold = false) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:302

Get the kerning offset of two glyphs.

> Deprecated: Use the `getKerning(char32_t, char32_t, unsigned int, bool)` overload instead.

The kerning is an extra offset (negative) to apply between two glyphs when rendering them, to make the pair look more "natural". For example, the pair "AV" have a special kerning to make them closer than other characters. Most of the glyphs pairs have a kerning offset of zero, though.

#### Returns
Kerning value for `first` and `second`, in pixels

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `first` | `std::uint32_t` | Unicode code point of the first character |
| `second` | `std::uint32_t` | Unicode code point of the second character |
| `characterSize` | `unsigned int` | Reference character size |
| `bold` | `bool` | Retrieve the bold version or the regular one? |

---

{#getkerning-1}

### getKerning

`const` `nodiscard`

```cpp
[[nodiscard]] float getKerning(char32_t first, char32_t second, unsigned int characterSize, bool bold = false) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:325

Get the kerning offset of two glyphs.

The kerning is an extra offset (negative) to apply between two glyphs when rendering them, to make the pair look more "natural". For example, the pair "AV" have a special kerning to make them closer than other characters. Most of the glyphs pairs have a kerning offset of zero, though.

#### Returns
Kerning value for `first` and `second`, in pixels

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `first` | `char32_t` | Unicode code point of the first character |
| `second` | `char32_t` | Unicode code point of the second character |
| `characterSize` | `unsigned int` | Reference character size |
| `bold` | `bool` | Retrieve the bold version or the regular one? |

---

{#getascent}

### getAscent

`const` `nodiscard`

```cpp
[[nodiscard]] float getAscent(unsigned int characterSize) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:341

Get the ascent.

The ascent is the largest distance between the baseline and the top of all glyphs in the font.

Be aware that there is no uniform definition of how the ascent is calculated. It can vary from font to font.

#### Returns
Ascent, in pixels

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `characterSize` | `unsigned int` | Reference character size |

---

{#getdescent}

### getDescent

`const` `nodiscard`

```cpp
[[nodiscard]] float getDescent(unsigned int characterSize) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:361

Get the descent.

The descent is the largest distance between the baseline and the bottom of all glyphs in the font.

Be aware that there is no uniform definition of how the descent is calculated. It can vary from font to font.

The descent shares the same coordinate system as the ascent. This means that it will be negative for distances below the baseline.

#### Returns
Descent, in pixels

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `characterSize` | `unsigned int` | Reference character size |

---

{#getlinespacing}

### getLineSpacing

`const` `nodiscard`

```cpp
[[nodiscard]] float getLineSpacing(unsigned int characterSize) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:374

Get the line spacing.

Line spacing is the vertical offset to apply between two consecutive lines of text.

#### Returns
Line spacing, in pixels

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `characterSize` | `unsigned int` | Reference character size |

---

{#getunderlineposition}

### getUnderlinePosition

`const` `nodiscard`

```cpp
[[nodiscard]] float getUnderlinePosition(unsigned int characterSize) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:389

Get the position of the underline.

Underline position is the vertical offset to apply between the baseline and the underline.

#### Returns
Underline position, in pixels

**See also**: `[getUnderlineThickness](#getunderlinethickness)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `characterSize` | `unsigned int` | Reference character size |

---

{#getunderlinethickness}

### getUnderlineThickness

`const` `nodiscard`

```cpp
[[nodiscard]] float getUnderlineThickness(unsigned int characterSize) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:403

Get the thickness of the underline.

Underline thickness is the vertical size of the underline.

#### Returns
Underline thickness, in pixels

**See also**: `[getUnderlinePosition](#getunderlineposition)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `characterSize` | `unsigned int` | Reference character size |

---

{#gettexture}

### getTexture

`const` `nodiscard`

```cpp
[[nodiscard]] const Texture & getTexture(unsigned int characterSize) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:417

Retrieve the texture containing the loaded glyphs of a certain size.

The contents of the returned texture changes as more glyphs are requested, thus it is not very relevant. It is mainly used internally by `[sf::Text](sf-Text.md#text-1)`.

#### Returns
[Texture](sf-Texture.md#texture-2) containing the glyphs of the requested size

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `characterSize` | `unsigned int` | Reference character size |

---

{#setsmooth}

### setSmooth

```cpp
void setSmooth(bool smooth)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:433

Enable or disable the smooth filter.

When the filter is activated, the font appears smoother so that pixels are less noticeable. However if you want the font to look exactly the same as its source file, you should disable it. The smooth filter is enabled by default.

**See also**: `[isSmooth](#issmooth)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `smooth` | `bool` | `true` to enable smoothing, `false` to disable it |

---

{#issmooth}

### isSmooth

`const` `nodiscard`

```cpp
[[nodiscard]] bool isSmooth() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:443

Tell whether the smooth filter is enabled or not.

#### Returns
`true` if smoothing is enabled, `false` if it is disabled

**See also**: `[setSmooth](#setsmooth)`

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::shared_ptr< FontHandles >` | [`m_fontHandles`](#m_fonthandles)  | Shared information about the internal font instance. |
| `bool` | [`m_isSmooth`](#m_issmooth)  | Status of the smooth filter. |
| [`Info`](sf-Font-Info.md#info-1) | [`m_info`](#m_info)  | Information about the font. |
| `PageTable` | [`m_pages`](#m_pages)  | Table containing the glyphs pages by character size. |
| `std::vector< std::uint8_t >` | [`m_pixelBuffer`](#m_pixelbuffer)  | Pixel buffer holding a glyph's pixels before being written to the texture. |
| std::shared_ptr< [`InputStream`](sf-InputStream.md#inputstream) > | [`m_stream`](#m_stream-1)  | Stream for openFromFile and openFromMemory. |

---

{#m_fonthandles}

### m_fontHandles

```cpp
std::shared_ptr< FontHandles > m_fontHandles
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:565

Shared information about the internal font instance.

---

{#m_issmooth}

### m_isSmooth

```cpp
bool m_isSmooth {true}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:566

Status of the smooth filter.

---

{#m_info}

### m_info

```cpp
Info m_info
```

Type: [`Info`](sf-Font-Info.md#info-1)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:567

Information about the font.

---

{#m_pages}

### m_pages

```cpp
PageTable m_pages
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:568

Table containing the glyphs pages by character size.

---

{#m_pixelbuffer}

### m_pixelBuffer

```cpp
std::vector< std::uint8_t > m_pixelBuffer
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:569

Pixel buffer holding a glyph's pixels before being written to the texture.

---

{#m_stream-1}

### m_stream

```cpp
std::shared_ptr< InputStream > m_stream
```

Type: std::shared_ptr< [`InputStream`](sf-InputStream.md#inputstream) >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:570

Stream for openFromFile and openFromMemory.

## Private Methods

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`cleanup`](#cleanup)  | Free all the internal resources. |
| `bool` | [`openFromStreamImpl`](#openfromstreamimpl) `nodiscard` | Open from stream and print errors with custom message. |
| `Page &` | [`loadPage`](#loadpage) `const` | Find or create the glyphs page corresponding to the given character size. |
| [`Glyph`](sf-Glyph.md#glyph) | [`loadGlyph`](#loadglyph) `const` | Load a new glyph and store it in the cache. |
| [`IntRect`](sf.md#intrect) | [`findGlyphRect`](#findglyphrect) `const` | Find a suitable rectangle within the texture for a glyph. |
| `bool` | [`setCurrentSize`](#setcurrentsize) `const` `nodiscard` | Make sure that the given size is the current one. |
| `FontHandle` | [`getFontHandle`](#getfonthandle) `const` `nodiscard` | Get the current font handle. |

---

{#cleanup}

### cleanup

```cpp
void cleanup()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:486

Free all the internal resources.

---

{#openfromstreamimpl}

### openFromStreamImpl

`nodiscard`

```cpp
[[nodiscard]] bool openFromStreamImpl(InputStream & stream, std::string_view type)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:492

Open from stream and print errors with custom message.

---

{#loadpage}

### loadPage

`const`

```cpp
Page & loadPage(unsigned int characterSize) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:502

Find or create the glyphs page corresponding to the given character size.

#### Returns
The glyphs page corresponding to *characterSize*

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `characterSize` | `unsigned int` | Reference character size |

---

{#loadglyph}

### loadGlyph

`const`

```cpp
Glyph loadGlyph(std::uint32_t id, unsigned int characterSize, bool bold, float outlineThickness) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:515

Load a new glyph and store it in the cache.

#### Returns
The glyph corresponding to `id` and `characterSize`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | `std::uint32_t` | [Glyph](sf-Glyph.md#glyph) ID of the character to load |
| `characterSize` | `unsigned int` | Reference character size |
| `bold` | `bool` | Retrieve the bold version or the regular one? |
| `outlineThickness` | `float` | Thickness of outline (when != 0 the glyph will not be filled) |

---

{#findglyphrect}

### findGlyphRect

`const`

```cpp
IntRect findGlyphRect(Page & page, Vector2u size) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:526

Find a suitable rectangle within the texture for a glyph.

#### Returns
Found rectangle within the texture

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `page` | `Page &` | Page of glyphs to search in |
| `size` | [`Vector2u`](sf.md#vector2u) | Width and height of the rectangle |

---

{#setcurrentsize}

### setCurrentSize

`const` `nodiscard`

```cpp
[[nodiscard]] bool setCurrentSize(unsigned int characterSize) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:536

Make sure that the given size is the current one.

#### Returns
`true` on success, `false` if any error happened

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `characterSize` | `unsigned int` | Reference character size |

---

{#getfonthandle}

### getFontHandle

`const` `nodiscard`

```cpp
[[nodiscard]] FontHandle getFontHandle() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:554

Get the current font handle.

This is used internally by [Text](sf-Text.md#text-1) to shape unicode text.

:::warning
Using this handle without care may result in unwanted side effects, as it could interfere with SFMLs internal usage!

:::

#### Returns
The currently active font handle or nullptr if there is none

