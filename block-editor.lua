--[[

block-editor - Editor for blocks.
BSD license.
by Sven Nilsen, 2012
http://www.cutoutpro.com

Version: 0.000 in angular degrees version notation
http://isprogrammingeasy.blogspot.no/2012/08/angular-degrees-versioning-notation.html

Keyboard settings can be modified using the 'keyMap' field.

This editor uses A, S, W, D for navigation.
TAB is used to move current block in the current direction.
SPACE is adding a block in the current direction, if there is no overlap with existing blocks.

Direction:
0 - right
1 - down
2 - left
3 - up

Uses group oriented programming to find the closest block in the current direction.

--]]

--[[

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
The views and conclusions contained in the software and documentation are those
of the authors and should not be interpreted as representing official policies,
either expressed or implied, of the FreeBSD Project.

--]]

require "includes/groups"

local block = require "block"
local editor = {}

function editor.newEditor()
  local ed = {
    blocks = {},
    units = 10,
    nextBlock = nil,
    currentBlockIndex = 0,
    keyMap = {
      addBlock = " ", 
      changeDirectionRight = "d",
      changeDirectionDown = "s",
      changeDirectionLeft = "a",
      changeDirectionUp = "w",
      moveBlock = "tab",
      removeBlock = "backspace",
    },
    direction = 0,
  }
  ed.nextBlock = block.newBlock(ed.units, 0, 0, 2, 1)
  return ed
end

