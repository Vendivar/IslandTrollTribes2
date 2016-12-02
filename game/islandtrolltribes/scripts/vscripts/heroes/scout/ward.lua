function PlaceWardCheck(keys)
    local caster = keys.caster
    local ability = keys.ability
    local curstacks = caster:GetModifierStackCount("modifier_wardcount", caster)
	print(caster,caster,curstacks)
	
    if curstacks >= 10 then
        SendErrorMessage(caster:GetPlayerOwnerID(),"#error_toomanywards")
        caster:Interrupt()
        ability:StartCooldown(1.0)
    else
	caster:AddNewModifier(caster, nil, "modifier_wardcount",{duration = -1})
    end
end

function PlaceWard( keys )
    local caster = keys.caster
	local target_point = keys.target_points[1]
    local curstacks = caster:GetModifierStackCount("modifier_wardcount", caster)

    local particle = ParticleManager:CreateParticle( "particles/custom/scout_ward_place.vpcf", PATTACH_CUSTOMORIGIN, nil )
    ParticleManager:SetParticleControl( particle, 0, target_point )
    ParticleManager:SetParticleControl( particle, 1, Vector( 0.0, -30, 0.0 ) )

	local ScoutWard = CreateUnitByName("npc_scout_ward", target_point, false, caster, caster, caster:GetTeam())
	ScoutWard:AddNewModifier(caster, nil, "modifier_invisible",{duration = -1, hidden = true})	
	ScoutWard:AddNewModifier(caster, nil, "modifier_kill", {duration = 120, hidden = true})
	caster:SetModifierStackCount("modifier_wardcount", nil, curstacks + 1)
end


function ScoutWardActivate(keys)
    local caster = keys.caster
    local target = keys.target

	if target:IsHero() and target:HasModifier("modifier_living_clay") then
	print("Gotcha")
	end
	
end











function WardTheArea( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Modifiers
	local modifier_living_clay = keys.modifier_living_clay
	local modifier_tracker = keys.modifier_tracker
	local modifier_caster = keys.modifier_caster

	-- Ability variables
	local activation_time = ability:GetLevelSpecialValueFor("explode_delay", ability_level)
	local expiration_time = ability:GetLevelSpecialValueFor("lifetime", ability_level)
	local num_wards = ability:GetLevelSpecialValueFor("wards", ability_level)
	local fade_time = ability:GetLevelSpecialValueFor("fade_time", ability_level)
	local aoe = ability:GetLevelSpecialValueFor("aoe", ability_level)

	--Generate random locations
	for i = 1, num_wards do
		local rand_vector = RandomVector(RandomFloat(0,aoe))
		local rand_point = caster:GetOrigin() + rand_vector
		print("random point for clay x:" .. rand_point.x .. " y:" .. rand_point.y .. " z:" .. rand_point.z)

		-- Create the land mine and apply the land mine modifier
		local living_clay = CreateUnitByName("npc_clay_living", rand_point, true, nil, nil, caster:GetTeamNumber())

		local trackingInfo = {}
		trackingInfo.ScoutWard = living_clay
		trackingInfo.caster = caster
		trackingInfo.trigger_radius = ability:GetLevelSpecialValueFor("radius", ability_level)
		trackingInfo.explode_delay = ability:GetLevelSpecialValueFor("explode_delay", ability_level)
		trackingInfo.expiration_time = GameRules:GetGameTime() + expiration_time

		-- Apply the tracker after the activation time
		Timers:CreateTimer(DoUniqueString("living_clay_tracker"),{callback = ScoutWardTracker, endTime = activation_time}, trackingInfo)
		-- Apply the invisibility after the fade time

		Timers:CreateTimer(fade_time, function()
			living_clay:AddNewModifier(living_clay,nil,"modifier_invisible",{duration = -1, hidden = true})
		end)
		ability:ApplyDataDrivenModifier(caster, living_clay, "modifier_living_clay", {})
	end

end
