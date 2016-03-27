function PackUp( event )
    local building = event.caster
    local unitName = building:GetUnitName()
    local buildingName = string.gsub(unitName, "npc_building_", "")
    local itemName = "item_building_kit_"..buildingName

    print("Packing up "..buildingName.." into "..itemName)
    local position = building:GetAbsOrigin()
    local itemKit = CreateItem(itemName, nil, nil)
    CreateItemOnPositionSync(position, itemKit)
    itemKit:LaunchLoot(false, 200, 0.5, position)

    BuildingHelper:RemoveBuilding(building, true)
    building:AddNoDraw()
end