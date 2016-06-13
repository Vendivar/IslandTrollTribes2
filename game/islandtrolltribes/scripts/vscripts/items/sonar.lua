function CompassUse(event)
    local caster = event.caster
    local team = caster:GetTeamNumber()
    local playerID = caster:GetPlayerOwnerID()
    local playerName = PlayerResource:GetPlayerName(playerID)
    if playerName == "" then playerName = "Player "..playerID end

    Notifications:BottomToTeam(team, {text=playerName, duration=6, style={["margin-right"]="7px;"}, class="NotificationMessage"})
    Notifications:BottomToTeam(team, {text="#compass_used", duration=6, continue=true, class="NotificationMessage"})
end