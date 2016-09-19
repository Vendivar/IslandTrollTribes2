
function SpeechSlamFail( event )
	local caster = event.caster

	caster:AddSpeechBubble(1,"#es_slamsfail",3.0,0,0)
	caster:EmitSound("es.slamfail")

end 

function SpeechSlam( event )
	local caster = event.caster

	caster:AddSpeechBubble(1,"#es_slam",3.0,0,0)

end 

function SpeechSlamStart( event )
	local caster = event.caster

  local dieRoll = RandomInt(0, 2)

    print("Test your luck! " .. dieRoll)
    if dieRoll == 0 then 
        caster:AddSpeechBubble(1,"#es_slamstart1",2.0,0,0)
		 caster:EmitSound("es.slamstart1")
		 print("1")
    elseif dieRoll == 1 then
        caster:AddSpeechBubble(1,"#es_slamstart2",2.0,0,0)
		 caster:EmitSound("es.slamstart2")
		print("2")
	elseif dieRoll == 2 then
           caster:AddSpeechBubble(1,"#es_slamstart3",2.0,0,0)
			caster:EmitSound("es.slamstart3")
		   print("3")
        end
    end
	
function SpeechTaunt( event )
	local caster = event.caster

	caster:AddSpeechBubble(1,"#es_taunt",2.0,0,0)

end 
