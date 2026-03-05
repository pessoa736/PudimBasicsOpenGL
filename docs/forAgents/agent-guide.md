# PudimBasicsGl — AI Agent Integration Guide

> This file is intended for AI coding agents (GitHub Copilot, Cursor, Cline, Windsurf, Claude, ChatGPT, etc.) that need to generate Lua code using the PudimBasicsGl library. It contains everything an agent needs to produce correct, idiomatic code without reading the entire codebase.

## Quick Facts

| Property | Value |
|----------|-------|
| Language | Lua 5.4+ |
| Install | `luarocks install pudimbasicsgl` |
| Require | `local pb = require("PudimBasicsGl")` |
| Platform | Linux, Windows (MinGW/MSYS2) |
| Graphics API | OpenGL 3.3 Core |
| License | MIT |
| Repository | https://github.com/pessoa736/PudimBasicsOpenGL |

## 1. Core Architecture — No Framework, No Callbacks

Unlike LÖVE, Raylib-Lua, or other game frameworks, **PudimBasicsGl does NOT control the main loop**. There is no `love.update()`, no `love.draw()`, no `onRender()`. The user writes a standard `while` loop and calls the library functions directly. This is the single most important thing to remember.

## 2. Minimal Boilerplate (Copy-Paste Ready)

Every PudimBasicsGl program follows this exact structure:

```lua
local pb = require("PudimBasicsGl")

-- 1. Create window + init renderer
local W, H = 800, 600
local win = pb.window.create(W, H, "My App")
pb.renderer.init()

-- 2. Load resources (AFTER window creation — needs OpenGL context)
local font = pb.text.load("/usr/share/fonts/TTF/DejaVuSans.ttf", 24)
local tex = pb.texture.load("sprite.png")
local music = pb.audio.load("bgm.mp3")

-- 3. Main loop
while not pb.window.should_close(win) do
    pb.time.update()
    local dt = pb.time.delta()
    local w, h = pb.window.get_size(win)

    -- Input
    if pb.input.is_key_pressed(pb.input.KEY_ESCAPE) then break end

    -- Rendering
    pb.renderer.clear(0.1, 0.1, 0.15, 1.0)
    pb.renderer.begin(w, h)

    -- Draw anything in any order — auto-flush handles batch switching
    pb.renderer.rect_filled(10, 10, 50, 50, pb.renderer.colors.RED)
    if tex then tex:draw(100, 100) end
    if font then font:draw("Hello!", 10, 200, pb.renderer.colors.WHITE) end

    pb.renderer.finish()
    pb.window.swap_buffers(win)
    pb.window.poll_events()
end

-- 4. Cleanup
if font then font:destroy() end
if tex then tex:destroy() end
if music then music:destroy() end
pb.audio.shutdown()
pb.window.destroy(win)
```

## 3. The 12 Modules — Complete API Reference

### 3.1 `pb.window` — Window Lifecycle

```lua
-- Create/destroy
local win = pb.window.create(800, 600, "Title")
pb.window.destroy(win)

-- Loop control
pb.window.should_close(win)        --> boolean
pb.window.close(win)               -- signal close
pb.window.swap_buffers(win)        -- present frame
pb.window.poll_events()            -- process OS events

-- Properties
local w, h = pb.window.get_size(win)
pb.window.set_size(win, 1024, 768)
pb.window.set_title(win, "New Title")
local x, y = pb.window.get_position(win)
pb.window.set_position(win, 100, 100)

-- VSync & Fullscreen
pb.window.set_vsync(win, true)
pb.window.set_fullscreen(win, true)
pb.window.toggle_fullscreen(win)
pb.window.is_fullscreen(win)       --> boolean

-- Focus & Resize
pb.window.focus(win)
pb.window.is_focused(win)          --> boolean
pb.window.set_resizable(win, true)
```

**Important:** Only one window should be active. The most recently created window is the "active window" used by input and UI modules.

### 3.2 `pb.renderer` — Primitives & State

