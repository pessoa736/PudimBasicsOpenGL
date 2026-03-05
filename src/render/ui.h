#ifndef UI_H
#define UI_H

#include "text.h"

// Initialize UI system (called lazily on first begin_frame)
void ui_init(void);

// Shutdown UI system
void ui_shutdown(void);

// Set the font used by all UI widgets
void ui_set_font(Font* font);

// Begin a new UI frame — reads mouse state from the active window
void ui_begin_frame(void);

// End the current UI frame — flushes all pending draws
void ui_end_frame(void);

// Draw a text label at (x, y) with the given color
void ui_label(const char* text, float x, float y, float r, float g, float b, float a);

// Draw a panel with optional title bar at (x, y, w, h)
void ui_panel(const char* title, float x, float y, float w, float h);

// Draw an interactive button. Returns 1 if clicked this frame, 0 otherwise.
int ui_button(const char* id, const char* label, float x, float y, float w, float h, float r, float g, float b);

// Draw an interactive slider. Returns the (possibly updated) value.
float ui_slider(const char* id, const char* label, float x, float y, float w, float h, float value, float min_val, float max_val);

#endif // UI_H
