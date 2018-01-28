print ('[ITT] itt.lua' )

TEAM_COLORS = {}
TEAM_COLORS[DOTA_TEAM_GOODGUYS] = { 52, 85, 255 }  -- Blue
TEAM_COLORS[DOTA_TEAM_BADGUYS]  = { 255, 52, 85 }  -- Red
TEAM_COLORS[DOTA_TEAM_CUSTOM_1] = { 101, 212, 19 } -- Green
TEAM_COLORS[DOTA_TEAM_CUSTOM_2] = { 243, 201, 9 }  -- Yellow
TEAM_NAMES = {[DOTA_TEAM_GOODGUYS]="Blue Tribe",
              [DOTA_TEAM_BADGUYS]="Red Tribe",
              [DOTA_TEAM_CUSTOM_1]="Green Tribe",
              [DOTA_TEAM_CUSTOM_2]="Blue Tribe",
              [DOTA_TEAM_NEUTRALS]="Neutral"}

playerList = {}
maxPlayerID = 0

GAME_TICK_TIME              = 0.1   -- The game should update every tenth second
GAME_TROLL_TICK_TIME        = 0.5   -- Its really like its wc3!
FLASH_ACK_THINK             = 2

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
-- GAME_TESTING_CHECK          = true

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
    --Timers(function() ITT:OnBuildingThink() return GAME_TROLL_TICK_TIME end)
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
    GameRules:SetTreeRegrowTime( 160.0 )
    GameRules:SetCreepMinimapIconScale( 0.7 )
    GameRules:SetRuneMinimapIconScale( 0.7 )
    GameRules:SetGoldTickTime( 60.0 )
    GameRules:SetGoldPerTick( 0 )

    -- Forcepick hero to skip default hero selection.
    GameRules:GetGameModeEntity():SetCustomGameForceHero("npc_dota_hero_wisp")


    -- Listeners
    ListenToGameEvent('player_connect_full', Dynamic_Wrap(ITT, 'OnPlayerConnectFull'), self)
    ListenToGameEvent( "npc_spawned", Dynamic_Wrap( ITT, "OnNPCSpawned" ), self )
    ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap(ITT, 'OnItemPickedUp'), self)
    ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap(ITT, 'OnPlayerGainedLevel'), self)
    ListenToGameEvent("entity_killed", Dynamic_Wrap( ITT, "OnEntityKilled" ), self )
    ListenToGameEvent("entity_hurt", Dynamic_Wrap(ITT, 'On_entity_hurt'), self)
    --ListenToGameEvent('player_chat', Dynamic_Wrap(ITT, 'OnPlayerChat'), self)
    ListenToGameEvent("player_reconnected", Dynamic_Wrap(ITT, 'OnPlayerReconnected'), self)
    ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( ITT, 'OnGameRulesStateChange' ), self )

    -- Panorama Listeners
    CustomGameEventManager:RegisterListener('custom_chat_say', Dynamic_Wrap( ITT, "OnPlayerChat"))

    CustomGameEventManager:RegisterListener( "game_mode_selected", Dynamic_Wrap( ITT, "OnGameModeSelected" ) )
    CustomGameEventManager:RegisterListener( "player_selected_class", Dynamic_Wrap( ITT, "OnClassSelected" ) )
    CustomGameEventManager:RegisterListener( "player_selected_subclass", Dynamic_Wrap( ITT, "OnSubclassChange" ) )

    CustomGameEventManager:RegisterListener( "player_sleep_outside", Dynamic_Wrap( ITT, "Sleep" ) )
    CustomGameEventManager:RegisterListener( "player_eat_meat", Dynamic_Wrap( ITT, "EatMeat" ) )
    CustomGameEventManager:RegisterListener( "player_drop_meat", Dynamic_Wrap( ITT, "DropMeat" ) )
    CustomGameEventManager:RegisterListener( "player_drop_all_meat", Dynamic_Wrap( ITT, "DropAllMeat" ) )
    CustomGameEventManager:RegisterListener( "player_panic", Dynamic_Wrap( ITT, "Panic" ) )
    CustomGameEventManager:RegisterListener( "player_rest_building", Dynamic_Wrap( ITT, "RestBuilding" ) )
    CustomGameEventManager:RegisterListener( "player_dropallitems", Dynamic_Wrap( ITT, "DropAllItems" ) )

    -- Filters
    GameMode:SetExecuteOrderFilter( Dynamic_Wrap( ITT, "FilterExecuteOrder" ), self )
    GameMode:SetDamageFilter( Dynamic_Wrap( ITT, "FilterDamage" ), self )
    GameMode:SetModifyExperienceFilter( Dynamic_Wrap( ITT, "FilterExperience" ), self )
    GameMode:SetModifyGoldFilter( Dynamic_Wrap( ITT, "FilterGold" ), self )

    -- Don't end the game if everyone is unassigned
    --SendToServerConsole("dota_surrender_on_disconnect 0")

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

  --  GameRules.APPLIER = CreateItem("item_apply_modifiers", nil, nil)

    -- Custom Stats for STR/AGI/INT
    Stats:Init()

    -- KV Tables
    GameRules.ClassInfo = LoadKeyValues("scripts/kv/class_info.kv")
    GameRules.GameModeSettings = LoadKeyValues("scripts/kv/game_mode_settings.kv")
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
    GameRules.SpawnLocationType = "random"
    GameRules.SpawnRegion = "Island"
    GameRules.BushSpawnLocationType = "predefined"
    GameRules.BushSpawnRegion = "Island"

    LoadCraftingTable()

    -- Load Chat
    self.Chat = Chat(playerList,TEAM_COLORS)

    -- Load Quests
    self.Quests = Quests()

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
    SendToServerConsole( "dota_combine_models 1" )

    -- Lua Modifiers
    LinkLuaModifier("modifier_chicken_form", "heroes/beastmaster/subclass_modifiers.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_pack_leader", "heroes/beastmaster/subclass_modifiers.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_shapeshifter", "heroes/beastmaster/subclass_modifiers.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_model_scale", "libraries/modifiers/modifier_model_scale", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_minimap", "libraries/modifiers/modifier_minimap", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_wearable_visuals", "libraries/modifiers/modifier_wearable_visuals", LUA_MODIFIER_MOTION_NONE)

    print('[ITT] Done loading gamemode!')
