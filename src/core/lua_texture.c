#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <stdlib.h>
#include "../render/texture.h"

#define TEXTURE_METATABLE "PudimBasicsGl.Texture"

// Track if texture renderer has been initialized
static int texture_renderer_initialized = 0;

// Helper to ensure texture renderer is initialized (lazy init)
static void ensure_texture_renderer_init(void) {
    if (!texture_renderer_initialized) {
        texture_renderer_init();
        texture_renderer_initialized = 1;
    }
}

// Helper to get texture from userdata
static Texture** check_texture(lua_State* L, int index) {
    return (Texture**)luaL_checkudata(L, index, TEXTURE_METATABLE);
}

// PudimBasicsGl.texture.load(filepath) -> Texture
// Accept optional self when called as module:load(filepath)
static int l_texture_load(lua_State* L) {
    int arg = 1;
    if (lua_istable(L, 1)) arg = 2; // allow pb.texture:load(path)
    const char* filepath = luaL_checkstring(L, arg);
    
    // Lazy init texture renderer (needs OpenGL context)
    ensure_texture_renderer_init();
    
    Texture* tex = texture_load(filepath);
    if (!tex) {
        lua_pushnil(L);
        lua_pushstring(L, "Failed to load texture");
        return 2;
    }
    
    Texture** udata = (Texture**)lua_newuserdata(L, sizeof(Texture*));
    *udata = tex;
    
    luaL_getmetatable(L, TEXTURE_METATABLE);
    lua_setmetatable(L, -2);
    
    return 1;
}

// PudimBasicsGl.texture.create(width, height, data?) -> Texture
// Accept optional self when called as module:create(width, height, data?)
static int l_texture_create(lua_State* L) {
    int arg = 1;
    if (lua_istable(L, 1)) arg = 2; // allow pb.texture:create(w,h,...)
    int width = (int)luaL_checkinteger(L, arg);
    int height = (int)luaL_checkinteger(L, arg + 1);
    
    // Lazy init texture renderer (needs OpenGL context)
    ensure_texture_renderer_init();
    
    unsigned char* data = NULL;
    
    // If data table provided, use it
    if (lua_istable(L, arg + 2)) {
        int size = width * height * 4;
        data = (unsigned char*)malloc(size);
        for (int i = 0; i < size; i++) {
            lua_rawgeti(L, arg + 2, i + 1);
            data[i] = (unsigned char)lua_tointeger(L, -1);
            lua_pop(L, 1);
        }
    }
    
    Texture* tex = texture_create(width, height, data);
    if (data) free(data);
    
    if (!tex) {
        lua_pushnil(L);
        lua_pushstring(L, "Failed to create texture");
        return 2;
    }
    
    Texture** udata = (Texture**)lua_newuserdata(L, sizeof(Texture*));
    *udata = tex;
    
    luaL_getmetatable(L, TEXTURE_METATABLE);
    lua_setmetatable(L, -2);
    
    return 1;
}

// texture:destroy()
static int l_texture_destroy(lua_State* L) {
    Texture** tex = check_texture(L, 1);
    if (*tex) {
        texture_destroy(*tex);
        *tex = NULL;
    }
    return 0;
}

// texture:get_size() -> width, height
static int l_texture_get_size(lua_State* L) {
    Texture** tex = check_texture(L, 1);
    if (!*tex) {
        lua_pushnil(L);
        lua_pushnil(L);
        return 2;
    }
    lua_pushinteger(L, (*tex)->width);
    lua_pushinteger(L, (*tex)->height);
    return 2;
}

// texture:get_width() -> number
static int l_texture_get_width(lua_State* L) {
    Texture** tex = check_texture(L, 1);
    lua_pushinteger(L, *tex ? (*tex)->width : 0);
    return 1;
}

// texture:get_height() -> number
static int l_texture_get_height(lua_State* L) {
    Texture** tex = check_texture(L, 1);
    lua_pushinteger(L, *tex ? (*tex)->height : 0);
    return 1;
}

// texture:draw(x, y, width?, height?)
static int l_texture_draw(lua_State* L) {
    Texture** tex = check_texture(L, 1);
    if (!*tex) return 0;
    
    int x = (int)luaL_checkinteger(L, 2);
    int y = (int)luaL_checkinteger(L, 3);
    int w = (int)luaL_optinteger(L, 4, (*tex)->width);
    int h = (int)luaL_optinteger(L, 5, (*tex)->height);
    
    render_texture(*tex, x, y, w, h);
    return 0;
}

// texture:draw_tinted(x, y, w, h, r, g, b, a?)
static int l_texture_draw_tinted(lua_State* L) {
    Texture** tex = check_texture(L, 1);
    if (!*tex) return 0;
    
    int x = (int)luaL_checkinteger(L, 2);
    int y = (int)luaL_checkinteger(L, 3);
    int w = (int)luaL_checkinteger(L, 4);
    int h = (int)luaL_checkinteger(L, 5);
    float r = (float)luaL_checknumber(L, 6);
    float g = (float)luaL_checknumber(L, 7);
    float b = (float)luaL_checknumber(L, 8);
    float a = (float)luaL_optnumber(L, 9, 1.0);
    
    render_texture_tinted(*tex, x, y, w, h, r, g, b, a);
    return 0;
}

// texture:draw_rotated(x, y, w, h, angle)
static int l_texture_draw_rotated(lua_State* L) {
    Texture** tex = check_texture(L, 1);
    if (!*tex) return 0;
    
    int x = (int)luaL_checkinteger(L, 2);
    int y = (int)luaL_checkinteger(L, 3);
    int w = (int)luaL_checkinteger(L, 4);
    int h = (int)luaL_checkinteger(L, 5);
    float angle = (float)luaL_checknumber(L, 6);
    
    render_texture_rotated(*tex, x, y, w, h, angle);
    return 0;
}

