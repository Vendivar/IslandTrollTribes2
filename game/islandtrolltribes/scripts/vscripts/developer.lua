CHEAT_CODES = {
    ["subclass"] = function(...) ITT:ChangeSubclass(...) end, -- Forces a subclass pick
    ["reset"] = function(...) ITT:ResetSubclass(...) end, -- Resets subclass choice
    ["workshop"] = function(...) ITT:TestWorkshop(...) end, -- Makes a workshop with items to test
    ["refresh"] = function(...) ITT:Refresh(...) end, -- Refreshes heat hp and mana
    ["dev"] = function(...) ITT:Dev(...) end, -- Reveal map and stop degen
    ["camp"] = function(...) ITT:Camp(...) end, -- Makes a fire
    ["acorns"] = function(...) ITT:Acorns(...) end, -- Make an acorn field
    ["debug_creeps"] = function(...) ITT:DebugCreeps(..) end, -- Spawn All Creeps

}

PLAYER_COMMANDS = {}

-- A player has typed something into the chat
function ITT:OnPlayerChat(keys)
    local text = keys.text
    local userID = keys.userid
    local playerID = self.vUserIds[userID]:GetPlayerID()

    -- Handle '-command'
    if StringStartsWith(text, "-") then
        text = string.sub(text, 2, string.len(text))
    end

    local input = split(text)
    local command = input[1]
    if CHEAT_CODES[command] and Convars:GetBool('developer') then
        --print('Command:',command, "Player:",playerID, "Parameters",input[2], input[3], input[4])
        CHEAT_CODES[command](playerID, input[2], input[3], input[4])
    
    elseif PLAYER_COMMANDS[command] then
        PLAYER_COMMANDS[command](playerID)
    end
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

    local workshop = CreateUnitByName("npc_building_workshop", position, true, hero, hero, hero:GetTeamNumber())
    workshop:SetControllableByPlayer(playerID, true)
    workshop:SetOwner(hero)
    workshop:SetForwardVector(-hero:GetForwardVector())

    local testItems = { 
        ["item_ingot_iron"] = 3,
        ["item_flint"] = 6,
        ["item_river_root"] = 5,
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