#define STB_TRUETYPE_IMPLEMENTATION
#include "stb/stb_truetype.h"

#include "text.h"
#include "camera.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

// Text renderer shader sources (uses texture + color like texture.c)
static const char* text_vertex_shader_source =
    "#version 330 core\n"
    "layout (location = 0) in vec2 aPos;\n"
    "layout (location = 1) in vec2 aTexCoord;\n"
    "layout (location = 2) in vec4 aColor;\n"
    "out vec2 TexCoord;\n"
    "out vec4 Color;\n"
    "uniform mat4 projection;\n"
    "void main() {\n"
    "    gl_Position = projection * vec4(aPos, 0.0, 1.0);\n"
    "    TexCoord = aTexCoord;\n"
    "    Color = aColor;\n"
    "}\n";

static const char* text_fragment_shader_source =
    "#version 330 core\n"
    "in vec2 TexCoord;\n"
    "in vec4 Color;\n"
    "out vec4 FragColor;\n"
    "uniform sampler2D fontAtlas;\n"
    "void main() {\n"
    "    float alpha = texture(fontAtlas, TexCoord).r;\n"
    "    FragColor = vec4(Color.rgb, Color.a * alpha);\n"
    "}\n";

// Text renderer state
#define TEXT_MAX_VERTICES 65536
#define TEXT_VERTEX_SIZE 8  // x, y, u, v, r, g, b, a

typedef struct {
    GLuint vao;
    GLuint vbo;
    GLuint shader;
    GLint projection_loc;
    GLint texture_loc;
    float vertices[TEXT_MAX_VERTICES * TEXT_VERTEX_SIZE];
    int vertex_count;
    GLuint current_texture;
    int screen_width;
    int screen_height;
    int initialized;
} TextRendererState;

static TextRendererState text_state = {0};

static GLuint create_text_shader(void) {
    GLuint vertex_shader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertex_shader, 1, &text_vertex_shader_source, NULL);
    glCompileShader(vertex_shader);

    GLint success;
    char info_log[512];
    glGetShaderiv(vertex_shader, GL_COMPILE_STATUS, &success);
    if (!success) {
        glGetShaderInfoLog(vertex_shader, 512, NULL, info_log);
        fprintf(stderr, "[Text] Vertex shader error: %s\n", info_log);
    }

    GLuint fragment_shader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragment_shader, 1, &text_fragment_shader_source, NULL);
    glCompileShader(fragment_shader);

    glGetShaderiv(fragment_shader, GL_COMPILE_STATUS, &success);
    if (!success) {
        glGetShaderInfoLog(fragment_shader, 512, NULL, info_log);
        fprintf(stderr, "[Text] Fragment shader error: %s\n", info_log);
    }

    GLuint program = glCreateProgram();
    glAttachShader(program, vertex_shader);
    glAttachShader(program, fragment_shader);
    glLinkProgram(program);

    glGetProgramiv(program, GL_LINK_STATUS, &success);
    if (!success) {
        glGetProgramInfoLog(program, 512, NULL, info_log);
        fprintf(stderr, "[Text] Shader linking error: %s\n", info_log);
    }

    glDeleteShader(vertex_shader);
    glDeleteShader(fragment_shader);

    return program;
}

void text_renderer_init(void) {
    if (text_state.initialized) return;

    text_state.shader = create_text_shader();
    text_state.projection_loc = glGetUniformLocation(text_state.shader, "projection");
    text_state.texture_loc = glGetUniformLocation(text_state.shader, "fontAtlas");

    glGenVertexArrays(1, &text_state.vao);
    glGenBuffers(1, &text_state.vbo);

    glBindVertexArray(text_state.vao);
    glBindBuffer(GL_ARRAY_BUFFER, text_state.vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(text_state.vertices), NULL, GL_DYNAMIC_DRAW);

    // Position attribute (location 0)
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, TEXT_VERTEX_SIZE * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0);

    // Texture coord attribute (location 1)
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, TEXT_VERTEX_SIZE * sizeof(float), (void*)(2 * sizeof(float)));
    glEnableVertexAttribArray(1);

    // Color attribute (location 2)
    glVertexAttribPointer(2, 4, GL_FLOAT, GL_FALSE, TEXT_VERTEX_SIZE * sizeof(float), (void*)(4 * sizeof(float)));
    glEnableVertexAttribArray(2);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);

    text_state.vertex_count = 0;
    text_state.current_texture = 0;
    text_state.initialized = 1;

    printf("[Text] Text renderer initialized\n");
}

