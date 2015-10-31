-- Single heal instance from cooked/smoked meat
function EatMeat( event )
    local ability = event.ability
    local caster = event.caster
    local heal = event.Heal

    if caster:HasModifier("modifier_priest_increasemetabolism") then
        heal = health + 25
    end

    caster:Heal(heal, caster)
    PopupHealing(caster, heal)
end