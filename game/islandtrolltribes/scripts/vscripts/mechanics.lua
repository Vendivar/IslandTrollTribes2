------------------------------------------------
--                  Messages                  --
------------------------------------------------

function SendErrorMessage( pID, string )
    Notifications:ClearBottom(pID)
    Notifications:ClearBottomFromAll()
    Notifications:Bottom(pID, {text=string, style={color='#E62020'}, duration=2})
    EmitSoundOnClient("General.Cancel", PlayerResource:GetPlayer(pID))
end


------------------------------------------------
--            Global item applier             --
------------------------------------------------
function ApplyModifier( unit, modifier_name )
    GameRules.APPLIER:ApplyDataDrivenModifier(unit, unit, modifier_name, {})
end

------------------------------------------------
--               Class functions              --
------------------------------------------------

-- Unit Label for now
function GetHeroClass( hero )
    return GameRules.ClassInfo['HeroClassNames'][hero:GetUnitName()]
end

function GetSubClass( hero )
    return hero.subclass or 'none'
end

function HasSubClass( hero )
    return GetSubClass(hero) ~= 'none'
end

------------------------------------------------
--              Ability functions             --
------------------------------------------------

function SetAbilityVisibility(unit, abilityName, visibility)
    local ability = unit:FindAbilityByName(abilityName)
    local hidden = (visibility == false)
    if ability ~= nil and unit ~= nil then
        ability:SetHidden(hidden)
    end
end

function TeachAbility( unit, ability_name, level )
    if not level then level = 1 end
    if GameRules.AbilityKV[ability_name] then
        unit:AddAbility(ability_name)
        local ability = unit:FindAbilityByName(ability_name)
        if ability then
            ability:SetLevel(tonumber(level))
            return ability
        end
    else
        print("ERROR: ability "..ability_name.." is not defined")
        return nil
    end
end

function PrintAbilities( unit )
    print("List of Abilities in "..unit:GetUnitName())
    for i=0,15 do
        local ability = unit:GetAbilityByIndex(i)
        if ability then
            local output = i.." - "..ability:GetAbilityName()
            if ability:IsHidden() then output = output.." (Hidden)" end
            print(output)
        end
    end
end

function ClearAbilities( unit )
    for i=0,15 do
        local ability = unit:GetAbilityByIndex(i)
        if ability then
            unit:RemoveAbility(ability:GetAbilityName())
        end
    end
end

------------------------------------------------
--                Item functions              --
------------------------------------------------

-- This attempts to pick up items from any range and resolves custom stacking
function PickupItem( unit, drop )
    local item = drop:GetContainedItem()
    if not item then
        print("INVALID ITEM PICKUP, ABORT")
        return
    end
    local itemName = item:GetAbilityName()

    -- Raw meat uses modifier stacks instead of inventory slots
    if itemName == "item_meat_raw" then
        local meatStacks = unit:GetModifierStackCount("modifier_meat_passive", nil)
        if meatStacks < 10 then
            unit:SetModifierStackCount("modifier_meat_passive", nil, meatStacks + 1)
            UTIL_Remove(drop)
            return true
        else
            SendErrorMessage(unit:GetPlayerOwnerID(), "#error_cant_carry_more_raw_meat")
            return false
        end
    end

    -- If there is 1 slot available, simply pickup the item and check for merges
    if CanTakeMoreItems(unit) then
        drop:SetAbsOrigin(unit:GetAbsOrigin())
        unit:PickupDroppedItem(drop)
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
                UTIL_Remove(drop)

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
        unit:DropItemAtPositionImmediate(item, target:GetAbsOrigin())
        Timers:CreateTimer(function()
            PickupItem( target, item:GetContainer() )
        end)
    else
        return false
    end
end

-- Adds an item by name to the units inventory taking custom max stack charges into consideration
function GiveItemStack( unit, itemName )
    local newItem = CreateItem(itemName, nil, nil)

    if CanTakeMoreItems(unit) then
        unit:AddItem(newItem)
        --print("Given "..itemName.." to "..unit:GetUnitName())
        ResolveInventoryMerge(unit, newItem)
        return newItem
    else
        local itemToStack = CanTakeMoreStacksOfItem(unit, newItem)
        if itemToStack then

            -- Add the charges
            local currentCharges = itemToStack:GetCurrentCharges()
            itemToStack:SetCurrentCharges(currentCharges + newItem:GetCurrentCharges())
            --print("Given "..itemName.." to "..unit:GetUnitName().." through stacks")
            UTIL_Remove(newItem)
            return itemToStack
        end
    end

    --print("Couldn't add "..itemName.." - Inventory is full and it wont take more stacks")
    UTIL_Remove(newItem)
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
            Timers:CreateTimer(function()
                UTIL_Remove(item)
            end)

        -- Otherwise add up to maxCharges and keep both items
        else
            --print(" Add max charges and keep both items")

            local transfer_charges = maxStacks - inventoryItemCharges
            itemToStack:SetCurrentCharges(maxStacks)
            item:SetCurrentCharges(currentItemCharges - transfer_charges)
        end
    end
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

