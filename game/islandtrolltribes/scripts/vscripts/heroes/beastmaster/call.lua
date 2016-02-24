function CallToBattle(keys)
    local caster = keys.caster
    local pets = GetPets(caster)
    local dur = keys.Duration

    for _,pet in pairs(pets) do
        local item = CreateItem("item_calltobattle_modifier_applier", caster, caster)
        item:ApplyDataDrivenModifier(caster, pet, "modifier_calltobattle", {duration=dur})
    end
end

function GetPets( hero )
    return hero.pets
end