Quests = Quests or class({})

require("quests_table")

-- Quests:Start(hero, type, id)
-- hero is a hero entity. This is used for storing the quest for the hero.
-- type is either "all" or the hero class.
-- id is used only when starting non-questline quests.
----------------------
-- Function:
-- Starts a quest.
-- If an id is given, start the quest with that id.
-- Without an id, only start the first quest in that type of questline.
function Quests:Start(hero, type, id)
    if not hero.current_quests then
        hero.current_quests = {}
        hero.quests = {}
    end

    if not id then
        if type == "all" then
            id = Quests.first_all_id
        else
            id = Quests.first_class_id
        end
        hero.current_quests[type] = id -- Only track main questlines
    end

    local quest = Quests.quests[type][id]
    if not quest then return end

    if id == Quests.first_all_id or id == Quests.first_class_id then
        print("Starting all quests for "..type)
        -- We are initializing all the delayed quests.
        Quests:StartDelayed(hero, type)
    end

    Quests:StartNowOrDelayed(hero, type, quest, id)
end

-- Quests:UpdateQuest(hero, value ,id)
-- hero is a hero entity.
-- value is the new value for the quest.
-- id is used for the quest id.
----------------------
-- Function:
-- Updates the quest with the value.
-- Should work whichever direction the progress is going.
function Quests:UpdateQuest(hero, value, id)
    local quest = hero.quests[id]
    if not quest then return end

    quest.context.current = value
    local playerID = hero:GetPlayerID()
    PlayerTables:SetTableValue("quests_"..playerID, id, {
        current = value
    })

    if value == quest.context.to then
        Quests:End(hero, id)
    end
end

-- Quests:End(hero, id)
-- hero is a hero entity.
-- id is used for the quest id.
----------------------
-- Function:
-- Ends the quest and checks if it's a questline.
-- If it is, start the next one.
-- Also checks if the next quest in the questline only starts after a certain time.
function Quests:End(hero, id)
    local quest = hero.quests[id]
    if not quest or quest.finished then return end

    local type = quest.type
    local next_quest = Quests.quests[type][id + 1]
    local in_questline = true
    if not next_quest then
        in_questline = false
    end

    -- Quest complete!
    EmitSoundOnClient("quest.complete", PlayerResource:GetPlayer(hero:GetPlayerID()))
    quest.finished = true

    local playerID = hero:GetPlayerID()
    PlayerTables:SetTableValue("quests_"..playerID, id, {
        finished = true
    })

    print("Quest #"..id.." has ended.")

    if quest.context.type == "Hook" then
        if quest.context.event_type == "Custom" then
            CustomGameEventManager:UnregisterListener(quest.context.event_hook_id)
        else
            StopListeningToGameEvent(quest.context.event_hook_id)
        end
    end

    if in_questline then
        -- If it's in our questline, start the next one.
        hero.current_quests[type] = id + 1

        Quests:StartNowOrDelayed(hero, type, next_quest, id + 1)
    end
end

function Quests:StopQuests(keys)
    local hero = PlayerResource:GetSelectedHeroEntity(keys.playerID)

    local IDs = {}
    for k,v in pairs(hero.quests) do
        IDs[k] = {finished = true}
        local quest = hero.quests[k]
        quest.finished = true
    end

    local playerID = hero:GetPlayerID()
    PlayerTables:SetTableValues("quests_"..playerID, IDs)

    hero.quests_stopped = true
end

-- Check if a quest is finished.
function Quests:IsFinished(hero, id)
    local quest = hero.quests[id]
    return quest and quest.finished
end

--- ############### INTERNAL
--- ############### DO NOT USE THESE DIRECTLY

function Quests:constructor()
    Quests.quests = GameRules.quests_table
    Quests.first_all_id = 1
    Quests.first_class_id = 100

    CustomGameEventManager:RegisterListener("start_quests", Dynamic_Wrap(Quests, "StartQuests"))
    CustomGameEventManager:RegisterListener("stop_quests", Dynamic_Wrap(Quests, "StopQuests"))

    Quests:BuildHooks()
end

function Quests:StartQuests(keys)
    local hero = PlayerResource:GetSelectedHeroEntity(keys.playerID)

    hero.spawned_time = GameRules:GetGameTime()
    Quests:Start(hero, "all")
    Quests:Start(hero, hero:GetHeroClass())
end

function Quests:StartTracking(hero, quest)
    if quest.context.type == "Time" then
        Quests:StartTimer(hero, quest)
    elseif quest.context.type == "Hook" then
        Quests:StartHook(hero, quest)
    end
end

function Quests:StartHook(hero, quest)
    -- These use a different function
    if quest.context.event_type == "Custom" then
        quest.context.event_hook_id = CustomGameEventManager:RegisterListener(quest.context.event_name, function(args)
            quest.context.event_func(args)
        end)
    else
        quest.context.event_hook_id = ListenToGameEvent(quest.context.event_name, function(args, keys)
            if Quests.hooks[quest.context.event_name] then
                Quests.hooks[quest.context.event_name](args[1], args[2], keys)
            end
        end, {hero, quest})
    end
end

