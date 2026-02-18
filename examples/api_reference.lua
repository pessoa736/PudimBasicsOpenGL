--[[
    PudimBasicsGl API Reference
    ===========================

    All APIs are under the 'PudimBasicsGl' table (aliased as 'pb' below).
    The user controls the main loop — there is no framework-imposed game loop.

    pb.window
    ---------
    pb.window.create(width, height, title)   -> Window
    pb.window.destroy(window)
    pb.window.should_close(window)           -> boolean
    pb.window.close(window)
    pb.window.swap_buffers(window)
    pb.window.poll_events()
    pb.window.get_size(window)               -> width, height
    pb.window.set_size(window, w, h)
    pb.window.set_title(window, title)
    pb.window.get_handle(window)             -> userdata
    pb.window.set_vsync(window, enabled)
    pb.window.get_vsync(window)              -> boolean
    pb.window.set_fullscreen(window, bool)
    pb.window.is_fullscreen(window)          -> boolean
    pb.window.toggle_fullscreen(window)
    pb.window.get_position(window)           -> x, y
    pb.window.set_position(window, x, y)
    pb.window.focus(window)
    pb.window.is_focused(window)             -> boolean
    pb.window.set_resizable(window, bool)
    -- Object-style also works: window:should_close(), window:get_size(), etc.

    pb.renderer
    -----------
    pb.renderer.init()                        -- Initialize (requires window)
    pb.renderer.clear(r, g, b, a?)            -- Clear screen
    pb.renderer.begin(width, height)          -- Begin 2D batch
    pb.renderer.finish()                      -- End 2D batch
    pb.renderer.flush()                       -- Flush without ending
    pb.renderer.pixel(x, y, color)            -- Draw a point
    pb.renderer.line(x1,y1, x2,y2, color)    -- Draw a line
    pb.renderer.rect(x, y, w, h, color)       -- Rectangle outline
    pb.renderer.rect_filled(x, y, w, h, color)
    pb.renderer.rect_gradient(x,y,w,h, top_color, bottom_color) -- Vertical gradient
    pb.renderer.circle(x, y, radius, color)
    pb.renderer.circle_filled(x, y, radius, color)
    pb.renderer.triangle(x1,y1,x2,y2,x3,y3, color)
    pb.renderer.triangle_filled(x1,y1,x2,y2,x3,y3, color)
    pb.renderer.set_point_size(size)
    pb.renderer.set_line_width(width)
    pb.renderer.color(r, g, b, a?)            -> color table (0.0-1.0 or hex)
    pb.renderer.color255(r, g, b, a?)         -> color table (0-255)
    pb.renderer.color_unpack(color)           -> r, g, b, a
    pb.renderer.begin_ui(w, h)                -- Begin screen-space UI (ignores camera)
    pb.renderer.end_ui()                      -- End screen-space UI
    pb.renderer.set_clear_color(r, g, b, a?)
    pb.renderer.enable_depth_test(enabled)
    pb.renderer.enable_blend(enabled)
    pb.renderer.set_viewport(x, y, w, h)
    pb.renderer.get_info()                    -> {version, renderer, vendor, glsl_version}
    -- Predefined colors: pb.renderer.colors.WHITE, RED, GREEN, BLUE, etc.

    pb.texture
    ----------
    pb.texture.load(filepath)                 -> Texture | nil, error
    pb.texture.create(w, h, data?)            -> Texture | nil, error
    pb.texture.flush()                        -- Flush pending texture draws
    -- Texture methods:
    texture:draw(x, y, w?, h?)
    texture:draw_tinted(x, y, w, h, r, g, b, a?)
    texture:draw_rotated(x, y, w, h, angle)
    texture:draw_ex(x, y, w, h, angle, ox, oy, r, g, b, a?)
    texture:draw_region(x, y, w, h, sx, sy, sw, sh)
    texture:draw_region_ex(x,y,w,h, sx,sy,sw,sh, angle,ox,oy, r,g,b,a?)
    texture:get_size()                        -> width, height
    texture:get_width()                       -> number
    texture:get_height()                      -> number
    texture:destroy()

    pb.input
    --------
    pb.input.is_key_pressed(key)              -> boolean
    pb.input.is_key_released(key)             -> boolean
    pb.input.is_mouse_button_pressed(button)  -> boolean
    pb.input.get_mouse_position()             -> x, y
    pb.input.set_mouse_position(x, y)
    pb.input.set_cursor_visible(visible)
    pb.input.set_cursor_locked(locked)
    -- Key constants: KEY_A..KEY_Z, KEY_0..KEY_9, KEY_SPACE, KEY_ESCAPE, etc.
    -- Mouse constants: MOUSE_LEFT, MOUSE_RIGHT, MOUSE_MIDDLE

    pb.audio
    --------
    pb.audio.load(filepath)                   -> Sound | nil, error
    pb.audio.set_master_volume(volume)
    pb.audio.get_master_volume()              -> number
    pb.audio.shutdown()
    -- Sound methods:
    sound:play()
    sound:stop()
    sound:pause()
    sound:resume()
    sound:is_playing()                        -> boolean
    sound:set_looping(bool)
    sound:is_looping()                        -> boolean
    sound:set_volume(vol)
    sound:get_volume()                        -> number
    sound:set_pitch(pitch)
    sound:get_pitch()                         -> number
    sound:destroy()

    pb.text
    -------
    pb.text.load(filepath, size?)             -> Font | nil, error
    pb.text.flush()                           -- Flush pending text draws
    -- Font methods:
    font:draw(text, x, y, color)
    font:measure(text)                        -> width, height
    font:set_size(size)
    font:get_size()                           -> number
    font:get_line_height()                    -> number
    font:destroy()

    pb.time
    -------
    pb.time.update()                          -- Call once per frame
    pb.time.delta()                           -> number (seconds since last frame)
    pb.time.get()                             -> number (seconds since start)
    pb.time.fps()                             -> number
    pb.time.sleep(seconds)                    -- Busy-wait sleep

    pb.camera
    ---------
    pb.camera.set_position(x, y)
    pb.camera.get_position()                  -> x, y
    pb.camera.move(dx, dy)
    pb.camera.set_zoom(zoom)
    pb.camera.get_zoom()                      -> number
    pb.camera.set_rotation(angle)
    pb.camera.get_rotation()                  -> number
    pb.camera.look_at(x, y, sw, sh)
    pb.camera.reset()
    pb.camera.screen_to_world(sx, sy)         -> wx, wy
    pb.camera.world_to_screen(wx, wy)         -> sx, sy

    pb.shader
    ---------
    pb.shader.create(vertex_src, fragment_src) -> Shader | nil, error
    pb.shader.load(vertex_path, fragment_path) -> Shader | nil, error
    pb.shader.unuse()                          -- Unbind current shader
    -- Shader methods:
    shader:use()
    shader:unuse()
    shader:set_int(name, value)
    shader:set_float(name, value)
    shader:set_vec2(name, x, y)
    shader:set_vec3(name, x, y, z)
    shader:set_vec4(name, x, y, z, w)
    shader:set_mat4(name, {m1..m16})           -- 16 floats, column-major
    shader:get_id()                            -> integer (GL program ID)
    shader:is_valid()                          -> boolean
    shader:destroy()

    pb.math
    -------
    pb.math.lerp(a, b, t)                     -> number
    pb.math.clamp(value, min, max)             -> number
    pb.math.radians(degrees)                   -> number
    pb.math.degrees(radians)                   -> number
    pb.math.vec2(x, y)                         -> {x, y}
    pb.math.vec3(x, y, z)                      -> {x, y, z}
    pb.math.vec4(x, y, z, w)                   -> {x, y, z, w}
    pb.math.vec_add(v1, v2)                    -> vector
    pb.math.vec_sub(v1, v2)                    -> vector
    pb.math.vec_scale(v, scalar)               -> vector
    pb.math.vec_length(v)                      -> number
    pb.math.vec_normalize(v)                   -> vector
    pb.math.vec_dot(v1, v2)                    -> number
    -- Constants: pb.math.PI, pb.math.TAU, pb.math.HALF_PI
]]

