---@diagnostic disable: duplicate-doc-alias, duplicate-doc-field, duplicate-doc-param

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


---@class PudimBasicsGl.window: Window
---@field create fun(width: integer, height: integer, title: string): Window
PudimBasicsGl.window = {}

function PudimBasicsGl.window.create(width, height, title) end

---Destroy a window and free resources
---@param window Window The window to destroy
function PudimBasicsGl.window.destroy(window) end

---Check if the window should close
---@param window Window The window to check
---@return boolean should_close True if the window should close
function PudimBasicsGl.window.should_close(window) end

---Signal that the window should close
---@param window Window The window to close
function PudimBasicsGl.window.close(window) end

---Swap the front and back buffers (present the frame)
---@param window Window The window to swap buffers for
function PudimBasicsGl.window.swap_buffers(window) end

---Poll for window events (call once per frame)
function PudimBasicsGl.window.poll_events() end

---Get the window size
---@param window Window The window to query
---@return integer width Window width in pixels
---@return integer height Window height in pixels
function PudimBasicsGl.window.get_size(window) end

---Set the window size
---@param window Window The window to modify
---@param width integer New width in pixels
---@param height integer New height in pixels
function PudimBasicsGl.window.set_size(window, width, height) end

---Set the window title
---@param window Window The window to modify
---@param title string The new window title
function PudimBasicsGl.window.set_title(window, title) end

---Get the native GLFW window handle (for advanced use)
---@param window Window The window
---@return userdata handle The GLFW window pointer
function PudimBasicsGl.window.get_handle(window) end

---Enable or disable VSync
---@param window Window The window
---@param enabled boolean True to enable VSync, false to disable
function PudimBasicsGl.window.set_vsync(window, enabled) end

---Check if VSync is enabled
---@param window Window The window
---@return boolean vsync True if VSync is enabled
function PudimBasicsGl.window.get_vsync(window) end

---Set fullscreen mode
---@param window Window The window
---@param fullscreen boolean True for fullscreen, false for windowed
function PudimBasicsGl.window.set_fullscreen(window, fullscreen) end

---Check if window is fullscreen
---@param window Window The window
---@return boolean fullscreen True if fullscreen
function PudimBasicsGl.window.is_fullscreen(window) end

---Toggle fullscreen mode
---@param window Window The window
function PudimBasicsGl.window.toggle_fullscreen(window) end

---Get window position
---@param window Window The window
---@return integer x X position on screen
---@return integer y Y position on screen
function PudimBasicsGl.window.get_position(window) end

---Set window position
---@param window Window The window
---@param x integer X position on screen
---@param y integer Y position on screen
function PudimBasicsGl.window.set_position(window, x, y) end

---Focus the window
---@param window Window The window to focus
function PudimBasicsGl.window.focus(window) end

---Check if window is focused
---@param window Window The window
---@return boolean focused True if window has focus
function PudimBasicsGl.window.is_focused(window) end

---Enable or disable window resizing
---@param window Window The window
---@param resizable boolean True to allow resizing
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

---Initialize the renderer (call after creating window)
function PudimBasicsGl.renderer.init() end

---Clear the screen with a color
---@param r number Red component (0.0 - 1.0)
---@param g number Green component (0.0 - 1.0)
---@param b number Blue component (0.0 - 1.0)
---@param a number? Alpha component (0.0 - 1.0), defaults to 1.0
function PudimBasicsGl.renderer.clear(r, g, b, a) end

---Begin a 2D rendering batch
---@param width integer Screen/viewport width
---@param height integer Screen/viewport height
function PudimBasicsGl.renderer.begin(width, height) end

---End the 2D rendering batch and flush to screen
function PudimBasicsGl.renderer.finish() end

---Flush the current batch without ending
function PudimBasicsGl.renderer.flush() end

---Draw a single pixel
---@param x integer X coordinate
---@param y integer Y coordinate
---@param r number|Color Red component or Color table
---@param g number? Green component (if r is number)
---@param b number? Blue component (if r is number)
---@param a number? Alpha component (if r is number)
function PudimBasicsGl.renderer.pixel(x, y, r, g, b, a) end

---Draw a line
---@param x1 integer Start X coordinate
---@param y1 integer Start Y coordinate
---@param x2 integer End X coordinate
---@param y2 integer End Y coordinate
---@param r number|Color Red component or Color table
---@param g number? Green component (if r is number)
---@param b number? Blue component (if r is number)
---@param a number? Alpha component (if r is number)
function PudimBasicsGl.renderer.line(x1, y1, x2, y2, r, g, b, a) end

