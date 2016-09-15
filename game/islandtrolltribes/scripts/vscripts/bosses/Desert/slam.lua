
function SpeechSlamFail( event )
	local caster = event.caster

	caster:AddSpeechBubble(1,"#es_slamstart1",3.0,0,0)

end 
function SpeechSlamStart( event )
	local caster = event.caster

	caster:AddSpeechBubble(1,"#es_slam1",3.0,0,0)

end 
function SpeechSlam( event )
	local caster = event.caster

	caster:AddSpeechBubble(1,"#es_slamfail1",3.0,0,0)

end 

function SpeechTaunt( event )
	local caster = event.caster

	caster:AddSpeechBubble(1,"#es_taunt",2.0,0,0)

end 
