--[[
    PudimEngine Lua API Reference
    =============================
    
    All APIs are under the 'pudim' namespace.
    
    pudim.window
    ------------
    pudim.window.get_size()              -> width, height
    pudim.window.get_title()             -> string
    pudim.window.set_title(title)
    pudim.window.should_close()          -> boolean
    pudim.window.close()
    
    pudim.renderer
    --------------
    pudim.renderer.clear(r, g, b, a?)    -- Clear screen with color
    pudim.renderer.set_clear_color(r, g, b, a?)
    pudim.renderer.enable_depth_test(enable)
    pudim.renderer.enable_blend(enable)
    pudim.renderer.set_viewport(x, y, width, height)
    pudim.renderer.get_info()            -> table {version, renderer, vendor, glsl_version}
    pudim.renderer.draw_arrays(mode, first, count)
    
    -- Drawing mode constants:
    pudim.renderer.POINTS
    pudim.renderer.LINES
    pudim.renderer.LINE_STRIP
    pudim.renderer.TRIANGLES
    pudim.renderer.TRIANGLE_STRIP
    pudim.renderer.TRIANGLE_FAN
    
    pudim.input
    -----------
    pudim.input.is_key_pressed(key)      -> boolean
    pudim.input.is_key_released(key)     -> boolean
    pudim.input.is_mouse_button_pressed(button) -> boolean
    pudim.input.get_mouse_position()     -> x, y
    pudim.input.set_mouse_position(x, y)
    pudim.input.set_cursor_visible(visible)
    pudim.input.set_cursor_locked(locked)
    
    -- Key constants:
    pudim.input.KEY_SPACE, KEY_ESCAPE, KEY_ENTER, KEY_TAB, KEY_BACKSPACE
    pudim.input.KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT
    pudim.input.KEY_W, KEY_A, KEY_S, KEY_D (and all letters A-Z)
    pudim.input.KEY_0 through KEY_9
    pudim.input.KEY_F1 through KEY_F12
    pudim.input.KEY_LEFT_SHIFT, KEY_RIGHT_SHIFT
    pudim.input.KEY_LEFT_CTRL, KEY_RIGHT_CTRL
    pudim.input.KEY_LEFT_ALT, KEY_RIGHT_ALT
    
    -- Mouse button constants:
    pudim.input.MOUSE_LEFT
    pudim.input.MOUSE_RIGHT
    pudim.input.MOUSE_MIDDLE
    
    pudim.time
    ----------
-- Examples:
-- local t1 = pudim.time.get()
-- local t2 = pudim.time:get()          -- method-style call
-- pudim.time.update()
-- pudim.time:update()                 -- method-style call
    pudim.time.fps()                     -> number (current FPS)
    pudim.time.sleep(seconds)            -- Pause execution
    
    pudim.math
    ----------
    pudim.math.lerp(a, b, t)             -> number
    pudim.math.clamp(value, min, max)    -> number
    pudim.math.radians(degrees)          -> number
    pudim.math.degrees(radians)          -> number
    pudim.math.vec2(x, y)                -> {x, y}
    pudim.math.vec3(x, y, z)             -> {x, y, z}
    pudim.math.vec4(x, y, z, w)          -> {x, y, z, w}
    pudim.math.vec_add(v1, v2)           -> vector
    pudim.math.vec_sub(v1, v2)           -> vector
    pudim.math.vec_scale(v, scalar)      -> vector
    pudim.math.vec_length(v)             -> number
    pudim.math.vec_normalize(v)          -> vector
    pudim.math.vec_dot(v1, v2)           -> number
    
    -- Math constants:
    pudim.math.PI
    pudim.math.TAU (2*PI)
    pudim.math.HALF_PI
    
    Game Loop Functions (implement these in your script)
    ----------------------------------------------------
    function init()      -- Called once at startup
    function update(dt)  -- Called every frame with delta time
    function draw()      -- Called every frame for rendering
    function shutdown()  -- Called when game closes
]]

-- Example: Simple color cycling demo
-- Note: For a complete OOP-style demo, see `examples/oop_demo.lua` which demonstrates
-- usage of `window:should_close()`, `texture:draw()` and `time:update()` in a loop.
local hue = 0

function init()
    print("API Reference loaded!")
    print("This is a simple color cycling demo")
end

function update(dt)
    hue = hue + dt * 0.5
    if hue > 1 then hue = hue - 1 end
    
    if pudim.input.is_key_pressed(pudim.input.KEY_ESCAPE) then
        pudim.window.close()
    end
end

function draw()
    -- HSV to RGB conversion (simplified)
    local r, g, b = hsvToRgb(hue, 0.7, 0.5)
    pudim.renderer.clear(r, g, b, 1)
end

-- Helper: Convert HSV to RGB
function hsvToRgb(h, s, v)
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