```lua
pb.renderer.init()                          -- call AFTER window.create
pb.renderer.clear(r, g, b, a)              -- clear screen (floats 0.0-1.0)
pb.renderer.begin(screen_w, screen_h)      -- start rendering batch
pb.renderer.finish()                        -- end batch + flush
pb.renderer.flush()                         -- manual flush (rarely needed)

-- Primitives (color as r,g,b,a floats OR a Color table)
pb.renderer.pixel(x, y, color)
pb.renderer.line(x1, y1, x2, y2, color)
pb.renderer.rect(x, y, w, h, color)                     -- outline
pb.renderer.rect_filled(x, y, w, h, color)              -- filled
pb.renderer.circle(cx, cy, radius, color)                -- outline
pb.renderer.circle_filled(cx, cy, radius, color)         -- filled
pb.renderer.triangle(x1,y1, x2,y2, x3,y3, color)        -- outline
pb.renderer.triangle_filled(x1,y1, x2,y2, x3,y3, color) -- filled
pb.renderer.rect_gradient(x, y, w, h, top_color, bottom_color)

-- Settings
pb.renderer.set_point_size(size)
pb.renderer.set_line_width(width)
pb.renderer.set_viewport(x, y, w, h)
pb.renderer.enable_blend(true)
pb.renderer.enable_depth_test(false)      -- disabled by default for 2D

-- Color helpers
local c = pb.renderer.color(1.0, 0.0, 0.0)         -- from floats
local c = pb.renderer.color(0xFF6600)               -- from hex
local c = pb.renderer.color255(255, 128, 0)          -- from 0-255
local r, g, b, a = pb.renderer.color_unpack(c)
local info = pb.renderer.get_info()  --> {version, renderer, vendor, glsl_version}

-- UI mode (screen-space, ignores camera)
pb.renderer.begin_ui(screen_w, screen_h)
-- ...draw HUD here...
pb.renderer.end_ui()

-- Pixel readback (testing / color picking)
local r, g, b, a = pb.renderer.read_pixel(x, y, screen_h) --> 0-255

-- Predefined colors
pb.renderer.colors.WHITE
pb.renderer.colors.BLACK
pb.renderer.colors.RED
pb.renderer.colors.GREEN
pb.renderer.colors.BLUE
pb.renderer.colors.YELLOW
pb.renderer.colors.CYAN
pb.renderer.colors.MAGENTA
pb.renderer.colors.ORANGE
pb.renderer.colors.PURPLE
pb.renderer.colors.GRAY
pb.renderer.colors.DARK_GRAY
pb.renderer.colors.LIGHT_GRAY
```

### 3.3 `pb.texture` — Image Loading & Drawing

```lua
-- Module functions
local tex, err = pb.texture.load("sprite.png")                    -- PNG, JPG, BMP, TGA
local tex = pb.texture.load_with_colorkey("sprite.bmp", 255, 0, 255) -- chroma key (magenta → transparent)
local tex = pb.texture.create(64, 64)                              -- blank texture
pb.texture.flush()                                                 -- manual flush (rarely needed)

-- Object methods (use colon syntax)
tex:draw(x, y)                                    -- draw at original size
tex:draw(x, y, width, height)                     -- draw scaled
tex:draw_tinted(x, y, w, h, r, g, b, a)          -- draw with color tint
tex:draw_rotated(x, y, w, h, angle_degrees)       -- draw rotated
tex:draw_ex(x, y, w, h, angle, ox, oy, r, g, b, a) -- full control
tex:draw_region(x, y, w, h, sx, sy, sw, sh)        -- sprite sheet region
tex:draw_region_ex(x, y, w, h, sx, sy, sw, sh, angle, ox, oy, r, g, b, a)
local w, h = tex:get_size()
local w = tex:get_width()
local h = tex:get_height()
tex:destroy()
```

**Error handling:** `load()` returns `nil, error_string` on failure — never throws.

### 3.4 `pb.input` — Keyboard & Mouse

```lua
-- Keyboard
pb.input.is_key_pressed(pb.input.KEY_W)      --> boolean (held down)
pb.input.is_key_released(pb.input.KEY_W)     --> boolean (not held)

-- Mouse
local mx, my = pb.input.get_mouse_position()
pb.input.set_mouse_position(x, y)
pb.input.is_mouse_button_pressed(pb.input.MOUSE_LEFT)  --> boolean
pb.input.set_cursor_visible(true)
pb.input.set_cursor_locked(true)   -- FPS-style

-- Key constants (partial list — most common):
-- pb.input.KEY_A through pb.input.KEY_Z
-- pb.input.KEY_0 through pb.input.KEY_9
-- pb.input.KEY_SPACE, KEY_ESCAPE, KEY_ENTER, KEY_TAB, KEY_BACKSPACE
-- pb.input.KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT
-- pb.input.KEY_LEFT_SHIFT, KEY_RIGHT_SHIFT, KEY_LEFT_CTRL, KEY_RIGHT_CTRL
-- pb.input.KEY_LEFT_ALT, KEY_RIGHT_ALT
-- pb.input.KEY_F1 through KEY_F12

-- Mouse constants:
-- pb.input.MOUSE_LEFT, MOUSE_RIGHT, MOUSE_MIDDLE
```

