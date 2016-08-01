MAXIMUM_PASSIVE_NEUTRALS    = 70
MAXIMUM_AGGRESSIVE_NEUTRALS = 20

-- Game periods determine what is allowed to spawn, from start (0) to X seconds in
GAME_PERIOD_GRACE             = 420
GAME_PERIOD_MIDGAME           = 900

if not Spawns then
    _G.Spawns = class({})
end

-- Stores the possible spawners for each creature name and start
function Spawns:Init()

    print("Spawns Init")
    GameRules.SpawnInfo = LoadKeyValues("scripts/kv/spawn_info.kv")

    Spawns.predefinedLocations = {}
    local spawnerNames = GameRules.SpawnInfo['SpawnerNames']

    for unitName,spawnerName in pairs(spawnerNames) do
        local spawners = Entities:FindAllByName("*"..spawnerName.."*")
        -- Store the position of each spawner under a table associated to the creep name
        Spawns.predefinedLocations[unitName] = {}
        for k,spawnerEnt in pairs(spawners) do
            table.insert(Spawns.predefinedLocations[unitName], spawnerEnt:GetAbsOrigin())
        end
    end

    Spawns.neutralCount = {}
    Spawns.neutralCount["World"]= {{}}
    Spawns.neutralCount["Island"]= {{},{},{},{}}
    for unitName,_ in pairs(spawnerNames) do
        Spawns.neutralCount["World"][1][unitName] = 0
        for i,_ in pairs(REGIONS) do
            Spawns.neutralCount["Island"][i][unitName] = 0
        end
    end

    Timers:CreateTimer(function()
        Spawns:Think()
        return GameRules.GameModeSettings["GAME_CREATURE_TICK_TIME"]
    end)

    -- Spawn the mammoth at start
    -- This needs to go on its spot
    --[[if (GameMode.neutralCurNum["npc_creep_mammoth"] == 0) then
        SpawnCreature("npc_creep_mammoth", "spawner_neutral_mammoth")
    end]]

end

function GetPredefinedLocationsOnRegion(region, unitName)
    local locations  = {}
    for _,predefinedLocation in pairs(Spawns.predefinedLocations[unitName]) do
        if IsVectorInBounds(predefinedLocation, region[1], region[2], region[4], region[3]) then
            table.insert(locations,predefinedLocation)
        end
    end
    return locations
end

function GetSpawnInstructions()
    -- Determine which spawn table to use depending on the game time
    local time = math.floor(GameRules:GetGameTime())
    local spawnTable = GameRules.SpawnInfo['Initial']
    if time > GAME_PERIOD_MIDGAME then
        spawnTable = GameRules.SpawnInfo['MidGame']
    elseif time > GAME_PERIOD_GRACE then
        spawnTable = GameRules.SpawnInfo['EarlyGame']
    elseif time > GameRules.GameModeSettings["GAME_CREATURE_TICK_TIME"] then
        spawnTable = GameRules.SpawnInfo['Start']
    end
    return spawnTable
end

function Spawns:Think()
    -- Roll chance and restrict creature spawns up to the max allowed
    local spawnTable = GetSpawnInstructions()
    local locationTypeTable = GameRules.SpawnInfo['LocationTypes'][GameRules.SpawnLocationType]
    for unitName,creepTable in pairs(spawnTable) do
        local spawnChance = creepTable['Chance']
        local numToSpawn = creepTable['Number']
        for i=1,numToSpawn do
            if RollPercentage(spawnChance) then
                if unitName == "npc_creep_fish" or unitName == "npc_creep_fish_green" or GameRules.SpawnRegion == "World" then
                    SpawnUnitInWorld(unitName, locationTypeTable[unitName])
                else
                    SpawnUnitOnEachIsland(unitName, locationTypeTable[unitName])
                end
            end
        end
    end
end

function SpawnUnitOnEachIsland(unitName, locationType)
    local regionType = "Island"
    local neutralMaxTable = GameRules.SpawnInfo['Max'][regionType]
    for i,region in pairs(REGIONS)  do
        if (Spawns.neutralCount[regionType][i][unitName] < neutralMaxTable[unitName]) then
            local location = GetSpawnLocation(unitName, region, locationType)
            --local unit = CreateUnitByName(unitName, location + RandomVector(RandomInt(500,500)), true, nil, nil, DOTA_TEAM_NEUTRALS)
            local unit = CreateUnitByName(unitName, location, true, nil, nil, DOTA_TEAM_NEUTRALS)
            unit.locationDetails = {regionType = regionType, regionId = i}
            Timers:CreateTimer(function() FindClearSpaceForUnit(unit, location, false) end)
            Spawns.neutralCount[regionType][i][unitName] = Spawns.neutralCount[regionType][i][unitName] + 1
        end
    end
end
--and (Spawns.neutralCount[GameRules.SpawnRegion][unitName] < neutralMaxTable[unitName]
function SpawnUnitInWorld(unitName, locationType)
    local regionType = "World"
    local neutralMaxTable = GameRules.SpawnInfo['Max'][regionType]
    local world =  {-8000, 8000, 8000, -8000, 1 }
    if (Spawns.neutralCount[regionType][1][unitName] < neutralMaxTable[unitName]) then
        local location = GetSpawnLocation(unitName, world, locationType)
        local unit = CreateUnitByName(unitName, location, true, nil, nil, DOTA_TEAM_NEUTRALS)
        unit.locationDetails = {regionType = regionType, regionId = 1}
        Timers:CreateTimer(function() FindClearSpaceForUnit(unit, location, false) end)
        Spawns.neutralCount[regionType][1][unitName] = Spawns.neutralCount[regionType][1][unitName] + 1
    end
end

function GetSpawnLocation(unitName, region, locationType)
    local location
    if locationType == "random" then
        location = Spawns:GetRandomLocation(region, unitName)
    elseif locationType == "predefined" then
        location = Spawns:GetPredefinedLocation(region , unitName)
    elseif locationType == "mix" then
        if RollPercentage(50) then
            location = Spawns:GetRandomLocation(region, unitName)
        else
            location = Spawns:GetPredefinedLocation(region , unitName)
        end
    end
    return location
end

-- Creates a neutral on a predefined spawner position
function Spawns:GetPredefinedLocation(region, unitName )
    local locations = GetPredefinedLocationsOnRegion(region, unitName)
    if not locations then
        print("ERROR: no spawner locations stored for "..unitName)
    end
    local location = GetEmptyLocation(locations)
    return location
end

-- Creates a nutral on a random location
function Spawns:GetRandomLocation(region)
    local location = GetRandomVectorGivenBounds(region[1], region[2], region[3], region[4])
    while IsNearABuilding(location) or IsNearAHero(location) do
        location = GetRandomVectorGivenBounds(region[1], region[2], region[3], region[4])
    end
    return location
end

-- Find a spawner location that doesn't have something nearby
function GetEmptyLocation( locations )
    local possibleLocations = ShuffledList(locations)
    for _,possibleLocation in pairs(possibleLocations) do
        local nearbyUnits = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, possibleLocation, nil, 1000, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
        if #nearbyUnits == 0 and not IsNearABuilding(possibleLocation) then
            return possibleLocation
        end
    end
    return locations[RandomInt(1, #locations)]
end

function IsNearAHero(location)
    local nearbyUnits = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, location, nil, 1000, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, 0, 0, false)
    return #nearbyUnits > 0
end

function IsNearABuilding(location)
    local nearbyUnits = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, location, nil, 1000, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
    for _,unit in pairs(nearbyUnits) do
        if IsCustomBuilding(unit) then
            return true
        end
    end
    return false
end
