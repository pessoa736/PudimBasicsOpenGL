#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

static double g_time_start = 0;
static double g_delta_time = 0;
static double g_last_frame_time = 0;
static int g_time_initialized = 0;

// Auto-initialize on first use
static void ensure_time_init(void) {
    if (!g_time_initialized) {
        g_time_start = glfwGetTime();
        g_last_frame_time = g_time_start;
        g_time_initialized = 1;
    }
}

// pudim.time.get() -> number (total time since start)
// Accept optional self when called as pb.time:get()
static int l_time_get(lua_State* L) {
    ensure_time_init();
    lua_pushnumber(L, glfwGetTime() - g_time_start);
    return 1;
}

// pudim.time.delta() -> number (time since last frame)
// Accept optional self when called as pb.time:delta()
static int l_time_delta(lua_State* L) {
    lua_pushnumber(L, g_delta_time);
    return 1;
}

// pudim.time.update() - call once per frame to update delta time
// Accept optional self when called as pb.time:update()
static int l_time_update(lua_State* L) {
    (void)L;
    ensure_time_init();
    double current = glfwGetTime();
    g_delta_time = current - g_last_frame_time;
    g_last_frame_time = current;
    return 0;
}

// pudim.time.fps() -> number
// Accept optional self when called as pb.time:fps()
static int l_time_fps(lua_State* L) {
    if (g_delta_time > 0) {
        lua_pushnumber(L, 1.0 / g_delta_time);
    } else {
        lua_pushnumber(L, 0);
    }
    return 1;
}

// pudim.time.sleep(seconds)
// Accept optional self when called as pb.time:sleep(seconds)
static int l_time_sleep(lua_State* L) {
    int arg = 1;
    if (lua_istable(L, 1)) arg = 2; // pb.time:sleep(seconds)
    double seconds = luaL_checknumber(L, arg);
    double start = glfwGetTime();
    while (glfwGetTime() - start < seconds) {
        // Busy wait (for small delays)
    }
    return 0;
}

static const luaL_Reg time_funcs[] = {
    {"get", l_time_get},
    {"delta", l_time_delta},
    {"update", l_time_update},
    {"fps", l_time_fps},
    {"sleep", l_time_sleep},
    {NULL, NULL}
};

void lua_register_time_api(lua_State* L) {
    lua_getglobal(L, "PudimBasicsGl");
    if (lua_isnil(L, -1)) {
        lua_pop(L, 1);
        lua_newtable(L);
        lua_setglobal(L, "PudimBasicsGl");
        lua_getglobal(L, "PudimBasicsGl");
    }
    
    // Create time subtable
    lua_newtable(L);
    luaL_setfuncs(L, time_funcs, 0);
    lua_setfield(L, -2, "time");
    
    lua_pop(L, 1);
}
