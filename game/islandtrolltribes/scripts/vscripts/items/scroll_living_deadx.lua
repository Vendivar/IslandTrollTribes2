function SummonSkeleton(keys)
	local caster = keys.caster

	local skeleton1 = CreateUnitByName("npc_creature_scroll_skeleton", caster:GetOrigin() + RandomVector(RandomInt(100,200)), true, nil, caster, keys.caster:GetTeam())
	skeleton1.position = 90
	local skeleton2 = CreateUnitByName("npc_creature_scroll_skeleton", caster:GetOrigin() + RandomVector(RandomInt(100,200)), true, nil, caster, keys.caster:GetTeam())
	skeleton2.position = -90

end