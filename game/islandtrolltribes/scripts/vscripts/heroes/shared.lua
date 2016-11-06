function DropAllItems(event)
  local hero = event.caster

  for i=0,5 do
      local item = hero:GetItemInSlot(i)
      if item and item:GetName() ~= "item_slot_locked" then
          local pos = hero:GetAbsOrigin() + RandomVector(RandomFloat(50,50))
          hero:DropItemAtPositionImmediate(item, hero:GetAbsOrigin())
          DropLaunch(hero, item, 0.5, pos)
      end
  end

  hero:Stop()
end
