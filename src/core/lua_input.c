#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>
#include "../platform/window.h"

// Get active window from lua_window.c
extern Window* pudim_get_active_window(void);

static Window* get_window(void) {
    return pudim_get_active_window();
}

// pudim.input.is_key_pressed(key) -> boolean
static int l_input_is_key_pressed(lua_State* L) {
    int key = (int)luaL_checkinteger(L, 1);
    Window* win = get_window();
    if (win && win->handle) {
        lua_pushboolean(L, glfwGetKey(win->handle, key) == GLFW_PRESS);
    } else {
        lua_pushboolean(L, 0);
    }
    return 1;
}

// pudim.input.is_key_released(key) -> boolean
static int l_input_is_key_released(lua_State* L) {
    int key = (int)luaL_checkinteger(L, 1);
    Window* win = get_window();
    if (win && win->handle) {
        lua_pushboolean(L, glfwGetKey(win->handle, key) == GLFW_RELEASE);
    } else {
        lua_pushboolean(L, 1);
    }
    return 1;
}

// pudim.input.is_mouse_button_pressed(button) -> boolean
static int l_input_is_mouse_button_pressed(lua_State* L) {
    int button = (int)luaL_checkinteger(L, 1);
    Window* win = get_window();
    if (win && win->handle) {
        lua_pushboolean(L, glfwGetMouseButton(win->handle, button) == GLFW_PRESS);
    } else {
        lua_pushboolean(L, 0);
    }
    return 1;
}

// pudim.input.get_mouse_position() -> x, y
static int l_input_get_mouse_position(lua_State* L) {
    Window* win = get_window();
    if (win && win->handle) {
        double x, y;
        glfwGetCursorPos(win->handle, &x, &y);
        lua_pushnumber(L, x);
        lua_pushnumber(L, y);
    } else {
        lua_pushnumber(L, 0);
        lua_pushnumber(L, 0);
    }
    return 2;
}

// pudim.input.set_mouse_position(x, y)
static int l_input_set_mouse_position(lua_State* L) {
    double x = luaL_checknumber(L, 1);
    double y = luaL_checknumber(L, 2);
    Window* win = get_window();
    if (win && win->handle) {
        glfwSetCursorPos(win->handle, x, y);
    }
    return 0;
}

// pudim.input.set_cursor_visible(visible)
static int l_input_set_cursor_visible(lua_State* L) {
    int visible = lua_toboolean(L, 1);
    Window* win = get_window();
    if (win && win->handle) {
        glfwSetInputMode(win->handle, GLFW_CURSOR, 
                         visible ? GLFW_CURSOR_NORMAL : GLFW_CURSOR_HIDDEN);
    }
    return 0;
}

// pudim.input.set_cursor_locked(locked)
static int l_input_set_cursor_locked(lua_State* L) {
    int locked = lua_toboolean(L, 1);
    Window* win = get_window();
    if (win && win->handle) {
        glfwSetInputMode(win->handle, GLFW_CURSOR, 
                         locked ? GLFW_CURSOR_DISABLED : GLFW_CURSOR_NORMAL);
    }
    return 0;
}

static const luaL_Reg input_funcs[] = {
    {"is_key_pressed", l_input_is_key_pressed},
    {"is_key_released", l_input_is_key_released},
    {"is_mouse_button_pressed", l_input_is_mouse_button_pressed},
    {"get_mouse_position", l_input_get_mouse_position},
    {"set_mouse_position", l_input_set_mouse_position},
    {"set_cursor_visible", l_input_set_cursor_visible},
    {"set_cursor_locked", l_input_set_cursor_locked},
    {NULL, NULL}
};

