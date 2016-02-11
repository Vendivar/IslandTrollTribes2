function SpiritLink (keys)
    local spellInfo = {caster = keys.caster, radius = keys.Radius, links = keys.Links, duration = keys.Duration, particle = keys.Particle}
    spellInfo.startTime = GameRules:GetGameTime()
    Timers:CreateTimer(SpiritLinkSpell, spellInfo)
end

function SpiritLinkSpell(spellInfo)
    local unitCounts, units = SelectUnits(GetNearbyAllies(spellInfo.caster, spellInfo.radius), spellInfo.links)
--    print("Number of units foun (Spirit Link): "..unitCounts)
    table.insert(units, spellInfo.caster)
    UpdateHP(units)
    if((spellInfo.startTime + spellInfo.duration) <= GameRules:GetGameTime()) then
        return nil
    end
    return 0.2
end

function UpdateHP(units)
    local particleName = "particles/units/heroes/hero_dazzle/dazzle_shadow_wave.vpcf"
    local particles = {}
    local totalHP = 0
    local averageHP = 0
    local unitCount = 0
    for _,unit in pairs(units) do
        if unit:IsAlive() then
            totalHP = totalHP + unit:GetHealth()
            unitCount =  unitCount + 1
        end
    end
    averageHP =  math.ceil(totalHP / unitCount)
--    print("Unit count: "..unitCount..", Total HP: "..totalHP..", Average HP: "..averageHP)
    for i,unit in pairs(units) do
        if unit:IsAlive() then
            unit:SetHealth(averageHP)
            local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, unit )
            ParticleManager:SetParticleControl(particle,1,Vector(unit:GetAbsOrigin().x,unit:GetAbsOrigin().y,unit:GetAbsOrigin().z+((unit:GetBoundingMaxs().z - unit:GetBoundingMins().z)/2)))
            table.insert(particles,  particle)
        end
    end
    return units
end


function SelectUnits(units, links)
    local numberOfUnitsToGet = links
--    print("Required unit count: "..numberOfUnitsToGet)
    local selectedUnits = {}
    local unitCount = 0
    for i,unit in pairs(units) do
        table.insert(selectedUnits, unit)
        unitCount = unitCount + 1
        if(unitCount == numberOfUnitsToGet) then
            break
        end
    end
    return unitCount, selectedUnits
end

function GetNearbyAllies(caster, radius)
    local units = FindUnitsInRadius(caster:GetTeamNumber(),
        caster:GetAbsOrigin(),
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )
    return ShuffledList(units)
end