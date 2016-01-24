--The following code written by Internet Veteran, handle with care.
--It is suppose to do one of three different things after a 33% chance has succeded. Once suceeded it calls this function.
function PotionDiseaseUse(keys)
	local caster = keys.caster
	local target = keys.target
	local dieRoll = RandomInt(0, 2)
	
	print("Test your luck! " .. dieRoll)
	
	if dieRoll == 0 then
		target:AddNewModifier(caster, nil, "modifier_disease1", { duration = 100})
	elseif dieRoll == 1 then
		target:AddNewModifier(caster, nil, "modifier_disease2", { duration = 300})
	elseif dieRoll == 2 then
		target:AddNewModifier(caster, nil, "modifier_disease3", { duration = 150})
	end
end