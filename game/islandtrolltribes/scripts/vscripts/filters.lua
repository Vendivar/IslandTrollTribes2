------------------------------------------------------------------
-- Order Filter
------------------------------------------------------------------

ITEM_TRANSFER_RANGE = 350
DEFAULT_TRANSFER_RANGE = 250

function ITT:FilterExecuteOrder( filterTable )
    local units = filterTable["units"]
    local order_type = filterTable["order_type"]
    local issuer = filterTable["issuer_player_id_const"]
    local abilityIndex = filterTable["entindex_ability"]
    local targetIndex = filterTable["entindex_target"]
    local x = tonumber(filterTable["position_x"])
    local y = tonumber(filterTable["position_y"])
    local z = tonumber(filterTable["position_z"])
    local point = Vector(x,y,z)
    local queue = filterTable["queue"]==1
    local unitIndex = units["0"]
    local unit = EntIndexToHScript(unitIndex)

    local CONSUME_EVENT = false
    local CONTINUE_PROCESSING_EVENT = true

    -- Drop orders for units that we don't want to be shared
    if unit and unit:GetClassname() ~= "player" then
        local playerID = unit:GetPlayerOwnerID()
        if issuer ~= -1 and playerID ~= -1 and issuer ~= playerID then
		--if issuer ~= -1 and playerID ~= -1 and issuer ~= playerID and (GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_DISCONNECTED or GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_ABANDONED) then
            if IsCustomBuilding(unit) and PlayerResource:GetTeam(issuer) == PlayerResource:GetTeam(playerID) then
                print("Allowing order to happen.")
            elseif not unit:IsSharedWithTeammates() then
                print("Denied order because issuer is "..issuer.." owner is "..playerID.." and the unit is not shared with teammates")
                return CONSUME_EVENT
            end
        end

        -- Prevent moving to stash
        local hero = unit:IsRealHero() and unit or unit:GetOwner()
        if order_type == DOTA_UNIT_ORDER_MOVE_ITEM then
            Timers:CreateTimer(0.03, function()
                if hero:GetNumItemsInStash() >= 0 then
                    for i=6,11 do
                        local item = hero:GetItemInSlot(i)
                        if item then
                            hero:EjectItemFromStash(item)
                            if hero:GetNumItemsInInventory() <= 5 then
                                hero:AddItem(item)
                            else
                                item:GetContainer():SetAbsOrigin(hero:GetAbsOrigin())
                            end
                        end
                    end
                end
            end)
            return CONTINUE_PROCESSING_EVENT
        end
    end

    -- Skip Prevents order loops
    if unit and unit.skip then
        unit.skip = false
        return CONTINUE_PROCESSING_EVENT
    end

    -- Order Timers Reset
    if unit.orderTimer then
        Timers:RemoveTimer(unit.orderTimer)
        unit.orderTimer = nil
    end

	--Scan Disable
	if order_type == DOTA_UNIT_ORDER_RADAR or order_type == DOTA_UNIT_ORDER_GLYPH then SendErrorMessage(issuer, "#error_nicetry") return end
	
	
	
    ------------------------------------------------
    --    		      Rez Uncancel		  	      --
    ------------------------------------------------
	if  order_type == DOTA_UNIT_ORDER_ATTACK_TARGET or order_type == DOTA_UNIT_ORDER_ATTACK_MOVE or order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET or order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION or order_type == DOTA_UNIT_ORDER_HOLD_POSITION or order_type == DOTA_UNIT_ORDER_STOP then
		if unit:GetUnitName() == "npc_building_spirit_ward" and unit:IsChanneling() then
		SendErrorMessage(issuer, "#error_cant_cancel")
		return CONSUME_EVENT
		end
    end

    ------------------------------------------------
    --          Warm up teammate       --
    ------------------------------------------------
	
	    if targetIndex and (order_type == DOTA_UNIT_ORDER_ATTACK_TARGET or order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET) then
        local target = EntIndexToHScript(targetIndex)
		if target and target:IsPlayer() and target:HasModifier("modifier_frozen") then
				local hero = PlayerResource:GetSelectedHeroEntity(issuer)				
				local abilityName = "ability_warm_up"
				local ability = hero:FindAbilityByName(abilityName)
				if not ability then
					ability = TeachAbility(hero, abilityName, 1)
				end
				if ability:IsFullyCastable() then
					hero:SetCursorCastTarget(target)
					hero:CastAbilityOnTarget(target, ability, hero:GetPlayerOwnerID())
					 print(hero:GetName().."casting spell, "..ability:GetName()..", on "..target:GetName())
				end
            return CONSUME_EVENT
        end
    end

    ------------------------------------------------
    --          Hide Building Crafting UI         --
    ------------------------------------------------
    if issuer ~= -1 and (order_type == DOTA_UNIT_ORDER_ATTACK_TARGET or order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION or order_type == DOTA_UNIT_ORDER_ATTACK_MOVE) then
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(issuer), "building_crafting_hide", {} )
    end

    ------------------------------------------------
    --            Attacks vs Flying Units         --
    ------------------------------------------------
    if targetIndex and (order_type == DOTA_UNIT_ORDER_ATTACK_TARGET or
                        order_type == DOTA_UNIT_ORDER_ATTACK_MOVE) then
        local target = EntIndexToHScript(targetIndex)
        if target and target.HasFlyMovementCapability and IsFlyingUnit(target) then
			if order_type == DOTA_UNIT_ORDER_ATTACK_TARGET then
                SendErrorMessage(issuer, "#error_cant_attack_air")
            end
            return CONSUME_EVENT
        end
    end

    ------------------------------------------------
    --          Transfer Range Increase           --
    ------------------------------------------------
    if targetIndex and abilityIndex and order_type == DOTA_UNIT_ORDER_GIVE_ITEM then

        local target = EntIndexToHScript(targetIndex)
        local item = EntIndexToHScript(abilityIndex)

        -- If within range of the modified transfer range, and the target has free inventory slots, make the swap
        local rangeToTarget = unit:GetRangeToUnit(target)
        if not CanTakeItem(target) then
            SendErrorMessage(issuer, "#error_inventory_full")
            return CONSUME_EVENT
    end

        if rangeToTarget <= ITEM_TRANSFER_RANGE then
            TransferItem(unit, target, item)
            return CONSUME_EVENT
        else
            -- If its a building targeting a hero, order the hero to move towards the building
            -- The building will transfer the item to the hero inventory as soon as it gets close
            local origin = unit:GetAbsOrigin()
            local target_origin = target:GetAbsOrigin()
            if IsCustomBuilding(unit) then
                local transfer_position = origin + (target_origin - origin):Normalized() * ITEM_TRANSFER_RANGE
                target.skip = true
                ExecuteOrderFromTable({ UnitIndex = targetIndex, OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = transfer_position, Queue = queue})

                -- Transfer the item when the hero gets within the transfer range
                unit.orderTimer = Timers:CreateTimer(function()
                    if IsValidAlive(unit) and IsValidAlive(target) and (unit:GetAbsOrigin() - target:GetAbsOrigin()):Length2D() <= ITEM_TRANSFER_RANGE+25 then
                        local canTransfer = TransferItem(unit, target, item)
                        if not canTransfer then
                            SendErrorMessage(issuer, "#error_inventory_full")
                        end
                        return false
                    end
                    return 0.1
                end)

            -- For heroes to buildings, move them towards the building while cancelling the action timer if they execute another order
            elseif IsCustomBuilding(target) then
                local itemName = item:GetAbilityName()

                -- Traps can't pickup certain items
                if target:GetUnitName() == "npc_building_ensnare_trap" and itemName ~= "item_meat_raw" then
                    SendErrorMessage(issuer, "#error_traps_cant_pickup_that")
                    return false
                end

                if target:GetUnitName() == "npc_building_tower_omni" and (itemName:match("meat") or itemName:match("potion")) then
                    SendErrorMessage(issuer, "#error_traps_cant_pickup_that")
                    return false
                end

                local transfer_position = target_origin + (origin - target_origin):Normalized() * ITEM_TRANSFER_RANGE

                unit.skip = true
                ExecuteOrderFromTable({ UnitIndex = unitIndex, OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = transfer_position, Queue = queue})

                -- Check for drop distance
                unit.orderTimer = Timers:CreateTimer(function()
                    if IsValidAlive(unit) and IsValidAlive(target) and (unit:GetAbsOrigin() - target:GetAbsOrigin()):Length2D() <= ITEM_TRANSFER_RANGE+25 then
                        local canTransfer = TransferItem(unit, target, item)
                        if not canTransfer then
                            SendErrorMessage(issuer, "#error_inventory_full")
                        end
                        return false
                    end
                    return 0.1
                end)

                return CONSUME_EVENT

            -- Hero to Hero
            else
                unit.skip = true
                ExecuteOrderFromTable({ UnitIndex = unitIndex, OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET, TargetIndex = targetIndex, Queue = queue})

                -- Check for drop distance
                unit.orderTimer = Timers:CreateTimer(function()
                    if IsValidAlive(unit) and IsValidAlive(target) and (unit:GetAbsOrigin() - target:GetAbsOrigin()):Length2D() <= ITEM_TRANSFER_RANGE+25 then
                        local canTransfer = TransferItem(unit, target, item)
                        unit:Stop()
                        if canTransfer == false then
                            SendErrorMessage(issuer, "#error_inventory_full")
                        end
                        return
                    end
                    return 0.1
                end)

                return CONSUME_EVENT
            end
        end

        return CONTINUE_PROCESSING_EVENT
    end

    ------------------------------------------------
    --             Drop Range Increase            --
    ------------------------------------------------
    if order_type == DOTA_UNIT_ORDER_DROP_ITEM then
        local item = EntIndexToHScript(abilityIndex)
        local origin = unit:GetAbsOrigin()

        -- Drop the item if within the extended range
        local distance = (origin - point):Length2D()
        if distance <= ITEM_TRANSFER_RANGE then
            unit:DropItemAtPositionImmediate(item, origin)
            DropLaunch(unit, item, 0.35, point)
            unit:Stop()
        else
            -- For buildings, Best Effort drop
            if IsCustomBuilding(unit) then
                local itemDropRangeForBuildings = 800
                local drop_point = origin + (point - origin):Normalized() * ITEM_TRANSFER_RANGE
                local dropDistance = (origin - point):Length2D()
                if not (dropDistance >= itemDropRangeForBuildings) then
                    unit:DropItemAtPositionImmediate(item, origin)
                    DropLaunch(unit, item, 0.75, point)
                    unit:Stop()
                else
                    SendErrorMessage(issuer, "#Can't drop the item here")
                end
            else
                -- Move towards the position and drop the item at the extended range
                local drop_position = point - (point - origin):Normalized() * ITEM_TRANSFER_RANGE
                unit.skip = true
                ExecuteOrderFromTable({ UnitIndex = unitIndex, OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = drop_position, Queue = queue})

                -- Check for drop distance
                unit.orderTimer = Timers:CreateTimer(function()
                    if IsValidAlive(unit) and (unit:GetAbsOrigin() - point):Length2D() <= ITEM_TRANSFER_RANGE+25 then
                        unit:DropItemAtPositionImmediate(item, unit:GetAbsOrigin())
                        DropLaunch(unit, item, 0.35, point)
                        print("unit:DropItemAtPositionImmediate(item, point)")
                        return false
                    end
                    return 0.1
                end)
            end
        end

        return CONSUME_EVENT
    end

    ------------------------------------------------
    --             Pickup Range Increase          --
    ------------------------------------------------
    if order_type == DOTA_UNIT_ORDER_PICKUP_ITEM  then

        local drop = EntIndexToHScript(targetIndex)
        if not drop then
            print("INVALID DROP, index was",targetIndex,"ABORT")
            return false
        end

        -- Filter out containers
        if drop.container then
            return true
        end

        local position = drop:GetAbsOrigin()
        local origin = unit:GetAbsOrigin()

        -- Buildings
        if IsCustomBuilding(unit) then
            local itemName = drop:GetContainedItem():GetAbilityName()
            if (origin - position):Length2D() <= ITEM_TRANSFER_RANGE + 250 then

                if itemName == "item_meat_raw" then
                    if unit:GetUnitName() == "npc_building_ensnare_trap" or unit:GetUnitName() == "npc_building_smoke_house" then
                        if not PickupRawMeat(unit, drop) then
                            SendErrorMessage(issuer, "#error_inventory_full")
                        end
                        return false
                    else
                        SendErrorMessage(issuer, "#error_building_cant_pick_meat")
                        return false
                    end
                end

                if unit:GetUnitName() == "npc_building_ensnare_trap" and itemName ~= "item_meat_raw" then
                    SendErrorMessage(issuer, "#error_traps_cant_pickup_that")
                    return false
                end

                if unit:GetUnitName() == "npc_building_tower_omni" and (itemName:match("meat") or itemName:match("potion")) then
                    SendErrorMessage(issuer, "#error_traps_cant_pickup_that")
                    return false
                end

                local pickedUp = PickupItem(unit, drop)
                if not pickedUp then
                 --   SendErrorMessage(issuer, "#error_inventory_full")
                end
            else
                SendErrorMessage(issuer, "#error_item_out_of_range")
            end

        -- Units
        else
            -- Move towards the drop position and pickup the item
            unit.skip = true
            ExecuteOrderFromTable({ UnitIndex = unitIndex, OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = position, Queue = queue})

            -- Check for drop distance
            unit.orderTimer = Timers:CreateTimer(function()
                if IsValidAlive(unit) and (unit:GetAbsOrigin() - position):Length2D() <= DEFAULT_TRANSFER_RANGE then
                    unit:Stop()
                    local pickedUp = PickupItem( unit, drop )
                    if not pickedUp then
                        SendErrorMessage(issuer, "#error_inventory_full")
                    end
                    return false
                end
                return 0.1
            end)
        end

        return CONSUME_EVENT
    end

    ------------------------------------------------
    --       Teleport Beacon Range Handling       --
    ------------------------------------------------
    if order_type == DOTA_UNIT_ORDER_CAST_TARGET then
        if unit:GetUnitName() == "npc_building_teleport_beacon" then
            local targetEntity = EntIndexToHScript(targetIndex)
            -- Since the spell targetting is handled in KV, don't have to do any checks here... ?
            local ability_being_cast = EntIndexToHScript(abilityIndex)
            if ability_being_cast:GetAbilityName() == "ability_teleport" then
                if (unit:GetOrigin() - targetEntity:GetOrigin()):Length2D() > ability_being_cast:GetCastRange() then
                    -- Out of range, we can't continue or the spell will be "queued" and cast when the unit is in range
                    return false
                end
            end
        end
    end

    ------------------------------------------------
    --       Redirect Building Orders to Hero     --
    ------------------------------------------------
    if IsCustomBuilding(unit) then
        -- When a move/attack order issued by a building, the order should be passed to the hero and the hero should be auto selected.
        local bMoveOrder = order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION or DOTA_UNIT_ORDER_MOVE_TO_TARGET

        local hero = PlayerResource:GetSelectedHeroEntity(issuer)
        if hero and bMoveOrder then
            hero.skip = true

            -- Move to a position or towards a target
            if order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION then
                ExecuteOrderFromTable({UnitIndex = hero:GetEntityIndex(), OrderType = order_type, Position = point, Queue = false})

            else

                -- If the target is an enemy, send an attack order instead
                local target = EntIndexToHScript(targetIndex)
                if order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET and target:GetTeamNumber() ~= hero:GetTeamNumber() then
                    order_type = DOTA_UNIT_ORDER_ATTACK_TARGET
                end

                ExecuteOrderFromTable({UnitIndex = hero:GetEntityIndex(), OrderType = order_type, TargetIndex = targetIndex, Queue = false})
            end

            PlayerResource:NewSelection(issuer, hero)
        end
    end

    return CONTINUE_PROCESSING_EVENT
