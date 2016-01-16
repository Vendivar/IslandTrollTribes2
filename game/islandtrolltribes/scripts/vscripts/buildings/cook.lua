function CookFood(keys)
    local caster = keys.caster
    local range = keys.Range

    for _,item in pairs( Entities:FindAllByClassnameWithin("dota_item_drop", caster:GetOrigin(), range)) do
        local containedItem = item:GetContainedItem()
        if containedItem:GetAbilityName() == "item_meat_raw" then
            local newItem = CreateItem("item_meat_cooked", nil, nil)
            CreateItemOnPositionSync(item:GetAbsOrigin(), newItem)
            UTIL_RemoveImmediate(containedItem)
            UTIL_RemoveImmediate(item)
        end
    end
end

function AutoCookFood( event )
    local ability = event.ability
    local caster = event.caster

    if ability:GetAutoCastState() and ability:IsFullyCastable() then
        caster:CastAbilityNoTarget(ability, -1)
    end
end