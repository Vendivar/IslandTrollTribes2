------------------------------------------------
--                Item functions              --
------------------------------------------------

function PickupRawMeat(unit, drop)
    local meatStacks = unit:GetModifierStackCount("modifier_meat_passive", nil)
    if meatStacks < 10 then
        unit:SetModifierStackCount("modifier_meat_passive", nil, meatStacks + 1)
        UTIL_Remove(drop)
        return true
    end
end

-- This attempts to pick up items from any range and resolves custom stacking
function PickupItem( unit, drop )
    local item = drop:GetContainedItem()
    if not item then
        print("INVALID ITEM PICKUP, ABORT")
        return
    end
    local itemName = item:GetAbilityName()

    -- Raw meat uses modifier stacks instead of inventory slots
    if itemName == "item_meat_raw" and not IsCustomBuilding(unit) then
        local meatStacks = unit:GetModifierStackCount("modifier_meat_passive", nil)
        if meatStacks < 8 then
            unit:SetModifierStackCount("modifier_meat_passive", nil, meatStacks + 1)
            UTIL_Remove(drop)
            return true
        else
            SendErrorMessage(unit:GetPlayerOwnerID(), "#error_cant_carry_more_raw_meat")
            return true
        end
    end

    -- If there is 1 slot available, simply pickup the item and check for merges
    if CanTakeMoreItems(unit) then
        drop:SetAbsOrigin(unit:GetAbsOrigin())
        unit:PickupDroppedItem(drop)
        if drop.pingStaticParticle then
            ParticleManager:DestroyParticle(drop.pingStaticParticle, true)
            drop.pingStaticParticle = nil
        end
        --print("Picking up "..item:GetAbilityName())
        ResolveInventoryMerge(unit, item)
        return true
    else
        local itemToStack = CanTakeMoreStacksOfItem(unit, item)
        if itemToStack then
            local maxStacks = GameRules.ItemKV[itemName]["MaxStacks"]
            --print("Got another of this item to stack with, merging")

            -- Reduce the stacks of the item on the ground and increase the item to stack
            local inventoryItemCharges = itemToStack:GetCurrentCharges()
            local currentItemCharges = item:GetCurrentCharges()

            -- If it can be merged completely, add the charges and remove the drop
            if inventoryItemCharges+currentItemCharges <= maxStacks then

                itemToStack:SetCurrentCharges(inventoryItemCharges+currentItemCharges)
                Timers:CreateTimer(function() 
                    if drop.pingStaticParticle then
                        ParticleManager:DestroyParticle(drop.pingStaticParticle, true)
                        drop.pingStaticParticle = nil
                    end

                    UTIL_Remove(drop)
                end)

            -- Otherwise add up to maxCharges and keep both items
            else
                local transfer_charges = maxStacks - inventoryItemCharges
                itemToStack:SetCurrentCharges(maxStacks)
                item:SetCurrentCharges(currentItemCharges - transfer_charges)
            end
            return true
        else
            return false
        end
    end
end

-- This handles transfering an item handle from a unit to a target
function TransferItem( unit, target, item )
    if CanTakeItem(target) then
        unit:DropItemAtPositionImmediate(item, unit:GetAbsOrigin())

        item:LaunchLoot(false, 200, 0.75, target:GetAbsOrigin())

        Timers:CreateTimer(0.75, function()
            local pickedUp = PickupItem( target, item:GetContainer() )
        end)
    else
        return false
    end
end

function DropItemAndSpendCharge(unit, item, point)
    if (item:GetCurrentCharges() > 1) then
        item:SetCurrentCharges(item:GetCurrentCharges() - 1)
        local clonedItem = CreateItem(item:GetName(), nil, nil)
        CreateItemOnPositionSync(unit:GetAbsOrigin(), clonedItem)
        DropLaunch(unit, clonedItem, 0.5, point)
    else
        unit:DropItemAtPositionImmediate(item, unit:GetAbsOrigin())
        DropLaunch(unit, item, 0.5, point)
    end
end

