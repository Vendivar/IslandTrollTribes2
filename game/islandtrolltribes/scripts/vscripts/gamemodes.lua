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
    GameRules.GameModeSettings["HEAT"]["TICK_RATE"] = 0.1
end

function SetSlowModeSettings()
end

function SetNormalModeSettings()
end

function SetNoobModeSettings()
end

function SetCustomSettings(settings)
    GameRules.GameModeSettings = settings
end

function ITT:LoadGameModeSettings()
    Heat:loadSettings()
end