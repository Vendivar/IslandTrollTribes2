

function HerbalInit(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    if string.find(target:GetUnitName(), "npc_dota_hero_dazzle") then
        SendErrorMessage(caster:GetPlayerOwnerID(),"#invalid_priest_target")
        caster:Interrupt()
        ability:StartCooldown(1.0)
    else
    print("else")
    end
end