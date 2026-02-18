#define STB_IMAGE_IMPLEMENTATION
#include "stb/stb_image.h"

#include "texture.h"
#include "camera.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

// Texture shader sources
static const char* texture_vertex_shader_source = 
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

static const char* texture_fragment_shader_source = 
    "#version 330 core\n"
    "in vec2 TexCoord;\n"
    "in vec4 Color;\n"
    "out vec4 FragColor;\n"
    "uniform sampler2D textureSampler;\n"
    "void main() {\n"
    "    vec4 texColor = texture(textureSampler, TexCoord);\n"
    "    FragColor = texColor * Color;\n"
    "}\n";

// Texture renderer state
#define TEXTURE_MAX_VERTICES 65536
#define TEXTURE_VERTEX_SIZE 8  // x, y, u, v, r, g, b, a

typedef struct {
    GLuint vao;
    GLuint vbo;
    GLuint shader;
    GLint projection_loc;
    GLint texture_loc;
    float vertices[TEXTURE_MAX_VERTICES * TEXTURE_VERTEX_SIZE];
    int vertex_count;
    GLuint current_texture;
    int screen_width;
    int screen_height;
    int initialized;
} TextureRendererState;

static TextureRendererState tex_state = {0};

static GLuint create_texture_shader(void) {
    GLuint vertex_shader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertex_shader, 1, &texture_vertex_shader_source, NULL);
    glCompileShader(vertex_shader);
    
    GLint success;
    char info_log[512];
    glGetShaderiv(vertex_shader, GL_COMPILE_STATUS, &success);
    if (!success) {
        glGetShaderInfoLog(vertex_shader, 512, NULL, info_log);
        fprintf(stderr, "[Texture] Vertex shader error: %s\n", info_log);
    }
    
    GLuint fragment_shader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragment_shader, 1, &texture_fragment_shader_source, NULL);
    glCompileShader(fragment_shader);
    
    glGetShaderiv(fragment_shader, GL_COMPILE_STATUS, &success);
    if (!success) {
        glGetShaderInfoLog(fragment_shader, 512, NULL, info_log);
        fprintf(stderr, "[Texture] Fragment shader error: %s\n", info_log);
    }
    
    GLuint program = glCreateProgram();
    glAttachShader(program, vertex_shader);
    glAttachShader(program, fragment_shader);
    glLinkProgram(program);
    
    glGetProgramiv(program, GL_LINK_STATUS, &success);
    if (!success) {
        glGetProgramInfoLog(program, 512, NULL, info_log);
        fprintf(stderr, "[Texture] Shader linking error: %s\n", info_log);
    }
    
    glDeleteShader(vertex_shader);
    glDeleteShader(fragment_shader);
    
    return program;
}

void texture_renderer_init(void) {
    if (tex_state.initialized) return;
    
    tex_state.shader = create_texture_shader();
    tex_state.projection_loc = glGetUniformLocation(tex_state.shader, "projection");
    tex_state.texture_loc = glGetUniformLocation(tex_state.shader, "textureSampler");
    
    glGenVertexArrays(1, &tex_state.vao);
    glGenBuffers(1, &tex_state.vbo);
    
    glBindVertexArray(tex_state.vao);
    glBindBuffer(GL_ARRAY_BUFFER, tex_state.vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(tex_state.vertices), NULL, GL_DYNAMIC_DRAW);
    
    // Position attribute (location 0)
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, TEXTURE_VERTEX_SIZE * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0);
    
    // Texture coord attribute (location 1)
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, TEXTURE_VERTEX_SIZE * sizeof(float), (void*)(2 * sizeof(float)));
    glEnableVertexAttribArray(1);
    
    // Color attribute (location 2)
    glVertexAttribPointer(2, 4, GL_FLOAT, GL_FALSE, TEXTURE_VERTEX_SIZE * sizeof(float), (void*)(4 * sizeof(float)));
    glEnableVertexAttribArray(2);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    
    tex_state.vertex_count = 0;
    tex_state.current_texture = 0;
    tex_state.initialized = 1;
    
    printf("[Texture] Texture renderer initialized\n");
}

void texture_renderer_shutdown(void) {
    if (!tex_state.initialized) return;
    
    glDeleteVertexArrays(1, &tex_state.vao);
    glDeleteBuffers(1, &tex_state.vbo);
    glDeleteProgram(tex_state.shader);
    tex_state.initialized = 0;
}

void texture_renderer_flush(void) {
    if (tex_state.vertex_count == 0 || !tex_state.initialized) return;
    
    // Enable alpha blending for transparent textures (PNG, etc.)
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    // Create projection * view matrix (incorporates camera transform)
    float projection[16];
    camera_get_matrix(projection, tex_state.screen_width, tex_state.screen_height);
    
    glUseProgram(tex_state.shader);
    glUniformMatrix4fv(tex_state.projection_loc, 1, GL_FALSE, projection);
    glUniform1i(tex_state.texture_loc, 0);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, tex_state.current_texture);
    
    glBindVertexArray(tex_state.vao);
    glBindBuffer(GL_ARRAY_BUFFER, tex_state.vbo);
    glBufferSubData(GL_ARRAY_BUFFER, 0, tex_state.vertex_count * TEXTURE_VERTEX_SIZE * sizeof(float), tex_state.vertices);
    
    glDrawArrays(GL_TRIANGLES, 0, tex_state.vertex_count);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    glUseProgram(0);
    
    tex_state.vertex_count = 0;
}

