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
            id = self.first_all_id
        else
            id = self.first_class_id
        end
        hero.current_quests[type] = id -- Only track main questlines
    end

    local quest = self.quests[type][id]
    if not quest then return end

    if id == self.first_all_id or id == self.first_class_id then
        print("Starting all quests for "..type)
        -- We are initializing all the delayed quests.
        self:StartDelayed(hero, type)
    end

    self:StartNowOrDelayed(hero, type, quest, id)
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

    quest.quest.context.current = value
    quest.quest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, value)
    quest.subquest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, value)

    if value == quest.quest.context.to then
        self:End(hero, id)
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
    if not quest or quest.quest.finished then return end

    local type = quest.quest.type
    local next_quest = self.quests[type][id + 1]
    local in_questline = true
    if not next_quest then
        in_questline = false
    end

    -- Quest complete!
    EmitSoundOnClient("quest.complete", PlayerResource:GetPlayer(hero:GetPlayerID()))
    quest.quest:CompleteQuest()
    quest.quest.finished = true
    print("Quest #"..id.." has ended.")

    if quest.quest.context.type == "Hook" then
        if quest.quest.context.event_type == "Custom" then
            CustomGameEventManager:UnregisterListener(quest.quest.context.event_hook_id)
        else
            StopListeningToGameEvent(quest.quest.context.event_hook_id)
        end
    end

    if in_questline then
        -- If it's in our questline, start the next one.
        hero.current_quests[type] = id + 1

        self:StartNowOrDelayed(hero, type, next_quest, id + 1)
    end
end

-- Check if a quest is finished.
function Quests:IsFinished(hero, id)
    local quest = hero.quests[id]
    return quest and quest.finished
end

--- ############### INTERNAL
--- ############### DO NOT USE THESE DIRECTLY

function Quests:constructor()
    self.quests = GameRules.quests_table
    self.first_all_id = 1
    self.first_class_id = 100

    self:BuildHooks()
end

function Quests:StartTracking(hero, quest)
    if quest.context.type == "Time" then
        self:StartTimer(hero, quest)
    elseif quest.context.type == "Hook" then
        self:StartHook(hero, quest)
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
            if self.hooks[quest.context.event_name] then
                self.hooks[quest.context.event_name](args[1], args[2], keys)
            end
        end, {hero, quest})
    end
end

function Quests:StartTimer(hero, quest)
    Timers:CreateTimer(DoUniqueString("quest_timer"), {
        endTime = 1.0,
        callback = function()
            if not self:IsFinished(hero, quest.id) then
                if quest.context.track then
                    quest.context.track(hero, quest, self)
                else
                    local val
                    if quest.context.from < quest.context.to then
                        val = quest.context.current + 1
                    else
                        val = quest.context.current - 1
                    end
                    self:UpdateQuest(hero, val, quest.id)
                end
                return 1
            end
        end
    })
end

function Quests:StartDelayed(hero, type)
    for k,v in pairs(self.quests[type]) do
        if v.context.delay_start and v.context.delay_start > 0 and not self.quests[type][k - 1] then
            -- Checks that it has a delayed start, and it's not in the middle of a questline.
            Timers:CreateTimer({
                endTime = v.context.delay_start - GameRules:GetGameTime(),
                callback = function()
                    self:StartQuest(hero, type, v, k)
                end
            })
        end
    end
end

function Quests:StartNowOrDelayed(hero, type, quest, id)
    -- Check if it's delayed.
    if quest.context.delay_start and quest.context.delay_start > 0 and GameRules:GetGameTime() < quest.context.delay_start then
        Timers:CreateTimer({
            endTime = quest.context.delay_start - GameRules:GetGameTime(),
            callback = function()
                self:StartQuest(hero, type, quest, id)
            end
        })
    else
        self:StartQuest(hero, type, quest, id)
    end
end

function Quests:StartQuest(hero, type, quest, id) -- Abstracting here.
    if hero.quests[id] then -- Don't start it again!
        print("Quest has already started!")
        return
    end

    local actual_quest = SpawnEntityFromTableSynchronous("quest", {
      name = quest.name,
      title = quest.title
    })


    -- For progressive quests (with progress bars)
    -- Quest starts from "from"
    -- Ends in "to"
    -- Progress is tracked in "current"

    -- For quests that only have a single thing in them (no progress bar needed.)
    -- Leave out the "from" and "to" from the context.

    local show_progress = false
    if quest.context.from and quest.context.to then
        show_progress = true
        quest.context.current = quest.context.from
    end

    actual_quest.context = quest.context
    actual_quest.finished = false
    actual_quest.type = type
    actual_quest.id = id

    local actual_subquest = SpawnEntityFromTableSynchronous("subquest_base", {
      show_progress_bar = show_progress,
      progress_bar_hue_shift = -119
    })

    actual_quest:AddSubquest(actual_subquest)

    if show_progress then   -- Progress bar stuff.
        actual_quest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, quest.context.from)
        actual_subquest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, quest.context.from)

        -- Progress bar can go in either direction.
        if quest.context.from < quest.context.to then -- From left to right.
            actual_quest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, quest.context.to)
            actual_subquest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, quest.context.to)
        else -- From right to left.
            actual_quest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, quest.context.from)
            actual_subquest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, quest.context.from)
        end
    end

    print("Quest #"..id.." has been started!")
    -- Track quests that have been started.
    hero.quests[id] = {
        quest = actual_quest,
        subquest = actual_subquest
    }


    self:StartTracking(hero, actual_quest)
end

function Quests:BuildHooks()
    self.hooks = {}

    self.hooks.dota_item_picked_up = function(hero, quest, keys)
        local h = PlayerResource:GetSelectedHeroEntity(keys.PlayerID)
        if h == hero then
            quest.context.event_func(hero, quest, keys.itemname, self)
        end
    end

    self.hooks.dota_money_changed = function(hero, quest, keys)
        -- Doesn't work at all.
        PrintTable(keys)
    end

    -- Doesn't work.
    self.hooks.dota_player_learned_ability = function(hero, quest, keys)
        PrintTable(keys)
        local h = PlayerResource:GetSelectedHeroEntity(keys.player)
        if h == hero then
            quest.context.event_func(hero, quest, keys.abilityname, self)
        end
    end

    -- Used for both abilities and items.
    self.hooks.dota_player_used_ability = function(hero, quest, keys)
        local h = PlayerResource:GetSelectedHeroEntity(keys.PlayerID)
        if h == hero then
            quest.context.event_func(hero, quest, keys.abilityname, self)
        end
    end

    -- Does not have a playerID
    self.hooks.dota_ability_channel_finished = function(hero, quest, keys)
        print("dota_ability_channel_finished")
        PrintTable(keys)
    end

    self.hooks.dota_player_killed = function(hero, quest, keys)
        PrintTable(keys)
    end

    self.hooks.npc_spawned = function(hero, quest, keys)
        PrintTable(keys)
    end

    self.hooks.tree_cut = function(hero, quest, keys)
        PrintTable(keys)
    end

    self.hooks.entity_killed = function(hero, quest, keys)
        local killedUnit = EntIndexToHScript(keys.entindex_killed)
        local killer = EntIndexToHScript(keys.entindex_attacker or 0)
        if killer == hero then
            quest.context.event_func(hero, quest, killedUnit, self)
        end
    end
end
