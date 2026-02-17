#ifndef CAMERA_H
#define CAMERA_H

// 2D Camera system
// The camera modifies the projection matrix used by all renderers.
// Position (x, y) is the world offset: at (0,0) the view is identical to no camera.
// Zoom is applied around the screen center.
// Rotation (degrees) is applied around the screen center.

// Reset camera to defaults (position=0,0  zoom=1  rotation=0)
void camera_reset(void);

// Position
void camera_set_position(float x, float y);
void camera_get_position(float* x, float* y);
void camera_move(float dx, float dy);

// Zoom (default 1.0, >1 = zoom in, <1 = zoom out)
void camera_set_zoom(float zoom);
float camera_get_zoom(void);

// Rotation in degrees (default 0.0)
void camera_set_rotation(float angle);
float camera_get_rotation(void);

// Center the camera on a world point
// Sets position so that (x, y) appears at screen center
void camera_look_at(float x, float y, int screen_width, int screen_height);

// Get the combined projection * view matrix (4x4, column-major)
// All renderers should call this instead of building a plain ortho projection.
void camera_get_matrix(float* out, int screen_width, int screen_height);

// Convert screen coordinates to world coordinates
// Uses the last screen size from camera_get_matrix
void camera_screen_to_world(float sx, float sy, float* wx, float* wy);

// Convert world coordinates to screen coordinates
// Uses the last screen size from camera_get_matrix
void camera_world_to_screen(float wx, float wy, float* sx, float* sy);

#endif // CAMERA_H
