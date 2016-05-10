GAME_BUSH_TICK_TIME = 60

function ITT:SpawnBushes()
    Containers:SetDisableItemLimit(true)
    Containers:UsePanoramaInventory(false)

    local bushSpawnerTable = GameRules.BushInfo["BushSpawnInfo"]["SpawnerNames"]
    GameRules.Bushes = {}
    Spawns.bushCount = {}
    Spawns.bushCount["World"]= {{}}
    Spawns.bushCount["Island"]= {{},{},{},{}}
    for bushItem,_ in pairs(bushSpawnerTable) do
        Spawns.bushCount["World"][1][bushItem] = 0
        for i,_ in pairs(REGIONS) do
            Spawns.bushCount["Island"][i][bushItem] = 0
        end
    end
    GameRules.PredefinedBushLocations = GetPredefinedBushLocations(bushSpawnerTable)
    local locationType =  GameRules.BushSpawnLocationType
    local regionType = GameRules.BushSpawnRegion
    for bushItem,_ in pairs(bushSpawnerTable) do
        SpawnBushes(bushItem, regionType, locationType)
    end

    local bushCount = #GameRules.Bushes
    print("Spawned "..bushCount.." bushes total")

    Timers:CreateTimer(function()
        ITT:OnBushThink()
        return GAME_BUSH_TICK_TIME
    end)
end


function SpawnBushes(bushItem, regionType, locationType)
    if regionType == "World"  then
        SpawnBushesCommon(bushItem, locationType, regionType, WORLD)
    elseif regionType == "Island" then
        SpawnBushesCommon(bushItem, locationType,regionType, REGIONS)
    end
end

function SpawnBushesCommon(bushItem, locationType, regionType, regions)
    local bushMaxTable = GameRules.BushInfo["BushSpawnInfo"]['Max'][regionType]
    for i,region in pairs(regions)  do
        for count=1,bushMaxTable[bushItem] do
            local spawnLocation = GetBushSpawnLocation(bushItem, region, locationType)
            if spawnLocation then
                CreateBush(bushItem, spawnLocation)
                CreateBushContainer(bushItem, spawnLocation)
            end
            Spawns.bushCount[regionType][i][bushItem] = Spawns.bushCount[regionType][i][bushItem] + 1
        end
    end
end

function GetPredefinedBushLocations(bushSpawnerTable)
    local allSpawners = Entities:FindAllByClassname("npc_dota_spawner")
    local bushSpawners = {}
    for bushItem,_ in pairs(bushSpawnerTable) do
        bushSpawners[bushItem] = {}
    end
    for _,spawner in pairs(allSpawners) do
        local spawnerName = spawner:GetName()
        if string.find(spawnerName, "_bush_") then
            local cutoff = string.find(spawnerName,"s")
            local bushName = "npc_".. string.gsub(string.sub(spawnerName, cutoff), "spawner_npc_", "")
            local itemName = "item_"..bushName
--            print("bushname " .. bushName)
            table.insert(bushSpawners[bushName],spawner)
        end
    end
    return bushSpawners
end

function GetBushSpawnLocation(bushItem, region, locationType)
    local location
    if locationType == "random" then
        location = GetRandomBushLocation(region, bushItem)
    elseif locationType == "predefined" then
        location = GetPredefinedBushLocation(region, bushItem)
    elseif locationType == "mix" then
        if RollPercentage(50) then
            location = GetRandomBushLocation(region, bushItem)
        else
            location = GetPredefinedBushLocation(region,  bushItem)
        end
    end
    return location
end

-- Creates a neutral on a predefined spawner position
function GetPredefinedBushLocation(region, bushItem)
    local locations = GetPredefinedBushLocationsOnRegion(region, bushItem)
    if not locations then
        print("ERROR: no spawner locations stored for "..bushItem)
    end
    local location = GetEmptyLocation(locations)
    return location
end

function GetPredefinedBushLocationsOnRegion(region, bushItem)
    local locations  = {}
    for _,predefinedLocation in pairs(GameRules.PredefinedBushLocations[bushItem]) do
        local location = predefinedLocation:GetAbsOrigin()
        if IsVectorInBounds(location, region[1], region[2], region[4], region[3]) and not IsNearABush(location, bushItem) then
            table.insert(locations, location)
        end
    end
    return locations
end

function IsNearABush(location, bushItem)
    local nearbyBushes = Entities:FindAllByClassnameWithin("npc_dota_creature", location, 200)
    for _,bushName in pairs(nearbyBushes) do
        if bushName:GetUnitName() == bushItem then
            return true
        end
    end
    return false
end

-- Creates a nutral on a random location
function GetRandomBushLocation(region, bushItem)
    local location = GetRandomVectorGivenBounds(region[1], region[2], region[3], region[4])
    while IsNearABush(location, bushItem) do
        location = GetRandomVectorGivenBounds(region[1], region[2], region[3], region[4])
    end
    return location
end

