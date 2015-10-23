-- Base heat loss is -1 every 3 seconds (-0.3333 per second)
-- Coats give +8 every 35 seconds (+0.2286 per second)
-- Gloves/Boots give +2 every 35 seconds (+0.0571 per second)
-- Fire gives +8 per second (modified by cold/heat mode to 5/15)
-- Mage Fire gives +16 per second (modified by cold/heat mode to 10/30)

--[[TODO
    * Tooltip adjustment to show the current heat loss
    * Handling Items
    * Handling Fires
    * Handling Skills
]]

if not Heat then
    _G.Heat = class({})
end

-- Initial Heat
function Heat:Start(hero)
    Heat.MAX = 100
    hero.HeatLoss = (1/3) --Per second
    ApplyModifier(hero, "modifier_heat_passive")
    Heat:Set(hero, Heat.MAX)
    Heat:Think(hero)
end

-- Modifies the hero current heat by amount
function Heat:Modify( hero, amount )
    local currentHeat = Heat:Get(hero)
    local newStacks = currentHeat + amount

    -- Cap the max
    if newStacks > Heat.MAX then
        newStacks = Heat.MAX
    end

    Heat:Set(hero, newStacks)
end

-- Takes a float amount and sets stacks with math floor
function Heat:Set( hero, amount )
    hero.currentHeat = amount
    Heat:SetStacks( hero, math.floor(amount) )
end

-- Returns a float amount
function Heat:Get( hero, amount )
    return hero.currentHeat or 0
end

function Heat:SetStacks( hero, amount )
    hero:SetModifierStackCount("modifier_heat_passive", nil, amount)
end

function Heat:GetStacks( hero )
    return hero:GetModifierStackCount("modifier_heat_passive", nil) or 0
end

function Heat:Think( hero )
    hero.HeatThink = Timers:CreateTimer(1, function()
        
        -- Stop after dying, gets reapplied when respawning
        if not hero:IsAlive() then
            return
        end

        Heat:Modify(hero, -hero.HeatLoss)
     
        if Heat:Get( hero ) <= 0 then
            hero:ForceKill(true)
        end

        return 1
    end)
end

function Heat:Stop(hero)
    Timers:RemoveTimer(hero.HeatThink)
end

-- Datadriven RunScript call with a "Heat" key
-- Negative values are accepted
function AddHeat(keys)
    local caster = keys.caster
    local target = keys.target
    local heatToAdd = keys.Heat

    if not target then
        target = caster
    end

    Heat:Modify(target, heatToAdd)
end