---@meta PudimBasicsGl
--- PudimBasicsGl - Pudim OpenGL Basics
--- A simple 2D graphics library for Lua using OpenGL
---
--- @module 'PudimBasicsGl'

---@class PudimBasicsGl
---@field window PudimBasicsGl.window Window management module
---@field renderer PudimBasicsGl.renderer 2D rendering module
---@field time PudimBasicsGl.time Time/delta time module
---@field texture PudimBasicsGl.texture Texture loading and rendering module
---@field input PudimBasicsGl.input Keyboard and mouse input module
---@field audio PudimBasicsGl.audio Audio loading and playback module
---@field text PudimBasicsGl.text Text rendering and font module
---@field camera PudimBasicsGl.camera 2D camera module
---@field shader PudimBasicsGl.shader Custom shader module
---@field math PudimBasicsGl.math Vector math and utility functions
---@field studio PudimBasicsGl.studio Tools for building editors, studios, and exporters
---@field ui PudimBasicsGl.ui Immediate-mode GUI module (panels, buttons, sliders)
local PudimBasicsGl = {}

--------------------------------------------------------------------------------
-- Window Module
--------------------------------------------------------------------------------


---@class Window
---Opaque window handle (userdata)
---
---Methods (available as `window:method()`):
---@field should_close fun(self: Window): boolean Check if window should close
---@field destroy fun(self: Window) Destroy window and free resources
---@field close fun(self: Window) Signal that the window should close
---@field swap_buffers fun(self: Window) Swap buffers (present frame)
---@field get_size fun(self: Window): integer, integer Get window width and height
---@field set_size fun(self: Window, width: integer, height: integer) Set window size
---@field set_title fun(self: Window, title: string) Set window title
---@field get_handle fun(self: Window): userdata Get native GLFW handle
---@field set_vsync fun(self: Window, enabled: boolean) Enable/disable VSync
---@field get_vsync fun(self: Window): boolean Check if VSync is enabled
---@field set_fullscreen fun(self: Window, fullscreen: boolean) Set fullscreen mode
---@field is_fullscreen fun(self: Window): boolean Check if fullscreen
---@field toggle_fullscreen fun(self: Window) Toggle fullscreen mode
---@field get_position fun(self: Window): integer, integer Get window position
---@field set_position fun(self: Window, x: integer, y: integer) Set window position
---@field focus fun(self: Window) Focus the window
---@field is_focused fun(self: Window): boolean Check if window has focus
---@field set_resizable fun(self: Window, resizable: boolean) Enable/disable resizing
---
---Note: All `PudimBasicsGl.window.*` functions that take a `Window` as the first
---parameter also support method-style calls on the userdata (e.g. `window:should_close()`),
---in addition to `PudimBasicsGl.window.should_close(window)`.
---


---@class PudimBasicsGl.window
PudimBasicsGl.window = {}

---Create a new **GLFW window** with an OpenGL context.
---
---Must be called **before** `pb.renderer.init()`.
---Only one window should be active at a time.
---
---### Example
---```lua
---local window = pb.window.create(800, 600, "My Game")
---```
---@param width integer Window width in pixels
---@param height integer Window height in pixels
---@param title string Window title
---@return Window window The created window
function PudimBasicsGl.window.create(width, height, title) end

---Destroy a window and **free all associated resources**.
---
---Call this at the end of your program to clean up.
---
---### Example
---```lua
---pb.window.destroy(window)
---```
---@param window Window The window to destroy
function PudimBasicsGl.window.destroy(window) end

---Check if the window should close (e.g. user clicked the **X** button).
---
---Typically used as the main loop condition.
---
---### Example
---```lua
---while not pb.window.should_close(window) do
---    -- game loop
---end
---```
---@param window Window The window to check
---@return boolean should_close `true` if the window should close
function PudimBasicsGl.window.should_close(window) end

---Signal that the window should close.
---
---After calling this, `should_close()` will return `true`.
---
---### Example
---```lua
---if pb.input.is_key_pressed(pb.input.KEY_ESCAPE) then
---    pb.window.close(window)
---end
---```
---@param window Window The window to close
function PudimBasicsGl.window.close(window) end

---Swap the **front and back buffers** (present the rendered frame).
---
---Call once per frame at the **end** of the render loop.
---@param window Window The window to swap buffers for
function PudimBasicsGl.window.swap_buffers(window) end

---Poll for pending window/input events.
---
---Call **once per frame**, typically at the end of the loop.
function PudimBasicsGl.window.poll_events() end

---Get the current window size in pixels.
---
---### Example
---```lua
---local w, h = pb.window.get_size(window)
---print("Window is " .. w .. "x" .. h)
---```
---@param window Window The window to query
---@return integer width Window width in pixels
---@return integer height Window height in pixels
function PudimBasicsGl.window.get_size(window) end

---Set the window size.
---@param window Window The window to modify
---@param width integer New width in pixels
---@param height integer New height in pixels
function PudimBasicsGl.window.set_size(window, width, height) end

---Set the window title text.
---@param window Window The window to modify
---@param title string The new window title
function PudimBasicsGl.window.set_title(window, title) end

---Get the native **GLFW** window handle (for advanced / interop use).
---@param window Window The window
---@return userdata handle The GLFW window pointer
function PudimBasicsGl.window.get_handle(window) end

---Enable or disable **VSync** (vertical synchronization).
---
---When enabled, the frame rate is capped to the monitor's refresh rate.
---@param window Window The window
---@param enabled boolean `true` to enable VSync, `false` to disable
function PudimBasicsGl.window.set_vsync(window, enabled) end

---Check if **VSync** is currently enabled.
---@param window Window The window
---@return boolean vsync `true` if VSync is enabled
function PudimBasicsGl.window.get_vsync(window) end

---Set fullscreen or windowed mode.
---@param window Window The window
---@param fullscreen boolean `true` for fullscreen, `false` for windowed
function PudimBasicsGl.window.set_fullscreen(window, fullscreen) end

---Check if the window is in fullscreen mode.
---@param window Window The window
---@return boolean fullscreen `true` if fullscreen
function PudimBasicsGl.window.is_fullscreen(window) end

---Toggle between fullscreen and windowed mode.
---@param window Window The window
function PudimBasicsGl.window.toggle_fullscreen(window) end

