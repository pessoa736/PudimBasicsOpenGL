#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <stdlib.h>
#include "../platform/window.h"
#include "../render/renderer.h"

#define WINDOW_METATABLE "PudimBasicsGl.Window"

// Helper to get Window* from userdata
static Window* check_window(lua_State* L, int idx) {
    Window** wp = (Window**)luaL_checkudata(L, idx, WINDOW_METATABLE);
    if (*wp == NULL) {
        luaL_error(L, "Window has been destroyed");
    }
    return *wp;
}

// Store active window for input module
static Window* g_active_window = NULL;

Window* pudim_get_active_window(void) {
    return g_active_window;
}

// pudim.window.create(width, height, title) -> window userdata
static int l_window_create(lua_State* L) {
    int width = (int)luaL_checkinteger(L, 1);
    int height = (int)luaL_checkinteger(L, 2);
    const char* title = luaL_checkstring(L, 3);
    
    Window* window = window_create(width, height, title);
    if (!window) {
        lua_pushnil(L);
        lua_pushstring(L, "Failed to create window");
        return 2;
    }
    
    // Store as active window for input
    g_active_window = window;
    
    // Create userdata to hold the window pointer
    Window** wp = (Window**)lua_newuserdata(L, sizeof(Window*));
    *wp = window;
    
    // Set metatable
    luaL_getmetatable(L, WINDOW_METATABLE);
    lua_setmetatable(L, -2);
    
    return 1;
}

// pudim.window.destroy(window)
static int l_window_destroy(lua_State* L) {
    Window** wp = (Window**)luaL_checkudata(L, 1, WINDOW_METATABLE);
    if (*wp) {
        if (g_active_window == *wp) {
            g_active_window = NULL;
        }
        window_destroy(*wp);
        *wp = NULL;
    }
    return 0;
}

// __gc metamethod
static int l_window_gc(lua_State* L) {
    return l_window_destroy(L);
}

// pudim.window.should_close(window) -> boolean
static int l_window_should_close(lua_State* L) {
    Window* window = check_window(L, 1);
    lua_pushboolean(L, window_should_close(window));
    return 1;
}

// pudim.window.poll_events()
static int l_window_poll_events(lua_State* L) {
    (void)L;
    if (g_active_window) {
        window_poll_events(g_active_window);
    }
    return 0;
}

// pudim.window.swap_buffers(window)
static int l_window_swap_buffers(lua_State* L) {
    Window* window = check_window(L, 1);
    window_swap_buffers(window);
    return 0;
}

// pudim.window.get_size(window) -> width, height
static int l_window_get_size(lua_State* L) {
    Window* window = check_window(L, 1);
    int w, h;
    window_get_size(window, &w, &h);
    lua_pushinteger(L, w);
    lua_pushinteger(L, h);
    return 2;
}

// pudim.window.set_title(window, title)
static int l_window_set_title(lua_State* L) {
    Window* window = check_window(L, 1);
    const char* title = luaL_checkstring(L, 2);
    window_set_title(window, title);
    return 0;
}

// PudimBasicsGl.window.close(window)
static int l_window_close(lua_State* L) {
    Window* window = check_window(L, 1);
    if (window->handle) {
        glfwSetWindowShouldClose(window->handle, GLFW_TRUE);
    }
    return 0;
}

// PudimBasicsGl.window.get_handle(window) -> lightuserdata (GLFWwindow*)
static int l_window_get_handle(lua_State* L) {
    Window* window = check_window(L, 1);
    lua_pushlightuserdata(L, window->handle);
    return 1;
}

// PudimBasicsGl.window.set_vsync(window, enabled)
static int l_window_set_vsync(lua_State* L) {
    Window* window = check_window(L, 1);
    int enabled = lua_toboolean(L, 2);
    window_set_vsync(window, enabled);
    return 0;
}

// PudimBasicsGl.window.get_vsync(window) -> boolean
static int l_window_get_vsync(lua_State* L) {
    Window* window = check_window(L, 1);
    lua_pushboolean(L, window_get_vsync(window));
    return 1;
}

