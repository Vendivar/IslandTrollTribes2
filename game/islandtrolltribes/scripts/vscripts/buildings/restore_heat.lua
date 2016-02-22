function RestoreHeatThink (spellInfo)
    Timers:CreateTimer(DoUniqueString("restore_heat"), {callback=RestoreHeat, endTime = 0.1}, spellInfo)
end

function RestoreHeat(spellInfo)
    local caster = spellInfo.caster
    local ability = spellInfo.ability
    local radius = spellInfo.Radius

--    print("Entity instance id: "..caster:GetEntityIndex()..",entity class name : "..caster:GetUnitName())
    if (caster:IsAlive() == false ) then
        return nil
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
    for _,unit in pairs(units) do
--        print("Found the unit: "..unit:GetName())
        if ability:IsActivated() then
            ability:ApplyDataDrivenModifier( caster, unit, "modifier_fire_heat", {duration=1.0})
        end
    end
    return 1.0
end