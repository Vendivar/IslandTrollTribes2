function CheckPosition( event )
	local caster = event.caster
	local point = event.target_points[1]
	local distance = (point - caster:GetAbsOrigin()):Length2D()
    if not BuildingHelper:ValidPosition(2, point, event) or distance > 500 then
        caster:Interrupt()
        SendErrorMessage(caster:GetPlayerOwnerID(), "#error_invalid_build_position")
    end
end



function MakeLesserBeehives(keys)
    local caster = keys.caster
    local origin =  keys.target_points[1]
	
        randomPoint = caster:GetOrigin() + RandomVector(RandomInt(50,500))
        AOEparticle = ParticleManager:CreateParticle("particles/custom/bee_swarm_throw_pull_child_plenty.vpcf", PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(AOEparticle, 0, caster:GetOrigin())
        ParticleManager:SetParticleControl(AOEparticle, 1, randomPoint)

        local beehive = CreateUnitByName("npc_beehive_lesser", randomPoint, false, caster, caster, caster:GetTeam())
		beehive:AddNewModifier(caster, nil, "modifier_kill", {duration = 10})
	
end