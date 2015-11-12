GAME_BUSH_TICK_TIME = 1--30

function ITT:SpawnBushes()
    local bush_herb_spawners = Entities:FindAllByClassname("npc_dota_spawner")
    GameRules.Bushes = {}
    for _,spawner in pairs(bush_herb_spawners) do
        local spawnerName = spawner:GetName()
        if string.find(spawnerName, "_bush_") then
            local bush_name = string.sub(string.gsub(spawner:GetName(), "spawner_", ""), 5)
            local bush = CreateUnitByName(bush_name, spawner:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)
            if bush then
                table.insert(GameRules.Bushes, bush)
                CreateBushContainer(bush)
            end
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
        
        if rand + bush.RngWeight >= 5 then 
            bush.RngWeight = bush.RngWeight - 1 --if spawn succeeds reduce the odds of the next spawn

            local bush_name = bush:GetUnitName()
            local bushTable = GameRules.BushInfo[bush_name]
            local possibleChoices = TableCount(bushTable)
            local randomN = tostring(RandomInt(1, possibleChoices))
            local bush_random_item = bushTable[randomN]

            GiveItemStack(bush, bush_random_item)

        else
            bush.RngWeight = bush.RngWeight + 1 --if spawn fails increase odds for next run
        end
    end

    return GAME_BUSH_TICK_TIME
end

function CreateBushContainer( bush )
    local cont = Containers:CreateContainer({
        layout =      {3,3},
        --skins =       {"Hourglass"},
        headerText =  bush:GetUnitName(),
        buttons =     {"Grab All"},
        position =    "entity", --"mouse",--"900px 200px 0px",
        draggable = false,
        closeOnOrder= true,
        items = {},
        entity = bush,
        range = DEFAULT_TRANSFER_RANGE,
        OnDragWorld = true,

        --[[OnDragFrom = function(playerID, unit, container, item, fromSlot, toContainer, toSlot) 
            --stuff here
            Containers:OnDragFrom(playerID, unit, container, item, fromSlot, toContainer, toSlot)
        end]]

        OnLeftClick = function(playerID, unit, container, item, slot)

            if CanTakeMoreItems(unit) or CanTakeMoreStacksOfItem(unit, item) then
                unit:StartGesture(ACT_DOTA_ATTACK)

                TransferItem(bush, unit, item)

            else
                SendErrorMessage(playerID, "#error_inventory_full")
            end
        end,

        OnButtonPressed = function(playerID, unit, container, button, buttonName)
            if button == 1 then
                local items = container:GetAllItems()

                for _,item in ipairs(items) do

                    TransferItem(bush, unit, item)

                end

                container:Close(playerID)
            end
        end,
    })

    Containers:SetEntityOrderAction(bush, {
        range = DEFAULT_TRANSFER_RANGE,
        action = function(playerID, unit, target)
            if (bush:GetUnitName() == "npc_bush_scout" and unit:GetClassname() ~= "npc_dota_hero_lion") then
                SendErrorMessage(playerID, "#error_scout_only_bush")
                return --exits if bush is used by anything other than a scout
            end

            if (bush:GetUnitName() == "npc_bush_thief" and unit:GetClassname() ~= "npc_dota_hero_riki") then
                SendErrorMessage(playerID, "#error_thief_only_bush")
                return --exits if bush is used by anything other than a thief
            end
            
            print("ORDER ACTION loot box: ", playerID)
            cont:Open(playerID)
            unit:Stop()
            unit:Hold()
        end,
    })

    bush.container = cont
    bush.replicatedContainer = true

    Containers:SetDefaultInventory(bush, container)
end