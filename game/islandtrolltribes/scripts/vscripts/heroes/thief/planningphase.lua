function ToggleAbility(keys)
    local caster = keys.caster
    local abilityName = keys.Ability

    if caster:HasAbility(abilityName) then
        local ability = caster:FindAbilityByName(abilityName)
        ability:SetActivated(not ability:IsActivated())
    end
end

function IncreaseVision( event )
    local caster = event.caster
    local ability = event.ability
    local increase = 150
    local radius = 150
    local team = caster:GetTeamNumber()
    local origin = caster:GetAbsOrigin()

    StartAnimation(caster, {duration=1, activity=ACT_DOTA_ATTACK, rate=1, translate="masquerade"})

    Timers:CreateTimer(1, function()
        if ability and ability:IsChanneling() then
            StartAnimation(caster, {duration=1, activity=ACT_DOTA_ATTACK, rate=1, translate="masquerade"})
            
            AddFOWViewer ( team, origin, radius, 1.1, false)

            local units = FindUnitsInRadius(team, origin, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
            for k,v in pairs(units) do
                ability:ApplyDataDrivenModifier(caster, v, "modifier_thief_reveal_vision", {duration=1.5})
            end

            radius = radius + increase
            return 1
        end
    end)
end