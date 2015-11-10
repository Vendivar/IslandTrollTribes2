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
            end
        end
    end
    local bushCount = #GameRules.Bushes
    print("Spawned "..bushCount.." bushes total")

    Timers:CreateTimer(GAME_BUSH_TICK_TIME, function()
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

-- Moves towards a bush and extracts items from it
function ITT:BushGather( event )
    local playerID = event.PlayerID
    local bush = EntIndexToHScript(event.entityIndex)
    local unit = PlayerResource:GetSelectedHeroEntity(playerID)

    print("Gather from "..bush:GetUnitName())

    -- Order Timers Reset
    if unit.orderTimer then
        Timers:RemoveTimer(unit.orderTimer)
    end

    if (bush:GetUnitName() == "npc_bush_scout" and unit:GetClassname() ~= "npc_dota_hero_lion") then
        SendErrorMessage(playerID, "#error_scout_only_bush")
        return --exits if bush is used by anything other than a scout
    end

    if (bush:GetUnitName() == "npc_bush_thief" and unit:GetClassname() ~= "npc_dota_hero_riki") then
        SendErrorMessage(playerID, "#error_thief_only_bush")
        return --exits if bush is used by anything other than a thief
    end

    -- Move towards the bush
    local position = bush:GetAbsOrigin()
    ExecuteOrderFromTable({ UnitIndex = unit:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = position, Queue = false})
    unit.orderTimer = Timers:CreateTimer(function()
        if IsValidAlive(unit) and (unit:GetAbsOrigin() - position):Length2D() <= DEFAULT_TRANSFER_RANGE then
            print("Reached Bush!")
            unit:Stop()
            if GetNumItemsInInventory(bush) > 0 then
                unit:StartGesture(ACT_DOTA_ATTACK)

                -- Transfer items from the bush to the gatherer
                for i=0,5 do
                    Timers:CreateTimer(0.1*i, function()

                        local item = bush:GetItemInSlot(i)
                        if item then
                            TransferItem(bush, unit, item)
                        end
                    end)
                end
            end

            return
        end
        return 0.1
    end)
end

function ITT:ContainerTest( hero )
    local position = hero:GetAbsOrigin() + hero:GetForwardVector() * 200

    CreateLootBox(position)
end

function RandomItem(owner)
  local id = RandomInt(1,29)
  local name = Containers.itemIDs[id]
  print(name)
  return CreateItem(name, owner, owner)
end

function CreateLootBox(loc)
    local phys = CreateItemOnPositionSync(loc, CreateItem("item_bush_mushroom", nil, nil))
    phys:SetForwardVector(Vector(0,-1,0))
    phys:SetModelScale(1.5)

    local items = {}
    local slots = {1,2,3,4,5,6}
    for i=1,6 do
        items[i] = CreateItem("item_mushroom", nil, nil)
    end

    local cont = Containers:CreateContainer({
    layout =      {3,3},
    --skins =       {"Hourglass"},
    headerText =  "Mushroom Bush",
    buttons =     {"Grab All"},
    position =    "entity", --"mouse",--"900px 200px 0px",
    draggable = false,
    closeOnOrder= true,
    items = items,
    entity = phys,
    range = 150,

    OnLeftClick = function(playerID, unit, container, item, slot)
        if CanTakeMoreItems(unit) or CanTakeMoreStacksOfItem(unit, item) then
            container:RemoveItem(item)
            Containers:AddItemToUnit(unit,item)
        else
            SendErrorMessage(playerID, "#error_inventory_full")
        end
    end,

    OnButtonPressed = function(playerID, unit, container, button, buttonName)
      if button == 1 then
        local items = container:GetAllItems()
        for _,item in ipairs(items) do
          container:RemoveItem(item)
          Containers:AddItemToUnit(unit,item)
        end

        container:Close(playerID)
      end
    end,
    })

    Containers:SetEntityOrderAction(phys, {
    range = 150,
    action = function(playerID, unit, target)
      print("ORDER ACTION loot box: ", playerID)
      cont:Open(playerID)
      unit:Stop()
    end,
    })

    loc.container = cont
    loc.phys = phys
end