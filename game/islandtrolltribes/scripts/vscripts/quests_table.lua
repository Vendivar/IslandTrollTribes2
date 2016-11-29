GameRules.quests_table = {}

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

GameRules.quests_table.all = {
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
                 if hero:GetLevel() == 2 then
                     Quests.End(obj, hero, quest.id)
                 end
            end,
            delay_start = 50
        }
    },
	[11] = {
        name = "Experience makes us wise!",
        title = "Reach level 3 before 7 minutes.",
        context = {
            type = "Time",
			track = function(hero, quest, obj)
                if hero:GetLevel() == 3 then
                     Quests.End(obj, hero, quest.id)
                end
            end
        }
    },
	[12] = {
        name = "Experience makes us wise!",
        title = "Reach level 4 before 8 minutes.",
        context = {
            type = "Time",
			 track = function(hero, quest, obj)
                 if hero:GetLevel() == 4 then
                     Quests.End(obj, hero, quest.id)
                 end
            end
        }
    },
	[13] = {
        name = "Experience makes us wise!",
        title = "Reach level 5 before 10 minutes.",
        context = {
            type = "Time",
			 track = function(hero, quest, obj)
                if hero:GetLevel() == 5 then
                    Quests.End(obj, hero, quest.id)
                end
            end
        }
    },
	[14] = {
        name = "Experience makes us wise!",
        title = "Reach level 6 before 11 minutes.",
        context = {
            type = "Time",
			 track = function(hero, quest, obj)
                if hero:GetLevel() == 6 then
                    Quests.End(obj, hero, quest.id)
                end
            end
        }
    },
	[15] = {
        name = "Experience makes us wise!",
        title = "Choose your subclass!",
        context = {
            type = "Time",
			 track = function(hero, quest, obj)
                local count = 0
                if hero:HasSubClass() then
                    Quests.End(obj, hero, quest.id)
                end
            end
        }
    }
}

-- ############### BEASTMASTER

GameRules.quests_table.beastmaster = { -- Class quests start from 100
    [100] = {
        name = "Test_Name",
        title = "Test_Title",
        context = {
            type = "Time",
            from = 0,
            to = 10
        }
    }
}

-- ############### GATHERER

GameRules.quests_table.gatherer = {
    [100] = {
        name = "Test_Name",
        title = "Test_Title",
        context = {
            type = "Time",
            from = 0,
            to = 10
        }
    }
}

-- ############### MAGE

GameRules.quests_table.mage = {
    [100] = {
        name = "Test_Name",
        title = "Test_Title",
        context = {
            type = "Time",
            from = 0,
            to = 10
        }
    }
}

-- ############### PRIEST

GameRules.quests_table.priest = {
    [100] = {
        name = "Test_Name",
        title = "Test_Title",
        context = {
            type = "Time",
            from = 0,
            to = 10
        }
    }
}

-- ############### SCOUT

GameRules.quests_table.scout = {
    [100] = {
        name = "Test_Name",
        title = "Test_Title",
        context = {
            type = "Time",
            from = 0,
            to = 10
        }
    }
}

-- ############### THIEF

GameRules.quests_table.thief = {
    [100] = {
        name = "Test_Name",
        title = "Test_Title",
        context = {
            type = "Time",
            from = 0,
            to = 10
        }
    }
}

-- ############### HUNTER

GameRules.quests_table.hunter = {
    [100] = {
        name = "Test_Name",
        title = "Test_Title",
        context = {
            type = "Time",
            from = 0,
            to = 10
        }
    }
}
