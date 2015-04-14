
-- Old code for spawning in a specific spot
-- Mammoth, etc should use this
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

-- Spawns a creature on a random clear spot
-- Kinda messy and uses a shotgun approach
-- Unlikely to be perfect, but hard to do so without some of the methods working properly

function SpawnRandomCreature(unitName)
    spawn = false
    -- repeats for each spawn till it finds a clear spot
    while (spawn == false) do
        spawnLocation = GetRandomVectorInBounds()
        local nearbyUnits = FindUnitsInRadius(DOTA_TEAM_BADGUYS, spawnLocation, nil, 100, DOTA_UNIT_TARGET_TEAM_BOTH,DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER, false)
        -- Checks a bounding box, 25 unit radius
        weighting = 25
        spawnTopLeft = Vector(spawnLocation.x-weighting, spawnLocation.y+weighting, spawnLocation.z)
        spawnTopRight = Vector(spawnLocation.x+weighting, spawnLocation.y+weighting, spawnLocation.z)
        spawnBotLeft = Vector(spawnLocation.x+weighting, spawnLocation.y-weighting, spawnLocation.z)
        spawnBotRight = Vector(spawnLocation.x-weighting, spawnLocation.y-weighting, spawnLocation.z)
        
        -- Ugly and checks everything I coul dthink of
        if #nearbyUnits == 0 then
            if GridNav:IsTraversable(spawnLocation) and GridNav:IsBlocked(spawnLocation) == false and GridNav:IsTraversable(spawnTopLeft) and GridNav:IsBlocked(spawnTopLeft) == false and GridNav:IsTraversable(spawnTopRight) and GridNav:IsBlocked(spawnTopRight) == false and GridNav:IsTraversable(spawnBotLeft) and GridNav:IsBlocked(spawnBotLeft) == false and GridNav:IsTraversable(spawnBotRight) and GridNav:IsBlocked(spawnBotRight) == false then
                CreateUnitByName(unitName, spawnLocation, false, nil, nil, DOTA_TEAM_NEUTRALS)
                -- This does not do what it claims to do, but seems to work, I think its made for blinking or such
                FindClearSpaceForUnit(unitname, spawnLocation, false)
                -- update unit count
                GameMode.neutralCurNum[unitName] = GameMode.neutralCurNum[unitName] + 1
                spawn = true
            end
        end
    end
end
