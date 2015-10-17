-- Handles constant health degen, IE hunger, mana and heat degen
-- Also handles combining items in the inventory to craft buildings
-- Author: Kieran Carnegie, Till Elton, David Li
--
-- Code from: Amanite, and http://www.reddit.com/r/Dota2Modding/comments/2dc0xm/guide_to_change_gold_over_time_to_reliable_gold/

require("craftinghelper")
require("recipe_list")

HUNGER_LOSS_PER_UNIT = 1
TICKS_PER_HUNGER_UNIT = 6

ENERGY_LOSS_PER_UNIT = 1
TICKS_PER_ENERGY_UNIT = 6

HEAT_LOSS_PER_UNIT = 1
TICKS_PER_HEAT_UNIT = 6

allowed_item_combos_two     = {}
allowed_item_combos_three   = {}
hungerTicks = 0
energyTicks = 0
heatTicks = 0

allowed_item_combos_two["item_ward_observer"]  = {"item_clarity", "item_tango"}

-- This reduces each players health by 3, every 3 seconds
-- The return values ensure it closes when the game ends
-- Possibly need to detect only living heroes, will test that with more players
function Hunger(playerID)
    hungerTicks = hungerTicks + 1
    if hungerTicks % TICKS_PER_HUNGER_UNIT == 0 then
        local player = PlayerInstanceFromIndex(playerID)
        local hero = player:GetAssignedHero()
        if hero ~= nil then
            hero:ModifyHealth(hero:GetHealth()-HUNGER_LOSS_PER_UNIT, hero,true,-1*HUNGER_LOSS_PER_UNIT)
        end
    end
end

function Energy(playerID)
    energyTicks = energyTicks + 1
    if energyTicks % TICKS_PER_ENERGY_UNIT == 0 then
        local player = PlayerInstanceFromIndex(playerID)
        local hero = player:GetAssignedHero()
        if hero ~= nil then
            hero:ReduceMana(ENERGY_LOSS_PER_UNIT)
            if hero:GetMana() <= 0 then
                hero:ForceKill(true)
            end
        end
    end
end

function Heat(playerID)
    heatTicks = heatTicks + 1
    if heatTicks % TICKS_PER_HEAT_UNIT == 0 then
        local player = PlayerInstanceFromIndex(playerID)
        local hero = player:GetAssignedHero()
        if hero ~= nil then
            local heatStackCount = hero:GetModifierStackCount("modifier_heat_passive", nil) - HEAT_LOSS_PER_UNIT
            hero:SetModifierStackCount("modifier_heat_passive", nil, heatStackCount)
            if heatStackCount <= 0 then
                hero:ForceKill(true)
            end
        end
    end
end

function InventoryCheck(playerID)
    -- print("Inv testing player " .. playerID)
    -- Lets find the hero we want to work with
    local player = PlayerInstanceFromIndex(playerID)
    local hero =   player:GetAssignedHero()
    if hero == nil then
        --print("hero " .. playerID .. " doesn't exist!")
    else
        CraftItems(hero, TROLL_RECIPE_TABLE, ITEM_ALIAS_TABLE)
        --craftinghelper.lua explains how to format the tables
        --tables are contained in recipe_list.lua
    end
end