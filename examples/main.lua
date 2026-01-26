-- PudimBasicsGl Library Example
-- Run with: lua scripts/main.lua (after running make)

-- Add current directory to cpath for PudimBasicsGl.so
package.cpath = "./?.so;" .. package.cpath

-- Load the PudimBasicsGl library
local pb = require("PudimBasicsGl")

-- Configuration
local WIDTH = 800
local HEIGHT = 600
local TITLE = "PudimBasicsGl - Pudim OpenGL Basics"

-- Create window
local window = pb.window.create(WIDTH, HEIGHT, TITLE)
if not window then
    print("Failed to create window!")
    os.exit(1)
end

-- Initialize renderer
pb.renderer.init()

-- Helper function for clamping
local function clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

-- Game state
local circles = {}
local frame_count = 0

-- Spawn some circles
for i = 1, 15 do
    table.insert(circles, {
        x = math.random(50, WIDTH - 50),
        y = math.random(50, HEIGHT - 50),
        radius = math.random(10, 40),
        color = {
            r = math.random(),
            g = math.random(),
            b = math.random(),
            a = 0.8
        },
        dx = (math.random() - 0.5) * 150,
        dy = (math.random() - 0.5) * 150
    })
end

print("PudimBasicsGl Graphics Library Demo")
print("Bouncing circles animation")

-- Main loop
while not pb.window.should_close(window) do
    -- Update time
    pb.time.update()
    local dt = pb.time.delta()
    frame_count = frame_count + 1
    
    -- Update circles
    for _, c in ipairs(circles) do
        c.x = c.x + c.dx * dt
        c.y = c.y + c.dy * dt
        
        -- Bounce off walls
        if c.x < c.radius or c.x > WIDTH - c.radius then
            c.dx = -c.dx
            c.x = clamp(c.x, c.radius, WIDTH - c.radius)
        end
        if c.y < c.radius or c.y > HEIGHT - c.radius then
            c.dy = -c.dy
            c.y = clamp(c.y, c.radius, HEIGHT - c.radius)
        end
    end
    
    -- Update window title with FPS
    if frame_count % 30 == 0 then
        local fps = pb.time.fps()
        pb.window.set_title(window, string.format("%s - FPS: %.0f", TITLE, fps))
    end
    
    -- Render
    pb.renderer.clear(0.1, 0.1, 0.15, 1.0)
    pb.renderer.begin(WIDTH, HEIGHT)
    
    -- Draw circles
    for _, c in ipairs(circles) do
        pb.renderer.circle_filled(math.floor(c.x), math.floor(c.y), c.radius, c.color)
    end
    
    -- Draw a static rectangle
    pb.renderer.rect_filled(10, 10, 100, 30, pb.renderer.colors.WHITE)
    
    pb.renderer.finish()
    
    -- Swap and poll
    pb.window.swap_buffers(window)
    pb.window.poll_events()
end

-- Cleanup
pb.window.destroy(window)
print("Goodbye!")
