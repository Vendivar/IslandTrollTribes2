-- Should be a 600 radius Aura on pets
function PetDeath(keys)
    local pet = keys.caster
    local owner = pet.vOwner
    local hero = owner:GetAssignedHero()

    if hero:HasAbility("ability_beastmaster_empathicrage") then
        local item = CreateItem("item_empathicrage_modifier_applier", hero, hero)
        item:ApplyDataDrivenModifier(hero, hero, "modifier_empathicrage", {duration=10})
    end
end