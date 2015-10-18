function Hypnosis(keys)
    local ability = keys.ability
    local caster  = keys.caster
    local target  = keys.target

    local heat = keys.heat_removed
    local mana = keys.mana_restored
    local hypnosis = keys.hypnosis

    local dur = keys.duration_creep
    if string.find(target:GetName(), "hero") then
        dur = keys.duration
        AddHeat(keys)
    end
    target:GiveMana(mana)

    ability:ApplyDataDrivenModifier(caster, target, hypnosis, {duration = dur})
end