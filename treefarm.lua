local computer = require("computer")
local robot = require("robot")
local shell = require("shell")

local args, option = shell.parse(...)

-- Change these to change the tree farm grid size or the distance between each tree in the grid.
local treesX = 1
local treesZ = 5
local x = 0
local z = 0
local distanceBetweenTrees = 3
local verbose = false
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

  if verbose then
    sfacing = ''
    if facing == 0 then
      sfacing = 'posZ'
    elseif facing == 1 then
      sfacing = 'posX'
    elseif facing == 2 then
      sfacing = 'negZ'
    else
      sfacing = 'negX'
    end 
    print(string.format('Current coords %n,%n, facing ' + sfacing,x,z))
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

  if verbose then
    sfacing = ''
    if facing == 0 then
      sfacing = 'posZ'
    elseif facing == 1 then
      sfacing = 'posX'
    elseif facing == 2 then
      sfacing = 'negZ'
    else
      sfacing = 'negX'
    end 
    print(string.format('Current coords %n,%n, facing ' + sfacing,x,z))
  end
end

local function facePosX()
  while facing ~= 1 do
    Turn()
  end

  if verbose then
    sfacing = ''
    if facing == 0 then
      sfacing = 'posZ'
    elseif facing == 1 then
      sfacing = 'posX'
    elseif facing == 2 then
      sfacing = 'negZ'
    else
      sfacing = 'negX'
    end 
    print(string.format('Current coords %n,%n, facing ' + sfacing,x,z))
  end
end

local function faceNegZ()
  while facing ~= 2 do
    Turn()
  end

  if verbose then
    sfacing = ''
    if facing == 0 then
      sfacing = 'posZ'
    elseif facing == 1 then
      sfacing = 'posX'
    elseif facing == 2 then
      sfacing = 'negZ'
    else
      sfacing = 'negX'
    end 
    print(string.format('Current coords %n,%n, facing ' + sfacing,x,z))
  end
end

local function faceNegX()
  while facing ~= 3 do
    Turn()
  end

  if verbose then
    sfacing = ''
    if facing == 0 then
      sfacing = 'posZ'
    elseif facing == 1 then
      sfacing = 'posX'
    elseif facing == 2 then
      sfacing = 'negZ'
    else
      sfacing = 'negX'
    end 
    print(string.format('Current coords %n,%n, facing ' .. sfacing,x,z))
  end
end

local function GoToStart()
  print('Now returning to origin position: (0,0)')
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
  print('Now evaluating tool durability')
  if robot.durability() < .5 then
    print('Tool durability evaluation: Too low to continue assigned task')
    print('Following proposed solution, wait 15 seconds')
    os.sleep(15)
    print('15 second sleep now ending')
  else
    print('Tool durability evaluation: Tool durability within acceptable range')
    print('continuing assigned task')
  end
end

local function EvaluateStock()
  print('Now evaluating stock levels of first inventory slot')
  GoToStart()
  faceNegX()
  if robot.count() < 32 then
    print('Stock levels too low')
    while robot.count() < 32 do
      robot.suck()
    end
  end
  facePosZ()
end

local function EvaluatePower()
  print('Now evaluating energy levels')
  current = computer.energy()
  max = computer.maxEnergy()
  if current / max < .5 then
    print('Energy level evaluation: Too low to continue assigned task')
    print('Following proposed solution, wait 15 seconds')
    os.sleep(30)
    print('30 second sleep now ending')
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
    print('Now beginning assigned task: dropping off excess items')
    GoToStart()
    facePosX()
    GoForward()
    print('Waiting 30 seconds for inventory to empty into hopper')
    os.sleep(30)
    print('30 second sleep now ending')
    faceNegX()
    GoForward()
    facePosZ()
end

local function navigateFarm(action, task)
  print('Now beginning assigned task: ' .. task)
  GoToStart()
  EvaluatePower()
  EvaluateStock()
  for x = 1,treesX do
    facePosX()
    for t = 0,distanceBetweenTrees do 
      GoForward() 
    end
    facePosZ()
    for z = 1, treesZ do
      for t = 0,distanceBetweenTrees do 
        GoForward() 
      end
      facePosX()
      action()
      facePosZ()
    end
    faceNegZ()
    for t = 1,(distanceBetweenTrees+1)*treesZ do 
      GoForward() 
    end
  end
end

-- Select the first slot, whihc is supposed ro have a sapling
robot.select(1)
if #args > 1 then
  if args[2] == '-v' or args[2] == '-V' then
    verbose = true
  end
end

while true do
  navigateFarm(CutTrees, 'Cut down trees')
  navigateFarm(PlantTrees, 'Replant trees')
  dropOffItems()
  os.sleep(300)
end
