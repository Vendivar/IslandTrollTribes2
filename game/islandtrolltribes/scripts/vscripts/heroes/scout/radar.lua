function EnemyRadar(keys)
    local caster = keys.caster
    local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
--    print("Ability cast range: "..ability:GetCastRange())
    local range = ability:GetCastRange() + GetMapMagicBonusRange(caster)
--    print("Ability cast range after mapmagic bonus: "..range)
    local casterPosition = caster:GetAbsOrigin()
    local teamnumber = caster:GetTeamNumber()

	local duration = ability:GetLevelSpecialValueFor("duration", ability_level) 
    
    local units = FindUnitsInRadius(teamnumber, casterPosition, nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
    
    if #units > 0 then
        for _, unit in pairs(units) do
            local r = 0
            local g = 0
            local b = 0
            local color = "white"
            if unit:IsRealHero() then
                r = 255
                color = "red"
            else
                b = 255
                color = "blue"
            end

            local position = unit:GetAbsOrigin()
            local thisParticle = ParticleManager:CreateParticleForTeam("particles/custom/ping_world.vpcf", PATTACH_ABSORIGIN, caster, teamnumber)
            ParticleManager:SetParticleControl(thisParticle, 0, position)
            ParticleManager:SetParticleControl(thisParticle, 1, Vector(r, g, b))

            local particle = ParticleManager:CreateParticleForTeam("particles/custom/ping_static.vpcf", PATTACH_ABSORIGIN, caster, teamnumber)
            ParticleManager:SetParticleControl(particle, 0, position)
            ParticleManager:SetParticleControl(particle, 1, Vector(r, g, b))
            Timers:CreateTimer(duration, function() ParticleManager:DestroyParticle(particle, true) end)

            PingMap(unit, position, color, teamnumber, duration)
        end

        EmitSoundOnLocationForAllies(caster:GetAbsOrigin(), "General.Ping", caster)
    end
end

function GetMapMagicBonusRange(caster)
    local mapMagicBonus =  0
    if caster:HasModifier("modifier_mapmagic") then
        mapMagicBonus = 1000
    end
    return mapMagicBonus
end