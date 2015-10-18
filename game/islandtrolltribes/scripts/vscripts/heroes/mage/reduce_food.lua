function ReduceFood(keys)
    local target = keys.target
    local reduction = RandomInt(0,2)

    for i=0,5 do
        local item = target:GetItemInSlot(i)
        if item ~= nil then
            local itemName = target:GetItemInSlot(i):GetName()
            if itemName == "item_meat_cooked" then
                local charges = item:GetCurrentCharges()
                local newCharges = charges-reduction
                if newCharges < 1 then
                    item:SetCurrentCharges(1)
                else
                    item:SetCurrentCharges(newCharges)
                end
                break
            end
        end
    end
end
