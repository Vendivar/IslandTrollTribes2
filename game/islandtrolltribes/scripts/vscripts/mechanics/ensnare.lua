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

function ElectroMagnetStart(keys)
    local caster = keys.caster
    local target = keys.target
    local pfx = keys.pfx
    target.pull_pfx = ParticleManager:CreateParticle(pfx, PATTACH_POINT_FOLLOW, caster)
    Timers:CreateTimer(DrawEnsnareParticle, target)
end

function DrawEnsnareParticle(target)
    local particleLifeTime = 1.0
    if not target:IsAlive() or not target:HasModifier("modifier_ensnare") then
        return nil
    end
    if HasUnitMoved(target) then
        if target.ensnareParticle then
            ParticleManager:DestroyParticle(target.ensnareParticle, false)
        end
        target.ensnareParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_meepo/meepo_earthbind.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    end
    return particleLifeTime
end

function HasUnitMoved(target)
    local hasMoved =  false
    local currentPosition = target:GetAbsOrigin()
    local oldPosition = target.oldPosition
    if not oldPosition or (oldPosition.x ~= currentPosition.x or oldPosition.y ~=  currentPosition.y or oldPosition.z ~=  currentPosition.z) then
        target.oldPosition = currentPosition
        hasMoved = true
    end
    return hasMoved
end

function ElectroMagnetThink(keys)
    local caster = keys.caster
    local origin = caster:GetAbsOrigin()
    local target = keys.target
    local targetPosition = target:GetAbsOrigin()
    local minimumPullRange = keys.min_range
    local pullMultiplier = keys.pull_scale
    local difference = origin - targetPosition
    if math.sqrt( math.pow(difference.x, 2 ) + math.pow( difference.y, 2 ) ) > minimumPullRange then
        local displacement = difference:Normalized() * pullMultiplier
        target:SetAbsOrigin( targetPosition + displacement )
        FindClearSpaceForUnit( target, target:GetAbsOrigin(), true )
    end
    ParticleManager:SetParticleControl(target.pull_pfx, 1, Vector( targetPosition.x, targetPosition.y, targetPosition.z + ( target:GetBoundingMaxs().z - target:GetBoundingMins().z ) / 2 ) )
end

function ElectroMagnetEnd(keys)
    local target = keys.target
    ParticleManager:DestroyParticle(target.pull_pfx, false)
    ParticleManager:DestroyParticle(target.ensnareParticle, false)
end
