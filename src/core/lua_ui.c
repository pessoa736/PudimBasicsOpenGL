// Lua binding for the UI immediate-mode GUI module
// Exposes PudimBasicsGl.ui.* functions

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#include "../render/ui.h"
#include "../render/text.h"

#define FONT_METATABLE "PudimBasicsGl.Font"

// Helper to get Font* from userdata at stack index
static Font* get_font(lua_State* L, int idx) {
    Font** udata = (Font**)luaL_checkudata(L, idx, FONT_METATABLE);
    if (!udata || !*udata) {
        luaL_error(L, "Font has been destroyed");
    }
    return *udata;
}

// pudim.ui.set_font(font)
static int l_ui_set_font(lua_State* L) {
    int arg = 1;
    if (lua_istable(L, 1)) arg = 2; // colon-call compat
    Font* font = get_font(L, arg);
    ui_set_font(font);
    return 0;
}

// pudim.ui.begin_frame()
static int l_ui_begin_frame(lua_State* L) {
    (void)L;
    ui_begin_frame();
    return 0;
}

// pudim.ui.end_frame()
static int l_ui_end_frame(lua_State* L) {
    (void)L;
    ui_end_frame();
    return 0;
}

// pudim.ui.label(text, x, y, r, g, b, a)
static int l_ui_label(lua_State* L) {
    int arg = 1;
    if (lua_istable(L, 1)) arg = 2;
    const char* text = luaL_checkstring(L, arg);
    float x = (float)luaL_checknumber(L, arg + 1);
    float y = (float)luaL_checknumber(L, arg + 2);
    float r = (float)luaL_optnumber(L, arg + 3, 1.0);
    float g = (float)luaL_optnumber(L, arg + 4, 1.0);
    float b = (float)luaL_optnumber(L, arg + 5, 1.0);
    float a = (float)luaL_optnumber(L, arg + 6, 1.0);
    ui_label(text, x, y, r, g, b, a);
    return 0;
}

// pudim.ui.panel(title, x, y, w, h)
static int l_ui_panel(lua_State* L) {
    int arg = 1;
    if (lua_istable(L, 1)) arg = 2;
    const char* title = lua_isstring(L, arg) ? lua_tostring(L, arg) : NULL;
    float x = (float)luaL_checknumber(L, arg + 1);
    float y = (float)luaL_checknumber(L, arg + 2);
    float w = (float)luaL_checknumber(L, arg + 3);
    float h = (float)luaL_checknumber(L, arg + 4);
    ui_panel(title, x, y, w, h);
    return 0;
}

// pudim.ui.button(id, label, x, y, w, h, r, g, b) -> boolean
static int l_ui_button(lua_State* L) {
    int arg = 1;
    if (lua_istable(L, 1)) arg = 2;
    const char* id    = luaL_checkstring(L, arg);
    const char* label = luaL_checkstring(L, arg + 1);
    float x = (float)luaL_checknumber(L, arg + 2);
    float y = (float)luaL_checknumber(L, arg + 3);
    float w = (float)luaL_checknumber(L, arg + 4);
    float h = (float)luaL_checknumber(L, arg + 5);
    float r = (float)luaL_optnumber(L, arg + 6, 0.3);
    float g = (float)luaL_optnumber(L, arg + 7, 0.4);
    float b = (float)luaL_optnumber(L, arg + 8, 0.6);
    int clicked = ui_button(id, label, x, y, w, h, r, g, b);
    lua_pushboolean(L, clicked);
    return 1;
}

// pudim.ui.slider(id, label, x, y, w, h, value, min, max) -> number
static int l_ui_slider(lua_State* L) {
    int arg = 1;
    if (lua_istable(L, 1)) arg = 2;
    const char* id    = luaL_checkstring(L, arg);
    const char* label = luaL_checkstring(L, arg + 1);
    float x   = (float)luaL_checknumber(L, arg + 2);
    float y   = (float)luaL_checknumber(L, arg + 3);
    float w   = (float)luaL_checknumber(L, arg + 4);
    float h   = (float)luaL_checknumber(L, arg + 5);
    float val = (float)luaL_checknumber(L, arg + 6);
    float mn  = (float)luaL_checknumber(L, arg + 7);
    float mx  = (float)luaL_checknumber(L, arg + 8);
    float result = ui_slider(id, label, x, y, w, h, val, mn, mx);
    lua_pushnumber(L, (double)result);
    return 1;
}

static const luaL_Reg ui_funcs[] = {
    {"set_font",    l_ui_set_font},
    {"begin_frame", l_ui_begin_frame},
    {"end_frame",   l_ui_end_frame},
    {"label",       l_ui_label},
    {"panel",       l_ui_panel},
    {"button",      l_ui_button},
    {"slider",      l_ui_slider},
    {NULL, NULL}
};

void lua_register_ui_api(lua_State* L) {
    lua_getglobal(L, "PudimBasicsGl");
    if (lua_isnil(L, -1)) {
        lua_pop(L, 1);
        lua_newtable(L);
        lua_setglobal(L, "PudimBasicsGl");
        lua_getglobal(L, "PudimBasicsGl");
    }
    lua_newtable(L);
    luaL_setfuncs(L, ui_funcs, 0);
    lua_setfield(L, -2, "ui");
    lua_pop(L, 1);
}
