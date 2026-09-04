{#glresource}

# GlResource

```cpp
#include <GlResource.hpp>
```

```cpp
class GlResource
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/GlResource.hpp:41

> **Subclassed by:** [`Context`](sf-Context.md#context), [`Shader`](sf-Shader.md#shader-1), [`Texture`](sf-Texture.md#texture-2), [`VertexBuffer`](sf-VertexBuffer.md#vertexbuffer), [`Window`](sf-Window.md#window)

Base class for classes that require an OpenGL context.

This class is for internal use only, it must be the base of every class that requires a valid OpenGL context in order to work.

## Protected Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`GlResource`](#glresource-1)  | Default constructor. |

---

{#glresource-1}

### GlResource

```cpp
GlResource()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/GlResource.hpp:48

Default constructor.

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::shared_ptr< void >` | [`m_sharedContext`](#m_sharedcontext)  | Shared context used to link all contexts together for resource sharing. |

---

{#m_sharedcontext}

### m_sharedContext

```cpp
std::shared_ptr< void > m_sharedContext
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/GlResource.hpp:106

Shared context used to link all contexts together for resource sharing.

