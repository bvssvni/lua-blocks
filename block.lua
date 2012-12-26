
local block = {}

function block.newBlock(units, x, y, w, h)
  return {x = x * units, y = y * units, w = w * units, h = h * units}
end

function block.copyBlock(a)
  return {x = a.x, y = a.y, w = a.w, h = a.h}
end

function block.compare(a, b)
  if a.x < b.x then return -1 end
  if a.x > b.x then return 1 end
  if a.y < b.y then return -1 end
  if a.y > b.y then return 1 end
  if a.w < b.w then return -1 end
  if a.w > b.w then return 1 end
  if a.h < b.h then return -1 end
  if a.h > b.h then return 1 end
  
  return 0
end

function block.isInDirection(target, a, direction)
  local diffx, diffy = target.x - a.x, target.y - a.y
  if direction == 0 or direction == 2 then
    return diffy == 0
  elseif direction == 1 or direction == 3 then
    return diffx == 0
  end
  
  return false
end

function block.toString(a)
  return "{x="..a.x..",y="..a.y..",w="..a.w..",h="..a.h.."}"
end

function block.blocksToString(blocks)
  local str = "{"
  for i = 1, #blocks do
    str = str .. block.toString(blocks[i]) .. ",\r\n"
  end
  str = str .. "}"
  return str
end

return block
