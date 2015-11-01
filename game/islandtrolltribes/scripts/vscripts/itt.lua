print ('[ITT] itt.lua' )

TEAM_COLORS = {}
TEAM_COLORS[DOTA_TEAM_GOODGUYS] = { 52, 85, 255 }  -- Blue
TEAM_COLORS[DOTA_TEAM_BADGUYS]  = { 255, 52, 85 }  -- Red
TEAM_COLORS[DOTA_TEAM_CUSTOM_1] = { 243, 201, 9 }  -- Yellow
TEAM_COLORS[DOTA_TEAM_CUSTOM_2] = { 101, 212, 19 } -- Green

playerList = {}
maxPlayerID = 0

GAME_TICK_TIME              = 0.1   -- The game should update every tenth second
GAME_BUSH_TICK_TIME         = 30    -- 1in2 chance any bush will actually spawn so average timer is 2x
GAME_TROLL_TICK_TIME        = 0.5   -- Its really like its wc3!
FLASH_ACK_THINK             = 2
WIN_GAME_THINK              = 0.5 -- checks if you've won every x seconds

BUILDING_TICK_TIME          = 0.03
DROPMODEL_TICK_TIME         = 0.03

-- Grace period respawn time in seconds
GRACE_PERIOD_RESPAWN_TIME    = 3

DEBUG_SPEW = 1

-- Tick time is 300s
-- https://github.com/island-troll-tribes/wc3-client/blob/1562854dd098180752f0f4a99df0c4968697b38b/src/systems/spawning/Spawn%20Normal.j#L3
-- GAME_ITEM_TICK_TIME         = 300

-- Using a shorter time for testing's sake
--GAME_ITEM_TICK_TIME         = 15

-- If this is enabled the game is in testing mode, and as a result nobody can win
GAME_TESTING_CHECK          = true 
-- Use this variable for anything that can ONLY happen during testing
-- REMEMBER TO DISABLE BEFORE PUBLIC RELEASE

--Merchant Boat paths, and other lists
PATH1 = {"path_ship_waypoint_1","path_ship_waypoint_2","path_ship_waypoint_3","path_ship_waypoint_4","path_ship_waypoint_5", "path_ship_waypoint_6", "path_ship_waypoint_7"}
PATH2 = {"path_ship_waypoint_8","path_ship_waypoint_9","path_ship_waypoint_4","path_ship_waypoint_5", "path_ship_waypoint_6", "path_ship_waypoint_7"}
PATH3 = {"path_ship_waypoint_1","path_ship_waypoint_2","path_ship_waypoint_3","path_ship_waypoint_4","path_ship_waypoint_5", "path_ship_waypoint_10", "path_ship_waypoint_11", "path_ship_waypoint_12"}
PATH4 = {"path_ship_waypoint_8","path_ship_waypoint_9","path_ship_waypoint_4","path_ship_waypoint_5", "path_ship_waypoint_10", "path_ship_waypoint_11", "path_ship_waypoint_12"}
PATH_LIST = {PATH1, PATH2, PATH3, PATH4}
SHOP_UNIT_NAME_LIST = {"npc_ship_merchant_1", "npc_ship_merchant_2", "npc_ship_merchant_3"}
TOTAL_SHOPS = #SHOP_UNIT_NAME_LIST
MAX_SHOPS_ON_MAP = 1

