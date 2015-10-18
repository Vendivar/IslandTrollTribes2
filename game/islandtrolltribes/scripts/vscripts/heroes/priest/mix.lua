function MixHeat(keys)
    local caster = keys.caster
    local target = keys.target

    local heat1 = caster:GetModifierStackCount("modifier_heat_passive", nil)
    local heat2 = target:GetModifierStackCount("modifier_heat_passive", nil)

    newHeat = (heat1+heat2)/2

    caster:SetModifierStackCount("modifier_heat_passive", nil, newHeat)
    target:SetModifierStackCount("modifier_heat_passive", nil, newHeat)
end

function MixEnergy(keys)
    local caster = keys.caster
    local target = keys.target

    local energy1 = caster:GetMana()
    local energy2 = target:GetMana()

    local newMana = (energy1+energy2)/2

    caster:SetMana(newMana)
    target:SetMana(newMana)
end

function MixHealth(keys)
    local caster = keys.caster
    local target = keys.target

    local health1 = caster:GetHealth()
    local health2 = target:GetHealth()

    local newHealth = (health1+health2)/2

    caster:SetHealth(newHealth)
    target:SetHealth(newHealth)
end