-- Test demonstrating object-style calls
---@type PudimBasicsGl
local pb = require('PudimBasicsGl')

-- Editor hint: annotate a Window variable to get LSP method suggestions
---@type Window
local win

-- Annotate textures for LSP
---@type Texture
local tex


print('Testing time module as object-style calls')
print('time.get()', pb.time.get())
print('time:get()', pb.time:get())

print('Calling time.update via both styles')
pb.time.update()
pb.time:update()

print('Testing time.sleep via colon (0.01s)')
pb.time:sleep(0.01)
print('sleep done')

print('\nTesting texture module flush (allowed without context)')
pb.texture.flush()
pb.texture:flush()

print('OK')
