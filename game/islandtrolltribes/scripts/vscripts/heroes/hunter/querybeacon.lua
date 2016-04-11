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
    CreatePingFlag(trackingUnit, trackingUnit.flagColor, particleLifeTime, trackingUnit:GetTeamNumber())
    PingUnitInMap(trackingUnit, trackingUnit.mapEntityColor, particleLifeTime, trackingUnit:GetTeamNumber())
    return 1.5
end

function FindTrackingUnits(caster, range)
    local trackingUnits = {}
    local foundUnits
    local units = Entities:FindAllByClassnameWithin("npc_dota_creature", caster:GetAbsOrigin(), range)
    for _,unit in pairs(units) do
        if (unit:GetUnitName()=="dummy_spotter" and unit.isTrackingBeaconDummy ) then
            --            print("Unit found")
            table.insert(trackingUnits, unit)
            foundUnits = true
        end
    end
    return trackingUnits, foundUnits
end