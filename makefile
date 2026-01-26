
# PudimBasicsGl - Pudim OpenGL Basics
# Compiles as a shared library (.so) that can be loaded with require("PudimBasicsGl")
# Compatible with Lua 5.4 and 5.5

CC = gcc
CFLAGS = -Wall -Wextra -std=c17 -g -fPIC -O2
LDFLAGS = -shared -lglfw -lGL -lm -ldl

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

SRC = src/main.c \
      src/platform/window.c \
      src/render/renderer.c \
      src/render/texture.c \
      src/core/lua_window.c \
      src/core/lua_renderer.c \
      src/core/lua_time.c \
      src/core/lua_texture.c \
      external/glad/src/glad.c

INCLUDES = -Iexternal/glad/include -Iexternal -Isrc $(LUA_CFLAGS)

# Output library name
TARGET = PudimBasicsGl.so

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(INCLUDES) $(SRC) $(LDFLAGS) $(LUA_LDFLAGS) -o $(TARGET)
	@echo "Built $(TARGET) - use with: lua -e \"package.cpath='./?.so;'..package.cpath\" your_script.lua"

clean: 
	rm -rf $(TARGET)

# Install to Lua's cpath (optional)
# Normalizes version number (5.4 or 54 -> 5.4, 5.5 -> 5.5)
INSTALL_VERSION = $(shell echo "$(LUA_VERSION)" | sed 's/^\([0-9]\)\([0-9]\)$$/\1.\2/')
install: $(TARGET)
	@echo "Installing to /usr/local/lib/lua/$(INSTALL_VERSION)/"
	sudo mkdir -p /usr/local/lib/lua/$(INSTALL_VERSION)
	sudo cp $(TARGET) /usr/local/lib/lua/$(INSTALL_VERSION)/

.PHONY: all clean install
