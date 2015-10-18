
function PainKillerBalmStart( event )
    local target = event.target
    local stacks = event.stacks

    target:SetModifierStackCount("ability_priest_painkillerbalm", target, stacks)
end

function PainKillerBalmThink( event )
    local target = event.target
    local stacks = target:GetModifierStackCount("ability_priest_painkillerbalm", target)

    target:SetModifierStackCount("ability_priest_painkillerbalm", target, stacks - 1)
end