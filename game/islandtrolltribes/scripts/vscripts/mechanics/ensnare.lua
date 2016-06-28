function LoseMovement( event )
    local target = event.target
    local bFlying = target:HasFlyMovementCapability()
    if bFlying then
        target.flying = true
        target:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
        local origin = target:GetAbsOrigin()
        origin.z = origin.z - 128
        target:SetAbsOrigin(origin)
    end
end

function RegainMovement( event )
    local target = event.target
    if target.flying and target:IsAlive() then
        target:SetMoveCapability(DOTA_UNIT_CAP_MOVE_FLY)
EscapeAttackers( target )
    end
end

function EscapeAttackers( flyingTarget )
    local targetPosition = flyingTarget:GetAbsOrigin()
    local units = FindUnitsInRadius(flyingTarget:GetTeamNumber(),
        targetPosition,
        nil,
        250,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false)
    for _,unit in pairs (units) do
        if unit:IsAttacking()  and unit:GetAttackTarget():GetEntityIndex() == flyingTarget:GetEntityIndex() then
            unit:Stop()
        end
    end
end