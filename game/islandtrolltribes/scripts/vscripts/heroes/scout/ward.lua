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
    local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local target_point = keys.target_points[1]
    local curstacks = caster:GetModifierStackCount("modifier_wardcount", caster)
	local dur = ability:GetLevelSpecialValueFor("life_duration", ability_level)

    local particle = ParticleManager:CreateParticle( "particles/custom/scout_ward_place.vpcf", PATTACH_CUSTOMORIGIN, nil )
    ParticleManager:SetParticleControl( particle, 0, target_point )
    ParticleManager:SetParticleControl( particle, 1, Vector( 0.0, -30, 0.0 ) )

	local ScoutWard = CreateUnitByName("npc_scout_ward", target_point, false, caster, caster, caster:GetTeam())
	ScoutWard:AddNewModifier(caster, nil, "modifier_invisible",{duration = -1, hidden = true})	
	ScoutWard:AddNewModifier(caster, nil, "modifier_kill", {duration = dur, hidden = false})
	caster:SetModifierStackCount("modifier_wardcount", nil, curstacks + 1)
end


function ScoutWardActivate(keys)
    local caster = keys.caster
    local target = keys.target
	local originalcaster = caster:GetOwner()
    local curstacks = originalcaster:GetModifierStackCount("modifier_wardcount", originalcaster)
	caster:ForceKill(true)	
	originalcaster:SetModifierStackCount("modifier_wardcount", nil, curstacks - 1)
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
	local num_wards = ability:GetLevelSpecialValueFor("wards", ability_level)
	local aoe = ability:GetLevelSpecialValueFor("aoe", ability_level)
	local dur = ability:GetLevelSpecialValueFor("lifetime", ability_level)

	--Generate random locations
	for i = 1, num_wards do
		local rand_vector = RandomVector(RandomFloat(0,aoe))
		local rand_point = caster:GetOrigin() + rand_vector
		print("random point for clay x:" .. rand_point.x .. " y:" .. rand_point.y .. " z:" .. rand_point.z)


	local ScoutWard = CreateUnitByName("npc_scout_ward", rand_point, false, caster, caster, caster:GetTeam())
	ScoutWard:AddNewModifier(caster, nil, "modifier_invisible",{duration = -1, hidden = true})	
	ScoutWard:AddNewModifier(caster, nil, "modifier_kill", {duration = 120, hidden = true})
end
end