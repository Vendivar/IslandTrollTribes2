function ITT:FilterExecuteOrder( filterTable )
    ITEM_TRANSFER_RANGE = 500

    local units = filterTable["units"]
    local order_type = filterTable["order_type"]
    local issuer = filterTable["issuer_player_id_const"]
    local abilityIndex = filterTable["entindex_ability"]
    local targetIndex = filterTable["entindex_target"]
    local x = tonumber(filterTable["position_x"])
    local y = tonumber(filterTable["position_y"])
    local z = tonumber(filterTable["position_z"])
    local point = Vector(x,y,z)
    local queue = (filterTable["queue"]==1 and true) or false

    -- Skip Prevents order loops
    local unitIndex = units["0"]
    local unit = EntIndexToHScript(unitIndex)
    if unit and unit.skip then
        unit.skip = false
        return true
    end

    -- Timers Reset
    unit.dropping = nil


    ------------------------------------------------
    --          Transfer Range Increase           --
    ------------------------------------------------
    if targetIndex and abilityIndex and order_type == DOTA_UNIT_ORDER_GIVE_ITEM then

        local target = EntIndexToHScript(targetIndex)
        local item = EntIndexToHScript(abilityIndex)

        -- If within range of the modified transfer range, and the target has free inventory slots, make the swap
        local rangeToTarget = unit:GetRangeToUnit(target)

        if not CanTakeMoreItems(target) then
            SendErrorMessage(issuer, "#error_inventory_full")
            return false
        end
        
        if rangeToTarget <= ITEM_TRANSFER_RANGE then
            TransferItem(unit, target, item)
            return false
        else
            -- If its a building targeting a hero, order the hero to move towards the building
            -- The building will transfer the item to the hero inventory as soon as it gets close
            -- Probably need to check ownership to not be able to order an enemy hero to do things
            local origin = unit:GetAbsOrigin()
            local target_origin = target:GetAbsOrigin()
            if IsCustomBuilding(unit) then
                local transfer_position = origin + (target_origin - origin):Normalized() * ITEM_TRANSFER_RANGE
                target.skip = true
                ExecuteOrderFromTable({ UnitIndex = targetIndex, OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = transfer_position, Queue = queue}) 
                                
                -- Transfer the item when the hero gets within the transfer range
                Timers:CreateTimer(function()
                    if IsValidAlive(unit) and IsValidAlive(target) and (unit:GetAbsOrigin() - target:GetAbsOrigin()):Length2D() <= ITEM_TRANSFER_RANGE+25 then
                        if CanTakeMoreItems(target) then
                            TransferItem(unit, target, item)
                        else
                            SendErrorMessage(issuer, "#error_inventory_full")
                        end
                        return
                    end
                    return 0.1
                end)

            -- For heroes to buildings, move them towards the building while cancelling the action timer if they execute another order
            elseif IsCustomBuilding(target) then
                local transfer_position = target_origin + (origin - target_origin):Normalized() * ITEM_TRANSFER_RANGE

                unit.skip = true
                ExecuteOrderFromTable({ UnitIndex = unitIndex, OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = transfer_position, Queue = queue}) 
                unit.dropping = true --Any order will override this, breaking the timer
                
                -- Check for drop distance
                Timers:CreateTimer(function()
                    if not unit.dropping then return
                    elseif IsValidAlive(unit) and IsValidAlive(target) and (unit:GetAbsOrigin() - target:GetAbsOrigin()):Length2D() <= ITEM_TRANSFER_RANGE+25 then
                        if CanTakeMoreItems(target) then
                            TransferItem(unit, target, item)
                        else
                            SendErrorMessage(issuer, "#error_inventory_full")
                        end
                        return
                    end
                    return 0.1
                end)

                return false
            end
        end

        return true
    end

    ------------------------------------------------
    --             Drop Range Increase            --
    ------------------------------------------------
    if order_type == DOTA_UNIT_ORDER_DROP_ITEM then
        local item = EntIndexToHScript(abilityIndex)
        local origin = unit:GetAbsOrigin()
        
        -- Drop the item if within the extended range
        if (origin - point):Length2D() <= ITEM_TRANSFER_RANGE then
            unit:DropItemAtPositionImmediate(item, point)
            unit:Stop()
        else
            -- For buildings, Best Effort drop
            if IsCustomBuilding(unit) then
                local drop_point = origin + (point - origin):Normalized() * ITEM_TRANSFER_RANGE
                unit:DropItemAtPositionImmediate(item, drop_point)
                unit:Stop()
            else
                -- Move towards the position and drop the item at the extended range
                local drop_position = point - (point - origin):Normalized() * ITEM_TRANSFER_RANGE
                DebugDrawCircle(drop_position, Vector(255,0,0), 100, 100, true, 10)
                unit.skip = true
                ExecuteOrderFromTable({ UnitIndex = unitIndex, OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = drop_position, Queue = queue}) 
                unit.dropping = true --Any order will override this, breaking the timer
                
                -- Check for drop distance
                Timers:CreateTimer(function()
                    if not unit.dropping then return
                    elseif IsValidAlive(unit) and unit.dropping and (unit:GetAbsOrigin() - point):Length2D() <= ITEM_TRANSFER_RANGE+25 then
                        unit:DropItemAtPositionImmediate(item, point)
                        unit.dropping = nil
                        return
                    end
                    return 0.1
                end)
            end


        end


        return false
    end

    ------------------------------------------------
    --       Building Pickup Range Increase       --
    ------------------------------------------------
    if order_type == DOTA_UNIT_ORDER_PICKUP_ITEM and IsCustomBuilding(unit) then

        local drop = EntIndexToHScript(targetIndex)
        local position = drop:GetAbsOrigin()
        local origin = unit:GetAbsOrigin()

        -- Drop the item if within the extended range
        if (origin - position):Length2D() <= ITEM_TRANSFER_RANGE+25 then
            drop:SetAbsOrigin(origin)
            unit:PickupDroppedItem(drop)            
        else
            SendErrorMessage(issuer, "#error_item_out_of_range")
        end

        return false
    end

    return true
