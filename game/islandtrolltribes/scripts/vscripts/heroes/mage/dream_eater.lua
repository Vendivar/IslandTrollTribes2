function DreamEater(keys)
    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target

    local hypnosis = keys.hypnosis
    local heal = keys.heal
    local mana = keys.mana
    local dmg = keys.damage
    local damageTable = {victim = target, attacker = caster, damage = dmg, damage_type = DAMAGE_TYPE_MAGICAL}
        
    if string.find(target:GetName(), "hero") and target:HasModifier(hypnosis) then
        caster:Heal(heal, caster)
        caster:GiveMana(mana)
        ApplyDamage(damageTable)
        target:ReduceMana(mana)
        target:RemoveModifierByName(hypnosis)
    end

end