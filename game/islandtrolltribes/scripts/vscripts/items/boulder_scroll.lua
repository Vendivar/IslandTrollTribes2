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

	local particleName = "particles/custom/boulder_scroll_drop.vpcf"
	caster.boulderParticle = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(caster.boulderParticle, 1, point)	

    
    Timers:CreateTimer(1.0,
		function() 
			--print(ability.trees_cut)

			-- Spawn as many treants as possible
				local boulder = CreateUnitByName(unit_name, point, true, caster, caster, caster:GetTeamNumber())
				treant:SetControllableByPlayer(pID, true)
				treant:AddNewModifier(caster, ability, "modifier_kill", {duration = duration})
			end
		end
	)
    
end