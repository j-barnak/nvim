{#transformable}

# Transformable

```cpp
#include <Transformable.hpp>
```

```cpp
class Transformable
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transformable.hpp:43

> **Subclassed by:** [`Shape`](sf-Shape.md#shape), [`Sprite`](sf-Sprite.md#sprite), [`Text`](sf-Text.md#text-1)

Decomposed transform defined by a position, a rotation and a scale.

This class is provided for convenience, on top of `[sf::Transform](sf-Transform.md#transform-1)`.

`[sf::Transform](sf-Transform.md#transform-1)`, as a low-level class, offers a great level of flexibility but it is not always convenient to manage. Indeed, one can easily combine any kind of operation, such as a translation followed by a rotation followed by a scaling, but once the result transform is built, there's no way to go backward and, let's say, change only the rotation without modifying the translation and scaling. The entire transform must be recomputed, which means that you need to retrieve the initial translation and scale factors as well, and combine them the same way you did before updating the rotation. This is a tedious operation, and it requires to store all the individual components of the final transform.

That's exactly what `[sf::Transformable](#transformable)` was written for: it hides these variables and the composed transform behind an easy to use interface. You can set or get any of the individual components without worrying about the others. It also provides the composed transform (as a `[sf::Transform](sf-Transform.md#transform-1)`), and keeps it up-to-date.

In addition to the position, rotation and scale, `[sf::Transformable](#transformable)` provides an "origin" component, which represents the local origin of the three other components. Let's take an example with a 10x10 pixels sprite. By default, the sprite is positioned/rotated/scaled relative to its top-left corner, because it is the local point (0, 0). But if we change the origin to be (5, 5), the sprite will be positioned/rotated/scaled around its center instead. And if we set the origin to (10, 10), it will be transformed around its bottom-right corner.

To keep the `[sf::Transformable](#transformable)` class simple, there's only one origin for all the components. You cannot position the sprite relative to its top-left corner while rotating it around its center, for example. To do such things, use `[sf::Transform](sf-Transform.md#transform-1)` directly.

`[sf::Transformable](#transformable)` can be used as a base class. It is often combined with `[sf::Drawable](sf-Drawable.md#drawable)`&ndash; that's what SFML's sprites, texts and shapes do. 
```cpp
class MyEntity : public sf::Transformable, public sf::Drawable
{
    void draw(sf::RenderTarget& target, sf::RenderStates states) const override
    {
        states.transform *= getTransform();
        target.draw(..., states);
    }
};

MyEntity entity;
entity.setPosition({10, 20});
entity.setRotation(sf::degrees(45));
window.draw(entity);
```

It can also be used as a member, if you don't want to use its API directly (because you don't need all its functions, or you have different naming conventions for example). 
```cpp
class MyEntity
{
public:
    void SetPosition(const MyVector& v)
    {
        myTransform.setPosition(v.x(), v.y());
    }

    void Draw(sf::RenderTarget& target) const
    {
        target.draw(..., myTransform.getTransform());
    }

private:
    sf::Transformable myTransform;
};
```

A note on coordinates and undistorted rendering: <br/>
By default, SFML (or more exactly, OpenGL) may interpolate drawable objects such as sprites or texts when rendering. While this allows transitions like slow movements or rotations to appear smoothly, it can lead to unwanted results in some cases, for example blurred or distorted objects. In order to render a `[sf::Drawable](sf-Drawable.md#drawable)` object pixel-perfectly, make sure the involved coordinates allow a 1:1 mapping of pixels in the window to texels (pixels in the texture). More specifically, this means:

* The object's position, origin and scale have no fractional part
* The object's and the view's rotation are a multiple of 90 degrees
* The view's center and size have no fractional part

**See also**: `[sf::Transform](sf-Transform.md#transform-1)`

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`Transformable`](#transformable-1)  | Default constructor. |
|  | [`~Transformable`](#transformable-2) `virtual` | Virtual destructor. |
| `void` | [`setPosition`](#setposition-5)  | set the position of the object |
| `void` | [`setRotation`](#setrotation)  | set the orientation of the object |
| `void` | [`setScale`](#setscale)  | set the scale factors of the object |
| `void` | [`setOrigin`](#setorigin)  | set the local origin of the object |
| [`Vector2f`](sf.md#vector2f) | [`getPosition`](#getposition-7) `const` `nodiscard` | get the position of the object |
| [`Angle`](sf-Angle.md#angle) | [`getRotation`](#getrotation) `const` `nodiscard` | get the orientation of the object |
| [`Vector2f`](sf.md#vector2f) | [`getScale`](#getscale) `const` `nodiscard` | get the current scale of the object |
| [`Vector2f`](sf.md#vector2f) | [`getOrigin`](#getorigin) `const` `nodiscard` | get the local origin of the object |
| `void` | [`move`](#move)  | Move the object by a given offset. |
| `void` | [`rotate`](#rotate-2)  | Rotate the object. |
| `void` | [`scale`](#scale-2)  | Scale the object. |
| const [`Transform`](sf-Transform.md#transform-1) & | [`getTransform`](#gettransform) `const` `nodiscard` | get the combined transform of the object |
| const [`Transform`](sf-Transform.md#transform-1) & | [`getInverseTransform`](#getinversetransform) `const` `nodiscard` | get the inverse of the combined transform of the object |

---

{#transformable-1}

### Transformable

```cpp
Transformable() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transformable.hpp:50

Default constructor.

---

{#transformable-2}

### ~Transformable

`virtual`

```cpp
virtual ~Transformable() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transformable.hpp:56

Virtual destructor.

---

{#setposition-5}

### setPosition

```cpp
void setPosition(Vector2f position)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transformable.hpp:86

set the position of the object

This function completely overwrites the previous position. See the move function to apply an offset based on the previous position instead. The default position of a transformable object is (0, 0).

Note that `[sf::Text](sf-Text.md#text-1)` may appear offset when positioned. This is because its local bounds are influenced by font metrics (e.g. tallest characters) to consistently align with the text's baseline. As such the `getGlobalBounds()` position may not match the position you set.

To account for this offset, the local bounds need to be considered. Either by including it in the position calculation: 
```cpp
text.setPosition(position - text.getLocalBounds().position);
```
 Or by adjusting the text's origin: 
```cpp
text.setOrigin(text.getLocalBounds().position);
text.setPosition(position);
```

**See also**: `[move](#move)`, `[getPosition](#getposition-7)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `position` | [`Vector2f`](sf.md#vector2f) | New position |

---

{#setrotation}

### setRotation

```cpp
void setRotation(Angle angle)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transformable.hpp:100

set the orientation of the object

This function completely overwrites the previous rotation. See the rotate function to add an angle based on the previous rotation instead. The default rotation of a transformable object is 0.

**See also**: `[rotate](#rotate-2)`, `[getRotation](#getrotation)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `angle` | [`Angle`](sf-Angle.md#angle) | New rotation |

---

{#setscale}

### setScale

```cpp
void setScale(Vector2f factors)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transformable.hpp:114

set the scale factors of the object

This function completely overwrites the previous scale. See the scale function to add a factor based on the previous scale instead. The default scale of a transformable object is (1, 1).

**See also**: `[scale](#scale-2)`, `[getScale](#getscale)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `factors` | [`Vector2f`](sf.md#vector2f) | New scale factors |

---

{#setorigin}

### setOrigin

```cpp
void setOrigin(Vector2f origin)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transformable.hpp:131

set the local origin of the object

The origin of an object defines the center point for all transformations (position, scale, rotation). The coordinates of this point must be relative to the top-left corner of the object, and ignore all transformations (position, scale, rotation). The default origin of a transformable object is (0, 0).

**See also**: `[getOrigin](#getorigin)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `origin` | [`Vector2f`](sf.md#vector2f) | New origin |

---

{#getposition-7}

### getPosition

`const` `nodiscard`

```cpp
[[nodiscard]] Vector2f getPosition() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transformable.hpp:141

get the position of the object

#### Returns
Current position

**See also**: `[setPosition](#setposition-5)`

---

{#getrotation}

### getRotation

`const` `nodiscard`

```cpp
[[nodiscard]] Angle getRotation() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transformable.hpp:153

get the orientation of the object

The rotation is always in the range [0, 360].

#### Returns
Current rotation

**See also**: `[setRotation](#setrotation)`

---

{#getscale}

### getScale

`const` `nodiscard`

```cpp
[[nodiscard]] Vector2f getScale() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transformable.hpp:163

get the current scale of the object

#### Returns
Current scale factors

**See also**: `[setScale](#setscale)`

---

{#getorigin}

### getOrigin

`const` `nodiscard`

```cpp
[[nodiscard]] Vector2f getOrigin() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transformable.hpp:173

get the local origin of the object

#### Returns
Current origin

**See also**: `[setOrigin](#setorigin)`

---

{#move}

### move

```cpp
void move(Vector2f offset)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transformable.hpp:190

Move the object by a given offset.

This function adds to the current position of the object, unlike `setPosition` which overwrites it. Thus, it is equivalent to the following code: 
```cpp
object.setPosition(object.getPosition() + offset);
```

**See also**: `[setPosition](#setposition-5)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `offset` | [`Vector2f`](sf.md#vector2f) | Offset |

---

{#rotate-2}

### rotate

```cpp
void rotate(Angle angle)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transformable.hpp:205

Rotate the object.

This function adds to the current rotation of the object, unlike `setRotation` which overwrites it. Thus, it is equivalent to the following code: 
```cpp
object.setRotation(object.getRotation() + angle);
```

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `angle` | [`Angle`](sf-Angle.md#angle) | [Angle](sf-Angle.md#angle) of rotation |

---

{#scale-2}

### scale

```cpp
void scale(Vector2f factor)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transformable.hpp:223

Scale the object.

This function multiplies the current scale of the object, unlike `setScale` which overwrites it. Thus, it is equivalent to the following code: 
```cpp
sf::Vector2f scale = object.getScale();
object.setScale(scale.x * factor.x, scale.y * factor.y);
```

**See also**: `[setScale](#setscale)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `factor` | [`Vector2f`](sf.md#vector2f) | Scale factors |

---

{#gettransform}

### getTransform

`const` `nodiscard`

```cpp
[[nodiscard]] const Transform & getTransform() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transformable.hpp:233

get the combined transform of the object

#### Returns
[Transform](sf-Transform.md#transform-1) combining the position/rotation/scale/origin of the object

**See also**: `[getInverseTransform](#getinversetransform)`

---

{#getinversetransform}

### getInverseTransform

`const` `nodiscard`

```cpp
[[nodiscard]] const Transform & getInverseTransform() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transformable.hpp:243

get the inverse of the combined transform of the object

#### Returns
Inverse of the combined transformations applied to the object

**See also**: `[getTransform](#gettransform)`

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`Vector2f`](sf.md#vector2f) | [`m_origin`](#m_origin)  | Origin of translation/rotation/scaling of the object. |
| [`Vector2f`](sf.md#vector2f) | [`m_position`](#m_position)  | Position of the object in the 2D world. |
| [`Angle`](sf-Angle.md#angle) | [`m_rotation`](#m_rotation)  | Orientation of the object. |
| [`Vector2f`](sf.md#vector2f) | [`m_scale`](#m_scale)  | Scale of the object. |
| [`Transform`](sf-Transform.md#transform-1) | [`m_transform`](#m_transform)  | Combined transformation of the object. |
| [`Transform`](sf-Transform.md#transform-1) | [`m_inverseTransform`](#m_inversetransform)  | Combined transformation of the object. |
| `bool` | [`m_transformNeedUpdate`](#m_transformneedupdate)  | Does the transform need to be recomputed? |
| `bool` | [`m_inverseTransformNeedUpdate`](#m_inversetransformneedupdate)  | Does the transform need to be recomputed? |

---

{#m_origin}

### m_origin

```cpp
Vector2f m_origin
```

Type: [`Vector2f`](sf.md#vector2f)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transformable.hpp:249

Origin of translation/rotation/scaling of the object.

---

{#m_position}

### m_position

```cpp
Vector2f m_position
```

Type: [`Vector2f`](sf.md#vector2f)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transformable.hpp:250

Position of the object in the 2D world.

---

{#m_rotation}

### m_rotation

```cpp
Angle m_rotation
```

Type: [`Angle`](sf-Angle.md#angle)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transformable.hpp:251

Orientation of the object.

---

{#m_scale}

### m_scale

```cpp
Vector2f m_scale {1, 1}
```

Type: [`Vector2f`](sf.md#vector2f)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transformable.hpp:252

Scale of the object.

---

{#m_transform}

### m_transform

```cpp
Transform m_transform
```

Type: [`Transform`](sf-Transform.md#transform-1)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transformable.hpp:253

Combined transformation of the object.

---

{#m_inversetransform}

### m_inverseTransform

```cpp
Transform m_inverseTransform
```

Type: [`Transform`](sf-Transform.md#transform-1)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transformable.hpp:254

Combined transformation of the object.

---

{#m_transformneedupdate}

### m_transformNeedUpdate

```cpp
bool m_transformNeedUpdate {true}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transformable.hpp:255

Does the transform need to be recomputed?

---

{#m_inversetransformneedupdate}

### m_inverseTransformNeedUpdate

```cpp
bool m_inverseTransformNeedUpdate {true}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Transformable.hpp:256

Does the transform need to be recomputed?