---Get the window position on screen.
---@param window Window The window
---@return integer x X position on screen
---@return integer y Y position on screen
function PudimBasicsGl.window.get_position(window) end

---Set the window position on screen.
---@param window Window The window
---@param x integer X position on screen
---@param y integer Y position on screen
function PudimBasicsGl.window.set_position(window, x, y) end

---Bring the window to front and give it input **focus**.
---@param window Window The window to focus
function PudimBasicsGl.window.focus(window) end

---Check if the window currently has input focus.
---@param window Window The window
---@return boolean focused `true` if window has focus
function PudimBasicsGl.window.is_focused(window) end

---Enable or disable **window resizing** by the user.
---@param window Window The window
---@param resizable boolean `true` to allow resizing
function PudimBasicsGl.window.set_resizable(window, resizable) end

--------------------------------------------------------------------------------
-- Renderer Module
--------------------------------------------------------------------------------

---@class PudimBasicsGl.renderer
PudimBasicsGl.renderer = {}

---@class Color
---@field r number Red component (0.0 - 1.0)
---@field g number Green component (0.0 - 1.0)
---@field b number Blue component (0.0 - 1.0)
---@field a number? Alpha component (0.0 - 1.0), defaults to 1.0

---@class PudimBasicsGl.renderer.colors
---@field WHITE Color
---@field BLACK Color
---@field RED Color
---@field GREEN Color
---@field BLUE Color
---@field YELLOW Color
---@field CYAN Color
---@field MAGENTA Color
---@field ORANGE Color
---@field PURPLE Color
---@field GRAY Color
---@field DARK_GRAY Color
---@field LIGHT_GRAY Color
PudimBasicsGl.renderer.colors = {}

---Initialize the **OpenGL renderer**.
---
---Must be called **after** creating a window and **before** any draw calls.
---Sets up shaders, vertex buffers, blending, and other GPU state.
---
---### Example
---```lua
---local window = pb.window.create(800, 600, "Game")
---pb.renderer.init()
---```
function PudimBasicsGl.renderer.init() end

---Clear the screen with a solid color.
---
---Call at the **beginning** of each frame before drawing.
---
---### Example
---```lua
---pb.renderer.clear(0.1, 0.1, 0.15, 1.0)  -- dark blue-gray
---```
---@param r number Red component (`0.0` – `1.0`)
---@param g number Green component (`0.0` – `1.0`)
---@param b number Blue component (`0.0` – `1.0`)
---@param a number? Alpha component (`0.0` – `1.0`), defaults to `1.0`
function PudimBasicsGl.renderer.clear(r, g, b, a) end

---Begin a **2D rendering batch** with camera-aware projection.
---
---Sets up the projection matrix using the current camera state.
---All draw calls between `begin()` and `finish()` are batched
---for efficient rendering.
---
---### Example
---```lua
---local w, h = pb.window.get_size(window)
---pb.renderer.begin(w, h)
----- draw stuff...
---pb.renderer.finish()
---```
---@param width integer Screen/viewport width
---@param height integer Screen/viewport height
function PudimBasicsGl.renderer.begin(width, height) end

---End the 2D rendering batch and **flush** all pending geometry to the GPU.
---
---Pair with `pb.renderer.begin()`.
function PudimBasicsGl.renderer.finish() end

---Flush the current primitive batch **without** ending the render pass.
---
---Useful when you need to force draw order between different batch types
---(primitives → textures → text). With auto-flush batch switching this is
---rarely needed.
function PudimBasicsGl.renderer.flush() end

---Draw a single **pixel** (point).
---
---Size can be changed with `set_point_size()`.
---@param x integer X coordinate
---@param y integer Y coordinate
---@param r number|Color Red component or `Color` table
---@param g number? Green component (if `r` is number)
---@param b number? Blue component (if `r` is number)
---@param a number? Alpha component (if `r` is number)
function PudimBasicsGl.renderer.pixel(x, y, r, g, b, a) end

---Draw a **line** between two points.
---
---Width can be changed with `set_line_width()`.
---
---### Example
---```lua
---pb.renderer.line(0, 0, 100, 100, 1.0, 0.0, 0.0, 1.0)  -- red diagonal
---```
---@param x1 integer Start X coordinate
---@param y1 integer Start Y coordinate
---@param x2 integer End X coordinate
---@param y2 integer End Y coordinate
---@param r number|Color Red component or `Color` table
---@param g number? Green component (if `r` is number)
---@param b number? Blue component (if `r` is number)
---@param a number? Alpha component (if `r` is number)
function PudimBasicsGl.renderer.line(x1, y1, x2, y2, r, g, b, a) end

---Draw a **rectangle outline** (wireframe).
---
---### Example
---```lua
---pb.renderer.rect(10, 10, 200, 100, 0.0, 1.0, 0.0, 1.0)  -- green outline
---```
---@param x integer X coordinate (top-left)
---@param y integer Y coordinate (top-left)
---@param width integer Rectangle width
---@param height integer Rectangle height
---@param r number|Color Red component or `Color` table
---@param g number? Green component (if `r` is number)
---@param b number? Blue component (if `r` is number)
---@param a number? Alpha component (if `r` is number)
function PudimBasicsGl.renderer.rect(x, y, width, height, r, g, b, a) end

---Draw a **filled rectangle**.
---
---### Example
---```lua
---pb.renderer.rect_filled(50, 50, 120, 80, 0.2, 0.5, 0.9, 1.0)
---```
---@param x integer X coordinate (top-left)
---@param y integer Y coordinate (top-left)
---@param width integer Rectangle width
---@param height integer Rectangle height
---@param r number|Color Red component or `Color` table
---@param g number? Green component (if `r` is number)
---@param b number? Blue component (if `r` is number)
---@param a number? Alpha component (if `r` is number)
function PudimBasicsGl.renderer.rect_filled(x, y, width, height, r, g, b, a) end

---Draw a **circle outline**.
---@param cx integer Center X coordinate
---@param cy integer Center Y coordinate
---@param radius integer Circle radius in pixels
---@param r number|Color Red component or `Color` table
---@param g number? Green component (if `r` is number)
---@param b number? Blue component (if `r` is number)
---@param a number? Alpha component (if `r` is number)
function PudimBasicsGl.renderer.circle(cx, cy, radius, r, g, b, a) end

