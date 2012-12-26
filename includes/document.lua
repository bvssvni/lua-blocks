--[[

document - Display document actions in upper left corner with open and save actions.
BSD license.
by Sven Nilsen, 2012
http://www.cutoutpro.com

Version: 0.000 in angular degrees version notation
http://isprogrammingeasy.blogspot.no/2012/08/angular-degrees-versioning-notation.html

Override 'document.save' and 'document.open' to handle data.
These methods need to return true in order to change the file name.

In 'Open' and 'Save' mode, you can give errors by setting the field 'errorMessage'.

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

local document = {}

document.MODE_SAVE = 0
document.MODE_OPEN = 1

function document.newDocument()
  return {
    active = false,
    filename = nil, 
    mode = -1,
    input = false, 
    inputText = "",
    errorMessage = nil,
    keyMap = {
      saveFile = "s",
      openFile = "o",
      cancel = "escape",
    },
  }
end

function document.draw(doc)
  local rx, ry, rw, rh = 0, 0, 200, 100
  if not doc.active then
    rh = 20
  end
  love.graphics.setColor(200, 200, 200, 255)
  love.graphics.rectangle("fill", rx, ry, rw, rh)
  love.graphics.setColor(100, 100, 100, 255)
  love.graphics.rectangle("line", rx, ry, rw, rh)
  
  -- Show file name.
  love.graphics.setColor(0, 0, 0, 255)
  if not doc.filename then
    love.graphics.print("File: (untitled)", 0, 0)
  else
    love.graphics.print("File: " .. doc.filename, 0, 0)
  end
  
  -- Don't display more information if not active.
  if not doc.active then return end
  
  local text
  if doc.mode == document.MODE_SAVE then text = "save" end
  if doc.mode == document.MODE_OPEN then text = "open" end
  
  -- Show the text the user is typing in.
  if doc.input then
    love.graphics.print(text .. ": " .. doc.inputText .. "|", 0, 20)
  end
  
  if doc.input and doc.errorMessage then
    love.graphics.setColor(255, 0, 0, 255)
    love.graphics.print("error: " .. doc.errorMessage, 0, 40)
  end
  
  love.graphics.setColor(0, 0, 0, 255)
  if doc.input then
    love.graphics.print("Escape - cancel\nEnter - ok", 0, 60)
  else
    love.graphics.print("S - save\nO - open", 0, 60)
  end
end

-- Add character to input text.
function addToInputText(doc, key)
  if not doc.input then return false end
  if not string.match(key, "%w") and 
    not string.match(key, "%s") and
    not string.match(key, "%p") then return false end
  if string.len(key) ~= 1 then return false end
  
  doc.inputText = doc.inputText .. key
  
  return true
end

-- Removes a character from the input text.
function removeFromInputText(doc, key)
  if key ~= "backspace" then return false end
  
  doc.inputText = string.sub(doc.inputText, 1, string.len(doc.inputText) - 1)
  return true
end

-- Override this function to save.
function document.save(doc, filename)
  return false
end

-- Override this function to open.
function document.open(doc, filename)
  return false
end

function goBackToDefaultMode(doc)
  doc.input = false
  doc.inputText = ""
  doc.errorMessage = nil
end

function goToSaveMode(doc)
  doc.input = true
  doc.mode = document.MODE_SAVE
  doc.errorMessage = nil
  if doc.filename then
    doc.inputText = doc.filename
  end
end

function goToOpenMode(doc)
  doc.input = true
  doc.errorMessage = nil
  doc.mode = document.MODE_OPEN
  doc.inputText = ""
end

-- Handles keyboard strokes.
function document.handleKeyPress(doc, key)
  assert(doc, "Missing argument 'doc'")
  assert(key, "Missing argument 'key'")
  
  if not doc.active then return end
  if removeFromInputText(doc, key) then return end
  if addToInputText(doc, key) then return end
  if doc.input and key == doc.keyMap.cancel then
    goBackToDefaultMode(doc)
    return
  end
  if not doc.input and key == doc.keyMap.saveFile then
    goToSaveMode(doc)
    return
  end
  if not doc.input and key == doc.keyMap.openFile then
    goToOpenMode(doc)
    return
  end
  if key == "return" and doc.input then
    local filename = doc.inputText
    if doc.mode == document.MODE_SAVE then
      if document.save(doc, filename) then
        doc.filename = filename
        goBackToDefaultMode(doc)
        return
      end
    elseif doc.mode == document.MODE_OPEN then
      if document.open(doc, filename) then
        doc.filename = filename
        goBackToDefaultMode(doc)
        return
      end
    end
  end
end

return document