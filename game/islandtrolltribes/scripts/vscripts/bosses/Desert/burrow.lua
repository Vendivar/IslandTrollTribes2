
function SpeechBurrow( event )
	local caster = event.caster

	caster:AddSpeechBubble(1,"#sk_burrow1",3.0,0,0)

end 

function SpeechTaunt( event )
	local caster = event.caster

	caster:AddSpeechBubble(1,"#sk_taunt",2.0,0,0)

end 


function burrowstrike_teleport( keys )
	local point = keys.target_points[1]
	local caster = keys.caster
	FindClearSpaceForUnit( caster, point, false )
end