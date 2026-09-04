{#callerhandler}

# Caller< Handler & >

```cpp
template<typename Handler>
struct Caller< Handler & >
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.inl:69

> **Inherits:** `Handler`

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `Handler &` | [`handler`](#handler)  |  |

---

{#handler}

### handler

```cpp
Handler & handler
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.inl:77

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
| `decltype(auto)` | [`operator()`](#operator-171) `inline` |  |

---

{#operator-171}

### operator()

`inline`

```cpp
template<typename Argument, std::enable_if_t< std::is_invocable_v< Handler &, Argument >, int > = 0> inline decltype(auto) operator()(Argument && argument)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.inl:73

