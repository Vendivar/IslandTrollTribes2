function Reveal( event )
    local caster = event.caster
    local ability = event.ability
    local duration = ability:GetSpecialValueFor("duration")
    local radius = ability:GetSpecialValueFor("radius")

    local dummy = CreateUnitByName("dummy_reveal", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
    dummy:SetDayTimeVisionRange(radius)
    dummy:SetNightTimeVisionRange(radius)
    Timers:CreateTimer(duration, function() dummy:RemoveSelf() end)
end