#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <math.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

// pudim.math.lerp(a, b, t) -> number
static int l_math_lerp(lua_State* L) {
    double a = luaL_checknumber(L, 1);
    double b = luaL_checknumber(L, 2);
    double t = luaL_checknumber(L, 3);
    
    lua_pushnumber(L, a + (b - a) * t);
    return 1;
}

// pudim.math.clamp(value, min, max) -> number
static int l_math_clamp(lua_State* L) {
    double value = luaL_checknumber(L, 1);
    double min = luaL_checknumber(L, 2);
    double max = luaL_checknumber(L, 3);
    
    if (value < min) value = min;
    if (value > max) value = max;
    
    lua_pushnumber(L, value);
    return 1;
}

// pudim.math.radians(degrees) -> number
static int l_math_radians(lua_State* L) {
    double degrees = luaL_checknumber(L, 1);
    lua_pushnumber(L, degrees * M_PI / 180.0);
    return 1;
}

// pudim.math.degrees(radians) -> number
static int l_math_degrees(lua_State* L) {
    double radians = luaL_checknumber(L, 1);
    lua_pushnumber(L, radians * 180.0 / M_PI);
    return 1;
}

// pudim.math.vec2(x, y) -> table
static int l_math_vec2(lua_State* L) {
    double x = luaL_optnumber(L, 1, 0.0);
    double y = luaL_optnumber(L, 2, 0.0);
    
    lua_newtable(L);
    lua_pushnumber(L, x); lua_setfield(L, -2, "x");
    lua_pushnumber(L, y); lua_setfield(L, -2, "y");
    
    return 1;
}

// pudim.math.vec3(x, y, z) -> table
static int l_math_vec3(lua_State* L) {
    double x = luaL_optnumber(L, 1, 0.0);
    double y = luaL_optnumber(L, 2, 0.0);
    double z = luaL_optnumber(L, 3, 0.0);
    
    lua_newtable(L);
    lua_pushnumber(L, x); lua_setfield(L, -2, "x");
    lua_pushnumber(L, y); lua_setfield(L, -2, "y");
    lua_pushnumber(L, z); lua_setfield(L, -2, "z");
    
    return 1;
}

// pudim.math.vec4(x, y, z, w) -> table
static int l_math_vec4(lua_State* L) {
    double x = luaL_optnumber(L, 1, 0.0);
    double y = luaL_optnumber(L, 2, 0.0);
    double z = luaL_optnumber(L, 3, 0.0);
    double w = luaL_optnumber(L, 4, 0.0);
    
    lua_newtable(L);
    lua_pushnumber(L, x); lua_setfield(L, -2, "x");
    lua_pushnumber(L, y); lua_setfield(L, -2, "y");
    lua_pushnumber(L, z); lua_setfield(L, -2, "z");
    lua_pushnumber(L, w); lua_setfield(L, -2, "w");
    
    return 1;
}

// pudim.math.vec_add(v1, v2) -> table
static int l_math_vec_add(lua_State* L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    luaL_checktype(L, 2, LUA_TTABLE);
    
    lua_newtable(L);
    
    lua_getfield(L, 1, "x"); double x1 = lua_tonumber(L, -1); lua_pop(L, 1);
    lua_getfield(L, 2, "x"); double x2 = lua_tonumber(L, -1); lua_pop(L, 1);
    lua_getfield(L, 1, "y"); double y1 = lua_tonumber(L, -1); lua_pop(L, 1);
    lua_getfield(L, 2, "y"); double y2 = lua_tonumber(L, -1); lua_pop(L, 1);
    
    lua_pushnumber(L, x1 + x2); lua_setfield(L, -2, "x");
    lua_pushnumber(L, y1 + y2); lua_setfield(L, -2, "y");
    
    // Check for z component
    lua_getfield(L, 1, "z");
    if (!lua_isnil(L, -1)) {
        double z1 = lua_tonumber(L, -1);
        lua_pop(L, 1);
        lua_getfield(L, 2, "z"); double z2 = lua_tonumber(L, -1); lua_pop(L, 1);
        lua_pushnumber(L, z1 + z2); lua_setfield(L, -2, "z");
    } else {
        lua_pop(L, 1);
    }
    
    return 1;
}

// pudim.math.vec_sub(v1, v2) -> table
static int l_math_vec_sub(lua_State* L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    luaL_checktype(L, 2, LUA_TTABLE);
    
    lua_newtable(L);
    
    lua_getfield(L, 1, "x"); double x1 = lua_tonumber(L, -1); lua_pop(L, 1);
    lua_getfield(L, 2, "x"); double x2 = lua_tonumber(L, -1); lua_pop(L, 1);
    lua_getfield(L, 1, "y"); double y1 = lua_tonumber(L, -1); lua_pop(L, 1);
    lua_getfield(L, 2, "y"); double y2 = lua_tonumber(L, -1); lua_pop(L, 1);
    
    lua_pushnumber(L, x1 - x2); lua_setfield(L, -2, "x");
    lua_pushnumber(L, y1 - y2); lua_setfield(L, -2, "y");
    
    lua_getfield(L, 1, "z");
    if (!lua_isnil(L, -1)) {
        double z1 = lua_tonumber(L, -1);
        lua_pop(L, 1);
        lua_getfield(L, 2, "z"); double z2 = lua_tonumber(L, -1); lua_pop(L, 1);
        lua_pushnumber(L, z1 - z2); lua_setfield(L, -2, "z");
    } else {
        lua_pop(L, 1);
    }
    
    return 1;
}

