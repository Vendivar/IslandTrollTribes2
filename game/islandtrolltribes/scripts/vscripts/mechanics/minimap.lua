-- Ping minimap with a colored icon
function PingMap(entity, pos, color, teamNumber)
    local duration = 45

    if type(color)=="table" then
        print("ERROR: function expected a color string, not this table:")
        DeepPrintTable(color)
    elseif not GameRules.UnitKV["minimap_icon_"..color] then
        print("ERROR: There is no minimap entity with the name minimap_icon_"..color,"A default white icon will be used!")
        color = "white"
    end

    local map_entity = CreateUnitByName("minimap_icon_"..color, entity:GetAbsOrigin(), false, nil, nil, teamNumber)
    map_entity:AddNewModifier(map_entity, nil, "modifier_minimap", {})

    Timers:CreateTimer(duration, function() map_entity:RemoveSelf() end)
end