---Draw a **filled circle**.
---
---### Example
---```lua
---pb.renderer.circle_filled(200, 200, 50, 1.0, 0.5, 0.0, 1.0)  -- orange
---```
---@param cx integer Center X coordinate
---@param cy integer Center Y coordinate
---@param radius integer Circle radius in pixels
---@param r number|Color Red component or `Color` table
---@param g number? Green component (if `r` is number)
---@param b number? Blue component (if `r` is number)
---@param a number? Alpha component (if `r` is number)
function PudimBasicsGl.renderer.circle_filled(cx, cy, radius, r, g, b, a) end

---Draw a **triangle outline**.
---@param x1 integer First vertex X
---@param y1 integer First vertex Y
---@param x2 integer Second vertex X
---@param y2 integer Second vertex Y
---@param x3 integer Third vertex X
---@param y3 integer Third vertex Y
---@param r number|Color Red component or `Color` table
---@param g number? Green component (if `r` is number)
---@param b number? Blue component (if `r` is number)
---@param a number? Alpha component (if `r` is number)
function PudimBasicsGl.renderer.triangle(x1, y1, x2, y2, x3, y3, r, g, b, a) end

---Draw a **filled triangle**.
---
---### Example
---```lua
---pb.renderer.triangle_filled(100, 10, 50, 90, 150, 90, 0.0, 0.8, 0.3, 1.0)
---```
---@param x1 integer First vertex X
---@param y1 integer First vertex Y
---@param x2 integer Second vertex X
---@param y2 integer Second vertex Y
---@param x3 integer Third vertex X
---@param y3 integer Third vertex Y
---@param r number|Color Red component or `Color` table
---@param g number? Green component (if `r` is number)
---@param b number? Blue component (if `r` is number)
---@param a number? Alpha component (if `r` is number)
function PudimBasicsGl.renderer.triangle_filled(x1, y1, x2, y2, x3, y3, r, g, b, a) end

---Set the **point size** for `pixel()` drawing.
---@param size number Point size in pixels (default `1.0`)
function PudimBasicsGl.renderer.set_point_size(size) end

---Set the **line width** for `line()` and outline drawing.
---@param width number Line width in pixels (default `1.0`)
function PudimBasicsGl.renderer.set_line_width(width) end

---Create a `Color` table from float components.
---
---### Example
---```lua
---local red = pb.renderer.color(1.0, 0.0, 0.0)
---local hex = pb.renderer.color(0xFF6600)  -- from hex
---```
---@param r number|integer Red (`0.0`–`1.0`) or hex integer (`0xRRGGBB`)
---@param g number? Green (`0.0`–`1.0`)
---@param b number? Blue (`0.0`–`1.0`)
---@param a number? Alpha (`0.0`–`1.0`), defaults to `1.0`
---@return Color color The color table
function PudimBasicsGl.renderer.color(r, g, b, a) end

---Create a `Color` table from **integer** values `0`–`255`.
---
---### Example
---```lua
---local coral = pb.renderer.color255(255, 127, 80)
---```
---@param r integer Red component (`0`–`255`)
---@param g integer Green component (`0`–`255`)
---@param b integer Blue component (`0`–`255`)
---@param a integer? Alpha component (`0`–`255`), defaults to `255`
---@return Color color The color table (internally converted to `0.0`–`1.0`)
function PudimBasicsGl.renderer.color255(r, g, b, a) end

---Unpack a `Color` table into four float values.
---
---### Example
---```lua
---local r, g, b, a = pb.renderer.color_unpack(pb.renderer.colors.RED)
---```
---@param color Color The color table to unpack
---@return number r Red (`0.0`–`1.0`)
---@return number g Green (`0.0`–`1.0`)
---@return number b Blue (`0.0`–`1.0`)
---@return number a Alpha (`0.0`–`1.0`)
function PudimBasicsGl.renderer.color_unpack(color) end

---Set the default clear color used by `clear()`.
---@param r number Red (`0.0`–`1.0`)
---@param g number Green (`0.0`–`1.0`)
---@param b number Blue (`0.0`–`1.0`)
---@param a number? Alpha (`0.0`–`1.0`), defaults to `1.0`
function PudimBasicsGl.renderer.set_clear_color(r, g, b, a) end

---Enable or disable **depth testing**.
---
---> **Note:** Depth testing is disabled by default in this 2D engine.
---@param enable boolean `true` to enable, `false` to disable
function PudimBasicsGl.renderer.enable_depth_test(enable) end

---Enable or disable **alpha blending**.
---
---Blending is enabled by default with `SRC_ALPHA, ONE_MINUS_SRC_ALPHA`.
---@param enable boolean `true` to enable, `false` to disable
function PudimBasicsGl.renderer.enable_blend(enable) end

---Set the OpenGL **viewport** rectangle.
---@param x integer Viewport X offset
---@param y integer Viewport Y offset
---@param width integer Viewport width
---@param height integer Viewport height
function PudimBasicsGl.renderer.set_viewport(x, y, width, height) end

---Get **OpenGL** driver information.
---
---### Example
---```lua
---local info = pb.renderer.get_info()
---print(info.version)   -- e.g. "4.6 (Core Profile) Mesa 26.0.1"
---print(info.renderer)  -- e.g. "AMD Radeon RX 6600"
---```
---@return table info Table with fields: `version`, `renderer`, `vendor`, `glsl_version`
function PudimBasicsGl.renderer.get_info() end

---Start **UI rendering mode** (screen-space, ignores camera).
---
---Everything drawn between `begin_ui()` and `end_ui()` stays fixed on screen,
---unaffected by camera position, zoom or rotation.
---Useful for **HUD**, health bars, score display, menus, etc.
---
---### Example
---```lua
---pb.renderer.begin_ui(W, H)
----- draw HUD elements here (fixed on screen)
---pb.renderer.end_ui()
---```
---@param width integer Screen width in pixels
---@param height integer Screen height in pixels
function PudimBasicsGl.renderer.begin_ui(width, height) end

---End **UI rendering mode** and restore camera-based projection.
function PudimBasicsGl.renderer.end_ui() end

