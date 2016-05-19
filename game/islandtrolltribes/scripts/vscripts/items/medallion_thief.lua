function checkClass(keys)
	local hero = keys.caster
	local item = keys.ability
	local heroName = hero:GetName()
	local heroClass = hero:GetHeroClass()
	local isSubClass = hero:HasSubClass()
	--print("equipped thief medallion " .. unitName)
	--print("hero is a " .. heroClass .. " and has subclass " .. hero:GetSubClass() .. " " .. tostring(isSubClass))
	if heroClass == "thief" and not isSubClass then
		--print("hero is a basic thief")
		item:ApplyDataDrivenModifier(hero, hero, "modifier_medallion_thief", {})
	else
		--print("hero is not a basic thief")
		item:ApplyDataDrivenModifier(hero, hero, "modifier_medallion_thief_false", {})
	end
end

function rollEffects(keys)
	local hero = keys.caster
	local item = keys.ability
	local percentChance = item:GetSpecialValueFor("percent_chance")
	local roll = RandomFloat(0,100)
	--print("rolling thief medallion on hit " .. roll)
	if roll <= percentChance then
		--print("Successful thief medallion roll! " .. roll)
		local rollForEffect = RandomInt(1,3)
		if rollForEffect == 1 then
			--print("thief medallion cloak")
			castCloak(keys)
		elseif rollForEffect == 2 then
			--print("thief medallion smoke")
			castSmoke(keys)
		else
			--print("thief medallion stomp")
			castStomp(keys)
		end
	end
end

function castCloak(keys)
	local hero = keys.caster
	local item = keys.ability
	local dummyCaster = CreateUnitByName("dummy_caster", hero:GetOrigin(), false, hero, hero, hero:GetTeamNumber())
	local dummyAbility = dummyCaster:AddAbility("ability_thief_cloak_medallion")
	dummyAbility:SetLevel(1)
	Timers:CreateTimer(0.1, function()
            dummyCaster:CastAbilityOnTarget(hero, dummyAbility, -1)
            return
        end)
	Timers:CreateTimer(1.0, function()
            dummyCaster:RemoveSelf()
            return
        end)
end

function castSmoke(keys)
	local hero = keys.caster
	local item = keys.ability
	local dummyCaster = CreateUnitByName("dummy_caster_pacifyingsmoke", hero:GetOrigin(), false, hero, hero, hero:GetTeamNumber())
	Timers:CreateTimer(4.0, function()
            dummyCaster:RemoveSelf()
            return
        end)
end

function castStomp(keys)
	local hero = keys.caster
	local item = keys.ability
	local dummyCaster = CreateUnitByName("dummy_caster", hero:GetOrigin(), false, hero, hero, hero:GetTeamNumber())
	local dummyAbility = dummyCaster:AddAbility("ability_thief_stomp_medallion")
	dummyAbility:SetLevel(1)
	Timers:CreateTimer(0.1, function()
            dummyCaster:CastAbilityNoTarget(dummyAbility, -1)
            return
        end)
	Timers:CreateTimer(1.0, function()
            dummyCaster:RemoveSelf()
            return
        end)
end

function checkForMedallion(keys)
	local hero = keys.caster
	local item = keys.ability
	--print("checking for medallion")
	if not hero:HasItemInInventory("item_medallion_thief") then
		--print("no medallion in inventory")
		hero:RemoveModifierByName("modifier_medallion_thief")
		hero:RemoveModifierByName("modifier_medallion_thief_false")
	end
	--print("has medallion")
end
