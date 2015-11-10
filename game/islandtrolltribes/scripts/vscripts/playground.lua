function RandomItem(owner)
  local id = RandomInt(1,29)
  local name = Containers.itemIDs[id]
  return CreateItem(name, owner, owner)
end

function CreateLootBox(loc)
  local phys = CreateItemOnPositionSync(loc:GetAbsOrigin(), nil)
  phys:SetForwardVector(Vector(0,-1,0))
  phys:SetModelScale(1.5)

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

function CreateShop(ii)
  local sItems = {}
  local prices = {}
  local stocks = {}

  for _,i in ipairs(ii) do
    item = CreateItem(i[1], unit, unit)
    local index = item:GetEntityIndex()
    sItems[#sItems+1] = item
    if i[2] ~= nil then prices[index] = i[2] end
    if i[3] ~= nil then stocks[index] = i[3] end
  end

  return sItems, prices, stocks
end

function GameMode:OpenInventory(args)
  local pid = args.PlayerID
  pidInventory[pid]:Open(pid)
end

function GameMode:DefaultInventory(args)
  local pid = args.PlayerID
  local hero = PlayerResource:GetSelectedHeroEntity(pid)

  local di = defaultInventory[pid]
  local msg = "Default Inventory Set To Container Inventory"
  if di then
    Containers:SetDefaultInventory(hero, nil)
    defaultInventory[pid] = false
    msg = "Default Inventory Set To DOTA Inventory"
  else
    Containers:SetDefaultInventory(hero, pidInventory[pid])
    defaultInventory[pid] = true
  end

  Notifications:Top(pid, {text=msg,duration=5})
end

function GameMode:OFPL()
  -- register listeners
  CustomGameEventManager:RegisterListener("OpenInventory", Dynamic_Wrap(GameMode, "OpenInventory"))
  CustomGameEventManager:RegisterListener("DefaultInventory", Dynamic_Wrap(GameMode, "DefaultInventory"))
  --CustomGameEventManager:RegisterListener("Containers_EntityShopRange", Dynamic_Wrap(Containers, "Containers_EntityShopRange"))
  --CustomGameEventManager:RegisterListener("Containers_EntityShopRange", Dynamic_Wrap(Containers, "Containers_EntityShopRange"))

  Containers:SetDisableItemLimit(true)

  -- create initial stuff
  lootSpawns = Entities:FindAllByName("loot_spawn")
  itemDrops = Entities:FindAllByName("item_drops")
  contShopRadEnt = Entities:FindByName(nil, "container_shop_radiant")
  contShopDireEnt = Entities:FindByName(nil, "container_shop_dire")
  privateBankEnt = Entities:FindByName(nil, "private_bank")
  sharedBankEnt = Entities:FindByName(nil, "shared_bank")
  itemShopEnt = Entities:FindByName(nil, "item_shop")


  privateBankEnt = CreateItemOnPositionSync(privateBankEnt:GetAbsOrigin(), nil)
  privateBankEnt:SetModel("models/props_debris/merchant_debris_chest002.vmdl")
  privateBankEnt:SetModelScale(1.8)
  privateBankEnt:SetForwardVector(Vector(-1,0,0))

  Containers:SetEntityOrderAction(privateBankEnt, {
    range = 250,
    action = function(playerID, unit, target)
      print("ORDER ACTION private bank: ", playerID)
      if privateBank[playerID] then
        privateBank[playerID]:Open(playerID)
      end
      unit:Stop()
    end,
  })

  local all = {}
  for i=0,23 do all[#all+1] = i end


  sharedBankEnt = CreateItemOnPositionSync(sharedBankEnt:GetAbsOrigin(), nil)
  sharedBankEnt:SetModel("models/props_debris/merchant_debris_chest001.vmdl")
  sharedBankEnt:SetModelScale(2.3)
  sharedBankEnt:SetForwardVector(Vector(-1,0,0))

  sharedBank = Containers:CreateContainer({
      layout =      {6,4,4,6},
      headerText =  "Shared Bank",
      pids =        all,
      position =    "entity", --"600px 400px 0px",
      entity =      sharedBankEnt,
      closeOnOrder= true,
      range =       230,
  })

  Containers:SetEntityOrderAction(sharedBankEnt, {
    range = 230,
    action = function(playerID, unit, target)
      print("ORDER ACTION shared bank: ", playerID)
      sharedBank:Open(playerID)
      unit:Stop()
    end,
  })


  itemShopEnt = CreateItemOnPositionSync(itemShopEnt:GetAbsOrigin(), nil)
  itemShopEnt:SetModel("models/props_gameplay/treasure_chest001.vmdl")
  itemShopEnt:SetModelScale(2.7)
  itemShopEnt:SetForwardVector(Vector(-1,0,0))

  local ii = {}
  for i=0,RandomInt(4,8) do
    local inner = {Containers.itemIDs[RandomInt(1,29)], RandomInt(8,200)*10}
    if RandomInt(0,1) == 1 then
      inner[3] = RandomInt(3,15)
    end

    table.insert(ii, inner)
  end

  local sItems,prices,stocks = CreateShop(ii)

  itemShop = Containers:CreateShop({
       layout =      {3,3,3},
       skins =       {},
       headerText =  "Item Shop",
       pids =        {},
       position =    "entity", --"1000px 300px 0px",
       entity =      itemShopEnt,
       items =       sItems,
       prices =      prices,
       stocks =      stocks,
       closeOnOrder= true,
       range =       230,
    })

  Containers:SetEntityOrderAction(itemShopEnt, {
    container = itemShop,
    action = function(playerID, unit, target)
      print("ORDER ACTION item shop", playerID)
      itemShop:Open(playerID)
      unit:Stop()
    end,
    })


  contShopRadEnt = CreateUnitByName("npc_dummy_unit", contShopRadEnt:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_GOODGUYS)
  contShopRadEnt:AddNewModifier(viper, nil, "modifier_shopkeeper", {})
  contShopRadEnt:SetModel("models/heroes/ancient_apparition/ancient_apparition.vmdl")
  contShopRadEnt:SetOriginalModel("models/heroes/ancient_apparition/ancient_apparition.vmdl")
  contShopRadEnt:StartGesture(ACT_DOTA_IDLE)
  contShopRadEnt:SetForwardVector(Vector(1,0,0))

  sItems,prices,stocks = CreateShop({
    {"item_quelling_blade", 150, 3},
    {"item_quelling_blade"},
    {"item_clarity"},
    {"item_bfury", 9000},
  })

  sItems[3]:SetCurrentCharges(2)

  contRadiantShop = Containers:CreateShop({
       layout =      {2,2,2,2,2},
       skins =       {},
       headerText =  "Radiant Shop",
       pids =        {},
       position =    "entity", --"1000px 300px 0px",
       entity =      contShopRadEnt,
       items =       sItems,
       prices =      prices,
       stocks =      stocks,
       closeOnOrder= true,
       range =       300,
    })

  Containers:SetEntityOrderAction(contShopRadEnt, {
    container = contRadiantShop,
    action = function(playerID, unit, target)
      print("ORDER ACTION radiant shop", playerID)
      if PlayerResource:GetTeam(playerID) == DOTA_TEAM_GOODGUYS then
        contRadiantShop:Open(playerID)
        unit:Stop()
      else
        Containers:DisplayError(playerID, "#dota_hud_error_unit_command_restricted")
      end
    end,
    })


  contShopDireEnt = CreateUnitByName("npc_dummy_unit", contShopDireEnt:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_BADGUYS)
  contShopDireEnt:AddNewModifier(viper, nil, "modifier_shopkeeper", {})
  contShopDireEnt:SetModel("models/heroes/enigma/enigma.vmdl")
  contShopDireEnt:SetOriginalModel("models/heroes/enigma/enigma.vmdl")
  contShopDireEnt:StartGesture(ACT_DOTA_IDLE)
  contShopDireEnt:SetForwardVector(Vector(-1,0,0))

  sItems,prices,stocks = CreateShop({
    {"item_quelling_blade", 150, 3},
    {"item_quelling_blade"},
    {"item_clarity"},
    {"item_bfury", 9000},
  })

  sItems[3]:SetCurrentCharges(2)
  
  contShopDire = Containers:CreateShop({
       layout =      {2,2,2,2,2},
       skins =       {},
       headerText =  "Dire Shop",
       pids =        {},
       position =    "entity", --"1000px 300px 0px",
       entity =      contShopDireEnt,
       items =       sItems,
       prices =      prices,
       stocks =      stocks,
       closeOnOrder= true,
       range =       300,
    })

  Containers:SetEntityOrderAction(contShopDireEnt, {
    container = contShopDire,
    action = function(playerID, unit, target)
      print("ORDER ACTION dire shop", playerID)
      if PlayerResource:GetTeam(playerID) == DOTA_TEAM_BADGUYS then
        contShopDire:Open(playerID)
        unit:Stop()
      else
        Containers:DisplayError(playerID, "#dota_hud_error_unit_command_restricted")
      end
    end,
    })


  for _,loc in ipairs(lootSpawns) do
    CreateLootBox(loc)
  end

  for _,loc in ipairs(itemDrops) do
    local phys = CreateItemOnPositionSync(loc:GetAbsOrigin(), RandomItem())
    phys:SetForwardVector(Vector(0,-1,0))

    loc.phys = phys
  end

  Timers:CreateTimer(function()
    for _,loc in ipairs(itemDrops) do
      if not IsValidEntity(loc.phys) then
        local phys = CreateItemOnPositionSync(loc:GetAbsOrigin(), RandomItem())
        phys:SetForwardVector(Vector(0,-1,0))

        loc.phys = phys
      end
    end
    return 15
  end)
end

function GameMode:OHIG(hero)
  -- create inventory
  print(pid, hero:GetName())
  local pid = hero:GetPlayerID()

  local c = Containers:CreateContainer({
     layout =      {3,4,4},
     skins =       {},
     headerText =  "My Inventory",
     pids =        {pid},
     --buttons =     {"Button 1", "Button 2"},
     entity =      hero,
     closeOnOrder = false,
     position =    "1200px 600px 0px",
     OnDragWorld = true,
    })

  pidInventory[pid] = c

  local item = CreateItem("item_tango", hero, hero)
  c:AddItem(item, 4)

  item = CreateItem("item_tango", hero, hero)
  c:AddItem(item, 6)

  item = CreateItem("item_force_staff", hero, hero)
  c:AddItem(item)

  item = CreateItem("item_blade_mail", hero, hero)
  c:AddItem(item)

  item = CreateItem("item_veil_of_discord", hero, hero)
  c:AddItem(item)

  privateBank[pid] = Containers:CreateContainer({
      layout =      {4,4,4,4},
      headerText =  "Private Bank",
      pids =        {pid},
      position =    "entity", --"200px 200px 0px",
      entity =      privateBankEnt,
      closeOnOrder= true,
      forceOwner =  hero,
      forcePurchaser=hero,
      range =       250,
  })

  defaultInventory[pid] = true
  Containers:SetDefaultInventory(hero, c)
end

if LOADED then
  return
end
LOADED = true

pidInventory = {}
lootSpawns = nil
itemDrops = nil
privateBankEnt = nil
sharedBankEnt = nil
contShopRadEnt = nil
contShopDireEnt = nil
itemShopEnt = nil

contShopRad = nil
contShopDire = nil
itemShop = nil
sharedBank = nil
privateBank = {}

defaultInventory = {}