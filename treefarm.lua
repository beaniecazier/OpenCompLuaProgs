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
  if facing % 2 == 0 then
    z = if facing == 0 then z + 1 else z - 1 end
  else
    x = if facing == 1 then x + 1 else X - 1 end
  end
end

local function Turn()
  facing = if facing == 3 then 0 else facing + 1 end
  robot.turnRight()
end

local function EvaluateDurability()
  if robot.durability() < 100 then
    os.sleep(15)
end

local function EvaluateStock()
  GoToStart()
  faceNegX()
  while robot.count() < 32 do
    rock.suck()
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

local function GoToStart()
  while x != 0 and z != 0 do
    if x != 0 do
      faceNegX()
      x -= if robot.forward() then 1 else 0
    end
    if z != 0 do
      faceNegZ()
      robot.forward()
      z -= if robot.forward() then 1 else 0
    end
  end
  facePosZ()
end

local function facePosZ()
  while facing != 0 do
    Turn()
  end
end

local function facePosX()
  while facing != 1 do
    Turn()
  end
end

local function faceNegZ()
  while facing != 2 do
    Turn()
  end
end

local function faceNegX()
  while facing != 3 do
    Turn()
  end
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

-- Select the first slot, whihc is supposed ro have a sapling
robot.select(1)
while true do
  navigateFarm(CutTrees)
  navigateFarm(PlantTrees)
  dropOffItems()
  os.sleep(300)
end
