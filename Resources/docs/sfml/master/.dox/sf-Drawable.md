{#drawable}

# Drawable

```cpp
#include <Drawable.hpp>
```

```cpp
class Drawable
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Drawable.hpp:43

> **Subclassed by:** [`Shape`](sf-Shape.md#shape), [`Sprite`](sf-Sprite.md#sprite), [`Text`](sf-Text.md#text-1), [`VertexArray`](sf-VertexArray.md#vertexarray), [`VertexBuffer`](sf-VertexBuffer.md#vertexbuffer)

Abstract base class for objects that can be drawn to a render target.

`[sf::Drawable](#drawable)` is a very simple base class that allows objects of derived classes to be drawn to a `[sf::RenderTarget](sf-RenderTarget.md#rendertarget-1)`.

All you have to do in your derived class is to override the draw virtual function.

Note that inheriting from `[sf::Drawable](#drawable)` is not mandatory, but it allows this nice syntax `window.draw(object)` rather than `object.draw(window)`, which is more consistent with other SFML classes.

Example: 
```cpp
class MyDrawable : public sf::Drawable
{
public:

   ...

private:

    void draw(sf::RenderTarget& target, sf::RenderStates states) const override
    {
        // You can draw other high-level objects
        target.draw(m_sprite, states);

        // ... or use the low-level API
        states.texture = &m_texture;
        target.draw(m_vertices, states);

        // ... or draw with OpenGL directly
        glBegin(GL_TRIANGLES);
        ...
        glEnd();
    }

    sf::Sprite m_sprite;
    sf::Texture m_texture;
    sf::VertexArray m_vertices;
};
```

**See also**: `[sf::RenderTarget](sf-RenderTarget.md#rendertarget-1)`

## Friends

| Name | Description |
|------|-------------|
| [`RenderTarget`](#rendertarget)  |  |

---

{#rendertarget}

### RenderTarget

```cpp
friend class RenderTarget
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Drawable.hpp:53

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`~Drawable`](#drawable-1) `virtual` | Virtual destructor. |

---

{#drawable-1}

### ~Drawable

`virtual`

```cpp
virtual ~Drawable() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Drawable.hpp:50

Virtual destructor.

## Protected Methods

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`draw`](#draw) `virtual` `const` | Draw the object to a render target. |

---

{#draw}

### draw

`virtual` `const`

```cpp
virtual void draw(RenderTarget & target, RenderStates states) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Drawable.hpp:66

Draw the object to a render target.

This is a pure virtual function that has to be implemented by the derived class to define how the drawable should be drawn.

#### Reimplemented by

- [`draw`](sf-Shape.md#draw-5)
- [`draw`](sf-Sprite.md#draw-6)
- [`draw`](sf-Text.md#draw-7)
- [`draw`](sf-VertexArray.md#draw-8)
- [`draw`](sf-VertexBuffer.md#draw-9)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `target` | [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) & | Render target to draw to |
| `states` | [`RenderStates`](sf-RenderStates.md#renderstates) | Current render states |

