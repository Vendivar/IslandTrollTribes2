--[[
function SpawnCreature(unitName, spawnerName)
	--print("spawn")
	GameMode = GameRules:GetGameModeEntity()
	local allSpawns = Entities:FindAllByClassname("npc_dota_spawner")
	local possibleLocations = {}
	for _,v in pairs(allSpawns) do
		if string.find(v:GetName(), spawnerName) then
			table.insert(possibleLocations, v)
		end
	end
	local spawnLocation = possibleLocations[RandomInt(1, #possibleLocations)]

	if spawnLocation ~= nil then
		local nearbyUnits = FindUnitsInRadius(
								DOTA_TEAM_BADGUYS,
								spawnLocation:GetOrigin(),
								nil, 100,
								DOTA_UNIT_TARGET_TEAM_BOTH,
								DOTA_UNIT_TARGET_ALL,
								DOTA_UNIT_TARGET_FLAG_NONE,
								FIND_ANY_ORDER,
								false)
		if #nearbyUnits == 0 then
			CreateUnitByName(unitName, spawnLocation:GetOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)
			GameMode.neutralCurNum[unitName] = GameMode.neutralCurNum[unitName] + 1
			--CreateUnitByName("npc_creep_hawk", spawnLocation:GetOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)
		end
	end
end
--]]


function SpawnCreature(unitName, spawnerName)
    spawn = false
    while (spawn == false) do
        spawnLocation = GetRandomVectorInBounds()
        local nearbyUnits = FindUnitsInRadius(DOTA_TEAM_BADGUYS, spawnLocation, nil, 100, DOTA_UNIT_TARGET_TEAM_BOTH,DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER, false)
        if #nearbyUnits == 0 then
            CreateUnitByName(unitName, spawnLocation, false, nil, nil, DOTA_TEAM_NEUTRALS)
            FindClearSpaceForUnit(unitname, spawnLocation, false) 
			GameMode.neutralCurNum[unitName] = GameMode.neutralCurNum[unitName] + 1
            spawn = true
        end
    end
end
