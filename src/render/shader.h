#ifndef SHADER_H
#define SHADER_H

#include <glad/glad.h>

typedef struct {
    GLuint program;
    int valid;  // 1 if shader compiled/linked successfully
} Shader;

// Create shader program from vertex and fragment source strings
Shader* shader_create(const char* vertex_src, const char* fragment_src);

// Load shader program from vertex and fragment source files
Shader* shader_load(const char* vertex_path, const char* fragment_path);

// Destroy shader and free resources
void shader_destroy(Shader* shader);

// Bind shader for rendering
void shader_use(Shader* shader);

// Unbind shader (restore no program)
void shader_unuse(void);

// Get uniform location (returns -1 if not found)
int shader_get_uniform_location(Shader* shader, const char* name);

// Set uniform values
void shader_set_int(Shader* shader, const char* name, int value);
void shader_set_float(Shader* shader, const char* name, float value);
void shader_set_vec2(Shader* shader, const char* name, float x, float y);
void shader_set_vec3(Shader* shader, const char* name, float x, float y, float z);
void shader_set_vec4(Shader* shader, const char* name, float x, float y, float z, float w);
void shader_set_mat4(Shader* shader, const char* name, const float* matrix);

#endif // SHADER_H
