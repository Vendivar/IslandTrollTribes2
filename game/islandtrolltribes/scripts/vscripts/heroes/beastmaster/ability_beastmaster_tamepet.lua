ability_beastmaster_tamepet = class({})

LinkLuaModifier( "modifier_pet_grow", "heroes/beastmaster/modifier_pet_grow.lua", LUA_MODIFIER_MOTION_NONE )

-- Pets stored on the caster.pets hero table
-- ability_beastmaster_tamepet can only hold 1, while ability_beastmaster_tamepet2 can hold 2
function ability_beastmaster_tamepet:OnSpellStart()
    local ability = self
    local caster = ability:GetCaster()
    local newPet = ability:GetCursorTarget()
    newPet.leashRange = ability:GetSpecialValueFor("leash_range")

    if not caster.pets then
        caster.pets = {}
    else

        -- Release old pet if it exists, this ability can't hold more than one pet
        -- We do the entire lua code in case the other pet is stunned or can't cast the release spell for any reason
        local pet = caster.pets[1]
        if pet and IsValidAlive(pet) then
            pet:SetTeam(DOTA_TEAM_NEUTRALS)
            pet:RemoveAbility("ability_pet")
            pet:RemoveModifierByName("modifier_pet")
            pet:RemoveModifierByName("modifier_grow")
            pet:RemoveAbility("ability_pet_release")
            pet:RemoveAbility("ability_pet_empathicrage")
            pet:RemoveAbility("ability_pet_sleep")
            pet:EmitSound("Hero_Beastmaster.Call.Boar")
            pet:EmitSound("Hero_Beastmaster.Call.Hawk")
            -- pet:SetControllableByPlayer(caster:GetPlayerID(), false)
            -- The boolean here doesn't affect the actual setting.
            pet:SetOwner(nil)
            pet:SetControllableByPlayer(-1, false)

            -- Go back to being a not-attackable animal
            if ability_beastmaster_tamepet:IsValidPetName( pet ) then
                TeachAbility(pet, "ability_baby_animal")
            end

            caster.pets = {}
        end
    end

    newPet:EmitSound("Hero_Enchantress.EnchantCreep")

    -- Grow
    local grow_duration = ability:GetSpecialValueFor("grow_young")
    newPet:AddNewModifier(caster, ability, "modifier_pet_grow", {duration=grow_duration})

    -- Change ownership
    newPet:SetControllableByPlayer(caster:GetPlayerID(), true)
    newPet:SetOwner(caster)
    newPet:SetTeam(caster:GetTeamNumber())

    newPet:RemoveAbility("ability_baby_animal")
    newPet:RemoveModifierByName("modifier_baby_animal")

    -- Abilities on the Pet: Release, Sleep
    TeachAbility(newPet, "ability_pet")
    TeachAbility(newPet, "ability_pet_sleep")
    TeachAbility(newPet, "ability_pet_release")
    TeachAbility(newPet, "ability_pet_empathicrage")

    -- Abilities on BM: Follow, Stay
    TeachAbility(caster, "ability_beastmaster_pet_follow")
    TeachAbility(caster, "ability_beastmaster_pet_stay")
    SetAbilityVisibility(caster,"ability_beastmaster_pet_follow",false)
    SetAbilityVisibility(caster,"ability_beastmaster_pet_stay",false)

    local petControllAbility = caster:FindAbilityByName("ability_beastmaster_petcontroll")
    if petControllAbility:GetToggleState() == false then
        ToggleOn(petControllAbility)
    end
    -- Attack gets added on the first growth
    --TeachAbility(caster, "ability_beastmaster_pet_attack")


    -- Add to the list of pets
    table.insert(caster.pets, newPet)
end

--------------------------------------------------------------------------------

function ability_beastmaster_tamepet:CastFilterResultTarget( target )
    local ability = self
    local caster = ability:GetCaster()

    local casterTeam = caster:GetTeamNumber()
    local targetTeam = target:GetTeamNumber()
    local allied = casterTeam == targetTeam

    if not ability_beastmaster_tamepet:IsValidPetName( target ) or allied then
        return UF_FAIL_CUSTOM
    end

    return UF_SUCCESS
end

function ability_beastmaster_tamepet:GetCustomCastErrorTarget( target )
    local ability = self
    local caster = ability:GetCaster()

    local casterTeam = caster:GetTeamNumber()
    local targetTeam = target:GetTeamNumber()
    local allied = casterTeam == targetTeam

    if not ability_beastmaster_tamepet:IsValidPetName( target ) or allied then
        return "#error_must_target_baby_animal"
    end

    return ""
end

ability_beastmaster_tamepet.validUnitNames = { ["npc_creep_fawn"] = "", ["npc_creep_wolf_pup"] = "", ["npc_creep_bear_cub"] = "" }

function ability_beastmaster_tamepet:IsValidPetName( target )
    return ability_beastmaster_tamepet.validUnitNames[target:GetUnitName()]
end

--------------------------------------------------------------------------------
