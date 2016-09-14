
function SpeechRockFall( event )
	local caster = event.caster

	caster:AddSpeechBubble(1,"#es_rockfall1",3.0,0,0)

end 

function SpeechTaunt( event )
	local caster = event.caster

	caster:AddSpeechBubble(1,"#es_taunt",2.0,0,0)

end 


function RockFall( keys )
	local caster = keys.caster
	local abilityName = "ability_rockfall"
	
        local dummy = CreateUnitByName("dummy_caster", caster:GetOrigin() + RandomVector(RandomInt(500,500)), false, caster, caster, caster:GetTeam())
        dummy:AddAbility("ability_rockfall")
        local rockAbility = dummy:FindAbilityByName("ability_rockfall")
        rockAbility:SetLevel(1)
		
	
        Timers:CreateTimer(5, function()
            dummy:CastAbilityOnPosition(dummy:GetOrigin(), rockAbility, -1)
            return
        end)
        Timers:CreateTimer(1, function()
            return
        end)

end