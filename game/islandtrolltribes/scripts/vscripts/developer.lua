CHEAT_CODES = {
    ["subclass"] = function(...) ITT:ChangeSubclass(...) end,
    ["reset"] = function(...) ITT:ResetSubclass(...) end,
}

PLAYER_COMMANDS = {}

-- A player has typed something into the chat
function ITT:OnPlayerChat(keys)
    local text = keys.text
    local userID = keys.userid
    local playerID = self.vUserIds[userID]:GetPlayerID()

    -- Handle '-command'
    if StringStartsWith(text, "-") then
        text = string.sub(text, 2, string.len(text))
    end

    local input = split(text)
    local command = input[1]
    if CHEAT_CODES[command] and Convars:GetBool('developer') then
        --print('Command:',command, "Player:",playerID, "Parameters",input[2], input[3], input[4])
        CHEAT_CODES[command](playerID, input[2], input[3], input[4])
    
    elseif PLAYER_COMMANDS[command] then
        PLAYER_COMMANDS[command](playerID)
    end
end

function ITT:ChangeSubclass( playerID, subclassID )
    print("Player ",playerID,"changing subclass")

    -- Build an event call (same as the panorama event)
    local event = {}
    event.playerID = playerID
    event.subclassID = subclassID
    ITT:OnSubclassChange(event)
end