-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function ITT:InitGameMode()
    GameMode = GameRules:GetGameModeEntity()

    -- DebugPrint
    Convars:RegisterConvar('debug_spew', tostring(DEBUG_SPEW), 'Set to 1 to start spewing debug info. Set to 0 to disable.', 0)

    -- Thinkers. Should get rid of these in favor of timers
    GameMode:SetThink( "OnBuildingThink", ITT, "BuildingThink", 0 )
    GameMode:SetThink( "OnItemThink", ITT, "ItemThink", 0 )
    GameMode:SetThink( "OnBushThink", ITT, "BushThink", 0 )
    GameMode:SetThink( "OnBoatThink", ITT, "BoatThink", 0 )
    
    boatStartTime = math.floor(GameRules:GetGameTime())
    GameMode.spawnedShops = {}
    GameMode.shopEntities = Entities:FindAllByName("entity_ship_merchant_*")

    GameMode:SetThink("FixDropModels", ITT, "FixDropModels", 0)

    -- Disable buybacks to stop instant respawning.
    GameMode:SetBuybackEnabled( false )
    GameMode:SetStashPurchasingDisabled(true)

    --GameRules:GetGameModeEntity():ClientLoadGridNav()
    GameRules:SetSameHeroSelectionEnabled( true )
    GameRules:SetTimeOfDay( 0.75 )
    GameRules:SetHeroRespawnEnabled( true )
    GameRules:SetHeroSelectionTime(0)
    GameRules:SetPreGameTime(GAME_PERIOD_GRACE)
    GameRules:SetPostGameTime( 60.0 )
    GameRules:SetTreeRegrowTime( 60.0 )
    GameRules:SetCreepMinimapIconScale( 0.7 )
    GameRules:SetRuneMinimapIconScale( 0.7 )
    GameRules:SetGoldTickTime( 60.0 )
    GameRules:SetGoldPerTick( 0 )

    -- Listeners
    ListenToGameEvent('player_connect_full', Dynamic_Wrap(ITT, 'OnPlayerConnectFull'), self)
    ListenToGameEvent( "npc_spawned", Dynamic_Wrap( ITT, "OnNPCSpawned" ), self )
    ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap(ITT, 'OnItemPickedUp'), self)
    ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap(ITT, 'OnPlayerGainedLevel'), self)
    ListenToGameEvent("entity_killed", Dynamic_Wrap( ITT, "OnEntityKilled" ), self )
    ListenToGameEvent("entity_hurt", Dynamic_Wrap(ITT, 'On_entity_hurt'), self)
    ListenToGameEvent('player_chat', Dynamic_Wrap(ITT, 'OnPlayerChat'), self)
    ListenToGameEvent("player_reconnected", Dynamic_Wrap(ITT, 'OnPlayerReconnected'), self)
    ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( ITT, 'OnGameRulesStateChange' ), self )

    -- Panorama Listeners
    CustomGameEventManager:RegisterListener( "update_selected_entities", Dynamic_Wrap(ITT, 'OnPlayerSelectedEntities'))
    CustomGameEventManager:RegisterListener( "player_selected_class", Dynamic_Wrap( ITT, "OnClassSelected" ) )
    CustomGameEventManager:RegisterListener( "player_selected_subclass", Dynamic_Wrap( ITT, "OnSubclassChange" ) )

    CustomGameEventManager:RegisterListener( "player_sleep", Dynamic_Wrap( ITT, "Sleep" ) )
    CustomGameEventManager:RegisterListener( "player_eat_meat", Dynamic_Wrap( ITT, "EatMeat" ) )
    CustomGameEventManager:RegisterListener( "player_drop_meat", Dynamic_Wrap( ITT, "DropMeat" ) )
    CustomGameEventManager:RegisterListener( "player_drop_all_meat", Dynamic_Wrap( ITT, "DropAllMeat" ) )
    CustomGameEventManager:RegisterListener( "player_panic", Dynamic_Wrap( ITT, "Panic" ) )

    CustomGameEventManager:RegisterListener( "player_bush_gather", Dynamic_Wrap( ITT, "BushGather" ) )

    -- Building Helper commands
    CustomGameEventManager:RegisterListener( "building_helper_build_command", Dynamic_Wrap(BuildingHelper, "BuildCommand"))
    CustomGameEventManager:RegisterListener( "building_helper_cancel_command", Dynamic_Wrap(BuildingHelper, "CancelCommand"))
    
    -- Store and update selected units of each pID
    GameRules.SELECTED_UNITS = {}

    -- Filters
    GameMode:SetExecuteOrderFilter( Dynamic_Wrap( ITT, "FilterExecuteOrder" ), self )
    GameMode:SetDamageFilter( Dynamic_Wrap( ITT, "FilterDamage" ), self )

    self.m_GatheredShuffledTeams = {}
    self.m_NumAssignedPlayers = 0

    -- Team Colors
    for team,color in pairs(TEAM_COLORS) do
        print("Color for team ",team,color[1], color[2], color[3])
        SetTeamCustomHealthbarColor(team, color[1], color[2], color[3])
    end

    -- Starting positions
    GameRules.StartingPositions = {}
    GameRules.StartingPositions["Radiant"] = {}
    GameRules.StartingPositions["Dire"] = {}
    GameRules.StartingPositions["Winter"] = {}
    GameRules.StartingPositions["Desert"] = {}
    local startEntities = Entities:FindAllByName( "start_*" )
    for k,v in pairs(startEntities) do
        local name = v:GetName()
        local posTable
        if string.match(name, "radiant_") then
            posTable = GameRules.StartingPositions["Radiant"]
        elseif string.match(name, "dire_") then
            posTable = GameRules.StartingPositions["Dire"]
        elseif string.match(name, "winter_") then
            posTable = GameRules.StartingPositions["Winter"]
        elseif string.match(name, "desert_") then
            posTable = GameRules.StartingPositions["Desert"]
        else
            print("What is this?",name)
        end

        pos_subtable = {}
        pos_subtable.playerID = -1 --Unassigned position
        pos_subtable.position = v:GetAbsOrigin()

        posTable[#posTable+1] = pos_subtable
    end

    -- Multiteams & randomized Island positions
    local islandList = {"Radiant", "Dire", "Winter", "Desert"}
    islandList = ShuffledList(islandList)

    VALID_TEAMS = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS, DOTA_TEAM_CUSTOM_1, DOTA_TEAM_CUSTOM_2}
    TEAM_ISLANDS = {}

    for k,v in pairs(VALID_TEAMS) do
        GameRules:SetCustomGameTeamMaxPlayers( v, 4 )
        TEAM_ISLANDS[v] = islandList[k]
    end

    self.vUserIds = {}
    self.vPlayerUserIds = {}

    --initial bush spawns
    --place entities starting with spawner_ plus the appropriate name to spawn to corresponding bush on game start
    local bush_herb_spawners = Entities:FindAllByClassname("npc_dota_spawner")
    GameRules.Bushes = {}
    for _,spawner in pairs(bush_herb_spawners) do
        local spawnerName = spawner:GetName()
        if string.find(spawnerName, "_bush_") then
            local bush_name = string.sub(string.gsub(spawner:GetName(), "spawner_", ""), 5)
            local bush = CreateUnitByName(bush_name, spawner:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)
            if bush then
                table.insert(GameRules.Bushes, bush)
            end
        end
    end
    local bushCount = #GameRules.Bushes
    print("Spawned "..bushCount.." bushes total")

    -- Change random seed
    local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
    math.randomseed(tonumber(timeTxt))

    GameRules.APPLIER = CreateItem("item_apply_modifiers", nil, nil)

    -- Custom Stats for STR/AGI/INT
    Stats:Init()

    -- KV Tables
    GameRules.ClassInfo = LoadKeyValues("scripts/kv/class_info.kv")
    GameRules.BushInfo = LoadKeyValues("scripts/kv/bush_info.kv")
    GameRules.ItemInfo = LoadKeyValues("scripts/kv/item_info.kv")
    GameRules.SpawnInfo = LoadKeyValues("scripts/kv/spawn_info.kv")
    GameRules.Crafting = LoadKeyValues("scripts/kv/crafting.kv")
    GameRules.AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
    GameRules.ItemKV = LoadKeyValues("scripts/npc/npc_items_custom.txt")
    GameRules.UnitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")
    GameRules.HeroKV = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")

    -- Check Syntax
    if (not GameRules.AbilityKV) or (not GameRules.ItemKV) or (not GameRules.UnitKV) or (not GameRules.HeroKV) then
        print("--------------------------------------------------\n\n")
        print("SYNTAX ERROR IN KEYVALUE FILES")
        print("npc_abilities_custom: ", GameRules.AbilityKV)
        print("npc_items_custom:     ", GameRules.ItemKV)
        print("npc_units_custom:     ", GameRules.UnitKV)
        print("npc_heroes_custom:    ", GameRules.HeroKV)
        print("--------------------------------------------------\n\n")
    end

    -- items_game parsing
    GameRules.ItemsGame = LoadKeyValues("scripts/items/items_game.txt")
    modelmap = {}
    itemskeys = GameRules.ItemsGame['items']
    MapModels()

    -- Allow cosmetic swapping
    SendToServerConsole( "dota_combine_models 0" )

    -- Lua Modifiers
    LinkLuaModifier("modifier_chicken_form", "heroes/beastmaster/subclass_modifiers.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_pack_leader", "heroes/beastmaster/subclass_modifiers.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_shapeshifter", "heroes/beastmaster/subclass_modifiers.lua", LUA_MODIFIER_MOTION_NONE)
    
    -- Grace Period
    GameMode:SetFixedRespawnTime(GRACE_PERIOD_RESPAWN_TIME)
    Timers:CreateTimer({
        endTime = GAME_PERIOD_GRACE,
        callback = function()
            print("End of grace period.")
            GameRules:SetHeroRespawnEnabled( false )
            UnblockMammoth()
        end
    })

    print('[ITT] Done loading gamemode!')