-- Example: Color cycling demo with gradient and UI overlay
package.cpath = "./?.so;" .. package.cpath
local pb = require("PudimBasicsGl")

local WIDTH = 640
local HEIGHT = 480

local window = pb.window.create(WIDTH, HEIGHT, "PudimBasicsGl API Reference")
if not window then
    print("Failed to create window!")
    return
end
pb.renderer.init()

local hue = 0

-- Helper: Convert HSV to RGB
local function hsvToRgb(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)

    i = i % 6
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end
    return r, g, b
end

print("Color cycling demo — press ESC to quit")

while not pb.window.should_close(window) do
    pb.time.update()
    local dt = pb.time.delta()

    hue = hue + dt * 0.5
    if hue > 1 then hue = hue - 1 end

    if pb.input.is_key_pressed(pb.input.KEY_ESCAPE) then
        pb.window.close(window)
    end

    local w, h = pb.window.get_size(window)

    -- Clear with animated color
    local r, g, b = hsvToRgb(hue, 0.7, 0.5)
    pb.renderer.clear(r, g, b, 1.0)
    pb.renderer.begin(w, h)

    -- Draw a gradient bar across the bottom
    local r2, g2, b2 = hsvToRgb((hue + 0.5) % 1.0, 0.8, 0.7)
    pb.renderer.rect_gradient(0, h - 60, w, 60, r, g, b, 1, r2, g2, b2, 1)

    pb.renderer.flush()

    -- Draw a UI overlay that stays fixed regardless of camera
    pb.renderer.begin_ui(w, h)
    pb.renderer.rect_filled(5, 5, 200, 22, 0, 0, 0, 0.6)
    pb.renderer.flush()
    pb.renderer.end_ui()

    pb.renderer.finish()

    pb.window.swap_buffers(window)
    pb.window.poll_events()
end

pb.window.destroy(window)
