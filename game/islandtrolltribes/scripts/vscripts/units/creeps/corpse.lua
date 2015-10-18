function Corpse( event )
	target = event.target
	decayTime = event.decay_time

	Timers:CreateTimer(decayTime, function()
		target:ForceKill(true)
		return
	end)
end