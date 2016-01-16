function ScryActive( keys )
	local caster = keys.caster
	local caster_team = caster:GetTeam()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1    
	local point = keys.target_points[1]

	-- Ability variables
	local charge_particle = "particles/custom/spirit_walk_glow.vpcf"
	local radius = ability:GetLevelSpecialValueFor("radius", ability_level)
	local vision_duration = ability:GetLevelSpecialValueFor("duration", ability_level) 
	local all_heroes = HeroList:GetAllHeroes()

	-- Create the vision
	AddFOWViewer(caster:GetTeamNumber(), point, radius, vision_duration, false)

end