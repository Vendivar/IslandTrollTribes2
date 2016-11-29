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
        if unit:GetUnitName() ~= section then -- Issue #227 fixed here.
            if not (PlayerResource:GetSelectedHeroEntity(playerID).subclass == "herbal_master_telegatherer" and section == "npc_building_mixing_pot") then
              local item_string = GetEnglishTranslation(itemName, "ability") or itemName
              local building_string = GetEnglishTranslation(section) or section
              SendErrorMessage(playerID, "Put items on "..building_string.." to craft "..item_string)
              return
            else
              unit = PlayerResource:GetSelectedHeroEntity(playerID)
              print("Allowing herbmaster to craft mixing pot items")
            end
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
    local usedInts = {}
    for itemName,num in pairs(requirements) do
        local items = HasEnoughInInventory(unit, itemName, num, usedInts)
        local usedInts = items[2]
        if items then
            table.insert(result, {items[1], num})
        else
            return false
        end
    end

    -- All the requirements passed, return the result to combine
    print("Can Combine "..recipeName)
    return result
end

-- HasEnoughInInventory no longer checks the same items that have already been used for the recipe.
-- This fixes a couple of issues, issue #239 among them.

-- Counts stack charges and returns the items involved in
-- If a charge goes over the max required items, the item removal will have to only remove the precise amount of charges instead of the full item
function HasEnoughInInventory( unit, itemName, num, usedInts)
    --local bEnough = false

    local items = {}
    local currentNum = 0
    for i=0,5 do
        local found = false
        for _,v in pairs(usedInts) do
            if v == i then
                found = true
                break
            end
        end

        if not found then
            if currentNum >= num then
                break
            end
            local item = unit:GetItemInSlot(i)
            if item then
                local thisItemName = item:GetAbilityName()
                if thisItemName ~= "item_slot_locked" then
                    if thisItemName == itemName or MatchesAlias(itemName, thisItemName) then
                        if item:GetCurrentCharges() == 0 then
                            currentNum = currentNum + 1
                        else
                            currentNum = currentNum + item:GetCurrentCharges()
                        end
                        table.insert(items, item)
                        table.insert(usedInts, i)
                    end
                end
            end
        end
    end

    if currentNum >= num then
        return {items, usedInts}
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

-- Crafting no longer removes full stacks when only 1 was used.
-- Also removes only the charges needed for the recipe.
-- Fixes the Darkthistles issue #229

function ClearItems( itemList )
    for k,v in pairs(itemList) do
        local items = v[1]
        local num = v[2]
        for _,item in pairs(items) do
            if not item:IsNull() and item:GetCurrentCharges() > 1 then
                for i = 1, num do
                    item:SetCurrentCharges(item:GetCurrentCharges() - 1)
                    num = num - 1
                    if item:GetCurrentCharges() == 0 then
                        UTIL_Remove(item)
                        break
                    end
                end
            else
                UTIL_Remove(item)
            end
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
        ["npc_building_mixing_pot"] = "particles/units/heroes/hero_keeper_of_the_light/keeper_chakra_magic.vpcf",
        ["npc_building_armory"] = "particles/units/heroes/hero_keeper_of_the_light/keeper_chakra_magic.vpcf",
        ["npc_building_tannery"] = "particles/units/heroes/hero_keeper_of_the_light/keeper_chakra_magic.vpcf",
        ["npc_building_workshop"] = "particles/units/heroes/hero_keeper_of_the_light/keeper_chakra_magic.vpcf",
        ["npc_building_hut_witch_doctor"] = "particles/units/heroes/hero_keeper_of_the_light/keeper_chakra_magic.vpcf",
    }

    local unitName = unit:GetUnitName()
    local particleName = combineParticles[unitName]
    if particleName then
        local combineFX = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, unit)
        ParticleManager:SetParticleControl(combineFX, 0, unit:GetAbsOrigin())
        ParticleManager:SetParticleControl(combineFX, 1, unit:GetAbsOrigin())
    end
end

-- Associates a combination sound to each building
function FireCombineParticle( unit )
    local combineSounds = {
        ["npc_building_mixing_pot"] = "craft.mixingpot",
        ["npc_building_armory"] = "craft.armory",
        ["npc_building_tannery"] = "craft.tannery",
        ["npc_building_workshop"] = "craft.workshop",
        ["npc_building_hut_witch_doctor"] = "craft.wdhut",
    }

    local unitName = unit:GetUnitName()
    local soundName = combineSounds[unitName]
    if soundName then
		EmitSoundOn( "freezing", unit )
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
