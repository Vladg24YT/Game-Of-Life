local event = require("event")
local gpu = require("component").gpu
local keyboard = require("keyboard")

local width, height = gpu.maxResolution()

local black = 0x000000
local white = 0xFFFFFF

local red = 0xC80000
local green = 0x00C800

local isSimLaunched = false

gpu.setBackground(black)
gpu.setForeground(white)
gpu.fill(1, 1, width, height, " ")

-- Game field
local field = {}
--previous generation container
local pfield = {}

-- Control hints
--[[
[ - previous generation \ - start/stop simulation ` - exit
] - next generation     / - restart               Use LMB to change cell's state
]]
gpu.setBackground(0x0000C8)
gpu.setForeground(black)
gpu.fill(1, height-2, width, 1, " ")
gpu.setBackground(white)
gpu.fill(1, height-1, width, 2, " ")
gpu.set(1, height-1, "[ - previous generation")
gpu.set(1, height, "] - next generation")
gpu.set(31, height-1, "\\ - start/stop simulation")
gpu.set(31, height, "/ - restart")
gpu.set(61, height-1, "` - exit")
gpu.set(61, height, "Use LMB to change cell's state")

-- Field generation (MUST UNDERSTAND HOW TO MAKE AN INFINITE GAME FIELD)
local function clearField()
  gpu.setBackground(0x0000C8)
  gpu.fill(1, height-2, width, 1, " ")
  for gx=1,width do
    if gx==width then
      field[width+1] = field[1]
    end
    field[gx] = {}
    for gy=1,height-3 do
      if gy==height-3 then
        field[gx][height-2] = field[gx][1]
      end
      field[gx][gy] = false
      -- PROGRESS
      if gx*gy==width*(height-3) then
        gpu.setBackground(green)
      else
        gpu.setBackground(red)
      end
      gpu.setForeground(white)
      gpu.set(2, height-2, "CURRENT PROCESS: FIELD CLEARING")
      gpu.set(60, height-2, "PROGRESS: "..gx*gy.."/"..width*(height-3))
      gpu.set(100, height-2, "RAM: "..require("computer").freeMemory().."/"..require("computer").totalMemory())
    end
  end
end

--Field redraw
local function drawField()
  gpu.setBackground(0x0000C8)
  gpu.fill(1, height-2, width, 1, " ")
  for x=1, width do
    for y=1,height-3 do
      if field[x][y] then
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
      gpu.set(2, height-2, "CURRENT PROCESS: FIELD REDRAWING")
      gpu.set(60, height-2, "PROGRESS: "..x*y.."/"..width*(height-3))
      gpu.set(100, height-2, "RAM: "..require("computer").freeMemory().."/"..require("computer").totalMemory())
    end
  end
end

-- Touch & Keyboard
--[[
arg1 - eventName / eventName
arg2 - screenAddress / keyboardAddress
arg3 - x / char
arg4 - y / code
arg5 - button / playerName
arg6 - playerName / _
]]
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
    --gpu.set(1, 1, "touch at "..lastEvent[3]..":"..lastEvent[4].." with "..lastEvent[5])

    --State invertion
    field[lastEvent[3]][lastEvent[4]] = not field[lastEvent[3]][lastEvent[4]]
    drawField()
  elseif lastEvent[1] == "key_down" then
    --gpu.set(1, 2, "char "..lastEvent[3]..", code "..lastEvent[4])
    if lastEvent[4] == keyboard.keys.lbracket then
      field = pfield
      drawField()
    elseif lastEvent[4] == keyboard.keys.rbracket then
      gpu.setBackground(0x0000C8)
      gpu.fill(1, height-2, width, 1, " ")
      for x=1,width do
        for y=1,height-3 do
          --Calculation of living cells around x:y
          local livingCells = 0
          for cx=x-1,x+1 do
            local prevX = cx
            for cy=y-1,y+1 do
              local prevY = cy
              --
              if cx==0 then
                cx=width
              end
              if cy==0 then
                cy=height-3
              end
              if field[cx][cy]==true and (cx~=x and cy~=y) then
                livingCells = livingCells + 1
              end
              -- PROGRESS
              if cx*cy==width*(height-3) then
                gpu.setBackground(green)
              else
                gpu.setBackground(red)
              end
              gpu.setForeground(white)
              gpu.set(2, height-2, "CURRENT PROCESS: CALCULATING NEIGHBOURS FOR "..x..":"..y)
              gpu.set(60, height-2, "PROGRESS: "..cx*cy.."/"..(x+1)*(y+1))
              gpu.set(100, height-2, "RAM: "..require("computer").freeMemory().."/"..require("computer").totalMemory())
              --
              cy = prevY
            end
            cx = prevX
          end
          --spawns
          if field[x][y]==false and livivngCells==3 then
            field[x][y] = true
          --dies
          elseif field[x][y]==true and (livingCells < 2 or livingCells > 3) then
            field[x][y] = false
          end
        end
      end
      pfield = field
      drawField()
    elseif lastEvent[4] == keyboard.keys.backslash then
      isSimLaunched = not isSimLaunched
      while true do
        if isSimLaunched then
          event.push("key_down", nil, nil, keyboard.keys.rbracket, nil)
          drawField()
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
