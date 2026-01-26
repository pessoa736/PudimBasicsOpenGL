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
local PudimBasicsGl = {}

--------------------------------------------------------------------------------
-- Window Module
--------------------------------------------------------------------------------

---@class PudimBasicsGl.window
PudimBasicsGl.window = {}

---@class Window
---Opaque window handle (userdata)

---Create a new window
---@param width integer Window width in pixels
---@param height integer Window height in pixels
---@param title string Window title
---@return Window? window The window handle, or nil on failure
---@return string? error Error message if creation failed
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

---Load a texture from file (PNG, JPG, BMP, TGA, etc.)
---@param filepath string Path to the image file
---@return Texture? texture The loaded texture, or nil on failure
---@return string? error Error message if loading failed
function PudimBasicsGl.texture.load(filepath) end

---Create an empty texture with optional RGBA data
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

return PudimBasicsGl
