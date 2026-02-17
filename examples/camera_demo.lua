-- PudimBasicsGl Camera Demo
-- Demonstrates 2D camera: pan, zoom, rotation, look_at, and coordinate conversion
-- Run with: lua examples/camera_demo.lua

package.cpath = "./?.so;" .. package.cpath
local pb = require("PudimBasicsGl")

-- Configuration
local WIDTH  = 800
local HEIGHT = 600
local TITLE  = "PudimBasicsGl - Camera Demo"

-- Create window
local window = pb.window.create(WIDTH, HEIGHT, TITLE)
if not window then
    print("Failed to create window!")
    os.exit(1)
end

pb.renderer.init()

-- ── World objects (static scene) ──────────────────────────────────────

local GRID_STEP   = 80
local GRID_EXTENT = 800  -- grid goes from -EXTENT to +EXTENT

local objects = {
    { x = 0,    y = 0,    w = 60, h = 60, color = pb.renderer.colors.RED,     label = "Origin" },
    { x = 200,  y = -150, w = 50, h = 50, color = pb.renderer.colors.GREEN,   label = "Green" },
    { x = -300, y = 100,  w = 70, h = 70, color = pb.renderer.colors.BLUE,    label = "Blue" },
    { x = 400,  y = 300,  w = 40, h = 40, color = pb.renderer.colors.YELLOW,  label = "Yellow" },
    { x = -200, y = -300, w = 55, h = 55, color = pb.renderer.colors.MAGENTA, label = "Magenta" },
    { x = 350,  y = -250, w = 45, h = 45, color = pb.renderer.colors.CYAN,    label = "Cyan" },
    { x = -400, y = 350,  w = 65, h = 65, color = pb.renderer.colors.ORANGE,  label = "Orange" },
}

-- Camera state for smooth movement
local cam_speed     = 300
local zoom_speed    = 1.5
local rotate_speed  = 90  -- degrees/sec

-- target index for look_at cycling
local look_at_idx = 0

print("=== PudimBasicsGl Camera Demo ===")
print("WASD / Arrows : pan camera")
print("Q / E         : zoom out / zoom in")
print("Z / C         : rotate left / right")
print("R             : reset camera")
print("SPACE         : look_at next object")
print("TAB           : snap to origin")
print("Left Shift    : 2.5x speed boost")
print("ESC           : quit")
print("=================================")

