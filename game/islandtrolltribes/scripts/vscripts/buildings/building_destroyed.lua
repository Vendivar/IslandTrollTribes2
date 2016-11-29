function BuildingDestroyed(keys)
caster = keys.caster
	
    local destroyEffect = ParticleManager:CreateParticle("particles/custom/building_collapse_light_d.vpcf", PATTACH_CUSTOMORIGIN, hatchery)
    ParticleManager:SetParticleControl(destroyEffect,0,caster:GetAbsOrigin())
	EmitSoundOn( "building.die", caster )
end