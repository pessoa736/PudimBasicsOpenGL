#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Try to provide an X server in headless CI environments using Xvfb
Xvfb_pid=""
cleanup() {
    if [ -n "$Xvfb_pid" ]; then
        kill "$Xvfb_pid" 2>/dev/null || true
    fi
}
trap cleanup EXIT

# Start Xvfb if DISPLAY is not set and Xvfb is available
if [ -z "${DISPLAY:-}" ]; then
    if command -v Xvfb >/dev/null 2>&1; then
        echo "No DISPLAY detected: starting Xvfb on :99"
        Xvfb :99 -screen 0 1024x768x24 >/dev/null 2>&1 &
        Xvfb_pid=$!
        export DISPLAY=:99
        sleep 0.5
    else
        echo "No DISPLAY and Xvfb not available; test may fail in headless environments"
    fi
fi

echo "Building project..."
make

echo "Running preload test (no LD_PRELOAD)..."
# Use lua to require the module and try to create a tiny window (1x1) then destroy it
OUTPUT=$(lua -e '
package.cpath = "./?.so;" .. package.cpath
local ok,pb = pcall(require, "PudimBasicsGl")
if not ok then print("REQUIRE_FAILED:"..tostring(pb)); os.exit(2) end
local ok2, w = pcall(pb.window.create, 1, 1, "test")
if not ok2 or not w then print("WINDOW_FAILED:"..tostring(w)); os.exit(3) end
print("WINDOW_OK")
pb.window.destroy(w)
' 2>&1 || true)

printf "%s\n" "$OUTPUT"

if printf "%s\n" "$OUTPUT" | grep -q "WINDOW_OK"; then
    echo "Preload test passed: window created without LD_PRELOAD"
    exit 0
else
    echo "Preload test failed; collecting diagnostics..." >&2
    echo "---- LUA OUTPUT ----" >&2
    printf "%s\n" "$OUTPUT" >&2
    echo "---- LDD PudimBasicsGl.so ----" >&2
    ldd ./PudimBasicsGl.so || true
    echo "---- LDD libglfw (if present) ----" >&2
    ldd /usr/lib/libglfw.so.3 || true
    echo "---- ENV ----" >&2
    env | sort >&2
    exit 4
fi
