function StoneStun(keys)
    print("Stone Stunned!")
	local ability = keys
    local caster = keys.caster
    local target = keys.target
    local dur = 7.0 --default duration for anything besides heros
    if (target:IsHero()) then --if the target's name includes "hero"
        dur = 1.0   --then we use the hero only duration
    end
    target:AddNewModifier(caster, nil, "modifier_persistent_invisibility", {duration = dur})
end
