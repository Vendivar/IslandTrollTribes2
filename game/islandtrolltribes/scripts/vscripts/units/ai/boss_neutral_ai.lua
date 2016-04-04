function Spawn(entityKeyValues)

	thisEntity.state = "wander"		--possible states = wander, attack, sleep, flee
	thisEntity.WanderDistance = 300
	thisEntity.FleeDistance = 300
	--print("starting aggressive neutral ai for "..thisEntity:GetUnitName()..thisEntity:GetEntityIndex())

	thisEntity.spawnTime = GameRules:GetGameTime()
	thisEntity.wander_wait_time = GameRules:GetGameTime() + 0	
    thisEntity.fight_wait_time = GameRules:GetGameTime() + 0	
	thisEntity.FleeDistance = 1000
	thisEntity.MinWaitTime = 15 
	thisEntity.MaxWaitTime = 30
    thisEntity.MinFightWaitTime = 10
    thisEntity.MaxFightWaitTime = 20
    thisEntity.Home = thisEntity:GetAbsOrigin()
    thisEntity.Pregame=0;
	Timers:CreateTimer(BossNeutralThink, thisEntity)
end

function distance(vec1,vec2) 
 	return math.sqrt((vec1.x-vec2.x)^2 + (vec1.y-vec2.y)^2 + (vec1.z-vec2.z)^2) 
end

function BossNeutralThink( thisEntity )
	if not thisEntity:IsAlive() then
		return nil
	end

	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        -- Will not run until pregame ends
        if thisEntity:HasModifier("modifier_mammoth_passive") then
        	thisEntity:RemoveModifierByName("modifier_mammoth_passive")
			thisEntity:RemoveAbility("ability_mammoth_passive_invul")
		end
    end

	if (thisEntity.state == "wander") then
		local targets = FindUnitsInRadius(
                            thisEntity:GetTeam(),
                            thisEntity:GetOrigin(),
                            nil, 300,
                            DOTA_UNIT_TARGET_TEAM_ENEMY,
                            DOTA_UNIT_TARGET_ALL,
                            DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
                            FIND_CLOSEST,
                            false)

		if #targets > 0 then
			--print(targets[1]:GetUnitName())
			thisEntity:MoveToTargetToAttack(targets[1])
            thisEntity.fight_wait_time = GameRules:GetGameTime() + RandomFloat(thisEntity.MinFightWaitTime, thisEntity.MaxFightWaitTime)
			thisEntity.state = "attack"
			--print("wander -> attack")
		end
		
		if distance(thisEntity.Home,thisEntity:GetAbsOrigin()) > 1100 then
			thisEntity:MoveToPosition(thisEntity.Home)
			thisEntity.state = "wander"
		end

		if GameRules:GetGameTime() >= thisEntity.wander_wait_time then
			thisEntity:MoveToPosition(thisEntity.Home)
			thisEntity.wander_wait_time = GameRules:GetGameTime() + RandomFloat(thisEntity.MinWaitTime, thisEntity.MaxWaitTime)
		end

		if not GameRules:IsDaytime() then
			local abilityName = "ability_neutral_sleep"
            local ability = thisEntity:FindAbilityByName(abilityName)
            if ability == nil then
                thisEntity:AddAbility(abilityName)
                ability = thisEntity:FindAbilityByName( abilityName )
                ability:SetLevel(1)
            end
            ability:ApplyDataDrivenModifier(thisEntity, thisEntity, "modifier_sleep", {duration = -1})

			thisEntity.state = "sleep"
			print("wander -> sleep")
		end
	elseif (thisEntity.state == "attack") then
		-- if you get 450 out, break attack
        local targets = FindUnitsInRadius(
                            thisEntity:GetTeam(),
                            thisEntity:GetOrigin(),
                            nil, 450,
                            DOTA_UNIT_TARGET_TEAM_ENEMY,
                            DOTA_UNIT_TARGET_ALL,
                            DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
                            FIND_CLOSEST,
                            false)

		if #targets == 0 then
            --print("breaking for distance")
            thisEntity.state = "wander"
        
        -- Also only chase for a limited duration
        elseif (GameRules:GetGameTime() > thisEntity.fight_wait_time) then
            --print("breaking for time")
            thisEntity.state = "wander"
        end
        
        
	elseif (thisEntity.state == "sleep") then
		--sleeping
		if GameRules:IsDaytime() then
			thisEntity:RemoveModifierByName("modifier_sleep")
			thisEntity.state = "wander"
			print("sleep -> wander")
			return 0.05
		end

		local targets = FindUnitsInRadius(
                            thisEntity:GetTeam(),
                            thisEntity:GetOrigin(),
                            nil, 300,
                            DOTA_UNIT_TARGET_TEAM_ENEMY,
                            DOTA_UNIT_TARGET_ALL,
                            DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
                            FIND_CLOSEST,
                            false)

		if #targets > 0 then
			--print(targets[1]:GetUnitName())
			thisEntity:RemoveModifierByName("modifier_sleep")
			thisEntity:MoveToTargetToAttack(targets[1])
            thisEntity.fight_wait_time = GameRules:GetGameTime() + RandomFloat(thisEntity.MinFightWaitTime, thisEntity.MaxFightWaitTime)
			thisEntity.state = "attack"
			print("wander -> attack")
		end

        elseif (thisEntity.state == "flee") then
            --not currently used, aggressive neutrals fight until dead
            local newPosition = thisEntity:GetAbsOrigin() + RandomVector(thisEntity.FleeDistance)
            thisEntity:MoveToPosition(newPosition)
            thisEntity.wander_wait_time = GameRules:GetGameTime() + RandomFloat(thisEntity.MinWaitTime, thisEntity.MaxWaitTime)
            thisEntity.state = "wander"
        end
    
	return 0.5
end