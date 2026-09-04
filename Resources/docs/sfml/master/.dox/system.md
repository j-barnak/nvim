{#systemmodule}

# System module

Base module of SFML, defining various utilities. It provides vector classes, Unicode strings and conversion functions, threads and mutexes, timing classes.

## Classes

| Name | Description |
|------|-------------|
| [`Angle`](sf-Angle.md#angle) | Represents an angle value. |
| [`Clock`](sf-Clock.md#clock) | Utility class that measures the elapsed time. |
| [`FileInputStream`](sf-FileInputStream.md#fileinputstream) | Implementation of input stream based on a file. |
| [`InputStream`](sf-InputStream.md#inputstream) | Abstract class for custom file input streams. |
| [`MemoryInputStream`](sf-MemoryInputStream.md#memoryinputstream) | Implementation of input stream based on a memory chunk. |
| [`String`](sf-String.md#string) | Utility string class that automatically handles conversions between types and encodings. |
| [`Time`](sf-Time.md#time) | Represents a time value. |
| [`TimeoutWithPredicate`](sf-TimeoutWithPredicate.md#timeoutwithpredicate) | Utility class providing hybrid functionality of a timeout and a continuation predicate. |
| [`Utf`](sf-Utf.md#utf) | Utility class providing generic functions for UTF conversions. |
| [`Vector2`](sf-Vector2.md#vector2) | Class template for manipulating 2-dimensional vectors. |
| [`Vector3`](sf-Vector3.md#vector3) | Utility template class for manipulating 3-dimensional vectors. |

## Functions

| Return | Name | Description |
|--------|------|-------------|
| [`SFML_SYSTEM_API`](api.md#sfml_system_api) ANativeActivity * | [`getNativeActivity`](#getnativeactivity) `nodiscard` | Return a pointer to the Android native activity. |
| [`SFML_SYSTEM_API`](api.md#sfml_system_api) void | [`sleep`](#sleep)  | Make the current thread sleep for a given duration. |
| [`SFML_SYSTEM_API`](api.md#sfml_system_api) std::ostream & | [`err`](#err) `nodiscard` | Standard stream used by SFML to output warnings and errors. |

---

{#getnativeactivity}

### getNativeActivity

`nodiscard`

```cpp
[[nodiscard]] SFML_SYSTEM_API ANativeActivity * getNativeActivity()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/NativeActivity.hpp:56

Return a pointer to the Android native activity.

You shouldn't have to use this function, unless you want to implement very specific details, that SFML doesn't support, or to use a workaround for a known issue.

#### Returns
Pointer to Android native activity structure

\sfplatform{Android,[SFML/System/NativeActivity.hpp](#nativeactivityhpp)}

---

{#sleep}

### sleep

```cpp
SFML_SYSTEM_API void sleep(Time duration)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Sleep.hpp:55

Make the current thread sleep for a given duration.

`[sf::sleep](#sleep)` is the best way to block a program or one of its threads, as it doesn't consume any CPU power. Compared to the standard `std::this_thread::sleep_for` function, this one provides more accurate sleeping time thanks to some platform-specific tweaks.

`[sf::sleep](#sleep)` only guarantees millisecond precision. Sleeping for a duration less than 1 millisecond is prone to result in the actual sleep duration being less than what is requested.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `duration` | `Time` | [Time](sf-Time.md#time) to sleep |

---

{#err}

### err

`nodiscard`

```cpp
[[nodiscard]] SFML_SYSTEM_API std::ostream & err()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Err.hpp:41

Standard stream used by SFML to output warnings and errors.

By default, `[sf::err()](#err)` outputs to the same location as `std::cerr`, (-> the stderr descriptor) which is the console if there's one available.

It is a standard `std::ostream` instance, so it supports all the insertion operations defined by the STL (`operator<<`, manipulators, etc.).

`[sf::err()](#err)` can be redirected to write to another output, independently of `std::cerr`, by using the `rdbuf()` function provided by the `std::ostream` class.

Example: 
```cpp
// Redirect to a file
std::ofstream file("sfml-log.txt");
std::streambuf* previous = sf::err().rdbuf(file.rdbuf());

// Redirect to nothing
sf::err().rdbuf(nullptr);

// Restore the original output
sf::err().rdbuf(previous);
```

#### Returns
Reference to `std::ostream` representing the SFML error stream