function ITT:OnBushThink()
    print("OnBushThink Creating Items on Bushes")
    
    local bushes = GameRules.Bushes

    for k,bush in pairs(bushes) do
        if bush.RngWeight == nil then --rng weight maks it so there's a chance a bush won't spawn but you won't get rng fucked
            bush.RngWeight = 1 --if rng weight doesnt exist declare it to a value that's unlikely to spawn for the first few ticks
        end

        local rand = RandomInt(-4,4) --randomize between -4 and +4, since the min is 0 with the best rng on the minimum number you will still not get a spawn
        local numItems = #(bush.container:GetAllItems())
        --print("Bush name: "..bush:GetUnitName())
        if rand + bush.RngWeight >= 5 and numItems <= 6 then
            bush.RngWeight = bush.RngWeight - 1 --if spawn succeeds reduce the odds of the next spawn

            local bush_name = bush.name
            local bushTable = GameRules.BushInfo["Bushes"][bush_name]
            local possibleChoices = TableCount(bushTable)
            local randomN = tostring(RandomInt(1, possibleChoices))
            local bush_random_item = bushTable[randomN]

            --GiveItemStack(bush, bush_random_item)
            local item = CreateItem(bush_random_item, nil, nil)
            bush.container:AddItem(item) --Missing stack handling
            print("Added " .. bush_random_item .. " to ".. bush_name .. " " .. bush:GetEntityIndex())

            -- Particle glow
            AddBushGlow(bush)
        else
            bush.RngWeight = bush.RngWeight + 1 --if spawn fails increase odds for next run
            --print("Spawn Failed " .. bush:GetUnitName() .. " " .. bush:GetEntityIndex())
        end
    end
    --print("bush spawning time: " .. math.floor(GameRules:GetGameTime()))
    return GAME_BUSH_TICK_TIME
end

function CreateBush(name, position)
    local bush
    -- Scout bush has to be a unit for invisibility
    if name:match("scout") then
        bush = CreateUnitByName(name, position, true, nil, nil, DOTA_TEAM_NEUTRALS)
    else
        bush = CreateItemOnPositionSync(position, CreateItem(name:gsub("npc","item"), nil, nil))
    end
    bush.name = name --keep the name as npc to not need to change the kv table

    table.insert(GameRules.Bushes, bush)

    CreateBushContainer(name, bush)
    --Containers:SetDefaultInventory(bush, container)
end

function AddBushGlow(entity)
    if not entity.whiteGlowParticle then
        --Particle refused to show through fog for an hour so give vision instead
        for _,v in pairs(VALID_TEAMS) do AddFOWViewer(v, entity:GetAbsOrigin(), 100, 0.1, false) end

        local particleName = "particles/custom/dropped_item_white.vpcf"
        entity.whiteGlowParticle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, entity)
        ParticleManager:SetParticleControlEnt(entity.whiteGlowParticle, 0, entity, PATTACH_POINT_FOLLOW, "attach_hitloc", entity:GetAbsOrigin(), true)
    end
end

function RemoveBushGlow(entity)
    if entity.whiteGlowParticle then
        ParticleManager:DestroyParticle(entity.whiteGlowParticle, true)
        entity.whiteGlowParticle = nil
    end
end

function CreateBushContainer(name, bush)
    local cont = Containers:CreateContainer({
        layout =      {3,3},
        --skins =       {"Hourglass"},
        headerText =  name,
        buttons =     {"Grab All"},
        position="worldpanel", --"mouse",--"900px 200px 0px",
        draggable = false,
        closeOnOrder= true,
        items = {},
        entity = bush,
        range = DEFAULT_TRANSFER_RANGE,
        OnDragWorld = true,

        OnLeftClick = function(playerID, container, unit, item, slot)

            container:RemoveItem(item)
            Containers:AddItemToUnit(unit,item)

            --[[if CanTakeMoreItems(unit) or CanTakeMoreStacksOfItem(unit, item) then
                unit:StartGesture(ACT_DOTA_ATTACK)

                TransferItem(container, unit, item)

            else
                SendErrorMessage(playerID, "#error_inventory_full")
            end]]

            if container:GetNumItems() == 0 then RemoveBushGlow(bush) end
        end,

        OnRightClick = function(playerID, container, unit, item, slot)
            container:RemoveItem(item)
            Containers:AddItemToUnit(unit,item)

            if container:GetNumItems() == 0 then RemoveBushGlow(bush) end
        end,

        OnButtonPressed = function(playerID, container, unit, button, buttonName)
            if button == 1 then
                local items = container:GetAllItems()

                for _,item in ipairs(items) do

                    --TransferItem(container, unit, item)
                    container:RemoveItem(item)
                    Containers:AddItemToUnit(unit,item)

                end

                container:Close(playerID)
                RemoveBushGlow(bush)
            end
        end,

        OnEntityOrder = function(playerID, container, unit, target)
            --[[if (bush:GetUnitName() == "npc_bush_scout" and unit:GetClassname() ~= "npc_dota_hero_lion") then
                SendErrorMessage(playerID, "#error_scout_only_bush")
                return --exits if bush is used by anything other than a scout
            end

            if (bush:GetUnitName() == "npc_bush_thief" and unit:GetClassname() ~= "npc_dota_hero_riki") then
                SendErrorMessage(playerID, "#error_thief_only_bush")
                return --exits if bush is used by anything other than a thief
            end]]
            
            print("ORDER ACTION loot box: ", playerID)
            container:Open(playerID)
            unit:Stop()
            unit:Hold()
        end,
    })

    bush.container = cont
    bush.phys = phys
end