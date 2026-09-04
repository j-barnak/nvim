{#renderwindow}

# RenderWindow

```cpp
#include <RenderWindow.hpp>
```

```cpp
class RenderWindow
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderWindow.hpp:54

> **Inherits:** [`Window`](sf-Window.md#window), [`RenderTarget`](sf-RenderTarget.md#rendertarget-1)

[Window](sf-Window.md#window) that can serve as a target for 2D drawing.

`[sf::RenderWindow](#renderwindow)` is the main class of the Graphics module. It defines an OS window that can be painted using the other classes of the graphics module.

`[sf::RenderWindow](#renderwindow)` is derived from `[sf::Window](sf-Window.md#window)`, thus it inherits all its features: events, window management, OpenGL rendering, etc. See the documentation of `[sf::Window](sf-Window.md#window)` for a more complete description of all these features, as well as code examples.

On top of that, `[sf::RenderWindow](#renderwindow)` adds more features related to 2D drawing with the graphics module (see its base class `[sf::RenderTarget](sf-RenderTarget.md#rendertarget-1)` for more details). Here is a typical rendering and event loop with a `[sf::RenderWindow](#renderwindow)`:

```cpp
// Declare and create a new render-window
sf::RenderWindow window(sf::VideoMode({800, 600}), "SFML window");

// Limit the framerate to 60 frames per second (this step is optional)
window.setFramerateLimit(60);

// The main loop - ends as soon as the window is closed
while (window.isOpen())
{
   // Event processing
   while (const std::optional event = window.pollEvent())
   {
       // Request for closing the window
       if (event->is<sf::Event::Closed>())
           window.close();
   }

   // Clear the whole window before rendering a new frame
   window.clear();

   // Draw some graphical entities
   window.draw(sprite);
   window.draw(circle);
   window.draw(text);

   // End the current frame and display its contents on screen
   window.display();
}
```

Like `[sf::Window](sf-Window.md#window)`, `[sf::RenderWindow](#renderwindow)` is still able to render direct OpenGL stuff. It is even possible to mix together OpenGL calls and regular SFML drawing commands.

```cpp
// Create the render window
sf::RenderWindow window(sf::VideoMode({800, 600}), "SFML OpenGL");

// Create a sprite and a text to display
const sf::Texture texture("circle.png");
sf::Sprite sprite(texture);
const sf::Font font("arial.ttf");
sf::Text text(font);
...

// Perform OpenGL initializations
glMatrixMode(GL_PROJECTION);
...

// Start the rendering loop
while (window.isOpen())
{
    // Process events
    ...

    // Draw a background sprite
    window.pushGLStates();
    window.draw(sprite);
    window.popGLStates();

    // Draw a 3D object using OpenGL
    glBegin(GL_TRIANGLES);
        glVertex3f(...);
        ...
    glEnd();

    // Draw text on top of the 3D object
    window.pushGLStates();
    window.draw(text);
    window.popGLStates();

    // Finally, display the rendered frame on screen
    window.display();
}
```

**See also**: `[sf::Window](sf-Window.md#window)`, `[sf::RenderTarget](sf-RenderTarget.md#rendertarget-1)`, `[sf::RenderTexture](sf-RenderTexture.md#rendertexture)`, `[sf::View](sf-View.md#view)`

## List of all members

| Name | Kind | Owner |
|------|------|-------|
| [`RenderWindow`](#renderwindow-1) | `function` | Declared here |
| [`RenderWindow`](#renderwindow-2) | `function` | Declared here |
| [`RenderWindow`](#renderwindow-3) | `function` | Declared here |
| [`RenderWindow`](#renderwindow-4) | `function` | Declared here |
| [`getSize`](#getsize-9) | `function` | Declared here |
| [`setIcon`](#seticon-1) | `function` | Declared here |
| [`isSrgb`](#issrgb-2) | `function` | Declared here |
| [`setActive`](#setactive-4) | `function` | Declared here |
| [`onCreate`](#oncreate-1) | `function` | Declared here |
| [`onResize`](#onresize-1) | `function` | Declared here |
| [`m_defaultFrameBuffer`](#m_defaultframebuffer) | `variable` | Declared here |
| [`Window`](sf-Window.md#window-1) | `function` | Inherited from [`Window`](sf-Window.md#window) |
| [`Window`](sf-Window.md#window-2) | `function` | Inherited from [`Window`](sf-Window.md#window) |
| [`Window`](sf-Window.md#window-3) | `function` | Inherited from [`Window`](sf-Window.md#window) |
| [`Window`](sf-Window.md#window-4) | `function` | Inherited from [`Window`](sf-Window.md#window) |
| [`~Window`](sf-Window.md#window-5) | `function` | Inherited from [`Window`](sf-Window.md#window) |
| [`Window`](sf-Window.md#window-6) | `function` | Inherited from [`Window`](sf-Window.md#window) |
| [`operator=`](sf-Window.md#operator-22) | `function` | Inherited from [`Window`](sf-Window.md#window) |
| [`Window`](sf-Window.md#window-7) | `function` | Inherited from [`Window`](sf-Window.md#window) |
| [`operator=`](sf-Window.md#operator-23) | `function` | Inherited from [`Window`](sf-Window.md#window) |
| [`create`](sf-Window.md#create) | `function` | Inherited from [`Window`](sf-Window.md#window) |
| [`create`](sf-Window.md#create-1) | `function` | Inherited from [`Window`](sf-Window.md#window) |
| [`create`](sf-Window.md#create-2) | `function` | Inherited from [`Window`](sf-Window.md#window) |
| [`create`](sf-Window.md#create-3) | `function` | Inherited from [`Window`](sf-Window.md#window) |
| [`create`](sf-Window.md#create-4) | `function` | Inherited from [`Window`](sf-Window.md#window) |
| [`create`](sf-Window.md#create-5) | `function` | Inherited from [`Window`](sf-Window.md#window) |
| [`close`](sf-Window.md#close-2) | `function` | Inherited from [`Window`](sf-Window.md#window) |
| [`getSettings`](sf-Window.md#getsettings-1) | `function` | Inherited from [`Window`](sf-Window.md#window) |
| [`setVerticalSyncEnabled`](sf-Window.md#setverticalsyncenabled) | `function` | Inherited from [`Window`](sf-Window.md#window) |
| [`setFramerateLimit`](sf-Window.md#setframeratelimit) | `function` | Inherited from [`Window`](sf-Window.md#window) |
| [`setActive`](sf-Window.md#setactive-1) | `function` | Inherited from [`Window`](sf-Window.md#window) |
| [`display`](sf-Window.md#display) | `function` | Inherited from [`Window`](sf-Window.md#window) |
| [`m_context`](sf-Window.md#m_context-1) | `variable` | Inherited from [`Window`](sf-Window.md#window) |
| [`m_clock`](sf-Window.md#m_clock) | `variable` | Inherited from [`Window`](sf-Window.md#window) |
| [`m_frameTimeLimit`](sf-Window.md#m_frametimelimit) | `variable` | Inherited from [`Window`](sf-Window.md#window) |
| [`initialize`](sf-Window.md#initialize-2) | `function` | Inherited from [`Window`](sf-Window.md#window) |
| [`Window`](sf-WindowBase.md#window-8) | `friend` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`WindowBase`](sf-WindowBase.md#windowbase-3) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`WindowBase`](sf-WindowBase.md#windowbase-4) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`WindowBase`](sf-WindowBase.md#windowbase-5) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`WindowBase`](sf-WindowBase.md#windowbase-6) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`~WindowBase`](sf-WindowBase.md#windowbase-7) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`WindowBase`](sf-WindowBase.md#windowbase-8) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`operator=`](sf-WindowBase.md#operator-24) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`WindowBase`](sf-WindowBase.md#windowbase-9) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`operator=`](sf-WindowBase.md#operator-25) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`create`](sf-WindowBase.md#create-6) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`create`](sf-WindowBase.md#create-7) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`create`](sf-WindowBase.md#create-8) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`close`](sf-WindowBase.md#close-3) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`isOpen`](sf-WindowBase.md#isopen) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`pollEvent`](sf-WindowBase.md#pollevent) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`waitEvent`](sf-WindowBase.md#waitevent) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`handleEvents`](sf-WindowBase.md#handleevents) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`getPosition`](sf-WindowBase.md#getposition-2) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`setPosition`](sf-WindowBase.md#setposition-2) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`getSize`](sf-WindowBase.md#getsize-4) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`setSize`](sf-WindowBase.md#setsize) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`setMinimumSize`](sf-WindowBase.md#setminimumsize) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`setMaximumSize`](sf-WindowBase.md#setmaximumsize) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`setTitle`](sf-WindowBase.md#settitle) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`setIcon`](sf-WindowBase.md#seticon) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`setVisible`](sf-WindowBase.md#setvisible) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`setMouseCursorVisible`](sf-WindowBase.md#setmousecursorvisible) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`setMouseCursorGrabbed`](sf-WindowBase.md#setmousecursorgrabbed) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`setMouseCursor`](sf-WindowBase.md#setmousecursor) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`setKeyRepeatEnabled`](sf-WindowBase.md#setkeyrepeatenabled) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`setJoystickThreshold`](sf-WindowBase.md#setjoystickthreshold) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`requestFocus`](sf-WindowBase.md#requestfocus) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`hasFocus`](sf-WindowBase.md#hasfocus) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`getNativeHandle`](sf-WindowBase.md#getnativehandle) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`createVulkanSurface`](sf-WindowBase.md#createvulkansurface) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`onCreate`](sf-WindowBase.md#oncreate) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`onResize`](sf-WindowBase.md#onresize) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`m_impl`](sf-WindowBase.md#m_impl-5) | `variable` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`m_size`](sf-WindowBase.md#m_size-1) | `variable` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`filterEvent`](sf-WindowBase.md#filterevent) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`initialize`](sf-WindowBase.md#initialize-3) | `function` | Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2) |
| [`GlResource`](sf-GlResource.md#glresource-1) | `function` | Inherited from [`GlResource`](sf-GlResource.md#glresource) |
| [`m_sharedContext`](sf-GlResource.md#m_sharedcontext) | `variable` | Inherited from [`GlResource`](sf-GlResource.md#glresource) |
| [`~RenderTarget`](sf-RenderTarget.md#rendertarget-2) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`RenderTarget`](sf-RenderTarget.md#rendertarget-3) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`operator=`](sf-RenderTarget.md#operator-70) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`RenderTarget`](sf-RenderTarget.md#rendertarget-4) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`operator=`](sf-RenderTarget.md#operator-71) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`clear`](sf-RenderTarget.md#clear-3) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`clearStencil`](sf-RenderTarget.md#clearstencil) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`clear`](sf-RenderTarget.md#clear-4) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`setView`](sf-RenderTarget.md#setview) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`getView`](sf-RenderTarget.md#getview) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`getDefaultView`](sf-RenderTarget.md#getdefaultview) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`getViewport`](sf-RenderTarget.md#getviewport) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`getScissor`](sf-RenderTarget.md#getscissor) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`mapPixelToCoords`](sf-RenderTarget.md#mappixeltocoords) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`mapPixelToCoords`](sf-RenderTarget.md#mappixeltocoords-1) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`mapCoordsToPixel`](sf-RenderTarget.md#mapcoordstopixel) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`mapCoordsToPixel`](sf-RenderTarget.md#mapcoordstopixel-1) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`draw`](sf-RenderTarget.md#draw-1) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`draw`](sf-RenderTarget.md#draw-2) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`draw`](sf-RenderTarget.md#draw-3) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`draw`](sf-RenderTarget.md#draw-4) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`getSize`](sf-RenderTarget.md#getsize-7) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`isSrgb`](sf-RenderTarget.md#issrgb) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`setActive`](sf-RenderTarget.md#setactive-2) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`pushGLStates`](sf-RenderTarget.md#pushglstates) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`popGLStates`](sf-RenderTarget.md#popglstates) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`resetGLStates`](sf-RenderTarget.md#resetglstates) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`RenderTarget`](sf-RenderTarget.md#rendertarget-5) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`initialize`](sf-RenderTarget.md#initialize-4) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`m_defaultView`](sf-RenderTarget.md#m_defaultview) | `variable` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`m_view`](sf-RenderTarget.md#m_view) | `variable` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`m_cache`](sf-RenderTarget.md#m_cache) | `variable` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`m_id`](sf-RenderTarget.md#m_id) | `variable` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`applyCurrentView`](sf-RenderTarget.md#applycurrentview) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`applyBlendMode`](sf-RenderTarget.md#applyblendmode) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`applyStencilMode`](sf-RenderTarget.md#applystencilmode) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`applyTransform`](sf-RenderTarget.md#applytransform) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`applyTexture`](sf-RenderTarget.md#applytexture) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`applyShader`](sf-RenderTarget.md#applyshader) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`setupDraw`](sf-RenderTarget.md#setupdraw) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`drawPrimitives`](sf-RenderTarget.md#drawprimitives) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`cleanupDraw`](sf-RenderTarget.md#cleanupdraw) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |

## Inherited from [`Window`](sf-Window.md#window)

| Kind | Name | Description |
|------|------|-------------|
| `function` | [`Window`](sf-Window.md#window-1)  | Default constructor. |
| `function` | [`Window`](sf-Window.md#window-2)  | Construct a new window. |
| `function` | [`Window`](sf-Window.md#window-3)  | Construct a new window. |
| `function` | [`Window`](sf-Window.md#window-4) `explicit` | Construct the window from an existing control. |
| `function` | [`~Window`](sf-Window.md#window-5) `override` | Destructor. |
| `function` | [`Window`](sf-Window.md#window-6)  | Deleted copy constructor. |
| `function` | [`operator=`](sf-Window.md#operator-22)  | Deleted copy assignment. |
| `function` | [`Window`](sf-Window.md#window-7) `noexcept` | Move constructor. |
| `function` | [`operator=`](sf-Window.md#operator-23) `noexcept` | Move assignment. |
| `function` | [`create`](sf-Window.md#create) `virtual` `override` | Create (or recreate) the window. |
| `function` | [`create`](sf-Window.md#create-1) `virtual` | Create (or recreate) the window. |
| `function` | [`create`](sf-Window.md#create-2) `virtual` `override` | Create (or recreate) the window. |
| `function` | [`create`](sf-Window.md#create-3) `virtual` | Create (or recreate) the window. |
| `function` | [`create`](sf-Window.md#create-4) `virtual` `override` | Create (or recreate) the window from an existing control. |
| `function` | [`create`](sf-Window.md#create-5) `virtual` | Create (or recreate) the window from an existing control. |
| `function` | [`close`](sf-Window.md#close-2) `virtual` `override` | Close the window and destroy all the attached resources. |
| `function` | [`getSettings`](sf-Window.md#getsettings-1) `const` `nodiscard` | Get the settings of the OpenGL context of the window. |
| `function` | [`setVerticalSyncEnabled`](sf-Window.md#setverticalsyncenabled)  | Enable or disable vertical synchronization. |
| `function` | [`setFramerateLimit`](sf-Window.md#setframeratelimit)  | Limit the framerate to a maximum fixed frequency. |
| `function` | [`setActive`](sf-Window.md#setactive-1) `const` `nodiscard` | Activate or deactivate the window as the current target for OpenGL rendering. |
| `function` | [`display`](sf-Window.md#display)  | Display on screen what has been rendered to the window so far. |
| `variable` | [`m_context`](sf-Window.md#m_context-1)  | Platform-specific implementation of the OpenGL context. |
| `variable` | [`m_clock`](sf-Window.md#m_clock)  | [Clock](sf-Clock.md#clock) for measuring the elapsed time between frames. |
| `variable` | [`m_frameTimeLimit`](sf-Window.md#m_frametimelimit)  | Current framerate limit. |
| `function` | [`initialize`](sf-Window.md#initialize-2)  | Perform some common internal initializations. |

## Inherited from [`WindowBase`](sf-WindowBase.md#windowbase-2)

| Kind | Name | Description |
|------|------|-------------|
| `friend` | [`Window`](sf-WindowBase.md#window-8)  |  |
| `function` | [`WindowBase`](sf-WindowBase.md#windowbase-3)  | Default constructor. |
| `function` | [`WindowBase`](sf-WindowBase.md#windowbase-4)  | Construct a new window. |
| `function` | [`WindowBase`](sf-WindowBase.md#windowbase-5)  | Construct a new window. |
| `function` | [`WindowBase`](sf-WindowBase.md#windowbase-6) `explicit` | Construct the window from an existing control. |
| `function` | [`~WindowBase`](sf-WindowBase.md#windowbase-7) `virtual` | Destructor. |
| `function` | [`WindowBase`](sf-WindowBase.md#windowbase-8)  | Deleted copy constructor. |
| `function` | [`operator=`](sf-WindowBase.md#operator-24)  | Deleted copy assignment. |
| `function` | [`WindowBase`](sf-WindowBase.md#windowbase-9) `noexcept` | Move constructor. |
| `function` | [`operator=`](sf-WindowBase.md#operator-25) `noexcept` | Move assignment. |
| `function` | [`create`](sf-WindowBase.md#create-6) `virtual` | Create (or recreate) the window. |
| `function` | [`create`](sf-WindowBase.md#create-7) `virtual` | Create (or recreate) the window. |
| `function` | [`create`](sf-WindowBase.md#create-8) `virtual` | Create (or recreate) the window from an existing control. |
| `function` | [`close`](sf-WindowBase.md#close-3) `virtual` | Close the window and destroy all the attached resources. |
| `function` | [`isOpen`](sf-WindowBase.md#isopen) `const` `nodiscard` | Tell whether or not the window is open. |
| `function` | [`pollEvent`](sf-WindowBase.md#pollevent) `nodiscard` | Pop the next event from the front of the FIFO event queue, if any, and return it. |
| `function` | [`waitEvent`](sf-WindowBase.md#waitevent) `nodiscard` | Wait for an event and return it. |
| `function` | [`handleEvents`](sf-WindowBase.md#handleevents)  | Handle all pending events. |
| `function` | [`getPosition`](sf-WindowBase.md#getposition-2) `const` `nodiscard` | Get the position of the window. |
| `function` | [`setPosition`](sf-WindowBase.md#setposition-2)  | Change the position of the window on screen. |
| `function` | [`getSize`](sf-WindowBase.md#getsize-4) `const` `nodiscard` | Get the size of the rendering region of the window. |
| `function` | [`setSize`](sf-WindowBase.md#setsize)  | Change the size of the rendering region of the window. |
| `function` | [`setMinimumSize`](sf-WindowBase.md#setminimumsize)  | Set the minimum window rendering region size. |
| `function` | [`setMaximumSize`](sf-WindowBase.md#setmaximumsize)  | Set the maximum window rendering region size. |
| `function` | [`setTitle`](sf-WindowBase.md#settitle)  | Change the title of the window. |
| `function` | [`setIcon`](sf-WindowBase.md#seticon)  | Change the window's icon. |
| `function` | [`setVisible`](sf-WindowBase.md#setvisible)  | Show or hide the window. |
| `function` | [`setMouseCursorVisible`](sf-WindowBase.md#setmousecursorvisible)  | Show or hide the mouse cursor. |
| `function` | [`setMouseCursorGrabbed`](sf-WindowBase.md#setmousecursorgrabbed)  | Grab or release the mouse cursor. |
| `function` | [`setMouseCursor`](sf-WindowBase.md#setmousecursor)  | Set the displayed cursor to a native system cursor. |
| `function` | [`setKeyRepeatEnabled`](sf-WindowBase.md#setkeyrepeatenabled)  | Enable or disable automatic key-repeat. |
| `function` | [`setJoystickThreshold`](sf-WindowBase.md#setjoystickthreshold)  | Change the joystick threshold. |
| `function` | [`requestFocus`](sf-WindowBase.md#requestfocus)  | Request the current window to be made the active foreground window. |
| `function` | [`hasFocus`](sf-WindowBase.md#hasfocus) `const` `nodiscard` | Check whether the window has the input focus. |
| `function` | [`getNativeHandle`](sf-WindowBase.md#getnativehandle) `const` `nodiscard` | Get the OS-specific handle of the window. |
| `function` | [`createVulkanSurface`](sf-WindowBase.md#createvulkansurface) `nodiscard` | Create a [Vulkan](sf-Vulkan.md#vulkan) rendering surface. |
| `function` | [`onCreate`](sf-WindowBase.md#oncreate) `virtual` | Function called after the window has been created. |
| `function` | [`onResize`](sf-WindowBase.md#onresize) `virtual` | Function called after the window has been resized. |
| `variable` | [`m_impl`](sf-WindowBase.md#m_impl-5)  | Platform-specific implementation of the window. |
| `variable` | [`m_size`](sf-WindowBase.md#m_size-1)  | Current size of the window. |
| `function` | [`filterEvent`](sf-WindowBase.md#filterevent)  | Processes an event before it is sent to the user. |
| `function` | [`initialize`](sf-WindowBase.md#initialize-3)  | Perform some common internal initializations. |

## Inherited from [`GlResource`](sf-GlResource.md#glresource)

| Kind | Name | Description |
|------|------|-------------|
| `function` | [`GlResource`](sf-GlResource.md#glresource-1)  | Default constructor. |
| `variable` | [`m_sharedContext`](sf-GlResource.md#m_sharedcontext)  | Shared context used to link all contexts together for resource sharing. |

## Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1)

| Kind | Name | Description |
|------|------|-------------|
| `function` | [`~RenderTarget`](sf-RenderTarget.md#rendertarget-2) `virtual` | Destructor. |
| `function` | [`RenderTarget`](sf-RenderTarget.md#rendertarget-3)  | Deleted copy constructor. |
| `function` | [`operator=`](sf-RenderTarget.md#operator-70)  | Deleted copy assignment. |
| `function` | [`RenderTarget`](sf-RenderTarget.md#rendertarget-4) `noexcept` | Move constructor. |
| `function` | [`operator=`](sf-RenderTarget.md#operator-71) `noexcept` | Move assignment. |
| `function` | [`clear`](sf-RenderTarget.md#clear-3)  | Clear the entire target with a single color. |
| `function` | [`clearStencil`](sf-RenderTarget.md#clearstencil)  | Clear the stencil buffer to a specific value. |
| `function` | [`clear`](sf-RenderTarget.md#clear-4)  | Clear the entire target with a single color and stencil value. |
| `function` | [`setView`](sf-RenderTarget.md#setview)  | Change the current active view. |
| `function` | [`getView`](sf-RenderTarget.md#getview) `const` `nodiscard` | Get the view currently in use in the render target. |
| `function` | [`getDefaultView`](sf-RenderTarget.md#getdefaultview) `const` `nodiscard` | Get the default view of the render target. |
| `function` | [`getViewport`](sf-RenderTarget.md#getviewport) `const` `nodiscard` | Get the viewport of a view, applied to this render target. |
| `function` | [`getScissor`](sf-RenderTarget.md#getscissor) `const` `nodiscard` | Get the scissor rectangle of a view, applied to this render target. |
| `function` | [`mapPixelToCoords`](sf-RenderTarget.md#mappixeltocoords) `const` `nodiscard` | Convert a point from target coordinates to world coordinates, using the current view. |
| `function` | [`mapPixelToCoords`](sf-RenderTarget.md#mappixeltocoords-1) `const` `nodiscard` | Convert a point from target coordinates to world coordinates. |
| `function` | [`mapCoordsToPixel`](sf-RenderTarget.md#mapcoordstopixel) `const` `nodiscard` | Convert a point from world coordinates to target coordinates, using the current view. |
| `function` | [`mapCoordsToPixel`](sf-RenderTarget.md#mapcoordstopixel-1) `const` `nodiscard` | Convert a point from world coordinates to target coordinates. |
| `function` | [`draw`](sf-RenderTarget.md#draw-1)  | Draw a drawable object to the render target. |
| `function` | [`draw`](sf-RenderTarget.md#draw-2)  | Draw primitives defined by an array of vertices. |
| `function` | [`draw`](sf-RenderTarget.md#draw-3)  | Draw primitives defined by a vertex buffer. |
| `function` | [`draw`](sf-RenderTarget.md#draw-4)  | Draw primitives defined by a vertex buffer. |
| `function` | [`getSize`](sf-RenderTarget.md#getsize-7) `virtual` `const` `nodiscard` | Return the size of the rendering region of the target. |
| `function` | [`isSrgb`](sf-RenderTarget.md#issrgb) `virtual` `const` `nodiscard` | Tell if the render target will use sRGB encoding when drawing on it. |
| `function` | [`setActive`](sf-RenderTarget.md#setactive-2) `virtual` `nodiscard` | Activate or deactivate the render target for rendering. |
| `function` | [`pushGLStates`](sf-RenderTarget.md#pushglstates)  | Save the current OpenGL render states and matrices. |
| `function` | [`popGLStates`](sf-RenderTarget.md#popglstates)  | Restore the previously saved OpenGL render states and matrices. |
| `function` | [`resetGLStates`](sf-RenderTarget.md#resetglstates)  | Reset the internal OpenGL states so that the target is ready for drawing. |
| `function` | [`RenderTarget`](sf-RenderTarget.md#rendertarget-5)  | Default constructor. |
| `function` | [`initialize`](sf-RenderTarget.md#initialize-4)  | Performs the common initialization step after creation. |
| `variable` | [`m_defaultView`](sf-RenderTarget.md#m_defaultview)  | Default view. |
| `variable` | [`m_view`](sf-RenderTarget.md#m_view)  | Current view. |
| `variable` | [`m_cache`](sf-RenderTarget.md#m_cache)  | Render states cache. |
| `variable` | [`m_id`](sf-RenderTarget.md#m_id)  | Unique number that identifies the [RenderTarget](sf-RenderTarget.md#rendertarget-1). |
| `function` | [`applyCurrentView`](sf-RenderTarget.md#applycurrentview)  | Apply the current view. |
| `function` | [`applyBlendMode`](sf-RenderTarget.md#applyblendmode)  | Apply a new blending mode. |
| `function` | [`applyStencilMode`](sf-RenderTarget.md#applystencilmode)  | Apply a new stencil mode. |
| `function` | [`applyTransform`](sf-RenderTarget.md#applytransform)  | Apply a new transform. |
| `function` | [`applyTexture`](sf-RenderTarget.md#applytexture)  | Apply a new texture. |
| `function` | [`applyShader`](sf-RenderTarget.md#applyshader)  | Apply a new shader. |
| `function` | [`setupDraw`](sf-RenderTarget.md#setupdraw)  | Setup environment for drawing. |
| `function` | [`drawPrimitives`](sf-RenderTarget.md#drawprimitives)  | Draw the primitives. |
| `function` | [`cleanupDraw`](sf-RenderTarget.md#cleanupdraw)  | Clean up environment after drawing. |

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`RenderWindow`](#renderwindow-1)  | Default constructor. |
|  | [`RenderWindow`](#renderwindow-2)  | Construct a new window. |
|  | [`RenderWindow`](#renderwindow-3)  | Construct a new window. |
|  | [`RenderWindow`](#renderwindow-4) `explicit` | Construct the window from an existing control. |
| [`Vector2u`](sf.md#vector2u) | [`getSize`](#getsize-9) `virtual` `const` `nodiscard` `override` | Get the size of the rendering region of the window. |
| `void` | [`setIcon`](#seticon-1)  | Change the window's icon. |
| `bool` | [`isSrgb`](#issrgb-2) `virtual` `const` `nodiscard` `override` | Tell if the window will use sRGB encoding when drawing on it. |
| `bool` | [`setActive`](#setactive-4) `virtual` `nodiscard` `override` | Activate or deactivate the window as the current target for OpenGL rendering. |

---

{#renderwindow-1}

### RenderWindow

```cpp
RenderWindow() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderWindow.hpp:64

Default constructor.

This constructor doesn't actually create the window, use the other constructors or call `[create()](sf-Window.md#create)` to do so.

---

{#renderwindow-2}

### RenderWindow

```cpp
RenderWindow(VideoMode mode, const String & title, std::uint32_t style = Style::Default, State state = State::Windowed, const ContextSettings & settings = {})
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderWindow.hpp:86

Construct a new window.

This constructor creates the window with the size and pixel depth defined in `mode`. An optional style can be passed to customize the look and behavior of the window (borders, title bar, resizable, closable, ...).

The last parameter is an optional structure specifying advanced OpenGL context settings such as anti-aliasing, depth-buffer bits, etc. You shouldn't care about these parameters for a regular usage of the graphics module.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mode` | [`VideoMode`](sf-VideoMode.md#videomode) | Video mode to use (defines the width, height and depth of the rendering area of the window) |
| `title` | const [`String`](sf-String.md#string) & | Title of the window |
| `style` | `std::uint32_t` | Window style, a bitwise OR combination of `[sf::Style](sf-Style.md#style-1)` enumerators |
| `state` | [`State`](State.md#state) | Window state |
| `settings` | const [`ContextSettings`](sf-ContextSettings.md#contextsettings) & | Additional settings for the underlying OpenGL context |

---

{#renderwindow-3}

### RenderWindow

```cpp
RenderWindow(VideoMode mode, const String & title, State state, const ContextSettings & settings = {})
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderWindow.hpp:109

Construct a new window.

This constructor creates the window with the size and pixel depth defined in `mode`. If `state` is `[State::Fullscreen](window.md#group__window_1gga504e2cd8fc6a852463f8d049db1151e5a0829ea6734059d66e6bf87096b215dc1)`, then `mode` must be a valid video mode.

The last parameter is an optional structure specifying advanced OpenGL context settings such as anti-aliasing, depth-buffer bits, etc.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mode` | [`VideoMode`](sf-VideoMode.md#videomode) | Video mode to use (defines the width, height and depth of the rendering area of the window) |
| `title` | const [`String`](sf-String.md#string) & | Title of the window |
| `state` | [`State`](State.md#state) | Window state |
| `settings` | const [`ContextSettings`](sf-ContextSettings.md#contextsettings) & | Additional settings for the underlying OpenGL context |

---

{#renderwindow-4}

### RenderWindow

`explicit`

```cpp
explicit RenderWindow(WindowHandle handle, const ContextSettings & settings = {})
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderWindow.hpp:127

Construct the window from an existing control.

Use this constructor if you want to create an SFML rendering area into an already existing control.

The second parameter is an optional structure specifying advanced OpenGL context settings such as anti-aliasing, depth-buffer bits, etc. You shouldn't care about these parameters for a regular usage of the graphics module.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `handle` | `WindowHandle` | Platform-specific handle of the control (*HWND* on Windows, *Window* on Linux/FreeBSD, *NSWindow* on macOS) |
| `settings` | const [`ContextSettings`](sf-ContextSettings.md#contextsettings) & | Additional settings for the underlying OpenGL context |

---

{#getsize-9}

### getSize

`virtual` `const` `nodiscard` `override`

```cpp
[[nodiscard]] virtual Vector2u getSize() const override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderWindow.hpp:138

Get the size of the rendering region of the window.

The size doesn't include the titlebar and borders of the window.

#### Returns
Size in pixels

#### Reimplements

- [`getSize`](sf-RenderTarget.md#getsize-7)

---

{#seticon-1}

### setIcon

```cpp
void setIcon(const Image & icon)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderWindow.hpp:150

Change the window's icon.

The OS default icon is used by default.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `icon` | const [`Image`](sf-Image.md#image) & | [Image](sf-Image.md#image) to use as the icon. The image is copied, so you need not keep the source alive after calling this function. |

---

{#issrgb-2}

### isSrgb

`virtual` `const` `nodiscard` `override`

```cpp
[[nodiscard]] virtual bool isSrgb() const override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderWindow.hpp:161

Tell if the window will use sRGB encoding when drawing on it.

You can request sRGB encoding for a window by having the sRgbCapable flag set in the `[ContextSettings](sf-ContextSettings.md#contextsettings)`

#### Returns
`true` if the window use sRGB encoding, `false` otherwise

#### Reimplements

- [`isSrgb`](sf-RenderTarget.md#issrgb)

---

{#setactive-4}

### setActive

`virtual` `nodiscard` `override`

```cpp
[[nodiscard]] virtual bool setActive(bool active = true) override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderWindow.hpp:179

Activate or deactivate the window as the current target for OpenGL rendering.

A window is active only on the current thread, if you want to make it active on another thread you have to deactivate it on the previous thread first if it was active. Only one window can be active on a thread at a time, thus the window previously active (if any) automatically gets deactivated. This is not to be confused with `[requestFocus()](sf-WindowBase.md#requestfocus)`.

#### Returns
`true` if operation was successful, `false` otherwise

#### Reimplements

- [`setActive`](sf-RenderTarget.md#setactive-2)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `active` | `bool` | `true` to activate, `false` to deactivate |

## Protected Methods

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`onCreate`](#oncreate-1) `virtual` `override` | Function called after the window has been created. |
| `void` | [`onResize`](#onresize-1) `virtual` `override` | Function called after the window has been resized. |

---

{#oncreate-1}

### onCreate

`virtual` `override`

```cpp
virtual void onCreate() override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderWindow.hpp:190

Function called after the window has been created.

This function is called so that derived classes can perform their own specific initialization as soon as the window is created.

#### Reimplements

- [`onCreate`](sf-WindowBase.md#oncreate)

---

{#onresize-1}

### onResize

`virtual` `override`

```cpp
virtual void onResize() override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderWindow.hpp:199

Function called after the window has been resized.

This function is called so that derived classes can perform custom actions when the size of the window changes.

#### Reimplements

- [`onResize`](sf-WindowBase.md#onresize)

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `unsigned int` | [`m_defaultFrameBuffer`](#m_defaultframebuffer)  | Framebuffer to bind when targeting this window. |

---

{#m_defaultframebuffer}

### m_defaultFrameBuffer

```cpp
unsigned int m_defaultFrameBuffer {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderWindow.hpp:205

Framebuffer to bind when targeting this window.

