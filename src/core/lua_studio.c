#include <lua.h>
#include <lauxlib.h>
#include <dirent.h>
#include <sys/stat.h>
#include <string.h>
#include <stdio.h>

// pb.studio.list_dir(path)
// Returns a table of filenames inside a directory
static int l_studio_list_dir(lua_State* L) {
    int arg = 1;
    if (lua_istable(L, 1)) arg = 2; // tolerate method calls
    const char* path = luaL_checkstring(L, arg);
    
    DIR* dir = opendir(path);
    if (!dir) {
        lua_pushnil(L);
        lua_pushstring(L, "Could not open directory");
        return 2;
    }

    lua_newtable(L);
    int i = 1;
    struct dirent* entry;
    while ((entry = readdir(dir)) != NULL) {
        if (strcmp(entry->d_name, ".") != 0 && strcmp(entry->d_name, "..") != 0) {
            lua_pushstring(L, entry->d_name);
            lua_rawseti(L, -2, i++);
        }
    }
    closedir(dir);
    return 1;
}

// pb.studio.get_file_modified_time(path)
// Returns an integer representing the last modified timestamp. Ideal for hot-reloading shaders!
static int l_studio_get_file_modified_time(lua_State* L) {
    int arg = 1;
    if (lua_istable(L, 1)) arg = 2;
    const char* path = luaL_checkstring(L, arg);
    
    struct stat attr;
    if (stat(path, &attr) == 0) {
        lua_pushinteger(L, (lua_Integer)attr.st_mtime);
        return 1;
    }
    lua_pushnil(L);
    return 1;
}

// pb.studio.copy_file(src, dest)
// Copies a file. Essential for exporting bundled studio projects.
static int l_studio_copy_file(lua_State* L) {
    int arg = 1;
    if (lua_istable(L, 1)) arg = 2;
    const char* src = luaL_checkstring(L, arg);
    const char* dest = luaL_checkstring(L, arg + 1);

    FILE* fsrc = fopen(src, "rb");
    if (!fsrc) {
        lua_pushboolean(L, 0);
        lua_pushstring(L, "Failed to open source file");
        return 2;
    }

    FILE* fdest = fopen(dest, "wb");
    if (!fdest) {
        fclose(fsrc);
        lua_pushboolean(L, 0);
        lua_pushstring(L, "Failed to open destination file");
        return 2;
    }

    char buffer[8192];
    size_t bytes;
    while ((bytes = fread(buffer, 1, sizeof(buffer), fsrc)) > 0) {
        fwrite(buffer, 1, bytes, fdest);
    }

    fclose(fsrc);
    fclose(fdest);

    lua_pushboolean(L, 1);
    return 1;
}

static const luaL_Reg studio_functions[] = {
    {"list_dir", l_studio_list_dir},
    {"get_file_modified_time", l_studio_get_file_modified_time},
    {"copy_file", l_studio_copy_file},
    {NULL, NULL}
};

void lua_register_studio_api(lua_State* L) {
    lua_getglobal(L, "PudimBasicsGl");
    if (lua_isnil(L, -1)) {
        lua_pop(L, 1);
        lua_newtable(L);
        lua_setglobal(L, "PudimBasicsGl");
        lua_getglobal(L, "PudimBasicsGl");
    }
    lua_newtable(L);
    luaL_setfuncs(L, studio_functions, 0);
    lua_setfield(L, -2, "studio");
    lua_pop(L, 1);
}
