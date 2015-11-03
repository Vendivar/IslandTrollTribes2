function Jump(keys)
    local caster = keys.caster
    local point = keys.target_points[1]

    local dummyTarget = CreateUnitByName("dummy_caster_metronome", point, false, nil, nil,DOTA_TEAM_NEUTRALS)

    FindClearSpaceForUnit(caster, point, false) 
    local landParticle = ParticleManager:CreateParticle("particles/custom/jump_land_smoke.vpcf", PATTACH_ABSORIGIN, point)
   			Timers:CreateTimer(3,
      function()
          ParticleManager:DestroyParticle(landParticle, false)
        end)
end