void text_renderer_shutdown(void) {
    if (!text_state.initialized) return;

    glDeleteVertexArrays(1, &text_state.vao);
    glDeleteBuffers(1, &text_state.vbo);
    glDeleteProgram(text_state.shader);
    text_state.initialized = 0;
}

void text_renderer_flush(void) {
    if (text_state.vertex_count == 0 || !text_state.initialized) return;

    // Enable alpha blending for text rendering
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    // Create projection * view matrix (incorporates camera transform)
    float projection[16];
    camera_get_matrix(projection, text_state.screen_width, text_state.screen_height);

    glUseProgram(text_state.shader);
    glUniformMatrix4fv(text_state.projection_loc, 1, GL_FALSE, projection);
    glUniform1i(text_state.texture_loc, 0);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, text_state.current_texture);

    glBindVertexArray(text_state.vao);
    glBindBuffer(GL_ARRAY_BUFFER, text_state.vbo);
    glBufferSubData(GL_ARRAY_BUFFER, 0, text_state.vertex_count * TEXT_VERTEX_SIZE * sizeof(float), text_state.vertices);

    glDrawArrays(GL_TRIANGLES, 0, text_state.vertex_count);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    glUseProgram(0);

    text_state.vertex_count = 0;
}

void text_renderer_set_screen_size(int width, int height) {
    text_state.screen_width = width;
    text_state.screen_height = height;
}

// Helper to add a textured vertex for text rendering
static void add_text_vertex(float x, float y, float u, float v, float r, float g, float b, float a) {
    if (text_state.vertex_count >= TEXT_MAX_VERTICES) {
        text_renderer_flush();
    }

    int idx = text_state.vertex_count * TEXT_VERTEX_SIZE;
    text_state.vertices[idx + 0] = x;
    text_state.vertices[idx + 1] = y;
    text_state.vertices[idx + 2] = u;
    text_state.vertices[idx + 3] = v;
    text_state.vertices[idx + 4] = r;
    text_state.vertices[idx + 5] = g;
    text_state.vertices[idx + 6] = b;
    text_state.vertices[idx + 7] = a;
    text_state.vertex_count++;
}

static void ensure_font_texture(GLuint texture_id) {
    if (text_state.current_texture != texture_id) {
        text_renderer_flush();
        text_state.current_texture = texture_id;
    }
}

