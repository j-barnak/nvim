{#streamdeleter}

# StreamDeleter

```cpp
struct StreamDeleter
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:262

Deleter for input streams that only conditionally deletes.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `bool` | [`owned`](#owned)  |  |

---

{#owned}

### owned

```cpp
bool owned {true}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:272

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`StreamDeleter`](#streamdeleter-1)  |  |
|  | [`StreamDeleter`](#streamdeleter-2)  |  |
| `void` | [`operator()`](#operator-2) `const` |  |

---

{#streamdeleter-1}

### StreamDeleter

```cpp
StreamDeleter(bool theOwned)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:264

---

{#streamdeleter-2}

### StreamDeleter

```cpp
template<typename T> StreamDeleter(const std::default_delete< T > &)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:268

---

{#operator-2}

### operator()

`const`

```cpp
void operator()(InputStream * ptr) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:270

