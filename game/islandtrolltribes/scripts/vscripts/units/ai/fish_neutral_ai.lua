function Spawn(entityKeyValues)

    Timers:CreateTimer(1, function()
        -- Check the fish has spawned in the water
        if thisEntity:GetAbsOrigin().z > 120 then
            print("ERROR: Fish spawned over the acceptable height, stoping")
            thisEntity:RemoveSelf()
            return
        end

        thisEntity:SetContextThink("fish_neutral_ai_think"..thisEntity:GetEntityIndex(), FishNeutralThink, 0.5)
        thisEntity.state = "wander"     --possible states = wander, flee
        thisEntity.WanderDistance = 300
        thisEntity.FleeDistance = 300
        thisEntity.MinWaitTime = 15
        thisEntity.MaxWaitTime = 30

        --print("Started AI "..thisEntity:GetUnitName()..thisEntity:GetEntityIndex())

        thisEntity.spawnTime = GameRules:GetGameTime()
        thisEntity.wander_wait_time = GameRules:GetGameTime()
    end)
end

function FishNeutralThink()
    if not thisEntity:IsAlive() then
        return nil
    end

    if GameRules:GetGameTime() >= thisEntity.wander_wait_time then
        local newPosition = GetNewWaterPosition(thisEntity)
        thisEntity:MoveToPosition(newPosition)
        thisEntity.wander_wait_time = GameRules:GetGameTime() + RandomFloat(thisEntity.MinWaitTime, thisEntity.MaxWaitTime)
    end
    
    return 0.5
end

-- Keep fish on land
function GetNewWaterPosition( unit )
    local distance = unit.WanderDistance
    local origin = unit:GetAbsOrigin()
    local newPosition = origin + RandomVector(distance)

    while math.abs(newPosition.x) > 8000 or math.abs(newPosition.y) > 8000 or GetGroundPosition(newPosition, unit).z > 120 do
        newPosition = origin + RandomVector(distance)
    end

    return newPosition
end