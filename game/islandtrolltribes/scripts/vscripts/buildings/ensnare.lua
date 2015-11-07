function CastTrap( event )
    local ability = event.ability
    local caster = event.caster
    local target = event.target_entities and event.target_entities[1]

    if target and ability:GetAutoCastState() and ability:IsFullyCastable() then
        -- Cast ability on target
        caster:CastAbilityOnTarget(target, ability, -1)
    end
end

function AutocastOn( event )
    local ability = event.ability
    ability:ToggleAutoCast()
end