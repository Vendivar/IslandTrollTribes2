CHEAT_CODES = {
    ["subclass"] = function(...) ITT:ChangeSubclass(...) end, -- Forces a subclass pick
    ["reset"] = function(...) ITT:ResetSubclass(...) end, -- Resets subclass choice
    ["workshop"] = function(...) ITT:TestWorkshop(...) end, -- Makes a workshop with items to test
    ["refresh"] = function(...) ITT:Refresh(...) end, -- Refreshes heat hp and mana
    ["dev"] = function(...) ITT:Dev(...) end, -- Reveal map and stop degen, improves inventory
    ["camp"] = function(...) ITT:Camp(...) end, -- Makes a fire, a ton of meat and building kits
    ["acorns"] = function(...) ITT:Acorns(...) end, -- Make an acorn field
    ["spears"] = function(...) ITT:Spears(...) end, -- Make an spear field
    ["debug_creeps"] = function(...) ITT:DebugCreeps(...) end, -- Spawn All Creeps
    ["fish"] = function(...) ITT:DebugFish(...) end, -- Spawn a shoal of fish
    ["ingredients"] = function(...) ITT:CreateIngredients(...) end, -- Creates ingredients for an item
    ["pets"] = function(...) ITT:SpawnPets(...) end, -- Creates pets around the hero
    ["bush"] = function( ... ) ITT:TestBush(...) end,
    ["potions"] = function( ... ) ITT:TestPotions(...) end,
    ["scrolls"] = function( ... ) ITT:TestScroll(...) end,
    ["axes"] = function( ... ) ITT:TestAxe(...) end,
    ["coats"] = function( ... ) ITT:TestCoat(...) end,
    ["debug_shops"] = function(...) ITT:DebugShops() end,
    ["spawnstats"] = function( ... ) ITT:SpawnStats(...) end,
    ["gg_end"] = function( ... ) GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS) end,
    ["lvlup"] = function(...) ITT:LvlUp(...) end,
}

PLAYER_COMMANDS = {
    ["help"] = function( ... ) ITT:Help(...) end,
    ["zoom"] = function( ... ) ITT:Zoom(...) end,
    ["!nick"] = function( ... ) ITT:SetNickname(...) end
}

-- A player has typed something into the chat
function ITT:OnPlayerChat(keys)
    local text = keys.message
    --local userID = keys.userid
    --local playerID = self.vUserIds[userID] and self.vUserIds[userID]:GetPlayerID()
    --if not playerID then return end
    local playerID = keys.PlayerID

    -- Handle '-command'
    if StringStartsWith(text, "-") then
        text = string.sub(text, 2, string.len(text))
    end

    local input = split(text)
    local command = table.remove(input, 1)
    if CHEAT_CODES[command] and (IsInToolsMode() or IsCheatMode()) then
        --print('Command:',command, "Player:",playerID, "Parameters",input[2], input[3], input[4])
        CHEAT_CODES[command](playerID, unpack(input))

    elseif PLAYER_COMMANDS[command] then
        PLAYER_COMMANDS[command](playerID, unpack(input))
    end
end

function ITT:LvlUp(playerID, level)
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    for i=1,tonumber(level) do
        hero:HeroLevelUp(false)
    end
end

function ITT:SetNickname( playerID, ...)
    if not ITT.player_nicknames then
        ITT.player_nicknames = {}
    end

    local array = {...}
    local name = ""
    for k,v in pairs(array) do
        name = name..v
        if k < #array then name = name.." " end
    end

    ITT.player_nicknames[playerID] = name
    print("Player #"..playerID.." changed their nickname to "..name)

    playername = PlayerResource:GetPlayerName(playerID)
    self.Chat:SystemMsg(playername.." has just changed their nickname to "..name)
end

function ITT:Zoom( playerID, value )
    value = value or 1134
    print("Player "..playerID.." zooming to "..value)

    -- Build an event call (same as the panorama event)
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "zoom", {zoom_distance = value});
end

function ITT:ChangeSubclass( playerID, subclassID )
    print("Player ",playerID,"changing subclass")

    -- Build an event call (same as the panorama event)
    local event = {}
    event.PlayerID = playerID
    event.subclassID = subclassID
    ITT:OnSubclassChange(event)
end

