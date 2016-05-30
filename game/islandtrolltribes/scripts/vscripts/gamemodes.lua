function ITT:OnGameModeSelected(event)
    local settings = event
    if settings["game_mode"] == "FAST" then
        SetFastModeSettings()
    elseif settings["game_mode"] == "SLOW" then
        SetSlowModeSettings()
    elseif settings["game_mode"] == "NOOB" then
        SetNoobModeSettings()
    elseif settings["game_mode"] == "NORMAL" then
        SetNoobModeSettings()
    elseif settings["game_mode"] == "CUSTOM" then
        SetCustomSettings(settings.custom_settings)
    end
    ITT:LoadGameModeSettings()
end

function SetFastModeSettings()
    GameRules.GameModeSettings["HEAT_TICK_RATE"] = 0.1
    GameRules.GameModeSettings["GAME_ITEM_TICK_TIME"] = 20
    GameRules.GameModeSettings["GAME_CREATURE_TICK_TIME"] = 20
end

function SetSlowModeSettings()
    GameRules.GameModeSettings["HEAT_TICK_RATE"] = 1.5
    GameRules.GameModeSettings["GAME_ITEM_TICK_TIME"] = 70
    GameRules.GameModeSettings["GAME_CREATURE_TICK_TIME"] = 60
end

function SetNormalModeSettings()
    GameRules.GameModeSettings["HEAT_TICK_RATE"] = 1.0
    GameRules.GameModeSettings["GAME_ITEM_TICK_TIME"] = 50
    GameRules.GameModeSettings["GAME_ITEM_TICK_TIME"] = 40
end

function SetNoobModeSettings()
end

function SetCustomSettings(settings)
    GameRules.GameModeSettings = settings
end

function ITT:LoadGameModeSettings()
    Heat:loadSettings()
end