// Helper to add textured vertex
static void add_texture_vertex(float x, float y, float u, float v, float r, float g, float b, float a) {
    if (tex_state.vertex_count >= TEXTURE_MAX_VERTICES) {
        texture_renderer_flush();
    }
    
    int idx = tex_state.vertex_count * TEXTURE_VERTEX_SIZE;
    tex_state.vertices[idx + 0] = x;
    tex_state.vertices[idx + 1] = y;
    tex_state.vertices[idx + 2] = u;
    tex_state.vertices[idx + 3] = v;
    tex_state.vertices[idx + 4] = r;
    tex_state.vertices[idx + 5] = g;
    tex_state.vertices[idx + 6] = b;
    tex_state.vertices[idx + 7] = a;
    tex_state.vertex_count++;
}

static void ensure_texture(GLuint texture_id) {
    if (tex_state.current_texture != texture_id) {
        texture_renderer_flush();
        tex_state.current_texture = texture_id;
    }
}

// --- Texture Loading ---

Texture* texture_load(const char* filepath) {
    stbi_set_flip_vertically_on_load(0); // Don't flip - we handle Y in projection
    
    int width, height, channels;
    unsigned char* data = stbi_load(filepath, &width, &height, &channels, 4); // Force RGBA
    
    if (!data) {
        fprintf(stderr, "[Texture] Failed to load: %s - %s\n", filepath, stbi_failure_reason());
        return NULL;
    }
    
    Texture* texture = texture_create(width, height, data);
    stbi_image_free(data);
    
    if (texture) {
        texture->channels = channels;
        printf("[Texture] Loaded: %s (%dx%d, %d channels)\n", filepath, width, height, channels);
    }
    
    return texture;
}

Texture* texture_create(int width, int height, unsigned char* data) {
    Texture* texture = (Texture*)malloc(sizeof(Texture));
    if (!texture) return NULL;
    
    texture->width = width;
    texture->height = height;
    texture->channels = 4;
    
    glGenTextures(1, &texture->id);
    glBindTexture(GL_TEXTURE_2D, texture->id);
    
    // Set texture parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    return texture;
}

void texture_destroy(Texture* texture) {
    if (texture) {
        glDeleteTextures(1, &texture->id);
        free(texture);
    }
}

void texture_bind(Texture* texture, unsigned int slot) {
    glActiveTexture(GL_TEXTURE0 + slot);
    glBindTexture(GL_TEXTURE_2D, texture ? texture->id : 0);
}

void texture_unbind(void) {
    glBindTexture(GL_TEXTURE_2D, 0);
}

// --- Drawing Functions ---

void render_texture(Texture* texture, int x, int y, int width, int height) {
    render_texture_tinted(texture, x, y, width, height, 1.0f, 1.0f, 1.0f, 1.0f);
}

void render_texture_tinted(Texture* texture, int x, int y, int width, int height,
                           float r, float g, float b, float a) {
    if (!texture || !tex_state.initialized) return;
    
    ensure_texture(texture->id);
    
    float fx = (float)x;
    float fy = (float)y;
    float fw = (float)width;
    float fh = (float)height;
    
    // UV coordinates
    float u0 = 0.0f, v0 = 0.0f;
    float u1 = 1.0f, v1 = 1.0f;
    
    // First triangle (top-left, top-right, bottom-right)
    add_texture_vertex(fx, fy, u0, v0, r, g, b, a);
    add_texture_vertex(fx + fw, fy, u1, v0, r, g, b, a);
    add_texture_vertex(fx + fw, fy + fh, u1, v1, r, g, b, a);
    
    // Second triangle (top-left, bottom-right, bottom-left)
    add_texture_vertex(fx, fy, u0, v0, r, g, b, a);
    add_texture_vertex(fx + fw, fy + fh, u1, v1, r, g, b, a);
    add_texture_vertex(fx, fy + fh, u0, v1, r, g, b, a);
}

void render_texture_rotated(Texture* texture, int x, int y, int width, int height, float angle) {
    render_texture_ex(texture, x, y, width, height, angle, 0.5f, 0.5f, 1.0f, 1.0f, 1.0f, 1.0f);
}

