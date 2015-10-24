--[[
Troll Toolkit abilities & items:
    Sleep           ability_rest_troll
    Eat Raw Meat    ability_item_eat_meat_raw
    Pick Up Meat    item_meat_raw
    Drop Meat       item_meat_raw
    Drop All Meat   item_meat_raw
    Panic           ability_panic
]]


-- Player is put to sleep
function ITT:Sleep(cmdName)
    print("Sleep Command")
    local cmdPlayer = Convars:GetCommandClient()  -- returns the player who issued the console command
    if cmdPlayer then
        local nPlayerID = cmdPlayer:GetPlayerID()
        local hero = cmdPlayer:GetAssignedHero()
        if hero == nil then
            return
        end
        local abilityName = "ability_rest_troll"
        local ability = hero:FindAbilityByName(abilityName)
        if ability == nil then
            hero:AddAbility(abilityName)
            ability = hero:FindAbilityByName( abilityName )
            ability:SetLevel(1)
        end
        print("trying to cast ability ", abilityName)
        hero:CastAbilityNoTarget(ability, -1)
    end
end

-- Player eats one raw meat
function ITT:EatMeat(cmdName)
    print("EatMeat Command")
    local cmdPlayer = Convars:GetCommandClient()  -- returns the player who issued the console command
    if cmdPlayer then
        local nPlayerID = cmdPlayer:GetPlayerID()
        local hero = cmdPlayer:GetAssignedHero()

        if hero == nil then
            return
        end

        local meatStacks = hero:GetModifierStackCount("modifier_meat_passive", nil)
        if meatStacks > 0 then
            local abilityName = "ability_item_eat_meat_raw"
            local ability = hero:FindAbilityByName(abilityName)
            if ability == nil then
                hero:AddAbility(abilityName)
                ability = hero:FindAbilityByName( abilityName )
                ability:SetLevel(1)
            end
            print("trying to cast ability ", abilityName)
            hero:CastAbilityNoTarget(ability, -1)

            hero:SetModifierStackCount("modifier_meat_passive", nil, meatStacks-1)
        end
    end
end

-- This was missing, added a placeholder to at least remove crashes
function ITT:PickUpMeat(cmdName)
    print("Pick up meat button not implemented, this added to remove crashes")
end

-- Player drops one raw meat
function ITT:DropMeat(cmdName)
    print("DropMeat Command")
    local cmdPlayer = Convars:GetCommandClient()  -- returns the player who issued the console command
    if cmdPlayer then
        local nPlayerID = cmdPlayer:GetPlayerID()
        local hero = cmdPlayer:GetAssignedHero()
        if hero == nil then
            return
        end
        print("COMMAND FROM PLAYER: " .. nPlayerID)
        print("Drop one meat from hero " .. hero:GetName())

        local meatStacks = hero:GetModifierStackCount("modifier_meat_passive", nil)
        if meatStacks > 0 and hero ~= nil then
            local newItem = CreateItem("item_meat_raw", nil, nil)
            CreateItemOnPositionSync(hero:GetOrigin() + RandomVector(RandomInt(50,100)), newItem)

            hero:SetModifierStackCount("modifier_meat_passive", nil, meatStacks - 1)
        end
    end
end

-- Player drops all raw meat
function ITT:DropAllMeat(cmdName)
    print("DropAllMeat Command")
    local cmdPlayer = Convars:GetCommandClient()  -- returns the player who issued the console command
    if cmdPlayer then
        local nPlayerID = cmdPlayer:GetPlayerID()
        local hero = cmdPlayer:GetAssignedHero()
        if hero == nil then
            return
        end
        print("COMMAND FROM PLAYER: " .. nPlayerID)
        print("Drop all meat hero " .. hero:GetName())

        local meatStacks = hero:GetModifierStackCount("modifier_meat_passive", nil)
        if meatStacks > 0 and hero ~= nil then
            for i = 1,meatStacks do
                local newItem = CreateItem("item_meat_raw", nil, nil)
                CreateItemOnPositionSync(hero:GetOrigin() + RandomVector(RandomInt(50,100)), newItem)

                hero:SetModifierStackCount("modifier_meat_passive", nil, 0)
            end
        end
    end
end

-- Player panics!
function ITT:Panic(cmdName)
    print("Panic Command")
    local cmdPlayer = Convars:GetCommandClient()  -- returns the player who issued the console command
    if cmdPlayer then
        local nPlayerID = cmdPlayer:GetPlayerID()
        local hero = cmdPlayer:GetAssignedHero()
        if hero == nil then
            return
        end
        local abilityName = "ability_panic"
        local ability = hero:FindAbilityByName(abilityName)
        if ability == nil and hero ~= nil then
            hero:AddAbility(abilityName)
            ability = hero:FindAbilityByName( abilityName )
            ability:SetLevel(1)
        end
        print("trying to cast ability ", abilityName)
        hero:CastAbilityNoTarget(ability, -1)
    end
end