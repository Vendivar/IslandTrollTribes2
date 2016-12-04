
function StartGather(keys)
    print("Starting to gather items in the itempen!")
    Timers:CreateTimer(DoUniqueString("check_building_itempen"), {callback=CheckBuilding, endTime = 0.1}, keys)
end

function CheckBuilding(keys)
    local building = keys.caster

    if building:IsNull() then
        return
    end

    if building:FindModifierByName("modifier_out_of_world") then
        if not building.ghost then
            building.ghost = 1
        end

        building.ghost = building.ghost + 1
        --print("Ghost modifier at "..building.ghost.."!")
        if building.ghost > 100 then
            return nil
        end
        return 1.0
    end

    if building:FindModifierByName("modifier_building_under_construction") then
        --print("Waiting for the construction!")
        return 0.2
    end

    -- Initialization
    building.items = {}
    building.nearby_buildings = {}
    building.range = 400

    print("Actually starting now!")
    Timers:CreateTimer(DoUniqueString("item_gather_itempen"), {callback=Gather, endTime = 0.1}, keys)
end

-- Highly tuned vector&scale table. Handle with care.
local allowed_items = {
    item_stick = {pos = Vector(-30, -110, 0), scale = 0.6},
    item_tinder = {pos = Vector(0, -110, 0), scale = 0.5},
    item_mushroom = {pos = Vector(30, -110, 0), scale = 0.75},
    item_flint = {pos = Vector(60, -110, 0), scale = 1.2},
    item_ball_clay = {pos = Vector(90, -110, 0), scale = 0.75},
    item_crystal_mana = {pos = Vector(-30, -60, 0), scale = 2.2},
    item_bone = {pos = Vector(0, -60, 0), scale = 0.75},
    item_ingot_steel = {pos = Vector(30, -60, 0), scale = 0.4},
    item_ingot_iron = {pos = Vector(60, -60, 0), scale = 0.4},
    item_stone = {pos = Vector(90, -60, 0), scale = 1.0},
    item_river_root = {pos = Vector(-30, -10, 0), scale = 0.75},
    item_river_stem = {pos = Vector(0, -10, 0), scale = 0.75},
    item_herb_purple = {pos = Vector(30, -10 ,0), scale = 0.75},
    item_herb_orange = {pos = Vector(60, -10, 0), scale = 0.75},
    item_herb_blue = {pos = Vector(90, -10, 0), scale = 0.75},
    item_herb_yellow = {pos = Vector(-30, 40, 0), scale = 0.6},
    item_herb_butsu = {pos = Vector(0, 40, 0), scale = 0.4},
    item_spirit_wind = {pos = Vector(30, 40, 0), scale = 1.5},
    item_spirit_water = {pos = Vector(60, 40, 0), scale = 0.5},
    item_hide_elk = {pos = Vector(-30, 90, 0), scale = 0.75},
    item_hide_wolf = {pos = Vector(0, 90, 0), scale = 0.75},
    item_hide_jungle_bear = {pos = Vector(30, 90, 0), scale = 0.75},
    item_magic_raw = {pos = Vector(60, 90, 0), scale = 0.75},
    item_meat_cooked = {pos = Vector(90, 90, 0), scale = 0.75}
    --= {pos = Vector(90, 40, 0), scale = 0.75}
}

local crafting_buildings = {
    npc_building_armory = true,
    npc_building_hut_witch_doctor = true,
    npc_building_mixing_pot = true,
    npc_building_tannery = true,
    npc_building_workshop = true
}

