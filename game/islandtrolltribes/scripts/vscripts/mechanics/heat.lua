function AddHeat(keys)
    local caster = keys.caster
    local target = keys.target

    if target == nil then
        target = caster
    end
    local heatToAdd = keys.Heat
    local heatStackCount = target:GetModifierStackCount("modifier_heat_passive", nil) + heatToAdd
    if heatStackCount > 100 then
        heatStackCount = 100
    end
    if heatStackCount <= 0 then
        heatStackCount = 1
    end
    target:SetModifierStackCount("modifier_heat_passive", nil, heatStackCount)
end