function DieOnEnemyCollision(keys)
    local caster = keys.caster
    local teamnumber = caster:GetTeamNumber()
    local casterPosition = caster:GetAbsOrigin()
    local radius = keys.Radius

    local units = FindUnitsInRadius(teamnumber,
                                    casterPosition,
                                    nil,
                                    radius,
                                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                                    DOTA_UNIT_TARGET_HERO,
                                    DOTA_UNIT_TARGET_FLAG_NONE,
                                    FIND_ANY_ORDER,
                                    false)
    local count = 0
    for _ in pairs(units) do
        count = count + 1
    end
    if count > 0 then
        caster:ForceKill(true)
    end
end