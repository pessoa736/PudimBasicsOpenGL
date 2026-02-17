#include "camera.h"
#include <math.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

// Global camera state
static struct {
    float x, y;           // World offset position
    float zoom;           // Zoom level (1.0 = normal)
    float rotation;       // Rotation in degrees
    int screen_width;     // Last known screen width
    int screen_height;    // Last known screen height
} g_camera = {0.0f, 0.0f, 1.0f, 0.0f, 0, 0};

void camera_reset(void) {
    g_camera.x = 0.0f;
    g_camera.y = 0.0f;
    g_camera.zoom = 1.0f;
    g_camera.rotation = 0.0f;
}

// Position
void camera_set_position(float x, float y) {
    g_camera.x = x;
    g_camera.y = y;
}

void camera_get_position(float* x, float* y) {
    *x = g_camera.x;
    *y = g_camera.y;
}

void camera_move(float dx, float dy) {
    g_camera.x += dx;
    g_camera.y += dy;
}

// Zoom
void camera_set_zoom(float zoom) {
    if (zoom > 0.0f) {
        g_camera.zoom = zoom;
    }
}

float camera_get_zoom(void) {
    return g_camera.zoom;
}

// Rotation
void camera_set_rotation(float angle) {
    g_camera.rotation = angle;
}

float camera_get_rotation(void) {
    return g_camera.rotation;
}

// Look at
void camera_look_at(float x, float y, int screen_width, int screen_height) {
    g_camera.x = x - (float)screen_width * 0.5f;
    g_camera.y = y - (float)screen_height * 0.5f;
}

// Combined projection * view matrix (column-major, for OpenGL)
//
// View transform (world → screen):
//   1. Translate by (-cam.x, -cam.y)
//   2. Center on screen: translate by (-sw/2, -sh/2)
//   3. Scale by zoom
//   4. Rotate by angle
//   5. Translate back by (sw/2, sh/2)
//
// V = T(sw/2, sh/2) * R(θ) * S(zoom) * T(-cam.x - sw/2, -cam.y - sh/2)
//
// Combined with ortho projection P = ortho(0, sw, sh, 0, -1, 1):
//   PV = P * V
void camera_get_matrix(float* out, int screen_width, int screen_height) {
    float sw = (float)screen_width;
    float sh = (float)screen_height;
    float z = g_camera.zoom;
    float angle_rad = g_camera.rotation * (float)(M_PI / 180.0);
    float c = cosf(angle_rad);
    float s = sinf(angle_rad);
    float cx = g_camera.x;
    float cy = g_camera.y;

    // View translation: combines camera offset and centering
    float tx = z * (s * (cy + sh * 0.5f) - c * (cx + sw * 0.5f));
    float ty = z * (-s * (cx + sw * 0.5f) - c * (cy + sh * 0.5f));

    // Combined projection * view matrix (column-major)
    // Column 0
    out[0]  =  2.0f * z * c / sw;
    out[1]  = -2.0f * z * s / sh;
    out[2]  =  0.0f;
    out[3]  =  0.0f;
    // Column 1
    out[4]  = -2.0f * z * s / sw;
    out[5]  = -2.0f * z * c / sh;
    out[6]  =  0.0f;
    out[7]  =  0.0f;
    // Column 2
    out[8]  =  0.0f;
    out[9]  =  0.0f;
    out[10] = -1.0f;
    out[11] =  0.0f;
    // Column 3
    out[12] =  2.0f * tx / sw;
    out[13] = -2.0f * ty / sh;
    out[14] =  0.0f;
    out[15] =  1.0f;

    // Store screen size for coordinate conversion
    g_camera.screen_width = screen_width;
    g_camera.screen_height = screen_height;
}

// Screen → World coordinate conversion
void camera_screen_to_world(float sx, float sy, float* wx, float* wy) {
    float sw = (float)g_camera.screen_width;
    float sh = (float)g_camera.screen_height;
    float z = g_camera.zoom;
    float angle_rad = g_camera.rotation * (float)(M_PI / 180.0);
    float c = cosf(angle_rad);
    float s = sinf(angle_rad);

    // Undo translate to center
    float dx = sx - sw * 0.5f;
    float dy = sy - sh * 0.5f;

    // Undo rotation (inverse = transpose for orthogonal matrix)
    float ux = dx * c + dy * s;
    float uy = -dx * s + dy * c;

    // Undo scale
    ux /= z;
    uy /= z;

    // Undo centering and camera offset
    *wx = ux + sw * 0.5f + g_camera.x;
    *wy = uy + sh * 0.5f + g_camera.y;
}

// World → Screen coordinate conversion
void camera_world_to_screen(float wx, float wy, float* sx, float* sy) {
    float sw = (float)g_camera.screen_width;
    float sh = (float)g_camera.screen_height;
    float z = g_camera.zoom;
    float angle_rad = g_camera.rotation * (float)(M_PI / 180.0);
    float c = cosf(angle_rad);
    float s = sinf(angle_rad);

    // Apply camera offset and centering
    float ux = (wx - g_camera.x - sw * 0.5f) * z;
    float uy = (wy - g_camera.y - sh * 0.5f) * z;

    // Apply rotation
    float dx = ux * c - uy * s;
    float dy = ux * s + uy * c;

    // Translate back to screen center
    *sx = dx + sw * 0.5f;
    *sy = dy + sh * 0.5f;
}
