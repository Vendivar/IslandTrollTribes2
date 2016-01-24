function CastPurge(keys)
	print("PURGE")
	local caster = keys.caster
	local target = keys.target
	if target == nil then
		target = caster
	end
	local abilityName = "ability_custom_purge"
    caster:AddAbility(abilityName)
    ab = caster:FindAbilityByName(abilityName)
    ab:SetLevel(1)
    print("trying to cast ability ", abilityName, "level", ab:GetLevel(), "on")
    caster:CastAbilityOnTarget(target, ab, -1)
    caster:RemoveAbility(abilityName)
    --dummy_caster:ForceKill(true)
end