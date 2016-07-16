function RestoreHeatThink (spellInfo)
    Timers:CreateTimer(DoUniqueString("restore_heat"), {callback=RestoreHeat, endTime = 0.1}, spellInfo)
end

function RestoreHeat(spellInfo)
    local caster = spellInfo.caster
    local ability = spellInfo.ability
    local radius = spellInfo.Radius
    local heat = spellInfo.Heat

    if not IsValidEntity(caster) or not caster:IsAlive() then
        return
    end

    local targetPosition = caster:GetAbsOrigin()
    local teamNumber = caster:GetTeamNumber()
    local units = FindUnitsInRadius(teamNumber,
        targetPosition,
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false)

    local modifier = "modifier_fire_heat"
    if heat == 16 then
        modifier = "modifier_mage_fire_heat"
    end

    for _,unit in pairs(units) do
        if ability:IsActivated() then
            ability:ApplyDataDrivenModifier( caster, unit, modifier, {duration=1.0})
        end
    end
    return 1.0
end
