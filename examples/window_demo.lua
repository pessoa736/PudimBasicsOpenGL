-- PudimBasicsGl Window Features Demo
-- Demonstrates VSync, fullscreen, and window manipulation

local pb = require("PudimBasicsGl")

local WIDTH = 800
local HEIGHT = 600

-- Create window
local window = pb.window.create(WIDTH, HEIGHT, "PudimBasicsGl Window Features Demo")
if not window then
    print("Failed to create window!")
    return
end

-- Initialize renderer
pb.renderer.init()

-- State
local vsync_enabled = pb.window.get_vsync(window)
local frame_count = 0
local last_fps_update = 0
local current_fps = 0

print("Controls:")
print("  Press any key to toggle VSync")
print("  Window is resizable")
print("  Close window to exit")
print("")
print("Initial VSync: " .. (vsync_enabled and "ON" or "OFF"))

-- Main loop
while not pb.window.should_close(window) do
    pb.time.update()
    local dt = pb.time.delta()
    local total_time = pb.time.get()
    
    -- Update FPS counter
    frame_count = frame_count + 1
    if total_time - last_fps_update >= 0.5 then
        current_fps = frame_count / (total_time - last_fps_update)
        frame_count = 0
        last_fps_update = total_time
    end
    
    -- Get current window size
    local w, h = pb.window.get_size(window)
    
    -- Clear with a color that changes based on vsync
    local bg_r = vsync_enabled and 0.1 or 0.15
    local bg_g = 0.1
    local bg_b = vsync_enabled and 0.15 or 0.1
    pb.renderer.clear(bg_r, bg_g, bg_b, 1.0)
    
    pb.renderer.begin(w, h)
    
    -- Draw animated shapes to visualize frame rate
    local num_circles = 20
    for i = 0, num_circles - 1 do
        local angle = (i / num_circles) * math.pi * 2 + total_time * 2
        local cx = w / 2 + math.cos(angle) * (math.min(w, h) * 0.3)
        local cy = h / 2 + math.sin(angle) * (math.min(w, h) * 0.3)
        local radius = 10 + 5 * math.sin(total_time * 4 + i)
        
        -- Rainbow colors
        local hue = (i / num_circles + total_time * 0.1) % 1.0
        local r, g, b = hsv_to_rgb(hue, 0.8, 1.0)
        
        pb.renderer.circle_filled(cx, cy, radius, r, g, b, 0.8)
    end
    
    -- Draw info panel
    local panel_w = 300
    local panel_h = 100
    local panel_x = 10
    local panel_y = 10
    
    pb.renderer.rect_filled(panel_x, panel_y, panel_w, panel_h, 0.0, 0.0, 0.0, 0.7)
    pb.renderer.rect(panel_x, panel_y, panel_w, panel_h, 0.5, 0.5, 0.5, 1.0)
    
    -- Draw indicator bars for FPS
    local bar_x = panel_x + 10
    local bar_y = panel_y + 60
    local bar_width = panel_w - 20
    local bar_height = 20
    
    -- Background bar
    pb.renderer.rect_filled(bar_x, bar_y, bar_width, bar_height, 0.2, 0.2, 0.2, 1.0)
    
    -- FPS indicator (green if high, yellow if medium, red if low)
    local fps_ratio = math.min(current_fps / 120, 1.0)
    local fps_r = fps_ratio < 0.5 and 1.0 or (1.0 - (fps_ratio - 0.5) * 2)
    local fps_g = fps_ratio > 0.5 and 1.0 or (fps_ratio * 2)
    pb.renderer.rect_filled(bar_x, bar_y, bar_width * fps_ratio, bar_height, fps_r, fps_g, 0.2, 1.0)
    
    -- VSync indicator
    local indicator_y = panel_y + 30
    local indicator_color = vsync_enabled and {0.2, 0.8, 0.2} or {0.8, 0.2, 0.2}
    pb.renderer.circle_filled(panel_x + 20, indicator_y, 8, indicator_color[1], indicator_color[2], indicator_color[3], 1.0)
    
    pb.renderer.finish()
    
    -- Update window title with info
    local fullscreen = pb.window.is_fullscreen(window)
    local title = string.format("PudimBasicsGl Demo | FPS: %.0f | VSync: %s | %dx%d | %s",
        current_fps,
        vsync_enabled and "ON" or "OFF",
        w, h,
        fullscreen and "Fullscreen" or "Windowed")
    pb.window.set_title(window, title)
    
    -- Swap and poll
    pb.window.swap_buffers(window)
    pb.window.poll_events()
end

-- Cleanup
pb.window.destroy(window)
print("Demo finished!")

-- Helper function: HSV to RGB conversion
function hsv_to_rgb(h, s, v)
    if s == 0 then return v, v, v end
    
    h = h * 6
    local i = math.floor(h)
    local f = h - i
    local p = v * (1 - s)
    local q = v * (1 - s * f)
    local t = v * (1 - s * (1 - f))
    
    i = i % 6
    if i == 0 then return v, t, p
    elseif i == 1 then return q, v, p
    elseif i == 2 then return p, v, t
    elseif i == 3 then return p, q, v
    elseif i == 4 then return t, p, v
    else return v, p, q
    end
end
