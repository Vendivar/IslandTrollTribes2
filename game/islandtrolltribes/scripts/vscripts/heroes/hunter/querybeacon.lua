function PingUnitsInRange(event)
    local caster = event.caster
    local range =  event.ability:GetCastRange()
    local trackingDuration = event.Duration
    local flagColor = Vector(255, 255, 255) --white
    local mapEntityColor = "white"
    local trackingUnits,foundUnits = FindTrackingUnits(caster, range)

    if foundUnits then
        EmitSoundOnLocationForAllies(caster:GetAbsOrigin(), "General.Ping", caster)
        for _,trackingUnit in pairs(trackingUnits) do
            trackingUnit.flagColor = flagColor
            trackingUnit.mapEntityColor = mapEntityColor
            trackingUnit.tracingEndTime = GameRules:GetGameTime() + trackingDuration
            Timers:CreateTimer(DoUniqueString("ping_unit"), {callback=StartPinging}, trackingUnit)
        end
    end
end


function StartPinging(trackingUnit)
    --    print("Tracking :"..trackingUnit:GetEntityIndex())
    local particleLifeTime = 1.2
    if(trackingUnit:IsAlive() == false or GameRules:GetGameTime() >= trackingUnit.tracingEndTime ) then
        return nil
    end
    CreateFlag(trackingUnit, trackingUnit.flagColor, particleLifeTime)
    PingUnitInMap(trackingUnit, trackingUnit.mapEntityColor, particleLifeTime)
    return 1.5
end

function FindTrackingUnits(caster, range)
    local trackingUnits = {}
    local foundUnits
    local units = Entities:FindAllByClassnameWithin("npc_dota_creature", caster:GetAbsOrigin(), range)
    for _,unit in pairs(units) do
        if (unit:GetUnitName()=="dummy_spotter" and unit.isTrackingDummy ) then
            --            print("Unit found")
            table.insert(trackingUnits, unit)
            foundUnits = true
        end
    end
    return trackingUnits, foundUnits
end

function CreateFlag(unit, color, duration)
    local particleNames = {"particles/custom/ping_world.vpcf","particles/custom/ping_static.vpcf" }
    local particles = {}
    for _,particleName in pairs(particleNames) do
        local particle = ParticleManager:CreateParticleForTeam(particleName, PATTACH_ABSORIGIN, unit, unit:GetTeamNumber())
        ParticleManager:SetParticleControl(particle, 0, unit:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle, 1, color)
        table.insert (particles,particle)
    end
    Timers:CreateTimer(DoUniqueString("ping_unit"), {callback=DestroyParticle, endTime = duration}, particles)
end

function DestroyParticle(particles)
    for _,particle in pairs(particles) do
        ParticleManager:DestroyParticle(particle, true)
    end
    return
end

function PingUnitInMap(map_entity, color, duration)
    local map_entity = CreateUnitByName("minimap_icon_"..color, map_entity:GetAbsOrigin(), false, nil, nil, map_entity:GetTeamNumber())
    map_entity:AddNewModifier(map_entity, nil, "modifier_minimap", {})
    Timers:CreateTimer(duration, function() map_entity:RemoveSelf() end)
end