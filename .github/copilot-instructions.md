# PudimBasicsGl — Copilot Instructions

## Project Overview

**PudimBasicsGl** is a minimal 2D graphics library for Lua, written in C17, using OpenGL 3.3 Core. It compiles to a shared library (`PudimBasicsGl.so` / `.dll`) loaded via Lua's `require("PudimBasicsGl")`. The project targets **Lua 5.4 / 5.5** and runs on **Linux** and **Windows (MinGW/MSYS2)**.

The library exposes a global `PudimBasicsGl` table with sub-modules: `window`, `renderer`, `texture`, `input`, `audio`, `time`, and `math`. The user controls the main loop — there is no framework-imposed game loop.

GitHub repository: `pessoa736/PudimBasicsOpenGL`  
License: MIT  
Package manager: LuaRocks (`pudimbasicsgl`)

---

## File Structure

```
src/
├── main.c                  # Module entry point: luaopen_PudimBasicsGl()
├── core/                   # Lua C bindings (one file per module)
│   ├── lua_window.c        # pb.window.* — Window userdata + metatable
│   ├── lua_renderer.c      # pb.renderer.* — Stateless drawing functions
│   ├── lua_texture.c       # pb.texture.* — Texture userdata + metatable
│   ├── lua_input.c         # pb.input.* — Stateless key/mouse queries + constants
│   ├── lua_time.c          # pb.time.* — Stateless timing functions
│   ├── lua_audio.c         # pb.audio.* — Sound userdata + metatable
│   ├── lua_text.c          # pb.text.* — Font userdata + metatable
│   └── lua_math.c          # pb.math.* — Utility math functions
├── platform/
│   ├── window.h            # C API header for window management
│   └── window.c            # GLFW window implementation
├── render/
│   ├── renderer.h          # C API header for 2D primitives
│   ├── renderer.c          # OpenGL batched primitive renderer
│   ├── texture.h           # C API header for textures
│   ├── texture.c           # OpenGL texture loading/rendering (stb_image)
│   ├── text.h              # C API header for text rendering
│   └── text.c              # TrueType text rendering (stb_truetype)
└── audio/
    ├── audio.h             # C API header for audio
    └── audio.c             # miniaudio implementation

external/                   # Third-party single-header libraries (vendored)
├── glad/                   # OpenGL loader (glad)
├── miniaudio/              # Audio engine (miniaudio.h)
└── stb/                    # Image loading (stb_image.h), font rasterization (stb_truetype.h)

library/
└── PudimBasicsGl.lua       # LuaLS (@meta) type definitions for LSP support

examples/                   # Example Lua scripts
scripts/                    # Test scripts (bash)
bin/
└── pbgl                    # CLI tool (Lua script)

makefile                    # Build system (for local development)
```

---

## Architecture & Layered Design

The codebase follows a strict **3-layer architecture**:

1. **C implementation layer** (`src/platform/`, `src/render/`, `src/audio/`) — Pure C functions with no Lua dependency. Each subsystem has a `.h` header and `.c` implementation.

2. **Lua binding layer** (`src/core/lua_*.c`) — Wraps the C API for Lua using the Lua C API. Each file registers functions into a subtable of the global `PudimBasicsGl` table.

3. **Entry point** (`src/main.c`) — `luaopen_PudimBasicsGl()` creates the `PudimBasicsGl` global table and calls each `lua_register_*_api()` function.

### Registration Flow

```
luaopen_PudimBasicsGl(L)
  → lua_newtable(L)                    // Create main table
  → lua_setglobal(L, "PudimBasicsGl")  // Store as global
  → lua_register_window_api(L)         // Creates PudimBasicsGl.window
  → lua_register_renderer_api(L)       // Creates PudimBasicsGl.renderer
  → lua_register_time_api(L)           // Creates PudimBasicsGl.time
  → lua_register_texture_api(L)        // Creates PudimBasicsGl.texture
  → lua_register_input_api(L)          // Creates PudimBasicsGl.input
  → lua_register_audio_api(L)          // Creates PudimBasicsGl.audio
  → lua_register_text_api(L)           // Creates PudimBasicsGl.text
  → return 1                           // Return the table
```

---

## Lua API Patterns

There are **two distinct patterns** for how modules expose their API:

### Pattern 1: Userdata + Metatable (for objects with lifecycle)

Used by: `window`, `texture`, `audio`

These modules create **Lua userdata** wrapping a C pointer, with a named metatable for methods and `__gc` for automatic cleanup.

