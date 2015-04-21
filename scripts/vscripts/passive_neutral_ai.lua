function Spawn(entityKeyValues)
	thisEntity:SetContextThink("passive_neutral_ai_think"..thisEntity:GetEntityIndex(), PassiveNeutralThink, 0.5)
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
end

function PassiveNeutralThink()
	if not thisEntity:IsAlive() then
		return nil
	end

	if (thisEntity.state == "wander") then
		if GameRules:GetGameTime() >= thisEntity.wander_wait_time then
			local newPosition = thisEntity:GetAbsOrigin() + RandomVector(thisEntity.WanderDistance)
            -- Keep fish on land
            if string.find(thisEntity:GetUnitName(), "fish") then
                -- Use an if so fish don't crash it if they spawn in a bad spot
                if newPosition.x > 8000 or newPosition.x < -8000 or newPosition.y > 8000 or newPosition.y < -8000 or newPosition.z < 130 then
                    newPosition = thisEntity:GetAbsOrigin() + RandomVector(thisEntity.WanderDistance)
                end
            else
                while newPosition.x > 8000 or newPosition.x < -8000 or newPosition.y > 8000 or newPosition.y < -8000 do
                    newPosition = thisEntity:GetAbsOrigin() + RandomVector(thisEntity.WanderDistance)
                end
            end
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