function HatchEgg(keys)
    local hatchery = keys.caster
    local hero = hatchery:GetOwner()
    local inventoryDetails = ValidateInventory( GetInventoryDetails( hatchery ) )
    if inventoryDetails.isValid then
        local spawnedBird = SpawnBird(SelectBird(inventoryDetails, hero), hatchery)
        ImproveAbility(spawnedBird, inventoryDetails)
    else
        SendErrorMessage(hero:GetPlayerOwnerID(), inventoryDetails.errorMessage)
    end
end


function GetInventoryDetails(hatchery)
    local itemTypes = {
        {type="hide", decides = "bird_type", selects = "npc_creep_hawk",  count=0 },
        {type="clay", decides = "bird_type", count=0, selects = "npc_creep_drake_bone", count=0},
        {type="spirit", decides = "bird_type", count=0, selects = "npc_creep_hawk", count=0},
        {type="thistle", decides = "bird_type", count=0, selects = "npc_creep_hawk", count=0},
        {type="mushroom", decides = "bird_type", count=0, selects = "npc_creep_hawk", count=0},
        {type="rock_dark", decides = "bird_type", count=0, selects = "npc_creep_hawk", count=0},
        {type="stick", decides = "ability", count=0, incleases = "health", by = "5%", count=0},
        {type="butsu",decides = "ability", count=0, incleases = "movement_speed", by = "5%", count=0},
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
    local functionList = {}

    functionList["health"] = function (creep, by, itemcount)
        local newHealthValue = creep:GetHealth()+  math.floor(creep:GetHealth()* (itemcount*by/100.0))
        creep:SetMaxHealth(newHealthValue)
        creep:SetHealth(newHealthValue)
        return creep
    end

    functionList["movement_speed"] = function(creep, by, itemcount)
        creep:SetBaseMoveSpeed(creep:GetBaseMoveSpeed()+ math.floor(creep:GetBaseMoveSpeed()* (itemcount*by/100.0)))
        return creep
    end


    for i,itemType in pairs(inventoryDetails.itemTypes) do
        if itemType.decides == "ability" and itemType.count > 0 then
           local by = string.gsub(itemType.by,"%%","") -- Removing percentage sign
           local f = functionList[itemType.incleases]
           selectedBird = f( selectedBird, by, itemType.count )
        end
    end
    return selectedBird
end