### 3.5 `pb.audio` — Sound Playback

```lua
-- Module functions
local snd, err = pb.audio.load("music.mp3")       -- WAV, MP3, FLAC
pb.audio.set_master_volume(0.5)                    -- 0.0 to 2.0
pb.audio.get_master_volume()                       --> number
pb.audio.shutdown()                                -- cleanup engine

-- Object methods
snd:play()
snd:stop()
snd:pause()
snd:resume()
snd:is_playing()           --> boolean
snd:set_looping(true)
snd:is_looping()           --> boolean
snd:set_volume(0.8)        -- 0.0 to 1.0
snd:get_volume()           --> number
snd:set_pitch(1.5)         -- 1.0 = normal, 0.5 = slow, 2.0 = fast
snd:get_pitch()            --> number
snd:destroy()
```

### 3.6 `pb.text` — Font Loading & Text Rendering

```lua
-- Module functions
local font, err = pb.text.load("font.ttf", 32)   -- size in pixels (default 24)
pb.text.flush()                                    -- manual flush (rarely needed)

-- Object methods
font:draw("Hello World", x, y, 1.0, 1.0, 1.0)          -- r, g, b args
font:draw("Hello World", x, y, pb.renderer.colors.RED)  -- or Color table
local tw, th = font:measure("Hello World")               -- get text bounds
font:set_size(48)                                         -- re-rasterize at new size
font:get_size()                                           --> number
font:get_line_height()                                    --> number
font:destroy()
```

### 3.7 `pb.time` — Delta Time & FPS

```lua
pb.time.update()     -- call ONCE per frame at top of loop
pb.time.delta()      --> number (seconds since last frame)
pb.time.get()        --> number (total seconds since init)
pb.time.fps()        --> number (current frames per second)
pb.time.sleep(0.016) -- busy-wait sleep (seconds)
```

### 3.8 `pb.camera` — 2D Camera

```lua
pb.camera.set_position(x, y)              -- move camera origin
local cx, cy = pb.camera.get_position()
pb.camera.move(dx, dy)                    -- relative move
pb.camera.set_zoom(2.0)                   -- 1.0 = normal, >1 = zoom in
pb.camera.get_zoom()                      --> number
pb.camera.set_rotation(45)                -- degrees
pb.camera.get_rotation()                  --> number
pb.camera.look_at(x, y, screen_w, screen_h) -- center on world point
pb.camera.reset()                         -- pos=0,0 zoom=1 rot=0
local wx, wy = pb.camera.screen_to_world(sx, sy)
local sx, sy = pb.camera.world_to_screen(wx, wy)
```

The camera affects everything drawn between `pb.renderer.begin()` and `pb.renderer.finish()`, **except** content inside `begin_ui()`/`end_ui()` blocks.

### 3.9 `pb.shader` — Custom GLSL Shaders

```lua
-- Create from source strings
local shd = pb.shader.create(vertex_src, fragment_src)

-- Or load from files
local shd = pb.shader.load("vert.glsl", "frag.glsl")

-- Use
shd:use()
shd:set_int("uTexture", 0)
shd:set_float("uTime", pb.time.get())
shd:set_vec2("uResolution", 800, 600)
shd:set_vec3("uColor", 1.0, 0.5, 0.0)
shd:set_vec4("uRect", 0, 0, 800, 600)
shd:set_mat4("uProjection", {m1, m2, ... m16})   -- 16 floats, column-major
-- draw geometry...
shd:unuse()
pb.shader.unuse()       -- global unbind (equivalent)

shd:get_id()            --> OpenGL program ID
shd:is_valid()          --> boolean
shd:destroy()
```

### 3.10 `pb.math` — Vector Math & Utilities

```lua
-- Scalar utilities
pb.math.lerp(a, b, t)               --> number
pb.math.clamp(val, min, max)        --> number
pb.math.radians(degrees)            --> number
pb.math.degrees(radians)            --> number

-- Vector creation (returns tables with x, y, z, w fields)
local v2 = pb.math.vec2(1.0, 2.0)        --> {x=1.0, y=2.0}
local v3 = pb.math.vec3(1.0, 2.0, 3.0)   --> {x=1.0, y=2.0, z=3.0}
local v4 = pb.math.vec4(1, 2, 3, 4)      --> {x=1, y=2, z=3, w=4}

-- Vector operations (vec2/vec3/vec4 — dimension matched automatically)
local sum    = pb.math.vec_add(a, b)      --> new vector
local diff   = pb.math.vec_sub(a, b)      --> new vector
local scaled = pb.math.vec_scale(v, 2.0)  --> new vector
local len    = pb.math.vec_length(v)      --> number
local norm   = pb.math.vec_normalize(v)   --> new vector
local d      = pb.math.vec_dot(a, b)      --> number

-- Constants
pb.math.PI        -- 3.14159...
pb.math.TAU       -- 6.28318... (2π)
pb.math.HALF_PI   -- 1.57079... (π/2)
```