// Rasterize font atlas at a given size using stb_truetype
static int rasterize_font(Font* font, float size) {
    stbtt_fontinfo info;
    if (!stbtt_InitFont(&info, font->font_data, stbtt_GetFontOffsetForIndex(font->font_data, 0))) {
        fprintf(stderr, "[Text] Failed to init font\n");
        return 0;
    }

    float scale = stbtt_ScaleForPixelHeight(&info, size);

    int ascent, descent, line_gap;
    stbtt_GetFontVMetrics(&info, &ascent, &descent, &line_gap);
    font->ascent = ascent * scale;
    font->descent = descent * scale;
    font->line_gap = line_gap * scale;
    font->line_height = font->ascent - font->descent + font->line_gap;
    font->font_size = size;

    // Determine atlas size — with 2x oversampling, effective size is doubled
    // so we need generous atlas dimensions
    int atlas_w, atlas_h;
    float effective = size * 2;  // account for 2x oversampling

    if (effective <= 64) {
        atlas_w = 512;  atlas_h = 512;
    } else if (effective <= 128) {
        atlas_w = 1024; atlas_h = 1024;
    } else if (effective <= 256) {
        atlas_w = 2048; atlas_h = 2048;
    } else {
        atlas_w = 4096; atlas_h = 4096;
    }

    unsigned char* atlas_bitmap = (unsigned char*)calloc(atlas_w * atlas_h, 1);
    if (!atlas_bitmap) {
        fprintf(stderr, "[Text] Failed to allocate atlas bitmap\n");
        return 0;
    }

    // Pack characters into atlas
    stbtt_pack_context pack_ctx;
    if (!stbtt_PackBegin(&pack_ctx, atlas_bitmap, atlas_w, atlas_h, 0, 1, NULL)) {
        fprintf(stderr, "[Text] Failed to begin font packing\n");
        free(atlas_bitmap);
        return 0;
    }

    stbtt_PackSetOversampling(&pack_ctx, 2, 2);

    stbtt_packedchar packed_chars[FONT_NUM_CHARS];
    if (!stbtt_PackFontRange(&pack_ctx, font->font_data, 0, size,
                             FONT_FIRST_CHAR, FONT_NUM_CHARS, packed_chars)) {
        fprintf(stderr, "[Text] Failed to pack font range\n");
        stbtt_PackEnd(&pack_ctx);
        free(atlas_bitmap);
        return 0;
    }

    stbtt_PackEnd(&pack_ctx);

    // Extract per-character metrics
    for (int i = 0; i < FONT_NUM_CHARS; i++) {
        stbtt_packedchar* pc = &packed_chars[i];
        font->advance_x[i] = pc->xadvance;
        font->offset_x[i] = pc->xoff;
        font->offset_y[i] = pc->yoff;
        font->width[i] = pc->xoff2 - pc->xoff;
        font->height[i] = pc->yoff2 - pc->yoff;
        font->uv_x0[i] = (float)pc->x0 / atlas_w;
        font->uv_y0[i] = (float)pc->y0 / atlas_h;
        font->uv_x1[i] = (float)pc->x1 / atlas_w;
        font->uv_y1[i] = (float)pc->y1 / atlas_h;
    }

    // Create or update OpenGL texture
    if (font->texture_id == 0) {
        glGenTextures(1, &font->texture_id);
    }

    glBindTexture(GL_TEXTURE_2D, font->texture_id);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    // Upload single-channel (RED) texture
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RED, atlas_w, atlas_h, 0, GL_RED, GL_UNSIGNED_BYTE, atlas_bitmap);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 4);

    glBindTexture(GL_TEXTURE_2D, 0);

    font->atlas_width = atlas_w;
    font->atlas_height = atlas_h;

    free(atlas_bitmap);
    return 1;
}

Font* font_load(const char* filepath, float size) {
    // Read font file
    FILE* f = fopen(filepath, "rb");
    if (!f) {
        fprintf(stderr, "[Text] Failed to open font file: %s\n", filepath);
        return NULL;
    }

    fseek(f, 0, SEEK_END);
    long file_size = ftell(f);
    fseek(f, 0, SEEK_SET);

    if (file_size <= 0) {
        fprintf(stderr, "[Text] Font file is empty: %s\n", filepath);
        fclose(f);
        return NULL;
    }

    unsigned char* font_data = (unsigned char*)malloc(file_size);
    if (!font_data) {
        fprintf(stderr, "[Text] Failed to allocate memory for font data\n");
        fclose(f);
        return NULL;
    }

    size_t read = fread(font_data, 1, file_size, f);
    fclose(f);

    if ((long)read != file_size) {
        fprintf(stderr, "[Text] Failed to read font file: %s\n", filepath);
        free(font_data);
        return NULL;
    }

    // Ensure text renderer is initialized
    text_renderer_init();

    Font* font = (Font*)calloc(1, sizeof(Font));
    if (!font) {
        free(font_data);
        return NULL;
    }

    font->font_data = font_data;
    font->font_data_size = file_size;
    font->texture_id = 0;

    if (!rasterize_font(font, size)) {
        free(font_data);
        free(font);
        return NULL;
    }

    printf("[Text] Loaded font: %s (size %.0f)\n", filepath, size);
    return font;
}

