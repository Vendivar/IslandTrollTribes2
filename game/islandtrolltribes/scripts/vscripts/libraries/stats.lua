if not Stats then
    Stats = class({})
end

function Stats:Init()
    -- Custom Stat Values
    local HP_PER_STR = 8
    local HP_REGEN_PER_STR = 0
    local MANA_PER_INT = 8
    local MANA_REGEN_PER_INT = 0
    local ARMOR_PER_AGI = 0.1
    local ATKSPD_PER_AGI = 0

    -- Default Dota Values
    local DEFAULT_HP_PER_STR = 19
    local DEFAULT_HP_REGEN_PER_STR = 0.03
    local DEFAULT_MANA_PER_INT = 13
    local DEFAULT_MANA_REGEN_PER_INT = 0.04
    local DEFAULT_ARMOR_PER_AGI = 0.14
    local DEFAULT_ATKSPD_PER_AGI = 1

    Stats.hp_adjustment = HP_PER_STR - DEFAULT_HP_PER_STR
    Stats.hp_regen_adjustment = HP_REGEN_PER_STR - DEFAULT_HP_REGEN_PER_STR
    Stats.mana_adjustment = MANA_PER_INT - DEFAULT_MANA_PER_INT
    Stats.mana_regen_adjustment = MANA_REGEN_PER_INT - DEFAULT_MANA_REGEN_PER_INT
    Stats.armor_adjustment = ARMOR_PER_AGI - DEFAULT_ARMOR_PER_AGI
    Stats.attackspeed_adjustment = ATKSPD_PER_AGI - DEFAULT_ATKSPD_PER_AGI

    Stats.applier = CreateItem("item_stat_modifier", nil, nil)
end

function Stats:ModifyBonuses(hero)

	print("Modifying Stats Bonus of hero "..hero:GetUnitName())

	Timers:CreateTimer(function()

		if not IsValidEntity(hero) then
			return
		end

		-- Initialize value tracking
		if not hero.custom_stats then
			hero.custom_stats = true
			hero.strength = 0
			hero.agility = 0
			hero.intellect = 0
		end

		-- Get player attribute values
		local strength = hero:GetStrength()
		local agility = hero:GetAgility()
		local intellect = hero:GetIntellect()
		
        -- Bonus Class/SubClass Armor
        local baseClassArmor = (hero.subclass and 1) or -1
        local armor = agility * Stats.armor_adjustment
        hero:SetPhysicalArmorBaseValue(armor + baseClassArmor)

		-- STR
		if strength ~= hero.strength then
			
			-- HP Bonus
			if not hero:HasModifier("modifier_negative_health_bonus") then
				Stats.applier:ApplyDataDrivenModifier(hero, hero, "modifier_negative_health_bonus", {})
			end

			local health_stacks = math.abs(strength * Stats.hp_adjustment)
			hero:SetModifierStackCount("modifier_negative_health_bonus", Stats.applier, health_stacks)

			-- HP Regen Bonus
			if not hero:HasModifier("modifier_negative_health_regen_constant") then
				Stats.applier:ApplyDataDrivenModifier(hero, hero, "modifier_negative_health_regen_constant", {})
			end

			local health_regen_stacks = math.abs(strength * Stats.hp_regen_adjustment * 100)
			hero:SetModifierStackCount("modifier_negative_health_regen_constant", Stats.applier, health_regen_stacks)
		end

		-- AGI
		if agility ~= hero.agility then		

			-- Attack Speed Bonus
			if not hero:HasModifier("modifier_negative_attackspeed_bonus_constant") then
				Stats.applier:ApplyDataDrivenModifier(hero, hero, "modifier_negative_attackspeed_bonus_constant", {})
			end

			local attackspeed_stacks = math.abs(agility * Stats.attackspeed_adjustment)
			hero:SetModifierStackCount("modifier_negative_attackspeed_bonus_constant", Stats.applier, attackspeed_stacks)
		end

		-- INT
		if intellect ~= hero.intellect then
			
			-- Mana Bonus
			if not hero:HasModifier("modifier_negative_mana_bonus") then
				Stats.applier:ApplyDataDrivenModifier(hero, hero, "modifier_negative_mana_bonus", {})
			end

			local mana_stacks = math.abs(intellect * Stats.mana_adjustment)
			hero:SetModifierStackCount("modifier_negative_mana_bonus", Stats.applier, mana_stacks)

			-- Mana Regen Bonus
			if not hero:HasModifier("modifier_negative_mana_regen") then
				Stats.applier:ApplyDataDrivenModifier(hero, hero, "modifier_negative_mana_regen", {})
			end

			local mana_regen_stacks = math.abs(intellect * Stats.mana_regen_adjustment * 100)
			hero:SetModifierStackCount("modifier_negative_mana_regen", Stats.applier, mana_regen_stacks)
		end

		-- Update the stored values for next timer cycle
		hero.strength = strength
		hero.agility = agility
		hero.intellect = intellect

		hero:CalculateStatBonus()

		return 0.25
	end)
end