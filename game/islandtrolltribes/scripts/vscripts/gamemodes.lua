
local player_amount = 0
function ITT:OnGameModeSelected(event)
    if not ITT.Gamemodevoting then
        ITT.Gamemodevoting = {}
    end

    table.insert(ITT.Gamemodevoting, event.settings)

    if player_amount == 0 then
        for k,v in pairs(playerList) do player_amount = player_amount + 1 end
    end

    if #ITT.Gamemodevoting == player_amount then
        -- Count the votes and set the settings.

        local speed_votes = {0,0,0}
        local pick_votes = {0,0,0}
        local custom_noob_votes = 0
        local custom_fixedbush_votes = 0
        local custom_norevive_votes = 0
        local custom_noislandbosses_votes = 0

        for k,v in pairs(ITT.Gamemodevoting) do
            speed_votes[v.speed] = speed_votes[v.speed] + 1
            pick_votes[v.pick] = pick_votes[v.pick] + 1

            if v.custom_noob == 1 then custom_noob_votes = custom_noob_votes + 1 end
            if v.custom_fixedbush == 1 then custom_fixedbush_votes = custom_fixedbush_votes + 1 end
            if v.custom_norevive == 1 then custom_norevive_votes = custom_norevive_votes + 1 end
            if v.custom_noislandbosses == 1 then custom_noislandbosses_votes = custom_noislandbosses_votes + 1 end
        end

        local function getMax(tab)
            local val = 0
            local key

            for k,v in pairs(tab) do
                if v > val then
                    val, key = v, k
                end
            end
            return key
        end

        local speed_vals = {"FAST","NORMAL","SLOW"}
        local speed = speed_vals[getMax(speed_votes)] -- 1 = Fast, 2 = Normal, 3 = Slow

        local pick_vals = {"ALL_PICK","ALL_RANDOM","SAME_HERO"}
        local pick = pick_vals[getMax(pick_votes)] -- 1 = All pick, 2 = All random, 3 = Same hero

        local custom_noob = false
        local custom_fixedbush = false
        local custom_norevive = false
        local custom_noislandbosses = false

        -- Change this to change the threshold for a custom option to activate.
        -- Currently it's 100%
        local custom_threshold = 1.0

        if custom_noob_votes >= player_amount * custom_threshold then custom_noob = true end
        if custom_fixedbush_votes >= player_amount * custom_threshold then custom_fixedbush = true end
        if custom_norevive_votes >= player_amount * custom_threshold then custom_norevive = true end
        if custom_noislandbosses_votes >= player_amount * custom_threshold then custom_noislandbosses = true end

        local settings = {
            ["game_mode"] = speed,
            ["pick_mode"] = pick,
            ["custom_settings"] = {
                ["noob_mode"] = custom_noob,
                ["fixed_bush_spawning"] = custom_fixedbush,
                ["norevive"] = custom_norevive,
                ["noislandbosses"] = custom_noislandbosses
            }
        }

        print("Gamemode settings:")
        PrintTable(settings)

        SetMode(settings)

        CustomGameEventManager:Send_ServerToAllClients("vote_confirmed", {
            player = event.PlayerID,
            settings = event.settings,
            voting_ended = true,
            voted_settings = settings
        })
    else
        CustomGameEventManager:Send_ServerToAllClients("vote_confirmed", {
            player = event.PlayerID,
            settings = event.settings,
            voting_ended = false
        })
    end
end

function SetMode(settings)
    SetGamemodeSettings(settings["game_mode"])
    SetPickSettings(settings["pick_mode"])

    SetCustomSettings(settings.custom_settings)
    ITT:LoadGameModeSettings()
end

function SetPickSettings(pickmode)
    GameRules.GameModeSettings["pick_mode"] = pickmode
end

function SetGamemodeSettings(gamemode)
    if gamemode == "FAST" then
        SetFastModeSettings()
    elseif gamemode == "SLOW" then
        SetSlowModeSettings()
    elseif gamemode == "NORMAL" then
        SetNormalModeSettings()
    end
end

function SetFastModeSettings()
    GameRules.GameModeSettings["HEAT_MAX_HEAT"] = 50
    GameRules.GameModeSettings["HEAT_TICK_RATE"] = 0.1
    GameRules.GameModeSettings["GAME_ITEM_TICK_TIME"] = 20
    GameRules.GameModeSettings["GAME_CREATURE_TICK_TIME"] = 20
end

function SetSlowModeSettings()
    GameRules.GameModeSettings["HEAT_MAX_HEAT"] = 200
    GameRules.GameModeSettings["HEAT_TICK_RATE"] = 1.5
    GameRules.GameModeSettings["GAME_ITEM_TICK_TIME"] = 70
    GameRules.GameModeSettings["GAME_CREATURE_TICK_TIME"] = 60
end

function SetNormalModeSettings()
    GameRules.GameModeSettings["HEAT_MAX_HEAT"] = 100
    GameRules.GameModeSettings["HEAT_TICK_RATE"] = 1.0
    GameRules.GameModeSettings["GAME_ITEM_TICK_TIME"] = 50
    GameRules.GameModeSettings["GAME_CREATURE_TICK_TIME"] = 40
end

function SetCustomSettings(settings)
    GameRules.GameModeSettings["custom"] = settings

    if settings.noob_mode then
        GameRules.GameModeSettings["HEAT_TICK_RATE"] = 1.5
        GameRules.GameModeSettings["HEAT_MAX_HEAT"] = 200
        GameRules.GameModeSettings["HEAT_IMMUNITY"] = true
        GAME_PERIOD_GRACE = 10800
    end

    if settings.fixed_bush_spawning then
        -- TODO: Fixed bush spawning.
    end

    -- No revive setting is checked when someone dies.
    -- TODO: Spirit ward revive when norevive is on.

    if settings.noislandbosses then
        -- TODO: When implementing island bosses, implement this!
    end
end

function ITT:LoadGameModeSettings()
    GameRules:SetPreGameTime(GAME_PERIOD_GRACE)
    Heat:loadSettings()
end