end

 --disables rosh pit
function UnblockMammoth()
    print("Trying to delete ent_blockers")
    local ent = Entities:FindAllByName("ent_blocker")
    if table.getn(ent) > 0 then
        type(ent)
        for i,v in pairs(ent) do
            print("deleting ent"..i)
            v:SetEnabled(false,false)
            v:RemoveSelf()
        end
    else
        print("name entblocker doesn't exist")
    end
end

local classes = { 
    [1] = "hunter",
    [2] = "gatherer",
    [3] = "scout",
    [4] = "thief",
    [5] = "priest",
    [6] = "mage",
    [7] = "beastmaster",
}

--Handler for class selection at the beginning of the game
function ITT:OnClassSelected(event)
    local playerID = event.PlayerID
    local class_name = event.selected_class
    local player = PlayerResource:GetPlayer(playerID)
    local team = PlayerResource:GetTeam(playerID)

    -- Handle random selection
    if class_name == "random" then
        class_name = classes[RandomInt(1,7)]
    end

    local hero_name = GameRules.ClassInfo['Classes'][class_name]

    local player_name = PlayerResource:GetPlayerName(playerID)
    if player_name == "" then player_name = "Player "..playerID end

    print("SelectClass "..hero_name)

    CustomGameEventManager:Send_ServerToTeam(team, "team_update_class", { class_name = class_name, player_name = player_name})

    PrecacheUnitByNameAsync(hero_name, function()
        local hero = CreateHeroForPlayer(hero_name, player)
        print("[ITT] CreateHeroForPlayer: ",playerID,hero_name,team)

        -- Move to the first unassigned starting position for the assigned team-isle
        ITT:SetHeroIslandPosition(hero, team)

        -- Health Label
        local color = ITT:ColorForTeam( team )
        hero:SetCustomHealthLabel( hero.Tribe.." Tribe", color[1], color[2], color[3] )

    end, playerID)
