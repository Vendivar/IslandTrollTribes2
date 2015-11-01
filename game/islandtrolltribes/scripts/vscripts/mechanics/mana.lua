function RestoreMana(keys)
    local target = keys.target
    local manaGain = keys.ManaRestored
    if not target then
        target = keys.caster
    end

    target:GiveMana(manaGain)
    PopupMana(target, manaGain)
end

function RemoveMana(keys)
    local target = keys.target
    local ability = keys.ability
    local manaloss = keys.ManaRemoved
    if not target then
        target = keys.caster
    end

    local mana = target:GetMana()
    target:SpendMana(manaloss, ability)
    PopupMana(target, -manaloss)
end