{#sensorchanged}

# SensorChanged

```cpp
#include <Event.hpp>
```

```cpp
struct SensorChanged
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:302

[Sensor](sf-Sensor.md#sensor) event subtype.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`Sensor::Type`](Type.md#type-2) | [`type`](#type-1)  | Type of the sensor. |
| [`Vector3f`](sf.md#vector3f) | [`value`](#value)  | Current value of the sensor on the X, Y, and Z axes. |

---

{#type-1}

### type

```cpp
Sensor::Type type {}
```

Type: [`Sensor::Type`](Type.md#type-2)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:304

Type of the sensor.

---

{#value}

### value

```cpp
Vector3f value
```

Type: [`Vector3f`](sf.md#vector3f)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:305

Current value of the sensor on the X, Y, and Z axes.

