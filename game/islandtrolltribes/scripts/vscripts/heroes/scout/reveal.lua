function Reveal( event )
    local caster = event.caster
    local ability = event.ability
    local level = ability:GetLevel()
    if ability:GetAbilityName() == ability_scout_greaterreveal then level = 4 end
    local duration = ability:GetSpecialValueFor("duration")

    local dummy = CreateUnitByName("dummy_reveal"..level, caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
    Timers:CreateTimer(duration, function() dummy:RemoveSelf() end)
end