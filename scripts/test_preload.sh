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
    exit 0
else
    echo "Text module tests failed!" >&2
    exit 7
fi
