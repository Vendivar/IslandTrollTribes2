function Spawn(entityKeyValues)
	
	thisEntity.state = "wander"		--possible states = wander, flee
	if string.find(thisEntity:GetUnitName(), "elk") then
		thisEntity.WanderDistance = 1000
		thisEntity.FleeDistance = 2000
		thisEntity.MinWaitTime = 5
		thisEntity.MaxWaitTime = 20
	elseif string.find(thisEntity:GetUnitName(), "fish") then
		thisEntity.WanderDistance = 300
		thisEntity.FleeDistance = 300
		thisEntity.MinWaitTime = 15
		thisEntity.MaxWaitTime = 30
	elseif string.find(thisEntity:GetUnitName(), "hawk") then
		thisEntity.WanderDistance = 3000
		thisEntity.FleeDistance = 3000
		thisEntity.MinWaitTime = 3
		thisEntity.MaxWaitTime = 7.5
	end
	--print("starting passive neutral ai for "..thisEntity:GetUnitName()..thisEntity:GetEntityIndex())

	thisEntity.spawnTime = GameRules:GetGameTime()
	thisEntity.wander_wait_time = GameRules:GetGameTime() + 0
	Timers:CreateTimer(PassiveNeutralThink, thisEntity)
end

function PassiveNeutralThink(thisEntity)
	if not thisEntity:IsAlive() then
		return nil
	end

	if (thisEntity.state == "wander") then
		if GameRules:GetGameTime() >= thisEntity.wander_wait_time then
			local newPosition = thisEntity:GetAbsOrigin() + RandomVector(thisEntity.WanderDistance)
            thisEntity:MoveToPosition(newPosition)

			thisEntity.wander_wait_time = GameRules:GetGameTime() + RandomFloat(thisEntity.MinWaitTime, thisEntity.MaxWaitTime)
		end
	elseif (thisEntity.state == "flee") then
		local newPosition = thisEntity:GetAbsOrigin() + RandomVector(thisEntity.FleeDistance)
		thisEntity:MoveToPosition(newPosition)
		thisEntity.wander_wait_time = GameRules:GetGameTime() + RandomFloat(thisEntity.MinWaitTime, thisEntity.MaxWaitTime)
		thisEntity.state = "wander"
	end
	
	return 0.5
end