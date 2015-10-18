function DysenteryTrackUnit(keys)
    local ability = keys.ability
    --print("level required to upgrade: "..ability:GetHeroLevelRequiredToUpgrade())
    local caster = keys.caster
    local target = keys.target
    local targetName = target:GetName()
    local dur = tonumber(keys.Duration)
    local trailFadeTime = tonumber(keys.TrailFadeTime)
    caster.dysenteryStartTime = GameRules:GetGameTime()
    caster.dysenteryDur = dur
    caster.dysenteryParticleTable = {}
    caster.dysenteryTarget = target
    caster:SetContextThink(target:GetEntityIndex().."dysenteryThink", DysenteryTrackThink, 0.75)
    caster:SetContextThink(target:GetEntityIndex().."dysenteryParticleThink", DysenteryParticleThink, trailFadeTime)
end

function DysenteryTrackThink(caster)
    local target = caster.dysenteryTarget
    print("create track")
    local thisParticle = ParticleManager:CreateParticleForPlayer("particles/econ/courier/courier_trail_fungal/courier_trail_fungal_f.vpcf", PATTACH_ABSORIGIN, caster, caster:GetPlayerOwner())
    table.insert(caster.dysenteryParticleTable, thisParticle)
    ParticleManager:SetParticleControl(thisParticle, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(thisParticle, 15, Vector(139,69,19))

    if (GameRules:GetGameTime() - caster.dysenteryStartTime) >= caster.dysenteryDur then
        return nil
    end

    return 0.75
end

function DysenteryParticleThink(caster)
    --kills the first particle of the table, then deletes it from table, shifting other values down
    particle = caster.dysenteryParticleTable[1]
    if particle == nil then
        return nil
    end
    ParticleManager:DestroyParticle(particle,false)
    ParticleManager:ReleaseParticleIndex(particle)
    table.remove(caster.dysenteryParticleTable, 1)
    return 0.75
end