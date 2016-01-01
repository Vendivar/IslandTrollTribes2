function Jump(keys)
    local caster = keys.caster
    local point = keys.target_points[1]

    local dummyTarget = CreateUnitByName("dummy_caster_metronome", point, false, nil, nil,DOTA_TEAM_NEUTRALS)

    FindClearSpaceForUnit(caster, point, false) 
end