Key elements:
- A `#define` for the metatable name: `"PudimBasicsGl.Window"`, `"PudimBasicsGl.Texture"`, `"PudimBasicsGl.Sound"`
- A `check_*()` helper to validate userdata: `luaL_checkudata(L, idx, METATABLE_NAME)`
- Constructor functions pushed into the module subtable (e.g., `pb.texture.load()`)
- Instance methods set as `__index` on the metatable (e.g., `texture:draw()`)
- `__gc` metamethod calls the destroy function
- Separate `luaL_Reg` arrays for **module functions** and **object methods**
- Nullable pointer pattern: on destroy, set `*ptr = NULL`; check for NULL in methods

**Texture/Audio example** (self-referencing metatable):
```c
luaL_newmetatable(L, METATABLE);
lua_pushvalue(L, -1);
lua_setfield(L, -2, "__index");   // metatable.__index = metatable
luaL_setfuncs(L, methods, 0);    // methods go directly on metatable
```

**Window example** (separate methods table):
```c
luaL_newmetatable(L, METATABLE);
luaL_setfuncs(L, meta_funcs, 0);  // __gc only
lua_newtable(L);
luaL_setfuncs(L, window_funcs, 0);
lua_setfield(L, -2, "__index");    // metatable.__index = methods_table
```

### Pattern 2: Plain Functions (for stateless modules)

Used by: `renderer`, `input`, `time`, `math`

These modules use **no userdata**. Functions are registered directly into a subtable. No metatables are needed.

```c
void lua_register_*_api(lua_State* L) {
    lua_getglobal(L, "PudimBasicsGl");
    // Guard: create table if nil (defensive pattern used in all modules)
    if (lua_isnil(L, -1)) {
        lua_pop(L, 1);
        lua_newtable(L);
        lua_setglobal(L, "PudimBasicsGl");
        lua_getglobal(L, "PudimBasicsGl");
    }
    lua_newtable(L);
    luaL_setfuncs(L, funcs, 0);
    // Optionally push constants (input keys, math PI, color tables)
    lua_setfield(L, -2, "modulename");
    lua_pop(L, 1);
}
```

### Constants Pattern

- **Input keys**: Pushed as integers into the `input` subtable (`pb.input.KEY_SPACE`, `pb.input.KEY_W`, etc.)
- **Colors**: Pushed as `{r, g, b, a}` tables into `pb.renderer.colors` (`pb.renderer.colors.RED`, etc.)
- **Math constants**: Pushed as numbers into `pb.math` (`pb.math.PI`, `pb.math.TAU`, etc.)

### Colon-call Compatibility

Some module functions accept an optional `self` (table) as the first argument to support both `pb.module.func()` and `pb.module:func()` calling conventions:
```c
int arg = 1;
if (lua_istable(L, 1)) arg = 2;  // skip self if called with ':'
```

### Error Return Convention

Resource-loading functions return `nil, error_string` on failure (not lua errors):
```c
if (!resource) {
    lua_pushnil(L);
    lua_pushstring(L, "Failed to load ...");
    return 2;
}
```

### Lazy Initialization

Some subsystems (texture renderer, audio engine) use lazy initialization to avoid requiring a valid OpenGL context at `require()` time:
```c
static int initialized = 0;
static void ensure_init(void) {
    if (!initialized) { do_init(); initialized = 1; }
}
```

---

## Naming Conventions

### C Code

| Element | Convention | Example |
|---------|-----------|---------|
| Functions (C API) | `module_action` | `window_create()`, `renderer_init()`, `audio_play()` |
| Functions (Lua binding) | `l_module_action` (static) | `l_window_create()`, `l_renderer_clear()` |
| Registration function | `lua_register_*_api` | `lua_register_window_api()` |
| Metatable name | `"PudimBasicsGl.Type"` | `"PudimBasicsGl.Window"`, `"PudimBasicsGl.Sound"` |
| Metatable define | `TYPE_METATABLE` | `WINDOW_METATABLE`, `TEXTURE_METATABLE` |
| Structs | `PascalCase` | `Window`, `Texture`, `Sound`, `Color` |
| Constants/macros | `UPPER_SNAKE_CASE` | `MAX_VERTICES`, `COLOR_RED` |
| Local variables | `snake_case` | `vertex_count`, `screen_width` |
| Global state | `g_` prefix | `g_active_window`, `g_engine` |
| luaL_Reg arrays | `module_funcs[]`, `module_methods[]` | `window_funcs[]`, `sound_methods[]` |
| Header guards | `MODULE_H` | `WINDOW_H`, `RENDERER_H`, `AUDIO_H` |

