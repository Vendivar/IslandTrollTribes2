
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