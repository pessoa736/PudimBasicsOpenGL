#ifndef RENDERER_H
#define RENDERER_H

#include <glad/glad.h>
#include <stdbool.h>

// Color structure
typedef struct {
    float r, g, b, a;
} Color;

// Predefined colors
#define COLOR_WHITE   (Color){1.0f, 1.0f, 1.0f, 1.0f}
#define COLOR_BLACK   (Color){0.0f, 0.0f, 0.0f, 1.0f}
#define COLOR_RED     (Color){1.0f, 0.0f, 0.0f, 1.0f}
#define COLOR_GREEN   (Color){0.0f, 1.0f, 0.0f, 1.0f}
#define COLOR_BLUE    (Color){0.0f, 0.0f, 1.0f, 1.0f}
#define COLOR_YELLOW  (Color){1.0f, 1.0f, 0.0f, 1.0f}
#define COLOR_CYAN    (Color){0.0f, 1.0f, 1.0f, 1.0f}
#define COLOR_MAGENTA (Color){1.0f, 0.0f, 1.0f, 1.0f}
#define COLOR_ORANGE  (Color){1.0f, 0.5f, 0.0f, 1.0f}
#define COLOR_PURPLE  (Color){0.5f, 0.0f, 0.5f, 1.0f}

// Color helpers
Color color_rgb(int r, int g, int b);
Color color_rgba(int r, int g, int b, int a);
Color color_hex(unsigned int hex);

// Core renderer functions
void renderer_init(void);
void renderer_shutdown(void);
void renderer_clear(float r, float g, float b, float a);
void renderer_set_viewport(int x, int y, int width, int height);

// 2D Drawing functions
void renderer_begin(int screen_width, int screen_height);
void renderer_end(void);
void renderer_flush(void);

// Primitive drawing
void render_pixel(int x, int y, Color color);
void render_line(int x1, int y1, int x2, int y2, Color color);
void render_rect(int x, int y, int width, int height, Color color);
void render_rect_filled(int x, int y, int width, int height, Color color);
void render_circle(int cx, int cy, int radius, Color color);
void render_circle_filled(int cx, int cy, int radius, Color color);
void render_triangle(int x1, int y1, int x2, int y2, int x3, int y3, Color color);
void render_triangle_filled(int x1, int y1, int x2, int y2, int x3, int y3, Color color);

// Set point/line size
void render_set_point_size(float size);
void render_set_line_width(float width);

// UI rendering (screen-space, ignores camera)
void renderer_begin_ui(int screen_width, int screen_height);
void renderer_end_ui(void);

// Shared rendering state — queried by text/texture renderers
int renderer_is_ui_mode(void);
void renderer_get_ui_projection(float* out, int screen_width, int screen_height);

// Active batch tracking — ensures correct draw order across renderers
typedef enum {
    BATCH_NONE = 0,
    BATCH_PRIMITIVES,
    BATCH_TEXTURES,
    BATCH_TEXT
} ActiveBatchType;

// Call before adding geometry to a batch. Automatically flushes the previous
// batch if a different renderer was active, preserving painter's-algorithm order.
void renderer_switch_batch(ActiveBatchType new_batch);

// Gradient rectangle
void render_rect_gradient(int x, int y, int width, int height, Color top_color, Color bottom_color);

// Read a pixel from the framebuffer (for testing / color picking)
// Returns RGBA values in the range 0-255. Coordinates are screen-space.
void renderer_read_pixel(int x, int y, int screen_height, unsigned char* r, unsigned char* g, unsigned char* b, unsigned char* a);

#endif // RENDERER_H
