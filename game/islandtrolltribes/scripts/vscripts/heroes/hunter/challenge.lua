function Challenge( event )
    local caster = event.caster
    local target = event.target

    target:SetForceAttackTarget(nil)

    if caster:IsAlive() then
        local order = 
        {
            UnitIndex = target:entindex(),
            OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
            TargetIndex = caster:entindex()
        }

        ExecuteOrderFromTable(order)
    else
        target:Stop()
    end

    target:SetForceAttackTarget(caster)
end

function ChallengeEnd( event )
    local target = event.target

    target:SetForceAttackTarget(nil)
end