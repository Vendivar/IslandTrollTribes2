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
        unit:RemoveModifierByName("modifier_disease3")
    end
end