---Draw a rectangle outline
---@param x integer X coordinate (top-left)
---@param y integer Y coordinate (top-left)
---@param width integer Rectangle width
---@param height integer Rectangle height
---@param r number|Color Red component or Color table
---@param g number? Green component (if r is number)
---@param b number? Blue component (if r is number)
---@param a number? Alpha component (if r is number)
function PudimBasicsGl.renderer.rect(x, y, width, height, r, g, b, a) end

---Draw a filled rectangle
---@param x integer X coordinate (top-left)
---@param y integer Y coordinate (top-left)
---@param width integer Rectangle width
---@param height integer Rectangle height
---@param r number|Color Red component or Color table
---@param g number? Green component (if r is number)
---@param b number? Blue component (if r is number)
---@param a number? Alpha component (if r is number)
function PudimBasicsGl.renderer.rect_filled(x, y, width, height, r, g, b, a) end

---Draw a circle outline
---@param cx integer Center X coordinate
---@param cy integer Center Y coordinate
---@param radius integer Circle radius
---@param r number|Color Red component or Color table
---@param g number? Green component (if r is number)
---@param b number? Blue component (if r is number)
---@param a number? Alpha component (if r is number)
function PudimBasicsGl.renderer.circle(cx, cy, radius, r, g, b, a) end

---Draw a filled circle
---@param cx integer Center X coordinate
---@param cy integer Center Y coordinate
---@param radius integer Circle radius
---@param r number|Color Red component or Color table
---@param g number? Green component (if r is number)
---@param b number? Blue component (if r is number)
---@param a number? Alpha component (if r is number)
function PudimBasicsGl.renderer.circle_filled(cx, cy, radius, r, g, b, a) end

---Draw a triangle outline
---@param x1 integer First vertex X
---@param y1 integer First vertex Y
---@param x2 integer Second vertex X
---@param y2 integer Second vertex Y
---@param x3 integer Third vertex X
---@param y3 integer Third vertex Y
---@param r number|Color Red component or Color table
---@param g number? Green component (if r is number)
---@param b number? Blue component (if r is number)
---@param a number? Alpha component (if r is number)
function PudimBasicsGl.renderer.triangle(x1, y1, x2, y2, x3, y3, r, g, b, a) end

---Draw a filled triangle
---@param x1 integer First vertex X
---@param y1 integer First vertex Y
---@param x2 integer Second vertex X
---@param y2 integer Second vertex Y
---@param x3 integer Third vertex X
---@param y3 integer Third vertex Y
---@param r number|Color Red component or Color table
---@param g number? Green component (if r is number)
---@param b number? Blue component (if r is number)
---@param a number? Alpha component (if r is number)
function PudimBasicsGl.renderer.triangle_filled(x1, y1, x2, y2, x3, y3, r, g, b, a) end

---Set the point size for pixel drawing
---@param size number Point size in pixels
function PudimBasicsGl.renderer.set_point_size(size) end

---Set the line width for line drawing
---@param width number Line width in pixels
function PudimBasicsGl.renderer.set_line_width(width) end

---Create a color table
---@param r number|integer Red component (0.0-1.0) or hex color (0xRRGGBB)
---@param g number? Green component (0.0-1.0)
---@param b number? Blue component (0.0-1.0)
---@param a number? Alpha component (0.0-1.0), defaults to 1.0
---@return Color color The color table
function PudimBasicsGl.renderer.color(r, g, b, a) end

---Create a color table from integer values (0-255)
---@param r integer Red component (0-255)
---@param g integer Green component (0-255)
---@param b integer Blue component (0-255)
---@param a integer? Alpha component (0-255), defaults to 255
---@return Color color The color table (converted to 0.0-1.0)
function PudimBasicsGl.renderer.color255(r, g, b, a) end

---Unpack a Color table into individual float values (0.0-1.0)
---@param color Color The color table to unpack
---@return number r Red component (0.0-1.0)
---@return number g Green component (0.0-1.0)
---@return number b Blue component (0.0-1.0)
---@return number a Alpha component (0.0-1.0)
function PudimBasicsGl.renderer.color_unpack(color) end

---Unpack a Color table into individual integer values (0-255)
---@param color Color The color table to unpack
---@return integer r Red component (0-255)
---@return integer g Green component (0-255)
---@return integer b Blue component (0-255)
---@return integer a Alpha component (0-255)
function PudimBasicsGl.renderer.color255_unpack(color) end

---Set the clear color (used by clear())
---@param r number Red component (0.0-1.0)
---@param g number Green component (0.0-1.0)
---@param b number Blue component (0.0-1.0)
---@param a number? Alpha component (0.0-1.0), defaults to 1.0
function PudimBasicsGl.renderer.set_clear_color(r, g, b, a) end

