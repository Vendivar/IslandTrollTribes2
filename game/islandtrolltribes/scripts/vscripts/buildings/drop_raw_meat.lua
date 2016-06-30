function DropMeatStack(keys)
    local caster = keys.caster
    local rawMeatStackCount =  caster:GetModifierStackCount("modifier_meat_passive", nil) or 0
    local position =  caster:GetAbsOrigin()
    local point =  keys.target_points[1]
    local stackCounter = rawMeatStackCount
    for i=1,rawMeatStackCount do
        CreateRawMeat(position, point)
        stackCounter = stackCounter - 1
        caster:SetModifierStackCount("modifier_meat_passive", nil, stackCounter)
    end
end

function CreateRawMeat(position, point)
    local droppedStateDuration = 20.0
    local dropPosition = position
    local launchPosition = point + RandomVector(RandomFloat(50,50))
    local rawMeat = CreateItem("item_meat_raw", nil, nil)
    CreateItemOnPositionSync(dropPosition, rawMeat)
    DropLaunch(caster, rawMeat, 0.75, launchPosition)    
    rawMeat.dropped = true
    Timers:CreateTimer(droppedStateDuration, function()
        rawMeat.dropped = nil
    end)
end


