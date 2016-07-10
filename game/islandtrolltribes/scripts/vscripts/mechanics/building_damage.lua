function DamageBuilding(target, damage, ability, caster)
    local currentHP = target:GetHealth()
    local newHP = currentHP - damage

    -- If the HP would hit 0 with this damage, kill the unit
    if newHP <= 0 then
        target:Kill(ability, caster)
    else
        target:SetHealth(newHP)
    end
end