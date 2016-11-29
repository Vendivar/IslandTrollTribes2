Quests = Quests or class({})

-- quests_table
-- Holds all the quests, could also be made as a KV table.
-- global quests (for all classes) start from index 1.
-- class quests (hero-specific) start from index 100.

-- When you are doing a chain of quests, use sequential numbers.
-- For random/timed quests, use non-sequential numbers.

-- For an example, hunter has 3 quests with IDs 100, 101 and 110
-- Quests 100 and 101 are sequential, meaning 101 starts automatically after 100 is finished.
-- Quest 110 has a delayed start, and it's not in sequence.
-- This means that it starts automatically after the time has elapsed.

-- If you want a progress bar, have both "from" and "to" in your quest.
-- These are the start and end points for your progress bar.
-- It can go either way, depending how the numbers are.

-- For no progress bar, just don't have "from" and "to" in there.

quests_table = {
    all = {
        [1] = { -- Global quests start from 1
            name = "Tutorial for everyone!",
            title = "Survive! Get a stick, a tinder and a flint.",
            context = {
                type = "Time",
                track = function(hero, quest, obj)
                    local count = 0
                    if HasAnItem(hero, "item_stick") then count = count + 1 end
                    if HasAnItem(hero, "item_tinder") then count = count + 1 end
                    if HasAnItem(hero, "item_flint") then count = count + 1 end
                    Quests.UpdateQuest(obj, hero, count, quest.id)
                end,
                from = 0,
                to = 3
            }
        },
        [2] = {
            name = "Home Sweet Home",
            title = "Home Sweet Home: Craft a campfire. (Press C)",
            context = {
                type = "Time",
                track = function(hero, quest, obj)
                    if HasAnItem(hero, "item_building_kit_fire_basic") then
                        Quests.End(obj, hero, quest.id)
                    end
                end
            }
        },
        [3] = {
            name = "Home Sweet Home Pt 2.",
            title = "Home Sweet Home Pt. 2: Place your newly crafted camp fire",
            context = {
                type = "Time",
                from = 0,
                to = 60
            }
        },
        [5] = {
            name = "Fire placement",
            title = "Agree upon a base location.",
            context = {
                type = "Time",
                from = 0,
                delay_start = 5,
                to = 45
            }
        },
		[7] = {
            name = "Experience makes us wise!",
            title = "Pick up 5 items",
            context = {
                type = "Time",
				 track = function(hero, quest, obj)
                    local count = 0
                    if OnItemPickedUp then count = count + 1 end
                    Quests.UpdateQuest(obj, hero, count, quest.id)
                end,
                delay_start = 40,
                from = 0,
                to = 5
            }
        },
        [10] = {
            name = "Experience makes us wise!",
            title = "Reach level 2 before 5 minutes.",
            context = {
                type = "Time",
				 track = function(hero, quest, obj)
                    local count = 0
                    if hero:OnInventoryContentsChanged() then count = count + 1 end
                    Quests.UpdateQuest(obj, hero, count, quest.id)
                end,
                delay_start = 50,
                from = 0,
                to = 1
            }
        },
		[11] = {
            name = "Experience makes us wise!",
            title = "Reach level 3 before 7 minutes.",
            context = {
                type = "Time",
				 track = function(hero, quest, obj)
                    local count = 0
                    if  hero:GetLevel() == 3 then count = count + 1 end
                    Quests.UpdateQuest(obj, hero, count, quest.id)
                end,
                delay_start = 0,
                from = 0,
                to = 1
            }
        },
		[12] = {
            name = "Experience makes us wise!",
            title = "Reach level 4 before 8 minutes.",
            context = {
                type = "Time",
				 track = function(hero, quest, obj)
                    local count = 0
                    if  hero:GetLevel() == 4 then count = count + 1 end
                    Quests.UpdateQuest(obj, hero, count, quest.id)
                end,
                delay_start = 0,
                from = 0,
                to = 1
            }
        },
		[13] = {
            name = "Experience makes us wise!",
            title = "Reach level 5 before 10 minutes.",
            context = {
                type = "Time",
				 track = function(hero, quest, obj)
                    local count = 0
                    if  hero:GetLevel() == 5 then count = count + 1 end
                    Quests.UpdateQuest(obj, hero, count, quest.id)
                end,
                delay_start = 0,
                from = 0,
                to = 1
            }
        },
		[14] = {
            name = "Experience makes us wise!",
            title = "Reach level 6 before 11 minutes.",
            context = {
                type = "Time",
				 track = function(hero, quest, obj)
                    local count = 0
                    if  hero:GetLevel() == 6 then count = count + 1 end
                    Quests.UpdateQuest(obj, hero, count, quest.id)
                end,
                delay_start = 0,
                from = 0,
                to = 1
            }
        },
		[15] = {
            name = "Experience makes us wise!",
            title = "Choose your subclass!",
            context = {
                type = "Time",
				 track = function(hero, quest, obj)
                    local count = 0
                    if hero:HasSubClass()  == true  then
                        Quests.End(obj, hero, quest.id)
                    end
                end
            }
        }
    },
    beastmaster = { -- Class quests start from 100
        [100] = {
            name = "Test_Name",
            title = "Test_Title",
            context = {
                type = "Time",
                delay_start = 0, -- If set, set this to actual gametime seconds.
                from = 0,
                to = 10
            }
        }
    },
    gatherer = {

    },
    mage = {

    },
    priest = {

    },
    scout = {

    },
    thief = {

    },
    hunter = {

    }
}

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
    EmitSoundOnClient("Tutorial.Quest.complete_01", PlayerResource:GetPlayer(hero:GetPlayerID()))
    quest.quest:CompleteQuest()
    quest.quest.finished = true
    print("Quest #"..id.." has ended.")

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
    self.quests = quests_table
    self.first_all_id = 1
    self.first_class_id = 100
end

function Quests:CheckForTimed(hero, quest)
    if quest.context.type == "Time" then
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


    self:CheckForTimed(hero, actual_quest)
end
