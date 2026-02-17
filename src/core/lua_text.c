#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include "../render/text.h"
#include "../render/renderer.h"

#define FONT_METATABLE "PudimBasicsGl.Font"

// Helper to validate Font userdata
static Font** check_font(lua_State* L, int idx) {
    return (Font**)luaL_checkudata(L, idx, FONT_METATABLE);
}

// Helper to get color from Lua (r,g,b,a or table) - same pattern as lua_renderer.c
static Color get_text_color_from_lua(lua_State* L, int start_idx) {
    Color c = {1.0f, 1.0f, 1.0f, 1.0f};

    if (lua_istable(L, start_idx)) {
        lua_getfield(L, start_idx, "r"); c.r = (float)lua_tonumber(L, -1); lua_pop(L, 1);
        lua_getfield(L, start_idx, "g"); c.g = (float)lua_tonumber(L, -1); lua_pop(L, 1);
        lua_getfield(L, start_idx, "b"); c.b = (float)lua_tonumber(L, -1); lua_pop(L, 1);
        lua_getfield(L, start_idx, "a");
        c.a = lua_isnil(L, -1) ? 1.0f : (float)lua_tonumber(L, -1);
        lua_pop(L, 1);
    } else {
        c.r = (float)luaL_checknumber(L, start_idx);
        c.g = (float)luaL_checknumber(L, start_idx + 1);
        c.b = (float)luaL_checknumber(L, start_idx + 2);
        c.a = (float)luaL_optnumber(L, start_idx + 3, 1.0);
    }
    return c;
}

// pudim.text.load(filepath, size) -> Font
static int l_text_load(lua_State* L) {
    int arg = 1;
    if (lua_istable(L, 1)) arg = 2;  // skip self if called with ':'

    const char* filepath = luaL_checkstring(L, arg);
    float size = (float)luaL_optnumber(L, arg + 1, 24.0);

    Font* font = font_load(filepath, size);
    if (!font) {
        lua_pushnil(L);
        lua_pushstring(L, "Failed to load font");
        return 2;
    }

    Font** udata = (Font**)lua_newuserdata(L, sizeof(Font*));
    *udata = font;

    luaL_getmetatable(L, FONT_METATABLE);
    lua_setmetatable(L, -2);

    return 1;
}

// font:draw(text, x, y, r, g, b, a?) or font:draw(text, x, y, color_table)
static int l_font_draw(lua_State* L) {
    Font** font = check_font(L, 1);
    if (!*font) {
        return luaL_error(L, "Font has been destroyed");
    }

    const char* text = luaL_checkstring(L, 2);
    float x = (float)luaL_checknumber(L, 3);
    float y = (float)luaL_checknumber(L, 4);
    Color c = get_text_color_from_lua(L, 5);

    render_text(*font, text, x, y, c);
    return 0;
}

// font:measure(text) -> width, height
static int l_font_measure(lua_State* L) {
    Font** font = check_font(L, 1);
    if (!*font) {
        return luaL_error(L, "Font has been destroyed");
    }

    const char* text = luaL_checkstring(L, 2);
    float w, h;
    text_measure(*font, text, &w, &h);

    lua_pushnumber(L, w);
    lua_pushnumber(L, h);
    return 2;
}

// font:set_size(size)
static int l_font_set_size(lua_State* L) {
    Font** font = check_font(L, 1);
    if (!*font) {
        return luaL_error(L, "Font has been destroyed");
    }

    float size = (float)luaL_checknumber(L, 2);
    if (!font_set_size(*font, size)) {
        return luaL_error(L, "Failed to set font size");
    }
    return 0;
}

// font:get_size() -> number
static int l_font_get_size(lua_State* L) {
    Font** font = check_font(L, 1);
    if (!*font) {
        return luaL_error(L, "Font has been destroyed");
    }

    lua_pushnumber(L, (*font)->font_size);
    return 1;
}

// font:get_line_height() -> number
static int l_font_get_line_height(lua_State* L) {
    Font** font = check_font(L, 1);
    if (!*font) {
        return luaL_error(L, "Font has been destroyed");
    }

    lua_pushnumber(L, (*font)->line_height);
    return 1;
}

// font:destroy()
static int l_font_destroy(lua_State* L) {
    Font** font = check_font(L, 1);
    if (*font) {
        font_destroy(*font);
        *font = NULL;
    }
    return 0;
}

// pudim.text.flush() - flush pending text draws
static int l_text_flush(lua_State* L) {
    (void)L;
    text_renderer_flush();
    return 0;
}

// Garbage collector
static int l_font_gc(lua_State* L) {
    Font** font = check_font(L, 1);
    if (*font) {
        font_destroy(*font);
        *font = NULL;
    }
    return 0;
}

// Metatable methods (instance methods on Font userdata)
static const luaL_Reg font_methods[] = {
    {"draw", l_font_draw},
    {"measure", l_font_measure},
    {"set_size", l_font_set_size},
    {"get_size", l_font_get_size},
    {"get_line_height", l_font_get_line_height},
    {"destroy", l_font_destroy},
    {NULL, NULL}
};

// Module functions (PudimBasicsGl.text.*)
static const luaL_Reg text_functions[] = {
    {"load", l_text_load},
    {"flush", l_text_flush},
    {NULL, NULL}
};

void lua_register_text_api(lua_State* L) {
    // Create metatable for Font objects
    luaL_newmetatable(L, FONT_METATABLE);

    lua_pushstring(L, "__index");
    lua_pushvalue(L, -2);  // push metatable
    lua_settable(L, -3);   // metatable.__index = metatable

    lua_pushstring(L, "__gc");
    lua_pushcfunction(L, l_font_gc);
    lua_settable(L, -3);

    // Register methods
    luaL_setfuncs(L, font_methods, 0);
    lua_pop(L, 1);

    // Create PudimBasicsGl.text table
    lua_getglobal(L, "PudimBasicsGl");
    if (lua_isnil(L, -1)) {
        lua_pop(L, 1);
        lua_newtable(L);
        lua_setglobal(L, "PudimBasicsGl");
        lua_getglobal(L, "PudimBasicsGl");
    }
    lua_newtable(L);
    luaL_setfuncs(L, text_functions, 0);
    lua_setfield(L, -2, "text");
    lua_pop(L, 1);
}
