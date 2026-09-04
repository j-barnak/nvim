{#string}

# String

```cpp
#include <String.hpp>
```

```cpp
class String
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:90

Utility string class that automatically handles conversions between types and encodings.

`[sf::String](#string)` is a utility string class defined mainly for convenience. It is a Unicode string (implemented using UTF-32), thus it can store any character in the world (European, Chinese, Arabic, Hebrew, etc.).

It automatically handles conversions from/to ANSI and wide strings, so that you can work with standard string classes and still be compatible with functions taking a `[sf::String](#string)`.

```cpp
sf::String s;

std::string s1 = s;  // automatically converted to ANSI string
std::wstring s2 = s; // automatically converted to wide string
s = "hello";         // automatically converted from ANSI string
s = L"hello";        // automatically converted from wide string
s += 'a';            // automatically converted from ANSI string
s += L'a';           // automatically converted from wide string
```

Conversions involving ANSI strings use the default user locale. However it is possible to use a custom locale if necessary: 
```cpp
std::locale locale;
sf::String s;
...
std::string s1 = s.toAnsiString(locale);
s = sf::String("hello", locale);
```

`[sf::String](#string)` defines the most important functions of the standard `std::string` class: removing, random access, iterating, appending, comparing, etc. However it is a simple class provided for convenience, and you may have to consider using a more optimized class if your program requires complex string handling. The automatic conversion functions will then take care of converting your string to `[sf::String](#string)` whenever SFML requires it.

Please note that SFML also defines a low-level, generic interface for Unicode handling, see the `[sf::Utf](sf-Utf.md#utf)` classes.

## Friends

| Name | Description |
|------|-------------|
| [`operator==`](#operator-12)  |  |
| [`operator<`](#operator-13)  |  |

---

{#operator-12}

### operator==

```cpp
friend bool operator==(const String & left, const String & right)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:648

---

{#operator-13}

### operator<

```cpp
friend bool operator<(const String & left, const String & right)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:649

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`String`](#string-1)  | Default constructor. |
|  | [`String`](#string-2)  | Deleted `std::nullptr_t` constructor. |
|  | [`String`](#string-3)  | Construct from a single ANSI character and a locale. |
|  | [`String`](#string-4)  | Construct from single wide character. |
|  | [`String`](#string-5)  | Construct from single UTF-32 character. |
|  | [`String`](#string-6)  | Construct from a null-terminated C-style ANSI string and a locale. |
|  | [`String`](#string-7)  | Construct from an ANSI string and a locale. |
|  | [`String`](#string-8)  | Construct from an ANSI string view and a locale. |
|  | [`String`](#string-9)  | Construct from null-terminated C-style wide string. |
|  | [`String`](#string-10)  | Construct from a wide string. |
|  | [`String`](#string-11)  | Construct from a wide string view. |
|  | [`String`](#string-12)  | Construct from a null-terminated C-style UTF-32 string. |
|  | [`String`](#string-13)  | Construct from an UTF-32 string. |
|  | [`String`](#string-14)  | Construct from an UTF-32 string view. |
|  | [`operator std::string`](#operatorstd-string) `const` | Implicit conversion operator to `std::string` (ANSI string) |
|  | [`operator std::wstring`](#operatorstd-wstring) `const` | Implicit conversion operator to `std::wstring` (wide string) |
| `std::string` | [`toAnsiString`](#toansistring) `const` `nodiscard` | Convert the Unicode string to an ANSI string. |
| `std::wstring` | [`toWideString`](#towidestring) `const` `nodiscard` | Convert the Unicode string to a wide string. |
| [`sf::U8String`](sf.md#u8string) | [`toUtf8`](#toutf8) `const` `nodiscard` | Convert the Unicode string to a UTF-8 string. |
| `std::u16string` | [`toUtf16`](#toutf16) `const` `nodiscard` | Convert the Unicode string to a UTF-16 string. |
| `std::u32string` | [`toUtf32`](#toutf32) `const` `nodiscard` | Convert the Unicode string to a UTF-32 string. |
| [`String`](#string) & | [`operator+=`](#operator-14)  | Overload of `operator+=` to append an UTF-32 string. |
| `char32_t` | [`operator[]`](#operator-15) `const` `nodiscard` | Overload of `operator[]` to access a character by its position. |
| `char32_t &` | [`operator[]`](#operator-16) `nodiscard` | Overload of `operator[]` to access a character by its position. |
| `void` | [`clear`](#clear)  | Clear the string. |
| `std::size_t` | [`getSize`](#getsize-3) `const` `nodiscard` | Get the size of the string. |
| `bool` | [`isEmpty`](#isempty) `const` `nodiscard` | Check whether the string is empty or not. |
| `void` | [`erase`](#erase)  | Erase one or more characters from the string. |
| `void` | [`insert`](#insert)  | Insert one or more characters into the string. |
| `std::size_t` | [`find`](#find) `const` `nodiscard` | Find a sequence of one or more characters in the string. |
| `void` | [`replace`](#replace)  | Replace a substring with another string. |
| `void` | [`replace`](#replace-1)  | Replace all occurrences of a substring with a replacement string. |
| [`String`](#string) | [`substring`](#substring) `const` `nodiscard` | Return a part of the string. |
| `const char32_t *` | [`getData`](#getdata) `const` `nodiscard` | Get a pointer to the C-style array of characters. |
| [`Iterator`](#iterator) | [`begin`](#begin) `nodiscard` | Return an iterator to the beginning of the string. |
| [`ConstIterator`](#constiterator) | [`begin`](#begin-1) `const` `nodiscard` | Return an iterator to the beginning of the string. |
| [`Iterator`](#iterator) | [`end`](#end) `nodiscard` | Return an iterator to the end of the string. |
| [`ConstIterator`](#constiterator) | [`end`](#end-1) `const` `nodiscard` | Return an iterator to the end of the string. |
| `bool` | [`isGraphemeBoundary`](#isgraphemeboundary) `const` `nodiscard` | Check if the position before a character is a grapheme boundary. |
| `bool` | [`isWordBoundary`](#iswordboundary) `const` `nodiscard` | Check if the position before a character is a word boundary. |
| `bool` | [`isSentenceBoundary`](#issentenceboundary) `const` `nodiscard` | Check if the position before a character is a sentence boundary. |

---

{#string-1}

### String

```cpp
String() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:113

Default constructor.

This constructor creates an empty string.

---

{#string-2}

### String

```cpp
String(std::nullptr_t, const std::locale & = {}) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:121

Deleted `std::nullptr_t` constructor.

Disallow construction from `nullptr` literal

---

{#string-3}

### String

```cpp
String(char ansiChar, const std::locale & locale = {})
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:133

Construct from a single ANSI character and a locale.

The source character is converted to UTF-32 according to the given locale.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ansiChar` | `char` | ANSI character to convert |
| `locale` | `const std::locale &` | Locale to use for conversion |

---

{#string-4}

### String

```cpp
String(wchar_t wideChar)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:141

Construct from single wide character.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `wideChar` | `wchar_t` | Wide character to convert |

---

{#string-5}

### String

```cpp
String(char32_t utf32Char)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:149

Construct from single UTF-32 character.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `utf32Char` | `char32_t` | UTF-32 character to convert |

---

{#string-6}

### String

```cpp
String(const char * ansiString, const std::locale & locale = {})
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:161

Construct from a null-terminated C-style ANSI string and a locale.

The source string is converted to UTF-32 according to the given locale.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ansiString` | `const char *` | ANSI string to convert |
| `locale` | `const std::locale &` | Locale to use for conversion |

---

{#string-7}

### String

```cpp
String(const std::string & ansiString, const std::locale & locale = {})
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:173

Construct from an ANSI string and a locale.

The source string is converted to UTF-32 according to the given locale.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ansiString` | `const std::string &` | ANSI string to convert |
| `locale` | `const std::locale &` | Locale to use for conversion |

---

{#string-8}

### String

```cpp
String(std::string_view ansiString, const std::locale & locale = {})
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:185

Construct from an ANSI string view and a locale.

The source string is converted to UTF-32 according to the given locale.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ansiString` | `std::string_view` | ANSI string to convert |
| `locale` | `const std::locale &` | Locale to use for conversion |

---

{#string-9}

### String

```cpp
String(const wchar_t * wideString)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:193

Construct from null-terminated C-style wide string.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `wideString` | `const wchar_t *` | Wide string to convert |

---

{#string-10}

### String

```cpp
String(const std::wstring & wideString)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:201

Construct from a wide string.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `wideString` | `const std::wstring &` | Wide string to convert |

---

{#string-11}

### String

```cpp
String(std::wstring_view wideString)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:209

Construct from a wide string view.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `wideString` | `std::wstring_view` | Wide string to convert |

---

{#string-12}

### String

```cpp
String(const char32_t * utf32String)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:217

Construct from a null-terminated C-style UTF-32 string.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `utf32String` | `const char32_t *` | UTF-32 string to assign |

---

{#string-13}

### String

```cpp
String(std::u32string utf32String)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:225

Construct from an UTF-32 string.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `utf32String` | `std::u32string` | UTF-32 string to assign |

---

{#string-14}

### String

```cpp
String(std::u32string_view utf32String)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:233

Construct from an UTF-32 string view.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `utf32String` | `std::u32string_view` | UTF-32 string to assign |

---

{#operatorstd-string}

### operator std::string

`const`

```cpp
operator std::string() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:298

Implicit conversion operator to `std::string` (ANSI string)

The current global locale is used for conversion. If you want to explicitly specify a locale, see toAnsiString. Characters that do not fit in the target encoding are discarded from the returned string. This operator is defined for convenience, and is equivalent to calling `[toAnsiString()](#toansistring)`.

#### Returns
Converted ANSI string

**See also**: `[toAnsiString](#toansistring)`, `operator std::wstring`

---

{#operatorstd-wstring}

### operator std::wstring

`const`

```cpp
operator std::wstring() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:313

Implicit conversion operator to `std::wstring` (wide string)

Characters that do not fit in the target encoding are discarded from the returned string. This operator is defined for convenience, and is equivalent to calling `[toWideString()](#towidestring)`.

#### Returns
Converted wide string

**See also**: `[toWideString](#towidestring)`, `operator std::string`

---

{#toansistring}

### toAnsiString

`const` `nodiscard`

```cpp
[[nodiscard]] std::string toAnsiString(const std::locale & locale = {}, std::optional< char > replacement = std::nullopt) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:329

Convert the Unicode string to an ANSI string.

The UTF-32 string is converted to an ANSI string in the encoding defined by `locale`.

#### Returns
Converted ANSI string

**See also**: `[toWideString](#towidestring)`, `operator std::string`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `locale` | `const std::locale &` | Locale to use for conversion |
| `replacement` | `std::optional< char >` | Replacement for characters not convertible to ANSI (use nullopt to skip them) |

---

{#towidestring}

### toWideString

`const` `nodiscard`

```cpp
[[nodiscard]] std::wstring toWideString(std::optional< wchar_t > replacement = std::nullopt) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:342

Convert the Unicode string to a wide string.

#### Returns
Converted wide string

**See also**: `[toAnsiString](#toansistring)`, `operator std::wstring`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `replacement` | `std::optional< wchar_t >` | Replacement for characters not convertible to wide char (use nullopt to skip them) |

---

{#toutf8}

### toUtf8

`const` `nodiscard`

```cpp
[[nodiscard]] sf::U8String toUtf8(std::optional< std::uint8_t > replacement = std::nullopt) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:354

Convert the Unicode string to a UTF-8 string.

#### Returns
Converted UTF-8 string

**See also**: `[toUtf16](#toutf16)`, `[toUtf32](#toutf32)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `replacement` | `std::optional< std::uint8_t >` | Replacement for characters not convertible to UTF-8 (use nullopt to skip them) |

---

{#toutf16}

### toUtf16

`const` `nodiscard`

```cpp
[[nodiscard]] std::u16string toUtf16(std::optional< std::uint16_t > replacement = std::nullopt) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:366

Convert the Unicode string to a UTF-16 string.

#### Returns
Converted UTF-16 string

**See also**: `[toUtf8](#toutf8)`, `[toUtf32](#toutf32)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `replacement` | `std::optional< std::uint16_t >` | Replacement for characters not convertible to UTF-16 (use nullopt to skip them) |

---

{#toutf32}

### toUtf32

`const` `nodiscard`

```cpp
[[nodiscard]] std::u32string toUtf32() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:379

Convert the Unicode string to a UTF-32 string.

This function doesn't perform any conversion, since the string is already stored as UTF-32 internally.

#### Returns
Converted UTF-32 string

**See also**: `[toUtf8](#toutf8)`, `[toUtf16](#toutf16)`

---

{#operator-14}

### operator+=

```cpp
String & operator+=(const String & right)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:389

Overload of `operator+=` to append an UTF-32 string.

#### Returns
Reference to self

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `right` | const [`String`](#string) & | [String](#string) to append |

---

{#operator-15}

### operator[]

`const` `nodiscard`

```cpp
[[nodiscard]] char32_t operator[](std::size_t index) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:402

Overload of `operator[]` to access a character by its position.

This function provides read-only access to characters. Note: the behavior is undefined if `index` is out of range.

#### Returns
Character at position `index`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `index` | `std::size_t` | Index of the character to get |

---

{#operator-16}

### operator[]

`nodiscard`

```cpp
[[nodiscard]] char32_t & operator[](std::size_t index)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:415

Overload of `operator[]` to access a character by its position.

This function provides read and write access to characters. Note: the behavior is undefined if `index` is out of range.

#### Returns
Reference to the character at position `index`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `index` | `std::size_t` | Index of the character to get |

---

{#clear}

### clear

```cpp
void clear()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:425

Clear the string.

This function removes all the characters from the string.

**See also**: `[isEmpty](#isempty)`, `[erase](#erase)`

---

{#getsize-3}

### getSize

`const` `nodiscard`

```cpp
[[nodiscard]] std::size_t getSize() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:435

Get the size of the string.

#### Returns
Number of characters in the string

**See also**: `[isEmpty](#isempty)`

---

{#isempty}

### isEmpty

`const` `nodiscard`

```cpp
[[nodiscard]] bool isEmpty() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:445

Check whether the string is empty or not.

#### Returns
`true` if the string is empty (i.e. contains no character)

**See also**: `[clear](#clear)`, `[getSize](#getsize-3)`

---

{#erase}

### erase

```cpp
void erase(std::size_t position, std::size_t count = 1)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:457

Erase one or more characters from the string.

This function removes a sequence of `count` characters starting from `position`.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `position` | `std::size_t` | Position of the first character to erase |
| `count` | `std::size_t` | Number of characters to erase |

---

{#insert}

### insert

```cpp
void insert(std::size_t position, const String & str)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:469

Insert one or more characters into the string.

This function inserts the characters of `str` into the string, starting from `position`.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `position` | `std::size_t` | Position of insertion |
| `str` | const [`String`](#string) & | Characters to insert |

---

{#find}

### find

`const` `nodiscard`

```cpp
[[nodiscard]] std::size_t find(const String & str, std::size_t start = 0) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:483

Find a sequence of one or more characters in the string.

This function searches for the characters of `str` in the string, starting from `start`.

#### Returns
Position of `str` in the string, or `[String::InvalidPos](#invalidpos)` if not found

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `str` | const [`String`](#string) & | Characters to find |
| `start` | `std::size_t` | Where to begin searching |

---

{#replace}

### replace

```cpp
void replace(std::size_t position, std::size_t length, const String & replaceWith)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:497

Replace a substring with another string.

This function replaces the substring that starts at index `position` and spans `length` characters with the string `replaceWith`.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `position` | `std::size_t` | Index of the first character to be replaced |
| `length` | `std::size_t` | Number of characters to replace. You can pass InvalidPos to replace all characters until the end of the string. |
| `replaceWith` | const [`String`](#string) & | [String](#string) that replaces the given substring. |

---

{#replace-1}

### replace

```cpp
void replace(const String & searchFor, const String & replaceWith)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:509

Replace all occurrences of a substring with a replacement string.

This function replaces all occurrences of `searchFor` in this string with the string `replaceWith`.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `searchFor` | const [`String`](#string) & | The value being searched for |
| `replaceWith` | const [`String`](#string) & | The value that replaces found `searchFor` values |

---

{#substring}

### substring

`const` `nodiscard`

```cpp
[[nodiscard]] String substring(std::size_t position, std::size_t length = InvalidPos) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:526

Return a part of the string.

This function returns the substring that starts at index `position` and spans `length` characters.

#### Returns
[String](#string) object containing a substring of this object

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `position` | `std::size_t` | Index of the first character |
| `length` | `std::size_t` | Number of characters to include in the substring (if the string is shorter, as many characters as possible are included). `InvalidPos` can be used to include all characters until the end of the string. |

---

{#getdata}

### getData

`const` `nodiscard`

```cpp
[[nodiscard]] const char32_t * getData() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:539

Get a pointer to the C-style array of characters.

This functions provides a read-only access to a null-terminated C-style representation of the string. The returned pointer is temporary and is meant only for immediate use, thus it is not recommended to store it.

#### Returns
Read-only pointer to the array of characters

---

{#begin}

### begin

`nodiscard`

```cpp
[[nodiscard]] Iterator begin()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:549

Return an iterator to the beginning of the string.

#### Returns
Read-write iterator to the beginning of the string characters

**See also**: `[end](#end)`

---

{#begin-1}

### begin

`const` `nodiscard`

```cpp
[[nodiscard]] ConstIterator begin() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:559

Return an iterator to the beginning of the string.

#### Returns
Read-only iterator to the beginning of the string characters

**See also**: `[end](#end)`

---

{#end}

### end

`nodiscard`

```cpp
[[nodiscard]] Iterator end()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:573

Return an iterator to the end of the string.

The end iterator refers to 1 position past the last character; thus it represents an invalid character and should never be accessed.

#### Returns
Read-write iterator to the end of the string characters

**See also**: `[begin](#begin)`

---

{#end-1}

### end

`const` `nodiscard`

```cpp
[[nodiscard]] ConstIterator end() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:587

Return an iterator to the end of the string.

The end iterator refers to 1 position past the last character; thus it represents an invalid character and should never be accessed.

#### Returns
Read-only iterator to the end of the string characters

**See also**: `[begin](#begin)`

---

{#isgraphemeboundary}

### isGraphemeBoundary

`const` `nodiscard`

```cpp
[[nodiscard]] bool isGraphemeBoundary(std::size_t position) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:608

Check if the position before a character is a grapheme boundary.

When manipulating unicode strings, removing single codepoints does not always make sense since they might be a part of a grapheme composed of multiple codepoints. In the case of a text editor, it is more intuitive to the user if entire graphemes are removed when e.g. delete or backspace is pressed rather than single codepoints. For this reason, the visual caret that marks the insertion/deletion point should only be positioned at a grapheme boundaries.

#### Returns
`true` if the position before a character is a grapheme boundary

**See also**: `[isWordBoundary](#iswordboundary)`, `[isSentenceBoundary](#issentenceboundary)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `position` | `std::size_t` | The position of the character to check |

---

{#iswordboundary}

### isWordBoundary

`const` `nodiscard`

```cpp
[[nodiscard]] bool isWordBoundary(std::size_t position) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:626

Check if the position before a character is a word boundary.

When breaking text into multiple lines, it is important to know where each word ends so that lines aren't broken in the middle of a word. This should be used in combination with `isSentenceBoundary` to ensure punctuation isn't broken into a new line by itself.

#### Returns
`true` if the position before a character is a word boundary

**See also**: `[isGraphemeBoundary](#isgraphemeboundary)`, `[isSentenceBoundary](#issentenceboundary)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `position` | `std::size_t` | The position of the character to check |

---

{#issentenceboundary}

### isSentenceBoundary

`const` `nodiscard`

```cpp
[[nodiscard]] bool isSentenceBoundary(std::size_t position) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:641

Check if the position before a character is a sentence boundary.

This can be used together with `isWordBoundary` to break lines. See `isWordBoundary` for more information.

#### Returns
`true` if the position before a character is a sentence boundary

**See also**: `[isGraphemeBoundary](#isgraphemeboundary)`, `[isWordBoundary](#iswordboundary)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `position` | `std::size_t` | The position of the character to check |

## Public Static Attributes

| Return | Name | Description |
|--------|------|-------------|
| `const std::size_t` | [`InvalidPos`](#invalidpos) `static` | Represents an invalid position in the string. |

---

{#invalidpos}

### InvalidPos

`static`

```cpp
const std::size_t InvalidPos {std::u32string::npos}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:104

Represents an invalid position in the string.

## Public Static Methods

| Return | Name | Description |
|--------|------|-------------|
| [`String`](#string) | [`fromUtf8`](#fromutf8) `static` `nodiscard` | Create a new `[sf::String](#string)` from a UTF-8 encoded string. |
| [`String`](#string) | [`fromUtf16`](#fromutf16) `static` `nodiscard` | Create a new `[sf::String](#string)` from a UTF-16 encoded string. |
| [`String`](#string) | [`fromUtf32`](#fromutf32) `static` `nodiscard` | Create a new `[sf::String](#string)` from a UTF-32 encoded string. |

---

{#fromutf8}

### fromUtf8

`static` `nodiscard`

```cpp
template<typename T> [[nodiscard]] static String fromUtf8(T begin, T end, std::optional< char32_t > replacement = std::nullopt)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:248

Create a new `[sf::String](#string)` from a UTF-8 encoded string.

#### Returns
A `[sf::String](#string)` containing the source string

**See also**: `[fromUtf16](#fromutf16)`, `[fromUtf32](#fromutf32)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `begin` | `T` | Forward iterator to the beginning of the UTF-8 sequence |
| `end` | `T` | Forward iterator to the end of the UTF-8 sequence |
| `replacement` | `std::optional< char32_t >` | Replacement for characters not convertible from UTF-8 (use nullopt to skip them) |

---

{#fromutf16}

### fromUtf16

`static` `nodiscard`

```cpp
template<typename T> [[nodiscard]] static String fromUtf16(T begin, T end, std::optional< char32_t > replacement = std::nullopt)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:263

Create a new `[sf::String](#string)` from a UTF-16 encoded string.

#### Returns
A `[sf::String](#string)` containing the source string

**See also**: `[fromUtf8](#fromutf8)`, `[fromUtf32](#fromutf32)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `begin` | `T` | Forward iterator to the beginning of the UTF-16 sequence |
| `end` | `T` | Forward iterator to the end of the UTF-16 sequence |
| `replacement` | `std::optional< char32_t >` | Replacement for characters not convertible from UTF-16 (use nullopt to skip them) |

---

{#fromutf32}

### fromUtf32

`static` `nodiscard`

```cpp
template<typename T> [[nodiscard]] static String fromUtf32(T begin, T end)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:281

Create a new `[sf::String](#string)` from a UTF-32 encoded string.

This function is provided for consistency, it is equivalent to using the constructors that takes a `const char32_t*` or a `std::u32string`.

#### Returns
A `[sf::String](#string)` containing the source string

**See also**: `[fromUtf8](#fromutf8)`, `[fromUtf16](#fromutf16)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `begin` | `T` | Forward iterator to the beginning of the UTF-32 sequence |
| `end` | `T` | Forward iterator to the end of the UTF-32 sequence |

## Public Types

| Name | Description |
|------|-------------|
| [`Iterator`](#iterator)  | [Iterator](#iterator) type. |
| [`ConstIterator`](#constiterator)  | Read-only iterator type. |

---

{#iterator}

### Iterator

```cpp
using Iterator = std::u32string::iterator
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:96

[Iterator](#iterator) type.

---

{#constiterator}

### ConstIterator

```cpp
using ConstIterator = std::u32string::const_iterator
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:97

Read-only iterator type.

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::u32string` | [`m_string`](#m_string)  | Internal string of UTF-32 characters. |

---

{#m_string}

### m_string

```cpp
std::u32string m_string
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:655

Internal string of UTF-32 characters.