function Quests:StartTimer(hero, quest)
    Timers:CreateTimer(DoUniqueString("quest_timer"), {
        endTime = 1.0,
        callback = function()
            if not Quests:IsFinished(hero, quest.id) then
                if quest.context.track then
                    quest.context.track(hero, quest)
                else
                    local val
                    if quest.context.from < quest.context.to then
                        val = quest.context.current + 1
                    else
                        val = quest.context.current - 1
                    end
                    Quests:UpdateQuest(hero, val, quest.id)
                end
                return 1
            end
        end
    })
end

function Quests:StartDelayed(hero, type)
    for k,v in pairs(Quests.quests[type]) do
        if v.context.delay_start and v.context.delay_start > 0 and not Quests.quests[type][k - 1] then
            -- Checks that it has a delayed start, and it's not in the middle of a questline.
            Timers:CreateTimer({
                endTime = v.context.delay_start - (GameRules:GetGameTime() - hero.spawned_time),
                callback = function()
                    Quests:StartQuest(hero, type, v, k)
                end
            })
        end
    end
end

function Quests:StartNowOrDelayed(hero, type, quest, id)
    -- Check if it's delayed.
    if quest.context.delay_start and quest.context.delay_start > 0 and GameRules:GetGameTime() - hero.spawned_time < quest.context.delay_start then
        Timers:CreateTimer({
            endTime = quest.context.delay_start - GameRules:GetGameTime(),
            callback = function()
                Quests:StartQuest(hero, type, quest, id)
            end
        })
    else
        Quests:StartQuest(hero, type, quest, id)
    end
end

function Quests:StartQuest(hero, type, quest, id) -- Abstracting here.
    if hero.quests[id] then -- Don't start it again!
        print("Quest has already started!")
        return
    end

    if hero.quests_stopped then -- Stop starting new ones.
        return
    end

    -- For progressive quests (with progress bars)
    -- Quest starts from "from"
    -- Ends in "to"
    -- Progress is tracked in "current"

    -- For quests that only have a single thing in them (no progress bar needed.)
    -- Leave out the "from" and "to" from the context.
    if not quest.desc then quest.desc = "" end

    local actual_quest = {
      id = id,
      title = quest.title,
      desc = quest.desc,
      context = quest.context,
      finished = false,
      type = type
    }

    local show_progress = false
    if quest.context.from and quest.context.to then
        show_progress = true
        actual_quest.context.current = quest.context.from
    end

    actual_quest.show_progress = show_progress

    print("Quest #"..id.." has been started!")
    -- Track quests that have been started.
    hero.quests[id] = actual_quest

    local playerID = hero:GetPlayerID()
    if not PlayerTables:TableExists("quests_"..playerID) then
        PlayerTables:CreateTable("quests_"..playerID, {}, {playerID})
    end

    local progress_bar = false
    if show_progress then
        progress_bar = {
            from = quest.context.from,
            to = quest.context.to
        }
    end

    Timers:CreateTimer({
        endTime = 3,
        callback = function()
            if hero.quests_stopped then return end
            PlayerTables:SetTableValue("quests_"..playerID, id, {
                title = quest.title,
                desc = quest.desc,
                progress_bar = progress_bar
            })

            Quests:StartTracking(hero, actual_quest)
        end
    })
end

function Quests:BuildHooks()
    Quests.hooks = {}

    Quests.hooks.dota_item_picked_up = function(hero, quest, keys)
        local h = PlayerResource:GetSelectedHeroEntity(keys.PlayerID)
        if h == hero then
            quest.context.event_func(hero, quest, keys.itemname)
        end
    end

    Quests.hooks.dota_money_changed = function(hero, quest, keys)
        -- Doesn't work at all.
        PrintTable(keys)
    end

    -- Doesn't work.
    Quests.hooks.dota_player_learned_ability = function(hero, quest, keys)
        PrintTable(keys)
        local h = PlayerResource:GetSelectedHeroEntity(keys.player)
        if h == hero then
            quest.context.event_func(hero, quest, keys.abilityname)
        end
    end

    -- Used for both abilities and items.
    Quests.hooks.dota_player_used_ability = function(hero, quest, keys)
        local h = PlayerResource:GetSelectedHeroEntity(keys.PlayerID)
        if h == hero then
            quest.context.event_func(hero, quest, keys.abilityname)
        end
    end

    -- Does not have a playerID
    Quests.hooks.dota_ability_channel_finished = function(hero, quest, keys)
        print("dota_ability_channel_finished")
        PrintTable(keys)
    end

    Quests.hooks.dota_player_killed = function(hero, quest, keys)
        PrintTable(keys)
    end

    Quests.hooks.npc_spawned = function(hero, quest, keys)
        PrintTable(keys)
    end

    Quests.hooks.tree_cut = function(hero, quest, keys)
        PrintTable(keys)
    end

    Quests.hooks.entity_killed = function(hero, quest, keys)
        local killedUnit = EntIndexToHScript(keys.entindex_killed)
        local killer = EntIndexToHScript(keys.entindex_attacker or 0)
        if killer == hero then
            quest.context.event_func(hero, quest, killedUnit)
        end
    end
end
