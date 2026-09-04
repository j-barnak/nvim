{#suspendawareclock}

# SuspendAwareClock

```cpp
#include <SuspendAwareClock.hpp>
```

```cpp
struct SuspendAwareClock
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/SuspendAwareClock.hpp:54

Android, chrono-compatible, suspend-aware clock.

Linux steady clock is represented by `CLOCK_MONOTONIC`. However, this implementation does not work properly for long-running clocks that work in the background when the system is suspended.

`[SuspendAwareClock](#suspendawareclock)` uses `CLOCK_BOOTTIME` which is identical to `CLOCK_MONOTONIC`, except that it also includes any time that the system is suspended.

Note: In most cases, `CLOCK_MONOTONIC` is a better choice. Make sure this implementation is required for your use case.

## Public Static Attributes

| Return | Name | Description |
|--------|------|-------------|
| `bool` | [`is_steady`](#is_steady) `static` `constexpr` |  |

---

{#is_steady}

### is_steady

`static` `constexpr`

```cpp
bool is_steady = true
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/SuspendAwareClock.hpp:71

## Public Static Methods

| Return | Name | Description |
|--------|------|-------------|
| [`time_point`](#time_point) | [`now`](#now) `static` `noexcept` |  |

---

{#now}

### now

`static` `noexcept`

```cpp
static time_point now() noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/SuspendAwareClock.hpp:73

## Public Types

| Name | Description |
|------|-------------|
| [`duration`](#duration)  | Type traits and static members. |
| [`rep`](#rep)  |  |
| [`period`](#period)  |  |
| [`time_point`](#time_point)  |  |

---

{#duration}

### duration

```cpp
using duration = std::chrono::nanoseconds
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/SuspendAwareClock.hpp:66

Type traits and static members.

These type traits and static members meet the requirements of a [Clock](sf-Clock.md#clock) concept in the C++ Standard. More specifically, TrivialClock requirements are met. Thus, naming convention has been kept consistent to allow for extended use e.g. [https://en.cppreference.com/w/cpp/chrono/is_clock](https://en.cppreference.com/w/cpp/chrono/is_clock)

---

{#rep}

### rep

```cpp
using rep = duration::rep
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/SuspendAwareClock.hpp:67

---

{#period}

### period

```cpp
using period = duration::period
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/SuspendAwareClock.hpp:68

---

{#time_point}

### time_point

```cpp
using time_point = std::chrono::time_point< SuspendAwareClock, duration >
```

Type: std::chrono::time_point< [`SuspendAwareClock`](#suspendawareclock), [`duration`](#duration) >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/SuspendAwareClock.hpp:69

