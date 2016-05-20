function CheckPosition( event )
    local caster = event.caster
    local point = event.target_points[1]
	local ability	= event.ability
    

    
    if not BuildingHelper:ValidPosition(2, point, event) then
        caster:Interrupt()
        SendErrorMessage(caster:GetPlayerOwnerID(), "#error_invalid_build_position")
    end
end

function CreateTeleportParticles( event )
	local caster = event.caster
	local point = event.target_points[1]
end

function MakeBoulder( event )
    local caster = event.caster
    local point = event.target_points[1]
    local dur = 25.0 --default duration for anything besides heross

	local particleName = "particles/custom/boulder_scroll_drop.vpcf"
	caster.boulderParticle = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(caster.boulderParticle, 1, point)	

    
    Timers:CreateTimer(1.0,
		function() 
			--print(ability.trees_cut)

			-- Spawn as many treants as possible
				local boulder = CreateUnitByName("npc_scroll_boulder", point, false, caster, caster, caster:GetTeamNumber())
				boulder:AddNewModifier(caster, nil, "modifier_kill", {duration = dur})
				FindClearSpaceForUnit(boulder, point, true)
                ParticleManager:DestroyParticle(caster.boulderParticle,false)
		end)
    
    
    

end

function EndBoulderParticle( event )
    local caster = event.caster
    --target:EmitSound("Hero_Abaddon.AphoticShield.Destroy")
    ParticleManager:DestroyParticle(caster.boulderParticle,false)
end