void render_texture_ex(Texture* texture, int x, int y, int width, int height,
                       float angle, float origin_x, float origin_y,
                       float r, float g, float b, float a) {
    if (!texture || !tex_state.initialized) return;
    
    ensure_texture(texture->id);
    
    float fw = (float)width;
    float fh = (float)height;
    
    // Origin in local space
    float ox = fw * origin_x;
    float oy = fh * origin_y;
    
    // Rotation in radians
    float rad = angle * (3.14159265f / 180.0f);
    float cos_a = cosf(rad);
    float sin_a = sinf(rad);
    
    // Define corners relative to origin
    float corners[4][2] = {
        {-ox, -oy},           // top-left
        {fw - ox, -oy},       // top-right
        {fw - ox, fh - oy},   // bottom-right
        {-ox, fh - oy}        // bottom-left
    };
    
    // Rotate and translate corners
    float rotated[4][2];
    for (int i = 0; i < 4; i++) {
        rotated[i][0] = x + ox + (corners[i][0] * cos_a - corners[i][1] * sin_a);
        rotated[i][1] = y + oy + (corners[i][0] * sin_a + corners[i][1] * cos_a);
    }
    
    // UV coordinates
    float uvs[4][2] = {{0, 0}, {1, 0}, {1, 1}, {0, 1}};
    
    // First triangle
    add_texture_vertex(rotated[0][0], rotated[0][1], uvs[0][0], uvs[0][1], r, g, b, a);
    add_texture_vertex(rotated[1][0], rotated[1][1], uvs[1][0], uvs[1][1], r, g, b, a);
    add_texture_vertex(rotated[2][0], rotated[2][1], uvs[2][0], uvs[2][1], r, g, b, a);
    
    // Second triangle
    add_texture_vertex(rotated[0][0], rotated[0][1], uvs[0][0], uvs[0][1], r, g, b, a);
    add_texture_vertex(rotated[2][0], rotated[2][1], uvs[2][0], uvs[2][1], r, g, b, a);
    add_texture_vertex(rotated[3][0], rotated[3][1], uvs[3][0], uvs[3][1], r, g, b, a);
}

void render_texture_region(Texture* texture,
                           int x, int y, int width, int height,
                           int src_x, int src_y, int src_width, int src_height) {
    render_texture_region_ex(texture, x, y, width, height, 
                             src_x, src_y, src_width, src_height,
                             0.0f, 0.5f, 0.5f, 1.0f, 1.0f, 1.0f, 1.0f);
}

void render_texture_region_ex(Texture* texture,
                              int x, int y, int width, int height,
                              int src_x, int src_y, int src_width, int src_height,
                              float angle, float origin_x, float origin_y,
                              float r, float g, float b, float a) {
    if (!texture || !tex_state.initialized) return;
    
    ensure_texture(texture->id);
    
    float fw = (float)width;
    float fh = (float)height;
    
    // Calculate UV coordinates from source rect
    float u0 = (float)src_x / texture->width;
    float v0 = (float)src_y / texture->height;
    float u1 = (float)(src_x + src_width) / texture->width;
    float v1 = (float)(src_y + src_height) / texture->height;
    
    if (angle == 0.0f) {
        // No rotation - simple quad
        float fx = (float)x;
        float fy = (float)y;
        
        add_texture_vertex(fx, fy, u0, v0, r, g, b, a);
        add_texture_vertex(fx + fw, fy, u1, v0, r, g, b, a);
        add_texture_vertex(fx + fw, fy + fh, u1, v1, r, g, b, a);
        
        add_texture_vertex(fx, fy, u0, v0, r, g, b, a);
        add_texture_vertex(fx + fw, fy + fh, u1, v1, r, g, b, a);
        add_texture_vertex(fx, fy + fh, u0, v1, r, g, b, a);
    } else {
        // With rotation
        float ox = fw * origin_x;
        float oy = fh * origin_y;
        
        float rad = angle * (3.14159265f / 180.0f);
        float cos_a = cosf(rad);
        float sin_a = sinf(rad);
        
        float corners[4][2] = {
            {-ox, -oy}, {fw - ox, -oy}, {fw - ox, fh - oy}, {-ox, fh - oy}
        };
        
        float rotated[4][2];
        for (int i = 0; i < 4; i++) {
            rotated[i][0] = x + ox + (corners[i][0] * cos_a - corners[i][1] * sin_a);
            rotated[i][1] = y + oy + (corners[i][0] * sin_a + corners[i][1] * cos_a);
        }
        
        float uvs[4][2] = {{u0, v0}, {u1, v0}, {u1, v1}, {u0, v1}};
        
        add_texture_vertex(rotated[0][0], rotated[0][1], uvs[0][0], uvs[0][1], r, g, b, a);
        add_texture_vertex(rotated[1][0], rotated[1][1], uvs[1][0], uvs[1][1], r, g, b, a);
        add_texture_vertex(rotated[2][0], rotated[2][1], uvs[2][0], uvs[2][1], r, g, b, a);
        
        add_texture_vertex(rotated[0][0], rotated[0][1], uvs[0][0], uvs[0][1], r, g, b, a);
        add_texture_vertex(rotated[2][0], rotated[2][1], uvs[2][0], uvs[2][1], r, g, b, a);
        add_texture_vertex(rotated[3][0], rotated[3][1], uvs[3][0], uvs[3][1], r, g, b, a);
    }
}

// Called by renderer_begin to update screen dimensions
void texture_renderer_set_screen_size(int width, int height) {
    tex_state.screen_width = width;
    tex_state.screen_height = height;
}
