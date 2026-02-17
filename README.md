# PudimBasicsGl - Pudim Basics OpenGL 

A minimal 2D graphics library for Lua using OpenGL. PudimBasicsGl focuses on the essentials: **window management**, **2D rendering**, **textures**, **input**, **audio**, **text**, and **time**. Math utilities are left to the developer's choice.

> [!WARNING]
> This project is **experimental**. APIs and features may change without notice — use with caution.

[Versão em Português (PT-BR)](README.pt-br.md)

## Features

- **Window**: Create and manage OpenGL windows with VSync, fullscreen, and resize support
- **Renderer**: Draw 2D primitives (pixels, lines, rectangles, circles, triangles)
- **Textures**: Load images (PNG, JPG, BMP, etc.) and draw them with rotation, tinting, and sprite sheet support
- **Input**: Keyboard and mouse input (key state, mouse position, cursor control)
- **Audio**: Load and play audio files (WAV, MP3, FLAC) with volume, pitch, and looping via [miniaudio](https://github.com/mackron/miniaudio)
- **Text**: Load TrueType fonts (.ttf) and render text with customizable size, color, and measurement via [stb_truetype](https://github.com/nothings/stb)
- **Time**: Delta time, FPS, and timing utilities

## Building

```bash
make
```

This creates `PudimBasicsGl.so`, a Lua module that you can load with `require("PudimBasicsGl")`.

## LSP Support

Add `library/` to your `lua-language-server` library path for full autocomplete and type checking:

```json
// .vscode/settings.json
{
    "Lua.workspace.library": ["./library"]
}
```

Or copy `library/PudimBasicsGl.lua` to your global lua-language-server addons folder.

Editor tip: Annotate variables with the qualified types to get method suggestions for instances. For example:

```lua
---@type PudimBasicsGl
local pb = require("PudimBasicsGl")

---@type PudimBasicsGl.Window
local win = pb.window.create(800, 600, "Title")

-- Now `win:` will show methods in VSCode's completion list
win:swap_buffers()

---@type PudimBasicsGl.Texture
local tex = pb.texture.load("sprite.png")
-- `tex:` will show texture methods such as `draw`, `get_size`, etc.

---@type Sound
local snd = pb.audio.load("music.mp3")
-- `snd:` will show audio methods such as `play`, `stop`, `set_volume`, etc.

---@type Font
local font = pb.text.load("my_font.ttf", 32)
-- `font:` will show text methods such as `draw`, `measure`, `set_size`, etc.
```




## Installation via LuaRocks

```bash
luarocks make PudimBasicsGl-1.0.0-1.rockspec
```

## Usage

```lua
local pb = require("PudimBasicsGl")

-- Create a window
local window = pb.window.create(800, 600, "My App")
pb.renderer.init()

-- Load a texture (optional)
local texture = pb.texture.load("sprite.png")

-- Main loop (you control it!)
while not pb.window.should_close(window) do
    pb.time.update()
    local dt = pb.time.delta()
    
    -- Your game logic here
    
    -- Get current window size (handles resize)
    local w, h = pb.window.get_size(window)
    
    -- Render
    pb.renderer.clear(0.1, 0.1, 0.15, 1.0)
    pb.renderer.begin(w, h)
    
    -- Draw primitives
    pb.renderer.rect_filled(100, 100, 50, 50, pb.renderer.colors.RED)
    pb.renderer.circle_filled(400, 300, 30, {r=0, g=1, b=0.5, a=1})
    pb.renderer.flush()  -- Flush primitives before textures
    
    -- Draw textures
    if texture then
        texture:draw(200, 200)  -- Simple draw
        texture:draw_rotated(400, 400, 64, 64, 45)  -- Rotated 45 degrees
    end
    pb.texture.flush()
    
    pb.renderer.finish()
    
    pb.window.swap_buffers(window)
    pb.window.poll_events()
end

if texture then texture:destroy() end
pb.window.destroy(window)
```

### Input Example

```lua
-- Keyboard
if pb.input.is_key_pressed(pb.input.KEY_W) then
    player.y = player.y - speed * dt
end
if pb.input.is_key_pressed(pb.input.KEY_ESCAPE) then
    break
end

-- Mouse
local mx, my = pb.input.get_mouse_position()
if pb.input.is_mouse_button_pressed(pb.input.MOUSE_LEFT) then
    -- handle click
end
```

### Audio Example

```lua
local music = pb.audio.load("music.mp3")
music:set_looping(true)
music:set_volume(0.8)
music:play()

-- Later...
music:pause()
music:resume()
music:stop()
music:destroy()

pb.audio.set_master_volume(0.5)
pb.audio.shutdown()
```

### Text Example

```lua
-- Load a TrueType font at 32px
local font = pb.text.load("my_font.ttf", 32)

-- Draw text (flush primitives first, different shader)
pb.renderer.flush()
font:draw("Hello, World!", 100, 100, 1, 1, 1) -- white text
font:draw("Colored!", 100, 150, {r=1, g=0.5, b=0, a=1}) -- orange text

-- Measure text dimensions
local w, h = font:measure("Hello, World!")

-- Change font size dynamically
font:set_size(48)

-- Flush text before drawing primitives again
pb.text.flush()

-- Cleanup
font:destroy()
```

## API Reference

### pb.window

| Function | Description |
|----------|-------------|
| `create(width, height, title)` | Create a window, returns window handle |
| `destroy(window)` | Destroy window and free resources |
| `should_close(window)` | Check if window should close |
| `close(window)` | Signal window to close |
| `swap_buffers(window)` | Present the rendered frame |
| `poll_events()` | Process window events |
| `get_size(window)` | Get window dimensions |
| `set_size(window, w, h)` | Set window dimensions |
| `set_title(window, title)` | Change window title |
| `get_handle(window)` | Get native GLFW handle |
| `set_vsync(window, enabled)` | Enable/disable VSync |
| `get_vsync(window)` | Check if VSync is enabled |
| `set_fullscreen(window, bool)` | Set fullscreen mode |
| `is_fullscreen(window)` | Check if fullscreen |
| `toggle_fullscreen(window)` | Toggle fullscreen mode |
| `get_position(window)` | Get window position |
| `set_position(window, x, y)` | Set window position |
| `focus(window)` | Focus the window |
| `is_focused(window)` | Check if window has focus |
| `set_resizable(window, bool)` | Enable/disable resize |

### pb.renderer

| Function | Description |
|----------|-------------|
| `init()` | Initialize the renderer |
| `clear(r, g, b, a)` | Clear screen with color |
| `begin(width, height)` | Begin 2D rendering batch |
| `finish()` | End rendering batch |
| `flush()` | Flush without ending batch |
| `pixel(x, y, color)` | Draw a point |
| `line(x1, y1, x2, y2, color)` | Draw a line |
| `rect(x, y, w, h, color)` | Draw rectangle outline |
| `rect_filled(x, y, w, h, color)` | Draw filled rectangle |
| `circle(x, y, radius, color)` | Draw circle outline |
| `circle_filled(x, y, radius, color)` | Draw filled circle |
| `triangle(...)` | Draw triangle outline |
| `triangle_filled(...)` | Draw filled triangle |
| `set_point_size(size)` | Set point rendering size |
| `set_line_width(width)` | Set line rendering width |
| `color(r, g, b, a)` | Create a color table (0.0-1.0 floats or hex) |
| `color255(r, g, b, a)` | Create a color table from 0-255 integers |
| `color_unpack(color)` | Unpack Color table → r, g, b, a (0.0-1.0) |
| `color255_unpack(color)` | Unpack Color table → r, g, b, a (0-255) |
| `colors.WHITE`, `colors.RED`, etc. | Predefined colors |

### pb.texture

| Function | Description |
|----------|-------------|
| `load(filepath)` | Load texture from file (PNG, JPG, BMP, TGA) |
| `create(w, h, data?)` | Create texture with optional RGBA data |
| `flush()` | Flush pending texture draws |

#### Texture Methods

| Method | Description |
|--------|-------------|
| `texture:draw(x, y, w?, h?)` | Draw at position |
| `texture:draw_tinted(x, y, w, h, r, g, b, a?)` | Draw with color tint |
| `texture:draw_rotated(x, y, w, h, angle)` | Draw rotated (degrees) |
| `texture:draw_ex(x, y, w, h, angle, ox, oy, r, g, b, a?)` | Full control draw |
| `texture:draw_region(x, y, w, h, sx, sy, sw, sh)` | Draw sprite sheet region |
| `texture:draw_region_ex(...)` | Region with rotation/tint |
| `texture:get_size()` | Get width, height |
| `texture:get_width()` | Get width |
| `texture:get_height()` | Get height |
| `texture:destroy()` | Free texture resources |

### pb.input

| Function | Description |
|----------|-------------|
| `is_key_pressed(key)` | Check if a key is currently held down |
| `is_key_released(key)` | Check if a key is not held down |
| `is_mouse_button_pressed(button)` | Check if a mouse button is held down |
| `get_mouse_position()` | Get cursor position (x, y) |
| `set_mouse_position(x, y)` | Set cursor position |
| `set_cursor_visible(visible)` | Show/hide the cursor |
| `set_cursor_locked(locked)` | Lock/unlock cursor (FPS-style) |

#### Key Constants

`KEY_A` to `KEY_Z`, `KEY_0` to `KEY_9`, `KEY_SPACE`, `KEY_ESCAPE`, `KEY_ENTER`, `KEY_TAB`, `KEY_BACKSPACE`, `KEY_UP`, `KEY_DOWN`, `KEY_LEFT`, `KEY_RIGHT`, `KEY_F1` to `KEY_F3`, `KEY_F11`, `KEY_F12`, `KEY_LEFT_SHIFT`, `KEY_RIGHT_SHIFT`, `KEY_LEFT_CTRL`, `KEY_RIGHT_CTRL`, `KEY_LEFT_ALT`, `KEY_RIGHT_ALT`

#### Mouse Constants

`MOUSE_LEFT`, `MOUSE_RIGHT`, `MOUSE_MIDDLE`

### pb.audio

| Function | Description |
|----------|-------------|
| `load(filepath)` | Load audio file (WAV, MP3, FLAC), returns Sound |
| `set_master_volume(volume)` | Set master volume (0.0–2.0) |
| `get_master_volume()` | Get current master volume |
| `shutdown()` | Shutdown audio engine |

#### Sound Methods

| Method | Description |
|--------|-------------|
| `sound:play()` | Play from the beginning |
| `sound:stop()` | Stop and rewind |
| `sound:pause()` | Pause at current position |
| `sound:resume()` | Resume from paused position |
| `sound:is_playing()` | Check if playing |
| `sound:set_looping(bool)` | Enable/disable looping |
| `sound:is_looping()` | Check if looping |
| `sound:set_volume(vol)` | Set volume (0.0 = silent, 1.0 = normal) |
| `sound:get_volume()` | Get current volume |
| `sound:set_pitch(pitch)` | Set pitch (1.0 = normal, 0.5 = slow, 2.0 = fast) |
| `sound:get_pitch()` | Get current pitch |
| `sound:destroy()` | Free sound resources |

### pb.text

| Function | Description |
|----------|-------------|
| `load(filepath, size?)` | Load a TrueType font (.ttf) at pixel size (default 24), returns Font |
| `flush()` | Flush pending text draws |

#### Font Methods

| Method | Description |
|--------|-------------|
| `font:draw(text, x, y, color)` | Draw text at position with color |
| `font:measure(text)` | Get text width and height without drawing |
| `font:set_size(size)` | Change font size (re-rasterizes atlas) |
| `font:get_size()` | Get current font size in pixels |
| `font:get_line_height()` | Get line height in pixels |
| `font:destroy()` | Free font resources |

> **Note:** Call `pb.renderer.flush()` before drawing text, and `pb.text.flush()` before drawing primitives — they use different shaders.

### pb.time

| Function | Description |
|----------|-------------|
| `update()` | Update time system (call once per frame) |
| `delta()` | Get time since last frame |
| `get()` | Get total time since init |
| `fps()` | Get current FPS |
| `sleep(seconds)` | Busy-wait sleep |

### Color Format

Colors can be passed as:
- Table: `{r=1.0, g=0.5, b=0.0, a=1.0}`
- Individual values: `r, g, b, a` (alpha optional, defaults to 1.0)

## Examples

We provide several example scripts in the `examples/` directory. A new OOP-style demo demonstrates the object-style API (method calls via `:`) — it shows `window:should_close()`, `texture:draw()`, `pb.time:update()` and a simple render loop.

Run the demo after building/installing the module locally:

```bash
# Build/install locally (optional)
luarocks make --local

# Run example (ensures local .so is in package.cpath)
lua -e "package.cpath='./?.so;'..package.cpath" examples/oop_demo.lua
```

You can also inspect `scripts/test_oop.lua` for a minimal non-visual smoke test of the object-style API.

## Dependencies

- GLFW3
- OpenGL 3.3+
- Lua 5.4 or 5.5

## Building

### Linux

```bash
make
```

The makefile auto-detects your Lua version. To build for a specific version:

```bash
make LUA_VERSION=5.4   # Force Lua 5.4
make LUA_VERSION=5.5   # Force Lua 5.5
```

### Windows (MSYS2/MinGW)

1. Install MSYS2 and open the MinGW64 terminal
2. Install dependencies:
```bash
pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-glfw mingw-w64-x86_64-lua
```
3. Build:
```bash
make
```

This creates `PudimBasicsGl.dll`. Use with:
```lua
-- Windows
package.cpath = ".\\?.dll;" .. package.cpath
local pb = require("PudimBasicsGl")
```

## Example Scripts

- `examples/main.lua` - Basic rendering demo
- `examples/minimal.lua` - Minimal example
- `examples/texture_demo.lua` - Texture loading and drawing
- `examples/window_demo.lua` - VSync and window features
- `examples/input_demo.lua` - Keyboard and mouse input demo
- `examples/audio_demo.lua` - Audio loading and playback demo
- `examples/oop_demo.lua` - Object-oriented style API demo
- `examples/text_demo.lua` - Text rendering and font loading demo
- `examples/api_reference.lua` - Complete API reference example
## Command-line tool (pbgl)

A small CLI named `pbgl` is installed with the rock. It provides two commands:

- `pbgl show-examples` — Copy bundled example scripts to `./demos/` in the current directory
- `pbgl help` — Show usage information

After running `pbgl show-examples` you'll have a `./demos/` folder; run an example with:

```bash
lua demos/main.lua
```

Make sure `~/.luarocks/bin` is in your PATH so you can call `pbgl` directly:

```bash
export PATH="$HOME/.luarocks/bin:$PATH"
```
## Credits

- Sample audio file (`examples/example.mp3`) from [file-examples.com](https://file-examples.com/index.php/sample-audio-files/sample-mp3-download/) — used for testing/demo purposes only.
- [miniaudio](https://github.com/mackron/miniaudio) — single-header audio library by David Reid (public domain / MIT-0).
- [stb_image](https://github.com/nothings/stb) — single-header image loader by Sean Barrett (public domain / MIT).
- [stb_truetype](https://github.com/nothings/stb) — single-header TrueType font rasterizer by Sean Barrett (public domain / MIT).
- [GLAD](https://glad.dav1d.de/) — OpenGL loader generator.

## License

MIT
