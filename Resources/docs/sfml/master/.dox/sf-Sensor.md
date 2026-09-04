{#sensor}

# Sensor

Give access to the real-time state of the sensors.

`[sf::Sensor](#sensor)` provides an interface to the state of the various sensors that a device provides.

This namespace allows users to query the sensors values at any time and directly, without having to deal with a window and its events. Compared to the SensorChanged event, `[sf::Sensor](#sensor)` can retrieve the state of a sensor at any time (you don't need to store and update its current value on your side).

Depending on the OS and hardware of the device (phone, tablet, ...), some sensor types may not be available. You should always check the availability of a sensor before trying to read it, with the `[sf::Sensor::isAvailable](#isavailable-1)` function.

You may wonder why some sensor types look so similar, for example Accelerometer and Gravity / UserAcceleration. The first one is the raw measurement of the acceleration, and takes into account both the earth gravity and the user movement. The others are more precise: they provide these components separately, which is usually more useful. In fact they are not direct sensors, they are computed internally based on the raw acceleration and other sensors. This is exactly the same for Gyroscope vs Orientation.

Because sensors consume a non-negligible amount of current, they are all disabled by default. You must call `[sf::Sensor::setEnabled](#setenabled)` for each sensor in which you are interested.

Usage example: 
```cpp
if (sf::Sensor::isAvailable(sf::Sensor::Type::Gravity))
{
    // gravity sensor is available
}

// enable the gravity sensor
sf::Sensor::setEnabled(sf::Sensor::Type::Gravity, true);

// get the current value of gravity
sf::Vector3f gravity = sf::Sensor::getValue(sf::Sensor::Type::Gravity);
```

## Enumerations

| Name | Description |
|------|-------------|
| [`Type`](#type-2)  | [Sensor](#sensor) type. |

---

{#type-2}

### Type

```cpp
enum Type
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Sensor.hpp:44

[Sensor](#sensor) type.

| Value | Description |
|-------|-------------|
| `Accelerometer` | Measures the raw acceleration (m/s^2) |
| `Gyroscope` | Measures the raw rotation rates (radians/s) |
| `Magnetometer` | Measures the ambient magnetic field (micro-teslas) |
| `Gravity` | Measures the direction and intensity of gravity, independent of device acceleration (m/s^2) |
| `UserAcceleration` | Measures the direction and intensity of device acceleration, independent of the gravity (m/s^2) |
| `Orientation` | Measures the absolute 3D orientation (radians) |
## Functions

| Return | Name | Description |
|--------|------|-------------|
| [`SFML_WINDOW_API`](api.md#sfml_window_api) bool | [`isAvailable`](#isavailable-1) `nodiscard` | Check if a sensor is available on the underlying platform. |
| [`SFML_WINDOW_API`](api.md#sfml_window_api) void | [`setEnabled`](#setenabled)  | Enable or disable a sensor. |
| [`SFML_WINDOW_API`](api.md#sfml_window_api)[`Vector3f`](sf.md#vector3f) | [`getValue`](#getvalue) `nodiscard` | Get the current sensor value. |

---

{#isavailable-1}

### isAvailable

`nodiscard`

```cpp
[[nodiscard]] SFML_WINDOW_API bool isAvailable(Type sensor)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Sensor.hpp:65

Check if a sensor is available on the underlying platform.

#### Returns
`true` if the sensor is available, `false` otherwise

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `sensor` | [`Type`](Type.md#type-2) | [Sensor](#sensor) to check |

---

{#setenabled}

### setEnabled

```cpp
SFML_WINDOW_API void setEnabled(Type sensor, bool enabled)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Sensor.hpp:80

Enable or disable a sensor.

All sensors are disabled by default, to avoid consuming too much battery power. Once a sensor is enabled, it starts sending events of the corresponding type.

This function does nothing if the sensor is unavailable.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `sensor` | [`Type`](Type.md#type-2) | [Sensor](#sensor) to enable |
| `enabled` | `bool` | `true` to enable, `false` to disable |

---

{#getvalue}

### getValue

`nodiscard`

```cpp
[[nodiscard]] SFML_WINDOW_APIVector3f getValue(Type sensor)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Sensor.hpp:90

Get the current sensor value.

#### Returns
The current sensor value

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `sensor` | [`Type`](Type.md#type-2) | [Sensor](#sensor) to read |

## Variables

| Return | Name | Description |
|--------|------|-------------|
| `unsigned int` | [`Count`](#count-1) `static` `constexpr` | The total number of sensor types. |

---

{#count-1}

### Count

`static` `constexpr`

```cpp
unsigned int Count {6}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Sensor.hpp:55

The total number of sensor types.