end

function printOrderTable( filterTable )
    print(ORDERS[filterTable["order_type"]])
    for k, v in pairs( filterTable ) do
        print("Order: " .. k .. " " .. tostring(v) )
    end
    print("-----------------------------------------")
end


ORDERS = {
    [0] = "DOTA_UNIT_ORDER_NONE",
    [1] = "DOTA_UNIT_ORDER_MOVE_TO_POSITION",
    [2] = "DOTA_UNIT_ORDER_MOVE_TO_TARGET",
    [3] = "DOTA_UNIT_ORDER_ATTACK_MOVE",
    [4] = "DOTA_UNIT_ORDER_ATTACK_TARGET",
    [5] = "DOTA_UNIT_ORDER_CAST_POSITION",
    [6] = "DOTA_UNIT_ORDER_CAST_TARGET",
    [7] = "DOTA_UNIT_ORDER_CAST_TARGET_TREE",
    [8] = "DOTA_UNIT_ORDER_CAST_NO_TARGET",
    [9] = "DOTA_UNIT_ORDER_CAST_TOGGLE",
    [10] = "DOTA_UNIT_ORDER_HOLD_POSITION",
    [11] = "DOTA_UNIT_ORDER_TRAIN_ABILITY",
    [12] = "DOTA_UNIT_ORDER_DROP_ITEM",
    [13] = "DOTA_UNIT_ORDER_GIVE_ITEM",
    [14] = "DOTA_UNIT_ORDER_PICKUP_ITEM",
    [15] = "DOTA_UNIT_ORDER_PICKUP_RUNE",
    [16] = "DOTA_UNIT_ORDER_PURCHASE_ITEM",
    [17] = "DOTA_UNIT_ORDER_SELL_ITEM",
    [18] = "DOTA_UNIT_ORDER_DISASSEMBLE_ITEM",
    [19] = "DOTA_UNIT_ORDER_MOVE_ITEM",
    [20] = "DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO",
    [21] = "DOTA_UNIT_ORDER_STOP",
    [22] = "DOTA_UNIT_ORDER_TAUNT",
    [23] = "DOTA_UNIT_ORDER_BUYBACK",
    [24] = "DOTA_UNIT_ORDER_GLYPH",
    [25] = "DOTA_UNIT_ORDER_EJECT_ITEM_FROM_STASH",
    [26] = "DOTA_UNIT_ORDER_CAST_RUNE",
    [27] = "DOTA_UNIT_ORDER_PING_ABILITY",
    [28] = "DOTA_UNIT_ORDER_MOVE_TO_DIRECTION",
}