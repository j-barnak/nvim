{#timeoutwithpredicate}

# TimeoutWithPredicate

```cpp
#include <TimeoutWithPredicate.hpp>
```

```cpp
class TimeoutWithPredicate
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/TimeoutWithPredicate.hpp:44

Utility class providing hybrid functionality of a timeout and a continuation predicate.

`[sf::TimeoutWithPredicate](#timeoutwithpredicate)` is a utility class that provides a hybrid of the functionality of a simple time based timeout and a predicate based timeout.

Functions taking a timeout parameter that is specified solely by an `[sf::Time](sf-Time.md#time)` cannot be easily interrupted. This becomes a problem when the time that the function call takes to complete depends on factors that are not within the control of the developer beforehand and thus specifying a fixed timeout value is not possible. Networking functions that transfer varying amounts of data are good examples of this.

In order to maintain backwards compatibility, `[sf::TimeoutWithPredicate](#timeoutwithpredicate)` objects can be implicitly constructed from a simple `[sf::Time](sf-Time.md#time)` value. In this case they provide the same functionality as if the function would have just taken a `[sf::Time](sf-Time.md#time)` timeout parameter as was the case in the past.

If the acceptable duration a function call should run for depends on information that is only available at run time, the `[sf::TimeoutWithPredicate](#timeoutwithpredicate)` object can be constructed from a predicate instead.

The predicate takes no arguments and must return `true` if the function should continue running or `false` if the function should end as soon as possible with a timeout error.

Functions that support taking a `[sf::TimeoutWithPredicate](#timeoutwithpredicate)` internally break their implementation down into discrete phases after which the predicate is re-evalutated. If a phase itself requires calling a blocking function, the timeout value provided to the blocking function is specified by providing a period value when initially constructing the `[sf::TimeoutWithPredicate](#timeoutwithpredicate)` object.

The optional `period` parameter is merely a hint to the implementation specifying the frequency at which the predicate should be re-evaluated. Depending on the concrete function that is called and how it is implemented the re-evaluation frequency can be kept as close as possible to the specified `period` value or when it is not possible the `period` value will not be respected at all.

Any callable object can be passed as the predicate. This includes lambda expressions, `std::function` objects and function pointers.

The predicate will be evaluated from the execution context of the function call in which the `[sf::TimeoutWithPredicate](#timeoutwithpredicate)` is passed. If the predicate relies on evaluating data that is set from another execution context e.g. another thread while the function call is still in progress care has to be taken to ensure proper synchronization to avoid data races between multiple threads that simultaneously read and write to the shared data.

Usage example: 
```cpp
// Simple timeout, implicitly constructed, not interruptible
const auto result = blockingFunction(sf::milliseconds(1000));

... Check result to see if the function timed out ...

// Predicate timeout, based on data provided
// by the function call itself
std::vector<char> buffer;
const auto readResult = readDataIntoBuffer(buffer, [&buffer]
{
    // Keep reading data until we have at least 1024 bytes
    return buffer.size() <= 1024u;
});

... Check result to see if the function timed out ...
// In this case a "timeout" could also mean the
// buffer contains at least 1024 bytes of data

// Predicate timeout, based on data shared by multiple threads
// Set evalutation frequency to 100 milliseconds
std::vector<char> receivedData;
std::mutex mutex;
bool applicationRunning = true;
std::thread workerThread([&]
{
    const auto result = receiveDataFromNetwork(receivedData, [&]
    {
        const std::lock_guard lock(mutex);
        return applicationRunning;
    }, sf::milliseconds(100));

    ... Check result to see if the function timed out ...
    // In this case a "timeout" could also mean
    // application exit was requested
});

...

// The user requested to exit the application
{
    const std::lock_guard lock(mutex);
    applicationRunning = false;
}
workerThread.join();
```

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`TimeoutWithPredicate`](#timeoutwithpredicate-1)  | Constructor. |
|  | [`TimeoutWithPredicate`](#timeoutwithpredicate-2)  | Constructor. |
| `const std::function< bool()> &` | [`getPredicate`](#getpredicate) `const` `nodiscard` | Get the predicate. |
| const [`Time`](sf-Time.md#time) & | [`getPeriod`](#getperiod) `const` `nodiscard` | Get the period. |

---

{#timeoutwithpredicate-1}

### TimeoutWithPredicate

```cpp
TimeoutWithPredicate(Time timeout)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/TimeoutWithPredicate.hpp:56

Constructor.

This constructor constructs a `[TimeoutWithPredicate](#timeoutwithpredicate)` object that times out after the given amount of time.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `timeout` | [`Time`](sf-Time.md#time) | [Time](sf-Time.md#time) to timeout after |

---

{#timeoutwithpredicate-2}

### TimeoutWithPredicate

```cpp
TimeoutWithPredicate(std::function< bool()> predicate, Time period = milliseconds(1))
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/TimeoutWithPredicate.hpp:73

Constructor.

This constructor constructs a `[TimeoutWithPredicate](#timeoutwithpredicate)` object that times out when the given predicate returns `false`. The frequency at which predicate is checked is specified by `period`.

If an empty predicate is passed, it will be set to a predicate that returns `false` when called.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `predicate` | `std::function< bool()>` | Predicate that returns `true` to continue or `false` to timeout |
| `period` | [`Time`](sf-Time.md#time) | The period between checks of the predicate |

---

{#getpredicate}

### getPredicate

`const` `nodiscard`

```cpp
[[nodiscard]] const std::function< bool()> & getPredicate() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/TimeoutWithPredicate.hpp:81

Get the predicate.

#### Returns
The predicate

---

{#getperiod}

### getPeriod

`const` `nodiscard`

```cpp
[[nodiscard]] const Time & getPeriod() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/TimeoutWithPredicate.hpp:89

Get the period.

#### Returns
The period

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::function< bool()>` | [`m_predicate`](#m_predicate)  | The contained predicate. |
| [`Time`](sf-Time.md#time) | [`m_period`](#m_period)  | The contained period. |

---

{#m_predicate}

### m_predicate

```cpp
std::function< bool()> m_predicate
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/TimeoutWithPredicate.hpp:95

The contained predicate.

---

{#m_period}

### m_period

```cpp
Time m_period
```

Type: [`Time`](sf-Time.md#time)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/TimeoutWithPredicate.hpp:96

The contained period.

