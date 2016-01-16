function Scry( event )
    local caster = event.caster
    local ability = event.ability
    local level = ability:GetLevel()
    local duration = ability:GetSpecialValueFor("duration")
    local pfx = ParticleManager:CreateParticle( "particles/custom/spirit_walk_glow.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( pfx, 0, ability.relocate_targetPoint )
    local dummy = CreateUnitByName("dummy_reveal"..level, caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
    Timers:CreateTimer(duration, function() dummy:RemoveSelf() end)
end


function ScryActive( keys )
	local caster = keys.caster
	local caster_team = caster:GetTeam()
	local target = keys.target
	local target_location = target:GetAbsOrigin()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local charge_particle = "particles/custom/spirit_walk_glow.vpcf"
	local area_of_effect = ability:GetLevelSpecialValueFor("area_of_effect", ability_level)
	local vision_duration = ability:GetLevelSpecialValueFor("duration", ability_level) 
	local vision_distance = 500
	local all_heroes = HeroList:GetAllHeroes()

	-- Create the vision
	local duration =  vision_duration
	ability:CreateVisibilityNode(target_location, vision_distance, vision_duration)

			local particle = ParticleManager:CreateParticleForPlayer(charge_particle, PATTACH_ABSORIGIN, hero, PlayerResource:GetPlayer(hero:GetPlayerID()))
			ParticleManager:SetParticleControl(particle, 0, target_location) 
			ParticleManager:SetParticleControl(particle, 1, Vector(area_of_effect,0,0))

			-- Remove the particle after the charging is done
			Timers:CreateTimer(delay, function()
				ParticleManager:DestroyParticle(particle, false)
			end)
		end
	end
end