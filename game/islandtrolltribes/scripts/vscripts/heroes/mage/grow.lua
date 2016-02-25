function Grow(keys)
    local target = keys.target
    if target == nil then
    target = keys.caster
    end
    target:SetModelScale(keys.GrowAmmt)
end

function Shrink(keys)
    local target = keys.target
    if target == nil then
        target = keys.caster
    end
    target:SetModelScale(1)
end