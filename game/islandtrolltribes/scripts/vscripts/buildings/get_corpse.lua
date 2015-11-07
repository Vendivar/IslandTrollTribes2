function GetCorpses( event )
    local ability = event.ability
    local caster = event.caster
    local range = ability:GetCastRange()

    local meatStacks = GetCurrentMeatRawStacks(caster)
    if (meatStacks < 10) then
        local drops = Entities:FindAllByClassnameWithin("dota_item_drop", caster:GetAbsOrigin(), range)

        for k,drop in pairs(drops) do
            if (meatStacks < 10) then
                local item = drop:GetContainedItem()
                local itemName = item:GetAbilityName()

                if itemName == "item_meat_raw" then
                    local hasMeat = GetMeatRawStack(caster)
                    if hasMeat then
                        local charges = item:GetCurrentCharges()
                        if charges + meatStacks <= 10 then
                            drop:RemoveSelf()
                            hasMeat:SetCurrentCharges(charges+meatStacks)
                            meatStacks = meatStacks + charges
                        else
                            hasMeat:SetCurrentCharges(10)
                            item:SetCurrentCharges(charges - (10-meatStacks))
                            return
                        end
                    else
                        caster:AddItem(item)
                        meatStacks = item:GetCurrentCharges()
                        drop:RemoveSelf()
                    end
                end
            end
        end
    end
end

function GetCorpseAutocast( event )
    local ability = event.ability
    local caster = event.caster

    if ability:GetAutoCastState() and ability:IsFullyCastable() then
        caster:CastAbilityNoTarget(ability, -1)
    end
end

function FillSlots( event )
    local unit = event.caster

    local lockN = 5
    for n=0,4 do
        unit:AddItem(CreateItem("item_slot_locked", nil, nil))
        unit:SwapItems(0, lockN)
        lockN = lockN-1
    end
end

function GetMeatRawStack( unit )
    for i=0,5 do
        local item = unit:GetItemInSlot(i)
        if item and item:GetAbilityName() == "item_meat_raw" then
            return item
        end
    end
    return nil
end

function GetCurrentMeatRawStacks( unit )
    local meat = GetMeatRawStack(unit)
    if not meat then
        return 0
    else
        return meat:GetCurrentCharges()
    end
end