---Draw a filled rectangle with a **vertical gradient** (top → bottom).
---
---### Example
---```lua
---pb.renderer.rect_gradient(0, 0, 800, 600,
---    0.1, 0.1, 0.3, 1.0,   -- top: dark blue
---    0.0, 0.0, 0.0, 1.0)   -- bottom: black
---```
---@param x integer X position
---@param y integer Y position
---@param width integer Rectangle width
---@param height integer Rectangle height
---@param top_r number|table Top color red (`0.0`–`1.0`) or color table `{r,g,b,a}`
---@param top_g? number Top color green
---@param top_b? number Top color blue
---@param top_a? number Top color alpha
---@param bot_r? number|table Bottom color red (`0.0`–`1.0`) or color table `{r,g,b,a}`
---@param bot_g? number Bottom color green
---@param bot_b? number Bottom color blue
---@param bot_a? number Bottom color alpha
---@overload fun(x: integer, y: integer, width: integer, height: integer, top_color: table, bottom_color: table)
function PudimBasicsGl.renderer.rect_gradient(x, y, width, height, top_r, top_g, top_b, top_a, bot_r, bot_g, bot_b, bot_a) end

---Read a pixel's color from the **framebuffer** (GPU readback).
---
---Useful for automated testing or color picking. Coordinates use
---**top-left** origin (the Y-flip is handled internally).
---
---### Example
---```lua
---local r, g, b, a = pb.renderer.read_pixel(100, 50, screen_height)
---```
---@param x integer X coordinate (screen-space)
---@param y integer Y coordinate (screen-space, top-left origin)
---@param screen_height integer Height of the screen (needed for OpenGL Y-flip)
---@return integer r Red (`0`–`255`)
---@return integer g Green (`0`–`255`)
---@return integer b Blue (`0`–`255`)
---@return integer a Alpha (`0`–`255`)
function PudimBasicsGl.renderer.read_pixel(x, y, screen_height) end

--------------------------------------------------------------------------------
-- Texture Module
--------------------------------------------------------------------------------

---@class PudimBasicsGl.texture
PudimBasicsGl.texture = {}

---@class Texture
---Opaque texture handle (userdata)
---@field draw fun(self: Texture, x: integer, y: integer, width?: integer, height?: integer) Draw texture at position
---@field draw_tinted fun(self: Texture, x: integer, y: integer, width: integer, height: integer, r: number, g: number, b: number, a?: number) Draw texture with color tint
---@field draw_rotated fun(self: Texture, x: integer, y: integer, width: integer, height: integer, angle: number) Draw rotated texture (angle in degrees)
---@field draw_ex fun(self: Texture, x: integer, y: integer, width: integer, height: integer, angle: number, origin_x?: number, origin_y?: number, r?: number, g?: number, b?: number, a?: number) Draw with full options
---@field draw_region fun(self: Texture, x: integer, y: integer, width: integer, height: integer, src_x: integer, src_y: integer, src_width: integer, src_height: integer) Draw a portion of texture (sprite sheet)
---@field draw_region_ex fun(self: Texture, x: integer, y: integer, width: integer, height: integer, src_x: integer, src_y: integer, src_width: integer, src_height: integer, angle?: number, origin_x?: number, origin_y?: number, r?: number, g?: number, b?: number, a?: number) Draw region with full options
---@field get_size fun(self: Texture): integer, integer Get texture dimensions
---@field get_width fun(self: Texture): integer Get texture width
---@field get_height fun(self: Texture): integer Get texture height
---@field destroy fun(self: Texture) Destroy texture and free resources

---Load a texture from an image file.
---
---Supports **PNG**, **JPG**, **BMP**, **TGA** and other formats via `stb_image`.
---
---Returns `nil, error_string` on failure (does **not** throw).
---
---### Example
---```lua
---local tex, err = pb.texture.load("assets/player.png")
---if not tex then print("Error: " .. err) end
---```
---@overload fun(self: PudimBasicsGl.texture, filepath: string): Texture?
---@param filepath string Path to the image file
---@return Texture? texture The loaded texture, or `nil` on failure
---@return string? error Error message if loading failed
function PudimBasicsGl.texture.load(filepath) end

---Load a texture with **chroma key** transparency.
---
---Pixels matching the `(r, g, b)` color are made fully transparent.
---Useful for sprite sheets that use a solid background color instead of alpha.
---
---### Example
---```lua
----- Make magenta (255, 0, 255) pixels transparent
---local tex = pb.texture.load_with_colorkey("sprite.bmp", 255, 0, 255)
---```
---@overload fun(self: PudimBasicsGl.texture, filepath: string, r: integer, g: integer, b: integer): Texture?
---@param filepath string Path to the image file
---@param r integer Red component of the chroma key (`0`–`255`)
---@param g integer Green component of the chroma key (`0`–`255`)
---@param b integer Blue component of the chroma key (`0`–`255`)
---@return Texture? texture The loaded texture, or `nil` on failure
---@return string? error Error message if loading failed
function PudimBasicsGl.texture.load_with_colorkey(filepath, r, g, b) end

---Create an **empty texture** with optional RGBA pixel data.
---
---### Example
---```lua
----- Create a 2x2 red/blue checkerboard
---local data = {
---    255,0,0,255,   0,0,255,255,
---    0,0,255,255,   255,0,0,255,
---}
---local tex = pb.texture.create(2, 2, data)
---```
---@overload fun(self: PudimBasicsGl.texture, width: integer, height: integer, data?: table): Texture?
---@param width integer Texture width in pixels
---@param height integer Texture height in pixels
---@param data? table Optional array of RGBA bytes (`width * height * 4` values, each `0`–`255`)
---@return Texture? texture The created texture, or `nil` on failure
---@return string? error Error message if creation failed
function PudimBasicsGl.texture.create(width, height, data) end

---Flush pending texture draws to the GPU.
---
---Normally handled automatically by batch switching.
function PudimBasicsGl.texture.flush() end

--------------------------------------------------------------------------------
-- Time Module
--------------------------------------------------------------------------------

---@class PudimBasicsGl.time
PudimBasicsGl.time = {}

---Note: All `PudimBasicsGl.time.*` functions accept method-style calls (e.g. `pb.time:get()`),
---in addition to the module-style `pb.time.get()`.

---Get **total elapsed time** since the library was initialized.
---@return number time Time in seconds
function PudimBasicsGl.time.get() end

