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
    end
end