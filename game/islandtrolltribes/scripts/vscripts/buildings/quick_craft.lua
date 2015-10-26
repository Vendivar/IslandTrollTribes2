-- Takes dropped items nearby and checks the quick_craft.kv table for a recipe match
function QuickCraft(keys)
    local caster = keys.caster
    local ability = keys.ability
    local range = ability:GetCastRange()
    local buildingName = caster:GetUnitName()

    if not CanTakeMoreItems(caster) then
        SendErrorMessage(caster:GetPlayerOwnerID(), "#error_inventory_full")
        return false
    end

    print("QuickCrafting on "..buildingName)
       
    local recipeTable = GameRules.QuickCraft[buildingName]
    --[[print("List of items the building can craft:")
    for k,v in pairs(recipeTable) do
        print(k)
    end]]

    -- Get all items dropped nearby
    local drops = Entities:FindAllByClassnameWithin("dota_item_drop", caster:GetAbsOrigin(), range)  --get the item in the slot
    
    local match
    -- Check if the items dropped match any recipe
    -- The order that the reciepes are compared might matter in the results, it will be a bit random with this method
    for recipeName,recipeIngredients in pairs(recipeTable) do 
        
        -- If the drop list contains enough of the ingredient items defined in the reciepeTable, it can be crafted and the drops need to be consumed
        local craftingItems = CanCraft(buildingName, recipeName, drops)
        if craftingItems then
            match = recipeName
            -- Create the resulting item
            caster:AddItem(CreateItem(recipeName, nil, nil))

            -- Clear the physical drops returned by the CanCraft aux
            ClearCraftingItems(craftingItems)   

            break  --end the function, only one item per mix
        end
    end

    if match then return
        print("QuickCrafting Created "..match)
    else
        print("No matches for QuickCrafting")
    end
end

-- Returns a list of crafting drops if the itemName can be crafted with the passed drops, false otherwise
function CanCraft( buildingName, itemName, droppedContainers )
    local recipeTable = GameRules.QuickCraft[buildingName]
    local required = recipeTable[itemName]
    
    local craftingItems = {}

    -- Go through the drops and check if there's enough of each ingredient
    for k,drop in pairs(droppedContainers) do
        local item = drop:GetContainedItem()
        local itemName = item:GetAbilityName()

        -- If the item is required for this craft, add if we don't have enough
        if required[itemName] then
            -- At least it will require 1 of the item
            if not craftingItems[itemName] then
                craftingItems[itemName] = {}
                table.insert(craftingItems[itemName], drop)

            -- If it requires more than 1 and we still don't have enough, keep adding
            elseif #craftingItems[itemName] < required[itemName] then
                table.insert(craftingItems[itemName], drop)
            end
        end
    end

    -- Check that the crafting and the required items match, break at first fail
    local ingredients = ""
    for k,v in pairs(required) do
        if type(v)=="number" and (not craftingItems[k] or (#craftingItems[k] < required[k])) then
            --print("Can't craft ",itemName,"missing ",k)
            return false
        elseif type(v)=="number" then
            ingredients = k.."("..v..") "
        end
    end

    print("--------\nPassed the basic requirements to craft "..itemName..": "..ingredients)

    -- Check for alternatives
    local alternatives = required['alt']
    if alternatives then

        print("Item has alternatives:")
        local alts = {}
        for k,v in pairs(alternatives) do
            local altString = ""
            for itemName,num in pairs(v) do
                altString = altString..itemName.."("..num..") "
            end
            alts[k] = altString
        end

        local altCrafting = {}
        local match
        for altNumber,altItems in pairs(alternatives) do
            if not match then
                print("Checking alternative "..altNumber..":", alts[altNumber])

                -- Build an alt table
                for altItemName,number in pairs(altItems) do
                    local dropFound = DropTableContainsItem(droppedContainers, altItemName)
                    if dropFound then
                        print("\tGot "..altItemName)
                        if not altCrafting[altItemName] then
                            altCrafting[altItemName] = {}
                            table.insert(altCrafting[altItemName], dropFound)
                        elseif #altCrafting[altItemName] < number then
                            table.insert(altCrafting[altItemName], dropFound)
                        end
                    end
                end

                -- Check that the crafting and the alt required items match, break at first fail
                match = true
                for k,v in pairs(altItems) do
                    if not altCrafting[k] or (#altCrafting[k] < v) then
                        altCrafting = {} --Clean up the alt table
                        print("\tFailed, not enough "..k)
                        match = false
                        break
                    end
                end
            end
        end
        
        if match then
            print("\tSucceeded an alternative match")
            -- Put all the matched alternatives in the final crafting ingredients and return it 
            for k,itemDropsMatch in pairs(altCrafting) do
                if not craftingItems[k] then
                    craftingItems[k] = {}
                end

                for _,v in pairs(itemDropsMatch) do
                    table.insert(craftingItems[k], v)
                end           
            end

            return craftingItems
        end
    else
        return craftingItems
    end
end

-- TODO: Handle charges
function DropTableContainsItem( droppedContainers, targetItemName )
    for k,drop in pairs(droppedContainers) do
        local item = drop:GetContainedItem()
        local itemName = item:GetAbilityName()

        if itemName == targetItemName then
            return drop
        end
    end
end

function ClearCraftingItems( droppedIngredients )
    print("Craft succesful, clearing items:")
    for dropNames,dropTable in pairs(droppedIngredients) do
        for k,drop in pairs(dropTable) do
            print("\tConsumed",drop, drop:GetClassname(), drop:GetContainedItem():GetAbilityName())
            drop:RemoveSelf()
        end 
    end
end