---Get the **delta time** (time elapsed since the last frame).
---
---### Example
---```lua
---local dt = pb.time.delta()
---player.x = player.x + speed * dt  -- frame-rate independent movement
---```
---@return number dt Delta time in seconds
function PudimBasicsGl.time.delta() end

---Update the time system. Call **once per frame** at the start of the loop.
---
---Must be called **before** `delta()` or `fps()` to get accurate values.
---
---### Example
---```lua
---while not pb.window.should_close(window) do
---    pb.time.update()
---    local dt = pb.time.delta()
---    -- ...
---end
---```
function PudimBasicsGl.time.update() end

---Get the current **frames per second**.
---
---Updates each frame based on `delta()`.
---@return number fps Current FPS
function PudimBasicsGl.time.fps() end

---**Busy-wait** sleep for a specified duration.
---
---> **Warning:** This blocks the thread with a spin-loop. For frame pacing
---> prefer **VSync** instead.
---@param seconds number Duration to sleep in seconds
function PudimBasicsGl.time.sleep(seconds) end

--------------------------------------------------------------------------------
-- Input Module
--------------------------------------------------------------------------------

---@class PudimBasicsGl.input
---
--- Key constants (GLFW key codes)
---@field KEY_SPACE integer Space key
---@field KEY_ESCAPE integer Escape key
---@field KEY_ENTER integer Enter/Return key
---@field KEY_TAB integer Tab key
---@field KEY_BACKSPACE integer Backspace key
---
--- Arrow keys
---@field KEY_UP integer Up arrow
---@field KEY_DOWN integer Down arrow
---@field KEY_LEFT integer Left arrow
---@field KEY_RIGHT integer Right arrow
---
--- Letter keys (A-Z)
---@field KEY_A integer
---@field KEY_B integer
---@field KEY_C integer
---@field KEY_D integer
---@field KEY_E integer
---@field KEY_F integer
---@field KEY_G integer
---@field KEY_H integer
---@field KEY_I integer
---@field KEY_J integer
---@field KEY_K integer
---@field KEY_L integer
---@field KEY_M integer
---@field KEY_N integer
---@field KEY_O integer
---@field KEY_P integer
---@field KEY_Q integer
---@field KEY_R integer
---@field KEY_S integer
---@field KEY_T integer
---@field KEY_U integer
---@field KEY_V integer
---@field KEY_W integer
---@field KEY_X integer
---@field KEY_Y integer
---@field KEY_Z integer
---
--- Number keys (0-9)
---@field KEY_0 integer
---@field KEY_1 integer
---@field KEY_2 integer
---@field KEY_3 integer
---@field KEY_4 integer
---@field KEY_5 integer
---@field KEY_6 integer
---@field KEY_7 integer
---@field KEY_8 integer
---@field KEY_9 integer
---
--- Function keys
---@field KEY_F1 integer
---@field KEY_F2 integer
---@field KEY_F3 integer
---@field KEY_F11 integer
---@field KEY_F12 integer
---
--- Modifier keys
---@field KEY_LEFT_SHIFT integer Left Shift
---@field KEY_RIGHT_SHIFT integer Right Shift
---@field KEY_LEFT_CTRL integer Left Control
---@field KEY_RIGHT_CTRL integer Right Control
---@field KEY_LEFT_ALT integer Left Alt
---@field KEY_RIGHT_ALT integer Right Alt
---
--- Mouse button constants
---@field MOUSE_LEFT integer Left mouse button
---@field MOUSE_RIGHT integer Right mouse button
---@field MOUSE_MIDDLE integer Middle mouse button
PudimBasicsGl.input = {}

---Check if a key is **currently held down**.
---
---### Example
---```lua
---if pb.input.is_key_pressed(pb.input.KEY_W) then
---    player.y = player.y - speed * dt
---end
---```
---@param key integer Key constant (e.g. `pb.input.KEY_SPACE`)
---@return boolean pressed `true` if the key is held down
function PudimBasicsGl.input.is_key_pressed(key) end

---Check if a key is **not** pressed (released).
---@param key integer Key constant (e.g. `pb.input.KEY_W`)
---@return boolean released `true` if the key is not held down
function PudimBasicsGl.input.is_key_released(key) end

---Check if a mouse button is **currently held down**.
---
---### Example
---```lua
---if pb.input.is_mouse_button_pressed(pb.input.MOUSE_LEFT) then
---    -- shoot!
---end
---```
---@param button integer Mouse button constant (e.g. `pb.input.MOUSE_LEFT`)
---@return boolean pressed `true` if the button is held down
function PudimBasicsGl.input.is_mouse_button_pressed(button) end

---Get the **mouse cursor position** relative to the window.
---
---### Example
---```lua
---local mx, my = pb.input.get_mouse_position()
---```
---@return number x Cursor X position in pixels
---@return number y Cursor Y position in pixels
function PudimBasicsGl.input.get_mouse_position() end

---Set the mouse cursor position within the window.
---@param x number X position in pixels
---@param y number Y position in pixels
function PudimBasicsGl.input.set_mouse_position(x, y) end

---Show or hide the mouse cursor.
---@param visible boolean `true` to show the cursor, `false` to hide it
function PudimBasicsGl.input.set_cursor_visible(visible) end

---Lock or unlock the mouse cursor (for **FPS-style** camera control).
---
---When locked, the cursor is hidden and mouse movement reports raw deltas.
---@param locked boolean `true` to lock (disable) the cursor, `false` to unlock
function PudimBasicsGl.input.set_cursor_locked(locked) end

--------------------------------------------------------------------------------
-- Audio Module
--------------------------------------------------------------------------------

