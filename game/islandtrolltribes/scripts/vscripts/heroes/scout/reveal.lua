function Reveal( event )
    local caster = event.caster
    local ability = event.ability
    local level = ability:GetLevel()
    local duration = ability:GetSpecialValueFor("duration")

    local dummy = CreateUnitByName("dummy_caster_reveal"..level, caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
    Timers:CreateTimer(duration, function() dummy:RemoveSelf() end)
end