-- TODO: Add popups.lua
function RestoreMana(keys)
    local target = keys.target
    if target == nil then
        target = keys.caster
    end
    target:GiveMana(keys.ManaRestored)
end

function RemoveMana(keys)
    local target = keys.target
    local manaloss = keys.ManaRemoved

    if target == nil then
        target = keys.caster
    end

    local mana = target:GetMana()
    target:SetMana(mana-manaloss)
end