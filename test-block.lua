
local block = require "block"
local test = {}

function testCopy()
  local units = 1
  local a = block.newBlock(units, 0, 0, 100, 100)
  local b = block.copyBlock(a)
  assert(b.x == 0)
  assert(b.y == 0)
  assert(b.w == 100)
  assert(b.h == 100)
end

function test.run()
  testCopy()
end

return test