**Important:** Vectors use named fields (`v.x`, `v.y`, `v.z`, `v.w`), **not** array indices (`v[1]`, `v[2]`).

### 3.11 `pb.studio` — File System Utilities

```lua
local files = pb.studio.list_dir("./assets")           --> {"file1.png", "file2.lua", ...}
local mtime = pb.studio.get_file_modified_time("f.lua") --> number (timestamp)
local ok = pb.studio.copy_file("src.txt", "dst.txt")   --> boolean
```

### 3.12 `pb.ui` — Immediate-Mode GUI

```lua
-- Setup (call ONCE before the main loop)
pb.ui.set_font(font)

-- Every frame, inside render loop:
pb.renderer.begin_ui(w, h)
pb.ui.begin_frame()

pb.ui.label("Score: 100", 10, 10, 1.0, 1.0, 1.0, 1.0)
pb.ui.panel("Settings", 50, 50, 300, 200)

if pb.ui.button("btn_play", "Play", 60, 80, 120, 30, 0.2, 0.6, 0.2) then
    print("Play clicked!")
end

slider_val = pb.ui.slider("sld_vol", "Volume", 60, 120, 200, 20, slider_val, 0.0, 1.0)

pb.ui.end_frame()
pb.renderer.end_ui()
```

**Critical rules for UI:**
- `set_font()` must be called **before** the first `begin_frame()`.
- Buttons return `true` on the frame they are clicked.
- Sliders return the (possibly updated) value every frame.
- IDs (first arg of button/slider) must be unique strings.
- Always wrap in `begin_ui()`/`end_ui()` for correct screen-space rendering.

## 4. Critical Rules for Correct Code

### 4.1 Auto-Flush Batch Switching
The renderer uses 3 internal batches: **Primitives**, **Textures**, **Text**. When you switch from drawing primitives to textures (or any other combination), the library **automatically flushes** the previous batch. You do **NOT** need to call `flush()` between different draw types.

```lua
-- CORRECT — just draw in any order
pb.renderer.rect_filled(10, 10, 50, 50, pb.renderer.colors.RED)
tex:draw(100, 100)                    -- auto-flushes primitives first
font:draw("Hi", 10, 200, 1, 1, 1)    -- auto-flushes textures first
pb.renderer.circle_filled(300, 300, 20, pb.renderer.colors.BLUE) -- auto-flushes text first
```

### 4.2 Resource Loading Requires OpenGL Context
**Always create a window before loading textures, fonts, or initializing the renderer.** The window creation establishes the OpenGL context.

```lua
-- WRONG
local tex = pb.texture.load("img.png")  -- crashes! no OpenGL context
local win = pb.window.create(800, 600, "App")

-- CORRECT
local win = pb.window.create(800, 600, "App")
pb.renderer.init()
local tex = pb.texture.load("img.png")  -- works!
```

### 4.3 Use Colon Syntax for Object Methods
Resources (Texture, Font, Sound, Shader) are Lua userdata with metatables. Always use `:` for method calls.

```lua
-- CORRECT
tex:draw(100, 100)
font:draw("Hi", 10, 10, 1, 1, 1)

-- WRONG — these will error
pb.texture.draw(tex, 100, 100)     -- not how it works
tex.draw(100, 100)                 -- missing self
```

### 4.4 Error Handling for Resource Loading
`load()` functions return `nil, error_string` on failure. They do NOT throw Lua errors.

```lua
local tex, err = pb.texture.load("missing.png")
if not tex then
    print("Failed to load texture: " .. err)
end
```

### 4.5 Colors — Two Valid Formats
Colors can be passed as:
1. **Separate floats:** `r, g, b, a` (0.0–1.0, alpha optional defaults to 1.0)
2. **Color table:** `{r=1.0, g=0.5, b=0.0, a=1.0}` or predefined `pb.renderer.colors.RED`

```lua
-- Both are equivalent:
pb.renderer.rect_filled(10, 10, 50, 50, 1.0, 0.0, 0.0, 1.0)
pb.renderer.rect_filled(10, 10, 50, 50, pb.renderer.colors.RED)
```

### 4.6 Cleanup Order
```lua
-- Destroy resources first, then window last
font:destroy()
tex:destroy()
music:destroy()
pb.audio.shutdown()
pb.window.destroy(win)
```

