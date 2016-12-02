

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


function PainKillerBalmStart( keys )
    local target = keys.target
    local caster = keys.caster
    local stacks = 20
	print(target,caster,stacks)
	target:SetModifierStackCount("modifier_priest_painkillerbalm", nil, 20)
end

function PainKillerBalmThink( keys )
    local target = keys.target
    local caster = keys.caster
    local curstacks = target:GetModifierStackCount("modifier_priest_painkillerbalm", caster)
	print(target,caster,curstacks)
	target:SetModifierStackCount("modifier_priest_painkillerbalm", nil, curstacks -1)
end