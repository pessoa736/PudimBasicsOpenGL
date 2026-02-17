/*
 * PudimBasicsGl - Pudim OpenGL Basics
 * A simple 2D graphics library for Lua using OpenGL
 * 
 * Usage in Lua:
 *   local pb = require("PudimBasicsGl")
 *   
 *   local window = pb.window.create(800, 600, "My App")
 *   pb.renderer.init()
 *   
 *   while not pb.window.should_close(window) do
 *       pb.renderer.clear(0.1, 0.1, 0.15, 1.0)
 *       pb.renderer.begin(800, 600)
 *       -- draw stuff
 *       pb.renderer.finish()
 *       pb.window.swap_buffers(window)
 *       pb.window.poll_events()
 *   end
 *   
 *   pb.window.destroy(window)
 */

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

// Forward declarations for API registration
extern void lua_register_window_api(lua_State* L);
extern void lua_register_renderer_api(lua_State* L);
extern void lua_register_time_api(lua_State* L);
extern void lua_register_texture_api(lua_State* L);
extern void lua_register_input_api(lua_State* L);
extern void lua_register_audio_api(lua_State* L);
extern void lua_register_text_api(lua_State* L);

// Module entry point - called when require("PudimBasicsGl") is used
int luaopen_PudimBasicsGl(lua_State* L) {
    // Create the main 'PudimBasicsGl' table
    lua_newtable(L);
    
    // Store it as a global for the sub-modules to find
    lua_pushvalue(L, -1);
    lua_setglobal(L, "PudimBasicsGl");
    
    // Register API modules
    lua_register_window_api(L);
    lua_register_renderer_api(L);
    lua_register_time_api(L);
    lua_register_texture_api(L);
    lua_register_input_api(L);
    lua_register_audio_api(L);
    lua_register_text_api(L);
    
    // Return the PudimBasicsGl table
    return 1;
}