void lua_register_input_api(lua_State* L) {
    lua_getglobal(L, "PudimBasicsGl");
    if (lua_isnil(L, -1)) {
        lua_pop(L, 1);
        lua_newtable(L);
        lua_setglobal(L, "PudimBasicsGl");
        lua_getglobal(L, "PudimBasicsGl");
    }
    
    // Create input subtable
    lua_newtable(L);
    luaL_setfuncs(L, input_funcs, 0);
    
    // Add key constants
    lua_pushinteger(L, GLFW_KEY_SPACE); lua_setfield(L, -2, "KEY_SPACE");
    lua_pushinteger(L, GLFW_KEY_ESCAPE); lua_setfield(L, -2, "KEY_ESCAPE");
    lua_pushinteger(L, GLFW_KEY_ENTER); lua_setfield(L, -2, "KEY_ENTER");
    lua_pushinteger(L, GLFW_KEY_TAB); lua_setfield(L, -2, "KEY_TAB");
    lua_pushinteger(L, GLFW_KEY_BACKSPACE); lua_setfield(L, -2, "KEY_BACKSPACE");
    
    // Arrow keys
    lua_pushinteger(L, GLFW_KEY_UP); lua_setfield(L, -2, "KEY_UP");
    lua_pushinteger(L, GLFW_KEY_DOWN); lua_setfield(L, -2, "KEY_DOWN");
    lua_pushinteger(L, GLFW_KEY_LEFT); lua_setfield(L, -2, "KEY_LEFT");
    lua_pushinteger(L, GLFW_KEY_RIGHT); lua_setfield(L, -2, "KEY_RIGHT");
    
    // WASD
    lua_pushinteger(L, GLFW_KEY_W); lua_setfield(L, -2, "KEY_W");
    lua_pushinteger(L, GLFW_KEY_A); lua_setfield(L, -2, "KEY_A");
    lua_pushinteger(L, GLFW_KEY_S); lua_setfield(L, -2, "KEY_S");
    lua_pushinteger(L, GLFW_KEY_D); lua_setfield(L, -2, "KEY_D");
    
    // Function keys
    lua_pushinteger(L, GLFW_KEY_F1); lua_setfield(L, -2, "KEY_F1");
    lua_pushinteger(L, GLFW_KEY_F2); lua_setfield(L, -2, "KEY_F2");
    lua_pushinteger(L, GLFW_KEY_F3); lua_setfield(L, -2, "KEY_F3");
    lua_pushinteger(L, GLFW_KEY_F11); lua_setfield(L, -2, "KEY_F11");
    lua_pushinteger(L, GLFW_KEY_F12); lua_setfield(L, -2, "KEY_F12");
    
    // Modifiers
    lua_pushinteger(L, GLFW_KEY_LEFT_SHIFT); lua_setfield(L, -2, "KEY_LEFT_SHIFT");
    lua_pushinteger(L, GLFW_KEY_RIGHT_SHIFT); lua_setfield(L, -2, "KEY_RIGHT_SHIFT");
    lua_pushinteger(L, GLFW_KEY_LEFT_CONTROL); lua_setfield(L, -2, "KEY_LEFT_CTRL");
    lua_pushinteger(L, GLFW_KEY_RIGHT_CONTROL); lua_setfield(L, -2, "KEY_RIGHT_CTRL");
    lua_pushinteger(L, GLFW_KEY_LEFT_ALT); lua_setfield(L, -2, "KEY_LEFT_ALT");
    lua_pushinteger(L, GLFW_KEY_RIGHT_ALT); lua_setfield(L, -2, "KEY_RIGHT_ALT");
    
    // Number keys
    for (int i = 0; i <= 9; i++) {
        char name[16];
        snprintf(name, sizeof(name), "KEY_%d", i);
        lua_pushinteger(L, GLFW_KEY_0 + i);
        lua_setfield(L, -2, name);
    }
    
    // Letter keys (A-Z)
    for (int i = 0; i < 26; i++) {
        char name[16];
        snprintf(name, sizeof(name), "KEY_%c", 'A' + i);
        lua_pushinteger(L, GLFW_KEY_A + i);
        lua_setfield(L, -2, name);
    }
    
    // Mouse buttons
    lua_pushinteger(L, GLFW_MOUSE_BUTTON_LEFT); lua_setfield(L, -2, "MOUSE_LEFT");
    lua_pushinteger(L, GLFW_MOUSE_BUTTON_RIGHT); lua_setfield(L, -2, "MOUSE_RIGHT");
    lua_pushinteger(L, GLFW_MOUSE_BUTTON_MIDDLE); lua_setfield(L, -2, "MOUSE_MIDDLE");
    
    lua_setfield(L, -2, "input");
    
    lua_pop(L, 1);
}
