--[[
	Some tips:
	Make sure you add your units first somewhere in your code before adding any buildings, or else the units won't be checked for collision:
	BuildingHelper:AddUnit(heroEntity)
	Put BuildingHelper:BlockGridNavSquares(nMapLength) in your InitGameMode function.
	If units are getting stuck put "BoundsHullName"   "DOTA_HULL_SIZE_TOWER" for buildings in npc_units_custom.txt
]]

BUILD_TIME_10 = 10.0
BUILD_TIME_5 = 5.0
BUILD_TIME_7 = 7.0
BUILD_TIME_12 = 12.0
BUILD_TIME_13 = 13.0
BUILD_TIME_30 = 30.0
function getCampFirePoint(keys)
	print("making fire")
	local itemName = tostring(keys.ability:GetAbilityName())
	local caster = keys.caster
	local point = BuildingHelper:AddBuildingToGrid(keys.target_points[1], 2, caster)
	if point ~= -1 then
		local Campfire = CreateUnitByName("npc_building_fire_basic", point, false, nil, nil, caster:GetTeam())
		local campfireBuildTime = BUILD_TIME_10
		BuildingHelper:AddBuilding(Campfire)
		Campfire:UpdateHealth(campfireBuildTime,true,1.0)
		Campfire:SetHullRadius(64)
		Campfire:SetFireEffect(nil) 
		Campfire:SetControllableByPlayer( caster:GetPlayerID(), true )

		for itemSlot = 0, 5, 1 do
			local Item = caster:GetItemInSlot( itemSlot )
			if Item ~= nil and Item:GetName() == itemName then
				caster:RemoveItem(Item)
				return
			end
		end
	else
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerID(), _error = "Can't build here" } )
	end
end
function getMageFirePoint(keys)
	local point = BuildingHelper:AddBuildingToGrid(keys.target_points[1], 2, keys.caster)
	local itemName = tostring(keys.ability:GetAbilityName())
	local caster = keys.caster
	if point ~= -1 then
		local Magefire = CreateUnitByName("npc_building_fire_mage", point, false, nil, nil, caster:GetTeam())
		BuildingHelper:AddBuilding(Magefire)
		Magefire:UpdateHealth(BUILD_TIME_10,true,1.0)
		Magefire:SetHullRadius(64)
		Magefire:SetFireEffect(nil) 
		Magefire:SetControllableByPlayer( caster:GetPlayerID(), true )
		for itemSlot = 0, 5, 1 do
			local Item = caster:GetItemInSlot( itemSlot )
			if Item ~= nil and Item:GetName() == itemName then
			caster:RemoveItem(Item)
			return
		end
		end
	else
	end
end
function getTentPoint(keys)
	local itemName = tostring(keys.ability:GetAbilityName())
	local caster = keys.caster
	local point = BuildingHelper:AddBuildingToGrid(keys.target_points[1], 2, caster)
	if point ~= -1 then
		local Tent = CreateUnitByName("npc_building_tent", point, false, nil, nil, caster:GetTeam())
		BuildingHelper:AddBuilding(Tent)
		Tent:UpdateHealth(BUILD_TIME_7,true,1.0)
		Tent:SetHullRadius(64)
		Tent:SetFireEffect(nil) 
		Tent:SetControllableByPlayer( caster:GetPlayerID(), true )
		for itemSlot = 0, 5, 1 do
			local Item = caster:GetItemInSlot( itemSlot )
			if Item ~= nil and Item:GetName() == itemName then
			caster:RemoveItem(Item)
			return
		end
		end
	else
	end
end
function getTrollHutPoint(keys)
	local itemName = tostring(keys.ability:GetAbilityName())
	local caster = keys.caster
	local point = BuildingHelper:AddBuildingToGrid(keys.target_points[1], 2, caster)
	if point ~= -1 then
		local Hut = CreateUnitByName("npc_building_hut_troll", point, false, nil, nil, caster:GetTeam())
		BuildingHelper:AddBuilding(Hut)
		Hut:UpdateHealth(BUILD_TIME_10,true,.5)
		Hut:SetHullRadius(64)
		Hut:SetFireEffect(nil) 
		Hut:SetControllableByPlayer( caster:GetPlayerID(), true )
		for itemSlot = 0, 5, 1 do
			local Item = caster:GetItemInSlot( itemSlot )
			if Item ~= nil and Item:GetName() == itemName then
			caster:RemoveItem(Item)
			return
		end
		end
	else
	end