-- Adds an item by name to the units inventory taking custom max stack charges into consideration
function GiveItemStack( unit, itemName )
    local newItem = CreateItem(itemName, nil, nil)

    local result
    if CanTakeMoreItems(unit) then
        unit:AddItem(newItem)
        --print("Given "..itemName.." to "..unit:GetUnitName())
        ResolveInventoryMerge(unit, newItem)
        result = newItem
    else
        local itemToStack = CanTakeMoreStacksOfItem(unit, newItem)
        if itemToStack then

            -- Add the charges
            local currentCharges = itemToStack:GetCurrentCharges()
            itemToStack:SetCurrentCharges(currentCharges + newItem:GetCurrentCharges())
            --print("Given "..itemName.." to "..unit:GetUnitName().." through stacks")
            Timers:CreateTimer(function()
                UTIL_Remove(newItem)
            end)
            result = itemToStack
        end
    end

    -- If the unit is replicating its inventory on a container, add it there too
    Timers:CreateTimer(function()
        if unit.replicatedContainer then
            local container = unit.container

            -- Set the correct charges
            for i=0,5 do
                local item = unit:GetItemInSlot(i)
                if item then
                    local containerItem = container:GetItemInSlot(i+1)
                    local charges = item:GetCurrentCharges() or 0
                    if not containerItem then
                        container:AddItem(CreateItem(itemName, nil, nil), i)
                    else
                        containerItem:SetCurrentCharges(charges)
                    end
                end
            end
        end
    end)

    if not result then
        --print("Couldn't add "..itemName.." - Inventory is full and it wont take more stacks")
        UTIL_Remove(newItem)
    end

    return result
end

function GetNumItemsInInventory( unit )
    local count = 0
    for i=0,5 do
        local item = unit:GetItemInSlot(i)
        if item then count = count + 1 end
    end
    return count
end

function CanTakeItem( unit, item )
    return (CanTakeMoreItems(unit) or CanTakeMoreStacksOfItem(unit, item))
end

function CanTakeMoreItems( unit )
    return (GetNumItemsInInventory(unit) < 6)
end

function CanTakeMoreStacksOfItem( unit, item )

    -- If the item is stackable with the default dota system, it will be combined and removed by default, making it invalid
    if not IsValidEntity(item) then return end

    -- If the item can be stacked
    local itemName = item:GetAbilityName()
    local maxStacks = GameRules.ItemKV[itemName]["MaxStacks"]
    if maxStacks then
        local currentCharges = item:GetCurrentCharges()
        --print(itemName.." can be stacked up to "..maxStacks.." times, currently at "..currentCharges.." charges")
        
        -- Check if there's another item to stack with
        for itemSlot = 0,5 do
            local itemInSlot = unit:GetItemInSlot( itemSlot )
            if itemInSlot then
                if itemInSlot ~= item and itemInSlot:GetAbilityName() == itemName and itemInSlot:GetCurrentCharges() < maxStacks then
                    --print(" Unit can take more stacks of "..itemName)
                    return itemInSlot --Return the item handle to pass the stacks to
                end
            end
        end
    end
    --print(" No item to stack "..itemName.." on")
    return false
end

-- The unit just picked an item and we want to see if it can be stacked to another item in inventory
function ResolveInventoryMerge( unit, item )
    --print("Resolving Inventory Merge")

    local itemToStack = CanTakeMoreStacksOfItem(unit, item)

    if itemToStack then
        --print(" Got an item to stack with")
        local itemName = item:GetAbilityName() 
        local maxStacks = GameRules.ItemKV[itemName]["MaxStacks"]

        -- Reduce the stacks of the new item and increase the item to stack
        local inventoryItemCharges = itemToStack:GetCurrentCharges()
        local currentItemCharges = item:GetCurrentCharges()

        -- If it can be merged completely, add the charges and remove the drop
        if inventoryItemCharges+currentItemCharges <= maxStacks then

            --print(" It can be merged completely")

            itemToStack:SetCurrentCharges(inventoryItemCharges+currentItemCharges)
            unit:DropItemAtPositionImmediate(item, unit:GetAbsOrigin())
            item:GetContainer():RemoveSelf()

        -- Otherwise add up to maxCharges and keep both items
        else
            --print(" Add max charges and keep both items")

            local transfer_charges = maxStacks - inventoryItemCharges
            itemToStack:SetCurrentCharges(maxStacks)
            item:SetCurrentCharges(currentItemCharges - transfer_charges)
        end
    end