### 4.7 Camera + HUD Layer Pattern
```lua
pb.renderer.begin(w, h)
-- World-space (affected by camera)
pb.camera.set_position(cam_x, cam_y)
pb.camera.set_zoom(2.0)
world_texture:draw(world_x, world_y)

-- Screen-space HUD (ignores camera)
pb.renderer.begin_ui(w, h)
font:draw("HP: 100", 10, 10, pb.renderer.colors.WHITE)
pb.renderer.end_ui()

pb.renderer.finish()
```

## 5. Common Recipes

### Moving a Player with Keyboard

```lua
local px, py = 400, 300
local speed = 200

while not pb.window.should_close(win) do
    pb.time.update()
    local dt = pb.time.delta()

    if pb.input.is_key_pressed(pb.input.KEY_W) then py = py - speed * dt end
    if pb.input.is_key_pressed(pb.input.KEY_S) then py = py + speed * dt end
    if pb.input.is_key_pressed(pb.input.KEY_A) then px = px - speed * dt end
    if pb.input.is_key_pressed(pb.input.KEY_D) then px = px + speed * dt end

    -- render...
    pb.renderer.rect_filled(px, py, 32, 32, pb.renderer.colors.GREEN)
end
```

### Sprite Sheet Animation

```lua
local sheet = pb.texture.load("spritesheet.png")
local frame = 0
local frame_timer = 0
local FRAME_W, FRAME_H = 32, 32
local FRAME_COUNT = 4

-- In loop:
frame_timer = frame_timer + dt
if frame_timer >= 0.1 then
    frame = (frame + 1) % FRAME_COUNT
    frame_timer = 0
end

sheet:draw_region(100, 100, FRAME_W * 2, FRAME_H * 2,
    frame * FRAME_W, 0, FRAME_W, FRAME_H)
```

### Follow Camera

```lua
-- Center camera on player
pb.camera.look_at(player_x, player_y, screen_w, screen_h)
```

### Debug UI Overlay

```lua
local show_debug = false

-- In input section:
if pb.input.is_key_pressed(pb.input.KEY_F3) then
    show_debug = not show_debug
end

-- In render section:
if show_debug then
    pb.renderer.begin_ui(w, h)
    pb.ui.begin_frame()
    pb.ui.panel("Debug", 10, 10, 200, 100)
    pb.ui.label(string.format("FPS: %.0f", pb.time.fps()), 20, 40, 1, 1, 1, 1)
    pb.ui.label(string.format("DT: %.3f", pb.time.delta()), 20, 60, 1, 1, 1, 1)
    pb.ui.label(string.format("Pos: %.0f, %.0f", px, py), 20, 80, 1, 1, 1, 1)
    pb.ui.end_frame()
    pb.renderer.end_ui()
end
```

### Background Music with Volume Slider

```lua
local music = pb.audio.load("bgm.mp3")
music:set_looping(true)
music:play()
local vol = 0.8

-- In UI frame:
vol = pb.ui.slider("sld_music", "Music", 10, 10, 200, 20, vol, 0.0, 1.0)
music:set_volume(vol)
```

## 6. What NOT to Do

| Mistake | Why It's Wrong | Correct |
|---------|---------------|---------|
| `love.draw()` style callbacks | PudimBasicsGl has no callbacks | Write your own `while` loop |
| `pb.renderer.flush()` between draw types | Auto-flush handles this | Just draw in any order |
| Load resources before `window.create()` | No OpenGL context yet | Create window first |
| `tex.draw(x, y)` | Missing `self` parameter | `tex:draw(x, y)` |
| Forget `pb.time.update()` | `delta()` and `fps()` return 0 | Call at top of every frame |
| Forget `pb.renderer.init()` | Nothing will render | Call after `window.create()` |
| Forget `pb.window.poll_events()` | Window freezes / stops responding | Call every frame |
| `pb.window.swap_buffers()` without arg | Needs the window handle | `pb.window.swap_buffers(win)` |
| `v[1]` for vector x component | Vectors use named fields | `v.x`, `v.y`, `v.z`, `v.w` |

## 7. LSP Type Annotations

When generating code for users who use VS Code with LuaLS, add type annotations:

```lua
---@type PudimBasicsGl
local pb = require("PudimBasicsGl")

---@type Window
local win = pb.window.create(800, 600, "App")

---@type Texture
local tex = pb.texture.load("img.png")

---@type Font
local font = pb.text.load("font.ttf", 24)

---@type Sound
local music = pb.audio.load("bgm.mp3")

---@type Shader
local shd = pb.shader.create(vs, fs)
```

This enables full autocomplete and type checking in the editor.
