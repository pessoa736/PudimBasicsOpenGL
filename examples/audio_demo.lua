-- PudimBasicsGl Audio Demo
-- Demonstrates loading and playing audio files
-- Run with: lua examples/audio_demo.lua
--
-- Supports WAV, MP3, and FLAC formats via miniaudio

package.cpath = "./?.so;" .. package.cpath
local pb = require("PudimBasicsGl")

-- Configuration
local WIDTH  = 800
local HEIGHT = 400
local TITLE  = "PudimBasicsGl - Audio Demo"

-- Create window
local window = pb.window.create(WIDTH, HEIGHT, TITLE)
if not window then
    print("Failed to create window!")
    os.exit(1)
end
pb.renderer.init()

-- ── Load sounds ─────────────────────────────────────────────────────
-- Put your audio files in the project root (or change the paths below).
-- Example: drop a "music.mp3" and a "click.wav" next to PudimBasicsGl.so.
--
-- If no files are found the demo still runs and shows the UI.

local sounds = {}      -- { {name, sound_or_nil, error_msg} }
local filenames = {
    "examples/example.mp3"
}

for _, fname in ipairs(filenames) do
    local snd, err = pb.audio.load(fname)
    if snd then
        table.insert(sounds, { name = fname, sound = snd })
        print("Loaded: " .. fname)
    end
end

if #sounds == 0 then
    print("No audio files found. Place .wav/.mp3/.flac files next to PudimBasicsGl.so")
    print("The UI will still show — press 1-5 when files are present.")
end

-- ── State ───────────────────────────────────────────────────────────
local master_vol  = 1.0
local selected    = 1
local status_text = "No sounds loaded"

if #sounds > 0 then
    status_text = "Ready — press SPACE to play"
end

print("")
print("=== Audio Demo Controls ===")
print("  1-5       : select sound slot")
print("  SPACE     : play / restart")
print("  P         : pause / resume")
print("  S         : stop")
print("  L         : toggle loop")
print("  UP/DOWN   : master volume")
print("  LEFT/RIGHT: pitch")
print("  ESC       : quit")
print("============================")

-- Key state tracking for edge detection (trigger once per press)
local prev_keys = {}
local function key_just_pressed(key)
    local pressed = pb.input.is_key_pressed(key)
    local was = prev_keys[key] or false
    prev_keys[key] = pressed
    return pressed and not was
end

while not pb.window.should_close(window) do
    pb.time.update()

    -- ── Input ─────────────────────────────────────────────────────
    -- Select slot 1-5
    for i = 1, 5 do
        if key_just_pressed(pb.input["KEY_" .. tostring(i)]) then
            selected = i
        end
    end

    local cur = sounds[selected]

    -- Play / restart
    if key_just_pressed(pb.input.KEY_SPACE) then
        if cur and cur.sound then
            cur.sound:play()
            status_text = "Playing: " .. cur.name
        end
    end

    -- Pause / resume
    if key_just_pressed(pb.input.KEY_P) then
        if cur and cur.sound then
            if cur.sound:is_playing() then
                cur.sound:pause()
                status_text = "Paused: " .. cur.name
            else
                cur.sound:resume()
                status_text = "Resumed: " .. cur.name
            end
        end
    end

    -- Stop
    if key_just_pressed(pb.input.KEY_S) then
        if cur and cur.sound then
            cur.sound:stop()
            status_text = "Stopped: " .. cur.name
        end
    end

    -- Toggle loop
    if key_just_pressed(pb.input.KEY_L) then
        if cur and cur.sound then
            local looping = not cur.sound:is_looping()
            cur.sound:set_looping(looping)
            status_text = (looping and "Loop ON: " or "Loop OFF: ") .. cur.name
        end
    end

    -- Master volume (UP/DOWN)
    if pb.input.is_key_pressed(pb.input.KEY_UP) then
        master_vol = math.min(master_vol + 0.01, 2.0)
        pb.audio.set_master_volume(master_vol)
    end
    if pb.input.is_key_pressed(pb.input.KEY_DOWN) then
        master_vol = math.max(master_vol - 0.01, 0.0)
        pb.audio.set_master_volume(master_vol)
    end

    -- Pitch (LEFT/RIGHT)
    if cur and cur.sound then
        if pb.input.is_key_pressed(pb.input.KEY_RIGHT) then
            local p = cur.sound:get_pitch() + 0.01
            cur.sound:set_pitch(math.min(p, 3.0))
        end
        if pb.input.is_key_pressed(pb.input.KEY_LEFT) then
            local p = cur.sound:get_pitch() - 0.01
            cur.sound:set_pitch(math.max(p, 0.1))
        end
    end

    -- ESC
    if pb.input.is_key_pressed(pb.input.KEY_ESCAPE) then
        break
    end

    -- ── Render ────────────────────────────────────────────────────
    pb.renderer.clear(0.1, 0.1, 0.15, 1.0)
    pb.renderer.begin(WIDTH, HEIGHT)

    -- Draw sound slots
    for i = 1, 5 do
        local slot = sounds[i]
        local y = 30 + (i - 1) * 60
        local is_sel = (i == selected)

        -- Slot background
        if is_sel then
            pb.renderer.rect_filled(20, y, WIDTH - 40, 50,
                { r = 0.2, g = 0.3, b = 0.5, a = 1.0 })
        else
            pb.renderer.rect_filled(20, y, WIDTH - 40, 50,
                { r = 0.15, g = 0.15, b = 0.2, a = 1.0 })
        end

        -- Playing indicator
        if slot and slot.sound and slot.sound:is_playing() then
            pb.renderer.circle_filled(50, y + 25, 8,
                { r = 0.2, g = 1.0, b = 0.3, a = 1.0 })
        else
            pb.renderer.circle_filled(50, y + 25, 8,
                { r = 0.4, g = 0.4, b = 0.4, a = 1.0 })
        end

        -- Looping indicator
        if slot and slot.sound and slot.sound:is_looping() then
            pb.renderer.circle_filled(80, y + 25, 5,
                { r = 1.0, g = 0.8, b = 0.2, a = 1.0 })
        end
    end

    -- Master volume bar
    local bar_y = HEIGHT - 50
    pb.renderer.rect_filled(20, bar_y, WIDTH - 40, 20,
        { r = 0.2, g = 0.2, b = 0.25, a = 1.0 })
    local vol_w = math.floor((WIDTH - 40) * math.min(master_vol, 2.0) / 2.0)
    pb.renderer.rect_filled(20, bar_y, vol_w, 20,
        { r = 0.3, g = 0.7, b = 0.3, a = 1.0 })

    pb.renderer.finish()

    -- Title with status
    pb.window.set_title(window, string.format(
        "%s | Vol: %.0f%% | %s",
        TITLE, master_vol * 100, status_text
    ))

    pb.window.swap_buffers(window)
    pb.window.poll_events()
end

-- Cleanup sounds
for _, s in ipairs(sounds) do
    if s.sound then s.sound:destroy() end
end
pb.audio.shutdown()
pb.window.destroy(window)
print("Goodbye!")
