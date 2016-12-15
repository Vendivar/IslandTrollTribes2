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

        if GetNumItemsInInventory(unit) == 6 then
            local pos = unit:GetAbsOrigin() + RandomVector(200)
            local item = CreateItem(itemName, nil, nil)
            CreateItemOnPositionSync(unit:GetAbsOrigin(), item)
            item:LaunchLoot(false, 200, 0.5, pos)
        else
            -- Create the resulting item
            unit:AddItem(CreateItem(itemName, nil, nil))
        end

        if itemName == "item_thistles_dark" then
            print("Giving back dark rock")
            unit:AddItem(CreateItem("item_rock_dark", nil, nil))
        end

        -- Fixes issue #238
        if itemName == "item_building_kit_fire_basic" then
            print("Giving flint back for creating a fire")
            unit:AddItem(CreateItem("item_flint", nil, nil))
        end

        FireCombineParticle(unit)
		FireCombineSound(unit)
		FireCombineSoundLayer(unit)
		print("firing particle",unit)
        unit:EmitSound("General.Combine")
    else
        if GetNumItemsInInventory(unit) == 6 and section ~= "Recipes" then
            SendErrorMessage(playerID, "#error_inventory_full")
        else
            print("Error, couldn't combine ",itemName)
        end
    end
end

function CanCombine( unit, section, recipeName )
    local requirements = GetRecipeForItem(section, recipeName)

    local result
    local usedInts
    local total_failure
    for _, recipe in pairs(requirements) do
        result = {}
        usedInts = {}
        local failure = false
        total_failure = false
        for itemName,num in pairs(recipe) do
            if not failure then
                local items = HasEnoughInInventory(unit, itemName, num, usedInts)
                local usedInts = items[2]
                if items[1] then
                    table.insert(result, {items[1], num})
                else
                    if unit.itempens then
                        -- We have a chance!
                        local res = CheckItempens(unit, num - #items[3], itemName)
                        if res then
                            table.insert(result, {items[3], num, res})
                        else
                            failure = true
                        end
                    else
                        failure = true
                    end
                end
            else
                total_failure = true
            end
        end
    end

    if total_failure then return false end

    -- All the requirements passed, return the result to combine
    print("Can Combine "..recipeName)
    return result
end

function CheckItempens(unit, num, itemName)
    local current = 0
    local itempens = {}
    local used = {}
    for i, itempen in pairs(unit.itempens) do
        if itempen:IsNull() or not IsValidEntity(itempen) then -- Was it destroyed?
            table.remove(itempen, i)
        else
            -- Need to check if it's an alias.
            if string.match(itemName, "any_") then
                for ind = 1, num do
                    local name = GetAliasForPen(itemName, itempen.items, used)
                    if itempen.items[name] and itempen.items[name].count > 0 then
                        current = current + 1
                        table.insert(itempens, {itempen, name, 1})

                        if used[name] then used[name] = used[name] + 1
                        else used[name] = 1 end

                        if current >= num then
                            return {itempens, itemName}
                        end
                    end
                end
            else
                if itempen.items[itemName] and itempen.items[itemName].count > 0 then
                    current = current + itempen.items[itemName].count
                    table.insert(itempens, {itempen})
                    if current >= num then
                        return {itempens, itemName}
                    end
                end
            end
        end
    end

    return false
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
        return {false, usedInts, items}
    end
end

-- Returns an appropriate name for itempen usage.
function GetAliasForPen(itemName, itempen, used)
    if string.match(itemName, "any_") then
        local aliasTable = GameRules.Crafting['Alias'][itemName]

        PrintTable(used)
        for k,v in pairs(aliasTable) do
            if itempen[k] and itempen[k].count > 0 then
                if used[k] and itempen[k].count > used[k] then
                    return k
                elseif not used[k] then
                    return k
                end
            end
        end

        -- No match, return the alias for automatic failure.
        return itemName
    else
        return itemName
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
        for _,item in pairs(items) do -- Remove the items in inventory
            if not item:IsNull() and item:GetCurrentCharges() > 1 then
                local len = num
                for i = 1, len do
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

        -- Still missing? Check itempens
        if num > 0 and v[3] then
            ClearItemsFromPen(v[3][1], v[3][2], num)
        end
    end
end

function ClearItemsFromPen(pens, itemName, num)
    local name = itemName
    for k,pen in pairs(pens) do
        local len = num
        if pen[2] then
            name = pen[2]
            len = pen[3]
        end
        pen = pen[1]
        local pen_items = pen.items[name].items
        local count = pen.items[name].count
        for i = 1, len do
            if i <= count then
                if not pen_items[i]:IsNull() then
                    UTIL_Remove(pen_items[i]:GetContainedItem())
                    UTIL_Remove(pen_items[i])
                    num = num - 1
                end
            else
                break
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
        ["npc_building_mixing_pot"] = "particles/custom/craft_mixing_pot.vpcf",
        ["npc_building_armory"] = "particles/custom/craft_armory.vpcf",
        ["npc_building_tannery"] = "particles/custom/craft_tannery.vpcf",
        ["npc_building_workshop"] = "particles/custom/craft_workshop.vpcf",
        ["npc_building_hut_witch_doctor"] = "particles/custom/craft_wdhut.vpcf"
    }

    local unitName = unit:GetUnitName()
    local particleName = combineParticles[unitName]
    if particleName then
        local combineFX = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, unit)
        ParticleManager:SetParticleControl(combineFX, 0, unit:GetAbsOrigin())
        ParticleManager:SetParticleControl(combineFX, 1, unit:GetAbsOrigin())
        ParticleManager:SetParticleControl(combineFX, 2, unit:GetAbsOrigin())
        ParticleManager:SetParticleControl(combineFX, 3, unit:GetAbsOrigin())
        ParticleManager:SetParticleControl(combineFX, 4, unit:GetAbsOrigin())
        ParticleManager:SetParticleControl(combineFX, 5, unit:GetAbsOrigin())
    end
end

-- Associates a combination sound to each building
function FireCombineSound( unit )
    local combineSounds = {
        ["npc_building_mixing_pot"] = "craft.mixing",
        ["npc_building_armory"] = "craft.armory",
        ["npc_building_tannery"] = "craft.tannery",
        ["npc_building_workshop"] = "craft.workshop",
        ["npc_building_hut_witch_doctor"] = "craft.wdhut"
    }

    local unitName = unit:GetUnitName()
    local soundName = combineSounds[unitName]
    if soundName then
		EmitSoundOnLocationWithCaster (unit:GetAbsOrigin(), soundName, unit)
    end
end


--Extra Layer Sounds
function FireCombineSoundLayer( unit )
    local combineSoundsL = {
        ["npc_building_mixing_pot"] = "craft.mixingl",
        ["npc_building_armory"] = "craft.armoryl",
        ["npc_building_tannery"] = "craft.tanneryl",
        ["npc_building_workshop"] = "craft.workshopl"
    }

    local unitName = unit:GetUnitName()
    local soundName = combineSoundsL[unitName]
    if soundName then
		EmitSoundOnLocationWithCaster (unit:GetAbsOrigin(), soundName, unit)
    end
end

function GetRecipeForItem(section, itemName)
    local unitTable = GameRules.Crafting[section]
    -- Recipes are in 1,2,3... order
    local recipes = {}
    for _,recipe in pairs(unitTable) do
        for recipeName,ingredients in pairs(recipe) do
            if recipeName==itemName then
                table.insert(recipes, ingredients)
            end
        end
    end
    return recipes
end
