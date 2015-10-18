function Teleport(keys)
    local caster = keys.caster
    local point = keys.target_points[1]

    local dummyTarget = CreateUnitByName("dummy_caster_metronome", point, false, nil, nil,DOTA_TEAM_NEUTRALS)
    local visible = caster:CanEntityBeSeenByMyTeam(dummyTarget)

    if visible then
        FindClearSpaceForUnit(caster, point, false)
    else
        local tp = caster:FindAbilityByName("ability_thief_teleport")
        tp:EndCooldown()
        local mana = tp:GetManaCost(1)
        caster:GiveMana(mana)
    end
end