end

function ITT:SetHeroIslandPosition(hero, teamID)

    hero.Tribe = TEAM_ISLANDS[teamID]
    if not hero.Tribe then
        print("ERROR: No Hero Tribe assigned to team ",teamID)
        DeepPrintTable(TEAM_ISLANDS)
        return
    end

    local possiblePositions = GameRules.StartingPositions[hero.Tribe]

    for k,v in pairs(possiblePositions) do
        if v.playerID == -1 then
            FindClearSpaceForUnit(hero, v.position, true)
            hero:SetRespawnPosition(v.position)
            v.playerID = hero:GetPlayerID()
            print("[ITT] Position for Hero in "..hero.Tribe.." Tribe: ".. VectorString(v.position))
            break
        end
    end
end

-- This code is written by Internet Veteran, handle with care.
--Do the same now for the subclasses
function ITT:OnNPCSpawned( keys )
    local spawnedUnit = EntIndexToHScript( keys.entindex )
    --print("spawned unit: ", spawnedUnit:GetUnitName(), spawnedUnit:GetClassname(), spawnedUnit:GetName(), spawnedUnit:GetEntityIndex())
    
    -- add it to the gridnav to stop people building on it
    --BuildingHelper:AddUnit(spawnedUnit)

    if spawnedUnit:IsRealHero() then
        if not spawnedUnit.bFirstSpawned then
            spawnedUnit.bFirstSpawned = true
            ITT:OnHeroInGame(spawnedUnit)
        else
            ITT:OnHeroRespawn(spawnedUnit)
        end
    end
end

function ITT:OnHeroInGame( hero )

    -- Remove starting gold
    hero:SetGold(0, false)

    -- Create locked slots
    ITT:CreateLockedSlots(hero)

    -- Add Innate Skills
    ITT:AdjustSkills(hero)

    -- Initial Heat
    Heat:Start(hero)

    -- Init Meat, Health and Energy Loss
    ApplyModifier(hero, "modifier_meat_passive")
    ApplyModifier(hero, "modifier_hunger")

    -- Set Wearables
    ITT:SetDefaultCosmetics(hero)

    -- Adjust Stats
    Stats:ModifyBonuses(hero)

    -- Crafting Think
    --[[Timers:CreateTimer(function()
        InventoryCheck(hero)
        return 1
    end)]]

    -- This handles spawning heroes through dota_bot_populate
    --[[if PlayerResource:IsFakeClient(hero:GetPlayerID()) then
        Timers:CreateTimer(1, function()
            ITT:SetHeroIslandPosition(hero, hero:GetTeamNumber())
        end)
    end]]
end

function ITT:OnHeroRespawn( hero )

    -- Restart Heat
    Heat:Start(hero)

    -- Restart Meat tracking
    ApplyModifier(hero, "modifier_meat_passive")

    -- Kill grave
    if hero.grave then
        UTIL_Remove(hero.grave)
        hero.grave = nil
    end
end