void font_destroy(Font* font) {
    if (!font) return;

    if (font->texture_id) {
        glDeleteTextures(1, &font->texture_id);
    }
    if (font->font_data) {
        free(font->font_data);
    }
    free(font);
}

int font_set_size(Font* font, float size) {
    if (!font || size <= 0) return 0;
    if (font->font_size == size) return 1;

    return rasterize_font(font, size);
}

void render_text(Font* font, const char* text, float x, float y, Color color) {
    if (!font || !text || !text_state.initialized) return;

    ensure_font_texture(font->texture_id);

    float cursor_x = x;
    float cursor_y = y + font->ascent;

    for (const char* p = text; *p; p++) {
        unsigned char c = (unsigned char)*p;

        // Handle newlines
        if (c == '\n') {
            cursor_x = x;
            cursor_y += font->line_height;
            continue;
        }

        // Handle tab as 4 spaces
        if (c == '\t') {
            int space_idx = ' ' - FONT_FIRST_CHAR;
            cursor_x += font->advance_x[space_idx] * 4;
            continue;
        }

        // Skip characters outside our range
        if (c < FONT_FIRST_CHAR || c >= FONT_FIRST_CHAR + FONT_NUM_CHARS) {
            continue;
        }

        int idx = c - FONT_FIRST_CHAR;

        float gx = cursor_x + font->offset_x[idx];
        float gy = cursor_y + font->offset_y[idx];
        float gw = font->width[idx];
        float gh = font->height[idx];

        float u0 = font->uv_x0[idx];
        float v0 = font->uv_y0[idx];
        float u1 = font->uv_x1[idx];
        float v1 = font->uv_y1[idx];

        // First triangle (top-left, top-right, bottom-right)
        add_text_vertex(gx, gy, u0, v0, color.r, color.g, color.b, color.a);
        add_text_vertex(gx + gw, gy, u1, v0, color.r, color.g, color.b, color.a);
        add_text_vertex(gx + gw, gy + gh, u1, v1, color.r, color.g, color.b, color.a);

        // Second triangle (top-left, bottom-right, bottom-left)
        add_text_vertex(gx, gy, u0, v0, color.r, color.g, color.b, color.a);
        add_text_vertex(gx + gw, gy + gh, u1, v1, color.r, color.g, color.b, color.a);
        add_text_vertex(gx, gy + gh, u0, v1, color.r, color.g, color.b, color.a);

        cursor_x += font->advance_x[idx];
    }
}

void text_measure(Font* font, const char* text, float* out_width, float* out_height) {
    if (!font || !text) {
        if (out_width) *out_width = 0;
        if (out_height) *out_height = 0;
        return;
    }

    float max_width = 0;
    float cursor_x = 0;
    int line_count = 1;

    for (const char* p = text; *p; p++) {
        unsigned char c = (unsigned char)*p;

        if (c == '\n') {
            if (cursor_x > max_width) max_width = cursor_x;
            cursor_x = 0;
            line_count++;
            continue;
        }

        if (c == '\t') {
            int space_idx = ' ' - FONT_FIRST_CHAR;
            cursor_x += font->advance_x[space_idx] * 4;
            continue;
        }

        if (c < FONT_FIRST_CHAR || c >= FONT_FIRST_CHAR + FONT_NUM_CHARS) {
            continue;
        }

        int idx = c - FONT_FIRST_CHAR;
        cursor_x += font->advance_x[idx];
    }

    if (cursor_x > max_width) max_width = cursor_x;

    if (out_width) *out_width = max_width;
    if (out_height) *out_height = line_count * font->line_height;
}
