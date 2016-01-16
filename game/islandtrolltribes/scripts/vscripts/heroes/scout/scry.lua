function ScryActive( keys )
	local caster = keys.caster
	local caster_team = caster:GetTeam()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1    
	local point = keys.target_points[1]

	local particleName = "particles/items_fx/dust_of_appearance.vpcf"

	-- Ability variables
	local charge_particle = "particles/custom/spirit_walk_glow.vpcf"
	local radius = ability:GetLevelSpecialValueFor("radius", ability_level)
	local vision_duration = ability:GetLevelSpecialValueFor("duration", ability_level) 
	local all_heroes = HeroList:GetAllHeroes()

	-- Create the vision
	AddFOWViewer(caster:GetTeamNumber(), point, radius, vision_duration, false)
    
    

	-- Particle for team
	for _, v in pairs( all_heroes ) do
		if v:GetPlayerID() and v:GetTeam() == caster:GetTeam() then
			local fxIndex = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_WORLDORIGIN, v, PlayerResource:GetPlayer( v:GetPlayerID() ) )
			ParticleManager:SetParticleControl( fxIndex, 0, point )
			ParticleManager:SetParticleControl( fxIndex, 1, Vector(radius,0,radius) )
		end
	end

end