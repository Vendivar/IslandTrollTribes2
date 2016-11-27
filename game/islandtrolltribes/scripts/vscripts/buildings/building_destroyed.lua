function BuildingDestroyed(keys)
caster = keys.caster

	local particleName = "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_spirit_form_ambient.vpcf"
	caster.buildingDestroyedParticle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster, caster())
	Timers:CreateTimer(2, function() caster:AddNoDraw() end)
end