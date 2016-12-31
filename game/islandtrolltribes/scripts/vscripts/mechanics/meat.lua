-- Utility functions for creating meat with decay time. Arguably would be best to place in another file

-- Get meat decay time, for now use constant, but later could be affected by buffs/class type
function GetMeatDecayTime(unitKilled, unitKiller)
    return 45
end

-- Function to contain logic that modifies food drop rate
function GetMeatStacksToDrop(baseDrop, unitKilled, unitKiller)
    return baseDrop
end

-- Creates some raw meat at the specified position and creates timers to make the meat decay.
-- position: location where to spawn the meat (vector)
-- stacks: number of meats to make
-- decayTimeInSec: # of seconds before meat dissapears
-- meatCreateTimestamp: Gametime timestamp of when the meat is created. This is used for create copies of meat with correct decay timers (picking up a meat with full meat means we need to copy)
function CreateRawMeatAtLoc(position, stacks, decayTimeInSec, meatCreateTimestamp)
    local points = GenerateNumPointsAround(stacks, position, 80)
    for i= 1, stacks, 1 do
        local newItem = CreateItem("item_meat_raw", nil, nil)
        local physicalItem =  CreateItemOnPositionSync(points[i], newItem)
        local decayTime = decayTimeInSec
        physicalItem.spawn_time = meatCreateTimestamp

        if (decayTime > 0) then
            Timers(decayTime, function()
                --TODO: add particle effect to dissapearing meat
                if (IsValidEntity(physicalItem)) then
                    UTIL_Remove(physicalItem:GetContainedItem())
                    UTIL_Remove(physicalItem)
                    --RemoveUnit(physicalItem)
                end
            end)
        end
    end
end