---@class Sound
---Opaque sound handle (userdata). Loaded via `pb.audio.load()`.
---
---Automatically freed by **garbage collection**, or manually via `:destroy()`.
---
---### Example
---```lua
---local sfx = pb.audio.load("jump.wav")
---sfx:play()
---sfx:set_volume(0.5)
---```
---@field play fun(self: Sound) Play the sound from the beginning
---@field stop fun(self: Sound) Stop playback and rewind to start
---@field pause fun(self: Sound) Pause playback at the current position
---@field resume fun(self: Sound) Resume playback from where it was paused
---@field is_playing fun(self: Sound): boolean Check if the sound is currently playing
---@field set_looping fun(self: Sound, loop: boolean) Enable or disable looping
---@field is_looping fun(self: Sound): boolean Check if looping is enabled
---@field set_volume fun(self: Sound, volume: number) Set volume (`0.0` = silent, `1.0` = normal, `>1.0` = amplified)
---@field get_volume fun(self: Sound): number Get current volume
---@field set_pitch fun(self: Sound, pitch: number) Set pitch/speed (`1.0` = normal, `0.5` = half, `2.0` = double)
---@field get_pitch fun(self: Sound): number Get current pitch
---@field destroy fun(self: Sound) Destroy the sound and free resources

---@class PudimBasicsGl.audio
PudimBasicsGl.audio = {}

---Load an audio file (**WAV**, **MP3**, **FLAC**).
---
---Returns `nil, error_string` on failure (does **not** throw).
---
---### Example
---```lua
---local music, err = pb.audio.load("background.mp3")
---if music then
---    music:set_looping(true)
---    music:play()
---end
---```
---@overload fun(self: PudimBasicsGl.audio, filepath: string): Sound?, string?
---@param filepath string Path to the audio file
---@return Sound? sound The loaded sound, or `nil` on failure
---@return string? error Error message if loading failed
function PudimBasicsGl.audio.load(filepath) end

---Set the **master volume** (affects all sounds globally).
---
---### Example
---```lua
---pb.audio.set_master_volume(0.3)  -- 30% volume
---```
---@param volume number Master volume (`0.0` = silent, `1.0` = normal, `>1.0` = amplified)
function PudimBasicsGl.audio.set_master_volume(volume) end

---Get the current **master volume**.
---@return number volume Current master volume
function PudimBasicsGl.audio.get_master_volume() end

---Shutdown the audio engine and release **all** audio resources.
function PudimBasicsGl.audio.shutdown() end

--------------------------------------------------------------------------------
-- Text Module
--------------------------------------------------------------------------------

---@class Font
---Opaque font handle (userdata). Loaded via `pb.text.load()`.
---
---Automatically freed by **garbage collection**, or manually via `:destroy()`.
---
---### Example
---```lua
---local font = pb.text.load("fonts/NotoSans.ttf", 24)
---font:draw("Hello!", 10, 10, 1.0, 1.0, 1.0, 1.0)
---local w, h = font:measure("Hello!")
---```
---@field draw fun(self: Font, text: string, x: number, y: number, r: number|Color, g?: number, b?: number, a?: number) Draw text at position with color
---@field measure fun(self: Font, text: string): number, number Measure text width and height without drawing
---@field set_size fun(self: Font, size: number) Change font size (re-rasterizes the glyph atlas)
---@field get_size fun(self: Font): number Get current font size in pixels
---@field get_line_height fun(self: Font): number Get line height in pixels
---@field destroy fun(self: Font) Destroy font and free resources

---@class PudimBasicsGl.text
PudimBasicsGl.text = {}

---Load a **TrueType** font file (`.ttf`) at a given pixel size.
---
---Returns `nil, error_string` on failure (does **not** throw).
---
---### Example
---```lua
---local font = pb.text.load("/usr/share/fonts/noto/NotoSans-Regular.ttf", 20)
---```
---@overload fun(self: PudimBasicsGl.text, filepath: string, size?: number): Font?, string?
---@param filepath string Path to the `.ttf` font file
---@param size? number Font size in pixels (default: `24`)
---@return Font? font The loaded font, or `nil` on failure
---@return string? error Error message if loading failed
function PudimBasicsGl.text.load(filepath, size) end

---Flush pending text draws to the GPU.
---
---Normally handled automatically by batch switching.
function PudimBasicsGl.text.flush() end

--------------------------------------------------------------------------------
-- Camera Module
--------------------------------------------------------------------------------

---@class PudimBasicsGl.camera
PudimBasicsGl.camera = {}

---Set the **camera position** (world offset).
---
---At `(0, 0)` the view is identical to no camera.
---
---### Example
---```lua
---pb.camera.set_position(player.x - W/2, player.y - H/2)
---```
---@param x number X position in world space
---@param y number Y position in world space
function PudimBasicsGl.camera.set_position(x, y) end

---Get the current camera position.
---@return number x X position
---@return number y Y position
function PudimBasicsGl.camera.get_position() end

---Move the camera by a **delta** offset.
---
---### Example
---```lua
---pb.camera.move(dx * dt, dy * dt)  -- smooth following
---```
---@param dx number Delta X
---@param dy number Delta Y
function PudimBasicsGl.camera.move(dx, dy) end

---Set camera **zoom** level.
---
---Values `> 1.0` zoom in, `< 1.0` zoom out. Zoom is applied around
---the screen center.
---
---### Example
---```lua
---pb.camera.set_zoom(2.0)  -- 2x zoom in
---```
---@param zoom number Zoom level (must be `> 0`)
function PudimBasicsGl.camera.set_zoom(zoom) end

---Get the current camera zoom level.
---@return number zoom Current zoom level
function PudimBasicsGl.camera.get_zoom() end

---Set camera **rotation** in degrees.
---
---Rotation is applied around the screen center.
---@param angle number Rotation angle in degrees
function PudimBasicsGl.camera.set_rotation(angle) end

---Get camera rotation in degrees.
---@return number angle Current rotation angle
function PudimBasicsGl.camera.get_rotation() end

---Center the camera on a **world point**.
---
---Sets the position so that `(x, y)` appears at screen center.
---
---### Example
---```lua
---pb.camera.look_at(player.x, player.y, W, H)
---```
---@param x number World X to center on
---@param y number World Y to center on
---@param screen_width integer Screen width in pixels
---@param screen_height integer Screen height in pixels
function PudimBasicsGl.camera.look_at(x, y, screen_width, screen_height) end

---**Reset** camera to defaults: `position=(0,0)`, `zoom=1`, `rotation=0`.
function PudimBasicsGl.camera.reset() end

---Convert **screen** coordinates to **world** coordinates.
---
---Uses the last screen size from `renderer.begin()`.
---
---### Example
---```lua
---local mx, my = pb.input.get_mouse_position()
---local wx, wy = pb.camera.screen_to_world(mx, my)
---```
---@param sx number Screen X coordinate
---@param sy number Screen Y coordinate
---@return number wx World X coordinate
---@return number wy World Y coordinate
function PudimBasicsGl.camera.screen_to_world(sx, sy) end

