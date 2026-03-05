#include "renderer.h"
#include "texture.h"
#include "camera.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

// External function from texture.c
extern void texture_renderer_set_screen_size(int width, int height);
extern void texture_renderer_flush(void);

// External function from text.c
extern void text_renderer_set_screen_size(int width, int height);
extern void text_renderer_flush(void);

// Shader sources
static const char* vertex_shader_src = 
    "#version 330 core\n"
    "layout (location = 0) in vec2 aPos;\n"
    "layout (location = 1) in vec4 aColor;\n"
    "out vec4 vertexColor;\n"
    "uniform mat4 projection;\n"
    "void main() {\n"
    "    gl_Position = projection * vec4(aPos, 0.0, 1.0);\n"
    "    vertexColor = aColor;\n"
    "}\n";

static const char* fragment_shader_src = 
    "#version 330 core\n"
    "in vec4 vertexColor;\n"
    "out vec4 FragColor;\n"
    "void main() {\n"
    "    FragColor = vertexColor;\n"
    "}\n";

// Batch rendering
#define MAX_VERTICES 65536
#define VERTEX_SIZE 6  // x, y, r, g, b, a

typedef struct {
    GLuint vao;
    GLuint vbo;
    GLuint shader;
    GLint projection_loc;
    
    float vertices[MAX_VERTICES * VERTEX_SIZE];
    int vertex_count;
    GLenum current_mode;
    
    int screen_width;
    int screen_height;
} RendererState;

static RendererState state = {0};

// Active batch tracking for draw-order preservation across renderers
static ActiveBatchType g_active_batch = BATCH_NONE;

// Shader compilation helper
static GLuint compile_shader(GLenum type, const char* source) {
    GLuint shader = glCreateShader(type);
    glShaderSource(shader, 1, &source, NULL);
    glCompileShader(shader);
    
    GLint success;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
    if (!success) {
        char info[512];
        glGetShaderInfoLog(shader, 512, NULL, info);
        fprintf(stderr, "Shader compilation error: %s\n", info);
    }
    return shader;
}

static GLuint create_shader_program(void) {
    GLuint vertex = compile_shader(GL_VERTEX_SHADER, vertex_shader_src);
    GLuint fragment = compile_shader(GL_FRAGMENT_SHADER, fragment_shader_src);
    
    GLuint program = glCreateProgram();
    glAttachShader(program, vertex);
    glAttachShader(program, fragment);
    glLinkProgram(program);
    
    GLint success;
    glGetProgramiv(program, GL_LINK_STATUS, &success);
    if (!success) {
        char info[512];
        glGetProgramInfoLog(program, 512, NULL, info);
        fprintf(stderr, "Shader linking error: %s\n", info);
    }
    
    glDeleteShader(vertex);
    glDeleteShader(fragment);
    
    return program;
}

// Color helpers
Color color_rgb(int r, int g, int b) {
    return (Color){r / 255.0f, g / 255.0f, b / 255.0f, 1.0f};
}

Color color_rgba(int r, int g, int b, int a) {
    return (Color){r / 255.0f, g / 255.0f, b / 255.0f, a / 255.0f};
}

Color color_hex(unsigned int hex) {
    return (Color){
        ((hex >> 16) & 0xFF) / 255.0f,
        ((hex >> 8) & 0xFF) / 255.0f,
        (hex & 0xFF) / 255.0f,
        1.0f
    };
}

void renderer_init(void) {
    // Create shader program
    state.shader = create_shader_program();
    state.projection_loc = glGetUniformLocation(state.shader, "projection");
    
    // Create VAO and VBO
    glGenVertexArrays(1, &state.vao);
    glGenBuffers(1, &state.vbo);
    
    glBindVertexArray(state.vao);
    glBindBuffer(GL_ARRAY_BUFFER, state.vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(state.vertices), NULL, GL_DYNAMIC_DRAW);
    
    // Position attribute (location 0)
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, VERTEX_SIZE * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0);
    
    // Color attribute (location 1)
    glVertexAttribPointer(1, 4, GL_FLOAT, GL_FALSE, VERTEX_SIZE * sizeof(float), (void*)(2 * sizeof(float)));
    glEnableVertexAttribArray(1);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    
    // Enable features
    glDisable(GL_DEPTH_TEST);
    glDepthMask(GL_FALSE);  // Don't write to depth buffer (2D engine)
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_PROGRAM_POINT_SIZE);
    
    state.vertex_count = 0;
    state.current_mode = GL_POINTS;
    
    printf("[Renderer] Initialized with batch rendering\n");
}

void renderer_shutdown(void) {
    glDeleteVertexArrays(1, &state.vao);
    glDeleteBuffers(1, &state.vbo);
    glDeleteProgram(state.shader);
}

void renderer_clear(float r, float g, float b, float a) {
    glClearColor(r, g, b, a);
    glClear(GL_COLOR_BUFFER_BIT);
}

void renderer_set_viewport(int x, int y, int width, int height) {
    glViewport(x, y, width, height);
}

