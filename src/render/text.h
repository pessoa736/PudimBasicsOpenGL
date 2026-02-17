#ifndef TEXT_H
#define TEXT_H

#include <glad/glad.h>
#include "renderer.h"

// Maximum number of characters in the font atlas (ASCII 32-126)
#define FONT_FIRST_CHAR 32
#define FONT_NUM_CHARS 95
#define FONT_ATLAS_SIZE 512

typedef struct {
    // Per-character metrics
    float advance_x[FONT_NUM_CHARS];
    float offset_x[FONT_NUM_CHARS];
    float offset_y[FONT_NUM_CHARS];
    float width[FONT_NUM_CHARS];
    float height[FONT_NUM_CHARS];
    float uv_x0[FONT_NUM_CHARS];
    float uv_y0[FONT_NUM_CHARS];
    float uv_x1[FONT_NUM_CHARS];
    float uv_y1[FONT_NUM_CHARS];

    // Font info
    float font_size;
    float ascent;
    float descent;
    float line_gap;
    float line_height;

    // OpenGL texture atlas
    GLuint texture_id;
    int atlas_width;
    int atlas_height;

    // Raw font data (kept for re-rasterizing at different sizes)
    unsigned char* font_data;
    size_t font_data_size;
} Font;

// Load a TrueType font from file at a given pixel size
Font* font_load(const char* filepath, float size);

// Destroy font and free all resources
void font_destroy(Font* font);

// Change the font size (re-rasterizes the atlas)
int font_set_size(Font* font, float size);

// Render text at position with color
void render_text(Font* font, const char* text, float x, float y, Color color);

// Measure text dimensions without drawing
void text_measure(Font* font, const char* text, float* out_width, float* out_height);

// Initialize text rendering system (called lazily)
void text_renderer_init(void);

// Shutdown text rendering system
void text_renderer_shutdown(void);

// Flush pending text draws
void text_renderer_flush(void);

// Called by renderer_begin to update screen dimensions
void text_renderer_set_screen_size(int width, int height);

#endif // TEXT_H
