
--[[Checks unit inventory for matching recipes. If there's a match, remove all items and add the corresponding potion
    Matches must have the exact number of each ingredient ]]
function MixHerbs(keys)
    local caster = keys.caster
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(caster:GetPlayerID()), "show_crafting_menu", {unitName=caster:GetUnitName(),caster=caster:GetEntityIndex()} )
end