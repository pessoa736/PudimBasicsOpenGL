// UI — Immediate Mode GUI system for PudimBasicsGl
// Provides panels, buttons, sliders and labels drawn with the engine's
// primitive and text renderers, reading mouse input via GLFW.

#include "ui.h"
#include "renderer.h"
#include "text.h"
#include "../platform/window.h"

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

#include <string.h>
#include <stdio.h>

// ---------------------------------------------------------------------------
// Internal state
// ---------------------------------------------------------------------------

// Get active window from lua_window.c
extern Window* pudim_get_active_window(void);

static Font* g_ui_font = NULL;

static double g_mouse_x = 0;
static double g_mouse_y = 0;
static int    g_mouse_down = 0;
static int    g_mouse_pressed = 0;  // just pressed this frame
static int    g_last_mouse_down = 0;

// Widget identity — simple FNV-1a hash of the string id
static unsigned int g_active_id = 0;
static unsigned int g_hot_id = 0;

static int g_initialized = 0;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

static unsigned int hash_id(const char* str) {
    unsigned int hash = 2166136261u;
    while (*str) {
        hash ^= (unsigned char)*str++;
        hash *= 16777619u;
    }
    return hash;
}

static int point_in_rect(double px, double py, float rx, float ry, float rw, float rh) {
    return (px >= rx && px <= rx + rw && py >= ry && py <= ry + rh);
}

static float clampf(float v, float lo, float hi) {
    if (v < lo) return lo;
    if (v > hi) return hi;
    return v;
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

void ui_init(void) {
    // NOTE: do NOT reset g_ui_font here — set_font may be called before the
    // first begin_frame, and ui_init is invoked lazily from begin_frame.
    g_active_id = 0;
    g_hot_id = 0;
    g_mouse_x = 0;
    g_mouse_y = 0;
    g_mouse_down = 0;
    g_mouse_pressed = 0;
    g_last_mouse_down = 0;
    g_initialized = 1;
}

void ui_shutdown(void) {
    g_ui_font = NULL;
    g_initialized = 0;
}

void ui_set_font(Font* font) {
    g_ui_font = font;
}

void ui_begin_frame(void) {
    if (!g_initialized) ui_init();

    Window* win = pudim_get_active_window();
    if (win && win->handle) {
        glfwGetCursorPos(win->handle, &g_mouse_x, &g_mouse_y);
        int btn = glfwGetMouseButton(win->handle, GLFW_MOUSE_BUTTON_LEFT);
        g_mouse_down = (btn == GLFW_PRESS);
    } else {
        g_mouse_x = 0;
        g_mouse_y = 0;
        g_mouse_down = 0;
    }

    g_mouse_pressed = g_mouse_down && !g_last_mouse_down;
    g_hot_id = 0;
}

void ui_end_frame(void) {
    if (!g_mouse_down) {
        g_active_id = 0;
    }
    g_last_mouse_down = g_mouse_down;

    // Flush all pending draws so the UI layer is fully committed
    renderer_flush();
    text_renderer_flush();
}

// pudim.ui.label(text, x, y, r, g, b, a)
void ui_label(const char* text, float x, float y, float r, float g, float b, float a) {
    if (!g_ui_font) return;

    // Flush primitives first so they sit behind the text
    renderer_flush();

    Color c = {r, g, b, a};
    render_text(g_ui_font, text, x, y, c);

    // Flush text immediately so it respects draw order with later primitives
    text_renderer_flush();
}

// pudim.ui.panel(title, x, y, w, h)
void ui_panel(const char* title, float x, float y, float w, float h) {
    // Background
    render_rect_filled((int)x, (int)y, (int)w, (int)h,
                       (Color){0.16f, 0.17f, 0.20f, 1.0f});
    // Header bar
    render_rect_filled((int)x, (int)y, (int)w, 30,
                       (Color){0.10f, 0.11f, 0.14f, 1.0f});
    // Border
    render_rect((int)x, (int)y, (int)w, (int)h,
                (Color){0.30f, 0.30f, 0.35f, 1.0f});

    if (title) {
        ui_label(title, x + 10, y + 8, 0.8f, 0.8f, 0.8f, 1.0f);
    }
}

// pudim.ui.button(id, label, x, y, w, h, r, g, b) -> clicked
int ui_button(const char* id, const char* label, float x, float y, float w, float h, float r, float g, float b) {
    unsigned int wid = hash_id(id);
    int hover = point_in_rect(g_mouse_x, g_mouse_y, x, y, w, h);

    if (hover) {
        g_hot_id = wid;
        if (g_mouse_pressed) {
            g_active_id = wid;
        }
    }

    float mult = 1.0f;
    if (g_hot_id == wid) {
        mult = 1.3f;
        if (g_active_id == wid) {
            mult = 0.7f;
        }
    }

    float cr = clampf(r * mult, 0.0f, 1.0f);
    float cg = clampf(g * mult, 0.0f, 1.0f);
    float cb = clampf(b * mult, 0.0f, 1.0f);

    render_rect_filled((int)x, (int)y, (int)w, (int)h,
                       (Color){cr, cg, cb, 1.0f});
    render_rect((int)x, (int)y, (int)w, (int)h,
                (Color){0.4f, 0.4f, 0.4f, 1.0f});

    if (g_ui_font && label) {
        float tw = 0, th = 0;
        text_measure(g_ui_font, label, &tw, &th);
        float text_x = x + (w / 2.0f) - (tw / 2.0f);
        float text_y = y + (h / 2.0f) - (th / 2.0f) - 4.0f;
        ui_label(label, text_x, text_y, 1.0f, 1.0f, 1.0f, 1.0f);
    }

    // Click fires on release while hovering the hot item
    if (!g_mouse_down && g_hot_id == wid && g_active_id == wid) {
        return 1;
    }
    return 0;
}

// pudim.ui.slider(id, label, x, y, w, h, value, min, max) -> value
float ui_slider(const char* id, const char* label, float x, float y, float w, float h, float value, float min_val, float max_val) {
    unsigned int wid = hash_id(id);
    int hover = point_in_rect(g_mouse_x, g_mouse_y, x, y, w, h);

    if (hover) {
        g_hot_id = wid;
        if (g_mouse_pressed) {
            g_active_id = wid;
        }
    }

    // Drag updates value
    if (g_active_id == wid) {
        float percent = (float)(g_mouse_x - (double)x) / w;
        percent = clampf(percent, 0.0f, 1.0f);
        value = min_val + percent * (max_val - min_val);
    }

    // Background
    render_rect_filled((int)x, (int)y, (int)w, (int)h,
                       (Color){0.10f, 0.10f, 0.10f, 1.0f});

    // Fill bar
    float fill_w = ((value - min_val) / (max_val - min_val)) * w;
    float bar_c = (g_active_id == wid) ? 0.8f : 0.5f;
    render_rect_filled((int)x, (int)y, (int)fill_w, (int)h,
                       (Color){bar_c, bar_c, 0.9f, 1.0f});

    // Border
    render_rect((int)x, (int)y, (int)w, (int)h,
                (Color){0.3f, 0.3f, 0.3f, 1.0f});

    // Label with current value
    if (g_ui_font && label) {
        char buf[128];
        snprintf(buf, sizeof(buf), "%s: %.2f", label, value);
        float tw = 0, th = 0;
        text_measure(g_ui_font, buf, &tw, &th);
        ui_label(buf, x + 8.0f, y + (h / 2.0f) - (th / 2.0f) - 2.0f, 1.0f, 1.0f, 1.0f, 1.0f);
    }

    return value;
}
