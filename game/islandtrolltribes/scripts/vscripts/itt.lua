print ('[ITT] itt.lua' )

TEAM_COLORS = {}
TEAM_COLORS[DOTA_TEAM_GOODGUYS] = { 52, 85, 255 }  -- Blue
TEAM_COLORS[DOTA_TEAM_BADGUYS]  = { 255, 52, 85 }  -- Red
TEAM_COLORS[DOTA_TEAM_CUSTOM_1] = { 101, 212, 19 } -- Green
TEAM_COLORS[DOTA_TEAM_CUSTOM_2] = { 243, 201, 9 }  -- Yellow

playerList = {}
maxPlayerID = 0

GAME_TICK_TIME              = 0.1   -- The game should update every tenth second
GAME_TROLL_TICK_TIME        = 0.5   -- Its really like its wc3!
FLASH_ACK_THINK             = 2
WIN_GAME_THINK              = 0.5 -- checks if you've won every x seconds

BUILDING_TICK_TIME          = 0.03
DROPMODEL_TICK_TIME         = 0.03

-- Grace period respawn time in seconds
GRACE_PERIOD_RESPAWN_TIME    = 3

DEBUG_SPEW = 1

XP_PER_LEVEL_TABLE = {
    0, -- 1
    200, -- 2 +200
    500, -- 3 +300
    900, -- 4 +400
    1400, -- 5 +500
    2000, -- 6 +600
    2700, -- 7 +700
    3500, -- 8 +800
    4400, -- 9 +900
    5400, -- 10 +1000
    6400, -- 11 +1000
    7400, -- 12 +1000
    8400, -- 13 +1000
    9400, -- 14 +1000
    10400, -- 15 +1000  
    11400, -- 16 +1000
    12400, -- 16 +1000
    13400, -- 17 +1000
    14400, -- 18 +1000
    15400, -- 19 +1000
    16400, -- 20 +1000
    17400, -- 21 +1000
    18400, -- 22 +1000
    19400, -- 23 +1000
    100400, -- 24 +1000
    120400 -- 25 +1000
 }

-- If this is enabled the game is in testing mode, and as a result nobody can win
GAME_TESTING_CHECK          = true 

