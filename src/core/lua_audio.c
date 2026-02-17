#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <stdlib.h>
#include "../audio/audio.h"

#define SOUND_METATABLE "PudimBasicsGl.Sound"

static int audio_engine_initialized = 0;

static void ensure_audio_init(void) {
    if (!audio_engine_initialized) {
        audio_init();
        audio_engine_initialized = 1;
    }
}

static Sound** check_sound(lua_State* L, int index) {
    return (Sound**)luaL_checkudata(L, index, SOUND_METATABLE);
}

// pb.audio.load(filepath) -> Sound
static int l_audio_load(lua_State* L) {
    int arg = 1;
    if (lua_istable(L, 1)) arg = 2;
    const char* filepath = luaL_checkstring(L, arg);

    ensure_audio_init();

    Sound* snd = audio_load(filepath);
    if (!snd) {
        lua_pushnil(L);
        lua_pushstring(L, "Failed to load audio file");
        return 2;
    }

    Sound** udata = (Sound**)lua_newuserdata(L, sizeof(Sound*));
    *udata = snd;

    luaL_getmetatable(L, SOUND_METATABLE);
    lua_setmetatable(L, -2);

    return 1;
}

// sound:play()
static int l_sound_play(lua_State* L) {
    Sound** snd = check_sound(L, 1);
    if (*snd) audio_play(*snd);
    return 0;
}

// sound:stop()
static int l_sound_stop(lua_State* L) {
    Sound** snd = check_sound(L, 1);
    if (*snd) audio_stop(*snd);
    return 0;
}

// sound:pause()
static int l_sound_pause(lua_State* L) {
    Sound** snd = check_sound(L, 1);
    if (*snd) audio_pause(*snd);
    return 0;
}

// sound:resume()
static int l_sound_resume(lua_State* L) {
    Sound** snd = check_sound(L, 1);
    if (*snd) audio_resume(*snd);
    return 0;
}

// sound:is_playing() -> boolean
static int l_sound_is_playing(lua_State* L) {
    Sound** snd = check_sound(L, 1);
    lua_pushboolean(L, *snd ? audio_is_playing(*snd) : 0);
    return 1;
}

// sound:set_looping(loop)
static int l_sound_set_looping(lua_State* L) {
    Sound** snd = check_sound(L, 1);
    int loop = lua_toboolean(L, 2);
    if (*snd) audio_set_looping(*snd, loop);
    return 0;
}

// sound:is_looping() -> boolean
static int l_sound_is_looping(lua_State* L) {
    Sound** snd = check_sound(L, 1);
    lua_pushboolean(L, *snd ? audio_is_looping(*snd) : 0);
    return 1;
}

// sound:set_volume(volume)
static int l_sound_set_volume(lua_State* L) {
    Sound** snd = check_sound(L, 1);
    float vol = (float)luaL_checknumber(L, 2);
    if (*snd) audio_set_volume(*snd, vol);
    return 0;
}

// sound:get_volume() -> number
static int l_sound_get_volume(lua_State* L) {
    Sound** snd = check_sound(L, 1);
    lua_pushnumber(L, *snd ? audio_get_volume(*snd) : 0.0);
    return 1;
}

// sound:set_pitch(pitch)
static int l_sound_set_pitch(lua_State* L) {
    Sound** snd = check_sound(L, 1);
    float pitch = (float)luaL_checknumber(L, 2);
    if (*snd) audio_set_pitch(*snd, pitch);
    return 0;
}

// sound:get_pitch() -> number
static int l_sound_get_pitch(lua_State* L) {
    Sound** snd = check_sound(L, 1);
    lua_pushnumber(L, *snd ? audio_get_pitch(*snd) : 1.0);
    return 1;
}

// sound:destroy()
static int l_sound_destroy(lua_State* L) {
    Sound** snd = check_sound(L, 1);
    if (*snd) {
        audio_destroy(*snd);
        *snd = NULL;
    }
    return 0;
}

// pb.audio.set_master_volume(volume)
static int l_audio_set_master_volume(lua_State* L) {
    int arg = 1;
    if (lua_istable(L, 1)) arg = 2;
    float vol = (float)luaL_checknumber(L, arg);
    ensure_audio_init();
    audio_set_master_volume(vol);
    return 0;
}

// pb.audio.get_master_volume() -> number
static int l_audio_get_master_volume(lua_State* L) {
    ensure_audio_init();
    lua_pushnumber(L, audio_get_master_volume());
    return 1;
}

// pb.audio.shutdown()
static int l_audio_shutdown(lua_State* L) {
    (void)L;
    audio_shutdown();
    audio_engine_initialized = 0;
    return 0;
}

// Module-level functions
static const luaL_Reg audio_module_funcs[] = {
    {"load",              l_audio_load},
    {"set_master_volume", l_audio_set_master_volume},
    {"get_master_volume", l_audio_get_master_volume},
    {"shutdown",          l_audio_shutdown},
    {NULL, NULL}
};

// Sound object methods
static const luaL_Reg sound_methods[] = {
    {"play",         l_sound_play},
    {"stop",         l_sound_stop},
    {"pause",        l_sound_pause},
    {"resume",       l_sound_resume},
    {"is_playing",   l_sound_is_playing},
    {"set_looping",  l_sound_set_looping},
    {"is_looping",   l_sound_is_looping},
    {"set_volume",   l_sound_set_volume},
    {"get_volume",   l_sound_get_volume},
    {"set_pitch",    l_sound_set_pitch},
    {"get_pitch",    l_sound_get_pitch},
    {"destroy",      l_sound_destroy},
    {NULL, NULL}
};

void lua_register_audio_api(lua_State* L) {
    // Create Sound metatable
    luaL_newmetatable(L, SOUND_METATABLE);

    lua_pushvalue(L, -1);
    lua_setfield(L, -2, "__index");

    luaL_setfuncs(L, sound_methods, 0);

    // __gc calls destroy
    lua_pushcfunction(L, l_sound_destroy);
    lua_setfield(L, -2, "__gc");

    lua_pop(L, 1); // pop metatable

    // Register into PudimBasicsGl table
    lua_getglobal(L, "PudimBasicsGl");
    if (lua_isnil(L, -1)) {
        lua_pop(L, 1);
        lua_newtable(L);
        lua_setglobal(L, "PudimBasicsGl");
        lua_getglobal(L, "PudimBasicsGl");
    }

    lua_newtable(L);
    luaL_setfuncs(L, audio_module_funcs, 0);
    lua_setfield(L, -2, "audio");

    lua_pop(L, 1);
}