function Gather(keys)
    local building = keys.caster

    if building:IsNull() then
        return nil
    end

    local current_items = {}
    local actual_items = {}

    for k,v in pairs(building.items) do
        current_items[k] = 0
        actual_items[k] = {}
    end

    local find = Entities:FindAllByClassnameWithin("dota_item_drop", building:GetAbsOrigin(), building.range)
    for k,v in pairs(find) do
        local item = v:GetContainedItem()
        local itemName = item:GetAbilityName()
        if allowed_items[itemName] then
            if v.confirm == building:GetEntityIndex() then -- Only when confirmed, count them to our actual inventory.
                if current_items[itemName] then
                    current_items[itemName] = current_items[itemName] + 1
                else
                    current_items[itemName] = 1
                    actual_items[itemName] = {}
                end
                table.insert(actual_items[itemName], v)
            end

            if v.counted == building:GetEntityIndex() and not v.positioned and not v.confirm then -- Confirming position.
                v.positioned = true
        		local grabFX = ParticleManager:CreateParticle("particles/econ/items/pugna/pugna_ward_ti5/pugna_ward_attack_light_ti_5.vpcf", PATTACH_OVERHEAD_FOLLOW, building)
                ParticleManager:SetParticleControl(grabFX, 0, building:GetAbsOrigin())
                ParticleManager:SetParticleControl(grabFX, 1, v:GetAbsOrigin())
        		ParticleManager:SetParticleControl(grabFX, 2, building:GetAbsOrigin())
        		ParticleManager:SetParticleControl(grabFX, 3, building:GetAbsOrigin())
                ParticleManager:SetParticleControl(grabFX, 4, v:GetAbsOrigin())
                EmitSoundOn( "itempen.grab", building )
                SetPosition(v, building.items[itemName].position, building:GetEntityIndex())
            end

            if not v.counted then -- A new item!
                v.counted = building:GetEntityIndex()

                local building_item = building.items[itemName]
                -- Add it to our inventory.
                local c = 1
                if item:GetCurrentCharges() > 1 then
                    c = item:GetCurrentCharges()
                end

                if not building_item then
                    building.items[itemName] = {
                        position = building:GetAbsOrigin() + allowed_items[itemName].pos,
                        count = c
                    }
                    building_item = building.items[itemName]
                else
                    building.items[itemName].count = building_item.count + c
                end

                if item:GetCurrentCharges() > 1 then
                    CreateItemsFromStack(item:GetCurrentCharges(), itemName, building_item.position, allowed_items[itemName].scale)

                    UTIL_RemoveImmediate(item)
                    UTIL_RemoveImmediate(v)
                else
                    v:SetOrigin(building_item.position)
                    v:SetModelScale(allowed_items[itemName].scale)
                end
            end
        elseif not string.find(itemName, "_bush_") or not string.find(itemName, "_meat_") then
            if not v.launched then
                v.launched = true
                if (v:GetAbsOrigin() - building:GetAbsOrigin()):Length2D() < 150 then
                    -- Only launch items that are too close to the itempen.
                    DropLaunch(building, item, 0.5, building:GetAbsOrigin() + RandomVector(300))
                end
            end
        end
    end

    local change = false
    for k,v in pairs(current_items) do
        if building.items[k].count ~= v then
            change = true
            building.items[k].count = v
            building.items[k].items = actual_items[k]
        end
    end

    local find = Entities:FindAllByClassnameWithin("npc_dota_creature", building:GetAbsOrigin(), 1500)
    for k,v in pairs(find) do
        if crafting_buildings[v:GetUnitName()] then
            local entIndex = v:GetEntityIndex()
            if not building.nearby_buildings[entIndex] then
                change = true
                building.nearby_buildings[entIndex] = v

                if not v.itempens then
                    v.itempens = {}
                end

                if not v.itempens[entIndex] then
                    v.itempens[entIndex] = building
                end
            end
        end
    end

    if change then
        --print("There's a change!")
        --PrintTable(current_items)
        SendDataToClients(building, current_items)
    end

    return 0.2
end

function CreateItemsFromStack(charges, itemName, position, scale)
    for i = 1, charges do
        local newItem = CreateItem(itemName, nil, nil)
        newItem = CreateItemOnPositionSync(position, newItem)
        newItem:SetOrigin(position)
        newItem:SetModelScale(scale)
        newItem.counted = true
    end
end

function SendDataToClients(building, current_items)
    local buildings_found = {};
    for k,v in pairs(building.nearby_buildings) do
        buildings_found[#buildings_found + 1] = k
    end

    CustomGameEventManager:Send_ServerToTeam(building:GetTeam(), "itempen_updated", {
        itempen_id = building:GetEntityIndex(),
        inventory = current_items,
        buildings = buildings_found
    })
end

function SetPosition(item, position, id)
    if item:GetVelocity():Length() > 0 then
        Timers:CreateTimer({
            callback = function()
                if not item:IsNull() then
                    if item:GetVelocity():Length() > 0 then
                        return 0.2
                    else
                        item:SetOrigin(position)
                        item.confirm = id
                    end
                end
            end
        })
    else
        if item:GetAbsOrigin() ~= position then
            item:SetOrigin(position)
        end
        item.confirm = id
    end
end