end
function getMudHutPoint(keys)
	local itemName = tostring(keys.ability:GetAbilityName())
	local caster = keys.caster
	local point = BuildingHelper:AddBuildingToGrid(keys.target_points[1], 2, caster)
	if point ~= -1 then
		local Mud_Hut = CreateUnitByName("npc_building_hut_mud", point, false, nil, nil, caster:GetTeam())
		BuildingHelper:AddBuilding(Mud_Hut)
		Mud_Hut:UpdateHealth(BUILD_TIME_10,true,1.0)
		Mud_Hut:SetHullRadius(64)
		Mud_Hut:SetFireEffect(nil) 
		Mud_Hut:SetControllableByPlayer( caster:GetPlayerID(), true )
		for itemSlot = 0, 5, 1 do
			local Item = caster:GetItemInSlot( itemSlot )
			if Item ~= nil and Item:GetName() == itemName then
			caster:RemoveItem(Item)
			return
		end
		end
	else
	end
end
function getChestPoint(keys)
	local itemName = tostring(keys.ability:GetAbilityName())
	local caster = keys.caster
	local point = BuildingHelper:AddBuildingToGrid(keys.target_points[1], 2, caster)
	if point ~= -1 then
		local Chest = CreateUnitByName("npc_building_storage_chest", point, false, nil, nil, caster:GetTeam())
		BuildingHelper:AddBuilding(Chest)
		Chest:UpdateHealth(BUILD_TIME_12,true,.6)
		Chest:SetHullRadius(64)
		Chest:SetFireEffect(nil) 
		Chest:SetControllableByPlayer( caster:GetPlayerID(), true )
		for itemSlot = 0, 5, 1 do
			local Item = caster:GetItemInSlot( itemSlot )
			if Item ~= nil and Item:GetName() == itemName then
			caster:RemoveItem(Item)
			return
		end
		end
	else
	end
end
function getSmokePoint(keys)
	local itemName = tostring(keys.ability:GetAbilityName())
	local caster = keys.caster
	local point = BuildingHelper:AddBuildingToGrid(keys.target_points[1], 2, caster)
	if point ~= -1 then
		local Smoke = CreateUnitByName("npc_building_smoke_house", point, false, nil, nil, caster:GetTeam())
		BuildingHelper:AddBuilding(Smoke)
		Smoke:UpdateHealth(BUILD_TIME_10,true,.6)
		Smoke:SetHullRadius(64)
		Smoke:SetFireEffect(nil) 
		Smoke:SetControllableByPlayer( caster:GetPlayerID(), true )
		for itemSlot = 0, 5, 1 do
			local Item = caster:GetItemInSlot( itemSlot )
			if Item ~= nil and Item:GetName() == itemName then
				caster:RemoveItem(Item)
				return
			end
		end
	else
	end
end
function getArmoryPoint(keys)
	local itemName = tostring(keys.ability:GetAbilityName())
	local caster = keys.caster
	local point = BuildingHelper:AddBuildingToGrid(keys.target_points[1], 2, caster)
	if point ~= -1 then
		local Armory = CreateUnitByName("npc_building_armory", point, false, nil, nil, caster:GetTeam())
		BuildingHelper:AddBuilding(Armory)
		Armory:UpdateHealth(BUILD_TIME_10,true,.4)
		Armory:SetHullRadius(64)
		Armory:SetFireEffect(nil) 
		Armory:SetControllableByPlayer( caster:GetPlayerID(), true )
		for itemSlot = 0, 5, 1 do
			local Item = caster:GetItemInSlot( itemSlot )
			if Item ~= nil and Item:GetName() == itemName then
			caster:RemoveItem(Item)
			return
		end
		end
	else
	end
end
function getTanneryPoint(keys)
	local itemName = tostring(keys.ability:GetAbilityName())
	local caster = keys.caster
	local point = BuildingHelper:AddBuildingToGrid(keys.target_points[1], 2, caster)
	if point ~= -1 then
		local Tannery = CreateUnitByName("npc_building_tannery", point, false, nil, nil, caster:GetTeam())
		BuildingHelper:AddBuilding(Tannery)
		Tannery:UpdateHealth(BUILD_TIME_10,true,.7)
		Tannery:SetHullRadius(64)
		Tannery:SetFireEffect(nil) 
		Tannery:SetControllableByPlayer( caster:GetPlayerID(), true )
		for itemSlot = 0, 5, 1 do
			local Item = caster:GetItemInSlot( itemSlot )
			if Item ~= nil and Item:GetName() == itemName then
			caster:RemoveItem(Item)
			return
		end
		end
	else
	end
