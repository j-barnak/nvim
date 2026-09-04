{#soundfilefactory}

# SoundFileFactory

```cpp
#include <SoundFileFactory.hpp>
```

```cpp
class SoundFileFactory
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundFileFactory.hpp:49

Manages and instantiates sound file readers and writers.

This class is where all the sound file readers and writers are registered. You should normally only need to use its registration and unregistration functions; readers/writers creation and manipulation are wrapped into the higher-level classes `[sf::InputSoundFile](sf-InputSoundFile.md#inputsoundfile)` and `[sf::OutputSoundFile](sf-OutputSoundFile.md#outputsoundfile)`.

To register a new reader (writer) use the `[sf::SoundFileFactory::registerReader](#registerreader)` (`registerWriter`) static function. You don't have to call the `unregisterReader` (`unregisterWriter`) function, unless you want to unregister a format before your application ends (typically, when a plugin is unloaded).

Usage example: 
```cpp
sf::SoundFileFactory::registerReader<MySoundFileReader>();
assert(sf::SoundFileFactory::isReaderRegistered<MySoundFileReader>());

sf::SoundFileFactory::registerWriter<MySoundFileWriter>();
assert(sf::SoundFileFactory::isWriterRegistered<MySoundFileWriter>());
```

**See also**: `[sf::InputSoundFile](sf-InputSoundFile.md#inputsoundfile)`, `[sf::OutputSoundFile](sf-OutputSoundFile.md#outputsoundfile)`, `[sf::SoundFileReader](sf-SoundFileReader.md#soundfilereader)`, `[sf::SoundFileWriter](sf-SoundFileWriter.md#soundfilewriter)`

## Public Static Methods

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`registerReader`](#registerreader) `static` | Register a new reader. |
| `void` | [`unregisterReader`](#unregisterreader) `static` | Unregister a reader. |
| `bool` | [`isReaderRegistered`](#isreaderregistered) `static` `nodiscard` | Check if a reader is registered. |
| `void` | [`registerWriter`](#registerwriter) `static` | Register a new writer. |
| `void` | [`unregisterWriter`](#unregisterwriter) `static` | Unregister a writer. |
| `bool` | [`isWriterRegistered`](#iswriterregistered) `static` `nodiscard` | Check if a writer is registered. |
| std::unique_ptr< [`SoundFileReader`](sf-SoundFileReader.md#soundfilereader) > | [`createReaderFromFilename`](#createreaderfromfilename) `static` `nodiscard` | Instantiate the right reader for the given file on disk. |
| std::unique_ptr< [`SoundFileReader`](sf-SoundFileReader.md#soundfilereader) > | [`createReaderFromMemory`](#createreaderfrommemory) `static` `nodiscard` | Instantiate the right codec for the given file in memory. |
| std::unique_ptr< [`SoundFileReader`](sf-SoundFileReader.md#soundfilereader) > | [`createReaderFromStream`](#createreaderfromstream) `static` `nodiscard` | Instantiate the right codec for the given file in stream. |
| std::unique_ptr< [`SoundFileWriter`](sf-SoundFileWriter.md#soundfilewriter) > | [`createWriterFromFilename`](#createwriterfromfilename) `static` `nodiscard` | Instantiate the right writer for the given file on disk. |

---

{#registerreader}

### registerReader

`static`

```cpp
template<typename T> static void registerReader()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundFileFactory.hpp:59

Register a new reader.

**See also**: `[unregisterReader](#unregisterreader)`

---

{#unregisterreader}

### unregisterReader

`static`

```cpp
template<typename T> static void unregisterReader()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundFileFactory.hpp:68

Unregister a reader.

**See also**: `[registerReader](#registerreader)`

---

{#isreaderregistered}

### isReaderRegistered

`static` `nodiscard`

```cpp
template<typename T> [[nodiscard]] static bool isReaderRegistered()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundFileFactory.hpp:75

Check if a reader is registered.

---

{#registerwriter}

### registerWriter

`static`

```cpp
template<typename T> static void registerWriter()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundFileFactory.hpp:84

Register a new writer.

**See also**: `[unregisterWriter](#unregisterwriter)`

---

{#unregisterwriter}

### unregisterWriter

`static`

```cpp
template<typename T> static void unregisterWriter()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundFileFactory.hpp:93

Unregister a writer.

**See also**: `[registerWriter](#registerwriter)`

---

{#iswriterregistered}

### isWriterRegistered

`static` `nodiscard`

```cpp
template<typename T> [[nodiscard]] static bool isWriterRegistered()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundFileFactory.hpp:100

Check if a writer is registered.

---

{#createreaderfromfilename}

### createReaderFromFilename

`static` `nodiscard`

```cpp
[[nodiscard]] static std::unique_ptr< SoundFileReader > createReaderFromFilename(const std::filesystem::path & filename)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundFileFactory.hpp:112

Instantiate the right reader for the given file on disk.

#### Returns
A new sound file reader that can read the given file, or `nullptr` if no reader can handle it

**See also**: `[createReaderFromMemory](#createreaderfrommemory)`, `[createReaderFromStream](#createreaderfromstream)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `filename` | `const std::filesystem::path &` | Path of the sound file |

---

{#createreaderfrommemory}

### createReaderFromMemory

`static` `nodiscard`

```cpp
[[nodiscard]] static std::unique_ptr< SoundFileReader > createReaderFromMemory(const void * data, std::size_t sizeInBytes)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundFileFactory.hpp:125

Instantiate the right codec for the given file in memory.

#### Returns
A new sound file codec that can read the given file, or `nullptr` if no codec can handle it

**See also**: `[createReaderFromFilename](#createreaderfromfilename)`, `[createReaderFromStream](#createreaderfromstream)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `const void *` | Pointer to the file data in memory |
| `sizeInBytes` | `std::size_t` | Total size of the file data, in bytes |

---

{#createreaderfromstream}

### createReaderFromStream

`static` `nodiscard`

```cpp
[[nodiscard]] static std::unique_ptr< SoundFileReader > createReaderFromStream(InputStream & stream)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundFileFactory.hpp:137

Instantiate the right codec for the given file in stream.

#### Returns
A new sound file codec that can read the given file, or `nullptr` if no codec can handle it

**See also**: `[createReaderFromFilename](#createreaderfromfilename)`, `[createReaderFromMemory](#createreaderfrommemory)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `stream` | [`InputStream`](sf-InputStream.md#inputstream) & | Source stream to read from |

---

{#createwriterfromfilename}

### createWriterFromFilename

`static` `nodiscard`

```cpp
[[nodiscard]] static std::unique_ptr< SoundFileWriter > createWriterFromFilename(const std::filesystem::path & filename)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundFileFactory.hpp:147

Instantiate the right writer for the given file on disk.

#### Returns
A new sound file writer that can write given file, or `nullptr` if no writer can handle it

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `filename` | `const std::filesystem::path &` | Path of the sound file |

## Private Static Methods

| Return | Name | Description |
|--------|------|-------------|
| `ReaderFactoryMap &` | [`getReaderFactoryMap`](#getreaderfactorymap) `static` `nodiscard` |  |
| `WriterFactoryMap &` | [`getWriterFactoryMap`](#getwriterfactorymap) `static` `nodiscard` |  |

---

{#getreaderfactorymap}

### getReaderFactoryMap

`static` `nodiscard`

```cpp
[[nodiscard]] static ReaderFactoryMap & getReaderFactoryMap()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundFileFactory.hpp:165

---

{#getwriterfactorymap}

### getWriterFactoryMap

`static` `nodiscard`

```cpp
[[nodiscard]] static WriterFactoryMap & getWriterFactoryMap()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundFileFactory.hpp:166