end

function IsTargetOrder( ... )
    return
end

function IsPositionOrder(order_type)
    return order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION or order_type == DOTA_UNIT_ORDER_ATTACK_MOVE
end

-- Orders casting a rest ability on the playerID hero
function ITT:RestBuilding( event )
    local playerID = event.PlayerID
    local building = EntIndexToHScript(event.entityIndex)
    local unit = PlayerResource:GetSelectedHeroEntity(playerID)

    -- Find any rest_ ability
    local restAbility
    for i=0,15 do
        local ability = building:GetAbilityByIndex(i)
        if ability and string.match(ability:GetAbilityName(), "rest_") then
            restAbility = ability
            break
        end
    end

    if restAbility then
        building:CastAbilityOnTarget(unit, restAbility, -1)
    end
end

function printOrderTable( filterTable )
    print(ORDERS[filterTable["order_type"]])
    for k, v in pairs( filterTable ) do
        print("Order: " .. k .. " " .. tostring(v) )
    end
    print("-----------------------------------------")
end

------------------------------------------------------------------
-- Damage Filter
------------------------------------------------------------------

function ITT:FilterDamage( filterTable )
    --for k, v in pairs( filterTable ) do
    --  print("Damage: " .. k .. " " .. tostring(v) )
    --end
    local victim_index = filterTable["entindex_victim_const"]
    local attacker_index = filterTable["entindex_attacker_const"]
    if not victim_index or not attacker_index then
        return true
    end

    local victim = EntIndexToHScript( victim_index )
    local attacker = EntIndexToHScript( attacker_index )
    local damagetype = filterTable["damagetype_const"]
    local inflictor = filterTable["entindex_inflictor_const"]
    local damage = filterTable["damage"] --Post reduction

    -- Store each entity that does damage to a creature to split XP later
    -- When 2 enemy players are fighting for a unit, who lasthits won't matter
    if not victim.attackers then
        victim.attackers = {}
    else
        local hero = attacker:GetOwner()
        if hero then
            local heroIndex = hero:GetEntityIndex() -- Associate the damage done to the hero, ignores summons
            victim.attackers[heroIndex] = victim.attackers[heroIndex] and (victim.attackers[heroIndex] + damage) or damage
        end
    end

    -- Revert damage from MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
    if attacker:IsHero() then
        if damagetype == DAMAGE_TYPE_MAGICAL or damagetype == DAMAGE_TYPE_PURE then
            filterTable["damage"] = filterTable["damage"]/(1+((attacker:GetIntellect()/16)/100))
        end
    end

    -- Physical attack damage filtering
    if damagetype == DAMAGE_TYPE_PHYSICAL then
        if not inflictor then
            -- Physical autoattack filtering here

        end
    end

    return true
