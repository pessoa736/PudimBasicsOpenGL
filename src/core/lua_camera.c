#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include "../render/camera.h"

// pudim.camera.set_position(x, y)
static int l_camera_set_position(lua_State* L) {
    float x = (float)luaL_checknumber(L, 1);
    float y = (float)luaL_checknumber(L, 2);
    camera_set_position(x, y);
    return 0;
}

// pudim.camera.get_position() -> x, y
static int l_camera_get_position(lua_State* L) {
    float x, y;
    camera_get_position(&x, &y);
    lua_pushnumber(L, x);
    lua_pushnumber(L, y);
    return 2;
}

// pudim.camera.move(dx, dy)
static int l_camera_move(lua_State* L) {
    float dx = (float)luaL_checknumber(L, 1);
    float dy = (float)luaL_checknumber(L, 2);
    camera_move(dx, dy);
    return 0;
}

// pudim.camera.set_zoom(zoom)
static int l_camera_set_zoom(lua_State* L) {
    float zoom = (float)luaL_checknumber(L, 1);
    camera_set_zoom(zoom);
    return 0;
}

// pudim.camera.get_zoom() -> number
static int l_camera_get_zoom(lua_State* L) {
    lua_pushnumber(L, camera_get_zoom());
    return 1;
}

// pudim.camera.set_rotation(angle)
static int l_camera_set_rotation(lua_State* L) {
    float angle = (float)luaL_checknumber(L, 1);
    camera_set_rotation(angle);
    return 0;
}

// pudim.camera.get_rotation() -> number
static int l_camera_get_rotation(lua_State* L) {
    lua_pushnumber(L, camera_get_rotation());
    return 1;
}

// pudim.camera.look_at(x, y, screen_width, screen_height)
static int l_camera_look_at(lua_State* L) {
    float x = (float)luaL_checknumber(L, 1);
    float y = (float)luaL_checknumber(L, 2);
    int sw = (int)luaL_checkinteger(L, 3);
    int sh = (int)luaL_checkinteger(L, 4);
    camera_look_at(x, y, sw, sh);
    return 0;
}

// pudim.camera.reset()
static int l_camera_reset(lua_State* L) {
    (void)L;
    camera_reset();
    return 0;
}

// pudim.camera.screen_to_world(sx, sy) -> wx, wy
static int l_camera_screen_to_world(lua_State* L) {
    float sx = (float)luaL_checknumber(L, 1);
    float sy = (float)luaL_checknumber(L, 2);
    float wx, wy;
    camera_screen_to_world(sx, sy, &wx, &wy);
    lua_pushnumber(L, wx);
    lua_pushnumber(L, wy);
    return 2;
}

// pudim.camera.world_to_screen(wx, wy) -> sx, sy
static int l_camera_world_to_screen(lua_State* L) {
    float wx = (float)luaL_checknumber(L, 1);
    float wy = (float)luaL_checknumber(L, 2);
    float sx, sy;
    camera_world_to_screen(wx, wy, &sx, &sy);
    lua_pushnumber(L, sx);
    lua_pushnumber(L, sy);
    return 2;
}

static const luaL_Reg camera_funcs[] = {
    {"set_position", l_camera_set_position},
    {"get_position", l_camera_get_position},
    {"move", l_camera_move},
    {"set_zoom", l_camera_set_zoom},
    {"get_zoom", l_camera_get_zoom},
    {"set_rotation", l_camera_set_rotation},
    {"get_rotation", l_camera_get_rotation},
    {"look_at", l_camera_look_at},
    {"reset", l_camera_reset},
    {"screen_to_world", l_camera_screen_to_world},
    {"world_to_screen", l_camera_world_to_screen},
    {NULL, NULL}
};

void lua_register_camera_api(lua_State* L) {
    lua_getglobal(L, "PudimBasicsGl");
    if (lua_isnil(L, -1)) {
        lua_pop(L, 1);
        lua_newtable(L);
        lua_setglobal(L, "PudimBasicsGl");
        lua_getglobal(L, "PudimBasicsGl");
    }
    lua_newtable(L);
    luaL_setfuncs(L, camera_funcs, 0);
    lua_setfield(L, -2, "camera");
    lua_pop(L, 1);
}
