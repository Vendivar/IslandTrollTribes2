--[[TODO
    * Tooltip adjustment to show the current heat loss
]]

if not Heat then
    _G.Heat = class({})
end

-- Initial Heat
function Heat:Start(hero)
    Heat:loadSettings()
    hero.HeatLoss = -1/3 --Per second
    ApplyModifier(hero, "modifier_heat_passive")
    Heat:Set(hero, Heat.MAX)
    Heat:Think(hero)
end

function Heat:loadSettings()
    Heat.MAX = GameRules.GameModeSettings["HEAT_MAX_HEAT"]
    Heat.TICK_RATE = GameRules.GameModeSettings["HEAT_TICK_RATE"]
    Heat.IMMUNITY = GameRules.GameModeSettings["HEAT_IMMUNITY"]

    if not Heat.PLAYERS then
        Heat.PLAYERS = {}

        -- Sends Heat data to player scoreboards.
        Timers:CreateTimer(1, function()
            for teamNumber,players in pairs(Heat.PLAYERS) do
                CustomGameEventManager:Send_ServerToTeam(teamNumber, "scoreboard_heat_update", {
                    players = players
                })
            end
            return 1
        end)
    end
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

        if Heat:Get( hero ) <= 25 then
		AddFreezingIndicator(hero)
		RemoveFrozenIndicator(hero)
		else
		RemoveFreezingIndicator(hero)
        end
		
		
		if Heat:Get( hero ) >= 15 then
		hero:RemoveModifierByName("modifier_frozen")
        RemoveFrozenIndicator(hero)	
        end
		
        if Heat:Get( hero ) <= 0 and not Heat.IMMUNITY then
            local item = CreateItem("item_apply_modifiers", hero, hero)
			item:ApplyDataDrivenModifier(hero, hero, "modifier_frozen", {duration=60})
            RemoveHeatingIndicator(hero)
            RemoveFreezingIndicator(hero)	
			AddFrozenIndicator(hero)
			Heat:Set(hero,1)
			TeammmateFrozenMessage(hero)	
        end

        if not Heat.PLAYERS[hero:GetTeamNumber()] then
            Heat.PLAYERS[hero:GetTeamNumber()] = {}
        end
        Heat.PLAYERS[hero:GetTeamNumber()][hero:GetPlayerID()] = Heat:Get(hero)

        return Heat.TICK_RATE
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
	
	-- The Glow aura is +1 every 9 seconds
    if hero:HasModifier("modifier_warm_up") then
        heatLoss = heatLoss + 1/0.25
    end


  -- Stop heat loss when frozen
   if hero:HasModifier("modifier_frozen") and not hero:HasModifier("modifier_mage_fire_heat") and not hero:HasModifier("modifier_fire_heat") then
        heatLoss = 0
   end
   
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

function RemoveHeatingIndicator(hero)
    if hero.heating_indicator then
        ParticleManager:DestroyParticle(hero.heating_indicator, false)
        hero.heating_indicator = nil
    end
end

function AddFreezingIndicator(hero)
EmitSoundOn( "freezing", hero )
    if not hero.freezing_indicator then
        EmitSoundOn( "freezing", hero )
        local player = PlayerResource:GetPlayer(hero:GetPlayerID())
        if player then
            hero.freezing_indicator = ParticleManager:CreateParticleForPlayer("particles/custom/screen_freeze_indicator.vpcf", PATTACH_EYES_FOLLOW, player, player)
            ParticleManager:SetParticleControl(hero.freezing_indicator, 1, Vector(1,0,0))
            SendFreezeMessage(hero:GetPlayerID(), "#error_heat_low")
			print("Freezing Indicator Internal")
--		Timers:CreateTimer(0.5, function()
--		EmitSoundOn( "freezing", hero )
--		SendFreezeMessage(hero:GetPlayerID(), "#error_heat_low")
--      return 3.5
--    end
--  )
  
        end
    end
	    			print("Freezing Indicator external")

end

function RemoveFreezingIndicator(hero)
    if hero.freezing_indicator then
        ParticleManager:DestroyParticle(hero.freezing_indicator, false)
        hero.freezing_indicator = nil
    end
end



function AddFrozenIndicator(hero)
EmitSoundOn( "freezing", hero )
    if not hero.frozen_indicator then
        EmitSoundOn( "freezing", hero )
        local player = PlayerResource:GetPlayer(hero:GetPlayerID())
        if player then
            hero.frozen_indicator = ParticleManager:CreateParticleForPlayer("particles/custom/screen_freeze_indicator.vpcf", PATTACH_EYES_FOLLOW, player, player)
            ParticleManager:SetParticleControl(hero.frozen_indicator, 1, Vector(1,0,0))
            SendFrozenMessage(hero:GetPlayerID(), "#error_frozen")
			EmitSoundOnClient("Hero_Beastmaster.Call.Hawk", player)
			print("Frozen Indicator Internal")

--	  Timers:CreateTimer(0.5, function()
--	  EmitSoundOn( "freezing", hero )
--	  SendFrozenMessage(hero:GetPlayerID(), "#error_frozen")
--      return 3.5
--    end
--  )
        end
    end	
	
			print("Frozen Indicator External")

	
end


function RemoveFrozenIndicator(hero)
    if hero.frozen_indicator then
        ParticleManager:DestroyParticle(hero.frozen_indicator, false)
		Notifications:RemoveBottom(hero:GetPlayerID())
        hero.frozen_indicator = nil
    end
end

function TeammmateFrozenMessage(hero)
    local team = hero:GetTeamNumber()
    local playerID = hero:GetPlayerOwnerID()
    local playerName = PlayerResource:GetPlayerName(playerID)
    if playerName == "" then playerName = "Player "..playerID end
		Notifications:TopToTeam(team, {ability="winter_wyvern_cold_embrace", duration=10})
		Notifications:TopToTeam(team, {text=playerName, duration=10, style={color="red", ["margin-right"]="7px;"}, continue=true, class="NotificationMessage"})
		Notifications:TopToTeam(team, {text="#teammate_frozen", duration=10, style={color="red"}, continue=true, class="NotificationMessage"})
end