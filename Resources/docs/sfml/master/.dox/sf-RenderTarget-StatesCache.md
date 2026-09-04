{#statescache}

# StatesCache

```cpp
struct StatesCache
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:548

Render states cache.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `bool` | [`enable`](#enable)  | Is the cache enabled? |
| `bool` | [`glStatesSet`](#glstatesset)  | Are our internal GL states set yet? |
| `bool` | [`viewChanged`](#viewchanged)  | Has the current view changed since last draw? |
| `bool` | [`scissorEnabled`](#scissorenabled)  | Is scissor testing enabled? |
| `bool` | [`stencilEnabled`](#stencilenabled)  | Is stencil testing enabled? |
| [`BlendMode`](sf-BlendMode.md#blendmode) | [`lastBlendMode`](#lastblendmode)  | Cached blending mode. |
| [`StencilMode`](sf-StencilMode.md#stencilmode-1) | [`lastStencilMode`](#laststencilmode)  | Cached stencil. |
| `std::uint64_t` | [`lastTextureId`](#lasttextureid)  | Cached texture. |
| [`CoordinateType`](CoordinateType.md#coordinatetype) | [`lastCoordinateType`](#lastcoordinatetype)  | [Texture](sf-Texture.md#texture-2) coordinate type. |
| `bool` | [`texCoordsArrayEnabled`](#texcoordsarrayenabled)  | Is `GL_TEXTURE_COORD_ARRAY` client state enabled? |
| `bool` | [`useVertexCache`](#usevertexcache)  | Did we previously use the vertex cache? |
| std::array< [`Vertex`](sf-Vertex.md#vertex), 4 > | [`vertexCache`](#vertexcache)  | Pre-transformed vertices cache. |

---

{#enable}

### enable

```cpp
bool enable {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:550

Is the cache enabled?

---

{#glstatesset}

### glStatesSet

```cpp
bool glStatesSet {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:551

Are our internal GL states set yet?

---

{#viewchanged}

### viewChanged

```cpp
bool viewChanged {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:552

Has the current view changed since last draw?

---

{#scissorenabled}

### scissorEnabled

```cpp
bool scissorEnabled {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:553

Is scissor testing enabled?

---

{#stencilenabled}

### stencilEnabled

```cpp
bool stencilEnabled {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:554

Is stencil testing enabled?

---

{#lastblendmode}

### lastBlendMode

```cpp
BlendMode lastBlendMode
```

Type: [`BlendMode`](sf-BlendMode.md#blendmode)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:555

Cached blending mode.

---

{#laststencilmode}

### lastStencilMode

```cpp
StencilMode lastStencilMode
```

Type: [`StencilMode`](sf-StencilMode.md#stencilmode-1)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:556

Cached stencil.

---

{#lasttextureid}

### lastTextureId

```cpp
std::uint64_t lastTextureId {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:557

Cached texture.

---

{#lastcoordinatetype}

### lastCoordinateType

```cpp
CoordinateType lastCoordinateType {}
```

Type: [`CoordinateType`](CoordinateType.md#coordinatetype)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:558

[Texture](sf-Texture.md#texture-2) coordinate type.

---

{#texcoordsarrayenabled}

### texCoordsArrayEnabled

```cpp
bool texCoordsArrayEnabled {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:559

Is `GL_TEXTURE_COORD_ARRAY` client state enabled?

---

{#usevertexcache}

### useVertexCache

```cpp
bool useVertexCache {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:560

Did we previously use the vertex cache?

---

{#vertexcache}

### vertexCache

```cpp
std::array< Vertex, 4 > vertexCache {}
```

Type: std::array< [`Vertex`](sf-Vertex.md#vertex), 4 >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:561

Pre-transformed vertices cache.

