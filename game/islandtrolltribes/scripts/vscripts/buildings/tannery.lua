function Make( event )
    local tannery = event.caster
    local ability = event.ability
    local item = event.Item

    local requirements = GameRules.Crafting['Tannery'][item]

    print("Making "..item)
    local make
    for recipeName,v in pairs(requirements) do
        local craftingItems
        -- Making Boots/Gloves/Coat only takes 1 single ingredient
        for itemName,num in pairs(v) do
            craftingItems = HasEnoughInInventory(tannery, itemName, num)
        end
        
        if craftingItems then

            -- Clear the inventory items returned by the CanCombine aux
            MakeClear(craftingItems)
            
            -- Create the resulting item
            tannery:AddItem(CreateItem(recipeName, nil, nil))
            
            tannery:EmitSound("General.Combine")

            make = true
            break
        end
    end

    if not make then
        SendErrorMessage(tannery:GetPlayerOwnerID(), "#error_not_enough_hides")
    end
end

function MakeClear( itemList )
    for k,v in pairs(itemList) do
        v:RemoveSelf()
    end
end