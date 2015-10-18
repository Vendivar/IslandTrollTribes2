function GunBlowCheckEmpty(keys)
    local caster = keys.caster
    local item = keys.ability

    if item:GetCurrentCharges() <= 0 then
        local emptyGun = CreateItem("item_gun_blow_empty", nil, nil)
        caster:RemoveItem(item)
        caster:AddItem(emptyGun)
    end
end

function ReloadItem(keys)
    local caster = keys.caster
    local ammoItem = keys.ability
    local ammoCharges = ammoItem:GetCurrentCharges()
    local maximumAmmo = keys.MaxStacks
    if maximumAmmo == nil then
        maximumAmmo = 3
    end
    if ammoCharges == 0 then
        ammoCharges = 1 --to account for ammo like bone, with no charges
    end
    local emptyItem = keys.EmptyItem
    local loadedItem = keys.LoadedItem

    --looks for already loaded weapon of the same type first, then looks for empty
    for itemSlot = 0, 5, 1 do
        if caster ~= nil then
            local Item = caster:GetItemInSlot( itemSlot )
            if Item ~= nil and Item:GetName() == loadedItem then
                local itemCharges = Item:GetCurrentCharges() + ammoCharges
                if itemCharges > maximumAmmo then
                    ammoItem:SetCurrentCharges(itemCharges - maximumAmmo)
                    Item:SetCurrentCharges(maximumAmmo)
                else
                    Item:SetCurrentCharges(itemCharges)
                    caster:RemoveItem(ammoItem)
                    return
                end
            end
        end
    end
    for itemSlot = 0, 5, 1 do
        if caster ~= nil then
            local Item = caster:GetItemInSlot( itemSlot )
            if Item~= nil and Item:GetName() == emptyItem then
                local itemCharges = Item:GetCurrentCharges() + ammoCharges
                local newItem = CreateItem(loadedItem, nil, nil)
                if itemCharges > maximumAmmo then
                    ammoItem:SetCurrentCharges(itemCharges - maximumAmmo)
                    newItem:SetCurrentCharges(maximumAmmo)
                    caster:RemoveItem(Item)
                    caster:AddItem(newItem)
                else
                    newItem:SetCurrentCharges(ammoCharges)
                    caster:RemoveItem(Item)
                    caster:AddItem(newItem)
                    caster:RemoveItem(ammoItem)
                    return
                end

            end
        end
    end
end