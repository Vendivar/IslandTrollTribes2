function DepressionOrbStart( event )
    local ability = event.ability
    local caster = event.caster
    local point = event.target_points[1]


    ability.start_pos = caster:GetAbsOrigin()
    ability.start_time = GameRules:GetGameTime()

    local targetDirection = ( ( point - ability.start_pos ) * Vector(1,1,0) ):Normalized()
    ability.proj_velocity = targetDirection * event.proj_speed
end

function DepressionOrbHit( event )
    local ability = event.ability
    local caster = event.caster
    local target = event.target
    local targetLocation = target:GetAbsOrigin()

    local depress = event.depress
    local modifier = event.modifier
    local depressModifier = event.depress_modifier
    local depressManaModifier = event.depress_mana_modifier
    local manaLoss = event.mana
    local dur = event.duration

    local elapsed = GameRules:GetGameTime() - ability.start_time

    local orbLocation = ability.start_pos + ability.proj_velocity * elapsed
    local distanceFromOrb = math.sqrt(math.pow(orbLocation.x - targetLocation.x, 2) + math.pow(orbLocation.y - targetLocation.y, 2))

    local distanceFromOrb = distanceFromOrb - 25 --the value seems to be offset by about 25 units, likly due to using caster location as starting location.

    if distanceFromOrb <= event.radius_small + 25 then
        target:RemoveModifierByName("modifier_depress")
        target:RemoveModifierByName("modifier_depress_mana_loss")
        target:ReduceMana(manaLoss)
        ability:ApplyDataDrivenModifier(caster, target, modifier, {duration = dur})
    else
        local dummy = CreateUnitByName("dummy_caster", orbLocation, false, caster, caster, caster:GetTeam())
        dummy:AddAbility(depress)
        local depressAbility = dummy:FindAbilityByName(depress)
        depressAbility:SetLevel(1)
        Timers:CreateTimer(0.1, function()
            dummy:CastAbilityOnTarget(target, depressAbility, -1)
            return
        end)
        Timers:CreateTimer(1, function()
            return
        end)
    end
end

function DepressionAura( event )
    local target = event.target
    local minMana = event.mana_loss_min
    local maxMana = event.mana_loss_max

    local mana = RandomInt(minMana, maxMana)
    target:ReduceMana(mana)
end