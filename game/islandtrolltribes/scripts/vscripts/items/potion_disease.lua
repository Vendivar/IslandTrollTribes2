--The following code written by Internet Veteran, handle with care.
--It is suppose to do one of three different things after a 33% chance has succeded. Once suceeded it calls this function.
function PotionDiseaseUse(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local dieRoll = RandomInt(0, 2)
	
	print("Test your luck! " .. dieRoll)
	
	if dieRoll == 0 then
        ability:ApplyDataDrivenModifier(caster, target, "modifier_disease1", {duration = 100})
    elseif dieRoll == 1 then
        ability:ApplyDataDrivenModifier(caster, target, "modifier_disease2", { duration = 300})
    elseif dieRoll == 2 then
        ability:ApplyDataDrivenModifier(caster, target, "modifier_disease3", { duration = 150})
    end

	-- Change meat to diseased
	for i=0,5 do
		local item = target:GetItemInSlot(i)
		if item then
			local itemName = item:GetAbilityName()
			if itemName == "item_meat_cooked" then
				local charges = item:GetCurrentCharges()
				UTIL_Remove(item)
				local newItem = target:AddItem(CreateItem("item_meat_diseased", target, target))
				newItem:SetCurrentCharges(charges)
			end
		end
	end
end

function SpendCharge( event )
    local caster = event.caster
    local origin = caster:GetAbsOrigin()
    origin.z = -128
    local item = event.ability

    local charges = item:GetCurrentCharges()
    if charges <= 1 then
    	caster:DropItemAtPositionImmediate(item, origin)
    	item:GetContainer():SetAbsOrigin(Vector(-8000,-8000,0))
    else
    	item:SetCurrentCharges(charges-1)
    end
end

function Remove( event )
    local item = event.ability
    local charges = item:GetCurrentCharges()

    if charges == 0 then
    	item:GetContainer():RemoveSelf()
    end
end


function DiseaseFoodThinker (keys)

	local target = keys.target
	
	-- Change meat to diseased
		for i=0,5 do
			local item = target:GetItemInSlot(i)
			if item then
				local itemName = item:GetAbilityName()
				if itemName == "item_meat_cooked" then
					local charges = item:GetCurrentCharges()
					UTIL_Remove(item)
					local newItem = target:AddItem(CreateItem("item_meat_diseased", target, target))
					newItem:SetCurrentCharges(charges)
				end
			end
		end
	end
	
function SpreadDisease2(keys)
    local radius = 250
    local duration = 300
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
    local teamNumber = target:GetTeamNumber()
    local targetOrigin = target:GetOrigin()
    local units = FindUnitsInRadius(teamNumber, targetOrigin, nil, radius,  DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)

end
	
function SpreadDisease3(keys)
    local radius = 250
    local duration = 150
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
    local teamNumber = target:GetTeamNumber()
    local targetOrigin = target:GetOrigin()
    local units = FindUnitsInRadius(teamNumber, targetOrigin, nil, radius,  DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)


end

	