end
function getWorkshopPoint(keys)
	local itemName = tostring(keys.ability:GetAbilityName())
	local caster = keys.caster
	local point = BuildingHelper:AddBuildingToGrid(keys.target_points[1], 2, caster)
	if point ~= -1 then
		local Workshop = CreateUnitByName("npc_building_workshop", point, false, nil, nil, caster:GetTeam())
		BuildingHelper:AddBuilding(Workshop)
		Workshop:UpdateHealth(BUILD_TIME_13,true,.8)
		Workshop:SetHullRadius(64)
		Workshop:SetFireEffect(nil) 
		Workshop:SetControllableByPlayer( caster:GetPlayerID(), true )
		for itemSlot = 0, 5, 1 do
			local Item = caster:GetItemInSlot( itemSlot )
			if Item ~= nil and Item:GetName() == itemName then
			caster:RemoveItem(Item)
			return
		end
		end
	else
	end
end
function getWDHutPoint(keys)
	local itemName = tostring(keys.ability:GetAbilityName())
	local caster = keys.caster
	local point = BuildingHelper:AddBuildingToGrid(keys.target_points[1], 2, caster)
	if point ~= -1 then
		local WDHut = CreateUnitByName("npc_building_hut_witch_doctor", point, false, nil, nil, caster:GetTeam())
		BuildingHelper:AddBuilding(WDHut)
		WDHut:UpdateHealth(BUILD_TIME_10,true,.7)
		WDHut:SetHullRadius(64)
		WDHut:SetFireEffect(nil) 
		WDHut:SetControllableByPlayer( caster:GetPlayerID(), true )
		for itemSlot = 0, 5, 1 do
			local Item = caster:GetItemInSlot( itemSlot )
			if Item ~= nil and Item:GetName() == itemName then
			caster:RemoveItem(Item)
			return
		end
		end
	else
	end
end
function getMixingPotPoint(keys)
	local itemName = tostring(keys.ability:GetAbilityName())
	local caster = keys.caster
	local point = BuildingHelper:AddBuildingToGrid(keys.target_points[1], 2, caster)
	if point ~= -1 then
		local Pot = CreateUnitByName("npc_building_mix_pot", point, false, nil, nil, caster:GetTeam())
		BuildingHelper:AddBuilding(Pot)
		Pot:UpdateHealth(BUILD_TIME_10,true,1.2)
		Pot:SetHullRadius(64)
		Pot:SetFireEffect(nil) 
		Pot:SetControllableByPlayer( caster:GetPlayerID(), true )
		for itemSlot = 0, 5, 1 do
			local Item = caster:GetItemInSlot( itemSlot )
			if Item ~= nil and Item:GetName() == itemName then
			caster:RemoveItem(Item)
			return
		end
		end
	else
	end
end
function getOmnitowerPoint(keys)
	local itemName = tostring(keys.ability:GetAbilityName())
	local caster = keys.caster
	local point = BuildingHelper:AddBuildingToGrid(keys.target_points[1], 2, caster)
	if point ~= -1 then
		local omnitower = CreateUnitByName("npc_building_omnitower", point, false, nil, nil, caster:GetTeam())
		BuildingHelper:AddBuilding(omnitower)
		omnitower:UpdateHealth(BUILD_TIME_10,true,.6)
		omnitower:SetHullRadius(64)
		omnitower:SetFireEffect(nil) 
		omnitower:SetControllableByPlayer( caster:GetPlayerID(), true )
		for itemSlot = 0, 5, 1 do
			local Item = caster:GetItemInSlot( itemSlot )
			if Item ~= nil and Item:GetName() == itemName then
			caster:RemoveItem(Item)
			return
		end
		end
	else
	end