-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function ITT:InitGameMode()
    GameMode = GameRules:GetGameModeEntity()
    
    GameMode:SetCustomXPRequiredToReachNextLevel(XP_PER_LEVEL_TABLE)
    GameRules:SetUseCustomHeroXPValues(true)
    GameMode:SetUseCustomHeroLevels(true)
    GameMode:SetCustomHeroMaxLevel(25)

    -- DebugPrint
    --Convars:RegisterConvar('debug_spew', tostring(DEBUG_SPEW), 'Set to 1 to start spewing debug info. Set to 0 to disable.', 0)

    -- Game logic timers
    Timers(function() ITT:OnBuildingThink() return GAME_TROLL_TICK_TIME end)
    Timers(function() ITT:OnItemThink() return GAME_ITEM_TICK_TIME end) --item_spawning.lua
    Timers(function() ITT:FixDropModels() return DROPMODEL_TICK_TIME end)

    -- Disable buybacks to stop instant respawning.
    GameMode:SetBuybackEnabled( false )
    GameMode:SetStashPurchasingDisabled(false)

    -- Grace Period
    GameMode:SetFixedRespawnTime(GRACE_PERIOD_RESPAWN_TIME)
    GameRules:SetPreGameTime(GAME_PERIOD_GRACE)

    GameRules:SetSameHeroSelectionEnabled( true )
    GameRules:SetTimeOfDay( 0.75 )
    GameRules:SetHeroRespawnEnabled( true )
    GameRules:SetHeroSelectionTime(0)
    GameRules:SetPostGameTime( 60.0 )
    GameRules:SetTreeRegrowTime( 60.0 )
    GameRules:SetCreepMinimapIconScale( 0.7 )
    GameRules:SetRuneMinimapIconScale( 0.7 )
    GameRules:SetGoldTickTime( 60.0 )
    GameRules:SetGoldPerTick( 0 )
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
    CustomGameEventManager:RegisterListener( "player_selected_class", Dynamic_Wrap( ITT, "OnClassSelected" ) )
    CustomGameEventManager:RegisterListener( "player_selected_subclass", Dynamic_Wrap( ITT, "OnSubclassChange" ) )

    CustomGameEventManager:RegisterListener( "player_sleep_outside", Dynamic_Wrap( ITT, "Sleep" ) )
    CustomGameEventManager:RegisterListener( "player_eat_meat", Dynamic_Wrap( ITT, "EatMeat" ) )
    CustomGameEventManager:RegisterListener( "player_drop_meat", Dynamic_Wrap( ITT, "DropMeat" ) )
    CustomGameEventManager:RegisterListener( "player_drop_all_meat", Dynamic_Wrap( ITT, "DropAllMeat" ) )
    CustomGameEventManager:RegisterListener( "player_panic", Dynamic_Wrap( ITT, "Panic" ) )
    CustomGameEventManager:RegisterListener( "player_rest_building", Dynamic_Wrap( ITT, "RestBuilding" ) )
    
    -- Filters
    GameMode:SetExecuteOrderFilter( Dynamic_Wrap( ITT, "FilterExecuteOrder" ), self )
    GameMode:SetDamageFilter( Dynamic_Wrap( ITT, "FilterDamage" ), self )
    GameMode:SetModifyExperienceFilter( Dynamic_Wrap( ITT, "FilterExperience" ), self )
    GameMode:SetModifyGoldFilter( Dynamic_Wrap( ITT, "FilterGold" ), self )

    -- Don't end the game if everyone is unassigned
    SendToServerConsole("dota_surrender_on_disconnect 0")

    -- Increase time to load and start even if not all players loaded
    SendToServerConsole("dota_wait_for_players_to_load_timeout 240")

    self.m_GatheredShuffledTeams = {}
    self.m_NumAssignedPlayers = 0

    -- Team Colors
    for team,color in pairs(TEAM_COLORS) do
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

    ITT_MAX_PLAYERS = 9
    ITT_MAX_TEAM_PLAYERS = 3
    VALID_TEAMS = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS, DOTA_TEAM_CUSTOM_1}
    TEAM_ISLANDS = {}

    if GetMapName() == "itt_quad" then
        ITT_MAX_PLAYERS = 16
        ITT_MAX_TEAM_PLAYERS = 4
        table.insert(VALID_TEAMS, DOTA_TEAM_CUSTOM_2)
    end

    for k,v in pairs(VALID_TEAMS) do
        GameRules:SetCustomGameTeamMaxPlayers( v, ITT_MAX_TEAM_PLAYERS )
        TEAM_ISLANDS[v] = islandList[k]
    end

    self.vUserIds = {}
    self.vPlayerUserIds = {}

    -- Change random seed
    local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
    math.randomseed(tonumber(timeTxt))

    GameRules.APPLIER = CreateItem("item_apply_modifiers", nil, nil)

    -- Custom Stats for STR/AGI/INT
    Stats:Init()

    -- KV Tables
    GameRules.ClassInfo = LoadKeyValues("scripts/kv/class_info.kv")
    GameRules.SpellBookInfo = LoadKeyValues("scripts/kv/spellbook_info.kv")
    GameRules.BushInfo = LoadKeyValues("scripts/kv/bush_info.kv")
    GameRules.ItemInfo = LoadKeyValues("scripts/kv/item_info.kv")
    GameRules.SpawnInfo = LoadKeyValues("scripts/kv/spawn_info.kv")
    GameRules.Crafting = LoadKeyValues("scripts/kv/crafting.kv")
    GameRules.AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
    GameRules.ItemKV = LoadKeyValues("scripts/npc/npc_items_custom.txt")
    GameRules.UnitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")
    GameRules.HeroKV = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
    GameRules.EnglishTooltips = LoadKeyValues("resource/addon_english.txt")
    MergeTables(GameRules.UnitKV, LoadKeyValues("scripts/npc/npc_heroes_custom.txt")) --Load HeroKV into UnitKV

    --The location behavior for creep spawning
    --Available values : predefined, random, mix
    -- predefined: Uses the predefined nodes on the map
    -- random: Select the location randomly
    -- mix: Use the both of the above.
    GameRules.SpawnLocationType = "predefined"
    GameRules.SpawnRegion = "Island"
    GameRules.BushSpawnLocationType = "predefined"
    GameRules.BushSpawnRegion = "Island"

    LoadCraftingTable()

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
    LinkLuaModifier("modifier_minimap", "libraries/modifiers/modifier_minimap", LUA_MODIFIER_MOTION_NONE)

    -- Initialize the roaming trading ships
    ITT:SetupShops()

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
        if v.playerID == hero:GetPlayerID() or  v.playerID == -1 then
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

    if spawnedUnit:IsRealHero() then
        if not spawnedUnit.bFirstSpawned then
            spawnedUnit.bFirstSpawned = true
            ITT:OnHeroInGame(spawnedUnit)
        else
            ITT:OnHeroRespawn(spawnedUnit)
        end
    end

    local fillSlots = GameRules.UnitKV[spawnedUnit:GetUnitName()]["FillSlots"]
    if fillSlots then
        ITT:CreateLockedSlotsForUnits(spawnedUnit, fillSlots)
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
    ApplyModifier(hero, "modifier_hunger_health")
    ApplyModifier(hero, "modifier_hunger_mana")

    -- Set Wearables
    ITT:SetDefaultCosmetics(hero)

    -- Adjust Stats
    Stats:ModifyBonuses(hero)

    -- This handles spawning heroes through dota_bot_populate
    --[[if PlayerResource:IsFakeClient(hero:GetPlayerID()) then
        Timers:CreateTimer(1, function()
            ITT:SetHeroIslandPosition(hero, hero:GetTeamNumber())
        end)
    end]]