// pudim.math.vec_scale(v, scalar) -> table
static int l_math_vec_scale(lua_State* L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    double scalar = luaL_checknumber(L, 2);
    
    lua_newtable(L);
    
    lua_getfield(L, 1, "x"); 
    lua_pushnumber(L, lua_tonumber(L, -1) * scalar); 
    lua_setfield(L, -3, "x");
    lua_pop(L, 1);
    
    lua_getfield(L, 1, "y"); 
    lua_pushnumber(L, lua_tonumber(L, -1) * scalar); 
    lua_setfield(L, -3, "y");
    lua_pop(L, 1);
    
    lua_getfield(L, 1, "z");
    if (!lua_isnil(L, -1)) {
        lua_pushnumber(L, lua_tonumber(L, -1) * scalar);
        lua_setfield(L, -3, "z");
    }
    lua_pop(L, 1);
    
    return 1;
}

// pudim.math.vec_length(v) -> number
static int l_math_vec_length(lua_State* L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    
    lua_getfield(L, 1, "x"); double x = lua_tonumber(L, -1); lua_pop(L, 1);
    lua_getfield(L, 1, "y"); double y = lua_tonumber(L, -1); lua_pop(L, 1);
    
    double z = 0;
    lua_getfield(L, 1, "z");
    if (!lua_isnil(L, -1)) {
        z = lua_tonumber(L, -1);
    }
    lua_pop(L, 1);
    
    lua_pushnumber(L, sqrt(x*x + y*y + z*z));
    return 1;
}

// pudim.math.vec_normalize(v) -> table
static int l_math_vec_normalize(lua_State* L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    
    lua_getfield(L, 1, "x"); double x = lua_tonumber(L, -1); lua_pop(L, 1);
    lua_getfield(L, 1, "y"); double y = lua_tonumber(L, -1); lua_pop(L, 1);
    
    double z = 0;
    int has_z = 0;
    lua_getfield(L, 1, "z");
    if (!lua_isnil(L, -1)) {
        z = lua_tonumber(L, -1);
        has_z = 1;
    }
    lua_pop(L, 1);
    
    double len = sqrt(x*x + y*y + z*z);
    if (len > 0.0001) {
        x /= len;
        y /= len;
        z /= len;
    }
    
    lua_newtable(L);
    lua_pushnumber(L, x); lua_setfield(L, -2, "x");
    lua_pushnumber(L, y); lua_setfield(L, -2, "y");
    if (has_z) {
        lua_pushnumber(L, z); lua_setfield(L, -2, "z");
    }
    
    return 1;
}

// pudim.math.vec_dot(v1, v2) -> number
static int l_math_vec_dot(lua_State* L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    luaL_checktype(L, 2, LUA_TTABLE);
    
    lua_getfield(L, 1, "x"); double x1 = lua_tonumber(L, -1); lua_pop(L, 1);
    lua_getfield(L, 2, "x"); double x2 = lua_tonumber(L, -1); lua_pop(L, 1);
    lua_getfield(L, 1, "y"); double y1 = lua_tonumber(L, -1); lua_pop(L, 1);
    lua_getfield(L, 2, "y"); double y2 = lua_tonumber(L, -1); lua_pop(L, 1);
    
    double result = x1*x2 + y1*y2;
    
    lua_getfield(L, 1, "z");
    if (!lua_isnil(L, -1)) {
        double z1 = lua_tonumber(L, -1);
        lua_pop(L, 1);
        lua_getfield(L, 2, "z"); double z2 = lua_tonumber(L, -1); lua_pop(L, 1);
        result += z1 * z2;
    } else {
        lua_pop(L, 1);
    }
    
    lua_pushnumber(L, result);
    return 1;
}

static const luaL_Reg math_funcs[] = {
    {"lerp", l_math_lerp},
    {"clamp", l_math_clamp},
    {"radians", l_math_radians},
    {"degrees", l_math_degrees},
    {"vec2", l_math_vec2},
    {"vec3", l_math_vec3},
    {"vec4", l_math_vec4},
    {"vec_add", l_math_vec_add},
    {"vec_sub", l_math_vec_sub},
    {"vec_scale", l_math_vec_scale},
    {"vec_length", l_math_vec_length},
    {"vec_normalize", l_math_vec_normalize},
    {"vec_dot", l_math_vec_dot},
    {NULL, NULL}
};

void lua_register_math_api(lua_State* L) {
    lua_getglobal(L, "PudimBasicsGl");
    if (lua_isnil(L, -1)) {
        lua_pop(L, 1);
        lua_newtable(L);
        lua_setglobal(L, "PudimBasicsGl");
        lua_getglobal(L, "PudimBasicsGl");
    }
    
    // Create math subtable (PudimBasicsGl.math, separate from standard math)
    lua_newtable(L);
    luaL_setfuncs(L, math_funcs, 0);
    
    // Add constants
    lua_pushnumber(L, M_PI); lua_setfield(L, -2, "PI");
    lua_pushnumber(L, M_PI * 2); lua_setfield(L, -2, "TAU");
    lua_pushnumber(L, M_PI / 2); lua_setfield(L, -2, "HALF_PI");
    
    lua_setfield(L, -2, "math");
    
    lua_pop(L, 1);
}