-- Make a workshop on front and drop many items around it
function ITT:TestWorkshop( playerID )
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local origin = hero:GetAbsOrigin()
    local fv = hero:GetForwardVector()
    local position = origin + fv * 500

    local workshop = CreateUnitByName("npc_building_armory", position, true, hero, hero, hero:GetTeamNumber())
    workshop:SetControllableByPlayer(playerID, true)
    workshop:SetOwner(hero)
    workshop:SetForwardVector(-hero:GetForwardVector())

    local testItems = {
        ["item_ingot_iron"] = 3,
        ["item_flint"] = 6,
        ["item_ingot_steel"] = 10,
        ["item_stick"] = 5,
        ["item_bone"] = 5,
    }

    local pos = origin + fv * 200
    for itemName,num in pairs(testItems) do
        for i=1,num do
            local item = CreateItem(itemName, nil, nil)
            local drop = CreateItemOnPositionSync( position, item )
            local pos_launch = pos+RandomVector(100)
            item:LaunchLoot(false, 200, 0.75, pos_launch)
        end
    end
end

-- Hooks the -refresh to also reset Heat
function ITT:Refresh( playerID )
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)

    Heat:Set( hero, 100 )
    hero:SetHealth(hero:GetMaxHealth())
    hero:SetMana(hero:GetMaxMana())
    for i=0,15 do
        local ability = hero:GetAbilityByIndex(i)
        if ability and not ability:IsCooldownReady() then
            ability:EndCooldown()
        end
    end
end

function ITT:Dev( playerID )
    GameRules.DevMode = not GameRules.DevMode

    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    if GameRules.DevMode then
        Heat:Stop(hero)
        hero:RemoveModifierByName("modifier_hunger")
        GameRules:GetGameModeEntity():SetFogOfWarDisabled(true)
    else
        Heat:Start(hero)
        ApplyModifier(hero, "modifier_hunger")
        GameRules:GetGameModeEntity():SetFogOfWarDisabled(false)
    end

    for i=0,5 do
        local item = hero:GetItemInSlot(i)
        if item and item:GetAbilityName() == "item_slot_locked" then
            item:RemoveSelf()
        end
    end

    hero:SetGold(5000, true)
    hero:AddItem(CreateItem("item_boots_anabolic", nil, nil))
    hero:AddItem(CreateItem("item_armor_battle", nil, nil))
    hero:AddItem(CreateItem("item_gloves_battle", nil, nil))
    hero:AddItem(CreateItem("item_shield_battle", nil, nil))
end

function ITT:Camp( playerID )
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local origin = hero:GetAbsOrigin()

    -- Put a fire on front
    local fv = hero:GetForwardVector()
    local position = origin + fv * 200

    local fire = CreateUnitByName("npc_building_fire_basic", position, true, hero, hero, hero:GetTeamNumber())
    fire:SetControllableByPlayer(playerID, true)
    fire:SetOwner(hero)
    fire:SetForwardVector(-hero:GetForwardVector())
    fire:RemoveModifierByName("modifier_invulnerable")
    fire:SetAbsOrigin(position)

    local testItems = {
        ["item_meat_raw"] = 30,
        ["item_meat_cooked"] = 20,
        ["item_meat_smoked"] = 20,
    }

    for itemName,num in pairs(testItems) do
        for i=1,num do
            local item = CreateItem(itemName, nil, nil)
            local drop = CreateItemOnPositionSync( position, item )
            if itemName == "item_meat_raw" then
                drop:SetAbsOrigin(position+RandomVector(RandomInt(100,200)))
            else
                local pos_launch = position+RandomVector(RandomInt(100,200))
                item:LaunchLoot(false, 200, 0.75, pos_launch)
            end
        end
    end

    local buildingItems = {
        "item_building_kit_armory",
        "item_building_kit_spirit_ward",
        "item_building_kit_fire_basic",
        "item_building_kit_storage_chest",
        "item_building_kit_fire_mage",
        "item_building_kit_tannery",
        "item_building_kit_hatchery",
        "item_building_kit_teleport_beacon",
        "item_building_kit_hut_mud",
        "item_building_kit_tent",
        "item_building_kit_hut_troll",
        "item_building_kit_tower_omni",
        "item_building_kit_hut_witch_doctor",
        "item_building_kit_trap_ensnare",
        "item_building_kit_mixing_pot",
        "item_building_kit_workshop",
        "item_building_kit_smoke_house",
    }

    for k,itemKit in pairs(buildingItems) do
        local item = CreateItem(itemKit, nil, nil)
        local drop = CreateItemOnPositionSync( origin, item )
        local pos_launch = origin+RandomVector(RandomInt(100,200))
        item:LaunchLoot(false, 200, 0.75, pos_launch)
    end

end

function ITT:Acorns( playerID )
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local origin = hero:GetAbsOrigin()

    for i=1,50 do
        local pos_launch = origin + RandomVector(RandomInt(1,200))
        local item = CreateItem("item_acorn", nil, nil)
        local drop = CreateItemOnPositionSync( origin, item )
        item:LaunchLoot(false, 200, 0.75, pos_launch)
    end
end

