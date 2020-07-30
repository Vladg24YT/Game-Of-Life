local event = require("event")
local gpu = require("component").gpu
local keyboard = require("keyboard")

local width, height = gpu.maxResolution()

local black = 0x000000
local grey = 0x7F7F7F
local white = 0xFFFFFF

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
gpu.setBackground(grey)
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
  for gx=1,width do
    if gx==width then
      field[1] = field[width+1]
    end
    field[gx] = {}
    for gy=1,height-3 do
      if gy==height-3 then
        field[gx][1] = field[gx][height-2]
      end
      field[gx][gy] = 0--[[false]]
      --[[gpu.set(1, gy, "x: "..gx)
      gpu.set(1, gy, "y: "..gy)]]
      gpu.set(1, gy, "field["..gx.."]["..gy.."]: "..field[gx][gy])
    end
  end
end

--Field redraw
local function drawField()
  for x=1, #field do
    for y=1,x do
      gpu.set(50, 23, "x: "..x)
      gpu.set(50, 24, "y: "..y)
      gpu.set(50, 25, "field["..x.."]["..y.."]: "..field[x][y])
      if field[x][y]==1 then
        gpu.setBackground(white)
        gpu.setForeground(black)
      else
        gpu.setBackground(black)
        gpu.setForeground(white)
      end
      gpu.fill(x, y, 1, 1, " ")
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
--while true do
  local lastEvent = {event.pullFiltered(filter)}
  if lastEvent[1] == "touch" and lastEvent[5] == 0 then
    gpu.set(1, 1, "touch at "..lastEvent[3]..":"..lastEvent[4].." with "..lastEvent[5])
    print(field[lastEvent[3]][lastEvent[4]])
    --State invertion
    --field[lastEvent[3]][lastEvent[4]] = not field[lastEvent[3]][lastEvent[4]]
    if field[lastEvent[3]][lastEvent[4]]==1 then
      field[lastEvent[3]][lastEvent[4]] = 0
    else
      field[lastEvent[3]][lastEvent[4]] = 1
    end
    drawField()
  elseif lastEvent[1] == "key_down" then
    gpu.set(1, 2, "char "..lastEvent[3]..", code "..lastEvent[4])
    if lastEvent[4] == keyboard.keys.lbracket then
      field = pfield
      drawField()
    elseif lastEvent[4] == keyboard.keys.rbracket then
      local c1, c2, c3, c4, c5, c6, c7, c8
      local tx, ty
      --[[
      c1, c2, c3
      c4, xy, c5,
      c6, c7, c8
      ]]
      for x=1,width do
        tx=x
        for y=1,height-3 do
          ty=y
          --

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
      --break
      return nil
    end
  end
--end