-- This handles locking a number of inventory slots for some classes
-- This means that players do not need to manually reshuffle them to craft
function ITT:CreateLockedSlots(hero)
    
    local lockedSlotsTable = GameRules.ClassInfo['LockedSlots']
    local className = GetHeroClass(hero)
    local lockedSlotNumber = lockedSlotsTable[className]
    
    local lockN = 5
    for n=0,lockedSlotNumber-1 do
        hero:AddItem(CreateItem("item_slot_locked", hero, spawnedUnit))
        hero:SwapItems(0, lockN)
        lockN = lockN -1
    end
end

-- Sets the hero skills for the level as defined in the 'SkillProgression' class_info.kv
-- Called on spawn and every time a hero gains a level or chooses a subclass
function ITT:AdjustSkills( hero )
    local skillProgressionTable = GameRules.ClassInfo['SkillProgression']
    local class = GetHeroClass(hero)
    local level = hero:GetLevel() --Level determines what skills to add or levelup
    hero:SetAbilityPoints(0) --All abilities are learned innately

    -- If the hero has a subclass, use that table instead
    if HasSubClass(hero) then
        class = GetSubClass(hero)
    end

    local class_skills = skillProgressionTable[class]
    if not class_skills then
        print("ERROR: No 'SkillProgression' table found for"..class.."!")
        return
    end

    -- Check for any skill in the 'unlearn' subtable
    local unlearn_skills = skillProgressionTable[class]['unlearn']
    if unlearn_skills then
        local unlearn_skills_level = unlearn_skills[tostring(level)]
        if unlearn_skills_level then
            local unlearn_ability_names = split(unlearn_skills_level, ",")

            for _,abilityName in pairs(unlearn_ability_names) do
                local ability = hero:FindAbilityByName(abilityName)
                if ability then
                    hero:RemoveAbility(abilityName)
                end
            end
        end
    end
    
    -- Learn/Upgrade all abilities for this level    
    local level_skills = skillProgressionTable[class][tostring(level)]
    if level_skills and level_skills ~= "" then
        print("[ITT] AdjustSkills for "..class.." at level "..level)
        local ability_names = split(level_skills, ",")

        -- If the ability already exists, upgrade it, otherwise add it at level 1
        for _,abilityName in pairs(ability_names) do
            local ability = hero:FindAbilityByName(abilityName)
            if ability then
                ability:SetHidden(false)
                ability:UpgradeAbility(false)
            else
                TeachAbility(hero, abilityName)
            end
        end
        print("------------------------------")
    else
        print("No skills to change for "..class.." at level "..level)
    end

    AdjustAbilityLayout(hero)
    PrintAbilities(hero)
end


