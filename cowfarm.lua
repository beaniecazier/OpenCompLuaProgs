--- Automatic King Tree Farmer for Drones
-- Need a drone with one solar and one inventory upgrade.

local robot = component.proxy(component.list("robot")())

local function sleep(timeout)
end

local function wait()
end

local function equip()
end

local function turnOnWater()
end

local function turnOffWater()
end

local function markWaypoints()
end

local function stockWheat()
end

local function startUp()
end

local function checkEnergy()
end

local function feed()
end

local function drop()
end

local function dropAll()
end

local function move(x, y, z)
end

local function beep(code)
end

local function checkArgs()
end

local function init()
    -- check energy
    -- go to start position
    -- make sure fully charged
    -- check if all needs components can be found
    -- check if looting sword is available
    -- check for a stack of wheat
    checkEnergy()

-- Main Loop
do while true
    checkArgs()
    init()
    -- go to water switch
    -- turn on water switch
    -- loop
    -- get wheat
    -- go to cows
    -- loop
    -- feed
    -- wait
    -- end loop
    -- end loop
    -- turn off water
    -- get sword
    -- check sword durability
    -- if <25% issue warning and cease functionality
    -- go to kill spot
    -- wait till cows are adults
    -- kills cows
    -- return sword
end