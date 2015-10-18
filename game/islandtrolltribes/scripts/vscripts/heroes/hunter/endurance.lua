function EnduranceSuccess(keys)
    attacker = keys.attacker
    caster = keys.caster

    local damage = attacker:GetAverageTrueAttackDamage()
    local block = 8
    if damage - block < 3 then
        block = damage - 3
    end

    caster:SetHealth(caster:GetHealth() + block)
end
