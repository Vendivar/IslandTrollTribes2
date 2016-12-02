function PetRelease( event )
    local pet = event.caster
    local hero = pet:GetOwner()

    pet:Stop()
    pet:SetTeam(DOTA_TEAM_NEUTRALS)
    pet:RemoveAbility("ability_pet")
    pet:RemoveModifierByName("modifier_pet")
    pet:RemoveModifierByName("modifier_grow")
    pet:RemoveModifierByName("modifier_pet_grow")
    pet:RemoveAbility("ability_pet_release")
    pet:RemoveAbility("ability_pet_empathicrage")
    pet:RemoveAbility("ability_pet_sleep")
    pet:RemoveAbility("ability_pet_stay")
    pet:RemoveAbility("ability_pet_follow")
    pet:RemoveAbility("ability_pet_attack")
    pet:EmitSound("Hero_Beastmaster.Call.Boar")
    pet:EmitSound("Hero_Beastmaster.Call.Hawk")
    pet:SetControllableByPlayer(-1, false)
    -- pet:ForceKill(true) ...What?

    -- Go back to being a not-attackable animal
    if IsValidPetName( pet ) then
        TeachAbility(pet, "ability_baby_animal")
    end

    AdjustAbilityLayout(pet)

    -- Disable abilities on BM only if it doesnt have another pet active
    RemovePetFromTable(hero, pet)
    CheckBeastmasterPetCount(hero)

end

------------------------------------------------------------

function PetFollow(event)
    local hero = event.caster
    local ability = event.ability
    local pets = GetPets(hero)

    ToggleOffSet(hero, ability)

    for _,pet in pairs(pets) do
        pet:RemoveModifierByName("modifier_stay")
        ExecuteOrderFromTable({ UnitIndex = pet:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET, TargetIndex = hero:GetEntityIndex(), Queue = false})

        -- ID from beastmaster quest table.
        local quest_id = 106
        if not Quests:IsFinished(hero, quest_id) then
            if hero.quests[quest_id] then
                Quests:End(hero, quest_id)
            end
        end
    end
end

function PetStop(event)
    local hero = event.caster
    local ability = event.ability
    local pets = GetPets(hero)

    for _,pet in pairs(pets) do
        pet:RemoveModifierByName("modifier_stay")
        ExecuteOrderFromTable({ UnitIndex = pet:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_STOP, Queue = false})
    end
end

function PetStay(event)
    local hero = event.caster
    local ability = event.ability
    local pets = GetPets(hero)

    ToggleOffSet(hero, ability)

    for _,pet in pairs(pets) do
        ExecuteOrderFromTable({ UnitIndex = pet:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_HOLD_POSITION, Queue = false})

        ability:ApplyDataDrivenModifier(hero, pet, "modifier_command_restrict", {})
        ability:ApplyDataDrivenModifier(hero, pet, "modifier_stay", {})

        -- ID from beastmaster quest table.
        local quest_id = 107
        if not Quests:IsFinished(hero, quest_id) then
            if hero.quests[quest_id] then
                Quests:End(hero, quest_id)
            end
        end
    end
end

-- Only valid for non baby pets
function PetAttack(event)
    local hero = event.caster
    local ability = event.ability
    local pets = GetPets(hero)

    ToggleOffSet(hero, ability)

    for _,pet in pairs(pets) do
        if pet:HasAttackCapability() then
            pet:RemoveModifierByName("modifier_stay")
            ExecuteOrderFromTable({ UnitIndex = pet:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE, Position = hero:GetAbsOrigin() + RandomVector(100), Queue = false})

            -- ID from beastmaster quest table.
            local quest_id = 109
            if not Quests:IsFinished(hero, quest_id) then
                if hero.quests[quest_id] then
                    Quests:End(hero, quest_id)
                end
            end
        end
    end
end

-- Toggle the other abilities
function ToggleOffSet(hero, ability)
    local stay = hero:FindAbilityByName("ability_beastmaster_pet_stay")
    local follow = hero:FindAbilityByName("ability_beastmaster_pet_follow")
    local attack = hero:FindAbilityByName("ability_beastmaster_pet_attack")

    if stay and ability ~= stay then
        ToggleOff(stay)
    end

    if follow and ability ~= follow then
        ToggleOff(follow)
    end

    if attack and ability ~= attack then
        ToggleOff(attack)
    end