---Convert **world** coordinates to **screen** coordinates.
---
---Uses the last screen size from `renderer.begin()`.
---@param wx number World X coordinate
---@param wy number World Y coordinate
---@return number sx Screen X coordinate
---@return number sy Screen Y coordinate
function PudimBasicsGl.camera.world_to_screen(wx, wy) end

--------------------------------------------------------------------------------
-- Shader Module
--------------------------------------------------------------------------------

---@class Shader
---Opaque shader program handle (userdata).
---
---### Example
---```lua
---local shader = pb.shader.create(vert_src, frag_src)
---shader:use()
---shader:set_float("u_time", pb.time.get())
---shader:unuse()
---```
---@field use fun(self: Shader) Bind this shader for rendering
---@field unuse fun(self: Shader) Unbind the shader (restore no program)
---@field set_int fun(self: Shader, name: string, value: integer) Set an `int` uniform
---@field set_float fun(self: Shader, name: string, value: number) Set a `float` uniform
---@field set_vec2 fun(self: Shader, name: string, x: number, y: number) Set a `vec2` uniform
---@field set_vec3 fun(self: Shader, name: string, x: number, y: number, z: number) Set a `vec3` uniform
---@field set_vec4 fun(self: Shader, name: string, x: number, y: number, z: number, w: number) Set a `vec4` uniform
---@field set_mat4 fun(self: Shader, name: string, matrix: number[]) Set a `mat4` uniform (16 floats, column-major)
---@field get_id fun(self: Shader): integer Get the OpenGL program ID
---@field is_valid fun(self: Shader): boolean Check if the shader is valid
---@field destroy fun(self: Shader) Destroy the shader and free GPU resources

---@class PudimBasicsGl.shader
PudimBasicsGl.shader = {}

---Create a shader program from **GLSL source strings**.
---
---Returns `nil, error_string` on compilation or linking failure.
---
---### Example
---```lua
---local shader, err = pb.shader.create(vertex_src, fragment_src)
---if not shader then print("Shader error: " .. err) end
---```
---@param vertex_src string GLSL vertex shader source code
---@param fragment_src string GLSL fragment shader source code
---@return Shader? shader The compiled shader program, or `nil` on failure
---@return string? error Error message if compilation/linking failed
function PudimBasicsGl.shader.create(vertex_src, fragment_src) end

---Load a shader program from **files** on disk.
---
---### Example
---```lua
---local shader = pb.shader.load("shaders/vert.glsl", "shaders/frag.glsl")
---```
---@param vertex_path string Path to the vertex shader file
---@param fragment_path string Path to the fragment shader file
---@return Shader? shader The compiled shader program, or `nil` on failure
---@return string? error Error message if loading/compilation failed
function PudimBasicsGl.shader.load(vertex_path, fragment_path) end

---Unbind the current shader (restore **no program**).
function PudimBasicsGl.shader.unuse() end

--------------------------------------------------------------------------------
-- Math Module
--------------------------------------------------------------------------------

---@class Vec2
---A 2D vector table.
---@field x number X component
---@field y number Y component

---@class Vec3
---A 3D vector table.
---@field x number X component
---@field y number Y component
---@field z number Z component

---@class Vec4
---A 4D vector table.
---@field x number X component
---@field y number Y component
---@field z number Z component
---@field w number W component

---@alias Vec Vec2|Vec3|Vec4

---@class PudimBasicsGl.math
---@field PI number Pi (`~3.14159`)
---@field TAU number Tau = 2π (`~6.28318`)
---@field HALF_PI number Half Pi = π/2 (`~1.5708`)
PudimBasicsGl.math = {}

---**Linear interpolation** between two values.
---
---### Example
---```lua
---local mid = pb.math.lerp(0, 100, 0.5)  -- 50
---```
---@param a number Start value
---@param b number End value
---@param t number Interpolation factor (`0.0` = a, `1.0` = b)
---@return number result Interpolated value
function PudimBasicsGl.math.lerp(a, b, t) end

---**Clamp** a value between `min` and `max`.
---
---### Example
---```lua
---local hp = pb.math.clamp(hp - damage, 0, max_hp)
---```
---@param value number Value to clamp
---@param min number Minimum bound
---@param max number Maximum bound
---@return number result Clamped value
function PudimBasicsGl.math.clamp(value, min, max) end

---Convert **degrees** to **radians**.
---@param degrees number Angle in degrees
---@return number radians Angle in radians
function PudimBasicsGl.math.radians(degrees) end

---Convert **radians** to **degrees**.
---@param radians number Angle in radians
---@return number degrees Angle in degrees
function PudimBasicsGl.math.degrees(radians) end

---Create a **2D vector** table `{x, y}`.
---
---### Example
---```lua
---local pos = pb.math.vec2(100, 200)
---print(pos.x, pos.y)
---```
---@param x? number X component (default `0`)
---@param y? number Y component (default `0`)
---@return Vec2 vec The vector table
function PudimBasicsGl.math.vec2(x, y) end

---Create a **3D vector** table `{x, y, z}`.
---@param x? number X component (default `0`)
---@param y? number Y component (default `0`)
---@param z? number Z component (default `0`)
---@return Vec3 vec The vector table
function PudimBasicsGl.math.vec3(x, y, z) end

---Create a **4D vector** table `{x, y, z, w}`.
---@param x? number X component (default `0`)
---@param y? number Y component (default `0`)
---@param z? number Z component (default `0`)
---@param w? number W component (default `0`)
---@return Vec4 vec The vector table
function PudimBasicsGl.math.vec4(x, y, z, w) end

---**Add** two vectors (works with `Vec2`, `Vec3`, or `Vec4`).
---
---### Example
---```lua
---local v = pb.math.vec_add(pb.math.vec2(1, 2), pb.math.vec2(3, 4))
----- v = {x=4, y=6}
---```
---@param v1 Vec First vector
---@param v2 Vec Second vector
---@return Vec result Sum vector (same dimension as inputs)
function PudimBasicsGl.math.vec_add(v1, v2) end

