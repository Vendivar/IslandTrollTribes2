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
    local diseased_meat = building:FindItemByName("item_meat_diseased")
    local meat_to_smoke = cooked_meat

    -- Prioritize smoking diseased meat over cooked meat
    if diseased_meat then
        meat_to_smoke = diseased_meat
    end

    if meat_to_smoke then
        -- First remove the cooked meat, makes space for the smoked
        local charges = meat_to_smoke:GetCurrentCharges()
        if charges <= 1 then
            meat_to_smoke:RemoveSelf()
        else
            meat_to_smoke:SetCurrentCharges(charges - 1)
        end

        local smoked_meat = GiveItemStack(building, "item_meat_smoked")
        building:EmitSound("Hero_Lina.attack")
        if not smoked_meat then
            -- Item can't be stacked but we just consumed a cooked meat for nothing.
            print("Smoked Meat could not be created on "..building:GetUnitName())
            -- We can either ignore this or eject a smoked meat outside of the building
            -- Alternatively: check for cooked meat, attempt to give the building a smoked meat, and only take a cooked meat if a smoked one was given
            -- Eject a smoked meat, since we took a cooked one
            local item = CreateItem("item_meat_smoked", nil, nil)
            local loc = building:GetAbsOrigin() + RandomVector(200)
            DropLaunch(building, item, 0.5, loc)
        end
    end
end
