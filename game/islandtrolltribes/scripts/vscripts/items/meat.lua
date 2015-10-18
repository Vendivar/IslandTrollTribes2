function EatMeatRaw(keys)   --triggers the meat eating channel ability
    ---[[
    local caster = keys.caster
    local abilityName = "ability_item_eat_meat_raw"
    local ability = caster:FindAbilityByName(abilityName)
    if ability == nil then
        caster:AddAbility(abilityName)
        ability = caster:FindAbilityByName( abilityName )
        ability:SetLevel(1)     
    end
    print("trying to cast ability ", abilityName)
    caster:CastAbilityNoTarget(ability, -1)
    --caster:RemoveAbility(abilityName)
    --]]
end

function EatMeat( event )
    local ability = event.ability
    local caster = event.caster
    local heal = event.heal_amount

    if caster:HasModifier("modifier_priest_increasemetabolism") then
        if ability:GetName() == "ability_item_eat_meat_raw" then
            caster:Heal(1, caster)
        else
            caster:Heal(10, caster)
        end
    end
    caster:Heal(heal, caster)
end

function EatCookedMeat( event )
end