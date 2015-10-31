GAME_CREATURE_TICK_TIME     = 20   -- Time for each creature spawn
MAXIMUM_PASSIVE_NEUTRALS    = 300
MAXIMUM_AGGRESSIVE_NEUTRALS = 20

-- Game periods determine what is allowed to spawn, from start (0) to X seconds in
GAME_PERIOD_GRACE           = 420
GAME_PERIOD_EARLY           = 900

if not Spawns then
    _G.Spawns = class({})
end

-- Stores the possible spawners for each creature name and start
function Spawns:Init()
    
    print("Spawns Init")
    GameRules.SpawnInfo = LoadKeyValues("scripts/kv/spawn_info.kv")

    Spawns.locations = {}
    local spawnerNames = GameRules.SpawnInfo['SpawnerNames']

    for unitName,spawnerName in pairs(spawnerNames) do
        local spawners = Entities:FindAllByName("*"..spawnerName.."*")
        -- Store the position of each spawner under a table associated to the creep name
        Spawns.locations[unitName] = {}
        for k,spawnerEnt in pairs(spawners) do
            table.insert(Spawns.locations[unitName], spawnerEnt:GetAbsOrigin())
        end
    end

    Spawns.neutralCount = {}
    for unitName,_ in pairs(spawnerNames) do
        Spawns.neutralCount[unitName] = 0
    end

    Timers:CreateTimer(function()
        Spawns:Think()
        return GAME_CREATURE_TICK_TIME
    end)

    -- Spawn the mammoth at start
    -- This needs to go on its spot
    --[[if (GameMode.neutralCurNum["npc_creep_mammoth"] == 0) then
        SpawnCreature("npc_creep_mammoth", "spawner_neutral_mammoth")
    end]]

end
   
function Spawns:Think()

    -- Determine which spawn table to use depending on the game time
    local time = math.floor(GameRules:GetGameTime())
    local spawnTable = GameRules.SpawnInfo['Start']
    if time > GAME_PERIOD_EARLY then
        spawnTable = GameRules.SpawnInfo['Early']
    elseif time > GAME_PERIOD_GRACE then
        spawnTable = GameRules.SpawnInfo['Grace']
    end

    -- Roll chance and restrict creature spawns up to the max allowed
    local neutralMaxTable = GameRules.SpawnInfo['Max']
    for unitName,creepTable in pairs(spawnTable) do
        local spawnChance = creepTable['Chance']
        local numToSpawn = creepTable['Number']

        for i=1,numToSpawn do
            if RollPercentage(spawnChance) and (Spawns.neutralCount[unitName] < neutralMaxTable[unitName]) then
                Spawns:Create(unitName)
            end
        end
    end
end

-- Creates a neutral on a predefined spawner position
function Spawns:Create( unitName )
    local locations = Spawns.locations[unitName]
    if not locations then
        print("ERROR: no spawner locations stored for "..unitName)
    end

    local position = GetEmptyLocation(locations)

    local unit = CreateUnitByName(unitName, position, true, nil, nil, DOTA_TEAM_NEUTRALS)
    Timers:CreateTimer(function() FindClearSpaceForUnit(unit, position, false) end)

    Spawns.neutralCount[unitName] = Spawns.neutralCount[unitName] + 1
end

-- Find a spawner location that doesn't have something nearby
function GetEmptyLocation( locations )
    local possibleLocations = ShuffledList(locations)

    for k,possibleLocation in pairs(possibleLocations) do
        local nearbyUnits = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, possibleLocation, nil, 100, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
        if #nearbyUnits == 0 then
            return possibleLocation
        end
    end
    
    return locations(RandomInt(1, #locations))
end