end

-- Launches an item towards a point, adjusted to never land on top of a tree
function DropLaunch(unit, item, duration, point)
    local trees = GridNav:GetAllTreesAroundPoint(point, 100, false)
    if #trees > 0 then
        local origin = unit:GetAbsOrigin()
        local fv = unit:GetForwardVector()

        -- Get points from tree towards the hero
        for i=64,320,64 do
            local testPosition = point + (origin - point):Normalized() * i
            trees = GridNav:GetAllTreesAroundPoint(testPosition, 100, false)
            if #trees == 0 then
                point = testPosition
                break
            end
        end
    end

    item:LaunchLoot(false, 200, duration, point)
end

-- Returns how many items of a certain slot type are there in the units inventory
function GetNumItemsOfSlot( unit, slotName )
    local count = 0
    for i=0,5 do
        local item = unit:GetItemInSlot(i)
        if item then
            local itemName = item:GetAbilityName()
            local itemSlotRestriction = GameRules.ItemInfo['ItemSlots'][itemName]
            if itemSlotRestriction and itemSlotRestriction == slotName then
                count = count + 1
            end
        end
    end
    return count
end

-- Removes the first item by name if found on the unit. Returns true if removed
function RemoveItemByName( unit, item_name )
    for i=0,15 do
        local item = unit:GetItemInSlot(i)
        if item and item:GetAbilityName() == item_name then
            item:RemoveSelf()
            return true
        end
    end
    return false
end

-- Takes all items and puts them 1 slot back
function ReorderItems( caster )
    local slots = {}
    for itemSlot = 0, 5, 1 do

        -- Handle the case in which the caster is removed
        local item
        if IsValidEntity(caster) then
            item = caster:GetItemInSlot( itemSlot )
        end

        if item ~= nil then
            table.insert(slots, itemSlot)
        end
    end

    for k,itemSlot in pairs(slots) do
        caster:SwapItems(itemSlot,k-1)
    end
end

------------------------------------------------
--               Layout manipulation          --
------------------------------------------------

function SetAbilityLayout( unit, layout_size )
    unit:RemoveModifierByName("modifier_ability_layout4")
    unit:RemoveModifierByName("modifier_ability_layout5")
    unit:RemoveModifierByName("modifier_ability_layout6")
    
    ApplyModifier(unit, "modifier_ability_layout"..layout_size)
end

function AdjustAbilityLayout( unit )
    local required_layout_size = GetVisibleAbilityCount(unit)

    if required_layout_size > 6 then
        required_layout_size = 6
    elseif required_layout_size < 4 then
        required_layout_size = 4
    end

    SetAbilityLayout(unit, required_layout_size)
end

function GetVisibleAbilityCount( unit )
    local count = 0
    for i=0,16 do
        local ability = unit:GetAbilityByIndex(i)
        if ability and not ability:IsHidden() and (ability:GetAbilityName() ~= "attribute_bonus") then
            count = count + 1
            ability:MarkAbilityButtonDirty()
        end
    end
    return count
end

function FindAbilityWithName( unit, ability_name_section )
    for i=0,15 do
        local ability = unit:GetAbilityByIndex(i)
        if ability and string.match(ability:GetAbilityName(), ability_name_section) then
            return ability
        end
    end
end

function GetAbilityOnVisibleSlot( unit, slot )
    local visible_slot = 0
    for i=0,15 do
        local ability = unit:GetAbilityByIndex(i)
        if ability and not ability:IsHidden() then
            visible_slot = visible_slot + 1
            if visible_slot == slot then
                return ability
            end
        end
    end
end