end

function ITT:OnHeroRespawn( hero )

    -- Setting the position of the respawned hero
    ITT:SetHeroIslandPosition(hero, hero:GetTeamNumber())

    -- Restart Heat
    Heat:Start(hero)

    -- Restart Meat tracking
    ApplyModifier(hero, "modifier_meat_passive")

    AdjustAbilityLayout(hero)

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
    local className = hero:GetHeroClass()
    local lockedSlotNumber = lockedSlotsTable[className]
    
    local lockN = 5
    for n=0,lockedSlotNumber-1 do
        hero:AddItem(CreateItem("item_slot_locked", hero, spawnedUnit))
        hero:SwapItems(0, lockN)
        lockN = lockN -1
    end
end

function ITT:CreateLockedSlotsForUnits(unit, lockedSlotCount)
    local lockN = 5
    for n=0,lockedSlotCount-1 do
        unit:AddItem(CreateItem("item_slot_locked", nil, nil))
        unit:SwapItems(0, lockN)
        lockN = lockN -1
    end
end

-- Sets the hero skills for the level as defined in the 'SkillProgression' class_info.kv
-- Called on spawn and every time a hero gains a level or chooses a subclass
function ITT:AdjustSkills( hero )
    local skillProgressionTable = GameRules.ClassInfo['SkillProgression']
    local class = hero:GetHeroClass()
    local level = hero:GetLevel() --Level determines what skills to add or levelup
    hero:SetAbilityPoints(0) --All abilities are learned innately

    -- If the hero has a subclass, use that table instead
    if hero:HasSubClass() then
        class = hero:GetSubClass()
    end

    local class_skills = skillProgressionTable[class]
    if not class_skills then
        print("ERROR: No 'SkillProgression' table found for"..class.."!")
        return
    end

    -- For every level past 6, we need to check for old levels of abilities could have been missed
    if hero.subclass_leveled and hero.subclass_leveled > 6 then

        for level = 6, hero.subclass_leveled do
            ITT:UnlearnAbilities(hero, class_skills, level)
            ITT:LearnAbilities(hero, class_skills, level)
        end

        hero.subclass_leveled = nil --Already subclassed, next time it will just adjust skills normally
    else
        ITT:UnlearnAbilities(hero, class_skills, level)
        ITT:LearnAbilities(hero, class_skills, level)
    end

    AdjustAbilityLayout(hero)
    EnableSpellBookAbilities(hero)
    PrintAbilities(hero)
    PlayerResource:RefreshSelection()
end

-- Check for any skill in the 'unlearn' subtable
function ITT:UnlearnAbilities(hero, class_skills, level)
    Timers:CreateTimer(function()
        local unlearn_skills = class_skills['unlearn']
        if unlearn_skills then
            local unlearn_skills_level = unlearn_skills[tostring(level)]
            if unlearn_skills_level then
                local unlearn_ability_names = split(unlearn_skills_level, ",")
                for _,abilityName in pairs(unlearn_ability_names) do
                    local ability = hero:FindAbilityByName(abilityName)
                    
                    if ability then
                        local kv = ability:GetAbilityKeyValues()
                        --print("unlearning " .. abilityName)
                        if kv["Modifiers"] then
                            for i,v in pairs(kv["Modifiers"]) do
                                --print("removing modifier ".. i)
                                hero:RemoveModifierByName(i)
                            end
                        end
                        hero:RemoveAbility(abilityName)
                    end
                end
            end
        end
    end)
