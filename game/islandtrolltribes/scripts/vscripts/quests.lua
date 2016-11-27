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

quests_table = {
    all = {
        ["1"] = { -- Global quests start from 1
            name = "Tutorial for everyone!",
            title = "Tutorials for all!",
            context = {
                type = "Time",
                from = 0,
                to = 20
            }
        }
    },
    beastmaster = { -- Class quests start from 100
        ["100"] = {
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
        -- We are initializing all the delayed quests.
        self:StartDelayed(hero, type)
    end

    -- A delayed quest!
    if quest.context.delay_start and quest.context.delay_start > 0 then
        Timers:CreateTimer({
            endTime = GameRules:GetGameTime() - quest.context.delay_start
            callback = function()
                self:StartQuest(hero, type, quest, id)
            end
        })
    else
        self:StartQuest(hero, type, quest, id)
    end
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
    quest.quest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, value)
    quest.subquest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, value)
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
    if not quest then return end

    local type = quest.type
    local next_quest = self.quests[type][id + 1]
    local in_questline = true
    if not next_quest then -- Specific?
        in_questline = false
    end

    -- Quest complete!
    EmitSoundOnClient("Tutorial.Quest.complete_01", PlayerResource:GetPlayer(hero:GetPlayerID()))
    quest.quest:CompleteQuest()
    quest.quest.finished = true

    if in_questline then
        -- If it's in our questline, start the next one.
        hero.current_quests[type] = id + 1

        -- Check if it's delayed
        if next_quest.context.delay_start and next_quest.context.delay_start > 0 and GameRules:GetGameTime() > next_quest.context.delay_start then
            Timers:CreateTimer({
                endTime = next_quest.context.delay_start - GameRules:GetGameTime(),
                callback = function()
                    self:StartQuest(hero, next_quest, id + 1)
                end
            })
        else
            self:StartQuest(hero, next_quest, id + 1)
        end
    end
end

--- ############### INTERNAL
--- ############### DO NOT USE THESE DIRECTLY

function Quests:constructor()
    self.quests = quests_table
    self.first_all_id = 1
    self.first_class_id = 100
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

function Quests:StartQuest(hero, type, quest, id) -- Abstracting here.
    if hero.quests[id] then -- Don't start it again!
        print("Quest has already started!")
        return
    end

    local actual_quest = SpawnEntityFromTableSynchronous("quest", {
      name = quest.name,
      title = quest.title
    })

    -- Quest starts from "from"
    -- Ends in "to"
    -- Progress is tracked in "current"

    quest.context.current = quest.context.from
    actual_quest.context = quest.context
    actual_quest.finished = false
    actual_quest.type = type

    local actual_subquest = SpawnEntityFromTableSynchronous("subquest_base", {
      show_progress_bar = true,
      progress_bar_hue_shift = -119
    })

    actual_quest:AddSubquest(actual_subquest)

    actual_quest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, quest.context.from)
    actual_subquest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, quest.context.from)

    -- Progress bar can go in either direction.
    if quest.from < quest.to then -- From left to right.
        actual_quest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, quest.context.to)
        actual_subquest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, quest.context.to)
    else -- From right to left.
        actual_quest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, quest.context.from)
        actual_subquest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, quest.context.from)
    end

    -- Track quests that have been started.
    hero.quests = {
        [id] = {
            quest = actual_quest,
            subquest = actual_subquest
        }
    }
end