// texture:draw_ex(x, y, w, h, angle, origin_x, origin_y, r, g, b, a?)
static int l_texture_draw_ex(lua_State* L) {
    Texture** tex = check_texture(L, 1);
    if (!*tex) return 0;
    
    int x = (int)luaL_checkinteger(L, 2);
    int y = (int)luaL_checkinteger(L, 3);
    int w = (int)luaL_checkinteger(L, 4);
    int h = (int)luaL_checkinteger(L, 5);
    float angle = (float)luaL_checknumber(L, 6);
    float ox = (float)luaL_optnumber(L, 7, 0.5);
    float oy = (float)luaL_optnumber(L, 8, 0.5);
    float r = (float)luaL_optnumber(L, 9, 1.0);
    float g = (float)luaL_optnumber(L, 10, 1.0);
    float b = (float)luaL_optnumber(L, 11, 1.0);
    float a = (float)luaL_optnumber(L, 12, 1.0);
    
    render_texture_ex(*tex, x, y, w, h, angle, ox, oy, r, g, b, a);
    return 0;
}

// texture:draw_region(x, y, w, h, src_x, src_y, src_w, src_h)
static int l_texture_draw_region(lua_State* L) {
    Texture** tex = check_texture(L, 1);
    if (!*tex) return 0;
    
    int x = (int)luaL_checkinteger(L, 2);
    int y = (int)luaL_checkinteger(L, 3);
    int w = (int)luaL_checkinteger(L, 4);
    int h = (int)luaL_checkinteger(L, 5);
    int sx = (int)luaL_checkinteger(L, 6);
    int sy = (int)luaL_checkinteger(L, 7);
    int sw = (int)luaL_checkinteger(L, 8);
    int sh = (int)luaL_checkinteger(L, 9);
    
    render_texture_region(*tex, x, y, w, h, sx, sy, sw, sh);
    return 0;
}

// texture:draw_region_ex(x, y, w, h, src_x, src_y, src_w, src_h, angle, ox, oy, r, g, b, a?)
static int l_texture_draw_region_ex(lua_State* L) {
    Texture** tex = check_texture(L, 1);
    if (!*tex) return 0;
    
    int x = (int)luaL_checkinteger(L, 2);
    int y = (int)luaL_checkinteger(L, 3);
    int w = (int)luaL_checkinteger(L, 4);
    int h = (int)luaL_checkinteger(L, 5);
    int sx = (int)luaL_checkinteger(L, 6);
    int sy = (int)luaL_checkinteger(L, 7);
    int sw = (int)luaL_checkinteger(L, 8);
    int sh = (int)luaL_checkinteger(L, 9);
    float angle = (float)luaL_optnumber(L, 10, 0.0);
    float ox = (float)luaL_optnumber(L, 11, 0.5);
    float oy = (float)luaL_optnumber(L, 12, 0.5);
    float r = (float)luaL_optnumber(L, 13, 1.0);
    float g = (float)luaL_optnumber(L, 14, 1.0);
    float b = (float)luaL_optnumber(L, 15, 1.0);
    float a = (float)luaL_optnumber(L, 16, 1.0);
    
    render_texture_region_ex(*tex, x, y, w, h, sx, sy, sw, sh, angle, ox, oy, r, g, b, a);
    return 0;
}

// PudimBasicsGl.texture.flush() - flush pending texture draws
static int l_texture_flush(lua_State* L) {
    (void)L;
    texture_renderer_flush();
    return 0;
}

// Garbage collector
static int l_texture_gc(lua_State* L) {
    Texture** tex = check_texture(L, 1);
    if (*tex) {
        texture_destroy(*tex);
        *tex = NULL;
    }
    return 0;
}

// Metatable methods
static const luaL_Reg texture_methods[] = {
    {"destroy", l_texture_destroy},
    {"get_size", l_texture_get_size},
    {"get_width", l_texture_get_width},
    {"get_height", l_texture_get_height},
    {"draw", l_texture_draw},
    {"draw_tinted", l_texture_draw_tinted},
    {"draw_rotated", l_texture_draw_rotated},
    {"draw_ex", l_texture_draw_ex},
    {"draw_region", l_texture_draw_region},
    {"draw_region_ex", l_texture_draw_region_ex},
    {NULL, NULL}
};

// Module functions
static const luaL_Reg texture_functions[] = {
    {"load", l_texture_load},
    {"create", l_texture_create},
    {"flush", l_texture_flush},
    {NULL, NULL}
};

void lua_register_texture_api(lua_State* L) {
    // Create metatable for Texture objects
    luaL_newmetatable(L, TEXTURE_METATABLE);
    
    lua_pushstring(L, "__index");
    lua_pushvalue(L, -2);  // push metatable
    lua_settable(L, -3);   // metatable.__index = metatable
    
    lua_pushstring(L, "__gc");
    lua_pushcfunction(L, l_texture_gc);
    lua_settable(L, -3);
    
    // Register methods
    luaL_setfuncs(L, texture_methods, 0);
    lua_pop(L, 1);
    
    // Create PudimBasicsGl.texture table
    lua_getglobal(L, "PudimBasicsGl");
    lua_newtable(L);
    luaL_setfuncs(L, texture_functions, 0);
    lua_setfield(L, -2, "texture");
    lua_pop(L, 1);
    
    // NOTE: texture_renderer_init() will be called lazily on first texture load/create
    // because OpenGL context may not exist yet at library load time
}