function ITT:OnEntityKilled(keys)
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
        {"npc_creep_hawk", {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_bone", 100}, {"item_egg_hawk", 10}},
        {"npc_creep_mammoth", {"item_bone", 100},{"item_bone", 100},{"item_bone", 100},{"item_bone", 100},{"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_horn_mammoth", 100}, {"item_horn_mammoth", 50}}
    }
    local spawnTable = {
                        {"npc_creep_elk_wild","npc_creep_fawn"},
                        {"npc_creep_wolf_jungle","npc_creep_wolf_pup"},
                        {"npc_creep_bear_jungle","npc_creep_bear_cub"},
                        {"npc_creep_bear_jungle_adult","npc_creep_bear_cub"}}

    local killedUnit = EntIndexToHScript(keys.entindex_killed)
    local killer = EntIndexToHScript(keys.entindex_attacker or 0)
    -- local keys.entindex_inflictor --long
    -- local keys.damagebits --long
    local unitName = killedUnit:GetUnitName()
    print(unitName .. " has been killed")

    -- Corpses
    if string.find(unitName, "creep") then
        corpse = CreateUnitByName("npc_creep_corpse", killedUnit:GetAbsOrigin(), false, nil, nil, 0)
        corpse.killer = killer

        -- Set the corpse invisible until the dota corpse disappears
        corpse:AddNoDraw()
            
        -- Keep a reference to its name and expire time
        corpse.corpse_expiration = GameRules:GetGameTime() + 90
        corpse.unit_name = killedUnit:GetUnitName()

        -- Set custom corpse visible
        Timers:CreateTimer(3, function() if IsValidEntity(corpse) then corpse:RemoveNoDraw() end end)

        -- Remove itself after the corpse duration
        Timers:CreateTimer(90, function()
            if corpse and IsValidEntity(corpse) then
                corpse:RemoveSelf()
            end
        end)
    end

    if string.find(unitName, "building") then
        killedUnit:RemoveBuilding(2, false)
    end

    -- Heroes
    if killedUnit.IsHero and killedUnit:IsHero() then
        --if it's a hero, drop all carried raw meat, plus 3, and a bone
        meatStacks = killedUnit:GetModifierStackCount("modifier_meat_passive", nil)
        for i= 1, meatStacks+3, 1 do
            local newItem = CreateItem("item_meat_raw", nil, nil)
            CreateItemOnPositionSync(killedUnit:GetOrigin() + RandomVector(RandomInt(20,100)), newItem)
        end
        local newItem = CreateItem("item_bone", nil, nil)
        CreateItemOnPositionSync(killedUnit:GetOrigin() + RandomVector(RandomInt(20,100)), newItem)

        -- Launch all carried items excluding the fillers
        for i=0,5 do
            local item = killedUnit:GetItemInSlot(i)
            if item and item:GetAbilityName() ~= "item_slot_locked" then
                killedUnit:DropItemAtPositionImmediate(item, killedUnit:GetAbsOrigin())
                local pos = killedUnit:GetAbsOrigin()
                local pos_launch = pos+RandomVector(RandomFloat(100,150))
                item:LaunchLoot(false, 200, 0.75, pos_launch)
            end
        end

        -- Create a grave if respawn is disabled
        local time = math.floor(GameRules:GetGameTime())
        if time > GAME_PERIOD_GRACE then
            killedUnit.grave = CreateUnitByName("gravestone", killedUnit:GetAbsOrigin(), false, killedUnit, killedUnit, killedUnit:GetTeamNumber())
            killedUnit.grave.hero = killedUnit
        end
    else
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

        -- Tracking number of neutrals
        if Spawns.neutralCount[unitName] then
            Spawns.neutralCount[unitName] = Spawns.neutralCount[unitName] - 1
        end
    end
end

function ITT:On_entity_hurt(data)
    --print("entity_hurt")
    local attacker = EntIndexToHScript(data.entindex_attacker)
    local killed = EntIndexToHScript(data.entindex_killed)
    if (string.find(killed:GetUnitName(), "elk") or string.find(killed:GetUnitName(), "fish") or string.find(killed:GetUnitName(), "hawk")) then
        killed.state = "flee"
    end
    --print("attacker: "..attacker:GetUnitName(), "killed: "..killed:GetUnitName())

end

function ITT:FixDropModels(dt)
    for _,v in pairs(Entities:FindAllByClassname("dota_item_drop")) do
        if not v.ModelFixInit then
            --print("initing.. " .. v:GetContainedItem():GetAbilityName())
            v.ModelFixInit = true
            v.OriginalOrigin = v:GetOrigin()
            v.OriginalAngles = v:GetAngles()
            local custom = GameRules.ItemKV[v:GetContainedItem():GetAbilityName()].Custom
            if custom then
                --print("found custom")
                if custom.ModelOffsets then
                    local offsets = GameRules.ItemKV[v:GetContainedItem():GetAbilityName()].Custom.ModelOffsets
                    v:SetOrigin( v.OriginalOrigin - Vector(offsets.Origin.x, offsets.Origin.y, offsets.Origin.z))
                    v:SetAngles( v.OriginalAngles.x - offsets.Angles.x, v.OriginalAngles.y - offsets.Angles.y, v.OriginalAngles.z - offsets.Angles.z)
                end
                if custom.ModelScale then v:SetModelScale(custom.ModelScale) end
            end
        end
    end
    return DROPMODEL_TICK_TIME
end

function ITT:OnBuildingThink()

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
    for i, building in pairs(buildings) do
        if building:GetUnitName() == "npc_building_armory" then
            CraftItems(building, ARMORY_RECIPE_TABLE, ITEM_ALIAS_TABLE)
        elseif building:GetUnitName() == "npc_building_workshop" then
            CraftItems(building, WORKSHOP_RECIPE_TABLE, ITEM_ALIAS_TABLE)
        elseif building:GetUnitName() == "npc_building_hut_witch_doctor" then
            CraftItems(building, WDHUT_RECIPE_TABLE, ITEM_ALIAS_TABLE)
        end
    end
    return GAME_TROLL_TICK_TIME
end

function ITT:OnBushThink()
    --print("--Creating Items on Bushes--")
    
    local bushes = GameRules.Bushes
    
    for k,bush in pairs(bushes) do
        if bush.RngWeight == nil then --rng weight maks it so there's a chance a bush won't spawn but you won't get rng fucked
            bush.RngWeight = 0 --if rng weight doesnt exist declare it to a value that's unlikely to spawn for the first few ticks
        end

        local rand = RandomInt(-4,4) --randomize between -4 and +4, since the min is 0 with the best rng on the minimum number you will still not get a spawn
        
        if rand + bush.RngWeight >= 5 then 
            bush.RngWeight = bush.RngWeight - 1 --if spawn succeeds reduce the odds of the next spawn

            local bush_name = bush:GetUnitName()
            local bushTable = GameRules.BushInfo[bush_name]
            local possibleChoices = TableCount(bushTable)
            local randomN = tostring(RandomInt(1, possibleChoices))
            local bush_random_item = bushTable[randomN]

            GiveItemStack(bush, bush_random_item)

        else
            bush.RngWeight = bush.RngWeight + 1 --if spawn fails increase odds for next run
        end
    end

    return GAME_BUSH_TICK_TIME
end

function ITT:OnBoatThink()
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

-- This function checks if you won the game or not
function ITT:CheckWinCondition()
    local winnerTeamID = nil

    -- Don't end single team lobbies
    if ITT:GetTeamCount() == 1 then
        return
    end

    -- Check if all the heroes still in game belong to the same team
    local AllHeroes = HeroList:GetAllHeroes()
    for k,hero in pairs(AllHeroes) do
        if hero:IsAlive() then
            local teamNumber = hero:GetTeamNumber()
            if not winnerTeamID then
                winnerTeamID = teamNumber
            elseif winnerTeamID ~= teamNumber then
                return
            end
        end
    end    

    if winnerTeamID and not GameRules.Winner then
        ITT:PrintWinMessageForTeam(winnerTeamID)
        GameRules:SetGameWinner(winnerTeamID)
    end
end

function ITT:PrintWinMessageForTeam( teamID )
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            local player = PlayerResource:GetPlayer(playerID)
            if player and player:GetTeamNumber() == teamID then
                local playerName = PlayerResource:GetPlayerName(playerID)
                if playerName == "" then playerName = "Player "..playerID end
                GameRules:SendCustomMessage(playerName.." was victorious!", 0, 0)
            end
        end
    end
end

-- When players connect, add them to the players list and begin operations on them
function ITT:OnPlayerConnectFull(keys)
    print ('[ITT] OnConnectFull')

    local entIndex = keys.index+1
    -- The Player entity of the joining user
    local ply = EntIndexToHScript(entIndex)

    -- The Player ID of the joining player
    local playerID = ply:GetPlayerID()

    playerList[playerID] = playerID
    maxPlayerID = maxPlayerID + 1

    -- Update the user ID table with this user
    self.vUserIds[keys.userid] = ply
    self.vPlayerUserIds[playerID] = keys.userid


    -- If the player reconnected and has a hero, check if the subclass button should be unlocked
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    if hero then
        local level = hero:GetLevel()
        if level >= 6 and not HasSubClass(hero) then
            CustomGameEventManager:Send_ServerToPlayer(ply, "player_unlock_subclass", {})

            if level == 6 then
                local particleName = "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_spirit_form_ambient.vpcf"
                hero.subclassAvailableParticle = ParticleManager:CreateParticleForTeam(particleName, PATTACH_ABSORIGIN_FOLLOW, hero, hero:GetTeamNumber())

                EmitSoundOnClient("SubSelectReady", PlayerResource:GetPlayer(playerID))
            end
        end
    end
end

-- Listener to handle item pickup (the rest of the pickup logic is tied to the order filter and item function mechanics)
function ITT:OnItemPickedUp(event)    
    if not event.HeroEntityIndex then
        print("A building just picked an item")
        return
    end

    local hero = EntIndexToHScript( event.HeroEntityIndex )
    local originalItem = EntIndexToHScript(event.ItemEntityIndex)
    local itemName = event.itemname

    -- Check for combines
    InventoryCheck(hero)

    local itemSlotRestriction = GameRules.ItemInfo['ItemSlots'][itemName]
    if itemSlotRestriction then
        local maxCarried = GameRules.ItemInfo['MaxCarried'][itemSlotRestriction]
        local count = GetNumItemsOfSlot(hero, itemSlotRestriction)

        -- Drop the item if the hero exceeds the possible max carried amount
        if count > maxCarried then
            local origin = hero:GetAbsOrigin()
            hero:DropItemAtPositionImmediate(originalItem, origin)
            local pos_launch = origin+RandomVector(100)
            originalItem:LaunchLoot(false, 200, 0.75, pos_launch)

            SendErrorMessage(hero:GetPlayerOwnerID(), "#error_cant_carry_more_"..itemSlotRestriction) --Concatenated error message
        end
    end

    local hasTelegather = hero:HasModifier("modifier_telegather")
    local hasTelethief = hero:HasModifier("modifier_thief_telethief")

    -- Related to RadarTelegathererInit
    if hasTelegather then

        local targetFire = hero.targetFire
        local newItem = CreateItem(originalItem:GetName(), nil, nil)

        local itemList = {"item_tinder", "item_flint", "item_stone", "item_stick", "item_bone", "item_meat_raw", "item_crystal_mana", "item_clay_ball", "item_river_root", "item_river_stem", "item_thistles", "item_acorn", "item_acorn_magic", "item_mushroom"}
        for key,value in pairs(itemList) do
            if value == originalItem:GetName() then
                print( "Teleporting Item", originalItem:GetName())
                hero:RemoveItem(originalItem)
                local itemPosition = targetFire:GetAbsOrigin() + RandomVector(RandomInt(100,150))
                CreateItemOnPositionSync(itemPosition,newItem)
                newItem:SetOrigin(itemPosition)
            end
        end
    end

    -- Related to TeleThiefInit
    if hasTelethief then
        
        local newItem = CreateItem(originalItem:GetName(), nil, nil)
        local fireLocation = hero.fire_location

        local radius = hero.radius
        local teamNumber = hero:GetTeamNumber()
        local buildings = FindUnitsInRadius(teamNumber, caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
        
        if buildings ~= null then
            print("Teleporting Item", originalItem:GetName())
            hero:RemoveItem(originalItem)
            local itemPosition = targetFire:GetAbsOrigin() + RandomVector(RandomInt(100,150))
            CreateItemOnPositionSync(itemPosition,newItem)
            newItem:SetOrigin(itemPosition)
        else
            print("Did not find enemy buildings")
        end
    end
end

--Listener to handle level up
function ITT:OnPlayerGainedLevel(event)
    local player = EntIndexToHScript(event.player)
    local playerID = player:GetPlayerID()
    local hero = player:GetAssignedHero()
    local class = GetHeroClass(hero)
    local level = event.level

    print("[ITT] OnPlayerLevelUp - Player "..playerID.." ("..class..") has reached level "..level)
	
    -- If the hero reached level 6 and hasn't unlocked a subclass, make the button clickable
    if level >= 6 and not HasSubClass(hero) then
        CustomGameEventManager:Send_ServerToPlayer(player, "player_unlock_subclass", {})

        if level == 6 then
            local particleName = "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_spirit_form_ambient.vpcf"
            hero.subclassAvailableParticle = ParticleManager:CreateParticleForTeam(particleName, PATTACH_ABSORIGIN_FOLLOW, hero, hero:GetTeamNumber())

            EmitSoundOnClient("SubSelectReady", PlayerResource:GetPlayer(playerID))
        end
    end
	
    -- Update skills
    ITT:AdjustSkills( hero )
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

Convars:RegisterCommand("print_fix_diffs", function(cmdname) print_fix_diffs(cmdname) end, "Give any item", 0)
Convars:RegisterCommand("print_dropped_vecs", function(cmdname) print_dropped_vecs(cmdname) end, "Give any item", 0)

---------------------------------------------------------------------------
-- Game state change handler
---------------------------------------------------------------------------
function ITT:OnGameRulesStateChange()
    local nNewState = GameRules:State_Get()
--  print( "OnGameRulesStateChange: " .. nNewState )

    if nNewState == DOTA_GAMERULES_STATE_HERO_SELECTION then

        Spawns:Init()

    elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then

        Timers:CreateTimer(function()
            ITT:CheckWinCondition()
            return WIN_GAME_THINK
        end)
    end
end

---------------------------------------------------------------------------

-- Called whenever a player changes its current selection, it keeps a list of entity indexes
function ITT:OnPlayerSelectedEntities( event )
    local pID = event.pID

    GameRules.SELECTED_UNITS[pID] = event.selected_entities

    -- This is for Building Helper to know which is the currently active builder
    local mainSelected = GetMainSelectedEntity(pID)
    if IsValidEntity(mainSelected) and IsBuilder(mainSelected) then
        local player = PlayerResource:GetPlayer(pID)
        player.activeBuilder = mainSelected
    end
end


---------------------------------------------------------------------------
-- Get the color associated with a given teamID
---------------------------------------------------------------------------
function ITT:ColorForTeam( teamID )
    local color = TEAM_COLORS[teamID]
    if color == nil then
        color = { 255, 255, 255 } -- default to white
    end
    return color
end

---------------------------------------------------------------------------
-- Get the number of teams with valid players in them
---------------------------------------------------------------------------
function ITT:GetTeamCount()
    local teamCount = 0
    for i=DOTA_TEAM_FIRST,DOTA_TEAM_CUSTOM_MAX do
        local playerCount = PlayerResource:GetPlayerCountForTeam(i)
        if playerCount > 0 then
            teamCount = teamCount + 1
        end
    end
    return teamCount
end