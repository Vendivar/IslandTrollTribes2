function Spawn(entityKeyValues)
	thisEntity:SetContextThink("skellythink", skellythink, 0.25)
	thisEntity.state = "follow"		--possible states = follow, attack
	local owner = thisEntity:GetOwner()
	--FindUnitsInRadius( iTeamNumber, vPosition, hCacheUnit, flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache)
	--find the nearest enemy in 200 range of the player controlling the skellies

	print("starting skelly ai")

	thisEntity.spawnTime = GameRules:GetGameTime()
end

function skellythink()
	local owner = thisEntity:GetOwner()
	local followAngle = thisEntity.position
	local followPosition = owner:GetOrigin() + RotatePosition(Vector(0,0,0), QAngle(0,thisEntity.position,0), owner:GetForwardVector()) * 100

	if not thisEntity:IsAlive() then
		return nil
	end

	if GameRules:GetGameTime() >= thisEntity.spawnTime + 30 then
		thisEntity:ForceKill(true)
		print("Skelly timed out")
		return nil
	end

	if (thisEntity.state == "follow") and (thisEntity:GetOrigin() ~= followPosition) then
		thisEntity:MoveToPosition(followPosition)

		local enemiesInRange = FindUnitsInRadius(
        owner:GetTeam(),
        owner:GetOrigin(),
        nil, 
        200,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_BUILDING,
        DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
        FIND_CLOSEST,
        false)

		if #enemiesInRange > 0 then
            local targetEntity = enemiesInRange[1]      
	        thisEntity:MoveToPositionAggressive(targetEntity:GetOrigin())
	        thisEntity.state = "attack"
	    end
    elseif (thisEntity.state == "attack") and ((thisEntity:GetOrigin() - owner:GetOrigin()):Length() > 250) then
    	thisEntity.state = "follow"
	end

	return 0.25
end