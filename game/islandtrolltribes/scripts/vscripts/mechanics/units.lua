------------------------------------------------

-- Used to drop orders of units that shouldn't be generally shared
function CDOTA_BaseNPC:IsSharedWithTeammates()
    return GameRules.UnitKV[self:GetUnitName()]["SharedWithTeammates"]==1
end

-- Returns an item handle if the item is in inventory
function CDOTA_BaseNPC:FindItemByName(item_name)
    local unit = self
    for i=0,5 do
        local item = unit:GetItemInSlot(i)
        if item and item:GetAbilityName() == item_name then
            return item
        end
    end
    return nil
end

------------------------------------------------

-- Returns Int
function GetGoldCost( unit )
    if unit and IsValidEntity(unit) then
        if unit.GoldCost then
            return unit.GoldCost
        end
    end
    return 0
end

-- Returns float
function GetBuildTime( unit )
    if unit and IsValidEntity(unit) then
        if unit.BuildTime then
            return unit.BuildTime
        end
    end
    return 0
end

function GetCollisionSize( unit )
    if unit and IsValidEntity(unit) then
        if GameRules.UnitKV[unit:GetUnitName()]["CollisionSize"] and GameRules.UnitKV[unit:GetUnitName()]["CollisionSize"] then
            return GameRules.UnitKV[unit:GetUnitName()]["CollisionSize"]
        end
    end
    return 0
end


------------------------------------------------
--                 Unit Checks                --
------------------------------------------------

-- Shortcut for all unit logic
function IsValidAlive( unit )
    return IsValidEntity(unit) and unit:IsAlive()
end

function IsFlyingUnit( unit )
    return unit:HasFlyMovementCapability()
end

------------------------------------------------

-- Goes through every ability and item, checking for any ability being channelled
function IsChanneling ( unit )
    
    for abilitySlot=0,15 do
        local ability = unit:GetAbilityByIndex(abilitySlot)
        if ability ~= nil and ability:IsChanneling() then 
            return true
        end
    end

    for itemSlot=0,5 do
        local item = unit:GetItemInSlot(itemSlot)
        if item ~= nil and item:IsChanneling() then
            return true
        end
    end

    return false
end

-- Creates the pinging particle on a unit
function CreatePingFlag(unit, color, duration, team)
    local particleNames = {"particles/custom/ping_world.vpcf","particles/custom/ping_static.vpcf" }
    local particles = {}
    for _,particleName in pairs(particleNames) do
        local particle = ParticleManager:CreateParticleForTeam(particleName, PATTACH_ABSORIGIN, unit, team)
        ParticleManager:SetParticleControl(particle, 0, unit:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle, 1, color)
        table.insert (particles,particle)
    end
    Timers:CreateTimer(DoUniqueString("ping_unit"), {callback=DestroyParticles, endTime = duration}, particles)
end

-- Destroying the particles
function DestroyParticles(particles)
    for _,particle in pairs(particles) do
        ParticleManager:DestroyParticle(particle, true)
    end
    return
end

function FindUnitsInRadiusByUnitList(unitsToSearch,center, range)
    local foundUnits = {}
    local unitListToSearch = {}
    if unitsToSearch then
        unitsToSearch = split(unitsToSearch, ",")
        for _,unitName in pairs(unitsToSearch) do
            unitListToSearch[unitName] = ""
        end
    end
    local units = Entities:FindAllByClassnameWithin("npc_dota_creature",center, range)
    for _,unit in pairs(units) do
        if (unitListToSearch[unit:GetUnitName()]) then
            table.insert(foundUnits, unit)
        end
    end
    return foundUnits
end