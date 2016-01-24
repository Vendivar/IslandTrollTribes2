function CloakProtectFail(keys)
	local caster = keys.caster
	local attackingUnit = keys.attacker
	print(attackingUnit:GetName(), attackingUnit:GetAverageTrueAttackDamage())

	local damageTable = {
		victim = caster,
		attacker = attackingUnit,
		damage = attackingUnit:GetAverageTrueAttackDamage(),
		damage_type = DAMAGE_TYPE_PHYSICAL}						

		ApplyDamage(damageTable)
end