modifier_pet_grow = class({})

function modifier_pet_grow:IsDebuff()
    return false
end

function modifier_pet_grow:IsHidden()
    return false
end

function modifier_pet_grow:OnDestroy()
    if IsServer() then
        local modifier = self
        local ability = modifier:GetAbility()
        local pet = modifier:GetParent()
        local unitName = pet:GetUnitName()
        local teamNumber = pet:GetTeam()
        local hero = pet:GetOwner()

        if not pet:HasAbility("ability_pet") then
            return
        end

        local petsTable = GameRules.SpawnInfo['Pets']
        local growYoung = petsTable['Young'][unitName]
        local groundAdult = petsTable['Adult'][unitName]
        local newPetName = growYoung or groundAdult

        if newPetName and pet:IsAlive() then
            print("Pet is growing into its next stage: ",newPetName)

            -- Create the unit and add to the hero pets, updating the old one
            local position = pet:GetAbsOrigin()
            position.z = -420
            pet:AddNoDraw()

            local newPet = CreateUnitByName(newPetName, position, true, hero, hero, teamNumber)
            newPet:SetOwner(hero)
            newPet:SetControllableByPlayer(hero:GetPlayerID(), true)
            FindClearSpaceForUnit(newPet, position, true)

            -- Abilities on the Pet: Release, Sleep
            TeachAbility(newPet, "ability_pet")
            TeachAbility(newPet, "ability_pet_sleep")
            TeachAbility(newPet, "ability_pet_release")

            -- Update table with the new pet
            local pets = hero.pets
            table.insert(pets, newPet)

            -- Keep the leash range
            newPet.leashRange = pet.leashRange

            -- Kill and remove old pet from the table
            pet.no_corpse = true
            pet:SetAbsOrigin(position)
            pet:ForceKill(true)

            -- Second growth
            if growYoung then
                TeachAbility(hero, "ability_beastmaster_pet_attack")
                if hero:FindAbilityByName("ability_beastmaster_petcontroll"):GetToggleState() == false then
                    SetAbilityVisibility(hero,"ability_beastmaster_petcontroll",false)
                end
                AdjustAbilityLayout(hero)

                local bPackLeader = GetSubClass(hero) == "pack_leader" -- Pack leaders grow their pets faster
                local grow_duration = bPackLeader and 220 or 300
                print("Young -> Adult in "..grow_duration)

                newPet:AddNewModifier(hero, ability, "modifier_pet_grow", {duration=grow_duration})
            end
        end
    end
end