function GatherItemThink(keys)
    local caster = keys.caster
    local ability = keys.ability
    caster.wander_wait_time = GameRules:GetGameTime() + 20 --Disabling the normal wandering
    local itemDrop = SelectItemToPick(caster, 50)
    if IsInventoryFull(caster) then
        caster:Stop()
        caster:RemoveModifierByName("modifier_itemgather_mode")
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_itemstore_mode", {})
    elseif itemDrop and caster:IsIdle() then
        local pickOrder = {
            UnitIndex = caster:GetEntityIndex(),
            OrderType = DOTA_UNIT_ORDER_PICKUP_ITEM,
            TargetIndex = itemDrop:GetEntityIndex(),
            Queue = 0
        }
        ExecuteOrderFromTable(pickOrder)
    end
end

function IsInventoryFull(unit)
    local itemCount = 0
    for i=0,5 do
        local item = unit:GetItemInSlot(i)
        if item then
            itemCount =  itemCount + 1
        end
    end
    if itemCount >= 6 then
        return true
    end
    return false
end

function SelectItemToPick(caster, range)
    local itemDrops = Entities:FindAllByClassnameWithin("dota_item_drop", caster:GetAbsOrigin(),range)
    while #itemDrops <= 0 do
        range =  range + 50
        itemDrops = Entities:FindAllByClassnameWithin("dota_item_drop", caster:GetAbsOrigin(),range)
    end
    for _,itemDrop in pairs(itemDrops) do
        local nearByHatchery = FindHatchery(caster, itemDrop:GetAbsOrigin(), 400)
        if not nearByHatchery then
            return itemDrop
        end
    end
    return SelectItemToPick(caster, range + 50)
end

function ToggleOffGathering(keys)
    local caster = keys.caster
    caster.hatchery = nil
    caster:Stop()
    caster:RemoveModifierByName("modifier_itemgather_mode")
    caster:RemoveModifierByName("modifier_itemstore_mode")
    caster:MoveToNPC(caster:GetOwner())
end

function StoreItemThink(keys)
    local caster = keys.caster
    local ability = keys.ability
    local hatcherySearchRange = 10000
    if not caster.hatchery then
        caster.wander_wait_time = GameRules:GetGameTime() + 20 --Disabling the normal wandering
        local hatchery = FindHatchery(caster, caster:GetAbsOrigin(), hatcherySearchRange)
        if hatchery then
            caster.hatchery = hatchery
            caster:MoveToNPC(hatchery)
            Timers:CreateTimer(TransferItemThink,keys)
        else
            SendErrorMessage(caster:GetPlayerOwnerID(),"#hatchery_is_not_found")
            ToggleOff(ability)
        end
    end
end

function TransferItemThink(keys)
    local caster = keys.caster
    local hatchery= caster.hatchery
    local distance = (caster:GetAbsOrigin() - hatchery:GetAbsOrigin()):Length2D()
    if distance <= ITEM_TRANSFER_RANGE then
        TransferItems(keys)
        caster:MoveToPosition(hatchery:GetAbsOrigin() + RandomVector(RandomFloat(300,550)))
        RestartGathering(keys)
        return nil
    end
    return 0.5
end

function TransferItems(keys)
    local caster = keys.caster
    local hatchery= caster.hatchery
    local ability = keys.ability
    for i=0,5 do
        local item = caster:GetItemInSlot(i)
        if item and item:GetName() ~= "item_slot_locked" then
            local clonedItem = CreateItem(item:GetName(), nil, nil)
            CreateItemOnPositionSync(hatchery:GetAbsOrigin() + RandomVector(RandomFloat(100,150)),clonedItem)
            item:RemoveSelf()
        end
    end
end

function RestartGathering(keys)
    local ability = keys.ability
    local caster = keys.caster
    if ability:GetToggleState() then
        caster.hatchery = nil
        caster:RemoveModifierByName("modifier_itemstore_mode")
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_itemgather_mode", {})
    end
end

function FindHatchery(caster, center, range)
    local units = FindUnitsInRadius(caster:GetTeamNumber(),
        center,
        nil,
        range,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_CREEP,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false)
    for _,unit in pairs(units) do
        if unit:GetUnitName() == "npc_building_hatchery" then
            return unit
        end
    end
end
