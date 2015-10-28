function SpearDarkThrow(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    local damageMin = keys.DamageMin
    local damageMax = keys.DamageMax
    local randomDamage = RandomInt(damageMin, damageMax)

    local startingMana = target:GetMana()
    target:SpendMana(randomDamage, nil)
    
    local damageTable = {
        victim = target,
        attacker = caster,
        damage = randomDamage,
        damage_type = DAMAGE_TYPE_MAGICAL
    }

    ApplyDamage(damageTable)
    PopupMana(target, -randomDamage)
end