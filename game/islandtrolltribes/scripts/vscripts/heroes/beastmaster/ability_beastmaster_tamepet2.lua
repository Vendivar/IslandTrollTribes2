ability_beastmaster_tamepet2 = class({})

LinkLuaModifier( "modifier_pet_grow", "heroes/beastmaster/modifier_pet_grow.lua", LUA_MODIFIER_MOTION_NONE )

-- Pets stored on the caster.pets hero table
-- ability_beastmaster_tamepet2 can hold 2 pets, and replaces the basic tamepet
function ability_beastmaster_tamepet2:OnSpellStart()
    local ability = self
    local caster = ability:GetCaster()
    local newPet = ability:GetCursorTarget()
    newPet.leashRange = ability:GetSpecialValueFor("leash_range")

    if not caster.pets then
        caster.pets = {}
    else

        -- Release the oldest pet if the beasmaster has more than 1 pet active
        local pet1 = caster.pets[1]
        local pet2 = caster.pets[2]
        if pet1 and IsValidAlive(pet1) and pet2 and IsValidAlive(pet2) then
            pet1:SetTeam(DOTA_TEAM_NEUTRALS)
            pet1:RemoveAbility("ability_pet")
            pet1:RemoveModifierByName("modifier_pet") --This will remove it from the list of pets
            pet:RemoveModifierByName("modifier_grow")
            pet1:RemoveAbility("ability_pet_release")
            pet1:RemoveAbility("ability_pet_sleep")
            pet1:EmitSound("Hero_Beastmaster.Call.Boar")
            pet1:EmitSound("Hero_Beastmaster.Call.Hawk")
            pet1:SetControllableByPlayer(caster:GetPlayerID(), false)

            -- Go back to being a not-attackable animal
            if ability_beastmaster_tamepet2:IsValidPetName( pet1 ) then
                TeachAbility(pet1, "ability_baby_animal")
            end

            AdjustAbilityLayout(pet1)
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

    -- Abilities on BM: Follow, Stay
    TeachAbility(caster, "ability_beastmaster_pet_follow")
    TeachAbility(caster, "ability_beastmaster_pet_stay")

    -- Attack gets added on the first growth
    --TeachAbility(caster, "ability_beastmaster_pet_attack")

    AdjustAbilityLayout(caster)
    AdjustAbilityLayout(newPet)

    -- Add to the list of pets
    table.insert(caster.pets, newPet)
end

--------------------------------------------------------------------------------
 
function ability_beastmaster_tamepet2:CastFilterResultTarget( target )
    local ability = self
    local caster = ability:GetCaster()

    local casterTeam = caster:GetTeamNumber()
    local targetTeam = target:GetTeamNumber()
    local allied = casterTeam == targetTeam

    if not ability_beastmaster_tamepet2:IsValidPetName( target ) or allied then
        return UF_FAIL_CUSTOM
    end

    return UF_SUCCESS
end
  
function ability_beastmaster_tamepet2:GetCustomCastErrorTarget( target )
    local ability = self
    local caster = ability:GetCaster()

    local casterTeam = caster:GetTeamNumber()
    local targetTeam = target:GetTeamNumber()
    local allied = casterTeam == targetTeam

    if not ability_beastmaster_tamepet2:IsValidPetName( target ) or allied then
        return "#error_must_target_baby_animal"
    end
 
    return ""
end

ability_beastmaster_tamepet2.validUnitNames = { ["npc_creep_fawn"] = "", ["npc_creep_wolf_pup"] = "", ["npc_creep_bear_cub"] = "" }

function ability_beastmaster_tamepet2:IsValidPetName( target )
    return ability_beastmaster_tamepet2.validUnitNames[target:GetUnitName()]
end

--------------------------------------------------------------------------------