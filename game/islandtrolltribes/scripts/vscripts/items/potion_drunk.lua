function PotionDrunkUse(keys)
	local caster = keys.caster
	local target = keys.target

	local dur = 13.0
	if (target:IsHero()) then --if the target is a hero unit, shorter duration
		dur = 9.0
	end
	
	target:AddNewModifier(caster, nil, "modifier_brewmaster_drunken_haze", {duration = dur, movement_slow = 10, miss_chance = 50})    
end