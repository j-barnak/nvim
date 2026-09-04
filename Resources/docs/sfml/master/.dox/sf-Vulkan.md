{#vulkan}

# Vulkan

[Vulkan](#vulkan) helper functions.

This namespace contains functions to help you use SFML for windowing and write your own [Vulkan](#vulkan) code for graphics

## Functions

| Return | Name | Description |
|--------|------|-------------|
| [`SFML_WINDOW_API`](api.md#sfml_window_api) bool | [`isAvailable`](#isavailable-2) `nodiscard` | Tell whether or not the system supports [Vulkan](#vulkan). |
| [`SFML_WINDOW_API`](api.md#sfml_window_api)[`VulkanFunctionPointer`](sf.md#vulkanfunctionpointer) | [`getFunction`](#getfunction-1) `nodiscard` | Get the address of a [Vulkan](#vulkan) function. |
| [`SFML_WINDOW_API`](api.md#sfml_window_api) const std::vector< const char * > & | [`getGraphicsRequiredInstanceExtensions`](#getgraphicsrequiredinstanceextensions) `nodiscard` | Get [Vulkan](#vulkan) instance extensions required for graphics. |

---

{#isavailable-2}

### isAvailable

`nodiscard`

```cpp
[[nodiscard]] SFML_WINDOW_API bool isAvailable(bool requireGraphics = true)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Vulkan.hpp:81

Tell whether or not the system supports [Vulkan](#vulkan).

This function should always be called before using the [Vulkan](#vulkan) features. If it returns `false`, then any attempt to use [Vulkan](#vulkan) will fail.

If only compute is required, set `requireGraphics` to `false` to skip checking for the extensions necessary for graphics rendering.

#### Returns
`true` if [Vulkan](#vulkan) is supported, `false` otherwise

---

{#getfunction-1}

### getFunction

`nodiscard`

```cpp
[[nodiscard]] SFML_WINDOW_APIVulkanFunctionPointer getFunction(const char * name)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Vulkan.hpp:91

Get the address of a [Vulkan](#vulkan) function.

#### Returns
Address of the [Vulkan](#vulkan) function, `nullptr` on failure

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const char *` | Name of the function to get the address of |

---

{#getgraphicsrequiredinstanceextensions}

### getGraphicsRequiredInstanceExtensions

`nodiscard`

```cpp
[[nodiscard]] SFML_WINDOW_API const std::vector< const char * > & getGraphicsRequiredInstanceExtensions()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Vulkan.hpp:99

Get [Vulkan](#vulkan) instance extensions required for graphics.

#### Returns
[Vulkan](#vulkan) instance extensions required for graphics

