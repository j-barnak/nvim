{#text-1}

# Text

```cpp
#include <Text.hpp>
```

```cpp
class Text
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:60

> **Inherits:** [`Drawable`](sf-Drawable.md#drawable), [`Transformable`](sf-Transformable.md#transformable)

Graphical text that can be drawn to a render target.

`[sf::Text](#text-1)` is a drawable class that allows to easily display some text with custom style and color on a render target.

It inherits all the functions from `[sf::Transformable](sf-Transformable.md#transformable)`: position, rotation, scale, origin. It also adds text-specific properties such as the font to use, the character size, the font style (bold, italic, underlined and strike through), the text color, the outline thickness, the outline color, the character spacing, the line spacing and the text to display of course. It also provides convenience functions to calculate the graphical size of the text, or to get the global position of a given character.

`[sf::Text](#text-1)` works in combination with the `[sf::Font](sf-Font.md#font)` class, which loads and provides the glyphs (visual characters) of a given font.

The separation of `[sf::Font](sf-Font.md#font)` and `[sf::Text](#text-1)` allows more flexibility and better performances: indeed a `[sf::Font](sf-Font.md#font)` is a heavy resource, and any operation on it is slow (often too slow for real-time applications). On the other side, a `[sf::Text](#text-1)` is a lightweight object which can combine the glyphs data and metrics of a `[sf::Font](sf-Font.md#font)` to display any text on a render target.

It is important to note that the `[sf::Text](#text-1)` instance doesn't copy the font that it uses, it only keeps a reference to it. Thus, a `[sf::Font](sf-Font.md#font)` must not be destructed while it is used by a `[sf::Text](#text-1)` (i.e. never write a function that uses a local `[sf::Font](sf-Font.md#font)` instance for creating a text).

See also the note on coordinates and undistorted rendering in `[sf::Transformable](sf-Transformable.md#transformable)`.

Usage example: 
```cpp
// Open a font
const sf::Font font("arial.ttf");

// Create a text
sf::Text text(font, "hello");
text.setCharacterSize(30);
text.setStyle(sf::Text::Bold);
text.setFillColor(sf::Color::Red);

// Draw it
window.draw(text);
```

**See also**: `[sf::Font](sf-Font.md#font)`, `[sf::Transformable](sf-Transformable.md#transformable)`

## List of all members

| Name | Kind | Owner |
|------|------|-------|
| [`Text`](#text-2) | `function` | Declared here |
| [`Text`](#text-3) | `function` | Declared here |
| [`setString`](#setstring-1) | `function` | Declared here |
| [`setFont`](#setfont) | `function` | Declared here |
| [`setFont`](#setfont-1) | `function` | Declared here |
| [`setCharacterSize`](#setcharactersize) | `function` | Declared here |
| [`setLineSpacing`](#setlinespacing) | `function` | Declared here |
| [`setLetterSpacing`](#setletterspacing) | `function` | Declared here |
| [`setStyle`](#setstyle) | `function` | Declared here |
| [`setFillColor`](#setfillcolor-1) | `function` | Declared here |
| [`setOutlineColor`](#setoutlinecolor-1) | `function` | Declared here |
| [`setOutlineThickness`](#setoutlinethickness-1) | `function` | Declared here |
| [`setLineAlignment`](#setlinealignment) | `function` | Declared here |
| [`setTextOrientation`](#settextorientation) | `function` | Declared here |
| [`getString`](#getstring-1) | `function` | Declared here |
| [`getFont`](#getfont) | `function` | Declared here |
| [`getCharacterSize`](#getcharactersize) | `function` | Declared here |
| [`getLetterSpacing`](#getletterspacing) | `function` | Declared here |
| [`getLineSpacing`](#getlinespacing-1) | `function` | Declared here |
| [`getStyle`](#getstyle) | `function` | Declared here |
| [`getFillColor`](#getfillcolor-1) | `function` | Declared here |
| [`getOutlineColor`](#getoutlinecolor-1) | `function` | Declared here |
| [`getOutlineThickness`](#getoutlinethickness-1) | `function` | Declared here |
| [`getLineAlignment`](#getlinealignment) | `function` | Declared here |
| [`getTextOrientation`](#gettextorientation) | `function` | Declared here |
| [`findCharacterPos`](#findcharacterpos) | `function` | Declared here |
| [`getShapedGlyphs`](#getshapedglyphs) | `function` | Declared here |
| [`getClusterGrouping`](#getclustergrouping) | `function` | Declared here |
| [`setClusterGrouping`](#setclustergrouping) | `function` | Declared here |
| [`setGlyphPreProcessor`](#setglyphpreprocessor) | `function` | Declared here |
| [`getVertexData`](#getvertexdata) | `function` | Declared here |
| [`getOutlineVertexData`](#getoutlinevertexdata) | `function` | Declared here |
| [`getLocalBounds`](#getlocalbounds-2) | `function` | Declared here |
| [`getGlobalBounds`](#getglobalbounds-2) | `function` | Declared here |
| [`Style`](Style.md#style) | `enum` | Declared here |
| [`LineAlignment`](LineAlignment.md#linealignment) | `enum` | Declared here |
| [`ClusterGrouping`](ClusterGrouping.md#clustergrouping) | `enum` | Declared here |
| [`TextDirection`](TextDirection.md#textdirection) | `enum` | Declared here |
| [`TextOrientation`](TextOrientation.md#textorientation) | `enum` | Declared here |
| [`GlyphPreProcessor`](#glyphpreprocessor) | `typedef` | Declared here |
| [`m_string`](#m_string-1) | `variable` | Declared here |
| [`m_font`](#m_font) | `variable` | Declared here |
| [`m_characterSize`](#m_charactersize) | `variable` | Declared here |
| [`m_letterSpacingFactor`](#m_letterspacingfactor) | `variable` | Declared here |
| [`m_lineSpacingFactor`](#m_linespacingfactor) | `variable` | Declared here |
| [`m_style`](#m_style) | `variable` | Declared here |
| [`m_fillColor`](#m_fillcolor-1) | `variable` | Declared here |
| [`m_outlineColor`](#m_outlinecolor-1) | `variable` | Declared here |
| [`m_outlineThickness`](#m_outlinethickness-1) | `variable` | Declared here |
| [`m_lineAlignment`](#m_linealignment) | `variable` | Declared here |
| [`m_textOrientation`](#m_textorientation) | `variable` | Declared here |
| [`m_clusterGrouping`](#m_clustergrouping) | `variable` | Declared here |
| [`m_glyphPreProcessor`](#m_glyphpreprocessor) | `variable` | Declared here |
| [`m_vertices`](#m_vertices-2) | `variable` | Declared here |
| [`m_outlineVertices`](#m_outlinevertices-1) | `variable` | Declared here |
| [`m_bounds`](#m_bounds-1) | `variable` | Declared here |
| [`m_geometryNeedUpdate`](#m_geometryneedupdate) | `variable` | Declared here |
| [`m_fontTextureId`](#m_fonttextureid) | `variable` | Declared here |
| [`m_glyphs`](#m_glyphs) | `variable` | Declared here |
| [`m_shaper`](#m_shaper) | `variable` | Declared here |
| [`draw`](#draw-7) | `function` | Declared here |
| [`ensureGeometryUpdate`](#ensuregeometryupdate) | `function` | Declared here |
| [`RenderTarget`](sf-Drawable.md#rendertarget) | `friend` | Inherited from [`Drawable`](sf-Drawable.md#drawable) |
| [`~Drawable`](sf-Drawable.md#drawable-1) | `function` | Inherited from [`Drawable`](sf-Drawable.md#drawable) |
| [`draw`](sf-Drawable.md#draw) | `function` | Inherited from [`Drawable`](sf-Drawable.md#drawable) |
| [`Transformable`](sf-Transformable.md#transformable-1) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`~Transformable`](sf-Transformable.md#transformable-2) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`setPosition`](sf-Transformable.md#setposition-5) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`setRotation`](sf-Transformable.md#setrotation) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`setScale`](sf-Transformable.md#setscale) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`setOrigin`](sf-Transformable.md#setorigin) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`getPosition`](sf-Transformable.md#getposition-7) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`getRotation`](sf-Transformable.md#getrotation) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`getScale`](sf-Transformable.md#getscale) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`getOrigin`](sf-Transformable.md#getorigin) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`move`](sf-Transformable.md#move) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`rotate`](sf-Transformable.md#rotate-2) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`scale`](sf-Transformable.md#scale-2) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`getTransform`](sf-Transformable.md#gettransform) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`getInverseTransform`](sf-Transformable.md#getinversetransform) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`m_origin`](sf-Transformable.md#m_origin) | `variable` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`m_position`](sf-Transformable.md#m_position) | `variable` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`m_rotation`](sf-Transformable.md#m_rotation) | `variable` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`m_scale`](sf-Transformable.md#m_scale) | `variable` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`m_transform`](sf-Transformable.md#m_transform) | `variable` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`m_inverseTransform`](sf-Transformable.md#m_inversetransform) | `variable` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`m_transformNeedUpdate`](sf-Transformable.md#m_transformneedupdate) | `variable` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`m_inverseTransformNeedUpdate`](sf-Transformable.md#m_inversetransformneedupdate) | `variable` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |

## Inherited from [`Drawable`](sf-Drawable.md#drawable)

| Kind | Name | Description |
|------|------|-------------|
| `friend` | [`RenderTarget`](sf-Drawable.md#rendertarget)  |  |
| `function` | [`~Drawable`](sf-Drawable.md#drawable-1) `virtual` | Virtual destructor. |
| `function` | [`draw`](sf-Drawable.md#draw) `virtual` `const` | Draw the object to a render target. |

## Inherited from [`Transformable`](sf-Transformable.md#transformable)

| Kind | Name | Description |
|------|------|-------------|
| `function` | [`Transformable`](sf-Transformable.md#transformable-1)  | Default constructor. |
| `function` | [`~Transformable`](sf-Transformable.md#transformable-2) `virtual` | Virtual destructor. |
| `function` | [`setPosition`](sf-Transformable.md#setposition-5)  | set the position of the object |
| `function` | [`setRotation`](sf-Transformable.md#setrotation)  | set the orientation of the object |
| `function` | [`setScale`](sf-Transformable.md#setscale)  | set the scale factors of the object |
| `function` | [`setOrigin`](sf-Transformable.md#setorigin)  | set the local origin of the object |
| `function` | [`getPosition`](sf-Transformable.md#getposition-7) `const` `nodiscard` | get the position of the object |
| `function` | [`getRotation`](sf-Transformable.md#getrotation) `const` `nodiscard` | get the orientation of the object |
| `function` | [`getScale`](sf-Transformable.md#getscale) `const` `nodiscard` | get the current scale of the object |
| `function` | [`getOrigin`](sf-Transformable.md#getorigin) `const` `nodiscard` | get the local origin of the object |
| `function` | [`move`](sf-Transformable.md#move)  | Move the object by a given offset. |
| `function` | [`rotate`](sf-Transformable.md#rotate-2)  | Rotate the object. |
| `function` | [`scale`](sf-Transformable.md#scale-2)  | Scale the object. |
| `function` | [`getTransform`](sf-Transformable.md#gettransform) `const` `nodiscard` | get the combined transform of the object |
| `function` | [`getInverseTransform`](sf-Transformable.md#getinversetransform) `const` `nodiscard` | get the inverse of the combined transform of the object |
| `variable` | [`m_origin`](sf-Transformable.md#m_origin)  | Origin of translation/rotation/scaling of the object. |
| `variable` | [`m_position`](sf-Transformable.md#m_position)  | Position of the object in the 2D world. |
| `variable` | [`m_rotation`](sf-Transformable.md#m_rotation)  | Orientation of the object. |
| `variable` | [`m_scale`](sf-Transformable.md#m_scale)  | Scale of the object. |
| `variable` | [`m_transform`](sf-Transformable.md#m_transform)  | Combined transformation of the object. |
| `variable` | [`m_inverseTransform`](sf-Transformable.md#m_inversetransform)  | Combined transformation of the object. |
| `variable` | [`m_transformNeedUpdate`](sf-Transformable.md#m_transformneedupdate)  | Does the transform need to be recomputed? |
| `variable` | [`m_inverseTransformNeedUpdate`](sf-Transformable.md#m_inversetransformneedupdate)  | Does the transform need to be recomputed? |

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`Text`](#text-2)  | Construct the text from a string, font and size. |
|  | [`Text`](#text-3)  | Disallow construction from a temporary font. |
| `void` | [`setString`](#setstring-1)  | Set the text's string. |
| `void` | [`setFont`](#setfont)  | Set the text's font. |
| `void` | [`setFont`](#setfont-1)  | Disallow setting from a temporary font. |
| `void` | [`setCharacterSize`](#setcharactersize)  | Set the character size. |
| `void` | [`setLineSpacing`](#setlinespacing)  | Set the line spacing factor. |
| `void` | [`setLetterSpacing`](#setletterspacing)  | Set the letter spacing factor. |
| `void` | [`setStyle`](#setstyle)  | Set the text's style. |
| `void` | [`setFillColor`](#setfillcolor-1)  | Set the fill color of the text. |
| `void` | [`setOutlineColor`](#setoutlinecolor-1)  | Set the outline color of the text. |
| `void` | [`setOutlineThickness`](#setoutlinethickness-1)  | Set the thickness of the text's outline. |
| `void` | [`setLineAlignment`](#setlinealignment)  | Set the line alignment for a multi-line text. |
| `void` | [`setTextOrientation`](#settextorientation)  | Set the text orientation. |
| const [`String`](sf-String.md#string) & | [`getString`](#getstring-1) `const` `nodiscard` | Get the text's string. |
| const [`Font`](sf-Font.md#font) & | [`getFont`](#getfont) `const` `nodiscard` | Get the text's font. |
| `unsigned int` | [`getCharacterSize`](#getcharactersize) `const` `nodiscard` | Get the character size. |
| `float` | [`getLetterSpacing`](#getletterspacing) `const` `nodiscard` | Get the size of the letter spacing factor. |
| `float` | [`getLineSpacing`](#getlinespacing-1) `const` `nodiscard` | Get the size of the line spacing factor. |
| `std::uint32_t` | [`getStyle`](#getstyle) `const` `nodiscard` | Get the text's style. |
| [`Color`](sf-Color.md#color) | [`getFillColor`](#getfillcolor-1) `const` `nodiscard` | Get the fill color of the text. |
| [`Color`](sf-Color.md#color) | [`getOutlineColor`](#getoutlinecolor-1) `const` `nodiscard` | Get the outline color of the text. |
| `float` | [`getOutlineThickness`](#getoutlinethickness-1) `const` `nodiscard` | Get the outline thickness of the text. |
| [`LineAlignment`](LineAlignment.md#linealignment) | [`getLineAlignment`](#getlinealignment) `const` | Get the line alignment for a multi-line text. |
| [`TextOrientation`](TextOrientation.md#textorientation) | [`getTextOrientation`](#gettextorientation) `const` | Get the text orientation. |
| [`Vector2f`](sf.md#vector2f) | [`findCharacterPos`](#findcharacterpos) `const` `nodiscard` | Return the position of the `index`-th character. |
| const std::vector< [`ShapedGlyph`](sf-Text-ShapedGlyph.md#shapedglyph) > & | [`getShapedGlyphs`](#getshapedglyphs) `const` `nodiscard` | Return a list of shaped glyphs that make up the text. |
| [`ClusterGrouping`](ClusterGrouping.md#clustergrouping) | [`getClusterGrouping`](#getclustergrouping) `const` `nodiscard` | Return the cluster grouping algorithm in use. |
| `void` | [`setClusterGrouping`](#setclustergrouping)  | Set the cluster grouping algorithm to use. |
| `void` | [`setGlyphPreProcessor`](#setglyphpreprocessor)  | Set the glyph pre-processor to be called per glyph. |
| [`VertexArray`](sf-VertexArray.md#vertexarray) & | [`getVertexData`](#getvertexdata) `const` | Get a reference to the vertex data of this text. |
| [`VertexArray`](sf-VertexArray.md#vertexarray) & | [`getOutlineVertexData`](#getoutlinevertexdata) `const` | Get a reference to the outline vertex data of this text. |
| [`FloatRect`](sf.md#floatrect) | [`getLocalBounds`](#getlocalbounds-2) `const` `nodiscard` | Get the local bounding rectangle of the entity. |
| [`FloatRect`](sf.md#floatrect) | [`getGlobalBounds`](#getglobalbounds-2) `const` `nodiscard` | Get the global bounding rectangle of the entity. |

---

{#text-2}

### Text

```cpp
Text(const Font & font, String string = "", unsigned int characterSize = 30)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:154

Construct the text from a string, font and size.

Note that if the used font is a bitmap font, it is not scalable, thus not all requested sizes will be available to use. This needs to be taken into consideration when setting the character size. If you need to display text of a certain size, make sure the corresponding bitmap font that supports that size is used.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `font` | const [`Font`](sf-Font.md#font) & | [Font](sf-Font.md#font) used to draw the string |
| `string` | [`String`](sf-String.md#string) | [Text](#text-1) assigned to the string |
| `characterSize` | `unsigned int` | Base size of characters, in pixels |

---

{#text-3}

### Text

```cpp
Text(const Font && font, String string = "", unsigned int characterSize = 30) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:160

Disallow construction from a temporary font.

---

{#setstring-1}

### setString

```cpp
void setString(const String & string)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:181

Set the text's string.

The `string` argument is a `[sf::String](sf-String.md#string)`, which can automatically be constructed from standard string types. So, the following calls are all valid: 
```cpp
text.setString("hello");
text.setString(L"hello");
text.setString(std::string("hello"));
text.setString(std::wstring(L"hello"));
```
 A text's string is empty by default.

**See also**: `[getString](#getstring-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `string` | const [`String`](sf-String.md#string) & | New string |

---

{#setfont}

### setFont

```cpp
void setFont(const Font & font)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:198

Set the text's font.

The `font` argument refers to a font that must exist as long as the text uses it. Indeed, the text doesn't store its own copy of the font, but rather keeps a pointer to the one that you passed to this function. If the font is destroyed and the text tries to use it, the behavior is undefined.

**See also**: `[getFont](#getfont)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `font` | const [`Font`](sf-Font.md#font) & | New font |

---

{#setfont-1}

### setFont

```cpp
void setFont(const Font && font) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:204

Disallow setting from a temporary font.

---

{#setcharactersize}

### setCharacterSize

```cpp
void setCharacterSize(unsigned int size)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:223

Set the character size.

The default size is 30.

Note that if the used font is a bitmap font, it is not scalable, thus not all requested sizes will be available to use. This needs to be taken into consideration when setting the character size. If you need to display text of a certain size, make sure the corresponding bitmap font that supports that size is used.

**See also**: `[getCharacterSize](#getcharactersize)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `size` | `unsigned int` | New character size, in pixels |

---

{#setlinespacing}

### setLineSpacing

```cpp
void setLineSpacing(float spacingFactor)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:237

Set the line spacing factor.

The default spacing between lines is defined by the font. This method enables you to set a factor for the spacing between lines. By default the line spacing factor is 1.

**See also**: `[getLineSpacing](#getlinespacing-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `spacingFactor` | `float` | New line spacing factor |

---

{#setletterspacing}

### setLetterSpacing

```cpp
void setLetterSpacing(float spacingFactor)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:256

Set the letter spacing factor.

The default spacing between letters is defined by the font. This factor doesn't directly apply to the existing spacing between each character, it rather adds a fixed space between them which is calculated from the font metrics and the character size. Note that factors below 1 (including negative numbers) bring characters closer to each other. By default the letter spacing factor is 1.

**See also**: `[getLetterSpacing](#getletterspacing)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `spacingFactor` | `float` | New letter spacing factor |

---

{#setstyle}

### setStyle

```cpp
void setStyle(std::uint32_t style)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:270

Set the text's style.

You can pass a combination of one or more styles, for example `[sf::Text::Bold](#classsf_1_1Text_1aa8add4aef484c6e6b20faff07452bd82af1b47f98fb1e10509ba930a596987171) | [sf::Text::Italic](#classsf_1_1Text_1aa8add4aef484c6e6b20faff07452bd82aee249eb803848723c542c2062ebe69d8)`. The default style is `[sf::Text::Regular](#classsf_1_1Text_1aa8add4aef484c6e6b20faff07452bd82a2af9ae5e1cda126570f744448e0caa32)`.

**See also**: `[getStyle](#getstyle)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `style` | `std::uint32_t` | New style |

---

{#setfillcolor-1}

### setFillColor

```cpp
void setFillColor(Color color)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:284

Set the fill color of the text.

By default, the text's fill color is opaque white. Setting the fill color to a transparent color with an outline will cause the outline to be displayed in the fill area of the text.

**See also**: `[getFillColor](#getfillcolor-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `color` | [`Color`](sf-Color.md#color) | New fill color of the text |

---

{#setoutlinecolor-1}

### setOutlineColor

```cpp
void setOutlineColor(Color color)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:296

Set the outline color of the text.

By default, the text's outline color is opaque black.

**See also**: `[getOutlineColor](#getoutlinecolor-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `color` | [`Color`](sf-Color.md#color) | New outline color of the text |

---

{#setoutlinethickness-1}

### setOutlineThickness

```cpp
void setOutlineThickness(float thickness)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:311

Set the thickness of the text's outline.

By default, the outline thickness is 0.

Be aware that using a negative value for the outline thickness will cause distorted rendering.

**See also**: `[getOutlineThickness](#getoutlinethickness-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `thickness` | `float` | New outline thickness, in pixels |

---

{#setlinealignment}

### setLineAlignment

```cpp
void setLineAlignment(LineAlignment lineAlignment)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:329

Set the line alignment for a multi-line text.

By default, the lines will be aligned according to the direction of the line's script. Left-to-right scripts will be aligned to the left and right-to-left scripts will be aligned to the right.

Forcing alignment will ignore script direction and always align according to the requested line alignment.

**See also**: `[getLineAlignment](#getlinealignment)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `lineAlignment` | [`LineAlignment`](LineAlignment.md#linealignment) | New line alignment |

---

{#settextorientation}

### setTextOrientation

```cpp
void setTextOrientation(TextOrientation textOrientation)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:354

Set the text orientation.

By default, the lines will have horizontal orientation.

Be aware that most fonts don't natively support vertical orientations. Fonts that are the most likely to natively support vertical orientations are those whose scripts also support vertical orientations e.g. east asian scripts.

If a font does not natively support vertical orientation, vertical metrics might still be provided for shaping. In this case, they are very likely to be emulated and might not result in good visual output.

Some metrics such as advance and baseline position will be rotated so they match the vertical axis.

**See also**: `[getTextOrientation](#gettextorientation)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `textOrientation` | [`TextOrientation`](TextOrientation.md#textorientation) | New text orientation |

---

{#getstring-1}

### getString

`const` `nodiscard`

```cpp
[[nodiscard]] const String & getString() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:373

Get the text's string.

The returned string is a `[sf::String](sf-String.md#string)`, which can automatically be converted to standard string types. So, the following lines of code are all valid: 
```cpp
sf::String   s1 = text.getString();
std::string  s2 = text.getString();
std::wstring s3 = text.getString();
```

#### Returns
[Text](#text-1)'s string

**See also**: `[setString](#setstring-1)`

---

{#getfont}

### getFont

`const` `nodiscard`

```cpp
[[nodiscard]] const Font & getFont() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:386

Get the text's font.

The returned reference is const, which means that you cannot modify the font when you get it from this function.

#### Returns
Reference to the text's font

**See also**: `[setFont](#setfont)`

---

{#getcharactersize}

### getCharacterSize

`const` `nodiscard`

```cpp
[[nodiscard]] unsigned int getCharacterSize() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:396

Get the character size.

#### Returns
Size of the characters, in pixels

**See also**: `[setCharacterSize](#setcharactersize)`

---

{#getletterspacing}

### getLetterSpacing

`const` `nodiscard`

```cpp
[[nodiscard]] float getLetterSpacing() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:406

Get the size of the letter spacing factor.

#### Returns
Size of the letter spacing factor

**See also**: `[setLetterSpacing](#setletterspacing)`

---

{#getlinespacing-1}

### getLineSpacing

`const` `nodiscard`

```cpp
[[nodiscard]] float getLineSpacing() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:416

Get the size of the line spacing factor.

#### Returns
Size of the line spacing factor

**See also**: `[setLineSpacing](#setlinespacing)`

---

{#getstyle}

### getStyle

`const` `nodiscard`

```cpp
[[nodiscard]] std::uint32_t getStyle() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:426

Get the text's style.

#### Returns
[Text](#text-1)'s style

**See also**: `[setStyle](#setstyle)`

---

{#getfillcolor-1}

### getFillColor

`const` `nodiscard`

```cpp
[[nodiscard]] Color getFillColor() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:436

Get the fill color of the text.

#### Returns
Fill color of the text

**See also**: `[setFillColor](#setfillcolor-1)`

---

{#getoutlinecolor-1}

### getOutlineColor

`const` `nodiscard`

```cpp
[[nodiscard]] Color getOutlineColor() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:446

Get the outline color of the text.

#### Returns
Outline color of the text

**See also**: `[setOutlineColor](#setoutlinecolor-1)`

---

{#getoutlinethickness-1}

### getOutlineThickness

`const` `nodiscard`

```cpp
[[nodiscard]] float getOutlineThickness() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:456

Get the outline thickness of the text.

#### Returns
Outline thickness of the text, in pixels

**See also**: `[setOutlineThickness](#setoutlinethickness-1)`

---

{#getlinealignment}

### getLineAlignment

`const`

```cpp
LineAlignment getLineAlignment() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:466

Get the line alignment for a multi-line text.

#### Returns
Line alignment

**See also**: `[setLineAlignment](#setlinealignment)`

---

{#gettextorientation}

### getTextOrientation

`const`

```cpp
TextOrientation getTextOrientation() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:476

Get the text orientation.

#### Returns
[Text](#text-1) orientation

**See also**: `[setTextOrientation](#settextorientation)`

---

{#findcharacterpos}

### findCharacterPos

`const` `nodiscard`

```cpp
[[nodiscard]] Vector2f findCharacterPos(std::size_t index) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:495

Return the position of the `index`-th character.

> Deprecated: Use `[getShapedGlyphs()](#getshapedglyphs)` instead.

This function computes the visual position of a character from its index in the string. The returned position is in global coordinates (translation, rotation, scale and origin are applied). If `index` is out of range, the position of the end of the string is returned.

#### Returns
Position of the character

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `index` | `std::size_t` | Index of the character |

---

{#getshapedglyphs}

### getShapedGlyphs

`const` `nodiscard`

```cpp
[[nodiscard]] const std::vector< ShapedGlyph > & getShapedGlyphs() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:542

Return a list of shaped glyphs that make up the text.

The result of shaping i.e. positioning individual glyphs based on the properties of the font and the input text is a sequence of shaped glyphs that each have a collection of properties.

In addition to the glyph information that is available by looking up a glyph from a font, the glyph position, glyph cluster ID and direction of the text represented by the glyph is provided.

When specifying unicode text, multiple unicode codepoints might combine to form e.g. a ligature such as æ or base-and-mark sequence such as é which are composed of multiple individual glyphs. These combinations are known as grapheme clusters. When segmenting text into grapheme clusters, each cluster identifies a complete unit of text that will be drawn. There are other methods of segmenting text into clusters e.g. without combining marks. Character cluster segmentation is used as the default. A single grapheme can be represented by an individual codepoint or by a composition of codepoints e.g. an e as the base and an accent as the mark which together compose the grapheme é. The cluster groups that result from shaping depend on whether the input text provides composed codepoints or decomposed codepoints. This is an advanced topic known as unicode normalisation.

When positioning e.g. a cursor within the text, grapheme clusters can be treated as the basic units of which the text is composed and not subdivided into their individual components or glyphs. If positioning of the cursor within a single grapheme e.g. a ligature is required, a more fine-grained cluster segmentation algorithm should be used.

The returned glyph positions are in local coordinates (translation, rotation, scale and origin are not applied).

#### Returns
List of shaped glyphs that make up the text

**See also**: `[setClusterGrouping](#setclustergrouping)`

---

{#getclustergrouping}

### getClusterGrouping

`const` `nodiscard`

```cpp
[[nodiscard]] ClusterGrouping getClusterGrouping() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:550

Return the cluster grouping algorithm in use.

#### Returns
The cluster grouping algorithm in use

---

{#setclustergrouping}

### setClusterGrouping

```cpp
void setClusterGrouping(ClusterGrouping clusterGrouping)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:566

Set the cluster grouping algorithm to use.

By default, character cluster grouping is used.

Character cluster grouping is good enough to be able to position cursors in most scenarios. If more coarse-grained grouping is required, grapheme grouping can be selected.

Cluster grouping can also be disabled if necessary.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `clusterGrouping` | [`ClusterGrouping`](ClusterGrouping.md#clustergrouping) | The cluster grouping algorithm to use |

---

{#setglyphpreprocessor}

### setGlyphPreProcessor

```cpp
void setGlyphPreProcessor(GlyphPreProcessor glyphPreProcessor)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:718

Set the glyph pre-processor to be called per glyph.

The glyph pre-processor is a callable that will be called with glyph data to be pre-processed.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `glyphPreProcessor` | [`GlyphPreProcessor`](#glyphpreprocessor) | The glyph pre-processor to be called per glyph, pass an empty pre-processor to disable pre-processing |

---

{#getvertexdata}

### getVertexData

`const`

```cpp
VertexArray & getVertexData() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:730

Get a reference to the vertex data of this text.

The vertex data is regenerated by the text whenever it is necessary. Any changes made to the vertex data will be discarded whenever this happens.

#### Returns
Reference to the vertex data of this text

---

{#getoutlinevertexdata}

### getOutlineVertexData

`const`

```cpp
VertexArray & getOutlineVertexData() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:742

Get a reference to the outline vertex data of this text.

The outline vertex data is regenerated by the text whenever it is necessary. Any changes made to the outline vertex data will be discarded whenever this happens.

#### Returns
Reference to the vertex data of this text

---

{#getlocalbounds-2}

### getLocalBounds

`const` `nodiscard`

```cpp
[[nodiscard]] FloatRect getLocalBounds() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:756

Get the local bounding rectangle of the entity.

The returned rectangle is in local coordinates, which means that it ignores the transformations (translation, rotation, scale, ...) that are applied to the entity. In other words, this function returns the bounds of the entity in the entity's coordinate system.

#### Returns
Local bounding rectangle of the entity

---

{#getglobalbounds-2}

### getGlobalBounds

`const` `nodiscard`

```cpp
[[nodiscard]] FloatRect getGlobalBounds() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:770

Get the global bounding rectangle of the entity.

The returned rectangle is in global coordinates, which means that it takes into account the transformations (translation, rotation, scale, ...) that are applied to the entity. In other words, this function returns the bounds of the text in the global 2D world's coordinate system.

#### Returns
Global bounding rectangle of the entity

## Public Types

| Name | Description |
|------|-------------|
| [`Style`](#style)  | Enumeration of the string drawing styles. |
| [`LineAlignment`](#linealignment)  | Enumeration of the text alignment options. |
| [`ClusterGrouping`](#clustergrouping)  | Cluster Grouping. |
| [`TextDirection`](#textdirection)  | [Text](#text-1) Direction. |
| [`TextOrientation`](#textorientation)  | [Text](#text-1) Orientation. |
| [`GlyphPreProcessor`](#glyphpreprocessor)  | Callable that is provided with glyph data for pre-processing. |

---

{#style}

### Style

```cpp
enum Style
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:67

Enumeration of the string drawing styles.

| Value | Description |
|-------|-------------|
| `Regular` | Regular characters, no style. |
| `Bold` | Bold characters. |
| `Italic` | Italic characters. |
| `Underlined` | Underlined characters. |
| `StrikeThrough` | Strike through characters. |

---

{#linealignment}

### LineAlignment

```cpp
enum LineAlignment
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:80

Enumeration of the text alignment options.

| Value | Description |
|-------|-------------|
| `Default` | Automatically align lines by script direction, left-align left-to-right text and right-align right-to-left text. |
| `Left` | Force align all lines to the left, regardless of script direction. |
| `Center` | Force align all lines centrally. |
| `Right` | Force align lines to the right, regardless of script direction. |

---

{#clustergrouping}

### ClusterGrouping

```cpp
enum ClusterGrouping
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:92

Cluster Grouping.

| Value | Description |
|-------|-------------|
| `Grapheme` | Group clusters by grapheme. |
| `Character` | Group clusters by character. |
| `None` | Do not group clusters. |

---

{#textdirection}

### TextDirection

```cpp
enum TextDirection
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:103

[Text](#text-1) Direction.

| Value | Description |
|-------|-------------|
| `Unspecified` | Unspecified. |
| `LeftToRight` | Left-to-right. |
| `RightToLeft` | Right-to-left. |
| `TopToBottom` | Top-to-bottom. |
| `BottomToTop` | Bottom-to-top. |

---

{#textorientation}

### TextOrientation

```cpp
enum TextOrientation
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:116

[Text](#text-1) Orientation.

| Value | Description |
|-------|-------------|
| `Default` | Default (left-to-right or right-to-left depending on detected script) |
| `TopToBottom` | Top-to-bottom. |
| `BottomToTop` | Bottom-to-top. |

---

{#glyphpreprocessor}

### GlyphPreProcessor

```cpp
using GlyphPreProcessor = std::function< void(const ShapedGlyph &shapedGlyph, std::uint32_t &style, Color &fillColor, Color &outlineColor, float &outlineThickness)>
```

Type: std::function< void(const [`ShapedGlyph`](sf-Text-ShapedGlyph.md#shapedglyph) &shapedGlyph, std::uint32_t &style, [`Color`](sf-Color.md#color) &fillColor, [`Color`](sf-Color.md#color) &outlineColor, float &outlineThickness)>

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:706

Callable that is provided with glyph data for pre-processing.

When re-generating the text geometry, shaping will be performed on the input string using the set font. The result of shaping is a set of shaped glyphs. Shaped glyphs are glyphs that have been positioned by the shaper and whose script direction has also been determined.

Because multiple input codepoints can be merged into a single glyph and single codepoints decomposed into multiple glyphs, the shaper provides a way to map the shaping output back to the input. When the input string is provided to the shaper, a monotonically increasing character index is attached to each input codepoint. If the input string consists of 10 codepoints, the indices will be 0 to 9.

After shaping each shaped glyph will be assigned a cluster value. These cluster values are derived from the input indices that were provided to the shaper. Because of the merging and decomposing that happens during shaping, there isn't a 1 to 1 mapping between input indices and output cluster values.

In order to set the glyph properties reliably, they have to be set based on text segmentation boundaries such as graphemes, words and sentences. See the corresponding methods in `[sf::String](sf-String.md#string)` that can check for these boundaries.

Once the input text segments to be pre-processed have been determined, they have to be applied to the shaped glyphs. When using character or grapheme cluster grouping it is guaranteed that the resulting cluster values are monotonic. This means that cluster values will not be reordered beyond the bounds of the indices that were provided with the input text.

What this means is that given a segment of text that should e.g. be colored differently, if a beginning and end index can be determined from the input codepoints, these index boundaries can be used to select the clusters of the shaped glyphs that correspond to the input segment and thus whose color needs to be set.

Here is an example string with codepoint indices: 
```cpp
I   l i k e   f l o w e r s ,   m u f f i n s   a n d   w a f f l e s .
0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 3 3 3 3 3 3
0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5
```
 After shaping, due to ligature merging of fl, ffi and ffl, the output clusters might look like: 
```cpp
I   l i k e   fl o w e r s ,   m u ffi n s   a n d   w a ffl e s .
0 0 0 0 0 0 0 0  0 1 1 1 1 1 1 1 1 1   2 2 2 2 2 2 2 2 2 3   3 3 3
0 1 2 3 4 5 6 7  9 0 1 2 3 4 5 6 7 8   1 2 3 4 5 6 7 8 9 0   3 4 5
```

In order to e.g. color the word "muffins", the beginning and end codepoint indices of the word have to be determined, in this case 16 and 22. After shaping, any glyphs belonging to the word "muffins" will have cluster values between and including 16 and 22. In the example above the clusters 16, 17, 18, 21 and 22 belong to the word "muffins". Coloring the glyphs with those indices will result in the word "muffins" being colored.

The same applies to "flowers" and "waffles" in the example above.

Because merging and decomposition of codepoints cannot happen beyond word boundaries, applying properties to glyphs using the above method is safe when segmenting based on words. As can be seen above it would not work when attempting to apply a different property to the single graphemes 'f', 'l' or 'i' since they can be merged with neighbouring graphemes into a single glyph.

The opposite, decomposition, of the following input: 
```cpp
I   f i n d   c l i c h é s   f u n n y .
0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1
0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0
```
 into glyphs would look like: 
```cpp
I   f i n d   c l i c h e + s   f u n n y .
0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1
0 1 2 3 4 5 6 7 8 9 0 1 2 2 3 4 5 6 7 8 9 0
```
 The + at cluster 12 is a placeholder for the acute accent. This can occur if the font provides the glyph for the accent seperate from the base glyph e which also has the cluster value 12. The codepoint é is thus decomposed into a base glyph and a mark glyph. The cluster value of the mark in such a decomposition will be identical to the base. Because of this, the same procedure as demonstrated in the fist example can be applied here as well.

The above examples are just simple examples of how to map input codepoint indices to output cluster values. While merging and decomposition are an exception in latin script, they can occur very frequently in other scripts. The mapping procedure described above will work for all scripts.

Once the boundaries of the cluster values whose properties to modify have been determined, they can be used from within the callable to set said properties on a glyph by glyph basis.

The callable will be called in the order in which glyph geometry is generated. This does not always happen in ascending cluster order such as in right-to-left text where it happens in descending cluster order.

Be aware that while changing the character size per glyph is not possible, changing its style or outline thickness is. Doing this, however, might lead to slight inconsistencies when the text bounds are computed at the end of the geometry update process. The same applies to the italic style.

In contrast, changing the fill or outline color is safe since they don't have any effect on the pixel coverage of the glyph.

Setting the underlined and strikethrough styles per glyph is technically possible but not yet implemented.

Note: Because text bounds are computed based on the geometry, it is not safe or reliable to query the text bounds from within this callable. If it is absolutely necessary to make decisions within this callable based on text bounds, multiple geometry updates will be necessary. The first geometry update is run with the pre-processor set to pass through data. Based on the first update the text bounds can be queried and stored. The stored text bounds can then be used in the second geometry update.

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`String`](sf-String.md#string) | [`m_string`](#m_string-1)  | [String](sf-String.md#string) to display. |
| const [`Font`](sf-Font.md#font) * | [`m_font`](#m_font)  | [Font](sf-Font.md#font) used to display the string. |
| `unsigned int` | [`m_characterSize`](#m_charactersize)  | Base size of characters, in pixels. |
| `float` | [`m_letterSpacingFactor`](#m_letterspacingfactor)  | Spacing factor between letters. |
| `float` | [`m_lineSpacingFactor`](#m_linespacingfactor)  | Spacing factor between lines. |
| `std::uint32_t` | [`m_style`](#m_style)  | [Text](#text-1) style (see [Style](sf-Style.md#style-1) enum) |
| [`Color`](sf-Color.md#color) | [`m_fillColor`](#m_fillcolor-1)  | [Text](#text-1) fill color. |
| [`Color`](sf-Color.md#color) | [`m_outlineColor`](#m_outlinecolor-1)  | [Text](#text-1) outline color. |
| `float` | [`m_outlineThickness`](#m_outlinethickness-1)  | Thickness of the text's outline. |
| [`LineAlignment`](LineAlignment.md#linealignment) | [`m_lineAlignment`](#m_linealignment)  | Line alignment for a multi-line text. |
| [`TextOrientation`](TextOrientation.md#textorientation) | [`m_textOrientation`](#m_textorientation)  | [Text](#text-1) orientation. |
| [`ClusterGrouping`](ClusterGrouping.md#clustergrouping) | [`m_clusterGrouping`](#m_clustergrouping)  | Cluster grouping algorithm. |
| [`GlyphPreProcessor`](#glyphpreprocessor) | [`m_glyphPreProcessor`](#m_glyphpreprocessor)  | [Glyph](sf-Glyph.md#glyph) pre-processor. |
| [`VertexArray`](sf-VertexArray.md#vertexarray) | [`m_vertices`](#m_vertices-2)  | [Vertex](sf-Vertex.md#vertex) array containing the fill geometry. |
| [`VertexArray`](sf-VertexArray.md#vertexarray) | [`m_outlineVertices`](#m_outlinevertices-1)  | [Vertex](sf-Vertex.md#vertex) array containing the outline geometry. |
| [`FloatRect`](sf.md#floatrect) | [`m_bounds`](#m_bounds-1)  | Bounding rectangle of the text (in local coordinates) |
| `bool` | [`m_geometryNeedUpdate`](#m_geometryneedupdate)  | Does the geometry need to be recomputed? |
| `std::uint64_t` | [`m_fontTextureId`](#m_fonttextureid)  | The font texture id. |
| std::vector< [`ShapedGlyph`](sf-Text-ShapedGlyph.md#shapedglyph) > | [`m_glyphs`](#m_glyphs)  | Cluster positions. |
| `std::shared_ptr< ShaperImpl >` | [`m_shaper`](#m_shaper)  | The shaper implementation. |

---

{#m_string-1}

### m_string

```cpp
String m_string
```

Type: [`String`](sf-String.md#string)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:796

[String](sf-String.md#string) to display.

---

{#m_font}

### m_font

```cpp
const Font * m_font {}
```

Type: const [`Font`](sf-Font.md#font) *

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:797

[Font](sf-Font.md#font) used to display the string.

---

{#m_charactersize}

### m_characterSize

```cpp
unsigned int m_characterSize {30}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:798

Base size of characters, in pixels.

---

{#m_letterspacingfactor}

### m_letterSpacingFactor

```cpp
float m_letterSpacingFactor {1.f}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:799

Spacing factor between letters.

---

{#m_linespacingfactor}

### m_lineSpacingFactor

```cpp
float m_lineSpacingFactor {1.f}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:800

Spacing factor between lines.

---

{#m_style}

### m_style

```cpp
std::uint32_t m_style {Regular}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:801

[Text](#text-1) style (see [Style](sf-Style.md#style-1) enum)

---

{#m_fillcolor-1}

### m_fillColor

```cpp
Color m_fillColor {Color::White}
```

Type: [`Color`](sf-Color.md#color)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:802

[Text](#text-1) fill color.

---

{#m_outlinecolor-1}

### m_outlineColor

```cpp
Color m_outlineColor {Color::Black}
```

Type: [`Color`](sf-Color.md#color)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:803

[Text](#text-1) outline color.

---

{#m_outlinethickness-1}

### m_outlineThickness

```cpp
float m_outlineThickness {0.f}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:804

Thickness of the text's outline.

---

{#m_linealignment}

### m_lineAlignment

```cpp
LineAlignment m_lineAlignment {LineAlignment::Default}
```

Type: [`LineAlignment`](LineAlignment.md#linealignment)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:805

Line alignment for a multi-line text.

---

{#m_textorientation}

### m_textOrientation

```cpp
TextOrientation m_textOrientation {TextOrientation::Default}
```

Type: [`TextOrientation`](TextOrientation.md#textorientation)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:806

[Text](#text-1) orientation.

---

{#m_clustergrouping}

### m_clusterGrouping

```cpp
ClusterGrouping m_clusterGrouping {ClusterGrouping::Character}
```

Type: [`ClusterGrouping`](ClusterGrouping.md#clustergrouping)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:807

Cluster grouping algorithm.

---

{#m_glyphpreprocessor}

### m_glyphPreProcessor

```cpp
GlyphPreProcessor m_glyphPreProcessor
```

Type: [`GlyphPreProcessor`](#glyphpreprocessor)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:808

[Glyph](sf-Glyph.md#glyph) pre-processor.

---

{#m_vertices-2}

### m_vertices

```cpp
VertexArray m_vertices {PrimitiveType::Triangles}
```

Type: [`VertexArray`](sf-VertexArray.md#vertexarray)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:809

[Vertex](sf-Vertex.md#vertex) array containing the fill geometry.

---

{#m_outlinevertices-1}

### m_outlineVertices

```cpp
VertexArray m_outlineVertices {PrimitiveType::Triangles}
```

Type: [`VertexArray`](sf-VertexArray.md#vertexarray)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:810

[Vertex](sf-Vertex.md#vertex) array containing the outline geometry.

---

{#m_bounds-1}

### m_bounds

```cpp
FloatRect m_bounds
```

Type: [`FloatRect`](sf.md#floatrect)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:811

Bounding rectangle of the text (in local coordinates)

---

{#m_geometryneedupdate}

### m_geometryNeedUpdate

```cpp
bool m_geometryNeedUpdate {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:812

Does the geometry need to be recomputed?

---

{#m_fonttextureid}

### m_fontTextureId

```cpp
std::uint64_t m_fontTextureId {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:813

The font texture id.

---

{#m_glyphs}

### m_glyphs

```cpp
std::vector< ShapedGlyph > m_glyphs
```

Type: std::vector< [`ShapedGlyph`](sf-Text-ShapedGlyph.md#shapedglyph) >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:814

Cluster positions.

---

{#m_shaper}

### m_shaper

```cpp
std::shared_ptr< ShaperImpl > m_shaper
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:815

The shaper implementation.

## Private Methods

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`draw`](#draw-7) `virtual` `const` `override` | Draw the text to a render target. |
| `void` | [`ensureGeometryUpdate`](#ensuregeometryupdate) `const` | Make sure the text's geometry is updated. |

---

{#draw-7}

### draw

`virtual` `const` `override`

```cpp
virtual void draw(RenderTarget & target, RenderStates states) const override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:780

Draw the text to a render target.

#### Reimplements

- [`draw`](sf-Drawable.md#draw)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `target` | [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) & | Render target to draw to |
| `states` | [`RenderStates`](sf-RenderStates.md#renderstates) | Current render states |

---

{#ensuregeometryupdate}

### ensureGeometryUpdate

`const`

```cpp
void ensureGeometryUpdate() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:789

Make sure the text's geometry is updated.

All the attributes related to rendering are cached, such that the geometry is only updated when necessary.

