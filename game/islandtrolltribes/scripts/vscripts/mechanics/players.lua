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

------------------------------------------------
--            Global item applier             --
------------------------------------------------

function ApplyModifier( unit, modifier_name )
    GameRules.APPLIER:ApplyDataDrivenModifier(unit, unit, modifier_name, {})
end