--[[TODO
    * Tooltip adjustment to show the current heat loss
]]

if not Heat then
    _G.Heat = class({})
end

-- Initial Heat
function Heat:Start(hero)
    Heat.MAX = 100
    hero.HeatLoss = -1/3 --Per second
    ApplyModifier(hero, "modifier_heat_passive")
    Heat:Set(hero, Heat.MAX)
    Heat:Think(hero)
end

-- Modifies the hero current heat by amount
function Heat:Modify( hero, amount )
    local currentHeat = Heat:Get(hero)
    local newStacks = currentHeat + amount

    if newStacks > currentHeat then
        AddHeatingIndicator(hero)
    else
        RemoveHeatingIndicator(hero)
    end

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

        Heat:UpdateLoss(hero)
        Heat:Modify(hero, hero.HeatLoss)
     
        if Heat:Get( hero ) <= 20 then
		AddFreezingIndicator(hero)			
        EmitSoundOn( "Hero_Ancient_Apparition.IceBlastRelease.Tick", hero )
        else
            RemoveFreezingIndicator(hero)
        end
    
        if Heat:Get( hero ) <= 0 then
            RemoveHeatingIndicator(hero)
            RemoveFreezingIndicator(hero)
            hero:ForceKill(true)
        end

        return 1
    end)
end

-- Checks if the HeatLoss value needs updating
function Heat:UpdateLoss(hero)
    local currentHeatLoss = Heat:CalculateLoss(hero)
    if hero.HeatLoss ~= currentHeatLoss then
        --print("Heat Loss Changed, now its ",currentHeatLoss)
        hero.HeatLoss = currentHeatLoss
    end
end

-- Goes through items and modifiers determining the rate at which the hero should lose heat
function Heat:CalculateLoss(hero)
    local heatLoss = -1/3 --heat loss is 20 per minute
    if not GameRules:IsDaytime() then
        heatLoss = -1/2 --heat loss is 30 per minute
    end

    -- Boots +2 every 35 seconds
    if hero:HasModifier("modifier_boots_heat") then
        heatLoss = heatLoss + 2/35
    end

    -- Gloves +2 every 35 seconds
    if hero:HasModifier("modifier_gloves_heat") then
        heatLoss = heatLoss + 2/35
    end

    -- Coat +8 every 35 seconds (+0.2 per second)
    if hero:HasModifier("modifier_coat_heat") then
        heatLoss = heatLoss + 8/35
    end

    -- Fire +8 per second (modified by cold/heat mode to 5/15)
    if hero:HasModifier("modifier_fire_heat") then
        heatLoss = heatLoss + 8
    end

    -- Mage Fire +16 per second (modified by cold/heat mode to 10/30)
    if hero:HasModifier("modifier_mage_fire_heat") then
        heatLoss = heatLoss + 16
    end

    -- The Glow aura is +1 every 9 seconds
    if hero:HasModifier("modifier_glow_heat") then
        heatLoss = heatLoss + 1/9
    end

    --print("Heat Per Second: "..heatLoss)

    return heatLoss
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

function AddHeatingIndicator(hero)
    if not hero.heating_indicator then
        local player = PlayerResource:GetPlayer(hero:GetPlayerID())
        if player then
         --   hero.heating_indicator = ParticleManager:CreateParticleForPlayer("particles/custom/screen_indicator_fire.vpcf", PATTACH_EYES_FOLLOW, player, player)
         --  ParticleManager:SetParticleControl(hero.heating_indicator, 1, Vector(1,0,0))
        end
    end
end

function AddFreezingIndicator(hero)
    if not hero.freezing_indicator then
        EmitSoundOn( "Hero_Ancient_Apparition.IceBlastRelease.Tick", hero )

        local player = PlayerResource:GetPlayer(hero:GetPlayerID())
        if player then
            hero.freezing_indicator = ParticleManager:CreateParticleForPlayer("particles/custom/screen_freeze_indicator.vpcf", PATTACH_EYES_FOLLOW, player, player)
            ParticleManager:SetParticleControl(hero.freezing_indicator, 1, Vector(1,0,0))
            SendFreezeMessage(hero:GetPlayerID(), "#error_heat_low")
        end
    end
end

function RemoveHeatingIndicator(hero)
    if hero.heating_indicator then
        ParticleManager:DestroyParticle(hero.heating_indicator, false)
        hero.heating_indicator = nil
    end
end

function RemoveFreezingIndicator(hero)
    if hero.freezing_indicator then
        ParticleManager:DestroyParticle(hero.freezing_indicator, false)
        hero.freezing_indicator = nil
    end
end