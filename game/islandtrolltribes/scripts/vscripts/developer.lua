CHEAT_CODES = {
    ["subclass"] = function(...) ITT:ChangeSubclass(...) end,
    ["reset"] = function(...) ITT:ResetSubclass(...) end,
    ["workshop"] = function(...) ITT:TestWorkshop(...) end,
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