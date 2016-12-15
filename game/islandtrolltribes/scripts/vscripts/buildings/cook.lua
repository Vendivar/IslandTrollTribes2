function CookFood(keys)
    local building = keys.caster
    local range = keys.Range

    for _,item in pairs( Entities:FindAllByClassnameWithin("dota_item_drop", building:GetAbsOrigin(), range)) do
        local containedItem = item:GetContainedItem()
        if containedItem:GetAbilityName() == "item_meat_raw" and not containedItem.dropped then
            building:EmitSound("Hero_Lina.attack")
            local newItem = CreateItem("item_meat_cooked", nil, nil)
            CreateItemOnPositionSync(item:GetAbsOrigin(), newItem)
            UTIL_Remove(containedItem)
            UTIL_Remove(item)
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

function AutoSmokeMeat( event )
    local ability = event.ability
    local caster = event.caster


    if ability:GetAutoCastState() and ability:IsFullyCastable() then
        caster:CastAbilityNoTarget(ability, -1)
    end
end

--ability_smoke_meat
function SmokeMeat( keys )
    local building = keys.caster

    local cooked_meat = building:FindItemByName("item_meat_cooked")
    if cooked_meat then

        -- First remove the cooked meat, makes space for the smoked
        local charges = cooked_meat:GetCurrentCharges()
        if charges <= 1 then
            cooked_meat:RemoveSelf()
        else
            cooked_meat:SetCurrentCharges(charges - 1)
        end

        local smoked_meat = GiveItemStack(building, "item_meat_smoked")
        if smoked_meat then
            building:EmitSound("Hero_Lina.attack")

        -- Item can't be stacked but we just consumed a cooked meat for nothing.
        else
            print("Smoked Meat could not be created on "..building:GetUnitName())
            -- We can either ignore this or eject a smoked meat outside of the building
        end
    end
end
