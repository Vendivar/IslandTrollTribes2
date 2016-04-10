function SpiritLink (keys)
    local caster = keys.caster
    local startTime = GameRules:GetGameTime()
    if not caster.spirtLinkUnits then
        caster.spirtLinkUnits = SelectUnits(GetNearbyAllies(caster, keys.Radius), caster, keys.Links)
        table.insert(caster.spirtLinkUnits, caster)
        for _,unit in pairs(caster.spirtLinkUnits) do
            keys.ability:ApplyDataDrivenModifier( caster, unit, "modifier_spiritlink", {duration = keys.Duration})
        end
    end
    Timers:CreateTimer(0.1, function()
        UpdateHP(caster.spirtLinkUnits)
        if((startTime + keys.Duration) <= GameRules:GetGameTime()) then
            caster.spirtLinkUnits = nil
            return nil
        end
        return 0.2
    end)
end

function UpdateHP(units)
    local totalHealthPercentage = 0
    for _,unit in pairs(units) do
        if unit:IsAlive() then
            local unitHealthPecerntage = (unit:GetHealth()/unit:GetMaxHealth()) * 100
            totalHealthPercentage = totalHealthPercentage + unitHealthPecerntage
        end
    end
    local averageHealthPercentage =  math.ceil(totalHealthPercentage / #units)
--    print("Unit count: "..#units..", Total HP: "..totalHealthPercentage..", Average HP: "..averageHealthPercentage)
    for _,unit in pairs(units) do
        if unit:IsAlive() then
            local newHP = (unit:GetMaxHealth()/100) * averageHealthPercentage
            unit:SetHealth(newHP)
        end
    end
    return units
end


function SelectUnits(units, caster, links)
    local numberOfUnitsToGet = links
    local selectedUnits = {}
    local unitCount = 0
    for _,unit in pairs(units) do
        if unit:GetEntityIndex() ~= caster:GetEntityIndex() then
            table.insert(selectedUnits, unit)
            unitCount = unitCount + 1
        end
        if(unitCount == numberOfUnitsToGet) then
            break
        end
    end
    return selectedUnits
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