#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <stdlib.h>
#include "../render/shader.h"

#define SHADER_METATABLE "PudimBasicsGl.Shader"

// Helper to get shader from userdata
static Shader** check_shader(lua_State* L, int index) {
    return (Shader**)luaL_checkudata(L, index, SHADER_METATABLE);
}

// pudim.shader.create(vertex_src, fragment_src) -> Shader | nil, string
static int l_shader_create(lua_State* L) {
    int arg = 1;
    if (lua_istable(L, 1)) arg = 2; // allow pb.shader:create(...)

    const char* vertex_src = luaL_checkstring(L, arg);
    const char* fragment_src = luaL_checkstring(L, arg + 1);

    Shader* shader = shader_create(vertex_src, fragment_src);
    if (!shader) {
        lua_pushnil(L);
        lua_pushstring(L, "Failed to compile/link shader program");
        return 2;
    }

    Shader** udata = (Shader**)lua_newuserdata(L, sizeof(Shader*));
    *udata = shader;

    luaL_getmetatable(L, SHADER_METATABLE);
    lua_setmetatable(L, -2);

    return 1;
}

// pudim.shader.load(vertex_path, fragment_path) -> Shader | nil, string
static int l_shader_load(lua_State* L) {
    int arg = 1;
    if (lua_istable(L, 1)) arg = 2; // allow pb.shader:load(...)

    const char* vertex_path = luaL_checkstring(L, arg);
    const char* fragment_path = luaL_checkstring(L, arg + 1);

    Shader* shader = shader_load(vertex_path, fragment_path);
    if (!shader) {
        lua_pushnil(L);
        lua_pushstring(L, "Failed to load/compile shader from files");
        return 2;
    }

    Shader** udata = (Shader**)lua_newuserdata(L, sizeof(Shader*));
    *udata = shader;

    luaL_getmetatable(L, SHADER_METATABLE);
    lua_setmetatable(L, -2);

    return 1;
}

// shader:use()
static int l_shader_use(lua_State* L) {
    Shader** s = check_shader(L, 1);
    if (*s) {
        shader_use(*s);
    }
    return 0;
}

// shader:unuse() or pudim.shader.unuse()
static int l_shader_unuse(lua_State* L) {
    (void)L;
    shader_unuse();
    return 0;
}

// shader:set_int(name, value)
static int l_shader_set_int(lua_State* L) {
    Shader** s = check_shader(L, 1);
    if (!*s) return 0;
    const char* name = luaL_checkstring(L, 2);
    int value = (int)luaL_checkinteger(L, 3);
    shader_set_int(*s, name, value);
    return 0;
}

// shader:set_float(name, value)
static int l_shader_set_float(lua_State* L) {
    Shader** s = check_shader(L, 1);
    if (!*s) return 0;
    const char* name = luaL_checkstring(L, 2);
    float value = (float)luaL_checknumber(L, 3);
    shader_set_float(*s, name, value);
    return 0;
}

// shader:set_vec2(name, x, y)
static int l_shader_set_vec2(lua_State* L) {
    Shader** s = check_shader(L, 1);
    if (!*s) return 0;
    const char* name = luaL_checkstring(L, 2);
    float x = (float)luaL_checknumber(L, 3);
    float y = (float)luaL_checknumber(L, 4);
    shader_set_vec2(*s, name, x, y);
    return 0;
}

// shader:set_vec3(name, x, y, z)
static int l_shader_set_vec3(lua_State* L) {
    Shader** s = check_shader(L, 1);
    if (!*s) return 0;
    const char* name = luaL_checkstring(L, 2);
    float x = (float)luaL_checknumber(L, 3);
    float y = (float)luaL_checknumber(L, 4);
    float z = (float)luaL_checknumber(L, 5);
    shader_set_vec3(*s, name, x, y, z);
    return 0;
}

