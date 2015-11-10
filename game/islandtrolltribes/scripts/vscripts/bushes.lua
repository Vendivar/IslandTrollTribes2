function ITT:CreateBushContainers()
  for k,bush in pairs(GameRules.Bushes) do
    CreateLootBox(bush)
  end
end

function RandomItem(owner)
  local id = RandomInt(1,29)
  local name = Containers.itemIDs[id]
  print(name)
  return CreateItem(name, owner, owner)
end

function CreateLootBox(loc)
  local phys = loc
  local items = {}
  local slots = {1,2,3,4}
  for i=1,RandomInt(1,3) do
    items[table.remove(slots, RandomInt(1,#slots))] = RandomItem()
  end

  local cont = Containers:CreateContainer({
    layout =      {2,2},
    --skins =       {"Hourglass"},
    headerText =  "Loot Box",
    buttons =     {"Take All"},
    position =    "entity", --"mouse",--"900px 200px 0px",
    OnEmptyAndClosed = function(container)
      print("Empty and closed")
      container:GetEntity():RemoveSelf()
      container:Delete()
      loc.container = nil

      Timers:CreateTimer(7, function()
        CreateLootBox(loc)
      end)
    end,
    closeOnOrder= true,
    items = items,
    entity = phys,
    range = 150,
    OnButtonPressed = function(playerID, unit, container, button, buttonName)
      if button == 1 then
        local items = container:GetAllItems()
        for _,item in ipairs(items) do
          container:RemoveItem(item)
          Containers:AddItemToUnit(unit,item)
        end

        container:Close(playerID)
      end
    end,
  })

  Containers:SetEntityOrderAction(phys, {
    range = 150,
    action = function(playerID, unit, target)
      print("ORDER ACTION loot box: ", playerID)
      cont:Open(playerID)
      unit:Stop()
    end,
  })

  loc.container = cont
  loc.phys = phys
end