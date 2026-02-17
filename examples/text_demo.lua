-- Text rendering demo for PudimBasicsGl
-- Shows how to load fonts, render text with different sizes and colors

package.cpath = "./?.so;" .. package.cpath
local pb = require("PudimBasicsGl")

local WIDTH = 800
local HEIGHT = 600

-- Create window
local window = pb.window.create(WIDTH, HEIGHT, "PudimBasicsGl - Text Demo")
pb.renderer.init()

-- Load fonts at different sizes
-- Replace with the path to a .ttf font on your system
local font_path = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"

local font_small = pb.text.load(font_path, 16)
if not font_small then
    -- Try alternative font paths
    font_path = "/usr/share/fonts/TTF/DejaVuSans.ttf"
    font_small = pb.text.load(font_path, 16)
end
if not font_small then
    font_path = "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf"
    font_small = pb.text.load(font_path, 16)
end
if not font_small then
    print("Could not find a system font! Please edit font_path in this script.")
    pb.window.destroy(window)
    return
end

local font_medium = pb.text.load(font_path, 28)
local font_large = pb.text.load(font_path, 48)
local font_title = pb.text.load(font_path, 64)

print("Font sizes loaded: " .. font_small:get_size() .. ", " ..
      font_medium:get_size() .. ", " ..
      font_large:get_size() .. ", " ..
      font_title:get_size())

-- Colors
local white = pb.renderer.color(1, 1, 1)
local red = pb.renderer.color(1, 0.2, 0.2)
local green = pb.renderer.color(0.2, 1, 0.2)
local blue = pb.renderer.color(0.3, 0.5, 1)
local yellow = pb.renderer.color(1, 1, 0.2)
local purple = pb.renderer.color(0.8, 0.3, 1)

-- Main loop
while not pb.window.should_close(window) do
    pb.time.update()
    pb.renderer.clear(0.1, 0.1, 0.15, 1.0)
    pb.renderer.begin(WIDTH, HEIGHT)

    -- Flush primitives before drawing text (different shader)
    pb.renderer.flush()

    -- Title
    font_title:draw("PudimBasicsGl", 20, 20, yellow)

    -- Subtitle
    font_medium:draw("Text Rendering Demo", 20, 100, white)

    -- Different sizes
    font_small:draw("Small text (16px)", 20, 160, green)
    font_medium:draw("Medium text (28px)", 20, 190, blue)
    font_large:draw("Large text (48px)", 20, 230, red)

    -- Measure text
    local tw, th = font_medium:measure("Measured text!")
    local mx, my = 20, 310
    -- Draw background rect
    pb.text.flush()  -- flush text before drawing primitives
    pb.renderer.rect_filled(mx - 4, my - 4, math.floor(tw) + 8, math.floor(th) + 8, 0.3, 0.3, 0.4)
    pb.renderer.flush()  -- flush primitives before text
    font_medium:draw("Measured text!", mx, my, purple)
    font_small:draw(string.format("Width: %.0f  Height: %.0f", tw, th), mx, my + th + 10, white)

    -- Multi-line text
    font_medium:draw("Line 1: Multi-line\nLine 2: text support\nLine 3: works great!", 20, 410, green)

    -- FPS counter
    local fps_text = string.format("FPS: %.0f", pb.time.fps())
    local fps_w = font_small:measure(fps_text)
    font_small:draw(fps_text, WIDTH - fps_w - 10, 10, yellow)

    -- Flush text before finishing
    pb.text.flush()

    pb.renderer.finish()
    pb.window.swap_buffers(window)
    pb.window.poll_events()
end

-- Cleanup
font_small:destroy()
font_medium:destroy()
font_large:destroy()
font_title:destroy()
pb.window.destroy(window)