void renderer_begin(int screen_width, int screen_height) {
    state.screen_width = screen_width;
    state.screen_height = screen_height;
    state.vertex_count = 0;
    g_active_batch = BATCH_NONE;
    
    // Update texture renderer screen size too
    texture_renderer_set_screen_size(screen_width, screen_height);
    
    // Update text renderer screen size too
    text_renderer_set_screen_size(screen_width, screen_height);
    
    // Create projection * view matrix (incorporates camera transform)
    float projection[16];
    camera_get_matrix(projection, screen_width, screen_height);
    
    glUseProgram(state.shader);
    glUniformMatrix4fv(state.projection_loc, 1, GL_FALSE, projection);
}

void renderer_flush(void) {
    if (state.vertex_count == 0) return;
    
    glUseProgram(state.shader);
    glBindVertexArray(state.vao);
    glBindBuffer(GL_ARRAY_BUFFER, state.vbo);
    glBufferSubData(GL_ARRAY_BUFFER, 0, state.vertex_count * VERTEX_SIZE * sizeof(float), state.vertices);
    
    glDrawArrays(state.current_mode, 0, state.vertex_count);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    
    state.vertex_count = 0;
}

void renderer_end(void) {
    renderer_flush();
    glUseProgram(0);
}

// Internal: add vertex to batch
static void add_vertex(float x, float y, Color color) {
    if (state.vertex_count >= MAX_VERTICES) {
        renderer_flush();
    }
    
    int idx = state.vertex_count * VERTEX_SIZE;
    state.vertices[idx + 0] = x;
    state.vertices[idx + 1] = y;
    state.vertices[idx + 2] = color.r;
    state.vertices[idx + 3] = color.g;
    state.vertices[idx + 4] = color.b;
    state.vertices[idx + 5] = color.a;
    state.vertex_count++;
}

static void set_mode(GLenum mode) {
    renderer_switch_batch(BATCH_PRIMITIVES);
    if (state.current_mode != mode) {
        renderer_flush();
        state.current_mode = mode;
    }
}

void render_set_point_size(float size) {
    glPointSize(size);
}

void render_set_line_width(float width) {
    glLineWidth(width);
}

void render_pixel(int x, int y, Color color) {
    set_mode(GL_POINTS);
    add_vertex((float)x + 0.5f, (float)y + 0.5f, color);
}

void render_line(int x1, int y1, int x2, int y2, Color color) {
    set_mode(GL_LINES);
    add_vertex((float)x1, (float)y1, color);
    add_vertex((float)x2, (float)y2, color);
}

void render_rect(int x, int y, int width, int height, Color color) {
    set_mode(GL_LINES);
    // Top
    add_vertex((float)x, (float)y, color);
    add_vertex((float)(x + width), (float)y, color);
    // Right
    add_vertex((float)(x + width), (float)y, color);
    add_vertex((float)(x + width), (float)(y + height), color);
    // Bottom
    add_vertex((float)(x + width), (float)(y + height), color);
    add_vertex((float)x, (float)(y + height), color);
    // Left
    add_vertex((float)x, (float)(y + height), color);
    add_vertex((float)x, (float)y, color);
}

void render_rect_filled(int x, int y, int width, int height, Color color) {
    set_mode(GL_TRIANGLES);
    float fx = (float)x;
    float fy = (float)y;
    float fw = (float)width;
    float fh = (float)height;
    
    // First triangle
    add_vertex(fx, fy, color);
    add_vertex(fx + fw, fy, color);
    add_vertex(fx + fw, fy + fh, color);
    
    // Second triangle
    add_vertex(fx, fy, color);
    add_vertex(fx + fw, fy + fh, color);
    add_vertex(fx, fy + fh, color);
}

void render_circle(int cx, int cy, int radius, Color color) {
    set_mode(GL_LINES);
    int segments = radius < 10 ? 16 : (radius < 50 ? 32 : 64);
    float angle_step = 2.0f * 3.14159265f / segments;
    
    for (int i = 0; i < segments; i++) {
        float angle1 = i * angle_step;
        float angle2 = (i + 1) * angle_step;
        
        float x1 = cx + cosf(angle1) * radius;
        float y1 = cy + sinf(angle1) * radius;
        float x2 = cx + cosf(angle2) * radius;
        float y2 = cy + sinf(angle2) * radius;
        
        add_vertex(x1, y1, color);
        add_vertex(x2, y2, color);
    }
}

void render_circle_filled(int cx, int cy, int radius, Color color) {
    set_mode(GL_TRIANGLES);
    int segments = radius < 10 ? 16 : (radius < 50 ? 32 : 64);
    float angle_step = 2.0f * 3.14159265f / segments;
    
    for (int i = 0; i < segments; i++) {
        float angle1 = i * angle_step;
        float angle2 = (i + 1) * angle_step;
        
        add_vertex((float)cx, (float)cy, color);
        add_vertex(cx + cosf(angle1) * radius, cy + sinf(angle1) * radius, color);
        add_vertex(cx + cosf(angle2) * radius, cy + sinf(angle2) * radius, color);
    }
}

