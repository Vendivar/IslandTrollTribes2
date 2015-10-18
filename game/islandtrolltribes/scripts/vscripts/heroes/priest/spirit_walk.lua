function SpiritWalkStart( event )
    ability = event.ability
    caster = event.caster
    target = event.target
    vision = event.vision

    ability.day_vision = caster:GetDayTimeVisionRange()
    ability.night_vision = caster:GetNightTimeVisionRange()
    caster:SetDayTimeVisionRange(vision)
    caster:SetNightTimeVisionRange(vision)

    target:SetControllableByPlayer(caster:GetMainControllingPlayer(), true)
 --SetOverrideSelectionEntity(int nPlayerID, handle hEntity) ????
    ability.spirit = target
    ability.caster_origin = caster:GetAbsOrigin()
end

function SpiritWalkThink( event )
    ability = event.ability
    caster = event.caster
    casterOrigin = ability.caster_origin
    spiritOrigin = ability.spirit:GetAbsOrigin()
    
    difference = math.sqrt(math.pow(spiritOrigin.x - casterOrigin.x, 2) + math.pow(spiritOrigin.y - casterOrigin.y, 2))

    energyRate = event.energy_rate
    perUnit = event.per_unit
    manaSpent = difference / perUnit * energyRate

    caster:SetMana( caster:GetMana() - manaSpent )
end

function SpiritWalkEnd( event )
    damage = event.attack_damage
    if damage > 10 or damage == -1 then
        ability = event.ability
        ability.spirit:ForceKill(true)
        caster = event.caster
        caster:RemoveModifierByName("modifier_priest_spiritwalk")
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_stunned", {duration=0.1})
        caster:SetDayTimeVisionRange(ability.day_vision)
        caster:SetNightTimeVisionRange(ability.night_vision)
    end
end
