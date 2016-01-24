function PotionPoisonUse(keys)
	local caster = keys.caster
	local oldItemName = keys.OldItemName
	local newItemName = keys.NewItemName
		for itemSlot = 0, 5, 1 do
		if caster ~= nil then
			local Item = killedUnit:GetItemInSlot( itemSlot )
			if Item ~= nil and Item:GetName() == oldItemName then
				local itemCharges = Item:GetCurrentCharges()
				local newItem = CreateItem(newItemName, nil, nil) 
				newItem:SetCurrentCharges(itemCharges)
				caster:RemoveItem(Item)
				caster:AddItem(itemName)
				return
			end
		end
	end
end