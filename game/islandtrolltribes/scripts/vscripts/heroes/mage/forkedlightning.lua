function ForkedLightning( events )
	local caster = events.caster
	local target = events.target

	local radius = events.radius
	local damage = events.damage

	local targets = {}
	local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	if #units > 1 then
		first = RandomInt(1, #units)
		second = first
		while second == first do
			second = (RandomInt(1, #units)
		end
		targets = {units[first], units[second]}
	else if #units == 1 then
		targets = {units[1]}
	end
	PrintTable(targets)
end