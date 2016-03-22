GAME_BUSH_TICK_TIME = 30

function ITT:SpawnBushes()
    Containers:SetDisableItemLimit(true)
    Containers:UsePanoramaInventory(false)

    local bush_herb_spawners = Entities:FindAllByClassname("npc_dota_spawner")
    GameRules.Bushes = {}
    for _,spawner in pairs(bush_herb_spawners) do
        local spawnerName = spawner:GetName()
        if string.find(spawnerName, "_bush_") then
            local cutoff = string.find(spawnerName,"s")
            local bushName = string.gsub(string.sub(spawnerName, cutoff), "spawner_npc_", "")
            local itemName = "item_"..bushName
            CreateBushContainer(itemName, spawner:GetAbsOrigin())
        end
    end
    local bushCount = #GameRules.Bushes
    print("Spawned "..bushCount.." bushes total")

    Timers:CreateTimer(function()
        ITT:OnBushThink()
        return GAME_BUSH_TICK_TIME
    end)
end

function ITT:OnBushThink()
    --print("--Creating Items on Bushes--")
    
    local bushes = GameRules.Bushes
    
    for k,bush in pairs(bushes) do
        if bush.RngWeight == nil then --rng weight maks it so there's a chance a bush won't spawn but you won't get rng fucked
            bush.RngWeight = 0 --if rng weight doesnt exist declare it to a value that's unlikely to spawn for the first few ticks
        end

        local rand = RandomInt(-4,4) --randomize between -4 and +4, since the min is 0 with the best rng on the minimum number you will still not get a spawn
        local items = bush.container:GetAllItems()
        if rand + bush.RngWeight >= 5 and #items <= 6 then 
            bush.RngWeight = bush.RngWeight - 1 --if spawn succeeds reduce the odds of the next spawn

            local bush_name = string.gsub(bush:GetContainedItem():GetAbilityName(), "item_", "")
            local bushTable = GameRules.BushInfo[bush_name]
            local possibleChoices = TableCount(bushTable)
            local randomN = tostring(RandomInt(1, possibleChoices))
            local bush_random_item = bushTable[randomN]

            --GiveItemStack(bush, bush_random_item)
            bush.container:AddItem(CreateItem(bush_random_item, nil, nil)) --Missing stack handling

        else
            bush.RngWeight = bush.RngWeight + 1 --if spawn fails increase odds for next run
        end
    end

    return GAME_BUSH_TICK_TIME
end

function CreateBushContainer( name, position )

    local newItem = CreateItem(name, nil, nil)
    local bush = CreateItemOnPositionSync(position, newItem)

    --Particle refused to show through fog for an hour so give vision instead
    for _,v in pairs(VALID_TEAMS) do AddFOWViewer ( v, position, 100, 0.1, false) end

    table.insert(GameRules.Bushes, bush)

    local cont = Containers:CreateContainer({
        layout =      {3,3},
        --skins =       {"Hourglass"},
        headerText =  newItem:GetAbilityName(),
        buttons =     {"Grab All"},
        position =    "entity", --"mouse",--"900px 200px 0px",
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

    --Containers:SetDefaultInventory(bush, container)
end