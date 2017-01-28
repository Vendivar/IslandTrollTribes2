-- Returns bool
function PlayerHasEnoughGold( player, gold_cost )
    local hero = player:GetAssignedHero()
    local pID = hero:GetPlayerID()
    local gold = hero:GetGold()

    if gold < gold_cost then
        SendErrorMessage(pID, "#error_not_enough_gold")
        return false
    else
        return true
    end
end

function RandomUnpickedPlayers()
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            local player = PlayerResource:GetPlayer(playerID)
            if player and not player:GetAssignedHero() then
                CustomGameEventManager:Send_ServerToPlayer(player, "player_force_pick", {})
            end
        end
    end
end