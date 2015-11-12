--Merchant Boat paths, and other lists
PATH1 = {"path_ship_waypoint_1","path_ship_waypoint_2","path_ship_waypoint_3","path_ship_waypoint_4","path_ship_waypoint_5", "path_ship_waypoint_6", "path_ship_waypoint_7"}
PATH2 = {"path_ship_waypoint_8","path_ship_waypoint_9","path_ship_waypoint_4","path_ship_waypoint_5", "path_ship_waypoint_6", "path_ship_waypoint_7"}
PATH3 = {"path_ship_waypoint_1","path_ship_waypoint_2","path_ship_waypoint_3","path_ship_waypoint_4","path_ship_waypoint_5", "path_ship_waypoint_10", "path_ship_waypoint_11", "path_ship_waypoint_12"}
PATH4 = {"path_ship_waypoint_8","path_ship_waypoint_9","path_ship_waypoint_4","path_ship_waypoint_5", "path_ship_waypoint_10", "path_ship_waypoint_11", "path_ship_waypoint_12"}
PATH_LIST = {PATH1, PATH2, PATH3, PATH4}
SHOP_UNIT_NAME_LIST = {"npc_ship_merchant_1", "npc_ship_merchant_2", "npc_ship_merchant_3"}
MAX_SHOPS_ON_MAP = 1

-- At any given time there are two boats on map, sailing at 120 move speed. They take a random path around the islands to an exit point. 
-- Sometimes the ships will stop in shallow water for a few seconds. There are 8 Trading Ships in total.
function ITT:SetupShops()

    boatStartTime = math.floor(GameRules:GetGameTime())
    GameMode.spawnedShops = {}
    GameMode.shopEntities = Entities:FindAllByName("entity_ship_merchant_*")

    GameRules.ShopKV = LoadKeyValues("scripts/kv/shop_info.kv")

    local pathA = RollPercentage(50) and 1 or 3
    local pathB = RollPercentage(50) and 2 or 4
    SpawnBoat(pathA)
    SpawnBoat(pathB)
end

function SpawnBoat(pathNum)
    local currentTime = math.floor(GameRules:GetGameTime())
    local path = PATH_LIST[pathNum]
    local initialWaypoint = Entities:FindByName(nil, path[1])
    local spawnOrigin = initialWaypoint:GetOrigin()

    local merchantNum = RandomInt(1, #SHOP_UNIT_NAME_LIST)
    unitName = SHOP_UNIT_NAME_LIST[merchantNum]

    local shopUnit = CreateUnitByName(unitName, spawnOrigin, false, nil, nil, DOTA_TEAM_NEUTRALS)
    shopUnit.path = path
    shopUnit.pathNum = pathNum

    print("Spawned "..unitName.." at path "..pathNum)

    TieShopToUnit(shopUnit)    
end

function TieShopToUnit( unit )
    unit:AddNewModifier(unit, nil, "modifier_shopkeeper", {})
    
    local unitName = unit:GetUnitName()
    local itemTable = GameRules.ShopKV[unitName]
    local sItems,prices,stocks = CreateShopItems(itemTable)

    -- Build the rows in a square
    local shopRows = math.ceil(math.sqrt(#sItems))
    local shopLayout = {}
    for i=1,shopRows-1 do
        shopLayout[i] = shopRows
    end
    shopLayout[shopRows] = #sItems - shopRows*(shopRows-1)

    local shop = Containers:CreateShop({
        layout =      shopLayout,
        skins =       {},
        headerText =  unitName,
        pids =        {},
        position =    "entity", --"1000px 300px 0px",
        entity =      unit,
        items =       sItems,
        prices =      prices,
        stocks =      stocks,
        closeOnOrder= true,
        range =       300,
    })

    Containers:SetEntityOrderAction(unit, {
        container = shop,
        action = function(playerID, unit, target)
            shop:Open(playerID)
            local player = PlayerResource:GetPlayer(playerID)
            EmitSoundOnClient("Shop.Available", player)
            EmitSoundOnClient("Quickbuy.Available", player)
            unit:Stop()
            unit:Hold()
        end,
    })
end

-- Creates items from a table with name, price and stock
function CreateShopItems(ii)
  local sItems = {}
  local prices = {}
  local stocks = {}

  for _,i in pairs(ii) do
    local item = CreateItem(i.name, nil, nil)
    local index = item:GetEntityIndex()
    sItems[#sItems+1] = item
    if i.price then prices[index] = i.price end
    if i.stock then stocks[index] = i.stock end
    
    item:SetCurrentCharges(item:GetInitialCharges())

  end

  return sItems, prices, stocks
end