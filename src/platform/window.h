#ifndef WINDOW_H
#define WINDOW_H

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

// Callback for window resize events
typedef void (*WindowResizeCallback)(int width, int height, void* user_data);

typedef struct {
    GLFWwindow* handle;
    int width;
    int height;
    const char* title;
    int is_fullscreen;
    int windowed_x, windowed_y;    // Position before fullscreen
    int windowed_w, windowed_h;    // Size before fullscreen
    WindowResizeCallback resize_callback;
    void* resize_user_data;
} Window;

Window* window_create(int width, int height, const char* title);
void window_destroy(Window* window);
int window_should_close(Window* window);
void window_poll_events(Window* window);
void window_swap_buffers(Window* window);

// New functions
void window_set_vsync(Window* window, int enabled);
int window_get_vsync(Window* window);
void window_set_fullscreen(Window* window, int fullscreen);
int window_is_fullscreen(Window* window);
void window_toggle_fullscreen(Window* window);
void window_set_size(Window* window, int width, int height);
void window_get_size(Window* window, int* width, int* height);
void window_set_position(Window* window, int x, int y);
void window_get_position(Window* window, int* x, int* y);
void window_set_title(Window* window, const char* title);
void window_set_resize_callback(Window* window, WindowResizeCallback callback, void* user_data);
void window_focus(Window* window);
int window_is_focused(Window* window);
void window_set_resizable(Window* window, int resizable);

#endif // WINDOW_H
