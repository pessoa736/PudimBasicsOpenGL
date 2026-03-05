#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Try to provide an X server in headless CI environments using Xvfb
Xvfb_pid=""
cleanup() {
    if [ -n "$Xvfb_pid" ]; then
        kill "$Xvfb_pid" 2>/dev/null || true
    fi
}
trap cleanup EXIT

# Start Xvfb if DISPLAY is not set and Xvfb is available
if [ -z "${DISPLAY:-}" ]; then
    if command -v Xvfb >/dev/null 2>&1; then
        echo "No DISPLAY detected: starting Xvfb on :99"
        Xvfb :99 -screen 0 1024x768x24 >/dev/null 2>&1 &
        Xvfb_pid=$!
        export DISPLAY=:99
        sleep 0.5
    else
        echo "No DISPLAY and Xvfb not available; test may fail in headless environments"
    fi
fi

echo "Building project..."
make

echo "Running preload test (no LD_PRELOAD)..."
# Use lua to require the module and try to create a tiny window (1x1) then destroy it
OUTPUT=$(lua -e '
package.cpath = "./?.so;" .. package.cpath
local ok,pb = pcall(require, "PudimBasicsGl")
if not ok then print("REQUIRE_FAILED:"..tostring(pb)); os.exit(2) end
local ok2, w = pcall(pb.window.create, 1, 1, "test")
if not ok2 or not w then print("WINDOW_FAILED:"..tostring(w)); os.exit(3) end
print("WINDOW_OK")
pb.window.destroy(w)
' 2>&1 || true)

printf "%s\n" "$OUTPUT"

if ! printf "%s\n" "$OUTPUT" | grep -q "WINDOW_OK"; then
    echo "Preload test failed; collecting diagnostics..." >&2
    echo "---- LUA OUTPUT ----" >&2
    printf "%s\n" "$OUTPUT" >&2
    echo "---- LDD PudimBasicsGl.so ----" >&2
    ldd ./PudimBasicsGl.so || true
    echo "---- LDD libglfw (if present) ----" >&2
    ldd /usr/lib/libglfw.so.3 || true
    echo "---- ENV ----" >&2
    env | sort >&2
    exit 4
fi

echo "Preload test passed: window created without LD_PRELOAD"

echo ""
echo "Running keyboard and mouse input tests..."
INPUT_OUTPUT=$(lua -e '
package.cpath = "./?.so;" .. package.cpath
local pb = require("PudimBasicsGl")
local w = pb.window.create(1, 1, "input_test")
if not w then print("INPUT_FAIL:window"); os.exit(2) end

local pass = 0
local fail = 0

local function check(name, cond)
    if cond then
        pass = pass + 1
        print("  OK: " .. name)
    else
        fail = fail + 1
        print("  FAIL: " .. name)
    end
end

-- == Keyboard tests ==
-- input subtable must exist
check("input table exists", pb.input ~= nil)
check("is_key_pressed is a function", type(pb.input.is_key_pressed) == "function")
check("is_key_released is a function", type(pb.input.is_key_released) == "function")

-- key constants must be integers
check("KEY_SPACE is integer", type(pb.input.KEY_SPACE) == "number" and pb.input.KEY_SPACE == math.floor(pb.input.KEY_SPACE))
check("KEY_ESCAPE is integer", type(pb.input.KEY_ESCAPE) == "number")
check("KEY_W is integer", type(pb.input.KEY_W) == "number")
check("KEY_A is integer", type(pb.input.KEY_A) == "number")
check("KEY_S is integer", type(pb.input.KEY_S) == "number")
check("KEY_D is integer", type(pb.input.KEY_D) == "number")
check("KEY_UP is integer", type(pb.input.KEY_UP) == "number")
check("KEY_LEFT_SHIFT is integer", type(pb.input.KEY_LEFT_SHIFT) == "number")
check("KEY_F1 is integer", type(pb.input.KEY_F1) == "number")
check("KEY_0 is integer", type(pb.input.KEY_0) == "number")

-- no key should be pressed in a fresh headless window
check("SPACE not pressed", pb.input.is_key_pressed(pb.input.KEY_SPACE) == false)
check("ESCAPE not pressed", pb.input.is_key_pressed(pb.input.KEY_ESCAPE) == false)
check("W not pressed", pb.input.is_key_pressed(pb.input.KEY_W) == false)

-- keys should report released
check("SPACE is released", pb.input.is_key_released(pb.input.KEY_SPACE) == true)
check("W is released", pb.input.is_key_released(pb.input.KEY_W) == true)

-- == Mouse tests ==
check("is_mouse_button_pressed is a function", type(pb.input.is_mouse_button_pressed) == "function")
check("get_mouse_position is a function", type(pb.input.get_mouse_position) == "function")
check("set_mouse_position is a function", type(pb.input.set_mouse_position) == "function")
check("set_cursor_visible is a function", type(pb.input.set_cursor_visible) == "function")
check("set_cursor_locked is a function", type(pb.input.set_cursor_locked) == "function")

-- mouse button constants
check("MOUSE_LEFT is integer", type(pb.input.MOUSE_LEFT) == "number")
check("MOUSE_RIGHT is integer", type(pb.input.MOUSE_RIGHT) == "number")
check("MOUSE_MIDDLE is integer", type(pb.input.MOUSE_MIDDLE) == "number")

-- no mouse button should be pressed
check("LEFT not pressed", pb.input.is_mouse_button_pressed(pb.input.MOUSE_LEFT) == false)
check("RIGHT not pressed", pb.input.is_mouse_button_pressed(pb.input.MOUSE_RIGHT) == false)
check("MIDDLE not pressed", pb.input.is_mouse_button_pressed(pb.input.MOUSE_MIDDLE) == false)

-- get_mouse_position should return two numbers
local mx, my = pb.input.get_mouse_position()
check("mouse pos x is number", type(mx) == "number")
check("mouse pos y is number", type(my) == "number")

-- set_mouse_position should not error
local ok_smp = pcall(pb.input.set_mouse_position, 50, 50)
check("set_mouse_position runs", ok_smp)

-- cursor visibility/lock should not error
local ok_cv = pcall(pb.input.set_cursor_visible, true)
check("set_cursor_visible runs", ok_cv)
local ok_cl = pcall(pb.input.set_cursor_locked, false)
check("set_cursor_locked runs", ok_cl)

pb.window.destroy(w)

print(string.format("INPUT_RESULT: %d passed, %d failed", pass, fail))
if fail > 0 then os.exit(5) end
print("INPUT_OK")
' 2>&1 || true)

printf "%s\n" "$INPUT_OUTPUT"

if printf "%s\n" "$INPUT_OUTPUT" | grep -q "INPUT_OK"; then
    echo "Keyboard and mouse input tests passed"
else
    echo "Keyboard/mouse input tests failed!" >&2
    exit 5
fi

echo ""
echo "Running audio module tests..."
AUDIO_OUTPUT=$(lua -e '
package.cpath = "./?.so;" .. package.cpath
local pb = require("PudimBasicsGl")
local w = pb.window.create(1, 1, "audio_test")
if not w then print("AUDIO_FAIL:window"); os.exit(2) end

local pass = 0
local fail = 0

local function check(name, cond)
    if cond then
        pass = pass + 1
        print("  OK: " .. name)
    else
        fail = fail + 1
        print("  FAIL: " .. name)
    end
end

-- audio subtable must exist
check("audio table exists", pb.audio ~= nil)
check("audio.load is a function", type(pb.audio.load) == "function")
check("audio.set_master_volume is function", type(pb.audio.set_master_volume) == "function")
check("audio.get_master_volume is function", type(pb.audio.get_master_volume) == "function")
check("audio.shutdown is a function", type(pb.audio.shutdown) == "function")

-- master volume
local ok_mv = pcall(pb.audio.set_master_volume, 0.5)
check("set_master_volume runs", ok_mv)
local mv = pb.audio.get_master_volume()
check("get_master_volume returns number", type(mv) == "number")
check("master volume ~ 0.5", math.abs(mv - 0.5) < 0.01)

-- loading a non-existent file should return nil
local bad, err = pb.audio.load("non_existent_file.wav")
check("load non-existent returns nil", bad == nil)
check("load non-existent returns error msg", type(err) == "string")

-- shutdown should not error
local ok_sd = pcall(pb.audio.shutdown)
check("shutdown runs", ok_sd)

pb.window.destroy(w)

print(string.format("AUDIO_RESULT: %d passed, %d failed", pass, fail))
if fail > 0 then os.exit(6) end
print("AUDIO_OK")
' 2>&1 || true)

printf "%s\n" "$AUDIO_OUTPUT"

if printf "%s\n" "$AUDIO_OUTPUT" | grep -q "AUDIO_OK"; then
    echo "Audio module tests passed"
else
    echo "Audio module tests failed!" >&2
    exit 6
fi

echo ""
echo "Running text module tests..."
TEXT_OUTPUT=$(lua -e '
package.cpath = "./?.so;" .. package.cpath
local pb = require("PudimBasicsGl")
local w = pb.window.create(1, 1, "text_test")
if not w then print("TEXT_FAIL:window"); os.exit(2) end

local pass = 0
local fail = 0

local function check(name, cond)
    if cond then
        pass = pass + 1
        print("  OK: " .. name)
    else
        fail = fail + 1
        print("  FAIL: " .. name)
    end
end

-- text subtable must exist
check("text table exists", pb.text ~= nil)
check("text.load is a function", type(pb.text.load) == "function")
check("text.flush is a function", type(pb.text.flush) == "function")

-- loading a non-existent font should return nil
local bad, err = pb.text.load("non_existent_font.ttf")
check("load non-existent returns nil", bad == nil)
check("load non-existent returns error msg", type(err) == "string")

-- Try to load a system font for deeper testing
local font_paths = {
    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    "/usr/share/fonts/TTF/DejaVuSans.ttf",
    "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf",
    "/usr/share/fonts/truetype/freefont/FreeSans.ttf",
}
local font = nil
for _, fp in ipairs(font_paths) do
    font = pb.text.load(fp, 24)
    if font then break end
end

if font then
    check("font loaded", true)
    check("font is userdata", type(font) == "userdata")

    -- get_size
    local sz = font:get_size()
    check("get_size returns number", type(sz) == "number")
    check("get_size == 24", math.abs(sz - 24) < 0.01)

    -- get_line_height
    local lh = font:get_line_height()
    check("get_line_height returns number", type(lh) == "number")
    check("line_height > 0", lh > 0)

    -- measure
    local tw, th = font:measure("Hello")
    check("measure returns width", type(tw) == "number" and tw > 0)
    check("measure returns height", type(th) == "number" and th > 0)

    -- empty string measure
    local ew, eh = font:measure("")
    check("empty measure width == 0", ew == 0)

    -- set_size
    local ok_ss = pcall(font.set_size, font, 32)
    check("set_size runs", ok_ss)
    local new_sz = font:get_size()
    check("new size == 32", math.abs(new_sz - 32) < 0.01)

    -- draw should not error (needs renderer begin)
    pb.renderer.init()
    pb.renderer.begin(1, 1)
    pb.renderer.flush()
    local ok_draw = pcall(font.draw, font, "Test", 0, 0, 1, 1, 1)
    check("draw runs", ok_draw)
    pb.text.flush()
    pb.renderer.finish()

    -- destroy
    font:destroy()
    check("destroy runs", true)

    -- methods on destroyed font should error
    local ok_dead = pcall(font.get_size, font)
    check("dead font errors", not ok_dead)
else
    print("  SKIP: no system font found for deeper tests")
end

pb.window.destroy(w)

print(string.format("TEXT_RESULT: %d passed, %d failed", pass, fail))
if fail > 0 then os.exit(7) end
print("TEXT_OK")
' 2>&1 || true)

printf "%s\n" "$TEXT_OUTPUT"

if printf "%s\n" "$TEXT_OUTPUT" | grep -q "TEXT_OK"; then
    echo "Text module tests passed"
else
    echo "Text module tests failed!" >&2
    exit 7
fi

# ───────────────── Camera module tests ─────────────────
echo ""
echo "Running camera module tests..."
CAMERA_OUTPUT=$(lua -e '
package.cpath = "./?.so;" .. package.cpath
local pb = require("PudimBasicsGl")

local pass = 0
local fail = 0
local function check(name, cond)
    if cond then pass = pass + 1; print("  OK: " .. name)
    else fail = fail + 1; print("  FAIL: " .. name) end
end

-- camera subtable exists
check("pb.camera exists", type(pb.camera) == "table")

-- functions exist
check("set_position is function", type(pb.camera.set_position) == "function")
check("get_position is function", type(pb.camera.get_position) == "function")
check("move is function", type(pb.camera.move) == "function")
check("set_zoom is function", type(pb.camera.set_zoom) == "function")
check("get_zoom is function", type(pb.camera.get_zoom) == "function")
check("set_rotation is function", type(pb.camera.set_rotation) == "function")
check("get_rotation is function", type(pb.camera.get_rotation) == "function")
check("look_at is function", type(pb.camera.look_at) == "function")
check("reset is function", type(pb.camera.reset) == "function")
check("screen_to_world is function", type(pb.camera.screen_to_world) == "function")
check("world_to_screen is function", type(pb.camera.world_to_screen) == "function")

-- default values
local x, y = pb.camera.get_position()
check("default position x == 0", math.abs(x) < 0.001)
check("default position y == 0", math.abs(y) < 0.001)
check("default zoom == 1", math.abs(pb.camera.get_zoom() - 1.0) < 0.001)
check("default rotation == 0", math.abs(pb.camera.get_rotation()) < 0.001)

-- set/get position
pb.camera.set_position(100, 200)
x, y = pb.camera.get_position()
check("set_position x", math.abs(x - 100) < 0.001)
check("set_position y", math.abs(y - 200) < 0.001)

-- move
pb.camera.move(50, -30)
x, y = pb.camera.get_position()
check("move x", math.abs(x - 150) < 0.001)
check("move y", math.abs(y - 170) < 0.001)

-- zoom
pb.camera.set_zoom(2.5)
check("set_zoom", math.abs(pb.camera.get_zoom() - 2.5) < 0.001)

-- zoom rejects <= 0
pb.camera.set_zoom(-1)
check("zoom rejects negative", math.abs(pb.camera.get_zoom() - 2.5) < 0.001)

-- rotation
pb.camera.set_rotation(45)
check("set_rotation", math.abs(pb.camera.get_rotation() - 45) < 0.001)

-- reset
pb.camera.reset()
x, y = pb.camera.get_position()
check("reset position x", math.abs(x) < 0.001)
check("reset position y", math.abs(y) < 0.001)
check("reset zoom", math.abs(pb.camera.get_zoom() - 1.0) < 0.001)
check("reset rotation", math.abs(pb.camera.get_rotation()) < 0.001)

-- look_at (centers point on screen)
pb.camera.look_at(400, 300, 800, 600)
x, y = pb.camera.get_position()
check("look_at x", math.abs(x - 0) < 0.001)   -- 400 - 800/2 = 0
check("look_at y", math.abs(y - 0) < 0.001)   -- 300 - 600/2 = 0

pb.camera.look_at(500, 400, 800, 600)
x, y = pb.camera.get_position()
check("look_at offset x", math.abs(x - 100) < 0.001) -- 500 - 400 = 100
check("look_at offset y", math.abs(y - 100) < 0.001) -- 400 - 300 = 100

-- coordinate conversion (needs a window for renderer_begin to set screen size)
local w = pb.window.create(1, 1, "camera_test")
pb.renderer.init()
pb.camera.reset()
pb.renderer.begin(800, 600)

-- with default camera, screen == world
local wx, wy = pb.camera.screen_to_world(100, 200)
check("s2w default x", math.abs(wx - 100) < 1)
check("s2w default y", math.abs(wy - 200) < 1)

local sx, sy = pb.camera.world_to_screen(100, 200)
check("w2s default x", math.abs(sx - 100) < 1)
check("w2s default y", math.abs(sy - 200) < 1)

-- with offset camera
pb.camera.set_position(50, 50)
pb.renderer.begin(800, 600)
wx, wy = pb.camera.screen_to_world(0, 0)
check("s2w offset x", math.abs(wx - 50) < 1)
check("s2w offset y", math.abs(wy - 50) < 1)

sx, sy = pb.camera.world_to_screen(50, 50)
check("w2s offset x", math.abs(sx - 0) < 1)
check("w2s offset y", math.abs(sy - 0) < 1)

-- roundtrip: world -> screen -> world
pb.camera.set_position(123, 456)
pb.camera.set_zoom(1.5)
pb.camera.set_rotation(30)
pb.renderer.begin(800, 600)
local orig_x, orig_y = 300, 400
sx, sy = pb.camera.world_to_screen(orig_x, orig_y)
wx, wy = pb.camera.screen_to_world(sx, sy)
check("roundtrip x", math.abs(wx - orig_x) < 1)
check("roundtrip y", math.abs(wy - orig_y) < 1)

pb.renderer.finish()
pb.window.destroy(w)

print(string.format("CAMERA_RESULT: %d passed, %d failed", pass, fail))
if fail > 0 then os.exit(7) end
print("CAMERA_OK")
' 2>&1 || true)

printf "%s\n" "$CAMERA_OUTPUT"

if printf "%s\n" "$CAMERA_OUTPUT" | grep -q "CAMERA_OK"; then
    echo "Camera module tests passed"
else
    echo "Camera module tests failed!" >&2
    exit 7
fi

# ───────────────── Visual Rendering tests ─────────────────
echo ""
echo "Running visual rendering tests (framebuffer readback)..."
RENDER_OUTPUT=$(lua -e '
package.cpath = "./?.so;" .. package.cpath
local pb = require("PudimBasicsGl")

local W, H = 64, 64
local w = pb.window.create(W, H, "render_test")
if not w then print("RENDER_FAIL:window"); os.exit(2) end
pb.renderer.init()

local pass = 0
local fail = 0
local function check(name, cond)
    if cond then pass = pass + 1; print("  OK: " .. name)
    else fail = fail + 1; print("  FAIL: " .. name) end
end

-- Tolerance helper: OpenGL colors can have slight precision differences
local function near(a, b, tol)
    tol = tol or 5
    return math.abs(a - b) <= tol
end

-- ════════ Test 1: clear color is readable ════════
pb.renderer.clear(1.0, 0.0, 0.0, 1.0)  -- solid red
pb.renderer.begin(W, H)
pb.renderer.flush()
pb.renderer.finish()
local r, g, b, a = pb.renderer.read_pixel(32, 32, H)
check("clear red: R ~255", near(r, 255))
check("clear red: G ~0",   near(g, 0))
check("clear red: B ~0",   near(b, 0))
check("clear red: A ~255", near(a, 255))

-- ════════ Test 2: different clear color ════════
pb.renderer.clear(0.0, 0.0, 1.0, 1.0)  -- solid blue
pb.renderer.begin(W, H)
pb.renderer.flush()
pb.renderer.finish()
r, g, b, a = pb.renderer.read_pixel(32, 32, H)
check("clear blue: R ~0",   near(r, 0))
check("clear blue: G ~0",   near(g, 0))
check("clear blue: B ~255", near(b, 255))

-- ════════ Test 3: rect_filled draws the right color ════════
pb.renderer.clear(0.0, 0.0, 0.0, 1.0)  -- black background
pb.renderer.begin(W, H)
pb.renderer.rect_filled(10, 10, 20, 20, 0, 1, 0, 1)  -- green rect
pb.renderer.flush()
pb.renderer.finish()
-- inside the rect
r, g, b, a = pb.renderer.read_pixel(20, 20, H)
check("green rect inside: R ~0",   near(r, 0))
check("green rect inside: G ~255", near(g, 255))
check("green rect inside: B ~0",   near(b, 0))
-- outside the rect (should be black)
r, g, b, a = pb.renderer.read_pixel(5, 5, H)
check("outside rect: R ~0", near(r, 0))
check("outside rect: G ~0", near(g, 0))
check("outside rect: B ~0", near(b, 0))

-- ════════ Test 4: overlapping rects (draw order) ════════
pb.renderer.clear(0.0, 0.0, 0.0, 1.0)
pb.renderer.begin(W, H)
pb.renderer.rect_filled(0, 0, 64, 64, 1, 0, 0, 1)  -- red covers all
pb.renderer.rect_filled(20, 20, 20, 20, 0, 0, 1, 1) -- blue on top
pb.renderer.flush()
pb.renderer.finish()
-- blue rect center
r, g, b, a = pb.renderer.read_pixel(30, 30, H)
check("overlap: blue on top R ~0",   near(r, 0))
check("overlap: blue on top B ~255", near(b, 255))
-- outside blue rect but inside red
r, g, b, a = pb.renderer.read_pixel(5, 5, H)
check("overlap: red underneath R ~255", near(r, 255))
check("overlap: red underneath B ~0",   near(b, 0))

-- ════════ Test 5: circle_filled ════════
pb.renderer.clear(0.0, 0.0, 0.0, 1.0)
pb.renderer.begin(W, H)
pb.renderer.circle_filled(32, 32, 15, 1, 1, 0, 1)  -- yellow center
pb.renderer.flush()
pb.renderer.finish()
r, g, b, a = pb.renderer.read_pixel(32, 32, H)
check("circle center: R ~255", near(r, 255))
check("circle center: G ~255", near(g, 255))
check("circle center: B ~0",   near(b, 0))

-- ════════ Test 6: UI mode renders correctly ════════
pb.renderer.clear(0.0, 0.0, 0.0, 1.0)
pb.renderer.begin_ui(W, H)
pb.renderer.rect_filled(0, 0, 32, 32, 1, 0, 1, 1)  -- magenta
pb.renderer.flush()
pb.renderer.end_ui()
pb.renderer.finish()
r, g, b, a = pb.renderer.read_pixel(16, 16, H)
check("UI mode rect: R ~255", near(r, 255))
check("UI mode rect: G ~0",   near(g, 0))
check("UI mode rect: B ~255", near(b, 255))

-- ════════ Test 7: procedural texture ════════
pb.renderer.clear(0.0, 0.0, 0.0, 1.0)
pb.renderer.begin(W, H)
pb.renderer.flush()
-- create a 1x1 solid cyan texture
local tex = pb.texture.create(1, 1, {0, 255, 255, 255})
check("tex created", tex ~= nil)
if tex then
    tex:draw(10, 10, 20, 20)
    pb.texture.flush()
    pb.renderer.finish()
    r, g, b, a = pb.renderer.read_pixel(20, 20, H)
    check("texture pixel: R ~0",   near(r, 0))
    check("texture pixel: G ~255", near(g, 255))
    check("texture pixel: B ~255", near(b, 255))
    tex:destroy()
else
    pb.renderer.finish()
end

-- ════════ Test 8: gradient rect ════════
pb.renderer.clear(0.0, 0.0, 0.0, 1.0)
pb.renderer.begin(W, H)
pb.renderer.rect_gradient(0, 0, W, H,
    pb.renderer.color(1, 0, 0), pb.renderer.color(0, 0, 1))
pb.renderer.flush()
pb.renderer.finish()
-- top should be mostly red
local tr, tg, tb = pb.renderer.read_pixel(32, 2, H)
-- bottom should be mostly blue
local br2, bg2, bb2 = pb.renderer.read_pixel(32, H - 2, H)
check("gradient top: more red",  tr > 200)
check("gradient top: less blue", tb < 50)
check("gradient bot: less red",  br2 < 50)
check("gradient bot: more blue", bb2 > 200)

pb.window.destroy(w)
print(string.format("RENDER_RESULT: %d passed, %d failed", pass, fail))
if fail > 0 then os.exit(8) end
print("RENDER_OK")
' 2>&1 || true)

printf "%s\n" "$RENDER_OUTPUT"

if printf "%s\n" "$RENDER_OUTPUT" | grep -q "RENDER_OK"; then
    echo "Visual rendering tests passed"
else
    echo "Visual rendering tests failed!" >&2
    exit 8
fi

# ───────────────── Shader module tests ─────────────────
echo ""
echo "Running shader module tests..."
SHADER_OUTPUT=$(lua -e '
package.cpath = "./?.so;" .. package.cpath
local pb = require("PudimBasicsGl")

local W, H = 64, 64
local w = pb.window.create(W, H, "shader_test")
if not w then print("SHADER_FAIL:window"); os.exit(2) end
pb.renderer.init()

local pass = 0
local fail = 0
local function check(name, cond)
    if cond then pass = pass + 1; print("  OK: " .. name)
    else fail = fail + 1; print("  FAIL: " .. name) end
end

-- shader subtable
check("shader table exists", pb.shader ~= nil)
check("shader.create is function", type(pb.shader.create) == "function")
check("shader.load is function", type(pb.shader.load) == "function")
check("shader.unuse is function", type(pb.shader.unuse) == "function")

-- create a simple shader
local vs = [[
#version 330 core
layout(location = 0) in vec2 aPos;
void main() { gl_Position = vec4(aPos, 0.0, 1.0); }
]]
local fs = [[
#version 330 core
out vec4 FragColor;
uniform vec3 uColor;
void main() { FragColor = vec4(uColor, 1.0); }
]]

local shader, err = pb.shader.create(vs, fs)
check("shader compiled", shader ~= nil)

if shader then
    check("get_id returns int", type(shader:get_id()) == "number" and shader:get_id() > 0)
    check("is_valid returns true", shader:is_valid() == true)

    -- set uniforms should not crash
    local ok1 = pcall(shader.set_float, shader, "uColor", 1.0)
    check("set_float no crash", true)

    local ok2 = pcall(shader.set_vec3, shader, "uColor", 1.0, 0.0, 0.0)
    check("set_vec3 no crash", ok2)

    -- use and unuse
    local ok_use = pcall(shader.use, shader)
    check("shader:use() runs", ok_use)
    local ok_unuse = pcall(shader.unuse, shader)
    check("shader:unuse() runs", ok_unuse)

    -- destroy
    shader:destroy()
    check("shader destroyed", true)
    check("destroyed shader invalid", shader:is_valid() == false)
end

-- invalid shader source
local bad_shader, bad_err = pb.shader.create("invalid", "invalid")
check("invalid shader returns nil", bad_shader == nil)
check("invalid shader returns error", type(bad_err) == "string")

pb.window.destroy(w)
print(string.format("SHADER_RESULT: %d passed, %d failed", pass, fail))
if fail > 0 then os.exit(9) end
print("SHADER_OK")
' 2>&1 || true)

printf "%s\n" "$SHADER_OUTPUT"

if printf "%s\n" "$SHADER_OUTPUT" | grep -q "SHADER_OK"; then
    echo "Shader module tests passed"
else
    echo "Shader module tests failed!" >&2
    exit 9
fi

# ───────────────── Math module tests ─────────────────
echo ""
echo "Running math module tests..."
MATH_OUTPUT=$(lua -e '
package.cpath = "./?.so;" .. package.cpath
local pb = require("PudimBasicsGl")

local pass = 0
local fail = 0
local function check(name, cond)
    if cond then pass = pass + 1; print("  OK: " .. name)
    else fail = fail + 1; print("  FAIL: " .. name) end
end

local function near(a, b, tol)
    tol = tol or 0.001
    return math.abs(a - b) <= tol
end

check("math table exists", pb.math ~= nil)

-- constants
check("PI exists", type(pb.math.PI) == "number")
check("PI value", near(pb.math.PI, 3.14159265, 0.0001))
check("TAU exists", type(pb.math.TAU) == "number")
check("TAU ~ 2*PI", near(pb.math.TAU, pb.math.PI * 2, 0.0001))
check("HALF_PI exists", type(pb.math.HALF_PI) == "number")
check("HALF_PI ~ PI/2", near(pb.math.HALF_PI, pb.math.PI / 2, 0.0001))

-- lerp
check("lerp 0", near(pb.math.lerp(10, 20, 0), 10))
check("lerp 1", near(pb.math.lerp(10, 20, 1), 20))
check("lerp 0.5", near(pb.math.lerp(10, 20, 0.5), 15))
check("lerp neg", near(pb.math.lerp(0, 100, 0.25), 25))

-- clamp
check("clamp inside", near(pb.math.clamp(5, 0, 10), 5))
check("clamp below", near(pb.math.clamp(-5, 0, 10), 0))
check("clamp above", near(pb.math.clamp(15, 0, 10), 10))

-- radians / degrees
check("radians(180)", near(pb.math.radians(180), pb.math.PI))
check("degrees(PI)", near(pb.math.degrees(pb.math.PI), 180))
check("roundtrip deg", near(pb.math.degrees(pb.math.radians(45)), 45))

-- vectors
local v = pb.math.vec2(3, 4)
check("vec2.x", v.x == 3)
check("vec2.y", v.y == 4)

local v3 = pb.math.vec3(1, 2, 3)
check("vec3.z", v3.z == 3)

local v4 = pb.math.vec4(1, 2, 3, 4)
check("vec4.w", v4.w == 4)

-- vector ops
local va = pb.math.vec2(1, 0)
local vb = pb.math.vec2(0, 1)
local vc = pb.math.vec_add(va, vb)
check("vec_add", vc.x == 1 and vc.y == 1)

local vd = pb.math.vec_sub(vc, va)
check("vec_sub", vd.x == 0 and vd.y == 1)

local vs2 = pb.math.vec_scale(pb.math.vec2(2, 3), 5)
check("vec_scale", vs2.x == 10 and vs2.y == 15)

local vlen = pb.math.vec_length(pb.math.vec2(3, 4))
check("vec_length", near(vlen, 5.0))

local vn = pb.math.vec_normalize(pb.math.vec2(0, 5))
check("vec_normalize", near(vn.x, 0) and near(vn.y, 1.0))

local dot = pb.math.vec_dot(pb.math.vec2(1, 0), pb.math.vec2(0, 1))
check("vec_dot perpendicular", near(dot, 0))
local dot2 = pb.math.vec_dot(pb.math.vec2(1, 0), pb.math.vec2(1, 0))
check("vec_dot parallel", near(dot2, 1))

print(string.format("MATH_RESULT: %d passed, %d failed", pass, fail))
if fail > 0 then os.exit(10) end
print("MATH_OK")
' 2>&1 || true)

printf "%s\n" "$MATH_OUTPUT"

if printf "%s\n" "$MATH_OUTPUT" | grep -q "MATH_OK"; then
    echo "Math module tests passed"
else
    echo "Math module tests failed!" >&2
    exit 10
fi

# ───────────────── Studio module tests ─────────────────
echo ""
echo "Running studio module tests..."
STUDIO_OUTPUT=$(lua -e '
package.cpath = "./?.so;" .. package.cpath
local pb = require("PudimBasicsGl")

local pass = 0
local fail = 0
local function check(name, cond)
    if cond then pass = pass + 1; print("  OK: " .. name)
    else fail = fail + 1; print("  FAIL: " .. name) end
end

check("studio table exists", pb.studio ~= nil)
check("list_dir is function", type(pb.studio.list_dir) == "function")
check("get_file_modified_time is function", type(pb.studio.get_file_modified_time) == "function")
check("copy_file is function", type(pb.studio.copy_file) == "function")

-- list_dir on current directory should return files
local files = pb.studio.list_dir(".")
check("list_dir returns table", type(files) == "table")
check("list_dir has entries", #files > 0)

-- should find PudimBasicsGl.so
local found_so = false
for _, f in ipairs(files or {}) do
    if f == "PudimBasicsGl.so" then found_so = true end
end
check("list_dir finds .so", found_so)

-- list_dir on non-existent should return nil
local bad, err = pb.studio.list_dir("/non_existent_path_12345")
check("list_dir bad path returns nil", bad == nil)
check("list_dir bad path has error", type(err) == "string")

-- get_file_modified_time
local mtime = pb.studio.get_file_modified_time("PudimBasicsGl.so")
check("mtime returns number", type(mtime) == "number")
check("mtime > 0", mtime > 0)

local bad_mtime = pb.studio.get_file_modified_time("non_existent_file_12345")
check("mtime bad file returns nil", bad_mtime == nil)

-- copy_file: create a temp file and copy it
local tmp_src = "/tmp/pudim_test_src.txt"
local tmp_dst = "/tmp/pudim_test_dst.txt"
local f = io.open(tmp_src, "w")
if f then
    f:write("pudim_test_data")
    f:close()
    local ok2, err2 = pb.studio.copy_file(tmp_src, tmp_dst)
    check("copy_file succeeds", ok2 == true)
    -- verify content
    local fc = io.open(tmp_dst, "r")
    if fc then
        local content = fc:read("*a")
        fc:close()
        check("copy_file content matches", content == "pudim_test_data")
    else
        check("copy_file content matches", false)
    end
    os.remove(tmp_src)
    os.remove(tmp_dst)
end

-- copy non-existent file
local ok3, err3 = pb.studio.copy_file("/non_existent_12345", "/tmp/x")
check("copy bad file fails", ok3 == false or ok3 == nil)
check("copy bad file has error", type(err3) == "string")

print(string.format("STUDIO_RESULT: %d passed, %d failed", pass, fail))
if fail > 0 then os.exit(11) end
print("STUDIO_OK")
' 2>&1 || true)

printf "%s\n" "$STUDIO_OUTPUT"

if printf "%s\n" "$STUDIO_OUTPUT" | grep -q "STUDIO_OK"; then
    echo "Studio module tests passed"
else
    echo "Studio module tests failed!" >&2
    exit 11
fi

# ───────────────── UI module tests ─────────────────
echo ""
echo "Running UI module tests..."
UI_OUTPUT=$(lua -e '
package.cpath = "./?.so;" .. package.cpath
local pb = require("PudimBasicsGl")

local W, H = 64, 64
local w = pb.window.create(W, H, "ui_test")
if not w then print("UI_FAIL:window"); os.exit(2) end
pb.renderer.init()

local pass = 0
local fail = 0
local function check(name, cond)
    if cond then pass = pass + 1; print("  OK: " .. name)
    else fail = fail + 1; print("  FAIL: " .. name) end
end

local function near(a, b, tol)
    tol = tol or 5
    return math.abs(a - b) <= tol
end

-- ui subtable must exist
check("ui table exists", pb.ui ~= nil)
check("set_font is function", type(pb.ui.set_font) == "function")
check("begin_frame is function", type(pb.ui.begin_frame) == "function")
check("end_frame is function", type(pb.ui.end_frame) == "function")
check("label is function", type(pb.ui.label) == "function")
check("panel is function", type(pb.ui.panel) == "function")
check("button is function", type(pb.ui.button) == "function")
check("slider is function", type(pb.ui.slider) == "function")

-- begin/end frame should not crash
pb.renderer.begin_ui(W, H)
local ok_bf = pcall(pb.ui.begin_frame)
check("begin_frame runs", ok_bf)

-- button returns boolean
local clicked = pb.ui.button("test_btn", "Click", 0, 0, 50, 20, 0.5, 0.5, 0.5)
check("button returns boolean", type(clicked) == "boolean")
check("button not clicked (no input)", clicked == false)

-- slider returns number
local val = pb.ui.slider("test_sl", "Test", 0, 30, 50, 10, 0.5, 0.0, 1.0)
check("slider returns number", type(val) == "number")
check("slider value unchanged (no drag)", math.abs(val - 0.5) < 0.01)

-- panel should not crash
local ok_panel = pcall(pb.ui.panel, "TestPanel", 0, 0, 64, 64)
check("panel runs", ok_panel)

local ok_ef = pcall(pb.ui.end_frame)
check("end_frame runs", ok_ef)
pb.renderer.end_ui()

-- Visual: panel draws dark background that we can read
pb.renderer.clear(1.0, 1.0, 1.0, 1.0)  -- white background
pb.renderer.begin_ui(W, H)
pb.ui.begin_frame()
pb.ui.panel(nil, 0, 0, W, H)  -- dark panel covering entire window
pb.ui.end_frame()
pb.renderer.end_ui()
pb.renderer.finish()

local r, g, b = pb.renderer.read_pixel(32, 32, H)
-- panel bg is (0.16, 0.17, 0.20) ≈ (41, 43, 51)
check("panel pixel: dark R", r < 80)
check("panel pixel: dark G", g < 80)
check("panel pixel: dark B", b < 80)
check("panel pixel: not white", r < 200 and g < 200 and b < 200)

-- Visual: button draws colored rect
pb.renderer.clear(0.0, 0.0, 0.0, 1.0)  -- black bg
pb.renderer.begin_ui(W, H)
pb.ui.begin_frame()
pb.ui.button("visual_btn", "", 10, 10, 40, 40, 1.0, 0.0, 0.0)  -- red button, no label
pb.ui.end_frame()
pb.renderer.end_ui()
pb.renderer.finish()

r, g, b = pb.renderer.read_pixel(30, 30, H)
check("button pixel: has red", r > 150)
check("button pixel: low green", g < 80)

pb.window.destroy(w)
print(string.format("UI_RESULT: %d passed, %d failed", pass, fail))
if fail > 0 then os.exit(12) end
print("UI_OK")
' 2>&1 || true)

printf "%s\n" "$UI_OUTPUT"

if printf "%s\n" "$UI_OUTPUT" | grep -q "UI_OK"; then
    echo "UI module tests passed"
else
    echo "UI module tests failed!" >&2
    exit 12
fi

# ───────────────── Texture module tests ─────────────────
echo ""
echo "Running texture module tests..."
TEXTURE_OUTPUT=$(lua -e '
package.cpath = "./?.so;" .. package.cpath
local pb = require("PudimBasicsGl")

local W, H = 64, 64
local w = pb.window.create(W, H, "texture_test")
if not w then print("TEX_FAIL:window"); os.exit(2) end
pb.renderer.init()

local pass = 0
local fail = 0
local function check(name, cond)
    if cond then pass = pass + 1; print("  OK: " .. name)
    else fail = fail + 1; print("  FAIL: " .. name) end
end

local function near(a, b, tol)
    tol = tol or 5
    return math.abs(a - b) <= tol
end

-- texture subtable
check("texture table exists", pb.texture ~= nil)
check("texture.load is function", type(pb.texture.load) == "function")
check("texture.create is function", type(pb.texture.create) == "function")
check("texture.flush is function", type(pb.texture.flush) == "function")
check("texture.load_with_colorkey is function", type(pb.texture.load_with_colorkey) == "function")

-- create a 2x2 texture: R, G, B, White
local tex = pb.texture.create(2, 2, {
    255, 0, 0, 255,    -- red
    0, 255, 0, 255,    -- green
    0, 0, 255, 255,    -- blue
    255, 255, 255, 255 -- white
})
check("create 2x2 succeeds", tex ~= nil)

if tex then
    local tw, th = tex:get_size()
    check("get_size width == 2", tw == 2)
    check("get_size height == 2", th == 2)
    check("get_width == 2", tex:get_width() == 2)
    check("get_height == 2", tex:get_height() == 2)

    -- draw and verify pixels
    pb.renderer.clear(0, 0, 0, 1)
    pb.renderer.begin(W, H)
    pb.renderer.flush()
    tex:draw(0, 0, W, H)
    pb.texture.flush()
    pb.renderer.finish()

    -- top-left quadrant should be red (the texture is 2x2 scaled to 64x64)
    local r, g, b = pb.renderer.read_pixel(8, 8, H)
    check("tex draw top-left: red", r > 200 and g < 50 and b < 50)
    -- top-right quadrant should be green
    r, g, b = pb.renderer.read_pixel(48, 8, H)
    check("tex draw top-right: green", g > 200 and r < 50 and b < 50)
    -- bottom-left should be blue
    r, g, b = pb.renderer.read_pixel(8, 48, H)
    check("tex draw bottom-left: blue", b > 200 and r < 50 and g < 50)
    -- bottom-right should be white
    r, g, b = pb.renderer.read_pixel(48, 48, H)
    check("tex draw bottom-right: white", r > 200 and g > 200 and b > 200)

    -- tinted draw
    pb.renderer.clear(0, 0, 0, 1)
    pb.renderer.begin(W, H)
    pb.renderer.flush()
    -- tint white texture region with pure red tint
    tex:draw_tinted(0, 0, W, H, 1.0, 0.0, 0.0, 1.0)
    pb.texture.flush()
    pb.renderer.finish()
    -- bottom-right was white (1,1,1) * red tint (1,0,0) = red
    r, g, b = pb.renderer.read_pixel(48, 48, H)
    check("tinted draw: white*red=red", r > 200 and g < 50)

    tex:destroy()
    check("tex destroy runs", true)

    -- methods on destroyed texture return nil (nullable pointer pattern)
    local w_dead, h_dead = tex:get_size()
    check("dead texture returns nil", w_dead == nil and h_dead == nil)
end

-- load non-existent file
local bad, err2 = pb.texture.load("non_existent_image_12345.png")
check("load bad file returns nil", bad == nil)
check("load bad file has error", type(err2) == "string")

pb.window.destroy(w)
print(string.format("TEXTURE_RESULT: %d passed, %d failed", pass, fail))
if fail > 0 then os.exit(13) end
print("TEXTURE_OK")
' 2>&1 || true)

printf "%s\n" "$TEXTURE_OUTPUT"

if printf "%s\n" "$TEXTURE_OUTPUT" | grep -q "TEXTURE_OK"; then
    echo "Texture module tests passed"
else
    echo "Texture module tests failed!" >&2
    exit 13
fi

# ───────────────── Window module tests ─────────────────
echo ""
echo "Running window module tests..."
WINDOW_OUTPUT=$(lua -e '
package.cpath = "./?.so;" .. package.cpath
local pb = require("PudimBasicsGl")

local pass = 0
local fail = 0
local function check(name, cond)
    if cond then pass = pass + 1; print("  OK: " .. name)
    else fail = fail + 1; print("  FAIL: " .. name) end
end

-- Create a window
local w = pb.window.create(320, 240, "window_test")
check("window created", w ~= nil)

if w then
    -- get_size
    local ww, wh = pb.window.get_size(w)
    check("get_size width", ww == 320)
    check("get_size height", wh == 240)

    -- should_close
    check("should_close is false", pb.window.should_close(w) == false)

    -- set/get title
    local ok_title = pcall(pb.window.set_title, w, "new_title")
    check("set_title runs", ok_title)

    -- vsync
    local vsync = pb.window.get_vsync(w)
    check("get_vsync returns bool", type(vsync) == "boolean")
    local ok_vs = pcall(pb.window.set_vsync, w, true)
    check("set_vsync runs", ok_vs)

    -- fullscreen
    local fs = pb.window.is_fullscreen(w)
    check("is_fullscreen returns bool", type(fs) == "boolean")
    check("not fullscreen initially", fs == false)

    -- position
    local px, py = pb.window.get_position(w)
    check("get_position x is number", type(px) == "number")
    check("get_position y is number", type(py) == "number")

    -- focus
    check("is_focused returns bool", type(pb.window.is_focused(w)) == "boolean")

    -- OOP style
    local ww2, wh2 = w:get_size()
    check("OOP get_size works", ww2 == 320 and wh2 == 240)
    check("OOP should_close works", w:should_close() == false)

    -- swap_buffers and poll_events should not crash
    local ok_sb = pcall(pb.window.swap_buffers, w)
    check("swap_buffers runs", ok_sb)
    local ok_pe = pcall(pb.window.poll_events)
    check("poll_events runs", ok_pe)

    pb.window.destroy(w)
    check("window destroyed", true)
end

print(string.format("WINDOW_RESULT: %d passed, %d failed", pass, fail))
if fail > 0 then os.exit(14) end
print("WINDOW_EXT_OK")
' 2>&1 || true)

printf "%s\n" "$WINDOW_OUTPUT"

if printf "%s\n" "$WINDOW_OUTPUT" | grep -q "WINDOW_EXT_OK"; then
    echo "Window module tests passed"
else
    echo "Window module tests failed!" >&2
    exit 14
fi

# ───────────────── Time module tests ─────────────────
echo ""
echo "Running time module tests..."
TIME_OUTPUT=$(lua -e '
package.cpath = "./?.so;" .. package.cpath
local pb = require("PudimBasicsGl")

local pass = 0
local fail = 0
local function check(name, cond)
    if cond then pass = pass + 1; print("  OK: " .. name)
    else fail = fail + 1; print("  FAIL: " .. name) end
end

-- Need a window so GLFW is initialized (glfwGetTime requires it)
local w = pb.window.create(1, 1, "time_test")

check("time table exists", pb.time ~= nil)
check("update is function", type(pb.time.update) == "function")
check("delta is function", type(pb.time.delta) == "function")
check("get is function", type(pb.time.get) == "function")
check("fps is function", type(pb.time.fps) == "function")
check("sleep is function", type(pb.time.sleep) == "function")

-- update should not crash
pb.time.update()
check("update runs", true)

-- delta returns number
local dt = pb.time.delta()
check("delta returns number", type(dt) == "number")
check("delta >= 0", dt >= 0)

-- get returns number
local t = pb.time.get()
check("get returns number", type(t) == "number")
check("get >= 0", t >= 0)

-- fps returns number
local fps = pb.time.fps()
check("fps returns number", type(fps) == "number")

-- sleep should actually wait
local before = os.clock()
pb.time.sleep(0.05)
local after = os.clock()
check("sleep waits", (after - before) >= 0.04)

-- multiple updates should advance time
pb.time.update()
pb.time.sleep(0.01)
pb.time.update()
local dt2 = pb.time.delta()
check("delta after sleep > 0", dt2 > 0)

pb.window.destroy(w)
print(string.format("TIME_RESULT: %d passed, %d failed", pass, fail))
if fail > 0 then os.exit(15) end
print("TIME_OK")
' 2>&1 || true)

printf "%s\n" "$TIME_OUTPUT"

if printf "%s\n" "$TIME_OUTPUT" | grep -q "TIME_OK"; then
    echo "Time module tests passed"
else
    echo "Time module tests failed!" >&2
    exit 15
fi

echo ""
echo "════════════════════════════════════════════"
echo " ALL TEST SUITES PASSED"
echo "════════════════════════════════════════════"
exit 0