function ITT:Spears( playerID )
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local origin = hero:GetAbsOrigin()

    local spear_types = { "basic", "iron", "dark", "steel", "poison", "poison_refined", "poison_ultra" }

    for i=1,50 do
        local pos_launch = origin + RandomVector(RandomInt(1,200))
        local item = CreateItem("item_spear_"..spear_types[RandomInt(1,#spear_types)], nil, nil)
        local drop = CreateItemOnPositionSync( origin, item )
        item:LaunchLoot(false, 200, 0.75, pos_launch)
    end
end

function ITT:SpawnCreeps( playerID )
    print("Debug: Spawn All Creeps")
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)

    local unitTable = {
        "npc_creep_fawn",
        "npc_creep_wolf_pup",
        "npc_creep_bear_cub",
        "npc_creep_mammoth_baby",
        "npc_creep_elk_pet",
        "npc_creep_elk_adult",
        "npc_creep_bear_jungle_adult",
        "npc_creep_drake_bone",
        "npc_creep_harpy_red",
        "npc_creep_bat_forest",
        "npc_creep_drake_nether",
        "npc_creep_fish",
        "npc_creep_fish_green",
        "npc_creep_elk_wild",
        "npc_creep_hawk",
        "npc_creep_wolf_jungle",
        "npc_creep_wolf_ice",
        "npc_creep_wolf_jungle_adult",
        "npc_creep_bear_jungle",
        "npc_creep_lizard",
        "npc_creep_panther",
        "npc_creep_panther_elder"
    }

    for key,npcName in pairs(unitTable) do
        local spawnLocationX = (key-1)%6
        spawnLocationY = math.floor((key-1)/6)
        spawnLocation = Vector(1,0,0)*spawnLocationX*200 + Vector(0,-1,0)*spawnLocationY*300 + Vector(1,0,0)*200
        local unit = CreateUnitByName(npcName, hero:GetAbsOrigin() + spawnLocation, true, nil, nil, hero:GetTeamNumber())
        if unit == nil then
            print(npcName)
        end
        unit.vOwner = hero
        unit:SetControllableByPlayer(hero:GetPlayerID(), true )
        unit:SetForwardVector(Vector(0,-1,0))
    end
end

function ITT:DebugFish()
    local fishNames = { "npc_creep_fish_green", "npc_creep_fish"}
    for i=1,100 do
        local fish = fishNames[RandomInt(1,2)]
        Spawns:Create( fish )
    end
end

function ITT:CreateIngredients( playerID, buildingName )
    local itemRecipes = GameRules.Crafting[buildingName]
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local origin = hero:GetAbsOrigin()

    for k,v in pairs(itemRecipes) do
        for itemName,n in pairs (v) do
            for i=1,n*3 do
                local pos_launch = origin + RandomVector(RandomInt(1,200))

                local item
                if string.match(itemName, "any_") then
                    item = CreateItem( GetRandomAliasFor(itemName), nil, nil )
                else
                    item = CreateItem(itemName, nil, nil)
                end

                if item then
                    local drop = CreateItemOnPositionSync( origin, item )
                    item:LaunchLoot(false, 200, 0.75, pos_launch)
                else
                    print("Fail, couldn't create item: "..itemName)
                end
            end
        end
    end
end

function ITT:SpawnPets(playerID)
    local animal_names = {"npc_creep_fawn", "npc_creep_wolf_pup", "npc_creep_bear_cub"}
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local origin = hero:GetAbsOrigin()
    local rotate_pos = origin + Vector(1,0,0) * 200
    local count = 4
    local angle = 360 / count
    for i=1,count do
        local position = RotatePosition(origin, QAngle(0, angle*i, 0), rotate_pos)
        CreateUnitByName(animal_names[RandomInt(1, #animal_names)], position, true, nil, nil, DOTA_TEAM_NEUTRALS)
    end
end

function ITT:TestBush( playerID )
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local position = hero:GetAbsOrigin() + hero:GetForwardVector() * 200

    CreateBushContainer("item_bush_mushroom", position)
end

function ITT:TestAxe( playerID )
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local origin = hero:GetAbsOrigin()

    -- Put a fire on front
    local fv = hero:GetForwardVector()
    local position = origin + fv * 200


    local testItems = {
        ["item_axe_battle "] = 1,
        ["item_axe_flint"] = 1,
        ["item_axe_iron"] = 1,
        ["item_axe_mage_masher"] = 1,
        ["item_axe_steel"] = 1,
        ["item_axe_stone"] = 1,
                        }

    for itemName,num in pairs(testItems) do
        for i=1,num do
            local item = CreateItem(itemName, nil, nil)
            local drop = CreateItemOnPositionSync( position, item )
            if itemName == "item_meat_raw" then
                drop:SetAbsOrigin(position+RandomVector(RandomInt(100,200)))
            else
                local pos_launch = position+RandomVector(RandomInt(100,200))
                item:LaunchLoot(false, 200, 0.75, pos_launch)
            end
        end
    end

end



function ITT:TestCoat( playerID )
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local origin = hero:GetAbsOrigin()

    -- Put a fire on front
    local fv = hero:GetForwardVector()
    local position = origin + fv * 200


    local testItems = {
        ["item_cloak_fire"] = 1,
        ["item_cloak_frost"] = 1,
        ["item_cloak_protection "] = 1,
        ["item_coat_bear"] = 1,
        ["item_coat_bone"] = 1,
        ["item_coat_camouflage"] = 1,
        ["item_coat_elk"] = 1,
        ["item_coat_iron"] = 1,
        ["item_coat_steel"] = 1,
        ["item_coat_wolf"] = 1,
        ["item_coat_wolf"] = 1,
                        }

    for itemName,num in pairs(testItems) do
        for i=1,num do
            local item = CreateItem(itemName, nil, nil)
            local drop = CreateItemOnPositionSync( position, item )
            if itemName == "item_meat_raw" then
                drop:SetAbsOrigin(position+RandomVector(RandomInt(100,200)))
            else
                local pos_launch = position+RandomVector(RandomInt(100,200))
                item:LaunchLoot(false, 200, 0.75, pos_launch)
            end
        end
    end

end

function ITT:TestScroll( playerID )
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local origin = hero:GetAbsOrigin()

    -- Put a fire on front
    local fv = hero:GetForwardVector()
    local position = origin + fv * 200


    local testItems = {
        ["item_scroll_cyclone"] = 1,
        ["item_scroll_entangling"] = 1,
        ["item_scroll_fireball"] = 1,
        ["item_scroll_living_dead"] = 1,
        ["item_scroll_stoneskin"] = 1,
        ["item_scroll_tsunami"] = 1,
                        }

    for itemName,num in pairs(testItems) do
        for i=1,num do
            local item = CreateItem(itemName, nil, nil)
            local drop = CreateItemOnPositionSync( position, item )
            if itemName == "item_meat_raw" then
                drop:SetAbsOrigin(position+RandomVector(RandomInt(100,200)))
            else
                local pos_launch = position+RandomVector(RandomInt(100,200))
                item:LaunchLoot(false, 200, 0.75, pos_launch)
            end
        end
    end

end

function ITT:TestPotions( playerID )
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local origin = hero:GetAbsOrigin()

    -- Put a fire on front
    local fv = hero:GetForwardVector()
    local position = origin + fv * 200


    local testItems = {
        ["item_potion_acid"] = 1,
        ["item_potion_anabolic"] = 1,
        ["item_potion_anti_magic"] = 1,
        ["item_potion_cure_all"] = 1,
        ["item_potion_disease"] = 1,
        ["item_potion_drunk"] = 1,
        ["item_potion_elemental"] = 1,
        ["item_potion_fervor"] = 1,
        ["item_potion_healingi"] = 1,
        ["item_potion_healingiii"] = 1,
        ["item_potion_healingiv"] = 1,
        ["item_potion_manai"] = 1,
        ["item_potion_manaiii"] = 1,
        ["item_potion_manaiv"] = 1,
        ["item_potion_nether"] = 1,
        ["item_potion_poison"] = 1,
        ["item_potion_poison_ultra"] = 1,
        ["item_potion_twin_island"] = 1,
    }

    for itemName,num in pairs(testItems) do
        for i=1,num do
            local item = CreateItem(itemName, nil, nil)
            local drop = CreateItemOnPositionSync( position, item )
            if itemName == "item_meat_raw" then
                drop:SetAbsOrigin(position+RandomVector(RandomInt(100,200)))
            else
                local pos_launch = position+RandomVector(RandomInt(100,200))
                item:LaunchLoot(false, 200, 0.75, pos_launch)
            end
        end
    end
end

function ITT:DebugShops(playerID)
    local shops = Entities:FindAllByClassname("trigger_shop")

    Timers:CreateTimer(1, function()
        for k,v in pairs(shops) do
            DebugDrawCircle(v:GetAbsOrigin(), Vector(255,0,0), 100, 250, true, 2)
        end
        return 1
    end)
end

function ITT:SpawnStats()
    local spawnerNames = GameRules.SpawnInfo['SpawnerNames']
    print("=========Spawning stats============")
    print("Game time : "..math.floor(GameRules:GetGameTime()))
    print("World region  : "..math.floor(GameRules:GetGameTime()))
    for unitName,_ in pairs(spawnerNames) do
        print("Unit counts on world ("..unitName..") : "..Spawns.neutralCount["World"][1][unitName])
        for i=1,4 do
            print("Unit counts on Island #"..i.." ("..unitName..") : "..Spawns.neutralCount["Island"][i][unitName])
        end
    end
    print("=========Spawning stats============")
end
