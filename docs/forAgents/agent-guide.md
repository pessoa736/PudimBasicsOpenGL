# PudimBasicsGl - Guide for AI Coding Agents

This document provides essential context for AI coding assistants (like Copilot, Cursor, etc.) generating Lua code using the `PudimBasicsGl` library.

## Core Philosophy
1. **No Inversion of Control**: Unlike LÖVE or other frameworks, `PudimBasicsGl` does *not* provide callbacks like `love.update()` or `love.draw()`. The user writes their own main loop and controls exactly when to update and render.
2. **Minimal & Explicit**: State is global but predictable. The library interacts closely with standard OpenGL pipeline concepts but abstracts away raw GL calls for 2D.
3. **Auto-Flushing Batches**: Rendering is separated into 3 internal batches (Primitives, Textures, Text). The library **automatically flushes** the active batch when switching to a different drawing mode. Manual `flush()` calls are generally not needed anymore.

## Getting Started / Boilerplate

When asked to create a minimal application or game loop, always use this pattern:

```lua
-- Include the local path if building from source, otherwise just require
-- package.cpath = "./?.so;" .. package.cpath 
local pb = require("PudimBasicsGl")

-- 1. Initialize Window & Renderer
local WINDOW_W, WINDOW_H = 800, 600
local win = pb.window.create(WINDOW_W, WINDOW_H, "My App")
pb.renderer.init()

-- 2. Load Resources
local my_font = pb.text.load("font.ttf", 24)
local my_texture = pb.texture.load("sprite.png")

-- 3. Main Loop
while not pb.window.should_close(win) do
    pb.time.update()
    local dt = pb.time.delta()

    -- Input & Logic
    if pb.input.is_key_pressed(pb.input.KEY_ESCAPE) then break end
    
    local w, h = pb.window.get_size(win)

    -- 4. Rendering
    pb.renderer.clear(0.1, 0.1, 0.15, 1.0)
    pb.renderer.begin(w, h)
    
    -- Draw logic goes here...
    pb.renderer.rect_filled(10, 10, 50, 50, pb.renderer.colors.RED)
    if my_texture then my_texture:draw(100, 100) end
    if my_font then my_font:draw("Hello!", 10, 200, pb.renderer.colors.WHITE) end

    pb.renderer.finish()
    
    -- 5. Present
    pb.window.swap_buffers(win)
    pb.window.poll_events()
end

-- 6. Cleanup
if my_font then my_font:destroy() end
if my_texture then my_texture:destroy() end
pb.window.destroy(win)
```

## API Structure (12 Modules)

The API is accessed through `pb.<module_name>`:
- `window`: Window lifecycle and events (`create`, `destroy`, `should_close`, `swap_buffers`, `poll_events`, `get_size`).
- `renderer`: State, canvas, and primitives (`init`, `clear`, `begin`, `finish`, `rect_filled`, `circle`, `begin_ui`).
- `texture`: Texture loading and instantiation (`load`, `load_with_colorkey`, `create`). Returns a `Texture` object.
- `text`: TrueType font loading (`load`). Returns a `Font` object.
- `audio`: Sound loading (`load`). Returns a `Sound` object. Background/streams not split by type.
- `input`: Keyboard and mouse polling (`is_key_pressed`, `get_mouse_position`).
- `time`: Delta time, FPS, and timing (`update`, `delta`, `get`).
- `camera`: 2D Viewport transformations (`set_position`, `set_zoom`, `look_at`, `screen_to_world`).
- `shader`: Custom GLSL shaders (`create`, `load`). Returns `Shader` object.
- `math`: Vector manipulation (`vec2`, `vec_add`, `lerp`, `clamp`) and constants (`math.PI`).
- `studio`: File utilities for tooling (`list_dir`, `get_file_modified_time`).
- `ui`: Immediate-mode GUI (`set_font`, `begin_frame`, `button`, `slider`, `panel`).

## Crucial Patterns to Follow

### 1. Object-Oriented Methods
Resources returned by load functions are Lua userdata bound to C objects. Always invoke their methods using the colon `:` syntax.
*Correct:* `font:draw("text", x, y, color)`
*Incorrect:* `pb.text.draw(font, "text", x, y, color)`

*Available Objects:* 
- `Texture`: `:draw()`, `:draw_rotated()`, `:draw_region()`, `:get_size()`, `:destroy()`
- `Font`: `:draw()`, `:measure()`, `:set_size()`, `:destroy()`
- `Sound`: `:play()`, `:stop()`, `:set_volume()`, `:set_looping()`, `:destroy()`
- `Shader`: `:use()`, `:unuse()`, `:set_float()`, `:set_vec2()`, `:destroy()`

### 2. Colors
Colors can be passed either as a table `{r, g, b, a}` (values 0.0 to 1.0) or often expanded as individual arguments depending on the function.
- Tip: Use predefined colors via `pb.renderer.colors.RED`, `pb.renderer.colors.WHITE`, etc.
- Example: `pb.renderer.rect_filled(x, y, w, h, pb.renderer.colors.YELLOW)`

### 3. Immediate Mode UI
UI elements are screen-space. Call `pb.ui.set_font(font)` **once** before entering the main loop. Wrap your UI calls between `begin_frame()` and `end_frame()`.
```lua
pb.ui.set_font(font)
-- Inside render loop:
pb.renderer.begin_ui(w, h)
pb.ui.begin_frame()
if pb.ui.button("btn1", "Click Me", 10, 10, 100, 30, 0.2, 0.2, 0.2) then
    print("Clicked!")
end
pb.ui.end_frame()
pb.renderer.end_ui()
```

### 4. Working with the Camera
Operations like panning the world or zooming are done via the `pb.camera` module.
The camera applies to everything rendered between `pb.renderer.begin(w, h)` and `pb.renderer.finish()` *unless* UI mode is active.
To render HUDs on top of a zoomed/panned view:
```lua
pb.renderer.begin(w, h)
-- 1. Draw World
-- (Camera transforms apply here automatically)
texture:draw(world_x, world_y)

-- 2. Draw HUD
pb.renderer.begin_ui(w, h)
-- (Camera transforms do NOT apply here)
font:draw("Score: 10", 10, 10, pb.renderer.colors.WHITE)
pb.renderer.end_ui()

pb.renderer.finish()
```

### 5. Memory Management
Always call the `:destroy()` method on objects (`Texture`, `Sound`, `Font`, `Shader`) and `pb.window.destroy(win)` when the application exits. While Lua garbage collection (`__gc`) will eventually catch them, explicit destruction prevents memory leaks during rapid hot-reloading or state switching.
