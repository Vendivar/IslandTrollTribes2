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
    dummySpotter:SetDayTimeVisionRange(200)
    dummySpotter:SetNightTimeVisionRange(200)
    dummySpotter.startTime = GameRules:GetGameTime()
    dummySpotter.duration = dur
    dummySpotter.target = target
    dummySpotter:SetContextThink("dummy_spotter_thinker"..dummySpotter:GetEntityIndex(), MoveDummySpotter, 0.1)
end