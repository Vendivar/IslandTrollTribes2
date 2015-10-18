--[[
	Notes:
    	Having a FindPets call in this file is not recommended, it should instead be a hero.pets list that gets updated whenever a pet gets acquired or killed
    	SetAbilityVisibility was moved to mechanics.lua 
]]

function TamePet(keys)
    local caster = keys.caster
    local target = keys.target
    local unitName = target:GetUnitName()
    local owner = caster:GetOwner()
    local maxPets = keys.MaxPets
    local growSpeed = keys.Growth
    local growAbility = "ability_beastmaster_pet_grow1"

    if growSpeed == "Fast" then
        growAbility = "ability_beastmaster_pet_grow1fast"
    end

    if (unitName == "npc_creep_fawn") or (unitName == "npc_creep_wolf_pup") or (unitName == "npc_creep_bear_cub") then
        if target:FindAbilityByName("ability_pet") == nil then
            target.vOwner = owner
            target:AddAbility("ability_pet")
            target:AddAbility(growAbility)
            target:FindAbilityByName("ability_pet"):SetLevel(1)
            target:FindAbilityByName(growAbility):SetLevel(1)
            SetAbilityVisibility(caster,"ability_beastmaster_pet_release", true)
            SetAbilityVisibility(caster,"ability_beastmaster_pet_follow", true)
            SetAbilityVisibility(caster,"ability_beastmaster_pet_stay", true)
        end
    end

    local pets = FindPets(keys)

    if (#pets) >= maxPets then
        print("Maximum amount of pets reached, removing tame pet skill!")
        SetAbilityVisibility(caster, "ability_beastmaster_tamepet", false)
        SetAbilityVisibility(caster, "ability_beastmaster_tamepet2", false)
    end
end

function FindPets(keys)
    local caster = keys.caster
    local owner = caster:GetOwner()
    if owner == nil then
        print("using different owner field")
        owner = caster.vOwner
    end
    local teamnumber = caster:GetTeamNumber()
    local pets = {}

    local units = FindUnitsInRadius(teamnumber,
                                    Vector(0,0,0),
                                    nil,
                                    FIND_UNITS_EVERYWHERE,
                                    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                                    DOTA_UNIT_TARGET_CREEP,
                                    DOTA_UNIT_TARGET_FLAG_NONE,
                                    FIND_ANY_ORDER,
                                    false)
    for _,unit in pairs(units) do
        if unit:HasAbility("ability_pet") and unit.vOwner == owner then
            print("Found a pet!")
            table.insert(pets,unit)
        end
    end

    if pets == {} then
        print("Failed to find pet")
    end

    return pets
end

function GrowPet(keys)
    local pet = keys.caster
    local name = pet:GetUnitName()
    local team = pet:GetTeam()
    local owner = pet.vOwner
    if owner then --only grow if the animal has an owner, wild animals never mature (we can change this, if necessary)
        local hero = owner:GetAssignedHero()
        local heroIsSub = hero:HasAbility("ability_beastmaster_tamepet2")
        local growAbility = "ability_beastmaster_pet_grow2"

        if heroIsSub then
            growAbility = "ability_beastmaster_pet_grow2fast"
        end

        local isBaby = false
        if pet:HasAbility("ability_beastmaster_pet_grow1") or pet:HasAbility("ability_beastmaster_pet_grow1fast") then
            isBaby = true
        end

        local GrowTable = {
                            {"npc_creep_fawn","npc_creep_elk_pet"},
                            {"npc_creep_wolf_pup","npc_creep_wolf_jungle"},
                            {"npc_creep_bear_cub","npc_creep_bear_jungle"},
                            {"npc_creep_elk_pet","npc_creep_elk_adult"},
                            {"npc_creep_wolf_jungle","npc_creep_wolf_jungle_adult"},
                            {"npc_creep_bear_jungle","npc_creep_bear_jungle_adult"}}


        print("Pet is growing into its next stage")

        for _,v in pairs(GrowTable) do
            if v[1] == name then
                local location = pet:GetAbsOrigin()
                pet:RemoveSelf()
                local newPet = CreateUnitByName(v[2],location, true,nil,nil,team)
                newPet.vOwner = owner
                newPet:AddAbility("ability_pet")
                newPet:AddAbility("ability_beastmaster_pet_sleep")
                newPet:FindAbilityByName("ability_beastmaster_pet_sleep"):SetLevel(1)
                if isBaby then
                    newPet:AddAbility(growAbility)
                    newPet:FindAbilityByName(growAbility):SetLevel(1)
                    SetAbilityVisibility(hero, "ability_beastmaster_pet_sleep", true)
                    SetAbilityVisibility(hero, "ability_beastmaster_pet_attack", true)
                end
                break
            end
        end
    end
end

function PetCommand(keys)
    local caster = keys.caster
    local command = keys.Command
    local petNumber = 1

    local pets = FindPets(keys)
    local pet = pets[petNumber]

    if pet ~= nil then
        print(command)
        if command == "release" then
            ReleasePet(caster,pet)
        elseif command == "follow" then
            pet:MoveToNPC(caster)
        elseif command == "stay" then
            pet:Stop()
        elseif command == "sleep" then
            sleep = pet:FindAbilityByName("ability_pet_sleep")
            if sleep ~= nil then
                sleep:SetLevel(1)
                sleep:CastAbility()
            end
        elseif command == "attack" then
            pet:MoveToPositionAggressive(caster:GetAbsOrigin())
        end
    end
end

function PetDeath(keys)
    local pet = keys.caster
    local owner = pet.vOwner
    local hero = owner:GetAssignedHero()

    SetAbilityVisibility(hero,"ability_beastmaster_tamepet", true)
    SetAbilityVisibility(hero,"ability_beastmaster_tamepet2", true)
    SetAbilityVisibility(hero,"ability_beastmaster_pet_release", false)
    SetAbilityVisibility(hero,"ability_beastmaster_pet_follow", false)
    SetAbilityVisibility(hero,"ability_beastmaster_pet_stay", false)
    SetAbilityVisibility(hero,"ability_beastmaster_pet_sleep", false)
    SetAbilityVisibility(hero,"ability_beastmaster_pet_attack", false)

    -- check if BM is within 600 range
    local distance = pet:GetRangeToUnit(hero)
    print(distance)

    if distance <= 600 then
        if hero:HasAbility("ability_beastmaster_empathicrage") then
            local item = CreateItem("item_empathicrage_modifier_applier", hero, hero)
            item:ApplyDataDrivenModifier(hero, hero, "modifier_empathicrage", {duration=10})
        end
    end
end

function ReleasePet(caster,pet)
    print("Releasing pet")
    pet:SetTeam(DOTA_TEAM_NEUTRALS)
    SetAbilityVisibility(caster,"ability_beastmaster_tamepet", true)
    SetAbilityVisibility(caster,"ability_beastmaster_tamepet2", true)
    SetAbilityVisibility(caster,"ability_beastmaster_pet_release", false)
    SetAbilityVisibility(caster,"ability_beastmaster_pet_follow", false)
    SetAbilityVisibility(caster,"ability_beastmaster_pet_stay", false)
    SetAbilityVisibility(caster,"ability_beastmaster_pet_sleep", false)
    SetAbilityVisibility(caster,"ability_beastmaster_pet_attack", false)
end

function HealPet(keys)
    local caster = keys.caster
    local maxHealth = caster:GetMaxHealth()
    local healAmount = maxHealth * 0.025

    caster:Heal(healAmount,nil)
end

function SetSpawnChance(keys)
    local caster = keys.caster
    local target = keys.target
    local level = caster:GetLevel()
    local bonus = 0
    local maxLevel = 4
    -- shitty way of determining whether the BM is pack leader form
    -- easier than copy pasting the massive spirit of the beast ability and only changing one function argument
    local heroIsSub = caster:HasAbility("ability_beastmaster_tamepet2")

    if heroIsSub then
        bonus = 5
        maxLevel = 9
    end

    if keys.Remove == "1" then
        level = 0
    end

    level = level + bonus
    if level > maxLevel then
        level = maxLevel
    end

    target:SetModifierStackCount("modifier_spawn_chance",nil,level)
end

function AttractAnimal(keys)
    local caster = keys.caster
    local target = keys.target
    local position = caster:GetAbsOrigin() + RandomVector(RandomInt(0,100))

    target:MoveToPositionAggressive(position)
end

function CallToBattle(keys)
    local caster = keys.caster
    local pets = FindPets(keys)
    local dur = keys.Duration

    for _,pet in pairs(pets) do
        local item = CreateItem("item_calltobattle_modifier_applier", caster, caster)
        item:ApplyDataDrivenModifier(caster, pet, "modifier_calltobattle", {duration=dur})
    end
end