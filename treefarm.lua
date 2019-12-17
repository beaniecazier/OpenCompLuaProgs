local computer = require("computer")
local robot = require("robot")

-- Change these to change the tree farm grid size or the distance between each tree in the grid.
local treesX = 1
local treesZ = 5
local x = 0
local z = 0
local distanceBetweenTrees = 3
-- facing is 0, 1, 2, 3 where 0 is the direction that is away from the charger, ie starting direction
local facing = 0

-- Goes forward eventually, no matter if something is blocking the path at the moment.
local function GoForward()
  while true do
    local movedSuccessfuly = robot.forward()
    if movedSuccessfuly then
      break
    end
  end
  if facing % 2 == 0 
  then
    if facing == 0 then 
      z = z + 1 
    else 
      z = z - 1 
    end
  else
    if facing == 1 then 
      x = x + 1 
    else 
      x = x - 1 
    end
  end
end

local function Turn()
  if facing == 3 then
    facing = 0 
  else
    facing = facing + 1 
  end
  robot.turnRight()
end

local function facePosZ()
  while facing ~= 0 do
    Turn()
  end
end

local function facePosX()
  while facing ~= 1 do
    Turn()
  end
end

local function faceNegZ()
  while facing ~= 2 do
    Turn()
  end
end

local function faceNegX()
  while facing ~= 3 do
    Turn()
  end
end

local function GoToStart()
  while x ~= 0 and z ~= 0 do
    if x ~= 0 then
      faceNegX()
      if robot.forward() then
        x = x - 1
      end
    end
    if z ~= 0 then
      faceNegZ()
      robot.forward()
      if robot.forward() then
        z = z - 1
      end
    end
  end
  facePosZ()
end

local function EvaluateDurability()
  if robot.durability() < 100 then
    os.sleep(15)
end

local function EvaluateStock()
  GoToStart()
  faceNegX()
  if  robot.count() < 32 then
    while robot.count() < 32 do
      rock.suck()
    end
  end
  facePosZ()
end

local function EvaluatePower()
  current = computer.energy()
  max = computer.maxEnergy()
  if current / max < .5 then
    os.sleep(30)
  end
end

local function CutTrees()
  for t = 0,6 do 
    EvaluateDurability()
    robot.swing() 
  end	
end

local function PlantTrees()
  robot.use()
end

local function dropOffItems()
    GoToStart()
    facePosX()
    GoForward()
    os.sleep(30)
    faceNegX()
    GoForward()
    facePosZ()
end

local function navigateFarm(action)
  GoToStart()
  EvaluatePower()
  EvaluateStock()
  for x = 0, treesX do
    facePosX()
    for t = 0,4 do GoForward() end
    facePosZ()
    for z = 0, treesZ do
      for t = 0,4 do GoForward() end
      facePosX()
      action()
      facePosZ()
    end
    faceNegZ()
    for t = 0,(distanceBetweenTrees+1)*treesZ do GoForward() end
  end
end

-- Select the first slot, whihc is supposed ro have a sapling
robot.select(1)
while true do
  navigateFarm(CutTrees)
  navigateFarm(PlantTrees)
  dropOffItems()
  os.sleep(300)
end
