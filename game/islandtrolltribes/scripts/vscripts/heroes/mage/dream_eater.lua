
function DreamInit(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    if not target:HasModifier("modifier_mage_hypnosis") then
        SendErrorMessage(caster:GetPlayerOwnerID(),"#invalid_hypnosis")
        caster:Interrupt()
        ability:StartCooldown(1.0)
    end
end

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
        
    if string.find(target:GetName(), "hero") and target:HasModifier("modifier_mage_hypnosis") then
        caster:Heal(heal, caster)
        caster:GiveMana(mana)
        ApplyDamage(damageTable)
        target:ReduceMana(mana)
        target:RemoveModifierByName(hypnosis)
        ability:ApplyDataDrivenModifier(caster, target, particle, {duration = 5.0})
        
      --  local particle = ParticleManager:CreateParticleForPlayer( "particles/custom/dream_eater.vpcf", PATTACH_ABSORIGIN, target, caster )
      --  ParticleManager:SetParticleControl( particle, 0, target:GetAbsOrigin() )
      --  ParticleManager:SetParticleControl( particle, 1, caster:GetAbsOrigin() )
    end
    ShowHypnosis(caster,ability)
end

function ShowHypnosis(caster,dreamEaterAbility)
    local hypnosisAbility = caster:FindAbilityByName("ability_mage_hypnosis")
    SetAbilityVisibility(caster,dreamEaterAbility:GetAbilityName(),false)
    SetAbilityVisibility(caster,hypnosisAbility:GetAbilityName(),true)
end