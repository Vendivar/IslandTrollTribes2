function MoveDummySpotter(dummySpotter)
    if (dummySpotter.target:IsAlive() == false) then
        print("Creature with dummy spotter died, removing it")
        dummySpotter:ForceKill(true)
        return nil
    end
    dummySpotter:MoveToPosition(dummySpotter.target:GetAbsOrigin())
    if (GameRules:GetGameTime() - dummySpotter.startTime) >= dummySpotter.duration then
        dummySpotter:ForceKill(true)
        --print("spotter is kill")
        return nil
    end
    return 0.1
end