end

function PetRunToOwner(event)
    local pet = event.caster
    local hero = pet:GetOwner()
    ExecuteOrderFromTable({ UnitIndex = pet:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET, TargetIndex = hero:GetEntityIndex(), Queue = false})
end

function PetCommandRestrict(event)
    local pet = event.caster
    pet:SetControllableByPlayer(-1, false)
end

function PetCommandUnRestrict(event)
    local pet = event.caster
    pet:SetControllableByPlayer(pet:GetOwner():GetPlayerID(), false)
end

------------------------------------------------------------

function PetThink( event )
    local pet = event.caster
    local hero = pet:GetOwner()

    -- local pID = hero:GetPlayerID()

    if pet:FindModifierByName("modifier_stay") or pet:FindModifierByName("modifier_sleep") then
        return
    end

    if pet:FindModifierByName("modifier_command_restrict") then
        if pet:GetRangeToUnit(hero) < pet.leashRange then
            pet:RemoveModifierByName("modifier_command_restrict")
        else
            ExecuteOrderFromTable({ UnitIndex = pet:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET, TargetIndex = hero:GetEntityIndex(), Queue = false})
            return
        end
    end

    -- Never go outside the leashRange of the player, defined when the tame ability is cast
    -- Now checks if the pet is sleeping, in which case the pet still stays. Issue #241
    if pet:GetRangeToUnit(hero) > pet.leashRange and hero:IsAlive() then

        ExecuteOrderFromTable({ UnitIndex = pet:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET, TargetIndex = hero:GetEntityIndex(), Queue = false})

        local ability = pet:FindAbilityByName("ability_pet")
        ability:ApplyDataDrivenModifier(pet, pet, "modifier_command_restrict", {})

        -- EmitSoundOn( "General.Ping", pet )
        local particle = ParticleManager:CreateParticle("particles/custom/alert.vpcf", PATTACH_ABSORIGIN_FOLLOW, pet)
        --  SendErrorMessage(pID, "#error_pet_leash_range")
        return
    end

    -- Execute an attack move order if the pet attack stance is active
    if pet:HasAttackCapability() then
        local attack = hero:FindAbilityByName("ability_beastmaster_pet_attack")
        if attack and attack:GetToggleState() == true then
            ExecuteOrderFromTable({ UnitIndex = pet:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE, Position = hero:GetAbsOrigin() + RandomVector(200), Queue = false})
        end
    end
end

------------------------------------------------------------

function HealPet(keys)
    local caster = keys.caster
    local maxHealth = caster:GetMaxHealth()
    local healAmount = maxHealth * 0.05

    caster:Heal(healAmount,nil)
end

------------------------------------------------------------

function IsValidPetName( unit )
    local unitName = unit:GetUnitName()
    return unitName == "npc_creep_fawn" or unitName == "npc_creep_wolf_pup" or unitName == "npc_creep_bear_cub"
end

function GetPets( hero )
    return hero.pets
end

function GetPetCount( hero )
    local pets = hero.pets
    return #pets
end

function PetFree( event )
    local pet = event.caster
    local hero = pet:GetOwner()

    RemovePetFromTable(hero, pet)
    CheckBeastmasterPetCount( hero )
end

function RemovePetFromTable( hero, pet )
    local pets = GetPets(hero)
    local unit_index = getIndexTable(pets, pet)
    if unit_index then
        print("Pet Removed from Table")
        table.remove(pets, unit_index)
    end
end

function CheckBeastmasterPetCount( hero )
    local petCount = GetPetCount(hero)
    if petCount == 0 then
        hero:RemoveAbility("ability_beastmaster_pet_sleep")
        hero:RemoveAbility("ability_beastmaster_pet_follow")
        hero:RemoveAbility("ability_beastmaster_pet_stay")
        hero:RemoveAbility("ability_beastmaster_pet_attack")

        AdjustAbilityLayout(hero)
    end
end
