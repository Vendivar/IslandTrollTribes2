function CookFood(keys)
    local building = keys.caster
    local range = keys.Range

    for _,item in pairs( Entities:FindAllByClassnameWithin("dota_item_drop", building:GetAbsOrigin(), range)) do
        local containedItem = item:GetContainedItem()
        if containedItem:GetAbilityName() == "item_meat_raw" then
            building:EmitSound("Hero_Lina.attack")
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

    if ability:GetAutoCastState() and ability:IsFullyCastable() and ability:IsActivated() then
        ability:CastAbility()
    end
end

--ability_smoke_meat
function SmokeMeat( event )
    local building = event.caster

    local cooked_meat = building:FindItemByName("item_meat_cooked")
    if cooked_meat then
        building:EmitSound("Hero_Lina.attack")
        local charges = cooked_meat:GetCurrentCharges()
        cooked_meat:RemoveSelf()

        local smoked_meat = CreateItem("item_meat_smoked", nil, nil)
        building:AddItem(smoked_meat)
        smoked_meat:SetCurrentCharges(charges)
    end
end