// PudimBasicsGl.window.set_fullscreen(window, fullscreen)
static int l_window_set_fullscreen(lua_State* L) {
    Window* window = check_window(L, 1);
    int fullscreen = lua_toboolean(L, 2);
    window_set_fullscreen(window, fullscreen);
    return 0;
}

// PudimBasicsGl.window.is_fullscreen(window) -> boolean
static int l_window_is_fullscreen(lua_State* L) {
    Window* window = check_window(L, 1);
    lua_pushboolean(L, window_is_fullscreen(window));
    return 1;
}

// PudimBasicsGl.window.toggle_fullscreen(window)
static int l_window_toggle_fullscreen(lua_State* L) {
    Window* window = check_window(L, 1);
    window_toggle_fullscreen(window);
    return 0;
}

// PudimBasicsGl.window.set_size(window, width, height)
static int l_window_set_size(lua_State* L) {
    Window* window = check_window(L, 1);
    int width = (int)luaL_checkinteger(L, 2);
    int height = (int)luaL_checkinteger(L, 3);
    window_set_size(window, width, height);
    return 0;
}

// PudimBasicsGl.window.get_position(window) -> x, y
static int l_window_get_position(lua_State* L) {
    Window* window = check_window(L, 1);
    int x, y;
    window_get_position(window, &x, &y);
    lua_pushinteger(L, x);
    lua_pushinteger(L, y);
    return 2;
}

// PudimBasicsGl.window.set_position(window, x, y)
static int l_window_set_position(lua_State* L) {
    Window* window = check_window(L, 1);
    int x = (int)luaL_checkinteger(L, 2);
    int y = (int)luaL_checkinteger(L, 3);
    window_set_position(window, x, y);
    return 0;
}

// PudimBasicsGl.window.focus(window)
static int l_window_focus(lua_State* L) {
    Window* window = check_window(L, 1);
    window_focus(window);
    return 0;
}

// PudimBasicsGl.window.is_focused(window) -> boolean
static int l_window_is_focused(lua_State* L) {
    Window* window = check_window(L, 1);
    lua_pushboolean(L, window_is_focused(window));
    return 1;
}

// PudimBasicsGl.window.set_resizable(window, resizable)
static int l_window_set_resizable(lua_State* L) {
    Window* window = check_window(L, 1);
    int resizable = lua_toboolean(L, 2);
    window_set_resizable(window, resizable);
    return 0;
}

static const luaL_Reg window_funcs[] = {
    {"create", l_window_create},
    {"destroy", l_window_destroy},
    {"should_close", l_window_should_close},
    {"poll_events", l_window_poll_events},
    {"swap_buffers", l_window_swap_buffers},
    {"get_size", l_window_get_size},
    {"set_size", l_window_set_size},
    {"set_title", l_window_set_title},
    {"close", l_window_close},
    {"get_handle", l_window_get_handle},
    {"set_vsync", l_window_set_vsync},
    {"get_vsync", l_window_get_vsync},
    {"set_fullscreen", l_window_set_fullscreen},
    {"is_fullscreen", l_window_is_fullscreen},
    {"toggle_fullscreen", l_window_toggle_fullscreen},
    {"get_position", l_window_get_position},
    {"set_position", l_window_set_position},
    {"focus", l_window_focus},
    {"is_focused", l_window_is_focused},
    {"set_resizable", l_window_set_resizable},
    {NULL, NULL}
};

static const luaL_Reg window_meta[] = {
    {"__gc", l_window_gc},
    {NULL, NULL}
};

void lua_register_window_api(lua_State* L) {
    // Create metatable for Window userdata
    luaL_newmetatable(L, WINDOW_METATABLE);
    luaL_setfuncs(L, window_meta, 0);
    lua_pop(L, 1);
    
    // Get or create PudimBasicsGl table
    lua_getglobal(L, "PudimBasicsGl");
    if (lua_isnil(L, -1)) {
        lua_pop(L, 1);
        lua_newtable(L);
        lua_setglobal(L, "PudimBasicsGl");
        lua_getglobal(L, "PudimBasicsGl");
    }
    
    // Create window subtable
    lua_newtable(L);
    luaL_setfuncs(L, window_funcs, 0);
    lua_setfield(L, -2, "window");
    
    lua_pop(L, 1);
}
