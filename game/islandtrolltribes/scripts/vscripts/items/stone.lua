function StoneStun(keys)
    local caster = keys.caster
    local target = keys.target
    local targetName = target:GetName()
    local dur = 7.0 --default duration for anything besides heros
    if (target:IsHero()) then --if the target's name includes "hero"
        dur = 1.0   --then we use the hero only duration
    end
    print("Stone Stunned!")
    target:AddNewModifier(caster, nil, "modifier_stunned", { duration = dur})
end