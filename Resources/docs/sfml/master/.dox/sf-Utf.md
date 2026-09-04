{#utf}

# Utf

```cpp
#include <Utf.hpp>
```

```cpp
template<unsigned int N>
class Utf
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Utf.hpp:765

Utility class providing generic functions for UTF conversions.

`[sf::Utf](#utf)` is a low-level, generic interface for counting, iterating, encoding and decoding Unicode characters and strings. It is able to handle ANSI, wide, latin-1, UTF-8, UTF-16 and UTF-32 encodings.

`[sf::Utf](#utf)<X>` functions are all static, these classes are not meant to be instantiated. All the functions are template, so that you can use any character / string type for a given encoding.

It has 3 specializations: 

* `[sf::Utf](#utf)<8>` (with `[sf::Utf8](sf.md#utf8)` type alias) 
* `[sf::Utf](#utf)<16>` (with `[sf::Utf16](sf.md#utf16)` type alias) 
* `[sf::Utf](#utf)<32>` (with `[sf::Utf32](sf.md#utf32)` type alias)

