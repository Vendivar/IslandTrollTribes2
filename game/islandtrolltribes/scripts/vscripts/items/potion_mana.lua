function PotionManaUse(keys)
	local caster = keys.caster

	local startingMana = caster:GetMana()
	caster:SetMana(startingMana + keys.ManaRestored)
end