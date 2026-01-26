-- PudimBasicsGl Texture Demo
-- This example demonstrates texture loading, drawing, and the new window features

local pb = require("PudimBasicsGl")

local WIDTH = 800
local HEIGHT = 600

-- Create window
local window = pb.window.create(WIDTH, HEIGHT, "PudimBasicsGl Texture Demo")
if not window then
    print("Failed to create window!")
    return
end

-- Initialize renderer
pb.renderer.init()

-- Try to load a texture (create a test image if needed)
local texture = pb.texture.load("test.png")
if not texture then
    print("Could not load 'test.png', creating a procedural texture...")
    -- Create a simple 64x64 checkerboard texture
    local size = 64
    local data = {}
    for y = 0, size - 1 do
        for x = 0, size - 1 do
            local isWhite = ((x // 8) + (y // 8)) % 2 == 0
            local r, g, b = 255, 255, 255
            if not isWhite then
                r, g, b = 100, 150, 200  -- Light blue
            end
            table.insert(data, r)  -- R
            table.insert(data, g)  -- G
            table.insert(data, b)  -- B
            table.insert(data, 255)  -- A
        end
    end
    texture = pb.texture.create(size, size, data)
end

if not texture then
    print("Failed to create texture!")
    pb.window.destroy(window)
    return
end

local tex_width, tex_height = texture:get_size()
print(string.format("Texture size: %dx%d", tex_width, tex_height))

-- State variables
local angle = 0
local scale = 1.0
local x, y = WIDTH / 2, HEIGHT / 2

-- Main loop
while not pb.window.should_close(window) do
    pb.time.update()
    local dt = pb.time.delta()
    
    -- Update rotation
    angle = angle + 45 * dt  -- 45 degrees per second
    if angle >= 360 then angle = angle - 360 end
    
    -- Pulse scale
    scale = 1.0 + 0.3 * math.sin(pb.time.get() * 2)
    
    -- Get current window size (in case it was resized)
    local w, h = pb.window.get_size(window)
    
    -- Clear screen
    pb.renderer.clear(0.1, 0.1, 0.15, 1.0)
    pb.renderer.begin(w, h)
    
    -- Draw some primitives in background
    pb.renderer.set_line_width(2)
    for i = 0, 10 do
        local lx = (i / 10) * w
        pb.renderer.line(lx, 0, lx, h, 0.2, 0.2, 0.25, 1.0)
    end
    for i = 0, 8 do
        local ly = (i / 8) * h
        pb.renderer.line(0, ly, w, ly, 0.2, 0.2, 0.25, 1.0)
    end
    
    -- Flush primitives before drawing textures
    pb.renderer.flush()
    
    -- Draw texture in different ways
    
    -- 1. Simple draw (top-left corner)
    texture:draw(10, 10)
    
    -- 2. Scaled draw
    texture:draw(10, 90, tex_width * 2, tex_height * 2)
    
    -- 3. Tinted draw (red tint)
    texture:draw_tinted(150, 10, tex_width, tex_height, 1.0, 0.5, 0.5, 1.0)
    
    -- 4. Rotating in center
    local scaled_w = tex_width * scale * 2
    local scaled_h = tex_height * scale * 2
    texture:draw_ex(
        w / 2 - scaled_w / 2, 
        h / 2 - scaled_h / 2, 
        scaled_w, scaled_h,
        angle,
        0.5, 0.5,  -- origin at center
        1.0, 1.0, 1.0, 1.0  -- white tint
    )
    
    -- 5. Draw a region (quarter of texture, bottom-right)
    texture:draw_region(
        w - 150, h - 150, 100, 100,  -- dest rect
        tex_width / 2, tex_height / 2, tex_width / 2, tex_height / 2  -- source rect
    )
    
    -- Flush textures
    pb.texture.flush()
    
    -- Draw UI text-like info using primitives
    pb.renderer.rect_filled(5, h - 25, 200, 20, 0.0, 0.0, 0.0, 0.7)
    pb.renderer.flush()
    
    pb.renderer.finish()
    
    -- Swap and poll
    pb.window.swap_buffers(window)
    pb.window.poll_events()
    
    -- Show FPS in title
    local fps = pb.time.fps()
    pb.window.set_title(window, string.format("PudimBasicsGl Texture Demo - FPS: %.1f", fps))
end

-- Cleanup
texture:destroy()
pb.window.destroy(window)
print("Demo finished!")