end
function getTrapPoint(keys)
	local itemName = tostring(keys.ability:GetAbilityName())
	local caster = keys.caster
	local point = BuildingHelper:AddBuildingToGrid(keys.target_points[1], 2, caster)
	if point ~= -1 then
		local Trap = CreateUnitByName("npc_building_ensnare_trap", point, false, nil, nil, caster:GetTeam())
		BuildingHelper:AddBuilding(Trap)
		Trap:UpdateHealth(BUILD_TIME_10,true,.5)
		Trap:SetHullRadius(64)
		Trap:SetFireEffect(nil) 
		Trap:SetControllableByPlayer( caster:GetPlayerID(), true )
		for itemSlot = 0, 5, 1 do
			local Item = caster:GetItemInSlot( itemSlot )
			if Item ~= nil and Item:GetName() == itemName then
			caster:RemoveItem(Item)
			return
		end
		end
	else
	end
end
function getWardPoint(keys)
	local itemName = tostring(keys.ability:GetAbilityName())
	local caster = keys.caster
	local point = BuildingHelper:AddBuildingToGrid(keys.target_points[1], 2, caster)
	if point ~= -1 then
		local Ward = CreateUnitByName("npc_building_spirit_ward", point, false, nil, nil, caster:GetTeam())
		BuildingHelper:AddBuilding(Ward)
		Ward:UpdateHealth(BUILD_TIME_30,true,1.1)
		Ward:SetHullRadius(64)
		Ward:SetFireEffect(nil) 
		Ward:SetControllableByPlayer( caster:GetPlayerID(), true )
		for itemSlot = 0, 5, 1 do
			local Item = caster:GetItemInSlot( itemSlot )
			if Item ~= nil and Item:GetName() == itemName then
			caster:RemoveItem(Item)
			return
		end
		end
	else
	end
end
function getTeleportPoint(keys)
	local itemName = tostring(keys.ability:GetAbilityName())
	local caster = keys.caster
	local point = BuildingHelper:AddBuildingToGrid(keys.target_points[1], 2, caster)
	if point ~= -1 then
		local Teleport = CreateUnitByName("npc_building_teleport_beacon", point, false, nil, nil, caster:GetTeam())
		BuildingHelper:AddBuilding(Teleport)
		Teleport:UpdateHealth(BUILD_TIME_10,true,1.0)
		Teleport:SetHullRadius(64)
		Teleport:SetFireEffect(nil) 
		Teleport:SetControllableByPlayer( caster:GetPlayerID(), true )
		for itemSlot = 0, 5, 1 do
			local Item = caster:GetItemInSlot( itemSlot )
			if Item ~= nil and Item:GetName() == itemName then
			caster:RemoveItem(Item)
			return
		end
		end
	else
	end
end
function getHatcheryPoint(keys)
	local itemName = tostring(keys.ability:GetAbilityName())
	local caster = keys.caster
	local point = BuildingHelper:AddBuildingToGrid(keys.target_points[1], 2, caster)
	if point ~= -1 then
		local hatchery = CreateUnitByName("npc_building_hatchery", point, false, nil, nil, caster:GetTeam())
		BuildingHelper:AddBuilding(hatchery)
		hatchery:UpdateHealth(BUILD_TIME_10,true,.8)
		hatchery:SetHullRadius(64)
		hatchery:SetFireEffect(nil) 
		hatchery:SetControllableByPlayer( caster:GetPlayerID(), true )
		for itemSlot = 0, 5, 1 do
			local Item = caster:GetItemInSlot( itemSlot )
			if Item ~= nil and Item:GetName() == itemName then
			caster:RemoveItem(Item)
			return
		end
		end
	else
	end
end
--[[function getHardFarmPoint(keys)
	local caster = keys.caster
	local point = BuildingHelper:AddBuildingToGrid(keys.target_points[1], 4, caster)
	if point == -1 then
		-- Refund the cost.
		caster:SetGold(caster:GetGold()+HARD_FARM_COST, false)
		--Fire a game event here and use Actionscript to let the player know he can't place a building at this spot.
		return
	else
		caster:SetGold(caster:GetGold()-5, false)
		local farm = CreateUnitByName("npc_hard_farm", point, false, nil, nil, caster:GetTeam())
		BuildingHelper:AddBuilding(farm)
		farm:UpdateHealth(BUILD_TIME,true,.8)
		farm:SetHullRadius(128)
		farm:SetControllableByPlayer( caster:GetPlayerID(), true )
	end
end]]