end

-- Learn/Upgrade all abilities for this level    
function ITT:LearnAbilities(hero, class_skills, level)
    local level_skills = class_skills[tostring(level)]
    local class = hero:GetHeroClass().." ("..hero:GetSubClass()..")"
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
end

function EnableSpellBookAbilities(hero)
    local toggleAbilityName
    local heroClass = hero:GetHeroClass()
    if heroClass == "mage" then
        toggleAbilityName = "ability_mage_spellbook_toggle"
    elseif heroClass == "priest" then
        toggleAbilityName = "ability_priest_toggle_spellbar"
    elseif heroClass == "gatherer" and hero:GetSubClass() == "herbal_master_telegatherer" then
        toggleAbilityName = "ability_gatherer_findherb"
    end

    if toggleAbilityName then
        local spellBookAbility = hero:FindAbilityByName(toggleAbilityName)
        ToggleOn(spellBookAbility)
        ToggleOff(spellBookAbility)
    end
end

--[[
Utility functions for creating meat with decay time. Arguably would be best to place in another file
]]
-- Get meat decay time, for now use constant, but later could be affected by buffs/class type
function GetMeatDecayTime(unitKilled, unitKiller)
    return 45
end

-- Function to contain logic that modifies food drop rate
function GetMeatStacksToDrop(baseDrop, unitKilled, unitKiller)
    return baseDrop
end

-- Creates some raw meat at the specified position and creates timers to make the meat decay.
-- position: location where to spawn the meat (vector)
-- stacks: number of meats to make
-- decayTimeInSec: # of seconds before meat dissapears
-- meatCreateTimestamp: Gametime timestamp of when the meat is created. This is used for create copies of meat with correct decay timers (picking up a meat with full meat means we need to copy)
function CreateRawMeatAtLoc(position, stacks, decayTimeInSec, meatCreateTimestamp)
    for i= 1, stacks, 1 do
        local newItem = CreateItem("item_meat_raw", nil, nil)
        local physicalItem =  CreateItemOnPositionSync(position + RandomVector(RandomInt(20,100)), newItem)
        local decayTime = decayTimeInSec
        physicalItem.spawn_time = meatCreateTimestamp
        
        if (decayTime > 0) then
            Timers(decayTime, function()
                --TODO: add particle effect to dissapearing meat
                if (IsValidEntity(physicalItem)) then
                    UTIL_Remove(physicalItem:GetContainedItem())
                    UTIL_Remove(physicalItem)
                    --RemoveUnit(physicalItem)
                end
            end)
        end
    end
end


