function CureAll(keys)
    local caster = keys.caster
    local target = keys.target

    target:RemoveModifierByName("modifier_lizard_slow")
    target:RemoveModifierByName("modifier_disease1")
    target:RemoveModifierByName("modifier_disease2")
    target:RemoveModifierByName("modifier_disease3")
end