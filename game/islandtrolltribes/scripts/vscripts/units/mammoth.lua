function MammothBlockSuccess(keys)
    attacker = keys.attacker
    caster = keys.caster

    local damage = attacker:GetAverageTrueAttackDamage()
    local block = 17
    if damage - block < 1 then
        block = damage - 1
    end

    caster:SetHealth(caster:GetHealth() + block)
end