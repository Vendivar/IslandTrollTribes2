function TrackUnit(keys)
    local ability = keys.ability
    --print("level required to upgrade: "..ability:GetHeroLevelRequiredToUpgrade())
    local caster = keys.caster
    local target = keys.target
    local targetName = target:GetName()
    local dur = tonumber(keys.Duration)
    if (string.find(targetName,"hero") == nil) then --if the target's name does not include "hero", ie an animal
        dur = 30.0
    end

    local dummySpotter = CreateUnitByName("dummy_spotter", target:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
    dummySpotter:SetDayTimeVisionRange(0)
    dummySpotter:SetNightTimeVisionRange(0)
    dummySpotter.startTime = GameRules:GetGameTime()
    dummySpotter.duration = dur
    dummySpotter.target = target
    dummySpotter.isTrackingBeaconDummy = true
    
    Timers:CreateTimer(MoveDummySpotter, dummySpotter)
end

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