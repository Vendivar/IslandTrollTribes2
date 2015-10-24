function EatMeatRaw(keys)   --triggers the meat eating channel ability
    local caster = keys.caster
    local abilityName = "eat_meat"
    local ability = caster:FindAbilityByName(abilityName)

    if not ability then
        TeachAbility("eat_meat", 1)  
    end

    caster:CastAbilityNoTarget(ability, -1)
end

function EatMeat( event )
    local ability = event.ability
    local caster = event.caster
    local heal = event.heal_amount

    if caster:HasModifier("modifier_priest_increasemetabolism") then
        if ability:GetName() == "eat_meat" then
            caster:Heal(1, caster)
        else
            caster:Heal(10, caster)
        end
    end
    caster:Heal(heal, caster)
end

function EatCookedMeat( event )
end