void render_triangle(int x1, int y1, int x2, int y2, int x3, int y3, Color color) {
    set_mode(GL_LINES);
    add_vertex((float)x1, (float)y1, color);
    add_vertex((float)x2, (float)y2, color);
    
    add_vertex((float)x2, (float)y2, color);
    add_vertex((float)x3, (float)y3, color);
    
    add_vertex((float)x3, (float)y3, color);
    add_vertex((float)x1, (float)y1, color);
}

void render_triangle_filled(int x1, int y1, int x2, int y2, int x3, int y3, Color color) {
    set_mode(GL_TRIANGLES);
    add_vertex((float)x1, (float)y1, color);
    add_vertex((float)x2, (float)y2, color);
    add_vertex((float)x3, (float)y3, color);
}

// --- Active batch tracking (draw-order preservation) ---

void renderer_switch_batch(ActiveBatchType new_batch) {
    if (g_active_batch == new_batch) return;

    // Flush the previously-active batch so its geometry renders first
    switch (g_active_batch) {
        case BATCH_PRIMITIVES: renderer_flush(); break;
        case BATCH_TEXTURES:   texture_renderer_flush(); break;
        case BATCH_TEXT:        text_renderer_flush(); break;
        default: break;
    }

    g_active_batch = new_batch;
}

// --- Shared UI mode state ---

static int g_ui_mode = 0;

int renderer_is_ui_mode(void) {
    return g_ui_mode;
}

void renderer_get_ui_projection(float* out, int screen_width, int screen_height) {
    float sw = (float)screen_width;
    float sh = (float)screen_height;
    // Plain orthographic projection (no camera transform)
    out[0]  =  2.0f / sw; out[1]  =  0.0f;       out[2]  = 0.0f;  out[3]  = 0.0f;
    out[4]  =  0.0f;      out[5]  = -2.0f / sh;  out[6]  = 0.0f;  out[7]  = 0.0f;
    out[8]  =  0.0f;      out[9]  =  0.0f;       out[10] = -1.0f; out[11] = 0.0f;
    out[12] = -1.0f;      out[13] =  1.0f;       out[14] =  0.0f; out[15] = 1.0f;
}

// --- UI Rendering (screen-space, ignores camera) ---

void renderer_begin_ui(int screen_width, int screen_height) {
    // Flush any pending world-space geometry first
    renderer_flush();
    texture_renderer_flush();
    text_renderer_flush();
    g_active_batch = BATCH_NONE;

    // Enter UI mode
    g_ui_mode = 1;

    // Update screen dimensions for ALL renderers
    state.screen_width = screen_width;
    state.screen_height = screen_height;
    texture_renderer_set_screen_size(screen_width, screen_height);
    text_renderer_set_screen_size(screen_width, screen_height);

    // Build a plain orthographic projection (no camera transform)
    float projection[16];
    renderer_get_ui_projection(projection, screen_width, screen_height);

    glUseProgram(state.shader);
    glUniformMatrix4fv(state.projection_loc, 1, GL_FALSE, projection);
}

void renderer_end_ui(void) {
    // Flush ALL UI geometry
    renderer_flush();
    texture_renderer_flush();
    text_renderer_flush();
    g_active_batch = BATCH_NONE;

    // Exit UI mode
    g_ui_mode = 0;

    // Restore camera projection so subsequent draws use the camera again
    float projection[16];
    camera_get_matrix(projection, state.screen_width, state.screen_height);
    glUseProgram(state.shader);
    glUniformMatrix4fv(state.projection_loc, 1, GL_FALSE, projection);
}

// --- Gradient Rectangle ---

void render_rect_gradient(int x, int y, int width, int height, Color top_color, Color bottom_color) {
    set_mode(GL_TRIANGLES);
    float fx = (float)x;
    float fy = (float)y;
    float fw = (float)width;
    float fh = (float)height;

    // First triangle (top-left, top-right, bottom-right)
    add_vertex(fx,      fy,      top_color);
    add_vertex(fx + fw, fy,      top_color);
    add_vertex(fx + fw, fy + fh, bottom_color);

    // Second triangle (top-left, bottom-right, bottom-left)
    add_vertex(fx,      fy,      top_color);
    add_vertex(fx + fw, fy + fh, bottom_color);
    add_vertex(fx,      fy + fh, bottom_color);
}

// --- Read Pixel (framebuffer readback) ---

void renderer_read_pixel(int x, int y, int screen_height, unsigned char* r, unsigned char* g, unsigned char* b, unsigned char* a) {
    // OpenGL has origin at bottom-left, flip Y
    int gl_y = screen_height - 1 - y;
    unsigned char pixel[4] = {0, 0, 0, 255};
    glReadPixels(x, gl_y, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, pixel);
    *r = pixel[0];
    *g = pixel[1];
    *b = pixel[2];
    *a = pixel[3];
}
