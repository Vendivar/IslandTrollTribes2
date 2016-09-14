--[[
	Author: kritth
	Date: 1.1.2015
	Remove the loop sound upon destroying the modifier
]]
function sand_storm_remove_sound( keys )
	local sound_name = "Ability.SandKing_SandStorm.loop"
	StopSoundEvent( sound_name, keys.caster )
end

function SpeechSandstorm( event )
	local caster = event.caster

	caster:AddSpeechBubble(1,"#sk_sand1",3.0,0,0)

end 

function SpeechTaunt( event )
	local caster = event.caster

	caster:AddSpeechBubble(1,"#sk_taunt",2.0,0,0)

end 

