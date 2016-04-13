function HatchEgg(keys)
    local hatchery = keys.caster
    local hero = hatchery:GetOwner()
    local inventoryDetails = ValidateInventory( GetInventoryDetails( hatchery ) )
    if inventoryDetails.isValid then
        local spawnedBird = SpawnBird(SelectBird(inventoryDetails, hero), hatchery)
        ImproveAbility(spawnedBird, inventoryDetails)
        RemoveInventoryItems( inventoryDetails, hatchery )
        
    local lockedSlotCount = 5
    ITT:CreateLockedSlotsForUnits(spawnedBird, lockedSlotCount)
    else
        SendErrorMessage(hero:GetPlayerOwnerID(), inventoryDetails.errorMessage)
    end
end


function GetInventoryDetails(hatchery)

    local itemTypes = {
        {type="hide", decides = "bird_type", selects = "npc_creep_hawk",  count=0 },
        {type="clay", decides = "bird_type",  selects = "npc_creep_drake_bone", count=0},
        {type="spirit", decides = "bird_type", selects = "npc_creep_hawk", count=0},
        {type="thistle", decides = "bird_type", selects = "npc_creep_hawk", count=0},
        {type="mushroom", decides = "bird_type", selects = "npc_creep_hawk", count=0},
        {type="rock_dark", decides = "bird_type",  selects = "npc_creep_hawk", count=0},
        
        {type="clay", decides = "ability", incleases = "health", by = "5%", count=0}, --Red Dragon
        {type="hide",decides = "ability", incleases = "health", by = "50", count=0},  --Red Dragon
        {type="butsu",decides = "ability", incleases = "movement_speed", by = "5%", count=0}, --Blue Dragon
        {type="stick",decides = "ability", incleases = "movement_speed", by = "5%", count=0},  --Blue Dragon
        {type="rock_dark",decides = "ability", incleases = "all_bonus", by = "1", count=0}, --Black Dragon
    }
    local inventoryDetails = { isValid = false, totalItemCount = 0, itemTypes = itemTypes,  errorMessage="", firstItem ="" }
    for i=0,5 do
        local item = hatchery:GetItemInSlot(i)
        if item then
            item = item:GetName()
            for i,itemType in pairs(inventoryDetails.itemTypes) do
                if string.match(item, itemType.type ) then
                    itemType.count = itemType.count + 1
                end
            end
            inventoryDetails.totalItemCount = inventoryDetails.totalItemCount + 1
        end
    end
    inventoryDetails.firstItem = GetFirstItemofInventory(hatchery)
    return inventoryDetails
end

function RemoveInventoryItems( inventoryDetails, hatchery )

    local resetInventoryDetails = function ()
        for i,itemType in pairs(inventoryDetails.itemTypes) do
            itemType.count = 0
        end
        inventoryDetails.isValid = false
        inventoryDetails.totalItemCount = 0
        inventoryDetails.errorMessage = ""
        inventoryDetails.firstItem = ""
    end

    local removeInventoryItems = function( inventoryDetails )
        for i=0,5 do
            local item = hatchery:GetItemInSlot(i)
            if item then
                hatchery:RemoveItem(item)
            end
        end
        resetInventoryDetails( inventoryDetails )
    end
    removeInventoryItems( inventoryDetails, hatchery )
end

function GetFirstItemofInventory( hatchery )
    if hatchery:GetItemInSlot(0) then
        return hatchery:GetItemInSlot(0):GetName()
    end
end


function ValidateInventory(inventoryDetails)
    if inventoryDetails.totalItemCount == 0  then
        inventoryDetails.errorMessage = "No items in the hatchery"
    elseif inventoryDetails.totalItemCount < 6 then
        inventoryDetails.errorMessage = "There are no enough items"
    elseif inventoryDetails.firstItem ~= "item_egg_hawk" then
        inventoryDetails.errorMessage = "The first slot in the hatchery must contain a Hawk Egg"
    else
        inventoryDetails.isValid = true
    end
    return inventoryDetails
end


function SelectBird(inventoryDetails, hero)
    inventoryDetails.selectedBird = "npc_creep_hawk"
    if hero:GetName() == "npc_dota_hero_lycan" then 
        inventoryDetails.selectedBird = "npc_creep_hawk"
        return  inventoryDetails.selectedBird
    end
    for  i,itemType in pairs(inventoryDetails.itemTypes) do
        if ( itemType.decides == "bird_type" and itemType.count >= 3  ) then
            inventoryDetails.selectedBird = itemType.selects
            return inventoryDetails.selectedBird
        end
    end
    return inventoryDetails.selectedBird
end


function SpawnBird(selectedBird, hatchery)
    local spawnLocation = Vector(hatchery:GetAbsOrigin().x, hatchery:GetAbsOrigin().y, hatchery:GetAbsOrigin().z + 200)
    local hero = hatchery:GetOwner()
    local hatchEffect = ParticleManager:CreateParticle("particles/custom/fowl_play.vpcf", PATTACH_CUSTOMORIGIN, hatchery)
    ParticleManager:SetParticleControl(hatchEffect,0,spawnLocation)
    local babyHawk = CreateUnitByName(selectedBird, spawnLocation, true, nil, nil, hero:GetTeamNumber())
    return babyHawk
end


function ImproveAbility(selectedBird, inventoryDetails)
    local getIncrement = function(value,by,itemcount)
        local increment = 0
        if string.find(by,"%%") then
            by = string.gsub(by,"%%","") -- Removing percentage sign
            increment = math.floor(value * ( itemcount * by / 100.0))
        else
            increment = itemcount * by
        end
        return increment
    end

    local functionList = {}
    functionList["health"] = function (creep, by, itemcount)
        local newHealthValue = creep:GetHealth() + getIncrement(creep:GetHealth(),by,itemcount)
        creep:SetMaxHealth(newHealthValue)
        creep:SetHealth(newHealthValue)
        return creep
    end

    functionList["movement_speed"] = function(creep, by, itemcount)
        local newMovementSpeed = creep:GetBaseMoveSpeed() + getIncrement( creep:GetBaseMoveSpeed(), by, itemcount)
        creep:SetBaseMoveSpeed(newMovementSpeed)
        return creep
    end

    functionList["all_bonus"] = function(creep, by, itemcount)
        creep = functionList["health"](creep, by, itemcount )
        creep = functionList["movement_speed"](creep, by, itemcount )
        return creep
    end

    for i,itemType in pairs(inventoryDetails.itemTypes) do
        if itemType.decides == "ability" and itemType.count > 0 then
            local f = functionList[itemType.incleases]
            selectedBird = f( selectedBird, itemType.by , itemType.count )
        end
    end
    return selectedBird
end