while not pb.window.should_close(window) do
    pb.time.update()
    local dt = pb.time.delta()

    local w, h = pb.window.get_size(window)

    -- ── Input ─────────────────────────────────────────────────────

    local speed = cam_speed
    if pb.input.is_key_pressed(pb.input.KEY_LEFT_SHIFT) then
        speed = speed * 2.5
    end

    -- Pan
    if pb.input.is_key_pressed(pb.input.KEY_W) or pb.input.is_key_pressed(pb.input.KEY_UP) then
        pb.camera.move(0, -speed * dt)
    end
    if pb.input.is_key_pressed(pb.input.KEY_S) or pb.input.is_key_pressed(pb.input.KEY_DOWN) then
        pb.camera.move(0, speed * dt)
    end
    if pb.input.is_key_pressed(pb.input.KEY_A) or pb.input.is_key_pressed(pb.input.KEY_LEFT) then
        pb.camera.move(-speed * dt, 0)
    end
    if pb.input.is_key_pressed(pb.input.KEY_D) or pb.input.is_key_pressed(pb.input.KEY_RIGHT) then
        pb.camera.move(speed * dt, 0)
    end

    -- Zoom
    if pb.input.is_key_pressed(pb.input.KEY_E) then
        local z = pb.camera.get_zoom()
        pb.camera.set_zoom(z + zoom_speed * dt)
    end
    if pb.input.is_key_pressed(pb.input.KEY_Q) then
        local z = pb.camera.get_zoom()
        local nz = z - zoom_speed * dt
        if nz < 0.1 then nz = 0.1 end
        pb.camera.set_zoom(nz)
    end

    -- Rotation
    if pb.input.is_key_pressed(pb.input.KEY_Z) then
        local r = pb.camera.get_rotation()
        pb.camera.set_rotation(r - rotate_speed * dt)
    end
    if pb.input.is_key_pressed(pb.input.KEY_C) then
        local r = pb.camera.get_rotation()
        pb.camera.set_rotation(r + rotate_speed * dt)
    end

    -- Reset
    if pb.input.is_key_pressed(pb.input.KEY_R) then
        pb.camera.reset()
    end

    -- TAB — snap to origin
    if pb.input.is_key_pressed(pb.input.KEY_TAB) then
        pb.camera.look_at(0, 0, w, h)
    end

    -- SPACE — cycle look_at through objects (simple debounce via frame skip)
    if pb.input.is_key_pressed(pb.input.KEY_SPACE) then
        look_at_idx = (look_at_idx % #objects) + 1
        local obj = objects[look_at_idx]
        pb.camera.look_at(obj.x + obj.w / 2, obj.y + obj.h / 2, w, h)
    end

    -- Quit
    if pb.input.is_key_pressed(pb.input.KEY_ESCAPE) then
        break
    end

    -- ── Mouse world coordinates ───────────────────────────────────

    local mx, my = pb.input.get_mouse_position()
    local wx, wy = pb.camera.screen_to_world(mx, my)

    -- ── Render ────────────────────────────────────────────────────

    pb.renderer.clear(0.08, 0.08, 0.12, 1.0)
    pb.renderer.begin(w, h)

    -- Draw grid (world space — camera affects it)
    local grid_color = { r = 0.2, g = 0.2, b = 0.25, a = 1.0 }
    for gx = -GRID_EXTENT, GRID_EXTENT, GRID_STEP do
        pb.renderer.line(gx, -GRID_EXTENT, gx, GRID_EXTENT, grid_color)
    end
    for gy = -GRID_EXTENT, GRID_EXTENT, GRID_STEP do
        pb.renderer.line(-GRID_EXTENT, gy, GRID_EXTENT, gy, grid_color)
    end

    -- World axes
    pb.renderer.line(-GRID_EXTENT, 0, GRID_EXTENT, 0, { r = 0.5, g = 0.15, b = 0.15, a = 0.6 })
    pb.renderer.line(0, -GRID_EXTENT, 0, GRID_EXTENT, { r = 0.15, g = 0.5, b = 0.15, a = 0.6 })

    -- Draw world objects
    for _, obj in ipairs(objects) do
        pb.renderer.rect_filled(obj.x, obj.y, obj.w, obj.h, obj.color)
        -- small outline
        pb.renderer.rect(obj.x - 1, obj.y - 1, obj.w + 2, obj.h + 2, pb.renderer.colors.WHITE)
    end

    -- Mouse crosshair in world coordinates
    local cross = { r = 1, g = 1, b = 0, a = 0.4 }
    pb.renderer.line(wx - 12, wy, wx + 12, wy, cross)
    pb.renderer.line(wx, wy - 12, wx, wy + 12, cross)

    pb.renderer.flush()

    -- ── HUD (reset camera so HUD stays on screen) ────────────────

    -- Save camera state
    local cam_x, cam_y = pb.camera.get_position()
    local cam_z = pb.camera.get_zoom()
    local cam_r = pb.camera.get_rotation()

    -- Temporarily reset camera for screen-space HUD
    pb.camera.reset()
    -- Force a new batch with identity camera
    pb.renderer.flush()
    pb.renderer.begin(w, h)

    -- Background strip for HUD
    pb.renderer.rect_filled(0, 0, w, 20, { r = 0, g = 0, b = 0, a = 0.5 })

    -- Status dots as simple visual indicators
    -- Zoom indicator bar
    local bar_x = 10
    local bar_w = math.min(cam_z * 60, 200)
    pb.renderer.rect_filled(bar_x, 5, bar_w, 10, { r = 0.3, g = 0.8, b = 0.3, a = 0.8 })

    -- Bottom-left help
    pb.renderer.rect_filled(0, h - 18, w, 18, { r = 0, g = 0, b = 0, a = 0.5 })

    pb.renderer.flush()

    -- Restore camera
    pb.camera.set_position(cam_x, cam_y)
    pb.camera.set_zoom(cam_z)
    pb.camera.set_rotation(cam_r)

    pb.renderer.finish()

    pb.window.swap_buffers(window)
    pb.window.poll_events()
end

pb.camera.reset()
pb.window.destroy(window)
print("Camera demo finished.")
