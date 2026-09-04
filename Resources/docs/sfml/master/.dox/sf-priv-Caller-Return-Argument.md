{#callerreturnargument}

# Caller< Return(*)(Argument)>

```cpp
template<typename Return, typename Argument>
struct Caller< Return(*)(Argument)>
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.inl:83

> **Inherits:** `Return(*)(Argument)`

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `Return(*` | [`function`](#function)  |  |

---

{#function}

### function

```cpp
Return(* function)(Argument)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.inl:89

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
| `Return` | [`operator()`](#operator-172) `inline` |  |

---

{#operator-172}

### operator()

`inline`

```cpp
inline Return operator()(Argument && argument)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/WindowBase.inl:85