function ITT:OnEntityKilled(keys)
    local dropTable = {
        --{"unit_name", {"item_1", drop_chance}, {"mutually_exclusive_item_1", "mutually_exclusive_item_2", drop_chance}},
        {"npc_creep_elk_wild", {"item_hide_elk", 100}, {"item_bone", 100}},
        {"npc_creep_wolf_jungle", {"item_hide_wolf", 100}, {"item_bone", 100}},
        {"npc_creep_bear_jungle", {"item_hide_jungle_bear", 100}, {"item_bone", 100}},
        {"npc_creep_bear_jungle_adult", {"item_hide_jungle_bear", 100}, {"item_bone", 100}},
        {"npc_creep_panther", {"item_bone", 100}, {"item_bone", 100}},
        {"npc_creep_panther_elder", {"item_bone", 100}, {"item_bone", 100}},
        {"npc_creep_hawk", {"item_bone", 100}, {"item_egg_hawk", 10}},
        {"npc_creep_mammoth", {"item_bone", 100},{"item_bone", 100},{"item_bone", 100},{"item_bone", 100}, {"item_horn_mammoth", 100}, {"item_horn_mammoth", 50}},
        {"npc_building_fire_basic", {"item_building_kit_fire_basic", 100}, {"item_flint", 10}}
    }
    local meatTable = {
        {"npc_creep_elk_wild", 6},
        {"npc_creep_wolf_jungle", 4},
        {"npc_creep_bear_jungle", 7},
        {"npc_creep_bear_jungle_adult", 7},
        {"npc_creep_panther", 8},
        {"npc_creep_panther_elder", 8},
        {"npc_creep_lizard", 1},
        {"npc_creep_fish", 1},
        {"npc_creep_fish_green", 3},
        
        {"npc_creep_hawk", 2},
        {"npc_creep_mammoth", 15}
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

    -- Remove dead units from selection group
    for playerID,_ in pairs(Selection.entities) do
        if PlayerResource:IsUnitSelected(playerID, killedUnit) then
            PlayerResource:RemoveFromSelection(playerID, killedUnit)
        end
    end

    -- Creeps
    if string.find(unitName, "creep") and not killedUnit.no_corpse then
        local corpse = CreateUnitByName("npc_creep_corpse", killedUnit:GetAbsOrigin(), false, nil, nil, 0)
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

        -- Experience split in area
        killedUnit:SplitExperienceBounty(killer:GetTeamNumber())
    end

    -- Heroes
    if killedUnit.IsHero and killedUnit:IsHero() then
        local pos = killedUnit:GetAbsOrigin()

        --if it's a hero, drop all carried raw meat, plus 3, and a bone
        local meatStacksBase = killedUnit:GetModifierStackCount("modifier_meat_passive", nil) + 3
        local meatStacks = GetMeatStacksToDrop(meatStacksBase, killedUnit, killer)
        local decayTime = GetMeatDecayTime(killedUnit, killer)
        CreateRawMeatAtLoc(killedUnit:GetOrigin(), meatStacks, decayTime, GameRules:GetGameTime())
        
        local newItem = CreateItem("item_bone", nil, nil)
        CreateItemOnPositionSync(pos + RandomVector(RandomInt(20,100)), newItem)

        -- Launch all carried items excluding the fillers
        for i=0,5 do
            local item = killedUnit:GetItemInSlot(i)
            if item and item:GetAbilityName() ~= "item_slot_locked" then
                local clonedItem = CreateItem(item:GetName(), nil, nil)
                CreateItemOnPositionSync(pos,clonedItem)
                clonedItem:LaunchLoot(false, 200, 0.75, pos)
                item:RemoveSelf()
            end
        end

        -- Create a grave if respawn is disabled
        local time = math.floor(GameRules:GetGameTime())
        if time > GAME_PERIOD_GRACE then
            killedUnit.grave = CreateUnitByName("gravestone", killedUnit:GetAbsOrigin(), false, killedUnit, killedUnit, killedUnit:GetTeamNumber())
            killedUnit.grave.hero = killedUnit
        end

        CreateGoldBag(killedUnit)

    elseif not killedUnit.deleted then --use the deleted flag to make the killing not roll the item drops
        --drop system
        -- Items
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
        -- Meat
     
        for _,v in pairs(meatTable) do
            if unitName == v[1] then
                local meatStacksBase = v[2]
                local meatStacks = GetMeatStacksToDrop(meatStacksBase, killedUnit, killer)
                local decayTime = GetMeatDecayTime(killedUnit, killer)
                CreateRawMeatAtLoc(killedUnit:GetOrigin(), meatStacks, decayTime, GameRules:GetGameTime())
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
                    local unit = CreateUnitByName(v[2],killedUnit:GetOrigin(), true,nil,nil,DOTA_TEAM_NEUTRALS)
                    unit.originalVision = unit:GetDayTimeVisionRange()
                    unit:SetNightTimeVisionRange(0)
                    unit:SetDayTimeVisionRange(0)
                end
            end
        end

        -- Tracking number of neutrals
        if killedUnit.locationDetails then
            Spawns.neutralCount[killedUnit.locationDetails.regionType][killedUnit.locationDetails.regionId][unitName] = Spawns.neutralCount[killedUnit.locationDetails.regionType][killedUnit.locationDetails.regionId][unitName] - 1
        end
    end

    --Buildings
    if IsCustomBuilding(killedUnit) then
        CustomGameEventManager:Send_ServerToAllClients("building_killed",{building = killedUnit:GetEntityIndex()})
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
            local item = v:GetContainedItem()
            if item then
                local itemName = item:GetAbilityName()
                local custom = GameRules.ItemKV[itemName] and GameRules.ItemKV[itemName].Custom
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
    end
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
end

-- This function checks if you won the game or not
function ITT:WinConditionThink()
    Timers(function()
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
            GameRules.Winner = winnerTeamID
            ITT:PrintWinMessageForTeam(winnerTeamID)
            GameRules:SetGameWinner(winnerTeamID)
            return
        end

        return WIN_GAME_THINK
    end)
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
        if level >= 6 and not hero:HasSubClass() then
            CustomGameEventManager:Send_ServerToPlayer(ply, "player_unlock_subclass", {})

            if level == 6 then
                local particleName = "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_spirit_form_ambient.vpcf"
                hero.subclassAvailableParticle = ParticleManager:CreateParticleForTeam(particleName, PATTACH_ABSORIGIN_FOLLOW, hero, hero:GetTeamNumber())

                EmitSoundOnClient("SubSelectReady", PlayerResource:GetPlayer(playerID))
            end
        end
    end

    if GameRules:GetGameTime() > GAME_PERIOD_GRACE and not ply:GetAssignedHero() then
        CustomGameEventManager:Send_ServerToPlayer(ply, "player_force_pick", {})
    end
end

-- Listener to handle item pickup (the rest of the pickup logic is tied to the order filter and item function mechanics)
function ITT:OnItemPickedUp(event)

    local unit
    if event.UnitEntityIndex then
        unit = EntIndexToHScript( event.UnitEntityIndex )
    elseif event.HeroEntityIndex then
        unit = EntIndexToHScript( event.HeroEntityIndex )
    end

    local originalItem = EntIndexToHScript( event.ItemEntityIndex )
    local itemName = event.itemname

    -- A unit/building picked an item, don't continue with the rest of the hero logic
    if not event.HeroEntityIndex then
        return
    end

    local teamNumber = unit:GetTeamNumber()
    local hero = unit

    local itemSlotRestriction = GameRules.ItemInfo['ItemSlots'][itemName]
    if itemSlotRestriction then
        local maxCarried = GameRules.ItemInfo['MaxCarried'][itemSlotRestriction]
        local count = GetNumItemsOfSlot(hero, itemSlotRestriction)

        -- Drop gloves and axes on chicken
        if hero:GetSubClass() == "chicken_form" and (itemSlotRestriction == "AxesShields" or itemSlotRestriction == "Gloves") then
            hero:DropItemAtPositionImmediate(originalItem, hero:GetAbsOrigin())
            SendErrorMessage(hero:GetPlayerOwnerID(), "#error_chicken_cant_carry_"..itemSlotRestriction) --Concatenated error message
        end

        -- Drop the item if the hero exceeds the possible max carried amount
        if count > maxCarried then
            hero:DropItemAtPositionImmediate(originalItem, hero:GetAbsOrigin())
            SendErrorMessage(hero:GetPlayerOwnerID(), "#error_cant_carry_more_"..itemSlotRestriction) --Concatenated error message
        end
    end

    -- Set item ownership to whoever picked it up
    originalItem:SetPurchaser(hero)

    local hasTelegather = hero:HasModifier("modifier_telegather")
    local hasTelethief = hero:HasModifier("modifier_thief_telethief")

    -- Related to RadarTelegathererInit
    if hasTelegather then
        local didTeleport = TeleportItem(hero,originalItem)
    end

    -- Related to TeleThiefInit
    if hasTelethief then
        
        local newItem = CreateItem(originalItem:GetName(), nil, nil)
        local fireLocation = hero.fire_location

        local radius = hero.radius
        local buildings = FindUnitsInRadius(teamNumber, unit:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
        
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

function TeleportItem(hero,originalItem)
    local targetFire = hero.targetFire
    local newItem = CreateItem(originalItem:GetName(), nil, nil)
    local teleportSuccess = false

    local telegatherBuff = hero:FindModifierByName("modifier_telegather")
    local telegatherAbility = telegatherBuff:GetAbility()
    local percentChance = telegatherAbility:GetSpecialValueFor("percent_chance")
   --print("Teleporting item : " .. telegatherAbility:GetAbilityName() .. ", " .. percentChance .."% chance")

    local itemList = {"item_tinder", "item_flint", "item_stone", "item_stick", "item_bone", "item_meat_raw", "item_crystal_mana", "item_clay_ball", "item_river_root", "item_river_stem", "item_thistles", "item_acorn", "item_acorn_magic", "item_mushroom" }
    if hero:GetSubClass() == "herbal_master_telegatherer" then
        itemList = {"item_herb_blue", "item_herb_butsu", "item_herb_orange", "item_herb_purple", "item_herb_yellow", "item_river_root", "item_river_stem", "item_spirit_water", "item_spirit_wind"}
    end
    for key,value in pairs(itemList) do
        if value == originalItem:GetName() then
            local diceRoll = RandomFloat(0,100)
            --print("telegather roll " .. diceRoll)
            if diceRoll <= percentChance then
                --print( "Teleporting Item", originalItem:GetName())
                hero:RemoveItem(originalItem)
                local itemPosition = targetFire:GetAbsOrigin() + RandomVector(RandomInt(100,150))
                CreateItemOnPositionSync(itemPosition,newItem)
                newItem:SetOrigin(itemPosition)
                teleportSuccess = true
                return teleportSuccess
            end
        end
    end
    return teleportSuccess
end

--Listener to handle level up
function ITT:OnPlayerGainedLevel(event)
    local player = EntIndexToHScript(event.player)
    local playerID = player:GetPlayerID()
    local hero = player:GetAssignedHero()
    local class = hero:GetHeroClass()
    local level = event.level

    print("[ITT] OnPlayerLevelUp - Player "..playerID.." ("..class..") has reached level "..level)
    
    -- If the hero reached level 6 and hasn't unlocked a subclass, make the button clickable
    if level >= 6 and not hero:HasSubClass() then
        CustomGameEventManager:Send_ServerToPlayer(player, "player_unlock_subclass", {})

        if level == 6 then
            local particleName = "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_spirit_form_ambient.vpcf"
            hero.subclassAvailableParticle = ParticleManager:CreateParticleForTeam(particleName, PATTACH_ABSORIGIN_FOLLOW, hero, hero:GetTeamNumber())
            Notifications:Bottom(PlayerResource:GetPlayer(playerID), {text="Hero subclass selection now available!", duration=10, style={color="white"}, continue=true})

            EmitSoundOnClient("Hero_Chen.HandOfGodHealHero", PlayerResource:GetPlayer(playerID))
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

        -- Initial bush spawns, starts the timer to add items to the bushes periodially
        -- Place entities starting with spawner_ plus the appropriate name to spawn to corresponding bush on game start
        ITT:SpawnBushes()

        ITT:ShareUnits()

    elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then

        GameRules:SetHeroRespawnEnabled( false )
        RandomUnpickedPlayers()
        UnblockMammoth()
        ITT:WinConditionThink()
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

---------------------------------------------------------------------------
-- Sets the shared unit mask to allow teammate unit control
-- Only units with "SharedWithTeammates" KV will be controllable
---------------------------------------------------------------------------
function ITT:ShareUnits()
    local playersOnTeams = {}
    playersOnTeams[DOTA_TEAM_GOODGUYS] = ITT:GetPlayersOnTeam(DOTA_TEAM_GOODGUYS)
    playersOnTeams[DOTA_TEAM_BADGUYS]  = ITT:GetPlayersOnTeam(DOTA_TEAM_BADGUYS)
    playersOnTeams[DOTA_TEAM_CUSTOM_1] = ITT:GetPlayersOnTeam(DOTA_TEAM_CUSTOM_1)
    playersOnTeams[DOTA_TEAM_CUSTOM_2] = ITT:GetPlayersOnTeam(DOTA_TEAM_CUSTOM_2)

    -- Share for each player to teammates
    for i=0,DOTA_MAX_TEAM_PLAYERS do
        if PlayerResource:IsValidPlayerID(i) then
            local teamNumber = PlayerResource:GetTeam(i)
            for _,playerID in pairs(playersOnTeams[teamNumber]) do
                if playerID~=i then
                    PlayerResource:SetUnitShareMaskForPlayer(i, playerID, 2, true)
                end
            end
        end
    end
end

---------------------------------------------------------------------------
-- Gets a list of playerIDs on a team
---------------------------------------------------------------------------
function ITT:GetPlayersOnTeam( teamNumber )
    local players = {}
    for playerID=0,DOTA_MAX_TEAM_PLAYERS do
        if PlayerResource:GetTeam(playerID) == teamNumber then
            table.insert(players, playerID)
        end
    end
    return players
end