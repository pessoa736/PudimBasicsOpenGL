#ifndef TEXTURE_H
#define TEXTURE_H

#include <glad/glad.h>

typedef struct {
    GLuint id;
    int width;
    int height;
    int channels;
} Texture;

// Load texture from file (PNG, JPG, BMP, etc.)
Texture* texture_load(const char* filepath);

// Create texture from raw RGBA data
Texture* texture_create(int width, int height, unsigned char* data);

// Destroy texture and free resources
void texture_destroy(Texture* texture);

// Bind texture for rendering
void texture_bind(Texture* texture, unsigned int slot);

// Unbind texture
void texture_unbind(void);

// Draw textured quad
void render_texture(Texture* texture, int x, int y, int width, int height);

// Draw textured quad with tint color
void render_texture_tinted(Texture* texture, int x, int y, int width, int height, 
                           float r, float g, float b, float a);

// Draw textured quad with rotation (angle in degrees)
void render_texture_rotated(Texture* texture, int x, int y, int width, int height, 
                            float angle);

// Draw textured quad with rotation and tint
void render_texture_ex(Texture* texture, int x, int y, int width, int height,
                       float angle, float origin_x, float origin_y,
                       float r, float g, float b, float a);

// Draw a portion of a texture (for sprite sheets)
void render_texture_region(Texture* texture, 
                           int x, int y, int width, int height,
                           int src_x, int src_y, int src_width, int src_height);

// Draw a portion with rotation and tint
void render_texture_region_ex(Texture* texture,
                              int x, int y, int width, int height,
                              int src_x, int src_y, int src_width, int src_height,
                              float angle, float origin_x, float origin_y,
                              float r, float g, float b, float a);

// Initialize texture rendering system (called after renderer_init)
void texture_renderer_init(void);

// Shutdown texture rendering system
void texture_renderer_shutdown(void);

// Flush any pending texture draws
void texture_renderer_flush(void);

#endif // TEXTURE_H
