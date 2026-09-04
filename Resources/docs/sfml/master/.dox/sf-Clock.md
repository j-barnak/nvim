{#clock}

# Clock

```cpp
#include <Clock.hpp>
```

```cpp
class Clock
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Clock.hpp:91

Utility class that measures the elapsed time.

The clock starts automatically after being constructed.

`[sf::Clock](#clock)` is a lightweight class for measuring time.

It provides the most precise time that the underlying OS can achieve (generally microseconds or nanoseconds). It also ensures monotonicity, which means that the returned time can never go backward, even if the system time is changed.

Usage example: 
```cpp
sf::Clock clock;
...
Time time1 = clock.getElapsedTime();
...
Time time2 = clock.restart();
...
Time time3 = clock.reset();
```

The `[sf::Time](sf-Time.md#time)` value returned by the clock can then be converted to a number of seconds, milliseconds or even microseconds.

**See also**: `[sf::Time](sf-Time.md#time)`

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
| [`Time`](sf-Time.md#time) | [`getElapsedTime`](#getelapsedtime) `const` `nodiscard` | Get the elapsed time. |
| `bool` | [`isRunning`](#isrunning) `const` `nodiscard` | Check whether the clock is running. |
| `void` | [`start`](#start-1)  | Start the clock. |
| `void` | [`stop`](#stop-4)  | Stop the clock. |
| [`Time`](sf-Time.md#time) | [`restart`](#restart)  | Restart the clock. |
| [`Time`](sf-Time.md#time) | [`reset`](#reset)  | Reset the clock. |

---

{#getelapsedtime}

### getElapsedTime

`const` `nodiscard`

```cpp
[[nodiscard]] Time getElapsedTime() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Clock.hpp:104

Get the elapsed time.

This function returns the time elapsed since the last call to `[restart()](#restart)` (or the construction of the instance if `[restart()](#restart)` has not been called).

#### Returns
[Time](sf-Time.md#time) elapsed

---

{#isrunning}

### isRunning

`const` `nodiscard`

```cpp
[[nodiscard]] bool isRunning() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Clock.hpp:112

Check whether the clock is running.

#### Returns
`true` if the clock is running, `false` otherwise

---

{#start-1}

### start

```cpp
void start()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Clock.hpp:120

Start the clock.

**See also**: `[stop](#stop-4)`

---

{#stop-4}

### stop

```cpp
void stop()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Clock.hpp:128

Stop the clock.

**See also**: `[start](#start-1)`

---

{#restart}

### restart

```cpp
Time restart()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Clock.hpp:141

Restart the clock.

This function puts the time counter back to zero, returns the elapsed time, and leaves the clock in a running state.

#### Returns
[Time](sf-Time.md#time) elapsed

**See also**: `[reset](#reset)`

---

{#reset}

### reset

```cpp
Time reset()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Clock.hpp:154

Reset the clock.

This function puts the time counter back to zero, returns the elapsed time, and leaves the clock in a paused state.

#### Returns
[Time](sf-Time.md#time) elapsed

**See also**: `[restart](#restart)`

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `priv::ClockImpl::time_point` | [`m_refPoint`](#m_refpoint)  | [Time](sf-Time.md#time) of last reset. |
| `priv::ClockImpl::time_point` | [`m_stopPoint`](#m_stoppoint)  | [Time](sf-Time.md#time) of last stop. |

---

{#m_refpoint}

### m_refPoint

```cpp
priv::ClockImpl::time_point m_refPoint {priv::ClockImpl::now()}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Clock.hpp:160

[Time](sf-Time.md#time) of last reset.

---

{#m_stoppoint}

### m_stopPoint

```cpp
priv::ClockImpl::time_point m_stopPoint
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Clock.hpp:161

[Time](sf-Time.md#time) of last stop.

