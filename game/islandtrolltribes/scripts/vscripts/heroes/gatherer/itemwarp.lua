function WarpItems(keys)
    local caster = keys.caster
    local range  = keys.Range
    local itemList = {"item_tinder", "item_flint", "item_stone", "item_stick", "item_bone", "item_meat_raw", "item_crystal_mana", "item_clay_ball", "item_river_root", "item_river_stem", "item_thistles", "item_acorn", "item_acorn_magic", "item_mushroom" }
    for _,item in pairs(itemList) do
        itemList[item] = ""
    end
    local itemsDrops = Entities:FindAllByClassnameWithin("dota_item_drop", caster:GetAbsOrigin(), range)
    for _,itemDrop in pairs(itemsDrops) do
        local item = itemDrop:GetContainedItem()
        local itemName = item:GetAbilityName()
        if itemList[itemName] then
            local itemPosition = caster:GetAbsOrigin() + RandomVector(RandomInt(100,150))
            itemDrop:SetOrigin(itemPosition)
        end
    end
end
