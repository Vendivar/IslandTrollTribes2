function ElectroMagnetStart(keys)
    local caster = keys.caster
    local target = keys.target
    local pfx = keys.pfx
    target.pull_pfx = ParticleManager:CreateParticle(pfx, PATTACH_POINT_FOLLOW, caster)
end

function ElectroMagnetThink(keys)
    local ability = keys.ability
    local caster = keys.caster
    local origin = caster:GetAbsOrigin()
    local target = keys.target
    local targetPosition = target:GetAbsOrigin()
    local minimumPullRange = keys.min_range
    local pullMultiplier = keys.pull_scale

    local difference = origin - targetPosition
    if math.sqrt( math.pow(difference.x, 2 ) + math.pow( difference.y, 2 ) ) > minimumPullRange then
        local displacement = difference:Normalized() * pullMultiplier
        target:SetAbsOrigin( targetPosition + displacement )
        FindClearSpaceForUnit( target, target:GetAbsOrigin(), true )
    end
    ParticleManager:SetParticleControl(target.pull_pfx, 1, Vector( targetPosition.x, targetPosition.y, targetPosition.z + ( target:GetBoundingMaxs().z - target:GetBoundingMins().z ) / 2 ) )
end

function ElectroMagnetEnd(keys)
    local target = keys.target
    local caster = keys.caster
	
    ParticleManager:DestroyParticle(target.pull_pfx, false)		
    ParticleManager:DestroyParticle(caster.pull_pfx, false)		
	
	target:StopSound("Hero_Disruptor.StaticStorm")
	target:StopSound("Hero_StormSpirit.ElectricVortex")
	caster:StopSound("Hero_Disruptor.StaticStorm")
	caster:StopSound("Hero_StormSpirit.ElectricVortex")
end