---**Subtract** two vectors (`v1 - v2`).
---@param v1 Vec First vector
---@param v2 Vec Second vector
---@return Vec result Difference vector
function PudimBasicsGl.math.vec_sub(v1, v2) end

---**Scale** a vector by a scalar factor.
---
---### Example
---```lua
---local doubled = pb.math.vec_scale(velocity, 2.0)
---```
---@param v Vec Vector to scale
---@param scalar number Scale factor
---@return Vec result Scaled vector
function PudimBasicsGl.math.vec_scale(v, scalar) end

---Get the **length** (magnitude) of a vector.
---@param v Vec Vector
---@return number length Vector length (Euclidean norm)
function PudimBasicsGl.math.vec_length(v) end

---**Normalize** a vector (make it unit length).
---
---Returns a zero vector if the input length is `~0`.
---@param v Vec Vector to normalize
---@return Vec result Normalized vector
function PudimBasicsGl.math.vec_normalize(v) end

---Compute the **dot product** of two vectors.
---@param v1 Vec First vector
---@param v2 Vec Second vector
---@return number result Dot product
function PudimBasicsGl.math.vec_dot(v1, v2) end

--------------------------------------------------------------------------------
-- Studio Module
--------------------------------------------------------------------------------

---@class PudimBasicsGl.studio
PudimBasicsGl.studio = {}

---List all files and folders in a **directory**.
---
---Directory entries are returned with a trailing `"/"`.
---
---### Example
---```lua
---local files, err = pb.studio.list_dir(".")
---if files then
---    for _, name in ipairs(files) do print(name) end
---end
---```
---@param path string Directory path to list
---@return string[]? files List of file/folder names, or `nil` on failure
---@return string? err Error message if listing failed
function PudimBasicsGl.studio.list_dir(path) end

---Get the **last modified time** of a file (Unix timestamp).
---
---Useful for **hot-reloading** assets when their file changes.
---
---### Example
---```lua
---local mtime = pb.studio.get_file_modified_time("script.lua")
---if mtime ~= last_mtime then reload() end
---```
---@param path string File path
---@return integer? time Unix timestamp of last modification, or `nil` on failure
---@return string? err Error message if failed
function PudimBasicsGl.studio.get_file_modified_time(path) end

---**Copy** a file from source to destination.
---
---Useful for exporting or packaging game assets.
---
---### Example
---```lua
---local ok, err = pb.studio.copy_file("assets/logo.png", "build/logo.png")
---```
---@param src string Source file path
---@param dest string Destination file path
---@return boolean success `true` if copy succeeded
---@return string? err Error message if copy failed
function PudimBasicsGl.studio.copy_file(src, dest) end

--------------------------------------------------------------------------------
-- UI Module (Immediate Mode GUI)
--------------------------------------------------------------------------------

---@class PudimBasicsGl.ui
PudimBasicsGl.ui = {}

---Set the font used by **all** UI widgets (labels, buttons, sliders).
---
---Must be called **before** `begin_frame()` (or at any time to switch fonts).
---
---### Example
---```lua
---local font = pb.text.load("font.ttf", 16)
---pb.ui.set_font(font)
---```
---@param font Font The loaded font to use
function PudimBasicsGl.ui.set_font(font) end

---Begin a new **UI frame**.
---
---Call **once per frame** before any UI widgets. Reads the mouse state
---from the active window automatically.
---
---### Example
---```lua
---pb.renderer.begin_ui(W, H)
---pb.ui.begin_frame()
----- ... draw UI widgets ...
---pb.ui.end_frame()
---pb.renderer.end_ui()
---```
function PudimBasicsGl.ui.begin_frame() end

---End the current **UI frame** and flush all pending draws.
---
---Call **once per frame** after all UI widgets.
function PudimBasicsGl.ui.end_frame() end

---Draw a **text label** at the given position.
---
---### Example
---```lua
---pb.ui.label("Score: 1200", 10, 10, 1.0, 1.0, 1.0, 1.0)
---```
---@param text string The text to display
---@param x number X position
---@param y number Y position
---@param r? number Red component (`0`–`1`, default `1`)
---@param g? number Green component (`0`–`1`, default `1`)
---@param b? number Blue component (`0`–`1`, default `1`)
---@param a? number Alpha component (`0`–`1`, default `1`)
function PudimBasicsGl.ui.label(text, x, y, r, g, b, a) end

---Draw a **panel** (dark rectangle with optional title bar).
---
---### Example
---```lua
---pb.ui.panel("Inventory", 10, 10, 300, 400)
---```
---@param title? string Title text for the header bar (`nil` for no title)
---@param x number X position
---@param y number Y position
---@param w number Width
---@param h number Height
function PudimBasicsGl.ui.panel(title, x, y, w, h) end

---Draw an interactive **button**. Returns `true` when clicked (on mouse release).
---
---Each button needs a **unique** `id` string so the UI system can track
---hover and active state across frames.
---
---### Example
---```lua
---if pb.ui.button("btn_play", "Play", 100, 200, 120, 40) then
---    start_game()
---end
---```
---@param id string Unique identifier for this button
---@param label string Text displayed on the button
---@param x number X position
---@param y number Y position
---@param w number Width
---@param h number Height
---@param r? number Background red component (`0`–`1`, default `0.3`)
---@param g? number Background green component (`0`–`1`, default `0.4`)
---@param b? number Background blue component (`0`–`1`, default `0.6`)
---@return boolean clicked `true` if the button was clicked this frame
function PudimBasicsGl.ui.button(id, label, x, y, w, h, r, g, b) end

---Draw an interactive **slider** for adjusting a numeric value.
---
---Drag horizontally to change the value between `min` and `max`.
---Each slider needs a **unique** `id` string.
---
---### Example
---```lua
---volume = pb.ui.slider("vol", "Volume", 10, 100, 200, 20, volume, 0.0, 1.0)
---```
---@param id string Unique identifier for this slider
---@param label string Label text displayed on the slider
---@param x number X position
---@param y number Y position
---@param w number Width
---@param h number Height
---@param value number Current value
---@param min number Minimum value
---@param max number Maximum value
---@return number value The (possibly updated) value
function PudimBasicsGl.ui.slider(id, label, x, y, w, h, value, min, max) end

return PudimBasicsGl
