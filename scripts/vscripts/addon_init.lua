-- Global variables
HUNTER = "npc_dota_hero_huskar"
PRIEST = "npc_dota_hero_dazzle"
MAGE = "npc_dota_hero_witch_doctor"
BEASTMASTER = "npc_dota_hero_lycan"
THIEF = "npc_dota_hero_riki"
SCOUT = "npc_dota_hero_lion"
GATHERER = "npc_dota_hero_shadow_shaman"

local subclasses = {
    npc_dota_hero_huskar = {        "npc_hero_hunter_tracker",
                                    "npc_hero_hunter_warrior",
                                    "npc_hero_hunter_juggernaught"},

    npc_dota_hero_dazzle = {          "npc_hero_priest_booster",
                        "npc_hero_priest_master_healer",
                        "npc_hero_priest_sage"},

    npc_dota_hero_witch_doctor = {            "npc_hero_mage_elementalist",
                        "npc_hero_mage_hypnotist",
                        "npc_hero_mage_dementia_master"},

    npc_dota_hero_lycan = {     "npc_hero_beastmaster_packleader",
                        "npc_hero_beastmaster_shapeshifter",
                        "npc_hero_beastmaster_form_chicken"},

    npc_dota_hero_riki = {           "npc_hero_thief_escape_artist", 
                        "npc_hero_thief_contortionist", 
                        "npc_hero_thief_assassin"},

    npc_dota_hero_lion = {           "npc_hero_scout_observer",
                        "npc_hero_scout_radar",
                        "npc_hero_scout_spy"},

    npc_dota_hero_shadow_shaman = {        "npc_hero_douchebag",
                        "npc_hero_crackaddict",
                        "npc_hero_catpicture"},
}

--[[
	This is where the meat of the addon is defined and modified
	This file exists mostly because addon_game_mode can't be dynamically reloaded
]]--

print("addon_init invoked")

require( 'util' )
require("recipe_list")

--[[
    Global variables
]]--

playerList = {}
maxPlayerID = 0

GAME_TICK_TIME              = 0.1  	-- The game should update every tenth second
GAME_CREATURE_TICK_TIME     = 120    -- Time for each creature spawn
GAME_BUSH_TICK_TIME         = 10
GAME_TROLL_TICK_TIME        = 0.5  	-- Its really like its wc3!
GAME_ITEM_TICK_TIME         = 30  	-- Spawn items every 30?
FLASH_ACK_THINK             = 2

BUILDING_TICK_TIME 			= 0.03
DROPMODEL_TICK_TIME         = 0.03

itemKeyValues = LoadKeyValues("scripts/npc/npc_items_custom.txt")

--[[
    This is all used for item spawning

    Globals related to item spawns, mostly taken from
    https://github.com/island-troll-tribes/wc3-client/blob/1562854dd098180752f0f4a99df0c4968697b38b/src/lib/PublicLibrary.j
    and
    https://github.com/island-troll-tribes/wc3-client/blob/1562854dd098180752f0f4a99df0c4968697b38b/src/init/objects/Globals.j
]]--

-- Regions of the map in xmin xmax, ymin, ymax as a box, and an int as a spawnrate
-- Currently just a placeholder region called CENTER till I get a proper map
REGIONS                     = {}
-- CENTER                      = {}
TOPLEFT                     = {-8000, -600, 8000, 500, 1}  --{xmin, xmax, ymin, ymax, spawnrate}
TOPRIGHT                    = {550, 8000, 8000, 800, 1}
BOTTOMRIGHT                 = {-1100, -8000, -600, -8000, 1}
BOTTOMLEFT                  = {950, 8000, -350, -8000, 1}
REGIONS[1]                  = TOPLEFT
REGIONS[2]                  = TOPRIGHT
REGIONS[3]                  = BOTTOMRIGHT
REGIONS[4]                  = BOTTOMLEFT

-- Tick time is 300s
-- https://github.com/island-troll-tribes/wc3-client/blob/1562854dd098180752f0f4a99df0c4968697b38b/src/systems/spawning/Spawn%20Normal.j#L3
-- GAME_ITEM_TICK_TIME         = 300    

-- Using a shorter time for testing's sake
--GAME_ITEM_TICK_TIME         = 15

-- Spawnrates of items, seeded with initial rates from
-- https://github.com/island-troll-tribes/wc3-client/blob/1562854dd098180752f0f4a99df0c4968697b38b/src/init/objects/Globals.j
TINDER_RATE                 = 5.00
FLINT_RATE                  = 3.00
STICK_RATE                  = 3.00
CLAYBALL_RATE               = 1.00
STONE_RATE                   = 1.00
MANACRYSTAL_RATE            = 0.00
MAGIC_RATE                  = 0.5

-- Relative rates start at 0 but get set such that all should sum to one on first call
REL_TINDER_RATE             = 0 
REL_FLINT_RATE              = 0
REL_STICK_RATE              = 0
REL_CLAYBALL_RATE           = 0
REL_STONE_RATE               = 0
REL_MANACRYSTAL_RATE        = 0
REL_MAGIC_RATE              = 0

-- Controls the base item spawn rate 
ITEM_BASE                   = 2

--Merchant Boat paths, and other lists
PATH1 = {"path_ship_waypoint_1","path_ship_waypoint_2","path_ship_waypoint_3","path_ship_waypoint_4","path_ship_waypoint_5", "path_ship_waypoint_6", "path_ship_waypoint_7"}
PATH2 = {"path_ship_waypoint_8","path_ship_waypoint_9","path_ship_waypoint_4","path_ship_waypoint_5", "path_ship_waypoint_6", "path_ship_waypoint_7"}
PATH3 = {"path_ship_waypoint_1","path_ship_waypoint_2","path_ship_waypoint_3","path_ship_waypoint_4","path_ship_waypoint_5", "path_ship_waypoint_10", "path_ship_waypoint_11", "path_ship_waypoint_12"}
PATH4 = {"path_ship_waypoint_8","path_ship_waypoint_9","path_ship_waypoint_4","path_ship_waypoint_5", "path_ship_waypoint_10", "path_ship_waypoint_11", "path_ship_waypoint_12"}
PATH_LIST = {PATH1, PATH2, PATH3, PATH4}
SHOP_UNIT_NAME_LIST = {"npc_ship_merchant_1", "npc_ship_merchant_2", "npc_ship_merchant_3"}
TOTAL_SHOPS = #SHOP_UNIT_NAME_LIST
MAX_SHOPS_ON_MAP = 1
 
--[[
    Default cruft to set everything up
    In the game creation trace, this runs after 
        S:Gamerules: entering state 'DOTA_GAMERULES_STATE_INIT' - base DOTA2 rules that we can't change are loaded here
        SV:  Spawn Server: template_map - where the map is loaded on the server
    It runs before any of these events: 
        Precaching
        CL:  CWaitForGameServerStartupPrerequisite - this is where the sever signals it is ready to be connected to
        CL:  CCreateGameClientJob - this creates the creating client connection to server
]]--

if ITT_GameMode == nil then
    print("ITT Script execution begin")
    ITT_GameMode = class({})
    -- LoadKeyValues(filename a) 
end

--[[
    Here is where we run the code that occurs when the game starts
    This is run once the engine has launched

    Some useful things to do here:

    Set the hero selection time. Make this 0.0 if you have you rown hero selection system (like wc3 taverns)
        GameRules:SetHeroSelectionTime( [time] )
]]--
function ITT_GameMode:InitGameMode()
    PrintTable(Entities)
    print( "Game mode setup." )
	BuildingHelper:BlockGridNavSquares(16384)

	Convars:RegisterConvar('itt_set_game_mode', nil, 'Set to the game mode', FCVAR_PROTECTED)

	GameMode = GameRules:GetGameModeEntity()

    -- Set the game's thinkers up

    -- This is the global thinker. It should only manage game state
    GameMode:SetThink( "OnStateThink", ITT_GameMode, "StateThink", 2 )

    -- This is the creature thinker. All neutral creature spawn logic goes here
    GameMode:SetThink( "OnCreatureThink", ITT_GameMode, "CreatureThink", 2 )
    GameMode.neutralCurNum = {}
    GameMode.neutralCurNum["npc_creep_elk_wild"] = 0
    GameMode.neutralCurNum["npc_creep_hawk"] = 0
    GameMode.neutralCurNum["npc_creep_fish"] = 0
    GameMode.neutralCurNum["npc_creep_fish_green"] = 0
    GameMode.neutralCurNum["npc_creep_wolf_jungle"] = 0
    GameMode.neutralCurNum["npc_creep_bear_jungle"] = 0
    GameMode.neutralCurNum["npc_creep_lizard"] = 0
    GameMode.neutralCurNum["npc_creep_panther"] = 0
    GameMode.neutralCurNum["npc_creep_panther_elder"] = 0

    -- This is the troll thinker. All logic on the player's heros should be checked here
    GameMode:SetThink( "OnTrollThink", ITT_GameMode, "TrollThink", 0 )

    -- This is the building thinker. All logic on building crafting goes here
    GameMode:SetThink( "OnBuildingThink", ITT_GameMode, "BuildingThink", 0 )

    -- This is the item thinker. All random item spawn logic goes here
    GameMode:SetThink( "OnItemThink", ITT_GameMode, "ItemThink", 0 )

     -- This is the herb bush thinker. All herb spawn logic goes here
    GameMode:SetThink( "OnBushThink", ITT_GameMode, "BushThink", 0 )

     -- This is the boat thinker. All boat logic goes here
    GameMode:SetThink( "OnBoatThink", ITT_GameMode, "BoatThink", 0 )
    boatStartTime = math.floor(GameRules:GetGameTime())
    GameMode.spawnedShops = {}
    GameMode.shopEntities = Entities:FindAllByName("entity_ship_merchant_*")

    -- This is the thinker that checks building placement
    GameMode:SetThink("Think", BuildingHelper, "buildinghelper", 0)

    GameMode:SetThink("FixDropModels", ITT_GameMode, "FixDropModels", 0)

    GameMode:SetThink("FlashAckThink", ITT_GameMode, "FlashAckThink", 0)

    
    GameRules:GetGameModeEntity():ClientLoadGridNav()
    GameRules:SetSameHeroSelectionEnabled( true )
    GameRules:SetTimeOfDay( 0.75 )
    GameRules:SetHeroRespawnEnabled( false )
    GameRules:SetHeroSelectionTime(0)
    GameRules:SetPreGameTime( 45.0 )
    GameRules:SetPostGameTime( 60.0 )
    GameRules:SetTreeRegrowTime( 60.0 )