end

------------------------------------------------------------------
-- Experience Filter
------------------------------------------------------------------

function ITT:FilterExperience( filterTable )
    --for k, v in pairs( filterTable ) do
        --print("Experience: " .. k .. " " .. tostring(v) )
    --end

    local experience = filterTable["experience"]
    local playerID = filterTable["player_id_const"]
    local reason = filterTable["reason_const"]

    if reason == DOTA_ModifyXP_HeroKill then
        return false
    end

    return true
end

------------------------------------------------------------------
-- Gold Filter
------------------------------------------------------------------

function ITT:FilterGold( filterTable )
    --for k, v in pairs( filterTable ) do
        --print("Gold: " .. k .. " " .. tostring(v) )
    --end

    local gold = filterTable["gold"]
    local playerID = filterTable["player_id_const"]
    local reason = filterTable["reason_const"]

    -- Disable all hero kill gold
    if reason == DOTA_ModifyGold_HeroKill then
        return false
    end

    return true
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
    [29] = "DOTA_UNIT_ORDER_RADAR",
}

DAMAGE_TYPES = {
    [0] = "DAMAGE_TYPE_NONE",
    [1] = "DAMAGE_TYPE_PHYSICAL",
    [2] = "DAMAGE_TYPE_MAGICAL",
    [4] = "DAMAGE_TYPE_PURE",
    [7] = "DAMAGE_TYPE_ALL",
    [8] = "DAMAGE_TYPE_HP_REMOVAL",
}

