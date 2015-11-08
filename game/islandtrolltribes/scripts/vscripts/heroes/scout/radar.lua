function EnemyRadar(keys)
    local caster = keys.caster
    local ability = keys.ability
    local range = ability:GetCastRange()
    local casterPosition = caster:GetAbsOrigin()
    local teamnumber = caster:GetTeamNumber()

    local units = FindUnitsInRadius(teamnumber, casterPosition, nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
    
    if #units > 0 then
        for _, unit in pairs(units) do
            local r = 0
            local g = 0
            local b = 0
            if unit:IsRealHero() then
                r = 255
            else
                b = 255
            end

            local position = unit:GetAbsOrigin()
            local thisParticle = ParticleManager:CreateParticleForTeam("particles/custom/ping_world.vpcf", PATTACH_ABSORIGIN, caster, teamnumber)
            ParticleManager:SetParticleControl(thisParticle, 0, position)
            ParticleManager:SetParticleControl(thisParticle, 1, Vector(r, g, b))

            local particle = ParticleManager:CreateParticleForTeam("particles/custom/ping_static.vpcf", PATTACH_ABSORIGIN, caster, teamnumber)
            ParticleManager:SetParticleControl(particle, 0, position)
            ParticleManager:SetParticleControl(particle, 1, Vector(r, g, b))
            Timers:CreateTimer(3, function() ParticleManager:DestroyParticle(particle, true) end)

            PingMap(unit, position, r, g, b, teamnumber)
        end

        EmitSoundOnLocationForAllies(caster:GetAbsOrigin(), "General.Ping", caster)
    end
end