-- OOP-style demo: window:should_close(), texture:draw(), time:update(), renderer calls
---@type PudimBasicsGl
local pb = require('PudimBasicsGl')

-- Create window (annotated for LSP: `win:` will show window methods)
---@type Window
local win, err = pb.window.create(800, 600, "OOP Demo")
if not win then
    print("Failed to create window:", err)
    return
end

-- Initialize renderer (requires OpenGL context)
pb.renderer.init()

-- Create a tiny procedural texture (2x2 RGBA): red, green, blue, yellow
---@type Texture
local tex = pb.texture.create(2, 2, {
    255, 0,   0,   255,  -- pixel 1 (red)
    0,   255, 0,   255,  -- pixel 2 (green)
    0,   0,   255, 255,  -- pixel 3 (blue)
    255, 255, 0,  255   -- pixel 4 (yellow)
})

-- Main loop
while not win:should_close() do
    pb.window.poll_events()

    -- Update time/delta
    pb.time.update()
    local dt = pb.time.delta()

    -- Animate clear color
    local t = pb.time.get()
    local pulse = (math.sin(t * 2.0) * 0.5 + 0.5)

    -- Render
    local w, h = win:get_size()
    pb.renderer.begin(w, h)
    pb.renderer.clear(pulse * 0.2, 0.15, 0.25, 1.0)

    -- Draw primitives
    pb.renderer.rect_filled(50, 50, 150, 100, 1, 1, 1, 1)
    pb.renderer.circle_filled(400, 200, 64, 1, 0.8, 0.2, 1)

    -- Draw the procedural texture scaled up using object-style call
    tex:draw(600, 50, 128, 128)

    pb.renderer.finish()

    -- Swap buffers
    win:swap_buffers()

    -- Small sleep to avoid busy loop
    pb.time.sleep(0.01)
end

-- Cleanup
pb.texture.destroy(tex)
pb.window.destroy(win)
