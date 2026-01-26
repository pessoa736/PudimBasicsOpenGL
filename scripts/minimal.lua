-- Minimal PudimBasicsGl Example
-- The simplest possible program using PudimBasicsGl

package.cpath = "./?.so;" .. package.cpath
local pb = require("PudimBasicsGl")

-- Create window and initialize
local window = pb.window.create(640, 480, "Hello PudimBasicsGl!")
pb.renderer.init()

-- Simple main loop
while not pb.window.should_close(window) do
    -- Clear and draw
    pb.renderer.clear(0.2, 0.3, 0.4, 1.0)
    pb.renderer.begin(640, 480)
    
    -- Draw a red rectangle
    pb.renderer.rect_filled(100, 100, 200, 150, pb.renderer.colors.RED)
    
    -- Draw a green circle
    pb.renderer.circle_filled(400, 240, 50, {r=0, g=1, b=0, a=1})
    
    pb.renderer.finish()
    
    -- Swap and poll
    pb.window.swap_buffers(window)
    pb.window.poll_events()
end

pb.window.destroy(window)
