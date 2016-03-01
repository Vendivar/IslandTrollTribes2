function Hypnosis(keys)
    local hypnosisAbility = keys.ability
    local caster  = keys.caster
    local target  = keys.target

    local heat = keys.heat_removed
    local mana = keys.mana_restored
    local hypnosis = keys.hypnosis

    local dur = keys.duration_creep
    if string.find(target:GetName(), "hero") then
        dur = keys.duration
        AddHeat(keys)
    end
    target:GiveMana(mana)

    hypnosisAbility:ApplyDataDrivenModifier(caster, target, hypnosis, {duration = dur})

    if not caster:HasAbility("ability_mage_dreameater") then
        caster:AddAbility("ability_mage_dreameater")
        local dreamEaterAbility = caster:FindAbilityByName("ability_mage_dreameater")
        dreamEaterAbility:SetLevel(1)
        dreamEaterAbility:SetAbilityIndex(hypnosisAbility:GetAbilityIndex()+1)
    end
    local dreamEaterAbility = caster:FindAbilityByName("ability_mage_dreameater")

    ReplaceAbility(caster, hypnosisAbility, dreamEaterAbility)
    Timers:CreateTimer(dur,function()
        ReplaceAbility(caster,dreamEaterAbility, hypnosisAbility)
    end)
end

function ReplaceAbility(caster,oldAbility, newAbility)
    SetAbilityVisibility(caster,newAbility:GetAbilityName(),true)
    SetAbilityVisibility(caster,oldAbility:GetAbilityName(),false)
end
