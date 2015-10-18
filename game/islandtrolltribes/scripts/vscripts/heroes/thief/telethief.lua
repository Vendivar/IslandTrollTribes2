function TeleThiefStart( event )
    local ability = event.ability
    local caster = event.caster
    local target = event.target

    local modifier = event.modifier
    local manaCost = event.mana_cost
    local dur = event.duration

    if string.find(target:GetUnitName(), "building_fire") then
        caster.fire_location = target:GetAbsOrigin()
        caster.radius = event.radius
        caster:RemoveModifierByName(modifier)
        ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = dur})
    else
        caster:GiveMana(manaCost)
        ability:EndCooldown()
    end
end