// shader:set_vec4(name, x, y, z, w)
static int l_shader_set_vec4(lua_State* L) {
    Shader** s = check_shader(L, 1);
    if (!*s) return 0;
    const char* name = luaL_checkstring(L, 2);
    float x = (float)luaL_checknumber(L, 3);
    float y = (float)luaL_checknumber(L, 4);
    float z = (float)luaL_checknumber(L, 5);
    float w = (float)luaL_checknumber(L, 6);
    shader_set_vec4(*s, name, x, y, z, w);
    return 0;
}

// shader:set_mat4(name, {m1, m2, ..., m16})
static int l_shader_set_mat4(lua_State* L) {
    Shader** s = check_shader(L, 1);
    if (!*s) return 0;
    const char* name = luaL_checkstring(L, 2);
    luaL_checktype(L, 3, LUA_TTABLE);

    float matrix[16];
    for (int i = 0; i < 16; i++) {
        lua_rawgeti(L, 3, i + 1);
        matrix[i] = (float)luaL_checknumber(L, -1);
        lua_pop(L, 1);
    }

    shader_set_mat4(*s, name, matrix);
    return 0;
}

// shader:get_id() -> integer (the GL program ID)
static int l_shader_get_id(lua_State* L) {
    Shader** s = check_shader(L, 1);
    if (!*s || !(*s)->valid) {
        lua_pushinteger(L, 0);
    } else {
        lua_pushinteger(L, (lua_Integer)(*s)->program);
    }
    return 1;
}

// shader:is_valid() -> boolean
static int l_shader_is_valid(lua_State* L) {
    Shader** s = check_shader(L, 1);
    lua_pushboolean(L, *s && (*s)->valid);
    return 1;
}

// shader:destroy()
static int l_shader_destroy(lua_State* L) {
    Shader** s = check_shader(L, 1);
    if (*s) {
        shader_destroy(*s);
        *s = NULL;
    }
    return 0;
}

// Garbage collector
static int l_shader_gc(lua_State* L) {
    Shader** s = check_shader(L, 1);
    if (*s) {
        shader_destroy(*s);
        *s = NULL;
    }
    return 0;
}

// Metatable methods (instance methods)
static const luaL_Reg shader_methods[] = {
    {"use",       l_shader_use},
    {"unuse",     l_shader_unuse},
    {"set_int",   l_shader_set_int},
    {"set_float", l_shader_set_float},
    {"set_vec2",  l_shader_set_vec2},
    {"set_vec3",  l_shader_set_vec3},
    {"set_vec4",  l_shader_set_vec4},
    {"set_mat4",  l_shader_set_mat4},
    {"get_id",    l_shader_get_id},
    {"is_valid",  l_shader_is_valid},
    {"destroy",   l_shader_destroy},
    {NULL, NULL}
};

// Module functions
static const luaL_Reg shader_functions[] = {
    {"create", l_shader_create},
    {"load",   l_shader_load},
    {"unuse",  l_shader_unuse},
    {NULL, NULL}
};

void lua_register_shader_api(lua_State* L) {
    // Create metatable for Shader objects
    luaL_newmetatable(L, SHADER_METATABLE);

    lua_pushvalue(L, -1);
    lua_setfield(L, -2, "__index"); // metatable.__index = metatable

    lua_pushcfunction(L, l_shader_gc);
    lua_setfield(L, -2, "__gc");

    // Register instance methods
    luaL_setfuncs(L, shader_methods, 0);
    lua_pop(L, 1);

    // Create PudimBasicsGl.shader table
    lua_getglobal(L, "PudimBasicsGl");
    if (lua_isnil(L, -1)) {
        lua_pop(L, 1);
        lua_newtable(L);
        lua_setglobal(L, "PudimBasicsGl");
        lua_getglobal(L, "PudimBasicsGl");
    }
    lua_newtable(L);
    luaL_setfuncs(L, shader_functions, 0);
    lua_setfield(L, -2, "shader");
    lua_pop(L, 1);
}
