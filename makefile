
# PudimBasicsGl - Pudim OpenGL Basics
# Compiles as a shared library (.so/.dll) that can be loaded with require("PudimBasicsGl")
# Compatible with Lua 5.4 and 5.5
# Supports Linux and Windows (MinGW/MSYS2)

CC = gcc
CFLAGS = -Wall -Wextra -std=c17 -g -fPIC -O2

# Detect operating system
ifeq ($(OS),Windows_NT)
    DETECTED_OS := Windows
else
    DETECTED_OS := $(shell uname -s)
endif

# Platform-specific settings
ifeq ($(DETECTED_OS),Windows)
    # Windows (MinGW/MSYS2)
    EXT = .dll
    LDFLAGS = -shared -lglfw3 -lopengl32 -lgdi32 -lm
    RM = del /Q
    MKDIR = mkdir
    # Windows Lua paths (MSYS2/MinGW)
    LUA_CFLAGS ?= -I/mingw64/include
    LUA_LDFLAGS ?= -L/mingw64/lib -llua
else
    # Linux/Unix
    EXT = .so
    LDFLAGS = -shared -lglfw -lGL -lm -ldl -lpthread
    RM = rm -rf
    MKDIR = mkdir -p
    
    # Lua configuration - auto-detect version (prefer 5.5, fallback to 5.4)
    # Override with: make LUA_VERSION=5.4
    LUA_VERSION ?= $(shell pkg-config --exists lua5.5 2>/dev/null && echo "5.5" || \
                           (pkg-config --exists lua54 2>/dev/null && echo "54") || \
                           (pkg-config --exists lua5.4 2>/dev/null && echo "5.4") || \
                           (pkg-config --exists lua 2>/dev/null && echo "") || echo "5.4")

    # Handle different pkg-config naming conventions
    LUA_PKG = $(shell pkg-config --exists lua$(LUA_VERSION) 2>/dev/null && echo "lua$(LUA_VERSION)" || \
                      (pkg-config --exists lua 2>/dev/null && echo "lua") || echo "")

    ifneq ($(LUA_PKG),)
        LUA_CFLAGS = $(shell pkg-config --cflags $(LUA_PKG))
        LUA_LDFLAGS = $(shell pkg-config --libs $(LUA_PKG))
    else
        # Fallback to common paths
        LUA_CFLAGS = -I/usr/local/include -I/usr/include/lua5.4
        LUA_LDFLAGS = -L/usr/local/lib -llua
    endif
endif

SRC = src/main.c \
      src/platform/window.c \
      src/render/renderer.c \
      src/render/texture.c \
      src/render/camera.c \
      src/audio/audio.c \
      src/core/lua_window.c \
      src/core/lua_renderer.c \
      src/core/lua_time.c \
      src/core/lua_texture.c \
      src/core/lua_input.c \
      src/core/lua_audio.c \
      src/core/lua_text.c \
      src/core/lua_camera.c \
      src/render/text.c \
      external/glad/src/glad.c

INCLUDES = -Iexternal/glad/include -Iexternal -Isrc $(LUA_CFLAGS)

# Output library name (platform-dependent extension)
TARGET = PudimBasicsGl$(EXT)

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(INCLUDES) $(SRC) $(LDFLAGS) $(LUA_LDFLAGS) -o $(TARGET)
ifeq ($(DETECTED_OS),Windows)
	@echo Built $(TARGET) - use with: lua -e "package.cpath='.\\?.dll;'..package.cpath" your_script.lua
else
	@echo "Built $(TARGET) - use with: lua -e \"package.cpath='./?.so;'..package.cpath\" your_script.lua"
endif

clean: 
	$(RM) PudimBasicsGl.so PudimBasicsGl.dll 2>/dev/null || true

# Install to Lua's cpath (Linux only)
ifeq ($(DETECTED_OS),Windows)
install:
	@echo "Manual installation required on Windows. Copy $(TARGET) to your Lua cpath."
else
# Normalizes version number (5.4 or 54 -> 5.4, 5.5 -> 5.5)
INSTALL_VERSION = $(shell echo "$(LUA_VERSION)" | sed 's/^\([0-9]\)\([0-9]\)$$/\1.\2/')
install: $(TARGET)
	@echo "Installing to /usr/local/lib/lua/$(INSTALL_VERSION)/"
	sudo mkdir -p /usr/local/lib/lua/$(INSTALL_VERSION)
	sudo cp $(TARGET) /usr/local/lib/lua/$(INSTALL_VERSION)/

.PHONY: test
test: all
	@echo "Running preload test script"
	@bash scripts/test_preload.sh
endif

.PHONY: all clean install
