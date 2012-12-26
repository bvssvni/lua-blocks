--[[

mode - Displays F1-F12 options in upper right corner.
BSD license.
by Sven Nilsen, 2012
http://www.cutoutpro.com

Version: 0.000 in angular degrees version notation
http://isprogrammingeasy.blogspot.no/2012/08/angular-degrees-versioning-notation.html

The user can use F1-F12 to select a mode.
Override "mode.change" to handle event and control what modes are accessible.

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


local mode = {}

-- Creates an object to keep track of modes.
function mode.newModes(names)
  return {
    names = names,
    selectedIndex = 0,
  }
end

-- Override this to update selected index.
-- This event is called before changing mode.
-- Return true to change the selected mode.
function mode.change(m, index)
  return true
end

-- Changes mode.
function mode.gotoMode(m, index)
  local names = m.names
  if index < 1 or index > #names then return end
  if mode.change(m, index) then
    m.selectedIndex = index
  end
end

-- Handles keyboard press.
function mode.handleKeyPress(m, key)
  if key == "f1" then
    mode.gotoMode(m, 1)
  elseif key == "f2" then
    mode.gotoMode(m, 2)
  elseif key == "f3" then
    mode.gotoMode(m, 3)
  elseif key == "f4" then
    mode.gotoMode(m, 4)
  elseif key == "f5" then
    mode.gotoMode(m, 5)
  elseif key == "f6" then
    mode.gotoMode(m, 6)
  elseif key == "f7" then
    mode.gotoMode(m, 7)
  elseif key == "f8" then
    mode.gotoMode(m, 8)
  elseif key == "f9" then
    mode.gotoMode(m, 9)
  elseif key == "f10" then
    mode.gotoMode(m, 10)
  elseif key == "f11" then
    mode.gotoMode(m, 11)
  elseif key == "f12" then
    mode.gotoMode(m, 12)
  end
end

-- Draws the mode as a menu.
function mode.draw(m)
  local w = love.graphics.getWidth()
  local width = 100
  local names = m.names
  local selectedIndex = m.selectedIndex
  local units = 20
  local rx, ry, rw, rh = w - width, 0, width, units * #names
  
  for i = 1, #names do
    local str = "F" .. i .. " - " .. names[i]
    if i == selectedIndex then
      love.graphics.setColor(100, 100, 100, 255)
      love.graphics.rectangle("fill", rx, ry + units * (i-1), rw, units)
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.print(str, rx, ry + units * (i-1))
    else
      love.graphics.setColor(200, 200, 200, 255)
      love.graphics.rectangle("fill", rx, ry + units * (i-1), rw, units)
      love.graphics.setColor(0, 0, 0, 255)
      love.graphics.print(str, rx, ry + units * (i-1))
    end
    love.graphics.setColor(100, 100, 100, 255)
    love.graphics.rectangle("line", rx, ry + units * (i-1), rw, units)
  end
end

return mode
