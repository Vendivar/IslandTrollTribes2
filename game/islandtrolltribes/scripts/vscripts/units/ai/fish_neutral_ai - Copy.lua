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
