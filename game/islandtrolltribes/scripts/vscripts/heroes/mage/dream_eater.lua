function DreamEater(keys)
    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target
    local particle = keys.particle_modifier

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
        ability:ApplyDataDrivenModifier(caster, target, particle, {duration = 5.0})
    end
    ShowHypnosis(caster,ability)
end

function ShowHypnosis(caster,dreamEaterAbility)
    local hypnosisAbility = caster:FindAbilityByName("ability_mage_hypnosis")
    SetAbilityVisibility(caster,dreamEaterAbility:GetAbilityName(),false)
    SetAbilityVisibility(caster,hypnosisAbility:GetAbilityName(),true)
end