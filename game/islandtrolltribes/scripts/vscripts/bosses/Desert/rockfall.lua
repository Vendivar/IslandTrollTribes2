
function SpeechRockfallStart( event )
	local caster = event.caster

  local dieRoll = RandomInt(0, 2)

    print("Test your luck! " .. dieRoll)
    if dieRoll == 0 then 
        caster:AddSpeechBubble(1,"#es_rockfall1",2.0,0,0)
		caster:EmitSound("es.rockfall1")
		 print("1")
    elseif dieRoll == 1 then
        caster:AddSpeechBubble(1,"#es_rockfall2",2.0,0,0)
		 caster:EmitSound("es.rockfall2")
		print("2")
	elseif dieRoll == 2 then
           caster:AddSpeechBubble(1,"#es_rockfall3",2.0,0,0)
			caster:EmitSound("es.rockfall3")
		   print("3")
        end
    end
	

function SpeechTaunt( event )
	local caster = event.caster

	caster:AddSpeechBubble(1,"#es_taunt",2.0,0,0)

end 


function RockFall( keys )
	local caster = keys.caster
	local abilityName = "ability_rockfall"

    for i=1,5 do
        randomPoint = caster:GetOrigin() + RandomVector(RandomInt(50,500))
        AOEparticle = ParticleManager:CreateParticle("particles/custom/aoe_indicator_small.vpcf", PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(AOEparticle, 0, randomPoint)

        local dummy = CreateUnitByName("dummy_caster", randomPoint, false, caster, caster, caster:GetTeam())
        dummy:AddAbility("ability_rockfall")
        local rockAbility = dummy:FindAbilityByName("ability_rockfall")
        rockAbility:SetLevel(1)

        Timers:CreateTimer(5, function()
		caster:EmitSound("scroll.boulder")
            dummy:CastAbilityOnPosition(dummy:GetOrigin(), rockAbility, -1)
            return
        end)
        Timers:CreateTimer(1, function()
            return
        end)
    end
end