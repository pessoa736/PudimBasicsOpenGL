-- PudimBasicsGl Input Demo
-- Demonstrates keyboard and mouse input
-- Run with: lua examples/input_demo.lua

package.cpath = "./?.so;" .. package.cpath
local pb = require("PudimBasicsGl")

-- Configuration
local WIDTH = 800
local HEIGHT = 600
local TITLE = "PudimBasicsGl - Input Demo"

-- Create window
local window = pb.window.create(WIDTH, HEIGHT, TITLE)
if not window then
    print("Failed to create window!")
    os.exit(1)
end

pb.renderer.init()

-- Player state (controlled by keyboard)
local player = {
    x = WIDTH / 2,
    y = HEIGHT / 2,
    size = 40,
    speed = 250,
    color = { r = 0.2, g = 0.6, b = 1.0, a = 1.0 }
}

-- Mouse cursor trail
local trail = {}
local MAX_TRAIL = 30

-- Click markers
local clicks = {}

-- Helper
local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

-- Color for mouse buttons
local BUTTON_COLORS = {
    left   = { r = 1.0,  g = 0.3,  b = 0.3,  a = 0.8 },
    right  = { r = 0.3,  g = 1.0,  b = 0.3,  a = 0.8 },
    middle = { r = 1.0,  g = 1.0,  b = 0.3,  a = 0.8 },
}

print("=== PudimBasicsGl Input Demo ===")
print("WASD / Arrow keys : move the blue square")
print("Left Shift        : boost speed")
print("Mouse move        : cursor trail")
print("Left click        : red marker")
print("Right click       : green marker")
print("Middle click      : yellow marker")
print("ESC               : quit")
print("================================")

while not pb.window.should_close(window) do
    pb.time.update()
    local dt = pb.time.delta()

    -- ── Keyboard input ──────────────────────────────────────────────

    -- Speed boost with Shift
    local speed = player.speed
    if pb.input.is_key_pressed(pb.input.KEY_LEFT_SHIFT) then
        speed = speed * 2.5
        player.color = { r = 1.0, g = 0.4, b = 0.1, a = 1.0 } -- orange when boosting
    else
        player.color = { r = 0.2, g = 0.6, b = 1.0, a = 1.0 }
    end

    -- Movement (WASD + arrows)
    if pb.input.is_key_pressed(pb.input.KEY_W) or pb.input.is_key_pressed(pb.input.KEY_UP) then
        player.y = player.y - speed * dt
    end
    if pb.input.is_key_pressed(pb.input.KEY_S) or pb.input.is_key_pressed(pb.input.KEY_DOWN) then
        player.y = player.y + speed * dt
    end
    if pb.input.is_key_pressed(pb.input.KEY_A) or pb.input.is_key_pressed(pb.input.KEY_LEFT) then
        player.x = player.x - speed * dt
    end
    if pb.input.is_key_pressed(pb.input.KEY_D) or pb.input.is_key_pressed(pb.input.KEY_RIGHT) then
        player.x = player.x + speed * dt
    end

    -- Keep player inside the window
    player.x = clamp(player.x, 0, WIDTH - player.size)
    player.y = clamp(player.y, 0, HEIGHT - player.size)

    -- Quit on ESC
    if pb.input.is_key_pressed(pb.input.KEY_ESCAPE) then
        break
    end

    -- ── Mouse input ─────────────────────────────────────────────────

    local mx, my = pb.input.get_mouse_position()

    -- Cursor trail (store recent positions)
    table.insert(trail, { x = mx, y = my })
    if #trail > MAX_TRAIL then
        table.remove(trail, 1)
    end

    -- Click markers
    if pb.input.is_mouse_button_pressed(pb.input.MOUSE_LEFT) then
        -- only add if last click is far enough (avoid spam)
        local last = clicks[#clicks]
        if not last or math.abs(last.x - mx) + math.abs(last.y - my) > 10 then
            table.insert(clicks, { x = mx, y = my, color = BUTTON_COLORS.left })
        end
    end
    if pb.input.is_mouse_button_pressed(pb.input.MOUSE_RIGHT) then
        local last = clicks[#clicks]
        if not last or math.abs(last.x - mx) + math.abs(last.y - my) > 10 then
            table.insert(clicks, { x = mx, y = my, color = BUTTON_COLORS.right })
        end
    end
    if pb.input.is_mouse_button_pressed(pb.input.MOUSE_MIDDLE) then
        local last = clicks[#clicks]
        if not last or math.abs(last.x - mx) + math.abs(last.y - my) > 10 then
            table.insert(clicks, { x = mx, y = my, color = BUTTON_COLORS.middle })
        end
    end

    -- Limit stored clicks
    while #clicks > 100 do
        table.remove(clicks, 1)
    end

    -- ── Render ──────────────────────────────────────────────────────

    pb.renderer.clear(0.08, 0.08, 0.12, 1.0)
    pb.renderer.begin(WIDTH, HEIGHT)

    -- Draw click markers
    for _, c in ipairs(clicks) do
        pb.renderer.circle_filled(math.floor(c.x), math.floor(c.y), 8, c.color)
    end

    -- Draw cursor trail (fading circles)
    for i, pt in ipairs(trail) do
        local alpha = i / #trail
        local radius = 3 + alpha * 5
        pb.renderer.circle_filled(
            math.floor(pt.x), math.floor(pt.y), math.floor(radius),
            { r = 0.9, g = 0.9, b = 0.9, a = alpha * 0.6 }
        )
    end

    -- Draw player square
    pb.renderer.rect_filled(
        math.floor(player.x), math.floor(player.y),
        player.size, player.size,
        player.color
    )

    -- Draw crosshair at mouse position
    local ch = 10
    pb.renderer.rect_filled(math.floor(mx) - ch, math.floor(my) - 1, ch * 2, 2, pb.renderer.colors.WHITE)
    pb.renderer.rect_filled(math.floor(mx) - 1, math.floor(my) - ch, 2, ch * 2, pb.renderer.colors.WHITE)

    pb.renderer.finish()

    -- Update title with FPS and player position
    pb.window.set_title(window, string.format(
        "%s | FPS: %.0f | Player: %d,%d | Mouse: %d,%d",
        TITLE, pb.time.fps(),
        math.floor(player.x), math.floor(player.y),
        math.floor(mx), math.floor(my)
    ))

    pb.window.swap_buffers(window)
    pb.window.poll_events()
end

pb.window.destroy(window)
print("Goodbye!")
