function Spawn(entityKeyValues)

    Timers:CreateTimer(1, function()
        thisEntity.state = "wander"     --possible states = wander, flee
        thisEntity.WanderDistance = 50
        thisEntity.FleeDistance = 20
        thisEntity.MinWaitTime = 15
        thisEntity.MaxWaitTime = 30

        --print("Started AI "..thisEntity:GetUnitName()..thisEntity:GetEntityIndex())

        thisEntity.spawnTime = GameRules:GetGameTime()
        thisEntity.wander_wait_time = GameRules:GetGameTime()
        Timers:CreateTimer(SpriteNeutralThink, thisEntity)
    end)
end

function SpriteNeutralThink(thisEntity)
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


function GetNewWaterPosition( unit )
    local distance = unit.WanderDistance
    local origin = unit:GetAbsOrigin()
    local newPosition = origin + RandomVector(distance)

    while math.abs(newPosition.x) > 8000 or math.abs(newPosition.y) > 8000 or GetGroundPosition(newPosition, unit).z > 120 do
        newPosition = origin + RandomVector(distance)
    end

    return newPosition
end