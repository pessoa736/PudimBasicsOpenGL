#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <glad/glad.h>
#include "../render/renderer.h"

// Helper to get color from Lua (r,g,b,a or table)
static Color get_color_from_lua(lua_State* L, int start_idx) {
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

// pudim.renderer.init()
static int l_renderer_init(lua_State* L) {
    (void)L;
    renderer_init();
    return 0;
}

// pudim.renderer.clear(r, g, b, a?)
static int l_renderer_clear(lua_State* L) {
    float r = (float)luaL_checknumber(L, 1);
    float g = (float)luaL_checknumber(L, 2);
    float b = (float)luaL_checknumber(L, 3);
    float a = (float)luaL_optnumber(L, 4, 1.0);
    
    renderer_clear(r, g, b, a);
    return 0;
}

// pudim.renderer.begin(width, height)
static int l_renderer_begin(lua_State* L) {
    int width = (int)luaL_checkinteger(L, 1);
    int height = (int)luaL_checkinteger(L, 2);
    renderer_begin(width, height);
    return 0;
}

// pudim.renderer.finish()
static int l_renderer_end(lua_State* L) {
    (void)L;
    renderer_end();
    return 0;
}

// pudim.renderer.flush()
static int l_renderer_flush(lua_State* L) {
    (void)L;
    renderer_flush();
    return 0;
}

// pudim.renderer.pixel(x, y, r, g, b, a?) or pixel(x, y, color_table)
static int l_renderer_pixel(lua_State* L) {
    int x = (int)luaL_checkinteger(L, 1);
    int y = (int)luaL_checkinteger(L, 2);
    Color c = get_color_from_lua(L, 3);
    render_pixel(x, y, c);
    return 0;
}

// pudim.renderer.line(x1, y1, x2, y2, r, g, b, a?)
static int l_renderer_line(lua_State* L) {
    int x1 = (int)luaL_checkinteger(L, 1);
    int y1 = (int)luaL_checkinteger(L, 2);
    int x2 = (int)luaL_checkinteger(L, 3);
    int y2 = (int)luaL_checkinteger(L, 4);
    Color c = get_color_from_lua(L, 5);
    render_line(x1, y1, x2, y2, c);
    return 0;
}

// pudim.renderer.rect(x, y, w, h, r, g, b, a?)
static int l_renderer_rect(lua_State* L) {
    int x = (int)luaL_checkinteger(L, 1);
    int y = (int)luaL_checkinteger(L, 2);
    int w = (int)luaL_checkinteger(L, 3);
    int h = (int)luaL_checkinteger(L, 4);
    Color c = get_color_from_lua(L, 5);
    render_rect(x, y, w, h, c);
    return 0;
}

// pudim.renderer.rect_filled(x, y, w, h, r, g, b, a?)
static int l_renderer_rect_filled(lua_State* L) {
    int x = (int)luaL_checkinteger(L, 1);
    int y = (int)luaL_checkinteger(L, 2);
    int w = (int)luaL_checkinteger(L, 3);
    int h = (int)luaL_checkinteger(L, 4);
    Color c = get_color_from_lua(L, 5);
    render_rect_filled(x, y, w, h, c);
    return 0;
}

// pudim.renderer.circle(cx, cy, radius, r, g, b, a?)
static int l_renderer_circle(lua_State* L) {
    int cx = (int)luaL_checkinteger(L, 1);
    int cy = (int)luaL_checkinteger(L, 2);
    int radius = (int)luaL_checkinteger(L, 3);
    Color c = get_color_from_lua(L, 4);
    render_circle(cx, cy, radius, c);
    return 0;
}

// pudim.renderer.circle_filled(cx, cy, radius, r, g, b, a?)
static int l_renderer_circle_filled(lua_State* L) {
    int cx = (int)luaL_checkinteger(L, 1);
    int cy = (int)luaL_checkinteger(L, 2);
    int radius = (int)luaL_checkinteger(L, 3);
    Color c = get_color_from_lua(L, 4);
    render_circle_filled(cx, cy, radius, c);
    return 0;
}

// pudim.renderer.triangle(x1, y1, x2, y2, x3, y3, r, g, b, a?)
static int l_renderer_triangle(lua_State* L) {
    int x1 = (int)luaL_checkinteger(L, 1);
    int y1 = (int)luaL_checkinteger(L, 2);
    int x2 = (int)luaL_checkinteger(L, 3);
    int y2 = (int)luaL_checkinteger(L, 4);
    int x3 = (int)luaL_checkinteger(L, 5);
    int y3 = (int)luaL_checkinteger(L, 6);
    Color c = get_color_from_lua(L, 7);
    render_triangle(x1, y1, x2, y2, x3, y3, c);
    return 0;
}

// pudim.renderer.triangle_filled(x1, y1, x2, y2, x3, y3, r, g, b, a?)
static int l_renderer_triangle_filled(lua_State* L) {
    int x1 = (int)luaL_checkinteger(L, 1);
    int y1 = (int)luaL_checkinteger(L, 2);
    int x2 = (int)luaL_checkinteger(L, 3);
    int y2 = (int)luaL_checkinteger(L, 4);
    int x3 = (int)luaL_checkinteger(L, 5);
    int y3 = (int)luaL_checkinteger(L, 6);
    Color c = get_color_from_lua(L, 7);
    render_triangle_filled(x1, y1, x2, y2, x3, y3, c);
    return 0;
}

// pudim.renderer.set_point_size(size)
static int l_renderer_set_point_size(lua_State* L) {
    float size = (float)luaL_checknumber(L, 1);
    render_set_point_size(size);
    return 0;
}

// pudim.renderer.set_line_width(width)
static int l_renderer_set_line_width(lua_State* L) {
    float width = (float)luaL_checknumber(L, 1);
    render_set_line_width(width);
    return 0;
}

// pudim.renderer.color(r, g, b, a?) -> table
static int l_renderer_color(lua_State* L) {
    float r, g, b, a = 1.0f;
    
    if (lua_gettop(L) == 1 && lua_isinteger(L, 1)) {
        // Hex color
        unsigned int hex = (unsigned int)lua_tointeger(L, 1);
        r = ((hex >> 16) & 0xFF) / 255.0f;
        g = ((hex >> 8) & 0xFF) / 255.0f;
        b = (hex & 0xFF) / 255.0f;
    } else {
        r = (float)luaL_checknumber(L, 1);
        g = (float)luaL_checknumber(L, 2);
        b = (float)luaL_checknumber(L, 3);
        a = (float)luaL_optnumber(L, 4, 1.0);
    }
    
    lua_newtable(L);
    lua_pushnumber(L, r); lua_setfield(L, -2, "r");
    lua_pushnumber(L, g); lua_setfield(L, -2, "g");
    lua_pushnumber(L, b); lua_setfield(L, -2, "b");
    lua_pushnumber(L, a); lua_setfield(L, -2, "a");
    return 1;
}

// pudim.renderer.set_clear_color(r, g, b, a?)
static int l_renderer_set_clear_color(lua_State* L) {
    float r = (float)luaL_checknumber(L, 1);
    float g = (float)luaL_checknumber(L, 2);
    float b = (float)luaL_checknumber(L, 3);
    float a = (float)luaL_optnumber(L, 4, 1.0);
    
    glClearColor(r, g, b, a);
    return 0;
}

// pudim.renderer.enable_depth_test(enable)
static int l_renderer_enable_depth_test(lua_State* L) {
    int enable = lua_toboolean(L, 1);
    if (enable) {
        glEnable(GL_DEPTH_TEST);
    } else {
        glDisable(GL_DEPTH_TEST);
    }
    return 0;
}

// pudim.renderer.enable_blend(enable)
static int l_renderer_enable_blend(lua_State* L) {
    int enable = lua_toboolean(L, 1);
    if (enable) {
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    } else {
        glDisable(GL_BLEND);
    }
    return 0;
}

// pudim.renderer.set_viewport(x, y, width, height)
static int l_renderer_set_viewport(lua_State* L) {
    int x = (int)luaL_checkinteger(L, 1);
    int y = (int)luaL_checkinteger(L, 2);
    int w = (int)luaL_checkinteger(L, 3);
    int h = (int)luaL_checkinteger(L, 4);
    
    renderer_set_viewport(x, y, w, h);
    return 0;
}

// pudim.renderer.get_info() -> table with opengl info
static int l_renderer_get_info(lua_State* L) {
    lua_newtable(L);
    
    lua_pushstring(L, (const char*)glGetString(GL_VERSION));
    lua_setfield(L, -2, "version");
    
    lua_pushstring(L, (const char*)glGetString(GL_RENDERER));
    lua_setfield(L, -2, "renderer");
    
    lua_pushstring(L, (const char*)glGetString(GL_VENDOR));
    lua_setfield(L, -2, "vendor");
    
    lua_pushstring(L, (const char*)glGetString(GL_SHADING_LANGUAGE_VERSION));
    lua_setfield(L, -2, "glsl_version");
    
    return 1;
}

static const luaL_Reg renderer_funcs[] = {
    {"init", l_renderer_init},
    {"clear", l_renderer_clear},
    {"begin", l_renderer_begin},
    {"finish", l_renderer_end},
    {"flush", l_renderer_flush},
    {"pixel", l_renderer_pixel},
    {"line", l_renderer_line},
    {"rect", l_renderer_rect},
    {"rect_filled", l_renderer_rect_filled},
    {"circle", l_renderer_circle},
    {"circle_filled", l_renderer_circle_filled},
    {"triangle", l_renderer_triangle},
    {"triangle_filled", l_renderer_triangle_filled},
    {"set_point_size", l_renderer_set_point_size},
    {"set_line_width", l_renderer_set_line_width},
    {"color", l_renderer_color},
    {"set_clear_color", l_renderer_set_clear_color},
    {"enable_depth_test", l_renderer_enable_depth_test},
    {"enable_blend", l_renderer_enable_blend},
    {"set_viewport", l_renderer_set_viewport},
    {"get_info", l_renderer_get_info},
    {NULL, NULL}
};

void lua_register_renderer_api(lua_State* L) {
    lua_getglobal(L, "PudimBasicsGl");
    if (lua_isnil(L, -1)) {
        lua_pop(L, 1);
        lua_newtable(L);
        lua_setglobal(L, "PudimBasicsGl");
        lua_getglobal(L, "PudimBasicsGl");
    }
    
    // Create renderer subtable
    lua_newtable(L);
    luaL_setfuncs(L, renderer_funcs, 0);
    
    // Add predefined colors
    lua_newtable(L);
    
    #define ADD_COLOR(name, r, g, b) \
        lua_newtable(L); \
        lua_pushnumber(L, r); lua_setfield(L, -2, "r"); \
        lua_pushnumber(L, g); lua_setfield(L, -2, "g"); \
        lua_pushnumber(L, b); lua_setfield(L, -2, "b"); \
        lua_pushnumber(L, 1.0); lua_setfield(L, -2, "a"); \
        lua_setfield(L, -2, name);
    
    ADD_COLOR("WHITE", 1.0, 1.0, 1.0);
    ADD_COLOR("BLACK", 0.0, 0.0, 0.0);
    ADD_COLOR("RED", 1.0, 0.0, 0.0);
    ADD_COLOR("GREEN", 0.0, 1.0, 0.0);
    ADD_COLOR("BLUE", 0.0, 0.0, 1.0);
    ADD_COLOR("YELLOW", 1.0, 1.0, 0.0);
    ADD_COLOR("CYAN", 0.0, 1.0, 1.0);
    ADD_COLOR("MAGENTA", 1.0, 0.0, 1.0);
    ADD_COLOR("ORANGE", 1.0, 0.5, 0.0);
    ADD_COLOR("PURPLE", 0.5, 0.0, 0.5);
    ADD_COLOR("GRAY", 0.5, 0.5, 0.5);
    ADD_COLOR("DARK_GRAY", 0.25, 0.25, 0.25);
    ADD_COLOR("LIGHT_GRAY", 0.75, 0.75, 0.75);
    
    #undef ADD_COLOR
    
    lua_setfield(L, -2, "colors");
    
    lua_setfield(L, -2, "renderer");
    
    lua_pop(L, 1);
}
