

function PainKillerInit(keys)
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


function PainKillerBalmStart( event )
    local target = event.target
    local stacks = event.stacks
    target:SetModifierStackCount("modifier_priest_painkillerbalm", target, stacks)
end

function PainKillerBalmThink( event )
    local target = event.target
    local stacks = target:GetModifierStackCount("modifier_priest_painkillerbalm", target)

    target:SetModifierStackCount("modifier_priest_painkillerbalm", target, stacks - 1)
end