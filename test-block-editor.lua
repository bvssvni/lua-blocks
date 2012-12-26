
local editor = require "block-editor"
local test = {}

function testAddBlock()
  local ed = editor.newEditor()
  assert(ed.direction == 0)
  local x = ed.nextBlock.x
  local w = ed.nextBlock.w
  assert(x)
  assert(w)
  editor.addNextBlock(ed)
  assert(ed.nextBlock.x == x + w)
end

function test.run()
  testAddBlock()
end

return test