Chat = Chat or class({})

function Chat:constructor(players, teamColors)
    self.players = players
    self.teamColors = teamColors

    print("Chat initialized!");
    CustomGameEventManager:RegisterListener("custom_chat_say", function(id, ...) Dynamic_Wrap(self, "OnSay")(self, ...) end)
end

function Chat:OnSay(args)
    local id = args.PlayerID
    local message = args.message
    local isTeam = args.isTeamChat

    print("Player #"..id.." just said '"..message.."'")

    message = message:gsub("^%s*(.-)%s*$", "%1") -- Whitespace trim
    message = message:gsub("^(.{0,256})", "%1") -- Limit string length

    if message:len() == 0 then
        return
    end

    local nickname = ""
    if ITT.player_nicknames and ITT.player_nicknames[id] then
        nickname = ITT.player_nicknames[id]
    end

    if isTeam == 1 then
        CustomGameEventManager:Send_ServerToTeam(PlayerResource:GetTeam(id), "custom_chat_say", {
            color = self.teamColors[PlayerResource:GetTeam(id)],
            player = id,
            name = nickname,
            message = args.message,
            isTeam = true
        })
    else
        CustomGameEventManager:Send_ServerToAllClients("custom_chat_say", {
            color = self.teamColors[PlayerResource:GetTeam(id)],
            player = id,
            name = nickname,
            message = args.message,
            isTeam = false
        })
    end
end

function Chat:SystemMsg(msg)
    CustomGameEventManager:Send_ServerToAllClients("custom_chat_say", {
        color = {255, 120, 0},
        message = msg,
        isTeam = false
    })
end