### Lua API

| Element | Convention | Example |
|---------|-----------|---------|
| Module name | `lowercase` | `pb.window`, `pb.renderer`, `pb.audio` |
| Functions | `snake_case` | `pb.window.create()`, `pb.renderer.rect_filled()` |
| Constants | `UPPER_SNAKE_CASE` | `pb.input.KEY_SPACE`, `pb.renderer.colors.RED` |
| Types (LSP) | `PudimBasicsGl.module` for modules, `PascalCase` for objects | `PudimBasicsGl.window`, `Window`, `Texture`, `Sound` |

### Files

| Layer | Convention | Example |
|-------|-----------|---------|
| C implementation | `module.c` / `module.h` | `window.c`, `audio.c`, `renderer.h` |
| Lua binding | `lua_module.c` | `lua_window.c`, `lua_audio.c` |
| Examples | `descriptive_name.lua` | `minimal.lua`, `texture_demo.lua` |

---

## Coding Style

- **C standard**: C17 (`-std=c17`)
- **Compiler flags**: `-Wall -Wextra -fPIC -O2 -g`
- **Indentation**: 4 spaces (C), 4 spaces (Lua)
- **Braces**: K&R style (opening brace on same line)
- **Comments**: `//` for single-line, `/* */` for file headers and multi-line
- **Function comments**: Standard format `// pudim.module.function(args) -> return`
- **Unused parameters**: `(void)L;` to suppress warnings
- **Include order**: Lua headers → system headers → project headers
- **Header guards**: `#ifndef MODULE_H` / `#define MODULE_H` / `#endif`

---

## Build System

### Building (local development)

```bash
make            # Build PudimBasicsGl.so (or .dll on Windows)
make clean      # Remove built artifacts
make install    # Install to /usr/local/lib/lua/5.x/ (Linux, requires sudo)
make test       # Build + run test suite
```

The `makefile` is used for **local development only**. For distribution, the project uses LuaRocks with `type = "builtin"` (see LuaRocks section below).

### Makefile Key Variables

- `SRC` — List of all `.c` source files (add new modules here)
- `INCLUDES` — Include paths (`-Iexternal/glad/include -Iexternal -Isrc`)
- `LDFLAGS` — Platform-specific linker flags (`-lglfw -lGL -lm -ldl -lpthread`)
- `LUA_VERSION` — Auto-detected (5.4 or 5.5), overridable
- `TARGET` — `PudimBasicsGl.so` (Linux) or `PudimBasicsGl.dll` (Windows)

### Cross-platform

The makefile detects OS and adjusts flags:
- **Linux**: `-shared`, links `-lglfw -lGL -lm -ldl -lpthread`
- **Windows (MinGW)**: `-shared`, links `-lglfw3 -lopengl32 -lgdi32 -lm`

---

## Testing

Tests are bash scripts in `scripts/` that run inline Lua code:

```bash
make test         # Runs scripts/test_preload.sh
```

### Test Structure (`scripts/test_preload.sh`)

The test script has **3 test sections** run sequentially:

1. **Preload test**: Verifies the `.so` loads and a window can be created without `LD_PRELOAD`
2. **Input tests**: Verifies `pb.input` subtable, functions, key constants, mouse functions
3. **Audio tests**: Verifies `pb.audio` subtable, functions, master volume, error handling

Each section uses a `check(name, condition)` helper pattern:
```lua
local pass = 0
local fail = 0
local function check(name, cond)
    if cond then pass = pass + 1; print("  OK: " .. name)
    else fail = fail + 1; print("  FAIL: " .. name) end
end
```

Tests run headless using **Xvfb** if no `DISPLAY` is available (CI-friendly).

When adding a new test section, follow this pattern:
1. Create a 1×1 window for the OpenGL context
2. Run checks with the `check()` helper
3. Print a summary line: `MODULE_RESULT: N passed, M failed`
4. Print `MODULE_OK` on success
5. Destroy the window
6. Wrap in a bash `$(lua -e '...' 2>&1 || true)` block
7. Check for the `MODULE_OK` marker

---

## Dependencies

### External Libraries (vendored in `external/`)

All third-party libraries are **single-header** libraries checked into `external/`:

| Library | Location | Purpose | Integration |
|---------|----------|---------|-------------|
| GLAD | `external/glad/` | OpenGL 3.3 Core loader | `glad.c` compiled as part of SRC |
| stb_image | `external/stb/stb_image.h` | Image loading (PNG, JPG, BMP, TGA) | `#define STB_IMAGE_IMPLEMENTATION` in `texture.c` |
| miniaudio | `external/miniaudio/miniaudio.h` | Audio engine (WAV, MP3, FLAC) | `#define MINIAUDIO_IMPLEMENTATION` in `audio.c` |

### System Dependencies

| Library | Header | Link Flag |
|---------|--------|-----------|
| GLFW 3 | `GLFW/glfw3.h` | `-lglfw` (Linux) / `-lglfw3` (Windows) |
| OpenGL | `GL/gl.h` | `-lGL` (Linux) / `-lopengl32` (Windows) |
| Lua 5.4+ | `lua.h`, `lauxlib.h`, `lualib.h` | Auto-detected via `pkg-config` |

### Adding a New Single-Header Library

1. Place the header in `external/libname/libname.h`
2. Add `#define LIBNAME_IMPLEMENTATION` in exactly **one** `.c` file
3. Add `-Iexternal` is already in `INCLUDES` (covers most cases)

---

## How to Add a New Module (Step by Step)

### Example: Adding a `physics` module

#### 1. Create the C API (`src/physics/`)

**`src/physics/physics.h`**:
```c
#ifndef PHYSICS_H
#define PHYSICS_H

typedef struct { float x, y, vx, vy; } Body;

Body* physics_create_body(float x, float y);
void  physics_destroy_body(Body* body);
void  physics_step(float dt);

#endif
```

**`src/physics/physics.c`**:
```c
#include "physics.h"
#include <stdlib.h>
// Implementation...
```

#### 2. Create the Lua binding (`src/core/lua_physics.c`)

```c
#include <lua.h>
#include <lauxlib.h>
#include "../physics/physics.h"

#define BODY_METATABLE "PudimBasicsGl.Body"

// If objects have lifecycle → use userdata + metatable pattern
// If stateless functions → use plain functions pattern

// check_body(), l_physics_create(), l_body_step(), l_body_gc(), etc.

static const luaL_Reg physics_module_funcs[] = { /* ... */ };
static const luaL_Reg body_methods[] = { /* ... */ };

void lua_register_physics_api(lua_State* L) {
    // Create Body metatable (if using userdata)
    luaL_newmetatable(L, BODY_METATABLE);
    lua_pushvalue(L, -1);
    lua_setfield(L, -2, "__index");
    luaL_setfuncs(L, body_methods, 0);
    lua_pushcfunction(L, l_body_gc);
    lua_setfield(L, -2, "__gc");
    lua_pop(L, 1);

    // Register into PudimBasicsGl.physics
    lua_getglobal(L, "PudimBasicsGl");
    if (lua_isnil(L, -1)) {
        lua_pop(L, 1);
        lua_newtable(L);
        lua_setglobal(L, "PudimBasicsGl");
        lua_getglobal(L, "PudimBasicsGl");
    }
    lua_newtable(L);
    luaL_setfuncs(L, physics_module_funcs, 0);
    lua_setfield(L, -2, "physics");
    lua_pop(L, 1);
}
```

#### 3. Register in `src/main.c`

Add the forward declaration and call:
```c
extern void lua_register_physics_api(lua_State* L);
// ...
lua_register_physics_api(L);  // inside luaopen_PudimBasicsGl()
```

#### 4. Add sources to `makefile` and rockspec

Add to the `SRC` variable in the makefile:
```makefile
SRC = ... \
      src/physics/physics.c \
      src/core/lua_physics.c
```

Add to the `sources` list in the rockspec (`build.modules.PudimBasicsGl.sources`):
```lua
sources = {
    -- ... existing sources ...
    "src/physics/physics.c",
    "src/core/lua_physics.c",
},
```

#### 5. Add LSP type definitions in `library/PudimBasicsGl.lua`

Add a new section following the existing pattern:
```lua
--------------------------------------------------------------------------------
-- Physics Module
--------------------------------------------------------------------------------

---@class Body
---Opaque body handle (userdata)
---@field step fun(self: Body, dt: number) Step physics
---@field destroy fun(self: Body) Destroy body

---@class PudimBasicsGl.physics
PudimBasicsGl.physics = {}

---Create a physics body
---@param x number Initial X position
---@param y number Initial Y position
---@return Body? body The created body, or nil on failure
function PudimBasicsGl.physics.create_body(x, y) end
```

