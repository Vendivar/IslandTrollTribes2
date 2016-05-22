function JealousyStart( event )
    local ability = event.ability
    local target = event.target
    ability.target_of_ability = target
end

function Jealousy( event )
    local ability = event.ability
    local target_of_ability = ability.target_of_ability
    local target = event.target

    target:SetForceAttackTarget(nil)
    target_of_ability:SetForceAttackTarget(nil)

    if target_of_ability:IsAlive() and target_of_ability ~= target then
        local order = 
        {
            UnitIndex = target:entindex(),
            OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
            TargetIndex = target_of_ability:entindex()
        }

        ExecuteOrderFromTable(order)
    else
        target:RemoveModifierByName(event.modifier)
    end

    target:SetForceAttackTarget(target_of_ability)
end

function JealousyEnd( event )
    local target = event.target
    local ability = event.ability
    local target_of_ability = ability.target_of_ability
    target:SetForceAttackTarget(nil)
    target_of_ability:SetForceAttackTarget(nil)
end