end

 --disables rosh pit
function ITT:UnblockMammoth()
    mammothBoss = CreateUnitByName("npc_boss_mammoth", Vector(0,0,10), true, nil, nil, DOTA_TEAM_NEUTRALS)
end


function ITT:KillMammoth()
    print("Trying to move and delete mammoth and duck")
	if (mammothBoss ~= nil)  then
		print("Deleting Mammoth")
		mammothBoss:SetOrigin(Vector(5000,0,0 - 5))
		mammothBoss:ForceKill(true)
	end

	if (duckBoss ~= nil)  then
		print("Deleting Duck")
		duckBoss:SetOrigin(Vector(5000,0,0 - 5))
		duckBoss:ForceKill(true)
	end
end


-- This code is written by Internet Veteran, handle with care.
--Do the same now for the subclasses
function ITT:OnNPCSpawned( keys )
    local spawnedUnit = EntIndexToHScript( keys.entindex )
    --print("spawned unit: ", spawnedUnit:GetUnitName(), spawnedUnit:GetClassname(), spawnedUnit:GetName(), spawnedUnit:GetEntityIndex())

    if not spawnedUnit or spawnedUnit:IsNull() or not spawnedUnit:GetUnitName() then return end
    if spawnedUnit:GetClassname() == "npc_dota_thinker" then return end

    if spawnedUnit:IsRealHero() then
        if not spawnedUnit.bFirstSpawned then
            spawnedUnit.bFirstSpawned = true
            ITT:OnHeroInGame(spawnedUnit)
        else
            ITT:OnHeroRespawn(spawnedUnit)
        end
    end

    if GameRules.UnitKV[spawnedUnit:GetUnitName()] then
        local fillSlots = GameRules.UnitKV[spawnedUnit:GetUnitName()]["FillSlots"]
        if fillSlots then
            ITT:CreateLockedSlotsForUnits(spawnedUnit, fillSlots)
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
        {"npc_boss_mammoth", {"item_bone", 100},{"item_bone", 100},{"item_bone", 100},{"item_bone", 100}, {"item_horn_mammoth", 100}, {"item_horn_mammoth", 50}, {"item_spear_dark", 5}, {"item_spear_iron", 5}, {"item_axe_iron", 15}},
        {"npc_boss_disco_duck", {"item_bone", 100},{"item_bone", 100},{"item_bone", 100},{"item_bone", 100}, {"item_potion_anabolic", 5}, {"item_crystal_mana", 20}, {"item_crystal_mana", 20}, {"item_crystal_mana", 20}, {"item_crystal_mana", 5}, {"item_spear_dark", 5}},
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
        {"npc_creep_fawn", 1},
        {"npc_creep_bear_cub", 1},
        {"npc_creep_wolf_pup", 1},

        {"npc_creep_hawk", 2},
        {"npc_boss_disco_duck", 10},
        {"npc_boss_mammoth", 15}
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
    if string.find(unitName, "creep") or string.find(unitName, "boss") and not killedUnit.no_corpse then
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
    if killedUnit.IsRealHero and killedUnit:IsRealHero() then
        ITT:CheckWinCondition()

        killedUnit:SplitExperienceBounty(killer:GetTeamNumber())

        local pos = killedUnit:GetAbsOrigin()

        --if it's a hero, drop all carried raw meat, plus 3, and a bone
        local meatStacksBase = killedUnit:GetModifierStackCount("modifier_meat_passive", nil) + 3
        local meatStacks = GetMeatStacksToDrop(meatStacksBase, killedUnit, killer)
        local decayTime = GetMeatDecayTime(killedUnit, killer)
        CreateRawMeatAtLoc(killedUnit:GetOrigin(), meatStacks, decayTime, GameRules:GetGameTime())

        -- Launch all carried items excluding the fillers
        local points = GenerateNumPointsAround(killedUnit:GetNumItemsInInventory()+1, pos, 120)
        local numDrop = 1
        for i=0,5 do
            local item = killedUnit:GetItemInSlot(i)
            if item and item:GetAbilityName() ~= "item_slot_locked" then
                local clonedItem = CreateItem(item:GetName(), nil, nil)
                if item:GetCurrentCharges() > 1 then
                    clonedItem:SetCurrentCharges(item:GetCurrentCharges())
                end
                CreateItemOnPositionSync(points[numDrop],clonedItem)
                clonedItem:LaunchLoot(false, 200, 0.75, points[numDrop])
                item:RemoveSelf()
                numDrop = numDrop + 1
            end
        end

        CreateItemOnPositionSync(points[numDrop], CreateItem("item_bone", nil, nil))

        -- Create a grave if respawn is disabled
        local time = math.floor(GameRules:GetGameTime())
        if time > GAME_PERIOD_GRACE or GameRules.GameModeSettings["custom"]["norevive"] then
            killedUnit.grave = CreateUnitByName("gravestone", killedUnit:GetAbsOrigin(), false, killedUnit, killedUnit, killedUnit:GetTeamNumber())
            killedUnit.grave:SetTeam(killedUnit:GetTeam())
            killedUnit.grave.hero = killedUnit
			killedUnit.deathParticle = ParticleManager:CreateParticle("particles/custom/tombstone_spawnspawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, killedUnit)
			killedUnit:EmitSound("tombstone.spawn")
        end

        CreateGoldBag(killedUnit)

        -- Notify self and allies when someone dies.
        local id = killedUnit:GetPlayerID()
        CustomGameEventManager:Send_ServerToTeam(killedUnit:GetTeam(), "team_member_down", {
            hero = PlayerResource:GetSelectedHeroName(id),
            player = id
        })

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
                        CreateItemOnPositionSync(killedUnit:GetOrigin() + RandomVector(RandomInt(30,100)), newItem)
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
    --local attacker = EntIndexToHScript(data.entindex_attacker)
    local hurt = EntIndexToHScript(data.entindex_killed)
    if (string.find(hurt:GetUnitName(), "elk") or string.find(hurt:GetUnitName(), "fish") or string.find(hurt:GetUnitName(), "hawk")) then
        hurt.state = "flee"
    end
    --print("attacker: "..attacker:GetUnitName(), "hurt: "..hurt:GetUnitName())

end


function ITT:CreateSpeechBubble(unit, time, dialogueMessage)
    unit:DestroyAllSpeechBubbles()
    local speechSlot = 1
    unit:AddSpeechBubble(speechSlot, dialogueMessage, time, 0, 0)
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




-- This function checks if you won the game or not
function ITT:CheckWinCondition()
    if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then return end
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
		ITT:KillMammoth()
        ITT:SetHerosIntoEndScreen(winnerTeamID)
        ITT:PrintWinMessageForTeam(winnerTeamID)
        GameRules:SetGameWinner(winnerTeamID)
    end
end



function ITT:SetHerosIntoEndScreen( teamID )
    GameRules:GetGameModeEntity():SetFogOfWarDisabled(true)
    local count = PlayerResource:GetPlayerCountForTeam(teamID)
    local vec_start = Vector(220,-484,384)
    local vec_end = Vector(-220,-484,384)
    local vec_step = (vec_end - vec_start) / (count + 1)
    local ind = 1
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            local team = PlayerResource:GetTeam(playerID)
            if team == teamID then
                local hero = PlayerResource:GetSelectedHeroEntity(playerID)
                if hero:IsAlive() then
					EndAnimation(hero)
					hero:Stop()
					hero:RemoveModifierByName("modifier_cold2")
					hero:RemoveModifierByName("modifier_frozen")
                    hero:SetAbsOrigin(vec_start + vec_step * ind)
                    hero:SetAngles(0,-90,0)
                    ind = ind + 1    
					StartAnimation(hero, {duration=30, activity=ACT_DOTA_VICTORY, rate=1})
                end
            end
        end
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
        -- Drop gloves and axes on chicken...or not
        --if hero:GetSubClass() == "chicken_form" and (itemSlotRestriction == "Axes" or itemSlotRestriction == "Gloves") then
        --    hero:DropItemAtPositionImmediate(originalItem, hero:GetAbsOrigin())
        --    SendErrorMessage(hero:GetPlayerOwnerID(), "#error_chicken_cant_carry_"..itemSlotRestriction) --Concatenated error message
        --end

        local maxCarried = GameRules.ItemInfo['MaxCarried'][itemSlotRestriction]
        local count = GetNumItemsOfSlot(hero, itemSlotRestriction)

        -- Drop the item if the hero exceeds the possible max carried amount
        if count > maxCarried then
            hero:DropItemAtPositionImmediate(originalItem, hero:GetAbsOrigin())
            SendErrorMessage(hero:GetPlayerOwnerID(), "#error_cant_carry_more_"..itemSlotRestriction) --Concatenated error message
        end
    end

    -- Set item ownership to whoever picked it up
    originalItem:SetPurchaser(hero)

    local hasTelegather = hero:HasModifier("modifier_telegather")
    local hasHerbTelegather = hero:HasModifier("modifier_herbtelegather")
    local hasTelethief = hero:HasModifier("modifier_thief_telethief")

    -- Related to RadarTelegathererInit
    if hasTelegather then
        local didTeleport = TeleportItem(hero,originalItem)
    end
    if hasHerbTelegather then
        local didTeleport = TeleportItemHerb(hero,originalItem)
    end
	
    -- Related to TeleThiefInit
    if hasTelethief then
        local didTeleport = TeleportItemTeletheif(hero,originalItem)
    end
end

function TeleportItemTeletheif(hero,originalItem)
    local targetFire = hero.targetFire
    local newItem = CreateItem(originalItem:GetName(), nil, nil)
    local teleportSuccess = false
    local teamNumber = hero:GetTeamNumber()
    local telegatherBuff = hero:FindModifierByName("modifier_thief_telethief")
    local telegatherAbility = telegatherBuff:GetAbility()
    local percentChance = 100
   --print("Teleporting item : " .. telegatherAbility:GetAbilityName() .. ", " .. percentChance .."% chance")

    local itemList = {"item_tinder", "item_flint", "item_stone", "item_stick", "item_bone", "item_meat_raw",  "item_crystal_mana", "item_ball_clay", "item_hide_elk", "item_hide_wolf", "item_hide_bear", "item_magic_raw", "item_herb_blue", "item_herb_butsu", "item_herb_orange", "item_herb_purple", "item_herb_yellow", "item_thistles", "item_river_root", "item_river_stem", "item_acorn", "item_acorn_magic", "item_mushroom", "item_spirit_water", "item_spirit_wind"}
	local buildings = FindUnitsInRadius(teamNumber, hero:GetAbsOrigin(), nil, 500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    
	local casterOrigin = hero:GetOrigin()
    local units = FindUnitsInRadius(teamNumber, casterOrigin, nil, 550, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
	
	if  hero:HasModifier("modifier_recentlytelethiefed") then
	SendErrorMessage(hero:GetPlayerOwnerID(),"#error_telegather_cooldown")
	end
	if  not hero:HasModifier("modifier_recentlytelethiefed") then
		for _,enemy in pairs(units) do
			for key,value in pairs(itemList) do
				if value == originalItem:GetName() then
						--print( "Teleporting Item", originalItem:GetName())
						hero:RemoveItem(originalItem)
						local itemPosition = targetFire:GetAbsOrigin() + RandomVector(RandomInt(100,150))
						CreateItemOnPositionSync(itemPosition,newItem)
						newItem:SetOrigin(itemPosition)
						hero:EmitSound("Hero_Zuus.Attack")
						local item = CreateItem("item_apply_modifiers", hero, hero)
						item:ApplyDataDrivenModifier(hero, hero, "modifier_recentlytelethiefed", {duration = 5.0})
						teleportSuccess = true
						return teleportSuccess
				end
			end
			return teleportSuccess
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

    local itemList = {"item_tinder", "item_flint", "item_stone", "item_stick", "item_bone", "item_meat_raw",  "item_crystal_mana", "item_ball_clay", "item_hide_elk", "item_hide_wolf", "item_hide_bear", "item_magic_raw"}
    if hero:GetSubClass() == "herbal_master_telegatherer" then
        itemList = {"item_herb_blue", "item_herb_butsu", "item_herb_orange", "item_herb_purple", "item_herb_yellow", "item_thistles", "item_river_root", "item_river_stem", "item_acorn", "item_acorn_magic", "item_mushroom", "item_spirit_water", "item_spirit_wind"}
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
				hero:EmitSound("Hero_Zuus.Attack")
                teleportSuccess = true
                return teleportSuccess
            end
        end
    end
    return teleportSuccess
end



function TeleportItemHerb(hero,originalItem)
    local targetFire = hero.targetFire
    local newItem = CreateItem(originalItem:GetName(), nil, nil)
    local teleportSuccess = false
 
    local herbtelegatherBuff = hero:FindModifierByName("modifier_herbtelegather")
    local telegatherAbility = herbtelegatherBuff:GetAbility()
    local percentChance = telegatherAbility:GetSpecialValueFor("percent_chance")
   --print("Teleporting item : " .. telegatherAbility:GetAbilityName() .. ", " .. percentChance .."% chance")

    local itemList = {"item_tinder", "item_flint", "item_stone", "item_stick", "item_bone", "item_meat_raw",  "item_crystal_mana", "item_ball_clay", "item_hide_elk", "item_hide_wolf", "item_hide_bear", "item_magic_raw"}
    if hero:GetSubClass() == "herbal_master_telegatherer" then
        itemList = {"item_herb_blue", "item_herb_butsu", "item_herb_orange", "item_herb_purple", "item_herb_yellow", "item_thistles", "item_river_root", "item_river_stem", "item_acorn", "item_acorn_magic", "item_mushroom", "item_spirit_water", "item_spirit_wind"}
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

  --  print("[ITT] OnPlayerLevelUp - Player "..playerID.." ("..class..") has reached level "..level)

	hero.levelParticle = ParticleManager:CreateParticle("particles/custom/hero_levelup.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
	Sounds:EmitSoundOnClient(playerID, "Level.Up")
	
    -- If the hero reached level 6 and hasn't unlocked a subclass, make the button clickable
    if level >= 6 and not hero:HasSubClass() then
        CustomGameEventManager:Send_ServerToPlayer(player, "player_unlock_subclass", {className=class} )
		  Timers:CreateTimer(.1, function()
		CustomGameEventManager:Send_ServerToPlayer(player, "player_unlock_subclass", {className=class} )
    end
  )
        

        if level == 6 then
            local particleName = "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_spirit_form_ambient.vpcf"
            hero.subclassAvailableParticle = ParticleManager:CreateParticleForTeam(particleName, PATTACH_ABSORIGIN_FOLLOW, hero, hero:GetTeamNumber())
            Notifications:Bottom(PlayerResource:GetPlayer(playerID), {text="Hero subclass selection now available!", duration=10, style={color="white"}, continue=true})

            EmitSoundOnClient("Hero_Chen.HandOfGodHealHero", PlayerResource:GetPlayer(playerID))
        end
    end

    -- Update skills
    ITT:AdjustSkills(hero)
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

function call_harmful(name, cb)
    status, err = pcall(cb);
    if err then

    end
    return status
end

---------------------------------------------------------------------------
-- Game state change handler
---------------------------------------------------------------------------
function ITT:OnGameRulesStateChange()
    local nNewState = GameRules:State_Get()
--  print( "OnGameRulesStateChange: " .. nNewState )

    if nNewState == DOTA_GAMERULES_STATE_HERO_SELECTION then
        SendToConsole("dota_camera_disable_zoom 1")

		SendToConsole("bind ENTER +EnterPressed")
		SendToConsole("bind KP_ENTER +EnterPressed")

        Spawns:Init()
        Timers(function() ITT:OnItemThink() return GameRules.GameModeSettings["GAME_ITEM_TICK_TIME"] end) --item_spawning.lua

        -- Initialize the roaming trading ships
        ITT:SetupShops()

        ITT:ShareUnits()

        CraftMaster:Spawn()

        -- Start the 1min timer for gamemode voting.
        ITT:StartVoting()
    elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then

        GameRules:SetHeroRespawnEnabled( false )
        RandomUnpickedPlayers()
        ITT:UnblockMammoth()
        EmitGlobalSound("get_ready")
       -- ShowCustomHeaderMessage("#NoobTimeOver", -1, -1, 5)
		Notifications:TopToAll({text="#NoobTimeOver", image="file://{images}/materials/particle/alert.psd", duration=5.0})
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
    for team, players in pairs(playersOnTeams) do
        for _, player in pairs(players) do
            for _, otherplayer in pairs(players) do
                if player ~= otherplayer then
                    PlayerResource:SetUnitShareMaskForPlayer(player, otherplayer, 2, true)
                end
            end
        end
    end

    --[==[
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
    --]==]
end
