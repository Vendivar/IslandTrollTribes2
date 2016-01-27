function CheckPosition( event )
    local caster = event.caster
    local point = event.target_points[1]

    if not BuildingHelper:ValidPosition(2, point, event) then
        caster:Interrupt()
        SendErrorMessage(caster:GetPlayerOwnerID(), "#error_invalid_build_position")
    end
end

function MakeClayExplosion(keys)
    local caster = keys.caster
    
    local dieRoll = RandomInt(0, 10)
    for i=1,dieRoll do
    
        local pos_launch = origin + RandomVector(RandomInt(1,200))
        local item = CreateItem("item_clay_living", nil, nil)
        local drop = CreateItemOnPositionSync( origin, item )
        item:LaunchLoot(false, 200, 0.75, pos_launch)
        print(dieRoll)
    end
    
end

function LivingClayPlant( keys )
	local caster = keys.caster
	local target_point = keys.target_points[1]
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Initialize the count and table
	caster.living_clay_count = caster.living_clay_count or 0
	caster.living_clay_table = caster.living_clay_table or {}

	-- Modifiers
	local modifier_living_clay = keys.modifier_living_clay
	local modifier_tracker = keys.modifier_tracker
	local modifier_caster = keys.modifier_caster
	local modifier_living_clay_invisibility = keys.modifier_living_clay_invisibility

	-- Ability variables
	local activation_time = ability:GetLevelSpecialValueFor("activation_time", ability_level) 
	local max_mines = ability:GetLevelSpecialValueFor("max_clay", ability_level) 
	local fade_time = ability:GetLevelSpecialValueFor("fade_time", ability_level)

	-- Create the land mine and apply the land mine modifier
	local living_clay = CreateUnitByName("npc_clay_living", target_point, false, nil, nil, caster:GetTeamNumber())
	ability:ApplyDataDrivenModifier(caster, living_clay, modifier_living_clay, {})

	-- Update the count and table
	caster.living_clay_count = caster.living_clay_count + 1
	table.insert(caster.living_clay_table, living_clay)

	-- If we exceeded the maximum number of mines then kill the oldest one
	if caster.living_clay_count > max_mines then
		caster.living_clay_table[1]:ForceKill(true)
	end

	-- Increase caster stack count of the caster modifier and add it to the caster if it doesnt exist
	if not caster:HasModifier(modifier_caster) then
		ability:ApplyDataDrivenModifier(caster, caster, modifier_caster, {})
	end

	caster:SetModifierStackCount(modifier_caster, ability, caster.living_clay_count)

	-- Apply the tracker after the activation time
	Timers:CreateTimer(activation_time, function()
		ability:ApplyDataDrivenModifier(caster, living_clay, modifier_tracker, {})
	end)

	-- Apply the invisibility after the fade time
	Timers:CreateTimer(fade_time, function()
		ability:ApplyDataDrivenModifier(caster, living_clay, modifier_living_clay_invisibility, {})
	end)
end

--[[Author: Pizzalol
	Date: 24.03.2015.
	Stop tracking the mine and create vision on the mine area]]
function LivingClayDeath( keys )
	local caster = keys.caster
	local unit = keys.unit
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local modifier_caster = keys.modifier_caster
	local vision_radius = ability:GetLevelSpecialValueFor("vision_radius", ability_level) 
	local vision_duration = ability:GetLevelSpecialValueFor("vision_duration", ability_level)

	-- Find the mine and remove it from the table
	for i = 1, #caster.living_clay_table do
		if caster.living_clay_table[i] == unit then
			table.remove(caster.living_clay_table, i)
			caster.living_clay_count = caster.living_clay_count - 1
			break
		end
	end

	-- Create vision on the mine position
	ability:CreateVisibilityNode(unit:GetAbsOrigin(), vision_radius, vision_duration)

	-- Update the stack count
	caster:SetModifierStackCount(modifier_caster, ability, caster.living_clay_count)
	if caster.living_clay_count < 1 then
		caster:RemoveModifierByNameAndCaster(modifier_caster, caster) 
	end
end

--[[Author: Pizzalol
	Date: 24.03.2015.
	Tracks if any enemy units are within the mine radius]]
function LivingClayTracker( keys )
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local trigger_radius = ability:GetLevelSpecialValueFor("radius", ability_level) 
	local explode_delay = ability:GetLevelSpecialValueFor("explode_delay", ability_level) 

	-- Target variables
	local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
	local target_types = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING
	local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES

	-- Find the valid units in the trigger radius
	local units = FindUnitsInRadius(target:GetTeamNumber(), target:GetAbsOrigin(), nil, trigger_radius, target_team, target_types, target_flags, FIND_CLOSEST, false) 

	-- If there is a valid unit in range then explode the mine
	if #units > 0 then
		Timers:CreateTimer(explode_delay, function()
			if target:IsAlive() then
				target:ForceKill(true) 
			end
		end)
	end
end