-- Test demonstrating object-style calls
local pb = require('PudimBasicsGl')

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