--Compares two tables to see if they have the same values
function CompareTables(table1, table2)
    if type(table1) ~= "table" or type(table2) ~= "table" then
        return false
    end

    for key,value in pairs(table1) do
        if table2[key] == nil then
            return false
        elseif table2[key] ~= table1[key] then
            return false
        end
    end

    for key,value in pairs(table2) do
        print(key, table2[key], table1[key])
        if table1[key] == nil then
            return false
        elseif table1[key] ~= table2[key] then
            return false
        end
    end
    
    return true
end

function compareHelper(a,b)
    return a[2] > b[2]
end

------------------------------------------------

--general "ping minimap" function
function PingMap(playerID,pos,r,g,b)
    --(PlayerID, position(vector), R, G, B, SizeofDot, Duration)
    GameRules:AddMinimapDebugPoint(5,pos, r, g, b, 500, 6)
    print("x:", pos.x)
    print("y:", pos.y)
    print("z:", pos.z)
    --NEWEST PING ALWAYS CLEARS LAST PING, ONLY ONE PING AT A TIME, THIS FUNCTION SUCKS DICK BUT IT'S ALL WE HAVE TO WORK WITH
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
    for i=0,15 do
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

------------------------------------------------
--                 Unit Checks                --
------------------------------------------------

function IsCustomBuilding( unit )
    return unit:HasAbility("ability_building")
end

-- Shortcut for all unit logic
function IsValidAlive( unit )
    return IsValidEntity(unit) and unit:IsAlive()
end

function IsFlyingUnit( unit )
    return unit:HasFlyMovementCapability()
end

------------------------------------------------
--               Building Helper              --
-- Should be made internal to the library...  --
------------------------------------------------

-- Returns Int
function GetGoldCost( unit )
    if unit and IsValidEntity(unit) then
        if unit.GoldCost then
            return unit.GoldCost
        end
    end
    return 0
end

-- Returns float
function GetBuildTime( unit )
    if unit and IsValidEntity(unit) then
        if unit.BuildTime then
            return unit.BuildTime
        end
    end
    return 0
end

function GetCollisionSize( unit )
    if unit and IsValidEntity(unit) then
        if GameRules.UnitKV[unit:GetUnitName()]["CollisionSize"] and GameRules.UnitKV[unit:GetUnitName()]["CollisionSize"] then
            return GameRules.UnitKV[unit:GetUnitName()]["CollisionSize"]
        end
    end
    return 0
end

-- Returns bool
function PlayerHasEnoughGold( player, gold_cost )
    local hero = player:GetAssignedHero()
    local pID = hero:GetPlayerID()
    local gold = hero:GetGold()

    if gold < gold_cost then
        SendErrorMessage(pID, "#error_not_enough_gold")
        return false
    else
        return true
    end
end

-- Builders require the "builder" label in its unit definition
function IsBuilder( unit )
    if not IsValidEntity(unit) then
        return
    end
    return (unit:GetUnitLabel() == "builder")
end

-- A BuildingHelper ability is identified by the "Building" key.
function IsBuildingAbility( ability )
    if not IsValidEntity(ability) then
        return
    end

    local ability_name = ability:GetAbilityName()
    local ability_table = GameRules.AbilityKV[ability_name]
    if ability_table and ability_table["Building"] then
        return true
    else
        ability_table = GameRules.ItemKV[ability_name]
        if ability_table and ability_table["Building"] then
            return true
        end
    end

    return false
end

function AddUnitToSelection( unit )
    local player = unit:GetPlayerOwner()
    CustomGameEventManager:Send_ServerToPlayer(player, "add_to_selection", { ent_index = unit:GetEntityIndex() })
end

function RemoveUnitFromSelection( unit )
    local player = unit:GetPlayerOwner()
    local ent_index = unit:GetEntityIndex()
    CustomGameEventManager:Send_ServerToPlayer(player, "remove_from_selection", { ent_index = unit:GetEntityIndex() })
end

function GetSelectedEntities( playerID )
    return GameRules.SELECTED_UNITS[playerID]
end

function IsCurrentlySelected( unit )
    local entIndex = unit:GetEntityIndex()
    local playerID = unit:GetPlayerOwnerID()
    local selectedEntities = GetSelectedEntities( playerID )
    for _,v in pairs(selectedEntities) do
        if v==entIndex then
            return true
        end
    end
    return false
end

-- Force-check the game event
function UpdateSelectedEntities()
    FireGameEvent("dota_player_update_selected_unit", {})
end

function GetMainSelectedEntity( playerID )
    if GameRules.SELECTED_UNITS[playerID]["0"] then
        return EntIndexToHScript(GameRules.SELECTED_UNITS[playerID]["0"])
    end
    return nil
end

-- ToggleAbility On only if its turned Off
function ToggleOn( ability )
    if ability:GetToggleState() == false then
        ability:ToggleAbility()
    end
end

-- ToggleAbility Off only if its turned On
function ToggleOff( ability )
    if ability:GetToggleState() == true then
        ability:ToggleAbility()
    end
end

-- Goes through every ability and item, checking for any ability being channelled
function IsChanneling ( hero )
    
    for abilitySlot=0,15 do
        local ability = hero:GetAbilityByIndex(abilitySlot)
        if ability ~= nil and ability:IsChanneling() then 
            return true
        end
    end

    for itemSlot=0,5 do
        local item = hero:GetItemInSlot(itemSlot)
        if item ~= nil and item:IsChanneling() then
            return true
        end
    end

    return false
end

----------------------------------------------