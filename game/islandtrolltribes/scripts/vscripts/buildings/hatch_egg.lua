function HatchEgg(keys)

    local hatchery = keys.caster
    local hero = hatchery:GetOwner()
    local spawnLocation = Vector(hatchery:GetAbsOrigin().x, hatchery:GetAbsOrigin().y, hatchery:GetAbsOrigin().z + 200)
    local inventoryDetails = GetInventoryDetails(hatchery)
    if inventoryDetails.isValid then
        local selectedBird = SelectBird(inventoryDetails, hero)
        print("Selected bird: "..selectedBird)
        local hatchEffect = ParticleManager:CreateParticle("particles/custom/fowl_play.vpcf", PATTACH_CUSTOMORIGIN, hatchery)
        ParticleManager:SetParticleControl(hatchEffect,0,spawnLocation)
        local babyHawk = CreateUnitByName(selectedBird, spawnLocation, true, nil, nil, hero:GetTeamNumber())
    else
        SendErrorMessage(hero:GetPlayerOwnerID(), inventoryDetails.errorMessage)
    end
end

function GetInventoryDetails(hatchery)

    local inventoryDetails = { isValid = false, itemCount = 0, hidesCount = 0, clayItemCount = 0, spiritItemCount = 0, thistleCount = 0, muchroomCount =0, darkRockCount=0, otherItemCount=0, errorMessage="", firstItem ="" }
    for i=0,5 do
        local item = hatchery:GetItemInSlot(i)
        if item then
            item = item:GetName()
            if i==0 then
                inventoryDetails.firstItem = item
            end
            if string.match(item, "hide") then
                inventoryDetails.hidesCount = inventoryDetails.hidesCount + 1
            elseif string.match(item, "clay") then
                inventoryDetails.clayItemCount = inventoryDetails.clayItemCount + 1
            elseif string.match(item, "spirit") then
                inventoryDetails.spiritItemCount = inventoryDetails.spiritItemCount + 1
            elseif string.match(item, "thistle") then
                inventoryDetails.thistleCount = inventoryDetails.thistleCount + 1
            elseif string.match(item, "mushroom") then
                inventoryDetails.mushroomCount = inventoryDetails.mushroomCount + 1
            elseif string.match(item, "rock_dark") then
                inventoryDetails.darkRockCount = inventoryDetails.darkRockCount + 1
            else
                inventoryDetails.otherItemCount = inventoryDetails.otherItemCount + 1
            end
            inventoryDetails.itemCount = inventoryDetails.itemCount + 1
        end
    end
    return   ValidateInventory(inventoryDetails)
end

function ValidateInventory(inventoryDetails)

    if inventoryDetails.itemCount == 0  then
        inventoryDetails.errorMessage = "No items in the hatchery"
    elseif inventoryDetails.itemCount < 6 then
        inventoryDetails.errorMessage = "There are no enough items"
    elseif inventoryDetails.firstItem ~= "item_egg_hawk" then
        inventoryDetails.errorMessage = "The first slot in the hatchery must contain a Hawk Egg"
    else
        inventoryDetails.isValid = true
    end
    return inventoryDetails
end

function SelectBird(inventoryDetails, hero)

    inventoryDetails.selectedBird = ""
    if hero:GetName() == "npc_dota_hero_lycan" then 
        inventoryDetails.selectedBird = "npc_creep_hawk"
    elseif inventoryDetails.clayItemCount >= 3 then
        inventoryDetails.selectedBird = "npc_creep_hawk"
    elseif inventoryDetails.spiritItemCount >= 3 then
        inventoryDetails.selectedBird = "npc_creep_hawk"
    elseif inventoryDetails.spiritItemCount >= 3 then
        inventoryDetails.selectedBird = "npc_creep_hawk"
    elseif inventoryDetails.thistleCount >= 3 then
        inventoryDetails.selectedBird = "npc_creep_hawk"
    elseif inventoryDetails.thistleCount >= 3 then
        inventoryDetails.selectedBird = "npc_creep_hawk"
    elseif inventoryDetails.darkRockCount >= 3 then
        inventoryDetails.selectedBird = "npc_creep_hawk"
    else
        inventoryDetails.selectedBird = "npc_creep_hawk"
    end
    return inventoryDetails.selectedBird;
end