XP_REASONS = {
    [0] = "DOTA_ModifyXP_Unspecified",
    [1] = "DOTA_ModifyXP_HeroKill",
    [2] = "DOTA_ModifyXP_CreepKill",
    [3] = "DOTA_ModifyXP_RoshanKill",
}

GOLD_REASONS = {
    [0] = "DOTA_ModifyGold_Unspecified",
    [1] = "DOTA_ModifyGold_Death",
    [2] = "DOTA_ModifyGold_Buyback",
    [3] = "DOTA_ModifyGold_PurchaseConsumable",
    [4] = "DOTA_ModifyGold_PurchaseItem",
    [5] = "DOTA_ModifyGold_AbandonedRedistribute",
    [6] = "DOTA_ModifyGold_SellItem",
    [7] = "DOTA_ModifyGold_AbilityCost",
    [8] = "DOTA_ModifyGold_CheatCommand",
    [9] = "DOTA_ModifyGold_SelectionPenalty",
    [10] = "DOTA_ModifyGold_GameTick",
    [11] = "DOTA_ModifyGold_Building",
    [12] = "DOTA_ModifyGold_HeroKill",
    [13] = "DOTA_ModifyGold_CreepKill",
    [14] = "DOTA_ModifyGold_RoshanKill",
    [15] = "DOTA_ModifyGold_CourierKill",
    [16] = "DOTA_ModifyGold_SharedGold",
}