Also add the field to the main `PudimBasicsGl` class:
```lua
---@class PudimBasicsGl
---@field physics PudimBasicsGl.physics Physics simulation module
```

#### 6. Add tests in `scripts/test_preload.sh`

Add a new bash section following the existing audio test pattern:
```bash
echo ""
echo "Running physics module tests..."
PHYSICS_OUTPUT=$(lua -e '
package.cpath = "./?.so;" .. package.cpath
local pb = require("PudimBasicsGl")
local w = pb.window.create(1, 1, "physics_test")
-- ... checks using check() helper ...
pb.window.destroy(w)
print(string.format("PHYSICS_RESULT: %d passed, %d failed", pass, fail))
if fail > 0 then os.exit(7) end
print("PHYSICS_OK")
' 2>&1 || true)
printf "%s\n" "$PHYSICS_OUTPUT"
if printf "%s\n" "$PHYSICS_OUTPUT" | grep -q "PHYSICS_OK"; then
    echo "Physics module tests passed"
else
    echo "Physics module tests failed!" >&2
    exit 7
fi
```

#### 7. (Optional) Add an example in `examples/`

Create `examples/physics_demo.lua` following the pattern from existing examples.

### Checklist Summary

- [ ] `src/module/module.h` — C API header
- [ ] `src/module/module.c` — C implementation
- [ ] `src/core/lua_module.c` — Lua binding
- [ ] `src/main.c` — Add `extern` and call `lua_register_*_api(L)`
- [ ] `makefile` — Add `.c` files to `SRC`
- [ ] Rockspec — Add `.c` files to `build.modules.PudimBasicsGl.sources`
- [ ] `library/PudimBasicsGl.lua` — Add `@class` and `@field` annotations
- [ ] `scripts/test_preload.sh` — Add test section
- [ ] `examples/module_demo.lua` — Example script (optional)

---

## LSP Type Definitions

The file `library/PudimBasicsGl.lua` uses LuaLS `@meta` annotations to provide IntelliSense. The file is **not runtime code** — it's purely for editor support.

Key conventions:
- `---@meta PudimBasicsGl` at the top
- `---@class PudimBasicsGl` for the root table
- `---@class PudimBasicsGl.modulename` for each subtable
- `---@class TypeName` for userdata types (`Window`, `Texture`, `Sound`)
- `---@field method fun(self: Type, ...) Description` for object methods
- `---@param`, `---@return`, `---@overload` for function signatures
- Optional parameters use `?` suffix: `a?` or `number?`

---

## LuaRocks Distribution

The project publishes to LuaRocks via `.rockspec` files. The rockspec uses `type = "builtin"` — LuaRocks compiles all `.c` sources directly into `.so` (Linux) or `.dll` (Windows), without requiring the makefile.

The `builtin` build type lists all source files, include directories, and libraries in the rockspec itself:

```lua
build = {
    type = "builtin",
    modules = {
        PudimBasicsGl = {
            sources = { "src/main.c", "src/platform/window.c", ... },
            incdirs = { "external/glad/include", "external", "src", "$(GLFW_INCDIR)" },
            libraries = { "glfw", "GL", "m", "dl", "pthread" },
        }
    },
}
```

Platform-specific overrides (e.g., Windows libraries) use the `platforms` sub-table inside `build` and `external_dependencies` for deep merge (requires `rockspec_format = "3.0"`).

The rockspec also installs:
- The CLI tool `bin/pbgl`
- Directories: `examples/`, `library/`, `scripts/`

Version format: `1.0.0-N` (semver with revision number).

---

## Common Gotchas

1. **OpenGL context required**: `renderer_init()`, texture loading, and similar functions require a window to be created first (GLFW provides the OpenGL context).

2. **Flush before switching render modes**: Call `pb.renderer.flush()` before drawing textures, and `pb.texture.flush()` before drawing primitives, since they use different shaders/batches.

3. **`package.cpath`**: When running from the project directory, scripts must set `package.cpath = "./?.so;" .. package.cpath` before `require()`.

4. **Active window singleton**: `lua_window.c` stores a global `g_active_window` pointer used by the input module. Only the most recently created window receives input queries.

5. **GLFW preloading on Linux**: `window.c` uses `dlopen()` with `RTLD_GLOBAL` to preload `libglfw.so` so that GLAD can resolve symbols without the user needing `LD_PRELOAD`.
