-- Init nettable for crafting UI
function LoadCraftingTable()
    for k,v in pairs(GameRules.Crafting) do
        CustomNetTables:SetTableValue("crafting", k, v)
    end

    CustomGameEventManager:RegisterListener( "craft_item", Dynamic_Wrap( ITT, "CraftItem" ) )
end

-- Recieve a craft_item event
function ITT:CraftItem(event)
    local playerID = event.PlayerID
    local itemName = event.itemname
    local section = event.section
    local entity = event.entity
    local unit
    print("Attempting to craft ",itemName," at ",section)
    if section == "Recipes" then
        unit = PlayerResource:GetSelectedHeroEntity(playerID)
    else
        unit = EntIndexToHScript(entity)
        if unit:GetUnitName() ~= section then
            local item_string = GetEnglishTranslation(itemName, "ability") or itemName
            local building_string = GetEnglishTranslation(section) or section
            SendErrorMessage(playerID, "Put items on "..building_string.." to craft "..item_string)
            return
        end

        -- Disallow crafting on buildings under construction
        if not unit.state == "complete" then
            SendErrorMessage(playerID, "Building still under construction!")
        end
    end

    local craftingItems = CanCombine(unit, section, itemName)
    if craftingItems then
        -- Clear the inventory items returned by the CanCombine aux
        ClearItems(craftingItems)

        -- Create the resulting item
        unit:AddItem(CreateItem(itemName, nil, nil))

        -- Fixes issue #238
        if itemName == "item_building_kit_fire_basic" then
            print("Giving flint back for creating a fire")
            unit:AddItem(CreateItem("item_flint", nil, nil))
        end

        FireCombineParticle(unit)

        unit:EmitSound("General.Combine")
    else
        print("Error, couldn't combine ",itemName)
    end
end

function CanCombine( unit, section, recipeName )
    local requirements = GetRecipeForItem(section, recipeName)

    local result = {}
    for itemName,num in pairs(requirements) do
        local items = HasEnoughInInventory(unit, itemName, num)
        if items then
            table.insert(result, items)
        else
            return false
        end
    end

    -- All the requirements passed, return the result to combine
    print("Can Combine "..recipeName)
    return result
end

-- Counts stack charges and returns the items involved in
-- If a charge goes over the max required items, the item removal will have to only remove the precise amount of charges instead of the full item
function HasEnoughInInventory( unit, itemName, num )
    local bEnough = false

    local items = {}
    local currentNum = 0
    for i=0,5 do
        if currentNum >= num then
            break
        end
        local item = unit:GetItemInSlot(i)
        if item then
            local thisItemName = item:GetAbilityName()
            if thisItemName ~= "item_slot_locked" then
                if thisItemName == itemName then
                    if item:GetCurrentCharges() == 0 then
                        currentNum = currentNum + 1
                    else
                        currentNum = currentNum + item:GetCurrentCharges()
                    end
                    table.insert(items, item)

                elseif MatchesAlias(itemName, thisItemName) then
                    currentNum = currentNum + 1
                    table.insert(items, item)
                end
            end
        end
    end

    if currentNum >= num then
        return items
    else
        return false
    end
end

-- Returns whether the itemName can be matched to an specific alias
function MatchesAlias( aliasName, itemName )
    if string.match(aliasName, "any_") then
        local aliasTable = GameRules.Crafting['Alias'][aliasName]

        for k,v in pairs(aliasTable) do
            if k==itemName then
                return true
            end
        end
    end
    return false
end

-- Returns alias or "" if couldn't find a match
function GetAlias( itemName )
    local aliases = GameRules.Crafting['Alias']
    for aliasName,aliasTable in pairs(aliases) do
        for k,v in pairs(aliasTable) do
            if k==itemName then
                return aliasName
            end
        end
    end
    return ""
end

-- TODO: Handle stacks, never delete a full item if we pick more than the required count
function ClearItems( itemList )
    for k,v in pairs(itemList) do
        for kk,vv in pairs(v) do
            UTIL_Remove(vv)
        end
    end
end

function GetRandomAliasFor(aliasName)
    local aliasTable = GameRules.Crafting['Alias'][aliasName]
    local random = RandomInt(1, #aliasTable)
    local count = 1
    for k,v in pairs(aliasTable) do
        if count == random then
            return k
        else
            count = count + 1
        end
    end
end

-- Associates a particle to each building
function FireCombineParticle( unit )
    local combineParticles = {
        ["npc_building_mix_pot"] = "particles/units/heroes/hero_keeper_of_the_light/keeper_chakra_magic.vpcf",
    }

    local unitName = unit:GetUnitName()
    local particleName = combineParticles[unitName]
    if particleName then
        local combineFX = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, unit)
        ParticleManager:SetParticleControl(combineFX, 0, unit:GetAbsOrigin())
        ParticleManager:SetParticleControl(combineFX, 1, unit:GetAbsOrigin())
    end
end

function GetRecipeForItem(section, itemName)
    local unitTable = GameRules.Crafting[section]
    -- Recipes are in 1,2,3... order
    for _,recipe in pairs(unitTable) do
        for recipeName,ingredients in pairs(recipe) do
            if recipeName==itemName then
                return ingredients
            end
        end
    end
end
