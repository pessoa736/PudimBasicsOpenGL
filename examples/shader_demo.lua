-- PudimBasicsGl Shader Demo
-- This example demonstrates custom shader creation and uniform control
-- A full-screen quad with an animated color wave effect

local pb = require("PudimBasicsGl")

local WIDTH = 800
local HEIGHT = 600

-- Create window
local window = pb.window.create(WIDTH, HEIGHT, "PudimBasicsGl Shader Demo")
if not window then
    print("Failed to create window!")
    return
end

-- Initialize renderer
pb.renderer.init()

-- ─── Shader sources ─────────────────────────────────────────────────────────

-- Simple passthrough vertex shader
local vertex_src = [[
#version 330 core
layout(location = 0) in vec2 aPos;

out vec2 fragCoord;

void main() {
    fragCoord = aPos * 0.5 + 0.5;   // map [-1,1] → [0,1]
    gl_Position = vec4(aPos, 0.0, 1.0);
}
]]

-- Animated color-wave fragment shader
local fragment_src = [[
#version 330 core
in vec2 fragCoord;
out vec4 FragColor;

uniform float     uTime;
uniform vec2      uResolution;
uniform vec3      uColor1;
uniform vec3      uColor2;

void main() {
    vec2 uv = fragCoord;

    // Create animated wave pattern
    float wave = sin(uv.x * 10.0 + uTime * 2.0) * 0.5 + 0.5;
    wave *= cos(uv.y * 8.0 - uTime * 1.5) * 0.5 + 0.5;

    // Mix the two user-controlled colors
    vec3 color = mix(uColor1, uColor2, wave);

    // Add a subtle radial vignette
    float dist = length(uv - 0.5) * 1.4;
    color *= 1.0 - dist * dist * 0.5;

    FragColor = vec4(color, 1.0);
}
]]

-- ─── Compile the shader ─────────────────────────────────────────────────────

local shader, err = pb.shader.create(vertex_src, fragment_src)
if not shader then
    print("Shader error: " .. tostring(err))
    pb.window.destroy(window)
    return
end
print(string.format("Shader compiled! (program id = %d)", shader:get_id()))

-- ─── Full-screen quad (two triangles covering clip-space) ───────────────────
-- We'll draw it manually with OpenGL via the renderer low-level API

-- Color palette (user can tweak these)
local color1 = { 0.1, 0.4, 0.8 }   -- blue
local color2 = { 1.0, 0.3, 0.6 }   -- pink
local palette_index = 1

local palettes = {
    { { 0.1, 0.4, 0.8 }, { 1.0, 0.3, 0.6 } },  -- blue/pink
    { { 0.0, 0.8, 0.4 }, { 1.0, 0.9, 0.0 } },  -- green/yellow
    { { 0.9, 0.2, 0.1 }, { 0.1, 0.1, 0.3 } },  -- red/dark blue
    { { 1.0, 0.5, 0.0 }, { 0.0, 0.7, 1.0 } },  -- orange/cyan
}

print("Controls:")
print("  SPACE  — Cycle color palette")
print("  ESC    — Quit")

-- ─── Main loop ──────────────────────────────────────────────────────────────

while not pb.window.should_close(window) do
    pb.time.update()
    local dt = pb.time.delta()
    local time = pb.time.get()

    -- ── Input ───────────────────────────────────────────────────────────────
    if pb.input.is_key_pressed(pb.input.KEY_ESCAPE) then
        pb.window.close(window)
    end

    -- Cycle palette (simple debounce via KEY_RELEASED would be better,
    -- but for a demo we use a small cooldown)
    if pb.input.is_key_pressed(pb.input.KEY_SPACE) then
        palette_index = (palette_index % #palettes) + 1
        color1 = palettes[palette_index][1]
        color2 = palettes[palette_index][2]
    end

    local w, h = pb.window.get_size(window)

    -- ── Render ──────────────────────────────────────────────────────────────
    pb.renderer.clear(0.0, 0.0, 0.0, 1.0)
    pb.renderer.begin(w, h)

    -- Activate our custom shader and set uniforms
    shader:use()
    shader:set_float("uTime", time)
    shader:set_vec2("uResolution", w, h)
    shader:set_vec3("uColor1", color1[1], color1[2], color1[3])
    shader:set_vec3("uColor2", color2[1], color2[2], color2[3])

    -- Draw a full-screen quad using the renderer's primitives
    -- (the shader overrides the default vertex/fragment pipeline)
    pb.renderer.rect_filled(0, 0, w, h, 1, 1, 1, 1)
    pb.renderer.flush()

    -- Restore the default shader so text/primitives keep working
    shader:unuse()

    -- Draw some info text with primitives (on top of the shader effect)
    local info = string.format("Palette %d/%d | FPS: %.0f", palette_index, #palettes, pb.time.fps())
    -- Simple dark bar behind text
    pb.renderer.rect_filled(5, h - 25, 280, 20, 0, 0, 0, 0.6)
    pb.renderer.flush()

    pb.renderer.finish()

    pb.window.swap_buffers(window)
    pb.window.poll_events()

    -- Update title
    pb.window.set_title(window, string.format("PudimBasicsGl Shader Demo - FPS: %.1f", pb.time.fps()))
end

-- ─── Cleanup ────────────────────────────────────────────────────────────────
shader:destroy()
pb.window.destroy(window)
print("Shader demo finished!")
