--[[
wearableTable = items_game['items'][ID]
wearableName = wearableTable['name']
wearableType = wearableTable['prefab'] -- "wearable" or "default_item"
modelName = wearableTable['model_player']

-- If necessary:
particles = wearableTable['particle_folder'] + wearableTable['visuals'] + items_game['attribute_controlled_attached_particles']
--]]

function ITT:PrecacheSubclassModels(context)
    local subclassInfo = LoadKeyValues("scripts/kv/class_info.kv").SubClasses

    for key,subTable in pairs(subclassInfo) do
        if subTable['Model'] then
            PrecacheModel(subTable['Model'], context)
        end

        if subTable['defaults'] then
            for k,v in pairs(subTable['defaults']) do
                PrecacheModel(v, context)
            end 
        end

        if subTable['Wearables'] then
            for k,v in pairs(subTable['Wearables']) do
                if string.find(v, ".vmdl") then
                    PrecacheModel(v, context)
                end
            end
        end
    end
end

-- When a hero gets ingame, check its cosmetics, find out the slot and replace by the defaults
function ITT:SetDefaultCosmetics(hero)
    local class = GetHeroClass(hero)
    local subclassInfo = GameRules.ClassInfo['SubClasses']
    local subclassNames = subclassInfo[class]
    local defaultWearables = subclassNames['defaults']

    print("SetDefaultCosmetics for "..class)

    local wearable = hero:FirstMoveChild()
    while wearable ~= nil do
        if wearable:GetClassname() == "dota_item_wearable" then
            local wearableName = wearable:GetModelName()
            if wearableName ~= "" then
                local slot = modelmap[wearableName] or "weapon" --Default main weapons don't have an item_slot in items_game.txt
                local defaultWearableName = defaultWearables[slot]
                print(wearableName,"at",slot)
                print("Default item at",slot,"is:",defaultWearableName,"\n-------------------------")
                if wearableName ~= defaultWearableName then
                    SwapWearable(hero, wearableName, defaultWearableName)
                end
            end
        end
        wearable = wearable:NextMovePeer()
    end
end

function ITT:OnSubclassChange(event)
    local playerID = event.playerID
    local subclassID = event.subclassID

    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local class = GetHeroClass(hero)
    print("Current class:",class)

    -- Reset subclass (just for testing purposes)
    if GetSubClass(hero) ~= "none" then
        ITT:ResetSubclass(playerID)
    end

    local subclassInfo = GameRules.ClassInfo['SubClasses']
    local subclassNames = subclassInfo[class]

    local new_name = subclassNames[subclassID]

    print("New Subclass:", new_name)
    hero.subclass = new_name

    -- Change the default wearables by new ones for that class
    local defaultWearables = subclassNames['defaults']
    local newWearables = subclassInfo[new_name]['Wearables']

    for slot,modelName in pairs(defaultWearables) do
        SwapWearable(hero, defaultWearables[slot], newWearables[slot])
    end
end

-- Change the current wearables by defaults
function ITT:ResetSubclass(playerID)
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local class = GetHeroClass(hero)
    local subclass = GetSubClass(hero)
    print("Current class and subclass:",class, subclass)

    local subclassInfo = GameRules.ClassInfo['SubClasses']
    local subclassNames = subclassInfo[class]

    local subclassNames = subclassInfo[class]
    local subclassInfo = GameRules.ClassInfo['SubClasses']
    local defaultWearables = subclassNames['defaults']
    local currentWearables = subclassInfo[subclass]['Wearables']

    print("Resetting subclass")
    hero.subclass = "none"

    for slot,modelName in pairs(defaultWearables) do
        SwapWearable(hero, currentWearables[slot], defaultWearables[slot])
    end
end

------------------------------------------------------

-- Swaps a target model for another
function SwapWearable( unit, target_model, new_model )
    local wearable = unit:FirstMoveChild()
    while wearable ~= nil do
        if wearable:GetClassname() == "dota_item_wearable" then
            if wearable:GetModelName() == target_model then
                wearable:SetModel( new_model )
                return
            end
        end
        wearable = wearable:NextMovePeer()
    end
end

------------------------------------------------------

function MapModels()
    for k,v in pairs(itemskeys) do
        if v.model_player then
            modelmap[v.model_player] = v.item_slot or "weapon"
        end
    end
end

function ModelForItemID(itemID)
    return itemskeys[tostring(itemID)].model_player
end

function SlotForItemID(itemID)
    return itemskeys[tostring(itemID)].item_slot
end

function SlotForModel(model)
    return modelmap[model]
end

function GetModelForSlot(clothes, slot)
    for k,v in pairs(clothes) do
        local itemID = v["ItemDef"]
        local newslot = SlotForItemID(itemID)
        if newslot == slot then return ModelForItemID(itemID) end
    end
end