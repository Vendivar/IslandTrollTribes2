function Spawn(entityKeyValues)

	thisEntity.state = "wander"		--possible states = wander, flee
	if string.find(thisEntity:GetUnitName(), "fish") then
		thisEntity.WanderDistance = 300
		thisEntity.FleeDistance = 300
		thisEntity.MinWaitTime = 15
		thisEntity.MaxWaitTime = 30
	elseif string.find(thisEntity:GetUnitName(), "hawk") then
		thisEntity.WanderDistance = 3000
		thisEntity.FleeDistance = 3000
		thisEntity.MinWaitTime = 3
		thisEntity.MaxWaitTime = 7.5
	elseif string.find(thisEntity:GetUnitName(), "fawn") or
				 string.find(thisEntity:GetUnitName(), "cub") or
				 string.find(thisEntity:GetUnitName(), "pup") then
		thisEntity.WanderDistance = 0
		thisEntity.FleeDistance = 1200
		thisEntity.MinWaitTime = 10
		thisEntity.MaxWaitTime = 30
	else
		thisEntity.WanderDistance = 1000
		thisEntity.FleeDistance = 3000
		thisEntity.MinWaitTime = 5
		thisEntity.MaxWaitTime = 20
	end
	--print("starting passive neutral ai for "..thisEntity:GetUnitName()..thisEntity:GetEntityIndex())

	thisEntity.hp = thisEntity:GetHealth()
	thisEntity.spawnTime = GameRules:GetGameTime()
	thisEntity.wander_wait_time = GameRules:GetGameTime() + 0
	thisEntity.flee_wait_time = GameRules:GetGameTime() + 0
	thisEntity.flee_times = 0
	Timers:CreateTimer(PassiveNeutralThink, thisEntity)
end

function PassiveNeutralThink(thisEntity)
	if not thisEntity:IsAlive() then
		return nil
	end

	if thisEntity.hp > thisEntity:GetHealth() then	-- WE ARE UNDER ATTACK
		thisEntity.state = "flee"
		thisEntity.hp = thisEntity:GetHealth()
	end

	if thisEntity.state == "wander" then
		if GameRules:GetGameTime() >= thisEntity.wander_wait_time then
			local newPosition = thisEntity:GetAbsOrigin() + RandomVector(thisEntity.WanderDistance)
      thisEntity:MoveToPosition(newPosition)
			thisEntity.wander_wait_time = GameRules:GetGameTime() + RandomFloat(thisEntity.MinWaitTime, thisEntity.MaxWaitTime)
		end
	elseif thisEntity.state == "flee" then
		if GameRules:GetGameTime() >= thisEntity.flee_wait_time and not thisEntity:HasModifier("modifier_spawn_chance") then
			local fleeTime = RandomFloat(thisEntity.MinWaitTime, thisEntity.MaxWaitTime)
			local item = CreateItem("item_apply_modifiers", thisEntity, thisEntity)
			item:ApplyDataDrivenModifier(thisEntity, thisEntity, "modifier_creeppanic", {duration = fleeTime})
			--thisEntity:AddNewModifier(thisEntity, thisEntity, "modifier_bloodseeker_thirst_speed", { duration = thisEntity.flee_wait_time })

			thisEntity.flee_wait_time = GameRules:GetGameTime() + fleeTime

			local newPosition = thisEntity:GetAbsOrigin() + RandomVector(thisEntity.FleeDistance)
			thisEntity:MoveToPosition(newPosition)

			thisEntity.flee_times = thisEntity.flee_times + 1
			if thisEntity.flee_times > 3 then
				thisEntity.flee_times = 0
				thisEntity.state = "wander"
			end
		end
	end

	return 0.5
end
