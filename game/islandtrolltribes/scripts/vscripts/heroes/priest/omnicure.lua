function Omnicure(keys)
    local caster = keys.caster
    local radius = keys.Radius
    local teamnumber = caster:GetTeamNumber()
    local targetPosition = caster:GetAbsOrigin()
    local units = FindUnitsInRadius(teamnumber,
        targetPosition,
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false)

    local particleName = "particles/units/heroes/hero_oracle/oracle_purifyingflames_hit.vpcf"

    for _,unit in pairs(units) do
        ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN, unit )
       
    unit:RemoveModifierByName("modifier_lizard_slow")
    unit:RemoveModifierByName("modifier_disease1")
    unit:RemoveModifierByName("modifier_disease2")
    unit:RemoveModifierByName("modifier_disease2_auraapplier")
    unit:RemoveModifierByName("modifier_disease2_auraapplied")
    unit:RemoveModifierByName("modifier_disease3")
    unit:RemoveModifierByName("modifier_lightning_shield_damage_aura")
    unit:RemoveModifierByName("modifier_priest_painkillerbalm")
    unit:RemoveModifierByName("modifier_priest_resistall")
    unit:RemoveModifierByName("modifier_pumpup")
    unit:RemoveModifierByName("modifier_rage_ability")
    unit:RemoveModifierByName("modifier_molotov_burn")
    unit:RemoveModifierByName("modifier_potion_nether")
    unit:RemoveModifierByName("modifier_potion_nether")
    unit:RemoveModifierByName("modifier_elemental_shield_damage_aura")

    end
end