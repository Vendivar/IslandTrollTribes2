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