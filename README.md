# PudimBasicsGl - Pudim Basics OpenGL 

A minimal 2D graphics library for Lua using OpenGL. PudimBasicsGl focuses on the essentials: **window management**, **2D rendering**, **textures**, and **time**. Input handling and math utilities are left to the developer's choice.

> [!WARNING]
> This project is **experimental**. APIs and features may change without notice — use with caution.

[Versão em Português (PT-BR)](README.pt-br.md)

## Features

- **Window**: Create and manage OpenGL windows with VSync, fullscreen, and resize support
- **Renderer**: Draw 2D primitives (pixels, lines, rectangles, circles, triangles)
- **Textures**: Load images (PNG, JPG, BMP, etc.) and draw them with rotation, tinting, and sprite sheet support
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
| `color(r, g, b, a)` | Create a color table |
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

- `scripts/main.lua` - Basic rendering demo
- `scripts/texture_demo.lua` - Texture loading and drawing
- `scripts/window_demo.lua` - VSync and window features
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
## Why No Input/Math?

PudimBasicsGl is intentionally minimal. For input, you can:
- Access GLFW directly via `pb.window.get_handle(window)`
- Use a dedicated input library
- Implement your own using FFI

For math, Lua's built-in `math` library covers most needs, and there are excellent libraries like `cpml` or `batteries` available.

## License

MIT
