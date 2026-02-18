#include "shader.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Compile a single shader stage (GL_VERTEX_SHADER or GL_FRAGMENT_SHADER)
static GLuint compile_shader_stage(GLenum type, const char* source) {
    GLuint shader = glCreateShader(type);
    glShaderSource(shader, 1, &source, NULL);
    glCompileShader(shader);

    GLint success;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
    if (!success) {
        char info_log[1024];
        glGetShaderInfoLog(shader, sizeof(info_log), NULL, info_log);
        const char* type_name = (type == GL_VERTEX_SHADER) ? "vertex" : "fragment";
        fprintf(stderr, "[Shader] %s shader compilation error:\n%s\n", type_name, info_log);
        glDeleteShader(shader);
        return 0;
    }

    return shader;
}

// Link vertex and fragment shaders into a program
static GLuint link_program(GLuint vertex, GLuint fragment) {
    GLuint program = glCreateProgram();
    glAttachShader(program, vertex);
    glAttachShader(program, fragment);
    glLinkProgram(program);

    GLint success;
    glGetProgramiv(program, GL_LINK_STATUS, &success);
    if (!success) {
        char info_log[1024];
        glGetProgramInfoLog(program, sizeof(info_log), NULL, info_log);
        fprintf(stderr, "[Shader] Program linking error:\n%s\n", info_log);
        glDeleteProgram(program);
        return 0;
    }

    return program;
}

// Read entire file into a malloc'd string (caller frees)
static char* read_file_to_string(const char* filepath) {
    FILE* f = fopen(filepath, "rb");
    if (!f) {
        fprintf(stderr, "[Shader] Failed to open file: %s\n", filepath);
        return NULL;
    }

    fseek(f, 0, SEEK_END);
    long len = ftell(f);
    fseek(f, 0, SEEK_SET);

    if (len < 0) {
        fclose(f);
        return NULL;
    }

    char* buf = (char*)malloc((size_t)len + 1);
    if (!buf) {
        fclose(f);
        return NULL;
    }

    size_t read = fread(buf, 1, (size_t)len, f);
    buf[read] = '\0';
    fclose(f);

    return buf;
}

Shader* shader_create(const char* vertex_src, const char* fragment_src) {
    if (!vertex_src || !fragment_src) return NULL;

    GLuint vs = compile_shader_stage(GL_VERTEX_SHADER, vertex_src);
    if (!vs) return NULL;

    GLuint fs = compile_shader_stage(GL_FRAGMENT_SHADER, fragment_src);
    if (!fs) {
        glDeleteShader(vs);
        return NULL;
    }

    GLuint program = link_program(vs, fs);
    glDeleteShader(vs);
    glDeleteShader(fs);

    if (!program) return NULL;

    Shader* shader = (Shader*)malloc(sizeof(Shader));
    if (!shader) {
        glDeleteProgram(program);
        return NULL;
    }

    shader->program = program;
    shader->valid = 1;

    return shader;
}

Shader* shader_load(const char* vertex_path, const char* fragment_path) {
    char* vs_src = read_file_to_string(vertex_path);
    if (!vs_src) return NULL;

    char* fs_src = read_file_to_string(fragment_path);
    if (!fs_src) {
        free(vs_src);
        return NULL;
    }

    Shader* shader = shader_create(vs_src, fs_src);

    free(vs_src);
    free(fs_src);

    return shader;
}

void shader_destroy(Shader* shader) {
    if (!shader) return;
    if (shader->valid) {
        glDeleteProgram(shader->program);
        shader->program = 0;
        shader->valid = 0;
    }
    free(shader);
}

void shader_use(Shader* shader) {
    if (shader && shader->valid) {
        glUseProgram(shader->program);
    }
}

void shader_unuse(void) {
    glUseProgram(0);
}

int shader_get_uniform_location(Shader* shader, const char* name) {
    if (!shader || !shader->valid || !name) return -1;
    return glGetUniformLocation(shader->program, name);
}

void shader_set_int(Shader* shader, const char* name, int value) {
    GLint loc = shader_get_uniform_location(shader, name);
    if (loc >= 0) glUniform1i(loc, value);
}

void shader_set_float(Shader* shader, const char* name, float value) {
    GLint loc = shader_get_uniform_location(shader, name);
    if (loc >= 0) glUniform1f(loc, value);
}

void shader_set_vec2(Shader* shader, const char* name, float x, float y) {
    GLint loc = shader_get_uniform_location(shader, name);
    if (loc >= 0) glUniform2f(loc, x, y);
}

void shader_set_vec3(Shader* shader, const char* name, float x, float y, float z) {
    GLint loc = shader_get_uniform_location(shader, name);
    if (loc >= 0) glUniform3f(loc, x, y, z);
}

void shader_set_vec4(Shader* shader, const char* name, float x, float y, float z, float w) {
    GLint loc = shader_get_uniform_location(shader, name);
    if (loc >= 0) glUniform4f(loc, x, y, z, w);
}

void shader_set_mat4(Shader* shader, const char* name, const float* matrix) {
    GLint loc = shader_get_uniform_location(shader, name);
    if (loc >= 0) glUniformMatrix4fv(loc, 1, GL_FALSE, matrix);
}
