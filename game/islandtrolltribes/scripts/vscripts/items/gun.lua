function GunBlowCheckEmpty(keys)
    local caster = keys.caster
    local item = keys.ability

    if item:GetCurrentCharges() <= 0 then
        local emptyGun = CreateItem("item_gun_blow_empty", nil, nil)
        caster:RemoveItem(item)
        caster:AddItem(emptyGun)
    end
end