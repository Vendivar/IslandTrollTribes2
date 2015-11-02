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
       
    local recipeTable = GameRules.Crafting[buildingName]

    -- Get all items dropped nearby
    local drops = Entities:FindAllByClassnameWithin("dota_item_drop", caster:GetAbsOrigin(), range)  --get the item in the slot
    
    local match
    -- Check if the items dropped match any recipe
    -- The order that the recipes are compared might matter in the results, it will be a bit random with this method
    for recipeName,recipeIngredients in pairs(recipeTable) do 

        -- If the drop list contains enough of the ingredient items defined in the recipeTable, it can be crafted and the drops need to be consumed
        local craftingItems = CanCraft(buildingName, recipeName, drops)
        if craftingItems then
            match = recipeName
            -- Create the resulting item
            caster:AddItem(CreateItem(recipeName, nil, nil))

            -- Clear the physical drops returned by the CanCraft aux
            ClearCraftingItems(craftingItems)   

            break  --end the function, only one item per mix
        end
        print("-----")
    end

    if match then return
        print("QuickCrafting Created "..match)
    else
        print("No matches for QuickCrafting")
    end
end

-- Returns a list of crafting drops if the itemName can be crafted with the passed drops, false otherwise
function CanCraft( buildingName, resultName, droppedContainers )
    local recipeTable = GameRules.Crafting[buildingName]
    local required = recipeTable[resultName]
    
    local craftingItems = {}

    -- Go through the drops and check if there's enough of each ingredient
    for k,drop in pairs(droppedContainers) do
        local item = drop:GetContainedItem()
        local itemName = item:GetAbilityName()

        -- If the item is required for this craft, add if we don't have enough
        local alias = GetAlias(itemName)
        if alias ~= "" then
            itemName = alias
        end
        local requiredAmount = required[itemName]
        if requiredAmount then
            --print("Is required ",requiredAmount)
            -- At least it will require 1 of the item
            
            if not craftingItems[itemName] then
                craftingItems[itemName] = {}
                table.insert(craftingItems[itemName], drop)

            -- If it requires more than 1 and we still don't have enough, keep adding
            elseif #craftingItems[itemName] < requiredAmount then
                table.insert(craftingItems[itemName], drop)
            end
        end
    end

    -- Check that the crafting and the required items match, break at first fail
    local ingredients = ""
    for k,v in pairs(required) do
        if type(v)=="number" then
            local requiredAmount = required[k] or required[GetAlias(k)]
            if not craftingItems[k] or (#craftingItems[k] < requiredAmount) then
                for kappa,vim in pairs(craftingItems) do
                    print(kappa,vim)
                end
                return false
            end
            ingredients = k.."("..v..") "
        end
    end

    print("--------\nPassed the requirements to craft "..resultName..": "..ingredients)

    return craftingItems
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