---Enable or disable depth testing
---@param enable boolean True to enable, false to disable
function PudimBasicsGl.renderer.enable_depth_test(enable) end

---Enable or disable alpha blending
---@param enable boolean True to enable, false to disable
function PudimBasicsGl.renderer.enable_blend(enable) end

---Set the viewport
---@param x integer Viewport X offset
---@param y integer Viewport Y offset
---@param width integer Viewport width
---@param height integer Viewport height
function PudimBasicsGl.renderer.set_viewport(x, y, width, height) end

---Get OpenGL information
---@return table info Table with version, renderer, vendor, glsl_version
function PudimBasicsGl.renderer.get_info() end

--------------------------------------------------------------------------------
-- Texture Module
--------------------------------------------------------------------------------

---@class PudimBasicsGl.texture
PudimBasicsGl.texture = {}

---@class PudimBasicsGl.Texture
---@class Texture
---Opaque texture handle (userdata)
---@field draw fun(self: PudimBasicsGl.Texture, x: integer, y: integer, width?: integer, height?: integer) Draw texture at position
---@field draw_tinted fun(self: PudimBasicsGl.Texture, x: integer, y: integer, width: integer, height: integer, r: number, g: number, b: number, a?: number) Draw texture with color tint
---@field draw_rotated fun(self: PudimBasicsGl.Texture, x: integer, y: integer, width: integer, height: integer, angle: number) Draw rotated texture (angle in degrees)
---@field draw_ex fun(self: PudimBasicsGl.Texture, x: integer, y: integer, width: integer, height: integer, angle: number, origin_x?: number, origin_y?: number, r?: number, g?: number, b?: number, a?: number) Draw with full options
---@field draw_region fun(self: PudimBasicsGl.Texture, x: integer, y: integer, width: integer, height: integer, src_x: integer, src_y: integer, src_width: integer, src_height: integer) Draw a portion of texture (sprite sheet)
---@field draw_region_ex fun(self: PudimBasicsGl.Texture, x: integer, y: integer, width: integer, height: integer, src_x: integer, src_y: integer, src_width: integer, src_height: integer, angle?: number, origin_x?: number, origin_y?: number, r?: number, g?: number, b?: number, a?: number) Draw region with full options
---@field get_size fun(self: PudimBasicsGl.Texture): integer, integer Get texture dimensions
---@field get_width fun(self: PudimBasicsGl.Texture): integer Get texture width
---@field get_height fun(self: PudimBasicsGl.Texture): integer Get texture height
---@field destroy fun(self: PudimBasicsGl.Texture) Destroy texture and free resources

---@class PudimBasicsGl.texture: Texture
---@field load fun(filepath: string): Texture
---@field create fun(width: integer, height: integer, data?: table): Texture

---Load a texture from file (PNG, JPG, BMP, TGA, etc.)
---Also available as method: `pb.texture:load(filepath)`
---@overload fun(self: PudimBasicsGl.texture, filepath: string): Texture?
---@param filepath string Path to the image file
---@return Texture? texture The loaded texture, or nil on failure
---@return string? error Error message if loading failed
function PudimBasicsGl.texture.load(filepath) end

---Create an empty texture with optional RGBA data
---Also available as method: `pb.texture:create(width, height, data)`
---@overload fun(self: PudimBasicsGl.texture, width: integer, height: integer, data?: table): Texture?
---@param width integer Texture width in pixels
---@param height integer Texture height in pixels
---@param data? table Optional array of RGBA bytes (width * height * 4 values)
---@return Texture? texture The created texture, or nil on failure
---@return string? error Error message if creation failed
function PudimBasicsGl.texture.create(width, height, data) end

---Flush pending texture draws to the screen
function PudimBasicsGl.texture.flush() end

--------------------------------------------------------------------------------
-- Time Module
--------------------------------------------------------------------------------

---@class PudimBasicsGl.time
PudimBasicsGl.time = {}

---Note: All `PudimBasicsGl.time.*` functions accept method-style calls (e.g. `pb.time:get()`),
---in addition to the module-style `pb.time.get()`.

---Get total time since the library was initialized
---@return number time Time in seconds
function PudimBasicsGl.time.get() end

---Get the delta time (time since last frame)
---@return number dt Delta time in seconds
function PudimBasicsGl.time.delta() end

---Update the time system (call once per frame at the start of the loop)
function PudimBasicsGl.time.update() end

---Get the current frames per second
---@return number fps Current FPS
function PudimBasicsGl.time.fps() end

---Sleep for a specified duration (busy wait)
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

---Check if a key is currently pressed
---@param key integer Key constant (e.g. `pb.input.KEY_SPACE`)
---@return boolean pressed True if the key is held down
function PudimBasicsGl.input.is_key_pressed(key) end

