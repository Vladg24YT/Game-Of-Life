local component = require("component")
local computer = require("computer")
local event = require("event")
local gpu = component.gpu
local keyboard = require("keyboard")

local width, height = gpu.maxResolution()

local black = 0x000000
local white = 0xFFFFFF

local red = 0xC80000
local green = 0x00C800
local blue = 0x0000C8

local isSimLaunched = false

gpu.setBackground(black)
gpu.setForeground(white)
gpu.fill(1, 1, width, height, " ")

-- Game field
local field = {}
--Next generation container
local nfield = {}

-- Control hints
--[[
[ - previous generation \ - start/stop simulation ` - exit
] - next generation     / - restart               Use LMB to change cell's state
]]
gpu.setBackground(blue)
gpu.setForeground(black)
gpu.fill(1, height-2, width, 1, " ")
gpu.setBackground(white)
gpu.fill(1, height-1, width, 2, " ")
gpu.set(1, height-1, "[ - previous generation | \\ - start/stop simulation | ` - exit")
gpu.set(1, height,   "] - next generation     | / - restart               | LMB - invert cell's state")

-- Field clearing/generation
local function clearField()
  gpu.setBackground(blue)
  gpu.fill(1, height-2, width, 1, " ")
  --Making the field array circular
  setmetatable(field, {
  __index = function(t,i)
    local index = i%width
    index = index == 0 and width or index
    return t[index] end
  })
  --
  for gx=1,width do
    field[gx] = {}
    nfield[gx] = {}
    --Making the field array circular pt.2
    setmetatable(field[gx], {
    __index = function(t,i)
      local index = i%height-3
      index = index == 0 and height-3 or index
      return t[index] end
    })
    --
    for gy=1,height-3 do
      field[gx][gy] = 0
      -- PROGRESS
      if gx*gy==width*(height-3) then
        gpu.setBackground(green)
      else
        gpu.setBackground(red)
      end
      gpu.setForeground(white)
      gpu.set(2, height-2, "CURRENT PROCESS: CLEARING "..gx..":"..gy..", PROGRESS: "..gx*gy.."/"..width*(height-3))
    end
  end
  computer.beep()
end

--Field redraw
local function drawField(cont)
  gpu.setBackground(blue)
  gpu.fill(1, height-2, width, 1, " ")
  for x=1, width do
    for y=1,height-3 do
      if cont[x][y]==1 then
        gpu.setBackground(white)
        gpu.setForeground(black)
      else
        gpu.setBackground(black)
        gpu.setForeground(white)
      end
      gpu.fill(x, y, 1, 1, " ")
      -- PROGRESS
      if x*y==width*(height-3) then
        gpu.setBackground(green)
      else
        gpu.setBackground(red)
      end
      gpu.setForeground(white)
      gpu.set(2, height-2, "CURRENT PROCESS: DRAWING "..x..":"..y..", PROGRESS: "..x*y.."/"..width*(height-3))
    end
  end
  computer.beep()
end

--- Calculating next generation
local function nextGen()
  -- Going through all the field
  for x=1,width do
    for y=1,height-3 do
      local livingCells = 0
      -- Calculation of living cells around x:y
      for i=x-1,x+1 do
        for j=y-1,y+1 do
          livingCells = livingCells + field[i][j]
          -- PROGRESS
          if i*j==width*(height-3) then
            gpu.setBackground(green)
          else
            gpu.setBackground(red)
          end
          gpu.setForeground(white)
          gpu.set(2, height-2, "CURRENT PROCESS: CHECKING NEIGHBOUR "..i..":"..j.." AT "..x..":"..y..", PROGRESS: "..i*j.."/"..width*(height-3))
        end
      end
      -- In case it's alive
      livingCells = livingCells - field[x][y]
      -- Spawning a new cell
      if field[x][y]==0 and livingCells==3 then
        nfield[x][y] = 1
      -- Killing a cell
      elseif field[x][y]==1 and (livingCells < 2 or livingCells > 3) then
        nfield[x][y] = 0
      else
        nfield[x][y] = field[x][y]
      end
    end
  end
  return true
  computer.beep()
end

-- Touch & Keyboard
local function filter(name, ...)
  if name ~= "key_down" and name ~= "touch" then
    return false
  end
  return true
end

-- Game loop
clearField()
while true do
  local lastEvent = {event.pullFiltered(filter)}
  if lastEvent[1] == "touch" and lastEvent[5] == 0 then
    --State invertion
    if field[lastEvent[3]][lastEvent[4]]==1 then
      field[lastEvent[3]][lastEvent[4]] = 0
      gpu.setBackground(black)
      gpu.setForeground(white)
    else
      field[lastEvent[3]][lastEvent[4]] = 1
      gpu.setBackground(white)
      gpu.setForeground(black)
    end
    gpu.fill(lastEvent[3], lastEvent[4], 1, 1, " ")
  elseif lastEvent[1] == "key_down" then
    if lastEvent[4] == keyboard.keys.lbracket then
      drawField(field)
    elseif lastEvent[4] == keyboard.keys.rbracket then
      gpu.setBackground(blue)
      gpu.fill(1, height-2, width, 1, " ")
      nextGen()
      drawField(nfield)
      for i=1,width do
        for j=1,height-3 do
          field[i][j] = nfield[i][j]
        end
      end
    elseif lastEvent[4] == keyboard.keys.backslash then
      isSimLaunched = not isSimLaunched
      while true do
        os.sleep(2)
        if isSimLaunched then
          if not nextGen() then
            break
          end
          drawField(nfield)
          for i=1,width do
            for j=1,height-3 do
              field[i][j] = nfield[i][j]
            end
          end
        else
          break
        end
      end
    elseif lastEvent[4] == keyboard.keys.slash then
      clearField()
      isSimLaunched = false
    elseif lastEvent[4] == keyboard.keys.grave then
      return nil
    end
  end
end