--    GameRules:SetHeroMinimapIconSize( 400 )
    GameRules:SetCreepMinimapIconScale( 0.7 )
    GameRules:SetRuneMinimapIconScale( 0.7 )
    GameRules:SetGoldTickTime( 60.0 )
    GameRules:SetGoldPerTick( 0 )

    -- Listen for a game event.
    -- A list of events is findable here: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Built-In_Engine_Events
    -- A bunch of those are broken, so be warned
    -- Custom events can be made in /scripts/custom_events.txt
    -- BROKEN:
    -- dota_item_drag_end dota_item_drag_begin dota_inventory_changed dota_inventory_item_changed  
    -- dota_inventory_changed_query_unit dota_inventory_item_added
    -- WORK:
    -- dota_item_picked_up dota_item_purchased
    ListenToGameEvent('player_connect_full', Dynamic_Wrap(ITT_GameMode, 'OnPlayerConnectFull'), self) 
   
	-- Use this for assigning items to heroes initially once they pick their hero.
	ListenToGameEvent( "dota_player_pick_hero", Dynamic_Wrap( ITT_GameMode, "OnPlayerPicked" ), self )
	
	-- Use this for dealing with subclass spawning
   	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( ITT_GameMode, "OnNPCSpawned" ), self )	

    --Listener for items picked up, used for telegather abilities
    ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap(ITT_GameMode, 'OnItemPickedUp'), self)

    ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap(ITT_GameMode, 'OnPlayerGainedLevel'), self) 
	
	--Listener for storing hero information and revive
	ListenToGameEvent("dota_player_killed", Dynamic_Wrap(ITT_GameMode, 'OnDotaPlayerKilled'), self)

    -- Listener for drops and for removing buildings from block table
    ListenToGameEvent("entity_killed", Dynamic_Wrap( ITT_GameMode, "OnEntityKilled" ), self )

    ListenToGameEvent("entity_hurt", Dynamic_Wrap(ITT_GameMode, 'On_entity_hurt'), self)

    --for multiteam
    ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( ITT_GameMode, 'OnGameRulesStateChange' ), self )

    --multiteam stuff
    self.m_TeamColors = {}
    print("DOTA_TEAM_GOODGUYS "..DOTA_TEAM_GOODGUYS, "DOTA_TEAM_BADGUYS "..DOTA_TEAM_BADGUYS, "DOTA_TEAM_CUSTOM_1 "..DOTA_TEAM_CUSTOM_1)
    self.m_TeamColors[DOTA_TEAM_GOODGUYS] = { 255, 0, 0 }
    self.m_TeamColors[DOTA_TEAM_BADGUYS] = { 0, 255, 0 }
    self.m_TeamColors[DOTA_TEAM_CUSTOM_1] = { 0, 0, 255 }
    print(self.m_TeamColors[DOTA_TEAM_GOODGUYS], self.m_TeamColors[DOTA_TEAM_BADGUYS], self.m_TeamColors[DOTA_TEAM_CUSTOM_1])

    self.m_VictoryMessages = {}
    self.m_VictoryMessages[DOTA_TEAM_GOODGUYS] = "#VictoryMessage_GoodGuys"
    self.m_VictoryMessages[DOTA_TEAM_BADGUYS] = "#VictoryMessage_BadGuys"
    self.m_VictoryMessages[DOTA_TEAM_CUSTOM_1] = "#VictoryMessage_Custom1"

    self.m_GatheredShuffledTeams = {}
    self.m_NumAssignedPlayers = 0

    self:GatherValidTeams()

    GameRules:GetGameModeEntity():SetThink( "OnThink", self, 1 ) 

    --initial bush spawns
    --place "npc_dota_spawner" entities on the map with the appropriate name to spawn to corresponding bush on game start
    local bush_herb_spawnpoints = Entities:FindAllByClassname("npc_dota_spawner")
    print("bush_herb_spawnpoints " .. #bush_herb_spawnpoints)
    for _,spawnpoint in pairs(bush_herb_spawnpoints) do
        if string.find(spawnpoint:GetName(), "spawner_npc_bush_herb_yellow") then
            CreateUnitByName("npc_bush_herb_yellow", spawnpoint:GetOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)
        elseif string.find(spawnpoint:GetName(), "spawner_npc_bush_herb_blue") then
            CreateUnitByName("npc_bush_herb_blue", spawnpoint:GetOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)
        elseif string.find(spawnpoint:GetName(), "spawner_npc_bush_herb_purple") then
            CreateUnitByName("npc_bush_herb_purple", spawnpoint:GetOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)
        elseif string.find(spawnpoint:GetName(), "spawner_npc_bush_herb_orange") then
            CreateUnitByName("npc_bush_herb_orange", spawnpoint:GetOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)
        elseif string.find(spawnpoint:GetName(), "spawner_npc_bush_herb") then
            CreateUnitByName("npc_bush_herb", spawnpoint:GetOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)
        elseif string.find(spawnpoint:GetName(), "spawner_npc_bush_mushroom") then
            CreateUnitByName("npc_bush_mushroom", spawnpoint:GetOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)
        elseif string.find(spawnpoint:GetName(), "spawner_npc_bush_thistle") then
            CreateUnitByName("npc_bush_thistle", spawnpoint:GetOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)
        elseif string.find(spawnpoint:GetName(), "spawner_npc_bush_stash") then
            CreateUnitByName("npc_bush_stash", spawnpoint:GetOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)
        elseif string.find(spawnpoint:GetName(), "spawner_npc_bush_thief") then
            CreateUnitByName("npc_bush_thief", spawnpoint:GetOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)
        elseif string.find(spawnpoint:GetName(), "spawner_npc_bush_scout") then
            CreateUnitByName("npc_bush_scout", spawnpoint:GetOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)
        elseif string.find(spawnpoint:GetName(), "spawner_npc_bush_river") then
            CreateUnitByName("npc_bush_river", spawnpoint:GetOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)
        end
    end
    -- spawner_npc_bush_herb
    -- spawner_npc_bush_river
    -- spawner_npc_bush_mushroom
    -- spawner_npc_bush_thistle
    -- spawner_npc_bush_stash
    -- spawner_npc_bush_herb_yellow
    -- spawner_npc_bush_herb_blue
    -- spawner_npc_bush_herb_purple
    -- spawner_npc_bush_herb_orange
    -- spawner_npc_bush_thief
    -- spawner_npc_bush_scout

    --flash ui commands
    --print("flash ui commands")
    Convars:RegisterCommand( "Sleep", function(...) return self:_Sleep( ... ) end, "Player is put to sleep", 0 )
    Convars:RegisterCommand( "PickUpMeat", function(...) return self:_PickUpMeat( ... ) end, "Player drops one raw meat", 0)
    Convars:RegisterCommand( "EatMeat", function(...) return self:_EatMeat( ... ) end, "Player eats one raw meat", 0 )
    Convars:RegisterCommand( "DropMeat", function(...) return self:_DropMeat( ... ) end, "Player drops one raw meat", 0 )
    Convars:RegisterCommand( "DropAllMeat", function(...) return self:_DropAllMeat( ... ) end, "Player drops all raw meat", 0)
    Convars:RegisterCommand( "Panic", function(...) return self:_Panic( ... ) end, "Player panics!", 0)
    Convars:RegisterCommand( "sub_select", function(cmdname, num) self:_SubSelect(Convars:GetCommandClient(), tonumber(num)) end, "Select Subclass", 0)
    Convars:RegisterCommand( "try_6", function(cmdname, class) print("Trying.."); FireGameEvent("fl_level_6", {pid = -1, gameclass = class}) end, "Select First Subclass", 0)
    
    --select class commands
    Convars:RegisterCommand( "SelectClass", function(...) return self:_SelectClass( ... ) end, "Player is selecting a class", 0 )

    --prepare neutral spawns
    self.NumPassiveNeutrals = 0
    self.NumAggressiveNeutrals = 0
end

--Handler for class selection at the beginning of the game
function ITT_GameMode:_SelectClass(cmdName, arg1)
    local cmdPlayer = Convars:GetCommandClient()  -- returns the player who issued the console command
    local classNum = tonumber(arg1)
    --print("Class selected "..classNum)
    if cmdPlayer then
        --0=hunter, 1=gatherer, 2=scout, 3=thief, 4=priest, 5=mage 6=bm
        if classNum == 0 then
            CreateHeroForPlayer("npc_dota_hero_huskar", cmdPlayer)
        elseif classNum == 1 then
            CreateHeroForPlayer("npc_dota_hero_shadow_shaman", cmdPlayer)
        elseif classNum == 2 then
            CreateHeroForPlayer("npc_dota_hero_lion", cmdPlayer)
        elseif classNum == 3 then
            CreateHeroForPlayer("npc_dota_hero_riki", cmdPlayer)
        elseif classNum == 4 then
            CreateHeroForPlayer("npc_dota_hero_dazzle", cmdPlayer)
        elseif classNum == 5 then
            CreateHeroForPlayer("npc_dota_hero_witch_doctor", cmdPlayer)
        elseif classNum == 6 then
            CreateHeroForPlayer("npc_dota_hero_lycan", cmdPlayer)
        else
            print("wtf class selected isn't 0-6, spawning hunter as default")
            CreateHeroForPlayer("npc_dota_hero_huskar", cmdPlayer)
        end
    end
end

--Handlers for commands from custom UI
function ITT_GameMode:_Sleep(cmdName)
    print("Sleep Command")
    local cmdPlayer = Convars:GetCommandClient()  -- returns the player who issued the console command
    if cmdPlayer then
        local nPlayerID = cmdPlayer:GetPlayerID()
        local hero = cmdPlayer:GetAssignedHero()
        if hero == nil then
            return
        end
        local abilityName = "ability_rest_troll"
        local ability = hero:FindAbilityByName(abilityName)
        if ability == nil then
            hero:AddAbility(abilityName)
            ability = hero:FindAbilityByName( abilityName )
            ability:SetLevel(1)
        end
        print("trying to cast ability ", abilityName)
        hero:CastAbilityNoTarget(ability, -1)
    end
end

function ITT_GameMode:_EatMeat(cmdName)
    print("EatMeat Command")
    local cmdPlayer = Convars:GetCommandClient()  -- returns the player who issued the console command
    if cmdPlayer then
        local nPlayerID = cmdPlayer:GetPlayerID()
        local hero = cmdPlayer:GetAssignedHero()

        if hero == nil then
            return
        end

        local meatStacks = hero:GetModifierStackCount("modifier_meat_passive", nil)
        if meatStacks > 0 then
            local abilityName = "ability_item_eat_meat_raw"
            local ability = hero:FindAbilityByName(abilityName)
            if ability == nil then
                hero:AddAbility(abilityName)
                ability = hero:FindAbilityByName( abilityName )
                ability:SetLevel(1)
            end
            print("trying to cast ability ", abilityName)
            hero:CastAbilityNoTarget(ability, -1)

            hero:SetModifierStackCount("modifier_meat_passive", nil, meatStacks-1)
        end
    end
end

function ITT_GameMode:_DropMeat(cmdName)
    print("DropMeat Command")
    local cmdPlayer = Convars:GetCommandClient()  -- returns the player who issued the console command
    if cmdPlayer then
        local nPlayerID = cmdPlayer:GetPlayerID()
        local hero = cmdPlayer:GetAssignedHero()
        if hero == nil then
            return
        end
        print("COMMAND FROM PLAYER: " .. nPlayerID)
        print("Drop one meat from hero " .. hero:GetName())

        local meatStacks = hero:GetModifierStackCount("modifier_meat_passive", nil)
        if meatStacks > 0 and hero ~= nil then
            local newItem = CreateItem("item_meat_raw", nil, nil)
            CreateItemOnPositionSync(hero:GetOrigin() + RandomVector(RandomInt(50,100)), newItem)

            hero:SetModifierStackCount("modifier_meat_passive", nil, meatStacks - 1)
        end
    end
end

function ITT_GameMode:_DropAllMeat(cmdName)
    print("DropAllMeat Command")
    local cmdPlayer = Convars:GetCommandClient()  -- returns the player who issued the console command
    if cmdPlayer then
        local nPlayerID = cmdPlayer:GetPlayerID()
        local hero = cmdPlayer:GetAssignedHero()
        if hero == nil then
            return
        end
        print("COMMAND FROM PLAYER: " .. nPlayerID)
        print("Drop all meat hero " .. hero:GetName())

        local meatStacks = hero:GetModifierStackCount("modifier_meat_passive", nil)
        if meatStacks > 0 and hero ~= nil then
            for i = 1,meatStacks do
                local newItem = CreateItem("item_meat_raw", nil, nil)
                CreateItemOnPositionSync(hero:GetOrigin() + RandomVector(RandomInt(50,100)), newItem)

                hero:SetModifierStackCount("modifier_meat_passive", nil, 0)
            end
        end
    end
end

function ITT_GameMode:_Panic(cmdName)
    print("Panic Command")
    local cmdPlayer = Convars:GetCommandClient()  -- returns the player who issued the console command
    if cmdPlayer then
        local nPlayerID = cmdPlayer:GetPlayerID()
        local hero = cmdPlayer:GetAssignedHero()
        if hero == nil then
            return
        end
        local abilityName = "ability_panic"
        local ability = hero:FindAbilityByName(abilityName)
        if ability == nil and hero ~= nil then
            hero:AddAbility(abilityName)
            ability = hero:FindAbilityByName( abilityName )
            ability:SetLevel(1)
        end
        print("trying to cast ability ", abilityName)
        hero:CastAbilityNoTarget(ability, -1)
    end
end

-- This was missing, added a placeholder to at least remove crashes
function ITT_GameMode:_PickUpMeat(cmdName)
    print("Pick up meat button not implemented, this added to remove crashes")
end

unitskeys = LoadKeyValues("scripts/npc/npc_units_custom.txt")
itemskeys = LoadKeyValues("scripts/items/items_game.txt").items
heroeskeys = LoadKeyValues("scripts/npc/npc_heroes.txt")

function ModelForItemID(itemid)
    return itemskeys[tostring(itemid)].model_player
end

function SlotForItemID(itemid)
    return itemskeys[tostring(itemid)].item_slot
end

modelmap = {}

function MapModels()
    for k,v in pairs(itemskeys) do
        if v.model_player and v.item_slot then
            modelmap[v.model_player] = v.item_slot
        end
    end
end

MapModels()

function SlotForModel(model)
    return modelmap[model]
end

function CosmeticsForUnit(unit)
    local retn = {}
    local i = unit:entindex()

    while true do  -- I'm aware of the FindByClassname function taking an iterator (the entity to lookafter), which would be greater prefered, but it was spewing nils at me
        local ent = EntIndexToHScript(i) 
        if ent:GetClassname() == "dota_item_wearable" then
            retn[#retn + 1] = ent
        elseif #retn > 0 then break
        end
        i = i + 1
    end

    return retn
end

function GetModelForSlot(clothes, slot)
    for k,v in pairs(clothes) do
        local itemid = v["ItemDef"]
        local newslot = SlotForItemID(itemid)
        if newslot == slot then return ModelForItemID(itemid) end
    end
end

--[[
    This fixes the Cosmetics issue by model-swapping the naturally assigned hero's cosmetics with the chosen subclass models. It does this by looking at the currect setup in
    npc_units_custom.txt. This is strange because this method implies that hero -> unit swapping is no longer intended. We will need to do the Ability shuffling manually later.

    Sticking with the player's assigned heroes as a number of player-usuability wins. It doesn't destroy Multiteam callouts, introduce 
    selectin wonkiness, break your control groups or hero-snap key, and probably some other stuff I'm forgetting.

    The biggest problem is that the unit's name on the UI no longer changes on its own. Off the top of my head, the only way to patch this up would be to rig some shit up in 
    scaleform, which isn't so bad because the gamemode could use some other gameui patches -- such as a better implementation of the inventory slot-blockers that you can
    move around.

]]

function ITT_GameMode:_SubSelect(player, n)

    local playerUnitEnt = player:GetAssignedHero()
    local playerUnit = playerUnitEnt:GetUnitName()
    local pid = player:GetPlayerID()

    local choices = subclasses[playerUnit]
    if choices then
        local choice = choices[n + 1]
        
        local oldClothes = CosmeticsForUnit(playerUnitEnt)

        local newClothes = unitskeys[choice].Creature.AttachWearables

        for _,v in pairs(oldClothes) do
            local oldmodel = v:GetModelName()
            local matchingNew = GetModelForSlot(newClothes, SlotForModel(oldmodel))
            if matchingNew then
                print("I'm changing " .. oldmodel .. " to " .. matchingNew )
                v:SetModel(matchingNew)
            end
        end
    end
end

-- This code is written by Internet Veteran, handle with care.
--Distribute slot locked items based off of the class.
function ITT_GameMode:OnPlayerPicked( keys ) 
    local spawnedUnit = EntIndexToHScript( keys.heroindex )
    local itemslotlock = CreateItem("item_slot_locked", spawnedUnit, spawnedUnit)
	
	local innateSkills = {
		{HUNTER,"ability_hunter_ensnare"},
		{PRIEST,"ability_priest_theglow"},
		{MAGE,"ability_mage_nulldamage"},
		{BEASTMASTER,"ability_beastmaster_tamepet","ability_beastmaster_spiritofthebeast","ability_beastmaster_pet_release",
						"ability_beastmaster_pet_follow","ability_beastmaster_pet_stay","ability_beastmaster_pet_sleep","ability_beastmaster_pet_attack"},
		{THIEF,"ability_thief_teleport"},
		{SCOUT,"ability_scout_enemyradar"},
		{GATHERER,"ability_gatherer_itemradar"}
	}
	local lockedSlots = {
		{HUNTER,3},
		{PRIEST,2},
		{MAGE,2},
		{BEASTMASTER,2},
		{THIEF,1},
		{SCOUT,1},
		{GATHERER,0}
	}
	
	local class = spawnedUnit:GetClassname()
	
    -- This handles locking a number of inventory slots for some classes
    -- Fills all slots with locks then removes them to leave the correct number
    -- This means that players do not need to manually reshuffle them to craft
	for _,slotList in pairs(lockedSlots) do
		if slotList[1] == class then
            local freeslots = 6 - slotList[2]
            --print("slots free are", freeslots)
            for i = 1, 6 do
                spawnedUnit:AddItem(CreateItem("item_slot_locked", spawnedUnit, spawnedUnit))
            end
            for i = 0, (freeslots-1) do
                local removeMe = spawnedUnit:GetItemInSlot(i)
                spawnedUnit:RemoveItem(removeMe)
            end
		end		
	end
	
	-- add innate skills
	spawnedUnit:SetAbilityPoints(0)
	for _,spellList in pairs(innateSkills) do
		if spellList[1] == class then
			for i = 2, #spellList do
                print("adding innate spell " .. spellList[i])
				local ability = spawnedUnit:FindAbilityByName(spellList[i])
				ability:UpgradeAbility(true)
			end
		end
	end

    --heat handling
    if string.find(spawnedUnit:GetClassname(), "hero") then
        print("HEAT1!")
        spawnedUnit:RemoveModifierByName("modifier_heat_passive")
        local heatApplier = CreateItem("item_heat_modifier_applier", spawnedUnit, spawnedUnit)
        heatApplier:ApplyDataDrivenModifier(spawnedUnit, spawnedUnit, "modifier_heat_passive", {duration=-1})
        spawnedUnit:SetModifierStackCount("modifier_heat_passive", nil, 100)
    end

     --meat handling
    if string.find(spawnedUnit:GetClassname(), "hero") then
        print("MEAT!")
        spawnedUnit:RemoveModifierByName("modifier_meat_passive")
        local heatApplier = CreateItem("item_meat_modifier_applier", spawnedUnit, spawnedUnit)
        heatApplier:ApplyDataDrivenModifier(spawnedUnit, spawnedUnit, "modifier_meat_passive", {duration=-1})
        spawnedUnit:SetModifierStackCount("modifier_meat_passive", nil, 0)
    end
end
	
-- This code is written by Internet Veteran, handle with care.
--Do the same now for the subclasses
function ITT_GameMode:OnNPCSpawned( keys ) 
    local spawnedUnit = EntIndexToHScript( keys.entindex )
    local itemslotlock1 = CreateItem("item_slot_locked", spawnedUnit, spawnedUnit)
    local itemslotlock2 = CreateItem("item_slot_locked", spawnedUnit, spawnedUnit)
    local itemslotlock3 = CreateItem("item_slot_locked", spawnedUnit, spawnedUnit)
    print("spawned unit: ", spawnedUnit:GetUnitName(), spawnedUnit:GetClassname(), spawnedUnit:GetName(), spawnedUnit:GetEntityIndex())
    if string.find(spawnedUnit:GetUnitName(), "mage") then
    	spawnedUnit:AddItem(itemslotlock1)
    	spawnedUnit:AddItem(itemslotlock2)
     --	if spawnedUnit:GetClassname() == "hunter" then
    elseif string.find(spawnedUnit:GetUnitName(), "hunter") then
    	spawnedUnit:AddItem(itemslotlock1)
        spawnedUnit:AddItem(itemslotlock2)
    	spawnedUnit:AddItem(itemslotlock3)
     --	if spawnedUnit:GetClassname() == "scout" then
    elseif string.find(spawnedUnit:GetUnitName(), "scout") and string.find(spawnedUnit:GetUnitName(), "hero") then
    	spawnedUnit:AddItem(itemslotlock1)
     --	if spawnedUnit:GetClassname() == "priest" then
     -- if spawnedUnit:(string.find(targetName,"priest") ~= nil) then 
    elseif string.find(spawnedUnit:GetUnitName(), "priest") then
    	spawnedUnit:AddItem(itemslotlock1)
        spawnedUnit:AddItem(itemslotlock2)
     --	if spawnedUnit:GetClassname() == "theif" then
     -- if spawnedUnit:(string.find(targetName,"thief") ~= nil) then 
     elseif string.find(spawnedUnit:GetUnitName(), "thief") and string.find(spawnedUnit:GetUnitName(), "hero") then
    	spawnedUnit:AddItem(itemslotlock1)
     --	if spawnedUnit:GetClassname() == "beastmaster" then
     -- if spawnedUnit:(string.find(targetName,"beastmaster") ~= nil) then 
    elseif string.find(spawnedUnit:GetUnitName(), "beastmaster") then
    	spawnedUnit:AddItem(itemslotlock1)
        spawnedUnit:AddItem(itemslotlock2)
    else  
        print(spawnedUnit:GetUnitName() .. " is not a subclass")
    end 

    --heat handling
    if string.find(spawnedUnit:GetUnitName(), "hero") then
        print("HEAT2!")
        spawnedUnit:RemoveModifierByName("modifier_heat_passive") 
        local heatApplier = CreateItem("item_heat_modifier_applier", spawnedUnit, spawnedUnit)
        heatApplier:ApplyDataDrivenModifier(spawnedUnit, spawnedUnit, "modifier_heat_passive", {duration=-1})
        spawnedUnit:SetModifierStackCount("modifier_heat_passive", nil, 100)
    end

    --meat handling
    if string.find(spawnedUnit:GetClassname(), "hero") then
        print("MEAT!")
        spawnedUnit:RemoveModifierByName("modifier_meat_passive")
        local heatApplier = CreateItem("item_meat_modifier_applier", spawnedUnit, spawnedUnit)
        heatApplier:ApplyDataDrivenModifier(spawnedUnit, spawnedUnit, "modifier_meat_passive", {duration=-1})
        spawnedUnit:SetModifierStackCount("modifier_meat_passive", nil, 0)
    end
end

function ITT_GameMode:OnEntityKilled(keys)
    local dropTable = {
        --{"unit_name", {"item_1", drop_chance}, {"mutually_exclusive_item_1", "mutually_exclusive_item_2", drop_chance}},
        {"npc_creep_elk_wild", {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_hide_elk", 100}, {"item_bone", 100}},
        {"npc_creep_wolf_jungle", {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_hide_wolf", 100}, {"item_bone", 100}},
        {"npc_creep_bear_jungle", {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_hide_jungle_bear", 100}, {"item_bone", 100}},
        {"npc_creep_bear_jungle_adult", {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_hide_jungle_bear", 100}, {"item_bone", 100}},
        {"npc_creep_panther", {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_bone", 100}, {"item_bone", 100}},
        {"npc_creep_panther_elder", {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_bone", 100}, {"item_bone", 100}},
        {"npc_creep_lizard", {"item_meat_raw", 100}},
        {"npc_creep_fish_green", {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}},
        {"npc_creep_fish", {"item_meat_raw", 100}},
        {"npc_creep_hawk", {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_bone", 100}, {"item_egg_hawk", 10}}
    }
	local spawnTable = { 
						{"npc_creep_elk_wild","npc_creep_fawn"}, 
						{"npc_creep_wolf_jungle","npc_creep_wolf_pup"},
						{"npc_creep_bear_jungle","npc_creep_bear_cub"},
						{"npc_creep_bear_jungle_adult","npc_creep_bear_cub"}}
       
    local killedUnit = EntIndexToHScript(keys.entindex_killed)
    local killer = EntIndexToHScript(keys.entindex_attacker)
    -- local keys.entindex_inflictor --long
    -- local keys.damagebits --long
    local unitName = killedUnit:GetUnitName() 
    print(unitName .. " has been killed")
    if string.find(unitName, "building") then
        killedUnit:RemoveBuilding(2, false)
    end

    --deal with killed heros
    if killedUnit:IsHero() then
        --if it's a hero, drop all carried raw meat, plus 3, and a bone
        meatStacks = killedUnit:GetModifierStackCount("modifier_meat_passive", nil)
        for i= 1, meatStacks+3, 1 do
            local newItem = CreateItem("item_meat_raw", nil, nil)
            CreateItemOnPositionSync(killedUnit:GetOrigin() + RandomVector(RandomInt(20,100)), newItem) 
        end
        local newItem = CreateItem("item_bone", nil, nil)
        CreateItemOnPositionSync(killedUnit:GetOrigin() + RandomVector(RandomInt(20,100)), newItem) 
    end

    --drop system
    for _,v in pairs(dropTable) do
        if unitName == v[1] then
            for itemNum = 2,#v,1 do
                itemName = v[itemNum][1]
                itemChance = v[itemNum][2]

                if RandomInt(0, 100) <= itemChance then
                    local newItem = CreateItem(itemName, nil, nil)
                    CreateItemOnPositionSync(killedUnit:GetOrigin() + RandomVector(RandomInt(20,100)), newItem) 
                end
            end
        end
    end
	
	--spawn young animals
	local dieRoll = RandomInt(1,20)
	local chance = 1
	local bonusChance = killedUnit:GetModifierStackCount("modifier_spawn_chance",nil)
	if bonusChance ~= nil then
		chance = chance + bonusChance
	end
	
	if dieRoll <= chance then
		print("Success! Spawning young animal")
		for _,v in pairs(spawnTable) do
			if unitName == v[1] then
				CreateUnitByName(v[2],killedUnit:GetOrigin(), true,nil,nil,killer:GetTeam()) 
			end
		end
	end

    --tracking number of neutrals
    --local numOfUnit = GameMode.neutralCurNum[unitName]
    if GameMode.neutralCurNum[unitName] ~= nil then
        GameMode.neutralCurNum[unitName] = GameMode.neutralCurNum[unitName] - 1
    end
end

function ITT_GameMode:OnDotaPlayerKilled(keys)
    local playerId = keys.PlayerID
    print(playerId)
    --print(PlayerResource:GetPlayer(playerID):GetAssignedHero())
end

function ITT_GameMode:On_entity_hurt(data)
    --print("entity_hurt")
    local attacker = EntIndexToHScript(data.entindex_attacker)
    local killed = EntIndexToHScript(data.entindex_killed)
    if (string.find(killed:GetUnitName(), "elk") or string.find(killed:GetUnitName(), "fish") or string.find(killed:GetUnitName(), "hawk")) then
        killed.state = "flee"
    end
    --print("attacker: "..attacker:GetUnitName(), "killed: "..killed:GetUnitName())

end

function ITT_GameMode:FixDropModels(dt)
    for _,v in pairs(Entities:FindAllByClassname("dota_item_drop")) do
        if not v.ModelFixInit then
            print("initing.. " .. v:GetContainedItem():GetAbilityName())
            v.ModelFixInit = true
            v.OriginalOrigin = v:GetOrigin()
            v.OriginalAngles = v:GetAngles()
            local custom = itemKeyValues[v:GetContainedItem():GetAbilityName()].Custom 
            if custom then
                --print("found custom")
                if custom.ModelOffsets then
                    local offsets = itemKeyValues[v:GetContainedItem():GetAbilityName()].Custom.ModelOffsets          
                    v:SetOrigin( v.OriginalOrigin - Vector(offsets.Origin.x, offsets.Origin.y, offsets.Origin.z))
                    v:SetAngles( v.OriginalAngles.x - offsets.Angles.x, v.OriginalAngles.y - offsets.Angles.y, v.OriginalAngles.z - offsets.Angles.z)
                end
                if custom.ModelScale then v:SetModelScale(custom.ModelScale) end
            end
        end
    end
    return DROPMODEL_TICK_TIME
end

-- This updates state on each troll
-- Every half second it updates heat, checks inventory for items, etc
-- Add anything you want to run regularly on each troll to this

function ITT_GameMode:OnTrollThink()

    if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        -- Will not run until pregame ends
        return 1
    end
    
    -- This will run on every player, do stuff here
    for i=1, maxPlayerID, 1 do
        Hunger(i)
		Energy(i)
        Heat(i)
        InventoryCheck(i)
        --print("burn")
    end
    return GAME_TROLL_TICK_TIME
end

function ITT_GameMode:OnBuildingThink()

    if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        -- Will not run until pregame ends
        return 1
    end
            
    -- Find all buildings
    buildings = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
                                  Vector(0, 0, 0),
                                  nil,
                                  FIND_UNITS_EVERYWHERE,
                                  DOTA_UNIT_TARGET_TEAM_BOTH,
                                  DOTA_UNIT_TARGET_BUILDING,
                                  DOTA_UNIT_TARGET_FLAG_NONE,
                                  FIND_ANY_ORDER,
                                  false)
    --check each for their type, and run crafting with the corresponding table
    for i=1, #buildings do
        if buildings[i]:GetUnitName() == "npc_building_armory" then
            CraftItems(buildings[i], ARMORY_RECIPE_TABLE, ITEM_ALIAS_TABLE)
        elseif buildings[i]:GetUnitName() == "npc_building_workshop" then
            CraftItems(buildings[i], WORKSHOP_RECIPE_TABLE, ITEM_ALIAS_TABLE)
        elseif buildings[i]:GetUnitName() == "npc_building_hut_witch_doctor" then
            CraftItems(buildings[i], WDHUT_RECIPE_TABLE, ITEM_ALIAS_TABLE)
        end
    end
    return GAME_TROLL_TICK_TIME
end

-- This is similar, but handles spawning creatures
function ITT_GameMode:OnCreatureThink()

    MAXIMUM_PASSIVE_NEUTRALS    = 300 --this isn't implemented yet
    MAXIMUM_AGGRESSIVE_NEUTRALS = 20

    neutralSpawnTable = {
        --{"creep_name", "spawner_name", spawn_chance, number_to_spawn},
        {"npc_creep_elk_wild",      "spawner_neutral_elk",      100, 2},
        {"npc_creep_hawk",          "spawner_neutral_hawk",     100, 2},
        {"npc_creep_fish",          "spawner_neutral_fish",     100, 5},
        {"npc_creep_fish_green",    "spawner_neutral_fish",     100, 2},
        {"npc_creep_wolf_jungle",   "spawner_neutral_wolf",     100, 1},
        {"npc_creep_bear_jungle",   "spawner_neutral_bear",     100, 1},
        {"npc_creep_lizard",        "spawner_neutral_lizard",   100, 1},
        {"npc_creep_panther",       "spawner_neutral_panther",  100, 1},
        {"npc_creep_panther_elder", "spawner_neutral_panther",  100, 1},
    }
    neutralMaxTable = {}
        neutralMaxTable["npc_creep_elk_wild"] = 20
        neutralMaxTable["npc_creep_hawk"] = 8
        neutralMaxTable["npc_creep_fish"] = 20
        neutralMaxTable["npc_creep_fish_green"] = 10
        neutralMaxTable["npc_creep_wolf_jungle"] = 12
        neutralMaxTable["npc_creep_bear_jungle"] = 8
        neutralMaxTable["npc_creep_lizard"] = 8
        neutralMaxTable["npc_creep_panther"] = 4
        neutralMaxTable["npc_creep_panther_elder"] = 4

    for _,v in pairs(neutralSpawnTable) do
        local creepName = v[1]
        local spawnerName = v[2]
        local spawnChance = v[3]
        local numToSpawn = v[4]

        for i=1,numToSpawn do
            if (spawnChance >= RandomInt(1, 100)) and (GameMode.neutralCurNum[creepName] < neutralMaxTable[creepName]) then
                SpawnCreature(creepName, spawnerName)
            end
        end
    end

    return GAME_CREATURE_TICK_TIME
end

-- The only real way of triggering code in Scaleform, events, are not reliable. Require acknowledgement of all events fired for this purpose.
function ITT_GameMode:FlashAckThink()
    --print("ackthink!")
    for i=0,9 do
        local player = PlayerResource:GetPlayer(i)
        if player and player.eventQueue then
            for k,v in pairs(player.eventQueue) do

                if v then 
                    print(k)
                    self:HandleFlashMessage(v.eventname, v.data, i, v.id)
                end
            end
        end
    end
    return FLASH_ACK_THINK
end

-- pid and id optional
function ITT_GameMode:HandleFlashMessage(eventname, data, pid, id)
    local id = id or DoUniqueString("")
    print("Setting ID to .." .. id)
    data.id = id
    if pid then
        print("Forcing ACK for only.. " .. pid) 
        local player = PlayerResource:GetPlayer(pid)
        self:PrepFlashMessage(player, eventname, data, id)
    else 
        data.pid = -1
        for i=0,9 do
            local player = PlayerResource:GetPlayer(i)
            if player then self:PrepFlashMessage(player, eventname, data, id) end
        end
    end
    FireGameEvent(eventname, data)
end

function ITT_GameMode:PrepFlashMessage(player, eventname, data, id)
    if not player.eventQueue then player.eventQueue = {} end
    player.eventQueue[id] = {eventname = eventname, data = data, id = id}
end

function acknowledge_flash_event(cmdname, eventname, pid, id)
    print("Got an ack from .." .. pid)
    local player = PlayerResource:GetPlayer(tonumber(pid))
    if player.eventQueue then 
        print("nilling then.." .. id)
        print(player.eventQueue[id])
        player.eventQueue[id] = nil 
    end
end


function ITT_GameMode:OnBushThink()
    -- Find all bushes
    --print("bush think")
    units = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
                                  Vector(0, 0, 0),
                                  nil,
                                  FIND_UNITS_EVERYWHERE,
                                  DOTA_UNIT_TARGET_TEAM_BOTH,
                                  DOTA_UNIT_TARGET_ALL,
                                  DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                                  FIND_ANY_ORDER,
                                  false)
    for i=1, #units do
        if units[i]:GetItemInSlot(5) == nil then
            --print(units[i]:GetUnitName(), units[i]:GetName())
            if units[i]:GetUnitName() == "npc_bush_herb" then
                local newItem = CreateItem("item_herb_butsu", nil, nil)
                units[i]:AddItem(newItem)
                --print("adding butsu")
            elseif units[i]:GetUnitName() == "npc_bush_thistle" then
                local newItem = CreateItem("item_thistles", nil, nil)
                units[i]:AddItem(newItem)
                --print("adding thistle")
            elseif units[i]:GetUnitName() == "npc_bush_river" then
                if RandomInt(0, 1) == 1 then
                    local newItem = CreateItem("item_river_root", nil, nil)
                    units[i]:AddItem(newItem)
                else
                    local newItem = CreateItem("item_river_stem", nil, nil)
                    units[i]:AddItem(newItem)
                end
                --print("adding river")
            elseif units[i]:GetUnitName() == "npc_bush_stash" then
                local random = RandomInt(0, 3)
                if random == 0 then
                    local newItem = CreateItem("item_acorn", nil, nil)
                    units[i]:AddItem(newItem)
                elseif  random == 1 then
                    local newItem = CreateItem("item_acorn_magic", nil, nil)
                    units[i]:AddItem(newItem)
                elseif  random == 2 then
                    local newItem = CreateItem("item_ball_clay", nil, nil)
                    units[i]:AddItem(newItem)
                else
                    local newItem = CreateItem("item_mushroom", nil, nil)
                    units[i]:AddItem(newItem)
                end
                --print("adding stash")
            elseif units[i]:GetUnitName() == "npc_bush_thief" then
                local random = RandomInt(0, 6)
                if random == 1 then
                    local newItem = CreateItem("item_meat_cooked", nil, nil)
                    units[i]:AddItem(newItem)
                elseif  random == 2 then
                    local newItem = CreateItem("item_net_basic", nil, nil)
                    units[i]:AddItem(newItem)
                elseif  random == 3 then
                    local newItem = CreateItem("item_potion_manai", nil, nil)
                    units[i]:AddItem(newItem)
                elseif  random == 4 then
                    local newItem = CreateItem("item_crystal_mana", nil, nil)
                    units[i]:AddItem(newItem)
                elseif  random == 5 then
                    local newItem = CreateItem("item_bomb_smoke", nil, nil)
                    units[i]:AddItem(newItem)
                else
                    local newItem = CreateItem("item_medallion_thief", nil, nil)
                    units[i]:AddItem(newItem)
                end
                --print("adding theif")
            elseif units[i]:GetUnitName() == "npc_bush_scout" then
                if RandomInt(0, 1) == 1 then
                    local newItem = CreateItem("item_clay_living", nil, nil)
                    units[i]:AddItem(newItem)
                else
                    local newItem = CreateItem("item_clay_explosion", nil, nil)
                    units[i]:AddItem(newItem)
                end
                --print("adding scout")
            elseif units[i]:GetUnitName() == "npc_bush_mushroom" then
                local newItem = CreateItem("item_mushroom", nil, nil)
                units[i]:AddItem(newItem)
                --print("adding mushroom")
            elseif units[i]:GetUnitName() == "npc_bush_herb_yellow" then
                local newItem = CreateItem("item_herb_yellow", nil, nil)
                units[i]:AddItem(newItem)
                --print("adding yellow")
            elseif units[i]:GetUnitName() == "npc_bush_herb_orange" then
                local newItem = CreateItem("item_herb_orange", nil, nil)
                units[i]:AddItem(newItem)
                --print("adding orange")
            elseif units[i]:GetUnitName() == "npc_bush_herb_blue" then
                local newItem = CreateItem("item_herb_blue", nil, nil)
                units[i]:AddItem(newItem)
                --print("adding blue")
            elseif units[i]:GetUnitName() == "npc_bush_herb_purple" then
                local newItem = CreateItem("item_herb_purple", nil, nil)
                units[i]:AddItem(newItem)
                --print("adding purple")
            end
        end
    end

    return GAME_BUSH_TICK_TIME
end

function ITT_GameMode:OnBoatThink()
    local currentTime = math.floor(GameRules:GetGameTime())
    local numShopsSpawned = 0
    for k,_ in pairs(GameMode.spawnedShops) do
        numShopsSpawned = numShopsSpawned + 1
    end

    if numShopsSpawned < MAX_SHOPS_ON_MAP then
        local pathNum = RandomInt(1, #PATH_LIST)
        local path = PATH_LIST[pathNum]

        local initialWaypoint = Entities:FindByName(nil, path[1])
        local spawnOrigin = initialWaypoint:GetOrigin()

        local merchantNum = RandomInt(1, TOTAL_SHOPS)
        unitName = SHOP_UNIT_NAME_LIST[merchantNum]
        local shopUnit = CreateUnitByName(unitName, spawnOrigin, false, nil, nil, DOTA_TEAM_NEUTRALS)
        shopUnit.path = path
        print("Spawning " .. unitName .. " on path " .. pathNum .. " at time " .. currentTime)
    end

    for _,shopUnit in pairs(GameMode.spawnedShops) do
        local shopent = nil
        for _,entity in pairs(GameMode.shopEntities) do 
            local nameToFind = string.sub(shopUnit:GetUnitName(), 5)
            if string.find(entity:GetName(), nameToFind) then
                shopent = entity
            end
        end
        
        if shopent == nil then
            print("No Shop Ent Found!")
            return 0.1
        end

        --local shopent = Entities:FindAllByClassname("ent_dota_shop")
        if shopUnit ~= nil then
            if shopUnit:IsAlive() then
                shopent:SetOrigin(shopUnit:GetOrigin())
                shopent:SetForwardVector(shopUnit:GetForwardVector())
            else
                shopent:SetOrigin(Vector(10000,10000,120))
            end
        else
            shopent:SetOrigin(Vector(10000,10000,120))
        end
    end

    return 0.1
end


--
-- This handles spawning items
--
-- Code by Till Elton
--
function ITT_GameMode:OnItemThink()
    --print("Item think tick started")
    if REL_TINDER_RATE == 0 then
        ITT_UpdateRelativePool()
    else
        ITT_AdjustItemSpawns()
    end
    --print("hit mid of spawn items")
    for i=1, #REGIONS, 1 do
        for ii=1, math.floor(ITEM_BASE * REGIONS[i][5]), 1 do
            --print("Spawning an item on island" .. i)
            item = ITT_SpawnItem(REGIONS[i])
        end
    end
    --print("Item think tick ended")
    return GAME_ITEM_TICK_TIME
end

function ITT_SpawnItem(island)
    local itemSpawned = ITT_GetItemFromPool()
    --print(itemSpawned)
    local item = CreateItem(itemSpawned, nil, nil)
    --item:SetPurchaseTime(Time)
    local randomVector = GetRandomVectorGivenBounds(island[1], island[2], island[3], island[4])
    --print(item:GetName().." spawned at " .. randomVector.x .. ", " .. randomVector.y)
    CreateItemOnPositionSync(randomVector, item)
    item:SetOrigin(randomVector)
end

-- Updates the relative probabilties, called only when the actual probabilties are changed
-- They from the point in which they are generated, sum to 1
function ITT_UpdateRelativePool()
    --print("Updating relative item probabilties")
    local Total = TINDER_RATE + FLINT_RATE + STICK_RATE + CLAYBALL_RATE + STONE_RATE + MANACRYSTAL_RATE + MAGIC_RATE
    REL_TINDER_RATE      = TINDER_RATE      / Total
    REL_FLINT_RATE       = FLINT_RATE       / Total
    REL_STICK_RATE       = STICK_RATE       / Total
    REL_CLAYBALL_RATE    = CLAYBALL_RATE    / Total
    REL_STONE_RATE       = STONE_RATE       / Total
    REL_MANACRYSTAL_RATE = MANACRYSTAL_RATE / Total
    REL_MAGIC_RATE       = MAGIC_RATE       / Total
end

-- Go though each item, order should not be relevant
function ITT_GetItemFromPool()
    local cumulProb = 0.0
    local rand      = RandomFloat(0,1)

    cumulProb = cumulProb + REL_TINDER_RATE
    if rand <= cumulProb then
        return "item_tinder"
    end

    cumulProb = cumulProb + REL_FLINT_RATE
    if rand <= cumulProb then
        return "item_flint"
    end

    cumulProb = cumulProb + REL_STICK_RATE
    if rand <= cumulProb then
        return "item_stick"
    end

    cumulProb = cumulProb + REL_CLAYBALL_RATE
    if rand <= cumulProb then
        return "item_ball_clay"
    end

    cumulProb = cumulProb + REL_STONE_RATE
    if rand <= cumulProb then
        return "item_stone"
    end

    cumulProb = cumulProb + REL_MANACRYSTAL_RATE
    if rand <= cumulProb then
        return "item_crystal_mana"
    end

    cumulProb = cumulProb + REL_MAGIC_RATE
    if rand <= cumulProb then
        return "item_magic_raw"
    end
    
    print("Should never happen, error in item spawning, commulative probability higher than items")
    print("cummulprob = " .. cumulProb)
    print("rand is " .. rand)
end

-- Item spawn distribution changes, later in the game it tends to a different ratio
-- From https://github.com/island-troll-tribes/wc3-client/blob/1562854dd098180752f0f4a99df0c4968697b38b/src/lib/PublicLibrary.j#L271-L292

function ITT_AdjustItemSpawns()
    --print("adjusting item spawns")
    FLINT_RATE = math.max(2.0,(FLINT_RATE-0.4))
    MANACRYSTAL_RATE = math.min(1.6,(MANACRYSTAL_RATE+0.5))
    STONE_RATE = math.min(3.3,(STONE_RATE+0.5))
    STICK_RATE = math.min(4.5,(STICK_RATE+0.5))
    TINDER_RATE = math.max(.7,(TINDER_RATE-0.6))
    CLAYBALL_RATE = math.min(1.85,(CLAYBALL_RATE+0.3))
    -- I don't get how item base works, it always seems too low in the wc3 file disabled for the moment since it breaks everything, any help?
    -- ITEM_BASE = math.max(1.15,(ITEM_BASE-0.2))
    ITT_UpdateRelativePool()
end

-- Gets a random vector in a specific area
function GetRandomVectorGivenBounds(minx, miny, maxx, maxy)
    return Vector(RandomFloat(minx, miny),RandomFloat(maxx, maxy),0)
end

-- Gets a random vector on the map
function GetRandomVectorInBounds()
    return Vector(RandomFloat(GetWorldMinX(), GetWorldMaxX()),RandomFloat(GetWorldMinY(), GetWorldMaxY()),0)
end

--
-- END OF ITEM SPAWNING
--

-- This will handle anything gamestate related that is not covered under other thinkers
function ITT_GameMode:OnStateThink()
    --print(GameRules:State_Get())
    return GAME_TICK_TIME
    --GameRules:MakeTeamLose(3)
    -- GameRules:SetGameWinner(1)
    --local player = PlayerInstanceFromIndex(1)
    --print(player:GetAssignedHero())
    --player:SetTeam(2)
    --print(player:GetTeam())
end

-- When players connect, add them to the players list and begin operations on them
function ITT_GameMode:OnPlayerConnectFull(keys)
    local playerID = keys.index + 1
    --local player = PlayerInstanceFromIndex(playerID)
    print( "Player " .. playerID .. " connected")
    
    playerList[playerID] = playerID
    maxPlayerID = maxPlayerID + 1
end

--Listener to handle telegather events from item pickup and picking up raw meat
function ITT_GameMode:OnItemPickedUp(event)
    local hero = EntIndexToHScript( event.HeroEntityIndex )

    if event.itemname == "item_meat_raw" then
        local meatStacks = hero:GetModifierStackCount("modifier_meat_passive", nil)
        if meatStacks < 10 then
            hero:SetModifierStackCount("modifier_meat_passive", nil, meatStacks + 1)
            for itemSlot = 0, 5, 1 do
                local Item = hero:GetItemInSlot( itemSlot )
                if (Item ~= nil) and (Item:GetName() == "item_meat_raw") then
                    hero:RemoveItem(Item)
                end
            end
        else
            for itemSlot = 0, 5, 1 do
                local Item = hero:GetItemInSlot( itemSlot )
                if (Item ~= nil) and (Item:GetName() == "item_meat_raw") then
                    local itemCharges = Item:GetCurrentCharges()
                    local newItem = CreateItem(Item:GetName(), nil, nil)
                    newItem:SetCurrentCharges(itemCharges)
                    CreateItemOnPositionSync(hero:GetOrigin() + RandomVector(RandomInt(50,50)), newItem)
                    hero:RemoveItem(Item)
                end
            end
        end

    end

    local hasTelegather = hero:HasModifier("modifier_telegather")
    
    if hasTelegather then
        RadarTelegather(event)
    end
end

--Listener to handle level up
function ITT_GameMode:OnPlayerGainedLevel(event)
	print("PlayerGainedLevel")
	local player = EntIndexToHScript(event.player)
	local hero = player:GetAssignedHero()
	local class = hero:GetClassname()
	local level = event.level
	
	-- contains skill progression for all classes
	-- first list denotes level 2 skills, since level 1 skills are automatically granted on spawning
	local skillProgression = {
		{HUNTER,
			{"ability_hunter_track"},
			{"ability_hunter_track"},
			{"ability_hunter_track"}
		},
		--{WARRIOR,}
		--{TRACKER,}
		--{JUGGERNAUT,}
		
		{MAGE,
			{"ability_mage_swap1","ability_mage_swap2","ability_mage_pumpup","ability_mage_flamespray","ability_mage_negativeblast"},
			{"ability_mage_reducefood","ability_mage_magefire","ability_mage_depress"},
			{"ability_mage_metronome"}
		},
		--{ELEMENTALIST,}
		--{HYPNOTIST,}
		--{DEMENTIA_MASTER,}
		
		{PRIEST,
			{"ability_priest_cureall","ability_priest_pumpup","ability_priest_resistall"},
			{"ability_priest_swap1","ability_priest_swap2","ability_priest_sprayhealing","ability_priest_pacifyingsmoke"},
			{"ability_priest_mixheat","ability_priest_mixhealth","ability_priest_mixenergy"}
		},
		--{BOOSTER},
		--{MASTER_HEALER},
		--{SHAMAN,}
		
		{BEASTMASTER,
			{},
			{},
			{},
			{},
			{}
		},
		--{CHICKEN_FORM,}
		--{PACK_LEADER,}
		--{SHAPESHIFTER,}
		
		{THIEF,
			{"ability_thief_teleport"},
			{"ability_thief_teleport"},
			{},
			{"ability_thief_teleport"}
		},
		--{ESCAPE_ARTIST,}
		--{CONTORTIONIST,}
		--{ASSASSIN,}
		
		{SCOUT,
			{"ability_scout_reveal"},
			{"ability_scout_reveal"},
			{},
			{"ability_scout_reveal"}
		},
		--{OBSERVER,}
		--{RADAR_SCOUT,}
		--{SPY,}
		
		{GATHERER,
			{"ability_gatherer_radarmanipulations"},
			{"ability_gatherer_radarmanipulations"},
			{"ability_gatherer_radarmanipulations"}
		}
		--{HERB_MASTER_TELEGATHERER,}
		--{RADAR_TELEGATHERER,}
		--{REMOTE_TELEGATHERER,}	
	}

	-- grant skills 
	for _,skillList in pairs(skillProgression) do
		if skillList[1] == class then
			local skills = skillList[level]
			if skills ~= nil then
				for _,skill in pairs(skills) do
					hero:FindAbilityByName(skill):UpgradeAbility(true)
				end
			end
		end
	end
end

function give_item(cmdname, itemname)
    local hero = Convars:GetCommandClient():GetAssignedHero()
    hero:AddItem(CreateItem(itemname, hero, hero))
end

function print_dropped_vecs(cmdname)
    local items = Entities:FindAllByClassname("dota_item_drop")
    for _,v in pairs(items) do
        print(v:GetClassname())
        local now = v:GetOrigin()
        v:SetOrigin(Vector(now.x, now.y, now.z - 146))
        v:SetModelScale(1.8)
    end
end

function print_fix_diffs(cmdname)
    local items = Entities:FindAllByClassname("dota_item_drop")
    for _,v in pairs(items) do
        local angs = v:GetAngles()
        local difforig = v.OriginalOrigin - v:GetOrigin()
        local diffangs = {x = v.OriginalAngles.x - angs.x, y = v.OriginalAngles.y - angs.y, z = v.OriginalAngles.z - angs.z} --i dunno either, exception w/o :__sub just for this
        print(v:GetContainedItem():GetAbilityName() .. " Offsets: ")
        print("\"Custom\"")
        print("{")
        print("    \"ModelOffsets\"")
        print("    {")
        print("        \"Origin\"")
        print("        {")
        print("            \"x\" \"" .. difforig.x .. "\"")
        print("            \"y\" \"" .. difforig.x .. "\"")
        print("            \"z\" \"" .. difforig.z .. "\"")
        print("        }")
        print("        \"Angles\"")
        print("        {")
        print("            \"x\" \"" .. diffangs.x .. "\"")
        print("            \"y\" \"" .. diffangs.x .. "\"")
        print("            \"z\" \"" .. diffangs.z .. "\"")
        print("        }")
        print("    }")
        print("}")
    end
end

function reload_ikv(cmdname)
    itemKeyValues = LoadKeyValues("scripts/npc/npc_items_custom.txt")
end

function test_ack(cmdname)
    ITT_GameMode:HandleFlashMessage("fl_level_6", {pid = -1, gameclass = "gatherer"})
end

function test_ack_sec(cmdname)
    ITT_GameMode:HandleFlashMessage("fl_level_6", {pid = Convars:GetCommandClient():GetPlayerID()})
end

function make(cmdname, unitname)
    local player = Convars:GetCommandClient()
    local hero = player:GetAssignedHero()
    CreateUnitByName(unitname, hero:GetOrigin(), true, hero, hero, 2)
end

Convars:RegisterCommand("make", function(cmdname, unitname) make(cmdname, unitname) end, "Give any item", 0)
Convars:RegisterCommand("test_ack_sec", function(cmdname) test_ack_sec(cmdname) end, "Give any item", 0)
Convars:RegisterCommand("test_ack", function(cmdname) test_ack(cmdname) end, "Give any item", 0)
Convars:RegisterCommand("acknowledge_flash_event", function(cmdname, eventname, pid, id) acknowledge_flash_event(cmdname, eventname, pid, id) end, "Give any item", 0)
Convars:RegisterCommand("reload_ikv", function(cmdname) reload_ikv(cmdname) end, "Give any item", 0)
Convars:RegisterCommand("print_fix_diffs", function(cmdname) print_fix_diffs(cmdname) end, "Give any item", 0)
Convars:RegisterCommand("print_dropped_vecs", function(cmdname) print_dropped_vecs(cmdname) end, "Give any item", 0)
Convars:RegisterCommand("give_item", function(cmdname, itemname) give_item(cmdname, itemname) end, "Give any item", 0)

--multiteam stuff

---------------------------------------------------------------------------
-- Game state change handler
---------------------------------------------------------------------------
function ITT_GameMode:OnGameRulesStateChange()
    local nNewState = GameRules:State_Get()
--  print( "OnGameRulesStateChange: " .. nNewState )

    if nNewState == DOTA_GAMERULES_STATE_HERO_SELECTION then
        print("DOTA_GAMERULES_STATE_HERO_SELECTION")
        --self:AssignAllPlayersToTeams()
        GameRules:GetGameModeEntity():SetThink( "BroadcastPlayerTeamAssignments", self, 0 ) -- can't do this immediately because the player resource doesn't have the names yet
    end
end

---------------------------------------------------------------------------
-- Helper functions
---------------------------------------------------------------------------
function ShuffledList( list )
    local result = {}
    local count = #list
    for i = 1, count do
        local pick = RandomInt( 1, #list )
        result[ #result + 1 ] = list[ pick ]
        table.remove( list, pick )
    end
    return result
end

function TableCount( t )
    local n = 0
    for _ in pairs( t ) do
        n = n + 1
    end
    return n
end

---------------------------------------------------------------------------
-- Scan the map to see which teams have spawn points
---------------------------------------------------------------------------
function ITT_GameMode:GatherValidTeams()
  print( "GatherValidTeams:" )

    local foundTeams = {}
    for _, playerStart in pairs( Entities:FindAllByClassname( "info_player_start_dota" ) ) do
        foundTeams[  playerStart:GetTeam() ] = true
    end

  print( "GatherValidTeams - Found spawns for a total of " .. TableCount(foundTeams) .. " teams" )
    
    local foundTeamsList = {}
    for t, _ in pairs( foundTeams ) do
        table.insert( foundTeamsList, t )
    end

    self.m_GatheredShuffledTeams = foundTeamsList
    print("gather shuffled teams", self.m_GatheredShuffledTeams, #self.m_GatheredShuffledTeams, #foundTeamsList)
    print( "Final shuffled team list:" )
    for _, team in pairs( self.m_GatheredShuffledTeams ) do
     print( " - " .. team .. " ( " .. GetTeamName( team ) .. " )" )
    end
end


---------------------------------------------------------------------------
-- Assign all real players to a team
---------------------------------------------------------------------------
function ITT_GameMode:AssignAllPlayersToTeams()
  print( "Assigning players to teams..." )
    for playerID = 0, (DOTA_MAX_TEAM_PLAYERS-1) do
        if nil ~= PlayerResource:GetPlayer( playerID ) then
            local teamID = self:GetNextTeamAssignment()
            print( " - Player " .. playerID .. " assigned to team " .. teamID )
            PlayerResource:SetCustomTeamAssignment( playerID, teamID )
        end
    end
end

---------------------------------------------------------------------------
-- Get the color associated with a given teamID
---------------------------------------------------------------------------
function ITT_GameMode:ColorForTeam( teamID )
    local color = self.m_TeamColors[teamID]
    if color == nil then
        color = { 255, 255, 255 } -- default to white
    end
    return color
end

---------------------------------------------------------------------------
-- Determine a good team assignment for the next player
---------------------------------------------------------------------------
function ITT_GameMode:GetNextTeamAssignment()
    if #self.m_GatheredShuffledTeams == 0 then
      print( "CANNOT ASSIGN PLAYER - NO KNOWN TEAMS" )
        return DOTA_TEAM_NOTEAM
    end

    -- haven't assigned this player to a team yet
    print( "m_NumAssignedPlayers = " .. self.m_NumAssignedPlayers )
    
    -- If the number of players per team doesn't divide evenly (ie. 10 players on 4 teams => 2.5 players per team)
    -- Then this floor will round that down to 2 players per team
    -- If you want to limit the number of players per team, you could just set this to eg. 1
    local playersPerTeam = 3 --math.floor( DOTA_MAX_TEAM_PLAYERS / #self.m_GatheredShuffledTeams )
    print( "playersPerTeam = " .. playersPerTeam )

    local teamIndexForPlayer = math.floor( self.m_NumAssignedPlayers / playersPerTeam )
    print( "teamIndexForPlayer = " .. teamIndexForPlayer )

    -- Then once we get to the 9th player from the case above, we need to wrap around and start assigning to the first team
    if teamIndexForPlayer >= #self.m_GatheredShuffledTeams then
        teamIndexForPlayer = teamIndexForPlayer - #self.m_GatheredShuffledTeams
        print( "teamIndexForPlayer => " .. teamIndexForPlayer )
    end
    
    teamAssignment = self.m_GatheredShuffledTeams[ 1 + teamIndexForPlayer ]
    print( "teamAssignment = " .. teamAssignment )

    self.m_NumAssignedPlayers = self.m_NumAssignedPlayers + 1

    return teamAssignment
end


---------------------------------------------------------------------------
-- Put a label over a player's hero so people know who is on what team
---------------------------------------------------------------------------
function ITT_GameMode:MakeLabelForPlayer( nPlayerID )
    if not PlayerResource:HasSelectedHero( nPlayerID ) then
        return
    end

    local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
    if hero == nil then
        return
    end

    local teamID = PlayerResource:GetTeam( nPlayerID )
    local color = self:ColorForTeam( teamID )
    hero:SetCustomHealthLabel( GetTeamName( teamID ), color[1], color[2], color[3] )
end

---------------------------------------------------------------------------
-- Tell everyone the team assignments during hero selection
---------------------------------------------------------------------------
function ITT_GameMode:BroadcastPlayerTeamAssignments()
    print("BroadcastPlayerTeamAssignments")
    for nPlayerID = 0, (DOTA_MAX_TEAM_PLAYERS-1) do
        local nTeamID = PlayerResource:GetTeam( nPlayerID )
        if nTeamID ~= DOTA_TEAM_NOTEAM then
            GameRules:SendCustomMessage( "#TeamAssignmentMessage", nPlayerID, -1 )
        end
    end
end

---------------------------------------------------------------------------
-- Update player labels and the scoreboard
---------------------------------------------------------------------------
function ITT_GameMode:OnThink()
    for nPlayerID = 0, (DOTA_MAX_TEAM_PLAYERS-1) do
        self:MakeLabelForPlayer( nPlayerID )
    end
        
    return 1
end

function eval(...)
    local contents = {...}
    local str = ""
    for i,v in ipairs(contents) do
        str = str .. " " .. v  --assumes space separated this arg and the last
    end
    print(loadstring(str)())
end

Convars:RegisterCommand("reload_kv", function() GameRules:Playtesting_UpdateAddOnKeyValues() end, "aa", 0)
Convars:RegisterCommand("eval", function(cmdname, ...) eval(...) end, "aaa", 0)