-- Adds a new block in the current direction relative to the current block.
function editor.addNextBlock(blockEditor)
  if not blockEditor.nextBlock then return false end
  if editor.doesNextBlockOverlap(blockEditor) then return false end
  
  local blocks = blockEditor.blocks
  blocks[#blocks+1] = blockEditor.nextBlock
  
  local nextBlock = block.copyBlock(blockEditor.nextBlock)
  blockEditor.nextBlock = nextBlock
  blockEditor.currentBlockIndex = #blocks
  
  editor.updateNextBlock(blockEditor)
  return true
end

-- Returns an index of the block that is overlapped by the next block.
function overlapBlockIndex(blockEditor)
  local blocks = blockEditor.blocks
  local nextBlock = blockEditor.nextBlock
  for i = 1, #blocks do
    local cmp = block.compare(blocks[i], nextBlock)
    if cmp == 0 then
      return i
    end
  end
  return 0
end

-- Moves to the overlapping next block.
function editor.moveToNextBlock(blockEditor)
  if not editor.doesNextBlockOverlap(blockEditor) then return false end
  
  local index = overlapBlockIndex(blockEditor)
  blockEditor.currentBlockIndex = index
  editor.updateNextBlock(blockEditor)
  
  return true
end

-- Moves the current block in the direction.
function editor.moveCurrentBlock(blockEditor)
  if editor.doesNextBlockOverlap(blockEditor) then return false end
  if blockEditor.currentBlockIndex < 1 then return false end
  
  local direction = blockEditor.direction
  local currentBlock = blockEditor.blocks[blockEditor.currentBlockIndex]
  
  if direction == 0 then
    currentBlock.x = currentBlock.x + currentBlock.w
  elseif direction == 1 then
    currentBlock.y = currentBlock.y + currentBlock.h
  elseif direction == 2 then
    currentBlock.x = currentBlock.x - currentBlock.w
  elseif direction == 3 then
    currentBlock.y = currentBlock.y - currentBlock.h
  end
  
  editor.updateNextBlock(blockEditor)
  
  return true
end

-- Removes the overlapping block.
function editor.removeBlock(blockEditor)
  if not editor.doesNextBlockOverlap(blockEditor) then return false end
  
  local index = overlapBlockIndex(blockEditor)
  local currentIndex = blockEditor.currentBlockIndex
  local subtract = currentIndex > index
  table.remove(blockEditor.blocks, index)
  if subtract then
    blockEditor.currentBlockIndex = currentIndex - 1
  end
  
  return true
end

-- Updates the next block.
function editor.updateNextBlock(blockEditor)
  local currentBlock = blockEditor.blocks[blockEditor.currentBlockIndex]
  if not currentBlock then return end
  
  local direction = blockEditor.direction
  
  local nextBlock = block.copyBlock(currentBlock)
  if direction == 0 then
    nextBlock.x = currentBlock.x + currentBlock.w
  elseif direction == 1 then
    nextBlock.y = currentBlock.y + currentBlock.h
  elseif direction == 2 then
    nextBlock.x = currentBlock.x - currentBlock.w
  elseif direction == 3 then
    nextBlock.y = currentBlock.y - currentBlock.h
  end
  
  blockEditor.nextBlock = nextBlock
end

-- Changes the direction of where to add a block next.
function editor.changeDirection(blockEditor, direction)
  assert(blockEditor, "Missing argument 'blockEditor'")
  assert(direction, "Missing argument 'direction'")
  blockEditor.direction = direction
  editor.updateNextBlock(blockEditor)
  return true
end

-- Returns a direction set by typing a key.
function directionByKey(blockEditor, key)
  if key == blockEditor.keyMap.changeDirectionRight then
    return 0
  end
  if key == blockEditor.keyMap.changeDirectionDown then
    return 1
  end
  if key == blockEditor.keyMap.changeDirectionLeft then
    return 2
  end
  if key == blockEditor.keyMap.changeDirectionUp then
    return 3
  end
  
  return -1
end

-- Handles keydown event.
function editor.handleKeyPress(blockEditor, key)
  if not blockEditor.active then return end
  
  -- Adds a block in the direction, or moves if there is a block there already.
  if key == blockEditor.keyMap.addBlock then
    if editor.addNextBlock(blockEditor) then return end
    if editor.moveToNextBlock(blockEditor) then return end
  end
  
  if key == blockEditor.keyMap.moveBlock then
    if editor.moveCurrentBlock(blockEditor) then return end
  end
  
  local newDirection = directionByKey(blockEditor, key)
  -- Move in same direction if hit twice.
  if blockEditor.direction == newDirection then
    if editor.moveToNextBlock(blockEditor) then return end
    if editor.moveToClosestBlock(blockEditor) then return end
  end
  -- Change direction.
  if newDirection >= 0 then
    if editor.changeDirection(blockEditor, newDirection) then return end
  end
  
  if key == blockEditor.keyMap.removeBlock then
    if editor.removeBlock(blockEditor) then return end
  end
end

-- Returns true if the next block overlaps with an existing block.
function editor.doesNextBlockOverlap(blockEditor)
  assert(blockEditor, "Missing argument 'blockEditor'.")
  
  local blocks = blockEditor.blocks
  local nextBlock = blockEditor.nextBlock
  for i = 1, #blocks do
    local cmp = block.compare(blocks[i], nextBlock)
    if cmp == 0 then 
        return true 
    end
  end
  
  return false
end

-- Returns the index of the closest block in a given direction.
function editor.closestBlockIndex(blockEditor, direction)
  assert(direction, "Missing argument 'direction'")
  
  local blocks = blockEditor.blocks
  local nextBlock = blockEditor.nextBlock
  
  local prop, equalProp
  local more = false
  if direction == 0 or direction == 1 then
    more = true
  end
  
  if direction == 0 or direction == 2 then
    prop = "x"
    equalProp = "y"
  elseif direction == 1 or direction == 3 then
    prop = "y"
    equalProp = "x"
  end
  
  local g = groups_EqualTo(blocks, equalProp, nextBlock[equalProp])
  if more then
    g = groups_MoreThan(blocks, prop, nextBlock[prop], g)
    return groups_FindMinIndex(blocks, prop, g, 1)
  else
    g = groups_LessThan(blocks, prop, nextBlock[prop], g)
    return groups_FindMaxIndex(blocks, prop, g, 1)
  end
end

-- Moves to closest block by jumping over gaps.
function editor.moveToClosestBlock(blockEditor)
  -- if editor.doesNextBlockOverlap(blockEditor) then return end
  
  local closestIndex = editor.closestBlockIndex(blockEditor, blockEditor.direction)
  if closestIndex < 1 then return false end
  
  blockEditor.currentBlockIndex = closestIndex
  editor.updateNextBlock(blockEditor)
  
  return true
end

-- Draw the next block to insert.
function editor.drawNextBlock(blockEditor)
  local overlaps = editor.doesNextBlockOverlap(blockEditor)
  local a = blockEditor.nextBlock
  if overlaps then
    love.graphics.setColor(255, 0, 0, 255)
  else
    love.graphics.setColor(0, 255, 0, 255)
  end
  love.graphics.rectangle("line", a.x, a.y, a.w, a.h)
end

-- Draw blocks.
function editor.drawBlocks(blockEditor)
  local blocks = blockEditor.blocks
  love.graphics.setColor(255, 255, 255, 255)
  for i = 1, #blocks do
    local a = blocks[i]
    love.graphics.rectangle("line", a.x, a.y, a.w, a.h)
  end
end

-- Draw the current block.
function editor.drawCurrentBlock(blockEditor)
  if blockEditor.currentBlockIndex < 1 then return end
  
  local a = blockEditor.blocks[blockEditor.currentBlockIndex]
  love.graphics.setColor(0, 0, 255, 255)
  love.graphics.rectangle("fill", a.x, a.y, a.w, a.h)
end

function editor.drawCurrentBlockPosition(blockEditor)
  local currentBlock = blockEditor.blocks[blockEditor.currentBlockIndex]
  if not currentBlock then return end
  
  local h = love.graphics.getHeight()
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.print((currentBlock.x/currentBlock.w) .. ", " .. (currentBlock.y/currentBlock.h), 0, h-20)
end

return editor