---Check if a key is currently released (not pressed)
---@param key integer Key constant (e.g. `pb.input.KEY_W`)
---@return boolean released True if the key is not held down
function PudimBasicsGl.input.is_key_released(key) end

---Check if a mouse button is currently pressed
---@param button integer Mouse button constant (e.g. `pb.input.MOUSE_LEFT`)
---@return boolean pressed True if the button is held down
function PudimBasicsGl.input.is_mouse_button_pressed(button) end

---Get the current mouse cursor position relative to the window
---@return number x Cursor X position in pixels
---@return number y Cursor Y position in pixels
function PudimBasicsGl.input.get_mouse_position() end

---Set the mouse cursor position
---@param x number X position in pixels
---@param y number Y position in pixels
function PudimBasicsGl.input.set_mouse_position(x, y) end

---Show or hide the mouse cursor
---@param visible boolean True to show the cursor, false to hide it
function PudimBasicsGl.input.set_cursor_visible(visible) end

---Lock or unlock the mouse cursor (for FPS-style camera control)
---@param locked boolean True to lock (disable) the cursor, false to unlock
function PudimBasicsGl.input.set_cursor_locked(locked) end

--------------------------------------------------------------------------------
-- Audio Module
--------------------------------------------------------------------------------

---@class Sound
---Opaque sound handle (userdata). Loaded via `pb.audio.load()`.
---Automatically freed by garbage collection, or manually via `:destroy()`.
---@field play fun(self: Sound) Play the sound from the beginning
---@field stop fun(self: Sound) Stop playback and rewind to start
---@field pause fun(self: Sound) Pause playback at the current position
---@field resume fun(self: Sound) Resume playback from where it was paused
---@field is_playing fun(self: Sound): boolean Check if the sound is currently playing
---@field set_looping fun(self: Sound, loop: boolean) Enable or disable looping
---@field is_looping fun(self: Sound): boolean Check if looping is enabled
---@field set_volume fun(self: Sound, volume: number) Set volume (0.0 = silent, 1.0 = normal, >1.0 = amplified)
---@field get_volume fun(self: Sound): number Get current volume
---@field set_pitch fun(self: Sound, pitch: number) Set pitch/speed (1.0 = normal, 0.5 = half speed, 2.0 = double)
---@field get_pitch fun(self: Sound): number Get current pitch
---@field destroy fun(self: Sound) Destroy the sound and free resources

---@class PudimBasicsGl.audio
PudimBasicsGl.audio = {}

---Load an audio file (WAV, MP3, FLAC)
---Also available as method: `pb.audio:load(filepath)`
---@overload fun(self: PudimBasicsGl.audio, filepath: string): Sound?, string?
---@param filepath string Path to the audio file
---@return Sound? sound The loaded sound, or nil on failure
---@return string? error Error message if loading failed
function PudimBasicsGl.audio.load(filepath) end

---Set the master volume (affects all sounds)
---@param volume number Master volume (0.0 = silent, 1.0 = normal, >1.0 = amplified)
function PudimBasicsGl.audio.set_master_volume(volume) end

---Get the current master volume
---@return number volume Current master volume
function PudimBasicsGl.audio.get_master_volume() end

---Shutdown the audio engine and release all resources
function PudimBasicsGl.audio.shutdown() end

--------------------------------------------------------------------------------
-- Text Module
--------------------------------------------------------------------------------

---@class Font
---Opaque font handle (userdata). Loaded via `pb.text.load()`.
---Automatically freed by garbage collection, or manually via `:destroy()`.
---@field draw fun(self: Font, text: string, x: number, y: number, r: number|Color, g?: number, b?: number, a?: number) Draw text at position with color
---@field measure fun(self: Font, text: string): number, number Measure text width and height
---@field set_size fun(self: Font, size: number) Change font size (re-rasterizes atlas)
---@field get_size fun(self: Font): number Get current font size in pixels
---@field get_line_height fun(self: Font): number Get line height in pixels
---@field destroy fun(self: Font) Destroy font and free resources

---@class PudimBasicsGl.text
PudimBasicsGl.text = {}

---Load a TrueType font file (.ttf) at a given pixel size
---Also available as method: `pb.text:load(filepath, size)`
---@overload fun(self: PudimBasicsGl.text, filepath: string, size?: number): Font?, string?
---@param filepath string Path to the .ttf font file
---@param size? number Font size in pixels (default: 24)
---@return Font? font The loaded font, or nil on failure
---@return string? error Error message if loading failed
function PudimBasicsGl.text.load(filepath, size) end

---Flush pending text draws to the screen
function PudimBasicsGl.text.flush() end

return PudimBasicsGl
