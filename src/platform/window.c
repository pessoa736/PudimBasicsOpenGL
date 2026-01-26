#include "window.h"
#include <stdio.h>
#include <stdlib.h>
#include <glad/glad.h>

static int vsync_enabled = 1;

// Internal resize callback that updates Window struct and calls user callback
static void framebuffer_size_callback(GLFWwindow* glfw_window, int width, int height) {
    glViewport(0, 0, width, height);
    
    Window* window = (Window*)glfwGetWindowUserPointer(glfw_window);
    if (window) {
        window->width = width;
        window->height = height;
        
        if (window->resize_callback) {
            window->resize_callback(width, height, window->resize_user_data);
        }
    }
}

static void error_callback(int error, const char* description) {
    fprintf(stderr, "GLFW Error %d: %s\n", error, description);
}

Window* window_create(int width, int height, const char* title) {
    Window* window = (Window*)malloc(sizeof(Window));
    if (!window) {
        fprintf(stderr, "Failed to allocate memory for window\n");
        return NULL;
    }
    
    glfwSetErrorCallback(error_callback);
    
    if (!glfwInit()) {
        fprintf(stderr, "Failed to initialize GLFW\n");
        free(window);
        return NULL;
    }
    
    // OpenGL version 3.3 Core Profile
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_RESIZABLE, GLFW_TRUE);
    
    #ifdef __APPLE__
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
    #endif
    
    window->handle = glfwCreateWindow(width, height, title, NULL, NULL);
    if (!window->handle) {
        fprintf(stderr, "Failed to create GLFW window\n");
        glfwTerminate();
        free(window);
        return NULL;
    }
    
    window->width = width;
    window->height = height;
    window->title = title;
    window->is_fullscreen = 0;
    window->windowed_x = 0;
    window->windowed_y = 0;
    window->windowed_w = width;
    window->windowed_h = height;
    window->resize_callback = NULL;
    window->resize_user_data = NULL;
    
    // Store window pointer for callbacks
    glfwSetWindowUserPointer(window->handle, window);
    
    glfwMakeContextCurrent(window->handle);
    glfwSetFramebufferSizeCallback(window->handle, framebuffer_size_callback);
    
    // Load OpenGL function pointers with GLAD
    if (!gladLoaderLoadGL()) {
        fprintf(stderr, "Failed to initialize GLAD\n");
        glfwDestroyWindow(window->handle);
        glfwTerminate();
        free(window);
        return NULL;
    }
    
    // Enable VSync by default
    glfwSwapInterval(1);
    vsync_enabled = 1;
    
    glViewport(0, 0, width, height);
    
    printf("OpenGL %s\n", glGetString(GL_VERSION));
    printf("GLSL %s\n", glGetString(GL_SHADING_LANGUAGE_VERSION));
    printf("Renderer: %s\n", glGetString(GL_RENDERER));
    
    return window;
}

void window_destroy(Window* window) {
    if (window) {
        if (window->handle) {
            glfwDestroyWindow(window->handle);
        }
        free(window);
    }
    glfwTerminate();
}

int window_should_close(Window* window) {
    return glfwWindowShouldClose(window->handle);
}

void window_poll_events(Window* window) {
    (void)window;
    glfwPollEvents();
}

void window_swap_buffers(Window* window) {
    glfwSwapBuffers(window->handle);
}

void window_set_vsync(Window* window, int enabled) {
    (void)window;
    glfwSwapInterval(enabled ? 1 : 0);
    vsync_enabled = enabled;
}

int window_get_vsync(Window* window) {
    (void)window;
    return vsync_enabled;
}

void window_set_fullscreen(Window* window, int fullscreen) {
    if (window->is_fullscreen == fullscreen) return;
    
    if (fullscreen) {
        // Save windowed position and size
        glfwGetWindowPos(window->handle, &window->windowed_x, &window->windowed_y);
        glfwGetWindowSize(window->handle, &window->windowed_w, &window->windowed_h);
        
        // Get primary monitor
        GLFWmonitor* monitor = glfwGetPrimaryMonitor();
        const GLFWvidmode* mode = glfwGetVideoMode(monitor);
        
        glfwSetWindowMonitor(window->handle, monitor, 0, 0, mode->width, mode->height, mode->refreshRate);
        window->is_fullscreen = 1;
    } else {
        // Restore windowed mode
        glfwSetWindowMonitor(window->handle, NULL, 
                            window->windowed_x, window->windowed_y,
                            window->windowed_w, window->windowed_h, 0);
        window->is_fullscreen = 0;
    }
    
    // Re-apply vsync setting
    glfwSwapInterval(vsync_enabled ? 1 : 0);
}

int window_is_fullscreen(Window* window) {
    return window->is_fullscreen;
}

void window_toggle_fullscreen(Window* window) {
    window_set_fullscreen(window, !window->is_fullscreen);
}

void window_set_size(Window* window, int width, int height) {
    glfwSetWindowSize(window->handle, width, height);
    window->width = width;
    window->height = height;
}

void window_get_size(Window* window, int* width, int* height) {
    glfwGetWindowSize(window->handle, width, height);
    window->width = *width;
    window->height = *height;
}

void window_set_position(Window* window, int x, int y) {
    glfwSetWindowPos(window->handle, x, y);
}

void window_get_position(Window* window, int* x, int* y) {
    glfwGetWindowPos(window->handle, x, y);
}

void window_set_title(Window* window, const char* title) {
    glfwSetWindowTitle(window->handle, title);
    window->title = title;
}

void window_set_resize_callback(Window* window, WindowResizeCallback callback, void* user_data) {
    window->resize_callback = callback;
    window->resize_user_data = user_data;
}

void window_focus(Window* window) {
    glfwFocusWindow(window->handle);
}

int window_is_focused(Window* window) {
    return glfwGetWindowAttrib(window->handle, GLFW_FOCUSED);
}

void window_set_resizable(Window* window, int resizable) {
    glfwSetWindowAttrib(window->handle, GLFW_RESIZABLE, resizable ? GLFW_TRUE : GLFW_FALSE);
}
