--[[

block-editor - A 2D block editor for game level design.
BSD license.
by Sven Nilsen, 2012
http://www.cutoutpro.com

Version: 0.000 in angular degrees version notation
http://isprogrammingeasy.blogspot.no/2012/08/angular-degrees-versioning-notation.html

Saves the blocks as Lua code.
This makes it possible to generate levels with code and then modify it.
The data is saved in the love.filesystem.getSaveDirector() folder.

See 'block-editor.lua' for more information.

--]]

local block = require "block"
local editor = require "block-editor"
local testEditor = require "test-block-editor"
local testBlock = require "test-block"
local document = require "includes/document"
local mode = require "includes/mode"

testBlock.run()
testEditor.run()

local ed = editor.newEditor()
ed.active = false

local doc = document.newDocument()
doc.input = false
doc.active = true

local mod = mode.newModes({"file", "edit"})
function love.load()
  mode.gotoMode(mod, 2)
end

-- This function is called when changing mode.
-- Set editor or document active.
function mode.change(m, index)
  doc.active = false
  ed.active = false
  if index == 1 then
    doc.active = true
  elseif index == 2 then
    ed.active = true
  end
  
  return true
end

-- This function is called when the document is told to save to file.
-- Returns true if the saving was successful.
function document.save(doc, filename)
  local dataStr = "return {".. block.blocksToString(ed.blocks) .. "}"
  if love.filesystem.write(filename, dataStr, string.len(dataStr)) then
    print("'" .. filename .. "' saved to '" .. love.filesystem.getSaveDirectory() .. "'")
    return true
  else
    return false
  end
end

-- This function is called when the document is told to open a file.
-- Returns true if the opening was successful.
function document.open(doc, filename)
  assert(filename, "Missing argument 'filename'")
  
  -- Load data as Lua function.
  doc.errorMessage = nil
  if not love.filesystem.exists(filename) then
    doc.errorMessage = "'" .. filename .. "' does not exists."
    return false
  end
  
  -- Load the file as Lua code.
  local chunk = love.filesystem.load(filename)
  local ok, result = pcall(chunk)
  if not ok then
    print("Error reading '" .. filename .. "': " .. result)
    return false
  end
  
  ed = editor.newEditor()
  if #result > 0 then
    ed.blocks = result
    ed.currentBlockIndex = #result
    editor.updateNextBlock(ed)
  end
  
  -- Go to edit mode.
  mode.gotoMode(mod, 2)
  
  return true
end

-- Handle keyboard strokes.
function love.keypressed(key)
  mode.handleKeyPress(mod, key)
  editor.handleKeyPress(ed, key)
  document.handleKeyPress(doc, key)
end

-- Computes the x and y coordinate of camera translation.
function cameraTranslate()
  local currentBlock = ed.blocks[ed.currentBlockIndex]
  if not currentBlock then
    currentBlock = ed.nextBlock
  end
  
  local w, h = love.graphics.getWidth(), love.graphics.getHeight()
  local tx, ty = currentBlock.x + currentBlock.w/2, currentBlock.y + currentBlock.h/2
  return w/2 - tx, h/2 - ty
end

-- Draw graphics to screen.
function love.draw()
  local tx, ty = cameraTranslate()
  love.graphics.translate(tx, ty)
  
  editor.drawCurrentBlock(ed)
  editor.drawBlocks(ed)
  editor.drawNextBlock(ed)
  
  love.graphics.translate(-tx, -ty)
  
  editor.drawCurrentBlockPosition(ed)
  
  love.graphics.setColor(255, 255, 255, 255)
  document.draw(doc)
  
  mode.draw(mod)
end
