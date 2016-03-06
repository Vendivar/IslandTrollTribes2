function EnsnareUnit(keys)
    local caster = keys.caster
    local target = keys.target
    local targetName = target:GetName()
    local dur = 8.0 --default duration for anything besides heros
    if (string.find(targetName,"hero") ~= nil) then --if the target's name includes "hero"
        dur = 3.5   --then we use the hero only duration
    elseif string.find(target:GetUnitName(), "hawk") then --if the target's name includes "hawk"
        target:RemoveModifierByName("modifier_hawk_flight")
        target:RemoveAbility("ability_hawk_flight")
    end
    target:AddNewModifier(caster, nil, "modifier_meepo_earthbind", { duration = dur})
end