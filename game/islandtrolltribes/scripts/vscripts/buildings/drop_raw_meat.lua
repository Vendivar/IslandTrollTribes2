function DropMeatStack(keys)
    local caster = keys.caster
    local rawMeatStackCount =  caster:GetModifierStackCount("modifier_meat_passive", nil) or 0
    local position =  caster:GetAbsOrigin()
    local stackCounter = rawMeatStackCount
    for i=1,rawMeatStackCount do
        CreateRawMeat(position)
        stackCounter = stackCounter - 1
        caster:SetModifierStackCount("modifier_meat_passive", nil, stackCounter)
        keys.ability:ApplyDataDrivenModifier(thisEntity, thisEntity, "modifier_just_dropped", {duration = -1})
    end
end

function CreateRawMeat(position)
    local dropDuration = 20.0
    local launchPosition = position + RandomVector(RandomFloat(100,150))
    local rawMeat = CreateItem("item_meat_raw", nil, nil)
    CreateItemOnPositionSync(position,rawMeat)
    rawMeat:LaunchLoot(false, 200, 0.75, launchPosition)
    rawMeat.dropped = true
    Timers:CreateTimer(dropDuration, function()
        rawMeat.dropped = nil
    end)
end