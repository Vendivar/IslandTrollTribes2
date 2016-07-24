function CureAll(keys)
    local caster = keys.caster
    local target = keys.target

    target:RemoveModifierByName("modifier_lizard_slow")
    target:RemoveModifierByName("modifier_disease1")
    target:RemoveModifierByName("modifier_disease2")
    target:RemoveModifierByName("modifier_disease3")
    target:RemoveModifierByName("modifier_lightning_shield_damage_aura")
    target:RemoveModifierByName("modifier_priest_painkillerbalm")
    target:RemoveModifierByName("modifier_priest_resistall")
    target:RemoveModifierByName("modifier_pumpup")
    target:RemoveModifierByName("modifier_rage_ability")
    target:RemoveModifierByName("modifier_molotov_burn")
    target:RemoveModifierByName("modifier_potion_nether")
    target:RemoveModifierByName("modifier_potion_nether")
    target:RemoveModifierByName("modifier_elemental_shield_damage_aura")

	caster:Purge(false, true, false, true, false)
end